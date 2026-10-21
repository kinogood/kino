*&---------------------------------------------------------------------*
*& Include          ZGTSDR1240F01
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

*-관계범주 리스트
  PERFORM SET_DIRECTED_TYPES.

*-관계범주
  P_RELTYP = GC_BU_RELTYP.


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
*-영업조직
  SELECT VKORG
    FROM TVKO
   WHERE VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_TVKO).
  DELETE LT_TVKO WHERE VKORG EQ GC_VKORG_6000.
  IF LT_TVKO[] IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-M05.

  ENDIF.

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
*    IF SCREEN-GROUP1 EQ 'ZM1'.
*      SCREEN-INPUT = 0.
*    ENDIF.
    IF SCREEN-GROUP1 EQ 'ZM2'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDING .
  CLEAR:GT_EXCLU[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DIRECTED_TYPES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DIRECTED_TYPES .
  DATA: LV_PARTNER_TYPE TYPE BUS_PARTNER-TYPE VALUE '2'.

  DATA LV_FROM           TYPE BU_BOOLEAN.
  DATA LV_TO             TYPE BU_BOOLEAN.
  DATA LS_DIRECTED_TYPE  TYPE BURS_RELATIONSHIP-DIRECTED_TYPE.
  DATA LS_RELTYP_DATA    TYPE BUS_RELTYP_DATA.
  DATA LS_RELTYP_DATA2   TYPE BUS_RELTYP_DATA.
  DATA LT_RELTYP_DATA    TYPE STANDARD TABLE OF BUS_RELTYP_DATA.
  DATA LT_RELTYP_DATA2   TYPE STANDARD TABLE OF BUS_RELTYP_DATA.
  DATA LT_DIRECTED_TYPES LIKE GT_DIRECTED_TYPES.
  DATA LT_TBZ0A          TYPE TABLE OF TBZ0A.
  DATA LS_TBZ0A          TYPE TBZ0A.
  DATA LT_TB920          TYPE TABLE OF TB920.
  CONSTANTS:LC_NO_XRF TYPE BU_XRF VALUE SPACE,
            LC_OBJAP  TYPE BU_OBJAP  VALUE 'BUPR'.

  CLEAR:GT_DIRECTED_TYPES[].

*   Rollenfindungsbeziehungstypen könnten hier durch einen 2. Aufruf
*   mit eingebaut werden.
  CALL FUNCTION 'BUS_RELTYP_GET_MULTIPLE'
    EXPORTING
      I_XRF         = LC_NO_XRF
    TABLES
      T_RELTYP_DATA = LT_RELTYP_DATA
      T_ROLES       = LT_TB920.



  DELETE LT_RELTYP_DATA WHERE XSUPPRESS = GC_X.

*   Exclude reltypes whose application is not active
  CALL FUNCTION 'BDT_TBZ0A_GET'
    EXPORTING
      IV_OBJAP             = LC_OBJAP
    TABLES
      ET_TBZ0A             = LT_TBZ0A
    EXCEPTIONS
      NOT_FOUND_WITH_OBJAP = 1
      OTHERS               = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  LOOP  AT LT_RELTYP_DATA   INTO  LS_RELTYP_DATA .
    READ  TABLE   LT_TBZ0A  INTO  LS_TBZ0A
                  WITH KEY  APPLI  =   LS_RELTYP_DATA-APPLI_TAB.
    IF   SY-SUBRC        = 0
    AND  LS_TBZ0A-XAKTV  IS  INITIAL.
      DELETE  LT_RELTYP_DATA .
    ENDIF.
  ENDLOOP.

*Need to do an authority check here do display only those that the user is allowed to see
*  CLEAR ET_DEL_RELATIONS.
*  LOOP  AT LT_RELTYP_DATA   INTO  LS_RELTYP_DATA .
*
*    AUTHORITY-CHECK OBJECT 'B_BUPR_BZT'
*             ID 'ACTVT' FIELD GC_DIALOG_ACTIVITY-DISPLAY
*             ID 'RELTYP' FIELD LS_RELTYP_DATA-RELTYP.
*
*    IF NOT SY-SUBRC IS INITIAL.
*      DELETE LT_RELTYP_DATA WHERE RELTYP = LS_RELTYP_DATA-RELTYP.
*      APPEND LS_RELTYP_DATA TO ET_DEL_RELATIONS.
*    ENDIF.
*
*  ENDLOOP.

*   Sort table by position number (the filled ones first)
  LS_RELTYP_DATA-POSNR = LS_RELTYP_DATA-POSNR_2 = '999'.
  MODIFY LT_RELTYP_DATA FROM LS_RELTYP_DATA TRANSPORTING POSNR
         WHERE POSNR IS INITIAL.
  MODIFY LT_RELTYP_DATA FROM LS_RELTYP_DATA TRANSPORTING POSNR_2
         WHERE POSNR_2 IS INITIAL.

*   For directed types we need two entries, both having their data
*   (sort number and description) in the same fields for both directions
*   (POSNR and BEZ50). This is to allow sorting both directions
*   correctly.
  LOOP AT LT_RELTYP_DATA INTO LS_RELTYP_DATA WHERE XDIRECTION = GC_X.
    LS_RELTYP_DATA2 = LS_RELTYP_DATA.
    LS_RELTYP_DATA2-POSNR = LS_RELTYP_DATA2-POSNR_2.
    LS_RELTYP_DATA2-BEZ50 = LS_RELTYP_DATA2-BEZ50_2.
    CLEAR: LS_RELTYP_DATA2-XORGA_P1, LS_RELTYP_DATA2-XPERS_P1,
           LS_RELTYP_DATA2-XGROU_P1.
    APPEND LS_RELTYP_DATA2 TO LT_RELTYP_DATA2.
    CLEAR: LS_RELTYP_DATA-XORGA_P2, LS_RELTYP_DATA-XPERS_P2,
           LS_RELTYP_DATA-XGROU_P2.
    MODIFY LT_RELTYP_DATA FROM LS_RELTYP_DATA.
  ENDLOOP.

  APPEND LINES OF LT_RELTYP_DATA2 TO LT_RELTYP_DATA.

  SORT LT_RELTYP_DATA BY POSNR BEZ50 AS TEXT.

  LOOP AT LT_RELTYP_DATA INTO LS_RELTYP_DATA.
*     Determine if source partner type is relevant.
    CLEAR LV_FROM.
    CASE LV_PARTNER_TYPE.
      WHEN GC_TYPE-UNSPECIFIED.
        LV_FROM = GC_X.
        LV_TO = GC_X.
      WHEN GC_TYPE-PERSON.
        LV_FROM = LS_RELTYP_DATA-XPERS_P1.
        LV_TO = LS_RELTYP_DATA-XPERS_P2.
      WHEN GC_TYPE-ORGANIZATION.
        LV_FROM = LS_RELTYP_DATA-XORGA_P1.
        LV_TO = LS_RELTYP_DATA-XORGA_P2.
      WHEN GC_TYPE-GROUP.
        LV_FROM = LS_RELTYP_DATA-XGROU_P1.
        LV_TO = LS_RELTYP_DATA-XGROU_P2.
    ENDCASE.

    LS_DIRECTED_TYPE-TYPE-RELTYP = LS_RELTYP_DATA-RELTYP.
    LS_DIRECTED_TYPE-TYPE-XRF    = LS_RELTYP_DATA-XRF.

    IF LS_RELTYP_DATA-XDIRECTION IS INITIAL.
      IF LV_FROM = GC_X.
        LS_DIRECTED_TYPE-DIRECTION = GC_DIRECTION-NONE.
        APPEND LS_DIRECTED_TYPE TO GT_DIRECTED_TYPES.
      ENDIF.
    ELSE.
      IF LV_FROM = GC_X.
        LS_DIRECTED_TYPE-DIRECTION = GC_DIRECTION-FROM.
        APPEND LS_DIRECTED_TYPE TO GT_DIRECTED_TYPES.
      ENDIF.
      IF LV_TO = GC_X.
        LS_DIRECTED_TYPE-DIRECTION = GC_DIRECTION-TO.
        APPEND LS_DIRECTED_TYPE TO GT_DIRECTED_TYPES.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR:GT_DROPDOWN_VALUES[].
*  DATA LS_DIRECTED_TYPE   TYPE BURS_RELATIONSHIP-DIRECTED_TYPE.
  DATA LS_DROPDOWN_VALUE  TYPE BUS_SCREEN-DROPDOWN_VALUE.
  DATA LT_DROPDOWN_VALUES TYPE BUS_SCREEN-DROPDOWN_VALUES.
  DATA LV_TITLE           TYPE BURS_RELATIONSHIP-TYPE_TITLE.
  DATA LV_COUNT           TYPE I.
  DATA LV_S4_SYSTEM       TYPE BU_BOOLEAN.
*  DATA LS_RELTYP_DATA TYPE BUS_RELTYP_DATA.

  LV_S4_SYSTEM = CL_COS_UTILITIES=>IS_S4H( ) .

*   Clear the value set.
  LOOP AT GT_DIRECTED_TYPES INTO LS_DIRECTED_TYPE.

* If it is a S4HANA SuccessFactors system and BP should not be able to create HCM001, HCM002, HCM003 relationship category for any roles
    IF LV_S4_SYSTEM = 'X' AND ( LS_DIRECTED_TYPE-TYPE-RELTYP = 'HCM001' OR LS_DIRECTED_TYPE-TYPE-RELTYP = 'HCM002' OR LS_DIRECTED_TYPE-TYPE-RELTYP = 'HCM003' ) .
      CONTINUE.
    ENDIF.
    CLEAR LS_RELTYP_DATA.

    CALL FUNCTION 'BUS_RELTYP_GET'
      EXPORTING
        I_RELTYP      = LS_DIRECTED_TYPE-TYPE-RELTYP
        I_XRF         = LS_DIRECTED_TYPE-TYPE-XRF
        I_SPRAS       = SY-LANGU
        I_XDATA       = GC_X
        I_XTEXT       = GC_X
      IMPORTING
        E_RELTYP_DATA = LS_RELTYP_DATA
      EXCEPTIONS
        OTHERS        = 1.

    CASE LS_DIRECTED_TYPE-DIRECTION.
      WHEN GC_DIRECTION-NONE.
        LV_TITLE = LS_RELTYP_DATA-BEZ50.
      WHEN GC_DIRECTION-FROM.
        LV_TITLE = LS_RELTYP_DATA-BEZ50.
      WHEN GC_DIRECTION-TO.
        LV_TITLE = LS_RELTYP_DATA-BEZ50_2.
      WHEN OTHERS.
        LV_TITLE = LS_DIRECTED_TYPE.
    ENDCASE.

*    CALL METHOD LCL_PARTNER_RELATIONSHIP=>GET_DIRECTED_TYPE_TITLE
*      EXPORTING
*        IS_DIRECTED_TYPE = LS_DIRECTED_TYPE
*        IV_LANGUAGE      = SY-LANGU
*      IMPORTING
*        EV_TITLE         = LV_TITLE.
*    CALL METHOD GET_COUNTER
*      EXPORTING
*        IS_DIRECTED_TYPE = LS_DIRECTED_TYPE
*      IMPORTING
*        EV_COUNT         = LV_COUNT.
    LS_DROPDOWN_VALUE-KEY = LS_DIRECTED_TYPE.
*    IF LV_COUNT > 0.
*      MESSAGE S224 WITH LV_TITLE LV_COUNT INTO LS_DROPDOWN_VALUE-TEXT.
*    ELSE.
    LS_DROPDOWN_VALUE-TEXT = LV_TITLE.
*    ENDIF.
    APPEND LS_DROPDOWN_VALUE TO LT_DROPDOWN_VALUES.
  ENDLOOP.

  GT_DROPDOWN_VALUES[] = LT_DROPDOWN_VALUES[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_RELTYP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_RELTYP  USING    P_FNAME.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD  = P_FNAME
      VALUE_ORG = 'S'
    TABLES
      VALUE_TAB = GT_DROPDOWN_VALUES
    EXCEPTIONS
      OTHERS    = 0.

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
         GV_RELTYP,
         GV_TITLE.

  REFRESH:
           GR_SGMNT,
           GT_LIST.
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

*-CREDIT SEGMENT
  PERFORM GET_CREDIT_SEGMENT.

*-RELATION TYPE
  GV_RELTYP = P_RELTYP+1(6).


  GV_EDIT = GC_X.

  GV_TITLE = TEXT-001.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CREDIT_SEGMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CREDIT_SEGMENT .

*-영업팀/영업그룹/여신세그먼트
  SELECT DISTINCT C~KKBER,D~CREDIT_SGMNT
    FROM TVKBZ AS A INNER JOIN TVBVK AS B
                    ON A~VKBUR = B~VKBUR
                    INNER JOIN ZGTSDT1012 AS C
                    ON B~VKGRP = C~VKGRP AND
                       C~LOEVM = @SPACE
                    INNER JOIN UKM_KKBER2SGM AS D
                    ON C~KKBER = D~KKBER

   WHERE A~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_DATA).
  SORT LT_DATA BY CREDIT_SGMNT.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING CREDIT_SGMNT.
  LOOP AT LT_DATA INTO DATA(LS_DATA).
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ'
                    LOW  = LS_DATA-CREDIT_SGMNT
                  ) TO GR_SGMNT.
  ENDLOOP.
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

