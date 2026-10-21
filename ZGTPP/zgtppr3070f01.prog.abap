*&---------------------------------------------------------------------*
*& Include          ZGTPPR3070F01
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
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .
*-오더생성일자 세팅
  IF S_ERDAT[] IS INITIAL.
    S_ERDAT-SIGN   = GC_I.
    S_ERDAT-OPTION = GC_EQ.
    S_ERDAT-LOW    = SY-DATUM.
    APPEND S_ERDAT.
  ENDIF.

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
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  IF P_R1 EQ GC_X.      "생산오더 생성
    PERFORM GET_JOB_CHECK.
    PERFORM GET_DATA_C.
  ELSEIF P_R2 EQ GC_X.  "생산오더 조회/변경
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

  DATA: L_DYN(50),
        L_DYN1(50).

  CLEAR: L_DYN, L_DYN1.
  IF SY-TCODE EQ 'ZGTPPR3070'.
    L_DYN = 'B~BESKZ NE @GC_F'.
  ELSEIF SY-TCODE EQ 'ZGTPPR3071'.
    L_DYN = 'B~BESKZ NE @SPACE'.
  ENDIF.

  IF P_C2 EQ SPACE.
    L_DYN1 = 'A~NO_DISP EQ @SPACE'.
  ENDIF.

  CLEAR: GT_CTOP, GT_OBOTTOM, GT_OBOTTOMB.

  SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS,
         A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
         A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7,
         A~ZIF_LAST, A~ZSTD, A~NO_DISP,
         B~AUFNR, B~COMP_STAT, B~OPER_CODE, B~OPER_NAME, B~BESKZ,
         B~OPER_MATNR, B~MENGE, B~MEINS, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
         C~VBELN, C~POSNR,
         D~ZPJNO,
         E~NAME1,
         F~MAKTX,
         G~MAKTX AS OPER_MAKTX,
         H~ZPTXT,
         I~FLD_02 AS OPER_CODE_E, I~FLD_03 AS OPER_NAME_E,
         I~FLD_06 AS LEN_ORDGB,
         J~ZJOB_NAME AS JOB_NM
    FROM      ZGTPPT3150           AS A
   INNER JOIN ZGTPPT3160           AS B ON B~JOB_NO      EQ A~JOB_NO
                                       AND B~LINE_NO     EQ A~LINE_NO
                                       AND B~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN ZGTMM_CV_BD_JOBNO_SO AS C ON C~JOB_NO      EQ A~JOB_NO
                                       AND C~LINE_NO     EQ A~LINE_NO
                                       AND C~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN       VBAK           AS D ON D~VBELN       EQ C~VBELN
   INNER JOIN       MARA           AS K ON K~MATNR       EQ B~OPER_MATNR
   INNER JOIN ZGTPPT1010           AS I ON I~MODULE_KIND EQ @GC_PP
                                       AND I~CODEGRP     EQ @GC_2030
                                       AND I~FLD_01      EQ A~WERKS
                                       AND I~FLD_04      EQ B~OPER_CODE
    LEFT OUTER JOIN T001W          AS E ON E~WERKS       EQ A~WERKS
    LEFT OUTER JOIN MAKT           AS F ON F~MATNR       EQ A~MATNR
                                       AND F~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN MAKT           AS G ON G~MATNR       EQ B~OPER_MATNR
                                       AND G~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T       AS H ON H~ZPJNO       EQ D~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121     AS J ON J~ZSYSTEM_ID  EQ @GC_KBDM
                                       AND J~ZWERKS      EQ A~WERKS
                                       AND J~ZJOB_NO     EQ A~JOB_NO
   WHERE A~WERKS      EQ @P_WERKS
     AND A~JOB_NO     IN @S_JOBNO
     AND A~MATNR      IN @S_MATNR
     AND B~OPER_MATNR IN @S_OMATNR
     AND C~VBELN      IN @S_VBELN
     AND C~POSNR      IN @S_POSNR
     AND D~ZPJNO      IN @S_ZPJNO
***  2025.04.24 주석 처리 pys s
*     AND ( B~ZMODE NE @GC_P AND B~ZMODE NE @GC_K )
***  2025.04.24 주석 처리 pys e
     AND ( ( B~AUFNR IS NOT INITIAL AND B~COMP_STAT EQ @SPACE ) OR
             B~AUFNR IS INITIAL )
     AND I~FLD_02     IN @S_GONG
     AND (L_DYN)
     AND (L_DYN1)
    INTO CORRESPONDING FIELDS OF TABLE @GT_CTOP.

  IF GT_CTOP IS NOT INITIAL.
*-제조지시상태 / 제조지시 유형 점검
    IF GR_JOB_NO IS NOT INITIAL.
      DELETE GT_CTOP WHERE JOB_NO NOT IN GR_JOB_NO.
    ENDIF.

    SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~PRCSS_SEQ, A~PRCSS_SUB_SEQ,
           A~OPER_CODE, A~OPER_NAME, A~OPER_MATNR,
           A~OPER_CODE_E, A~OPER_NAME_E,
           B~MTRL_SEQ, B~MATNR, B~MENGE, B~KAUSF, "B~MEINS,
           C~SBDKZ, C~RGEKZ,
           D~MAKTX AS OPER_MAKTX,
           E~MAKTX,
           F~MEINS
      FROM      @GT_CTOP   AS A
     INNER JOIN ZGTPPT3170 AS B ON B~JOB_NO        EQ A~JOB_NO
                               AND B~LINE_NO       EQ A~LINE_NO
                               AND B~SERIAL_INFO   EQ A~SERIAL_INFO
                               AND B~PRCSS_SEQ     EQ A~PRCSS_SEQ
                               AND B~PRCSS_SUB_SEQ EQ A~PRCSS_SUB_SEQ
      LEFT OUTER JOIN MARC AS C ON C~MATNR         EQ B~MATNR
                               AND C~WERKS         EQ A~WERKS
      LEFT OUTER JOIN MAKT AS D ON D~MATNR         EQ A~OPER_MATNR
                               AND D~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MAKT AS E ON E~MATNR         EQ B~MATNR
                               AND E~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MARA AS F ON F~MATNR         EQ B~MATNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_OBOTTOM.

    SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, B~PRCSS_SEQ, A~PRCSS_SUB_SEQ,
           A~OPER_CODE, A~OPER_NAME, A~OPER_MATNR,
           A~OPER_CODE_E, A~OPER_NAME_E,
           B~MTRL_SEQ, B~MATNR, B~MENGE, B~KAUSF, "B~MEINS,
           C~SBDKZ, C~RGEKZ,
           D~MAKTX AS OPER_MAKTX,
           E~MAKTX,
           F~MEINS
      FROM      @GT_CTOP   AS A
     INNER JOIN ZGTPPT3170 AS B ON B~JOB_NO        EQ A~JOB_NO
                               AND B~LINE_NO       EQ A~LINE_NO
                               AND B~SERIAL_INFO   EQ A~SERIAL_INFO
*                               AND B~PRCSS_SEQ     EQ A~PRCSS_SEQ
                               AND B~PRCSS_SUB_SEQ EQ A~PRCSS_SUB_SEQ
      LEFT OUTER JOIN MARC AS C ON C~MATNR         EQ B~MATNR
                               AND C~WERKS         EQ A~WERKS
      LEFT OUTER JOIN MAKT AS D ON D~MATNR         EQ A~OPER_MATNR
                               AND D~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MAKT AS E ON E~MATNR         EQ B~MATNR
                               AND E~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MARA AS F ON F~MATNR         EQ B~MATNR
     WHERE A~OPER_CODE_E EQ @GC_BUS001
       AND B~PRCSS_SEQ   EQ @GC_01
      INTO CORRESPONDING FIELDS OF TABLE @GT_OBOTTOMB.

  ENDIF.

  IF GT_OBOTTOMB IS NOT INITIAL.
    SORT GT_OBOTTOMB BY JOB_NO LINE_NO SERIAL_INFO PRCSS_SEQ PRCSS_SUB_SEQ.
    DELETE ADJACENT DUPLICATES FROM GT_OBOTTOMB
          COMPARING JOB_NO LINE_NO SERIAL_INFO PRCSS_SEQ PRCSS_SUB_SEQ.

    LOOP AT GT_OBOTTOMB INTO DATA(LS_OBOTTOM).
      READ TABLE GT_OBOTTOM INTO DATA(LS_OBTM)
        WITH KEY JOB_NO        = LS_OBOTTOM-JOB_NO
                 LINE_NO       = LS_OBOTTOM-LINE_NO
                 SERIAL_INFO   = LS_OBOTTOM-SERIAL_INFO
                 PRCSS_SEQ     = LS_OBOTTOM-PRCSS_SEQ
                 PRCSS_SUB_SEQ = LS_OBOTTOM-PRCSS_SUB_SEQ.
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING LS_OBOTTOM TO GS_OBOTTOM.
        APPEND GS_OBOTTOM TO GT_OBOTTOM.
        CLEAR: GS_OBOTTOM.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT: GT_CTOP BY VBELN POSNR JOB_NO OPER_CODE_E
                   OPER_MATNR LINE_NO SERIAL_INFO PRCSS_SEQ,
        GT_OBOTTOM BY OPER_CODE OPER_MATNR MTRL_SEQ.

  GT_LOCK[] = CORRESPONDING #( GT_CTOP[] ).

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
  IF P_R1 EQ GC_X.
    PERFORM MODIFY_DATA_C.
  ELSEIF P_R2 EQ GC_X.
    PERFORM MODIFY_DATA_S.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_C .

  DATA: LT_ORDERC LIKE TABLE OF GS_CTOP,
        LS_ORDERC LIKE GS_CTOP.

  DATA: LT_CTOP LIKE TABLE OF GS_CTOP.

  DATA: L_L1L7   TYPE STRING,
        L_CNT(1).

  DATA: LS_CELLCOR TYPE LVC_S_SCOL.

  FIELD-SYMBOLS: <L_L1L7> TYPE ANY.

  CLEAR: LT_ORDERC.

  LOOP AT GT_CTOP ASSIGNING FIELD-SYMBOL(<FS_C>).
    IF <FS_C>-AUFNR IS INITIAL.
      <FS_C>-ORD_STAT = ICON_LED_INACTIVE.
    ELSE.
      <FS_C>-ORD_STAT = ICON_LED_GREEN.
    ENDIF.

    IF <FS_C>-COMP_STAT EQ GC_Y.
      <FS_C>-COMP_ID = ICON_LED_GREEN.
    ELSE.
      <FS_C>-COMP_ID = ICON_LED_INACTIVE.
    ENDIF.

    <FS_C>-GSTRP = SY-DATUM.
    <FS_C>-GLTRP = SY-DATUM.
    <FS_C>-VERID = GC_0010.

    IF <FS_C>-AUFNR IS NOT INITIAL.
      SELECT SINGLE IDAT1
        INTO <FS_C>-IDAT1
        FROM AUFK
       WHERE AUFNR EQ <FS_C>-AUFNR.
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

    IF <FS_C>-OPER_CODE_E EQ GC_BUS001.
      <FS_C>-BUS_PRCSS_SEQ = GC_01.
    ENDIF.

*-재고 수량
    SELECT SUM( KALAB )
      FROM MSKA
     WHERE MATNR EQ @<FS_C>-OPER_MATNR
       AND WERKS EQ @<FS_C>-WERKS
       AND VBELN EQ @<FS_C>-VBELN
       AND POSNR EQ @<FS_C>-POSNR
       AND KALAB GT 0
      INTO @<FS_C>-KALAB.

    IF SY-TCODE = 'ZGTPPR3071'.
      IF <FS_C>-KALAB NE 0.
        <FS_C>-ORD_STAT = ICON_LED_RED.
        <FS_C>-ORD_MSG = TEXT-M20. "이미 재고가 존재하여 생산오더를 생성하지 않습니다.
      ENDIF.
    ENDIF.

    IF SY-TCODE EQ 'ZGTPPR3070'.
