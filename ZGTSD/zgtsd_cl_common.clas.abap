class ZGTSD_CL_COMMON definition
  public
  final
  create public .

public section.
  type-pools ESP1 .

  types:
    TY_T_BAPIXMSPOW TYPE TABLE OF BAPIXMSPOW .
  types:
    TY_T_ZGTSDS0010   TYPE TABLE OF ZGTSDS0010 WITH DEFAULT KEY .

  constants GC_1 type CHAR1 value '1' ##NO_TEXT.
  constants GC_2 type CHAR1 value '2' ##NO_TEXT.
  constants GC_A type CHAR1 value 'A' ##NO_TEXT.
  constants GC_B type CHAR1 value 'B' ##NO_TEXT.
  constants GC_C type CHAR1 value 'C' ##NO_TEXT.
  constants GC_D type CHAR1 value 'D' ##NO_TEXT.
  constants GC_E type CHAR1 value 'E' ##NO_TEXT.
  constants GC_F type CHAR1 value 'F' ##NO_TEXT.
  constants GC_G type CHAR1 value 'G' ##NO_TEXT.
  constants GC_H type CHAR1 value 'H' ##NO_TEXT.
  constants GC_I type CHAR1 value 'I' ##NO_TEXT.
  constants GC_J type CHAR1 value 'J' ##NO_TEXT.
  constants GC_K type CHAR1 value 'K' ##NO_TEXT.
  constants GC_L type CHAR1 value 'L' ##NO_TEXT.
  constants GC_M type CHAR1 value 'M' ##NO_TEXT.
  constants GC_N type CHAR1 value 'N' ##NO_TEXT.
  constants GC_O type CHAR1 value 'O' ##NO_TEXT.
  constants GC_P type CHAR1 value 'P' ##NO_TEXT.
  constants GC_Q type CHAR1 value 'Q' ##NO_TEXT.
  constants GC_R type CHAR1 value 'R' ##NO_TEXT.
  constants GC_S type CHAR1 value 'S' ##NO_TEXT.
  constants GC_T type CHAR1 value 'T' ##NO_TEXT.
  constants GC_U type CHAR1 value 'U' ##NO_TEXT.
  constants GC_V type CHAR1 value 'V' ##NO_TEXT.
  constants GC_W type CHAR1 value 'W' ##NO_TEXT.
  constants GC_X type CHAR1 value 'X' ##NO_TEXT.
  constants GC_Y type CHAR1 value 'Y' ##NO_TEXT.
  constants GC_Z type CHAR1 value 'Z' ##NO_TEXT.
  constants GC_SB type CHAR1 value 'b' ##NO_TEXT.
  constants GC_SS type CHAR1 value 's' ##NO_TEXT.
  constants GC_SG type CHAR1 value 'g' ##NO_TEXT.
  constants GC_COMMA type CHAR1 value ',' ##NO_TEXT.
  constants GC_POINT type CHAR1 value '.' ##NO_TEXT.
  constants GC_COLON type CHAR1 value ':' ##NO_TEXT.
  constants GC_PLUS type CHAR1 value '+' ##NO_TEXT.
  constants GC_MINUS type CHAR1 value '-' ##NO_TEXT.
  constants GC_SLASH type CHAR1 value '/' ##NO_TEXT.
  constants GC_NUMERIC type CHAR20 value '0123456789-. ' ##NO_TEXT.
  constants GC_QUOTA type CHAR1 value '"' ##NO_TEXT.
  constants GC_XLSX type CHAR4 value 'XLSX' ##NO_TEXT.
  constants GC_H_LOWER type CHAR1 value 'h' ##NO_TEXT.
  constants GC_FN_LINECOL type FIELDNAME value 'LINECOL' ##NO_TEXT.

  class-methods GET_DYNP_VALUE
    importing
      value(IV_FNAME) type FIELDNAME
      !IV_REPID type SY-REPID default SY-CPROG
      !IV_DYNNR type SY-DYNNR default SY-DYNNR
    returning
      value(RV_VALUE) type STRING .
  class-methods SET_DYNP_VALUE
    importing
      !IV_FNAME type FIELDNAME optional
      !IV_VALUE type DYNFIELDVALUE optional
      !IV_REPID type SY-REPID default SY-CPROG
      !IV_DYNNR type SY-DYNNR default SY-DYNNR
      !IT_VALUE type DYNPREAD_T optional .
  class-methods SET_TIMESTAMP
    importing
      !IV_GUBUN type CHAR1 default 'A'
    changing
      !CS_TIMESTAMP type ANY .
  class-methods GET_FIELDCATALOG
    importing
      value(IT_TAB) type ANY TABLE
    returning
      value(RT_FIELDCAT) type LVC_T_FCAT .
  class-methods GET_FCAT
    importing
      !IS_FCAT type LVC_S_FCAT optional
      !IV_DDIC_OBJECT type ANY optional
      !IS_DATA type ANY optional
      !IT_DATA type ANY TABLE optional
      !IO_DREF type ref to DATA optional
    returning
      value(RT_FCAT) type LVC_T_FCAT
    exceptions
      NO_STRUCTURE
      INVALID_TYPE .
  class-methods GET_ALV_EXCL_TOOLBAR
    returning
      value(RT_EXCL) type UI_FUNCTIONS .
  class-methods GET_ALV_LAYOUT
    importing
      !IT_TAB type STANDARD TABLE
    returning
      value(RS_LAYOUT) type LVC_S_LAYO .
  class-methods ALV_REFRESH
    importing
      !IO_ALV type ref to CL_GUI_ALV_GRID
      !IV_NORMAL type CHAR01 optional .
  class-methods ALV_DISPLAY
    importing
      !IT_FCAT type LVC_T_FCAT optional
      !IV_SCOL type SY-TABIX
      !IV_SLINE type SY-TABIX
      !IV_ECOL type SY-TABIX
      !IV_ELINE type SY-TABIX
    changing
      !CT_TAB type STANDARD TABLE .
  class-methods SET_ALV_F4
    importing
      !IO_ALV type ref to CL_GUI_ALV_GRID
      !IT_FCAT type LVC_T_FCAT .
  class-methods POPUP_TO_COMFIRM
    importing
      !IV_UCOMM type ANY
      !IV_MESSA type ANY optional
    returning
      value(RV_ANSWER) type CHAR1 .
  class-methods GET_DOMAIN_TEXT
    importing
      value(IV_DOMNAME) type DOMNAME
      value(IV_DOMVALUE) type DOMVALUE_L
    returning
      value(RV_DDTEXT) type VAL_TEXT .
  class-methods CONV_TIME_ZONE
    importing
      value(IV_DATE) type DATUM
      value(IV_TIME) type UZEIT
      value(IV_CONVTY) type CHAR1 default 'S'
      value(IV_TZONE_LO) type TZNZONE optional
    exporting
      value(EV_DATE) type DATUM
      value(EV_TIME) type UZEIT .
  class-methods FILE_CHECK
    importing
      !IV_FILENAME type STRING
    returning
      value(RV_RESULT) type CHAR1 .
  class-methods CONV_DATE_INPUT
    changing
      !CV_INPUT type ANY .
  class-methods CONV_TIME_INPUT
    changing
      !CV_INPUT type ANY .
  class-methods CONV_CURR_INPUT
    changing
      !CV_INPUT type ANY
    exceptions
      NOT_NUMERIC .
  class-methods GET_ALV_VARIANT
    importing
      !IV_REPID type REPID default SY-REPID
      !IV_HANDLE type SLIS_HANDL
      !IV_UNAME type SLIS_USER optional
    returning
      value(RV_VARIANT) type SLIS_VARI .
  class-methods F4_ALV_VARIANT
    importing
      !IV_REPID type REPID default SY-CPROG
      !IV_HANDLE type SLIS_HANDL
      !IV_UNAME type SLIS_USER
    returning
      value(RV_VARIANT) type SLIS_VARI .
  class-methods READ_USER_NAME
    importing
      value(IV_UNAME) type UNAME
    returning
      value(RV_NAME_TX) type AD_NAMTEXT .
  class-methods FILE_OPEN_DIALOG
    importing
      !IV_FILTER type STRING default CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
    returning
      value(RV_FNAME) type LOCALFILE .
  class-methods FILE_OPEN_DIALOG2
    importing
      value(IV_FILTER) type STRING optional
    returning
      value(RT_FNAME) type CNV_20000_FILENAME .
  class-methods FILE_SAVE_DIALOG
    importing
      !IV_FILTER type STRING default CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
    changing
      !CV_FNAME type LOCALFILE .
  class-methods EXCEL_OLE_STANDART_DAT
    importing
      !IV_FNAME type LOCALFILE
      value(IT_DATA) type STANDARD TABLE
      value(IT_FIELD) type STANDARD TABLE .
  class-methods FILE_GET_SIZE
    importing
      !IV_FNAME type LOCALFILE
    returning
      value(RV_FSIZE) type INT4 .
  class-methods ZSE16N
    importing
      !IV_TAB_NAME type TABLE_NAME
      !IV_MAX_LINES type SYTABIX default 500 .
  class-methods GET_FIELDCAT
    importing
      !IT_TAB type ANY TABLE
    returning
      value(RT_FIELDCAT) type LVC_T_FCAT
    exceptions
      NOT_A_STRUCTURE
      NO_DDIC .
  class-methods DISPLAY_MESSAGE
    importing
      !IV_TITLE type LVC_TITLE optional
      !IT_BAPIRET2 type BAPIRET2_T .
  class-methods EXCEL_DOWNLOAD
    importing
      value(IT_DATA) type TABLE
      value(IT_FCAT) type LVC_T_FCAT
      value(IV_DEF_FNAME) type STRING default 'EXPORT.XLSX'
      value(IV_XML_TYPE) type SALV_BS_CONSTANT default IF_SALV_BS_XML=>C_TYPE_XLSX
      value(IV_XML_VERSION) type STRING default IF_SALV_BS_XML=>VERSION
      value(IV_OPERATION) type STRING default 'OPEN'
    exporting
      value(EV_FILENAME) type STRING .
  class-methods EXCEL_UPLOAD
    importing
      value(IV_FILENAME) type LOCALFILE
      value(IV_HEADER_CNT) type INT2 default 1
      value(IV_COLUMN_CNT) type INT2 default 0
      value(IV_UPPERCASE) type CHAR1 default 'X'
      value(IV_START_COL) type INT4 default 1
      value(IV_END_ROW) type INT4 optional
      value(IV_FIRST_SHEET) type CHAR1 default 'X'
      value(IV_SHEET_NO) type INT4 optional
    exporting
      !ET_TABLE type TABLE
      !EV_ERROR type FLAG .
  class-methods GET_LOGIN_EMP_NO
    returning
      value(RV_EMP_NO) type ZGTE_EMP_NO .
  class-methods GET_ELEMENTS
    importing
      !IT_COMP type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
    returning
      value(RT_COMP) type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
  class-methods GET_FIELD_INFO
    importing
      !IV_TABNAME type TABNAME
      !IV_FIELDNAME type FIELDNAME
      !IV_LANGU type SY-LANGU
    exporting
      !ES_DFIES type DFIES
    exceptions
      FIELD_INFO_NOT_FOUND .
  class-methods AUTHORITY_CHECK
    importing
      value(IV_OBJECT) type XUOBJECT
      value(IV_AUTH_FIELD) type XUFIELD
      value(IV_AUTH_VAL) type XUVAL
    exporting
      value(EV_MTYPE) type BAPI_MTYPE
      value(EV_MSGTX) type BAPI_MSG .
  class-methods GET_CODE_MASTER
    importing
      value(IV_CODE) type ZGTE_GCODE
      value(IV_CODE1) type ZGTE_SCODE1 optional
      value(IV_CODE2) type ZGTE_SCODE2 optional
      value(IV_CODE3) type ZGTE_SCODE3 optional
      value(IV_FS) type CHAR1 optional
      value(IV_FIELDNAME) type LVC_FNAME optional
      value(IV_VALUE) type USRCHAR20 optional
    returning
      value(RT_CODE) type TY_T_ZGTSDS0010 .
  class-methods GET_FIELD_CATALOG
    importing
      value(IV_DEF_TECH) type LVC_TECH default 'X'
      !IV_CELLS type FLAG optional
      !IV_CELLC type FLAG optional
      value(IT_TABLE) type ANY TABLE
    returning
      value(RT_FCAT) type LVC_T_FCAT .
  class-methods GET_SELECTED_ROWS
    importing
      value(IO_GRID) type ref to CL_GUI_ALV_GRID
      value(IV_CK) type FLAG optional
      value(IV_ONLY_ONE) type FLAG optional
      value(IV_INFOTY) type FLAG optional
    exporting
      value(EV_SUBRC) type SYSUBRC
    returning
      value(RT_ROWS) type LVC_T_ROW .
  class-methods EXCEL_WEB_UPLOAD
    importing
      value(IV_FILENAME) type LOCALFILE
      value(IV_HEADER_CNT) type INT2 default 1
      value(IV_COLUMN_CNT) type INT2 default 0
      value(IV_UPPERCASE) type CHAR1 default 'X'
      value(IV_START_COL) type INT4 default 1
      value(IV_END_ROW) type INT4 optional
      value(IV_FIRST_SHEET) type CHAR1 default 'X'
      value(IV_SHEET_NO) type INT4 optional
    exporting
      !ET_TABLE type TABLE
      !EV_ERROR type FLAG .
  class-methods CONV_COLUMN_TO_I
    importing
      value(IV_FLD) type FIELDNAME
    changing
      value(EV_COL_NUM) type I .
  class-methods CHECK_EXIT_CONTROL
    importing
      value(IV_CODEGRP) type ZGTECODEGRP
      value(IV_PROG) type SY-CPROG
      value(IV_PERFORM) type SY-CPROG
      value(IV_VKORG) type VKORG optional
      value(IV_VTWEG) type VTWEG optional
      value(IV_SPART) type SPART optional
      value(IV_VKBUR) type VKBUR optional
      value(IV_WERKS) type WERKS_D optional
      value(IV_AUART) type AUART optional
      value(IV_LFART) type LFART optional
      value(IV_FKART) type FKART optional
      !IV_DATE type SY-DATLO default SY-DATLO
    returning
      value(EV_ACTIVE) type CHAR1 .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZGTSD_CL_COMMON IMPLEMENTATION.


  METHOD ALV_DISPLAY.
    "--------------------------------------------------------------------------------
*   CALL method zcl_cm_common=>alv_display( EXPORTING it_fcat = gt_fcat1 i_scol = 10 i_sline = 5 i_ecol = 150 i_eline = 15  CHANGING ct_tab = <gt_list1> ).
    "--------------------------------------------------------------------------------

    DATA : LT_FCAT  TYPE SLIS_T_FIELDCAT_ALV,
           LT_FCAT1 TYPE LVC_T_FCAT,
           LS_LAYO  TYPE SLIS_LAYOUT_ALV,
           LS_FCAT1 LIKE LINE OF LT_FCAT1,
           LS_FCAT  LIKE LINE OF LT_FCAT.

    IF IT_FCAT IS NOT INITIAL.
      LT_FCAT1 = IT_FCAT.
    ELSE.
      LT_FCAT1 = GET_FCAT( IT_DATA = CT_TAB ).
    ENDIF.
    LOOP AT LT_FCAT1 INTO LS_FCAT1.
      MOVE-CORRESPONDING LS_FCAT1 TO LS_FCAT.
      LS_FCAT-SELTEXT_S = LS_FCAT-SELTEXT_M = LS_FCAT-SELTEXT_L = LS_FCAT1-COLTEXT.
      APPEND LS_FCAT TO LT_FCAT.
    ENDLOOP.
    LS_LAYO-COLWIDTH_OPTIMIZE = 'X'.
