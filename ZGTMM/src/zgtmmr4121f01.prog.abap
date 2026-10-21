*&---------------------------------------------------------------------*
*& Include          ZGTMMR4121F01
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
    FROM T001
    INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK LV_BUKRS IS INITIAL.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E016 WITH '회사코드'(F03). "&를(을) 확인하세요.

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

  RANGES : LR_IWERKS FOR T001W-WERKS,
           LR_CWERKS FOR T001W-WERKS.


  "회사코드-플랜트간 종속성 Check

  CHECK P_BUKRS   IS NOT INITIAL
    AND S_WERKS[] IS NOT INITIAL.

  SELECT @GC_I   AS SIGN,
         @GC_EQ  AS OPTION,
         W~WERKS AS LOW
    FROM T001W AS W
    INTO CORRESPONDING FIELDS OF TABLE @LR_IWERKS
   WHERE W~WERKS IN @S_WERKS.

  IF LR_IWERKS[] IS INITIAL.
    DATA(LV_ERR) = GC_X.
  ELSE.
    SELECT @GC_I   AS SIGN,
           @GC_EQ  AS OPTION,
           W~WERKS AS LOW
      FROM T001K AS K INNER JOIN T001W AS W
        ON K~BWKEY = W~BWKEY
      INTO CORRESPONDING FIELDS OF TABLE @LR_CWERKS
     WHERE K~BUKRS = @P_BUKRS.

    LOOP AT LR_IWERKS.
      CHECK LR_IWERKS-LOW NOT IN LR_CWERKS.
      LV_ERR = GC_X.
      EXIT.
    ENDLOOP.
  ENDIF.

  CHECK LV_ERR = GC_X.

  SET CURSOR FIELD 'S_WERKS-LOW'.
  MESSAGE E016 WITH '플랜트'(F04). "&를(을) 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS USING PV_FNME.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'T001W'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           PV_FNME.

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
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GT_HLIST[], GT_ILIST[], GV_CNT.

  SELECT *
    FROM ZGTMM_CV_SCAPPLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST
   WHERE BUKRS  = @P_BUKRS
     AND WERKS IN @S_WERKS
     AND LIFNR IN @S_LIFNR
     AND BUDAT IN @S_BUDAT.

  IF GT_HLIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HLIST BY ZGUID.

  GV_CNT = LINES( GT_HLIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

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
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  "#3 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2
                                      COLUMN = 1 ).

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

  "ALV 상/하단 Toolbar 동일하게 구현(송종면E 25.01.03)

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

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-SMALLTITLE = GC_X.
      PS_LAYO-GRID_TITLE = '출고리스트'(T01).

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
          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'GUID'(F01),

          'S' 'FIELDNAME'  'ZGITYPE',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '초과불출유형'(F02),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F03),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
*         ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치'(F05),

          'S' 'FIELDNAME'  'LGOBE',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치명'(F06),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '외주업체'(F07),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F08),

          'S' 'FIELDNAME'  'PREIS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '보증금액'(F09),

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고액'(F10),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
*         ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '출고처리액'(F11),

          'S' 'FIELDNAME'  'REVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출고가용액'(F12),

          'S' 'FIELDNAME'  'IVVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'NO_OUT'     'X',
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '당월IV 금액'(F13),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F14),

          'S' 'FIELDNAME'  'ORES',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '초과사유'(F15),

          'S' 'FIELDNAME'  'OREST',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '초과사유명'(F16),

          'S' 'FIELDNAME'  'OETC',
          ' ' 'OUTPUTLEN'  100,
          'E' 'COLTEXT'    '비고'(F17),

          'S' 'FIELDNAME'  'APPSTAT',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인상태'(F18),

          'S' 'FIELDNAME'  'REJRES',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '반려사유'(F19),

          'S' 'FIELDNAME'  'REJREST',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '반려사유명'(F20),

          'S' 'FIELDNAME'  'RETC',
          ' ' 'OUTPUTLEN'  100,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '비고(반려)'(F21),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '연도'(F22),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'MBLNR',
