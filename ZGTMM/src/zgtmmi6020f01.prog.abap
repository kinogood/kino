*&---------------------------------------------------------------------*
*& Include          ZGTMMI6020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT.

  PERFORM GET_IFNO.

  P_IFSYT = GC_KBDM.

  CLEAR : S_IFDAT[].
  S_IFDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

  P_EKORG = GC_1100.
  P_WERKS = GC_1306.

  P_TCDAT = SY-DATLO.
  P_TCTIM = SY-TIMLO.

  PERFORM CALC_TIME USING P_TCDAT P_TCTIM '900' '-'
                 CHANGING P_FCDAT P_FCTIM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_TCDAT
*&      --> P_TCTIM
*&      --> P_
*&      --> P_
*&      <-- P_FCDAT
*&      <-- P_FCTIM
*&---------------------------------------------------------------------*
FORM CALC_TIME USING PV_TCDAT
                     PV_TCTIM
                     PV_DURTN
                     PV_DIRTN
            CHANGING PV_FCDAT
                     PV_FCTIM.

  CALL FUNCTION 'TSTR_CALC_TIME'
    EXPORTING
*     IV_CALENDARID            =
*     IV_TSTREAMID             =
*     IV_HANDLE                =
      IV_BEGIN_DATELOCAL_REQ   = PV_TCDAT
      IV_BEGIN_TIMELOCAL_REQ   = PV_TCTIM
*     IV_BEGIN_TIMESTAMP_REQ   =
*     IV_BEGIN_TIMEZONE        =
*     IV_END_TIMEZONE          =
*     IV_DURATION              =
      IV_DURATION_INTEGER      = PV_DURTN
      IV_DIRECTION             = PV_DIRTN
*     IV_SPLIT_ALLOWED         = 'X'
    IMPORTING
*     EV_BEGIN_DATELOCAL_ACT   =
*     EV_BEGIN_TIMELOCAL_ACT   =
*     EV_BEGIN_TIMESTAMP_ACT   =
      EV_END_DATELOCAL         = PV_FCDAT
      EV_END_TIMELOCAL         = PV_FCTIM