*-생성할 생산오더 수량 SUM
      IF <FS_C>-ORD_STAT EQ ICON_LED_INACTIVE.
        MOVE-CORRESPONDING <FS_C> TO LS_ORDERC.
        APPEND LS_ORDERC TO LT_ORDERC.
        CLEAR: LS_ORDERC.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF SY-TCODE EQ 'ZGTPPR3071'.
    CLEAR: LT_CTOP.
    APPEND LINES OF GT_CTOP TO LT_CTOP.
    DELETE LT_CTOP WHERE OPER_CODE_E EQ GC_ABUS001.
    DELETE LT_CTOP WHERE ORD_STAT NE ICON_LED_RED.
    SORT LT_CTOP BY JOB_NO LINE_NO SERIAL_INFO PRCSS_SEQ.
    DELETE ADJACENT DUPLICATES FROM LT_CTOP COMPARING JOB_NO LINE_NO SERIAL_INFO.

    LOOP AT LT_CTOP ASSIGNING FIELD-SYMBOL(<FS_LC>).
      LOOP AT GT_CTOP ASSIGNING <FS_C> WHERE JOB_NO EQ <FS_LC>-JOB_NO
                                         AND LINE_NO EQ <FS_LC>-LINE_NO
                                         AND SERIAL_INFO EQ <FS_LC>-SERIAL_INFO
                                         AND PRCSS_SEQ LT <FS_LC>-PRCSS_SEQ.
        IF <FS_C>-OPER_CODE_E NE GC_ABUS001.
          <FS_C>-ORD_STAT = <FS_LC>-ORD_STAT.
          <FS_C>-ORD_MSG = TEXT-M21. "후공정에 재고가 이미 존재하여 생산오더를 생성하지 않습니다.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT GT_CTOP ASSIGNING <FS_C>.
      IF <FS_C>-BESKZ EQ GC_F.
        <FS_C>-ORD_STAT = ICON_LED_RED.
      ENDIF.

*-생성할 생산오더 수량 SUM
      IF <FS_C>-ORD_STAT EQ ICON_LED_INACTIVE.
        MOVE-CORRESPONDING <FS_C> TO LS_ORDERC.
        APPEND LS_ORDERC TO LT_ORDERC.
        CLEAR: LS_ORDERC.
      ENDIF.
    ENDLOOP.
  ENDIF.

*-판매오더,판매품목,제조지시번호,라인번호,시리얼정보 기준으로 중복 제거
  SORT LT_ORDERC BY VBELN POSNR JOB_NO LINE_NO SERIAL_INFO OPER_MATNR L1L7.
  DELETE ADJACENT DUPLICATES FROM LT_ORDERC
          COMPARING VBELN POSNR JOB_NO LINE_NO SERIAL_INFO OPER_MATNR L1L7.

*-판매오더,판매품목,생산품목 기준으로 생산 수량 SUM
  CLEAR: GT_ORDERC.
  LOOP AT LT_ORDERC INTO LS_ORDERC.
    MOVE-CORRESPONDING LS_ORDERC TO GS_ORDERC.
    COLLECT GS_ORDERC INTO GT_ORDERC.
    CLEAR: LS_ORDERC, GS_ORDERC.
  ENDLOOP.

  LOOP AT GT_OBOTTOM ASSIGNING FIELD-SYMBOL(<FS_B>).
    <FS_B>-COMP_QTY = <FS_B>-MENGE * ( 1 + ( <FS_B>-KAUSF / 100 ) ).
    READ TABLE GT_CTOP INTO DATA(GS) WITH KEY JOB_NO        = <FS_B>-JOB_NO
                                              LINE_NO       = <FS_B>-LINE_NO
                                              SERIAL_INFO   = <FS_B>-SERIAL_INFO
                                              PRCSS_SEQ     = <FS_B>-PRCSS_SEQ
                                              PRCSS_SUB_SEQ = <FS_B>-PRCSS_SUB_SEQ.
    IF SY-SUBRC EQ 0 AND GS-LEN_ORDGB EQ GC_Y.
      <FS_B>-L1L7 = GS-L1L7.
    ENDIF.
    CLEAR: GS.
  ENDLOOP.

*-구성품에 총소요량이 0 이 있는 경우 생산 오더 생성 막음 세팅
  LOOP AT GT_CTOP ASSIGNING <FS_C>.
    READ TABLE GT_OBOTTOM INTO DATA(LS_OBTM) WITH KEY JOB_NO        = <FS_C>-JOB_NO
                                                      LINE_NO       = <FS_C>-LINE_NO
                                                      SERIAL_INFO   = <FS_C>-SERIAL_INFO
                                                      PRCSS_SEQ     = <FS_C>-PRCSS_SEQ
                                                      PRCSS_SUB_SEQ = <FS_C>-PRCSS_SUB_SEQ
                                                      COMP_QTY      = 0.
    IF SY-SUBRC EQ 0.
      <FS_C>-ORD_STAT = ICON_MESSAGE_ERROR.
      <FS_C>-ORD_MSG = TEXT-M19. "소요량이 0인 구성품이 존재합니다. 데이터를 점검하세요.

    ELSE.
      READ TABLE GT_OBOTTOM INTO LS_OBTM WITH KEY JOB_NO        = <FS_C>-JOB_NO
                                                  LINE_NO       = <FS_C>-LINE_NO
                                                  SERIAL_INFO   = <FS_C>-SERIAL_INFO
                                                  PRCSS_SEQ     = <FS_C>-BUS_PRCSS_SEQ
                                                  PRCSS_SUB_SEQ = <FS_C>-PRCSS_SUB_SEQ
                                                  COMP_QTY      = 0.
      IF SY-SUBRC EQ 0.
        <FS_C>-ORD_STAT = ICON_MESSAGE_ERROR.
        <FS_C>-ORD_MSG = TEXT-M19. "소요량이 0인 구성품이 존재합니다. 데이터를 점검하세요.
      ENDIF.
    ENDIF.

*-재고수량 <> 0. 색상 강조
    IF <FS_C>-KALAB NE 0.
      LS_CELLCOR-FNAME     = 'KALAB'.
      LS_CELLCOR-COLOR-COL = '7'.
      LS_CELLCOR-COLOR-INT = '1'.
      LS_CELLCOR-COLOR-INV = '0'.
      APPEND LS_CELLCOR TO <FS_C>-CELL_COR.
      CLEAR: LS_CELLCOR.
    ENDIF.
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
         GT_EXCLUDE_0100,
         GT_FIELDCAT_0101[], GS_LAYOUT_0101, GT_EXCLUDE_0101[],
         GT_EXCLUDE_0101, GV_OK_CODE, GV_DBCNT,
         GT_CTOP[], GT_STOP[], GT_BOTTOM[].

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101.
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

  CREATE OBJECT GO_DOCKING_CONTAINER
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID = 1
      HEIGHT = 90 ).

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
  GS_LAYOUT_0100-CTAB_FNAME = 'CELL_COR'.
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
    PERFORM SET_FIELDCAT_C.
  ELSEIF P_R2 EQ GC_X.
    PERFORM SET_FIELDCAT_S.
  ENDIF.
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
  IF P_R1 EQ GC_X.
    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      CHANGING
        IT_OUTTAB            = GT_CTOP
        IT_SORT              = GT_SORT_0100
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.
  ELSEIF P_R2 EQ GC_X.
    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      CHANGING
        IT_OUTTAB            = GT_STOP
        IT_SORT              = GT_SORT_0100
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ITEMCHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ITEMCHK .

  DATA: LT_ROW_NO  TYPE LVC_T_ROID WITH HEADER LINE.

  FIELD-SYMBOLS: <FS_C> LIKE GS_CTOP,
                 <FS_S> LIKE GS_STOP.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF LINES( LT_ROW_NO ) > 1.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M10. "구성부품 확인은 1건씩 선택하세요.
    EXIT.
  ENDIF.

  CLEAR: GT_CTOPS, GT_STOPS.
  IF P_R1 EQ GC_X.
    APPEND LINES OF GT_CTOP TO GT_CTOPS.
  ELSEIF P_R2 EQ GC_X.
    APPEND LINES OF GT_STOP TO GT_STOPS.
  ENDIF.

  LOOP AT LT_ROW_NO.
    IF P_R1 EQ GC_X.
      READ TABLE GT_CTOP ASSIGNING <FS_C> INDEX LT_ROW_NO-ROW_ID.
      PERFORM SET_BOTTOM_DATA_C USING <FS_C>.
    ELSEIF P_R2 EQ GC_X.
      READ TABLE GT_STOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.
      PERFORM SET_BOTTOM_DATA_S USING <FS_S>.
    ENDIF.
    PERFORM SET_BOTTOM_DATA.
    PERFORM SET_BOTTOM_ALV_0101.
  ENDLOOP.

  " REFRESH DISPLAY
*  PERFORM REF_ALV_RTN USING GO_GRID_0100.

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
*& Form SET_BOTTOM_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_DATA_C  USING    P_LINE LIKE GS_CTOP.

  CLEAR: GT_BOTTOM.
  LOOP AT GT_CTOPS INTO DATA(LS_CTOPS) WHERE VBELN      EQ P_LINE-VBELN
                                         AND POSNR      EQ P_LINE-POSNR
                                         AND OPER_MATNR EQ P_LINE-OPER_MATNR
                                         AND L1L7       EQ P_LINE-L1L7.

    LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_CTOPS-JOB_NO
                                            AND LINE_NO       EQ LS_CTOPS-LINE_NO
                                            AND SERIAL_INFO   EQ LS_CTOPS-SERIAL_INFO
                                            AND PRCSS_SEQ     EQ LS_CTOPS-PRCSS_SEQ
                                            AND PRCSS_SUB_SEQ EQ LS_CTOPS-PRCSS_SUB_SEQ
                                            AND L1L7          EQ LS_CTOPS-L1L7.

      MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
      CLEAR: GS_BOTTOM-MTRL_SEQ.

      COLLECT GS_BOTTOM INTO GT_BOTTOM.
      CLEAR: GS_BOTTOM, LS_OBTM.
    ENDLOOP.
    CLEAR: LS_CTOPS.
  ENDLOOP.

  IF GT_BOTTOM IS INITIAL.
    READ TABLE GT_OBOTTOM INTO LS_OBTM WITH KEY JOB_NO        = P_LINE-JOB_NO
                                                LINE_NO       = P_LINE-LINE_NO
                                                SERIAL_INFO   = P_LINE-SERIAL_INFO
                                                PRCSS_SEQ     = P_LINE-BUS_PRCSS_SEQ
                                                PRCSS_SUB_SEQ = P_LINE-PRCSS_SUB_SEQ
                                                L1L7          = P_LINE-L1L7.

    MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
    CLEAR: GS_BOTTOM-MTRL_SEQ.

    COLLECT GS_BOTTOM INTO GT_BOTTOM.
    CLEAR: GS_BOTTOM, LS_OBTM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_ALV_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_ALV_0101 .
  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REF_ALV_RTN USING GO_GRID_0101.
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

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
    WHEN GO_GRID_0101.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0101.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .
  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-ZEBRA      = GC_X.
  GS_LAYOUT_0101-COL_OPT    = GC_X.
  GS_LAYOUT_0101-CWIDTH_OPT = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3070TOP'
      I_INTERNAL_TABNAME     = 'GS_BOTTOM'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_BOTTOM
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'OPER_CODE_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "공정코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'OPER_NAME_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'OPER_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'OPER_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'L1L7'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F43. "L1~L7
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-OUTPUTLEN = '35'.
      WHEN 'MTRL_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "자재순번
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "제품코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "제품내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "순소요량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'KAUSF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "LOSS율(%)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'COMP_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "총소요량
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = GC_R.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "수량단위
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF <LS_FCAT>-FIELDNAME = 'OPER_CODE'  OR <LS_FCAT>-FIELDNAME = 'OPER_NAME' OR
       <LS_FCAT>-FIELDNAME = 'OPER_MATNR' OR <LS_FCAT>-FIELDNAME = 'OPER_MAKTX'.

    ELSE.
      CLEAR: <LS_FCAT>-KEY.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
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
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .
  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_BOTTOM
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ORDCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_CTOPSEL LIKE TABLE OF GS_CTOP.

  FIELD-SYMBOLS: <FS_S> LIKE GS_CTOP.

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
      TITLEBAR              = TEXT-T04 "생산오더 생성
      TEXT_QUESTION         = TEXT-T05 "생산오더 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_CTOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CTOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ORD_STAT EQ ICON_LED_GREEN.
        <FS_S>-ORD_MSG = TEXT-M02. "이미 생산오더가 생성되었습니다.
      ELSEIF <FS_S>-ORD_STAT EQ ICON_MESSAGE_ERROR.
        <FS_S>-ORD_MSG = TEXT-M19. "소요량이 0인 구성품이 존재합니다. 데이터를 점검하세요.
      ELSEIF <FS_S>-ORD_STAT EQ ICON_LED_RED.
        <FS_S>-ORD_MSG = TEXT-M20. "이미 재고가 존재하여 생산오더를 생성하지 않습니다.
      ELSE.
