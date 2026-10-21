*&---------------------------------------------------------------------*
*& Include          ZGTPPR2320F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '이메일 수신관리'.
  GV_DYNTXT-QUICKINFO = '이메일 수신관리'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.


  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '(임시)품목별 판매량 등록'.
  GV_DYNTXT-QUICKINFO = '(임시)품목별 판매량 등록'.
  SSCRFIELDS-FUNCTXT_02 = GV_DYNTXT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW_01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MAINTAIN_VIEW_01 .

  PERFORM GET_INIT_DATA.

  REFRESH GT_MAINTAIN.
  CLEAR GV_CHK_EDIT_200.

  SELECT * FROM ZGTPPT3460
    INTO TABLE GT_3460
   WHERE CPROG = 'ZGTPPR2320'
     AND WERKS = P_WERKS
     AND SPGCD = P_SPGCD.

  SORT GT_3460 BY SEQNO.
  LOOP AT GT_3460 INTO DATA(LS_3460).
    CLEAR GS_MAINTAIN.
    MOVE-CORRESPONDING LS_3460 TO GS_MAINTAIN.
* 플랜트명
    GS_MAINTAIN-NAME1 = GV_NAME1.
* spg명
    GS_MAINTAIN-DESCR = GV_DESCR.

    APPEND GS_MAINTAIN TO GT_MAINTAIN.

  ENDLOOP.

  CALL SCREEN '0200'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW_02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MAINTAIN_VIEW_02 .

  PERFORM GET_INIT_DATA.

  REFRESH GT_MAINTAIN_300.
  CLEAR GV_CHK_EDIT_300.

  SELECT DISTINCT * FROM ZGTPPT3470
    INTO TABLE GT_3470
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD.

  SORT GT_3470 BY MATNR.
  LOOP AT GT_3470 INTO DATA(LS_3470).
    CLEAR GS_MAINTAIN_300.
    MOVE-CORRESPONDING LS_3470 TO GS_MAINTAIN_300.
* 플랜트명
    GS_MAINTAIN_300-NAME1 = GV_NAME1.
* spg명
    GS_MAINTAIN_300-DESCR = GV_DESCR.

* spg명
    GS_MAINTAIN_300-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_3470-MATNR ).

    APPEND GS_MAINTAIN_300 TO GT_MAINTAIN_300.

  ENDLOOP.

  CALL SCREEN '0300'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING   PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'ADDLINE' ICON_INSERT_ROW '라인추가' '라인추가' 0,
                                            'DELLINE' ICON_DELETE_ROW	 '라인삭제' '라인삭제' 0,
                                             '' '' '' '' 3,
                                            'SAVE' ICON_SAVE_AS_TEMPLATE '저장' '저장' 0.
    WHEN GO_GRID_0200.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'ADDLINE' ICON_INSERT_ROW '라인추가' '라인추가' 0,
                                            'DELLINE' ICON_DELETE_ROW	 '라인삭제' '라인삭제' 0,
                                             '' '' '' '' 3,
                                            'SAVE' ICON_SAVE_AS_TEMPLATE '저장' '저장' 0.
    WHEN GO_GRID_0300.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'ADDLINE' ICON_INSERT_ROW '라인추가' '라인추가' 0,
                                            'DELLINE' ICON_DELETE_ROW	 '라인삭제' '라인삭제' 0,
                                             '' '' '' '' 3,
                                            'SAVE' ICON_SAVE_AS_TEMPLATE '저장' '저장' 0.
    WHEN GO_GRID_0400.
      CASE GV_ZTYPE.
        WHEN 'A'.
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                     USING : 'EXCUTE' '' '오더 생성' '오더 생성' 0.
        WHEN 'B'.
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                     USING : 'EXCUTE' '' '생산오더 생성' '생산오더 생성' 0.
      ENDCASE.
  ENDCASE.

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
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE ' '  PV_TEXT ' '  INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING     PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'ADDLINE'.
          PERFORM PROC_ADDLINE.
        WHEN 'DELLINE'.
          PERFORM PROC_DELLINE.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE.
      ENDCASE.
    WHEN GO_GRID_0200.
      CASE PV_UCOMM.
        WHEN 'ADDLINE'.
          PERFORM PROC_ADDLINE_0200.
        WHEN 'DELLINE'.
          PERFORM PROC_DELLINE_0200.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE_0200.
      ENDCASE.
    WHEN GO_GRID_0300.
      CASE PV_UCOMM.
        WHEN 'ADDLINE'.
          PERFORM PROC_ADDLINE_0300.
        WHEN 'DELLINE'.
          PERFORM PROC_DELLINE_0300.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE_0300.
      ENDCASE.
    WHEN GO_GRID_0400.
      CASE PV_UCOMM.
        WHEN 'EXCUTE'. " 오더생성
          PERFORM PROC_EXCUTE_0400.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
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

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_MEINS TYPE MEINS.
  DATA : LV_MAKTX TYPE MAKT-MAKTX.
  DATA : LS_MTVAL TYPE ZGTCVMSTVAL.
  DATA : LV_CHK_ERR.
  DATA : LV_MATNR TYPE MATNR.

  DATA : LV_CHK_CHANGE_0400.
  DATA : LV_CHK_CHANGE_0300.
  DATA : LV_CHK_CHANGE_0100.

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
  END-OF-DEFINITION.

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

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      GV_CHK_EDIT_100 = ABAP_TRUE.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECK'.
            LV_CHK_CHANGE_0100 = ABAP_TRUE.
          WHEN 'MATNR'.
            IF LS_MOD_CELLS-VALUE IS INITIAL.
              CLEAR LV_MAKTX.
              CLEAR LV_MEINS.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MAKTX' LV_MAKTX.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MEINS' LV_MEINS.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZZCOLOR_BASE' LS_MTVAL-COLORBASE.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZZSPEC_NO' LS_MTVAL-PDCASPECNO.
            ELSE.
              CLEAR LV_MAKTX.
              CLEAR LV_MEINS.

              PERFORM VALIDATION_MATNR USING LS_MOD_CELLS-VALUE CHANGING LV_MAKTX LV_MEINS LV_CHK_ERR.
              IF LV_CHK_ERR IS INITIAL.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'MAKTX' LV_MAKTX.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'MEINS' LV_MEINS.
                LV_MATNR = LS_MOD_CELLS-VALUE.
                CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                  EXPORTING
                    INPUT        = LV_MATNR
                  IMPORTING
                    OUTPUT       = LV_MATNR
                  EXCEPTIONS
                    LENGTH_ERROR = 1.

                SELECT SINGLE * FROM ZGTCVMSTVAL
                  INTO LS_MTVAL
                 WHERE WERKS = P_WERKS
                   AND MATNR = LV_MATNR.

                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZZCOLOR_BASE' LS_MTVAL-COLORBASE.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ZZSPEC_NO' LS_MTVAL-PDCASPECNO.
              ELSE.
                __SET_ERR_MSG '유효하지 않은 품목입니다.' LS_MOD_CELLS-FIELDNAME.
              ENDIF.
            ENDIF.

            LV_CHK_CHANGE_0300 = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.

    WHEN GO_GRID_0200.
      GV_CHK_EDIT_200 = ABAP_TRUE.
    WHEN GO_GRID_0300.
      GV_CHK_EDIT_300 = ABAP_TRUE.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MATNR'.
            IF LS_MOD_CELLS-VALUE IS INITIAL.
              CLEAR LV_MAKTX.
              CLEAR LV_MEINS.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MAKTX' LV_MAKTX.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MEINS' LV_MEINS.
            ELSE.
              CLEAR LV_MAKTX.
              CLEAR LV_MEINS.

              PERFORM VALIDATION_MATNR USING LS_MOD_CELLS-VALUE CHANGING LV_MAKTX LV_MEINS LV_CHK_ERR.
              IF LV_CHK_ERR IS INITIAL.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'MAKTX' LV_MAKTX.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'MEINS' LV_MEINS.
              ELSE.
                __SET_ERR_MSG '유효하지 않은 품목입니다.' LS_MOD_CELLS-FIELDNAME.
              ENDIF.
            ENDIF.

            LV_CHK_CHANGE_0300 = ABAP_TRUE.

        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ELSE.
    IF LV_CHK_CHANGE_0100 = ABAP_TRUE.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'REFRESH'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.

    ENDIF.

    IF LV_CHK_CHANGE_0300 = ABAP_TRUE.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'REFRESH'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADDLINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADDLINE_0200 .

  DATA : LV_SEQNO(4) TYPE N.
  DATA : LS_MAIN LIKE GS_MAINTAIN.

  DATA(LT_MAIN) = GT_MAINTAIN.
  SORT LT_MAIN BY SEQNO DESCENDING.
  READ TABLE LT_MAIN INTO DATA(LS_MAIN_TMP) INDEX 1.
  IF SY-SUBRC EQ 0.
    LV_SEQNO = LS_MAIN_TMP-SEQNO + 1.
  ELSE.
    LV_SEQNO = 1.
  ENDIF.

  LS_MAIN-CPROG = 'ZGTPPR2320'.
  LS_MAIN-WERKS = P_WERKS.
  LS_MAIN-NAME1 = GV_NAME1.
  LS_MAIN-SPGCD = P_SPGCD.
  LS_MAIN-DESCR = GV_DESCR.
  LS_MAIN-SEQNO = LV_SEQNO.
  LS_MAIN-STATUS = 'N'.

  APPEND LS_MAIN TO GT_MAINTAIN.

  PERFORM REFRESH_GRID USING GO_GRID_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    WHEN GO_GRID_0200.
      GO_GRID_0200->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0200 ).
    WHEN GO_GRID_0300.
      GO_GRID_0300->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0300 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0300.
    WHEN GO_GRID_0400.
      GO_GRID_0400->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0400 ).

  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELLINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELLINE_0200 .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0200->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(E01).
    RETURN.
  ENDIF.

* 딜리트는 인덱스 역순으로 처리
  SORT   LT_ROWS BY INDEX DESCENDING.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    DELETE GT_MAINTAIN INDEX LS_ROWS-INDEX.
  ENDLOOP.

  GV_CHK_EDIT_200 = ABAP_TRUE.
  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_0200 .

  DATA : LV_CHK_ERR.
  DATA : LT_CHG_3460 TYPE TABLE OF ZGTPPT3460.
  DATA : LV_SEQNO(4) TYPE N.

  PERFORM CHK_BEFORE_SAVE_0200 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO LT_CHG_3460 ASSIGNING FIELD-SYMBOL(<LS_3460>).
    MOVE-CORRESPONDING LS_MAIN TO <LS_3460>.

    IF LS_MAIN-STATUS = 'N'. " 신규 입력 라인
      MOVE : SY-DATUM TO <LS_3460>-CRDAT,
                SY-UZEIT TO <LS_3460>-CRTIM,
                SY-UNAME TO <LS_3460>-CRNAM,
                SY-DATUM TO <LS_3460>-CHDAT,
                SY-UZEIT TO <LS_3460>-CHTIM,
                SY-UNAME TO <LS_3460>-CHNAM.
    ELSE.
      READ TABLE GT_3460 INTO DATA(LS_3460) WITH KEY SEQNO = LS_MAIN-SEQNO.
      IF SY-SUBRC EQ 0.
        MOVE : LS_3460-CRDAT TO <LS_3460>-CRDAT,
                LS_3460-CRTIM TO <LS_3460>-CRTIM,
                LS_3460-CRNAM TO <LS_3460>-CRNAM,
                SY-DATUM TO <LS_3460>-CHDAT,
                SY-UZEIT TO <LS_3460>-CHTIM,
                SY-UNAME TO <LS_3460>-CHNAM.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT LT_CHG_3460 BY SEQNO.
  LOOP AT LT_CHG_3460 ASSIGNING <LS_3460>.
    ADD 1 TO LV_SEQNO.
    <LS_3460>-SEQNO = LV_SEQNO.
  ENDLOOP.

  IF GT_3460[] IS NOT INITIAL.
    DELETE ZGTPPT3460 FROM TABLE GT_3460.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '수신자 관리 테이블 저장중 오류 발생하였습니다.'(e07).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_CHG_3460 IS NOT INITIAL.
    MODIFY ZGTPPT3460 FROM TABLE LT_CHG_3460.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '수신자 관리 테이블 저장중 오류 발생하였습니다.'(e07).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  PERFORM REFRESH_GRID USING GO_GRID_0200.
  CLEAR GV_CHK_EDIT_200.
  MESSAGE S006 WITH '데이터 저장 완료 되었습니다.'(e08).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SAVE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SAVE_0200  CHANGING PV_CHK_ERR.

  IF GT_MAINTAIN[] IS INITIAL AND GT_3460 IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '저장할 수 있는 데이터가 없습니다'(e02).
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN INTO DATA(LS_MAIN).
    IF LS_MAIN-ACTIVE = ABAP_TRUE.
      IF LS_MAIN-NAME IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 성명이 비어있습니다.'(e03).
        RETURN.
      ENDIF.

      IF LS_MAIN-MAIL_TYPE IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 수신 구분이 비어있습니다.'(e04).
        RETURN.
      ENDIF.

      IF LS_MAIN-DEPT IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 부서가 비어있습니다.'(e05).
        RETURN.
      ENDIF.

      IF LS_MAIN-MAIL_ADDR IS INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '활성 체크된 라인에 이메일 주소가 비어있습니다.'(e06).
        RETURN.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT_DATA .

  GV_DISPO = P_SPGCD && '%'. "

