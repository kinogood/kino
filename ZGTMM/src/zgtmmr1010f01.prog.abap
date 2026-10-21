*&---------------------------------------------------------------------*
*& Include          ZGTMMR1010F01
*&---------------------------------------------------------------------*
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

  CHECK GV_ERR IS INITIAL.
  CHECK P_VAL  IS INITIAL.

  SET CURSOR FIELD P_FNM.
  MESSAGE S015 WITH P_TXT DISPLAY LIKE 'E'. "&를(을) 입력하세요.

  GV_ERR = GC_X.

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

  CLEAR : GS_MCON-BUKRS, GS_MCON-BUTXT.

  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS BUTXT
    FROM T001
    INTO CORRESPONDING FIELDS OF GS_MCON
   WHERE BUKRS = P_BUKRS
     AND SPRAS = SY-LANGU.

  CHECK SY-SUBRC <> 0.

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

  "회사코드-플랜트간 종속성 체크

  CLEAR : GS_MCON-WERKS, GS_MCON-NAME1.

  CHECK P_BUKRS IS NOT INITIAL
    AND P_WERKS IS NOT INITIAL.

  SELECT SINGLE W~WERKS W~NAME1
    FROM T001K AS K INNER JOIN T001W AS W
      ON K~BWKEY = W~BWKEY
    INTO CORRESPONDING FIELDS OF GS_MCON
   WHERE K~BUKRS = P_BUKRS
     AND W~WERKS = P_WERKS
     AND W~SPRAS = SY-LANGU.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E016 WITH '플랜트'(F05). "&를(을) 확인하세요.

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

  PERFORM F4IF_FIELD USING 'ZGTMMT4113' "ZGTMMT4014
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
FORM F4IF_FIELD USING P_TNAME
                      P_FNAME
                      P_SHELP
                      P_FIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = CONV TABNAME( P_TNAME )
      FIELDNAME         = CONV FIELDNAME( P_FNAME )
      SEARCHHELP        = CONV SHLPNAME( P_SHELP )
