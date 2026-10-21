*----------------------------------------------------------------------*
***INCLUDE ZNF2COMM .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form  CHECK_AUTHORIZATION        - 회사코드 권한점검
*& Form  POPUP_TO_CONFIRM           - 예, 아니오 확인 팝업창
*& Form  DOMAIN_VALUE_GET           - 도메인 텍스트
*& Form  GET_DEFAULT_COMPANY_DATA   - 회사코드 기본값
*& Form  CONVERSION_EXIT_ALPHA      - ALPHA Conversion
*& Form  PRICE_CLASSIFICATION       - 가격구분/비철수주가
*& Form  PRICE_CLASSIFICATION1      - 가격구분/비철수주가/수주량
*& Form  GET_SAPID_PER_USRID        - 사번으로 SAP ID 찾기
*& Form  GET_USRID_PER_SAPID        - SAP ID로 사번찾기
*& Form  GET_BUKRS_DESC             - 회사 명
*& Form  GET_NFCTR_DESC             - 사업부 명
*& Form  GET_PRCTR_DESC             - 손익센터 명
*& Form  GET_VKGRP_DESC             - 영업그룹 명
*& Form  GET_KUNNR_DESC             - Customer 명
*& Form  GET_LIFNR_DESC             - Vendor/FCM 명
*& Form  GET_PERNR_DESC             - 사원명
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      MACRO APPEND_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DEFINE APPEND_RANGES.
  CLEAR : &1.

  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH   = &5.

  APPEND &1.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&      MACRO APPEND_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DEFINE APPEND_PARAM.
  CLEAR : &1.

  &1-SELNAME = &2.
  &1-KIND    = &3.
  &1-SIGN    = &4.
  &1-OPTION  = &5.
  &1-LOW     = &6.
  &1-HIGH    = &7.

  APPEND &1.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_AUTHORIZATION  USING    PV_BUKRS
                                   PV_ERROR.

  CLEAR : PV_ERROR.

  AUTHORITY-CHECK OBJECT 'ZNF_000002'
       ID 'BUKRS' FIELD PV_BUKRS
       ID 'PRCTR' DUMMY
       ID 'WERKS' DUMMY.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드' PV_BUKRS
            '에 대한 권한을 점검하시기 바랍니다.'.
  ENDIF.

ENDFORM.                    " CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING    PV_TITLE
                                PV_TEXT
                                PV_DEFAULT
                                PV_ANSWER.

  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  DOMAIN_VALUE_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOMAIN_VALUE_GET  USING  PV_DOMNAME
                              PV_DOMVALUE
                              PV_DDTEXT.
  DATA: LV_DOMNAME  LIKE DD07V-DOMNAME,
        LV_DOMVALUE LIKE DD07V-DOMVALUE_L,
        LV_DDTEXT   LIKE  DD07V-DDTEXT.

  CLEAR : LV_DDTEXT, PV_DDTEXT.

  LV_DOMNAME  = PV_DOMNAME.
  LV_DOMVALUE = PV_DOMVALUE.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      I_DOMNAME  = LV_DOMNAME
      I_DOMVALUE = LV_DOMVALUE
    IMPORTING
      E_DDTEXT   = LV_DDTEXT
    EXCEPTIONS
      NOT_EXIST  = 1
      OTHERS     = 2.

  PV_DDTEXT = LV_DDTEXT.

ENDFORM.                    " DOMAIN_VALUE_GET
*&---------------------------------------------------------------------*
*&      Form  GET_DEFAULT_COMPANY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DEFAULT_COMPANY_DATA  USING    PV_BUKRS
                                        PV_WAERS
                                        PV_LAND1
                                        PV_BUTXT
                                        PV_KTOPL
                                        PV_KOKRS.

  CLEAR : PV_WAERS, PV_LAND1, PV_BUTXT,
          PV_KTOPL, PV_KOKRS.

  CHECK PV_BUKRS IS NOT INITIAL.

  SELECT SINGLE A~WAERS
                A~LAND1
                A~BUTXT
                A~KTOPL
                B~KOKRS
    INTO (PV_WAERS, PV_LAND1, PV_BUTXT,
          PV_KTOPL, PV_KOKRS)
    FROM T001 AS A
   INNER JOIN TKA02 AS B
      ON A~BUKRS = B~BUKRS
   WHERE A~BUKRS = PV_BUKRS.

