*&---------------------------------------------------------------------*
*& Include          ZGTMMR4230F01
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

  "화면 이동 버튼 추가(송종면E 25.02.17)
  PERFORM SET_FUNC_KEY USING '산출대상자재'(B01)
                    CHANGING SSCRFIELDS-FUNCTXT_01.
  PERFORM SET_FUNC_KEY USING '산출대상 저장위치'(B02)
                    CHANGING SSCRFIELDS-FUNCTXT_02.
  PERFORM SET_FUNC_KEY USING '출고이동유형'(B03)
                    CHANGING SSCRFIELDS-FUNCTXT_03.
  PERFORM SET_FUNC_KEY USING '서비스계수'(B04)
                    CHANGING SSCRFIELDS-FUNCTXT_04.

  _CALC_DATE SY-DATLO '00' '06' '-' '00'.

  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = GV_CDATE
                         HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FUNC_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- SSCRFIELDS_FUNCTXT_01
*&---------------------------------------------------------------------*
FORM SET_FUNC_KEY USING PV_TEXT
               CHANGING PV_FUNCTXT.

  CLEAR : GS_FKEY.

* GS_FKEY-TEXT
  GS_FKEY-ICON_ID   = ICON_TRANSFER.
  GS_FKEY-ICON_TEXT = PV_TEXT.
  GS_FKEY-QUICKINFO = PV_TEXT.

  PV_FUNCTXT = GS_FKEY.

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

  "입력값 유효성 Check
  PERFORM CHECK_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_WERKS.

  CLEAR : GT_WERKS[].
  CHECK S_WERKS[] IS NOT INITIAL.

  SELECT WERKS FROM T001W
    INTO CORRESPONDING FIELDS OF TABLE GT_WERKS
   WHERE WERKS IN S_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'S_WERKS-LOW'.
  MESSAGE E016 WITH '플랜트'(F03). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  "권한 체크 추가(송종면E 25.02.17)

  LOOP AT GT_WERKS.
    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
                 ID 'WERKS' FIELD GT_WERKS-WERKS.

    CHECK SY-SUBRC <> 0.

    SET CURSOR FIELD 'S_WERKS-LOW'.
    MESSAGE E106 WITH GT_WERKS-WERKS. "플랜트 [&] 작업권한을 확인하세요.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAI_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PAI_1000.

  "Pgm.화면 이동 기능 추가(송종면E 25.02.17)

  CHECK SY-DYNNR = GC_1000.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'. "산출대상자재
      SUBMIT ZGTMMR4220 WITH P_WERKS = S_WERKS-LOW
                        VIA SELECTION-SCREEN
                        AND RETURN.

    WHEN 'FC02'. "산출대상 저장위치
      SUBMIT ZGTMMR4222 WITH P_WERKS = S_WERKS-LOW
                        VIA SELECTION-SCREEN
                        AND RETURN.

    WHEN 'FC03'. "출고이동유형
      SUBMIT ZGTMMR4223 WITH P_WERKS = S_WERKS-LOW
                        VIA SELECTION-SCREEN
                        AND RETURN.

    WHEN 'FC04'. "서비스계수
      SUBMIT ZGTMMR4221 WITH P_WERKS = S_WERKS-LOW
                        VIA SELECTION-SCREEN
                        AND RETURN.

  ENDCASE.

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

  CASE 'X'.
    WHEN P_WEEK.
      PERFORM GET_XSTK_DATA TABLES GT_WSTK
                             USING 'ZGTMM_CV_AGG_STOCK_WEEKLY2'.

    WHEN P_DAY.
      PERFORM GET_XSTK_DATA TABLES GT_DSTK
                             USING 'ZGTMM_CV_AGG_STOCK_DAILY2'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_XSTK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_WSTK
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_XSTK_DATA TABLES PT_XSTK
                    USING PV_VNME.

  DATA : LV_VNME(100).


  CLEAR : PT_XSTK[], GV_CNT.

  LV_VNME = PV_VNME && '( P_STARTDATE = @S_BUDAT-LOW, P_ENDDATE = @S_BUDAT-HIGH )'.

  SELECT *
    FROM (LV_VNME)
   WHERE WERKS IN @S_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @PT_XSTK.

  IF PT_XSTK[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  LOOP AT PT_XSTK.
    MOVE-CORRESPONDING PT_XSTK TO GS_COM.

    GS_COM-TOTALQTY	= GS_COM-UNQTY + GS_COM-BONDEDQTY.

    GS_COM-F1_SQRT = SQRT( GS_COM-F1 ).
    GS_COM-F2_SQRT = SQRT( GS_COM-F2 ).

    GS_COM-SAFTY_QTY = GS_COM-SERVICEFACTOR * GS_COM-F1_SQRT * GS_COM-F2_SQRT.
    GS_COM-SU_QTY    = GS_COM-SAFTY_QTY + ( GS_COM-LT * GS_COM-REQ_DAILY ).
    GS_COM-DIFF      = GS_COM-TOTALQTY - GS_COM-SU_QTY.

    MOVE-CORRESPONDING GS_COM TO PT_XSTK.
    MODIFY PT_XSTK.
  ENDLOOP.

  SORT PT_XSTK BY ('BUKRS') ('WERKS') ('MATNR').

  GV_CNT = LINES( PT_XSTK ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

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

  CLEAR : GV_TITLE.

  GV_TITLE = COND #( WHEN P_WEEK = GC_X THEN TEXT-R01
                     WHEN P_DAY  = GC_X THEN TEXT-R02 ).

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
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT.

  "Sort 기능 추가(SJM 25.04.09)
  " WERKS/MATNR/TYPE 기준 오름차순

  CLEAR : GT_SORT.

  PERFORM SET_SFNM USING 1 'WERKS'   'X' ' ' ' '.
  PERFORM SET_SFNM USING 2 'WERKS_N' 'X' ' ' ' '.
  PERFORM SET_SFNM USING 3 'MATNR'   'X' ' ' ' '.
  PERFORM SET_SFNM USING 4 'MATNR_N' 'X' ' ' ' '.
  PERFORM SET_SFNM USING 5 'TYPE'    'X' ' ' ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SFNM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SFNM USING PV_SPOS
                    PV_FNME
                    PV_UP
                    PV_DOWN
                    PV_STOT.

  APPEND VALUE #( SPOS      = PV_SPOS
                  FIELDNAME = PV_FNME
                  UP        = PV_UP
                  DOWN      = PV_DOWN
                  SUBTOT    = PV_STOT ) TO GT_SORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_WSTK
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_LIST
                    USING PV_TNME.

  PERFORM SET_FCAT TABLES PT_LIST
                    USING PV_TNME.

  PERFORM SET_DISP TABLES PT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_LIST
