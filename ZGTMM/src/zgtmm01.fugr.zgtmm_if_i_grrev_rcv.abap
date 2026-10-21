FUNCTION ZGTMM_IF_I_GRREV_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"     VALUE(I_MBLNR) TYPE  MBLNR
*"     VALUE(I_MJAHR) TYPE  MJAHR
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_TAB STRUCTURE  ZGTMMSIF0019
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_GRREV_RCV
*& 프로그램 명 : 구매 입고 취소 정보 수신
*& 개요   : 구매 입고 취소 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.12
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' 'MM00010' ' ' ' '.

  CLEAR : GV_MBLNR, GV_MJAHR, GT_I19[].

  GV_MBLNR = I_MBLNR. "자재문서번호
  GV_MJAHR = I_MJAHR. "자재전표연도

  GV_MBLNR = |{ GV_MBLNR ALPHA = IN }|.

  PERFORM SET_9100_LOG USING 'S' ' ' ' '.

  "입고 처리 취소
  PERFORM GOODSMVT_RGR_RCV.

  "구매 입고 취소 처리 결과
  OT_TAB[] = GT_I19[].

  PERFORM SET_9100_LOG USING 'E' GT_I19-ZRESULT GT_I19-MESSAGE.
  PERFORM SET_COM_LOG  USING 'E' ' '
                                 GT_I19-ZRESULT GT_I19-MESSAGE.

  PERFORM SET_EAI_MSG USING GT_I19-ZRESULT CHANGING ZO_RESULT
                                                    ZO_MESSAGE.
* "Export Parameter : 고정값
* ZO_RESULT  = '00'.
* ZO_MESSAGE = '전송 데이터 처리 성공'.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_9100_LOG
*&---------------------------------------------------------------------*
FORM SET_9100_LOG USING PV_TYPE
                        PV_ZRESULT
                        PV_MESSAGE.

  "수신 Data Log Table 저장

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_9100, GT_9100[].

      GT_9100-ZIFKEY  = GT_9000-ZIFKEY.
      GT_9100-MBLNR_I = GV_MBLNR.
      GT_9100-MJAHR_I = GV_MJAHR.

      MODIFY ZGTMMT9100 FROM GT_9100.

    WHEN 'E'. "End
      UPDATE ZGTMMT9100 SET MBLNR_C = GS_MHDRT-MAT_DOC
                            MJAHR_C = GS_MHDRT-DOC_YEAR
                            ZRESULT = PV_ZRESULT
                            MESSAGE = PV_MESSAGE
                      WHERE ZIFKEY  = GT_9000-ZIFKEY
                        AND MBLNR_I = GV_MBLNR
                        AND MJAHR_I = GV_MJAHR.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODSMVT_RGR_RCV
*&---------------------------------------------------------------------*
FORM GOODSMVT_RGR_RCV.

  CLEAR : GV_BUDAT, GS_MHDRT, GT_I19, GT_I19[].

  SELECT SINGLE BUDAT
    FROM MKPF INTO GV_BUDAT
   WHERE MBLNR = GV_MBLNR
     AND MJAHR = GV_MJAHR.


*[프로젝트 개선] 아래 취소시킬 전표가 없음도 표시해줘야 함 - [S] ZLSGMM4
*  CHECK SY-SUBRC = 0. "주석처리
  IF SY-SUBRC <> 0.
    DATA(LV_TEXT) = |자재문서 { GV_MBLNR } / { GV_MJAHR } 가 존재하지 않습니다.|.
    PERFORM RTN_GRREV_RCV USING 'E' LV_TEXT.

    RETURN.
  ENDIF.

*[프로젝트 개선] 아래 취소시킬 전표가 없음도 표시해줘야 함 - [E]


  PERFORM BAPI_GOODSMVT_CANCEL USING GV_MBLNR
                                     GV_MJAHR
                                     GV_BUDAT.

  READ TABLE GT_RTN WITH KEY TYPE = 'E'.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    PERFORM RTN_GRREV_RCV USING 'E' GT_RTN-MESSAGE.
  ELSE.
    PERFORM BAPI_COMMIT.

    PERFORM RTN_GRREV_RCV USING 'S' '구매 입고 취소 성공'(M06).

    PERFORM MODIFY_ZPPT0001_GRREV.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_GRREV_RCV
*&---------------------------------------------------------------------*
FORM RTN_GRREV_RCV USING PV_RST
                         PV_MSG.

  CLEAR : GT_I19.

  IF PV_RST = 'S'.
    GT_I19-MBLNR = GS_MHDRT-MAT_DOC.
    GT_I19-MJAHR = GS_MHDRT-DOC_YEAR.
    GT_I19-BUDAT = GV_BUDAT.

    GT_I19-MBLNR = |{ GT_I19-MBLNR ALPHA = OUT }|.
  ENDIF.

  GT_I19-ZRESULT = PV_RST.
  GT_I19-MESSAGE = PV_MSG.

  APPEND GT_I19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_GRREV
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001_GRREV.

  DATA : LV_AUFNR LIKE ZPPT0001-AUFNR,
         LV_POSNR LIKE ZPPT0001-POSNR.


  PERFORM BAPI_GOODSMVT_GETDETAIL USING GV_MBLNR
                                        GV_MJAHR.

  CHECK GT_DITM[] IS NOT INITIAL.

  LOOP AT GT_DITM.

    "--> 주석처리. 배치 X 인데 꼬리표 있는 경우도 있음
*    CHECK GT_DITM-BATCH IS NOT INITIAL.

    LV_AUFNR = |{ GT_DITM-PO_NUMBER ALPHA = IN }|.
    LV_POSNR = GT_DITM-PO_ITEM.

    UPDATE ZPPT0001 SET GRFLG   = 'N'
                        LGORT   = ' '
                        MBLNR   = ' '
                        MGVRG   = ' '
                        REMAIN  = ' '
                        WKDAT   = ' '
                        GRINDAT =  SY-DATUM
                        GRINTIM =  SY-UZEIT
                        GRINNAM =  SY-UNAME
                  WHERE WERKS = GT_DITM-PLANT
                    AND AUFNR = LV_AUFNR
                    AND POSNR = LV_POSNR
                    AND CHARG = GT_DITM-BATCH
                    AND MBLNR = GV_MBLNR
                    AND MATNR = GT_DITM-MATERIAL.

    IF SY-SUBRC = 0.
      DATA(L_CHK) = 'X'.
    ENDIF.
  ENDLOOP.

  CHECK L_CHK = 'X'.
  COMMIT WORK.

ENDFORM.