ENDFORM.                    " GET_DEFAULT_COMPANY_DATA
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA  USING    PV_FLAG
                                     PV_VALUE.
  "-> CCM : 2023.04.19 ZITCS4HDEV06 - matnr과 관계없음

  IF PV_FLAG = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE.
  ENDIF.

ENDFORM.                    " CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*&      Form  PRICE_CLASSIFICATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRICE_CLASSIFICATION  USING    PV_CONNO
                                    PV_NFKEY
                                    PV_PRIND
                                    PV_SUJUP
                                    PV_ERROR.
  DATA: LV_PRICE LIKE ZNFT1001-PRICE,
        LV_AVGPR LIKE ZNFT1001-AVGPR,
        LV_OFFCH LIKE ZNFT1001-OFFCH,
        LV_CURPR LIKE ZNFT1001-CURPR,
        LV_WAERS LIKE ZNFT1001-WAERS.

  CLEAR : PV_PRIND, PV_SUJUP, PV_ERROR,
          LV_PRICE, LV_AVGPR, LV_OFFCH,
          LV_CURPR, LV_WAERS.

  CHECK PV_CONNO IS NOT INITIAL AND
        PV_NFKEY IS NOT INITIAL.

  SELECT SINGLE PRICE  "요청가
                WAERS  "통화
                AVGPR  "평균가 기준월
                OFFCH  "Official Cash
                CURPR  "시세계약
    INTO (LV_PRICE, LV_WAERS,
          LV_AVGPR, LV_OFFCH,
          LV_CURPR)
    FROM ZNFT1001
   WHERE CONNO = PV_CONNO
     AND NFKEY = PV_NFKEY.

  IF SY-SUBRC = 0.
    IF LV_PRICE IS NOT INITIAL.
      PV_PRIND = 'Fix Price'.
      WRITE : LV_PRICE TO PV_SUJUP CURRENCY LV_WAERS
                                   LEFT-JUSTIFIED.
*      CONCATENATE PV_SUJUP LV_WAERS
*             INTO PV_SUJUP SEPARATED BY SPACE.
    ELSEIF LV_AVGPR IS NOT INITIAL.
      PV_PRIND = 'Average Price'.

      CALL FUNCTION 'CONVERSION_EXIT_PERI_OUTPUT'
        EXPORTING
          INPUT  = LV_AVGPR
        IMPORTING
          OUTPUT = PV_SUJUP.
    ELSEIF LV_OFFCH IS NOT INITIAL.
      PV_PRIND = 'Official Price'.

      WRITE : LV_OFFCH TO PV_SUJUP.
    ELSEIF LV_CURPR IS NOT INITIAL.
      PV_PRIND = '시세'.
    ELSE.
      PV_ERROR = 'X'.
    ENDIF.
  ELSE.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " PRICE_CLASSIFICATION
*&---------------------------------------------------------------------*
*&      Form  GET_SAPID_PER_USRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SAPID_PER_USRID  USING    PV_PERNR
                                   PV_USRID
                                   PV_COMM.
  DATA: LV_ESSGB LIKE ZPA0105-ZZ_ESSGB, "PA0105 테이블 대체
*        LV_ESSGB LIKE PA0105-ZZ_ESSGB,
        LV_CLASS LIKE USR02-CLASS.

  CLEAR : PV_USRID, PV_COMM, LV_ESSGB, LV_CLASS.

