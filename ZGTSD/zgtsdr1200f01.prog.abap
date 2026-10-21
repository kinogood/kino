*&---------------------------------------------------------------------*
*& Include          ZGTSDR1200F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-영업조직
  S_VKORG[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 ) ).

*-정보범주
  S_ADDTYP[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_ADDTYPE_10 ) ).

  P_CURR = GC_WAERS_KRW.

*-년월
  PERFORM SET_MONTH.

*-화폐단위
  P_PUNIT = '10000'.

*-VKBUR/VKGRP 제외
  PERFORM SET_VKBUR_VKGRP_EXCLUD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'. "영업조직
      SCREEN-INPUT = 0.
    ENDIF.
    IF SCREEN-GROUP1 EQ 'ZM2'. "정보범주
      SCREEN-INPUT = 0.
    ENDIF.
    IF SCREEN-GROUP1 EQ 'ZM3'. "통화
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  MOVE: P_CURR TO BP3100-CURR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG IN @S_VKORG
     AND A~VKBUR IN @GR_VKBUR_ECL
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG IN @S_VKORG
     AND H~VKBUR IN @S_VKBUR
     AND H~VKBUR IN @GR_VKBUR_ECL
     AND A~VKGRP IN @GR_VKGRP_ECL
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0100  USING    PS_E_ROW  TYPE LVC_S_ROW
                                     PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'KUNNR'.
      IF LS_LIST-KUNNR   IS NOT INITIAL AND
         LS_LIST-PARTNER IS NOT INITIAL.
        SET PARAMETER ID 'UKM_SEGMENT' FIELD LS_LIST-CRITER.
        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-PARTNER
                                      IV_ROLE    = GC_ROLE_UKM000
                                      IV_CHANGE  = GC_X ).
      ENDIF.

    WHEN 'PARTNER'.
      IF LS_LIST-PARTNER IS NOT INITIAL.
        SET PARAMETER ID 'UKM_SEGMENT' FIELD LS_LIST-CRITER.
        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-PARTNER
                                      IV_ROLE    = GC_ROLE_UKM000
                                      IV_CHANGE  = GC_X  ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VKBUR_VKGRP_EXCLUD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VKBUR_VKGRP_EXCLUD .
*-영업팀
  GR_VKBUR_ECL[] = VALUE #( ( SIGN = 'I' OPTION = 'NP' LOW = '69*' ) ).

*-영업그룹
  GR_VKGRP_ECL[] = VALUE #( ( SIGN = 'I' OPTION = 'NP' LOW = '69*' ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MONTH .
  DATA: LV_DATE TYPE SY-DATUM.

  "기준년월
  P_CUMON = SY-DATLO(6).

  LV_DATE = SY-DATLO.
  LV_DATE+6(2) = '01'.
  LV_DATE = LV_DATE - 1.

  "비교년월
  P_BFMON = LV_DATE(6).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CUMON
*&---------------------------------------------------------------------*
FORM F4_SPMON  USING    P_FVAL.
  DATA:LV_SUBRC TYPE SY-SUBRC.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH             = P_FVAL
      RETURN_CODE                = LV_SUBRC
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
*-01. INIT OBJECTS
  PERFORM INIT_OBJECTS.

*-02. CHECK INPUT
  PERFORM CHECK_INPUT_VALUE.

*-03. SET VALUES
  PERFORM SET_VALUES.

*-04. GET DATA
  PERFORM GET_DATA.

*-05. MAKE LIST
  PERFORM MAKE_LIST.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR:
         GV_TITLE,GV_PUNIT,
         GV_DATEFR,GV_DATETO,GV_DATEFR_BF,GV_DATETO_BF.

  REFRESH:
          GT_LIST,
          GT_MAIN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .

*-비교년월
  PERFORM CHECK_MONTH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MONTH .
  "기준년월
  PERFORM CHECK_PERIOD USING P_CUMON
                             TEXT-003.
  "비교년월
  PERFORM CHECK_PERIOD USING P_BFMON
                             TEXT-004.

  IF P_BFMON >= P_CUMON.
    MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CUMON
*&---------------------------------------------------------------------*
FORM CHECK_PERIOD  USING    P_MONTH
                            P_TEXT.
  DATA: LV_DATE TYPE SY-DATUM.

  LV_DATE(6) = P_MONTH.
  LV_DATE+6(2) = '01'.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      DATE                      = LV_DATE
    EXCEPTIONS
      PLAUSIBILITY_CHECK_FAILED = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH P_TEXT TEXT-M01 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VALUES .

