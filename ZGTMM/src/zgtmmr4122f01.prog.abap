*&---------------------------------------------------------------------*
*& Include          ZGTMMR4122F01
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

  CLEAR : S_BUDAT[].
  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = SY-DATLO - 30
                         HIGH   = SY-DATLO ) ).

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
  PERFORM CHECK_BUKRS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BUKRS.

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.
*    AND SPRAS = SY-LANGU.

  CHECK SY-SUBRC <> 0.
  MESSAGE E016 WITH '회사코드'(F02). "&를(을) 확인하세요.

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

  DATA : LV_FDATE LIKE SY-DATUM,
         LV_TDATE LIKE SY-DATUM.
  DATA : LV_PREIS LIKE ZMMT0860-PREIS.
  DATA : LV_PREIS_EX LIKE ZMMT0860-PREIS.

  CLEAR : GT_HLIST[], GV_CNT.

  PERFORM SET_CDATE CHANGING LV_FDATE
                             LV_TDATE.

  SELECT CASE WHEN REMAINVAL > 0 THEN @ICON_LED_GREEN
              WHEN REMAINVAL < 0 THEN @ICON_LED_RED
                                 ELSE @ICON_LED_YELLOW
          END AS STATUS,
         H~*
    FROM ZGTMM_CV_SCSTOCKDAILYH( P_STARTDATE  = @LV_FDATE,
                                 P_ENDDATE    = @LV_TDATE,
                                 P_PERIODTYPE = @GC_D ) AS H
   WHERE BUKRS     = @P_BUKRS
*    AND ZDATE    IN @S_BUDAT
     AND SUPPLIER IN @S_LIFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST.

  IF GT_HLIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HLIST BY BUKRS ZDATE SUPPLIER.

*--> [CHM2601-00624] 삭제된 보증금액 반영
**** 삭제 = 아예 대상 X. 만료 = 해당 기간(DATAB~DATAI)만 금액 반영
  LOOP AT GT_HLIST.
    CLEAR : LV_PREIS, LV_PREIS_EX.

    SELECT SUM( PREIS )
      INTO @LV_PREIS
      FROM ZMMT0860
     WHERE BUKRS = @GT_HLIST-BUKRS
       AND LIFNR = @GT_HLIST-SUPPLIER
       AND DATAB <= @GT_HLIST-ZDATE
       AND DATAI >= @GT_HLIST-ZDATE
       AND DEL_FLAG <> 'X' "--> 삭제 제외
       AND EXCHK <> 'X'. "--> 만료 제외

    SELECT SUM( PREIS )
      INTO @LV_PREIS_EX
      FROM ZMMT0860
     WHERE BUKRS = @GT_HLIST-BUKRS
       AND LIFNR = @GT_HLIST-SUPPLIER
       AND DATAB <= @GT_HLIST-ZDATE
       AND DATAI >= @GT_HLIST-ZDATE
       AND DEL_FLAG <> 'X' "--> 삭제 제외
       AND EXCHK = 'X'. "--> 만료는 포함

    LV_PREIS = LV_PREIS + LV_PREIS_EX.

    IF GT_HLIST-PREIS <> LV_PREIS.
      GT_HLIST-PREIS = LV_PREIS.
      MODIFY GT_HLIST TRANSPORTING PREIS.
    ENDIF.
  ENDLOOP.
*<-- [CHM2601-00624] 삭제된 보증금액 반영

  GV_CNT = LINES( GT_HLIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FDATE
*&      <-- LV_TDATE
*&---------------------------------------------------------------------*
FORM SET_CDATE CHANGING PV_FDATE
                        PV_TDATE.

  DATA : LV_FDATE(10),
         LV_TDATE(10).


  CLEAR : PV_FDATE, PV_TDATE, GV_BUDAT.

  PV_FDATE = VALUE #( S_BUDAT[ 1 ]-LOW  OPTIONAL ).
  PV_TDATE = VALUE #( S_BUDAT[ 1 ]-HIGH OPTIONAL ).

  IF PV_TDATE IS INITIAL.
    PV_TDATE = PV_FDATE.
  ENDIF.

  WRITE PV_FDATE TO LV_FDATE.
  WRITE PV_TDATE TO LV_TDATE.

  GV_BUDAT = LV_FDATE && ` ~ ` && LV_TDATE.

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
                    ROWS    = 3
                    COLUMNS = 1 ).

  "#1 Row
  GR_TCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 1
                                      COLUMN    = 1 ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 5 ).

  "#2 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 2
                                      COLUMN    = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 2
                            HEIGHT = 50 ).

  "#3 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW       = 3
                                      COLUMN    = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
                    I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEXCL
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EXCL TABLES PT_EXCL TYPE UI_FUNCTIONS
               USING PV_TYPE.

  "ALV 상/하단 Toolbar 동일하게 구현(송종면E 24.12.18)

  CLEAR : PT_EXCL[].

  CASE PV_TYPE.
    WHEN 'H' OR 'I'.
      PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