*   ls_layo-box_fieldname = 'BOX'.
*   ls_layo-no_rowmark = 'X'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        IS_LAYOUT             = LS_LAYO
        IT_FIELDCAT           = LT_FCAT
*       IT_EXCLUDING          = lt_excl
        I_SCREEN_START_COLUMN = IV_SCOL
        I_SCREEN_START_LINE   = IV_SLINE
        I_SCREEN_END_COLUMN   = IV_ECOL
        I_SCREEN_END_LINE     = IV_ELINE
*       IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        T_OUTTAB              = CT_TAB
      EXCEPTIONS
        PROGRAM_ERROR         = 1
        OTHERS                = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD ALV_REFRESH.
    "--------------------------------------------------------------------------------
*    CALL METHOD zcl_cm_common=>alv_refresh( io_alv = go_grid2 ).   "soft refresh
*    CALL METHOD zcl_cm_common=>alv_refresh( io_alv = go_grid2  i_normal = 'X').   "sub total, grand totalµîÀ» °»½ÅÇÏ°íÀÚ ÇÒ¶§
    "--------------------------------------------------------------------------------

    DATA : LS_STBL TYPE LVC_S_STBL,
           LV_SOFT TYPE CHAR01.

    LV_SOFT = LS_STBL-ROW = LS_STBL-COL = GC_X.
    IF IV_NORMAL IS NOT INITIAL.
      CLEAR: LV_SOFT.
    ENDIF.

    CALL METHOD IO_ALV->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE      = LS_STBL
        I_SOFT_REFRESH = LV_SOFT
      EXCEPTIONS
        FINISHED       = 1
        OTHERS         = 2.
  ENDMETHOD.


  METHOD AUTHORITY_CHECK.

    DATA: LO_DATA   TYPE REF TO DATA,
          LT_OBJVAL TYPE TABLE OF USVALUES.
    FIELD-SYMBOLS: <LT_VAL> TYPE TABLE.


*.- 0. Check Input Field
    IF IV_OBJECT IS INITIAL.
      MESSAGE S008 WITH TEXT-F11 INTO EV_MSGTX.
      EV_MTYPE = GC_E.  RETURN.
    ENDIF.

    IF IV_AUTH_FIELD IS INITIAL.
      MESSAGE S008 WITH TEXT-F12 INTO EV_MSGTX.
      EV_MTYPE = GC_E.  RETURN.
    ENDIF.

    IF IV_AUTH_VAL IS INITIAL.
      MESSAGE S008 WITH TEXT-F13 INTO EV_MSGTX.
      EV_MTYPE = GC_E.  RETURN.
    ENDIF.

*.- 1. Check Authority Object
    CALL FUNCTION 'EFG_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        X_OBJECT       = IV_OBJECT
      TABLES
        YT_USVALUES    = LT_OBJVAL
      EXCEPTIONS
        USER_NOT_FOUND = 1
        NOT_AUTHORIZED = 2
        INTERNAL_ERROR = 3
        OTHERS         = 4.
    IF SY-SUBRC NE 0.
      MESSAGE S006 WITH TEXT-F11 IV_OBJECT INTO EV_MSGTX.
      EV_MTYPE = GC_E.  RETURN.
    ENDIF.

*.- 2. Check Authority Field
    SORT LT_OBJVAL BY FIELD.
    READ TABLE LT_OBJVAL WITH KEY FIELD = IV_AUTH_FIELD
                         TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      MESSAGE S006 WITH TEXT-F12 IV_AUTH_FIELD INTO EV_MSGTX.
      EV_MTYPE = GC_E.  RETURN.
    ENDIF.


*.- Read Data Element, Check Table.
    SELECT SINGLE ROLLNAME, CHECKTABLE
      INTO @DATA(LS_AUTHX)
      FROM AUTHX
     WHERE FIELDNAME EQ @IV_AUTH_FIELD.
    IF SY-SUBRC EQ 0.
      DATA(LV_ROLLNAME) = LS_AUTHX-ROLLNAME.
      DATA(LV_CHKTABLE) = LS_AUTHX-CHECKTABLE.
    ENDIF.

*.- Read Check Table.
    IF LV_CHKTABLE IS INITIAL.
      SELECT SINGLE B~ENTITYTAB INTO LV_CHKTABLE
        FROM DD04L AS A INNER JOIN DD01L AS B
                           ON A~DOMNAME EQ B~DOMNAME
       WHERE A~ROLLNAME EQ LV_ROLLNAME.
    ENDIF.

*.- 3. Check Authority Value
    IF LV_CHKTABLE IS NOT INITIAL.
      TRY.
          CREATE DATA LO_DATA TYPE TABLE OF (LV_CHKTABLE).
          ASSIGN LO_DATA->* TO <LT_VAL>.
          CHECK SY-SUBRC EQ 0.

          DATA(LV_COND) = CONV CHAR72( IV_AUTH_FIELD && ' EQ @IV_AUTH_VAL' ).
          SELECT * INTO CORRESPONDING FIELDS OF TABLE @<LT_VAL>
            FROM (LV_CHKTABLE)
           WHERE (LV_COND).
          IF SY-SUBRC NE 0.
            MESSAGE S006 WITH TEXT-F13 IV_AUTH_VAL INTO EV_MSGTX.
            EV_MTYPE = GC_E.  RETURN.
          ENDIF.

        CATCH CX_ROOT INTO DATA(LO_SQL).
          EV_MSGTX = LO_SQL->GET_TEXT( ).
          EV_MTYPE = GC_E.  RETURN.
      ENDTRY.
    ENDIF.


*.- 4. Check Authority
    AUTHORITY-CHECK OBJECT IV_OBJECT  ID IV_AUTH_FIELD  FIELD IV_AUTH_VAL.
    IF SY-SUBRC EQ 0.
      EV_MTYPE = GC_S.
    ELSE.
      EV_MTYPE = GC_E.
      MESSAGE S149(00) WITH IV_AUTH_VAL INTO EV_MSGTX.
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_EXIT_CONTROL.

*-----------------------------------------------------------------------
*-- 1. 로컬 데이터 선언
*-----------------------------------------------------------------------
    DATA : LR_VKORG TYPE RANGE OF ZGTE_FLDVAL,
           LR_SPART TYPE RANGE OF ZGTE_FLDVAL,
           LR_VKBUR TYPE RANGE OF ZGTE_FLDVAL,
           LR_VTWEG TYPE RANGE OF ZGTE_FLDVAL,
           LR_WERKS TYPE RANGE OF ZGTE_FLDVAL,
           LR_AUART TYPE RANGE OF ZGTE_FLDVAL,
           LR_LFART TYPE RANGE OF ZGTE_FLDVAL,
           LR_PROG  TYPE RANGE OF ZGTE_FLDVAL,
           LR_PERF  TYPE RANGE OF ZGTE_FLDVAL,
           LR_FKART TYPE RANGE OF ZGTE_FLDVAL.

*-- Range Sign
    CONSTANTS : BEGIN OF GC_SIGN,
                  I TYPE DDSIGN                     VALUE 'I',
                  E TYPE DDSIGN                     VALUE 'E',
                END OF GC_SIGN,
*-- Range Option
                BEGIN OF GC_OPTN,
                  EQ TYPE DDOPTION                  VALUE 'EQ',
                  NE TYPE DDOPTION                  VALUE 'NE',
                  BT TYPE DDOPTION                  VALUE 'BT',
                  CP TYPE DDOPTION                  VALUE 'CP',
                END OF GC_OPTN.

    CLEAR : LR_VKORG, LR_SPART, LR_AUART, LR_VKBUR, LR_VTWEG, LR_WERKS,
            LR_LFART, LR_PROG,  LR_PERF,  LR_FKART, EV_ACTIVE.

*-----------------------------------------------------------------------
*-- 2. 로직 구성
*-----------------------------------------------------------------------
*-- 조회조건 기준 Range 변수 구성

    IF IV_PROG IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_PROG
                    ) TO LR_PROG.
    ENDIF.

    IF IV_PERFORM IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_PERFORM
                    ) TO LR_PERF.
    ENDIF.


    IF IV_VKORG IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_VKORG
                    ) TO LR_VKORG.
    ENDIF.

    IF IV_VTWEG IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_VTWEG
                    ) TO LR_VTWEG.
    ENDIF.

    IF IV_SPART IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_SPART
                    ) TO LR_SPART.
    ENDIF.

    IF IV_VKBUR IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_VKBUR
                    ) TO LR_VKBUR.
    ENDIF.

    IF IV_WERKS IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_WERKS
                    ) TO LR_WERKS.
    ENDIF.

    IF IV_AUART IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_AUART
                    ) TO LR_AUART.
    ENDIF.

    IF IV_LFART IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_LFART
                    ) TO LR_LFART.
    ENDIF.

    IF IV_FKART IS NOT INITIAL.
      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-EQ
                      LOW    = IV_FKART
                    ) TO LR_FKART.
    ENDIF.

*-- 입력 정보 기준 신규 로직 적용여부 Select
    SELECT SINGLE MANDT INTO @SY-MANDT
      FROM ZGTPPT1010 AS A
     WHERE A~MODULE_KIND EQ 'SD'
       AND A~CODEGRP     EQ @IV_CODEGRP
       AND A~FLD_01      IN @LR_PROG
       AND A~FLD_02      IN @LR_PERF
       AND A~FLD_03      IN @LR_VKORG
       AND A~FLD_04      IN @LR_VTWEG
       AND A~FLD_05      IN @LR_SPART
       AND A~FLD_06      IN @LR_VKBUR
       AND A~FLD_07      IN @LR_WERKS
       AND A~FLD_08      IN @LR_AUART
       AND A~FLD_09      IN @LR_LFART
       AND A~FLD_10      IN @LR_FKART
       AND A~FLD_11      EQ @ZGTSD_Y
       AND A~FLD_12      <= @IV_DATE
       AND A~FLD_13      >= @IV_DATE.
*-- 적용여부 결과 리턴
    IF SY-SUBRC EQ 0.
      EV_ACTIVE = 'Y'.
    ELSE.
      EV_ACTIVE = 'N'.
    ENDIF.


  ENDMETHOD.


  METHOD CONV_COLUMN_TO_I.

    DATA : LV_INPUT       TYPE STRING,
           LV_CC          TYPE C VALUE '',
           LV_STRL        TYPE I,
           LV_CNT         TYPE I VALUE 0,
           LV_ASCII_VAL   TYPE I,
           LV_ASCII_VAL_A TYPE I.

    DATA LV_COL_NUM TYPE I.

    MOVE IV_FLD TO LV_INPUT.

    LV_ASCII_VAL_A = CL_ABAP_CONV_OUT_CE=>UCCP( 'A' ).
    TRANSLATE LV_INPUT TO UPPER CASE.
    LV_STRL = STRLEN( LV_INPUT ) - 1.

    WHILE LV_STRL >= 0.
      LV_CC = LV_INPUT+LV_CNT(1).
      LV_ASCII_VAL = CL_ABAP_CONV_OUT_CE=>UCCP( LV_CC ).
      IF LV_CC >= 'A' AND LV_CC <= 'Z'.
        LV_COL_NUM = LV_COL_NUM + ( LV_ASCII_VAL - LV_ASCII_VAL_A + 1 ) * 26 ** LV_STRL .
        LV_CNT = LV_CNT + 1.
        LV_STRL = LV_STRL - 1 .
      ELSE.
        LV_COL_NUM = 0.
        EXIT.
      ENDIF.
    ENDWHILE.

    MOVE LV_COL_NUM TO EV_COL_NUM.

  ENDMETHOD.


  METHOD CONV_CURR_INPUT.

    DATA : LV_CURR_INPUT  TYPE STRING,
           LV_CURR_OUTPUT TYPE C LENGTH 30.

    CHECK CV_INPUT IS NOT INITIAL.

    LV_CURR_INPUT = CV_INPUT.

*.- Read ½ÊÁø¼ö Çü½Ä
*     1.234.567,89
*  X  1,234,567.89
*  Y  1 234 567,89
    SELECT SINGLE DCPFM INTO @DATA(LV_DCPFM)
      FROM USR01
     WHERE BNAME EQ @SY-UNAME.

    CASE LV_DCPFM.
      WHEN SPACE.
        REPLACE ALL OCCURRENCES OF GC_POINT IN LV_CURR_INPUT WITH SPACE.
        REPLACE ALL OCCURRENCES OF GC_COMMA IN LV_CURR_INPUT WITH GC_POINT.
      WHEN GC_X.
        REPLACE ALL OCCURRENCES OF GC_COMMA IN LV_CURR_INPUT WITH SPACE.
      WHEN GC_Y.
        REPLACE ALL OCCURRENCES OF GC_COMMA IN LV_CURR_INPUT WITH GC_POINT.
    ENDCASE.

    CONDENSE LV_CURR_INPUT NO-GAPS.


    IF NOT LV_CURR_INPUT CO GC_NUMERIC. "'0123456789-. '.
      RAISE NOT_NUMERIC.
    ENDIF.

    WRITE LV_CURR_INPUT TO LV_CURR_OUTPUT  LEFT-JUSTIFIED.
    CONDENSE LV_CURR_OUTPUT NO-GAPS.

    IF LV_CURR_OUTPUT EQ GC_MINUS. "'-'.
      LV_CURR_OUTPUT = '0'.
    ENDIF.

    CV_INPUT = LV_CURR_OUTPUT.

  ENDMETHOD.


  METHOD CONV_DATE_INPUT.

    DATA : LV_DATUM_INPUT  TYPE C LENGTH 50,
           LV_DATUM_OUTPUT TYPE SY-DATUM.

    IF CV_INPUT IS INITIAL.
      CV_INPUT = '00000000'.
      EXIT.
    ENDIF.

    LV_DATUM_INPUT = CV_INPUT.

    REPLACE ALL OCCURRENCES OF GC_POINT IN LV_DATUM_INPUT WITH ABAP_FALSE. ".
    REPLACE ALL OCCURRENCES OF GC_COMMA IN LV_DATUM_INPUT WITH ABAP_FALSE. ",
    REPLACE ALL OCCURRENCES OF GC_MINUS IN LV_DATUM_INPUT WITH ABAP_FALSE. "-
    REPLACE ALL OCCURRENCES OF GC_SLASH IN LV_DATUM_INPUT WITH ABAP_FALSE. "/

    CALL FUNCTION 'CONVERT_DATE_INPUT'
      EXPORTING
        INPUT                     = LV_DATUM_INPUT
        PLAUSIBILITY_CHECK        = ABAP_TRUE
      IMPORTING
        OUTPUT                    = LV_DATUM_OUTPUT
      EXCEPTIONS
        PLAUSIBILITY_CHECK_FAILED = 1
        WRONG_FORMAT_IN_INPUT     = 2.

    IF SY-SUBRC NE 0.
      CV_INPUT = SPACE.
    ELSE.
      CV_INPUT = LV_DATUM_OUTPUT.
    ENDIF.

  ENDMETHOD.


  METHOD CONV_TIME_INPUT.

    DATA : LV_TIME_INPUT  TYPE C LENGTH 50,
           LV_TIME_OUTPUT TYPE SY-UZEIT.

    CHECK CV_INPUT IS NOT INITIAL.

    LV_TIME_INPUT = CV_INPUT.
    REPLACE ALL OCCURRENCES OF GC_COLON IN LV_TIME_INPUT WITH ABAP_FALSE. ":
    REPLACE ALL OCCURRENCES OF GC_POINT IN LV_TIME_INPUT WITH ABAP_FALSE. ".
    REPLACE ALL OCCURRENCES OF GC_SLASH IN LV_TIME_INPUT WITH ABAP_FALSE. "/
    REPLACE ALL OCCURRENCES OF GC_COMMA IN LV_TIME_INPUT WITH ABAP_FALSE. ",
    REPLACE ALL OCCURRENCES OF GC_MINUS IN LV_TIME_INPUT WITH ABAP_FALSE. "-

    CALL FUNCTION 'CONVERT_TIME_INPUT'
      EXPORTING
        INPUT                     = LV_TIME_INPUT
        PLAUSIBILITY_CHECK        = ABAP_TRUE
      IMPORTING
        OUTPUT                    = LV_TIME_OUTPUT
      EXCEPTIONS
        PLAUSIBILITY_CHECK_FAILED = 1
        WRONG_FORMAT_IN_INPUT     = 2.

    IF SY-SUBRC NE 0.
      CV_INPUT = SPACE.
    ELSE.
      CV_INPUT = LV_TIME_OUTPUT.
    ENDIF.

  ENDMETHOD.


  METHOD CONV_TIME_ZONE.

    CONSTANTS: LC_KOREA   TYPE TZNZONE VALUE 'KOREA'.


    CLEAR: EV_DATE, EV_TIME.

