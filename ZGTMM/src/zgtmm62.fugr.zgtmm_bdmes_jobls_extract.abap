FUNCTION ZGTMM_BDMES_JOBLS_EXTRACT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_ZSYSTEM_ID) TYPE  ZGTETARGET DEFAULT 'KBDM'
*"     VALUE(I_ZWERKS) TYPE  EWERK
*"     VALUE(I_ZTABLE) TYPE  CHAR20 OPTIONAL
*"     VALUE(I_ZKEY1) TYPE  CHAR40
*"     VALUE(I_CANCEL) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_JOBLS_EXTRACT
*& 프로그램 명 : [BD] 구매 제조지시 데이터 추출
*& 개요   : 설계 시스템에서 전송 받은 ED 테이블의 구매 제조지시 데이터를 추출하여 MM 테이블에 저장
*& 생성일 : 2025.02.20
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  CLEAR : ZO_RESULT, ZO_MESSAGE, GV_RST, GV_MSG.

  GV_ZSYSTEM_ID = I_ZSYSTEM_ID.
  GV_ZWERKS     = I_ZWERKS.
  GV_JOB_NO     = I_ZKEY1.
  GV_CANCEL     = I_CANCEL.

  PERFORM PRCS_CANC.

  IF GV_RST IS NOT INITIAL.
    ZO_RESULT  = GV_RST.
    ZO_MESSAGE = GV_MSG.
    RETURN.
  ENDIF.

  CLEAR : GT_DATA[].

  SELECT * FROM ZGTEDT2132
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
   WHERE ZSYSTEM_ID = GV_ZSYSTEM_ID
     AND ZWERKS     = GV_ZWERKS
     AND ZTABLE    IN ( GC_ZGTMMT6210, GC_ZGTMMT6211 )
     AND ZKEY1      = GV_JOB_NO.

  IF GT_DATA[] IS INITIAL.
    ZO_RESULT = GC_E.
    MESSAGE E002(ZGTMM01) INTO ZO_MESSAGE. "조회된 값이 없습니다.
    RETURN.
  ENDIF.

  SORT GT_DATA BY ZTABLE ZKEY1 ZKEY2 ZKEY3 ZKEY4.
  DELETE ADJACENT DUPLICATES FROM GT_DATA
        COMPARING ZTABLE ZKEY1 ZKEY2 ZKEY3 ZKEY4.

  PERFORM GET_MES_XEQ.
  PERFORM SET_TIMESTAMP USING 'X' ' '.

  PERFORM SAVE_ZGTMMT6210.
  PERFORM SAVE_ZGTMMT6211.

  ZO_RESULT  = GV_RST.
  ZO_MESSAGE = GV_MSG.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form PRCS_CANC
*&---------------------------------------------------------------------*
FORM PRCS_CANC.

  "제조지시 취소 로직 변경(PSJ 25.04.09)

  CLEAR : GT_CPR[], GT_CPO[], GV_ERR.

  CHECK GV_CANCEL = GC_X. "제조지시 취소

  SELECT JOB_NO, JOBLS, BANFN AS DOCNO
    FROM ZGTMM_CV_BD_JNPR_LIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_CPR
   WHERE WERKS  = @GV_ZWERKS
     AND JOB_NO = @GV_JOB_NO.

  SELECT JOB_NO, JOBLS, EBELN AS DOCNO
    FROM ZGTMM_CV_BD_JNPO_LIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_CPO
   WHERE WERKS  = @GV_ZWERKS
     AND JOB_NO = @GV_JOB_NO.

  CHECK GT_CPR[] IS NOT INITIAL OR GT_CPO[] IS NOT INITIAL.

  PERFORM DELETE_ZGTMMT621X TABLES GT_CPR USING ' '.
  PERFORM DELETE_ZGTMMT621X TABLES GT_CPO USING 'X'.

  IF GV_ERR IS INITIAL.
    COMMIT WORK.
    PERFORM SET_RST_MSG USING 'S' 'SUCCESS'(M02).
  ELSE.
    ROLLBACK WORK.
    PERFORM SET_RST_MSG USING 'E' '구매확정 취소 DB 에러'(M03).
  ENDIF.