*-01. 로컬지급처
  SELECT A~KUNNR   AS KUNNR2,
         G~PARTNER AS PARTNER2,
         C~NAME1   AS KUNNR2_TX,
         A~KUNNR   AS KUNNR1
    FROM KNVV AS A INNER JOIN KNA1 AS B
                   ON A~KUNNR = B~KUNNR        AND
                      B~KTOKD = @GC_KTOKD_0003
                   INNER JOIN CVI_CUST_LINK AS F
                   ON B~KUNNR = F~CUSTOMER
                   INNER JOIN BUT000 AS G
                   ON F~PARTNER_GUID = G~PARTNER_GUID
                   LEFT OUTER JOIN ADRC AS C
                   ON B~ADRNR     = C~ADDRNUMBER AND
                      C~DATE_FROM <= @SY-DATLO   AND
                      C~NATION    = @SPACE
   WHERE A~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_KNVV_10).
  SORT LT_KNVV_10 BY KUNNR2.
  DELETE ADJACENT DUPLICATES FROM LT_KNVV_10 COMPARING KUNNR2.

*-02. 로컬지급처에 대한 내수고객
*     => 고객코드 앞자리만 1로 변경
  LOOP AT LT_KNVV_10 ASSIGNING FIELD-SYMBOL(<FS_LINE_10>).
    <FS_LINE_10>-KUNNR1 = |{ <FS_LINE_10>-KUNNR1 ALPHA = OUT }|.
    <FS_LINE_10>-KUNNR1(1) = '1'.
    <FS_LINE_10>-KUNNR1 = |{ <FS_LINE_10>-KUNNR1 ALPHA = IN }|.
  ENDLOOP.


