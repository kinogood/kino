*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES PT_TABLE USING PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_field_catalogs
*&---------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                          USING  PV_GUB
                                 PV_FNAME
                                 PV_VALUE.
*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점
  IF PV_GUB = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.
*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA LV_FNAME(40).
  FIELD-SYMBOLS <FS_FIELD> TYPE ANY.

  CONCATENATE 'GS_FIELDCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS_FIELD>.
  <FS_FIELD> = PV_VALUE.

  IF PV_GUB = 'E'.
    APPEND GS_FIELDCAT TO PT_FIELDCAT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROC USING PO_SENDER
                        PS_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        PV_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.

      MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.


      CLEAR LS_TOOLBAR.
      MOVE 'CHK'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_CHECKBOX      TO  LS_TOOLBAR-ICON.
      MOVE '체크'           TO  LS_TOOLBAR-QUICKINFO.
      MOVE '체크'           TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'SELA'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_SELECT_ALL      TO  LS_TOOLBAR-ICON.
      MOVE '전체선택'           TO  LS_TOOLBAR-QUICKINFO.
      MOVE '전체선택'           TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.
*
*    *&  MOVE   3                  TO  ls_toolbar-butn_type.
*    *&  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
      CLEAR LS_TOOLBAR.
      MOVE 'DSEL'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_DESELECT_ALL    TO  LS_TOOLBAR-ICON.
      MOVE '전체해제'           TO  LS_TOOLBAR-QUICKINFO.
      MOVE '전체해제'           TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'LOSS'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_SYSTEM_SAVE     TO  LS_TOOLBAR-ICON.
      MOVE '로스율저장'         TO  LS_TOOLBAR-QUICKINFO.
      MOVE '로스율저장'         TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'ALLO'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_MASS_CHANGE     TO  LS_TOOLBAR-ICON.
      MOVE '일괄로스율입력'      TO  LS_TOOLBAR-QUICKINFO.
      MOVE '일괄로스율입력'      TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'PRCA'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_CREATE         TO  LS_TOOLBAR-ICON.
      MOVE '구매요청생성'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '구매요청생성'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'PRDE'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_DELETE         TO  LS_TOOLBAR-ICON.
      MOVE '구매요청삭제'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '구매요청삭제'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'CHANGE'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_INTERCHANGE         TO  LS_TOOLBAR-ICON.
      MOVE '대체자재변경'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '대체자재변경'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'UNDO'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_SYSTEM_UNDO         TO  LS_TOOLBAR-ICON.
      MOVE '대체자재변경취소'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '대체자재변경취소'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

*      CLEAR ls_toolbar.
*      MOVE 'SENDMAIL'           TO  ls_toolbar-function.
*      MOVE ICON_MAIL            TO  ls_toolbar-icon.
*      MOVE '메일 전송'          TO  ls_toolbar-quickinfo.
*      MOVE '메일 전송'          TO  ls_toolbar-text.
*      MOVE ' '                  TO  ls_toolbar-disabled.
*      APPEND ls_toolbar         TO  ps_object->mt_toolbar.

    WHEN GO_GRID_0230.
      MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'PRCA'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_CHANGE         TO  LS_TOOLBAR-ICON.
      MOVE '구매요청변경'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '구매요청변경'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'PRDE'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_DELETE         TO  LS_TOOLBAR-ICON.
      MOVE '구매요청삭제'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '구매요청삭제'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

    WHEN GO_GRID_0270.
      MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'UNDOMAT'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_SYSTEM_UNDO         TO  LS_TOOLBAR-ICON.
      MOVE '대체자재변경취소'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '대체자재변경취소'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.

    WHEN GO_GRID_0400.
      MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'PRCA'              TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_CREATE         TO  LS_TOOLBAR-ICON.
      MOVE '구매요청생성'       TO  LS_TOOLBAR-QUICKINFO.
      MOVE '구매요청생성'       TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  PS_OBJECT->MT_TOOLBAR.


  ENDCASE.

*  PERFORM SET_TOOLBAR TABLES ps_object->MT_TOOLBAR
*                       USING : '' '' '' '' '3',            "구분자
*                                  'ADD' ICON_CREATE '' TEXT-T01 0 ,
*                                  'DEL' ICON_DELETE '' TEXT-T02 0,
*                                  'COP' ICON_SYSTEM_COPY '' TEXT-T03 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROC USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                             PV_UCOMM.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LS_ZGTPPT3292 TYPE  ZGTPPT3292.
  DATA : LT_ZGTPPT3292 TYPE TABLE OF ZGTPPT3292.
  DATA : LT_DELTAB_2130 TYPE TABLE OF ZGTPPT2130.
  DATA : LV_CHK_ITEM_EXIST.
  DATA : LV_INDEX TYPE SY-TABIX.
  DATA : LV_RESULT(1).
  DATA : LV_PR_CHK(1).
  DATA : LV_UNDOMAT_CHK(1).
  DATA : LV_UNDO_CHK(1).
  DATA : LV_MAIL_CHK(1),
         LV_MAIL_CHK2(1).

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CELLS_DISP TYPE LVC_T_CENO.
  DATA : LT_INDEX_ROWS TYPE LVC_T_ROW,
         LT_ROW_NO     TYPE LVC_T_ROID.
  DATA : LS_INDEX_ROWS TYPE LVC_S_ROW,
         LS_ROW_NO     TYPE LVC_S_ROID.
  DATA : LS_MODI TYPE LVC_S_MODI.
  DATA : LS_DISP_91 LIKE GS_DISP,
         LT_DISP_91 LIKE TABLE OF GS_DISP . "전송 ALV 테이블


  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_STYLE01  TYPE LVC_STYLE.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_CHANGE_CHK(1).
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.

        WHEN 'CHK'.

          CLEAR: LT_CELLS[], LT_CELLS.
          CLEAR : GT_DISP_CHK[], GT_DISP_CHK.

          GO_GRID_0100->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS ).                " CELL IDS

          LOOP AT LT_CELLS INTO DATA(LS_CELLS).
            READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX LS_CELLS-ROW_ID.
            <LS_DISP>-CHECK = ABAP_TRUE.

          ENDLOOP.

*            화면 리프레쉬

*          PERFORM REFRESH_GRID USING GO_GRID_0100.

          LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE CHECK = 'X' .
            REFRESH LT_CELLTAB.
            LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
              CASE <LS_FACT>-FIELDNAME.
                WHEN 'GRPNR' OR 'VBELN' OR 'KUNNR' OR
                     'NAME1' OR 'EDATU' OR 'MATNR_F' OR
                     'SUL_NO' OR 'REV_SEQ' OR
                     'KV' OR 'SQ'
                     .

                WHEN OTHERS .
                  CLEAR LS_CELLTAB.
                  CLEAR LV_FIELDNAME.
                  LV_FIELDNAME = <LS_FACT>-FIELDNAME.
                  LS_CELLCOL-FNAME = LV_FIELDNAME.
                  LS_CELLCOL-COLOR-COL = '3'.
                  LS_CELLCOL-COLOR-INT = '0'.
                  LS_CELLCOL-COLOR-INV = '0'.
                  LS_CELLCOL-NOKEYCOL  = ' '.
                  INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

              ENDCASE.
            ENDLOOP.

            INSERT LINES OF LT_CELLCOL INTO TABLE <LS_DATA>-CELLSCOL.
          ENDLOOP.

