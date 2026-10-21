*&---------------------------------------------------------------------*
*& Include          ZGTMMR4910F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT.

  PERFORM GET_IFNO.

  CLEAR : S_IFDAT[], S_ERDAT[].
  S_IFDAT[] = S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                                     OPTION = GC_BT
                                     LOW    = SY-DATLO - 1
                                     HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IFNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IFNO.

  CLEAR : GT_IFNO[].

  SELECT DISTINCT
         FLD_01 AS KEY,
         FLD_02 AS TEXT
    FROM ZGTPPT1010 "ZGTMM_CV_GET_IFLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFNO
   WHERE MODULE_KIND = @GC_PP
     AND CODEGRP     = @GC_0010.

  SORT GT_IFNO BY KEY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  CLEAR : GR_GR1[].

  CASE 'X'.
    WHEN P_ILOG.
      APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = GC_SND ) TO GR_GR1.
    WHEN P_SEND.
      APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) TO GR_GR1.
  ENDCASE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 IN GR_GR1.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    CLEAR : GV_REQ.
    CASE SCREEN-NAME.
      WHEN 'P_IFSYT'.
        IF P_SEND = GC_X.
          GV_REQ = 2.
        ENDIF.

      WHEN 'S_IFDAT-LOW' OR 'S_ERDAT-LOW'
        OR 'P_EKORG'.
        GV_REQ = 2.

    ENDCASE.

    IF GV_REQ = 2.
      SCREEN-REQUIRED = GV_REQ.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IFSYT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IFSYT USING PV_ID.

  DATA : LT_IFNO TYPE VRM_VALUES.


  LT_IFNO[] = CORRESPONDING #( GT_IFNO[] ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_IFNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GV_ERR.

  IF ( P_ILOG = GC_X AND S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL
                        OR P_EKORG   IS INITIAL ) ).
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GV_CNT.
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_MST_INFO USING 'MM00001'.

  PERFORM MAKE_ITAB.
  CLEAR : <GT_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

  GV_CNT = LINES( <GT_LIST> ).
  IF GV_CNT IS NOT INITIAL.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MST_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_MST_INFO USING PV_ID.

  CLEAR : GS_MST.

  SELECT SINGLE FLD_03,
                FLD_04,
                FLD_05
    FROM ZGTMM_CV_GET_IFLIST
    INTO @GS_MST
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0010
     AND FLD_01      = @PV_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB.

  DATA : LR_DATA  TYPE REF TO DATA.


  CLEAR    : GV_TNAME.
  UNASSIGN : <GT_LIST>, <GS_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_TNAME = GS_MST-VIEW. "ZGTMM_CV_VENDOR_IF_LOG_L
    WHEN P_SEND.
      GV_TNAME = GC_ZGTMM_CV_CHANGEDVD.
  ENDCASE.

  DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                       CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( GV_TNAME ) ).

  CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
  ASSIGN LR_DATA->* TO  <GS_LIST>.
  FREE : LR_DATA.

  CREATE DATA LR_DATA LIKE STANDARD TABLE OF <GS_LIST>.
  ASSIGN LR_DATA->* TO <GT_LIST>.
  FREE : LR_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_DATA.

  DATA : LV_COND TYPE STRING.


  LV_COND = | IFDAT IN @S_IFDAT AND LIFNR IN @S_LIFNR |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_FNL IS NOT INITIAL.
    LV_COND = LV_COND && | AND LASTDATA = @GC_X |.
  ENDIF.

  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
  ENDIF.

  SELECT *
    FROM (GV_TNAME)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>
   WHERE (LV_COND).

  CHECK <GT_LIST> IS NOT INITIAL.
  SORT <GT_LIST> BY ('ZIFKEY') DESCENDING ('LIFNR') ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_DATA.

  CLEAR : GT_VCHG[].

  SELECT *
    FROM ZGTMM_CV_CHANGEDVD( P_STARTDATE = @S_ERDAT-LOW,
                             P_ENDDATE   = @S_ERDAT-HIGH )
   WHERE LIFNR IN @S_LIFNR
     AND EKORG  = @P_EKORG
    INTO CORRESPONDING FIELDS OF TABLE @GT_VCHG.

  CHECK GT_VCHG[] IS NOT INITIAL.

*--> [CHM2510-00260]소재 MOM I/F 반영
**** 재 I/F 위한 CHANGENR 추출 로직 추가
  LOOP AT GT_VCHG.
    SELECT SINGLE CHANGENR
      INTO GT_VCHG-CHANGENR
      FROM CDHDR AS A
     WHERE A~OBJECTCLAS = 'KRED'
       AND A~OBJECTID = GT_VCHG-LIFNR
       AND A~UDATE IN S_ERDAT
       AND A~CHANGENR = (
                         SELECT MAX( AA~CHANGENR )
                           FROM CDHDR AS AA
                          WHERE A~OBJECTCLAS = AA~OBJECTCLAS
                            AND A~OBJECTID = AA~OBJECTID
                            AND AA~UDATE IN S_ERDAT
                        ).
    MODIFY GT_VCHG TRANSPORTING CHANGENR.
  ENDLOOP.