* 플랜트명
  CLEAR GV_NAME1.
  GV_NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME( IV_WERKS = P_WERKS ).

* SPG명
  CLEAR GV_DESCR.
  SELECT SINGLE DESCR INTO GV_DESCR
         FROM ZPPT0107
        WHERE SPGCD EQ P_SPGCD.

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
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0300 .

  CREATE OBJECT GO_CONTAIN_0300
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

  CREATE OBJECT GO_GRID_0300
    EXPORTING
      I_PARENT      = GO_CONTAIN_0300
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0300 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.

  CLEAR GS_LAYOUT_0300.
  GS_LAYOUT_0300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0300-SEL_MODE   = 'D'.
  GS_LAYOUT_0300-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0300-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT1 SEPARATED BY SPACE.
  LV_TEXT1 = LV_TEXT1 && ','.

  CLEAR LV_TEXT2.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT2 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 INTO GS_LAYOUT_0300-GRID_TITLE SEPARATED BY SPACE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0300 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2320TOP'
      I_INTERNAL_TABNAME     = 'GS_MAINTAIN_300'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0300[]
    TABLES
      IT_DATA         = GT_MAINTAIN_300
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'STATUS'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'STATUS'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 20.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.

  ENDIF.


  LOOP AT GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG 내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F10).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F11).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'M01_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.01(총판매)'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M02_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.02(총판매)'(F13).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M03_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.03(총판매)'(F14).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M04_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.04(총판매)'(F15).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M05_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.05(총판매)'(F16).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M06_TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.06(총판매)'(F17).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M01_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.01(SM판매)'(F18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M02_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.02(SM판매)'(F19).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M03_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.03(SM판매)'(F20).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M04_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.04(SM판매)'(F21).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M05_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.05(SM판매)'(F22).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'M06_SM_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '2026.06(SM판매)'(F23).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(F24).
        <LS_FCAT>-JUST = 'C'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0300 .

  REFRESH GT_EXCLUDE_0300.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0300
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0300_DISPLAY .

  CALL METHOD GO_GRID_0300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0300
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0300
    CHANGING
      IT_OUTTAB            = GT_MAINTAIN_300
      IT_FIELDCATALOG      = GT_FIELDCAT_0300.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0300 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT GT_MAINTAIN_300 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.
    IF <LS_MAIN>-STATUS IS INITIAL.
      CLEAR LS_CELLTAB.
      LS_CELLTAB-FIELDNAME = 'MATNR'.
      LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
      INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_0300 .

  DATA : LV_CHK_ERR.
  DATA : LT_CHG_3470 TYPE TABLE OF ZGTPPT3470.

  PERFORM CHK_BEFORE_SAVE_0300 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN_300 INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO LT_CHG_3470 ASSIGNING FIELD-SYMBOL(<LS_3470>).
    MOVE-CORRESPONDING LS_MAIN TO <LS_3470>.

    IF LS_MAIN-STATUS = 'N'. " 신규 입력 라인
      MOVE : SY-DATUM TO <LS_3470>-CRDAT,
                SY-UZEIT TO <LS_3470>-CRTIM,
                SY-UNAME TO <LS_3470>-CRNAM,
                SY-DATUM TO <LS_3470>-CHDAT,
                SY-UZEIT TO <LS_3470>-CHTIM,
                SY-UNAME TO <LS_3470>-CHNAM.
    ELSE.
      READ TABLE GT_3470 INTO DATA(LS_3470) WITH KEY MATNR = LS_MAIN-MATNR.
      IF SY-SUBRC EQ 0.
        MOVE : LS_3470-CRDAT TO <LS_3470>-CRDAT,
                LS_3470-CRTIM TO <LS_3470>-CRTIM,
                LS_3470-CRNAM TO <LS_3470>-CRNAM,
                SY-DATUM TO <LS_3470>-CHDAT,
                SY-UZEIT TO <LS_3470>-CHTIM,
                SY-UNAME TO <LS_3470>-CHNAM.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF GT_3470[] IS NOT INITIAL.
    DELETE ZGTPPT3470 FROM TABLE GT_3470.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '(임시) 품목별 판매량 등록 테이블 저장중 오류 발생하였습니다.'(e11).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_CHG_3470 IS NOT INITIAL.
    MODIFY ZGTPPT3470 FROM TABLE LT_CHG_3470.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '(임시) 품목별 판매량 등록 테이블 저장중 오류 발생하였습니다.'(e11).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  LOOP AT GT_MAINTAIN_300 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR <LS_MAIN>-STATUS.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0300.
  CLEAR GV_CHK_EDIT_300.
  MESSAGE S006 WITH '데이터 저장 완료 되었습니다.'(e08).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_0300 .

  DATA : LT_F4 TYPE LVC_T_F4,
         LS_F4 TYPE LVC_S_F4.

  CLEAR : LT_F4.

  LS_F4-FIELDNAME = 'MATNR'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_0300->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM ALV_ONF4  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        PV_FIELDNAME TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO  TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS TYPE LVC_T_MODI
                        PV_DISPLAY TYPE CHAR01.

  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.


  CASE PO_SENDER.

    WHEN GO_GRID_0100.
      CASE PV_FIELDNAME.
        WHEN 'MATNR'.
          PERFORM F4_MATNR USING PV_FIELDNAME PS_ROW_NO
                                   CHANGING PV_FIELDVALUE.

          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.   "스탠다드 F4는 무시
          IF PV_FIELDVALUE IS INITIAL.
            RETURN.
          ENDIF.

          ASSIGN PR_EVENT_DATA->M_DATA->* TO <LT_DATA>.
          APPEND INITIAL LINE TO <LT_DATA> ASSIGNING FIELD-SYMBOL(<FS_F4>).
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PS_ROW_NO-ROW_ID.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDNAME.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDVALUE.
          ENDIF.

      ENDCASE.
    WHEN GO_GRID_0300.
      CASE PV_FIELDNAME.
        WHEN 'MATNR'.
          PERFORM F4_MATNR USING PV_FIELDNAME PS_ROW_NO
                                   CHANGING PV_FIELDVALUE.

          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.   "스탠다드 F4는 무시
          IF PV_FIELDVALUE IS INITIAL.
            RETURN.
          ENDIF.

          ASSIGN PR_EVENT_DATA->M_DATA->* TO <LT_DATA>.
          APPEND INITIAL LINE TO <LT_DATA> ASSIGNING <FS_F4>.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PS_ROW_NO-ROW_ID.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDNAME.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDVALUE.
          ENDIF.

      ENDCASE.

    WHEN GO_GRID_0400.
      CASE PV_FIELDNAME.
        WHEN 'ARBPL'.
          PERFORM F4_ARBPL USING PV_FIELDNAME PS_ROW_NO
                                   CHANGING PV_FIELDVALUE.

          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.   "스탠다드 F4는 무시
          IF PV_FIELDVALUE IS INITIAL.
            RETURN.
          ENDIF.

          ASSIGN PR_EVENT_DATA->M_DATA->* TO <LT_DATA>.
          APPEND INITIAL LINE TO <LT_DATA> ASSIGNING <FS_F4>.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PS_ROW_NO-ROW_ID.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDNAME.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDVALUE.
          ENDIF.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      --> PS_ROW_NO
*&      <-- PV_FIELDVALUE
*&---------------------------------------------------------------------*
FORM F4_MATNR  USING    PV_FIELDNAME TYPE LVC_FNAME
                             PS_ROW_NO  TYPE LVC_S_ROID
               CHANGING PV_FIELDVALUE TYPE LVC_VALUE.

  DATA : BEGIN OF LS_TABLE,
           MATNR LIKE MARC-MATNR,
           MAKTX LIKE MAKT-MAKTX,
         END OF LS_TABLE.
  DATA : LT_TABLE LIKE TABLE OF LS_TABLE.
  DATA : LV_FIELDNAME TYPE  LVC_FNAME.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_DISPO TYPE MARC-DISPO.

  LV_DISPO = P_SPGCD && '%'. "

* 조회조건의 자재와 자내내역을 조합하여 추출 자재범위 세팅
  SELECT A~MATNR, B~MAKTX
    FROM MARC AS A
    INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
    INNER JOIN MARA AS C ON C~MATNR = A~MATNR
    INNER JOIN T134 AS D ON D~MTART = C~MTART
   WHERE A~WERKS = @P_WERKS
      AND A~LVORM = ' '
      AND A~DISPO LIKE @LV_DISPO
      AND D~MTREF = 'FERT'
    INTO CORRESPONDING FIELDS OF TABLE @LT_TABLE.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = PV_FIELDNAME
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'MATNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '품목조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_TABLE                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  PV_FIELDVALUE = LS_RETURN_TAB-FIELDVAL.   "F4에서 선택한 값을 다시 넣어줌

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADDLINE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADDLINE_0300 .

  DATA : LS_MAIN LIKE GS_MAINTAIN_300.
  GV_CHK_EDIT_300 = ABAP_TRUE.

  LS_MAIN-WERKS = P_WERKS.
  LS_MAIN-NAME1 = GV_NAME1.
  LS_MAIN-SPGCD = P_SPGCD.
  LS_MAIN-DESCR = GV_DESCR.
  LS_MAIN-STATUS = 'N'.

  APPEND LS_MAIN TO GT_MAINTAIN_300.

  PERFORM REFRESH_GRID USING GO_GRID_0300.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELLINE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELLINE_0300 .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0300->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(E01).
    RETURN.
  ENDIF.

* 딜리트는 인덱스 역순으로 처리
  SORT   LT_ROWS BY INDEX DESCENDING.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    DELETE GT_MAINTAIN_300 INDEX LS_ROWS-INDEX.
  ENDLOOP.

  GV_CHK_EDIT_300 = ABAP_TRUE.
  PERFORM REFRESH_GRID USING GO_GRID_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SAVE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SAVE_0300  CHANGING PV_CHK_ERR.

  IF GT_MAINTAIN_300[] IS INITIAL AND GT_3470 IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '저장할 수 있는 데이터가 없습니다'(e02).
    RETURN.
  ENDIF.

  LOOP AT GT_MAINTAIN_300 INTO DATA(LS_MAIN).
    IF LS_MAIN-MATNR IS INITIAL.
      PV_CHK_ERR = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '자재가 입력되지 않은 라인이 존재합니다.'(e09).
      RETURN.
    ENDIF.
  ENDLOOP.

  DATA(LT_CHK_MATNR) = GT_MAINTAIN_300.
  SORT LT_CHK_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING MATNR.
  IF SY-SUBRC EQ 0.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '중복된 자재가 존재합니다.'(e10).
    RETURN.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LV_MAKTX
*&      <-- LV_MEINS
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM VALIDATION_MATNR  USING    PV_VALUE
                       CHANGING PV_MAKTX TYPE MAKT-MAKTX
                                PV_MEINS TYPE MARA-MEINS
                                PV_CHK_ERR.

  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_DISPO TYPE MARC-DISPO.

  LV_DISPO = P_SPGCD && '%'. "

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_VALUE
    IMPORTING
      OUTPUT       = LV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  CASE GV_ZTYPE.
    WHEN 'A'.

      SELECT SINGLE B~MAKTX, C~MEINS
        FROM MARC AS A
        INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
        INNER JOIN MARA AS C ON C~MATNR = A~MATNR
        INNER JOIN T134 AS D ON D~MTART = C~MTART
       WHERE A~MATNR = @LV_MATNR
          AND A~WERKS = @P_WERKS
          AND A~LVORM = ' '
          AND A~DISPO LIKE @LV_DISPO
          AND ( C~MTART = 'MCHA'
           OR D~MTREF = 'FERT' )
        INTO ( @PV_MAKTX, @PV_MEINS ).

    WHEN 'B'.
      SELECT SINGLE B~MAKTX, C~MEINS
        FROM MARC AS A
        INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
        INNER JOIN MARA AS C ON C~MATNR = A~MATNR
       WHERE A~MATNR = @LV_MATNR
          AND A~WERKS = @P_WERKS
          AND A~LVORM = ' '
          AND A~DISPO LIKE @LV_DISPO
        INTO ( @PV_MAKTX, @PV_MEINS ).

    WHEN OTHERS.

      SELECT SINGLE B~MAKTX, C~MEINS
        FROM MARC AS A
        INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
        INNER JOIN MARA AS C ON C~MATNR = A~MATNR
        INNER JOIN T134 AS D ON D~MTART = C~MTART
       WHERE A~MATNR = @LV_MATNR
          AND A~WERKS = @P_WERKS
          AND A~LVORM = ' '
          AND A~DISPO LIKE @LV_DISPO
          AND ( C~MTART = 'MCHA'
           OR D~MTREF = 'FERT' )
        INTO ( @PV_MAKTX, @PV_MEINS ).

  ENDCASE.

  IF SY-SUBRC EQ 0 AND PV_MAKTX IS NOT INITIAL AND PV_MEINS IS NOT INITIAL.
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  PERFORM GET_INIT_DATA.

  CASE ABAP_TRUE.
    WHEN P_RAD21.
      GV_ZTYPE = 'A'.
    WHEN P_RAD22.
      GV_ZTYPE = 'B'.
  ENDCASE.

  CASE ABAP_TRUE.
    WHEN P_RAD11. " 품목정보 등록
      PERFORM MAKE_REGIST_MATNR.
    WHEN P_RAD12.  "생산오더 생성
      PERFORM MAKE_CRT_ORDER_INFO.
    WHEN P_RAD13.   " 생성 결과조회
      PERFORM MAKE_RESULT.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_REGIST_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ZTYPE
*&---------------------------------------------------------------------*
FORM MAKE_REGIST_MATNR.

  REFRESH GT_MAIN_REGEIST.
  DATA : LT_MATNR TYPE RANGE OF MATNR.

  CASE GV_ZTYPE.
    WHEN 'A'.
      SELECT DISTINCT A~MATNR, A~ZZSPEC_NO, A~ZZCOLOR_BASE, A~MEINS, A~MTART
        FROM MARC AS B
        INNER JOIN MARA AS A ON A~MATNR = B~MATNR
        INNER JOIN T134 AS C ON C~MTART = A~MTART
        INTO TABLE @DATA(LT_MOSU)
       WHERE B~WERKS = @P_WERKS
         AND B~MATNR IN @S_MATNR
         AND B~DISPO LIKE @GV_DISPO
         AND B~LVORM = ' '
        AND ( A~MTART = 'MCHA'
         OR C~MTREF = 'FERT' ).

      LT_MATNR = VALUE #( FOR LW_MOSU IN LT_MOSU WHERE ( MATNR IS NOT INITIAL )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MOSU-MATNR ) ).

      IF LT_MATNR[] IS NOT INITIAL.
        SORT LT_MATNR BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

        SELECT * FROM ZGTPPT3480
          INTO TABLE GT_3480
         WHERE WERKS = P_WERKS
            AND SPGCD = P_SPGCD
            AND MATNR IN LT_MATNR
            AND ZTYPE = GV_ZTYPE.
      ENDIF.

* 화면 구성 테이블
      LOOP AT LT_MOSU INTO DATA(LS_MOSU).
        CLEAR GS_MAIN_REGEIST.
        MOVE-CORRESPONDING LS_MOSU TO GS_MAIN_REGEIST.
        GS_MAIN_REGEIST-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_REGEIST-MATNR ).
        IF LS_MOSU-MTART = 'MCHA'.
          GS_MAIN_REGEIST-IN_OUT = 'F'.
        ENDIF.

        READ TABLE GT_3480 INTO DATA(LS_3480) WITH KEY MATNR = GS_MAIN_REGEIST-MATNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_REGEIST-CHECK = ABAP_TRUE.
          GS_MAIN_REGEIST-SFTST = LS_3480-SFTST.
          GS_MAIN_REGEIST-SFTRT = LS_3480-SFTRT.
          GS_MAIN_REGEIST-ROPRT = LS_3480-ROPRT.
          GS_MAIN_REGEIST-LENGTH = LS_3480-LENGTH.
          GS_MAIN_REGEIST-IN_OUT = LS_3480-IN_OUT.
        ENDIF.

        APPEND GS_MAIN_REGEIST TO GT_MAIN_REGEIST.
      ENDLOOP.

      SORT GT_MAIN_REGEIST BY CHECK DESCENDING MATNR.

    WHEN 'B'.
      SELECT DISTINCT A~*
        FROM ZGTPPT3480 AS A
        INNER JOIN MARC AS B ON B~MATNR = A~MATNR
                                   AND B~WERKS = A~WERKS
          INTO TABLE @GT_3480
         WHERE A~WERKS = @P_WERKS
            AND A~SPGCD = @P_SPGCD
            AND A~MATNR IN @S_MATNR
            AND A~ZTYPE = @GV_ZTYPE.

      LOOP AT GT_3480 INTO LS_3480.
        CLEAR GS_MAIN_REGEIST.
        GS_MAIN_REGEIST-MATNR = LS_3480-MATNR.
        GS_MAIN_REGEIST-SEQNO = LS_3480-SEQNO.
        GS_MAIN_REGEIST-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_REGEIST-MATNR ).
        GS_MAIN_REGEIST-LENGTH = LS_3480-LENGTH.
