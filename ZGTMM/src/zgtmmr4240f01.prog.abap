*&---------------------------------------------------------------------*
*& Include          ZGTMMR4240F01
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

  P_CDATE = SY-DATLO.

  CLEAR : GV_CDATE, GR_WERKS[].

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

  SET CURSOR FIELD GV_FNM.

  LOOP AT SCREEN.
    IF SCREEN-NAME = GC_P_VERSN.
      SCREEN-REQUIRED = GC_2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VERSN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VERSN USING PV_ID.

  DATA : LT_INFO TYPE VRM_VALUES.


  CHECK S_WERKS[] IS NOT INITIAL
    AND P_CDATE   IS NOT INITIAL.

  CHECK S_WERKS[] <> GR_WERKS[]
     OR P_CDATE   <> GV_CDATE.

  CLEAR : P_VERSN.

  SELECT DISTINCT CAST( TIMESTAMP AS CHAR ) AS KEY
    FROM ZGTMMT4220
    INTO CORRESPONDING FIELDS OF TABLE @LT_INFO
   WHERE WERKS      IN @S_WERKS
     AND ERDAT_LOCAL = @P_CDATE.

  SORT LT_INFO BY KEY.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_INFO.

  GV_CDATE   = P_CDATE.
  GR_WERKS[] = S_WERKS[].

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

  CLEAR : GV_ERR.

  IF P_VERSN IS INITIAL.
    GV_FNM = GC_P_VERSN.

    MESSAGE S278(00) WITH 'Version' DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

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
  MESSAGE E016 WITH '플랜트'(F04). "&를(을) 확인하세요.

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

  LOOP AT GT_WERKS.
    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
                 ID 'WERKS' FIELD GT_WERKS-WERKS.

    CHECK SY-SUBRC <> 0.

    SET CURSOR FIELD 'S_WERKS-LOW'.
    MESSAGE E106 WITH GT_WERKS-WERKS. "플랜트 [&] 작업권한을 확인하세요.
  ENDLOOP.

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

  RANGES : LR_TYPE FOR ZGTMMT4221-TYPE.

  DATA : BEGIN OF LS_KEY,
           WERKS LIKE ZGTMMT4220-WERKS,
           MATNR LIKE ZGTMMT4220-MATNR,
         END   OF LS_KEY.

  DATA : LV_COL(4).


  CLEAR : GT_LIST[], GV_CNT.

  LR_TYPE[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_A )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_B )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_C )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_D )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_G )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_H )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_I )
                       ( SIGN = GC_I OPTION = GC_EQ LOW = GC_J ) ).

  SELECT W~*
    FROM ZGTMM_CV_SUITABLE_STOCK_W AS W
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE TIMESTAMP   = @P_VERSN
     AND WERKS      IN @S_WERKS
     AND MATNR      IN @S_MATNR
*    AND TYPE       IN @LR_TYPE  "삭제(SJM 25.03.26)
     AND ERDAT_LOCAL = @P_CDATE.