***    SELECT SINGLE TZONESYS INTO @DATA(LV_TZONE_SYS)
***      FROM TTZCU.
    DATA(LV_TZONE_SYS) = LC_KOREA.

    IF IV_TZONE_LO IS INITIAL.
      SELECT SINGLE TZONE INTO @DATA(LV_TZONE_LO)
        FROM USR02
       WHERE BNAME EQ @SY-UNAME.
    ELSE.
      LV_TZONE_LO = IV_TZONE_LO.
    ENDIF.


    CASE IV_CONVTY.
      WHEN GC_S. "Local System Time  -> 본사 System Time
*.-     Local System 시간을 UTC로 변경
        CONVERT DATE IV_DATE TIME IV_TIME
                INTO TIME STAMP DATA(LV_TIMESTAMP) TIME ZONE LV_TZONE_LO.

*.-     UTC 시간을 본사 System 시간으로 변경
        CONVERT TIME STAMP LV_TIMESTAMP TIME ZONE LV_TZONE_SYS
                INTO DATE EV_DATE TIME EV_TIME.

      WHEN GC_L. "본사 System Time -> Local System Time
*.-     본사 System 시간을 UTC로 변경
        CONVERT DATE IV_DATE TIME IV_TIME
                INTO TIME STAMP LV_TIMESTAMP TIME ZONE LV_TZONE_SYS.

*.-     UTC 시간을 Local System 시간으로 변경
        CONVERT TIME STAMP LV_TIMESTAMP TIME ZONE LV_TZONE_LO
                INTO DATE EV_DATE TIME EV_TIME.
    ENDCASE.

  ENDMETHOD.


  METHOD DISPLAY_MESSAGE.

    CHECK IT_BAPIRET2[] IS NOT INITIAL.

    DATA(LV_TITLE) = COND #( WHEN IV_TITLE IS INITIAL THEN CONV LVC_TITLE( TEXT-M02 ) ELSE IV_TITLE ).

    CALL FUNCTION 'SU2X_SHOW_MSG'
      EXPORTING
        IT_LOG   = IT_BAPIRET2
        ID_TITLE = LV_TITLE.

  ENDMETHOD.


  METHOD EXCEL_DOWNLOAD.

    DATA: LV_XML      TYPE XSTRING,
          LV_DEF_PATH TYPE STRING.


    CLEAR EV_FILENAME.

*.- Transforms According to Defined XML Version
    CALL METHOD CL_SALV_BS_TT_UTIL=>IF_SALV_BS_TT_UTIL~TRANSFORM
      EXPORTING
        XML_TYPE      = IV_XML_TYPE
        XML_VERSION   = IV_XML_VERSION
        R_RESULT_DATA = CL_SALV_EX_UTIL=>FACTORY_RESULT_DATA_TABLE( R_DATA         = REF #( IT_DATA )
                                                                    T_FIELDCATALOG = IT_FCAT )
        XML_FLAVOUR   = IF_SALV_BS_C_TT=>C_TT_XML_FLAVOUR_EXPORT
        GUI_TYPE      = IF_SALV_BS_XML=>C_GUI_TYPE_GUI
      IMPORTING
        XML           = LV_XML.

*   Returns the Current Directory
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
      CHANGING
        CURRENT_DIRECTORY = LV_DEF_PATH.

    DATA(LV_DEF_FNAME) = IV_DEF_FNAME.
    TRANSLATE LV_DEF_FNAME TO UPPER CASE.
    FIND FIRST OCCURRENCE OF `XLS` IN LV_DEF_FNAME.
    IF SY-SUBRC NE 0.
      IV_DEF_FNAME = |{ IV_DEF_FNAME }.xlsx|.
    ENDIF.


*.- Download File
***    CALL FUNCTION 'XML_EXPORT_DIALOG'
***      EXPORTING
***        I_XML                      = LV_XML
***        I_DEFAULT_EXTENSION        = CONV STRING( GC_XLSX )
***        I_INITIAL_DIRECTORY        = LV_DEF_PATH
***        I_DEFAULT_FILE_NAME        = IV_DEF_FNAME
***        I_MASK                     = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
***      EXCEPTIONS
***        APPLICATION_NOT_EXECUTABLE = 1
***        OTHERS                     = 2.

*.- Download File
*   파일열기가 기본 옵션이어서 로직 변경.
    DATA: LV_LENGTH      TYPE I,
          LV_FILENAME    TYPE STRING,
          LV_APPL_PARA   TYPE STRING,
          LV_XML_STREAM  TYPE XML_RAWDATA,
          LV_LOC_FN      TYPE STRING,
          LV_LOC_DIR     TYPE STRING,
          LV_USER_ACTION TYPE I.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
      EXPORTING
*       WINDOW_TITLE         = S_TITLE
        DEFAULT_EXTENSION    = CONV STRING( GC_XLSX )
        DEFAULT_FILE_NAME    = IV_DEF_FNAME
        FILE_FILTER          = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
        INITIAL_DIRECTORY    = LV_DEF_PATH
      CHANGING
        FILENAME             = LV_LOC_FN
        PATH                 = LV_LOC_DIR
        FULLPATH             = LV_LOC_DIR
        USER_ACTION          = LV_USER_ACTION
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        NOT_SUPPORTED_BY_GUI = 3
        OTHERS               = 4.

    IF SY-SUBRC NE 0.
      MESSAGE E162(ALVHT).
      EXIT.
    ENDIF.

    IF LV_USER_ACTION EQ CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL .
      MESSAGE S161(ALVHT).
      EXIT.
    ENDIF.

    CONCATENATE LV_LOC_DIR LV_LOC_FN INTO LV_FILENAME.
    EV_FILENAME = LV_FILENAME.


    CHECK LV_FILENAME IS NOT INITIAL.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        BUFFER        = LV_XML
      IMPORTING
        OUTPUT_LENGTH = LV_LENGTH
      TABLES
        BINARY_TAB    = LV_XML_STREAM.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
      EXPORTING
        BIN_FILESIZE = LV_LENGTH
        FILETYPE     = 'BIN'
        FILENAME     = LV_FILENAME
      CHANGING
        DATA_TAB     = LV_XML_STREAM
      EXCEPTIONS
        OTHERS       = 1.

    IF IV_OPERATION IS NOT INITIAL.
      CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
        EXPORTING
          DOCUMENT               = LV_FILENAME
          OPERATION              = IV_OPERATION   "'OPEN'
        EXCEPTIONS
          CNTL_ERROR             = 1
          ERROR_NO_GUI           = 2
          BAD_PARAMETER          = 3
          FILE_NOT_FOUND         = 4
          PATH_NOT_FOUND         = 5
          FILE_EXTENSION_UNKNOWN = 6
          ERROR_EXECUTE_FAILED   = 7
          SYNCHRONOUS_FAILED     = 8
          NOT_SUPPORTED_BY_GUI   = 9
          OTHERS                 = 10.
      IF SY-SUBRC NE 0.
        MESSAGE I000(0K) WITH |Application not executable!| |(sy-subrc : { SY-SUBRC })|. "#EC NOTEXT
        EXIT.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD EXCEL_OLE_STANDART_DAT.

    CALL FUNCTION 'EXCEL_OLE_STANDARD_DAT'
      EXPORTING
        FILE_NAME                 = IV_FNAME
      TABLES
        DATA_TAB                  = IT_DATA
        FIELDNAMES                = IT_FIELD
      EXCEPTIONS
        FILE_NOT_EXIST            = 1
        FILENAME_EXPECTED         = 2
        COMMUNICATION_ERROR       = 3
        OLE_OBJECT_METHOD_ERROR   = 4
        OLE_OBJECT_PROPERTY_ERROR = 5
        INVALID_PIVOT_FIELDS      = 6
        DOWNLOAD_PROBLEM          = 7
        OTHERS                    = 8.

    IF SY-SUBRC EQ 0.
      MESSAGE S055.
    ELSE.
      MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
                          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                          DISPLAY LIKE GC_E.
    ENDIF.

  ENDMETHOD.


  METHOD EXCEL_UPLOAD.

    DATA: LO_NEW_LINE TYPE REF TO DATA,
          LO_STRU_REF TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_TAB_REF  TYPE REF TO CL_ABAP_TABLEDESCR.

    DATA: LV_START_COL  TYPE INT4,
          LV_START_ROW  TYPE INT4 VALUE '2',
          LV_END_COL    TYPE INT4 VALUE '256',
          LV_END_ROW    TYPE INT4 VALUE '262144',           "'131072',
          LT_EXECL_LINE TYPE KCDE_SENDER,
          LV_SEPARATOR  TYPE C.

    DATA: BEGIN OF LS_LINE_COL,
            FIELD(1024),
          END OF LS_LINE_COL.
    DATA: LT_EXCEL_COL LIKE TABLE OF LS_LINE_COL.


    CLEAR: ET_TABLE[], EV_ERROR.

*   Header line 수
    LV_START_ROW = IV_HEADER_CNT + 1. "Header Line + 1

*   시작 Column
    LV_START_COL = IV_START_COL.

*   종료 행
    IF IV_END_ROW NE 0.
      LV_END_ROW = COND #( WHEN IV_END_ROW GT LV_END_ROW THEN LV_END_ROW ELSE IV_END_ROW ).
    ELSE.
      CLEAR LV_END_ROW.
    ENDIF.

*   Column 수
    LO_TAB_REF  ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( ET_TABLE ).
    LO_STRU_REF ?= LO_TAB_REF->GET_TABLE_LINE_TYPE( ).
    LV_END_COL = COND #( WHEN IV_COLUMN_CNT EQ 0 THEN LINES( LO_STRU_REF->COMPONENTS ) ELSE IV_COLUMN_CNT ).

*   EXCEL FILE UPLOAD.
    CALL FUNCTION 'ZGTSD_EXCEL_UPLOAD'
      EXPORTING
        IV_FILENAME             = CONV STRING( IV_FILENAME )
        IV_BEGIN_COL            = LV_START_COL
        IV_BEGIN_ROW            = LV_START_ROW
        IV_END_COL              = LV_END_COL
        IV_END_ROW              = LV_END_ROW
        IV_FIRST_SHEET          = IV_FIRST_SHEET
        IV_SHEET_NO             = IV_SHEET_NO
      IMPORTING
        EV_SEPARATOR            = LV_SEPARATOR
      TABLES
        ET_EXCEL_TAB            = LT_EXECL_LINE
      EXCEPTIONS
        INCONSISTENT_PARAMETERS = 1
        UPLOAD_OLE              = 2
        OTHERS                  = 3.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        MESSAGE I006 WITH TEXT-F03 DISPLAY LIKE GC_E.
        EXIT.
      WHEN 2.
        MESSAGE I098 DISPLAY LIKE GC_E.
        EV_ERROR = GC_X.  EXIT.
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE GC_I NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                   DISPLAY LIKE GC_E.
        EXIT.
    ENDCASE.

    CHECK LT_EXECL_LINE[] IS NOT INITIAL.

    CREATE DATA LO_NEW_LINE  LIKE LINE OF ET_TABLE.
    ASSIGN LO_NEW_LINE->* TO FIELD-SYMBOL(<LS_WORK>).
    DATA(LT_COMP) = LO_STRU_REF->GET_COMPONENTS( ).

    LOOP AT LT_EXECL_LINE INTO DATA(LS_LINE).

      TRY.
          CHECK LS_LINE IS NOT INITIAL.

          CLEAR LT_EXCEL_COL[].
          SPLIT LS_LINE-LINE AT LV_SEPARATOR INTO TABLE LT_EXCEL_COL.

          CLEAR <LS_WORK>.
          LOOP AT LT_EXCEL_COL INTO LS_LINE_COL.
            DATA(LV_TABIX) = SY-TABIX.

            ASSIGN COMPONENT LV_TABIX OF STRUCTURE <LS_WORK> TO FIELD-SYMBOL(<LV_FIELD>).
            CHECK SY-SUBRC EQ 0.

            DATA(LV_NAME) = LT_COMP[ LV_TABIX ]-NAME.   " ← 필드 이름

            DESCRIBE FIELD <LV_FIELD> TYPE DATA(LV_TYPE).

            CASE LV_TYPE.
              WHEN GC_D. " DATE.
                ZGTSD_CL_COMMON=>CONV_DATE_INPUT( CHANGING CV_INPUT = LS_LINE_COL-FIELD ).
                <LV_FIELD> = LS_LINE_COL-FIELD.

              WHEN GC_T. " TIME
                ZGTSD_CL_COMMON=>CONV_TIME_INPUT( CHANGING CV_INPUT = LS_LINE_COL-FIELD ).
                <LV_FIELD> = LS_LINE_COL-FIELD.

              WHEN GC_I  OR GC_P OR GC_N OR
                   GC_SB OR GC_SS. " 숫자인 경우..
                ZGTSD_CL_COMMON=>CONV_CURR_INPUT( CHANGING   CV_INPUT    = LS_LINE_COL-FIELD
                                                EXCEPTIONS NOT_NUMERIC = 1 ).
                IF SY-SUBRC EQ 0.
                  <LV_FIELD> = LS_LINE_COL-FIELD.
                ELSE.
                  ASSIGN COMPONENT 'ERR_MSG' OF STRUCTURE <LS_WORK> TO FIELD-SYMBOL(<LV_MSG>).
                  IF SY-SUBRC EQ 0.