* 기본단위
        SELECT SINGLE MEINS FROM MARA
          INTO GS_MAIN_REGEIST-MEINS
         WHERE MATNR = GS_MAIN_REGEIST-MATNR.

        APPEND GS_MAIN_REGEIST TO GT_MAIN_REGEIST.

      ENDLOOP.

* 순번 재적용
      DATA : LV_SEQNO TYPE N LENGTH 4.
      SORT GT_MAIN_REGEIST BY SEQNO MATNR.

      LOOP AT GT_MAIN_REGEIST ASSIGNING FIELD-SYMBOL(<LS_MAIN_REGEIST>).
        ADD 1 TO LV_SEQNO.
        <LS_MAIN_REGEIST>-SEQNO = LV_SEQNO.

      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  DATA: LT_EXCL TYPE TABLE OF SY-UCOMM.
  APPEND 'FC01' TO LT_EXCL.
  APPEND 'FC02' TO LT_EXCL.

  LOOP AT SCREEN.
    CASE ABAP_TRUE.
      WHEN P_RAD11.

        IF SCREEN-GROUP1 = 'S01'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'S03'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_RAD12.
        IF SCREEN-GROUP1 = 'S03'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_RAD13.
        IF SCREEN-GROUP1 = 'S02'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'S01'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  CASE ABAP_TRUE.
    WHEN P_RAD11.
      REFRESH LT_EXCL.
      CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
        EXPORTING
          P_STATUS  = SY-PFKEY
        TABLES
          P_EXCLUDE = LT_EXCL.

    WHEN OTHERS.
      CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
        EXPORTING
          P_STATUS  = SY-PFKEY
        TABLES
          P_EXCLUDE = LT_EXCL.
  ENDCASE.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISPLAY .

  CASE ABAP_TRUE.
    WHEN P_RAD11. " 품목정보 등록
      CALL SCREEN '0100'.
    WHEN P_RAD12.  "생산오더 생성
      IF P_BATCH = ABAP_TRUE.
        PERFORM PROC_EXCUTE_0400.
      ELSE.
        CALL SCREEN '0400'.
      ENDIF.

    WHEN P_RAD13.   " 생성 결과조회
      CALL SCREEN '0500'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_CONTAIN_0100
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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.
  DATA : LV_TEXT3 TYPE CHAR100.

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0100-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CASE GV_ZTYPE.
    WHEN 'A'.
      LV_TEXT1 = '생산오더 유형 : A　MTS,'.
    WHEN 'B'.
      LV_TEXT1 = '생산오더 유형 : B　구다이스,'.
  ENDCASE.

  CLEAR LV_TEXT2.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT2 SEPARATED BY SPACE.
  LV_TEXT2 = LV_TEXT2 && ','.

  CLEAR LV_TEXT3.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT3 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 LV_TEXT3 INTO GS_LAYOUT_0100-GRID_TITLE SEPARATED BY SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2320TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_REGEIST'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_REGEIST
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'MTS 선정여부'(F25).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.

  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'STATUS'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'STATUS'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 11.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.

  ENDIF.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F10).
        <LS_FCAT>-JUST = 'C'.
        IF GV_ZTYPE = 'A'.
          <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        ENDIF.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F11).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SEQNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(F43).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ZZSPEC_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Spec No'(F26).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZCOLOR_BASE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IN_OUT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자작/외주'(F45).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'SFTST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '안전재고'(F28).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'SFTRT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '안전재고비율'(F29).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ROPRT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'ROP비율'(F30).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'LENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장단위'(F31).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(F24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'MTS 선정여부'(F25).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  IF GV_ZTYPE = 'B'.
    LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'CHECK' OR 'ZZSPEC_NO' OR 'ZZCOLOR_BASE' OR 'SFTST' OR 'SFTRT' OR 'ROPRT' OR 'IN_OUT'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN 'SEQNO'.
          CLEAR <LS_FCAT>-NO_OUT.
      ENDCASE.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_0100 .

  CHECK GV_ZTYPE = 'A'.

  DATA : LT_F4 TYPE LVC_T_F4,
         LS_F4 TYPE LVC_S_F4.

  CLEAR : LT_F4.

  LS_F4-FIELDNAME = 'MATNR'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_0100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  CHECK GV_ZTYPE = 'A'.

  LOOP AT GT_MAIN_REGEIST ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    IF <LS_MAIN>-CHECK = ABAP_TRUE AND
       <LS_MAIN>-STATUS = ''.
      CLEAR LS_CELLTAB.
      LS_CELLTAB-FIELDNAME = 'MATNR'.
      LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
      INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  REFRESH GT_EXCLUDE_0100.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
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
      IT_OUTTAB            = GT_MAIN_REGEIST
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
*& Form PROC_ADDLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADDLINE .

  DATA : LV_SEQNO(4) TYPE N.
  DATA : LS_MAIN LIKE GS_MAIN_REGEIST.

  LS_MAIN-STATUS = 'N'.

  INSERT LS_MAIN INTO GT_MAIN_REGEIST INDEX 1.

*  APPEND LS_MAIN TO GT_MAIN_REGEIST.

  GV_CHK_EDIT_100 = ABAP_TRUE.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELLINE .

  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                " Indexes of Selected Rows
*      ET_ROW_NO     =                  " Numeric IDs of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(E01).
    RETURN.
  ENDIF.

* 딜리트는 인덱스 역순으로 처리
  SORT   LT_ROWS BY INDEX DESCENDING.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    DELETE GT_MAIN_REGEIST INDEX LS_ROWS-INDEX.
  ENDLOOP.

  GV_CHK_EDIT_100 = ABAP_TRUE.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE .

  DATA : LV_CHK_ERR.
  DATA : LT_CHG_3480 TYPE TABLE OF ZGTPPT3480.
  DATA : LV_SEQNO(4) TYPE N.

  PERFORM CHK_BEFORE_SAVE CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '데이터 저장을 하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CASE GV_ZTYPE.
    WHEN 'A'.
* MTS 선정여부 체크된 필드만 저장 대상
      LOOP AT GT_MAIN_REGEIST INTO DATA(LS_MAIN) WHERE CHECK = ABAP_TRUE.
        APPEND INITIAL LINE TO LT_CHG_3480 ASSIGNING FIELD-SYMBOL(<LS_3480>).
        MOVE-CORRESPONDING LS_MAIN TO <LS_3480>.

        MOVE : P_WERKS TO <LS_3480>-WERKS,
                   P_SPGCD TO <LS_3480>-SPGCD,
                   GV_ZTYPE TO <LS_3480>-ZTYPE.

        IF LS_MAIN-STATUS = 'N'. " 신규 입력 라인
          MOVE : SY-DATUM TO <LS_3480>-CRDAT,
                    SY-UZEIT TO <LS_3480>-CRTIM,
                    SY-UNAME TO <LS_3480>-CRNAM,
                    SY-DATUM TO <LS_3480>-CHDAT,
                    SY-UZEIT TO <LS_3480>-CHTIM,
                    SY-UNAME TO <LS_3480>-CHNAM.
        ELSE.
          READ TABLE GT_3480 INTO DATA(LS_3480) WITH KEY MATNR = LS_MAIN-MATNR.
          IF SY-SUBRC EQ 0.
            MOVE : LS_3480-CRDAT TO <LS_3480>-CRDAT,
                    LS_3480-CRTIM TO <LS_3480>-CRTIM,
                    LS_3480-CRNAM TO <LS_3480>-CRNAM,
                    SY-DATUM TO <LS_3480>-CHDAT,
                    SY-UZEIT TO <LS_3480>-CHTIM,
                    SY-UNAME TO <LS_3480>-CHNAM.
          ENDIF.
        ENDIF.
      ENDLOOP.
    WHEN 'B'.
      LOOP AT GT_MAIN_REGEIST INTO LS_MAIN.
        ADD 1 TO LV_SEQNO.
        APPEND INITIAL LINE TO LT_CHG_3480 ASSIGNING <LS_3480>.
        MOVE-CORRESPONDING LS_MAIN TO <LS_3480>.

        MOVE : P_WERKS TO <LS_3480>-WERKS,
                   P_SPGCD TO <LS_3480>-SPGCD,
                   GV_ZTYPE TO <LS_3480>-ZTYPE,
                   LV_SEQNO TO <LS_3480>-SEQNO.

        MOVE : SY-DATUM TO <LS_3480>-CRDAT,
                  SY-UZEIT TO <LS_3480>-CRTIM,
                  SY-UNAME TO <LS_3480>-CRNAM,
                  SY-DATUM TO <LS_3480>-CHDAT,
                  SY-UZEIT TO <LS_3480>-CHTIM,
                  SY-UNAME TO <LS_3480>-CHNAM.

      ENDLOOP.

  ENDCASE.

  IF GT_3480[] IS NOT INITIAL.
    DELETE ZGTPPT3480 FROM TABLE GT_3480.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '품목정보 테이블 저장중 오류 발생하였습니다.'(e12).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_CHG_3480 IS NOT INITIAL.
    MODIFY ZGTPPT3480 FROM TABLE LT_CHG_3480.
    IF SY-SUBRC NE 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '품목정보 테이블 저장중 오류 발생하였습니다.'(e12).
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  CLEAR GV_CHK_EDIT_100.
  MESSAGE S006 WITH '데이터 저장 완료 되었습니다.'(e08).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SAVE  CHANGING PV_CHK_ERR.

  DATA : LT_CHK_SORT LIKE GT_MAIN_REGEIST.

  CASE GV_ZTYPE.
    WHEN 'A'.
      LOOP AT GT_MAIN_REGEIST INTO DATA(LS_MAIN) WHERE CHECK = ABAP_TRUE.
        IF LS_MAIN-MATNR IS INITIAL.
          MESSAGE S006 DISPLAY LIKE 'E' WITH 'MTS 선정여부 칼럼이 설정된 라인에 품목코드가 없습니다.'(e13).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

        APPEND LS_MAIN TO LT_CHK_SORT.
      ENDLOOP.

      SORT LT_CHK_SORT[] BY MATNR.
      DELETE ADJACENT DUPLICATES FROM LT_CHK_SORT COMPARING MATNR.
      IF SY-SUBRC EQ 0.
        MESSAGE S006 DISPLAY LIKE 'E' WITH 'MTS 선정여부 칼럼이 설정된 라인에 중복된 품목코드가 있습니다.'(e14).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    WHEN 'B'.
      LOOP AT GT_MAIN_REGEIST INTO LS_MAIN.
        IF LS_MAIN-MATNR IS INITIAL.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '품목코드가 없습니다.'(e15).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

        IF LS_MAIN-LENGTH IS INITIAL.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '조장단위가 없습니다.'(e16).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

        APPEND LS_MAIN TO LT_CHK_SORT.
      ENDLOOP.


*      SORT LT_CHK_SORT[] BY MATNR.
*      DELETE ADJACENT DUPLICATES FROM LT_CHK_SORT COMPARING MATNR.
*      IF SY-SUBRC EQ 0.
*        MESSAGE S006 DISPLAY LIKE 'E' WITH '중복된 품목코드가 있습니다.'(e17).
*        PV_CHK_ERR = ABAP_TRUE.
*        RETURN.
*      ENDIF.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_CRT_ORDER_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_CRT_ORDER_INFO .

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_MATNR2 TYPE RANGE OF MATNR.
  DATA : LT_MATNR3 TYPE RANGE OF MATNR.
  DATA : LV_CAL_MENGE TYPE MSEG-MENGE.
  DATA : LV_BANFN TYPE EBAN-BANFN.
  DATA : LV_BNFPO TYPE EBAN-BNFPO.

  REFRESH : GT_3480, GT_3490.
  REFRESH GT_MAIN_CTR_ORDER.

  CASE GV_ZTYPE.
    WHEN 'A'.

      SELECT * FROM ZGTPPT3480
        INTO TABLE GT_3480
       WHERE WERKS = P_WERKS
          AND SPGCD = P_SPGCD
          AND MATNR IN S_MATNR
          AND ZTYPE = GV_ZTYPE.

      LT_MATNR = VALUE #( FOR LW_3480 IN GT_3480 WHERE ( MATNR IS NOT INITIAL )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3480-MATNR ) ).

      IF LT_MATNR[] IS NOT INITIAL.
        SORT LT_MATNR BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

        SELECT DISTINCT A~MATNR, A~ZZSPEC_NO, A~ZZCOLOR_BASE, A~MEINS
          FROM MARC AS B
          INNER JOIN MARA AS A ON A~MATNR = B~MATNR
          INNER JOIN T134 AS C ON C~MTART = A~MTART
          INTO TABLE @DATA(LT_MOSU)
         WHERE B~WERKS = @P_WERKS
           AND B~MATNR IN @LT_MATNR
           AND B~DISPO LIKE @GV_DISPO
           AND B~LVORM = ' '
           AND C~MTREF = 'FERT'.

        SELECT MATNR, SUM( CLABS ) AS CLABS FROM MCHB
         WHERE WERKS = @P_WERKS
           AND MATNR IN @LT_MATNR
           AND CLABS > 0
          GROUP BY MATNR
           INTO TABLE @DATA(LT_JAGO).

        SELECT * FROM ZGTPPT3490
          INTO TABLE GT_3490
         WHERE WERKS = P_WERKS
            AND SPGCD = P_SPGCD
            AND MATNR IN LT_MATNR
            AND AUF_TYP = GV_ZTYPE
            AND ERDAT = SY-DATUM.

        PERFORM GET_SALES_MONTH_AVERAGE.

      ENDIF.

* 기할당조장, 미할당조장을 구하기 위한 로직 구정
      LT_MATNR2 = VALUE #( FOR LW_3480 IN GT_3480 WHERE ( MATNR IS NOT INITIAL
                                                    AND   IN_OUT = 'E' ) "외주
                         ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3480-MATNR ) ).

      IF LT_MATNR2[] IS NOT INITIAL.
        SORT LT_MATNR2 BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_MATNR2 COMPARING LOW.
        GT_MATNR = LT_MATNR2.
        PERFORM GET_STOCK_LINK_INFO.
      ENDIF.

