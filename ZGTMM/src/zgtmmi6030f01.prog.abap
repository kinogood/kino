*&---------------------------------------------------------------------*
*& Include          ZGTMMI6030F01
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

  P_IFSYT = GC_KBDM.

  CLEAR : S_IFDAT[].
  S_IFDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

  P_WERKS = GC_1306.

  CLEAR : S_SCPUDT[].
  S_SCPUDT[] = VALUE #( ( SIGN   = GC_I
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

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_WERKS )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_SCPUDT-LOW ) ).

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

    IF SCREEN-NAME = GC_P_IFSYT.
      SCREEN-INPUT = 0.
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

  IF P_IFSYT IS INITIAL "당장 의미는 없다만...
  OR ( P_ILOG = GC_X AND   S_IFDAT[]  IS INITIAL )
  OR ( P_SEND = GC_X AND ( P_WERKS    IS INITIAL
                        OR S_SCPUDT[] IS INITIAL ) ).
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

  CLEAR : GT_LIST[], GT_6060[].

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CNT_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CNT_MSG.

  IF GV_CNT IS NOT INITIAL.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

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

  RANGES : LR_STAT FOR ZGTMMT9000-ZSTAT.


  IF P_ALL IS INITIAL.
    DATA(LV_STAT) = COND #( WHEN P_SUC = 'X' THEN GC_S
                            WHEN P_ERR = 'X' THEN GC_E ).

    LR_STAT[] = VALUE #( ( SIGN   = GC_I
                           OPTION = GC_EQ
                           LOW    = LV_STAT ) ).
  ENDIF.

  SELECT *
    FROM ZGTMM_CV_BD_RPOGR_LOG
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE ZIFKEY   IN @S_IFKEY
     AND SYSTEM_ID = @P_IFSYT
     AND ZSTAT    IN @LR_STAT
     AND IFDAT    IN @S_IFDAT
     AND EBELN    IN @S_EBELN
     AND BUDAT    IN @S_BUDAT
     AND JOB_NO   IN @S_JOBNO
     AND MATNR    IN @S_MATNR
     AND CPUDT    IN @S_DCPUDT.

  GV_CNT = LINES( GT_LIST[] ).
  PERFORM SET_CNT_MSG.

  SORT GT_LIST BY ZIFNO ZIFKEY SYSTEM_ID.

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

  SELECT *
    FROM ZGTMM_CV_BD_PO_MATDOC
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE WERKS   = @P_WERKS
     AND MTART  IN @S_MTART
     AND EKGRP  IN @S_EKGRP
     AND JOB_NO IN @S_JOBNO
     AND MATNR  IN @S_MATNR
     AND MBLNR  IN @S_MBLNR
     AND CPUDT  IN @S_SCPUDT.

  PERFORM EXCEPT_SEND_DATA.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S075 DISPLAY LIKE 'E'. "전송할 데이터가 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY MBLNR MJAHR ZEILE.

  GT_6060[] = CORRESPONDING #( GT_LIST[] ).

  GV_CNT = LINES( GT_6060[] ).

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

  DATA : BEGIN OF LS_MDOC,
           MBLNR LIKE ZGTMMT6060-MBLNR,
           MJAHR LIKE ZGTMMT6060-MJAHR,
           ZEILE LIKE ZGTMMT6060-ZEILE,
         END   OF LS_MDOC.

  DATA : LT_MDOC LIKE SORTED TABLE OF LS_MDOC
                 WITH UNIQUE KEY MBLNR MJAHR ZEILE.


  "'Data 전송' 선택시 I/F 성공건은 전송대상에서 제외(PSJ 25.03.25)

  CHECK GT_LIST[] IS NOT INITIAL.

  LT_MDOC[] = CORRESPONDING #( GT_LIST[] DISCARDING DUPLICATES ).

  SELECT MBLNR, MJAHR, ZEILE
    FROM ZGTMM_CV_BD_RPOGR_LOG
    INTO CORRESPONDING FIELDS OF TABLE @LT_MDOC
     FOR ALL ENTRIES IN @LT_MDOC
   WHERE ZIFNO     = @GC_MM00067
     AND SYSTEM_ID = @P_IFSYT
     AND ZSTAT     = @GC_S
     AND MBLNR     = @LT_MDOC-MBLNR
     AND MJAHR     = @LT_MDOC-MJAHR
     AND ZEILE     = @LT_MDOC-ZEILE.

  CHECK LT_MDOC[] IS NOT INITIAL.

  LOOP AT GT_LIST.
    READ TABLE LT_MDOC INTO LS_MDOC
                   WITH KEY MBLNR = GT_LIST-MBLNR
                            MJAHR = GT_LIST-MJAHR
                            ZEILE = GT_LIST-ZEILE
                            BINARY SEARCH.

    CHECK SY-SUBRC = 0.
    DELETE GT_LIST.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_GRID = NEW #( I_PARENT      = GR_DOCK
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
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYO.

  CLEAR : GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_D.
  GS_LAYO-CWIDTH_OPT = GC_X.
  GS_LAYO-ZEBRA      = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], GT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_LIST'
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = GT_FCAT[]
    TABLES
      IT_DATA         = GT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    PERFORM SET_LIST_FCAT.

    MODIFY GT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FTXT USING PV_TEXT.

  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'ZIFNO'.
      PERFORM SET_FTXT USING 'I/F No'(F01).
      GS_FCAT-KEY = GC_X.
    WHEN 'ZIFKEY'.
      PERFORM SET_FTXT USING 'Interface Key'(F02).
      GS_FCAT-KEY = GC_X.
    WHEN 'SYSTEM_ID'.
      PERFORM SET_FTXT USING 'I/F 시스템'(F03).
      GS_FCAT-KEY = GC_X.
    WHEN 'ZSTAT'.
      PERFORM SET_FTXT USING '상태'(F04).
      GS_FCAT-KEY = GC_X.
    WHEN 'MESSAGE'.
      PERFORM SET_FTXT USING '메시지'(F05).
      GS_FCAT-KEY = GC_X.
    WHEN 'IFDAT'.
      PERFORM SET_FTXT USING 'I/F 일자'(F06).
      GS_FCAT-KEY = GC_X.
    WHEN 'IFTIM'.
      PERFORM SET_FTXT USING 'I/F 시간'(F07).