* SELECT SINGLE JOB_NO
*   FROM ZGTMM_CV_BD_JOBLS_PRPO
*   INTO @DATA(LV_JOB_NO)
*  WHERE JOB_NO = @GV_JOB_NO.
*
* IF LV_JOB_NO IS NOT INITIAL.
*   PERFORM SET_RST_MSG USING 'E' '구매확정건이 존재합니다.'(M01).
*   EXIT.
* ENDIF.
*
* DELETE FROM ZGTMMT6211 WHERE JOB_NO = GV_JOB_NO.
* DELETE FROM ZGTMMT6210 WHERE JOB_NO = GV_JOB_NO.
*
* IF SY-SUBRC = 0.
*   COMMIT WORK.
*   PERFORM SET_RST_MSG USING 'S' 'SUCCESS'(M02).
* ELSE.
*   ROLLBACK WORK.
*   PERFORM SET_RST_MSG USING 'E' '구매확정 취소 DB 에러'(M03).
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ZGTMMT621X
*&---------------------------------------------------------------------*
FORM DELETE_ZGTMMT621X TABLES PT_CPX STRUCTURE GT_CPR
                        USING PV_CHK.

  "1)ZGTMM_CV_BD_JNPR_LIST의 구매요청번호가 있는 건만 남기고 ZGTMMT6210에서 삭제
  "  구매요청번호가 있는 건은 ZGTMMT6210의 "생관확정취소(CNFCL)"를 'X'로 수정
  "2)ZGTMM_CV_BD_JNPO_LIST의 구매오더번호가 있는 건만 남기고 ZGTMMT6210/ZGTMMT6211에서 삭제
  "  구매오더번호가 있는 건은 ZGTMMT6210의 "생관확정취소(CNFCL)"를 'X'로 수정

  CHECK GV_ERR   IS INITIAL.
  CHECK PT_CPX[] IS NOT INITIAL.

  LOOP AT PT_CPX.
    IF PT_CPX-DOCNO IS NOT INITIAL.
      UPDATE ZGTMMT6210 SET CNFCL  = GC_X
                      WHERE JOB_NO = PT_CPX-JOB_NO
                        AND JOBLS  = PT_CPX-JOBLS.
    ELSE.
      IF PV_CHK = GC_X.
        DELETE FROM ZGTMMT6211 WHERE JOB_NO = PT_CPX-JOB_NO
                                 AND JOBLS  = PT_CPX-JOBLS.
      ENDIF.

      DELETE FROM ZGTMMT6210 WHERE JOB_NO = PT_CPX-JOB_NO
                               AND JOBLS  = PT_CPX-JOBLS.
    ENDIF.

    IF SY-SUBRC <> 0.
      GV_ERR = GC_X.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MES_XEQ
*&---------------------------------------------------------------------*
FORM GET_MES_XEQ.

  GT_MES[] = VALUE #( FOR LS_DATA IN GT_DATA
                       ( VALUE #( MES_REQ = LS_DATA-ZKEY2
                                  MES_SEQ = LS_DATA-ZKEY3 ) ) ).

  SORT GT_MES BY MES_REQ MES_SEQ.
  DELETE ADJACENT DUPLICATES FROM GT_MES COMPARING MES_REQ MES_SEQ.

  SELECT H~MES_REQ
         H~MES_SEQ
         H~JOBLS
         I~JOB_NO
    FROM ZGTMMT6210 AS H LEFT JOIN ZGTMMT6211 AS I
      ON H~MES_REQ = I~MES_REQ
     AND H~MES_SEQ = I~MES_SEQ
    INTO CORRESPONDING FIELDS OF TABLE GT_MES
     FOR ALL ENTRIES IN GT_MES
   WHERE H~MES_REQ = GT_MES-MES_REQ
     AND H~MES_SEQ = GT_MES-MES_SEQ.

  CHECK GT_MES[] IS NOT INITIAL.
  SORT GT_MES BY MES_REQ MES_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTMMT6210
*&---------------------------------------------------------------------*
FORM SAVE_ZGTMMT6210.

  PERFORM MAKE_ZGTMMT6210.

  IF GT_6210[] IS INITIAL.
    PERFORM SET_RST_MSG USING 'E' '[ZGTMMT6210] 저장할 내역이 없습니다.'(M04).
    EXIT.
  ENDIF.

  MODIFY ZGTMMT6210 FROM TABLE GT_6210.

  IF SY-SUBRC = 0.
    COMMIT WORK.
    PERFORM SET_RST_MSG USING 'S' 'SUCCESS'(M02).

    PERFORM GET_MES_XEQ.
  ELSE.
    ROLLBACK WORK.
    PERFORM SET_RST_MSG USING 'E' '[ZGTMMT6210] 구매확정 저장 DB 에러'(M05).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ZGTMMT6210
