*&---------------------------------------------------------------------*
*& Include          ZGTSDR1280F01
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
*-공급업체계정그룹
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_KTOKK_3800 )
      TO S_KTOKK.
*-회사코드
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_BUKRS_6000 )
      TO S_BUKRS.
*-영업조직
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 )
      TO S_VKORG.
*-유통경로
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VTWEG_50 )
      TO S_VTWEG.
*-제품군
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_3C )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_4C )
      TO S_SPART.
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
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
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
         GV_TITLE.

  REFRESH:
           GT_0100,GT_0200,GT_TVTA.
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
  GV_EDIT = GC_X.

  CASE GC_X.
    WHEN P_R01.  "일반/회계뷰
      GV_TITLE = TEXT-003.
    WHEN P_R02.  "영업뷰
      GV_TITLE = TEXT-004.

      PERFORM SET_TVTA.
  ENDCASE.


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
  CASE GC_X.
    WHEN P_R01.  "일반/회계뷰
      PERFORM GET_DATA_0100.

    WHEN P_R02.  "영업뷰
      PERFORM GET_DATA_0200.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_0100 .

*-01. 공급업체
  SELECT A~LIFNR,B~BUKRS,
         D~PARTNER,D~TYPE,
         E~ADDRNUMBER
    FROM LFA1 AS A INNER JOIN CVI_VEND_LINK AS C
                   ON A~LIFNR = C~VENDOR
                   INNER JOIN BUT000 AS D
                   ON C~PARTNER_GUID = D~PARTNER_GUID
                   INNER JOIN LFB1 AS B
                   ON A~LIFNR = B~LIFNR
                   LEFT OUTER JOIN BUT020 AS E
                   ON D~PARTNER = E~PARTNER

   WHERE A~KTOKK IN @S_KTOKK
     AND B~BUKRS IN @S_BUKRS
    INTO TABLE @DATA(LT_LFA1).
  SORT LT_LFA1 BY LIFNR.

  CHECK LT_LFA1[] IS NOT INITIAL.

*-02. 고객코드
  DATA(LT_TEMP) = LT_LFA1[].
  SORT LT_TEMP BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING LIFNR.

  SELECT A~KUNNR,B~BUKRS,
         D~PARTNER,D~TYPE,D~BU_GROUP,D~PARTNER_GUID,
         E~ADDRNUMBER
    FROM KNA1 AS A INNER JOIN CVI_CUST_LINK AS C
                   ON A~KUNNR = C~CUSTOMER
                   INNER JOIN BUT000 AS D
                   ON C~PARTNER_GUID = D~PARTNER_GUID
                   LEFT OUTER JOIN BUT020 AS E
                   ON D~PARTNER = E~PARTNER
                   LEFT OUTER JOIN KNB1 AS B
                   ON A~KUNNR = B~KUNNR
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE A~KUNNR EQ @LT_TEMP-LIFNR
     AND B~BUKRS IN @S_BUKRS
    INTO TABLE @DATA(LT_KNA1).

*-03. 공급업체기준 미생성 고객코드
  LOOP AT LT_LFA1 INTO DATA(LS_LFA1).
    DATA(LS_KNA1) = VALUE #( LT_KNA1[ KUNNR = LS_LFA1-LIFNR ] OPTIONAL ).
    IF LS_KNA1 IS NOT INITIAL.
*      IF LS_KNA1-BUKRS IS INITIAL.
*        CLEAR GS_0100.
*        GS_0100-LIFNR    = LS_LFA1-LIFNR.
*        GS_0100-TYPE     = GC_TYPE_2.
*        GS_0100-BU_GROUP = LS_KNA1-BU_GROUP.
*        GS_0100-RLTYP    = GC_RLTYP_FLCU00.
*        GS_0100-BUKRS    = VALUE #( S_BUKRS[ 1 ]-LOW OPTIONAL ).
*        GS_0100-KUNNR    = LS_KNA1-KUNNR.
*        GS_0100-AKONT    = GC_AKONT_BP.
*        GS_0100-RISK_CLASS = GC_RISK_CLASS_001.
*
*        GS_0100-ADDRNUMBER = LS_LFA1-ADDRNUMBER.
*
*        GS_0100-BUK      = GC_X.
*        GS_0100-PARTNER  = LS_KNA1-PARTNER.
*        GS_0100-PARTNER_GUID = LS_KNA1-PARTNER_GUID.
*
*        APPEND GS_0100 TO GT_0100.
*
*      ENDIF.
    ELSE.
      CLEAR GS_0100.
      GS_0100-LIFNR    = LS_LFA1-LIFNR.
      GS_0100-TYPE     = GC_TYPE_2.
      GS_0100-BU_GROUP = GC_BUGROUP_C120.
      GS_0100-RLTYP    = GC_RLTYP_FLCU00.
      GS_0100-BUKRS    = VALUE #( S_BUKRS[ 1 ]-LOW OPTIONAL ).
      GS_0100-KUNNR    = LS_LFA1-LIFNR.
      GS_0100-AKONT    = GC_AKONT_BP.
      GS_0100-RISK_CLASS = GC_RISK_CLASS_001.

      GS_0100-ADDRNUMBER = LS_LFA1-ADDRNUMBER.

      GS_0100-LANGU      = GC_3.


      GS_0100-NEW      = GC_X.

      APPEND GS_0100 TO GT_0100.
    ENDIF.

    CLEAR:LS_KNA1.
  ENDLOOP.

  CHECK GT_0100[] IS NOT INITIAL.

*-04. OTHER DATA

  DATA(LT_TEMP10) = GT_0100[].
  SORT LT_TEMP10 BY ADDRNUMBER.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING ADDRNUMBER.
  IF LT_TEMP10[] IS NOT INITIAL.
    "ADRC
    SELECT *
      FROM ADRC
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE ADDRNUMBER EQ @LT_TEMP10-ADDRNUMBER
       AND DATE_FROM  LE @SY-DATLO
       AND NATION     EQ @SPACE
      INTO TABLE @DATA(LT_ADRC).
    SORT LT_ADRC BY ADDRNUMBER.

    "ADR6
    SELECT *
      FROM ADR6
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE ADDRNUMBER EQ @LT_TEMP10-ADDRNUMBER
       AND DATE_FROM  LE @SY-DATLO
       AND FLGDEFAULT EQ @GC_X
      INTO TABLE @DATA(LT_ADR6).
    SORT LT_ADR6 BY ADDRNUMBER.
  ENDIF.

*-05. LIST 구성
  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>).
    "ADRC
    DATA(LS_ADRC) = VALUE #( LT_ADRC[ ADDRNUMBER = <FS_0100>-ADDRNUMBER ] OPTIONAL ).
    IF LS_ADRC IS NOT INITIAL.
      <FS_0100>-NAME1       = LS_ADRC-NAME1.
      <FS_0100>-NAME2       = LS_ADRC-NAME2.
      <FS_0100>-SORT1       = LS_ADRC-SORT1.
      <FS_0100>-POST_CODE1  = LS_ADRC-POST_CODE1.
      <FS_0100>-CITY1       = LS_ADRC-CITY1.
      <FS_0100>-STREET      = LS_ADRC-STREET.
      <FS_0100>-COUNTRY     = LS_ADRC-COUNTRY.
      <FS_0100>-REGION      = LS_ADRC-REGION.
