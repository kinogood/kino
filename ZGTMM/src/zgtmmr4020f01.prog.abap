*&---------------------------------------------------------------------*
*& Include          ZGTMMR4020F01
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

  CLEAR : S_LFDAT[].
  S_LFDAT[] = VALUE #( ( SIGN   = GC_I
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
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK LV_BUKRS IS INITIAL.

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

  "회사코드-플랜트간 종속성 체크

  CHECK P_BUKRS IS NOT INITIAL
    AND P_WERKS IS NOT INITIAL.

  SELECT SINGLE W~WERKS
    FROM T001K AS K INNER JOIN T001W AS W
      ON K~BWKEY = W~BWKEY
    INTO @DATA(LV_WERKS)
   WHERE K~BUKRS = @P_BUKRS
     AND W~WERKS = @P_WERKS.

  CHECK LV_WERKS IS INITIAL.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E016 WITH '플랜트'(F02). "&를(을) 확인하세요.

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

  "권한 체크 추가(SJM 25.02.17)

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_WERKS.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'LIPS'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           'P_WERKS'.

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

  RANGES : LR_MBLNR FOR MATDOC-MBLNR.


  CLEAR : GT_LIST[], GT_HLIST[], GT_ILIST[], GV_CNT.

  CASE 'X'.
    WHEN P_YGR.
      LR_MBLNR[] = VALUE #( ( SIGN = GC_E OPTION = GC_EQ LOW = ' ' ) ).
    WHEN P_NGR.
      LR_MBLNR[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = ' ' ) ).
  ENDCASE.

  SELECT CASE WHEN H~ISPSTAT = 'S' AND H~MBLNR <> ' ' THEN @ICON_LED_GREEN
              WHEN H~ISPSTAT = 'S' AND H~MBLNR  = ' ' THEN @ICON_LED_YELLOW
              WHEN H~ISPSTAT = 'E'                    THEN @ICON_LED_RED
          END AS STATUS,
         H~*, H~WAERS AS WAERS_H,
         I~*, I~WAERS AS WAERS_I
    FROM ZGTMM_CV_GETINBDIRECT_H AS H INNER JOIN ZGTMM_CV_GETINBDIRECT_I AS I
      ON H~VBELN = I~VBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
   WHERE H~BUKRS  = @P_BUKRS
     AND H~WERKS  = @P_WERKS
     AND H~LFDAT IN @S_LFDAT
     AND H~IPDAT IN @S_IPDAT
     AND H~VBELN IN @S_VBELN
     AND I~MATNR IN @S_MATNR
     AND H~LIFNR IN @S_LIFNR
     AND H~EMLIF IN @S_EMLIF
     AND H~MBLNR IN @LR_MBLNR.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY VBELN POSNR.

  GT_HLIST[] = CORRESPONDING #( GT_LIST[] ).

  SORT GT_HLIST BY VBELN.
  DELETE ADJACENT DUPLICATES FROM GT_HLIST COMPARING VBELN.

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

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '납품서 현황'(T01).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '납품 내역'(T02).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PV_TYPE.

  CLEAR : PT_FCAT[], GT_FCAT[].

  CASE PV_TYPE.
    WHEN 'H'.
      PERFORM SET_HLIST_FCAT.
    WHEN 'I'.
      PERFORM SET_ILIST_FCAT.
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
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HLIST_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F02),

          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '상태'(F03),

          'S' 'FIELDNAME'  'VBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          ' ' 'HOTSPOT'    'X',
          'E' 'COLTEXT'    '납품서번호'(F04),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '직납업체'(F05),

          'S' 'FIELDNAME'  'LIFNRN',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F06),

          'S' 'FIELDNAME'  'VBERDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '생성일'(F07),

          'S' 'FIELDNAME'  'LFDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '납품예정일'(F08),

          'S' 'FIELDNAME'  'EMLIF',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '검수업체'(F09),

          'S' 'FIELDNAME'  'EMLIFN',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F06),

          'S' 'FIELDNAME'  'IPDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '업체검수일'(F10),

          'S' 'FIELDNAME'  'ISPSTAT',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '검수결과 상태'(F11),

          'S' 'FIELDNAME'  'ISPSTATN',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '검수결과'(F12),

          'S' 'FIELDNAME'  'FCODE',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '오류사유 코드'(F13),

          'S' 'FIELDNAME'  'FCODEN',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '오류사유'(F14),

          'S' 'FIELDNAME'  'ZETC',
          ' ' 'OUTPUTLEN'  50,
          'E' 'COLTEXT'    '비고'(F15),

          'S' 'FIELDNAME'  'ZCLOSE',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    'CLOSE'(F16),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '연도'(F17),

          'S' 'FIELDNAME'  'BUDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '입고전기일'(F18),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'MBLNR',
