*&---------------------------------------------------------------------*
*& Include          ZGTMMR6210F01
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

  CLEAR : S_SPMON[].
  S_SPMON[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

  PERFORM SET_SP USING 'P' 'X' ' '. "최초(비율)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SP USING PV_SP
                  PV_S
                  PV_P.

  GV_SP = PV_SP.
  GV_S  = PV_S.
  GV_P  = PV_P.

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
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  DATA : LV_DATE LIKE SY-DATLO.


  CLEAR : GV_DUR, GR_SPMON[].

  IF S_SPMON-HIGH IS INITIAL.
    GV_DUR = 1.
    EXIT.
  ENDIF.

  CALL FUNCTION 'HR_PT_GET_MONTHS'
    EXPORTING
      FIRST_DATE        = CONV SYST_DATUM( S_SPMON-LOW && '01' )
      SECOND_DATE       = CONV SYST_DATUM( S_SPMON-HIGH && '01' )
      MODIFY_INTERVAL   = SPACE
    IMPORTING
      DURATION          = GV_DUR
    EXCEPTIONS
      INVALID_SEQ_DATES = 1
      OTHERS            = 2.

  IF GV_DUR = 12.
    SET CURSOR FIELD 'S_SPMON-HIGH'.
    MESSAGE E118. "12개월 데이터만 조회 가능합니다.
  ENDIF.

  GV_DUR += 1.

  LV_DATE = S_SPMON-LOW && '01'.

  DO GV_DUR TIMES.
    IF SY-INDEX <> 1.
      _CALC_DATE LV_DATE '00' '01' '+' '00'.
      LV_DATE = GV_CDATE.
    ENDIF.

    APPEND VALUE #( SIGN   = GC_I
                    OPTION = GC_EQ
                    LOW    = LV_DATE+0(6) ) TO GR_SPMON.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_SPMON-LOW
*&---------------------------------------------------------------------*
FORM F4_SPMON USING PV_SPMON.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = CONV KMONTH( SY-DATLO+0(6) )
*     FACTORY_CALENDAR           = ' '
*     HOLIDAY_CALENDAR           = ' '
*     LANGUAGE                   = SY-LANGU
*     START_COLUMN               = 8
*     START_ROW                  = 5
    IMPORTING
      SELECTED_MONTH             = PV_SPMON
*     RETURN_CODE                =
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_MTGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_MTGRP USING PV_FIELD.

  SELECT ZMTGRP,
         ZMTGRPT
    FROM ZGTMMT6100
    INTO TABLE @DATA(LT_MTG)
   WHERE ZUSED = @SPACE
     AND LVORM = @SPACE.

  SORT LT_MTG BY ZMTGRP.

  PERFORM F4IF_TABLE TABLES LT_MTG
                      USING 'ZMTGRP'
                            PV_FIELD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MTG
*&      --> P_
*&      --> PV_FIELD
*&---------------------------------------------------------------------*
FORM F4IF_TABLE TABLES PT_VTAB
                 USING PV_RFIELD
                       PV_DFIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = PV_RFIELD
