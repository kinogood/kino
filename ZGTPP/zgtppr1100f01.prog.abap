*&---------------------------------------------------------------------*
*& Include          ZGTPPR1100F01
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
      WHEN 'P_WERKS' OR 'S_WERKS-LOW' OR 'S_SPART-LOW' OR 'P_FILE'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R5 EQ GC_X.   "제품,반제품,상품
      IF P_R7 = GC_X.
        CLEAR P_R7.
        P_R1 = GC_X.
      ENDIF.

      IF P_R3 EQ GC_X.  "수기
        IF SCREEN-GROUP1 = 'S4' OR SCREEN-GROUP1 = 'S5'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF P_R1 EQ GC_X.     "신규
          IF SCREEN-GROUP1 = 'S2' OR
             SCREEN-GROUP1 = 'S9' OR
             SCREEN-GROUP1 = 'S10'.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
          ENDIF.

        ELSEIF P_R2 EQ GC_X. "수정
          IF SCREEN-GROUP1 = 'S1' OR
             SCREEN-GROUP1 = 'S7' OR
             SCREEN-GROUP1 = 'S10'.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

        CLEAR: SSCRFIELDS-FUNCTXT_01.

        GV_TITLE = TEXT-T03. "조회 옵션

      ELSEIF P_R4 EQ GC_X.  "엑셀업로드
        IF SCREEN-GROUP1 = 'S1' OR
           SCREEN-GROUP1 = 'S2' OR
           SCREEN-GROUP1 = 'S3' OR
           SCREEN-GROUP1 = 'S5' OR
           SCREEN-GROUP1 = 'S7' OR
           SCREEN-GROUP1 = 'S8' OR
           SCREEN-GROUP1 = 'S9' OR
           SCREEN-GROUP1 = 'S10'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        CLEAR: SSCRFIELDS-FUNCTXT_01.
        SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT1.

        GV_TITLE = TEXT-T08. "업로드 파일
      ENDIF.

    ELSEIF P_R6 EQ GC_X.   "원자재,부자재
      IF SCREEN-GROUP1 = 'S4' OR
         SCREEN-GROUP1 = 'S6' OR
         SCREEN-GROUP1 = 'S7' OR
         SCREEN-GROUP1 = 'S8' OR
         SCREEN-GROUP1 = 'S9'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

      IF P_R2 EQ GC_X OR
         P_R7 EQ GC_X.
        IF SCREEN-GROUP1 = 'S1' OR
           SCREEN-GROUP1 = 'S9'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      CLEAR: SSCRFIELDS-FUNCTXT_01.
      SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT2.

      GV_TITLE = TEXT-T03. "조회 옵션

    ENDIF.

  ENDLOOP.
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

  IF P_R5 EQ GC_X.
    IF P_R3 EQ GC_X.
      IF P_R2 EQ GC_X.
        IF S_WERKS-LOW IS INITIAL.
          MESSAGE S003 DISPLAY LIKE 'E'
             WITH TEXT-M02. "필수 필드 "플랜트"에 입력하십시오.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDIF.

      IF S_SPART-LOW IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH TEXT-M01. "필수 필드 "제품군"에 입력하십시오.
        LEAVE LIST-PROCESSING.
      ENDIF.

    ELSEIF P_R4 EQ GC_X.
      IF P_FILE IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH TEXT-M08. "필수 필드 "파일 경로"에 입력하십시오.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

  ELSEIF P_R6 EQ GC_X.
    IF P_WERKS IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M02. "필수 필드 "플랜트"에 입력하십시오.
      LEAVE LIST-PROCESSING.
    ENDIF.
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

  IF P_R5 EQ GC_X.            "제품,반제품,상품
    IF P_R3 EQ GC_X.            "수기
      IF P_R1 EQ GC_X.            "신규
        PERFORM GET_DATA_N.
      ELSEIF P_R2 EQ GC_X.        "수정
        PERFORM GET_DATA_C.
      ENDIF.
    ELSEIF P_R4 EQ GC_X.        "엑셀업로드
      PERFORM EXCEL_UPLOAD.
      PERFORM CHECK_DATA.
    ENDIF.

  ELSEIF P_R6 EQ GC_X.        "원자재,부자재
    IF P_R1 EQ GC_X.            "신규
      PERFORM GET_DATA_RM_N.
    ELSEIF P_R2 EQ GC_X.        "수정
      PERFORM GET_DATA_RM_C.
    ELSEIF P_R7 EQ GC_X.        "생산저장위치업데이트
      PERFORM GET_DATA_UPDATE.
    ENDIF.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  IF P_R5 EQ GC_X.
    PERFORM MODIFY_DATA.
  ELSEIF P_R6 EQ GC_X.
    PERFORM MODIFY_DATA_RMU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_N
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_N .

  DATA: LS_1010 LIKE GS_1010.

  DATA: LV_WERKS TYPE WERKS_D.

  CLEAR: GT_MARA.
  SELECT A~MATNR, A~SPART, A~MTART, A~SATNR, A~CUOBF,
         B~MAKTX
    FROM MARA AS A
    LEFT OUTER JOIN MAKT AS B ON B~MATNR EQ A~MATNR
                             AND B~SPRAS EQ @SY-LANGU
   WHERE A~SPART IN @S_SPART
     AND A~MTART IN @S_MTART
     AND A~MTART IN ('FERT', 'HALB', 'HAWA', 'MCFE', 'MCHF', 'MCHA')
     AND A~MATNR IN @S_MATNR
     AND A~ERSDA IN @S_ERSDA
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARA.

  CLEAR: GT_1010.
  SELECT FLD_03, FLD_01
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_1030
     AND FLD_01      IN @S_SPART
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

  CLEAR: GT_DATA.
  LOOP AT GT_MARA INTO DATA(LS_MARA).
    IF LS_MARA-SPART EQ '23'.
      SELECT SINGLE B~CLASS
        FROM KSSK AS A
       INNER JOIN KLAH AS B ON B~CLINT = A~CLINT
       WHERE A~OBJEK EQ @LS_MARA-MATNR
         AND A~KLART EQ '001'
        INTO @DATA(LV_CLASS).

      IF LV_CLASS = 'FT_GP_CONDUIT' OR LV_CLASS = 'RW_GP_CONDUIT'.
        MOVE-CORRESPONDING LS_MARA TO GS_DATA.
        GS_DATA-WERKS = '6581'.
        GS_DATA-STDPD = LS_MARA-SATNR.

        APPEND GS_DATA TO GT_DATA.
        CLEAR: GS_DATA.

      ELSE.
        CLEAR: LS_1010.
        LOOP AT GT_1010 INTO LS_1010 WHERE FLD_01 EQ LS_MARA-SPART.
          MOVE-CORRESPONDING LS_MARA TO GS_DATA.
          GS_DATA-WERKS = LS_1010-FLD_03.
          GS_DATA-STDPD = LS_MARA-SATNR.

          APPEND GS_DATA TO GT_DATA.
          CLEAR: LS_1010, GS_DATA.
        ENDLOOP.
      ENDIF.

      CLEAR: LV_CLASS.

    ELSE.
      CLEAR: LS_1010.
      LOOP AT GT_1010 INTO LS_1010 WHERE FLD_01 EQ LS_MARA-SPART.
        MOVE-CORRESPONDING LS_MARA TO GS_DATA.
        GS_DATA-WERKS = LS_1010-FLD_03.
        GS_DATA-STDPD = LS_MARA-SATNR.

        APPEND GS_DATA TO GT_DATA.
        CLEAR: LS_1010, GS_DATA.
      ENDLOOP.
    ENDIF.

    CLEAR: LS_MARA.

  ENDLOOP.

  "확장 대상 제외
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF <FS_S>-MTART EQ GC_MCHA OR <FS_S>-MTART EQ GC_HAWA.
      SELECT SINGLE A~MANDT
        FROM MARC AS A
        JOIN MARA AS B ON B~MATNR EQ A~MATNR
       WHERE A~MATNR EQ @<FS_S>-MATNR
         AND A~WERKS EQ @<FS_S>-WERKS
         AND ( A~MMSTA EQ 'ZD' OR B~MATKL NE @SPACE )
        INTO @DATA(LV_MANDT).

      IF SY-SUBRC EQ 0.
        <FS_S>-DEL = GC_X.
        CONTINUE.
      ENDIF.

    ELSE.
      CLEAR: LV_MANDT.
      SELECT SINGLE MANDT
        FROM MARC
       WHERE MATNR EQ @<FS_S>-MATNR
         AND WERKS EQ @<FS_S>-WERKS
         AND ( BESKZ NE @SPACE OR
               MMSTA EQ 'ZD' )
        INTO @LV_MANDT.

      IF SY-SUBRC EQ 0.
        <FS_S>-DEL = GC_X.
        CONTINUE.
      ENDIF.

    ENDIF.

    IF <FS_S>-WERKS CS '91'.
      CLEAR: LV_WERKS.
      LV_WERKS = <FS_S>-WERKS+0(2) && |00|.

      CLEAR: LV_MANDT.
      SELECT SINGLE MANDT
        FROM MARC
       WHERE MATNR EQ @<FS_S>-MATNR
         AND WERKS EQ @LV_WERKS
         AND MMSTA EQ 'ZD'
        INTO @LV_MANDT.

      IF SY-SUBRC EQ 0.
        <FS_S>-DEL = GC_X.
        CONTINUE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  DELETE GT_DATA WHERE DEL EQ GC_X.

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

  DATA: LS_1080 LIKE GS_1080.

  DATA: LT_CONFG TYPE TABLE OF CONF_OUT,
        LS_CONFG TYPE CONF_OUT.

  DATA: LV_DYN(50),
        LV_MATKL   TYPE MATKL,
        LV_MANDT   TYPE MANDT.

  DATA: LV_MATKL_1(1),
        LV_MATKL_23(3),
        LV_MATKL_57(3),
        LV_MATKL_89(2).

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF P_R3 EQ GC_X.
      IF P_R1 EQ GC_X.
        "플랜트 내역
        SELECT SINGLE NAME1
          FROM T001W
         WHERE WERKS EQ @<FS_S>-WERKS
          INTO @<FS_S>-NAME1.

        "제품군 내역
        SELECT SINGLE VTEXT
          FROM TSPAT
         WHERE SPRAS EQ @SY-LANGU
           AND SPART EQ @<FS_S>-SPART
          INTO @<FS_S>-VTEXT.

        "자재유형 내역
        SELECT SINGLE MTBEZ
          FROM T134T
         WHERE SPRAS EQ @SY-LANGU
           AND MTART EQ @<FS_S>-MTART
          INTO @<FS_S>-MTBEZ.

        "자재그룹 자동지정
        PERFORM SET_MATKL USING <FS_S>.

        "자동 자재그룹 지정 후 DEFAULT 값 세팅
        PERFORM GET_DEFLT_ZGTPPT1080 USING <FS_S>.

        "자재그룹 내역
        SELECT SINGLE WGBEZ
          FROM T023T
         WHERE SPRAS EQ @SY-LANGU
           AND MATKL EQ @<FS_S>-MATKL
          INTO @<FS_S>-WGBEZ.

        IF <FS_S>-MATKL IS INITIAL.
          <FS_S>-ZSTAT = ICON_LED_RED.
          <FS_S>-ZMESSAGE = TEXT-M03. "자재그룹을 입력하세요.

          PERFORM SET_STY_RTN USING SPACE
                              CHANGING <FS_S>.
        ELSE.
          <FS_S>-ZSTAT = ICON_LED_INACTIVE.

          PERFORM SET_STY_RTN USING GC_M
                              CHANGING <FS_S>.
        ENDIF.

      ELSEIF P_R2 EQ GC_X.
        IF <FS_S>-MATKL IS INITIAL.
          <FS_S>-ZSTAT = ICON_LED_RED.
          <FS_S>-ZMESSAGE = TEXT-M03. "자재그룹을 입력하세요.

          PERFORM SET_STY_RTN USING SPACE
                              CHANGING <FS_S>.
        ELSE.
          <FS_S>-ZSTAT = ICON_LED_INACTIVE.

          PERFORM SET_STY_RTN USING GC_M
                              CHANGING <FS_S>.
        ENDIF.
      ENDIF.

    ELSEIF P_R4 EQ GC_X.
      <FS_S>-ZSTAT = ICON_LED_INACTIVE.

      IF <FS_S>-DEFLT EQ GC_Y.
        PERFORM GET_DEFLT_ZGTPPT1080 USING <FS_S>.
      ENDIF.

      PERFORM SET_STY_RTN USING SPACE
                          CHANGING <FS_S>.

    ENDIF.