*         ' ' 'REF_TABLE'  'MATDOC',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '자재문서번호'(F23),

          'S' 'FIELDNAME'  'IV_NO',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '통문번호'(F24),

          'S' 'FIELDNAME'  'ERDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '상신일'(F25),

          'S' 'FIELDNAME'  'ERDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '상신일(LOCAL)'(F26),

          'S' 'FIELDNAME'  'ERTIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '상신시간'(F27),

          'S' 'FIELDNAME'  'ERTIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '상신시간(LOCAL)'(F28),

          'S' 'FIELDNAME'  'ERNAM',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '품의자'(F29),

          'S' 'FIELDNAME'  'REQNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '품의자명'(F30),

          'S' 'FIELDNAME'  'AEDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인일'(F31),

          'S' 'FIELDNAME'  'AEDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '승인일(LOCAL)'(F32),

          'S' 'FIELDNAME'  'AETIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인시간'(F33),

          'S' 'FIELDNAME'  'AETIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인시간(LOCAL)'(F34),

          'S' 'FIELDNAME'  'AENAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '승인자'(F35),

          'S' 'FIELDNAME'  'APPNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인자명'(F36),

          'S' 'FIELDNAME'  'APPROVER1',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인자1'(F37),

          'S' 'FIELDNAME'  'APPROVER2',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인자2'(F38),

          'S' 'FIELDNAME'  'BLDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '전기일'(F39),

          'S' 'FIELDNAME'  'BUDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '증빙일'(F40),

          'S' 'FIELDNAME'  'CPUDT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '입력일'(F41),

          'S' 'FIELDNAME'  'USNAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '입력자'(F42).

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
          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'GUID'(F01),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재코드'(F43),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재명'(F44),

          'S' 'FIELDNAME'  'XCHPF',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
*         ' ' 'KEY'        'X',
          ' ' 'CHECKBOX'   'X',
          'E' 'COLTEXT'    '배치관리여부'(F45),

          'S' 'FIELDNAME'  'REQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '총소요량'(F46),

          'S' 'FIELDNAME'  'SCQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '외주재고량'(F47),

          'S' 'FIELDNAME'  'NEQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '필요량'(F48),

          'S' 'FIELDNAME'  'SLQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '창고재고량'(F49),

          'S' 'FIELDNAME'  'ISQTY',
          ' ' 'OUTPUTLEN'  21,