*     EV_END_TIMESTAMP         =
*     ES_SEGMENTS_TOUCHED_FIRST       =
*     ES_SEGMENTS_TOUCHED_LAST =
*     ET_SEGMENTS_TOUCHED      =
    EXCEPTIONS
      FATAL_ERROR              = 1
      TIME_INVALID             = 2
      TIME_MISSING             = 3
      TSTREAM_NOT_LOADABLE     = 4
      TSTREAM_GENERATION_ERROR = 5
      PARAMETER_ERROR          = 6
      UNSPECIFIED_ERROR        = 7
      OTHERS                   = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IFNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IFNO.

  CLEAR : GT_IFNO[].

  SELECT DISTINCT
         FLD_01 AS KEY,
         FLD_02 AS TEXT
    FROM ZGTPPT1010 "ZGTMM_CV_GET_IFLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFNO
   WHERE MODULE_KIND = @GC_PP
     AND CODEGRP     = @GC_0010.

  SORT GT_IFNO BY KEY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  CLEAR : GR_GR1[], GR_SNM[].

  CASE 'X'.
    WHEN P_ILOG.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_SND ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_EKORG )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_WERKS )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_FCDAT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_TCDAT ) ).

  ENDCASE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 IN GR_GR1.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME IN GR_SNM.
      SCREEN-REQUIRED = 2.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME = GC_P_IFSYT.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IFSYT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IFSYT USING PV_ID.

  DATA : LT_IFNO TYPE VRM_VALUES.


  LT_IFNO[] = CORRESPONDING #( GT_IFNO[] ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_IFNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GV_ERR.

  IF P_IFSYT IS INITIAL "당장 의미는 없다만...
  OR ( P_ILOG = GC_X AND S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( P_EKORG IS INITIAL
                        OR P_WERKS IS INITIAL
                        OR P_FCDAT IS INITIAL
                        OR P_TCDAT IS INITIAL ) ).
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    GV_ERR = GC_X. EXIT.
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
FORM GET_DATA.

  CLEAR : GV_CNT.
  CHECK GV_ERR IS INITIAL.

  CLEAR : GT_6020[], GT_6021[], GT_6022[].

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CNT_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CNT_MSG.

  IF GV_CNT IS NOT INITIAL.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_DATA.

  RANGES : LR_STAT FOR ZGTMMT9000-ZSTAT.


  CLEAR : GT_HDR[], GT_ITM[], GT_CMP[].

  IF P_ALL IS INITIAL.
    DATA(LV_STAT) = COND #( WHEN P_SUC = 'X' THEN GC_S
                            WHEN P_ERR = 'X' THEN GC_E ).

    LR_STAT[] = VALUE #( ( SIGN   = GC_I
                           OPTION = GC_EQ
                           LOW    = LV_STAT ) ).
  ENDIF.

  SELECT S~ZIFNO
         S~ZIFKEY
         S~SYSTEM_ID
         S~ZSTAT
         S~MESSAGE
         S~IFDAT
         S~IFTIM
         S~IFNAM
         H~EBELN
         H~BSART
         H~BUKRS
         H~EKORG
         H~EKGRP
         H~EKNAM
         H~BSAKZ
         H~LIFNR
         H~NAME1
         H~RESWK
         H~BEDAT
         H~AEDAT
         H~LASTCHANGEDATETIME
    FROM ZGTMMT9000 AS S INNER JOIN ZGTMMT6020 AS H
      ON S~ZIFKEY = H~ZIFKEY
    INTO CORRESPONDING FIELDS OF TABLE GT_HDR
   WHERE S~ZIFNO     = GC_MM00062
     AND S~ZIFKEY   IN S_IFKEY
     AND S~SYSTEM_ID = P_IFSYT
     AND S~ZSTAT    IN LR_STAT
     AND S~IFDAT    IN S_IFDAT
     AND H~EKGRP    IN S_EKGRP
     AND H~LIFNR    IN S_LIFNR
     AND H~EBELN    IN S_EBELN
     AND H~BEDAT    IN S_BEDAT
     AND H~BSART    IN S_BSART.

  GV_CNT = LINES( GT_HDR[] ).
  PERFORM SET_CNT_MSG.

  SORT GT_HDR BY ZIFKEY DESCENDING
                  EBELN ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_DATA.

  DATA : LV_CNT TYPE I.
  DATA : LV_CNT_D TYPE I.

  CLEAR : GT_DATA[], GT_PO[].

  PERFORM SET_LCDAT.

  SELECT K~EBELN,
         K~BSART,
         K~BUKRS,
         K~EKORG,
         K~EKGRP,
         PG~EKNAM,
         K~BSAKZ,
         K~LIFNR,
         KL~NAME1,
         K~RESWK,
         K~BEDAT,
         K~AEDAT,
         K~LASTCHANGEDATETIME,
         P~EBELP,
         P~LOEKZ,
         P~PSTYP,
         P~KNTTP,
         P~MATNR,
         P~TXZ01,
         P~MTART,
         P~MATKL,
         P~MENGE,
         P~MEINS,
         P~UEBTO,
         P~UNTTO,
         P~WERKS,
         P~LGORT,
         P~BSTAE,
         P~EMLIF,
         PL~NAME1 AS EMLIF_TX,
         P~LBLKZ,
         P~KUNNR,
         PK~NAME1 AS KUNNR_TX,
         P~RETPO,
         P~BEDNR  AS JOB_NO,    "추가(PSJ 25.04.28)
         S~EINDT
    FROM EKKO AS K JOIN EKPO AS P
      ON K~EBELN = P~EBELN
    JOIN EKET AS S
      ON P~EBELN = S~EBELN
     AND P~EBELP = S~EBELP
     AND S~ETENR = @GC_0001
    LEFT JOIN T024 AS PG ON K~EKGRP = PG~EKGRP
    LEFT JOIN LFA1 AS KL ON K~LIFNR = KL~LIFNR AND KL~LOEVM = @SPACE
    LEFT JOIN LFA1 AS PL ON P~EMLIF = PL~LIFNR AND PL~LOEVM = @SPACE
    LEFT JOIN KNA1 AS PK ON P~KUNNR = PK~KUNNR AND PK~LOEVM = @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
   WHERE K~EBELN              IN @S_EBELN
     AND K~BSART              IN @S_BSART
     AND K~LIFNR              IN @S_LIFNR
     AND K~EKORG               = @P_EKORG
     AND K~EKGRP              IN @S_EKGRP
     AND K~BEDAT              IN @S_BEDAT
     AND K~LASTCHANGEDATETIME IN @GR_LCDAT
     AND P~WERKS               = @P_WERKS.

*--> 제조지시정보 없는 내역은 I/F 대상 제외
**** 원자재는 제조지시정보 없기에 체크 대상 X
  LOOP AT GT_DATA.
    IF GT_DATA-MTART <> GC_ROH1 AND GT_DATA-MTART <> GC_ROH2.
      CLEAR : LV_CNT, LV_CNT_D.
      SELECT COUNT(*)
        INTO LV_CNT
        FROM ZGTMMT6000
       WHERE EBELN = GT_DATA-EBELN
         AND EBELP = GT_DATA-EBELP.

      SELECT COUNT(*)
        INTO LV_CNT_D
        FROM ZGTMMT6000D
       WHERE EBELN = GT_DATA-EBELN
         AND EBELP = GT_DATA-EBELP.

      IF LV_CNT = 0 AND LV_CNT_D = 0.
        DELETE GT_DATA.
      ENDIF.
    ENDIF.
  ENDLOOP.
