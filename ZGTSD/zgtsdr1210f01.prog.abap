*&---------------------------------------------------------------------*
*& Include          ZGTSDR1210F01
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

*-기준일자
  P_BDATE = SY-DATLO.

*-화폐단위
  P_PUNIT = '10000'.

*-통화
  P_CURR = GC_WAERS_KRW.
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
    IF SCREEN-GROUP1 EQ 'ZM2'. "기준일자
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
*  PERFORM MAKE_LIST.
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
         GV_TITLE,GV_PUNIT.

  REFRESH:
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

  GV_TITLE = TEXT-001.

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
  DATA: LT_LOCAL LIKE TABLE OF GT_LIST.

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

*-UKMBP_CMS_SGM + BP PARTNER
  SELECT A~VKBUR,
         A~VKGRP,
         B~PARTNER,
         B~CREDIT_SGMNT AS CRITER,
         B~CREDIT_LIMIT,
         B~XCRITICAL,
         I~CURRENCY,
         D~CUSTOMER     AS KUNNR,
         E~BEZEI        AS VKBUR_TX,
         F~BEZEI        AS VKGRP_TX,
         G~NAME1        AS KUNNR_TX,
         K~KTOKD
    FROM @LT_BASE AS A INNER JOIN UKMBP_CMS_SGM AS B
                       ON A~CREDIT_SGMNT = B~CREDIT_SGMNT
                       INNER JOIN BUT000 AS C
                       ON B~PARTNER = C~PARTNER
                       INNER JOIN CVI_CUST_LINK AS D
                       ON C~PARTNER_GUID = D~PARTNER_GUID
                       INNER JOIN KNA1 AS K
                       ON D~CUSTOMER = K~KUNNR
                       INNER JOIN BUT020 AS H
                       ON C~PARTNER = H~PARTNER
                       INNER JOIN UKMCRED_SGM0C AS I
                         ON A~CREDIT_SGMNT = I~CREDIT_SGMNT
                       LEFT OUTER JOIN TVKBT AS E
                       ON A~VKBUR = E~VKBUR   AND
                          E~SPRAS = @SY-LANGU
                       LEFT OUTER JOIN TVGRT AS F
                       ON A~VKGRP = F~VKGRP   AND
                          F~SPRAS = @SY-LANGU
                       LEFT OUTER JOIN ADRC AS G
                       ON H~ADDRNUMBER = G~ADDRNUMBER AND
                          G~NATION     = @SPACE
   WHERE D~CUSTOMER  IN @S_KUNNR
    INTO TABLE @DATA(LT_MAIN).

  CHECK LT_MAIN[] IS NOT INITIAL.

  SORT LT_MAIN BY PARTNER CRITER.

*------------------------------------------------
* [BP3100]- 정보범주 '10' , '50'
*------------------------------------------------
  DATA(LT_TEMP) = LT_MAIN[].

  IF LT_TEMP[] IS NOT INITIAL.
    SELECT *
      FROM BP3100
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE PARTNER  EQ @LT_TEMP-PARTNER
       AND CRITER   EQ @LT_TEMP-CRITER
       AND ADDTYPE  IN (@GC_ADDTYPE_10,@GC_ADDTYPE_50)
       AND DATEFR   LE @P_BDATE
       AND DATETO   GE @P_BDATE
       AND XFELD    EQ @GC_X
      INTO TABLE @DATA(LT_BP3100).
    SORT LT_BP3100 BY PARTNER CRITER ADDTYPE.
  ENDIF.

*------------------------------------------------
* [신용 익스포저]
*------------------------------------------------
  CLEAR GT_TOTALSDISPLAY[].
  CLEAR:GR_PARTNER_S[],GR_SEGMT_S[],GR_COMTYP_S[].
  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    "PARTNER
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_MAIN-PARTNER ) TO GR_PARTNER_S.
    "SEGMENT
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_MAIN-CRITER  ) TO GR_SEGMT_S.
  ENDLOOP.
  SORT:GR_PARTNER_S BY LOW,
       GR_SEGMT_S   BY LOW.
  DELETE ADJACENT DUPLICATES FROM GR_PARTNER_S COMPARING LOW.
  DELETE ADJACENT DUPLICATES FROM GR_SEGMT_S COMPARING LOW.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_COMMTYP_200  ) TO GR_COMTYP_S.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '300'  ) TO GR_COMTYP_S.

