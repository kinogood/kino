*&---------------------------------------------------------------------*
*& Include          ZGTMMR4911F01
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

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
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

  IF ( P_ILOG = GC_X AND S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( S_WERKS[] IS INITIAL
                        OR S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL ) ).
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

  PERFORM GET_MST_INFO USING 'MM00002'.

  PERFORM MAKE_ITAB.
  CLEAR : <GT_HLIST>, <GT_ILIST>.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

  GV_CNT = LINES( <GT_HLIST> ).

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

  CLEAR    : GV_HNAME,    GV_INAME.
  UNASSIGN : <GT_HLIST>, <GT_ILIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_HNAME = GS_MST-VIEW. "ZGTMM_CV_PO_IF_LOG_L
      GV_INAME = GC_ZGTMMT9021.

    WHEN P_SEND.
      GV_HNAME = GC_ZGTMMSIF0002.
      GV_INAME = GC_ZGTMMSIF0003.

  ENDCASE.

  PERFORM ASSIGN_ITAB USING 'H' GV_HNAME.
  PERFORM ASSIGN_ITAB USING 'I' GV_INAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GT_HLIST>
*&      --> GV_HNAME
*&---------------------------------------------------------------------*
FORM ASSIGN_ITAB USING PV_TYPE
                       PV_NAME.

  DATA : LR_DATA  TYPE REF TO DATA.

  FIELD-SYMBOLS : <LS_LIST>.


  DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                       CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( PV_NAME ) ).

  CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
  ASSIGN LR_DATA->* TO <LS_LIST>.
  FREE : LR_DATA.

  CREATE DATA LR_DATA LIKE STANDARD TABLE OF <LS_LIST>.
  CASE PV_TYPE.
    WHEN 'H'.
      ASSIGN LR_DATA->* TO <GT_HLIST>.
    WHEN 'I'.
      ASSIGN LR_DATA->* TO <GT_ILIST>.
  ENDCASE.
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


  LV_COND = | IFDAT IN @S_IFDAT AND LIFNR IN @S_LIFNR AND EBELN IN @S_EBELN |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_FNL IS NOT INITIAL.
    LV_COND = LV_COND && | AND LASTDATA = @GC_X |.
  ENDIF.

  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
  ENDIF.

  SELECT *
    FROM (GV_HNAME)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_HLIST>
   WHERE (LV_COND).

  CHECK <GT_HLIST> IS NOT INITIAL.
  SORT <GT_HLIST> BY ('ZIFKEY') DESCENDING
                     ('LIFNR')  ASCENDING
                     ('EBELN')  ASCENDING.

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

  CLEAR : GT_PCHG[], GT_LFA1[].
  CLEAR : GT_SHDR[], GT_SITM[], GT_SMAT[].

  SELECT *
    FROM ZGTMM_CV_CHANGEDPO( P_STARTDATE = @S_ERDAT-LOW,
                             P_ENDDATE   = @S_ERDAT-HIGH )
   WHERE WERKS IN @S_WERKS
     AND LIFNR IN @S_LIFNR
     AND EBELN IN @S_EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_PCHG.

*--> [CHM2510-00260] 소재 MOM 사내거래오더 I/F 추가
  IF P_IFSYT = 'KSCM'.
    SELECT *
      FROM ZGTMM_CV_CHANGEDPO( P_STARTDATE = @S_ERDAT-LOW,
                               P_ENDDATE   = @S_ERDAT-HIGH )
     WHERE RESWK IN @S_WERKS
       AND LIFNR IN @S_LIFNR
       AND EBELN IN @S_EBELN
    APPENDING CORRESPONDING FIELDS OF TABLE @GT_PCHG.
  ENDIF.
*<-- [CHM2510-00260] 소재 MOM 사내거래오더 I/F 추가

* "3(Subcontracting) & 0005(Confirmation/Change)
* DELETE GT_PCHG WHERE PSTYP = GC_3 AND BSTAE = GC_0005. "주석처리(송종면E 24.12.16)
  CHECK GT_PCHG[] IS NOT INITIAL.

  PERFORM EXCEPT_SEND_DATA.
  CHECK GT_PCHG[] IS NOT INITIAL.

  SORT GT_PCHG BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM GT_PCHG COMPARING EBELN EBELP.

  PERFORM GET_SMAT_DATA.
  PERFORM GET_LFA1.

  LOOP AT GT_PCHG.
    MOVE-CORRESPONDING GT_PCHG TO GS_PCHG.

    AT NEW EBELN.
      PERFORM SET_SHDR. "Header
    ENDAT.

    PERFORM SET_SITM. "Item

