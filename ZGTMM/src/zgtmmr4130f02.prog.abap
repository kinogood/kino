*&---------------------------------------------------------------------*
*& Include          ZGTMMR4130F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_ACTV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ACTV.

  "Pgm.실행 Active Flag Check(SJM 25.04.17)

  SELECT SINGLE FLD_03
    FROM ZGTPPT1010 INTO @DATA(LV_CHK)
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0200
     AND FLD_01      = @GC_ZGTMMR4130.

  CHECK LV_CHK IS INITIAL.
  MESSAGE E134(ZGTMM01). "해당 Pgm.은 실행 불가한 상태입니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZUSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ZUSE.

  "GT 과제 활성화 여부 사전 체크

  CLEAR : GV_ZUSE, GV_BUKRS.

  SELECT SINGLE ZUSE
    FROM ZGTMMT1000 INTO GV_ZUSE
   WHERE WERKS = P_WERKS
     AND ZTYPE = GC_02.  "SC-Stock MGMT

  SELECT SINGLE BUKRS INTO @GV_BUKRS
    FROM T001W AS W INNER JOIN T001K AS K
      ON W~BWKEY = K~BWKEY
     AND W~WERKS = @P_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_MB1B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_MB1B.

  PERFORM CHECK_MB1B USING ' '.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_MB1B_HDR.

  DATA(LV_AT) = SWITCH #( GV_PRC WHEN 'N' THEN 12
                                          ELSE 9 ).

  CALL SCREEN 210 STARTING AT  10 5
                    ENDING AT 128 LV_AT. "15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MB1B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MB1B USING PV_CHK.

* DATA : BEGIN OF LT_LAG OCCURS 0,
*          LGORT LIKE MDSB-LGORT,
**         CHECK(1),
*        END   OF LT_LAG.
  TYPES : LTY_LAG LIKE TABLE OF GT_LAG WITH EMPTY KEY.


  "상/하단 ALV 선택라인의 저장위치는 모두 동일해야 이력 관리 가능(SJM 25.03.18)
  "상/하단 ALV 선택라인의 저장위치는 서로 다를 수 있음으로 변경(SJM 25.03.31)
  " 상/하단 ALV 각각에서 저장위치가 동일한지를 체크

  CLEAR : GV_ERR,   GV_COND.
  CLEAR : GV_L_LAG, GV_W_LAG.
  CLEAR : GT_LAG[], GT_MDSB[], GT_CSTK[].

* LT_LAG[] = CORRESPONDING #( GT_MDSB_L[] ).
* LT_LAG[] = CORRESPONDING #( BASE ( LT_LAG[] ) GT_MDSB_W2[] ).
*
* DELETE LT_LAG WHERE CHECK = SPACE.
*
* SORT LT_LAG BY LGORT.
* DELETE ADJACENT DUPLICATES FROM LT_LAG COMPARING LGORT.

  PERFORM CHK_MB1B TABLES GT_MDSB_L  USING 'L' PV_CHK.
  PERFORM CHK_MB1B TABLES GT_MDSB_W2 USING 'W' PV_CHK.

  CHECK GV_ERR IS INITIAL.
  IF PV_CHK IS INITIAL.
    IF GT_MDSB[] IS INITIAL.
      MESSAGE S004(ZGTMM01) DISPLAY LIKE 'E'. "라인을 선택하세요.
      GV_ERR = GC_X. EXIT.
    ELSEIF LINES( GT_LAG ) = 0 OR LINE_EXISTS( GT_LAG[ LGORT = SPACE ] ).
      MESSAGE S015(ZGTMM01) WITH '저장위치' DISPLAY LIKE 'E'. "&를(을) 입력하세요.
      GV_ERR = GC_X. EXIT.
*   ELSEIF LINES( GT_LAG ) > 1.
    ELSEIF LINES( VALUE LTY_LAG( FOR LS_LAG IN GT_LAG WHERE ( TYPE = GC_L ) ( LS_LAG ) ) ) > 1
        OR LINES( VALUE LTY_LAG( FOR LS_LAG IN GT_LAG WHERE ( TYPE = GC_W ) ( LS_LAG ) ) ) > 1.
      MESSAGE S123(ZGTMM01) DISPLAY LIKE 'E'. "동일한 저장위치에 대해서만 처리가능합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

*   CHECK GV_ERR IS INITIAL.
*   GV_LGORT = GT_LAG[ 1 ]-LGORT.
    GV_L_LAG = VALUE #( GT_LAG[ TYPE = GC_L ]-LGORT OPTIONAL ).
    GV_W_LAG = VALUE #( GT_LAG[ TYPE = GC_W ]-LGORT OPTIONAL ).
  ENDIF.

  PERFORM CHK_CSTK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MB1B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHK_MB1B TABLES PT_MDSB
               USING PV_TYPE
                     PV_CHK.

  DATA : BEGIN OF LT_TAG OCCURS 0,
           MATNR_C LIKE ZGTMMT4114-MATNR,
           TAGNR   LIKE ZGTMMT4114-TAGNR,
         END   OF LT_TAG.


  CHECK GV_ERR IS INITIAL.

  LT_TAG[] = CORRESPONDING #( PT_MDSB[] ). "추가(SJM 25.05.14)

  GV_COND = | CHECK = GC_X |.

  LOOP AT PT_MDSB WHERE (GV_COND).
    PERFORM CHK_MB1B_ERR USING PT_MDSB
                               PV_CHK.
    IF GV_ERR = GC_X. EXIT. ENDIF.

    CHECK PV_CHK IS INITIAL.

    ASSIGN COMPONENT 'LGORT' OF STRUCTURE PT_MDSB TO FIELD-SYMBOL(<LFS_LGORT>).
    GT_LAG-TYPE  = PV_TYPE.
    GT_LAG-LGORT = <LFS_LGORT>.
    COLLECT GT_LAG.
*   _SET_CON1 GT_LAG GT_LAG-LGORT <LFS_LGORT>.

    PERFORM SET_MDSB USING PV_TYPE PT_MDSB.

    "입력값 Check
    IF GT_MDSB-MENGE IS INITIAL.
      MESSAGE S124(ZGTMM01) DISPLAY LIKE 'E'. "수량 입력은 필수입니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_MDSB-XCHPF = GC_X AND GT_MDSB-CHARG IS INITIAL.
      MESSAGE S125(ZGTMM01) DISPLAY LIKE 'E'. "배치 관리 자재는 배치 입력이 필수입니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    "배치 미관리 자재 꼬리표 중복 사용 여부 Check(SJM 25.05.13)
    " - 승인 진행시 사용했던 꼬리표 재사용 불가
    " - 현재 화면상 중복 입력 불가(SJM 25.05.14)
    IF PV_TYPE = GC_W AND GT_MDSB-TAGNR IS NOT INITIAL.
      DATA(LV_CNT) = REDUCE I( INIT X = 0 FOR LS_TAG IN LT_TAG
                                        WHERE ( MATNR_C = GT_MDSB-MATNR
                                            AND TAGNR   = GT_MDSB-TAGNR )
                                         NEXT X = X + 1 ).

      IF LV_CNT <= 1.
*       READ TABLE GT_PO WITH KEY GUBUN = PV_TYPE
*                                 LGORT = GT_MDSB-LGORT
*                                 MATNR = GT_MDSB-MATNR
*                                 TAGNR = GT_MDSB-TAGNR.
        SELECT SINGLE TAGNR
          FROM ZGTMMT4114 INTO @DATA(LV_TAG)
         WHERE PSWRK = @GT_MDSB-WERKS
           AND MATNR = @GT_MDSB-MATNR
           AND TAGNR = @GT_MDSB-TAGNR.
      ENDIF.

      IF LV_CNT > 1 OR LV_TAG IS NOT INITIAL.
        "꼬리표는 중복 사용할 수 없습니다. &
        MESSAGE S153(ZGTMM01) WITH GT_MDSB-TAGNR DISPLAY LIKE 'E'.
        GV_ERR = GC_X. EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MB1B_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&      --> PV_CHK
*&---------------------------------------------------------------------*
FORM CHK_MB1B_ERR USING PS_MDSB
                        PV_CHK.

  ASSIGN COMPONENT 'STATS' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_STATS>).
  ASSIGN COMPONENT 'MBLNR' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MBLNR>).

  IF <LFS_STATS> <> ICON_ALLOW AND PV_CHK = GC_X AND GV_ZUSE = GC_X.
    MESSAGE S135(ZGTMM01) DISPLAY LIKE 'E'. "승인되지 않은 건이 포함되어 있습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF <LFS_STATS> = ICON_MAIL.
    MESSAGE S026(ZGTMM01) DISPLAY LIKE 'E'. "해당 업체 출고 관련 승인 진행 건이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF <LFS_STATS> = ICON_ALLOW AND <LFS_MBLNR> <> SPACE.
    MESSAGE S027(ZGTMM01) DISPLAY LIKE 'E'. "출고 처리 결과가 존재합니다. 다시 조회 후 진행하세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

* IF ( <LFS_STATS> = ICON_MAIL
* OR ( <LFS_STATS> = ICON_ALLOW AND <LFS_MBLNR> = SPACE ) ).
*   MESSAGE S026(ZGTMM01) DISPLAY LIKE 'E'. "해당 업체 출고 관련 승인 진행 건이 존재합니다.
*   GV_ERR = GC_X. EXIT.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MDSB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_MDSB_L
*&---------------------------------------------------------------------*
FORM SET_MDSB USING PV_TYPE
                    PS_MDSB.

  CLEAR : GT_MDSB, GT_CSTK.

  MOVE-CORRESPONDING PS_MDSB TO GT_MDSB.

  DATA(LV_MENGE) = SWITCH #( PV_TYPE WHEN 'L' THEN 'BDMNG'
                                     WHEN 'W' THEN 'ENMNG' ).

  ASSIGN COMPONENT 'MATNR_C' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MATNR>).
  ASSIGN COMPONENT LV_MENGE  OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MENGE>).

  GT_MDSB-MATNR = <LFS_MATNR>.
  GT_MDSB-MENGE = <LFS_MENGE>.
  GT_MDSB-TYPE = PV_TYPE.

  IF PV_TYPE = GC_W.
    SELECT SINGLE XCHPF
      FROM MARC INTO GT_MDSB-XCHPF
     WHERE MATNR = GT_MDSB-MATNR
       AND WERKS = GT_MDSB-WERKS.
  ENDIF.

  PERFORM SUM_LABST USING GT_MDSB-MATNR
                          GT_MDSB-WERKS
                          GT_MDSB-LGORT
                 CHANGING GT_MDSB-LABST. "현재고(Plant)

  DATA(LV_LIFNR) = GT_LIFNR[ 1 ]-LIFNR.
  PERFORM SUM_LBLAB USING GT_MDSB-MATNR
                          GT_MDSB-WERKS
                          GT_MDSB-CHARG
                          LV_LIFNR
                 CHANGING GT_MDSB-LBLAB. "현재고(SC업체)

  APPEND GT_MDSB.

  MOVE-CORRESPONDING GT_MDSB TO GT_CSTK.
  COLLECT GT_CSTK.

