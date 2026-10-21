*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4150
*& 프로그램 명 : MM Exit
*& 개요   : GT PJT MM Exit 로직 구현
*& 생성일 : 2025.03.17
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT ZGTMMR4150.


INCLUDE ZGTMMR4150TOP.


*&---------------------------------------------------------------------*
*&      Form  SAVE_ZGTMMT411X
*&---------------------------------------------------------------------*
*   직납 입고시 외주 불출 금액 누락되지 않게 CBO Table 저장(SJM 25.03.17)
*----------------------------------------------------------------------*
FORM SAVE_ZGTMMT411X TABLES PT_XMSEG STRUCTURE MSEG.

* CHECK SY-UNAME = 'ZGISMM01' OR SY-UNAME = 'ZGSIDEV03'. "임시! 추후 삭제 예정!

  CHECK SY-TCODE <> GC_ZGTMMR4020.

  "직납 입고 중 ZGTMMR4020으로 입고 잡지 않는 경우 직납 업체별 이전 금액 합산

  CLEAR : GT_HLIST[], GT_ILIST[].

  LOOP AT PT_XMSEG INTO DATA(LS_MSEG) WHERE SOBKZ  = GC_O
                                        AND EBELN <> SPACE.

    "Plant별 제어 로직 추가(SJM 25.04.30)
    SELECT SINGLE ZUSE INTO @DATA(LV_ZUSE)
      FROM ZGTMM_CV_GETAPPSTATBYSPG
     WHERE WERKS = @LS_MSEG-WERKS
       AND ZTYPE = @GC_02.

    CHECK LV_ZUSE = GC_X.

    CASE LS_MSEG-BWART.
      WHEN '101'.
        MOVE-CORRESPONDING LS_MSEG TO GT_HLIST.
        MOVE-CORRESPONDING LS_MSEG TO GT_ILIST.
        COLLECT : GT_HLIST, GT_ILIST.

      WHEN '102'.
        UPDATE ZGTMMT4110 SET LOEKZ = GC_X
                        WHERE MJAHR = LS_MSEG-SJAHR
                          AND MBLNR = LS_MSEG-SMBLN.

        EXIT.
    ENDCASE.
  ENDLOOP.

  CHECK GT_HLIST[] IS NOT INITIAL.

  LOOP AT GT_HLIST.
    "한도 예외 관리 업체 Check(SJM 25.03.25)
    " 초과 불출 예외 업체는 한도 금액 상관없음. 초과 불출 정보 저장 안함.(ZGTMMT4110 저장 X)
    SELECT SINGLE LIFNR
      FROM ZGTMMT4101 INTO @DATA(LV_LIFNR)
     WHERE LIFNR = @GT_HLIST-EMLIF. "검수업체

    CHECK SY-SUBRC <> 0.

    "공급업체 보증금액 및 한도 금액 조회
    SELECT SINGLE PREIS,
                  TOTALSCVALUE,
                  APVALUE,
                  WAERS
      INTO CORRESPONDING FIELDS OF @GS_SHDR
      FROM ZGTMM_CV_SCSTOCKHEADER
     WHERE BUKRS = @GT_HLIST-BUKRS
       AND LIFNR = @GT_HLIST-EMLIF.

    CHECK SY-SUBRC = 0.

    "보증보험 금액 - 외주재고액 - 입고액
    GV_REVAL = GS_SHDR-PREIS - GS_SHDR-TOTALSCVALUE - GT_HLIST-DMBTR.

    CHECK GV_REVAL < 0.

    PERFORM SET_SHDR.
    PERFORM SET_SITM.

    MODIFY ZGTMMT4111 FROM TABLE GT_SITM.
    MODIFY ZGTMMT4110 FROM TABLE GT_SHDR.