*- 선택한 데이터
        APPEND <FS_S> TO LT_CTOPSEL.
      ENDIF.
    ENDLOOP.

*-선택된 데이터를 판매오더+품목+생산품목 기준으로 중복 제거
    SORT LT_CTOPSEL BY VBELN POSNR OPER_MATNR L1L7.
    DELETE ADJACENT DUPLICATES FROM LT_CTOPSEL
                          COMPARING VBELN POSNR OPER_MATNR L1L7.

    SORT LT_CTOPSEL BY VBELN POSNR OPER_CODE_E.

*-선택된 데이터를 판매오더+품목+생산품목 기준으로 오더 생성
    LOOP AT LT_CTOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_ORD_CREATE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_CTOP ASSIGNING <FS_S> WHERE ORD_STAT NE ICON_LED_GREEN
                                       AND AUFNR EQ SPACE.
      READ TABLE LT_CTOPSEL INTO DATA(LS_SEL) WITH KEY VBELN      = <FS_S>-VBELN
                                                       POSNR      = <FS_S>-POSNR
                                                       OPER_MATNR = <FS_S>-OPER_MATNR
                                                       L1L7       = <FS_S>-L1L7.
      IF SY-SUBRC EQ 0.
        <FS_S>-ORD_STAT = LS_SEL-ORD_STAT.
        <FS_S>-ORD_MSG = LS_SEL-ORD_MSG.
        <FS_S>-AUFNR = LS_SEL-AUFNR.

*-처리 결과 DB 업데이트(성공건만)
        IF LS_SEL-AUFNR IS NOT INITIAL AND LS_SEL-ORD_STAT EQ ICON_LED_GREEN.
          UPDATE ZGTPPT3150 SET ZIF_APPLIED = <FS_S>-ZIF_LAST
                          WHERE JOB_NO      = <FS_S>-JOB_NO
                            AND LINE_NO     = <FS_S>-LINE_NO
                            AND SERIAL_INFO = <FS_S>-SERIAL_INFO.

          UPDATE ZGTPPT3160 SET AUFNR         = <FS_S>-AUFNR
                          WHERE JOB_NO        = <FS_S>-JOB_NO
                            AND LINE_NO       = <FS_S>-LINE_NO
                            AND SERIAL_INFO   = <FS_S>-SERIAL_INFO
                            AND PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                            AND PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.
*** 2025.04.24 주석 처리 pys s
*                            AND ( ZMODE NE GC_P AND ZMODE NE GC_K ).
*** 2025.04.24 주석 처리 pys e
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ORD_CREATE  USING    P_LINE LIKE GS_CTOP.
  DATA: LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.
  DATA: LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA: LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.

*- 판매오더+품목+생산자재 기준의 수량 sum
  READ TABLE GT_ORDERC INTO DATA(LS_ORDERC) WITH KEY VBELN      = P_LINE-VBELN
                                                     POSNR      = P_LINE-POSNR
                                                     OPER_MATNR = P_LINE-OPER_MATNR
                                                     L1L7       = P_LINE-L1L7.

  CLEAR : LS_ORDER, LS_RETURN, LV_ORDER_NUMBER.
*  오더 생성
  LS_ORDER-MATERIAL              = P_LINE-OPER_MATNR.
  LS_ORDER-PLANT                 = P_LINE-WERKS.
  LS_ORDER-ORDER_TYPE            = 'PP04'.
  LS_ORDER-BASIC_START_DATE      = P_LINE-GSTRP.
  LS_ORDER-BASIC_START_TIME      = '000000'.
  LS_ORDER-BASIC_END_DATE        = P_LINE-GLTRP.
  LS_ORDER-BASIC_END_TIME        = '000000'.
  LS_ORDER-QUANTITY              = LS_ORDERC-MENGE.  "P_LINE-MENGE.
  LS_ORDER-QUANTITY_UOM          = P_LINE-MEINS.
  LS_ORDER-PROD_VERSION          = P_LINE-VERID.
  LS_ORDER-SALES_ORDER           = P_LINE-VBELN.
  LS_ORDER-SALES_ORDER_ITEM      = P_LINE-POSNR.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

  IF LS_RETURN-TYPE NE GC_E.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

* 커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE AUFNR, POSNR
        FROM AFPO
       WHERE AUFNR = @LV_ORDER_NUMBER
        INTO @DATA(LS_AFPO).
      IF SY-SUBRC EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.5' SECONDS.
      ENDIF.
    ENDDO.

    P_LINE-ORD_STAT = ICON_LED_GREEN.
    P_LINE-ORD_MSG = TEXT-M03. "오더 생성에 성공하였습니다.
    P_LINE-AUFNR = LV_ORDER_NUMBER.

  ELSE.
    P_LINE-ORD_STAT = ICON_LED_RED.
    P_LINE-ORD_MSG = LS_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ITEMCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ITEMCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_CTOPSEL LIKE TABLE OF GS_CTOP.
  DATA : LV_CHK_ERR.

  FIELD-SYMBOLS: <FS_S> LIKE GS_CTOP.

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
      TITLEBAR              = TEXT-T06 "생산오더 구성부품 등록
      TEXT_QUESTION         = TEXT-T07 "생산오더 구성부품을 등록하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.

    CLEAR: GT_CTOPS.
    APPEND LINES OF GT_CTOP TO GT_CTOPS.

    CLEAR: LT_CTOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CTOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR EQ SPACE.
        <FS_S>-COMP_MSG = TEXT-M04. "생산오더 생성 후 진행하십시요.
      ELSE.
        IF <FS_S>-COMP_ID EQ ICON_LED_GREEN.
          <FS_S>-COMP_MSG = TEXT-M05. "이미 구성부품 등록이 수행되었습니다.
        ELSE.
          IF <FS_S>-IDAT1 EQ SPACE.
            <FS_S>-COMP_MSG = TEXT-M06. "생산오더 릴리즈 상태에서만 구성부품 등록이 가능합니다.
          ELSE.
* 구성 부품 유효성체크 추가
            CLEAR LV_CHK_ERR.
            PERFORM CHECK_IDNRK_STATUS USING <FS_S> CHANGING <FS_S>-COMP_MSG LV_CHK_ERR.
            IF LV_CHK_ERR IS INITIAL.
*-선택한 데이터
              APPEND <FS_S> TO LT_CTOPSEL.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.




*-선택한 데이터를 오더 기준으로 중복 제거
    SORT LT_CTOPSEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_CTOPSEL COMPARING AUFNR.

*-선택한 데이터를 오더 기준으로 품목 등록
    LOOP AT LT_CTOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_ITEM_CREATE USING <FS_SEL>.
    ENDLOOP.

    CLEAR: GT_AUFNR_SEND.
*-처리 결과 ALV 적용
    LOOP AT GT_CTOP ASSIGNING <FS_S> WHERE COMP_ID NE ICON_LED_GREEN
                                       AND AUFNR NE SPACE.
      READ TABLE LT_CTOPSEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
      IF SY-SUBRC EQ 0.
        <FS_S>-COMP_ID = LS_SEL-COMP_ID.
        <FS_S>-COMP_MSG = LS_SEL-COMP_MSG.

*-처리 결과 DB 업데이트(성공건만)
        IF LS_SEL-COMP_ID EQ ICON_LED_GREEN.
          UPDATE ZGTPPT3160 SET COMP_STAT     = GC_Y
                          WHERE JOB_NO        = <FS_S>-JOB_NO
                            AND LINE_NO       = <FS_S>-LINE_NO
                            AND SERIAL_INFO   = <FS_S>-SERIAL_INFO
                            AND PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                            AND PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.

          COMMIT WORK.

*-전송할 생산오더
          GS_AUFNR_SEND-AUFNR = LS_SEL-AUFNR.
          SELECT SINGLE ERDAT
            FROM AUFK
           WHERE AUFNR EQ @LS_SEL-AUFNR
            INTO @GS_AUFNR_SEND-ERDAT.

          COLLECT GS_AUFNR_SEND INTO GT_AUFNR_SEND.
          CLEAR: GS_AUFNR_SEND.

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
*& Form EXEC_ITEM_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ITEM_CREATE  USING    P_LINE LIKE GS_CTOP.

  DATA: LS_ORDDATA  TYPE BAPI_PP_ORDER_CHANGE,
        LS_ORDDATAX TYPE BAPI_PP_ORDER_CHANGEX,
        LS_RETURN   TYPE BAPIRET2,
        LV_READ     TYPE BAPIFLAG-BAPIFLAG.

  CLEAR: LS_ORDDATA, LS_ORDDATAX, LS_RETURN, LV_READ.

  LS_ORDDATA-EXPLOSION_DATE = SY-DATUM.
  LS_ORDDATA-EXPLODE_NEW = GC_X.

  LS_ORDDATAX-EXPLOSION_DATE = GC_X.

  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
    EXPORTING
      NUMBER           = P_LINE-AUFNR
      ORDERDATA        = LS_ORDDATA
      ORDERDATAX       = LS_ORDDATAX
    IMPORTING
      RETURN           = LS_RETURN
      MASTER_DATA_READ = LV_READ.

  WAIT UP TO 1 SECONDS.

  IF LV_READ NE GC_X.
    P_LINE-COMP_ID  = ICON_LED_RED.
    P_LINE-COMP_MSG = LS_RETURN-MESSAGE.

  ELSEIF LV_READ EQ GC_X.
    PERFORM COMPONENT_ADD USING P_LINE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPONENT_ADD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM COMPONENT_ADD  USING    P_LINE LIKE GS_CTOP.

  DATA: LT_BOTTOM LIKE TABLE OF GS_BOTTOM.

  CLEAR: LT_BOTTOM.
  LOOP AT GT_CTOPS INTO DATA(LS_CTOPS) WHERE VBELN      EQ P_LINE-VBELN
                                         AND POSNR      EQ P_LINE-POSNR
                                         AND OPER_MATNR EQ P_LINE-OPER_MATNR
                                         AND L1L7       EQ P_LINE-L1L7.

    LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_CTOPS-JOB_NO
                                            AND LINE_NO       EQ LS_CTOPS-LINE_NO
                                            AND SERIAL_INFO   EQ LS_CTOPS-SERIAL_INFO
                                            AND PRCSS_SEQ     EQ LS_CTOPS-PRCSS_SEQ
                                            AND PRCSS_SUB_SEQ EQ LS_CTOPS-PRCSS_SUB_SEQ
                                            AND L1L7          EQ LS_CTOPS-L1L7.

      MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
      CLEAR: GS_BOTTOM-MTRL_SEQ.

      COLLECT GS_BOTTOM INTO LT_BOTTOM.
      CLEAR: GS_BOTTOM, LS_OBTM.
    ENDLOOP.
    CLEAR: LS_CTOPS.
  ENDLOOP.

  IF LT_BOTTOM IS INITIAL.
    READ TABLE GT_OBOTTOM INTO LS_OBTM WITH KEY JOB_NO        = P_LINE-JOB_NO
                                                LINE_NO       = P_LINE-LINE_NO
                                                SERIAL_INFO   = P_LINE-SERIAL_INFO
                                                PRCSS_SEQ     = P_LINE-BUS_PRCSS_SEQ
                                                PRCSS_SUB_SEQ = P_LINE-PRCSS_SUB_SEQ
                                                L1L7          = P_LINE-L1L7.

    MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
    CLEAR: GS_BOTTOM-MTRL_SEQ.

    COLLECT GS_BOTTOM INTO LT_BOTTOM.
    CLEAR: GS_BOTTOM, LS_OBTM.
  ENDIF.

  IF LT_BOTTOM IS INITIAL.
    P_LINE-COMP_STAT = ICON_LED_RED.
    P_LINE-COMP_MSG = TEXT-M07. "등록할 품목이 없습니다.

  ELSE.
    SORT LT_BOTTOM BY OPER_CODE_E OPER_MATNR L1L7 MATNR.

    CLEAR: GV_SEQ.
    LOOP AT LT_BOTTOM ASSIGNING FIELD-SYMBOL(<LS_BTM>).
      GV_SEQ = GV_SEQ + 1.
      <LS_BTM>-MTRL_SEQ = GV_SEQ.
    ENDLOOP.

    CLEAR: GV_POSNR.

    LOOP AT LT_BOTTOM INTO DATA(LS_BOTTOM).
      CLEAR: GS_STORAGE_LOCATION, GS_STORAGE_LOCATIONX.
      SELECT SINGLE LGPRO
        INTO GS_STORAGE_LOCATION-LGORT
        FROM MARC
       WHERE MATNR EQ LS_BOTTOM-MATNR
            AND WERKS EQ P_LINE-WERKS.               "2025.07.17 플랜트 조건 추가

      GS_STORAGE_LOCATION-WERKS = P_LINE-WERKS.

      GS_STORAGE_LOCATIONX-WERKS = GC_X.
      GS_STORAGE_LOCATIONX-LGORT = GC_X.

      CLEAR: GS_REQU_QUAN.
      GS_REQU_QUAN-QUANTITY = LS_BOTTOM-COMP_QTY.
      CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
        EXPORTING
          ISO_CODE  = LS_BOTTOM-MEINS
        IMPORTING
          SAP_CODE  = GS_REQU_QUAN-UOM
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.

      CLEAR: GV_OPERATION, GV_SEQUENCE.
      SELECT SINGLE B~APLZL B~PLNFL
        INTO (GV_OPERATION, GV_SEQUENCE)
        FROM AFKO AS A
       INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
       WHERE A~AUFNR EQ P_LINE-AUFNR.

      CLEAR: GV_SOBKZ, GV_SOBKZX, GV_KDAUF, GV_KDAUFX, GV_KDPOS, GV_KDPOSX.
      IF LS_BOTTOM-SBDKZ EQ '1'.
        GV_SOBKZ = GC_E.
        GV_SOBKZX = GC_X.
        GV_KDAUF = P_LINE-VBELN.
        GV_KDAUFX = GC_X.
        GV_KDPOS = P_LINE-POSNR.
        GV_KDPOSX = GC_X.
      ENDIF.

      CLEAR: GV_POSTP, GV_POSITIONNO.
      GV_POSTP = GC_L.

      GV_POSNR = GV_POSNR + 10.
      CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
        EXPORTING
          INPUT  = GV_POSNR
        IMPORTING
          OUTPUT = GV_POSITIONNO.

      CLEAR: GS_RETURN, GV_ERROR.
      CALL FUNCTION 'CO_XT_COMPONENT_ADD'
        EXPORTING
          IS_ORDER_KEY         = P_LINE-AUFNR
          I_MATERIAL           = LS_BOTTOM-MATNR
          IS_REQU_QUAN         = GS_REQU_QUAN
          I_OPERATION          = GV_OPERATION
          I_SEQUENCE           = GV_SEQUENCE
          IS_STORAGE_LOCATION  = GS_STORAGE_LOCATION
          IS_STORAGE_LOCATIONX = GS_STORAGE_LOCATIONX
          I_POSTP              = GV_POSTP
          I_SOBKZ              = GV_SOBKZ
          I_SOBKZX             = GV_SOBKZX
          I_KDAUF              = GV_KDAUF
          I_KDAUFX             = GV_KDAUFX
          I_KDPOS              = GV_KDPOS
          I_KDPOSX             = GV_KDPOSX
          I_POSNO              = GV_POSITIONNO
        IMPORTING
          ES_BAPIRETURN        = GS_RETURN
          E_ERROR_OCCURRED     = GV_ERROR.

      IF GV_ERROR IS NOT INITIAL.
        P_LINE-COMP_ID = ICON_LED_RED.
        P_LINE-COMP_MSG = GS_RETURN-MESSAGE.