* APPEND VALUE #( MATNR = GT_MDSB_L-MATNR_C
*                 WERKS = GT_MDSB_L-WERKS
*                 MENGE = GT_MDSB_L-BDMNG
*                 TYPE  = GC_L ) TO GT_MDSB.
*
* APPEND VALUE #( MATNR = GT_MDSB_W2-MATNR_C
*                 WERKS = GT_MDSB_W2-WERKS
*                 MENGE = GT_MDSB_W2-ENMNG
*                 TYPE  = GC_W ) TO GT_MDSB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUM_LABST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_MATNR
*&      --> GT_MDSB_WERKS
*&      --> GT_MDSB-LGORT
*&      <-- GT_MDSB_LABST
*&---------------------------------------------------------------------*
FORM SUM_LABST USING PV_MATNR
                     PV_WERKS
                     PV_LGORT
            CHANGING PV_LABST.

  CLEAR : PV_LABST.

  SELECT SUM( LABST )
    FROM MARD INTO PV_LABST
   WHERE MATNR = PV_MATNR
     AND WERKS = PV_WERKS.
*    AND LGORT = PV_LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUM_LBLAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_MATNR
*&      --> GT_MDSB_WERKS
*&      --> GT_MDSB_CHARG
*&      --> LV_LIFNR
*&      <-- GT_MDSB_LBLAB
*&---------------------------------------------------------------------*
FORM SUM_LBLAB USING PV_MATNR
                     PV_WERKS
                     PV_CHARG
                     PV_LIFNR
            CHANGING PV_LBLAB.

  RANGES : LR_CHA FOR MSLB-CHARG.


  CLEAR : PV_LBLAB.

  IF PV_CHARG IS NOT INITIAL.
    APPEND VALUE #( SIGN   = GC_I
                    OPTION = GC_EQ
                    LOW    = PV_CHARG ) TO LR_CHA.
  ENDIF.

* DATA(LV_LIFNR) = GT_LIFNR[ 1 ]-LIFNR.

  SELECT SUM( LBLAB )
    FROM MSLB INTO PV_LBLAB
   WHERE MATNR  = PV_MATNR
     AND WERKS  = PV_WERKS
     AND CHARG IN LR_CHA
     AND SOBKZ  = GC_O
     AND LIFNR  = PV_LIFNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CSTK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_CSTK.

  "재고 유효성 Check 추가(SJM 25.04.24)

  CLEAR : GT_MSG[].
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_CSTK.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_CSTK-MATNR
                              CHANGING GV_MATNR.

    CASE GT_CSTK-TYPE.
      WHEN 'L'.
        PERFORM CHK_CSTK_L.
      WHEN 'W'.
        PERFORM CHK_CSTK_W.
    ENDCASE.
  ENDLOOP.

  CHECK GT_MSG[] IS NOT INITIAL.

  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      XDOCNO_SHOW = 'X'
    TABLES
      XMSG        = GT_MSG.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_CSTK_MATNR
*&      <-- GV_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_IMATNR
                       CHANGING PV_OMATNR.

  CLEAR : PV_OMATNR.
  CHECK PV_IMATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_IMATNR
    IMPORTING
      OUTPUT = PV_OMATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> LV_MSG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_POP_MSG USING PV_MSGID
                       PV_MSGTY
                       PV_MSGNO
                       PV_MSGV1
                       PV_DOCNO
                       PV_DOCIT.

  CLEAR : GT_MSG.

  GT_MSG-MSGID = PV_MSGID.
  GT_MSG-MSGTY = PV_MSGTY.
  GT_MSG-MSGNO = PV_MSGNO.
  GT_MSG-MSGV1 = PV_MSGV1.
  GT_MSG-REFNO = PV_DOCNO.
  GT_MSG-REFIT = PV_DOCIT.
  APPEND GT_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CSTK_L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_CSTK_L.

  DATA(LV_MSG) = GV_MATNR && '/' && GT_CSTK-CHARG && '/' && GT_CSTK-LGORT.

  SELECT SINGLE XPCBT, CLABS
    FROM ZGTMM_CV_GETBATCHSTOCK
    INTO @DATA(LS_STK)
   WHERE WERKS = @GT_CSTK-WERKS
     AND LGORT = @GT_CSTK-LGORT
     AND MATNR = @GT_CSTK-MATNR
     AND CHARG = @GT_CSTK-CHARG.

  IF SY-SUBRC <> 0.
    PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '122' LV_MSG ' ' ' '. "재고가 없습니다. &
  ELSE.
    IF LS_STK-XPCBT = GC_X.  "단일 배치면 재고수량 = 출고수량
      IF LS_STK-CLABS <> GT_CSTK-MENGE.
        PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '136' LV_MSG ' ' ' '. "단일 배치 수량 차이가 있습니다. &
      ENDIF.
    ELSE.
      IF LS_STK-CLABS < GT_CSTK-MENGE.
        PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '098' LV_MSG ' ' ' '. "가용 재고가 부족합니다. &
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CSTK_W
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_CSTK_W.

  DATA(LV_MSG) = GV_MATNR && '/' && GT_CSTK-LGORT.

  SELECT SINGLE LABST
    FROM NSDM_E_MARD
    INTO @DATA(LV_LABST)
   WHERE WERKS = @GT_CSTK-WERKS
     AND LGORT = @GT_CSTK-LGORT
     AND MATNR = @GT_CSTK-MATNR.

  IF SY-SUBRC <> 0.
    PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '122' LV_MSG ' ' ' '. "재고가 없습니다. &
  ELSE.
    IF LV_LABST < GT_CSTK-MENGE.
      PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '098' LV_MSG ' ' ' '. "가용 재고가 부족합니다. &
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MB1B_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MB1B_HDR.

  CLEAR : GS_HDR.

  GS_HDR-LIFNR = VALUE #( GT_LIFNR[ 1 ]-LIFNR OPTIONAL ).
  PERFORM SET_LNAME USING GS_HDR-LIFNR
                 CHANGING GS_HDR-NAME1.

  GS_HDR-WERKS = P_WERKS.
* GS_HDR-LGORT = P_LGORT.
* PERFORM SET_LGOBE USING GS_HDR-WERKS
*                         GS_HDR-LGORT
*                CHANGING GS_HDR-LGOBE.

  PERFORM SET_BLOCK USING GS_HDR-LIFNR.

  "외주 업체 보증보험 금액 및 한도액 조회
  SELECT SINGLE PREIS,                 "보증금액
                TOTALSCVALUE AS SCVAL, "외주재고액
                APVALUE      AS APVAL, "당월IV금액
                WAERS                  "통화
    FROM ZGTMM_CV_SCSTOCKHEADER
    INTO CORRESPONDING FIELDS OF @GS_HDR
   WHERE BUKRS = @GV_BUKRS
     AND LIFNR = @GS_HDR-LIFNR.

  IF GS_HDR-WAERS IS INITIAL.
    SELECT SINGLE WAERS FROM T001
      INTO GS_HDR-WAERS WHERE BUKRS = GV_BUKRS.
  ENDIF.

  "출고예정액
  PERFORM CAL_ISVAL CHANGING GS_HDR-ISVAL.

  "가용금액 = 보증금액 - 외주재고액 - 출고예정액
  GS_HDR-IAVAL = GS_HDR-PREIS - GS_HDR-SCVAL - GS_HDR-ISVAL.

  "한도 예외 관리 업체 Check
  SELECT SINGLE MANDT
    FROM ZGTMMT4101 INTO @DATA(LV_MANDT)
   WHERE LIFNR = @GS_HDR-LIFNR.

  IF SY-SUBRC = 0.
    GS_HDR-XCPT = GC_X.
  ENDIF.

  PERFORM SET_QTEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HDR_LIFNR
*&      <-- GS_HDR_NAME1
*&---------------------------------------------------------------------*
FORM SET_LNAME USING PV_LIFNR
            CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM LFA1 INTO PV_NAME1
   WHERE LIFNR = PV_LIFNR
     AND LOEVM = SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HDR_LIFNR
*&---------------------------------------------------------------------*
FORM SET_BLOCK USING PV_LIFNR.

  "상신 Block 여부 조회

  CHECK PV_LIFNR IS NOT INITIAL.

  "Block Check Skip 대상 추가(SJM 25.06.10)
  SELECT SINGLE MANDT
    FROM ZGTPPT1010 INTO SY-MANDT
   WHERE MODULE_KIND = GC_MM
     AND CODEGRP     = GC_0400
     AND FLD_01      = P_WERKS.

  CHECK SY-SUBRC <> 0.

  SELECT SINGLE O~WERKS, W~NAME1,
                O~LGORT, L~LGOBE, N~NAME
    FROM ZGTMMT4110 AS O JOIN T001W AS W
      ON O~WERKS = W~WERKS
    JOIN T001L AS L
      ON O~WERKS = L~WERKS
     AND O~LGORT = L~LGORT
    LEFT JOIN ZGTMM_CV_GETUSERNAME AS N
      ON O~ERNAM = N~USERID
   WHERE O~BUKRS = @GV_BUKRS
     AND O~WERKS = @P_WERKS
     AND O~LIFNR = @PV_LIFNR
     AND ( O~APPSTAT = @SPACE
      OR ( O~APPSTAT = @GC_A AND O~MBLNR = @SPACE ) )
     AND O~LOEKZ = @SPACE
    INTO @DATA(LS_BLK).

  CHECK SY-SUBRC = 0.

  GS_HDR-BLOCK     = GC_X.
  GS_HDR-BLOCK_TXT = LS_BLK-NAME1 && ` / `
                  && LS_BLK-LGOBE && ` / `
                  && LS_BLK-NAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_ISVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_HDR_ISVAL
*&---------------------------------------------------------------------*
FORM CAL_ISVAL CHANGING PV_ISVAL.

  DATA : LT_MDSB LIKE GT_MDSB OCCURS 0 WITH HEADER LINE.