*   GT_SMAT-statu 필드가 TO-Be 에는 없어서 넣어주는 로직 불필요!!
  ENDLOOP.

  SORT GT_SHDR BY EBELN.
* SORT GT_SITM BY EBELN EBELP.
* SORT GT_SMAT BY EBELN EBELP MATNR.

  <GT_HLIST>[] = CORRESPONDING #( GT_SHDR[] ).
* <GT_ILIST>[] = CORRESPONDING #( GT_SITM[] ).

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

  DATA : LT_PCHG TYPE ZGTMM_CV_CHANGEDPO OCCURS 0 WITH HEADER LINE.


  CLEAR : GR_EBELN[].

  CHECK P_FRC     IS INITIAL. "기전송된 데이터 삭제
  CHECK GT_PCHG[] IS NOT INITIAL.

  LT_PCHG[] = GT_PCHG[].
  SORT LT_PCHG BY EBELN CHANGENR.
  DELETE ADJACENT DUPLICATES FROM LT_PCHG COMPARING EBELN CHANGENR.

  SELECT DISTINCT EBELN AS LOW
    FROM ZGTMMT9000 AS C INNER JOIN ZGTMMT9020 AS H
      ON C~ZIFKEY = H~ZIFKEY
    INTO CORRESPONDING FIELDS OF TABLE @GR_EBELN
     FOR ALL ENTRIES IN @LT_PCHG
   WHERE C~ZIFNO     = @GC_MM00002
     AND C~SYSTEM_ID = @P_IFSYT
     AND C~ZSTAT     = @GC_S
     AND H~EBELN     = @LT_PCHG-EBELN
     AND H~CHANGENR  = @LT_PCHG-CHANGENR.


  IF GR_EBELN[] IS NOT INITIAL. "CHECK GR_EBELN[] IS NOT INITIAL.
    GR_EBELN-SIGN   = GC_I.
    GR_EBELN-OPTION = GC_EQ.
    MODIFY GR_EBELN TRANSPORTING SIGN OPTION
                           WHERE SIGN IS INITIAL.

    DELETE GT_PCHG WHERE EBELN IN GR_EBELN.
  ENDIF.

*--> [GO_MM] 2026.07.14 가온전선 로직 분기 START (I/F MATNR NULL 필터링)
  IF P_IFSYT EQ 'KGOM' OR P_IFSYT EQ 'KGPM'.
    DELETE GT_PCHG WHERE MATNR IS INITIAL.
  ENDIF.
*<-- [GO_MM] 2026.07.14 가온전선 로직 분기 END (I/F MATNR NULL 필터링)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SMAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SMAT_DATA.

  DATA : BEGIN OF LT_PCHG OCCURS 0,
           EBELN LIKE EKPO-EBELN,
           EBELP LIKE EKPO-EBELP,
           PSTYP LIKE EKPO-PSTYP,
           BSTAE LIKE EKPO-BSTAE,
         END   OF LT_PCHG.


  CHECK GT_PCHG[] IS NOT INITIAL.
  LT_PCHG[] = CORRESPONDING #( GT_PCHG[] ).

* DELETE LT_PCHG WHERE NOT ( PSTYP = GC_3 AND BSTAE <> GC_0005 ).
  DELETE LT_PCHG WHERE PSTYP <> GC_3.

  CHECK LT_PCHG[] IS NOT INITIAL.
  SORT LT_PCHG BY EBELN EBELP.

  SELECT EBELN EBELP MATNR ERFMG ERFME LIFNR
    FROM RESB
    INTO CORRESPONDING FIELDS OF TABLE GT_SMAT
     FOR ALL ENTRIES IN LT_PCHG
   WHERE EBELN = LT_PCHG-EBELN
     AND EBELP = LT_PCHG-EBELP.

