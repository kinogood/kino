FUNCTION ZGTMM_BDMES_COMP_TF.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4 DEFAULT 'KBDM'
*"     VALUE(I_ZGRCD) TYPE  ZGTE_BD_ZGRCD
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(I_ZIFKEY) TYPE  ZGTEIFKEY OPTIONAL
*"     VALUE(IS_HEAD) TYPE  ZGTMMSIF0069
*"     VALUE(IS_PASS) TYPE  ZGTMMSIF0070 OPTIONAL
*"  EXPORTING
*"     VALUE(O_MBLNR) TYPE  MBLNR
*"     VALUE(O_MJAHR) TYPE  MJAHR
*"     VALUE(O_IV_NO) TYPE  ZIV_NO
*"     VALUE(O_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(O_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTMMSIF0071 OPTIONAL
*"      OT_RTN STRUCTURE  ZGTMMSIF0068 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_COMP_TF
*& 프로그램 명 : [BD] 사급자재 출고 I/F 수신
*& 개요   : 부스닥트 생산 시스템에서 외주 임가공 업체에 구성품을 출고 처리
*& 생성일 : 2025.01.02
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기값 Setting
  O_RESULT = GC_S.
  CLEAR : O_MESSAGE, O_MBLNR, O_MJAHR, O_IV_NO, OT_RTN[].

  GV_SYSTEM_ID = I_SYSTEM_ID.
  GV_ZGRCD     = I_ZGRCD.
  GV_WERKS     = I_WERKS.
  GV_ZIFKEY    = I_ZIFKEY.
  PERFORM SET_COM_LOG USING 'S' 'MM00065' ' ' ' '.

  CLEAR : GS_I69, GS_I70, GT_I71[], GT_OTN[].
  CLEAR : GV_RST, GV_MSG, GS_MDOC.

  GS_I69   = IS_HEAD.
  GS_I70   = IS_PASS.
  GT_I71[] = IT_ITEM[].

  PERFORM CHECK_CGX_RCV.
  PERFORM SET_6040_LOG USING 'S'.

  IF GT_OTN[] IS NOT INITIAL.
    PERFORM SET_CGX_RTN TABLES OT_RTN
                      CHANGING O_RESULT
                               O_MESSAGE
                               O_MBLNR
                               O_MJAHR
                               O_IV_NO.
    RETURN.
  ENDIF.

  CASE GV_ZGRCD.
    WHEN 'C'. "취소
      PERFORM RUN_CGC_RCV.
    WHEN 'T'. "사급출고
      PERFORM RUN_CGR_RCV.
  ENDCASE.

  PERFORM SET_CGX_RTN TABLES OT_RTN
                    CHANGING O_RESULT
                             O_MESSAGE
                             O_MBLNR
                             O_MJAHR
                             O_IV_NO.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form CHECK_CGX_RCV
