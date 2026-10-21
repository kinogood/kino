*&---------------------------------------------------------------------*
*& Include          ZGTMMR4913F01
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

  CLEAR : S_IFDAT[], S_ERDAT[].
  S_IFDAT[] = S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                                     OPTION = GC_BT
                                     LOW    = SY-DATLO - 1
                                     HIGH   = SY-DATLO ) ).

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

  SELECT DISTINCT FLD_01 AS KEY,
                  FLD_02 AS TEXT
    FROM ZGTPPT1010
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

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_BUKRS )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_EKORG-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_WERKS-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_ERDAT-LOW ) ).

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

  IF ( P_ILOG = GC_X AND   S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( S_EKORG[] IS INITIAL
                        OR S_WERKS[] IS INITIAL
                        OR S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL
                        OR P_BUKRS   IS INITIAL ) ).
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

  PERFORM GET_MST_INFO USING 'MM00004'.

  PERFORM MAKE_ITAB.
  CLEAR : <GT_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

  GV_CNT = LINES( <GT_LIST> ).
  IF GV_CNT IS NOT INITIAL.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MST_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_MST_INFO USING PV_ID.

  CLEAR : GS_MST.

  SELECT SINGLE FLD_03,
                FLD_04,
                FLD_05
    FROM ZGTMM_CV_GET_IFLIST
    INTO @GS_MST
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0010
     AND FLD_01      = @PV_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB.

  DATA : LR_DATA  TYPE REF TO DATA.


  CLEAR    : GV_TNAME.
  UNASSIGN : <GT_LIST>, <GS_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_TNAME = GS_MST-VIEW. "ZGTMM_CV_CU_IF_LOG_L
    WHEN P_SEND.
      GV_TNAME = GC_ZGTMM_CV_CHANGEDCU.
  ENDCASE.

  DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                       CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( GV_TNAME ) ).

  CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
  ASSIGN LR_DATA->* TO  <GS_LIST>.
  FREE : LR_DATA.

  CREATE DATA LR_DATA LIKE STANDARD TABLE OF <GS_LIST>.
  ASSIGN LR_DATA->* TO <GT_LIST>.
  FREE : LR_DATA.

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

  DATA : LV_COND TYPE STRING.


  LV_COND = | IFDAT IN @S_IFDAT AND ICCNO IN @S_ICCNO |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_BUKRS IS NOT INITIAL. "필수가 아니므로..
    LV_COND = LV_COND && | AND BUKRS = @P_BUKRS |.
  ENDIF.

  IF P_FNL IS NOT INITIAL.
    LV_COND = LV_COND && | AND LASTDATA = @GC_X |.
  ENDIF.

  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
  ENDIF.

  SELECT *
    FROM (GV_TNAME)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>
   WHERE (LV_COND).

  CHECK <GT_LIST> IS NOT INITIAL.
  SORT <GT_LIST> BY ('ZIFKEY') DESCENDING ('ICCNO') ASCENDING.

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

  DATA : LR_DUP TYPE RANGE OF CHAR1.


  CLEAR : GT_CCHG[].

  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    LR_DUP[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_EQ
                          LOW    = SPACE ) ).
  ENDIF.

  SELECT *
    FROM ZGTMM_CV_CHANGEDCU( P_STARTDATE = @S_ERDAT-LOW,
                             P_ENDDATE   = @S_ERDAT-HIGH )
   WHERE BUKRS  = @P_BUKRS
     AND EKORG IN @S_EKORG
     AND WERKS IN @S_WERKS
     AND ICCNO IN @S_ICCNO
     AND DUP   IN @LR_DUP
    INTO CORRESPONDING FIELDS OF TABLE @GT_CCHG.