*         ' ' 'REF_TABLE'  'MATDOC',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '입고자재문서'(F19),

          'S' 'FIELDNAME'  'INSMK', "추가(SJM 25.04.08)
          ' ' 'OUTPUTLEN'  6,
          'E' 'COLTEXT'    '품질검사대상'(F38),

          'S' 'FIELDNAME'  'STOCKVALSUM',
          ' ' 'OUTPUTLEN'  21,
*         ' ' 'NO_OUT'     'X',  "임시!
          ' ' 'CFIELDNAME' 'WAERS_H',
          'E' 'COLTEXT'    '재고평가총액'(F20),

          'S' 'FIELDNAME'  'WAERS_H',
          ' ' 'OUTPUTLEN'  5,
*         ' ' 'NO_OUT'     'X',  "임시!
          'E' 'COLTEXT'    '통화'(F21),

          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',  "변경(SJM 25.02.17)
          'E' 'COLTEXT'    'ZGUID'(F22),

          'S' 'FIELDNAME'  'ERDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성일'(F23),

          'S' 'FIELDNAME'  'ERDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성일(Local)'(F24),

          'S' 'FIELDNAME'  'ERTIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성시간'(F25),

          'S' 'FIELDNAME'  'ERTIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성시간(Local)'(F26),

          'S' 'FIELDNAME'  'ERNAM',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성자'(F27).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ILIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ILIST_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'VBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '납품서번호'(F04),

          'S' 'FIELDNAME'  'POSNR',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F28),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          'E' 'COLTEXT'    '자재코드'(F29),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F30),

          'S' 'FIELDNAME'  'LFIMG',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '납품수량'(F31),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F32),

          'S' 'FIELDNAME'  'CHARG',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '배치번호'(F33),

          'S' 'FIELDNAME'  'LICHN',
          ' ' 'OUTPUTLEN'  17,
          'E' 'COLTEXT'    '꼬리표번호'(F34),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치'(F35),

          'S' 'FIELDNAME'  'EBELN',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'EBELN',
*         ' ' 'REF_TABLE'  'EKPO',
          'E' 'COLTEXT'    'PO번호'(F36),

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '항번'(F28),

          'S' 'FIELDNAME'  'STOCKVALUE',
          ' ' 'OUTPUTLEN'  21,
*          ' ' 'NO_OUT'     'X', "임시!
          ' ' 'CFIELDNAME' 'WAERS_I',
          'E' 'COLTEXT'    '재고평가액'(F37),

          'S' 'FIELDNAME'  'WAERS_I',
          ' ' 'OUTPUTLEN'  5,