*    AND DAILYLAST   = @GC_X.    "삭제(SJM 25.03.26)

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY WERKS MATNR TYPE.

  LV_COL = GC_C700.

  LOOP AT GT_LIST.
    IF NOT ( GT_LIST-WERKS = LS_KEY-WERKS
         AND GT_LIST-MATNR = LS_KEY-MATNR ).
      LV_COL = SWITCH #( LV_COL WHEN 'C200' THEN GC_C700
                                WHEN 'C700' THEN GC_C200 ).
    ENDIF.

    PERFORM CHECK_SQTY. "추가(SJM 25.04.09)

    GT_LIST-R_COL = LV_COL.
    MODIFY GT_LIST TRANSPORTING R_COL C_COL.

    MOVE-CORRESPONDING GT_LIST TO LS_KEY.
  ENDLOOP.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SQTY.

  DATA : LV_NUM(2),
         LV_FNM TYPE LVC_FNAME.


  "D/F/J/L열의 W1~W15까지 적정재고의 +-10% 보다 작거나 크면 Red 표시(SJM 25.04.09)

  CLEAR : GT_LIST-C_COL.

  CHECK GT_LIST-TYPE = GC_D OR GT_LIST-TYPE = GC_J  "Simul.Syst
     OR GT_LIST-TYPE = GC_F OR GT_LIST-TYPE = GC_L. "Simul.User

  DO 15 TIMES.
    LV_NUM += 1.
    LV_FNM  = 'W' && LV_NUM.

    ASSIGN COMPONENT LV_FNM OF STRUCTURE GT_LIST TO FIELD-SYMBOL(<LFS_WQTY>).

    IF <LFS_WQTY> < GT_LIST-SU_QTY_UNDER  "적정재고(-10%)
    OR <LFS_WQTY> > GT_LIST-SU_QTY_OVER.  "적정재고(+10%)
      PERFORM SET_COLOR USING LV_FNM '6' '1' '1' GT_LIST-C_COL.
    ENDIF.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FNM
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GT_LIST_C_COL
*&---------------------------------------------------------------------*
FORM SET_COLOR USING PV_FNM
                     PV_COL
                     PV_INT
                     PV_INV
                     PT_COL TYPE LVC_T_SCOL.

  DATA : LS_COL TYPE LVC_S_SCOL.


  LS_COL-FNAME     = PV_FNM.
  LS_COL-COLOR-COL = PV_COL.
  LS_COL-COLOR-INT = PV_INT.
  LS_COL-COLOR-INV = PV_INV.

  INSERT LS_COL INTO TABLE PT_COL.

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
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )

                       ( CL_GUI_ALV_GRID=>MC_FC_FILTER )
                       ( CL_GUI_ALV_GRID=>MC_FC_FIND )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO )
                       ( CL_GUI_ALV_GRID=>MC_FC_PRINT )
                       ( CL_GUI_ALV_GRID=>MC_FC_SORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_SORT_ASC )
                       ( CL_GUI_ALV_GRID=>MC_FC_SORT_DSC )
                       ( CL_GUI_ALV_GRID=>MC_FC_SUBTOT )
                       ( CL_GUI_ALV_GRID=>MC_FC_SUM )
                       ( CL_GUI_ALV_GRID=>MC_MB_SUM )
                     ).

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
  GS_LAYO-CWIDTH_OPT = GC_A. "GC_X.
  GS_LAYO-ZEBRA      = GC_X.
