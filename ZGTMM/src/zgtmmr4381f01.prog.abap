*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BUKRS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_BUKRS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    BUKRS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_WERKS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_WERKS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    WERKS
    FROM T001W
    WHERE WERKS EQ @P_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_LGORT .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_LGORT IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    LGORT
    FROM T001L
    WHERE LGORT EQ @P_LGORT
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  "오류가 있으면 종료
  IF GV_ERROR EQ ABAP_TRUE.
    LEAVE LIST-PROCESSING.
  ENDIF.

* DATA SELECT
  CASE ABAP_TRUE.
    WHEN P_ADJ. "조정처리
      PERFORM F_GET_DATA_ADJ.

    WHEN P_DISP. "조회
      PERFORM F_GET_DATA_DISP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  CASE ABAP_TRUE.
    WHEN P_ADJ.
      IF GT_ADJ[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 100.

    WHEN P_DISP.
      IF GT_DISP[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 200.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_ADJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_ADJ .

  "초기화
  CLEAR:
    GT_ADJ[].

  SELECT
      CV~WERKS,
      TW~NAME1,
      CV~LGORT,
      TL~LGOBE,
      CV~MATNR,
      MK~MAKTX,
      CV~CHARG,
      CV~LABST,
      CV~MEINS
    FROM ZGTMM_CV_GET_STOCKLIST AS CV
    JOIN MARA AS M ON CV~MATNR EQ M~MATNR
    LEFT OUTER JOIN T001W AS TW ON CV~WERKS EQ TW~WERKS
                                                    AND TW~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001L AS TL ON CV~WERKS EQ TL~WERKS
                                                   AND CV~LGORT EQ TL~LGORT
    LEFT OUTER JOIN MAKT AS MK ON CV~MATNR EQ MK~MATNR
                                                   AND MK~SPRAS EQ @SY-LANGU
    WHERE CV~WERKS = @P_WERKS
    AND CV~LGORT = @P_LGORT
    AND CV~MATNR IN @S_MATNR
    AND M~MTART EQ @GC_SCRP
    ORDER BY CV~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_ADJ.

*  LOOP AT GT_ADJ ASSIGNING FIELD-SYMBOL(<LS_ADJ>).
*    "--STYLE 설정
*    PERFORM F_SET_ALV_STYLE_GT_ADJ CHANGING <LS_ADJ>.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SCREEN_ATTR_1000 .

  LOOP AT SCREEN.

    CASE SCREEN-GROUP1.
      WHEN 'DIS'.
        IF P_ADJ EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  "--전기일자 초기값
  IF S_BUDAT[] IS INITIAL.
    S_BUDAT[] = VALUE #( ( SIGN = 'I'
                                          OPTION = 'BT'
                                          LOW = SY-DATUM - 30
                                          HIGH = SY-DATUM  ) ).
  ENDIF.

  "--저장위치 초기값
  IF P_LGORT IS INITIAL.
    P_LGORT = GC_1900.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_DISP .
  "초기화
  CLEAR:
    GT_DISP[].

  SELECT
    MD~MBLNR,
    MD~MJAHR,
    MD~ZEILE,
    MD~BUDAT,
    MD~BWART,
    TT~BTEXT,
    MD~WERKS,
    TW~NAME1,
    MD~LGORT,
    TL~LGOBE,
    MD~MATNR,
    MK~MAKTX,
    MD~CHARG,
    MD~ERFMG,
    MD~ERFME,
    MD~USNAM,
    AD~NAME_TEXT
    FROM MATDOC AS MD
    JOIN MARA AS M ON MD~MATNR EQ M~MATNR
    JOIN USR21 AS UR ON MD~USNAM EQ UR~BNAME
    LEFT OUTER JOIN ADRP AS AD ON UR~PERSNUMBER EQ AD~PERSNUMBER
    LEFT OUTER JOIN MAKT AS MK ON MD~MATNR EQ MK~MATNR
                                                   AND MK~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T156T AS TT ON MD~BWART EQ TT~BWART
                                                   AND MD~SOBKZ EQ TT~SOBKZ
                                                   AND MD~KZBEW EQ TT~KZBEW
                                                   AND MD~KZZUG EQ TT~KZZUG
                                                   AND MD~KZVBR EQ TT~KZVBR
                                                   AND TT~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W AS TW ON MD~WERKS EQ TW~WERKS
                                                AND TW~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001L AS TL ON MD~WERKS EQ TL~WERKS
                                                   AND MD~LGORT EQ TL~LGORT
    WHERE MD~WERKS EQ @P_WERKS
    AND MD~LGORT EQ @P_LGORT
    AND MD~BUDAT IN @S_BUDAT
    AND MD~MATNR IN @S_MATNR
    AND M~MTART EQ @GC_SCRP
    AND MD~BWART IN ( @GC_Z21, @GC_Z22 )
    AND MD~MBLNR NE @SPACE  "자재문서 존재
    AND MD~CANCELLED EQ @SPACE  "취소상태 자재문서 제외
    AND MD~SMBLN EQ @SPACE  "취소 자재문서 제외
    ORDER BY MD~MJAHR, MD~BUDAT, MD~MBLNR, MD~ZEILE
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_RESULT .

  "--오류(LED RED)건 초기화
  CASE ABAP_TRUE.
    WHEN P_ADJ.
      LOOP AT GT_ADJ ASSIGNING FIELD-SYMBOL(<LS_ADJ>) WHERE RESULT = ICON_LED_RED.
        <LS_ADJ>-RESULT = SPACE.
        <LS_ADJ>-MESSAGE = SPACE.
      ENDLOOP.
    WHEN P_DISP.
      LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) WHERE RESULT = ICON_LED_RED.
        <LS_DISP>-RESULT = SPACE.
        <LS_DISP>-MESSAGE = SPACE.
      ENDLOOP.
  ENDCASE.

ENDFORM.