*     SHLPPARAM         = ' '
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = CONV DYNFNAM( P_FIELD )
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
*& Form CHECK_MAND_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MAND_COND.

  CLEAR : GV_ERR.

  "필수 입력 필드 Check
  PERFORM CHECK_NULL USING P_BUKRS 'P_BUKRS' '회사코드'(F03).
  PERFORM CHECK_NULL USING P_WERKS 'P_WERKS' '플랜트'(F05).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_KEY.

  "Table Key

  GV_TNAME = COND #( WHEN P_ABL = GC_X THEN GC_ZGTMMT4113
                     WHEN P_ABS = GC_X THEN GC_ZGTMMT4014 ).

  CLEAR : GT_KEY[], GT_KTAB[].

  SELECT FIELDNAME
         POSITION
    FROM DD03L
    INTO TABLE GT_KEY
   WHERE TABNAME    = GV_TNAME
     AND FIELDNAME <> GC_MANDT
     AND KEYFLAG    = GC_X.

  GT_KTAB[] = VALUE #( FOR LS_KEY IN GT_KEY
                       ( VALUE #( NAME = LS_KEY-FNAME ) ) ).

  "공통 Key(입력 불가) 삭제
  DELETE GT_KEY WHERE FNAME = GC_BUKRS.
  DELETE GT_KEY WHERE FNAME = GC_WERKS.

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

  CLEAR : GV_CNT.

  CASE 'X'.
    WHEN P_ABL.
      PERFORM GET_ABL_DATA TABLES GT_ABL GT_OBL
                                  GT_M13 GT_D13.
    WHEN P_ABS.
      PERFORM GET_ABS_DATA TABLES GT_ABS GT_OBS
                                  GT_M14 GT_D14.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> PT_ABL_STYLE
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
*& Form SET_ABX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABL
*&      --> PT_OBL
*&---------------------------------------------------------------------*
FORM SET_ABX_DATA TABLES PT_ABX
                         PT_OBX
                         PT_M1X
                         PT_D1X.

  SORT PT_ABX BY (GT_KTAB).

  GV_CNT = LINES( PT_ABX ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

  PERFORM SET_ORGN TABLES PT_ABX PT_OBX
                          PT_M1X PT_D1X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABL
*&      --> PT_OBL
*&      --> GT_M13
*&      --> GT_D13
*&---------------------------------------------------------------------*
FORM SET_ORGN TABLES PT_NEW
                     PT_OLD
                     PT_M1X
                     PT_D1X.

  CLEAR : PT_OLD[].
  CLEAR : PT_M1X[], PT_D1X[].

  PT_OLD[] = PT_NEW[]. "변경 전 Data

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ABL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> GT_OBL
*&      --> GT_M13
*&      --> GT_D13
*&---------------------------------------------------------------------*
FORM GET_ABL_DATA TABLES PT_ABL STRUCTURE GT_ABL
                         PT_OBL STRUCTURE GT_OBL
                         PT_M13 STRUCTURE GT_M13
                         PT_D13 STRUCTURE GT_D13.

  CLEAR : PT_ABL[].

  SELECT *
    FROM ZGTMM_CV_APPUSER_LIST
    INTO CORRESPONDING FIELDS OF TABLE @PT_ABL
   WHERE BUKRS  = @P_BUKRS
     AND WERKS  = @P_WERKS.

  IF PT_ABL[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  PERFORM SET_STYLE USING 'E' 'APPROVER1' PT_ABL-STYLE.
  PERFORM SET_STYLE USING 'E' 'APPROVER2' PT_ABL-STYLE.

  MODIFY PT_ABL TRANSPORTING STYLE
                       WHERE STYLE IS INITIAL.

  PERFORM SET_ABX_DATA TABLES PT_ABL PT_OBL
                              PT_M13 PT_D13.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ABS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABS
*&      --> GT_OBS
*&      --> GT_M14
*&      --> GT_D14
*&---------------------------------------------------------------------*
FORM GET_ABS_DATA TABLES PT_ABS STRUCTURE GT_ABS
                         PT_OBS STRUCTURE GT_OBS
                         PT_M14 STRUCTURE GT_M14
                         PT_D14 STRUCTURE GT_D14.

  CLEAR : PT_ABS[].

  SELECT *
    FROM ZGTMM_CV_APPUSER_LIST_SPG
    INTO CORRESPONDING FIELDS OF TABLE @PT_ABS
   WHERE BUKRS = @P_BUKRS
     AND WERKS = @P_WERKS.

  IF PT_ABS[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  PERFORM SET_STYLE USING 'E' 'APPUSER' PT_ABS-STYLE.
  PERFORM SET_STYLE USING 'E' 'ZUSE'    PT_ABS-STYLE.

  MODIFY PT_ABS TRANSPORTING STYLE
                       WHERE STYLE IS INITIAL.

  PERFORM SET_ABX_DATA TABLES PT_ABS PT_OBS
                              PT_M14 PT_D14.

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

  GV_TITLE = COND #( WHEN P_ABL = GC_X THEN '사급자재 초과 불출 승인'(T01)
                     WHEN P_ABS = GC_X THEN '직납 PO 변경 승인'(T02) ).

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
  GS_LAYO-STYLEFNAME = GC_STYLE.
  GS_LAYO-CTAB_FNAME = GC_COLOR.

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

  SET HANDLER GR_EVENTS->HANDLE_TOOLBAR               FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_ONF4                  FOR GR_GRID.
* SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK         FOR GR_GRID.

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
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_LIST
                    USING PV_TNAME.

  PERFORM SET_FCAT TABLES PT_LIST
                    USING PV_TNAME.

  PERFORM SET_DISP TABLES PT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_LIST
*&      --> PV_TNAME
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_LIST
               USING PV_TNAME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNAME
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

    CASE PV_TNAME.
      WHEN 'GT_ABL'.
        PERFORM SET_ABL_FCAT.
      WHEN 'GT_ABS'.
        PERFORM SET_ABS_FCAT.
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
*& Form SET_ABL_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ABL_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Status'(F01).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'MSG_TXT'.
      PERFORM SET_FTXT USING 'Message'(F02).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F03).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'BUTXT'.
      PERFORM SET_FTXT USING '회사명'(F04).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F05).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '플랜트명'(F06).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F07).
*     GS_FCAT-KEY       = GC_X.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'LGOBE'.
      PERFORM SET_FTXT USING '저장위치명'(F08).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'APPROVER1'.
      PERFORM SET_FTXT USING '승인자'(F09).
      GS_FCAT-EDIT = GC_X.
    WHEN 'APNAME1'.
      PERFORM SET_FTXT USING '승인자명'(F10).
    WHEN 'APPROVER2'.
      PERFORM SET_FTXT USING '승인자(대리)'(F11).
      GS_FCAT-EDIT = GC_X.
    WHEN 'APNAME2'.
      PERFORM SET_FTXT USING '승인자명(대리)'(F12).
    WHEN 'ERDAT'.
      PERFORM SET_FTXT USING '생성일'(F13).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일(Local)'(F14).
    WHEN 'ERTIM'.
      PERFORM SET_FTXT USING '생성시간'(F15).
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '생성시간(Local)'(F16).
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '생성자'(F17).
    WHEN 'AEDAT'.
      PERFORM SET_FTXT USING '변경일'(F18).
    WHEN 'AEDAT_LOCAL'.
      PERFORM SET_FTXT USING '변경일(Local)'(F19).
    WHEN 'AETIM'.
      PERFORM SET_FTXT USING '변경시간'(F20).
    WHEN 'AETIM_LOCAL'.
      PERFORM SET_FTXT USING '변경시간(Local)'(F21).
    WHEN 'AENAM'.
      PERFORM SET_FTXT USING '변경자'(F22).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ABS_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ABS_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Status'(F01).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'MSG_TXT'.
      PERFORM SET_FTXT USING 'Message'(F02).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING '회사코드'(F03).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'BUTXT'.
      PERFORM SET_FTXT USING '회사명'(F04).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F05).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '플랜트명'(F06).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING '구매그룹'(F23).