*     GS_FCAT-KEY = GC_X.
    WHEN 'IFNAM'.
      PERFORM SET_FTXT USING '송수신자'(F08).
*     GS_FCAT-KEY = GC_X.
    WHEN 'MBLNR'.
      PERFORM SET_FTXT USING '자재문서번호'(F09).
*     GS_FCAT-KEY = GC_X.
    WHEN 'MJAHR'.
      PERFORM SET_FTXT USING '자재연도'(F10).
    WHEN 'ZEILE'.
      PERFORM SET_FTXT USING '항목'(F11).
    WHEN 'CPUDT'.
      PERFORM SET_FTXT USING '입력일'(F12).
    WHEN 'BUDAT'.
      PERFORM SET_FTXT USING '전기일'(F13).
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더'(F14).
    WHEN 'EBELP'.
      PERFORM SET_FTXT USING '품목'(F15).
    WHEN 'KNTTP'.
      PERFORM SET_FTXT USING 'A'(F16).
    WHEN 'JOB_NO'.
      PERFORM SET_FTXT USING '제조지시번호'(F17).
    WHEN 'LINE_NO'.
      PERFORM SET_FTXT USING '라인번호'(F18).
    WHEN 'SERIAL_NO'.
      PERFORM SET_FTXT USING '시리얼'(F19).
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F20).
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING '구매그룹'(F21).
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F22).
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '공급업체명'(F23).
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재'(F24).
    WHEN 'MTART'.
      PERFORM SET_FTXT USING '자재유형'(F25).
    WHEN 'TXZ01'.
      PERFORM SET_FTXT USING '자재내역'(F26).
    WHEN 'MATKL'.
      PERFORM SET_FTXT USING '자재그룹'(F27).
    WHEN 'BWART'.
      PERFORM SET_FTXT USING 'MvT'(F28).
    WHEN 'SHKZG'.
      PERFORM SET_FTXT USING 'D/C'(F29).
    WHEN 'BSTME'.
      PERFORM SET_FTXT USING 'OUn'(F30).
    WHEN 'BSTMG'.
      PERFORM SET_FTXT USING 'Qty OUn'(F31).
    WHEN 'LGORT_SID'.
      PERFORM SET_FTXT USING 'SLoc'(F32).
    WHEN 'LIFNR_SID'.
      PERFORM SET_FTXT USING '직납처'(F33).
    WHEN 'NAME1_SID'.
      PERFORM SET_FTXT USING '직납처명'(F34).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP.

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD GR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = GS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_GRID.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD GR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

  CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
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
*&---------------------------------------------------------------------*
*& Form REFR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFR_DATA.

  PERFORM GET_DATA.
  GV_REF = GC_X.

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


  CLEAR : GT_F074[].
  CLEAR : GV_CNT, GV_MSG.

  IF PV_CHK = GC_X.
    PERFORM SEND_SEL_DATA.
    CHECK GV_ERR IS INITIAL.
  ENDIF.

  IF ( PV_CHK = GC_X AND GV_ERR IS INITIAL )
  OR ( PV_CHK = ' '  AND SY-BATCH <> GC_X ).
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '데이터를 전송 하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ENDIF.

  GV_CNT = LINES( GT_6060[] ).

  PERFORM MODIFY_F074_DATA.

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

  CALL FUNCTION 'ZGTMM_BDMES_RPOGR_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_ITAB     = GT_F074[]
    EXCEPTIONS
      OTHERS      = 1.

  "모든 경우 Log 남기기(박상진E 24.12.23)
  IF SY-SUBRC <> 0.
    LV_RET = GC_E.
    MESSAGE E076 INTO GV_MSG. "전송을 위한 EAI 함수를 호출할 수 없습니다.
  ELSE.
    CASE LV_RST.
      WHEN '00'.
        LV_RET = GC_S.
        GV_MSG = GV_CNT && '건 전송 성공'(M02).
      WHEN OTHERS.
        LV_RET = GC_E.
        GV_MSG = GV_CNT && '건 전송 실패'(M03).
    ENDCASE.
  ENDIF.

  PERFORM SAVE_LOG USING LV_RET
                         GV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

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

  CLEAR : GT_6060[].

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '재전송할 대상을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    GT_6060 = CORRESPONDING #( GT_LIST ).
    APPEND GT_6060.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        IF PV_MSG IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ELSE.
          MESSAGE S050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
        ENDIF.
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
*& Form MODIFY_F074_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F074_DATA.

  GET TIME STAMP FIELD GV_ZIFKEY.

  LOOP AT GT_6060.
    GT_F074 = CORRESPONDING #( GT_6060 ).

    GT_F074-ZIFKEY    = GV_ZIFKEY.
    GT_F074-MBLNR     = |{ GT_F074-MBLNR     ALPHA = OUT }|.
    GT_F074-EBELN     = |{ GT_F074-EBELN     ALPHA = OUT }|.
    GT_F074-LIFNR     = |{ GT_F074-LIFNR     ALPHA = OUT }|.
    GT_F074-LIFNR_SID = |{ GT_F074-LIFNR_SID ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F074-MATNR.

    SHIFT GT_F074-ZEILE LEFT DELETING LEADING '0'.
    SHIFT GT_F074-EBELP LEFT DELETING LEADING '0'.

    APPEND GT_F074.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F074_MATNR
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
*&      --> GV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CHECK GT_6060[] IS NOT INITIAL.

  CLEAR : GS_9000, GT_6060.

  PERFORM SET_TSTMP.

  "ZGTMMT9000
* GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFKEY    = GV_ZIFKEY.
  GS_9000-ZIFNO     = GC_MM00067.
  GS_9000-SYSTEM_ID = P_IFSYT.
  GS_9000-ZSTAT     = PV_RET.
  GS_9000-MESSAGE   = PV_MSG.
  GS_9000-IFDAT     = SY-DATLO.
  GS_9000-IFTIM     = SY-TIMLO.
  GS_9000-IFNAM     = SY-UNAME.
  MOVE-CORRESPONDING GS_CREA TO GS_9000.

  "ZGTMMT6060
  GT_6060-ZIFKEY = GS_9000-ZIFKEY.
  MOVE-CORRESPONDING GS_CREA TO GT_6060.

  MODIFY GT_6060 TRANSPORTING ZIFKEY
                              ERDAT
                              ERDAT_LOCAL
                              ERTIM
                              ERTIM_LOCAL
                              ERNAM
                        WHERE MANDT IS INITIAL.

  MODIFY ZGTMMT6060 FROM TABLE GT_6060.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TSTMP.

  CLEAR : GS_CREA.

  GS_CREA-ERDAT       = SY-DATUM.
  GS_CREA-ERDAT_LOCAL = SY-DATLO.
  GS_CREA-ERTIM       = SY-UZEIT.
  GS_CREA-ERTIM_LOCAL = SY-TIMLO.
  GS_CREA-ERNAM       = SY-UNAME.

ENDFORM.