*  "신용 익스포저
*  PERFORM GET_CREDIT_EXPOSURE USING GS_LIST.

*------------------------------------------------
* [UKM_ITEM]
*------------------------------------------------
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT B~PARTNER,B~CREDIT_SGMNT, B~CURRENCY,
           SUM( B~AMOUNT ) AS AMOUNT
      FROM @LT_TEMP AS A INNER JOIN UKM_ITEM AS B
                         ON A~PARTNER = B~PARTNER AND
                            A~CRITER  = B~CREDIT_SGMNT
      GROUP BY B~PARTNER, B~CREDIT_SGMNT, B~CURRENCY
      INTO TABLE @DATA(LT_UKM_ITEM).
    SORT LT_UKM_ITEM BY PARTNER CREDIT_SGMNT.
  ENDIF.


*------------------------------------------------
* [리스트 구성]
*------------------------------------------------
  DATA: LV_AMT_IN TYPE WRBTR,
        LV_AMT_OT TYPE WRBTR.

  LOOP AT LT_MAIN INTO LS_MAIN.
    CLEAR GS_LIST.
    MOVE-CORRESPONDING LS_MAIN TO GS_LIST.
    GS_LIST-CURR = P_CURR.
    GS_LIST-DFTVAL = LS_MAIN-CRITER.

    "기본한도
    IF GS_LIST-CURR NE LS_MAIN-CURRENCY.
      IF LS_MAIN-CREDIT_LIMIT NE 0.
        CLEAR:LV_AMT_IN,LV_AMT_OT.
        LV_AMT_IN = LS_MAIN-CREDIT_LIMIT.
        LV_AMT_OT = ZGTSD_CL_COMMON2=>CONV_TO_LOCAL_CURRENCY( IV_DATE   = SY-DATLO
                                                              IV_FR_AMT = LV_AMT_IN
                                                              IV_FR_CUR = LS_MAIN-CURRENCY
                                                              IV_TO_CUR = GS_LIST-CURR
                                                             ).
      ENDIF.
    ELSE.
      LV_AMT_OT = LS_MAIN-CREDIT_LIMIT.
    ENDIF.
    GS_LIST-CREDIT_LIMIT = LV_AMT_OT.

    "유효담보,운영한도
    LOOP AT LT_BP3100 INTO DATA(LS_BP3100) WHERE PARTNER = LS_MAIN-PARTNER
                                             AND CRITER  = LS_MAIN-CRITER.

      CLEAR:LV_AMT_IN,LV_AMT_OT.
      IF GS_LIST-CURR NE LS_BP3100-CURR.
        IF LS_BP3100-AMNT NE 0.
          LV_AMT_IN = LS_BP3100-AMNT.
          LV_AMT_OT = ZGTSD_CL_COMMON2=>CONV_TO_LOCAL_CURRENCY( IV_DATE   = SY-DATLO
                                                                IV_FR_AMT = LV_AMT_IN
                                                                IV_FR_CUR = LS_BP3100-CURR
                                                                IV_TO_CUR = GS_LIST-CURR
                                                               ).
        ENDIF.
      ELSE.
        LV_AMT_OT = LS_BP3100-AMNT.
      ENDIF.

      CASE LS_BP3100-ADDTYPE.
        WHEN GC_ADDTYPE_10. "유효담보
          GS_LIST-AMNT_10 = GS_LIST-AMNT_10 + LV_AMT_OT.
        WHEN GC_ADDTYPE_50. "운영한도
          GS_LIST-AMNT_50 = GS_LIST-AMNT_50 + LV_AMT_OT.
      ENDCASE.
    ENDLOOP.

    "매출환산
    LOOP AT LT_UKM_ITEM INTO DATA(LS_UKM_ITEM) WHERE PARTNER      = LS_MAIN-PARTNER
                                                 AND CREDIT_SGMNT = LS_MAIN-CRITER.
      CLEAR:LV_AMT_IN,LV_AMT_OT.
      IF GS_LIST-CURR NE LS_UKM_ITEM-CURRENCY.
        IF LS_UKM_ITEM-AMOUNT NE 0.
          LV_AMT_IN = LS_UKM_ITEM-AMOUNT.
          LV_AMT_OT = ZGTSD_CL_COMMON2=>CONV_TO_LOCAL_CURRENCY( IV_DATE   = SY-DATLO
                                                                IV_FR_AMT = LV_AMT_IN
                                                                IV_FR_CUR = LS_UKM_ITEM-CURRENCY
                                                                IV_TO_CUR = GS_LIST-CURR
                                                               ).
        ENDIF.
      ELSE.
        LV_AMT_OT = LS_UKM_ITEM-AMOUNT.
      ENDIF.

      GS_LIST-AMOUNT = GS_LIST-AMOUNT + LV_AMT_OT.
    ENDLOOP.

    "채권
    CLEAR:GT_TOTALSDISPLAY[].
    PERFORM GET_CREDIT_EXPOSURE USING GS_LIST.
    LOOP AT GT_TOTALSDISPLAY INTO GS_TOTALSDISPLAY WHERE MSG_PARTNER  = LS_MAIN-PARTNER
                                                     AND CREDIT_SGMNT = LS_MAIN-CRITER.
      CLEAR:LV_AMT_IN,LV_AMT_OT.
      IF GS_LIST-CURR NE GS_TOTALSDISPLAY-CURRENCY.
        IF GS_TOTALSDISPLAY-AMOUNT NE 0.
          LV_AMT_IN = GS_TOTALSDISPLAY-AMOUNT.
          LV_AMT_OT = ZGTSD_CL_COMMON2=>CONV_TO_LOCAL_CURRENCY( IV_DATE   = SY-DATLO
                                                                IV_FR_AMT = LV_AMT_IN
                                                                IV_FR_CUR = GS_TOTALSDISPLAY-CURRENCY
                                                                IV_TO_CUR = GS_LIST-CURR
                                                               ).
        ENDIF.
      ELSE.
        LV_AMT_OT = GS_TOTALSDISPLAY-AMOUNT.
      ENDIF.

      GS_LIST-AMOUNT_AR = GS_LIST-AMOUNT_AR + LV_AMT_OT.
    ENDLOOP.

    "총여신 : 기본한도 + 유효담보 + 운영한도
    GS_LIST-AMNT_TOT = GS_LIST-CREDIT_LIMIT +
                       GS_LIST-AMNT_10      +
                       GS_LIST-AMNT_50.

    "사용여신 : 매출환산 + 채권
    GS_LIST-AMOUNT_TOT = GS_LIST-AMOUNT + GS_LIST-AMOUNT_AR.

    "여신잔액 : 총여신 - 사용여신
    GS_LIST-CREDIT_REMAIN = GS_LIST-AMNT_TOT - GS_LIST-AMOUNT_TOT.