*            화면 리프레쉬
          PERFORM REFRESH_GRID USING GO_GRID_0100.


        WHEN 'SELA'.  " 전체 선택

          LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPA>).
            <LS_DISPA>-CHECK = ABAP_TRUE.
          ENDLOOP.
*            화면 리프레쉬
          PERFORM REFRESH_GRID USING GO_GRID_0100.
        WHEN 'DSEL'. "전체 해제

          LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPD>).
            <LS_DISPD>-CHECK = ''.
          ENDLOOP.
*            화면 리프레쉬
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'LOSS'. " 로스율  저장

          CLEAR GV_ANSWER.
          PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
            ' '
            TEXT-M17 "'해당 정보로 로스율이 저장됩니다. 진행하시겠습니까?'
            TEXT-M18. "'저장확인'.
          IF GV_ANSWER NE 'J'.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '저장작업이 취소 되었습니다.'.
            RETURN.
          ENDIF.

          CHECK GV_ANSWER = 'J'.

          CLEAR: LT_CELLS[], LT_CELLS..

          GO_GRID_0100->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS ).                " CELL IDS

*          LOOP AT lt_cells INTO DATA(ls_cells_loss).
*            READ TABLE gt_disp ASSIGNING FIELD-SYMBOL(<ls_displ>)
*                                        INDEX ls_cells_loss-row_id.
          CLEAR : LT_DISP_91[].
          LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPL>)
                                   WHERE CHECK = 'X'.
            MOVE-CORRESPONDING <LS_DISPL> TO LS_DISP_91.
            APPEND LS_DISP_91 TO LT_DISP_91.
          ENDLOOP.

          SORT LT_DISP_91 BY  CHECK
                              GRPNR
                              VBELN
                              AUFNR_T
                              MATNR_F
                              GONG_CD
                              MATNR_R.

          DELETE ADJACENT DUPLICATES FROM LT_DISP_91
                         COMPARING
                              CHECK
                              GRPNR
                              VBELN
                              AUFNR_T
                              MATNR_F
                              GONG_CD
                              MATNR_R.

          LOOP AT LT_DISP_91 ASSIGNING FIELD-SYMBOL(<LS_DISPL2>).
*                                   WHERE CHECK = 'X'.

            PERFORM SAVE_LOG_3291 USING <LS_DISPL2>
                                        LV_RESULT.
          ENDLOOP.

          IF LV_RESULT = 'S'.
            MESSAGE S003 DISPLAY LIKE 'S' WITH '저장작업이 성공 되었습니다.'.
          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '저장작업이 실패하였습니다.'.
          ENDIF.

*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'ALLO'. "일괄로스율입력

          CLEAR : GT_ROW_250[], GS_ROW_250.
          CALL METHOD PO_SENDER->GET_SELECTED_ROWS
            IMPORTING
              ET_INDEX_ROWS = GT_ROW_250.

          CALL SCREEN '0250' STARTING AT 5 5 ENDING AT 76 10.
*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'PRCA'. " 구매요청 생성
          .
          PERFORM PROC_CREATE_REQ USING PO_SENDER.
*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'PRDE'. " 구매요청 삭제


          PERFORM PROC_DEL_REQ USING PO_SENDER.
*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'CHANGE'.  "대체자재 변경

          LV_CHANGE_CHK = 'Y'.
          LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
            IF GS_DISP-GUBUN =  '기존 발주내역'.
              LV_CHANGE_CHK = 'N'.
              MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E14.
            ENDIF.
            IF GS_DISP-GUBUN = '대체자재 지정'.
              LV_CHANGE_CHK = 'N'.
              MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E16.
            ENDIF.

          ENDLOOP.

          CHECK LV_CHANGE_CHK <> 'N'.


          PERFORM CHANGE_MATNR.
*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'UNDO'.  "대체자재 변경 취소

          LV_UNDO_CHK = 'Y'.
          LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
            IF GS_DISP-BANFN IS NOT INITIAL.
              LV_UNDO_CHK = 'N'.
              MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E15.
            ENDIF.

          ENDLOOP.
          CHECK LV_UNDO_CHK = 'Y'.

          CLEAR : GT_DISP_UNDO[],GT_DISP_UNDO_MTS[].
          CLEAR : GT_T3292P[], GS_T3292P.
          LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'
                                         AND MTS_CHK = ''.
            MOVE-CORRESPONDING GS_DISP TO GS_DISP_UNDO..
            APPEND GS_DISP_UNDO TO GT_DISP_UNDO.
          ENDLOOP.

          LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'
                                         AND MTS_CHK = 'MTS'.
            MOVE-CORRESPONDING GS_DISP TO GS_DISP_UNDO_MTS..
            APPEND GS_DISP_UNDO_MTS TO GT_DISP_UNDO_MTS.
          ENDLOOP.

          IF GT_DISP_UNDO[] IS NOT INITIAL.
            SELECT *
              INTO  CORRESPONDING FIELDS OF TABLE @GT_T3292P
              FROM ZGTPPT3292
              FOR ALL ENTRIES IN @GT_DISP_UNDO
             WHERE GRPNR        EQ @GT_DISP_UNDO-GRPNR
               AND VBELN        EQ @GT_DISP_UNDO-VBELN+0(10)
*             AND AUFNR        EQ @GT_DISP_UNDO-AUFNR_T
               AND MATNR_F      EQ @GT_DISP_UNDO-MATNR_F
               AND GONG_CD      EQ @GT_DISP_UNDO-GONG_CD
               AND MATNR_TO     EQ @GT_DISP_UNDO-MATNR_R.
          ENDIF.

          IF GT_DISP_UNDO_MTS[] IS NOT INITIAL.
            SELECT *
              APPENDING  CORRESPONDING FIELDS OF TABLE @GT_T3292P
              FROM ZGTPPT3292
              FOR ALL ENTRIES IN @GT_DISP_UNDO_MTS
             WHERE GRPNR        EQ @GT_DISP_UNDO_MTS-GRPNR
               AND VBELN        EQ @GT_DISP_UNDO_MTS-VBELN+0(10)
               AND AUFNR        EQ @GT_DISP_UNDO_MTS-AUFNR_T
               AND MATNR_F      EQ @GT_DISP_UNDO_MTS-MATNR_F
               AND GONG_CD      EQ @GT_DISP_UNDO_MTS-GONG_CD
               AND MATNR_TO     EQ @GT_DISP_UNDO_MTS-MATNR_R
               .
          ENDIF.

          CLEAR : GT_MAKT_POPUP[].
          IF GT_T3292P[] IS NOT INITIAL.
            SELECT *
              INTO CORRESPONDING FIELDS OF TABLE GT_MAKT_POPUP
              FROM MAKT
              FOR ALL ENTRIES IN GT_T3292P
             WHERE MATNR = GT_T3292P-MATNR_FR
               AND SPRAS = SY-LANGU.

            SELECT *
              APPENDING CORRESPONDING FIELDS OF TABLE GT_MAKT_POPUP
              FROM MAKT
              FOR ALL ENTRIES IN GT_T3292P
             WHERE MATNR = GT_T3292P-MATNR_TO
               AND SPRAS = SY-LANGU.
          ENDIF.

          LOOP AT GT_T3292P INTO GS_T3292P.
            READ TABLE GT_MAKT_POPUP INTO GS_MAKT_POPUP
                                    WITH KEY MATNR = GS_T3292P-MATNR_FR.
            IF SY-SUBRC = 0.
              GS_T3292P-MAKTX_FR = GS_MAKT_POPUP-MAKTX.
            ENDIF.

            READ TABLE GT_MAKT_POPUP INTO GS_MAKT_POPUP
                                    WITH KEY MATNR = GS_T3292P-MATNR_TO.
            IF SY-SUBRC = 0.
              GS_T3292P-MAKTX_TO = GS_MAKT_POPUP-MAKTX.
            ENDIF.
            MODIFY GT_T3292P FROM GS_T3292P.
          ENDLOOP.

          CALL SCREEN '0270' STARTING AT 5 5 ENDING AT 150 20.
