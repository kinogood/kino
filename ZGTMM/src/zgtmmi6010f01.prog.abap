*&---------------------------------------------------------------------*
*& Include          ZGTMMR4916F01
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

  CLEAR : S_IFDAT[], S_ERDAT[], S_EKORG[], S_WERKS[].
  S_IFDAT[] = S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                                     OPTION = GC_BT
                                     LOW    = SY-DATLO - 1
                                     HIGH   = SY-DATLO ) ).

  S_EKORG[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = GC_1100 ) ).

  S_WERKS[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = GC_1306 ) ).
  P_IFSYT = GC_KBDM.
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

  SELECT DISTINCT FLD_01 AS KEY,
                  FLD_02 AS TEXT
    FROM ZGTPPT1010
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

  CLEAR : GR_GR1[], GR_SNM[].

  CASE 'X'.
    WHEN P_ILOG.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_SND ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_ERDAT-LOW ) ).

  ENDCASE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 IN GR_GR1.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME IN GR_SNM.
      SCREEN-REQUIRED = 2.
      MODIFY SCREEN.
    ENDIF.

    CASE SCREEN-GROUP1.
      WHEN 'M1'.
        SCREEN-INPUT = 0.
      WHEN 'M2'.
        IF P_SEND = GC_X.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
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

  IF ( P_ILOG = GC_X AND   S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL ) ).
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

  PERFORM GET_MST_INFO USING 'MM00061'.

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
      GV_TNAME = GS_MST-VIEW. "ZGTMM_CV_BD_INFO_LOG
    WHEN P_SEND.
      GV_TNAME = GC_ZGTMM_CV_INFO_CHNG_HIST.
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


  LV_COND = |     IFDAT IN @S_IFDAT |
         && | AND EKORG IN @S_EKORG |
         && | AND WERKS IN @S_WERKS |
         && | AND LIFNR IN @S_LIFNR |
         && | AND ESOKZ IN @S_ESOKZ |
         && | AND UDATE IN @S_ERDAT |
         && | AND MATKL IN @S_MATKL |
         && | AND MATNR IN @S_MATNR |
         && | AND INFNR IN @S_INFNR |. "추가(PSJ 25.03.12)

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  CASE GC_X.
    WHEN P_SU.
      LV_COND = LV_COND && | AND ZSTAT = @GC_S |.
    WHEN P_FA.
      LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
  ENDCASE.

  SELECT *
    FROM (GV_TNAME)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>
   WHERE (LV_COND).

  CHECK <GT_LIST> IS NOT INITIAL.
  SORT <GT_LIST> BY ('ZIFKEY') DESCENDING
                    ('EKORG')  ASCENDING
                    ('WERKS')  ASCENDING
                    ('MATKL')  ASCENDING
                    ('MATNR')  ASCENDING
                    ('LIFNR')  ASCENDING.

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

  SELECT A~*, B~MAKTX
    FROM ZGTMM_CV_INFO_CHNG_HIST AS A
    LEFT OUTER JOIN MAKT AS B
      ON A~MATNR = B~MATNR
     AND B~SPRAS = @SY-LANGU
   WHERE A~EKORG  IN @S_EKORG
     AND A~WERKS  IN @S_WERKS
     AND A~LIFNR  IN @S_LIFNR
     AND A~MATKL  IN @S_MATKL
     AND A~MATNR  IN @S_MATNR
     AND A~INFNR  IN @S_INFNR "추가(PSJ 25.03.12)
     AND A~ESOKZ  IN @S_ESOKZ
     AND A~UDATE  IN @S_ERDAT
     AND A~KAPPL   = @GC_M
     AND A~KSCHL   = @GC_PB00
    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>.

  CHECK <GT_LIST> IS NOT INITIAL.
  SORT <GT_LIST> BY ('INFNR') ('ESOKZ') ('DATAB') ('DATBI') ASCENDING ('UDATE') DESCENDING ('UTIME') DESCENDING.
  DELETE ADJACENT DUPLICATES FROM <GT_LIST> COMPARING ('INFNR') ('ESOKZ') ('DATAB') ('DATBI').

  PERFORM EXCEPT_SEND_DATA.
  CHECK <GT_LIST> IS NOT INITIAL.

  SORT <GT_LIST> BY ('EKORG')  ASCENDING
                    ('WERKS')  ASCENDING
                    ('MATKL')  ASCENDING
                    ('MATNR')  ASCENDING
                    ('LIFNR')  ASCENDING.

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

  DATA : BEGIN OF LS_INFO,
           INFNR LIKE ZGTMMT6010-INFNR,
           ESOKZ LIKE ZGTMMT6010-ESOKZ,
           MATKL LIKE ZGTMMT6010-MATKL,
           MATNR LIKE ZGTMMT6010-MATNR,
           DATBI LIKE ZGTMMT6010-DATBI,
           DATAB LIKE ZGTMMT6010-DATAB,
           KBETR LIKE ZGTMMT6010-KBETR,
         END   OF LS_INFO.

  DATA : LT_INFO LIKE SORTED TABLE OF LS_INFO
                 WITH UNIQUE KEY INFNR ESOKZ MATKL MATNR
                                 DATBI DATAB KBETR.

  DATA : LS_LIST LIKE LS_INFO.


  "'Data 전송' 선택시 I/F 성공건은 전송대상에서 제외(PSJ 25.03.25)
  " 중복 체크 조건: INFNR/ESOKZ/MATKL/MATNR/DATBI/DATAB/KBETR

  CHECK <GT_LIST> IS NOT INITIAL.

  LT_INFO[] = CORRESPONDING #( <GT_LIST> DISCARDING DUPLICATES ).

  SELECT INFNR, ESOKZ, MATKL, MATNR,
         DATBI, DATAB, KBETR
    FROM ZGTMM_CV_BD_INFO_LOG
    INTO CORRESPONDING FIELDS OF TABLE @LT_INFO
     FOR ALL ENTRIES IN @LT_INFO
   WHERE ZIFNO     = @GC_MM00061
     AND SYSTEM_ID = @P_IFSYT
     AND ZSTAT     = @GC_S
     AND INFNR     = @LT_INFO-INFNR
     AND ESOKZ     = @LT_INFO-ESOKZ
     AND MATKL     = @LT_INFO-MATKL
     AND MATNR     = @LT_INFO-MATNR
     AND DATBI     = @LT_INFO-DATBI.

  CHECK LT_INFO[] IS NOT INITIAL.

  LOOP AT <GT_LIST> ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    MOVE-CORRESPONDING <LS_LIST> TO LS_LIST.

    READ TABLE LT_INFO INTO LS_INFO
                   WITH KEY INFNR = LS_LIST-INFNR
                            ESOKZ = LS_LIST-ESOKZ
                            MATKL = LS_LIST-MATKL
                            MATNR = LS_LIST-MATNR
                            DATBI = LS_LIST-DATBI
                            DATAB = LS_LIST-DATAB
                            KBETR = LS_LIST-KBETR
                            BINARY SEARCH.

    CHECK SY-SUBRC = 0.
    DELETE <GT_LIST>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_DATA USING PV_CHK.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE ZO_RESULT,
         LV_MSG  TYPE ZO_MESSAGE,
         LV_RET  TYPE ZIFE_IFRET.

  DATA : LT_F062 LIKE ZGTMMSIF0062 OCCURS 0 WITH HEADER LINE.

  CLEAR : GT_F062[], GT_ELOG[].
  CLEAR : GV_CNT,    GV_MSG.

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

  PERFORM MODIFY_F062_DATA.

  LT_F062[] = GT_F062[].