*    "금액변경 : 선택조건 화면의 화페단위 적용
*    PERFORM SET_PUNIT_TO_AMOUNT CHANGING GS_LIST.

    "로컬지급처는 미 대상임 KNA1-KTOKD = '0003'.
    IF LS_MAIN-KTOKD EQ GC_KTOKD_0003.
      APPEND GS_LIST TO LT_LOCAL.
      CONTINUE.
    ENDIF.

    APPEND GS_LIST TO GT_LIST.
  ENDLOOP.

*-RELATION : BUT050
  DATA(LT_TEMP10) = LT_LOCAL[].
  SORT LT_TEMP10 BY PARTNER DFTVAL .
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING PARTNER DFTVAL.
  IF LT_TEMP10[] IS NOT INITIAL.
    SELECT PARTNER1,PARTNER2,DFTVAL
      FROM BUT050
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE PARTNER2 EQ @LT_TEMP10-PARTNER
       AND DATE_TO  GE @SY-DATLO
       AND RELTYP   EQ 'UKM001'
       AND DFTVAL   EQ @LT_TEMP10-DFTVAL
      INTO TABLE @DATA(LT_BUT050).
    SORT LT_BUT050 BY PARTNER1 PARTNER2 DFTVAL.
  ENDIF.

  IF LT_BUT050[] IS NOT INITIAL.

    LOOP AT LT_LOCAL INTO DATA(LS_LOCAL).
      READ TABLE LT_BUT050 INTO DATA(LS_BUT050) WITH KEY PARTNER2 = LS_LOCAL-PARTNER
                                                         DFTVAL   = LS_LOCAL-DFTVAL.

      IF SY-SUBRC EQ 0.
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WITH KEY PARTNER = LS_BUT050-PARTNER1
                                                                      CRITER  = LS_BUT050-DFTVAL
                                                                      KTOKD   = GC_KTOKD_0001.
        IF SY-SUBRC EQ 0.
          "기본한도
          <FS_LIST>-CREDIT_LIMIT = <FS_LIST>-CREDIT_LIMIT + LS_LOCAL-CREDIT_LIMIT.
          "유효담보
          <FS_LIST>-AMNT_10 = <FS_LIST>-AMNT_10 + LS_LOCAL-AMNT_10.
          "운영한도
          <FS_LIST>-AMNT_50 = <FS_LIST>-AMNT_50 + LS_LOCAL-AMNT_50.
          "총여신 : 기본한도 + 유효담보 + 운영한도
          <FS_LIST>-AMNT_TOT = <FS_LIST>-CREDIT_LIMIT +
                               <FS_LIST>-AMNT_10      +
                               <FS_LIST>-AMNT_50.

          "매출환산
          <FS_LIST>-AMOUNT  = <FS_LIST>-AMOUNT + LS_LOCAL-AMOUNT.
          "채권
          <FS_LIST>-AMOUNT_AR  = <FS_LIST>-AMOUNT_AR + LS_LOCAL-AMOUNT_AR.
          "사용여신 : 매출환산 + 채권
          <FS_LIST>-AMOUNT_TOT = <FS_LIST>-AMOUNT + <FS_LIST>-AMOUNT_AR.

          "여신잔액 : 총여신 - 사용여신
          <FS_LIST>-CREDIT_REMAIN = <FS_LIST>-AMNT_TOT - <FS_LIST>-AMOUNT_TOT.

        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  "금액변경 : 선택조건 화면의 화페단위 적용
  LOOP AT GT_LIST ASSIGNING <FS_LIST>.

    PERFORM SET_PUNIT_TO_AMOUNT CHANGING <FS_LIST>.
  ENDLOOP.

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
*& Form GET_CREDIT_EXPOSURE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CREDIT_EXPOSURE USING PS_LIST LIKE GT_LIST.
  DATA: LR_DATA  TYPE REF TO DATA.


  FIELD-SYMBOLS: <FS_TABLE> TYPE ANY TABLE,
                 <FS_LINE>  TYPE ANY.

  CLEAR:GR_PARTNER_S[],GR_SEGMT_S[].
