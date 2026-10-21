FUNCTION ZGTMM_IF_I_INFODATA_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_MAIN STRUCTURE  ZGTMMS1009
*"      IT_PLANT STRUCTURE  ZGTMMS1000
*"      IT_PRICE STRUCTURE  ZGTMMS1013 OPTIONAL
*"      OT_MSG STRUCTURE  ZGTMMS1002
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_INFODATA_RCV
*& 프로그램 명 :  단가 계약 정보 수신(G-SRM->SAP)
*& 개요   : G-SRM(전자구매시스템)에서 전송된 단가 계약 정보를 SAP INFORECORD 생성하거나
*&           변경하는 INTERFACE 용 FUNCTION 개발 RFC (FROM G-SRM)
*& 생성일 : 2025.12.19
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
DATA :  GT_MARA   TYPE TABLE OF MARA,
            LT_MAIN  TYPE TABLE OF ZGTMMS1009.

*--전송 데이터 누락여부 확인
  IF IT_MAIN[] IS INITIAL OR IT_PLANT[] IS INITIAL .

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.

  ELSE.
    LT_MAIN = VALUE #( BASE LT_MAIN FOR WA IN IT_MAIN
                                   ( MATNR = |{ WA-MATNR WIDTH = 18 ALIGN = RIGHT PAD = '0' }|
                                     LIFNR = |{ WA-LIFNR ALPHA = IN }| ) ).
    CHECK LT_MAIN[] IS NOT INITIAL.

    SELECT FROM MARA
    FIELDS MATNR
    FOR ALL ENTRIES IN @LT_MAIN
    WHERE MATNR = @LT_MAIN-MATNR
        AND LVORM IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @GT_MARA.

*    SELECT FROM MARA
*    FIELDS MATNR
*    FOR ALL ENTRIES IN @IT_MAIN
*    WHERE MATNR = @IT_MAIN-MATNR AND LVORM <> 'X'
*        INTO CORRESPONDING FIELDS OF TABLE @GT_MARA.

   SORT GT_MARA BY MATNR.
   DELETE ADJACENT DUPLICATES FROM   GT_MARA.

   IF GT_MARA[] IS NOT INITIAL.
     LOOP AT GT_MARA INTO DATA(LS_GT_MARA).
       CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
         EXPORTING
           input         = LS_GT_MARA-MATNR
        IMPORTING
          OUTPUT        = LS_GT_MARA-MATNR.

       MODIFY GT_MARA FROM LS_GT_MARA.
     ENDLOOP.
   ENDIF.

  ENDIF.

  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.


  DATA : LV_EXT TYPE BAPICURR-BAPICURR,
             LV_KBETR TYPE KBETR_KOND.


*BANFN/BNFPO를 제외한 나머지 필수 필드 중 빈 값이 있으면, 에러 리턴.
  LOOP AT IT_MAIN INTO DATA(LS_MAIN).
    IF LS_MAIN-MATNR IS INITIAL OR LS_MAIN-LIFNR IS INITIAL OR
      LS_MAIN-EKORG IS INITIAL OR LS_MAIN-WERKS IS INITIAL OR
      LS_MAIN-ESOKZ IS INITIAL OR LS_MAIN-WAERS IS INITIAL OR
      LS_MAIN-DATAB IS INITIAL OR LS_MAIN-DATBI IS INITIAL OR
      LS_MAIN-NETPR IS INITIAL OR LS_MAIN-PEINH IS INITIAL OR
      LS_MAIN-BPRME IS INITIAL OR LS_MAIN-EKGRP IS INITIAL.

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      RETURN.

    ELSE.

    READ TABLE GT_MARA INTO DATA(LS_MARA) WITH KEY MATNR = LS_MAIN-MATNR BINARY SEARCH.
    IF SY-SUBRC NE 0.
      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '(' && LS_MAIN-MATNR && ')' && '자재마스터가 삭제상태입니다.'(E24).
      RETURN.
    ENDIF.

    ENDIF.

    CLEAR LS_MAIN.
  ENDLOOP.

*--전송 정보 저장(1차 LOG 등록)
  CLEAR: GS_MSG, GV_SYSTEM_ID.
  SORT IT_PRICE BY WERKS.
  SORT IT_PLANT BY WERKS.

  GV_SYSTEM_ID = I_SYSTEM_ID.
  DATA : LV_MATNR TYPE MATNR18.
  DATA : LV_PTYPE TYPE CHAR1.