* SORT GT_SMAT BY EBELN EBELP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_LFA1.

  CHECK GT_PCHG[] IS NOT INITIAL.
  GT_LFA1[] = CORRESPONDING #( GT_PCHG[] ).

  SORT GT_LFA1 BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM GT_LFA1 COMPARING LIFNR.

  CHECK GT_LFA1[] IS NOT INITIAL.

  SELECT LIFNR KTOKK
    FROM LFA1
    INTO CORRESPONDING FIELDS OF TABLE GT_LFA1
     FOR ALL ENTRIES IN GT_LFA1
   WHERE LIFNR = GT_LFA1-LIFNR.

  SORT GT_LFA1 BY LIFNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SHDR.

  CLEAR : GT_SHDR.
  MOVE-CORRESPONDING GS_PCHG TO GT_SHDR.

  PERFORM SET_ZSHIP.

  IF GT_PCHG-H_LOEKZ = GC_C.
    GT_SHDR-LOEKZ = GC_X.
    GT_SHDR-STATU = '삭제'(V01).
  ELSEIF GT_PCHG-ELIKZ = GC_X.
    GT_SHDR-STATU = '완료'(V02).
  ELSE.
    GT_SHDR-STATU = '발주'(V03).
  ENDIF.

  APPEND GT_SHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZSHIP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ZSHIP.

  READ TABLE GT_LFA1 WITH KEY LIFNR = GT_SHDR-LIFNR
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_SHDR-ZSHIP = SWITCH #( GT_LFA1-KTOKK WHEN '1000' THEN GC_D    "내자
                                          WHEN '2000' THEN GC_O ). "외자

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SITM.

  CLEAR : GS_SITM.
  MOVE-CORRESPONDING GS_PCHG TO GS_SITM.
  GS_SITM-LOEKZ = GT_SHDR-LOEKZ.
  GS_SITM-STATU = GT_SHDR-STATU.

  PERFORM SET_TEXT.

  IF GT_PCHG-I_LOEKZ = GC_L.
    GS_SITM-LOEKZ = GC_X.
    GS_SITM-STATU = '삭제'(V01).
*--> [CHM2510-00260] 소재 MOM I/F 신규 필드 반영
    IF P_IFSYT = 'KSCM'.
      GS_SITM-ZFLAG = GC_D. " 삭제 = D
    ENDIF.
  ELSE.
    IF P_IFSYT = 'KSCM'.
      GS_SITM-ZFLAG = 'N'. " 기본값 = N
    ENDIF.
*<-- [CHM2510-00260] 소재 MOM I/F 신규 필드 반영
  ENDIF.

*--> 가온 재고유형/처리유형 필드추가
  IF P_IFSYT = 'KGPM' OR P_IFSYT = 'KGOM'.
    DATA: LV_MTART TYPE MARA-MTART.

    " 재고유형(공백:가용, X:품질재고, S:보류재고)
    GS_SITM-INSMK = GS_PCHG-INSMK.

    " PO처리유형 (A:외주가공, B:OEM상품, C:일반)
    SELECT SINGLE MTART INTO LV_MTART
      FROM MARA
     WHERE MATNR = GS_PCHG-MATNR.
    IF GS_PCHG-PSTYP = '3'.
      GS_SITM-POTYPE = 'A'.
    ELSEIF ( LV_MTART = 'MCHA' OR  LV_MTART = 'MCFE').
      GS_SITM-POTYPE = 'B'.
    ELSE.
      GS_SITM-POTYPE = 'C'.
    ENDIF.

    "--> 가온 조장정보 필드 추가
    DATA : LV_DRQTY TYPE I.
    SELECT SINGLE LENGTH, DRQTY
      INTO (@GS_SITM-MILLCA_LENGTH, @LV_DRQTY)
      FROM ZGTMM_CV_PO_VCVALUE_MAIN2
     WHERE PDOC = @GS_PCHG-EBELN
       AND PDOCITEM = @GS_PCHG-EBELP.

    GS_SITM-MILLCA_FACTOR = LV_DRQTY.
    CONDENSE GS_SITM-MILLCA_FACTOR NO-GAPS.
    "<-- 가온 조장정보 필드 추가
  ENDIF.
*<-- 가온 재고유형/처리유형 필드추가

  APPEND GS_SITM TO GT_SITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TEXT.

  DATA : LV_NAME LIKE THEAD-TDNAME.
  DATA : LT_LINE LIKE TLINE OCCURS 0 WITH HEADER LINE.

  LV_NAME = GS_PCHG-EBELN && GS_PCHG-EBELP.

"--> 내/외자 공급업체별 언어 구분자 추가
"*** 외자업체(LANGUAGE = EN)은 EN으로만 텍스트 읽어와 짐
"*** 한국은 KO로만 로그인한다는 전제
  DATA : LV_LANGU TYPE SYST_LANGU.
  SELECT COUNT(*)
    FROM LFA1
   WHERE LIFNR = GS_PCHG-LIFNR
     AND SPRAS = SY-LANGU.

  IF SY-DBCNT = 0.
    LV_LANGU = 'EN'.
  ELSE.
    LV_LANGU = SY-LANGU.
  ENDIF.