*        LV_NPRC TYPE NETPR.
*        LV_XPRC TYPE NETWR.


  "출고 예정금액 조회

  CLEAR : GT_MBEW[], GV_LPRC, GV_WPRC.

  LT_MDSB[] = GT_MDSB[].

  SORT LT_MDSB BY MATNR WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_MDSB COMPARING MATNR WERKS.

  CHECK LT_MDSB[] IS NOT INITIAL.

  "불출 자재의 평가 금액 조회
  SELECT MATNR, BWKEY, VPRSV, VERPR, STPRS, PEINH
    FROM MBEW
    INTO CORRESPONDING FIELDS OF TABLE @GT_MBEW
     FOR ALL ENTRIES IN @LT_MDSB
   WHERE MATNR = @LT_MDSB-MATNR
     AND BWKEY = @LT_MDSB-WERKS
     AND LVORM = @SPACE.

  SORT GT_MBEW BY MATNR BWKEY.

  "불출 금액 합산
  LOOP AT GT_MDSB.
    PERFORM CAL_XPRC USING GT_MDSB-MATNR
                           GT_MDSB-WERKS
                           GT_MDSB-MENGE
                  CHANGING GV_XPRC.

    CASE GT_MDSB-TYPE.
      WHEN 'L'.
        GV_LPRC = GV_LPRC + GV_XPRC.
      WHEN 'W'.
        GV_WPRC = GV_WPRC + GV_XPRC.
    ENDCASE.

*   MODIFY GT_MDSB TRANSPORTING XPRC.
  ENDLOOP.

  PV_ISVAL = GV_LPRC + GV_WPRC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_XPRC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_MATNR
*&      --> GT_MDSB_WERKS
*&      --> GT_MDSB_MENGE
*&      <-- GV_XPRC
*&---------------------------------------------------------------------*
FORM CAL_XPRC USING PV_MATNR
                    PV_WERKS
                    PV_MENGE
           CHANGING PV_PRICE.

  DATA : LV_NPRC TYPE NETPR.


  CLEAR : PV_PRICE.

  READ TABLE GT_MBEW WITH KEY MATNR = PV_MATNR
                              BWKEY = PV_WERKS
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LV_NPRC = SWITCH #( GT_MBEW-VPRSV WHEN 'S' THEN GT_MBEW-STPRS
                                             ELSE GT_MBEW-VERPR ).

  PV_PRICE = LV_NPRC * PV_MENGE / GT_MBEW-PEINH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_QTEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_QTEXT.

  CLEAR : GV_PRC.

  IF GS_HDR-BLOCK = GC_X.
    "메세지 변경(SJM 25.06.12)
    GS_HDR-QTEXT = GS_HDR-BLOCK_TXT
                && ' 님이 현재 한도 초과 불출 상신 중입니다. 승인 완료 및 출고 처리 후 후속 불출 가능합니다.'.
*               && ' 님이 현재 한도 초과 불출 상신 중입니다. 승인 완료 후 불출 가능합니다.'.
    GV_PRC       = GC_E.
  ELSE.
    IF GS_HDR-XCPT = GC_X.
      GS_HDR-QTEXT = '불출 처리 하시겠습니까?'.
      GV_PRC       = GC_O.
    ELSE.
      IF GS_HDR-IAVAL >= 0.
        GS_HDR-QTEXT = '불출 처리 하시겠습니까?'.
        GV_PRC       = GC_O.
      ELSE.
        GS_HDR-QTEXT = '한도 초과에 대한 불출 승인 후 반출이 가능합니다. 반출 승인 요청 하시겠습니까?'.
        GV_PRC       = GC_N.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VRM_SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_HDR_ORES
*&---------------------------------------------------------------------*
FORM VRM_SET_VALUES  USING PV_ID
                          PV_VAL.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = GT_LBOX.

  PV_VAL = VALUE #( GT_LBOX[ 1 ]-KEY OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_GIAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_GIAR.

  PERFORM CHECK_GIAR.
  CHECK GV_ERR IS INITIAL.

  CLEAR : GT_AHDR[], GT_AITM[], GT_ABAT[], GT_AHIS[].

  PERFORM SET_411X USING 'L' GV_LGUID GV_L_LAG.
  PERFORM SET_411X USING 'W' GV_WGUID GV_W_LAG.

* IF GT_AITM[] IS INITIAL.
*   MESSAGE S031(ZGTMM01) DISPLAY LIKE 'E'. "품의 진행할 내역이 없습니다.
*   EXIT.
* ENDIF.

  MODIFY ZGTMMT4114 FROM TABLE GT_AHIS.
  MODIFY ZGTMMT4112 FROM TABLE GT_ABAT.
  MODIFY ZGTMMT4111 FROM TABLE GT_AITM.
  MODIFY ZGTMMT4110 FROM TABLE GT_AHDR.

  IF SY-SUBRC = 0.
    COMMIT WORK.

*   PERFORM SET_BLOCK USING GS_HDR-LIFNR.

    PERFORM UPD_CAP_RST TABLES GT_MDSB_L  USING GV_LGUID 'L'.
    PERFORM UPD_CAP_RST TABLES GT_MDSB_W2 USING GV_WGUID 'W'.

    PERFORM SEND_MAIL.
    MESSAGE S042(ZGTMM01). "출고 품의 완료되었습니다.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S032(ZGTMM01) DISPLAY LIKE 'E'. "품의 진행에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_GIAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_GIAR.

  CLEAR : GV_ERR, GT_APPV[].

  "초과사유 기타(999)인 경우 비고 필수
  IF GS_HDR-ORES = GC_999  "기타
 AND GS_HDR-REMARK IS INITIAL.
    MESSAGE S082(ZGTMM01) DISPLAY LIKE 'E'. "기타인 경우, 비고는 필수 입력값입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  "승인 담당자 Setting 여부 Check
  PERFORM CHECK_APPV USING GV_L_LAG.
  IF GV_L_LAG <> GV_W_LAG.
    PERFORM CHECK_APPV USING GV_W_LAG.
  ENDIF.

* "입력값 Check
* LOOP AT GT_MDSB.
*   IF GT_MDSB-MENGE IS INITIAL.
*     MESSAGE S124(ZGTMM01) DISPLAY LIKE 'E'. "수량 입력은 필수입니다.
*     GV_ERR = GC_X. EXIT.
*   ENDIF.
*
*   IF GT_MDSB-XCHPF = GC_X AND GT_MDSB-CHARG IS INITIAL.
*     MESSAGE S125(ZGTMM01) DISPLAY LIKE 'E'. "배치 관리 자재는 배치 입력이 필수입니다.
*     GV_ERR = GC_X. EXIT.
*   ENDIF.
* ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_APPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_L_LAG
*&---------------------------------------------------------------------*
FORM CHECK_APPV USING PV_LGORT.

  CHECK GV_ERR   IS INITIAL.
  CHECK PV_LGORT IS NOT INITIAL. "추가(SJM 25.04.04)

  SELECT APPROVER1 AS APPV1,
         APPROVER2 AS APPV2
    FROM ZGTMMT4113
    INTO TABLE @DATA(LT_APPV)
   WHERE BUKRS = @GV_BUKRS
     AND WERKS = @P_WERKS
     AND LGORT = @PV_LGORT.

  IF LT_APPV IS INITIAL. "추가(SJM 25.04.03)
    MESSAGE S121(ZGTMM01) DISPLAY LIKE 'E'. "승인자 정보가 없습니다. 초과 불출 승인자를 먼저 등록하세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  LOOP AT LT_APPV INTO DATA(LS_APPV).
    IF LS_APPV-APPV1 IS INITIAL AND LS_APPV-APPV2 IS INITIAL.
      MESSAGE S121(ZGTMM01) DISPLAY LIKE 'E'. "승인자 정보가 없습니다. 초과 불출 승인자를 먼저 등록하세요.
      GV_ERR = GC_X. EXIT.
    ELSE.
      _SET_CON1 GT_APPV GT_APPV-USRID LS_APPV-APPV1.
      _SET_CON1 GT_APPV GT_APPV-USRID LS_APPV-APPV2.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_411X
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GV_LGUID
*&      --> GV_L_LAG
*&---------------------------------------------------------------------*
FORM SET_411X USING PV_TYPE
                    PV_GUID
                    PV_XLAG.

  CLEAR : PV_GUID.

  READ TABLE GT_MDSB WITH KEY TYPE = PV_TYPE.
  CHECK SY-SUBRC = 0.

  READ TABLE GT_MDSB WITH KEY MBLNR_F = GC_X.

  IF SY-SUBRC = 0.
    "출고반제품코드 & 은(는) 이미 재고이전이 되었습니다!!!
    MESSAGE W126(ZGTMM01) WITH GT_MDSB-MATNR.
  ELSE.
    PERFORM SET_AHDR USING PV_XLAG.
    PERFORM SET_AITM USING PV_TYPE.
    PERFORM SET_AHIS USING PV_TYPE.

    PV_GUID = GT_AHDR-ZGUID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TIMESTAMP USING PV_CREA
                         PV_CHNG.

  CLEAR : GS_CREA, GS_CHNG.

  IF PV_CREA = GC_X.
    PERFORM SET_TSTMP USING GS_CREA.
  ENDIF.

  IF PV_CHNG = GC_X.
    PERFORM SET_TSTMP USING GS_CHNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AHDR USING PV_XLAG.

  CLEAR : GT_AHDR.

  PERFORM CREATE_GUID CHANGING GT_AHDR-ZGUID.

  GT_AHDR-ZGITYPE = GC_E.           "초과불출유형
  GT_AHDR-BUKRS   = GV_BUKRS.       "회사코드
  GT_AHDR-WERKS   = P_WERKS.        "플랜트
  GT_AHDR-LGORT   = PV_XLAG.        "저장위치 GV_LGORT
  GT_AHDR-LIFNR   = GS_HDR-LIFNR.   "업체
  GT_AHDR-PREIS   = GS_HDR-PREIS.   "보증금액
  GT_AHDR-SCVAL   = GS_HDR-SCVAL.   "외주재고액
  GT_AHDR-ISVAL   = GS_HDR-ISVAL.   "출고예정액
  GT_AHDR-REVAL   = GS_HDR-IAVAL.   "출고가용액
  GT_AHDR-IVVAL   = GS_HDR-APVAL.   "당월IV 금액
  GT_AHDR-WAERS   = GS_HDR-WAERS.   "통화
  GT_AHDR-ORES    = GS_HDR-ORES.    "초과사유
  GT_AHDR-OETC    = GS_HDR-REMARK.  "비고

  PERFORM SET_TIMESTAMP USING 'X' 'X'.
  MOVE-CORRESPONDING GS_CREA TO GT_AHDR.
  MOVE-CORRESPONDING GS_CHNG TO GT_AHDR.

  APPEND GT_AHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_GUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_AHDR_ZGUID
