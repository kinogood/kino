*&---------------------------------------------------------------------*
*& Include          ZGTPPR3100F01
*&---------------------------------------------------------------------*
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
  ID 'WERKS' FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M02 P_WERKS TEXT-M03.
  ENDIF.
ENDFORM.
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
      WHEN 'P_WERKS'.
        SCREEN-REQUIRED = 1.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_R2 EQ GC_X.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF P_R1 EQ GC_X.
    IF P_ABUS EQ GC_X.
      CLEAR: S_GONG[], S_GONG.
      READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_02 = GC_ABUS001.
    ELSEIF P_BUS EQ GC_X.
      CLEAR: S_GONG[], S_GONG.
      READ TABLE GT_1010 INTO LS_1010 WITH KEY FLD_02 = GC_BUS001.
    ELSEIF P_INS EQ GC_X.
      CLEAR: S_GONG[], S_GONG.
      READ TABLE GT_1010 INTO LS_1010 WITH KEY FLD_02 = GC_INS001.
    ELSEIF P_ASM EQ GC_X.
      CLEAR: S_GONG[], S_GONG.
      READ TABLE GT_1010 INTO LS_1010 WITH KEY FLD_02 = GC_ASM001.
    ENDIF.
    IF P_ALL NE GC_X.
      APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_1010-FLD_02 ) TO S_GONG.
    ENDIF.
  ENDIF.

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

  IF P_R1 EQ GC_X.      "외주전환처리
    PERFORM GET_JOB_STATUS.
    PERFORM GET_DATA_C.
  ELSEIF P_R2 EQ GC_X.  "전환결과조회/취소
    PERFORM GET_DATA_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_C .

  CLEAR: GT_DATA.

  SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS, A~ZWEIGHT,
         A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
         A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7, A~CRDAT,
         B~AUFNR, B~COMP_STAT, B~ZMODE, B~OPER_CODE, B~OPER_NAME,
         B~OPER_MATNR, B~MENGE, B~MEINS, B~JOBLS, B~IDNLF,
         B~BSTMG, B~BSTME, B~NETWR, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
         C~VBELN, C~POSNR,
         D~ZPJNO,
         E~MTART, E~MATKL,
         F~NAME1,
         G~MAKTX,
         H~MAKTX AS OPER_MAKTX,
         I~ZPTXT,
         J~FLD_02 AS OPER_CODE_E, J~FLD_03 AS OPER_NAME_E,
         J~FLD_06 AS LEN_ORDGB,
         K~ZJOB_NAME AS JOB_NM
    FROM      ZGTPPT3150           AS A
   INNER JOIN ZGTPPT3160           AS B ON B~JOB_NO      EQ A~JOB_NO
                                       AND B~LINE_NO     EQ A~LINE_NO
                                       AND B~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN ZGTMM_CV_BD_JOBNO_SO AS C ON C~JOB_NO      EQ A~JOB_NO
                                       AND C~LINE_NO     EQ A~LINE_NO
                                       AND C~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN       VBAK           AS D ON D~VBELN       EQ C~VBELN
   INNER JOIN       MARA           AS E ON E~MATNR       EQ B~OPER_MATNR
   INNER JOIN ZGTPPT1010           AS J ON J~MODULE_KIND EQ @GC_PP
                                       AND J~CODEGRP     EQ @GC_2030
                                       AND J~FLD_01      EQ A~WERKS
                                       AND J~FLD_04      EQ B~OPER_CODE
    LEFT OUTER JOIN T001W          AS F ON F~WERKS       EQ A~WERKS
    LEFT OUTER JOIN MAKT           AS G ON G~MATNR       EQ A~MATNR
                                       AND G~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN MAKT           AS H ON H~MATNR       EQ B~OPER_MATNR
                                       AND H~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T       AS I ON I~ZPJNO       EQ D~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121     AS K ON K~ZSYSTEM_ID  EQ @GC_KBDM
                                       AND K~ZWERKS      EQ A~WERKS
                                       AND K~ZJOB_NO     EQ A~JOB_NO
   WHERE A~WERKS       EQ @P_WERKS
     AND A~JOB_NO      IN @S_JOBNO
     AND A~SERIAL_INFO IN @S_SERIAL
     AND A~CRDAT       IN @S_CRDAT
     AND B~AUFNR       IN @S_AUFNR
     AND B~OPER_MATNR  IN @S_OMATNR
     AND C~VBELN       IN @S_VBELN
     AND C~POSNR       IN @S_POSNR
     AND D~ZPJNO       IN @S_ZPJNO
     AND E~MTART       IN @S_MTART
     AND E~MATKL       IN @S_MATKL
     AND B~BESKZ       NE @GC_F    "외주생산품목제외
     AND ( B~ZMODE NE @GC_P AND B~ZMODE NE @GC_K ) "외주전환품목제외
     AND J~FLD_02      IN @S_GONG
     AND B~OPER_CODE IN @S_GONG2
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  IF GT_DATA IS NOT INITIAL.
*-제조지시상태 점검
    IF GR_JOB_NO IS NOT INITIAL.
      DELETE GT_DATA WHERE JOB_NO NOT IN GR_JOB_NO.
    ENDIF.
  ENDIF.

  SORT: GT_DATA BY VBELN POSNR JOB_NO OPER_CODE_E
                   OPER_MATNR LINE_NO SERIAL_INFO PRCSS_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_S .

  CLEAR: GT_DATA.

  SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS, A~ZWEIGHT,
         A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
         A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7, A~CRDAT,
         B~AUFNR, B~COMP_STAT, B~ZMODE, B~OPER_CODE, B~OPER_NAME,
         B~OPER_MATNR, B~MENGE, B~MEINS, B~JOBLS, B~IDNLF,
         B~BSTMG, B~BSTME, B~NETWR, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
         C~VBELN, C~POSNR,
         D~ZPJNO,
         E~MTART, E~MATKL,
         F~NAME1,
         G~MAKTX,
         H~MAKTX AS OPER_MAKTX,
         I~ZPTXT,
         J~FLD_02 AS OPER_CODE_E, J~FLD_03 AS OPER_NAME_E,
         J~FLD_06 AS LEN_ORDGB,
         K~ZJOB_NAME AS JOB_NM
    FROM      ZGTPPT3150           AS A
   INNER JOIN ZGTPPT3160           AS B ON B~JOB_NO      EQ A~JOB_NO
                                       AND B~LINE_NO     EQ A~LINE_NO
                                       AND B~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN ZGTMM_CV_BD_JOBNO_SO AS C ON C~JOB_NO      EQ A~JOB_NO
                                       AND C~LINE_NO     EQ A~LINE_NO
                                       AND C~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN       VBAK           AS D ON D~VBELN       EQ C~VBELN
   INNER JOIN       MARA           AS E ON E~MATNR       EQ B~OPER_MATNR
   INNER JOIN ZGTPPT1010           AS J ON J~MODULE_KIND EQ @GC_PP
                                       AND J~CODEGRP     EQ @GC_2030
                                       AND J~FLD_01      EQ A~WERKS
                                       AND J~FLD_04      EQ B~OPER_CODE
    LEFT OUTER JOIN T001W          AS F ON F~WERKS       EQ A~WERKS
    LEFT OUTER JOIN MAKT           AS G ON G~MATNR       EQ A~MATNR
                                       AND G~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN MAKT           AS H ON H~MATNR       EQ B~OPER_MATNR
                                       AND H~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T       AS I ON I~ZPJNO       EQ D~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121     AS K ON K~ZSYSTEM_ID  EQ @GC_KBDM
                                       AND K~ZWERKS      EQ A~WERKS
                                       AND K~ZJOB_NO     EQ A~JOB_NO
   WHERE A~WERKS       EQ @P_WERKS
     AND A~JOB_NO      IN @S_JOBNO
     AND A~SERIAL_INFO IN @S_SERIAL
     AND A~CRDAT       IN @S_CRDAT
     AND B~OPER_MATNR  IN @S_OMATNR
     AND B~JOBLS       IN @S_JOBLS
     AND C~VBELN       IN @S_VBELN
     AND C~POSNR       IN @S_POSNR
     AND D~ZPJNO       IN @S_ZPJNO
     AND E~MTART       IN @S_MTART
     AND E~MATKL       IN @S_MATKL
     AND ( B~ZMODE EQ @GC_P OR B~ZMODE EQ @GC_K ) "외주전환처리된건만
     AND J~FLD_02      IN @S_GONG
     AND B~OPER_CODE IN @S_GONG2
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  SORT: GT_DATA BY VBELN POSNR JOB_NO OPER_CODE_E
                   OPER_MATNR LINE_NO SERIAL_INFO PRCSS_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOB_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_JOB_STATUS .
  TYPES: BEGIN OF LTY_JOB_STATUS,
           FLD_02 LIKE ZGTPPT1010-FLD_02,
         END OF LTY_JOB_STATUS,
         BEGIN OF LTY_JOB_NO,
           ZJOB_NO LIKE ZGTEDT2121-ZJOB_NO,
         END OF LTY_JOB_NO.

  DATA: LT_JOB_STATUS TYPE TABLE OF LTY_JOB_STATUS,
        LT_JOB_NO     TYPE TABLE OF LTY_JOB_NO.

  CLEAR: LT_JOB_STATUS.
  SELECT FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_2040
     AND FLD_01      EQ @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @LT_JOB_STATUS.

  IF LT_JOB_STATUS IS NOT INITIAL.
    CLEAR: GR_JOB_STATUS, GR_JOB_STATUS[].
    LOOP AT LT_JOB_STATUS INTO DATA(LS_JOB).
      GR_JOB_STATUS-SIGN   = GC_I.
      GR_JOB_STATUS-OPTION = GC_EQ.
      GR_JOB_STATUS-LOW    = LS_JOB-FLD_02.
      APPEND GR_JOB_STATUS.
    ENDLOOP.
  ENDIF.

  IF GR_JOB_STATUS[] IS NOT INITIAL.
    CLEAR: LT_JOB_NO.
    SELECT ZJOB_NO
      FROM ZGTEDT2121
     WHERE ZSYSTEM_ID EQ @GC_KBDM
       AND ZWERKS     EQ @P_WERKS
       AND ZSTATUS    IN @GR_JOB_STATUS
      INTO CORRESPONDING FIELDS OF TABLE @LT_JOB_NO.

    IF LT_JOB_NO IS NOT INITIAL.
      CLEAR: GR_JOB_NO, GR_JOB_NO[].
      LOOP AT LT_JOB_NO INTO DATA(LS_JOB_NO).
        GR_JOB_NO-SIGN   = GC_I.
        GR_JOB_NO-OPTION = GC_EQ.
        GR_JOB_NO-LOW    = LS_JOB_NO-ZJOB_NO.
        APPEND GR_JOB_NO.
      ENDLOOP.
    ENDIF.
  ENDIF.
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
  DATA: BEGIN OF LS_STAT,
          STAT TYPE CHAR100,
        END OF LS_STAT,
        LT_STAT LIKE TABLE OF LS_STAT.

  DATA: LV_FLD_01 TYPE ZGTE_FLDVAL,
        LT_LIST   LIKE TABLE OF ZLES001.

  DATA: L_L1L7   TYPE STRING,
        L_CNT(1).

  FIELD-SYMBOLS: <L_L1L7> TYPE ANY.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_C>).
    IF <FS_C>-AUFNR IS NOT INITIAL.
