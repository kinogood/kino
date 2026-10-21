*&---------------------------------------------------------------------*
*& Include          ZGTMMR4250F01
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

  CLEAR : GV_CDATE, GV_WERKS.

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
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GV_ERR.

  IF P_VERSN IS INITIAL.
    GV_FNM = GC_P_VERSN.

    MESSAGE S278(00) WITH 'Version' DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

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


  CHECK P_WERKS IS NOT INITIAL
    AND P_CDATE IS NOT INITIAL.

  CHECK P_WERKS <> GV_WERKS
     OR P_CDATE <> GV_CDATE.

  CLEAR : P_VERSN.

  SELECT DISTINCT CAST( TIMESTAMP AS CHAR ) AS KEY
    FROM ZGTMMT4220
    INTO CORRESPONDING FIELDS OF TABLE @LT_INFO
   WHERE WERKS       = @P_WERKS
     AND ERDAT_LOCAL = @P_CDATE.

  SORT LT_INFO BY KEY.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_INFO.

  GV_CDATE = P_CDATE.
  GV_WERKS = P_WERKS.

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

  CHECK P_WERKS IS NOT INITIAL.

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

  CLEAR : GT_LIST[], GV_CNT.

  SELECT W~*,
         W~W0 AS W00,
         W~W1 AS W01,
         W~W2 AS W02,
         W~W3 AS W03,
         W~W4 AS W04,
         W~W5 AS W05,
         W~W6 AS W06,
         W~W7 AS W07,
         W~W8 AS W08,
         W~W9 AS W09,
         CASE WHEN TYPE = @GC_A OR TYPE = @GC_B OR TYPE = @GC_C
                OR TYPE = @GC_D OR TYPE = @GC_F THEN @GC_C700
              WHEN TYPE = @GC_G OR TYPE = @GC_H OR TYPE = @GC_I
                OR TYPE = @GC_J OR TYPE = @GC_L THEN @GC_C200
          END AS R_COL
    FROM ZGTMM_CV_SUITABLE_STOCK_W AS W
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE ERDAT_LOCAL = @P_CDATE
     AND WERKS       = @P_WERKS
     AND TIMESTAMP   = @P_VERSN
     AND MATNR      IN @S_MATNR.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY TIMESTAMP BUKRS WERKS MATNR TYPE.

  PERFORM SET_STYL_SCOL.

* GT_LIST-STYLE = GT_STYL.
* MODIFY GT_LIST TRANSPORTING STYLE
*  WHERE TYPE = GC_E OR TYPE = GC_K.
*
* GT_LIST-C_COL = GT_SCOL.
* MODIFY GT_LIST TRANSPORTING C_COL
*  WHERE TYPE = GC_E.

  LOOP AT GT_LIST.
    CLEAR : GV_NUM, GV_FNM.

    CASE GT_LIST-TYPE.
      WHEN 'E'.
        GT_LIST-STYLE = GT_STYL.
        GT_LIST-C_COL = GT_SCOL.

      WHEN 'K'.
        GT_LIST-STYLE = GT_STYL.

      WHEN 'D' OR 'J'  "Simul.Syst
        OR 'F' OR 'L'. "Simul.User
        "Simul.수량이 적정재고 수량보다 많은 경우 Red 표시(SJM 25.03.10)
        DO 15 TIMES.
          GV_NUM += 1.
          GV_FNM  = 'W' && GV_NUM.

          ASSIGN COMPONENT GV_FNM OF STRUCTURE GT_LIST TO FIELD-SYMBOL(<LFS_WQTY>).
          PERFORM CHECK_SQTY USING GV_FNM
                                   <LFS_WQTY>           "Simul.Qty
                                   GT_LIST-SU_QTY_UNDER "적정재고(-10%)
                                   GT_LIST-SU_QTY_OVER  "적정재고(+10%)
                          CHANGING GT_LIST-C_COL.
        ENDDO.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY GT_LIST TRANSPORTING STYLE C_COL.
  ENDLOOP.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYL_SCOL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_STYL_SCOL.

  CLEAR : GT_STYL, GT_SCOL.

  LOOP AT GT_FCAT INTO GS_FCAT.
    IF ( GS_FCAT-FIELDNAME+0(2) = GC_W0
      OR GS_FCAT-FIELDNAME+0(2) = GC_W1 )
   AND   GS_FCAT-FIELDNAME <> GC_W00.
      PERFORM SET_STYLE USING 'E' GS_FCAT-FIELDNAME GT_STYL.
    ELSE.
      PERFORM SET_COLOR USING GS_FCAT-FIELDNAME '7' '0' '0' GT_SCOL.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_STYL