*&---------------------------------------------------------------------*
FORM CREATE_GUID CHANGING PV_ZGUID.

  CLEAR : PV_ZGUID.
  PV_ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM SET_AITM USING PV_TYPE.

  LOOP AT GT_MDSB WHERE TYPE = PV_TYPE.
    PERFORM SET_ITM.
    PERFORM SET_BAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITM.

  CLEAR : GT_AITM.

  GT_AITM-ZGUID	= GT_AHDR-ZGUID.
  GT_AITM-MATNR = GT_MDSB-MATNR. "자재 번호
  GT_AITM-XCHPF = GT_MDSB-XCHPF. "배치 관리 필요 지시자
  GT_AITM-REQTY = GT_MDSB-MENGE. "총소요량
  GT_AITM-SCQTY = GT_MDSB-LBLAB. "외주재고량
  GT_AITM-NEQTY = GT_MDSB-MENGE. "필요량
  GT_AITM-SLQTY = GT_MDSB-LABST. "창고재고량
  GT_AITM-ISQTY = GT_MDSB-MENGE. "출하지시량
  GT_AITM-MEINS = GT_MDSB-MEINS. "기본 단위
  GT_AITM-WAERS = GS_HDR-WAERS.  "통화

  PERFORM CAL_XPRC USING GT_MDSB-MATNR
                         GT_MDSB-WERKS
                         GT_AITM-ISQTY
                CHANGING GT_AITM-ISVAL. "출하지시금액

  PERFORM CAL_XPRC USING GT_MDSB-MATNR
                         GT_MDSB-WERKS
                         GT_AITM-SCQTY
                CHANGING GT_AITM-SCVAL. "외주재고액

  COLLECT GT_AITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BAT.

  CLEAR : GT_ABAT.

  GT_ABAT-ZGUID = GT_AHDR-ZGUID.
  GT_ABAT-WERKS = GT_MDSB-WERKS. "플랜트
  GT_ABAT-MATNR = GT_MDSB-MATNR. "자재 번호
  GT_ABAT-CHARG = GT_MDSB-CHARG. "배치 번호
  GT_ABAT-TAGNR = GT_MDSB-TAGNR. "꼬리표번호
  GT_ABAT-ISQTY = GT_MDSB-MENGE. "출하지시량
  GT_ABAT-MEINS = GT_MDSB-MEINS. "기본 단위

  COLLECT GT_ABAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AHIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM SET_AHIS USING PV_TYPE.

* DATA : BEGIN OF LT_KEY OCCURS 0,
*          PSWRK LIKE ZGTMMT4114-PSWRK,
*          EBELN LIKE ZGTMMT4114-EBELN,
*          EBELP LIKE ZGTMMT4114-EBELP,
*          MATNR LIKE ZGTMMT4114-MATNR,
*          TAGNR LIKE ZGTMMT4114-TAGNR,
*          POSNR LIKE ZGTMMT4114-POSNR,
*        END   OF LT_KEY.

  DATA : LV_POSNR LIKE ZGTMMT4114-POSNR,
         LV_ZSEQ  LIKE ZGTMMT4114-ZSEQ.

  "배치 관리 사급자재 Key(ZSEQ) 추가(SJM 25.04.24)
  " ZGTMMT4114 Key 채번 로직 배치관리/미관리 통합화

  CASE PV_TYPE.
    WHEN 'L'.  "길이관리 사급자재
      PERFORM GET_4114_KEY TABLES GT_MDSB_L
                            USING 'L'.

      LOOP AT GT_MDSB_L.
        CHECK GT_MDSB_L-CHECK = GC_X.

        PERFORM SET_4114_KEY USING GT_MDSB_L-WERKS
                                   GT_MDSB_L-EBELN
                                   GT_MDSB_L-EBELP
                                   GT_MDSB_L-MATNR_C
                                   GT_MDSB_L-TAGNR
                                   GT_MDSB_L-POSNR
                                   GT_MDSB_L-CHARG 'L'
                          CHANGING LV_ZSEQ.

        CLEAR : GT_AHIS.
        MOVE-CORRESPONDING GT_MDSB_L TO GT_AHIS.
        MOVE-CORRESPONDING GS_CREA   TO GT_AHIS.
        GT_AHIS-PSWRK = GT_MDSB_L-WERKS.
        GT_AHIS-MATNR = GT_MDSB_L-MATNR_C.
        GT_AHIS-LOSSR = GT_EBAN-LOSSR.
        GT_AHIS-SCQTY = GT_MDSB_L-LBLAB.
        GT_AHIS-POSNR = GT_MDSB_L-POSNR.
        GT_AHIS-ZSEQ  = LV_ZSEQ.
*       GT_AHIS-MBLNR_F = 'X'.
        GT_AHIS-GUBUN = GC_L.
        GT_AHIS-ZGUID = GT_AHDR-ZGUID.

        APPEND GT_AHIS.
      ENDLOOP.

    WHEN 'W'.  "중량관리 사급자재
      PERFORM GET_4114_KEY TABLES GT_MDSB_W1
                            USING 'W'.

      LOOP AT GT_MDSB_W1.
        "중량관리 자재여도 이전전기 자재문서로 취소하기위해 insert

        LOOP AT GT_MDSB_W2 WHERE WERKS   = GT_MDSB_W1-WERKS
                             AND MATNR_C = GT_MDSB_W1-MATNR_C.

          CHECK GT_MDSB_W2-CHECK = GC_X.

          PERFORM SET_4114_KEY USING GT_MDSB_W1-WERKS
                                     GT_MDSB_W1-EBELN
                                     GT_MDSB_W1-EBELP
                                     GT_MDSB_W1-MATNR_C
                                     GT_MDSB_W2-TAGNR
                                     ' ' ' ' 'W'
                            CHANGING LV_POSNR.
*         LV_POSNR = LV_POSNR + 1.

          CLEAR : GT_AHIS.
          MOVE-CORRESPONDING GT_MDSB_W1 TO GT_AHIS.
          MOVE-CORRESPONDING GS_CREA    TO GT_AHIS.
          GT_AHIS-PSWRK = GT_MDSB_W1-WERKS.
          GT_AHIS-MATNR = GT_MDSB_W1-MATNR_C.
          GT_AHIS-LOSSR = GT_EBAN-LOSSR.
          GT_AHIS-BDMNG = GT_MDSB_W1-BDMNG_A.
          GT_AHIS-ENMNG = GT_MDSB_W2-ENMNG.
          GT_AHIS-SCQTY = GT_MDSB_W2-LBLAB.
          GT_AHIS-MEINS = GT_MDSB_W2-AUSME.
*         GT_AHIS-MBLNR = GT_MDSB_W2-MBLNR.
*         GT_AHIS-ZEILE = GT_MDSB_W2-ZEILE.
*         GT_AHIS-MJAHR = GT_MDSB_W2-MJAHR.
          GT_AHIS-LGORT = GT_MDSB_W2-LGORT.
          GT_AHIS-POSNR = LV_POSNR.
          GT_AHIS-TAGNR = GT_MDSB_W2-TAGNR.
          GT_AHIS-CHARG = GT_MDSB_W2-CHARG.
          GT_AHIS-MBLNR_F = SPACE.
          GT_AHIS-GUBUN = GC_W.
          GT_AHIS-ZGUID = GT_AHDR-ZGUID.

          APPEND GT_AHIS.
        ENDLOOP.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_4114_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_4114_KEY TABLES PT_MDSB
                   USING PV_TYPE.

  GT_KEY[] = CORRESPONDING #( PT_MDSB[] ).
  IF PV_TYPE = GC_L.
    DELETE GT_KEY WHERE CHECK <> GC_X.
  ENDIF.

  CHECK GT_KEY[] IS NOT INITIAL.

  SORT GT_KEY BY WERKS EBELN EBELP MATNR_C.
  DELETE ADJACENT DUPLICATES FROM GT_KEY COMPARING WERKS EBELN EBELP MATNR_C.

* SELECT MAX( POSNR ) INTO LV_POSNR
  SELECT PSWRK AS WERKS,
         EBELN,
         EBELP,
         MATNR AS MATNR_C,
         TAGNR,
         POSNR,
         CHARG,
         ZSEQ
    FROM ZGTMM_CV_ZGTMMT4114_MAX "변경(SJM 25.04.04) ZGTMMT4114
    INTO CORRESPONDING FIELDS OF TABLE @GT_KEY
     FOR ALL ENTRIES IN @GT_KEY
   WHERE PSWRK = @GT_KEY-WERKS
     AND EBELN = @GT_KEY-EBELN
     AND EBELP = @GT_KEY-EBELP
     AND MATNR = @GT_KEY-MATNR_C.

  CHECK GT_KEY[] IS NOT INITIAL.

  PERFORM SORT_4114_KEY USING PV_TYPE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SORT_4114_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM SORT_4114_KEY USING PV_TYPE.

  CASE PV_TYPE.
    WHEN 'L'.
      SORT GT_KEY BY WERKS   ASCENDING
                     EBELN   ASCENDING
                     EBELP   ASCENDING
                     MATNR_C ASCENDING
                     TAGNR   ASCENDING
                     POSNR   ASCENDING
                     CHARG   ASCENDING
                     ZSEQ    DESCENDING.
    WHEN 'W'.
      SORT GT_KEY BY WERKS   ASCENDING
                     EBELN   ASCENDING
                     EBELP   ASCENDING
                     MATNR_C ASCENDING
                     TAGNR   ASCENDING
                     POSNR   DESCENDING.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_4114_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L_WERKS
*&      --> GT_MDSB_L_EBELN
*&      --> GT_MDSB_L_EBELP
*&      --> GT_MDSB_L_MATNR_C
*&      --> GT_MDSB_L_TAGNR
*&      --> GT_MDSB_L_POSNR
*&      --> GT_MDSB_L_CHARG
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_4114_KEY USING PV_WERKS
                        PV_EBELN
                        PV_EBELP
                        PV_MATNR
                        PV_TAGNR
                        PV_POSNR
                        PV_CHARG
                        PV_TYPE
               CHANGING PV_KEY.

  DATA : LV_COND TYPE STRING.


  LV_COND = |     WERKS = PV_WERKS AND EBELN = PV_EBELN AND EBELP = PV_EBELP |
         && | AND TAGNR = PV_TAGNR AND MATNR_C = PV_MATNR |.

  IF PV_TYPE = GC_L.
    LV_COND = LV_COND && | AND POSNR = PV_POSNR AND CHARG = PV_CHARG |.
  ENDIF.

  CLEAR : GT_KEY, PV_KEY.
  LOOP AT GT_KEY WHERE (LV_COND).
