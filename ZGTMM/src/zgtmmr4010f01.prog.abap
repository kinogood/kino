*&---------------------------------------------------------------------*
*& Include          ZGTMMR4010F01
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

  RANGES : LR_DATE FOR SY-DATLO,
           LR_USER FOR SY-UNAME.


  "S_AEDAT/S_RDATE/S_ADATE
  LR_DATE[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = SY-DATLO - 7
                         HIGH   = SY-DATLO ) ).

  "S_RUSER/S_AUSER
  LR_USER[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-UNAME ) ).

  CASE 'X'.
    WHEN P_RQP.
      CHECK GV_RAD <> GC_RQP.
      GV_RAD = GC_RQP.

      PERFORM SET_DEF TABLES S_AEDAT LR_DATE.

    WHEN P_RQD.
      CHECK GV_RAD <> GC_RQD.
      GV_RAD = GC_RQD.

      CLEAR : S_AUSER[], S_ADATE[].
      PERFORM SET_DEF TABLES S_RUSER LR_USER. "Hidden
      PERFORM SET_DEF TABLES S_RDATE LR_DATE.

    WHEN P_APM.
      CHECK GV_RAD <> GC_APM.
      GV_RAD = GC_APM.

      CLEAR : S_RUSER[], S_ADATE[].
      PERFORM SET_DEF TABLES S_RDATE LR_DATE.
      PERFORM SET_DEF TABLES S_AUSER LR_USER. "Hidden

    WHEN P_APD.
      CHECK GV_RAD <> GC_APD.
      GV_RAD = GC_APD.

      CLEAR : S_RUSER[], S_RDATE[].
      PERFORM SET_DEF TABLES S_AUSER LR_USER. "Hidden
      PERFORM SET_DEF TABLES S_ADATE LR_DATE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_AEDAT