*      <FS_0100>-LANGU       = LS_ADRC-LANGU.
      <FS_0100>-TEL_NUMBER  = LS_ADRC-TEL_NUMBER.
      <FS_0100>-EXTENSION1  = LS_ADRC-EXTENSION1.

      <FS_0100>-STAT        = ICON_LED_YELLOW.
    ENDIF.

    "ADR6
    DATA(LS_ADR6) = VALUE #( LT_ADR6[ ADDRNUMBER = <FS_0100>-ADDRNUMBER ] OPTIONAL ).
    IF LS_ADR6 IS NOT INITIAL.
      <FS_0100>-SMTP_ADDR   = LS_ADR6-SMTP_ADDR.

      <FS_0100>-STAT        = ICON_LED_YELLOW.
    ENDIF.

    "LED
    PERFORM SET_LED_0100 CHANGING <FS_0100>.

    CLEAR:LS_ADRC,LS_ADR6.
  ENDLOOP.


  FREE: LS_KNA1,LT_TEMP,LT_TEMP10,LT_ADRC,LT_ADR6,LT_LFA1,LT_KNA1,LS_ADRC,LS_ADR6.
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

  CASE GC_X.
    WHEN P_R01.  "일반/회계뷰
      IF GT_0100[] IS NOT INITIAL.
        IF SY-BATCH IS NOT INITIAL.
          PERFORM BACKGROUND_PROCESS USING GC_A.
        ELSE.
          CALL SCREEN 0100.
        ENDIF.
      ELSE.
        MESSAGE S018.
      ENDIF.
    WHEN P_R02.  "영업뷰
      IF GT_0200[] IS NOT INITIAL.
        IF SY-BATCH IS NOT INITIAL.
          PERFORM BACKGROUND_PROCESS USING GC_B.
        ELSE.
          CALL SCREEN 0200.
        ENDIF.
      ELSE.
        MESSAGE S018.
      ENDIF.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM SET_LED_0100  CHANGING PS_0100 LIKE GT_0100.
  CASE PS_0100-RSLT.
    WHEN GC_S.
      PS_0100-STAT = ICON_LED_GREEN.
    WHEN GC_E.
      PS_0100-STAT = ICON_LED_RED.
    WHEN OTHERS.
      PS_0100-STAT = ICON_LED_YELLOW.
  ENDCASE.
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

  CASE GC_X.
    WHEN P_R01.  "일반/회계뷰
      MODIFY GT_0100 FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                 WHERE SEL NE GC_X
                   AND RSLT NE GC_S.

    WHEN P_R02.  "영업뷰
      MODIFY GT_0200 FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                 WHERE SEL NE GC_X
                   AND RSLT NE GC_S.
  ENDCASE.

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
  CASE GC_X.
    WHEN P_R01.  "일반/회계뷰
      MODIFY GT_0100 FROM VALUE #( SEL = '' )
                 TRANSPORTING SEL
                 WHERE SEL EQ GC_X
                   AND RSLT NE GC_S.

    WHEN P_R02.  "영업뷰
      MODIFY GT_0200 FROM VALUE #( SEL = '' )
                 TRANSPORTING SEL
                 WHERE SEL EQ GC_X
                   AND RSLT NE GC_S.
  ENDCASE.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PARTNERFUNC_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PARTNERFUNC_0100 .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_LIST_PRCESS_0100.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 판매처에 로컬지급처 지정
  PERFORM MAINTAIN_BP_PART_PROC_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LIST_PRCESS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LIST_PRCESS_0100 .
  DATA:LV_CHK(1).