* PR생성된 자재의 입고예정수량
      LT_MATNR3 = VALUE #( FOR LW_3480 IN GT_3480 WHERE ( MATNR IS NOT INITIAL
                                                    AND   IN_OUT = 'F' ) "외주
                         ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3480-MATNR ) ).

      IF LT_MATNR3[] IS NOT INITIAL.
        SORT LT_MATNR3 BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_MATNR3 COMPARING LOW.

        SELECT DISTINCT WERKS, MATNR, BANFN, BNFPO, MENGE, MEINS  FROM EBAN
          INTO TABLE @DATA(LT_EBAN)
         WHERE MATNR IN @LT_MATNR3
           AND WERKS = @P_WERKS
           AND LOEKZ = ''.

        SELECT DISTINCT B~EBELN, B~EBELP
          FROM @LT_EBAN AS A
          INNER JOIN EKPO AS B ON B~BANFN = A~BANFN
                              AND B~BNFPO = A~BNFPO
         WHERE B~LOEKZ = ''
                     INTO TABLE @DATA(LT_EKPO).

        SELECT DISTINCT B~WERKS, B~MATNR, ERFME, SUM( ERFMG ) AS ERFMG
          FROM @LT_EKPO AS A
          INNER JOIN MATDOC AS B ON B~EBELN = A~EBELN
                              AND B~EBELP = A~EBELP
         WHERE B~BWART = '101'
           AND B~CANCELLED = ''
          GROUP BY WERKS, MATNR, ERFME
          INTO TABLE @DATA(LT_MATDOC).

      ENDIF.

* 출력화면 구성
      LOOP AT GT_3480 INTO DATA(LS_3480).
        CLEAR GS_MAIN_CTR_ORDER.
        GS_MAIN_CTR_ORDER-MATNR = LS_3480-MATNR.
        GS_MAIN_CTR_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_3480-MATNR ).
        READ TABLE LT_MOSU INTO DATA(LS_MOSU) WITH KEY MATNR = LS_3480-MATNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_CTR_ORDER-ZZSPEC_NO = LS_MOSU-ZZSPEC_NO.
          GS_MAIN_CTR_ORDER-ZZCOLOR_BASE = LS_MOSU-ZZCOLOR_BASE.

          READ TABLE GT_MENGE_VBAP INTO DATA(LS_MENGE) WITH KEY MATNR = LS_3480-MATNR.

          IF SY-SUBRC EQ 0.
            GS_MAIN_CTR_ORDER-MENGE01 = LS_MENGE-MENGE01 / 6.
            GS_MAIN_CTR_ORDER-MENGE02 = LS_MENGE-MENGE02 / 6.
          ENDIF.