*&---------------------------------------------------------------------*
FORM CHECK_CGX_RCV.

  DATA : LV_MSG(100).


  "입력값 점검

  CASE GV_ZGRCD.
    WHEN 'T'. "사급출고
      IF GT_I71[] IS INITIAL.
        PERFORM SET_RTN_MSG USING 'E' '사급자재 출고 처리할 아이템을 입력하세요.'(M18).
        EXIT.
      ENDIF.

      IF GS_I69-LIFNR IS INITIAL.
        PERFORM SET_RTN_MSG USING 'E' '출고 처리 할 공급업체를 입력하세요.'(M19).
        EXIT.
      ELSE.
        GS_I69-LIFNR = |{ GS_I69-LIFNR ALPHA = IN }|.
      ENDIF.

      IF GS_I70-REQST = GC_X.
        IF LINE_EXISTS( GT_I71[ PSCHK = GC_X ] ).
        ELSE.
          PERFORM SET_RTN_MSG USING 'E' '통문 출고 대상 자재가 없습니다.'(M20).
          EXIT.
        ENDIF.

        CLEAR : LV_MSG.
        LV_MSG = COND #( WHEN GS_I70-PERNR        IS INITIAL THEN '사원번호를 입력하세요.'(M21)
                         WHEN GS_I70-DRIVER_NM    IS INITIAL THEN '운전자 이름을 입력하세요.'(M22)
                         WHEN GS_I70-DRIVER_TELNO IS INITIAL THEN '운전자 전화번호를 입력하세요.'(M23)
                         WHEN GS_I70-TRUCK_NO     IS INITIAL THEN '차량번호를 입력하세요.'(M24) ).

        IF LV_MSG IS NOT INITIAL.
          PERFORM SET_RTN_MSG USING 'E' LV_MSG.
          GV_MSG = '통문처리 필드를 입력하세요.'(M25).
          EXIT.
        ENDIF.
      ENDIF.

      LOOP AT GT_I71.
        GT_I71-VBELN = |{ GT_I71-VBELN ALPHA = IN }|.
        PERFORM CONVERT_MATN1_INPUT USING GT_I71-MATNR.
        MODIFY GT_I71 TRANSPORTING VBELN MATNR.
      ENDLOOP.

      PERFORM CHECK_STK_DATA.

      IF GV_ERR = GC_X.
*       GV_MSG = '재고가 부족한 자재가 존재합니다.'(M26). "변경(PSJ 25.06.17)
        EXIT.
      ENDIF.

    WHEN 'C'. "취소
      IF GS_I69-SMBLN IS INITIAL AND GS_I69-SJAHR IS INITIAL.
        PERFORM SET_RTN_MSG USING 'E' '취소할 자재문서를 입력하세요.'(M10).
        EXIT.
      ENDIF.

      GS_I69-SMBLN = |{ GS_I69-SMBLN ALPHA = IN }|.

    WHEN OTHERS.
      PERFORM SET_RTN_MSG USING 'E' '처리 구분값은 T 또는 C를 입력해야 합니다.'(M27).
      EXIT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_STK_DATA
*&---------------------------------------------------------------------*
FORM CHECK_STK_DATA.

  DATA : BEGIN OF LT_STK OCCURS 0,
           MATNR TYPE ZGTMM_CV_GET_STOCKLIST-MATNR,
           WERKS TYPE ZGTMM_CV_GET_STOCKLIST-WERKS,
           LGORT TYPE ZGTMM_CV_GET_STOCKLIST-LGORT,
           CHARG TYPE ZGTMM_CV_GET_STOCKLIST-CHARG,
           VBELN TYPE ZGTMM_CV_GET_STOCKLIST-VBELN,
           POSNR TYPE ZGTMM_CV_GET_STOCKLIST-POSNR,
           LABST TYPE ZGTMM_CV_GET_STOCKLIST-LABST,
           MEINS TYPE ZGTMM_CV_GET_STOCKLIST-MEINS,
         END   OF LT_STK.

  DATA : LV_MSG(100),
         LV_MATNR TYPE MATNR.


  CLEAR : GV_ERR.
  CHECK GT_I71[] IS NOT INITIAL.

  LT_STK[] = CORRESPONDING #( GT_I71[] ).

  SORT LT_STK BY MATNR LGORT CHARG VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_STK COMPARING MATNR LGORT CHARG VBELN.

  SELECT MATNR,
         WERKS,
         LGORT,
         CHARG,
         VBELN,
         POSNR,
         LABST,
         MEINS
    FROM ZGTMM_CV_GET_STOCKLIST
    INTO CORRESPONDING FIELDS OF TABLE @LT_STK
     FOR ALL ENTRIES IN @LT_STK
   WHERE MATNR = @LT_STK-MATNR
     AND WERKS = @GV_WERKS
     AND LGORT = @LT_STK-LGORT
     AND CHARG = @LT_STK-CHARG
     AND VBELN = @LT_STK-VBELN.

  IF LT_STK[] IS NOT INITIAL.