*___개인 ID
*  SELECT SINGLE USRID
*    INTO PV_USRID
*    FROM PA0105
*   WHERE PERNR =  PV_PERNR
*     AND USRTY =  '0001'
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- PA0105 테이블 대체
  SELECT SINGLE USRID
    INTO PV_USRID
    FROM ZPA0105
   WHERE PERNR =  PV_PERNR
     AND USRTY =  '0001'
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- PA0105 테이블 대체

  IF SY-SUBRC = 0.
    SELECT SINGLE CLASS
      INTO LV_CLASS
      FROM USR02
     WHERE BNAME =  PV_USRID
       AND GLTGV <= SY-DATLO
       AND GLTGB >= SY-DATLO
       AND CLASS =  'PUSER'.

    IF SY-SUBRC <> 0.
      SELECT SINGLE CLASS
        INTO LV_CLASS
        FROM USR02
       WHERE BNAME = PV_USRID
         AND GLTGB = '00000000'
         AND CLASS = 'PUSER'.

      IF SY-SUBRC <> 0.
        CLEAR : PV_USRID.

*___공용 ID
*        SELECT SINGLE USRID
*          INTO PV_USRID
*          FROM PA0105
*         WHERE PERNR =  PV_PERNR
*           AND USRTY =  '9001'
*           AND ENDDA >= SY-DATLO
*           AND BEGDA <= SY-DATLO.

*- [MM] PA0105 테이블 대체
        SELECT SINGLE USRID
          INTO PV_USRID
          FROM ZPA0105
         WHERE PERNR =  PV_PERNR
           AND USRTY =  '9001'
           AND ENDDA >= SY-DATLO
           AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체

        IF SY-SUBRC = 0 AND PV_USRID IS NOT INITIAL.
          PV_COMM = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR : PV_USRID.

*___공용 ID
*    SELECT SINGLE USRID
*      INTO PV_USRID
*      FROM PA0105
*     WHERE PERNR =  PV_PERNR
*       AND USRTY =  '9001'
*       AND ENDDA >= SY-DATLO
*       AND BEGDA <= SY-DATLO.

*- [MM] PA0105 테이블 대체
    SELECT SINGLE USRID
      INTO PV_USRID
      FROM ZPA0105
     WHERE PERNR =  PV_PERNR
       AND USRTY =  '9001'
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체

    IF SY-SUBRC = 0 AND PV_USRID IS NOT INITIAL.
      PV_COMM = 'X'.
    ENDIF.
  ENDIF.

**___개인 ID
*  SELECT SINGLE USRID
*                ZZ_ESSGB
*    INTO (PV_USRID, LV_ESSGB)
*    FROM PA0105
*   WHERE PERNR =  PV_PERNR
*     AND USRTY =  '0001'
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.
*
*  IF SY-SUBRC <> 0 OR LV_ESSGB = 'X'.
*    CLEAR : PV_USRID.
*
**___공용 ID
*    SELECT SINGLE USRID
*      INTO PV_USRID
*      FROM PA0105
*     WHERE PERNR =  PV_PERNR
*       AND USRTY =  '9001'
*       AND ENDDA >= SY-DATLO
*       AND BEGDA <= SY-DATLO.
*  ENDIF.

ENDFORM.                    " GET_SAPID_PER_USRID
*&---------------------------------------------------------------------*
*&      Form  GET_USRID_PER_SAPID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_USRID_PER_SAPID  TABLES   PT_PERNR
                          USING    PV_SAPID
                                   PV_PERNR.
  DATA: BEGIN OF LT_PERNR OCCURS 0,
*          PERNR LIKE PA0105-PERNR,
          PERNR LIKE ZPA0105-PERNR, " PA0105 테이블 대체
        END   OF LT_PERNR.

  CLEAR   : PT_PERNR, PV_PERNR.
  REFRESH : PT_PERNR.

*  SELECT SINGLE PERNR
*    INTO PV_PERNR
*    FROM PA0105
*   WHERE USRTY =  '0001'
*     AND USRID =  PV_SAPID
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- [MM] PA0105 테이블 대체
  SELECT SINGLE PERNR
    INTO PV_PERNR
    FROM ZPA0105
   WHERE USRTY =  '0001'
     AND USRID =  PV_SAPID
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체

  IF SY-SUBRC <> 0.
    CLEAR   : LT_PERNR, PV_PERNR.
    REFRESH : LT_PERNR.