* 안전재고 = 안전재고 = ( "SM 판매량" * 안전재고비율(%)" )
          GS_MAIN_CTR_ORDER-SFTST = GS_MAIN_CTR_ORDER-MENGE02 * LS_3480-SFTRT.
          GS_MAIN_CTR_ORDER-SFTRT = LS_3480-SFTRT.
* ROP = ROP = ( "안전재고" * "ROP비율(%)" )
          GS_MAIN_CTR_ORDER-MENGE03 = GS_MAIN_CTR_ORDER-SFTST * LS_3480-ROPRT.
          GS_MAIN_CTR_ORDER-ROPRT = LS_3480-ROPRT.

          GS_MAIN_CTR_ORDER-LENGTH = LS_3480-LENGTH.
* 재고수량 = MCHB-CLABS 추가
          READ TABLE LT_JAGO INTO DATA(LS_JAGO) WITH KEY MATNR = LS_3480-MATNR.
          IF SY-SUBRC EQ 0. " 현재 재고 존재시
            GS_MAIN_CTR_ORDER-CLABS = LS_JAGO-CLABS.
          ENDIF.

          GS_MAIN_CTR_ORDER-ERDAT = SY-DATUM.

          READ TABLE LT_JAGO INTO LS_JAGO WITH KEY MATNR = LS_3480-MATNR.
          IF SY-SUBRC EQ 0. " 현재 재고 존재시
            IF LS_JAGO-CLABS >= GS_MAIN_CTR_ORDER-MENGE03. " 재고수량이 ROP보다 작은 경우 하기의 계산식으로 오더수량을 제안함
              GS_MAIN_CTR_ORDER-GAMNG = 0.
            ELSE.
              " 안전재고"/"조장단위)으로 나눈 값을 "조장단위"의 배수로 표기  오더수량 = ( "안전재고" / "조장단위" ) * "조장단위"
*  ↑ ( "안전재고" / "조장단위" ) 內 몫을 정수에서 올림 처리
              CLEAR LV_CAL_MENGE.
              LV_CAL_MENGE = LS_3480-SFTST / GS_MAIN_CTR_ORDER-LENGTH.
*             올림처리후 오더 수량 계산
              PERFORM CONV_UPPPER_ROUND USING 1 CHANGING LV_CAL_MENGE.
              GS_MAIN_CTR_ORDER-GAMNG = GS_MAIN_CTR_ORDER-LENGTH * LV_CAL_MENGE.
            ENDIF.
          ELSE.
            CLEAR LV_CAL_MENGE.
            LV_CAL_MENGE = LS_3480-SFTST / GS_MAIN_CTR_ORDER-LENGTH.
*             올림처리후 오더 수량 계산
            PERFORM CONV_UPPPER_ROUND USING 1 CHANGING LV_CAL_MENGE.
            GS_MAIN_CTR_ORDER-GAMNG = GS_MAIN_CTR_ORDER-LENGTH * LV_CAL_MENGE.
          ENDIF.

* 입고 예정수량
          CASE LS_3480-IN_OUT.
            WHEN 'E'. "자작
              LOOP AT GT_LINK_STOCK INTO DATA(LS_LINK) WHERE MATNR = LS_MOSU-MATNR.
                IF LS_LINK-MEINS NE LS_MOSU-MEINS.
                  PERFORM GET_QUINTITY_CONV_UINT USING LS_MOSU-MATNR LS_LINK-LABST2 LS_LINK-MEINS LS_MOSU-MEINS
                                                    CHANGING LS_LINK-LABST2.

                  PERFORM GET_QUINTITY_CONV_UINT USING LS_MOSU-MATNR LS_LINK-LABST3 LS_LINK-MEINS LS_MOSU-MEINS
                                                    CHANGING LS_LINK-LABST3.

                ENDIF.

                ADD LS_LINK-LABST2 TO GS_MAIN_CTR_ORDER-LABST2.
                ADD LS_LINK-LABST3 TO GS_MAIN_CTR_ORDER-LABST3.

              ENDLOOP.

              IF GS_MAIN_CTR_ORDER-LENGTH NE 0.
                GS_MAIN_CTR_ORDER-INFACTOR2 = GS_MAIN_CTR_ORDER-LABST2 / GS_MAIN_CTR_ORDER-LENGTH.
                GS_MAIN_CTR_ORDER-INFACTOR3 = GS_MAIN_CTR_ORDER-LABST3 / GS_MAIN_CTR_ORDER-LENGTH.
              ELSE.
                GS_MAIN_CTR_ORDER-INFACTOR2 = 1.
                GS_MAIN_CTR_ORDER-INFACTOR3 = 1.
              ENDIF.


            WHEN 'F'. "외주
              CLEAR GS_MAIN_CTR_ORDER-MENGE04.
* 요청수량
              LOOP AT LT_EBAN INTO DATA(LS_EBAN) WHERE MATNR = LS_MOSU-MATNR.
                IF LS_EBAN-MEINS NE LS_MOSU-MEINS.
                  PERFORM GET_QUINTITY_CONV_UINT USING LS_MOSU-MATNR LS_EBAN-MENGE LS_EBAN-MEINS LS_MOSU-MEINS
                                                    CHANGING LS_EBAN-MENGE.
                ENDIF.

                ADD LS_EBAN-MENGE TO GS_MAIN_CTR_ORDER-MENGE04.
              ENDLOOP.
* 구매오더 입고 수량
              LOOP AT LT_MATDOC INTO DATA(LS_MATDOC) WHERE MATNR = LS_MOSU-MATNR.
                IF LS_MATDOC-ERFME NE LS_MOSU-MEINS.
                  PERFORM GET_QUINTITY_CONV_UINT USING LS_MOSU-MATNR LS_MATDOC-ERFMG LS_MATDOC-ERFME LS_MOSU-MEINS
                                                    CHANGING LS_MATDOC-ERFMG.
                ENDIF.

                GS_MAIN_CTR_ORDER-MENGE04 = GS_MAIN_CTR_ORDER-MENGE04 - LS_MATDOC-ERFMG.
              ENDLOOP.
          ENDCASE.

* 스테이터스 기본 인엑티브
          GS_MAIN_CTR_ORDER-STATUS = ICON_LED_INACTIVE.
          GS_MAIN_CTR_ORDER-MEINS = LS_MOSU-MEINS.

          READ TABLE GT_3490 INTO DATA(LS_3490) WITH KEY MATNR = LS_3480-MATNR.
          IF SY-SUBRC EQ 0.
            GS_MAIN_CTR_ORDER-GAMNG = LS_3490-WEMNG.
            GS_MAIN_CTR_ORDER-STATUS = ICON_LED_GREEN.
            GS_MAIN_CTR_ORDER-MESSAGE = LS_3490-STAT_MSG.
            GS_MAIN_CTR_ORDER-ORDNR = LS_3490-ORDNR.

          ENDIF.
        ENDIF.

        GS_MAIN_CTR_ORDER-IN_OUT = LS_3480-IN_OUT.

        APPEND GS_MAIN_CTR_ORDER TO GT_MAIN_CTR_ORDER.

      ENDLOOP.

    WHEN 'B'.
      SELECT * FROM ZGTPPT3480
        INTO TABLE GT_3480
       WHERE WERKS = P_WERKS
          AND SPGCD = P_SPGCD
          AND MATNR IN S_MATNR
          AND ZTYPE = GV_ZTYPE.

      LT_MATNR = VALUE #( FOR LW_3480 IN GT_3480 WHERE ( MATNR IS NOT INITIAL )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3480-MATNR ) ).

      IF LT_MATNR[] IS NOT INITIAL.
        SORT LT_MATNR BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

        SELECT * FROM ZGTPPT3490
          INTO TABLE GT_3490
         WHERE WERKS = P_WERKS
            AND SPGCD = P_SPGCD
            AND MATNR IN LT_MATNR
            AND AUF_TYP = GV_ZTYPE
            AND ERDAT = SY-DATUM.
      ENDIF.

* 출력화면 구성
      LOOP AT GT_3480 INTO LS_3480.
        CLEAR GS_MAIN_CTR_ORDER.
        GS_MAIN_CTR_ORDER-SEQNO = LS_3490-SEQNO.
        GS_MAIN_CTR_ORDER-MATNR = LS_3480-MATNR.
        GS_MAIN_CTR_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_3480-MATNR ).
* 스테이터스 기본 인엑티브
        GS_MAIN_CTR_ORDER-STATUS = ICON_LED_INACTIVE.
        SELECT SINGLE MEINS FROM MARA
          INTO GS_MAIN_CTR_ORDER-MEINS
          WHERE MATNR = LS_3480-MATNR.
        GS_MAIN_CTR_ORDER-GAMNG = LS_3480-LENGTH.

        READ TABLE GT_3490 INTO LS_3490 WITH KEY SEQNO = LS_3480-SEQNO
                                                             MATNR = LS_3480-MATNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_CTR_ORDER-GAMNG = LS_3490-WEMNG.
          GS_MAIN_CTR_ORDER-STATUS = ICON_LED_GREEN.
          GS_MAIN_CTR_ORDER-MESSAGE = LS_3490-STAT_MSG.
          GS_MAIN_CTR_ORDER-ORDNR = LS_3490-ORDNR.
        ENDIF.

        APPEND GS_MAIN_CTR_ORDER TO GT_MAIN_CTR_ORDER.

      ENDLOOP.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_UPPPER_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      <-- GS_MAIN_DISP_103_MENGE05
*&---------------------------------------------------------------------*
FORM CONV_UPPPER_ROUND  USING    PV_DIGIT
                 CHANGING PV_MENGE.

  DATA : LV_RUNIT TYPE VTBFIMA-RUNIT.
  DATA : LV_VALUE TYPE MENGE_D.

  LV_RUNIT = PV_DIGIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = '+'
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_MENGE
    IMPORTING
      E_VALUE_RND = PV_MENGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SALES_MONTH_AVERAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MATNR
*&---------------------------------------------------------------------*
FORM GET_SALES_MONTH_AVERAGE.

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_DATUM TYPE RANGE OF SY-DATUM.
  DATA : LT_SPMON TYPE RANGE OF SPMON.
  DATA : LT_MENGE_VBAP LIKE GT_MENGE_VBAP.
  DATA : LV_CAL_MONTH TYPE I.
  DATA : LV_BGN_MON TYPE SPMON.
  DATA : LV_BGN_DATE TYPE SY-DATUM.
  DATA : LV_CAL_DATE TYPE SY-DATUM.
  DATA : LV_FIELDNAME01 TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  DATA : LV_CURRENT_DT TYPE SY-DATUM.

  REFRESH GT_MENGE_VBAP.

* 조회기준 날짜 세팅
  CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
    EXPORTING
      MONTHS  = '-6'
      OLDDATE = SY-DATUM
    IMPORTING
      NEWDATE = LV_BGN_DATE.

  LV_CURRENT_DT = SY-DATUM+0(6)  && '01'.
  LV_BGN_DATE = LV_BGN_DATE+0(6) && '01'.

  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_BGN_DATE+0(6) ) TO LT_SPMON.
  LV_CAL_DATE = LV_BGN_DATE.
  DO 5 TIMES.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '1'
        OLDDATE = LV_CAL_DATE
      IMPORTING
        NEWDATE = LV_CAL_DATE.

    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_CAL_DATE+0(6) ) TO LT_SPMON.
  ENDDO.

  SORT LT_SPMON BY LOW.


* 자재별 총 판매수량 세팅,
  LT_MATNR = VALUE #( FOR LW_3480 IN GT_3480 WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3480-MATNR ) ).

  IF LT_MATNR[] IS NOT INITIAL.
    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

* 판매수량 점검일자(현재월 -6개월 ) 가 20260701 보다 작다면 임시저장 테이블에서 판매수량 추출
    IF LV_BGN_DATE < '20260701'.
      SELECT * FROM ZGTPPT3470
        INTO TABLE GT_3470
       WHERE WERKS = P_WERKS
         AND SPGCD = P_SPGCD
         AND MATNR IN LT_MATNR.


      LOOP AT GT_3470 INTO DATA(LS_3470).
        CLEAR LV_BGN_MON.
        LOOP AT LT_SPMON INTO DATA(LS_SPMON).
          CLEAR : LV_FIELDNAME01, LV_FIELDNAME02.
          IF LS_SPMON-LOW < '202601'. " 에러
            CONTINUE.
          ENDIF.
          CASE LS_SPMON-LOW.
            WHEN '202601'.
              LV_FIELDNAME01 = 'M01_TOT_QTY'.
              LV_FIELDNAME02 = 'M01_SM_QTY'.
            WHEN '202602'.
              LV_FIELDNAME01 = 'M02_TOT_QTY'.
              LV_FIELDNAME02 = 'M02_SM_QTY'.
            WHEN '202603'.
              LV_FIELDNAME01 = 'M03_TOT_QTY'.
              LV_FIELDNAME02 = 'M03_SM_QTY'.
            WHEN '202604'.
              LV_FIELDNAME01 = 'M04_TOT_QTY'.
              LV_FIELDNAME02 = 'M04_SM_QTY'.
            WHEN '202605'.
              LV_FIELDNAME01 = 'M05_TOT_QTY'.
              LV_FIELDNAME02 = 'M05_SM_QTY'.
            WHEN '202606'.
              LV_FIELDNAME01 = 'M06_TOT_QTY'.
              LV_FIELDNAME02 = 'M06_SM_QTY'.
            WHEN OTHERS.
              ADD 1 TO LV_CAL_MONTH.
              IF LV_BGN_MON IS INITIAL OR LV_BGN_MON = '000000'.
                LV_BGN_MON = LS_SPMON-LOW.
              ELSE.
                IF LV_BGN_MON > LS_SPMON-LOW.
                  LV_BGN_MON = LS_SPMON-LOW.
                ENDIF.
              ENDIF.
              CONTINUE.
          ENDCASE.

          IF LV_FIELDNAME01 IS INITIAL AND LV_FIELDNAME02 IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR GS_MENGE_VBAP.
          GS_MENGE_VBAP-MATNR = LS_3470-MATNR.
          GS_MENGE_VBAP-MENGE01 = LS_3470-(LV_FIELDNAME01).
          GS_MENGE_VBAP-MENGE02 = LS_3470-(LV_FIELDNAME02).
          COLLECT GS_MENGE_VBAP INTO GT_MENGE_VBAP.
        ENDLOOP.
      ENDLOOP.

    ENDIF.

    IF LV_BGN_MON IS NOT INITIAL.
      APPEND INITIAL LINE TO LT_DATUM ASSIGNING FIELD-SYMBOL(<LS_DATUM>).
      <LS_DATUM>-SIGN = 'I'.
      <LS_DATUM>-OPTION = 'BT'.
      <LS_DATUM>-LOW = LV_BGN_MON && '01'.
      <LS_DATUM>-HIGH = LV_CURRENT_DT - 1.
    ELSE.
      APPEND INITIAL LINE TO  LT_DATUM ASSIGNING <LS_DATUM>.
      <LS_DATUM>-SIGN = 'I'.
      <LS_DATUM>-OPTION = 'BT'.
      <LS_DATUM>-LOW = LV_BGN_DATE.
      <LS_DATUM>-HIGH = LV_CURRENT_DT - 1.
    ENDIF.

    IF LT_DATUM[] IS NOT INITIAL.

      SELECT P~MATNR,
                 SUM( L~LFIMG ) AS MENGE01,
                 SUM( CASE P~FIXMG
                         WHEN 'X' THEN L~LFIMG
                         ELSE 0 END ) AS MENGE02
        FROM VBEP AS A
        INNER JOIN VBAP AS P
                               ON P~VBELN = A~VBELN
                              AND P~POSNR = A~POSNR
        INNER JOIN LIPS AS L ON L~VBELV = P~VBELN
                              AND L~POSNV = P~POSNR
     WHERE A~EDATU IN @LT_DATUM
         AND CONCAT( CONCAT( A~VBELN, A~POSNR ), A~ETENR ) IN
                          ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
                                   FROM VBEP
                                  WHERE VBELN  = A~VBELN
                                     AND POSNR   = A~POSNR
                                     AND LIFSP = ' '
                                     AND WMENG    NE 0
                            GROUP BY VBELN, POSNR )
          AND CONCAT( P~VBELN, P~POSNR ) NOT IN
           ( SELECT  CONCAT( VBELN, POSNR )
                FROM VBEP
              WHERE VBELN = A~VBELN
                  AND POSNR   = A~POSNR
                  AND ETTYP = 'CN'
                  AND EDATU  = ( SELECT MAX( EDATU ) AS EDATU
                                    FROM VBEP
                                WHERE VBELN = A~VBELN
                                    AND POSNR   = A~POSNR
                           GROUP BY VBELN, POSNR ) )
            AND P~MATNR IN @LT_MATNR
            AND P~WERKS = @P_WERKS
            AND L~WBSTA = 'C'
            AND L~LFIMG > 0
          GROUP BY P~MATNR
            INTO CORRESPONDING FIELDS OF TABLE @LT_MENGE_VBAP.

      LOOP AT LT_MENGE_VBAP INTO DATA(LS_CAL).
        CLEAR GS_MENGE_VBAP.
        GS_MENGE_VBAP-MATNR = LS_CAL-MATNR.
        GS_MENGE_VBAP-MENGE01 = LS_CAL-MENGE01.
        GS_MENGE_VBAP-MENGE02 = LS_CAL-MENGE02.
        COLLECT GS_MENGE_VBAP INTO GT_MENGE_VBAP.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_CONTAIN_0400->FREE.
      FREE : GO_CONTAIN_0400, GO_GRID_0400.
      REFRESH : GT_SORT_0400, GT_EXCLUDE_0400, GT_FIELDCAT_0400.
      FREE GO_EVENT_HANDLER.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0400 .

  CREATE OBJECT GO_CONTAIN_0400
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

  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0400 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.
  DATA : LV_TEXT3 TYPE CHAR100.

  CLEAR GS_LAYOUT_0400.
  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0400-SEL_MODE   = 'D'.
  GS_LAYOUT_0400-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0400-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CASE GV_ZTYPE.
    WHEN 'A'.
      LV_TEXT1 = '생산오더 유형 : A　MTS,'.
    WHEN 'B'.
      LV_TEXT1 = '생산오더 유형 : B　구다이스,'.
  ENDCASE.

  CLEAR LV_TEXT2.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT2 SEPARATED BY SPACE.
  LV_TEXT2 = LV_TEXT2 && ','.

  CLEAR LV_TEXT3.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT3 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 LV_TEXT3 INTO GS_LAYOUT_0400-GRID_TITLE SEPARATED BY SPACE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0400 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2320TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_CTR_ORDER'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0400.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_MAIN_CTR_ORDER
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'GUBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'GUBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더 구분'(F42).
    <LS_FCAT>-COL_POS = 19.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    IF SY-DYNNR = '0400'.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

  ENDIF.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(F40).
    <LS_FCAT>-COL_POS = 21.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
    <LS_FCAT>-JUST = 'L'.

  ENDIF.


  LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(F43).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(F11).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZZSPEC_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Spec No'(F26).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZCOLOR_BASE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '평균판매량'(F32).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SM 판매량'(F33).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SFTST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '안전재고'(F28).
        <LS_FCAT>-JUST = 'C'.