*        P_LINE-COMP_MSG = TEXT-M09. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.

        EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERROR EQ SPACE.
      CLEAR: GV_NUMC.
      ASSIGN ('(SAPLCOBC)RESB_BT[]') TO <FT_RESB_BT>.
      LOOP AT <FT_RESB_BT> ASSIGNING <FS_RESB_BT>.
        GV_NUMC = SY-TABIX * 10.
        <FS_RESB_BT>-POSNR = GV_NUMC.
        CLEAR GV_NUMC.
        READ TABLE LT_BOTTOM INTO DATA(LS_BTM) WITH KEY MATNR = <FS_RESB_BT>-MATNR.
        IF SY-SUBRC EQ 0.
          IF LS_BTM-RGEKZ EQ '1'.
            <FS_RESB_BT>-RGEKZ = GC_X.
          ENDIF.
        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'CO_ZV_ORDER_POST'
        EXPORTING
          COMMIT_FLAG             = SPACE
          EXT_FLG                 = 'X'
          TRANS_TYP               = 'V'
          NO_DIALOG               = 'X'
          IV_COMMIT_WORK_AND_WAIT = 'X'
        EXCEPTIONS
          NO_CHANGE               = 01
          UPDATE_REJECT           = 02
          ERROR_MESSAGE           = 03.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

        P_LINE-COMP_ID = ICON_LED_GREEN.
        P_LINE-COMP_MSG = TEXT-M08. "생산오더의 구성부품 등록에 성공하였습니다.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        P_LINE-COMP_ID = ICON_LED_RED.
        P_LINE-COMP_MSG = TEXT-M09. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-COMP_ID = ICON_LED_RED.
      P_LINE-COMP_MSG = GS_RETURN-MESSAGE.
*      P_LINE-COMP_MSG = TEXT-M09. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.

    ENDIF.
  ENDIF.
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

  CLEAR: GT_STOP, GT_OBOTTOM, GT_OBOTTOMB.

  SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~MATNR, A~WERKS,
         A~ZLENGTH_1, A~ZLENGTH_2, A~ZLENGTH_3, A~ZLENGTH_4,
         A~ZLENGTH_5, A~ZLENGTH_6, A~ZLENGTH_7,
         A~ZIF_APPLIED, A~ZIF_LAST, A~ZSTD,
         B~AUFNR, B~COMP_STAT, B~OPER_CODE, B~OPER_NAME,
         B~OPER_MATNR, B~MENGE, B~MEINS, B~PRCSS_SEQ, B~PRCSS_SUB_SEQ,
         C~ERDAT,
         D~GSTRP, D~GLTRP,
         E~KDAUF, E~KDPOS, E~VERID,
         F~ZPJNO,
         G~NAME1,
         H~MAKTX,
         I~MAKTX AS OPER_MAKTX,
         J~ZPTXT,
         K~FLD_02 AS OPER_CODE_E, K~FLD_03 AS OPER_NAME_E,
         K~FLD_06 AS LEN_ORDGB,
         L~ZJOB_NAME AS JOB_NM
    FROM      ZGTPPT3150       AS A
   INNER JOIN ZGTPPT3160       AS B ON B~JOB_NO      EQ A~JOB_NO
                                   AND B~LINE_NO     EQ A~LINE_NO
                                   AND B~SERIAL_INFO EQ A~SERIAL_INFO
   INNER JOIN       AUFK       AS C ON C~AUFNR       EQ B~AUFNR
   INNER JOIN       AFKO       AS D ON D~AUFNR       EQ C~AUFNR
   INNER JOIN       AFPO       AS E ON E~AUFNR       EQ D~AUFNR
   INNER JOIN       VBAK       AS F ON F~VBELN       EQ E~KDAUF
   INNER JOIN       MARA       AS M ON M~MATNR       EQ B~OPER_MATNR
   INNER JOIN ZGTPPT1010       AS K ON K~MODULE_KIND EQ @GC_PP
                                   AND K~CODEGRP     EQ @GC_2030
                                   AND K~FLD_01      EQ A~WERKS
                                   AND K~FLD_04      EQ B~OPER_CODE
    LEFT OUTER JOIN T001W      AS G ON G~WERKS       EQ A~WERKS
    LEFT OUTER JOIN MAKT       AS H ON H~MATNR       EQ A~MATNR
                                   AND H~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN MAKT       AS I ON I~MATNR       EQ B~OPER_MATNR
                                   AND I~SPRAS       EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T   AS J ON J~ZPJNO       EQ F~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS L ON L~ZSYSTEM_ID  EQ @GC_KBDM
                                   AND L~ZWERKS      EQ A~WERKS
                                   AND L~ZJOB_NO     EQ A~JOB_NO
   WHERE C~WERKS       EQ @P_WERKS
     AND A~JOB_NO      IN @S_JOBNO
     AND A~LINE_NO     IN @S_LINENO
     AND A~SERIAL_INFO IN @S_SERIAL
     AND A~MATNR       IN @S_MATNR
     AND E~MATNR       IN @S_OMATNR
     AND E~KDAUF       IN @S_VBELN
     AND E~KDPOS       IN @S_POSNR
     AND F~ZPJNO       IN @S_ZPJNO
     AND B~AUFNR       IN @S_AUFNR
     AND C~ERDAT       IN @S_ERDAT
     AND K~FLD_02      IN @S_GONG
     AND B~AUFNR       IS NOT INITIAL
     AND B~COMP_STAT   IS NOT INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @GT_STOP.

  IF GT_STOP IS NOT INITIAL.
    SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, A~PRCSS_SEQ, A~PRCSS_SUB_SEQ,
           A~OPER_CODE, A~OPER_NAME, A~OPER_MATNR,
           A~OPER_CODE_E, A~OPER_NAME_E,
           B~MTRL_SEQ, B~MATNR, B~MENGE, B~KAUSF, "B~MEINS,
           C~SBDKZ, C~RGEKZ,
           D~MAKTX AS OPER_MAKTX,
           E~MAKTX,
           F~MEINS
      FROM      @GT_STOP   AS A
     INNER JOIN ZGTPPT3170 AS B ON B~JOB_NO        EQ A~JOB_NO
                               AND B~LINE_NO       EQ A~LINE_NO
                               AND B~SERIAL_INFO   EQ A~SERIAL_INFO
                               AND B~PRCSS_SEQ     EQ A~PRCSS_SEQ
                               AND B~PRCSS_SUB_SEQ EQ A~PRCSS_SUB_SEQ
      LEFT OUTER JOIN MARC AS C ON C~MATNR         EQ B~MATNR
                               AND C~WERKS         EQ A~WERKS
      LEFT OUTER JOIN MAKT AS D ON D~MATNR         EQ A~OPER_MATNR
                               AND D~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MAKT AS E ON E~MATNR         EQ B~MATNR
                               AND E~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MARA AS F ON F~MATNR         EQ B~MATNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_OBOTTOM.

    SELECT A~JOB_NO, A~LINE_NO, A~SERIAL_INFO, B~PRCSS_SEQ, A~PRCSS_SUB_SEQ,
           A~OPER_CODE, A~OPER_NAME, A~OPER_MATNR,
           A~OPER_CODE_E, A~OPER_NAME_E,
           B~MTRL_SEQ, B~MATNR, B~MENGE, B~KAUSF, "B~MEINS,
           C~SBDKZ, C~RGEKZ,
           D~MAKTX AS OPER_MAKTX,
           E~MAKTX,
           F~MEINS
      FROM      @GT_STOP   AS A
     INNER JOIN ZGTPPT3170 AS B ON B~JOB_NO        EQ A~JOB_NO
                               AND B~LINE_NO       EQ A~LINE_NO
                               AND B~SERIAL_INFO   EQ A~SERIAL_INFO