*-기간
  PERFORM SET_BASE_PERIOD.

  GV_TITLE = TEXT-009.

*-FIELDCATALOG
  CLEAR: GT_FIELDCAT[].
  PERFORM CREATE_FIELDCAT USING 'GT_LIST'
                                GT_FIELDCAT.

*-PRICE UNIT
  PERFORM GET_PUNIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  DATA: LT_MAIN LIKE TABLE OF GT_LIST.

*-영업팀/영업그룹/여신세그먼트
  SELECT DISTINCT A~VKBUR,B~VKGRP,C~KKBER,D~CREDIT_SGMNT
    FROM TVKBZ AS A INNER JOIN TVBVK AS B
                    ON A~VKBUR = B~VKBUR
                    INNER JOIN ZGTSDT1012 AS C
                    ON B~VKGRP = C~VKGRP AND
                       C~LOEVM = @SPACE
                    INNER JOIN UKM_KKBER2SGM AS D
                    ON C~KKBER = D~KKBER

   WHERE A~VKORG IN @S_VKORG
     AND A~VKBUR IN @S_VKBUR
     AND A~VKBUR IN @GR_VKBUR_ECL
     AND B~VKGRP IN @S_VKGRP
     AND B~VKGRP IN @GR_VKGRP_ECL
    INTO TABLE @DATA(LT_BASE).
  SORT LT_BASE BY VKBUR VKGRP CREDIT_SGMNT.

  CHECK LT_BASE[] IS NOT INITIAL.