*                <LV_FIELD> = LS_LINE_COL-FIELD.
                    MESSAGE S041 WITH LS_LINE_COL-FIELD INTO <LV_MSG>.
                  ENDIF.
                ENDIF.

              WHEN GC_X. "RAW
                <LV_FIELD> = LS_LINE_COL-FIELD.

              WHEN GC_SG.
                IF LS_LINE_COL-FIELD IS INITIAL.
                  CLEAR <LV_FIELD>.

                ELSE.
                  IF <LV_FIELD> IS INITIAL.
                    IF LS_LINE_COL-FIELD(1) EQ GC_QUOTA. "'"'.
                      LS_LINE_COL-FIELD(1) = SPACE.
                    ENDIF.
                    DATA(LV_LEN) = STRLEN( LS_LINE_COL-FIELD ).
                    LV_LEN = LV_LEN - 1.
                    IF LS_LINE_COL-FIELD+LV_LEN(1) EQ GC_QUOTA.
                      LS_LINE_COL-FIELD+LV_LEN(1) = SPACE.
                    ENDIF.
                    CONDENSE LS_LINE_COL-FIELD.
                    <LV_FIELD> = LS_LINE_COL-FIELD.
                  ENDIF.
                ENDIF.

              WHEN OTHERS.
                IF LS_LINE_COL-FIELD IS INITIAL.
                  CASE LV_NAME.
                    WHEN 'ERR_MSG'.
                    WHEN OTHERS.
                      CLEAR <LV_FIELD>.
                  ENDCASE.
                ELSE.
                  IF <LV_FIELD> IS INITIAL.
                    SHIFT LS_LINE_COL-FIELD LEFT DELETING LEADING SPACE.
                    WRITE LS_LINE_COL-FIELD TO <LV_FIELD> LEFT-JUSTIFIED.

                    IF IV_UPPERCASE EQ GC_X.
                      TRANSLATE <LV_FIELD> TO UPPER CASE.
                    ENDIF.
                  ENDIF.
                ENDIF.
            ENDCASE.

          ENDLOOP.

        CATCH CX_ROOT INTO DATA(LO_ROOT).
          DATA(LV_MSG) = LO_ROOT->GET_TEXT( ).
          ASSIGN COMPONENT 'ERR_MSG' OF STRUCTURE <LS_WORK> TO <LV_MSG>.
          IF SY-SUBRC EQ 0.
            <LV_MSG> = LV_MSG.
          ENDIF.
      ENDTRY.

      CHECK <LS_WORK> IS NOT INITIAL.

      APPEND <LS_WORK> TO ET_TABLE.

    ENDLOOP.

  ENDMETHOD.


  METHOD EXCEL_WEB_UPLOAD.

    DATA: LO_NEW_LINE TYPE REF TO DATA,
          LO_STRU_REF TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_TAB_REF  TYPE REF TO CL_ABAP_TABLEDESCR.

    DATA: LV_START_COL  TYPE INT4,
          LV_START_ROW  TYPE INT4 VALUE '2',
          LV_END_COL    TYPE INT4 VALUE '256',
          LV_END_ROW    TYPE INT4 VALUE '262144',           "'131072',
          LT_EXECL_LINE TYPE KCDE_SENDER,
          LV_SHEET_NO   TYPE INT1,
          LV_SEPARATOR  TYPE C.

    DATA : LT_FILE_TABLE TYPE FILETABLE,
           LV_RC         TYPE I,
           LT_DATA_TAB   TYPE SOLIX_TAB.

    DATA: BEGIN OF LS_LINE_COL,
            FIELD(1024),
          END OF LS_LINE_COL.
    DATA: LT_EXCEL_COL LIKE TABLE OF LS_LINE_COL.
    FIELD-SYMBOLS <LFT_XLS> TYPE STANDARD TABLE.

    CLEAR: ET_TABLE[], EV_ERROR.

*   Header line 수
    LV_START_ROW = IV_HEADER_CNT. "Header Line + 1

*   시작 Column
    LV_START_COL = IV_START_COL.

*   종료 행
    IF IV_END_ROW NE 0.
      LV_END_ROW = COND #( WHEN IV_END_ROW GT LV_END_ROW THEN LV_END_ROW ELSE IV_END_ROW ).
    ELSE.
      CLEAR LV_END_ROW.
    ENDIF.

    IF IV_SHEET_NO GT 0.
      LV_SHEET_NO = IV_SHEET_NO. "시트
    ELSE.
      IF IV_FIRST_SHEET EQ ABAP_TRUE.
        LV_SHEET_NO = 1.
      ENDIF.
    ENDIF.

*   Column 수
    LO_TAB_REF  ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( ET_TABLE ).
    LO_STRU_REF ?= LO_TAB_REF->GET_TABLE_LINE_TYPE( ).
    LV_END_COL = COND #( WHEN IV_COLUMN_CNT EQ 0 THEN LINES( LO_STRU_REF->COMPONENTS ) ELSE IV_COLUMN_CNT ).

    CREATE DATA LO_NEW_LINE LIKE LINE OF ET_TABLE.
    ASSIGN LO_NEW_LINE->* TO FIELD-SYMBOL(<LS_WORK>).

*스트럭처에 필드 메세지 필드는 전체 컬럼수에서 제외 한다.
    ASSIGN COMPONENT 'ERR_MSG' OF STRUCTURE <LS_WORK> TO FIELD-SYMBOL(<LV_ECOL>).
    IF SY-SUBRC EQ 0.
      IF IV_COLUMN_CNT IS NOT INITIAL.
        IF IV_COLUMN_CNT = LINES( LO_STRU_REF->COMPONENTS ).
          LV_END_COL = LV_END_COL - 1.
        ENDIF.
      ELSE.
        LV_END_COL = LV_END_COL - 1.
      ENDIF.
    ENDIF.

    "파일 업로드
    CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD(
      EXPORTING
        FILENAME                = CONV #( IV_FILENAME )
        FILETYPE                = 'BIN'    " File Type (ASCII, Binary)
      IMPORTING
        FILELENGTH              = DATA(LV_LENGTH)
      CHANGING
        DATA_TAB                = LT_DATA_TAB
      EXCEPTIONS
        FILE_OPEN_ERROR         = 1
        FILE_READ_ERROR         = 2
        NO_BATCH                = 3
        GUI_REFUSE_FILETRANSFER = 4
        INVALID_TYPE            = 5
        NO_AUTHORITY            = 6
        UNKNOWN_ERROR           = 7
        BAD_DATA_FORMAT         = 8
        HEADER_NOT_ALLOWED      = 9
        SEPARATOR_NOT_ALLOWED   = 10
        HEADER_TOO_LONG         = 11
        UNKNOWN_DP_ERROR        = 12
        ACCESS_DENIED           = 13
        DP_OUT_OF_MEMORY        = 14
        DISK_FULL               = 15
        DP_TIMEOUT              = 16
        NOT_SUPPORTED_BY_GUI    = 17
        ERROR_NO_GUI            = 18
        OTHERS                  = 19
    ).
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE GC_I NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                 DISPLAY LIKE GC_E.
      EV_ERROR = GC_X.  EXIT.
    ENDIF.

    TRY.
        DATA(LV_XSTRING) = CL_BCS_CONVERT=>SOLIX_TO_XSTRING( LT_DATA_TAB ).
        DATA(LO_EXCEL_REF) = NEW CL_FDT_XL_SPREADSHEET( DOCUMENT_NAME = CONV #( IV_FILENAME )
                                                        XDOCUMENT     = LV_XSTRING ) .

        "GET LIST OF WORKSHEETS
        LO_EXCEL_REF->IF_FDT_DOC_SPREADSHEET~GET_WORKSHEET_NAMES(
          IMPORTING
            WORKSHEET_NAMES = DATA(LT_WORKSHEETS) ).

      CATCH CX_ROOT INTO DATA(LO_ERR).
        MESSAGE I000 WITH '엑셀파일 읽는중 오류가 발생했습니다.' DISPLAY LIKE ZGTSD_E.
        EV_ERROR = 'X'. EXIT.
    ENDTRY .

    CHECK LT_WORKSHEETS IS NOT INITIAL.

    TRY.
        DATA(LO_DATA_REF) = LO_EXCEL_REF->IF_FDT_DOC_SPREADSHEET~GET_ITAB_FROM_WORKSHEET(
                                                 WORKSHEET_NAME = LT_WORKSHEETS[ LV_SHEET_NO ] ).
      CATCH CX_ROOT INTO LO_ERR.
        MESSAGE I000 WITH '엑셀파일 읽는중 오류가 발생했습니다.' DISPLAY LIKE ZGTSD_E.
        EV_ERROR = 'X'. EXIT.
    ENDTRY.

    ASSIGN LO_DATA_REF->* TO <LFT_XLS>.
    DATA(LT_DFIES) = CL_SALV_DDIC=>GET_BY_DATA( <LFT_XLS> ).
    DATA LV_COL_NUM TYPE I.
    DATA(LT_COMP) = LO_STRU_REF->GET_COMPONENTS( ).

    LOOP AT <LFT_XLS> ASSIGNING FIELD-SYMBOL(<LFS_XLS>).

      IF SY-TABIX <= LV_START_ROW.
        CONTINUE.
      ENDIF.

      CLEAR <LS_WORK>.
      LOOP AT LT_DFIES INTO DATA(LS_DFIES).

        ASSIGN COMPONENT LS_DFIES-FIELDNAME OF STRUCTURE <LFS_XLS> TO FIELD-SYMBOL(<LFV_XLS>).
        CHECK SY-SUBRC = 0.

        ZGTSD_CL_COMMON=>CONV_COLUMN_TO_I( EXPORTING IV_FLD = LS_DFIES-FIELDNAME
                                            CHANGING EV_COL_NUM = LV_COL_NUM ).

*컬럼 한계지정
        CHECK LV_COL_NUM <= LV_END_COL.

        ASSIGN COMPONENT LV_COL_NUM OF STRUCTURE <LS_WORK> TO FIELD-SYMBOL(<LFV_ITAB>).
        CHECK SY-SUBRC = 0.
        DATA(LV_NAME) = LT_COMP[ LV_COL_NUM ]-NAME.   " ← 필드 이름

        IF <LFV_XLS> IS ASSIGNED AND <LFV_ITAB> IS ASSIGNED.
          DESCRIBE FIELD <LFV_ITAB> TYPE DATA(LV_TYPE).

          CASE LV_TYPE.

            WHEN GC_D. " DATE.
              ZGTSD_CL_COMMON=>CONV_DATE_INPUT( CHANGING CV_INPUT = <LFV_XLS> ).
              <LFV_ITAB> = <LFV_XLS>.

            WHEN GC_T. " TIME
              ZGTSD_CL_COMMON=>CONV_TIME_INPUT( CHANGING CV_INPUT = <LFV_XLS> ).
              <LFV_ITAB> = <LFV_XLS>.

            WHEN GC_I  OR GC_P OR GC_N OR
                 GC_SB OR GC_SS. " 숫자인 경우..
              ZGTSD_CL_COMMON=>CONV_CURR_INPUT( CHANGING   CV_INPUT    = <LFV_XLS>
                                              EXCEPTIONS NOT_NUMERIC = 1 ).
              IF SY-SUBRC EQ 0.
                <LFV_ITAB> = <LFV_XLS>.
              ELSE.
                ASSIGN COMPONENT 'ERR_MSG' OF STRUCTURE <LS_WORK> TO FIELD-SYMBOL(<LV_MSG>).
                IF SY-SUBRC EQ 0.
*                <LFV_ITAB> = <LFV_XLS>.
                  MESSAGE S041 WITH <LFV_XLS> INTO <LV_MSG>.
                ENDIF.
              ENDIF.

            WHEN GC_X. "RAW
              <LFV_ITAB> = <LFV_XLS>.

            WHEN GC_SG.
              IF <LFV_XLS> IS INITIAL.
                CLEAR <LFV_ITAB>.

              ELSE.
                IF <LFV_ITAB> IS INITIAL.
                  IF <LFV_XLS>(1) EQ GC_QUOTA. "'"'.
                    <LFV_XLS>(1) = SPACE.
                  ENDIF.
                  DATA(LV_LEN) = STRLEN( <LFV_XLS> ).
                  LV_LEN = LV_LEN - 1.
                  IF <LFV_XLS>+LV_LEN(1) EQ GC_QUOTA.
                    <LFV_XLS>+LV_LEN(1) = SPACE.
                  ENDIF.
                  CONDENSE <LFV_XLS>.
                  <LFV_ITAB> = <LFV_XLS>.
                ENDIF.
              ENDIF.

            WHEN OTHERS.
              IF <LFV_XLS> IS INITIAL.
                CASE LV_NAME.
                  WHEN 'ERR_MSG'.
                  WHEN OTHERS.
                    CLEAR <LFV_ITAB>.
                ENDCASE.

              ELSE.
                IF <LFV_ITAB> IS INITIAL.
                  SHIFT <LFV_XLS> LEFT DELETING LEADING SPACE.
                  WRITE <LFV_XLS> TO <LFV_ITAB> LEFT-JUSTIFIED.

                  IF IV_UPPERCASE EQ GC_X.
                    TRANSLATE <LFV_ITAB> TO UPPER CASE.
                  ENDIF.
                ENDIF.
              ENDIF.
          ENDCASE.

        ENDIF.

      ENDLOOP.

      CHECK <LS_WORK> IS NOT INITIAL.
      APPEND <LS_WORK> TO ET_TABLE.
    ENDLOOP.

  ENDMETHOD.


  METHOD F4_ALV_VARIANT.

    DATA: LV_EXIT    TYPE CHAR1,
          LS_VARIANT TYPE DISVARIANT.


    CLEAR RV_VARIANT.

    LS_VARIANT-REPORT    = IV_REPID.
    LS_VARIANT-HANDLE    = IV_HANDLE.
    LS_VARIANT-USERNAME  = COND #( WHEN IV_UNAME IS INITIAL THEN SY-UNAME ELSE IV_UNAME ).

    CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
      EXPORTING
        IS_VARIANT = LS_VARIANT
        I_SAVE     = 'A'
      IMPORTING
        E_EXIT     = LV_EXIT
        ES_VARIANT = LS_VARIANT
      EXCEPTIONS
        OTHERS     = 2.

    IF SY-SUBRC EQ 2.
      MESSAGE ID SY-MSGID TYPE GC_I      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      IF LV_EXIT EQ SPACE.
        RV_VARIANT = LS_VARIANT-VARIANT.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD FILE_CHECK.

    DATA: LV_RESULT TYPE CHAR1.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
      EXPORTING
        FILE                 = IV_FILENAME
      RECEIVING
        RESULT               = LV_RESULT
      EXCEPTIONS
        CNTL_ERROR           = 1      " Control error
        ERROR_NO_GUI         = 2      " Error: No GUI
        WRONG_PARAMETER      = 3      " Incorrect parameter
        NOT_SUPPORTED_BY_GUI = 4.     " GUI does not support this

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE SY-MSGTY.
      RV_RESULT = GC_E.
    ENDIF.

    IF LV_RESULT EQ GC_X.
      RV_RESULT = GC_S.
    ELSE.
      MESSAGE S127(FR) DISPLAY LIKE GC_E.
      RV_RESULT = GC_E.
    ENDIF.

  ENDMETHOD.


  METHOD FILE_GET_SIZE.

    CLEAR RV_FSIZE.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_GET_SIZE
      EXPORTING
        FILE_NAME            = CONV STRING( IV_FNAME )
      IMPORTING
        FILE_SIZE            = RV_FSIZE
      EXCEPTIONS
        FILE_GET_SIZE_FAILED = 1
        CNTL_ERROR           = 2
        ERROR_NO_GUI         = 3
        NOT_SUPPORTED_BY_GUI = 4
        OTHERS               = 5.

    CHECK SY-SUBRC EQ 0.

    CALL METHOD CL_GUI_CFW=>FLUSH.

    RV_FSIZE = RV_FSIZE / 1024.

  ENDMETHOD.


  METHOD FILE_OPEN_DIALOG.

    DATA: LV_DEF_PATH TYPE STRING,
          LV_RC       TYPE I,
          LT_FILE_TAB TYPE FILETABLE,
          LV_TITLE    TYPE STRING.


    CLEAR: RV_FNAME.

****   Finding desktop
***    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
***      CHANGING
***        DESKTOP_DIRECTORY    = LV_DEF_PATH
***      EXCEPTIONS
***        CNTL_ERROR           = 1
***        ERROR_NO_GUI         = 2
***        NOT_SUPPORTED_BY_GUI = 3
***        OTHERS               = 4.
***    IF SY-SUBRC NE 0.
***      MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
***                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE SY-MSGTY.
***      RETURN.
***    ENDIF.

****   Update View
***    CALL METHOD CL_GUI_CFW=>UPDATE_VIEW
***      EXCEPTIONS
***        CNTL_SYSTEM_ERROR = 1
***        CNTL_ERROR        = 2
***        OTHERS            = 3.

*   Returns the Current Directory
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
      CHANGING
        CURRENT_DIRECTORY = LV_DEF_PATH.