*<-- 제조지시정보 없는 내역은 I/F 대상 제외

  PERFORM EXCEPT_SEND_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S075 DISPLAY LIKE 'E'. "전송할 데이터가 없습니다.
    EXIT.
  ENDIF.

  SORT GT_DATA BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM GT_DATA COMPARING EBELN EBELP.

  GT_PO[] = CORRESPONDING #( GT_DATA[] ).

  PERFORM GET_6000.
  PERFORM GET_EKKN.

  PERFORM GET_SEND_HDR.
  PERFORM GET_SEND_ITM.
  PERFORM GET_SEND_CMP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LCDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LCDAT.

  DATA : LV_FSTMP TYPE CHANGEDATETIME,
         LV_TSTMP TYPE CHANGEDATETIME.


  CLEAR : GR_LCDAT[].

  PERFORM CONVERT_TSTAMP USING P_FCDAT
                               P_FCTIM
                      CHANGING LV_FSTMP.

  PERFORM CONVERT_TSTAMP USING P_TCDAT
                               P_TCTIM
                      CHANGING LV_TSTMP.

  GR_LCDAT[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_BT
                          LOW    = LV_FSTMP
                          HIGH   = LV_TSTMP ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_TSTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FCDAT
*&      --> P_FCTIM
*&      <-- LV_FSTMP
*&---------------------------------------------------------------------*
FORM CONVERT_TSTAMP USING PV_DATE
                          PV_TIME
                 CHANGING PV_STMP.

  CLEAR : PV_STMP.
  CHECK PV_DATE IS NOT INITIAL.

  CONVERT DATE PV_DATE TIME PV_TIME
     INTO TIME STAMP PV_STMP TIME ZONE SY-ZONLO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA.

  DATA : BEGIN OF LS_PO,
           EBELN              LIKE EKKO-EBELN,
           LASTCHANGEDATETIME LIKE EKKO-LASTCHANGEDATETIME,
         END   OF LS_PO.

  DATA : LT_PO LIKE SORTED TABLE OF LS_PO
               WITH UNIQUE KEY EBELN LASTCHANGEDATETIME.


  CLEAR : GR_EBELN[].

  CHECK GT_DATA[] IS NOT INITIAL.

  LT_PO[] = CORRESPONDING #( GT_DATA[] DISCARDING DUPLICATES ).

  SELECT DISTINCT H~EBELN AS LOW
    FROM ZGTMMT9000 AS C
         INNER JOIN ZGTMMT6020 AS H
          ON C~ZIFKEY = H~ZIFKEY
    INTO CORRESPONDING FIELDS OF TABLE @GR_EBELN
     FOR ALL ENTRIES IN @LT_PO
   WHERE C~ZIFNO              = @GC_MM00062
     AND C~SYSTEM_ID          = @P_IFSYT
     AND C~ZSTAT              = @GC_S
     AND H~EBELN              = @LT_PO-EBELN
     AND H~LASTCHANGEDATETIME = @LT_PO-LASTCHANGEDATETIME.

  CHECK GR_EBELN[] IS NOT INITIAL.
  GR_EBELN-SIGN   = GC_I.
  GR_EBELN-OPTION = GC_EQ.
  MODIFY GR_EBELN TRANSPORTING SIGN OPTION
                         WHERE SIGN IS INITIAL.

  IF S_EBELN[] IS INITIAL.
    DELETE GT_DATA WHERE EBELN IN GR_EBELN.
  ELSE.
    "강제전송시 지워지지 않도록
    DELETE GT_DATA WHERE EBELN IN GR_EBELN AND EBELN NOT IN S_EBELN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_6000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_6000.

  CLEAR : GT_6000[].
  CHECK GT_PO[] IS NOT INITIAL.

  SELECT EBELN
         EBELP
         JOB_NO
         LINE_NO
         SERIAL_INFO AS SERIAL_NO
    FROM ZGTMMT6000
    INTO CORRESPONDING FIELDS OF TABLE GT_6000
     FOR ALL ENTRIES IN GT_PO
   WHERE EBELN = GT_PO-EBELN
     AND EBELP = GT_PO-EBELP.

  SORT GT_6000 BY EBELN EBELP.

*--> [CHM2509-00580] 부스덕트 PO I/F 수정
**** 삭제이력은 ZGTMMT6000에 없어서 ZGTMMT6000D 추가 확인
  SELECT EBELN
         EBELP
         JOB_NO
         LINE_NO
         SERIAL_INFO AS SERIAL_NO
    FROM ZGTMMT6000D
    INTO CORRESPONDING FIELDS OF TABLE GT_6000D
     FOR ALL ENTRIES IN GT_PO
   WHERE EBELN = GT_PO-EBELN
     AND EBELP = GT_PO-EBELP.

  SORT GT_6000D BY EBELN EBELP.
*<-- [CHM2509-00580] 부스덕트 PO I/F 수정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EKKN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EKKN.

  CLEAR : GT_EKKN[], GT_AFVC[], GT_PRXX[].

  CHECK GT_PO[] IS NOT INITIAL.

  SELECT EBELN
         EBELP
         VBELN
         VBELP
         AUFNR
         AUFPL
         APLZL
         PS_PSP_PNR
         ABLAD
    FROM EKKN
    INTO CORRESPONDING FIELDS OF TABLE GT_EKKN
     FOR ALL ENTRIES IN GT_PO
   WHERE EBELN = GT_PO-EBELN
     AND EBELP = GT_PO-EBELP
     AND ZEKKN = GC_01.
*    AND LOEKZ = SPACE.

  CHECK GT_EKKN[] IS NOT INITIAL.
  SORT GT_EKKN BY EBELN EBELP.

  PERFORM GET_AFVC.
  PERFORM GET_PRXX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_AFVC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_AFVC.

  CHECK GT_EKKN[] IS NOT INITIAL.

  GT_AFVC[] = CORRESPONDING #( GT_EKKN[] ).
  DELETE GT_AFVC WHERE AUFNR IS INITIAL.

  CHECK GT_AFVC[] IS NOT INITIAL.

  SORT GT_AFVC BY AUFPL APLZL.
  DELETE ADJACENT DUPLICATES FROM GT_AFVC COMPARING AUFPL APLZL.

  SELECT AUFPL
         APLZL
         VORNR
    FROM AFVC
    INTO CORRESPONDING FIELDS OF TABLE GT_AFVC
     FOR ALL ENTRIES IN GT_AFVC
   WHERE AUFPL = GT_AFVC-AUFPL
     AND APLZL = GT_AFVC-APLZL.
*    AND LOEKZ = SPACE.

  SORT GT_AFVC BY AUFPL APLZL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PRXX.

  CHECK GT_EKKN[] IS NOT INITIAL.

  GT_PRXX[] = CORRESPONDING #( GT_EKKN[] ).
  DELETE GT_PRXX WHERE PS_PSP_PNR IS INITIAL.

  CHECK GT_PRXX[] IS NOT INITIAL.

  SORT GT_PRXX BY PS_PSP_PNR.
  DELETE ADJACENT DUPLICATES FROM GT_PRXX COMPARING PS_PSP_PNR.

  SELECT S~PSPNR
         S~POSID
         J~PSPID
    FROM PRPS AS S LEFT JOIN PROJ AS J
      ON S~PSPHI = J~PSPNR
    INTO CORRESPONDING FIELDS OF TABLE GT_PRXX
     FOR ALL ENTRIES IN GT_PRXX
   WHERE S~PSPNR = GT_PRXX-PS_PSP_PNR.
*    AND S~LOEVM = SPACE AND J~LOEVM = SPACE.

  SORT GT_PRXX BY PSPNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_HDR.

  CLEAR : GT_6020[].
  GT_6020[] = CORRESPONDING #( GT_DATA[] ).

  SORT GT_6020 BY EBELN.
  DELETE ADJACENT DUPLICATES FROM GT_6020 COMPARING EBELN.

  GV_CNT = LINES( GT_6020[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_ITM.

  CLEAR : GT_6021[].

  LOOP AT GT_DATA.
    CLEAR : GT_6021.
    GT_6021 = CORRESPONDING #( GT_DATA ).

    PERFORM SET_6000.
    PERFORM SET_T001L.
    PERFORM SET_EKKN.

    APPEND GT_6021.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_6000.

  "JOB_NO 추출 기준 변경(PSJ 25.04.28)
  " ROH1/ROH2 : EKPO-BEDNR
  " 그 외 : ZGTMMT6000-JOB_NO

  CHECK GT_6021-MTART <> GC_ROH1 AND GT_6021-MTART <> GC_ROH2.
  CLEAR : GT_6021-JOB_NO.

  READ TABLE GT_6000 WITH KEY EBELN = GT_6021-EBELN
                              EBELP = GT_6021-EBELP
                              BINARY SEARCH.

*--> [CHM2509-00580] 부스덕트 PO I/F 수정
**** 원본 BK - START
*  CHECK SY-SUBRC = 0.
*
*  GT_6021-JOB_NO    = GT_6000-JOB_NO.
*  GT_6021-LINE_NO   = GT_6000-LINE_NO.
*  GT_6021-SERIAL_NO = GT_6000-SERIAL_NO.
**** 원본 BK - END

  IF SY-SUBRC = 0.
    GT_6021-JOB_NO    = GT_6000-JOB_NO.
    GT_6021-LINE_NO   = GT_6000-LINE_NO.
    GT_6021-SERIAL_NO = GT_6000-SERIAL_NO.
  ELSE. "--> 삭제이력은 GT_6000D에 있어서 추가 확인
    READ TABLE GT_6000D WITH KEY EBELN = GT_6021-EBELN
                                 EBELP = GT_6021-EBELP
                                 BINARY SEARCH.
    GT_6021-JOB_NO    = GT_6000D-JOB_NO.
    GT_6021-LINE_NO   = GT_6000D-LINE_NO.
    GT_6021-SERIAL_NO = GT_6000D-SERIAL_NO.
  ENDIF.
*<-- [CHM2509-00580] 부스덕트 PO I/F 수정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_T001L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_T001L.

  CHECK GT_6021-WERKS IS NOT INITIAL
    AND GT_6021-LGORT IS NOT INITIAL.

  SELECT SINGLE LGOBE FROM T001L
    INTO GT_6021-LGOBE
   WHERE WERKS = GT_6021-WERKS
     AND LGORT = GT_6021-LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EKKN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EKKN.

  READ TABLE GT_EKKN WITH KEY EBELN = GT_6021-EBELN
                              EBELP = GT_6021-EBELP
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_6021-VBELN = GT_EKKN-VBELN.
  GT_6021-VBELP = GT_EKKN-VBELP.
  GT_6021-AUFNR = GT_EKKN-AUFNR.
  GT_6021-ABLAD = GT_EKKN-ABLAD.

  PERFORM SET_AFVC.
  PERFORM SET_PRXX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AFVC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AFVC.

  CHECK GT_EKKN-AUFNR IS NOT INITIAL.

  READ TABLE GT_AFVC WITH KEY AUFPL = GT_EKKN-AUFPL
                              APLZL = GT_EKKN-APLZL
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_6021-VORNR = GT_AFVC-VORNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PRXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PRXX.

  CHECK GT_EKKN-PS_PSP_PNR IS NOT INITIAL.

  READ TABLE GT_PRXX WITH KEY PSPNR = GT_EKKN-PS_PSP_PNR
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_6021-POSID = GT_PRXX-POSID.
  GT_6021-PSPID = GT_PRXX-PSPID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_CMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_CMP.

  CLEAR : GT_6022[].
  CHECK GT_PO[] IS NOT INITIAL.

  SELECT R~EBELN
         R~EBELP
         R~MATNR
         T~MAKTX
         R~WERKS
         R~LGORT
         L~LGOBE
         R~BDTER
         R~BDMNG
         R~MEINS
    FROM RESB AS R
    LEFT JOIN MAKT  AS T ON R~MATNR = T~MATNR AND T~SPRAS = SY-LANGU
    LEFT JOIN T001L AS L ON R~WERKS = L~WERKS AND R~LGORT = L~LGORT
    INTO CORRESPONDING FIELDS OF TABLE GT_6022
     FOR ALL ENTRIES IN GT_PO
   WHERE EBELN = GT_PO-EBELN
     AND EBELP = GT_PO-EBELP.
*    AND XLOEK = SPACE.

  SORT GT_6022 BY EBELN EBELP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_RSPLT = NEW #( PARENT  = GR_DOCK
                    ROWS    = 2
                    COLUMNS = 1 ).

  "#1 Row
  GR_HCNTR = GR_RSPLT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_RSPLT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 35 ).

  "#2 Row - Left
  GR_ICNTR = GR_RSPLT->GET_CONTAINER( ROW    = 2
                                      COLUMN = 1 ).

  GR_CSPLT = NEW #( PARENT  = GR_ICNTR
                    ROWS    = 1
                    COLUMNS = 2 ).

  GR_ICNTR = GR_CSPLT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
                   I_APPL_EVENTS = GC_X ).

  "#2 Row - Right
  GR_CCNTR = GR_CSPLT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 2 ).

  GR_CGRID = NEW #( I_PARENT      = GR_CCNTR
                    I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO
                    PV_TYPE.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '헤더'(T01).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '아이템'(T02).

    WHEN 'C'.
      PS_LAYO-GRID_TITLE = '구성품'(T03).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> GT_HDR
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_DATA
               USING PV_NAME
                     PV_TYPE.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_NAME