*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영
**** 삭제내역 전송 추가
  IF P_IFSYT = 'KSCM'.
    "--> 삭제된 통관 관리번호 추출
    CLEAR : GT_DEL, GT_DEL[].
    SELECT DISTINCT
           LEFT( B~OBJECTID,10 ) AS ICCNO,
           CAST( RIGHT( B~OBJECTID,2 ) AS NUMC ) AS ICCSQ,
           CAST( RIGHT( B~TABKEY,5 ) AS NUMC ) AS ICCIT,
           A~CHANGENR,
           A~USERNAME,
           A~UDATE,
           A~UTIME
      FROM CDHDR AS A
           INNER JOIN CDPOS AS B
            ON A~OBJECTCLAS = B~OBJECTCLAS
            AND A~OBJECTID = B~OBJECTID
            AND A~CHANGENR = B~CHANGENR
     WHERE A~OBJECTCLAS = 'ZTICRCHDOC'
       AND A~TCODE IN ('ZTIT434')
       AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH
       AND B~CHNGIND = 'D'
       AND B~TABNAME = 'ZTITCRP'
       AND LEFT( B~OBJECTID,10 ) IN @S_ICCNO
      INTO CORRESPONDING FIELDS OF TABLE @GT_DEL.

    SORT GT_DEL BY ICCNO ICCSQ ICCIT.

    "--> P_FRC : I/F 성공 데이터 포함
    " INITIAL : 기성공 전송내역 있을 시 삭제
    IF P_FRC IS INITIAL.
      CLEAR : GS_DEL.
      LOOP AT GT_DEL INTO GS_DEL.
        SELECT COUNT(*)
          FROM ZGTMMT9040 AS A
               INNER JOIN ZGTMMT9000 AS B
                ON A~ZIFKEY = B~ZIFKEY
                AND B~ZIFNO = 'MM00004'
                AND B~SYSTEM_ID = P_IFSYT
         WHERE A~ICCNO = GS_DEL-ICCNO
           AND A~ICCSQ = GS_DEL-ICCSQ
           AND A~ICCIT = GS_DEL-ICCIT
           AND A~ZFLAG = 'D'
           AND B~ZSTAT = 'S'.

        IF SY-DBCNT > 0.
          DELETE GT_DEL INDEX SY-TABIX.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "--> I/F 데이터 추출
    CLEAR : GS_DEL.
    LOOP AT GT_DEL INTO GS_DEL.
      CLEAR : GS_CCHG.
      SELECT SINGLE A~*, B~WERKS, C~LIFNR, C~EKORG
        FROM ZGTMMT9040 AS A
             INNER JOIN EKPO AS B
              ON A~EBELN = B~EBELN
              AND A~EBELP = B~EBELP
             INNER JOIN EKKO AS C
              ON B~EBELN = C~EBELN
       WHERE A~ICCNO = @GS_DEL-ICCNO
         AND A~ICCSQ = @GS_DEL-ICCSQ
         AND A~ICCIT = @GS_DEL-ICCIT
         AND C~BUKRS = @P_BUKRS
         AND B~WERKS IN @S_WERKS
         AND A~ZFLAG <> 'D'
         AND A~ZIFKEY = (
                          SELECT MAX( AA~ZIFKEY )
                            FROM ZGTMMT9040 AS AA
                           WHERE A~ICCNO = AA~ICCNO
                             AND A~ICCSQ = AA~ICCSQ
                             AND A~ICCIT = AA~ICCIT
                             AND A~ZFLAG = AA~ZFLAG
                        )
      INTO CORRESPONDING FIELDS OF @GS_CCHG.

      "--> I/F 테이블 반영
      IF SY-SUBRC = 0.

        GS_CCHG-CHANGENR = GS_DEL-CHANGENR.
        GS_CCHG-USERNAME = GS_DEL-USERNAME.
        GS_CCHG-UTIME = GS_DEL-UTIME.
        GS_CCHG-UDATE = GS_DEL-UDATE.

        MOVE-CORRESPONDING GS_CCHG TO GT_CCHG.
        APPEND GT_CCHG.
      ENDIF.
    ENDLOOP.
  ENDIF.
*<-- [CHM2510-00260]소재 MOM I/F 신규 필드 반영

* CHECK GT_CCHG[] IS NOT INITIAL.
* PERFORM EXCEPT_SEND_DATA.

  CHECK GT_CCHG[] IS NOT INITIAL.

  SORT GT_CCHG BY ICCNO UDATE.
  <GT_LIST> = CORRESPONDING #( GT_CCHG[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& text --> ZGTMM_CV_CHANGEDCU-DUP 로 전송여부 구분 변경!(송종면E 24.12.06)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM EXCEPT_SEND_DATA.
*
*  DATA : LT_CCHG TYPE ZGTMM_CV_CHANGEDCU OCCURS 0 WITH HEADER LINE.
*
*
*  CLEAR : GR_ICCNO[].
*
*  CHECK P_FRC     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
*  CHECK GT_CCHG[] IS NOT INITIAL.
*
*  LT_CCHG[] = GT_CCHG[].
*  SORT LT_CCHG BY ICCNO CHANGENR.
*  DELETE ADJACENT DUPLICATES FROM LT_CCHG COMPARING ICCNO CHANGENR.
*
*  SELECT DISTINCT ICCNO AS LOW
*    FROM ZGTMM_CV_CU_IF_LOG
*    INTO CORRESPONDING FIELDS OF TABLE @GR_ICCNO
*     FOR ALL ENTRIES IN @LT_CCHG
*   WHERE ICCNO    = @LT_CCHG-ICCNO
*     AND CHANGENR = @LT_CCHG-CHANGENR
*     AND ZSTAT    = @GC_S.
*
*  CHECK GR_ICCNO[] IS NOT INITIAL.
*  GR_ICCNO-SIGN   = GC_I.
*  GR_ICCNO-OPTION = GC_EQ.
*  MODIFY GR_ICCNO TRANSPORTING SIGN OPTION
*                         WHERE SIGN IS INITIAL.
*
*  DELETE GT_CCHG WHERE ICCNO IN GR_ICCNO.
*
*ENDFORM.
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

  DATA : LT_F006 LIKE ZGTMMSIF0006 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_F006[], GT_CLOG[].
  CLEAR : GV_CNT,    GV_MSG.

  IF PV_CHK = GC_X.
    PERFORM SEND_SEL_DATA.

    CHECK GV_ERR IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   'Data를 전송 하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ELSE.
    PERFORM SEND_BAT_DATA.
  ENDIF.

  IF P_IFSYT IS INITIAL.
    MESSAGE S015 WITH 'I/F 시스템'(M01) DISPLAY LIKE 'E'. "&를(을) 입력하세요.
    EXIT.
  ENDIF.

  PERFORM MODIFY_F006_DATA.

  LT_F006[] = GT_F006[].