*&      --> LR_DATE
*&---------------------------------------------------------------------*
FORM SET_DEF TABLES PT_OVAL
                    PT_IVAL.

  READ TABLE PT_OVAL INDEX 1.
  ASSIGN COMPONENT 'LOW' OF STRUCTURE PT_OVAL TO FIELD-SYMBOL(<LFS_LOW>).

  CHECK PT_OVAL[] IS INITIAL
     OR <LFS_LOW> IS INITIAL.

  PT_OVAL[] = PT_IVAL[].

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

  CLEAR : GR_GR1[], GR_SNM[].

  CASE 'X'.
    WHEN P_RQP.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_BT LOW = GC_C07 HIGH = GC_C10 ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_WERKS )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_EKGRP-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_AEDAT-LOW ) ).

    WHEN P_RQD.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_CP LOW = GC_C* )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C04 )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C08 ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_RUSER-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_RDATE-LOW ) ).

    WHEN P_APM.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_CP LOW = GC_C* )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C07 )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C08 ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_RDATE-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_AUSER-LOW ) ).

    WHEN P_APD.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_CP LOW = GC_C* )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C04 )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C07 )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C08 )
                          ( SIGN = GC_E OPTION = GC_EQ LOW = GC_C10 ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_AUSER-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_ADATE-LOW ) ).

  ENDCASE.

  APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_BUKRS ) TO GR_SNM.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 IN GR_GR1.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME IN GR_SNM.
      SCREEN-REQUIRED = 2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ACTV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ACTV.

  "Pgm.실행 Active Flag Check(SJM 25.04.17)

  SELECT SINGLE FLD_03
    FROM ZGTPPT1010 INTO @DATA(LV_CHK)
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0200
     AND FLD_01      = @GC_ZGTMMR4010.

  CHECK LV_CHK IS INITIAL.
  MESSAGE E134. "해당 Pgm.은 실행 불가한 상태입니다.

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

  CHECK P_RQP = GC_X.

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

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
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_WERKS.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'T001L'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           'P_WERKS'.

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

  CASE 'X'.
    WHEN P_RQP.
      IF P_BUKRS   IS INITIAL OR P_WERKS IS INITIAL
      OR S_EKGRP[] IS INITIAL OR S_AEDAT[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_RQD.
      IF P_BUKRS   IS INITIAL
      OR S_RUSER[] IS INITIAL OR S_RDATE[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_APM.
      IF P_BUKRS   IS INITIAL
      OR S_RDATE[] IS INITIAL OR S_AUSER[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_APD.
      IF P_BUKRS   IS INITIAL
      OR S_AUSER[] IS INITIAL OR S_ADATE[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

  ENDCASE.

  IF GV_ERR = GC_X.
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    EXIT.
  ENDIF.

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

  CHECK GV_ERR  IS INITIAL.
  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK LV_BUKRS IS INITIAL.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE S016 WITH '회사코드'(F02) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

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

  CHECK GV_ERR  IS INITIAL.
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
  MESSAGE S016 WITH '플랜트'(F17) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

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
    WHEN P_RQP.
      PERFORM GET_RQP_DATA.

    WHEN P_RQD.
      PERFORM GET_RQD_DATA.

    WHEN P_APM.
      PERFORM GET_APM_DATA.

    WHEN P_APD.
      PERFORM GET_APD_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RQP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_RQP_DATA.

  " Status - 1)변경: ICON_CHANGE
  "          2)신규: ICON_CREATE
  "          3)ZGTMM_CV_GETEKPODATA-ING='X': ICON_TRANSPORT

  CLEAR : GT_HRQP[], GT_IRQP[], GT_ORQP[].

  SELECT CASE WHEN ING = 'X' THEN @ICON_TRANSPORT
                             ELSE @SPACE
                             END AS STATUS,
         EBELP AS EBELP_O,
         P~*
    FROM ZGTMM_CV_GETEKPODATA AS P
    INTO CORRESPONDING FIELDS OF TABLE @GT_HRQP
   WHERE BUKRS  = @P_BUKRS
     AND WERKS  = @P_WERKS
     AND BSART IN @S_BSART
     AND EKGRP IN @S_EKGRP
     AND LIFNR IN @S_LIFNR
     AND EBELN IN @S_EBELN
     AND AEDAT IN @S_AEDAT
     AND LOEKZ  = @SPACE
     AND ELIKZ  = @SPACE
     AND LAND1  = @GC_KR. "추가(SJM 25.02.17)

  CASE 'X'.
    WHEN P_NDS.
      DELETE GT_HRQP WHERE NOT ( EMLIF = SPACE AND KUNNR = SPACE ).
    WHEN P_YDS.
      DELETE GT_HRQP WHERE NOT ( EMLIF <> SPACE OR KUNNR <> SPACE ).
  ENDCASE.

  IF GT_HRQP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  "Inbound 수량 or 입고수량 > 0인 해당 PO는 직납업체, 직납고객 변경 불가(SJM 25.03.12)
  PERFORM SET_STYLE USING 'E' 'EMLIF' GT_HRQP-STYLE.
  PERFORM SET_STYLE USING 'E' 'KUNNR' GT_HRQP-STYLE.
  MODIFY GT_HRQP TRANSPORTING STYLE
                 WHERE NOT ( INBQTY > 0 OR GRQTY > 0 ).

* PERFORM SET_COLOR USING 'EBELN' '3' '0' '0' GT_HRQP-COLOR.
* PERFORM SET_COLOR USING 'EBELP' '3' '0' '0' GT_HRQP-COLOR.
* MODIFY GT_HRQP TRANSPORTING COLOR WHERE COLOR IS INITIAL.

  SORT GT_HRQP BY EBELN EBELP.

  GV_CNT = LINES( GT_HRQP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

  PERFORM SET_ORQP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_HRQP_STYLE
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
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GT_HRQP_COLOR
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
*& Form SET_ORQP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORQP.

  GT_ORQP[] = GT_HRQP[]. "최초 조회건
  CLEAR : GT_ERR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIN_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HRQD
*&---------------------------------------------------------------------*
FORM SET_LIN_COL TABLES PT_HLIST STRUCTURE GT_HAPP.

  DATA : LV_ZGUID TYPE GUID_32.

  DATA(LV_COL) = GC_C500.


  LOOP AT PT_HLIST.
    IF LV_ZGUID <> PT_HLIST-ZGUID.
      CASE LV_COL.
        WHEN 'C500'.
          LV_COL = GC_C200.
        WHEN OTHERS.
          LV_COL = GC_C500.
      ENDCASE.
    ENDIF.

    PT_HLIST-L_COL = LV_COL.
    MODIFY PT_HLIST TRANSPORTING L_COL.

    LV_ZGUID = PT_HLIST-ZGUID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RQD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_RQD_DATA.

* CLEAR : GT_HRQD[], GT_IRQD[].
  CLEAR : GT_HAPP[], GT_IAPP[].

  SELECT CASE WHEN APPSTAT = ' ' THEN @ICON_TRANSPORT
              WHEN APPSTAT = 'R' THEN @ICON_LED_RED
              WHEN APPSTAT = 'A'
               AND TYPE    = 'E' THEN @ICON_MESSAGE_ERROR
              WHEN APPSTAT = 'A' THEN @ICON_LED_GREEN
                                 ELSE @SPACE
                                 END AS STATUS,
         P~*
    FROM ZGTMM_CV_PODIVAPPLIST AS P
    INTO CORRESPONDING FIELDS OF TABLE @GT_HAPP
   WHERE BUKRS        = @P_BUKRS
     AND LIFNR       IN @S_LIFNR
     AND ERDAT_LOCAL IN @S_RDATE
     AND ERNAM       IN @S_RUSER "SY-UNAME
     AND CANCEL       = @SPACE.

  IF GT_HAPP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HAPP BY ZGUID EBELN.

  PERFORM SET_LIN_COL TABLES GT_HAPP.

  GV_CNT = LINES( GT_HAPP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_APM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_APM_DATA.

* CLEAR : GT_HAPM[], GT_IAPM[].
  CLEAR : GT_HAPP[], GT_IAPP[].

  SELECT *
    FROM ZGTMM_CV_PODIVAPPLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_HAPP
   WHERE BUKRS        = @P_BUKRS
     AND ERDAT_LOCAL IN @S_RDATE
     AND ERNAM       IN @S_RUSER
     AND CANCEL       = @SPACE
     AND APPUSER     IN @S_AUSER "SY-UNAME
     AND APPSTAT      = @SPACE.

  IF GT_HAPP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HAPP BY ZGUID EBELN.

  PERFORM SET_LIN_COL TABLES GT_HAPP.

  GV_CNT = LINES( GT_HAPP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_APD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_APD_DATA.

* CLEAR : GT_HAPD[], GT_IAPD[].
  CLEAR : GT_HAPP[], GT_IAPP[].

  SELECT CASE WHEN APPSTAT = ' ' THEN @ICON_TRANSPORT "의미가 없네..
              WHEN APPSTAT = 'R' THEN @ICON_LED_RED
              WHEN APPSTAT = 'A' THEN @ICON_LED_GREEN
                                 ELSE @SPACE
                                 END AS STATUS,
         P~*
    FROM ZGTMM_CV_PODIVAPPLIST AS P
    INTO CORRESPONDING FIELDS OF TABLE @GT_HAPP
   WHERE BUKRS        = @P_BUKRS
     AND LIFNR       IN @S_LIFNR
     AND APPSTAT     <> @SPACE
     AND ERDAT_LOCAL IN @S_RDATE
     AND ERNAM       IN @S_RUSER
     AND AEDAT_LOCAL IN @S_ADATE
     AND APPUSER     IN @S_AUSER. "AENAM/SY-UNAME

  IF GT_HAPP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HAPP BY ZGUID EBELN.

  PERFORM SET_LIN_COL TABLES GT_HAPP.

  GV_CNT = LINES( GT_HAPP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

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

  CLEAR : GT_EXCD[], GV_TITLE.

  CASE 'X'.
    WHEN P_RQP.
      GV_TITLE  = SY-TITLE && ` - ` && TEXT-R04.
      GT_EXCD[] = VALUE #( ( 'CCAP' )
                           ( 'REPC' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

    WHEN P_RQD.
      GV_TITLE  = SY-TITLE && ` - ` && TEXT-R05.
      GT_EXCD[] = VALUE #( ( 'PCAP' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

    WHEN P_APM.
      GV_TITLE  = SY-TITLE && ` - ` && TEXT-R06.
      GT_EXCD[] = VALUE #( ( 'PCAP' )
                           ( 'CCAP' )
                           ( 'REPC' ) ).

    WHEN P_APD.
      GV_TITLE  = SY-TITLE && ` - ` && TEXT-R07.
      GT_EXCD[] = VALUE #( ( 'PCAP' )
                           ( 'CCAP' )
                           ( 'REPC' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

  ENDCASE.

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

  GR_HDOCK = NEW #( REPID     = SY-REPID
                    DYNNR     = SY-DYNNR
                    SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                    EXTENSION = 655 ).

  GR_SPLIT = NEW #( PARENT  = GR_HDOCK
                    ROWS    = 2
                    COLUMNS = 1 ).

  "#1 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

  "#2 Row
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
*&---------------------------------------------------------------------*
FORM SET_EXCL TABLES PT_EXCL TYPE UI_FUNCTIONS.

  CLEAR : PT_EXCL[].

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

* PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL  ) ).

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

  IF P_RQP = GC_X.
    PS_LAYO-STYLEFNAME = GC_STYLE.
    PS_LAYO-CTAB_FNAME = GC_COLOR.
  ENDIF.

  CASE PV_TYPE.
    WHEN 'H'.
      CASE 'X'.
        WHEN P_RQP.
          PS_LAYO-GRID_TITLE = '구매오더정보'(T01).

        WHEN P_RQD OR P_APM.
          PS_LAYO-GRID_TITLE = '상신정보'(T02).
          PS_LAYO-INFO_FNAME = GC_L_COL.

        WHEN P_APD.
          PS_LAYO-GRID_TITLE = '승인현황'(T03).
          PS_LAYO-INFO_FNAME = GC_L_COL.

      ENDCASE.

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '분할정보'(T04).

  ENDCASE.

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
      CASE 'X'.
        WHEN P_RQP.
          SET HANDLER GR_EVENTS->HANDLE_TOOLBAR       FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND  FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

          PERFORM SET_EVNT_EDIT USING PR_GRID.

        WHEN P_RQD.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

        WHEN P_APM.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

        WHEN P_APD.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

      ENDCASE.

    WHEN 'GR_IGRID'.
      CASE 'X'.
        WHEN P_RQP.
          SET HANDLER GR_EVENTS->HANDLE_TOOLBAR       FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND  FOR PR_GRID.

          PERFORM SET_EVNT_EDIT USING PR_GRID.

        WHEN P_RQD.


        WHEN P_APM.


        WHEN P_APD.


      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT_EDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT_EDIT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR PR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR PR_GRID.

  CALL METHOD PR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HRQP
*&      --> GT_IRQP
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_HLIST
                          PT_ILIST.

  PERFORM SET_FCAT TABLES GT_HFCAT
                    USING 'H'.
  PERFORM SET_DISP TABLES GT_HEXCL
                          GT_HFCAT
                          PT_HLIST
                    USING GR_HGRID
                          GS_HLAYO 'H'.

  PERFORM SET_FCAT TABLES GT_IFCAT
                    USING 'I'.
  PERFORM SET_DISP TABLES GT_IEXCL
                          GT_IFCAT
                          PT_ILIST
                    USING GR_IGRID
                          GS_ILAYO 'I'.

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

  CASE 'X'.
    WHEN P_RQP.
      PERFORM SET_HRQP_FCAT.

    WHEN OTHERS.
      PERFORM SET_HAPP_FCAT.

*   WHEN P_RQD.
*     PERFORM SET_HRQD_FCAT.
*   WHEN P_APM.
*     PERFORM SET_HAPM_FCAT.
*   WHEN P_APD.
*     PERFORM SET_HAPD_FCAT.

  ENDCASE.

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

  CASE 'X'.
    WHEN P_RQP.
      PERFORM SET_IRQP_FCAT.

    WHEN OTHERS.
      PERFORM SET_IAPP_FCAT.

*   WHEN P_RQD.
*     PERFORM SET_IRQD_FCAT.
*   WHEN P_APM.
*     PERFORM SET_IAPM_FCAT.
*   WHEN P_APD.
*     PERFORM SET_IAPD_FCAT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HRQP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HRQP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '상태'(F01),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F02),

          'S' 'FIELDNAME'  'BUKRS_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사명'(F03),

          'S' 'FIELDNAME'  'EKORG',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '구매조직'(F04),

          'S' 'FIELDNAME'  'EKORG_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '구매조직명'(F05),

          'S' 'FIELDNAME'  'BSART',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '문서유형'(F06),

          'S' 'FIELDNAME'  'BSART_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '문서유형명'(F07),

          'S' 'FIELDNAME'  'BSTYP',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '문서범주'(F08),

          'S' 'FIELDNAME'  'EKGRP',
          ' ' 'OUTPUTLEN'  3,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '구매그룹'(F09),

          'S' 'FIELDNAME'  'EKGRP_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '구매그룹명'(F10),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '공급업체'(F11),

          'S' 'FIELDNAME'  'LIFNR_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F12),

*         'S' 'FIELDNAME'  'SPGCD',       "삭제(SJM 25.02.17)
*         ' ' 'OUTPUTLEN'  2,
*         'E' 'COLTEXT'    'SPG코드'(F13),
*
*         'S' 'FIELDNAME'  'SPGNAME',     "삭제(SJM 25.02.17)
*         ' ' 'OUTPUTLEN'  20,
*         'E' 'COLTEXT'    'SPG명'(F14),

          'S' 'FIELDNAME'  'EBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'KEY'        'X',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    'PO번호'(F15), "구매오더

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
*         ' ' 'KEY'        'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '항번'(F16),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트'(F17),

          'S' 'FIELDNAME'  'WERKS_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트명'(F18),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치'(F19),

          'S' 'FIELDNAME'  'LGORT_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치명'(F20),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          'E' 'COLTEXT'    '자재코드'(F21),

          'S' 'FIELDNAME'  'TXZ01',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F22),

          'S' 'FIELDNAME'  'LOEKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '삭제지시자'(F23),

          'S' 'FIELDNAME'  'MENGE',
          ' ' 'OUTPUTLEN'  21,
*         ' ' 'REF_FIELD'  'MENGE',
*         ' ' 'REF_TABLE'  'EKPO',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '수량'(F24),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F25),

          'S' 'FIELDNAME'  'ELIKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '납품완료'(F26),

          'S' 'FIELDNAME'  'EMLIF',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EDIT'       'X',
          ' ' 'REF_FIELD'  'EMLIF',  "추가(SJM 25.02.17)
          ' ' 'REF_TABLE'  'EKPO',   "추가(SJM 25.02.17)
          'E' 'COLTEXT'    '직납업체'(F27),

          'S' 'FIELDNAME'  'EMLIF_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납업체명'(F28),

          'S' 'FIELDNAME'  'LBLKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '외주공급업체'(F29),

          'S' 'FIELDNAME'  'KUNNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EDIT'       'X',
          ' ' 'REF_FIELD'  'KUNNR',  "추가(SJM 25.02.17)
          ' ' 'REF_TABLE'  'EKPO',   "추가(SJM 25.02.17)
          'E' 'COLTEXT'    '직납고객'(F30),

          'S' 'FIELDNAME'  'KUNNR_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납고객명'(F31),

          'S' 'FIELDNAME'  'INBQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
*         ' ' 'NO_OUT'     'X',  "변경(SJM 25.02.17)
          'E' 'COLTEXT'    'Inbound수량'(F32),

          'S' 'FIELDNAME'  'GRQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
*         ' ' 'NO_OUT'     'X',  "변경(SJM 25.02.17)
          'E' 'COLTEXT'    '입고수량'(F33),

          'S' 'FIELDNAME'  'REQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
*         ' ' 'NO_OUT'     'X',  "변경(SJM 25.02.17)
          'E' 'COLTEXT'    '잔여수량'(F34),

          'S' 'FIELDNAME'  'MAXQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'MAX수량'(F35),

          'S' 'FIELDNAME'  'AEDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성일'(F36),

          'S' 'FIELDNAME'  'ING',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인진행여부'(F37).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HNO.

  CLEAR : GS_HNO.

  CASE 'X'.
    WHEN P_RQD.

    WHEN P_APM.
      GS_HNO-01 = GS_HNO-04 = GS_HNO-08 = GS_HNO-09 = GS_HNO-10
    = GS_HNO-16 = GS_HNO-17 = GS_HNO-18 = GS_HNO-21 = GC_X.

    WHEN P_APD.
      GS_HNO-18 = GS_HNO-21 = GC_X.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HAPP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HAPP_FCAT.

  PERFORM SET_HNO.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     GS_HNO-01,
          'E' 'COLTEXT'    '상태'(F01),

          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'GUID'(F38),

          'S' 'FIELDNAME'  'APPSTAT',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인상태'(F39),

          'S' 'FIELDNAME'  'APPSTAT_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     GS_HNO-04,
          'E' 'COLTEXT'    '승인상태명'(F40),

          'S' 'FIELDNAME'  'ERDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '요청일'(F41),

          'S' 'FIELDNAME'  'ERNAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '요청자'(F42),

          'S' 'FIELDNAME'  'ERNAM_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '요청자명'(F43),

          'S' 'FIELDNAME'  'AEDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     GS_HNO-08,
          'E' 'COLTEXT'    '승인일'(F44),

          'S' 'FIELDNAME'  'APPUSER',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     GS_HNO-09,
          'E' 'COLTEXT'    '승인자'(F45),

          'S' 'FIELDNAME'  'APPUSER_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     GS_HNO-10,
          'E' 'COLTEXT'    '승인자명'(F46),

          'S' 'FIELDNAME'  'EBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          ' ' 'HOTSPOT'    'X',
          'E' 'COLTEXT'    'PO번호'(F15), "구매오더

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '공급업체'(F11),

          'S' 'FIELDNAME'  'LIFNR_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F12),

          'S' 'FIELDNAME'  'MAILTEXT',
          ' ' 'OUTPUTLEN'  50,
          'E' 'COLTEXT'    '비고'(F47),

          'S' 'FIELDNAME'  'REJRES',
          ' ' 'OUTPUTLEN'  3,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '반려사유코드'(F48),

          'S' 'FIELDNAME'  'REJRES_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     GS_HNO-16,
          'E' 'COLTEXT'    '반려사유명'(F49),

          'S' 'FIELDNAME'  'RETC',
          ' ' 'OUTPUTLEN'  50,
          ' ' 'NO_OUT'     GS_HNO-17,
          'E' 'COLTEXT'    '비고(반려)'(F50),

          'S' 'FIELDNAME'  'TYPE',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     GS_HNO-18,
          'E' 'COLTEXT'    'S,W,E'(F51),

          'S' 'FIELDNAME'  'ID',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '메시지 클래스'(F52),

          'S' 'FIELDNAME'  'ZNUMBER',
          ' ' 'OUTPUTLEN'  3,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '메시지 번호'(F53),

          'S' 'FIELDNAME'  'MESSAGE',
          ' ' 'OUTPUTLEN'  50,
          ' ' 'NO_OUT'     GS_HNO-21,
          'E' 'COLTEXT'    '메시지 텍스트'(F54).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IRQP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IRQP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '상태'(F01),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '회사코드'(F02),

          'S' 'FIELDNAME'  'BUKRS_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '회사명'(F03),

          'S' 'FIELDNAME'  'EKORG',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매조직'(F04),

          'S' 'FIELDNAME'  'EKORG_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매조직명'(F05),

          'S' 'FIELDNAME'  'BSART',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '문서유형'(F06),

          'S' 'FIELDNAME'  'BSART_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '문서유형명'(F07),

          'S' 'FIELDNAME'  'BSTYP',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '문서범주'(F08),

          'S' 'FIELDNAME'  'EKGRP',
          ' ' 'OUTPUTLEN'  3,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매그룹'(F09),

          'S' 'FIELDNAME'  'EKGRP_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '구매그룹명'(F10),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '공급업체'(F11),

          'S' 'FIELDNAME'  'LIFNR_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F12), "공급업체명

*         'S' 'FIELDNAME'  'SPGCD',       "삭제(SJM 25.02.17)
*         ' ' 'OUTPUTLEN'  2,
*         ' ' 'NO_OUT'     'X',
*         'E' 'COLTEXT'    'SPG코드'(F13),
*
*         'S' 'FIELDNAME'  'SPGNAME',     "삭제(SJM 25.02.17)
*         ' ' 'OUTPUTLEN'  20,
*         ' ' 'NO_OUT'     'X',
*         'E' 'COLTEXT'    'SPG명'(F14),

          'S' 'FIELDNAME'  'EBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'KEY'        'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    'PO번호'(F15), "구매오더

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
*         ' ' 'KEY'        'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '항번'(F16),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트'(F17),

          'S' 'FIELDNAME'  'WERKS_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트명'(F18),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치'(F19),

          'S' 'FIELDNAME'  'LGORT_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치명'(F20),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          'E' 'COLTEXT'    '자재코드'(F21),

          'S' 'FIELDNAME'  'TXZ01',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F22),

          'S' 'FIELDNAME'  'LOEKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '삭제지시자'(F23),

          'S' 'FIELDNAME'  'MENGE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'REF_FIELD'  'MENGE',
          ' ' 'REF_TABLE'  'EKPO',
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'EDIT'       'X',
          'E' 'COLTEXT'    '수량'(F24),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F25),

          'S' 'FIELDNAME'  'ELIKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '납품완료'(F26),

          'S' 'FIELDNAME'  'EMLIF',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EDIT'       'X',
          ' ' 'REF_FIELD'  'EMLIF',  "추가(SJM 25.02.17)
          ' ' 'REF_TABLE'  'EKPO',   "추가(SJM 25.02.17)
          'E' 'COLTEXT'    '직납업체'(F27),

          'S' 'FIELDNAME'  'EMLIF_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납업체명'(F28),

          'S' 'FIELDNAME'  'LBLKZ',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '외주공급업체'(F29),

          'S' 'FIELDNAME'  'KUNNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EDIT'       'X',
          ' ' 'REF_FIELD'  'KUNNR',  "추가(SJM 25.02.17)
          ' ' 'REF_TABLE'  'EKPO',   "추가(SJM 25.02.17)
          'E' 'COLTEXT'    '직납고객'(F30),

          'S' 'FIELDNAME'  'KUNNR_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납고객명'(F31),

          'S' 'FIELDNAME'  'INBQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'Inbound수량'(F32),

          'S' 'FIELDNAME'  'GRQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '입고수량'(F33),

          'S' 'FIELDNAME'  'REQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '잔여수량'(F34),

          'S' 'FIELDNAME'  'MAXQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    'MAX수량'(F35),

          'S' 'FIELDNAME'  'AEDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생성일'(F36),

          'S' 'FIELDNAME'  'ING',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인진행여부'(F37).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IAPP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IAPP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'EBELN',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'PO번호'(F15), "구매오더

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F16),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          'E' 'COLTEXT'    '자재코드'(F21),

          'S' 'FIELDNAME'  'TXZ01',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F22),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '플랜트'(F17),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '저장위치'(F19),

          'S' 'FIELDNAME'  'MENGE_O',
          ' ' 'OUTPUTLEN'  21,