*     PVALKEY         = ' '
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_DFIELD
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      VALUE_ORG       = GC_S
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*     IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = PT_VTAB
*     FIELD_TAB       =
      RETURN_TAB      = GT_RTAB
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

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

  PERFORM ADD_DYN_FCAT.

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
    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F01).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-JUST   = GC_C.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F02).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-JUST   = GC_C.
    WHEN 'ZMTGRP'.
      PERFORM SET_FTXT USING '발주그룹'(F03).
      GS_FCAT-KEY    = GC_X.
      GS_FCAT-JUST   = GC_C.
      GS_FCAT-NO_OUT = GC_X.
    WHEN 'ZMTGRPT'.
      PERFORM SET_FTXT USING '발주그룹 내역'(F04).
      GS_FCAT-KEY    = GC_X.
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F05).
      GS_FCAT-KEY    = GC_X.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '공급업체명'(F06).
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F07).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING 'OUn'(F08).
    WHEN 'BSTMG_S'.
      PERFORM SET_FTXT USING '물량 합'(F09).
      GS_FCAT-EMPHASIZE = GC_C300.
      GS_FCAT-DO_SUM    = GC_X.
    WHEN 'BSTMG_P'.
      PERFORM SET_FTXT USING '물량(%)'(F10).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'BWERT_S'.
      PERFORM SET_FTXT USING '금액 합'(F11).
      GS_FCAT-EMPHASIZE = GC_C500.
      GS_FCAT-DO_SUM    = GC_X.
    WHEN 'BWERT_P'.
      PERFORM SET_FTXT USING '금액(%)'(F12).
      GS_FCAT-EMPHASIZE = GC_C500.

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_DYN_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_DYN_FCAT.

  DATA : LV_TXT(10).


  GV_CNT = LINES( GT_FCAT[] ).

  LOOP AT GR_SPMON.
    LV_TXT = GR_SPMON-LOW+0(4) && '.' && GR_SPMON-LOW+4(2).

    PERFORM SET_DYN_FNM.

    GV_CNT += 1.
    PERFORM MAKE_FCAT USING :
            'S' 'COL_POS'    GV_CNT,
            ' ' 'FIELDNAME'  GV_FSQ,
            ' ' 'QFIELDNAME' 'MEINS',
            ' ' 'REF_FIELD'  'MENGE',
            ' ' 'REF_TABLE'  'AUBF',
            ' ' 'EMPHASIZE'  'C300',
            ' ' 'DO_SUM'     'X',
            ' ' 'NO_OUT'     GV_S,
            ' ' 'TOOLTIP'    '물량 합'(F09),
            'E' 'COLTEXT'    LV_TXT.

    GV_CNT += 1.
    PERFORM MAKE_FCAT USING :
            'S' 'COL_POS'    GV_CNT,
            ' ' 'FIELDNAME'  GV_FPQ,
            ' ' 'REF_FIELD'  'DPROZ',
            ' ' 'REF_TABLE'  'T169K',
            ' ' 'EMPHASIZE'  'C300',
            ' ' 'DO_SUM'     'X',
            ' ' 'NO_OUT'     GV_P,
            ' ' 'TOOLTIP'    '물량(%)'(F10),
            'E' 'COLTEXT'    LV_TXT.

    GV_CNT += 1.
    PERFORM MAKE_FCAT USING :
            'S' 'COL_POS'    GV_CNT,
            ' ' 'FIELDNAME'  GV_FSA,
            ' ' 'CFIELDNAME' 'WAERS',
            ' ' 'REF_FIELD'  'EKWRT',
            ' ' 'REF_TABLE'  'AUBF',
            ' ' 'EMPHASIZE'  'C500',
            ' ' 'DO_SUM'     'X',
            ' ' 'NO_OUT'     GV_S,
            ' ' 'TOOLTIP'    '금액 합'(F11),
            'E' 'COLTEXT'    LV_TXT.

    GV_CNT += 1.
    PERFORM MAKE_FCAT USING :
            'S' 'COL_POS'    GV_CNT,
            ' ' 'FIELDNAME'  GV_FPA,
            ' ' 'REF_FIELD'  'DPROZ',
            ' ' 'REF_TABLE'  'T169K',
            ' ' 'EMPHASIZE'  'C500',
            ' ' 'DO_SUM'     'X',
            ' ' 'NO_OUT'     GV_P,
            ' ' 'TOOLTIP'    '금액(%)'(F12),
            'E' 'COLTEXT'    LV_TXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DYN_FNM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DYN_FNM.

  GV_FSQ = 'SQ_' && GR_SPMON-LOW.
  GV_FPQ = 'PQ_' && GR_SPMON-LOW.
  GV_FSA = 'SA_' && GR_SPMON-LOW.
  GV_FPA = 'PA_' && GR_SPMON-LOW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> LV_FNM
*&---------------------------------------------------------------------*
FORM MAKE_FCAT USING PV_GUBUN
                     PV_FNAME
                     PV_FVAL.

  DATA : LV_FNAME(40).
  FIELD-SYMBOLS : <LFS_FVAL>.


  IF PV_GUBUN = GC_S.
    CLEAR : GS_FCAT.
  ENDIF.

  CONCATENATE 'GS_FCAT-' PV_FNAME INTO LV_FNAME.
  ASSIGN (LV_FNAME) TO <LFS_FVAL>.
  MOVE    PV_FVAL   TO <LFS_FVAL>.

  CHECK PV_GUBUN = GC_E.
  APPEND GS_FCAT TO GT_FCAT.

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


  UNASSIGN : <GT_LIST>, <GT_LSUM>, <GS_LIST>.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT
    IMPORTING
      EP_TABLE        = LR_DATA.

  ASSIGN LR_DATA->* TO <GT_LIST>.

  CREATE DATA LR_DATA LIKE LINE OF <GT_LIST>.
  ASSIGN LR_DATA->* TO <GS_LIST>.

  CREATE DATA LR_DATA LIKE TABLE OF <GS_LIST>.
  ASSIGN LR_DATA->* TO <GT_LSUM>.

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

  DATA : LV_QTY LIKE EKPO-MENGE,
         LV_AMT LIKE EKPO-NETWR,
         LV_STY LIKE AUBF-MENGE,
         LV_SMT LIKE AUBF-EKWRT.


  CLEAR : GT_DATA[], <GT_LIST>, <GT_LSUM>, GV_CNT.

  SELECT P~EKORG,
         P~WERKS,
         P~ZMTGRP,
         P~CHAR30 AS ZMTGRPT,
         P~LIFNR,
         P~NAME1,
         P~WAERS,
         P~MEINS,
         P~YMONTH,
         P~BSTMG,
         P~BWERT
    FROM ZGTMM_CV_BD_POLIST AS P INNER JOIN ZGTMMT6100 AS G
      ON P~ZMTGRP = G~ZMTGRP
     AND G~ZUSED  = @SPACE
     AND G~LVORM  = @SPACE
   WHERE P~EKORG   = @P_EKORG
     AND P~WERKS   = @P_WERKS
     AND P~YMONTH IN @S_SPMON
     AND P~LIFNR  IN @S_LIFNR
     AND P~ZMTGRP IN @S_MTGRP
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