*          ' ' 'NO_OUT'     'X', "임시!
          'E' 'COLTEXT'    '통화'(F21).

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
*&      --> GT_HFCAT
*&      --> GT_HLIST
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
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
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
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

    WHEN '0200'.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REFR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REFR.

  PERFORM GET_DATA.

  GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

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
        WHEN 'VBELN'.
          PERFORM GET_ILIST_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

        WHEN 'MBLNR'.
          PERFORM CALL_MIGO USING GT_HLIST-MBLNR
                                  GT_HLIST-MJAHR.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILIST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILIST_DATA.

  CLEAR : GT_ILIST[], GV_CNT.

  GT_ILIST[] = CORRESPONDING #( GT_LIST[] ).
  DELETE GT_ILIST WHERE VBELN <> GT_HLIST-VBELN.

  IF GT_ILIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_ILIST BY VBELN POSNR.

  GV_CNT = LINES( GT_ILIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MIGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HLIST_MBLNR
*&      --> GT_HLIST_MJAHR
*&---------------------------------------------------------------------*
FORM CALL_MIGO USING PV_MBLNR
                     PV_MJAHR.

  CHECK PV_MBLNR IS NOT INITIAL.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
*     I_ACTION            = 'A04'
*     I_REFDOC            = 'R02'
*     I_NOTREE            = 'X'
*     I_NO_AUTH_CHECK     =
*     I_SKIP_FIRST_SCREEN = 'X'
*     I_DEADEND           = 'X'
*     I_OKCODE            = 'OK_GO'
*     I_LEAVE_AFTER_POST  =
*     I_NEW_ROLLAREA      = 'X'
*     I_SYTCODE           =
*     I_EBELN             =
*     I_EBELP             =
      I_MBLNR             = PV_MBLNR
      I_MJAHR             = PV_MJAHR
*     I_ZEILE             =
*     I_TRANSPORT         =
*     I_ORDER_NUMBER      =
*     I_ORDER_ITEM        =
*     I_TRANSPORT_MEANS   =
*     I_TRANSPORTIDENT    =
*     I_INBOUND_DELIV     =
*     I_OUTBOUND_DELIV    =
*     I_RESERVATION_NUMB  =
*     I_RESERVATION_ITEM  =
*     EXT                 =
*     I_MOVE_TYPE         =
*     I_SPEC_STOCK        =
*     I_PSTNG_DATE        =
*     I_DOC_DATE          =
*     I_REF_DOC_NO        =
*     I_HEADER_TXT        =
    EXCEPTIONS
      ILLEGAL_COMBINATION = 1
      OTHERS              = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
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
          MESSAGE S004 DISPLAY LIKE 'E'. "라인을 선택하세요.
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
*& Form PRCS_PCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_PCGR.

  CLEAR : GV_ERR, GV_PRXX, GS_PRXX.

  PERFORM CHECK_PCGR.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_PGR.

  GS_PRXX-TXT01 = '입고 처리 하시겠습니까?'(P01).
  GS_PRXX-BUDAT = SY-DATLO.

  CALL SCREEN 200 STARTING AT 10 5
                    ENDING AT 60 7.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PCGR.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '처리할 대상을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HLIST INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  IF GT_HLIST-STATUS <> ICON_LED_YELLOW.
    MESSAGE S045 DISPLAY LIKE 'E'. "입고 처리할 수 없는 정보입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YPGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YPGR.

  CLEAR : GS_MHDRT, GT_RTN[].

  PERFORM SET_MHDR.
  PERFORM SET_MITM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GS_MHDR
      GOODSMVT_CODE    = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET = GS_MHDRT
    TABLES
      GOODSMVT_ITEM    = GT_MITM
      RETURN           = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.
    MESSAGE S046. "입고 처리를 완료했습니다.

    PERFORM SEND_EPRO USING 'I'.

    PERFORM SET_PGR_STK.
    PERFORM SET_PGR_TAG.
    PERFORM SET_PGR_RTN.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_BAPI_ERR_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MHDR.

  "Header
  CLEAR : GS_MHDR, GS_MCOD.

  GS_MHDR-PSTNG_DATE = GS_PRXX-BUDAT.
  GS_MHDR-DOC_DATE   = SY-DATLO.
  GS_MHDR-REF_DOC_NO = GT_HLIST-VBELN.
  GS_MHDR-PR_UNAME   = SY-UNAME.

  GS_MCOD-GM_CODE    = GC_01. "Goods receipt for PO

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MITM.

  "Item
  CLEAR : GT_MITM[].

  READ TABLE GT_LIST WITH KEY VBELN = GT_HLIST-VBELN
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.
  DATA(LV_TBX) = SY-TABIX.

  PERFORM GET_XDO.

  LOOP AT GT_LIST FROM LV_TBX. "SY-TABIX.
    IF GT_LIST-VBELN <> GT_HLIST-VBELN.
      EXIT.
    ENDIF.

    CLEAR : GT_MITM.

    GT_MITM-MATERIAL  = GT_LIST-MATNR.
    GT_MITM-PLANT     = GT_LIST-WERKS.
    GT_MITM-STGE_LOC  = GT_LIST-LGORT.
    GT_MITM-BATCH     = GT_LIST-CHARG.
    GT_MITM-MOVE_TYPE = GC_101. "GR goods receipt
    GT_MITM-ENTRY_QNT = GT_LIST-LFIMG.
    GT_MITM-ENTRY_UOM = GT_LIST-MEINS.
    GT_MITM-ITEM_TEXT = GT_LIST-LICHN. "추가(SJM 25.02.27)
    GT_MITM-MVT_IND   = GC_B.   "Goods movement for PO

    IF GS_IDO IS NOT INITIAL. "SAP Inbound DO 사용 납품인 경우
      GT_MITM-DELIV_NUMB_TO_SEARCH = GT_LIST-VBELN.
      GT_MITM-DELIV_ITEM_TO_SEARCH = GT_LIST-POSNR.
    ELSE.
      GT_MITM-PO_NUMBER	= GT_LIST-EBELN.
      GT_MITM-PO_ITEM	  = GT_LIST-EBELP.

      IF GT_EPR[] IS NOT INITIAL.
        GV_LINEID  += 1.
        GV_LINEID_P = GV_LINEID.

        GT_MITM-LINE_ID = GV_LINEID.
      ENDIF.
    ENDIF.

    APPEND GT_MITM.

    PERFORM SET_MITM_EPR.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_XDO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_XDO.

  CLEAR : GS_IDO,    GT_EPR[].
  CLEAR : GV_LINEID, GV_LINEID_P.

  SELECT SINGLE VBELN
    FROM LIKP INTO CORRESPONDING FIELDS OF GS_IDO
   WHERE VBELN = GT_HLIST-VBELN.

  CHECK SY-SUBRC <> 0.

  SELECT * FROM ZGTMM_CV_SC_543GICHECK2 "변경(SJM 25.04.14) ZMMTI35
    INTO CORRESPONDING FIELDS OF TABLE @GT_EPR
   WHERE VBELN = @GT_HLIST-VBELN.

  SORT GT_EPR BY VBELN TAGNR. "POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MITM_EPR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MITM_EPR.

  CHECK GT_EPR[] IS NOT INITIAL.

  READ TABLE GT_EPR WITH KEY VBELN = GT_LIST-VBELN
                             TAGNR = GT_LIST-LICHN
*                            POSNR = GT_LIST-POSNR
                             BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_EPR FROM SY-TABIX.
    IF NOT ( GT_EPR-VBELN = GT_LIST-VBELN
         AND GT_EPR-TAGNR = GT_LIST-LICHN ).
*        AND GT_EPR-POSNR = GT_LIST-POSNR ).
      EXIT.
    ENDIF.

    GV_LINEID  += 1.

    CLEAR : GT_MITM.

    PERFORM CONVERT_MATN1_INPUT USING GT_EPR-IDNRK
                             CHANGING GT_MITM-MATERIAL.