*   Open Fiile dialog.
    LV_TITLE = TEXT-M01.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
      EXPORTING
        WINDOW_TITLE            = LV_TITLE "'Select Open File'
        DEFAULT_EXTENSION       = IV_FILTER "CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
        FILE_FILTER             = IV_FILTER "CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
        INITIAL_DIRECTORY       = LV_DEF_PATH
      CHANGING
        FILE_TABLE              = LT_FILE_TAB
        RC                      = LV_RC
      EXCEPTIONS
        FILE_OPEN_DIALOG_FAILED = 1
        CNTL_ERROR              = 2
        ERROR_NO_GUI            = 3
        NOT_SUPPORTED_BY_GUI    = 4
        OTHERS                  = 5.
    IF SY-SUBRC NE  0.
      MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE SY-MSGTY.
      RETURN.
    ENDIF.

    IF LV_RC EQ 0.
      MESSAGE I050. " '작업이 취소되었습니다.'.
      RETURN.
    ENDIF.

    READ TABLE LT_FILE_TAB INTO DATA(LS_FILE) INDEX 1.
    IF SY-SUBRC EQ 0.
      RV_FNAME = LS_FILE-FILENAME.
    ENDIF.

  ENDMETHOD.


  METHOD FILE_OPEN_DIALOG2.
    DATA: LV_DEF_PATH TYPE STRING,
          LV_RC       TYPE I,
          LT_FILE_TAB TYPE FILETABLE,
          LV_TITLE    TYPE STRING.


    CLEAR: RT_FNAME[].

*   Returns the Current Directory
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
      CHANGING
        CURRENT_DIRECTORY = LV_DEF_PATH.

*   Open Fiile dialog.
    LV_TITLE = TEXT-M01.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
      EXPORTING
        WINDOW_TITLE            = LV_TITLE "'Select Open File'
        DEFAULT_EXTENSION       = IV_FILTER "CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
        FILE_FILTER             = IV_FILTER "CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
        INITIAL_DIRECTORY       = LV_DEF_PATH
        MULTISELECTION          = GC_X
      CHANGING
        FILE_TABLE              = LT_FILE_TAB
        RC                      = LV_RC
      EXCEPTIONS
        FILE_OPEN_DIALOG_FAILED = 1
        CNTL_ERROR              = 2
        ERROR_NO_GUI            = 3
        NOT_SUPPORTED_BY_GUI    = 4
        OTHERS                  = 5.
    IF SY-SUBRC NE  0.
      MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE SY-MSGTY.
      RETURN.
    ENDIF.

    IF LV_RC EQ 0.
      MESSAGE I050. " '작업이 취소되었습니다.'.
      RETURN.
    ENDIF.

    LOOP AT LT_FILE_TAB INTO DATA(LS_FILE).
      APPEND LS_FILE-FILENAME TO RT_FNAME.
    ENDLOOP.

  ENDMETHOD.


  METHOD FILE_SAVE_DIALOG.

    DATA: LV_WINDOW_TITLE TYPE STRING,
          LV_DEF_FNAME    TYPE STRING,
          LV_DEF_PATH     TYPE STRING,

          LV_FILENAME     TYPE STRING,
          LV_PATH         TYPE STRING,
          LV_FULLNAME     TYPE STRING.

    LV_DEF_FNAME = CV_FNAME.

*   Returns the Current Directory
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
      CHANGING
        CURRENT_DIRECTORY = LV_DEF_PATH.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
      EXPORTING
        WINDOW_TITLE         = LV_WINDOW_TITLE
        DEFAULT_FILE_NAME    = LV_DEF_FNAME
        INITIAL_DIRECTORY    = LV_DEF_PATH
        FILE_FILTER          = IV_FILTER "CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
      CHANGING
        FILENAME             = LV_FILENAME
        PATH                 = LV_PATH
        FULLPATH             = LV_FULLNAME
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        NOT_SUPPORTED_BY_GUI = 3
        OTHERS               = 4.

    CALL METHOD CL_GUI_CFW=>FLUSH.

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE GC_I NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              DISPLAY LIKE GC_E.
    ENDIF.

    IF LV_FULLNAME IS NOT INITIAL.
      CV_FNAME = LV_FULLNAME.
    ELSE.
      CLEAR CV_FNAME.
      MESSAGE S518(00).
    ENDIF.

  ENDMETHOD.


  METHOD GET_ALV_EXCL_TOOLBAR.
    "--------------------------------------------------------------------------------
*      gt_exld1          =  zcl_cm_common=>get_excl_toolbar( ).
    "--------------------------------------------------------------------------------

    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO                         TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_GRAPH                            TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_INFO                             TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY                         TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_HTML                             TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW                     TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_CUT                          TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW                   TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW                   TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW                     TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW                   TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE                        TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW                TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT                            TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK                       TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV                       TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_VIEWS                            TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_REFRESH                          TO RT_EXCL.
    APPEND CL_GUI_ALV_GRID=>MC_FC_CHECK                            TO RT_EXCL.

***  APPEND cl_gui_alv_grid=>mc_fc_auf                     TO rt_excl.                 "Drilldown Totals Level
***  APPEND cl_gui_alv_grid=>mc_fc_average                 TO rt_excl.                 "Calculate Average
**    APPEND cl_gui_alv_grid=>mc_fc_back_classic            TO rt_excl.                 "Back
**    APPEND cl_gui_alv_grid=>mc_fc_call_abc                TO rt_excl.                 "ABC Analysis
**    APPEND cl_gui_alv_grid=>mc_fc_call_chain              TO rt_excl.                 "Call Sequence
**    APPEND cl_gui_alv_grid=>mc_fc_call_crbatch            TO rt_excl.                 "Seagate Info Batch Processing
**    APPEND cl_gui_alv_grid=>mc_fc_call_crweb              TO rt_excl.                 "Seagate Info Web Processing
**    APPEND cl_gui_alv_grid=>mc_fc_call_lineitems          TO rt_excl.                 "Line Items
**    APPEND cl_gui_alv_grid=>mc_fc_call_master_data        TO rt_excl.                 "Master Data
**    APPEND cl_gui_alv_grid=>mc_fc_call_more               TO rt_excl.                 "More Calls
**    APPEND cl_gui_alv_grid=>mc_fc_call_report             TO rt_excl.                 "Call Report
**    APPEND cl_gui_alv_grid=>mc_fc_call_xint               TO rt_excl.                 "Additional Functions of SAPQuery
***  APPEND cl_gui_alv_grid=>mc_fc_call_xml_export         TO rt_excl.                 "StarOffice
***  APPEND cl_gui_alv_grid=>mc_fc_call_xxl                TO rt_excl.                 "XXL
**    APPEND cl_gui_alv_grid=>mc_fc_check                   TO rt_excl.                 "Check Entries
**    APPEND cl_gui_alv_grid=>mc_fc_col_invisible           TO rt_excl.                 "Columns Invisible
**    APPEND cl_gui_alv_grid=>mc_fc_col_optimize            TO rt_excl.                 "Optimize Columns
*** APPEND cl_gui_alv_grid=>mc_fc_count                   TO rt_excl.                 "Counter
***  APPEND cl_gui_alv_grid=>mc_fc_current_variant         TO rt_excl.                 "Current Variant
***  APPEND cl_gui_alv_grid=>mc_fc_data_save               TO rt_excl.                 "Save Data
***  APPEND cl_gui_alv_grid=>mc_fc_delete_filter           TO rt_excl.                 "Delete Filter
***  APPEND cl_gui_alv_grid=>mc_fc_deselect_all            TO rt_excl.                 "Deselect All Rows
***  APPEND cl_gui_alv_grid=>mc_fc_detail                  TO rt_excl.                 "Choose Detail
***  APPEND cl_gui_alv_grid=>mc_fc_excl_all                TO rt_excl.                 "Exclude all Grid Functions
**    APPEND cl_gui_alv_grid=>mc_fc_expcrdata               TO rt_excl.                 "CrystalReportsTM (Export with Data)
**    APPEND cl_gui_alv_grid=>mc_fc_expcrdesig              TO rt_excl.                 "Crystal Reports (TM) ( Start Designer)
**    APPEND cl_gui_alv_grid=>mc_fc_expcrtempl              TO rt_excl.                 "Crystal ( Templ ).
**    APPEND cl_gui_alv_grid=>mc_fc_expmdb                  TO rt_excl.                 "MicrosoftTM Database File
**    APPEND cl_gui_alv_grid=>mc_fc_extend                  TO rt_excl.                 "Additional Query Functions
**    APPEND cl_gui_alv_grid=>mc_fc_f4                      TO rt_excl.                 "F4
***  APPEND cl_gui_alv_grid=>mc_fc_filter                  TO rt_excl.                 "Filters
***  APPEND cl_gui_alv_grid=>mc_fc_find                    TO rt_excl.                 "Find
***  APPEND cl_gui_alv_grid=>mc_fc_find_more               TO rt_excl.                 "Search
**    APPEND cl_gui_alv_grid=>mc_fc_fix_columns             TO rt_excl.                 "Freeze to Column
**    APPEND cl_gui_alv_grid=>mc_fc_graph                   TO rt_excl.                 "Graphic
**    APPEND cl_gui_alv_grid=>mc_fc_help                    TO rt_excl.                 "Help
***  APPEND cl_gui_alv_grid=>mc_fc_html                    TO rt_excl.                 "HTML Download
**    APPEND cl_gui_alv_grid=>mc_fc_info                    TO rt_excl.                 "Information
***  APPEND cl_gui_alv_grid=>mc_fc_load_variant            TO rt_excl.                 "Read Variant
**    APPEND cl_gui_alv_grid=>mc_fc_loc_append_row          TO rt_excl.                 "Local: Append Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_copy                TO rt_excl.                 "Local: Copy
**    APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row            TO rt_excl.                 "Local: Copy Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_cut                 TO rt_excl.                 "Local: Cut
**    APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row          TO rt_excl.                 "Local: Delete Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row          TO rt_excl.                 "Local: Insert Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_move_row            TO rt_excl.                 "Local: Move Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_paste               TO rt_excl.                 "Local: Paste
**    APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row       TO rt_excl.                 "Locally: Paste new Row
**    APPEND cl_gui_alv_grid=>mc_fc_loc_undo                TO rt_excl.                 "Undo
***  APPEND cl_gui_alv_grid=>mc_fc_maintain_variant        TO rt_excl.                 "Maintain Variants
**    APPEND cl_gui_alv_grid=>mc_fc_maximum                 TO rt_excl.                 "Maximum
**    APPEND cl_gui_alv_grid=>mc_fc_minimum                 TO rt_excl.                 "Minimum
***  APPEND cl_gui_alv_grid=>mc_fc_pc_file                 TO rt_excl.                 "Export Local File
***  APPEND cl_gui_alv_grid=>mc_fc_print                   TO rt_excl.                 "Print
***  APPEND cl_gui_alv_grid=>mc_fc_print_back              TO rt_excl.                 "Print Backend
***  APPEND cl_gui_alv_grid=>mc_fc_print_prev              TO rt_excl.                 "Print Preview
**    APPEND cl_gui_alv_grid=>mc_fc_refresh                 TO rt_excl.                 "Refresh
**    APPEND cl_gui_alv_grid=>mc_fc_reprep                  TO rt_excl.                 "Report/Report Interface
***  APPEND cl_gui_alv_grid=>mc_fc_save_variant            TO rt_excl.                 "Save Variant
***  APPEND cl_gui_alv_grid=>mc_fc_select_all              TO rt_excl.                 "Select All Rows
**    APPEND cl_gui_alv_grid=>mc_fc_send                    TO rt_excl.                 "Send
**    APPEND cl_gui_alv_grid=>mc_fc_separator               TO rt_excl.                 "Separator
***  APPEND cl_gui_alv_grid=>mc_fc_sort                    TO rt_excl.                 "Sort
***  APPEND cl_gui_alv_grid=>mc_fc_sort_asc                TO rt_excl.                 "Sort in Ascending Order
***  APPEND cl_gui_alv_grid=>mc_fc_sort_dsc                TO rt_excl.                 "Sort in Descending Order
***  APPEND cl_gui_alv_grid=>mc_fc_subtot                  TO rt_excl.                 "Subtotals
***  APPEND cl_gui_alv_grid=>mc_fc_sum                     TO rt_excl.                 "Total
***  APPEND cl_gui_alv_grid=>mc_fc_to_office               TO rt_excl.                 "Export Office
**    APPEND cl_gui_alv_grid=>mc_fc_to_rep_tree             TO rt_excl.                 "Export Reporting Tree
**    APPEND cl_gui_alv_grid=>mc_fc_unfix_columns           TO rt_excl.                 "Unfreeze Columns
***  APPEND cl_gui_alv_grid=>mc_fc_url_copy_to_clipboard   TO rt_excl.                 "Generate URL for RFC Call
***  APPEND cl_gui_alv_grid=>mc_fc_variant_admin           TO rt_excl.                 "Function Code
***  APPEND cl_gui_alv_grid=>mc_fc_view_crystal            TO rt_excl.                 "Crystal Preview Inplace
***  APPEND cl_gui_alv_grid=>mc_fc_view_excel              TO rt_excl.                 "Excel Inplace
***  APPEND cl_gui_alv_grid=>mc_fc_view_grid               TO rt_excl.                 "Grid Control
***  APPEND cl_gui_alv_grid=>mc_fc_view_lotus              TO rt_excl.                 "Lotus Inplace
***  APPEND cl_gui_alv_grid=>mc_fc_views                   TO rt_excl.                 "View Change
**    APPEND cl_gui_alv_grid=>mc_fc_word_processor          TO rt_excl.                 "Word Processing
  ENDMETHOD.


  METHOD GET_ALV_LAYOUT.
    "--------------------------------------------------------------------------------
*  gs_layo1          =  ycl_commons=>get_layout( it_tab  = <gt_list1> ).
    "--------------------------------------------------------------------------------

    CONSTANTS : LC_COL  TYPE CHAR5 VALUE '*COL*',
                LC_STYL TYPE CHAR6 VALUE '*TAB*'.
    DATA : LR_DREF TYPE REF TO DATA.
    DATA : LO_TYPEDESCR   TYPE REF TO CL_ABAP_STRUCTDESCR.
    DATA : LS_COMP  TYPE LINE OF ABAP_COMPDESCR_TAB.
    CREATE DATA : LR_DREF LIKE LINE OF IT_TAB.

    LO_TYPEDESCR ?=  CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA_REF( LR_DREF ).
    LOOP AT LO_TYPEDESCR->COMPONENTS INTO LS_COMP.
      CHECK LS_COMP-TYPE_KIND = GC_H_LOWER.  "table type

      IF LS_COMP-NAME CP LC_COL.
        RS_LAYOUT-CTAB_FNAME = LS_COMP-NAME.
      ENDIF.
      IF LS_COMP-NAME CP LC_STYL.
        RS_LAYOUT-STYLEFNAME = LS_COMP-NAME.
      ENDIF.
    ENDLOOP.

*Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.
* =======================================
*  IF rs_layout-stylefname IS INITIAL.
*    IF i_incl_style_tab IS NOT INITIAL.
*      rs_layout-stylefname = mv_celltab.         "Stylefname
*    ENDIF.
*  ENDIF.

* General display options
* =======================================
*  IF rs_layout-cwidth_opt IS INITIAL.
*    IF i_no_col_opt IS INITIAL.
*      rs_layout-cwidth_opt = gc_x.          "ALV Column Optimization
*    ENDIF.
*  ENDIF.

    IF RS_LAYOUT-SMALLTITLE IS INITIAL.
      RS_LAYOUT-SMALLTITLE = GC_X.          "ALV Title Size Small
    ENDIF.
    RS_LAYOUT-CWIDTH_OPT = GC_X.
    RS_LAYOUT-ZEBRA      = GC_X.          "ALV Line Zebra

*rs_layout-box_fname  = 'BOX'.
* ICON.
* =======================================
*  rs_layout-excp_fname = g_lights_name.      "ALV ICON

