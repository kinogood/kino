*&---------------------------------------------------------------------*
*&  Include           ZSDR1040F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  create_note_editor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_NOTE_EDITOR .
* create SAP Custom Container; define container object in dynpro
  CREATE OBJECT TEXTEDIT_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME              = 'NOTE_EDITOR'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
  IF SY-SUBRC <> 0.
*   add your handling
  ENDIF.

* call constructor to initialize and link the text edit control
* to SAP Custom Container
  CREATE OBJECT NOTE_EDITOR
    EXPORTING
      PARENT                     = TEXTEDIT_CUSTOM_CONTAINER
      WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
      WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>TRUE
    EXCEPTIONS
      OTHERS                     = 1.
  IF SY-SUBRC <> 0.
*   add your handling
  ENDIF.

  IF G_ACTIVETAB = 'PUSH1'.
    READONLY = NOTE_EDITOR->FALSE.
*ZLSGSD4 ZSDR1800에서 호출할 때는 노트 바로 수정 가능
  ELSEIF SY-CALLD = 'X'   AND  SY-UCOMM EQ 'CHAN'
                          AND ( SY-TCODE NE 'SE38'
                          AND   SY-TCODE NE 'SE80'
                          AND   SY-TCODE NE 'SEU_INT' ).
    READONLY = NOTE_EDITOR->FALSE.
*ZLSGSD4
  ELSE.
    READONLY = NOTE_EDITOR->TRUE.
  ENDIF.

* set the new readonly_mode
  CALL METHOD NOTE_EDITOR->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE = READONLY.

* without toolbar?
*  if p_tbar = space.
  CALL METHOD NOTE_EDITOR->SET_TOOLBAR_MODE
    EXPORTING
*     toolbar_mode = cl_gui_textedit=>false
      TOOLBAR_MODE = CL_GUI_TEXTEDIT=>TRUE
    EXCEPTIONS
      OTHERS       = 1.
  IF SY-SUBRC <> 0.
*     add your handling
  ENDIF.
*  endif.

* without statusbar?
*  if p_sbar = space.
  CALL METHOD NOTE_EDITOR->SET_STATUSBAR_MODE
    EXPORTING
*     statusbar_mode = cl_gui_textedit=>false
      STATUSBAR_MODE = CL_GUI_TEXTEDIT=>TRUE
    EXCEPTIONS
      OTHERS         = 1.
  IF SY-SUBRC <> 0.
*     add your handling
  ENDIF.
*  endif.


ENDFORM.                    " create_note_editor
*&---------------------------------------------------------------------*
*&      Form  send_text_to_note_editor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_TEXT_TO_NOTE_EDITOR .
* convert itf text to stream text
  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    TABLES
      ITF_TEXT    = ITFTEXT
      TEXT_STREAM = NOTETAB.
* and send text to note editor
  CALL METHOD NOTE_EDITOR->SET_TEXT_AS_STREAM
    EXPORTING
      TEXT   = NOTETAB
    EXCEPTIONS
      OTHERS = 1.
  IF SY-SUBRC <> 0.
*   add your handling
  ENDIF.

ENDFORM.                    " send_text_to_note_editor

*&---------------------------------------------------------------------*
*&      Form  read_notepad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_NOTEPAD .
  CHECK G_ACTIVETAB = 'PUSH2'.

  CLEAR WA_THEAD.
  WA_THEAD-TDID = 'ZTS2'.
  WA_THEAD-TDNAME = GS_ZSD0106T-ZPJNO.
  WA_THEAD-TDOBJECT = 'ZTSD02'.
  WA_THEAD-TDSPRAS  = SY-LANGU.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      ID                      = WA_THEAD-TDID
      LANGUAGE                = WA_THEAD-TDSPRAS
      NAME                    = WA_THEAD-TDNAME
      OBJECT                  = WA_THEAD-TDOBJECT
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
    IMPORTING
      HEADER                  = WA_THEAD
    TABLES
*     lines                   = it_long
      LINES                   = ITFTEXT
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    REFRESH ITFTEXT.
  ENDIF.

ENDFORM.                    " read_notepad
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  IF G_ACTIVETAB = 'PUSH1'.
    SET TITLEBAR '0100'.
  ELSE.
    SET TITLEBAR '0200'.
  ENDIF.
  PERFORM APPEND_IT_FCODE.   "GUI STATUS 설정

  SET PF-STATUS 'STATUS01' EXCLUDING IT_FCODE.

  IF NOTE_EDITOR IS INITIAL.
    PERFORM CREATE_NOTE_EDITOR.
  ENDIF.

  PERFORM SEND_TEXT_TO_NOTE_EDITOR.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.

  CASE GV_OKCODE.
*{ ZLSGSD4 - s 외부에서 back할 시 바로 프로그램 나가게(ex ZSDR1800)
      IF SY-CALLD = 'X' AND ( SY-TCODE NE 'SE38'
                          AND SY-TCODE NE 'SE80'
                          AND SY-TCODE NE 'SEU_INT' ).
        LEAVE PROGRAM.
      ENDIF.
*} ZLSGSD4 - e
    WHEN 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.

  CASE GV_OKCODE.
    WHEN 'SAVE'.