*&---------------------------------------------------------------------*
FORM MAKE_ZGTMMT6210.

  CLEAR : GT_6210[].

  READ TABLE GT_DATA WITH KEY ZTABLE = GC_ZGTMMT6210
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_DATA FROM SY-TABIX.
    IF GT_DATA-ZTABLE <> GC_ZGTMMT6210.
      EXIT.
    ENDIF.

    CLEAR : GT_6210.
    GT_6210-MES_REQ = GT_DATA-ZKEY2.
    GT_6210-MES_SEQ = GT_DATA-ZKEY3.

    "기저장된 MES_REQ/MES_SEQ는 대상에서 제외
    READ TABLE GT_MES WITH KEY MES_REQ = GT_6210-MES_REQ
                               MES_SEQ = GT_6210-MES_SEQ
                               BINARY SEARCH.

    IF SY-SUBRC = 0.
      CONTINUE.
    ENDIF.

    PERFORM SET_6210_VAL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6210_VAL
*&---------------------------------------------------------------------*
FORM SET_6210_VAL.

  PERFORM GET_NUMBER USING '01' 'ZGTMM_JOBL'
                  CHANGING GT_6210-JOBLS.

  GT_6210-JOB_NO      = GT_DATA-ZKEY1.
  GT_6210-LINE_NO     = GT_DATA-ZVALUE01.
  GT_6210-SERIAL_INFO = GT_DATA-ZVALUE02.
* GT_6210-ORDCH
  GT_6210-BSTYP       = GT_DATA-ZVALUE03.
  GT_6210-EKORG       = GT_DATA-ZVALUE04.
  GT_6210-EKGRP       = GT_DATA-ZVALUE05.
  GT_6210-AFNAM       = GT_DATA-ZVALUE06.
  GT_6210-PSTYP       = GT_DATA-ZVALUE07.

* PERFORM CONVERSION_EXIT_PDATE_INPUT USING GT_DATA-ZVALUE08
*                                  CHANGING GT_6210-EINDT.
  GT_6210-EINDT = GT_DATA-ZVALUE08.
  GT_6210-MATKL = GT_DATA-ZVALUE09.

  PERFORM CONVERT_MATN1_INPUT USING GT_DATA-ZVALUE10
                           CHANGING GT_6210-MATNR.

  GT_6210-TXZ01 = GT_DATA-ZVALUE11.

  PERFORM REMOVE_SEP USING GT_DATA-ZVALUE12
                  CHANGING GT_6210-MENGE.

  PERFORM CONVERSION_EXIT_CUNIT_INPUT USING GT_DATA-ZVALUE13
                                   CHANGING GT_6210-MEINS.

  GT_6210-WERKS = GT_DATA-ZVALUE14.
  GT_6210-LGORT = GT_DATA-ZVALUE15.
  GT_6210-EMLIF = |{ GT_DATA-ZVALUE16 ALPHA = IN }|.
  GT_6210-KUNNR = |{ GT_DATA-ZVALUE17 ALPHA = IN }|.
  GT_6210-KNTTP = GT_DATA-ZVALUE18.
  GT_6210-ABLAD = GT_DATA-ZVALUE19.
  GT_6210-SAKTO = |{ GT_DATA-ZVALUE20 ALPHA = IN }|.
  GT_6210-KOSTL = |{ GT_DATA-ZVALUE21 ALPHA = IN }|.
  GT_6210-SOBKZ = GT_DATA-ZVALUE22.
  GT_6210-VBELN = |{ GT_DATA-ZVALUE23 ALPHA = IN }|.
  GT_6210-VBELP = GT_DATA-ZVALUE24.
  GT_6210-FLIEF = |{ GT_DATA-ZVALUE25 ALPHA = IN }|.
  GT_6210-UMSON = GT_DATA-ZVALUE26.
  GT_6210-EXPRC = GT_DATA-ZVALUE27.
  GT_6210-IDNLF = GT_DATA-ZVALUE28.

  PERFORM REMOVE_SEP USING GT_DATA-ZVALUE29
                  CHANGING GT_6210-BSTMG.

  PERFORM CONVERSION_EXIT_CUNIT_INPUT USING GT_DATA-ZVALUE30
                                   CHANGING GT_6210-BSTME.

  PERFORM BAPI_CURRENCY_CONV_TO_INTERNAL USING GT_DATA-ZVALUE31
                                               GT_DATA-ZVALUE32
                                      CHANGING GT_6210-WAERS
                                               GT_6210-NETPR.

  GT_6210-PEINH = GT_DATA-ZVALUE33.

  "WAERS 참조 안함: 소수점 값으로 원화 금액이 넘어옴
  PERFORM REMOVE_SEP USING GT_DATA-ZVALUE34
                  CHANGING GT_6210-NETWR.

  GT_6210-INFNR = |{ GT_DATA-ZVALUE35 ALPHA = IN }|.

  GT_6210-ZMTGRP = GT_DATA-ZVALUE36.

  GT_6210-ZWEIGHT   = GT_DATA-ZVALUE37.
  GT_6210-ZLENGTH_1 = GT_DATA-ZVALUE38.
  GT_6210-ZLENGTH_2 = GT_DATA-ZVALUE39.
  GT_6210-ZLENGTH_3 = GT_DATA-ZVALUE40.
  GT_6210-ZLENGTH_4 = GT_DATA-ZVALUE41.
  GT_6210-ZLENGTH_5 = GT_DATA-ZVALUE42.
  GT_6210-ZLENGTH_6 = GT_DATA-ZVALUE43.
  GT_6210-ZLENGTH_7 = GT_DATA-ZVALUE44.

  MOVE-CORRESPONDING GS_CREA TO GT_6210.
  APPEND GT_6210.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTMMT6211