*         ' ' 'REF_FIELD'  'MENGE',
*         ' ' 'REF_TABLE'  'EKPO',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '수량(기존)'(F55),

          'S' 'FIELDNAME'  'MENGE_N',
          ' ' 'OUTPUTLEN'  21,
*         ' ' 'REF_FIELD'  'MENGE',
*         ' ' 'REF_TABLE'  'EKPO',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '수량(변경요청)'(F56),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F25),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '공급업체'(F11),

          'S' 'FIELDNAME'  'LIFNR_N',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F12),

          'S' 'FIELDNAME'  'EMLIF_O',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '직납업체(기존)'(F57),

          'S' 'FIELDNAME'  'EMLIF_O_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납업체명(기존)'(F58),

          'S' 'FIELDNAME'  'EMLIF_N',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '직납업체(변경)'(F59),

          'S' 'FIELDNAME'  'EMLIF_N_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납업체명(변경)'(F60),

          'S' 'FIELDNAME'  'KUNNR_O',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '직납고객(기존)'(F61),

          'S' 'FIELDNAME'  'KUNNR_O_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납고객명(기존)'(F62),

          'S' 'FIELDNAME'  'KUNNR_N',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '직납고객(변경)'(F63),

          'S' 'FIELDNAME'  'KUNNR_N_N',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '직납고객명(변경)'(F64),

          'S' 'FIELDNAME'  'ZNEW',
          ' ' 'OUTPUTLEN'  1,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '신규여부'(F65).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEXCL
*&      --> GT_HFCAT
*&      --> PT_HLIST
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
      CALL METHOD GR_HDOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_HCNTR, GR_ICNTR, GR_HDOCK.

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
*   LS_TBAR-CHECKED   = 'X'.
*   LS_TBAR-DISABLED  = 'X'.
    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 '  ' '  ' '  '.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE 'X'.
        WHEN P_RQP.
          _SET_TBAR 0 'PODV' ' ' 'PO분할'(B01).

        WHEN P_RQD.
        WHEN P_APM.
        WHEN P_APD.

      ENDCASE.

    WHEN 'GR_IGRID'.
      CASE 'X'.
        WHEN P_RQP.
          _SET_TBAR 0 'APDV' ' ' '분할적용'(B02).
          _SET_TBAR 0 'DELE' ' ' '삭제'(B03).

        WHEN P_RQD.
        WHEN P_APM.
        WHEN P_APD.

      ENDCASE.

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
    WHEN 'PODV'. "PO분할
      PERFORM PRCS_PODV.

    WHEN 'APDV'. "분할적용
      PERFORM PRCS_APDV.

    WHEN 'DELE'. "삭제
      PERFORM PRCS_DELE.

  ENDCASE.

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
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_200
*&      --> P_10
*&      --> P_5
*&      --> P_70
*&      --> P_8
*&---------------------------------------------------------------------*
FORM CALL_SCREEN USING PV_DYNNR
                       PV_SC
                       PV_SL
                       PV_EC
                       PV_EL.

  CALL SCREEN PV_DYNNR STARTING AT PV_SC PV_SL
                         ENDING AT PV_EC PV_EL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_PODV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_PODV.

  CLEAR : GV_PRXX, GS_PRXX.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '분할 대상을 먼저 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  PERFORM CHECK_PODV.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_POD.
  GS_PRXX-DCNT = 2.

  PERFORM CALL_SCREEN USING 200 10 5
                                70 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PODV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PODV.

  READ TABLE GT_HRQP INTO GS_HRQP INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  CASE GS_HRQP-STATUS.
    WHEN ICON_TRANSPORT.
      MESSAGE S051 DISPLAY LIKE 'E'. "분할 승인 진행 중인 PO는 변경 불가합니다.
      GV_ERR = GC_X. EXIT.

    WHEN ICON_CREATE.
      MESSAGE S068 DISPLAY LIKE 'E'. "신규 추가 아이템은 분할이 불가합니다.
      GV_ERR = GC_X. EXIT.

  ENDCASE.

  IF GT_IRQP[] IS NOT INITIAL.
    "분할 진행 중인 PO가 존재합니다. 분할 적용이나 삭제를 먼저 진행하세요.
    MESSAGE S052 DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF GS_HRQP-REQTY <= 0. "추가(SJM 25.02.17)
    "더 이상 분할 할 수 없는 구매오더 항목입니다.
    MESSAGE S107 DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YPOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YPOD.

  "하단 ALV 첫번째 라인 Status
  DATA(LV_STATUS) = SWITCH #( GS_HRQP-STATUS WHEN ' ' OR ICON_CHANGE THEN ICON_CHANGE    "기존 PO 변경 대상
                                             WHEN ICON_CREATE        THEN ICON_CREATE ). "PO Item 추가 대상

  "ICON_CHANGE : 상단 ALV 동일하게 복사
  "ICON_CREATE : 상단 ALV 기반 + EBELP/MENGE 값 Clear

  DO GS_PRXX-DCNT TIMES.
    MOVE-CORRESPONDING GS_HRQP TO GT_IRQP.

    IF SY-INDEX = 1.
      GT_IRQP-STATUS = LV_STATUS.
    ELSE.
      GT_IRQP-STATUS = ICON_CREATE.
    ENDIF.

    IF GT_IRQP-STATUS = ICON_CREATE.
      CLEAR : GT_IRQP-EBELP, GT_IRQP-MENGE.
      "PO Item 추가 라인은 직납업체, 직납고객 항상 변경 가능(SJM 25.03.12)
      CLEAR : GT_IRQP-STYLE.
      PERFORM SET_STYLE USING 'E' 'EMLIF' GT_IRQP-STYLE.
      PERFORM SET_STYLE USING 'E' 'KUNNR' GT_IRQP-STYLE.
    ENDIF.

    APPEND GT_IRQP.
  ENDDO.

  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

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

  CHECK PV_MODI IS NOT INITIAL.

  GT_MODI = PT_MODI.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      PERFORM CHNG_FNSH_HGRID.

    WHEN 'GR_IGRID'.
      PERFORM CHNG_FNSH_IGRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_HGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_HGRID.

  CASE 'X'.
    WHEN P_RQP.
      PERFORM CHANGE_HRQP_DATA.

    WHEN P_RQD.

    WHEN P_APM.

    WHEN P_APD.

  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_IGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_IGRID.

  CASE 'X'.
    WHEN P_RQP.
      PERFORM CHANGE_IRQP_DATA.

    WHEN P_RQD.

    WHEN P_APM.

    WHEN P_APD.

  ENDCASE.

* GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_HRQP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_HRQP_DATA.

  LOOP AT GT_MODI INTO GS_MODI.
    AT NEW ROW_ID.
      CLEAR : GV_SEQ.
    ENDAT.
    GV_TBX = GS_MODI-ROW_ID.
    GV_CHK = GC_H.

    READ TABLE GT_HRQP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    PERFORM CHECK_HRQP_CHNG.
    CHECK GV_ERR IS INITIAL.

    MOVE-CORRESPONDING GT_HRQP TO GS_DIR.
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_HRQP TO <GFS_COL>.

    CLEAR : GV_ERR, GV_MSG, GV_FNM.

    CASE GS_MODI-FIELDNAME.
      WHEN 'EMLIF'.
        PERFORM CHANGE_EMLIF.

      WHEN 'KUNNR'.
        PERFORM CHANGE_KUNNR.

    ENDCASE.

    MOVE-CORRESPONDING GS_DIR TO GT_HRQP.

    AT END OF ROW_ID.
      PERFORM CHECK_DUP_DIR.
      PERFORM SET_ERR_RST.

      PERFORM SET_XRQP_ERR USING GT_HRQP-ERR.
      PERFORM COMP_HRQP_CHNG.
    ENDAT.

    PERFORM SET_LIST_CUR USING GR_HGRID.
*   PERFORM SET_XRQP_ERR USING GT_HRQP-ERR.

    MODIFY GT_HRQP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_HRQP_CHNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_HRQP_CHNG.

  CLEAR : GV_ERR.

  CHECK GT_HRQP-STATUS = ICON_TRANSPORT.

  ASSIGN COMPONENT GS_MODI-FIELDNAME
      OF STRUCTURE GT_HRQP TO FIELD-SYMBOL(<LFS_VAL>).

  CLEAR : <LFS_VAL>.
  MODIFY GT_HRQP INDEX GS_MODI-ROW_ID.

  GV_ERR = GC_X.
  MESSAGE S051 DISPLAY LIKE 'E'. "분할 승인 진행 중인 PO는 변경 불가합니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMP_HRQP_CHNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM COMP_HRQP_CHNG.

  "상단 ALV에서 수정 발생시.. Status 반영
  " 입력값이 최초 에러였다가 삭제할 경우는 결국 변경이 아니므로 원본 비교 작업 추가

  CHECK <GFS_COL> IS INITIAL AND GT_HRQP-STATUS IS INITIAL.

  READ TABLE GT_ORQP WITH KEY EBELN = GT_HRQP-EBELN
                              EBELP = GT_HRQP-EBELP
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0 AND GT_ORQP <> GT_HRQP.

  GT_HRQP-STATUS = ICON_CHANGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_EMLIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_EMLIF.

* PERFORM CHECK_DUP_DIR.
* CHECK GV_ERR IS INITIAL.

  CLEAR : GS_DIR-EMLIF_N, GS_DIR-LBLKZ.

  PERFORM GET_LFA1 USING GS_DIR-EMLIF
                CHANGING GS_DIR-EMLIF_N.

  IF SY-SUBRC <> 0.
    MESSAGE E013 WITH GS_DIR-EMLIF INTO GV_MSG. "입력된 값이 올바르지 않습니다. &

    PERFORM SET_ERR_MSG USING 'EMLIF' 'V'.
    PERFORM SET_ERR_COL USING 'EMLIF'.
  ELSE.
    PERFORM DEL_ERR_MSG USING 'EMLIF' 'V'.

    IF GS_DIR-EMLIF IS NOT INITIAL.
      GS_DIR-LBLKZ = GC_X.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_FNM
                       PV_TYPE.

  GV_SEQ += 1.

  GS_ERR-GUBUN = GV_CHK.
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
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  GV_ERR = GC_X.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_ERR_MSG USING PV_FNM
                       PV_TYPE.

  GV_ERR = SPACE.
  CHECK GT_ERR IS NOT INITIAL.

  DELETE GT_ERR WHERE GUBUN = GV_CHK
                  AND INDEX = GV_TBX
                  AND FNAME = PV_FNM
                  AND TYPE  = PV_TYPE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_ERR_COL USING P_FNM.

  GV_ERR = SPACE.

  CHECK <GFS_COL> IS NOT INITIAL.
  DELETE <GFS_COL> WHERE FNAME = P_FNM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUP_DIR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DUP_DIR.

  "EMLIF/KUNNR 동시 존재하는 경우는 없음.
  " EMLIF 입력시 KUNNR 값이 존재하거나
  " KUNNR 입력시 EMLIF 값이 존재하면 에러처리

* CLEAR : GV_ERR.

  IF GS_DIR-EMLIF IS NOT INITIAL
 AND GS_DIR-KUNNR IS NOT INITIAL.
    MESSAGE E053 INTO GV_MSG. "직납업체와 직납고객은 동시 입력이 불가능합니다.

    PERFORM SET_ERR_MSG USING 'EMLIF' 'D'.
    PERFORM SET_ERR_MSG USING 'KUNNR' 'D'.
    PERFORM SET_ERR_COL USING 'EMLIF'.
    PERFORM SET_ERR_COL USING 'KUNNR'.
  ELSE.
    PERFORM DEL_ERR_MSG USING 'EMLIF' 'D'.
    PERFORM DEL_ERR_MSG USING 'KUNNR' 'D'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIR_EMLIF
*&      <-- GS_DIR_EMLIF_N
*&---------------------------------------------------------------------*
FORM GET_LFA1 USING PV_LIFNR
           CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM LFA1 INTO PV_NAME1
   WHERE LIFNR = PV_LIFNR
     AND LOEVM = SPACE
     AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_KUNNR.

