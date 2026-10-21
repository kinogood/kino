*&---------------------------------------------------------------------*
*& Include          ZGTPPR4010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'P_WERKS' OR 'P_TBSTNK'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
      WHEN 'S_MTART-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      WHEN 'P_FJOBNM' OR 'P_TJOBNM' OR 'P_FBSTNK'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 = GC_X.
      IF P_R12 EQ GC_X.
        IF SCREEN-GROUP1 = 'S2' OR
           SCREEN-GROUP1 = 'S3' OR
           SCREEN-GROUP1 = 'S5'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSEIF P_R14 EQ GC_X.
        IF SCREEN-GROUP1 = 'S2' OR
           SCREEN-GROUP1 = 'S3' OR
           SCREEN-GROUP1 = 'S4'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF SCREEN-GROUP1 = 'S2' OR
           SCREEN-GROUP1 = 'S5'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'S1' OR
         SCREEN-GROUP1 = 'S5'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT  CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_LAYO = LS_VARIANT-VARIANT.
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

  PERFORM GET_ZTYPE.

  IF P_R1 EQ GC_X.            "이전전기처리
    IF P_R11 EQ GC_X OR       "판매오더간
       P_R13 EQ GC_X.         "판매오더->플랜트
      PERFORM GET_DATA_MOVE_AC.
    ELSEIF P_R12 EQ GC_X.     "플랜트->판매오더
      PERFORM GET_DATA_MOVE_B.
    ELSEIF P_R14 EQ GC_X.     "제번간 일괄
      PERFORM CHK_INIT.
      PERFORM GET_DATA_MOVE_D.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.        "처리결과조회/취소
    PERFORM GET_DATA_REVMOVE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_MOVE_AC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_MOVE_AC .

  CLEAR: GT_DATA.

  SELECT A~MATNR, A~WERKS, A~LGORT, A~CHARG, A~SOBKZ,
         A~VBELN AS FVBELN, A~POSNR AS FPOSNR, A~KALAB AS FKALAB,
         B~MTART, B~MATKL, B~MEINS,
         C~ZPJNO AS FZPJNO, C~BSTNK AS FBSTNK,
         D~NAME1,
         E~LGOBE,
         F~MTBEZ,
         G~WGBEZ,
         H~MAKTX,
         I~ZPTXT AS FZPTXT,
         J~ZJOB_NAME AS FJOBNM
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
    FROM            MSKA       AS A
   INNER JOIN       MARA       AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN VBAK       AS C ON C~VBELN EQ A~VBELN
    LEFT OUTER JOIN T001W      AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L      AS E ON E~WERKS EQ A~WERKS
                                   AND E~LGORT EQ A~LGORT
    LEFT OUTER JOIN T134T      AS F ON F~SPRAS EQ @SY-LANGU
                                   AND F~MTART EQ B~MTART
    LEFT OUTER JOIN T023T      AS G ON G~SPRAS EQ @SY-LANGU
                                   AND G~MATKL EQ B~MATKL
    LEFT OUTER JOIN MAKT       AS H ON H~MATNR EQ A~MATNR
                                   AND H~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T   AS I ON I~ZPJNO EQ C~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS J ON J~ZJOB_NO EQ C~BSTNK
   WHERE A~WERKS EQ @P_WERKS
     AND A~MATNR IN @S_MATNR
     AND B~MTART IN @S_MTART
     AND B~MATKL IN @S_MATKL
     AND A~LGORT IN @S_LGORT
     AND A~VBELN IN @S_VBELN
     AND A~POSNR IN @S_POSNR
     AND C~ZPJNO IN @S_ZPJNO
     AND C~BSTNK IN @S_BSTNK
     AND A~CHARG IN @S_CHARG
     AND A~KALAB GT 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_MOVE_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_MOVE_B .

  DATA: LT_DATA LIKE TABLE OF GS_DATA.

  CLEAR: GT_DATA.

  SELECT A~MATNR A~WERKS A~LGORT A~CHARG A~CLABS AS FKALAB
         B~MTART B~MATKL B~MEINS
         C~NAME1
         D~LGOBE
         E~MTBEZ
         F~WGBEZ
         G~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
    FROM            MCHB  AS A
   INNER JOIN       MARA  AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN T001W AS C ON C~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L AS D ON D~WERKS EQ A~WERKS
                              AND D~LGORT EQ A~LGORT
    LEFT OUTER JOIN T134T AS E ON E~SPRAS EQ SY-LANGU
                              AND E~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ SY-LANGU
                              AND F~MATKL EQ B~MATKL
    LEFT OUTER JOIN MAKT  AS G ON G~MATNR EQ A~MATNR
                              AND G~SPRAS EQ SY-LANGU
   WHERE A~WERKS EQ P_WERKS
     AND A~MATNR IN S_MATNR
     AND B~MTART IN S_MTART
     AND B~MATKL IN S_MATKL
     AND A~LGORT IN S_LGORT
     AND A~CHARG IN S_CHARG
     AND A~CLABS GT 0.

  CLEAR: LT_DATA.

  SELECT A~MATNR A~WERKS A~LGORT A~LABST AS FKALAB
         B~MTART B~MATKL B~MEINS
         C~NAME1
         D~LGOBE
         E~MTBEZ
         F~WGBEZ
         G~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE LT_DATA
    FROM            MARD  AS A
   INNER JOIN       MARA  AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN T001W AS C ON C~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L AS D ON D~WERKS EQ A~WERKS
                              AND D~LGORT EQ A~LGORT
    LEFT OUTER JOIN T134T AS E ON E~SPRAS EQ SY-LANGU
                              AND E~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ SY-LANGU
                              AND F~MATKL EQ B~MATKL
    LEFT OUTER JOIN MAKT  AS G ON G~MATNR EQ A~MATNR
                              AND G~SPRAS EQ SY-LANGU
   WHERE A~WERKS EQ P_WERKS
     AND A~MATNR IN S_MATNR
     AND B~MTART IN S_MTART
     AND B~MATKL IN S_MATKL
     AND A~LGORT IN S_LGORT
     AND A~LABST GT 0.

  LOOP AT LT_DATA INTO DATA(LS_DATA).
    READ TABLE GT_DATA INTO DATA(LS_DATA1) WITH KEY MATNR = LS_DATA-MATNR.
    IF LS_DATA1 IS INITIAL.
      MOVE-CORRESPONDING LS_DATA TO GS_DATA.
      APPEND GS_DATA TO GT_DATA.
      CLEAR: GS_DATA, LS_DATA.
    ENDIF.
    CLEAR: LS_DATA1, LS_DATA.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  IF P_R1 EQ GC_X.            "이전전기처리
    PERFORM MODIFY_DATA_MOVE.
  ELSEIF P_R2 EQ GC_X.        "처리결과조회/취소
    PERFORM MODIFY_DATA_REVMOVE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_MOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_MOVE .

  DATA : LV_MENGE  TYPE VBAP-KWMENG.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF P_R11 EQ GC_X.
      <FS_S>-ZTYPE = GC_A.
      IF <FS_S>-CHARG IS NOT INITIAL.
        <FS_S>-TCHARG = <FS_S>-CHARG.
      ENDIF.
    ELSEIF P_R12 EQ GC_X.
      <FS_S>-ZTYPE = GC_B.
      IF <FS_S>-CHARG IS NOT INITIAL.
        <FS_S>-TCHARG = <FS_S>-CHARG.
      ENDIF.
    ELSEIF P_R13 EQ GC_X.
      <FS_S>-ZTYPE = GC_C.

      IF <FS_S>-CHARG IS NOT INITIAL.
        READ TABLE GT_MCHB INTO DATA(LS_MCHB) WITH KEY MATNR = <FS_S>-MATNR
                                                       WERKS = <FS_S>-WERKS
                                                       LGORT = <FS_S>-LGORT
                                                       CHARG = <FS_S>-CHARG.
        IF LS_MCHB IS NOT INITIAL.
          <FS_S>-TKALAB = LS_MCHB-CLABS.
        ENDIF.
        CLEAR: LS_MCHB.

        <FS_S>-TCHARG = <FS_S>-CHARG.

      ELSEIF <FS_S>-CHARG IS INITIAL.
        READ TABLE GT_MARD INTO DATA(LS_MARD) WITH KEY MATNR = <FS_S>-MATNR
                                                       WERKS = <FS_S>-WERKS
                                                       LGORT = <FS_S>-LGORT.
        IF LS_MARD IS NOT INITIAL.
          <FS_S>-TKALAB = LS_MARD-LABST.
        ENDIF.
        CLEAR: LS_MARD.

      ENDIF.
    ELSEIF P_R14 EQ GC_X.
      <FS_S>-ZTYPE = GC_D.

      IF <FS_S>-LV_ATWRT IS NOT INITIAL.
        READ TABLE GT_DATATO ASSIGNING FIELD-SYMBOL(<FS_DATATO>)
                             WITH KEY LV_ATWRT = <FS_S>-LV_ATWRT
                                      TMATNR   = <FS_S>-MATNR
                                      BINARY SEARCH.    "SRM2602-01100

        IF SY-SUBRC EQ 0.
          MOVE: <FS_DATATO>-TZPJNO TO <FS_S>-TZPJNO,
                <FS_DATATO>-TZPTXT TO <FS_S>-TZPTXT,
                <FS_DATATO>-TBSTNK TO <FS_S>-TBSTNK,
                <FS_DATATO>-TJOBNM TO <FS_S>-TJOBNM,
                <FS_DATATO>-TVBELN TO <FS_S>-TVBELN,
                <FS_DATATO>-TPOSNR TO <FS_S>-TPOSNR,
                <FS_DATATO>-TMATNR TO <FS_S>-TMATNR,
                <FS_DATATO>-KWMENG TO <FS_S>-KWMENG.

          IF <FS_S>-CHARG IS NOT INITIAL.
            GV_ZAHL = GV_ZAHL + 1.

            CLEAR: GV_ZAHL_36.
            CALL FUNCTION 'TB_LIMIT_CONVERT_DEC_TO_36'
              EXPORTING
                I_ZAHL   = GV_ZAHL
              IMPORTING
                E_ZAHL   = GV_ZAHL_36
              EXCEPTIONS
                OVERFLOW = 1
                OTHERS   = 2.

            <FS_S>-TCHARG = <FS_S>-TBSTNK+0(8) && GV_ZAHL_36+18(2).
          ENDIF.

          IF <FS_S>-TVBELN IS NOT INITIAL AND <FS_S>-TPOSNR IS NOT INITIAL.
            SELECT SINGLE KALAB
              FROM MSKA
             WHERE WERKS EQ @<FS_S>-WERKS
               AND LGORT EQ @<FS_S>-LGORT
               AND CHARG EQ @<FS_S>-TCHARG
               AND VBELN EQ @<FS_S>-TVBELN
               AND POSNR EQ @<FS_S>-TPOSNR
              INTO @<FS_S>-TKALAB.
          ENDIF.

