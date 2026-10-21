FUNCTION ZGTMM_IF_I_RETURN_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"     VALUE(I_DATE) TYPE  DATS
*"     VALUE(I_ZTYPE) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTMMSIF0025
*"      OT_HEAD STRUCTURE  ZGTMMSIF0026
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_RETURN_RCV
*& 프로그램 명 : 반품 출고 정보 수신
*& 개요   : 반품 출고 정보 수신용 RFC (From WMS)
*& 생성일 : 2025.06.12
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  GV_SYSTEM_ID = I_SYSTEM_ID.
  GV_ZTYPE = I_ZTYPE.

*--> GV_ZTYPE = C 입고취소일 경우 유효성 체크
  DATA : LV_MBLNR TYPE MBLNR.
  IF GV_ZTYPE = 'C'.
    SORT IT_ITEM BY MJAHR MBLNR ZEILE.
    LOOP AT IT_ITEM.
*      AT FIRST.
*        LV_MBLNR = IT_ITEM-MBLNR.
*      ENDAT.
      IF SY-TABIX = 1.
        LV_MBLNR = IT_ITEM-MBLNR.
      ENDIF.

      IF LV_MBLNR <> IT_ITEM-MBLNR.
        ZO_RESULT  = GC_01.
        ZO_MESSAGE = '입고취소는 1개 입고문서만 가능합니다.'(M04).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CHECK ZO_RESULT <> GC_01.
*<-- GV_ZTYPE = C 입고취소일 경우 유효성 체크

  PERFORM SET_COM_LOG USING 'S' 'MM00019' ' ' ' '.

  CLEAR : GT_I25[], GT_I26[].

  GT_I25[] = IT_ITEM[].
  SORT GT_I25 BY MJAHR MBLNR ZEILE.

  PERFORM SET_9170_LOG USING 'S'.

  PERFORM RUN_RTN_RCV USING I_DATE.

  OT_HEAD[] = GT_I26[].

  PERFORM SET_9170_LOG USING 'E'.
  PERFORM SET_COM_LOG  USING 'E' ' ' GV_RST GV_MSG.

  IF GV_RST = GC_S.
    ZO_RESULT  = GC_00.
    ZO_MESSAGE = '전송 데이터 처리 성공'(M03).
  ELSE.
    ZO_RESULT  = GC_02.
    ZO_MESSAGE = GV_MSG.
  ENDIF.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_9170_LOG
*&---------------------------------------------------------------------*
FORM SET_9170_LOG USING PV_TYPE.

  "수신 Data Log Table 저장

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_9170[].

      LOOP AT GT_I25.
        GT_I25-MBLNR = |{ GT_I25-MBLNR ALPHA = IN }|.
        PERFORM CONVERT_MATN1_INPUT USING GT_I25-MATNR.
        MODIFY GT_I25 TRANSPORTING MBLNR MATNR.

        CLEAR : GT_9170.
        MOVE-CORRESPONDING GT_I25 TO GT_9170.
        GT_9170-ZIFKEY = GT_9000-ZIFKEY.
        GT_9170-ZTYPE = GV_ZTYPE.

        APPEND GT_9170.
      ENDLOOP.

      MODIFY ZGTMMT9170 FROM TABLE GT_9170.

    WHEN 'E'. "End
      UPDATE ZGTMMT9170 SET MJAHR_R = GS_MHDRT-DOC_YEAR
                            MBLNR_R = GS_MHDRT-MAT_DOC
                      WHERE ZIFKEY  = GT_9000-ZIFKEY.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_RTN_RCV
*&---------------------------------------------------------------------*
FORM RUN_RTN_RCV USING PV_DATE.

  IF GV_ZTYPE <> 'C'. "--> 반품
    PERFORM GET_RPO.
    "Header
    PERFORM SET_RTN_HEAD USING PV_DATE.
    "Item
    LOOP AT GT_I25.
      PERFORM SET_RTN_ITEM.
    ENDLOOP.
    "BAPI
    PERFORM BAPI_GOODSMVT_CREATE.
  ELSE. "--> 입고취소
    "--> CLEAR
    CLEAR : GS_MHDR, GS_MCOD, GS_MHDRT,
            GT_MITM, GT_MITM[], GT_RTN, GT_RTN[].
    CLEAR : GS_MHDR_C.
    CLEAR : GT_MITM_C, GT_MITM_C[].
    "--> HEADER
    DATA : LV_DATE TYPE BUDAT.
    READ TABLE GT_I25 INDEX 1.

    SELECT SINGLE BUDAT
      INTO LV_DATE
      FROM MKPF
     WHERE MBLNR = GT_I25-MBLNR
       AND MJAHR = GT_I25-MJAHR.

    GS_MHDR_C-MAT_DOC    = GT_I25-MBLNR.
    GS_MHDR_C-DOC_YEAR   = GT_I25-MJAHR.
    GS_MHDR_C-PSTNG_DATE = LV_DATE. "--> 입고문서 전기일 사용

    "--> ITEM
    LOOP AT GT_I25.
      GT_MITM_C-MATDOC_ITEM = GT_I25-ZEILE.
      APPEND GT_MITM_C.
    ENDLOOP.

    "--> BAPI
    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GS_MHDR_C-MAT_DOC
        MATDOCUMENTYEAR     = GS_MHDR_C-DOC_YEAR
        GOODSMVT_PSTNG_DATE = GS_MHDR_C-PSTNG_DATE
      IMPORTING
        GOODSMVT_HEADRET    = GS_MHDRT
      TABLES
        RETURN              = GT_RTN
        GOODSMVT_MATDOCITEM = GT_MITM_C.
  ENDIF.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.
    PERFORM RST_RTN_RCV USING 'E'.
  ELSE.
    PERFORM BAPI_COMMIT.
    PERFORM RST_RTN_RCV USING 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_RPO