*-03. 내수고객
  IF LT_KNVV_10[] IS NOT INITIAL.
    SELECT A~KUNNR   AS KUNNR1,
           G~PARTNER AS PARTNER1,
           C~NAME1   AS KUNNR1_TX
      FROM KNVV AS A INNER JOIN KNA1 AS B
                     ON A~KUNNR = B~KUNNR        AND
                      B~KTOKD = @GC_KTOKD_0001
                     INNER JOIN CVI_CUST_LINK AS F
                     ON B~KUNNR = F~CUSTOMER
                     INNER JOIN BUT000 AS G
                     ON F~PARTNER_GUID = G~PARTNER_GUID
                     LEFT OUTER JOIN ADRC AS C
                     ON B~ADRNR     = C~ADDRNUMBER AND
                        C~DATE_FROM <= @SY-DATLO   AND
                        C~NATION    = @SPACE
       FOR ALL ENTRIES IN @LT_KNVV_10
     WHERE A~VKORG IN @S_VKORG
       AND A~KUNNR EQ @LT_KNVV_10-KUNNR1
      INTO TABLE @DATA(LT_KNVV_20).
    SORT LT_KNVV_20 BY KUNNR1.
    DELETE ADJACENT DUPLICATES FROM LT_KNVV_20 COMPARING KUNNR1.
  ENDIF.


*-04. 내수고객 - 로컬지급처 연결 리스트 구성.
  LOOP AT LT_KNVV_10 INTO DATA(LS_LOCAL).
    CLEAR GS_LIST.
    READ TABLE LT_KNVV_20 INTO DATA(LS_CUST) WITH KEY KUNNR1 = LS_LOCAL-KUNNR1
                                             BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      "내수고객
      GS_LIST-KUNNR1    = LS_CUST-KUNNR1.
      GS_LIST-PARTNER1  = LS_CUST-PARTNER1.
      GS_LIST-KUNNR1_TX = LS_CUST-KUNNR1_TX.
    ENDIF.

    "로컬지급처
    GS_LIST-KUNNR2    = LS_LOCAL-KUNNR2.
    GS_LIST-PARTNER2  = LS_LOCAL-PARTNER2.
    GS_LIST-KUNNR2_TX = LS_LOCAL-KUNNR2_TX.

    APPEND GS_LIST TO GT_LIST.

    CLEAR:LS_CUST.
  ENDLOOP.
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
  DATA: LT_LIST LIKE TABLE OF GT_LIST.
  DATA: LT_DATA TYPE STANDARD TABLE OF BUT050.

  CHECK GT_LIST[] IS NOT INITIAL.

* 내수고객 리스트를 기준으로 내수/로컬지급처 여신정보 및 RELATIONS을 구성한다.

*-01. 내수고객 여신 정보
  DATA(LT_TEMP10) = GT_LIST[].
  SORT LT_TEMP10 BY PARTNER1.
  DELETE LT_TEMP10 WHERE PARTNER1 IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING PARTNER1.

  IF LT_TEMP10[] IS NOT INITIAL.
    SELECT A~PARTNER,A~CHECK_RULE,
           B~CREDIT_SGMNT
      FROM UKMBP_CMS AS A LEFT OUTER JOIN UKMBP_CMS_SGM AS B
                          ON A~PARTNER = B~PARTNER
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE A~PARTNER      EQ @LT_TEMP10-PARTNER1
       AND A~CHECK_RULE   EQ @GC_CHKRULE_STND
       AND B~CREDIT_SGMNT IN @GR_SGMNT
      INTO TABLE @DATA(LT_UKMBP_10).
    SORT LT_UKMBP_10 BY PARTNER CHECK_RULE CREDIT_SGMNT.
  ENDIF.

*-02. 로컬지급처 여신 정보
  DATA(LT_TEMP20) = GT_LIST[].
  SORT LT_TEMP20 BY PARTNER2.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP20 COMPARING PARTNER2.

  IF LT_TEMP20[] IS NOT INITIAL.
    SELECT A~PARTNER,A~CHECK_RULE,
           B~CREDIT_SGMNT
      FROM UKMBP_CMS AS A LEFT OUTER JOIN UKMBP_CMS_SGM AS B
                          ON A~PARTNER = B~PARTNER
       FOR ALL ENTRIES IN @LT_TEMP20
     WHERE A~PARTNER      EQ @LT_TEMP20-PARTNER2
       AND A~CHECK_RULE   EQ @GC_CHKRULE_LOCAL
       AND B~CREDIT_SGMNT IN @GR_SGMNT
      INTO TABLE @DATA(LT_UKMBP_20).
    SORT LT_UKMBP_20 BY PARTNER CHECK_RULE CREDIT_SGMNT.
  ENDIF.

  LT_LIST[] = CORRESPONDING #( GT_LIST[] ).
  CLEAR:GT_LIST[].