*-01. 선택
  IF NOT LINE_EXISTS( GT_0100[ SEL = GC_X ] ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02.
  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL  EQ GC_X
                                                      AND RSLT NE GC_S.
    CLEAR:<FS_0100>-NEW.

    SELECT SINGLE KUNNR
      FROM KNB1
     WHERE KUNNR EQ @<FS_0100>-KUNNR
       AND BUKRS EQ @<FS_0100>-BUKRS
      INTO @DATA(LV_KUNNR).
*    SELECT SINGLE A~PARTNER, A~PARTNER_GUID
*      INTO @DATA(LS_CUST)
*      FROM BUT000 AS A INNER JOIN CVI_CUST_LINK AS B
*                       ON A~PARTNER_GUID = B~PARTNER_GUID
*    WHERE B~CUSTOMER =  @<FS_0100>-KUNNR.
    IF SY-SUBRC NE 0.
      LV_CHK        = GC_X.
      <FS_0100>-NEW = GC_X.
    ENDIF.
  ENDLOOP.

  IF LV_CHK IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-E01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PART_PROC_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PART_PROC_0100 .
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR GV_ERROR.
  CLEAR GT_ZGTSDT9040[].

  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) WHERE SEL  EQ GC_X
                                                      AND RSLT NE GC_S
                                                      AND NEW  EQ GC_X.

    "BP MAINTAIN
    PERFORM MAINTAIN_BP_0100 CHANGING <FS_0100>.

    "LED
    PERFORM SET_LED_0100 CHANGING <FS_0100>.

    PERFORM SET_ATTRIBUTES_LINE_0100 CHANGING <FS_0100>.

    CLEAR <FS_0100>-SEL.

    IF <FS_0100>-RSLT EQ GC_E.
      GV_ERROR = GC_X.
    ENDIF.

    APPEND VALUE #( ZGUID   = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                    KUNNR   = <FS_0100>-KUNNR
                    BUKRS   = <FS_0100>-BUKRS
                    TYPE    = <FS_0100>-RSLT
                    MESSAGE = <FS_0100>-MESSAGE
                  ) TO GT_ZGTSDT9040.
  ENDLOOP.


  IF SY-BATCH IS NOT INITIAL.
    "LOG
    IF GT_ZGTSDT9040[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9040[] ).
      MODIFY ZGTSDT9040 FROM TABLE GT_ZGTSDT9040.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9040[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |[{ LV_MSG1 }/{ LV_MSG2 }]|.

      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_R01. "일반/회계뷰
          LV_MSG2 = TEXT-005.
        WHEN P_R02. "영업뷰
          LV_MSG2 = TEXT-006.
      ENDCASE.
      LV_MSG2 = LV_MSG2 && TEXT-007.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-008 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.

  ELSE.
    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    ELSE.
      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_R01. "일반/회계뷰
          LV_MSG2 = TEXT-005.
        WHEN P_R02. "영업뷰
          LV_MSG2 = TEXT-006.
      ENDCASE.
      LV_MSG2 = LV_MSG2 && TEXT-007.
      MESSAGE I000 WITH LV_MSG2 DISPLAY LIKE GC_S.
    ENDIF.
    PERFORM REFRESH_ALV USING GO_GRID.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_0100  CHANGING PS_0100 LIKE GT_0100.
  DATA: LT_RETURN_MAP TYPE MDG_BS_BP_MSGMAP_T,
        LT_RETURN     TYPE BAPIRETM.
  DATA: LV_MSG(200).

  CLEAR:GT_DATA[], GS_DATA.

*-01. BP 일반데이터(KNA1)
  PERFORM SET_BP_GENERAL USING PS_0100.

*-02. CUSTOMER
  PERFORM SET_BP_CUSTOMER USING PS_0100.

*-03. VALIDATION
  CALL METHOD CL_MD_BP_MAINTAIN=>VALIDATE_SINGLE
    EXPORTING
      I_DATA        = GS_DATA
    IMPORTING
      ET_RETURN_MAP = LT_RETURN_MAP.

  IF LT_RETURN_MAP[] IS NOT INITIAL.
    PS_0100-RSLT    = GC_E.

    LOOP AT LT_RETURN_MAP INTO DATA(LS_RETURN_MAP) WHERE TYPE CA 'AE'.
      CLEAR:LV_MSG.
      PERFORM SET_RETURN_MESSAGE USING LS_RETURN_MAP-TYPE
                                       LS_RETURN_MAP-ID
                                       LS_RETURN_MAP-NUMBER
                                       LS_RETURN_MAP-MESSAGE_V1
                                       LS_RETURN_MAP-MESSAGE_V2
                                       LS_RETURN_MAP-MESSAGE_V3
                                       LS_RETURN_MAP-MESSAGE_V4
                                 CHANGING LV_MSG.
      IF PS_0100-MESSAGE IS NOT INITIAL.
        PS_0100-MESSAGE = |{ PS_0100-MESSAGE }/{ LV_MSG }|.
      ELSE.
        PS_0100-MESSAGE = LV_MSG.
      ENDIF.
    ENDLOOP.
    EXIT.
  ENDIF.

*-04.저장
  APPEND GS_DATA TO GT_DATA.

  CALL METHOD CL_MD_BP_MAINTAIN=>MAINTAIN
    EXPORTING
      I_DATA   = GT_DATA
    IMPORTING
      E_RETURN = LT_RETURN.
  LOOP AT LT_RETURN INTO DATA(LS_RETURN).
    LOOP AT LS_RETURN-OBJECT_MSG INTO DATA(LS_MSG) WHERE TYPE CA 'AE'.
      EXIT.
    ENDLOOP.
  ENDLOOP.

  IF LS_MSG IS INITIAL.
    __BAPI_TRANSACTION_COMMIT.

    PS_0100-RSLT    = GC_S.

    WAIT UP TO '0.5' SECONDS.

    PERFORM GET_BP_NUMBER CHANGING PS_0100.

    "EXTENSION1 UPDATE
    PERFORM UPDATE_ADRC USING PS_0100.


  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_0100-RSLT    = GC_E.

    LOOP AT LT_RETURN INTO LS_RETURN.
      LOOP AT LS_RETURN-OBJECT_MSG INTO LS_MSG WHERE TYPE CA 'AE'.
        CLEAR:LV_MSG.
        PERFORM SET_RETURN_MESSAGE USING LS_MSG-TYPE
                                         LS_MSG-ID
                                         LS_MSG-NUMBER
                                         LS_MSG-MESSAGE_V1
                                         LS_MSG-MESSAGE_V2
                                         LS_MSG-MESSAGE_V3
                                         LS_MSG-MESSAGE_V4
                                   CHANGING LV_MSG.
        IF PS_0100-MESSAGE IS NOT INITIAL.
          PS_0100-MESSAGE = |{ PS_0100-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_0100-MESSAGE = LV_MSG.
        ENDIF.
      ENDLOOP.
    ENDLOOP.


  ENDIF.

*-05. RISK CLASS
  IF PS_0100-RSLT EQ GC_S AND PS_0100-PARTNER_CU IS NOT INITIAL.
    PERFORM SET_RISK_CLASS USING PS_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_GENERAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_GENERAL  USING    PS_0100 LIKE GT_0100.
  DATA: LV_TASK(1),
        LV_PARTNER      TYPE BU_PARTNER,
        LV_PARTNER_GUID TYPE SYSUUID_X16.

  SELECT SINGLE A~PARTNER, A~PARTNER_GUID
    INTO @DATA(LS_BUT000)
    FROM BUT000 AS A INNER JOIN CVI_CUST_LINK AS B
                     ON   A~PARTNER_GUID = B~PARTNER_GUID
    WHERE B~CUSTOMER = @PS_0100-KUNNR.
  IF SY-SUBRC EQ 0.
    LV_TASK = GC_U.
    LV_PARTNER = LS_BUT000-PARTNER.
    LV_PARTNER_GUID = LS_BUT000-PARTNER_GUID.


  ELSE.
    LV_TASK = GC_I.
    LV_PARTNER_GUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( ).
    GS_DATA-ENSURE_CREATE-CREATE_CUSTOMER = ABAP_TRUE.
  ENDIF.

  GS_DATA-PARTNER-HEADER-OBJECT_TASK = LV_TASK.
  GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER = LV_PARTNER .
  GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNERGUID = LV_PARTNER_GUID.


  IF LV_TASK EQ GC_I.
    GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CONTROL-CATEGORY = PS_0100-TYPE.
    GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CONTROL-GROUPING = PS_0100-BU_GROUP.
  ENDIF.

  "BP ROLE
  PERFORM SET_BP_ROLE USING PS_0100
                            LV_PARTNER.


  "이름 1/이름2
  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-NAME1 = PS_0100-NAME1.
  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-NAME2 = PS_0100-NAME2.

  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-NAME1 = GC_X.
  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-NAME2 = GC_X.

  "검색어 1
  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-SEARCHTERM1 = PS_0100-SORT1.
  GS_DATA-PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-SEARCHTERM1 = GC_X.

*  "언어
*  GS_DATA-PARTNER--CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-PARTNERLANGUAGE = PS_0100-LANGU.
*  GS_DATA-PARTNER--CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-PARTNERLANGUAGE = GC_X.


  "BP ADDRESS
  PERFORM SET_BP_ADDRESS USING PS_0100.







ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_ADDRESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_ADDRESS  USING    PS_0100 LIKE GT_0100.
  DATA: LT_ADDRESS TYPE BUS_EI_BUPA_ADDRESS_T,
        LS_ADDRESS TYPE BUS_EI_BUPA_ADDRESS.
  DATA: LT_PHONE TYPE BUS_EI_BUPA_TELEPHONE_T,
        LT_FAX   TYPE BUS_EI_BUPA_FAX_T,
        LT_SMTP  TYPE BUS_EI_BUPA_SMTP_T.
  DATA: LV_TASK    TYPE BUS_EI_OBJECT_TASK.

  IF GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER IS NOT INITIAL.
    SELECT SINGLE ADDRNUMBER,ADDRESS_GUID
      INTO (@DATA(LV_ADDRNUMBER),@DATA(LV_AGUID))
      FROM BUT020
     WHERE PARTNER EQ @GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER.
    IF SY-SUBRC EQ 0.
      LV_TASK = GC_U.
    ELSE.
      LV_TASK = GC_I.

    ENDIF.
  ELSE.
    LV_TASK = GC_I.
  ENDIF.
  IF LV_TASK EQ GC_I.
    TRY.
        CALL METHOD CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC
          RECEIVING
            UUID = LV_AGUID.
      CATCH CX_UUID_ERROR.
    ENDTRY.
  ENDIF.

  LS_ADDRESS-TASK = LV_TASK.
  LS_ADDRESS-DATA_KEY-GUID = LV_AGUID.

  "우편번호 POST_CODE1
  LS_ADDRESS-DATA-POSTAL-DATA-POSTL_COD1  = PS_0100-POST_CODE1.
  LS_ADDRESS-DATA-POSTAL-DATAX-POSTL_COD1 = ABAP_TRUE.
  "도시 CITY1
  LS_ADDRESS-DATA-POSTAL-DATA-CITY        = PS_0100-CITY1.
  LS_ADDRESS-DATA-POSTAL-DATAX-CITY       = ABAP_TRUE.
  "도로주소 STREET
  LS_ADDRESS-DATA-POSTAL-DATA-STREET        = PS_0100-STREET.
  LS_ADDRESS-DATA-POSTAL-DATAX-STREET       = ABAP_TRUE.
  "국가 COUNTRY
  LS_ADDRESS-DATA-POSTAL-DATA-COUNTRY        = PS_0100-COUNTRY.
  LS_ADDRESS-DATA-POSTAL-DATAX-COUNTRY       = ABAP_TRUE.
  "지역 REGION
  LS_ADDRESS-DATA-POSTAL-DATA-REGION        = PS_0100-REGION.
  LS_ADDRESS-DATA-POSTAL-DATAX-REGION       = ABAP_TRUE.
  "언어 LANGU
  LS_ADDRESS-DATA-POSTAL-DATA-LANGU        = PS_0100-LANGU.
  LS_ADDRESS-DATA-POSTAL-DATAX-LANGU       = ABAP_TRUE.

* 전화번호
  IF PS_0100-TEL_NUMBER IS NOT INITIAL.
    PERFORM SET_TEL_NUMBER    USING PS_0100
                                    LV_ADDRNUMBER
                           CHANGING LT_PHONE.
    IF LT_PHONE[] IS NOT INITIAL.
      LS_ADDRESS-DATA-COMMUNICATION-PHONE-PHONE[] = LT_PHONE[].
    ENDIF.
  ENDIF.

* E-MAIL
  IF PS_0100-SMTP_ADDR IS NOT INITIAL.
    PERFORM SET_SMTP_NUMBER    USING PS_0100
                                     LV_ADDRNUMBER
                            CHANGING LT_SMTP.
    IF LT_SMTP[] IS NOT INITIAL.
      LS_ADDRESS-DATA-COMMUNICATION-SMTP-SMTP[] = LT_SMTP[].
    ENDIF.

  ENDIF.

  APPEND LS_ADDRESS TO LT_ADDRESS.

  GS_DATA-PARTNER-CENTRAL_DATA-ADDRESS-CURRENT_STATE = GC_C. "현 ADDRESS를 MODIFY함
  GS_DATA-PARTNER-CENTRAL_DATA-ADDRESS-ADDRESSES[]   = LT_ADDRESS[].


*E-MAIL
*대표자명

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEL_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&      <-- LT_PHONE
*&---------------------------------------------------------------------*
FORM SET_TEL_NUMBER  USING    PS_0100 LIKE GT_0100
                              PV_ADDRNUMBER
                     CHANGING PT_PHONE TYPE BUS_EI_BUPA_TELEPHONE_T.
  DATA: LS_PHONE TYPE BUS_EI_BUPA_TELEPHONE.
  DATA: LS_MOBILE TYPE BUS_EI_BUPA_TELEPHONE.
  DATA: LV_TASK    TYPE BUS_EI_OBJECT_TASK.
  DATA: LV_UPDATEFLAG TYPE UPDATEFLAG.
  DATA: LV_CONSNUMBER TYPE AD_CONSNUM.

  IF PV_ADDRNUMBER IS NOT INITIAL.


    SELECT *
      INTO TABLE @DATA(LT_ADR2)
      FROM ADR2
     WHERE ADDRNUMBER EQ @PV_ADDRNUMBER.

  ENDIF.

  IF LT_ADR2[] IS NOT INITIAL.
    LV_TASK = GC_U.

    DATA(LS_ADR2) = VALUE #( LT_ADR2[ ADDRNUMBER = PV_ADDRNUMBER
                                      R3_USER    = GC_1          ] OPTIONAL ).

    IF LS_ADR2 IS NOT INITIAL.
      LV_UPDATEFLAG = GC_U.
      LV_CONSNUMBER = LS_ADR2-CONSNUMBER.
    ELSE.
      LV_UPDATEFLAG = GC_I.
      SORT LT_ADR2 BY CONSNUMBER DESCENDING.
      LV_CONSNUMBER = VALUE #( LT_ADR2[ 1 ]-CONSNUMBER OPTIONAL ).
      LV_CONSNUMBER = LV_CONSNUMBER + 1.
    ENDIF.

  ELSE.
    LV_TASK = GC_I.
  ENDIF.


  LS_PHONE-CONTACT-TASK = LV_TASK.
  LS_PHONE-CONTACT-DATA-COUNTRY     = PS_0100-COUNTRY.
  LS_PHONE-CONTACT-DATA-TELEPHONE   = PS_0100-TEL_NUMBER.
  LS_PHONE-CONTACT-DATA-CONSNUMBER  = LV_CONSNUMBER.
  LS_PHONE-CONTACT-DATA-HOME_FLAG   = GC_X.
  LS_PHONE-CONTACT-DATA-R_3_USER    = GC_1.
  LS_PHONE-CONTACT-DATA-STD_NO      = GC_X.

  LS_PHONE-CONTACT-DATAX-COUNTRY     = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-TELEPHONE   = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-CONSNUMBER  = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-HOME_FLAG   = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-R_3_USER    = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-STD_NO      = ABAP_TRUE.
  LS_PHONE-CONTACT-DATAX-UPDATEFLAG  = LV_UPDATEFLAG.
  IF LV_UPDATEFLAG EQ GC_U.
    LS_PHONE-CONTACT-DATA-VALID_FROM  = LS_ADR2-VALID_FROM.
    LS_PHONE-CONTACT-DATAX-VALID_FROM = ABAP_TRUE.
  ENDIF.

  APPEND LS_PHONE TO PT_PHONE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SMTP_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_PARTNER
