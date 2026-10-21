*&---------------------------------------------------------------------*
*& Include          ZGTSDR1270F01
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

*-유통경로
  S_VTWEG[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_VTWEG_10 ) ).

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
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING  PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
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
*& Form F4_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_KUNN2_LOW
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KUNNR  USING    PV_FVAL PV_FNAME.
  DATA: LV_MC_OBJ LIKE HELP_INFO-MCOBJ.
  DATA: LT_RETURN_VALUES LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA: LV_DISPLAY TYPE C.
  DATA: LV_VKORG TYPE VBAK-VKORG,
        LV_VTWEG TYPE VBAK-VTWEG.

*   Matchcodeobjekt aufrufen
  LV_MC_OBJ = 'SD_DEBI'.
  LV_VKORG  = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
  LV_VTWEG  = VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ).
  SET PARAMETER ID 'VKO' FIELD LV_VKORG.
  SET PARAMETER ID 'VTU' FIELD LV_VTWEG.
  SET PARAMETER ID 'SPA' FIELD SPACE.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = SPACE
      FIELDNAME         = SPACE
      SEARCHHELP        = LV_MC_OBJ
*     SHLPPARAM         = ' '
*     DYNPPROG          = ' '
*     DYNPNR            = ' '
      DYNPROFIELD       = 'X'
*     STEPL             = 0
      VALUE             = PV_FNAME
*     MULTIPLE_CHOICE   = ' '
      DISPLAY           = LV_DISPLAY
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
    TABLES
      RETURN_TAB        = LT_RETURN_VALUES
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  IF SY-SUBRC = 0.
    PV_FVAL = VALUE #( LT_RETURN_VALUES[ 1 ]-FIELDVAL OPTIONAL ).
  ENDIF.

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

  CASE GC_X.
    WHEN P_R01. "신규지정
      CLEAR:GT_EXCLU[].
    WHEN P_R02. "조회
      APPEND VALUE #( FCODE = 'ZSAV' ) TO GT_EXCLU.
  ENDCASE.
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
         GV_TITLE,GV_EDIT,GV_BATCH.

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
*-조회시 BATCH JOB수행 에러
  IF P_R02 IS NOT INITIAL AND
     SY-BATCH IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-E03.
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

  CASE GC_X.
    WHEN P_R01. "신규지정
      GV_TITLE = |{ TEXT-003 }{ TEXT-004 }|.

      GV_EDIT  = 'X'.

    WHEN P_R02. "조회
      GV_TITLE = |{ TEXT-003 }{ TEXT-005 }|.

      CLEAR GV_EDIT.
  ENDCASE.

  IF SY-BATCH IS NOT INITIAL.
    GV_BATCH = GC_X.
  ENDIF.

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
  SELECT A~VKORG,A~VTWEG,A~SPART,
         A~KUNNR   AS KUNN2,
         A~KUNNR,
         D~PARTNER AS KUNN2_BP,
         F~NAME1   AS KUNN2_TX
    FROM KNVV AS A INNER JOIN KNA1 AS B
                   ON A~KUNNR = B~KUNNR
                   INNER JOIN CVI_CUST_LINK AS C
                   ON B~KUNNR = C~CUSTOMER
                   INNER JOIN BUT000 AS D
                   ON C~PARTNER_GUID = D~PARTNER_GUID
                   INNER JOIN BUT020 AS E
                   ON D~PARTNER = E~PARTNER
                   INNER JOIN ADRC AS F
                   ON E~ADDRNUMBER = F~ADDRNUMBER AND
                      F~DATE_FROM  <= @SY-DATLO   AND
                      F~NATION     = @SPACE
   WHERE A~VKORG IN @S_VKORG
     AND A~VTWEG IN @S_VTWEG
     AND A~SPART IN @S_SPART
     AND A~KUNNR IN @S_KUNN2
     AND B~KTOKD EQ @GC_KTOKD_0003     "로컬지급처
    INTO TABLE @DATA(LT_KUNN2).
  SORT LT_KUNN2 BY VKORG VTWEG SPART KUNN2.
  DELETE ADJACENT DUPLICATES FROM LT_KUNN2 COMPARING VKORG VTWEG SPART KUNN2.