*___공용 ID
*    SELECT PERNR
*      INTO TABLE LT_PERNR
*      FROM PA0105
*     WHERE USRTY =  '9001'
*       AND USRID =  PV_SAPID
*       AND ENDDA >= SY-DATLO
*       AND BEGDA <= SY-DATLO.

*- [MM] PA0105 테이블 대체
    SELECT PERNR
      INTO TABLE LT_PERNR
      FROM ZPA0105
     WHERE USRTY =  '9001'
       AND USRID =  PV_SAPID
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체

    IF SY-SUBRC = 0.
      PT_PERNR[] = LT_PERNR[].
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_USRID_PER_SAPID
*&---------------------------------------------------------------------*
*&      Form  GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BUKRS_DESC  USING  PV_BUKRS
                            PV_BUTXT.

  CLEAR : PV_BUTXT.

  CHECK PV_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUTXT
    INTO PV_BUTXT
    FROM T001
   WHERE BUKRS = PV_BUKRS.

ENDFORM.                    " GET_BUKRS_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_NFCTR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_NFCTR_DESC  USING    PV_BUKRS
                              PV_NFCTR
                              PV_NTEXT.

  CLEAR : PV_NTEXT.

  CHECK PV_NFCTR IS NOT INITIAL.

  SELECT SINGLE NTEXT
    INTO PV_NTEXT
    FROM ZNFT0005
   WHERE BUKRS = PV_BUKRS
     AND NFCTR = PV_NFCTR.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '사업부가 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_NFCTR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_PRCTR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PRCTR_DESC  USING    PV_KOKRS
                              PV_PRCTR
                              PV_PTEXT.
  CLEAR : PV_PTEXT.

  CHECK PV_PRCTR IS NOT INITIAL.

  SELECT SINGLE KTEXT
    INTO PV_PTEXT
    FROM CEPCT
   WHERE SPRAS =  SY-LANGU
     AND PRCTR =  PV_PRCTR
     AND DATBI >= SY-DATLO
     AND KOKRS =  PV_KOKRS.

*  SELECT SINGLE PTEXT
*    INTO PV_PTEXT
*    FROM ZNFT0004
*   WHERE KOKRS = PV_KOKRS
*     AND PRCTR = PV_PRCTR.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '손익센터가 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_PRCTR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_VKGRP_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_VKGRP_DESC  USING    PV_KOKRS
                              PV_VKGRP
                              PV_VTEXT.

  CLEAR : PV_VTEXT.

  CHECK PV_VKGRP IS NOT INITIAL.

  SELECT SINGLE BEZEI
    INTO PV_VTEXT
    FROM TVGRT
   WHERE SPRAS = SY-LANGU
     AND VKGRP = PV_VKGRP.

*  SELECT SINGLE VTEXT
*    INTO PV_VTEXT
*    FROM ZNFT0003
*   WHERE KOKRS = PV_KOKRS
*     AND VKGRP = PV_VKGRP.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '영업그룹이 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_VKGRP_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_KUNNR_DESC  USING    PV_KUNNR
                              PV_NAME1.

  CLEAR : PV_NAME1.

  CHECK PV_KUNNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    INTO PV_NAME1
    FROM KNA1
   WHERE KUNNR = PV_KUNNR.

ENDFORM.                    " GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_LIFNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LIFNR_DESC  USING    PV_LIFNR
                              PV_NAME1.

  CLEAR : PV_NAME1.

  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    INTO PV_NAME1
    FROM LFA1
   WHERE LIFNR = PV_LIFNR.

ENDFORM.                    " GET_LIFNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_PERNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PERNR_DESC USING PV_PERNR
                          PV_ENAME.

  CLEAR : PV_ENAME.

  CHECK PV_PERNR IS NOT INITIAL.