*            화면 리프레쉬
          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

        WHEN 'SENDMAIL'.
          LV_MAIL_CHK2 = 'Y'.
          READ TABLE GT_DISP INTO GS_DISP
                             WITH KEY CHECK = 'X'.
          IF SY-SUBRC <> 0.
            LV_MAIL_CHK2 = 'N'.
            "선택된 라인이 없습니다.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
          ENDIF.
          CHECK LV_MAIL_CHK2 = 'Y'.

          LV_MAIL_CHK = 'Y'.
          LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
            IF GS_DISP-BANFN IS NOT INITIAL.
              LV_MAIL_CHK = 'N'.
              "구매요청문서가 없는 Line을 선택했습니다
              MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E19.
            ENDIF.

          ENDLOOP.
          CHECK LV_MAIL_CHK = 'Y'.

          PERFORM SEND_MAIL.



      ENDCASE.
**        화면 리프레쉬
*      PERFORM REFRESH_GRID USING GO_GRID_0100.

    WHEN GO_GRID_0230.
      CASE PV_UCOMM.
        WHEN 'PRCA'.

          LOOP AT GT_T3290P INTO GS_T3290P WHERE CHECK = 'X'.
            LV_PR_CHK = 'Y'.
            READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPR>)
                               INDEX SY-TABIX.
            IF SY-SUBRC = 0.

              IF <LS_DISPR>-EBELN IS NOT INITIAL.
                LV_PR_CHK = 'N'.
                "선택한 Line에는 구매오더 정보가 있기 때문에 변경, 삭제 불가합니다
                MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E12.
                LV_PR_CHK = 'N'.
                EXIT.
              ENDIF.

            ENDIF.
          ENDLOOP.
          CHECK LV_PR_CHK <> 'N'.

          PERFORM PROC_CHANGE_REQ_0230 TABLES GT_DISP
                                         USING PO_SENDER.

        WHEN 'PRDE'.. " 구매요청 삭제

          PERFORM PROC_DEL_REQ_230 USING PO_SENDER.
          .
      ENDCASE.
*        화면 리프레쉬
*      PERFORM refresh_grid USING go_grid_0100.

    WHEN GO_GRID_0270.

      CASE PV_UCOMM.
        WHEN 'UNDOMAT' .

          CLEAR GV_ANSWER.
          PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
            ' '
            TEXT-M22 "'해당 자재대체 내역이 삭제됩니다. 진행하시겠습니까?'
            TEXT-M20."'삭제확인'.
          IF GV_ANSWER NE 'J'.
            " '자재대체 내역 삭제작업이 취소 되었습니다.'.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E17.
            RETURN.
          ENDIF.

          CHECK GV_ANSWER = 'J'.


          LOOP AT GT_T3292P INTO GS_T3292P .
            MOVE-CORRESPONDING GS_T3292P TO LS_ZGTPPT3292.
            APPEND LS_ZGTPPT3292 TO LT_ZGTPPT3292.
          ENDLOOP.

          DELETE  ZGTPPT3292 FROM TABLE LT_ZGTPPT3292.
          IF SY-SUBRC EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
          CLEAR : GT_T3292P[], GS_T3292P.
          MESSAGE S003 DISPLAY LIKE 'S' WITH TEXT-E17.

          CALL METHOD GO_CONTAIN_0270->FREE.
          FREE : GO_CONTAIN_0270, GO_GRID_0270.
          CALL METHOD CL_GUI_CFW=>FLUSH.
          CLEAR : GT_T3292P[], GS_T3292P.

          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN GO_GRID_0400.

      CASE PV_UCOMM.
        WHEN 'PRCA'.

          PERFORM PROC_CREATE_REQ_0400 TABLES GT_DISP
                                       USING PO_SENDER
                                       .
      ENDCASE.
*        화면 리프레쉬
*      PERFORM refresh_grid USING go_grid_0100.

  ENDCASE.

*  PERFORM refresh_grid_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM AFTER_USER_COMMAND USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                              PV_UCOMM.


*  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
*        LT_ROW_NO     TYPE LVC_T_ROID.
*
*  DATA: LS_INDEX_ROWS TYPE LVC_S_ROW,
*        LS_ROW_NO     TYPE LVC_S_ROID.
*
*  DATA :LS_MODI TYPE LVC_S_MODI.
*
*
*  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
*         LT_ROW_NO, LT_ROW_NO[].
*
*  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
*
*    LS_MODI-ROW_ID = SY-TABIX.
*
*    LS_INDEX_ROWS-INDEX = LS_MODI-ROW_ID.
*    APPEND LS_INDEX_ROWS TO LT_INDEX_ROWS.
*
*    LS_ROW_NO-ROW_ID = LS_MODI-ROW_ID.
*    APPEND LS_ROW_NO TO LT_ROW_NO.
*
*    PO_SENDER->SET_SELECTED_ROWS(
*      EXPORTING
*        IT_INDEX_ROWS = LT_INDEX_ROWS
*        IT_ROW_NO     = LT_ROW_NO ).
*
*    MODIFY GT_DISP INDEX LS_MODI-ROW_ID FROM GS_DISP .
*  ENDLOOP.



  CASE PV_UCOMM.
    WHEN '&REFRESH'.
*            화면 리프레쉬
      PERFORM GET_DATA.
      PERFORM MODIFY_DATA.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                        PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                        PV_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01.

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI.


  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  DATA : LV_ROW TYPE LVC_S_ROW.
  DATA : LV_CALL_FUNC.

  DATA : LV_AUSCH          TYPE P DECIMALS 2,
         LV_NWMENG_TXT(70),
         LV_AUSCH_TXT(70).

  LOOP AT PR_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.

    READ TABLE GT_DISP INTO GS_DISP INDEX LS_MOD_CELLS-ROW_ID.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'RWMENG'.
        LV_NWMENG_TXT = LS_MOD_CELLS-VALUE.
        REPLACE ALL OCCURRENCES OF ',' IN LV_NWMENG_TXT WITH ''.
        LS_MOD_CELLS-VALUE = LV_NWMENG_TXT.
        "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * LS_MOD_CELLS-VALUE )
                                / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.
        MODIFY GT_DISP INDEX LS_MOD_CELLS-ROW_ID FROM GS_DISP .
*         화면 리프레쉬
        PERFORM REFRESH_GRID USING GO_GRID_0100.
      WHEN 'AUSCH'.
        LV_AUSCH_TXT = LS_MOD_CELLS-VALUE.
        REPLACE ALL OCCURRENCES OF ',' IN LV_AUSCH_TXT WITH ''.
        LS_MOD_CELLS-VALUE = LV_AUSCH_TXT.
