*&---------------------------------------------------------------------*
*& Include          ZGTMMR4200F01
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

  S_AEDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = GV_CDATE
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
  PERFORM CHECK_EKORG.
  PERFORM CHECK_WERKS.

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
*    AND SPRAS = @SY-LANGU.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E016 WITH '회사코드'(F03). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_EKORG.

  CHECK P_EKORG IS NOT INITIAL.

  SELECT SINGLE EKORG
    FROM T024E INTO @DATA(LV_EKORG)
   WHERE EKORG = @P_EKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE E016 WITH '구매조직'(F05). "&를(을) 확인하세요.

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

  CHECK S_WERKS[] IS NOT INITIAL.

  SELECT WERKS FROM T001W
    INTO TABLE @DATA(LT_WERKS)
   WHERE WERKS IN @S_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'S_WERKS-LOW'.
  MESSAGE E016 WITH '플랜트'(F07). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_BUKRS
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING PV_FNAME
                   CHANGING PV_FVAL.

  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  CLEAR : LT_DYN[], PV_FVAL.
  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_FIELD USING PV_TNAME
                      PV_FNAME
                      PV_SHELP
                      PV_FIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = CONV TABNAME( PV_TNAME )
      FIELDNAME         = CONV FIELDNAME( PV_FNAME )
      SEARCHHELP        = CONV SHLPNAME( PV_SHELP )
*     SHLPPARAM         = ' '
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = CONV DYNFNAM( PV_FIELD )
*     STEPL             = 0
*     VALUE             = ' '
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
*     CALLBACK_METHOD   =
*     SELECTION_SCREEN  = ' '
*   IMPORTING
*     USER_RESET        =
    TABLES
      RETURN_TAB        = GT_RTAB
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS USING PV_FNAME.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'EKPO'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           PV_FNAME.

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

  SELECT *
    FROM ZGTMM_CV_LTTIMECHECK
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE BUKRS     = @P_BUKRS
     AND EKORG     = @P_EKORG
     AND WERKS    IN @S_WERKS
     AND LIFNR    IN @S_LIFNR
     AND MATNR    IN @S_MATNR
     AND PODATE_C IN @S_AEDAT.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST.
    CLEAR : GT_LIST-COLOR.

    PERFORM SET_COLOR USING 'INFO_LT' '7' '1' '0' GT_LIST-COLOR.

    PERFORM SET_DIFF USING GT_LIST-POLTCHECK     'POLTCHECK'     GT_LIST-COLOR.
    PERFORM SET_DIFF USING GT_LIST-FIRSTGR_CHECK 'FIRSTGR_CHECK' GT_LIST-COLOR.
    PERFORM SET_DIFF USING GT_LIST-LASTGR_CHECK  'LASTGR_CHECK'  GT_LIST-COLOR.

    MODIFY GT_LIST TRANSPORTING COLOR.
  ENDLOOP.

  SORT GT_LIST BY BUKRS EKORG WERKS MATNR LIFNR. "확인! PO가 아니구?

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GT_LIST_COLOR
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
*& Form SET_DIFF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_POLTCHECK
*&      --> P_
*&      --> GT_LIST_COLOR
*&---------------------------------------------------------------------*
FORM SET_DIFF USING PV_CHK
                    PV_FNM
                    PT_COL TYPE LVC_T_SCOL.

  CHECK PV_CHK = GC_DIFF.

  PERFORM SET_COLOR USING PV_FNM '6' '1' '0' PT_COL.

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
* GS_LAYO-STYLEFNAME = GC_STYLE.
  GS_LAYO-CTAB_FNAME = GC_COLOR.

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

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'EBELN',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'EBELN',
*         ' ' 'REF_TABLE'  'EKPO',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'PO번호'(F01),

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F02),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          'E' 'COLTEXT'    '회사코드'(F03),

          'S' 'FIELDNAME'  'BUKRS_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '회사명'(F04),

          'S' 'FIELDNAME'  'EKORG',
          ' ' 'OUTPUTLEN'  4,
          'E' 'COLTEXT'    '구매조직'(F05),

          'S' 'FIELDNAME'  'EKORG_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매조직명'(F06),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          'E' 'COLTEXT'    '플랜트'(F07),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트명'(F08),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '공급업체'(F09),

          'S' 'FIELDNAME'  'LIFNR_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '공급업체명'(F10),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'EKPO',
          'E' 'COLTEXT'    '자재코드'(F11),

          'S' 'FIELDNAME'  'TXZ01',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F12),

          'S' 'FIELDNAME'  'MENGE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '수량'(F13),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '단위'(F14),

          'S' 'FIELDNAME'  'BANFN',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'BANFN',
*         ' ' 'REF_TABLE'  'EKPO',
          'E' 'COLTEXT'    '구매요청'(F15),

          'S' 'FIELDNAME'  'BNFPO',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '항번'(F02),

          'S' 'FIELDNAME'  'PRDATE_C',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    'PR생성일'(F16),

          'S' 'FIELDNAME'  'PRDATE_R',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    'PR납품요청일'(F17),

          'S' 'FIELDNAME'  'PODATE_C',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    'PO생성일'(F18),

          'S' 'FIELDNAME'  'PODATE_R',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    'PO납품요청일'(F19),

          'S' 'FIELDNAME'  'INFO_LT',
          ' ' 'OUTPUTLEN'  3,
          'E' 'COLTEXT'    'Info L/T'(F20),

          'S' 'FIELDNAME'  'PRDATE_LT',
          ' ' 'OUTPUTLEN'  3,
          'E' 'COLTEXT'    'PR L/T'(F21),

          'S' 'FIELDNAME'  'PODATE_LT',
          ' ' 'OUTPUTLEN'  3,
          'E' 'COLTEXT'    'PO L/T'(F22),

          'S' 'FIELDNAME'  'POLTCHECK',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          'E' 'COLTEXT'    'PO L/T 점검'(F23),

          'S' 'FIELDNAME'  'GRDATE_F',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '최초입고일'(F24),

          'S' 'FIELDNAME'  'LT_F',
          ' ' 'OUTPUTLEN'  3,
          'E' 'COLTEXT'    '최초입고 L/T'(F25),

          'S' 'FIELDNAME'  'FIRSTGR_CHECK',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          'E' 'COLTEXT'    '최초입고 L/T 점검'(F26),

          'S' 'FIELDNAME'  'GRDATA_L',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '최종입고일'(F27),

          'S' 'FIELDNAME'  'LT_L',
          ' ' 'OUTPUTLEN'  3,
          'E' 'COLTEXT'    '최종입고 L/T'(F28),

          'S' 'FIELDNAME'  'LASTGR_CHECK',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          'E' 'COLTEXT'    '최종입고 L/T 점검'(F29).

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