*         ' ' 'REF_FIELD'  'MENGE',
*         ' ' 'REF_TABLE'  'MSEG',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '출하지시량'(F50),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F51),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출하지시금액'(F52), "'출고처리액'(F11)

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고금액'(F53), "'외주재고액'(F10)

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F14).

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
      I_SAVE               = GC_A
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
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID,
              GR_HCNTR, GR_ICNTR, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

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
        WHEN 'MBLNR'.
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

  SELECT * FROM ZGTMM_CV_SCAPPDETAIL
    INTO CORRESPONDING FIELDS OF TABLE @GT_ILIST
   WHERE ZGUID = @GT_HLIST-ZGUID.

  IF GT_ILIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_ILIST BY MATNR.

  GV_CNT = LINES( GT_ILIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_IGRID
*&      --> GS_ILAYO
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
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_DATA .

  DATA : LV_PREIS LIKE ZMMT0860-PREIS.
  DATA : LV_PREIS_EX LIKE ZMMT0860-PREIS.
  DATA : LV_DATLO(8).
  CONCATENATE SY-DATLO+0(4) '0101' INTO LV_DATLO. " 당년 기준
  DATA : LV_ISVAL TYPE ZGTMM_CV_SCAPPLIST-ISVAL. " 출고액
  DATA : LV_CNT TYPE I.
  DATA : LV_PER TYPE P DECIMALS 2.
  DATA : LV_ERR(1).

  DATA : BEGIN OF LS_MSLB,
           ZGUID LIKE ZGTMMT4111-ZGUID,
           MATNR LIKE MSLB-MATNR,
           WERKS LIKE MSLB-WERKS,
           CHARG LIKE MSLB-CHARG,
           SOBKZ LIKE MSLB-SOBKZ,
           LIFNR LIKE MSLB-LIFNR,
           LBLAB LIKE MSLB-LBLAB,
         END OF LS_MSLB.
  DATA : LT_MSLB LIKE TABLE OF LS_MSLB.

  CLEAR : GT_HLIST_CUR, GT_HLIST_CUR[].
  CLEAR : GT_HLIST_HIS, GT_HLIST_HIS[].
  CLEAR : GT_HLIST_TEMP, GT_HLIST_TEMP[].

  "--> 1. 현 시점 정보
  SELECT CASE WHEN REMAINVAL > 0 THEN @ICON_LED_GREEN
              WHEN REMAINVAL < 0 THEN @ICON_LED_RED
                                 ELSE @ICON_LED_YELLOW
          END AS STATUS,
         H~*
    FROM ZGTMM_CV_SCSTOCKDAILYH( P_STARTDATE  = @SY-DATLO,
                                 P_ENDDATE    = @SY-DATLO,
                                 P_PERIODTYPE = @GC_D ) AS H
   WHERE BUKRS    = @P_BUKRS
     AND REMAINVAL < 0
*     AND SUPPLIER = '0000108209' "* TEST
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST_CUR.

  CHECK GT_HLIST_CUR[] IS NOT INITIAL.
  SORT GT_HLIST_CUR BY BUKRS ZDATE SUPPLIER.

  "--> 삭제/만료 보증금액 반영
  LOOP AT GT_HLIST_CUR.
    CLEAR : LV_PREIS, LV_PREIS_EX.

    SELECT SUM( PREIS )
      INTO @LV_PREIS
      FROM ZMMT0860
     WHERE BUKRS = @GT_HLIST_CUR-BUKRS
       AND LIFNR = @GT_HLIST_CUR-SUPPLIER
       AND DATAB <= @GT_HLIST_CUR-ZDATE
       AND DATAI >= @GT_HLIST_CUR-ZDATE
       AND DEL_FLAG <> 'X' "--> 삭제 제외
       AND EXCHK <> 'X'. "--> 만료 제외

    SELECT SUM( PREIS )
      INTO @LV_PREIS_EX
      FROM ZMMT0860
     WHERE BUKRS = @GT_HLIST_CUR-BUKRS
       AND LIFNR = @GT_HLIST_CUR-SUPPLIER
       AND DATAB <= @GT_HLIST_CUR-ZDATE
       AND DATAI >= @GT_HLIST_CUR-ZDATE
       AND DEL_FLAG <> 'X' "--> 삭제 제외
       AND EXCHK = 'X'. "--> 만료는 포함

    LV_PREIS = LV_PREIS + LV_PREIS_EX.

    IF GT_HLIST_CUR-PREIS <> LV_PREIS.
      GT_HLIST_CUR-PREIS = LV_PREIS.
    ENDIF.

    "--> 담보초과비율 (무조건 KRW)
    LV_PER = ( GT_HLIST_CUR-REMAINVAL * 100 ) / ( GT_HLIST_CUR-PREIS * 100 ) * 100.
    "--> 반올림
    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = ' '
        I_RUNIT     = 1
        I_VALUE     = LV_PER
      IMPORTING
        E_VALUE_RND = LV_PER.

    GT_HLIST_CUR-PERCT = LV_PER.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        INPUT  = GT_HLIST_CUR-SUPPLIER
*      IMPORTING
*        OUTPUT = GT_HLIST_CUR-SUPPLIER.

*    MODIFY GT_HLIST_CUR TRANSPORTING PREIS PERCT SUPPLIER PREIS.
    MODIFY GT_HLIST_CUR TRANSPORTING PREIS PERCT PREIS.
  ENDLOOP.

  CHECK GT_HLIST_CUR[] IS NOT INITIAL.

  "--> 2. 이력 정보
*  LV_DATLO = '20250101'. " TEST
  SELECT *
    FROM ZGTMM_CV_SCAPPLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST_TEMP
    FOR ALL ENTRIES IN @GT_HLIST_CUR
   WHERE BUKRS  = @P_BUKRS
     AND ZGITYPE IN ('A','E') "* 직납입고 제외 (초과불출만)
     AND APPSTAT = 'A' "* 승인내역만 대상
*     AND MBLNR <> ' ' "* 승인 후 출고 완료내역만. → 승인기준 주석처리 (이서준D)
     AND LIFNR = @GT_HLIST_CUR-SUPPLIER.
*     AND BUDAT >= @LV_DATLO.

  CHECK GT_HLIST_TEMP[] IS NOT INITIAL.

*  SORT GT_HLIST_TEMP BY BUKRS LIFNR WERKS LGORT ERNAM BUDAT.
  SORT GT_HLIST_TEMP BY ZGUID WERKS LIFNR.

  SELECT B~ZGUID,
         A~MATNR,
         A~WERKS,
         A~CHARG,
         A~SOBKZ,
         A~LIFNR,
         A~LBLAB
    FROM MSLB AS A
         INNER JOIN ZGTMMT4111 AS B
          ON A~MATNR = B~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_MSLB
     FOR ALL ENTRIES IN @GT_HLIST_TEMP
   WHERE A~WERKS = @GT_HLIST_TEMP-WERKS
     AND A~LIFNR = @GT_HLIST_TEMP-LIFNR
     AND A~SOBKZ = 'O'
     AND A~LBLAB > 0
     AND B~ZGUID = @GT_HLIST_TEMP-ZGUID.

  SORT LT_MSLB BY ZGUID WERKS LIFNR.

  CLEAR : GS_HLIST_TEMP.
  LOOP AT GT_HLIST_TEMP INTO GS_HLIST_TEMP.

    "--> 재고 있는 내역만 대상으로 함
    CLEAR : LS_MSLB.
    READ TABLE LT_MSLB INTO LS_MSLB WITH KEY ZGUID = GS_HLIST_TEMP-ZGUID
                                             WERKS = GS_HLIST_TEMP-WERKS
                                             LIFNR = GS_HLIST_TEMP-LIFNR
                                    BINARY SEARCH.
    IF SY-SUBRC = 0.
    ELSE.
      DELETE GT_HLIST_TEMP.
      CONTINUE.
    ENDIF.
    "<-- 재고 있는 내역만 대상으로 함

    SELECT SINGLE B~NAME_TEXT
      INTO GS_HLIST_TEMP-REQNAME
      FROM USR21 AS A
           INNER JOIN ADRP AS B
            ON A~PERSNUMBER = B~PERSNUMBER
     WHERE A~BNAME = GS_HLIST_TEMP-ERNAM.

    IF GS_HLIST_TEMP-REQNAME IS INITIAL.
      SELECT SINGLE B~NAME_LAST
        INTO GS_HLIST_TEMP-REQNAME
        FROM USR21 AS A
             INNER JOIN ADRP AS B
              ON A~PERSNUMBER = B~PERSNUMBER
       WHERE A~BNAME = GS_HLIST_TEMP-ERNAM.
    ENDIF.

    GS_HLIST_TEMP-KEY_FIELD
    = GS_HLIST_TEMP-LIFNR && GS_HLIST_TEMP-WERKS && GS_HLIST_TEMP-LGORT && GS_HLIST_TEMP-ERNAM.

*    MODIFY GT_HLIST_TEMP FROM GS_HLIST_TEMP TRANSPORTING KEY_FIELD LIFNR.
    MODIFY GT_HLIST_TEMP FROM GS_HLIST_TEMP TRANSPORTING KEY_FIELD REQNAME.
  ENDLOOP.

  SORT GT_HLIST_TEMP BY BUKRS LIFNR WERKS LGORT ERNAM BUDAT.

  CLEAR : GS_HLIST_TEMP.
  LOOP AT GT_HLIST_TEMP INTO GS_HLIST_TEMP.
    AT NEW KEY_FIELD.
      CLEAR : LV_ISVAL.
      LV_CNT = 0.
    ENDAT.

    MOVE-CORRESPONDING GS_HLIST_TEMP TO GT_HLIST_HIS.
    LV_ISVAL = LV_ISVAL + GS_HLIST_TEMP-ISVAL.
    LV_CNT = LV_CNT + 1.

    AT END OF KEY_FIELD.
      GT_HLIST_HIS-ISVAL = LV_ISVAL.
      GT_HLIST_HIS-COUNT = LV_CNT.
      APPEND GT_HLIST_HIS.
    ENDAT.
  ENDLOOP.

  "--> 3. 메일 발송
  LOOP AT GT_HLIST_CUR.
    "--> GT_HLIST_HIS 기준 메일 발송
    "*** GT_HLIST_HIS에 없으면 발송 X. 설마 그럴리는 없겠지만,,
    READ TABLE GT_HLIST_HIS WITH KEY BUKRS = GT_HLIST_CUR-BUKRS
                                     LIFNR = GT_HLIST_CUR-SUPPLIER.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    "--> 업체별 발송
    PERFORM SEND_MAIL USING GT_HLIST_CUR-SUPPLIER
                      CHANGING LV_ERR.
    IF LV_ERR IS NOT INITIAL.
      MESSAGE S001 DISPLAY LIKE 'E' WITH '이메일 발송 중 에러 발생하였습니다.'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL USING PV_SUPPLIER CHANGING PV_ERR.

  DATA: LV_FLAG,
        LV_TEXT1(255),
        LV_TEXT2(255),
        LV_TEXT3(255),
        LV_DATE(50),
        LV_YEAR(7),
        LV_MON(7),
        LV_SUBJECT(200),
        LV_ENAME        LIKE PA0001-ENAME,
        LV_ORGTX        LIKE T527X-ORGTX.

  DEFINE MAIL_MSG.
    APPEND &1 TO GT_MESSAGE.
  END-OF-DEFINITION.

  CLEAR  : GT_MESSAGE, GV_SUBJECT, LV_TEXT1.
  REFRESH: GT_MESSAGE.

  DATA : LV_PREIS(20).
  DATA : LV_PREIS_FIX(20).
  DATA : LV_TSTOCKVAL(20).
  DATA : LV_REMAINVAL(20).
  DATA : LV_PERCT(20).
  DATA : LV_SHKZG(1).
  DATA : LV_LIFNR LIKE LFA1-LIFNR.
  DATA : LV_ISVAL(20).
  DATA : LV_BUDAT(20).
  DATA : LV_ERNAM(20).

  "--> 메일 제목
  CONCATENATE '[' SY-DATLO ']'
              '보증금액 한도초과 사급자재불출 알림메일'
         INTO GV_SUBJECT SEPARATED BY SPACE.

  MAIL_MSG: '<HTML>',
            '<BODY>'.

  "--> 메일 본문 TEXT1
  CONCATENATE '<BR>'
              '<P STYLE = "COLOR : BLUE; FONT-SIZE: 14PX; FONT-WEIGHT: BOLD; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;"> 보증금액 한도를 초과하여 사급자재가 불출되었습니다.</P>'
         INTO LV_TEXT1 SEPARATED BY SPACE.
  APPEND LV_TEXT1 TO GT_MESSAGE.
  CLEAR : LV_TEXT1.

  CONCATENATE '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">즉시 사급자재 현황을 점검하시어 사급자재 금액이 보증금액 한도 내에서 운영될 수 있도록 조치 부탁드립니다.</P>'
              '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">(사급자재 회수, 보증금액 증액 등)</P>'
         INTO LV_TEXT1 SEPARATED BY SPACE.
  APPEND LV_TEXT1 TO GT_MESSAGE.
  CLEAR : LV_TEXT1.

  MAIL_MSG : '<BR>',
             '<BR>',
             '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">[초과불출내역]</P>'.
  "--> 메일 본문 TEXT2
  MAIL_MSG :    '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 13PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">',
                '<THEAD>',
                '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">업체코드</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">업체명</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">담보금액(원)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">사급자재불출금액(원)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">초과불출금액(원)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">담보초과비율(%)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">통화</TH>',
                '</TR>',
                '</THEAD>',
                '<TBODY>'.

  LOOP AT GT_HLIST_CUR WHERE SUPPLIER = PV_SUPPLIER.
    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    CLEAR : LV_LIFNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_HLIST_CUR-SUPPLIER
      IMPORTING
        OUTPUT = LV_LIFNR.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    LV_LIFNR '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    GT_HLIST_CUR-BPNAME '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

*    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*      EXPORTING
*        CURRENCY        = GT_HLIST_CUR-WAERS
*        AMOUNT_INTERNAL = GT_HLIST_CUR-PREIS
*      IMPORTING
*        AMOUNT_EXTERNAL = LV_PREIS_EXT.

    CLEAR : LV_PREIS.
    WRITE GT_HLIST_CUR-PREIS TO LV_PREIS CURRENCY GT_HLIST_CUR-WAERS.
    CONDENSE LV_PREIS NO-GAPS.
    LV_PREIS_FIX = LV_PREIS. "* 사급자재 불출내역표에서 활용
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    LV_PREIS '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

    CLEAR : LV_TSTOCKVAL.
    WRITE GT_HLIST_CUR-TSTOCKVAL TO LV_TSTOCKVAL CURRENCY GT_HLIST_CUR-WAERS.
    CONDENSE LV_TSTOCKVAL NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    LV_TSTOCKVAL '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

*    CLEAR : LV_SHKZG.
*    IF GT_HLIST_CUR-REMAINVAL > 0.
*      LV_SHKZG = '+'.
*    ELSE.
*      LV_SHKZG = '-'.
*    ENDIF.

    CLEAR : LV_REMAINVAL.
    GT_HLIST_CUR-REMAINVAL = ABS( GT_HLIST_CUR-REMAINVAL ).
    WRITE GT_HLIST_CUR-REMAINVAL TO LV_REMAINVAL CURRENCY GT_HLIST_CUR-WAERS.
    CONDENSE LV_REMAINVAL NO-GAPS.
    CONCATENATE
*    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT; COLOR: #FF0000; BACKGROUND-COLOR: YELLOW; FONT-WEIGHT: BOLD;">'
*    LV_SHKZG LV_REMAINVAL '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    LV_REMAINVAL '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

*    CLEAR : LV_SHKZG.
*    IF GT_HLIST_CUR-PERCT > 0.
*      LV_SHKZG = '+'.
*    ELSE.
*      LV_SHKZG = '-'.
*    ENDIF.

    CLEAR : LV_PERCT.
    LV_PERCT = ABS( GT_HLIST_CUR-PERCT ).
    CONDENSE LV_PERCT NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER; COLOR: #FF0000; BACKGROUND-COLOR: YELLOW; FONT-WEIGHT: BOLD;">'
*    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER; COLOR: #FF0000; BACKGROUND-COLOR: ##FFFF00;">'
*    LV_SHKZG LV_PERCT '%' '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    LV_PERCT '%' '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
*    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER; COLOR: #FF0000; BACKGROUND-COLOR: ##FFFF00;">'
    GT_HLIST_CUR-WAERS '</TD>' INTO LV_TEXT2 SEPARATED BY SPACE.
    APPEND LV_TEXT2 TO GT_MESSAGE.
    CLEAR : LV_TEXT2.

    MAIL_MSG : '</TR>'.
  ENDLOOP.

  MAIL_MSG: '</TBODY>',
            '</TABLE>',
            '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">※ 담보초과비율(%) = 초과불출금액/담보금액</P>'.
*            '<BR>'.

  "--> 메일 본문 TEXT3
  CLEAR : LV_TEXT3.
  MAIL_MSG : '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">[사급자재 불출내역]</P>'.

  MAIL_MSG :    '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 13PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">',
                '<THEAD>',
                '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">업체코드</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">업체명</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">담보금액(원)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">사급자재불출금액(원)</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">최근불출일</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">담당자</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">플랜트</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">저장위치</TH>',
                '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">저장위치명</TH>',
                '</TR>',
                '</THEAD>',
                '<TBODY>'.

  LOOP AT GT_HLIST_HIS WHERE LIFNR = PV_SUPPLIER.
    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    CLEAR : LV_LIFNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_HLIST_HIS-LIFNR
      IMPORTING
        OUTPUT = LV_LIFNR.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    LV_LIFNR '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    GT_HLIST_HIS-NAME1 '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

*    CLEAR : LV_PREIS.
*    WRITE GT_HLIST_HIS-PREIS TO LV_PREIS CURRENCY GT_HLIST_HIS-WAERS.
*    CONDENSE LV_PREIS NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    LV_PREIS_FIX '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CLEAR : LV_ISVAL.
    WRITE GT_HLIST_HIS-ISVAL TO LV_ISVAL CURRENCY GT_HLIST_HIS-WAERS.
    CONDENSE LV_ISVAL NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    LV_ISVAL '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CLEAR : LV_BUDAT.
    "**** 없으면 공란
    CONCATENATE GT_HLIST_HIS-BUDAT+0(4) '.' GT_HLIST_HIS-BUDAT+4(2) '.' GT_HLIST_HIS-BUDAT+6(2) INTO LV_BUDAT.
    CONDENSE LV_BUDAT NO-GAPS.
    IF LV_BUDAT = '..'.
      CLEAR : LV_BUDAT.
    ENDIF.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    LV_BUDAT '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CLEAR : LV_ERNAM.
    CONCATENATE GT_HLIST_HIS-REQNAME '(' GT_HLIST_HIS-ERNAM ')' INTO LV_ERNAM.
    CONDENSE LV_ERNAM NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    LV_ERNAM '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CONCATENATE
*    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER; COLOR: #FF0000; BACKGROUND-COLOR: YELLOW;">'
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    GT_HLIST_HIS-WERKS '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    GT_HLIST_HIS-LGORT '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    GT_HLIST_HIS-LGOBE '</TD>' INTO LV_TEXT3 SEPARATED BY SPACE.
    APPEND LV_TEXT3 TO GT_MESSAGE.
    CLEAR : LV_TEXT3.

    MAIL_MSG : '</TR>'.
  ENDLOOP.

  MAIL_MSG: '</TBODY>',
            '</TABLE>'.

  MAIL_MSG : '<BR>',
             '<P STYLE = "FONT-SIZE: 14PX; FONT-FAMILY: 맑은 고딕, MALGUN GOTHIC;">※ Batch Job Program : ZGTMMR4121</P>'.

  MAIL_MSG: '</BODY>',
            '</HTML>'.


  PERFORM SEND_MAIL_MSG USING PV_SUPPLIER CHANGING PV_ERR.
  CLEAR : GT_RECV[], GT_MESSAGE[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_ERR
*&---------------------------------------------------------------------*
FORM SEND_MAIL_MSG  USING PV_SUPPLIER CHANGING PV_ERR.

  DATA: RESULT_TAB   TYPE MATCH_RESULT_TAB.

  CLEAR : PV_ERR.

  "--> 수신자
  PERFORM GET_RECEIVER_LIST USING PV_SUPPLIER.

  IF GT_RECV[] IS NOT INITIAL.
    TRY.
        G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

        G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                        I_TYPE    = 'HTM'
                        I_TEXT    = GT_MESSAGE
                        I_SUBJECT = GV_SUBJECT ).

        G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

        LOOP AT GT_RECV.
          G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                        I_ADDRESS_STRING = GT_RECV-SMTP_ADDR ).

          G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                  I_EXPRESS   = 'X' ).
        ENDLOOP.

        IF SY-SYSID = 'S4P'.
          G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).
        ELSE.
          G_EMAIL->SET_SEND_IMMEDIATELY( ' ' ).