* SORT GT_DATA BY EKORG WERKS ZMTGRPT LIFNR WAERS MEINS YMONTH.
  SORT GT_DATA BY EKORG WERKS ZMTGRPT WAERS MEINS LIFNR YMONTH.

  LOOP AT GT_DATA.
    MOVE-CORRESPONDING GT_DATA TO GS_DATA.

    AT NEW LIFNR.
      CLEAR : LV_STY, LV_SMT, <GS_LIST>.
      MOVE-CORRESPONDING GS_DATA TO <GS_LIST>.
    ENDAT.

    AT NEW YMONTH.
      CLEAR : LV_QTY, LV_AMT.
    ENDAT.

    LV_QTY += GT_DATA-BSTMG.
    LV_AMT += GT_DATA-BWERT.

    LV_STY += GT_DATA-BSTMG.
    LV_SMT += GT_DATA-BWERT.

    AT END OF YMONTH.
      PERFORM SET_YMONTH USING 'SQ_' LV_QTY.
      PERFORM SET_YMONTH USING 'SA_' LV_AMT.
    ENDAT.

    AT END OF LIFNR.
      PERFORM SET_SVAL USING 'BSTMG_S' LV_STY.
      PERFORM SET_SVAL USING 'BWERT_S' LV_SMT.

      PERFORM SET_CSORT.

      APPEND <GS_LIST> TO <GT_LIST>.

      PERFORM SET_SSUM.
    ENDAT.
  ENDLOOP.

  SORT <GT_LSUM> BY (GC_EKORG) (GC_WERKS) (GC_ZMTGRPT)
                    (GC_WAERS) (GC_MEINS).

  "비율 계산
  LOOP AT <GT_LIST> INTO <GS_LIST>.
    MOVE-CORRESPONDING <GS_LIST> TO GT_LIST.

    PERFORM CAL_PCT USING 'BSTMG_S' 'BSTMG_P'.
    PERFORM CAL_PCT USING 'BWERT_S' 'BWERT_P'.

    LOOP AT GR_SPMON.
      PERFORM SET_DYN_FNM.

      PERFORM CAL_PCT USING GV_FSQ GV_FPQ.
      PERFORM CAL_PCT USING GV_FSA GV_FPA.
    ENDLOOP.

    MODIFY <GT_LIST> FROM <GS_LIST>.
  ENDLOOP.

  GV_CNT = LINES( <GT_LIST> ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_YMONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_QTY
*&---------------------------------------------------------------------*
FORM SET_YMONTH USING PV_TYPE
                      PV_FVAL.

  DATA(LV_FNM) = PV_TYPE && GS_DATA-YMONTH.

  ASSIGN COMPONENT LV_FNM OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_VAL>).

  CHECK SY-SUBRC = 0.
  <LFS_VAL> = PV_FVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_STY
*&---------------------------------------------------------------------*
FORM SET_SVAL USING PV_FNME
                    PV_FVAL.

  ASSIGN COMPONENT PV_FNME OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_VAL>).

  CHECK SY-SUBRC = 0.
  <LFS_VAL> = PV_FVAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CSORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CSORT.

  "Sort 기준 필드 조합

  ASSIGN COMPONENT 'CSORT' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_VAL>).

  CHECK SY-SUBRC = 0.
  <LFS_VAL> = '합    계'(T01)  && `                   `
           && GS_DATA-ZMTGRPT && ` / `
           && GS_DATA-WAERS   && ` / `
           && GS_DATA-MEINS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SSUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SSUM.

  DATA : BEGIN OF LS_LIST OCCURS 0,
           ZMTGRP LIKE ZGTMMT6100-ZMTGRP,  "발주그룹
           LIFNR  LIKE EKKO-LIFNR,         "공급업체
           NAME1  LIKE LFA1-NAME1,         "공급업체명