*-03. 내수고객/로컬지급처 여신정보 지정
  LOOP AT LT_LIST INTO DATA(LS_LIST).
    CLEAR GS_LIST.
    MOVE-CORRESPONDING LS_LIST TO GS_LIST.

    LOOP AT LT_UKMBP_10 INTO DATA(LS_UKMBP_10) WHERE PARTNER = LS_LIST-PARTNER1.
      CLEAR:GS_LIST-CHECK_RULE1,GS_LIST-CREDIT_SGMNT1.
      CLEAR:GS_LIST-CHECK_RULE2,GS_LIST-CREDIT_SGMNT2.
*     [내수고객]
      "CHECK RULE
      GS_LIST-CHECK_RULE1   = LS_UKMBP_10-CHECK_RULE.
      "CREDIT SEGMENT
      GS_LIST-CREDIT_SGMNT1 = LS_UKMBP_10-CREDIT_SGMNT.

*     [로컬지급처]
      READ TABLE LT_UKMBP_20 INTO DATA(LS_UKMBP_20) WITH KEY PARTNER      = LS_LIST-PARTNER2
                                                             CREDIT_SGMNT = GS_LIST-CREDIT_SGMNT1
                                                    BINARY SEARCH.
      GV_INDEX = SY-TABIX.

      IF SY-SUBRC EQ 0.
        "CHECK RULE
        GS_LIST-CHECK_RULE2   = LS_UKMBP_20-CHECK_RULE.
        "CREDIT SEGMENT
        GS_LIST-CREDIT_SGMNT2 = LS_UKMBP_20-CREDIT_SGMNT.

        "처리한 로컬지급처 여신정보 삭제
        DELETE LT_UKMBP_20 INDEX GV_INDEX.
      ENDIF.

      APPEND GS_LIST TO GT_LIST.

    ENDLOOP.

  ENDLOOP.

*-04. 내수고객 여신정보(CREDIT_SGMNT) 와 로컬지급처 여신정보(CREDIT_SGMNT) 연결이 안된것 처리
  LOOP AT LT_UKMBP_20 INTO LS_UKMBP_20.
    CLEAR:GS_LIST.
    READ TABLE GT_LIST INTO GS_LIST WITH KEY PARTNER2 = LS_UKMBP_20-PARTNER
                                    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CLEAR:GS_LIST-CHECK_RULE2,GS_LIST-CREDIT_SGMNT2.

*     [로컬지급처]
      "CHECK RULE
      GS_LIST-CHECK_RULE2   = LS_UKMBP_20-CHECK_RULE.
      "CREDIT SEGMENT
      GS_LIST-CREDIT_SGMNT2 = LS_UKMBP_20-CREDIT_SGMNT.

*     [내수고객]
      CLEAR:GS_LIST-CREDIT_SGMNT1.

      GS_LIST-FLAG_X = GC_X.

      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDLOOP.

*-05. 내수고객-로컬지급처 관계
  CLEAR LT_DATA[].
  LT_DATA[] = CORRESPONDING #( GT_LIST[] ).
  SORT LT_DATA BY PARTNER1 PARTNER2.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING PARTNER1 PARTNER2.
  "BUT050
  IF LT_DATA[] IS NOT INITIAL.
    SELECT B~PARTNER1,B~PARTNER2,B~RELTYP,
           SUBSTRING( B~DFTVAL,1,10 ) AS CREDIT_SGMNT
      FROM @LT_DATA AS A INNER JOIN BUT050 AS B
                         ON A~PARTNER1 = B~PARTNER1 AND
                            A~PARTNER2 = B~PARTNER2
     WHERE B~RELTYP EQ @GV_RELTYP
       AND B~DFTVAL IN @GR_SGMNT
      INTO TABLE @DATA(LT_BUT050).
  ENDIF.

*-06. 전체상태
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    "로컬지급처 BP 여신
    IF <FS_LIST>-CHECK_RULE2 IS NOT INITIAL.
      <FS_LIST>-FLAG_C = GC_X.
    ENDIF.
    "로컬지급처 BP SEGMENT
    IF <FS_LIST>-CREDIT_SGMNT2 IS NOT INITIAL.
      <FS_LIST>-FLAG_S = GC_X.
    ENDIF.

    IF <FS_LIST>-PARTNER1 IS INITIAL.
      <FS_LIST>-FLAG_X = GC_X.
    ENDIF.


    "BP RELATION
    IF <FS_LIST>-FLAG_X IS INITIAL.
      IF LINE_EXISTS( LT_BUT050[ PARTNER1     = <FS_LIST>-PARTNER1
                                 PARTNER2     = <FS_LIST>-PARTNER2
                                 RELTYP       = GC_RELTYP_UKM001
                                 CREDIT_SGMNT = <FS_LIST>-CREDIT_SGMNT1 ] ).
        <FS_LIST>-FLAG_R = GC_X.
      ENDIF.
    ENDIF.

    PERFORM SET_LED CHANGING <FS_LIST>.
  ENDLOOP.

*-완료건 삭제
  DELETE GT_LIST WHERE FLAG_X NE GC_X
                   AND FLAG_C EQ GC_X  "여신일반
                   AND FLAG_S EQ GC_X  "여신 SEGMENT
                   AND FLAG_R EQ GC_X. "관계

  SORT GT_LIST BY KUNNR1 CREDIT_SGMNT1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GT_LIST.

  "여신세그먼트
  IF PS_LIST-FLAG_S EQ GC_X.
    PS_LIST-STAT1 = ICON_LED_GREEN.
  ELSE.
    PS_LIST-STAT1 = ICON_LED_YELLOW.
  ENDIF.

  "RELATION
  IF PS_LIST-FLAG_R EQ GC_X.
    PS_LIST-STAT2 = ICON_LED_GREEN.
  ELSE.
    PS_LIST-STAT2 = ICON_LED_YELLOW.
  ENDIF.

  "오류
  IF PS_LIST-FLAG_X EQ GC_X.
    PS_LIST-STAT1 = ICON_LED_RED.
    PS_LIST-STAT2 = ICON_LED_RED.
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
  IF SY-BATCH IS NOT INITIAL.
    IF GT_LIST[] IS NOT INITIAL.
      PERFORM BACKGROUND_PROCESS.
    ELSE.
      MESSAGE S010.
    ENDIF.
  ELSE.
    IF GT_LIST[] IS NOT INITIAL.
      CALL SCREEN 0100.
    ELSE.
      MESSAGE S010.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_LIST_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REBUILD_LIST_0100 .
  CLEAR:GT_LIST[].

  PERFORM GET_DATA.
  PERFORM MAKE_LIST.
  PERFORM CELL_ATTRIBUTES_0100.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0100 .
  CLEAR GS_LIST.
  GS_LIST-SEL = GC_X.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL    EQ SPACE
                                                 AND FLAG_R NE GC_X
                                                 AND FLAG_X NE GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0100 .
  CLEAR GS_LIST.

  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_CREDIT_SEGMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CREDIT .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_BP_CREDIT.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-MAINTAIN BP CREDIT
  PERFORM MAINTAIN_BP_CREDIT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BP_CREDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BP_CREDIT .
  DATA: LV_CNT TYPE I.