*&      --> PV_TNME
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_LIST
               USING PV_TNME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], GT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNME
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
      IT_DATA         = PT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    PERFORM SET_XCOM_FCAT.
*   PERFORM SET_XSTK_FCAT.

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
*& Form SET_XCOM_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_XCOM_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F01).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'BUKRS_N'.
      PERFORM SET_FTXT USING '회사명'(F02).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F03).
      GS_FCAT-KEY    = GC_X.
    WHEN 'WERKS_N'.
      PERFORM SET_FTXT USING '플랜트명'(F04).
      GS_FCAT-KEY    = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재'(F05).
      GS_FCAT-KEY    = GC_X.
    WHEN 'MATNR_N'.
      PERFORM SET_FTXT USING '자재명'(F06).
      GS_FCAT-KEY    = GC_X.
    WHEN 'TYPE'.
      PERFORM SET_FTXT USING '라인구분'(F07).
    WHEN 'TYPENAME'.
      PERFORM SET_FTXT USING '구분명'(F08).
    WHEN 'LT'.
      PERFORM SET_FTXT USING 'LeadTime'(F09).
    WHEN 'SERVICEFACTOR'.
      PERFORM SET_FTXT USING 'Factor'(F10).
    WHEN 'REQQTY'. "'REQTY'.
      PERFORM SET_FTXT USING '총소요량'(F11).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F12).
    WHEN 'REQ_DAILY'.
      PERFORM SET_FTXT USING '일소요량'(F13).
    WHEN 'UNQTY'.
      PERFORM SET_FTXT USING '창고재고'(F14).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'BONDEDQTY'.
      PERFORM SET_FTXT USING '보세재고'(F15).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'TOTALQTY'.
      PERFORM SET_FTXT USING '재고합계'(F16).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'STOCKVAL'.
      PERFORM SET_FTXT USING '현재고액'(F17).
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F18).
    WHEN 'F1'.
      PERFORM SET_FTXT USING 'LT/7'(F19).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F2'.
      PERFORM SET_FTXT USING '최종평균'(F20).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F1_SQRT'.
      PERFORM SET_FTXT USING 'SQRT(LT/7)'(F21).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F2_SQRT'.
      PERFORM SET_FTXT USING '표준편차'(F22).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'SAFTY_QTY'.
      PERFORM SET_FTXT USING '안전재고'(F23).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'SU_QTY'.
      PERFORM SET_FTXT USING '적정재고'(F24).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'DIFF'.
      PERFORM SET_FTXT USING '현재고-적정재고'(F25).
      GS_FCAT-EMPHASIZE = GC_C710.
    WHEN 'PLANWEEK'.
      PERFORM SET_FTXT USING '계획주차'(F26).
    WHEN OTHERS.
      PERFORM SET_XSTK_FCAT.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XSTK_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_XSTK_FCAT.

  DATA : LV_CHR(1),
         LV_NUM(3),
         LV_TXT(6).


  LV_CHR = COND #( WHEN P_WEEK = GC_X THEN GC_W
                   WHEN P_DAY  = GC_X THEN GC_D ).

  SPLIT GS_FCAT-FIELDNAME AT LV_CHR INTO LV_CHR LV_NUM.
  CHECK SY-SUBRC = 0.

  LV_TXT = COND #( WHEN P_WEEK = GC_X THEN LV_NUM && '주차'(F27)
                   WHEN P_DAY  = GC_X THEN 'Day'(F28) && LV_NUM ).

  PERFORM SET_FTXT USING LV_TXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_LIST
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_LIST.

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
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[]. "추가(SJM 25.04.09)
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
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA.

  CASE 'X'.
    WHEN P_WEEK.
      PERFORM SAVE_XSTK_DATA TABLES GT_WSTK
                                    GT_4220
                                    GT_4221
                              USING 'ZGTMMT4220'
                                    'ZGTMMT4221'
                                    'Weekly'(R01).

    WHEN P_DAY.
      PERFORM SAVE_XSTK_DATA TABLES GT_DSTK
                                    GT_4222
                                    GT_4223
                              USING 'ZGTMMT4222'
                                    'ZGTMMT4223'
                                    'Daily'(R02).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_XSTK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_WSTK