*   WHEN 'I'.
*     PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL  ) ).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO
                    PV_TYPE.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.
* PS_LAYO-STYLEFNAME = GC_STYLE.
* PS_LAYO-CTAB_FNAME = GC_COLOR.

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '업체 별 외주 재고 금액'(T02).
    WHEN 'I'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> GT_HLIST
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_DATA
               USING PV_TNAME.

  CLEAR : PT_FCAT[], GT_FCAT[].

  CASE PV_TNAME.
    WHEN 'GT_HLIST'.
      PERFORM SET_HLIST_FCAT TABLES PT_FCAT.
    WHEN 'GT_ILIST'.
      PERFORM SET_ILIST_FCAT TABLES PT_FCAT.
  ENDCASE.

  PT_FCAT[] = GT_FCAT[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
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
*& Form SET_HLIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&---------------------------------------------------------------------*
FORM SET_HLIST_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          ' ' 'JUST'       'C',
          'E' 'COLTEXT'    '상태'(F01),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F02),

          'S' 'FIELDNAME'  'ZDATE',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '전기일'(F03),

          'S' 'FIELDNAME'  'SUPPLIER',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'REF_FIELD'  'LIFNR',
          ' ' 'REF_TABLE'  'LFA1',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체'(F04),

          'S' 'FIELDNAME'  'BPNAME',
          ' ' 'OUTPUTLEN'  30,
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F05),

          'S' 'FIELDNAME'  'PREIS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '보증보험금액'(F06),

          'S' 'FIELDNAME'  'TSTOCKVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '외주재고액'(F07),

          'S' 'FIELDNAME'  'REMAINVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '한도금액'(F08),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F09).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ILIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&---------------------------------------------------------------------*
FORM SET_ILIST_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F02),

          'S' 'FIELDNAME'  'COMPANYCODENAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사명'(F10),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F11),

          'S' 'FIELDNAME'  'PLANTNAME',
          ' ' 'OUTPUTLEN'  25,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트명'(F12),

          'S' 'FIELDNAME'  'SUPPLIER',
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'LIFNR',
*         ' ' 'REF_TABLE'  'LFA1',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체'(F04),

          'S' 'FIELDNAME'  'BPNAME',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F05),

          'S' 'FIELDNAME'  'PERIOD',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '기간(YYYYMM)'(F13),

          'S' 'FIELDNAME'  'ZDATE',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '전기일'(F03),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재'(F14),

          'S' 'FIELDNAME'  'MATERIALNAME',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재명'(F15),

          'S' 'FIELDNAME'  'BATCH',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '배치'(F16),

          'S' 'FIELDNAME'  'STPRS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '단가(표준/이동)'(F17),

          'S' 'FIELDNAME'  'PEINH',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '가격단위'(F18),

          'S' 'FIELDNAME'  'STOCKQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '재고수량'(F19),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F20),

          'S' 'FIELDNAME'  'TSTOCKVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
*         ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '외주재고액'(F07),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F09),

          'S' 'FIELDNAME'  'STPRSBASE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '수량*단가'(F21),

          'S' 'FIELDNAME'  'EKGRP',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매그룹'(F22),

          'S' 'FIELDNAME'  'EKNAM',
          ' ' 'OUTPUTLEN'  18,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매그룹명'(F23),

          'S' 'FIELDNAME'  'DISPO',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'MRP관리자'(F24),

          'S' 'FIELDNAME'  'DSNAM',
          ' ' 'OUTPUTLEN'  18,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'MRP관리자명'(F25),

          'S' 'FIELDNAME'  'MATKL',
          ' ' 'OUTPUTLEN'  9,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '자재그룹'(F26).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.


  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      SET HANDLER GR_EVENTS->HANDLE_TOP_OF_PAGE   FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

    WHEN 'GR_IGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEXCL
*&      --> GT_HFCAT
*&      --> GT_HLIST
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_EXCL TYPE UI_FUNCTIONS
                     PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO
                     PV_TYPE.

  CLEAR : GS_VARI.
  CASE PV_TYPE.
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.

  ENDCASE.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = 'A'
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = PT_EXCL[]
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

  CHECK PV_TYPE = GC_H.
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
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GS_HLAYO
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
      CALL METHOD GR_HGRID->FREE.
      CALL METHOD GR_IGRID->FREE.
      CALL METHOD GR_TCNTR->FREE.
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_DOCK,
              GR_TCNTR, GR_HCNTR, GR_ICNTR.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

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

  DATA : LR_TAB   TYPE REF TO CL_DD_TABLE_ELEMENT,
         LR_LAREA TYPE REF TO CL_DD_AREA,
         LR_CAREA TYPE REF TO CL_DD_AREA,
         LR_RAREA TYPE REF TO CL_DD_AREA.


  PR_DOCU->ADD_TABLE( EXPORTING NO_OF_COLUMNS = 3
                                WITH_HEADING  = ' '
                                BORDER        = '0'
                                WIDTH         = '100%'
                      IMPORTING TABLE         = LR_TAB ).

  PERFORM ADD_COLUMN USING : LR_TAB LR_LAREA '7%'  1 'LEFT',
                             LR_TAB LR_CAREA '1%'  2 'CENTER',
                             LR_TAB LR_RAREA '92%' 3 'LEFT'.

  PERFORM ADD_TEXT USING : LR_LAREA TEXT-T01 ' ' ' ' 'SMALL' 'STRONG',
                           LR_CAREA ':'      ' ' ' ' 'SMALL' 'STRONG',
                           LR_RAREA GV_BUDAT ' ' ' ' 'SMALL' ' '.

  PR_DOCU->MERGE_DOCUMENT( ).

  PR_DOCU->DISPLAY_DOCUMENT( REUSE_CONTROL = 'X'
                             PARENT        = GR_TCNTR ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_COLUMN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_TAB
*&      --> LR_LAREA
*&      --> P_
*&      --> P_1
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_COLUMN USING PR_TAB  TYPE REF TO CL_DD_TABLE_ELEMENT
                      PR_AREA TYPE REF TO CL_DD_AREA
                      PV_WIDTH
                      PV_COL_NO
                      PV_ALIGN.

  PR_TAB->ADD_COLUMN( EXPORTING WIDTH  = PV_WIDTH
*                               BG_COLOR
*                               HEADING
                      IMPORTING COLUMN = PR_AREA ).

  PR_TAB->SET_COLUMN_STYLE( EXPORTING COL_NO    = PV_COL_NO
*                                     SAP_STYLE
*                                     SAP_COLOR
*                                     SAP_FONTSIZE
*                                     SAP_FONTSTYLE
*                                     SAP_EMPHASIS
                                      SAP_ALIGN = PV_ALIGN
*                                     SAP_VALIGN
*                                     SAP_SYMBOL
                          ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_LAREA
*&      --> TEXT_T01
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_TEXT USING PR_AREA TYPE REF TO CL_DD_AREA
                    PV_TEXT
                    PV_STYLE
                    PV_COLOR
                    PV_FONT
                    PV_EMPHA.

  PR_AREA->ADD_TEXT( TEXT         = CONV SDYDO_TEXT_ELEMENT( PV_TEXT )
                     SAP_STYLE    = PV_STYLE    "CL_DD_AREA=>STRONG
                     SAP_COLOR    = PV_COLOR    "CL_DD_AREA=>LIST_HEADING_INT
                     SAP_FONTSIZE = PV_FONT     "CL_DD_AREA=>LARGE
                     SAP_EMPHASIS = PV_EMPHA ). "CL_DD_AREA=>HEADING

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_ROW  TYPE LVC_S_ROW
                                PS_COL  TYPE LVC_S_COL
                                PS_ROID TYPE LVC_S_ROID
                                PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      READ TABLE GT_HLIST INDEX PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'TSTOCKVAL'.
          PERFORM GET_ITEM_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITEM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ITEM_DATA.

  CLEAR : GT_ILIST[], GV_CNT.

  SELECT I~*
    FROM ZGTMM_CV_SCSTOCKLIST2( P_STARTDATE  = @GT_HLIST-ZDATE,
                                P_ENDDATE    = @GT_HLIST-ZDATE,
                                P_PERIODTYPE = @GC_D ) AS I
   WHERE BUKRS    = @GT_HLIST-BUKRS
*    AND ZDATE    = @GT_HLIST-ZDATE
     AND SUPPLIER = @GT_HLIST-SUPPLIER
    INTO CORRESPONDING FIELDS OF TABLE @GT_ILIST.

  IF GT_ILIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_ILIST BY WERKS MATNR BATCH.

  GV_CNT = LINES( GT_ILIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