*     GS_FCAT-KEY       = GC_X.
*     GS_FCAT-VALEXI    = GC_EM.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'EKNAM'.
      PERFORM SET_FTXT USING '구매그룹명'(F24).
*     GS_FCAT-KEY       = GC_X.
      GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'APPUSER'.
      PERFORM SET_FTXT USING '승인자'(F09).
      GS_FCAT-EDIT = GC_X.
    WHEN 'APNAME1'.
      PERFORM SET_FTXT USING '승인자명'(F10).
    WHEN 'ZUSE'.
      PERFORM SET_FTXT USING '사용여부'(F25).
      GS_FCAT-EDIT     = GC_X.
      GS_FCAT-CHECKBOX = GC_X.
    WHEN 'ERDAT'.
      PERFORM SET_FTXT USING '생성일'(F13).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일(Local)'(F14).
    WHEN 'ERTIM'.
      PERFORM SET_FTXT USING '생성시간'(F15).
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '생성시간(Local)'(F16).
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '생성자'(F17).
    WHEN 'AEDAT'.
      PERFORM SET_FTXT USING '변경일'(F18).
    WHEN 'AEDAT_LOCAL'.
      PERFORM SET_FTXT USING '변경일(Local)'(F19).
    WHEN 'AETIM'.
      PERFORM SET_FTXT USING '변경시간'(F20).
    WHEN 'AETIM_LOCAL'.
      PERFORM SET_FTXT USING '변경시간(Local)'(F21).
    WHEN 'AENAM'.
      PERFORM SET_FTXT USING '변경자'(F22).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

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
*& Form CHECK_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_EXIT USING PV_MODE.

  PERFORM CHECK_CHANGE.

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
*& Form CHECK_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGE.

  CASE 'X'.
    WHEN P_ABL.
      PERFORM CHECK_CHGON TABLES GT_ABL.
    WHEN P_ABS.
      PERFORM CHECK_CHGON TABLES GT_ABS.
  ENDCASE.

* CLEAR : GV_CHG.
*
* CASE 'X'.
*   WHEN P_ABL.
*     PERFORM CHECK_CHGON TABLES GT_ABL.
*     CHECK GT_OBL[] <> GT_ABL[].
*   WHEN P_ABS.
*     CHECK GT_OBS[] <> GT_ABS[].
* ENDCASE.
*
* GV_CHG = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHGON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&---------------------------------------------------------------------*
FORM CHECK_CHGON TABLES PT_ABX.

  CLEAR : GV_CHG.

  LOOP AT PT_ABX.
    PERFORM ASSIGN_COM USING PT_ABX 'X' ' ' ' ' ' ' ' '.

    CHECK <GFS_STATUS> = ICON_CREATE
       OR <GFS_STATUS> = ICON_CHANGE.

    GV_CHG = GC_X.
    EXIT.
  ENDLOOP.

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
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          PV_OTEXT.

  DATA : LS_TBAR TYPE STB_BUTTON.


  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.
    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION  = &2.
    LS_TBAR-ICON      = &3.
    LS_TBAR-TEXT      = &4.
    LS_TBAR-QUICKINFO = &4.
    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE 'Save'(B01).
      _SET_TBAR 0 'INSR' ICON_INSERT_ROW  '신규'(B02).
      _SET_TBAR 0 'MISR' ICON_INSERT_ROW  '멀티'(B03).
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '삭제'(B04).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PV_UCOMM LIKE SY-UCOMM
                               PV_OTEXT.

  CLEAR : GV_REF.

  CASE PV_UCOMM.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA USING 'X'.

    WHEN 'INSR'.
      PERFORM INSR_DATA.

    WHEN 'MISR'.
      PERFORM MISR_DATA.

    WHEN 'DELE'.
      PERFORM DELE_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_DATA USING PV_POP.

  CASE 'X'.
    WHEN P_ABL.
      PERFORM SAVE_ABX_DATA TABLES GT_ABL GT_OBL
                                   GT_M13 GT_D13
                             USING PV_POP.

    WHEN P_ABS.
      PERFORM SAVE_ABX_DATA TABLES GT_ABS GT_OBS
                                   GT_M14 GT_D14
                             USING PV_POP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ABX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> GT_OBL