* PERFORM CHECK_DUP_DIR.
* CHECK GV_ERR IS INITIAL.

  PERFORM GET_KNA1 USING GS_DIR-KUNNR
                CHANGING GS_DIR-KUNNR_N.

  IF SY-SUBRC <> 0.
    MESSAGE E013 WITH GS_DIR-KUNNR INTO GV_MSG. "입력된 값이 올바르지 않습니다. &

    PERFORM SET_ERR_MSG USING 'KUNNR' 'V'.
    PERFORM SET_ERR_COL USING 'KUNNR'.
  ELSE.
    PERFORM DEL_ERR_MSG USING 'KUNNR' 'V'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KNA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIR_KUNNR
*&      <-- GS_DIR_KUNNR_N
*&---------------------------------------------------------------------*
FORM GET_KNA1 USING PV_KUNNR
           CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_KUNNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM KNA1 INTO PV_NAME1
   WHERE KUNNR = PV_KUNNR
     AND LOEVM = SPACE
     AND SPRAS = SY-LANGU.

  "로그온 언어로 셋팅된 값이 없으면, 영어 셋팅 여부 추가 Check(SJM 25.04.14)
  CHECK SY-SUBRC <> 0.

  SELECT SINGLE NAME1
    FROM KNA1 INTO PV_NAME1
   WHERE KUNNR = PV_KUNNR
     AND LOEVM = SPACE
     AND SPRAS = GC_E.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ERR_RST.

  DATA : LR_FNAME TYPE RANGE OF LVC_FNAME,
         LV_CNT   TYPE I.


  CLEAR : GV_FNM, GV_MSG.

  READ TABLE GT_ERR INTO GS_ERR WITH KEY GUBUN = GV_CHK
                                         INDEX = GV_TBX
                                         BINARY SEARCH.

  IF SY-SUBRC = 0.
    LV_CNT += 1.

    IF LV_CNT = 1.
      GV_FNM = GS_ERR-FNAME.
      GV_MSG = GS_ERR-MSG.
    ENDIF.

    LOOP AT GT_ERR INTO GS_ERR FROM SY-TABIX.
      IF NOT ( GS_ERR-GUBUN = GV_CHK
           AND GS_ERR-INDEX = GV_TBX ).
        EXIT.
      ENDIF.

      APPEND VALUE #( SIGN   = GC_E
                      OPTION = GC_EQ
                      LOW    = GS_ERR-FNAME ) TO LR_FNAME.
    ENDLOOP.
  ELSE.
    CLEAR : <GFS_COL>.
  ENDIF.

  IF LR_FNAME[] IS NOT INITIAL.
    DELETE <GFS_COL> WHERE FNAME IN LR_FNAME.
  ENDIF.

  CHECK GV_MSG IS NOT INITIAL.
  MESSAGE S000 WITH GV_MSG+0(50) GV_MSG+50(50) DISPLAY LIKE 'E'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_CUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&---------------------------------------------------------------------*
FORM SET_LIST_CUR USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GV_FNM IS INITIAL.
    GV_FNM = GS_MODI-FIELDNAME.
  ENDIF.

  CLEAR : GS_ROW, GS_COL.
  GS_ROW-INDEX     = GV_TBX.
  GS_COL-FIELDNAME = GV_FNM.

  CALL METHOD PR_GRID->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = GS_ROW
      IS_COLUMN_ID = GS_COL.
*     IS_ROW_NO    =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XRQP_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HRQP_ERR
*&---------------------------------------------------------------------*
FORM SET_XRQP_ERR USING PV_ERR.

  IF <GFS_COL> IS NOT INITIAL.
    PV_ERR = GC_X.
  ELSE.
    PV_ERR = SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_IRQP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_IRQP_DATA.

  LOOP AT GT_MODI INTO GS_MODI.
    AT NEW ROW_ID.
      CLEAR : GV_SEQ.
    ENDAT.
    GV_TBX = GS_MODI-ROW_ID.
    GV_CHK = GC_I.

    READ TABLE GT_IRQP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    MOVE-CORRESPONDING GT_IRQP TO GS_DIR.
    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_IRQP TO <GFS_COL>.

    CLEAR : GV_ERR, GV_MSG, GV_FNM.

    CASE GS_MODI-FIELDNAME.
      WHEN 'MENGE'.
        PERFORM CHANGE_MENGE.

      WHEN 'EMLIF'.
        PERFORM CHANGE_EMLIF.

      WHEN 'KUNNR'.
        PERFORM CHANGE_KUNNR.

    ENDCASE.

    AT END OF ROW_ID.
      PERFORM CHECK_DUP_DIR.
      PERFORM SET_ERR_RST.

      PERFORM SET_XRQP_ERR USING GT_IRQP-ERR.
    ENDAT.

    PERFORM SET_LIST_CUR USING GR_IGRID.
*   PERFORM SET_XRQP_ERR USING GT_IRQP-ERR.

    MOVE-CORRESPONDING GS_DIR TO GT_IRQP.
    MODIFY GT_IRQP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_MENGE.

  IF GT_IRQP-EBELP IS NOT INITIAL
 AND GT_IRQP-MENGE IS NOT INITIAL.
    IF GT_IRQP-MENGE < GT_IRQP-MAXQTY.
      "이미 납품 처리된 수량보다 작게 변경할 수 없습니다."&"[납품서/입고 수량]"&ALV-MAXQTY&ALV-MEINS
      MESSAGE E055 WITH GT_IRQP-MAXQTY
                        GT_IRQP-MEINS INTO GV_MSG.
    ENDIF.
  ENDIF.

  PERFORM SET_XQTY USING GT_IRQP-EBELN
                         GT_IRQP-EBELP_O.

  IF GV_IQTY > GV_HQTY. "하단 입력 수량 Sum > 상단 원본 수량
    MESSAGE E054 INTO GV_MSG. "원본 수량을 초과했습니다.
  ENDIF.

  IF GV_MSG IS NOT INITIAL.
    PERFORM SET_ERR_MSG USING 'MENGE' 'V'.
    PERFORM SET_ERR_COL USING 'MENGE'.
  ELSE.
    PERFORM DEL_ERR_MSG USING 'MENGE' 'V'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_IRQP_EBELN
*&      --> GT_IRQP_EBELP_O
*&---------------------------------------------------------------------*
FORM SET_XQTY USING PV_EBELN
                    PV_EBELP_O.

  CLEAR : GV_HQTY, GV_IQTY.

  DATA(LT_IRQP) = GT_IRQP[].
  GV_IQTY = REDUCE MENGE_D( INIT X = CONV MENGE_D( 0 )
                             FOR LS_IRQP IN LT_IRQP
                           WHERE ( EBELN   = PV_EBELN
                               AND EBELP_O = PV_EBELP_O )
                            NEXT X = X + LS_IRQP-MENGE ).

  GV_HQTY = VALUE #( GT_HRQP[ EBELN   = PV_EBELN
                              EBELP_O = PV_EBELP_O ]-MENGE ).

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
      PERFORM READ_LIST_BY_INDEX USING PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'EBELN'.
          IF P_RQP = GC_X.
            PERFORM CALL_ME23N USING GT_HRQP-EBELN.
          ELSE.
            PERFORM GET_IAPP_DATA.
            PERFORM REFRESH_GRID USING GR_IGRID
                                       GS_ILAYO.
          ENDIF.

        WHEN OTHERS.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_LIST_BY_INDEX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROW_INDEX
*&---------------------------------------------------------------------*
FORM READ_LIST_BY_INDEX USING PV_INDEX.

  IF P_RQP = GC_X.
    READ TABLE GT_HRQP INDEX PV_INDEX.
  ELSE.
*   READ TABLE GT_HAPP INDEX PV_INDEX. "IT 공통화로 바로 Read Table해도 무방!
    PERFORM READ_HXXX TABLES GT_HAPP USING PV_INDEX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_HXXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HRQD