* GS_LAYO-STYLEFNAME = GC_STYLE.
  GS_LAYO-CTAB_FNAME = GC_C_COL.
  GS_LAYO-INFO_FNAME = GC_R_COL.

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
*& Form SET_LIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'TIMESTAMP'.
      PERFORM SET_FTXT USING 'TimeStamp'(F01).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F02).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'BUKRS_N'.
      PERFORM SET_FTXT USING '회사명'(F03).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F04).
      GS_FCAT-KEY = GC_X.
    WHEN 'WERKS_N'.
      PERFORM SET_FTXT USING '플랜트명'(F05).
      GS_FCAT-KEY = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재'(F06).
      GS_FCAT-KEY = GC_X.
    WHEN 'MATNR_N'.
      PERFORM SET_FTXT USING '자재명'(F07).
      GS_FCAT-KEY = GC_X.

    WHEN 'LT'.
      PERFORM SET_FTXT USING 'LeadTime'(F08).
    WHEN 'SERVICEFACTOR'.
      PERFORM SET_FTXT USING 'Factor'(F09).
    WHEN 'REQQTY'.
      PERFORM SET_FTXT USING '총소요량'(F10).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F11).
    WHEN 'REQ_DAILY'.
      PERFORM SET_FTXT USING '일소요량'(F12).
    WHEN 'UNQTY'.
      PERFORM SET_FTXT USING '창고재고'(F13).
    WHEN 'BONDEDQTY'.
      PERFORM SET_FTXT USING '보세재고'(F14).
    WHEN 'TOTALQTY'.
      PERFORM SET_FTXT USING '재고합계'(F15).

    WHEN 'STOCKVAL'.
      PERFORM SET_FTXT USING '현재고액'(F16).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F17).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F1'.
      PERFORM SET_FTXT USING 'LT/7'(F18).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F2'.
      PERFORM SET_FTXT USING '최종평균'(F19).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F1_SQRT'.
      PERFORM SET_FTXT USING 'SQRT(LT/7)'(F20).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'F2_SQRT'.
      PERFORM SET_FTXT USING '표준편차'(F21).
      GS_FCAT-NO_OUT = GC_X.

    WHEN 'SAFTY_QTY'.
      PERFORM SET_FTXT USING '안전재고'(F22).
    WHEN 'SU_QTY'.
      PERFORM SET_FTXT USING '적정재고'(F23).
    WHEN 'DIFF'.
      PERFORM SET_FTXT USING '현재고-적정재고'(F24).
    WHEN 'PLANWEEK'.
      PERFORM SET_FTXT USING '계획주차'(F25).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'TYPE'.
      PERFORM SET_FTXT USING '라인구분'(F26).
    WHEN 'TYPENAME'.
      PERFORM SET_FTXT USING '구분명'(F27).

    WHEN 'W0'.
      PERFORM SET_FTXT USING 'W0'.
    WHEN 'W1'.
      PERFORM SET_FTXT USING 'W1'.
    WHEN 'W2'.
      PERFORM SET_FTXT USING 'W2'.
    WHEN 'W3'.
      PERFORM SET_FTXT USING 'W3'.
    WHEN 'W4'.
      PERFORM SET_FTXT USING 'W4'.
    WHEN 'W5'.
      PERFORM SET_FTXT USING 'W5'.
    WHEN 'W6'.
      PERFORM SET_FTXT USING 'W6'.
    WHEN 'W7'.
      PERFORM SET_FTXT USING 'W7'.
    WHEN 'W8'.
      PERFORM SET_FTXT USING 'W8'.
    WHEN 'W9'.
      PERFORM SET_FTXT USING 'W9'.
    WHEN 'W10'.
      PERFORM SET_FTXT USING 'W10'.
    WHEN 'W11'.
      PERFORM SET_FTXT USING 'W11'.
    WHEN 'W12'.
      PERFORM SET_FTXT USING 'W12'.
    WHEN 'W13'.
      PERFORM SET_FTXT USING 'W13'.
    WHEN 'W14'.
      PERFORM SET_FTXT USING 'W14'.
    WHEN 'W15'.
      PERFORM SET_FTXT USING 'W15'.

    WHEN 'ERDAT'.
      PERFORM SET_FTXT USING '등록일'(F28).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '등록일(Local)'(F29).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'ERTIM'.
      PERFORM SET_FTXT USING '등록시간'(F30).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '등록시간(Local)'(F31).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '등록자'(F32).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'AEDAT'.
      PERFORM SET_FTXT USING '변경일'(F33).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'AEDAT_LOCAL'.
      PERFORM SET_FTXT USING '변경일(Local)'(F34).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'AETIM'.
      PERFORM SET_FTXT USING '변경시간'(F35).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'AETIM_LOCAL'.
      PERFORM SET_FTXT USING '변경시간(Local)'(F36).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'AENAM'.
      PERFORM SET_FTXT USING '변경자'(F37).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'DAILYLAST'.
      PERFORM SET_FTXT USING '최종데이터'(F38).
      GS_FCAT-NO_OUT = GC_X.

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

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
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT.

  CLEAR : GT_SORT.

  PERFORM SET_SFNM USING 1 'WERKS'   'X' ' ' 'X'.
  PERFORM SET_SFNM USING 2 'WERKS_N' 'X' ' ' 'X'.
  PERFORM SET_SFNM USING 3 'MATNR'   'X' ' ' 'X'.
  PERFORM SET_SFNM USING 4 'MATNR_N' 'X' ' ' 'X'.

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
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVNT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

* SET HANDLER GR_EVENTS->HANDLE_TOOLBAR               FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND          FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK          FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU          FOR GR_GRID.

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
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[].
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