*SRM2602-01100
          LV_MENGE = LV_MENGE + <FS_S>-FKALAB.

*배치재고 + 누적 재고가 판매오더 수량과 동일하면 다음 맵핑 제외
          IF LV_MENGE >= <FS_S>-KWMENG.
               CLEAR : LV_MENGE, <FS_DATATO>-LV_ATWRT.
          ENDIF.
*SRM2602-01100

        ENDIF.
      ENDIF.

      <FS_S>-SKALAB = <FS_S>-FKALAB + <FS_S>-TKALAB.
    ENDIF.

*-유형 TEXT
    READ TABLE GT_ZTYPE INTO GS_ZTYPE WITH KEY DOMVALUE_L = <FS_S>-ZTYPE.
    <FS_S>-ZTEXT = GS_ZTYPE-DDTEXT.

    <FS_S>-BUDAT = SY-DATUM.
    <FS_S>-BKTXT = SY-REPID.
    <FS_S>-ID = ICON_LED_INACTIVE.

    PERFORM SET_STY_RTN CHANGING <FS_S>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN .
  CLEAR: GT_FIELDCAT_0100[], GS_LAYOUT_0100, GT_EXCLUDE_0100[],
         GT_EXCLUDE_0100, GV_OK_CODE, GV_DBCNT,
         GT_DATA[], GT_REVDATA[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .
  CREATE OBJECT GO_CONTAIN_0100
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
  DATA: LV_TITLE(40).

  CLEAR: LV_TITLE.
  IF P_R1 EQ GC_X.
    IF P_R11 EQ GC_X.
      LV_TITLE = TEXT-T02 && |: | && TEXT-A01.
    ELSEIF P_R12 EQ GC_X.
      LV_TITLE = TEXT-T02 && |: | && TEXT-B01.
    ELSEIF P_R13 EQ GC_X.
      LV_TITLE = TEXT-T02 && |: | && TEXT-C01.
    ELSEIF P_R14 EQ GC_X.
      LV_TITLE = TEXT-T02 && |: | && TEXT-D01.
    ENDIF.
  ENDIF.

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
  GS_LAYOUT_0100-EDIT       = GC_X.
  GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
  GS_LAYOUT_0100-GRID_TITLE = LV_TITLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_GRID_0100 .
  IF P_LAYO IS NOT INITIAL.
    GS_VARIANT-VARIANT = P_LAYO.
  ENDIF.
  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .
  IF P_R1 EQ GC_X.
    PERFORM SET_FIELDCAT_MOVE.
  ELSEIF P_R2 EQ GC_X.
    PERFORM SET_FIELDCAT_REVMOVE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_MOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_MOVE .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4010TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
*      WHEN 'ZTEXT'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "유형
*        <LS_FCAT>-JUST = GC_L.
*        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "저장위치 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "자재유형 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재그룹 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "(FROM)배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "(FROM)프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "(FROM)프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FBSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "(FROM)제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FJOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "(FROM)제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FVBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "(FROM)판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FPOSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "(FROM)판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FKALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "(FROM)재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TCHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "(TO)배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "(TO)프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "(TO)프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TBSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "(TO)제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TJOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "(TO)제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TVBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "(TO)판매오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'TPOSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "(TO)판매오더품목
        <LS_FCAT>-JUST = GC_C.
      WHEN 'TKALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "(TO)재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "재고단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "전기일자
        <LS_FCAT>-JUST = GC_C.
*      WHEN 'BKTXT'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "헤더텍스트
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "처리메세지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

    IF P_R11 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'TCHARG'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R12 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'FZPJNO' OR <LS_FCAT>-FIELDNAME = 'FZPTXT' OR
         <LS_FCAT>-FIELDNAME = 'FBSTNK' OR <LS_FCAT>-FIELDNAME = 'FJOBNM' OR
         <LS_FCAT>-FIELDNAME = 'FVBELN' OR <LS_FCAT>-FIELDNAME = 'FPOSNR' OR
         <LS_FCAT>-FIELDNAME = 'TCHARG'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R13 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'TZPJNO' OR <LS_FCAT>-FIELDNAME = 'TZPTXT' OR
         <LS_FCAT>-FIELDNAME = 'TBSTNK' OR <LS_FCAT>-FIELDNAME = 'TJOBNM' OR
         <LS_FCAT>-FIELDNAME = 'TVBELN' OR <LS_FCAT>-FIELDNAME = 'TPOSNR' OR
         <LS_FCAT>-FIELDNAME = 'TCHARG'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R14 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'TVBELN' OR <LS_FCAT>-FIELDNAME = 'TPOSNR'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100 .
  CHECK GO_EVTR_0100 IS INITIAL.

  CREATE OBJECT GO_EVTR_0100
    EXPORTING
      I_REPID = GV_REPID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  PERFORM SET_EVTR_RTN.

  IF P_R1 EQ GC_X.
    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = GS_VARIANT
        I_SAVE               = GC_X
      CHANGING
        IT_OUTTAB            = GT_DATA
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ELSEIF P_R2 EQ GC_X.
    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = GS_VARIANT
        I_SAVE               = GC_X
      CHANGING
        IT_OUTTAB            = GT_REVDATA
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVTR_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVTR_RTN .
  SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0100.
  SET HANDLER: GO_EVTR_0100->HDL_DOUBLE_CLICK FOR GO_GRID_0100.

* DATA CHANGE
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TKALAB_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_TKALAB_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                     CHANGING P_DATA_CHANGED
                              TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_KALAB TYPE LABST,
        L_VBELN TYPE VBELN,
        L_POSNR TYPE POSNR,
        L_ZPJNO TYPE ZPJNO,
        L_BSTNK TYPE BSTNK,
        L_ZPTXT TYPE ZPTXT,
        L_JOBNM LIKE ZGTEDT2121-ZJOB_NAME.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  IF <FS_S>-ZTYPE EQ GC_A OR <FS_S>-ZTYPE EQ GC_B.
    CLEAR: L_VBELN, L_POSNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = <FS_S>-TVBELN
      IMPORTING
        OUTPUT = L_VBELN.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_LVC_S_MODI-VALUE
      IMPORTING
        OUTPUT = L_POSNR.

    CLEAR: L_ZPJNO, L_BSTNK, L_ZPTXT, L_JOBNM.
    IF <FS_S>-ZTYPE EQ GC_A.
      SELECT SINGLE A~MATNR A~KWMENG B~ZPJNO B~BSTNK C~ZPTXT D~ZJOB_NAME
        INTO (<FS_S>-TMATNR, <FS_S>-KWMENG, L_ZPJNO, L_BSTNK, L_ZPTXT, L_JOBNM)
        FROM            VBAP       AS A
       INNER JOIN       VBAK       AS B ON B~VBELN EQ A~VBELN
        LEFT OUTER JOIN ZSD0106T   AS C ON C~ZPJNO EQ B~ZPJNO
        LEFT OUTER JOIN ZGTEDT2121 AS D ON D~ZJOB_NO EQ B~BSTNK
       WHERE A~VBELN EQ L_VBELN
         AND A~POSNR EQ L_POSNR
         AND A~WERKS EQ <FS_S>-WERKS.

    ELSEIF <FS_S>-ZTYPE EQ GC_B.
      SELECT SINGLE A~KWMENG B~ZPJNO B~BSTNK C~ZPTXT D~ZJOB_NAME
        INTO (<FS_S>-KWMENG, L_ZPJNO, L_BSTNK, L_ZPTXT, L_JOBNM)
        FROM            VBAP       AS A
       INNER JOIN       VBAK       AS B ON B~VBELN EQ A~VBELN
        LEFT OUTER JOIN ZSD0106T   AS C ON C~ZPJNO EQ B~ZPJNO
        LEFT OUTER JOIN ZGTEDT2121 AS D ON D~ZJOB_NO EQ B~BSTNK
       WHERE A~VBELN EQ L_VBELN
         AND A~POSNR EQ L_POSNR
         AND A~WERKS EQ <FS_S>-WERKS.
    ENDIF.

    IF SY-SUBRC EQ 0.
      CLEAR: L_KALAB.
      IF <FS_S>-CHARG IS NOT INITIAL.
        SELECT SINGLE KALAB
          INTO L_KALAB
          FROM MSKA
         WHERE MATNR EQ <FS_S>-MATNR
           AND WERKS EQ <FS_S>-WERKS
           AND LGORT EQ <FS_S>-LGORT
           AND CHARG EQ <FS_S>-CHARG
           AND VBELN EQ L_VBELN
           AND POSNR EQ L_POSNR.

      ELSEIF <FS_S>-CHARG IS INITIAL.
        SELECT SINGLE KALAB
          INTO L_KALAB
          FROM MSKA
         WHERE MATNR EQ <FS_S>-MATNR
           AND WERKS EQ <FS_S>-WERKS
           AND LGORT EQ <FS_S>-LGORT
           AND VBELN EQ L_VBELN
           AND POSNR EQ L_POSNR.
      ENDIF.

*-(FROM)재고 + (TO)재고
      <FS_S>-SKALAB = <FS_S>-FKALAB + L_KALAB.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TKALAB'
          I_VALUE     = L_KALAB.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TZPJNO'
          I_VALUE     = L_ZPJNO.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TZPTXT'
          I_VALUE     = L_ZPTXT.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TBSTNK'
          I_VALUE     = L_BSTNK.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TJOBNM'
          I_VALUE     = L_JOBNM.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TMATNR'
          I_VALUE     = <FS_S>-TMATNR.

    ELSE.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TKALAB'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TVBELN'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TPOSNR'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TZPJNO'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TZPTXT'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TBSTNK'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TJOBNM'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'TMATNR'
          I_VALUE     = SPACE.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN  CHANGING P_LINE LIKE GS_DATA.

  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ELSE.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    ENDIF.

    LS_STY-FIELDNAME = &1.
    INSERT LS_STY INTO TABLE P_LINE-CELL_STY.
    CLEAR LS_STY.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  SET_STY 'ZTEXT'    'X'.
  SET_STY 'WERKS'    'X'.
  SET_STY 'NAME1'    'X'.
  SET_STY 'LGORT'    'X'.
  SET_STY 'LGOBE'    'X'.
  SET_STY 'MTART'    'X'.
  SET_STY 'MTBEZ'    'X'.
  SET_STY 'MATKL'    'X'.
  SET_STY 'WGBEZ'    'X'.
  SET_STY 'MATNR'    'X'.
  SET_STY 'MAKTX'    'X'.
  SET_STY 'CHARG'    'X'.
  SET_STY 'FZPJNO'   'X'.
  SET_STY 'FZPTXT'   'X'.
  SET_STY 'FBSTNK'   'X'.
  SET_STY 'FJOBNM'   'X'.
  SET_STY 'FVBELN'   'X'.
  SET_STY 'FPOSNR'   'X'.
  SET_STY 'FKALAB'   'X'.
  SET_STY 'TCHARG'   'X'.
  SET_STY 'TZPJNO'   'X'.
  SET_STY 'TZPTXT'   'X'.
  SET_STY 'TBSTNK'   'X'.
  SET_STY 'TJOBNM'   'X'.
  IF P_LINE-ZTYPE EQ GC_D.
    SET_STY 'TVBELN'   'X'.
    SET_STY 'TPOSNR'   'X'.
  ELSE.
    SET_STY 'TVBELN'   SPACE.
    SET_STY 'TPOSNR'   SPACE.
  ENDIF.
  SET_STY 'TKALAB'   'X'.
  SET_STY 'MEINS'    'X'.
  SET_STY 'BUDAT'    SPACE.
  SET_STY 'BKTXT'    SPACE.
  SET_STY 'ID'       'X'.
  SET_STY 'RTMSG'    'X'.
  SET_STY 'MBLNR'    'X'.
  SET_STY 'MJAHR'    'X'.
  SET_STY 'SOBKZ'    'X'.
  SET_STY 'ZTYPE'    'X'.
  SET_STY 'TMATNR'   'X'.
  SET_STY 'KWMENG'   'X'.
  SET_STY 'SKALAB'   'X'.
  SET_STY 'LV_ATWRT' 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_MOVE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T05 "재고 이전전기
      TEXT_QUESTION         = TEXT-T06 "재고 이전전기를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ID EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M02. "이미 처리한 레코드가 선택되었습니다.
      ELSE.
        IF P_R11 EQ GC_X OR  "판매오더간
           P_R14 EQ GC_X.    "제번간 일괄
          "품목코드 체크
          IF <FS_S>-MATNR NE <FS_S>-TMATNR.
            <FS_S>-RTMSG = TEXT-M08. "판매오더의 품목코드가 서로 다릅니다.
          ELSE.
            "(FROM)재고+(TO)재고는 (TO)판매오더+품목의 오더수량을 초과할 수 없다.
            IF <FS_S>-SKALAB GT <FS_S>-KWMENG.
              <FS_S>-RTMSG = TEXT-M11. "(TO)판매오더수량을 초과한 재고 이전은 불가합니다.
            ELSE.
              IF P_R14 EQ GC_X.
                CLEAR: GV_CHK.
                PERFORM CREATE_BATCH USING <FS_S>.
                IF GV_CHK EQ GC_X.
                  PERFORM EXEC_STOCK_MOVE USING <FS_S>.
                ENDIF.
              ELSE.
                PERFORM EXEC_STOCK_MOVE USING <FS_S>.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF P_R12 EQ GC_X.  "플랜트->판매오더
          "(FROM)재고+(TO)재고는 (TO)판매오더+품목의 오더수량을 초과할 수 없다.
          IF <FS_S>-SKALAB GT <FS_S>-KWMENG.
            <FS_S>-RTMSG = TEXT-M11. "(TO)판매오더수량을 초과한 재고 이전은 불가합니다.
          ELSE.
            PERFORM EXEC_STOCK_MOVE USING <FS_S>.
          ENDIF.
        ELSE.
          PERFORM EXEC_STOCK_MOVE USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SEL_ROW_RTN  TABLES PT_ROW_NO TYPE LVC_T_ROID
                  USING  PR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

*--------------------------------------------------------------------*

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN .
  DATA LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_GRID_0100->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_0100.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_STOCK_MOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_STOCK_MOVE  USING    P_LINE LIKE GS_DATA.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '04',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_BWART TYPE BWART,
        LV_SOBKZ TYPE SOBKZ.
  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = P_LINE-BUDAT
                       HEADER_TXT = P_LINE-BKTXT ).

  CLEAR: LV_BWART.
  IF P_LINE-ZTYPE EQ GC_A OR P_LINE-ZTYPE EQ GC_B OR P_LINE-ZTYPE EQ GC_D.
    LV_BWART = '413'.
  ELSEIF P_LINE-ZTYPE EQ GC_C.
    LV_BWART = '411'.
  ENDIF.

  CLEAR: LV_SOBKZ.
  IF P_LINE-ZTYPE EQ GC_A OR P_LINE-ZTYPE EQ GC_C OR P_LINE-ZTYPE EQ GC_D.
    LV_SOBKZ = GC_E.
  ENDIF.

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-MATNR
                       PLANT          = P_LINE-WERKS
                       STGE_LOC       = P_LINE-LGORT
                       BATCH             = P_LINE-CHARG       "SRM2509-06700