*INTERFACE->내부 ITAB 변환
  PERFORM CONV_DATA TABLES IT_PRICE.

  LOOP AT  IT_MAIN ASSIGNING FIELD-SYMBOL(<FS>).
*공통로그
    PERFORM SET_COM_LOG  USING 'S' 'MM00024' '' '' CHANGING GS_9000.
*단가-기본 정보_ZGTMMT9230
    CLEAR : GS_9230, GS_9231, GS_9232, GS_1040, LV_MATNR,LV_KBETR , LV_EXT.
    LV_MATNR = |{ <FS>-MATNR ALPHA = IN }|. "INFORECORD생성시 18자리로 설정필요.
    <FS>-LIFNR = |{ <FS>-LIFNR  ALPHA = IN }|.
*    PERFORM CONVERT_MATN1_INPUT CHANGING <FS>-MATNR.
*    SHIFT <FS>-MATNR LEFT DELETING LEADING '0'.

       LV_EXT = <FS>-NETPR.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      CURRENCY                 = <FS>-WAERS
      AMOUNT_EXTERNAL    = LV_EXT
      MAX_NUMBER_OF_DIGITS = 20
   IMPORTING
     AMOUNT_INTERNAL    = LV_KBETR .

    GS_9230 = VALUE #(  MATNR = <FS>-MATNR
                                    LIFNR = <FS>-LIFNR
                                    EKORG = <FS>-EKORG
                                    WERKS = <FS>-WERKS
                                    ESOKZ = <FS>-ESOKZ
                                    WAERS = <FS>-WAERS
                                    DATAB = <FS>-DATAB
                                    DATBI = <FS>-DATBI
                                    NETPR = LV_KBETR
                                    PEINH = <FS>-PEINH
                                    BPRME = <FS>-BPRME
                                    EKGRP = <FS>-EKGRP
                                   ZIFKEY = GS_9000-ZIFKEY ).


*단가-플랜트 정보_ZGTMMT9231
    READ TABLE IT_PLANT INTO DATA(LS_PL) WITH KEY WERKS = <FS>-WERKS BINARY SEARCH.
    IF SY-SUBRC = 0.
      LV_PTYPE = LS_PL-PTYPE.
      GS_9231 = VALUE #( ZIFKEY  = GS_9000-ZIFKEY
                                 WERKS   = <FS>-WERKS
                                 APLFZ    = LS_PL-APLFZ
                                 UEBTO   = LS_PL-UEBTO
                                 UNTTO   = LS_PL-UNTTO
                                 UEBTK   = LS_PL-UEBTK
                                 KZABS   = LS_PL-KZABS
                                 BSTAE   = LS_PL-BSTAE
                                 WEBRE  = LS_PL-WEBRE
                                 NORBM = LS_PL-NORBM
                                 MINBM  = LS_PL-MINBM
                                 MWSKZ = LS_PL-MWSKZ
                                 MEPRF = LS_PL-MEPRF
                                 INCO1  = LS_PL-INCO1 ) .
    ENDIF.
*가격정보 확인
    READ TABLE GT_PRICE INTO DATA(LS_PR) WITH KEY WERKS = <FS>-WERKS BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_9232 = VALUE #( ZIFKEY   = GS_9000-ZIFKEY
                                 WERKS       = <FS>-WERKS
                                 CDATE   = SY-DATLO
                                PTYPE =  LS_PL-PTYPE
                                CU_QT = LS_PR-CU_QT
                                CU_PRC = LS_PR-CU_PRC
                                CU_SUM = LS_PR-CU_SUM
                                AL_QT = LS_PR-AL_QT
                                AL_PRC = LS_PR-AL_PRC
                                AL_SUM = LS_PR-AL_SUM
                                CUTAPE_QT = LS_PR-CUTAPE_QT
                                CUTAPE_PRC = LS_PR-CUTAPE_PRC
                                CUTAPE_SUM = LS_PR-CUTAPE_SUM
                                RQ_RAW_SUM = LS_PR-RQ_RAW_SUM
                                COMPOUND1_QT = LS_PR-COMPOUND1_QT
                                COMPOUND1_PRC = LS_PR-COMPOUND1_PRC
                                COMPOUND1_SUM = LS_PR-COMPOUND1_SUM
                                COMPOUND2_QT = LS_PR-COMPOUND2_QT
                                COMPOUND2_PRC = LS_PR-COMPOUND2_PRC
                                COMPOUND2_SUM = LS_PR-COMPOUND2_SUM
                                 MAT_COST = LS_PR-MAT_COST
                                 PAK_COST = LS_PR-PAK_COST
                                 MFG_COST = LS_PR-MFG_COST
                                 WAERS = 'KRW'
                                MEINS = 'KG'
                                LMEDATE = LS_PR-LMEDATE
                                LMEPRICE = LS_PR-LMEPRICE
                                LWAERS = LS_PR-LWAERS ) .
    ENDIF.