*   IF SY-SUBRC = 0.
*     COMMIT WORK.
*   ELSE.
*     ROLLBACK WORK.
*   ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_GUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SHDR_ZGUID
*&---------------------------------------------------------------------*
FORM CREATE_GUID CHANGING PV_ZGUID.

  CLEAR : PV_ZGUID.
  PV_ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

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
*& Form SET_SHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SHDR.

  CLEAR : GT_SHDR, GT_SHDR[].

  PERFORM CREATE_GUID CHANGING GT_SHDR-ZGUID.

  GT_SHDR-ZGITYPE = GC_D.
  GT_SHDR-BUKRS   = GT_HLIST-BUKRS.
  GT_SHDR-WERKS   = GT_HLIST-WERKS.
* GT_SHDR-LGORT   = GT_HLIST-LGORT.
  GT_SHDR-LIFNR   = GT_HLIST-EMLIF.
  GT_SHDR-PREIS   = GS_SHDR-PREIS.
  GT_SHDR-SCVAL   = GS_SHDR-TOTALSCVALUE.
  GT_SHDR-ISVAL   = GT_HLIST-DMBTR.
  GT_SHDR-REVAL   = GV_REVAL.
  GT_SHDR-IVVAL   = GS_SHDR-APVALUE.
  GT_SHDR-WAERS   = GS_SHDR-WAERS.
  GT_SHDR-ORES    = GC_003.
  GT_SHDR-OETC    = '업체 직납'(M01).
  GT_SHDR-APPSTAT = GC_A.
  GT_SHDR-MJAHR   = GT_HLIST-MJAHR.
  GT_SHDR-MBLNR   = GT_HLIST-MBLNR.

  PERFORM SET_TIMESTAMP USING 'X' 'X'.
  MOVE-CORRESPONDING GS_CREA TO GT_SHDR.
  MOVE-CORRESPONDING GS_CHNG TO GT_SHDR.

  APPEND GT_SHDR.

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

  DATA : LT_ITM LIKE GT_ILIST OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_SITM[].

  LT_ITM[] = GT_ILIST[].
  DELETE LT_ITM WHERE EMLIF <> GT_HLIST-EMLIF.

  CHECK LT_ITM[] IS NOT INITIAL.

  SORT LT_ITM BY MATNR.

  SELECT MATNR,
         XCHPF,
         SCQTY,
         MEINS,
         SCVAL,
         WAERS
    INTO TABLE @DATA(LT_STK)
    FROM ZGTMM_CV_SCREQLIST_L
     FOR ALL ENTRIES IN @LT_ITM
   WHERE BUKRS = @GT_HLIST-BUKRS
     AND LIFNR = @GT_HLIST-EMLIF
     AND MATNR = @LT_ITM-MATNR.

  SORT LT_STK BY MATNR.

  LOOP AT LT_ITM.
    CLEAR : GT_SITM.

    GT_SITM-ZGUID = GT_SHDR-ZGUID.
    GT_SITM-MATNR = LT_ITM-MATNR.
    GT_SITM-REQTY = LT_ITM-MENGE.
    GT_SITM-NEQTY = LT_ITM-MENGE.
*   GT_SITM-SLQTY
    GT_SITM-ISQTY	= LT_ITM-MENGE.
    GT_SITM-MEINS	= LT_ITM-MEINS.
    GT_SITM-ISVAL	= LT_ITM-DMBTR.
    GT_SITM-WAERS	= LT_ITM-WAERS.

    SELECT SINGLE XCHPF
      FROM MARC INTO GT_SITM-XCHPF
     WHERE MATNR = LT_ITM-MATNR
       AND WERKS = GT_HLIST-WERKS
       AND LVORM = SPACE.

    READ TABLE LT_STK INTO DATA(LS_STK)
      WITH KEY MATNR = LT_ITM-MATNR BINARY SEARCH.

    IF SY-SUBRC = 0.
      GT_SITM-SCQTY	= LS_STK-SCQTY.
      GT_SITM-SCVAL	= LS_STK-SCVAL.
    ENDIF.

    APPEND GT_SITM.
  ENDLOOP.

ENDFORM.
