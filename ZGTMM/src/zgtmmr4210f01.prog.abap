*&---------------------------------------------------------------------*
*& Include          ZGTMMR4210F01
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

  _CALC_DATE SY-DATLO '00' '06' '-' '00'.

  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = GV_CDATE
                         HIGH   = SY-DATLO ) ).

  P_SALK3  = '100000000'(C01).
  PERFORM CONVERT_KRW.

  GV_SALK3 = '원 이상'(C02).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_KRW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERT_KRW.

  DATA : LV_AMT TYPE I.


  PERFORM REPLACE_COMMA USING P_SALK3.

  LV_AMT = P_SALK3.
  WRITE LV_AMT TO P_SALK3 CURRENCY 'KRW'.

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

  "작업 유형 추가(송종면E 25.01.07)

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN P_SCAL.
        IF SCREEN-GROUP1 = GC_CAL.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REPLACE_COMMA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SALK3
*&---------------------------------------------------------------------*
FORM REPLACE_COMMA USING PV_VAL.

  REPLACE ALL OCCURRENCES OF ',' IN PV_VAL WITH ' '.
  CONDENSE PV_VAL NO-GAPS.

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

  CHECK P_WERKS IS NOT INITIAL.

  SELECT SINGLE WERKS
    FROM T001W INTO @DATA(LV_WERKS)
   WHERE WERKS = @P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E016 WITH '플랜트'(F01). "&를(을) 확인하세요.

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

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

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

  "작업 유형 추가로 인한 추출 로직 변경(송종면E 25.01.07)

  CLEAR : GT_OT[], GT_LIST[], GV_CNT.

  GV_PTYPE = SWITCH #( P_WEEK WHEN 'X' THEN GC_W
                                       ELSE GC_D ).

  DATA(LV_SALK3) = P_SALK3.
  PERFORM REPLACE_COMMA  USING LV_SALK3.
  PERFORM CONVERT_IN_CUR USING LV_SALK3
                      CHANGING GV_VALUE.

  IF P_RCAL = GC_X.
    PERFORM GET_RCAL_DATA.
  ENDIF.

  PERFORM GET_SCAL_DATA.

  IF GT_OT[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  GT_LIST[] = VALUE #( FOR LS_OT IN GT_OT
                       ( VALUE #( BASE CORRESPONDING #( LS_OT )
                                  TOTALQTY = LS_OT-UNQTY + LS_OT-BONDEDQTY
                                  DIFF     = LS_OT-PSTOCK - ( LS_OT-UNQTY + LS_OT-BONDEDQTY ) ) ) ).

  SORT GT_LIST BY WERKS MATNR.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