*&      --> PV_INDEX
*&---------------------------------------------------------------------*
FORM READ_HXXX TABLES PT_HXXX
                USING PV_INDEX.

  UNASSIGN : <GFS_ZGUID>, <GFS_EBELN>.

  READ TABLE PT_HXXX INDEX PV_INDEX.

  CHECK SY-SUBRC = 0.

  ASSIGN COMPONENT 'ZGUID' OF STRUCTURE PT_HXXX TO <GFS_ZGUID>.
  ASSIGN COMPONENT 'EBELN' OF STRUCTURE PT_HXXX TO <GFS_EBELN>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_ME23N
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HRQP_EBELN
*&---------------------------------------------------------------------*
FORM CALL_ME23N USING PV_EBELN.

  CHECK PV_EBELN IS NOT INITIAL.

  SET PARAMETER ID 'BES' FIELD PV_EBELN.
  CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IAPP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IAPP_DATA.

  CLEAR : GT_IAPP[], GV_CNT.

  SELECT * FROM ZGTMM_CV_PODIVAPPITEM
    INTO CORRESPONDING FIELDS OF TABLE @GT_IAPP
   WHERE ZGUID = @<GFS_ZGUID>  "GT_HAPP-ZGUID
     AND EBELN = @<GFS_EBELN>. "GT_HAPP-EBELN

  IF GT_IAPP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_IAPP BY EBELN EBELP.

  GV_CNT = LINES( GT_IAPP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_APDV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_APDV.

  PERFORM CHECK_APDV.
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HRQP WITH KEY EBELN = GT_IRQP-EBELN
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_HRQP FROM SY-TABIX.
    IF GT_HRQP-EBELN <> GT_IRQP-EBELN.
      EXIT.
    ENDIF.

*   DATA(LV_EBELP) = GT_HRQP-EBELP. "현 PO의 가장 마지막 Item No.

    "기존 PO Item 변경건일 경우, 하단 ALV Data 기준으로 Update
    IF GT_HRQP-EBELP = GT_IRQP-EBELP.
      PERFORM RESET_HRQP.
      MODIFY GT_HRQP.

      DELETE GT_IRQP INDEX 1.
    ENDIF.
  ENDLOOP.

  "신규 PO Item 추가건: 상단 ALV에 Line Insert
  IF GT_IRQP[] IS NOT INITIAL.
    "현 PO의 가장 마지막 Item No.(중간 Item이 삭제될 수도 있으므로)
    SELECT MAX( EBELP ) FROM EKPO
      INTO @DATA(LV_EBELP) WHERE EBELN = @GT_IRQP-EBELN.

    LOOP AT GT_IRQP.
      LV_EBELP += 10.
      GT_IRQP-EBELP = LV_EBELP. "GT_IRQP-EBELP_O =

      PERFORM RESET_HRQP.
      APPEND GT_HRQP.
    ENDLOOP.

    SORT GT_HRQP BY EBELN EBELP.
    CLEAR : GT_IRQP[].
  ENDIF.

  "하단 ALV 모든 정보는 상단 ALV에 적용한 후, 하단 ALV Clear

  GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_APDV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_APDV.

  CLEAR : GV_ERR.

  IF GT_IRQP[] IS INITIAL.
    MESSAGE S058 DISPLAY LIKE 'E'. "작업중인 데이터가 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF LINE_EXISTS( GT_IRQP[ MENGE = 0 ] ).
    MESSAGE S056 DISPLAY LIKE 'E'. "모든 수량을 입력해 주세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  READ TABLE GT_IRQP INDEX 1.
  PERFORM SET_XQTY USING GT_IRQP-EBELN
                         GT_IRQP-EBELP_O.

  IF GV_IQTY <> GV_HQTY. "하단 입력 수량 Sum <> 상단 원본 수량
    MESSAGE S057 DISPLAY LIKE 'E'. "원본 수량과 동일하지 않습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF LINE_EXISTS( GT_IRQP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_HRQP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_HRQP.

  MOVE-CORRESPONDING GT_IRQP TO GT_HRQP.
* PERFORM SET_COLOR USING 'EBELN' '3' '0' '0' GT_HRQP-COLOR.
* PERFORM SET_COLOR USING 'EBELP' '3' '0' '0' GT_HRQP-COLOR.

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
*& Form PRCS_DELE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_DELE.

  IF GT_IRQP[] IS INITIAL.
    MESSAGE S058 DISPLAY LIKE 'E'. "작업중인 데이터가 없습니다.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '작업중인 데이터가 삭제됩니다. 삭제하시겠습니까?'(P02).

  CHECK GV_ANS = GC_1.

  CLEAR : GT_IRQP[]. "전체 삭제만 가능!
  DELETE GT_ERR WHERE GUBUN = GC_I.

  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_PCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_PCAP.

  PERFORM CHECK_PCAP.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_TXT_DEF.

  PERFORM CALL_SCREEN USING 210 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PCAP.

  CLEAR : GV_ERR, GT_4012[], GT_4013[].

  IF LINE_EXISTS( GT_HRQP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  LOOP AT GT_HRQP.
    CHECK GT_HRQP-STATUS = ICON_CREATE
       OR GT_HRQP-STATUS = ICON_CHANGE.

    GT_4012 = CORRESPONDING #( GT_HRQP ).
    GT_4013 = VALUE #( BASE CORRESPONDING #( GT_HRQP )
                       ZNEW    = SWITCH #( GT_HRQP-STATUS WHEN ICON_CREATE THEN 'N'
                                                          WHEN ICON_CHANGE THEN 'C' )
                       EBELP_O = SWITCH #( GT_HRQP-STATUS WHEN ICON_CREATE THEN GT_HRQP-EBELP_O
                                                          WHEN ICON_CHANGE THEN ' ' ) ).
    COLLECT : GT_4012, GT_4013.
  ENDLOOP.

  IF GT_4012[] IS INITIAL.
    MESSAGE S069 DISPLAY LIKE 'E'. "상신할 데이터가 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  "선택한 라인만 대상인 경우...
* PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
*                                 '상신할 대상을 먼저 선택하세요.'(M02).
* CHECK GV_ERR IS INITIAL.
*  CLEAR : GT_4012[], GT_4013[].
*
*  LOOP AT GT_ROW INTO GS_ROW.
*    READ TABLE GT_HRQP INDEX GS_ROW-INDEX.
*    CHECK SY-SUBRC = 0.
*
*    IF GT_HRQP-STATUS = SPACE
*    OR GT_HRQP-STATUS = ICON_TRANSPORT.
*      MESSAGE S059 DISPLAY LIKE 'E'. "상신 불가능한 데이터가 포함되어 있습니다.
*      GV_ERR = GC_X. EXIT.
*    ENDIF.
*
*    GT_4012 = CORRESPONDING #( GT_HRQP ).
*    GT_4013 = VALUE #( BASE CORRESPONDING #( GT_HRQP )
*                       ZNEW = SWITCH #( GT_HRQP-STATUS WHEN ICON_CREATE THEN 'N'
*                                                       WHEN ICON_CHANGE THEN 'C' ) ).
*    COLLECT : GT_4012, GT_4013.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TXT_DEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TXT_DEF.

  DATA : LS_TEXT TYPE STRING,
         LT_TEXT LIKE TABLE OF LS_TEXT,
         LV_TEXT TYPE STRING.


  CLEAR : GS_APPV, GT_LINE.

  LV_TEXT = 'PO 납품처 변경 승인 요청드립니다. T-Code ZGTMMR4010으로 승인 처리 부탁드립니다.'(M02).

  CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
    EXPORTING
      TEXT                = LV_TEXT
      FLAG_NO_LINE_BREAKS = 'X'
      LINE_LENGTH         = 60
*     LANGU               = SY-LANGU
    TABLES
      TEXT_TAB            = LT_TEXT.

  LOOP AT LT_TEXT INTO LS_TEXT.
    APPEND LS_TEXT TO GT_LINE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TXT_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TXT_OBJ.

  GR_TCUST = NEW #( CONTAINER_NAME = 'CC_0210' ).

  GR_TEDIT = NEW #( MAX_NUMBER_CHARS           = 255 "전체 길이
                    WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_FIXED_POSITION
                    WORDWRAP_POSITION          = 60  "한줄 길이
                    WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>TRUE
                    PARENT                     = GR_TCUST ).

  GR_TEDIT->SET_TOOLBAR_MODE( TOOLBAR_MODE = GR_TEDIT->FALSE ).
  GR_TEDIT->SET_STATUSBAR_MODE( STATUSBAR_MODE = GR_TEDIT->FALSE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FUNC_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FUNC_CODE.

* CL_GUI_CFW=>SET_NEW_OK_CODE( NEW_CODE = 'ENTER' ).
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = '=' "'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_RAPP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_RAPP.

  PERFORM CHECK_RAPP.
  CHECK GV_ERR IS INITIAL.

  PERFORM SEND_MAIL.

  CASE GV_CHK.
    WHEN 'E'.
      MESSAGE S000 WITH GV_MSG+0(50) GV_MSG+50(50) DISPLAY LIKE 'E'.
    WHEN OTHERS.
      PERFORM SAVE_401X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RAPP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_RAPP.

  CLEAR : GV_ERR.

  CLEAR : GT_LINE.
  GR_TEDIT->GET_TEXT_AS_R3TABLE( IMPORTING TABLE = GT_LINE ).

  IF GS_APPV-USERID IS INITIAL
  OR GT_LINE        IS INITIAL.
    MESSAGE S060 DISPLAY LIKE 'E'. "승인자와 비고는 필수 입력사항입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL.

  CLEAR : GV_CHK, GV_MSG, GV_TEXT, GT_MTXT.

  CASE GV_OKCODE.
    WHEN 'RAPP'. "승인요청
      PERFORM SET_RAPP_MAIL.

    WHEN 'APPV'. "승인
      PERFORM SET_XAPV_MAIL USING '승인'(M03).

    WHEN 'YPRX'. "반려(Yes)
      IF GV_PRXX = GC_REJ. "지금은..없어도 되지만..
        PERFORM SET_XAPV_MAIL USING '반려'(M04).
      ENDIF.

  ENDCASE.

  CALL FUNCTION 'Z_MM_SEND_MAIL'
    EXPORTING
      I_UNAME     = CONV SYST_UNAME( GS_APPV-USERID )
      I_EMAIL     = CONV AD_SMTPADR( GS_APPV-EMAIL )
      I_HEAD_TEXT = GV_TEXT
    IMPORTING
      E_RETURN    = GV_CHK
      E_MESSAGE   = GV_MSG
    TABLES
      T_MSG       = GT_MTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RAPP_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RAPP_MAIL.

  GV_TEXT = SY-DATLO && ` ` && 'PO 납품처 변경 승인 요청'(T05).

  CLEAR : GS_MTXT.
  LOOP AT GT_LINE INTO DATA(LS_LINE).
    GS_MTXT-LINE = GS_MTXT-LINE && ` ` && LS_LINE.

    APPEND LS_LINE TO GT_MTXT.
  ENDLOOP.

  CONDENSE GS_MTXT-LINE.
* APPEND GS_MTXT TO GT_MTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XAPV_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_XAPV_MAIL USING PV_PRCNM.

  GS_APPV-USERID = GT_HAPP-ERNAM.

  SELECT SINGLE EMAIL
    FROM ZGTMM_CV_GETAPUSERLIST
    INTO @GS_APPV-EMAIL
   WHERE USERID = @GS_APPV-USERID.

  "[&완료]PO 납품처 변경 승인 요청에 대한 처리 결과 회신
  MESSAGE S066 WITH PV_PRCNM INTO GV_TEXT.

  "PO 납품처 변경 요청이 &되었습니다. T-Code ZGTMMR4010에서 상세 확인하세요.
  MESSAGE S067 WITH PV_PRCNM INTO GS_MTXT-LINE.
  APPEND GS_MTXT TO GT_MTXT.

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
*& Form SAVE_401X
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_401X.

  DATA : LT_4012 LIKE ZGTMMT4012 OCCURS 0 WITH HEADER LINE.

  DATA : LV_ZGUID LIKE ZGTMMT4012-ZGUID.


  LT_4012[] = GT_4012[].

  LV_ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).
  PERFORM SET_TIMESTAMP USING 'X' ' '.

  "Header
  GT_4012[] = VALUE #( FOR LS_HDR IN LT_4012
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  ZGUID       = LV_ZGUID
                                  APPUSER     = GS_APPV-USERID
                                  MAILTEXT    = GS_MTXT
                                  ERDAT       = GS_CREA-ERDAT
                                  ERDAT_LOCAL = GS_CREA-ERDAT_LOCAL
                                  ERTIM       = GS_CREA-ERTIM
                                  ERTIM_LOCAL = GS_CREA-ERTIM_LOCAL
                                  ERNAM       = GS_CREA-ERNAM
                                  AEDAT       = GS_CHNG-AEDAT ) ) ).

  "Item
  GT_4013-ZGUID = LV_ZGUID.
  MODIFY GT_4013 TRANSPORTING ZGUID
                        WHERE ZGUID IS INITIAL.

  MODIFY ZGTMMT4013 FROM TABLE GT_4013.
  MODIFY ZGTMMT4012 FROM TABLE GT_4012.

  COMMIT WORK.

  PERFORM GET_DATA.
  MESSAGE S061. "상신 완료되었습니다.

  GV_REF = GC_X.

  "상신 성공 후 동일 화면에서 다시 상신을 누를경우, 중복 상신 우려! 상태 업데이트 필요!
  "데이터 재조회 or 현 화면상 방금 상신 성공한 대상인지? -> 데이터 재조회로 간다!(SJM 24.12.05)
  "아래 소스는 추후 방향 변경될지도 몰라.. 일단 둔다..