*&      --> GT_M13
*&      --> GT_D13
*&      --> PV_POP
*&---------------------------------------------------------------------*
FORM SAVE_ABX_DATA TABLES PT_ABX
                          PT_OBX
                          PT_M1X
                          PT_D1X
                    USING PV_POP.

  DATA : L_VALID.


  CLEAR : PT_M1X[], GV_ERR.

  GR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = L_VALID ).
  CHECK L_VALID IS NOT INITIAL.

  IF PV_POP = GC_X.
    PERFORM CHECK_CHGON TABLES PT_ABX.

    IF GV_CHG = GC_X. "PT_OBX[] <> PT_ABX[].
      PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                     '변경된 Data를 저장하시겠습니까?'(P02).

      CHECK GV_ANS = GC_1.
    ELSE.
      MESSAGE S017. "변경된 내역이 없습니다.
      EXIT.
    ENDIF.
  ENDIF.

  GV_REF = GC_X.

  PERFORM CHECK_ERROR TABLES PT_ABX.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_TIMESTAMP USING 'X' 'X'.

  LOOP AT PT_ABX.
    PERFORM ASSIGN_COM USING PT_ABX 'X' ' ' 'X' ' ' ' '.

    CASE <GFS_STATUS>.
      WHEN ICON_CREATE.
        PERFORM SET_M1X TABLES PT_M1X
                         USING PT_ABX
                               'I'.
      WHEN ICON_CHANGE.
        PERFORM SET_M1X TABLES PT_M1X
                         USING PT_ABX
                               'U'.
      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY PT_ABX.
  ENDLOOP.

  IF PT_D1X[] IS INITIAL AND PT_M1X[] IS INITIAL.
    MESSAGE S007 DISPLAY LIKE 'E'. "저장할 내역이 없습니다.
    EXIT.
  ENDIF.

  IF PT_D1X[] IS NOT INITIAL.
    DELETE (GV_TNAME) FROM TABLE PT_D1X.
    DATA(L_DEL) = SY-SUBRC.
  ENDIF.

  IF PT_M1X[] IS NOT INITIAL.
    MODIFY (GV_TNAME) FROM TABLE PT_M1X.
    DATA(L_MOD) = SY-SUBRC.
  ENDIF.

  IF L_DEL = 0 AND L_MOD = 0.
    COMMIT WORK.

    PERFORM SET_URST TABLES PT_ABX.
    PERFORM SET_MRST TABLES PT_M1X PT_D1X.
    PERFORM SET_ORGN TABLES PT_ABX PT_OBX
                            PT_M1X PT_D1X.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S010 DISPLAY LIKE 'E'. "저장에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM CHECK_ERROR TABLES PT_ABX.

  LOOP AT PT_ABX.
    GV_TBX = SY-TABIX.
    PERFORM ASSIGN_COM USING PT_ABX 'X' 'X' 'X' ' ' 'X'.

    PERFORM CHECK_ERR  USING PT_ABX.

    CASE <GFS_STATUS>.
      WHEN ICON_RED_LIGHT.
        MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
        GV_ERR = GC_X. "EXIT.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    MODIFY PT_ABX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM CHECK_ERR USING PS_ABX.

  DATA : LV_TXT(10),
         LV_APP TYPE LVC_FNAME.


  "신규 라인만 추가하고 값을 입력하지 않을 수 있으므로 필수 필드 Check

  CLEAR : GV_MSG, GV_SEQ.

  CHECK <GFS_TYPE> = GC_I.

  READ TABLE GT_KEY INDEX 1.

  LV_TXT = COND #( WHEN P_ABL = GC_X THEN '저장위치'(F07)
                   WHEN P_ABS = GC_X THEN '구매그룹'(F23) ).

  ASSIGN COMPONENT GT_KEY-FNAME OF STRUCTURE PS_ABX TO <GFS_KEY>.
  PERFORM CHECK_MAND USING <GFS_KEY> GT_KEY-FNAME LV_TXT.

  LV_APP = COND #( WHEN P_ABL = GC_X THEN GC_APPROVER1
                   WHEN P_ABS = GC_X THEN GC_APPUSER ).

  ASSIGN COMPONENT LV_APP OF STRUCTURE PS_ABX TO FIELD-SYMBOL(<LFS_APP>).
  PERFORM CHECK_MAND USING <LFS_APP> LV_APP '승인자'(F09).

  PERFORM RESET_STATUS.

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
*& Form SET_M1X
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_M1X
*&      --> PT_ABX
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_M1X TABLES PT_M1X
              USING PS_ABX
                    P_CHK.

  CASE P_CHK.
    WHEN 'I'.
      MOVE-CORRESPONDING GS_CREA TO PS_ABX.
      <GFS_TYPE> = GC_S.
    WHEN 'U'.
      MOVE-CORRESPONDING GS_CHNG TO PS_ABX.
      <GFS_TYPE> = GC_U.
  ENDCASE.

  MOVE-CORRESPONDING PS_ABX TO PT_M1X.
  APPEND PT_M1X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_URST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM SET_URST TABLES PT_ABX.

  LOOP AT PT_ABX.
    PERFORM ASSIGN_COM USING PT_ABX 'X' 'X' ' ' 'X' ' '.

    CASE <GFS_STATUS>.
      WHEN ICON_CREATE.
        CLEAR : <GFS_STY>.

      WHEN ICON_CHANGE.
      WHEN ICON_GREEN_LIGHT.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    "이미 저장 작업한 뒤 바로 재작업시..
    IF <GFS_STATUS> = ICON_GREEN_LIGHT.
      <GFS_STATUS> = ICON_YELLOW_LIGHT.
    ELSE.
      <GFS_STATUS> = ICON_GREEN_LIGHT.
    ENDIF.

    <GFS_MTXT> = SPACE.

    MODIFY PT_ABX TRANSPORTING ('STATUS')
                               ('MSG_TXT')
                               ('STYLE').
  ENDLOOP.

  SORT PT_ABX BY (GT_KTAB).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSR_DATA.

  CLEAR : GT_ABL, GT_ABS.

  PERFORM INSR_COM_DATA.

  CASE 'X'.
    WHEN P_ABL.
      MOVE-CORRESPONDING GS_COM TO GT_ABL.

      PERFORM SET_STYLE USING 'E' 'LGORT'     GT_ABL-STYLE.
      PERFORM SET_STYLE USING 'E' 'APPROVER1' GT_ABL-STYLE.
      PERFORM SET_STYLE USING 'E' 'APPROVER2' GT_ABL-STYLE.

      APPEND GT_ABL.

    WHEN P_ABS.
      MOVE-CORRESPONDING GS_COM TO GT_ABS.
      GT_ABS-ZUSE = GC_X.

      PERFORM SET_STYLE USING 'E' 'EKGRP'   GT_ABS-STYLE.
      PERFORM SET_STYLE USING 'E' 'APPUSER' GT_ABS-STYLE.
      PERFORM SET_STYLE USING 'E' 'ZUSE'    GT_ABS-STYLE.

      APPEND GT_ABS.

  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSR_COM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSR_COM_DATA.

  CLEAR : GS_COM.

  GS_COM-STATUS = ICON_CREATE.
  GS_COM-TYPE   = GC_I.
  GS_COM-BUKRS  = P_BUKRS.
  GS_COM-BUTXT  = GS_MCON-BUTXT.
  GS_COM-WERKS  = P_WERKS.
  GS_COM-NAME1  = GS_MCON-NAME1.
  GS_COM-ERNAM  = SY-UNAME.