*  SELECT SINGLE ENAME
*    INTO PV_ENAME
*    FROM PA0001
*   WHERE PERNR =  PV_PERNR
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- [MM] PA0001 대체
  SELECT SINGLE ENAME
    INTO PV_ENAME
    FROM ZZPA0001
   WHERE PERNR =  PV_PERNR
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- [MM] PA0001 대체

ENDFORM.                    " GET_SNRO_OBJECT_NO
*&---------------------------------------------------------------------*
*&      Form  PRICE_CLASSIFICATION1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRICE_CLASSIFICATION1  USING    PV_CONNO
                                     PV_NFKEY
                                     PV_PRIND
                                     PV_SUJUP
                                     PV_EMENG
                                     PV_ERROR.

  DATA: LV_PRICE LIKE ZNFT1001-PRICE,
        LV_AVGPR LIKE ZNFT1001-AVGPR,
        LV_OFFCH LIKE ZNFT1001-OFFCH,
        LV_CURPR LIKE ZNFT1001-CURPR,
        LV_EMENG LIKE ZNFT1001-EMENG,
        LV_WAERS LIKE ZNFT1001-WAERS.

  CLEAR : PV_PRIND, PV_SUJUP, PV_ERROR,
          PV_EMENG, LV_PRICE, LV_AVGPR,
          LV_OFFCH, LV_CURPR, LV_WAERS,
          LV_EMENG.

  CHECK PV_CONNO IS NOT INITIAL AND
        PV_NFKEY IS NOT INITIAL.

  SELECT SINGLE PRICE  "요청가
                WAERS  "통화
                AVGPR  "평균가 기준월
                OFFCH  "Official Cash
                CURPR  "시세계약
                EMENG  "수주량
    INTO (LV_PRICE, LV_WAERS,
          LV_AVGPR, LV_OFFCH,
          LV_CURPR, LV_EMENG)
    FROM ZNFT1001
   WHERE CONNO = PV_CONNO
     AND NFKEY = PV_NFKEY.

  IF SY-SUBRC = 0.
    PV_EMENG = LV_EMENG.

    IF LV_PRICE IS NOT INITIAL.
      PV_PRIND = 'Fix Price'.
      WRITE : LV_PRICE TO PV_SUJUP CURRENCY LV_WAERS
                                   LEFT-JUSTIFIED.
*      CONCATENATE PV_SUJUP LV_WAERS
*             INTO PV_SUJUP SEPARATED BY SPACE.
    ELSEIF LV_AVGPR IS NOT INITIAL.
      PV_PRIND = 'Average Price'.

      CALL FUNCTION 'CONVERSION_EXIT_PERI_OUTPUT'
        EXPORTING
          INPUT  = LV_AVGPR
        IMPORTING
          OUTPUT = PV_SUJUP.
    ELSEIF LV_OFFCH IS NOT INITIAL.
      PV_PRIND = 'Official Price'.

      WRITE : LV_OFFCH TO PV_SUJUP.
    ELSEIF LV_CURPR IS NOT INITIAL.
      PV_PRIND = '시세'.
    ELSE.
      PV_ERROR = 'X'.
    ENDIF.
  ELSE.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " PRICE_CLASSIFICATION1
*&---------------------------------------------------------------------*
*&      Form  GET_SAPID_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SAPID_NAME  USING    PV_UNAME
                              PV_ENAME.

  CLEAR : PV_ENAME.

  CHECK PV_UNAME IS NOT INITIAL.

  SELECT SINGLE NAME_LAST
    INTO PV_ENAME
    FROM USR21 AS A
   INNER JOIN ADRP AS B
      ON A~PERSNUMBER = B~PERSNUMBER
   WHERE A~BNAME      =  PV_UNAME
     AND B~DATE_FROM  <= SY-DATLO
     AND B~DATE_TO    >= SY-DATLO.

ENDFORM.                    " GET_SAPID_NAME