*   GT_MITM-MATERIAL  = GT_EPR-IDNRK.
    GT_MITM-PLANT     = GT_LIST-WERKS.
*   GT_MITM-STGE_LOC  = GT_EPR-LGORT.
    GT_MITM-BATCH     = GT_EPR-CHARG.
    GT_MITM-MOVE_TYPE = GC_543. "GI subcon cust stk
    GT_MITM-ENTRY_QNT = GT_EPR-LFIMG.
    GT_MITM-ENTRY_UOM = GT_EPR-MEINS.
    GT_MITM-MVT_IND   = GC_B.   "Goods movement for PO
    GT_MITM-PO_NUMBER	= GT_LIST-EBELN.
    GT_MITM-PO_ITEM	  = GT_LIST-EBELP.
    GT_MITM-LINE_ID   = GV_LINEID.
    GT_MITM-PARENT_ID = GV_LINEID_P.

    APPEND GT_MITM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EPR_IDNRK
*&      <-- GT_MITM_MATERIAL
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_INPUT USING PV_IMATN
                      CHANGING PV_OMATN.

  CHECK PV_IMATN IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_IMATN
    IMPORTING
      OUTPUT       = PV_OMATN
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_EPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_EPRO USING PV_STATUS.

  DATA : LT_TAB LIKE ZGTMMSIF0043 OCCURS 0 WITH HEADER LINE.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE BAPI_MTYPE,
         LV_MSG  TYPE BAPI_MSG.


  "입고 처리/취소 성공시 E-Pro I/F 연계 로직 추가(SJM 25.02.17)
  " 외주직납 검수 RFC에서 입고된 납품서 존재시 에러 처리를 하므로
  " ZGTMM_IF_O_DIRECTGR 전송시 오류가 발생해도 재처리는 하지 않음.

  LT_TAB[] = VALUE #( ( BUKRS   = GT_HLIST-BUKRS
                        WERKS   = GT_HLIST-WERKS
                        VBELN   = |{ GT_HLIST-VBELN ALPHA = OUT }|
                        LIFNR   = |{ GT_HLIST-LIFNR ALPHA = OUT }|
                        ZSTATUS = PV_STATUS ) ).