*&      --> LV_ADDRNUMBER
*&      <-- LT_SMTP
*&---------------------------------------------------------------------*
FORM SET_SMTP_NUMBER  USING    PS_0100 LIKE GT_0100
                               PV_ADDRNUMBER
                      CHANGING PT_SMTP TYPE BUS_EI_BUPA_SMTP_T.
  DATA: LS_SMTP   TYPE BUS_EI_BUPA_SMTP.
  DATA: LV_TASK   TYPE BUS_EI_OBJECT_TASK.
  DATA: LV_CONSNUMBER TYPE AD_CONSNUM.

  IF PV_ADDRNUMBER IS NOT INITIAL.
    SELECT SINGLE * INTO @DATA(LS_ADR6)
      FROM ADR6
     WHERE ADDRNUMBER EQ @PV_ADDRNUMBER.

    IF SY-SUBRC EQ 0.
      LV_TASK = GC_U.
      LV_CONSNUMBER = LS_ADR6-CONSNUMBER.
    ELSE.
      LV_TASK = GC_I.
      LV_CONSNUMBER = LV_CONSNUMBER + 1.
    ENDIF.
  ELSE.
    LV_TASK = GC_I.
    LV_CONSNUMBER = LV_CONSNUMBER + 1.
  ENDIF.

  LS_SMTP-CONTACT-TASK = LV_TASK.
  LS_SMTP-CONTACT-DATA-STD_NO      = GC_X.
  LS_SMTP-CONTACT-DATA-E_MAIL      = PS_0100-SMTP_ADDR.
  LS_SMTP-CONTACT-DATA-EMAIL_SRCH  = TO_UPPER( VAL = PS_0100-SMTP_ADDR ).
  LS_SMTP-CONTACT-DATA-HOME_FLAG   = GC_X.
  LS_SMTP-CONTACT-DATA-CONSNUMBER  = LV_CONSNUMBER.

  LS_SMTP-CONTACT-DATAX-STD_NO      = ABAP_TRUE.
  LS_SMTP-CONTACT-DATAX-E_MAIL      = ABAP_TRUE.
  LS_SMTP-CONTACT-DATAX-EMAIL_SRCH  = ABAP_TRUE.
  LS_SMTP-CONTACT-DATAX-HOME_FLAG   = ABAP_TRUE.
  LS_SMTP-CONTACT-DATAX-CONSNUMBER  = ABAP_TRUE.
  LS_SMTP-CONTACT-DATAX-UPDATEFLAG = LV_TASK.

  IF LV_TASK EQ GC_U.
    LS_SMTP-CONTACT-DATA-VALID_FROM  = LS_ADR6-VALID_FROM.
    LS_SMTP-CONTACT-DATAX-VALID_FROM = ABAP_TRUE.
  ENDIF.

  APPEND LS_SMTP TO PT_SMTP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_ROLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_ROLE  USING    PS_0100 LIKE GT_0100
                           PV_PARTNER.
  DATA: LT_ROLES TYPE BUS_EI_BUPA_ROLES_T.

  IF PV_PARTNER IS NOT INITIAL.
    SELECT *
      INTO TABLE @DATA(LT_BUT100)
      FROM BUT100
     WHERE PARTNER EQ @PV_PARTNER.
  ENDIF.

  IF NOT ( LINE_EXISTS( LT_BUT100[ PARTNER = PV_PARTNER
                                   RLTYP   = PS_0100-RLTYP ] ) ).
    APPEND VALUE #( TASK            = GC_I
                    DATA_KEY        = PS_0100-RLTYP