*     Note에 작업한 것을 저장
      PERFORM SAVE_DATA.   "ZLSGSD4
*      PERFORM SAVE_ZSD0106T_DATA.
      PERFORM READ_TEXT_FROM_NOTE_EDITOR.
      PERFORM SAVE_TEXT_INFO.
      PERFORM DESTROY_NOTE_EDITOR.
      LEAVE TO SCREEN 0.
    WHEN 'CHAN'.
      PERFORM UPDATE_DATA.  "ZLSGSD4
*      PERFORM UPDATE_ZSD0106T_DATA.
      PERFORM READ_TEXT_FROM_NOTE_EDITOR.
      PERFORM SAVE_TEXT_INFO.
      PERFORM DESTROY_NOTE_EDITOR.
    WHEN OTHERS.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.

  CASE GV_OKCODE.
    WHEN 'SAVE'.
*     Note에 작업한 것을 저장
      PERFORM UPDATE_DATA.   "ZLSGSD4
*      PERFORM UPDATE_ZSD0106T_DATA.
      PERFORM READ_TEXT_FROM_NOTE_EDITOR.
      PERFORM SAVE_TEXT_INFO.
      PERFORM DESTROY_NOTE_EDITOR.

    WHEN 'CHAN'.
      READONLY = NOTE_EDITOR->FALSE.

* set the new readonly_mode
      CALL METHOD NOTE_EDITOR->SET_READONLY_MODE
        EXPORTING
          READONLY_MODE = READONLY.
    WHEN 'DISP'.
      READONLY = NOTE_EDITOR->TRUE.

* set the new readonly_mode
      CALL METHOD NOTE_EDITOR->SET_READONLY_MODE
        EXPORTING
          READONLY_MODE = READONLY.

    WHEN OTHERS.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  read_text_from_note_editor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_TEXT_FROM_NOTE_EDITOR .

* read text from note editor
  CALL METHOD NOTE_EDITOR->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT = NOTETAB.
  PERFORM FLUSH.
* and convert text stream into ITF text
  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = NOTETAB
      ITF_TEXT    = ITFTEXT.

ENDFORM.                    " read_text_from_note_editor
*&---------------------------------------------------------------------*
*&      Form  save_text_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_TEXT_INFO .
  CLEAR WA_THEAD.
  WA_THEAD-TDID = 'ZTS2'.
*  CONCATENATE g_300_spec_cd g_300_revision_no
*              INTO wa_thead-tdname.
  WA_THEAD-TDNAME = GS_ZSD0106T-ZPJNO.
  WA_THEAD-TDOBJECT = 'ZTSD02'.
  WA_THEAD-TDSPRAS  = SY-LANGU.
  REFRESH IT_LONG.
  LOOP AT ITFTEXT.
    IT_LONG-TDFORMAT = '*'.
    IT_LONG-TDLINE   = ITFTEXT-TDLINE.
    APPEND IT_LONG.
    CLEAR  IT_LONG.
  ENDLOOP.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      CLIENT          = SY-MANDT
      HEADER          = WA_THEAD
*     INSERT          = ' '
      SAVEMODE_DIRECT = 'X'
*     OWNER_SPECIFIED = ' '
*     LOCAL_CAT       = ' '
*       IMPORTING
*     FUNCTION        =
*     NEWHEADER       =
    TABLES
      LINES           = IT_LONG
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBJECT          = 4
      OTHERS          = 5.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
  ENDIF.


ENDFORM.                    " save_text_info
*&---------------------------------------------------------------------*
*&      Form  destroy_note_editor
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESTROY_NOTE_EDITOR .
* destroy note editor
  IF NOT NOTE_EDITOR IS INITIAL.
    CALL METHOD NOTE_EDITOR->FREE
      EXCEPTIONS
        OTHERS = 1.
    IF SY-SUBRC <> 0.
*     add your handling
    ENDIF.
    FREE NOTE_EDITOR.
  ENDIF.

* destroy container
  IF NOT TEXTEDIT_CUSTOM_CONTAINER IS INITIAL.
    CALL METHOD TEXTEDIT_CUSTOM_CONTAINER->FREE
      EXCEPTIONS
        OTHERS = 1.
    IF SY-SUBRC <> 0.
*     add your handling
    ENDIF.
    FREE TEXTEDIT_CUSTOM_CONTAINER.
  ENDIF.

* final flush
  PERFORM FLUSH.

ENDFORM.                    " destroy_note_editor
*&---------------------------------------------------------------------*
*&      Form  flush
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FLUSH .

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.
  IF SY-SUBRC <> 0.
*   add your handling
  ENDIF.