*  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = PS_LIST-PARTNER )
*      TO GR_PARTNER_S.
*  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = PS_LIST-CRITER )
*      TO GR_SEGMT_S.


  CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING
                                  DISPLAY  = ABAP_FALSE
                                  METADATA = ABAP_FALSE
                                  DATA     = ABAP_TRUE  ).

  SET PARAMETER ID 'BPA' FIELD PS_LIST-PARTNER.
  SET PARAMETER ID 'UKM_SEGMENT' FIELD PS_LIST-CRITER.

  SUBMIT UKM_COMMTS_DELETE WITH S_PARTNER IN GR_PARTNER_S
                           WITH S_SEGMT   IN GR_SEGMT_S
                           WITH S_COMTYP  IN GR_COMTYP_S
                           WITH DEL_TOT   EQ SPACE
                           WITH DEL_ITEM  EQ SPACE
                           WITH REBUILD   EQ 'X'
                           WITH X_BUPR    EQ 'X'
                            AND RETURN.
  TRY.
      CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF( IMPORTING R_DATA = LR_DATA ).
      ASSIGN LR_DATA->* TO <FS_TABLE>.

    CATCH CX_SALV_BS_SC_RUNTIME_INFO.
      MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_W.

  ENDTRY.


  IF <FS_TABLE> IS ASSIGNED.
    LOOP AT <FS_TABLE> ASSIGNING <FS_LINE>.
      CLEAR GS_TOTALSDISPLAY.
      MOVE-CORRESPONDING <FS_LINE> TO GS_TOTALSDISPLAY.
      APPEND GS_TOTALSDISPLAY TO GT_TOTALSDISPLAY.
    ENDLOOP.
  ENDIF.

  CL_SALV_BS_RUNTIME_INFO=>CLEAR_ALL( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PUNIT_TO_AMOUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LIST
*&---------------------------------------------------------------------*
FORM SET_PUNIT_TO_AMOUNT  CHANGING PS_LIST LIKE GS_LIST.
  DATA:LV_AMT_IN TYPE ZGTE_AMNT,
       LV_AMT_OT TYPE ZGTE_AMNT.

  LOOP AT GT_FIELDCAT INTO GS_FIELDCAT WHERE DATATYPE EQ 'CURR'.
    CLEAR:LV_AMT_IN,LV_AMT_OT.
    ASSIGN COMPONENT GS_FIELDCAT-FIELDNAME OF STRUCTURE PS_LIST
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
                                      IV_CHANGE  = GC_X ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOTO_DETAILS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GOTO_DETAILS .
  "SELECTED ROWS
  PERFORM GET_SELECTED_ROWS USING GO_GRID.

  IF GT_ROWS[] IS INITIAL.
    MESSAGE I000 WITH TEXT-M03 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM GOTO_ZGTSDR1200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOTO_ZGTSDR1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GOTO_ZGTSDR1200 .
  RANGES: LR_VKORG FOR VBAK-VKORG,
          LR_VKBUR FOR VBAK-VKBUR,
          LR_VKGRP FOR VBAK-VKGRP,
          LR_KUNNR FOR VBAK-KUNNR.
  DATA: LV_CUMON LIKE S001-SPMON,
        LV_BFMON LIKE S001-SPMON,
        LV_PUNIT LIKE BP3100-AMNT,
        LV_CURR  LIKE BP3100-CURR.
  DATA: LV_DATE   TYPE SY-DATUM.

  LOOP AT GT_ROWS INTO GS_ROWS.
    CLEAR GS_LIST.
    READ TABLE GT_LIST INTO GS_LIST INDEX GS_ROWS-INDEX.
    CHECK SY-SUBRC EQ 0.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GS_LIST-VKBUR ) TO LR_VKBUR.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GS_LIST-VKGRP ) TO LR_VKGRP.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GS_LIST-KUNNR ) TO LR_KUNNR.
  ENDLOOP.
  LR_VKORG[] = S_VKORG[].

  LV_PUNIT = P_PUNIT.
  LV_CURR  = P_CURR.

  LV_CUMON = P_BDATE(6).
  LV_DATE(6) = P_BDATE(6).
  LV_DATE+6(2) = '01'.
  LV_DATE = LV_DATE - 1.
  LV_BFMON = LV_DATE(6).

  SUBMIT ZGTSDR1200 WITH S_VKORG IN LR_VKORG
                    WITH S_VKBUR IN LR_VKBUR
                    WITH S_VKGRP IN LR_VKGRP
                    WITH S_KUNNR IN LR_KUNNR
                    WITH P_CUMON EQ LV_CUMON
                    WITH P_BFMON EQ LV_BFMON
                    WITH P_PUNIT EQ LV_PUNIT
                    WITH P_CURR  EQ LV_CURR
                    WITH P_CHANG EQ SPACE
                    AND RETURN.
ENDFORM.