"2025.10.02 BMES 통합 IS전환
  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
*      GUBUN                 = 'MM'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_BDMES_INFO_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID           = P_IFSYT
    IMPORTING
      ZO_RESULT             = LV_RST
      ZO_MESSAGE            = LV_MSG
    TABLES
      OT_TAB                = LT_F062[]
    EXCEPTIONS
      SYSTEM_FAILURE        = 1 MESSAGE LV_MSG
      COMMUNICATION_FAILURE = 2 MESSAGE LV_MSG
      ILLEGALNAME           = 3
      OTHERS                = 4.
  IF SY-SUBRC NE 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
      GV_CNT = LINES( GT_F062[] ).
      GV_MSG = GV_CNT && '건 전송 성공'(M02).
    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

  PERFORM SAVE_LOG USING LV_RET
                         LV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

  CHECK P_ILOG = GC_X.
  PERFORM GET_DATA.

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

  DATA : LV_FLD TYPE CHAR8.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_LIST> INTO <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    GT_ELOG = CORRESPONDING #( <GS_LIST> ).
    IF P_ILOG = GC_X.
      LV_FLD = |WAERS|.
    ELSE.
      LV_FLD = |KONWA|.
    ENDIF.
    ASSIGN COMPONENT LV_FLD OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LV_VAL>).
    CHECK SY-SUBRC = 0.
    GT_ELOG-WAERS = <LV_VAL>.

    APPEND GT_ELOG.
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

*  GT_ELOG[] = CORRESPONDING #( <GT_LIST> ).
  LOOP AT <GT_LIST> INTO <GS_LIST>.

    GT_ELOG = CORRESPONDING #( <GS_LIST> ).
    ASSIGN COMPONENT 'KONWA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LV_VAL>).
    CHECK SY-SUBRC = 0.
    GT_ELOG-WAERS = <LV_VAL>.
    APPEND GT_ELOG.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F062_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F062_DATA.

  DATA : LV_KBETR TYPE BAPICURR-BAPICURR.


  GET TIME STAMP FIELD GV_ZIFKEY.

  LOOP AT GT_ELOG.
    GT_F062 = CORRESPONDING #( GT_ELOG ).

    GT_F062-ZIFKEY = GV_ZIFKEY.

    PERFORM CONVERT_MATN1_OUTPUT USING GT_F062-MATNR.
    GT_F062-LIFNR = |{ GT_F062-LIFNR ALPHA = OUT }|.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        CURRENCY        = GT_F062-WAERS
        AMOUNT_INTERNAL = GT_F062-KBETR
      IMPORTING
        AMOUNT_EXTERNAL = LV_KBETR.
    GT_F062-KBETR = LV_KBETR.
    APPEND GT_F062.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F030_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

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

  CLEAR : GS_9000, GT_6010[].

* GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFKEY      = GV_ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00061.
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

  GT_6010[] = VALUE #( FOR LS_LOG IN GT_ELOG
                       ( VALUE #( BASE CORRESPONDING #( LS_LOG )
                                  ZIFKEY      = GS_9000-ZIFKEY
                                  ERDAT       = SY-DATUM
                                  ERDAT_LOCAL = SY-DATLO
                                  ERTIM       = SY-UZEIT
                                  ERTIM_LOCAL = SY-TIMLO
                                  ERNAM       = SY-UNAME ) ) ).

  CHECK GT_6010[] IS NOT INITIAL.

  MODIFY ZGTMMT6010 FROM TABLE GT_6010.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

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

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
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
  PS_LAYO-GRID_TITLE = COND #( WHEN P_ILOG = 'X' THEN 'Interface 처리상태'(T01)
                               WHEN P_SEND = 'X' THEN '자재/벤더 정보'(T02) ).

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

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

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