"<-- 내/외자 공급업체별 언어 구분자 추가

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = 'F01'
*      LANGUAGE                = SY-LANGU
      LANGUAGE                = LV_LANGU
      NAME                    = LV_NAME
      OBJECT                  = 'EKPO'
    TABLES
      LINES                   = LT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  CHECK SY-SUBRC = 0.

  LOOP AT LT_LINE.
    CONCATENATE GS_SITM-ZTEXT LT_LINE-TDLINE
           INTO GS_SITM-ZTEXT SEPARATED BY SPACE.
  ENDLOOP.

  CONDENSE GS_SITM-ZTEXT.

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

  DATA : LT_F002 LIKE ZGTMMSIF0002 OCCURS 0 WITH HEADER LINE,
         LT_F003 LIKE ZGTMMSIF0003 OCCURS 0 WITH HEADER LINE,
         LT_F004 LIKE ZGTMMSIF0004 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_F002[], GT_F003[], GT_F004[].
  CLEAR : GT_XHDR[], GT_XITM[], GT_XMAT[].
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

  PERFORM MODIFY_F00X_DATA.

  LT_F002[] = GT_F002[].
  LT_F003[] = GT_F003[].
  LT_F004[] = GT_F004[].

*2025.08.13 통합솔루션 IS전환
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

  DATA : LV_SYS_MSG(255) TYPE C.

  CALL FUNCTION 'ZGTMM_IF_O_POSEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_TAB01    = LT_F002[] "GT_F002[]
      OT_TAB02    = LT_F003[] "GT_F003[]
      OT_TAB03    = LT_F004[] "GT_F004[]
    EXCEPTIONS
      OTHERS      = 1.
*    EXCEPTIONS
*      system_failure        = 1 MESSAGE lv_sys_msg
*      communication_failure = 2 MESSAGE lv_sys_msg
*      OTHERS                = 3.


  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
      GV_CNT = LINES( GT_F002[] ).
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
*&      --> GR_HGRID
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

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  CLEAR : GT_LITM[], GT_LMAT[].

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_HLIST> ASSIGNING <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE 'X'.
      WHEN P_ILOG.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LAST>).

        IF <LFS_LAST> IS INITIAL.
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

        PERFORM APPEND_LIST TABLES GT_XHDR USING <GS_LIST>.
        PERFORM APPEND_LIST TABLES GT_LITM USING <GS_LIST>.
        PERFORM APPEND_LIST TABLES GT_LMAT USING <GS_LIST>.

      WHEN P_SEND.
        PERFORM GET_SEND_ITM USING 'X' 'X'.
        APPEND LINES OF GT_TITM TO GT_F003.
        APPEND LINES OF GT_TMAT TO GT_F004.

        READ TABLE GT_SHDR WITH KEY EBELN = <GV_EBELN>
                                    BINARY SEARCH.

        IF SY-SUBRC = 0.
          PERFORM APPEND_LIST TABLES GT_XHDR USING GT_SHDR.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_ITM.
      PERFORM GET_ILOG_MAT.

      GT_F003[] = CORRESPONDING #( GT_LITM[] ).
      GT_F004[] = CORRESPONDING #( GT_LMAT[] ).

    WHEN P_SEND.

  ENDCASE.

  GT_XITM[] = CORRESPONDING #( GT_F003[] ).
  GT_XMAT[] = CORRESPONDING #( GT_F004[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F002