ENDFORM.                    " flush
*&---------------------------------------------------------------------*
*&      Form  p0000_entries_pepst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P0000_ENTRIES_PEPST  USING    P_SPMON VALUE(P_DYNPROFIELD).

  DATA: DYNPRO_VALUES TYPE TABLE OF DYNPREAD WITH HEADER LINE.
  DATA: PRONM TYPE D020S-PROG,
        DYNNR TYPE D020S-DNUM,
        CLMON TYPE ISELLIST-MONTH,
        RCODE TYPE SY-UCOMM.
  DATA: L_FIELD              LIKE HELP_INFO-DYNPROFLD.

  MOVE P_DYNPROFIELD    TO L_FIELD.
  MOVE L_FIELD TO DYNPRO_VALUES-FIELDNAME.
  APPEND DYNPRO_VALUES.

  PRONM = SY-REPID.
  DYNNR = SY-DYNNR.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = PRONM
      DYNUMB             = DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = DYNPRO_VALUES.

  READ TABLE DYNPRO_VALUES INDEX 1.

  MOVE DYNPRO_VALUES-FIELDVALUE TO CLMON.
  IF CLMON IS INITIAL.
    CLMON = SY-DATLO(6).
  ENDIF.
  PERFORM POPUP_TO_SELECT_MONTH CHANGING CLMON.
  CHECK NOT CLMON IS INITIAL.
  CONCATENATE CLMON+0(4) '.' CLMON+4(2) INTO P_SPMON.
  CONDENSE P_SPMON NO-GAPS.