* 배치 클래스
    "023 클래스유형으로 존재유무 체크
    CLEAR: LV_MANDT.
    SELECT SINGLE MANDT
      FROM INOB
     WHERE OBJEK EQ @<FS_S>-MATNR
       AND KLART EQ '023'
      INTO @LV_MANDT.

    "023 클래스유형으로 없으면 CLASS 생성을 위하여
    "001 클래스유형의 CLASS 추출
    IF SY-SUBRC NE 0.
      SELECT SINGLE B~CLASS
        FROM KSSK AS A
       INNER JOIN KLAH AS B ON B~CLINT = A~CLINT
       WHERE A~OBJEK EQ @<FS_S>-MATNR
         AND A~KLART EQ '001'
        INTO @<FS_S>-CLASS.
    ENDIF.

    "등가계수
    SELECT SINGLE CSPLIT
      FROM MAKV
     WHERE MATNR EQ @<FS_S>-MATNR
       AND WERKS EQ @<FS_S>-WERKS
      INTO @<FS_S>-CSPLIT.

  ENDLOOP.

  SORT GT_DATA BY MATNR WERKS.

  UNASSIGN <FS_S>.

  IF ( P_R3 EQ GC_X AND P_R1 EQ GC_X ) OR
       P_R4 EQ GC_X.
    LOOP AT GT_DATA ASSIGNING <FS_S>.
      "구성형자재가 해당 플랜트에 존재 체크
      IF <FS_S>-STDPD IS NOT INITIAL.
        CLEAR: LV_MANDT.
        SELECT SINGLE MANDT
          FROM MARC
         WHERE WERKS EQ @<FS_S>-WERKS
           AND MATNR EQ @<FS_S>-STDPD
          INTO @LV_MANDT.

        IF SY-SUBRC NE 0.
          <FS_S>-ZSTAT = ICON_LED_RED.
          "구성형 자재가 & 플랜트에 확장되지 않았습니다.
          CONCATENATE TEXT-M19 <FS_S>-WERKS TEXT-M20
                 INTO <FS_S>-ZMESSAGE SEPARATED BY SPACE.

          PERFORM SET_STY_RTN USING GC_X
                              CHANGING <FS_S>.

          CONTINUE.
        ENDIF.
      ENDIF.

      IF <FS_S>-CLASS IS NOT INITIAL.
        "023 배치클래스 존재여부 체크
        CLEAR: LV_MANDT.
        SELECT SINGLE MANDT
          FROM KLAH
         WHERE KLART EQ '023'
           AND CLASS EQ @<FS_S>-CLASS
          INTO @LV_MANDT.

        IF SY-SUBRC NE 0.
          <FS_S>-ZSTAT = ICON_LED_RED.
          "배치 클래스가 존재하지 않습니다.
          <FS_S>-ZMESSAGE = TEXT-M21.

          PERFORM SET_STY_RTN USING GC_X
                              CHANGING <FS_S>.

          CONTINUE.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

  CLEAR: GT_DATA1.
  APPEND LINES OF GT_DATA TO GT_DATA1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SPACE
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN  USING P_STATUS
                  CHANGING P_LINE LIKE GS_DATA.

  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      ls_sty-style = cl_gui_alv_grid=>mc_style_disabled.
    ELSE.
      ls_sty-style = cl_gui_alv_grid=>mc_style_enabled.
    ENDIF.

    ls_sty-fieldname = &1.
    INSERT ls_sty INTO TABLE p_line-cell_sty.
    CLEAR ls_sty.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  SET_STY 'ZSTAT'    'X'.
  SET_STY 'ZMESSAGE' 'X'.
  SET_STY 'MATNR'    'X'.
  SET_STY 'MAKTX'    'X'.
  SET_STY 'WERKS'    'X'.
  SET_STY 'NAME1'    'X'.
  SET_STY 'SPART'    'X'.
  SET_STY 'VTEXT'    'X'.
  SET_STY 'MTART'    'X'.
  SET_STY 'MTBEZ'    'X'.
  IF P_R3 EQ GC_X.
    IF P_STATUS EQ GC_X.
      SET_STY 'MATKL'    'X'.
    ELSE.
      SET_STY 'MATKL'    SPACE.
    ENDIF.
  ELSEIF P_R4 EQ GC_X.
    SET_STY 'MATKL'    'X'.
  ENDIF.
  SET_STY 'WGBEZ'    'X'.

  IF P_STATUS EQ GC_M.
    SET_STY 'STRGR'   SPACE.
    SET_STY 'DISMM'   SPACE.
    SET_STY 'DISPO'   SPACE.
    SET_STY 'DISLS'   SPACE.
    SET_STY 'BESKZ'   SPACE.
    SET_STY 'SOBSL'   SPACE.
    SET_STY 'LGPRO'   SPACE.
    SET_STY 'LGFSB'   SPACE.
    SET_STY 'RGEKZ'   SPACE.
    SET_STY 'MTVFP'   SPACE.
    SET_STY 'SBDKZ'   SPACE.
    SET_STY 'XCHAR'   SPACE.
    SET_STY 'UEETK'   SPACE.
    SET_STY 'FEVOR'   SPACE.
    SET_STY 'SFCPF'   SPACE.
    SET_STY 'DPCBT'   SPACE.
    SET_STY 'KZKUP'   SPACE.
    SET_STY 'DISGR'   SPACE.
    SET_STY 'INSMK'   SPACE.
    SET_STY 'STDPD'   'X'.
    SET_STY 'CLASS'   'X'.
    SET_STY 'CSPLIT'  'X'.
    SET_STY 'CUOBF'   'X'.
    SET_STY 'DEFLT'   'X'.
    SET_STY 'DEL'     'X'.

  ELSE.
    SET_STY 'STRGR'   'X'.
    SET_STY 'DISMM'   'X'.
    SET_STY 'DISPO'   'X'.
    SET_STY 'DISLS'   'X'.
    SET_STY 'BESKZ'   'X'.
    SET_STY 'SOBSL'   'X'.
    SET_STY 'LGPRO'   'X'.
    SET_STY 'LGFSB'   'X'.
    SET_STY 'RGEKZ'   'X'.
    SET_STY 'MTVFP'   'X'.
    SET_STY 'SBDKZ'   'X'.
    SET_STY 'XCHAR'   'X'.
    SET_STY 'UEETK'   'X'.
    SET_STY 'FEVOR'   'X'.
    SET_STY 'SFCPF'   'X'.
    SET_STY 'DPCBT'   'X'.
    SET_STY 'KZKUP'   'X'.
    SET_STY 'DISGR'   'X'.
    SET_STY 'INSMK'   'X'.
    SET_STY 'STDPD'   'X'.
    SET_STY 'CLASS'   'X'.
    SET_STY 'CSPLIT'  'X'.
    SET_STY 'CUOBF'   'X'.
    SET_STY 'DEFLT'   'X'.
    SET_STY 'DEL'     'X'.
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
  SELECT A~WERKS, A~STRGR, A~DISMM, A~DISPO, A~DISLS,
         A~BESKZ, A~SOBSL, A~LGPRO, A~LGFSB, A~RGEKZ,
         A~MTVFP, A~SBDKZ, A~UEETK, A~FEVOR, A~SFCPF,
         A~DPCBT, A~KZKUP, A~DISGR, A~INSMK,
         B~MATNR, B~SPART, B~MTART, B~MATKL,
         B~XCHPF AS XCHAR, B~SATNR AS STDPD,
         C~MAKTX,
         D~NAME1,
         E~VTEXT,
         F~MTBEZ,
         G~WGBEZ
    FROM            MARC  AS A
   INNER JOIN       MARA  AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN MAKT  AS C ON C~MATNR EQ B~MATNR
                              AND C~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN TSPAT AS E ON E~SPRAS EQ @SY-LANGU
                              AND E~SPART EQ B~SPART
    LEFT OUTER JOIN T134T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS G ON G~SPRAS EQ @SY-LANGU
                              AND G~MATKL EQ B~MATKL
   WHERE A~WERKS IN @S_WERKS
     AND A~PSTAT LIKE '%D%'
     AND A~MMSTA NE 'ZD'
     AND B~SPART IN @S_SPART
     AND B~MTART IN @S_MTART
     AND B~MTART IN ('FERT', 'HALB', 'HAWA', 'MCFE', 'MCHF', 'MCHA')
     AND B~MATKL IN @S_MATKL
     AND B~MATNR IN @S_MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

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
*  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
  IF P_R5 EQ GC_X.
    GS_LAYOUT_0100-EDIT       = GC_X.
    GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
  ENDIF.
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
  IF P_R5 EQ GC_X.
    PERFORM SET_FIELDCAT_DATA.
  ELSEIF P_R6 EQ GC_X.
    IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
      PERFORM SET_FIELDCAT_RM.
    ELSEIF P_R7 EQ GC_X.
      PERFORM SET_FIELDCAT_UPDATE.
    ENDIF.
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
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0100.
  ENDCASE.

* 인풋이벤트 추가
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* DATA CHANGE
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
  IF P_R5 EQ GC_X.
    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*       IS_VARIANT           = GS_VARIANT
*       I_SAVE               = GC_X
      CHANGING
        IT_OUTTAB            = GT_DATA
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ELSEIF P_R6 EQ GC_X.
    IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*         IS_VARIANT           = GS_VARIANT