*                               AND B~PRCSS_SEQ     EQ A~PRCSS_SEQ
                               AND B~PRCSS_SUB_SEQ EQ A~PRCSS_SUB_SEQ
      LEFT OUTER JOIN MARC AS C ON C~MATNR         EQ B~MATNR
                               AND C~WERKS         EQ A~WERKS
      LEFT OUTER JOIN MAKT AS D ON D~MATNR         EQ A~OPER_MATNR
                               AND D~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MAKT AS E ON E~MATNR         EQ B~MATNR
                               AND E~SPRAS         EQ @SY-LANGU
      LEFT OUTER JOIN MARA AS F ON F~MATNR         EQ B~MATNR
     WHERE A~OPER_CODE_E EQ @GC_BUS001
       AND B~PRCSS_SEQ   EQ @GC_01
      INTO CORRESPONDING FIELDS OF TABLE @GT_OBOTTOMB.

  ENDIF.

  IF GT_OBOTTOMB IS NOT INITIAL.
    SORT GT_OBOTTOMB BY JOB_NO LINE_NO SERIAL_INFO PRCSS_SEQ PRCSS_SUB_SEQ.
    DELETE ADJACENT DUPLICATES FROM GT_OBOTTOMB
          COMPARING JOB_NO LINE_NO SERIAL_INFO PRCSS_SEQ PRCSS_SUB_SEQ.

    LOOP AT GT_OBOTTOMB INTO DATA(LS_OBOTTOM).
      READ TABLE GT_OBOTTOM INTO DATA(LS_OBTM)
        WITH KEY JOB_NO        = LS_OBOTTOM-JOB_NO
                 LINE_NO       = LS_OBOTTOM-LINE_NO
                 SERIAL_INFO   = LS_OBOTTOM-SERIAL_INFO
                 PRCSS_SEQ     = LS_OBOTTOM-PRCSS_SEQ
                 PRCSS_SUB_SEQ = LS_OBOTTOM-PRCSS_SUB_SEQ.
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING LS_OBOTTOM TO GS_OBOTTOM.
        APPEND GS_OBOTTOM TO GT_OBOTTOM.
        CLEAR: GS_OBOTTOM.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT: GT_STOP BY KDAUF KDPOS JOB_NO OPER_CODE_E
                   OPER_MATNR LINE_NO SERIAL_INFO PRCSS_SEQ,
        GT_OBOTTOM BY OPER_CODE OPER_MATNR MTRL_SEQ.

  GT_LOCK[] = CORRESPONDING #( GT_STOP[] ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_S .

  DATA: LT_ORDERS LIKE TABLE OF GS_STOP,
        LS_ORDERS LIKE GS_STOP.

  DATA: BEGIN OF LS_STAT,
          STAT TYPE CHAR100,
        END OF LS_STAT,
        LT_STAT LIKE TABLE OF LS_STAT.

  DATA: L_L1L7   TYPE STRING,
        L_CNT(1).

  FIELD-SYMBOLS: <L_L1L7> TYPE ANY.

  CLEAR: LT_ORDERS.

  LOOP AT GT_STOP ASSIGNING FIELD-SYMBOL(<FS_S>).
*    IF <FS_S>-ZIF_APPLIED EQ <FS_S>-ZIF_LAST.
*      <FS_S>-APPL_STAT = ICON_LED_GREEN.
*    ELSE.
*      <FS_S>-APPL_STAT = ICON_LED_INACTIVE.
*    ENDIF.

    IF <FS_S>-LEN_ORDGB EQ GC_Y AND <FS_S>-ZLENGTH_1 IS NOT INITIAL.
      CLEAR: L_CNT, L_L1L7.
      DO 7 TIMES.
        L_CNT = L_CNT + 1.
        L_L1L7 = '<FS_S>-ZLENGTH_' && L_CNT.
        ASSIGN (L_L1L7) TO <L_L1L7>.

        IF <L_L1L7> IS NOT INITIAL.
          IF L_CNT EQ '1'.
            <FS_S>-L1L7 = <L_L1L7>.
          ELSE.
            <FS_S>-L1L7 = <FS_S>-L1L7 && |,| && <L_L1L7>.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDIF.

    IF <FS_S>-AUFNR IS NOT INITIAL.
*-오더상태
      CLEAR: LS_STAT, LT_STAT.
      CALL FUNCTION 'ZGTPP_ORDER_STATUS'
        EXPORTING
          I_AUFNR  = <FS_S>-AUFNR
        IMPORTING
          E_STATUS = <FS_S>-ORDSTAT.
    ENDIF.

    IF <FS_S>-OPER_CODE_E EQ GC_BUS001.
      <FS_S>-BUS_PRCSS_SEQ = GC_01.
    ENDIF.

*-재고 수량
    SELECT SUM( KALAB )
      FROM MSKA
     WHERE MATNR EQ @<FS_S>-OPER_MATNR
       AND WERKS EQ @<FS_S>-WERKS
       AND VBELN EQ @<FS_S>-KDAUF
       AND POSNR EQ @<FS_S>-KDPOS
       AND KALAB GT 0
      INTO @<FS_S>-KALAB.

*-생성할 생산오더 수량 SUM
*    IF <FS_S>-APPL_STAT EQ ICON_LED_INACTIVE.
*      MOVE-CORRESPONDING <FS_S> TO LS_ORDERS.
*      APPEND LS_ORDERS TO LT_ORDERS.
*      CLEAR: LS_ORDERS.
*    ENDIF.
  ENDLOOP.

**-판매오더,판매품목,제조지시번호,라인번호,시리얼정보 기준으로 중복 제거
*  SORT LT_ORDERS BY KDAUF KDPOS JOB_NO LINE_NO SERIAL_INFO OPER_MATNR L1L7.
*  DELETE ADJACENT DUPLICATES FROM LT_ORDERS
*          COMPARING KDAUF KDPOS JOB_NO LINE_NO SERIAL_INFO OPER_MATNR L1L7.
*
**-판매오더,판매품목,생산품목 기준으로 생산 수량 SUM
*  CLEAR: GT_ORDERC.
*  LOOP AT LT_ORDERS INTO LS_ORDERS.
*    MOVE-CORRESPONDING LS_ORDERS TO GS_ORDERC.
*    MOVE: LS_ORDERS-KDAUF TO GS_ORDERC-VBELN,
*          LS_ORDERS-KDPOS TO GS_ORDERC-POSNR.
*    COLLECT GS_ORDERC INTO GT_ORDERC.
*    CLEAR: LS_ORDERS, GS_ORDERC.
*  ENDLOOP.

  LOOP AT GT_OBOTTOM ASSIGNING FIELD-SYMBOL(<FS_B>).
    <FS_B>-COMP_QTY = <FS_B>-MENGE * ( 1 + ( <FS_B>-KAUSF / 100 ) ).
    READ TABLE GT_STOP INTO DATA(GS) WITH KEY JOB_NO        = <FS_B>-JOB_NO
                                              LINE_NO       = <FS_B>-LINE_NO
                                              SERIAL_INFO   = <FS_B>-SERIAL_INFO
                                              PRCSS_SEQ     = <FS_B>-PRCSS_SEQ
                                              PRCSS_SUB_SEQ = <FS_B>-PRCSS_SUB_SEQ.
    IF SY-SUBRC EQ 0 AND GS-LEN_ORDGB EQ GC_Y.
      <FS_B>-L1L7 = GS-L1L7.
    ENDIF.
    CLEAR: GS.
  ENDLOOP.

*  IF P_C1 EQ GC_X.   "변경 데이터만 조회
*    DELETE GT_STOP WHERE APPL_STAT EQ ICON_LED_GREEN.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_C .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3070TOP'
      I_INTERNAL_TABNAME     = 'GS_CTOP'
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
      IT_DATA         = GT_CTOP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "생성상태
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ORD_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "생성메시지
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "생산오더번호
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'COMP_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "구성부품 등록
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'COMP_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "등록 메시지
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "판매오더번호
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "판매오더품목
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "제품내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LINE_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "라인번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'SERIAL_INFO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "시리얼정보
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "제품코드
        <LS_FCAT>-JUST = GC_C.
*      WHEN 'MAKTX'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "제품내역
*        <LS_FCAT>-JUST = GC_L.
      WHEN 'OPER_CODE_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "ERP공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "ERP공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'LEN_ORDGB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F42. "길이별 오더구분
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_CODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "MES공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "MES공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'OPER_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'OPER_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-DO_SUM = GC_X.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F46. "재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-DO_SUM = GC_X.
      WHEN 'L1L7'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F43. "L1~L7
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '35'.
      WHEN 'ZSTD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F45. "표준피더여부
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "오더시작일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "오더종료일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VERID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "생산버전
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NO_DISP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F47. "제번 조회 제외
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF <LS_FCAT>-FIELDNAME = 'ORD_STAT' OR <LS_FCAT>-FIELDNAME = 'ORD_MSG' OR
       <LS_FCAT>-FIELDNAME = 'AUFNR'    OR
       <LS_FCAT>-FIELDNAME = 'COMP_ID'  OR <LS_FCAT>-FIELDNAME = 'COMP_MSG'.

    ELSE.
      CLEAR: <LS_FCAT>-KEY.
    ENDIF.

    IF <LS_FCAT>-FIELDNAME = 'MATNR' OR
       <LS_FCAT>-FIELDNAME = 'LEN_ORDGB'.
      <LS_FCAT>-NO_OUT = GC_X.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_S .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3070TOP'
      I_INTERNAL_TABNAME     = 'GS_STOP'
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
      IT_DATA         = GT_STOP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
*      WHEN 'APPL_STAT'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "최종 적용여부
*        <LS_FCAT>-KEY = GC_X.
*        <LS_FCAT>-JUST = GC_C.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "생산오더번호
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ORDSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F44. "생산오더상태
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'UPD_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "처리 상태
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'UPD_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "처리 메시지
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'LINE_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "라인번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'SERIAL_INFO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "시리얼정보
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "제품코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "제품내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'OPER_CODE_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "ERP공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME_E'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "ERP공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'LEN_ORDGB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F42. "길이별 오더구분
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_CODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "MES공정
        <LS_FCAT>-JUST = GC_C.
      WHEN 'OPER_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "MES공정명
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'OPER_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'OPER_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F46. "재고수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'L1L7'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F43. "L1~L7
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '35'.
      WHEN 'ZSTD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F45. "표준피더여부
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "오더시작일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "오더종료일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VERID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "생산버전
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF "<LS_FCAT>-FIELDNAME = 'APPL_STAT' OR
       <LS_FCAT>-FIELDNAME = 'AUFNR'    OR <LS_FCAT>-FIELDNAME = 'ORDSTAT' OR
       <LS_FCAT>-FIELDNAME = 'UPD_STAT' OR <LS_FCAT>-FIELDNAME = 'UPD_MSG'.

    ELSE.
      CLEAR: <LS_FCAT>-KEY.
    ENDIF.

    IF <LS_FCAT>-FIELDNAME = 'MATNR' OR <LS_FCAT>-FIELDNAME = 'MAKTX' OR
       <LS_FCAT>-FIELDNAME = 'LEN_ORDGB'.
      <LS_FCAT>-NO_OUT = GC_X.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_DATA_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_DATA_S  USING    P_LINE LIKE GS_STOP.

  CLEAR: GT_BOTTOM.
  LOOP AT GT_STOPS INTO DATA(LS_STOPS) WHERE KDAUF      EQ P_LINE-KDAUF
                                         AND KDPOS      EQ P_LINE-KDPOS
                                         AND OPER_MATNR EQ P_LINE-OPER_MATNR
                                         AND L1L7       EQ P_LINE-L1L7.

    LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_STOPS-JOB_NO
                                            AND LINE_NO       EQ LS_STOPS-LINE_NO
                                            AND SERIAL_INFO   EQ LS_STOPS-SERIAL_INFO
                                            AND PRCSS_SEQ     EQ LS_STOPS-PRCSS_SEQ
                                            AND PRCSS_SUB_SEQ EQ LS_STOPS-PRCSS_SUB_SEQ
                                            AND L1L7          EQ LS_STOPS-L1L7.

      MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
      CLEAR: GS_BOTTOM-MTRL_SEQ.

      COLLECT GS_BOTTOM INTO GT_BOTTOM.
      CLEAR: GS_BOTTOM, LS_OBTM.
    ENDLOOP.
    CLEAR: LS_STOPS.
  ENDLOOP.

  IF GT_BOTTOM IS INITIAL.
    READ TABLE GT_OBOTTOM INTO LS_OBTM WITH KEY JOB_NO        = P_LINE-JOB_NO
                                                LINE_NO       = P_LINE-LINE_NO
                                                SERIAL_INFO   = P_LINE-SERIAL_INFO
                                                PRCSS_SEQ     = P_LINE-BUS_PRCSS_SEQ
                                                PRCSS_SUB_SEQ = P_LINE-PRCSS_SUB_SEQ
                                                L1L7          = P_LINE-L1L7.

    MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
    CLEAR: GS_BOTTOM-MTRL_SEQ.

    COLLECT GS_BOTTOM INTO GT_BOTTOM.
    CLEAR: GS_BOTTOM, LS_OBTM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDUPD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM PROCESS_ORDUPD .