*-BP ADDITIONAL INFO : BP3100
  SELECT A~VKBUR,
         A~VKGRP,
         B~MANDT,
         B~PARTNER,
         B~CRITER,
         B~ADDTYPE,
         B~DATA_TYPE,
         B~COUNTER,
         B~DATEFR,
         B~DATETO,
         B~CURR,
         B~AMNT,
         B~ZZGUR_AGY,
         B~ZZAREA,
         B~ZZSQUARE,
         B~ZZCOLSEC_AMT,
         B~ZZCOLSEC_PRI,
         B~ZZCOLSEC_SET,
         B~ZZCOLSEC_AMT_P,
         B~ZZREALEST_AMT,
         B~ZZADDRESS,
         B~TEXT,
         B~XFELD,
         D~CUSTOMER AS KUNNR,
         E~BEZEI    AS VKBUR_TX,
         F~BEZEI    AS VKGRP_TX,
         G~NAME1    AS KUNNR_TX,
         K~INFOCATEGORY_TXT AS ADDTYPE_TX,
         M~INFOTYPE_TXT     AS DATA_TYPE_TX

    FROM @LT_BASE AS A INNER JOIN BP3100 AS B
                       ON A~CREDIT_SGMNT = B~CRITER
                       INNER JOIN BUT000 AS C
                       ON B~PARTNER = C~PARTNER
                       INNER JOIN CVI_CUST_LINK AS D
                       ON C~PARTNER_GUID = D~PARTNER_GUID
                       INNER JOIN BUT020 AS H
                       ON C~PARTNER = H~PARTNER
                       LEFT OUTER JOIN TVKBT AS E
                       ON A~VKBUR = E~VKBUR   AND
                          E~SPRAS = @SY-LANGU
                       LEFT OUTER JOIN TVGRT AS F
                       ON A~VKGRP = F~VKGRP   AND
                          F~SPRAS = @SY-LANGU
                       LEFT OUTER JOIN ADRC AS G
                       ON H~ADDRNUMBER = G~ADDRNUMBER AND
                          G~NATION     = @SPACE
                       LEFT OUTER JOIN UKM_INFOCAT0T AS K
                       ON B~ADDTYPE = K~INFOCATEGORY AND
                          K~LANGU   = @SY-LANGU
                       LEFT OUTER JOIN UKM_INFOTYP0T AS M
                       ON B~DATA_TYPE = M~INFOTYPE   AND
                          M~LANGU     = @SY-LANGU

   WHERE B~ADDTYPE   IN @S_ADDTYP
     AND B~DATA_TYPE IN @S_DATTYP

     AND ( B~DATEFR LE @GV_DATEFR AND B~DATETO GE @GV_DATEFR OR
           B~DATEFR LE @GV_DATETO AND B~DATETO GE @GV_DATETO OR
           B~DATEFR BETWEEN @GV_DATEFR AND @GV_DATETO        OR
           B~DATETO BETWEEN @GV_DATEFR AND @GV_DATETO           )

     AND D~CUSTOMER  IN @S_KUNNR
     AND G~DATE_FROM LE @SY-DATUM
     AND G~DATE_TO   GE @SY-DATUM
    INTO CORRESPONDING FIELDS OF TABLE @LT_MAIN.


  LOOP AT LT_MAIN ASSIGNING FIELD-SYMBOL(<FS_LINE>).
    "CDPOS-TABKEY
    PERFORM GET_TABKEY CHANGING <FS_LINE>.
    "OBJECTID
    <FS_LINE>-OBJECTID = <FS_LINE>-PARTNER.
  ENDLOOP.

  GT_MAIN[] = CORRESPONDING #( LT_MAIN[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_LIST .

  CHECK GT_MAIN[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY OBJECTID TABKEY.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING OBJECTID TABKEY.

*-BP3100 생성일자/비교년월 변동내역
  SELECT *
    FROM Z_PLS_CDS_CHDOCU
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE OBJECTCLAS EQ @GC_OBJECTCLAS
     AND OBJECTID   EQ @LT_TEMP-OBJECTID
     AND TABKEY     EQ @LT_TEMP-TABKEY
     AND TABNAME    EQ 'BP3100'
     AND ( ( CHNGIND  EQ @GC_I  AND
             FNAME    EQ 'KEY'       ) OR

           ( CHNGIND  EQ @GC_U  AND
             FNAME    EQ 'TEXT' AND
             UDATE    BETWEEN @GV_DATEFR_BF AND @GV_DATETO_BF ) ) "비교년월 일자기간
    INTO TABLE @DATA(LT_CDPOS).
  SORT LT_CDPOS BY OBJECTID TABKEY CHNGIND.

  DATA(LT_CHGDOC_LAST) = LT_CDPOS[].
  DATA(LT_CHGDOC_FIRT) = LT_CDPOS[].
  DELETE LT_CHGDOC_LAST WHERE CHNGIND EQ GC_I.
  DELETE LT_CHGDOC_FIRT WHERE CHNGIND EQ GC_I.

  SORT LT_CHGDOC_LAST BY OBJECTID TABKEY ASCENDING
                         UDATE DESCENDING UTIME DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_CHGDOC_LAST
                     COMPARING OBJECTID TABKEY.

  SORT LT_CHGDOC_FIRT BY OBJECTID TABKEY ASCENDING
                         UDATE ASCENDING UTIME ASCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_CHGDOC_FIRT
                     COMPARING OBJECTID TABKEY.

*-LIST 구성
  LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<FS_MAIN>).
    "생성일자
    <FS_MAIN>-UDATE = VALUE #( LT_CDPOS[ OBJECTID = <FS_MAIN>-OBJECTID
                                         TABKEY   = <FS_MAIN>-TABKEY
                                         CHNGIND  = GC_I               ]-UDATE OPTIONAL ).

    "비교년월 TEXT 필드 변동내역(변경 후 다시 변경 전으로 변경하는 경우 고려)
    DATA(LS_CHGDOC_LAST) = VALUE #( LT_CHGDOC_LAST[ OBJECTID = <FS_MAIN>-OBJECTID
                                                    TABKEY   = <FS_MAIN>-TABKEY
                                                  ] OPTIONAL ).
    IF LS_CHGDOC_LAST IS NOT INITIAL.
      DATA(LS_CHGDOC_FIRT) = VALUE #( LT_CHGDOC_FIRT[ OBJECTID = <FS_MAIN>-OBJECTID
                                                      TABKEY   = <FS_MAIN>-TABKEY
                                                    ] OPTIONAL ).
      IF LS_CHGDOC_FIRT IS NOT INITIAL.
        IF LS_CHGDOC_LAST-VALUE_NEW NE LS_CHGDOC_FIRT-VALUE_OLD.
          <FS_MAIN>-CHG_TEXT = TEXT-005.
        ELSE.
          <FS_MAIN>-CHG_TEXT = TEXT-006.
        ENDIF.
      ELSE.
        <FS_MAIN>-CHG_TEXT = TEXT-005.
      ENDIF.
    ELSE.
      <FS_MAIN>-CHG_TEXT = TEXT-006.
    ENDIF.