*-01. 선택
  IF NOT LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. VALIDATION
  DATA(LT_TEMP) = GT_LIST[].
  DELETE LT_TEMP WHERE SEL NE GC_X.
  DELETE LT_TEMP WHERE FLAG_X EQ GC_X.
  IF LT_TEMP[] IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL    EQ GC_X
                                       AND FLAG_X NE GC_X.
    "BP CREDIT
    SELECT SINGLE A~PARTNER,A~CHECK_RULE,
                  B~CREDIT_SGMNT
      FROM UKMBP_CMS AS A LEFT OUTER JOIN UKMBP_CMS_SGM AS B
                          ON A~PARTNER = B~PARTNER
     WHERE A~PARTNER      EQ @LS_LIST-PARTNER2
       AND A~CHECK_RULE   EQ @GC_CHKRULE_LOCAL
       AND B~CREDIT_SGMNT EQ @LS_LIST-CREDIT_SGMNT1
      INTO @DATA(LS_UKMBP).
    IF SY-SUBRC NE 0.
      LV_CNT = LV_CNT + 1.
      EXIT.
    ELSE.
      IF LS_UKMBP-CREDIT_SGMNT IS NOT INITIAL.

      ELSE.
        LV_CNT = LV_CNT + 1.
        EXIT.
      ENDIF.

    ENDIF.

    CLEAR LS_UKMBP.
  ENDLOOP.

  IF LV_CNT <= 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CREDIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CREDIT_DATA .
  DATA: LV_NO(1).
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR: GT_ZGTSDT9041,GT_ZGTSDT9041[].
  CLEAR GV_ERROR.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL    EQ GC_X
                                                      AND FLAG_X NE GC_X.
    CLEAR:LV_NO.

    "처리 완료건 체크
    PERFORM CHECK_BP_CREDIT_MAINTAINED USING <FS_LIST> CHANGING LV_NO.

    IF LV_NO IS INITIAL.
      CLEAR:<FS_LIST>-RSLT,<FS_LIST>-MESSAGE.
      PERFORM MAINTAIN_BP_CREDIT_PROC CHANGING <FS_LIST>.

      IF <FS_LIST>-RSLT EQ GC_S.
        <FS_LIST>-FLAG_C = GC_X.
        <FS_LIST>-FLAG_S = GC_X.

        PERFORM SET_CREDIT_INFO CHANGING <FS_LIST>.

        PERFORM SET_LED CHANGING <FS_LIST>.
      ELSE.
        CLEAR:<FS_LIST>-FLAG_S.
        <FS_LIST>-STAT1 = ICON_LED_RED.

      ENDIF.


      APPEND VALUE #( ZGUID       = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                      KUNNR1      = <FS_LIST>-KUNNR1
                      KUNNR2      = <FS_LIST>-KUNNR2
                      ZSTEP       = GC_C
                      PARTNER1    = <FS_LIST>-PARTNER1
                      PARTNER2    = <FS_LIST>-PARTNER2
                      CHECK_RULE1 = <FS_LIST>-CHECK_RULE1
                      CHECK_RULE2 = <FS_LIST>-CHECK_RULE2
                      CREDIT_SGMNT = <FS_LIST>-CREDIT_SGMNT2
                      TYPE        = <FS_LIST>-RSLT
                      MESSAGE     = <FS_LIST>-MESSAGE
                  ) TO GT_ZGTSDT9041.
    ENDIF.

  ENDLOOP.

  IF SY-BATCH IS NOT INITIAL.

    "LOG
    IF GT_ZGTSDT9041[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9041[] ).
      MODIFY ZGTSDT9041 FROM TABLE GT_ZGTSDT9041.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9041[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |[{ LV_MSG1 }/{ LV_MSG2 }]|.

      CLEAR LV_MSG2.
      LV_MSG2 = TEXT-002.
      LV_MSG2 = LV_MSG2 && TEXT-004.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-005 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.


  ELSE.

    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-M03 DISPLAY LIKE GC_E.
    ENDIF.

    PERFORM REFRESH_ALV USING GO_GRID.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BP_CREDIT_MAINTAINED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_LIST>
*&      <-- LV_NO
*&---------------------------------------------------------------------*
FORM CHECK_BP_CREDIT_MAINTAINED  USING    PS_LIST LIKE GT_LIST
                                 CHANGING PV_NO.

  "BP CREDIT
  SELECT SINGLE A~PARTNER,A~CHECK_RULE,
                B~CREDIT_SGMNT
    FROM UKMBP_CMS AS A LEFT OUTER JOIN UKMBP_CMS_SGM AS B
                        ON A~PARTNER = B~PARTNER
   WHERE A~PARTNER      EQ @PS_LIST-PARTNER2
     AND A~CHECK_RULE   EQ @GC_CHKRULE_LOCAL
     AND B~CREDIT_SGMNT EQ @PS_LIST-CREDIT_SGMNT1
    INTO @DATA(LS_UKMBP).
  IF SY-SUBRC NE 0.
    CLEAR:PV_NO.
  ELSE.
    IF LS_UKMBP-CREDIT_SGMNT IS NOT INITIAL.
      CLEAR:PV_NO.
    ELSE.
      PV_NO = GC_X.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CREDIT_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CREDIT_PROC  CHANGING PS_LIST LIKE GT_LIST.
  DATA: IO_FACADE       TYPE REF TO CL_UKM_FACADE,
        IO_PARTNER      TYPE REF TO CL_UKM_BUSINESS_PARTNER,
        IO_BUPA_FACTORY TYPE REF TO CL_UKM_BUPA_FACTORY,
        IO_ACCOUNT      TYPE REF TO CL_UKM_ACCOUNT.

  DATA: LS_BP_CREDIT_SGM TYPE UKM_S_BP_CMS_SGM,
        LS_UKM_S_BP_CMS  TYPE UKM_S_BP_CMS,
        LT_BP1012        TYPE UKM_T_BP1012,
        LV_GRADE         TYPE BP_GRADE,
        LS_NEW_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LS_OLD_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LT_ADD_INFO      TYPE UKM_TS_ADD_INFO,
        LS_ADD_INFO      TYPE UKM_S_ADD_INFO.

  DATA: LS_BUPA_ERROR TYPE MDS_CTRLS_ERROR.

  DATA: LV_PARTNER      TYPE BU_PARTNER,
        LV_CREDIT_SGMNT TYPE UKM_CREDIT_SGMNT,
        LV_CREDIT_GROUP TYPE UKM_CRED_GROUP,
        LV_CREDIT_LIMIT TYPE UKM_S_BP_CMS_SGM-CREDIT_LIMIT.

  DATA: LV_AMT  TYPE UKM_AMOUNT,
        LV_DATE TYPE SY-DATUM.

  DATA: LT_RETURN   TYPE UKM_T_MONITOR_RETURN,
        LT_RET2     TYPE TABLE OF BAPIRET2,
        LS_BAPIRET2 TYPE BAPIRET2.

  DATA: LV_CMS_CHK(1),
        LV_SGM_CHK(1).

  DATA: LV_MSG(100).

  LV_PARTNER = PS_LIST-PARTNER2.

*-------------------------------------------------------
*-01. CREDIT ROLE
*-------------------------------------------------------
  SELECT SINGLE PARTNER
    FROM BUT100
   WHERE PARTNER EQ @LV_PARTNER
     AND RLTYP   EQ 'UKM000'
    INTO @DATA(LV_PART).
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
      EXPORTING
        BUSINESSPARTNER             = LV_PARTNER
        BUSINESSPARTNERROLECATEGORY = 'UKM000'
        BUSINESSPARTNERROLE         = 'UKM000'
      TABLES
        RETURN                      = LT_RET2.
    LOOP AT LT_RET2 INTO DATA(LS_RET2) WHERE TYPE CA 'AE'.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      __BAPI_TRANSACTION_ROLLBACK.

      GV_ERROR = GC_X.

      PS_LIST-RSLT = GC_E.
      LOOP AT LT_RET2 INTO LS_RET2 WHERE TYPE CA 'AE'.
        CLEAR:LV_MSG.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = LS_RET2-ID
            MSGNR               = LS_RET2-NUMBER
            MSGV1               = LS_RET2-MESSAGE_V1
            MSGV2               = LS_RET2-MESSAGE_V2
            MSGV3               = LS_RET2-MESSAGE_V3
            MSGV4               = LS_RET2-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LV_MSG.
        IF PS_LIST-MESSAGE IS NOT INITIAL.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_LIST-MESSAGE = LV_MSG.
        ENDIF.
      ENDLOOP.
      EXIT.
    ENDIF.

    __BAPI_TRANSACTION_COMMIT.
    WAIT UP TO '0.5' SECONDS.
  ENDIF.

  "BP LOCK 체크
  DATA(LO_BUPA) = NEW CL_IM_MDS_BUPA_LOCK( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~LOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IF LS_BUPA_ERROR-IS_ERROR IS NOT INITIAL.
    GV_ERROR = GC_X.
    PS_LIST-RSLT = GC_E.
    DATA(LS_MSG) = VALUE #( LS_BUPA_ERROR-MESSAGES[ TYPE = GC_E
                                                    ID = 'MC'
                                                    NUMBER = '601' ] OPTIONAL ).
    IF LS_MSG IS NOT INITIAL.
      PS_LIST-MESSAGE = LS_MSG-MESSAGE.
    ELSE.
      LOOP AT LS_BUPA_ERROR-MESSAGES INTO LS_MSG WHERE TYPE EQ GC_E.
        IF PS_LIST-MESSAGE IS INITIAL.
          PS_LIST-MESSAGE = LS_MSG-MESSAGE.
        ELSE.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_MSG-MESSAGE }|.
        ENDIF.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.

  IO_FACADE       = CL_UKM_FACADE=>CREATE( I_ACTIVITY = CL_UKM_CNST_EVENTING=>BP_MAINTENANCE ).
  IO_BUPA_FACTORY = IO_FACADE->GET_BUPA_FACTORY( ).
  IO_PARTNER      = IO_BUPA_FACTORY->GET_BUSINESS_PARTNER( LV_PARTNER ).