*&---------------------------------------------------------------------*
FORM SAVE_ZGTMMT6211.

  PERFORM MAKE_ZGTMMT6211.

  IF GT_6211[] IS INITIAL.
    PERFORM SET_RST_MSG USING 'E' '[ZGTMMT6211] 저장할 내역이 없습니다.'(M06).
    EXIT.
  ENDIF.

  IF LINE_EXISTS( GT_6211[ JOBLS = SPACE ] ).
    PERFORM SET_RST_MSG USING 'E' '구성품을 매핑할 수 없습니다.'(M07).
    EXIT.
  ENDIF.

  MODIFY ZGTMMT6211 FROM TABLE GT_6211.

  IF SY-SUBRC = 0.
    COMMIT WORK.
    PERFORM SET_RST_MSG USING 'S' 'SUCCESS'(M02).
  ELSE.
    ROLLBACK WORK.
    PERFORM SET_RST_MSG USING 'E' '[ZGTMMT6211] 구매확정 저장 DB 에러'(M08).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ZGTMMT6211
*&---------------------------------------------------------------------*
FORM MAKE_ZGTMMT6211.

  CLEAR : GT_6211[].

  READ TABLE GT_DATA WITH KEY ZTABLE = GC_ZGTMMT6211
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_DATA FROM SY-TABIX.
    IF GT_DATA-ZTABLE <> GC_ZGTMMT6211.
      EXIT.
    ENDIF.

    CLEAR : GT_6211.
    GT_6211-MES_REQ = GT_DATA-ZKEY2.
    GT_6211-MES_SEQ = GT_DATA-ZKEY3.

    "기저장된 MES_REQ/MES_SEQ는 대상에서 제외
    READ TABLE GT_MES WITH KEY MES_REQ = GT_6211-MES_REQ
                               MES_SEQ = GT_6211-MES_SEQ
                               BINARY SEARCH.

    IF SY-SUBRC = 0 AND GT_MES-JOB_NO IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM SET_6211_VAL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6211_VAL
*&---------------------------------------------------------------------*
FORM SET_6211_VAL.

  GT_6211-JOBLS   = GT_MES-JOBLS.
  GT_6211-MES_CMP = GT_DATA-ZKEY4.
  GT_6211-JOB_NO  = GT_DATA-ZKEY1.

  PERFORM CONVERT_MATN1_INPUT USING GT_DATA-ZVALUE01
                           CHANGING GT_6211-MATNR.

  PERFORM REMOVE_SEP USING GT_DATA-ZVALUE02
                  CHANGING GT_6211-BDMNG.

  PERFORM CONVERSION_EXIT_CUNIT_INPUT USING GT_DATA-ZVALUE03
                                   CHANGING GT_6211-MEINS.

  MOVE-CORRESPONDING GS_CREA TO GT_6211.
  APPEND GT_6211.

ENDFORM.