*         LV_AUSCH = ( ls_mod_cells-value / 100 ).
        IF GS_DISP-MTS_CHK = 'MTS'.
          " 소요량 = 기존 소요량 * 수정한 로스율 / 기존 로스율
          GS_DISP-ERFMG_SO = ( GS_DISP-ERFMG_SO *  LS_MOD_CELLS-VALUE )
                             / GS_DISP-AUSCH.
          IF GS_DISP-NWMENG <> 0.
            GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                   / GS_DISP-NWMENG.
          ELSE.
            GS_DISP-ERFMG_RE   = 0 .
          ENDIF.
        ELSE.

          "소요량(수주 기준) = '정미량(JAJE_QTY)' * 로스율 * '신규 수주량(WMENG) / 1000.
          GS_DISP-ERFMG_SO   =  ( GS_DISP-JAJE_QTY *
                                LS_MOD_CELLS-VALUE *
                                GS_DISP-NWMENG ) / 1000.

          "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
          IF GS_DISP-NWMENG <> 0.
            GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                  / GS_DISP-NWMENG.
          ELSE.
            GS_DISP-ERFMG_RE   = 0 .
          ENDIF.

        ENDIF.
        MODIFY GT_DISP INDEX LS_MOD_CELLS-ROW_ID FROM GS_DISP .
*         화면 리프레쉬
        PERFORM REFRESH_GRID USING GO_GRID_0100.
      WHEN 'CHECK'.
        GV_CHK_LINE = LS_MOD_CELLS-ROW_ID.
        GV_CHK_VALUE = LS_MOD_CELLS-VALUE.
        LV_CALL_FUNC = ABAP_TRUE.


*            LV_ROW-index = LS_MOD_CELLS-ROW_ID.
*
*            PERFORM SET_SELECTED_ROWS USING PO_SENDER LV_ROW-index.
*
*            MODIFY GT_DISP INDEX LS_MOD_CELLS-ROW_ID FROM GS_DISP .


*            LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE CHECK = 'X' .
*              REFRESH LT_CELLTAB.
*              LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
*                CASE <LS_FACT>-FIELDNAME.
*                  WHEN 'GRPNR' OR 'VBELN' OR 'KUNNR' OR
*                       'NAME1' OR 'EDATU' OR 'MATNR_F' OR
*                       'SUL_NO' OR 'REV_SEQ' OR
*                       'KV' OR 'SQ'
*                       .
*
*                  WHEN OTHERS .
*                  CLEAR LS_CELLTAB.
*                  CLEAR LV_FIELDNAME.
*                  LV_FIELDNAME = <LS_FACT>-FIELDNAME.
*                  ls_cellcol-fname = LV_FIELDNAME.
*                  ls_cellcol-color-col = '3'.
*                  ls_cellcol-color-int = '0'.
*                  ls_cellcol-color-inv = '0'.
*                  ls_cellcol-nokeycol  = ' '.
*                  INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*                ENDCASE.
*              ENDLOOP.
*
*              INSERT LINES OF lt_cellcol INTO TABLE <LS_DATA>-cellScol.
*
*            ENDLOOP.
*
** 화면 리프레쉬
*            PERFORM REFRESH_GRID USING GO_GRID_0100.

    ENDCASE.

*      MODIFY GT_DISP INDEX LS_MOD_CELLS-ROW_ID FROM GS_DISP .

  ENDLOOP.

* 화면 리프레쉬
*  PERFORM REFRESH_GRID USING GO_GRID_0100.

  IF LV_CALL_FUNC IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'SETCHECK'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PV_ROW_ID     TYPE LVC_S_ROW
                                     PV_COLUMN_ID TYPE LVC_S_COL.

  CASE PV_COLUMN_ID-FIELDNAME.

*    WHEN 'AUFNR'. "생산 오더
*

*        CLEAR gs_disp.
*        READ TABLE gt_disp1 INTO gs_disp INDEX pv_row_id-index.
*        SET PARAMETER ID 'ANR' FIELD gs_disp-aufnr.
*        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.


*     CLEAR gs_disp.
*     READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.
*     SET PARAMETER ID 'MAT' FIELD gs_disp-matnr.
*     CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                        PV_ROW
                        PV_COLUMN.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.
  DATA : LT_CELLS_DISP TYPE LVC_T_CENO.
  READ TABLE GT_DISP INTO  GS_DISP INDEX PV_ROW.


  CASE PO_SENDER.

    WHEN GO_GRID_0100.

      CASE PV_COLUMN.

        WHEN 'GRPNR'.

*          CLEAR: lt_seltab.
*          lt_seltab = VALUE #(
*          ( selname = 'P_WERKS' kind = 'P' sign = 'I' option = 'EQ' low = '1302' )
*          ( selname = 'P_SPGCD' kind = 'P' sign = 'I' option = 'EQ' low = 'PC' )
*          ( selname = 'S_GRPNR' kind = 'S' sign = 'I' option = 'EQ' low = gs_disp-grpnr )
*           ).
*          SUBMIT zgtppr2050 WITH SELECTION-TABLE lt_seltab
*                            AND  RETURN.


          SET PARAMETER ID: 'WRK' FIELD '1302'.
          SET PARAMETER ID: 'ZSPG' FIELD 'PC'.
          SET PARAMETER ID: 'ZGRPNR' FIELD GS_DISP-GRPNR.

          CALL TRANSACTION 'ZGTPPR2050'AND SKIP FIRST SCREEN.
          SET PARAMETER ID: 'ZGRPNR' FIELD SPACE.

        WHEN 'VBELN'.

          SET PARAMETER ID: 'AUN' FIELD GS_DISP-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        WHEN 'SUL_NO'.

          SET PARAMETER ID: 'ZED_SUL_NO' FIELD GS_DISP-SUL_NO.
          CALL TRANSACTION 'ZED1L1030' AND SKIP FIRST SCREEN.

        WHEN 'MATNR_F' OR 'MAKTX_F'.
          SET PARAMETER ID 'MAT' FIELD GS_DISP-MATNR_F.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

        WHEN 'MATNR_R' OR 'MAKTX_R'.
          SET PARAMETER ID 'MAT' FIELD GS_DISP-MATNR_R.
          CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

        WHEN 'VBELN_TXT'.

          CLEAR : GT_POPUP2[].
          GO_GRID_0100->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS ).                " CELL IDS

          LOOP AT LT_CELLS INTO DATA(LS_CELLS).
            READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX LS_CELLS-ROW_ID.

            LOOP AT GT_DATA_INIT INTO GS_DATA_INIT
                                 WHERE GRPNR = <LS_DISP>-GRPNR.
              GS_POPUP2-VBELN     = GS_DATA_INIT-VBELN.
              GS_POPUP2-KUNNR     = GS_DATA_INIT-KUNNR.
              " 납선
              CLEAR : GS_KNA1.
              READ TABLE GT_KNA1 INTO GS_KNA1
                                 WITH KEY KUNNR = GS_DATA_INIT-KUNNR
                                 BINARY SEARCH.
              IF SY-SUBRC = 0.
                GS_POPUP2-NAME1   =   GS_KNA1-NAME1.
              ENDIF.
              GS_POPUP2-EDATU     = GS_DATA_INIT-EDATU.
              GS_POPUP2-MATNR_F   = GS_DATA_INIT-MATNR_F.
              APPEND GS_POPUP2 TO GT_POPUP2.
            ENDLOOP.
          ENDLOOP.

          SORT GT_POPUP2 BY VBELN  KUNNR.

          CALL SCREEN 0260 STARTING AT 2 2 ENDING AT 70 10.