*  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
*        L_ANSWER  TYPE CHAR01.
*
*  DATA: LT_STOPSEL LIKE TABLE OF GS_STOP.
*
*  FIELD-SYMBOLS: <FS_S> LIKE GS_STOP.
*
*  CLEAR: L_ANSWER.
*
*  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
*                      USING  GO_GRID_0100.
*
*  IF LT_ROW_NO[] IS INITIAL.
*    MESSAGE S003 DISPLAY LIKE GC_W
*       WITH TEXT-M01. "실행 할 레코드를 선택하세요.
*    EXIT.
*  ENDIF.
*
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      TITLEBAR              = TEXT-T08 "생산오더 업데이트
*      TEXT_QUESTION         = TEXT-T09 "해당 생산오더에 업데이트 사항을 반영하시겠습니까?
*      DISPLAY_CANCEL_BUTTON = SPACE
*    IMPORTING
*      ANSWER                = L_ANSWER.
*
*  IF L_ANSWER = '1'.
*
*    CLEAR: GT_STOPS.
*    APPEND LINES OF GT_STOP TO GT_STOPS.
*
*    CLEAR: LT_STOPSEL.
*    LOOP AT LT_ROW_NO.
*      READ TABLE GT_STOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.
*
*      IF <FS_S>-APPL_STAT EQ ICON_LED_GREEN.
*        <FS_S>-UPD_MSG = TEXT-M11. "생산오더에 반영할 업데이트 사항이 없습니다.
*      ELSE.
**- 선택한 데이터
*        APPEND <FS_S> TO LT_STOPSEL.
*      ENDIF.
*    ENDLOOP.
*
**-선택한 데이터를 오더 기준으로 중복 제거
*    SORT LT_STOPSEL BY AUFNR.
*    DELETE ADJACENT DUPLICATES FROM LT_STOPSEL COMPARING AUFNR.
*
**-선택한 데이터를 오더 기준으로 업데이트 및 품목 등록
*    LOOP AT LT_STOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
*      PERFORM EXEC_ORD_UPDATE USING <FS_SEL>.
*    ENDLOOP.
*
**-처리 결과 ALV 적용
*    LOOP AT GT_STOP ASSIGNING <FS_S> WHERE UPD_STAT NE ICON_LED_GREEN.
*      READ TABLE LT_STOPSEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
*      IF SY-SUBRC EQ 0.
*        <FS_S>-UPD_STAT = LS_SEL-UPD_STAT.
*        <FS_S>-UPD_MSG = LS_SEL-UPD_MSG.
*
**-처리 결과 DB 업데이트(성공건만)
*        IF LS_SEL-UPD_STAT EQ ICON_LED_GREEN.
*          UPDATE ZGTPPT3150 SET ZIF_APPLIED = <FS_S>-ZIF_LAST
*                          WHERE JOB_NO      = <FS_S>-JOB_NO
*                            AND LINE_NO     = <FS_S>-LINE_NO
*                            AND SERIAL_INFO = <FS_S>-SERIAL_INFO.
*          COMMIT WORK.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*    " REFRESH DISPLAY
*    PERFORM REF_ALV_RTN USING GO_GRID_0100.
*
*  ENDIF.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
*FORM EXEC_ORD_UPDATE  USING    P_LINE LIKE GS_STOP.
*
*  DATA: LS_ORDDATA  TYPE BAPI_PP_ORDER_CHANGE,
*        LS_ORDDATAX TYPE BAPI_PP_ORDER_CHANGEX,
*        LS_RETURN   TYPE BAPIRET2,
*        LV_READ     TYPE BAPIFLAG-BAPIFLAG.
*
**- 판매오더+품목+생산자재 기준의 수량 sum
*  READ TABLE GT_ORDERC INTO DATA(LS_ORDERC) WITH KEY VBELN      = P_LINE-KDAUF
*                                                     POSNR      = P_LINE-KDPOS
*                                                     OPER_MATNR = P_LINE-OPER_MATNR
*                                                     L1L7       = P_LINE-L1L7.
*
*  CLEAR: LS_ORDDATA, LS_ORDDATAX, LS_RETURN, LV_READ.
*
*  LS_ORDDATA-EXPLOSION_DATE = SY-DATUM.
*  LS_ORDDATA-EXPLODE_NEW = GC_X.
*  LS_ORDDATA-QUANTITY = P_LINE-MENGE.   "LS_ORDERC-MENGE
*
*  LS_ORDDATAX-EXPLOSION_DATE = GC_X.
*  LS_ORDDATAX-QUANTITY = GC_X.
*
*  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
*    EXPORTING
*      NUMBER           = P_LINE-AUFNR
*      ORDERDATA        = LS_ORDDATA
*      ORDERDATAX       = LS_ORDDATAX
*    IMPORTING
*      RETURN           = LS_RETURN
*      MASTER_DATA_READ = LV_READ.
*
*  WAIT UP TO 1 SECONDS.
*
*  IF LV_READ NE GC_X.
*    P_LINE-UPD_STAT = ICON_LED_RED.
*    P_LINE-UPD_MSG = LS_RETURN-MESSAGE.
*
*  ELSEIF LV_READ EQ GC_X.
*    PERFORM COMPONENT_ADD_UPDATE USING P_LINE.
*  ENDIF.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPONENT_ADD_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
*FORM COMPONENT_ADD_UPDATE  USING    P_LINE LIKE GS_STOP.
*
*  DATA: LT_BOTTOM LIKE TABLE OF GS_BOTTOM.
*
*  CLEAR: LT_BOTTOM.
*  LOOP AT GT_STOPS INTO DATA(LS_STOPS) WHERE KDAUF      EQ P_LINE-KDAUF
*                                         AND KDPOS      EQ P_LINE-KDPOS
*                                         AND OPER_MATNR EQ P_LINE-OPER_MATNR
*                                         AND L1L7       EQ P_LINE-L1L7.
*
*    LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_STOPS-JOB_NO
*                                            AND LINE_NO       EQ LS_STOPS-LINE_NO
*                                            AND SERIAL_INFO   EQ LS_STOPS-SERIAL_INFO
*                                            AND PRCSS_SEQ     EQ LS_STOPS-PRCSS_SEQ
*                                            AND PRCSS_SUB_SEQ EQ LS_STOPS-PRCSS_SUB_SEQ
*                                            AND L1L7          EQ LS_STOPS-L1L7.
*
*      MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
*
*      COLLECT GS_BOTTOM INTO LT_BOTTOM.
*      CLEAR: GS_BOTTOM, LS_OBTM.
*    ENDLOOP.
*    CLEAR: LS_STOPS.
*  ENDLOOP.
*
*  IF LT_BOTTOM IS INITIAL.
*    P_LINE-UPD_STAT = ICON_LED_RED.
*    P_LINE-UPD_MSG = TEXT-M07. "등록할 품목이 없습니다.
*
*  ELSE.
*    CLEAR: GV_POSNR.
*
*    LOOP AT LT_BOTTOM INTO DATA(LS_BOTTOM).
*      CLEAR: GS_STORAGE_LOCATION, GS_STORAGE_LOCATIONX.
*      SELECT SINGLE LGPRO
*        INTO GS_STORAGE_LOCATION-LGORT
*        FROM MARC
*       WHERE MATNR EQ LS_BOTTOM-MATNR.
*
*      GS_STORAGE_LOCATION-WERKS = P_LINE-WERKS.
*
*      GS_STORAGE_LOCATIONX-WERKS = GC_X.
*      GS_STORAGE_LOCATIONX-LGORT = GC_X.
*
*      CLEAR: GS_REQU_QUAN.
*      GS_REQU_QUAN-QUANTITY = LS_BOTTOM-COMP_QTY.
*      CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
*        EXPORTING
*          ISO_CODE  = LS_BOTTOM-MEINS
*        IMPORTING
*          SAP_CODE  = GS_REQU_QUAN-UOM
*        EXCEPTIONS
*          NOT_FOUND = 1
*          OTHERS    = 2.
*
*      CLEAR: GV_OPERATION, GV_SEQUENCE.
*      SELECT SINGLE B~APLZL B~PLNFL
*        INTO (GV_OPERATION, GV_SEQUENCE)
*        FROM AFKO AS A
*       INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
*       WHERE A~AUFNR EQ P_LINE-AUFNR.
*
*      CLEAR: GV_SOBKZ, GV_SOBKZX, GV_KDAUF, GV_KDAUFX, GV_KDPOS, GV_KDPOSX.
*      IF LS_BOTTOM-SBDKZ EQ '1'.
*        GV_SOBKZ = GC_E.
*        GV_SOBKZX = GC_X.
*        GV_KDAUF = P_LINE-KDAUF.
*        GV_KDAUFX = GC_X.
*        GV_KDPOS = P_LINE-KDPOS.
*        GV_KDPOSX = GC_X.
*      ENDIF.
*
*      CLEAR: GV_POSTP, GV_POSITIONNO.
*      GV_POSTP = GC_L.
*
*      GV_POSNR = GV_POSNR + 10.
*      CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
*        EXPORTING
*          INPUT  = GV_POSNR
*        IMPORTING
*          OUTPUT = GV_POSITIONNO.
*
*      CALL FUNCTION 'CO_XT_COMPONENT_ADD'
*        EXPORTING
*          IS_ORDER_KEY         = P_LINE-AUFNR
*          I_MATERIAL           = LS_BOTTOM-MATNR
*          IS_REQU_QUAN         = GS_REQU_QUAN
*          I_OPERATION          = GV_OPERATION
*          I_SEQUENCE           = GV_SEQUENCE
*          IS_STORAGE_LOCATION  = GS_STORAGE_LOCATION
*          IS_STORAGE_LOCATIONX = GS_STORAGE_LOCATIONX
*          I_POSTP              = GV_POSTP
*          I_SOBKZ              = GV_SOBKZ
*          I_SOBKZX             = GV_SOBKZX
*          I_KDAUF              = GV_KDAUF
*          I_KDAUFX             = GV_KDAUFX
*          I_KDPOS              = GV_KDPOS
*          I_KDPOSX             = GV_KDPOSX
*          I_POSNO              = GV_POSITIONNO
*        IMPORTING
*          ES_BAPIRETURN        = GS_RETURN
*          E_ERROR_OCCURRED     = GV_ERROR.
*
*      IF GV_ERROR IS NOT INITIAL.
*        P_LINE-UPD_STAT = ICON_LED_RED.
*        P_LINE-UPD_MSG = TEXT-M13. "생산오더 업데이트 도중 오류가 발생하였습니다.
*
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*
*    IF GV_ERROR EQ SPACE.
*      CLEAR: GV_NUMC.
*      ASSIGN ('(SAPLCOBC)RESB_BT[]') TO <FT_RESB_BT>.
*      LOOP AT <FT_RESB_BT> ASSIGNING <FS_RESB_BT>.
*        GV_NUMC = SY-TABIX * 10.
*        <FS_RESB_BT>-POSNR = GV_NUMC.
*        CLEAR GV_NUMC.
*        READ TABLE LT_BOTTOM INTO DATA(LS_BTM) WITH KEY MATNR = <FS_RESB_BT>-MATNR.
*        IF SY-SUBRC EQ 0.
*          IF LS_BTM-RGEKZ EQ '1'.
*            <FS_RESB_BT>-RGEKZ = GC_X.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      CALL FUNCTION 'CO_ZV_ORDER_POST'
*        EXPORTING
*          COMMIT_FLAG             = SPACE
*          EXT_FLG                 = 'X'
*          TRANS_TYP               = 'V'
*          NO_DIALOG               = 'X'
*          IV_COMMIT_WORK_AND_WAIT = 'X'
*        EXCEPTIONS
*          NO_CHANGE               = 01
*          UPDATE_REJECT           = 02
*          ERROR_MESSAGE           = 03.
*      IF SY-SUBRC EQ 0.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
*
*        P_LINE-UPD_STAT = ICON_LED_GREEN.
*        P_LINE-UPD_MSG = TEXT-M12. "생산오더의 업데이트 반영이 성공하였습니다.
*      ELSE.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*        P_LINE-UPD_STAT = ICON_LED_RED.
*        P_LINE-UPD_MSG = TEXT-M13. "생산오더 업데이트 도중 오류가 발생하였습니다.
*      ENDIF.
*
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      P_LINE-UPD_STAT = ICON_LED_RED.
*      P_LINE-UPD_MSG = TEXT-M13. "생산오더 업데이트 도중 오류가 발생하였습니다.
*
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
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
    MESSAGE E006 WITH TEXT-M14 P_WERKS TEXT-M15.
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

  IF P_R1 EQ GC_X.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                          USING : 1 'VBELN'        'X' '' '',
                                  2 'POSNR'        'X' '' '',
                                  3 'JOB_NO'       'X' '' '',
                                  4 'JOB_NM'       'X' '' '',
                                  5 'OPER_CODE_E'  'X' '' '',
                                  6 'OPER_NAME_E'  'X' '' ''.
  ELSEIF P_R2 EQ GC_X.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                          USING : 1 'KDAUF'        'X' '' '',
                                  2 'KDPOS'        'X' '' '',
                                  3 'JOB_NO'       'X' '' '',
                                  4 'JOB_NM'       'X' '' '',
                                  5 'OPER_CODE_E'  'X' '' '',
                                  6 'OPER_NAME_E'  'X' '' ''.
  ENDIF.

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
*& Form set_bottom_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_DATA .

  SORT GT_BOTTOM BY OPER_CODE_E OPER_MATNR L1L7 MATNR.

  CLEAR: GV_SEQ.
  LOOP AT GT_BOTTOM ASSIGNING FIELD-SYMBOL(<FS>).
    GV_SEQ = GV_SEQ + 1.
    <FS>-MTRL_SEQ = GV_SEQ.

    READ TABLE GT_OBOTTOM INTO DATA(LS_OBTM)
                          WITH KEY OPER_MATNR = <FS>-OPER_MATNR
                                   MATNR      = <FS>-MATNR.
    IF SY-SUBRC EQ 0.
      <FS>-KAUSF = LS_OBTM-KAUSF.
    ENDIF.
    CLEAR: LS_OBTM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDITEMCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ORDITEMCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_CTOPSEL LIKE TABLE OF GS_CTOP.
  DATA: LT_BOTTOM LIKE TABLE OF GS_BOTTOM.

  FIELD-SYMBOLS: <FS_S> LIKE GS_CTOP.

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
      TITLEBAR              = TEXT-T10 "생산오더 생성 및 구성부품 등록
      TEXT_QUESTION         = TEXT-T11 "생산오더 생성 및 구성부품 등록을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GT_CTOPS.
    APPEND LINES OF GT_CTOP TO GT_CTOPS.

    CLEAR: LT_CTOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CTOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ORD_STAT EQ ICON_LED_GREEN.
        <FS_S>-ORD_MSG = TEXT-M02. "이미 생산오더가 생성되었습니다.
      ELSEIF <FS_S>-ORD_STAT EQ ICON_MESSAGE_ERROR.
        <FS_S>-ORD_MSG = TEXT-M19. "소요량이 0인 구성품이 존재합니다. 데이터를 점검하세요.
      ELSEIF <FS_S>-ORD_STAT EQ ICON_LED_RED.
        <FS_S>-ORD_MSG = TEXT-M20. "이미 재고가 존재하여 생산오더를 생성하지 않습니다.
      ELSE.
        CLEAR: LT_BOTTOM.
        LOOP AT GT_CTOPS INTO DATA(LS_CTOPS) WHERE VBELN      EQ <FS_S>-VBELN
                                               AND POSNR      EQ <FS_S>-POSNR
                                               AND OPER_MATNR EQ <FS_S>-OPER_MATNR
                                               AND L1L7       EQ <FS_S>-L1L7.

          LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_CTOPS-JOB_NO
                                                  AND LINE_NO       EQ LS_CTOPS-LINE_NO
                                                  AND SERIAL_INFO   EQ LS_CTOPS-SERIAL_INFO
                                                  AND PRCSS_SEQ     EQ LS_CTOPS-PRCSS_SEQ
                                                  AND PRCSS_SUB_SEQ EQ LS_CTOPS-PRCSS_SUB_SEQ
                                                  AND L1L7          EQ LS_CTOPS-L1L7.

            MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.

            COLLECT GS_BOTTOM INTO LT_BOTTOM.
            CLEAR: GS_BOTTOM, LS_OBTM.
          ENDLOOP.
          CLEAR: LS_CTOPS.
        ENDLOOP.

        IF LT_BOTTOM IS INITIAL.
          READ TABLE GT_OBOTTOM INTO LS_OBTM WITH KEY JOB_NO        = <FS_S>-JOB_NO
                                                      LINE_NO       = <FS_S>-LINE_NO
                                                      SERIAL_INFO   = <FS_S>-SERIAL_INFO
                                                      PRCSS_SEQ     = <FS_S>-BUS_PRCSS_SEQ
                                                      PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ
                                                      L1L7          = <FS_S>-L1L7.

          MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.

          COLLECT GS_BOTTOM INTO LT_BOTTOM.
          CLEAR: GS_BOTTOM, LS_OBTM.
        ENDIF.

        IF LT_BOTTOM IS INITIAL.
          <FS_S>-ORD_MSG = TEXT-M07. "등록할 품목이 없습니다.
          CLEAR: LT_BOTTOM.
        ELSE.