*구매 단가 구성 정보_인포레코드 변경 BAPI성공 시 업데이트 위해 선 구성
    GS_1040 = VALUE #( BASE CORRESPONDING #( <FS> )
                                 WERKS      = LS_PR-WERKS
                                 CDATE   = SY-DATLO
                                 PTYPE =  LS_PL-PTYPE
                                 CU_QT = LS_PR-CU_QT
                                 CU_PRC = LS_PR-CU_PRC
                                 CU_SUM = LS_PR-CU_SUM
                                 AL_QT = LS_PR-AL_QT
                                 AL_PRC = LS_PR-AL_PRC
                                 AL_SUM = LS_PR-AL_SUM
                                 CUTAPE_QT = LS_PR-CUTAPE_QT
                                 CUTAPE_PRC = LS_PR-CUTAPE_PRC
                                 CUTAPE_SUM = LS_PR-CUTAPE_SUM
                                 RQ_RAW_SUM = LS_PR-RQ_RAW_SUM
                                 COMPOUND1_QT = LS_PR-COMPOUND1_QT
                                 COMPOUND1_PRC = LS_PR-COMPOUND1_PRC
                                 COMPOUND1_SUM = LS_PR-COMPOUND1_SUM
                                 COMPOUND2_QT = LS_PR-COMPOUND2_QT
                                 COMPOUND2_PRC = LS_PR-COMPOUND2_PRC
                                 COMPOUND2_SUM = LS_PR-COMPOUND2_SUM
                                 MAT_COST = LS_PR-MAT_COST
                                 PAK_COST = LS_PR-PAK_COST
                                 MFG_COST = LS_PR-MFG_COST
                                 PEINH = <FS>-PEINH
                                 MEINS = 'KG'
                                 LMEDATE = LS_PR-LMEDATE
                                 LMEPRICE = LS_PR-LMEPRICE
                                 LWAERS = LS_PR-LWAERS
                                 ERDAT = SY-DATUM
                                 ERDAT_LOCAL = SY-DATLO
                                 ERTIM = SY-UZEIT
                                 ERTIM_LOCAL = SY-TIMLO
                                 ERNAM = SY-UNAME )  .

    CLEAR : LS_PL, LS_PR.
*단가 기본정보/플랜트정보/단가정보 저장
    MODIFY ZGTMMT9230 FROM GS_9230.
    MODIFY ZGTMMT9231 FROM GS_9231.
    MODIFY ZGTMMT9232 FROM GS_9232.

*-------------------------------------------------------------
*INFORECORD 생성/변경
*-------------------------------------------------------------
*공급업체 국가 확인
    SELECT SINGLE LAND1 FROM LFA1
      WHERE LIFNR = @<FS>-LIFNR INTO @DATA(LV_LAND).

*-법인 별 로직 분개_현재는 가온 구매조직 '1400'만 구현
    CASE <FS>-EKORG.
*가온전선 구매조직(1400)
      WHEN '1400'.
*FUCNTION_CREATE INFORECORD
        PERFORM SET_INFORECORD USING GS_9231 LV_LAND <FS> LV_MATNR LV_PTYPE
                                                    CHANGING GS_MSG.
*그 외..
      WHEN OTHERS.

    ENDCASE.

  ENDLOOP.

*RETURN TABLE 구성
  IF GS_MSG IS INITIAL. "성공
    APPEND VALUE #( TYPE        = GC_S
                                 CODE       = GC_000
                                 MESSAGE = '단가가 등록 되었습니다.'(M01) ) TO OT_MSG.
    ZO_RESULT    = GC_00. "00
    IF LV_PTYPE  = GC_B.
      ZO_MESSAGE =  'INFORECORD MAINTAIN 성공'(M02) .
    ELSE.
      ZO_MESSAGE =  '예가 견적 등록 성공'(M02) .
    ENDIF.

  ELSE. "에러
    APPEND VALUE #( TYPE        = GS_MSG-TYPE
                                 CODE       = GS_MSG-CODE
                                 MESSAGE = GS_MSG-MESSAGE ) TO OT_MSG.
    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = GS_MSG-MESSAGE .
  ENDIF.


ENDFUNCTION.