ENDFORM.                    " p0000_entries_pepst
*&---------------------------------------------------------------------*
*&      Form  P001_SMATKL_LOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_MATKL_LOW  text
*----------------------------------------------------------------------*
FORM P001_P_ZPJNO USING    P_ZPJNO.

  DATA:  SELF4HELP  LIKE HELP_VALUE OCCURS 5 WITH HEADER LINE.
  DATA : BEGIN OF WT_ZSD0106T OCCURS 0,
           ZPJNO LIKE ZSD0106T-ZPJNO,
           ZPTXT LIKE ZSD0106T-ZPTXT,
         END   OF WT_ZSD0106T.
  DATA : WL_TABIX LIKE SY-TABIX.
  DATA : WL_ZSD0106T LIKE ZSD0106T.

  CLEAR : WT_ZSD0106T, WT_ZSD0106T[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE WT_ZSD0106T
       FROM ZSD0106T.

  IF SY-SUBRC NE 0.
    MESSAGE I000 WITH TEXT-027. EXIT.
  ENDIF.

  SELF4HELP-TABNAME    = 'ZSD0106T'.
  SELF4HELP-FIELDNAME  = 'ZPJNO'.
  SELF4HELP-SELECTFLAG = 'X'.
  APPEND_TAB SELF4HELP.

  SELF4HELP-TABNAME    = 'ZSD0106T'.
  SELF4HELP-FIELDNAME  = 'ZPTXT'.
  APPEND_TAB SELF4HELP.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = 'ZPJNO'
    IMPORTING
      IND                          = WL_TABIX
    TABLES
      FIELDS                       = SELF4HELP
      FULL_TABLE                   = WT_ZSD0106T
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.
  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH TEXT-027. EXIT.
  ENDIF.

  READ TABLE WT_ZSD0106T INDEX WL_TABIX.
  IF SY-SUBRC NE 0.
*    MESSAGE I000 WITH TEXT-033. EXIT.
  ENDIF.

  P_ZPJNO = WT_ZSD0106T-ZPJNO.

  PERFORM DYNP_VALUES_UPDATE USING 'P_ZPJNO'
                                   WT_ZSD0106T-ZPJNO.

ENDFORM.                    "
*&---------------------------------------------------------------------*
*&      Form  DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0070   text
*      -->P_LT_VIEW_MOKPYO  text
*----------------------------------------------------------------------*
FORM DYNP_VALUES_UPDATE USING     P_FIELDNAME
                                 P_FIELDVALUE.
  DATA: L_LINE TYPE I.

  REFRESH DYNPFIELDS. CLEAR DYNPFIELDS.

  GET CURSOR LINE L_LINE.
  DYNPFIELDS-FIELDNAME  = P_FIELDNAME.
  DYNPFIELDS-FIELDVALUE = P_FIELDVALUE.
  DYNPFIELDS-STEPL      = L_LINE.
  APPEND DYNPFIELDS.

*--->화면에 값을 넣어줌...
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = DYNPFIELDS.

ENDFORM.                    " DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*&      Form  popup_to_select_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_SELECT_MONTH  CHANGING E_CLMON TYPE ISELLIST-MONTH.

  DATA: L_CLMON              TYPE ISELLIST-MONTH.
  DATA: P_RCODE              TYPE SY-SUBRC.
  L_CLMON = E_CLMON.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = L_CLMON
    IMPORTING
      SELECTED_MONTH             = L_CLMON
      RETURN_CODE                = P_RCODE
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 01
      HOLIDAY_CALENDAR_NOT_FOUND = 02
      MONTH_NOT_FOUND            = 03.

  E_CLMON = L_CLMON.

ENDFORM.                    " popup_to_select_month

*&---------------------------------------------------------------------*
*&      Form  read_main_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_MAIN_DATA .
  CHECK G_ACTIVETAB = 'PUSH1'.

  CLEAR : GT_ZSD0106T, GT_ZSD0106T[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ZSD0106T
             FROM ZSD0106T
             WHERE SPMON = P_SPMON
*-[SRM2109-05740_S
*              AND  SPART = P_SPART "키값 아니라서 주석처리
              AND ERDAT = SY-DATUM
              AND ZPJNO LIKE 'PD%'
*]-SRM2109-05740_E
              AND  ZCATG = 'PROJ'.

ENDFORM.                    " read_main_data
*&---------------------------------------------------------------------*
*&      Form  intial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INTIAL_DATA .

  IMPORT G_INIT
           G_DYNNR
           MYTAB FROM MEMORY ID 'SCREEN_CR70'.

  MYTAB-PROG = SY-REPID.
  BUTTON1 = TEXT-T01.          "비용전표별 대체전표생성
  BUTTON2 = TEXT-T02.          "결산전표처리 및 선급명세서출력
  IF G_INIT IS INITIAL.
    G_DYNNR = MYTAB-DYNNR = 0010.
    MYTAB-ACTIVETAB = 'BUTTON1'.
    G_INIT = 'X'.
  ENDIF.

*- initial data...초기에만 실행시킨다...초기실행이고 import받은
*                 gt_activetab이 있는경우 -> 삭제
  IMPORT G_ACTIVETAB FROM MEMORY ID 'G_ACTIVETAB'.
  IF X_INIT = 'Y' AND NOT G_ACTIVETAB IS INITIAL.
    X_INIT = 'N'.   "재실행
    DELETE FROM MEMORY ID 'G_ACTIVETAB'.
  ELSE.           "초기실행이고 import된 값이 없을때...default
    G_ACTIVETAB = 'PUSH1'.
  ENDIF.
  MYTAB-ACTIVETAB = G_ACTIVETAB.
  PERFORM P0000_CHOICE_TAB.


*--- texts
*  text_001 = '기본조건'.
*  text_002 = '선택조건'.
*  text_003 = '상세조건'.
*  text_004 = '선택조건'.
*  text_005 = '테스트실행'.


ENDFORM.                    " intial_data
*&---------------------------------------------------------------------*
*&      Form  p0000_choice_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P0000_CHOICE_TAB .
  IF NOT SY-UCOMM IS INITIAL.
    G_ACTIVETAB = SY-UCOMM.
  ENDIF.

  CASE SY-DYNNR.
    WHEN 1000 OR 0010 OR 0020 OR 0030.
      CASE G_ACTIVETAB.
        WHEN 'PUSH1'.
          G_DYNNR        = MYTAB-DYNNR = 0010.
        WHEN 'PUSH2'.
          G_DYNNR        = MYTAB-DYNNR = 0020.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " p0000_choice_tab
*&---------------------------------------------------------------------*
*&      Form  check_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .

  CHECK G_ACTIVETAB = 'PUSH1'.

  CLEAR : GV_FLAG.

*  if r01 eq 'X'.

  IF P_SPMON IS INITIAL.
    CALL FUNCTION 'WS_MSG'
      EXPORTING
        MSG_TYPE = 'I'
        TEXT     = '해당생성년월을 입력하세요.'
        TITL     = '검색결과'.
    GV_FLAG = 'X'.
    EXIT.
  ENDIF.

*  IF P_SPART IS INITIAL.
*    CALL FUNCTION 'WS_MSG'
*      EXPORTING
*        MSG_TYPE = 'I'
*        TEXT     = '해당SPG를 입력하세요.'
*        TITL     = '검색결과'.
*    GV_FLAG = 'X'.
*    EXIT.
*  ENDIF.
*  endif.


** SPG '22', '40'는 대상에서 제외
*  CLEAR : LR_SPART, LR_SPART[].
*  LR_SPART-SIGN   = 'I'.
*  LR_SPART-OPTION = 'EQ'.
*  LR_SPART-LOW    = '22'.
*  APPEND LR_SPART.  CLEAR LR_SPART.
*  LR_SPART-SIGN   = 'I'.
*  LR_SPART-OPTION = 'EQ'.
*  LR_SPART-LOW    = '40'.
*  APPEND LR_SPART.  CLEAR LR_SPART.
**  lr_spart-sign   = 'I'.
**  lr_spart-option = 'EQ'.
**  lr_spart-low    = '41'.
**  append lr_spart.  clear lr_spart.
*
*
*  IF P_SPART IN LR_SPART.
*    CALL FUNCTION 'WS_MSG'
*      EXPORTING
*        MSG_TYPE = 'I'
*        TEXT     = '해당SPG는 대상이 아닙니다.'
*        TITL     = '검색결과'.
*    GV_FLAG = 'X'.
*    EXIT.
*  ENDIF.

ENDFORM.                    " check_data
*&---------------------------------------------------------------------*
*&      Form  check_data_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA_200.

  CHECK G_ACTIVETAB = 'PUSH2'.

  CLEAR : GV_FLAG.

  IF P_PJNO IS INITIAL.
    CALL FUNCTION 'WS_MSG'
      EXPORTING
        MSG_TYPE = 'I'
        TEXT     = '해당Project NO을 입력하세요.'
        TITL     = '검색결과'.
    GV_FLAG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " check_data_200

*&---------------------------------------------------------------------*
*&      Form  modify_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA .

  CONSTANTS LC_KUNNR TYPE KUNNR VALUE '106022'.

  CHECK G_ACTIVETAB = 'PUSH1'.

  DATA : LV_COUNT(3) TYPE N.


  IF R01 EQ 'X'.
    GS_ZSD0106T-SPMON = P_SPMON.
*    GS_ZSD0106T-SPART = P_SPART.
    GS_ZSD0106T-ZPDAT = SY-DATUM.

*-- 판매처 / 제품군 / 영업사원 고정값 구성
    GS_ZSD0106T-KUNNR = LC_KUNNR.
    GS_ZSD0106T-SPART = |60|.
    GS_ZSD0106T-PERNR = SY-UNAME.

    LV_COUNT = 1.

*-[SRM2109-05740_S
*만약에 M + 숫자 9로 한다면.
    DELETE GT_ZSD0106T WHERE ZPJNO+0(2) <> 'PD'.
*]-SRM2109-05740_E

    SORT GT_ZSD0106T DESCENDING BY ZPJNO.

    READ TABLE GT_ZSD0106T INDEX 1.

    IF SY-SUBRC EQ 0.
*-[SRM2109-05740_S
      LV_COUNT  = LV_COUNT + GT_ZSD0106T-ZPJNO+7(3).
      CONCATENATE 'PD' GS_ZSD0106T-ZPDAT+2(6) LV_COUNT
             INTO GS_ZSD0106T-ZPJNO.
*      LV_COUNT = LV_COUNT + GT_ZSD0106T-ZPJNO+8(2).
*      CONCATENATE GS_ZSD0106T-SPMON+2(4) '-' GS_ZSD0106T-SPART '-'
*                  LV_COUNT INTO GS_ZSD0106T-ZPJNO.
    ELSE.
      CONCATENATE 'PD' GS_ZSD0106T-ZPDAT+2(6) LV_COUNT
             INTO GS_ZSD0106T-ZPJNO.
*      CONCATENATE GS_ZSD0106T-SPMON+2(4) '-' GS_ZSD0106T-SPART '-'
*                  LV_COUNT INTO GS_ZSD0106T-ZPJNO.
*]-SRM2109-05740_E
    ENDIF.
  ELSE.
    GS_ZSD0106T-SPMON = P_SPMON.
*    GS_ZSD0106T-SPART = P_SPART.
    GS_ZSD0106T-ZPDAT = SY-DATUM.

*-- 판매처 / 제품군 / 영업사원 고정값 구성
    GS_ZSD0106T-KUNNR = LC_KUNNR.
    GS_ZSD0106T-SPART = |60|.
    GS_ZSD0106T-PERNR = SY-UNAME.

  ENDIF.

ENDFORM.                    " modify_data
*&---------------------------------------------------------------------*
*&      Form  read_main_data_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_MAIN_DATA_200 .
  CHECK G_ACTIVETAB = 'PUSH2'.

  CLEAR : GT_ZSD0106T, GT_ZSD0106T[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ZSD0106T
             FROM ZSD0106T
             WHERE ZPJNO = P_PJNO.


  LOOP AT GT_ZSD0106T.

** 판매처명
    SELECT  SINGLE NAME1
      INTO  G_NAME1
      FROM  KNA1
     WHERE  KUNNR  =  GT_ZSD0106T-KUNNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_ZSD0106T-KUNNR
      IMPORTING
        OUTPUT = GT_ZSD0106T-KUNNR.

    SELECT SINGLE VTEXT
      INTO G_NAME2
      FROM TSPAT
     WHERE SPRAS = SY-LANGU
       AND SPART = GT_ZSD0106T-ZSPART.

    SELECT SINGLE BEZEI
      INTO G_NAME3
      FROM TVKBT
     WHERE SPRAS = SY-LANGU
       AND VKBUR = GT_ZSD0106T-ZVKBUR.

    SELECT SINGLE BEZEI
      INTO G_NAME4
      FROM TVGRT
     WHERE SPRAS = SY-LANGU
       AND VKGRP = GT_ZSD0106T-ZVKGRP.

*{ ZLSGSD4
    CLEAR : GS_ZSD0106TA.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF GS_ZSD0106TA
           FROM ZSD0106TA
           WHERE ZPJNO = P_PJNO.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE POSID
        INTO GS_ZSD0106TA-POSID
        FROM PRPS
       WHERE PSPNR EQ GS_ZSD0106TA-PS_PSP_PNR.

      CALL FUNCTION 'CONVERSION_EXIT_PROJN_OUTPUT'
        EXPORTING
          INPUT  = GS_ZSD0106TA-POSID
        IMPORTING
          OUTPUT = GS_ZSD0106TA-POSID.

    ENDIF.
*} ZLSGSD4


    MODIFY  GT_ZSD0106T.
    CLEAR  GT_ZSD0106T.

  ENDLOOP.

ENDFORM.                    " read_main_data_200
*&---------------------------------------------------------------------*
*&      Form  modify_data_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_200 .
  CHECK G_ACTIVETAB = 'PUSH2'.

  READ TABLE GT_ZSD0106T INDEX 1.

  GS_ZSD0106T = GT_ZSD0106T.

ENDFORM.                    " modify_data_200
*&---------------------------------------------------------------------*
*&      Form  p1000_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P1000_INITIAL_DATA .

*//Back 했을때 원래 조회하던 화면이 나올수 있도록 global data로 넘김
  G_ACTIVETAB = MYTAB-ACTIVETAB.
  EXPORT G_ACTIVETAB TO MEMORY ID 'G_ACTIVETAB'.

*{ ZLSGSD4 - s
  IF SY-CALLD = 'X' AND ( SY-TCODE NE 'SE38'
                      AND SY-TCODE NE 'SE80'
                      AND SY-TCODE NE 'SEU_INT' ).
    SY-UCOMM = 'CHAN'.
    G_ACTIVETAB = 'PUSH2'.
  ENDIF.
*} ZLSGSD4



ENDFORM.                    " p1000_initial_data
*&---------------------------------------------------------------------*
*&      Form  save_zsd0106t_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_ZSD0106T_DATA .


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ZSD0106T-KUNNR
    IMPORTING
      OUTPUT = GS_ZSD0106T-KUNNR.

  GS_ZSD0106T-ZGUBUN = 'S'.
  GS_ZSD0106T-ZVKBUR = |1710|.
  GS_ZSD0106T-ZVKGRP = |172|.
  GS_ZSD0106T-LAND1  = |KR|.
  GS_ZSD0106T-ERDAT = SY-DATUM.
  GS_ZSD0106T-ERZET = SY-UZEIT.
  GS_ZSD0106T-ERNAM = SY-UNAME.
  GS_ZSD0106T-ZCATG = 'PROJ'.

  INSERT ZSD0106T FROM GS_ZSD0106T.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    FREE MEMORY.

*-- MES 송신 수행
    PERFORM SEND_IF_MES.

    SET PARAMETER ID 'ZPJ' FIELD GS_ZSD0106T-ZPJNO.
    MESSAGE S002 WITH GS_ZSD0106T-ZPJNO '을 정상적으로 저장하였습니다.'.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_ZSD0106T-KUNNR
    IMPORTING
      OUTPUT = GS_ZSD0106T-KUNNR.

ENDFORM.                    " save_zsd0106t_data
*&---------------------------------------------------------------------*
*&      Form  update_zsd0106t_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZSD0106T_DATA .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ZSD0106T-KUNNR
    IMPORTING
      OUTPUT = GS_ZSD0106T-KUNNR.

  GS_ZSD0106T-ERDAT = SY-DATUM.
  GS_ZSD0106T-ERZET = SY-UZEIT.
  GS_ZSD0106T-ERNAM = SY-UNAME.

  MODIFY ZSD0106T FROM GS_ZSD0106T.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    MESSAGE S001 WITH '정상적으로 저장하였습니다.'.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_ZSD0106T-KUNNR
    IMPORTING
      OUTPUT = GS_ZSD0106T-KUNNR.


ENDFORM.                    " update_zsd0106t_data
*&---------------------------------------------------------------------*
*&      Form  APPEND_GT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPEND_IT_FCODE .

  REFRESH IT_FCODE.
  CASE G_ACTIVETAB.
    WHEN 'PUSH1'. "
      MOVE 'DISP' TO IT_FCODE-FCODE. APPEND IT_FCODE. CLEAR: IT_FCODE.
      MOVE 'CHAN' TO IT_FCODE-FCODE. APPEND IT_FCODE. CLEAR: IT_FCODE.
    WHEN 'PUSH2'.  "승인요청
*      move 'SAVE' to it_fcode-fcode. append it_fcode. clear: it_fcode.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " APPEND_GT_STATUS
*&---------------------------------------------------------------------*
*&      Form  get_zpjno_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZPJNO_DATA .

  DATA:  SELF4HELP  LIKE HELP_VALUE OCCURS 5 WITH HEADER LINE.
  DATA : BEGIN OF WT_ZSD0106T OCCURS 0,
           ZPJNO LIKE ZSD0106T-ZPJNO,
           ZPTXT LIKE ZSD0106T-ZPTXT,
         END   OF WT_ZSD0106T.
  DATA : WL_TABIX LIKE SY-TABIX.
  DATA : WL_ZSD0106T LIKE ZSD0106T.

  CLEAR : WT_ZSD0106T, WT_ZSD0106T[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE WT_ZSD0106T
       FROM ZSD0106T.

  IF SY-SUBRC NE 0.
    MESSAGE I000 WITH TEXT-027. EXIT.
  ENDIF.

  SELF4HELP-TABNAME    = 'ZSD0106T'.
  SELF4HELP-FIELDNAME  = 'ZPJNO'.
  SELF4HELP-SELECTFLAG = 'X'.
  APPEND_TAB SELF4HELP.

  SELF4HELP-TABNAME    = 'ZSD0106T'.
  SELF4HELP-FIELDNAME  = 'ZPTXT'.
  APPEND_TAB SELF4HELP.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = 'ZPJNO'
    IMPORTING
      IND                          = WL_TABIX
    TABLES
      FIELDS                       = SELF4HELP
      FULL_TABLE                   = WT_ZSD0106T
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.
  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH TEXT-027. EXIT.
  ENDIF.

  READ TABLE WT_ZSD0106T INDEX WL_TABIX.
  IF SY-SUBRC NE 0.
*    MESSAGE I000 WITH TEXT-033. EXIT.
  ENDIF.

  GS_ZSD0106T-ZPJNO = WT_ZSD0106T-ZPJNO.

  PERFORM DYNP_VALUES_UPDATE USING 'GS_ZSD0106T-ZPJNO'
                                   WT_ZSD0106T-ZPJNO.

ENDFORM.                    " get_zpjno_data
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

*{ ZSD0106TA 테이블 수정 / 필수값은 아님
  GS_ZSD0106TA-ZPJNO = GS_ZSD0106T-ZPJNO.
*{ 2022.06.08 - s 이력 추가
  GS_ZSD0106TA-ERDAT = SY-DATUM.
  GS_ZSD0106TA-ERZET = SY-UZEIT.
  GS_ZSD0106TA-ERNAM = SY-UNAME.
*} 2022.06.08 - e 이력 추가
  MODIFY ZSD0106TA FROM GS_ZSD0106TA.

  IF SY-SUBRC EQ 0.
    PERFORM SAVE_ZSD0106T_DATA.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S001 DISPLAY LIKE 'E'
                 WITH '저장에 실패하였습니다'.
  ENDIF.

ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_DATA .

*{ 2022.06.08 - s 이력 추가
  DATA : LV_PS_PSP_PNR TYPE ZSD0106TA-PS_PSP_PNR.

  SELECT SINGLE PS_PSP_PNR
    INTO LV_PS_PSP_PNR
    FROM ZSD0106TA
   WHERE ZPJNO EQ GS_ZSD0106T-ZPJNO.

  IF LV_PS_PSP_PNR NE GS_ZSD0106TA-PS_PSP_PNR.

*ZSD0106TA 테이블 수정
    GS_ZSD0106TA-ZPJNO = GS_ZSD0106T-ZPJNO.
    GS_ZSD0106TA-ERDAT = SY-DATUM.
    GS_ZSD0106TA-ERZET = SY-UZEIT.
    GS_ZSD0106TA-ERNAM = SY-UNAME.
    MODIFY ZSD0106TA FROM GS_ZSD0106TA.

    IF SY-SUBRC EQ 0.
      PERFORM UPDATE_ZSD0106T_DATA.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S001 DISPLAY LIKE 'E'
                   WITH '저장에 실패하였습니다'.
      EXIT.
    ENDIF.

  ELSE.
    PERFORM UPDATE_ZSD0106T_DATA.
  ENDIF.
*} 2022.06.08 - e 이력 추가

ENDFORM.                    " UPDATE_DATA
*&---------------------------------------------------------------------*
*& Form send_if_mes
*&---------------------------------------------------------------------*
*&  MES 프로젝트 정보 전송 수행
*&---------------------------------------------------------------------*
FORM SEND_IF_MES .

  DATA : LV_SYSID  TYPE ZGTETARGET,
         LV_WERKS  TYPE WERKS_D,
         LV_DEST   TYPE ZDEST,
         LV_NUM    TYPE NUMC06,
         LV_DAT    TYPE CHAR10,

         LV_RESULT TYPE ZO_RESULT,
         LV_MSG    TYPE ZO_MESSAGE,
         LV_ZIFKEY TYPE TIMESTAMPL.

  DATA : LR_MREQNO TYPE RANGE OF ZGTE_MREQNO.

  DATA : LT_HTAB TYPE TABLE OF ZGTSDSIF0060 WITH EMPTY KEY,
         LT_9000 TYPE TABLE OF ZGTSDT9000 WITH EMPTY KEY,
         LT_0060 TYPE TABLE OF ZGTSDT0060 WITH EMPTY KEY.

  CLEAR : LT_HTAB, LT_9000,
          LV_NUM, LR_MREQNO.

*-- Target System 정보 확인
  CALL FUNCTION 'ZGTSD_GET_TARGETSYS'
    EXPORTING
      I_VKBUR = GS_ZSD0106T-ZVKBUR
    IMPORTING
      E_SYSID = LV_SYSID.

*-- 공통코드 기준 Plant  정보 구성
  SELECT SINGLE A~FLD_03
    FROM ZGTPPT1010 AS A
   WHERE A~MODULE_KIND EQ 'PP'
     AND A~CODEGRP     EQ '0010'
     AND A~FLD_01      EQ @LV_SYSID

   INTO @LV_WERKS.

*-- Destination 정보 구성
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

*-- User 정보 Select
  SELECT SINGLE A~NAME,  A~EMAIL

    FROM ZGTMM_CV_GETUSERNAME AS A
   WHERE A~USERID EQ @GS_ZSD0106T-PERNR

    INTO @DATA(LS_USER_INFO).

*-- 요청번호 채번 수행 : 날짜(YYMM) + 시리얼번호 6자리 - 000001 -
*  APPEND VALUE #(
*                  sign   = 'I'
*                  option = 'CP'
*                  low    = sy-datlo+2(4) && |*|
*                ) TO lr_mreqno.
*
*  SELECT MAX( a~mreqno ) AS mreqno
*    FROM zgtsdt0060 AS a
*   WHERE a~zpjno  EQ @gs_zsd0106t-zpjno
*     AND a~mreqno IN @lr_mreqno
*
*    INTO @DATA(lv_mreqno).
*
*  IF sy-subrc NE 0.
*    ADD 1 TO lv_num.
*    lv_mreqno = sy-datlo+2(4) && lv_num.
*  ENDIF.


*-- 제조지시요청 번호 채번
*-- 제조지시요청번호 10자리(CHAR)
*-- 채번 규칙 - 날짜(YYMM) + 시리얼번호 6자리(000001) e.g. 2501000001
  CLEAR LV_NUM.
  CONCATENATE SY-DATLO+2(4) '%' INTO LV_DAT.
  SELECT MAX( MREQNO )
    FROM ZGTSDT0060
   WHERE MREQNO LIKE @LV_DAT

    INTO @DATA(LV_MREQNO).

  IF LV_MREQNO IS INITIAL.
    ADD 1 TO LV_NUM.
  ELSE.
    LV_NUM = LV_MREQNO+4(6).
    ADD 1 TO LV_NUM.
  ENDIF.

  CONCATENATE SY-DATLO+2(4) LV_NUM INTO LV_MREQNO.

*-- 국가코드 정보 구성
  SELECT SINGLE A~INTCA3
    FROM T005 AS A
   WHERE A~LAND1 EQ @GS_ZSD0106T-LAND1
    INTO @DATA(LV_INTCA3).
* ENAME
  SELECT SINGLE NAME INTO @DATA(LV_NAME)
    FROM ZGTMM_CV_GETUSERNAME
   WHERE USERID = @GS_ZSD0106T-PERNR.

*-- 전송 정보 구성
  APPEND VALUE #(
                  MREQNO    = LV_MREQNO
                  WERKS     = LV_WERKS
                  ZPJNO     = GS_ZSD0106T-ZPJNO
                  STAT      = 'C010'
                  KUNNR     = GS_ZSD0106T-KUNNR
                  NAME1     = LS_USER_INFO-NAME
                  ZPDAT     = GS_ZSD0106T-ZPDAT
                  ZPTXT     = GS_ZSD0106T-ZPTXT
                  PERNR     = GS_ZSD0106T-PERNR
                  MAIL_ADDR = LS_USER_INFO-EMAIL
                  LAND1     = LV_INTCA3
                  ENAME     = LV_NAME
                ) TO LT_HTAB.

  CALL FUNCTION 'ZGTSD_IF_O_BD_MFG_INSTR_REQ'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID           = LV_SYSID
    IMPORTING
      ZO_RESULT             = LV_RESULT
      ZO_MESSAGE            = LV_MSG
    TABLES
      OT_HTAB               = LT_HTAB
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
      ILLEGALNAME           = 3
      OTHERS                = 4.

*-- I/F 전송 결과 저장 수행
  GET TIME STAMP FIELD LV_ZIFKEY.

  APPEND VALUE #(
                  ZIFRFC     = |ZGTSD_IF_O_BD_MFG_INSTR_REQ|
                  ZIFKEY     = LV_ZIFKEY
                  ZSYSTEM_ID = LV_SYSID
                  ZSTAT      = LV_RESULT
                  ZMESSAGE   = LV_MSG

                  ZVALUE01   = LV_MREQNO
                  ZVALUE02   = LV_WERKS
                  ZVALUE03   = GS_ZSD0106T-ZPJNO
                  ZVALUE04   = 'C010'
                  ZVALUE05   = GS_ZSD0106T-KUNNR
                  ZVALUE06   = LS_USER_INFO-NAME
                  ZVALUE07   = GS_ZSD0106T-ZPDAT
                  ZVALUE08   = GS_ZSD0106T-ZPTXT
                  ZVALUE09   = GS_ZSD0106T-PERNR
                  ZVALUE10   = LS_USER_INFO-EMAIL
                  ZVALUE11   = LV_NAME
                  ZVALUE12   = LV_INTCA3

                  IFDAT      = SY-DATUM
                  IFTIM      = SY-UZEIT
                  IFNAM      = SY-UNAME
                  ERNAM      = SY-UNAME
                  ERDAT      = SY-DATUM
                  ERZEIT     = SY-UZEIT
                  ERDATLO    = SY-DATLO
                  ERTIMLO    = SY-TIMLO
                ) TO LT_9000.

*-- 제조지시요청 Header 송수신 Log 구성
  APPEND VALUE #(
                  ZIFKEY     = LV_ZIFKEY
                  ZSYSTEM_ID = LV_SYSID
                  MREQNO     = LV_MREQNO
                  WERKS      = LV_WERKS
                  ZPJNO      = GS_ZSD0106T-ZPJNO
                  ZSTAT      = LV_RESULT
                  ZMESSAGE   = LV_MSG
                  ERDAT      = SY-DATUM
                  ERNAM      = SY-UNAME
                  IFDAT      = SY-DATUM
                  IFTIM      = SY-UZEIT
                  IFNAM      = SY-UNAME
                ) TO LT_0060.

  TRY.
      INSERT : ZGTSDT9000 FROM TABLE LT_9000,
               ZGTSDT0060 FROM TABLE LT_0060.
    CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
      DATA(LV_EMSG) = LO_SQL_DB->GET_TEXT( ).
      ROLLBACK WORK.
  ENDTRY.

  CHECK LV_EMSG IS INITIAL.
  COMMIT WORK.

ENDFORM.