*   LT_STK-POSNR = GC_000000.
    MODIFY LT_STK TRANSPORTING POSNR
                         WHERE POSNR = ' '.

    SORT LT_STK BY MATNR LGORT CHARG VBELN POSNR.
  ENDIF.

  LOOP AT GT_I71.
    CLEAR : LT_STK, LV_MSG.
    READ TABLE LT_STK WITH KEY MATNR = GT_I71-MATNR
                               LGORT = GT_I71-LGORT
                               CHARG = GT_I71-CHARG
                               VBELN = GT_I71-VBELN
                               POSNR = GT_I71-VBELP
                               BINARY SEARCH.

    IF LT_STK-LABST < GT_I71-LFIMG.
      "(S)메세지 변경(PSJ 25.06.17)
      " 현재 MES에서 OT_RTN 값을 읽지도 않고 있다 함. O_MESSAGE에 여러건 중 한건만 Return
      LV_MATNR = GT_I71-MATNR.
      PERFORM CONVERT_MATN1_OUTPUT USING LV_MATNR.

      MESSAGE E079(ZGTMM01) WITH LV_MATNR LT_STK-LABST GT_I71-MEINS
         INTO LV_MSG. "'&1는 재고가 &2 &3 밖에 없습니다.'

*     MESSAGE E079(ZGTMM01) WITH GT_I71-MATNR LT_STK-LABST GT_I71-MEINS
*        INTO LV_MSG. "'&1는 재고가 &2 &3 존재합니다.'
      "(E)메세지 변경(PSJ 25.06.17)

      PERFORM SET_RTN_MSG USING 'E' LV_MSG.
      GV_ERR = GC_X.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6040_LOG
*&---------------------------------------------------------------------*
FORM SET_6040_LOG USING PV_TYPE.

  "수신 Data Log Table 저장

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_6040, GT_6040[].

      MOVE-CORRESPONDING GS_I69 TO GT_6040.
      MOVE-CORRESPONDING GS_I70 TO GT_6040.
      GT_6040-ZIFNO     = GT_9000-ZIFNO.
      GT_6040-ZIFKEY    = GT_9000-ZIFKEY.
      GT_6040-SYSTEM_ID = GT_9000-SYSTEM_ID.
      GT_6040-ZGRCD     = GV_ZGRCD.
      GT_6040-WERKS     = GV_WERKS.

      CASE GV_ZGRCD.
        WHEN 'T'. "사급출고
          GT_6040[] = CORRESPONDING #( GT_I71[] ).
          MODIFY GT_6040 TRANSPORTING ZIFNO
                                      ZIFKEY
                                      SYSTEM_ID
                                      ZGRCD
                                      WERKS
                                      LIFNR
                                      BUDAT
                                      BLDAT
                                      LFSNR
                                      BKTXT
                                      SMBLN
                                      SJAHR
                                      REQST
                                      PERNR
                                      ETC_NM
                                      DRIVER_NM
                                      DRIVER_TELNO
                                      TRUCK_NO
                                WHERE ZIFNO IS INITIAL.

        WHEN 'C'.
          APPEND GT_6040.

      ENDCASE.

      MODIFY ZGTMMT6040 FROM TABLE GT_6040.

    WHEN 'E'. "End
      UPDATE ZGTMMT6040 SET MBLNR       = GS_MDOC-MBLNR1
                            MJAHR       = GS_MDOC-MJAHR1
                            IV_NO       = GS_MDOC-IV_NO
                            ERDAT       = GS_CREA-ERDAT
                            ERDAT_LOCAL = GS_CREA-ERDAT_LOCAL
                            ERTIM       = GS_CREA-ERTIM
                            ERTIM_LOCAL = GS_CREA-ERTIM_LOCAL
                            ERNAM       = GS_CREA-ERNAM
                      WHERE ZIFNO       = GT_9000-ZIFNO
                        AND ZIFKEY      = GT_9000-ZIFKEY
                        AND SYSTEM_ID   = GT_9000-SYSTEM_ID
                        AND ZGRCD       = GV_ZGRCD.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGX_RTN