*&---------------------------------------------------------------------*
FORM SET_STYLE USING PV_MODE
                     PV_FNAME
                     PT_STYLE TYPE LVC_T_STYL.

  DATA : LS_STYLE TYPE LVC_S_STYL.


  LS_STYLE-FIELDNAME = PV_FNAME.

  CASE PV_MODE.
    WHEN 'E'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    WHEN 'D'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  ENDCASE.

  INSERT LS_STYLE INTO TABLE PT_STYLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_FCAT_FIELDNAME
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GT_SCOL
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
*& Form CHECK_SQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_FNM
*&      --> <LFS_WQTY>
*&      --> GT_LIST_SU_QTY_UNDER
*&      --> GT_LIST_SU_QTY_OVER
*&      <-- GT_LIST-C_COL
*&---------------------------------------------------------------------*
FORM CHECK_SQTY USING PV_FNM
                      PV_WQTY
                      PV_UQTY "적정재고(-10%)
                      PV_OQTY "적정재고(+10%)
             CHANGING PT_CCOL TYPE LVC_T_SCOL.

* IF PV_WQTY > PV_SQTY. "Simul.Qty > 적정재고
  "적정재고 비교 기준 변경(SJM 25.03.13)
  " "Simul.Qty < 적정재고(-10%) or Simul.Qty > 적정재고(+10%)
  IF PV_WQTY < PV_UQTY OR PV_WQTY > PV_OQTY.
    PERFORM SET_COLOR USING PV_FNM '6' '1' '1' PT_CCOL.
  ELSE.
    DELETE PT_CCOL WHERE FNAME     = PV_FNM
                     AND COLOR-COL = GC_6.
  ENDIF.

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
  GS_LAYO-STYLEFNAME = GC_STYLE.
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
    WHEN 'SU_QTY_UNDER'. "추가(SJM 25.03.13)
      PERFORM SET_FTXT USING '적정재고(-10%)'(F39).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'SU_QTY_OVER'.  "추가(SJM 25.03.13)
      PERFORM SET_FTXT USING '적정재고(+10%)'(F40).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'DIFF'.
      PERFORM SET_FTXT USING '현재고-적정재고'(F24).
    WHEN 'PLANWEEK'.
      PERFORM SET_FTXT USING '계획주차'(F25).
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'TYPE'.
      PERFORM SET_FTXT USING '라인구분'(F26).
    WHEN 'TYPENAME'.
      PERFORM SET_FTXT USING '구분명'(F27).

    WHEN 'W00'.
      PERFORM SET_DTXT USING 'W0'.
    WHEN 'W01'.
      PERFORM SET_DTXT USING 'W1'.
    WHEN 'W02'.
      PERFORM SET_DTXT USING 'W2'.
    WHEN 'W03'.
      PERFORM SET_DTXT USING 'W3'.
    WHEN 'W04'.
      PERFORM SET_DTXT USING 'W4'.
    WHEN 'W05'.
      PERFORM SET_DTXT USING 'W5'.
    WHEN 'W06'.
      PERFORM SET_DTXT USING 'W6'.
    WHEN 'W07'.
      PERFORM SET_DTXT USING 'W7'.
    WHEN 'W08'.
      PERFORM SET_DTXT USING 'W8'.
    WHEN 'W09'.
      PERFORM SET_DTXT USING 'W9'.
    WHEN 'W10'.
      PERFORM SET_DTXT USING 'W10'.
    WHEN 'W11'.
      PERFORM SET_DTXT USING 'W11'.
    WHEN 'W12'.
      PERFORM SET_DTXT USING 'W12'.
    WHEN 'W13'.
      PERFORM SET_DTXT USING 'W13'.
    WHEN 'W14'.
      PERFORM SET_DTXT USING 'W14'.
    WHEN 'W15'.
      PERFORM SET_DTXT USING 'W15'.

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
*& Form SET_DTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DTXT USING PV_TEXT.

  DATA : LV_MON(4),
         LV_SUN(4).


  IF PV_TEXT = GC_W0.
    PERFORM GET_WDATE.
  ELSE.
    GV_MON = GV_MON + 7.
    GV_SUN = GV_SUN + 7.
  ENDIF.

  PERFORM SET_FTXT USING PV_TEXT.

  PERFORM RESET_DATE USING GV_MON+4(4) CHANGING LV_MON.
  PERFORM RESET_DATE USING GV_SUN+4(4) CHANGING LV_SUN.

  GS_FCAT-TOOLTIP = LV_MON && '~' && LV_SUN.

  GS_FCAT-JUST = GC_C.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_WDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_WDATE.

  CLEAR : GV_MON, GV_SUN.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      DATE   = SY-DATLO
    IMPORTING