*     I_STRUCTURE_NAME   = CONV TABNAME( PV_NAME )
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = PT_DATA
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT PT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE PV_NAME.
      WHEN 'GT_HDR'.
        PERFORM SET_HDR_FCAT.
      WHEN 'GT_ITM'.
        PERFORM SET_ITM_FCAT.
      WHEN 'GT_CMP'.
        PERFORM SET_CMP_FCAT.
    ENDCASE.

    MODIFY PT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FTXT USING PV_TEXT.

  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HDR_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HDR_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'ZIFNO'.
      PERFORM SET_FTXT USING 'I/F No'(F01).
      GS_FCAT-KEY = GC_X.
    WHEN 'ZIFKEY'.
      PERFORM SET_FTXT USING 'Interface Key'(F02).
      GS_FCAT-KEY = GC_X.
    WHEN 'SYSTEM_ID'.
      PERFORM SET_FTXT USING 'I/F 시스템'(F03).
      GS_FCAT-KEY = GC_X.
    WHEN 'ZSTAT'.
      PERFORM SET_FTXT USING '상태'(F04).
      GS_FCAT-KEY = GC_X.
    WHEN 'MESSAGE'.
      PERFORM SET_FTXT USING '메시지'(F05).
      GS_FCAT-KEY = GC_X.
    WHEN 'IFDAT'.
      PERFORM SET_FTXT USING 'I/F 일자'(F06).
      GS_FCAT-KEY = GC_X.
    WHEN 'IFTIM'.
      PERFORM SET_FTXT USING 'I/F 시간'(F07).
      GS_FCAT-KEY = GC_X.
    WHEN 'IFNAM'.
      PERFORM SET_FTXT USING '송수신자'(F08).
      GS_FCAT-KEY = GC_X.
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더'(F09).
      GS_FCAT-KEY = GC_X.
    WHEN 'BSART'.
      PERFORM SET_FTXT USING '유형'(F10).
    WHEN 'BUKRS'.
      PERFORM SET_FTXT USING 'CoCd'(F11).
    WHEN 'EKORG'.
      PERFORM SET_FTXT USING 'POrg'(F12).
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING 'PGrp'(F13).
    WHEN 'EKNAM'.
      PERFORM SET_FTXT USING '구매그룹'(F14).
    WHEN 'BSAKZ'.
      PERFORM SET_FTXT USING 'Ctl'(F15).
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F16).
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '공급업체명'(F17).
    WHEN 'RESWK'.
      PERFORM SET_FTXT USING '출고플랜트'(F18).
    WHEN 'BEDAT'.
      PERFORM SET_FTXT USING '증빙일'(F19).
    WHEN 'AEDAT'.
      PERFORM SET_FTXT USING '생성일'(F20).
    WHEN 'LASTCHANGEDATETIME'.
      PERFORM SET_FTXT USING '최종 변경일시'(F21).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITM_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITM_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'ZIFKEY'.
      PERFORM SET_FTXT USING 'Interface Key'(F02).
      GS_FCAT-KEY = GC_X.
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더'(F09).
      GS_FCAT-KEY = GC_X.
    WHEN 'EBELP'.
      PERFORM SET_FTXT USING '품목'(F22).
      GS_FCAT-KEY = GC_X.
    WHEN 'LOEKZ'.
      PERFORM SET_FTXT USING 'D'(F23).
    WHEN 'PSTYP'.
      PERFORM SET_FTXT USING 'I'(F24).
    WHEN 'KNTTP'.
      PERFORM SET_FTXT USING 'A'(F25).
    WHEN 'JOB_NO'.
      PERFORM SET_FTXT USING '제조지시번호'(F26).
    WHEN 'LINE_NO'.
      PERFORM SET_FTXT USING '라인번호'(F27).
    WHEN 'SERIAL_NO'.
      PERFORM SET_FTXT USING '시리얼'(F28).
    WHEN 'EINDT'.
      PERFORM SET_FTXT USING '납품일'(F29).
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재번호'(F30).
    WHEN 'TXZ01'.
      PERFORM SET_FTXT USING '자재 내역'(F31).
    WHEN 'MTART'.
      PERFORM SET_FTXT USING '자재유형'(F32).
    WHEN 'MATKL'.
      PERFORM SET_FTXT USING '자재그룹'(F33).
    WHEN 'MENGE'.
      PERFORM SET_FTXT USING 'PO 수량'(F34).