*        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'SFTRT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '안전재고비율'(F29).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'ROP'(F34).
        <LS_FCAT>-JUST = 'C'.
*        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ROPRT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'ROP비율'(F30).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장단위'(F31).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CLABS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전산조장'(F41).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(F24).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리상태'(F35).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(F40).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ORDNR'.
        CASE GV_ZTYPE.
          WHEN 'A'.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SM오더번호'(F36).
          WHEN 'B'.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더번호'(F37).
        ENDCASE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성기준일자'(F38).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더수량'(F39).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.

      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '대체 작업장'(F44).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'IN_OUT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자작/외주'(F45).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LABST2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기할당조장'(F46).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기할당조장수'(F47).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LABST3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '미할당조장'(F48).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '미할당조장수'(F49).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고 예정수량'(F50).
        <LS_FCAT>-JUST = 'R'.

      WHEN 'CRDAT' OR 'CRTIM' OR 'CRNAM'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  IF GV_ZTYPE = 'B'.
    LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'ZZSPEC_NO' OR 'ZZCOLOR_BASE' OR 'SFTST' OR 'SFTRT' OR 'ROPRT' OR
          'MENGE01' OR 'MENGE02' OR 'MENGE03' OR 'IN_OUT' OR 'LABST2' OR 'INFACTOR2' OR
          'LABST3' OR 'INFACTOR3' OR 'MENGE04'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN 'SFTST' OR 'ROPRT' OR 'GAMNG'.
          CLEAR <LS_FCAT>-EDIT.
        WHEN 'SEQNO'.
          CLEAR <LS_FCAT>-NO_OUT.
        WHEN 'ARBPL'.
          <LS_FCAT>-EDIT = ABAP_TRUE.
          CLEAR <LS_FCAT>-NO_OUT.
          <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  IF P_RAD13 = ABAP_TRUE.
    LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'LABST2' OR 'INFACTOR2' OR 'LABST3' OR 'INFACTOR3' OR 'MENGE04' OR 'CLABS'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN 'CRDAT' OR 'CRTIM' OR 'CRNAM'.
          CLEAR <LS_FCAT>-NO_OUT.
        WHEN 'GAMNG'.
          CLEAR <LS_FCAT>-EDIT.
      ENDCASE.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0400 .

  REFRESH GT_EXCLUDE_0400.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0400_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0400_DISPLAY .

  CALL METHOD GO_GRID_0400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0400
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0400
    CHANGING
      IT_OUTTAB            = GT_MAIN_CTR_ORDER
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

  IF GV_ZTYPE NE 'B'.
* 인풋이벤트 추가
    CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

    CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_EXCUTE_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_EXCUTE_0400 .

  DATA : LT_MOSU LIKE GT_MAIN_CTR_ORDER.
  DATA : LV_STRING TYPE STRING.

  PERFORM GET_MOSU_FOR_CREATE_ORDER TABLES LT_MOSU.

  IF LT_MOSU[] IS INITIAL.
    CASE GV_ZTYPE.
      WHEN 'A'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '오더 생성 할 품목이 없습니다.'(E18).
      WHEN 'B'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 생성할 품목이 없습니다.'(e19).
    ENDCASE.
    RETURN.
  ENDIF.

  IF P_BATCH NE ABAP_TRUE.
    CLEAR LV_STRING.
    CASE GV_ZTYPE.
      WHEN 'A'.
        LV_STRING = '조장구성 반영 진행하시겠습니까?'.
      WHEN 'B'.
        LV_STRING = '생산오더 생성 진행하시겠습니까?'.
    ENDCASE.


    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      LV_STRING
      '작업확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM CREATE_ORDER TABLES LT_MOSU.

  CASE GV_ZTYPE.
    WHEN 'A'.
      MESSAGE S003 WITH '오더 생성 실행되었습니다.'.
    WHEN 'B'.
      MESSAGE S003 WITH '구다이스 생산오더 생성 실행되었습니다.'.
  ENDCASE.
  IF P_BATCH = ABAP_TRUE.
    RETURN.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MOSU_FOR_CREATE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MOSU
*&---------------------------------------------------------------------*
FORM GET_MOSU_FOR_CREATE_ORDER  TABLES   PT_MOSU STRUCTURE GS_MAIN_CTR_ORDER.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.

  CASE GV_ZTYPE.
    WHEN 'A'.

      CALL METHOD GO_GRID_0400->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROW.

      DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

      IF LT_ROW[] IS INITIAL.
        RETURN.
      ENDIF.

      REFRESH PT_MOSU.
      LOOP AT LT_ROW INTO LS_ROW.
        READ TABLE GT_MAIN_CTR_ORDER INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
        CLEAR PT_MOSU.
        MOVE-CORRESPONDING LS_MAIN TO PT_MOSU.
        APPEND PT_MOSU.
      ENDLOOP.


    WHEN 'B'.
* 생성을 위한 모수 기준 추출
      PT_MOSU[] = VALUE #( FOR LW_MOSU IN GT_MAIN_CTR_ORDER WHERE ( STATUS NE ICON_LED_GREEN
                                                                                                AND    ORDNR IS INITIAL
                                                                                                AND   GAMNG > 0 )
                                  ( CORRESPONDING #( LW_MOSU ) ) ).
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MOSU
*&---------------------------------------------------------------------*
FORM CREATE_ORDER  TABLES   PT_MOSU STRUCTURE GS_MAIN_CTR_ORDER.

  DATA : LT_CHG_3490 TYPE TABLE OF ZGTPPT3490.
  DATA : LT_SUCCESS_MOSU LIKE TABLE OF GS_MAIN_CTR_ORDER.
  DATA : LV_CHK_ERR.

  REFRESH GT_CHG_2001.

  LOOP AT PT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).

    CLEAR LV_CHK_ERR.
    CASE GV_ZTYPE.
      WHEN 'A'.
        CASE <LS_MOSU>-IN_OUT.
          WHEN 'E'.
            PERFORM CREATE_SM_ORDER CHANGING <LS_MOSU> LV_CHK_ERR.
          WHEN 'F'.
            PERFORM CREATE_PR CHANGING <LS_MOSU> LV_CHK_ERR.
        ENDCASE.
      WHEN 'B'.
        PERFORM CREATE_PRD_ORDER CHANGING <LS_MOSU> LV_CHK_ERR.
    ENDCASE.

    CASE GV_ZTYPE.
      WHEN 'A'.
        READ TABLE GT_MAIN_CTR_ORDER ASSIGNING FIELD-SYMBOL(<LS_ORIGN>) WITH KEY MATNR = <LS_MOSU>-MATNR.
      WHEN 'B'.
        READ TABLE GT_MAIN_CTR_ORDER ASSIGNING <LS_ORIGN> WITH KEY MATNR = <LS_MOSU>-MATNR
                                                                   SEQNO = <LS_MOSU>-SEQNO.
    ENDCASE.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING <LS_MOSU> TO <LS_ORIGN>.

*    오더 생성정보 테이블 구성
      IF LV_CHK_ERR IS INITIAL.
*       자작/외주 구분없이 메일 전송
        APPEND <LS_MOSU> TO LT_SUCCESS_MOSU.

        APPEND INITIAL LINE TO LT_CHG_3490 ASSIGNING FIELD-SYMBOL(<LS_3490>).
        <LS_3490>-WERKS = P_WERKS.
        <LS_3490>-SPGCD = P_SPGCD.
        <LS_3490>-ORDNR = <LS_MOSU>-ORDNR.
        <LS_3490>-IN_OUT = <LS_MOSU>-IN_OUT.
        <LS_3490>-AUF_TYP = GV_ZTYPE.
        <LS_3490>-MATNR = <LS_MOSU>-MATNR.
        <LS_3490>-SEQNO = <LS_MOSU>-SEQNO.
        <LS_3490>-SALES_AVG = <LS_MOSU>-MENGE01.
        <LS_3490>-SM_SALES = <LS_MOSU>-MENGE02.
        <LS_3490>-SFT_INV = <LS_MOSU>-SFTST.
        <LS_3490>-SFT_RATE = <LS_MOSU>-SFTRT.
        <LS_3490>-ROP_QTY = <LS_MOSU>-MENGE03.
        <LS_3490>-ROP_RATE = <LS_MOSU>-ROPRT.
        <LS_3490>-LENGTH = <LS_MOSU>-LENGTH.
        <LS_3490>-STAT = 'S'.
        <LS_3490>-STAT_MSG = <LS_MOSU>-MESSAGE.
        <LS_3490>-ERDAT = SY-DATUM.
        <LS_3490>-WEMNG = <LS_MOSU>-GAMNG.
        <LS_3490>-CRDAT = SY-DATUM.
        <LS_3490>-CRTIM = SY-UZEIT.
        <LS_3490>-CRNAM = SY-UNAME.
        <LS_3490>-CHDAT = SY-DATUM.
        <LS_3490>-CHTIM = SY-UZEIT.
        <LS_3490>-CHNAM = SY-UNAME.
      ENDIF.
    ENDIF.

  ENDLOOP.

* 생성 결과 처리
  CASE GV_ZTYPE.
    WHEN 'A'.
      IF GT_CHG_2001 IS NOT INITIAL.
        MODIFY ZGTPPT2001 FROM TABLE GT_CHG_2001.
      ENDIF.

      IF LT_CHG_3490 IS NOT INITIAL.
        MODIFY ZGTPPT3490 FROM TABLE LT_CHG_3490.
      ENDIF.

      COMMIT WORK.
* Email 전송 처리
      IF LT_SUCCESS_MOSU IS NOT INITIAL. " 오더 생성건 존재시
        PERFORM SEND_MAIL TABLES LT_SUCCESS_MOSU.
      ENDIF.
    WHEN 'B'.
      IF LT_CHG_3490 IS NOT INITIAL.
        MODIFY ZGTPPT3490 FROM TABLE LT_CHG_3490.
      ENDIF.

      COMMIT WORK.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_SM_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MOSU>