*                       BATCH              = P_LINE-TCHARG
                       VAL_SALES_ORD  = P_LINE-FVBELN
                       VAL_S_ORD_ITEM = P_LINE-FPOSNR
                       MOVE_TYPE      = LV_BWART
                       SPEC_STOCK     = LV_SOBKZ
                       MOVE_MAT       = P_LINE-MATNR
                       MOVE_PLANT     = P_LINE-WERKS
                       MOVE_STLOC     = P_LINE-LGORT
                       MOVE_BATCH     = P_LINE-TCHARG   "SRM2509-06700
*                       MOVE_BATCH     = P_LINE-CHARG
                       STCK_TYPE      = SPACE
                       ENTRY_UOM      = P_LINE-MEINS
                       ENTRY_QNT      = P_LINE-FKALAB
                       SALES_ORD      = P_LINE-TVBELN
                       S_ORD_ITEM     = P_LINE-TPOSNR ) ).

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LV_CODE
    IMPORTING
      GOODSMVT_HEADRET = LS_GMHEADRET
      MATERIALDOCUMENT = LV_DOCUMENT
      MATDOCUMENTYEAR  = LV_YEAR
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LS_GMHEADRET IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = GC_E.
    IF LS_RETURN-MESSAGE IS INITIAL.
      P_LINE-RTMSG = TEXT-M04. "재고 이전전기 처리에 실패하였습니다.
    ELSE.
      P_LINE-RTMSG = LS_RETURN-MESSAGE.
    ENDIF.
    P_LINE-ID = ICON_LED_RED.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-ID = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M03. "재고 이전전기 처리에 성공하였습니다.
    P_LINE-MBLNR = LV_DOCUMENT.
    P_LINE-MJAHR = LV_YEAR.

    PERFORM SAVE_ZGTPPT4010 USING P_LINE.

    IF P_LINE-ZTYPE EQ GC_D.
      PERFORM UPDATE_JOBNO_STATUS USING P_LINE.
      PERFORM UPDATE_ZGTSDT0065 USING P_LINE.
    ENDIF.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT4010  USING    P_LINE LIKE GS_DATA.

  DATA: LS_ZGTPPT4010 LIKE ZGTPPT4010.

  CLEAR: LS_ZGTPPT4010.

  LS_ZGTPPT4010 = VALUE #( BASE CORRESPONDING #( P_LINE )
                             CRDAT = SY-DATUM
                             CRTIM = SY-UZEIT
                             CRNAM = SY-UNAME ).

  MODIFY ZGTPPT4010 FROM LS_ZGTPPT4010.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_REVMOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_REVMOVE .

  CLEAR: GT_REVODATA.

  SELECT A~MBLNR A~MJAHR A~ZTYPE A~CRDAT A~CRTIM A~CRNAM
         B~BUDAT B~BKTXT
         C~BWART C~WERKS C~LGORT C~MATNR C~CHARG C~UMCHA AS TCHARG
         C~MAT_KDAUF AS FVBELN C~MAT_KDPOS AS FPOSNR
         C~KDAUF AS TVBELN C~KDPOS AS TPOSNR
         C~MENGE C~MEINS C~ZEILE C~SHKZG
         D~MTART D~MATKL
         E~NAME1
         F~LGOBE
         G~MTBEZ
         H~WGBEZ
         I~MAKTX
         J~BTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_REVODATA
    FROM      ZGTPPT4010   AS A
   INNER JOIN       MKPF   AS B ON B~MBLNR EQ A~MBLNR
                               AND B~MJAHR EQ A~MJAHR
   INNER JOIN       MSEG   AS C ON C~MBLNR EQ B~MBLNR
                               AND C~MJAHR EQ B~MJAHR
   INNER JOIN       MARA   AS D ON D~MATNR EQ C~MATNR
    LEFT OUTER JOIN T001W  AS E ON E~WERKS EQ C~WERKS
    LEFT OUTER JOIN T001L  AS F ON F~WERKS EQ C~WERKS
                               AND F~LGORT EQ C~LGORT
    LEFT OUTER JOIN T134T  AS G ON G~SPRAS EQ SY-LANGU
                               AND G~MTART EQ D~MTART
    LEFT OUTER JOIN T023T  AS H ON H~SPRAS EQ SY-LANGU
                               AND H~MATKL EQ D~MATKL
    LEFT OUTER JOIN MAKT   AS I ON I~MATNR EQ C~MATNR
                               AND I~SPRAS EQ SY-LANGU
    LEFT OUTER JOIN T156HT AS J ON J~SPRAS EQ SY-LANGU
                               AND J~BWART EQ C~BWART
   WHERE C~WERKS EQ P_WERKS
     AND C~MATNR IN S_MATNR
     AND D~MTART IN S_MTART
     AND D~MATKL IN S_MATKL
     AND C~LGORT IN S_LGORT
     AND ( C~MAT_KDAUF IN S_VBELN OR C~KDAUF IN S_VBELN )
     AND ( C~MAT_KDPOS IN S_POSNR OR C~KDPOS IN S_POSNR )
     AND C~CHARG IN S_CHARG
     AND A~MBLNR IN S_MBLNR
     AND C~BWART IN S_BWART
     AND B~BUDAT IN S_BUDAT
     AND A~ZTYPE IN S_ZTYPE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_REVMOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_REVMOVE .

  TYPES: BEGIN OF LTY_MBLNR,
           MBLNR TYPE MBLNR,
           MJAHR TYPE MJAHR,
         END OF LTY_MBLNR.

  DATA: LT_MBLNR TYPE TABLE OF LTY_MBLNR.

  CLEAR: GT_REVDATA.

  GT_REVDATA = VALUE #( FOR LS_REVODATA IN GT_REVODATA
                        WHERE ( SHKZG = GC_H )
                      ( CORRESPONDING #( LS_REVODATA ) ) ).

  CLEAR: LT_MBLNR.
  LT_MBLNR = VALUE #( FOR LS IN GT_REVDATA ( CORRESPONDING #( LS ) ) ).
  SORT LT_MBLNR BY MBLNR MJAHR.
  DELETE ADJACENT DUPLICATES FROM LT_MBLNR COMPARING MBLNR MJAHR.

  IF LT_MBLNR IS NOT INITIAL.
    CLEAR: GT_SMBLN.
    SELECT SMBLN SJAHR MBLNR MJAHR
      INTO TABLE GT_SMBLN
      FROM MSEG
       FOR ALL ENTRIES IN LT_MBLNR
     WHERE SMBLN EQ LT_MBLNR-MBLNR
       AND SJAHR EQ LT_MBLNR-MJAHR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_REVMOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_REVMOVE .

  DATA: LT_REVAC LIKE TABLE OF GS_REVDATA,
        LT_REVB  LIKE TABLE OF GS_REVDATA.

  LOOP AT GT_REVDATA ASSIGNING FIELD-SYMBOL(<FS_S>).
*-유형 TEXT
    READ TABLE GT_ZTYPE INTO GS_ZTYPE WITH KEY DOMVALUE_L = <FS_S>-ZTYPE.
    <FS_S>-ZTEXT = GS_ZTYPE-DDTEXT.

    SELECT SINGLE A~ZPJNO A~BSTNK B~ZPTXT C~ZJOB_NAME
      INTO (<FS_S>-FZPJNO, <FS_S>-FBSTNK, <FS_S>-FZPTXT, <FS_S>-FJOBNM)
      FROM VBAK AS A
      LEFT OUTER JOIN ZSD0106T   AS B ON B~ZPJNO EQ A~ZPJNO
      LEFT OUTER JOIN ZGTEDT2121 AS C ON C~ZJOB_NO EQ A~BSTNK
     WHERE A~VBELN EQ <FS_S>-FVBELN.

    SELECT SINGLE A~ZPJNO A~BSTNK B~ZPTXT C~ZJOB_NAME
      INTO (<FS_S>-TZPJNO, <FS_S>-TBSTNK, <FS_S>-TZPTXT, <FS_S>-TJOBNM)
      FROM VBAK AS A
      LEFT OUTER JOIN ZSD0106T   AS B ON B~ZPJNO EQ A~ZPJNO
      LEFT OUTER JOIN ZGTEDT2121 AS C ON C~ZJOB_NO EQ A~BSTNK
     WHERE A~VBELN EQ <FS_S>-TVBELN.

    <FS_S>-ID = ICON_LED_INACTIVE.

    READ TABLE GT_SMBLN INTO DATA(LS_SMBLN) WITH KEY SMBLN = <FS_S>-MBLNR
                                                     SJAHR = <FS_S>-MJAHR.
    IF LS_SMBLN IS NOT INITIAL.
      <FS_S>-SMBLN = LS_SMBLN-MBLNR.
    ENDIF.
    CLEAR: LS_SMBLN.

    PERFORM SET_STY_RTN_R CHANGING <FS_S>.
  ENDLOOP.

  IF P_C1 EQ GC_X.
    DELETE GT_REVDATA WHERE SMBLN IS NOT INITIAL.
  ENDIF.

  CLEAR: LT_REVAC, LT_REVB.
  LT_REVAC = VALUE #( FOR LS_REVAC IN GT_REVDATA
                      WHERE ( ZTYPE = GC_A OR ZTYPE = GC_C OR ZTYPE = GC_D )
                    ( CORRESPONDING #( LS_REVAC ) ) ).

  LT_REVB = VALUE #( FOR LS_REVB IN GT_REVDATA
                     WHERE ( ZTYPE = GC_B )
                   ( CORRESPONDING #( LS_REVB ) ) ).

  IF S_ZPJNO[] IS NOT INITIAL.
    DELETE LT_REVAC WHERE FZPJNO NOT IN S_ZPJNO.
    DELETE LT_REVB  WHERE TZPJNO NOT IN S_ZPJNO.
  ENDIF.

  IF S_BSTNK[] IS NOT INITIAL.
    DELETE LT_REVAC WHERE FBSTNK NOT IN S_BSTNK.
    DELETE LT_REVB  WHERE TBSTNK NOT IN S_BSTNK.
  ENDIF.

  CLEAR: GT_REVDATA[].
  APPEND LINES OF LT_REVAC TO GT_REVDATA.
  APPEND LINES OF LT_REVB TO GT_REVDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_MOVE_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_MOVE_C .

  DATA: LT_MCHB1 LIKE TABLE OF GS_DATA,
        LT_MARD1 LIKE TABLE OF GS_DATA.

  CLEAR: LT_MCHB1, LT_MARD1.
  LT_MCHB1 = VALUE #( FOR LS_DATA IN GT_DATA WHERE ( CHARG IS NOT INITIAL )
                                   ( MATNR = LS_DATA-MATNR
                                     WERKS = LS_DATA-WERKS
                                     LGORT = LS_DATA-LGORT
                                     CHARG = LS_DATA-CHARG ) ).

  LT_MARD1 = VALUE #( FOR LS_DATA IN GT_DATA WHERE ( CHARG IS INITIAL )
                                   ( MATNR = LS_DATA-MATNR
                                     WERKS = LS_DATA-WERKS
                                     LGORT = LS_DATA-LGORT ) ).

  SORT: LT_MCHB1 BY MATNR WERKS LGORT CHARG,
        LT_MARD1 BY MATNR WERKS LGORT.

  DELETE ADJACENT DUPLICATES FROM LT_MCHB1 COMPARING MATNR WERKS LGORT CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_MARD1 COMPARING MATNR WERKS LGORT.

  IF LT_MCHB1 IS NOT INITIAL.
    CLEAR: GT_MCHB.
    SELECT A~MATNR, A~WERKS, A~LGORT, A~CHARG, A~CLABS
      FROM      MCHB AS A
     INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
      INTO TABLE @GT_MCHB
       FOR ALL ENTRIES IN @LT_MCHB1
     WHERE A~MATNR EQ @LT_MCHB1-MATNR
       AND A~WERKS EQ @LT_MCHB1-WERKS
       AND A~LGORT EQ @LT_MCHB1-LGORT
       AND A~CHARG EQ @LT_MCHB1-CHARG.
  ENDIF.

  IF LT_MARD1 IS NOT INITIAL.
    CLEAR: GT_MARD.
    SELECT A~MATNR, A~WERKS, A~LGORT, A~LABST
      FROM      MARD AS A
     INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
      INTO TABLE @GT_MARD
       FOR ALL ENTRIES IN @LT_MARD1
     WHERE A~MATNR EQ @LT_MARD1-MATNR
       AND A~WERKS EQ @LT_MARD1-WERKS
       AND A~LGORT EQ @LT_MARD1-LGORT.
  ENDIF.

  SORT: GT_MCHB BY MATNR WERKS LGORT CHARG,
        GT_MARD BY MATNR WERKS LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA .
  IF P_R1 EQ GC_X.            "이전전기처리
    IF P_R13 EQ GC_X.            "판매오더->플랜트
      PERFORM SET_DATA_MOVE_C.
    ELSEIF P_R14 EQ GC_X.        "제번간 일괄
      PERFORM SET_DATA_MOVE_D.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.        "처리결과조회/취소
    PERFORM SET_DATA_REVMOVE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_REVMOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_REVMOVE .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4010TOP'
      I_INTERNAL_TABNAME     = 'GS_REVDATA'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_REVDATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "유형
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SMBLN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "취소자재문서번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BWART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "이동유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'BTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "이동유형 내역
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "저장위치 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "자재유형 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재그룹 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "(FROM)배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "(FROM)프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "(FROM)프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FBSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "(FROM)제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FJOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "(FROM)제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FVBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "(FROM)판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'FPOSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "(FROM)판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TCHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "(TO)배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "(TO)프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "(TO)프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TBSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "(TO)제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TJOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "(TO)제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TVBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "(TO)판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TPOSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "(TO)판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "재고단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "전기일자
        <LS_FCAT>-JUST = GC_C.
*      WHEN 'BKTXT'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "헤더텍스트
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "처리일자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "처리시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "처리자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "처리메세지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN_R
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN_R  CHANGING P_LINE LIKE GS_REVDATA.

  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ELSE.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    ENDIF.

    LS_STY-FIELDNAME = &1.
    INSERT LS_STY INTO TABLE P_LINE-CELL_STY.
    CLEAR LS_STY.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  SET_STY 'ZTEXT'  'X'.
  SET_STY 'MBLNR'  'X'.
  SET_STY 'MJAHR'  'X'.
  SET_STY 'SMBLN'  'X'.
  SET_STY 'BWART'  'X'.
  SET_STY 'BTEXT'  'X'.
  SET_STY 'WERKS'  'X'.
  SET_STY 'NAME1'  'X'.
  SET_STY 'LGORT'  'X'.
  SET_STY 'LGOBE'  'X'.
  SET_STY 'MTART'  'X'.
  SET_STY 'MTBEZ'  'X'.
  SET_STY 'MATKL'  'X'.
  SET_STY 'WGBEZ'  'X'.
  SET_STY 'MATNR'  'X'.
  SET_STY 'MAKTX'  'X'.
  SET_STY 'CHARG'  'X'.
  SET_STY 'FZPJNO' 'X'.
  SET_STY 'FZPTXT' 'X'.
  SET_STY 'FBSTNK' 'X'.
  SET_STY 'FJOBNM' 'X'.
  SET_STY 'FVBELN' 'X'.
  SET_STY 'FPOSNR' 'X'.
  SET_STY 'TCHARG' 'X'.
  SET_STY 'TZPJNO' 'X'.
  SET_STY 'TZPTXT' 'X'.
  SET_STY 'TBSTNK' 'X'.
  SET_STY 'TJOBNM' 'X'.
  SET_STY 'TVBELN' 'X'.
  SET_STY 'TPOSNR' 'X'.
  SET_STY 'MENGE'  'X'.
  SET_STY 'MEINS'  'X'.
  SET_STY 'BUDAT'  'X'.
  SET_STY 'BKTXT'  'X'.
  SET_STY 'CRDAT'  'X'.
  SET_STY 'CRTIM'  'X'.
  SET_STY 'CRNAM'  'X'.
  SET_STY 'ID'     'X'.
  SET_STY 'RTMSG'  'X'.
  SET_STY 'ZTYPE'  'X'.
  SET_STY 'ZEILE'  'X'.
  SET_STY 'SHKZG'  'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_REVMOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_REVMOVE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_REVDATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T07 "자재문서 취소
      "기존 재고 형태로 회귀합니다. 주의하여 주십시요! 선택한 자재문서를 취소하시겠습니까?
      TEXT_QUESTION         = TEXT-T08
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_REVDATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-SMBLN IS NOT INITIAL.
        <FS_S>-RTMSG = TEXT-M05. "이미 취소 처리된 자재문서입니다.
      ELSE.
        PERFORM EXEC_STOCK_MOVE_CANCEL USING <FS_S>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_STOCK_MOVE_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_STOCK_MOVE_CANCEL  USING    P_LINE LIKE GS_REVDATA.

  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT = P_LINE-MBLNR
      MATDOCUMENTYEAR  = P_LINE-MJAHR
*     GOODSMVT_PSTNG_DATE = SY-DATUM
    IMPORTING
      GOODSMVT_HEADRET = LS_GOODSMVT
    TABLES
      RETURN           = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-ID = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M06. "자재문서 취소에 성공하였습니다.
    P_LINE-SMBLN = LS_GOODSMVT-MAT_DOC.

    IF P_LINE-ZTYPE EQ GC_D.
      PERFORM UPDATE_JOBNO_STATUS_REV USING P_LINE.
    ENDIF.

    WAIT UP TO 1 SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    IF LT_RETURN-MESSAGE IS INITIAL.
      P_LINE-RTMSG = TEXT-M07. "자재문서 취소에 실패하였습니다.
    ELSE.
      P_LINE-RTMSG = LT_RETURN-MESSAGE.
    ENDIF.
    P_LINE-ID = ICON_LED_RED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M09 P_WERKS TEXT-M10.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

  IF P_FBSTNK IS NOT INITIAL.
    CLEAR: ZGTEDT2121, P_FJOBNM.
    SELECT SINGLE ZJOB_NAME
      FROM ZGTEDT2121
     WHERE ZJOB_NO EQ @P_FBSTNK
      INTO @P_FJOBNM.
  ELSE.
    CLEAR: P_FJOBNM.
  ENDIF.

  IF P_TBSTNK IS NOT INITIAL.
    CLEAR: ZGTEDT2121, P_TJOBNM.
    SELECT SINGLE ZJOB_NAME
      FROM ZGTEDT2121
     WHERE ZJOB_NO EQ @P_TBSTNK
      INTO @P_TJOBNM.
  ELSE.
    CLEAR: P_TJOBNM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_MOVE_D
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_MOVE_D .

  CLEAR: GT_DATA.

  SELECT A~MATNR, A~WERKS, A~LGORT, A~CHARG, A~SOBKZ,
         A~VBELN AS FVBELN, A~POSNR AS FPOSNR, A~KALAB AS FKALAB,
         B~MTART, B~MATKL, B~MEINS,
         C~ZPJNO AS FZPJNO, C~BSTNK AS FBSTNK,
         D~NAME1,
         E~LGOBE,
         F~MTBEZ,
         G~WGBEZ,
         H~MAKTX,
         I~ZPTXT AS FZPTXT,
         J~ZJOB_NAME AS FJOBNM
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
    FROM            MSKA       AS A
   INNER JOIN       MARA       AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN VBAK       AS C ON C~VBELN EQ A~VBELN
    LEFT OUTER JOIN T001W      AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L      AS E ON E~WERKS EQ A~WERKS
                                   AND E~LGORT EQ A~LGORT
    LEFT OUTER JOIN T134T      AS F ON F~SPRAS EQ @SY-LANGU
                                   AND F~MTART EQ B~MTART
    LEFT OUTER JOIN T023T      AS G ON G~SPRAS EQ @SY-LANGU
                                   AND G~MATKL EQ B~MATKL
    LEFT OUTER JOIN MAKT       AS H ON H~MATNR EQ A~MATNR
                                   AND H~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T   AS I ON I~ZPJNO EQ C~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS J ON J~ZJOB_NO EQ C~BSTNK
   WHERE A~WERKS EQ @P_WERKS
     AND B~MTART IN @S_MTART
     AND C~BSTNK EQ @P_FBSTNK
     AND A~KALAB GT 0.

  CLEAR: GT_DATATO.
  SELECT A~ZPJNO AS TZPJNO, A~BSTNK AS TBSTNK,
         B~MATNR AS TMATNR, B~WERKS, B~SOBKZ,
         B~VBELN AS TVBELN, B~POSNR AS TPOSNR, B~KWMENG,
         C~MTART, C~MATKL, C~MEINS,
         D~NAME1,
         E~MTBEZ,
         F~WGBEZ,
         G~MAKTX,
         H~ZPTXT AS TZPTXT,
         I~ZJOB_NAME AS TJOBNM
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATATO
    FROM            VBAK       AS A
   INNER JOIN       VBAP       AS B ON B~VBELN EQ A~VBELN
   INNER JOIN       MARA       AS C ON C~MATNR EQ B~MATNR
    LEFT OUTER JOIN T001W      AS D ON D~WERKS EQ B~WERKS
    LEFT OUTER JOIN T134T      AS E ON E~SPRAS EQ @SY-LANGU
                                   AND E~MTART EQ C~MTART
    LEFT OUTER JOIN T023T      AS F ON F~SPRAS EQ @SY-LANGU
                                   AND F~MATKL EQ C~MATKL
    LEFT OUTER JOIN MAKT       AS G ON G~MATNR EQ C~MATNR
                                   AND G~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T   AS H ON H~ZPJNO EQ A~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS I ON I~ZJOB_NO EQ A~BSTNK
   WHERE B~WERKS EQ @P_WERKS
     AND A~BSTNK EQ @P_TBSTNK
     AND b~ABGRU EQ @SPACE.    "SRM2510-03431 취소 판매오더 제외

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_MOVE_D
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_MOVE_D .

  DATA: LT_LIST LIKE TABLE OF ZLES001.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_F>).
    CLEAR: LT_LIST.
    CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
      EXPORTING
        I_VBELN                      = <FS_F>-FVBELN
        I_POSNR                      = <FS_F>-FPOSNR
        I_OBJECT                     = <FS_F>-MATNR
        I_WERKS                      = <FS_F>-WERKS
      TABLES
        GT_LIST                      = LT_LIST
      EXCEPTIONS
        INSTANCE_NOT_FOUND           = 1
        INSTANCE_IS_A_CLASSIFICATION = 2
        INVALID_DATA                 = 3
        OTHERS                       = 4.

    LOOP AT LT_LIST INTO DATA(LS_F).
      <FS_F>-LV_ATWRT = <FS_F>-LV_ATWRT && |,| && LS_F-ATWRT.
    ENDLOOP.
  ENDLOOP.

  IF GT_DATA IS NOT INITIAL.
    LOOP AT GT_DATATO ASSIGNING FIELD-SYMBOL(<FS_T>).
      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS_T>-TVBELN
          I_POSNR                      = <FS_T>-TPOSNR
          I_OBJECT                     = <FS_T>-TMATNR
          I_WERKS                      = <FS_T>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

      LOOP AT LT_LIST INTO DATA(LS_T).
        <FS_T>-LV_ATWRT = <FS_T>-LV_ATWRT && |,| && LS_T-ATWRT.
      ENDLOOP.
    ENDLOOP.

    SORT: GT_DATA BY LV_ATWRT MATNR,
          GT_DATATO BY LV_ATWRT TMATNR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .

  S_MTART[] = VALUE #( ( SIGN = GC_I
                         OPTION = GC_EQ
                         LOW = GC_FERT )
                       ( SIGN = GC_I
                         OPTION = GC_EQ
                         LOW = GC_HAWA )
                       ( SIGN = GC_I
                         OPTION = GC_EQ
                         LOW = GC_ROH1 )
                           ( SIGN = GC_I
                         OPTION = GC_EQ
                         LOW = GC_HALB ) ).

  CLEAR: GV_ZAHL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FBSTNK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_FBSTNK  USING    PV_VALUE.

  IF STRLEN( PV_VALUE ) GT '10'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M14. "제조지시번호의 길이는 10 자리입니다.
    LEAVE LIST-PROCESSING.
  ELSE.