*         REFRESH DISPLAY
          CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
            EXPORTING
              I_SOFT_REFRESH = 'X'
              IS_STABLE      = GV_STABLE.

        WHEN 'AUFNR_TXT'.

          CLEAR: GT_POPUP[], GS_POPUP.

          SELECT *
             INTO CORRESPONDING FIELDS OF TABLE GT_AFPO_P
             FROM AFPO
             FOR ALL ENTRIES IN GT_T2010
             WHERE AUFNR = GT_T2010-ORDNR.
          SORT GT_AFPO_P BY AUFNR.

          LOOP AT GT_T2010 INTO GS_T2010 WHERE GRPNR = GS_DISP-GRPNR
                                         AND GONG_CD = GS_DISP-GONG_CD.

            GS_POPUP-GONG_NM    = GS_DISP-GONG_NM.
            GS_POPUP-AUFNR      = GS_T2010-ORDNR.
            GS_POPUP-POSNR      = GS_T2010-POSNR.
            GS_POPUP-WEMNG      = GS_T2010-WEMNG.
            READ TABLE GT_AFPO_P INTO GS_AFPO_P
                                 WITH KEY AUFNR = GS_T2010-ORDNR.
            GS_POPUP-NWMENG     = GS_AFPO_P-PSMNG.
            GS_POPUP-MEINS      = GS_T2010-MEINS.
            APPEND GS_POPUP TO GT_POPUP.

          ENDLOOP.


          IF GT_POPUP[] IS  INITIAL.

*            MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e08.
            SET PARAMETER ID 'ANR' FIELD GS_DISP-AUFNR_T.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          ELSE.

            SORT GT_POPUP BY GRPNR  MATNR_F AUFNR POSNR.

            CALL SCREEN 0220 STARTING AT 2 2 ENDING AT 110 20.
*         REFRESH DISPLAY
            CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
              EXPORTING
                I_SOFT_REFRESH = 'X'
                IS_STABLE      = GV_STABLE.

          ENDIF.

        WHEN 'BANFN'. " 구매요청 번호
*          SET PARAMETER ID 'BAN' FIELD gs_disp-banfn.
*          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

          GO_GRID_0100->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS_DISP ).                " Cell IDs

          LOOP AT LT_CELLS_DISP INTO DATA(LS_CELLS_DISP).
            READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>)
                                          INDEX LS_CELLS_DISP-ROW_ID.
*            변경정 설계서 구매오더 추출
            CLEAR : GT_T3290P[].
            IF <LS_MAIN_DISP>-MTS_CHK = 'MTS'.
              SELECT *
                INTO CORRESPONDING FIELDS OF TABLE GT_T3290P
                FROM ZGTPPT3290 AS A INNER JOIN ZGTPPT3280 AS B
                                     ON A~BANFN = B~BANFN
                                     AND A~BNFPO = B~BNFPO
                WHERE A~GRPNR = <LS_MAIN_DISP>-GRPNR
                  AND A~VBELN = <LS_MAIN_DISP>-VBELN+0(10)
                  AND A~MATNR_F = <LS_MAIN_DISP>-MATNR_F
                  AND A~SUL_NO  = <LS_MAIN_DISP>-SUL_NO
                  AND A~REV_SEQ = <LS_MAIN_DISP>-REV_SEQ
                  AND A~GONG_CD = <LS_MAIN_DISP>-GONG_CD
                  AND A~AUFNR = <LS_MAIN_DISP>-AUFNR_T
                  AND A~MATNR = <LS_MAIN_DISP>-MATNR_R
                  AND A~LOEKZ     = ''.
              SORT GT_T3290P BY GRPNR VBELN MATNR_F GONG_CD MATNR.

            ELSE.
              SELECT *
                INTO CORRESPONDING FIELDS OF TABLE GT_T3290P
                FROM ZGTPPT3290 AS A INNER JOIN ZGTPPT3280 AS B
                                     ON A~BANFN = B~BANFN
                                     AND A~BNFPO = B~BNFPO
                WHERE A~GRPNR = <LS_MAIN_DISP>-GRPNR
                  AND A~VBELN = <LS_MAIN_DISP>-VBELN+0(10)
                  AND A~MATNR_F = <LS_MAIN_DISP>-MATNR_F
                  AND A~SUL_NO  = <LS_MAIN_DISP>-SUL_NO
                  AND A~REV_SEQ = <LS_MAIN_DISP>-REV_SEQ
                  AND A~GONG_CD = <LS_MAIN_DISP>-GONG_CD
*                  AND a~aufnr = <ls_main_disp>-aufnr_t
                  AND A~MATNR = <LS_MAIN_DISP>-MATNR_R
                  AND A~LOEKZ     = ''.
              SORT GT_T3290P BY GRPNR VBELN MATNR_F GONG_CD MATNR.
            ENDIF.

          ENDLOOP.

          LOOP AT GT_T3290P INTO GS_T3290P.

            READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP2>)
                                          INDEX LS_CELLS_DISP-ROW_ID.
            " 제품명
            CLEAR : GS_MAKT.
            READ TABLE GT_MAKT2 INTO GS_MAKT
                               WITH KEY MATNR = <LS_MAIN_DISP2>-MATNR_R
                               BINARY SEARCH.
            IF SY-SUBRC = 0.
              GS_T3290P-MAKTX_R =   GS_MAKT-MAKTX.
            ENDIF.

            GS_T3290P-WEMNG2   = <LS_MAIN_DISP2>-WEMNG2.    "  입고 수량

*            플랜트
            GS_T3290P-WERKS = P_WERKS.
*            저장소
            PERFORM GET_LGORT USING <LS_MAIN_DISP2>-MATNR_R
                     CHANGING GS_T3290P-LGORT.

            MODIFY GT_T3290P FROM GS_T3290P.
          ENDLOOP.
          SORT GT_T3290P BY BANFN
                            BNFPO.
          DELETE ADJACENT DUPLICATES FROM GT_T3290P
                         COMPARING BANFN
                                   BNFPO.


          "========================구매오더(PO) DATA 확인 START
          CLEAR : GT_EKPOA_POP[].
          SELECT  *
            INTO CORRESPONDING FIELDS OF TABLE @GT_EKPOA_POP
            FROM EKPO AS A
            FOR ALL ENTRIES IN @GT_T3290P
           WHERE A~BANFN = @GT_T3290P-BANFN
             AND A~BNFPO = @GT_T3290P-BNFPO.

          SORT GT_T3290P BY BANFN
                            BNFPO.

          LOOP AT GT_T3290P INTO GS_T3290P.
            CLEAR : GS_EKPOA_POP.
            READ TABLE GT_EKPOA_POP INTO GS_EKPOA_POP
                               WITH KEY BANFN = GS_T3290P-BANFN
                                        BNFPO = GS_T3290P-BNFPO
                               BINARY SEARCH.
            IF SY-SUBRC = 0.
              GS_T3290P-EBELN = GS_EKPOA_POP-EBELN.
              GS_T3290P-EBELP = GS_EKPOA_POP-EBELP.
              MODIFY GT_T3290P FROM GS_T3290P.
            ENDIF.
          ENDLOOP.

          "========================구매오더(PO) DATA 확인END

          CALL SCREEN 0230 STARTING AT 2 2 ENDING AT 210 20.

          PERFORM GET_DATA.
          PERFORM MODIFY_DATA.
          PERFORM REFRESH_GRID USING GO_GRID_0100.