*-------------------------------------------------------
*-02. CREDIT PROFILE
*-------------------------------------------------------

*-일반정보 유지보수
  IO_PARTNER->GET_BP_CMS( IMPORTING ES_BP_CMS = LS_UKM_S_BP_CMS ).

  IF LS_UKM_S_BP_CMS IS INITIAL.
    LV_CMS_CHK = GC_X.

    LS_UKM_S_BP_CMS-CHECK_RULE = GC_CHKRULE_LOCAL.
    LS_UKM_S_BP_CMS-RISK_CLASS = GC_RISK_CLASS_001. "'001'.

  ELSE.
    IF NOT ( LS_UKM_S_BP_CMS-CHECK_RULE EQ GC_CHKRULE_LOCAL AND
             LS_UKM_S_BP_CMS-RISK_CLASS EQ GC_RISK_CLASS_001       ).
      LV_CMS_CHK = GC_X.

      LS_UKM_S_BP_CMS-CHECK_RULE = GC_CHKRULE_LOCAL.
      LS_UKM_S_BP_CMS-RISK_CLASS = GC_RISK_CLASS_001.
    ENDIF.

  ENDIF.
  IF LV_CMS_CHK = GC_X.
    IO_PARTNER->SET_BP_CMS( LS_UKM_S_BP_CMS ).
  ENDIF.