*     WEEK   =
      MONDAY = GV_MON
      SUNDAY = GV_SUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_MON+4(4)
*&      <-- LV_MON
*&---------------------------------------------------------------------*
FORM RESET_DATE USING PV_IDATE
             CHANGING PV_ODATE.

  DATA : LV_MON(2),
         LV_DAY(2).


  CLEAR : PV_ODATE.

  LV_MON = PV_IDATE+0(2).
  LV_DAY = PV_IDATE+2(2).

  PERFORM DELE_ZERO USING LV_MON.
  PERFORM DELE_ZERO USING LV_DAY.

  PV_ODATE = LV_MON && '/' && LV_DAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_ZERO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_MON
*&---------------------------------------------------------------------*
FORM DELE_ZERO USING PV_DATE.

  SHIFT PV_DATE LEFT DELETING LEADING '0'.

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
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK          FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU          FOR GR_GRID.

  CALL METHOD GR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
*     IT_SORT              = GT_SORT[].
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
*& Form CHECK_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_EXIT USING PV_MODE.

  PERFORM CHECK_CHGON.

  IF GV_CHG = GC_X.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '변경된 Data를 저장하시겠습니까?'(P02).

    IF GV_ANS = GC_1.
      PERFORM SAVE_DATA USING ' '.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM FREE_OBJ.

  CASE PV_MODE.
    WHEN 'C'.
      LEAVE PROGRAM.
    WHEN 'N'.
      SET SCREEN 0.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHGON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHGON.

  CLEAR : GV_CHG.

  CHECK LINE_EXISTS( GT_LIST[ CHG = GC_X ] ).

  GV_CHG = GC_X.

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
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODI
                                        PT_MODI TYPE LVC_T_MODI
                                        PV_OTEXT.

  CLEAR : GV_REF.
  CHECK PV_MODI IS NOT INITIAL.

  LOOP AT PT_MODI INTO GS_MODI.
    READ TABLE GT_LIST INTO GS_ELST INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