*2025.08.13 통합솔루션 IS전환
  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
*      GUBUN                 = 'MM'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_IF_O_CUSTSEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_TAB      = LT_F006[] "GT_F006[]
    EXCEPTIONS
      OTHERS      = 1.

  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
      GV_CNT = LINES( GT_F006[] ).
      GV_MSG = GV_CNT && '건 전송 성공'(M02).
    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

  PERFORM SAVE_LOG USING LV_RET
                         LV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        MESSAGE S050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
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

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_LIST> INTO <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE 'X'.
      WHEN P_ILOG.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LAST>).

        IF <LFS_LAST> IS INITIAL.
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.

    GT_CLOG = CORRESPONDING #( <GS_LIST> ).
    APPEND GT_CLOG.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_BAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_BAT_DATA.

  GT_CLOG[] = CORRESPONDING #( <GT_LIST> ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F006_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F006_DATA.

  LOOP AT GT_CLOG.

*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영
    IF P_IFSYT = 'KSCM'.
      IF GT_CLOG-CHANGENR IS NOT INITIAL.
        GT_CLOG-ZFLAG = 'D'. " 삭제 구분자
      ELSE.
        GT_CLOG-ZFLAG = 'N'. " 생성/수정 구분자
      ENDIF.
      MODIFY GT_CLOG TRANSPORTING ZFLAG..
    ENDIF.
*<-- [CHM2510-00260]소재 MOM I/F 신규 필드 반영

    GT_F006 = CORRESPONDING #( GT_CLOG ).

    GT_F006-EBELN = |{ GT_F006-EBELN ALPHA = OUT }|.
    GT_F006-IBLNO = |{ GT_F006-IBLNO ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F006-MATNR.

    SHIFT GT_F006-ICCIT LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT GT_F006-EBELP LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT GT_F006-IBLIT LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

    APPEND GT_F006.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F006_MATNR
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
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CLEAR : GS_9000, GT_9040[].

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00004.
  GS_9000-SYSTEM_ID   = P_IFSYT.
  GS_9000-ZSTAT       = PV_RET.
  GS_9000-MESSAGE     = PV_MSG.
  GS_9000-IFDAT       = SY-DATLO.
  GS_9000-IFTIM       = SY-TIMLO.
  GS_9000-IFNAM       = SY-UNAME.
  GS_9000-ERDAT       = SY-DATUM.
  GS_9000-ERDAT_LOCAL = SY-DATLO.
  GS_9000-ERTIM       = SY-UZEIT.
  GS_9000-ERTIM_LOCAL = SY-TIMLO.
  GS_9000-ERNAM       = SY-UNAME.

  GT_9040[] = VALUE #( FOR LS_LOG IN GT_CLOG
                       ( VALUE #( BASE CORRESPONDING #( LS_LOG )
                                  ZIFKEY = GS_9000-ZIFKEY ) ) ).

  CHECK GT_9040[] IS NOT INITIAL.

  MODIFY ZGTMMT9040 FROM TABLE GT_9040.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  GV_SEND = COND #( WHEN P_ILOG = 'X' THEN '재전송'(B01)
                    WHEN P_SEND = 'X' THEN '전송'(B02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_DOCK
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_OBJ USING PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER
                   PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  PR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  PR_GRID = NEW #( I_PARENT      = PR_DOCK
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

  "다운로드 기능(MC_MB_EXPORT) 삭제(송종면E 25.02.10)

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.
  PS_LAYO-GRID_TITLE = COND #( WHEN P_ILOG = 'X' THEN 'Interface 처리상태'(T01)
                               WHEN P_SEND = 'X' THEN '통관 정보'(T02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( GV_TNAME )
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  DELETE LT_FCAT WHERE FIELDNAME = '.NODE1'.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = <GT_LIST>
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
*     IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = <GT_LIST>
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> GS_LAYO
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
      CALL METHOD GR_GRID->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_GRID, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