*<-- [CHM2510-00260]소재 MOM I/F 반영

  PERFORM EXCEPT_SEND_DATA.

  CHECK GT_VCHG[] IS NOT INITIAL.
  PERFORM GET_ADRC.

  SORT GT_VCHG BY LIFNR UDATE.
  <GT_LIST> = CORRESPONDING #( GT_VCHG[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA.

  DATA : LT_VCHG TYPE ZGTMM_CV_CHANGEDVD OCCURS 0 WITH HEADER LINE.


  CLEAR : GR_LIFNR[].

  CHECK P_FRC     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
  CHECK GT_VCHG[] IS NOT INITIAL.

  LT_VCHG[] = GT_VCHG[].
  SORT LT_VCHG BY LIFNR CHANGENR.
  DELETE ADJACENT DUPLICATES FROM LT_VCHG COMPARING LIFNR CHANGENR.

  SELECT DISTINCT LIFNR AS LOW
    FROM ZGTMM_CV_VENDOR_IF_LOG
    INTO CORRESPONDING FIELDS OF TABLE @GR_LIFNR
     FOR ALL ENTRIES IN @LT_VCHG
   WHERE LIFNR    = @LT_VCHG-LIFNR
     AND CHANGENR = @LT_VCHG-CHANGENR
     AND ZSTAT    = @GC_S
     AND SYSTEM_ID = @P_IFSYT. "--> [CHM2510-00260]소재 MOM I/F 구분자 추가

  CHECK GR_LIFNR[] IS NOT INITIAL.
  GR_LIFNR-SIGN   = GC_I.
  GR_LIFNR-OPTION = GC_EQ.
  MODIFY GR_LIFNR TRANSPORTING SIGN OPTION
                         WHERE SIGN IS INITIAL.

  DELETE GT_VCHG WHERE LIFNR IN GR_LIFNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ADRC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ADRC.

  DATA : LT_ADR6 LIKE SORTED TABLE OF GS_ADR6
                 WITH UNIQUE KEY ADRNR.


  CLEAR : GT_ADR6[].

  LT_ADR6[] = CORRESPONDING #( GT_VCHG[] DISCARDING DUPLICATES ).
  DELETE LT_ADR6 WHERE ADRNR IS INITIAL.

  CHECK LT_ADR6[] IS NOT INITIAL.

  SELECT ADDRNUMBER AS ADRNR
         SMTP_ADDR
    FROM ADR6
    INTO CORRESPONDING FIELDS OF TABLE GT_ADR6
     FOR ALL ENTRIES IN LT_ADR6
   WHERE ADDRNUMBER = LT_ADR6-ADRNR.

  "Address Number에 매핑된 사번이 여러건일 경우, 아무건이나 하나로 지정(송종면E 25.02.10)
  CHECK GT_ADR6[] IS NOT INITIAL.

  SORT GT_ADR6 BY ADRNR.
  DELETE ADJACENT DUPLICATES FROM GT_ADR6 COMPARING ADRNR.

  LOOP AT GT_VCHG.
    PERFORM SET_SMTP_ADDR USING GT_VCHG-ADRNR
                       CHANGING GT_VCHG-SMTP_ADDR.

    MODIFY GT_VCHG TRANSPORTING SMTP_ADDR.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_DATA USING PV_CHK.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE ZO_RESULT,
         LV_MSG  TYPE ZO_MESSAGE,
         LV_RET  TYPE ZIFE_IFRET.

  DATA : LT_F001 LIKE ZGTMMSIF0001 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_F001[], GV_CNT, GV_MSG.

  IF PV_CHK = GC_X.
    PERFORM SEND_SEL_DATA.

    CHECK GV_ERR IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   'Data를 전송 하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ELSE.
    PERFORM SEND_BAT_DATA.
  ENDIF.

  IF P_IFSYT IS INITIAL.
    MESSAGE S015 WITH 'I/F 시스템'(M01) DISPLAY LIKE 'E'. "&를(을) 입력하세요.
    EXIT.
  ENDIF.

  SORT GT_F001 BY LIFNR.
  LT_F001[] = GT_F001[].

*2025.08.13 통합솔루션 전환 IS 변경
  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
*     GUBUN                 = 'MM'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_IF_O_VENDOR'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_TAB      = LT_F001[] "GT_F001[]
    EXCEPTIONS