*-(FROM)제조지시번호 추출
    SELECT SINGLE OJOB_NO
      FROM ZGTSDT0065
     WHERE ZSYSTEM_ID EQ @GC_KBDM
       AND JOB_NO     EQ @PV_VALUE
      INTO @DATA(L_JOB_NO).

    IF L_JOB_NO IS NOT INITIAL.
      P_FBSTNK = L_JOB_NO.
    ELSE.
      CLEAR: P_FBSTNK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_INIT .

*-(FROM)제조지시번호 체크
  IF P_FBSTNK IS INITIAL OR P_TBSTNK IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M15. "필수 필드에 값을 입력하세요.
    STOP.
  ENDIF.

*(TO)제조지시번호의 제조지시유형 점검
  IF P_TBSTNK IS NOT INITIAL.
    SELECT SINGLE ZJOB_NO
      FROM ZGTEDT2121
     WHERE ZSYSTEM_ID EQ @GC_KBDM
       AND ZWERKS     EQ @P_WERKS
       AND ZJOB_NO    EQ @P_TBSTNK
       AND ZZJOB_TYPE EQ @GC_Y
      INTO @DATA(LV_ZJOB_NO).

    IF LV_ZJOB_NO IS INITIAL.
      MESSAGE S003 DISPLAY LIKE GC_W
         WITH TEXT-M16. "이전전기 제조지시 유형이 아닙니다.
      STOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .

  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M12. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_R1 EQ GC_X AND P_R14 EQ GC_X.
    IF P_TBSTNK IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M13. "필수 필드 "(To)제조지시번호"에 입력하십시오.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZTYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ZTYPE .

  CLEAR: GT_ZTYPE.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME         = GC_ZTYPE    "ZGTD_ZTYPE
      TEXT            = GC_X
    TABLES
      VALUES_TAB      = GT_ZTYPE
    EXCEPTIONS
      NO_VALUES_FOUND = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_JOBNO_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM UPDATE_JOBNO_STATUS  USING    P_LINE LIKE GS_DATA.

  DATA: LV_RESULT  TYPE ZO_RESULT,
            LV_MESSAGE TYPE ZO_MESSAGE,
            LV_ZJOB_NO  TYPE char30,
            lv_zpro           TYPE char20.

            lv_zjob_no = p_line-fbstnk.
            lv_zpro = sy-repid.

  CLEAR: LV_RESULT, LV_MESSAGE.
  CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
    EXPORTING
      I_ZMODULE             = GC_PP
      I_ZPROGRAM           = lv_zpro         "ZGTPPR4010
      I_ZWERKS              = P_LINE-WERKS