*   GV_FNM = GS_MODI-FIELDNAME.
    GV_ROW = GS_MODI-ROW_ID.

    CASE GS_MODI-FIELDNAME+0(2).
      WHEN 'W0' OR 'W1'.
        PERFORM CHANGE_WXX USING GS_MODI-FIELDNAME 'X'.

    ENDCASE.

    GV_REF = GC_X.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_WXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MODI-FIELDNAME
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHANGE_WXX USING PV_FNM
                      PV_CHG.

  DATA : LV_FTYP(1),
         LV_LTYP(1).

  DATA : LV_FNM(10),
         LV_NUM     TYPE NUMC2,
         LV_TIM     TYPE NUMC2,
         LV_ROW     TYPE LVC_INDEX.


  CASE GS_ELST-TYPE.
    WHEN 'E'.
      LV_FTYP = GC_A.
      LV_LTYP = GC_F.
    WHEN 'K'.
      LV_FTYP = GC_G.
      LV_LTYP = GC_L.
  ENDCASE.

  IF PV_FNM = GC_W01.
    LV_FNM = GC_TOTALQTY.
  ELSE.
    LV_NUM = PV_FNM+1(2) - 1.
    LV_FNM = 'W' && LV_NUM.
  ENDIF.
  LV_ROW = GV_ROW + 1.

  CLEAR : GS_FLST, GS_LLST.

  READ TABLE GT_LIST INTO GS_FLST
    WITH KEY TIMESTAMP = GS_ELST-TIMESTAMP
             BUKRS     = GS_ELST-BUKRS
             WERKS     = GS_ELST-WERKS
             MATNR     = GS_ELST-MATNR
             TYPE      = LV_FTYP
             BINARY SEARCH.

  READ TABLE GT_LIST INTO GS_LLST
    WITH KEY TIMESTAMP = GS_ELST-TIMESTAMP
             BUKRS     = GS_ELST-BUKRS
             WERKS     = GS_ELST-WERKS
             MATNR     = GS_ELST-MATNR
             TYPE      = LV_LTYP
             BINARY SEARCH.

  ASSIGN COMPONENT PV_FNM OF STRUCTURE GS_ELST TO FIELD-SYMBOL(<LFS_EVAL>).
  ASSIGN COMPONENT PV_FNM OF STRUCTURE GS_FLST TO FIELD-SYMBOL(<LFS_FVAL>).
  ASSIGN COMPONENT PV_FNM OF STRUCTURE GS_LLST TO FIELD-SYMBOL(<LFS_LVAL>).
  ASSIGN COMPONENT LV_FNM OF STRUCTURE GS_LLST TO FIELD-SYMBOL(<LFS_PVAL>).

  <LFS_LVAL> = <LFS_PVAL> - <LFS_FVAL> + <LFS_EVAL>.

  IF PV_CHG = GC_X.
    PERFORM MODIFY_LIST USING GS_ELST "Edit 필드
                              GV_ROW
                              PV_FNM.
  ENDIF.

  "Simul.수량이 적정재고 수량보다 많은 경우 Red 표시(SJM 25.03.10)
* ASSIGN COMPONENT 'SU_QTY' OF STRUCTURE GS_LLST TO FIELD-SYMBOL(<LFS_SVAL>).
  ASSIGN COMPONENT 'SU_QTY_UNDER' OF STRUCTURE GS_LLST TO FIELD-SYMBOL(<LFS_UVAL>).
  ASSIGN COMPONENT 'SU_QTY_OVER'  OF STRUCTURE GS_LLST TO FIELD-SYMBOL(<LFS_OVAL>).
  PERFORM CHECK_SQTY USING PV_FNM
                           <LFS_LVAL>     "Simul.User
                           <LFS_UVAL>     "적정재고(-10%)
                           <LFS_OVAL>     "적정재고(+10%)
                  CHANGING GS_LLST-C_COL.

  PERFORM MODIFY_LIST USING GS_LLST "계산 필드(Last)
                            LV_ROW
                            PV_FNM.

  "해당 주차 이후 주차 자동 계산
  CHECK PV_CHG = GC_X.

  LV_TIM = 15 - PV_FNM+1(2).
  CHECK LV_TIM IS NOT INITIAL.

  LV_NUM = PV_FNM+1(2).

  DO LV_TIM TIMES.
    LV_NUM += 1.
    LV_FNM  = 'W' && LV_NUM.

    PERFORM CHANGE_WXX USING LV_FNM ' '.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ELST