*2025.08.05 통합솔루션 전환 IS변경
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
*      GUBUN                 = 'MM'
      GUBUN                 = 'IS'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_IF_O_DIRECTGR'
    DESTINATION LV_DEST
    IMPORTING
      E_ZRESULT = LV_RST
      E_MESSAGE = LV_MSG
    TABLES
      OT_TAB    = LT_TAB
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGR_TAG.

  DATA : LT_P01 LIKE ZPPT0001 OCCURS 0 WITH HEADER LINE,
         LT_P15 LIKE ZPPT0015 OCCURS 0 WITH HEADER LINE.


  "꼬리표 로직 추가(SJM 25.02.27)

  "자재문서 조회
  CLEAR : GT_TAG[].

  DO 5 TIMES. "HANA DB 속도차에 의해 읽지 못하는 경우 대비
    PERFORM GET_TAG USING GS_MHDRT-DOC_YEAR
                          GS_MHDRT-MAT_DOC.

    IF GT_TAG[] IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

  CHECK GT_TAG[] IS NOT INITIAL.

  "꼬리표 정보 존재시 ZPPT0001 Insert(꼬리표가 있을때만)
  LT_P01[] = VALUE #( FOR LS_TAG IN GT_TAG
                       ( VALUE #( BASE CORRESPONDING #( LS_TAG )
                                  POSNR = LS_TAG-EBELP ) ) ).
  DELETE LT_P01 WHERE TAGNR IS INITIAL.

  PERFORM MODIFY_ZPPT00XX TABLES LT_P01 USING 'ZPPT0001'.

  "투입 정보 존재시 ZPPT0015 Insert(꼬리표가 있을때만)
  SELECT *
    FROM ZGTMM_CV_TAGNUMBER_GI
   WHERE MJAHR = @GS_MHDRT-DOC_YEAR
     AND MBLNR = @GS_MHDRT-MAT_DOC
     AND TAGNR_O IS NOT INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @LT_P15.

  PERFORM MODIFY_ZPPT00XX TABLES LT_P15 USING 'ZPPT0015'.

  "Update ZMMTI34
  LOOP AT GT_TAG.
    PERFORM UPDATE_ZMMTI34 USING GT_TAG-MBLNR
                                 GT_TAG-MJAHR
                                 GT_TAG-BUDAT
                                 GT_TAG-ZEILE.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MHDRT_DOC_YEAR
*&      --> GS_MHDRT_MAT_DOC
*&---------------------------------------------------------------------*
FORM GET_TAG USING PV_MJAHR
                   PV_MBLNR.

  CLEAR : GT_TAG[].

  SELECT *
    FROM ZGTMM_CV_TAGNUMBER
    INTO CORRESPONDING FIELDS OF TABLE @GT_TAG
   WHERE MJAHR = @PV_MJAHR
     AND MBLNR = @PV_MBLNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT00XX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_P01
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT00XX TABLES PT_PXX
                      USING PV_TNM.

  CHECK PT_PXX[] IS NOT INITIAL.
  MODIFY (PV_TNM) FROM TABLE PT_PXX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZMMTI34
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_TAG_MBLNR
*&      --> GT_TAG_MJAHR
*&      --> GT_TAG_BUDAT
*&      --> GT_TAG_ZEILE
*&---------------------------------------------------------------------*
FORM UPDATE_ZMMTI34 USING PV_MBLNR
                          PV_MJAHR
                          PV_BUDAT
                          PV_ZEILE.

  UPDATE ZMMTI34 SET BELNR = PV_MBLNR
                     GJAHR = PV_MJAHR
                     BUDAT = PV_BUDAT
                     BEZEI = PV_ZEILE
               WHERE VBELN = GT_TAG-VBELN
                 AND POSNR = GT_TAG-POSNR
                 AND WERKS = GT_TAG-WERKS
                 AND MATNR = GT_TAG-MATNR
                 AND TAGNR = GT_TAG-TAGNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODI_XGR_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ICON_LED_GREEN
