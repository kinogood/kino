*----------------------------------------------------------------------*
***INCLUDE ZLER1200_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS   USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE
                          P_GRID   TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_TOOLBAR     TYPE STB_BUTTON.
  DATA: LT_BOTTOM_LEFT LIKE GT_BOTTOM_LEFT OCCURS 0 WITH HEADER LINE.

  CASE P_GRID.

    WHEN GC_ALV_GRID1.
      CHECK NOT GT_TOP_LEFT[] IS INITIAL.

      CASE GC_X.
        WHEN P_RAD1 OR P_RAD3.
*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO LS_TOOLBAR-BUTN_TYPE.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___상세
          CLEAR LS_TOOLBAR.
          MOVE 'RIGHT'              TO LS_TOOLBAR-FUNCTION.
          MOVE ICON_ARROW_RIGHT     TO LS_TOOLBAR-ICON.
          MOVE '▶'                 TO LS_TOOLBAR-QUICKINFO.
          MOVE '상세'               TO LS_TOOLBAR-TEXT.
          MOVE ' '                  TO LS_TOOLBAR-DISABLED.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO LS_TOOLBAR-BUTN_TYPE.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___SAVE
*{ 기능개선 156428 - 추가
          IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
            CLEAR LS_TOOLBAR.
            MOVE 'SAVE'             TO LS_TOOLBAR-FUNCTION.
            MOVE ICON_SYSTEM_SAVE   TO LS_TOOLBAR-ICON.
            MOVE '저장'             TO LS_TOOLBAR-QUICKINFO.
            MOVE 'SAVE'             TO LS_TOOLBAR-TEXT.

            IF P_RAD1 EQ GC_X OR P_RAD3 EQ GC_X.
              MOVE ' '              TO LS_TOOLBAR-DISABLED.
            ELSEIF P_RAD2 EQ GC_X OR P_RAD4 EQ GC_X..
              MOVE 'X'              TO LS_TOOLBAR-DISABLED.
            ENDIF.

            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
            CLEAR LS_TOOLBAR.
            MOVE   3                TO LS_TOOLBAR-BUTN_TYPE.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Delete(초기화)
            CLEAR LS_TOOLBAR.
            MOVE 'DELETE'           TO LS_TOOLBAR-FUNCTION.
            MOVE ICON_DELETE        TO LS_TOOLBAR-ICON.
            MOVE '초기화'           TO LS_TOOLBAR-QUICKINFO.
            MOVE '초기화'           TO LS_TOOLBAR-TEXT.

            IF P_RAD1 EQ GC_X OR P_RAD3 EQ GC_X.
              MOVE ' '              TO LS_TOOLBAR-DISABLED.
            ELSEIF P_RAD2 EQ GC_X OR P_RAD4 EQ GC_X..
              MOVE 'X'              TO LS_TOOLBAR-DISABLED.
            ENDIF.

            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
            CLEAR LS_TOOLBAR.
            MOVE   3                TO LS_TOOLBAR-BUTN_TYPE.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___TMS 전송
            CLEAR LS_TOOLBAR.
            MOVE 'SEND'             TO LS_TOOLBAR-FUNCTION.
            MOVE ICON_TRANSFER      TO LS_TOOLBAR-ICON.
            MOVE 'TMS 전송'         TO LS_TOOLBAR-QUICKINFO.
            MOVE 'TMS 전송'         TO LS_TOOLBAR-TEXT.

            IF P_RAD1 EQ GC_X OR P_RAD3 EQ GC_X.
              MOVE ' '              TO LS_TOOLBAR-DISABLED.
            ELSEIF P_RAD2 EQ GC_X OR P_RAD4 EQ GC_X..
              MOVE 'X'              TO LS_TOOLBAR-DISABLED.
            ENDIF.

            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
            CLEAR LS_TOOLBAR.
            MOVE   3                TO LS_TOOLBAR-BUTN_TYPE.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
          ENDIF.

*___범례
          CLEAR LS_TOOLBAR.
          MOVE 'LEGEND'             TO LS_TOOLBAR-FUNCTION.
          MOVE ICON_INFORMATION     TO LS_TOOLBAR-ICON.
          MOVE '범례'               TO LS_TOOLBAR-QUICKINFO.
          MOVE '범례'               TO LS_TOOLBAR-TEXT.

        WHEN OTHERS.
*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO LS_TOOLBAR-BUTN_TYPE.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___상세
          CLEAR LS_TOOLBAR.
          MOVE 'RIGHT'              TO LS_TOOLBAR-FUNCTION.
          MOVE ICON_ARROW_RIGHT     TO LS_TOOLBAR-ICON.
          MOVE '▶'                 TO LS_TOOLBAR-QUICKINFO.
          MOVE '상세'               TO LS_TOOLBAR-TEXT.
          MOVE ' '                  TO LS_TOOLBAR-DISABLED.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO LS_TOOLBAR-BUTN_TYPE.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___SAVE
*{ 기능개선 156428 - 추가
          IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
            CLEAR LS_TOOLBAR.
            MOVE 'SAVE'             TO LS_TOOLBAR-FUNCTION.
            MOVE ICON_SYSTEM_SAVE   TO LS_TOOLBAR-ICON.
            MOVE '저장'             TO LS_TOOLBAR-QUICKINFO.
            MOVE 'SAVE'             TO LS_TOOLBAR-TEXT.
            MOVE 'X'                TO LS_TOOLBAR-DISABLED.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
            CLEAR LS_TOOLBAR.
            MOVE   3                TO LS_TOOLBAR-BUTN_TYPE.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
          ENDIF.

*___Delete(초기화)
          CLEAR LS_TOOLBAR.
          MOVE 'DELETE'             TO LS_TOOLBAR-FUNCTION.
          MOVE ICON_DELETE          TO LS_TOOLBAR-ICON.
          MOVE '초기화'             TO LS_TOOLBAR-QUICKINFO.
          MOVE '초기화'             TO LS_TOOLBAR-TEXT.
          MOVE 'X'                  TO LS_TOOLBAR-DISABLED.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO LS_TOOLBAR-BUTN_TYPE.
          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

*___TMS 전송
*{ 기능개선 156428 - 추가
          IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
            CLEAR LS_TOOLBAR.
            MOVE 'SEND'             TO LS_TOOLBAR-FUNCTION.
            MOVE ICON_TRANSFER      TO LS_TOOLBAR-ICON.
            MOVE 'TMS 전송'         TO LS_TOOLBAR-QUICKINFO.
            MOVE 'TMS 전송'         TO LS_TOOLBAR-TEXT.
            MOVE 'X'                TO LS_TOOLBAR-DISABLED.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.

*___Separator Line
            CLEAR LS_TOOLBAR.
            MOVE   3                TO LS_TOOLBAR-BUTN_TYPE.
            APPEND LS_TOOLBAR       TO R_OBJECT->MT_TOOLBAR.
          ENDIF.

*___범례
          CLEAR LS_TOOLBAR.
          MOVE 'LEGEND'             TO LS_TOOLBAR-FUNCTION.
          MOVE ICON_INFORMATION     TO LS_TOOLBAR-ICON.
          MOVE '범례'               TO LS_TOOLBAR-QUICKINFO.
          MOVE '범례'               TO LS_TOOLBAR-TEXT.

      ENDCASE.

      MOVE ' '                      TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR             TO R_OBJECT->MT_TOOLBAR.

    WHEN GC_ALV_GRID2.
*___행삭제
      CLEAR LS_TOOLBAR.
      MOVE 'DELETE'                 TO LS_TOOLBAR-FUNCTION.
      MOVE ICON_DELETE_ROW          TO LS_TOOLBAR-ICON.
      MOVE '행 삭제'                TO LS_TOOLBAR-QUICKINFO.
      MOVE ' '                      TO LS_TOOLBAR-TEXT.

      CASE GC_X.
        WHEN P_RAD1 OR P_RAD3.
          IF NOT GT_TOP_RIGHT[] IS INITIAL.
            MOVE ' '                TO LS_TOOLBAR-DISABLED.
          ELSEIF P_RAD1 EQ GC_X OR P_RAD3 EQ GC_X.
            MOVE 'X'                TO LS_TOOLBAR-DISABLED.
          ENDIF.

        WHEN OTHERS.
          MOVE 'X'                  TO LS_TOOLBAR-DISABLED.

      ENDCASE.

      APPEND LS_TOOLBAR             TO R_OBJECT->MT_TOOLBAR.

    WHEN GC_ALV_GRID3.

      MOVE GT_BOTTOM_LEFT[] TO LT_BOTTOM_LEFT[].
      SORT LT_BOTTOM_LEFT BY ICON.

      DELETE LT_BOTTOM_LEFT WHERE ICON EQ ICON_LED_INACTIVE.

    WHEN GC_ALV_GRID4.
      CASE GC_X.
        WHEN P_RAD1 OR P_RAD3.
*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
          INSERT LS_TOOLBAR         INTO R_OBJECT->MT_TOOLBAR INDEX 1.

*___행삽입
          CLEAR LS_TOOLBAR.
          MOVE 'NEW'                TO   LS_TOOLBAR-FUNCTION.
          MOVE ICON_INSERT_ROW      TO   LS_TOOLBAR-ICON.
          MOVE '행 삽입'            TO   LS_TOOLBAR-QUICKINFO.
          MOVE ' '                  TO   LS_TOOLBAR-TEXT.

          IF NOT GT_BOTTOM_LEFT[] IS INITIAL.
            MOVE ' '                TO   LS_TOOLBAR-DISABLED.
          ELSE.
            MOVE 'X'                TO   LS_TOOLBAR-DISABLED.
          ENDIF.

          LOOP AT GT_BOTTOM_RIGHT WHERE ICON EQ ICON_LIGHT_OUT
                                     OR ICON EQ ICON_YELLOW_LIGHT
                                     OR ICON EQ ICON_GREEN_LIGHT.
            EXIT.
          ENDLOOP.

          IF SY-SUBRC EQ 0.
            MOVE ' '                TO   LS_TOOLBAR-DISABLED.
          ELSE.
            MOVE 'X'                TO   LS_TOOLBAR-DISABLED.
          ENDIF.

          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

          CLEAR LS_TOOLBAR.
          MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
          INSERT LS_TOOLBAR         INTO R_OBJECT->MT_TOOLBAR INDEX 1.

*___행삭제
          CLEAR LS_TOOLBAR.
          MOVE 'DELETE'             TO   LS_TOOLBAR-FUNCTION.
          MOVE ICON_DELETE_ROW      TO   LS_TOOLBAR-ICON.
          MOVE '행 삭제'            TO   LS_TOOLBAR-QUICKINFO.
          MOVE ' '                  TO   LS_TOOLBAR-TEXT.

          IF NOT GT_BOTTOM_RIGHT[] IS INITIAL.
            MOVE ' '                TO   LS_TOOLBAR-DISABLED.
          ELSE.
            MOVE 'X'                TO   LS_TOOLBAR-DISABLED.
          ENDIF.

          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

        WHEN OTHERS.
*___Separator Line
          CLEAR LS_TOOLBAR.
          MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
          INSERT LS_TOOLBAR         INTO R_OBJECT->MT_TOOLBAR INDEX 1.

*___행삽입
          CLEAR LS_TOOLBAR.
          MOVE 'NEW'                TO   LS_TOOLBAR-FUNCTION.
          MOVE ICON_INSERT_ROW      TO   LS_TOOLBAR-ICON.
          MOVE '행 삽입'            TO   LS_TOOLBAR-QUICKINFO.
          MOVE ' '                  TO   LS_TOOLBAR-TEXT.
          MOVE 'X'                  TO   LS_TOOLBAR-DISABLED.

          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

          CLEAR LS_TOOLBAR.
          MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
          INSERT LS_TOOLBAR         INTO R_OBJECT->MT_TOOLBAR INDEX 1.

*___행삭제
          CLEAR LS_TOOLBAR.
          MOVE 'DELETE'             TO   LS_TOOLBAR-FUNCTION.
          MOVE ICON_DELETE_ROW      TO   LS_TOOLBAR-ICON.
          MOVE '행 삭제'            TO   LS_TOOLBAR-QUICKINFO.
          MOVE ' '                  TO   LS_TOOLBAR-TEXT.
          MOVE 'X'                  TO   LS_TOOLBAR-DISABLED.

          APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

      ENDCASE.

  ENDCASE.

ENDFORM.                    " TOOLBAR_PROS
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING  E_UCOMM
                               SENDER.

  DATA: LT_ROWS TYPE LVC_T_ROW.

  PERFORM GET_SELECT_ROW USING SENDER CHANGING LT_ROWS[].

  CASE SENDER.
    WHEN GC_ALV_GRID1.            "top left
      CASE E_UCOMM.
          " 상세 정보 조회
        WHEN 'RIGHT'.
          " 변경 사항 체크
          PERFORM CHECK_CHANGED_SET.

          CLEAR GV_ERROR.
          PERFORM SEND_SALES_DETAIL USING SENDER.

          CHECK GV_ERROR IS INITIAL.

*          perform handle_screen_size_height using 35.
*          perform handle_screen_size_width using 40.
          PERFORM REFRESH_GRID USING GC_ALV_GRID1.
          PERFORM REFRESH_GRID USING GC_ALV_GRID2.
          PERFORM REFRESH_GRID USING GC_ALV_GRID3.
          PERFORM REFRESH_GRID USING GC_ALV_GRID4.
          " 저장 로릭
        WHEN 'SAVE'.
          " 변경 사항 체크
          PERFORM CHECK_CHANGED_SET.

          CLEAR GV_ERROR.
          PERFORM SAVE_DELIVERY USING SENDER.

          CHECK GV_ERROR IS INITIAL.

*          perform handle_screen_size_height using 35.
*          perform handle_screen_size_width using 40.
          PERFORM REFRESH_GRID USING GC_ALV_GRID1.
          PERFORM REFRESH_GRID USING GC_ALV_GRID2.
          PERFORM REFRESH_GRID USING GC_ALV_GRID3.
          PERFORM REFRESH_GRID USING GC_ALV_GRID4.

          " 삭제
        WHEN 'DELETE'.
          " 변경 사항 체크
          PERFORM CHECK_CHANGED_SET.

          CLEAR GV_ERROR.
          PERFORM DELETE_DELIVERY USING SENDER.

          CHECK GV_ERROR IS INITIAL.

*          perform handle_screen_size_height using 35.
*          perform handle_screen_size_width using 40.
          PERFORM REFRESH_GRID USING GC_ALV_GRID1.
          PERFORM REFRESH_GRID USING GC_ALV_GRID2.
          PERFORM REFRESH_GRID USING GC_ALV_GRID3.
          PERFORM REFRESH_GRID USING GC_ALV_GRID4.

          " tms 전송
        WHEN 'SEND'.
          " 변경 사항 체크
          PERFORM CHECK_CHANGED_SET.
          PERFORM SEND_DELIVERY USING SENDER.

          " new line
        WHEN 'NEW'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM ADD_ROW USING SENDER.

          " 범레
        WHEN 'LEGEND'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM CALL_LEGEND_POPUP.

      ENDCASE.

    WHEN GC_ALV_GRID2.            "top right
      CASE E_UCOMM.
*        WHEN 'NEW'.
*          PERFORM add_row USING sender.
        WHEN 'DELETE'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM DELETE_ROW USING SENDER.
      ENDCASE.

    WHEN GC_ALV_GRID3.            "bottom left
      CASE E_UCOMM.
        WHEN'NEW'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM ADD_ROW USING SENDER.
      ENDCASE.

    WHEN GC_ALV_GRID4.            "bottom right
      CASE E_UCOMM.
        WHEN 'NEW'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM ADD_ROW USING SENDER.

        WHEN 'DELETE'.
          PERFORM CHECK_CHANGED_SET.
          PERFORM DELETE_ROW USING SENDER.

      ENDCASE.

  ENDCASE.

  PERFORM SET_SELECT_ROW USING SENDER
                      CHANGING LT_ROWS[].

ENDFORM.                    " USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING P_MODIFIED
                                  PT_GOOD_CELLS TYPE LVC_T_MODI
                                  P_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_TOP LIKE GT_TOP_LEFT OCCURS 0 WITH HEADER LINE.
  DATA: PS_GOOD_CELLS TYPE LVC_S_MODI.

  CHECK P_MODIFIED = 'X'.

  " 톤수차량 변경이 경우 REFRESH
  IF GV_REFRESH_FLAG EQ GC_X.
    CLEAR GV_REFRESH_FLAG.
    PERFORM REFRESH_GRID USING GC_ALV_GRID1.
  ENDIF.

  " 4개의 화면의 아이콘을  refresh 없이 변경
  CASE P_GRID.
    WHEN GC_ALV_GRID1.
      CASE GC_X.
          " 일반 출하
        WHEN P_RAD1 OR P_RAD2.
          " 4개의 화면에 아이콘 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_TOP_LEFT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.
*{ 기능개선 159419 - 추가
            IF GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
*} 기능개선 159419 - 추가
              GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
              GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.
              MODIFY GT_TOP_LEFT INDEX PS_GOOD_CELLS-ROW_ID
                                 TRANSPORTING ICON.

              MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                   WHERE VBELN EQ GT_TOP_LEFT-VBELN.

              MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                    WHERE VBELN EQ GT_TOP_LEFT-VBELN
                                      AND NOT ICON EQ ICON_LED_INACTIVE.

              MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                     WHERE VBELN EQ GT_TOP_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_LEFT[]
                                              GC_ALV_GRID1
                                              GT_TOP_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_RIGHT[]
                                              GC_ALV_GRID2
                                              GT_TOP_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_LEFT[]
                                              GC_ALV_GRID3
                                              GT_TOP_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_RIGHT[]
                                              GC_ALV_GRID4
                                              GT_TOP_LEFT-VBELN.
            ENDIF.
          ENDLOOP.

          " 컨테이너 시뮬레이션
        WHEN P_RAD3 OR P_RAD4.
          " 4개의 화면에 아이콘 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_TOP_LEFT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.

            MOVE GT_TOP_LEFT-SHSRQ TO LT_TOP-SHSRQ.
            APPEND LT_TOP.

            GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
            GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

            MODIFY GT_TOP_LEFT TRANSPORTING ICON
                               WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ.

            MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                 WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ.

            MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                  WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ
                                    AND NOT ICON EQ ICON_LED_INACTIVE.

            MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                   WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ.
          ENDLOOP.

          LOOP AT LT_TOP.
            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_LEFT[]
                                                GC_ALV_GRID1
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_RIGHT[]
                                                GC_ALV_GRID2
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_LEFT[]
                                                GC_ALV_GRID3
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_RIGHT[]
                                                GC_ALV_GRID4
                                                LT_TOP-SHSRQ.
          ENDLOOP.

      ENDCASE.

    WHEN GC_ALV_GRID2.
      "  해당 라인의 아이콘 상태값 변경
      IF NOT GT_DELTA_CELLS[] IS INITIAL.
        PERFORM DISPLAY_CHANGE_CELLS USING GT_DELTA_CELLS[]
                                           GC_ALV_GRID4.

        PERFORM REFRESH_GRID USING GC_ALV_GRID4.

        REFRESH GT_DELTA_CELLS.
      ENDIF.

      CASE GC_X.
          " 일반 출하
        WHEN P_RAD1 OR P_RAD2.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_TOP_RIGHT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.

*{ 기능개선 159419 - 추가
            READ TABLE GT_TOP_LEFT WITH KEY VBELN = GT_TOP_RIGHT-VBELN.

            IF SY-SUBRC = 0 AND GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
*} 기능개선 159419 - 추가
              GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
              GT_TOP_RIGHT-ICON  = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

              MODIFY GT_TOP_RIGHT INDEX PS_GOOD_CELLS-ROW_ID
                                  TRANSPORTING ICON.

              MODIFY GT_TOP_LEFT  TRANSPORTING ICON
                                  WHERE VBELN EQ GT_TOP_RIGHT-VBELN.

              MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                    WHERE VBELN EQ GT_TOP_RIGHT-VBELN
                                      AND NOT ICON EQ ICON_LED_INACTIVE.

              MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                     WHERE VBELN EQ GT_TOP_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_LEFT[]
                                              GC_ALV_GRID1
                                              GT_TOP_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_RIGHT[]
                                              GC_ALV_GRID2
                                              GT_TOP_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_LEFT[]
                                              GC_ALV_GRID3
                                              GT_TOP_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_RIGHT[]
                                              GC_ALV_GRID4
                                              GT_TOP_RIGHT-VBELN.
            ENDIF.
          ENDLOOP.

          " 컨테이너 시뮬레이션
        WHEN P_RAD3 OR P_RAD4.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_TOP_RIGHT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.

            MOVE GT_TOP_RIGHT-SHSRQ TO LT_TOP-SHSRQ.
            APPEND LT_TOP.

            GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON
            = GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

            MODIFY GT_TOP_RIGHT TRANSPORTING ICON
                                WHERE SHSRQ EQ GT_TOP_RIGHT-SHSRQ.

            MODIFY GT_TOP_LEFT  TRANSPORTING ICON
                                WHERE SHSRQ EQ GT_TOP_RIGHT-SHSRQ.

            MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                  WHERE SHSRQ EQ GT_TOP_RIGHT-SHSRQ
                                    AND NOT ICON EQ ICON_LED_INACTIVE.

            MODIFY GT_BOTTOM_RIGHT  TRANSPORTING ICON
                                    WHERE SHSRQ EQ GT_TOP_RIGHT-SHSRQ.
          ENDLOOP.

          LOOP AT LT_TOP.
            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_LEFT[]
                                                GC_ALV_GRID1
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_RIGHT[]
                                                GC_ALV_GRID2
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_LEFT[]
                                                GC_ALV_GRID3
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_RIGHT[]
                                                GC_ALV_GRID4
                                                LT_TOP-SHSRQ.
          ENDLOOP.

      ENDCASE.

    WHEN GC_ALV_GRID3.

      CASE GC_X.
          " 일반 출하
        WHEN P_RAD1 OR P_RAD2.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_BOTTOM_LEFT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.
            CHECK NOT GT_BOTTOM_LEFT-ICON EQ ICON_LED_INACTIVE.

*{ 기능개선 159419 - 추가
            READ TABLE GT_TOP_LEFT
                       WITH KEY VBELN = GT_BOTTOM_LEFT-VBELN.

            IF SY-SUBRC = 0 AND GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
*} 기능개선 159419 - 추가
              GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
              GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

              MODIFY GT_BOTTOM_LEFT INDEX PS_GOOD_CELLS-ROW_ID
                                    TRANSPORTING ICON.

              MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                   WHERE VBELN EQ GT_BOTTOM_LEFT-VBELN.

              MODIFY GT_TOP_LEFT TRANSPORTING ICON
                                 WHERE VBELN EQ GT_BOTTOM_LEFT-VBELN.

              MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                    WHERE VBELN EQ GT_BOTTOM_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_LEFT[]
                                              GC_ALV_GRID1
                                              GT_BOTTOM_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_RIGHT[]
                                              GC_ALV_GRID2
                                              GT_BOTTOM_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_LEFT[]
                                              GC_ALV_GRID3
                                              GT_BOTTOM_LEFT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_RIGHT[]
                                              GC_ALV_GRID4
                                              GT_BOTTOM_LEFT-VBELN.
            ENDIF.
          ENDLOOP.

          " 컨테이너 시뮬레이션
        WHEN P_RAD3 OR P_RAD4.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_BOTTOM_LEFT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.
            CHECK NOT GT_BOTTOM_LEFT-ICON EQ ICON_LED_INACTIVE.

            MOVE GT_BOTTOM_LEFT-SHSRQ TO LT_TOP-SHSRQ.
            APPEND LT_TOP.

            GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON
            = GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

            MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                  WHERE SHSRQ EQ GT_BOTTOM_LEFT-SHSRQ.

            MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                 WHERE SHSRQ EQ GT_BOTTOM_LEFT-SHSRQ.

            MODIFY GT_TOP_LEFT TRANSPORTING ICON
                               WHERE SHSRQ EQ GT_BOTTOM_LEFT-SHSRQ.

            MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                   WHERE SHSRQ EQ GT_BOTTOM_LEFT-SHSRQ.
          ENDLOOP.
*
          LOOP AT LT_TOP.
            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_LEFT[]
                                                GC_ALV_GRID1
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_RIGHT[]
                                                GC_ALV_GRID2
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_LEFT[]
                                                GC_ALV_GRID3
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_RIGHT[]
                                                GC_ALV_GRID4
                                                LT_TOP-SHSRQ.
          ENDLOOP.

      ENDCASE.

    WHEN GC_ALV_GRID4.
      "  해당 라인의 아이콘 상태값 변경
      IF NOT GT_DELTA_CELLS[] IS INITIAL.
        PERFORM DISPLAY_CHANGE_CELLS USING GT_DELTA_CELLS[]
        GC_ALV_GRID2.
        REFRESH GT_DELTA_CELLS.
      ENDIF.

      CASE GC_X.
        WHEN P_RAD1 OR P_RAD2.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_BOTTOM_RIGHT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.

*{ 기능개선 159419 - 추가
            READ TABLE GT_TOP_LEFT
                       WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN.

            IF SY-SUBRC = 0 AND GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
*} 기능개선 159419 - 추가
              GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
              GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

              MODIFY GT_BOTTOM_RIGHT INDEX PS_GOOD_CELLS-ROW_ID
                                     TRANSPORTING ICON.

              MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                   WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN.

              MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                    WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN
                                      AND NOT ICON EQ ICON_LED_INACTIVE.

              MODIFY GT_TOP_LEFT  TRANSPORTING ICON
                                  WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_LEFT[]
                                              GC_ALV_GRID1
                                              GT_BOTTOM_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_TOP_RIGHT[]
                                              GC_ALV_GRID2
                                              GT_BOTTOM_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_LEFT[]
                                              GC_ALV_GRID3
                                              GT_BOTTOM_RIGHT-VBELN.

              PERFORM MODIFY_GRID_CELLS USING GT_BOTTOM_RIGHT[]
                                              GC_ALV_GRID4
                                              GT_BOTTOM_RIGHT-VBELN.
            ENDIF.
          ENDLOOP.

        WHEN P_RAD3 OR P_RAD4.
          " 동일한 납품문서의 아이콘 상태값 변경 및 4개 화면 아이콘
          " 상태값 변경
          LOOP AT PT_GOOD_CELLS INTO PS_GOOD_CELLS.
            READ TABLE GT_BOTTOM_RIGHT INDEX PS_GOOD_CELLS-ROW_ID.
            CHECK SY-SUBRC EQ 0.

            MOVE GT_BOTTOM_RIGHT-SHSRQ TO LT_TOP-SHSRQ.
            APPEND LT_TOP.

            GT_BOTTOM_RIGHT-ICON = GT_BOTTOM_LEFT-ICON
            = GT_TOP_RIGHT-ICON = GT_TOP_LEFT-ICON = ICON_YELLOW_LIGHT.

            MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                                   WHERE SHSRQ EQ GT_BOTTOM_RIGHT-SHSRQ.

            MODIFY GT_TOP_RIGHT  TRANSPORTING ICON
                                 WHERE SHSRQ EQ GT_BOTTOM_RIGHT-SHSRQ.

            MODIFY GT_BOTTOM_LEFT TRANSPORTING ICON
                                  WHERE SHSRQ EQ GT_BOTTOM_RIGHT-SHSRQ
                                    AND NOT ICON EQ ICON_LED_INACTIVE.

            MODIFY GT_TOP_LEFT  TRANSPORTING ICON
                                WHERE SHSRQ EQ GT_BOTTOM_RIGHT-SHSRQ.
          ENDLOOP.

          LOOP AT LT_TOP.
            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_LEFT[]
                                                GC_ALV_GRID1
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_TOP_RIGHT[]
                                                GC_ALV_GRID2
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_LEFT[]
                                                GC_ALV_GRID3
                                                LT_TOP-SHSRQ.

            PERFORM MODIFY_GRID_CELLS_TWO USING GT_BOTTOM_RIGHT[]
                                                GC_ALV_GRID4
                                                LT_TOP-SHSRQ.
          ENDLOOP.

      ENDCASE.

      " 4사분면 화면에 의해서 1사분면 화면에 신규라인이
      " 늘어나는 로직
      IF GV_MOD_FLAG EQ GC_X.
        CLEAR GT_BOTTOM_RIGHT.
        READ TABLE GT_BOTTOM_RIGHT INDEX GV_INDEX.

        CHECK SY-SUBRC EQ 0.

        CLEAR GT_TOP_RIGHT.
        READ TABLE GT_TOP_RIGHT
          WITH KEY VBELN   = GT_BOTTOM_RIGHT-VBELN
                   PKTYP   = GT_BOTTOM_RIGHT-PKTYP
                   PKMATNR = GT_BOTTOM_RIGHT-PKMATNR
                   WIDTH   = GT_BOTTOM_RIGHT-WIDTH
                   ZLENGTH = GT_BOTTOM_RIGHT-ZLENGTH
                   HEIGHT  = GT_BOTTOM_RIGHT-HEIGHT
                   PKWEI   = GT_BOTTOM_RIGHT-PKWEI.

        IF SY-SUBRC <> 0.
          MOVE-CORRESPONDING GT_BOTTOM_RIGHT TO GT_TOP_RIGHT.

          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
                                              'WIDTH'
                                     CHANGING GT_TOP_LEFT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
                                              'ZLENGTH'
                                     CHANGING GT_TOP_LEFT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
                                              'HEIGHT'
                                     CHANGING GT_TOP_LEFT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
                                              'PKWEI'
                                     CHANGING GT_TOP_LEFT-CELLTAB.

          APPEND GT_TOP_RIGHT. CLEAR GT_TOP_RIGHT.

          PERFORM REFRESH_GRID USING GC_ALV_GRID2.
        ENDIF.

        CLEAR: GV_MOD_FLAG, GV_INDEX.

      ENDIF.

  ENDCASE.

  REFRESH GT_DELTA_CELLS.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING
                            P_ROW
                            P_COLUMN TYPE LVC_S_COL
                            P_SENDER.

  CASE P_SENDER.
    WHEN GC_ALV_GRID1.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN'.
          CASE GC_X.
            WHEN P_RAD1 OR P_RAD2.
              CLEAR GT_TOP_LEFT.
              READ TABLE GT_TOP_LEFT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'VL' 'VL03N'
                                             GT_TOP_LEFT-VBELN.

            WHEN P_RAD3 OR P_RAD4.
              CLEAR GT_TOP_LEFT.
              READ TABLE GT_TOP_LEFT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                             GT_TOP_LEFT-VBELN.

          ENDCASE.

        WHEN 'KUNNR'.
          CLEAR GT_TOP_LEFT.
          READ TABLE GT_TOP_LEFT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'KUN' 'XD03'
                                         GT_TOP_LEFT-KUNNR.
      ENDCASE.

    WHEN GC_ALV_GRID2.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN'.
          CASE GC_X.
            WHEN P_RAD1 OR P_RAD2.
              CLEAR GT_TOP_RIGHT.
              READ TABLE GT_TOP_RIGHT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'VL' 'VL03N'
                                             GT_TOP_RIGHT-VBELN.

            WHEN P_RAD3 OR P_RAD4.
              CLEAR GT_TOP_RIGHT.
              READ TABLE GT_TOP_RIGHT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                             GT_TOP_RIGHT-VBELN.

          ENDCASE.

      ENDCASE.

    WHEN GC_ALV_GRID3.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN'.
          CASE GC_X.
            WHEN P_RAD1 OR P_RAD2.
              CLEAR GT_BOTTOM_LEFT.
              READ TABLE GT_BOTTOM_LEFT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'VL' 'VL03N'
                                             GT_BOTTOM_LEFT-VBELN.

            WHEN P_RAD3 OR P_RAD4.
              CLEAR GT_BOTTOM_LEFT.
              READ TABLE GT_BOTTOM_LEFT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                             GT_BOTTOM_LEFT-VBELN.

          ENDCASE.

        WHEN  'VBELN_VL'.
          CLEAR GT_BOTTOM_LEFT.
          READ TABLE GT_BOTTOM_LEFT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                         GT_BOTTOM_LEFT-VBELN_VL.

        WHEN  'MATNR'.
          CLEAR GT_BOTTOM_LEFT.
          READ TABLE GT_BOTTOM_LEFT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'MAT' 'MM03'
                                         GT_BOTTOM_LEFT-MATNR.

        WHEN 'KUNNR'.
          CLEAR GT_BOTTOM_LEFT.
          READ TABLE GT_BOTTOM_LEFT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'KUN' 'XD03'
                                         GT_BOTTOM_LEFT-KUNNR.
      ENDCASE.

    WHEN GC_ALV_GRID4.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN'.
          CASE GC_X.
            WHEN P_RAD1 OR P_RAD2.
              CLEAR GT_BOTTOM_RIGHT.
              READ TABLE GT_BOTTOM_RIGHT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'VL' 'VL03N'
                                             GT_BOTTOM_RIGHT-VBELN.

            WHEN P_RAD3 OR P_RAD4.
              CLEAR GT_BOTTOM_RIGHT.
              READ TABLE GT_BOTTOM_RIGHT INDEX P_ROW.
              CHECK SY-SUBRC EQ 0.

              PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                             GT_BOTTOM_RIGHT-VBELN.

          ENDCASE.

        WHEN  'VBELN_VL'.
          CLEAR GT_BOTTOM_RIGHT.
          READ TABLE GT_BOTTOM_RIGHT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'AUN' 'VA03'
                                         GT_BOTTOM_RIGHT-VBELN_VL.

        WHEN  'MATNR'.
          CLEAR GT_BOTTOM_RIGHT.
          READ TABLE GT_BOTTOM_RIGHT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'MAT' 'MM03'
                                         GT_BOTTOM_RIGHT-MATNR.

        WHEN 'KUNNR'.
          CLEAR GT_BOTTOM_RIGHT.
          READ TABLE GT_BOTTOM_RIGHT INDEX P_ROW.
          CHECK SY-SUBRC EQ 0.

          PERFORM CALL_TRANSACTION USING 'KUN' 'XD03'
                                         GT_BOTTOM_RIGHT-KUNNR.

      ENDCASE.
  ENDCASE.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    P_ROW_ID    TYPE LVC_S_ROW
                             P_COLUMN_ID TYPE LVC_S_COL.
  DATA : LV_BONEM  LIKE KONA-BONEM.

ENDFORM.                    " HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_CONTAINER .

  CREATE OBJECT GC_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = GC_CONTAINER_NAME.

  CREATE OBJECT SPLITTER
    EXPORTING
      PARENT  = GC_CUSTOM_CONTAINER
      ROWS    = 2
      COLUMNS = 2.

  CALL METHOD SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 35.

  CALL METHOD SPLITTER->SET_COLUMN_WIDTH
    EXPORTING
      ID    = 1
      WIDTH = 40.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = CONTAINER_1.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = CONTAINER_2.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = CONTAINER_3.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 2
    RECEIVING
      CONTAINER = CONTAINER_4.

  CREATE OBJECT GC_ALV_GRID1
    EXPORTING
      I_PARENT      = CONTAINER_1
      I_APPL_EVENTS = 'X'.


  CREATE OBJECT GC_ALV_GRID2
    EXPORTING
      I_PARENT      = CONTAINER_2
      I_APPL_EVENTS = 'X'.

  CREATE OBJECT GC_ALV_GRID3
    EXPORTING
      I_PARENT      = CONTAINER_3
      I_APPL_EVENTS = 'X'.


  CREATE OBJECT GC_ALV_GRID4
    EXPORTING
      I_PARENT      = CONTAINER_4
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO1 CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  PS_LAYOUT-ZEBRA             = 'X'.
  PS_LAYOUT-CWIDTH_OPT        = ' '.
  PS_LAYOUT-SMALLTITLE        = 'X'.
  PS_LAYOUT-SEL_MODE          = 'A'.          "select multiple lines
*  gs_layout1-no_rowmark        = 'X'.
  PS_LAYOUT-NO_ROWINS          = 'X'.
  PS_LAYOUT-STYLEFNAME        = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME        = 'COLORTAB'.

  IF P_RAD1 EQ GC_X OR P_RAD2 EQ GC_X.
    PS_LAYOUT-GRID_TITLE      = '☞ 납품문서 헤더'.
  ELSE.
    PS_LAYOUT-GRID_TITLE      = '☞ 컨테이너 시뮬레이션  헤더'.
  ENDIF.

ENDFORM.                    " SET_GRID_LAYO1
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO2  CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  PS_LAYOUT-ZEBRA             = 'X'.
  PS_LAYOUT-CWIDTH_OPT        = ' '.
  PS_LAYOUT-SMALLTITLE        = 'X'.
  PS_LAYOUT-SEL_MODE          = 'A'.          "select multiple lines
  PS_LAYOUT-NO_ROWINS         = 'X'.
*  gs_layout1-no_rowmark        = 'X'.
*INFO_FNAME
*CTAB_FNAME
  PS_LAYOUT-STYLEFNAME        = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME        = 'COLORTAB'.
  PS_LAYOUT-GRID_TITLE        = '☞ 포장 정보(합계)'.

ENDFORM.                    " SET_GRID_LAYO2
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO3  CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  PS_LAYOUT-ZEBRA             = 'X'.
  PS_LAYOUT-CWIDTH_OPT        = ' '.
  PS_LAYOUT-SMALLTITLE        = 'X'.
  PS_LAYOUT-SEL_MODE          = 'A'.          "select multiple lines
  PS_LAYOUT-NO_ROWINS         = 'X'.
*  gs_layout1-no_rowmark        = 'X'.

  IF P_RAD1 EQ GC_X OR P_RAD2 EQ GC_X.
    PS_LAYOUT-GRID_TITLE      = '☞ 납품문서 아이템'.
  ELSE.
    PS_LAYOUT-GRID_TITLE      = '☞ 컨테이너 시뮬레이션  아이템'.
  ENDIF.

  PS_LAYOUT-STYLEFNAME        = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME        = 'COLORTAB'.

ENDFORM.                    " SET_GRID_LAYO3
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO4 CHANGING PS_LAYOUT TYPE LVC_S_LAYO..

  PS_LAYOUT-ZEBRA             = 'X'.
  PS_LAYOUT-CWIDTH_OPT        = ' '.
  PS_LAYOUT-SMALLTITLE        = 'X'.
  PS_LAYOUT-SEL_MODE          = 'A'.          "select multiple lines
  PS_LAYOUT-NO_ROWINS         = 'X'.
*  gs_layout1-no_rowmark        = 'X'.
  PS_LAYOUT-GRID_TITLE        = '☞ 포장 정보(디테일)'.
  PS_LAYOUT-STYLEFNAME        = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME        = 'COLORTAB'.

ENDFORM.                    " SET_GRID_LAYO4

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT1 TABLES PT_FIELDCAT TYPE LVC_T_FCAT .
*{ 기능개선 156428 - 추가
  DATA: LV_CHK.
  DATA: LV_CHK2.
*} 기능개선 156428 - 추가

*___FIELDNAME/CURR/UNIT/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT

*___계약정보(GRID1)
*  gv_itab = 'GT_KONA'.
  DATA: LS_CAT TYPE LVC_S_FCAT.

*{ 기능개선 156428 - 추가
  IF SY-TCODE = GC_TCODE2.
    CLEAR : LV_CHK.
  ELSE.
    LV_CHK = 'X'.
  ENDIF.
*} 기능개선 156428 - 추가

*{ 기능개선 178740 - 추가
*   IF GT_BOTTOM_LEFT-SPART NE '30'.
*     lv_chk2 = 'X'.
*   ELSEIF GT_BOTTOM_LEFT-SPART = '30'.
*     lv_chk2 = ' '.
*   ENDIF.
*{ 기능개선 178740 - 추가

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                 USING :

      'ICON'    ' '     ' '     'X' ' ' ' ' 'C100' 'X' '' ' ' 4
      '상태'      ''     ''    ' ' ''    '' ' ' ' ' ' ' 'GT_TOP_LEFT'.

  CASE GC_X.

    WHEN P_RAD1 OR P_RAD2.
      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

        'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
        '납품문서' 'VBELN' 'LIPS' ' ' '' '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'BZAREA'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' 'X' ' ' 4
        '사업장(거점)'     'BZAREA'     'ZLET0033'
        ' ' '' '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'WADAT'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '납품계획일'     'WADAT'     'LIKP'    ' ' '' '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'VGTYP'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 2
        '요청 유형'     'VGTYP'  'ZLET0917'    ' ' '' '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'LFDAT'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '도착요청일'     'WADAT'  'LIKP'    ' ' ''    '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'LFUHR'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '도착요청시간'     'MBUHR'   'VBEP'    ' ' ''
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'KUNNR'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '납품처'     'KUNNR'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'NAME1'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '납품처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'KUNAG'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '판매처'     'KUNAG'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'NAMAG'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '판매처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'POST_CODE1'     ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 6
        '우편번호'        '' ''          ' ' ' '    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'STREET'    ' '     ''     '' ' ' ' ' '' ' ' ' X' ' ' 20
        '주소'        '' ''          ' ' ' '    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'ROUTE'    ' '     ''     '' ' ' ' ' '' ' ' ' ' ' ' 8
        '운송경로'        'ROUTE' 'LIKP'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'ROUTE_TEXT'    ' '     ''     '' ' ' ' ' '' ' ' ' ' ' ' 10
        'CY명'        'ROUTE_TEXT' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'VSTEL'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 11
        '원 출하지점'     'VSTEL' 'LIKP'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'ORGSHP'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 15
        '실제 출하지점'     'VSTEL' 'LIKP'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'ADDSHP'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 15
        '추가 출하지점'     'VSTEL' 'LIKP'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'TRFLG'    ' '     ''     '' ' ' ' ' '' ' ' ' ' ' ' 4
        '경유여부'        'TRFLG' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'MIXLOD'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 12
        '혼적제한여부'        'MIXLOD' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'VHCTYP'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 8
        '차량톤수'        'SDABW' 'VTTK'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'VHCINEQ'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 8
        '톤수제한'        'VHCINEQ' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'VSART'    ' '     ''     '' ' ' ' ' '' ' ' 'X' ' '  8
        '출하유형'        'VSART' 'LIKP'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'VSBED'    ' '     ''     '' ' ' ' ' '' ' ' 'X' ' ' 8
        '출하조건'        'VSBED' 'LIKP'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'SHTYP'    ' '     ' '     '' ' ' ' ' '' ' ' '' ' '  8
        '선적유형'        'SHTYP' 'VTTK'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'BFART'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 10
        '서비스레벨'        'BFART' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'URGNT'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 6
        '긴급도'        'URGNT' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'INCO1'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 8
        '인도조건'        'INCO1' 'LIKP'          ' ' ' '
        '' ' ' ' ' '' 'GT_TOP_LEFT',

        'TDLNR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 10
        '운송사코드'      'TDLNR' 'VTTK'          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT',

        'EXTI1'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 12
        '차량번호'        '' ''          ' ' ' '    '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'EXTI2'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 12
        '기사명'        '' ''          ' ' ' '    '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'TPBEZ'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 20
        '기사연락처'        '' ''          ' ' ' '    '' ' ' ' ' LV_CHK
        'GT_TOP_LEFT',

        'GRTXT'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 20
        '출하요청 텍스트'        '' ''          ' ' ' '
        '' ' ' ' ' LV_CHK 'GT_TOP_LEFT'.

    WHEN P_RAD3 OR P_RAD4.

      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

        'SHSRQ'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
        '시뮬레이션 요청번호'     'SHSRQ'     'ZLET0917'    ' ' ''
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
        '판매오더'     'VBELN'     'LIPS'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'POSNR'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' ' ' ' ' 4
        '품목'        'POSNR' 'LIPS'          ' ' ' '    'X' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'WADAT'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '납품계획일'     'WADAT'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'VGTYP'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 2
        '요청 유형'     'VGTYP'     'ZLET0917'    ' ' ''
        '' ' ' ' ' '' 'GT_TOP_LEFT',

        'KUNNR'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '납품처'     'KUNNR'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'NAME1'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '납품처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'KUNAG'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '판매처'     'KUNAG'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'NAMAG'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '판매처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'CONTY'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 13
        '컨테이너 타입'     'CONTY'     'ZLET0403'    ' ' ''
        '' ' ' ' ' ' ' 'GT_TOP_LEFT',

        'CONSZ'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 13
        '컨테이너 규격'  'CONSZ'     'ZLET0403'    ' ' ''
        '' ' ' ' ' ' ' 'GT_TOP_LEFT'.

  ENDCASE.

  MOVE 'X' TO LS_CAT-F4AVAILABL.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING F4AVAILABL
                    WHERE FIELDNAME EQ 'VGTYP'.

  MOVE 'X' TO LS_CAT-F4AVAILABL.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING F4AVAILABL
                    WHERE FIELDNAME EQ 'URGNT'.

  MOVE 'X' TO LS_CAT-F4AVAILABL.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING F4AVAILABL
                    WHERE FIELDNAME EQ 'VHCINEQ'.


*  IF gt_bottom_left-spart NE '30'.
  MOVE 'X' TO LS_CAT-F4AVAILABL.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING F4AVAILABL
                    WHERE FIELDNAME EQ 'VHCTYP'.
*  ENDIF.

ENDFORM.                    " SET_GRID_FCAT1

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT2  TABLES PT_FIELDCAT TYPE LVC_T_FCAT .

  DATA: LS_CAT TYPE LVC_S_FCAT.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                 USING :

      'ICON'    ' '     ' '     'X' ' ' '' 'C100' 'X' '' ' ' 4
      '상태'      ''     ''    ' ' ''
      '' ' ' ' ' ' ' 'GT_TOP_RIGHT'.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '납품문서'     'VBELN'     'LIPS'    ' ' ''
            '' ' ' ' ' ' ' 'GT_TOP_RIGHT'.

    WHEN P_RAD3 OR P_RAD4.

      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '판매오더'     'VBELN'     'LIPS'    ' ' ''
            '' ' ' ' ' ' ' 'GT_TOP_RIGHT'.

  ENDCASE.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                   USING :

*     'DELIDN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' '  4
*     '순번'      'DELIDN'     'ZLET0917'    ' ' ' '    '' ' ' ' ' ' '
*     'GT_TOP_RIGHT',

        'PKTYP'    ' '     ''     '' ' ' ' ' '' ' ' '' ' '  11
        '포장재 유형'      'PKTYP' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT',

        'PKMATNR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 11
        '포장재 코드'      'PKMATNR' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT',

        'MENGE'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 11
        '포장재 수량'      'MENGE' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' 'X' 'GT_TOP_RIGHT',

        'WIDTH'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '폭'      'WIDTH' 'ZLET0917'          ' ' ' '    '' ' ' ' ' ' '
        'GT_TOP_RIGHT',

        'ZLENGTH'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '길이'      'ZLENGTH' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT',

        'HEIGHT'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '높이'      'HEIGHT' 'ZLET0917' ' ' ' '    '' ' ' ' ' ' '
        'GT_TOP_RIGHT',

        'ZMEINS'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 4
        '단위'      'ZMEINS' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT',

        'PKWEI'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 11
        '포장재 무게' 'PKWEI' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT',

        'PMEINS'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 5
        '단위'      'PMEINS' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_TOP_RIGHT'.

  READ TABLE PT_FIELDCAT WITH KEY FIELDNAME = 'MENGE'
                                   INTO LS_CAT.

  CHECK SY-SUBRC EQ 0.

  MOVE 0 TO LS_CAT-DECIMALS_O.
  MODIFY PT_FIELDCAT INDEX SY-TABIX FROM LS_CAT
                     TRANSPORTING DECIMALS_O.

  MOVE 'X' TO LS_CAT-NO_SIGN.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING NO_SIGN
                    WHERE NO_SIGN IS INITIAL.

ENDFORM.                    " SET_GRID_FCAT2
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT3 TABLES PT_FIELDCAT TYPE LVC_T_FCAT .

*___FIELDNAME/CURR/UNIT/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                 USING :

      'ICON'    ' '     ' '     'X' ' ' ' ' 'C100' 'X' '' ' ' 4
      '상태'      ''     ''    ' ' ''
      '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '납품문서'     'VBELN'     'LIPS'    ' ' ''
            '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

    WHEN P_RAD3 OR P_RAD4.

      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '판매오더'     'VBELN'     'LIPS'    ' ' ''
            '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

  ENDCASE.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                   USING :

        'POSNR'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' ' ' ' ' 4
        '품목'        'POSNR' 'LIPS'          ' ' ' '
        'X' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'MATNR'    ' '     ' '     ' ' ' ' ' ' '' 'X' '' ' ' 12
        '자재코드'        'MATNR' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'ARKTX'    ' '     ''     ' ' ' ' ' ' '' ' ' '' ' ' 12
        '품명'            'ARKTX' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'SPART'    ' '     ''     ' ' ' ' ' ' '' ' ' '' ' ' 6
        '제품군' 'SPART' 'LIPS'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_LEFT',

        'WERKS'    ' '     ' '     ' ' ' ' ' ' 'C100' '' '' ' ' 6
        '플랜트'        'WERKS' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'LENGTH'    ''     ''     ' ' ' ' ' ' '' ' ' '' ' ' 4
        '조장 '        'LENGTH' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'FACTOR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 6
        '조장수'        'FACTOR' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'LFIMG'    ' '     'VRKME'     '' ' ' ' ' '' ' ' '' ' ' 10
        '납품 수량'        'LFIMG' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'VRKME'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 4
        '단위'        'VRKME' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

  IF P_RAD1 EQ GC_X OR P_RAD2 EQ GC_X.

    PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                     USING :

          'VBELN_VL'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 12
          '판매 오더'        'VBELN' 'VBAK'          ' ' ' '
          '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

          'POSNR_VL'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 12
          '판매오더 품목'        'POSNR' 'VBAP'          ' ' ' '
          '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

  ENDIF.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                   USING :

        'KUNNR'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 12
        '판매처'        'KUNNR' 'VBAK'          ' ' ' '    '' ' ' ' ' ''
        'GT_BOTTOM_LEFT',

        'NAMAG'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '판매처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'KUNWE'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 10
        '납품처'     'KUNNR'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'NAMWE'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 20
        '납품처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_TOP_LEFT',

        'FLTLVL'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 9
        '적재 단수'        'FLTLVL' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' 'X' 'GT_BOTTOM_LEFT',

        'NTGEW'    ' '     'GEWEI'     ' ' ' ' ' ' '' '' 'X' ' ' 6
        '중량'        'NTGEW' 'MARA'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_LEFT',

        'GEWEI'    ' '     ''     ' ' ' ' ' ' '' '' 'X' ' ' 8
        '중량단위'        'GEWEI' 'MARA'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT',

        'NTGEW_LF' ' '    'GEWEI_LF' ' ' ' ' ' ' '' '' 'X' ' ' 6
        '납품중량'    'NTGEW' 'LIPS'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_LEFT',

        'GEWEI_LF'    ' '     ''     ' ' ' ' ' ' '' '' 'X' ' ' 8
        '납품중량단위'        'GEWEI' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_LEFT'.

*
*      'TKNUM' ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 10
*      '선적문서'        'VBELN' 'LIPS'          ' ' ' '
*    '' ' ' ' ' ' '
*'GT_TOP_LEFT'.


ENDFORM.                    " SET_GRID_FCAT3
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT4 TABLES PT_FIELDCAT TYPE LVC_T_FCAT .

  DATA: LS_CAT TYPE LVC_S_FCAT.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                 USING :

      'ICON'    ' '     ' '     'X' ' ' ' ' 'C100' 'X' '' ' ' 4
      '상태'      ''     ''    ' ' ''    '' ' ' ' ' ' '
      'GT_BOTTOM_RIGHT'.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '납품문서'     'VBELN'     'LIPS'    ' ' ''
            ' ' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT'.

    WHEN P_RAD3 OR P_RAD4.

      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

            'VBELN'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 10
            '판매오더'     'VBELN'     'LIPS'    ' ' ''
            '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT'.

  ENDCASE.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                   USING :

        'POSNR'    ' '     ' '     ' ' ' ' ' ' 'C100' 'X' '' ' ' 4
        '품목'     'POSNR'     'LIPS'    ' ' ''    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'DELIDN'    ' '     ' '     '' ' ' ' ' 'C100' 'X' '' ' '  4
        '순번'      'DELIDN'     'ZLET0917'    ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'PUSH'    ' '     ' '     'X' ' ' ' ' 'C100' 'X' '' ' '  4
        '수정'      ''     ''    ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'PKTYP'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 11
        '포장재 유형'      'PKTYP' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' 'X' 'GT_BOTTOM_RIGHT',

        'PKMATNR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 12
        '포장재 코드'      'PKMATNR' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' 'X' 'GT_BOTTOM_RIGHT',

        'DMMATNR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 10
        '드럼 기호'      'PKMATNR' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'SPART'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 6
        '제품군'      'SPART' 'LIPS'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'WIDTH'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '폭'      'WIDTH' 'ZLET0917'          ' ' ' '    '' ' ' ' ' ''
        'GT_BOTTOM_RIGHT',

        'ZLENGTH'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '길이'      'ZLENGTH' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' '' 'GT_BOTTOM_RIGHT',

        'HEIGHT'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 7
        '높이'      'HEIGHT' 'ZLET0917' ' ' ' '    '' ' ' ' ' ''
        'GT_BOTTOM_RIGHT',

        'PKWEI'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 11
        '포장재 무게' 'PKWEI' 'ZLET0917'          ' ' ' '  '' ' ' ' ' ''
        'GT_BOTTOM_RIGHT',

        'PMEINS'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 5
        '단위' 'MEINS' 'MARA'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'INMENGE'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 12
        '포장재 최초수량'      'MENGE' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' '' 'GT_BOTTOM_RIGHT',

        'MENGE'    ' '     ''     '' ' ' ' ' '' ' ' '' 'X' 11
        '포장재 수량'      'MENGE' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' 'X' 'GT_BOTTOM_RIGHT',

        'ZMEINS'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 4
        '단위'      'MEINS' 'MARA'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'VBELN_VL'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 4
        '판매 오더'        'VBELN' 'VBAK'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'POSNR_VL'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 4
        '판매오더 품목'        'POSNR' 'VBAP'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'KUNNR'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 5
        '납품처'     'KUNNR'     'LIKP'    ' ' ''    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'NAME1'    ' '     ' '     ' ' ' ' ' ' '' '' '' ' ' 5
        '납품처명'  'NAME1'     'KNA1'    ' ' ''    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'MATNR'    ' '     ' '     ' ' ' ' ' ' '' 'X' '' ' ' 4
        '자재코드'        'MATNR' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'ARKTX'    ' '     ''     ' ' ' ' ' ' '' ' ' '' ' ' 4
        '품명'            'ARKTX' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'CODE_POINT'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 5
        '' '' ''          ' ' ' '    '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'KEY_TEXT'    ' '     ''     '' ' ' ' ' '' ' ' '' '' 10
        'Path' '' ''          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT'.

**** 필드카탈로그 필드 추가 20170907 BY 서동우
  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      PERFORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT
                                       USING :

        'LENGTH'    ''     ''     ' ' ' ' ' ' '' ' ' '' ' ' 4
        '조장 '        'LENGTH' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'FACTOR'    ' '     ''     '' ' ' ' ' '' ' ' '' ' ' 6
        '조장수'        'FACTOR' 'ZLET0917'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'NTGEW' ' '    'GEWEI' ' ' ' ' ' ' '' '' '' ' ' 6
        '중량'    'NTGEW' 'MARA'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'GEWEI'    ' '     ''     ' ' ' ' ' ' '' '' '' ' ' 8
        '단위'        'GEWEI' 'MARA'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT',

        'NTGEW_LF' ' '    'GEWEI_LF' ' ' ' ' ' ' '' '' '' ' ' 6
        '총중량'    'NTGEW' 'LIPS'          ' ' ' '    '' ' ' ' ' ' '
        'GT_BOTTOM_RIGHT',

        'GEWEI_LF'    ' '     ''     ' ' ' ' ' ' '' '' '' ' ' 8
        '단위'        'GEWEI' 'LIPS'          ' ' ' '
        '' ' ' ' ' ' ' 'GT_BOTTOM_RIGHT'.
  ENDCASE.
**** 필드카탈로그 필드 추가 20170907 BY 서동우

  READ TABLE PT_FIELDCAT WITH KEY FIELDNAME = 'MENGE'
                                   INTO LS_CAT.

  CHECK SY-SUBRC EQ 0.

  MOVE 0 TO LS_CAT-DECIMALS_O.
  MODIFY PT_FIELDCAT INDEX SY-TABIX FROM LS_CAT
                     TRANSPORTING DECIMALS_O.

  MOVE 'X' TO LS_CAT-NO_SIGN.
  MODIFY PT_FIELDCAT INDEX SY-TABIX FROM LS_CAT
                     TRANSPORTING NO_SIGN.

  MOVE ' ' TO LS_CAT-F4AVAILABL.
  MODIFY PT_FIELDCAT FROM LS_CAT TRANSPORTING F4AVAILABL
                    WHERE FIELDNAME EQ 'VHCTYP'.

ENDFORM.                    " SET_GRID_FCAT4
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                             USING PV_FNAME
                                   PV_CURK
                                   PV_UNIT
                                   PV_ICON
                                   PV_CHECK
                                   PV_JUST
                                   PV_EMPHA
                                   PV_FIX
                                   PV_NOOUT
                                   PV_NOZERO
                                   PV_LENGTH
                                   PV_TEXT
                                   PV_REFF
                                   PV_REFT
                                   PV_TECH
                                   PV_TYPE
                                   PV_NOSUM
                                   PV_DOSUM
                                   PV_HOTSPOT
                                   PV_EDIT
                                   PV_TAB.

  DATA : LS_FIELDCAT          TYPE LVC_S_FCAT.

  CLEAR : LS_FIELDCAT.

  GV_POS = GV_POS + 1.

  LS_FIELDCAT-COL_POS        = GV_POS.
  LS_FIELDCAT-FIELDNAME      = PV_FNAME.
  LS_FIELDCAT-CFIELDNAME     = PV_CURK.
  LS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  LS_FIELDCAT-ICON           = PV_ICON.
  LS_FIELDCAT-CHECKBOX       = PV_CHECK.
  LS_FIELDCAT-JUST           = PV_JUST.
  LS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  LS_FIELDCAT-FIX_COLUMN     = PV_FIX.
*  LS_FIELDCAT-KEY            = PV_FIX.
  LS_FIELDCAT-NO_OUT         = PV_NOOUT.
  LS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  LS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  LS_FIELDCAT-COLTEXT        = PV_TEXT.
  LS_FIELDCAT-SCRTEXT_S      = PV_TEXT.
  LS_FIELDCAT-SCRTEXT_M      = PV_TEXT.
  LS_FIELDCAT-SCRTEXT_L      = PV_TEXT.
  LS_FIELDCAT-REF_FIELD      = PV_REFF.
  LS_FIELDCAT-REF_TABLE      = PV_REFT.
  LS_FIELDCAT-TECH           = PV_TECH.
  LS_FIELDCAT-DATATYPE       = PV_TYPE.
  LS_FIELDCAT-NO_SUM         = PV_NOSUM.
  LS_FIELDCAT-DO_SUM         = PV_DOSUM.
  LS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  LS_FIELDCAT-EDIT           = PV_EDIT.
  LS_FIELDCAT-TABNAME        = PV_TAB.

  APPEND LS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_TWO CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_ASC.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER1 .


  CALL METHOD GC_ALV_GRID1->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD GC_ALV_GRID2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD GC_ALV_GRID3->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD GC_ALV_GRID4->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD GC_ALV_GRID1->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GC_ALV_GRID2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GC_ALV_GRID3->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GC_ALV_GRID4->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.


*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER1.
  CREATE OBJECT GC_EVENT_HANDLER2.
  CREATE OBJECT GC_EVENT_HANDLER3.
  CREATE OBJECT GC_EVENT_HANDLER4.

  SET HANDLER GC_EVENT_HANDLER1->HANDLE_TOOLBAR_1
  FOR GC_ALV_GRID1.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_USER_COMMAND
  FOR GC_ALV_GRID1.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_HOTSPOT_CLICK
  FOR GC_ALV_GRID1.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK1
  FOR GC_ALV_GRID1.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED
  FOR GC_ALV_GRID1.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED
  FOR GC_ALV_GRID1.
*  SET HANDLER gc_event_handler1->handle_top_of_page
*FOR gc_alv_grid1.

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_TOOLBAR_2
  FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DATA_CHANGED
  FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK1
  FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_USER_COMMAND
  FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED
  FOR GC_ALV_GRID2.
*  SET HANDLER gc_event_handler1->handle_top_of_page
* FOR gc_alv_grid2.

  SET HANDLER GC_EVENT_HANDLER3->HANDLE_TOOLBAR_3
  FOR GC_ALV_GRID3.
  SET HANDLER GC_EVENT_HANDLER3->HANDLE_DATA_CHANGED
  FOR GC_ALV_GRID3.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK1
  FOR GC_ALV_GRID3.
  SET HANDLER GC_EVENT_HANDLER3->HANDLE_USER_COMMAND
  FOR GC_ALV_GRID3.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED
  FOR GC_ALV_GRID3.
*  SET HANDLER gc_event_handler1->handle_top_of_page
* FOR gc_alv_grid3.

  SET HANDLER GC_EVENT_HANDLER4->HANDLE_TOOLBAR_4
  FOR GC_ALV_GRID4.
  SET HANDLER GC_EVENT_HANDLER4->HANDLE_BUTTON_CLICK
  FOR GC_ALV_GRID4.
  SET HANDLER GC_EVENT_HANDLER4->HANDLE_DATA_CHANGED
  FOR GC_ALV_GRID4.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK1
  FOR GC_ALV_GRID4.
  SET HANDLER GC_EVENT_HANDLER4->HANDLE_USER_COMMAND
  FOR GC_ALV_GRID4.
  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED
  FOR GC_ALV_GRID4.
*  SET HANDLER gc_event_handler1->handle_top_of_page
* FOR gc_alv_grid4.

ENDFORM.                    " EVENT_HANDLER_REGISTER1
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY1
                              USING P_GRID TYPE REF TO CL_GUI_ALV_GRID
                                     P_HANDLE TYPE NUM4
                                     P_LAYOUT TYPE LVC_S_LAYO
                                     PT_FIELDCAT1 TYPE STANDARD TABLE
                                     PT_TAB TYPE STANDARD TABLE
                                     PT_EXCLUDE TYPE UI_FUNCTIONS.


  GS_VARIANT-HANDLE = P_HANDLE.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD P_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = P_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = PT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = PT_FIELDCAT1[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = PT_TAB[].

*  gs_variant-handle = '0003'.
*  gs_variant-report = sy-repid.
*
*  CALL METHOD gc_alv_grid3->set_table_for_first_display
*    EXPORTING
*      is_variant           = gs_variant
*      is_layout            = gs_layout3
*      i_save               = 'A'
*      it_toolbar_excluding = gt_exclude
*    CHANGING
*      it_fieldcatalog      = gt_fieldcat3[]
**      IT_SORT              = GT_SORT[]
*      it_outtab            = gt_mypa[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY1
*&---------------------------------------------------------------------*
*&      Form  INIT_CONTAINER4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_CONTAINER2 .

  IF NOT GC_ALV_GRID2 IS INITIAL.
    CALL METHOD GC_ALV_GRID2->FREE.
    FREE GC_ALV_GRID2.
  ENDIF.

ENDFORM.                    " INIT_CONTAINER2
*&---------------------------------------------------------------------*
*&      Form  INIT_CONTAINER4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_CONTAINER4 .

  IF NOT GC_ALV_GRID4 IS INITIAL.
    CALL METHOD GC_ALV_GRID4->FREE.
    FREE GC_ALV_GRID4.
  ENDIF.

ENDFORM.                    " INIT_CONTAINER4
*&---------------------------------------------------------------------*
*&      Form  GET_MAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MAIN_DATA CHANGING PV_ERROR.
  DATA: LV_DEL.

  REFRESH: GT_LIPS,  GT_LIKP,   GT_LIPS,  GT_VTTK,  GT_VTTP,  GT_VBAK,
  GT_VBAP.

  DATA: LT_LIPS  LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_LIKP  LIKE LIKP OCCURS 0 WITH HEADER LINE,
        LT_VTTP  LIKE VTTP OCCURS 0 WITH HEADER LINE,
        LT_VTTK  LIKE VTTK OCCURS 0 WITH HEADER LINE,
        LT_VBAK  LIKE VBAK OCCURS 0 WITH HEADER LINE,
        LT_VBAP  LIKE VBAP OCCURS 0 WITH HEADER LINE,
        LT_TLIKP LIKE LIKP OCCURS 0 WITH HEADER LINE.

  " S/O D/N 정보 존재 유무 체크
  CLEAR PV_ERROR.
  PERFORM READ_SALES_DOC_DELIVERY_DOC TABLES LT_TLIKP USING
  'S/O D/N 정보 체크' 5 CHANGING PV_ERROR.

  SORT LT_TLIKP BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_TLIKP COMPARING VBELN.

  " Read D/N
  CLEAR PV_ERROR.
  PERFORM READ_DELIVERY_DOCUMENT TABLES LT_TLIKP
  USING 'D/N 정보 발췌' 10 CHANGING PV_ERROR.

  " Read Zlet0917
  CLEAR PV_ERROR.
  PERFORM READ_ZLET0917_ZLET0903 USING 'TMS  정보 발췌' 15
  CHANGING PV_ERROR.

  " Read Shipment
  CLEAR PV_ERROR.
  PERFORM READ_SHIPMENT TABLES GT_LIPS USING ' 선적 정보 발췌' 20
  CHANGING PV_ERROR.

  " Read S/O
  CLEAR PV_ERROR.
  PERFORM READ_SALES_DOCUMENT TABLES GT_LIPS USING 'S/O 정보 발췌' 25
  CHANGING PV_ERROR.

  "  고객정보, 우편번호 발췌
  CLEAR PV_ERROR.
  PERFORM READ_CUSTOMER_POSTING TABLES GT_LIKP USING
  '고객정보, 우편번호 발췌' 30 CHANGING PV_ERROR.

  " Read Zlet0402, zlet0400 톤수제한, 혼적제한
  PERFORM GET_0402_0400 USING '톤수제한' 32 CHANGING PV_ERROR.

  "  데이타 구성
  IF P_RAD1 EQ GC_X OR P_RAD2 EQ GC_X.
    PERFORM CREATE_GT_TOP_RIGHT
    USING '데이타 구성' 35 CHANGING PV_ERROR.
    ""컨테이너 시뮬레이션
  ELSEIF P_RAD3 EQ GC_X OR P_RAD4 EQ GC_X.
    PERFORM CREATE_GT_TOP_RIGHT_TWO  USING '데이타 구성' 35
    CHANGING PV_ERROR.
  ENDIF.

* 3 SCREEN 구성
  PERFORM CREATE_3_SCREEN.

  CASE GC_X.
      " 일반 출하, 선적 시뮬레이션
    WHEN P_RAD1 OR P_RAD3.
*{ 기능개선 163582 - 추가
      IF SY-TCODE <> GC_TCODE2.
*} 기능개선 163582 - 추가
        DELETE GT_TOP_LEFT    WHERE ICON EQ ICON_TRANSFER.
        DELETE GT_BOTTOM_LEFT WHERE ICON EQ ICON_TRANSFER.
      ENDIF.

      IF P_RAD1 = 'X'.
*___TMS 미전송인 경우 선적문서가 존재하는 납품문서 제외
*{ 기능개선 156428 - 추가
        IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
          LOOP AT GT_TOP_LEFT.
            CLEAR : LV_DEL.

            LOOP AT GT_VTTP WHERE VBELN = GT_TOP_LEFT-VBELN.
              READ TABLE GT_VTTK WITH KEY TKNUM = GT_VTTP-TKNUM.
              IF SY-SUBRC = 0 AND GT_VTTK-SHTYP <> 'Z103'.
                DELETE GT_BOTTOM_LEFT WHERE VBELN = GT_TOP_LEFT-VBELN.
                DELETE GT_TOP_LEFT.

                LV_DEL = 'X'.
                EXIT.
              ENDIF.
            ENDLOOP.

            IF LV_DEL = 'X'.
              CONTINUE.
            ENDIF.

*___우편번호가 입력되지 않았거나 우편번호와 운송경로가
*   일치하지 않는 경우 빨간신호등
            PERFORM CHECK_TRANS_ROUTE.

            MODIFY GT_TOP_LEFT.
          ENDLOOP.
        ENDIF.
      ENDIF.

      " 전송완료 조회
    WHEN P_RAD2 OR P_RAD4.
      DELETE GT_TOP_LEFT
      WHERE NOT
      ( ICON EQ ICON_TRANSFER OR ICON EQ ICON_WF_WORKITEM_WAITING ).
      DELETE GT_BOTTOM_LEFT
      WHERE NOT
      ( ICON EQ ICON_TRANSFER OR ICON EQ ICON_WF_WORKITEM_WAITING ).

  ENDCASE.

  " 전송완료인 경우 Celltab 초기화
  IF P_RAD3 EQ GC_X OR P_RAD4 EQ GC_X.
    LOOP AT GT_TOP_LEFT.
      REFRESH GT_TOP_LEFT-CELLTAB.
      MODIFY GT_TOP_LEFT.
    ENDLOOP.
  ENDIF.

  "  저장만 조회
  IF P_CHK1 EQ GC_X.
    DELETE GT_TOP_LEFT WHERE NOT ICON EQ ICON_GREEN_LIGHT.
  ENDIF.

ENDFORM.                    " GET_MAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMER_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CUSTOMER_NAME  USING    P_KUNNR
                                 P_NAME1.

  CLEAR : P_NAME1.

  CHECK P_KUNNR IS NOT INITIAL.

  READ TABLE GT_KNA1 WITH KEY KUNNR = P_KUNNR
                              BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_KNA1.

    SELECT SINGLE KUNNR
                  NAME1
      INTO GT_KNA1
      FROM KNA1
     WHERE KUNNR = P_KUNNR.

    IF SY-SUBRC = 0.
      APPEND GT_KNA1.

      SORT GT_KNA1 BY KUNNR.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    P_NAME1 = GT_KNA1-NAME1.
  ENDIF.

ENDFORM.                    " GET_CUSTOMER_NAME
*&---------------------------------------------------------------------*
*&      Form  GET_KUNWE_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_KUNWE_NAME  USING    P_VBELN
                              P_NAME1.

  CLEAR : P_NAME1.

  CHECK P_VBELN IS NOT INITIAL.

  READ TABLE GT_ADRC WITH KEY VBELN = P_VBELN
                              BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_ADRC.

    SELECT SINGLE A~VBELN
                  B~NAME1
      INTO GT_ADRC
      FROM VBPA AS A
     INNER JOIN ADRC AS B
        ON A~ADRNR = B~ADDRNUMBER
     WHERE A~VBELN = P_VBELN
       AND A~PARVW = 'WE'
       AND B~DATE_FROM  <= SY-DATLO
       AND B~DATE_TO    >= SY-DATLO.

    IF SY-SUBRC = 0.
      APPEND GT_ADRC.

      SORT GT_ADRC BY VBELN.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    P_NAME1 = GT_ADRC-NAME1.
  ENDIF.

ENDFORM.                    " get_kunwe_name
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_ALPHA_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_ALPHA_CODE  USING    P_CODE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_CODE
    IMPORTING
      OUTPUT = P_CODE.

ENDFORM.                    " CONVERSION_ALPHA_CODE
*&---------------------------------------------------------------------*
*&      Form  MOVE_NUM_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MOVE_NUM_TO_CHAR  USING    P_NUMBER
                                P_CHAR
                                P_WAERS.

  WRITE : P_NUMBER TO P_CHAR CURRENCY P_WAERS
                             NO-GROUPING
                             LEFT-JUSTIFIED.

  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      VALUE = P_CHAR.

ENDFORM.                    " MOVE_NUM_TO_CHAR
*&---------------------------------------------------------------------*
*&      Form  SEND_SALES_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_SALES_DETAIL USING P_GRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA: LT_ROWS    TYPE LVC_T_ROW,
        LS_ROWS    TYPE LVC_S_ROW,
        LT_E1CUVAL TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LV_VBELN   TYPE LIPS-VBELN.

  DATA: ET_RETURN  TYPE BAPIRET2_T.

  SORT GT_0917 BY VBELN POSNR DELIDN.

  PERFORM GET_SELECT_ROW USING P_GRID CHANGING LT_ROWS[].

  CLEAR GV_ERROR.

  REFRESH: GT_TOP_RIGHT, GT_BOTTOM_LEFT, GT_BOTTOM_RIGHT.
  " 선택한 라인 구성
  PERFORM LT_ROWS USING LT_ROWS '선택한 라인이 없습니다'
  CHANGING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.
    IF SY-SUBRC = 0 AND GT_TOP_LEFT-ICON = ICON_RED_LIGHT.
      MESSAGE I004 DISPLAY LIKE 'E'
         WITH '유효하지 않은 우편번호 또는 운송지역과'
              '일치하지 않는 납품문서가 선택되었습니다.'
              '확인하십시오.'.
      RETURN.
    ENDIF.
  ENDLOOP.

  CASE GC_X.
      " 일발 출하 TMS , 일반 출하 TMS 완료 조회
    WHEN P_RAD1 OR P_RAD2.
      LOOP AT GT_TOP_LEFT.
        IF GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
          MOVE ICON_LIGHT_OUT TO GT_TOP_LEFT-ICON.
        ENDIF.

        CLEAR GT_0917.
        SELECT SINGLE VBELN
           INTO LV_VBELN
          FROM ZLET0917
        WHERE VBELN = GT_TOP_LEFT-VBELN
*             AND xloek EQ ''
          "  납품분할 되지 않은 삭제는 보여준다.
             AND VBELN_VN EQ ''.

*{ 기능개선 159419 - 변경
*        IF sy-subrc EQ 0.
        IF SY-SUBRC EQ 0 AND GT_TOP_LEFT-ICON <> ICON_RED_LIGHT AND
           SY-TCODE <> GC_TCODE2.
*} 기능개선 159419 - 변경
          MOVE ICON_GREEN_LIGHT TO GT_TOP_LEFT-ICON.
        ENDIF.

        PERFORM CREATE_ICON_0903 USING GT_TOP_LEFT-VBELN ' '
        CHANGING GT_TOP_LEFT-ICON.

        MODIFY GT_TOP_LEFT TRANSPORTING ICON.

      ENDLOOP.

    WHEN P_RAD3 OR P_RAD4.
      " 선적 시뮬레이션, 선적 시뮬레이션 전송 조회
      LOOP AT GT_TOP_LEFT.
        IF GT_TOP_LEFT-ICON <> ICON_RED_LIGHT.
          MOVE ICON_LIGHT_OUT TO GT_TOP_LEFT-ICON.
        ENDIF.

        CLEAR GT_0917.
        SELECT SINGLE VBELN
           INTO LV_VBELN
          FROM ZLET0917
        WHERE VBELN  EQ GT_TOP_LEFT-VBELN
             AND POSNR EQ GT_TOP_LEFT-POSNR
*             AND xloek  EQ ''
          "  납품분할 되지 않은 삭제는 보여준다.
             AND VBELN_VN EQ ''.

        IF SY-SUBRC EQ 0.
          MOVE ICON_GREEN_LIGHT TO GT_TOP_LEFT-ICON.
        ENDIF.

        PERFORM CREATE_ICON_0903_TWO
        USING GT_TOP_LEFT-VBELN GT_TOP_LEFT-POSNR ' '
        CHANGING GT_TOP_LEFT-ICON.

        MODIFY GT_TOP_LEFT TRANSPORTING ICON.

      ENDLOOP.

  ENDCASE.

  "  1 Screen 의 선택한 라인 구성
  PERFORM SELECT_ROWS TABLES LT_LIPS USING LT_ROWS.

  "  정렬

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      SORT LT_LIPS BY VBELN.
      DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN.

    WHEN P_RAD3 OR P_RAD4.
      SORT LT_LIPS BY VBELN POSNR.
      DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN POSNR.
  ENDCASE.

  "  저장된 데이타(ZLET0917)를 먼저 구성한다.
*{ 기능개선 167496 - 추가
*___포장재 표시율 검증용 T-Code인 경우 저장된 데이터를 조회하지 않는다.
  IF SY-TCODE <> GC_TCODE2.
*} 기능개선 167496 - 추가
    CLEAR GV_ERROR.
    PERFORM GET_SAVE_AND_TRANS_LET0917 TABLES LT_LIPS USING LT_ROWS
    CHANGING GV_ERROR.
  ENDIF.

  "  저장되지 않은  d/n 반영(ZLET0917 저장된 것을 먼저 반영하고 크로스
  " 체크해서 LIPS를 반영한다.)
  "  반영할 테이블이 많아서 파라메트로 선언 안함.
  " 2,4번 스크린 구성
  PERFORM CROSS_CHECK_DATA_2_4_SCREEN USING LT_ROWS CHANGING GV_ERROR.

  "  저장되지 않은  d/n 반영(ZLET0917 저장된 것을 먼저 반영하고 크로스
  " 체크해서 LIPS를 반영한다.)
  "  반영할 테이블이 많아서 파라메트로 선언 안함.
  " 3번 스크린 구성
  PERFORM CROSS_CHECK_DATA_AFTER_CONF USING LT_ROWS CHANGING GV_ERROR.

  "  2번 스크린 구성
  PERFORM DEC_INTEGER_QUANTITY_REFLECT CHANGING GV_ERROR.

*{ 기능개선 157325 - 변경
  LOOP AT GT_BOTTOM_LEFT WHERE FLTLVL IS INITIAL.
    IF GT_BOTTOM_LEFT-SPART = '22'.
      GT_BOTTOM_LEFT-FLTLVL = 10.
    ELSEIF GT_BOTTOM_LEFT-SPART = '10'.
      IF GT_TOP_LEFT-SHTYP = 'Z101'.
        GT_BOTTOM_LEFT-FLTLVL = 2.
      ELSE.
        GT_BOTTOM_LEFT-FLTLVL = 1.
      ENDIF.
    ELSE.
      GT_BOTTOM_LEFT-FLTLVL = 1.
    ENDIF.

    MODIFY GT_BOTTOM_LEFT.
  ENDLOOP.

*  MOVE 1 TO gt_bottom_left-fltlvl.
*  MODIFY gt_bottom_left TRANSPORTING fltlvl
*   WHERE fltlvl IS INITIAL.
*} 기능개선 157325 - 변경

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.

      SORT GT_TOP_LEFT BY VBELN POSNR.
      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
      SORT GT_TOP_RIGHT BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
    WHEN P_RAD3 OR P_RAD4.
      SORT GT_TOP_LEFT BY SHSRQ.
      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
      SORT GT_TOP_RIGHT BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
  ENDCASE.

  CLEAR GV_ERROR.

ENDFORM.                    " SEND_SALES_DETAIL

*&---------------------------------------------------------------------*
*&      Form  LT_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      -->P_GV_SUBRC  text
*      -->P_4155   text
*----------------------------------------------------------------------*
FORM LT_ROWS  USING  PT_ROWS TYPE LVC_T_ROW
                                    PV_TEXT
                  CHANGING PV_SUBRC.

  IF PT_ROWS[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E' WITH PV_TEXT.
    MOVE 'X' TO PV_SUBRC.
    RETURN.
  ENDIF.

ENDFORM.                    " LT_ROWS
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_ALV_GRID1  text
*----------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PV_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL  TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD PV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = LS_SCROLL.     "화면 라인 Refresh

ENDFORM.                    " REFRESH_GRID
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*      -->P_E_ONF4  text
*      -->P_E_UCOMM  text
*      -->P_SENDER  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED USING DATA_CHANGED
TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                        E_ONF4 TYPE CHAR1
                                        E_COMM
                                        P_SENDER.

  FIELD-SYMBOLS <FS>.

  DATA: LS_MOD_CELLS    TYPE LVC_S_MODI.
  DATA: LT_MOD_CELLS    TYPE LVC_T_MODI.
  DATA: LV_SUB          TYPE P DECIMALS 3.
  DATA: LV_SUB2         TYPE P DECIMALS 3,
        LS_BOTTOM_RIGHT LIKE GT_BOTTOM_RIGHT,
        LV_ICON         TYPE ICON_D,
        LV_SPART        TYPE SPART,
        LV_PKTYP        TYPE ZLET0917-PKTYP.

  DATA: LV_CHAR1(20).
  DATA: LV_CHAR2(20).
  DATA: LV_CHAR3(20).
  DATA: LV_CHAR4(20).
  DATA: LV_INT         TYPE I,
        LV_DEC         TYPE P DECIMALS 3,
        LV_ICON_STATUS TYPE ICON_D,
        LV_VALUE       TYPE LVC_STYLE,
        LV_P           TYPE P.

  DATA: LV_PKMATNR TYPE ZLET0917-PKMATNR, "  포장재 자재코드
        LV_WIDTH   TYPE ZLET0917-WIDTH, "   폭
        LV_ZLENGTH TYPE ZLET0917-ZLENGTH, "   길이
        LV_HEIGHT  TYPE ZLET0917-HEIGHT, "  높이
        LV_PKWEI   TYPE ZLET0917-PKWEI. " 포장재 무게

*  DATA: LV_WERKS     LIKE T001L-WERKS,
*        LV_LGORT     LIKE T001L-LGORT.
*
*  CALL METHOD RR_DATA_CHANGED->REFRESH_PROTOCOL.
*LOOP AT DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
  REFRESH GT_DELTA_CELLS.

  CLEAR GV_ERROR.

  MOVE DATA_CHANGED->MT_GOOD_CELLS[] TO LT_MOD_CELLS[].

  " handle_data_changed_finished 에 발생한 ICON. 변경은 삭제한다.
  DELETE LT_MOD_CELLS WHERE FIELDNAME EQ 'ICON'.

  LOOP AT LT_MOD_CELLS INTO LS_MOD_CELLS.

    CHECK LS_MOD_CELLS-ERROR IS INITIAL.

    CLEAR: LV_ICON_STATUS.

    IF P_SENDER EQ GC_ALV_GRID4.
      PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                   'PUSH' LV_ICON_STATUS.
    ENDIF.

    CASE LS_MOD_CELLS-FIELDNAME.
        " 선적 유형
      WHEN 'SHTYP'.

        CASE LS_MOD_CELLS-VALUE.
          WHEN 'Z003'.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP' 'S'.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP'
                                     CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'VHCTYP'  ' '.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'VHCINEQ' ' '.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'EXTI1' '00가0000'.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'EXTI2' '택배기사'.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'TPBEZ' '010-000-0000'.
          WHEN 'Z004' OR 'Z102'.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP' 'S'.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP'
                                     CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'EXTI2'  ''.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'TPBEZ'  ''.
          WHEN OTHERS.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP' 'C'.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'VGTYP'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'EXTI2'  ''.
            PERFORM MODIFY_CELL  USING DATA_CHANGED LS_MOD_CELLS
                                       'TPBEZ'  ''.
        ENDCASE.

        " document Type
      WHEN 'VGTYP'.
        CASE GC_X.
          WHEN P_RAD1 OR P_RAD2.
            IF NOT LS_MOD_CELLS-VALUE IS INITIAL.
              IF LS_MOD_CELLS-VALUE <> 'C' AND
                 LS_MOD_CELLS-VALUE <> 'S'.
                PERFORM ADD_PROTOCOL_ENTRY
                  USING DATA_CHANGED
                        '선택 할 수 없는 유형입니다.'
                        LS_MOD_CELLS.
                EXIT.
              ENDIF.
            ENDIF.

          WHEN P_RAD3 OR P_RAD4.

        ENDCASE.

        " 포장재 유형
      WHEN 'PKTYP'.
        CASE LS_MOD_CELLS-VALUE.
          WHEN 'CO' OR 'WM'.
*          PERFORM add_protocol_entry
*USING data_changed 'DM 드럼형은 포장정보(디테일)에서 변경하십시오'
* ls_mod_cells.
            IF LS_MOD_CELLS-VALUE EQ 'CO'.
              PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                        'PKMATNR'  '7511009'.
            ELSE.
*               PERFORM modify_cell   USING data_changed ls_mod_cells
* 'PKMATNR'  '7511009'.
            ENDIF.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'PKTYP'
                                     CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            IF LS_MOD_CELLS-VALUE <> 'CO'."기능개선 293734
              PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                         'PKMATNR'
              CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            ENDIF.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'MENGE'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'WIDTH'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'ZLENGTH'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'HEIGHT'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'PKWEI'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

          WHEN 'DM'.
            PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
                                       'DMMATNR'
                                      CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

          WHEN OTHERS.
        ENDCASE.

        CLEAR GT_BOTTOM_RIGHT.

        READ TABLE GT_BOTTOM_RIGHT INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC EQ 0.
          CLEAR GT_BOTTOM_LEFT.

          READ TABLE GT_BOTTOM_LEFT
                     WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                              POSNR = GT_BOTTOM_RIGHT-POSNR.
        ENDIF.

        CLEAR: GT_AREA, GV_ERROR.

        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'PKMATNR' LV_PKMATNR.

        " 포장재 유형을 입력한 경우 zlet0530에서 데이타를 읽음.
        PERFORM GET_ZLET0530_MATNR USING GT_BOTTOM_LEFT-SPART
                                         LS_MOD_CELLS-VALUE
                                         LV_PKMATNR
                                CHANGING GV_ERROR.

        " zlet0530 에서 데이타를 읽은 경우 수정
        IF GV_ERROR IS INITIAL.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                    'WIDTH'   GT_AREA-WIDTH.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                    'ZLENGTH' GT_AREA-ZLENGTH.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                    'HEIGHT'  GT_AREA-HEIGHT.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                    'PKWEI'   GT_AREA-PKWEI.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
                                    'PMEINS'  GT_AREA-PMEINS.

*{ 기능개선 175722 - 추가
*___포장재코드에 따라 길이, 무게가 변경된 경우 screen 1 차량톤수 변경
          LV_ZLENGTH = GT_AREA-ZLENGTH.
          LV_PKWEI   = GT_AREA-PKWEI.

          PERFORM MODIFY_SCREEN_OTHERS_INFO_TWO
            USING LS_MOD_CELLS-ROW_ID  LV_ZLENGTH LV_PKWEI.
*} 기능개선 175722 - 추가
        ENDIF.

        " TOP 2 SCREEN  에 신규라인을 늘리기 위해 체크
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'PKMATNR' LV_PKMATNR.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'WIDTH'   LV_WIDTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'ZLENGTH' LV_ZLENGTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'HEIGHT'  LV_HEIGHT.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
                                     'PKWEI'   LV_PKWEI.

        " 폭, 길이, 높이; 무게에 값이 있는 경우
        " DATA_CHANGED_FINISHED에서 1사분면에  라인을 늘려준다.
        IF NOT LS_MOD_CELLS-VALUE IS INITIAL AND
           NOT LV_WIDTH           IS INITIAL AND
           NOT LV_ZLENGTH         IS INITIAL AND
           NOT LV_HEIGHT          IS INITIAL AND NOT LV_PKWEI IS INITIAL
  AND ( LV_ICON_STATUS EQ ICON_CHANGE OR LV_ICON_STATUS IS INITIAL ).
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'PUSH' ICON_CHANGE.
          LV_VALUE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED +
          CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PUSH' LV_VALUE.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKTYP' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'DMMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'MENGE' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'WIDTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'ZLENGTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'HEIGHT' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKWEI' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          MOVE GC_X TO GV_MOD_FLAG.
          MOVE LS_MOD_CELLS-ROW_ID TO GV_INDEX.
        ENDIF.

        " 드럼 자재코드
      WHEN 'DMMATNR'.
        CLEAR: GV_ERROR, GT_AREA.

        " 드럼코드를 읽는다.
        PERFORM GET_CREATE_AREA_44 CHANGING LS_MOD_CELLS-VALUE
                                            GV_ERROR.

        " 드럼코드를 읽은 경우 폭, 길이, 높이, 무게 수정
        CHECK GV_ERROR IS INITIAL.
        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'WIDTH' GT_AREA-WIDTH.
        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'ZLENGTH' GT_AREA-ZLENGTH.
        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'HEIGHT' GT_AREA-HEIGHT.
        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'PKWEI' GT_AREA-PKWEI.
        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'PMEINS' GT_AREA-PMEINS.

        PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
        'PUSH' ICON_DISPLAY.
        LV_VALUE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED +
        CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
        PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
        'PUSH' LV_VALUE.

        " 배송 타입
      WHEN 'BFART'.

        IF LS_MOD_CELLS-VALUE  EQ '2' OR LS_MOD_CELLS-VALUE  EQ '4'.

          PERFORM ADD_PROTOCOL_ENTRY USING DATA_CHANGED
          '2.반입, 4.긴급 배송은 선택 불가합니다.' LS_MOD_CELLS.
          PERFORM MODIFY_CELL   USING DATA_CHANGED LS_MOD_CELLS
          'MIXLOD' ' '.

**          CALL METHOD data_changed->DISPLAY_PROTOCOL.
*          CALL METHOD data_changed->PROTOCOL_IS_VISIBLE.
**          CALL METHOD data_changed->REFRESH_PROTOCOL.
          EXIT.
        ELSEIF LS_MOD_CELLS-VALUE  EQ '3'.

          PERFORM MODIFY_CELL   USING DATA_CHANGED LS_MOD_CELLS
          'MIXLOD' 'V'.

        ENDIF.

        " 포장재 코드
      WHEN 'PKMATNR'.

        CLEAR GT_BOTTOM_RIGHT.
        READ TABLE GT_BOTTOM_RIGHT INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC EQ 0.
          CLEAR GT_BOTTOM_LEFT.
          READ TABLE GT_BOTTOM_LEFT
          WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                    POSNR = GT_BOTTOM_RIGHT-POSNR.
        ENDIF.

        CLEAR: GT_AREA, GV_ERROR.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'PKTYP' LV_PKTYP.

        " zlet0530 포장재 정보를 읽는다.
        PERFORM GET_ZLET0530_MATNR USING GT_BOTTOM_LEFT-SPART LV_PKTYP
        LS_MOD_CELLS-VALUE CHANGING GV_ERROR.

        " 포장재 정보를 읽은 경우 폭,길이,높이,무게 수정
        IF GV_ERROR IS INITIAL.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'WIDTH' GT_AREA-WIDTH.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'ZLENGTH' GT_AREA-ZLENGTH.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'HEIGHT' GT_AREA-HEIGHT.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'PKWEI' GT_AREA-PKWEI.
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'PMEINS' GT_AREA-PMEINS.

*{ 기능개선 175722 - 추가
*___포장재코드에 따라 길이, 무게가 변경된 경우 screen 1 차량톤수 변경
          LV_ZLENGTH = GT_AREA-ZLENGTH.
          LV_PKWEI   = GT_AREA-PKWEI.

          PERFORM MODIFY_SCREEN_OTHERS_INFO_TWO
            USING LS_MOD_CELLS-ROW_ID  LV_ZLENGTH LV_PKWEI.
*} 기능개선 175722 - 추가
        ENDIF.
*
        " TOP 2 SCREEN  에 신규라인을 늘리기 위해 체크
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'PKTYP' LV_PKTYP.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'WIDTH' LV_WIDTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'ZLENGTH' LV_ZLENGTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'HEIGHT' LV_HEIGHT.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'PKWEI' LV_PKWEI.

        " 폭, 길이, 높이; 무게에 값이 있는 경우
        " DATA_CHANGED_FINISHED에서 1사분면에  라인을 늘려준다.
        IF NOT LS_MOD_CELLS-VALUE IS INITIAL AND
        NOT LV_PKTYP IS INITIAL
     AND NOT LV_WIDTH IS INITIAL AND NOT LV_ZLENGTH IS INITIAL
     AND NOT LV_HEIGHT IS INITIAL AND NOT LV_PKWEI IS INITIAL
    AND ( LV_ICON_STATUS EQ ICON_CHANGE OR LV_ICON_STATUS IS INITIAL ).
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
           'PUSH' ICON_CHANGE.
          LV_VALUE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED
          + CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PUSH' LV_VALUE.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKTYP' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'DMMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'MENGE' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'WIDTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'ZLENGTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'HEIGHT' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKWEI' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          MOVE GC_X TO GV_MOD_FLAG.
          MOVE LS_MOD_CELLS-ROW_ID TO GV_INDEX.
        ENDIF.

      WHEN 'WIDTH' OR 'ZLENGTH' OR 'HEIGHT' OR 'PKWEI'.

        MOVE LS_MOD_CELLS-VALUE TO LV_DEC.
        MOVE LV_DEC TO LV_CHAR4.
        SPLIT  LV_CHAR4 AT '.' INTO LV_CHAR1 LV_CHAR2.
        CONDENSE LV_CHAR1 NO-GAPS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'WIDTH' OR 'HEIGHT'.

            IF STRLEN( LV_CHAR1 ) >= 4.

              PERFORM ADD_PROTOCOL_ENTRY USING DATA_CHANGED
            '폭,길이,높이는 CM 단위로 입력하셔야 합니다.' LS_MOD_CELLS.
              EXIT.
*              PERFORM modify_cell   USING data_changed
* ls_mod_cells ls_mod_cells-fieldname ''.
*              MOVE gc_x TO gv_error.
*              EXIT.

            ENDIF.

            PERFORM MODIFY_CELL   USING DATA_CHANGED LS_MOD_CELLS
            'PKMATNR' ''.
            " 길이
          WHEN 'ZLENGTH'.

            IF STRLEN( LV_CHAR1 ) >= 4.

              PERFORM ADD_PROTOCOL_ENTRY USING DATA_CHANGED
            '폭,길이,높이는 CM 단위로 입력하셔야 합니다.' LS_MOD_CELLS.
              EXIT.
*              PERFORM modify_cell   USING data_changed
* ls_mod_cells ls_mod_cells-fieldname ''.
*              MOVE gc_x TO gv_error.
*              EXIT.

            ENDIF.

            PERFORM MODIFY_CELL   USING DATA_CHANGED LS_MOD_CELLS
            'PKMATNR' ''.

            PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
            'PKWEI' LV_PKWEI.

            " 차량톤수 길이에 따라 변경 screen 1
            PERFORM MODIFY_SCREEN_OTHERS_INFO_TWO
            USING LS_MOD_CELLS-ROW_ID LS_MOD_CELLS-VALUE LV_PKWEI.

            " 무게
          WHEN 'PKWEI'.

            PERFORM MODIFY_CELL   USING DATA_CHANGED LS_MOD_CELLS
            'PMEINS' 'KG'.

            PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
            'ZLENGTH' LV_ZLENGTH.

            " 차량톤수 길이에 따라 변경 screen 1
            PERFORM MODIFY_SCREEN_OTHERS_INFO_TWO
            USING LS_MOD_CELLS-ROW_ID LV_ZLENGTH LS_MOD_CELLS-VALUE.

        ENDCASE.

        " 수정한 된 납품문서는 품목 전체를 수정 신호등(노란색신호등
        " 으로 변경한다.
        CASE P_SENDER.
          WHEN GC_ALV_GRID2.
            READ TABLE GT_TOP_RIGHT INDEX LS_MOD_CELLS-ROW_ID.
            PERFORM CHEATE_DELTA_CELLS_TOP USING DATA_CHANGED
            LS_MOD_CELLS-FIELDNAME LS_MOD_CELLS LS_MOD_CELLS-VALUE
            GT_TOP_RIGHT 'GRID2'.
          WHEN GC_ALV_GRID4.
            READ TABLE GT_BOTTOM_RIGHT INDEX LS_MOD_CELLS-ROW_ID.
            MOVE-CORRESPONDING GT_BOTTOM_RIGHT TO GT_TOP_RIGHT.
            PERFORM CHEATE_DELTA_CELLS_TOP USING DATA_CHANGED
            LS_MOD_CELLS-FIELDNAME LS_MOD_CELLS LS_MOD_CELLS-VALUE
            GT_TOP_RIGHT 'GRID4'.
        ENDCASE.

        " TOP 2 SCREEN  에 신규라인을 늘리기 위해 체크
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'PKTYP' LV_PKTYP.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'WIDTH' LV_WIDTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'ZLENGTH' LV_ZLENGTH.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'HEIGHT' LV_HEIGHT.
        PERFORM GET_CELL_VALUE USING DATA_CHANGED LS_MOD_CELLS
        'PKWEI' LV_PKWEI.

        CASE  LS_MOD_CELLS-FIELDNAME.
          WHEN 'WIDTH'.
            MOVE LS_MOD_CELLS-VALUE TO LV_WIDTH.
          WHEN 'ZLENGTH'.
            MOVE LS_MOD_CELLS-VALUE TO LV_ZLENGTH.
          WHEN 'HEIGHT'.
            MOVE LS_MOD_CELLS-VALUE TO LV_HEIGHT.
          WHEN 'PKWEI'.
            MOVE LS_MOD_CELLS-VALUE TO LV_PKWEI.
        ENDCASE.

        " 폭, 길이, 높이; 무게에 값이 있는 경우
        " DATA_CHANGED_FINISHED에서 1사분면에  라인을 늘려준다.
        IF NOT LV_PKTYP IS INITIAL AND NOT LV_ZLENGTH IS INITIAL
     AND NOT LV_WIDTH IS INITIAL AND NOT LV_HEIGHT IS INITIAL
     AND NOT LV_PKWEI IS INITIAL
    AND ( LV_ICON_STATUS EQ ICON_CHANGE OR LV_ICON_STATUS IS INITIAL ).
          PERFORM MODIFY_CELL USING DATA_CHANGED LS_MOD_CELLS
          'PUSH' ICON_CHANGE.
          LV_VALUE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED
          + CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PUSH' LV_VALUE.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKTYP' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'DMMATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'MENGE' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'WIDTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'ZLENGTH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'HEIGHT' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          PERFORM MODIFY_STYLE USING DATA_CHANGED LS_MOD_CELLS
          'PKWEI' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          MOVE GC_X TO GV_MOD_FLAG.
          MOVE LS_MOD_CELLS-ROW_ID TO GV_INDEX.
        ELSE.
          REFRESH GT_DELTA_CELLS.
        ENDIF.

        " 포장재 수량
      WHEN 'MENGE'.

        MOVE LS_MOD_CELLS-VALUE TO LV_P.

        IF LV_P < 0.
          PERFORM ADD_PROTOCOL_ENTRY USING DATA_CHANGED
          '정수를 입력 바랍니다.' LS_MOD_CELLS.
          EXIT.
        ENDIF.

        CASE P_SENDER.
          WHEN GC_ALV_GRID2.

            CLEAR GT_TOP_RIGHT.
            READ TABLE GT_TOP_RIGHT INDEX LS_MOD_CELLS-ROW_ID.

            " 1사분면에 수량이 변경된 여부 판단.
            CHECK LS_MOD_CELLS-VALUE <> GT_TOP_RIGHT-MENGE.

            MOVE LS_MOD_CELLS-VALUE TO LV_DEC.
            MOVE LV_DEC TO LV_CHAR4.

            SPLIT  LV_CHAR4 AT '.' INTO LV_CHAR1 LV_CHAR2.

            MOVE LV_CHAR2 TO LV_INT.

            IF LV_INT > 0.

              PERFORM ADD_PROTOCOL_ENTRY USING DATA_CHANGED
              '정수를 입력 바랍니다.' LS_MOD_CELLS.
              EXIT.

            ENDIF.

            " 1사분면의 포장재 수량이 증가된 경우인지 아닌지 판단
            LV_SUB = LS_MOD_CELLS-VALUE - GT_TOP_RIGHT-MENGE.

            CHECK NOT LV_SUB IS INITIAL.
            " 입력된 수량이 증가한 경우
            IF LV_SUB > 0.
              DO.
                LOOP AT GT_BOTTOM_RIGHT
                             WHERE VBELN   EQ GT_TOP_RIGHT-VBELN
                               AND PKTYP   EQ GT_TOP_RIGHT-PKTYP
                               AND PKMATNR EQ GT_TOP_RIGHT-PKMATNR
                               AND WIDTH   EQ GT_TOP_RIGHT-WIDTH
                               AND ZLENGTH EQ GT_TOP_RIGHT-ZLENGTH
                               AND HEIGHT  EQ GT_TOP_RIGHT-HEIGHT
                               AND PKWEI   EQ GT_TOP_RIGHT-PKWEI.

                  " 소숫점인 경우
*                  IF lv_sub < 1.
*                    ADD lv_sub TO gt_bottom_right-menge.
*                    MOVE 0 TO lv_sub.
*                    " 정수인 ㅣ경우
*                  ELSE.
                  IF LV_SUB EQ 0.
                    EXIT.
                  ENDIF.

                  " 4사분면에 포장재 1개씩 수량 반영
                  ADD 1 TO GT_BOTTOM_RIGHT-MENGE.
*                  ENDIF.

                  MODIFY GT_BOTTOM_RIGHT
                  INDEX SY-TABIX TRANSPORTING MENGE.

                  " 증가된 수량분은 하나씩 가
                  SUBTRACT 1 FROM LV_SUB.

                ENDLOOP.

                " 증가분 수량분이 '0'이면 .exit
                IF LV_SUB EQ 0.
                  EXIT.
                ENDIF.

              ENDDO.

              " 1사분면의 포장재 수량이 가감된 경우
            ELSE.

              DO.
                LOOP AT GT_BOTTOM_RIGHT
                        WHERE VBELN EQ GT_TOP_RIGHT-VBELN
                         AND PKTYP     EQ GT_TOP_RIGHT-PKTYP
                         AND PKMATNR EQ GT_TOP_RIGHT-PKMATNR
                         AND WIDTH     EQ GT_TOP_RIGHT-WIDTH
                         AND ZLENGTH EQ GT_TOP_RIGHT-ZLENGTH
                         AND HEIGHT   EQ GT_TOP_RIGHT-HEIGHT
                         AND PKWEI    EQ GT_TOP_RIGHT-PKWEI.

                  "  포장재 수량을 가감한다.
                  IF NOT GT_BOTTOM_RIGHT-MENGE IS INITIAL.
                    SUBTRACT 1 FROM GT_BOTTOM_RIGHT-MENGE.
                    " '0'이면 가감 제
                  ELSEIF  GT_BOTTOM_RIGHT-MENGE IS INITIAL.
                    CONTINUE.
                  ENDIF.

                  MODIFY GT_BOTTOM_RIGHT
                  INDEX SY-TABIX TRANSPORTING MENGE.

                  ADD 1 TO LV_SUB.
                  IF LV_SUB EQ 0.
                    EXIT.
                  ENDIF.

                ENDLOOP.
                " 토탈 수량이 0이면 exit
                IF LV_SUB EQ 0.
                  EXIT.
                ENDIF.

              ENDDO.
            ENDIF.

            " DATA_CHANGED_FINISHED에서
            " 아이콘 상태 변경
            LOOP AT GT_BOTTOM_RIGHT WHERE VBELN EQ GT_TOP_RIGHT-VBELN
                                 AND PKTYP   EQ GT_TOP_RIGHT-PKTYP
                                 AND PKMATNR EQ GT_TOP_RIGHT-PKMATNR
                                 AND WIDTH   EQ GT_TOP_RIGHT-WIDTH
                                 AND ZLENGTH EQ GT_TOP_RIGHT-ZLENGTH
                                 AND HEIGHT  EQ GT_TOP_RIGHT-HEIGHT
                                 AND PKWEI   EQ GT_TOP_RIGHT-PKWEI.

              MOVE SY-TABIX TO GV_TABIX.
              MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
              MOVE GT_BOTTOM_RIGHT-MENGE TO GS_DELTA_CELLS-VALUE.
              MOVE 'MENGE' TO GS_DELTA_CELLS-FIELDNAME.
              APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.

              MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
              MOVE ICON_YELLOW_LIGHT TO GS_DELTA_CELLS-VALUE.
              MOVE 'ICON' TO GS_DELTA_CELLS-FIELDNAME.
              APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.

            ENDLOOP.

          WHEN GC_ALV_GRID4.

            CLEAR GT_BOTTOM_RIGHT.
            READ TABLE GT_BOTTOM_RIGHT INDEX LS_MOD_CELLS-ROW_ID.

            MOVE SY-TABIX TO GV_TABIX.

            CHECK SY-SUBRC EQ 0.
            " 납품문서, 포장유형, 포장재코드,폭,길이,높이,무게가
            " 같은 경우 수량을  sum한다.
            CLEAR: LS_BOTTOM_RIGHT.
            LOOP AT GT_BOTTOM_RIGHT
              WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN
                AND PKTYP   EQ GT_BOTTOM_RIGHT-PKTYP
                AND PKMATNR EQ GT_BOTTOM_RIGHT-PKMATNR
                AND WIDTH   EQ GT_BOTTOM_RIGHT-WIDTH
                AND ZLENGTH EQ GT_BOTTOM_RIGHT-ZLENGTH
                AND HEIGHT  EQ GT_BOTTOM_RIGHT-HEIGHT
                AND PKWEI   EQ GT_BOTTOM_RIGHT-PKWEI.

              IF GV_TABIX EQ SY-TABIX.
                ADD LS_MOD_CELLS-VALUE TO LS_BOTTOM_RIGHT-MENGE.
              ELSE.
                ADD GT_BOTTOM_RIGHT-MENGE TO LS_BOTTOM_RIGHT-MENGE.
              ENDIF.

            ENDLOOP.

            " 소수점이 아래 숫자가 있으면 1 더 해준다.
            MOVE LS_BOTTOM_RIGHT-MENGE TO LV_CHAR3.
            SPLIT  LV_CHAR3 AT '.' INTO LV_CHAR1 LV_CHAR2.
            MOVE LV_CHAR1 TO LV_SUB.

            MOVE LV_CHAR2 TO LV_SUB2.

            IF LV_SUB2 > 0.
              ADD 1 TO LV_SUB.
            ENDIF.

            " DATA_CHANGED_FINISHED에서
            " 아이콘 상태 변경
            CLEAR GT_TOP_RIGHT.
            READ TABLE GT_TOP_RIGHT
              WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                       PKTYP   = GT_BOTTOM_RIGHT-PKTYP
                       PKMATNR = GT_BOTTOM_RIGHT-PKMATNR
                       WIDTH   = GT_BOTTOM_RIGHT-WIDTH
                       ZLENGTH = GT_BOTTOM_RIGHT-ZLENGTH
                       HEIGHT  = GT_BOTTOM_RIGHT-HEIGHT
                       PKWEI   = GT_BOTTOM_RIGHT-PKWEI.

            IF SY-SUBRC EQ 0.
              MOVE SY-TABIX TO GV_TABIX.
              MOVE LV_SUB TO GT_TOP_RIGHT-MENGE.
              MODIFY GT_TOP_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.

              MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
              MOVE GT_TOP_RIGHT-MENGE TO GS_DELTA_CELLS-VALUE.
              MOVE 'MENGE' TO GS_DELTA_CELLS-FIELDNAME.
              APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.

              MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
              MOVE ICON_YELLOW_LIGHT TO GS_DELTA_CELLS-VALUE.
              MOVE 'ICON' TO GS_DELTA_CELLS-FIELDNAME.
              APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.
*
*              ENDIF.

*            ELSE.
*
*              CLEAR gt_top_right.
*      READ TABLE gt_top_right WITH KEY vbeln = gt_bottom_right-vbeln
*                                  pktyp     = gt_bottom_right-pktyp
*                                  pkmatnr = gt_bottom_right-pkmatnr
*                                 width      = gt_bottom_right-width
*                                 zlength   = gt_bottom_right-zlength
*                                 height    = gt_bottom_right-height
*                                 pkwei     = gt_bottom_right-pkwei.
*
*          IF sy-subrc EQ 0.
*            MOVE sy-tabix TO gv_tabix.
*            ADD lv_sub TO gt_top_right-menge.
*            MODIFY gt_top_right INDEX gv_tabix TRANSPORTING menge.
*
*            MOVE gv_tabix TO gs_delta_cells-row_id.
*            MOVE gt_top_right-menge TO gs_delta_cells-value.
*            MOVE 'MENGE' TO gs_delta_cells-fieldname.
*            APPEND gs_delta_cells TO gt_delta_cells.
*
*            MOVE gv_tabix TO gs_delta_cells-row_id.
*            MOVE icon_yellow_light TO gs_delta_cells-value.
*            MOVE 'ICON' TO gs_delta_cells-fieldname.
*            APPEND gs_delta_cells TO gt_delta_cells.

            ENDIF.

*            ENDIF.

        ENDCASE.

    ENDCASE.

*{ 기능개선 159419 - 삭제
*    PERFORM modify_cell USING data_changed ls_mod_cells
*                              'ICON'  icon_yellow_light.
*} 기능개선 159419 - 삭제

  ENDLOOP.

*  IF NOT gv_error  IS INITIAL.
*    CALL METHOD data_changed->display_protocol.
*  ENDIF.
**          CALL METHOD RR_DATA_CHANGED->PROTOCOL_IS_VISIBLE.

*    CASE LS_MOD_CELLS-FIELDNAME.
*      WHEN 'WERKS'.
*        CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
*          EXPORTING
*            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*          IMPORTING
*            E_VALUE     = LV_WERKS.
*
*        IF LV_WERKS <> P_WERKS.
*          CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*            EXPORTING
*              I_MSGID     = 'ZWM1'
*              I_MSGNO     = '002'
*              I_MSGTY     = 'E'
*              I_MSGV1     = '플랜트는'
*              I_MSGV2     = P_WERKS
*              I_MSGV3     = '만 입력 가능합니다.'
*              I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*              I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
*
*          CALL METHOD RR_DATA_CHANGED->DISPLAY_PROTOCOL.
**          CALL METHOD RR_DATA_CHANGED->PROTOCOL_IS_VISIBLE.
*        ENDIF.
*
*  ENDLOOP.

  IF GV_REFRESH_FLAG EQ GC_X.
    CLEAR GV_REFRESH_FLAG.
    PERFORM REFRESH_GRID USING GC_ALV_GRID1.
  ENDIF.

ENDFORM.                    " data_changed
*&---------------------------------------------------------------------*
*&      Form  SAVE_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*----------------------------------------------------------------------*
FORM SAVE_DELIVERY  USING P_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_ROWS     TYPE LVC_T_ROW,
        LS_ROWS     TYPE LVC_S_ROW,
        LT_E1CUVAL  TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS     LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LS_TOP_LEFT LIKE GT_TOP_LEFT.

  PERFORM GET_SELECT_ROW USING P_GRID
                      CHANGING LT_ROWS[].

  CLEAR GV_ERROR.

  PERFORM LT_ROWS USING LT_ROWS '선택한 라인이 없습니다.'
               CHANGING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  " 체크 로직
  CLEAR: GV_ERROR, GV_MESSAGE.

  PERFORM CHECK_SAVE_DATA USING LT_ROWS
                       CHANGING GV_ERROR
                                GV_MESSAGE.

  PERFORM MESSAGE_RESULT USING GV_MESSAGE
                               GC_E.

  CHECK GV_ERROR IS INITIAL.

  " 데이타 구성
  CLEAR: GV_ERROR, GV_MESSAGE.

  PERFORM MAKE_SAVE_DATA TABLES GT_INSERT
                          USING LT_ROWS
                       CHANGING GV_ERROR
                                GV_MESSAGE.

  " 메시지 결과
  PERFORM MESSAGE_RESULT USING GV_MESSAGE
                               GC_E.

  CHECK GV_ERROR IS INITIAL.

  " 데이타 저장
  PERFORM INSERT_ZLET0917 TABLES GT_INSERT.

  LOOP AT LT_ROWS INTO LS_ROWS.
    CLEAR LS_TOP_LEFT.

    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX INTO LS_TOP_LEFT.

    GT_TOP_LEFT-ICON = GT_TOP_RIGHT-ICON = GT_BOTTOM_LEFT-ICON =
    GT_BOTTOM_RIGHT-ICON = ICON_GREEN_LIGHT.

    MODIFY GT_TOP_LEFT     INDEX LS_ROWS-INDEX TRANSPORTING ICON.
    MODIFY GT_TOP_RIGHT    TRANSPORTING ICON
                           WHERE VBELN EQ LS_TOP_LEFT-VBELN.
    MODIFY GT_BOTTOM_LEFT  TRANSPORTING ICON
                           WHERE VBELN EQ LS_TOP_LEFT-VBELN.
    MODIFY GT_BOTTOM_RIGHT TRANSPORTING ICON
                           WHERE VBELN EQ LS_TOP_LEFT-VBELN.
  ENDLOOP.

*  REFRESH: gt_top_right, gt_bottom_left, gt_bottom_right.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      SORT GT_TOP_LEFT     BY VBELN POSNR.
      SORT GT_BOTTOM_LEFT  BY VBELN POSNR.
      SORT GT_TOP_RIGHT    BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
    WHEN P_RAD3 OR P_RAD4.
      SORT GT_TOP_LEFT     BY SHSRQ.
      SORT GT_BOTTOM_LEFT  BY VBELN POSNR.
      SORT GT_TOP_RIGHT    BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
  ENDCASE.

ENDFORM.                    " SAVE_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  ADD_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*----------------------------------------------------------------------*
FORM ADD_ROW  USING  P_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LV_LINES TYPE I.
  DATA: LT_TAB LIKE GT_TOP_RIGHT OCCURS 0 WITH HEADER LINE.
  DATA: LT_BOTTOM LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE,
        LT_MAX    LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.
  DATA: LT_ROWS   TYPE LVC_T_ROW,
        LS_ROWS   TYPE LVC_S_ROW,
        LV_ROW    TYPE I,
        LV_INDEX  TYPE I,
        LS_TOP    LIKE GT_TOP_RIGHT,
        LT_TOP    LIKE GT_TOP_LEFT OCCURS 0 WITH HEADER LINE,
        LS_BOTTOM LIKE GT_BOTTOM_RIGHT.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL.

  CASE P_GRID.
    WHEN GC_ALV_GRID3.
*
      PERFORM GET_SELECT_ROW_TWO  USING P_GRID  CHANGING LT_ROWS[].

      LV_LINES = LINES( LT_ROWS[] ).

      IF LV_LINES > 0.
        CLEAR: GV_ERROR, GV_MESSAGE.
        PERFORM CHECK_ROWS USING LT_ROWS[] CHANGING GV_ERROR GV_MESSAGE.

        IF LINES( LT_ROWS[] ) > 1.
          MESSAGE S001 WITH '라인 하나만 선택하세요' DISPLAY LIKE GC_E.
          MOVE GC_X TO GV_ERROR.
          RETURN.
        ENDIF.

        PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.
        CHECK GV_ERROR IS INITIAL.
      ELSE.
        CLEAR LV_ROW.
        PERFORM GET_CURRENT_CELL USING P_GRID CHANGING LV_ROW .
        IF LV_ROW IS INITIAL.
          MOVE '선택 라인이 없습니다.' TO GV_MESSAGE.
          PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.
        ENDIF.
        CHECK NOT LV_ROW IS INITIAL.
        MOVE LV_ROW TO LS_ROWS-INDEX.
        APPEND LS_ROWS TO LT_ROWS.
      ENDIF.
      " 체크 로직
      CLEAR: GV_ERROR, GV_MESSAGE.
      PERFORM CHECK_GRID3_SCREEN USING LT_ROWS
      CHANGING GV_ERROR GV_MESSAGE.
      PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.

      CHECK GV_ERROR IS INITIAL.

      READ TABLE LT_ROWS INDEX 1 INTO LS_ROWS.
      CLEAR LS_BOTTOM.
      READ TABLE GT_BOTTOM_LEFT INDEX LS_ROWS-INDEX .
      CHECK SY-SUBRC EQ 0.

      MOVE GT_BOTTOM_RIGHT[] TO LT_MAX[].

      SORT LT_MAX BY SHSRQ DELIDN DESCENDING.
      " 선적 시뮬레이션 판별
      READ TABLE LT_MAX WITH KEY SHSRQ = GT_BOTTOM_LEFT-SHSRQ.

      IF  SY-SUBRC EQ 0.
        " 선적 시뮬레이션인 경우 제일 큰값
        MOVE LT_MAX-DELIDN TO LS_BOTTOM-DELIDN.
        ADD 1 TO LS_BOTTOM-DELIDN.
      ELSE.
        " 일반 출하는 '000001'.
        MOVE '000001' TO LS_BOTTOM-DELIDN.
      ENDIF.

      MOVE ICON_LIGHT_OUT TO LS_BOTTOM-ICON.
      MOVE GT_BOTTOM_LEFT-VBELN TO LS_BOTTOM-VBELN.
      MOVE GT_BOTTOM_LEFT-POSNR TO LS_BOTTOM-POSNR.
      MOVE GT_BOTTOM_LEFT-SHSRQ TO LS_BOTTOM-SHSRQ.
      MOVE 'EA' TO LS_BOTTOM-ZMEINS.
      MOVE 'KG' TO LS_BOTTOM-PMEINS.

      " 필드 입력 가능, 불가 선언
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'PKTYP'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'PKMATNR'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'MENGE'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'ZMEINS'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'WIDTH'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'ZLENGTH'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'HEIGHT'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'PKWEI'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'PMEINS'
      CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LS_BOTTOM-CELLTAB.
      APPEND LS_BOTTOM TO GT_BOTTOM_RIGHT.

      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.

      PERFORM REFRESH_GRID USING GC_ALV_GRID4.

      " 4사분면 라인 증가
    WHEN GC_ALV_GRID4.

      PERFORM GET_SELECT_ROW_TWO  USING P_GRID  CHANGING LT_ROWS[].

      LV_LINES = LINES( LT_ROWS[] ).
      "  라인 선택 체크 로직
      IF LV_LINES > 0.
        CLEAR: GV_ERROR, GV_MESSAGE.
        PERFORM CHECK_ROWS USING LT_ROWS[] CHANGING GV_ERROR GV_MESSAGE.
        PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.
        CHECK GV_ERROR IS INITIAL.
        " 마우스 포커스 체크 로직
      ELSE.
        CLEAR LV_ROW.
        PERFORM GET_CURRENT_CELL USING P_GRID CHANGING LV_ROW .
        IF LV_ROW IS INITIAL.
          MOVE '선택 라인이 없습니다.' TO GV_MESSAGE.
          PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.
        ENDIF.
        CHECK NOT LV_ROW IS INITIAL.
        MOVE LV_ROW TO LS_ROWS-INDEX.
        APPEND LS_ROWS TO LT_ROWS.
      ENDIF.

      " 전송 완료 체크
      CLEAR: GV_ERROR, GV_MESSAGE.
      PERFORM CHECK_NEW_LOGIC
      USING LT_ROWS CHANGING GV_ERROR GV_MESSAGE.
      PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.

      CHECK GV_ERROR IS INITIAL.

      CASE GC_X.
          " 일반 tms출하 및 전송 완료
        WHEN P_RAD1 OR P_RAD2.

          LOOP AT LT_ROWS INTO LS_ROWS.
            CLEAR GT_BOTTOM_RIGHT.
            READ TABLE GT_BOTTOM_RIGHT
            INDEX LS_ROWS-INDEX INTO LS_BOTTOM.
            CHECK SY-SUBRC EQ 0.
            MOVE LS_BOTTOM-DELIDN TO LV_INDEX.
            DO.
              ADD 1 TO LV_INDEX.
              CLEAR GT_BOTTOM_RIGHT.
              READ TABLE GT_BOTTOM_RIGHT
                WITH KEY VBELN  = LS_BOTTOM-VBELN
                         DELIDN = LV_INDEX.
              IF SY-SUBRC <> 0.
                CLEAR LT_BOTTOM.
                READ TABLE LT_BOTTOM WITH KEY VBELN  = LS_BOTTOM-VBELN
                                             POSNR = LS_BOTTOM-POSNR
                                             DELIDN = LV_INDEX.
                IF SY-SUBRC <> 0.
                  CLEAR GT_BOTTOM_LEFT.
                  READ TABLE GT_BOTTOM_LEFT
                    WITH KEY VBELN = LS_BOTTOM-VBELN
                             POSNR = LS_BOTTOM-POSNR.

                  MOVE ICON_LIGHT_OUT TO LT_BOTTOM-ICON.
                  MOVE LS_BOTTOM-VBELN TO LT_BOTTOM-VBELN.
                  MOVE LS_BOTTOM-POSNR TO LT_BOTTOM-POSNR.
                  MOVE GT_BOTTOM_LEFT-VBELN_VL TO LT_BOTTOM-VBELN_VL.
                  MOVE GT_BOTTOM_LEFT-POSNR_VL TO LT_BOTTOM-POSNR_VL.
                  MOVE GT_BOTTOM_LEFT-MATNR TO LT_BOTTOM-MATNR.
                  MOVE GT_BOTTOM_LEFT-ARKTX TO LT_BOTTOM-ARKTX.
                  MOVE GT_BOTTOM_LEFT-SPART TO LT_BOTTOM-SPART.

                  MOVE LV_INDEX TO LT_BOTTOM-DELIDN.
                  MOVE 'EA' TO LT_BOTTOM-ZMEINS.
                  MOVE 'KG' TO LT_BOTTOM-PMEINS.

***** 필드 추가 20170907 by 서동우
                  MOVE GT_BOTTOM_LEFT-LENGTH     TO LT_BOTTOM-LENGTH.
                  MOVE GT_BOTTOM_LEFT-FACTOR     TO LT_BOTTOM-FACTOR.
                  MOVE GT_BOTTOM_LEFT-NTGEW      TO LT_BOTTOM-NTGEW.
                  MOVE GT_BOTTOM_LEFT-GEWEI      TO LT_BOTTOM-GEWEI.
                  MOVE GT_BOTTOM_LEFT-NTGEW_LF   TO LT_BOTTOM-NTGEW_LF.
                  MOVE GT_BOTTOM_LEFT-GEWEI_LF   TO LT_BOTTOM-GEWEI_LF.
***** 필드 추가 20170907 by 서동우


                  " 필드속성 선언
                  PERFORM MODIFY_CELL_ATTRIBUTE
                  USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'PKMATNR'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'MENGE'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE
                  USING GC_NO_EDIT 'ZMEINS'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'WIDTH'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'ZLENGTH'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'HEIGHT'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT 'PKWEI'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE
                  USING GC_NO_EDIT 'PMEINS'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE
                  USING GC_NO_EDIT 'VBELN_VL'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE
                  USING GC_NO_EDIT 'POSNR_VL'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'MATNR'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT 'ARKTX'
                  CHANGING LT_CELLTAB.
                  INSERT LINES OF LT_CELLTAB
                  INTO TABLE LT_BOTTOM-CELLTAB.
                  APPEND LT_BOTTOM. CLEAR LT_BOTTOM.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDDO.

            IF LT_ROWS[] IS INITIAL.
              EXIT.
            ENDIF.

          ENDLOOP.

          APPEND LINES OF LT_BOTTOM TO GT_BOTTOM_RIGHT.
          SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
* 선적시뮬레이션은 SHSRQ로 운영
        WHEN P_RAD3 OR P_RAD4.

          READ TABLE LT_ROWS INDEX 1 INTO LS_ROWS.

          READ TABLE GT_BOTTOM_RIGHT INDEX LS_ROWS-INDEX INTO LS_BOTTOM.
          CHECK SY-SUBRC EQ 0.

          MOVE GT_BOTTOM_RIGHT[] TO LT_MAX[].

          SORT LT_MAX BY SHSRQ DELIDN DESCENDING.

          READ TABLE LT_MAX WITH KEY SHSRQ = LS_BOTTOM-SHSRQ.

          CHECK SY-SUBRC EQ 0.

          MOVE LT_MAX-DELIDN TO LV_INDEX.

          ADD 1 TO LV_INDEX.

          READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = LS_BOTTOM-VBELN
                                            POSNR = LS_BOTTOM-POSNR.

          MOVE ICON_LIGHT_OUT TO LT_BOTTOM-ICON.
          MOVE LS_BOTTOM-VBELN TO LT_BOTTOM-VBELN.
          MOVE LS_BOTTOM-POSNR TO LT_BOTTOM-POSNR.
          MOVE LS_BOTTOM-SHSRQ TO LT_BOTTOM-SHSRQ.
          MOVE GT_BOTTOM_LEFT-VBELN_VL TO LT_BOTTOM-VBELN_VL.
          MOVE GT_BOTTOM_LEFT-POSNR_VL TO LT_BOTTOM-POSNR_VL.
          MOVE GT_BOTTOM_LEFT-MATNR TO LT_BOTTOM-MATNR.
          MOVE GT_BOTTOM_LEFT-ARKTX TO LT_BOTTOM-ARKTX.
          MOVE GT_BOTTOM_LEFT-SPART TO LT_BOTTOM-SPART.

          MOVE LV_INDEX TO LT_BOTTOM-DELIDN.
          MOVE 'EA' TO LT_BOTTOM-ZMEINS.
          MOVE 'KG' TO LT_BOTTOM-PMEINS.

          " 필드속성 선언
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'PKTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'PKMATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'MENGE' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'ZMEINS' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'WIDTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'ZLENGTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'HEIGHT' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_EDIT
          'PKWEI' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'PMEINS' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'VBELN_VL' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'POSNR_VL' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'MATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE USING GC_NO_EDIT
          'ARKTX' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
          APPEND LT_BOTTOM. CLEAR LT_BOTTOM.

          APPEND LINES OF LT_BOTTOM TO GT_BOTTOM_RIGHT.
          SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
*
      ENDCASE.

  ENDCASE.

  PERFORM REFRESH_GRID USING P_GRID.

ENDFORM.                    " ADD_ROW
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*----------------------------------------------------------------------*
FORM DELETE_ROW  USING P_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_ROWS         TYPE LVC_T_ROW,
        LS_ROWS         TYPE LVC_S_ROW,
        LS_BOTTOM       LIKE GT_BOTTOM_RIGHT,
        LV_2SCREEN_FLAG,
        LV_3SCREEN_FLAG.

  CALL METHOD P_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.

  DELETE LT_ROWS WHERE INDEX EQ 0.

  CLEAR GV_ERROR.

  " 라인 선택 생성
  PERFORM LT_ROWS USING LT_ROWS '선택한 라인이 없습니다.'
  CHANGING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  SORT LT_ROWS BY INDEX DESCENDING.

  CLEAR: GV_ERROR, GV_MESSAGE.
  " 체크 로직
  PERFORM CHECK_DELETE_LOGIC USING LT_ROWS
  CHANGING GV_ERROR GV_MESSAGE.
  " 메시지
  PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.

  CHECK GV_ERROR IS INITIAL.

  CASE P_GRID.
    WHEN GC_ALV_GRID1.
      LOOP AT LT_ROWS INTO LS_ROWS.
        DELETE GT_TOP_LEFT INDEX LS_ROWS-INDEX.
      ENDLOOP.
      PERFORM REFRESH_GRID USING P_GRID.
    WHEN GC_ALV_GRID2.

      SORT LT_ROWS BY INDEX DESCENDING.

      " 데이타를 삭제한 경우 각 스크린별 데이타도 삭제한다.
      LOOP AT LT_ROWS INTO LS_ROWS.
        READ TABLE GT_TOP_RIGHT INDEX LS_ROWS-INDEX.
        DELETE GT_TOP_RIGHT INDEX LS_ROWS-INDEX.
        DELETE GT_BOTTOM_RIGHT WHERE VBELN EQ GT_TOP_RIGHT-VBELN
                            AND PKTYP     EQ GT_TOP_RIGHT-PKTYP
                            AND PKMATNR   EQ GT_TOP_RIGHT-PKMATNR
                            AND WIDTH   EQ GT_TOP_RIGHT-WIDTH
                            AND ZLENGTH EQ  GT_TOP_RIGHT-ZLENGTH
                            AND HEIGHT EQ GT_TOP_RIGHT-HEIGHT
                            AND PKWEI   EQ GT_TOP_RIGHT-PKWEI.

      ENDLOOP.

      " 데이타를 삭제한 경우 각 스크린별 데이타도 삭제한다.
      LOOP AT GT_BOTTOM_LEFT WHERE NOT ICON EQ ICON_LED_INACTIVE.
        LOOP AT  GT_BOTTOM_RIGHT WHERE VBELN EQ GT_BOTTOM_LEFT-VBELN
                                  AND POSNR EQ GT_BOTTOM_LEFT-POSNR.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC <> 0.
          DELETE GT_BOTTOM_LEFT.
        ENDIF.
      ENDLOOP.

      PERFORM REFRESH_GRID USING GC_ALV_GRID2.
      PERFORM REFRESH_GRID USING GC_ALV_GRID3.
      PERFORM REFRESH_GRID USING GC_ALV_GRID4.

    WHEN GC_ALV_GRID4.

      " 데이타를 삭제한 경우 각 스크린별 데이타도 삭제한다.
      LOOP AT LT_ROWS INTO LS_ROWS.
        CLEAR GT_BOTTOM_RIGHT.
        READ TABLE GT_BOTTOM_RIGHT INDEX LS_ROWS-INDEX INTO LS_BOTTOM.

        DELETE GT_BOTTOM_RIGHT INDEX LS_ROWS-INDEX.

        LOOP AT  GT_BOTTOM_RIGHT WHERE VBELN     EQ LS_BOTTOM-VBELN
                                   AND PKTYP    EQ LS_BOTTOM-PKTYP
                                   AND PKMATNR  EQ LS_BOTTOM-PKMATNR
                                   AND WIDTH    EQ LS_BOTTOM-WIDTH
                                   AND ZLENGTH EQ  LS_BOTTOM-ZLENGTH
                                   AND HEIGHT   EQ LS_BOTTOM-HEIGHT
                                   AND PKWEI    EQ LS_BOTTOM-PKWEI.
          EXIT.
        ENDLOOP.

        IF SY-SUBRC <> 0.
          DELETE GT_TOP_RIGHT WHERE VBELN    EQ LS_BOTTOM-VBELN
                                AND PKTYP     EQ LS_BOTTOM-PKTYP
                               AND PKMATNR  EQ LS_BOTTOM-PKMATNR
                                AND WIDTH     EQ LS_BOTTOM-WIDTH
                                AND ZLENGTH EQ  LS_BOTTOM-ZLENGTH
                                AND HEIGHT   EQ LS_BOTTOM-HEIGHT
                                AND PKWEI    EQ LS_BOTTOM-PKWEI.

        ENDIF.

      ENDLOOP.

*      LOOP AT gt_bottom_left WHERE NOT icon EQ icon_led_inactive.
*        LOOP AT  gt_bottom_right WHERE vbeln EQ gt_bottom_left-vbeln
*                                  AND posnr EQ gt_bottom_left-posnr.
*          EXIT.
*        ENDLOOP.
*        IF sy-subrc <> 0.
*          DELETE gt_bottom_left.
*        ENDIF.
*      ENDLOOP.

      CLEAR GT_TOP_RIGHT.
      MODIFY GT_TOP_RIGHT TRANSPORTING MENGE
       WHERE NOT  MENGE IS INITIAL.

      " 상단 우측에 수량 sum을 재생성한다.
      PERFORM DEC_INTEGER_QUANTITY_TWO CHANGING GV_ERROR.

      PERFORM REFRESH_GRID USING GC_ALV_GRID2.
*      PERFORM refresh_grid USING gc_alv_grid3.
      PERFORM REFRESH_GRID USING GC_ALV_GRID4.
  ENDCASE.

ENDFORM.                    " DELETE_ROW
*&---------------------------------------------------------------------*
*&      Form  GET_SELECT_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GRID  text
*      -->P_LT_ROWS[]  text
*----------------------------------------------------------------------*
FORM GET_SELECT_ROW  USING P_GRID  TYPE REF TO CL_GUI_ALV_GRID
                  CHANGING PT_ROWS TYPE LVC_T_ROW.

  DATA: LT_TOP LIKE GT_TOP_LEFT OCCURS 0 WITH HEADER LINE.
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROWS TYPE LVC_S_ROW.

  CALL METHOD P_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = PT_ROWS.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.

    WHEN P_RAD3 OR P_RAD4.
      LOOP AT PT_ROWS INTO LS_ROWS.
        CLEAR GT_TOP_LEFT.
        READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.
        LOOP AT GT_TOP_LEFT WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ.

          MOVE SY-TABIX TO LS_ROWS-INDEX.
          APPEND LS_ROWS TO LT_ROWS.
        ENDLOOP.

      ENDLOOP.

      SORT LT_ROWS BY INDEX.
      DELETE ADJACENT DUPLICATES FROM LT_ROWS COMPARING INDEX.

      MOVE LT_ROWS[] TO PT_ROWS[].
  ENDCASE.

  DELETE PT_ROWS WHERE INDEX EQ 0.

ENDFORM.                    " GET_SELECT_ROW
*&---------------------------------------------------------------------*
*&      Form  GET_SELECT_ROW_Two
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GRID  text
*      -->P_LT_ROWS[]  text
*----------------------------------------------------------------------*
FORM GET_SELECT_ROW_TWO  USING P_GRID  TYPE REF TO CL_GUI_ALV_GRID
                      CHANGING PT_ROWS TYPE LVC_T_ROW.

  DATA: LT_TOP LIKE GT_TOP_LEFT OCCURS 0 WITH HEADER LINE.
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROWS TYPE LVC_S_ROW.

  CALL METHOD P_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = PT_ROWS.

  DELETE PT_ROWS WHERE INDEX EQ 0.

ENDFORM.                    " GET_SELECT_ROW_Two
*&---------------------------------------------------------------------*
*&      Form  SET_SELECT_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GRID  text
*      -->P_LT_ROWS[]  text
*----------------------------------------------------------------------*
FORM SET_SELECT_ROW  USING P_GRID TYPE REF TO CL_GUI_ALV_GRID
                  CHANGING PT_ROWS TYPE LVC_T_ROW.

  CHECK NOT PT_ROWS[] IS INITIAL.

  CHECK P_GRID EQ GC_ALV_GRID1.

  CALL METHOD P_GRID->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = PT_ROWS.

ENDFORM.                    " GET_SELECT_ROW
*&---------------------------------------------------------------------*
*&      Form  CHECK_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_ERROR  text
*      -->P_LT_ROWS[]  text
*----------------------------------------------------------------------*
FORM CHECK_ROWS  USING PT_ROWS TYPE LVC_T_ROW
              CHANGING PV_ERROR
                       PV_MSG.

  DATA: LT_TAB LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.
  DATA: LS_ROWS TYPE LVC_S_ROW.
  DATA: LV_LINE TYPE I.

  LOOP AT PT_ROWS INTO LS_ROWS.
    CLEAR GT_BOTTOM_RIGHT.
    READ TABLE GT_BOTTOM_RIGHT INDEX LS_ROWS-INDEX.
    CHECK SY-SUBRC EQ 0 .
    MOVE GT_BOTTOM_RIGHT TO LT_TAB.
    APPEND LT_TAB.
  ENDLOOP.

  SORT LT_TAB BY VBELN POSNR DELIDN.
  DELETE ADJACENT DUPLICATES FROM LT_TAB COMPARING VBELN POSNR DELIDN.

*   2건 이상이면 에러
  IF LINES( LT_TAB[] ) > 1.
    MOVE GC_X TO PV_ERROR.
    MOVE '하나의 라인만 선택하세요.' TO PV_MSG.
  ENDIF.

ENDFORM.                    " CHECK_ROWS
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM MESSAGE_RESULT  USING PV_MESSAGE TYPE STRING
                           PV_TYPE.

  CHECK NOT PV_MESSAGE IS INITIAL.

  MESSAGE S001 WITH PV_MESSAGE DISPLAY LIKE PV_TYPE.

ENDFORM.                    " MESSAGE_RESULT
*&---------------------------------------------------------------------*
*&      Form  GET_CURRENT_CELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_ROW  text
*----------------------------------------------------------------------*
FORM GET_CURRENT_CELL USING P_GRID TYPE REF TO CL_GUI_ALV_GRID
                   CHANGING PV_ROW.

  CALL METHOD P_GRID->GET_CURRENT_CELL
    IMPORTING
      E_ROW = PV_ROW.
*             e_value   =
*             e_col     =
*             es_row_id =
*             es_col_id =
*             es_row_no =


ENDFORM.                    " GET_CURRENT_CELL
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL.
  DATA : LV_SPART(2).

  LOOP AT GT_TOP_LEFT.
    CLEAR: LT_CELLTAB[], LT_COLOR[], LV_SPART.

    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_TOP_LEFT-VBELN.

    IF SY-SUBRC = 0.
      LV_SPART = GT_BOTTOM_LEFT-SPART.
    ENDIF.

    PERFORM FILL_CELLTAB_L USING LV_SPART
                           CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR     CHANGING LT_COLOR.

    CLEAR: GT_TOP_LEFT-CELLTAB[], GT_TOP_LEFT-F_COL[].

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_TOP_LEFT-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_TOP_LEFT-F_COL.

    MODIFY GT_TOP_LEFT.
    CLEAR  GT_TOP_LEFT.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C  USING PV_EDIT
                           PV_FIELDNAME
                  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

*  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
*    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.
*
**___필드 활성화 여부
*    IF LS_CELLTAB-FIELDNAME = 'FACTOR2' OR
*       LS_CELLTAB-FIELDNAME = 'LENGTH2' OR
  LS_CELLTAB-FIELDNAME = PV_FIELDNAME.

  IF PV_EDIT EQ GC_X.
    LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                         CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
  ELSE.
    LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
  ENDIF.

  IF PV_FIELDNAME EQ 'PUSH'.
    LS_CELLTAB-STYLE
    = LS_CELLTAB-STYLE + CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
  ENDIF.
*
  INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
*  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_TOP_LEFT_CELLTAB  text
*----------------------------------------------------------------------*
FORM MODIFY_CELL_ATTRIBUTE USING PV_EDIT PV_FIELDNAME
                        CHANGING PV_CELLTAB TYPE LVC_T_STYL.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL.

  CLEAR: LT_CELLTAB[], LT_COLOR[].

  PERFORM FILL_CELLTAB_C USING PV_EDIT PV_FIELDNAME CHANGING LT_CELLTAB.

  CLEAR: PV_CELLTAB[]. " , GT_MAIN-F_COL[].

  INSERT LINES OF LT_CELLTAB INTO TABLE PV_CELLTAB.

ENDFORM.                    " MODIFY_CELL_ATTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  SEND_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_DELIVERY USING P_GRID TYPE REF TO CL_GUI_ALV_GRID.

*  DATA: OD_DATA     LIKE ZLET0010S OCCURS 0 WITH HEADER LINE,
*        OD_SAVE     LIKE ZLET0010S OCCURS 0 WITH HEADER LINE,
*        LT_0917     LIKE ZLET0917 OCCURS 0 WITH HEADER LINE,
*        LT_ROWS     TYPE LVC_T_ROW,
*        LS_ROWS     TYPE LVC_S_ROW,
*        LT_TLIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
*        LV_STATUS   TYPE ZLET0903-STATUS,
*        LV_FLAG,
*        E_RESULT    TYPE CHAR2,
*        E_MESSAGE   TYPE CHAR200,
*        LV_MENGE    TYPE EKPO-MENGE,
*        PV_ERROR(1).
*
*  DATA: GV_ADRC  LIKE ADRC-NAME1.
*
*  DATA: LT_0903 LIKE ZLET0903 OCCURS 0 WITH HEADER LINE,
*        LT_0919 LIKE ZLET0919 OCCURS 0 WITH HEADER LINE,
*        LV_MNG  LIKE LT_0919-BRGEW.
*
*  DATA: LV_MATNR    LIKE MARA-MATNR.
*
*  PERFORM GET_SELECT_ROW USING P_GRID CHANGING LT_ROWS[].
*
*  CLEAR GV_ERROR.
*
*  PERFORM LT_ROWS USING LT_ROWS '선택한 라인이 없습니다.'
*  CHANGING GV_ERROR.
*
*  CHECK GV_ERROR IS INITIAL.
*
*  CLEAR: GV_MESSAGE, GV_ERROR.
*  " 데이타 체크
*  PERFORM CHECK_SEND_TMS USING LT_ROWS CHANGING GV_ERROR GV_MESSAGE.
*  PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.
*
*  CHECK GV_ERROR IS INITIAL.
*
*  CLEAR GV_ANSWER.
*  PERFORM POPUP_TO_CONFIRM USING '전송'
*                                 'TMS 전송 하시겠습니까?'
*                                 '1'
*                                 GV_ANSWER.
*
*  CHECK GV_ANSWER EQ 1 .
*
*  REFRESH OD_DATA.
*
*  LOOP AT LT_ROWS INTO LS_ROWS.
*
*    CLEAR GT_TOP_LEFT.
** 선택된 라인
*    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.
*
*    CASE GC_X.
*
*      WHEN P_RAD1 OR P_RAD2.
*        " 저장된 데이타를 전송한다.
*        SELECT *
*           INTO CORRESPONDING FIELDS OF TABLE LT_0917
*           FROM ZLET0917
*          WHERE VBELN EQ GT_TOP_LEFT-VBELN.
*
*      WHEN P_RAD3 OR P_RAD4.
*        " 저장된 데이타를 전송한다.
*        SELECT *
*           INTO CORRESPONDING FIELDS OF TABLE LT_0917
*           FROM ZLET0917
*          WHERE VBELN EQ GT_TOP_LEFT-VBELN
*               AND POSNR EQ GT_TOP_LEFT-POSNR.
*
*    ENDCASE.
*
*    LOOP AT LT_0917.
*      MOVE-CORRESPONDING LT_0917 TO OD_DATA.
*      " tms 전송할때 컨테이너 시뮬레이션은 cs를 빼고 보내준다.
*      IF GT_TOP_LEFT-VGTYP EQ 'V'.
*        CLEAR LT_0917-SHSRQ(2).
*        CONDENSE LT_0917-SHSRQ NO-GAPS.
*        MOVE LT_0917-SHSRQ TO OD_DATA-VBELN.
*      ENDIF.
*
*      MOVE LT_0917-CONTY TO OD_DATA-ETC012.
*      MOVE LT_0917-CONSZ TO OD_DATA-ETC013.
*      MOVE:  'N'            TO OD_DATA-IFFLG.
*      MOVE LT_0917-TRFLG TO OD_DATA-ETC003.
*
*      " TMS 용 납품 중량
*      IF OD_DATA-GEWEI EQ 'G'.
*
*        MOVE OD_DATA-NTGEW TO LV_MENGE.
*
*        LV_MATNR = OD_DATA-MATNR.
*
*        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
*          EXPORTING
*            I_MATNR              = LV_MATNR
*            I_IN_ME              = 'G'
*            I_OUT_ME             = 'KG'
*            I_MENGE              = LV_MENGE
*          IMPORTING
*            E_MENGE              = LV_MENGE
*          EXCEPTIONS
*            ERROR_IN_APPLICATION = 1
*            ERROR                = 2
*            OTHERS               = 3.
*
*        IF SY-SUBRC EQ 0.
*          MOVE LV_MENGE TO OD_DATA-NTGEW.
*        ELSE.
*          " 환산계수가 없는 경우 / 1000 한다.
*          IF NOT LV_MENGE IS INITIAL.
*            PERFORM CALCULATION_EXCEPTION_HANDING
*            USING LV_MENGE '/' 1000 CHANGING OD_DATA-NTGEW.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
*
*      IF NOT OD_DATA-NTGEW IS INITIAL  AND NOT OD_DATA-LFIMG IS INITIAL.
*        PERFORM CALCULATION_EXCEPTION_HANDING
*        USING OD_DATA-NTGEW '*' OD_DATA-LFIMG CHANGING OD_DATA-NTGEW.
*      ENDIF.
*
*      MOVE '0' TO OD_DATA-UPDCHK.
*
*      MOVE: SY-DATUM TO OD_DATA-ERDAT,
*                 SY-UZEIT   TO OD_DATA-ERZET,
*                 SY-UNAME TO OD_DATA-ERNAM,
*                 SY-DATUM TO OD_DATA-AEDAT,
*                 SY-UZEIT   TO OD_DATA-AEZET,
*                 SY-UNAME TO OD_DATA-AENAM.
*
**color(VKGRP) & 납품처명(MATKL) 입력
*      CLEAR : OD_DATA-VKGRP, OD_DATA-MATKL, GV_ATWRT.
*
*      REFRESH GT_ET_CHAR.
*
*      CLEAR PV_ERROR.
*      PERFORM GET_SALES_CHARACTER1 TABLES GT_ET_CHAR
*                                   USING OD_DATA-VBELN_VL
*                                         OD_DATA-POSNR_VL
*                                CHANGING PV_ERROR.
*
*      PERFORM READ_ET_CHAR
*      USING 'PD_CA_COLOR_BASE' CHANGING GV_ERROR GV_ATWRT.
*
*      SELECT SINGLE B~NAME1
*        INTO GV_ADRC
*        FROM VBPA AS A
*       INNER JOIN ADRC AS B
*          ON A~ADRNR = B~ADDRNUMBER
*       WHERE A~VBELN = LT_0917-VBELN
*         AND A~PARVW = 'WE'
*         AND B~DATE_FROM  <= SY-DATLO
*         AND B~DATE_TO    >= SY-DATLO.
**
*
*      MOVE: GV_ATWRT   TO OD_DATA-VKGRP, "컬러
*            GV_ADRC    TO OD_DATA-MATKL. "납품처명
*
*      APPEND OD_DATA.
*    ENDLOOP.
**
*  ENDLOOP.
*
*  " TMS  요청
*  MOVE '0' TO OD_DATA-LENGTH.
*  MODIFY OD_DATA TRANSPORTING LENGTH
*   WHERE LENGTH EQ ' '.
*
*  MOVE OD_DATA[] TO OD_SAVE[].
*
*  LOOP AT OD_SAVE.
*    MOVE-CORRESPONDING OD_SAVE TO LT_0903.
*    IF OD_SAVE-VGTYP EQ 'V'.
*      MOVE OD_SAVE-VBELN_VL TO LT_0903-VBELN.
*    ENDIF.
*    MOVE 'N' TO LT_0903-STATUS.
*    APPEND LT_0903.
*  ENDLOOP.
*
*  MODIFY ZLET0903 FROM TABLE LT_0903.
*
*  COMMIT WORK.
*
*  DATA: LV_DEST  TYPE ZDEST,
*        LV_GUBUN TYPE ZIFDEST-GUBUN.
*
**  CASE SY-SYSID.
**    WHEN 'R3S'.
**      LV_GUBUN = 'TM'.
**    WHEN 'R3P'.
**      LV_GUBUN = 'SD'.
**********************************************
**    WHEN OTHERS.
*  LV_GUBUN = 'IS'.
*********************************************
*  ENDCASE.

*  " DESTINATION 정보 조회
*  CALL FUNCTION 'Z_IF_DESTINATION'
*    EXPORTING
*      GUBUN                 = LV_GUBUN
*    IMPORTING
*      DEST_NAME             = LV_DEST
*    EXCEPTIONS
*      DESTINATION_NOT_FOUND = 1
*      OTHERS                = 2.
*
*  SORT OD_DATA BY VBELN POSNR.
*
*  " tms 전송
*  CALL FUNCTION 'Z_SD_RFC_TMS_DELIVERY' DESTINATION LV_DEST
*    IMPORTING
*      E_RESULT  = E_RESULT
*      E_MESSAGE = E_MESSAGE
*    TABLES
*      OD_DATA   = OD_DATA
*    EXCEPTIONS
*      ERROR     = 1
*      OTHERS    = 2.
*
*  IF SY-SUBRC EQ 0.
*    " 납품문서별 면적 및 중량 관리 zlet0919 에 저장
*    LOOP AT OD_SAVE.
*      MOVE: OD_SAVE-VBELN TO LT_0919-VBELN,
*                 OD_SAVE-POSNR TO LT_0919-POSNR.
*
*      IF NOT OD_SAVE-WIDTH IS INITIAL AND
*      NOT OD_SAVE-ZLENGTH IS INITIAL AND NOT OD_SAVE-MENGE IS INITIAL.
*        PERFORM CALCULATION_EXCEPTION_HANDING
*        USING OD_SAVE-WIDTH '*' OD_SAVE-ZLENGTH CHANGING LV_MNG.
*        PERFORM CALCULATION_EXCEPTION_HANDING
*        USING LV_MNG '/' 10000 CHANGING LV_MNG.
*        PERFORM CALCULATION_EXCEPTION_HANDING
*        USING LV_MNG '*' OD_SAVE-MENGE CHANGING LT_0919-BRGEW.
*        MOVE 'M2'  TO LT_0919-GEWEI.
*      ENDIF.
*
**       move od_save-pkwei to lt_0919-pkwei.
**       move 'KG' TO LT_0919-PMEINS.
*      COLLECT LT_0919.
*
*    ENDLOOP.
*
*    MODIFY ZLET0919 FROM TABLE LT_0919.
*
*    COMMIT WORK.
*
**___tms  전송 완료 후 tms에 의한 zlet0903 업데이트 여부 체크
**   Update는 RFC Function 'Z_SD_RFC_TMS_DELIVERY_TMS'에서 실행
**   SAP -> TMS -> SAP
*    DO 10 TIMES.
*
*      CLEAR LV_FLAG.
*      LOOP AT LT_ROWS INTO LS_ROWS.
*
*        CLEAR GT_TOP_LEFT.
**
*        READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.
*
*        CASE GC_X.
*
*          WHEN P_RAD1 OR P_RAD2.
*
*            SELECT SINGLE STATUS
*              INTO LV_STATUS
*              FROM ZLET0903
*             WHERE VBELN EQ GT_TOP_LEFT-VBELN.
*
*          WHEN P_RAD3 OR P_RAD3.
*
*            SELECT SINGLE STATUS
*              INTO LV_STATUS
*              FROM ZLET0903
*             WHERE VBELN EQ GT_TOP_LEFT-VBELN
*                   AND POSNR EQ GT_TOP_LEFT-POSNR.
*
*        ENDCASE.
**      " Y는 전송 완료
*        IF SY-SUBRC EQ 0 AND LV_STATUS EQ 'Y'.
*          MOVE ICON_TRANSFER TO GT_TOP_LEFT-ICON.
*        ELSE.
*          MOVE ICON_WF_WORKITEM_WAITING TO GT_TOP_LEFT-ICON.
*          LV_FLAG = GC_X.
*        ENDIF.
*
*        REFRESH GT_TOP_LEFT-CELLTAB. CLEAR GT_TOP_LEFT-CELLTAB.
*        PERFORM MODIFY_CELL_ATTRIBUTE
*        USING GC_NO_EDIT ' ' CHANGING GT_TOP_LEFT-CELLTAB.
*
*        MODIFY GT_TOP_LEFT INDEX LS_ROWS-INDEX TRANSPORTING ICON CELLTAB.
*
*      ENDLOOP.
*
*      IF LV_FLAG IS INITIAL.
*        EXIT.
*      ELSE.
*        WAIT UP TO 1 SECONDS.
*      ENDIF.
*
*    ENDDO.
*
*    MESSAGE S001 WITH 'TMS 전송 완료' DISPLAY LIKE GC_S.
*
*  ELSE.
*    MESSAGE S001 WITH 'TMS 전송 중 에러'  DISPLAY LIKE GC_E.
*  ENDIF.
*
*  REFRESH: GT_TOP_RIGHT, GT_BOTTOM_LEFT, GT_BOTTOM_RIGHT.
*
*  CASE GC_X.
*    WHEN P_RAD1 OR P_RAD2.
*
*      SORT GT_TOP_LEFT BY VBELN POSNR.
*      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
*      SORT GT_TOP_RIGHT BY VBELN DELIDN.
*      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
*    WHEN P_RAD3 OR P_RAD4.
*      SORT GT_TOP_LEFT BY SHSRQ.
*      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
*      SORT GT_TOP_RIGHT BY VBELN DELIDN.
*      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
*  ENDCASE.
*
*  PERFORM REFRESH_GRID USING GC_ALV_GRID1.
*  PERFORM REFRESH_GRID USING GC_ALV_GRID2.
*  PERFORM REFRESH_GRID USING GC_ALV_GRID3.
*  PERFORM REFRESH_GRID USING GC_ALV_GRID4.

ENDFORM.                    " SEND_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  CREATE_ICON_0903
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0917_VBELN  text
*      <--P_GT_TOP_RIGHT_ICON  text
*----------------------------------------------------------------------*
FORM CREATE_ICON_0903  USING    PV_VBELN
                                                      PV_CHANGE_ICON
                       CHANGING PV_ICON.

  DATA: LS_0903 LIKE ZLET0903.

  SELECT SINGLE *
       INTO LS_0903
     FROM ZLET0903
   WHERE VBELN = PV_VBELN.

*{ 기능개선 167496 - 변경
  IF SY-SUBRC EQ 0 AND SY-TCODE <> GC_TCODE2.
*  IF sy-subrc EQ 0.
*} 기능개선 167496 - 변경
    IF  LS_0903-STATUS EQ 'Y'.
      MOVE ICON_TRANSFER TO PV_ICON.
    ELSEIF LS_0903-STATUS EQ 'N'.
      MOVE ICON_WF_WORKITEM_WAITING TO PV_ICON.
    ENDIF.
  ELSE.
    IF NOT PV_CHANGE_ICON IS INITIAL.
      MOVE PV_CHANGE_ICON TO PV_ICON.
    ENDIF.
  ENDIF.

ENDFORM.                    " CREATE_ICON_0903
*&---------------------------------------------------------------------*
*&      Form  CREATE_ICON_0903_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0917_VBELN  text
*      <--P_GT_TOP_RIGHT_ICON  text
*----------------------------------------------------------------------*
FORM CREATE_ICON_0903_TWO USING    PV_VBELN
                                  PV_POSNR
                                  PV_CHANGE_ICON
                         CHANGING PV_ICON.

  DATA: LS_0903 LIKE ZLET0903.

  SELECT SINGLE *
       INTO LS_0903
     FROM ZLET0903
   WHERE VBELN = PV_VBELN
        AND POSNR EQ PV_POSNR.

  IF SY-SUBRC EQ 0.
    IF  LS_0903-STATUS EQ 'Y'.
      MOVE ICON_TRANSFER TO PV_ICON.
    ELSEIF LS_0903-STATUS EQ 'N'.
      MOVE ICON_WF_WORKITEM_WAITING TO PV_ICON.
    ENDIF.
  ELSE.
    IF NOT PV_CHANGE_ICON IS INITIAL.
      MOVE PV_CHANGE_ICON TO PV_ICON.
    ENDIF.
  ENDIF.

ENDFORM.                    " CREATE_ICON_0903_TWO
*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_DYNDOC_ID  text
*----------------------------------------------------------------------*
FORM EVENT_TOP_OF_PAGE
USING    P_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT P_GRID.

  DATA: LV_INDEX TYPE CHAR5.

  CASE P_GRID.

    WHEN GC_ALV_GRID1.

      LV_INDEX = LINES( GT_TOP_LEFT[] ).
      CONCATENATE '☞ 납품문서 헤더' '(' LV_INDEX ') 건'
      INTO GV_TEXT.
      PERFORM ADD_TOP_PAGE USING P_DYNDOC_ID GV_TEXT P_GRID.

    WHEN GC_ALV_GRID2.

      LV_INDEX = LINES( GT_TOP_RIGHT[] ).
      CONCATENATE '☞ 포장 정보(합계)' '(' LV_INDEX ') 건'
      INTO GV_TEXT.
      PERFORM ADD_TOP_PAGE USING P_DYNDOC_ID GV_TEXT P_GRID.

    WHEN GC_ALV_GRID3.

      LV_INDEX = LINES( GT_BOTTOM_LEFT[] ).
      CONCATENATE '☞ 납품문서 아이템' '(' LV_INDEX ') 건'
      INTO GV_TEXT.
      PERFORM ADD_TOP_PAGE USING P_DYNDOC_ID GV_TEXT P_GRID.

    WHEN GC_ALV_GRID4.

      LV_INDEX = LINES( GT_BOTTOM_RIGHT[] ).
      CONCATENATE '☞ 포장 정보(디테일)' '(' LV_INDEX ') 건'
      INTO GV_TEXT.
      PERFORM ADD_TOP_PAGE USING P_DYNDOC_ID GV_TEXT P_GRID.

  ENDCASE.

ENDFORM.                    " EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  ADD_TOP_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_TEXT  text
*----------------------------------------------------------------------*
FORM ADD_TOP_PAGE
USING  P_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT  PV_TEXT P_GRID.

  DATA :TOP_MESSAGE TYPE C LENGTH 255.

  CLEAR : TOP_MESSAGE.
  MOVE PV_TEXT TO TOP_MESSAGE.

  CALL METHOD P_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = TOP_MESSAGE
      SAP_STYLE    = SPACE
      SAP_COLOR    = SPACE
      SAP_FONTSIZE = CL_DD_DOCUMENT=>LARGE
      SAP_EMPHASIS = SPACE
      STYLE_CLASS  = SPACE.

** "" add_text 및 new_line 으로 추가된 텍스트를 탑오브페이지에 추가
  CALL METHOD P_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      REUSE_CONTROL      = 'X'
      PARENT             = P_GRID "표시할 컨테이너부분
    EXCEPTIONS
      HTML_DISPLAY_ERROR = 1.

ENDFORM.                    " ADD_TOP_PAGE
*&---------------------------------------------------------------------*
*&      Form  make_save_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_SAVE_DATA TABLES PT_INSERT STRUCTURE ZLET0917
                              USING  PT_ROWS TYPE LVC_T_ROW
                               CHANGING PV_ERROR
                                                 PV_TEXT.

  DATA: LT_ROWS    TYPE LVC_T_ROW,
        LS_ROWS    TYPE LVC_S_ROW,
        LT_TLIPS   LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_E1CUVAL LIKE E1CUVAL OCCURS 0 WITH HEADER LINE.

  DATA: LT_BOTTOM LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.
  DATA: LT_DATA    LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.

  REFRESH PT_INSERT. CLEAR PT_INSERT.

  SORT GT_VTTK BY VBELN.
  SORT GT_LIPS BY VBELN POSNR.
  SORT GT_LIKP BY VBELN.
*  SORT gt_top_left BY vbeln posnr.
  SORT GT_TOP_RIGHT BY VBELN DELIDN.
  SORT GT_BOTTOM_LEFT BY VBELN POSNR.
  SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.

  MOVE GT_BOTTOM_RIGHT[] TO LT_BOTTOM[].

  " dummy data 구성
  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.

    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    LOOP AT GT_LIPS WHERE VBELN EQ GT_TOP_LEFT-VBELN.
      CLEAR LT_BOTTOM.
      READ TABLE LT_BOTTOM WITH KEY VBELN = GT_LIPS-VBELN
                                                  POSNR = GT_LIPS-POSNR
                                     BINARY SEARCH.
      CHECK SY-SUBRC <> 0.

      MOVE: GT_LIPS-VBELN TO LT_DATA-VBELN,
                GT_LIPS-POSNR TO LT_DATA-POSNR,
                '000001'           TO LT_DATA-DELIDN,
                'X' TO LT_DATA-XLOEK.
      APPEND LT_DATA.
    ENDLOOP.

  ENDLOOP.

  APPEND LINES OF LT_DATA TO LT_BOTTOM.
  SORT LT_BOTTOM BY VBELN POSNR DELIDN.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.

    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    LOOP AT LT_BOTTOM WHERE VBELN EQ GT_TOP_LEFT-VBELN.

      CASE GC_X.

        WHEN P_RAD1 OR P_RAD2.

          CLEAR GT_TOP_LEFT.
          READ TABLE GT_TOP_LEFT WITH KEY VBELN = LT_BOTTOM-VBELN.


        WHEN P_RAD3 OR P_RAD4.

          CHECK GT_TOP_LEFT-POSNR EQ LT_BOTTOM-POSNR.

          CLEAR GT_TOP_LEFT.
          READ TABLE GT_TOP_LEFT WITH KEY VBELN = LT_BOTTOM-VBELN
                                         POSNR = LT_BOTTOM-POSNR.

      ENDCASE.

      "  Read 1 ALV


      "  Read 2 ALV
      CLEAR GT_TOP_RIGHT.
      READ TABLE GT_TOP_RIGHT WITH KEY VBELN  = LT_BOTTOM-VBELN
                                       DELIDN = LT_BOTTOM-DELIDN
                                       BINARY SEARCH.

      "  Read 3 ALV
      CLEAR GT_BOTTOM_LEFT.
      READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = LT_BOTTOM-VBELN
                                         POSNR = LT_BOTTOM-POSNR
                                         BINARY SEARCH.

      "  Read Delivery
      CLEAR GT_LIPS.
      READ TABLE GT_LIPS WITH KEY VBELN = LT_BOTTOM-VBELN
                                  POSNR = LT_BOTTOM-POSNR
                                  BINARY SEARCH.


      " 판매오더유형, 영업조직, 유통경로,  영업팀, 영업그룹, Spart
      CLEAR GT_VBAK.
      READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                  BINARY SEARCH.

      " Werks
      MOVE GT_BOTTOM_LEFT-WERKS TO PT_INSERT-WERKS.
**********************************************************************************
      "TMS 미전송일 경우
      IF P_RAD1 = 'X'.

        " 납품문서의 출하지점을 orhshp(원 출하지점) 으로 이동
        MOVE GT_TOP_LEFT-VSTEL  TO PT_INSERT-ORGSHP.

        " 입력한 실제 출하지점을 vstel(실제 출하지점) 으로 이동
        MOVE GT_TOP_LEFT-ORGSHP TO PT_INSERT-VSTEL.


      ELSE.

        " 납품문서의 출하지점을 vstel(실제 출하지점)으로 복사
        MOVE GT_TOP_LEFT-VSTEL  TO PT_INSERT-VSTEL.

        " 납품문서의 출하지점을 orhshp(원 출하지점)으로 복사
        MOVE GT_TOP_LEFT-VSTEL  TO PT_INSERT-ORGSHP.

      ENDIF.

      " 실제 출하 지점의 사업장 재탐색
      SELECT SINGLE BZAREA
               INTO PT_INSERT-BZAREA
               FROM ZLET0033
              WHERE VSTEL EQ PT_INSERT-VSTEL.
*      "  거점
*      MOVE gt_top_left-bzarea TO pt_insert-bzarea.

*      " 원출하지점 orgshp
*      MOVE gt_top_left-vstel TO pt_insert-orgshp.
*
*      "  실제 출하 지점.
*      MOVE gt_top_left-orgshp TO pt_insert-vstel.

**********************************************************************************
      "  추가출하지점.  addshp
      MOVE GT_TOP_LEFT-ADDSHP TO PT_INSERT-ADDSHP.

      "  Planning Point(운송계획지점)
      CLEAR GT_VTTK.
      READ TABLE GT_VTTK WITH KEY VBELN = GT_LIKP-VBELN
                                 BINARY SEARCH.

      MOVE GT_VTTK-TPLST TO PT_INSERT-TPLST.

      " Doc Section C:Delivery Simulation Order,V:Container Simulation
      MOVE GT_TOP_LEFT-VGTYP TO PT_INSERT-VGTYP.

      " 'Shipment Type
      MOVE GT_TOP_LEFT-SHTYP TO PT_INSERT-SHTYP.

      " Shipping type(선배송, 택배, 직납, 기타..)
      MOVE GT_TOP_LEFT-VSART TO PT_INSERT-VSART.

      "  출하조건
      MOVE GT_TOP_LEFT-VSBED TO PT_INSERT-VSBED.

      "  서비스레벨
      MOVE GT_TOP_LEFT-BFART TO PT_INSERT-BFART.

      "  인도조건
      MOVE GT_TOP_LEFT-INCO1 TO PT_INSERT-INCO1.

      "  경유 여부
      MOVE GT_TOP_LEFT-TRFLG   TO PT_INSERT-TRFLG.

      " Delivery
      MOVE LT_BOTTOM-VBELN TO PT_INSERT-VBELN.

      "  Delivery iltem
      MOVE LT_BOTTOM-POSNR TO PT_INSERT-POSNR.

      "  Delivery iltem  detail DELIDN      .
      MOVE LT_BOTTOM-DELIDN TO PT_INSERT-DELIDN.

      " 우편번호, 주소, 운송지역
      MOVE: GT_TOP_LEFT-KUNNR        TO PT_INSERT-KUNNR,
                 GT_TOP_LEFT-POST_CODE1 TO PT_INSERT-POST_CODE1,
                 GT_TOP_LEFT-STREET TO PT_INSERT-STREET.

      " SAP루트(운송경로)
      MOVE GT_TOP_LEFT-ROUTE TO PT_INSERT-ROUTE.

      " 혼적불가여부(혼적불가:V, 혼적가능:' ')
      MOVE GT_TOP_LEFT-MIXLOD TO PT_INSERT-MIXLOD.

      "긴급도(0~9)
      MOVE GT_TOP_LEFT-URGNT TO PT_INSERT-URGNT.

      IF PT_INSERT-URGNT EQ ' '.
        MOVE '0' TO PT_INSERT-URGNT.
      ENDIF.

      "TMS루트키   RUTEKY
      MOVE 'TMS' TO PT_INSERT-RUTEKY.

      "출하요청일
      MOVE GT_TOP_LEFT-WADAT TO PT_INSERT-WADAT.
      "배송요청일
      MOVE GT_TOP_LEFT-LFDAT TO PT_INSERT-LFDAT.
      "배송요청시간
      MOVE GT_TOP_LEFT-LFUHR TO PT_INSERT-LFUHR.

      " Sales Order No
      MOVE GT_BOTTOM_LEFT-VBELN_VL TO PT_INSERT-VBELN_VL.
      " Sales Item No
      MOVE GT_BOTTOM_LEFT-POSNR_VL TO PT_INSERT-POSNR_VL.

      "  판매처
      MOVE GT_TOP_LEFT-KUNAG TO PT_INSERT-KUNAG.

      " 판매오더유형, 영업조직, 유통경로,  영업팀, 영업그룹, Spart
      MOVE GT_VBAK-AUART TO PT_INSERT-AUART.
      MOVE GT_VBAK-VKORG TO PT_INSERT-VKORG.
      MOVE GT_VBAK-VTWEG TO PT_INSERT-VTWEG.
      MOVE GT_VBAK-VKBUR TO PT_INSERT-VKBUR.
      MOVE GT_VBAK-VKGRP TO PT_INSERT-VKGRP.
      MOVE GT_VBAK-SPART TO PT_INSERT-SPART.

      " 출하 요청 텍스트 GRTXT
      MOVE GT_TOP_LEFT-GRTXT TO PT_INSERT-GRTXT.
      " Material Group, Lot Number(배치번호)

      " Material Code, Desc
      MOVE: GT_BOTTOM_LEFT-MATNR TO PT_INSERT-MATNR,
                 GT_BOTTOM_LEFT-ARKTX  TO PT_INSERT-ARKTX.

      " 조장
      MOVE: GT_BOTTOM_LEFT-LENGTH TO PT_INSERT-LENGTH.

      " 조장 수
      MOVE: GT_BOTTOM_LEFT-FACTOR TO PT_INSERT-FACTOR.

      "  delivery qty, uom, weight, weight uom, net weight
      MOVE: GT_BOTTOM_LEFT-LFIMG TO PT_INSERT-LFIMG,  " delivery qty,
        GT_BOTTOM_LEFT-VRKME TO PT_INSERT-MEINS,  " delivery uom
        GT_BOTTOM_LEFT-BRGEW  TO PT_INSERT-BRGEW,  " Weight
        GT_BOTTOM_LEFT-GEWEI TO PT_INSERT-GEWEI,  " Weight Uom
        GT_BOTTOM_LEFT-NTGEW TO PT_INSERT-NTGEW.  " Net Weight
*          GT_LIps-gewei TO pt_insert-newei.  " Net Weight UOM


      " 포장재 타입(유형
      MOVE LT_BOTTOM-PKTYP TO PT_INSERT-PKTYP.

      "포장재 자재코드
      MOVE LT_BOTTOM-PKMATNR TO PT_INSERT-PKMATNR.

      "드럼 기호
      MOVE LT_BOTTOM-DMMATNR TO PT_INSERT-DMMATNR.

      "포장재 코드 수량
      MOVE LT_BOTTOM-MENGE TO PT_INSERT-MENGE.

      "단위
      MOVE LT_BOTTOM-ZMEINS TO PT_INSERT-ZMEINS.

      "폭
      MOVE LT_BOTTOM-WIDTH TO PT_INSERT-WIDTH.

      "길이
      MOVE LT_BOTTOM-ZLENGTH TO PT_INSERT-ZLENGTH.

      "높이
      MOVE LT_BOTTOM-HEIGHT TO PT_INSERT-HEIGHT.

      "포장재 무게
      MOVE LT_BOTTOM-PKWEI TO PT_INSERT-PKWEI.

      "포장재 단위
      MOVE LT_BOTTOM-PMEINS TO PT_INSERT-PMEINS.

      "적재단수:(적재단수필드에 값이 있으면 M2계산)
      MOVE GT_BOTTOM_LEFT-FLTLVL TO PT_INSERT-FLTLVL.
      " 혼적불가, 톤수제한 Ranges
      " 차량 정보
*      CLEAR gt_0013.
*      READ TABLE gt_0013 WITH KEY vstel  = gt_likp-vstel
*                                        kunnr = gt_likp-kunnr
*                          BINARY SEARCH.
*
*      IF sy-subrc EQ 0.
      MOVE: GT_TOP_LEFT-MIXLOD  TO PT_INSERT-MIXLOD,
            GT_TOP_LEFT-VHCTYP  TO PT_INSERT-VHCTYP,
            GT_TOP_LEFT-VHCINEQ TO PT_INSERT-VHCINEQ,
            GT_TOP_LEFT-CONTY   TO PT_INSERT-CONTY,
            GT_TOP_LEFT-CONSZ   TO PT_INSERT-CONSZ.
*      ELSE.
*      ENDIF.

      "  운송사 코드
      MOVE GT_TOP_LEFT-TDLNR TO PT_INSERT-TDLNR.
      " 차량번호
      MOVE GT_TOP_LEFT-EXTI1 TO PT_INSERT-EXTI1.
      " 기사명
      MOVE GT_TOP_LEFT-EXTI2 TO PT_INSERT-EXTI2.
      " 기사전화번호
      MOVE GT_TOP_LEFT-TPBEZ TO PT_INSERT-TPBEZ.
      "   컨테이너 시뮬레이션 요청번호
      MOVE GT_TOP_LEFT-SHSRQ TO PT_INSERT-SHSRQ.
      "Delivery 확정여부(확정:V, 미확정:' ')
      " 오더분할코드
*ETC001
      MOVE LT_BOTTOM-PMEINS  TO PT_INSERT-ETC001.
      MOVE LT_BOTTOM-DMMATNR TO PT_INSERT-ETC002.
      MOVE LT_BOTTOM-XLOEK   TO PT_INSERT-XLOEK.
*ETC002
*ETC003
*ETC004
*ETC005
*ETC006
*ETC007
*ETC008
*ETC009
*ETC010
*ETC011
*ETC012
*ETC013
*ETC014
*ETC015
*ETC016
*ETC017
*ETC018
*ETC019
*ETC020

      "  Default N, 처리 완료시 Y로 변경

      MOVE:  'N'                  TO PT_INSERT-IFFLG.

      " LOG
*{ 기능개선 159419 - 변경
      SELECT SINGLE ERDAT
                    ERZET
                    ERNAM
        INTO (PT_INSERT-ERDAT, PT_INSERT-ERZET,
              PT_INSERT-ERNAM)
        FROM ZLET0917
       WHERE VBELN  = PT_INSERT-VBELN
         AND POSNR  = PT_INSERT-POSNR
         AND DELIDN = PT_INSERT-DELIDN.

      IF PT_INSERT-ERDAT IS INITIAL.
        PT_INSERT-ERDAT = SY-DATUM.
        PT_INSERT-ERZET = SY-UZEIT.
        PT_INSERT-ERNAM = SY-UNAME.
      ENDIF.

      PT_INSERT-AEDAT = SY-DATUM.
      PT_INSERT-AEZET = SY-UZEIT.
      PT_INSERT-AENAM = SY-UNAME.

*      MOVE: sy-datum TO pt_insert-erdat,
*            sy-uzeit TO pt_insert-erzet,
*            sy-uname TO pt_insert-ernam,
*            sy-datum TO pt_insert-aedat,
*            sy-uzeit TO pt_insert-aezet,
*            sy-uname TO pt_insert-aenam.
*} 기능개선 159419 - 변경

      APPEND PT_INSERT.   CLEAR PT_INSERT.

    ENDLOOP.

  ENDLOOP.

  SORT PT_INSERT BY VBELN POSNR.

  IF PT_INSERT[] IS INITIAL.
    MOVE '저장할 대상이 없습니다.' TO PV_TEXT.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " make_save_data
*&---------------------------------------------------------------------*
*&      Form  INSERT_ZLET0917
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_INSERT  text
*      -->P_LT_ROWS  text
*      -->P_GV_SUBRC  text
*      -->P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM INSERT_ZLET0917  TABLES PT_INSERT STRUCTURE ZLET0917.

  DATA: LV_CHAR(5).

  LOOP AT PT_INSERT.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.

        DELETE FROM ZLET0917 WHERE VBELN EQ PT_INSERT-VBELN.

      WHEN P_RAD3 OR P_RAD4.

        DELETE FROM ZLET0917 WHERE VBELN EQ PT_INSERT-VBELN
                             AND POSNR EQ PT_INSERT-POSNR.

    ENDCASE.
  ENDLOOP.

  MODIFY ZLET0917 FROM TABLE PT_INSERT.

  LV_CHAR = LINES( PT_INSERT[] ).
  MESSAGE S002 WITH LV_CHAR '건을 생성' DISPLAY LIKE GC_S.

ENDFORM.                    " INSERT_ZLET0917
*&---------------------------------------------------------------------*
*&      Form  MODIFY_GRID_CELLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOP_LEFT  text
*      -->P_GC_ALV_GRID1  text
*      -->P_GT_TOP_LEFT_VBELN  text
*----------------------------------------------------------------------*
FORM MODIFY_GRID_CELLS USING PT_TOP_LEFT TYPE STANDARD TABLE
                                  PV_GRID1 TYPE REF TO CL_GUI_ALV_GRID
                                  PV_VBELN.

  FIELD-SYMBOLS <FS>.
  FIELD-SYMBOLS <FS_VBELN>.
  FIELD-SYMBOLS <FS_ICON>.

  DATA: PT_GOOD_CELLS  TYPE LVC_T_MODI.
  DATA: PS_DELTA_CELLS TYPE LVC_S_MODI.

  CHECK NOT PT_TOP_LEFT[] IS INITIAL.

  LOOP AT PT_TOP_LEFT ASSIGNING <FS>.

    MOVE SY-TABIX TO GV_TABIX.

    UNASSIGN <FS_VBELN>.
    ASSIGN COMPONENT 'VBELN' OF STRUCTURE <FS> TO <FS_VBELN>.

    UNASSIGN <FS_ICON>.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <FS> TO <FS_ICON>.

    CHECK <FS_VBELN> IS ASSIGNED.

    CHECK PV_VBELN EQ <FS_VBELN>.
    CHECK NOT <FS_ICON> EQ ICON_LED_INACTIVE.

    MOVE GV_TABIX TO PS_DELTA_CELLS-ROW_ID.
    MOVE ICON_YELLOW_LIGHT TO PS_DELTA_CELLS-VALUE.
    MOVE 'ICON' TO PS_DELTA_CELLS-FIELDNAME.
    APPEND PS_DELTA_CELLS TO PT_GOOD_CELLS.

  ENDLOOP.

  CALL METHOD PV_GRID1->SET_DELTA_CELLS
    EXPORTING
      IT_DELTA_CELLS = PT_GOOD_CELLS
      I_MODIFIED     = 'X'.

ENDFORM.                    " MODIFY_GRID_CELLS
*&---------------------------------------------------------------------*
*&      Form  MODIFY_GRID_CELLS_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOP_LEFT  text
*      -->P_GC_ALV_GRID1  text
*      -->P_GT_TOP_LEFT_VBELN  text
*----------------------------------------------------------------------*
FORM MODIFY_GRID_CELLS_TWO USING PT_TOP_LEFT TYPE STANDARD TABLE
                              PV_GRID1 TYPE REF TO CL_GUI_ALV_GRID
                              PV_SHSRQ.


  FIELD-SYMBOLS <FS>.
  FIELD-SYMBOLS <FS_ICON>.
  FIELD-SYMBOLS <FS_SHSRQ>.

  DATA: PT_GOOD_CELLS  TYPE LVC_T_MODI.
  DATA: PS_DELTA_CELLS TYPE LVC_S_MODI.

  CHECK NOT PT_TOP_LEFT[] IS INITIAL.

  LOOP AT PT_TOP_LEFT ASSIGNING <FS>.

    MOVE SY-TABIX TO GV_TABIX.

    UNASSIGN <FS_SHSRQ>.
    ASSIGN COMPONENT 'SHSRQ' OF STRUCTURE <FS> TO <FS_SHSRQ>.

    UNASSIGN <FS_ICON>.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <FS> TO <FS_ICON>.

    CHECK <FS_SHSRQ> IS ASSIGNED.

    CHECK PV_SHSRQ EQ <FS_SHSRQ>.
    CHECK NOT <FS_ICON> EQ ICON_LED_INACTIVE.

    MOVE GV_TABIX TO PS_DELTA_CELLS-ROW_ID.
    MOVE ICON_YELLOW_LIGHT TO PS_DELTA_CELLS-VALUE.
    MOVE 'ICON' TO PS_DELTA_CELLS-FIELDNAME.
    APPEND PS_DELTA_CELLS TO PT_GOOD_CELLS.

  ENDLOOP.

  CALL METHOD PV_GRID1->SET_DELTA_CELLS
    EXPORTING
      IT_DELTA_CELLS = PT_GOOD_CELLS
      I_MODIFIED     = 'X'.

ENDFORM.                    " MODIFY_GRID_CELLS_TWO
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_CELLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DELTA_CELLS[]  text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGE_CELLS  USING PT_DELTA_CELLS TYPE LVC_T_MODI
                                  PV_GRID1 TYPE REF TO CL_GUI_ALV_GRID.

  CALL METHOD PV_GRID1->SET_DELTA_CELLS
    EXPORTING
      IT_DELTA_CELLS = PT_DELTA_CELLS
      I_MODIFIED     = 'X'.

ENDFORM.                    " DISPLAY_CHANGE_CELLS
*&---------------------------------------------------------------------*
*&      Form  ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5270   text
*      -->P_LS_MOD_CELLS  text
*----------------------------------------------------------------------*
FORM ADD_PROTOCOL_ENTRY
USING DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                        PV_TEXT
                                        PS_MOD_CELLS TYPE LVC_S_MODI.

  CALL METHOD DATA_CHANGED->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = 'ZSD1'
      I_MSGNO     = '001'
      I_MSGTY     = 'E'
      I_MSGV1     = PV_TEXT
*     I_MSGV2     = P_WERKS
*     I_MSGV3     = '만 입력 가능합니다.'
      I_FIELDNAME = PS_MOD_CELLS-FIELDNAME
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID.

ENDFORM.                    " ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_ICON_YELLOW_LIGHT  text
*----------------------------------------------------------------------*
FORM MODIFY_CELL
USING    DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PS_MOD_CELLS    TYPE LVC_S_MODI
                                PV_FIELDNAME
                                PV_VALUE .

  CALL METHOD DATA_CHANGED->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = PV_FIELDNAME
      I_VALUE     = PV_VALUE.

ENDFORM.                    " MODIFY_CELL
*&---------------------------------------------------------------------*
*&      Form  MODIFY_STYLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_ICON_YELLOW_LIGHT  text
*----------------------------------------------------------------------*
FORM MODIFY_STYLE
USING    DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                      PS_MOD_CELLS    TYPE LVC_S_MODI
                                      PV_FIELDNAME
                                      PV_VALUE .

  CALL METHOD DATA_CHANGED->MODIFY_STYLE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = PV_FIELDNAME
      I_STYLE     = PV_VALUE.

ENDFORM.                    " MODIFY_STYLE
*&---------------------------------------------------------------------*
*&      Form  GET_CELL_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_ICON_YELLOW_LIGHT  text
*----------------------------------------------------------------------*
FORM GET_CELL_VALUE
USING  DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                          PS_MOD_CELLS TYPE LVC_S_MODI
                                          PV_FIELDNAME
                                          PV_VALUE .

  CALL METHOD DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = PV_FIELDNAME
    IMPORTING
      E_VALUE     = PV_VALUE.

ENDFORM.                    " GET_CELL_VALUE
*&---------------------------------------------------------------------*
*&      Form  CHEATE_DELTA_CELLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA_CHANGED  text
*      -->P_5528   text
*      -->P_LS_MOD_CELLS_VALUE  text
*----------------------------------------------------------------------*
FORM CHEATE_DELTA_CELLS_TOP
USING DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                      FIELDNAME
                                      PS_MOD_CELLS    TYPE LVC_S_MODI
                                      PS_MOD_VALUE
                                      PS_TABLE LIKE GT_TOP_RIGHT
                                      PV_TYPE.

  FIELD-SYMBOLS <FS>.

  DATA: LT_BOTTOM LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.
  DATA: LT_TOP LIKE GT_TOP_RIGHT OCCURS 0 WITH HEADER LINE.

  MOVE GT_BOTTOM_RIGHT[] TO LT_BOTTOM[].
  SORT LT_BOTTOM BY VBELN PKTYP PKMATNR.

  MOVE GT_TOP_RIGHT[] TO LT_TOP[].
  SORT LT_TOP BY VBELN PKTYP PKMATNR.

  CASE PV_TYPE.
      " 수정한 된 납품문서는 품목 전체를 수정 신호등(노란색신호등
      " 으로 변경한다.
    WHEN 'GRID2'.

      CLEAR LT_BOTTOM.
      READ TABLE LT_BOTTOM WITH KEY VBELN    = PS_TABLE-VBELN
*                                      pktyp     = ps_table-pktyp
*                                      pkmatnr = ps_table-pkmatnr
                                         BINARY SEARCH.

      CHECK SY-SUBRC EQ 0.

      LOOP AT LT_BOTTOM FROM SY-TABIX.

        CHECK LT_BOTTOM-ICON <> ICON_YELLOW_LIGHT.

        MOVE SY-TABIX TO GV_TABIX.

        UNASSIGN <FS>.

        IF LT_BOTTOM-VBELN <> PS_TABLE-VBELN.
*       OR lt_bottom-pktyp <> ps_table-pktyp
*       OR lt_bottom-pkmatnr <> ps_table-pkmatnr.
          RETURN.
        ENDIF.

*        MOVE gv_tabix TO gs_delta_cells-row_id.
*        MOVE ps_mod_value TO gs_delta_cells-value.
*        MOVE fieldname TO gs_delta_cells-fieldname.
*        APPEND gs_delta_cells TO gt_delta_cells.

        MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
        MOVE ICON_YELLOW_LIGHT TO GS_DELTA_CELLS-VALUE.
        MOVE 'ICON' TO GS_DELTA_CELLS-FIELDNAME.
        APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.

      ENDLOOP.

    WHEN 'GRID4'.
      " 수정한 된 납품문서는 품목 전체를 수정 신호등(노란색신호등
      " 으로 변경한다.
      CLEAR LT_TOP.
      READ TABLE LT_TOP WITH KEY VBELN    = PS_TABLE-VBELN
                                     BINARY SEARCH.

      CHECK SY-SUBRC EQ 0.

      LOOP AT LT_TOP FROM SY-TABIX.

        CHECK LT_BOTTOM-ICON <> ICON_YELLOW_LIGHT.

        MOVE SY-TABIX TO GV_TABIX.

        UNASSIGN <FS>.

        IF LT_TOP-VBELN <> PS_TABLE-VBELN.
          RETURN.
        ENDIF.

*        MOVE gv_tabix TO gs_delta_cells-row_id.
*        MOVE ps_mod_value TO gs_delta_cells-value.
*        MOVE fieldname TO gs_delta_cells-fieldname.
*        APPEND gs_delta_cells TO gt_delta_cells.

        MOVE GV_TABIX TO GS_DELTA_CELLS-ROW_ID.
        MOVE ICON_YELLOW_LIGHT TO GS_DELTA_CELLS-VALUE.
        MOVE 'ICON' TO GS_DELTA_CELLS-FIELDNAME.
        APPEND GS_DELTA_CELLS TO GT_DELTA_CELLS.

      ENDLOOP.

  ENDCASE.

ENDFORM.                    " CHEATE_DELTA_CELLS
*&---------------------------------------------------------------------*
*&      Form  GET_PKKTX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PKKTX .

  REFRESH GT_AREA.

  SORT GT_BOTTOM_LEFT BY VBELN POSNR.

  CHECK P_RAD1 EQ GC_X OR  P_RAD3 EQ GC_X.


  "  Spart '20' 의 마스터 데이타
  PERFORM GET_MASTER_20 TABLES GT_0210 CHANGING GV_ERROR.
  DATA(LT_SPART) = S_SPART[].
  SORT LT_SPART BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_SPART COMPARING LOW.
  LOOP AT LT_SPART INTO DATA(LS_SPART).

    CASE LS_SPART-LOW.
      WHEN '10'.
**************** Case 1 제품군 1. 제품군 10(팔레트 적재) ******** ***
        PERFORM GET_PACKING_SPART_10.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 10' 40.
**************** Case 1 제품군 1. 제품군 10(팔레트 적재) ************
      WHEN '20'.
**************** Case 2. 제품군 20(드럼)*************************
        PERFORM GET_PACKING_SPART_20.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 20' '44'.
**************** Case 2. 제품군 20(드럼)*************************
      WHEN '21'.
**************** Case 3. 3. 제품군 21(다발, 합판보빈을 팔레트 적재,
        PERFORM GET_PACKING_SPART_21.
        PERFORM SAPGUI_PROGRESS_INDICATOR
        USING '제품군 21' '48'.
**************** Case 3. 3. 제품군 21(다발, 합판보빈을 팔레트
      WHEN '22'.
**************** Case 4 제품군 22(다발, 합판보빈을 팔레트 적재
        PERFORM GET_PACKING_SPART_22.
        PERFORM SAPGUI_PROGRESS_INDICATOR
        USING '제품군 22' '52'.
**************** Case 4 제품군 22(다발, 합판보빈을 팔레트 적재,
      WHEN '23'.
**************** Case 5 제품군 23(다발 팔레트 적재) *************
        PERFORM GET_PACKING_SPART_23.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 23' '56'.
**************** Case 5 제품군 23(다발 팔레트 적재) *************
      WHEN '24'.
**************** Case 6. 제품군 24(드럼 적재*******************
        PERFORM GET_PACKING_SPART_24.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 24' '60'.
**************** Case 6. 제품군 24(드럼 적재 ****************
      WHEN '30'.
**************** Case 8. 제품군 30(철드럼, 목드럼 적재)********
        PERFORM GET_PACKING_SPART_30.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 30' '68'.
**************** Case 8. 제품군 30(철드럼, 목드럼 적재)*****
      WHEN '31'.
**************** Case 9. 제품군 31(철드럼, 목드럼 적재)************
        PERFORM GET_PACKING_SPART_31.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 31' '72'.
**************** Case 9. 제품군 31(철드럼, 목드럼 적재)************
      WHEN '32'.
**************** Case 10. 제품군 32(목박스 적재*****************
        PERFORM GET_PACKING_SPART_32.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 32' '76'.
**************** Case 10. 제품군 32(목박스 적재)*****************
      WHEN '40'.
**************** Case 11. 제품군 40(팔레트 적재)***************
        PERFORM GET_PACKING_SPART_40.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 40' '80'.
**************** Case 11. 제품군 40(팔레트 적재)*****************
      WHEN '41'.
**************** Case 12. 제품군 41(드럼, 팔레트 적재)***********
        PERFORM GET_PACKING_SPART_41.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 41' '84'.
**************** Case 12. 제품군 41(드럼, 팔레트 적재)**********
      WHEN '43'.
**************** Case 13. 제품군 43(박스로 팔레트 적재)**********
        PERFORM GET_PACKING_SPART_43.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 43' '88'.
**************** Case 13. 제품군 43(박스로 팔레트 적재)*********
      WHEN '44'.
**************** Case 14. 제품군 44(드럼 적재)****************
        PERFORM GET_PACKING_SPART_44.
        PERFORM SAPGUI_PROGRESS_INDICATOR USING '제품군 44' '100'.
**************** Case 14. 제품군 44(드럼 적재)****************
    ENDCASE.

  ENDLOOP.

  SORT GT_AREA BY VBELN POSNR.

ENDFORM.                    " GET_PKKTX
*&---------------------------------------------------------------------*
*&      Form  get_ZLET0510
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8315   text
*----------------------------------------------------------------------*
FORM GET_ZLET0510
USING PV_SPART PV_MATNR PV_KUNNR
PS_VBAP LIKE GT_VBAP PS_LIPS LIKE GT_LIPS
                    CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_INT TYPE P DECIMALS 2.
  DATA: LV_CHAR1 TYPE CHAR20,
        LV_CHAR2 TYPE CHAR20,
        LV_CHAR3 TYPE CHAR20,
        LV_FLAG,
        GS_0510  LIKE GT_0510.

  CLEAR PV_ERROR.

  IF PV_SPART IS INITIAL OR PV_MATNR IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  " 포장재 마스터 테이블
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_0510
     FROM ZLET0510
    WHERE SPART  EQ PV_SPART
         AND MATNR EQ PV_MATNR.

  IF GT_0510[] IS INITIAL.

    MOVE GC_X TO PV_ERROR.
    RETURN.

  ENDIF.

  SORT GT_0510 BY SPART MATNR KUNNR LSMENG.

  CLEAR GS_0510.
  PERFORM GET_ORDER_MENGE TABLES GT_0510
            USING PV_SPART PV_MATNR GT_VBAK-KUNNR GT_VBAP GS_0510
                  CHANGING PV_ERROR GT_AREA.

  MOVE: GS_0510-PKKTX        TO GT_AREA-PKTYP, " 포자재 유형
             GS_0510-PKMATNR2  TO GT_AREA-PKMATNR,
             GS_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             GS_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
             GS_0510-PKHEIGHT2 TO GT_AREA-HEIGHT, "  높이`
             GS_0510-PKWEIGHT2 TO GT_AREA-PKWEI, " 무게
             GS_0510-PKMEINS2  TO GT_AREA-PMEINS.
  ADD GS_0510-ZHEIGHT TO GT_AREA-HEIGHT. "  높이`

  CONCATENATE GS_0510-SPART GS_0510-PKKTX GS_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

  " 포장재유형(PKKTX)과 포장재코드(PKMATNR2)를 표시하고
  " 납품수량(LIPS-LFIMG)에서 적재량(ZLET0510-LSMENG)을
  " 나눈 숫자를 표시(4사분면)
  IF NOT PS_LIPS-LFIMG IS INITIAL AND NOT GT_0510-LSMENG IS INITIAL.

    PERFORM CALCULATION_EXCEPTION_HANDING
    USING PS_LIPS-LFIMG '/' GT_0510-LSMENG CHANGING GT_AREA-MENGE.

  ENDIF.

*  PERFORM get_mara_brgew USING gt_area-pkmatnr CHANGING gt_area.

ENDFORM.                    " get_ZLET0510
*&---------------------------------------------------------------------*
*&      Form  get_ZLET0510_32
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8315   text
*----------------------------------------------------------------------*
FORM GET_ZLET0510_32
USING PV_SPART PV_MATNR PV_KUNNR
PS_VBAP LIKE GT_VBAP PS_LIPS LIKE GT_LIPS
                    CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_INT TYPE P DECIMALS 2.
  DATA: LV_CHAR1 TYPE CHAR20,
        LV_CHAR2 TYPE CHAR20,
        LV_CHAR3 TYPE CHAR20,
        LV_FLAG,
        GS_0510  LIKE GT_0510,
        LV_02    TYPE P DECIMALS 2.

  CLEAR PV_ERROR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_0510
     FROM ZLET0510
    WHERE SPART  EQ PV_SPART
         AND MATNR EQ PV_MATNR
         AND KUNNR EQ PV_KUNNR.

  IF GT_0510[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SORT GT_0510 BY SPART MATNR KUNNR.

  CLEAR GT_0510.
  READ TABLE GT_0510 INDEX 1 INTO GS_0510.

*  CLEAR gs_0510.
*  PERFORM get_order_menge_32 TABLES gt_0510
*            USING pv_spart pv_matnr gt_vbak-kunnr
* gt_vbap gs_0510 PS_LIPS
*                  CHANGING pv_error gt_area.

  MOVE: GS_0510-PKKTX        TO GT_AREA-PKTYP,
             GS_0510-PKMATNR2  TO GT_AREA-PKMATNR,
             GS_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             GS_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
             GS_0510-PKHEIGHT2 TO GT_AREA-HEIGHT, "  높이`
             GS_0510-PKWEIGHT2 TO GT_AREA-PKWEI,
             GS_0510-PKMEINS2  TO GT_AREA-PMEINS.
  ADD GS_0510-ZHEIGHT TO GT_AREA-HEIGHT. "  높이`

  CONCATENATE GS_0510-SPART GS_0510-PKKTX GS_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

  " 포장재유형(PKKTX)과 포장재코드(PKMATNR2)를 표시하고
  " 납품수량(LIPS-LFIMG)에서 적재량(ZLET0510-LSMENG)을
  " 나눈 숫자를 표시(4사분면)
  MOVE '0.2' TO LV_02.

  IF NOT PS_LIPS-LFIMG IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING PS_LIPS-LFIMG '*' LV_02 CHANGING GT_AREA-MENGE.
  ENDIF.

*  PERFORM get_mara_brgew USING gt_area-pkmatnr CHANGING gt_area.

ENDFORM.                    " get_ZLET0510_32
*&---------------------------------------------------------------------*
*&      Form  get_0510_2_2.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8315   text
*----------------------------------------------------------------------*
FORM GET_0510_2_2 USING  PV_SPART PV_KUNNR
                          PV_PACKAGING_CAT PV_STD_PRODUCT_NAME
                          PV_OUT
                          PV_LENGTH
                          PV_PROC_GR
                 CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_OUT           TYPE ZLET0510-OUT_DIA_FROM,
        LV_LENGTH        TYPE ZLET0510-LENGTH_FROM,
        LV_PACKAGING_CAT TYPE ZLET0510-PKKTX,
        LV_ZSTD_NAME     TYPE ZSTD_NAME,
        LV_FACTOR        TYPE ZLET0510-LENGTH,
        LV_PROC_GR       TYPE ZLET0510-PROC_GR.

  CLEAR PV_ERROR.

  MOVE PV_PACKAGING_CAT TO LV_PACKAGING_CAT.
  MOVE PV_STD_PRODUCT_NAME TO LV_ZSTD_NAME.
  MOVE PV_OUT TO LV_OUT.
  MOVE PV_LENGTH TO LV_LENGTH.
*  MOVE pv_sap_millca_factor TO lv_factor.
  MOVE PV_PROC_GR TO LV_PROC_GR.

  " 표준품명, 외경, 공정그룹, 조장
  SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF GT_0510
     FROM ZLET0510
    WHERE SPART  EQ PV_SPART
      AND STD_NAME EQ LV_ZSTD_NAME(3)
      AND OUT_DIA_FROM <= LV_OUT
      AND OUT_DIA_TO   >= LV_OUT
      AND LENGTH_FROM  <= LV_LENGTH
      AND LENGTH_TO    >= LV_LENGTH
      AND PROC_GR   EQ LV_PROC_GR.

  IF SY-SUBRC EQ 0.
    RETURN.
  ELSE.

    " 외경, 공정그룹, 조장
    SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF GT_0510
       FROM ZLET0510
      WHERE SPART  EQ PV_SPART
        AND OUT_DIA_FROM <= LV_OUT
        AND OUT_DIA_TO   >= LV_OUT
        AND LENGTH_FROM  <= LV_LENGTH
        AND LENGTH_TO    >= LV_LENGTH
        AND PROC_GR   EQ LV_PROC_GR.

    IF SY-SUBRC EQ 0.
      RETURN.
    ELSE.

      " 표준품명, 외경, 조장
      SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF GT_0510
         FROM ZLET0510
        WHERE SPART  EQ PV_SPART
          AND STD_NAME EQ LV_ZSTD_NAME(3)
          AND OUT_DIA_FROM <= LV_OUT
          AND OUT_DIA_TO   >= LV_OUT
          AND LENGTH_FROM  <= LV_LENGTH
          AND LENGTH_TO    >= LV_LENGTH.

      IF SY-SUBRC EQ 0.
        RETURN.
      ELSE.

        " 외경, 조장
        SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF GT_0510
           FROM ZLET0510
          WHERE SPART  EQ PV_SPART
            AND OUT_DIA_FROM <= LV_OUT
            AND OUT_DIA_TO   >= LV_OUT
            AND LENGTH_FROM  <= LV_LENGTH
            AND LENGTH_TO    >= LV_LENGTH.

        IF SY-SUBRC EQ 0.
          RETURN.
        ELSE.
          MOVE GC_X TO PV_ERROR.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_0510_2_2.
*&---------------------------------------------------------------------*
*&      Form  get_0510_22.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8315   text
*----------------------------------------------------------------------*
FORM GET_0510_22 USING PV_SPART PV_KUNNR PV_STD_NAME PV_EXPDIA PV_LENGTH
                                 CHANGING PV_ERROR.

  DATA: LV_STD_NAME TYPE CHAR40,
        LV_EXPDIA   TYPE ZLET0510-EXPDIA,
        LV_LENGTH   TYPE ZLET0510-LENGTH_FROM.

*  PERFORM change_string_replace USING 'MM' CHANGING pv_expdia.
*  PERFORM change_string_nogap CHANGING pv_expdia.

  MOVE PV_STD_NAME TO LV_STD_NAME.
  MOVE PV_EXPDIA     TO LV_EXPDIA.
  MOVE PV_LENGTH      TO LV_LENGTH.

  CLEAR PV_ERROR.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_0510
    FROM ZLET0510
   WHERE SPART          EQ PV_SPART
     AND KUNNR            EQ PV_KUNNR
     AND STD_NAME      EQ LV_STD_NAME
     AND EXPDIA          EQ LV_EXPDIA
*     AND expdia_to      >= lv_expdia
     AND LENGTH_FROM   <= LV_LENGTH
     AND LENGTH_TO       >= LV_LENGTH.

  IF SY-SUBRC <> 0.

    SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF GT_0510
       FROM ZLET0510
      WHERE SPART            EQ PV_SPART
           AND KUNNR           EQ ' '
           AND STD_NAME     EQ LV_STD_NAME
           AND EXPDIA          EQ LV_EXPDIA
*           AND expdia_to      >= lv_expdia
           AND LENGTH_FROM   <= LV_LENGTH
           AND LENGTH_TO       >= LV_LENGTH.

    IF SY-SUBRC <> 0.
      MOVE GC_X TO PV_ERROR.
    ENDIF.

  ENDIF.

ENDFORM.                    " get_0510_22.
*&---------------------------------------------------------------------*
*&      Form  get_READ_0510
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8315   text
*----------------------------------------------------------------------*
FORM GET_READ_0510 USING PV_SPART PV_PRODUCT_NAME PV_VOLTAGE
 PV_LENGTH PV_CORE_NO PV_COND_SIZE PV_COND_DIA PV_VBELN PV_POSNR
                                 CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_SPART            LIKE ZLET0510-SPART,
        LV_STD_NAME         LIKE ZLET0510-STD_NAME,
        LV_VOLTAGE          LIKE ZLET0510-VOLTAGE,
        LV_LENGTH           LIKE ZLET0510-LENGTH,
        LV_CORE_NO          LIKE ZLET0510-CORE_NO,
        LV_COND_SIZE        LIKE ZLET0510-COND_SIZE,
        LV_COND_DIA         LIKE ZLET0510-COND_DIA,
        LV_FACTOR_ATWRT     TYPE ATWRT,
        LV_CHAR10           TYPE CHAR10,
        LV_MENGE            TYPE P DECIMALS 3,
        LV_SAP_LENGTH_VKRME TYPE ATWRT,
        LV_MENGE2           TYPE P DECIMALS 3.

  DATA: LV_HOR_ATWRT TYPE ATWRT.
  DATA: LV_VER_ATWRT TYPE ATWRT.
  DATA: LV_HEIGHT_ATWRT TYPE ATWRT.

  ", 표준품명(STD_NAME), 전압(VOLTAGE), 조장(LENGTH), 도체수
*  (CORE_NO), 도체사이즈(COND_SIZE), 소선경(COND_DIA)로 데이터를 찾는다.

  MOVE PV_SPART               TO LV_SPART.
  MOVE PV_PRODUCT_NAME TO LV_STD_NAME.
  MOVE PV_VOLTAGE            TO LV_VOLTAGE.
  MOVE PV_LENGTH              TO LV_LENGTH.
  MOVE PV_CORE_NO          TO LV_CORE_NO.
  MOVE PV_COND_SIZE       TO LV_COND_SIZE.
  MOVE PV_COND_DIA        TO LV_COND_DIA.

  CLEAR GT_0510.

  IF LV_COND_DIA IS INITIAL.

    SELECT SINGLE *
        INTO GT_0510
      FROM ZLET0510
    WHERE SPART   = LV_SPART
          AND STD_NAME = LV_STD_NAME
          AND VOLTAGE    = LV_VOLTAGE
          AND LENGTH      = LV_LENGTH
          AND CORE_NO   = LV_CORE_NO
          AND COND_SIZE = LV_COND_SIZE
          AND COND_DIA EQ ' '.

  ELSE.

    SELECT SINGLE *
        INTO GT_0510
      FROM ZLET0510
    WHERE SPART   = LV_SPART
          AND STD_NAME = LV_STD_NAME
          AND VOLTAGE    = LV_VOLTAGE
          AND LENGTH      = LV_LENGTH
          AND CORE_NO   = LV_CORE_NO
          AND COND_SIZE = LV_COND_SIZE
          AND COND_DIA <> ''.
  ENDIF.
  .
  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
  CHANGING PV_ERROR LV_FACTOR_ATWRT.

  MOVE: GT_0510-PKKTX          TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2    TO GT_AREA-PKMATNR.
*             gt_0510-coil_height TO gt_area-height.

*  MOVE pv_length TO LV_MENGE2.
  " 조장
  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE2.

  "  LIPS-LFIMG /  SAP_LENGTH_VKRME
  IF NOT GT_LIPS-LFIMG  IS INITIAL AND NOT LV_MENGE2 IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE2 CHANGING LV_MENGE.
  ENDIF.

  "  총 적재수 / 적재단수
  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING LV_MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  "  포장재코드의 특성 PK_AA_HORIZONTAL(가로), PK_AA_VERTICAL(세로),
  "PK_AA_HEIGHT(높이)에서 숫자값을 10으로 나눈값
  " (mm가 아닌 cm로 환산하기 위함)

*  PERFORM read_et_char USING 'PK_AA_HORIZONTAL'
*CHANGING gv_error lv_hor_atwrt.
*
*  PERFORM read_et_char USING 'PK_AA_VERTICAL'
* CHANGING gv_error lv_ver_atwrt.
*
*  PERFORM read_et_char USING 'PK_AA_HEIGHT'
* CHANGING gv_error lv_height_atwrt.

  MOVE: PV_VBELN TO GT_AREA-VBELN,
             PV_POSNR  TO GT_AREA-POSNR,
             PV_SPART TO GT_AREA-SPART,
            GT_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
            GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
*            gt_0510-pkweight2 TO gt_area-pkwei,
            GT_0510-PKMEINS2  TO GT_AREA-PMEINS.

  MOVE LV_FACTOR_ATWRT TO LV_MENGE.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "    6) 가로, 세로는 최종포장재코드의 가로, 세로를 표시하고
  "높이는 1차 포장재코드의 높이(COIL_HEIGHT X 적재단수)와
  "최종포장재 높이를 더하여 표시
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
  NOT GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
    CHANGING GT_AREA-HEIGHT.
  ENDIF.

*      add Gt_0510-pkheight2 TO gt_area-height. "  높이`
  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`
  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.
*  IF NOT gt_area-height IS INITIAL.
*    gt_area-height = gt_area-height / 10.
*  ENDIF.

  "  mm -> cm 반영하기 위해서나눔.
*  IF gt_area-width <> 0.
*    gt_area-width = gt_area-width / 10.
*  ENDIF.
*
*  IF gt_area-zlength <> 0.
*    gt_area-zlength = gt_area-zlength / 10.
*  ENDIF.
*
*  IF gt_area-height <> 0.
*    gt_area-height = gt_area-height / 10.
*  ENDIF.

ENDFORM.                    " get_READ_0510.
*&---------------------------------------------------------------------*
*&      Form  GET_characteristic_20
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8319   text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC_20  USING PV_SPART PV_VGBEL PV_VGPOS PV_CHK_CM
 CHANGING PV_ERROR PS_AREA.

  "MTO 판매오더 포장재 검색

  DATA: LV_ATINN LIKE AUSP-ATINN .
*
  "    2) 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
  "판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.

  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  SORT GT_ET_CHAR BY ATNAM ATWRT.
  DELETE ADJACENT DUPLICATES FROM GT_ET_CHAR COMPARING ATNAM.

  IF PV_CHK_CM EQ GC_X.

    "    3) ATINN "PD_CA_PACKMARK_STATUS"의 ATWRT "CM"인 ATINN
    ""SAP_MILLCA_PACKAGING"의 ATWRT를 구한다.(최종 포장재 코드)
    CLEAR GT_ET_CHAR.

    PERFORM READ_ET_CHAR USING 'PD_CA_PACKMARK_STATUS'
    CHANGING PV_ERROR GV_ATWRT.

    IF PV_ERROR IS INITIAL.
      CHECK GV_ATWRT EQ 'CM'.
    ELSE.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

  ENDIF.

*  CLEAR pv_error.
*  PERFORM read_et_char USING 'PD_CA_PACKING_DM'
*HANGING pv_error gv_atwrt.

*  IF pv_error IS INITIAL.

  CLEAR GV_ATWRT.
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_PACKAGING'
  CHANGING PV_ERROR GV_ATWRT.
  "  RL_CA_FG_DIA_CHG(플랜지경변경),
  "RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 모두 없는 경우
  "  RL_CA_FG_DIA_CHG(플랜지경변경)이나
  "RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 있는 경우
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM MATERIALCHARACTERISTIC_GET
  USING PV_SPART GV_ATWRT CHANGING PV_ERROR.

*  ELSE.
*
*    MOVE gc_x TO pv_error.
*    RETURN.
*
*  ENDIF.

ENDFORM.                    " GET_characteristic_20
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_CHARACTERISTIC_GET
*&---------------------------------------------------------------------*
FORM MATERIALCHARACTERISTIC_GET
  USING PV_SPART PV_AWART CHANGING PV_ERROR.

  DATA: LV_OPTION            TYPE AUSP-OBJEK,
        LV_CA_NO             TYPE AUSP-OBJEK,
        LV_DIA_CHG           TYPE AUSP-OBJEK,
        LV_WIDTH_CHG         TYPE AUSP-OBJEK,
        LV_DRUM_NO           TYPE ZEDRUM_NO,
        LV_PK_WD_THK         TYPE ZEPK_WD_THK,
        LV_PK_WD_THK_2       TYPE ZEPK_WD_THK,
        LV_SAP_MILLCA_LENGTH TYPE ATWRT,
        LV_MENGE             TYPE P DECIMALS 3,
        LV_DR_GBN.

  REFRESH GT_OBJECT.

  " 자재특성 값을 가져온다.
  PERFORM GET_MATERIAL_CHARACT TABLES GT_OBJECT USING PV_AWART.

  " RL_CA_RAMP_OPTION(특수드럼표기),
  CLEAR: LV_OPTION, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_RAMP_OPTION' CHANGING PV_ERROR LV_OPTION.

  " RL_CA_NO(드럼기호)
  CLEAR: LV_CA_NO, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_NO' CHANGING PV_ERROR LV_CA_NO.

  "  RL_CA_FG_DIA_CHG(플랜지경변경)
  CLEAR: LV_DIA_CHG, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_FG_DIA_CHG' CHANGING PV_ERROR LV_DIA_CHG.

  "  RL_CA_IN_WIDTH_CHG(내폭변경)
  CLEAR: LV_WIDTH_CHG, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_IN_WIDTH_CHG' CHANGING PV_ERROR LV_WIDTH_CHG.

  MOVE LV_CA_NO TO LV_DRUM_NO.

  CASE LV_OPTION.
    WHEN 'U' OR 'S' OR 'D'.
      LV_DR_GBN = 'U'.
    WHEN OTHERS.
      LV_DR_GBN = 'G'.
  ENDCASE.

  SORT GT_0210 BY DR_GBN SG_GBN DRUM_DET DRUM_NO.

  " 드럼 구분, 판매 구분 ,드럼 상세 코드 적용 순서
  CLEAR GV_SUBRC. CLEAR PV_ERROR.
  PERFORM GET_ZEDT0210 USING LV_DR_GBN LV_CA_NO CHANGING GV_SUBRC.

  IF GV_SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CASE PV_SPART.
    WHEN '20'.
      MOVE 'DM' TO GT_AREA-PKTYP.
*      PERFORM get_mara_brgew USING pv_awart CHANGING gt_area.

    WHEN '21'.
      MOVE 'DM' TO GT_AREA-PKTYP.
    WHEN '23' OR '24'.
      MOVE 'DM' TO GT_AREA-PKTYP.
    WHEN '30' OR '31' OR '41' OR '44'.
      MOVE 'DM' TO GT_AREA-PKTYP.
  ENDCASE.

*  CLEAR pv_error.          "   lv_sap_millca_factor TYPE atwrt.
*  PERFORM read_et_char USING 'SAP_MILLCA_LENGTH'
*  CHANGING pv_error lv_sap_millca_length.

*  " 포장재 수량
*  IF NOT lv_sap_millca_length IS INITIAL.
*    PERFORM change_string_replace
*    USING ',' CHANGING lv_sap_millca_length.
*    CONDENSE lv_sap_millca_length NO-GAPS.
*    MOVE lv_sap_millca_length TO lv_menge.
*  ENDIF.

  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

  " 납품수량 / 조장
  IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE CHANGING GT_AREA-MENGE.
  ENDIF.

  "    5) RL_CA_FG_DIA_CHG(플랜지경변경),
  " RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 모두 없는 경우
  IF LV_DIA_CHG IS INITIAL AND LV_WIDTH_CHG IS INITIAL.

    IF NOT GT_0210-PK_WD_THK IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PK_WD_THK '*' 2 CHANGING LV_PK_WD_THK.
    ENDIF.

    GT_AREA-PKMATNR = PV_AWART.   " 최종 포장재 코드
    GT_AREA-DMMATNR = LV_CA_NO.   " 드럼 기호
    GT_AREA-HEIGHT = GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_PK_WD_THK.
    GT_AREA-WIDTH = GT_0210-OUT_WID.
    GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
    GT_AREA-PMEINS = 'KG'.

    " RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 있는 경우
  ELSEIF (  NOT LV_DIA_CHG IS INITIAL OR LV_WIDTH_CHG IS INITIAL ).

    MOVE LV_DIA_CHG+1(29) TO LV_PK_WD_THK.
    "
    IF NOT GT_0210-PLAN_THK IS INITIAL AND
    NOT GT_0210-PLAN_CNT IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PLAN_THK '*' GT_0210-PLAN_CNT
      CHANGING LV_PK_WD_THK_2.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_PK_WD_THK_2 '*' 2 CHANGING LV_PK_WD_THK_2.
      LV_PK_WD_THK = LV_PK_WD_THK + LV_PK_WD_THK_2.
    ENDIF.

    GT_AREA-HEIGHT = GT_AREA-ZLENGTH = LV_PK_WD_THK.
    GT_AREA-WIDTH = GT_0210-OUT_WID.
    GT_AREA-PKMATNR = PV_AWART.   " 최종 포장재 코드
    GT_AREA-DMMATNR = LV_CA_NO.   " 드럼 기호
    GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
    GT_AREA-PMEINS = 'KG'.

    " RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 있는 경우
  ELSEIF (  LV_DIA_CHG IS INITIAL OR NOT LV_WIDTH_CHG IS INITIAL ).

*    MOVE lv_dia_chg+1(29) TO lv_pk_wd_thk.
    IF NOT GT_0210-PK_WD_THK IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PK_WD_THK '*' 2 CHANGING LV_PK_WD_THK.
    ENDIF.

    GT_AREA-HEIGHT = GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_PK_WD_THK.

*    gt_area-height = gt_area-zlength = lv_pk_wd_thk.

    CLEAR LV_PK_WD_THK.
    MOVE LV_WIDTH_CHG+1(29) TO LV_PK_WD_THK.

    IF NOT GT_0210-PLAN_THK IS INITIAL AND
    NOT GT_0210-PLAN_CNT IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PLAN_THK '*' GT_0210-PLAN_CNT
      CHANGING LV_PK_WD_THK_2.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_PK_WD_THK_2 '*' 2 CHANGING LV_PK_WD_THK_2.
      LV_PK_WD_THK = LV_PK_WD_THK + LV_PK_WD_THK_2.
    ENDIF.

    GT_AREA-WIDTH = LV_PK_WD_THK.
    GT_AREA-PKMATNR = PV_AWART.   " 최종 포장재 코드
    GT_AREA-DMMATNR = LV_CA_NO.   " 드럼 기호
    GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
    GT_AREA-PMEINS = 'KG'.
    "    6) RL_CA_FG_DIA_CHG(플랜지경변경)이나
    " RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 있는 경우
  ELSEIF ( NOT LV_DIA_CHG IS INITIAL OR NOT LV_WIDTH_CHG IS INITIAL ).

    MOVE LV_DIA_CHG+1(29) TO LV_PK_WD_THK.
    "
    IF NOT GT_0210-PLAN_THK IS INITIAL AND
    NOT GT_0210-PLAN_CNT IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PLAN_THK '*' GT_0210-PLAN_CNT
      CHANGING LV_PK_WD_THK_2.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_PK_WD_THK_2 '*' 2 CHANGING LV_PK_WD_THK_2.
      LV_PK_WD_THK = LV_PK_WD_THK + LV_PK_WD_THK_2.
    ENDIF.

    GT_AREA-HEIGHT = GT_AREA-ZLENGTH = LV_PK_WD_THK.

    CLEAR LV_PK_WD_THK.
    MOVE LV_WIDTH_CHG+1(29) TO LV_PK_WD_THK.

    IF NOT GT_0210-PLAN_THK IS INITIAL AND
    NOT GT_0210-PLAN_CNT IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PLAN_THK '*' GT_0210-PLAN_CNT
      CHANGING LV_PK_WD_THK_2.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_PK_WD_THK_2 '*' 2 CHANGING LV_PK_WD_THK_2.
      LV_PK_WD_THK = LV_PK_WD_THK + LV_PK_WD_THK_2.
    ENDIF.

    GT_AREA-WIDTH = LV_PK_WD_THK.
    GT_AREA-PKMATNR = PV_AWART.   " 최종 포장재 코드
    GT_AREA-DMMATNR = LV_CA_NO.   " 드럼 기호
    GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
    GT_AREA-PMEINS = 'KG'.

  ELSE.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CASE LV_OPTION.
    WHEN '붕드럼(밖)/U형' OR 'D'.
      ADD GC_70 TO GT_AREA-WIDTH .
    WHEN OTHERS.
      " 특수드럼표기값은 특수드럼표기값을 'G'로 넣어서 진행
  ENDCASE.
  "  mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
  ENDIF.

ENDFORM.                    " MATERIAL_CHARACTERISTIC_GET
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_CHARACTERISTIC_GET_30
*&---------------------------------------------------------------------*
FORM MATERIALCHARACTERISTIC_GET_30
USING PV_SPART PV_MATNR PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  DATA: LS_VBFA LIKE VBFA.

  DATA: LV_WIDTH             TYPE AUSP-OBJEK,
        LV_FG_DIA            TYPE AUSP-OBJEK,
        LV_FACTOR_ATWRT      TYPE ATWRT,
        LV_SAP_MILLCA_LENGTH TYPE ATWRT,
        LV_RL_CA_WEIGHT      TYPE ATWRT,
        LV_MENGE             TYPE ZLET0917-MENGE.

  REFRESH GT_OBJECT.

  " 자재특성 값을 가져온다.
  PERFORM GET_MATERIAL_CHARACT TABLES GT_OBJECT USING PV_MATNR.

  " RL_CA_RAMP_OPTION(특수드럼표기),
  CLEAR: LV_WIDTH, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_OUT_WIDTH' CHANGING PV_ERROR LV_WIDTH.

  " RL_CA_NO(드럼기호)
  CLEAR: LV_FG_DIA, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_FG_DIA' CHANGING PV_ERROR LV_FG_DIA.

  CLEAR: LV_RL_CA_WEIGHT, PV_ERROR.

  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_WEIGHT' CHANGING PV_ERROR LV_RL_CA_WEIGHT.


  IF LV_WIDTH IS INITIAL OR LV_FG_DIA IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  " 포장재 수량
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
  CHANGING PV_ERROR LV_FACTOR_ATWRT.

  "  ATWRT로 자재마스터의 특성에서 외폭(RL_CA_OUT_WIDTH)은 가로로,

  IF NOT LV_WIDTH IS INITIAL.

    PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING LV_WIDTH.
    PERFORM CHANGE_STRING_REPLACE USING 'mm' CHANGING LV_WIDTH.
    PERFORM CHANGE_STRING_NOGAP CHANGING LV_WIDTH.

    MOVE LV_WIDTH TO GT_AREA-WIDTH.
    IF GT_AREA-WIDTH <> 0.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
    ENDIF.
  ENDIF.

  "  플랜지경(RL_CA_FG_DIA)은 세로와 높이로 인식한다.-티코
  IF NOT LV_FG_DIA IS INITIAL.

    PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING LV_FG_DIA.
    PERFORM CHANGE_STRING_REPLACE USING 'mm' CHANGING LV_FG_DIA.
    PERFORM CHANGE_STRING_NOGAP CHANGING LV_FG_DIA.

    MOVE: LV_FG_DIA TO GT_AREA-ZLENGTH,
               LV_FG_DIA TO GT_AREA-HEIGHT.

    IF GT_AREA-ZLENGTH <> 0.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
    ENDIF.

    IF GT_AREA-HEIGHT <> 0.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
    ENDIF.

  ENDIF.

*  IF NOT lv_rl_ca_weight IS INITIAL.
*
*    PERFORM change_string_replace USING ',' CHANGING lv_rl_ca_weight.
*    PERFORM change_string_replace USING 'kg' CHANGING lv_rl_ca_weight.
*    PERFORM change_string_nogap CHANGING lv_rl_ca_weight.
*
*    MOVE: lv_rl_ca_weight TO gt_area-pkwei,
*                'KG'                TO gt_area-pmeins.
*
*  ENDIF.

  "  수량
  GT_AREA-PKMATNR = PV_MATNR.
  GT_AREA-PKTYP = 'DM'.


*  CLEAR pv_error.          "   lv_sap_millca_factor TYPE atwrt.
*  PERFORM read_et_char USING 'SAP_MILLCA_LENGTH'
*  CHANGING pv_error lv_sap_millca_length.
*
*  " 포장재 수량
*  IF NOT lv_sap_millca_length IS INITIAL.
*    PERFORM change_string_replace
*    USING ',' CHANGING lv_sap_millca_length.
*    CONDENSE lv_sap_millca_length NO-GAPS.
*    MOVE lv_sap_millca_length TO lv_menge.
*  ENDIF.

  " 조장
  MOVE: GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

  " 납품수량 / 조장
  IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE CHANGING GT_AREA-MENGE.
  ENDIF.

  CLEAR GT_AREA-PKWEI.

  SELECT SINGLE NTGEW
      INTO GT_AREA-PKWEI
    FROM MARA
   WHERE MATNR EQ PV_MATNR.

  MOVE 'KG' TO GT_AREA-PMEINS.

ENDFORM.                    " MATERIAL_CHARACTERISTIC_GET_30
*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_CTBPCONVERTVALUE
*&---------------------------------------------------------------------*
FORM CALL_FUNCTION_CTBPCONVERTVALUE  USING P_ATNAM TYPE ATNAM
                                           P_ATFLV TYPE ATFLV
                                           P_ATFLB TYPE ATFLB
                                           P_ATCOD TYPE ATCOD
                                  CHANGING P_ATWTB TYPE ATWTB.

  DATA LV_ATWRT TYPE ATWRT.
  CLEAR LV_ATWRT.

  CALL FUNCTION 'CTBP_CONVERT_VALUE_INT_TO_EXT'
    EXPORTING
      CHARACTNAME       = P_ATNAM
      VALUE_FROM        = P_ATFLV
      VALUE_TO          = P_ATFLB
      VALUE_RELATION    = P_ATCOD
    IMPORTING
      VALUE_EXTERNAL    = LV_ATWRT
    EXCEPTIONS
      CHARACT_NOT_FOUND = 1
      NO_AUTHORITY      = 2
      WRONG_DATA_TYPE   = 3
      INTERNAL_ERROR    = 4
      WRONG_INPUT       = 5
      WRONG_FORMAT      = 6
      OTHERS            = 7.

  IF SY-SUBRC <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK LV_ATWRT IS NOT INITIAL.

  MOVE LV_ATWRT TO P_ATWTB .

ENDFORM.                    " CALL_FUNCTION_CTBPCONVERTVALUE
*&---------------------------------------------------------------------*
*&      Form  GET_MASTER_20
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0210  text
*----------------------------------------------------------------------*
FORM GET_MASTER_20  TABLES   PT_0210 STRUCTURE ZEDT0210
                                  CHANGING PV_ERROR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE PT_0210
     FROM ZEDT0210.

  IF PT_0210[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SORT PT_0210 BY DR_GBN SG_GBN DRUM_DET DRUM_NO.

ENDFORM.                    " GET_MASTER_20
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_10
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_10.

  LOOP AT GT_LIPS WHERE SPART EQ 10.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GV_ERROR.
    PERFORM GET_SPART_10 USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-MATNR GT_LIPS-VGBEL GT_LIPS-VGPOS
    CHANGING GV_ERROR.
  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_10
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_20
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_20.

  LOOP AT GT_LIPS WHERE SPART EQ 20.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.
    CLEAR:  GV_ERROR, GT_AREA.
    PERFORM GET_SPART_20
    USING GT_LIPS-VBELN GT_LIPS-POSNR 20 GT_LIPS-VGBEL GT_LIPS-VGPOS
    GT_LIPS-MATNR GT_VBAK-KUNNR GT_LIPS-CHARG GT_LIPS-WERKS CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_20
*&---------------------------------------------------------------------*
*&      Form  GET_characteristic_20_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM  GET_CHARACTERISTIC_20_2  USING    PV_SPART
                                                  PV_VGBEL
                                                  PV_VGPOS
                                                  PV_MATNR
                                                  PV_KUNNR
                                         CHANGING PV_ERROR
                                                  PS_AREA LIKE GT_AREA.

  DATA: LV_ATINN LIKE AUSP-ATINN .
  DATA: LV_OUT_ATWRT TYPE ATWRT.
  DATA: LV_LENGTH_ATWRT TYPE ATWRT.
  DATA: LV_FACTOR_ATWRT TYPE ATWRT.
  DATA: LV_INT                      TYPE P DECIMALS 2,
        LV_MENGE                    TYPE P DECIMALS 3,
        LV_SAP_MILLCA_PACKAGING_CAT TYPE ATWRT,
        LV_PD_AA_STD_PRODUCT_NAME   TYPE ATWRT,
        LV_SAP_MILLCA_FACTOR        TYPE ATWRT,
        LV_PD_CA_PROC_GR            TYPE ATWRT,
        LV_SAP_LENGTH_VKRME         TYPE ATWRT,
        LV_MENGE2                   TYPE P DECIMALS 3.
*
  "    2) 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN,
  "I_POSNR에 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서
  " 특성값을 구한다.

  REFRESH GT_ET_CHAR.

  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER
  TABLES GT_ET_CHAR USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  SORT GT_ET_CHAR BY ATNAM ATWRT.
  DELETE ADJACENT DUPLICATES FROM GT_ET_CHAR COMPARING ATNAM.

*   3) 제품군(ZLET0510-SPART), 고객(ZLET0510-KUNNR),
*       특성 공정외경(PD_CA_PROC_OUT_DIA)이 ZLET0510-OUT_DIA_FROM~OUT_
*       조장(SAP_LENGTH_VKRME)이 ZLET0510-LENGTH_FROM~LENGTH_TO에도 만

  "  포장재 유형
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_PACKAGING_CAT'
  CHANGING GV_ERROR LV_SAP_MILLCA_PACKAGING_CAT.

  "  표준 품명
  PERFORM READ_ET_CHAR USING 'PD_AA_STD_PRODUCT_NAME'
  CHANGING GV_ERROR LV_PD_AA_STD_PRODUCT_NAME.

  PERFORM READ_ET_CHAR USING 'PD_CA_PROC_OUT_DIA'
  CHANGING GV_ERROR LV_OUT_ATWRT.

  PERFORM READ_ET_CHAR USING 'SAP_LENGTH_VKRME'
  CHANGING GV_ERROR LV_LENGTH_ATWRT.

*  PERFORM read_et_char USING 'SAP_MILLCA_FACTOR'
  "CHANGING gv_error lv_sap_millca_factor.

  PERFORM READ_ET_CHAR USING 'PD_CA_PROC_GR'
  CHANGING GV_ERROR LV_PD_CA_PROC_GR.


  " 2-2. 제품군 20(다발, 합판보빈을 팔레트 적재)
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_0510_2_2  USING GT_LIPS-SPART GT_VBAK-KUNNR
  LV_SAP_MILLCA_PACKAGING_CAT LV_PD_AA_STD_PRODUCT_NAME
  LV_OUT_ATWRT LV_LENGTH_ATWRT  LV_PD_CA_PROC_GR
                                   CHANGING PV_ERROR GT_AREA.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
  CHANGING GV_ERROR LV_FACTOR_ATWRT..

  MOVE: GT_0510-PKKTX       TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2 TO GT_AREA-PKMATNR.

  " 조장
  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE2.

  "  LIPS-LFIMG /  SAP_LENGTH_VKRME
  IF NOT GT_LIPS-LFIMG  IS INITIAL AND NOT LV_MENGE2 IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE2 CHANGING LV_MENGE.
  ENDIF.

  "  포장재 수량
  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING LV_MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  "    6) 가로, 세로는 최종포장재코드의 가로, 세로를 표시하고
  "높이는 1차 포장재코드의 높이(COIL_HEIGHT X 적재단수)와
  "최종포장재 높이를 더하여 표시
*  IF NOT ( gt_area-height IS INITIAL AND NOT lv_factor_atwrt
*IS INITIAL ).
*    gt_area-height = gt_area-height * lv_factor_atwrt.
*  ENDIF.

  MOVE: GT_0510-PKWIDTH2   TO GT_AREA-WIDTH, "   세로
         GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
         GT_0510-PKMEINS2 TO GT_AREA-PMEINS.

  MOVE LV_FACTOR_ATWRT TO LV_MENGE.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
  GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
    CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

*  "  mm -> cm 반영하기 위해서나눔.
*  IF gt_area-width <> 0.
*    gt_area-width = gt_area-width.
*  ENDIF.
*
*  IF gt_area-zlength <> 0.
*    gt_area-zlength = gt_area-zlength.
*  ENDIF.
*
*  IF gt_area-height <> 0.
*    gt_area-height = gt_area-height.
*  ENDIF.

ENDFORM.                    " GET_characteristic_20_2
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_21.

  LOOP AT GT_LIPS WHERE SPART EQ 21.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_21  USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-VGBEL GT_LIPS-VGPOS GT_LIPS-MATNR
    GT_VBAK-KUNNR CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_21
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_22
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_22.

  LOOP AT GT_LIPS WHERE SPART EQ 22.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_22  USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-VGBEL GT_LIPS-VGPOS GT_LIPS-MATNR
    VBAK-KUNNR CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_21
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_23
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_23.

  LOOP AT GT_LIPS WHERE SPART EQ 23.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

*    CLEAR: gv_error, gt_area.
    " 5-2. 제품군 23(다발 팔레트 적재
    PERFORM GET_PALETTE_23 USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-VGBEL GT_LIPS-VGPOS GT_LIPS-MATNR
    VBAK-KUNNR GT_LIPS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.

      MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                 GT_LIPS-POSNR TO GT_AREA-POSNR.
      MOVE '23-A' TO GT_AREA-CODE_POINT.

      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.

    ENDIF.

    " 5-1 제품군  23(드럼 적재)
    " MTO 인 경우
    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_20  USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-VGBEL GT_LIPS-VGPOS GT_LIPS-MATNR
    VBAK-KUNNR GT_LIPS-CHARG GT_LIPS-WERKS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

    " MTS 경우
    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_23 USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-VGBEL GT_LIPS-VGPOS GT_LIPS-MATNR
    VBAK-KUNNR GT_LIPS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.

      MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                 GT_LIPS-POSNR TO GT_AREA-POSNR.
      MOVE '23-B' TO GT_AREA-CODE_POINT.

      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_23

*&---------------------------------------------------------------------*
*&      Form  READ_ET_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_9498   text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_ET_CHAR  USING PV_CHAR
                   CHANGING PV_ERROR PV_ATWRT.

  CLEAR: GT_ET_CHAR, PV_ERROR.
  READ TABLE GT_ET_CHAR WITH KEY ATNAM = PV_CHAR
                                   BINARY SEARCH.

  IF SY-SUBRC <> 0.

    IF PV_CHAR EQ 'SAP_MILLCA_PACKAGING'.

      CLEAR: GT_ET_CHAR, PV_ERROR.
      READ TABLE GT_ET_CHAR WITH KEY ATNAM = 'PD_CA_PACKING_DM'
                                       BINARY SEARCH.

    ENDIF.

    IF SY-SUBRC <> 0.
      MOVE GC_X TO PV_ERROR.
    ELSE.
      MOVE GT_ET_CHAR-ATWRT TO PV_ATWRT.
    ENDIF.

  ELSE.
    MOVE GT_ET_CHAR-ATWRT TO PV_ATWRT.
  ENDIF.

ENDFORM.                    " READ_ET_CHAR
*&---------------------------------------------------------------------*
*&      Form  GET_CHARACTERISTIC_TABLE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ET_CHAR  text
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*----------------------------------------------------------------------*
FORM GET_SALES_CHARACTER  TABLES PT_ET_CHAR STRUCTURE GT_ET_CHAR
                           USING PV_VGBEL
                                 PV_VGPOS
                        CHANGING PV_ERROR.

  CLEAR   : PT_ET_CHAR, PV_ERROR.
  REFRESH : PT_ET_CHAR.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
    EXPORTING
      I_VBELN                      = PV_VGBEL
      I_POSNR                      = PV_VGPOS
    TABLES
      ET_CHAR                      = PT_ET_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.

  IF PT_ET_CHAR[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SORT PT_ET_CHAR BY ATNAM.

*___쓰레기값 삭제
  DELETE PT_ET_CHAR WHERE ATWRT EQ '?'.

ENDFORM.                    " GET_CHARACTERISTIC_TABLE2
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_SPART_21  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_VGBEL
                                             PV_VGPOS
                                             PV_MATNR
                                             PV_KUNNR
                            CHANGING PV_ERROR.

  DATA: LV_NAME_ATWRT TYPE ATWRT.
  DATA: LV_SIZE_ATWRT TYPE ATWRT.
  DATA: LV_LENGTH_ATWRT TYPE ATWRT.
  DATA: LV_PACKING_ATWRT TYPE ATWRT.

  DATA:  LV_FACTOR_ATWRT TYPE ATWRT.
  DATA: LV_HOR_ATWRT TYPE ATWRT.
  DATA: LV_VER_ATWRT TYPE ATWRT.
  DATA: LV_HEIGHT_ATWRT TYPE ATWRT.
  DATA: LV_INT   TYPE P DECIMALS 2,
        LV_MENGE TYPE P DECIMALS 3,
        LV_KDKG4 LIKE VBKD-KDKG4.
  DATA:  LV_MENGE2 TYPE P DECIMALS 3.
  " 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN,
  "I_POSNR에 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서
  "특성값을 구한다.

  REFRESH GT_ET_CHAR.
  CLEAR PV_ERROR.

  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  "    3) 특성값에서 표준품명(PD_AA_STD_PRODUCT_NAME),
  "도체사이즈(PD_CA_COND_SIZE_1ST), 조장(SAP_LENGTH_VKRME)의
  "ATWRT를 구한다.
  PERFORM READ_ET_CHAR USING 'PD_AA_STD_PRODUCT_NAME'
  CHANGING PV_ERROR LV_NAME_ATWRT.

  PERFORM READ_ET_CHAR USING 'PD_CA_COND_SIZE_1ST'
  CHANGING PV_ERROR LV_SIZE_ATWRT.

  PERFORM READ_ET_CHAR USING 'SAP_LENGTH_VKRME'
  CHANGING PV_ERROR LV_LENGTH_ATWRT.

*  PERFORM read_et_char USING 'SAP_MILLCA_PACKAGING_CAT
*' CHANGING pv_error lv_packing_atwrt.

  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
  CHANGING PV_ERROR LV_FACTOR_ATWRT.

  SELECT SINGLE KDKG4
       INTO LV_KDKG4
      FROM VBKD
   WHERE VBELN EQ PV_VGBEL.

  PERFORM GET_0510_21  USING PV_SPART PV_KUNNR
  LV_NAME_ATWRT LV_SIZE_ATWRT LV_LENGTH_ATWRT GT_0510 LV_KDKG4
                                             CHANGING PV_ERROR.

  " 값이 있으면
  IF PV_ERROR IS INITIAL.

    "최종포장재유형이 DM이면
    CASE GT_0510-PKKTX.
      WHEN 'DM'.

        CLEAR GT_AREA.
        PERFORM MATERIALCHARACTERISTIC_GET
        USING PV_SPART GT_0510-PKMATNR2 CHANGING PV_ERROR.

        IF PV_ERROR IS INITIAL.
          MOVE: PV_VBELN  TO GT_AREA-VBELN,
                     PV_POSNR TO GT_AREA-POSNR,
                     PV_SPART  TO GT_AREA-SPART,
                     '21-A'      TO GT_AREA-CODE_POINT.
          APPEND GT_AREA. CLEAR GT_AREA.

          RETURN.
        ENDIF.

      WHEN OTHERS.

        CLEAR GT_AREA.

        MOVE: PV_VBELN             TO GT_AREA-VBELN,
                   PV_POSNR             TO GT_AREA-POSNR,
                   PV_SPART              TO GT_AREA-SPART,
                  GT_0510-PKKTX       TO GT_AREA-PKTYP,
                  GT_0510-PKMATNR2 TO GT_AREA-PKMATNR.
*                 gt_0510-coil_height TO gt_area-height.

        MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE2.
*        MOVE lv_length_atwrt TO LV_MENGE2.

        "  LIPS-LFIMG /  SAP_LENGTH_VKRME
        IF NOT GT_LIPS-LFIMG  IS INITIAL AND NOT LV_MENGE2 IS INITIAL.
          PERFORM CALCULATION_EXCEPTION_HANDING
          USING GT_LIPS-LFIMG '/' LV_MENGE2 CHANGING LV_MENGE.
        ENDIF.

        "  총 적재수 / 적재단수
        IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
          PERFORM CALCULATION_EXCEPTION_HANDING
          USING  LV_MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
        ENDIF.

        MOVE: GT_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
                   GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
*                 gt_0510-pkweight2 TO gt_area-pkwei,    " 포장재 무게
                  " 포장재 무게 단위
                   GT_0510-PKMEINS2  TO GT_AREA-PMEINS.

        CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
        INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

        MOVE LV_FACTOR_ATWRT TO LV_MENGE.

        " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
        IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
          PERFORM CALCULATION_EXCEPTION_HANDING
          USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
        ENDIF.

        ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

        "   포장재 높이 가로, 세로는 최종포장재코드의 가로,
*      세로를 표시하고 높이는 1차 포장재코드의 높이(COIL_HEIGHT
*X 적재단수)
*      와 최종포장재 높이를 더하여 표시
        IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
        NOT GT_0510-LOAD_QTY IS INITIAL.
          PERFORM CALCULATION_EXCEPTION_HANDING
          USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
          CHANGING GT_AREA-HEIGHT .
        ENDIF.

        ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

        MOVE '21-B'      TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.

    ENDCASE.

  ENDIF.

  " 20-B 상품의 사용 드럼 정보 검색
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_SPART_20_A USING  PV_VBELN
                                                        PV_POSNR
                                                        PV_SPART
                                                        PV_VGBEL
                                                        PV_VGPOS
                                                        PV_MATNR
                                                        PV_KUNNR
                                       CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN TO GT_AREA-VBELN,
               PV_POSNR  TO GT_AREA-POSNR,
               '21-C' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_SPART_21
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_22
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_SPART_22  USING  PV_VBELN
                                             PV_POSNR
                                              PV_SPART
                                              PV_VGBEL
                                              PV_VGPOS
                                              PV_MATNR
                                              PV_KUNNR
                                     CHANGING PV_ERROR.

  DATA: LV_NAME_ATWRT TYPE ATWRT.
  DATA: LV_INNER_ATWRT TYPE ATWRT.
  DATA: LV_LENGTH_ATWRT TYPE ATWRT.
  DATA: LV_FACTOR_ATWRT TYPE ATWRT.

  DATA: LV_HOR_ATWRT TYPE ATWRT.
  DATA: LV_VER_ATWRT TYPE ATWRT.
  DATA: LV_HEIGHT_ATWRT TYPE ATWRT.
  DATA: LV_INT              TYPE P DECIMALS 2,
        LV_MENGE            TYPE P DECIMALS 3,
        LV_SAP_LENGTH_VKRME TYPE ATWRT,
        LV_MENGE2           TYPE P DECIMALS 3.

  " 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN,
  " I_POSNR에 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서
  "특성값을 구한다.

  REFRESH GT_ET_CHAR.

  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  "    3) 특성값에서 표준품명(PD_AA_STD_PRODUCT_NAME),
  "도체사이즈(PD_CA_COND_SIZE_1ST), 조장(SAP_LENGTH_VKRME)의
  "ATWRT를 구한다.
  PERFORM READ_ET_CHAR USING 'PD_AA_STD_PRODUCT_NAME'
  CHANGING GV_ERROR LV_NAME_ATWRT.

  PERFORM READ_ET_CHAR USING 'PD_TB_STD_EXP_INNER_DIA'
  CHANGING GV_ERROR LV_INNER_ATWRT.

  PERFORM READ_ET_CHAR USING 'SAP_LENGTH_VKRME'
  CHANGING GV_ERROR LV_LENGTH_ATWRT.

  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
  CHANGING GV_ERROR LV_FACTOR_ATWRT.

  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_0510_22
  USING PV_SPART PV_KUNNR LV_NAME_ATWRT
  LV_INNER_ATWRT LV_LENGTH_ATWRT
                                         CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  MOVE: PV_VBELN               TO GT_AREA-VBELN,
             PV_POSNR              TO GT_AREA-POSNR,
             GT_0510-PKKTX        TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2 TO GT_AREA-PKMATNR,
*             gt_0510-coil_height TO gt_area-height,
       GT_0510-PKWIDTH2   TO GT_AREA-WIDTH,  "   가로
       GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
*       gt_0510-pkweight2 TO gt_area-pkwei,    " 포장재 무게
       GT_0510-PKMEINS2 TO GT_AREA-PMEINS.  " 포장재 무게 단위
*       gt_0510-pkheight2 TO gt_area-height. "  높이`

  " 조장
  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE2.
*  MOVE lv_length_atwrt TO LV_MENGE2.

  "  LIPS-LFIMG /  SAP_LENGTH_VKRME
  IF NOT GT_LIPS-LFIMG  IS INITIAL AND NOT LV_MENGE2 IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE2 CHANGING LV_MENGE.
  ENDIF.

  "  총 적재수 / 적재단수
  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING LV_MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  MOVE LV_FACTOR_ATWRT TO LV_MENGE.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "    6) 가로, 세로는 최종포장재코드의 가로, 세로를 표시하고
  "높이는 1차 포장재코드의 높이(COIL_HEIGHT X 적재단수)와 최종포장재
  "높이를 더하여 표시
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
  NOT GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
    CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`
*  ADD gt_0510-coil_height TO gt_area-height.

  MOVE: '22-A'      TO GT_AREA-CODE_POINT.
  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.
  APPEND GT_AREA. CLEAR GT_AREA.
*  ADD GS_0510-ZHEIGHT TO gt_area-height. "  높이`

ENDFORM.                    " GET_SPART_22
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_20
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_SPART_20  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_VGBEL
                                             PV_VGPOS
                                             PV_MATNR
                                             PV_KUNNR
                                             PV_CHARG
                                             PV_WERKS
                            CHANGING PV_ERROR.

  DATA: LS_VBFA LIKE VBFA.

  " 1. 포장재 마스터 검색(PL)
  IF PV_SPART EQ '20'.

    CLEAR: PV_ERROR, GT_AREA.
    PERFORM GET_CHARACTERISTIC_20_2
    USING PV_SPART PV_VGBEL PV_VGPOS PV_MATNR VBAK-KUNNR
    CHANGING PV_ERROR GT_AREA.

    IF  PV_ERROR IS INITIAL.
      MOVE: PV_VBELN  TO GT_AREA-VBELN,
                 PV_POSNR TO GT_AREA-POSNR,
                   '20-A'   TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      RETURN.
    ENDIF.
  ENDIF.

  " 23, 24, 41, 43, 44 제품군에 대해서 납품절단,
  " 재고 절단 로직 추가
  CASE PV_SPART.
    WHEN '23' OR '24' OR '41' OR '43' OR '44'.

*  " 2. 납품절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_SPLIT USING  PV_VBELN
                                        PV_POSNR
                                        PV_VGBEL
                                        PV_VGPOS
                                        PV_SPART
                                        PV_MATNR
                               CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '20-B'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

      " 3. 재고 절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_STOCK_SPLIT USING  PV_VBELN
                                              PV_POSNR
                                              PV_VGBEL
                                              PV_VGPOS
                                              PV_SPART
                                              PV_MATNR
                                              PV_CHARG
                                              PV_WERKS
                                     CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '20-C'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

  ENDCASE.

  " 4.  상품 입고 정보 검색
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_SPART_20_A USING  PV_VBELN
                                PV_POSNR
                                PV_SPART
                                PV_VGBEL
                                PV_VGPOS
                                PV_MATNR
                                PV_KUNNR
                       CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.
    IF PV_SPART EQ 24.
      MOVE 'DM' TO GT_AREA-PKTYP.
    ENDIF.

    MOVE: PV_VBELN TO GT_AREA-VBELN,
               PV_POSNR  TO GT_AREA-POSNR,
               '20-D' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

*{ 기능개선 162986 - 추가
*___제품군 '23'인 경우 철드럼 검색
  IF PV_SPART = '23'.
*___판매오더 특성
    PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
                                 USING PV_VGBEL
                                       PV_VGPOS
                              CHANGING PV_ERROR.

    SORT GT_ET_CHAR BY ATNAM ATWRT.

*___'PD_CA_PACKMARK_STATUS'의 값이 "CM"인
*   'SAP_MILLCA_PACKAGING'의 값(최종 포장재 코드)
    READ TABLE GT_ET_CHAR WITH KEY ATNAM = 'PD_CA_PACKMARK_STATUS'
                                   ATWRT = 'CM'
                                   BINARY SEARCH.

    IF SY-SUBRC = 0.
      CLEAR : PV_ERROR, GV_ATWRT.

      PERFORM READ_ET_CHAR USING 'SAP_MILLCA_PACKAGING'
                        CHANGING PV_ERROR
                                 GV_ATWRT.

      IF PV_ERROR IS INITIAL.
        PERFORM MATERIALCHARACTERISTIC_GET_30 USING PV_SPART
                                                    GV_ATWRT
                                                    PV_VGBEL
                                                    PV_VGPOS
                                           CHANGING PV_ERROR.

        IF PV_ERROR IS INITIAL.
          MOVE: PV_VBELN TO GT_AREA-VBELN,
                PV_POSNR TO GT_AREA-POSNR,
                '20-D-1' TO GT_AREA-CODE_POINT.

          APPEND GT_AREA.

          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*} 기능개선 162986 - 추가

  " 5   MTO는 S/O에 지정된 포장재코드로 검색
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_CHARACTERISTIC_20
  USING PV_SPART PV_VGBEL PV_VGPOS GC_X CHANGING PV_ERROR GT_AREA.

  IF GV_ERROR IS INITIAL.

    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
               PV_SPART  TO GT_AREA-SPART,
               '20-E' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.

    RETURN.

  ENDIF.

  "  6.	오더유형 ZCS는 선행 오더의 포장재코드로 검색
  CLEAR: PV_ERROR.
  PERFORM CHECK_VBFA
  USING LS_VBFA PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.
    "  해당하는 값이 없고 LIPS-VGBEL의 VBAK-AUART="ZCS"이면
    " 아래 순서로 처리한다.
    CLEAR: PV_ERROR, GT_AREA.
    PERFORM GET_CHARACTERISTIC_20
    USING PV_SPART LS_VBFA-VBELV LS_VBFA-POSNV ' '
    CHANGING PV_ERROR GT_AREA.

    IF PV_ERROR IS INITIAL.

      MOVE: PV_VBELN TO GT_AREA-VBELN,
                 PV_POSNR TO GT_AREA-POSNR,
                 PV_SPART TO GT_AREA-SPART,
               '20-F' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.

      RETURN.

    ENDIF.

  ENDIF.

ENDFORM.                    " GET_PACK_SPART
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_10
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_MATNR  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_10  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_MATNR
                                             PV_VGBEL
                                             PV_VGPOS
                           CHANGING PV_ERROR.

  CLEAR GT_VBAK.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  CLEAR GT_VBAP.
  READ TABLE GT_VBAP WITH KEY VBELN = PV_VGBEL
                                                   POSNR = PV_VGPOS
                                    BINARY SEARCH.

  " 1. 포장재 마스터 검색(PL)
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_ZLET0510
  USING PV_SPART PV_MATNR GT_VBAK-KUNNR GT_VBAP GT_LIPS
   CHANGING PV_ERROR GT_AREA.

  IF NOT PV_ERROR IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ELSE.

    MOVE: PV_VBELN TO GT_AREA-VBELN,
               PV_POSNR TO  GT_AREA-POSNR,
               '10-A' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.

  ENDIF.

ENDFORM.                    " GET_SPART_10
*&---------------------------------------------------------------------*
*&      Form  GET_0510_SPART_32
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_MATNR  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_0510_SPART_32  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_MATNR
                                             PV_VGBEL
                                             PV_VGPOS
                           CHANGING PV_ERROR.

  CLEAR GT_VBAK.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  CLEAR GT_VBAP.
  READ TABLE GT_VBAP WITH KEY VBELN = PV_VGBEL
                                                   POSNR = PV_VGPOS
                                    BINARY SEARCH.

  " 1. 포장재 마스터 검색(PL)
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_ZLET0510_32
  USING PV_SPART PV_MATNR GT_VBAK-KUNNR GT_VBAP GT_LIPS
   CHANGING PV_ERROR GT_AREA.

  IF NOT PV_ERROR IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ELSE.

    MOVE: PV_VBELN TO GT_AREA-VBELN,
               PV_POSNR TO  GT_AREA-POSNR,
               '32-A' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.

  ENDIF.

ENDFORM.                    " GET_0510_SPART_32
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_23
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_9631   text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_23  USING  PV_VBELN
                                                 PV_POSNR
                                                 PV_SPART
                                                 PV_VGBEL
                                                 PV_VGPOS
                                                 PV_MATNR
                                                 PV_KUNNR
                                                 PS_LIPS LIKE GT_LIPS
                                CHANGING PV_ERROR.

  DATA: LV_LENGTH_ATWRT TYPE ATWRT.
  DATA: LV_VOLTAG_ATWRT TYPE ATWRT.
  DATA: LV_OUT_DIA_ATWRT TYPE ATWRT.
  DATA: LV_OUT_DIA_LONG_ATWRT TYPE ATWRT.
  DATA: LV_ATWRT TYPE ATWRT.
  DATA: LS_091 LIKE ZEDS091.
  DATA: LS_ZEDS057 LIKE ZEDS057.
  DATA: LS_ZEDS058 LIKE ZEDS058.
  DATA: LV_SAP_MILLCA_LENGTH TYPE ATWRT.
  DATA: LT_ZEDS110 LIKE ZEDS110 OCCURS 0 WITH HEADER LINE,
        LT_ZEDS059 LIKE ZEDS059 OCCURS 0 WITH HEADER LINE,
        LS_MARA    LIKE MARA,
        LV_CHAR30  TYPE CHAR30,
        LV_MENGE   TYPE MENGE_D,
        LV_WD_THK  LIKE GT_0210-PK_WD_THK.

  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  " 3) ATINN "PD_CA_PACKMARK_STATUS"의 ATWRT "CM"인 ATINN
  "SAP_MILLCA_PACKAGING"의 ATWRT를 구한다.(최종 포장재 코드)
  CLEAR GT_ET_CHAR.
  READ TABLE GT_ET_CHAR WITH KEY ATNAM = 'PD_CA_PACKMARK_STATUS'
                                        BINARY SEARCH.

  IF SY-SUBRC <> 0 OR GT_ET_CHAR-ATWRT <> 'CM'
  OR GT_ET_CHAR-ATWRT IS INITIAL.
    " 또한 특성 전압 "PD_CA_VOLTAGE"의 ATWRT,
    " 공정외경 "PD_CA_PROC_OUT_DIA"의 ATWRT를 구한다.
    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
    USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_LENGTH_ATWRT.

    CASE PV_SPART.
      WHEN 23.
        PERFORM READ_ET_CHAR
        USING 'PD_CA_VOLTAGE' CHANGING PV_ERROR LV_VOLTAG_ATWRT.
      WHEN 24.
        PERFORM READ_ET_CHAR
        USING 'PD_CA_VOLTAGE' CHANGING PV_ERROR LV_VOLTAG_ATWRT.
      WHEN 44.
        PERFORM READ_ET_CHAR
        USING 'PD_CA_INS_DIA' CHANGING PV_ERROR LV_VOLTAG_ATWRT.
    ENDCASE.
*공정외경 찾는 로직
    PERFORM READ_ET_CHAR
    USING 'PD_CA_PROC_OUT_DIA' CHANGING PV_ERROR LV_OUT_DIA_ATWRT.
*공정외경(장경) 찾는 로직
    PERFORM READ_ET_CHAR
    USING 'PD_CA_PROC_OUT_DIA_LONG' CHANGING PV_ERROR
                                             LV_OUT_DIA_LONG_ATWRT.
  ELSE.

    MOVE GT_ET_CHAR-ATWRT  TO LV_ATWRT.

  ENDIF.

  CLEAR LS_MARA.
  SELECT SINGLE *
      INTO LS_MARA
      FROM MARA
    WHERE MATNR EQ PS_LIPS-MATNR.

  " 자재유형이 'MCFE ' 인 경우만 MTS. 시뮬레이션 처리
  CHECK LS_MARA-MTART EQ 'MCFE'.

  MOVE PS_LIPS-WERKS TO LS_091-WERKS.
  MOVE PS_LIPS-SPART  TO LS_091-SPART.
  MOVE '4' TO LS_091-JEPUM_GUBUN.

* 케이블구분 CABLE_GBN='CR', 특수드럼 SPC_GBN='G',
* 드럼치수변경 DRUM_CHG='N', 외포장구분 OUT_GBN='F'
* 표준조장 STD_JOJANG=SAP_LENGTH_VRKME, 외경(단경)
* SHORTDIA과 외경(장경) LONGDIA=PD_CA_PROC_OUT_DIA의 ATWRT,
* 케이블중량 CABLE_WEIGHT=MARA-NTGEW*1000
* 동경비 BARREL_RATE는 "PD_CA_VOLTAGE"의 ATWRT 값에 따라 달라짐

  MOVE 'RL_CA_WD_DM' TO LS_ZEDS057-CLASS.
  MOVE PV_MATNR TO LS_ZEDS057-MATNR.
  MOVE 'G' TO LS_ZEDS057-DR_GBN.
  MOVE 'D' TO LS_ZEDS057-SG_GBN.
  MOVE 'S' TO LS_ZEDS057-DRUM_DET.

  LS_ZEDS057-CABLE_GUBUN = 'CR'.
  LS_ZEDS057-SPC_GBN = 'G'.
  LS_ZEDS057-DRUM_CHG = 'N'.
  LS_ZEDS057-OUT_GBN = 'F'.

  LS_ZEDS057-STD_JOJANG = LV_LENGTH_ATWRT. "  표준조장

*공정외경(장경)값이 있는경우 장경값을 넣고, 없으면 공정외경값으로 처리
  IF LV_OUT_DIA_LONG_ATWRT IS INITIAL.
    LS_ZEDS057-SHORTDIA =  LV_OUT_DIA_ATWRT.  " 외경(단경)
    LS_ZEDS057-LONGDIA = LV_OUT_DIA_ATWRT.   "  외경(장경)
  ELSE.
    LS_ZEDS057-SHORTDIA =  LV_OUT_DIA_ATWRT.  " 외경(단경)
    LS_ZEDS057-LONGDIA  = LV_OUT_DIA_LONG_ATWRT."  외경(장경)
  ENDIF.

  LS_ZEDS057-CABLE_WEIGHT = LS_MARA-NTGEW. " 케이블중량

*공정외경 / 장경 값 둘다 없을경우 1값으로 들어감
  IF LS_ZEDS057-SHORTDIA IS INITIAL.
    MOVE 1 TO LS_ZEDS057-SHORTDIA.
  ENDIF.

  IF LS_ZEDS057-LONGDIA IS INITIAL.
    MOVE 1 TO LS_ZEDS057-LONGDIA.
  ENDIF.

*          동경비 BARREL_RATE는 "PD_CA_VOLTAGE"의 ATWRT 값에 따라 달라짐
*            ⅰ) 맨 오른쪽 문자 2개가 KV가 아니라면 '15'
*            ⅱ) 값 중에서 '/', 특문, 영문, 공백을 제외한
*            숫자값이 6을 초과하면 20
*            ⅲ) 나머지는 17(맨 오른쪽 문자 2개가 KV이면서  '/',
*          특문, 영문, 공백을 제외한 숫자값이 6이하)
*          권공 GON_GONG은 "PD_CA_PROC_OUT_DIA"의 ATWRT 값에 따라 달라짐
*            ⅰ) 30이하면 50
*            ⅱ) 50초과면 100
*            ⅲ) 나머지는 70(30초과 50이하)

  IF PV_SPART EQ 23.

    " ) 맨 오른쪽 문자 2개가 KV가 아니라면 '15'
    PERFORM GET_VOLTAG_ATWRT
      USING LV_VOLTAG_ATWRT CHANGING LS_ZEDS057-BARREL_RATE.

    " 권공 GON_GONG은 "PD_CA_PROC_OUT_DIA"의 ATWRT 값에 따라 달라짐
    PERFORM GET_GON_GONG
      USING LV_OUT_DIA_ATWRT CHANGING LS_ZEDS057-GON_GONG.

  ELSEIF PV_SPART EQ 24.

    LS_ZEDS057-BARREL_RATE = 17.
    LS_ZEDS057-GON_GONG  = ''.

  ELSEIF PV_SPART EQ 41.

    LS_ZEDS057-BARREL_RATE = 43.
    LS_ZEDS057-GON_GONG  = 50.

  ELSEIF PV_SPART EQ 44.

    LS_ZEDS057-BARREL_RATE = 25.

    PERFORM CHECK_STRING USING LV_VOLTAG_ATWRT CHANGING LV_VOLTAG_ATWRT.

    LS_ZEDS057-GON_GONG  = LV_VOLTAG_ATWRT. " '절연외경(PD_CA_INS_DIA)'


  ENDIF.

  " 드럼 시뮬레이션
  CALL FUNCTION 'Z_ED_DRUM_SELECT'
    EXPORTING
      IS_ZEDS091 = LS_091
*     I_CLEAR    =
*     I_AUTO_FLAG       =
    TABLES
      IT_ZEDS110 = LT_ZEDS110
      IT_ZEDS059 = LT_ZEDS059
    CHANGING
      IS_ZEDS057 = LS_ZEDS057
      IS_ZEDS058 = LS_ZEDS058.

  IF LS_ZEDS058-OUT_WID IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ELSE.

    CLEAR PV_ERROR.          "   lv_sap_millca_factor TYPE atwrt.
    PERFORM READ_ET_CHAR USING 'SAP_MILLCA_LENGTH'
    CHANGING PV_ERROR LV_SAP_MILLCA_LENGTH.

    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
               PV_SPART  TO GT_AREA-WIDTH.
*               lv_sap_millca_factor TO gt_area-menge.

*    " 포장재 수량
*    IF NOT lv_sap_millca_length IS INITIAL.
*      PERFORM change_string_replace
*      USING ',' CHANGING lv_sap_millca_length.
*      CONDENSE lv_sap_millca_length NO-GAPS.
*      MOVE lv_sap_millca_length TO lv_menge.
*    ENDIF.

    " 조장
    MOVE: GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

    " 납품수량 / 조장
    IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
      PERFORM CALCULATION_EXCEPTION_HANDING
        USING GT_LIPS-LFIMG '/' LV_MENGE CHANGING GT_AREA-MENGE.
    ENDIF.

    " 6) 펑션 결과 ZEDS058에 나온 외폭 OUT_DIA를 10으로 나눠 가로로
    " 인식하고 플랜지경 PLAN_DIA를 10으로 나눠 세로와 높이로 인식
    " (mm가 아닌 cm로 변환하기 위함)

*    IF NOT ls_zeds058-out_wid IS INITIAL.
*      gt_area-width = ls_zeds058-out_wid.
*    ENDIF.
*
*    IF NOT ls_zeds058-plan_dia IS INITIAL.
*      gt_area-height = gt_area-zlength = ls_zeds058-plan_dia .
*    ENDIF.

    " 포장재 코드
*    PERFORM read_et_char USING 'SAP_MILLCA_PACKAGING'
*CHANGING pv_error gt_area-pkmatnr.
    CLEAR PV_ERROR.

    GT_AREA-PMEINS = 'KG'.
    GT_AREA-PKTYP = 'DM'.
    GT_AREA-DMMATNR = LS_ZEDS058-DRUM_NO.
*    APPEND gt_area. CLEAR gt_area.

    SORT GT_0210 BY DR_GBN SG_GBN DRUM_DET DRUM_NO.

    CLEAR GT_0210.
    READ TABLE GT_0210 WITH KEY DR_GBN  = 'G'
                               SG_GBN   = 'D'
                               DRUM_DET = 'S'
                               DRUM_NO  = LS_ZEDS058-DRUM_NO
                   BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      MOVE GT_0210-OUT_WID TO GT_AREA-WIDTH.
*      MOVE gt_0210-plan_dia TO gt_area-zlength.
*      MOVE gt_0210-plan_dia TO gt_area-height.

      IF NOT GT_0210-PK_WD_THK IS INITIAL.
        PERFORM CALCULATION_EXCEPTION_HANDING
          USING GT_0210-PK_WD_THK '*' 2 CHANGING LV_WD_THK.
      ENDIF.

      GT_AREA-HEIGHT = GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_WD_THK.

      "  포장재 무게
      GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
    ENDIF.

  ENDIF.

  "  mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
  ENDIF.

ENDFORM.                    " GET_SPART_23
*&---------------------------------------------------------------------*
*&      Form  GET_VOLTAG_ATWRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VOLTAG_ATWRT  text
*----------------------------------------------------------------------*
FORM GET_VOLTAG_ATWRT  USING    PV_VOLTAG_ATWRT CHANGING PV_RATE.

  DATA: LV_CHAR40    TYPE CHAR30,
        LV_CHAR,
        LV_CHAR20    TYPE CHAR20,
        LV_TYPE      LIKE DD01V-DATATYPE,
        LV_INT       TYPE I,
        LV_INT2      TYPE I,
        LV_DEC3      TYPE P DECIMALS 3,
        LV_INT_VALUE TYPE I.

  MOVE PV_VOLTAG_ATWRT TO LV_CHAR40.
  CONDENSE LV_CHAR40 NO-GAPS.
  LV_INT = STRLEN( LV_CHAR40 ).

  "             ⅰ) 맨 오른쪽 문자 2개가 KV가 아니라면 '15'
  IF LV_INT >= 2.
    SUBTRACT 2 FROM LV_INT.
    IF LV_CHAR40+LV_INT(2) <> 'KV'.
      PV_RATE = 15.
      RETURN.
    ENDIF.
  ENDIF.

  LV_INT = STRLEN( LV_CHAR40 ).

  DO LV_INT TIMES.

    MOVE SY-INDEX TO LV_INT2.
    SUBTRACT 1 FROM LV_INT2.
    IF LV_CHAR40+LV_INT2(1) CN '.1234567890'.
      CLEAR LV_CHAR40+LV_INT2(1).
    ENDIF.

  ENDDO.

  CONDENSE LV_CHAR40 NO-GAPS.
  MOVE LV_CHAR40 TO LV_DEC3.

  "  ⅱ) 값 중에서 '/', 특문, 영문, 공백을 제외한
  " 숫자값이 6을 초과하면 20
  IF LV_DEC3 > 6.
    PV_RATE = 20.
    " ⅲ) 나머지는 17(맨 오른쪽 문자 2개가 KV이면서
    " '/', 특문, 영문, 공백을 제외한 숫자값이 6이하)
  ELSE.
    PV_RATE = 17.
  ENDIF.

ENDFORM.                    " GET_VOLTAG_ATWRT
*&---------------------------------------------------------------------*
*&      Form  GET_GON_GONG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_OUT_DIA_ATWRT  text
*      <--P_LT_ZEDS110_GON_GONG  text
*----------------------------------------------------------------------*
FORM GET_GON_GONG  USING  PV_DIA_ATWRT
                                 CHANGING PV_GON_GONG.

*          권공 GON_GONG은 "PD_CA_PROC_OUT_DIA"의 ATWRT 값에 따라 달라짐
*            ⅰ) 30이하면 50
*            ⅱ) 50초과면 100
*            ⅲ) 나머지는 70(30초과 50이하)

  IF PV_DIA_ATWRT <= 30.
    MOVE 50 TO PV_GON_GONG.
  ELSEIF PV_DIA_ATWRT > 50.
    MOVE 100 TO PV_GON_GONG.
  ELSE.
    MOVE 70 TO PV_GON_GONG.
  ENDIF.

ENDFORM.                    " GET_GON_GONG
*&---------------------------------------------------------------------*
*&      Form  GET_PALETTE_23
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_9655   text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_PALETTE_23  USING  PV_VBELN
                                                 PV_POSNR
                                                 PV_SPART
                                                 PV_VGBEL
                                                 PV_VGPOS
                                                 PV_MATNR
                                                 PV_KUNNR
                                                 PS_LIPS LIKE GT_LIPS
                                CHANGING PV_ERROR.

  DATA: LV_PRODUCT_NAME TYPE ATWRT,
        LV_VOLTAGE      TYPE ATWRT,
        LV_LENGTH       TYPE ATWRT,
        LV_CORE_NO      TYPE ATWRT,
        LV_COND_SIZE    TYPE ATWRT,
        LV_COND_DIA     TYPE ATWRT.

  REFRESH GT_ET_CHAR.

  "  S/O  특성
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  IF NOT PV_ERROR IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

*      3) 특성값에서 표준품명(PD_AA_STD_PRODUCT_NAME),
*전압(PD_CA_VOLTAGE), 조장(SAP_LENGTH_VKRME),
*도체수(PD_CA_CORE_NO_1ST), 도체사이즈(PD_CA_COND_SIZE_1ST),
*       소선경(PD_CA_COND_DIA_1ST)의 ATWRT를 구한다.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_AA_STD_PRODUCT_NAME' CHANGING PV_ERROR LV_PRODUCT_NAME.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_VOLTAGE' CHANGING PV_ERROR LV_VOLTAGE.

  PERFORM READ_ET_CHAR
    USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_LENGTH.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_CORE_NO_1ST' CHANGING PV_ERROR LV_CORE_NO.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_COND_SIZE_1ST' CHANGING PV_ERROR LV_COND_SIZE.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_COND_DIA_1ST' CHANGING PV_ERROR LV_COND_DIA.

  " 2-2. 제품군 20(다발, 합판보빈을 팔레트 적재)
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_READ_0510
    USING PV_SPART LV_PRODUCT_NAME LV_VOLTAGE LV_LENGTH
          LV_CORE_NO LV_COND_SIZE LV_COND_DIA PV_VBELN
          PV_POSNR
 CHANGING PV_ERROR GT_AREA.

ENDFORM.                    " GET_PALETTE_23
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_24
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_24.

  LOOP AT GT_LIPS WHERE SPART EQ 24.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    " 5-2. 제품군 23(다발 팔레트 적재
    PERFORM GET_PALETTE_23
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS
            CHANGING GV_ERROR.
    IF GV_ERROR IS INITIAL.
      MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                 GT_LIPS-POSNR TO GT_AREA-POSNR.
      MOVE '24-C' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.
    ENDIF.

    " 5-1 제품군  23(드럼 적재)
    " MTO 인 경우

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_20
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS-CHARG
            GT_LIPS-WERKS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

    " MTS 경우
    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_23
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
      GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                 GT_LIPS-POSNR TO GT_AREA-POSNR.
      MOVE '24-B' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_24
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_30
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_30.

  LOOP AT GT_LIPS WHERE SPART EQ 30.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_30
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR
      CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_30

*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_CHARACT_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_OBJECT  text
*      -->P_GT_AREA_PKMATNR  text
*----------------------------------------------------------------------*
FORM GET_MATERIAL_CHARACT TABLES   PT_OBJECT STRUCTURE GT_OBJECT
                                USING    PV_MATNR.

  DATA: LV_OBJECT TYPE AUSP-OBJEK.
  DATA: LT_CLASS TYPE SCLASS OCCURS 0 WITH HEADER LINE.

  CHECK NOT PV_MATNR IS INITIAL.

  PERFORM CONVERSION_ATNAM USING PV_MATNR CHANGING LV_OBJECT.

  "포장재 코드로  특성을 찾는다.
  CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
    EXPORTING
      CLASSTYPE          = '001'
      OBJECT             = LV_OBJECT
    TABLES
      T_CLASS            = LT_CLASS
      T_OBJECTDATA       = PT_OBJECT
    EXCEPTIONS
      NO_CLASSIFICATION  = 1
      NO_CLASSTYPES      = 2
      INVALID_CLASS_TYPE = 3
      OTHERS             = 4.

  SORT PT_OBJECT BY ATNAM AUSP1.

  DELETE PT_OBJECT WHERE AUSP1 EQ '?'.

ENDFORM.                    " GET_MATNR_CHARACT_OBJECTS
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_ATNAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_MATNR  text
*      <--P_LV_OBJECT  text
*----------------------------------------------------------------------*
FORM CONVERSION_ATNAM  USING    PV_MATNR
                       CHANGING PV_OBJECT.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_OBJECT.

ENDFORM.                    " CONVERSION_ATNAM
*&---------------------------------------------------------------------*
*&      Form  CHANGE_STRING_REPLACE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8552   text
*      <--P_GV_OBJECT  text
*----------------------------------------------------------------------*
FORM CHANGE_STRING_REPLACE  USING PV_PATTERN
                            CHANGING PV_OBJECT.

  CHECK NOT PV_OBJECT IS INITIAL.

  CALL FUNCTION 'STRING_REPLACE'
    EXPORTING
      PATTERN             = PV_PATTERN
      SUBSTITUTE          = ''
*     MAX_REPLACES        = 0
* IMPORTING
*     NUMBER_OF_REPLACES  =
    CHANGING
      TEXT                = PV_OBJECT
    EXCEPTIONS
      WRONG_STRING_LENGTH = 1
      OTHERS              = 2.

ENDFORM.                    " CHANGE_STRING_REPLACE
*&---------------------------------------------------------------------*
*&      Form  CHANGE_STRING_NOGAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_OBJECT  text
*----------------------------------------------------------------------*
FORM CHANGE_STRING_NOGAP  CHANGING PV_OBJECT.

  CONDENSE PV_OBJECT NO-GAPS.

ENDFORM.                    " CHANGE_STRING_NOGAP
*&---------------------------------------------------------------------*
*&      Form  READ_MATNR_CHARACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8546   text
*      <--P_GV_OBJECT  text
*----------------------------------------------------------------------*
FORM READ_MATNR_CHARACT  TABLES PT_OBJECT STRUCTURE GT_OBJECT
                                          USING   PV_NAME TYPE ATNAM
                                     CHANGING PV_ERROR PV_OBJECT.

  CLEAR: PT_OBJECT, PV_ERROR.
  READ TABLE PT_OBJECT WITH KEY ATNAM = PV_NAME
                                  BINARY SEARCH.

  IF SY-SUBRC EQ 0.
    MOVE PT_OBJECT-AUSP1 TO PV_OBJECT.
  ELSE.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " READ_MATNR_CHARACT
*&---------------------------------------------------------------------*
*&      Form  GET_0510_21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_SPART  text
*      -->P_PV_KUNNR  text
*      -->P_LV_NAME_ATWRT  text
*      -->P_LV_SIZE_ATWRT  text
*      -->P_LV_LENGTH_ATWRT  text
*      <--P_PV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_0510_21  USING PV_SPART
                        PV_KUNNR
                        PV_NAME
                        PV_SIZE
                        PV_LENGTH
                        PS_0510    LIKE GT_0510
                        PV_FLAG
               CHANGING PV_ERROR.

  DATA: LV_STD_NAME    LIKE ZLET0510-STD_NAME,
        LV_COND_SIZE   LIKE ZLET0510-COND_SIZE,
        LV_LENGTH_FROM LIKE ZLET0510-LENGTH_FROM,
        LV_SALES_FLAG  LIKE ZLET0510-SALES_FLAG.

  MOVE: PV_NAME   TO LV_STD_NAME,
        PV_SIZE   TO LV_COND_SIZE,
        PV_LENGTH TO LV_LENGTH_FROM.

  IF PV_FLAG EQ '4D'.
    MOVE 1 TO LV_SALES_FLAG.
  ELSE.
    MOVE 2 TO LV_SALES_FLAG.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_0510
    FROM ZLET0510
   WHERE SPART       EQ PV_SPART
     AND KUNNR       EQ PV_KUNNR
     AND STD_NAME    EQ LV_STD_NAME
     AND COND_SIZE   EQ LV_COND_SIZE
     AND LENGTH_FROM <= LV_LENGTH_FROM
     AND LENGTH_TO   >= LV_LENGTH_FROM
     AND SALES_FLAG  =  LV_SALES_FLAG.

  IF SY-SUBRC <> 0.

    " Kunnr  이 없는 경우
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_0510
      FROM ZLET0510
     WHERE SPART       EQ PV_SPART
       AND KUNNR       EQ ' '
       AND STD_NAME    EQ LV_STD_NAME
       AND COND_SIZE   EQ LV_COND_SIZE
       AND LENGTH_FROM <= LV_LENGTH_FROM
       AND LENGTH_TO   >= LV_LENGTH_FROM
       AND SALES_FLAG  =  LV_SALES_FLAG.

    IF SY-SUBRC <> 0.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

  ENDIF.

  READ TABLE GT_0510 INDEX 1 INTO PS_0510.

ENDFORM.                    " GET_0510_21
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_BOBIN_41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_1753   text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_BOBIN_41  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_VGBEL
                                             PV_VGPOS
                                             PV_MATNR
                                             PV_KUNNR
                            CHANGING PV_ERROR.

  DATA: LV_SAP_MILLCA_PACKAGING TYPE ATWRT.
  DATA: LV_SAP_LENGTH_VKRME LIKE AUSP-ATINN .
  DATA: LV_SAP_MILLCA_FACTOR TYPE ATWRT.
*
  DATA: LV_HOR_ATWRT TYPE ATWRT.
  DATA: LV_VER_ATWRT TYPE ATWRT.
  DATA: LV_HEIGHT_ATWRT TYPE ATWRT,
        LV_MENGE        TYPE P DECIMALS 3.

  "    2) 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
  " 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.

  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'SAP_MILLCA_PACKAGING'
    CHANGING PV_ERROR LV_SAP_MILLCA_PACKAGING.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_SAP_LENGTH_VKRME.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'SAP_MILLCA_FACTOR' CHANGING PV_ERROR LV_SAP_MILLCA_FACTOR.

  PERFORM GET_0510_41
    USING PV_SPART  LV_SAP_MILLCA_PACKAGING "lv_sap_length_vkrme
         LV_SAP_MILLCA_FACTOR
   CHANGING PV_ERROR GT_0510.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  MOVE: GT_0510-PKKTX          TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2    TO GT_AREA-PKMATNR.
  MOVE LV_SAP_MILLCA_FACTOR TO LV_MENGE.
  "  총 적재수 / 적재단수
  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING LV_MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  "  포장재코드의 특성 PK_AA_HORIZONTAL(가로), PK_AA_VERTICAL(세로),
  " PK_AA_HEIGHT(높이)에서 숫자값을 10으로 나눈값
  " (mm가 아닌 cm로 환산하기 위함)

*  PERFORM read_et_char USING 'PK_AA_HORIZONTAL'
* CHANGING gv_error lv_hor_atwrt.
*  PERFORM read_et_char USING 'PK_AA_VERTICAL'
* CHANGING gv_error lv_ver_atwrt.
*
*  PERFORM read_et_char USING 'PK_AA_HEIGHT'
* CHANGING gv_error lv_height_atwrt.

  MOVE: PV_VBELN TO GT_AREA-VBELN,
             PV_POSNR  TO GT_AREA-POSNR,
*             pv_spart TO gt_area-spart,
*             pv_vgbel TO gt_area-vgbel,
*             pv_vgpos TO gt_area-vgpos,
*             lv_hor_atwrt TO gt_area-width,
*             lv_ver_atwrt TO gt_area-zlength.
             GT_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
*             gt_0510-pkweight2 TO gt_area-pkwei,
             GT_0510-PKMEINS2 TO GT_AREA-PMEINS.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "    6) 가로, 세로는 최종포장재코드의 가로, 세로를 표시하고
  " 높이는 1차 포장재코드의 높이(COIL_HEIGHT X 적재단수)와
  " 최종포장재 높이를 더하여 표시
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
     NOT GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
      CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD  GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`
*  IF NOT gt_area-width IS INITIAL.
*    gt_area-width = gt_area-width / 10.
*  ENDIF.
*
*  IF NOT gt_area-zlength IS INITIAL.
*    gt_area-zlength = gt_area-zlength / 10.
*  ENDIF.
*
*  IF NOT lv_height_atwrt IS INITIAL.
*    lv_height_atwrt = lv_height_atwrt / 10.
*    ADD lv_height_atwrt TO gt_area-height.
*  ENDIF.
  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
    INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.
  MOVE  '41-J' TO GT_AREA-CODE_POINT.
  APPEND GT_AREA. CLEAR GT_AREA.
  RETURN.

ENDFORM.                    " GET_SPART_BOBIN_41
*&---------------------------------------------------------------------*
*&      Form  GET_0510_41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_SPART  text
*      -->P_PV_KUNNR  text
*      -->P_LV_PACKING_ATWRT  text
*      <--P_PV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_0510_41  USING PV_SPART PV_BOBIN
                                           "pv_from
                       PV_TO
                CHANGING PV_ERROR
                         PS_0510 LIKE GS_0510.

  DATA: LV_SPART       LIKE ZLET0510-SPART,
        LV_ZBOBIN      LIKE ZLET0510-ZBOBIN,
        LV_FACTOR_FROM LIKE ZLET0510-FACTOR_FROM,
        LV_FACTOR_TO   LIKE ZLET0510-FACTOR_TO.

  MOVE: PV_SPART          TO LV_SPART,
             PV_BOBIN TO LV_ZBOBIN,
             PV_TO TO LV_FACTOR_FROM,
             PV_TO TO LV_FACTOR_TO.

  CLEAR GS_0510.
  SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF PS_0510
     FROM ZLET0510
    WHERE SPART   EQ LV_SPART
         AND ZBOBIN EQ LV_ZBOBIN
         AND ( FACTOR_FROM  <= LV_FACTOR_FROM
         AND FACTOR_TO >= LV_FACTOR_TO ).

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_0510_41
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_30
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_1753   text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_30  USING  PV_VBELN
                                             PV_POSNR
                                             PV_SPART
                                             PV_VGBEL
                                             PV_VGPOS
                                             PV_MATNR
                                             PV_KUNNR
                            CHANGING PV_ERROR.

  DATA: LV_BOBIN_ATWRT TYPE ATWRT.
  DATA: LV_ATINN LIKE AUSP-ATINN .
  DATA: LV_FACTOR_ATWRT TYPE ATWRT.
*
  DATA: LV_HOR_ATWRT TYPE ATWRT.
  DATA: LV_VER_ATWRT TYPE ATWRT.
  DATA: LV_HEIGHT_ATWRT TYPE ATWRT.

  DATA: LS_VBFA TYPE VBFA.

  " 20-A 상품의 사용 드럼 정보 검색
  PERFORM GET_SPART_20_A USING  PV_VBELN PV_POSNR
                                         PV_SPART
                                         PV_VGBEL
                                         PV_VGPOS
                                         PV_MATNR
                                         PV_KUNNR
                        CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN TO GT_AREA-VBELN,
               PV_POSNR  TO GT_AREA-POSNR,
               PV_SPART TO GT_AREA-SPART,
               '30-A' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  "    2) 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
  " 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.

  REFRESH GT_ET_CHAR.
  CLEAR PV_ERROR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  SORT GT_ET_CHAR BY ATNAM ATWRT.
*  DELETE ADJACENT DUPLICATES FROM gt_et_char COMPARING atnam.

  "    3) ATINN "PD_CA_PACKMARK_STATUS"의 ATWRT "CM"인 ATINN
  " "SAP_MILLCA_PACKAGING"의 ATWRT를 구한다.(최종 포장재 코드)
  CLEAR GT_ET_CHAR.
  READ TABLE GT_ET_CHAR WITH KEY ATNAM =  'PD_CA_PACKMARK_STATUS'
                                 ATWRT = 'CM'
                        BINARY SEARCH.

  IF SY-SUBRC EQ 0.

    CLEAR: PV_ERROR, GV_ATWRT.
    PERFORM READ_ET_CHAR
    USING 'SAP_MILLCA_PACKAGING' CHANGING PV_ERROR GV_ATWRT.

    IF GV_ERROR IS INITIAL.

      PERFORM MATERIALCHARACTERISTIC_GET_30
      USING PV_SPART GV_ATWRT PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.

        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR.
        MOVE '30-B' TO GT_AREA-CODE_POINT.

        APPEND GT_AREA. CLEAR GT_AREA.

        RETURN.

      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR: PV_ERROR, GT_AREA.

  "  해당하는 값이 없고 LIPS-VGBEL의 VBAK-AUART="ZCS"이면
  " 아래 순서로 처리한다.
  PERFORM GET_CHARACTERISTIC_20
    USING PV_SPART PV_VGBEL PV_VGPOS GC_X CHANGING PV_ERROR GT_AREA.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR.
    MOVE '30-C' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  CLEAR: GT_VBAK, PV_ERROR, GT_AREA.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  IF GT_VBAK-AUART EQ 'ZCS'.

    "  선행 오더의 철드럼 제원 찾기

    SELECT SINGLE VBELV POSNV
        INTO (LS_VBFA-VBELV, LS_VBFA-POSNV)
        FROM VBFA
     WHERE VBELN   EQ PV_VGBEL
          AND POSNN EQ PV_VGPOS.

    REFRESH GT_ET_CHAR.
    CLEAR PV_ERROR.

    " Z_LE_GET_CHARACTERISTIC_TABLE2
    PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
      USING LS_VBFA-VBELV LS_VBFA-POSNV CHANGING PV_ERROR.

    SORT GT_ET_CHAR BY ATNAM ATWRT.

    CLEAR: PV_ERROR, GV_ATWRT.
    PERFORM READ_ET_CHAR
      USING 'SAP_MILLCA_PACKAGING' CHANGING PV_ERROR GV_ATWRT.

    IF GV_ERROR IS INITIAL.

      PERFORM MATERIALCHARACTERISTIC_GET_30
        USING PV_SPART GV_ATWRT PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.

        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR.
        MOVE '30-D' TO GT_AREA-CODE_POINT.

        APPEND GT_AREA. CLEAR GT_AREA.

        RETURN.

      ENDIF.

    ENDIF.

  ENDIF.

  "  선행 오더의  목드럽 제원 찾기

  SELECT SINGLE VBELV POSNV
      INTO (LS_VBFA-VBELV, LS_VBFA-POSNV)
      FROM VBFA
   WHERE VBELN   EQ PV_VGBEL
        AND POSNN EQ PV_VGPOS.

  CLEAR: PV_ERROR, GT_AREA.

  "  해당하는 값이 없고 LIPS-VGBEL의 VBAK-AUART="ZCS"이면
  " 아래 순서로 처리한다.
  PERFORM GET_CHARACTERISTIC_20
    USING PV_SPART LS_VBFA-VBELV LS_VBFA-POSNV ' '
    CHANGING PV_ERROR GT_AREA.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR.
    MOVE '30-E' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  " 5-1 제품군  23(드럼 적재)
  " MTO 인 경우
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_SPART_20
    USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
    GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS-CHARG
    GT_LIPS-WERKS CHANGING GV_ERROR.

  IF GV_ERROR IS INITIAL.
    RETURN.
  ENDIF.


  CHECK NOT ( PV_SPART EQ '31' OR PV_SPART EQ '30' ).

  " MTS 경우
  CLEAR: GV_ERROR, GT_AREA.
  PERFORM GET_SPART_23
  USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
  GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS CHANGING GV_ERROR.

  IF GV_ERROR IS INITIAL.

    MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
               GT_LIPS-POSNR TO GT_AREA-POSNR.
    MOVE '23-D' TO GT_AREA-CODE_POINT.

    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.

  ENDIF.

ENDFORM.                    " GET_SPART_30
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_31
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_31.

  LOOP AT GT_LIPS WHERE SPART EQ 31.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CLEAR GV_ERROR.
    PERFORM GET_SPART_30
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
      GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_31
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_32
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_32 .

  LOOP AT GT_LIPS WHERE SPART EQ 32.
    " 조장, 조장수 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    " 포장재 마스터
    CLEAR GV_ERROR.
    PERFORM GET_0510_SPART_32 USING GT_LIPS-VBELN GT_LIPS-POSNR
    GT_LIPS-SPART GT_LIPS-MATNR GT_LIPS-VGBEL GT_LIPS-VGPOS
    CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

    " BOM 검색 후 포장재 마스터 구성
    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_32
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART
            GT_LIPS-MATNR GT_LIPS CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_32
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_32
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_2791   text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_32  USING  PV_VBELN
                          PV_POSNR
                          PV_SPART
                          PV_MATNR
                          PS_LIPS LIKE GT_LIPS
                 CHANGING PV_ERROR.

  DATA: LT_STPOL LIKE STPOL OCCURS 0 WITH HEADER LINE,
        LV_MATNR TYPE MATNR,
        LS_0510  LIKE ZLET0510,
        LV_INT   TYPE P DECIMALS 2,
        LV_MENGE LIKE LT_STPOL-MENGE.

  REFRESH LT_STPOL.
  " BOM 전개
  PERFORM CS_BOM_EXPLOSION_MAT TABLES LT_STPOL
    USING PV_MATNR '1302' CHANGING PV_ERROR.

  "  MARA-MTART="ROH1", "ROH2"인 자재코드(목박스)를 구한다.
  LOOP AT LT_STPOL.
    SELECT SINGLE A~MATNR
        INTO LV_MATNR
      FROM MARA AS A INNER JOIN MAKT AS B
          ON A~MATNR EQ B~MATNR
         AND B~SPRAS EQ SY-LANGU
     WHERE A~MATNR EQ LT_STPOL-IDNRK
         AND ( A~MTART EQ GC_ROH1
           OR A~MTART EQ GC_ROH2  ).
*         AND B~MAKTX LIKE '%목박스%'.
    IF SY-SUBRC EQ  0.

    ELSE.
      DELETE LT_STPOL.
    ENDIF.
  ENDLOOP.

  IF LT_STPOL[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.
  "
  LOOP AT LT_STPOL.
    "
    SELECT SINGLE *
         INTO LS_0510
       FROM ZLET0510
     WHERE MATNR EQ LT_STPOL-IDNRK.

    CHECK SY-SUBRC EQ 0.

    " bom 수량 / 1 * 납품수량
    IF NOT  LT_STPOL-MENGE IS INITIAL AND NOT PS_LIPS-LFIMG IS INITIAL.

      PERFORM CALCULATION_EXCEPTION_HANDING
        USING LT_STPOL-MENGE '/' 1 CHANGING LV_MENGE.
      PERFORM CALCULATION_EXCEPTION_HANDING
        USING LV_MENGE '*' PS_LIPS-LFIMG CHANGING GT_AREA-MENGE.

      " 올림
*      CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
*        EXPORTING
*          i_rtype     = '+'
*          i_runit     = 1
*          i_value     = gt_area-menge
*        IMPORTING
*          e_value_rnd = gt_area-menge.

    ENDIF.

    MOVE: "lt_stpol-menge         TO gt_area-menge, " 수량
               LS_0510-PKWIDTH2   TO GT_AREA-WIDTH,  "   가로
               LS_0510-PKLENGTH2  TO GT_AREA-ZLENGTH, "   세로
               LS_0510-PKHEIGHT2  TO GT_AREA-HEIGHT, "  높이`
               LS_0510-PKMATNR2  TO GT_AREA-PKMATNR,
               LS_0510-PKWEIGHT2 TO GT_AREA-PKWEI,
               LS_0510-PKMEINS2 TO GT_AREA-PMEINS,
               LS_0510-PKKTX        TO GT_AREA-PKTYP.
    MOVE PV_VBELN TO GT_AREA-VBELN.
    MOVE PV_POSNR TO GT_AREA-POSNR.
    MOVE '32-B' TO GT_AREA-CODE_POINT.
    CONCATENATE LS_0510-SPART LS_0510-PKKTX LS_0510-SEQNO
      INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.
    APPEND GT_AREA.

  ENDLOOP.

ENDFORM.                    " GET_SPART_32
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_2791   text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_40  USING  PV_VBELN
                                             PV_MATNR
                                             PS_LIPS LIKE GT_LIPS
                            CHANGING PV_ERROR.
*
  DATA: LV_INT   TYPE P DECIMALS 2,
        LV_COUNT TYPE I,
        LV_MENGE TYPE P DECIMALS 3,
        LV_TOTAL TYPE P DECIMALS 2.

  "    3) 특성의 조장수(SAP_MILLCA_FACTOR)를 구하여
  " 납품문서-품목의 전체로 SUM(조장수 전체 합)한다.

  LOOP AT GT_LIPS WHERE VBELN EQ PV_VBELN
                                  AND MATNR EQ PV_MATNR.

    " 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
    " 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.
    REFRESH GT_ET_CHAR.

    " Z_LE_GET_CHARACTERISTIC_TABLE2
    PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
      USING GT_LIPS-VGBEL GT_LIPS-VGPOS CHANGING PV_ERROR.

    IF NOT PV_ERROR IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'SAP_MILLCA_FACTOR' CHANGING PV_ERROR GV_ATWRT.

    MOVE GV_ATWRT TO LV_INT.
    ADD LV_INT TO LV_TOTAL.
    ADD 1 TO LV_COUNT.

  ENDLOOP.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_0510
     FROM ZLET0510
    WHERE SPART  EQ '40'.

  IF GT_0510[] IS INITIAL.

    MOVE GC_X TO PV_ERROR.
    RETURN.

  ENDIF.

  READ TABLE GT_0510 INDEX 1.

  MOVE: GT_0510-PKKTX        TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2  TO GT_AREA-PKMATNR,
             GT_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             GT_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
*             gt_0510-pkheight2 TO gt_area-height, "  높이`
*             gt_0510-pkweight2 TO gt_area-pkwei,
             GT_0510-PKMEINS2  TO GT_AREA-PMEINS.

  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_TOTAL IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_TOTAL '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_COUNT IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0510-PKWEIGHT1 '*' LV_COUNT CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
         GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
            CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

  SORT GT_LIPS BY VBELN MATNR POSNR.

  " 품목 번호가 빠른거 하나 읽는다.
  READ TABLE GT_LIPS WITH KEY VBELN = PV_VBELN
                              MATNR = PV_MATNR
                     BINARY SEARCH.

  MOVE GT_LIPS-VBELN TO GT_AREA-VBELN.
  MOVE GT_LIPS-POSNR TO GT_AREA-POSNR.
  MOVE '40-A' TO GT_AREA-CODE_POINT.
  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
    INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.
  APPEND GT_AREA.

ENDFORM.                    " GET_SPART_40
*&---------------------------------------------------------------------*
*&      Form  CS_BOM_EXPLOSION_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_STPOL  text
*      -->P_PV_MATNR  text
*      -->P_ENDFORM  text
*----------------------------------------------------------------------*
FORM CS_BOM_EXPLOSION_MAT  TABLES PT_STPOL STRUCTURE STPOL
                            USING PV_MATNR PV_WERKS
                         CHANGING PV_ERROR.

  DATA: LV_CAPID TYPE TC04-CAPID,
        LV_DATUV TYPE SY-DATUM,
        LV_MEHRS TYPE CSDATA-XFELD,
        LV_EMENG TYPE STKO-BMENG,
        LV_MTNRV TYPE MARA-MATNR,
        LV_STLAN TYPE STZU-STLAN,
        LV_WERKS TYPE MARC-WERKS.

  MOVE: 'PP01' TO LV_CAPID,
              SY-DATUM TO LV_DATUV,
*              GC_x          TO LV_MEHRS,
              1                 TO LV_EMENG,
              PV_MATNR TO LV_MTNRV,
              1                 TO LV_STLAN,
              PV_WERKS TO LV_WERKS.

  CALL FUNCTION 'CS_BOM_EXPLOSION_MAT'
    EXPORTING
      CAPID                 = LV_CAPID
*     COSPR                 = ' '
*     CUOBJ                 = 000000000000000
      DATUV                 = LV_DATUV
*     DELNL                 = ' '
      EMENG                 = LV_EMENG
*     ERSKZ                 = ' '
*     ERSSL                 = ' '
*     FBSTP                 = ' '
*     MBWLS                 = ' '
*     MDMPS                 = ' '
      MEHRS                 = LV_MEHRS
*     MKMAT                 = ' '
      MTNRV                 = LV_MTNRV
*     POSTP                 = ' '
*     RNDKZ                 = ' '
*     RVREL                 = ' '
*     SANFR                 = ' '
*     SANIN                 = ' '
*     SANKA                 = ' '
*     SANKO                 = ' '
*     SANVS                 = ' '
*     SCHGT                 = ' '
*     STKKZ                 = ' '
*     STLAL                 = ' '
      STLAN                 = LV_STLAN
      WERKS                 = LV_WERKS
*   IMPORTING
*     TOPMAT                =
    TABLES
      STB                   = PT_STPOL
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      OTHERS                = 8.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " CS_BOM_EXPLOSION_MAT
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_40.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.

  MOVE GT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY VBELN MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN MATNR.

  LOOP AT LT_LIPS WHERE SPART EQ 40.

    " 조장, 조장수를 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_SPART_40
      USING LT_LIPS-VBELN LT_LIPS-MATNR LT_LIPS CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_40
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_41.

  LOOP AT GT_LIPS WHERE SPART EQ 41.

    " 조장, 조장수를 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    " 12-3. 제품군 41(광접속재를 팔레트 적재)
    CLEAR:  GV_ERROR, GT_AREA.
    PERFORM GET_SPART_LIGHT_41
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR CHANGING GV_ERROR.

    IF  GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

    " 제품군 41(보빈을 팔레트 적재)
    CLEAR:  GV_ERROR, GT_AREA.
    PERFORM GET_SPART_BOBIN_41
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR CHANGING GV_ERROR.

    IF  GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR:  GV_ERROR, GT_AREA.
    PERFORM GET_SPART_41
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR GT_LIPS CHANGING GV_ERROR.

    IF  GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_41
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_43
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_43.

  DATA: LV_KDKG4 TYPE VBKD-KDKG4.

  LOOP AT GT_LIPS WHERE SPART EQ 43.

    " 조장, 조장수를 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    " 23, 24, 41, 43, 44 제품군에 대해서 납품절단,
    " 재고 절단 로직 추가
    CASE GT_LIPS-SPART.
      WHEN '23' OR '24' OR '41' OR '43' OR '44'.

        " 2. 납품절단
        CLEAR: GV_ERROR, GT_AREA.
        PERFORM GET_SPART_20_SPLIT USING  GT_LIPS-VBELN
                                                              GT_LIPS-POSNR
                                                              GT_LIPS-VGBEL
                                                              GT_LIPS-VGPOS
                                                              GT_LIPS-SPART
                                                              GT_LIPS-MATNR
                                             CHANGING GV_ERROR.

        IF  GV_ERROR IS INITIAL.
          MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                     GT_LIPS-POSNR TO GT_AREA-POSNR,
                       '43-A'   TO GT_AREA-CODE_POINT.
          APPEND GT_AREA. CLEAR GT_AREA.
          CONTINUE.
        ENDIF.

        " 3. 재고 절단
        CLEAR: GV_ERROR, GT_AREA.
        PERFORM GET_SPART_20_STOCK_SPLIT USING  GT_LIPS-VBELN
                                                              GT_LIPS-POSNR
                                                              GT_LIPS-VGBEL
                                                              GT_LIPS-VGPOS
                                                              GT_LIPS-SPART
                                                              GT_LIPS-MATNR
                                                              GT_LIPS-CHARG
                                                              GT_LIPS-WERKS
                                             CHANGING GV_ERROR.

        IF  GV_ERROR IS INITIAL.
          MOVE: GT_LIPS-VBELN  TO GT_AREA-VBELN,
                     GT_LIPS-POSNR TO GT_AREA-POSNR,
                       '43-B'   TO GT_AREA-CODE_POINT.
          APPEND GT_AREA. CLEAR GT_AREA.
          CONTINUE.
        ENDIF.

    ENDCASE.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CLEAR GV_ERROR.
    " 20-A 상품의 사용 드럼 정보 검색
    PERFORM GET_SPART_20_A USING  GT_LIPS-VBELN GT_LIPS-POSNR
                                           GT_LIPS-SPART
                                           GT_LIPS-VGBEL
                                           GT_LIPS-VGPOS
                                           GT_LIPS-MATNR
                                           GT_VBAK-KUNNR
                          CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      MOVE: GT_LIPS-VBELN TO GT_AREA-VBELN,
                 GT_LIPS-POSNR  TO GT_AREA-POSNR,
                 GT_LIPS-SPART TO GT_AREA-SPART,
                 '43-C' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.
    ENDIF.

    " 배선자재
    CLEAR: GV_ERROR, GT_AREA.
    PERFORM GET_ZLET0600T
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR GT_LIPS LV_KDKG4
      CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      MOVE '43-D' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      CONTINUE.
    ENDIF.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    SELECT SINGLE KDKG4
         INTO LV_KDKG4
        FROM VBKD
     WHERE VBELN EQ GT_LIPS-VGBEL.
*         AND posnr EQ gt_lips-vgpos.

    CLEAR GV_ERROR.
    PERFORM GET_SPART_43
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
        GT_LIPS-VGPOS GT_LIPS-MATNR GT_LIPS LV_KDKG4 CHANGING GV_ERROR.

    IF GV_ERROR IS INITIAL.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_43
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_SPART_44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_SPART_44.

  LOOP AT GT_LIPS WHERE SPART EQ 44.

    " 조장, 조장수를 읽기 위해서
    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                                        POSNR = GT_LIPS-POSNR
                                           BINARY SEARCH.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.
    CLEAR GV_ERROR.
    PERFORM GET_SPART_44
      USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
            GT_LIPS-VGPOS GT_LIPS-MATNR GT_LIPS CHANGING GV_ERROR.

  ENDLOOP.

ENDFORM.                    " GET_PACKING_SPART_44
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_41  USING  PV_VBELN
                         PV_POSNR
                         PV_SPART
                         PV_VGBEL
                         PV_VGPOS
                         PV_MATNR
                         PS_LIPS LIKE GT_LIPS
                 CHANGING PV_ERROR.

  DATA: LT_STPOL LIKE STPOL OCCURS 0 WITH HEADER LINE.
  DATA: LS_VBFA  LIKE VBFA,
        LV_DEC4  TYPE P DECIMALS 4,
        LV_DEC3  TYPE P DECIMALS 3,
        LV_MATNR TYPE MATNR.


  DATA: LS_EKKN        LIKE EKKN,
        LV_DRUM_NUMBER TYPE ZMMT0217-DRUM_NUMBER.
*
*  CLEAR pv_error.
*
*  "  판매오더와 품목을 EKKN-VBELN, VBELP에 넣어
* 구매오더(EBELN)와 품목(EBELP)을 구한다.
*  PERFORM check_ekkn USING pv_vbeln pv_posnr CHANGING
*pv_error ls_ekkn.
*
*  IF pv_error IS INITIAL.
*
*    PERFORM check_zmmt0217
*USING ls_ekkn-ebeln ls_ekkn-ebelp
*CHANGING pv_error lv_drum_number.
*
*    " 위에서 드럼기호를 구하지 못한다면 펑션
*Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
*판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.
*    IF lv_drum_number IS INITIAL.
*
*      PERFORM get_zmmt0217_drum_number USING pv_vgbel pv_vgpos
* pv_matnr CHANGING pv_error lv_drum_number gt_area.
*
*    ENDIF.
*
*    PERFORM get_create_area_44 CHANGING lv_drum_number pv_error.
*
*    IF pv_error IS INITIAL.
*      MOVE: pv_vbeln  TO gt_area-vbeln,
*                 pv_posnr TO gt_area-posnr.
*      APPEND gt_area. CLEAR gt_area.
*      RETURN.
*    ENDIF.
*
*  ENDIF.
*
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_CHARACTERISTIC_20
    USING PV_SPART PV_VGBEL PV_VGPOS GC_X CHANGING PV_ERROR GT_AREA.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
              '41-B' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  " 23, 24, 41, 43, 44 제품군에 대해서 납품절단,
  " 재고 절단 로직 추가
  CASE PV_SPART.
    WHEN '23' OR '24' OR '41' OR '43' OR '44'.

      " 2. 납품절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_SPLIT USING  PV_VBELN
                                                            PV_POSNR
                                                            PV_VGBEL
                                                            PV_VGPOS
                                                            PV_SPART
                                                            PV_MATNR
                                           CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '41-C'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

      " 3. 재고 절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_STOCK_SPLIT USING  PV_VBELN
                                                            PV_POSNR
                                                            PV_VGBEL
                                                            PV_VGPOS
                                                            PV_SPART
                                                            PV_MATNR
                                                            PS_LIPS-CHARG
                                                            PS_LIPS-WERKS
                                           CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '41-D'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

  ENDCASE.

  CLEAR PV_ERROR.

  "  판매오더와 품목을 EKKN-VBELN, VBELP에
  " 넣어 구매오더(EBELN)와 품목(EBELP)을 구한다.
  PERFORM CHECK_EKKN
    USING PV_VBELN PV_POSNR CHANGING PV_ERROR LS_EKKN.

  PERFORM CHECK_ZMMT0217
    USING LS_EKKN-EBELN LS_EKKN-EBELP CHANGING PV_ERROR LV_DRUM_NUMBER.

  " 위에서 드럼기호를 구하지 못한다면 펑션
  " Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에 판매오더와
  " 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.

*  IF lv_drum_number IS INITIAL.     "기능개선 160066 - 삭제
  PERFORM GET_ZMMT0217_DRUM_NUMBER
    USING PV_VGBEL PV_VGPOS PV_MATNR
    CHANGING PV_ERROR LV_DRUM_NUMBER GT_AREA.
*  ENDIF.

  PERFORM GET_CREATE_AREA_44 CHANGING LV_DRUM_NUMBER PV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
              '41-E' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  CLEAR: GT_VBAK, PV_ERROR, GT_AREA.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  IF GT_VBAK-AUART EQ 'ZCS'.

    SELECT SINGLE VBELV POSNV
        INTO (LS_VBFA-VBELV, LS_VBFA-POSNV)
        FROM VBFA
     WHERE VBELN   EQ PV_VGBEL
          AND POSNN EQ PV_VGPOS.

    CLEAR: PV_ERROR, GT_AREA.
    PERFORM GET_CHARACTERISTIC_20
      USING PV_SPART LS_VBFA-VBELV LS_VBFA-POSNV ' '
        CHANGING PV_ERROR GT_AREA.

    IF PV_ERROR IS INITIAL.
      MOVE: PV_VBELN  TO GT_AREA-VBELN,
                 PV_POSNR TO GT_AREA-POSNR,
                '41-F' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      RETURN.
    ENDIF.

  ENDIF.

  CLEAR: PV_ERROR, GT_AREA.
*
  "  판매오더와 품목을 EKKN-VBELN, VBELP에 넣어
  " 구매오더(EBELN)와 품목(EBELP)을 구한다.
  PERFORM CHECK_EKKN USING PV_VBELN PV_POSNR CHANGING PV_ERROR LS_EKKN.

  CLEAR: PV_ERROR, GT_AREA.
  PERFORM CHECK_ZMMT0217
    USING LS_EKKN-EBELN LS_EKKN-EBELP CHANGING PV_ERROR LV_DRUM_NUMBER.

  " 위에서 드럼기호를 구하지 못한다면 펑션
  " Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
  " 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.
*  IF lv_drum_number IS INITIAL.     "기능개선 160066 - 삭제

  PERFORM GET_ZMMT0217_DRUM_NUMBER
    USING PV_VGBEL PV_VGPOS PV_MATNR
    CHANGING PV_ERROR LV_DRUM_NUMBER GT_AREA.

*  ENDIF.

  PERFORM GET_CREATE_AREA_44 CHANGING LV_DRUM_NUMBER PV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
               '41-G' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  CLEAR: PV_ERROR, GT_AREA.
  " mts 의 경우 (정조장이면 BOM의 드럼코드의 드럼기호 제원)
  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  "    3) ATINN "PD_CA_PACKMARK_STATUS"의 ATWRT "CM"인
  " ATINN "SAP_MILLCA_PACKAGING"의 ATWRT를 구한다.(최종 포장재 코드)
  CLEAR: GT_ET_CHAR, GV_ATWRT.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_PACKMARK_STATUS' CHANGING PV_ERROR GV_ATWRT.

  "    2) ATINN "PD_CA_PACKMARK_STATUS"의 ATWRT 값이 없거나
  "CM"이 아닌 경우는 특성값에서 조장(SAP_LENGTH_VKRME)의
  " ATWRT를 구한다.

** 정조장인 경우
  IF  GV_ATWRT <> 'CM'OR GV_ATWRT IS INITIAL.

    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR GV_ATWRT.

    IF NOT  GV_ATWRT IS INITIAL.

      PERFORM CHECK_CS_BOM_VKRME  USING  PV_VBELN
                                         PV_POSNR
                                         PV_SPART
                                         PV_VGBEL
                                         PV_VGPOS
                                         PV_MATNR
                                         PS_LIPS
                       CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                   '41-H' TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

    ENDIF.

  ENDIF.

  " 정조장이 아니면 포장재 시뮬레이션
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_SPART_23
    USING GT_LIPS-VBELN GT_LIPS-POSNR PV_SPART GT_LIPS-VGBEL
          GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS
          CHANGING GV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
          PV_POSNR TO GT_AREA-POSNR,
         '41-I' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_SPART_41
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_43
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_43  USING  PV_VBELN
                          PV_POSNR
                          PV_SPART
                          PV_VGBEL
                          PV_VGPOS
                          PV_MATNR
                          PS_LIPS LIKE GT_LIPS
                          PV_KDKG4
        CHANGING PV_ERROR.

  DATA: LV_PD_LN_CABLE_TYPE     TYPE ATWRT,
        LV_PD_CA_CORE_NO_1ST    TYPE ATWRT,
        LV_PD_LN_CATEGORY       TYPE ATWRT,
        LV_PD_LN_ENHANCED       TYPE ATWRT,
        LV_PD_LN_SHE_ADD_INFORM TYPE ATWRT,
        LV_PD_CA_SHE_NUM        TYPE ATWRT,
        LV_SAP_LENGTH_VKRME     TYPE ATWRT.

  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_LN_CABLE_TYPE' CHANGING PV_ERROR LV_PD_LN_CABLE_TYPE.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_CA_CORE_NO_1ST' CHANGING PV_ERROR LV_PD_CA_CORE_NO_1ST.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_LN_CATEGORY' CHANGING PV_ERROR LV_PD_LN_CATEGORY.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_LN_ENHANCED' CHANGING PV_ERROR LV_PD_LN_ENHANCED.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_LN_SHE_ADD_INFORM'
    CHANGING PV_ERROR LV_PD_LN_SHE_ADD_INFORM.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'PD_CA_SHE_NUM'
    CHANGING PV_ERROR LV_PD_CA_SHE_NUM.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
    USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_SAP_LENGTH_VKRME.

  PERFORM READ_0510_43
    USING PV_SPART LV_PD_LN_CABLE_TYPE LV_PD_CA_CORE_NO_1ST
          LV_PD_LN_CATEGORY  LV_PD_LN_ENHANCED LV_PD_LN_SHE_ADD_INFORM
          LV_PD_CA_SHE_NUM LV_SAP_LENGTH_VKRME PV_KDKG4
          CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.

    MOVE PV_VBELN TO GT_AREA-VBELN.
    MOVE PV_POSNR TO GT_AREA-POSNR.
    MOVE '43-E' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.

  ENDIF.

ENDFORM.                    " GET_SPART_43
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_44  USING  PV_VBELN
                          PV_POSNR
                          PV_SPART
                          PV_VGBEL
                          PV_VGPOS
                          PV_MATNR
                          PS_LIPS LIKE GT_LIPS
                CHANGING PV_ERROR.

  DATA: LS_EKKN                  TYPE EKKN,
        LS_VBFA                  TYPE VBFA,
        LV_DRUM_NUMBER           TYPE ZMMT0217-DRUM_NUMBER,
        LV_SAP_LENGTH_VKRME      TYPE ATWRT,
        LV_SAP_MILLCA_FACTOR     TYPE ATWRT,
        LV_PD_CA_PACKMARK_STATUS TYPE ATWRT,
        LV_ZROLEN                TYPE ZMMT0217-ZROLEN,
        LV_ZROLCN                TYPE ZMMT0217-ZROLCN,
        LV_PD_CX_CABLE_TYPE      TYPE ATWRT,
        LV_PD_CA_INS_DIA         TYPE ATWRT,
        LT_STPOL                 LIKE STPOL OCCURS 0 WITH HEADER LINE,
        LV_MATNR                 TYPE MATNR,
        LT_0217                  LIKE ZMMT0217 OCCURS 0 WITH HEADER LINE,
        LV_KDKG4                 TYPE VBKD-KDKG4.

  " 23, 24, 41, 43, 44 제품군에 대해서 납품절단,
  " 재고 절단 로직 추가
  CASE PV_SPART.
    WHEN '23' OR '24' OR '41' OR '43' OR '44'.

      " 2. 납품절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_SPLIT USING  PV_VBELN
                                                            PV_POSNR
                                                           PV_VGBEL
                                                           PV_VGPOS
                                                            PV_SPART
                                                            PV_MATNR
                                           CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '44-A'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

      " 3. 재고 절단
      CLEAR: PV_ERROR, GT_AREA.
      PERFORM GET_SPART_20_STOCK_SPLIT USING  PV_VBELN
                                                            PV_POSNR
                                                            PV_VGBEL
                                                            PV_VGPOS
                                                            PV_SPART
                                                            PV_MATNR
                                                            PS_LIPS-CHARG
                                                            PS_LIPS-WERKS
                                           CHANGING PV_ERROR.

      IF  PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                     '44-B'   TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

  ENDCASE.

  CLEAR: PV_ERROR, GT_AREA.


  " 제품군 44(다발, 합판보빈 팔레트 적재)
  SELECT SINGLE KDKG4
       INTO LV_KDKG4
     FROM VBKD
   WHERE VBELN  EQ PV_VGBEL.
*        AND posnr EQ pv_vgpos.

  CLEAR GV_ERROR.
  PERFORM GET_SPART_44_2
    USING GT_LIPS-VBELN GT_LIPS-POSNR GT_LIPS-SPART GT_LIPS-VGBEL
          GT_LIPS-VGPOS GT_LIPS-MATNR GT_LIPS LV_KDKG4
          CHANGING GV_ERROR.

  IF GV_ERROR IS INITIAL.
    RETURN.
  ENDIF.
*
  "  판매오더와 품목을 EKKN-VBELN, VBELP에 넣어
  " 구매오더(EBELN)와 품목(EBELP)을 구한다.
  PERFORM CHECK_EKKN USING PV_VBELN PV_POSNR CHANGING PV_ERROR LS_EKKN.

  CLEAR: PV_ERROR, GT_AREA.
  PERFORM CHECK_ZMMT0217
    USING LS_EKKN-EBELN LS_EKKN-EBELP CHANGING PV_ERROR LV_DRUM_NUMBER.

  " 위에서 드럼기호를 구하지 못한다면 펑션
  " Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에 판매오더와
  " 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.
*  IF lv_drum_number IS INITIAL.     "기능개선 160066 - 삭제
  CLEAR: PV_ERROR.
  PERFORM GET_ZMMT0217_DRUM_NUMBER
    USING PV_VGBEL PV_VGPOS PV_MATNR
    CHANGING PV_ERROR LV_DRUM_NUMBER GT_AREA.

*  ENDIF.

  PERFORM GET_CREATE_AREA_44 CHANGING LV_DRUM_NUMBER PV_ERROR.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
               '44-C' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  " MTO  경우
  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_CHARACTERISTIC_20
    USING PV_SPART PV_VGBEL PV_VGPOS GC_X CHANGING PV_ERROR GT_AREA.

  IF PV_ERROR IS INITIAL.
    MOVE: PV_VBELN  TO GT_AREA-VBELN,
               PV_POSNR TO GT_AREA-POSNR,
               '44-D' TO GT_AREA-CODE_POINT.
    APPEND GT_AREA. CLEAR GT_AREA.
    RETURN.
  ENDIF.

  CLEAR GT_VBAK.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  IF  GT_VBAK-AUART EQ 'ZCS'.

    SELECT SINGLE VBELV POSNV
        INTO (LS_VBFA-VBELV, LS_VBFA-POSNV)
        FROM VBFA
     WHERE VBELN   EQ PV_VGBEL
          AND POSNN EQ PV_VGPOS.

    "  해당하는 값이 없고 LIPS-VGBEL의 VBAK-AUART="ZCS"이면
    " 아래 순서로 처리한다.
    PERFORM GET_CHARACTERISTIC_20
      USING PV_SPART LS_VBFA-VBELV LS_VBFA-POSNV ' '
      CHANGING PV_ERROR GT_AREA.

    IF PV_ERROR IS INITIAL.
      MOVE: PV_VBELN  TO GT_AREA-VBELN,
                 PV_POSNR TO GT_AREA-POSNR,
               '44-E' TO GT_AREA-CODE_POINT.
      APPEND GT_AREA. CLEAR GT_AREA.
      RETURN.
    ENDIF.

  ENDIF.

  " MTS 경우
  REFRESH GT_ET_CHAR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  PERFORM READ_ET_CHAR
    USING 'PD_CA_PACKMARK_STATUS'
    CHANGING PV_ERROR LV_PD_CA_PACKMARK_STATUS.

  IF SY-SUBRC <> 0 OR LV_PD_CA_PACKMARK_STATUS <> 'CM' OR
     LV_PD_CA_PACKMARK_STATUS IS INITIAL.

    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_SAP_LENGTH_VKRME.

    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'PD_CX_CABLE_TYPE' CHANGING PV_ERROR LV_PD_CX_CABLE_TYPE.

    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'PD_CA_INS_DIA' CHANGING PV_ERROR LV_PD_CA_INS_DIA.

  ENDIF.

* RFCL류가 아니고 정조장이거나 작으면 BOM의 드럼코드의 드럼기호 제원
  IF LV_PD_CX_CABLE_TYPE <> 'RFCL'.

    REFRESH LT_STPOL.
    " BOM 전개
    PERFORM CS_BOM_EXPLOSION_MAT TABLES LT_STPOL
      USING PV_MATNR PS_LIPS-WERKS CHANGING PV_ERROR.

    "  MARA-MTART="ROH1", "ROH2"인 자재코드(목박스)를 구한다.
    LOOP AT LT_STPOL.
      SELECT SINGLE MATNR
          INTO LV_MATNR
        FROM MARA
       WHERE MATNR EQ LT_STPOL-IDNRK
           AND  MTART EQ GC_MRM1.
      IF SY-SUBRC <> 0.
        DELETE LT_STPOL.
      ENDIF.
    ENDLOOP.

*     7) 수량(STPO-KMLMG)으로 표준 조장을 구한다.
*      ① 0.333이면 3,000M가 표준 조장
*      ② 0.500이면 2,000M가 표준 조장
*      ③ 1.000이면 1,000M가 표준 조장
*      ④ 2.000이면 500M가 표준 조장

    CLEAR LT_STPOL.
    READ TABLE LT_STPOL INDEX 1.

    " 조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서
    " 구한 표준조장과 일치하면 정조장으로 인식
    CLEAR: PV_ERROR, GV_ATWRT.
    PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR GV_ATWRT.

    "  조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서
    " 구한 표준조장과 일치하면 정조장으로 인식
    PERFORM CHECK_STD_VKRME
      USING LT_STPOL-MENGE GV_ATWRT ' ' CHANGING PV_ERROR GV_SUBRC.

*    IF NOT pv_error IS INITIAL.
*      RETURN.
*    ENDIF.

    " 0은 정조장으로 인식 아래 로직을 건너 뛴다.
    IF GV_SUBRC EQ 0.

      "  ATWRT로 자재마스터의 특성에서 RL_CA_RAMP_OPTION(특수드럼표기),
      " RL_CA_NO(드럼기호), RL_CA_FG_DIA_CHG(플랜지경변경),
      " RL_CA_IN_WIDTH_CHG(내폭변경)을 구한다. -티코드 ZSD1R6020 참고
      PERFORM MATERIALCHARACTERISTIC_GET
        USING PV_SPART LT_STPOL-IDNRK CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                   '44-F' TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

    ELSE.

      " 정조장이 아니면 포장재 시뮬레이션
      PERFORM GET_SPART_23
        USING GT_LIPS-VBELN GT_LIPS-POSNR PV_SPART GT_LIPS-VGBEL
              GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS
              CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                   '44-G' TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

    ENDIF.

  ELSEIF LV_PD_CX_CABLE_TYPE EQ 'RFCL'.

    REFRESH LT_STPOL.
    " BOM 전개
    PERFORM CS_BOM_EXPLOSION_MAT TABLES LT_STPOL
      USING PV_MATNR PS_LIPS-WERKS CHANGING PV_ERROR.

    "  MARA-MTART="ROH1", "ROH2"인 자재코드(목박스)를 구한다.
    LOOP AT LT_STPOL.
      SELECT SINGLE MATNR
          INTO LV_MATNR
        FROM MARA
       WHERE MATNR EQ LT_STPOL-IDNRK
           AND  MTART EQ GC_MRM1.
      IF SY-SUBRC <> 0.
        DELETE LT_STPOL.
      ENDIF.
    ENDLOOP.

*     7) 수량(STPO-KMLMG)으로 표준 조장을 구한다.
*      ① 0.333이면 3,000M가 표준 조장
*      ② 0.500이면 2,000M가 표준 조장
*      ③ 1.000이면 1,000M가 표준 조장
*      ④ 2.000이면 500M가 표준 조장

    CLEAR LT_STPOL.
    READ TABLE LT_STPOL INDEX 1.

    " 조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서 구한
    " 표준조장과 일치하면 정조장으로 인식
    CLEAR PV_ERROR.
    PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR GV_ATWRT.

    "  조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서 구한
    " 표준조장과 일치하면 정조장으로 인식
    PERFORM CHECK_STD_VKRME
      USING LT_STPOL-MENGE GV_ATWRT 'RFCL' CHANGING PV_ERROR GV_SUBRC.

    IF NOT PV_ERROR IS INITIAL.
      RETURN.
    ENDIF.

    " 0은 정조장으로 인식 아래 로직을 건너 뛴다.
    IF GV_SUBRC EQ 0.

      "  ATWRT로 자재마스터의 특성에서 RL_CA_RAMP_OPTION(특수드럼표기),
      " RL_CA_NO(드럼기호), RL_CA_FG_DIA_CHG(플랜지경변경),
      " RL_CA_IN_WIDTH_CHG(내폭변경)을 구한다. -티코드 ZSD1R6020 참고
      PERFORM MATERIALCHARACTERISTIC_GET
        USING PV_SPART LT_STPOL-IDNRK CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                   '44-H' TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

    ELSE.

      " 정조장이 아니면 포장재 시뮬레이션
      PERFORM GET_SPART_23
        USING GT_LIPS-VBELN GT_LIPS-POSNR PV_SPART GT_LIPS-VGBEL
              GT_LIPS-VGPOS GT_LIPS-MATNR VBAK-KUNNR GT_LIPS
              CHANGING PV_ERROR.

      IF PV_ERROR IS INITIAL.
        MOVE: PV_VBELN  TO GT_AREA-VBELN,
                   PV_POSNR TO GT_AREA-POSNR,
                   '44-I' TO GT_AREA-CODE_POINT.
        APPEND GT_AREA. CLEAR GT_AREA.
        RETURN.
      ENDIF.

    ENDIF.

  ENDIF.


ENDFORM.                    " GET_SPART_44
*&---------------------------------------------------------------------*
*&      Form  READ_0510_43
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_PD_LN_CABLE_TYPE  text
*      -->P_LV_PD_CA_CORE_NO_1ST  text
*      -->P_LV_PD_LN_CATEGORY  text
*      -->P_LV_PD_LN_ENHANCED  text
*      -->P_LV_PD_LN_SHE_ADD_INFORM  text
*      -->P_LV_PD_CA_SHE_NUM  text
*      -->P_LV_SAP_LENGTH_VKRME  text
*----------------------------------------------------------------------*
FORM READ_0510_43  USING PV_SPART
                          PV_PD_LN_CABLE_TYPE
                          PV_PD_CA_CORE_NO_1ST
                          PV_PD_LN_CATEGORY
                          PV_PD_LN_ENHANCED
                          PV_PD_LN_SHE_ADD_INFORM
                          PV_PD_CA_SHE_NUM
                          PV_SAP_LENGTH_VKRME
                          PV_KDKG4
                CHANGING PV_ERROR.

  DATA: LV_CABLE_NAME TYPE ZLET0510-CABLE_NAME,
        LV_CORE_NO    TYPE ZLET0510-CORE_NO,
        LV_CATGR      TYPE ZLET0510-CATGR,
        LV_ENHCD      TYPE ZLET0510-ENHCD,
        LV_ADDINFO    TYPE ZLET0510-ADDINFO,
        LV_SHENUM     TYPE ZLET0510-SHENUM,
        LV_LENGTH     TYPE ZLET0510-LENGTH,
        LV_SALES_FLAG TYPE ZLET0510-SALES_FLAG,
        LS_0510       LIKE ZLET0510,
        LV_INT        TYPE P DECIMALS 4,
        LV_MENGE      TYPE P DECIMALS 3.

  MOVE: PV_PD_LN_CABLE_TYPE TO LV_CABLE_NAME,
            PV_PD_CA_CORE_NO_1ST TO LV_CORE_NO,
            PV_PD_LN_CATEGORY TO LV_CATGR,
            PV_PD_LN_ENHANCED TO LV_ENHCD,
            PV_PD_LN_SHE_ADD_INFORM TO LV_ADDINFO,
            PV_PD_CA_SHE_NUM TO LV_SHENUM,
            PV_SAP_LENGTH_VKRME TO LV_LENGTH.

  DATA: LV_MATNR TYPE MATNR.

  CASE PV_KDKG4.
    WHEN '4D'.
      LV_SALES_FLAG = 1.
    WHEN '4L' OR '4S' OR '4E'.
      LV_SALES_FLAG = 2.
  ENDCASE.

  SELECT SINGLE *
     INTO LS_0510
    FROM ZLET0510
 WHERE SPART EQ PV_SPART
    AND CABLE_NAME EQ LV_CABLE_NAME
    AND CORE_NO      EQ LV_CORE_NO
    AND CATGR           EQ LV_CATGR
    AND ENHCD         EQ LV_ENHCD
    AND ADDINFO        EQ LV_ADDINFO
    AND SHENUM      EQ LV_SHENUM
    AND LENGTH         EQ LV_LENGTH
    AND SALES_FLAG  EQ LV_SALES_FLAG.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
    CHANGING PV_ERROR GV_ATWRT.

  MOVE GV_ATWRT TO LV_MENGE.
  IF NOT GV_ATWRT IS INITIAL AND
     NOT LS_0510-TOT_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_MENGE '/' LS_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

*  IF NOT ls_0510-coil_height IS INITIAL AND
*NOT ls_0510-load_qty IS INITIAL.
*    PERFORM calculation_exception_handing USING
*ls_0510-coil_height '*' ls_0510-load_qty CHANGING gt_area-height.
*  ENDIF.

  MOVE: LS_0510-PKMATNR2 TO GT_AREA-PKMATNR,
             LS_0510-PKKTX       TO GT_AREA-PKTYP,
*            ls_0510-coil_height TO gt_area-height.
             LS_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             LS_0510-PKLENGTH2 TO GT_AREA-ZLENGTH, "   세로
             LS_0510-PKWEIGHT2 TO GT_AREA-PKWEI, "   세로
              LS_0510-PKMEINS2  TO GT_AREA-PMEINS.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT LS_0510-PKWEIGHT1 IS INITIAL AND NOT LS_0510-TOT_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LS_0510-PKWEIGHT1 '*' LS_0510-TOT_QTY
            CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD LS_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT LS_0510-COIL_HEIGHT IS INITIAL AND
         LS_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LS_0510-COIL_HEIGHT '*' LS_0510-LOAD_QTY
      CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD LS_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

  CONCATENATE LS_0510-SPART LS_0510-PKKTX LS_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

ENDFORM.                    " READ_0510_43
*&---------------------------------------------------------------------*
*&      Form  READ_0510_44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_PD_LN_CABLE_TYPE  text
*      -->P_LV_PD_CA_CORE_NO_1ST  text
*      -->P_LV_PD_LN_CATEGORY  text
*      -->P_LV_PD_LN_ENHANCED  text
*      -->P_LV_PD_LN_SHE_ADD_INFORM  text
*      -->P_LV_PD_CA_SHE_NUM  text
*      -->P_LV_SAP_LENGTH_VKRME  text
*----------------------------------------------------------------------*
FORM READ_0510_44  USING PV_SPART
                          PV_SAP_LENGTH_VKRME
                          PV_PD_CX_CABLE_TYPE
                          PV_PD_CA_INS_DIA
                          PV_PD_CA_SHE_MAT_NAME
                          PV_KDKG4
                CHANGING PV_ERROR.


  DATA: LV_CXTYP      TYPE ZLET0510-CXTYP,
        LV_INS_DIA    TYPE ZLET0510-INS_DIA,
        LV_SHEMAT     TYPE ZLET0510-SHEMAT,
        LV_SALES_FLAG TYPE ZLET0510-SALES_FLAG,
        LS_0510       LIKE ZLET0510,
        LV_INT        TYPE P DECIMALS 4,
        LV_MENGE      TYPE P DECIMALS 3.

  MOVE: PV_PD_CX_CABLE_TYPE TO LV_CXTYP ,
             PV_PD_CA_INS_DIA TO LV_INS_DIA,
             PV_PD_CA_SHE_MAT_NAME TO LV_SHEMAT.

  DATA: LV_MATNR TYPE MATNR.

  CASE PV_KDKG4.
    WHEN '4D'.
      LV_SALES_FLAG = 1.
    WHEN '4L' OR '4S' OR '4E'.
      LV_SALES_FLAG = 2.
  ENDCASE.

  SELECT SINGLE *
     INTO LS_0510
    FROM ZLET0510
 WHERE SPART EQ PV_SPART
      AND CXTYP EQ LV_CXTYP
      AND INS_DIA EQ LV_INS_DIA
      AND SHEMAT EQ  LV_SHEMAT
      AND SALES_FLAG EQ PV_KDKG4.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CLEAR PV_ERROR.

  PERFORM READ_ET_CHAR
    USING 'SAP_MILLCA_FACTOR' CHANGING PV_ERROR GV_ATWRT.

  MOVE GV_ATWRT TO LV_MENGE.
  IF NOT LV_MENGE IS INITIAL AND
     NOT LS_0510-TOT_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LV_MENGE '/' LS_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  IF NOT LS_0510-COIL_HEIGHT IS INITIAL AND
     NOT LS_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LS_0510-COIL_HEIGHT '*' LS_0510-LOAD_QTY
      CHANGING GT_AREA-HEIGHT .
  ENDIF.

  MOVE: LS_0510-PKMATNR2 TO GT_AREA-PKMATNR,
             LS_0510-PKKTX       TO GT_AREA-PKTYP,
*             ls_0510-coil_height TO gt_area-height.
             LS_0510-PKWIDTH2  TO GT_AREA-WIDTH,  "   가로
             LS_0510-PKLENGTH2 TO GT_AREA-ZLENGTH. "   세로

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT LS_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LS_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD LS_0510-PKWEIGHT2 TO GT_AREA-PKWEI.
  MOVE  LS_0510-PKMEINS2  TO GT_AREA-PMEINS.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT LS_0510-COIL_HEIGHT IS INITIAL AND
         LS_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING LS_0510-COIL_HEIGHT '*' LS_0510-LOAD_QTY
      CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD LS_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

*  ADD: ls_0510-pkheight2 TO gt_area-height. "  높이`

  CONCATENATE LS_0510-SPART LS_0510-PKKTX LS_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

ENDFORM.                    " READ_0510_44
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_44_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_44_2  USING  PV_VBELN
                           PV_POSNR
                           PV_SPART
                           PV_VGBEL
                           PV_VGPOS
                           PV_MATNR
                           PS_LIPS LIKE GT_LIPS
                           PV_KDKG4
         CHANGING PV_ERROR.

  DATA: LV_SAP_LENGTH_VKRME   TYPE ATWRT,
        LV_PD_CX_CABLE_TYPE   TYPE ATWRT,
        LV_PD_CA_INS_DIA      TYPE ATWRT,
        LV_PD_CA_SHE_MAT_NAME TYPE ATWRT.

  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_SAP_LENGTH_VKRME.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'PD_CX_CABLE_TYPE' CHANGING PV_ERROR LV_PD_CX_CABLE_TYPE.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'PD_CA_INS_DIA' CHANGING PV_ERROR LV_PD_CA_INS_DIA.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'PD_CA_SHE_MAT_NAME' CHANGING PV_ERROR LV_PD_CA_SHE_MAT_NAME.

  PERFORM READ_0510_44
  USING PV_SPART  LV_SAP_LENGTH_VKRME LV_PD_CX_CABLE_TYPE
        LV_PD_CA_INS_DIA  LV_PD_CA_SHE_MAT_NAME PV_KDKG4
        CHANGING PV_ERROR.

  IF PV_ERROR IS INITIAL.

    MOVE PV_VBELN TO GT_AREA-VBELN.
    MOVE PV_POSNR TO GT_AREA-POSNR.

    APPEND GT_AREA.

  ENDIF.

ENDFORM.                    " GET_SPART_44_2
*&---------------------------------------------------------------------*
*&      Form  CHECK_EKKN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_EKKN  USING  PV_VBELN
                       PV_POSNR
                 CHANGING PV_ERROR
                         PS_EKKN TYPE EKKN.

  SELECT SINGLE *
      INTO PS_EKKN
    FROM EKKN
   WHERE VBELN EQ PV_VBELN
        AND VBELP EQ PV_POSNR.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " CHECK_EKKN
*&---------------------------------------------------------------------*
*&      Form  CHECK_ZMMT0217
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_EKKN_EBELN  text
*      -->P_LS_EKKN_EBELP  text
*      <--P_PV_ERROR  text
*      <--P_LV_DRUM_NUMBER  text
*----------------------------------------------------------------------*
FORM CHECK_ZMMT0217  USING  PV_EBELN
                            PV_EBELP
                   CHANGING PV_ERROR
                            PV_DRUM_NUMBER.

*{ 기능개선 159419 - 변경
  SELECT SINGLE DRUM_NUMBER
    INTO PV_DRUM_NUMBER
    FROM ZMMT0217
   WHERE VGBEL = PV_EBELN
     AND VGPOS = PV_EBELP
     AND LOEVM = 'C'.

*  SELECT SINGLE drum_number
*    INTO pv_drum_number
*    FROM zmmt0217
*   WHERE vbeln EQ pv_ebeln
*     AND posnr EQ pv_ebelp
*     AND loevm EQ 'C'.
*} 기능개선 159419 - 변경

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " CHECK_ZMMT0217
*&---------------------------------------------------------------------*
*&      Form  GET_ZMMT0217_DRUM_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*      <--P_PV_ERROR  text
*      <--P_LV_DRUM_NUMBER  text
*----------------------------------------------------------------------*
FORM GET_ZMMT0217_DRUM_NUMBER  USING PV_VGBEL
                                    PV_VGPOS
                                    PV_MATNR
                           CHANGING PV_ERROR
                                    PV_DRUM_NUMBER
                                    PS_AREA LIKE GT_AREA.


  RANGES: LR_LFDAT FOR SY-DATUM.

  DATA: LV_SAP_LENGTH_VKRME  TYPE ATWRT,
        LV_SAP_MILLCA_FACTOR TYPE ATWRT,
        LV_ZROLEN            TYPE ZMMT0217-ZROLEN,
        LV_ZROLCN            TYPE ZMMT0217-ZROLCN,
        LV_INT               TYPE I,
        LT_0217              LIKE ZMMT0217 OCCURS 0 WITH HEADER LINE.

  DATA: LV_SAP_MILLCA_LENGTH TYPE ATWRT,
        LV_MENGE             TYPE MENGE_D.

  " 펑션 Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에
  " 판매오더와 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.
  REFRESH GT_ET_CHAR.

  " Z_LE_GET_CHARACTERISTIC_TABLE2
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR LV_SAP_LENGTH_VKRME.

  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'SAP_MILLCA_FACTOR' CHANGING PV_ERROR LV_SAP_MILLCA_FACTOR.

  MOVE: LV_SAP_LENGTH_VKRME TO LV_INT,
             LV_INT TO LV_ZROLEN,
             LV_SAP_MILLCA_FACTOR TO LV_ZROLCN.

  PERFORM CHANGE_STRING_NOGAP CHANGING LV_ZROLEN.

*{ 기능개선 160066 - 추가
  IF PV_DRUM_NUMBER IS INITIAL.
*} 기능개선 160066 - 추가
    REFRESH LT_0217.

    LR_LFDAT-LOW =  LR_LFDAT-HIGH = SY-DATUM.
    SUBTRACT 180 FROM LR_LFDAT-LOW.
    CONCATENATE 'IBT' LR_LFDAT-LOW LR_LFDAT-HIGH INTO LR_LFDAT.
    APPEND LR_LFDAT.

    SELECT MATNR DRUM_NUMBER ERDAT
        INTO CORRESPONDING FIELDS OF TABLE LT_0217
       FROM ZMMT0217
     WHERE MATNR EQ PV_MATNR
         AND ZROLEN EQ LV_ZROLEN
         AND LFDAT  IN LR_LFDAT
         AND LOEVM EQ 'C'.
*         AND zrolcn EQ lv_zrolcn.

    "  테이블 ZMMT0217에서 자재코드(MATNR), 조장(ZROLEN),
    " 조장수(ZROLCN)로 드럼기호(DRUM_NUMBER)를 구한다.(최근 데이터)
    SORT LT_0217 BY MATNR ERDAT DESCENDING.
    DELETE ADJACENT DUPLICATES FROM LT_0217 COMPARING MATNR ERDAT.

    CLEAR LT_0217.
    READ TABLE LT_0217 INDEX 1.

    IF SY-SUBRC <> 0.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    MOVE LT_0217-DRUM_NUMBER TO PV_DRUM_NUMBER.
  ENDIF.

  MOVE 'DM' TO PS_AREA-PKTYP.
  MOVE PV_DRUM_NUMBER TO PS_AREA-DMMATNR.

*-긴급_문이언_S
  CONDENSE : PS_AREA-DMMATNR,
             PV_DRUM_NUMBER,
             LT_0217-DRUM_NUMBER.
*-긴급_문이언_E

*  CLEAR pv_error.          "   lv_sap_millca_factor TYPE atwrt.
*  PERFORM read_et_char USING 'SAP_MILLCA_LENGTH'
*  CHANGING pv_error lv_sap_millca_length.
*
*  " 포장재 수량
*  IF NOT lv_sap_millca_length IS INITIAL.
*    PERFORM change_string_replace
*    USING ',' CHANGING lv_sap_millca_length.
*    CONDENSE lv_sap_millca_length NO-GAPS.
*    MOVE lv_sap_millca_length TO lv_menge.
*  ENDIF.

  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

  " 납품수량 / 조장
  IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE CHANGING PS_AREA-MENGE.
  ENDIF.
*  MOVE lv_sap_millca_factor TO ps_area-menge.

ENDFORM.                    " GET_ZMMT0217_DRUM_NUMBER
*&---------------------------------------------------------------------*
*&      Form  GET_CREATE_AREA_44
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_DRUM_NUMBER  text
*----------------------------------------------------------------------*
FORM GET_CREATE_AREA_44  CHANGING PV_DRUM_NUMBER PV_ERROR.

  DATA: LV_PK_WD_THK TYPE ZEDT0210-PLAN_DIA,
        LV_SUBRC     LIKE SY-SUBRC.

  CLEAR : PV_ERROR.

*  CLEAR gt_0210.
*  READ TABLE gt_0210 WITH KEY "dr_gbn = 'G'
*                              "sg_gbn = 'D'
*                              "drum_det = 'S'
*                               drum_no = pv_drum_number.
**                BINARY SEARCH.

  PERFORM GET_ZEDT0210 USING ' '
                             PV_DRUM_NUMBER
                    CHANGING LV_SUBRC.

  IF LV_SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  "    5) RL_CA_FG_DIA_CHG(플랜지경변경),
  " RL_CA_IN_WIDTH_CHG(내폭변경)의 값이 모두 없는 경우
  IF NOT GT_0210-PK_WD_THK IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0210-PK_WD_THK '*' 2 CHANGING LV_PK_WD_THK.
  ENDIF.

  GT_AREA-WIDTH    = GT_0210-OUT_WID.   "  폭  - 가로
  GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_PK_WD_THK. " 길이 - 세로
  GT_AREA-HEIGHT   = GT_0210-PLAN_DIA + LV_PK_WD_THK. " 높이
  GT_AREA-DMMATNR = PV_DRUM_NUMBER.
  GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.
  GT_AREA-PMEINS = 'KG'.

  "  mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
  ENDIF.

ENDFORM.                    " GET_CREATE_AREA_44
*&---------------------------------------------------------------------*
*&      Form  GET_0510_64
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_SPART  text
*      -->P_PV_MATNR  text
*      -->P_GT_VBAK_KUNNR  text
*      <--P_PV_ERROR  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_0510_64  USING  PV_SPART
                        PV_KDKG4
                        PV_RL_CA_RAMP_OPTION
                        PV_RL_CA_NO
                        PV_RL_CA_FG_DIA_CHG
                        PV_RL_CA_IN_WIDTH_CHG
                        PV_PD_AL_STD_PRODUCT_NAME
                        PV_PD_AL_PRODUCT_HEIGHT
                        PV_PD_AL_PRODUCT_WIDTH
                        PV_PD_AL_PRODUCT_LENGTH
                        PS_LIPS LIKE GT_LIPS
                 CHANGING PV_ERROR
                                   PS_AREA LIKE GT_AREA.

  REFRESH GT_0510.

  DATA: LV_INT        TYPE P DECIMALS 2,
        LV_MENGE      TYPE P DECIMALS 3,
        LV_SALES_FLAG LIKE ZLET0510-SALES_FLAG,
        LV_ALNAME     LIKE ZLET0510-ALNAME,
        LV_ALHEIGHT   LIKE ZLET0510-ALHEIGHT,
        LV_ALWIDTH    LIKE ZLET0510-ALWIDTH,
        LV_ALLENGTH   LIKE ZLET0510-ALLENGTH.

  MOVE:  PV_KDKG4 TO LV_SALES_FLAG,
             PV_PD_AL_STD_PRODUCT_NAME TO LV_ALNAME,
             PV_PD_AL_PRODUCT_HEIGHT TO LV_ALHEIGHT,
             PV_PD_AL_PRODUCT_WIDTH TO LV_ALWIDTH,
             PV_PD_AL_PRODUCT_LENGTH TO LV_ALLENGTH.

  CASE PV_KDKG4.
    WHEN '4D'.
      LV_SALES_FLAG = 1.
    WHEN '4L' OR '4S' OR '4E'.
      LV_SALES_FLAG = 2.
  ENDCASE.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_0510
    FROM ZLET0510
  WHERE SPART EQ PV_SPART
        AND SALES_FLAG EQ LV_SALES_FLAG
        AND ALNAME EQ  LV_ALNAME
        AND ALHEIGHT EQ LV_ALHEIGHT
        AND ALWIDTH  EQ LV_ALWIDTH
        AND ALLENGTH EQ LV_ALLENGTH.
*        AND allength < 60. " 60미만 여부로 판단한다.

  IF GT_0510[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  LOOP AT GT_0510.

    PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING GT_0510-ALLENGTH.
    PERFORM CHANGE_STRING_NOGAP CHANGING GT_0510-ALLENGTH.

    MOVE GT_0510-ALLENGTH TO LV_INT.
    MODIFY GT_0510.
    " 제품길이(ALLENGTH)는 60미만 여부로 판단한다.
*    IF lv_int >= 60.
*      DELETE gt_0510.
*    ENDIF.

  ENDLOOP.

  READ TABLE GT_0510 INDEX 1.

  " 포장재 수량
  IF NOT PS_LIPS-LFIMG IS INITIAL AND NOT GT_0510-ALMENG IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING PS_LIPS-LFIMG '/' GT_0510-ALMENG CHANGING GT_AREA-MENGE.
  ENDIF.

  IF NOT GT_AREA-MENGE IS INITIAL AND NOT GT_0510-TOT_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-MENGE '/' GT_0510-TOT_QTY CHANGING GT_AREA-MENGE.
  ENDIF.

  MOVE: PS_LIPS-VBELN           TO GT_AREA-VBELN,
             PS_LIPS-POSNR          TO GT_AREA-POSNR,
             GT_0510-PKKTX           TO GT_AREA-PKTYP,
             GT_0510-PKMATNR2    TO GT_AREA-PKMATNR,
             GT_0510-PKWIDTH2     TO GT_AREA-WIDTH,  "   가로
             GT_0510-PKLENGTH2    TO GT_AREA-ZLENGTH, "   세로
*             gt_0510-pkheight2 TO gt_area-height,
             GT_0510-PKWEIGHT2   TO GT_AREA-PKWEI, "   무게
             GT_0510-PKMEINS2   TO GT_AREA-PMEINS. "   세로

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-PKWEIGHT1 '*' LV_MENGE CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
         GT_0510-LOAD_QTY IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_0510-COIL_HEIGHT '*' GT_0510-LOAD_QTY
    CHANGING GT_AREA-HEIGHT.
  ENDIF.

  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`
  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
  INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

  "  mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
  ENDIF.
*  REFRESH gt_object.

ENDFORM.                    " GET_0510_64
*&---------------------------------------------------------------------*
*&      Form  GET_MARA_BRGEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AREA_PKMATNR2  text
*      <--P_GT_AREA  text
*----------------------------------------------------------------------*
FORM GET_MARA_BRGEW  USING PV_MATNR
                     CHANGING PS_AREA LIKE GT_AREA.

  DATA: LS_MARA  LIKE MARA,
        LV_MATNR TYPE MATNR.

  CHECK NOT PV_MATNR IS INITIAL.

  PERFORM CONVERSION_ATNAM USING PV_MATNR CHANGING LV_MATNR.

  SELECT SINGLE *
      INTO LS_MARA
    FROM MARA
   WHERE MATNR EQ LV_MATNR.

  MOVE: LS_MARA-NTGEW TO PS_AREA-PKWEI,
             LS_MARA-GEWEI   TO PS_AREA-PMEINS.

*  IF ps_area-pkwei <> 0 AND gt_lips-lfimg <> 0.
*    ps_area-pkwei = ps_area-pkwei * gt_lips-lfimg.
*  ENDIF.

ENDFORM.                    " GET_MARA_BRGEW
*&---------------------------------------------------------------------*
*&      Form  CHECK_STD_VKRME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_STPOL_MENGE  text
*      -->P_GV_ATWRT  text
*      <--P_PV_ERROR  text
*      <--P_GV_SUBRC  text
*----------------------------------------------------------------------*
FORM CHECK_STD_VKRME  USING PV_MENGE
                            PV_ATWRT
                            PV_RFCL_FLAG
                    CHANGING PV_ERROR
                            PV_SUBRC.

  DATA: LV_DEC   TYPE P DECIMALS 2,
        LV_ATWRT TYPE ATWRT.

  IF PV_ATWRT IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  MOVE PV_ATWRT TO LV_ATWRT.

  PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING LV_ATWRT.
  PERFORM CHANGE_STRING_REPLACE USING 'mm' CHANGING LV_ATWRT.
  PERFORM CHANGE_STRING_NOGAP CHANGING LV_ATWRT.

  CASE PV_MENGE.
    WHEN '0.333'.
      MOVE 3000 TO LV_DEC.
    WHEN '0.500'.
      MOVE 2000 TO LV_DEC.
    WHEN '1.000'.
      MOVE 1000 TO LV_DEC.
    WHEN '2.000'.
      MOVE 500 TO LV_DEC.
  ENDCASE.

  CASE PV_RFCL_FLAG.
    WHEN 'RFCL'.
      IF LV_ATWRT = LV_DEC.
        MOVE 0 TO PV_SUBRC.
      ELSE.
        MOVE 8 TO PV_SUBRC.
      ENDIF.
    WHEN OTHERS.
      IF LV_ATWRT <= LV_DEC.
        MOVE 0 TO PV_SUBRC.
      ELSE.
        MOVE 8 TO PV_SUBRC.
      ENDIF.
  ENDCASE.

ENDFORM.                    " CHECK_STD_VKRME
*&---------------------------------------------------------------------*
*&      Form  SELECT_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_LIPS  text
*----------------------------------------------------------------------*
FORM SELECT_ROWS  TABLES   PT_LIPS STRUCTURE GT_LIPS
                                      USING PT_ROWS TYPE LVC_T_ROW.

  DATA: LS_ROWS TYPE LVC_S_ROW.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    MOVE GT_TOP_LEFT-VBELN TO PT_LIPS-VBELN.
    MOVE GT_TOP_LEFT-POSNR TO PT_LIPS-POSNR.

    APPEND PT_LIPS.

  ENDLOOP.

ENDFORM.                    " SELECT_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_SAVE_AND_TRANS_LET0917
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_LIPS  text
*----------------------------------------------------------------------*
FORM GET_SAVE_AND_TRANS_LET0917  TABLES   PT_LIPS STRUCTURE GT_LIPS
                                    USING PT_ROWS TYPE LVC_T_ROW
                                       CHANGING PV_ERROR.

  DATA: LS_ROWS TYPE LVC_S_ROW.
  DATA: LT_BOTTOM LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL.

  SORT PT_LIPS BY VBELN POSNR.

  IF NOT PT_LIPS[] IS INITIAL.

    REFRESH GT_0917.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.

        SELECT *
             INTO CORRESPONDING FIELDS OF TABLE GT_0917
          FROM ZLET0917
            FOR ALL ENTRIES IN PT_LIPS
        WHERE VBELN EQ PT_LIPS-VBELN
*             AND xloek  EQ ''
          "  납품분할 되지 않은 삭제는 보여준다.
             AND VBELN_VN EQ ' '.

      WHEN P_RAD3 OR P_RAD4.

        SELECT *
             INTO CORRESPONDING FIELDS OF TABLE GT_0917
          FROM ZLET0917
            FOR ALL ENTRIES IN PT_LIPS
        WHERE VBELN EQ PT_LIPS-VBELN
             AND POSNR EQ PT_LIPS-POSNR
*             AND xloek  EQ ''
          "  납품분할 되지 않은 삭제는 보여준다.
             AND VBELN_VN EQ ' '.

    ENDCASE.

    IF GT_0917[] IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

  ENDIF.

  REFRESH: GT_TOP_RIGHT, GT_BOTTOM_RIGHT, GT_BOTTOM_LEFT.
  CLEAR: GT_TOP_RIGHT, GT_BOTTOM_RIGHT, GT_BOTTOM_LEFT.

  SORT GT_0917 BY VBELN POSNR.
  SORT GT_0903 BY VBELN.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    " TOP RIGHT SCREEN.
    LOOP AT GT_0917 WHERE VBELN EQ GT_TOP_LEFT-VBELN.

      CASE GC_X.
        WHEN P_RAD1 OR P_RAD2.
        WHEN P_RAD3 OR P_RAD4.
          CHECK GT_0917-POSNR EQ GT_TOP_LEFT-POSNR.
      ENDCASE.

      MOVE-CORRESPONDING GT_0917 TO GT_BOTTOM_LEFT.
      MOVE GT_0917-MEINS TO GT_BOTTOM_LEFT-VRKME.
      MOVE-CORRESPONDING GT_0917 TO GT_BOTTOM_RIGHT.
      MOVE GT_BOTTOM_RIGHT-MENGE TO GT_BOTTOM_RIGHT-INMENGE.
      " 아이콘 결정
      CASE GC_X.
        WHEN P_RAD1 OR P_RAD2.
          PERFORM CREATE_ICON_0903
          USING GT_0917-VBELN ICON_GREEN_LIGHT
          CHANGING GT_BOTTOM_RIGHT-ICON.
        WHEN P_RAD3 OR P_RAD4.
          PERFORM CREATE_ICON_0903_TWO
          USING GT_0917-VBELN GT_0917-POSNR ICON_GREEN_LIGHT
          CHANGING GT_BOTTOM_RIGHT-ICON.
      ENDCASE.
      GT_BOTTOM_LEFT-ICON = GT_TOP_LEFT-ICON = GT_BOTTOM_RIGHT-ICON.

      READ TABLE GT_LIKP WITH KEY VBELN = GT_0917-VBELN.
      IF SY-SUBRC = 0.
        GT_BOTTOM_LEFT-KUNWE =  GT_LIKP-KUNNR. "납품처
      ENDIF.

*___판매처명
      PERFORM GET_CUSTOMER_NAME USING: GT_BOTTOM_LEFT-KUNNR
                                       GT_BOTTOM_LEFT-NAMAG.

*___납품처명
      PERFORM GET_KUNWE_NAME    USING: GT_BOTTOM_LEFT-VBELN
                                       GT_BOTTOM_LEFT-NAMWE.

      REFRESH LT_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.

      " 포장재 타입과 자재코드가 있으면 입력 불가
      IF GT_TOP_LEFT-ICON EQ ICON_TRANSFER OR
         GT_TOP_LEFT-ICON EQ ICON_WF_WORKITEM_WAITING.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'FLTLVL' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'PUSH' CHANGING LT_CELLTAB.

        INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
      ELSE.
        MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE LT_BOTTOM-CELLTAB.
      ENDIF.

      GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
      = LT_BOTTOM-CELLTAB[].
      MODIFY GT_TOP_LEFT INDEX LS_ROWS-INDEX
      TRANSPORTING CELLTAB.

      APPEND GT_BOTTOM_LEFT. CLEAR GT_BOTTOM_LEFT.
      APPEND GT_BOTTOM_RIGHT. CLEAR GT_BOTTOM_RIGHT.
    ENDLOOP.

    SORT GT_BOTTOM_LEFT BY VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM GT_BOTTOM_LEFT
    COMPARING VBELN POSNR.

  ENDLOOP.

ENDFORM.                    " GET_SAVE_AND_TRANS_LET0917
*&---------------------------------------------------------------------*
*&      Form  Dec_integer_quantity_reflect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOP_RIGHT  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DEC_INTEGER_QUANTITY_REFLECT CHANGING PV_ERROR.

  DATA: LV_INT TYPE I.
  DATA: LV_CHAR(10).
  DATA: LV_CHAR1(10).
  DATA: LV_CHAR2(10),
        LV_MENGE       TYPE P DECIMALS 3,
        LV_TOTAL_MENGE TYPE P DECIMALS 3.

  LOOP AT GT_BOTTOM_RIGHT WHERE ( NOT PKTYP IS INITIAL AND
                    NOT WIDTH IS INITIAL AND NOT ZLENGTH IS INITIAL
                 AND NOT HEIGHT IS INITIAL AND NOT PKWEI IS INITIAL ).

    MOVE-CORRESPONDING GT_BOTTOM_RIGHT TO GT_TOP_RIGHT.

    " 전송 완료인 경우 2번 스크린에 수량 입력 불가
    IF GT_BOTTOM_RIGHT-ICON EQ ICON_TRANSFER OR
        GT_BOTTOM_RIGHT-ICON EQ ICON_WF_WORKITEM_WAITING.
      REFRESH GT_TOP_RIGHT-CELLTAB. CLEAR GT_TOP_RIGHT-MENGE.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'MENGE' CHANGING GT_TOP_RIGHT-CELLTAB.
    ELSE.
      " 드럼인 경우 상단 오른쪽 포장재 수량 입력 불가
      IF GT_BOTTOM_RIGHT-PKTYP EQ 'DM' OR GT_BOTTOM_RIGHT-SPART EQ '32'.
        REFRESH GT_TOP_RIGHT-CELLTAB. CLEAR GT_TOP_RIGHT-MENGE.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'MENGE' CHANGING GT_TOP_RIGHT-CELLTAB.
        " 수량 입력 가능
      ELSE.
        REFRESH GT_TOP_RIGHT-CELLTAB. CLEAR GT_TOP_RIGHT-MENGE.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_EDIT 'MENGE' CHANGING GT_TOP_RIGHT-CELLTAB.
      ENDIF.
    ENDIF.
    APPEND GT_TOP_RIGHT.
  ENDLOOP.

  SORT GT_TOP_RIGHT BY VBELN PKTYP PKMATNR WIDTH ZLENGTH HEIGHT PKWEI.
  DELETE ADJACENT DUPLICATES FROM GT_TOP_RIGHT
  COMPARING VBELN PKTYP PKMATNR WIDTH ZLENGTH HEIGHT PKWEI.

  LOOP AT GT_BOTTOM_RIGHT.
    CLEAR GT_TOP_RIGHT.
    READ TABLE GT_TOP_RIGHT WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                                    PKTYP     = GT_BOTTOM_RIGHT-PKTYP
                                    PKMATNR = GT_BOTTOM_RIGHT-PKMATNR
                                    WIDTH     = GT_BOTTOM_RIGHT-WIDTH
                                    ZLENGTH  = GT_BOTTOM_RIGHT-ZLENGTH
                                    HEIGHT    = GT_BOTTOM_RIGHT-HEIGHT
                                    PKWEI      = GT_BOTTOM_RIGHT-PKWEI
                             BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    MOVE SY-TABIX TO GV_TABIX.
    "
    CASE GT_BOTTOM_RIGHT-SPART.
        " 32 제품군은 수량 올림 처리
      WHEN '32'.
*    IF gt_bottom_right-menge > 0 AND gt_bottom_right-menge < 1.
*      ADD 1 TO  gt_top_right-menge.
*    ELSE.
        CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
          EXPORTING
            I_RTYPE     = '+'
            I_RUNIT     = 1
            I_VALUE     = GT_BOTTOM_RIGHT-MENGE
          IMPORTING
            E_VALUE_RND = GT_BOTTOM_RIGHT-MENGE.
        MODIFY GT_BOTTOM_RIGHT.
      WHEN OTHERS.
    ENDCASE.

    ADD GT_BOTTOM_RIGHT-MENGE TO GT_TOP_RIGHT-MENGE.

    MODIFY GT_TOP_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.

  ENDLOOP.

  " 소수점 수량 1로 반영
  LOOP AT GT_TOP_RIGHT.
    MOVE SY-TABIX TO GV_TABIX.
    MOVE GT_TOP_RIGHT-MENGE TO LV_CHAR.
    SPLIT LV_CHAR AT '.' INTO LV_CHAR1 LV_CHAR2.
    MOVE LV_CHAR2 TO LV_INT.
    IF LV_INT > 0.
      MOVE LV_CHAR1 TO GT_TOP_RIGHT-MENGE.
      ADD 1 TO  GT_TOP_RIGHT-MENGE.
    ENDIF.

    MOVE GT_TOP_RIGHT-MENGE TO LV_INT.
    MOVE LV_INT TO GT_TOP_RIGHT-MENGE.
    MODIFY GT_TOP_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.
  ENDLOOP.

  SORT GT_TOP_RIGHT BY VBELN POSNR.

  " 드럼이 아니면서 최초 생성인 경우 배분 로직 쓴다.
  LOOP AT GT_TOP_RIGHT WHERE NOT PKTYP EQ 'DM'
                         AND ICON EQ ICON_LIGHT_OUT.

    MOVE GT_TOP_RIGHT-MENGE TO LV_TOTAL_MENGE.
    CLEAR LV_MENGE.

    CHECK NOT LV_TOTAL_MENGE IS INITIAL.

    READ TABLE GT_BOTTOM_RIGHT WITH KEY
                               VBELN = GT_TOP_RIGHT-VBELN
                               PKTYP     = GT_TOP_RIGHT-PKTYP
                               PKMATNR = GT_TOP_RIGHT-PKMATNR
                               WIDTH     = GT_TOP_RIGHT-WIDTH
                               ZLENGTH  = GT_TOP_RIGHT-ZLENGTH
                               HEIGHT    = GT_TOP_RIGHT-HEIGHT
                               PKWEI      = GT_TOP_RIGHT-PKWEI.

    CHECK NOT GT_BOTTOM_RIGHT-SPART EQ '32'.

    CLEAR GT_BOTTOM_RIGHT-MENGE.
    MODIFY GT_BOTTOM_RIGHT TRANSPORTING MENGE
                         WHERE VBELN = GT_TOP_RIGHT-VBELN
                              AND PKTYP     = GT_TOP_RIGHT-PKTYP
                              AND PKMATNR = GT_TOP_RIGHT-PKMATNR
                              AND WIDTH     = GT_TOP_RIGHT-WIDTH
                              AND ZLENGTH  = GT_TOP_RIGHT-ZLENGTH
                              AND HEIGHT    = GT_TOP_RIGHT-HEIGHT
                              AND PKWEI      = GT_TOP_RIGHT-PKWEI.

    DO.

      LOOP AT GT_BOTTOM_RIGHT WHERE VBELN = GT_TOP_RIGHT-VBELN
                                AND PKTYP     = GT_TOP_RIGHT-PKTYP
                                AND PKMATNR = GT_TOP_RIGHT-PKMATNR
                                AND WIDTH     = GT_TOP_RIGHT-WIDTH
                                AND ZLENGTH  = GT_TOP_RIGHT-ZLENGTH
                                AND HEIGHT    = GT_TOP_RIGHT-HEIGHT
                                AND PKWEI      = GT_TOP_RIGHT-PKWEI.

        MOVE SY-TABIX TO GV_TABIX.

*      MOVE gt_bottom_right-menge TO lv_menge.
*    CLEAR gt_top_right.
*    READ TABLE gt_top_right WITH KEY vbeln = gt_bottom_right-vbeln
*                                    posnr = gt_bottom_right-posnr
*                         BINARY SEARCH.

*      MOVE sy-tabix TO gv_tabix.
*      MOVE gt_bottom_right-menge TO lv_char.
*      SPLIT lv_char AT '.' INTO lv_char1 lv_char2.
*      MOVE lv_char2 TO lv_int.
*
*      CASE gt_bottom_right-spart.
*        WHEN 32.
*          IF lv_int > 0.
*            MOVE lv_char1 TO gt_bottom_right-menge.
*            ADD 1 TO  gt_bottom_right-menge.
**          ADD gt_bottom_right-menge TO lv_menge.
*          ENDIF.
*        WHEN OTHERS.
*          IF lv_int > 0. "  AND lv_total_menge > lv_menge.
*            MOVE lv_char1 TO gt_bottom_right-menge.
*            ADD 1 TO  gt_bottom_right-menge.
**          ADD gt_bottom_right-menge TO lv_menge.
*          ENDIF.
*      ENDCASE.
*      MOVE gt_bottom_right-menge TO lv_int.
*      MOVE lv_int TO gt_bottom_right-menge.
*      MODIFY gt_bottom_right INDEX gv_tabix TRANSPORTING menge.
        IF LV_TOTAL_MENGE EQ 0.
          EXIT.
        ENDIF.
        " 하단 오른쪽 수량은 수량 1씩 증가 시킨다.
        ADD 1 TO GT_BOTTOM_RIGHT-MENGE.
        MODIFY GT_BOTTOM_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.
        " total 수량은 가감한다.
        SUBTRACT 1 FROM LV_TOTAL_MENGE.
        CLEAR GT_BOTTOM_RIGHT.

      ENDLOOP.
      " 수량 '0' 경우 exit
      IF LV_TOTAL_MENGE EQ 0.
        EXIT.
      ENDIF.

    ENDDO.

  ENDLOOP.

  SORT GT_TOP_RIGHT BY VBELN DELIDN.

ENDFORM.                    " Dec_integer_quantity_reflect
*&---------------------------------------------------------------------*
*&      Form  Dec_integer_quantity_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOP_RIGHT  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DEC_INTEGER_QUANTITY_TWO CHANGING PV_ERROR.

  DATA: LV_INT TYPE I.
  DATA: LV_CHAR(10).
  DATA: LV_CHAR1(10).
  DATA: LV_CHAR2(10),
        LV_MENGE       TYPE P DECIMALS 3,
        LV_TOTAL_MENGE TYPE P DECIMALS 3.

*  SORT gt_top_right BY vbeln pktyp pkmatnr width zlength height pkwei.

  LOOP AT GT_BOTTOM_RIGHT.
    CLEAR GT_TOP_RIGHT.
    READ TABLE GT_TOP_RIGHT WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                                    PKTYP     = GT_BOTTOM_RIGHT-PKTYP
                                    PKMATNR = GT_BOTTOM_RIGHT-PKMATNR
                                    WIDTH     = GT_BOTTOM_RIGHT-WIDTH
                                    ZLENGTH  = GT_BOTTOM_RIGHT-ZLENGTH
                                    HEIGHT    = GT_BOTTOM_RIGHT-HEIGHT
                                    PKWEI      = GT_BOTTOM_RIGHT-PKWEI.
*               BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    MOVE SY-TABIX TO GV_TABIX.
    ADD GT_BOTTOM_RIGHT-MENGE TO GT_TOP_RIGHT-MENGE.
    MODIFY GT_TOP_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.

  ENDLOOP.

  " 소수점 수량 1로 반영
  LOOP AT GT_TOP_RIGHT.
    MOVE SY-TABIX TO GV_TABIX.
    MOVE GT_TOP_RIGHT-MENGE TO LV_CHAR.
    SPLIT LV_CHAR AT '.' INTO LV_CHAR1 LV_CHAR2.
    MOVE LV_CHAR2 TO LV_INT.
    IF LV_INT > 0.
      MOVE LV_CHAR1 TO GT_TOP_RIGHT-MENGE.
      ADD 1 TO  GT_TOP_RIGHT-MENGE.
    ENDIF.

    MOVE GT_TOP_RIGHT-MENGE TO LV_INT.
    MOVE LV_INT TO GT_TOP_RIGHT-MENGE.
    MODIFY GT_TOP_RIGHT INDEX GV_TABIX TRANSPORTING MENGE.
  ENDLOOP.

**  SORT gt_top_right BY vbeln delidn.

ENDFORM.                    " Dec_integer_quantity_TWO
*&---------------------------------------------------------------------*
*&      Form  CROSS_CHECK_DATA_AFTER_CONF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CROSS_CHECK_DATA_AFTER_CONF USING PT_ROWS TYPE LVC_T_ROW
                                        CHANGING PV_ERROR.

  DATA: LT_ROWS    TYPE LVC_T_ROW,
        LS_ROWS    TYPE LVC_S_ROW,
        LT_E1CUVAL TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.

  SORT GT_TOP_RIGHT BY VBELN.
  SORT GT_BOTTOM_RIGHT BY VBELN POSNR.
  SORT GT_AREA BY VBELN POSNR.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    LOOP AT GT_LIPS WHERE VBELN EQ GT_TOP_LEFT-VBELN.

      CASE GC_X.

        WHEN P_RAD1 OR P_RAD2.

        WHEN P_RAD3 OR P_RAD4.

          CHECK GT_TOP_LEFT-POSNR EQ GT_LIPS-POSNR.

      ENDCASE.

      " 4 Screen 에 데이타 구성이 되어 있지 않으면 팅
      CLEAR GT_BOTTOM_LEFT.
      READ TABLE GT_BOTTOM_RIGHT WITH KEY VBELN = GT_LIPS-VBELN
                                         POSNR = GT_LIPS-POSNR
                                 BINARY SEARCH.

      IF SY-SUBRC <> 0.
        REFRESH GT_BOTTOM_LEFT-CELLTAB.

        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'FLTLVL' CHANGING GT_BOTTOM_LEFT-CELLTAB.
      ENDIF.

      " Screen 3 데이타가 있으면 팅 Binary Search  안함.
      READ TABLE GT_BOTTOM_LEFT  WITH KEY VBELN = GT_LIPS-VBELN
                                         POSNR = GT_LIPS-POSNR.

      CHECK SY-SUBRC <> 0.

      CLEAR GT_VBAK.
      READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                       BINARY SEARCH.
      " 납품문서
      MOVE GT_LIPS-VBELN TO GT_BOTTOM_LEFT-VBELN.
      " 품목번호
      MOVE GT_LIPS-POSNR TO GT_BOTTOM_LEFT-POSNR.
      " 자재코드
      MOVE GT_LIPS-MATNR TO GT_BOTTOM_LEFT-MATNR.
      " 제품군	M…ARKTX
      MOVE GT_LIPS-ARKTX TO GT_BOTTOM_LEFT-ARKTX.
      " 플랜트
      MOVE GT_LIPS-WERKS TO GT_BOTTOM_LEFT-WERKS.
      " 제품군
      MOVE GT_LIPS-SPART TO GT_BOTTOM_LEFT-SPART.

      MOVE GT_TOP_LEFT-SHSRQ TO GT_BOTTOM_LEFT-SHSRQ.

      " 조장  주문 특성
      REFRESH LT_E1CUVAL.

      IF NOT GT_LIPS-VGBEL  IS INITIAL AND
         NOT GT_LIPS-VGPOS IS INITIAL.

        REFRESH GT_ET_CHAR. CLEAR GV_ERROR.
        " Z_LE_GET_CHARACTERISTIC_TABLE2
        PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
        USING GT_LIPS-VGBEL GT_LIPS-VGPOS CHANGING GV_ERROR.

      ENDIF.

      " 조장
      PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING GV_ERROR GV_ATWRT.

      IF SY-SUBRC EQ 0.
        PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING GV_ATWRT.
        CONDENSE GV_ATWRT NO-GAPS.
        MOVE: GV_ATWRT TO GT_BOTTOM_LEFT-LENGTH.
      ENDIF.

      " 납품수량
      MOVE: GT_LIPS-LFIMG TO GT_BOTTOM_LEFT-LFIMG.

      " 조장 수
      IF GT_BOTTOM_LEFT-LFIMG <> 0 AND GT_BOTTOM_LEFT-LENGTH <> 0.
        PERFORM CALCULATION_EXCEPTION_HANDING
        USING GT_BOTTOM_LEFT-LFIMG '/' GT_BOTTOM_LEFT-LENGTH
        CHANGING GT_BOTTOM_LEFT-FACTOR.
      ENDIF.

      " 단위
      MOVE: GT_LIPS-VRKME TO GT_BOTTOM_LEFT-VRKME.
      " 판매오더
      MOVE: GT_LIPS-VGBEL TO GT_BOTTOM_LEFT-VBELN_VL.
      " 판매오더품목
      MOVE: GT_LIPS-VGPOS TO GT_BOTTOM_LEFT-POSNR_VL.
      " 판매처
      MOVE: GT_VBAK-KUNNR TO GT_BOTTOM_LEFT-KUNNR.

      READ TABLE GT_LIKP WITH KEY VBELN = GT_LIPS-VBELN.
      IF SY-SUBRC = 0.
        GT_BOTTOM_LEFT-KUNWE =  GT_LIKP-KUNNR. "납품처
      ENDIF.

*___판매처명
      PERFORM GET_CUSTOMER_NAME USING: GT_BOTTOM_LEFT-KUNNR
                                       GT_BOTTOM_LEFT-NAMAG.

*___납품처명
      PERFORM GET_KUNWE_NAME    USING: GT_BOTTOM_LEFT-VBELN
                                       GT_BOTTOM_LEFT-NAMWE.

      " 적재단수
*      MOVE: gt_lips-vrkme TO gt_bottom_left-vrkme.
      " 중량       " 중량단위
      SELECT SINGLE NTGEW GEWEI BRGEW
          INTO (GT_BOTTOM_LEFT-NTGEW, GT_BOTTOM_LEFT-GEWEI,
                GT_BOTTOM_LEFT-BRGEW)
        FROM MARA
       WHERE MATNR EQ GT_BOTTOM_LEFT-MATNR.

*___납품문서의 중량
      SELECT GEWEI
             SUM( NTGEW )
             SUM( BRGEW )
        INTO (GT_BOTTOM_LEFT-GEWEI_LF, GT_BOTTOM_LEFT-NTGEW_LF,
              GT_BOTTOM_LEFT-BRGEW_LF)
        FROM LIPS
       WHERE VBELN = GT_LIPS-VBELN
         AND ( POSNR = GT_LIPS-POSNR
            OR UECHA = GT_LIPS-POSNR )
       GROUP BY GEWEI.

      ENDSELECT.

      MOVE GT_TOP_LEFT-ICON TO GT_BOTTOM_LEFT-ICON.

      " Icon Status
      CLEAR GT_AREA.
      READ TABLE GT_AREA WITH KEY VBELN = GT_LIPS-VBELN
                                  POSNR = GT_LIPS-POSNR
                         BINARY SEARCH.

      IF SY-SUBRC <> 0 AND ( P_RAD1 EQ 'X' OR P_RAD3 EQ GC_X ).
        MOVE ICON_LED_INACTIVE TO GT_BOTTOM_LEFT-ICON.
      ENDIF.

      APPEND GT_BOTTOM_LEFT.  CLEAR GT_BOTTOM_LEFT.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " CROSS_CHECK_DATA_AFTER_CONF
*&---------------------------------------------------------------------*
*&      Form  CROSS_CHECK_DATA_2_4_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CROSS_CHECK_DATA_2_4_SCREEN  USING PT_ROWS TYPE LVC_T_ROW
                                  CHANGING PV_ERROR.
*

  CASE GC_X.
      " 일반 출하 구성
    WHEN P_RAD1 OR P_RAD2.
      PERFORM CREATE_BOTTOM_RIGHT USING PT_ROWS CHANGING PV_ERROR.
      " 선적 시뮬레이션 구성
    WHEN P_RAD3 OR P_RAD4.
      PERFORM CREATE_BOTTOM_RIGHT_TWO USING PT_ROWS CHANGING PV_ERROR.
  ENDCASE.

ENDFORM.                    " CROSS_CHECK_DATA_2_4_SCREEN
*&---------------------------------------------------------------------*
*&      Form  READ_SALES_DOC_DELIVERY_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_SALES_DOC_DELIVERY_DOC TABLES PT_TLIKP STRUCTURE LIKP
                        USING PV_TEXT PV_PERCENTAGE CHANGING PV_ERROR.
  DATA: LT_TLIKP    LIKE LIKP OCCURS 0 WITH HEADER LINE.

  DATA: LV_ERDAT    LIKE LIKP-ERDAT.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  IF P_RAD1 EQ GC_X.

    "  납품문서 조회
    IF S_DLVRQ[] IS INITIAL.

      SELECT A~VBELN
        INTO CORRESPONDING FIELDS OF TABLE PT_TLIKP
        FROM LIKP AS A
       INNER JOIN LIPS AS B
          ON A~VBELN EQ B~VBELN
       INNER JOIN VBAK AS C
          ON B~VGBEL EQ C~VBELN
       INNER JOIN MARA AS D
          ON B~MATNR EQ D~MATNR
*       INNER JOIN VBUK AS E
*          ON A~VBELN EQ E~VBELN
       WHERE A~VSTEL IN S_VSTEL
         AND A~WADAT IN S_WADAT
         AND A~ERDAT IN S_ERDAT
         AND A~VBELN IN S_VBELN
         AND A~KUNNR IN S_KUNNR
         AND B~WERKS IN S_WERKS
         AND C~VKORG IN S_VKORG
         AND C~VTWEG IN S_VTWEG
         AND C~VKBUR IN S_VKBUR
         AND C~VKGRP IN S_VKGRP
         AND C~VBELN IN S_SVBELN
         AND C~KUNNR IN S_SKUNNR
         AND B~MATNR IN S_MATNR
         AND C~AUART IN ('TA',   'ZEXE', 'ZFS', 'ZFQ',
                         'ZORQ', 'ZREQ', 'RE',  'ZCS' )
         AND D~SPART IN S_SPART
         AND A~TRSTA NE ' '.

    ELSE.

* 출하요청 추가
      SELECT A~VBELN
        APPENDING CORRESPONDING FIELDS OF TABLE PT_TLIKP
        FROM LIKP AS A
       INNER JOIN LIPS AS B
          ON A~VBELN EQ B~VBELN
       INNER JOIN VBAK AS C
          ON B~VGBEL EQ C~VBELN
       INNER JOIN ZLET0402 AS D
          ON B~VBELN EQ D~VGBEL
         AND B~POSNR EQ D~VGPOS
       INNER JOIN MARA AS E
          ON B~MATNR EQ E~MATNR
*       INNER JOIN VBUK AS F
*          ON B~VGBEL EQ F~VBELN
       WHERE A~VSTEL IN S_VSTEL
         AND A~WADAT IN S_WADAT
         AND A~ERDAT IN S_ERDAT
         AND A~VBELN IN S_VBELN
         AND A~KUNNR IN S_KUNNR
         AND B~WERKS IN S_WERKS
         AND C~VKORG IN S_VKORG
         AND C~VTWEG IN S_VTWEG
         AND C~VKBUR IN S_VKBUR
         AND C~VKGRP IN S_VKGRP
         AND C~VBELN IN S_SVBELN
         AND C~KUNNR IN S_SKUNNR
         AND B~MATNR IN S_MATNR
         AND C~AUART IN ('TA',   'ZEXE', 'ZFS', 'ZFQ',
                         'ZORQ', 'ZREQ', 'RE',  'ZCS' )
         AND D~DLVRQ IN S_DLVRQ
         AND E~SPART IN S_SPART
         AND A~TRSTA NE ' '.

    ENDIF.

    " 전송완료 조회
  ELSEIF P_RAD2 EQ GC_X OR P_RAD4 EQ GC_X.

    IF P_RAD4 EQ GC_X.
      REFRESH: S_WERKS, S_WADAT, S_ERDAT, S_VBELN, S_KUNNR,
               S_DLVRQ, S_MATNR, S_SHSRQ, S_VKORG, S_VTWEG,
               S_VSTEL, S_VBELN, S_ERDA1.
    ENDIF.

    " 출하요청번호
    IF S_DLVRQ[] IS INITIAL.
      SELECT VBELN
           INTO CORRESPONDING FIELDS OF TABLE PT_TLIKP
         FROM ZLET0917
        WHERE SHSRQ IN S_SHSRQ
             AND VSTEL IN S_VSTEL
             AND WADAT IN S_WADAT
             AND ERDAT IN S_ERDA1
             AND WERKS IN S_WERKS
             AND VBELN IN S_VBELN
             AND KUNNR IN S_KUNNR
             AND VKORG IN S_VKORG
             AND VTWEG IN S_VTWEG
             AND SPART IN S_SPART
             AND VKBUR IN S_VKBUR
             AND VKGRP IN S_VKGRP
             AND VBELN_VL IN S_SVBELN
             AND KUNNR IN S_SKUNNR
             AND MATNR IN S_MATNR
             " 납품분할에 삭제는 제외
             AND NOT ( XLOEK EQ GC_X AND VBELN_VN <> '' ).
    ELSE.
      " 일반 납품문서
      SELECT A~VBELN
           INTO CORRESPONDING FIELDS OF TABLE PT_TLIKP
         FROM ZLET0917 AS A INNER JOIN ZLET0402 AS B
              ON A~VBELN EQ B~VGBEL
            AND A~POSNR EQ B~VGPOS
        WHERE A~SHSRQ IN S_SHSRQ
             AND A~VSTEL IN S_VSTEL
             AND A~WADAT IN S_WADAT
             AND A~ERDAT IN S_ERDA1
             AND A~WERKS IN S_WERKS
             AND A~VBELN IN S_VBELN
             AND A~KUNNR IN S_KUNNR
             AND A~VKORG IN S_VKORG
             AND A~VTWEG IN S_VTWEG
             AND A~SPART IN S_SPART
             AND A~VKBUR IN S_VKBUR
             AND A~VKGRP IN S_VKGRP
             AND A~VBELN IN S_SVBELN
             AND A~KUNNR IN S_SKUNNR
             AND A~MATNR IN S_MATNR
             AND B~DLVRQ IN S_DLVRQ
             " 납품분할에 삭제는 제외
             AND NOT ( XLOEK EQ GC_X AND VBELN_VN <> '' ).
    ENDIF.

    LOOP AT PT_TLIKP.
      IF P_RAD2 = GC_X.
        SELECT SINGLE ERDAT
          INTO LV_ERDAT
          FROM LIKP
         WHERE VBELN =  PT_TLIKP-VBELN
           AND ERDAT IN S_ERDAT.
      ELSE.
        SELECT SINGLE ERDAT
          INTO LV_ERDAT
          FROM VBAK
         WHERE VBELN =  PT_TLIKP-VBELN
           AND ERDAT IN S_ERDAT.
      ENDIF.

      IF SY-SUBRC <> 0.
        DELETE PT_TLIKP.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ELSEIF P_RAD3 EQ  GC_X.

    REFRESH: S_WERKS, S_WADAT, S_ERDAT, S_VBELN, S_KUNNR,
                 S_DLVRQ.

* 컨테이너 시뮬레이션
    SELECT B~VBELN
         APPENDING CORRESPONDING FIELDS OF TABLE PT_TLIKP
       FROM  VBAK AS A  INNER JOIN ZLET0404 AS B
             ON A~VBELN EQ B~VBELN
                                    INNER JOIN ZLET0403 AS C
              ON B~SHSRQ EQ C~SHSRQ
                                    INNER JOIN VBAP AS D
              ON A~VBELN EQ D~VBELN
                                    INNER JOIN MARA AS E
              ON D~MATNR EQ E~MATNR
      WHERE A~VKORG IN S_VKORG
           AND A~VTWEG IN S_VTWEG
           AND A~VKBUR IN S_VKBUR
           AND A~VKGRP IN S_VKGRP
           AND A~VBELN IN S_SVBELN
           AND A~KUNNR IN S_SKUNNR
*         AND a~matnr IN s_matnr
           AND B~SHSRQ IN S_SHSRQ
           AND C~LVORM EQ ''
           AND E~SPART IN S_SPART
           AND B~LVORM EQ ' '
           AND C~LVORM EQ ' '.
  ENDIF.

  IF PT_TLIKP[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    MESSAGE S001 WITH '조회 조건의 데이타가 없습니다.'
    DISPLAY LIKE GC_E.
    RETURN.
  ENDIF.
*  ENDIF.

  SORT PT_TLIKP BY VBELN.
  DELETE ADJACENT DUPLICATES FROM PT_TLIKP COMPARING VBELN.

*___시뮬레이션 데이터의 경우 시뮬레이션 요청번호 단위로 읽기 위해
  IF P_RAD3 = GC_X.
    LT_TLIKP[] = PT_TLIKP[].

    CLEAR   : PT_TLIKP.
    REFRESH : PT_TLIKP.

    SELECT DISTINCT VBELN
      INTO CORRESPONDING FIELDS OF TABLE PT_TLIKP
      FROM ZLET0404
       FOR ALL ENTRIES IN LT_TLIKP
     WHERE SHSRQ IN ( SELECT SHSRQ
                        FROM ZLET0404
                       WHERE VBELN = LT_TLIKP-VBELN
                         AND LVORM = ' ' )
       AND LVORM =  ' '.
  ELSEIF P_RAD4 = GC_X.
    LT_TLIKP[] = PT_TLIKP[].

    CLEAR   : PT_TLIKP.
    REFRESH : PT_TLIKP.

    SELECT DISTINCT VBELN
      INTO CORRESPONDING FIELDS OF TABLE PT_TLIKP
      FROM ZLET0917
       FOR ALL ENTRIES IN LT_TLIKP
     WHERE SHSRQ IN ( SELECT SHSRQ
                        FROM ZLET0917
                       WHERE VBELN = LT_TLIKP-VBELN
                         AND ( XLOEK = ' ' OR VBELN_VN = ' ' ) )
       AND ( XLOEK = ' ' OR VBELN_VN = ' ' ).
  ENDIF.

  " 저장 상태만 조회
  IF P_CHK1 EQ GC_X.
    LOOP AT PT_TLIKP.
      " 포장재 정보 테이블
      SELECT SINGLE VBELN
        INTO PT_TLIKP-VBELN
        FROM ZLET0917
       WHERE VBELN = PT_TLIKP-VBELN.

      IF SY-SUBRC <> 0.
        DELETE PT_TLIKP.
        CONTINUE.
      ENDIF.

      " 포장재 정보 전송 테이블
      SELECT SINGLE VBELN
        INTO PT_TLIKP-VBELN
        FROM ZLET0903
       WHERE VBELN = PT_TLIKP-VBELN.

      IF SY-SUBRC EQ 0.
        DELETE PT_TLIKP.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF PT_TLIKP[] IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      MESSAGE S001 WITH '조회 조건의 데이타가 없습니다.'
      DISPLAY LIKE GC_E.
      RETURN.
    ENDIF.

  ENDIF.

ENDFORM.                    " READ_SALES_DOC_DELIVERY_DOC
*&---------------------------------------------------------------------*
*&      Form  SAPGUI_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_TEXT  text
*      -->P_PERCENTAGE  text
*----------------------------------------------------------------------*
FORM SAPGUI_PROGRESS_INDICATOR  USING    PV_TEXT P_PERCENTAGE.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = P_PERCENTAGE
      TEXT       = PV_TEXT.

ENDFORM.                    " SAPGUI_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  READ_DELIVERY_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3480   text
*      -->P_3481   text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_DELIVERY_DOCUMENT TABLES PT_TLIKP STRUCTURE LIKP
                                        USING PV_TEXT PV_PERCENTAGE
                                       CHANGING PV_ERROR.

  DATA: LT_LIKP LIKE LIKP OCCURS 0 WITH HEADER LINE,
        LT_SEL  LIKE ZLET0404 OCCURS 0 WITH HEADER LINE,
        LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_VBAP LIKE VBAP OCCURS 0 WITH HEADER LINE,
        LT_TEMP LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_SUM  LIKE LIPS OCCURS 0 WITH HEADER LINE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  "  납품문서 조회, 전송완료 조회
  IF P_RAD1 EQ GC_X OR P_RAD2 EQ GC_X.

    CHECK NOT PT_TLIKP[] IS INITIAL.

    SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_LIKP
       FROM LIKP
         FOR ALL ENTRIES IN PT_TLIKP
     WHERE VBELN EQ PT_TLIKP-VBELN.

    IF GT_LIKP[] IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_LIPS
       FROM LIPS
         FOR ALL ENTRIES IN PT_TLIKP
      WHERE VBELN EQ PT_TLIKP-VBELN
           AND WERKS IN S_WERKS.
*           AND lfimg > 0.

    " 컨테이너 시뮬레이션 및 전송 완료 조회
    " 컨테이너 시뮬레이션은 납품문서 조회 이후에 들어온 로직으로 인해
    " 납품문서에 S/O NO를 넣어서 기존 로직을 그대로 흘러간다.
  ELSEIF P_RAD3 EQ GC_X OR P_RAD4 EQ GC_X.

    CHECK NOT PT_TLIKP[] IS INITIAL.

    SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_LIKP
       FROM VBAK
         FOR ALL ENTRIES IN PT_TLIKP
      WHERE VBELN EQ PT_TLIKP-VBELN.

    IF GT_LIKP[] IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_LIPS
       FROM VBAP
         FOR ALL ENTRIES IN PT_TLIKP
     WHERE VBELN EQ PT_TLIKP-VBELN.

    " S/O 정보
    LOOP AT GT_LIPS.
      MOVE GT_LIPS-VBELN TO GT_LIPS-VGBEL.
      MOVE GT_LIPS-POSNR TO GT_LIPS-VGPOS.
      MODIFY GT_LIPS.
    ENDLOOP.

    REFRESH GT_0404.

    " 선적 시뮬레이션 정보 ITEM
    SELECT *
       INTO CORRESPONDING FIELDS OF TABLE GT_0404
       FROM ZLET0404
       FOR ALL ENTRIES IN PT_TLIKP
   WHERE VBELN EQ PT_TLIKP-VBELN
        AND LVORM EQ ' '.

    SORT GT_0404 BY VBELN POSNR.

    MOVE GT_0404[] TO LT_SEL[].
    SORT LT_SEL BY SHSRQ.
    DELETE ADJACENT DUPLICATES FROM LT_SEL COMPARING SHSRQ.

    IF NOT LT_SEL[] IS INITIAL.

      REFRESH GT_0403.

      " 선적 시뮬레이션 정보 HEAD
      SELECT *
         INTO CORRESPONDING FIELDS OF TABLE GT_0403
         FROM ZLET0403
         FOR ALL ENTRIES IN LT_SEL
     WHERE SHSRQ EQ LT_SEL-SHSRQ
        AND LVORM EQ ' '.

      SORT GT_0403 BY SHSRQ.

    ENDIF.

    " 선적 시뮬레이션은 기존 납품문서 로직에 수량과 단위만
    " 대체해서 기존 로직을 흘러간다.
    " 그래서 GT_LIPS에 MODIFY 한다.
    SORT GT_0404 BY VBELN POSNR.
    LOOP AT GT_LIPS.
      CLEAR GT_0404.
      READ TABLE GT_0404 WITH KEY VBELN = GT_LIPS-VBELN
                                  POSNR = GT_LIPS-POSNR
                         BINARY SEARCH.

      IF SY-SUBRC EQ 0.

        MOVE GT_0404-DLRMG TO GT_LIPS-LFIMG.
        MOVE GT_0404-VRKME TO GT_LIPS-VRKME.

      ENDIF.

      MODIFY GT_LIPS.

    ENDLOOP.

    DELETE GT_LIPS WHERE LFIMG EQ 0.

  ENDIF.

  LOOP AT GT_LIPS.
    MOVE GT_LIPS-VBELN TO LT_SUM-VBELN.
    MOVE GT_LIPS-LFIMG TO LT_SUM-LFIMG.
    COLLECT LT_SUM.
  ENDLOOP.

  SORT LT_SUM BY VBELN.
  SORT GT_LIPS BY VBELN.

  " 수량 0 삭제
  LOOP AT GT_LIKP.

    " 선행 데이타 select .부분에 테이블 조건이 다르기
    " 때문에 헤더와 아이템이 다를 수 있어서
    " 크로스 체크 후 없으면 삭제한다.
    CLEAR GT_LIPS.
    READ TABLE GT_LIPS WITH KEY VBELN = GT_LIKP-VBELN
                                BINARY SEARCH.
    IF SY-SUBRC <> 0.
      DELETE GT_LIKP.
    ENDIF.

    CLEAR LT_SUM.
    READ TABLE LT_SUM WITH KEY VBELN = GT_LIKP-VBELN
                                      BINARY SEARCH.
    IF SY-SUBRC EQ 0 AND LT_SUM-LFIMG EQ 0.
      DELETE GT_LIKP.
    ENDIF.

  ENDLOOP.

  SORT GT_LIKP BY VBELN.
  LOOP AT GT_LIPS.
    " 선행 데이타 select .부분에 테이블 조건이 다르기
    " 때문에 헤더와 아이템이 다를 수 있어서
    " 크로스 체크 후 없으면 삭제한다.
    CLEAR GT_LIKP.
    READ TABLE GT_LIKP WITH KEY VBELN = GT_LIPS-VBELN
                                BINARY SEARCH.
    IF SY-SUBRC <> 0.
      DELETE GT_LIPS.
    ENDIF.
  ENDLOOP.

  IF GT_LIKP[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.

      MOVE GT_LIKP[] TO LT_LIKP[].
      SORT LT_LIKP BY VSTEL.
      DELETE ADJACENT DUPLICATES FROM LT_LIKP COMPARING VSTEL.

      IF NOT LT_LIKP[] IS INITIAL.

        " 사업장 조회
        SELECT *
            INTO CORRESPONDING FIELDS OF TABLE GT_0033
          FROM ZLET0033
           FOR ALL ENTRIES IN LT_LIKP
       WHERE VSTEL EQ LT_LIKP-VSTEL.

      ENDIF.

    WHEN P_RAD3 OR P_RAD4.

      MOVE GT_LIPS[] TO LT_TEMP[].
      SORT LT_TEMP BY VBELN.
      DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN.

      IF NOT LT_TEMP[] IS INITIAL.

        " 사업장 조회
        SELECT *
            INTO CORRESPONDING FIELDS OF TABLE GT_0033
          FROM ZLET0033 AS A INNER JOIN VBAP AS B
               ON A~VSTEL EQ B~VSTEL
           FOR ALL ENTRIES IN LT_TEMP
       WHERE VBELN EQ LT_TEMP-VBELN.

      ENDIF.

      SORT GT_0033 BY VBELN.
      LOOP AT GT_LIKP.
        CLEAR GT_0033.
        READ TABLE GT_0033 WITH KEY VBELN = GT_LIKP-VBELN
                                      BINARY SEARCH.
        CHECK SY-SUBRC EQ 0.

        MOVE GT_0033-VSTEL TO GT_LIKP-VSTEL.
        MODIFY GT_LIKP.

      ENDLOOP.

  ENDCASE.

ENDFORM.                    " READ_DELIVERY_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  READ_ZLET0917_ZLET0903
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_TLIKP  text
*      -->P_3499   text
*      -->P_3500   text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_ZLET0917_ZLET0903  USING PV_TEXT PV_PERCENTAGE
                                               CHANGING PV_ERROR.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  " TMS  삭제된 문서들은 삭제
  SELECT *
       INTO CORRESPONDING FIELDS OF TABLE GT_0917
     FROM ZLET0917
             " 납품분할에 삭제는 제외
     WHERE NOT ( XLOEK EQ GC_X AND VBELN_VN <> '' )
    AND WERKS IN S_WERKS
    AND VSTEL IN S_VSTEL .




  SORT GT_LIPS BY VBELN POSNR.
  LOOP AT GT_0917 WHERE XLOEK EQ GC_X
                                    AND NOT VBELN_VN IS INITIAL.

    CLEAR GT_LIPS.
    READ TABLE GT_LIPS WITH KEY VBELN = GT_0917-VBELN
                                POSNR = GT_0917-POSNR
                       BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    DELETE GT_LIPS INDEX SY-TABIX.
    DELETE GT_0917.
*    DELETE gt_likp WHERE vbeln = gt_0917-vbeln.

  ENDLOOP.

  SORT GT_LIPS BY VBELN POSNR.

  "  LIPS 에 데이타가 없으면 LIKP를 삭제한다.
  LOOP AT GT_LIKP.
    CLEAR GT_LIPS.
    READ TABLE GT_LIPS WITH KEY VBELN = GT_LIKP-VBELN
                                BINARY SEARCH.
    IF SY-SUBRC <> 0.
      DELETE GT_LIKP.
    ENDIF.
  ENDLOOP.

  REFRESH GT_0903.

*  " 전송 완료 조회
*  SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE GT_0903
*    FROM ZLET0903.

ENDFORM.                    " READ_ZLET0917_ZLET0903
*&---------------------------------------------------------------------*
*&      Form  READ_SHIPMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS  text
*      -->P_3510   text
*      -->P_3511   text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_SHIPMENT  TABLES PT_LIPS STRUCTURE GT_LIPS
                                          USING PV_TEXT PV_PERCENTAGE
                                   CHANGING PV_ERROR.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_VTTP LIKE VTTP OCCURS 0 WITH HEADER LINE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  MOVE PT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN.

  " 선적 정보 발췌
  IF NOT LT_LIPS[] IS INITIAL.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_VTTP
      FROM VTTP
       FOR ALL ENTRIES IN LT_LIPS
   WHERE VBELN EQ LT_LIPS-VBELN.

  ENDIF.

  MOVE GT_VTTP[] TO LT_VTTP[].
  SORT LT_VTTP BY TKNUM.
  DELETE ADJACENT DUPLICATES FROM LT_VTTP COMPARING TKNUM.

  IF NOT LT_VTTP[] IS INITIAL.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_VTTK
      FROM VTTK
       FOR ALL ENTRIES IN LT_VTTP
   WHERE TKNUM EQ LT_VTTP-TKNUM.

  ENDIF.

ENDFORM.                    " READ_SHIPMENT
*&---------------------------------------------------------------------*
*&      Form  READ_SALES_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS  text
*      -->P_'S/O 정보 발췌'  text
*      -->P_'50'  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_SALES_DOCUMENT  TABLES PT_LIPS STRUCTURE GT_LIPS
                                        USING PV_TEXT PV_PERCENTAGE
                                 CHANGING PV_ERROR.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_VTTP LIKE VTTP OCCURS 0 WITH HEADER LINE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  MOVE PT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY VGBEL.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VGBEL.

  " S/O 정보 발췌
  IF NOT LT_LIPS[] IS INITIAL.

    REFRESH GT_VBAK.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_VBAK
       FROM VBAK
          FOR ALL ENTRIES IN LT_LIPS
    WHERE VBELN EQ LT_LIPS-VGBEL.

    SORT GT_VBAK BY VBELN.

    REFRESH GT_VBAP.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_VBAP
       FROM VBAP
          FOR ALL ENTRIES IN LT_LIPS
    WHERE VBELN EQ LT_LIPS-VGBEL.

    SORT GT_VBAP BY VBELN.

  ENDIF.

ENDFORM.                    " READ_SALES_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  READ_CUSTOMER_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP  text
*      -->P_3532   text
*      -->P_3533   text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM READ_CUSTOMER_POSTING  TABLES PT_LIKP STRUCTURE LIKP
                                          USING PV_TEXT PV_PERCENTAGE
                                   CHANGING PV_ERROR.

  DATA: LT_LIKP LIKE LIKP OCCURS 0 WITH HEADER LINE,
        LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LT_MARA LIKE MARA OCCURS 0 WITH HEADER LINE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  "  VTTK-ZCY_CODE에서 읽은 값을 ZLET0540에서 찾아
  "  CY명, 우편번호, 주소를 표시
  REFRESH GT_0540.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_0540
    FROM ZLET0540 AS A INNER JOIN ZLET0541 AS B
        ON A~ZCY_CODE EQ B~ZCY_CODE.

  MOVE PT_LIKP[] TO LT_LIKP[].
  SORT LT_LIKP BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIKP COMPARING KUNNR.

  IF NOT LT_LIKP[] IS INITIAL.
*    REFRESH gt_adrc1.

    " 우편번호, 주소, 운송지역
*    SELECT a~kunnr  b~post_code1 b~city1 " b~transpzone
*      INTO CORRESPONDING FIELDS OF TABLE gt_adrc1
*      FROM kna1 AS a INNER JOIN adrc AS b
*         ON a~adrnr EQ b~addrnumber
*       FOR ALL ENTRIES IN lt_likp
*     WHERE a~kunnr EQ lt_likp-kunnr.

  ENDIF.

  MOVE GT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN.

  IF NOT LT_LIPS[] IS INITIAL.

    REFRESH GT_ADRC1.
    " 우편번호, 주소, 운송지역
    SELECT A~VBELN A~KUNNR  B~POST_CODE1 B~CITY1 B~EXTENSION2
      INTO CORRESPONDING FIELDS OF TABLE GT_ADRC1
      FROM VBPA AS A INNER JOIN ADRC AS B
         ON A~ADRNR EQ B~ADDRNUMBER
       FOR ALL ENTRIES IN LT_LIPS
     WHERE A~VBELN EQ LT_LIPS-VBELN
         AND A~PARVW EQ 'WE'.
  ENDIF.

  MOVE GT_LIKP[] TO LT_LIKP[].
  SORT LT_LIKP BY VSTEL KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIKP COMPARING VSTEL KUNNR.

  IF NOT LT_LIKP[] IS INITIAL.

    " 톤수 제한
    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_0012
      FROM ZLET0012
       FOR ALL ENTRIES IN LT_LIKP
   WHERE VSTEL  EQ LT_LIKP-VSTEL
        AND KUNNR EQ LT_LIKP-KUNNR.

    " [LE] 혼적불가 거래선 마스터관리
    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_0013
      FROM ZLET0013
       FOR ALL ENTRIES IN LT_LIKP
   WHERE VSTEL  EQ LT_LIKP-VSTEL
        AND KUNNR EQ LT_LIKP-KUNNR.

  ENDIF.

  MOVE GT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING MATNR.

  "  제품군 , 순중량
  IF NOT LT_LIPS[] IS INITIAL.

    SELECT MATNR SPART NTGEW
         INTO CORRESPONDING FIELDS OF TABLE LT_MARA
          FROM MARA
          FOR ALL ENTRIES IN LT_LIPS
     WHERE MATNR EQ LT_LIPS-MATNR.

    SORT LT_MARA BY MATNR SPART.
    LOOP AT GT_LIPS.

      MOVE SY-TABIX TO GV_TABIX.

      CLEAR LT_MARA.
      READ TABLE LT_MARA WITH KEY MATNR = GT_LIPS-MATNR
                                   BINARY SEARCH.

      CHECK SY-SUBRC EQ 0.

      MOVE LT_MARA-SPART TO GT_LIPS-SPART.
      MOVE LT_MARA-NTGEW TO GT_LIPS-NTGEW.

      MODIFY GT_LIPS INDEX GV_TABIX TRANSPORTING SPART NTGEW.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " READ_CUSTOMER_POSTING
*&---------------------------------------------------------------------*
*&      Form  CREATE_GT_TOP_RIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3539   text
*      -->P_3540   text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CREATE_GT_TOP_RIGHT  USING PV_TEXT PV_PERCENTAGE
                                            CHANGING PV_ERROR.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_0918 LIKE ZLET0918 OCCURS 0 WITH HEADER LINE.
  DATA: LV_TEMP LIKE ZLET0917-VSTEL.
  DATA: LV_CHAR.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LV_TRANZ   LIKE ADRC-TRANSPZONE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  REFRESH GT_TOP_LEFT.

  SORT GT_0033 BY VSTEL.
  SORT GT_KNA1 BY KUNNR.
  SORT GT_ADRC1 BY VBELN KUNNR.
  SORT GT_0012 BY VSTEL KUNNR KUNAG.
  SORT GT_0013 BY VSTEL KUNNR KUNAG.
  SORT GT_0917 BY VBELN POSNR DELIDN.
  SORT GT_0903 BY VBELN POSNR DELIDN.
  SORT GT_VTTP BY VBELN.
  SORT GT_VTTK BY TKNUM.
  SORT GT_0403 BY SHSRQ.
  SORT GT_0404 BY VBELN POSNR.
*  SORT gt_0540 BY zcy_code.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_0918
    FROM ZLET0918.

  SORT LT_0918 BY CYCODE.

  LOOP AT GT_LIKP.

    " 거점
    CLEAR GT_0033.
    READ TABLE GT_0033 WITH KEY VSTEL = GT_LIKP-VSTEL
                                  BINARY SEARCH.

*    IF sy-subrc <> 0.
    CLEAR GT_ADRC1.
    READ TABLE GT_ADRC1 WITH KEY VBELN = GT_LIKP-VBELN
                                 KUNNR = GT_LIKP-KUNNR
                        BINARY SEARCH.

    " 출하 요청 텍스트
    MOVE GT_ADRC1-EXTENSION2 TO GT_TOP_LEFT-GRTXT.

    REFRESH GT_TOP_LEFT-CELLTAB. CLEAR GT_TOP_LEFT-CELLTAB.

    CASE GC_X.
      WHEN P_RAD1 OR P_RAD2.

        MOVE: GT_LIKP-WADAT TO GT_TOP_LEFT-WADAT,  " 납품계획인
                    GT_LIKP-KUNNR TO GT_TOP_LEFT-KUNNR, " 납품처
                    'C'           TO GT_TOP_LEFT-VGTYP." Doc Selection
    ENDCASE.

    MOVE: GT_LIKP-VBELN       TO GT_TOP_LEFT-VBELN,
          GT_LIKP-VSTEL       TO GT_TOP_LEFT-VSTEL,      " 원출하지점
          GT_0033-BZAREA      TO GT_TOP_LEFT-BZAREA,     " 사업장
          GT_LIKP-LFDAT       TO GT_TOP_LEFT-LFDAT,      " 배송요청일
          GT_LIKP-LFUHR       TO GT_TOP_LEFT-LFUHR,      " 배송요청시간
          GT_KNA1-NAME1       TO GT_TOP_LEFT-NAME1,      " 업체명
          GT_ADRC1-POST_CODE1 TO GT_TOP_LEFT-POST_CODE1, " 우편번호
          GT_ADRC1-CITY1      TO GT_TOP_LEFT-STREET,     " 주소
          GT_LIKP-ROUTE       TO GT_TOP_LEFT-ROUTE,      " 운송경로

          ''                  TO GT_TOP_LEFT-VHCINEQ,    " 톤수제한 범위
               "  Shipping type(선배송, 택배, 직납, 기타..)

          GT_LIKP-VSBED       TO GT_TOP_LEFT-VSBED,      "   출하조건
          GT_LIKP-INCO1       TO GT_TOP_LEFT-INCO1,
          GT_LIKP-KUNAG       TO GT_TOP_LEFT-KUNAG.

*___판매처명
    PERFORM GET_CUSTOMER_NAME USING: GT_TOP_LEFT-KUNAG
                                     GT_TOP_LEFT-NAMAG.

*___납품처명
    PERFORM GET_KUNWE_NAME    USING: GT_TOP_LEFT-VBELN
                                     GT_TOP_LEFT-NAME1.

    " 톤수제한, 혼적제한
    CLEAR GT_0400.
    READ TABLE GT_0400 WITH KEY VGBEL = GT_LIKP-VBELN
                                BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE: GT_0400-VHCTP TO GT_TOP_LEFT-VHCTYP.   " 차량톤수

      IF NOT GT_0400-ALONE IS INITIAL.
        MOVE GC_V  TO GT_TOP_LEFT-MIXLOD.          " 혼적불가여부
      ENDIF.

      IF GT_0400-BKNFT EQ GC_X.
        MOVE 3 TO GT_TOP_LEFT-BFART.                " 서비스레벨
      ENDIF.

      " 출하 요청 텍스트
      IF GT_TOP_LEFT-GRTXT IS INITIAL.
        MOVE GT_0400-REMARK TO GT_TOP_LEFT-GRTXT.
      ELSE.
        CONCATENATE GT_ADRC1-EXTENSION2 '/' GT_0400-REMARK
          INTO GT_TOP_LEFT-GRTXT.
      ENDIF.

      " 긴급도
      IF GT_0400-IMMDT EQ GC_X. " OR
*      NOT ( gt_0400-arrtm IS INITIAL OR gt_0400-arrtm EQ '000000' ).
        MOVE 1 TO GT_TOP_LEFT-URGNT.
      ENDIF.

      " 운송유형
      IF GT_0400-TRTYP EQ '04'.
        MOVE 'Z003' TO GT_TOP_LEFT-SHTYP.
      ENDIF.

    ELSE.

      "  혼적정보
      CLEAR GT_0012.
      READ TABLE GT_0012 WITH KEY VSTEL   = GT_LIKP-VSTEL
                                           KUNNR = GT_LIKP-KUNNR
                                           KUNAG = GT_LIKP-KUNAG
                        BINARY SEARCH.

      IF SY-SUBRC <> 0.

        CLEAR GT_0012.
        READ TABLE GT_0012 WITH KEY VSTEL  = GT_LIKP-VSTEL
                                    KUNNR = GT_LIKP-KUNNR
                           BINARY SEARCH.
      ENDIF.

      IF SY-SUBRC EQ 0.
        MOVE GT_0012-TON TO GT_TOP_LEFT-VHCTYP.  " 차량톤수
      ENDIF.
      " 차량 정보

      CLEAR GT_0013.
      READ TABLE GT_0013 WITH KEY VSTEL  = GT_LIKP-VSTEL
                                   KUNNR = GT_LIKP-KUNNR
                                   KUNAG = GT_LIKP-KUNAG
                         BINARY SEARCH.
      IF SY-SUBRC <> 0.

        CLEAR GT_0013.
        READ TABLE GT_0013 WITH KEY VSTEL  = GT_LIKP-VSTEL
                                   KUNNR = GT_LIKP-KUNNR
                           BINARY SEARCH.

      ENDIF.

      IF SY-SUBRC EQ 0.
        MOVE GC_V  TO GT_TOP_LEFT-MIXLOD.  " 혼적불가여부
      ENDIF.

    ENDIF.

    IF NOT GT_TOP_LEFT-VHCTYP IS INITIAL.
      MOVE 'VTL' TO GT_TOP_LEFT-VHCINEQ.
    ENDIF.

    IF NOT GT_LIKP-VSTEL IS INITIAL.
      MOVE: GT_LIKP-VSTEL TO GT_TOP_LEFT-ORGSHP,
                ' '                  TO GT_TOP_LEFT-ADDSHP.
    ENDIF.

    " CY명
    CLEAR GT_VTTP.
    READ TABLE GT_VTTP WITH KEY VBELN = GT_LIKP-VBELN
                                        BINARY SEARCH.

    " CY명
    CLEAR GT_VTTK.
    READ TABLE GT_VTTK WITH KEY TKNUM = GT_VTTP-TKNUM
                                        BINARY SEARCH.

    MOVE  GT_VTTK-VSART  TO GT_TOP_LEFT-VSART.

    "  수출 선적 해상 AIR 로직
    IF GT_VTTK-SHTYP EQ 'Z103'.
*      CASE gt_vttk-route(1).
*        WHEN '1'.
*          MOVE 'C81 부산' TO gt_top_left-route_text.
*          CONCATENATE gt_top_left-route(3) 'C81' INTO gt_top_left-route.
*        WHEN '2'.
*          MOVE 'C82 인천' TO gt_top_left-route_text.
*          CONCATENATE gt_top_left-route(3) 'C82' INTO gt_top_left-route.
*        WHEN '3'.
*          MOVE 'C87 마산' TO gt_top_left-route_text.
*          CONCATENATE gt_top_left-route(3) 'C87' INTO gt_top_left-route.
*        WHEN '4'.
*          MOVE 'C86 평택'  TO gt_top_left-route_text.
*          CONCATENATE gt_top_left-route(3) 'C86' INTO gt_top_left-route.
*      ENDCASE.
*
*      CLEAR lt_0918.
*      READ TABLE lt_0918 WITH KEY cycode = gt_top_left-route+3(3)
*                                        BINARY SEARCH.
*
*      IF sy-subrc EQ 0.
*        MOVE lt_0918-post_code1 TO gt_top_left-post_code1.
*        MOVE lt_0918-street          TO gt_top_left-street.
*      ENDIF.

      MOVE 'Z101' TO GT_TOP_LEFT-SHTYP.

      IF GT_VTTK-ZCY_CODE IS INITIAL.

        CLEAR : LV_TRANZ.
        SELECT SINGLE B~TRANSPZONE
          INTO LV_TRANZ
          FROM VBPA AS A
         INNER JOIN ADRC AS B
            ON A~ADRNR = B~ADDRNUMBER
         WHERE A~VBELN = GT_LIKP-VBELN
           AND A~PARVW = 'WE'.

        CONCATENATE  GT_LIKP-ROUTE(2) '-' LV_TRANZ
        INTO GT_TOP_LEFT-ROUTE.

      ENDIF.
    ENDIF.

    " 수출납품문서인 경우 운송경로, 우편번호, 주소 가져오는 로직 변경.
    " 운송경로는 납품문서의 운송경로 앞 3자리+VTTK-CBO의 앞 3자리를
    "  조합하는 로직 그대로

    CLEAR GT_0540.
    READ TABLE GT_0540 WITH KEY ZCY_CODE(3) = GT_VTTK-ZCY_CODE(3)
                                  BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CASE GT_VTTK-VSART.
        WHEN '03'.   "해상
          LV_CHAR = '3'.
        WHEN '04'.   "Air
          LV_CHAR = '4'.
        WHEN OTHERS.
          LV_CHAR = '-'.
      ENDCASE.

      MOVE GT_0540-POST_CODE1 TO GT_TOP_LEFT-POST_CODE1.
      MOVE GT_0540-CITY1      TO GT_TOP_LEFT-STREET.
      MOVE GT_0540-ZCY_DESC   TO GT_TOP_LEFT-ROUTE_TEXT.

      CONCATENATE GT_TOP_LEFT-ROUTE(2) LV_CHAR GT_VTTK-ZCY_CODE(3)
             INTO GT_TOP_LEFT-ROUTE.
*      CONCATENATE gt_top_left-route(3) gt_vttk-zcy_code(3)
*             INTO gt_top_left-route.
    ENDIF.

    IF GT_TOP_LEFT-ICON IS INITIAL.
      MOVE ICON_LIGHT_OUT TO GT_TOP_LEFT-ICON.
    ENDIF.

*    " icon
*    PERFORM create_icon_0903
*    USING gt_top_left-vbeln ' ' CHANGING gt_top_left-icon.

    " 출하유형이 "01"or"02"or"09"or" "이면 "Z001", "03" or "04"면 "Z101"
    " "Z001"일때는 "Z002"~"Z009"까지 변경 가능, "Z101"은 변경 불가

    CASE GT_TOP_LEFT-VSART.
      WHEN '01' OR '02' OR '09' OR '00' OR ''.
        MOVE 'Z001' TO GT_TOP_LEFT-SHTYP.
*{ 기능개선 156428 - 추가
        IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'SHTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE GT_TOP_LEFT-CELLTAB.
        ENDIF.
      WHEN '03' OR '04'.
        MOVE 'Z101' TO GT_TOP_LEFT-SHTYP.
*{ 기능개선 156428 - 추가
        IF SY-TCODE <> GC_TCODE2.
*} 기능개선 156428 - 추가
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'SHTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB INTO TABLE GT_TOP_LEFT-CELLTAB.
        ENDIF.
    ENDCASE .

    " 저장된 정보가 있으면
    CLEAR GT_0917.
    READ TABLE GT_0917 WITH KEY VBELN = GT_TOP_LEFT-VBELN
                                       BINARY SEARCH.

*{ 기능개선 167496 - 변경
    IF SY-SUBRC EQ 0 AND SY-TCODE <> GC_TCODE2.
*    IF sy-subrc EQ 0.
*} 기능개선 167496 - 변경
      MOVE-CORRESPONDING GT_0917 TO GT_TOP_LEFT.
***********************************************************************
      "저장된 정보가 있는 경우, 원 출하지점(orgshp)) <-> 실제 출하지점(vstel) 바꿔서 표시
      CLEAR LV_TEMP.
      LV_TEMP            = GT_TOP_LEFT-VSTEL.
      GT_TOP_LEFT-VSTEL  = GT_TOP_LEFT-ORGSHP.
      GT_TOP_LEFT-ORGSHP = LV_TEMP.

***********************************************************************
      MOVE ICON_GREEN_LIGHT TO GT_TOP_LEFT-ICON.
    ENDIF.

* icon선택 위치 변경
    " icon
    PERFORM CREATE_ICON_0903
    USING GT_TOP_LEFT-VBELN ' ' CHANGING GT_TOP_LEFT-ICON.


    " 전송완료 및 전송 대기인 경우 입력 전체 불가 선언
    IF GT_TOP_LEFT-ICON EQ ICON_TRANSFER OR
       GT_TOP_LEFT-ICON EQ ICON_WF_WORKITEM_WAITING.
      REFRESH GT_TOP_LEFT-CELLTAB. CLEAR GT_TOP_LEFT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT ' ' CHANGING GT_TOP_LEFT-CELLTAB.
    ENDIF.

    APPEND GT_TOP_LEFT. CLEAR GT_TOP_LEFT.

  ENDLOOP.

  " 배치 품목은 원품목에 수량을 더해주고 삭제한다.
  " 즉 품목번호 9000xx 시리즈는  품목번호 '10' 에 수량을 더 해주고
  " 삭제한다.
  MOVE GT_LIPS[] TO LT_LIPS[].
  DELETE GT_LIPS WHERE POSNR > '900000'.
  DELETE LT_LIPS WHERE UECHA IS INITIAL.
  SORT LT_LIPS BY VBELN UECHA.
  SORT GT_LIPS BY VBELN POSNR.

  " 배치 수량을 더한다.
  LOOP AT GT_LIPS.
    LT_LIPS-LFIMG = GT_LIPS-KCMENG.

    IF GT_LIPS-MEINS <> GT_LIPS-VRKME.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = GT_LIPS-MATNR
          I_IN_ME              = GT_LIPS-MEINS
          I_OUT_ME             = GT_LIPS-VRKME
          I_MENGE              = LT_LIPS-LFIMG
        IMPORTING
          E_MENGE              = LT_LIPS-LFIMG
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

      IF SY-SUBRC <> 0.
        MESSAGE E001 WITH '판매단위 변경 오류'.
      ENDIF.
    ENDIF.

    GT_LIPS-LFIMG = GT_LIPS-LFIMG + LT_LIPS-LFIMG.

    MODIFY GT_LIPS.
  ENDLOOP.

ENDFORM.                    " CREATE_GT_TOP_RIGHT

*&---------------------------------------------------------------------*
*&      Form  CREATE_GT_TOP_RIGHT_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3539   text
*      -->P_3540   text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CREATE_GT_TOP_RIGHT_TWO  USING PV_TEXT PV_PERCENTAGE
                                            CHANGING PV_ERROR.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_0918 LIKE ZLET0918 OCCURS 0 WITH HEADER LINE.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  REFRESH GT_TOP_LEFT.

  SORT GT_0033 BY VSTEL.
  SORT GT_ADRC1 BY VBELN KUNNR.
  SORT GT_0012 BY VSTEL KUNNR KUNAG.
  SORT GT_0013 BY VSTEL KUNNR KUNAG.
  SORT GT_0917 BY VBELN POSNR DELIDN.
  SORT GT_0903 BY VBELN POSNR DELIDN.
  SORT GT_VTTP BY VBELN.
  SORT GT_VTTK BY TKNUM.
  SORT GT_0403 BY SHSRQ.
  SORT GT_0404 BY VBELN POSNR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_0918
    FROM ZLET0918.

  SORT LT_0918 BY CYCODE.
  SORT GT_LIKP BY VBELN.

  LOOP AT GT_LIPS.

    CLEAR GT_LIKP.
    "
    READ TABLE GT_LIKP WITH KEY VBELN = GT_LIPS-VBELN
                                      BINARY SEARCH.

    " 거점
    CLEAR GT_0033.
    READ TABLE GT_0033 WITH KEY VSTEL = GT_LIKP-VSTEL
                       BINARY SEARCH.

    REFRESH GT_TOP_LEFT-CELLTAB. CLEAR GT_TOP_LEFT-CELLTAB.

    CASE GC_X.

        " 선적 시뮬레이션
      WHEN P_RAD3 OR P_RAD4.

        CLEAR GT_0404.
        READ TABLE GT_0404 WITH KEY VBELN = GT_LIKP-VBELN
                                     POSNR = GT_LIPS-POSNR
                          BINARY SEARCH.

        CLEAR GT_0403.
        READ TABLE GT_0403 WITH KEY SHSRQ = GT_0404-SHSRQ
                                          BINARY SEARCH.

        MOVE: GT_0403-SHSRQ TO GT_TOP_LEFT-SHSRQ,
              GT_0403-EDATU  TO GT_TOP_LEFT-WADAT,
              'V'                    TO GT_TOP_LEFT-VGTYP,
              GT_LIKP-KUNNR TO GT_TOP_LEFT-KUNNR,
              GT_0403-CONTY TO GT_TOP_LEFT-CONTY,
              GT_0403-CONSZ TO GT_TOP_LEFT-CONSZ.

        CONDENSE GT_TOP_LEFT-SHSRQ NO-GAPS.

        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'VGTYP' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GT_TOP_LEFT-CELLTAB.
    ENDCASE.

    MOVE: GT_LIPS-VBELN TO GT_TOP_LEFT-VBELN,
          GT_LIPS-POSNR TO GT_TOP_LEFT-POSNR,
          GT_LIKP-VSTEL TO GT_TOP_LEFT-VSTEL,
          GT_LIKP-KUNNR TO GT_TOP_LEFT-KUNAG,
          GT_0033-BZAREA TO GT_TOP_LEFT-BZAREA.

*___판매처명
    PERFORM GET_CUSTOMER_NAME USING: GT_TOP_LEFT-KUNAG
                                     GT_TOP_LEFT-NAMAG.

*___납품처명
    PERFORM GET_KUNWE_NAME    USING: GT_TOP_LEFT-VBELN
                                     GT_TOP_LEFT-NAME1.

    " 포장재 정보 테이블
    CLEAR GT_0917.
    READ TABLE GT_0917 WITH KEY VBELN = GT_TOP_LEFT-VBELN
                               POSNR = GT_TOP_LEFT-POSNR
                       BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING GT_0917 TO GT_TOP_LEFT.
      MOVE ICON_GREEN_LIGHT TO GT_TOP_LEFT-ICON.
    ENDIF.

    " icon
    PERFORM CREATE_ICON_0903_TWO
    USING GT_TOP_LEFT-VBELN  GT_TOP_LEFT-POSNR ' '
    CHANGING GT_TOP_LEFT-ICON.

    " 전송완료 및 전송 대기인 경우 입력 전체 불가 선언
    IF GT_TOP_LEFT-ICON EQ ICON_TRANSFER OR
       GT_TOP_LEFT-ICON EQ ICON_WF_WORKITEM_WAITING.
      REFRESH GT_TOP_LEFT-CELLTAB. CLEAR GT_TOP_LEFT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT ' ' CHANGING GT_TOP_LEFT-CELLTAB.
    ENDIF.

    " cy 관리
    CLEAR LT_0918.
    READ TABLE LT_0918 WITH KEY CYCODE = GT_TOP_LEFT-ROUTE+3(3)
                                      BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      MOVE LT_0918-POST_CODE1 TO GT_TOP_LEFT-POST_CODE1.
      MOVE LT_0918-STREET          TO GT_TOP_LEFT-STREET.
    ENDIF.

    IF GT_TOP_LEFT-ICON IS INITIAL.
      MOVE ICON_LIGHT_OUT TO GT_TOP_LEFT-ICON.
    ENDIF.

    APPEND GT_TOP_LEFT. CLEAR GT_TOP_LEFT.

  ENDLOOP.

  " 배치 품목은 원품목에 수량을 더해주고 삭제한다.
  " 즉 품목번호 9000xx 시리즈는  품목번호 '10' 에 수량을 더 해주고
  " 삭제한다.
  MOVE GT_LIPS[] TO LT_LIPS[].
  DELETE GT_LIPS WHERE POSNR > '900000'.
  DELETE LT_LIPS WHERE UECHA IS INITIAL.
  SORT LT_LIPS BY VBELN UECHA.
  SORT GT_LIPS BY VBELN POSNR.

  LOOP AT GT_LIPS.
    LT_LIPS-LFIMG = GT_LIPS-KCMENG.

    IF GT_LIPS-MEINS <> GT_LIPS-VRKME.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = GT_LIPS-MATNR    " <-- 해당 자재코드
          I_IN_ME              = GT_LIPS-MEINS    " <-- 현 수량의 단위
          I_OUT_ME             = GT_LIPS-VRKME    " <-- 변경되어질 수량의 단위
          I_MENGE              = LT_LIPS-LFIMG    " <-- 현 수량 변수
        IMPORTING
          E_MENGE              = LT_LIPS-LFIMG    " <-- 변경되어질 수량변수
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

      IF SY-SUBRC <> 0.
        MESSAGE E001 WITH '판매단위 변경 오류'.
      ENDIF.

    ENDIF.

    GT_LIPS-LFIMG =  GT_LIPS-LFIMG + LT_LIPS-LFIMG.

    MODIFY GT_LIPS.
  ENDLOOP.

ENDFORM.                    " CREATE_GT_TOP_RIGHT_TWO
*&---------------------------------------------------------------------*
*&      Form  check_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      -->P_5224   text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SAVE_DATA USING  PT_ROWS TYPE LVC_T_ROW
                               CHANGING PV_ERROR
                                                 PV_MSG.

  DATA: LT_ROWS      TYPE LVC_T_ROW,
        LS_ROWS      TYPE LVC_S_ROW,
        LV_SHTYP     TYPE SHTYP,
        LV_STRING    TYPE STRING,
        LV_KUNNR     TYPE KUNNR,
        LV_POST_CODE TYPE ZSDT9120-POST_CODE,
        LV_VSTEL     TYPE TVST-VSTEL,
        LV_LFIMG     TYPE LIPS-LFIMG,
        LT_LIPS      LIKE LIPS OCCURS 0 WITH HEADER LINE,
        LT_0917      LIKE ZLET0917 OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_SUM OCCURS 0,
          VBELN LIKE LIKP-VBELN,
          POSNR LIKE LIPS-POSNR,
          LFIMG LIKE LIPS-LFIMG,
          SHSRQ LIKE ZLET0917-SHSRQ,
        END OF LT_SUM,
        LV_CHAR,
        LV_TYPE(4).

  SORT GT_LIPS BY VBELN.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    IF GT_TOP_LEFT-ICON  EQ ICON_GREEN_LIGHT
   OR GT_TOP_LEFT-ICON EQ ICON_TRANSFER
  OR GT_TOP_LEFT-ICON EQ ICON_WF_WORKITEM_WAITING.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN '선택 라인의 상태를 확인 바랍니다.'
      INTO PV_MSG.
      RETURN.
    ENDIF.

    READ TABLE GT_BOTTOM_RIGHT WITH KEY VBELN = GT_TOP_LEFT-VBELN.

    IF SY-SUBRC <> 0.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품 상세 정보가 없습니다.' INTO PV_MSG.
      RETURN.
    ENDIF.

    CASE GC_X.
      WHEN P_RAD1 OR P_RAD2.
      WHEN P_RAD3 OR P_RAD4.
        IF GT_TOP_LEFT-CONTY IS INITIAL OR GT_TOP_LEFT-CONSZ IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN
          '컨테이너 타입과 규격은 필수입니다.' INTO PV_MSG.
          RETURN.
        ENDIF.
    ENDCASE.

*    IF gt_bottom_right-menge <= 0.
*      MOVE gc_x TO pv_error.
*      CONCATENATE gt_top_left-vbeln '포장재 수량은 필수입니다.'
* INTO pv_msg.
*      RETURN.
*    ENDIF.

    CASE GT_TOP_LEFT-VGTYP.
      WHEN 'C'.
        IF NOT GT_TOP_LEFT-VHCTYP IS INITIAL AND
               GT_TOP_LEFT-VHCINEQ IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN '톤수제한은 필수 필드입니다.'
          INTO PV_MSG SEPARATED BY SPACE.
          RETURN.
        ENDIF.

        MOVE GT_TOP_LEFT-VHCTYP(1) TO LV_CHAR.

*        PERFORM check_string_two USING lv_char CHANGING lv_type.

        "  로베드 차량인 경우만 체크
        CASE LV_CHAR.
          WHEN 'L'.
            IF NOT GT_TOP_LEFT-VHCINEQ EQ 'VT'.
              MOVE GC_X TO PV_ERROR.
              CONCATENATE GT_TOP_LEFT-VBELN
              '톤수제한 값을 확인 바랍니다.'
              INTO PV_MSG SEPARATED BY SPACE.
              RETURN.
            ENDIF.
        ENDCASE.

      WHEN 'S'.

        CHECK GT_TOP_LEFT-SHTYP <> 'Z004' AND GT_TOP_LEFT-SHTYP <> 'Z102'.

        IF GT_TOP_LEFT-TDLNR IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN '운송사 코드는 필수 입니다.'
          INTO PV_MSG SEPARATED BY SPACE.
          RETURN.
        ENDIF.

        IF GT_TOP_LEFT-EXTI1 IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN '차량번호는 필수 입니다.'
          INTO PV_MSG.
          RETURN.
        ENDIF.

        IF GT_TOP_LEFT-EXTI2 IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN '기사명은 필수 입니다.'
          INTO PV_MSG.
          RETURN.
        ENDIF.

        IF GT_TOP_LEFT-TPBEZ IS INITIAL.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN '기사전화번호 필수 입니다.'
          INTO PV_MSG.
          RETURN.
        ENDIF.

    ENDCASE.

    IF NOT GT_TOP_LEFT-VHCINEQ IS INITIAL AND
           GT_TOP_LEFT-VHCTYP IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN '차량 톤수는 필수입니다.'
      INTO PV_MSG.
      RETURN.
    ENDIF.

    " 우편번호 체크
    SELECT SINGLE POST_CODE
        INTO LV_POST_CODE
       FROM ZSDT9120
    WHERE POST_CODE EQ GT_TOP_LEFT-POST_CODE1.

    IF SY-SUBRC <> 0.

      SELECT SINGLE POST_CODE
          INTO LV_POST_CODE
         FROM ZSDT9121
      WHERE POST_CODE EQ GT_TOP_LEFT-POST_CODE1.

      IF SY-SUBRC <> 0 AND GT_TOP_LEFT-VGTYP EQ 'C'.
        MOVE GC_X TO PV_ERROR.
        CONCATENATE GT_TOP_LEFT-VBELN
        '납품문서에 대한 우편 번호를 확인 하세요!' INTO PV_MSG.
        RETURN.
      ENDIF .

    ENDIF.

    " 출하지점 체크
    SELECT SINGLE VSTEL
        INTO LV_VSTEL
      FROM TVST
   WHERE VSTEL EQ GT_TOP_LEFT-VSTEL.

    IF SY-SUBRC <> 0 AND NOT GT_TOP_LEFT-VSTEL IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품문서에 대한 출하 지점을 확인하세요!' INTO PV_MSG.
      RETURN.
    ENDIF.

    " 출하지점 체크
    SELECT SINGLE VSTEL
        INTO LV_VSTEL
      FROM TVST
   WHERE VSTEL EQ GT_TOP_LEFT-ADDSHP.

    IF SY-SUBRC <> 0 AND NOT GT_TOP_LEFT-ADDSHP IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품문서에 대한 출하 지점을 확인하세요!' INTO PV_MSG.
      RETURN.
    ENDIF.

    " 출하지점 체크
    SELECT SINGLE VSTEL
        INTO LV_VSTEL
      FROM TVST
   WHERE VSTEL EQ GT_TOP_LEFT-ORGSHP.

    IF SY-SUBRC <> 0 AND NOT GT_TOP_LEFT-ORGSHP IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품문서에 대한 출하 지점을 확인하세요!' INTO PV_MSG.
      RETURN.
    ENDIF.

*    CLEAR gt_bottom_right.
*    READ TABLE gt_bottom_right WITH KEY vbeln = gt_top_left-vbeln
*                                        pktyp = ''.
*
*    IF sy-subrc EQ 0.
*      MOVE gc_x TO pv_error.
*      CONCATENATE gt_top_left-vbeln
*      '포장재 유형은 입력하세요!' INTO pv_msg.
*      RETURN.
*    ENDIF.

    CLEAR GT_LIPS.
    READ TABLE GT_LIPS WITH KEY VBELN = GT_TOP_LEFT-VBELN
                                       BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                       BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_VBAK-KUNNR
      IMPORTING
        OUTPUT = LV_KUNNR.

    CHECK LV_KUNNR(1) EQ 3.

    SELECT SINGLE B~SHTYP
        INTO LV_SHTYP
      FROM VTTP AS A INNER JOIN VTTK AS B
         ON A~TKNUM EQ B~TKNUM
   WHERE A~VBELN EQ GT_TOP_LEFT-VBELN
        AND B~SHTYP EQ 'Z103'.

    IF SY-SUBRC <> 0 AND GT_TOP_LEFT-VGTYP EQ 'C'.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품문서에 대한 수출 선적 문서를 먼저 생성하십시오!' INTO PV_MSG.
      RETURN.
    ENDIF.

  ENDLOOP.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
*
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.

        LOOP AT GT_BOTTOM_RIGHT WHERE VBELN EQ GT_TOP_LEFT-VBELN.
          MOVE: GT_BOTTOM_RIGHT-VBELN    TO LT_SUM-VBELN,
                     GT_BOTTOM_RIGHT-MENGE TO LT_SUM-LFIMG.
          COLLECT  LT_SUM. CLEAR LT_SUM.
        ENDLOOP.

        LOOP AT LT_SUM WHERE LFIMG EQ 0.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE LT_SUM-VBELN
          '포장재 수량이 없습니다.' INTO PV_MSG.
          RETURN.
        ENDLOOP.

      WHEN P_RAD3 OR P_RAD4.

        LOOP AT GT_BOTTOM_RIGHT WHERE SHSRQ EQ GT_TOP_LEFT-SHSRQ.
          MOVE: GT_BOTTOM_RIGHT-SHSRQ    TO LT_SUM-SHSRQ,
                     GT_BOTTOM_RIGHT-MENGE TO LT_SUM-LFIMG.
          COLLECT  LT_SUM. CLEAR LT_SUM.
        ENDLOOP.

        LOOP AT LT_SUM WHERE LFIMG EQ 0.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE LT_SUM-SHSRQ
          '포장재 수량이 없습니다.' INTO PV_MSG.
          RETURN.
        ENDLOOP.

    ENDCASE.

    " 납품 문서 변경사항 체크
    SORT LT_0917 BY VBELN.
    DELETE ADJACENT DUPLICATES FROM LT_0917 COMPARING VBELN.

    IF NOT LT_0917[] IS INITIAL.

      SELECT VBELN POSNR UECHA LFIMG
          INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
        FROM LIPS
         FOR ALL ENTRIES IN LT_0917
       WHERE VBELN EQ LT_0917-VBELN.

      REFRESH LT_SUM.

      LOOP AT LT_LIPS.
        MOVE-CORRESPONDING LT_LIPS TO LT_SUM.
        IF NOT LT_LIPS-UECHA IS INITIAL .
          MOVE LT_LIPS-UECHA TO LT_SUM-POSNR.
        ENDIF.
        COLLECT LT_SUM.
      ENDLOOP.

      SORT LT_SUM BY VBELN POSNR.

      LOOP AT LT_0917.
        CLEAR LT_SUM.
        READ TABLE LT_SUM WITH KEY VBELN = LT_0917-VBELN
                                   POSNR = LT_0917-POSNR
                          BINARY SEARCH.
        IF SY-SUBRC <> 0.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN
          '삭제된 납품문서. 확인 바랍니다.' INTO PV_MSG.
          RETURN.
        ENDIF.

        IF LT_0917-LFIMG <> LT_SUM-LFIMG.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN
          '납품 수량이 변경. 삭제 후 재생성 바랍니다.' INTO PV_MSG.
          RETURN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " check_SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  DELETE_DELIVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*----------------------------------------------------------------------*
FORM DELETE_DELIVERY  USING    P_SENDER.

  DATA: LT_ROWS   TYPE LVC_T_ROW,
        LS_ROWS   TYPE LVC_S_ROW,
        LV_STRING TYPE STRING,
        LV_CHAR   TYPE CHAR10.

  PERFORM GET_SELECT_ROW USING P_SENDER CHANGING LT_ROWS[].

  CLEAR GV_ERROR.
  PERFORM LT_ROWS
  USING LT_ROWS '선택한 라인이 없습니다.' CHANGING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  CLEAR: GV_ERROR, GV_MESSAGE.
  " 삭제 대상 체크 로직
  PERFORM CHECK_DELETE_DATA
  USING LT_ROWS CHANGING GV_ERROR GV_MESSAGE.
  PERFORM MESSAGE_RESULT USING GV_MESSAGE GC_E.

  CHECK GV_ERROR IS INITIAL.
  " popup 화면
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM USING '삭제'
                           'DB의 데이타를 삭제 하시겠습니까?'
                           '1'
                           GV_ANSWER.

  CHECK GV_ANSWER EQ 1 .
  " db 삭제
  PERFORM DELETE_ZLET0917 USING LT_ROWS CHANGING GV_ERROR.

  LOOP AT LT_ROWS INTO LS_ROWS.
    MOVE LS_ROWS-INDEX TO GV_TABIX.
    MOVE ICON_LIGHT_OUT  TO GT_TOP_LEFT-ICON.
    MODIFY GT_TOP_LEFT INDEX GV_TABIX TRANSPORTING ICON.
  ENDLOOP.

  LV_CHAR = LINES( LT_ROWS[] ).
  CONCATENATE LV_CHAR '건을 삭제 했습니다.' INTO LV_STRING.

  PERFORM MESSAGE_RESULT USING LV_STRING GC_S.

  REFRESH: GT_TOP_RIGHT, GT_BOTTOM_LEFT, GT_BOTTOM_RIGHT.

  CASE GC_X.
    WHEN P_RAD1 OR P_RAD2.
      SORT GT_TOP_LEFT BY VBELN POSNR.
      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
      SORT GT_TOP_RIGHT BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
    WHEN P_RAD3 OR P_RAD4.
      SORT GT_TOP_LEFT BY SHSRQ.
      SORT GT_BOTTOM_LEFT BY VBELN POSNR.
      SORT GT_TOP_RIGHT BY VBELN DELIDN.
      SORT GT_BOTTOM_RIGHT BY VBELN POSNR DELIDN.
  ENDCASE.

ENDFORM.                    " DELETE_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING   PV_TITLE
                               PV_TEXT
                               PV_DEFAULT
                               PV_ANSWER.

  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELETE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*      <--P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM CHECK_DELETE_DATA  USING    PT_ROWS TYPE LVC_T_ROW
                        CHANGING PV_ERROR
                                 PV_MESSAGE.

  DATA: LT_ROWS  TYPE LVC_T_ROW,
        LS_ROWS  TYPE LVC_S_ROW,
        LS_0903  TYPE ZLET0903,
        LS_0917  TYPE ZLET0917,
        LV_SHTYP TYPE CHAR4.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    "  icon 상태 확인
    IF NOT ( GT_TOP_LEFT-ICON EQ ICON_YELLOW_LIGHT OR
              GT_TOP_LEFT-ICON EQ ICON_GREEN_LIGHT ).
      MOVE '삭제할 대상의 상태를 확인 바랍니다.' TO PV_MESSAGE.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    " TMS  전송 상태 확인

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.

        SELECT SINGLE *
             INTO LS_0903
            FROM ZLET0903
         WHERE VBELN EQ GT_TOP_LEFT-VBELN.

      WHEN P_RAD3 OR P_RAD4.

        SELECT SINGLE *
             INTO LS_0903
            FROM ZLET0903
         WHERE VBELN EQ GT_TOP_LEFT-VBELN
              AND POSNR EQ GT_TOP_LEFT-POSNR.

    ENDCASE.

    IF SY-SUBRC EQ 0 AND LS_0903-STATUS EQ 'Y'.
      MOVE 'TMS 전송한 대상은 삭제할 수 없습니다.' TO PV_MESSAGE.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.

        " 삭제 대상 확인
        SELECT SINGLE *
          INTO LS_0917
           FROM ZLET0917
        WHERE VBELN EQ GT_TOP_LEFT-VBELN
             AND XLOEK EQ ''.

      WHEN P_RAD3 OR P_RAD4.

        " 삭제 대상 확인
        SELECT SINGLE *
          INTO LS_0917
           FROM ZLET0917
        WHERE VBELN EQ GT_TOP_LEFT-VBELN
             AND POSNR EQ GT_TOP_LEFT-POSNR
             AND XLOEK EQ ''.

    ENDCASE.

    IF SY-SUBRC <> 0.
      MOVE '삭제할 대상이 없습니다.' TO PV_MESSAGE.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_DELETE_DATA
*&---------------------------------------------------------------------*
*&      Form  DELETE_ZLET0917
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_INSERT  text
*----------------------------------------------------------------------*
FORM DELETE_ZLET0917  USING    PT_ROWS TYPE LVC_T_ROW
                        CHANGING PV_ERROR.

  DATA: LS_ROWS TYPE LVC_S_ROW.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.
        DELETE FROM ZLET0917 WHERE VBELN EQ GT_TOP_LEFT-VBELN.
      WHEN P_RAD3 OR P_RAD4.
        DELETE FROM ZLET0917 WHERE VBELN EQ GT_TOP_LEFT-VBELN
                              AND POSNR EQ GT_TOP_LEFT-POSNR.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " DELETE_ZLET0917
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEND_TMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SEND_TMS  USING PT_ROWS TYPE LVC_T_ROW
                     CHANGING PV_ERROR PV_MSG.

  DATA: LS_ROWS  TYPE LVC_S_ROW,
        LV_SHTYP TYPE VTTK-SHTYP,
        LV_KUNNR TYPE KUNAG,
        LT_LIPS  LIKE LIPS OCCURS 0 WITH HEADER LINE,
        LT_SUM   LIKE LIPS OCCURS 0 WITH HEADER LINE,
        LT_0917  LIKE ZLET0917 OCCURS 0 WITH HEADER LINE.

  SORT GT_LIPS BY VBELN.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    IF NOT GT_TOP_LEFT-ICON EQ ICON_GREEN_LIGHT.
      MOVE '전송할 대상을 확인 바랍니다.' TO PV_MSG.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    CASE GC_X.
      WHEN P_RAD1.
        " 전송 완료 체크
        SELECT SINGLE MANDT
             INTO SY-MANDT
            FROM ZLET0903
          WHERE VBELN EQ GT_TOP_LEFT-VBELN
               AND STATUS EQ 'Y'.

      WHEN P_RAD3.
        " 전송 완료 체크
        SELECT SINGLE MANDT
           INTO SY-MANDT
          FROM ZLET0903
        WHERE VBELN EQ GT_TOP_LEFT-VBELN
             AND POSNR EQ GT_TOP_LEFT-POSNR
             AND STATUS EQ 'Y'.

    ENDCASE.

    IF SY-SUBRC EQ 0.
      MOVE '전송 완료건입니다.' TO PV_MSG.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.

    CLEAR GT_LIKP.
    READ TABLE GT_LIPS WITH KEY VBELN = GT_TOP_LEFT-VBELN
                                       BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    CLEAR GT_VBAK.
    READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                     BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_VBAK-KUNNR
      IMPORTING
        OUTPUT = LV_KUNNR.

    CHECK LV_KUNNR(1) EQ 3.

    SELECT SINGLE B~SHTYP
        INTO LV_SHTYP
      FROM VTTP AS A INNER JOIN VTTK AS B
         ON A~TKNUM EQ B~TKNUM
   WHERE A~VBELN EQ GT_TOP_LEFT-VBELN
        AND B~SHTYP EQ 'Z103'.

    IF SY-SUBRC <> 0  AND GT_TOP_LEFT-VGTYP EQ 'C'.
      MOVE GC_X TO PV_ERROR.
      CONCATENATE GT_TOP_LEFT-VBELN
      '납품문서에 대한 수출 선적 문서를 먼저 생성하십시오!' INTO PV_MSG.
      RETURN.
    ENDIF.

  ENDLOOP.

  CHECK P_RAD1 EQ GC_X.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
*
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CASE GC_X.

      WHEN P_RAD1 OR P_RAD2.
        " 삭제 로직 체크
        SELECT *
           INTO CORRESPONDING FIELDS OF TABLE LT_0917
           FROM ZLET0917
          WHERE VBELN EQ GT_TOP_LEFT-VBELN
               AND XLOEK EQ ''.

      WHEN P_RAD3 OR P_RAD4.
        " 삭제 로직 체크
        SELECT *
           INTO CORRESPONDING FIELDS OF TABLE LT_0917
           FROM ZLET0917
          WHERE VBELN EQ GT_TOP_LEFT-VBELN
               AND POSNR EQ GT_TOP_LEFT-POSNR
               AND XLOEK EQ ''.

    ENDCASE.

    SORT LT_0917 BY VBELN.
    DELETE ADJACENT DUPLICATES FROM LT_0917 COMPARING VBELN.

    IF NOT LT_0917[] IS INITIAL.

      SELECT VBELN POSNR UECHA LFIMG
          INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
        FROM LIPS
         FOR ALL ENTRIES IN LT_0917
       WHERE VBELN EQ LT_0917-VBELN.

      LOOP AT LT_LIPS.
        MOVE LT_LIPS-VBELN TO LT_SUM-VBELN.
        MOVE LT_LIPS-POSNR TO LT_SUM-POSNR.
        MOVE LT_LIPS-LFIMG TO LT_SUM-LFIMG.
        IF NOT LT_LIPS-UECHA IS INITIAL .
          MOVE LT_LIPS-UECHA TO LT_SUM-POSNR.
        ENDIF.
        COLLECT LT_SUM.
      ENDLOOP.

      SORT LT_SUM BY VBELN POSNR.

      LOOP AT LT_0917.
        CLEAR LT_SUM.
        READ TABLE LT_SUM WITH KEY VBELN = LT_0917-VBELN
                                   POSNR = LT_0917-POSNR
                          BINARY SEARCH.
        IF SY-SUBRC <> 0.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN
          '삭제된 납품문서. 확인 바랍니다.' INTO PV_MSG.
          RETURN.
        ENDIF.

        IF LT_0917-LFIMG <> LT_SUM-LFIMG.
          MOVE GC_X TO PV_ERROR.
          CONCATENATE GT_TOP_LEFT-VBELN
          '납품 수량이 변경. 삭제 후 재생성 바랍니다.' INTO PV_MSG.
          RETURN.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_SEND_TMS
*&---------------------------------------------------------------------*
*&      Form  CHECK_NEW_LOGIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*      <--P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM CHECK_NEW_LOGIC  USING  PT_ROWS TYPE LVC_T_ROW
                      CHANGING PV_ERROR
                                    PV_MESSAGE.

  DATA: LS_ROWS TYPE LVC_S_ROW.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_BOTTOM_RIGHT.
    READ TABLE GT_BOTTOM_RIGHT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    IF GT_BOTTOM_RIGHT-ICON EQ ICON_TRANSFER OR
       GT_BOTTOM_RIGHT-ICON EQ ICON_WF_WORKITEM_WAITING.
      MOVE GC_X TO PV_ERROR.
      MOVE '전송 상태는 라인 추가 불가합니다.' TO PV_MESSAGE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_NEW_LOGIC
*&---------------------------------------------------------------------*
*&      Form  CHECK_GRID3_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*      <--P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM CHECK_GRID3_SCREEN  USING  PT_ROWS TYPE LVC_T_ROW
                      CHANGING PV_ERROR
                                    PV_MESSAGE.

  DATA: LS_ROWS TYPE LVC_S_ROW.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_BOTTOM_LEFT.
    READ TABLE GT_BOTTOM_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    IF GT_BOTTOM_LEFT-ICON <> ICON_LED_INACTIVE.
      MOVE GC_X TO PV_ERROR.
      MOVE '아이콘 상태를 확인 바랍니다.' TO PV_MESSAGE.
      RETURN.
    ENDIF.

    CLEAR GT_BOTTOM_RIGHT.
    READ TABLE GT_BOTTOM_RIGHT WITH KEY VBELN = GT_BOTTOM_LEFT-VBELN
                                        POSNR = GT_BOTTOM_LEFT-POSNR.

    IF SY-SUBRC EQ 0.
      MOVE GC_X TO PV_ERROR.
      MOVE '생성된 납품 문서 번호입니다.' TO PV_MESSAGE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_GRID3_SCREEN
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELETE_LOGIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ROWS  text
*      <--P_GV_ERROR  text
*      <--P_GV_MESSAGE  text
*----------------------------------------------------------------------*
FORM CHECK_DELETE_LOGIC  USING  PT_ROWS TYPE LVC_T_ROW
                      CHANGING PV_ERROR
                                    PV_MESSAGE.

  DATA: LS_ROWS TYPE LVC_S_ROW.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_RIGHT.
    READ TABLE GT_TOP_RIGHT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    IF GT_TOP_RIGHT-ICON EQ ICON_TRANSFER OR
       GT_TOP_RIGHT-ICON EQ ICON_WF_WORKITEM_WAITING.
      MOVE GC_X TO PV_ERROR.
      MOVE '전송 상태는 라인 삭제 불가합니다.' TO PV_MESSAGE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_DELETE_LOGIC
*&---------------------------------------------------------------------*
*&      Form  CHECK_CS_BOM_VKRME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*      -->P_PV_SPART  text
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*      -->P_PV_MATNR  text
*      -->P_PS_LIPS  text
*      -->P_LIKE  text
*      -->P_LIPS  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_CS_BOM_VKRME  USING  PV_VBELN
                               PV_POSNR
                               PV_SPART
                               PV_VGBEL
                               PV_VGPOS
                               PV_MATNR
                               PS_LIPS LIKE GT_LIPS
             CHANGING PV_ERROR.

  DATA: LT_STPOL LIKE STPOL OCCURS 0 WITH HEADER LINE.
  DATA: LS_VBFA  LIKE VBFA,
        LV_DEC4  TYPE P DECIMALS 4,
        LV_DEC3  TYPE P DECIMALS 3,
        LV_MATNR TYPE MATNR.


  DATA: LS_EKKN        LIKE EKKN,
        LV_DRUM_NUMBER TYPE ZMMT0217-DRUM_NUMBER.


  REFRESH LT_STPOL.
  " BOM 전개
  PERFORM CS_BOM_EXPLOSION_MAT TABLES LT_STPOL
  USING PV_MATNR PS_LIPS-WERKS CHANGING PV_ERROR.

  "  MARA-MTART="ROH1", "ROH2"인 자재코드(목박스)를 구한다.
  LOOP AT LT_STPOL.
    SELECT SINGLE MATNR
        INTO LV_MATNR
      FROM MARA
     WHERE MATNR EQ LT_STPOL-IDNRK
         AND  MTART EQ GC_MRM1.
    IF SY-SUBRC <> 0.
      DELETE LT_STPOL.
    ENDIF.
  ENDLOOP.

*     7) 수량(STPO-KMLMG)으로 표준 조장을 구한다.
*      ① 0.333이면 3,000M가 표준 조장
*      ② 0.500이면 2,000M가 표준 조장
*      ③ 1.000이면 1,000M가 표준 조장
*      ④ 2.000이면 500M가 표준 조장

  CLEAR LT_STPOL.
  READ TABLE LT_STPOL INDEX 1.

  " 조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서 구한
  "  표준조장과 일치하면 정조장으로 인식
  CLEAR PV_ERROR.
  PERFORM READ_ET_CHAR
  USING 'SAP_LENGTH_VKRME' CHANGING PV_ERROR GV_ATWRT.

  "  조장(SAP_LENGTH_VKRME)의 ATWRT 값이 위에서 구한
  " 표준조장과 일치하면 정조장으로 인식
  CASE LT_STPOL-MENGE.
    WHEN '0.219'.
      MOVE 4500 TO LV_DEC3.
    WHEN '0.333'.
      MOVE 3000 TO LV_DEC3.
    WHEN '0.500'.
      MOVE 2000 TO LV_DEC3.
    WHEN '1.000'.
      MOVE 1000 TO LV_DEC3.
    WHEN '2.000'.
      MOVE 500 TO LV_DEC3.
  ENDCASE.

  IF NOT LV_DEC3 EQ GV_ATWRT.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  "  ATWRT로 자재마스터의 특성에서 RL_CA_RAMP_OPTION(특수드럼표기),
  " RL_CA_NO(드럼기호), RL_CA_FG_DIA_CHG(플랜지경변경),
  " RL_CA_IN_WIDTH_CHG(내폭변경)을 구한다. -티코드 ZSD1R6020 참고
  PERFORM MATERIALCHARACTERISTIC_GET
  USING PV_SPART LT_STPOL-IDNRK CHANGING PV_ERROR.

ENDFORM.                    " CHECK_CS_BOM_VKRME
*&---------------------------------------------------------------------*
*&      Form  CREATE_3_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_3_SCREEN .

  DATA: LT_E1CUVAL TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL.

  SORT GT_TOP_RIGHT BY VBELN.
  SORT GT_0917 BY VBELN POSNR.
  SORT GT_0903 BY VBELN POSNR.

  CLEAR GT_TOP_LEFT.
  LOOP AT GT_TOP_LEFT.

    LOOP AT GT_LIPS WHERE VBELN EQ GT_TOP_LEFT-VBELN.

      CASE GC_X.

        WHEN P_RAD1 OR P_RAD2.
        WHEN P_RAD3 OR P_RAD4.

          CHECK GT_TOP_LEFT-POSNR EQ GT_LIPS-POSNR.

      ENDCASE.

      " Screen 3 데이타가 있으면 팅 Binary Search  안함.
      READ TABLE GT_BOTTOM_LEFT  WITH KEY VBELN = GT_LIPS-VBELN
                                         POSNR = GT_LIPS-POSNR.

      CHECK SY-SUBRC <> 0.

      CLEAR GT_VBAK.
      READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                                       BINARY SEARCH.
      " 납품문서
      MOVE GT_LIPS-VBELN TO GT_BOTTOM_LEFT-VBELN.
      " 품목번호
      MOVE GT_LIPS-POSNR TO GT_BOTTOM_LEFT-POSNR.
      " 자재코드
      MOVE GT_LIPS-MATNR TO GT_BOTTOM_LEFT-MATNR.
      " 제품군	M…ARKTX
      MOVE GT_LIPS-ARKTX TO GT_BOTTOM_LEFT-ARKTX.
      " 플랜트
      MOVE GT_LIPS-WERKS TO GT_BOTTOM_LEFT-WERKS.
      " 제품군
      MOVE GT_LIPS-SPART TO GT_BOTTOM_LEFT-SPART.
      " 제품군
      MOVE GT_TOP_LEFT-SHSRQ TO GT_BOTTOM_LEFT-SHSRQ.

      " 조장  주문 특성
      REFRESH LT_E1CUVAL.

      IF NOT GT_LIPS-VGBEL IS INITIAL AND NOT GT_LIPS-VGPOS IS INITIAL.

        REFRESH GT_ET_CHAR. CLEAR GV_ERROR.
        " Z_LE_GET_CHARACTERISTIC_TABLE2
        PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
        USING GT_LIPS-VGBEL GT_LIPS-VGPOS CHANGING GV_ERROR.

      ENDIF.

      " 조장
      PERFORM READ_ET_CHAR
      USING 'SAP_LENGTH_VKRME' CHANGING GV_ERROR GV_ATWRT.

      IF SY-SUBRC EQ 0.
        PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING GV_ATWRT.
        CONDENSE GV_ATWRT NO-GAPS.
        MOVE: GV_ATWRT TO GT_BOTTOM_LEFT-LENGTH.
      ENDIF.

      " 조장 수
      " 조장
*      PERFORM read_et_char USING 'SAP_MILLCA_FACTOR'
*CHANGING gv_error gv_atwrt.

*      IF sy-subrc EQ 0.
*        MOVE: gv_atwrt TO gt_bottom_left-factor.
*      ENDIF.

      " 납품수량
      MOVE: GT_LIPS-LFIMG TO GT_BOTTOM_LEFT-LFIMG.

      " 조장 수
      IF GT_BOTTOM_LEFT-LFIMG <> 0 AND GT_BOTTOM_LEFT-LENGTH <> 0.
        PERFORM CALCULATION_EXCEPTION_HANDING
        USING GT_BOTTOM_LEFT-LFIMG '/' GT_BOTTOM_LEFT-LENGTH
        CHANGING GT_BOTTOM_LEFT-FACTOR.
      ENDIF.

      " 단위
      MOVE: GT_LIPS-VRKME TO GT_BOTTOM_LEFT-VRKME.
      " 판매오더
      MOVE: GT_LIPS-VGBEL TO GT_BOTTOM_LEFT-VBELN_VL.
      " 판매오더품목
      MOVE: GT_LIPS-VGPOS TO GT_BOTTOM_LEFT-POSNR_VL.
      " 판매처
      MOVE: GT_VBAK-KUNNR TO GT_BOTTOM_LEFT-KUNNR.

      READ TABLE GT_LIKP WITH KEY VBELN = GT_LIPS-VBELN.
      IF SY-SUBRC = 0.
        GT_BOTTOM_LEFT-KUNWE =  GT_LIKP-KUNNR. "납품처
      ENDIF.

*___판매처명
      PERFORM GET_CUSTOMER_NAME USING: GT_BOTTOM_LEFT-KUNNR
                                       GT_BOTTOM_LEFT-NAMAG.

*___납품처명
      PERFORM GET_KUNWE_NAME    USING: GT_BOTTOM_LEFT-VBELN
                                       GT_BOTTOM_LEFT-NAMWE.

      " 적재단수
*      MOVE: gt_lips-vrkme TO gt_bottom_left-vrkme.
      " 중량       " 중량단위
      SELECT SINGLE NTGEW GEWEI BRGEW
          INTO (GT_BOTTOM_LEFT-NTGEW, GT_BOTTOM_LEFT-GEWEI,
                GT_BOTTOM_LEFT-BRGEW)
        FROM MARA
       WHERE MATNR EQ GT_BOTTOM_LEFT-MATNR.

*___납품문서의 중량
      SELECT GEWEI
             SUM( NTGEW )
             SUM( BRGEW )
        INTO (GT_BOTTOM_LEFT-GEWEI_LF, GT_BOTTOM_LEFT-NTGEW_LF,
              GT_BOTTOM_LEFT-BRGEW_LF)
        FROM LIPS
       WHERE VBELN = GT_LIPS-VBELN
         AND ( POSNR = GT_LIPS-POSNR
            OR UECHA = GT_LIPS-POSNR )
       GROUP BY GEWEI.

      ENDSELECT.

      CLEAR GT_0917.
      READ TABLE GT_0917 WITH KEY VBELN = GT_BOTTOM_LEFT-VBELN
                                  POSNR = GT_BOTTOM_LEFT-POSNR
                        BINARY SEARCH.

      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING GT_0917 TO GT_BOTTOM_LEFT.
      ENDIF.

      "  전송완료 및 전송대기인 경우 적재단수 입력 불가
      IF GT_TOP_LEFT-ICON EQ ICON_TRANSFER OR
         GT_TOP_LEFT-ICON EQ ICON_WF_WORKITEM_WAITING.

        REFRESH GT_BOTTOM_LEFT-CELLTAB.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'FLTLVL' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_LEFT-CELLTAB.
      ENDIF.

      " Icon Status
      MOVE GT_TOP_LEFT-ICON TO GT_BOTTOM_LEFT-ICON.

      IF GT_BOTTOM_LEFT-FLTLVL IS INITIAL.
*{ 기능개선 157325 - 변경
        IF GT_BOTTOM_LEFT-SPART = '22'.
          GT_BOTTOM_LEFT-FLTLVL = 10.
        ELSEIF GT_BOTTOM_LEFT-SPART = '10'.
          IF GT_TOP_LEFT-SHTYP = 'Z101'.
            GT_BOTTOM_LEFT-FLTLVL = 2.
          ELSE.
            GT_BOTTOM_LEFT-FLTLVL = 1.
          ENDIF.
        ELSE.
          GT_BOTTOM_LEFT-FLTLVL = 1.
        ENDIF.

*        MOVE 1 TO gt_bottom_left-fltlvl.
*} 기능개선 157325 - 변경
      ENDIF.

      APPEND GT_BOTTOM_LEFT.  CLEAR GT_BOTTOM_LEFT.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " CREATE_3_SCREEN
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_20_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*      -->P_PV_SPART  text
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*      -->P_PV_MATNR  text
*      -->P_PV_KUNNR  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_20_A  USING  PV_VBELN
                            PV_POSNR
                            PV_SPART
                            PV_VGBEL
                            PV_VGPOS
                            PV_MATNR
                            PV_KUNNR
           CHANGING PV_ERROR.

  DATA: LS_VBFA LIKE VBFA.
  DATA: LS_EKKN        LIKE EKKN,
        LV_DRUM_NUMBER TYPE ZMMT0217-DRUM_NUMBER.

  CLEAR PV_ERROR.

  "  판매오더와 품목을 EKKN-VBELN, VBELP에 넣어
  " 구매오더(EBELN)와 품목(EBELP)을 구한다.
  PERFORM CHECK_EKKN
  USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR LS_EKKN.

  " 상품(드럼) 입고 정보
  CLEAR PV_ERROR.
  PERFORM CHECK_ZMMT0217
  USING LS_EKKN-EBELN LS_EKKN-EBELP CHANGING PV_ERROR LV_DRUM_NUMBER.

  " 위에서 드럼기호를 구하지 못한다면 펑션
  " Z_LE_GET_CHARACTERISTIC_TABLE2의 I_VBELN, I_POSNR에 판매오더와
  " 품목(LIPS-VGBEL, VGPOS)을 넣어서 특성값을 구한다.

*  IF lv_drum_number IS INITIAL.   "기능개선 160066 - 삭제

  CLEAR: PV_ERROR, GT_AREA.
  PERFORM GET_ZMMT0217_DRUM_NUMBER
  USING PV_VGBEL PV_VGPOS PV_MATNR
  CHANGING PV_ERROR LV_DRUM_NUMBER GT_AREA.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

*  ENDIF.

  CLEAR PV_ERROR.
  PERFORM GET_CREATE_AREA_44 CHANGING LV_DRUM_NUMBER PV_ERROR.

ENDFORM.                    " GET_SPART_20_A
*&---------------------------------------------------------------------*
*&      Form  CHECK_VBFA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_VBFA  text
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_VBFA  USING PS_VBFA LIKE VBFA
                       PV_VGBEL
                       PV_VGPOS
              CHANGING PV_ERROR.

  CLEAR GT_VBAK.
  READ TABLE GT_VBAK WITH KEY VBELN = PV_VGBEL
                                   BINARY SEARCH.

  IF NOT GT_VBAK-AUART EQ 'ZCS'.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SELECT SINGLE VBELV POSNV
      INTO (PS_VBFA-VBELV, PS_VBFA-POSNV)
      FROM VBFA
   WHERE VBELN   EQ PV_VGBEL
        AND POSNN EQ PV_VGPOS.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " CHECK_VBFA
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_MENGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0510  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_ORDER_MENGE  TABLES   PT_0510 STRUCTURE GT_0510
                       USING PV_SPART PV_MATNR PV_KUNNR
                           PS_VBAP LIKE GT_VBAP PS_0510 LIKE GT_0510
                 CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_INT TYPE P DECIMALS 2.
  DATA: LV_CHAR1 TYPE CHAR20,
        LV_CHAR2 TYPE CHAR20,
        LV_CHAR3 TYPE CHAR20,
        LV_FLAG.

*  STEP1

  CLEAR: PT_0510, PS_0510.
  LOOP AT PT_0510 WHERE SPART EQ PV_SPART
                    AND MATNR EQ PV_MATNR
                    AND KUNNR EQ PV_KUNNR
                    AND NOT SO_MENG IS INITIAL."오더배수량

    IF NOT PS_VBAP-KWMENG IS INITIAL AND NOT PT_0510-SO_MENG IS INITIAL.
      PERFORM CALCULATION_EXCEPTION_HANDING
      USING PS_VBAP-KWMENG '/' GT_0510-SO_MENG CHANGING PS_VBAP-KWMENG.
      MOVE PS_VBAP-KWMENG TO LV_CHAR1.

      " 소숫점 확인
      SPLIT LV_CHAR1 AT '.' INTO LV_CHAR2 LV_CHAR3.
      MOVE LV_CHAR3 TO LV_INT.
    ENDIF.

    " 배수인 경우
    IF LV_INT EQ 0.
      MOVE PT_0510 TO PS_0510.
      LV_FLAG = GC_X.
      RETURN.
    ENDIF.

  ENDLOOP.

  CLEAR: PT_0510, PS_0510.
  LOOP AT PT_0510 WHERE SPART EQ PV_SPART
                    AND MATNR EQ PV_MATNR
                    AND KUNNR EQ PV_KUNNR
                    AND SO_MENG IS INITIAL.   " 오더배수량
    MOVE PT_0510 TO PS_0510.
    RETURN.
  ENDLOOP.

  CLEAR: PT_0510, PS_0510.
  LOOP AT PT_0510 WHERE SPART EQ PV_SPART
                                    AND MATNR EQ PV_MATNR.
    MOVE PT_0510 TO PS_0510.
    RETURN.
  ENDLOOP.

  IF LV_FLAG IS INITIAL.
    CLEAR PS_0510.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_ORDER_MENGE
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_MENGE_64
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0510  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_ORDER_MENGE_64  TABLES   PT_0510 STRUCTURE GT_0510
                       USING PV_SPART PV_MATNR PV_KUNNR
                           PS_VBAP LIKE GT_VBAP PS_0510 LIKE GT_0510
                                  PV_SALES_FLAG
                 CHANGING PV_ERROR PS_AREA LIKE GT_AREA.

  DATA: LV_INT TYPE P DECIMALS 2.
  DATA: LV_CHAR1 TYPE CHAR20,
        LV_CHAR2 TYPE CHAR20,
        LV_CHAR3 TYPE CHAR20,
        LV_FLAG.

*  STEP1
  CLEAR: PT_0510, PS_0510.
  LOOP AT PT_0510 WHERE SPART EQ PV_SPART
                    AND MATNR EQ PV_MATNR
                    AND KUNNR EQ PV_KUNNR
                    AND SALES_FLAG EQ PV_SALES_FLAG.

    MOVE PT_0510 TO PS_0510.
    RETURN.
  ENDLOOP.

  CLEAR: PT_0510, PS_0510.
  LOOP AT PT_0510 WHERE SPART EQ PV_SPART
                    AND MATNR EQ PV_MATNR
                    AND SALES_FLAG EQ PV_SALES_FLAG.
    MOVE PT_0510 TO PS_0510.
    RETURN.
  ENDLOOP.

  IF LV_FLAG IS INITIAL.
    CLEAR PS_0510.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_ORDER_MENGE_64
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_LIGHT_41
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_VBAK_KUNNR  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_LIGHT_41  USING  PV_VBELN
                                PV_POSNR
                                PV_SPART
                                PV_VGBEL
                                PV_VGPOS
                                PV_MATNR
                                PV_KUNNR
                       CHANGING PV_ERROR.

  DATA: LV_PD_CA_CABLE_LENGTH TYPE ATWRT,
        LV_C_LENGTH           LIKE ZLET0510-C_LENGTH_TO,
        LV_MENGE              TYPE P DECIMALS 3.

  DATA: LV_FACTOR_ATWRT       TYPE ATWRT.

  REFRESH GT_ET_CHAR.

  CLEAR PV_ERROR.
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
                               USING PV_VGBEL
                                     PV_VGPOS
                            CHANGING PV_ERROR.

  CLEAR GT_VBAK.
  READ TABLE GT_VBAK WITH KEY VBELN = GT_LIPS-VGBEL
                              BINARY SEARCH.

  REFRESH GT_OBJECT.

  " 자재특성 값을 가져온다.
  PERFORM GET_MATERIAL_CHARACT TABLES GT_OBJECT
                                USING PV_MATNR.
  "
  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
                              USING 'PD_CA_CABLE_LENGTH'
                           CHANGING PV_ERROR
                                    LV_PD_CA_CABLE_LENGTH.

  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_FACTOR'
                    CHANGING GV_ERROR
                             LV_FACTOR_ATWRT.

  SELECT SINGLE KWMENG
    INTO LV_MENGE
    FROM VBAP
   WHERE VBELN EQ PV_VGBEL
     AND POSNR EQ PV_VGPOS.

  PERFORM CHANGE_STRING_REPLACE  USING ','
                              CHANGING LV_PD_CA_CABLE_LENGTH.
  PERFORM CHANGE_STRING_REPLACE  USING 'm'
                              CHANGING LV_PD_CA_CABLE_LENGTH.
  PERFORM CHANGE_STRING_NOGAP CHANGING LV_PD_CA_CABLE_LENGTH.

  MOVE LV_PD_CA_CABLE_LENGTH TO LV_C_LENGTH.

  CLEAR: GT_0510, PV_ERROR.
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF  GT_0510
    FROM ZLET0510
   WHERE SPART         =  PV_SPART
     AND C_LENGTH_FROM <= LV_C_LENGTH
     AND C_LENGTH_TO   >= LV_C_LENGTH
     AND VSBED         =  GT_VBAK-VSBED.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

*  MOVE lv_c_length TO lv_menge.
  "  총 적재수 / 적재단수
  IF NOT GT_0510-TOT_QTY IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING USING LV_MENGE
                                                '/'
                                                GT_0510-TOT_QTY
                                       CHANGING GT_AREA-MENGE.
  ENDIF.

*  IF NOT  gt_0510-coil_height IS INITIAL AND
*gt_0510-load_qty IS INITIAL.
*    PERFORM calculation_exception_handing
*USING gt_0510-coil_height '*' gt_0510-load_qty CHANGING gt_area-height .
*  ENDIF.

  MOVE: PV_VBELN           TO GT_AREA-VBELN,
        PV_POSNR           TO GT_AREA-POSNR,
        GT_0510-PKKTX      TO GT_AREA-PKTYP, "   폭
        GT_0510-PKWIDTH2   TO GT_AREA-WIDTH, "   폭
        GT_0510-PKLENGTH2  TO GT_AREA-ZLENGTH, "   길이
*        gt_0510-pkweight2  TO gt_area-pkwei,
        GT_0510-PKMEINS2   TO GT_AREA-PMEINS,
        '41-A'             TO GT_AREA-CODE_POINT.

  MOVE  LV_FACTOR_ATWRT    TO LV_MENGE.

  " 포장재 무게( 1차 포장재 무게 * 총 적재수) + 2차 포장재 무게
  IF NOT GT_0510-PKWEIGHT1 IS INITIAL AND NOT LV_MENGE IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_0510-PKWEIGHT1
                                                '*'
                                                LV_MENGE
                                       CHANGING GT_AREA-PKWEI.
  ENDIF.

  ADD GT_0510-PKWEIGHT2 TO GT_AREA-PKWEI.

  "" 포장재 높이( 1차 포장재 높이 * 적재단수) + 2차 포장재 높이
  IF NOT GT_0510-COIL_HEIGHT IS INITIAL AND
         GT_0510-LOAD_QTY    IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_0510-COIL_HEIGHT
                                                '*'
                                                GT_0510-LOAD_QTY
                                       CHANGING GT_AREA-HEIGHT .
  ENDIF.

  ADD GT_0510-PKHEIGHT2 TO GT_AREA-HEIGHT. "  높이`

  CONCATENATE GT_0510-SPART GT_0510-PKKTX GT_0510-SEQNO
         INTO GT_AREA-KEY_TEXT SEPARATED BY SPACE.

  APPEND GT_AREA.

*  ADD GS_0510-ZHEIGHT TO gt_area-height. "  높이`

ENDFORM.                    " GET_SPART_LIGHT_41
*&---------------------------------------------------------------------*
*&      Form  CALL_LEGEND_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_LEGEND_POPUP.

  DATA: LT_HRFPM_ICON_LEGEND_IT TYPE HRFPM_ICON_LEGEND_IT,
        LS_HRFPM_ICON_LEGEND    TYPE HRFPM_ICON_LEGEND.

  REFRESH LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_LED_INACTIVE.
  LS_HRFPM_ICON_LEGEND-TEXT = '포장재 정보 없음'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_LIGHT_OUT.
  LS_HRFPM_ICON_LEGEND-TEXT = '변경 사항 없음'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_YELLOW_LIGHT.
  LS_HRFPM_ICON_LEGEND-TEXT = '변경'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_GREEN_LIGHT..
  LS_HRFPM_ICON_LEGEND-TEXT = '저장'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_RED_LIGHT..
  LS_HRFPM_ICON_LEGEND-TEXT = '에러'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  LS_HRFPM_ICON_LEGEND-ICON = ICON_TRANSFER.
  LS_HRFPM_ICON_LEGEND-TEXT = 'TMS 전송'.
  APPEND LS_HRFPM_ICON_LEGEND TO LT_HRFPM_ICON_LEGEND_IT.

  CALL FUNCTION 'HRFPM_DISPLAY_ICON_LEGEND'
    EXPORTING
      I_T_ICON_LEGEND = LT_HRFPM_ICON_LEGEND_IT.

ENDFORM.                    " CALL_LEGEND_POPUP
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_3 .

  LOOP AT GT_BOTTOM_LEFT WHERE ICON <> ICON_TRANSFER.

*    CHECK gt_bottom_left-icon <> icon_green_light.

    " 포장재 정보가 없으면 입력 불가
    CLEAR GT_AREA.
    READ TABLE GT_AREA WITH KEY VBELN = GT_BOTTOM_LEFT-VBELN
                                POSNR = GT_BOTTOM_LEFT-POSNR
                        BINARY SEARCH.

    IF SY-SUBRC <> 0.
      REFRESH GT_BOTTOM_LEFT-CELLTAB.

      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'FLTLVL' CHANGING GT_BOTTOM_LEFT-CELLTAB.

      MOVE ICON_LED_INACTIVE TO GT_BOTTOM_LEFT-ICON.
    ENDIF.

    MODIFY GT_BOTTOM_LEFT.

  ENDLOOP.

ENDFORM.                    " MODIFY_SCREEN_3
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOP_LEFT_VBELN  text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION  USING PV_PARAMETER PV_TCODE  PV_VBELN.

  SET PARAMETER ID PV_PARAMETER  FIELD PV_VBELN.
  CALL TRANSACTION PV_TCODE AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  CHECK_CHANGED_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CHANGED_SET .

  DATA : L_VALID(1),
         L_REFRESH(1) TYPE C VALUE 'X'.

  CALL METHOD GC_ALV_GRID1->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID   = L_VALID
    CHANGING
      C_REFRESH = L_REFRESH.

  CALL METHOD GC_ALV_GRID2->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID   = L_VALID
    CHANGING
      C_REFRESH = L_REFRESH.

  CALL METHOD GC_ALV_GRID3->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID   = L_VALID
    CHANGING
      C_REFRESH = L_REFRESH.

  CALL METHOD GC_ALV_GRID4->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID   = L_VALID
    CHANGING
      C_REFRESH = L_REFRESH.

ENDFORM.                    " CHECK_CHANGED_SET
*&---------------------------------------------------------------------*
*&      Form  GET_0402_0400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4384   text
*      -->P_32     text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_0402_0400  USING PV_TEXT PV_PERCENTAGE
                                            CHANGING PV_ERROR.

  DATA: LT_LIPS LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.

  PERFORM SAPGUI_PROGRESS_INDICATOR USING PV_TEXT PV_PERCENTAGE.

  MOVE GT_LIPS[] TO LT_LIPS[].
  SORT LT_LIPS BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN.

  " Zlet0402, zlet0400 톤수제한, 혼적제한
  IF NOT LT_LIPS[] IS INITIAL.
    SELECT A~VGBEL
           B~VHCTP
           B~ALONE
           B~BKNFT
           B~REMARK
           B~IMMDT
           B~ARRTM
      INTO CORRESPONDING FIELDS OF TABLE GT_0400
      FROM ZLET0402 AS A
     INNER JOIN ZLET0400 AS B
        ON A~DLVRQ = B~DLVRQ
       FOR ALL ENTRIES IN LT_LIPS
     WHERE A~VGBEL = LT_LIPS-VBELN
      AND B~VSTEL IN S_VSTEL.

    SORT GT_0400 BY VGBEL.
  ENDIF.

ENDFORM.                    " GET_0402_0400
*&---------------------------------------------------------------------*
*&      Form  GET_ZLET0530_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SPART  text
*      -->P_LV_PKTYP  text
*      -->P_LS_MOD_CELLS_VALUE  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_ZLET0530_MATNR  USING    PV_SPART
                                  PV_PKTYP
                                  PS_MOD_CELLS_VALUE
                         CHANGING PV_ERROR.

  DATA: LS_0530 LIKE ZLET0530.

  SELECT SINGLE *
    INTO LS_0530
    FROM ZLET0530
   WHERE SPART EQ PV_SPART
     AND PKKTX EQ PV_PKTYP
     AND MATNR EQ PS_MOD_CELLS_VALUE.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  MOVE: LS_0530-PKLENGTH2 TO GT_AREA-ZLENGTH,
        LS_0530-PKWIDTH2  TO GT_AREA-WIDTH,
        LS_0530-PKHEIGHT2 TO GT_AREA-HEIGHT,
        LS_0530-PKWEIGHT2 TO GT_AREA-PKWEI,
        LS_0530-PKMEINS2  TO GT_AREA-PMEINS.

ENDFORM.                    " GET_ZLET0530_MATNR
*&---------------------------------------------------------------------*
*&      Form  button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK  USING  PS_COL_ID  TYPE  LVC_S_COL
                                          PS_ROW_NO  TYPE  LVC_S_ROID.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL.

  DATA: LT_BOTTOM LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE.

  CLEAR GT_BOTTOM_RIGHT.
  READ TABLE GT_BOTTOM_RIGHT INDEX PS_ROW_NO-ROW_ID.

  CHECK SY-SUBRC EQ 0.
  " 4사분면 화면에서 연필(수정) 버튼을 누른 경우
  " 포장재 유형, 포장재 코드, 폭, 길이, 높이, 무게 수정 가능
  " 포장재 수량은 입력 불가
  " 포장재 유형, 포장재 코드, 폭, 길이, 높이, 무게를 입력한 경우
  " 1사분면 화면에 레코드가 하나 생성되는데
  " 입력시 마다 무한 생성을 방지하기 위해서 버튼 생성
  CASE GT_BOTTOM_RIGHT-PUSH.
    WHEN ICON_CHANGE.

      REFRESH GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

      IF GT_BOTTOM_RIGHT-PKTYP EQ 'DM'.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_EDIT 'DMMATNR' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      ENDIF.

      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'ZMEINS' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'WIDTH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'PKWEI' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PMEINS' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

      MOVE ICON_DISPLAY TO GT_BOTTOM_RIGHT-PUSH.
      MODIFY GT_BOTTOM_RIGHT INDEX PS_ROW_NO-ROW_ID
      TRANSPORTING CELLTAB PUSH.
      PERFORM REFRESH_GRID USING GC_ALV_GRID4.

      " 4사분면 화면에서 안경 (Display 버튼을 누른 경우
      " 포장재 유형, 포장재 코드, 폭, 길이, 높이, 무게 입력 불가
      " 포장재 수량은 입력 가능
    WHEN ICON_DISPLAY.

      PERFORM CHECK_CHANGED_SET.
      REFRESH GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

      IF GT_BOTTOM_RIGHT-PKTYP EQ 'DM'.
        PERFORM MODIFY_CELL_ATTRIBUTE
        USING GC_NO_EDIT 'DMMATNR' CHANGING LT_CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      ENDIF.

      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_EDIT 'MENGE' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'ZMEINS' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'WIDTH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PKWEI' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
      PERFORM MODIFY_CELL_ATTRIBUTE
      USING GC_NO_EDIT 'PMEINS' CHANGING LT_CELLTAB.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

      MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
      MODIFY GT_BOTTOM_RIGHT INDEX PS_ROW_NO-ROW_ID
      TRANSPORTING CELLTAB PUSH.

      CLEAR GT_BOTTOM_RIGHT.
      READ TABLE GT_BOTTOM_RIGHT INDEX PS_ROW_NO-ROW_ID.

      CHECK SY-SUBRC EQ 0.

      " 포장재 수량을 입력한 경우 1사분면 화면에 수량 sum 한다.
      " 소숫점 수량이 있으면  2번째 screen 2 수량 반영
      REFRESH GT_TOP_RIGHT.
      PERFORM DEC_INTEGER_QUANTITY_REFLECT CHANGING GV_ERROR.

      PERFORM REFRESH_GRID USING GC_ALV_GRID2.
      PERFORM REFRESH_GRID USING GC_ALV_GRID4.

  ENDCASE.

ENDFORM.                    " button_click
*&---------------------------------------------------------------------*
*&      Form  GET_ZLET0600T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIPS_VBELN  text
*      -->P_GT_LIPS_POSNR  text
*      -->P_GT_LIPS_SPART  text
*      -->P_GT_LIPS_VGBEL  text
*      -->P_GT_LIPS_VGPOS  text
*      -->P_GT_LIPS_MATNR  text
*      -->P_GT_LIPS  text
*      -->P_LV_KDKG4  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_ZLET0600T  USING    PV_VBELN
                                              PV_POSNR
                                              PV_SPART
                                              PV_VGBEL
                                              PV_VGPOS
                                              PV_MATNR
                                              PS_LIPS
                                              PV_KDKG4
                            CHANGING PV_ERROR.

  DATA: LT_600T LIKE ZLE0600T OCCURS 0 WITH HEADER LINE,
        LT_0530 LIKE ZLET0530 OCCURS 0 WITH HEADER LINE.

  " 상품인 경우만 배선 자재를 찾는다.
  SELECT SINGLE MANDT
      INTO SY-MANDT
    FROM MARA
   WHERE MATNR EQ PV_MATNR
     AND MTART EQ 'HAWA'.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_600T
     FROM ZLE0600T
  WHERE VBELN EQ PV_VBELN.

  SORT LT_600T BY PKGNO PKMATNR VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_600T
  COMPARING PKGNO PKMATNR VBELN.

  IF LT_600T[] IS INITIAL .
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_0530
     FROM ZLET0530
  WHERE SPART EQ '43'
       AND PKKTX EQ 'PL'.

  SORT LT_0530 BY MATNR.
  LOOP AT LT_600T.

    CLEAR LT_0530.
    READ TABLE LT_0530 WITH KEY MATNR = LT_600T-PKMATNR
                                  BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      MOVE PV_VBELN TO GT_AREA-VBELN.
      MOVE PV_POSNR TO GT_AREA-POSNR.
      MOVE 'PL' TO GT_AREA-PKTYP.

      GT_AREA-MENGE = LT_600T-PKMENG.
      MOVE: LT_0530-PKLENGTH2 TO GT_AREA-ZLENGTH,
                LT_0530-PKWIDTH2   TO GT_AREA-WIDTH,
                LT_0530-PKHEIGHT2  TO GT_AREA-HEIGHT,
                LT_0530-PKWEIGHT2 TO GT_AREA-PKWEI,
                LT_0530-PKMEINS2  TO GT_AREA-PMEINS.
    ENDIF.
    MOVE LT_600T-PKMATNR TO GT_AREA-PKMATNR.
  ENDLOOP.

ENDFORM.                    " GET_ZLET0600T
*&---------------------------------------------------------------------*
*&      Form  CALCULATION_EXCEPTION_HANDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_LIPS_LFIMG  text
*      -->P_0692   text
*      -->P_GT_0510_LSMENG  text
*      <--P_GT_AREA_MENGE  text
*----------------------------------------------------------------------*
FORM CALCULATION_EXCEPTION_HANDING  USING PV_ONE
                                        PV_SIGN
                                        PV_TWO
                              CHANGING PV_RETURN.

  CATCH SYSTEM-EXCEPTIONS ARITHMETIC_ERRORS = 4
                          OTHERS = 8.

    CASE PV_SIGN.
      WHEN '/'.
        CHECK NOT PV_ONE IS INITIAL AND NOT PV_TWO IS INITIAL.
        PV_RETURN = PV_ONE / PV_TWO.

      WHEN '*'.
        CHECK NOT PV_ONE IS INITIAL AND NOT PV_TWO IS INITIAL.
        PV_RETURN = PV_ONE * PV_TWO.

      WHEN '+'.
        PV_RETURN = PV_ONE + PV_TWO.

      WHEN '-'.
        PV_RETURN = PV_ONE - PV_TWO.

    ENDCASE.

  ENDCATCH.

ENDFORM.                    " CALCULATION_EXCEPTION_HANDING
*&---------------------------------------------------------------------*
*&      Form  prepare_sort_table
*&---------------------------------------------------------------------*
FORM PREPARE_SORT_TABLE CHANGING PT_SORT TYPE LVC_T_SORT.

  DATA LS_SORT TYPE LVC_S_SORT.

  LS_SORT-SPOS      = '1'.
  LS_SORT-FIELDNAME = 'SHSRQ'.
  LS_SORT-UP        = 'X'.
  LS_SORT-DOWN      = SPACE.
  LS_SORT-SUBTOT    = 'X'.
  APPEND LS_SORT TO PT_SORT.

ENDFORM.                    " prepare_sort_table
*&---------------------------------------------------------------------*
*&      Form  CREATE_BOTTOM_RIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ROWS  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CREATE_BOTTOM_RIGHT  USING PT_ROWS TYPE LVC_T_ROW
                                              CHANGING PV_ERROR.

  DATA: LT_ROWS    TYPE LVC_T_ROW,
        LS_ROWS    TYPE LVC_S_ROW,
        LT_E1CUVAL TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LV_VBELN   LIKE GT_LIPS-VBELN,
        LV_MATNR   TYPE MATNR_D,
        LV_FLAG.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL,
         LV_INT     TYPE I.

  DATA: LT_LIPS_40 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_LIPS_43 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_TEMP_43 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_LIPS_60 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.

  SORT GT_BOTTOM_RIGHT BY VBELN POSNR.
  SORT GT_BOTTOM_LEFT BY VBELN POSNR.
  SORT GT_AREA BY VBELN POSNR.
  SORT GT_0917 BY VBELN POSNR.

  " '60' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_60[].
  DELETE LT_LIPS_60 WHERE NOT SPART EQ 60.
  SORT LT_LIPS_60 BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS_60 COMPARING VBELN.

  " '43' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_43[].
  DELETE LT_LIPS_43 WHERE NOT SPART EQ 43.

  " '4'으로 시작하는 것 삭제
  LOOP AT LT_LIPS_43.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LT_LIPS_43-MATNR
      IMPORTING
        OUTPUT = LV_MATNR.

    IF  LV_MATNR(1) EQ '4'.
      DELETE LT_LIPS_43.
    ENDIF.

  ENDLOOP.

  MOVE GT_LIPS[] TO LT_TEMP_43[].
  DELETE LT_TEMP_43 WHERE NOT SPART EQ 43.

  " 배선자재는 '4'으로 시작할 경우 자재 품목을 하나만 표시한다.
  LOOP AT LT_TEMP_43.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LT_TEMP_43-MATNR
      IMPORTING
        OUTPUT = LV_MATNR.

    IF NOT LV_MATNR(1) EQ '4'.
      DELETE LT_TEMP_43.
    ENDIF.

  ENDLOOP.

  SORT LT_TEMP_43 BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP_43 COMPARING VBELN.

  APPEND LINES OF LT_TEMP_43[] TO LT_LIPS_43[].
  SORT LT_LIPS_43 BY VBELN POSNR.

  " '40' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_40[].
  DELETE LT_LIPS_40 WHERE NOT SPART EQ 40.
  SORT LT_LIPS_40 BY VBELN MATNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS_40 COMPARING VBELN MATNR.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    CHECK SY-SUBRC EQ 0.

    CASE GC_X.
        "  일반 출하
      WHEN P_RAD1 OR P_RAD2.
        " 삭제 대상은 제외
        CLEAR GT_0917.
        SELECT SINGLE VBELN
            INTO LV_VBELN
           FROM ZLET0917
         WHERE VBELN = GT_TOP_LEFT-VBELN
             AND XLOEK EQ ''.
        "  선적 시뮬레이션
      WHEN P_RAD3 OR P_RAD4.
        " 삭제 대상은 제외
        CLEAR GT_0917.
        SELECT SINGLE VBELN
            INTO LV_VBELN
           FROM ZLET0917
         WHERE VBELN = GT_TOP_LEFT-VBELN
             AND POSNR EQ GT_TOP_LEFT-POSNR
             AND XLOEK EQ ''.

    ENDCASE.

*{ 기능개선 167496 - 변경
*    CHECK sy-subrc <> 0.
    CHECK SY-SUBRC <> 0 OR SY-TCODE = GC_TCODE2.
*} 기능개선 167496 - 변경

    LOOP AT GT_LIPS WHERE VBELN EQ GT_TOP_LEFT-VBELN.
      CLEAR LV_INT.
      CLEAR GT_BOTTOM_RIGHT.
      READ TABLE GT_BOTTOM_RIGHT WITH KEY VBELN = GT_LIPS-VBELN
                                         POSNR = GT_LIPS-POSNR
                                 BINARY SEARCH.

      CHECK SY-SUBRC <> 0.

      CLEAR GT_BOTTOM_LEFT.
      READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                          POSNR = GT_LIPS-POSNR
                               BINARY SEARCH.

      CLEAR GT_TOP_LEFT.
      READ TABLE GT_TOP_LEFT WITH KEY VBELN = GT_LIPS-VBELN.

*      CASE gc_x.
*
*        WHEN p_rad1 OR p_rad2.
*          " 처음 생성인 경우 상세 품목은 '000001'.
*          MOVE '000001' TO gt_bottom_right-delidn.
*        WHEN p_rad3 OR p_rad4.
*
*          CHECK gt_top_left-posnr EQ gt_lips-posnr.
*          ADD 1 TO lv_int.
*          MOVE lv_int TO gt_bottom_right-delidn.
*      ENDCASE.

      MOVE ICON_LIGHT_OUT TO GT_BOTTOM_RIGHT-ICON.
      MOVE GT_LIPS-VBELN  TO GT_BOTTOM_RIGHT-VBELN.
      MOVE GT_LIPS-POSNR TO GT_BOTTOM_RIGHT-POSNR.
      MOVE GT_LIPS-SPART TO GT_BOTTOM_RIGHT-SPART.
      MOVE GT_LIPS-MATNR TO GT_BOTTOM_RIGHT-MATNR.
      MOVE GT_LIPS-ARKTX TO GT_BOTTOM_RIGHT-ARKTX.
      MOVE GT_LIPS-VGBEL TO GT_BOTTOM_RIGHT-VBELN_VL.
      MOVE GT_LIPS-VGPOS TO GT_BOTTOM_RIGHT-POSNR_VL.
      MOVE GT_TOP_LEFT-KUNNR TO GT_BOTTOM_RIGHT-KUNNR.
      MOVE GT_TOP_LEFT-NAME1 TO GT_BOTTOM_RIGHT-NAME1.


**** 필드추가 20170907 BY 서동우
      " 조장
      IF NOT GT_LIPS-VGBEL  IS INITIAL AND
         NOT GT_LIPS-VGPOS IS INITIAL.

        REFRESH GT_ET_CHAR.
        CLEAR : GV_ERROR, GV_ATWRT.
        " Z_LE_GET_CHARACTERISTIC_TABLE2
        PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
                                     USING GT_LIPS-VGBEL
                                           GT_LIPS-VGPOS
                                  CHANGING GV_ERROR.

      ENDIF.

      " 조장
      PERFORM READ_ET_CHAR USING 'SAP_LENGTH_VKRME'
                        CHANGING GV_ERROR
                                 GV_ATWRT.

      IF SY-SUBRC EQ 0.
        PERFORM CHANGE_STRING_REPLACE USING ','
                                   CHANGING GV_ATWRT.
        CONDENSE GV_ATWRT NO-GAPS.
        MOVE: GV_ATWRT TO GT_BOTTOM_RIGHT-LENGTH.
      ENDIF.

      " 납품수량
      MOVE: GT_LIPS-LFIMG TO GT_BOTTOM_LEFT-LFIMG.

      " 조장 수
      IF GT_LIPS-LFIMG <> 0 AND GT_BOTTOM_RIGHT-LENGTH <> 0.
        PERFORM CALCULATION_EXCEPTION_HANDING
          USING GT_LIPS-LFIMG
                '/'
                GT_BOTTOM_RIGHT-LENGTH
       CHANGING GT_BOTTOM_RIGHT-FACTOR.
      ENDIF.

      " 중량       " 중량단위
      SELECT SINGLE NTGEW GEWEI
          INTO (GT_BOTTOM_RIGHT-NTGEW, GT_BOTTOM_RIGHT-GEWEI)
        FROM MARA
       WHERE MATNR EQ GT_LIPS-MATNR.

*___납품문서의 총 순중량
      SELECT GEWEI
          SUM( NTGEW )
        INTO (GT_BOTTOM_RIGHT-GEWEI_LF, GT_BOTTOM_RIGHT-NTGEW_LF)
        FROM LIPS
       WHERE VBELN = GT_LIPS-VBELN
         AND ( POSNR = GT_LIPS-POSNR
          OR   UECHA = GT_LIPS-POSNR )
       GROUP BY GEWEI.
      ENDSELECT.

**** 필드추가 20170907 BY 서동우

      " 40 제품군은 납품문서, 자재코드, 품목번호가
      " 제일 빠른 한건만 생성한다.
      IF GT_LIPS-SPART EQ 40.

        CLEAR LT_LIPS_40.
        READ TABLE LT_LIPS_40 WITH KEY VBELN = GT_LIPS-VBELN
                                        MATNR = GT_LIPS-MATNR
                                        POSNR = GT_LIPS-POSNR
                              BINARY SEARCH.

        CHECK SY-SUBRC EQ 0.

      ENDIF.

      " 60 제품군은 납품문서, 품목번호가
      " 제일 빠른 한건만 생성한다.
      IF GT_LIPS-SPART EQ 60.

        CLEAR LT_LIPS_60.
        READ TABLE LT_LIPS_60 WITH KEY VBELN = GT_LIPS-VBELN
                                        POSNR = GT_LIPS-POSNR
                              BINARY SEARCH.

        CHECK SY-SUBRC EQ 0.

      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = GT_LIPS-MATNR
        IMPORTING
          OUTPUT = LV_MATNR.

      CLEAR LV_FLAG.
      IF LV_MATNR(1) EQ '4'.
        LV_FLAG = GC_X.
      ENDIF.

      " 43 제품군은 납품문서, 품목번호가
      " 제일 빠른 한건만 생성한다.
      IF GT_LIPS-SPART EQ 43 AND LV_FLAG EQ GC_X.

        CLEAR LT_LIPS_43.
        READ TABLE LT_LIPS_43 WITH KEY VBELN = GT_LIPS-VBELN
                                       POSNR = GT_LIPS-POSNR
                              BINARY SEARCH.

        CHECK SY-SUBRC EQ 0.

      ENDIF.

      " 제품군 32
      " 포장재 정보를 찾은 경우
      IF GT_LIPS-SPART EQ 32.

        CLEAR GT_AREA.
        LOOP AT GT_AREA WHERE VBELN = GT_LIPS-VBELN
                                           AND POSNR = GT_LIPS-POSNR.

*      CHECK sy-subrc EQ 0.
          ADD 1 TO LV_INT.
          MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
          MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP,  " 포장재 유형
               GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 포장재 코드
               GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR," 드럼 코드
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE,  " 최초수량
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 포장재 수량
               'EA'            TO GT_BOTTOM_RIGHT-ZMEINS,  " 포장재단위
               GT_AREA-WIDTH   TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
               GT_AREA-ZLENGTH TO GT_BOTTOM_RIGHT-ZLENGTH,  " 길이
               GT_AREA-HEIGHT  TO GT_BOTTOM_RIGHT-HEIGHT,  " 넓이
               GT_AREA-PKWEI   TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
               'KG'             TO GT_BOTTOM_RIGHT-PMEINS, " 단위
               GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
               GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.

          " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND NOT
* gt_bottom_right-pktyp IS INITIAL.
          REFRESH GT_BOTTOM_RIGHT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

          GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
          = GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].

          APPEND GT_BOTTOM_RIGHT.

        ENDLOOP.

        " 포장재 정보를 찾지 못한 경우
        IF SY-SUBRC <> 0.

          ADD 1 TO LV_INT.
          MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.

          MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP, " 포장재 타입
               GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 포장재 코드
               GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR," 드럼 코드
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE," 최초 수량
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 포장재수량
               'EA'             TO GT_BOTTOM_RIGHT-ZMEINS,  " 단위
               GT_AREA-WIDTH    TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
               GT_AREA-ZLENGTH  TO GT_BOTTOM_RIGHT-ZLENGTH,  " 길이
               GT_AREA-HEIGHT    TO GT_BOTTOM_RIGHT-HEIGHT,  " 높이
               GT_AREA-PKWEI     TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
               GT_AREA-PMEINS TO GT_BOTTOM_RIGHT-PMEINS,  " 무게 단위
               GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
               GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.

          " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL
* AND NOT gt_bottom_right-pktyp IS INITIAL.
          REFRESH GT_BOTTOM_RIGHT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          CLEAR GT_BOTTOM_RIGHT-PUSH.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PUSH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'WIDTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKWEI' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

          GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
          = GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].

          APPEND GT_BOTTOM_RIGHT. CLEAR GT_BOTTOM_RIGHT.

        ENDIF.

      ELSE.

        CLEAR GT_AREA.
        READ TABLE GT_AREA WITH KEY VBELN = GT_LIPS-VBELN
                                    POSNR = GT_LIPS-POSNR
                          BINARY SEARCH.
        " 포장재 정보가 있는 경우
        IF SY-SUBRC EQ 0.
          ADD 1 TO LV_INT.
          MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
          MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP,  " 포장재 타입
               GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR, " 포장재 코드
               GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR, " 드럼 코드
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE,  " 최초수량
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,   " 수량
               'EA'             TO GT_BOTTOM_RIGHT-ZMEINS,  " 단위
               GT_AREA-WIDTH     TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
               GT_AREA-ZLENGTH  TO GT_BOTTOM_RIGHT-ZLENGTH,  " 길이
               GT_AREA-HEIGHT    TO GT_BOTTOM_RIGHT-HEIGHT,  " 높이
               GT_AREA-PKWEI     TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
               GT_AREA-PMEINS     TO GT_BOTTOM_RIGHT-PMEINS,  " 단위
               GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
               GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.

          " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
* NOT gt_bottom_right-pktyp IS INITIAL.
          REFRESH GT_BOTTOM_RIGHT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
          = GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].
*      ENDIF.
          " 포장재 정보가 없는 경우
        ELSE.

          ADD 1 TO LV_INT.
          MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
          MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP," 포장재타입
               GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 포장재코드
               GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR, " 드럼 코드
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE, " 최초수량
               GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 수량
               'EA'            TO GT_BOTTOM_RIGHT-ZMEINS, "단위
               GT_AREA-WIDTH   TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
               GT_AREA-ZLENGTH TO GT_BOTTOM_RIGHT-ZLENGTH,  " 길이
               GT_AREA-HEIGHT  TO GT_BOTTOM_RIGHT-HEIGHT,  " 높이
               GT_AREA-PKWEI   TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
                 'KG'          TO GT_BOTTOM_RIGHT-PMEINS, " 단위
               GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
               GT_AREA-KEY_TEXT       TO GT_BOTTOM_RIGHT-KEY_TEXT.
          " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
*NOT gt_bottom_right-pktyp IS INITIAL.
          REFRESH GT_BOTTOM_RIGHT-CELLTAB.

          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          CLEAR GT_BOTTOM_RIGHT-PUSH.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'PUSH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'WIDTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
          PERFORM MODIFY_CELL_ATTRIBUTE
          USING GC_EDIT 'PKWEI' CHANGING LT_CELLTAB.
          INSERT LINES OF LT_CELLTAB
          INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

        ENDIF.

        APPEND GT_BOTTOM_RIGHT. CLEAR  GT_BOTTOM_RIGHT.

      ENDIF.

    ENDLOOP.

    SORT GT_BOTTOM_RIGHT BY VBELN POSNR.

  ENDLOOP.

ENDFORM.                    " CREATE_BOTTOM_RIGHT
*&---------------------------------------------------------------------*
*&      Form  CREATE_BOTTOM_RIGHT_Two
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ROWS  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM CREATE_BOTTOM_RIGHT_TWO  USING PT_ROWS TYPE LVC_T_ROW
                                              CHANGING PV_ERROR.

  DATA: LT_ROWS    TYPE LVC_T_ROW,
        LS_ROWS    TYPE LVC_S_ROW,
        LT_E1CUVAL TYPE E1CUVAL OCCURS 0 WITH HEADER LINE,
        LT_LIPS    LIKE GT_LIPS OCCURS 0 WITH HEADER LINE,
        LV_VBELN   LIKE GT_LIPS-VBELN,
        LT_TOP     LIKE GT_TOP_LEFT OCCURS 0 WITH HEADER LINE,
        LT_BOTTOM  LIKE GT_BOTTOM_RIGHT OCCURS 0 WITH HEADER LINE,
        LV_MATNR   TYPE MATNR_D,
        LV_FLAG.

*___각 Cell의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         LT_COLOR   TYPE LVC_T_SCOL,
         LV_INT     TYPE I.

  DATA: LT_LIPS_40 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_LIPS_43 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_TEMP_43 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: LT_LIPS_60 LIKE GT_LIPS OCCURS 0 WITH HEADER LINE.

  SORT GT_BOTTOM_RIGHT BY VBELN POSNR.
  SORT GT_BOTTOM_LEFT BY VBELN POSNR.
  SORT GT_AREA BY VBELN POSNR.
  SORT GT_0917 BY VBELN POSNR.

  " '60' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_60[].
  DELETE LT_LIPS_60 WHERE NOT SPART EQ 60.
  SORT LT_LIPS_60 BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS_60 COMPARING VBELN.

  " '43' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_43[].
  DELETE LT_LIPS_43 WHERE NOT SPART EQ 43.

  LOOP AT LT_LIPS_43.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LT_LIPS_43-MATNR
      IMPORTING
        OUTPUT = LV_MATNR.

    IF  LV_MATNR(1) EQ '4'.
      DELETE LT_LIPS_43.
    ENDIF.

  ENDLOOP.

  MOVE GT_LIPS[] TO LT_TEMP_43[].
  DELETE LT_TEMP_43 WHERE NOT SPART EQ 43.

  " 배선자재는 '4'으로 시작할 경우 자재 품목을 하나만 표시한다.
  LOOP AT LT_TEMP_43.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LT_TEMP_43-MATNR
      IMPORTING
        OUTPUT = LV_MATNR.

    IF NOT LV_MATNR(1) EQ '4'.
      DELETE LT_TEMP_43.
    ENDIF.

  ENDLOOP.

  SORT LT_TEMP_43 BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP_43 COMPARING VBELN.

  APPEND LINES OF LT_TEMP_43[] TO LT_LIPS_43[].
  SORT LT_LIPS_43 BY VBELN POSNR.

  " '40' 제품군 체크용
  MOVE GT_LIPS[] TO LT_LIPS_40[].
  DELETE LT_LIPS_40 WHERE NOT SPART EQ 40.
  SORT LT_LIPS_40 BY VBELN MATNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIPS_40 COMPARING VBELN MATNR.

  LOOP AT PT_ROWS INTO LS_ROWS.

    CLEAR GT_TOP_LEFT.
    READ TABLE GT_TOP_LEFT INDEX LS_ROWS-INDEX.

    MOVE GT_TOP_LEFT-SHSRQ TO LT_TOP-SHSRQ.
    APPEND LT_TOP.
  ENDLOOP.

  SORT LT_TOP BY SHSRQ.
  DELETE ADJACENT DUPLICATES FROM LT_TOP COMPARING SHSRQ.

  LOOP AT LT_TOP.

    LOOP AT GT_TOP_LEFT WHERE SHSRQ EQ LT_TOP-SHSRQ.

      CLEAR GT_0917.
      SELECT SINGLE VBELN
          INTO LV_VBELN
         FROM ZLET0917
       WHERE VBELN = GT_TOP_LEFT-VBELN
           AND POSNR EQ GT_TOP_LEFT-POSNR
           AND XLOEK EQ ''.

      CHECK SY-SUBRC <> 0.

      LOOP AT GT_LIPS WHERE VBELN EQ GT_TOP_LEFT-VBELN.
        CLEAR LV_INT.
        CLEAR GT_BOTTOM_RIGHT.
        READ TABLE GT_BOTTOM_RIGHT WITH KEY VBELN = GT_LIPS-VBELN
                                             POSNR = GT_LIPS-POSNR
                                  BINARY SEARCH.

        CHECK SY-SUBRC <> 0.

        CLEAR GT_BOTTOM_LEFT.
        READ TABLE GT_BOTTOM_LEFT WITH KEY VBELN = GT_LIPS-VBELN
                                          POSNR = GT_LIPS-POSNR
                                 BINARY SEARCH.

        CHECK GT_TOP_LEFT-POSNR EQ GT_LIPS-POSNR.

        MOVE ICON_LIGHT_OUT TO GT_BOTTOM_RIGHT-ICON.
        MOVE GT_TOP_LEFT-SHSRQ TO GT_BOTTOM_RIGHT-SHSRQ.
        MOVE GT_LIPS-VBELN  TO GT_BOTTOM_RIGHT-VBELN.
        MOVE GT_LIPS-POSNR TO GT_BOTTOM_RIGHT-POSNR.
        MOVE GT_LIPS-SPART TO GT_BOTTOM_RIGHT-SPART.
        MOVE GT_LIPS-MATNR TO GT_BOTTOM_RIGHT-MATNR.
        MOVE GT_LIPS-ARKTX TO GT_BOTTOM_RIGHT-ARKTX.
        MOVE GT_LIPS-VGBEL TO GT_BOTTOM_RIGHT-VBELN_VL.
        MOVE GT_LIPS-VGPOS TO GT_BOTTOM_RIGHT-POSNR_VL.
        MOVE GT_TOP_LEFT-KUNNR TO GT_BOTTOM_RIGHT-KUNNR.
        MOVE GT_TOP_LEFT-NAME1 TO GT_BOTTOM_RIGHT-NAME1.

        " 40 제품군은 납품문서, 자재코드, 품목번호가
        " 제일 빠른  한건만 생성한다.
        IF GT_LIPS-SPART EQ 40.

          CLEAR LT_LIPS_40.
          READ TABLE LT_LIPS_40 WITH KEY VBELN = GT_LIPS-VBELN
                                        MATNR = GT_LIPS-MATNR
                                        POSNR = GT_LIPS-POSNR
                                BINARY SEARCH.

          CHECK SY-SUBRC EQ 0.

        ENDIF.

        " 43 제품군은 납품문서, 품목번호가
        " 제일 빠른 한건만 생성한다.
        IF GT_LIPS-SPART EQ 43 AND LV_FLAG EQ GC_X.

          CLEAR LT_LIPS_43.
          READ TABLE LT_LIPS_43 WITH KEY VBELN = GT_LIPS-VBELN
                                         POSNR = GT_LIPS-POSNR
                                BINARY SEARCH.

          CHECK SY-SUBRC EQ 0.

*        CLEAR gt_area.
*        READ TABLE gt_area WITH KEY vbeln = gt_lips-vbeln
*                                    posnr = gt_lips-posnr
*                           BINARY SEARCH.
*
*        " 43-A에서 데이타 찾은 경우만 제일 빠른 한건만 생성한다.
*        IF gt_area-code_point EQ '43-A'.
*          CHECK sy-subrc EQ 0.
*        ELSE.
*
*        ENDIF.

        ENDIF.


        " 포장재 정보가 없으면 구성하지 않는다.
        IF GT_LIPS-SPART EQ 32.
          " 포장재 정보가 있는 경우
          CLEAR GT_AREA.
          LOOP AT GT_AREA WHERE VBELN = GT_LIPS-VBELN
                           AND POSNR = GT_LIPS-POSNR.

*      CHECK sy-subrc EQ 0.
            ADD 1 TO LV_INT.
            MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
            MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP," 포장재타입
                 GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 자재코드
                 GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR," 드럼 코드
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE," 최초수량
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 수량
                 'EA'             TO GT_BOTTOM_RIGHT-ZMEINS, " 단위
                 GT_AREA-WIDTH    TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
                 GT_AREA-ZLENGTH  TO GT_BOTTOM_RIGHT-ZLENGTH," 길이
                 GT_AREA-HEIGHT    TO GT_BOTTOM_RIGHT-HEIGHT," 높이
                 GT_AREA-PKWEI     TO GT_BOTTOM_RIGHT-PKWEI, " 무게
                 GT_AREA-PMEINS TO GT_BOTTOM_RIGHT-PMEINS,  " 무게단위
                 GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
                 GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.

            " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
* NOT gt_bottom_right-pktyp IS INITIAL.
            REFRESH GT_BOTTOM_RIGHT-CELLTAB.

            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

            GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
            = GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].

            APPEND GT_BOTTOM_RIGHT.
            " 헤던 선언 부분이 있어서 Clear 하지 않는다.
            " CLEAR gt_bottom_right.

          ENDLOOP.
          " 포장재 정보가 없는 경우
          IF SY-SUBRC <> 0.

            ADD 1 TO LV_INT.
            MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.

            MOVE: GT_AREA-PKTYP TO GT_BOTTOM_RIGHT-PKTYP,  " 포장재타입
                 GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 자재코드
                 GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR," 드럼 코드
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE," 최초수량
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 수량
                 'EA'            TO GT_BOTTOM_RIGHT-ZMEINS, " 단위
                 GT_AREA-WIDTH   TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
                 GT_AREA-ZLENGTH TO GT_BOTTOM_RIGHT-ZLENGTH," 길이
                 GT_AREA-HEIGHT  TO GT_BOTTOM_RIGHT-HEIGHT, " 높이
                 GT_AREA-PKWEI   TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
                 'KG'            TO GT_BOTTOM_RIGHT-PMEINS, " 단위
                 GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
                 GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.

            " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
*NOT gt_bottom_right-pktyp IS INITIAL.
            REFRESH GT_BOTTOM_RIGHT-CELLTAB.

            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            CLEAR GT_BOTTOM_RIGHT-PUSH.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PUSH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'WIDTH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKWEI' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

            GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[]
            = GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].

            APPEND GT_BOTTOM_RIGHT.
            " 헤던 선언 부분이 있어서 Clear 하지 않는다.
            " CLEAR gt_bottom_right.
          ENDIF.

        ELSE.
          " 포장재 정보가 있는 경우
          CLEAR GT_AREA.
          READ TABLE GT_AREA WITH KEY VBELN = GT_LIPS-VBELN
                                              POSNR = GT_LIPS-POSNR
                            BINARY SEARCH.

          IF SY-SUBRC EQ 0.

            ADD 1 TO LV_INT.
            MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
            MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP, " 포장재타입
                 GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR," 자재코드
                 GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR," 드럼 코드
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE," 최초수량
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  " 수량
                 'EA'            TO GT_BOTTOM_RIGHT-ZMEINS, " 단위
                 GT_AREA-WIDTH   TO GT_BOTTOM_RIGHT-WIDTH,  " 폭
                 GT_AREA-ZLENGTH TO GT_BOTTOM_RIGHT-ZLENGTH, " 길이
                 GT_AREA-HEIGHT  TO GT_BOTTOM_RIGHT-HEIGHT,  " 높이
                 GT_AREA-PKWEI   TO GT_BOTTOM_RIGHT-PKWEI,  " 무게
                 GT_AREA-PMEINS  TO GT_BOTTOM_RIGHT-PMEINS,  " 단위
                 GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
                 GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.
            " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
* NOT gt_bottom_right-pktyp IS INITIAL.
            REFRESH GT_BOTTOM_RIGHT-CELLTAB.

            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PKTYP' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            MOVE ICON_CHANGE TO GT_BOTTOM_RIGHT-PUSH.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PUSH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            GT_BOTTOM_RIGHT-CELLTAB[] = GT_BOTTOM_LEFT-CELLTAB[] =
            GT_TOP_LEFT-CELLTAB[] = GT_BOTTOM_RIGHT-CELLTAB[].
*      ENDIF.
            " 포장재 정보가 없는 경우
          ELSE.

            ADD 1 TO LV_INT.
            MOVE LV_INT TO GT_BOTTOM_RIGHT-DELIDN.
            MOVE: GT_AREA-PKTYP  TO GT_BOTTOM_RIGHT-PKTYP,  "포장재타입
                 GT_AREA-PKMATNR TO GT_BOTTOM_RIGHT-PKMATNR,"자재코드
                 GT_AREA-DMMATNR TO GT_BOTTOM_RIGHT-DMMATNR,"드럼코드
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-INMENGE,"최초수량
                 GT_AREA-MENGE   TO GT_BOTTOM_RIGHT-MENGE,  "수량
                 'EA'            TO GT_BOTTOM_RIGHT-ZMEINS, "단위
                 GT_AREA-WIDTH   TO GT_BOTTOM_RIGHT-WIDTH,  "폭
                 GT_AREA-ZLENGTH TO GT_BOTTOM_RIGHT-ZLENGTH,"길이
                 GT_AREA-HEIGHT  TO GT_BOTTOM_RIGHT-HEIGHT, "높이
                 GT_AREA-PKWEI   TO GT_BOTTOM_RIGHT-PKWEI,  "무게
                 'KG'               TO GT_BOTTOM_RIGHT-PMEINS,"단위
                 GT_AREA-CODE_POINT TO GT_BOTTOM_RIGHT-CODE_POINT,
                 GT_AREA-KEY_TEXT   TO GT_BOTTOM_RIGHT-KEY_TEXT.
            " 포장재 타입과 자재코드가 있으면 입력 불가
*      IF NOT gt_bottom_right-pkmatnr IS INITIAL AND
* NOT gt_bottom_right-pktyp IS INITIAL.
            REFRESH GT_BOTTOM_RIGHT-CELLTAB.

            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKMATNR' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKTYP' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            CLEAR GT_BOTTOM_RIGHT-PUSH.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'PUSH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_NO_EDIT 'MENGE' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'WIDTH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'ZLENGTH' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'HEIGHT' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.
            PERFORM MODIFY_CELL_ATTRIBUTE
            USING GC_EDIT 'PKWEI' CHANGING LT_CELLTAB.
            INSERT LINES OF LT_CELLTAB
            INTO TABLE GT_BOTTOM_RIGHT-CELLTAB.

          ENDIF.
          APPEND GT_BOTTOM_RIGHT.
          " 헤던 선언 부분이 있어서 Clear 하지 않는다.
          " CLEAR gt_bottom_right.
        ENDIF.
      ENDLOOP.

      SORT GT_BOTTOM_RIGHT BY VBELN POSNR.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " CREATE_BOTTOM_RIGHT_Two
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  CASE GC_X.
      " 일반 납품문서 화면 제어
    WHEN P_RAD1 OR P_RAD2.
      LOOP AT SCREEN.
        IF SCREEN-NAME = '%_S_SHSRQ_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_SHSRQ-LOW'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_SHSRQ-HIGH'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-VALU_PUSH'.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

      IF P_RAD2 EQ GC_X..
        LOOP AT SCREEN.
          IF SCREEN-NAME = 'P_CHK1'.
            SCREEN-INPUT = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        P_CHK1 = ''.

      ENDIF.
      " 컨테이너 시뮬레이션 화면 제어
    WHEN P_RAD3 OR P_RAD4.
      LOOP AT SCREEN.
        IF SCREEN-NAME = '%_S_WADAT_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_WADAT_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_WADAT-LOW'
        OR SCREEN-NAME = '%_S_WADAT_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_WADAT-HIGH'
        OR SCREEN-NAME = '%_S_WADAT_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_ERDAT_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_ERDAT_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_ERDAT-LOW'
        OR SCREEN-NAME = '%_S_ERDAT_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_ERDAT-HIGH'
        OR SCREEN-NAME = '%_S_ERDAT_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_VBELN_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_VBELN_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_VBELN-LOW'
        OR SCREEN-NAME = '%_S_VBELN_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_VBELN-HIGH'
        OR SCREEN-NAME = '%_S_VBELN_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_KUNNR_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_KUNNR_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_KUNNR-LOW'
        OR SCREEN-NAME = '%_S_KUNNR_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_MATNR_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_MATNR_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_MATNR-LOW'
        OR SCREEN-NAME = '%_S_MATNR_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_MATNR-HIGH'
        OR SCREEN-NAME = '%_S_MATNR_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_DLVRQ_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_DLVRQ_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_DLVRQ-LOW'
        OR SCREEN-NAME = '%_S_DLVRQ_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_DLVRQ-HIGH'
        OR SCREEN-NAME = '%_S_DLVRQ_%_APP_%-VALU_PUSH'
        OR SCREEN-NAME = '%_S_VKORG_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_VKORG_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_VKORG-LOW'
        OR SCREEN-NAME = '%_S_VTWEG_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_VTWEG_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_VTWEG-LOW'
        OR SCREEN-NAME = '%_S_VTWEG_%_APP_%-VALU_PUSH'.
          SCREEN-ACTIVE = 0.
        ELSEIF SCREEN-NAME = '%_S_SHSRQ_%_APP_%-TEXT'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-OPTI_PUSH'
        OR SCREEN-NAME = 'S_SHSRQ-LOW'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-TO_TEXT'
        OR SCREEN-NAME = 'S_SHSRQ-HIGH'
        OR SCREEN-NAME = '%_S_SHSRQ_%_APP_%-VALU_PUSH'.
          SCREEN-ACTIVE = 1.
        ENDIF.

        MODIFY SCREEN.
      ENDLOOP.

      " 저장된 상태만 조회
      IF P_RAD4 EQ GC_X..
        LOOP AT SCREEN.
          IF SCREEN-NAME = 'P_CHK1'.
            SCREEN-INPUT = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        P_CHK1 = ''.

      ENDIF.

  ENDCASE.

  LOOP AT SCREEN.
    IF P_RAD2 <> 'X' AND SCREEN-GROUP1 = 'M11'.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.

*{ 기능개선 163582 - 추가
    IF SY-TCODE = GC_TCODE2 AND SCREEN-GROUP1 = 'M21'.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.
*} 기능개선 163582 - 추가

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  HANDLE_SCREEN_SIZE_HEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_35     text
*----------------------------------------------------------------------*
FORM HANDLE_SCREEN_SIZE_HEIGHT  USING  PV_VALUE.

  CALL METHOD SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = PV_VALUE.


ENDFORM.                    " HANDLE_SCREEN_SIZE_HEIGHT
*&---------------------------------------------------------------------*
*&      Form  HANDLE_SCREEN_SIZE_WIDTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_35     text
*----------------------------------------------------------------------*
FORM HANDLE_SCREEN_SIZE_WIDTH  USING PV_VALUE.

  CALL METHOD SPLITTER->SET_COLUMN_WIDTH
    EXPORTING
      ID    = 1
      WIDTH = PV_VALUE.

ENDFORM.                    " HANDLE_SCREEN_SIZE_WIDTH
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_OTHERS_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_OTHERS_INFO .

  DATA: LV_MENGE   TYPE MENGE_D,
        LT_BOTTOM  LIKE GT_BOTTOM_LEFT OCCURS 0 WITH HEADER LINE,
        LV_LENG    TYPE EKPO-MENGE,
        LV_ZLENGTH LIKE EKPO-MENGE.

  MOVE GT_BOTTOM_LEFT[] TO LT_BOTTOM[].

  SORT GT_TOP_LEFT BY VBELN POSNR.
  SORT LT_BOTTOM BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_BOTTOM COMPARING VBELN POSNR.

  SORT GT_LIPS BY VBELN POSNR.
  SORT GT_AREA BY VBELN POSNR.

  CLEAR GT_TOP_LEFT.
  LOOP AT LT_BOTTOM WHERE SPART EQ 30.

    CLEAR GT_AREA.
    READ TABLE GT_AREA WITH KEY VBELN = LT_BOTTOM-VBELN
                                 POSNR = LT_BOTTOM-POSNR
                        BINARY SEARCH.

    CLEAR: GT_LIPS, LV_MENGE.
    READ TABLE GT_LIPS WITH KEY VBELN = LT_BOTTOM-VBELN
                               POSNR = LT_BOTTOM-POSNR
                      BINARY SEARCH.
    IF SY-SUBRC EQ 0.

      REFRESH GT_ET_CHAR. CLEAR GV_ERROR.
      " Z_LE_GET_CHARACTERISTIC_TABLE2
      PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
      USING GT_LIPS-VGBEL GT_LIPS-VGPOS CHANGING GV_ERROR.

      " 조장
      PERFORM READ_ET_CHAR
      USING 'SAP_MILLCA_LENGTH' CHANGING GV_ERROR GV_ATWRT.

      " 쉼표 제외
      IF NOT GV_ATWRT IS INITIAL.
        PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING GV_ATWRT.
        CONDENSE GV_ATWRT NO-GAPS.
        MOVE GV_ATWRT TO LV_MENGE.
      ENDIF.

      PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_LIPS-NTGEW '*' LV_MENGE CHANGING LV_MENGE.

    ENDIF.

    LV_LENG =  GT_AREA-ZLENGTH.

    ADD GT_AREA-PKWEI TO LV_MENGE.

    " 단위 변환
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        I_MATNR              = GT_LIPS-MATNR
        I_IN_ME              = 'CM'
        I_OUT_ME             = 'MM'
        I_MENGE              = LV_LENG
      IMPORTING
        E_MENGE              = LV_ZLENGTH
      EXCEPTIONS
        ERROR_IN_APPLICATION = 1
        ERROR                = 2
        OTHERS               = 3.

    " 톤수제한 부여
    IF LV_ZLENGTH < 3600 AND LV_MENGE < 25000.
      MOVE 'L35L' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF LV_ZLENGTH < 3600 AND LV_MENGE >= 25000.
      MOVE 'L35H' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF ( LV_ZLENGTH >= 3600 AND LV_ZLENGTH < 3900 )
    AND LV_MENGE < 25000.
      MOVE 'L38L' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF ( LV_ZLENGTH >= 3600 AND LV_ZLENGTH < 3900 )
    AND LV_MENGE >= 25000.
      MOVE 'L38H' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF ( LV_ZLENGTH >= 3900 AND LV_ZLENGTH < 4200 )
    AND LV_MENGE >= 25000.
      MOVE 'L41H' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF ( LV_ZLENGTH >= 3900 AND LV_ZLENGTH < 4200 )
    AND LV_MENGE < 25000.
      MOVE 'L41L' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF LV_ZLENGTH >= 4200 AND LV_MENGE >= 25000.
      MOVE 'L42H' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ELSEIF LV_ZLENGTH >= 4200 AND LV_MENGE < 25000.
      MOVE 'L42L' TO GT_TOP_LEFT-VHCTYP.
      MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
    ENDIF.

    CASE GC_X.
      WHEN P_RAD1.
        MODIFY GT_TOP_LEFT TRANSPORTING VHCTYP VHCINEQ
         WHERE VBELN EQ LT_BOTTOM-VBELN.
      WHEN P_RAD3.
        MODIFY GT_TOP_LEFT TRANSPORTING VHCTYP VHCINEQ
         WHERE VBELN EQ LT_BOTTOM-VBELN
              AND POSNR EQ LT_BOTTOM-POSNR.
    ENDCASE.
    CLEAR GT_TOP_LEFT.

  ENDLOOP.

ENDFORM.                    " MODIFY_SCREEN_OTHERS_INFO
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_OTHERS_INFO_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_OTHERS_INFO_TWO
  USING PV_INDEX
             PV_LENGTH
            PV_PKWEI.

  DATA: LV_MENGE   TYPE MENGE_D,
        LT_BOTTOM  LIKE GT_BOTTOM_LEFT OCCURS 0 WITH HEADER LINE,
        LV_LENG    TYPE EKPO-MENGE,
        LV_ZLENGTH LIKE EKPO-MENGE.

  READ TABLE GT_BOTTOM_RIGHT INDEX PV_INDEX.

*  SORT gt_top_left BY vbeln posnr.
*  SORT lt_bottom BY vbeln posnr.
*  DELETE ADJACENT DUPLICATES FROM lt_bottom COMPARING vbeln posnr.
*
*  SORT gt_lips BY vbeln posnr.
  SORT GT_AREA BY VBELN POSNR.
*
  CHECK GT_BOTTOM_RIGHT-SPART EQ 30.

  CLEAR GT_AREA.
  READ TABLE GT_AREA WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                               POSNR = GT_BOTTOM_RIGHT-POSNR
                      BINARY SEARCH.

  CLEAR: GT_LIPS, LV_MENGE.
  READ TABLE GT_LIPS WITH KEY VBELN = GT_BOTTOM_RIGHT-VBELN
                             POSNR = GT_BOTTOM_RIGHT-POSNR
                    BINARY SEARCH.

  IF SY-SUBRC EQ 0.

    REFRESH GT_ET_CHAR. CLEAR GV_ERROR.
    " Z_LE_GET_CHARACTERISTIC_TABLE2
    PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING GT_LIPS-VGBEL GT_LIPS-VGPOS CHANGING GV_ERROR.

    " 조장
    PERFORM READ_ET_CHAR
    USING 'SAP_MILLCA_LENGTH' CHANGING GV_ERROR GV_ATWRT.

    IF NOT GV_ATWRT IS INITIAL.
      PERFORM CHANGE_STRING_REPLACE USING ',' CHANGING GV_ATWRT.
      CONDENSE GV_ATWRT NO-GAPS.
      MOVE GV_ATWRT TO LV_MENGE.
    ENDIF.

    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-NTGEW '*' LV_MENGE CHANGING LV_MENGE.

  ENDIF.

  " 길이
  LV_LENG =  PV_LENGTH.

  "  무게
  LV_MENGE = LV_MENGE + PV_PKWEI.

  CHECK NOT LV_LENG IS INITIAL AND NOT LV_MENGE IS INITIAL.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = GT_LIPS-MATNR
      I_IN_ME              = 'CM'
      I_OUT_ME             = 'MM'
      I_MENGE              = LV_LENG
    IMPORTING
      E_MENGE              = LV_ZLENGTH
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

  " 톤수제한 부여
  IF LV_ZLENGTH < 3600 AND LV_MENGE < 25000.
    MOVE 'L35L' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF LV_ZLENGTH < 3600 AND LV_MENGE >= 25000.
    MOVE 'L35H' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF ( LV_ZLENGTH >= 3600 AND LV_ZLENGTH < 3900 )
  AND LV_MENGE < 25000.
    MOVE 'L38L' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF ( LV_ZLENGTH >= 3600 AND LV_ZLENGTH < 3900 )
  AND LV_MENGE >= 25000.
    MOVE 'L38H' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF ( LV_ZLENGTH >= 3900 AND LV_ZLENGTH < 4200 )
  AND LV_MENGE >= 25000.
    MOVE 'L41H' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF ( LV_ZLENGTH >= 3900 AND LV_ZLENGTH < 4200 )
  AND LV_MENGE < 25000.
    MOVE 'L41L' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF LV_ZLENGTH >= 4200 AND LV_MENGE >= 25000.
    MOVE 'L42H' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ELSEIF LV_ZLENGTH >= 4200 AND LV_MENGE < 25000.
    MOVE 'L42L' TO GT_TOP_LEFT-VHCTYP.
    MOVE 'VT' TO GT_TOP_LEFT-VHCINEQ.
  ENDIF.

  CASE GC_X.
    WHEN P_RAD1.
      MODIFY GT_TOP_LEFT TRANSPORTING VHCTYP VHCINEQ
       WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN.
    WHEN P_RAD3.
      MODIFY GT_TOP_LEFT TRANSPORTING VHCTYP VHCINEQ
       WHERE VBELN EQ GT_BOTTOM_RIGHT-VBELN
            AND POSNR EQ GT_BOTTOM_RIGHT-POSNR.
  ENDCASE.

  GV_REFRESH_FLAG = GC_X.

ENDFORM.                    " MODIFY_SCREEN_OTHERS_INFO_TWO
*&---------------------------------------------------------------------*
*&      Form  CHECK_STRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VOLTAG_ATWRT  text
*      <--P_LV_VOLTAG_ATWRT  text
*----------------------------------------------------------------------*
FORM CHECK_STRING  USING    PV_VOLTAG_ATWRT
                   CHANGING PV_ATWRT.

  DATA: STRING_1(20)     TYPE C, STRING_1_TYPE(4) TYPE C.

  MOVE PV_VOLTAG_ATWRT TO STRING_1.

  CALL FUNCTION 'NUMERIC_CHECK'
    EXPORTING
      STRING_IN = STRING_1
    IMPORTING
      HTYPE     = STRING_1_TYPE.

  IF STRING_1_TYPE EQ 'CHAR'.
    MOVE 12 TO PV_ATWRT.
  ELSEIF STRING_1_TYPE EQ 'NUMC'.

  ENDIF.

ENDFORM.                    " CHECK_STRING
*&---------------------------------------------------------------------*
*&      Form  CHECK_STRING_TWO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_CHAR  text
*      <--P_LV_TYPE  text
*----------------------------------------------------------------------*
FORM CHECK_STRING_TWO  USING    PV_CHAR
                       CHANGING PV_TYPE.

  DATA: STRING_1(20)     TYPE C, STRING_1_TYPE(4) TYPE C.

  MOVE PV_CHAR TO STRING_1.

  CALL FUNCTION 'NUMERIC_CHECK'
    EXPORTING
      STRING_IN = STRING_1
    IMPORTING
      HTYPE     = PV_TYPE.

ENDFORM.                    " CHECK_STRING_TWO
*&---------------------------------------------------------------------*
*&      Form  GET_ZEDT0210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_DR_GBN  text
*      -->P_LV_CA_NO  text
*      <--P_GV_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_ZEDT0210  USING    PV_DR_GBN
                            PV_CA_NO
                   CHANGING PV_SUBRC.

  DATA : LV_DRGBN LIKE ZEDT0210-DR_GBN,
         LV_SGGBN LIKE ZEDT0210-SG_GBN,
         LV_DRDET LIKE ZEDT0210-DRUM_DET.

  CLEAR : GT_0210, PV_SUBRC.

  DO 9 TIMES.
*___ZEDT0210 찾는 순서(드럼구분 판매구분 드럼상세)
*   1. G D E
*   2. G E E
*   3. L D E
*   4. L E E
*   5. G D S
*   6. G E S
*   7. L E S
*   8. L D S
*   9. G H S

*___드럼구분
    CASE SY-INDEX.
      WHEN 1 OR 2 OR 5 OR 6 OR 9.
        LV_DRGBN = 'G'.
      WHEN OTHERS.
        LV_DRGBN = 'L'.
    ENDCASE.

*___판매구분
    CASE SY-INDEX.
      WHEN 1 OR 3 OR 5 OR 8.
        LV_SGGBN = 'D'.
      WHEN 2 OR 4 OR 6 OR 7.
        LV_SGGBN = 'E'.
      WHEN OTHERS.
        LV_SGGBN = 'H'.
    ENDCASE.

*___드럼상세
    CASE SY-INDEX.
      WHEN 1 OR 2 OR 3 OR 4.
        LV_DRDET = 'E'.
      WHEN OTHERS.
        LV_DRDET = 'S'.
    ENDCASE.

    READ TABLE GT_0210 WITH KEY DR_GBN   = LV_DRGBN
                                SG_GBN   = LV_SGGBN
                                DRUM_DET = LV_DRDET
                                DRUM_NO  = PV_CA_NO
                                BINARY SEARCH.

    IF SY-SUBRC = 0.
      RETURN.
    ENDIF.
  ENDDO.

*___위에서 찾지 못한 경우 드럼기호만으로 검색
  READ TABLE GT_0210 WITH KEY DRUM_NO = PV_CA_NO.

  CHECK SY-SUBRC <> 0.

  MOVE 8 TO PV_SUBRC.

ENDFORM.                    " GET_ZEDT0210
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_20_SPLIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*      -->P_PV_SPART  text
*      -->P_PV_VGBEL  text
*      -->P_PV_VGPOS  text
*      -->P_PV_MATNR  text
*      -->P_PV_KUNNR  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_20_SPLIT  USING  PV_VBELN
                                PV_POSNR
                                PV_VGBEL
                                PV_VGPOS
                                PV_SPART
                                PV_MATNR
                       CHANGING PV_ERROR.

  DATA: LS_0002              LIKE ZLET0002,
        LV_WD_THK            LIKE GT_0210-PK_WD_THK,
        LV_SAP_MILLCA_LENGTH TYPE ATWRT,
        LV_MENGE             TYPE MENGE_D.

  CLEAR : PV_ERROR.

*___ZLET0002 납품절단 테이블
  SELECT SINGLE *
    INTO LS_0002
    FROM ZLET0002
   WHERE VBELN  EQ PV_VBELN
     AND UECHA  EQ PV_POSNR
     AND MATNR  EQ PV_MATNR
     AND FLAG_D EQ ' '.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SORT GT_0210 BY DR_GBN SG_GBN DRUM_DET DRUM_NO.

*___드럼 구분, 판매 구분 ,드럼 상세 코드 적용 순서
  CLEAR GV_SUBRC.
  PERFORM GET_ZEDT0210 USING ' '
                             LS_0002-DR_NO
                    CHANGING GV_SUBRC.

  IF GV_SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  CLEAR PV_ERROR.

  REFRESH GT_ET_CHAR.

*___S/O  특성
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
                               USING PV_VGBEL
                                     PV_VGPOS
                            CHANGING PV_ERROR.

  GT_AREA-PMEINS  = 'KG'.
  GT_AREA-PKTYP   = 'DM'.
  GT_AREA-DMMATNR = LS_0002-DR_NO.
*    APPEND gt_area. CLEAR gt_area.

  CLEAR PV_ERROR.          "   lv_sap_millca_factor TYPE atwrt.
  PERFORM READ_ET_CHAR USING 'SAP_MILLCA_LENGTH'
                    CHANGING PV_ERROR
                             LV_SAP_MILLCA_LENGTH.

*___포장재 수량
*  IF NOT lv_sap_millca_length IS INITIAL.
*    PERFORM change_string_replace
*    USING ',' CHANGING lv_sap_millca_length.
*    CONDENSE lv_sap_millca_length NO-GAPS.
*    MOVE lv_sap_millca_length TO lv_menge.
*  ENDIF.

  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

*___납품수량 / 조장
  IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_LIPS-LFIMG
                                                '/'
                                                LV_MENGE
                                       CHANGING GT_AREA-MENGE.
  ENDIF.

  MOVE GT_0210-OUT_WID TO GT_AREA-WIDTH.
*    MOVE gt_0210-plan_dia TO gt_area-zlength.
*    MOVE gt_0210-plan_dia TO gt_area-height.

  IF NOT GT_0210-PK_WD_THK IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_0210-PK_WD_THK
                                                '*'
                                                2
                                       CHANGING LV_WD_THK.
  ENDIF.

  GT_AREA-HEIGHT = GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_WD_THK.

*___포장재 무게
  GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.

*___mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_AREA-WIDTH
                                                '/'
                                                10
                                       CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_AREA-ZLENGTH
                                                '/'
                                                10
                                       CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING USING GT_AREA-HEIGHT
                                                '/'
                                                10
                                       CHANGING GT_AREA-HEIGHT.
  ENDIF.

ENDFORM.                    " GET_SPART_20_SPLIT
*&---------------------------------------------------------------------*
*&      Form  GET_SPART_20_STOCK_SPLIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*      -->P_PV_SPART  text
*      -->P_PV_MATNR  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SPART_20_STOCK_SPLIT  USING  PV_VBELN
                            PV_POSNR
                            PV_VGBEL
                            PV_VGPOS
                            PV_SPART
                            PV_MATNR
                            PV_CHARG
                            PV_WERKS
           CHANGING PV_ERROR.

  DATA: LT_API_VALI             LIKE API_VALI  OCCURS 0 WITH HEADER LINE,
        LT_API_CHAR             LIKE API_CHAR  OCCURS 0 WITH HEADER LINE,
        LV_CA_NO                TYPE AUSP-OBJEK,
        LV_SAP_MILLCA_PACKAGING TYPE ATWRT,
        LV_WD_THK               LIKE GT_0210-PK_WD_THK,
        LV_SAP_MILLCA_LENGTH    TYPE ATWRT,
        LV_MENGE                TYPE MENGE_D.

  IF PV_CHARG IS INITIAL.

    " 배치번호가 없는 경우
    PERFORM GET_CHARG USING PV_VBELN PV_POSNR
          CHANGING PV_CHARG PV_ERROR.
    IF NOT PV_ERROR IS INITIAL.
      MOVE GC_X TO PV_ERROR.
      RETURN.
    ENDIF.
  ENDIF.

* 입고자재에 대한 특성내역을 가져온다.
  REFRESH: LT_API_VALI, LT_API_CHAR.
  CLEAR  : LT_API_VALI, LT_API_CHAR.

  "  배치 특성 찾음.
  PERFORM READ_BATCH_ATTR TABLES LT_API_VALI LT_API_CHAR
    USING PV_MATNR PV_WERKS PV_CHARG.

  "  배치 특성 SAP_MILLCA_PACKAGING 찾음.
  PERFORM READ_CHARG_ATTR TABLES LT_API_VALI LT_API_CHAR
    USING 'SAP_MILLCA_PACKAGING'
    CHANGING PV_ERROR LV_SAP_MILLCA_PACKAGING.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.

  " 자재특성 값을 가져온다.
  REFRESH GT_OBJECT.
  PERFORM GET_MATERIAL_CHARACT TABLES GT_OBJECT
     USING LV_SAP_MILLCA_PACKAGING.

  " RL_CA_NO(드럼기호)
  CLEAR: LV_CA_NO, PV_ERROR.
  PERFORM READ_MATNR_CHARACT TABLES GT_OBJECT
  USING 'RL_CA_NO' CHANGING PV_ERROR LV_CA_NO.

  IF NOT PV_ERROR IS INITIAL.
    RETURN.
  ENDIF.


  SORT GT_0210 BY DR_GBN SG_GBN DRUM_DET DRUM_NO.

  " 드럼 구분, 판매 구분 ,드럼 상세 코드 적용 순서
  CLEAR GV_SUBRC.
  PERFORM GET_ZEDT0210 USING ' ' LV_CA_NO CHANGING GV_SUBRC.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  "  S/O  특성
  PERFORM GET_SALES_CHARACTER TABLES GT_ET_CHAR
    USING PV_VGBEL PV_VGPOS CHANGING PV_ERROR.

  CLEAR PV_ERROR.

  GT_AREA-PMEINS = 'KG'.
  GT_AREA-PKTYP = 'DM'.
  GT_AREA-DMMATNR = LV_CA_NO.
*    APPEND gt_area. CLEAR gt_area.

*  CLEAR pv_error.          "   lv_sap_millca_factor TYPE atwrt.
*  PERFORM read_et_char USING 'SAP_MILLCA_LENGTH'
*  CHANGING pv_error lv_sap_millca_length.

  " 포장재 수량
*  IF NOT lv_sap_millca_length IS INITIAL.
*    PERFORM change_string_replace
*    USING ',' CHANGING lv_sap_millca_length.
*    CONDENSE lv_sap_millca_length NO-GAPS.
*    MOVE lv_sap_millca_length TO lv_menge.
*  ENDIF.

  "  조장
  MOVE GT_BOTTOM_LEFT-LENGTH TO LV_MENGE.

  " 납품수량 / 조장
  IF GT_LIPS-LFIMG <> 0 AND LV_MENGE <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
    USING GT_LIPS-LFIMG '/' LV_MENGE CHANGING GT_AREA-MENGE.
  ENDIF.

  MOVE GT_0210-OUT_WID TO GT_AREA-WIDTH.
*    MOVE gt_0210-plan_dia TO gt_area-zlength.
*    MOVE gt_0210-plan_dia TO gt_area-height.

  IF NOT GT_0210-PK_WD_THK IS INITIAL.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_0210-PK_WD_THK '*' 2 CHANGING LV_WD_THK.
  ENDIF.

  GT_AREA-HEIGHT = GT_AREA-ZLENGTH = GT_0210-PLAN_DIA + LV_WD_THK.

  "  포장재 무게
  GT_AREA-PKWEI = GT_0210-DR_WEIGHT + GT_0210-PK_WD_WET.

  "  mm -> cm 반영하기 위해서나눔.
  IF GT_AREA-WIDTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-WIDTH '/' 10 CHANGING GT_AREA-WIDTH.
  ENDIF.

  IF GT_AREA-ZLENGTH <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-ZLENGTH '/' 10 CHANGING GT_AREA-ZLENGTH.
  ENDIF.

  IF GT_AREA-HEIGHT <> 0.
    PERFORM CALCULATION_EXCEPTION_HANDING
      USING GT_AREA-HEIGHT '/' 10 CHANGING GT_AREA-HEIGHT.
  ENDIF.


ENDFORM.                    " GET_SPART_20_STOCK_SPLIT
*&---------------------------------------------------------------------*
*&      Form  READ_BATCH_ATTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_API_VALI  text
*      -->P_LT_API_CHAR  text
*      -->P_PV_MATNR  text
*      -->P_PV_WERKS  text
*      -->P_PV_CHARG  text
*----------------------------------------------------------------------*
FORM READ_BATCH_ATTR  TABLES   PT_API_VALI STRUCTURE API_VALI
                               PT_API_CHAR STRUCTURE API_CHAR
                      USING    PV_MATNR
                               PV_WERKS
                               PV_CHARG.

  CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = PV_MATNR
      I_VAL_WERKS    = PV_WERKS
      I_VAL_CHARGE   = PV_CHARG
    TABLES
      T_VAL_TAB      = PT_API_VALI
      T_CHAR_TAB     = PT_API_CHAR
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4.

ENDFORM.                    " READ_BATCH_ATTR
*&---------------------------------------------------------------------*
*&      Form  READ_CHARG_ATTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5331   text
*      <--P_PV_ERROR  text
*      <--P_LV_SAP_MILLCA_PACKAGING  text
*----------------------------------------------------------------------*
FORM READ_CHARG_ATTR  TABLES   PT_API_VALI STRUCTURE API_VALI
                               PT_API_CHAR STRUCTURE API_CHAR
                                    USING PV_VALUE
                      CHANGING PV_ERROR
                               PV_SAP_MILLCA_PACKAGING.

  SORT PT_API_VALI BY ATNAM.

  CLEAR: PT_API_VALI, PV_ERROR.
  READ TABLE PT_API_VALI WITH KEY ATNAM = PV_VALUE
                                   BINARY SEARCH.

  IF SY-SUBRC <> 0.
    MOVE GC_X TO PV_ERROR.
  ELSE.
    MOVE PT_API_VALI-ATWRT TO PV_SAP_MILLCA_PACKAGING.
  ENDIF.

ENDFORM.                    " READ_CHARG_ATTR
*&---------------------------------------------------------------------*
*&      Form  GET_CHARG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_VBELN  text
*      -->P_PV_POSNR  text
*----------------------------------------------------------------------*
FORM GET_CHARG  USING PV_VBELN
                      PV_POSNR
             CHANGING PV_CHARG
                      PV_ERROR.

  DATA: LT_LIPS LIKE LIPS OCCURS 0 WITH HEADER LINE.

  SELECT POSNR CHARG
    INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
    FROM LIPS
   WHERE VBELN EQ PV_VBELN
      AND UECHA EQ PV_POSNR.

  SORT LT_LIPS BY POSNR.

  READ TABLE LT_LIPS INDEX 1.

  IF SY-SUBRC EQ 0.
    MOVE  LT_LIPS-CHARG TO PV_CHARG.
  ELSE.
    MOVE GC_X TO PV_ERROR.
  ENDIF.

ENDFORM.                    " GET_CHARG
*&---------------------------------------------------------------------*
*&      Form  CHECK_TRANS_ROUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_TRANS_ROUTE .
  DATA: LV_ZCY_CODE LIKE VTTK-ZCY_CODE,
        LV_ZONE1    LIKE ZSDT9121-ZONE1.

*___우편번호 입력되지 않은 경우
  IF GT_TOP_LEFT-POST_CODE1 IS INITIAL.
    GT_TOP_LEFT-ICON = ICON_RED_LIGHT.

    EXIT.
  ENDIF.

*___수출선적문서
  CLEAR : LV_ZCY_CODE.

  SELECT SINGLE B~ZCY_CODE
    INTO LV_ZCY_CODE
    FROM VTTP AS A
   INNER JOIN VTTK AS B
      ON A~TKNUM = B~TKNUM
   WHERE A~VBELN = GT_TOP_LEFT-VBELN
     AND B~SHTYP = 'Z103'.

  IF SY-SUBRC <> 0 OR LV_ZCY_CODE IS INITIAL.
*___수출선적문서가 없거나 CY Code가 입력되지 않은 경우
*   운송경로 점검
    CLEAR : LV_ZONE1.

    SELECT SINGLE ZONE1
      INTO LV_ZONE1
      FROM ZSDT9121
     WHERE POST_CODE = GT_TOP_LEFT-POST_CODE1.

    IF SY-SUBRC <> 0.
      SELECT SINGLE ZONE1
        INTO LV_ZONE1
        FROM ZSDT9120
       WHERE POST_CODE = GT_TOP_LEFT-POST_CODE1.

      IF SY-SUBRC <> 0.
*___우편번호가 존재하지 않으면 빨간신호등
        GT_TOP_LEFT-ICON = ICON_RED_LIGHT.

        EXIT.
      ENDIF.
    ENDIF.

    IF GT_TOP_LEFT-ROUTE+3(3) <> LV_ZONE1.
*___우편번호의 운송지역과 운송경로의 뒷자리(3)가 다르면 빨간신호등
      GT_TOP_LEFT-ICON = ICON_RED_LIGHT.

      EXIT.
    ENDIF.

    IF GT_TOP_LEFT-ROUTE IS NOT INITIAL.
      SELECT SINGLE ROUTE
        INTO GT_TOP_LEFT-ROUTE
        FROM TVRO
       WHERE ROUTE = GT_TOP_LEFT-ROUTE.

      IF SY-SUBRC <> 0.
*___운송경로가 존재하지 않으면 빨간신호등
        GT_TOP_LEFT-ICON = ICON_RED_LIGHT.

        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_TRANS_ROUTE
*&---------------------------------------------------------------------*
*&      Form  SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INIT_PARAMETER .

  CLEAR   : S_ERDA1.
  REFRESH : S_ERDA1.

  S_ERDA1-SIGN   = 'I'.
  S_ERDA1-OPTION = 'BT'.
  S_ERDA1-LOW    = SY-DATLO - 1.
  S_ERDA1-HIGH   = SY-DATLO.
  APPEND S_ERDA1.

  CLEAR   : S_ERDAT.
  REFRESH : S_ERDAT.

  S_ERDAT-SIGN   = 'I'.
  S_ERDAT-OPTION = 'BT'.
  S_ERDAT-LOW    = SY-DATLO - 10.
  S_ERDAT-HIGH   = SY-DATLO.
  APPEND S_ERDAT.

  IF SY-TCODE = GC_TCODE2.
    GV_TITLE = TEXT-T01."'포장재 표시율 검증용'.
  ELSE.
    GV_TITLE = TEXT-T02."'포장재 검증 및 TMS 전송'.
  ENDIF.

  SET TITLEBAR '0100' WITH GV_TITLE.

ENDFORM.                    " SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  GET_SALES_CHARACTER1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ET_CHAR  text
*      -->P_OD_DATA_VBELN_VL  text
*      -->P_OD_DATA_POSNR_VL  text
*      <--P_PV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_SALES_CHARACTER1  TABLES   PT_ET_CHAR STRUCTURE GT_ET_CHAR
                           USING    OD_DATA_VBELN_VL
                                    OD_DATA_POSNR_VL
                           CHANGING PV_ERROR.

  DATA : LV_VBELN LIKE VBAP-VBELN,
         LV_POSNR LIKE VBAP-POSNR.

  LV_VBELN = OD_DATA_VBELN_VL.
  LV_POSNR = OD_DATA_POSNR_VL.


  CLEAR   : PT_ET_CHAR, PV_ERROR.
  REFRESH : PT_ET_CHAR.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
    EXPORTING
      I_VBELN                      = LV_VBELN
      I_POSNR                      = LV_POSNR
    TABLES
      ET_CHAR                      = PT_ET_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.

  IF PT_ET_CHAR[] IS INITIAL.
    MOVE GC_X TO PV_ERROR.
    RETURN.
  ENDIF.

  SORT PT_ET_CHAR BY ATNAM.

*___쓰레기값 삭제
  DELETE PT_ET_CHAR WHERE ATWRT EQ '?'.
ENDFORM.                    " GET_SALES_CHARACTER1
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_L   USING PV_SPART
                      CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT1 INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF PV_SPART = '30'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                          + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ENDIF.
    ELSE.
      IF PV_SPART = '30'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                          + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ENDIF.

    ENDIF.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_L