*          WAERS  LIKE EKKO-WAERS,         "통화
*          MEINS  LIKE EKPO-MEINS,         "OUn
         END   OF LS_LIST.


  MOVE-CORRESPONDING LS_LIST TO <GS_LIST>.
  COLLECT <GS_LIST> INTO <GT_LSUM>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_PCT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CAL_PCT USING PV_SUM
                   PV_PCT.

  READ TABLE <GT_LSUM> ASSIGNING FIELD-SYMBOL(<LS_LSUM>)
                       WITH KEY (GC_EKORG)   = GT_LIST-EKORG
                                (GC_WERKS)   = GT_LIST-WERKS
                                (GC_ZMTGRPT) = GT_LIST-ZMTGRPT
                                (GC_WAERS)   = GT_LIST-WAERS
                                (GC_MEINS)   = GT_LIST-MEINS
                                BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  ASSIGN COMPONENT PV_SUM OF STRUCTURE <LS_LSUM> TO FIELD-SYMBOL(<LFS_TOT>).
  CHECK <LFS_TOT> IS NOT INITIAL.

  ASSIGN COMPONENT PV_SUM OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_SUM>).
  ASSIGN COMPONENT PV_PCT OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_PCT>).

  <LFS_PCT> = ( <LFS_SUM> / <LFS_TOT> ) * 100.

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

  GR_SPLIT = NEW #( PARENT  = GR_DOCK
                    ROWS    = 2
                    COLUMNS = 1 ).

  "#1 Row
  GR_TCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 1
                                      COLUMN    = 1 ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 17 ).

  "#2 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 2
                                      COLUMN    = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

* GR_SPLIT->SET_ROW_HEIGHT( ID     = 2
*                           HEIGHT = 50 ).

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
  GS_LAYO-NO_TOTLINE = GC_X.

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

*  PERFORM SET_SFNM USING 1 'CSORT'   'X' ' ' 'X'. "2025.06.29 - ALV Subtotal 제외.
* PERFORM SET_SFNM USING 2 'ZMTGRPT' 'X' ' ' 'X'.

* PERFORM SET_SFNM USING 2 'WAERS'   'X' ' ' 'X'.
* PERFORM SET_SFNM USING 3 'MEINS'   'X' ' ' 'X'.

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

  SET HANDLER GR_EVENTS->HANDLE_TOP_OF_PAGE  FOR GR_HGRID.
  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR GR_HGRID.

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

  CALL METHOD GR_HGRID->SET_TABLE_FOR_FIRST_DISPLAY
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
      IT_OUTTAB            = <GT_LIST>[]
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[].
*     IT_FILTER            =

  PERFORM SET_DOCU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DOCU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DOCU.

  GR_TDOCU = NEW #( STYLE = 'ALV_GRID' ).

  GR_TDOCU->INITIALIZE_DOCUMENT( BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA ).

  GR_HGRID->LIST_PROCESSING_EVENTS( I_EVENT_NAME = 'TOP_OF_PAGE'
                                    I_DYNDOC_ID  = GR_TDOCU ).

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
      CALL METHOD GR_HGRID->FREE.
      CALL METHOD GR_TCNTR->FREE.
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_TCNTR, GR_HCNTR, GR_DOCK.

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

  PERFORM SET_SP USING 'P' 'X' ' '. "최초(비율)

  PERFORM GET_DATA.
  PERFORM REFRESH_GRID.

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

  PERFORM RESET_FCAT.

  CALL METHOD GR_HGRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

  CALL METHOD GR_HGRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_FCAT.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CASE GS_FCAT-FIELDNAME+0(2).
      WHEN 'SQ' OR 'SA'.
        GS_FCAT-NO_OUT = GV_S.
      WHEN 'PQ' OR 'PA'.
        GS_FCAT-NO_OUT = GV_P.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    MODIFY GT_FCAT FROM GS_FCAT TRANSPORTING NO_OUT.
  ENDLOOP.

  CALL METHOD GR_HGRID->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHSP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHSP_DATA.

  CASE GV_SP.
    WHEN 'S'.
      PERFORM SET_SP USING 'P' 'X' ' '.

    WHEN 'P'.
      PERFORM SET_SP USING 'S' ' ' 'X'.

  ENDCASE.

  PERFORM REFRESH_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MTGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MTGR.

  CALL TRANSACTION 'ZGTMMV6100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_DYNDOC_ID
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOP_OF_PAGE USING PR_DOCU TYPE REF TO CL_DD_DOCUMENT
                              PV_OTEXT.

  CALL METHOD PR_DOCU->ADD_PICTURE
    EXPORTING
      PICTURE_ID = 'ZGTMM_LEGEND' "OAOR
      WIDTH      = '10%'.

  PR_DOCU->MERGE_DOCUMENT( ).

  PR_DOCU->DISPLAY_DOCUMENT( REUSE_CONTROL = 'X'
                             PARENT        = GR_TCNTR ).

ENDFORM.