*  LOOP AT GT_4013.
*    READ TABLE GT_HRQP WITH KEY EBELN = GT_4013-EBELN
*                                EBELP = GT_4013-EBELP
*                                BINARY SEARCH.
*
*    CHECK SY-SUBRC = 0.
*
*    GT_HRQP-STATUS = ICON_TRANSPORT.
*    MODIFY GT_HRQP INDEX SY-TABIX TRANSPORTING STATUS.
*  ENDLOOP.
*  PERFORM SET_ORQP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_XAPP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_XAPP.

  "상신취소/재처리/승인/반려: ZGUID별 진행
  " 라인 클릭시 'ZGUID'가 동일한 라인은 모두 일괄 자동 선택

  "'ZGUID'가 다른 라인이 이미 선택된 경우 기존 라인 선택 자동 해제 및 신규 GUID에 대한 일괄 자동 선택

  DATA : LV_COND TYPE STRING.


  CLEAR : GV_ERR, GT_CKEY[].

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HAPP INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CLEAR : GT_CKEY.

    CASE GV_PRXX.
      WHEN 'CAP'. "상신취소
        IF GT_HAPP-STATUS <> ICON_TRANSPORT.
          MESSAGE S070 DISPLAY LIKE 'E'. "승인 완료 및 반려 건은 취소할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

      WHEN 'RPC'. "재처리
        IF NOT ( GT_HAPP-APPSTAT = GC_A AND GT_HAPP-TYPE = GC_E ).
          MESSAGE S065 DISPLAY LIKE 'E'. "재처리 대상이 아닙니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

        GT_CKEY-EBELN = GT_HAPP-EBELN.

    ENDCASE.

    GT_CKEY-ZGUID = GT_HAPP-ZGUID.
    COLLECT GT_CKEY.
  ENDLOOP.

  CHECK GV_ERR    IS INITIAL.
  CHECK GT_CKEY[] IS NOT INITIAL.

  CLEAR : GT_ROW, GS_ROW.
  SORT GT_CKEY BY ZGUID EBELN.

  LV_COND = | ZGUID = GT_CKEY-ZGUID |.

  IF GV_PRXX = GC_RPC. "재처리
    LV_COND = LV_COND && | AND EBELN = GT_CKEY-EBELN |.
  ENDIF.

  LOOP AT GT_CKEY.
    LOOP AT GT_HAPP WHERE (LV_COND).
      GS_ROW-INDEX = SY-TABIX.
      APPEND GS_ROW TO GT_ROW.
    ENDLOOP.
  ENDLOOP.

  GR_HGRID->SET_SELECTED_ROWS( IT_INDEX_ROWS = GT_ROW ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCAP.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '취소할 대상을 선택하세요.'(M05).
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_CAP.
  PERFORM CHECK_XAPP.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '해당 품의에서 요청된 모든 PO 변경요청이 상신 취소됩니다. 상신 취소하시겠습니까?'(P03).

  CHECK GV_ANS = GC_1.

  PERFORM UPDATE_4012_BY_ZGUID USING ' ' ' ' ' ' 'X'.

  PERFORM PRCS_REFR.
  MESSAGE S062. "상신 취소되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_4012_BY_ZGUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_4012_BY_ZGUID USING PV_APPSTAT
                                PV_REJRES
                                PV_RETC
                                PV_CANCEL.

  PERFORM SET_TIMESTAMP USING ' ' 'X'.

  LOOP AT GT_CKEY.
    UPDATE ZGTMMT4012 SET APPSTAT     = PV_APPSTAT
                          REJRES      = PV_REJRES
                          RETC        = PV_RETC
                          CANCEL      = PV_CANCEL
                          AEDAT       = GS_CHNG-AEDAT       "SY-DATUM
                          AEDAT_LOCAL = GS_CHNG-AEDAT_LOCAL "SY-DATLO
                          AETIM       = GS_CHNG-AETIM       "SY-UZEIT
                          AETIM_LOCAL = GS_CHNG-AETIM_LOCAL "SY-TIMLO
                          AENAM       = GS_CHNG-AENAM       "SY-UNAME
                    WHERE ZGUID       = GT_CKEY-ZGUID.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_APPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_APPV.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '승인할 대상을 선택하세요.'(M06).
  CHECK GV_ERR IS INITIAL.

  PERFORM CHECK_XAPP.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '해당 PO 변경요청을 승인하시겠습니까?'(P04).

  CHECK GV_ANS = GC_1.

  PERFORM CHANGE_PO.
  PERFORM SEND_MAIL.

* COMMIT WORK.

  PERFORM PRCS_REFR.
  MESSAGE S063. "승인 완료되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_PO.

  DATA : LT_CPO  LIKE GT_IAPP OCCURS 0 WITH HEADER LINE.
  DATA : LV_COND TYPE STRING.


  CHECK GT_CKEY[] IS NOT INITIAL.

  LV_COND = | ZGUID = @GT_CKEY-ZGUID |.

  IF GV_PRXX = GC_RPC. "재처리
    LV_COND = LV_COND && | AND EBELN = @GT_CKEY-EBELN |.
  ENDIF.

  SELECT * FROM ZGTMM_CV_PODIVAPPITEM
    INTO CORRESPONDING FIELDS OF TABLE @LT_CPO
     FOR ALL ENTRIES IN @GT_CKEY
   WHERE (LV_COND).

  SORT LT_CPO BY ZGUID EBELN EBELP.

  PERFORM GET_OITM TABLES LT_CPO.

  LOOP AT LT_CPO.
    MOVE-CORRESPONDING LT_CPO TO GS_IAPP.

    AT NEW EBELN.
      CLEAR : GS_PHDRT,  GT_RTN[],   GT_PITM[], GT_PITMX[],
              GT_PSCD[], GT_PSCDX[], GT_PACC[], GT_PACCX[].
    ENDAT.

    PERFORM READ_OITM.

    PERFORM SET_PITM.
    PERFORM SET_PSCD.
    PERFORM SET_PACC.

    AT END OF EBELN.
      PERFORM BAPI_PO_CHANGE.
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_OITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CPO
*&---------------------------------------------------------------------*
FORM GET_OITM TABLES PT_CPO STRUCTURE GT_IAPP.

  "신규 라인의 경우, 원본 라인 Item 정보 추가(SJM 24.12.20)

  CLEAR : GT_OITM[].

  DATA(LT_CPO) = PT_CPO[].

  DELETE LT_CPO WHERE ZNEW <> GC_N.
  CHECK LT_CPO[] IS NOT INITIAL.

  SORT LT_CPO BY EBELN EBELP_O.
  DELETE ADJACENT DUPLICATES FROM LT_CPO COMPARING EBELN EBELP_O.

  SELECT I~EBELN
         I~EBELP
         I~PSTYP
         I~KNTTP
         I~MWSKZ  "추가(SJM 25.02.26)
         I~BSTAE  "추가(SJM 25.02.26)
         S~EINDT
         S~BANFN
         S~BNFPO
         A~SAKTO
         A~GSBER
         A~KOSTL
         A~VBELN
         A~VBELP
         A~ANLN1
         A~ANLN2
         A~AUFNR
         A~PRCTR
         A~PS_PSP_PNR
         A~NPLNR
    FROM EKPO AS I LEFT JOIN EKET AS S
      ON I~EBELN = S~EBELN
     AND I~EBELP = S~EBELP
    LEFT JOIN EKKN AS A
      ON I~EBELN = A~EBELN
     AND I~EBELP = A~EBELP
    INTO CORRESPONDING FIELDS OF TABLE GT_OITM
     FOR ALL ENTRIES IN LT_CPO
   WHERE I~EBELN = LT_CPO-EBELN
     AND I~EBELP = LT_CPO-EBELP_O.

  SORT GT_OITM BY EBELN EBELP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_OITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_OITM.

  "신규라인의 경우, 참조항번을 기준으로 원본의 정보를 추가
  CLEAR : GT_OITM.

  CHECK GS_IAPP-ZNEW = GC_N.

  READ TABLE GT_OITM WITH KEY EBELN = GS_IAPP-EBELN
                              EBELP = GS_IAPP-EBELP_O
                              BINARY SEARCH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PITM.

  CLEAR : GT_PITM, GT_PITMX.

  GT_PITM-PO_ITEM     = GS_IAPP-EBELP.
  GT_PITM-QUANTITY    = GS_IAPP-MENGE_N.
  GT_PITM-PO_UNIT     = GS_IAPP-MEINS.
  GT_PITM-SUPP_VENDOR = GS_IAPP-EMLIF_N.
  GT_PITM-SC_VENDOR   = SWITCH #( GS_IAPP-EMLIF_N WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PITM-CUSTOMER    = GS_IAPP-KUNNR_N.
  GT_PITM-MATERIAL    = GS_IAPP-MATNR.
  GT_PITM-PLANT       = GS_IAPP-WERKS.
  GT_PITM-STGE_LOC    = GS_IAPP-LGORT.
  GT_PITM-ITEM_CAT    = GT_OITM-PSTYP.
  GT_PITM-ACCTASSCAT  = GT_OITM-KNTTP.
  GT_PITM-TAX_CODE    = GT_OITM-MWSKZ.
  GT_PITM-CONF_CTRL   = GT_OITM-BSTAE.

  GT_PITMX-PO_ITEM     = GS_IAPP-EBELP.
  GT_PITMX-PO_ITEMX    = GC_X.
  GT_PITMX-QUANTITY    = GC_X.
  GT_PITMX-PO_UNIT     = GC_X. "?
  GT_PITMX-SUPP_VENDOR = GT_PITMX-SC_VENDOR
                       = SWITCH #( GS_IAPP-EMLIF_N WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PITMX-CUSTOMER    = SWITCH #( GS_IAPP-KUNNR_N WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PITMX-MATERIAL    = GT_PITMX-PLANT = GT_PITMX-STGE_LOC
                       = SWITCH #( GS_IAPP-ZNEW    WHEN 'N' THEN 'X' ELSE ' ' ).
  GT_PITMX-ITEM_CAT    = GT_PITMX-ACCTASSCAT
                       = SWITCH #( GS_IAPP-ZNEW    WHEN 'N' THEN 'X' ELSE ' ' ).
  GT_PITMX-TAX_CODE    = GT_PITMX-CONF_CTRL
                       = SWITCH #( GS_IAPP-ZNEW    WHEN 'N' THEN 'X' ELSE ' ' ).

  APPEND : GT_PITM, GT_PITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PSCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PSCD.

  CLEAR : GT_PSCD, GT_PSCDX.

  "특정 Material의 경우, 신규 Item 추가시 Schedule Line 정보도 필요..
  CHECK GS_IAPP-ZNEW = GC_N.

  GT_PSCD-PO_ITEM       = GS_IAPP-EBELP.
  GT_PSCD-SCHED_LINE    = 1.
  GT_PSCD-DELIVERY_DATE = GT_OITM-EINDT.
  GT_PSCD-QUANTITY      = GS_IAPP-MENGE_N.
  GT_PSCD-PREQ_NO       = GT_OITM-BANFN.
  GT_PSCD-PREQ_ITEM     = GT_OITM-BNFPO.

  GT_PSCDX-PO_ITEM       = GS_IAPP-EBELP.
  GT_PSCDX-SCHED_LINE    = 1.
  GT_PSCDX-PO_ITEMX      = GC_X.
  GT_PSCDX-SCHED_LINEX   = GC_X.
  GT_PSCDX-DELIVERY_DATE = GC_X.
  GT_PSCDX-QUANTITY      = GC_X.
  GT_PSCDX-PREQ_NO       = SWITCH #( GT_OITM-BANFN WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PSCDX-PREQ_ITEM     = SWITCH #( GT_OITM-BANFN WHEN ' ' THEN ' ' ELSE 'X' ).

  APPEND : GT_PSCD, GT_PSCDX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PACC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PACC.

  CLEAR : GT_PACC, GT_PACCX.

  "특정 Material의 경우, 신규 Item 추가시 필요..
  CHECK GS_IAPP-ZNEW = GC_N.

  GT_PACC-PO_ITEM	    = GS_IAPP-EBELP.
  GT_PACC-SERIAL_NO   = 1.
  GT_PACC-QUANTITY    = GS_IAPP-MENGE_N.
  GT_PACC-GL_ACCOUNT  = GT_OITM-SAKTO.
  GT_PACC-BUS_AREA    = GT_OITM-GSBER.
  GT_PACC-COSTCENTER  = GT_OITM-KOSTL.
  GT_PACC-SD_DOC      = GT_OITM-VBELN.
  GT_PACC-ITM_NUMBER  = GT_OITM-VBELP.
  GT_PACC-ASSET_NO    = GT_OITM-ANLN1.
  GT_PACC-SUB_NUMBER  = GT_OITM-ANLN2.
  GT_PACC-ORDERID     = GT_OITM-AUFNR.
  GT_PACC-PROFIT_CTR  = GT_OITM-PRCTR.
  GT_PACC-WBS_ELEMENT = SWITCH #( GT_OITM-PS_PSP_PNR WHEN '00000000' THEN ' '
                                                                     ELSE GT_OITM-PS_PSP_PNR ).
  GT_PACC-NETWORK     = GT_OITM-NPLNR.

  GT_PACCX-PO_ITEM     = GS_IAPP-EBELP.
  GT_PACCX-SERIAL_NO   = 1.
  GT_PACCX-PO_ITEMX    = GC_X.
  GT_PACCX-SERIAL_NOX  = GC_X.
  GT_PACCX-QUANTITY    = GC_X.
  GT_PACCX-GL_ACCOUNT  = SWITCH #( GT_OITM-SAKTO WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-BUS_AREA    = SWITCH #( GT_OITM-GSBER WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-COSTCENTER  = SWITCH #( GT_OITM-KOSTL WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-SD_DOC      = SWITCH #( GT_OITM-VBELN WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-ITM_NUMBER  = SWITCH #( GT_OITM-VBELN WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-ASSET_NO    = SWITCH #( GT_OITM-ANLN1 WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-SUB_NUMBER  = SWITCH #( GT_OITM-ANLN2 WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-ORDERID     = SWITCH #( GT_OITM-AUFNR WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-PROFIT_CTR  = SWITCH #( GT_OITM-PRCTR WHEN ' ' THEN ' ' ELSE 'X' ).
  GT_PACCX-WBS_ELEMENT = SWITCH #( GT_OITM-PS_PSP_PNR WHEN '00000000' THEN ' ' ELSE 'X' ).
  GT_PACCX-NETWORK     = SWITCH #( GT_OITM-NPLNR WHEN ' ' THEN ' ' ELSE 'X' ).

  APPEND : GT_PACC, GT_PACCX.

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
*& Form BAPI_PO_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PO_CHANGE.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GS_IAPP-EBELN
    IMPORTING
      EXPHEADER     = GS_PHDRT
    TABLES
      RETURN        = GT_RTN
      POITEM        = GT_PITM
      POITEMX       = GT_PITMX
      POSCHEDULE    = GT_PSCD
      POSCHEDULEX   = GT_PSCDX
      POACCOUNT     = GT_PACC
      POACCOUNTX    = GT_PACCX.

  READ TABLE GT_RTN WITH KEY TYPE = 'E'.

  IF SY-SUBRC <> 0 AND GS_PHDRT-PO_NUMBER IS NOT INITIAL.
    PERFORM BAPI_COMMIT.
    PERFORM UPDATE_4012_BY_EBELN USING 'A' 'S' ' ' ' ' 'PO 변경 성공'(M07).
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM UPDATE_4012_BY_EBELN USING 'A' 'E' GT_RTN-ID
                                       GT_RTN-NUMBER
                                       GT_RTN-MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_4012_BY_EBELN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_4012_BY_EBELN USING PV_APPSTAT
                                PV_TYPE
                                PV_ID
                                PV_ZNUMBER
                                PV_MESSAGE.

  PERFORM SET_TIMESTAMP USING ' ' 'X'.

  UPDATE ZGTMMT4012 SET APPSTAT     = PV_APPSTAT
                        TYPE        = PV_TYPE
                        ID          = PV_ID
                        ZNUMBER     = PV_ZNUMBER
                        MESSAGE     = PV_MESSAGE
                        AEDAT       = GS_CHNG-AEDAT
                        AEDAT_LOCAL = GS_CHNG-AEDAT_LOCAL
                        AETIM       = GS_CHNG-AETIM
                        AETIM_LOCAL = GS_CHNG-AETIM_LOCAL
                        AENAM       = GS_CHNG-AENAM
                  WHERE ZGUID       = GS_IAPP-ZGUID
                    AND EBELN       = GS_IAPP-EBELN.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REJT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REJT.

  CLEAR : GV_PRXX, GS_PRXX.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '반려할 대상을 선택하세요.'(M08).
  CHECK GV_ERR IS INITIAL.

  PERFORM CHECK_XAPP.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_REJ.
  GS_PRXX-REJRES = GC_001. "PO 변경 불가

  PERFORM CALL_SCREEN USING 200 10 5
                                70 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YREJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YREJ.

  IF GS_PRXX-REJRES = GC_999  "기타
 AND GS_PRXX-RETC IS INITIAL.
    MESSAGE S082 DISPLAY LIKE 'E'. "기타인 경우, 비고는 필수 입력값입니다.
    GV_ERR = GC_X.
    EXIT.
  ENDIF.

  PERFORM UPDATE_4012_BY_ZGUID USING 'R' GS_PRXX-REJRES GS_PRXX-RETC ' '.

  PERFORM SEND_MAIL.

  PERFORM PRCS_REFR.
  MESSAGE S064. "반려 완료되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REPC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REPC.

  "재처리: 승인권자의 승인을 받았으나 BAPI처리 오류 발생된 건에 대해 사용자가 에러 처리를 할 수 있도록 하기 위함

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '재처리할 대상을 선택하세요.'(M09).
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_RPC.
  PERFORM CHECK_XAPP.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '해당 PO를 변경하시겠습니까?'(P05).

  CHECK GV_ANS = GC_1.

  PERFORM CHANGE_PO.

  PERFORM PRCS_REFR.
  MESSAGE S071. "재처리되었습니다. 결과를 확인하세요.

ENDFORM.