*&---------------------------------------------------------------------*
FORM CREATE_SM_ORDER  CHANGING PS_MOSU LIKE GS_MAIN_CTR_ORDER
                                           PV_CHK_ERR.

  DATA : LS_SAVE_2001 TYPE ZGTPPT2001.

  CLEAR LS_SAVE_2001.
  PERFORM GET_ORDNO CHANGING LS_SAVE_2001-ORDNO PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    PS_MOSU-STATUS = ICON_LED_RED.
    PS_MOSU-MESSAGE = 'ERROR'.
    RETURN.
  ENDIF.

  PS_MOSU-ORDNR = LS_SAVE_2001-ORDNO.
  PS_MOSU-STATUS = ICON_LED_GREEN.
  PS_MOSU-MESSAGE = 'SM오더생성 완료'.

  LS_SAVE_2001-POSNR = 1.
  LS_SAVE_2001-WERKS = P_WERKS.
  LS_SAVE_2001-SPGCD = P_SPGCD.
  LS_SAVE_2001-GSTRP = SY-DATUM.
  LS_SAVE_2001-GLTRP = SY-DATUM.
  LS_SAVE_2001-MATNR = PS_MOSU-MATNR.
  LS_SAVE_2001-INLENGTH = PS_MOSU-LENGTH.
  LS_SAVE_2001-GAMNG = PS_MOSU-GAMNG.
  LS_SAVE_2001-INFACTOR = PS_MOSU-GAMNG / PS_MOSU-LENGTH.
  LS_SAVE_2001-MEINS = PS_MOSU-MEINS.

  APPEND LS_SAVE_2001 TO GT_CHG_2001.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORDNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_SAVE_2001_ORDNO
*&---------------------------------------------------------------------*
FORM GET_ORDNO  CHANGING PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                         PV_CHK_ERR.

  DATA : LV_NR     LIKE  INRI-NRRANGENR.

  LV_NR = '01'.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
      OBJECT                  = 'ZGTPP_GORD'
    IMPORTING
      NUMBER                  = PV_ORDNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MOSU>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PRD_ORDER  CHANGING PS_MOSU LIKE GS_MAIN_CTR_ORDER
                                           PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LV_CHK_ERR.
  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.

*  오더 생성
  LS_ORDER-MATERIAL = PS_MOSU-MATNR.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_START_DATE = SY-DATUM.
  LS_ORDER-BASIC_END_DATE = SY-DATUM.
  LS_ORDER-QUANTITY = PS_MOSU-GAMNG.
  LS_ORDER-QUANTITY_UOM = PS_MOSU-MEINS.
  LS_ORDER-PROD_VERSION = '1000'.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '7'.


  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

  IF LS_RETURN-TYPE NE 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE AUFNR, POSNR
        FROM AFPO
       WHERE AUFNR = @LV_ORDER_NUMBER
        INTO @DATA(LS_AFPO).
      IF SY-SUBRC EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.
    ENDDO.

    PS_MOSU-ORDNR = LV_ORDER_NUMBER.
    PS_MOSU-STATUS = ICON_LED_GREEN.
    PS_MOSU-MESSAGE = '생산오더 생성완료'.

    WAIT UP TO '0.3' SECONDS.

  ELSE.
    PS_MOSU-STATUS = ICON_LED_RED.
    PS_MOSU-MESSAGE = 'ERROR'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF PS_MOSU-ARBPL IS NOT INITIAL.

    DATA : LV_RESULT TYPE ZO_RESULT.
    DATA : LV_MESSAGE TYPE ZO_MESSAGE.
    DATA : LT_ORDER TYPE TABLE OF ZGTPPSIF0012.
    DATA : IT_ORDERDATA TYPE TABLE OF ZGTPPSIF0013.
    DATA : IT_RESULT TYPE TABLE OF ZGTPPSIF0014.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
    DATA : LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.

*  생산오더 정보 입력
    APPEND INITIAL LINE TO LT_ORDER ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
    <LS_ORDER>-WERKS = P_WERKS.
    <LS_ORDER>-ZSERNO = SY-DATUM && '9999'.
    <LS_ORDER>-AUFNR = LV_ORDER_NUMBER.
*  설비변경정보 입력
    APPEND INITIAL LINE TO IT_ORDERDATA ASSIGNING FIELD-SYMBOL(<LS_ORDERDATA>).
    <LS_ORDERDATA>-AUFNR = LV_ORDER_NUMBER.
    <LS_ORDERDATA>-VORNR = '0010'.
    <LS_ORDERDATA>-ARBPL = PS_MOSU-ARBPL.
    <LS_ORDERDATA>-ARBPLX = ABAP_TRUE.


    CALL FUNCTION 'ZGTPP_IF_I_PROD_CHG'
      EXPORTING
        I_SYSTEM_ID           = 'KGOM'
      IMPORTING
        ZO_RESULT             = LV_RESULT
        ZO_MESSAGE            = LV_MESSAGE
      TABLES
        IT_ORDER              = LT_ORDER
        IT_ORDERDATA          = IT_ORDERDATA
        OT_RESULT             = IT_RESULT
      EXCEPTIONS
        SYSTEM_FAILURE        = 1
        COMMUNICATION_FAILURE = 2
        ILLEGALNAME           = 3
        OTHERS                = 4.
    IF SY-SUBRC <> 0.
      LV_CHK_ERR = ABAP_TRUE.
      CLEAR PS_MOSU-ORDNR.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = '대체설비 지정중 오류 발생'.

      APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDERS>).
      <LS_PRD_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = LT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      RETURN.
    ENDIF.

    IF LV_RESULT = '01'.
      CLEAR PS_MOSU-ORDNR.
      PS_MOSU-STATUS = ICON_LED_RED.
      PS_MOSU-MESSAGE = '대체설비 지정중 오류 발생'.

      APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING <LS_PRD_ORDERS>.
      <LS_PRD_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = LT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      RETURN.
    ENDIF.

  ENDIF.

* 작업지시를 위해 릴리즈
  REFRESH LT_ORDERS.
  APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
  <LS_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SUCCESS_MOSU
*&---------------------------------------------------------------------*
FORM SEND_MAIL  TABLES   PT_MOSU STRUCTURE GS_MAIN_CTR_ORDER.

  DATA : LV_SFTST(20).
  DATA : LV_SFTRT(20).
  DATA : LV_MENGE03(20).
  DATA : LV_ROPRT(20).
  DATA : LV_LENGTH(20).
  DATA : LV_GAMNG(20).

  DEFINE MAIL_MSG.
    CLEAR gs_msg.
    gs_msg = &1.
    APPEND gs_msg TO gtt_message.
  END-OF-DEFINITION.

  DEFINE __SET_MENGE_TO_CHAR.
    CLEAR &2.
    &2 = &1.
    condense &2.
  END-OF-DEFINITION.

  SELECT * FROM ZGTPPT3460
    INTO TABLE GT_3460
   WHERE CPROG = 'ZGTPPR2320'
     AND WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND ACTIVE = 'X'.

  SORT GT_3460 BY MAIL_TYPE DESCENDING.

* 메일 제목 생성
  GV_SUBJECT = 'MTS 가용재고 부족 지시 생성'.

* 메일본문
  MAIL_MSG : '<HTML>',
                    '<BODY>'.
  MAIL_MSG '본메일은 가온전선 MTS 오더 관리 기능에서 자동으로 보내는 알람 메일입니다.<BR>'.
  MAIL_MSG '담당자분들께서는 메일 내용을 확인하시고 업무에 참고하시기 바랍니다. <BR><BR>'.

  MAIL_MSG '[MTS 오더 생성]<BR>'.

* 테이블 헤더
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                  '<THEAD>',
                  '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">오더번호</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품목코드</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품목내역</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">SPEC NO</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">자작/외주</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">안전재고</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">안전재고비율(%)</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">ROP</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">ROP비율(%)</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">조장단위</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">오더수량</TH>',
                  '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">단위</TH>',
                  '</TR>',
                  '</THEAD>',
                  '<TBODY>'.

  LOOP AT PT_MOSU INTO DATA(LS_MAIN).
    __SET_MENGE_TO_CHAR : LS_MAIN-SFTST LV_SFTST,
                                        LS_MAIN-SFTRT LV_SFTRT,
                                        LS_MAIN-MENGE03 LV_MENGE03,
                                        LS_MAIN-ROPRT LV_ROPRT,
                                        LS_MAIN-LENGTH LV_LENGTH,
                                        LS_MAIN-GAMNG LV_GAMNG.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-ORDNR 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-MATNR 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-MAKTX 'L'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-ZZSPEC_NO 'C'.
    IF LS_MAIN-IN_OUT = 'E'.
      PERFORM APPEND_HTML_FOR_LIST USING '자작' 'C'.
    ELSEIF LS_MAIN-IN_OUT = 'F'..
      PERFORM APPEND_HTML_FOR_LIST USING '외주' 'C'.
    ENDIF.
    PERFORM APPEND_HTML_FOR_LIST USING LV_SFTST 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LV_SFTRT 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LV_MENGE03 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LV_ROPRT 'C'.
    PERFORM APPEND_HTML_FOR_LIST USING LV_LENGTH 'R'.
    PERFORM APPEND_HTML_FOR_LIST USING LV_GAMNG 'R'.
    PERFORM APPEND_HTML_FOR_LIST USING LS_MAIN-MEINS 'C'.
    MAIL_MSG : '</TR>'.
  ENDLOOP.

  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '</BODY>',
                   '</HTML>'.


  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GTT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).



      LOOP AT GT_3460 INTO DATA(LS_3460).
        CLEAR G_RECEIVER.
        CLEAR GV_ADDRESS.

        GV_ADDRESS = LS_3460-MAIL_ADDR.

        G_RECEIVER =
        CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

        CASE LS_3460-MAIL_TYPE.
          WHEN 'TO'.
            G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                    I_EXPRESS   = 'X' ).
          WHEN 'CC'.
            G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                    I_COPY   = 'X' ).
        ENDCASE.
      ENDLOOP.
      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).

      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.

  ENDTRY.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_HTML_FOR_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_AFKO3_WERKS
*&      --> P_
*&---------------------------------------------------------------------*
FORM APPEND_HTML_FOR_LIST  USING   PV_VALUE PV_SIGN.

  DATA : LV_MAIN(30),
         LV_LEFT(16),
         LV_RIGHT(6),
         LV_LEFT2(16),
         LV_RIGHT2(6).
  DATA : LV_MENGE TYPE STRING.

  IF PV_SIGN = 'C'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'L'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'R'.
    CLEAR : LV_MAIN, LV_LEFT, LV_RIGHT, LV_LEFT2, LV_RIGHT2, LV_MENGE.
    LV_MENGE = PV_VALUE.
    CALL FUNCTION 'BUX_DECIMAL_START'
      EXPORTING
        I_VALUE_DB   = LV_MENGE
      IMPORTING
        E_VALUE_DYNP = LV_MAIN.
    SPLIT LV_MAIN AT '.' INTO LV_LEFT LV_RIGHT.
    IF LV_RIGHT IS INITIAL.
      SPLIT LV_MENGE AT '.' INTO LV_LEFT2 LV_RIGHT2.
      CONCATENATE LV_LEFT '.' LV_RIGHT2 INTO GV_TEXT2.
    ELSE.
      GV_TEXT2 = LV_MAIN.
    ENDIF.
    CONDENSE GV_TEXT2 NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    GV_TEXT2 '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ENDIF.

  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR : GS_MSG, GV_TEXT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_RESULT .

  DATA : LT_MATNR TYPE RANGE OF MATNR.

  SELECT * FROM ZGTPPT3490
    INTO TABLE GT_3490
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND MATNR IN S_MATNR
     AND ORDNR IN S_AUFNR
     AND ERDAT IN S_GLTRS.

  LT_MATNR = VALUE #( FOR LW_3490 IN GT_3490 WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_3490-MATNR ) ).

  IF LT_MATNR[] IS NOT INITIAL.
    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

    SELECT DISTINCT A~MATNR, A~ZZSPEC_NO, A~ZZCOLOR_BASE, A~MEINS
      FROM MARC AS B
      INNER JOIN MARA AS A ON A~MATNR = B~MATNR
      INNER JOIN T134 AS C ON C~MTART = A~MTART
      INTO TABLE @DATA(LT_MOSU)
     WHERE B~WERKS = @P_WERKS
       AND B~MATNR IN @LT_MATNR
       AND B~DISPO LIKE @GV_DISPO
       AND B~LVORM = ' '
       AND ( A~MTART = 'MCHA'
        OR C~MTREF = 'FERT' ).
  ENDIF.

  REFRESH GT_MAIN_CTR_ORDER.
  LOOP AT GT_3490 INTO DATA(LS_3490).
    CLEAR GS_MAIN_CTR_ORDER.
    GS_MAIN_CTR_ORDER-SEQNO = LS_3490-SEQNO.
    GS_MAIN_CTR_ORDER-MATNR = LS_3490-MATNR.
    GS_MAIN_CTR_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_3490-MATNR ).
    READ TABLE LT_MOSU INTO DATA(LS_MOSU) WITH KEY MATNR = LS_3490-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_CTR_ORDER-ZZSPEC_NO = LS_MOSU-ZZSPEC_NO.
      GS_MAIN_CTR_ORDER-ZZCOLOR_BASE = LS_MOSU-ZZCOLOR_BASE.
    ENDIF.
    GS_MAIN_CTR_ORDER-MENGE01 = LS_3490-SALES_AVG.
    GS_MAIN_CTR_ORDER-MENGE02 = LS_3490-SM_SALES.
    GS_MAIN_CTR_ORDER-SFTST = LS_3490-SFT_INV.
    GS_MAIN_CTR_ORDER-SFTRT = LS_3490-SFT_RATE.
    GS_MAIN_CTR_ORDER-MENGE03 = LS_3490-ROP_QTY.
    GS_MAIN_CTR_ORDER-ROPRT = LS_3490-ROP_RATE.
    GS_MAIN_CTR_ORDER-LENGTH = LS_3490-LENGTH.
    CASE LS_3490-AUF_TYP.
      WHEN 'A'.
        GS_MAIN_CTR_ORDER-GUBUN = 'MTS'.
      WHEN 'B'.
        GS_MAIN_CTR_ORDER-GUBUN = '구다이스'.
    ENDCASE.
    GS_MAIN_CTR_ORDER-STATUS = ICON_LED_GREEN.
    GS_MAIN_CTR_ORDER-MESSAGE = LS_3490-STAT_MSG.
    GS_MAIN_CTR_ORDER-ORDNR = LS_3490-ORDNR.
    GS_MAIN_CTR_ORDER-ERDAT = LS_3490-ERDAT.
    GS_MAIN_CTR_ORDER-GAMNG = LS_3490-WEMNG.
    GS_MAIN_CTR_ORDER-CRDAT = LS_3490-CRDAT.
    GS_MAIN_CTR_ORDER-CRTIM = LS_3490-CRTIM.
    GS_MAIN_CTR_ORDER-CRDAT = LS_3490-CRDAT.
    APPEND GS_MAIN_CTR_ORDER TO GT_MAIN_CTR_ORDER.

  ENDLOOP.

  SORT GT_MAIN_CTR_ORDER BY MATNR ERDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS '0500'.
  SET TITLEBAR '0500'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0500 OUTPUT.
  IF GO_GRID_0500 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0400.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0500 .

  CREATE OBJECT GO_CONTAIN_0500
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

  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0500 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.
  DATA : LV_TEXT3 TYPE CHAR100.

  CLEAR GS_LAYOUT_0500.
  GS_LAYOUT_0500-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0500-SEL_MODE   = 'D'.
  GS_LAYOUT_0500-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0500-SMALLTITLE = 'X'.

  CLEAR LV_TEXT2.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT2 SEPARATED BY SPACE.
  LV_TEXT2 = LV_TEXT2 && ','.

  CLEAR LV_TEXT3.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT3 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT2 LV_TEXT3 INTO GS_LAYOUT_0500-GRID_TITLE SEPARATED BY SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0500 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0500 .

  REFRESH GT_EXCLUDE_0500.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0500_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0500_DISPLAY .

  CALL METHOD GO_GRID_0500->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0500
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0500
    CHANGING
      IT_OUTTAB            = GT_MAIN_CTR_ORDER
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0500 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