*    IF LINE_EXISTS( LT_CDPOS[ OBJECTID = <FS_MAIN>-OBJECTID
*                              TABKEY   = <FS_MAIN>-TABKEY
*                              CHNGIND  = GC_U
*                              FNAME    = 'TEXT'             ] ).
*
*      <FS_MAIN>-CHG_TEXT = TEXT-005.
*    ELSE.
*      <FS_MAIN>-CHG_TEXT = TEXT-006.
*    ENDIF.

    "물건
    CASE <FS_MAIN>-DATA_TYPE(1).  "정보유형
      WHEN GC_1.
        <FS_MAIN>-MULGUN = TEXT-007.
      WHEN GC_2.
        <FS_MAIN>-MULGUN = TEXT-008.
      WHEN OTHERS.
    ENDCASE.

    "금액변경 : 선택조건 화면의 화페단위 적용
    PERFORM SET_PUNIT_TO_AMOUNT CHANGING <FS_MAIN>.

    CLEAR:LS_CHGDOC_LAST,LS_CHGDOC_FIRT.
  ENDLOOP.


*-변동내역만 조회
  IF P_CHANG IS NOT INITIAL.
    DELETE GT_MAIN WHERE CHG_TEXT NE TEXT-005.
  ENDIF.

  CLEAR GT_LIST[].
  GT_LIST[] = CORRESPONDING #( GT_MAIN[] ).

  SORT GT_LIST BY VKBUR VKBUR_TX VKGRP VKGRP_TX CRITER PARTNER
                  KUNNR KUNNR_TX ADDTYPE DATA_TYPE .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BASE_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BASE_PERIOD .
  DATA: LV_DATE TYPE SY-DATUM.

*-현재월
  LV_DATE(6) = P_CUMON.
  LV_DATE+6(2) = '01'.

  "FROM
  GV_DATEFR = LV_DATE.

  "TO
  LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
  GV_DATETO = LV_DATE.

*-비교년월
  CLEAR LV_DATE.
  LV_DATE(6) = P_BFMON.
  LV_DATE+6(2) = '01'.
  LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
  LV_DATE = LV_DATE + 1.

  "FROM
  GV_DATEFR_BF = LV_DATE.

  "TO
  LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
  GV_DATETO_BF = LV_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TABKEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LINE>