*&---------------------------------------------------------------------*
FORM GET_RPO.

  GT_RPO[] = CORRESPONDING #( GT_I25[] ).

  SORT GT_RPO BY MBLNR MJAHR ZEILE.
  DELETE ADJACENT DUPLICATES FROM GT_RPO COMPARING MBLNR MJAHR ZEILE.

  CHECK GT_RPO[] IS NOT INITIAL.

  SELECT MBLNR
         MJAHR
         ZEILE
         EBELN
         EBELP
    FROM MATDOC
    INTO CORRESPONDING FIELDS OF TABLE GT_RPO
     FOR ALL ENTRIES IN GT_RPO
   WHERE MBLNR = GT_RPO-MBLNR
     AND MJAHR = GT_RPO-MJAHR
     AND ZEILE = GT_RPO-ZEILE.

  SORT GT_RPO BY MBLNR MJAHR ZEILE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTN_HEAD
*&---------------------------------------------------------------------*
FORM SET_RTN_HEAD USING PV_DATE.

  CLEAR : GS_MHDR, GS_MCOD, GS_MHDRT,
          GT_MITM, GT_MITM[], GT_RTN, GT_RTN[].

  GS_MHDR-PSTNG_DATE = PV_DATE. "전기일
  GS_MHDR-DOC_DATE   = PV_DATE. "증빙일
  GS_MCOD-GM_CODE = GC_01. "구매입고

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTN_ITEM
*&---------------------------------------------------------------------*
FORM SET_RTN_ITEM.

  CLEAR : GT_MITM.

  GT_MITM-MATERIAL   = GT_I25-MATNR.
  GT_MITM-PLANT      = GT_I25-WERKS.
  GT_MITM-STGE_LOC   = GT_I25-LGORT.
  GT_MITM-BATCH      = GT_I25-CHARG.
  GT_MITM-MOVE_TYPE  = GC_122.
  GT_MITM-ENTRY_QNT  = GT_I25-MENGE.
  GT_MITM-ENTRY_UOM  = GT_I25-MEINS.
  GT_MITM-MVT_IND    = GC_B.
  GT_MITM-MOVE_REAS  = GT_I25-GRUND.
  GT_MITM-REF_DOC_YR = GT_I25-MJAHR.
  GT_MITM-REF_DOC    = GT_I25-MBLNR.
  GT_MITM-REF_DOC_IT = GT_I25-ZEILE.

  READ TABLE GT_RPO WITH KEY MBLNR = GT_I25-MBLNR
                             MJAHR = GT_I25-MJAHR
                             ZEILE = GT_I25-ZEILE
                             BINARY SEARCH.

  IF SY-SUBRC = 0.
    GT_MITM-PO_NUMBER = GT_RPO-EBELN.
    GT_MITM-PO_ITEM   = GT_RPO-EBELP.
  ENDIF.

  APPEND GT_MITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RST_RTN_RCV
*&---------------------------------------------------------------------*
FORM RST_RTN_RCV USING PV_RST.

  DATA : LV_MSG TYPE BAPI_MSG.


  CLEAR : GT_I26.
  CLEAR : GV_RST, GV_MSG.

  CASE PV_RST.
    WHEN 'S'.
      GT_I26-MBLNR = GS_MHDRT-MAT_DOC.
      GT_I26-MJAHR = GS_MHDRT-DOC_YEAR.

      IF GV_ZTYPE <> 'C'.
        LV_MSG = '반품 처리되었습니다.'(M01).
      ELSE.
        LV_MSG = '입고취소 처리되었습니다.'(M01).
      ENDIF.

    WHEN 'E'.
      LV_MSG = GT_RTN-MESSAGE.
  ENDCASE.

  PERFORM SET_RTN_RCV USING PV_RST
                            LV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTN_RCV
*&---------------------------------------------------------------------*
FORM SET_RTN_RCV USING PV_RST
                       PV_MSG.

  GT_I26-ZRESULT = GV_RST = PV_RST.
  GT_I26-MESSAGE = GV_MSG = PV_MSG.
  APPEND GT_I26.

  CHECK PV_RST = GC_S.
  IF GV_ZTYPE <> 'C'.
    GV_MSG = '반품 성공'(M02).
  ELSE.
    GV_MSG = '입고취소 성공'(M02).
  ENDIF.
ENDFORM.