*-02. 로컬지급처 => 내수고객 코드변경
  LOOP AT LT_KUNN2 ASSIGNING FIELD-SYMBOL(<FS_KUNN2>).
    <FS_KUNN2>-KUNNR = |{ <FS_KUNN2>-KUNNR ALPHA = OUT }|.
    <FS_KUNN2>-KUNNR+0(1) = '1'.
    <FS_KUNN2>-KUNNR = |{ <FS_KUNN2>-KUNNR ALPHA = IN }|.
  ENDLOOP.


*-03. 내수고객
  IF LT_KUNN2[] IS NOT INITIAL.
    SELECT B~VKORG,B~VTWEG,B~SPART,
           B~KUNNR,
           E~PARTNER AS KUNNR_BP, E~PARTNER_GUID AS KUNNR_BP_GUID,
           G~NAME1   AS KUNNR_TX
      FROM @LT_KUNN2     AS A INNER JOIN KNVV AS B
                              ON A~VKORG = B~VKORG AND
                                 A~VTWEG = B~VTWEG AND
                                 A~SPART = B~SPART AND
                                 A~KUNNR = B~KUNNR
                              INNER JOIN KNA1 AS C
                              ON B~KUNNR = C~KUNNR AND
                                 C~KTOKD = @GC_KTOKD_0001       "국내 내수고객
                              INNER JOIN CVI_CUST_LINK AS D
                              ON C~KUNNR = D~CUSTOMER
                              INNER JOIN BUT000 AS E
                              ON D~PARTNER_GUID = E~PARTNER_GUID
                              INNER JOIN BUT020 AS F
                              ON E~PARTNER = F~PARTNER
                              INNER JOIN ADRC AS G
                              ON F~ADDRNUMBER = G~ADDRNUMBER AND
                                 G~DATE_FROM  <= @SY-DATLO   AND
                                 G~NATION     = @SPACE
     WHERE B~KUNNR IN @S_KUNNR
      INTO TABLE @DATA(LT_KUNNR).

  ENDIF.

*-04. 리스트 구성
  LOOP AT LT_KUNN2 INTO DATA(LS_KUNN2).
    CLEAR GS_LIST.
    DATA(LS_KUNNR) = VALUE #( LT_KUNNR[ VKORG = LS_KUNN2-VKORG
                                        VTWEG = LS_KUNN2-VTWEG
                                        SPART = LS_KUNN2-SPART
                                        KUNNR = LS_KUNN2-KUNNR ] OPTIONAL ).
    IF LS_KUNNR IS NOT INITIAL.

      GS_LIST-VKORG     = LS_KUNN2-VKORG.
      GS_LIST-VTWEG     = LS_KUNN2-VTWEG.
      GS_LIST-SPART     = LS_KUNN2-SPART.
      "로컬지급처
      GS_LIST-KUNN2     = LS_KUNN2-KUNN2.
      GS_LIST-KUNN2_BP  = LS_KUNN2-KUNN2_BP.
      GS_LIST-KUNN2_TX  = LS_KUNN2-KUNN2_TX.
      "국내 내수고객
      GS_LIST-KUNNR     = LS_KUNNR-KUNNR.
      GS_LIST-KUNNR_BP  = LS_KUNNR-KUNNR_BP.
      GS_LIST-KUNNR_BP_GUID = LS_KUNNR-KUNNR_BP_GUID. "내수고객 BP GUID
      GS_LIST-KUNNR_TX  = LS_KUNNR-KUNNR_TX.
      APPEND GS_LIST TO GT_LIST.
    ENDIF.

    CLEAR LS_KUNNR.
  ENDLOOP.

  SORT GT_LIST BY VKORG VTWEG SPART KUNN2 KUNNR.

  FREE: LT_KUNN2,LT_KUNNR,LS_KUNN2,LS_KUNNR.
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

  CHECK GT_LIST[] IS NOT INITIAL.