*     CALL_FUNCTION_OPEN_ERROR = 1
      OTHERS      = 2.

  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
      GV_CNT = LINES( GT_F001[] ).
      GV_MSG = GV_CNT && '건 전송 성공'(M02).
    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

  PERFORM SAVE_LOG USING LV_RET
                         LV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        MESSAGE S050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
      ENDIF.
    WHEN 1.
      IF PV_MODE = GC_S.
        READ TABLE GT_ROW INTO GS_ROW INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM USING PV_TITLE
                            PV_QTEXT.

  CLEAR : GV_ANS. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      TITLEBAR      = PV_TITLE
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION = PV_QTEXT
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER        = GV_ANS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SEL_DATA.

  DATA : LS_LIST LIKE GT_VCHG.


  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_LIST> INTO <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE 'X'.
      WHEN P_ILOG.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LAST>).

        IF <LFS_LAST> IS INITIAL.
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

        GT_F001 = CORRESPONDING #( <GS_LIST> ).
        GT_F001-LIFNR = |{ GT_F001-LIFNR ALPHA = OUT }|.
        APPEND GT_F001.

      WHEN OTHERS.
        LS_LIST = CORRESPONDING #( <GS_LIST> ).

        GT_F001[] = VALUE #( BASE GT_F001[]
                             ( VALUE #( BASE CORRESPONDING #( LS_LIST )
                                        LIFNR     = |{ LS_LIST-LIFNR ALPHA = OUT }|
                                        SMTP_ADDR = VALUE #( GT_ADR6[ ADRNR = LS_LIST-ADRNR ]-SMTP_ADDR OPTIONAL ) ) ) ).

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_BAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_BAT_DATA.

  DATA : LT_LIST LIKE GT_VCHG OCCURS 0 WITH HEADER LINE.


  LT_LIST[] = CORRESPONDING #( <GT_LIST> ).

  GT_F001[] = VALUE #( FOR LS_LIST IN LT_LIST
                       ( VALUE #( BASE CORRESPONDING #( LS_LIST )
                                  LIFNR     = |{ LS_LIST-LIFNR ALPHA = OUT }|
                                  SMTP_ADDR = VALUE #( GT_ADR6[ ADRNR = LS_LIST-ADRNR ]-SMTP_ADDR OPTIONAL ) ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CLEAR : GS_9000, GT_9010[].

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00001.
  GS_9000-SYSTEM_ID   = P_IFSYT.
  GS_9000-ZSTAT       = PV_RET.
  GS_9000-MESSAGE     = PV_MSG.
  GS_9000-IFDAT       = SY-DATLO.
  GS_9000-IFTIM       = SY-TIMLO.
  GS_9000-IFNAM       = SY-UNAME.
  GS_9000-ERDAT       = SY-DATUM.
  GS_9000-ERDAT_LOCAL = SY-DATLO.
  GS_9000-ERTIM       = SY-UZEIT.
  GS_9000-ERTIM_LOCAL = SY-TIMLO.
  GS_9000-ERNAM       = SY-UNAME.

  LOOP AT <GT_LIST> ASSIGNING <GS_LIST>.
    CLEAR : GT_9010.
    MOVE-CORRESPONDING <GS_LIST> TO GT_9010.

    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LIFNR>).
    <LFS_LIFNR> = |{ <LFS_LIFNR> ALPHA = OUT }|.

    CHECK LINE_EXISTS( GT_F001[ LIFNR = <LFS_LIFNR> ] ).

    GT_9010-ZIFKEY = GS_9000-ZIFKEY.

    IF P_SEND = GC_X.
      ASSIGN COMPONENT 'ADRNR' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_ADRNR>).

      PERFORM SET_SMTP_ADDR USING <LFS_ADRNR>
                         CHANGING GT_9010-SMTP_ADDR.
    ENDIF.

    APPEND GT_9010.
  ENDLOOP.

  CHECK GT_9010[] IS NOT INITIAL.

  MODIFY ZGTMMT9000 FROM GS_9000.
  MODIFY ZGTMMT9010 FROM TABLE GT_9010.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SMTP_ADDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LFS_ADRNR>
*&      <-- GT_9010_SMTP_ADDR
*&---------------------------------------------------------------------*
FORM SET_SMTP_ADDR USING PV_ADRNR
                CHANGING PV_SADDR.

  CLEAR : PV_SADDR.
  CHECK PV_ADRNR IS NOT INITIAL.

  READ TABLE GT_ADR6 INTO DATA(LS_ADR6)
    WITH KEY ADRNR = PV_ADRNR BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  PV_SADDR = LS_ADR6-SMTP_ADDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  GV_SEND = COND #( WHEN P_ILOG = 'X' THEN '재전송'(B01)
                    WHEN P_SEND = 'X' THEN '전송'(B02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_DOCK
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_OBJ USING PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER
                   PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  PR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  PR_GRID = NEW #( I_PARENT      = PR_DOCK
                   I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

  "다운로드 기능(MC_MB_EXPORT) 삭제(송종면E 25.02.10)

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.
  PS_LAYO-GRID_TITLE = 'Interface 처리상태'(T01).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( GV_TNAME )
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  DELETE LT_FCAT WHERE FIELDNAME = '.NODE1'.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = <GT_LIST>
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO.

* CLEAR : GS_VARI.
* GS_VARI-REPORT   = SY-REPID.
* GS_VARI-HANDLE   = SY-DYNNR.
* GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
*     IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = <GT_LIST>
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PS_LAYO TYPE LVC_S_LAYO.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = PS_LAYO.

  CALL METHOD PR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GR_GRID->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_GRID, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