*     GS_FCAT-QFIELDNAME = GC_MEINS.
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING 'OUn'(F35).
    WHEN 'UEBTO'.
      PERFORM SET_FTXT USING '초과한도%'(F36).
    WHEN 'UNTTO'.
      PERFORM SET_FTXT USING '미달한도%'(F37).
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F38).
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F39).
    WHEN 'LGOBE'.
      PERFORM SET_FTXT USING '저장위치 내역'(F40).
    WHEN 'BSTAE'.
      PERFORM SET_FTXT USING '확인관리'(F41).
    WHEN 'EMLIF'.
      PERFORM SET_FTXT USING '공급업체'(F42).
    WHEN 'EMLIF_TX'.
      PERFORM SET_FTXT USING '공급업체 이름'(F43).
    WHEN 'LBLKZ'.
      PERFORM SET_FTXT USING 'SC'(F44).
      GS_FCAT-CHECKBOX = GC_X.
    WHEN 'KUNNR'.
      PERFORM SET_FTXT USING '고객'(F45).
    WHEN 'KUNNR_TX'.
      PERFORM SET_FTXT USING '고객 이름'(F46).
    WHEN 'VBELN'.
      PERFORM SET_FTXT USING '판매오더'(F47).
    WHEN 'VBELP'.
      PERFORM SET_FTXT USING '항목'(F48).
    WHEN 'AUFNR'.
      PERFORM SET_FTXT USING '생산오더'(F49).
    WHEN 'VORNR'.
      PERFORM SET_FTXT USING '작업번호'(F50).
    WHEN 'POSID'.
      PERFORM SET_FTXT USING 'WBS'(F51).
    WHEN 'PSPID'.
      PERFORM SET_FTXT USING '프로젝트'(F52).
    WHEN 'ABLAD'.
      PERFORM SET_FTXT USING '하적지점'(F53).
    WHEN 'RETPO'.
      PERFORM SET_FTXT USING '반품'(F54).
      GS_FCAT-CHECKBOX = GC_X.

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CMP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CMP_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'ZIFKEY'.
      PERFORM SET_FTXT USING 'Interface Key'(F02).
      GS_FCAT-KEY = GC_X.
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더'(F09).
      GS_FCAT-KEY = GC_X.
    WHEN 'EBELP'.
      PERFORM SET_FTXT USING '품목'(F22).
      GS_FCAT-KEY = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재번호'(F30).
      GS_FCAT-KEY = GC_X.
    WHEN 'MAKTX'.
      PERFORM SET_FTXT USING '자재 내역'(F31).
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F38).
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F39).
    WHEN 'LGOBE'.
      PERFORM SET_FTXT USING '저장위치 내역'(F40).
    WHEN 'BDTER'.
      PERFORM SET_FTXT USING '소요일'(F55).
    WHEN 'BDMNG'.
      PERFORM SET_FTXT USING '소요량'(F56).