* Grid customizing
* Title between grid control and toolbar(70# ##)
* =======================================
*  IF rs_layout-grid_title IS INITIAL.
*    IF i_grid_title IS NOT INITIAL.
*      rs_layout-grid_title = i_grid_title.    "ALV ##: ### ###
*    ENDIF.
*  ENDIF.

*Column headers are hidden
* =======================================
* rs_layout-no_headers = gc_x.            "ALV No Header

* Columns are displayed without horizontal grid lines
* =======================================
* rs_layout-no_hgridln = gc_x.            "ALV No Grid Line

* Cells are not merged when a column is sorted
* =======================================
* rs_layout-no_merging = gc_x.            "ALV No Merge

* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* CHECK BOX ### #### NO_ROMARK = X
* ( SEL_MODE = 'A' ).
** =======================================
    IF RS_LAYOUT-NO_ROWMARK IS INITIAL.
      RS_LAYOUT-NO_ROWMARK = SPACE.             "(or 'X') ALV No Row Mark
    ENDIF.

*Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
* =======================================
    IF RS_LAYOUT-SEL_MODE IS INITIAL.
      RS_LAYOUT-SEL_MODE = GC_A.                 "ALV Column and row selection
    ENDIF.

*If this field is set, the toolbar is hidden.
* =======================================
*  IF rs_layout-no_toolbar IS INITIAL.
*    IF i_no_toolbar IS NOT INITIAL.
*      rs_layout-no_toolbar = gc_x.            "ALV No Toolbar
*    ENDIF.
*  ENDIF.

*columns are displayed without vertical grid lines
* =======================================
* rs_layout-no_vgridln = gc_x.            "ALV Vertical No line

* Set status of all cells to editable using the layout structure.
* =======================================
*  IF rs_layout-edit IS INITIAL.
*    rs_layout-edit = i_edit.
*  ENDIF.



*Delete Key # Function Key Disabled Setting
* =====================================================
    IF RS_LAYOUT-NO_ROWINS IS INITIAL.
      RS_LAYOUT-NO_ROWINS = GC_X.
    ENDIF.

    RS_LAYOUT-INFO_FNAME = GC_FN_LINECOL.
  ENDMETHOD.


  METHOD GET_ALV_VARIANT.

    DATA: LT_REPORT  TYPE TABLE OF STRING,
          LT_VARIANT TYPE FIST_ALV_VARIANT_MAPPING,
          LV_USER    TYPE SLIS_USER.


    APPEND IV_REPID TO LT_REPORT.

    CALL FUNCTION 'FIS_ALV_VARIANTS_GET'
      EXPORTING
        IT_REPORT         = LT_REPORT
        IV_INCLUDE_USER   = 'X'
        IV_INCLUDE_SYSTEM = 'X'
      IMPORTING
        ET_VARIANT        = LT_VARIANT.

    LV_USER = COND #( WHEN IV_UNAME IS INITIAL THEN SY-UNAME ELSE IV_UNAME ).

    READ TABLE LT_VARIANT WITH KEY REPORT   = IV_REPID
                                   HANDLE   = IV_HANDLE
                                   USERNAME = LV_USER
                          INTO DATA(LS_VARIANT).
    IF SY-SUBRC EQ 0.
      RV_VARIANT = LS_VARIANT-VARIANT.
    ENDIF.

  ENDMETHOD.


  METHOD GET_CODE_MASTER.
    DEFINE __RANGE_EQ.
      IF &2 IS NOT INITIAL.
        APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = &2 ) TO &1.
      ENDIF.
    END-OF-DEFINITION.

    DATA : LV_WHERE TYPE CHAR72,
           LR_CODE1 TYPE RANGE OF ZGTSDT0002-CODE1,
           LR_CODE2 TYPE RANGE OF ZGTSDT0002-CODE2,
           LR_CODE3 TYPE RANGE OF ZGTSDT0002-CODE3.


*.- Range setting
    __RANGE_EQ: LR_CODE1  IV_CODE1,
                LR_CODE2  IV_CODE2,
                LR_CODE3  IV_CODE3.

*.- 추가 조건
    IF IV_FS EQ GC_X.
      LV_WHERE = |A~{ IV_FIELDNAME } EQ '{ IV_VALUE }'|.
    ENDIF.


    CLEAR RT_CODE[].

    TRY.
        SELECT A~*, B~SNAME, B~STEXT
          INTO CORRESPONDING FIELDS OF TABLE @RT_CODE
          FROM ZGTSDT0002 AS A LEFT JOIN ZGTSDT0002T AS B
                                    ON A~CODE  EQ B~CODE
                                   AND A~CODE1 EQ B~CODE1
                                   AND A~CODE2 EQ B~CODE2
                                   AND A~CODE3 EQ B~CODE3
                                   AND B~SPRAS EQ @SY-LANGU
         WHERE A~CODE   EQ @IV_CODE
           AND A~CODE1  IN @LR_CODE1
           AND A~CODE2  IN @LR_CODE2
           AND A~CODE3  IN @LR_CODE3
           AND A~IN_ACT EQ @SPACE
           AND (LV_WHERE)
         ORDER BY A~VALPOS, A~CODE1, A~CODE2, A~CODE3.


      CATCH CX_SY_DYNAMIC_OSQL_ERROR.

    ENDTRY.

  ENDMETHOD.


  METHOD GET_DOMAIN_TEXT.
    CLEAR RV_DDTEXT.

    SELECT SINGLE DDTEXT
      INTO RV_DDTEXT
      FROM DD07T
     WHERE DOMNAME    EQ IV_DOMNAME
       AND DDLANGUAGE EQ SY-LANGU
       AND DOMVALUE_L EQ IV_DOMVALUE.

  ENDMETHOD.


  METHOD GET_DYNP_VALUE.
    DATA : LT_FIELD TYPE TABLE OF DYNPREAD.

    CLEAR : RV_VALUE.

    LT_FIELD = VALUE #( ( FIELDNAME = IV_FNAME ) ).

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME               = IV_REPID
        DYNUMB               = IV_DYNNR
        TRANSLATE_TO_UPPER   = GC_X
      TABLES
        DYNPFIELDS           = LT_FIELD
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

    CHECK SY-SUBRC EQ 0 AND LT_FIELD[] IS NOT INITIAL.

    RV_VALUE = LT_FIELD[ 1 ]-FIELDVALUE.

  ENDMETHOD.


  METHOD GET_ELEMENTS.

    DATA: LO_STRU_REF TYPE REF TO CL_ABAP_STRUCTDESCR,
          LT_COMP     TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
          LS_COMP     LIKE LINE OF LT_COMP,
          LT_COMP_D   LIKE LT_COMP,
          LT_COMP_R   LIKE LT_COMP,
          LS_COMP_D   LIKE LS_COMP,
          LV_INDEX    TYPE SY-INDEX.


    LT_COMP[] = IT_COMP[].
    LOOP AT LT_COMP INTO LS_COMP WHERE AS_INCLUDE EQ GC_X.
      LV_INDEX = SY-TABIX.

      DELETE LT_COMP.
      LO_STRU_REF ?= LS_COMP-TYPE.
      LT_COMP_D = LO_STRU_REF->GET_COMPONENTS( ).            "Recursive Point

      IF LS_COMP-SUFFIX IS NOT INITIAL.
        LOOP AT LT_COMP_D INTO LS_COMP_D.

          IF LS_COMP_D-AS_INCLUDE = SPACE.
            CONCATENATE LS_COMP_D-NAME LS_COMP-SUFFIX INTO LS_COMP_D-NAME.
          ELSE.
            LS_COMP_D-SUFFIX = LS_COMP-SUFFIX.
          ENDIF.
          MODIFY LT_COMP_D FROM LS_COMP_D.

        ENDLOOP.
      ENDIF.

***      LT_COMP_R = ME->GET_ELEMENTS( LT_COMP_D ).
      LT_COMP_R = ZGTSD_CL_COMMON=>GET_ELEMENTS( LT_COMP_D ).

      LOOP AT LT_COMP_R INTO LS_COMP_D.
*      APPEND ls_comp_d TO lt_comp.
        INSERT LS_COMP_D INTO LT_COMP INDEX LV_INDEX.
        LV_INDEX = LV_INDEX + 1.
        CLEAR LS_COMP_D.
      ENDLOOP.
      CLEAR : LS_COMP, LT_COMP_R[].

    ENDLOOP.

    RT_COMP = LT_COMP.

  ENDMETHOD.


  METHOD GET_FCAT.
    "--------------------------------------------------------------------------------
* ALV에서 사용하는 FieldCatalog를 빠르게 가져올 때 사용한다.
    "--------------------------------------------------------------------------------
* is_fcat         :
* iv_ddic_object  : ABAP Dictionary의 Object를 지정해 준다. 'SFLIGHT'
* is_data         :
* it_data         : itab을 지정해 준다. gt_list
* ior_dref        : Data Type으로 지정된 itab을 설정할 수 있다.
* rt_fcat         : FieldCatalog를 리턴해 준다.
    "--------------------------------------------------------------------------------
* data(lt_fcat ) =  zcl_cm_common=>get_fcat( it_data = gt_list ).
* data(lt_fcat) = zcl_cm_common=>get_fcat( iv_ddic_object = 'MARA' ).
* => gt_list 내용의 FieldCatalog를 리턴해라.
    "--------------------------------------------------------------------------------

    DATA: LS_FCAT        TYPE LVC_S_FCAT,
          LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_TYPEDESCR   TYPE REF TO CL_ABAP_TYPEDESCR,
          LO_DATA        TYPE REF TO DATA,
          LT_DFIES       TYPE DDFIELDS,
          LO_DFIES       TYPE REF TO DFIES.

    FIELD-SYMBOLS: <LT_DATA> TYPE STANDARD TABLE.

    CONSTANTS: LC_MANDT      TYPE CHAR5  VALUE 'MANDT',
               LC_CURR       TYPE CHAR4  VALUE 'CURR',
               LC_QUAN       TYPE CHAR4  VALUE 'QUAN',
               LC_REF        TYPE CHAR3  VALUE 'REF',
               LC_COLOR      TYPE CHAR10 VALUE 'COLOR',
               LC_T_COLOR    TYPE CHAR10 VALUE 'T_COLOR',
               LC_T_STYLE    TYPE CHAR10 VALUE 'T_STYLE',
               LC_S_DROPDOWN TYPE CHAR10 VALUE 'S_DROPDOWN',
               LC_EDIT       TYPE CHAR10 VALUE 'EDIT',
               LC_NODE_KEY   TYPE CHAR10 VALUE 'NODE_KEY',
               LC_RELATKEY   TYPE CHAR10 VALUE 'RELATKEY',
               LC_CHECKBOX   TYPE CHAR10 VALUE 'CHECKBOX',
               LC_XFELD      TYPE CHAR10 VALUE 'XFELD',
               LC_ICON       TYPE CHAR10 VALUE 'ICON',
               LC_TSTMP_FROM TYPE CHAR20 VALUE '/BSAR/DE_TSTMP_FROM',
               LC_TSTMP_TO   TYPE CHAR20 VALUE '/BSAR/DE_TSTMP_TO',
               LC_CRETSTMP   TYPE CHAR20 VALUE '/BSAR/DE_CRETSTMP',
               LC_CHATSTMP   TYPE CHAR20 VALUE '/BSAR/DE_CHATSTMP'.



* Full structure input
    IF IS_FCAT IS NOT INITIAL.
      APPEND IS_FCAT TO RT_FCAT.


* DDIC struct of table name
    ELSEIF IV_DDIC_OBJECT IS NOT INITIAL.
      CREATE DATA LO_DATA TYPE (IV_DDIC_OBJECT).
      RT_FCAT = GET_FCAT( IO_DREF = LO_DATA ).

* Fill Table name
      LS_FCAT-TABNAME = IV_DDIC_OBJECT.
      MODIFY RT_FCAT FROM LS_FCAT
             TRANSPORTING TABNAME WHERE TABNAME = SPACE.


* Any data structure
    ELSEIF IS_DATA IS SUPPLIED.
      GET REFERENCE OF IS_DATA INTO LO_DATA.
      RT_FCAT = GET_FCAT( IO_DREF = LO_DATA ).


* Any data table
    ELSEIF IT_DATA IS SUPPLIED.
      GET REFERENCE OF IT_DATA INTO LO_DATA.
      RT_FCAT = GET_FCAT( IO_DREF = LO_DATA ).


* Data reference
    ELSEIF IO_DREF IS BOUND.
* Get reference type
      LO_TYPEDESCR ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA_REF( IO_DREF ).

*    CASE lo_typedescr->kind.
*      WHEN cl_abap_typedescr=>kind_elem.    " field

*      WHEN cl_abap_typedescr=>kind_struct.  " structure
*        lo_structdescr ?= cl_abap_structdescr=>describe_by_data_ref( ior_dref ).
*        lor_struc = ior_dref.

*      WHEN cl_abap_typedescr=>kind_table.   " table
*        ASSIGN ior_dref->* TO <lt_data>.
*        CREATE DATA lor_struc LIKE LINE OF <lt_data>.
*        lo_structdescr ?= cl_abap_structdescr=>describe_by_data_ref( lor_struc ).

*    ENDCASE.

      CASE LO_TYPEDESCR->TYPE_KIND.
        WHEN CL_ABAP_TYPEDESCR=>TYPEKIND_STRUCT1 OR
             CL_ABAP_TYPEDESCR=>TYPEKIND_STRUCT2.  " structure

          LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( IO_DREF ).
          LO_DATA = IO_DREF.


        WHEN CL_ABAP_TYPEDESCR=>TYPEKIND_TABLE.   " table
          ASSIGN IO_DREF->* TO <LT_DATA>.

          CREATE DATA LO_DATA LIKE LINE OF <LT_DATA>.
          LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_DATA ).

      ENDCASE.


** Get fields in table
      LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

* Build Field catalog
      LOOP AT LT_DFIES REFERENCE INTO LO_DFIES.
        LS_FCAT-FIELDNAME = LO_DFIES->FIELDNAME.
        LS_FCAT-REF_FIELD = LO_DFIES->REFFIELD.
        LS_FCAT-REF_TABLE = LO_DFIES->REFTABLE.