* GS_COM-AENAM  = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MISR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MISR_DATA.

  DATA : LV_RTRN,
         LT_SVAL TYPE TABLE OF SVAL,
         LV_LINE LIKE ZGTMMT1010-SEQ.


  LT_SVAL = VALUE #( (  TABNAME   = 'ZGTMMT1010' "임의지정
                        FIELDNAME = 'SEQ'
                        VALUE     = '2'
                        FIELDTEXT = '추가할 라인 수(1~999)'(T04) ) ).

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK  = ' '
      POPUP_TITLE     = '라인수 입력'(T03)
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = LV_RTRN
    TABLES
      FIELDS          = LT_SVAL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.

  CHECK LV_RTRN IS INITIAL.

  LV_LINE = VALUE #( LT_SVAL[ 1 ]-VALUE OPTIONAL ).

  IF LV_LINE IS INITIAL.
    MESSAGE S015 WITH TEXT-T04 DISPLAY LIKE 'E'. "&를(을)입력하세요.
    EXIT.
  ENDIF.

  DO LV_LINE TIMES.
    PERFORM INSR_DATA.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
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
*& Form DELE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELE_DATA.

  DATA : LT_ABL LIKE GT_ABL OCCURS 0 WITH HEADER LINE,
         LT_ABS LIKE GT_ABS OCCURS 0 WITH HEADER LINE.


  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'
                                  '삭제할 대상을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  DELETE GT_ROW WHERE INDEX IS INITIAL.
  SORT GT_ROW BY INDEX DESCENDING.

  CLEAR : GT_D13[], GT_D14[].
  CLEAR : GR_IDX[], GV_CHK.

  LT_ABL[] = GT_ABL[].
  LT_ABS[] = GT_ABS[].

  LOOP AT GT_ROW INTO GS_ROW.
    CASE 'X'.
      WHEN P_ABL.
        PERFORM DELE_ABX_LIST TABLES LT_ABL
                                     GT_D13.
      WHEN P_ABS.
        PERFORM DELE_ABX_LIST TABLES LT_ABS
                                     GT_D14.
    ENDCASE.
  ENDLOOP.

  IF GV_CHK = GC_X.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '저장되었던 데이터를 삭제합니다. 삭제하시겠습니까?'(P03).

    CHECK GV_ANS = GC_1.
  ENDIF.

  GV_REF = GC_X.

  CASE 'X'.
    WHEN P_ABL.
      GT_ABL[] = LT_ABL[].
      PERFORM DELE_ABX_DATA TABLES GT_ABL GT_OBL
                                   GT_M13 GT_D13.
    WHEN P_ABS.
      GT_ABS[] = LT_ABS[].
      PERFORM DELE_ABX_DATA TABLES GT_ABS GT_OBS
                                   GT_M14 GT_D14.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_ABX_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> GT_D13
*&---------------------------------------------------------------------*
FORM DELE_ABX_LIST TABLES PT_ABX
                          PT_D1X.

  READ TABLE PT_ABX INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  ASSIGN COMPONENT 'TYPE' OF STRUCTURE PT_ABX TO <GFS_TYPE>.

  CASE <GFS_TYPE>.
    WHEN 'I'. "신규 라인

    WHEN OTHERS.
      GV_CHK = GC_X.
      MOVE-CORRESPONDING PT_ABX TO PT_D1X.
      APPEND PT_D1X.

  ENDCASE.

  DELETE PT_ABX INDEX GS_ROW-INDEX.

  APPEND VALUE #( SIGN   = GC_I
                  OPTION = GC_EQ
                  LOW    = GS_ROW-INDEX ) TO GR_IDX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_ABX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> GT_OBL