*&---------------------------------------------------------------------*
FORM GET_TABKEY  CHANGING PS_LINE LIKE GT_LIST.
  DATA: LS_BP3100  TYPE BP3100,
        LV_TABNAME TYPE CDPOS-TABNAME VALUE 'BP3100',
        LV_TABKEY  TYPE CDPOS_UID-TABKEY.


  MOVE-CORRESPONDING PS_LINE TO LS_BP3100.

  CALL FUNCTION 'CHANGEDOCU_KEY_ANY2CHAR'
    EXPORTING
      IV_STRUCT_IN     = LS_BP3100
      IV_TABNAME       = LV_TABNAME
    IMPORTING
      EV_TABKEY        = LV_TABKEY
    EXCEPTIONS
      TABNAME_IS_EMPTY = 1
      NAMETAB_ERROR    = 2
      OTHERS           = 3.
  IF SY-SUBRC EQ 0.
    PS_LINE-TABKEY = LV_TABKEY.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  IF GT_LIST[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S018.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PUNIT_TO_AMOUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LINE>
*&---------------------------------------------------------------------*
FORM SET_PUNIT_TO_AMOUNT  CHANGING PS_LINE LIKE GT_LIST.
  DATA:LV_AMT_IN TYPE ZGTE_AMNT,
       LV_AMT_OT TYPE ZGTE_AMNT.

  LOOP AT GT_FIELDCAT INTO GS_FIELDCAT WHERE DATATYPE EQ 'CURR'.
    CLEAR:LV_AMT_IN,LV_AMT_OT.
    ASSIGN COMPONENT GS_FIELDCAT-FIELDNAME OF STRUCTURE PS_LINE
        TO FIELD-SYMBOL(<FS_VAL>).
    IF SY-SUBRC EQ 0 AND <FS_VAL> NE 0.
      LV_AMT_IN = <FS_VAL>.
      LV_AMT_OT = ZGTSD_CL_COMMON2=>GET_CURR_EXTERNAL( IV_WAERS = P_CURR
                                                       IV_AMT   = LV_AMT_IN
                                                     ).
      CLEAR:LV_AMT_IN.
      LV_AMT_IN = TRUNC( LV_AMT_OT / GV_PUNIT ) * GV_PUNIT.
      LV_AMT_IN = LV_AMT_IN / GV_PUNIT.

      <FS_VAL> = ZGTSD_CL_COMMON2=>GET_CURR_INTERNAL( IV_WAERS = P_CURR
                                                       IV_AMT   = LV_AMT_IN
                                                     ).
    ENDIF.
  ENDLOOP.

*  LOOP AT GT_FIELDCAT INTO GS_FIELDCAT WHERE DATATYPE EQ 'CURR'.
*    ASSIGN COMPONENT GS_FIELDCAT-FIELDNAME OF STRUCTURE PS_LINE
*        TO FIELD-SYMBOL(<FS_VAL>).
*    IF SY-SUBRC EQ 0 AND <FS_VAL> NE 0.
*      <FS_VAL> = <FS_VAL> / GV_PUNIT .
*    ENDIF.
*    IF <FS_VAL> IS ASSIGNED. UNASSIGN <FS_VAL>. ENDIF.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PUNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PUNIT .
  DATA:LV_AMT_IN TYPE ZGTE_AMNT,
       LV_AMT_OT TYPE ZGTE_AMNT.
  LV_AMT_IN = P_PUNIT.
  LV_AMT_OT = ZGTSD_CL_COMMON2=>GET_CURR_EXTERNAL( IV_WAERS = P_CURR
                                                   IV_AMT   = LV_AMT_IN
                                                 ).
  GV_PUNIT = LV_AMT_OT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILTER_PERIOD_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_A
*&---------------------------------------------------------------------*
FORM GET_FILTER_PERIOD_MONTH  USING P_STEP.
  DATA: LV_DATE TYPE SY-DATUM.
  DATA: LT_FILTER TYPE LVC_T_FILT,
        LS_FILTER TYPE LVC_S_FILT.

  RANGES: LR_DATETO FOR BP3100-DATETO.


  CALL METHOD GO_GRID->GET_FILTER_CRITERIA
    IMPORTING
      ET_FILTER = LT_FILTER.
  CLEAR LT_FILTER[].

  LV_DATE = P_CUMON.
  LV_DATE+6(2) = '01'.
  CASE P_STEP.
    WHEN GC_A. "당월
      LS_FILTER-FIELDNAME = 'DATETO'.
      LS_FILTER-SIGN      = 'I'.
      LS_FILTER-OPTION    = 'BT'.
      LS_FILTER-LOW       = LV_DATE.
      LS_FILTER-HIGH      = CONV TEXT80( ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ) ).
      APPEND LS_FILTER TO LT_FILTER.

    WHEN GC_B. "익월
      LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
      LV_DATE = LV_DATE + 1.
      LS_FILTER-FIELDNAME = 'DATETO'.
      LS_FILTER-SIGN      = 'I'.
      LS_FILTER-OPTION    = 'BT'.
      LS_FILTER-LOW       = LV_DATE.
      LS_FILTER-HIGH      = CONV TEXT80( ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ) ).
      APPEND LS_FILTER TO LT_FILTER.

    WHEN GC_C. "당월/익월
      LS_FILTER-FIELDNAME = 'DATETO'.
      LS_FILTER-SIGN      = 'I'.
      LS_FILTER-OPTION    = 'BT'.
      LS_FILTER-LOW       = LV_DATE.
      LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
      LV_DATE = LV_DATE + 1.
      LS_FILTER-HIGH      = CONV TEXT80( ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ) ).
      APPEND LS_FILTER TO LT_FILTER.

    WHEN GC_D.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

  CALL METHOD GO_GRID->SET_FILTER_CRITERIA
    EXPORTING
      IT_FILTER                 = LT_FILTER
    EXCEPTIONS
      NO_FIELDCATALOG_AVAILABLE = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH TEXT-M03 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM REFRESH_ALV USING GO_GRID.

*  CLEAR GT_LIST[].
*  GT_LIST[] = CORRESPONDING #( GT_MAIN[] ).

*  CASE P_STEP.
*    WHEN GC_A. "당월
*      APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
*                      LOW  = LV_DATE
*                      HIGH = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE )
*                    ) TO LR_DATETO.
*
*    WHEN GC_B. "익월
*      LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
*      LV_DATE = LV_DATE + 1.
*      APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
*                      LOW  = LV_DATE
*                      HIGH = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE )
*                    ) TO LR_DATETO.
*    WHEN GC_C. "당월/익월
*      APPEND INITIAL LINE TO LR_DATETO ASSIGNING FIELD-SYMBOL(<FS_LINE>).
*      <FS_LINE>-SIGN = 'I'.
*      <FS_LINE>-OPTION = 'BT'.
*      <FS_LINE>-LOW    = LV_DATE.
*      LV_DATE = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
*      LV_DATE = LV_DATE + 1.
*      <FS_LINE>-HIGH   = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE ).
*    WHEN GC_D.
*
*  ENDCASE.
*
*  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
