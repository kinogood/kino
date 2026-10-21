FUNCTION ZGTMM_IF_I_MDOCANCEL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"     VALUE(I_MJAHR) TYPE  MJAHR
*"     VALUE(I_MBLNR) TYPE  MBLNR
*"  EXPORTING
*"     VALUE(MJAHR) TYPE  MJAHR
*"     VALUE(MBLNR) TYPE  MBLNR
*"     VALUE(MJAHR_C) TYPE  MJAHR
*"     VALUE(MBLNR_C) TYPE  MBLNR
*"     VALUE(ZRESULT) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_MDOCANCEL
*& 프로그램 명 : 자재 문서 취소 정보 수신
*& 개요   : 자재 문서 취소 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.28
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.12.09
*& 수정자  : ZLSGMM3
*& 수정개요: 소재 MOM 경우 내자/수입 구매입고취소도 ZGTMM_IF_I_MDOCANCEL
*&         : 사용하기에 해당 로직 추가
*&---------------------------------------------------------------------*

  IF I_MJAHR IS INITIAL OR I_MBLNR IS INITIAL.
    ZO_RESULT  = GC_02.
    ZO_MESSAGE = '필수값이 누락되었습니다.'(M12).
    RETURN.
  ENDIF.

  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' 'MM00014' ' ' ' '.

  CLEAR : GV_MBLNR, GV_MJAHR, GS_MHDRT.

  GV_MBLNR = MBLNR = I_MBLNR. "자재문서번호
  GV_MJAHR = MJAHR = I_MJAHR. "자재전표연도
  GV_MBLNR = |{ GV_MBLNR ALPHA = IN }|.

  PERFORM SET_9150_LOG USING 'S' ' ' ' '.

  PERFORM CHECK_MDOCANCEL CHANGING ZRESULT
                                   MESSAGE.

  IF ZRESULT = GC_E.
    PERFORM SET_EAI_MSG USING 'E' CHANGING ZO_RESULT
                                           ZO_MESSAGE.

    PERFORM SET_9150_LOG USING 'E' ZRESULT MESSAGE.
    PERFORM SET_COM_LOG  USING 'E' ' '
                                   ZRESULT ZO_MESSAGE.
    RETURN.
  ENDIF.

  "자재 문서 취소
  PERFORM GOODSMVT_MDOCANCEL CHANGING MJAHR_C
                                      MBLNR_C
                                      ZRESULT
                                      MESSAGE.

  PERFORM SET_EAI_MSG USING ZRESULT CHANGING ZO_RESULT
                                             ZO_MESSAGE.

  PERFORM SET_9150_LOG USING 'E' ZRESULT MESSAGE.
  PERFORM SET_COM_LOG  USING 'E' ' '
                                 ZRESULT ZO_MESSAGE.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_9150_LOG
*&---------------------------------------------------------------------*
FORM SET_9150_LOG USING PV_TYPE
                        PV_ZRESULT
                        PV_MESSAGE.

  "수신 Data Log Table 저장

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_9150, GT_9150[].

      GT_9150 = VALUE #( ZIFKEY = GT_9000-ZIFKEY
                         MBLNR  = GV_MBLNR
                         MJAHR  = GV_MJAHR ).

      MODIFY ZGTMMT9150 FROM GT_9150.

    WHEN 'E'. "End
      UPDATE ZGTMMT9150 SET MBLNR_C = GS_MHDRT-MAT_DOC
                            MJAHR_C = GS_MHDRT-DOC_YEAR
                            ZRESULT = PV_ZRESULT
                            MESSAGE = PV_MESSAGE
                      WHERE ZIFKEY  = GT_9000-ZIFKEY
                        AND MBLNR   = GV_MBLNR
                        AND MJAHR   = GV_MJAHR.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MDOCANCEL
*&---------------------------------------------------------------------*
FORM CHECK_MDOCANCEL CHANGING PV_ZRESULT
                              PV_MESSAGE.

  CLEAR : GV_BUDAT.

  SELECT SINGLE BUDAT,
                CANCELLED,
                REVERSAL_MOVEMENT
    INTO @DATA(LS_MDOC)
    FROM MATDOC
   WHERE MJAHR = @GV_MJAHR
     AND MBLNR = @GV_MBLNR.


  IF SY-SUBRC <> 0.
    PV_ZRESULT = GC_E.
    PV_MESSAGE = '존재하지 않는 자재문서입니다.'(M13).
    EXIT.
  ENDIF.

  IF LS_MDOC-CANCELLED IS NOT INITIAL.
    PV_ZRESULT = GC_E.
    PV_MESSAGE = '이미 취소된 문서입니다.'(M14).
    EXIT.
  ENDIF.

  IF LS_MDOC-REVERSAL_MOVEMENT IS NOT INITIAL.
    PV_ZRESULT = GC_E.
    PV_MESSAGE = '역분개 문서를 취소할 수 없습니다.'(M15).
    EXIT.
  ENDIF.