*&---------------------------------------------------------------------*
FORM SET_CGX_RTN TABLES PT_RTN STRUCTURE ZGTMMSIF0068
               CHANGING PV_RESULT
                        PV_MESSAGE
                        PV_MBLNR
                        PV_MJAHR
                        PV_IV_NO.

  PV_RESULT  = GV_RST.
  PV_MESSAGE = GV_MSG.
  PV_MBLNR   = GS_MDOC-MBLNR1.
  PV_MJAHR   = GS_MDOC-MJAHR1.
  PV_IV_NO   = GS_MDOC-IV_NO.
  PT_RTN[]   = GT_OTN[].

  PERFORM SET_TIMESTAMP USING 'X' ' '.

  PERFORM SET_6040_LOG USING 'E'.
  PERFORM SET_COM_LOG  USING 'E' ' ' GV_RST GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_CGC_RCV
*&---------------------------------------------------------------------*
FORM RUN_CGC_RCV.

  CLEAR : GS_XGR, GT_CGR, GT_CGR[].

  "입고 처리된 문서 정보
  SELECT SINGLE MBLNR AS MBLNR1
                MJAHR AS MJAHR1
                IV_NO
    FROM ZGTMMT6040
    INTO CORRESPONDING FIELDS OF GS_XGR
   WHERE ZGRCD = GC_T
     AND MBLNR = GS_I69-SMBLN
     AND MJAHR = GS_I69-SJAHR.

  IF SY-SUBRC <> 0.
    PERFORM SET_RTN_MSG USING 'E' '취소할 자재문서 번호가 없습니다.'(M12).
    EXIT.
  ENDIF.

  "취소 이력 정보
  SELECT ZIFKEY,
         MBLNR  AS MBLNR1,
         MJAHR  AS MJAHR1
    FROM ZGTMMT6040
   WHERE ZGRCD = @GC_C
     AND SMBLN = @GS_I69-SMBLN
     AND SJAHR = @GS_I69-SJAHR
     AND ERDAT IS NOT INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @GT_CGR.

  SORT GT_CGR BY ZIFKEY DESCENDING.
  READ TABLE GT_CGR INDEX 1.

  IF GT_CGR-MBLNR1 IS NOT INITIAL.
    PERFORM SET_RTN_MSG USING 'E' '이미 취소한 자재문서 입니다.'(M13).
    EXIT.
  ENDIF.

  "통문 여부 Check
  IF GS_XGR-IV_NO IS NOT INITIAL.
    SELECT SINGLE OUT_YN
      FROM ZLET0005 INTO @DATA(LV_OUT_YN)
     WHERE IV_NO = @GS_XGR-IV_NO.

    IF LV_OUT_YN <> SPACE. "통문 확정
      PERFORM SET_RTN_MSG USING 'E' '통문 확정된 자재문서 입니다.'(M28).
      EXIT.
    ENDIF.
  ENDIF.

  "IS_HEAD-SMBLN 취소
  PERFORM BAPI_CGC_RCV USING GS_I69-SMBLN
                             GS_I69-SJAHR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CGC_RCV
*&---------------------------------------------------------------------*
FORM BAPI_CGC_RCV USING PV_MBLNR
                        PV_MJAHR.

  CHECK PV_MBLNR IS NOT INITIAL.

  PERFORM GET_BUDAT USING PV_MBLNR
                          PV_MJAHR.

  PERFORM BAPI_GOODSMVT_CANCEL USING PV_MBLNR
                                     PV_MJAHR
                                     GV_BUDAT.

  PERFORM BAPI_CGX_RCV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CGX_RCV