*                    DATA-VALID_FROM = SY-DATLO
                    DATA-VALID_TO   = '99991231'
*                    DATAX-VALID_FROM = ABAP_TRUE
                    DATAX-VALID_TO   = ABAP_TRUE
                  ) TO LT_ROLES.
  ENDIF.
  "UKM000
  IF NOT ( LINE_EXISTS( LT_BUT100[ PARTNER = PV_PARTNER
                                   RLTYP   = GC_ROLE_UKM000 ] ) ).
    APPEND VALUE #( TASK            = GC_I
                    DATA_KEY        = GC_ROLE_UKM000
*                    DATA-VALID_FROM = SY-DATLO
                    DATA-VALID_TO   = '99991231'
*                    DATAX-VALID_FROM = ABAP_TRUE
                    DATAX-VALID_TO   = ABAP_TRUE
                  ) TO LT_ROLES.
  ENDIF.
  IF LT_ROLES[] IS NOT INITIAL.
    GS_DATA-PARTNER-CENTRAL_DATA-ROLE-ROLES[] = CORRESPONDING #( LT_ROLES[] ).
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_CUSTOMER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_CUSTOMER  USING    PS_0100 LIKE GT_0100.

*-01. GENERAL
  PERFORM SET_BP_CUST_GENERAL USING PS_0100.

*-02. COMPANY CODE
  PERFORM SET_BP_CUST_COMPANY USING PS_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_CUST_GENERAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_CUST_GENERAL  USING    PS_0100 LIKE GT_0100.
  DATA: LV_TASK   TYPE BUS_EI_OBJECT_TASK.

  SELECT SINGLE KUNNR
    INTO @DATA(LV_KUNNR)
    FROM KNA1
   WHERE KUNNR EQ @PS_0100-KUNNR.
  IF SY-SUBRC EQ 0.
    LV_TASK = GC_U.
  ELSE.
    LV_TASK = GC_I.
  ENDIF.

*------------------------------------------
* HEADER
*------------------------------------------
  GS_DATA-CUSTOMER-HEADER-OBJECT_TASK = LV_TASK.
  GS_DATA-CUSTOMER-HEADER-OBJECT_INSTANCE-KUNNR = PS_0100-KUNNR.

*------------------------------------------
* CENTRAL
*------------------------------------------
  "공급업체
  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-LIFNR = PS_0100-LIFNR.
  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-LIFNR = ABAP_TRUE.
  "사업자구분
  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-FITYP  = '01'.
  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-FITYP  = ABAP_TRUE.

  "고객계정그룹
*  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-KTOKD   = PS_0100-KTOKD.
*  GS_DATA-CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-KTOKD  = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_CUST_COMPANY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_BP_CUST_COMPANY  USING    PS_0100 LIKE GT_0100.
  DATA : LS_COMPANY TYPE CMDS_EI_COMPANY.

  SELECT SINGLE MANDT INTO SY-MANDT
    FROM KNB1
   WHERE KUNNR = PS_0100-KUNNR
     AND BUKRS = PS_0100-BUKRS.
  IF SY-SUBRC EQ 0.
    LS_COMPANY-TASK = GC_U.
  ELSE.
    LS_COMPANY-TASK = GC_I.
  ENDIF.

  LS_COMPANY-DATA_KEY = PS_0100-BUKRS.

  "조정계정
  LS_COMPANY-DATA-AKONT = PS_0100-AKONT.
  LS_COMPANY-DATAX-AKONT = ABAP_TRUE.

  APPEND LS_COMPANY TO GS_DATA-CUSTOMER-COMPANY_DATA-COMPANY .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RETURN_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_RETURN_MAP_TYPE
*&      --> LS_RETURN_MAP_ID
*&      --> LS_RETURN_MAP_NUMBER
*&      --> LS_RETURN_MAP_MESSAGE_V1
*&      --> LS_RETURN_MAP_MESSAGE_V2
*&      --> LS_RETURN_MAP_MESSAGE_V3
*&      --> LS_RETURN_MAP_MESSAGE_V4
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM SET_RETURN_MESSAGE  USING    PV_TYPE
                                  PV_ID
                                  PV_NUMBER
                                  PV_MESSAGE_V1
                                  PV_MESSAGE_V2
                                  PV_MESSAGE_V3
                                  PV_MESSAGE_V4
                         CHANGING PV_MSG.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = PV_ID "SY-MSGID
      MSGNR               = PV_NUMBER "SY-MSGNO
      MSGV1               = PV_MESSAGE_V1 "SY-MSGV1
      MSGV2               = PV_MESSAGE_V2 "SY-MSGV3
      MSGV3               = PV_MESSAGE_V3
      MSGV4               = PV_MESSAGE_V4 "SY-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = PV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BP_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM GET_BP_NUMBER  CHANGING PS_0100 LIKE GT_0100.

  DO 5 TIMES.
    SELECT SINGLE B~PARTNER
      FROM CVI_CUST_LINK AS A INNER JOIN BUT000 AS B
                              ON A~PARTNER_GUID = B~PARTNER_GUID
     WHERE A~CUSTOMER EQ @PS_0100-KUNNR
      INTO @DATA(LV_PARTNER).
    IF SY-SUBRC EQ 0.
      PS_0100-PARTNER_CU = LV_PARTNER.
      EXIT.
    ELSE.
      WAIT UP TO '0.5' SECONDS.
      CONTINUE.
    ENDIF.

  ENDDO.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RISK_CLASS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM SET_RISK_CLASS  USING  PS_0100 LIKE GT_0100.
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

  LV_PARTNER = PS_0100-PARTNER_CU.

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

      PS_0100-RSLT = GC_E.
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
        IF PS_0100-MESSAGE IS NOT INITIAL.
          PS_0100-MESSAGE = |{ PS_0100-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_0100-MESSAGE = LV_MSG.
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
    PS_0100-RSLT = GC_E.
    DATA(LS_MSG) = VALUE #( LS_BUPA_ERROR-MESSAGES[ TYPE = GC_E
                                                    ID = 'MC'
                                                    NUMBER = '601' ] OPTIONAL ).
    IF LS_MSG IS NOT INITIAL.
      PS_0100-MESSAGE = LS_MSG-MESSAGE.
    ELSE.
      LOOP AT LS_BUPA_ERROR-MESSAGES INTO LS_MSG WHERE TYPE EQ GC_E.
        IF PS_0100-MESSAGE IS INITIAL.
          PS_0100-MESSAGE = LS_MSG-MESSAGE.
        ELSE.
          PS_0100-MESSAGE = |{ PS_0100-MESSAGE }/{ LS_MSG-MESSAGE }|.
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
    LS_UKM_S_BP_CMS-RISK_CLASS = PS_0100-RISK_CLASS.

  ELSE.
    IF LS_UKM_S_BP_CMS-RISK_CLASS NE PS_0100-RISK_CLASS.
      LV_CMS_CHK = GC_X.

      LS_UKM_S_BP_CMS-RISK_CLASS = PS_0100-RISK_CLASS.
    ENDIF.

  ENDIF.

  CHECK LV_CMS_CHK = GC_X.

  IO_PARTNER->SET_BP_CMS( LS_UKM_S_BP_CMS ).

  CALL METHOD IO_BUPA_FACTORY->SAVE_ALL
    EXPORTING
      I_UPD_TASK = ABAP_FALSE