*&      --> GT_M13
*&      --> GT_D13
*&---------------------------------------------------------------------*
FORM DELE_ABX_DATA TABLES PT_ABX
                          PT_OBX
                          PT_M1X
                          PT_D1X.

  DELETE GT_ERR WHERE INDEX IN GR_IDX.

  CHECK PT_D1X[] IS NOT INITIAL.
  DELETE (GV_TNAME) FROM TABLE PT_D1X.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM SET_MRST TABLES PT_M1X PT_D1X.
    PERFORM SET_ORGN TABLES PT_ABX PT_OBX
                            PT_M1X PT_D1X.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S014 DISPLAY LIKE 'E'. "삭제에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MRST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_M1X
*&      --> PT_D1X
*&---------------------------------------------------------------------*
FORM SET_MRST TABLES PT_M1X
                     PT_D1X.

  CLEAR : GV_TCNT, GV_MCNT, GV_DCNT.

  GV_MCNT = LINES( PT_M1X ).
  GV_DCNT = LINES( PT_D1X ).
  GV_TCNT = GV_MCNT + GV_DCNT.

  MESSAGE S009 WITH GV_TCNT GV_MCNT GV_DCNT. "총 &1 건: 저장 &2 건, 삭제 &3 건.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PV_OTEXT.

  CLEAR : GV_REF, GR_DROW[].

  IF PR_CHNG->MT_INSERTED_ROWS IS NOT INITIAL.
    GR_DROW[] = VALUE #( FOR LS_IROW IN PR_CHNG->MT_INSERTED_ROWS
                         ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_IROW-ROW_ID ) ) ).

    DELETE PR_CHNG->MT_GOOD_CELLS WHERE ROW_ID IN GR_DROW.
    DELETE PR_CHNG->MT_MOD_CELLS  WHERE ROW_ID IN GR_DROW.
    CLEAR : PR_CHNG->MT_INSERTED_ROWS.
  ENDIF.

  LOOP AT PR_CHNG->MT_GOOD_CELLS INTO GS_MODI.
    CASE GS_MODI-FIELDNAME.
      WHEN 'LGORT' OR 'APPROVER1' OR 'APPROVER2'
        OR 'EKGRP' OR 'APPUSER'   OR 'ZUSE'.
        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.

      WHEN OTHERS.

    ENDCASE.

    GV_REF = GC_X.
  ENDLOOP.

  CHECK GR_DROW[] IS NOT INITIAL. "ALV List 반영!
  PERFORM REFRESH_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> ICON_CHANGE
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                       PV_FNAME
                       PV_FVAL.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = GS_MODI-ROW_ID
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

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

  IF GR_DROW[] IS NOT INITIAL.
    DELETE PT_MODI WHERE ROW_ID IN GR_DROW.
  ENDIF.

  GT_MODI[] = PT_MODI[].

  CASE 'X'.
    WHEN P_ABL.
      PERFORM CHNG_ABX_DATA TABLES GT_ABL
                                   GT_SBL.

    WHEN P_ABS.
      PERFORM CHNG_ABX_DATA TABLES GT_ABS
                                   GT_SBS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_COM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM ASSIGN_COM USING PS_ABX
                      PV_STS
                      PV_MSG
                      PV_TYP
                      PV_STY
                      PV_COL.

  IF PV_STS = GC_X.
    ASSIGN COMPONENT 'STATUS'  OF STRUCTURE PS_ABX TO <GFS_STATUS>.
  ENDIF.

  IF PV_MSG = GC_X.
    ASSIGN COMPONENT 'MSG_TXT' OF STRUCTURE PS_ABX TO <GFS_MTXT>.
  ENDIF.

  IF PV_TYP = GC_X.
    ASSIGN COMPONENT 'TYPE'    OF STRUCTURE PS_ABX TO <GFS_TYPE>.
  ENDIF.

  IF PV_STY = GC_X.
    ASSIGN COMPONENT 'STYLE'   OF STRUCTURE PS_ABX TO <GFS_STY>.
  ENDIF.

  IF PV_COL = GC_X.
    ASSIGN COMPONENT 'COLOR'   OF STRUCTURE PS_ABX TO <GFS_COL>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_ABX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ABL