*&-----------------------------------------------
*& 한미소(KFCM)의 경우 GR기준IV 체크 시
*& 송장생성되어 있으면 입고취소 불가     - [S]
*&-----------------------------------------------
  PERFORM CHECK_KFCM_IV_EXIST CHANGING PV_ZRESULT
                                       PV_MESSAGE.
  IF PV_ZRESULT = GC_E.
    EXIT.
  ENDIF.

*&-----------------------------------------------
*& 한미소(KFCM)의 경우 GR기준IV 체크 시
*& 송장생성되어 있으면 입고취소 불가     - [E]
*&-----------------------------------------------


  GV_BUDAT = LS_MDOC-BUDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODSMVT_MDOCANCEL
*&---------------------------------------------------------------------*
FORM GOODSMVT_MDOCANCEL CHANGING PV_MJAHR_C
                                 PV_MBLNR_C
                                 PV_ZRESULT
                                 PV_MESSAGE.

  PERFORM BAPI_GOODSMVT_CANCEL USING GV_MBLNR
                                     GV_MJAHR
                                     GV_BUDAT.

  READ TABLE GT_RTN WITH KEY TYPE = 'E'.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    PERFORM RTN_MDOCANCEL USING 'E' GT_RTN-MESSAGE
                       CHANGING PV_ZRESULT
                                PV_MESSAGE.
  ELSE.
    PERFORM BAPI_COMMIT.

    PV_MBLNR_C = GS_MHDRT-MAT_DOC.
    PV_MJAHR_C = GS_MHDRT-DOC_YEAR.
    PV_MBLNR_C = |{ PV_MBLNR_C ALPHA = OUT }|.

    PERFORM RTN_MDOCANCEL USING 'S' '역분개 되었습니다.'(M16)
                       CHANGING PV_ZRESULT
                                PV_MESSAGE.

*--> [CHM2510-00260] 소재 MOM 추가 로직 반영
**** 소재 101 구매입고 혹은 사내거래입고/출고 취소 시에만
    DATA : LV_BWART LIKE MATDOC-BWART,
           LV_EBELN LIKE MATDOC-EBELN.

    IF GV_SYSTEM_ID = 'KSCM'. "--> 소재 MOM 구분자

      SELECT SINGLE BWART, EBELN
        INTO (@LV_BWART, @LV_EBELN)
        FROM MATDOC
       WHERE MJAHR = @GV_MJAHR
         AND MBLNR = @GV_MBLNR
         AND BUKRS = '1000'
         AND WERKS = '1305'.

      IF LV_EBELN IS NOT INITIAL.
        IF LV_BWART = '101'. "--> 구매입고 취소
          "--> 꼬리표 CBO 반영
          PERFORM MODIFY_ZPPT0001_GRREV.
          "--> 수입 CBO 반영
          PERFORM MODIFY_IMPORT_GRREV.
        ELSEIF LV_BWART = '351'. "--> 사내거래출고 취소
          PERFORM MODIFY_ZPPT0001_GIREV USING GV_MBLNR
                                              GV_MJAHR.
        ENDIF.
      ENDIF.
    ENDIF.
*<-- [CHM2510-00260] 소재 MOM 추가 로직 반영

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_MDOCANCEL
*&---------------------------------------------------------------------*
FORM RTN_MDOCANCEL USING PV_RST
                         PV_MSG
                CHANGING PV_ZRESULT
                         PV_MESSAGE.

  PV_ZRESULT = PV_RST.
  PV_MESSAGE = PV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_MDOCANCEL
*&---------------------------------------------------------------------*
FORM MODIFY_IMPORT_GRREV.

  DATA : LV_IGRNO LIKE ZTITGRK-IGRNO.

  SELECT SINGLE IGRNO
    INTO LV_IGRNO
    FROM ZTITGRK
  WHERE MJAHR = GV_MJAHR
    AND MBLNR = GV_MBLNR
    AND BUKRS = GV_BUKRS.

  IF LV_IGRNO IS NOT INITIAL.
    DELETE FROM ZTITGRK
    WHERE IGRNO = LV_IGRNO.

    DELETE FROM ZTITGRP
    WHERE IGRNO = LV_IGRNO.

    DELETE FROM ZTITGRB
    WHERE IGRNO = LV_IGRNO.

    DELETE FROM ZTITGRH
    WHERE IGRNO = LV_IGRNO.

    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