*     I_FREE_ALL = NO
*     I_WITH_EXTERNAL_SCORINGS = NO
*     I_WITH_ADD_INFOS = ABAP_TRUE
*     I_WITH_VECTORS   = NO
*     I_WITH_ENQUEUE   = NO
*     I_FROM_HCP = NO
*     I_TESTRUN  = NO
    RECEIVING
      ET_RETURN  = LT_RETURN
    EXCEPTIONS
      FAILED     = 1
      OTHERS     = 2.
  IF LINE_EXISTS( LT_RETURN[ MSGTY = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    PS_0100-RSLT = GC_E.
    LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE MSGTY EQ GC_E.
      IF PS_0100-MESSAGE IS NOT INITIAL.
        PS_0100-MESSAGE = |{ PS_0100-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ELSE.
        PS_0100-MESSAGE = LS_RETURN-MESSAGE.
      ENDIF.
    ENDLOOP.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    PS_0100-RSLT   = GC_S.

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
*& Form UPDATE_ADRC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_0100
*&---------------------------------------------------------------------*
FORM UPDATE_ADRC  USING    PS_0100 LIKE GT_0100.
  DATA:LV_CHK(1).
  CHECK PS_0100-RSLT EQ GC_S AND PS_0100-PARTNER_CU IS NOT INITIAL.
  CHECK PS_0100-EXTENSION1 IS NOT INITIAL.

  SELECT SINGLE ADRNR
    INTO @DATA(LV_ADRNR)
    FROM KNA1
   WHERE KUNNR = @PS_0100-KUNNR.

  SELECT SINGLE ADDRNUMBER
    INTO @DATA(LV_ADDRNUMBER)
    FROM BUT020
   WHERE PARTNER = @PS_0100-PARTNER_CU.

  IF LV_ADRNR IS NOT INITIAL.
    LV_CHK = GC_X.
    UPDATE ADRC SET EXTENSION1 = PS_0100-EXTENSION1
              WHERE ADDRNUMBER = LV_ADRNR.
  ENDIF.
  IF LV_ADDRNUMBER IS NOT INITIAL.
    LV_CHK = GC_X.
    UPDATE ADRC SET EXTENSION1 = PS_0100-EXTENSION1
              WHERE ADDRNUMBER = LV_ADDRNUMBER.
  ENDIF.

  IF LV_CHK EQ GC_X.
    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR_LINE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM SET_COLOR_LINE_0100  CHANGING PS_0100 LIKE GT_0100.
  CLEAR:PS_0100-COLOR[].
  PERFORM ALV_FIELD_COLOR_SET   USING 'LIFNR'
                                      '1'  '0'  '3'
                             CHANGING PS_0100-COLOR.
  PERFORM ALV_FIELD_COLOR_SET   USING 'KUNNR'
                                      '1'  '0'  '3'
                             CHANGING PS_0100-COLOR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_FIELD_COLOR_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      <-- PS_0100_COLOR
*&---------------------------------------------------------------------*
FORM ALV_FIELD_COLOR_SET  USING    PI_FNAME
                                   PI_INT
                                   PI_INV
                                   PI_COL
                          CHANGING PT_COLOR   TYPE LVC_T_SCOL.

**
  APPEND VALUE #( FNAME       = PI_FNAME
                  COLOR-INT   = PI_INT
                  COLOR-INV   = PI_INV
                  COLOR-COL   = PI_COL ) TO PT_COLOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_0200 .

*-01. 공급업체
  SELECT A~LIFNR,B~BUKRS,
         D~PARTNER,
         F~NAME1
    FROM LFA1 AS A INNER JOIN CVI_VEND_LINK AS C
                   ON A~LIFNR = C~VENDOR
                   INNER JOIN BUT000 AS D
                   ON C~PARTNER_GUID = D~PARTNER_GUID
                   INNER JOIN LFB1 AS B
                   ON A~LIFNR = B~LIFNR

                   LEFT OUTER JOIN BUT020 AS E
                   ON D~PARTNER = E~PARTNER
                   LEFT OUTER JOIN ADRC AS F
                   ON E~ADDRNUMBER = F~ADDRNUMBER AND
                      F~DATE_FROM <= @SY-DATLO     AND
                      F~NATION     = @SPACE
   WHERE A~KTOKK IN @S_KTOKK
     AND B~BUKRS IN @S_BUKRS
    INTO TABLE @DATA(LT_LFA1).
  SORT LT_LFA1 BY LIFNR.

  CHECK LT_LFA1[] IS NOT INITIAL.

*-02. 고객코드(영업뷰)
  DATA(LT_TEMP) = LT_LFA1[].
  SORT LT_TEMP BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING LIFNR.

  SELECT *
    FROM KNVV
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE KUNNR EQ @LT_TEMP-LIFNR
     AND VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
     AND SPART IN @S_SPART
    INTO TABLE @DATA(LT_KNVV).
  SORT LT_KNVV BY KUNNR VKORG VTWEG SPART.

*-03. 고객코드

  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,A~BUKRS,
           C~PARTNER
      FROM KNB1 AS A INNER JOIN CVI_CUST_LINK AS B
                     ON A~KUNNR = B~CUSTOMER
                     INNER JOIN BUT000 AS C
                     ON B~PARTNER_GUID = C~PARTNER_GUID
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE KUNNR EQ @LT_TEMP-LIFNR
       AND BUKRS IN @S_BUKRS
      INTO TABLE @DATA(LT_KNB1).
    SORT LT_KNB1 BY KUNNR.
  ENDIF.


*-04. 리스트 구성
  LOOP AT LT_LFA1 INTO DATA(LS_LFA1).
    LOOP AT GT_TVTA INTO DATA(LS_TVTA).
      CLEAR:GS_0200.
      GS_0200-LIFNR = LS_LFA1-LIFNR.
      GS_0200-RLTYP = GC_RLTYP_FLCU01.
      GS_0200-VKORG = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
      GS_0200-VTWEG = VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ).
      GS_0200-SPART = LS_TVTA-SPART.
      GS_0200-KUNNR = LS_LFA1-LIFNR.
      GS_0200-BUKRS = VALUE #( S_BUKRS[ 1 ]-LOW OPTIONAL ).

      "KNVV 존재여부
      IF NOT LINE_EXISTS( LT_KNVV[ KUNNR = GS_0200-KUNNR
                                   VKORG = GS_0200-VKORG
                                   VTWEG = GS_0200-VTWEG
                                   SPART = GS_0200-SPART ] ).
        "KNB1 존재여부
        DATA(LS_KNB1) = VALUE #( LT_KNB1[ KUNNR = GS_0200-KUNNR
                                          BUKRS = GS_0200-BUKRS ] OPTIONAL ).
        IF LS_KNB1 IS NOT INITIAL.
          GS_0200-KALKS = GC_Z.
          GS_0200-BOKRE = GC_X.
          GS_0200-PRFRE = GC_X.
          GS_0200-NAME1 = LS_LFA1-NAME1.

          "LED
          PERFORM SET_LED_0200 CHANGING GS_0200.

          APPEND GS_0200 TO GT_0200.
        ENDIF.
      ENDIF.
      CLEAR:LS_KNB1.
    ENDLOOP.
  ENDLOOP.

  FREE:LT_LFA1,LT_TEMP,LT_KNVV,LT_KNB1,LS_KNB1,LS_TVTA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TVTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TVTA .
  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
     AND SPART IN @S_SPART
    INTO CORRESPONDING FIELDS OF TABLE @GT_TVTA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0200>
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_0200  CHANGING PS_0200 LIKE GT_0200.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : WA_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_0200-CELLTAB[].

  LOOP AT GT_FIELDCAT INTO DATA(LS_FCAT).
    CLEAR:WA_CELLTAB.
    WA_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'SEL'.
        IF PS_0200-RSLT EQ GC_S.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.

      WHEN OTHERS.
        WA_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT WA_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_0200-CELLTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0200>