*&      --> GV_ROW
*&      --> PV_FNM
*&---------------------------------------------------------------------*
FORM MODIFY_LIST USING PS_XLST
                       PV_ROW
                       PV_FNM.

  ASSIGN COMPONENT GC_CHG OF STRUCTURE PS_XLST TO FIELD-SYMBOL(<LFS_CHG>).
  <LFS_CHG> = GC_X.

  MODIFY GT_LIST FROM PS_XLST INDEX PV_ROW
         TRANSPORTING (PV_FNM) (GC_CHG) (GC_C_COL).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_DATA USING PV_POP.

  DATA : LV_VALID.


  CLEAR : GT_M20[], GT_M21[].

  GR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = LV_VALID ).
  CHECK LV_VALID IS NOT INITIAL.

  IF PV_POP = GC_X.
    PERFORM CHECK_CHGON.

    IF GV_CHG = GC_X.
      PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                     '변경된 Data를 저장하시겠습니까?'(P02).

      CHECK GV_ANS = GC_1.
    ELSE.
      MESSAGE S017. "변경된 내역이 없습니다.
      EXIT.
    ENDIF.
  ENDIF.

* GV_REF = GC_X.

  PERFORM SET_TIMESTAMP USING ' ' 'X'.

  LOOP AT GT_LIST.
    CHECK GT_LIST-CHG = GC_X.

    PERFORM SET_M20.
    PERFORM SET_M21.
  ENDLOOP.

  IF GT_M21[] IS INITIAL.
    MESSAGE S007 DISPLAY LIKE 'E'. "저장할 내역이 없습니다.
    EXIT.
  ENDIF.

  MODIFY ZGTMMT4221 FROM TABLE GT_M21.

  IF SY-SUBRC = 0.
    LOOP AT GT_M20.
      UPDATE ZGTMMT4220 SET AEDAT       = GS_CHNG-AEDAT
                            AEDAT_LOCAL = GS_CHNG-AEDAT_LOCAL
                            AETIM       = GS_CHNG-AETIM
                            AETIM_LOCAL = GS_CHNG-AETIM_LOCAL
                            AENAM       = GS_CHNG-AENAM
                      WHERE TIMESTAMP   = P_VERSN "GT_M20-TIMESTAMP
                        AND BUKRS       = GT_M20-BUKRS
                        AND WERKS       = GT_M20-WERKS
                        AND MATNR       = GT_M20-MATNR.
    ENDLOOP.

    COMMIT WORK.

    PERFORM REFR_DATA.
    MESSAGE S080. "저장 성공
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
*&---------------------------------------------------------------------*
*& Form SET_M20
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_M20.

  CLEAR : GT_M20.

* GT_M20-TIMESTAMP = GT_LIST-TIMESTAMP.
  GT_M20-BUKRS     = GT_LIST-BUKRS.
  GT_M20-WERKS     = GT_LIST-WERKS.
  GT_M20-MATNR     = GT_LIST-MATNR.

  COLLECT GT_M20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_M21
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_M21.

  CLEAR : GT_M21.

  MOVE-CORRESPONDING GT_LIST TO GT_M21.
  GT_M21-W0 = GT_LIST-W00.
  GT_M21-W1 = GT_LIST-W01.
  GT_M21-W2 = GT_LIST-W02.
  GT_M21-W3 = GT_LIST-W03.
  GT_M21-W4 = GT_LIST-W04.
  GT_M21-W5 = GT_LIST-W05.
  GT_M21-W6 = GT_LIST-W06.
  GT_M21-W7 = GT_LIST-W07.
  GT_M21-W8 = GT_LIST-W08.
  GT_M21-W9 = GT_LIST-W09.

  APPEND GT_M21.

ENDFORM.