*&      --> GT_4220
*&      --> GT_4221
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_XSTK_DATA TABLES PT_XSTK
                           PT_422I  "적정재고 산출 결과 자재 정보 Table
                           PT_422S  "적정재고 산출 결과 15주 현황 Table
                     USING PV_INFO  "적정재고 산출 결과 자재 정보 Table
                           PV_SITU  "적정재고 산출 결과 15주 현황 Table
                           PV_MTXT.

  DATA : LV_TIMESTAMP TYPE ZGTETIMESTAMP.


  CLEAR : PT_422I[], PT_422S[].

  GET TIME STAMP FIELD LV_TIMESTAMP.
  PERFORM SET_TIMESTAMP USING 'X' 'X'.

  LOOP AT PT_XSTK.
    CLEAR : PT_422I, PT_422S.

    MOVE-CORRESPONDING PT_XSTK TO PT_422I.
    MOVE-CORRESPONDING PT_XSTK TO PT_422S.

    ASSIGN COMPONENT 'TIMESTAMP' OF STRUCTURE PT_422I
                                 TO FIELD-SYMBOL(<LFS_IKEY>).
    ASSIGN COMPONENT 'TIMESTAMP' OF STRUCTURE PT_422S
                                 TO FIELD-SYMBOL(<LFS_SKEY>).

    <LFS_IKEY> = <LFS_SKEY> = LV_TIMESTAMP.
    MOVE-CORRESPONDING GS_CREA TO PT_422I.
    MOVE-CORRESPONDING GS_CHNG TO PT_422I.

    APPEND : PT_422I, PT_422S.
  ENDLOOP.

  "중복 제거 후 저장(적정재고 산출 결과 자재 정보 Table)
  SORT PT_422I BY ('TIMESTAMP') ('BUKRS') ('WERKS') ('MATNR').
  DELETE ADJACENT DUPLICATES FROM PT_422I
        COMPARING ('TIMESTAMP') ('BUKRS') ('WERKS') ('MATNR').


  MODIFY (PV_SITU) FROM TABLE PT_422S.
  MODIFY (PV_INFO) FROM TABLE PT_422I.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    MESSAGE S100 WITH PV_MTXT. "& 기준 적정 재고 수량을 저장했습니다.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S010 DISPLAY LIKE 'E'. "저장에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TIMESTAMP USING PV_CREA
                         PV_CHNG.

  CLEAR : GS_CREA, GS_CHNG.

  IF PV_CREA = GC_X.
    PERFORM SET_TSTMP USING GS_CREA.
  ENDIF.

  IF PV_CHNG = GC_X.
    PERFORM SET_TSTMP USING GS_CHNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  CLEAR : PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