*&---------------------------------------------------------------------*
FORM SET_COLOR_LINE_0200  CHANGING PS_0200 LIKE GT_0200.
  CLEAR:PS_0200-COLOR[].
  PERFORM ALV_FIELD_COLOR_SET   USING 'LIFNR'
                                      '1'  '0'  '3'
                             CHANGING PS_0200-COLOR.
  PERFORM ALV_FIELD_COLOR_SET   USING 'KUNNR'
                                      '1'  '0'  '3'
                             CHANGING PS_0200-COLOR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_0200
*&---------------------------------------------------------------------*
FORM SET_LED_0200  CHANGING PS_0200 LIKE GT_0200.
  CASE PS_0200-RSLT.
    WHEN GC_S.
      PS_0200-STAT = ICON_LED_GREEN.
    WHEN GC_E.
      PS_0200-STAT = ICON_LED_RED.
    WHEN OTHERS.
      PS_0200-STAT = ICON_LED_YELLOW.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PARTNERFUNC_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PARTNERFUNC_0200 .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_LIST_PRCESS_0200.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-02. BP 유지보수
  PERFORM MAINTAIN_BP_PART_PROC_0200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LIST_PRCESS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LIST_PRCESS_0200 .
  DATA:LV_CHK(1).

*-01. 선택
  IF NOT LINE_EXISTS( GT_0200[ SEL = GC_X ] ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02.
  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WHERE SEL  EQ GC_X
                                                      AND RSLT NE GC_S.
    CLEAR:<FS_0200>-NEW.

    SELECT SINGLE KUNNR,VKORG,VTWEG,SPART
      FROM KNVV
     WHERE KUNNR EQ @<FS_0200>-KUNNR
       AND VKORG EQ @<FS_0200>-VKORG
       AND VTWEG EQ @<FS_0200>-VTWEG
       AND SPART EQ @<FS_0200>-SPART
      INTO @DATA(LS_KNVV).

    IF SY-SUBRC NE 0.
      LV_CHK        = GC_X.
      <FS_0200>-NEW = GC_X.
    ENDIF.
  ENDLOOP.

  IF LV_CHK IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-E01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  FREE:LS_KNVV.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PART_PROC_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PART_PROC_0200 .
  DATA: LS_RESULT TYPE BAPIRET2.
  DATA: LV_MSG1(50),
        LV_MSG2(50).


  CLEAR GV_ERROR.
  CLEAR GT_ZGTSDT9040[].

  LOOP AT GT_0200 INTO DATA(LS_0200) WHERE SEL  EQ GC_X
                                       AND RSLT NE GC_S
                                     GROUP BY ( KUNNR = LS_0200-KUNNR
                                                VKORG = LS_0200-VKORG )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).
    CLEAR: GS_0200,LS_RESULT.
    CLEAR:GT_DATA[], GS_DATA.
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      MOVE-CORRESPONDING <FS_LINE> TO GS_0200.
      EXIT.
    ENDLOOP.

    "SET BP PARTNER
    PERFORM SET_PARTNER_HEADER USING GS_0200.

    "BP ROLE
    PERFORM SET_BP_ROLE_0200   USING GS_0200.

    "영업데이터 헤더
    GS_DATA-CUSTOMER-HEADER-OBJECT_TASK           = GC_U.
    GS_DATA-CUSTOMER-HEADER-OBJECT_INSTANCE-KUNNR = GS_0200-KUNNR.

    "영업데이터
    LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
      CLEAR GS_0200.
      MOVE-CORRESPONDING <FS_LINE> TO GS_0200.
      PERFORM SET_BP_SALES_0200 USING GS_0200.
    ENDLOOP.

    "VALIDATION
    PERFORM BP_MAINTAIN_VALIDATION CHANGING LS_RESULT.

    IF LS_RESULT-TYPE NE GC_E.
      "저장
      PERFORM BP_MAINTAIN_SAVE CHANGING LS_RESULT.

    ENDIF.

    "결과
    LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
      <FS_LINE>-RSLT    = LS_RESULT-TYPE.
      <FS_LINE>-MESSAGE = LS_RESULT-MESSAGE.

      "LED
      PERFORM SET_LED_0200 CHANGING <FS_LINE>.
      PERFORM SET_ATTRIBUTES_LINE_0200 CHANGING <FS_LINE>.

      CLEAR <FS_LINE>-SEL.

      IF <FS_LINE>-RSLT EQ GC_E.
        GV_ERROR = GC_X.
      ENDIF.
      APPEND VALUE #( ZGUID   = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                      KUNNR   = <FS_LINE>-KUNNR
                      BUKRS   = <FS_LINE>-BUKRS
                      VKORG   = <FS_LINE>-VKORG
                      VTWEG   = <FS_LINE>-VTWEG
                      SPART   = <FS_LINE>-SPART
                      TYPE    = <FS_LINE>-RSLT
                      MESSAGE = <FS_LINE>-MESSAGE
                  ) TO GT_ZGTSDT9040.
    ENDLOOP.
  ENDLOOP.

  IF SY-BATCH IS NOT INITIAL.
    "LOG
    IF GT_ZGTSDT9040[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9040[] ).
      MODIFY ZGTSDT9040 FROM TABLE GT_ZGTSDT9040.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9040[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |[{ LV_MSG1 }/{ LV_MSG2 }]|.

      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_R01. "일반/회계뷰
          LV_MSG2 = TEXT-005.
        WHEN P_R02. "영업뷰
          LV_MSG2 = TEXT-006.
      ENDCASE.
      LV_MSG2 = LV_MSG2 && TEXT-007.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-008 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.

  ELSE.
    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    ELSE.
      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_R01. "일반/회계뷰
          LV_MSG2 = TEXT-005.
        WHEN P_R02. "영업뷰
          LV_MSG2 = TEXT-006.
      ENDCASE.
      LV_MSG2 = LV_MSG2 && TEXT-007.
      MESSAGE I000 WITH LV_MSG2 DISPLAY LIKE GC_S.
    ENDIF.
    PERFORM REFRESH_ALV USING GO_GRID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PARTNER_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_0200
*&---------------------------------------------------------------------*
FORM SET_PARTNER_HEADER  USING    PS_0200 LIKE GT_0200.
  DATA: LV_TASK   TYPE BUS_EI_OBJECT_TASK.

  SELECT SINGLE A~CUSTOMER,B~PARTNER,B~PARTNER_GUID
    FROM CVI_CUST_LINK AS A INNER JOIN BUT000 AS B
                            ON A~PARTNER_GUID = B~PARTNER_GUID
   WHERE A~CUSTOMER EQ @PS_0200-KUNNR
    INTO @DATA(LS_BUT000).
  IF SY-SUBRC EQ 0.
    LV_TASK = GC_U.
  ELSE.
    LV_TASK = GC_I.

    LS_BUT000-PARTNER_GUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( ).
  ENDIF.

  GS_DATA-PARTNER-HEADER-OBJECT_TASK                  = LV_TASK.
  GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNERGUID = LS_BUT000-PARTNER_GUID.


  CASE LV_TASK.
    WHEN GC_I.

      GS_DATA-ENSURE_CREATE-CREATE_CUSTOMER               = ABAP_TRUE.

    WHEN GC_U.
      GS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER     = LS_BUT000-PARTNER .

      PS_0200-PARTNER_CU = LS_BUT000-PARTNER .

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_ROLE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_0200
*&---------------------------------------------------------------------*
FORM SET_BP_ROLE_0200  USING    PS_0200 LIKE GT_0200.

  DATA: LT_ROLES TYPE BUS_EI_BUPA_ROLES_T.

  IF PS_0200-PARTNER_CU IS NOT INITIAL.
    SELECT *
      INTO TABLE @DATA(LT_BUT100)
      FROM BUT100
     WHERE PARTNER EQ @PS_0200-PARTNER_CU.
  ENDIF.

  IF NOT ( LINE_EXISTS( LT_BUT100[ PARTNER = PS_0200-PARTNER_CU
                                   RLTYP   = PS_0200-RLTYP ] ) ).
    APPEND VALUE #( TASK            = GC_I
                    DATA_KEY        = PS_0200-RLTYP
*                    DATA-VALID_FROM = SY-DATLO
                    DATA-VALID_TO   = '99991231'
*                    DATAX-VALID_FROM = ABAP_TRUE
                    DATAX-VALID_TO   = ABAP_TRUE
                  ) TO LT_ROLES.
  ENDIF.

  IF LT_ROLES[] IS NOT INITIAL.
    GS_DATA-PARTNER-CENTRAL_DATA-ROLE-ROLES[] = CORRESPONDING #( LT_ROLES[] ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_SALES_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_0200