* MACRO
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LOOP AT GT_MAIN_CTR_ORDER ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE : 'GUBUN' ALV_STYLE_COLOR_INT_KEY,
                                        'STATUS' ALV_STYLE_COLOR_INT_KEY,
                                        'MESSAGE' ALV_STYLE_COLOR_INT_KEY,
                                        'ORDNR' ALV_STYLE_COLOR_INT_KEY.

    <LS_MAIN>-CELLTAB = LT_CELLTAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                     PV_MODIFIED
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  DATA : LV_CAL_MENGE TYPE MENGE_D.

  CASE P_SENDER.
    WHEN GO_GRID_0400.
      LOOP AT PT_GOOD_CELLS INTO DATA(LS_CELLS).
        CASE LS_CELLS-FIELDNAME.
* 잔전재고 변경시 ROP, 생산옫더 수량 변경
          WHEN 'SFTST'.
            READ TABLE GT_MAIN_CTR_ORDER ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
* ROP = ROP = ( "안전재고" * "ROP비율(%)" )
            <LS_MAIN>-MENGE03 = <LS_MAIN>-SFTST * <LS_MAIN>-ROPRT.

            IF <LS_MAIN>-CLABS >= <LS_MAIN>-MENGE03. " 재고수량이 ROP보다 작은 경우 하기의 계산식으로 오더수량을 제안함
              <LS_MAIN>-GAMNG = 0.
            ELSE.
              " 안전재고"/"조장단위)으로 나눈 값을 "조장단위"의 배수로 표기  오더수량 = ( "안전재고" / "조장단위" ) * "조장단위"
*  ↑ ( "안전재고" / "조장단위" ) 內 몫을 정수에서 올림 처리
              CLEAR LV_CAL_MENGE.
              LV_CAL_MENGE = <LS_MAIN>-SFTST / <LS_MAIN>-LENGTH.
*             올림처리후 오더 수량 계산
              PERFORM CONV_UPPPER_ROUND USING 1 CHANGING LV_CAL_MENGE.
              <LS_MAIN>-GAMNG = <LS_MAIN>-LENGTH * LV_CAL_MENGE.
            ENDIF.

          WHEN 'MENGE03'.

            READ TABLE GT_MAIN_CTR_ORDER ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.

            IF <LS_MAIN>-CLABS >= <LS_MAIN>-MENGE03. " 재고수량이 ROP보다 작은 경우 하기의 계산식으로 오더수량을 제안함
              <LS_MAIN>-GAMNG = 0.
            ELSE.
              " 안전재고"/"조장단위)으로 나눈 값을 "조장단위"의 배수로 표기  오더수량 = ( "안전재고" / "조장단위" ) * "조장단위"
*  ↑ ( "안전재고" / "조장단위" ) 內 몫을 정수에서 올림 처리
              CLEAR LV_CAL_MENGE.
              LV_CAL_MENGE = <LS_MAIN>-SFTST / <LS_MAIN>-LENGTH.
*             올림처리후 오더 수량 계산
              PERFORM CONV_UPPPER_ROUND USING 1 CHANGING LV_CAL_MENGE.
              <LS_MAIN>-GAMNG = <LS_MAIN>-LENGTH * LV_CAL_MENGE.
            ENDIF.

        ENDCASE.
      ENDLOOP.

      PERFORM REFRESH_GRID USING GO_GRID_0400.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_0400 .

  CHECK GV_ZTYPE = 'B'.

  DATA : LT_F4 TYPE LVC_T_F4,
         LS_F4 TYPE LVC_S_F4.

  CLEAR : LT_F4.

  LS_F4-FIELDNAME = 'ARBPL'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_0400->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      --> PS_ROW_NO
*&      <-- PV_FIELDVALUE
*&---------------------------------------------------------------------*
FORM F4_ARBPL  USING    PV_FIELDNAME TYPE LVC_FNAME
                             PS_ROW_NO  TYPE LVC_S_ROID
               CHANGING PV_FIELDVALUE TYPE LVC_VALUE.

  DATA : BEGIN OF LS_TABLE,
           ARBPL TYPE CRHD_V1-ARBPL,
           KTEXT TYPE CRHD_V1-KTEXT,
         END OF LS_TABLE.
  DATA : LT_TABLE LIKE TABLE OF LS_TABLE.
  DATA : LV_FIELDNAME TYPE  LVC_FNAME.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  READ TABLE GT_MAIN_CTR_ORDER INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.


  SELECT DISTINCT * FROM ZGTCVROUTING
    INTO TABLE @DATA(LT_ROUTING)
   WHERE MATNR = @LS_MAIN-MATNR
      AND WERKS = @P_WERKS.

  IF LT_ROUTING[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROUTING INTO DATA(LS_ROUTING).
    APPEND INITIAL LINE TO LT_TABLE ASSIGNING FIELD-SYMBOL(<LS_TABLE>).
    <LS_TABLE>-ARBPL = LS_ROUTING-ARBPL.
    <LS_TABLE>-KTEXT = LS_ROUTING-KTEXT.
  ENDLOOP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = PV_FIELDNAME
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'ARBPL'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '설비조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_TABLE                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  PV_FIELDVALUE = LS_RETURN_TAB-FIELDVAL.   "F4에서 선택한 값을 다시 넣어줌

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_LINK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_STOCK_LINK_INFO .

  CLEAR: GT_LINK_DETAIL, GT_LINK_STOCK.

  CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
    EXPORTING
      I_WERKS        = P_WERKS
      I_LGORT        = '3410'
      IT_MATNR       = GT_MATNR
    TABLES
      OT_LINK_DETAIL = GT_LINK_DETAIL
      OT_LINK_STOCK  = GT_LINK_STOCK.

  SORT GT_LINK_STOCK BY MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_QUINTITY_CONV_UINT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_MATNR
*&      --> LS_MAIN_WMENG
*&      --> LS_MAIN_VRKME
*&      --> LS_MAIN_MEINS
*&      <-- <LS_MAIN>_WMENG
*&---------------------------------------------------------------------*
FORM GET_QUINTITY_CONV_UINT  USING    PV_MATNR TYPE MATNR
                                      PV_IN_MENGE TYPE MENGE_D
                                      PV_IN_MEINS TYPE MEINS
                                      PV_OUT_MEINS TYPE MEINS
                             CHANGING PV_OUT_MENGE TYPE MENGE_D.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_IN_MEINS
      I_OUT_ME             = PV_OUT_MEINS
      I_MENGE              = PV_IN_MENGE
    IMPORTING
      E_MENGE              = PV_OUT_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MOSU>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PR  CHANGING PS_MOSU LIKE GS_MAIN_CTR_ORDER
                                           PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LS_PR_INFOR TYPE ZGTPPS0004.
  DATA : LT_CHART TYPE ZGTPPY0005.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_PSMNG_C(30) TYPE C.

  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @GS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS.

* 전송데이터 구성
  IF PS_MOSU-LENGTH NE 0.
    LV_INLENGTH = PS_MOSU-LENGTH.
  ELSE.
    LV_INLENGTH = PS_MOSU-GAMNG.
  ENDIF.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
  <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
  <LS_CHART>-ATWRT = LV_INLENGTH_C.

  IF PS_MOSU-LENGTH NE 0.
    LV_INFACTOR = PS_MOSU-GAMNG / PS_MOSU-LENGTH.
  ELSE.
    LV_INFACTOR = 1.
  ENDIF.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
  <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
  <LS_CHART>-ATWRT = LV_INFACTOR_C.

  LV_PSMNG_C = PS_MOSU-GAMNG.
  CONDENSE : LV_PSMNG_C.

  CLEAR LS_PR_INFOR.
  LS_PR_INFOR-BSART = 'NB'.
*  LS_PR_INFOR-KNTTP = 'M'.
*  LV_DATE = GS_MAIN_DISP-EDATU - 1.
  LS_PR_INFOR-EEIND = SY-DATUM.
  LS_PR_INFOR-LPEIN = 'T'.
  LS_PR_INFOR-WERKS = P_WERKS.
  LS_PR_INFOR-EKGRP = GS_EKORG-EKGRP.
  LS_PR_INFOR-AFNAM = SY-UNAME.
  LS_PR_INFOR-MATNR = PS_MOSU-MATNR.
  LS_PR_INFOR-EKORG = GS_EKORG-EKORG.
  LS_PR_INFOR-MENGE = LV_PSMNG_C.


  DATA : LV_RESULT TYPE CHAR01.
  DATA : LV_BANFN TYPE BANFN.


  CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
    EXPORTING
      IS_PR_INFOR = LS_PR_INFOR
    IMPORTING
      EV_RESULT   = LV_RESULT
      EV_BANFN    = LV_BANFN
    TABLES
      IT_CHART    = LT_CHART.

* 결과처리

  IF LV_RESULT NE 'S'.
    PV_CHK_ERR = ABAP_TRUE.
    PS_MOSU-STATUS = ICON_LED_RED.
    PS_MOSU-MESSAGE = 'ERROR'.
    RETURN.
  ENDIF.

  PS_MOSU-ORDNR = LV_BANFN.
  PS_MOSU-STATUS = ICON_LED_GREEN.
  PS_MOSU-MESSAGE = 'MTS구매요청 생성 완료'.

  IF P_WERKS EQ '6500'. " 군포 pr생성시 드럼 자동지정 수행
    DATA : LT_BANFN TYPE RANGE OF EBAN-BANFN.
    APPEND INITIAL LINE TO LT_BANFN ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
    <LS_BANFN>-SIGN = 'I'.
    <LS_BANFN>-OPTION = 'EQ'.
    <LS_BANFN>-LOW = LV_BANFN.

    SUBMIT ZGTPPR2330 WITH P_SLSORD = ' '
                      WITH P_PR = 'X'
                      WITH S_BANFN IN LT_BANFN
                      WITH P_DRUM = 'H'
                      WITH P_AUTO = ABAP_TRUE
                      WITH P_BATCH = ABAP_TRUE
                      AND RETURN.

  ENDIF.

ENDFORM.