* Set technical - by fieldname
* This are the fields from include structure ZCLS_ALV_OUTPUT
* or fields that were declared as reference
        IF LO_DFIES->DATATYPE = LC_REF        OR "reference
           LS_FCAT-FIELDNAME  = LC_COLOR      OR
           LS_FCAT-FIELDNAME  = LC_T_COLOR    OR "pointer: layout-info_fname
           LS_FCAT-FIELDNAME  = LC_T_STYLE    OR
           LS_FCAT-FIELDNAME  = LC_S_DROPDOWN OR
           LS_FCAT-FIELDNAME  = LC_EDIT       OR
           LS_FCAT-FIELDNAME  = LC_NODE_KEY   OR
           LS_FCAT-FIELDNAME  = LC_RELATKEY.

          LS_FCAT-TECH = ABAP_TRUE.

        ELSE.
          IF LO_DFIES->PRECFIELD IS NOT INITIAL.
            IF LO_DFIES->DATATYPE = LC_CURR. "'CURR'.
              LS_FCAT-CFIELDNAME = LO_DFIES->PRECFIELD.

            ELSEIF LO_DFIES->DATATYPE = LC_QUAN. "'QUAN'.
              LS_FCAT-QFIELDNAME = LO_DFIES->PRECFIELD.

            ENDIF.

          ENDIF.

          LS_FCAT-OUTPUTLEN = LO_DFIES->OUTPUTLEN.
          LS_FCAT-DD_OUTLEN = LO_DFIES->OUTPUTLEN.

          IF LO_DFIES->CONVEXIT IS NOT INITIAL.
            CONCATENATE '==' LO_DFIES->CONVEXIT INTO LS_FCAT-EDIT_MASK.

          ENDIF.

          LS_FCAT-ROLLNAME   = LO_DFIES->ROLLNAME.
          LS_FCAT-F4AVAILABL = LO_DFIES->F4AVAILABL.
          LS_FCAT-MAC        = LO_DFIES->MAC.
          LS_FCAT-ROLLNAME   = LO_DFIES->ROLLNAME.
          LS_FCAT-DOMNAME    = LO_DFIES->DOMNAME.
          LS_FCAT-INTLEN     = LO_DFIES->LENG.
          LS_FCAT-INTLEN     = LO_DFIES->INTLEN.
          LS_FCAT-DECIMALS   = LO_DFIES->DECIMALS.
          LS_FCAT-DATATYPE   = LO_DFIES->DATATYPE.
          LS_FCAT-INTTYPE    = LO_DFIES->INTTYPE.
          LS_FCAT-SCRTEXT_S  = LO_DFIES->SCRTEXT_S.
          LS_FCAT-SCRTEXT_M  = LO_DFIES->SCRTEXT_M.
          LS_FCAT-SCRTEXT_L  = LO_DFIES->SCRTEXT_L.
          LS_FCAT-COLTEXT    = LO_DFIES->SCRTEXT_L.
          IF LS_FCAT-SCRTEXT_S IS INITIAL AND
             LS_FCAT-SCRTEXT_M IS INITIAL AND
             LS_FCAT-SCRTEXT_L IS INITIAL.
            LS_FCAT-SCRTEXT_S = LS_FCAT-SCRTEXT_M = LS_FCAT-SCRTEXT_L = LS_FCAT-COLTEXT = LO_DFIES->FIELDTEXT.
          ENDIF.

          IF LO_DFIES->DATATYPE = LC_CURR OR
             LO_DFIES->DATATYPE = LC_QUAN.
            LS_FCAT-NO_SIGN = ABAP_FALSE.

          ELSE.
            LS_FCAT-NO_SIGN    = LO_DFIES->SIGN.

          ENDIF.

          LS_FCAT-LOWERCASE  = LO_DFIES->LOWERCASE.
          LS_FCAT-F4AVAILABL = LO_DFIES->F4AVAILABL.
          LS_FCAT-CHECKTABLE = LO_DFIES->CHECKTABLE.
          LS_FCAT-KEY        = LO_DFIES->KEYFLAG.

* Set No-Sum field
***          IF LS_FCAT-DATATYPE <> LC_CURR AND
***             LS_FCAT-DATATYPE <> LC_QUAN.
***            LS_FCAT-NO_SUM  = ABAP_TRUE.
***          ENDIF.

* Set technical - by rollname
          IF LS_FCAT-ROLLNAME  = LC_MANDT      OR
             LS_FCAT-ROLLNAME  = LC_TSTMP_FROM OR
             LS_FCAT-ROLLNAME  = LC_TSTMP_TO   OR
             LS_FCAT-ROLLNAME  = LC_CRETSTMP   OR
             LS_FCAT-ROLLNAME  = LC_CHATSTMP.
            LS_FCAT-TECH = ABAP_TRUE.
          ENDIF.

* Set checkbox
          IF LS_FCAT-DOMNAME = LC_CHECKBOX OR
             LS_FCAT-DOMNAME = LC_XFELD.
            LS_FCAT-CHECKBOX = ABAP_TRUE.
          ENDIF.

* Set Icon
          IF LS_FCAT-DOMNAME = LC_ICON.
            LS_FCAT-ICON = ABAP_TRUE.
            LS_FCAT-JUST = GC_C.  "Center
          ENDIF.
        ENDIF.


* Save column as record
        APPEND LS_FCAT TO RT_FCAT. CLEAR LS_FCAT.

      ENDLOOP.

      IF SY-SUBRC = 1.
        RAISE NO_STRUCTURE.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD GET_FIELDCAT.

    DATA: LO_SREF       TYPE REF TO DATA,
          LO_STRU_ELE   TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_STRU_REF   TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_STRU_REF_T TYPE REF TO CL_ABAP_STRUCTDESCR,
          LO_CLSS_REF   TYPE REF TO CL_ABAP_CLASSDESCR,
          LO_ELEM_REF   TYPE REF TO CL_ABAP_ELEMDESCR,
          LO_TAB_REF    TYPE REF TO CL_ABAP_TABLEDESCR,
          LT_COMP       TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
          LT_COMP_      LIKE LT_COMP,
          LT_COMP_ELE   LIKE LT_COMP,
          LS_COMP       LIKE LINE OF LT_COMP,
          LS_COMP_ELE   LIKE LINE OF LT_COMP_ELE,
          LV_SIZE       TYPE I,
          LV_INDEX      TYPE I,
          LV_IND_COMP   TYPE I,
          LV_TYP1       TYPE STRING,
          LV_HLPID      TYPE STRING,
          LV_SNAME      TYPE STRING,
          LS_FCAT       TYPE LVC_S_FCAT,
          LS_DFIES      TYPE DFIES,
          LT_TAB        TYPE TABLE OF STRING,
          LV_REFSTRUCT  TYPE SWCONTDEF-REFSTRUCT,
          LV_REFFIELD   TYPE SWCONTDEF-REFFIELD,
          LS_DD04V      TYPE DD04V.


    FIELD-SYMBOLS: <LS_WA>    TYPE ANY,
                   <LV_FIELD> TYPE ANY.

    CONSTANTS: LC_STRUCTDESCR TYPE CHAR30 VALUE 'CL_ABAP_STRUCTDESCR',
               LC_TABLEDESCR  TYPE CHAR30 VALUE 'CL_ABAP_TABLEDESCR',
               LC_MANDT       TYPE CHAR05 VALUE 'MANDT'.


    LO_TAB_REF  ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( IT_TAB ).
    LO_STRU_REF ?= LO_TAB_REF->GET_TABLE_LINE_TYPE( ).

*-- Check Reference
    LO_CLSS_REF ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_OBJECT_REF( LO_STRU_REF ).
    IF LO_CLSS_REF->GET_RELATIVE_NAME( ) NE LC_STRUCTDESCR. "'CL_ABAP_STRUCTDESCR'.
      RAISE NOT_A_STRUCTURE.
    ENDIF.

*-- Recursive Search for Include.
    LT_COMP_ = LO_STRU_REF->GET_COMPONENTS( ).
*   Table Type
    LOOP AT LT_COMP_ INTO LS_COMP.
      LO_CLSS_REF ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_OBJECT_REF( LS_COMP-TYPE ).
      IF LO_CLSS_REF->GET_RELATIVE_NAME( ) EQ LC_TABLEDESCR. "'CL_ABAP_TABLEDESCR'.
        DELETE LT_COMP_.
      ENDIF.
    ENDLOOP.

    LT_COMP  = ZGTSD_CL_COMMON=>GET_ELEMENTS( LT_COMP_ ).

    LV_SIZE = LINES( LT_COMP ).
    LV_SNAME = LO_STRU_REF->ABSOLUTE_NAME."get_relative_name( ).

*-- get memebers
    TRY .
        CREATE DATA LO_SREF TYPE (LV_SNAME).
      CATCH CX_SY_CREATE_DATA_ERROR.
        CALL METHOD CL_ABAP_STRUCTDESCR=>CREATE
          EXPORTING
            P_COMPONENTS = LT_COMP
          RECEIVING
            P_RESULT     = LO_STRU_REF_T.

        CREATE DATA LO_SREF TYPE HANDLE LO_STRU_REF_T.

    ENDTRY.
    ASSIGN LO_SREF->* TO <LS_WA>.

    CLEAR: LV_INDEX.
    DO LV_SIZE TIMES.

      LV_IND_COMP = SY-INDEX.

      DO.
        LV_INDEX = LV_INDEX + 1.

        UNASSIGN <LV_FIELD>.
        ASSIGN COMPONENT LV_INDEX OF STRUCTURE <LS_WA> TO <LV_FIELD>.
        DESCRIBE FIELD: <LV_FIELD> HELP-ID LV_HLPID,
                        <LV_FIELD> TYPE LV_TYP1.

        CASE LV_TYP1.
          WHEN 'h'.
          WHEN OTHERS.        EXIT.
        ENDCASE.
      ENDDO.

      " XXX-VVV, VVV, SPACE
      SPLIT LV_HLPID AT '-' INTO TABLE LT_TAB.
      READ TABLE LT_COMP INTO LS_COMP INDEX LV_IND_COMP.
      CHECK SY-SUBRC EQ 0.


      CASE LINES( LT_TAB ).
        WHEN 2.     "struct + field
          READ TABLE LT_TAB INTO LV_REFSTRUCT INDEX 1.
          READ TABLE LT_TAB INTO LV_REFFIELD  INDEX 2.

          " field # ### ### ##.
          CALL METHOD ZGTSD_CL_COMMON=>GET_FIELD_INFO
            EXPORTING
              IV_TABNAME           = LV_REFSTRUCT
              IV_FIELDNAME         = LV_REFFIELD
              IV_LANGU             = SY-LANGU
            IMPORTING
              ES_DFIES             = LS_DFIES
            EXCEPTIONS
              FIELD_INFO_NOT_FOUND = 1
              OTHERS               = 2.
          IF SY-SUBRC EQ 0.
            IF LS_DFIES-REPTEXT   IS INITIAL AND
               LS_DFIES-SCRTEXT_S IS INITIAL AND
               LS_DFIES-SCRTEXT_M IS INITIAL AND
               LS_DFIES-SCRTEXT_L IS INITIAL.
              LS_DFIES-REPTEXT   = LS_DFIES-SCRTEXT_S =
              LS_DFIES-SCRTEXT_M = LS_DFIES-SCRTEXT_L = LS_DFIES-FIELDTEXT.
            ENDIF.

            LS_FCAT = CORRESPONDING #( LS_DFIES MAPPING KEY = KEYFLAG ).
            LS_FCAT-COLTEXT = LS_FCAT-REPTEXT.

*       Data Type : Currency, Quanitity  Field
            CASE LS_DFIES-DATATYPE.
              WHEN 'CURR' OR 'QUAN'.
                READ TABLE LT_COMP WITH KEY NAME = LS_DFIES-REFFIELD
                     TRANSPORTING NO FIELDS.
                IF SY-SUBRC = 0.
                  CASE LS_DFIES-DATATYPE.
                    WHEN 'CURR' .
                      LS_FCAT-CFIELDNAME = LS_DFIES-REFFIELD.
                    WHEN 'QUAN'.
                      LS_FCAT-QFIELDNAME = LS_DFIES-REFFIELD.
                  ENDCASE.
                ENDIF.
            ENDCASE.

            LS_FCAT-REF_TABLE = LV_REFSTRUCT.
            LS_FCAT-REF_FIELD = LV_REFFIELD.
            LS_FCAT-TABNAME   = SPACE.
            LS_FCAT-FIELDNAME = LS_COMP-NAME.
            APPEND LS_FCAT TO RT_FIELDCAT.

          ELSE.
            RAISE NO_DDIC.
          ENDIF.

        WHEN 1.   "DataElement
          READ TABLE LT_TAB INTO LV_REFFIELD INDEX 1.

          CALL FUNCTION 'DDIF_DTEL_GET'
            EXPORTING
              NAME          = LV_REFFIELD
*             STATE         = 'A'
              LANGU         = SY-LANGU
            IMPORTING
*             GOTSTATE      =
              DD04V_WA      = LS_DD04V
*             TPARA_WA      =
            EXCEPTIONS
              ILLEGAL_INPUT = 1
              OTHERS        = 2.

          IF SY-SUBRC = 0.
            MOVE-CORRESPONDING LS_DD04V TO LS_FCAT.

            LS_FCAT-REPTEXT   = LS_FCAT-SCRTEXT_L =
            LS_FCAT-SCRTEXT_M = LS_FCAT-SCRTEXT_S =
            LS_FCAT-COLTEXT   = LS_DD04V-DDTEXT.
            LS_FCAT-REF_TABLE = SPACE.
            LS_FCAT-TABNAME   = SPACE.
            LS_FCAT-FIELDNAME = LS_COMP-NAME.

            IF LS_DD04V-SHLPNAME IS NOT INITIAL.
              LS_FCAT-F4AVAILABL = GC_X.
            ENDIF.

            APPEND LS_FCAT      TO RT_FIELDCAT.
          ELSE.
            RAISE NO_DDIC.
          ENDIF.

        WHEN OTHERS.

          CASE LS_COMP-TYPE->KIND.
            WHEN 'S'.   " Structure..
              LO_STRU_ELE ?= LS_COMP-TYPE.
              LT_COMP_ELE = LO_STRU_ELE->GET_COMPONENTS( ).
              LOOP AT LT_COMP_ELE INTO LS_COMP_ELE.
                LO_ELEM_REF ?= LS_COMP_ELE-TYPE.
                LS_FCAT-FIELDNAME = LS_COMP-NAME && '-' && LS_COMP_ELE-NAME.

                LS_FCAT-INTTYPE   = LO_ELEM_REF->TYPE_KIND.
                LS_FCAT-INTLEN    = LO_ELEM_REF->LENGTH.
                LS_FCAT-DECIMALS  = LS_FCAT-DECIMALS_O = LO_ELEM_REF->DECIMALS.
                LS_FCAT-OUTPUTLEN = LO_ELEM_REF->OUTPUT_LENGTH.
                APPEND LS_FCAT   TO RT_FIELDCAT.
              ENDLOOP.

            WHEN OTHERS.
              LO_ELEM_REF ?= LS_COMP-TYPE.
              LS_FCAT-FIELDNAME = LS_COMP-NAME.

              LS_FCAT-INTTYPE   = LO_ELEM_REF->TYPE_KIND.
              LS_FCAT-INTLEN    = LO_ELEM_REF->LENGTH.
              LS_FCAT-DECIMALS  = LS_FCAT-DECIMALS_O = LO_ELEM_REF->DECIMALS.
              LS_FCAT-OUTPUTLEN = LO_ELEM_REF->OUTPUT_LENGTH.
              APPEND LS_FCAT   TO RT_FIELDCAT.
          ENDCASE.
      ENDCASE.

      CLEAR: LS_FCAT, LS_COMP, LV_REFFIELD, LV_REFSTRUCT, LS_DD04V, LS_DFIES, LO_ELEM_REF, LT_TAB[].

    ENDDO.

    " Col pos # '999'# ####.
    LS_FCAT-COL_POS = 999.
    MODIFY RT_FIELDCAT FROM LS_FCAT TRANSPORTING COL_POS
                      WHERE COL_POS NE LS_FCAT-COL_POS.

    LS_FCAT-NO_OUT = GC_X.
    MODIFY RT_FIELDCAT FROM LS_FCAT TRANSPORTING NO_OUT
                      WHERE FIELDNAME EQ LC_MANDT.

  ENDMETHOD.


  METHOD GET_FIELDCATALOG.

    TRY.
        CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = DATA(LO_TABLE)
                                CHANGING  T_TABLE      = IT_TAB ).
        RT_FIELDCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG( R_COLUMNS      = LO_TABLE->GET_COLUMNS( )
                                                                         R_AGGREGATIONS = LO_TABLE->GET_AGGREGATIONS( ) ).

        LOOP AT RT_FIELDCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-SCRTEXT_L.
          <LS_FCAT>-COL_POS = 999.
        ENDLOOP.

      CATCH CX_ROOT.
    ENDTRY.

  ENDMETHOD.


  METHOD GET_FIELD_CATALOG.

    TRY.
        CL_SALV_TABLE=>FACTORY( IMPORTING
                                  R_SALV_TABLE   = DATA(LO_SALV_TABLE)
                                CHANGING
                                  T_TABLE        = IT_TABLE ).
        RT_FCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
                    R_COLUMNS      = LO_SALV_TABLE->GET_COLUMNS( )         "ALV Filter
                    R_AGGREGATIONS = LO_SALV_TABLE->GET_AGGREGATIONS( ) ). "ALV Aggregations
      CATCH CX_ROOT.
    ENDTRY.

    LOOP AT RT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      <LS_FCAT>-COLTEXT = <LS_FCAT>-SCRTEXT_L.
      <LS_FCAT>-TECH    = IV_DEF_TECH. "Default Tech = 'X'
      <LS_FCAT>-COL_POS = 999.
    ENDLOOP.

    IF IV_CELLS = ZGTSD_X.         "Add Cell Style 필드
      RT_FCAT = VALUE #( BASE RT_FCAT ( FIELDNAME = |CELLS|
                                        TECH      = ZGTSD_X
                                        COL_POS   = LINES( RT_FCAT ) ) ).
    ENDIF.

    IF IV_CELLC = ZGTSD_X.         "Add Cell Color 필드
      RT_FCAT = VALUE #( BASE RT_FCAT ( FIELDNAME = |CELLC|
                                        TECH      = ZGTSD_X
                                        COL_POS   = LINES( RT_FCAT ) ) ).
    ENDIF.

  ENDMETHOD.


  METHOD GET_FIELD_INFO.

    DATA: LS_DFIES TYPE DFIES,
          LT_DFIES TYPE TABLE OF DFIES.