*&      --> GS_PRXX_BUDAT
*&      --> GS_MHDRT_DOC_YEAR
*&      --> GS_MHDRT_MAT_DOC
*&---------------------------------------------------------------------*
FORM MODI_XGR_RTN USING PV_STATUS
                        PV_BUDAT
                        PV_MJAHR
                        PV_MBLNR.

  GT_HLIST-STATUS = PV_STATUS.
  GT_HLIST-BUDAT  = PV_BUDAT.
  GT_HLIST-MJAHR  = PV_MJAHR.
  GT_HLIST-MBLNR  = PV_MBLNR.

  IF PV_MBLNR IS NOT INITIAL.
    GT_HLIST-ZCLOSE = GC_X.
    GT_HLIST-ZGUID  = GT_SHDR-ZGUID.
  ELSE.
    GT_HLIST-ZCLOSE = SPACE.
    GT_HLIST-ZGUID  = SPACE.
  ENDIF.

  MODIFY GT_HLIST INDEX GS_ROW-INDEX
           TRANSPORTING STATUS ZCLOSE BUDAT MJAHR MBLNR ZGUID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGR_RTN.

  "입고 처리 결과 List Update

  PERFORM MODI_XGR_RTN USING ICON_LED_GREEN
                             GS_PRXX-BUDAT
                             GS_MHDRT-DOC_YEAR
                             GS_MHDRT-MAT_DOC.

  CLEAR : GT_ILIST[].

  GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BAPI_ERR_MSG.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.
  CHECK SY-SUBRC = 0.

  MESSAGE S000 DISPLAY LIKE 'E'
     WITH GT_RTN-MESSAGE+0(50)   GT_RTN-MESSAGE+50(50)
          GT_RTN-MESSAGE+100(50) GT_RTN-MESSAGE+150(50).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCGR.

  CLEAR : GV_ERR, GV_PRXX, GS_PRXX.

  PERFORM CHECK_CCGR.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_CGR.

  GS_PRXX-TXT01 = '입고 취소 처리 하시겠습니까?'(P02).
  GS_PRXX-BUDAT = GT_HLIST-BUDAT.

  CALL SCREEN 200 STARTING AT 10 5
                    ENDING AT 60 7.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CCGR.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '처리할 대상을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HLIST INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  IF GT_HLIST-STATUS <> ICON_LED_GREEN.
    MESSAGE S047 DISPLAY LIKE 'E'. "입고 처리되지 않은 정보입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YCGR.

  CLEAR : GS_MHDRT, GT_RTN[].

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GT_HLIST-MBLNR
      MATDOCUMENTYEAR     = GT_HLIST-MJAHR
      GOODSMVT_PSTNG_DATE = GS_PRXX-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = GS_MHDRT
    TABLES
      RETURN              = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.
    MESSAGE S048. "입고 취소했습니다.

    PERFORM SEND_EPRO USING 'C'.

    PERFORM SET_CGR_STK.
    PERFORM SET_CGR_TAG.
    PERFORM SET_CGR_RTN.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_BAPI_ERR_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CGR_RTN.

  "입고 취소 처리 결과 List Update

  PERFORM MODI_XGR_RTN USING ICON_LED_YELLOW
                             ' ' ' ' ' '.

  CLEAR : GT_ILIST[].

  GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_STK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGR_STK.

  CLEAR : GS_SHDR, GV_REVAL, GT_SHDR.

  "한도 예외 관리 업체 Check(SJM 25.03.25)
  " 초과 불출 예외 업체는 한도 금액 상관없음. 초과 불출 정보 저장 안함.(ZGTMMT4110 저장 X)
  SELECT SINGLE LIFNR
    FROM ZGTMMT4101 INTO @DATA(LV_LIFNR)
   WHERE LIFNR = @GT_HLIST-EMLIF. "검수업체

  CHECK SY-SUBRC <> 0.

  "선택된 상단 ALV의 라인 대상으로 공급업체의 보증금액 한도와 외주 재고액 조회
  SELECT SINGLE PREIS,
                TOTALSCVALUE,
                APVALUE,
                WAERS
    INTO CORRESPONDING FIELDS OF @GS_SHDR
    FROM ZGTMM_CV_SCSTOCKHEADER
   WHERE BUKRS = @P_BUKRS
     AND LIFNR = @GT_HLIST-EMLIF.

  CHECK SY-SUBRC = 0.

  "보증보험 금액 - 외주재고액 - 입고액
  GV_REVAL = GS_SHDR-PREIS - GS_SHDR-TOTALSCVALUE - GT_HLIST-STOCKVALSUM.

  CHECK GV_REVAL < 0.

  PERFORM SET_SHDR.
  PERFORM SET_SITM.

  MODIFY ZGTMMT4111 FROM TABLE GT_SITM.
  MODIFY ZGTMMT4110 FROM TABLE GT_SHDR.

  IF SY-SUBRC = 0.
    UPDATE ZGTMMT4010 SET ZGUID = GT_SHDR-ZGUID
                    WHERE BUKRS = GT_HLIST-BUKRS
                      AND WERKS = GT_HLIST-WERKS
                      AND VBELN = GT_HLIST-VBELN.
    COMMIT WORK.

    MESSAGE S128. "입고 처리를 완료했습니다.(외주 업체 재고 한도 초과) "추가(SJM 25.03.25)
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_GUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SHDR_ZGUID
*&---------------------------------------------------------------------*
FORM CREATE_GUID CHANGING PV_ZGUID.

  CLEAR : PV_ZGUID.
  PV_ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

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
*& Form SET_SHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SHDR.

  CLEAR : GT_SHDR, GT_SHDR[].

  PERFORM CREATE_GUID CHANGING GT_SHDR-ZGUID.

  GT_SHDR-ZGITYPE = GC_D.
  GT_SHDR-BUKRS   = GT_HLIST-BUKRS.
  GT_SHDR-WERKS   = GT_HLIST-WERKS.