*   DATA(LV_CHK) = GC_X.
    EXIT.
  ENDLOOP.

  IF GT_KEY IS INITIAL.
    GT_KEY-WERKS   = PV_WERKS.
    GT_KEY-EBELN   = PV_EBELN.
    GT_KEY-EBELP   = PV_EBELP.
    GT_KEY-MATNR_C = PV_MATNR.
    GT_KEY-TAGNR   = PV_TAGNR.

    IF PV_TYPE = GC_L.
      GT_KEY-POSNR = PV_POSNR.
      GT_KEY-CHARG = PV_CHARG.
    ENDIF.
  ENDIF.

  CASE PV_TYPE.
    WHEN 'L'.
      GT_KEY-ZSEQ = GT_KEY-ZSEQ + 1.
      PV_KEY = GT_KEY-ZSEQ.
    WHEN 'W'.
      GT_KEY-POSNR = GT_KEY-POSNR + 1.
      PV_KEY = GT_KEY-POSNR.
  ENDCASE.

  APPEND GT_KEY.

  PERFORM SORT_4114_KEY USING PV_TYPE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL.

  DATA : LV_CHK,
         LV_MSG(100).


  PERFORM GET_EMAIL.
  CHECK GT_APPV[] IS NOT INITIAL.

  CLEAR : GV_TEXT, GT_MTXT.

  GV_TEXT = '[사급자재불출]사급자재 보증 금액 초과 불출에 대한 승인 요청'.

  "메일 본문에 Plant 정보 추가(SJM 25.05.22)
  GT_MTXT[] = VALUE #( ( LINE = `Plant ` && P_WERKS && '의 사급자재 보증 금액 초과 불출이 필요합니다.' )
                       ( LINE = '내용 확인 후 승인 요청드립니다.' )
                       ( LINE = 'T-Code ZGTMMR4110에서 상세 확인하세요.' ) ).

  LOOP AT GT_APPV.
    CALL FUNCTION 'Z_MM_SEND_MAIL'
      EXPORTING
        I_UNAME     = CONV SYST_UNAME( GT_APPV-USRID )
        I_EMAIL     = CONV AD_SMTPADR( GT_APPV-EMAIL )
        I_HEAD_TEXT = GV_TEXT
      IMPORTING
        E_RETURN    = LV_CHK
        E_MESSAGE   = LV_MSG
      TABLES
        T_MSG       = GT_MTXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EMAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EMAIL.

  CHECK GT_APPV[] IS NOT INITIAL.
  SORT GT_APPV BY USRID.

  SELECT USERID AS USRID,
         EMAIL
    FROM ZGTMM_CV_GETUSERNAME "ZGTMM_CV_GETAPUSERLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_APPV
     FOR ALL ENTRIES IN @GT_APPV
   WHERE USERID = @GT_APPV-USRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_4110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_4110.

  DELETE GT_PO WHERE EBELN IS INITIAL.
  CHECK GT_PO[] IS NOT INITIAL.

  SORT GT_PO BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM GT_PO COMPARING EBELN EBELP.

  SELECT S~EBELN,
         S~EBELP,
         S~MATNR,
*        S~TAGNR,
         S~POSNR,
         S~GUBUN,
         S~BDMNG,
         S~ENMNG,
         S~LGORT,
         S~CHARG,
         S~ZSEQ,
         S~LOTNO,
         S~TAGNR,
         S~MBLNR,
         S~MJAHR,
         H~ZGUID,
         H~APPSTAT
    FROM ZGTMM_CV_ZGTMMT4114_MAX AS S "변경(SJM 25.04.04) ZGTMMT4114
    JOIN ZGTMMT4110 AS H
      ON S~ZGUID = H~ZGUID
     FOR ALL ENTRIES IN @GT_PO
   WHERE S~EBELN = @GT_PO-EBELN
     AND S~EBELP = @GT_PO-EBELP
*    AND H~MBLNR = @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_PO.

* SORT GT_PO BY GUBUN EBELN EBELP MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_4110_EBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_4110_EBAN.

  PERFORM SET_4110 USING GT_EBAN-EBELN
                         GT_EBAN-EBELP 'L'
                CHANGING GT_EBAN-STATS_L
                         GT_EBAN-ZGUID_L.

  PERFORM SET_4110 USING GT_EBAN-EBELN
                         GT_EBAN-EBELP 'W'
                CHANGING GT_EBAN-STATS_W
                         GT_EBAN-ZGUID_W.

* GT_EBAN-ZGUID = GT_EBAN-ZGUID_L && GT_EBAN-ZGUID_W.

  "상신 중 or 승인/반려 선택시 W,L 중 하나라도 존재하면 조회(SJM 25.03.25)
  CLEAR : GV_DEL.

  CASE 'X'.
    WHEN P_SBM.
      IF GT_EBAN-STATS_L <> ICON_MAIL
     AND GT_EBAN-STATS_W <> ICON_MAIL.
        GV_DEL = GC_X.
      ENDIF.

    WHEN P_APV.
      IF GT_EBAN-STATS_L <> ICON_ALLOW
     AND GT_EBAN-STATS_L <> ICON_REJECT
     AND GT_EBAN-STATS_W <> ICON_ALLOW
     AND GT_EBAN-STATS_W <> ICON_REJECT.
        GV_DEL = GC_X.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_4110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EBAN_EBELN
*&      --> GT_EBAN_EBELP
*&      --> P_
*&      <-- GT_EBAN_STATS_L
*&      <-- GT_EBAN_ZGUID_L
*&---------------------------------------------------------------------*
FORM SET_4110 USING PV_EBELN
                    PV_EBELP
                    PV_GUBUN
           CHANGING PV_STATS
                    PV_ZGUID.

  CLEAR : PV_STATS, PV_ZGUID.
  CHECK PV_EBELN IS NOT INITIAL.

  READ TABLE GT_PO WITH KEY GUBUN = PV_GUBUN
                            EBELN = PV_EBELN
                            EBELP = PV_EBELP
                            BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  PERFORM SET_STATS_ZGUID USING GT_PO-APPSTAT
                                GT_PO-ZGUID
                       CHANGING PV_STATS
                                PV_ZGUID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STATS_ZGUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_PO_APPSTAT
*&      --> GT_PO-ZGUID
*&      <-- PV_STATS
*&      <-- PV_ZGUID
*&---------------------------------------------------------------------*
FORM SET_STATS_ZGUID USING PV_APPSTAT
                           PV_PGUID
                  CHANGING PV_STATS
                           PV_ZGUID.

  PV_STATS = SWITCH #( PV_APPSTAT WHEN ' ' THEN ICON_MAIL
                                  WHEN 'A' THEN ICON_ALLOW
                                  WHEN 'R' THEN ICON_REJECT ).

  PV_ZGUID = SWITCH #( PV_APPSTAT WHEN 'R' THEN ' '
                                           ELSE PV_PGUID ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_4114
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L_EBELN
*&      --> GT_MDSB_L_EBELP
*&      --> GT_MDSB_L_MATNR_C
*&      --> GT_MDSB_W2-TAGNR
*&      --> P_
*&      <-- GT_MDSB_L
*&---------------------------------------------------------------------*
FORM SET_4114 USING PV_EBELN
                    PV_EBELP
                    PV_MATNR
                    PV_TAGNR  "추가(SJM 25.05.12)
                    PV_GUBUN
           CHANGING PS_MDSB.

  DATA : BEGIN OF LS_COM,
           STATS    LIKE ICON-ID,
           ZGUID    LIKE ZGTMMT4110-ZGUID,
           LGORT    LIKE ZGTMMT4114-LGORT,
           CHARG    LIKE ZGTMMT4114-CHARG,
           TAGNR    LIKE ZGTMMT4114-TAGNR,

           MBLNR    LIKE ZGTMMT4114-MBLNR, "(S)추가(SJM 25.05.13)
           MJAHR    LIKE ZGTMMT4114-MJAHR,
           MBLNR_F,
           FLAG1(4),                       "(E)추가(SJM 25.05.13)
         END   OF LS_COM.

  FIELD-SYMBOLS : <LFS_MENGE>,
                  <LFS_LOTNO>.
*                 <LFS_TAGNR>.


  CHECK PV_EBELN IS NOT INITIAL.

  READ TABLE GT_PO WITH KEY GUBUN = PV_GUBUN
                            EBELN = PV_EBELN
                            EBELP = PV_EBELP
                            MATNR = PV_MATNR
                            TAGNR = PV_TAGNR  "추가(SJM 25.05.12)
                            BINARY SEARCH.

  CHECK SY-SUBRC = 0.
  DATA(LV_TBX) = SY-TABIX.

  PERFORM SET_STATS_ZGUID USING GT_PO-APPSTAT
                                GT_PO-ZGUID
                       CHANGING LS_COM-STATS
                                LS_COM-ZGUID.

  LS_COM-LGORT = GT_PO-LGORT.
  LS_COM-CHARG = GT_PO-CHARG.
  LS_COM-TAGNR = GT_PO-TAGNR.

  LS_COM-MBLNR = GT_PO-MBLNR.        "(S)추가(SJM 25.05.13)
  LS_COM-MJAHR = GT_PO-MJAHR.

  IF GT_PO-MBLNR IS NOT INITIAL.
    LS_COM-MBLNR_F = GC_X.
    LS_COM-FLAG1   = ICON_LED_GREEN.
  ENDIF.                             "(E)추가(SJM 25.05.13)

  MOVE-CORRESPONDING LS_COM TO PS_MDSB.

  PERFORM GET_DOC_INFO USING PS_MDSB. "추가(SJM 25.06.11)

  CASE PV_GUBUN.
    WHEN 'L'. "로직 변경으로 미사용~
      ASSIGN COMPONENT 'BDMNG' OF STRUCTURE PS_MDSB TO <LFS_MENGE>.

      <LFS_MENGE> = GT_PO-BDMNG.

    WHEN 'W'.
      ASSIGN COMPONENT 'ENMNG' OF STRUCTURE PS_MDSB TO <LFS_MENGE>.
      ASSIGN COMPONENT 'LOTNO' OF STRUCTURE PS_MDSB TO <LFS_LOTNO>.
*     ASSIGN COMPONENT 'TAGNR' OF STRUCTURE PS_MDSB TO <LFS_TAGNR>.

*     <LFS_MENGE> = GT_PO-ENMNG.
*     <LFS_MENGE> = REDUCE DMBTR_CS( INIT X = CONV ENMNG( 0 )
*                                     FOR LS_PO IN GT_PO
*                                   WHERE ( GUBUN = PV_GUBUN
*                                       AND EBELN = PV_EBELN
*                                       AND EBELP = PV_EBELP
*                                       AND MATNR = PV_MATNR )
*                                    NEXT X = X + LS_PO-ENMNG ).
      CLEAR : <LFS_MENGE>.
      <LFS_LOTNO> = GT_PO-LOTNO.
*     <LFS_TAGNR> = GT_PO-TAGNR.

      LOOP AT GT_PO FROM LV_TBX.
        IF NOT ( GT_PO-GUBUN = PV_GUBUN
             AND GT_PO-EBELN = PV_EBELN
             AND GT_PO-EBELP = PV_EBELP
             AND GT_PO-MATNR = PV_MATNR
             AND GT_PO-TAGNR = PV_TAGNR ). "추가(SJM 25.05.12)
          EXIT.
        ENDIF.

        <LFS_MENGE> = <LFS_MENGE> + GT_PO-ENMNG.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_CHECK_LW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&---------------------------------------------------------------------*