*-오더상태
      CLEAR: LS_STAT, LT_STAT.
      CALL FUNCTION 'ZGTPP_ORDER_STATUS'
        EXPORTING
          I_AUFNR  = <FS_C>-AUFNR
        IMPORTING
          E_STATUS = <FS_C>-ORDSTAT.
    ENDIF.

    IF <FS_C>-LEN_ORDGB EQ GC_Y AND <FS_C>-ZLENGTH_1 IS NOT INITIAL.
      CLEAR: L_CNT, L_L1L7.
      DO 7 TIMES.
        L_CNT = L_CNT + 1.
        L_L1L7 = '<FS_C>-ZLENGTH_' && L_CNT.
        ASSIGN (L_L1L7) TO <L_L1L7>.

        IF <L_L1L7> IS NOT INITIAL.
          IF L_CNT EQ '1'.
            <FS_C>-L1L7 = <L_L1L7>.
          ELSE.
            <FS_C>-L1L7 = <FS_C>-L1L7 && |,| && <L_L1L7>.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDIF.

    IF <FS_C>-WAERS IS INITIAL.
      <FS_C>-WAERS = GV_WAERS.
    ENDIF.

    IF <FS_C>-ZMODE EQ GC_P OR <FS_C>-ZMODE EQ GC_K.
      <FS_C>-RTID = ICON_LED_GREEN.
    ENDIF.

    IF <FS_C>-ZMODE EQ GC_C AND <FS_C>-JOBLS IS NOT INITIAL.
      CLEAR: <FS_C>-JOBLS.
    ENDIF.

    IF <FS_C>-OPER_CODE_E EQ GC_BUS001 AND
       <FS_C>-OPER_CODE IS NOT INITIAL.
      CLEAR: LV_FLD_01.
      SELECT SINGLE FLD_01
        FROM ZGTPPT1010
       WHERE MODULE_KIND EQ @GC_PP
         AND CODEGRP     EQ @GC_3050
         AND FLD_03      EQ @<FS_C>-OPER_CODE
        INTO @LV_FLD_01.

      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS_C>-VBELN
          I_POSNR                      = <FS_C>-POSNR
          I_OBJECT                     = <FS_C>-MATNR
          I_WERKS                      = <FS_C>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

      READ TABLE LT_LIST INTO DATA(LS_LIST) WITH KEY ATNAM = 'PD_NBD_CM_COND_MAT'.

      <FS_C>-OPER_MATKL = LV_FLD_01 && LS_LIST-ATWRT.

      CLEAR: LS_LIST.

      SELECT SINGLE WGBEZ
        FROM T023T
       WHERE SPRAS EQ @SY-LANGU
         AND MATKL EQ @<FS_C>-OPER_MATKL
        INTO @<FS_C>-OPER_WGBEZ.
    ENDIF.

    READ TABLE GT_1010 INTO DATA(LS_1010)
                       WITH KEY FLD_04 = <FS_C>-OPER_CODE.
    IF SY-SUBRC EQ 0.
      <FS_C>-FLD_07 = LS_1010-FLD_07.
    ENDIF.