* GT_SHDR-LGORT   = GT_HLIST-LGORT.
  GT_SHDR-LIFNR   = GT_HLIST-EMLIF.
  GT_SHDR-PREIS   = GS_SHDR-PREIS.
  GT_SHDR-SCVAL   = GS_SHDR-TOTALSCVALUE.
  GT_SHDR-ISVAL   = GT_HLIST-STOCKVALSUM.
  GT_SHDR-REVAL   = GV_REVAL.
  GT_SHDR-IVVAL   = GS_SHDR-APVALUE.
  GT_SHDR-WAERS   = GS_SHDR-WAERS.
  GT_SHDR-ORES    = GC_003.
  GT_SHDR-OETC    = '업체 직납'(M02).
  GT_SHDR-APPSTAT = GC_A.
  GT_SHDR-MJAHR   = GS_MHDRT-DOC_YEAR. "추가(SJM 24.12.31)
  GT_SHDR-MBLNR   = GS_MHDRT-MAT_DOC.  "추가(SJM 24.12.31)

  PERFORM SET_TIMESTAMP USING 'X' 'X'.
  MOVE-CORRESPONDING GS_CREA TO GT_SHDR.
  MOVE-CORRESPONDING GS_CHNG TO GT_SHDR.

  APPEND GT_SHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SITM.

  DATA : BEGIN OF LT_ITM OCCURS 0,
           MATNR      TYPE ZGTMM_CV_GETINBDIRECT_I-MATNR,        "자재코드
           LFIMG      TYPE ZGTMM_CV_GETINBDIRECT_I-LFIMG,        "납품수량
           MEINS      TYPE ZGTMM_CV_GETINBDIRECT_I-MEINS,        "단위
           STOCKVALUE TYPE ZGTMM_CV_GETINBDIRECT_I-STOCKVALUE,   "재고평가액
           WAERS_I    TYPE ZGTMM_CV_GETINBDIRECT_I-WAERS,        "통화
         END   OF LT_ITM.


  CLEAR : GT_SITM[].

  READ TABLE GT_LIST WITH KEY VBELN = GT_HLIST-VBELN
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_LIST FROM SY-TABIX.
    IF GT_LIST-VBELN <> GT_HLIST-VBELN.
      EXIT.
    ENDIF.

    "선택한 상단 ALV-VBELN를 구성하는 Item 정보를 MATNR별 Collect
    CLEAR : LT_ITM.
    MOVE-CORRESPONDING GT_LIST TO LT_ITM.
    COLLECT LT_ITM.
  ENDLOOP.

  SORT LT_ITM BY MATNR.

  SELECT MATNR,
         XCHPF,
         SCQTY,
         MEINS,
         SCVAL,
         WAERS
    INTO TABLE @DATA(LT_STK)
    FROM ZGTMM_CV_SCREQLIST_L
     FOR ALL ENTRIES IN @LT_ITM
   WHERE BUKRS = @P_BUKRS
     AND LIFNR = @GT_HLIST-EMLIF
     AND MATNR = @LT_ITM-MATNR.

  SORT LT_STK BY MATNR.

  LOOP AT LT_ITM.
    CLEAR : GT_SITM.

    GT_SITM-ZGUID = GT_SHDR-ZGUID.
    GT_SITM-MATNR = LT_ITM-MATNR.
    GT_SITM-REQTY = LT_ITM-LFIMG.
    GT_SITM-NEQTY = LT_ITM-LFIMG.