*&      --> <GS_LIST>
*&---------------------------------------------------------------------*
FORM APPEND_LIST TABLES PT_ITAB
                  USING PS_LIST.

  CLEAR : PT_ITAB.

  PT_ITAB = CORRESPONDING #( PS_LIST ).
  APPEND PT_ITAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_ITM.

  CHECK GT_LITM[] IS NOT INITIAL.

  SORT GT_LITM BY ZIFKEY EBELN.
  DELETE ADJACENT DUPLICATES FROM GT_LITM COMPARING ZIFKEY EBELN.

  SELECT *
    FROM ZGTMMT9021
    INTO CORRESPONDING FIELDS OF TABLE GT_LITM
     FOR ALL ENTRIES IN GT_LITM
   WHERE ZIFKEY = GT_LITM-ZIFKEY
     AND EBELN  = GT_LITM-EBELN.

  SORT GT_LITM BY ZIFKEY DESCENDING
                  LIFNR  ASCENDING
                  EBELN  ASCENDING
                  EBELP  ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_MAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_MAT.

  CHECK GT_LMAT[] IS NOT INITIAL.

  SORT GT_LMAT BY ZIFKEY EBELN.
  DELETE ADJACENT DUPLICATES FROM GT_LMAT COMPARING ZIFKEY EBELN.

  SELECT *
    FROM ZGTMMT9022
    INTO CORRESPONDING FIELDS OF TABLE GT_LMAT
     FOR ALL ENTRIES IN GT_LMAT
   WHERE ZIFKEY = GT_LMAT-ZIFKEY
     AND EBELN  = GT_LMAT-EBELN.

  SORT GT_LMAT BY ZIFKEY DESCENDING
                  LIFNR  ASCENDING
                  EBELN  ASCENDING
                  EBELP  ASCENDING
                  MATNR  ASCENDING.

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

  GT_F002[] = GT_XHDR[] = CORRESPONDING #( GT_SHDR[] ).
  GT_F003[] = GT_XITM[] = CORRESPONDING #( GT_SITM[] ).
  GT_F004[] = GT_XMAT[] = CORRESPONDING #( GT_SMAT[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F00X_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F00X_DATA.

  GT_F002[] = VALUE #( FOR LS_HDR IN GT_XHDR
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  EBELN = |{ LS_HDR-EBELN ALPHA = OUT }|
                                  LIFNR = |{ LS_HDR-LIFNR ALPHA = OUT }| ) ) ).

  LOOP AT GT_F003.
    GT_F003-EBELN = |{ GT_F003-EBELN ALPHA = OUT }|.
    GT_F003-LIFNR = |{ GT_F003-LIFNR ALPHA = OUT }|.
    GT_F003-KUNNR = |{ GT_F003-KUNNR ALPHA = OUT }|.
    GT_F003-VBELN = |{ GT_F003-VBELN ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F003-MATNR.

    SHIFT GT_F003-EBELP LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT GT_F003-VBELP LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

*    MODIFY GT_F003 TRANSPORTING EBELN LIFNR KUNNR VBELN MATNR EBELP VBELP.
    MODIFY GT_F003 TRANSPORTING EBELN LIFNR KUNNR VBELN MATNR EBELP VBELP MILLCA_LENGTH MILLCA_FACTOR.
  ENDLOOP.

  LOOP AT GT_F004.
    GT_F004-EBELN = |{ GT_F004-EBELN ALPHA = OUT }|.
    GT_F004-LIFNR = |{ GT_F004-LIFNR ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F004-MATNR.

    SHIFT GT_F004-EBELP LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영
    IF P_IFSYT = 'KSCM'.
      READ TABLE GT_F003 WITH KEY EBELN = GT_F004-EBELN
                                  EBELP = GT_F004-EBELP.
      IF SY-SUBRC = 0.
        GT_F004-STATU = GT_F003-STATU.
      ENDIF.
      MODIFY GT_F004 TRANSPORTING EBELN LIFNR MATNR EBELP STATU.
    ELSE.
      MODIFY GT_F004 TRANSPORTING EBELN LIFNR MATNR EBELP.
    ENDIF.
*<-- [CHM2510-00260]소재 MOM I/F 신규 필드 반영

*    MODIFY GT_F004 TRANSPORTING EBELN LIFNR MATNR EBELP.

  ENDLOOP.

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
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CLEAR : GS_9000, GT_9020[], GT_9021[], GT_9022[].

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00002.
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

  GT_9020[] = VALUE #( FOR LS_HDR IN GT_XHDR
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  ZIFKEY  = GS_9000-ZIFKEY
                                  CRE_NAM = SY-UNAME ) ) ).

  GT_9021[] = VALUE #( FOR LS_ITM IN GT_XITM
                       ( VALUE #( BASE CORRESPONDING #( LS_ITM )
                                  ZIFKEY  = GS_9000-ZIFKEY ) ) ).

  GT_9022[] = VALUE #( FOR LS_MAT IN GT_XMAT
                       ( VALUE #( BASE CORRESPONDING #( LS_MAT )
                                  ZIFKEY  = GS_9000-ZIFKEY ) ) ). "STATU ??

  CHECK GT_9020[] IS NOT INITIAL.