*    *     REFRESH DISPLAY
*          CALL METHOD go_grid_0100->refresh_table_display
*            EXPORTING
*              i_soft_refresh = 'X'
*              is_stable      = gv_stable.



        WHEN 'EBELN'. " 구매오더번호
          SET PARAMETER ID 'BES' FIELD GS_DISP-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ENDCASE.

    WHEN GO_GRID_0220.

      CASE PV_COLUMN.

        WHEN 'AUFNR'.
          CLEAR : LT_CELLS_DISP[].
          GO_GRID_0220->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS_DISP ).                " CELL IDS

          LOOP AT LT_CELLS_DISP INTO DATA(LS_CELLS_DISP3).
            READ TABLE GT_POPUP ASSIGNING FIELD-SYMBOL(<LS_POPUP_DISP>)
                                        INDEX LS_CELLS_DISP3-ROW_ID.
            SET PARAMETER ID 'ANR' FIELD <LS_POPUP_DISP>-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          ENDLOOP.

        WHEN OTHERS.

      ENDCASE.

    WHEN GO_GRID_0230.
      CASE PV_COLUMN.
        WHEN 'BANFN'.
          READ TABLE GT_T3290P INTO DATA(LS_T3290P) INDEX PV_ROW.

          SET PARAMETER ID 'BAN' FIELD LS_T3290P-BANFN.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

      ENDCASE.
      .

    WHEN GO_GRID_0260.

      CASE PV_COLUMN.

        WHEN 'VBELN'.
          CLEAR : LT_CELLS_DISP[].
          GO_GRID_0260->GET_SELECTED_CELLS_ID(
              IMPORTING
               ET_CELLS = LT_CELLS_DISP ).                " CELL IDS

          LOOP AT LT_CELLS_DISP INTO DATA(LS_CELLS_DISP2).
            READ TABLE GT_POPUP2 ASSIGNING FIELD-SYMBOL(<LS_POPUP2_DISP>)
                                        INDEX LS_CELLS_DISP2-ROW_ID.
            SET PARAMETER ID 'AUN' FIELD <LS_POPUP2_DISP>-VBELN.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

          ENDLOOP.

        WHEN OTHERS.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
FORM BUTTON_CLICK USING PS_COL_ID  TYPE  LVC_S_COL
                        PS_ROW_NO  TYPE  LVC_S_ROID.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FNAME
                       PV_FVAL
                       PS_ROID  TYPE LVC_S_ROID
                       PO_EVENT TYPE REF TO CL_ALV_EVENT_DATA
                       PT_BCELL TYPE LVC_T_MODI
                       PV_DISPLAY.


  DATA: LS_MODI TYPE LVC_S_MODI.

  FIELD-SYMBOLS: <LT_MODI> TYPE LVC_T_MODI.

  PO_EVENT->M_EVENT_HANDLED = ABAP_ON.

  READ TABLE GT_DISP INTO DATA(LS_DISP) INDEX PS_ROID-ROW_ID.

  CHECK SY-SUBRC = 0.

  CASE PV_FNAME.
    WHEN 'ARBPL'.
      PERFORM F4_ARBPL USING PS_ROID-ROW_ID
                       CHANGING LS_DISP.

    WHEN 'OPTYPE'.
      PERFORM F4_OPTYPE USING PS_ROID-ROW_ID
                       CHANGING LS_DISP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
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

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    10 ).             " Height

* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.
** bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
*& Event Handler 등록
  CREATE OBJECT GO_EVENT_HANDLER.

  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_BUTTON_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE
          FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
*& GENERAL DISPLAY OPTIONS
  CLEAR GS_LAYOUT_0100.
*  GS_LAYOUT_0100-CWIDTH_OPT = 'X'.
*  GS_LAYOUT_0100-EDIT      = 'X'.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_HEADERS = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWMARK = ABAP_TRUE.
*  GS_LAYOUT_0100-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0100-SMALLTITLE = 'X'.             "작은타이틀.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0100-CTAB_FNAME = 'CELLSCOL'.    "셀색상

*  PS_LAYOCAT-EDIT       = 'E'.
*  GS_LAYOUT_0100-NO_ROWMARK = ' '.           "선택버튼 비활성

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  PERFORM SET_FIELDCAT_FOR_RL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_RL .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP'
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
      IT_DATA         = GT_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
*    CLEAR : <ls_fcat>-EDIT .
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-COLTEXT = TEXT-F01. "상태
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-CHECKBOX  = 'X'.
        <LS_FCAT>-KEY     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'GRPNR'.
        <LS_FCAT>-COLTEXT = TEXT-F02.  "조장표번호
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-FIX_COLUMN = 'X'.
*        <ls_fcat>-emphasize = 'C510'.
        <LS_FCAT>-KEY     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.

*      WHEN 'VBELN'.
*        <ls_fcat>-coltext = TEXT-f03.  "판매오더
*        <ls_fcat>-col_pos = '3'.
*        <ls_fcat>-no_out  = ' '.
*        <ls_fcat>-edit    = ''.
*        <ls_fcat>-just    = 'L'.
**        <ls_fcat>-key     = 'X'.
**        <ls_fcat>-emphasize = 'C510'.
*        <ls_fcat>-fix_column = 'X'.
*        <ls_fcat>-outputlen  = '8'.

      WHEN 'VBELN_TXT'.
        <LS_FCAT>-COLTEXT = TEXT-F03.  "판매오더
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'L'.
*        <ls_fcat>-key     = 'X'.
*        <ls_fcat>-emphasize = 'C510'.
        <LS_FCAT>-FIX_COLUMN = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '13'.

      WHEN 'KUNNR'.
        <LS_FCAT>-COLTEXT = TEXT-F04.   "고객사코드
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '8'.
      WHEN 'NAME1'.
        <LS_FCAT>-COLTEXT = TEXT-F05.  " 납선
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '20'.
      WHEN 'EDATU'.
        <LS_FCAT>-COLTEXT = TEXT-F06.   " 납품요청일
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.


      WHEN 'MATNR_F'.
        <LS_FCAT>-COLTEXT = TEXT-F11.  "제품
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'L'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '8'.

      WHEN 'SUL_NO'.
        <LS_FCAT>-COLTEXT = TEXT-F07.   " 설계서번호
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'L'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '8'.

      WHEN 'REV_SEQ'.
        <LS_FCAT>-COLTEXT = TEXT-F08.  " Revision
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '3'.

      WHEN 'KV'.
        <LS_FCAT>-COLTEXT = TEXT-F12.   "KV
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '6'.
      WHEN 'SQ'.
        <LS_FCAT>-COLTEXT = TEXT-F13.  "SQ
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = ''.
        <LS_FCAT>-JUST    = 'C'.