*     GS_FCAT-QFIELDNAME = GC_MEINS.
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F57).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK FOR PR_GRID.

    WHEN 'GR_IGRID'.
      SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK FOR PR_GRID.

    WHEN 'GR_CGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> GT_HDR
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO
                     PV_TYPE.

  CLEAR : GS_VARI.
  CASE PV_TYPE.
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.

  ENDCASE.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PS_LAYO TYPE LVC_S_LAYO.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = PS_LAYO.

  CALL METHOD PR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GR_HGRID->FREE.
      CALL METHOD GR_IGRID->FREE.
      CALL METHOD GR_CGRID->FREE.
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_CCNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_CGRID,
              GR_HCNTR, GR_ICNTR, GR_CCNTR, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PS_ROW  TYPE LVC_S_ROW
                               PS_COL  TYPE LVC_S_COL
                               PS_ROID TYPE LVC_S_ROID
                               PV_OTEXT.

  CLEAR : GT_LKEY[].

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      READ TABLE GT_HDR INDEX PS_ROW-INDEX.
      CHECK SY-SUBRC = 0.

      GT_LKEY = CORRESPONDING #( GT_HDR ).
      APPEND GT_LKEY.

      PERFORM GET_ILOG_ITM TABLES GT_ITM USING ' '.
      PERFORM REFRESH_GRID USING GR_IGRID
                                 GS_ILAYO.

      CLEAR : GT_CMP[].
      PERFORM REFRESH_GRID USING GR_CGRID
                                 GS_CLAYO.

    WHEN 'GR_IGRID'.
      READ TABLE GT_ITM INDEX PS_ROW-INDEX.
      CHECK SY-SUBRC = 0.

      GT_LKEY = CORRESPONDING #( GT_ITM ).
      APPEND GT_LKEY.

      PERFORM GET_ILOG_CMP TABLES GT_CMP USING ' '.
      PERFORM REFRESH_GRID USING GR_CGRID
                                 GS_CLAYO.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_DATA USING PV_CHK.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE ZO_RESULT,
         LV_MSG  TYPE ZO_MESSAGE,
         LV_RET  TYPE ZIFE_IFRET.


  CLEAR : GT_F063[], GT_F064[], GT_F065[].
  CLEAR : GV_CNT,    GV_MSG.

  IF PV_CHK = GC_X.
    PERFORM SEND_SEL_DATA.
    CHECK GV_ERR IS INITIAL.
  ENDIF.

  IF ( PV_CHK = GC_X AND GV_ERR IS INITIAL )
  OR ( PV_CHK = ' '  AND SY-BATCH <> GC_X ).
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '데이터를 전송 하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ENDIF.

  GV_CNT = LINES( GT_6020[] ).

  PERFORM MODIFY_F06X_DATA.

  "2025.10.02 BMES 통합 IS전환
  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