*-01. KNVP(내수고잭에 ASSIGN된 로컬지급처
  DATA(LT_TEMP) = GT_LIST[].

  SELECT B~VKORG,B~VTWEG,B~SPART,
         B~KUNNR,B~KUNN2
    FROM @LT_TEMP AS A INNER JOIN KNVP AS B
                       ON A~VKORG = B~VKORG AND
                          A~VTWEG = B~VTWEG AND
                          A~SPART = B~SPART AND
                          A~KUNNR = B~KUNNR AND
                          A~KUNN2 = B~KUNN2 AND
                          B~PARVW = @GC_PARVW_RG
    INTO TABLE @DATA(LT_KNVP).

*-02. KNVP 유지보수 여부
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    IF LINE_EXISTS( LT_KNVP[ VKORG = <FS_LIST>-VKORG VTWEG = <FS_LIST>-VTWEG
                             SPART = <FS_LIST>-SPART
                             KUNNR = <FS_LIST>-KUNNR KUNN2 = <FS_LIST>-KUNN2 ] ).
      <FS_LIST>-ZFLAG = GC_Y.  "로컬지급처 지정
    ELSE.
      <FS_LIST>-ZFLAG = GC_N.  "로컬지급처 미지정
    ENDIF.

    PERFORM SET_LED CHANGING <FS_LIST>.

  ENDLOOP.

*-03. 선택조건 신규/조회 적용
  CASE GC_X.
    WHEN P_R01. "신규지정
      "로컬지급처 지정된건 제외
      DELETE GT_LIST WHERE ZFLAG EQ GC_Y.
    WHEN P_R02. "조회
      "로컬지급처 미지정된건 제외
      DELETE GT_LIST WHERE ZFLAG EQ GC_N.
  ENDCASE.


  FREE:LT_KNVP.
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
    CASE GC_X.
      WHEN P_R01.
        IF GV_BATCH IS INITIAL.
          CALL SCREEN 0100.
        ELSE.
          PERFORM BATCH_PROCESS.
        ENDIF.
      WHEN P_R02.
        CALL SCREEN 0100.
    ENDCASE.

  ELSE.
    MESSAGE S018.
  ENDIF.


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
  MODIFY GT_LIST FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                WHERE SEL   NE GC_X
                  AND ZFLAG NE GC_Y.

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
  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PARTNERFUNC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PARTNERFUNC .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_LIST_PRCESS.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 판매처에 로컬지급처 지정
  PERFORM MAINTAIN_BP_PARTNERFUNC_PROC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LIST_PRCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LIST_PRCESS .
  DATA:LV_CHK(1).

*-01. 리스트 선택
  IF NOT ( LINE_EXISTS( GT_LIST[ SEL = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02.
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL EQ GC_X.
    SELECT SINGLE KUNNR
      FROM KNVP
     WHERE VKORG EQ @<FS_LIST>-VKORG
       AND VTWEG EQ @<FS_LIST>-VTWEG
       AND SPART EQ @<FS_LIST>-SPART
       AND KUNNR EQ @<FS_LIST>-KUNNR
       AND KUNN2 EQ @<FS_LIST>-KUNN2
       AND PARVW EQ @GC_PARVW_RG
      INTO @DATA(LV_KUNNR).
    IF SY-SUBRC EQ 0.
      <FS_LIST>-ZFLAG = GC_Y.
    ELSE.
      <FS_LIST>-ZFLAG = GC_N.
      LV_CHK = GC_X.

    ENDIF.
  ENDLOOP.
  IF LV_CHK IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-E01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_PARTNERFUNC_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_PARTNERFUNC_PROC .
  DATA: LT_DATA TYPE CVIS_EI_EXTERN_T,
        LS_DATA TYPE CVIS_EI_EXTERN.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA: LV_OK(1).

  CLEAR GV_ERROR.

  "국내 내수고객 BP 단위로 처리한다
  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL = GC_X
                                  GROUP BY ( VKORG = LS_LIST-VKORG
                                             KUNNR = LS_LIST-KUNNR
                                             KUNN2 = LS_LIST-KUNN2 )
                                  ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).
    CLEAR:LT_DATA[],LS_DATA,LS_RETURN,LV_OK.

    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      CLEAR:GS_LIST.
      CLEAR:<FS_LINE>-RSLT,<FS_LINE>-MESSAGE.
      MOVE-CORRESPONDING <FS_LINE> TO GS_LIST.

      PERFORM SET_BP_SALES_PARTFUNC    USING GS_LIST
                                    CHANGING LS_DATA
                                             LV_OK.
      IF LV_OK IS NOT INITIAL.
        <FS_LINE>-ZFLAG = GC_N.
      ELSE.
        <FS_LINE>-ZFLAG = GC_Y.
      ENDIF.
    ENDLOOP.
    IF LV_OK IS NOT INITIAL.
      LS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER     = <FS_LINE>-KUNNR_BP.
      LS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNERGUID = <FS_LINE>-KUNNR_BP_GUID.
      LS_DATA-PARTNER-HEADER-OBJECT_TASK                  = GC_U.

*      "CUSTOMER HEADER
*      LS_DATA-CUSTOMER-HEADER-OBJECT_INSTANCE-KUNNR   = <FS_LINE>-KUNNR.
*      LS_DATA-CUSTOMER-HEADER-OBJECT_TASK             = GC_U.
    ELSE.
      CONTINUE.
    ENDIF.

    PERFORM BP_MAINTAIN_VALIDATE_SINGLE     USING LS_DATA
                                         CHANGING LS_RETURN.

    IF LS_RETURN-TYPE NE GC_E.
      APPEND LS_DATA TO LT_DATA.

      CLEAR LS_RETURN.
      PERFORM CREATE_BP_MAINTAIN        USING  LT_DATA[]
                                      CHANGING LS_RETURN.
    ENDIF.

    "처리결과
    LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
      CHECK <FS_LINE>-ZFLAG EQ GC_N.
      CASE LS_RETURN-TYPE.
        WHEN GC_E.
          GV_ERROR = GC_X.
          <FS_LINE>-RSLT    = GC_E.
          <FS_LINE>-MESSAGE = LS_RETURN-MESSAGE.
        WHEN OTHERS.
          <FS_LINE>-RSLT    = GC_S.
          <FS_LINE>-ZFLAG   = GC_Y.

      ENDCASE.
      PERFORM SET_LED CHANGING <FS_LINE>.
      PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LINE>.
    ENDLOOP.


  ENDLOOP.

  IF GV_BATCH IS INITIAL.
    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-E02 DISPLAY LIKE GC_E.
    ELSE.
      MESSAGE I000 WITH TEXT-S01 DISPLAY LIKE GC_S.
    ENDIF.
  ELSE.
    IF GV_ERROR IS NOT INITIAL.
      DATA(LV_MSG) = |{ TEXT-007 } { TEXT-E02 }|.
      WRITE: LV_MSG.

    ELSE.
      LV_MSG = |{ TEXT-006 } { TEXT-S01 }|.
      WRITE: LV_MSG.

    ENDIF.
  ENDIF.

  IF GV_BATCH IS INITIAL.
    PERFORM REFRESH_ALV USING GO_GRID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BP_SALES_PARTFUNC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST
*&      <-- LS_DATA
*&      <-- LV_OK
*&---------------------------------------------------------------------*
FORM SET_BP_SALES_PARTFUNC  USING    PS_LIST LIKE GS_LIST
                            CHANGING PS_DATA TYPE CVIS_EI_EXTERN
                                     PV_OK.

  DATA: LS_SALES     TYPE CMDS_EI_SALES,
        LS_FUNCTIONS TYPE CMDS_EI_FUNCTIONS.

*-CHECK
  SELECT SINGLE KUNNR
    FROM KNVP
   WHERE VKORG EQ @PS_LIST-VKORG
     AND VTWEG EQ @PS_LIST-VTWEG
     AND SPART EQ @PS_LIST-SPART
     AND KUNNR EQ @PS_LIST-KUNNR
     AND KUNN2 EQ @PS_LIST-KUNN2
     AND PARVW EQ @GC_PARVW_RG
    INTO @DATA(LV_KUNNR).

  CHECK SY-SUBRC NE 0.

  PV_OK = GC_X.

*-01. SALES DATA
  LS_SALES-TASK           = GC_U.
  LS_SALES-DATA_KEY-VKORG = PS_LIST-VKORG.
  LS_SALES-DATA_KEY-VTWEG = PS_LIST-VTWEG.
  LS_SALES-DATA_KEY-SPART = PS_LIST-SPART.

*-02. Partner Function.
  CLEAR: LS_FUNCTIONS.

  LS_FUNCTIONS-TASK           = GC_I.
  LS_FUNCTIONS-DATA_KEY-PARVW = GC_PARVW_RG.

  LS_FUNCTIONS-DATA-PARTNER   = PS_LIST-KUNN2.
  LS_FUNCTIONS-DATAX-PARTNER  = GC_X.

  APPEND LS_FUNCTIONS TO LS_SALES-FUNCTIONS-FUNCTIONS.

  APPEND LS_SALES TO PS_DATA-CUSTOMER-SALES_DATA-SALES .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_MAINTAIN_VALIDATE_SINGLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA
*&      <-- LS_RETURN
*&---------------------------------------------------------------------*
FORM BP_MAINTAIN_VALIDATE_SINGLE  USING    PS_DATA TYPE CVIS_EI_EXTERN
                                  CHANGING PS_RETURN TYPE BAPIRET2.

  CL_MD_BP_MAINTAIN=>VALIDATE_SINGLE(
    EXPORTING
      I_DATA        = PS_DATA
    IMPORTING
      ET_RETURN_MAP = DATA(LT_RETURN) ).

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    PS_RETURN-TYPE = GC_E.
    LOOP AT LT_RETURN INTO LS_RETURN WHERE TYPE CA 'AE'.
      IF PS_RETURN-MESSAGE IS INITIAL.
        PS_RETURN-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        PS_RETURN-MESSAGE = |{ PS_RETURN-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_BP_MAINTAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DATA[]
*&      <-- LS_RETURN
*&---------------------------------------------------------------------*
FORM CREATE_BP_MAINTAIN  USING    PT_DATA TYPE CVIS_EI_EXTERN_T
                         CHANGING PS_RETURN TYPE BAPIRET2.

  DATA: LT_RETURN TYPE BAPIRETM,
        LT_MSG1   TYPE TABLE OF BDCMSGCOLL,
        LT_MSG2   TYPE TABLE OF BAPIRET2.

  CALL METHOD CL_MD_BP_MAINTAIN=>MAINTAIN
    EXPORTING
      I_DATA   = PT_DATA
    IMPORTING
      E_RETURN = LT_RETURN.

  LOOP AT LT_RETURN INTO DATA(LS_RETURN).
    MOVE-CORRESPONDING LS_RETURN-OBJECT_MSG TO LT_MSG2[] KEEPING TARGET LINES.
  ENDLOOP.

  LOOP AT LT_MSG2 INTO DATA(LS_MSG2) WHERE TYPE CA 'AE'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.
    PS_RETURN-TYPE = GC_E.
    LOOP AT LT_MSG2 INTO LS_MSG2 WHERE TYPE CA 'AE'.
      IF PS_RETURN-MESSAGE IS INITIAL.
        PS_RETURN-MESSAGE = LS_MSG2-MESSAGE.
      ELSE.
        PS_RETURN-MESSAGE = |{ PS_RETURN-MESSAGE }/{ LS_MSG2-MESSAGE }|.
      ENDIF.
    ENDLOOP.
  ELSE.
    __BAPI_TRANSACTION_COMMIT.
    PS_RETURN-TYPE = GC_S.
  ENDIF.

  FREE: LS_RETURN,LS_MSG2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GT_LIST.

  CASE PS_LIST-ZFLAG.
    WHEN GC_Y.   "내수고객에 로컬지급처 지정됨
      PS_LIST-STAT = ICON_LED_GREEN.
    WHEN GC_N.   "내수고객에 로컬지급처 미지정됨
      IF PS_LIST-RSLT EQ GC_E.
        PS_LIST-STAT = ICON_LED_RED.
      ELSE.
        PS_LIST-STAT = ICON_LED_YELLOW.
      ENDIF.
  ENDCASE.
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
         LS_LIST-KUNNR_BP IS NOT INITIAL.

        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-KUNNR_BP
                                      IV_ROLE    = GC_ROLE_FLCU01   ).
      ENDIF.

    WHEN 'KUNNR_BP'.
      IF LS_LIST-KUNNR_BP IS NOT INITIAL.
        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-KUNNR_BP
                                      IV_ROLE    = GC_ROLE_FLCU01   ).
      ENDIF.

    WHEN 'KUNN2'.
      IF LS_LIST-KUNN2   IS NOT INITIAL AND
         LS_LIST-KUNN2_BP IS NOT INITIAL.

        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-KUNN2_BP
                                      IV_ROLE    = GC_ROLE_FLCU01   ).
      ENDIF.

    WHEN 'KUNN2_BP'.
      IF LS_LIST-KUNN2_BP IS NOT INITIAL.
        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-KUNN2_BP
                                      IV_ROLE    = GC_ROLE_FLCU01   ).
      ENDIF.
  ENDCASE.

  FREE:LS_LIST.
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
  PERFORM MAIN .
  PERFORM CELL_ATTRIBUTES_0100.
  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BATCH_PROCESS .
  MODIFY GT_LIST FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                WHERE SEL = SPACE.

  PERFORM MAINTAIN_BP_PARTNERFUNC_PROC.
ENDFORM.