*          LS_TABLE_HEADER_INFO TYPE X030L,


    IF IV_TABNAME IS INITIAL AND IV_FIELDNAME IS INITIAL.
      RAISE FIELD_INFO_NOT_FOUND.
    ENDIF.

    DATA(LV_LANGU) = COND #( WHEN IV_LANGU IS INITIAL THEN SY-LANGU ELSE IV_LANGU ).

    " Table
    SELECT SINGLE TABCLASS
      FROM DD02L
      INTO @DATA(LV_TABCLASS)
     WHERE TABNAME  EQ @IV_TABNAME
       AND AS4LOCAL EQ @GC_A.
    IF SY-SUBRC NE 0.
      RAISE FIELD_INFO_NOT_FOUND.
    ENDIF.

    LS_DFIES-TABNAME   = IV_TABNAME.     "type conversion
    LS_DFIES-FIELDNAME = IV_FIELDNAME.  "type conversion

    CASE LV_TABCLASS.
      WHEN 'INTTAB' OR 'APPEND'.
        SELECT SINGLE *
          FROM DD03M
          INTO CORRESPONDING FIELDS OF ES_DFIES
         WHERE TABNAME    = LS_DFIES-TABNAME
           AND FIELDNAME  = LS_DFIES-FIELDNAME
           AND DDLANGUAGE = LV_LANGU.

      WHEN OTHERS.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            TABNAME        = LS_DFIES-TABNAME
            FIELDNAME      = LS_DFIES-FIELDNAME
            LANGU          = LV_LANGU
*          IMPORTING
*           X030L_WA       = LS_TABLE_HEADER_INFO
          TABLES
            DFIES_TAB      = LT_DFIES[]
          EXCEPTIONS
            NOT_FOUND      = 01
            INTERNAL_ERROR = 02
            OTHERS         = 99.
        IF SY-SUBRC NE 0.
          RAISE FIELD_INFO_NOT_FOUND.
        ENDIF.

*       now read the field info for the requested field
        READ TABLE LT_DFIES[] INTO ES_DFIES
                              WITH KEY FIELDNAME = LS_DFIES-FIELDNAME.
    ENDCASE.

  ENDMETHOD.


  METHOD GET_LOGIN_EMP_NO.

    CLEAR RV_EMP_NO.
    GET PARAMETER ID 'ZEMP_NO' FIELD RV_EMP_NO.

  ENDMETHOD.


  METHOD GET_SELECTED_ROWS.

    CLEAR : RT_ROWS, EV_SUBRC.

    CHECK IO_GRID IS BOUND.

    IO_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = RT_ROWS ).

    DELETE RT_ROWS WHERE ROWTYPE IS NOT INITIAL. "유효하지 않은 라인 삭제

    CHECK IV_CK = ZGTSD_X.

    CASE IV_INFOTY.
      WHEN ZGTSD_X. "메시지 팝업 유형
        IF RT_ROWS IS INITIAL.
          MESSAGE I042 DISPLAY LIKE ZGTSD_W. "행 선택 후 실행하세요.
          EV_SUBRC = 4.
        ELSEIF IV_ONLY_ONE = ZGTSD_X AND LINES( RT_ROWS ) > 1.
          MESSAGE I002 DISPLAY LIKE ZGTSD_W. "유효한 라인을 하나만 선택하십시오.
          EV_SUBRC = 4.
        ENDIF.
      WHEN OTHERS.
        IF RT_ROWS IS INITIAL.
          MESSAGE S042 DISPLAY LIKE ZGTSD_W. "행 선택 후 실행하세요.
          EV_SUBRC = 4.
        ELSEIF IV_ONLY_ONE = ZGTSD_X AND LINES( RT_ROWS ) > 1.
          MESSAGE S002 DISPLAY LIKE ZGTSD_W. "유효한 라인을 하나만 선택하십시오.
          EV_SUBRC = 4.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD POPUP_TO_COMFIRM.
    DATA: LV_TITLE TYPE CHAR40,
          LV_TEXT  TYPE CHAR80.

    CLEAR RV_ANSWER.

    IF IV_MESSA IS INITIAL.
      CASE IV_UCOMM.
        WHEN 'SAVE'." - Are you sure you want to save?
          MESSAGE S031 INTO LV_TEXT.
        WHEN 'DELE'." - Are you sure you want to delete?
          MESSAGE S032 INTO LV_TEXT.
        WHEN 'CHAN'." - Are you sure you want to change the data?
          MESSAGE S033 INTO LV_TEXT.
        WHEN 'CREA'." - Are you sure you want to New the data?
          MESSAGE S034 INTO LV_TEXT.
        WHEN 'EXEC'." - Are you sure you want to continue?
          MESSAGE S035 INTO LV_TEXT.
        WHEN 'EXIT'." - Are you sure you want to leave the screen?
          MESSAGE S036 INTO LV_TEXT.
        WHEN 'COPY'." - Are you sure you want to copy?
          MESSAGE S037 INTO LV_TEXT.
        WHEN 'REDO'." - Are you sure you want to restoration?
          MESSAGE S038 INTO LV_TEXT.
        WHEN 'DELC'." -
          MESSAGE S039 INTO LV_TEXT.
      ENDCASE.
    ELSE.
      LV_TEXT = IV_MESSA.
    ENDIF.


    IF LV_TEXT IS INITIAL.
      EXIT.

    ELSE.
      MESSAGE S040 INTO LV_TITLE.  "확인
*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*          DEFAULTOPTION  = 'N'
*          TEXTLINE1      = LV_TEXT
*          TITEL          = LV_TITLE
*          CANCEL_DISPLAY = SPACE
*          START_COLUMN   = 25
*          START_ROW      = 6
*        IMPORTING
*          ANSWER         = RV_ANSWER
*        EXCEPTIONS
*          OTHERS         = 1.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = LV_TITLE
          TEXT_QUESTION         = LV_TEXT
          TEXT_BUTTON_1         = TEXT-F01
          TEXT_BUTTON_2         = TEXT-F02
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = ''
          POPUP_TYPE            = 'ICON_MESSAGE_INFORMATION'
        IMPORTING
          ANSWER                = RV_ANSWER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.

      CHECK SY-SUBRC EQ 0.

      RV_ANSWER = COND #( WHEN RV_ANSWER EQ GC_1 THEN GC_J ELSE RV_ANSWER ).
    ENDIF.

  ENDMETHOD.


  METHOD READ_USER_NAME.

    CLEAR RV_NAME_TX.

    SELECT SINGLE NAME_TEXT INTO @RV_NAME_TX
      FROM V_USR_NAME
     WHERE BNAME EQ @IV_UNAME.
*    SELECT SINGLE B~NAME_TEXT INTO @RV_NAME_TX
*      FROM USR21 AS A INNER JOIN ADRP AS B
*                         ON A~PERSNUMBER = B~PERSNUMBER
*     WHERE A~BNAME EQ @IV_UNAME.

  ENDMETHOD.


  METHOD SET_ALV_F4.
    "--------------------------------------------------------------------------------
*          call method zcl_cm_common=>set_alv_f4( io_alv = go_grid2 it_fcat = gt_fcat2 ).
    "--------------------------------------------------------------------------------
    DATA : LS_FCAT LIKE LINE OF IT_FCAT.
    DATA : LT_F4_LIST TYPE LVC_T_F4,
           LS_F4      TYPE LVC_S_F4.
    LS_F4-REGISTER = GC_X.
    LOOP AT IT_FCAT INTO LS_FCAT WHERE F4AVAILABL = GC_X.
      LS_F4-FIELDNAME  = LS_FCAT-FIELDNAME.
      INSERT LS_F4 INTO TABLE LT_F4_LIST.
    ENDLOOP.

    CALL METHOD IO_ALV->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = LT_F4_LIST.
  ENDMETHOD.


  METHOD SET_DYNP_VALUE.

    DATA: LT_DYNPREAD TYPE TABLE OF DYNPREAD.

    IF IT_VALUE[] IS NOT INITIAL.
      LT_DYNPREAD = IT_VALUE.
    ELSE.
      CHECK IV_FNAME IS NOT INITIAL AND
            IV_VALUE IS NOT INITIAL.
      LT_DYNPREAD = VALUE #( ( FIELDNAME  = IV_FNAME
                               FIELDVALUE = IV_VALUE ) ).
    ENDIF.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = IV_REPID
        DYNUMB               = IV_DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPREAD
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.

    CHECK SY-SUBRC EQ 0.

  ENDMETHOD.


  METHOD SET_TIMESTAMP.
    DATA LR_TITLE TYPE RANGE OF SY-TITLE.

    FIELD-SYMBOLS: <LV_VAL> TYPE ANY.

    CONSTANTS: LC_ERNAM      TYPE CHAR10     VALUE 'ERNAM',
               LC_ERDAT      TYPE CHAR10     VALUE 'ERDAT',
               LC_ERZEIT     TYPE CHAR10     VALUE 'ERZEIT',
               LC_ERDATLO    TYPE CHAR10     VALUE 'ERDATLO',
               LC_ERTIMLO    TYPE CHAR10     VALUE 'ERTIMLO',
               LC_ERTCODE    TYPE CHAR10     VALUE 'ERTCODE',
               LC_EREMPNO    TYPE CHAR10     VALUE 'EREMPNO',
               LC_AENAM      TYPE CHAR10     VALUE 'AENAM',
               LC_AEDAT      TYPE CHAR10     VALUE 'AEDAT',
               LC_AEZEIT     TYPE CHAR10     VALUE 'AEZEIT',
               LC_AEDATLO    TYPE CHAR10     VALUE 'AEDATLO',
               LC_AETIMLO    TYPE CHAR10     VALUE 'AETIMLO',
               LC_AETCODE    TYPE CHAR10     VALUE 'AETCODE',
               LC_AEEMPNO    TYPE CHAR10     VALUE 'AEEMPNO',
               LC_SEU_INT    TYPE CHAR10     VALUE 'SEU_INT',
               LC_UTC_9      TYPE TZNZONESYS VALUE 'UTC+9',
               LC_TITLE      TYPE SY-TITLE   VALUE 'DMS 문서*',
               LC_ATTACH_DOC TYPE SY-CPROG   VALUE 'ZCM_ATTACH_DOCUMENT'.

    DEFINE __SET_DATA.
      IF SY-SUBRC EQ 0.  &1 = &2.  ENDIF.
    END-OF-DEFINITION.

*// Get IP Addr
*    DATA : LV_ADDRSTR TYPE NI_NODEADDR,
*           LV_IP      TYPE RFCIPADDR.
*    CALL FUNCTION 'TH_USER_INFO'
*      IMPORTING
*        ADDRSTR = LV_ADDRSTR.
*    LV_IP = LV_ADDRSTR.

***    SELECT SINGLE TZONESYS INTO @DATA(LV_TZONE_SYS)
***      FROM TTZCU.
    DATA(LV_TZONE_SYS) = LC_UTC_9.

    SELECT SINGLE TZONE INTO @DATA(LV_TZONE_LO)
      FROM USR02
     WHERE BNAME EQ @SY-UNAME.

*.- Local 시간을 UTC로 변경
    CONVERT DATE SY-DATLO TIME SY-TIMLO
            INTO TIME STAMP DATA(LV_TIMESTAMP) TIME ZONE LV_TZONE_LO.

*.- UTC 시간을 본사 System 시간으로 변경
    CONVERT TIME STAMP LV_TIMESTAMP TIME ZONE LV_TZONE_SYS
            INTO DATE DATA(LV_DATUM) TIME DATA(LV_UZEIT).


    APPEND VALUE #( SIGN = 'I' OPTION = 'CP' LOW = LC_TITLE  HIGH = '' ) TO LR_TITLE.


    DATA(LV_EMP_NO) = ZGTSD_CL_COMMON=>GET_LOGIN_EMP_NO( ).      "로그온 사용자

    IF IV_GUBUN EQ GC_C OR IV_GUBUN EQ GC_A.
      ASSIGN COMPONENT LC_ERNAM   OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-UNAME.
*      <LV_VAL> = COND #( WHEN SY-SUBRC EQ 0 THEN SY-UNAME ).

      ASSIGN COMPONENT LC_ERDAT   OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_DATUM.

      ASSIGN COMPONENT LC_ERZEIT  OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_UZEIT.

      ASSIGN COMPONENT LC_ERDATLO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-DATLO.

      ASSIGN COMPONENT LC_ERTIMLO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-TIMLO.

      ASSIGN COMPONENT LC_ERTCODE OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      IF SY-SUBRC EQ 0.
        <LV_VAL> = COND #( WHEN SY-TCODE NE LC_SEU_INT THEN SY-TCODE      ELSE SY-CPROG ).
        <LV_VAL> = COND #( WHEN SY-TITLE IN LR_TITLE   THEN LC_ATTACH_DOC ELSE <LV_VAL> ).
      ENDIF.

      ASSIGN COMPONENT LC_EREMPNO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_EMP_NO.

    ENDIF.

    IF IV_GUBUN EQ GC_U OR IV_GUBUN EQ GC_A.
      ASSIGN COMPONENT LC_AENAM   OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-UNAME.

      ASSIGN COMPONENT LC_AEDAT   OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_DATUM.

      ASSIGN COMPONENT LC_AEZEIT  OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_UZEIT.

      ASSIGN COMPONENT LC_AEDATLO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-DATLO.

      ASSIGN COMPONENT LC_AETIMLO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> SY-TIMLO.

      ASSIGN COMPONENT LC_AETCODE OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      IF SY-SUBRC EQ 0.
        <LV_VAL> = COND #( WHEN SY-TCODE NE LC_SEU_INT THEN SY-TCODE      ELSE SY-CPROG ).
        <LV_VAL> = COND #( WHEN SY-TITLE IN LR_TITLE   THEN LC_ATTACH_DOC ELSE <LV_VAL> ).
      ENDIF.

      ASSIGN COMPONENT LC_AEEMPNO OF STRUCTURE CS_TIMESTAMP TO <LV_VAL>.
      __SET_DATA <LV_VAL> LV_EMP_NO.

    ENDIF.
  ENDMETHOD.


  METHOD ZSE16N.

    DATA LT_SELFLD TYPE SE16N_OR_T.

    CALL FUNCTION 'SE16N_UT_GET_SELECT_CRITERIA'
      EXPORTING
        I_TAB           = IV_TAB_NAME
      CHANGING
        ET_OR_SELFIELDS = LT_SELFLD.


    CALL FUNCTION 'SE16N_INTERFACE'
      EXPORTING
        I_TAB           = IV_TAB_NAME
        I_EDIT          = 'X'
        I_SAPEDIT       = 'X'
        I_MAX_LINES     = IV_MAX_LINES
      TABLES
        IT_OR_SELFIELDS = LT_SELFLD.

  ENDMETHOD.
ENDCLASS.