***********************************************************************
*  DATA : LV_VALUE    TYPE SALK3,
*         LV_ZRESULT  TYPE BAPI_MTYPE,
*         LV_MESSAGE  TYPE BAPI_MSG.
*
*  DATA : LT_IT LIKE ZGTMMS0003 OCCURS 0 WITH HEADER LINE,
*         LT_OT LIKE ZGTMMS0004 OCCURS 0 WITH HEADER LINE.
*
*
*  CLEAR : GT_LIST[], GV_CNT.
*
*  DATA(LV_PTYPE) = SWITCH #( P_WEEK WHEN 'X' THEN GC_W
*                                             ELSE GC_D ).
*
*  IF S_MATNR[] IS NOT INITIAL.
*    SELECT @P_WERKS AS WERKS,
*           MATNR
*      FROM MARA
*      INTO CORRESPONDING FIELDS OF TABLE @LT_IT
*     WHERE MATNR IN @S_MATNR
*       AND LVORM  = @SPACE.
*  ELSE.
*    "현재 S_MATNR 필수 임시처리. 추후 필수 제거되면 추가되는 로직 필요!
*  ENDIF.
*
*  READ TABLE S_BUDAT INDEX 1.
*
*  DATA(LV_SALK3) = P_SALK3.
*  PERFORM REPLACE_COMMA  USING LV_SALK3.
*  PERFORM CONVERT_IN_CUR USING LV_SALK3
*                      CHANGING LV_VALUE.
*
*  CALL FUNCTION 'ZGTMM_GETSUIT_STOCK'
*    EXPORTING
*      I_PTYPE = LV_PTYPE
*      I_FROM  = S_BUDAT-LOW
*      I_TO    = S_BUDAT-HIGH
*      I_VALUE = LV_VALUE
*    IMPORTING
*      ZRESULT = LV_ZRESULT
*      MESSAGE = LV_MESSAGE
*    TABLES
*      IT_TAB  = LT_IT
*      OT_TAB  = LT_OT.
*
*  IF LT_OT[] IS INITIAL.
*    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
*    EXIT.
*  ENDIF.
*
*  GT_LIST[] = VALUE #( FOR LS_OT IN LT_OT
*                       ( VALUE #( BASE CORRESPONDING #( LS_OT )
*                                  TOTALQTY = LS_OT-UNQTY + LS_OT-BONDEDQTY
*                                  DIFF     = LS_OT-PSTOCK - ( LS_OT-UNQTY + LS_OT-BONDEDQTY ) ) ) ).
*
*  SORT GT_LIST BY WERKS MATNR.
*
*  GV_CNT = LINES( GT_LIST ).
*  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
***********************************************************************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_IN_CUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SALK3
*&---------------------------------------------------------------------*
FORM CONVERT_IN_CUR USING PV_SALK3
                 CHANGING PV_VALUE.

  DATA : LV_AMT TYPE DEC11_4.


  CLEAR : PV_VALUE.

  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
    EXPORTING
      CURRENCY        = 'KRW'
      AMOUNT_DISPLAY  = CONV DEC11_4( PV_SALK3 )
    IMPORTING
      AMOUNT_INTERNAL = LV_AMT
    EXCEPTIONS
      INTERNAL_ERROR  = 1
      OTHERS          = 2.

  PV_VALUE = LV_AMT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SCAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SCAL_DATA.

  DATA : LR_VAL TYPE RANGE OF SALK3.


  "산출 정보 조회

  IF GV_VALUE > 0.
    LR_VAL[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_GE
                          LOW    = GV_VALUE ) ).
  ENDIF.

  SELECT *
    FROM ZGTMMT4210
    INTO CORRESPONDING FIELDS OF TABLE GT_OT
   WHERE ZCYCLE    = GV_PTYPE
     AND WERKS     = P_WERKS
     AND MATNR    IN S_MATNR
     AND STOCKVAL IN LR_VAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RCAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_RCAL_DATA.

  DATA : LV_ZRESULT TYPE BAPI_MTYPE,
         LV_MESSAGE TYPE BAPI_MSG.

  DATA : LT_IT LIKE ZGTMMS0003 OCCURS 0 WITH HEADER LINE,
         LT_OT LIKE ZGTMMS0004 OCCURS 0 WITH HEADER LINE.


  "재산출 후 조회

  READ TABLE S_BUDAT INDEX 1.

  CALL FUNCTION 'ZGTMM_GETSUIT_STOCK'
    EXPORTING
      I_PTYPE  = GV_PTYPE
      I_OPTION = GC_9         "Only 저장
      I_FROM   = S_BUDAT-LOW
      I_TO     = S_BUDAT-HIGH
      I_VALUE  = GV_VALUE
    IMPORTING
      ZRESULT  = LV_ZRESULT
      MESSAGE  = LV_MESSAGE
    TABLES
      IT_TAB   = LT_IT
      OT_TAB   = LT_OT.

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


  CLEAR : LT_FCAT[].
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

    CASE GS_FCAT-FIELDNAME.
      WHEN 'WERKS'.
        PERFORM SET_FTXT USING '플랜트'(F01).
      WHEN 'WERKS_N'.
        PERFORM SET_FTXT USING '플랜트명'(F02).
      WHEN 'MATNR'.
        PERFORM SET_FTXT USING '자재'(F03).
      WHEN 'MATNR_N'.
        PERFORM SET_FTXT USING '자재명'(F04).
      WHEN 'APLFZ'.
        PERFORM SET_FTXT USING 'L/T(일수)'(F05).
      WHEN 'FACTOR'.
        PERFORM SET_FTXT USING 'K'(F06).
      WHEN 'REQ_DAILY'.
        PERFORM SET_FTXT USING '일소요량'(F07).
      WHEN 'SAFTYQTY'.
        PERFORM SET_FTXT USING '안전재고'(F08).
        GS_FCAT-EMPHASIZE = GC_C300.
      WHEN 'PSTOCK'.
        PERFORM SET_FTXT USING '적정재고'(F09).
        GS_FCAT-EMPHASIZE = GC_C500.
      WHEN 'UNQTY'.
        PERFORM SET_FTXT USING '창고재고'(F10).
        GS_FCAT-EMPHASIZE = GC_C410.
      WHEN 'BONDEDQTY'.
        PERFORM SET_FTXT USING '보세재고'(F11).
        GS_FCAT-EMPHASIZE = GC_C410.
      WHEN 'TOTALQTY'.
        PERFORM SET_FTXT USING '재고합계'(F12).
        GS_FCAT-EMPHASIZE = GC_C410.
      WHEN 'MEINS'.
        PERFORM SET_FTXT USING '단위'(F13).
      WHEN 'STOCKVAL'.
        PERFORM SET_FTXT USING '현재고액'(F14).
      WHEN 'WAERS'.
        PERFORM SET_FTXT USING '통화'(F15).
      WHEN 'DIFF'.
        PERFORM SET_FTXT USING '적정재고대비'(F16).
        GS_FCAT-EMPHASIZE = GC_C710.
      WHEN 'GIQTY'.
        PERFORM SET_FTXT USING '총 출고수량'(F17).
      WHEN 'DAYC'.
        PERFORM SET_FTXT USING '총 소요일'(F18).

      WHEN OTHERS.
        GS_FCAT-NO_OUT = GC_X.
        GS_FCAT-TECH   = GC_X.
    ENDCASE.

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
      IT_TOOLBAR_EXCLUDING = GT_EXCL
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