*&---------------------------------------------------------------------*
FORM BAPI_CGX_RCV.

  DATA : LV_MSG(50).


  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    LV_MSG = COND #( WHEN GV_ZGRCD = GC_T THEN GT_RTN-MESSAGE
                     WHEN GV_ZGRCD = GC_C THEN '자재문서를 취소하지 못했습니다.'(M15) ).

    PERFORM SET_BAPI_MSG USING 'E' LV_MSG.

  ELSE.
    PERFORM BAPI_COMMIT.
    PERFORM SET_CGX_SUC.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGX_SUC
*&---------------------------------------------------------------------*
FORM SET_CGX_SUC.

  GS_MDOC-MBLNR1 = GS_MHDRT-MAT_DOC.
  GS_MDOC-MJAHR1 = GS_MHDRT-DOC_YEAR.

  DATA(LV_MSG) = GS_MHDRT-MAT_DOC && '/' && GS_MHDRT-DOC_YEAR && ` ` && '생성'(M16).
  PERFORM SET_RTN_MSG USING 'S' LV_MSG.

  CASE GV_ZGRCD.
    WHEN 'C'. "취소
      PERFORM UPDATE_ZLET0005 USING GS_XGR-IV_NO.
    WHEN 'T'. "사급출고
      PERFORM CREATE_ZLET0005.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_CGR_RCV
*&---------------------------------------------------------------------*
FORM RUN_CGR_RCV.

  "Header
  PERFORM SET_CGR_HEAD.

  SORT GT_I71 BY IFSEQ.

  LOOP AT GT_I71.
    PERFORM SET_CGR_ITEM. "Item
  ENDLOOP.

  PERFORM BAPI_CGR_RCV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_HEAD
*&---------------------------------------------------------------------*
FORM SET_CGR_HEAD.

  CLEAR : GS_MHDR,   GS_MCOD,  GS_MHDRT,
          GT_MITM[], GT_RTN[].

  GS_MHDR-PSTNG_DATE = SWITCH #( GS_I69-BUDAT WHEN ' ' THEN SY-DATLO ELSE GS_I69-BUDAT ).
  GS_MHDR-DOC_DATE   = SWITCH #( GS_I69-BLDAT WHEN ' ' THEN SY-DATLO ELSE GS_I69-BLDAT ).
  GS_MHDR-REF_DOC_NO = GS_I69-LFSNR.
  GS_MHDR-HEADER_TXT = GS_I69-BKTXT.

  GS_MCOD-GM_CODE = GC_04. "이전전기

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_ITEM
*&---------------------------------------------------------------------*
FORM SET_CGR_ITEM.

  CLEAR : GT_MITM.

  GT_MITM-MATERIAL   = GT_MITM-MATERIAL_LONG = GT_I71-MATNR. "자재번호
  GT_MITM-PLANT      = GV_WERKS.     "플랜트
  GT_MITM-STGE_LOC   = GT_I71-LGORT. "저장위치
  GT_MITM-BATCH      = GT_I71-CHARG. "배치번호
  GT_MITM-VENDOR     = GS_I69-LIFNR.
  GT_MITM-SALES_ORD  = GT_I71-VBELN.
  GT_MITM-S_ORD_ITEM = GT_I71-VBELP.
  GT_MITM-ENTRY_QNT  = GT_I71-LFIMG. "입력단위 수량
  GT_MITM-ENTRY_UOM  = GT_I71-MEINS. "입력단위

  GT_MITM-MOVE_TYPE  = SWITCH #( GT_I71-VBELN WHEN ' ' THEN GC_541 ELSE GC_413 ).

  IF GT_MITM-MOVE_TYPE = GC_413.
    GT_MITM-SPEC_STOCK     = GC_E.
    GT_MITM-MOVE_PLANT     = GV_WERKS.
    GT_MITM-MOVE_STLOC     = GC_2530. "외주창고
    GT_MITM-MOVE_BATCH     = GT_I71-CHARG.
    GT_MITM-VAL_SALES_ORD  = GT_I71-VBELN.
    GT_MITM-VAL_S_ORD_ITEM = GT_I71-VBELP.
  ENDIF.

  APPEND GT_MITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CGR_RCV