*&      --> GT_SBL
*&---------------------------------------------------------------------*
FORM CHNG_ABX_DATA TABLES PT_ABX
                          PT_SBX.

  PT_SBX[] = PT_ABX[].
  SORT PT_SBX BY (GT_KTAB).

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE PT_ABX INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    AT NEW ROW_ID.
      GV_NEW = GC_X.
    ENDAT.

    GV_SEQ = SPACE.
    GV_TBX = GS_MODI-ROW_ID.

    PERFORM ASSIGN_COM USING PT_ABX 'X' 'X' 'X' ' ' 'X'.

    PERFORM CHECK_DUP TABLES PT_ABX
                             PT_SBX.

    ASSIGN COMPONENT GS_MODI-FIELDNAME OF STRUCTURE PT_ABX TO <GFS_VAL>.

    CASE GS_MODI-FIELDNAME.
      WHEN 'LGORT'.
        PERFORM CHANGE_LGORT USING PT_ABX.

      WHEN 'APPROVER1' OR 'APPROVER2' OR 'APPUSER'.
        PERFORM CHANGE_APRVR USING PT_ABX.

      WHEN 'EKGRP'.
        PERFORM CHANGE_EKGRP USING PT_ABX.

      WHEN 'ZUSE'.

    ENDCASE.

    AT END OF ROW_ID.
      PERFORM RESET_STATUS.
    ENDAT.

    MODIFY PT_ABX INDEX GS_MODI-ROW_ID.
    GV_REF = GC_X.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&      --> PT_SBX
*&---------------------------------------------------------------------*
FORM CHECK_DUP TABLES PT_ABX
                      PT_SBX.

  DATA : LV_MANDT TYPE MANDT.


  CLEAR : GV_ERR, GV_MSG.

  CHECK   GV_NEW = GC_X.
  CLEAR : GV_NEW.

  CHECK <GFS_TYPE> = GC_I. "Only 신규 입력건

  GV_COND = | BUKRS = P_BUKRS AND WERKS = P_WERKS |.

  CASE 'X'.
    WHEN P_ABL.
      ASSIGN COMPONENT 'LGORT' OF STRUCTURE PT_ABX TO <GFS_KEY>.
      GV_COND = GV_COND && | AND LGORT = <GFS_KEY> |.
    WHEN P_ABS.
      ASSIGN COMPONENT 'EKGRP' OF STRUCTURE PT_ABX TO <GFS_KEY>.
      GV_COND = GV_COND && | AND EKGRP = <GFS_KEY> |.
  ENDCASE.

  CHECK <GFS_KEY> IS NOT INITIAL.

  "기 저장 여부 Check
  SELECT SINGLE MANDT
    FROM (GV_TNAME) INTO LV_MANDT "@DATA(L_MANDT)
   WHERE (GV_COND).

  IF SY-SUBRC = 0.
    MESSAGE E011 INTO GV_MSG. "이미 동일한 데이터가 등록된 상태입니다.
  ELSE.
    PERFORM CHECK_SCR_DUP TABLES PT_SBX.
  ENDIF.

  LOOP AT GT_KEY.
    IF GV_MSG IS NOT INITIAL.
      PERFORM SET_ERR_MSG USING GT_KEY-FNAME 'D'.
      PERFORM SET_ERR_COL USING GT_KEY-FNAME.
    ELSE.
      PERFORM RESET_ERR   USING GT_KEY-FNAME 'D'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SCR_DUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SBX
*&---------------------------------------------------------------------*
FORM CHECK_SCR_DUP TABLES PT_SBX.

  DATA : LV_CNT TYPE I.


  LOOP AT PT_SBX WHERE (GV_COND).
    LV_CNT += 1.
  ENDLOOP.

  CHECK LV_CNT > 1.
  MESSAGE E012 INTO GV_MSG. "중복된 데이터가 존재합니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_KEY_FNAME
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_FNM
                       PV_TYPE.

  GV_SEQ += 1.

  GS_ERR-INDEX = GV_TBX.
  GS_ERR-F_SEQ = GV_SEQ.
  GS_ERR-FNAME = PV_FNM.
  GS_ERR-MSG   = GV_MSG.
  GS_ERR-TYPE  = PV_TYPE.
  INSERT GS_ERR INTO TABLE GT_ERR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_KEY_FNAME
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_KEY_FNAME
*&      --> P_
*&---------------------------------------------------------------------*
FORM RESET_ERR USING PV_FNM
                     PV_TYPE.

  DELETE GT_ERR WHERE INDEX = GV_TBX
                  AND FNAME = PV_FNM
                  AND TYPE  = PV_TYPE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_STATUS.

  PERFORM SET_MSG_TXT.

  IF <GFS_MTXT> IS NOT INITIAL.
    <GFS_STATUS> = ICON_RED_LIGHT.
    PERFORM SET_LIST_CUR.
  ELSE.
    CASE <GFS_TYPE>.
      WHEN 'I'.
        <GFS_STATUS> = ICON_CREATE.
      WHEN 'U' OR 'S'.
        <GFS_STATUS> = ICON_CHANGE.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MSG_TXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MSG_TXT.

  DATA : LR_FNAME TYPE RANGE OF LVC_FNAME.


  CLEAR : GV_FNM, <GFS_MTXT>.

  READ TABLE GT_ERR INTO GS_ERR WITH KEY INDEX = GV_TBX
                                         BINARY SEARCH.

  IF SY-SUBRC = 0.
    GV_FNM     = GS_ERR-FNAME.
    <GFS_MTXT> = GS_ERR-MSG.

    LOOP AT GT_ERR INTO GS_ERR FROM SY-TABIX.
      IF GS_ERR-INDEX <> GV_TBX.
        EXIT.
      ENDIF.

      APPEND VALUE #( SIGN   = GC_E
                      OPTION = GC_EQ
                      LOW    = GS_ERR-FNAME ) TO LR_FNAME.
    ENDLOOP.
  ELSE.
    CLEAR : <GFS_COL>.
  ENDIF.

  CHECK LR_FNAME[] IS NOT INITIAL.
  DELETE <GFS_COL> WHERE FNAME IN LR_FNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_CUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_CUR.

  CLEAR : GS_ROW, GS_COL.
  GS_ROW-INDEX     = GV_TBX.
  GS_COL-FIELDNAME = GV_FNM.

  CALL METHOD GR_GRID->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = GS_ROW
      IS_COLUMN_ID = GS_COL.