*-구매오더번호
    IF P_R2 EQ GC_X.
      SELECT SINGLE EBELN
        FROM ZGTMMT6000
       WHERE JOBLS EQ @<FS_C>-JOBLS
        INTO @<FS_C>-EBELN.
    ENDIF.
  ENDLOOP.

  CLEAR: GT_SDATA.
  APPEND LINES OF GT_DATA TO GT_SDATA.

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
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
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
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3100TOP'
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
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "판매오더번호
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "판매오더품목
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'LINE_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "라인번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'SERIAL_INFO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "시리얼정보
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제품코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "제품내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'OPER_CODE_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "ERP공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "ERP공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'LEN_ORDGB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "길이별 오더구분
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_CODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "MES공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "MES공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'RTID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "처리모드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "처리 메세지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'JOBLS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "MES 요청번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "구매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'OPER_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "생산품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'OPER_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'ORDSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "생산오더상태
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'IDNLF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "외주공정 자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'BSTMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "외주가공수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'BSTME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "외주가공단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'NETWR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "외주가공금액
        <LS_FCAT>-JUST = GC_R.
*        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'WAERS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "금액 단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "생산수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'L1L7'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "L1~L7
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '35'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "제조지시 수신일자
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

    IF <LS_FCAT>-FIELDNAME = 'MATNR' OR <LS_FCAT>-FIELDNAME = 'MAKTX' OR
       <LS_FCAT>-FIELDNAME = 'LEN_ORDGB'.
      <LS_FCAT>-NO_OUT = GC_X.
    ENDIF.

    IF P_R1 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'EBELN'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R2 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'AUFNR' OR <LS_FCAT>-FIELDNAME = 'ORDSTAT'.
        <LS_FCAT>-NO_OUT = GC_X.
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
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
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
         GT_DATA[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

  IF P_WERKS IS NOT INITIAL.
    CLEAR: GV_WAERS.
    SELECT SINGLE WAERS
      FROM T001K AS A
     INNER JOIN T001 AS B ON B~BUKRS EQ A~BUKRS
     WHERE BWKEY EQ @P_WERKS
      INTO @GV_WAERS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDDEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ORDDEL .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_DATA.

  DATA: BEGIN OF LS_STAT,
          STAT TYPE CHAR100,
        END OF LS_STAT,
        LT_STAT LIKE TABLE OF LS_STAT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "생산오더 삭제 설정
      TEXT_QUESTION         = TEXT-T05 "생산오더 삭제 설정을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS INITIAL.
        <FS_S>-RTMSG = TEXT-M04. "생산오더가 없습니다.
      ELSE.
        IF <FS_S>-ORDSTAT IS NOT INITIAL.
          CLEAR: LS_STAT, LT_STAT.
          SPLIT <FS_S>-ORDSTAT AT '/' INTO TABLE LT_STAT.

          IF LINE_EXISTS( LT_STAT[ STAT = 'CNF' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'DLV' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'PCNF' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'PDLV' ] ).
            <FS_S>-RTMSG = TEXT-M05. "실적이 입력된 생산오더는 삭제 설정이 불가합니다.
          ELSE.
*- 선택한 데이터
            APPEND <FS_S> TO LT_SEL.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 오더 기준으로 중복 제거
    SORT LT_SEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL COMPARING AUFNR.

*-선택한 데이터를 오더 기준으로 삭제 플래그 설정
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_ORD_DELETE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    CLEAR: GT_AUFNR_SEND.
    LOOP AT GT_DATA ASSIGNING <FS_S> WHERE AUFNR IS NOT INITIAL.
      READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
      IF SY-SUBRC EQ 0.
        <FS_S>-RTID = LS_SEL-RTID.
        <FS_S>-RTMSG = LS_SEL-RTMSG.

*-처리 결과 DB 업데이트(성공건만)
        IF LS_SEL-RTID EQ ICON_LED_GREEN.
          UPDATE ZGTPPT3160 SET AUFNR = SPACE
                                COMP_STAT = SPACE
                          WHERE AUFNR = <FS_S>-AUFNR.
          COMMIT WORK.

*-전송할 생산오더
          GS_AUFNR_SEND-AUFNR = <FS_S>-AUFNR.
          SELECT SINGLE ERDAT
            FROM AUFK
           WHERE AUFNR EQ @<FS_S>-AUFNR
            INTO @GS_AUFNR_SEND-ERDAT.

          COLLECT GS_AUFNR_SEND INTO GT_AUFNR_SEND.
          CLEAR: GS_AUFNR_SEND.

          CLEAR: <FS_S>-AUFNR, <FS_S>-COMP_STAT.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-생산오더 송신
    IF GT_AUFNR_SEND IS NOT INITIAL.
      PERFORM SUBMIT_ZGTPPI2010.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

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
*& Form EXEC_ORD_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ORD_DELETE  USING    P_LINE LIKE GS_DATA.

  DATA: LT_ORDERS	       TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN OCCURS 0 WITH HEADER LINE.

  CLEAR: LT_DETAIL_RETURN, LT_DETAIL_RETURN[], LT_ORDERS, LT_ORDERS[].

  LT_ORDERS-ORDER_NUMBER = P_LINE-AUFNR.
  APPEND LT_ORDERS.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    EXPORTING
      WORK_PROCESS_GROUP = 'COWORK_BAPI'
      WORK_PROCESS_MAX   = 99
    TABLES
      ORDERS             = LT_ORDERS
      DETAIL_RETURN      = LT_DETAIL_RETURN.

  READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = GC_E.
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-RTID = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M06. "생산오더 삭제 설정에 성공하였습니다.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = 'E'.

    P_LINE-RTID = ICON_LED_RED.
    P_LINE-RTMSG = LT_DETAIL_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_0100.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXPRCCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXPRCCRE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_MODEP LIKE TABLE OF GS_DATA.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

*  IF LINES( LT_ROW_NO ) > 1.
*    MESSAGE S003 DISPLAY LIKE GC_W
*       WITH TEXT-M07. "외주 전환은 1건씩 선택하세요.
*    EXIT.
*  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T06 "외주 전환 처리
      TEXT_QUESTION         = TEXT-T07 "외주 전환 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GT_JOBLS_SEND.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS NOT INITIAL.
        <FS_S>-RTMSG = TEXT-M08. "생산 오더 삭제 설정 후 진행 가능합니다.
      ELSE.
        IF <FS_S>-ZMODE EQ GC_P OR <FS_S>-ZMODE EQ GC_K.
          <FS_S>-RTMSG = TEXT-M09. "이미 외주 전환 처리를 수행한 시리얼입니다.
        ELSE.
          IF <FS_S>-FLD_07 IS NOT INITIAL AND
             ( <FS_S>-OPER_CODE IS INITIAL OR <FS_S>-OPER_WGBEZ IS INITIAL ).
            <FS_S>-RTMSG = TEXT-M22. "존재하지 않는 공정 코드입니다.
          ELSE.
            IF <FS_S>-FLD_07 IS NOT INITIAL AND <FS_S>-BSTMG EQ 0.
              <FS_S>-RTMSG = TEXT-M24. "비용성 구매 전환의 경우 외주가공수량이 필수입니다.
            ELSEIF <FS_S>-FLD_07 IS INITIAL AND <FS_S>-NETWR EQ 0.
              <FS_S>-RTMSG = TEXT-M23. "임가공 구매 전환의 경우 외주가공금액이 필수입니다.
            ELSE.
* 도체가공 체크 로직 주석(20250526)
*              IF <FS_S>-OPER_CODE_E EQ GC_BUS001.
*                CLEAR: LT_MODEP.
*                SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS, A~ZWEIGHT,
*                       A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
*                       A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7,
*                       B~AUFNR, B~COMP_STAT, B~ZMODE, B~OPER_CODE, B~OPER_NAME,
*                       B~OPER_MATNR, B~MENGE, B~MEINS, B~JOBLS, B~IDNLF,
*                       B~BSTMG, B~BSTME, B~NETWR, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
*                       C~VBELN, C~POSNR,
*                       D~ZPJNO,
*                       E~MTART, E~MATKL
*                  FROM      ZGTPPT3150           AS A
*                 INNER JOIN ZGTPPT3160           AS B ON B~JOB_NO      EQ A~JOB_NO
*                                                     AND B~LINE_NO     EQ A~LINE_NO
*                                                     AND B~SERIAL_INFO EQ A~SERIAL_INFO
*                 INNER JOIN ZGTMM_CV_BD_JOBNO_SO AS C ON C~JOB_NO      EQ A~JOB_NO
*                                                     AND C~LINE_NO     EQ A~LINE_NO
*                                                     AND C~SERIAL_INFO EQ A~SERIAL_INFO
*                 INNER JOIN VBAK                 AS D ON D~VBELN       EQ C~VBELN
*                 INNER JOIN MARA                 AS E ON E~MATNR       EQ B~OPER_MATNR
*                 WHERE A~WERKS      EQ @<FS_S>-WERKS
*                   AND B~OPER_MATNR EQ @<FS_S>-OPER_MATNR
*                   AND C~VBELN      EQ @<FS_S>-VBELN
*                   AND C~POSNR      EQ @<FS_S>-POSNR
*                   AND B~BESKZ      NE @GC_F
*                   AND ( B~ZMODE NE @GC_P AND B~ZMODE NE @GC_K )  "외주전환처리안된건만
*                  INTO CORRESPONDING FIELDS OF TABLE @LT_MODEP.
*
*                IF LINES( LT_MODEP ) LE 1.
*                  "도체가공의 경우 전체 공정을 외주 전환하려면 "도체가공 전체 외주 전환" 버튼을 사용하십시요.
*                  <FS_S>-RTMSG = TEXT-M20.
*                ELSE.
*                  PERFORM EXEC_EXPRC_CRE USING <FS_S>.
*                ENDIF.
*              ELSE.
              PERFORM EXEC_EXPRC_CRE USING <FS_S>.
*              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-외주 전환 결과 송신
    IF GT_JOBLS_SEND IS NOT INITIAL.
      PERFORM SUBMIT_ZGTPPI3090.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_EXPRC_CRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_EXPRC_CRE  USING    P_LINE LIKE GS_DATA.

  DATA: LV_ZMODE LIKE ZGTPPT3160-ZMODE,
        LV_BESKZ LIKE ZGTPPT3160-BESKZ.

  CLEAR: GV_JOBLS.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '02'
      OBJECT                  = 'ZGTMM_JOBL'
    IMPORTING
      NUMBER                  = GV_JOBLS
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF GV_JOBLS IS INITIAL.
    P_LINE-RTMSG = TEXT-M10. "제조지시 요청번호 채번 오류
  ENDIF.

  CHECK GV_JOBLS IS NOT INITIAL.

  CLEAR: GV_07, GV_SAKTO, GV_KOSTL.
  SELECT SINGLE FLD_07, FLD_08, FLD_09
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_2030
     AND FLD_01      EQ @P_LINE-WERKS
     AND FLD_04      EQ @P_LINE-OPER_CODE
    INTO (@GV_07, @GV_SAKTO, @GV_KOSTL).

  PERFORM CONVERSION_EXIT_ALPHA USING GV_SAKTO GC_I.
  PERFORM CONVERSION_EXIT_ALPHA USING GV_KOSTL GC_I.

  CLEAR: LV_ZMODE.
  IF GV_07 EQ SPACE.
    LV_ZMODE = GC_P.
  ELSE.
    LV_ZMODE = GC_K.
  ENDIF.

  CLEAR: LV_BESKZ.
  IF P_LINE-OPER_CODE EQ GC_SC.
    LV_BESKZ = GC_X.
  ELSE.
    LV_BESKZ = GC_F.
  ENDIF.

  UPDATE ZGTPPT3160 SET ZMODE = LV_ZMODE
                        BESKZ = LV_BESKZ
                        JOBLS = GV_JOBLS
                        CHDAT = SY-DATUM
                        CHTIM = SY-UZEIT
                        CHNAM = SY-UNAME
                  WHERE JOB_NO        = P_LINE-JOB_NO
                    AND LINE_NO       = P_LINE-LINE_NO
                    AND SERIAL_INFO   = P_LINE-SERIAL_INFO
                    AND PRCSS_SEQ     = P_LINE-PRCSS_SEQ
                    AND PRCSS_SUB_SEQ = P_LINE-PRCSS_SUB_SEQ.

  IF SY-SUBRC EQ 0.
    PERFORM SET_ZGTMMT6210 USING P_LINE.

    MODIFY ZGTMMT6210 FROM TABLE GT_ZGTMMT6210.

    IF SY-SUBRC EQ 0.
      PERFORM SET_ZGTMMT6211 USING P_LINE.

      IF GT_ZGTMMT6211 IS NOT INITIAL.
        MODIFY ZGTMMT6211 FROM TABLE GT_ZGTMMT6211.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          P_LINE-RTID = ICON_LED_GREEN.
          P_LINE-RTMSG = TEXT-M11. "외주 전환 처리에 성공하였습니다.
          P_LINE-ZMODE = LV_ZMODE.
          P_LINE-JOBLS = GV_JOBLS.
          P_LINE-BESKZ = GC_F.

*-전송할 외주 전환 요청 번호
          GS_JOBLS_SEND-JOBLS = P_LINE-JOBLS.
          COLLECT GS_JOBLS_SEND INTO GT_JOBLS_SEND.
          CLEAR: GS_JOBLS_SEND.

        ELSE.
          ROLLBACK WORK.
          P_LINE-RTMSG = TEXT-M12. "외주 전환 처리 도중 오류가 발생하였습니다.
        ENDIF.
      ELSE.
        COMMIT WORK.
        P_LINE-RTID = ICON_LED_GREEN.
        P_LINE-RTMSG = TEXT-M11. "외주 전환 처리에 성공하였습니다.
        P_LINE-ZMODE = LV_ZMODE.
        P_LINE-JOBLS = GV_JOBLS.
        P_LINE-BESKZ = GC_F.

*-전송할 외주 전환 요청 번호
        GS_JOBLS_SEND-JOBLS = P_LINE-JOBLS.
        COLLECT GS_JOBLS_SEND INTO GT_JOBLS_SEND.
        CLEAR: GS_JOBLS_SEND.

      ENDIF.
    ELSE.
      ROLLBACK WORK.
      P_LINE-RTMSG = TEXT-M12. "외주 전환 처리 도중 오류가 발생하였습니다.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    P_LINE-RTMSG = TEXT-M12. "외주 전환 처리 도중 오류가 발생하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZGTMMT6210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SET_ZGTMMT6210  USING    P_LINE LIKE GS_DATA.

  IF GV_07 IS INITIAL.
    PERFORM SET_DATA_ZGTMMT6210 USING P_LINE P_LINE-MTART.
  ELSE.
    PERFORM SET_DATA_ZGTMMT6210 USING P_LINE SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_ZGTMMT6210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&      --> GC_FERT
*&---------------------------------------------------------------------*
FORM SET_DATA_ZGTMMT6210  USING    P_LINE LIKE GS_DATA
                                   P_MTART TYPE MTART.

  DATA: LS_ZGTMMT6210 LIKE ZGTMMT6210.

  DATA: LS_USER_USR03 LIKE USR03.

  DATA: LV_FLD_01 TYPE ZGTE_FLDVAL,
        LT_LIST   LIKE TABLE OF ZLES001.

  CLEAR: GV_MREQ.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZGTPP_MREQ'
    IMPORTING
      NUMBER                  = GV_MREQ
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF GV_MREQ IS INITIAL.
    P_LINE-RTMSG = TEXT-M21. "MES 요청번호 채번 오류
  ENDIF.

  CLEAR: GT_ZGTMMT6210.

  LS_ZGTMMT6210-JOBLS       = GV_JOBLS.
  LS_ZGTMMT6210-MES_REQ     = GV_MREQ.
  LS_ZGTMMT6210-MES_SEQ     = GV_MSEQ.                      "00000001
  LS_ZGTMMT6210-JOB_NO      = P_LINE-JOB_NO.
  LS_ZGTMMT6210-LINE_NO     = P_LINE-LINE_NO.
  LS_ZGTMMT6210-SERIAL_INFO = P_LINE-SERIAL_INFO.
  LS_ZGTMMT6210-ORDCH       = GC_X.
  LS_ZGTMMT6210-BSTYP       = GC_F.
  LS_ZGTMMT6210-EKORG       = GC_1100.

  CLEAR: LS_USER_USR03.
  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
    EXPORTING
      USER_NAME              = SY-UNAME
    IMPORTING
      USER_USR03             = LS_USER_USR03
    EXCEPTIONS
      USER_ADDRESS_NOT_FOUND = 1
      OTHERS                 = 2.

  LS_ZGTMMT6210-AFNAM       = LS_USER_USR03-NAME2.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = SY-DATLO
      DAYS      = '02'
      MONTHS    = '00'
      SIGNUM    = '+'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = LS_ZGTMMT6210-EINDT.

  LS_ZGTMMT6210-WERKS       = P_LINE-WERKS.
  LS_ZGTMMT6210-ABLAD       = TEXT-T13.         "부스닥트
  LS_ZGTMMT6210-VBELN       = P_LINE-VBELN.
  LS_ZGTMMT6210-VBELP       = P_LINE-POSNR.
  LS_ZGTMMT6210-WAERS       = P_LINE-WAERS.
  LS_ZGTMMT6210-ERDAT       = SY-DATUM.
  LS_ZGTMMT6210-ERDAT_LOCAL = SY-DATLO.
  LS_ZGTMMT6210-ERTIM       = SY-UZEIT.
  LS_ZGTMMT6210-ERTIM_LOCAL = SY-TIMLO.
  LS_ZGTMMT6210-ERNAM       = SY-UNAME.
  LS_ZGTMMT6210-ZWEIGHT     = P_LINE-ZWEIGHT.
  LS_ZGTMMT6210-ZLENGTH_1   = P_LINE-ZLENGTH_1.
  LS_ZGTMMT6210-ZLENGTH_2   = P_LINE-ZLENGTH_2.
  LS_ZGTMMT6210-ZLENGTH_3   = P_LINE-ZLENGTH_3.
  LS_ZGTMMT6210-ZLENGTH_4   = P_LINE-ZLENGTH_4.
  LS_ZGTMMT6210-ZLENGTH_5   = P_LINE-ZLENGTH_5.
  LS_ZGTMMT6210-ZLENGTH_6   = P_LINE-ZLENGTH_6.
  LS_ZGTMMT6210-ZLENGTH_7   = P_LINE-ZLENGTH_7.

  IF GV_07 IS INITIAL.
    LS_ZGTMMT6210-PSTYP = GC_3.
    LS_ZGTMMT6210-KNTTP = GC_M.
    LS_ZGTMMT6210-MENGE = P_LINE-MENGE.
    LS_ZGTMMT6210-MEINS = P_LINE-MEINS.
    LS_ZGTMMT6210-EXPRC = GC_X.
    LS_ZGTMMT6210-MATNR = P_LINE-OPER_MATNR.
    LS_ZGTMMT6210-SOBKZ = GC_E.
    LS_ZGTMMT6210-NETWR = P_LINE-NETWR.
    LS_ZGTMMT6210-BSTMG = P_LINE-BSTMG.
    LS_ZGTMMT6210-BSTME = P_LINE-BSTME.

    IF P_MTART EQ GC_FERT.
      LS_ZGTMMT6210-EKGRP = GC_F60.
      LS_ZGTMMT6210-LGORT = GC_2550.
    ELSEIF P_MTART EQ GC_HALB.
      LS_ZGTMMT6210-EKGRP = GC_H60.
      LS_ZGTMMT6210-LGORT = GC_2540.
    ENDIF.

  ELSE.
    LS_ZGTMMT6210-PSTYP = GC_0.
    LS_ZGTMMT6210-KNTTP = GC_K.
    LS_ZGTMMT6210-EKGRP = GC_H60.
    LS_ZGTMMT6210-MENGE = P_LINE-BSTMG.
    LS_ZGTMMT6210-MEINS = P_LINE-BSTME.
    LS_ZGTMMT6210-EXPRC = SPACE.
    LS_ZGTMMT6210-IDNLF = P_LINE-OPER_MATKL.
    LS_ZGTMMT6210-BSTMG = P_LINE-BSTMG.
    LS_ZGTMMT6210-BSTME = P_LINE-BSTME.
    LS_ZGTMMT6210-SAKTO = GV_SAKTO.
    LS_ZGTMMT6210-KOSTL = GV_KOSTL.
    LS_ZGTMMT6210-MATKL = P_LINE-OPER_MATKL.
    LS_ZGTMMT6210-TXZ01 = P_LINE-OPER_WGBEZ.

  ENDIF.

  APPEND LS_ZGTMMT6210 TO GT_ZGTMMT6210.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZGTMMT6211
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SET_ZGTMMT6211  USING    P_LINE LIKE GS_DATA.

  DATA: LT_ZGTPPT3170 LIKE TABLE OF ZGTPPT3170,
        LS_ZGTMMT6211 LIKE ZGTMMT6211.

  DATA: L_CNT TYPE ZGTE_BD_MES_CMP.

  CLEAR: LT_ZGTPPT3170.
  SELECT *
    FROM ZGTPPT3170
   WHERE JOB_NO        EQ @P_LINE-JOB_NO
     AND LINE_NO       EQ @P_LINE-LINE_NO
     AND SERIAL_INFO   EQ @P_LINE-SERIAL_INFO
     AND PRCSS_SEQ     EQ @P_LINE-PRCSS_SEQ
     AND PRCSS_SUB_SEQ EQ @P_LINE-PRCSS_SUB_SEQ
    INTO CORRESPONDING FIELDS OF TABLE @LT_ZGTPPT3170.

  CLEAR: GT_ZGTMMT6211, L_CNT.
  LOOP AT LT_ZGTPPT3170 INTO DATA(LS_3170).
    L_CNT = L_CNT + 1.

    MOVE: GV_JOBLS      TO LS_ZGTMMT6211-JOBLS,
          L_CNT         TO LS_ZGTMMT6211-MES_CMP,
          GV_MREQ       TO LS_ZGTMMT6211-MES_REQ,
          GV_MSEQ       TO LS_ZGTMMT6211-MES_SEQ,
          P_LINE-JOB_NO TO LS_ZGTMMT6211-JOB_NO,
          LS_3170-MATNR TO LS_ZGTMMT6211-MATNR,
          LS_3170-MEINS TO LS_ZGTMMT6211-MEINS,
          SY-DATUM      TO LS_ZGTMMT6211-ERDAT,
          SY-DATLO      TO LS_ZGTMMT6211-ERDAT_LOCAL,
          SY-UZEIT      TO LS_ZGTMMT6211-ERTIM,
          SY-TIMLO      TO LS_ZGTMMT6211-ERTIM_LOCAL,
          SY-UNAME      TO LS_ZGTMMT6211-ERNAM.

    LS_ZGTMMT6211-BDMNG = LS_3170-MENGE * ( 1 + ( LS_3170-KAUSF / 100 ) ).

    APPEND LS_ZGTMMT6211 TO GT_ZGTMMT6211.
    CLEAR: LS_ZGTMMT6211.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUBMIT_ZGTPPI3090
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SUBMIT_ZGTPPI3090.

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME VALUE 'ZGTPPI3090',
         LV_JOBNAME2 LIKE TBTCJOB-JOBNAME,
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
         LV_RELEASED LIKE BTCH0000-CHAR1,
         LV_UZEIT    LIKE SY-UZEIT.

  CLEAR: LV_JOBNAME2.
  LV_JOBNAME2 = LV_JOBNAME && |_| && SY-DATUM && |_| && SY-UZEIT.

  CLEAR: LV_JOBCOUNT.
  DO.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = LV_JOBNAME2
      IMPORTING
        JOBCOUNT         = LV_JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.
    IF SY-SUBRC EQ 0.
      EXIT.
    ENDIF.
  ENDDO.

  CLEAR: LT_SELTAB[].
  LT_SELTAB = VALUE #(
  ( SELNAME = 'P_WERKS' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = P_WERKS )
  ( SELNAME = 'P_R1' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
  ( SELNAME = 'P_R8' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' ) ).

  SORT GT_JOBLS_SEND BY JOBLS.
  LOOP AT GT_JOBLS_SEND INTO GS_JOBLS_SEND.
    APPEND VALUE #( SELNAME = 'S_JOBLS' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = GS_JOBLS_SEND-JOBLS )
        TO LT_SELTAB.
  ENDLOOP.

  SUBMIT ZGTPPI3090 VIA JOB LV_JOBNAME2
                    NUMBER LV_JOBCOUNT
                    WITH SELECTION-TABLE LT_SELTAB
                    AND RETURN.

  CLEAR: LV_UZEIT.
  LV_UZEIT = SY-UZEIT + 10.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = LV_JOBCOUNT
      JOBNAME              = LV_JOBNAME2
      SDLSTRTDT            = SY-DATUM
      SDLSTRTTM            = LV_UZEIT
      STRTIMMED            = 'X'  "즉시 기동
    IMPORTING
      JOB_WAS_RELEASED     = LV_RELEASED
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXPRCCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXPRCCAN .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T08 "외주 전환 처리 취소
      TEXT_QUESTION         = TEXT-T09 "외주 전환 처리를 취소하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GT_JOBLS_SEND.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ZMODE NE GC_P AND <FS_S>-ZMODE NE GC_K.
        <FS_S>-RTMSG = TEXT-M13. "외주 전환 처리가 이미 취소된 레코드입니다.
      ELSE.
        IF <FS_S>-EBELN IS NOT INITIAL.
          <FS_S>-RTMSG = TEXT-M14. "이미 구매오더로 전환된 상태이므로 취소가 불가합니다.
        ELSE.
          PERFORM EXEC_EXPRC_CAN USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-외주 전환 결과 송신
    IF GT_JOBLS_SEND IS NOT INITIAL.
      PERFORM SUBMIT_ZGTPPI3090.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_EXPRC_CAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_EXPRC_CAN  USING    P_LINE LIKE GS_DATA.

  UPDATE ZGTPPT3160 SET ZMODE = GC_C
                        BESKZ = GC_E
*                        JOBLS = SPACE
                        CHDAT = SY-DATUM
                        CHTIM = SY-UZEIT
                        CHNAM = SY-UNAME
                  WHERE JOBLS = P_LINE-JOBLS.

  IF SY-SUBRC EQ 0.
    DELETE FROM ZGTMMT6210 WHERE JOBLS = P_LINE-JOBLS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE JOBLS
        FROM ZGTMMT6211
       WHERE JOBLS EQ @P_LINE-JOBLS
        INTO @DATA(LV_JOBLS).

      IF SY-SUBRC EQ 0.
        DELETE FROM ZGTMMT6211 WHERE JOBLS = P_LINE-JOBLS.
        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          P_LINE-RTID = ICON_LED_GREEN.
          P_LINE-RTMSG = TEXT-M15. "외주 전환 처리를 취소하였습니다.
          P_LINE-ZMODE = GC_C.
          P_LINE-BESKZ = GC_E.

*-전송할 외주 전환 요청 번호
          GS_JOBLS_SEND-JOBLS = P_LINE-JOBLS.
          COLLECT GS_JOBLS_SEND INTO GT_JOBLS_SEND.
          CLEAR: GS_JOBLS_SEND.

          CLEAR: P_LINE-JOBLS.
        ELSE.
          ROLLBACK WORK.
          P_LINE-RTMSG = TEXT-M16. "외주 전환 처리 취소 도중 오류가 발생하였습니다.
        ENDIF.
      ELSE.
        COMMIT WORK.
        P_LINE-RTID = ICON_LED_GREEN.
        P_LINE-RTMSG = TEXT-M15. "외주 전환 처리를 취소하였습니다.
        P_LINE-ZMODE = GC_C.
        P_LINE-BESKZ = GC_E.

*-전송할 외주 전환 요청 번호
        GS_JOBLS_SEND-JOBLS = P_LINE-JOBLS.
        COLLECT GS_JOBLS_SEND INTO GT_JOBLS_SEND.
        CLEAR: GS_JOBLS_SEND.

        CLEAR: P_LINE-JOBLS.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      P_LINE-RTMSG = TEXT-M16. "외주 전환 처리 취소 도중 오류가 발생하였습니다.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    P_LINE-RTMSG = TEXT-M16. "외주 전환 처리 취소 도중 오류가 발생하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BUSEXPRCCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BUSEXPRCCRE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_DATA  LIKE TABLE OF GS_DATA,
        LT_DATA1 LIKE TABLE OF GS_DATA,
        LT_SEL   LIKE TABLE OF GS_DATA,
        LT_JOBLS LIKE TABLE OF GS_DATA,
        LS_MODEP LIKE GS_DATA.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T10 "도체가공 공정 전체 외주 전환
      TEXT_QUESTION         = TEXT-T11 "도체가공 공정에 대해 전체 외주 전환을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-OPER_CODE_E NE GC_BUS001.
        <FS_S>-RTMSG = TEXT-M18. "도체가공 공정만 전체 외주 전환 처리가 가능합니다.
      ELSE.
        CLEAR: LS_MODEP.
        SELECT SINGLE
               A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS, A~ZWEIGHT,
               A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
               A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7,
               B~AUFNR, B~COMP_STAT, B~ZMODE, B~OPER_CODE, B~OPER_NAME,
               B~OPER_MATNR, B~MENGE, B~MEINS, B~JOBLS, B~IDNLF,
               B~BSTMG, B~BSTME, B~NETWR, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
               C~VBELN, C~POSNR,
               D~ZPJNO,
               E~MTART, E~MATKL
          FROM      ZGTPPT3150           AS A
         INNER JOIN ZGTPPT3160           AS B ON B~JOB_NO      EQ A~JOB_NO
                                             AND B~LINE_NO     EQ A~LINE_NO
                                             AND B~SERIAL_INFO EQ A~SERIAL_INFO
         INNER JOIN ZGTMM_CV_BD_JOBNO_SO AS C ON C~JOB_NO      EQ A~JOB_NO
                                             AND C~LINE_NO     EQ A~LINE_NO
                                             AND C~SERIAL_INFO EQ A~SERIAL_INFO
         INNER JOIN VBAK                 AS D ON D~VBELN       EQ C~VBELN
         INNER JOIN MARA                 AS E ON E~MATNR       EQ B~OPER_MATNR
         WHERE A~WERKS      EQ @<FS_S>-WERKS
           AND A~ZLENGTH_1  EQ @<FS_S>-ZLENGTH_1
           AND A~ZLENGTH_2  EQ @<FS_S>-ZLENGTH_2
           AND A~ZLENGTH_3  EQ @<FS_S>-ZLENGTH_3
           AND A~ZLENGTH_4  EQ @<FS_S>-ZLENGTH_4
           AND A~ZLENGTH_5  EQ @<FS_S>-ZLENGTH_5
           AND A~ZLENGTH_6  EQ @<FS_S>-ZLENGTH_6
           AND A~ZLENGTH_7  EQ @<FS_S>-ZLENGTH_7
           AND B~OPER_MATNR EQ @<FS_S>-OPER_MATNR
           AND C~VBELN      EQ @<FS_S>-VBELN
           AND C~POSNR      EQ @<FS_S>-POSNR
           AND ( B~ZMODE EQ @GC_P OR B~ZMODE EQ @GC_K ) "외주전환처리된건만
          INTO CORRESPONDING FIELDS OF @LS_MODEP.

        IF LS_MODEP IS NOT INITIAL.
          "이미 도체가공 공정 중 일부가 외주 전환되어 전체 외주 전환이 불가합니다.
          <FS_S>-RTMSG = TEXT-M19.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_SEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 판매오더+품목+생산품목+L1L7 기준으로 중복 제거
    SORT LT_SEL BY VBELN POSNR OPER_MATNR L1L7.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING VBELN POSNR OPER_MATNR L1L7.

    SORT LT_SEL BY VBELN POSNR JOB_NO LINE_NO SERIAL_INFO.

*-선택된 데이터를 기준으로 나머지 데이터 append 및 수량 체크
    CLEAR: LT_DATA.
    LOOP AT LT_SEL INTO DATA(LS_SEL).
      LOOP AT GT_SDATA INTO DATA(LS_SDATA) WHERE VBELN       = LS_SEL-VBELN
                                             AND POSNR       = LS_SEL-POSNR
                                             AND OPER_MATNR  = LS_SEL-OPER_MATNR
                                             AND OPER_CODE_E = LS_SEL-OPER_CODE_E
                                             AND L1L7        = LS_SEL-L1L7.

        MOVE-CORRESPONDING LS_SDATA TO GS_DATA.

        IF LS_SDATA-FLD_07 IS NOT INITIAL AND LS_SDATA-BSTMG EQ 0.
          GS_DATA-RTMSG = TEXT-M24. "비용성 구매 전환의 경우 외주가공수량이 필수입니다.
        ENDIF.

        APPEND GS_DATA TO LT_DATA.
        CLEAR: GS_DATA.
      ENDLOOP.
    ENDLOOP.

    CLEAR: LT_DATA1.
    APPEND LINES OF LT_DATA TO LT_DATA1.

*-오류 메세지만 남김
    SORT LT_DATA1 BY RTMSG.
    DELETE LT_DATA1 WHERE RTMSG IS INITIAL.

    SORT LT_DATA1 BY VBELN POSNR OPER_MATNR L1L7.
    DELETE ADJACENT DUPLICATES FROM LT_DATA1
                          COMPARING VBELN POSNR OPER_MATNR L1L7.

*-선택된 데이터 외 오류 메세지 update
    LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<LS>).
      READ TABLE LT_DATA1 INTO DATA(LS1) WITH KEY VBELN       = <LS>-VBELN
                                                  POSNR       = <LS>-POSNR
                                                  OPER_MATNR  = <LS>-OPER_MATNR
                                                  L1L7        = <LS>-L1L7.
      IF SY-SUBRC EQ 0 AND LS1-RTMSG IS NOT INITIAL.
        <LS>-RTMSG = LS1-RTMSG.
      ENDIF.
    ENDLOOP.

    SORT LT_DATA BY VBELN POSNR JOB_NO LINE_NO SERIAL_INFO.

*-데이터 처리
    CLEAR: GT_JOBLS_SEND.
    LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<FS_SEL>) WHERE RTMSG IS INITIAL.
      PERFORM EXEC_EXPRC_CRE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_DATA ASSIGNING <FS_S> WHERE RTID NE ICON_LED_GREEN
                                       AND JOBLS EQ SPACE.

      READ TABLE LT_DATA INTO DATA(LS_DATA) WITH KEY VBELN         = <FS_S>-VBELN
                                                     POSNR         = <FS_S>-POSNR
                                                     OPER_MATNR    = <FS_S>-OPER_MATNR
                                                     L1L7          = <FS_S>-L1L7
                                                     JOB_NO        = <FS_S>-JOB_NO
                                                     LINE_NO       = <FS_S>-LINE_NO
                                                     SERIAL_INFO   = <FS_S>-SERIAL_INFO
                                                     PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                                                     PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.

      IF SY-SUBRC EQ 0.
        IF LS_DATA-JOBLS IS NOT INITIAL.
          <FS_S>-RTID  = LS_DATA-RTID.
          <FS_S>-RTMSG = LS_DATA-RTMSG.
          <FS_S>-ZMODE = LS_DATA-ZMODE.
          <FS_S>-JOBLS = LS_DATA-JOBLS.
          IF <FS_S>-OPER_CODE EQ GC_SC.
            <FS_S>-BESKZ = GC_X.
          ELSE.
            <FS_S>-BESKZ = GC_F.
          ENDIF.

*-도체가공 전체 외주 전환 UPDATE 재처리
          UPDATE ZGTPPT3160 SET ZMODE = <FS_S>-ZMODE
                                BESKZ = <FS_S>-BESKZ
                                JOBLS = <FS_S>-JOBLS
                                CHDAT = SY-DATUM
                                CHTIM = SY-UZEIT
                                CHNAM = SY-UNAME
                          WHERE JOB_NO        = <FS_S>-JOB_NO
                            AND LINE_NO       = <FS_S>-LINE_NO
                            AND SERIAL_INFO   = <FS_S>-SERIAL_INFO
                            AND PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                            AND PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.

          COMMIT WORK.

        ELSE.
          <FS_S>-RTMSG = LS_DATA-RTMSG.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-외주 전환 결과 송신
    IF GT_JOBLS_SEND IS NOT INITIAL.
      PERFORM SUBMIT_ZGTPPI3090.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_GONG_LOW
*&---------------------------------------------------------------------*
FORM F4_GONG_CD  USING    PV_GONG.

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.

  SELECT DISTINCT FLD_02, FLD_03 INTO TABLE @DATA(LT_1010)
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ @GC_PP
      AND CODEGRP EQ @GC_2030
      AND FLD_01 EQ @LV_WERKS.

  SORT LT_1010 BY FLD_02.
  DELETE ADJACENT DUPLICATES FROM LT_1010 COMPARING FLD_02.

  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'ZGTPPT1010'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  APPEND LS_FIELD TO LT_FIELDS.

  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.
      WHEN 'FLD_02'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = 'ERP 공정'.
        <LS_FIELD>-SCRTEXT_M = 'ERP 공정'.
        <LS_FIELD>-SCRTEXT_L = 'ERP 공정'.
        <LS_FIELD>-REPTEXT   = 'ERP 공정'.
      WHEN 'FLD_03'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 40.
        <LS_FIELD>-SCRTEXT_S = 'ERP 공정내역'.
        <LS_FIELD>-SCRTEXT_M = 'ERP 공정내역'.
        <LS_FIELD>-SCRTEXT_L = 'ERP 공정내역'.
        <LS_FIELD>-REPTEXT   = 'ERP 공정내역'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'FLD_02'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = GC_S
      WINDOW_TITLE    = '공정코드'
    TABLES
      VALUE_TAB       = LT_1010
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  PV_GONG = LT_RETURN-FIELDVAL.

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
  IF P_WERKS IS NOT INITIAL.
    CLEAR: GT_1010.
    SELECT *
      FROM ZGTPPT1010
     WHERE MODULE_KIND EQ @GC_PP
       AND CODEGRP EQ @GC_2030
       AND FLD_01 EQ @P_WERKS
      INTO TABLE @GT_1010.

    SORT GT_1010 BY FLD_02.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SAKTO
*&      --> GC_I
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA  USING    P_VALUE
                                     P_GBN.

  IF P_GBN EQ GC_I.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_VALUE
      IMPORTING
        OUTPUT = P_VALUE.

  ELSEIF P_GBN EQ GC_O.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_VALUE
      IMPORTING
        OUTPUT = P_VALUE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .
  REFRESH GT_SORT_0100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                        USING : 1 'VBELN'        'X' '' '',
                                2 'POSNR'        'X' '' '',
                                3 'JOB_NO'       'X' '' '',
                                4 'JOB_NM'       'X' '' '',
                                5 'OPER_CODE_E'  'X' '' '',
                                6 'OPER_NAME_E'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                            PV_FIELDNAME
                            PV_UP
                            PV_DOWN
                            PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUBMIT_ZGTPPI2010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUBMIT_ZGTPPI2010 .

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME VALUE 'ZGTPPI2010',
         LV_JOBNAME2 LIKE TBTCJOB-JOBNAME,
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
         LV_RELEASED LIKE BTCH0000-CHAR1,
         LV_UZEIT    LIKE SY-UZEIT.

  LOOP AT GT_AUFNR_SEND INTO GS_AUFNR_SEND.
    CLEAR: LV_JOBNAME2.
    LV_JOBNAME2 = LV_JOBNAME && |_| && SY-DATUM && |_| && SY-UZEIT.

    CLEAR: LV_JOBCOUNT.
    DO.
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          JOBNAME          = LV_JOBNAME2
        IMPORTING
          JOBCOUNT         = LV_JOBCOUNT
        EXCEPTIONS
          CANT_CREATE_JOB  = 1
          INVALID_JOB_DATA = 2
          JOBNAME_MISSING  = 3
          OTHERS           = 4.
      IF SY-SUBRC EQ 0.
        EXIT.
      ENDIF.
    ENDDO.

    CLEAR: LT_SELTAB[].
    LT_SELTAB = VALUE #(
    ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = GS_AUFNR_SEND-AUFNR )
    ( SELNAME = 'S_ERDAT' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = GS_AUFNR_SEND-ERDAT )
    ( SELNAME = 'P_R1' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
    ( SELNAME = 'P_R2' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE )
    ( SELNAME = 'P_R3' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE )
    ( SELNAME = 'P_R4' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
    ( SELNAME = 'P_R9' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE )
    ( SELNAME = 'P_R8' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' ) ).

    SUBMIT ZGTPPI2010 VIA JOB LV_JOBNAME2
                      NUMBER LV_JOBCOUNT
                      WITH SELECTION-TABLE LT_SELTAB
                      AND RETURN.

    CLEAR: LV_UZEIT.
    LV_UZEIT = SY-UZEIT + 10.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        JOBCOUNT             = LV_JOBCOUNT
        JOBNAME              = LV_JOBNAME2
        SDLSTRTDT            = SY-DATUM
        SDLSTRTTM            = LV_UZEIT
        STRTIMMED            = 'X'  "즉시 기동
      IMPORTING
        JOB_WAS_RELEASED     = LV_RELEASED
      EXCEPTIONS
        CANT_START_IMMEDIATE = 1
        INVALID_STARTDATE    = 2
        JOBNAME_MISSING      = 3
        JOB_CLOSE_FAILED     = 4
        JOB_NOSTEPS          = 5
        JOB_NOTEX            = 6
        LOCK_FAILED          = 7
        OTHERS               = 8.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100 USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DOUBLE_CLICK FOR GO_GRID_0100.
  ENDCASE.

ENDFORM.