*   GT_SITM-SLQTY
    GT_SITM-ISQTY	= LT_ITM-LFIMG.
    GT_SITM-MEINS	= LT_ITM-MEINS.
    GT_SITM-ISVAL	= LT_ITM-STOCKVALUE.
    GT_SITM-WAERS	= LT_ITM-WAERS_I.

    SELECT SINGLE XCHPF
      FROM MARC INTO GT_SITM-XCHPF
     WHERE MATNR = LT_ITM-MATNR
       AND WERKS = GT_HLIST-WERKS
       AND LVORM = SPACE.

    READ TABLE LT_STK INTO DATA(LS_STK)
      WITH KEY MATNR = LT_ITM-MATNR BINARY SEARCH.

    IF SY-SUBRC = 0.
      GT_SITM-SCQTY	= LS_STK-SCQTY.
      GT_SITM-SCVAL	= LS_STK-SCVAL.
    ENDIF.

    APPEND GT_SITM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_STK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CGR_STK.

  "입고 취소시 ZGTMMT4110-LOEKZ = 'X' (상단 ALV-ZGUID 기준)

  CHECK GT_HLIST-ZGUID IS NOT INITIAL.

  UPDATE ZGTMMT4110 SET LOEKZ = GC_X
                  WHERE ZGUID = GT_HLIST-ZGUID.

  UPDATE ZGTMMT4010 SET ZGUID = SPACE
                  WHERE BUKRS = GT_HLIST-BUKRS
                    AND WERKS = GT_HLIST-WERKS
                    AND VBELN = GT_HLIST-VBELN.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CGR_TAG.

  "꼬리표 로직 추가(SJM 25.02.27)

  "취소한 원본 자재문서 조회
  PERFORM GET_TAG USING GT_HLIST-MJAHR
                        GT_HLIST-MBLNR.

  CHECK GT_TAG[] IS NOT INITIAL.

  LOOP AT GT_TAG.
    "GT_TAG 전체 값에 대해 다음 삭제 처리(꼬리표가 있을때만)
    IF GT_TAG-TAGNR IS NOT INITIAL.
      DELETE FROM ZPPT0001 WHERE WERKS = GT_TAG-WERKS
                             AND AUFNR = GT_TAG-AUFNR
                             AND TAGNR = GT_TAG-TAGNR
                             AND MATNR = GT_TAG-MATNR.

      DELETE FROM ZPPT0015 WHERE WERKS   = GT_TAG-WERKS
                             AND TAGNR_O = GT_TAG-TAGNR.
    ENDIF.

    "Table ZMMTI34 자재문서/항번 Clear
    PERFORM UPDATE_ZMMTI34 USING ' ' ' ' ' ' ' '.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