*      I_ZJOB_NO             = P_LINE-FBSTNK
      I_ZJOB_NO             = lv_zjob_no
      I_ZSTATUS             = GC_90
    IMPORTING
      ZO_RESULT             = LV_RESULT
      ZO_MESSAGE            = LV_MESSAGE
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
      ILLEGALNAME           = 3
      OTHERS                = 4.

  CLEAR: LV_RESULT, LV_MESSAGE, lv_zjob_no.

  lv_zjob_no = P_LINE-TBSTNK.

  CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
    EXPORTING
      I_ZMODULE             = GC_PP
      I_ZPROGRAM            = lv_zpro         "ZGTPPR4010
      I_ZWERKS              = P_LINE-WERKS
*      I_ZJOB_NO             = P_LINE-TBSTNK
      I_ZJOB_NO             = lv_zjob_no
      I_ZSTATUS             = GC_90
    IMPORTING
      ZO_RESULT             = LV_RESULT
      ZO_MESSAGE            = LV_MESSAGE
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
      ILLEGALNAME           = 3
      OTHERS                = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_JOBNO_STATUS_REV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM UPDATE_JOBNO_STATUS_REV  USING    P_LINE LIKE GS_REVDATA.

  DATA: LV_RESULT  TYPE ZO_RESULT,
            LV_MESSAGE TYPE ZO_MESSAGE,
            LV_ZJOB_NO  TYPE char30,
            lv_zpro           TYPE char20.

            lv_zjob_no = p_line-fbstnk.
            lv_zpro = sy-repid.

  CLEAR: LV_RESULT, LV_MESSAGE.
  CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
    EXPORTING
      I_ZMODULE             = GC_PP
      I_ZPROGRAM            = lv_zpro        "ZGTPPR4010
      I_ZWERKS              = P_LINE-WERKS
      I_ZJOB_NO             = lv_zjob_no
      I_ZSTATUS             = GC_58
    IMPORTING
      ZO_RESULT             = LV_RESULT
      ZO_MESSAGE            = LV_MESSAGE
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
      ILLEGALNAME           = 3
      OTHERS                = 4.

  CLEAR: LV_RESULT, LV_MESSAGE, lv_zjob_no.

  lv_zjob_no = P_LINE-TBSTNK.
  CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
    EXPORTING
      I_ZMODULE             = GC_PP
      I_ZPROGRAM            = lv_zpro          "ZGTPPR4010
      I_ZWERKS              = P_LINE-WERKS
      I_ZJOB_NO             =   lv_zjob_no
      I_ZSTATUS             = GC_51
    IMPORTING
      ZO_RESULT             = LV_RESULT
      ZO_MESSAGE            = LV_MESSAGE
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
      ILLEGALNAME           = 3
      OTHERS                = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM CREATE_BATCH  USING    P_LINE LIKE GS_DATA.

  DATA : LS_YMCHA LIKE MCHA,
         LV_KDAUF LIKE AFPO-KDAUF,
         LV_KDPOS LIKE AFPO-KDPOS.

  DATA : LV_OBJECTKEY          LIKE  BAPI1003_KEY-OBJECT,
         LS_ALLOCVALUESNUMNEW	 LIKE BAPI1003_ALLOC_VALUES_NUM,
         LT_ALLOCVALUESNUMNEW  LIKE TABLE OF  BAPI1003_ALLOC_VALUES_NUM,
         LS_ALLOCVALUESCHARNEW LIKE BAPI1003_ALLOC_VALUES_CHAR,
         LT_ALLOCVALUESCHARNEW LIKE TABLE OF  BAPI1003_ALLOC_VALUES_CHAR,
         LS_ALLOCVALUESCURRNEW LIKE	BAPI1003_ALLOC_VALUES_CURR,
         LT_ALLOCVALUESCURRNEW LIKE	TABLE OF BAPI1003_ALLOC_VALUES_CURR,
         LS_RETURN             LIKE	BAPIRET2,
         LT_RETURN             LIKE	TABLE OF BAPIRET2.

  DATA: LV_CNT(1) TYPE N,
        LV_FS(17).
  FIELD-SYMBOLS : <LV_FS>.

  SELECT SINGLE MANDT
    FROM MCHA
   WHERE MATNR EQ @P_LINE-MATNR
     AND WERKS EQ @P_LINE-WERKS
     AND CHARG EQ @P_LINE-TCHARG
    INTO @SY-MANDT.

  IF SY-SUBRC NE 0.
    CLEAR: LS_YMCHA.
    LS_YMCHA-MATNR         = P_LINE-MATNR.
    LS_YMCHA-WERKS         = P_LINE-WERKS.
    LS_YMCHA-CHARG         = P_LINE-TCHARG.
    LS_YMCHA-ZZPJT_NO      = P_LINE-TZPJNO.
    LS_YMCHA-ZZJOB_NO      = P_LINE-TBSTNK.

    CLEAR: GV_FLINE_NO, GV_FSERIAL_INFO.
    SELECT SINGLE ZZLINE_NO, ZZSERIAL_INFO
      FROM MCH1
     WHERE MATNR EQ @P_LINE-MATNR
       AND CHARG EQ @P_LINE-CHARG
      INTO (@GV_FLINE_NO, @GV_FSERIAL_INFO).

    LS_YMCHA-ZZLINE_NO = GV_FLINE_NO.
    LS_YMCHA-ZZSERIAL_INFO = GV_FSERIAL_INFO.

    CLEAR: LS_RETURN, LT_RETURN.
    CALL FUNCTION 'VB_CREATE_BATCH'
      EXPORTING
        YMCHA                        = LS_YMCHA
      TABLES
        RETURN                       = LT_RETURN
      EXCEPTIONS
        NO_MATERIAL                  = 1
        NO_BATCH                     = 2
        NO_PLANT                     = 3
        MATERIAL_NOT_FOUND           = 4
        PLANT_NOT_FOUND              = 5
        STOLOC_NOT_FOUND             = 6
        LOCK_ON_MATERIAL             = 7
        LOCK_ON_PLANT                = 8
        LOCK_ON_BATCH                = 9
        LOCK_SYSTEM_ERROR            = 10
        NO_AUTHORITY                 = 11
        BATCH_EXIST                  = 12
        STOLOC_EXIST                 = 13
        ILLEGAL_BATCH_NUMBER         = 14
        NO_BATCH_HANDLING            = 15
        NO_VALUATION_AREA            = 16
        VALUATION_TYPE_NOT_FOUND     = 17
        NO_VALUATION_FOUND           = 18
        ERROR_AUTOMATIC_BATCH_NUMBER = 19
        CANCELLED                    = 20
        WRONG_STATUS                 = 21
        INTERVAL_NOT_FOUND           = 22
        NUMBER_RANGE_NOT_EXTERN      = 23
        OBJECT_NOT_FOUND             = 24
        ERROR_CHECK_BATCH_NUMBER     = 25
        NO_EXTERNAL_NUMBER           = 26
        NO_CUSTOMER_NUMBER           = 27
        NO_CLASS                     = 28
        ERROR_IN_CLASSIFICATION      = 29
        INCONSISTENCY_IN_KEY         = 30
        REGION_OF_ORIGIN_NOT_FOUND   = 31
        COUNTRY_OF_ORIGIN_NOT_FOUND  = 32
        VENDOR_ERROR                 = 33
        OTHERS                       = 34.

    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      CLEAR: GT_CLS.
      SELECT ATFOR, ATNAM, ATFLV, ATFLB, ATWRT
        FROM ZGTMM_CV_BD_GET_VCOFSO
       WHERE VBELN EQ @P_LINE-TVBELN
         AND POSNR EQ @P_LINE-TPOSNR
         AND WERKS EQ @P_LINE-WERKS
        INTO CORRESPONDING FIELDS OF TABLE @GT_CLS.

      IF GT_CLS IS NOT INITIAL.
        CLEAR: GS_3150.
        SELECT SINGLE *
          FROM ZGTPPT3150
         WHERE JOB_NO      EQ @P_LINE-FBSTNK
           AND LINE_NO     EQ @GV_FLINE_NO
           AND SERIAL_INFO EQ @GV_FSERIAL_INFO
          INTO CORRESPONDING FIELDS OF @GS_3150.

        CLEAR: LV_CNT, GV_ATWRT.
        DO 7 TIMES.
          LV_CNT = LV_CNT + 1.
          CONCATENATE 'GS_3150-ZLENGTH_' LV_CNT INTO LV_FS.
          ASSIGN (LV_FS) TO <LV_FS>.
          REPLACE ALL OCCURRENCES OF ',' IN <LV_FS> WITH ''.
          CONDENSE <LV_FS> NO-GAPS.
          GV_ATWRT = GV_ATWRT + <LV_FS>.
          CONDENSE GV_ATWRT NO-GAPS.
        ENDDO.

        CLEAR : LT_ALLOCVALUESNUMNEW, LT_ALLOCVALUESCHARNEW, LT_ALLOCVALUESCURRNEW.

        LOOP AT GT_CLS INTO GS_CLS.
          PERFORM SET_CLS TABLES LT_ALLOCVALUESNUMNEW.
          PERFORM SET_CLS TABLES LT_ALLOCVALUESCHARNEW.
          PERFORM SET_CLS TABLES LT_ALLOCVALUESCURRNEW.
          CLEAR: GS_CLS.
        ENDLOOP.

        CLEAR : LS_RETURN, LT_RETURN.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE'
          EXPORTING
            OBJECTKEY          = CONV OBJNUM( P_LINE-MATNR && P_LINE-TCHARG )
            OBJECTTABLE        = 'MCH1'
            CLASSNUM           = 'FT_NBD_GENERAL_001'
            CLASSTYPE          = '023'
          TABLES
            ALLOCVALUESNUMNEW  = LT_ALLOCVALUESNUMNEW
            ALLOCVALUESCHARNEW = LT_ALLOCVALUESCHARNEW
            ALLOCVALUESCURRNEW = LT_ALLOCVALUESCURRNEW
            RETURN             = LT_RETURN.

        IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.
          IF LS_RETURN-MESSAGE IS INITIAL.
            P_LINE-RTMSG = TEXT-M17. "배치마스터 생성 도중 오류가 발생하였습니다.
          ELSE.
            P_LINE-RTMSG = LS_RETURN-MESSAGE.
          ENDIF.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = GC_X.

          GV_CHK = GC_X.
        ENDIF.

      ELSE.
        GV_CHK = GC_X.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.
      IF LS_RETURN-MESSAGE IS INITIAL.
        P_LINE-RTMSG = TEXT-M17. "배치마스터 생성 도중 오류가 발생하였습니다.
      ELSE.
        P_LINE-RTMSG = LS_RETURN-MESSAGE.
      ENDIF.

    ENDIF.

  ELSE.
    CLEAR: GT_CLS.
    SELECT ATFOR, ATNAM, ATFLV, ATFLB, ATWRT
      FROM ZGTMM_CV_BD_GET_VCOFSO
     WHERE VBELN EQ @P_LINE-TVBELN
       AND POSNR EQ @P_LINE-TPOSNR
       AND WERKS EQ @P_LINE-WERKS
      INTO CORRESPONDING FIELDS OF TABLE @GT_CLS.

    IF GT_CLS IS NOT INITIAL.
      CLEAR: GS_3150.
      SELECT SINGLE *
        FROM ZGTPPT3150
       WHERE JOB_NO      EQ @P_LINE-FBSTNK
         AND LINE_NO     EQ @GV_FLINE_NO
         AND SERIAL_INFO EQ @GV_FSERIAL_INFO
        INTO CORRESPONDING FIELDS OF @GS_3150.

      CLEAR: LV_CNT, GV_ATWRT.
      DO 7 TIMES.
        LV_CNT = LV_CNT + 1.
        CONCATENATE 'GS_3150-ZLENGTH_' LV_CNT INTO LV_FS.
        ASSIGN (LV_FS) TO <LV_FS>.
        REPLACE ALL OCCURRENCES OF ',' IN <LV_FS> WITH ''.
        CONDENSE <LV_FS> NO-GAPS.
        GV_ATWRT = GV_ATWRT + <LV_FS>.
        CONDENSE GV_ATWRT NO-GAPS.
      ENDDO.

      CLEAR : LT_ALLOCVALUESNUMNEW, LT_ALLOCVALUESCHARNEW, LT_ALLOCVALUESCURRNEW.

      LOOP AT GT_CLS INTO GS_CLS.
        PERFORM SET_CLS TABLES LT_ALLOCVALUESNUMNEW.
        PERFORM SET_CLS TABLES LT_ALLOCVALUESCHARNEW.
        PERFORM SET_CLS TABLES LT_ALLOCVALUESCURRNEW.
        CLEAR: GS_CLS.
      ENDLOOP.

      CLEAR : LS_RETURN, LT_RETURN.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE'
        EXPORTING
          OBJECTKEY          = CONV OBJNUM( P_LINE-MATNR && P_LINE-TCHARG )
          OBJECTTABLE        = 'MCH1'
          CLASSNUM           = 'FT_NBD_GENERAL_001'
          CLASSTYPE          = '023'
        TABLES
          ALLOCVALUESNUMNEW  = LT_ALLOCVALUESNUMNEW
          ALLOCVALUESCHARNEW = LT_ALLOCVALUESCHARNEW
          ALLOCVALUESCURRNEW = LT_ALLOCVALUESCURRNEW
          RETURN             = LT_RETURN.

      IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.
        IF LS_RETURN-MESSAGE IS INITIAL.
          P_LINE-RTMSG = TEXT-M17. "배치마스터 생성 도중 오류가 발생하였습니다.
        ELSE.
          P_LINE-RTMSG = LS_RETURN-MESSAGE.
        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.

        GV_CHK = GC_X.
      ENDIF.

    ELSE.
      GV_CHK = GC_X.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ALLOCVALUESNUMNEW