FORM RESET_CHECK_LW USING PV_VAL.

  "최초 검색 List 화면에서 선택 라인의 'ZGUID_L'/'ZGUID_W'의 값을 가진 라인은
  "모두 일괄 자동 선택/취소(SJM 25.04.01)

  CLEAR : GR_GUID[].

  DATA(LV_LGUID) = GT_EBAN-ZGUID_L.
  DATA(LV_WGUID) = GT_EBAN-ZGUID_W.

  LOOP AT GT_EBAN.
    IF LV_LGUID IS INITIAL AND LV_WGUID IS INITIAL.
      IF GT_EBAN-ZGUID_L IS NOT INITIAL
      OR GT_EBAN-ZGUID_W IS NOT INITIAL.
        CLEAR : GT_EBAN-CHECK.
      ENDIF.
    ELSE.
      IF GT_EBAN-ZGUID_L IS INITIAL
     AND GT_EBAN-ZGUID_W IS INITIAL.
        CLEAR : GT_EBAN-CHECK.
      ENDIF.

      IF ( LV_LGUID <> SPACE AND LV_LGUID = GT_EBAN-ZGUID_L )
      OR ( LV_WGUID <> SPACE AND LV_WGUID = GT_EBAN-ZGUID_W ).
        GT_EBAN-CHECK = PV_VAL.

        _COL_RNG GR_GUID GT_EBAN-ZGUID_L.
        _COL_RNG GR_GUID GT_EBAN-ZGUID_W.
      ENDIF.
    ENDIF.

    MODIFY GT_EBAN TRANSPORTING CHECK.
  ENDLOOP.

  "선택라인의 조건을 만족하는 타라인에서 추가적인 ZGUID이 발생할 수 있으므로
  "최종 선택이 누락되는 케이스 발생하여 한 번 더 Check
  LOOP AT GR_GUID.
    GT_EBAN-CHECK = PV_VAL.
    MODIFY GT_EBAN TRANSPORTING CHECK
     WHERE ZGUID_L = GR_GUID-LOW
        OR ZGUID_W = GR_GUID-LOW.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EBAN
*&      --> GT_EBAN-ZGUID
*&      --> LS_MOD_CELLS-VALUE
*&---------------------------------------------------------------------*
FORM RESET_CHECK TABLES PT_LIST
                  USING PV_GUID
                        PV_VAL.

  DATA : LV_GUID TYPE GUID_32.


  "라인 선택시 'ZGUID'가 동일한 라인은 모두 일괄 자동 선택
  "'ZGUID'가 다른 라인이 이미 선택된 경우 기존 라인 선택 자동 해제 및 신규 GUID에 대한 일괄 자동 선택
  "선택 취소시에도 일괄 처리되도록..(SJM 25.03.25)

  CHECK PV_GUID IS NOT INITIAL.
  LV_GUID = PV_GUID.

  LOOP AT PT_LIST.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE PT_LIST TO FIELD-SYMBOL(<LFS_CHK>).
    ASSIGN COMPONENT 'ZGUID' OF STRUCTURE PT_LIST TO FIELD-SYMBOL(<LFS_GUID>).

    CHECK <LFS_CHK> <> '-'. "중복 라인이 아닐때(Only 'L') "추가(SJM 25.04.03)

    CLEAR : <LFS_CHK>.
    IF <LFS_GUID> = LV_GUID.
      <LFS_CHK> = PV_VAL.
    ENDIF.

    MODIFY PT_LIST TRANSPORTING ('CHECK').
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTMMT4110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L_ZGUID
*&      --> GT_MDSB_L_MBLNR
*&      --> GT_MDSB_L_MJAHR
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTMMT4110 USING PV_ZGUID
                             PV_MBLNR
                             PV_MJAHR.

  CHECK PV_ZGUID IS NOT INITIAL.

  UPDATE ZGTMMT4110 SET MBLNR = PV_MBLNR
                        MJAHR = PV_MJAHR
                  WHERE ZGUID = PV_ZGUID.

  UPDATE ZGTMMT4114 SET MBLNR   = PV_MBLNR
                        MJAHR   = PV_MJAHR
                        MBLNR_F = GC_X
                  WHERE ZGUID   = PV_ZGUID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L_LGORT
*&      --> GT_MDSB_L_MBLNR
*&      --> GT_MDSB_L_MJAHR
*&---------------------------------------------------------------------*
FORM SET_WIF USING PV_LGORT
                   PV_MBLNR
                   PV_MJAHR.

  CLEAR : GT_WIF.

  GT_WIF-LGORT = PV_LGORT.
  GT_WIF-MBLNR = PV_MBLNR.
  GT_WIF-MJAHR = PV_MJAHR.

  COLLECT GT_WIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_WMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_WMS.

  RANGES : LR_MJAHR FOR MKPF-MJAHR,
           LR_MBLNR FOR MKPF-MBLNR.


  "출고(취소) 처리후, 출고(취소)정보 전송 대상 저장위치(WMS 활용 저장위치)인 경우 I/F

  CHECK GT_WIF[] IS NOT INITIAL.
  SORT GT_WIF BY LGORT MBLNR.

  LOOP AT GT_WIF.
    SELECT SINGLE ZMODE
      FROM ZGTMMT4100 INTO @DATA(LV_ZMODE)
     WHERE BUKRS = @G_BUKRS
       AND WERKS = @P_WERKS
       AND LGORT = @GT_WIF-LGORT.

    CHECK LV_ZMODE = GC_OD.

    LR_MJAHR[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GT_WIF-MJAHR ) ).
    LR_MBLNR[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GT_WIF-MBLNR ) ).

    SUBMIT ZGTMMR4917 WITH P_ILOG   = SPACE
                      WITH P_SEND   = GC_X
                      WITH P_IFSYT  = GC_KPCM
                      WITH S_MJAHR IN LR_MJAHR
                      WITH S_MBLNR IN LR_MBLNR
                      WITH P_BAT    = GC_X
                       AND RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_STK_W2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM RESET_STK_W2 USING PV_TYPE.

  "재고 로직 기준 변경(SJM 25.05.13)
  " 꼬리표별 추가 쪼개짐에 따라, 라인별 계산은 불일치하므로 DB 조회로 변경

  PERFORM SUM_LABST USING GT_MDSB_W2-MATNR_C
                          GT_MDSB_W2-WERKS
                          GT_MDSB_W2-LGORT
                 CHANGING GT_MDSB_W2-LABST. "현재고(Plant)

  PERFORM SUM_LBLAB USING GT_MDSB_W2-MATNR_C
                          GT_MDSB_W2-WERKS
                          ' '
                          GT_MDSB_W2-LIFNR
                 CHANGING GT_MDSB_W2-LBLAB. "현재고(SC업체)

* CASE PV_TYPE.
*   WHEN 'Y'.
*     GT_MDSB_W2-LABST = GT_MDSB_W2-LABST - GT_MDSB_W2-ENMNG.
*     GT_MDSB_W2-LBLAB = GT_MDSB_W2-LBLAB + GT_MDSB_W2-ENMNG.
*
*   WHEN 'N'.
*     GT_MDSB_W2-LABST = GT_MDSB_W2-LABST + GT_MDSB_W2-ENMNG.
*     GT_MDSB_W2-LBLAB = GT_MDSB_W2-LBLAB - GT_MDSB_W2-ENMNG.
*
* ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCAP.

  PERFORM CHECK_CCAP.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM_STEP USING 'N' ' '
                                      '상신 취소 하시겠습니까?'
                                      '상신 취소'.

  CHECK GV_ANSWER = GC_J.

  PERFORM PRCS_YCAP.

  PERFORM REFRESH_GT_MDSB_L_DISPLAY.
  PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CCAP.

  CLEAR : GV_ERR, GV_COND, GR_GUID[].

  PERFORM CHECK_CAP TABLES GT_MDSB_L.
  PERFORM CHECK_CAP TABLES GT_MDSB_W2.
  CHECK GV_ERR IS INITIAL.

*  LOOP AT GT_MDSB_L WHERE CHECK = GC_X.
*    PERFORM CHECK_CAP USING GT_MDSB_L-STATS_L
*                            GT_MDSB_L-MBLNR.
*    _SET_CON1 GT_GUID GT_GUID-ZGUID GT_MDSB_L-ZGUID_L.
*  ENDLOOP.
*
*  LOOP AT GT_MDSB_W2 WHERE CHECK = GC_X.
*    _SET_CON1 GT_GUID GT_GUID-ZGUID GT_MDSB_W2-ZGUID_W.
*  ENDLOOP.

  IF GR_GUID[] IS INITIAL.
    MESSAGE S127(ZGTMM01) DISPLAY LIKE 'E'. "상신 취소할 데이터가 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  SORT GR_GUID BY LOW.
  DELETE ADJACENT DUPLICATES FROM GR_GUID COMPARING LOW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&---------------------------------------------------------------------*
FORM CHECK_CAP TABLES PT_MDSB.

  CHECK GV_ERR IS INITIAL.

  GV_COND = | CHECK = GC_X AND ZGUID <> SPACE |.

  LOOP AT PT_MDSB WHERE (GV_COND).
    MOVE-CORRESPONDING PT_MDSB TO GS_CAP.

    IF ( GS_CAP-STATS = ICON_ALLOW  AND GS_CAP-MBLNR IS NOT INITIAL )
    OR ( GS_CAP-STATS = ICON_REJECT ).
      MESSAGE S038(ZGTMM01) DISPLAY LIKE 'E'. "반려된 상신 및 이미 출고 처리된 품의 정보는 취소할 수 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    CHECK GS_CAP-ZGUID IS NOT INITIAL.
    APPEND VALUE #( SIGN   = GC_I
                    OPTION = GC_EQ
                    LOW    = GS_CAP-ZGUID ) TO GR_GUID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YCAP.

  DELETE FROM ZGTMMT4114 WHERE ZGUID IN GR_GUID.
  DELETE FROM ZGTMMT4112 WHERE ZGUID IN GR_GUID.
  DELETE FROM ZGTMMT4111 WHERE ZGUID IN GR_GUID.
  DELETE FROM ZGTMMT4110 WHERE ZGUID IN GR_GUID.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM UPD_CAP_RST TABLES GT_MDSB_L  USING ' ' 'L'.
    PERFORM UPD_CAP_RST TABLES GT_MDSB_W2 USING ' ' 'W'.

    MESSAGE S036(ZGTMM01) WITH '상신 취소'. "& 성공했습니다.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S037(ZGTMM01) WITH '상신 취소' DISPLAY LIKE 'E'. "& 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPD_CAP_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&      --> GV_LGUID
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPD_CAP_RST TABLES PT_MDSB
                  USING PV_GUID
                        PV_TYPE.

* DATA : LV_COND TYPE STRING.


  CHECK PT_MDSB[] IS NOT INITIAL.

  CLEAR : GS_CAP.

  IF PV_GUID IS NOT INITIAL.
    GS_CAP-STATS = ICON_MAIL.
    GS_CAP-ZGUID = PV_GUID.
* ELSE.
*   PERFORM CLEAR_MDOC USING PT_MDSB PV_TYPE.
  ENDIF.

  PERFORM MDF_CAP_RST TABLES PT_MDSB
                       USING GV_COND
                             PV_TYPE.