*         I_SAVE               = GC_X
        CHANGING
          IT_OUTTAB            = GT_DATA_RM
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ELSEIF P_R7 EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*         IS_VARIANT           = GS_VARIANT
*         I_SAVE               = GC_X
        CHANGING
          IT_OUTTAB            = GT_DATA_UPDATE
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ENDIF.
  ENDIF.
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
         GV_OK_CODE, GV_DBCNT,
         GT_DATA[], GT_DATA_RM[], GT_DATA_UPDATE[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "자재마스터 확장(MRP,작업일정뷰)
      TEXT_QUESTION         = TEXT-T05 "자재마스터 확장을 하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GT_MATNR.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-MATKL IS NOT INITIAL.
        PERFORM EXEC_EXTENSIONIN_MAT USING <FS_S>.

        IF <FS_S>-ZSTAT = ICON_LED_GREEN.
          IF P_R1 EQ GC_X AND P_LGORT EQ GC_X.
            "저장위치 확장용
            CLEAR: GS_MATNR.
            GS_MATNR-MATNR = <FS_S>-MATNR.
            GS_MATNR-WERKS = <FS_S>-WERKS.
            COLLECT GS_MATNR INTO GT_MATNR.
          ENDIF.

          PERFORM SET_STY_RTN USING SPACE
                              CHANGING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "저장위치 확장은 신규에서만 별도로 진행
    IF P_R1 EQ GC_X AND P_LGORT EQ GC_X.
      IF GT_MATNR IS NOT INITIAL.
        PERFORM EXEC_LGORT_CRE.
      ENDIF.
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

    WHEN GO_GRID_0200.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0200.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_EXTENSIONIN_MAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_EXTENSIONIN_MAT  USING    P_LINE LIKE GS_DATA.

  CLEAR: HEADDATA, CLIENTDATA, CLIENTDATAX, PLANTDATA, PLANTDATAX.

  "확장뷰선택
  HEADDATA-MATERIAL = P_LINE-MATNR. "자재코드
  HEADDATA-MRP_VIEW = GC_X.         "MRP뷰
  HEADDATA-WORK_SCHED_VIEW = GC_X.  "작업일정뷰

  "기본데이터
  CLIENTDATA-MATL_GROUP = P_LINE-MATKL.  "자재그룹
  CLIENTDATA-BATCH_MGMT = P_LINE-XCHAR.  "배치관리소요량지시자
  CLIENTDATAX-MATL_GROUP = GC_X.
  CLIENTDATAX-BATCH_MGMT = GC_X.

  "플랜트확장(MRP1,2,3,4/작업일정뷰)
  PLANTDATA-PLANT                  = P_LINE-WERKS. "플랜트
  PLANTDATA-PLAN_STRGP             = P_LINE-STRGR. "생산전략
  PLANTDATA-MRP_TYPE               = P_LINE-DISMM. "MRP유형
  PLANTDATA-MRP_CTRLER             = P_LINE-DISPO. "MRP관리자
  PLANTDATA-LOTSIZEKEY             = P_LINE-DISLS. "로트크기유형
  PLANTDATA-PROC_TYPE              = P_LINE-BESKZ. "조달유형
  PLANTDATA-SPPROCTYPE             = P_LINE-SOBSL. "특별조달유형
  PLANTDATA-ISS_ST_LOC             = P_LINE-LGPRO. "생산저장위치
  PLANTDATA-SLOC_EXPRC             = P_LINE-LGFSB. "외부조달저장위치
  PLANTDATA-BACKFLUSH              = P_LINE-RGEKZ. "백플러쉬
  PLANTDATA-AVAILCHECK             = P_LINE-MTVFP. "가용성점검
  PLANTDATA-DEP_REQ_ID             = P_LINE-SBDKZ. "개별/일괄
  PLANTDATA-BATCH_MGMT             = P_LINE-XCHAR. "배치관리
  PLANTDATA-UNLIMITED              = P_LINE-UEETK. "무제한허용
  PLANTDATA-PRODUCTION_SCHEDULER   = P_LINE-FEVOR. "생산감독자
  PLANTDATA-PRODPROF               = P_LINE-SFCPF. "생산일정프로파일
  PLANTDATA-CO_PRODUCT             = P_LINE-KZKUP. "연산품
  PLANTDATA-MRP_GROUP              = P_LINE-DISGR. "MRP그룹
  PLANTDATA-IND_POST_TO_INSP_STOCK = P_LINE-INSMK. "검사재고로 전기

  PLANTDATAX-PLANT                  = P_LINE-WERKS. "플랜트
  PLANTDATAX-PLAN_STRGP             = GC_X.         "생산전략
  PLANTDATAX-MRP_TYPE               = GC_X.         "MRP유형
  PLANTDATAX-MRP_CTRLER             = GC_X.         "MRP관리자
  PLANTDATAX-LOTSIZEKEY             = GC_X.         "로트크기유형
  PLANTDATAX-PROC_TYPE              = GC_X.         "조달유형
  PLANTDATAX-SPPROCTYPE             = GC_X.         "특별조달유형
  PLANTDATAX-ISS_ST_LOC             = GC_X.         "생산저장위치
  PLANTDATAX-SLOC_EXPRC             = GC_X.         "외부조달저장위치
  PLANTDATAX-BACKFLUSH              = GC_X.         "백플러쉬
  PLANTDATAX-AVAILCHECK             = GC_X.         "가용성점검
  PLANTDATAX-DEP_REQ_ID             = GC_X.         "개별/일괄
  PLANTDATAX-BATCH_MGMT             = GC_X.         "배치관리
  PLANTDATAX-UNLIMITED              = GC_X.         "무제한허용
  PLANTDATAX-PRODUCTION_SCHEDULER   = GC_X.         "생산감독자
  PLANTDATAX-PRODPROF               = GC_X.         "생산일정프로파일
  PLANTDATAX-CO_PRODUCT             = GC_X.         "연산품
  PLANTDATAX-MRP_GROUP              = GC_X.         "MRP그룹
  PLANTDATAX-IND_POST_TO_INSP_STOCK = GC_X.         "검사재고로 전기

  REFRESH RETURNMESSAGES.
  CLEAR: GS_RETURN, RETURNMESSAGES.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      HEADDATA       = HEADDATA
      CLIENTDATA     = CLIENTDATA
      CLIENTDATAX    = CLIENTDATAX
      PLANTDATA      = PLANTDATA
      PLANTDATAX     = PLANTDATAX
    IMPORTING
      RETURN         = GS_RETURN
    TABLES
      RETURNMESSAGES = RETURNMESSAGES.

  IF GS_RETURN-TYPE EQ 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-ZSTAT = ICON_LED_RED.
    P_LINE-ZMESSAGE = GS_RETURN-MESSAGE.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = GS_RETURN-MESSAGE.

*    IF P_LINE-MTART EQ GC_FERT OR P_LINE-MTART EQ GC_MCFE.
    "배치클래스 할당
    IF P_LINE-CLASS IS NOT INITIAL.
      PERFORM ADD_CLASS USING P_LINE.
    ENDIF.

    "구성형자재
    IF P_LINE-STDPD IS NOT INITIAL.
      PERFORM ADD_STDPD USING P_LINE.
    ENDIF.

    "추가데이터
    IF P_LINE-DPCBT IS NOT INITIAL.
      PERFORM ADD_DATA USING P_LINE.
    ENDIF.

    "배부구조(등가계수)할당
    IF P_LINE-KZKUP EQ GC_X AND P_LINE-BESKZ NE GC_F.
      IF P_LINE-CSPLIT IS INITIAL.
        PERFORM ADD_CSPLIT USING P_LINE.
      ENDIF.
    ENDIF.

    "구매뷰 확장
    PERFORM EXPAND_PURVIEW USING P_LINE.

*    ELSE.
*      P_LINE-ZSTAT = ICON_LED_GREEN.
*      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.
*
*    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_DATA  USING    P_LINE LIKE GS_DATA.

  PERFORM ADD_DATA_MARA USING P_LINE.
  PERFORM ADD_DATA_MARC USING P_LINE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO  USING DYNBEGIN NAME VALUE.
  CLEAR BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO BDCDATA-PROGRAM,
          VALUE TO BDCDATA-DYNPRO,
          'X'   TO BDCDATA-DYNBEGIN.
    APPEND BDCDATA.
  ELSE.
    MOVE: NAME  TO BDCDATA-FNAM,
          VALUE TO BDCDATA-FVAL.
    APPEND BDCDATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZPPT1080_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_ZPPT1080_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                       CHANGING P_DATA_CHANGED
                                TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_WGBEZ TYPE WGBEZ.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  DATA: LV_DYN(50),
        LV_MATKL TYPE MATKL.

  DATA: LT_FIELDCAT TYPE LVC_T_FCAT,
        LS_FIELDCAT TYPE LVC_S_FCAT.

  DATA: NAME TYPE STRING.

  FIELD-SYMBOLS: <FS>.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: LT_FIELDCAT, LT_FIELDCAT[].
  APPEND LINES OF GT_FIELDCAT_0100 TO LT_FIELDCAT.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: GS_1080.
  SELECT SINGLE *
    FROM ZGTPPT1080
   WHERE WERKS EQ @<FS_S>-WERKS
     AND SPART EQ @<FS_S>-SPART
     AND MTART EQ @<FS_S>-MTART
     AND MATKL EQ @L_VALUE
    INTO @GS_1080.

  IF GS_1080 IS INITIAL AND L_VALUE IS NOT INITIAL.
    CLEAR: LV_DYN, LV_MATKL.
    LV_MATKL = |%| && L_VALUE+0(7) && |%|.
    LV_DYN = 'MATKL LIKE @LV_MATKL'.

    SELECT SINGLE *
      FROM ZGTPPT1080
     WHERE WERKS EQ @<FS_S>-WERKS
       AND SPART EQ @<FS_S>-SPART
       AND MTART EQ @<FS_S>-MTART
       AND (LV_DYN)
      INTO @GS_1080.
  ENDIF.

  IF GS_1080 IS NOT INITIAL.
    "설계서에 설정된 조달유형 BESKZ = 'EP' and
    "WERKS = 6500 or WERKS = 6600 인 경우
    "고정값 대신 조달유형 = 'F', 특별조달유형 = '30', 연산품 = SPACE 로 변경
    "설계정보 추출
    SELECT SINGLE SUL_NO, REV_SEQ, GONG_SEQ
      FROM ZEDT1050
     WHERE MATNR_N EQ @<FS_S>-MATNR
      INTO @DATA(LS_1050).

    "해당 공정의 조달유형 추출
    IF LS_1050 IS NOT INITIAL.
      SELECT SINGLE BESKZ
        FROM ZEDT1010
       WHERE SUL_NO EQ @LS_1050-SUL_NO
         AND REV_SEQ EQ @LS_1050-REV_SEQ
         AND GONG_SEQ EQ @LS_1050-GONG_SEQ
        INTO @DATA(LV_BESKZ).

      IF LV_BESKZ EQ 'EP'.
        IF <FS_S>-WERKS EQ '6500' OR <FS_S>-WERKS EQ '6600'.
          GS_1080-BESKZ = 'F'.
          GS_1080-SOBSL = '30'.
          CLEAR: GS_1080-KZKUP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: L_WGBEZ.
  SELECT SINGLE WGBEZ
    FROM T023T
   WHERE SPRAS EQ @SY-LANGU
     AND MATKL EQ @L_VALUE
    INTO @L_WGBEZ.

  IF L_WGBEZ IS INITIAL.
    L_WGBEZ = GS_1080-WGBEZ.
  ENDIF.

  IF L_WGBEZ IS INITIAL.
    IF L_VALUE IS INITIAL.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'MATKL'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'WGBEZ'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'ZSTAT'
          I_VALUE     = ICON_LED_RED.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'ZMESSAGE'
          I_VALUE     = TEXT-M03. "자재그룹을 입력하세요.

      IF P_R1 EQ GC_X.
        DELETE LT_FIELDCAT WHERE COL_POS LT 13.
        DELETE LT_FIELDCAT WHERE COL_POS GT 31.

        LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
          CALL METHOD P_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = P_LVC_S_MODI-ROW_ID
              I_TABIX     = P_LVC_S_MODI-TABIX
              I_FIELDNAME = LS_FIELDCAT-FIELDNAME
              I_VALUE     = SPACE.

          CALL METHOD P_DATA_CHANGED->MODIFY_STYLE
            EXPORTING
              I_ROW_ID    = P_LVC_S_MODI-ROW_ID
              I_FIELDNAME = LS_FIELDCAT-FIELDNAME
              I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

          CLEAR: LS_FIELDCAT.
        ENDLOOP.

      ELSEIF P_R2 EQ GC_X.
        READ TABLE GT_DATA1 INTO DATA(LS_DATA1) WITH KEY MATNR = <FS_S>-MATNR
                                                         WERKS = <FS_S>-WERKS
                                                         SPART = <FS_S>-SPART
                                                         MTART = <FS_S>-MTART.
        IF LS_DATA1 IS NOT INITIAL.
          DELETE LT_FIELDCAT WHERE COL_POS LT 13.
          DELETE LT_FIELDCAT WHERE COL_POS GT 31.

          LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
            UNASSIGN: <FS>.
            CLEAR: NAME.
            NAME = |LS_DATA1-| && LS_FIELDCAT-FIELDNAME.
            ASSIGN (NAME) TO <FS>.

            IF <FS> IS ASSIGNED.
              CALL METHOD P_DATA_CHANGED->MODIFY_CELL
                EXPORTING
                  I_ROW_ID    = P_LVC_S_MODI-ROW_ID
                  I_TABIX     = P_LVC_S_MODI-TABIX
                  I_FIELDNAME = LS_FIELDCAT-FIELDNAME
                  I_VALUE     = <FS>.

              CALL METHOD P_DATA_CHANGED->MODIFY_STYLE
                EXPORTING
                  I_ROW_ID    = P_LVC_S_MODI-ROW_ID
                  I_FIELDNAME = LS_FIELDCAT-FIELDNAME
                  I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

            ENDIF.
            CLEAR: LS_FIELDCAT.
          ENDLOOP.
          CLEAR: LS_DATA1.
        ENDIF.
      ENDIF.

    ELSE.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'MATKL'
          I_VALUE     = <FS_S>-MATKL.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'WGBEZ'
          I_VALUE     = <FS_S>-WGBEZ.
    ENDIF.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'WGBEZ'
        I_VALUE     = L_WGBEZ.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ZSTAT'
        I_VALUE     = ICON_LED_INACTIVE.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ZMESSAGE'
        I_VALUE     = SPACE.

    IF GS_1080 IS NOT INITIAL.
      DELETE LT_FIELDCAT WHERE COL_POS LT 13.
      DELETE LT_FIELDCAT WHERE COL_POS GT 31.

      LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
        UNASSIGN: <FS>.
        CLEAR: NAME.
        NAME = |GS_1080-| && LS_FIELDCAT-FIELDNAME.
        ASSIGN (NAME) TO <FS>.

        IF <FS> IS ASSIGNED.
          CALL METHOD P_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = P_LVC_S_MODI-ROW_ID
              I_TABIX     = P_LVC_S_MODI-TABIX
              I_FIELDNAME = LS_FIELDCAT-FIELDNAME
              I_VALUE     = <FS>.

          CALL METHOD P_DATA_CHANGED->MODIFY_STYLE
            EXPORTING
              I_ROW_ID    = P_LVC_S_MODI-ROW_ID
              I_FIELDNAME = LS_FIELDCAT-FIELDNAME
              I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        ENDIF.
        CLEAR: LS_FIELDCAT.
      ENDLOOP.

    ELSE.
      DELETE LT_FIELDCAT WHERE COL_POS LT 13.
      DELETE LT_FIELDCAT WHERE COL_POS GT 31.

      LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_TABIX     = P_LVC_S_MODI-TABIX
            I_FIELDNAME = LS_FIELDCAT-FIELDNAME
            I_VALUE     = SPACE.

        CALL METHOD P_DATA_CHANGED->MODIFY_STYLE
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_FIELDNAME = LS_FIELDCAT-FIELDNAME
            I_STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        CLEAR: LS_FIELDCAT.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_LGORT_CRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXEC_LGORT_CRE .

  DATA: BEGIN OF LS_LGORT,
          MATNR LIKE MARD-MATNR,
          WERKS LIKE MARD-WERKS,
          LGORT LIKE MARD-LGORT,
        END OF LS_LGORT.
  DATA: LT_LGORT LIKE TABLE OF LS_LGORT.

  DATA: BEGIN OF LS_T001L,
          LGORT LIKE T001L-LGORT,
        END OF LS_T001L.
  DATA: LT_T001L LIKE TABLE OF LS_T001L,
        LT_MARD  LIKE TABLE OF LS_T001L.

  SORT GT_MATNR BY MATNR WERKS.

  CLEAR: LT_LGORT.
  LOOP AT GT_MATNR INTO DATA(LS_MATNR).
    CLEAR: LT_T001L.
    SELECT LGORT
      FROM T001L
     WHERE WERKS EQ @LS_MATNR-WERKS
      INTO CORRESPONDING FIELDS OF TABLE @LT_T001L.

    CLEAR: LT_MARD.
    SELECT LGORT
      FROM MARD
     WHERE MATNR EQ @LS_MATNR-MATNR
       AND WERKS EQ @LS_MATNR-WERKS
      INTO CORRESPONDING FIELDS OF TABLE @LT_MARD.

    SORT: LT_T001L BY LGORT,
          LT_MARD  BY LGORT.

    LOOP AT LT_T001L INTO LS_T001L.
      READ TABLE LT_MARD INTO DATA(LS_MARD) WITH KEY LGORT = LS_T001L-LGORT.
      IF SY-SUBRC NE 0.
        MOVE: LS_MATNR-MATNR TO LS_LGORT-MATNR,
              LS_MATNR-WERKS TO LS_LGORT-WERKS,
              LS_T001L-LGORT TO LS_LGORT-LGORT.
        COLLECT LS_LGORT INTO LT_LGORT.
        CLEAR: LS_LGORT.
      ENDIF.
      CLEAR: LS_T001L, LS_MARD.
    ENDLOOP.

    CLEAR: LS_MATNR.
  ENDLOOP.

  IF LT_LGORT IS NOT INITIAL.
    SORT LT_LGORT BY MATNR WERKS LGORT.

    CLEAR: LS_LGORT.
    LOOP AT LT_LGORT INTO LS_LGORT.

      CLEAR: HEADDATA, STORAGELOCATIONDATA, STORAGELOCATIONDATAX.
      HEADDATA-MATERIAL = LS_LGORT-MATNR. "자재코드
      HEADDATA-STORAGE_VIEW = GC_X.       "저장위치뷰


      STORAGELOCATIONDATA-PLANT     = LS_LGORT-WERKS.
      STORAGELOCATIONDATA-STGE_LOC  = LS_LGORT-LGORT.

      STORAGELOCATIONDATAX-PLANT    = LS_LGORT-WERKS.
      STORAGELOCATIONDATAX-STGE_LOC = LS_LGORT-LGORT.

      REFRESH RETURNMESSAGES.
      CLEAR: GS_RETURN, RETURNMESSAGES.

      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          HEADDATA             = HEADDATA
          STORAGELOCATIONDATA  = STORAGELOCATIONDATA
          STORAGELOCATIONDATAX = STORAGELOCATIONDATAX
        IMPORTING
          RETURN               = GS_RETURN
        TABLES
          RETURNMESSAGES       = RETURNMESSAGES.

      IF GS_RETURN-TYPE EQ 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

      ENDIF.

      CLEAR: LS_LGORT.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .
  CLEAR: GV_DYNTXT1.
*  GV_DYNTXT-ICON_ID = '@0S@'.  "information
  GV_DYNTXT1-TEXT = '엑셀 양식 다운로드'.
  GV_DYNTXT1-ICON_TEXT = '엑셀 양식 다운로드'.
  GV_DYNTXT1-QUICKINFO = '엑셀 양식 다운로드'.

  CLEAR: GV_DYNTXT2.
*  GV_DYNTXT-ICON_ID = '@0S@'.  "information
  GV_DYNTXT2-TEXT = '컴포넌트 스크랩 설정'.
  GV_DYNTXT2-ICON_TEXT = '컴포넌트 스크랩 설정'.
  GV_DYNTXT2-QUICKINFO = '컴포넌트 스크랩 설정'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM F4_FILENAME  CHANGING P_FILE.

  DATA: L_RC               TYPE I VALUE 1,
        LT_FILES           TYPE FILETABLE,
        LV_USER_ACTION     TYPE I,
        L_DESKTOPDIRECTORY TYPE STRING,
        LV_TITLE           TYPE STRING.

  CLEAR: LV_TITLE.
  LV_TITLE = TEXT-T07.  "파일 열기

  CONCATENATE CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
              CL_GUI_FRONTEND_SERVICES=>FILETYPE_ALL
         INTO DATA(LV_FILE_FILTER).

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
    CHANGING
      DESKTOP_DIRECTORY = L_DESKTOPDIRECTORY.

  CALL METHOD CL_GUI_CFW=>UPDATE_VIEW.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_TITLE
      FILE_FILTER       = LV_FILE_FILTER
      INITIAL_DIRECTORY = L_DESKTOPDIRECTORY
    CHANGING
      FILE_TABLE        = LT_FILES
      RC                = L_RC
      USER_ACTION       = LV_USER_ACTION.

  IF LT_FILES[] IS NOT INITIAL.
    READ TABLE LT_FILES INTO P_FILE INDEX 1.
  ELSE.
    MESSAGE S003 DISPLAY LIKE GC_E WITH 'FILE NOT SELECT'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_EXCEL .
  DATA: LV_OBJ TYPE CHAR40.

  DATA: LV_DESTINATION TYPE RLGRAP-FILENAME,
        LV_FILENAME    TYPE STRING,
        LV_PATH        TYPE STRING,
        LV_FULLPATH    TYPE STRING,
        LS_KEY         TYPE WWWDATATAB,
        LV_EXTEN       TYPE STRING,
        LV_SUBRC       TYPE SY-SUBRC,
        LV_USER_ACTION TYPE I.

  CONSTANTS: LC_TITLE TYPE STRING VALUE 'Select File',
             LC_MI(2) TYPE C VALUE 'MI'.

  LV_OBJ = |ZGTPPR1100|.

  TRY .
      LV_EXTEN    = |xlsx|.
      LV_FILENAME = LV_OBJ.

      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        EXPORTING
          WINDOW_TITLE         = LC_TITLE
          DEFAULT_EXTENSION    = LV_EXTEN
          DEFAULT_FILE_NAME    = LV_FILENAME
          FILE_FILTER          = 'xlsx'
          PROMPT_ON_OVERWRITE  = ABAP_TRUE
        CHANGING
          FILENAME             = LV_FILENAME
          PATH                 = LV_PATH
          FULLPATH             = LV_FULLPATH
          USER_ACTION          = LV_USER_ACTION
        EXCEPTIONS
          CNTL_ERROR           = 1
          ERROR_NO_GUI         = 2
          NOT_SUPPORTED_BY_GUI = 3
          OTHERS               = 4.
      IF SY-SUBRC <> 0.
        LV_SUBRC  = SY-SUBRC.
        MESSAGE E162(ALVHT).
        EXIT.
      ENDIF.

      IF LV_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL .
        MESSAGE S161(ALVHT) DISPLAY LIKE GC_E.
        EXIT.
      ENDIF.

*-- check file path
      IF LV_FULLPATH IS INITIAL.
        MESSAGE E003 WITH TEXT-M06. "파일명을 확인하세요.
        EXIT.
      ENDIF.

* DOWNLOAD OBJECT FILE
      CLEAR: LS_KEY.
      SELECT SINGLE *
        FROM WWWDATA
       WHERE OBJID EQ @LV_OBJ
        INTO CORRESPONDING FIELDS OF @LS_KEY.

      LS_KEY-RELID = LC_MI.
      LS_KEY-OBJID = LV_OBJ.
      LV_DESTINATION = LV_FULLPATH.

      DATA(LV_LEN) = STRLEN( LV_FULLPATH ).
      IF LV_LEN > 128.
        MESSAGE S003 DISPLAY LIKE GC_E
           WITH TEXT-M07. "다운로드 중 오류가 발생하였습니다.
        EXIT.
      ENDIF.

      CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
        EXPORTING
          KEY         = LS_KEY
          DESTINATION = LV_DESTINATION
        IMPORTING
          RC          = LV_SUBRC
        EXCEPTIONS
          OTHERS      = 1.
      IF SY-SUBRC IS NOT INITIAL OR LV_SUBRC IS NOT INITIAL.
        MESSAGE E003 WITH TEXT-M07. "다운로드 중 오류가 발생하였습니다.
        EXIT.
      ENDIF.

      CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
        EXPORTING
          DOCUMENT               = LV_FULLPATH
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
      IF SY-SUBRC IS NOT INITIAL.
        MESSAGE E162(ALVHT).
        EXIT.
      ENDIF.

    CATCH CX_ROOT INTO DATA(LO_ERR).
      MESSAGE S000 DISPLAY LIKE GC_E
         WITH LO_ERR->GET_LONGTEXT( ).
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD .
  DATA: LT_EXCEL TYPE KCDE_CELLS OCCURS 0 WITH HEADER LINE.
  DATA: LV_INDEX LIKE SY-TABIX.

  DATA: LCL_ERROR  TYPE REF TO CX_ROOT,
        LV_MESSAGE TYPE STRING,
        LT_RETURN  TYPE TABLE OF BAPIRET2 WITH HEADER LINE.

  FIELD-SYMBOLS: <FS>.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = C_START_COL
      I_BEGIN_ROW             = C_START_ROW
      I_END_COL               = C_END_COL
      I_END_ROW               = C_END_ROW
    TABLES
      INTERN                  = LT_EXCEL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2.

  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH 'File Upload Failed !' .
    STOP.
  ENDIF.

  CHECK NOT LT_EXCEL[] IS INITIAL.
  SORT LT_EXCEL BY ROW COL.

  LOOP AT LT_EXCEL.
    MOVE: LT_EXCEL-COL TO LV_INDEX.
    ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_UPLOAD TO <FS>.
    TRY.
        MOVE: LT_EXCEL-VALUE TO <FS>.
      CATCH CX_ROOT INTO LCL_ERROR.
        CLEAR: LT_RETURN.
        LV_MESSAGE = LCL_ERROR->GET_TEXT( ).
        LT_RETURN-TYPE       = 'E'.
        LT_RETURN-ID         = 'ZGTPP00'.
        LT_RETURN-NUMBER     = '999'.
        LT_RETURN-MESSAGE_V1 = LT_EXCEL-ROW.
        LT_RETURN-MESSAGE_V2 = LT_EXCEL-COL.
        LT_RETURN-MESSAGE_V3 = LT_EXCEL-VALUE.
        LT_RETURN-MESSAGE_V4 = LV_MESSAGE.
        LT_RETURN-MESSAGE    = SPACE.
        LT_RETURN-ROW        = LT_EXCEL-ROW.
        LT_RETURN-FIELD      = LT_EXCEL-COL.
        APPEND LT_RETURN.
    ENDTRY.
    AT END OF ROW.
      APPEND GS_UPLOAD TO GT_UPLOAD.
      CLEAR GS_UPLOAD.
    ENDAT.
  ENDLOOP.

  CLEAR: GT_DATA.
  LOOP AT GT_UPLOAD INTO GS_UPLOAD.
    CLEAR: GS_DATA.
    MOVE-CORRESPONDING GS_UPLOAD TO GS_DATA.

    PERFORM CONV_EXIT USING GS_DATA-MATNR GC_M GC_I
                      CHANGING GS_DATA-MATNR.

    PERFORM CONV_EXIT USING GS_DATA-SFCPF GC_A GC_I
                      CHANGING GS_DATA-SFCPF.

    PERFORM CONV_EXIT USING GS_DATA-DISGR GC_A GC_I
                      CHANGING GS_DATA-DISGR.

    APPEND GS_DATA TO GT_DATA.
  ENDLOOP.

  IF LT_RETURN[] IS NOT INITIAL.
    CLEAR: LT_RETURN.
    LT_RETURN-TYPE       = 'E'.
    LT_RETURN-ID         = 'ZGTPP00'.
    LT_RETURN-NUMBER     = '000'.
    LT_RETURN-MESSAGE_V1 = '엑셀 변환오류가 발생하였습니다. 처리를 종료합니다,'.
    APPEND LT_RETURN.
    CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
      EXPORTING
        IT_MESSAGE = LT_RETURN[].
    REFRESH GT_DATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  CLEAR: GV_ERROR.

  "플랜트, 제품군, 자재유형, 기본값설정, 자재그룹 중 하나라도 빈값 체크
  IF LINE_EXISTS( GT_DATA[ WERKS = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M09. "플랜트 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ SPART = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M10. "제품군 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ MTART = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M11. "자재유형 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ MTART = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M12. "기본값 설정 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ MATKL = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M13. "자재그룹 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  LOOP AT GT_DATA INTO DATA(LS_DATA).
    "자재유형 점검
    IF LS_DATA-MTART NE 'FERT' AND
       LS_DATA-MTART NE 'HALB' AND
       LS_DATA-MTART NE 'HAWA' AND
       LS_DATA-MTART NE 'MCFE' AND
       LS_DATA-MTART NE 'MCHF' AND
       LS_DATA-MTART NE 'MCHA'.
      MESSAGE S003 DISPLAY LIKE GC_W
         WITH TEXT-M14. "제품, 반제품, 상품만 등록 가능합니다.
      GV_ERROR = GC_X.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA_MATNR
*&      --> GC_I
*&      --> GC_M
*&      <-- GS_DATA_MATNR
*&---------------------------------------------------------------------*
FORM CONV_EXIT  USING    PV_INPUT  PV_TYPE  PV_IO
                CHANGING PV_OUTPUT.

  CASE PV_TYPE.
    WHEN GC_M.
      CASE PV_IO.
        WHEN GC_I.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              INPUT        = PV_INPUT
            IMPORTING
              OUTPUT       = PV_OUTPUT
            EXCEPTIONS
              LENGTH_ERROR = 1
              OTHERS       = 2.

        WHEN GC_O.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              INPUT  = PV_INPUT
            IMPORTING
              OUTPUT = PV_OUTPUT.

      ENDCASE.

    WHEN GC_A.
      CASE PV_IO.
        WHEN GC_I.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = PV_INPUT
            IMPORTING
              OUTPUT = PV_OUTPUT.


        WHEN GC_O.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = PV_INPUT
            IMPORTING
              OUTPUT = PV_OUTPUT.

      ENDCASE.
  ENDCASE.
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
  IF P_R5 EQ GC_X.
    IF P_R3 EQ GC_X.
      IF P_R2 EQ GC_X.
*& 플랜트에 대한 권한체크
        AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
        ID 'WERKS' FIELD S_WERKS-LOW.

        IF SY-SUBRC <> 0.
          "플랜트[S_WERKS-LOW] 작업권한을 확인하세요.
          MESSAGE S006 DISPLAY LIKE GC_E
             WITH TEXT-M15 S_WERKS-LOW TEXT-M16.
          LEAVE LIST-PROCESSING.
        ELSE.
*& 제품군에 대한 권한체크
          AUTHORITY-CHECK OBJECT 'ZPP_SPART'
          ID 'WERKS'  FIELD S_WERKS-LOW
          ID 'SPART'  FIELD S_SPART-LOW.

          IF SY-SUBRC <> 0.
            "제품군[S_SPART-LOW] 작업권한을 확인하세요.
            MESSAGE S006 DISPLAY LIKE GC_E
               WITH TEXT-M17 S_SPART-LOW TEXT-M18.
            LEAVE LIST-PROCESSING.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF P_R6 EQ GC_X.
*& 플랜트에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
    ID 'WERKS' FIELD P_WERKS.

    IF SY-SUBRC <> 0.
      "플랜트[P_WERKS] 작업권한을 확인하세요.
      MESSAGE E006 WITH TEXT-M15 P_WERKS TEXT-M16.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_STDPD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_STDPD  USING    P_LINE LIKE GS_DATA.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
        LV_INDEX, LV_TEXT.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0060',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-MATNR' P_LINE-MATNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0070',
        ' ' 'BDC_OKCODE'  '=SELA'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0070',
        ' ' 'BDC_OKCODE'  '=ENTR'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0080',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-WERKS' P_LINE-WERKS.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5004',
        ' ' 'BDC_OKCODE'  '=SP15'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'MARC-STDPD'  P_LINE-STDPD.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=PB22'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=PB19'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCEI0'    '0109',
        ' ' 'BDC_OKCODE'  '=BACK'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=BU'.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE = 'S'.   " 갱신세션

  CALL TRANSACTION 'MM02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ 'M3' AND
     MESSTAB-MSGV1  NE SPACE AND
    ( MESSTAB-MSGNR EQ '800' OR MESSTAB-MSGNR EQ '801' ).
    "자재 &을(를) 생성 OR 변경 했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_DATA_MARA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_DATA_MARA  USING    P_LINE LIKE GS_DATA.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         LV_INDEX, LV_TEXT.

  "초기화면
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0060',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-MATNR' P_LINE-MATNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'   '0070',
        ' ' 'BDC_OKCODE' '=ENTR',
        ' ' 'MSICHTAUSW-KZSEL(01)' 'X'.

  "추가데이터
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5004',
        ' ' 'BDC_OKCODE'  '=ZU01'.

  "PROPORTION/PROD.UNIT
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '=ZU09'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'MARA-KZWSM'  'B'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'MARA-DPCBT'  P_LINE-DPCBT,
        ' ' 'SMEINH_WS-ATWRT(01)' '1',
        ' ' 'SMEINH_WS-WSMEI(01)' 'ST'.

  "저장
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '=BU',
        ' ' 'MILL_PCBT_MAT_DIA-XPRGI' 'X',
        ' ' 'MARA-XGRDT' 'X',
        ' ' 'SMEINH_WS-XPCBU(01)' 'X'.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE = 'S'.   " 갱신세션

  CALL TRANSACTION 'MM02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ 'M3' AND
     MESSTAB-MSGV1  NE SPACE AND
    ( MESSTAB-MSGNR EQ '800' OR MESSTAB-MSGNR EQ '801' ).
    "자재 &을(를) 생성 OR 변경 했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_DATA_MARC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_DATA_MARC  USING    P_LINE LIKE GS_DATA.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         LV_INDEX, LV_TEXT.

  "초기화면
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0060',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-MATNR' P_LINE-MATNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'   '0070',
        ' ' 'BDC_OKCODE' '=SELA'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'   '0070',
        ' ' 'BDC_OKCODE' '=ENTR'.

  "플랜트 선택
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0080',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-WERKS' P_LINE-WERKS.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5004',
        ' ' 'BDC_OKCODE'  '=SP14'.

  "추가데이터
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=ZU01'.

  "PROPORTION/PROD.UNIT
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '=ZU09'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'MARC-DPCBT'  P_LINE-DPCBT.

  "저장
  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5300',
        ' ' 'BDC_OKCODE'  '=BU',
        ' ' 'MILL_PCBT_MAT_DIA-XPRGI' 'X',
        ' ' 'MARA-XGRDT' 'X'.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE = 'S'.   " 갱신세션

  CALL TRANSACTION 'MM02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ 'M3' AND
     MESSTAB-MSGV1  NE SPACE AND
    ( MESSTAB-MSGNR EQ '800' OR MESSTAB-MSGNR EQ '801' ).
    "자재 &을(를) 생성 OR 변경 했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_CLASS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_CLASS  USING    P_LINE LIKE GS_DATA.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  SET PARAMETER ID 'KAR' FIELD SPACE.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
        LV_INDEX, LV_TEXT.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0060',
        ' ' 'BDC_OKCODE'  'AUSW',
        ' ' 'RMMG1-MATNR' P_LINE-MATNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0070',
        ' ' 'BDC_OKCODE'  '=BILD',
        ' ' 'MSICHTAUSW-KZSEL(03)' 'X'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCLCA'    '0602',
        ' ' 'BDC_OKCODE'  '=ENTE',
        ' ' 'RMCLF-KLART' '023'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCLFM'         '0500',
        ' ' 'BDC_OKCODE'       '/00',
        ' ' 'RMCLF-CLASS(01)'  P_LINE-CLASS.

  PERFORM DYNPRO USING:
        'X' 'SAPLCTMS'    '0109',
        ' ' 'BDC_OKCODE'  '=BACK'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCLFM'    '0500',
        ' ' 'BDC_OKCODE'  '=SAVE'.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE = 'S'.   " 갱신세션

  CALL TRANSACTION 'MM02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ 'M3' AND
     MESSTAB-MSGV1  NE SPACE AND
    ( MESSTAB-MSGNR EQ '800' OR MESSTAB-MSGNR EQ '801' ).
    "자재 &을(를) 생성 OR 변경 했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_CSPLIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ADD_CSPLIT  USING    P_LINE LIKE GS_DATA.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  DATA: LV_MATNR TYPE MATNR.

  CLEAR: LV_MATNR.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = P_LINE-MATNR
    IMPORTING
      OUTPUT = LV_MATNR.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         LV_INDEX, LV_TEXT.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0060',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-MATNR' P_LINE-MATNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0070',
        ' ' 'BDC_OKCODE'  '=SELA'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0070',
        ' ' 'BDC_OKCODE'  '=ENTR'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '0080',
        ' ' 'BDC_OKCODE'  '=ENTR',
        ' ' 'RMMG1-WERKS' P_LINE-WERKS.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5004',
        ' ' 'BDC_OKCODE'  '=SP14'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=PB11'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCMKV'    '0110',
        ' ' 'BDC_OKCODE'  '=MAKZ',
        ' ' 'MAKV-CSPLIT(01)' '1',
        ' ' 'MAKV-KTEXT(01)' LV_MATNR,
        ' ' 'MAKV-SCNAM(01)' '1'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCMKV'    '0110',
        ' ' 'BDC_OKCODE'  '=MAKZ'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCMKV'    '0130',
        ' ' 'BDC_OKCODE'  '=NEXT',
        ' ' 'MAKZ-SCZUO(01)' '1',
        ' ' 'MAKZ-KUPPL(01)' P_LINE-MATNR,
        ' ' 'MAKZ-DATUB(01)' '99991231',
        ' ' 'MAKZ-ZIFFR(01)' '1'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCMKV'    '0130',
        ' ' 'BDC_OKCODE'  '=NEXT'.

  PERFORM DYNPRO USING:
        'X' 'SAPLMGMM'    '5000',
        ' ' 'BDC_OKCODE'  '=BU'.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE = 'S'.   " 갱신세션

  CALL TRANSACTION 'MM02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ 'M3' AND
     MESSTAB-MSGV1  NE SPACE AND
    ( MESSTAB-MSGNR EQ '800' OR MESSTAB-MSGNR EQ '801' ).
    "자재 &을(를) 생성 OR 변경 했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M05. "확장되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MATKL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM SET_MATKL  USING    P_LINE LIKE GS_DATA.

  DATA: LV_OBJECT   LIKE AUSP-OBJEK,
        LT_SCLASS   TYPE TABLE OF SCLASS,
        LT_CLOBJDAT TYPE TABLE OF CLOBJDAT.

  DATA: LV_MATKL_1(1),   "자재그룹 1번 자리
        LV_MATKL_24(3),  "자재그룹 2번~3번 자리 + 4번 자리('-')
        LV_MATKL_57(3),  "자재그룹 5번~7번 자리
        LV_MATKL_89(2).  "자재그룹 8번~9번 자리

  DATA: LV_ATWRT1 TYPE ATWRT.

  CLEAR: LV_MATKL_1, LV_MATKL_24, LV_MATKL_57, LV_MATKL_89.

  "자재그룹 1번 자리
  CASE P_LINE-MTART.
    WHEN 'FERT' OR 'MCFE'.
      LV_MATKL_1 = 'F'.
    WHEN 'HALB' OR 'MCHF'.
      LV_MATKL_1 = 'H'.
    WHEN 'HAWA' OR 'MCHA'.
      LV_MATKL_1 = 'W'.
  ENDCASE.

  "자재그룹 2번~3번 자리 + 4번 자리('-')
  "회사코드 추출
  SELECT SINGLE BUKRS
    FROM T001K
   WHERE BWKEY EQ @P_LINE-WERKS
    INTO @DATA(LV_BUKRS).

  "SPG 코드 발췌
  SELECT SINGLE CLASS
    FROM ZEDT0031
   WHERE BUKRS = @LV_BUKRS
     AND SPART = @P_LINE-SPART
    INTO @LV_MATKL_24.

  LV_MATKL_24 = LV_MATKL_24 && |-|.

  IF P_LINE-MTART EQ 'FERT' OR P_LINE-MTART EQ 'MCFE' OR
     P_LINE-MTART EQ 'HALB' OR P_LINE-MTART EQ 'MCHF'.

    CLEAR: LV_OBJECT.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = P_LINE-MATNR
      IMPORTING
        OUTPUT       = LV_OBJECT
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

    "자재에 할당된 CLASS의 특성값 추출
    CLEAR: LT_SCLASS, LT_CLOBJDAT.
    CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
      EXPORTING
        CLASSTYPE          = '001'     "-. Class Type
        OBJECT             = LV_OBJECT "-. 자재
        INITIAL_CHARACT    = SPACE     "-. space
        NO_VALUE_DESCRIPT  = GC_X      "-. 'X'
      TABLES
        T_CLASS            = LT_SCLASS
        T_OBJECTDATA       = LT_CLOBJDAT
      EXCEPTIONS
        NO_CLASSIFICATION  = 1
        NO_CLASSTYPES      = 2
        INVALID_CLASS_TYPE = 3
        OTHERS             = 4.

    SORT LT_CLOBJDAT BY ATNAM.

    "자재그룹 5번~7번 자리
    DATA(LV_ATWRT) = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_PROC_NAME' ]-AUSP1 OPTIONAL ).

    LV_MATKL_57 = LV_ATWRT.

    "자재그룹 8번~9번 자리
    CLEAR: LV_ATWRT1.
    LV_ATWRT1 = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_COND_MAT' ]-AUSP1 OPTIONAL ).

    IF LV_ATWRT1 IS INITIAL.
      SELECT SINGLE SUL_NO
        FROM ZEDT1050
       WHERE MATNR_N EQ @P_LINE-MATNR
        INTO @DATA(LV_SUL_NO).

      SELECT SINGLE ATWRT
        FROM ZEDT1060
       WHERE SUL_NO EQ @LV_SUL_NO
         AND ATNAM EQ 'PD_CA_COND_MAT'
        INTO @LV_ATWRT1.
    ENDIF.

    CLEAR: LV_ATWRT.
    CASE LV_ATWRT1.
      WHEN 'A'.
        LV_ATWRT = 'CU'.
      WHEN 'AL'.
        LV_ATWRT = 'AL'.
      WHEN 'TA'.
        LV_ATWRT = 'TA'.
    ENDCASE.

    LV_MATKL_89 = LV_ATWRT.
  ENDIF.

  "자재그룹 명 합치기
  IF P_LINE-MTART EQ 'MCHF' AND
   ( P_LINE-SPART EQ '10' OR P_LINE-SPART EQ '90' ).
    P_LINE-MATKL = 'RW600109'.
  ELSEIF P_LINE-MTART EQ 'HAWA' OR P_LINE-MTART EQ 'MCHA'.
    P_LINE-MATKL = LV_MATKL_1 && LV_MATKL_24 && |00000|.
  ELSE.
    P_LINE-MATKL = LV_MATKL_1 && LV_MATKL_24 && LV_MATKL_57 && LV_MATKL_89.

    SELECT SINGLE MANDT
      FROM T023
     WHERE MATKL EQ @P_LINE-MATKL
      INTO @DATA(LV_MANDT).

    IF SY-SUBRC NE 0.
      P_LINE-MATKL = P_LINE-MATKL && |CU|.
    ENDIF.

  ENDIF.

  "플랜트:6581 -> RW600107 고정
  IF P_LINE-WERKS EQ '6581'.
    P_LINE-MATKL = 'RW600107'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DEFLT_ZGTPPT1080
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM GET_DEFLT_ZGTPPT1080  USING    P_LINE LIKE GS_DATA.

  DATA: LS_1080 LIKE GS_1080.

  DATA: LV_DYN(50),
        LV_MATKL   TYPE MATKL,
        LV_MANDT   TYPE MANDT.

  CLEAR: LS_1080.
  SELECT SINGLE *
    FROM ZGTPPT1080
   WHERE WERKS EQ @P_LINE-WERKS
     AND SPART EQ @P_LINE-SPART
     AND MTART EQ @P_LINE-MTART
     AND MATKL EQ @P_LINE-MATKL
    INTO @LS_1080.

  IF LS_1080 IS INITIAL.
    CLEAR: LV_DYN, LV_MATKL.
    LV_MATKL = |%| && P_LINE-MATKL+0(7) && |%|.
    LV_DYN = 'MATKL LIKE @LV_MATKL'.

    SELECT SINGLE *
      FROM ZGTPPT1080
     WHERE WERKS EQ @P_LINE-WERKS
       AND SPART EQ @P_LINE-SPART
       AND MTART EQ @P_LINE-MTART
       AND (LV_DYN)
      INTO @LS_1080.
  ENDIF.

  IF SY-SUBRC EQ 0.
    P_LINE-STRGR = LS_1080-STRGR.
    P_LINE-DISMM = LS_1080-DISMM.
    P_LINE-DISPO = LS_1080-DISPO.
    P_LINE-DISLS = LS_1080-DISLS.
    P_LINE-BESKZ = LS_1080-BESKZ.
    P_LINE-SOBSL = LS_1080-SOBSL.
    P_LINE-LGPRO = LS_1080-LGPRO.
    P_LINE-LGFSB = LS_1080-LGFSB.
    P_LINE-RGEKZ = LS_1080-RGEKZ.
    P_LINE-MTVFP = LS_1080-MTVFP.
    P_LINE-SBDKZ = LS_1080-SBDKZ.
    P_LINE-XCHAR = LS_1080-XCHAR.
    P_LINE-UEETK = LS_1080-UEETK.
    P_LINE-FEVOR = LS_1080-FEVOR.
    P_LINE-SFCPF = LS_1080-SFCPF.
    P_LINE-DPCBT = LS_1080-DPCBT.
    P_LINE-KZKUP = LS_1080-KZKUP.
    P_LINE-DISGR = LS_1080-DISGR.
    P_LINE-INSMK = LS_1080-INSMK.

    "설계서에 설정된 조달유형 BESKZ = 'EP' and
    "WERKS = 6500 or WERKS = 6600 인 경우
    "고정값 대신 조달유형 = 'F', 특별조달유형 = '30', 연산품 = SPACE 로 변경
    "설계정보 추출
    SELECT SINGLE SUL_NO, REV_SEQ, GONG_SEQ
      FROM ZEDT1050
     WHERE MATNR_N EQ @P_LINE-MATNR
      INTO @DATA(LS_1050).

    "해당 공정의 조달유형 추출
    IF LS_1050 IS NOT INITIAL.
      SELECT SINGLE BESKZ
        FROM ZEDT1010
       WHERE SUL_NO EQ @LS_1050-SUL_NO
         AND REV_SEQ EQ @LS_1050-REV_SEQ
         AND GONG_SEQ EQ @LS_1050-GONG_SEQ
        INTO @DATA(LV_BESKZ).

      IF LV_BESKZ EQ 'EP'.
        IF P_LINE-WERKS EQ '6500' OR P_LINE-WERKS EQ '6600'.
          P_LINE-BESKZ = 'F'.
          P_LINE-SOBSL = '30'.
          CLEAR: P_LINE-KZKUP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_DATA .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1100TOP'
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
      WHEN 'ZSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "자재코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제품군
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "제품군내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "자재유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'STRGR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "생산전략
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISMM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "MRP유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "MRP관리자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISLS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "로트크기유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "조달유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "특별조달유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGPRO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGFSB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "외부조달저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'RGEKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "백플러쉬
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTVFP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "가용성점검
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SBDKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "개별/일괄
        <LS_FCAT>-JUST = GC_C.
      WHEN 'XCHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "배치관리
        <LS_FCAT>-JUST = GC_C.
      WHEN 'UEETK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "무제한허용
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FEVOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "생산감독자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SFCPF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "생산일정프로파일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DPCBT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "단일단위배치기본값
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KZKUP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "연산품
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISGR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "MRP그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'INSMK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "검사재고로 전기
        <LS_FCAT>-JUST = GC_C.
      WHEN 'STDPD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "구성형자재
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_RM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_RM .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1100TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA_RM'
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
      IT_DATA         = GT_DATA_RM
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "자재코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "자재유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGPRO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산저장위치
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'SBDKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "개별/일괄
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'KAUSF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "구성부품스크랩
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'RGEKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "백플러시
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_RMU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_RMU .

  DATA: LS_1080 LIKE GS_1080.

  DATA: LV_DYN(50),
        LV_MATKL   TYPE MATKL.

  IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
    LOOP AT GT_DATA_RM ASSIGNING FIELD-SYMBOL(<FS_RM>).
      <FS_RM>-ZSTAT = ICON_LED_INACTIVE.

      IF P_R1 EQ GC_X.
        "DEFAULT 값 세팅
        CLEAR: LS_1080.
        SELECT SINGLE *
          FROM ZGTPPT1080
         WHERE WERKS EQ @<FS_RM>-WERKS
           AND MTART EQ @<FS_RM>-MTART
           AND MATKL EQ @<FS_RM>-MATKL
          INTO @LS_1080.

        IF LS_1080 IS INITIAL.
          IF <FS_RM>-MATKL IS NOT INITIAL.
            CLEAR: LV_DYN, LV_MATKL.
            LV_MATKL = <FS_RM>-MATKL+0(1) && |%|.
            LV_DYN = 'MATKL LIKE @LV_MATKL'.

            SELECT SINGLE *
              FROM ZGTPPT1080
             WHERE WERKS EQ @<FS_RM>-WERKS
               AND MTART EQ @<FS_RM>-MTART
               AND (LV_DYN)
              INTO @LS_1080.
          ENDIF.
        ENDIF.

        IF LS_1080 IS NOT INITIAL AND SY-SUBRC EQ 0.
          <FS_RM>-LGPRO = LS_1080-LGPRO.
          <FS_RM>-SBDKZ = LS_1080-SBDKZ.
          <FS_RM>-RGEKZ = LS_1080-RGEKZ.
        ENDIF.

        "배치관리 지시자 설정여부
        SELECT SINGLE XCHAR
          FROM MARC
         WHERE MATNR EQ @<FS_RM>-MATNR
           AND WERKS EQ @<FS_RM>-WERKS
          INTO @DATA(LV_XCHAR).

        "배치관리 지시자에 값이 있으면 백플러쉬 미반영
        IF LV_XCHAR NE SPACE.
          CLEAR: <FS_RM>-RGEKZ.
        ENDIF.

        "구성부품스크랩추출
        SELECT SINGLE KAUSF
          FROM ZGTPPT1150
         WHERE WERKS EQ @<FS_RM>-WERKS
           AND BISMT EQ @<FS_RM>-BISMT+1(4)
          INTO @<FS_RM>-KAUSF.

        "백플러시가 미설정인 경우 컴포넌트 스크랩율 미반영
        IF <FS_RM>-RGEKZ EQ SPACE.
          CLEAR: <FS_RM>-KAUSF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ELSEIF P_R7 EQ GC_X.
    LOOP AT GT_DATA_UPDATE ASSIGNING FIELD-SYMBOL(<FS_UP>).
      <FS_UP>-ZSTAT = ICON_LED_INACTIVE.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXEC_RM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC_RM .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_RM> LIKE GS_DATA_RM.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "자재마스터 확장(MRP,작업일정뷰)
      TEXT_QUESTION         = TEXT-T05 "자재마스터 확장을 하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA_RM ASSIGNING <FS_RM> INDEX LT_ROW_NO-ROW_ID.

      PERFORM EXEC_EXTENSIONIN_MAT_RM USING <FS_RM>.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_EXTENSIONIN_MAT_RM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_RM>
*&---------------------------------------------------------------------*
FORM EXEC_EXTENSIONIN_MAT_RM  USING    P_LINE LIKE GS_DATA_RM.

  CLEAR: HEADDATA, CLIENTDATA, CLIENTDATAX, PLANTDATA, PLANTDATAX.

  "확장뷰선택
  HEADDATA-MATERIAL = P_LINE-MATNR. "자재코드
  HEADDATA-MRP_VIEW = GC_X.         "MRP뷰

  "플랜트확장(MRP1,2,3,4/작업일정뷰)
  PLANTDATA-PLANT      = P_LINE-WERKS. "플랜트
  PLANTDATA-ISS_ST_LOC = P_LINE-LGPRO. "생산저장위치
  PLANTDATA-DEP_REQ_ID = P_LINE-SBDKZ. "개별/일괄
  PLANTDATA-COMP_SCRAP = P_LINE-KAUSF. "구성부품스크랩
  PLANTDATA-BACKFLUSH  = P_LINE-RGEKZ. "백플러시

  PLANTDATAX-PLANT      = P_LINE-WERKS. "플랜트
  PLANTDATAX-ISS_ST_LOC = GC_X.         "생산저장위치
  PLANTDATAX-DEP_REQ_ID = GC_X.         "개별/일괄
  PLANTDATAX-COMP_SCRAP = GC_X.         "구성부품스크랩
  PLANTDATAX-BACKFLUSH  = GC_X.         "백플러시

  REFRESH RETURNMESSAGES.
  CLEAR: GS_RETURN, RETURNMESSAGES.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      HEADDATA       = HEADDATA
      PLANTDATA      = PLANTDATA
      PLANTDATAX     = PLANTDATAX
    IMPORTING
      RETURN         = GS_RETURN
    TABLES
      RETURNMESSAGES = RETURNMESSAGES.

  IF GS_RETURN-TYPE EQ 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-ZSTAT = ICON_LED_RED.
    P_LINE-ZMESSAGE = GS_RETURN-MESSAGE.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = GS_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_UPDATE .

  "모품목의 제품군과 자품목의 생산저장위치 맵핑 정보 추출
  CLEAR: GT_1010.
  SELECT FLD_03, FLD_01, FLD_05
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_1070
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

  SORT GT_1010 BY FLD_03 FLD_01 FLD_05.

  "BOM 구성품 중 점검 대상 추출
  CLEAR: GT_DATA_UPDATE.
  SELECT DISTINCT A~WERKS, A~MATNR AS PMATN, A~STLAN,
         B~IDNRK AS CMATN, B~POSNR, B~LGORT,
         C~MTART, C~MATKL,
         D~MAKTX AS CMAKT,
         E~MAKTX AS PMAKT,
         F~NAME1,
         G~MTBEZ,
         H~WGBEZ
    FROM            MAST  AS A
   INNER       JOIN STPO  AS B ON B~STLNR EQ A~STLNR
   INNER       JOIN MARA  AS C ON C~MATNR EQ B~IDNRK
    LEFT OUTER JOIN MAKT  AS D ON D~MATNR EQ B~IDNRK
                              AND D~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN MAKT  AS E ON E~MATNR EQ A~MATNR
                              AND E~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS F ON F~WERKS EQ A~WERKS
    LEFT OUTER JOIN T134T AS G ON G~SPRAS EQ @SY-LANGU
                              AND G~MTART EQ C~MTART
    LEFT OUTER JOIN T023T AS H ON H~SPRAS EQ @SY-LANGU
                              AND H~MATKL EQ C~MATKL
   WHERE A~WERKS EQ @P_WERKS
     AND A~STLAN EQ '1'
     AND C~MTART IN @S_MTART
     AND C~MTART IN ('ROH1', 'ROH2')
     AND C~MATKL IN @S_MATKL
     AND B~IDNRK IN @S_MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA_UPDATE.

  LOOP AT GT_DATA_UPDATE ASSIGNING FIELD-SYMBOL(<FS_UP>).
    "모품목 제품군, 제품군내역 추출
    SELECT SINGLE A~SPART, B~VTEXT
      FROM MARA AS A
      LEFT OUTER JOIN TSPAT AS B ON B~SPRAS EQ @SY-LANGU
                                AND B~SPART EQ A~SPART
     WHERE A~MATNR EQ @<FS_UP>-PMATN
      INTO ( @<FS_UP>-SPART, @<FS_UP>-VTEXT ).

    "자품목 자재마스터 생산저장위치, 내역 추출
    SELECT SINGLE A~LGPRO, B~LGOBE
      FROM MARC AS A
      LEFT OUTER JOIN T001L AS B ON B~WERKS EQ A~WERKS
                                AND B~LGORT EQ A~LGPRO
     WHERE A~MATNR EQ @<FS_UP>-CMATN
       AND A~WERKS EQ @<FS_UP>-WERKS
      INTO ( @<FS_UP>-LGPRO, @<FS_UP>-LGOBE ).
  ENDLOOP.

  SORT GT_DATA_UPDATE BY WERKS SPART LGPRO.

  UNASSIGN: <FS_UP>.
  LOOP AT GT_DATA_UPDATE ASSIGNING <FS_UP>.
    READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_03 = <FS_UP>-WERKS
                                                   FLD_01 = <FS_UP>-SPART
                                                   FLD_05 = <FS_UP>-LGPRO.
    IF SY-SUBRC EQ 0.
      <FS_UP>-DEL = GC_X.
    ENDIF.
  ENDLOOP.

  DELETE GT_DATA_UPDATE WHERE DEL EQ GC_X.

  SORT GT_DATA_UPDATE BY PMATN SPART POSNR CMATN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_UPDATE .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1100TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA_UPDATE'
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
      IT_DATA         = GT_DATA_UPDATE
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PMATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "모품목코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PMAKT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "모품목내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제품군
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'VTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "제품군내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "BOM품목번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'CMATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'CMAKT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "자재유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGPRO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "(자재마스터)생산저장위치
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "(BOM)생산저장위치
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXEC_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC_UPDATE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_UP> LIKE GS_DATA_UPDATE.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T10 "BOM 생산 저장위치 업데이트
      TEXT_QUESTION         = TEXT-T11 "BOM 생산 저장위치 업데이트를 하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA_UPDATE ASSIGNING <FS_UP> INDEX LT_ROW_NO-ROW_ID.

      PERFORM EXEC_BOM_LGORT_UPDATE USING <FS_UP>.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_BOM_LGORT_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_UP>
*&---------------------------------------------------------------------*
FORM EXEC_BOM_LGORT_UPDATE  USING    P_LINE LIKE GS_DATA_UPDATE.

  DATA: LV_INDEX TYPE SY-TABIX,
        LV_TEXT  TYPE CHAR255.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
        LV_INDEX, LV_TEXT.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '0100',
        ' ' 'BDC_OKCODE'  '=FCPU',
        ' ' 'RC29N-MATNR' P_LINE-PMATN,
        ' ' 'RC29N-WERKS' P_LINE-WERKS,
        ' ' 'RC29N-STLAN' P_LINE-STLAN.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '2150',
        ' ' 'BDC_OKCODE'  '=SETP'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '0708',
        ' ' 'BDC_OKCODE'  '=CLWI',
        ' ' 'BDC_CURSOR'  'RC29P-SELPO',
        ' ' 'RC29P-SELPO' P_LINE-POSNR.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '2150',
*        ' ' 'BDC_OKCODE'  '=/CS',
        ' ' 'BDC_OKCODE'  '=PALL',
*        ' ' 'BDC_CURSOR'  'RC29P-POSNR(01)'.
        ' ' 'RC29P-AUSKZ(01)' 'X'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '2130',
        ' ' 'BDC_OKCODE'  '=PDAT'.

  PERFORM DYNPRO USING:
        'X' 'SAPLCSDI'    '2130',
        ' ' 'BDC_OKCODE'  '=FCBU',
        ' ' 'BDC_CURSOR'  'RC29P-LGORT',
        ' ' 'RC29P-LGORT' P_LINE-LGORT.

  CLEAR: GS_PARAMS.
  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = 'A'.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'CS02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: LV_INDEX.
  LV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX LV_INDEX.

  CLEAR: LV_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MESSTAB-MSGID
      MSGNR               = MESSTAB-MSGNR
      MSGV1               = MESSTAB-MSGV1
      MSGV2               = MESSTAB-MSGV2
      MSGV3               = MESSTAB-MSGV3
      MSGV4               = MESSTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = LV_TEXT.

  IF MESSTAB-MSGTYP EQ 'S'   AND MESSTAB-MSGID EQ '29' AND
     MESSTAB-MSGV1  NE SPACE AND MESSTAB-MSGNR EQ '031'.
    "자재 &에 대한 BOM을 변경했습니다.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZSTAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = LV_TEXT.

  ELSE.
    IF MESSTAB-MSGTYP EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-ZSTAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LV_TEXT.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      P_LINE-ZSTAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M22. "업데이트되었습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COMP_SCRAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_COMP_SCRAP .

  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M02. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CHECK P_WERKS IS NOT INITIAL.

  PERFORM GET_ZGTPPT1150.

  CALL SCREEN 0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_RM_N
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_RM_N .
  CLEAR: GT_DATA_RM.

  SELECT A~WERKS,
         B~MATNR, B~MTART, B~MATKL, B~BISMT,
         C~MAKTX,
         D~NAME1,
         E~MTBEZ,
         F~WGBEZ
    FROM            MARC AS A
   INNER       JOIN MARA AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN MAKT AS C ON C~MATNR EQ B~MATNR
                             AND C~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN T134T AS E ON E~SPRAS EQ @SY-LANGU
                              AND E~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MATKL EQ B~MATKL
   WHERE A~WERKS EQ @P_WERKS
     AND A~LGPRO EQ @SPACE
     AND A~MMSTA NE 'ZD'
     AND B~MTART IN @S_MTART
     AND B~MTART IN ('ROH1', 'ROH2', 'MRM1', 'MRM2')
     AND B~MATKL IN @S_MATKL
     AND B~MATNR IN @S_MATNR
     AND B~ERSDA IN @S_ERSDA
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA_RM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_RM_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_RM_C .
  CLEAR: GT_DATA_RM.

  SELECT A~WERKS, A~LGPRO, A~SBDKZ, A~KAUSF, A~RGEKZ,
         B~MATNR, B~MTART, B~MATKL, B~BISMT,
         C~MAKTX,
         D~NAME1,
         E~MTBEZ,
         F~WGBEZ
    FROM            MARC AS A
   INNER       JOIN MARA AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN MAKT AS C ON C~MATNR EQ B~MATNR
                             AND C~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN T134T AS E ON E~SPRAS EQ @SY-LANGU
                              AND E~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MATKL EQ B~MATKL
   WHERE A~WERKS EQ @P_WERKS
     AND A~LGPRO NE @SPACE
     AND A~PSTAT LIKE '%D%'
     AND A~MMSTA NE 'ZD'
     AND B~MTART IN @S_MTART
     AND B~MTART IN ('ROH1', 'ROH2', 'MRM1', 'MRM2')
     AND B~MATKL IN @S_MATKL
     AND B~MATNR IN @S_MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA_RM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZGTPPT1150
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ZGTPPT1150 .

  CLEAR: GT_1150.
  SELECT A~*,
         B~NAME1
    FROM ZGTPPT1150 AS A
    LEFT JOIN T001W AS B ON B~WERKS EQ A~WERKS
   WHERE A~WERKS EQ @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_1150.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN_0200 .
  CLEAR: GT_FIELDCAT_0200[], GS_LAYOUT_0200, GT_EXCLUDE_0200[],
         GT_EXCLUDE_0200,
         GV_OK_CODE, GV_DBCNT,
         GT_1150[].

  CALL METHOD GO_CONTAIN_0200->FREE.
  CLEAR : GO_CONTAIN_0200, GO_GRID_0200.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .
  CREATE OBJECT GO_CONTAIN_0200
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

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .
  CLEAR GS_LAYOUT_0200.
*  GS_LAYOUT_0200-ZEBRA      = GC_X.
  GS_LAYOUT_0200-COL_OPT    = GC_X.
*  GS_LAYOUT_0200-CWIDTH_OPT = GC_X.
*  GS_LAYOUT_0200-NO_ROWINS  = GC_X.
  GS_LAYOUT_0200-SEL_MODE   = GC_D.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1100TOP'
      I_INTERNAL_TABNAME     = 'GS_1150'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_1150
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'BISMT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "기존구매자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'BISNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'BISSP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F42. "자재규격
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'KAUSF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "컴포넌트스크랩율(%)
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .
  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_1150
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ADDLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ADDLINE .

  CLEAR: GS_1150.

  GS_1150-WERKS = P_WERKS.

  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @P_WERKS
    INTO @GS_1150-NAME1.

  APPEND GS_1150 TO GT_1150.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DELLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DELLINE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_1150.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0200.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T12 "컴포넌트 스크랩율 삭제
      TEXT_QUESTION         = TEXT-T13 "선택한 레코드를 삭제하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_1150 ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      DELETE GT_1150 INDEX LT_ROW_NO-ROW_ID.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0200.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ZSAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ZSAVE .
  DATA: L_ANSWER TYPE CHAR01.

  DATA: LT_ZGTPPT1150 LIKE TABLE OF ZGTPPT1150,
        LS_ZGTPPT1150 LIKE ZGTPPT1150.

  DATA: LV_CX_REF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_1150.

  CLEAR: L_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T14 "컴포넌트 스크랩율 저장
      TEXT_QUESTION         = TEXT-T15 "데이터를 저장하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_ZGTPPT1150.
    LOOP AT GT_1150 INTO GS_1150.
      MOVE-CORRESPONDING GS_1150 TO LS_ZGTPPT1150.

      APPEND LS_ZGTPPT1150 TO LT_ZGTPPT1150.
      CLEAR: GS_1150, LS_ZGTPPT1150.
    ENDLOOP.

    DELETE FROM ZGTPPT1150 WHERE WERKS EQ P_WERKS.

    IF LT_ZGTPPT1150 IS NOT INITIAL.
      TRY.
          INSERT ZGTPPT1150 FROM TABLE LT_ZGTPPT1150.
          IF SY-SUBRC EQ 0.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
        CATCH CX_ROOT INTO LV_CX_REF.
          ROLLBACK WORK.
      ENDTRY.
    ENDIF.

    MESSAGE S004.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_KAUSF_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_KAUSF_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_RM> LIKE GS_DATA_RM.

  READ TABLE GT_DATA_RM ASSIGNING <FS_RM> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  IF L_VALUE IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'KAUSF'
        I_VALUE     = SPACE.

  ELSE.
    "배치관리 지시자 설정여부
    SELECT SINGLE XCHAR
      FROM MARC
     WHERE MATNR EQ @<FS_RM>-MATNR
       AND WERKS EQ @<FS_RM>-WERKS
      INTO @DATA(LV_XCHAR).

    IF LV_XCHAR NE SPACE.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'RGEKZ'
          I_VALUE     = SPACE.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'KAUSF'
          I_VALUE     = SPACE.

    ELSE.
      "구성부품스크랩추출
      SELECT SINGLE KAUSF
        FROM ZGTPPT1150
       WHERE WERKS EQ @<FS_RM>-WERKS
         AND BISMT EQ @<FS_RM>-BISMT+1(4)
        INTO @DATA(LV_KAUSF).

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'KAUSF'
          I_VALUE     = LV_KAUSF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXPAND_PURVIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM EXPAND_PURVIEW  USING    P_LINE LIKE GS_DATA.

  DATA: LV_TYPE    TYPE BAPI_MTYPE,
        LV_MESSAGE TYPE BAPI_MSG.

  CLEAR: LV_TYPE, LV_MESSAGE.
  CALL FUNCTION 'ZGTMM_EXPAND_PURVIEW'
    EXPORTING
      I_MATNR   = P_LINE-MATNR
      I_WERKS   = P_LINE-WERKS
      I_BESKZ   = P_LINE-BESKZ
      I_SOBSL   = P_LINE-SOBSL
    IMPORTING
      E_TYPE    = LV_TYPE
      E_MESSAGE = LV_MESSAGE.

ENDFORM.