*- 선택한 데이터
          APPEND <FS_S> TO LT_CTOPSEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택된 데이터를 판매오더+품목+생산품목 기준으로 중복 제거
    SORT LT_CTOPSEL BY VBELN POSNR OPER_MATNR L1L7.
    DELETE ADJACENT DUPLICATES FROM LT_CTOPSEL
                          COMPARING VBELN POSNR OPER_MATNR L1L7.

    SORT LT_CTOPSEL BY VBELN POSNR OPER_CODE_E.

*-선택된 데이터를 판매오더+품목+생산품목 기준으로 오더 생성
    LOOP AT LT_CTOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_ORD_CREATE USING <FS_SEL>.
      IF <FS_SEL>-AUFNR IS NOT INITIAL AND <FS_SEL>-ORD_STAT EQ ICON_LED_GREEN.
        PERFORM EXEC_ITEM_CREATE USING <FS_SEL>.
      ENDIF.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_CTOP ASSIGNING <FS_S> WHERE ORD_STAT NE ICON_LED_GREEN
                                       AND AUFNR EQ SPACE.
      READ TABLE LT_CTOPSEL INTO DATA(LS_SEL) WITH KEY VBELN      = <FS_S>-VBELN
                                                       POSNR      = <FS_S>-POSNR
                                                       OPER_MATNR = <FS_S>-OPER_MATNR
                                                       L1L7       = <FS_S>-L1L7.
      IF SY-SUBRC EQ 0.
        <FS_S>-ORD_STAT = LS_SEL-ORD_STAT.
        <FS_S>-ORD_MSG = LS_SEL-ORD_MSG.
        <FS_S>-AUFNR = LS_SEL-AUFNR.

        <FS_S>-COMP_ID = LS_SEL-COMP_ID.
        <FS_S>-COMP_MSG = LS_SEL-COMP_MSG.

*-처리 결과 DB 업데이트(성공건만) - 오더생성 및 구성부품등록 모두 성공
        IF LS_SEL-AUFNR IS NOT INITIAL AND LS_SEL-ORD_STAT EQ ICON_LED_GREEN.
          IF LS_SEL-COMP_ID EQ ICON_LED_GREEN.
            UPDATE ZGTPPT3150 SET ZIF_APPLIED = <FS_S>-ZIF_LAST
                            WHERE JOB_NO      = <FS_S>-JOB_NO
                              AND LINE_NO     = <FS_S>-LINE_NO
                              AND SERIAL_INFO = <FS_S>-SERIAL_INFO.

            UPDATE ZGTPPT3160 SET AUFNR         = <FS_S>-AUFNR
                                  COMP_STAT     = GC_Y
                            WHERE JOB_NO        = <FS_S>-JOB_NO
                              AND LINE_NO       = <FS_S>-LINE_NO
                              AND SERIAL_INFO   = <FS_S>-SERIAL_INFO
                              AND PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                              AND PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.
*** 2025.04.24 주석 처리 pys s
*                              AND ( ZMODE NE GC_P AND ZMODE NE GC_K ).
*** 2025.04.24 주석 처리 pys e
            COMMIT WORK.

*-전송할 생산오더
            GS_AUFNR_SEND-AUFNR = LS_SEL-AUFNR.
            SELECT SINGLE ERDAT
              FROM AUFK
             WHERE AUFNR EQ @LS_SEL-AUFNR
              INTO @GS_AUFNR_SEND-ERDAT.

            COLLECT GS_AUFNR_SEND INTO GT_AUFNR_SEND.
            CLEAR: GS_AUFNR_SEND.

*-처리 결과 DB 업데이트(성공건만) - 오더생성만 성공한 경우
          ELSE.
            UPDATE ZGTPPT3150 SET ZIF_APPLIED = <FS_S>-ZIF_LAST
                            WHERE JOB_NO      = <FS_S>-JOB_NO
                              AND LINE_NO     = <FS_S>-LINE_NO
                              AND SERIAL_INFO = <FS_S>-SERIAL_INFO.

            UPDATE ZGTPPT3160 SET AUFNR         = <FS_S>-AUFNR
                            WHERE JOB_NO        = <FS_S>-JOB_NO
                              AND LINE_NO       = <FS_S>-LINE_NO
                              AND SERIAL_INFO   = <FS_S>-SERIAL_INFO
                              AND PRCSS_SEQ     = <FS_S>-PRCSS_SEQ
                              AND PRCSS_SUB_SEQ = <FS_S>-PRCSS_SUB_SEQ.
*** 2025.04.24 주석 처리 pys s
*                              AND ( ZMODE NE GC_P AND ZMODE NE GC_K ).
*** 2025.04.24 주석 처리 pys e

            COMMIT WORK.

          ENDIF.

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
    LOOP AT LT_JOB_STATUS INTO DATA(LS_JOB) WHERE FLD_02 IS NOT INITIAL.
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
      LOOP AT LT_JOB_NO INTO DATA(LS_JOB_NO).
        GR_JOB_NO-SIGN   = GC_I.
        GR_JOB_NO-OPTION = GC_EQ.
        GR_JOB_NO-LOW    = LS_JOB_NO-ZJOB_NO.
        COLLECT GR_JOB_NO.
      ENDLOOP.
    ENDIF.
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

  DATA: LT_STOPSEL LIKE TABLE OF GS_STOP.

  DATA: BEGIN OF LS_STAT,
          STAT TYPE CHAR100,
        END OF LS_STAT,
        LT_STAT LIKE TABLE OF LS_STAT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_STOP.

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
      TITLEBAR              = TEXT-T12 "생산오더 생성 취소
      TEXT_QUESTION         = TEXT-T13 "해당 생산오더의 생성을 취소하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_STOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_STOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS INITIAL.
        <FS_S>-UPD_MSG = TEXT-M16. "생산오더가 이미 삭제된 상태입니다.
      ELSE.
        IF <FS_S>-ORDSTAT IS NOT INITIAL.
          CLEAR: LS_STAT, LT_STAT.
          SPLIT <FS_S>-ORDSTAT AT '/' INTO TABLE LT_STAT.

          IF LINE_EXISTS( LT_STAT[ STAT = 'CNF' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'DLV' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'PCNF' ] ) OR
             LINE_EXISTS( LT_STAT[ STAT = 'PDLV' ] ).
            <FS_S>-UPD_MSG = TEXT-M18. "실적이 입력된 생산오더는 삭제 설정이 불가합니다.
          ELSE.
*- 선택한 데이터
            APPEND <FS_S> TO LT_STOPSEL.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 오더 기준으로 중복 제거
    SORT LT_STOPSEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_STOPSEL COMPARING AUFNR.

*-선택한 데이터를 오더 기준으로 삭제 플래그 설정
    LOOP AT LT_STOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_ORD_DELETE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_STOP ASSIGNING <FS_S> WHERE AUFNR IS NOT INITIAL.
      READ TABLE LT_STOPSEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
      IF SY-SUBRC EQ 0.
        <FS_S>-UPD_STAT = LS_SEL-UPD_STAT.
        <FS_S>-UPD_MSG = LS_SEL-UPD_MSG.

*-처리 결과 DB 업데이트(성공건만)
        IF LS_SEL-UPD_STAT EQ ICON_LED_GREEN.
          UPDATE ZGTPPT3160 SET AUFNR = SPACE
                                COMP_STAT = SPACE
                          WHERE AUFNR = <FS_S>-AUFNR.

          COMMIT WORK.

