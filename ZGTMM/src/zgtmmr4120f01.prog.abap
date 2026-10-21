*&---------------------------------------------------------------------*
*& Include          ZGTMMR4120F01
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
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN P_PST.
        IF SCREEN-GROUP1+0(1) = GC_P.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_HIS.

      WHEN P_PRD.
        IF SCREEN-GROUP1 = GC_PXX.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
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

  PERFORM CHECK_NULL USING P_BUKRS 'P_BUKRS' '회사코드'(F01).
  PERFORM CHECK_BUKRS.

  CASE 'X'.
    WHEN P_PST.


    WHEN P_HIS.
      PERFORM CHECK_NULL USING S_BUDAT-LOW 'S_BUDAT-LOW' '조회기간'(S03).
      PERFORM CHECK_WERKS.

    WHEN P_PRD.
      PERFORM CHECK_NULL USING S_BUDAT-LOW 'S_BUDAT-LOW' '조회기간'(S03).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NULL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_NULL USING P_VAL
                      P_FNM
                      P_TXT.

  "필수 입력 필드 Check

  CHECK P_VAL IS INITIAL.

  SET CURSOR FIELD P_FNM.
  MESSAGE E015 WITH P_TXT. "&를(을) 입력하세요.

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

  "입력값 유효성 Check

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001
    INTO @DATA(L_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK L_BUKRS IS INITIAL.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E016 WITH '회사코드'(F01). "&를(을) 확인하세요.

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


  "입력값 유효성 Check
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
  MESSAGE E016 WITH '플랜트'(F10). "&를(을) 확인하세요.

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

  CLEAR : GT_HLIST[], GV_CNT.

  CASE 'X'.
    WHEN P_PST.
      PERFORM GET_PST_DATA.

    WHEN P_HIS.
      PERFORM GET_HIS_DATA.

    WHEN P_PRD.
      PERFORM GET_PRD_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PST_DATA.

  SELECT H~*
    FROM ZGTMM_CV_SCSTOCKHEADER AS H
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST
   WHERE BUKRS  = @P_BUKRS
     AND LIFNR IN @S_LIFNR.

  IF GT_HLIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HLIST BY BUKRS LIFNR.

  GV_CNT = LINES( GT_HLIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HIS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HIS_DATA.

  SUBMIT ZGTMMR4121 WITH P_BUKRS  = P_BUKRS
                    WITH S_WERKS IN S_WERKS
                    WITH S_LIFNR IN S_LIFNR
                    WITH S_BUDAT IN S_BUDAT
                    AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PRD_DATA.

  SUBMIT ZGTMMR4122 WITH P_BUKRS  = P_BUKRS
                    WITH S_LIFNR IN S_LIFNR
                    WITH S_BUDAT IN S_BUDAT
                    AND RETURN.

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
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 1
                                      COLUMN    = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

* GR_SPLIT->SET_COLUMN_WIDTH( ID    = 1
*                             WIDTH = 60 ).

  "#2 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW       = 2
                                      COLUMN    = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
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
  PS_LAYO-SMALLTITLE = GC_X.
* PS_LAYO-STYLEFNAME = GC_STYLE.
* PS_LAYO-CTAB_FNAME = GC_COLOR.

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '업체 한도액 현황'(T01).
    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '업체 외주 재고 현황'(T02).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
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
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'BUTXT',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사명'(F02),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'REF_FIELD'  'LIFNR',
          ' ' 'REF_TABLE'  'LFA1',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체'(F03),

          'S' 'FIELDNAME'  'VENDORNAME',
          ' ' 'OUTPUTLEN'  20,
*         ' ' 'F4AVAILABL' 'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F04),

          'S' 'FIELDNAME'  'PREIS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '보증보험금액'(F05),

          'S' 'FIELDNAME'  'TOTALSCVALUE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '외주재고액'(F06),

          'S' 'FIELDNAME'  'LIMITVALUE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '한도금액'(F07),

          'S' 'FIELDNAME'  'APVALUE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '당월외상매입금액'(F08),

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
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'BUTXT',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사명'(F02),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'LIFNR',
*         ' ' 'REF_TABLE'  'LFA1',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체'(F03),

          'S' 'FIELDNAME'  'VENDORNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F04),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F10),

          'S' 'FIELDNAME'  'PLANTNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트명'(F11),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재'(F12),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재명'(F13),

          'S' 'FIELDNAME'  'CHARG',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '배치'(F14),

          'S' 'FIELDNAME'  'VPRSV',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '가격지시자'(F15),

          'S' 'FIELDNAME'  'VERPR',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '이동평균가'(F16),

          'S' 'FIELDNAME'  'STPRS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '표준가'(F17),

          'S' 'FIELDNAME'  'PEINH',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '가격단위'(F18),

          'S' 'FIELDNAME'  'LBLAB',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '재고수량'(F19),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F20),

          'S' 'FIELDNAME'  'TOTALSCVALUE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
*         ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '외주재고액'(F06),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F09).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
*FORM SET_FTXT USING PV_TEXT.
*
*  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
*= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HLST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM SET_HLST_FCAT.
*
*  CASE GS_FCAT-FIELDNAME.
*    WHEN 'LIFNR'.
*      PERFORM SET_FTXT USING '업체'(F01).
*    WHEN 'VENDORNAME'.
*      PERFORM SET_FTXT USING '업체명'(F02).
*    WHEN 'PREIS'.
*      PERFORM SET_FTXT USING '보증보험금액'(F03).
*    WHEN 'TOTALSCVALUE'.
*      PERFORM SET_FTXT USING '외주재고액'(F04).
*      GS_FCAT-HOTSPOT = GC_X.
*    WHEN 'LIMITVALUE'.
*      PERFORM SET_FTXT USING '한도금액'(F05).
*    WHEN 'APVALUE'.
*      PERFORM SET_FTXT USING '당월외상매입금액'(F06).
*    WHEN 'WAERS'.
*      PERFORM SET_FTXT USING '통화'(F07).
*
*    WHEN OTHERS.
*      GS_FCAT-NO_OUT = GC_X.
*      GS_FCAT-TECH   = GC_X.
*  ENDCASE.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ILST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM SET_ILST_FCAT.
*
*  CASE GS_FCAT-FIELDNAME.
*    WHEN 'WERKS'.
*      PERFORM SET_FTXT USING '플랜트'(F08).
*    WHEN 'PLANTNAME'.
*      PERFORM SET_FTXT USING '플랜트명'(F09).
*    WHEN 'MATNR'.
*      PERFORM SET_FTXT USING '자재'(F10).
*    WHEN 'MAKTX'.
*      PERFORM SET_FTXT USING '자재명'(F11).
*    WHEN 'CHARG'.
*      PERFORM SET_FTXT USING '배치'(F12).
*    WHEN 'VPRSV'.
*      PERFORM SET_FTXT USING '가격지시자'(F13).
*    WHEN 'VERPR'.
*      PERFORM SET_FTXT USING '이동평균가'(F14).
*    WHEN 'STPRS'.
*      PERFORM SET_FTXT USING '표준가'(F15).
*    WHEN 'PEINH'.
*      PERFORM SET_FTXT USING '가격단위'(F16).
*    WHEN 'LBLAB'.
*      PERFORM SET_FTXT USING '재고수량'(F17).
*    WHEN 'MEINS'.
*      PERFORM SET_FTXT USING '단위'(F18).
*    WHEN 'TOTALSCVALUE'.
*      PERFORM SET_FTXT USING '외주재고액'(F04).
*    WHEN 'WAERS'.
*      PERFORM SET_FTXT USING '통화'(F07).
*
*    WHEN OTHERS.
*      GS_FCAT-NO_OUT = GC_X.
*      GS_FCAT-TECH   = GC_X.
*  ENDCASE.
*
*ENDFORM.
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
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_HCNTR, GR_ICNTR, GR_DOCK.

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
        WHEN 'TOTALSCVALUE'.
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
    FROM ZGTMM_CV_SCSTOCKITEM_SUM AS I
    INTO CORRESPONDING FIELDS OF TABLE @GT_ILIST
   WHERE BUKRS = @GT_HLIST-BUKRS
     AND LIFNR = @GT_HLIST-LIFNR.

  IF GT_ILIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_ILIST BY BUKRS LIFNR WERKS MATNR CHARG.

  GV_CNT = LINES( GT_ILIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