* "취소시 멀티 라인일 경우 선택된 라인만 결과 반영되는 경우가 있어, ZGUID가 동일한 나머지 라인도 한 번 더 처리
* "멀티 라인 자동 선택이 자재문서가 취소되면서 풀리는 경우 발생하는데.. 항상 발생하는 케이스는 아닌듯..
* IF PV_GUID IS INITIAL.
*   LV_COND = | ZGUID IN GR_GUID |.
*   PERFORM MDF_CAP_RST TABLES PT_MDSB
*                        USING LV_COND
*                              PV_TYPE.
* ENDIF.

* MOVE-CORRESPONDING GS_CAP TO PT_MDSB.
* PERFORM CLEAR_MDOC USING PT_MDSB PV_TYPE.
*
* MODIFY PT_MDSB TRANSPORTING ('STATS') ('ZGUID') ('BDMNG') ('ENMNG')
*                             ('LOTNO') ('CHARG') ('TAGNR') ('LGORT')
*                       WHERE (GV_COND).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MDF_CAP_RST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MDSB
*&      --> GV_COND
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM MDF_CAP_RST TABLES PT_MDSB
                  USING PV_COND
                        PV_TYPE.

  LOOP AT PT_MDSB WHERE (PV_COND).
    MOVE-CORRESPONDING GS_CAP TO PT_MDSB.
    PERFORM CLEAR_MDOC USING PT_MDSB PV_TYPE.

    MODIFY PT_MDSB TRANSPORTING ('STATS') ('ZGUID') ('BDMNG') ('ENMNG')
                                ('LOTNO') ('CHARG') ('TAGNR') ('LGORT').
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTMMT411X
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L_MBLNR
*&      --> GT_MDSB_L_MJAHR
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTMMT411X USING PV_MBLNR
                             PV_MJAHR
                             PV_TYPE.

* CHECK PV_ZGUID IS NOT INITIAL.

  UPDATE ZGTMMT4110 SET MJAHR = SPACE
                        MBLNR = SPACE
                  WHERE MBLNR = PV_MBLNR
                    AND MJAHR = PV_MJAHR.

  CHECK SY-SUBRC = 0.

  CASE PV_TYPE.
    WHEN 'L'.
      "기존 ZPPT0018 처리 로직 변경(SJM 25.04.01): DELETE->UPDATE
      UPDATE ZGTMMT4114 SET MBLNR   = SPACE
                            MJAHR   = SPACE
                            MBLNR_F = SPACE
                      WHERE MBLNR   = PV_MBLNR
                        AND MJAHR   = PV_MJAHR.
*     DELETE FROM ZGTMMT4114 WHERE MBLNR = PV_MBLNR
*                              AND MJAHR = PV_MJAHR.

    WHEN 'W'.
      "기존 ZPPT0018 처리 로직 변경(SJM 25.04.18): 자재문서만 Clear 처리
      UPDATE ZGTMMT4114 SET MBLNR   = SPACE
                            MBLNR_F = SPACE
                            MJAHR   = SPACE
                      WHERE MBLNR   = PV_MBLNR
                        AND MJAHR   = PV_MJAHR.
*     UPDATE ZGTMMT4114 SET ENMNG   = SPACE
*                           MEINS   = SPACE
*                           MBLNR   = SPACE
*                           MBLNR_F = SPACE
*                           MJAHR   = SPACE
*                           LOTNO   = SPACE
*                           SCQTY   = SPACE
*                     WHERE MBLNR   = PV_MBLNR
*                       AND MJAHR   = PV_MJAHR.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_MDOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&      --> P_
*&---------------------------------------------------------------------*
FORM CLEAR_MDOC USING PS_MDSB
                      PV_TYPE.

  DATA : BEGIN OF LS_COM,
           CHARG LIKE MDSB-CHARG,
           TAGNR LIKE ZPPT0011-TAGNR,
           LGORT LIKE MDSB-LGORT,
         END   OF LS_COM.


  ASSIGN COMPONENT 'ZGUID' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_ZGUID>).
  CHECK <LFS_ZGUID> IS INITIAL.

  DATA(LV_MENGE) = SWITCH #( PV_TYPE WHEN 'L' THEN 'BDMNG'
                                     WHEN 'W' THEN 'ENMNG' ).

  ASSIGN COMPONENT LV_MENGE OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MENGE>).
  CLEAR : <LFS_MENGE>.

  MOVE-CORRESPONDING LS_COM TO PS_MDSB.

  IF PV_TYPE = GC_W.
    ASSIGN COMPONENT 'LOTNO' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_LOTNO>).
    CLEAR : <LFS_LOTNO>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_POX.

  GT_POL[] = GT_POW[] = GT_PO[].
  DELETE GT_POL WHERE GUBUN <> GC_L.
  DELETE GT_POW WHERE GUBUN <> GC_W.

  SORT GT_POL BY GUBUN MBLNR EBELN EBELP        "추가(SJM 25.05.13)
                 MATNR POSNR TAGNR CHARG ZSEQ.  "추가(SJM 25.04.23)

  SORT GT_POW BY GUBUN EBELN EBELP MATNR TAGNR. "추가(SJM 25.05.12)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_POL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_POL.

  "자재문서가 아직 생성되지 않은 승인 진행건 or 행복사로 쪼개져 ZPPT0018에 저장되지 못한건 추가(SJM 25.05.13)

  CHECK GT_POL[] IS NOT INITIAL.

  LOOP AT GT_EBAN WHERE CHECK = GC_X.
    LOOP AT GT_POL WHERE EBELN = GT_EBAN-EBELN
                     AND EBELP = GT_EBAN-EBELP.

      CLEAR : GT_MDSB_L3, GT_MDSB_L.

      READ TABLE GT_MDSB_L3 WITH KEY EBELN   = GT_POL-EBELN
                                     EBELP   = GT_POL-EBELP
                                     MATNR_C = GT_POL-MATNR
                                     POSNR   = GT_POL-POSNR.

      MOVE-CORRESPONDING GT_MDSB_L3 TO GT_MDSB_L.

      IF GT_POL-MBLNR IS INITIAL.
        CLEAR : GT_MDSB_L-IV_NO,   GT_MDSB_L-MBLNR,       GT_MDSB_L-MJAHR,
                GT_MDSB_L-ZEILE,   GT_MDSB_L-BUDAT,       GT_MDSB_L-CPUDT,
                GT_MDSB_L-IV_DATE, GT_MDSB_L-IV_PRINT_YN, GT_MDSB_L-OUT_YN,
                GT_MDSB_L-MBLNR_F, GT_MDSB_L-FLAG1,       GT_MDSB_L-FLAG2.
      ELSE.
        GT_MDSB_L-MBLNR = GT_POL-MBLNR.
        GT_MDSB_L-MJAHR = GT_POL-MJAHR.

        PERFORM GET_DOC_INFO USING GT_MDSB_L.
      ENDIF.

      GT_MDSB_L-BDMNG = GT_POL-BDMNG.
      GT_MDSB_L-CHARG = GT_POL-CHARG.
      GT_MDSB_L-TAGNR = GT_POL-TAGNR.
      GT_MDSB_L-LGORT = GT_POL-LGORT.

      PERFORM SET_STATS_ZGUID USING GT_POL-APPSTAT
                                    GT_POL-ZGUID
                           CHANGING GT_MDSB_L-STATS
                                    GT_MDSB_L-ZGUID.

      APPEND GT_MDSB_L.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DOC_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MDSB_L
*&---------------------------------------------------------------------*
FORM GET_DOC_INFO USING PS_MDSB.

  DATA : BEGIN OF LS_DOC,
*          MBLNR       LIKE MKPF-MBLNR,           "자재문서
*          MJAHR       LIKE MKPF-MJAHR,           "자재문서년도
           ZEILE       LIKE MSEG-ZEILE,           "자재문서 품목 번호
           BUDAT       LIKE MKPF-BUDAT,           "전표의 전기일
           CPUDT       LIKE MKPF-CPUDT,           "회계전표 입력일

           IV_NO       LIKE ZLET0005-IV_NO,       "통문번호
           IV_DATE     LIKE ZLET0005-IV_DATE,     "통문증발행일
           IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
           OUT_YN      LIKE ZLET0005-OUT_YN,      "통문여부
           MBLNR_F,                               "이전전기여부
           FLAG1(4),                              "이전전기여부(ICON)
           FLAG2(4),                              "통문증발행여부(ICON)
         END   OF LS_DOC.


  CLEAR : LS_DOC.

  ASSIGN COMPONENT 'MBLNR' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MBLNR>).
  ASSIGN COMPONENT 'MJAHR' OF STRUCTURE PS_MDSB TO FIELD-SYMBOL(<LFS_MJAHR>).

* CHECK <LFS_MBLNR> IS NOT INITIAL.
  IF <LFS_MBLNR> IS INITIAL.
    MOVE-CORRESPONDING LS_DOC TO PS_MDSB.
    EXIT.
  ENDIF.

  "자재문서 정보
  SELECT SINGLE BUDAT CPUDT
    FROM MKPF
    INTO CORRESPONDING FIELDS OF LS_DOC
   WHERE MBLNR = <LFS_MBLNR>
     AND MJAHR = <LFS_MJAHR>.

  "통문 정보
  SELECT SINGLE B~IV_NO B~IV_DATE B~IV_PRINT_YN B~OUT_YN
    FROM ZLET0006 AS A INNER JOIN ZLET0005 AS B
      ON A~IV_NO = B~IV_NO
    INTO CORRESPONDING FIELDS OF LS_DOC
   WHERE A~MBLNR        = <LFS_MBLNR>
     AND A~MJAHR        = <LFS_MJAHR>
     AND B~IV_CANCEL_YN = SPACE.

  "이전전기 및 통문증 발행 여부
  LS_DOC-MBLNR_F = GC_X.
  LS_DOC-FLAG1   = ICON_LED_GREEN.

  IF LS_DOC-IV_PRINT_YN = GC_X.
    LS_DOC-FLAG2 = ICON_LED_GREEN.
  ENDIF.

  MOVE-CORRESPONDING LS_DOC TO PS_MDSB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_L_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_L_LIST.

  "배치 관리 사급자재일 때, 라인이 쪼개지는 경우(행 복사) 라인 재구성(SJM 25.04.23)
  " 승인이 필요한 케이스인 경우, 자재문서 생성전까지는 ZPPT0018에 값이 들어가지 않으므로
  " 쪼개진 라인 정보를 ZGTMMT4114에서 가져와 다시 구성하는 작업 필요

  "승인 프로세스 적용전 이미 자재문서가 일부 생성된 케이스의 경우, ~POSNR 중복으로 인하여 라인이
  "지속적으로 쪼개지면 구분이 모호해 지므로.. '자재문서' 조건을 추가함.(SJM 25.05.13)