*     GUBUN                 = 'MM'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_BDMES_PO_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_HTAB     = GT_F063[]
      OT_ITAB     = GT_F064[]
      OT_STAB     = GT_F065[]
    EXCEPTIONS
      OTHERS      = 1.

  "모든 경우 Log 남기기(박상진E 24.12.23)
  IF SY-SUBRC <> 0.
    LV_RET = GC_E.
    MESSAGE E076 INTO GV_MSG. "전송을 위한 EAI 함수를 호출할 수 없습니다.
*   MESSAGE S076 DISPLAY LIKE 'E'.
*   EXIT.
  ELSE.
    CASE LV_RST.
      WHEN '00'.
        LV_RET = GC_S.
        GV_MSG = GV_CNT && '건 전송 성공'(M01).
      WHEN OTHERS.
        LV_RET = GC_E.
        GV_MSG = GV_CNT && '건 전송 실패'(M02).
    ENDCASE.
  ENDIF.

  PERFORM SAVE_LOG USING LV_RET
                         GV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        IF PV_MSG IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ELSE.
          MESSAGE S050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
        ENDIF.
      ENDIF.
    WHEN 1.
      IF PV_MODE = GC_S.
        READ TABLE GT_ROW INTO GS_ROW INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM USING PV_TITLE
                            PV_QTEXT.

  CLEAR : GV_ANS. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      TITLEBAR      = PV_TITLE
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION = PV_QTEXT
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER        = GV_ANS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SEL_DATA.

  CLEAR : GT_6020[], GT_6021[], GT_6022[].

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '재전송할 대상을 선택하세요.'(M03).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HDR INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    GT_6020 = CORRESPONDING #( GT_HDR ).
    GT_LKEY = CORRESPONDING #( GT_HDR ).
    APPEND : GT_6020, GT_LKEY.
  ENDLOOP.