*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영
  IF GT_9022[] IS NOT INITIAL.
    LOOP AT GT_9022.
      READ TABLE GT_9021 WITH KEY ZIFKEY = GT_9022-ZIFKEY
                                  EBELN = GT_9022-EBELN
                                  EBELP = GT_9022-EBELP.
      IF SY-SUBRC = 0.
        GT_9022-STATU = GT_9021-STATU.
        MODIFY GT_9022 TRANSPORTING STATU.
      ENDIF.
    ENDLOOP.
  ENDIF.
*<-- [CHM2510-00260]소재 MOM I/F 신규 필드 반영

  MODIFY ZGTMMT9022 FROM TABLE GT_9022.
  MODIFY ZGTMMT9021 FROM TABLE GT_9021.
  MODIFY ZGTMMT9020 FROM TABLE GT_9020.
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
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_SPLIT = NEW #( PARENT  = GR_DOCK
                    ROWS    = 2
                    COLUMNS = 1 ).

  "#1 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

  "#2 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2
                                      COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
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
      PS_LAYO-GRID_TITLE = COND #( WHEN P_ILOG = 'X' THEN 'Interface 처리상태'(T01)
                                   WHEN P_SEND = 'X' THEN '구매오더 헤더정보'(T02) ).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '상세정보'(T03).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
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
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( PV_NAME )
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
      IT_DATA         = PT_DATA
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  "내장유형 필드명 추가
  LOOP AT PT_FCAT INTO GS_FCAT.
    CASE GS_FCAT-FIELDNAME.
      WHEN 'ZFLAG'.
        GS_FCAT-SCRTEXT_M = '삭제지시자'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'POTYPE'.
        GS_FCAT-SCRTEXT_M = '처리유형'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'INSMK'.
        GS_FCAT-SCRTEXT_M = '재고유형'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'EINDT'.
        GS_FCAT-SCRTEXT_M = '납품요청일'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'AEDAT'.
        GS_FCAT-SCRTEXT_M = '변경일'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'MILLCA_LENGTH'.
        GS_FCAT-SCRTEXT_M = '조장 길이'.
        MODIFY PT_FCAT FROM GS_FCAT.
      WHEN 'MILLCA_FACTOR'.
        GS_FCAT-SCRTEXT_M = '조장 수'.
        MODIFY PT_FCAT FROM GS_FCAT.
    ENDCASE.
  ENDLOOP.

  CHECK PV_TYPE = GC_H.

  GS_FCAT-HOTSPOT = GC_X.
  MODIFY PT_FCAT FROM GS_FCAT TRANSPORTING HOTSPOT
                WHERE FIELDNAME = GC_EBELN.

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
      SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

    WHEN 'GR_IGRID'.

  ENDCASE.

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> <GT_HLIST>
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
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_HCNTR, GR_ICNTR, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_ROW  TYPE LVC_S_ROW
                                PS_COL  TYPE LVC_S_COL
                                PS_ROID TYPE LVC_S_ROID
                                PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      READ TABLE <GT_HLIST> ASSIGNING <GS_LIST> INDEX PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'EBELN'.
          PERFORM GET_ILIST_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILIST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILIST_DATA.

  CLEAR : <GT_ILIST>.

  CASE 'X'.
    WHEN P_ILOG.
      CLEAR : GT_LITM[].
      PERFORM APPEND_LIST TABLES GT_LITM USING <GS_LIST>.

      PERFORM GET_ILOG_ITM.
      <GT_ILIST>[] = CORRESPONDING #( GT_LITM[] ).

    WHEN P_SEND.
      PERFORM GET_SEND_ITM USING 'X' ' '.
      <GT_ILIST>[] = CORRESPONDING #( GT_TITM[] ).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_ITM USING PV_ITM
                        PV_MAT.

  CLEAR : GT_TITM[], GT_TMAT[].

  ASSIGN COMPONENT 'EBELN' OF STRUCTURE <GS_LIST> TO <GV_EBELN>.

  IF PV_ITM = GC_X.
    GT_TITM[] = CORRESPONDING #( FILTER #( GT_SITM WHERE EBELN = <GV_EBELN> ) ).
  ENDIF.

  IF PV_MAT = GC_X.
    GT_TMAT[] = CORRESPONDING #( FILTER #( GT_SMAT WHERE EBELN = <GV_EBELN> ) ).
  ENDIF.

ENDFORM.