*-------------------------------------------------------
*-03. CREDIT SEGMENT
*-------------------------------------------------------
  LV_CREDIT_SGMNT = PS_LIST-CREDIT_SGMNT1.

  CALL METHOD IO_BUPA_FACTORY->GET_CREDIT_ACCOUNT
    EXPORTING
      I_PARTNER         = LV_PARTNER
      I_CREDIT_SGMNT    = LV_CREDIT_SGMNT
    RECEIVING
      RO_CREDIT_ACCOUNT = IO_ACCOUNT.

  SELECT SINGLE PARTNER
    FROM UKMBP_CMS_SGM
   WHERE PARTNER      EQ @LV_PARTNER
     AND CREDIT_SGMNT EQ @LV_CREDIT_SGMNT
    INTO @LV_PART.
  IF SY-SUBRC EQ 0.

  ELSE.
    LV_SGM_CHK = GC_X.

    LS_BP_CREDIT_SGM-CREDIT_LIMIT   = LV_CREDIT_LIMIT.
    LS_BP_CREDIT_SGM-LIMIT_CHG_DATE = SY-DATLO.
  ENDIF.

  IF LV_SGM_CHK = GC_X.
    IO_ACCOUNT->SET_BP_CMS_SGM( EXPORTING IS_BP_CMS_SGM = LS_BP_CREDIT_SGM ).
  ENDIF.


*-------------------------------------------------------
*-04. SAVE
*-------------------------------------------------------
  IF LV_CMS_CHK IS INITIAL AND
     LV_SGM_CHK IS INITIAL.
    PS_LIST-RSLT    = GC_S.
*    PS_LIST-MESSAGE = TEXT-M12.

  ELSE.
    CALL METHOD IO_BUPA_FACTORY->SAVE_ALL
      EXPORTING
        I_UPD_TASK = ABAP_FALSE