* SORT GT_6020 BY ZIFKEY DESCENDING EBELN ASCENDING.

  SORT GT_LKEY BY ZIFKEY EBELN.
  DELETE ADJACENT DUPLICATES FROM GT_LKEY COMPARING ZIFKEY EBELN.

  PERFORM GET_ILOG_ITM TABLES GT_6021 USING 'X'.
  PERFORM GET_ILOG_CMP TABLES GT_6022 USING 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_6021
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_ILOG_ITM TABLES PT_ITM STRUCTURE ZGTMMT6021
                   USING PV_CHK.

  CLEAR : PT_ITM[], GV_CNT.
  CHECK GT_LKEY[] IS NOT INITIAL.

  DATA(LT_LKEY) = GT_LKEY[].

  SELECT I~*,
         @SPACE AS MANDT,
         CAST( '00000000' AS DATS ) AS ERDAT,
         CAST( '00000000' AS DATS ) AS ERDAT_LOCAL,
         CAST( '000000'   AS TIMS ) AS ERTIM,
         CAST( '000000'   AS TIMS ) AS ERTIM_LOCAL,
         @SPACE AS ERNAM
    FROM ZGTMMT6021 AS I JOIN @LT_LKEY AS K
      ON I~ZIFKEY = K~ZIFKEY
     AND I~EBELN  = K~EBELN
    INTO CORRESPONDING FIELDS OF TABLE @PT_ITM.

  SORT PT_ITM BY ZIFKEY EBELN EBELP.

  IF PV_CHK IS INITIAL.
    GV_CNT = LINES( PT_ITM[] ).
    PERFORM SET_CNT_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_CMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_6022
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_ILOG_CMP TABLES PT_CMP STRUCTURE ZGTMMT6022
                   USING PV_CHK.

  DATA : LV_COND TYPE STRING.


  CLEAR : PT_CMP[], GV_CNT.
  CHECK GT_LKEY[] IS NOT INITIAL.

  LV_COND = | ZIFKEY = GT_LKEY-ZIFKEY AND EBELN = GT_LKEY-EBELN |.

  IF PV_CHK IS INITIAL.
    LV_COND = LV_COND && | AND EBELP = GT_LKEY-EBELP |.
  ENDIF.

  SELECT ZIFKEY
         EBELN
         EBELP
         MATNR
         MAKTX
         WERKS
         LGORT
         LGOBE
         BDTER
         BDMNG
         MEINS
    FROM ZGTMMT6022
    INTO CORRESPONDING FIELDS OF TABLE PT_CMP
     FOR ALL ENTRIES IN GT_LKEY
   WHERE (LV_COND).

  SORT PT_CMP BY ZIFKEY EBELN EBELP MATNR.

  IF PV_CHK IS INITIAL.
    GV_CNT = LINES( PT_CMP[] ).
    PERFORM SET_CNT_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F003_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F06X_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F06X_DATA.

  GET TIME STAMP FIELD GV_ZIFKEY.

  GT_F063[] = VALUE #( FOR LS_HDR IN GT_6020
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  ZIFKEY = GV_ZIFKEY
                                  EBELN  = |{ LS_HDR-EBELN ALPHA = OUT }|
                                  LIFNR  = |{ LS_HDR-LIFNR ALPHA = OUT }| ) ) ).

  LOOP AT GT_6021.
    GT_F064 = CORRESPONDING #( GT_6021 ).

    GT_F064-ZIFKEY = GV_ZIFKEY.
    GT_F064-EBELN  = |{ GT_F064-EBELN ALPHA = OUT }|.
    GT_F064-EMLIF  = |{ GT_F064-EMLIF ALPHA = OUT }|.
    GT_F064-KUNNR  = |{ GT_F064-KUNNR ALPHA = OUT }|.
    GT_F064-VBELN  = |{ GT_F064-VBELN ALPHA = OUT }|.
    GT_F064-AUFNR  = |{ GT_F064-AUFNR ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F064-MATNR.

    SHIFT GT_F064-EBELP LEFT DELETING LEADING '0'.
    SHIFT GT_F064-VBELP LEFT DELETING LEADING '0'.

    APPEND GT_F064.
  ENDLOOP.

  LOOP AT GT_6022.
    GT_F065 = CORRESPONDING #( GT_6022 ).

    GT_F065-ZIFKEY = GV_ZIFKEY.
    GT_F065-EBELN  = |{ GT_F065-EBELN ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F065-MATNR.

    SHIFT GT_F065-EBELP LEFT DELETING LEADING '0'.

    APPEND GT_F065.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CLEAR : GS_9000, GT_6020, GT_6021, GT_6022.

  PERFORM SET_TSTMP.

* GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFKEY    = GV_ZIFKEY.
  GS_9000-ZIFNO     = GC_MM00062.
  GS_9000-SYSTEM_ID = P_IFSYT.
  GS_9000-ZSTAT     = PV_RET.
  GS_9000-MESSAGE   = PV_MSG.
  GS_9000-IFDAT     = SY-DATLO.
  GS_9000-IFTIM     = SY-TIMLO.
  GS_9000-IFNAM     = SY-UNAME.
  MOVE-CORRESPONDING GS_CREA TO GS_9000.

  PERFORM SET_LOG TABLES GT_6020.
  PERFORM SET_LOG TABLES GT_6021.
  PERFORM SET_LOG TABLES GT_6022.

  CHECK GT_6020[] IS NOT INITIAL.

  MODIFY ZGTMMT6022 FROM TABLE GT_6022.
  MODIFY ZGTMMT6021 FROM TABLE GT_6021.
  MODIFY ZGTMMT6020 FROM TABLE GT_6020.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TSTMP.

  CLEAR : GS_CREA.

  GS_CREA-ERDAT       = SY-DATUM.
  GS_CREA-ERDAT_LOCAL = SY-DATLO.
  GS_CREA-ERTIM       = SY-UZEIT.
  GS_CREA-ERTIM_LOCAL = SY-TIMLO.
  GS_CREA-ERNAM       = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_6020
*&---------------------------------------------------------------------*
FORM SET_LOG TABLES PT_602X.

  DATA : LV_COND TYPE STRING.


  CHECK PT_602X[] IS NOT INITIAL.

  ASSIGN COMPONENT 'ZIFKEY' OF STRUCTURE PT_602X TO FIELD-SYMBOL(<LFS_ZIFKEY>).

  <LFS_ZIFKEY> = GS_9000-ZIFKEY.
  MOVE-CORRESPONDING GS_CREA TO PT_602X.

  LV_COND = | MANDT IS INITIAL |.

  MODIFY PT_602X TRANSPORTING ('ZIFKEY')
                              ('ERDAT')
                              ('ERDAT_LOCAL')
                              ('ERTIM')
                              ('ERTIM_LOCAL')
                              ('ERNAM')
                        WHERE (LV_COND).

ENDFORM.