*     IS_ROW_NO    =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM CHANGE_LGORT USING PS_ABX.

  ASSIGN COMPONENT 'LGOBE' OF STRUCTURE PS_ABX TO FIELD-SYMBOL(<LFS_LGOBE>).

  PERFORM CHECK_MAND USING <GFS_VAL> 'LGORT' '저장위치'(F07).

  PERFORM CHECK_T001L USING <GFS_VAL>
                   CHANGING <LFS_LGOBE>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFS_VAL>
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_MAND USING P_VAL
                      P_FNM
                      P_TXT.

  IF P_VAL IS INITIAL.
    MESSAGE E008 WITH P_TXT INTO GV_MSG. "필수 값이 누락되었습니다. &

    PERFORM SET_ERR_MSG USING P_FNM 'M'.
    PERFORM SET_ERR_COL USING P_FNM.
  ELSE.
    PERFORM RESET_ERR   USING P_FNM 'M'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_T001L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFS_VAL>
*&      <-- <LFS_LGOBE>
*&---------------------------------------------------------------------*
FORM CHECK_T001L USING PV_LGORT
              CHANGING PV_LGOBE.

  CLEAR : PV_LGOBE.
  CHECK PV_LGORT IS NOT INITIAL.

  SELECT SINGLE LGOBE
    FROM T001L INTO PV_LGOBE
   WHERE WERKS = P_WERKS
     AND LGORT = PV_LGORT.

  IF SY-SUBRC <> 0.
    MESSAGE E081 WITH '저장위치'(F07) INTO GV_MSG. "존재하지 않는 &입니다.

    PERFORM SET_ERR_MSG USING 'LGORT' 'V'.
    PERFORM SET_ERR_COL USING 'LGORT'.
  ELSE.
    PERFORM RESET_ERR   USING 'LGORT' 'V'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_APRVR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM CHANGE_APRVR USING PS_ABX.

  DATA : LV_ANAME TYPE LVC_FNAME.


  CASE GS_MODI-FIELDNAME.
    WHEN 'APPROVER1' OR 'APPUSER'.
      PERFORM CHECK_MAND USING <GFS_VAL> GS_MODI-FIELDNAME '승인자'(F09).
      LV_ANAME = GC_APNAME1.

    WHEN 'APPROVER2'.
      LV_ANAME = GC_APNAME2.

  ENDCASE.

  ASSIGN COMPONENT LV_ANAME OF STRUCTURE PS_ABX TO FIELD-SYMBOL(<LFS_ANAME>).

  PERFORM GET_ANAME USING <GFS_VAL>
                 CHANGING <LFS_ANAME>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ANAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFS_VAL>
*&      <-- <LFS_ANAME>
*&---------------------------------------------------------------------*
FORM GET_ANAME USING PV_USERID
            CHANGING PV_NAME.

  CLEAR : PV_NAME.
  CHECK PV_USERID IS NOT INITIAL.

  SELECT SINGLE NAME
    FROM ZGTMM_CV_GETUSERNAME
    INTO @PV_NAME
   WHERE USERID = @PV_USERID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_EKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ABX
*&---------------------------------------------------------------------*
FORM CHANGE_EKGRP USING PS_ABX.

  ASSIGN COMPONENT 'EKNAM' OF STRUCTURE PS_ABX TO FIELD-SYMBOL(<LFS_EKNAM>).

  PERFORM CHECK_MAND USING <GFS_VAL> 'EKGRP' '구매그룹'(F23).

  PERFORM CHECK_T024 USING <GFS_VAL>
                  CHANGING <LFS_EKNAM>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_T024
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFS_VAL>
*&      <-- <LFS_EKNAM>
*&---------------------------------------------------------------------*
FORM CHECK_T024 USING PV_EKGRP
             CHANGING PV_EKNAM.

  CLEAR : PV_EKNAM.
  CHECK PV_EKGRP IS NOT INITIAL.

  SELECT SINGLE EKNAM
    FROM T024 INTO PV_EKNAM
   WHERE EKGRP = PV_EKGRP.

  IF SY-SUBRC <> 0.
    MESSAGE E081 WITH '구매그룹'(F23) INTO GV_MSG. "존재하지 않는 &입니다.

    PERFORM SET_ERR_MSG USING 'EKGRP' 'V'.
    PERFORM SET_ERR_COL USING 'EKGRP'.
  ELSE.
    PERFORM RESET_ERR   USING 'EKGRP' 'V'.
  ENDIF.

ENDFORM.