*        <ls_fcat>-key     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '6'.

      WHEN 'GONG_SEQ'.
        <LS_FCAT>-COLTEXT = TEXT-F40.  "공정순서
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '5'.

      WHEN 'AUFNR_TXT'.
        <LS_FCAT>-COLTEXT = TEXT-F20.   "오더번호
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-INTLEN   = '30'.
        <LS_FCAT>-OUTPUTLEN  = '15'.



      WHEN 'SOSUN1'.
        <LS_FCAT>-COLTEXT = TEXT-F09.   "소선구성1
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '20'.

      WHEN 'SOSUN3'.
        <LS_FCAT>-COLTEXT = TEXT-F10.  "소선구성2
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '20'.


      WHEN 'MAKTX_F'.
        <LS_FCAT>-COLTEXT = TEXT-F14.   "제품명
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '20'.
*        <ls_fcat>-emphasize = 'C510'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-COLTEXT = TEXT-F60.   " 조장수
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-OUTPUTLEN  = '4'.
        <LS_FCAT>-DECIMALS_O = 0.

      WHEN 'NWMENG'.
        <LS_FCAT>-COLTEXT = TEXT-F15.   " 수주량  오더 총 수량
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'RWMENG'.
        <LS_FCAT>-COLTEXT = TEXT-F16.  "잔여수량
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-DECIMALS  = 2. " 소수점 자리수 설정
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.


*      WHEN 'MEINS'.
*        <ls_fcat>-coltext = TEXT-f17.   "수주단위
*        <ls_fcat>-col_pos = '19'.
*        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-edit   = ''.
*        <ls_fcat>-just      = 'C'.
*        <ls_fcat>-outputlen  = '3'.
      WHEN 'WEMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F18.  "입고수량
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'AMEIN'.
        <LS_FCAT>-COLTEXT = TEXT-F19.  "입고단위 -> 오더단위
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '3'.


      WHEN 'GONG_CD'.
        <LS_FCAT>-COLTEXT = TEXT-F21.  "공정코드
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-COLTEXT = TEXT-F22.   " 공정
        <LS_FCAT>-COL_POS = '23'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MAKTX_R'.
        <LS_FCAT>-COLTEXT = TEXT-F23.   " 자재내역
        <LS_FCAT>-COL_POS = '24'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '20'.
      WHEN 'GUBUN'.
        <LS_FCAT>-COLTEXT = TEXT-F43.   " 구분
        <LS_FCAT>-COL_POS = '25'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '10'.

      WHEN 'MATNR_R'.
        <LS_FCAT>-COLTEXT = TEXT-F24.  " 자재코드
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'JAJE_QTY'.
        <LS_FCAT>-COLTEXT = TEXT-F25.   "정미량
        <LS_FCAT>-COL_POS = '27'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'AUSCH'.
        <LS_FCAT>-COLTEXT = TEXT-F26.  "로스율
        <LS_FCAT>-COL_POS = '28'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-DECIMALS  = 2. " 소수점 자리수 설정
        <LS_FCAT>-JUST      = 'R'.
*        <ls_fcat>-f4availabl = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'ERFMG_SO'.
        <LS_FCAT>-COLTEXT = TEXT-F27.  "소요량(수주 기준)
        <LS_FCAT>-COL_POS = '29'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'ERFMG_RE'.
        <LS_FCAT>-COLTEXT = TEXT-F28.   "소요량(잔여 기준)
        <LS_FCAT>-COL_POS = '30'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'JAJE_UNIT'.
        <LS_FCAT>-COLTEXT = TEXT-F29.  "단위
        <LS_FCAT>-COL_POS = '31'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'PO_YN'.
        <LS_FCAT>-COLTEXT = TEXT-F30.   " 발주여부
        <LS_FCAT>-COL_POS = '32'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'BADAT'.
        <LS_FCAT>-COLTEXT = TEXT-F31.   "구매요청일
        <LS_FCAT>-COL_POS = '33'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'BANFN'.
        <LS_FCAT>-COLTEXT = TEXT-F32.  "PR 번호
        <LS_FCAT>-COL_POS = '34'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'BNFPO'.
        <LS_FCAT>-COLTEXT = TEXT-F33.   "PR Item 번호
        <LS_FCAT>-COL_POS = '35'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'MENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F34.  "PR 수량
        <LS_FCAT>-COL_POS = '36'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MEINS2'.
        <LS_FCAT>-COLTEXT = TEXT-F35.  "단위
        <LS_FCAT>-COL_POS = '37'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'LFDAT'.
        <LS_FCAT>-COLTEXT = TEXT-F36.   " 납기일
        <LS_FCAT>-COL_POS = '38'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'BIGO'.
        <LS_FCAT>-COLTEXT = TEXT-F42.   " 기타사항(메모)
        <LS_FCAT>-COL_POS = '39'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.



      WHEN 'EBELN'.
        <LS_FCAT>-COLTEXT = TEXT-F37.  " PO번호
        <LS_FCAT>-COL_POS = '40'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'EBELP'.
        <LS_FCAT>-COLTEXT = TEXT-F38.   " PO Item 번호
        <LS_FCAT>-COL_POS = '41'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'WEMNG2'.
        <LS_FCAT>-COLTEXT = TEXT-F39.   " 입고 수량
        <LS_FCAT>-COL_POS = '42'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.


      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_STYLE01  TYPE LVC_STYLE.
  DATA : LV_DATE TYPE SY-DATUM.
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_field>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_field2> IS ASSIGNED. UNASSIGN <lv_field2>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_field2>.
  END-OF-DEFINITION.

  DEFINE __SET_STYLE.
    CLEAR ls_celltab.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    ls_celltab-fieldname = lv_fieldname.
    ls_celltab-style = CONV #( &2 ).
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    REFRESH LT_CELLCOL.
    LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
      CASE <LS_FACT>-FIELDNAME.
        WHEN 'GRPNR' OR 'VBELN' OR 'VBELN_TXT' OR 'KUNNR' OR
             'NAME1' OR 'EDATU' OR 'MATNR_F' OR
             'SUL_NO' OR 'REV_SEQ' OR
             'KV' OR 'SQ'
             .
          CLEAR LS_CELLTAB.
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = <LS_FACT>-FIELDNAME.
          LS_CELLCOL-FNAME = LV_FIELDNAME.
          LS_CELLCOL-COLOR-COL = '4'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN 'GUBUN'.
          IF <LS_DATA>-GUBUN = '대체자재 지정'.
            CLEAR LS_CELLTAB.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = <LS_FACT>-FIELDNAME.
            LS_CELLCOL-FNAME = LV_FIELDNAME.
            LS_CELLCOL-COLOR-COL = '1'.
            LS_CELLCOL-COLOR-INT = '1'.
            LS_CELLCOL-COLOR-INV = '4'.
            LS_CELLCOL-NOKEYCOL  = ' '.
            INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
          ENDIF.

          IF <LS_DATA>-GUBUN = '기존 발주내역'.
            CLEAR LS_CELLTAB.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = <LS_FACT>-FIELDNAME.
            LS_CELLCOL-FNAME = LV_FIELDNAME.
            LS_CELLCOL-COLOR-COL = '1'.
            LS_CELLCOL-COLOR-INT = '1'.
            LS_CELLCOL-COLOR-INV = '4'.
            LS_CELLCOL-NOKEYCOL  = ' '.
            INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
          ENDIF.
        WHEN OTHERS." 'PO_YN'.
          IF <LS_DATA>-PO_YN = 'Y'.
            CLEAR LS_CELLTAB.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = <LS_FACT>-FIELDNAME.
            LS_CELLCOL-FNAME = LV_FIELDNAME.
            LS_CELLCOL-COLOR-COL = '5'.
            LS_CELLCOL-COLOR-INT = '0'.
            LS_CELLCOL-COLOR-INV = '0'.
            LS_CELLCOL-NOKEYCOL  = ' '.
            INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
          ENDIF.


      ENDCASE.
    ENDLOOP.

    IF <LS_DATA>-CHECK = ABAP_TRUE.

      LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FACT>.
        CASE <LS_FACT>-FIELDNAME.
          WHEN 'GRPNR' OR 'VBELN' OR 'VBELN_TXT' OR 'KUNNR' OR
               'NAME1' OR 'EDATU' OR 'MATNR_F' OR
               'SUL_NO' OR 'REV_SEQ' OR
               'KV' OR 'SQ'
               .
          WHEN 'PO_YN'.
            DELETE LT_CELLCOL WHERE FNAME = 'PO_YN'.
            CLEAR LS_CELLTAB.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = <LS_FACT>-FIELDNAME.
            LS_CELLCOL-FNAME = LV_FIELDNAME.
            LS_CELLCOL-COLOR-COL = '3'.
            LS_CELLCOL-COLOR-INT = '0'.
            LS_CELLCOL-COLOR-INV = '0'.
            LS_CELLCOL-NOKEYCOL  = ' '.
            INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
          WHEN OTHERS .
            DELETE LT_CELLCOL WHERE FNAME = <LS_FACT>-FIELDNAME.
            CLEAR LS_CELLTAB.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = <LS_FACT>-FIELDNAME.
            LS_CELLCOL-FNAME = LV_FIELDNAME.
            LS_CELLCOL-COLOR-COL = '3'.
            LS_CELLCOL-COLOR-INT = '0'.
            LS_CELLCOL-COLOR-INV = '0'.
            LS_CELLCOL-NOKEYCOL  = ' '.
            INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

        ENDCASE.
      ENDLOOP.
    ENDIF.

    MOVE-CORRESPONDING LT_CELLCOL TO <LS_DATA>-CELLSCOL.