* DATA : LV_COND TYPE STRING.


  CLEAR : GV_RES.

  READ TABLE GT_POL WITH KEY GUBUN = GC_L
                             MBLNR = GT_MDSB_L3-MBLNR   "추가(SJM 25.05.13)
                             EBELN = GT_MDSB_L3-EBELN
                             EBELP = GT_MDSB_L3-EBELP
                             MATNR = GT_MDSB_L3-MATNR_C
                             POSNR = GT_MDSB_L3-POSNR
                             TAGNR = GT_MDSB_L3-TAGNR   "자재문서 생성전까진 값 無
                             CHARG = GT_MDSB_L3-CHARG   "자재문서 생성전까진 값 無
                             BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_POL FROM SY-TABIX.
    IF NOT ( GT_POL-GUBUN = GC_L
         AND GT_POL-MBLNR = GT_MDSB_L3-MBLNR   "추가(SJM 25.05.13)
         AND GT_POL-EBELN = GT_MDSB_L3-EBELN
         AND GT_POL-EBELP = GT_MDSB_L3-EBELP
         AND GT_POL-MATNR = GT_MDSB_L3-MATNR_C
         AND GT_POL-POSNR = GT_MDSB_L3-POSNR
         AND GT_POL-TAGNR = GT_MDSB_L3-TAGNR
         AND GT_POL-CHARG = GT_MDSB_L3-CHARG ).
      EXIT.
    ENDIF.

    CLEAR: GT_MDSB_L.
    MOVE-CORRESPONDING GT_MDSB_L3 TO GT_MDSB_L.

    GT_MDSB_L-BDMNG = GT_POL-BDMNG.
    GT_MDSB_L-CHARG = GT_POL-CHARG.
    GT_MDSB_L-TAGNR = GT_POL-TAGNR.
    GT_MDSB_L-LGORT = GT_POL-LGORT.

    GT_MDSB_L-MBLNR = GT_POL-MBLNR.
    GT_MDSB_L-MJAHR = GT_POL-MJAHR.

    IF GT_POL-MBLNR IS INITIAL.
      CLEAR : GT_MDSB_L-MBLNR_F, GT_MDSB_L-FLAG1.
      CLEAR : GT_MDSB_L-IV_NO,   GT_MDSB_L-IV_PRINT_YN,
              GT_MDSB_L-OUT_YN,  GT_MDSB_L-IV_DATE,
              GT_MDSB_L-FLAG2.
    ELSE.
      GT_MDSB_L-MBLNR_F = GC_X.
      GT_MDSB_L-FLAG1   = ICON_LED_GREEN.
    ENDIF.

    PERFORM SET_STATS_ZGUID USING GT_POL-APPSTAT
                                  GT_POL-ZGUID
                         CHANGING GT_MDSB_L-STATS
                                  GT_MDSB_L-ZGUID.

    APPEND GT_MDSB_L.
    DELETE GT_POL.
  ENDLOOP.

* LV_COND = |     GUBUN = GC_L |
*        && | AND EBELN = GT_MDSB_L3-EBELN   AND EBELP = GT_MDSB_L3-EBELP |
*        && | AND MATNR = GT_MDSB_L3-MATNR_C AND POSNR = GT_MDSB_L3-POSNR |.
*
* IF GT_MDSB_L3-MBLNR_F = GC_X.
*   LV_COND = LV_COND && | AND TAGNR = GT_MDSB_L3-TAGNR |
*                     && | AND CHARG = GT_MDSB_L3-CHARG |.
* ENDIF.

* PERFORM APPEND_L_LIST USING LV_COND.

  GV_RES = GC_X.

  "라인 뻥튀기되지 않게..
* DELETE GT_MDSB_L3 WHERE EBELN   = GT_MDSB_L3-EBELN
*                     AND EBELP   = GT_MDSB_L3-EBELP
*                     AND MATNR_C = GT_MDSB_L3-MATNR_C
*                     AND POSNR   = GT_MDSB_L3-POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_L_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_COND
*&---------------------------------------------------------------------*
FORM APPEND_L_LIST USING PV_COND.

  LOOP AT GT_PO WHERE (PV_COND).
* LOOP AT GT_PO FROM SY-TABIX.
*   IF NOT ( GT_PO-GUBUN = GC_L
*        AND GT_PO-EBELN = GT_MDSB_L3-EBELN
*        AND GT_PO-EBELP = GT_MDSB_L3-EBELP
*        AND GT_PO-MATNR = GT_MDSB_L3-MATNR_C
*        AND GT_PO-POSNR = GT_MDSB_L3-POSNR ).
**       AND GT_PO-TAGNR = GT_MDSB_L3-TAGNR
**       AND GT_PO-CHARG = GT_MDSB_L3-CHARG ).
*     EXIT.
*   ENDIF.

    CLEAR: GT_MDSB_L.
    MOVE-CORRESPONDING GT_MDSB_L3 TO GT_MDSB_L.

    GT_MDSB_L-BDMNG = GT_PO-BDMNG.
    GT_MDSB_L-CHARG = GT_PO-CHARG.
    GT_MDSB_L-TAGNR = GT_PO-TAGNR.
    GT_MDSB_L-LGORT = GT_PO-LGORT.

    GT_MDSB_L-MBLNR = GT_PO-MBLNR.
    GT_MDSB_L-MJAHR = GT_PO-MJAHR.

    IF GT_PO-MBLNR IS INITIAL.
      CLEAR : GT_MDSB_L-MBLNR_F, GT_MDSB_L-FLAG1.
    ELSE.
      GT_MDSB_L-MBLNR_F = GC_X.
      GT_MDSB_L-FLAG1   = ICON_LED_GREEN.
    ENDIF.

    PERFORM SET_STATS_ZGUID USING GT_PO-APPSTAT
                                  GT_PO-ZGUID
                         CHANGING GT_MDSB_L-STATS
                                  GT_MDSB_L-ZGUID.

    APPEND GT_MDSB_L.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_W3_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_W3_QTY TABLES PT_W1 STRUCTURE GT_MDSB_W1.

  "중량 라인이 쪼개지는 경우, 라인이 배수로 증가하는 기존 오류 수정(SJM 25.04.02)

  READ TABLE PT_W1 WITH KEY MATNR_C = GT_MDSB_W3-MATNR_C
                            BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  CLEAR : GT_MDSB_W3-BDMNG, GT_MDSB_W3-BDMNG_A,
          GT_MDSB_W3-ERFMG, GT_MDSB_W3-ERFMG_A.

  LOOP AT PT_W1 FROM SY-TABIX.
    IF PT_W1-MATNR_C <> GT_MDSB_W3-MATNR_C.
      EXIT.
    ENDIF.

    GT_MDSB_W3-BDMNG   += PT_W1-BDMNG.
    GT_MDSB_W3-BDMNG_A += PT_W1-BDMNG_A.
    GT_MDSB_W3-ERFMG   += PT_W1-ERFMG.
    GT_MDSB_W3-ERFMG_A += PT_W1-ERFMG_A.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ENMNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ENMNG.

  "기존 업체불출량 추출 로직 오류 수정(SJM 25.04.02)

  WITH +LT_QTY AS ( SELECT DISTINCT POSNR, MATNR, ENMNG
                      FROM ZPPT0018
                     WHERE MATNR = @GT_MDSB_W3-MATNR_C
                       AND MBLNR = @GT_MDSB_W3-MBLNR
                       AND MJAHR = @GT_MDSB_W3-MJAHR
                       AND TAGNR = @GT_MDSB_W3-TAGNR ) "추가(SJM 25.06.27)

   SELECT DISTINCT MATNR, SUM( ENMNG ) AS ENMNG
     FROM +LT_QTY
    GROUP BY MATNR
     INTO TABLE @DATA(LT_SUM).

  GT_MDSB_W2-ENMNG = VALUE #( LT_SUM[ 1 ]-ENMNG OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MBST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MBST.

  "기존 로직 개선(SJM 25.04.03)
  " Validation Check 추가

  CLEAR : GV_ERR.

  "라인 선택 여부 Check
  IF NOT ( LINE_EXISTS( GT_MDSB_L[  CHECK = GC_X ] )
        OR LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X ] ) ).
    MESSAGE S004(ZGTMM01) DISPLAY LIKE 'E'. "라인을 선택하세요.
    GV_ERR = GC_X.
    EXIT.
  ENDIF.

  "자재문서 존재 여부 Check
  IF LINE_EXISTS( GT_MDSB_L[  CHECK = GC_X MBLNR = SPACE ] )
  OR LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X MBLNR = SPACE ] ).
    "취소할 자재문서가 없는 라인이 포함되어 있습니다.
    MESSAGE S130(ZGTMM01) DISPLAY LIKE 'E'.
    GV_ERR = GC_X.
    EXIT.
  ENDIF.

  "통문증 존재 여부 Check(SJM 25.05.13)
  IF LINE_EXISTS( GT_MDSB_L[  CHECK = GC_X IV_PRINT_YN = GC_X ] )
  OR LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X IV_PRINT_YN = GC_X ] ).
    "통문증부터 취소하세요.
    MESSAGE S034(ZGTMM01) DISPLAY LIKE 'E'.
    GV_ERR = GC_X.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WX_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_WX_LIST.

  "라인 구성 방식 변경(SJM 25.06.26)
  " 즉시 출고 진행 후, 승인 프로세스 적용(한도 초과)으로 변경되는 경우 발생
  " ZPPT0018 기존 로직 데이터 추가한 후, 출고 미진행 승인건(ZPPT0018 미존재) 라인 추가
  APPEND  GT_MDSB_W1.
  COLLECT GT_MDSB_W3.

  READ TABLE GT_POW WITH KEY GUBUN = GC_W
                             EBELN = GT_EBAN-EBELN
                             EBELP = GT_EBAN-EBELP
                             MATNR = GT_MDSB_W3-MATNR_C
                             BINARY SEARCH.

* IF SY-SUBRC <> 0.
*   COLLECT GT_MDSB_W3.
* ELSE.
  IF SY-SUBRC = 0.
    LOOP AT GT_POW FROM SY-TABIX.
      IF NOT ( GT_POW-GUBUN = GC_W
           AND GT_POW-EBELN = GT_EBAN-EBELN
           AND GT_POW-EBELP = GT_EBAN-EBELP
           AND GT_POW-MATNR = GT_MDSB_W3-MATNR_C ).
        EXIT.
      ENDIF.

      CHECK GT_POW-MBLNR IS INITIAL. "추가(SJM 25.06.26)

      GT_MDSB_W3-TAGNR = GT_POW-TAGNR.
      COLLECT GT_MDSB_W3.
    ENDLOOP.
* ENDIF.
* APPEND GT_MDSB_W1.
  ENDIF.
  CLEAR: GT_MDSB_W1, GT_MDSB_W3.

ENDFORM.