*       I_FREE_ALL = NO
*       I_WITH_EXTERNAL_SCORINGS = NO
*       I_WITH_ADD_INFOS = ABAP_TRUE
*       I_WITH_VECTORS   = NO
*       I_WITH_ENQUEUE   = NO
*       I_FROM_HCP = NO
*       I_TESTRUN  = NO
      RECEIVING
        ET_RETURN  = LT_RETURN
      EXCEPTIONS
        FAILED     = 1
        OTHERS     = 2.
    IF LINE_EXISTS( LT_RETURN[ MSGTY = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_LIST-RSLT    = GC_E.
      PS_LIST-MESSAGE = TEXT-M02.
      LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE MSGTY EQ GC_E.
        PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      PS_LIST-RSLT    = GC_S.
      PS_LIST-MESSAGE = TEXT-S01.

    ENDIF.
  ENDIF.

  IO_BUPA_FACTORY->REFRESH_PREREAD_BUFFER( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~UNLOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IO_BUPA_FACTORY->FREE_ALL( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CREDIT_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_CREDIT_INFO  CHANGING PS_LIST LIKE GT_LIST.


  "BP CREDIT
  SELECT SINGLE A~PARTNER,A~CHECK_RULE,
                B~CREDIT_SGMNT
    FROM UKMBP_CMS AS A LEFT OUTER JOIN UKMBP_CMS_SGM AS B
                        ON A~PARTNER = B~PARTNER
   WHERE A~PARTNER      EQ @PS_LIST-PARTNER2
     AND A~CHECK_RULE   EQ @GC_CHKRULE_LOCAL
     AND B~CREDIT_SGMNT EQ @PS_LIST-CREDIT_SGMNT1
    INTO @DATA(LS_UKMBP).
  IF SY-SUBRC EQ 0.
    PS_LIST-CHECK_RULE2   = LS_UKMBP-CHECK_RULE.
    PS_LIST-CREDIT_SGMNT2 = LS_UKMBP-CREDIT_SGMNT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_BP_RELATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_BP_RELATIONS .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_BP_RELATIONS.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-MAINTAIN BP CREDIT
  PERFORM MAINTAIN_BP_RELATIONS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BP_RELATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BP_RELATIONS .
  DATA: LV_CNT TYPE I.

*-01. 선택
  IF NOT LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. VALIDATION
  DATA(LT_TEMP) = GT_LIST[].
  DELETE LT_TEMP WHERE SEL NE GC_X.
  DELETE LT_TEMP WHERE FLAG_X EQ GC_X.
  IF LT_TEMP[] IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL    EQ GC_X
                                       AND FLAG_X NE GC_X.
    "BP RELATIONS
    SELECT SINGLE *
      FROM BUT050
     WHERE PARTNER1 EQ @LS_LIST-PARTNER1
       AND PARTNER2 EQ @LS_LIST-PARTNER2
       AND RELTYP   EQ @GC_RELTYP_UKM001
       AND DFTVAL   EQ @LS_LIST-CREDIT_SGMNT1
      INTO @DATA(LS_BUT050).
    IF SY-SUBRC NE 0.
      LV_CNT = LV_CNT + 1.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF LV_CNT <= 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_RELATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_RELATIONS .
  DATA: LV_NO(1).
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR: GT_ZGTSDT9041,GT_ZGTSDT9041[].
  CLEAR GV_ERROR.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL    EQ GC_X
                                                      AND FLAG_X NE GC_X.
    GV_INDEX = SY-TABIX.

    CLEAR LV_NO.
    CLEAR:<FS_LIST>-RSLT,<FS_LIST>-MESSAGE.

    "여신확장 체크
    PERFORM CHECK_BP_CREDIT_MAINT_FINISH CHANGING <FS_LIST>.
    IF <FS_LIST>-RSLT EQ GC_E.
      GV_ERROR = GC_X.
      CLEAR:<FS_LIST>-FLAG_R.
      <FS_LIST>-STAT2 = ICON_LED_RED.
    ENDIF.

    IF <FS_LIST>-RSLT NE GC_E.
      "RELATION 체크
      PERFORM CHECK_BP_RELATIONS_EXIST CHANGING <FS_LIST>.
      IF <FS_LIST>-RSLT EQ GC_S.
        <FS_LIST>-FLAG_R = GC_X.
      ENDIF.

      "RELATIONS 생성
      IF <FS_LIST>-RSLT NE GC_S.
        PERFORM CREATE_BP_RELATIONS_PROC CHANGING <FS_LIST>.
*        IF <FS_LIST>-RSLT EQ GC_S.
*          DELETE GT_LIST INDEX GV_INDEX.
*        ENDIF.
      ENDIF.

    ENDIF.

    APPEND VALUE #( ZGUID       = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                    KUNNR1      = <FS_LIST>-KUNNR1
                    KUNNR2      = <FS_LIST>-KUNNR2
                    ZSTEP       = GC_R
                    PARTNER1    = <FS_LIST>-PARTNER1
                    PARTNER2    = <FS_LIST>-PARTNER2
                    CHECK_RULE1 = <FS_LIST>-CHECK_RULE1
                    CHECK_RULE2 = <FS_LIST>-CHECK_RULE2
                    CREDIT_SGMNT = <FS_LIST>-CREDIT_SGMNT2
                    TYPE        = <FS_LIST>-RSLT
                    MESSAGE     = <FS_LIST>-MESSAGE
                  ) TO GT_ZGTSDT9041.

    IF <FS_LIST>-RSLT EQ GC_S.
      DELETE GT_LIST INDEX GV_INDEX.
    ENDIF.

  ENDLOOP.

  IF SY-BATCH IS NOT INITIAL.

    "LOG
    IF GT_ZGTSDT9041[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9041[] ).
      MODIFY ZGTSDT9041 FROM TABLE GT_ZGTSDT9041.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9041[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |[{ LV_MSG1 }/{ LV_MSG2 }]|.

      CLEAR LV_MSG2.
      LV_MSG2 = TEXT-003.
      LV_MSG2 = LV_MSG2 && TEXT-004.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-005 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.


  ELSE.

    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-M03 DISPLAY LIKE GC_E.
    ELSE.
      MESSAGE I000 WITH TEXT-S02 DISPLAY LIKE GC_S.
    ENDIF.

    PERFORM REFRESH_ALV USING GO_GRID.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BP_CREDIT_MAINT_FINISH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM CHECK_BP_CREDIT_MAINT_FINISH  CHANGING PS_LIST LIKE GT_LIST.

  "BP CREDIT
  SELECT SINGLE A~PARTNER,A~CHECK_RULE,
                B~CREDIT_SGMNT
    FROM UKMBP_CMS AS A INNER JOIN UKMBP_CMS_SGM AS B
                        ON A~PARTNER = B~PARTNER
   WHERE A~PARTNER      EQ @PS_LIST-PARTNER2
     AND A~CHECK_RULE   EQ @GC_CHKRULE_LOCAL
     AND B~CREDIT_SGMNT EQ @PS_LIST-CREDIT_SGMNT1
    INTO @DATA(LS_UKMBP).
  IF SY-SUBRC NE 0.
    PS_LIST-RSLT = GC_E.
    PS_LIST-MESSAGE = TEXT-M04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BP_RELATIONS_EXIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM CHECK_BP_RELATIONS_EXIST  CHANGING PS_LIST LIKE GT_LIST.
  "BP RELATIONS
  SELECT SINGLE *
    FROM BUT050
   WHERE PARTNER1 EQ @PS_LIST-PARTNER1
     AND PARTNER2 EQ @PS_LIST-PARTNER2
     AND RELTYP   EQ @GC_RELTYP_UKM001
     AND DFTVAL   EQ @PS_LIST-CREDIT_SGMNT1
    INTO @DATA(LS_BUT050).
  IF SY-SUBRC EQ 0.
    PS_LIST-RSLT = GC_S.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_BP_RELATIONS_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM CREATE_BP_RELATIONS_PROC  CHANGING PS_LIST LIKE GT_LIST.
  DATA:LV_PARTNER1 LIKE  BAPIBUS1006_HEAD-BPARTNER,
       LV_PARTNER2 LIKE  BAPIBUS1006_HEAD-BPARTNER,
       LV_RELTYP   LIKE  BUT050-RELTYP,
       LV_FROMDATE LIKE  BAPIBUS1006002_HEADER-VALIDFROMDATE,
       LV_TODATE   LIKE  BAPIBUS1006002_HEADER-VALIDUNTILDATE,
       LV_DFTVAL   LIKE  BUT050-DFTVAL,
       LT_RETURN   TYPE TABLE OF BAPIRET2.

  LV_PARTNER1  = PS_LIST-PARTNER1.
  LV_PARTNER2  = PS_LIST-PARTNER2.
  LV_RELTYP    = GC_RELTYP_UKM001.
  LV_FROMDATE  = '00010101'.
  LV_TODATE    = '99991231'.
  LV_DFTVAL    = PS_LIST-CREDIT_SGMNT1.

  CALL FUNCTION 'BAPI_BUPR_RELATIONSHIP_CREATE'
    EXPORTING
      BUSINESSPARTNER1         = LV_PARTNER1
      BUSINESSPARTNER2         = LV_PARTNER2
      RELATIONSHIPCATEGORY     = LV_RELTYP
      VALIDFROMDATE            = LV_FROMDATE
      VALIDUNTILDATE           = LV_TODATE
      DIFFERENTIATIONTYPEVALUE = LV_DFTVAL
    TABLES
      RETURN                   = LT_RETURN.

  IF LINE_EXISTS( LT_RETURN[ TYPE = 'S' ID = 'R1' NUMBER = '048' ] ).
    __BAPI_TRANSACTION_COMMIT.

    PS_LIST-RSLT    = GC_S.
    PS_LIST-MESSAGE = TEXT-S03.
    PS_LIST-FLAG_R  = GC_X.

  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_LIST-RSLT   = GC_E.
    CLEAR:PS_LIST-FLAG_R.
    PS_LIST-STAT2  = ICON_LED_RED.

    LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
      IF PS_LIST-MESSAGE IS INITIAL.
        PS_LIST-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BACKGROUND_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BACKGROUND_PROCESS .
*-01. 로컬고객 여신확장
  DATA(LT_TEMP) = GT_LIST[].
  DELETE LT_TEMP WHERE FLAG_X EQ GC_X.
  DELETE LT_TEMP WHERE FLAG_C EQ GC_X  "여신영역
                   AND FLAG_S EQ GC_X. "여신 SEGMENT

  IF LT_TEMP[] IS NOT INITIAL.
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE FLAG_X NE GC_X
                                                        AND NOT ( FLAG_C EQ GC_X AND
                                                                  FLAG_S EQ GC_X     ).
      <FS_LIST>-SEL = GC_X.
    ENDLOOP.
    PERFORM MAINTAIN_BP_CREDIT_DATA.
  ENDIF.

*-02. 내수-로컬 연결
  MODIFY GT_LIST FROM VALUE #( SEL = '' )
                 TRANSPORTING SEL
                 WHERE SEL EQ GC_X.
  CLEAR:LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  DELETE LT_TEMP WHERE FLAG_X EQ GC_X.
  DELETE LT_TEMP WHERE FLAG_R EQ GC_X. "내수-로컬 연결
  IF LT_TEMP[] IS NOT INITIAL.
    LOOP AT GT_LIST ASSIGNING <FS_LIST> WHERE FLAG_X NE GC_X
                                          AND FLAG_C EQ GC_X
                                          AND FLAG_S EQ GC_X
                                          AND FLAG_R NE GC_X.
      <FS_LIST>-SEL = GC_X.
    ENDLOOP.
    PERFORM MAINTAIN_BP_RELATIONS.
  ENDIF.

ENDFORM.