*    INSERT LINES OF lt_cellcol INTO TABLE <ls_data>-cellScol.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

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
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
*                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

*  IF p_layo IS NOT INITIAL.
*    alv_variant-variant = p_layo.
*  ENDIF.
  ALV_VARIANT-REPORT = SY-REPID.
  ALV_VARIANT-USERNAME = SY-UNAME.


  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = ALV_VARIANT  " 선택, 메뉴 display
      I_SAVE               = 'A' "X  Global 레이아웃 세팅만 가능함
      "U  특정 사용자에 한해서 레이아웃 세팅만 가능함
      "A  X와 U 둘 다 가능함
      "SPACE('')  레이아웃 저장을 하지 않음.
    CHANGING
      IT_OUTTAB            = GT_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100
      IT_SORT              = GT_SORT.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.


** 인풋이벤트 추가
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_and_init_controls
*&---------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS .

  IF GO_GRID_0100 IS NOT BOUND.

    PERFORM SET_OBJECT_GRID_0100.

*& EDIT EVENT 및  EVENT HANDLER 등록
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
*& GRID 속성 지정(DISPLAY): DISPLAY시 옵션 지정
    PERFORM SET_LAYOUT_GRID_0100.
*
    PERFORM SET_F4.
*& 출력할 필드 속성을 정의
    PERFORM SET_FIELDCAT_GRID_0100.

    PERFORM SET_SORTTAB_GRID_0100.

    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.

    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.

    PERFORM CALL_GRID_0100_DISPLAY.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .
  REFRESH GT_SORT.

  PERFORM SET_SORT_TAB TABLES GT_SORT
                        USING : 1 'GRPNR'       'X' '' '',
                                2 'VBELN'       'X' '' '',
                                3 'KUNNR'       'X' '' '',
                                4 'NAME1'       'X' '' '',
                                5 'EDATU'       'X' '' '',
                                6 'MATNR_F'     'X' '' '',
                                7 'SUL_NO'      'X' '' '',
                                8 'REV_SEQ'     'X' '' '',
                                9 'KV'          'X' '' '',
                                10 'SQ'          'X' '' '',
                                11 'GONG_SEQ'    'X' '' '',
                                12 'AUFNR_T'    'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                            PV_FIELDNAME
                            PV_UP
                            PV_DOWN
                            PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_finished
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                  PV_MODI
                                  PT_MODI TYPE LVC_T_MODI.
*  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
*        LT_ROW_NO     TYPE LVC_T_ROID.
*
*  DATA: LS_INDEX_ROWS TYPE LVC_S_ROW,
*        LS_ROW_NO     TYPE LVC_S_ROID.
*
*  DATA :LS_MODI TYPE LVC_S_MODI.
*
*  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
*         LT_ROW_NO, LT_ROW_NO[].
*
*
*  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
*
*    LS_MODI-ROW_ID = SY-TABIX.
*
*    LS_INDEX_ROWS-INDEX = LS_MODI-ROW_ID.
*    APPEND LS_INDEX_ROWS TO LT_INDEX_ROWS.
*
*    LS_ROW_NO-ROW_ID = LS_MODI-ROW_ID.
*    APPEND LS_ROW_NO TO LT_ROW_NO.
*
*    PO_SENDER->SET_SELECTED_ROWS(
*      EXPORTING
*        IT_INDEX_ROWS = LT_INDEX_ROWS
*        IT_ROW_NO     = LT_ROW_NO ).
*
*    MODIFY GT_DISP INDEX LS_MODI-ROW_ID FROM GS_DISP .
*  ENDLOOP.

*  DATA : LT_CELLS TYPE LVC_T_CENO.
*  DATA : LT_CELLTAB TYPE LVC_T_STYL.
*  DATA : LS_CELLTAB TYPE LVC_S_STYL.
*  DATA : lt_cellcol TYPE lvc_t_scol.
*  DATA : ls_cellcol TYPE lvc_s_scol.
*  DATA : LV_FIELDNAME TYPE FIELDNAME.
*  DATA : LV_DATE TYPE SY-DATUM.
*  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
*  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

*  CLEAR: LT_CELLS[], LT_CELLS.
*
*  GO_GRID_0100->GET_SELECTED_CELLS_ID(
*      IMPORTING
*       ET_CELLS = LT_CELLS ).                " CELL IDS
*
*  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
*    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX LS_CELLS-ROW_ID.
*
*    <LS_DISP>-CHECK = ABAP_TRUE.
*
*  ENDLOOP.
*
*  CLEAR: LT_CELLS[], LT_CELLS.

*  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE CHECK = 'X' .
*    REFRESH LT_CELLTAB.
*    LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
*      CASE <LS_FACT>-FIELDNAME.
*        WHEN 'GRPNR' OR 'VBELN' OR 'KUNNR' OR
*             'NAME1' OR 'EDATU' OR 'MATNR_F' OR
*             'SUL_NO' OR 'REV_SEQ' OR
*             'KV' OR 'SQ'
*             .
*
*        WHEN OTHERS .
*        CLEAR LS_CELLTAB.
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = <LS_FACT>-FIELDNAME.
*        ls_cellcol-fname = LV_FIELDNAME.
*        ls_cellcol-color-col = '3'.
*        ls_cellcol-color-int = '0'.
*        ls_cellcol-color-inv = '0'.
*        ls_cellcol-nokeycol  = ' '.
*        INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*      ENDCASE.
*    ENDLOOP.
*
*    INSERT LINES OF lt_cellcol INTO TABLE <LS_DATA>-cellScol.
*
*  ENDLOOP.

*            화면 리프레쉬
*  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