*          G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).
        ENDIF.

        G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                       RECEIVING RESULT              = GV_SEND_RESULT ).

        COMMIT WORK AND WAIT.

      CATCH CX_BCS INTO G_EXCEPTION.
        PV_ERR = 'X'.
        CLEAR : GT_RECV[], GT_MESSAGE[].
        EXIT.
    ENDTRY.

    CLEAR : GT_RECV[], GT_MESSAGE[].
  ELSE.
    PV_ERR = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RECEIVER_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_RECEIVER_LIST USING PV_SUPPLIER.

  DATA : LV_ADDRNUMBER LIKE USR21-ADDRNUMBER,
         LV_PERSNUMBER LIKE USR21-PERSNUMBER,
         LV_PERSON     LIKE USR21-PERSNUMBER,
         LV_ZPFAC      LIKE ZMMT0862-ZPFAC.

  DATA : LV_BNAME1 LIKE USR21-BNAME.
  DATA : LV_BNAME2 LIKE USR21-BNAME.

  CLEAR : GT_RECV, GT_RECV[].

  "--> 1. 담당자 수신인 추가
  LOOP AT GT_HLIST_HIS WHERE LIFNR = PV_SUPPLIER.
    SELECT SINGLE A~BNAME B~SMTP_ADDR
      INTO (GT_RECV-BNAME, GT_RECV-SMTP_ADDR)
      FROM USR21 AS A
           INNER JOIN ADR6 AS B
            ON A~PERSNUMBER = B~PERSNUMBER
            AND A~ADDRNUMBER = B~ADDRNUMBER
     WHERE A~BNAME = GT_HLIST_HIS-ERNAM.
    IF SY-SUBRC = 0.
      APPEND GT_RECV.
    ENDIF.
  ENDLOOP.

  "--> 2. 승인자/대리승인자 수신인 추가
  LOOP AT GT_HLIST_HIS WHERE LIFNR = PV_SUPPLIER.
    CLEAR : LV_BNAME1, LV_BNAME2.
    SELECT SINGLE APPROVER1 APPROVER2
      INTO (LV_BNAME1, LV_BNAME2)
      FROM ZGTMMT4113
     WHERE BUKRS = GT_HLIST_HIS-BUKRS
       AND WERKS = GT_HLIST_HIS-WERKS
       AND LGORT = GT_HLIST_HIS-LGORT.

    "**** 승인자
    IF LV_BNAME1 IS NOT INITIAL.
      SELECT SINGLE A~BNAME B~SMTP_ADDR
        INTO (GT_RECV-BNAME, GT_RECV-SMTP_ADDR)
        FROM USR21 AS A
             INNER JOIN ADR6 AS B
              ON A~PERSNUMBER = B~PERSNUMBER
              AND A~ADDRNUMBER = B~ADDRNUMBER
       WHERE A~BNAME = LV_BNAME1.
      IF SY-SUBRC = 0.
        APPEND GT_RECV.
      ENDIF.
    ENDIF.

    "**** 대리승인자
    IF LV_BNAME2 IS NOT INITIAL.
      SELECT SINGLE A~BNAME B~SMTP_ADDR
        INTO (GT_RECV-BNAME, GT_RECV-SMTP_ADDR)
        FROM USR21 AS A
             INNER JOIN ADR6 AS B
              ON A~PERSNUMBER = B~PERSNUMBER
              AND A~ADDRNUMBER = B~ADDRNUMBER
       WHERE A~BNAME = LV_BNAME2.
      IF SY-SUBRC = 0.
        APPEND GT_RECV.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "--> TEST
*  CLEAR : GT_RECV.
*  GT_RECV-BNAME = 'ZLSGMM3'.
*  GT_RECV-SMTP_ADDR = 'jaewoon.lee@lsitc.com'.
*  APPEND GT_RECV.
*  DELETE GT_RECV WHERE BNAME <> 'ZLSGMM3'.
  "<-- TEST

  SORT GT_RECV BY BNAME.
  DELETE ADJACENT DUPLICATES FROM GT_RECV.

ENDFORM.