*&---------------------------------------------------------------------*
FORM BAPI_CGR_RCV.

  PERFORM BAPI_GOODSMVT_CREATE.

  PERFORM BAPI_CGX_RCV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ZLET0005
*&---------------------------------------------------------------------*
FORM CREATE_ZLET0005.

  CHECK GS_I70-REQST = GC_X.

  PERFORM GET_NUMBER USING '06' 'ZLE001'
                  CHANGING GS_MDOC-IV_NO.

  CHECK GS_MDOC-IV_NO IS NOT INITIAL.

  PERFORM SET_CGX_LE05.
  PERFORM SET_CGX_LE06.

  PERFORM MODIFY_ZLET0005.

  CHECK GV_CHK = GC_E.
  CLEAR : GS_MDOC-IV_NO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGX_LE05
*&---------------------------------------------------------------------*
FORM SET_CGX_LE05.

  CLEAR : GT_LE05, GT_LE05[].

  GT_LE05-IV_NO        = GS_MDOC-IV_NO.       "거래명세서 번호(통문번호)
  GT_LE05-IV_TYPE      = GC_B01.              "통문유형(무상사급)
  GT_LE05-BWART        = GC_541.              "이동유형
  GT_LE05-DRIVER_NM    = GS_I70-DRIVER_NM.    "운전자명
  GT_LE05-DRIVER_TELNO = GS_I70-DRIVER_TELNO. "운전자전화번호
  GT_LE05-TRUCK_NO     = GS_I70-TRUCK_NO.     "차량번호
  GT_LE05-WERKS        = GV_WERKS.            "플랜트
  GT_LE05-ETC_NM       = GS_I70-ETC_NM.       "기타특기사항
  GT_LE05-KUNNR        = GS_I69-LIFNR.        "고객번호(공급업체)

  PERFORM SET_COM_LE05 USING GS_I70-PERNR.

  APPEND GT_LE05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGX_LE06
*&---------------------------------------------------------------------*
FORM SET_CGX_LE06.

  DATA : LV_SEQ   TYPE I,
         LV_ZEILE TYPE MBLPO.


  CLEAR : GT_LE06[].

  DATA(LT_I71) = GT_I71[].
  DELETE LT_I71 WHERE PSCHK <> GC_X.
  GT_MAKT[]    = CORRESPONDING #( LT_I71[] ).
  PERFORM GET_MAKT.

  LOOP AT GT_I71.
    "자재문서 항목: 전체 Item 기준으로 Line별 홀수 지정(1,3,5,7,9~~)
    LV_ZEILE = SY-TABIX + ( SY-TABIX - 1 ).

    CLEAR : GT_LE06.

    CHECK GT_I71-PSCHK = GC_X.
    LV_SEQ += 1.

    GT_LE06-IV_NO    = GS_MDOC-IV_NO.     "거래명세서 번호(통문번호)
    GT_LE06-IV_SEQ   = LV_SEQ.            "Line Seq
    GT_LE06-MBLNR    = GS_MDOC-MBLNR1.    "자재문서 번호
    GT_LE06-ZEILE    = LV_ZEILE.          "자재문서 항목
    GT_LE06-MJAHR    = GS_MDOC-MJAHR1.    "자재문서 연도
    GT_LE06-MATNR    = GT_I71-MATNR.      "자재번호
    PERFORM SET_MAKT USING GT_LE06-MATNR
                  CHANGING GT_LE06-MAKTX. "자재내역
    GT_LE06-CHARG    = GT_I71-CHARG.      "배치번호
    GT_LE06-LFIMG    = GT_I71-LFIMG.      "실제 납품 수량(판매 단위)
    GT_LE06-MTR_UNIT = GT_I71-MEINS.      "판매 단위
    GT_LE06-LGORT    = GT_I71-LGORT.      "저장위치

    APPEND GT_LE06.
  ENDLOOP.

ENDFORM.