*-전송할 생산오더
          GS_AUFNR_SEND-AUFNR = LS_SEL-AUFNR.
          SELECT SINGLE ERDAT
            FROM AUFK
           WHERE AUFNR EQ @LS_SEL-AUFNR
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
*& Form EXEC_ORD_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SEL>
*&---------------------------------------------------------------------*
FORM EXEC_ORD_DELETE  USING    P_LINE LIKE GS_STOP.

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

    P_LINE-UPD_STAT = ICON_LED_GREEN.
    P_LINE-UPD_MSG = TEXT-M17. "생산오더 삭제 설정에 성공하였습니다.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = 'E'.

    P_LINE-UPD_STAT = ICON_LED_RED.
    P_LINE-UPD_MSG = LT_DETAIL_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOB_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_JOB_TYPE .

  TYPES: BEGIN OF LTY_JOB_TYPE,
           FLD_02 LIKE ZGTPPT1010-FLD_02,
         END OF LTY_JOB_TYPE,
         BEGIN OF LTY_JOB_TNO,
           ZJOB_NO LIKE ZGTEDT2121-ZJOB_NO,
         END OF LTY_JOB_TNO.

  DATA: LT_JOB_TYPE TYPE TABLE OF LTY_JOB_TYPE,
        LT_JOB_TNO  TYPE TABLE OF LTY_JOB_TNO.

  CLEAR: LT_JOB_TYPE.
  SELECT FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_3040
     AND FLD_01      EQ @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @LT_JOB_TYPE.

  IF LT_JOB_TYPE IS NOT INITIAL.
    CLEAR: GR_JOB_TYPE, GR_JOB_TYPE[].
    LOOP AT LT_JOB_TYPE INTO DATA(LS_TYPE) WHERE FLD_02 IS NOT INITIAL.
      GR_JOB_TYPE-SIGN   = GC_I.
      GR_JOB_TYPE-OPTION = GC_EQ.
      GR_JOB_TYPE-LOW    = LS_TYPE-FLD_02.
      APPEND GR_JOB_TYPE.
    ENDLOOP.
  ENDIF.

  IF GR_JOB_TYPE[] IS NOT INITIAL.
    CLEAR: LT_JOB_TNO.
    SELECT ZJOB_NO
      FROM ZGTEDT2121
     WHERE ZSYSTEM_ID EQ @GC_KBDM
       AND ZWERKS     EQ @P_WERKS
       AND ZZJOB_TYPE IN @GR_JOB_TYPE
      INTO CORRESPONDING FIELDS OF TABLE @LT_JOB_TNO.

    IF LT_JOB_TNO IS NOT INITIAL.
      LOOP AT LT_JOB_TNO INTO DATA(LS_JOB_TNO).
        GR_JOB_NO-SIGN   = GC_I.
        GR_JOB_NO-OPTION = GC_EQ.
        GR_JOB_NO-LOW    = LS_JOB_TNO-ZJOB_NO.
        COLLECT GR_JOB_NO.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_job_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_JOB_CHECK .
  CLEAR: GR_JOB_NO, GR_JOB_NO[].
  PERFORM GET_JOB_STATUS.
  PERFORM GET_JOB_TYPE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUBMIT_ZGTPPI2010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SUBMIT_ZGTPPI2010.

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
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
*&---------------------------------------------------------------------*
*& Form PROCESS_JOBNOEXC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JOBNOEXC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_CTOPSEL LIKE TABLE OF GS_CTOP.

  FIELD-SYMBOLS: <FS_S> LIKE GS_CTOP.

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
      TITLEBAR              = TEXT-T15 "제번 조회 제외 처리
      TEXT_QUESTION         = TEXT-T16 "선택하신 제번을 조회 제외 처리하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_CTOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CTOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS NOT INITIAL.
        <FS_S>-ORD_MSG = TEXT-M22. "생산오더가 이미 존재하여 조회 제외가 불가합니다.
      ELSE.
        SELECT SINGLE JOB_NO
          FROM ZGTPPT3160
         WHERE JOB_NO EQ @<FS_S>-JOB_NO
           AND AUFNR NE @SPACE
          INTO @DATA(LV_JOBNO).

        IF LV_JOBNO IS NOT INITIAL.
          <FS_S>-ORD_MSG = TEXT-M22. "생산오더가 이미 존재하여 조회 제외가 불가합니다.
        ELSE.
*- 선택한 데이터
          APPEND <FS_S> TO LT_CTOPSEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택된 데이터를 제조지시번호 기준으로 중복 제거
    SORT LT_CTOPSEL BY JOB_NO.
    DELETE ADJACENT DUPLICATES FROM LT_CTOPSEL
                          COMPARING JOB_NO.

    SORT LT_CTOPSEL BY JOB_NO.

*-선택된 데이터를 제조지시번호 기준으로 조회 제외 처리
    LOOP AT LT_CTOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      UPDATE ZGTPPT3150 SET NO_DISP = GC_Y
                      WHERE JOB_NO = <FS_SEL>-JOB_NO.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        <FS_SEL>-NO_DISP = GC_Y.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_CTOP ASSIGNING <FS_S> WHERE NO_DISP EQ SPACE.
      READ TABLE LT_CTOPSEL INTO DATA(LS_SEL) WITH KEY JOB_NO = <FS_S>-JOB_NO.
      IF SY-SUBRC EQ 0.
        <FS_S>-NO_DISP = LS_SEL-NO_DISP.
      ENDIF.
    ENDLOOP.

    MESSAGE S000 WITH TEXT-M24. "처리되었습니다.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_JOBNOEXCCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_JOBNOEXCCAN .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_CTOPSEL LIKE TABLE OF GS_CTOP.

  FIELD-SYMBOLS: <FS_S> LIKE GS_CTOP.

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
      TITLEBAR              = TEXT-T17 "제번 조회 제외 취소 처리
      TEXT_QUESTION         = TEXT-T18 "선택하신 제번을 조회 제외 취소 처리하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_CTOPSEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CTOP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-NO_DISP NE GC_Y.
        <FS_S>-ORD_MSG = TEXT-M23. "조회 제외 처리하지 않은 제번입니다.
      ELSE.
*- 선택한 데이터
        APPEND <FS_S> TO LT_CTOPSEL.
      ENDIF.
    ENDLOOP.

*-선택된 데이터를 제조지시번호 기준으로 중복 제거
    SORT LT_CTOPSEL BY JOB_NO.
    DELETE ADJACENT DUPLICATES FROM LT_CTOPSEL
                          COMPARING JOB_NO.

    SORT LT_CTOPSEL BY JOB_NO.

*-선택된 데이터를 제조지시번호 기준으로 조회 제외 처리 취소
    LOOP AT LT_CTOPSEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      UPDATE ZGTPPT3150 SET NO_DISP = SPACE
                      WHERE JOB_NO = <FS_SEL>-JOB_NO.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        CLEAR: <FS_SEL>-NO_DISP.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_CTOP ASSIGNING <FS_S> WHERE NO_DISP EQ GC_Y.
      READ TABLE LT_CTOPSEL INTO DATA(LS_SEL) WITH KEY JOB_NO = <FS_S>-JOB_NO.
      IF SY-SUBRC EQ 0.
        <FS_S>-NO_DISP = LS_SEL-NO_DISP.
      ENDIF.
    ENDLOOP.

    MESSAGE S000 WITH TEXT-M25. "취소 처리되었습니다.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_IDNRK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_DATA
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHECK_IDNRK_STATUS  USING    P_LINE LIKE GS_CTOP
                                         CHANGING PV_MESSAGE
                                                        PV_CHK_ERR.

  DATA: LT_BOTTOM LIKE TABLE OF GS_BOTTOM.
  DATA : LT_MMSTA TYPE RANGE OF MARC-MMSTA.

* 자재상태가 SPACE or ZA가 아닌 자재
  APPEND INITIAL LINE TO LT_MMSTA ASSIGNING FIELD-SYMBOL(<LS_MMSTA>).
  <LS_MMSTA>-SIGN = 'I'.
  <LS_MMSTA>-OPTION = 'EQ'.

  APPEND INITIAL LINE TO LT_MMSTA ASSIGNING <LS_MMSTA>.
  <LS_MMSTA>-SIGN = 'I'.
  <LS_MMSTA>-OPTION = 'EQ'.
  <LS_MMSTA>-LOW = 'ZA'.


  CLEAR: LT_BOTTOM.
  LOOP AT GT_CTOPS INTO DATA(LS_CTOPS) WHERE VBELN      EQ P_LINE-VBELN
                                         AND POSNR      EQ P_LINE-POSNR
                                         AND OPER_MATNR EQ P_LINE-OPER_MATNR
                                         AND L1L7       EQ P_LINE-L1L7.

    LOOP AT GT_OBOTTOM INTO DATA(LS_OBTM) WHERE JOB_NO        EQ LS_CTOPS-JOB_NO
                                            AND LINE_NO       EQ LS_CTOPS-LINE_NO
                                            AND SERIAL_INFO   EQ LS_CTOPS-SERIAL_INFO
                                            AND PRCSS_SEQ     EQ LS_CTOPS-PRCSS_SEQ
                                            AND PRCSS_SUB_SEQ EQ LS_CTOPS-PRCSS_SUB_SEQ
                                            AND L1L7          EQ LS_CTOPS-L1L7.

      MOVE-CORRESPONDING LS_OBTM TO GS_BOTTOM.
      CLEAR: GS_BOTTOM-MTRL_SEQ.

      COLLECT GS_BOTTOM INTO LT_BOTTOM.
      CLEAR: GS_BOTTOM, LS_OBTM.
    ENDLOOP.
    CLEAR: LS_CTOPS.
  ENDLOOP.

  SORT LT_BOTTOM BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_BOTTOM COMPARING MATNR.

  IF LT_BOTTOM[] IS NOT INITIAL.
    SELECT MATNR, MMSTA FROM MARC
      INTO TABLE @DATA(LT_CHK_IDNRK)
      FOR ALL ENTRIES IN @LT_BOTTOM
     WHERE MATNR = @LT_BOTTOM-MATNR
        AND WERKS = @P_WERKS
        AND MMSTA NOT IN @LT_MMSTA.
    IF SY-SUBRC EQ 0.
      READ TABLE LT_CHK_IDNRK INTO DATA(LS_CHK_IDNRK) INDEX 1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LS_CHK_IDNRK-MATNR
        IMPORTING
          OUTPUT = PV_MESSAGE.
      PV_MESSAGE = PV_MESSAGE && '자재의 상태를 점검하십시요'.
      PV_CHK_ERR = ABAP_TRUE.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LOCK USING PV_CHK.

  DELETE GT_LOCK WHERE JOB_NO IS INITIAL.
  CHECK GT_LOCK[] IS NOT INITIAL.

  SORT GT_LOCK BY JOB_NO.
  DELETE ADJACENT DUPLICATES FROM GT_LOCK COMPARING JOB_NO.

  PERFORM ENQUEUE_READ USING 'ZGTPPT3160'.

  IF GT_ENQ[] IS NOT INITIAL AND PV_CHK = GC_X.
    LOOP AT GT_LOCK.
      READ TABLE GT_ENQ WITH KEY GARG+3(10) = GT_LOCK-JOB_NO
                                 BINARY SEARCH.

      IF SY-SUBRC = 0.
        MESSAGE I000 WITH GT_LOCK-JOB_NO '제조지시번호는 사용자' GT_ENQ-GUNAME
                                '가 잠궜습니다.' DISPLAY LIKE 'E'.
        GV_LCK = GC_X.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CHECK GV_LCK IS INITIAL.

  LOOP AT GT_LOCK.
    PERFORM ENQUEUE  USING GT_LOCK-JOB_NO.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENQUEUE_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM ENQUEUE_READ USING PV_TNM.

  CLEAR : GT_ENQ[].

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GNAME                 = CONV EQEGRANAME( PV_TNM )
      GUNAME                = '*'
    TABLES
      ENQ                   = GT_ENQ
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  SORT GT_ENQ BY GARG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENQUEUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LOCK_JOB_NO
*&---------------------------------------------------------------------*
FORM ENQUEUE USING PV_JOB_NO.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR3070'
    EXPORTING
      MODE_ZGTPPT3160 = 'E'
      JOB_NO          = PV_JOB_NO
    EXCEPTIONS
      FOREIGN_LOCK    = 1
      SYSTEM_FAILURE  = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEQUEUE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM dequeue_obj .

      IF GV_LCK IS INITIAL.
        CALL FUNCTION 'DEQUEUE_ALL'.
      ENDIF.

ENDFORM.