*&---------------------------------------------------------------------*
FORM SET_CLS  TABLES PT_VAL.

  ASSIGN COMPONENT 'CHARACT' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_ACT>).
  <LFS_ACT> = GS_CLS-ATNAM.

  CASE GS_CLS-ATFOR.
    WHEN 'NUM' OR 'CURR'.
      ASSIGN COMPONENT 'VALUE_FROM' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_FROM>).
      ASSIGN COMPONENT 'VALUE_TO'   OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_TO>).

      CHECK <LFS_FROM> IS ASSIGNED.
      <LFS_FROM> = GS_CLS-ATFLV.
      <LFS_TO>   = GS_CLS-ATFLB.

    WHEN 'CHAR'.
      ASSIGN COMPONENT 'VALUE_CHAR' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_CHAR>).

      CHECK <LFS_CHAR> IS ASSIGNED.
      IF <LFS_ACT> = 'PD_NBD_CM_LENGTH'. "Serial 총길이
        <LFS_CHAR> = GV_ATWRT.
      ELSEIF <LFS_ACT> = 'PD_NBD_CM_WEIGHT'. "Serial 총중량
        <LFS_CHAR> = GS_3150-ZWEIGHT.
        CONDENSE <LFS_CHAR>.
      ELSE.
        <LFS_CHAR> = GS_CLS-ATWRT.
      ENDIF.

    WHEN OTHERS.
      EXIT.

  ENDCASE.

  APPEND PT_VAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTSDT0065
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTSDT0065  USING    P_LINE LIKE GS_DATA.

  UPDATE ZGTSDT0065 SET ZSTAT   = GC_T
                        ZMSG    = TEXT-M18 "이전전기가 완료되었습니다.
                        AENAM   = SY-UNAME
                        AEDAT   = SY-DATUM
                        AEZEIT  = SY-UZEIT
                        AEDATLO = SY-DATLO
                        AETIMLO = SY-TIMLO
                        AETCODE = SY-REPID         "ZGTPPR4010
                  WHERE VBELN = P_LINE-FVBELN
                    AND POSNR = P_LINE-FPOSNR.

  COMMIT WORK.
ENDFORM.