*&---------------------------------------------------------------------*
FORM SET_BP_SALES_0200  USING    PS_0200 LIKE GT_0200.
  DATA: LS_SALES     TYPE CMDS_EI_SALES.

  SELECT SINGLE MANDT INTO SY-MANDT
    FROM KNVV
   WHERE KUNNR = PS_0200-KUNNR
     AND VKORG = PS_0200-VKORG
     AND VTWEG = PS_0200-VTWEG
     AND SPART = PS_0200-SPART.
  IF SY-SUBRC = 0.
    LS_SALES-TASK = GC_U.
  ELSE.
    LS_SALES-TASK = GC_I.
  ENDIF.

  "KEY값 설정
  LS_SALES-DATA_KEY-VKORG = PS_0200-VKORG.
  LS_SALES-DATA_KEY-VTWEG = PS_0200-VTWEG.
  LS_SALES-DATA_KEY-SPART = PS_0200-SPART.

  "고객가격결정절차
  LS_SALES-DATA-KALKS  = PS_0200-KALKS.
  LS_SALES-DATAX-KALKS = ABAP_TRUE.

  "리베이트
  LS_SALES-DATA-BOKRE  = PS_0200-BOKRE.
  LS_SALES-DATAX-BOKRE = ABAP_TRUE.

  "가격결정
  LS_SALES-DATA-PRFRE  = PS_0200-PRFRE.
  LS_SALES-DATAX-PRFRE = ABAP_TRUE.

  APPEND LS_SALES TO GS_DATA-CUSTOMER-SALES_DATA-SALES.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_MAINTAIN_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM BP_MAINTAIN_VALIDATION  CHANGING PS_RESULT TYPE BAPIRET2.
  DATA: LT_RETURN_MAP TYPE MDG_BS_BP_MSGMAP_T.
  DATA: LV_MSG(200).

  CALL METHOD CL_MD_BP_MAINTAIN=>VALIDATE_SINGLE
    EXPORTING
      I_DATA        = GS_DATA
    IMPORTING
      ET_RETURN_MAP = LT_RETURN_MAP.

  IF LT_RETURN_MAP[] IS NOT INITIAL.
    PS_RESULT-TYPE    = GC_E.

    LOOP AT LT_RETURN_MAP INTO DATA(LS_RETURN_MAP) WHERE TYPE CA 'AE'.
      CLEAR:LV_MSG.
      PERFORM SET_RETURN_MESSAGE USING LS_RETURN_MAP-TYPE
                                       LS_RETURN_MAP-ID
                                       LS_RETURN_MAP-NUMBER
                                       LS_RETURN_MAP-MESSAGE_V1
                                       LS_RETURN_MAP-MESSAGE_V2
                                       LS_RETURN_MAP-MESSAGE_V3
                                       LS_RETURN_MAP-MESSAGE_V4
                                 CHANGING LV_MSG.
      IF PS_RESULT-MESSAGE IS NOT INITIAL.
        PS_RESULT-MESSAGE = |{ PS_RESULT-MESSAGE }/{ LV_MSG }|.
      ELSE.
        PS_RESULT-MESSAGE = LV_MSG.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_MAINTAIN_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM BP_MAINTAIN_SAVE  CHANGING PS_RESULT TYPE BAPIRET2.
  DATA: LT_RETURN     TYPE BAPIRETM.
  DATA: LV_MSG(200).

  APPEND GS_DATA TO GT_DATA.

  CALL METHOD CL_MD_BP_MAINTAIN=>MAINTAIN
    EXPORTING
      I_DATA   = GT_DATA
    IMPORTING
      E_RETURN = LT_RETURN.
  LOOP AT LT_RETURN INTO DATA(LS_RETURN).
    LOOP AT LS_RETURN-OBJECT_MSG INTO DATA(LS_MSG) WHERE TYPE CA 'AE'.
      EXIT.
    ENDLOOP.
  ENDLOOP.

  IF LS_MSG IS INITIAL.
    __BAPI_TRANSACTION_COMMIT.

    PS_RESULT-TYPE    = GC_S.


  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_RESULT-TYPE    = GC_E.

    LOOP AT LT_RETURN INTO LS_RETURN.
      LOOP AT LS_RETURN-OBJECT_MSG INTO LS_MSG WHERE TYPE CA 'AE'.
        CLEAR:LV_MSG.
        PERFORM SET_RETURN_MESSAGE USING LS_MSG-TYPE
                                         LS_MSG-ID
                                         LS_MSG-NUMBER
                                         LS_MSG-MESSAGE_V1
                                         LS_MSG-MESSAGE_V2
                                         LS_MSG-MESSAGE_V3
                                         LS_MSG-MESSAGE_V4
                                   CHANGING LV_MSG.
        IF PS_RESULT-MESSAGE IS NOT INITIAL.
          PS_RESULT-MESSAGE = |{ PS_RESULT-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_RESULT-MESSAGE = LV_MSG.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BACKGROUND_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_A
*&---------------------------------------------------------------------*
FORM BACKGROUND_PROCESS  USING    PV_STEP.

  CASE PV_STEP.
    WHEN GC_A. "일반/회계뷰
      PERFORM BP_MAINTAIN_BACK_0100.
    WHEN GC_B. "영업뷰
      PERFORM BP_MAINTAIN_BACK_0200.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_MAINTAIN_BACK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BP_MAINTAIN_BACK_0100 .
  MODIFY GT_0100 FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                WHERE SEL NE GC_X.

  PERFORM MAINTAIN_BP_PART_PROC_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_MAINTAIN_BACK_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BP_MAINTAIN_BACK_0200 .
  MODIFY GT_0200 FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                WHERE SEL NE GC_X.

  PERFORM MAINTAIN_BP_PART_PROC_0200.
ENDFORM.
