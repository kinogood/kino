*----------------------------------------------------------------------*
***INCLUDE LZGTMM01F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_scrap_kfcm_data
*&---------------------------------------------------------------------*
*& KFCM 한국미래소재 전용
*&---------------------------------------------------------------------*
FORM GET_SCRAP_KFCM_DATA .

  DATA: LT_SCRAP LIKE TABLE OF GS_SCRAP.
  CLEAR: LT_SCRAP, GS_SCRAP.

*- 한미소의 경우 SCRAP 부산물 자재 고정
  CLEAR: GS_SCRAP.
  CASE SY-MANDT.
    WHEN '210'.    "품질
      GS_SCRAP-MATNR = '000000000008531701'.
      GS_SCRAP-LGORT = '2190'.
    WHEN '100'.    "운영
      GS_SCRAP-MATNR = '000000000008531711'.
      GS_SCRAP-LGORT = '2190'.
    WHEN '600'.    "개발
      GS_SCRAP-MATNR = '000000000008531682'.
      GS_SCRAP-LGORT = '2190'.
  ENDCASE.


*- 자재코드 단위
  SELECT SINGLE MEINS
    FROM MARA
    INTO @GS_SCRAP-MEINS
   WHERE MATNR = @GS_SCRAP-MATNR.


*& ------------------------------
*   BDC 수행전 CHECK (1차 CHECK)
*& ------------------------------
  IF GS_SCRAP-MATNR IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '유효한 SCRAP자재가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '유효한 SCRAP자재가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- SCRAP 수량
  GS_SCRAP-MENGE = GS_ZGTMMT9250-MENGE.

  "SCRAP 수량 구하기(CONVERSION수량)
  PERFORM CONVERT_MAT_UNIT USING GS_ZGTMMT9250-MEINS
                                 GS_ZGTMMT9250-MATNR
                                 GS_SCRAP-MEINS
                           CHANGING GS_SCRAP-MENGE.

*- 원가차감 코드
  SELECT SINGLE PRCTR INTO @GS_SCRAP-PRCTR
    FROM MARC
   WHERE MATNR = @GS_ZGTMMT9250-MATNR
     AND WERKS = @GS_ZGTMMT9250-WERKS.


 "한미소의 경우 원가차감 코드 고정
  CASE SY-MANDT.
    WHEN '210'.
      GS_SCRAP-SP_MATNR = '000000000008531706'.
    WHEN '100'.
      GS_SCRAP-SP_MATNR = '000000000008531736'.
    WHEN '600' .
      GS_SCRAP-SP_MATNR = '000000000008531691'.
  ENDCASE.


*& ------------------------------
*   BDC 수행전 CHECK (2차 CHECK)
*& ------------------------------
  IF GS_SCRAP-MENGE IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '단위 환산된 SCRAP수량이 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '단위 환산된 SCRAP수량이 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.

  ELSEIF GS_SCRAP-PRCTR IS INITIAL.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '손익센터(MARC-PRCTR)가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '손익센터(MARC-PRCTR)가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.

  ELSEIF GS_SCRAP-MATNR IS INITIAL.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '원가차감코드(ZCOTP010-SP_MATNR)가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '원가차감코드(ZCOTP010-SP_MATNR)가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MAT_UNIT
*&---------------------------------------------------------------------*
*&  자재에 속한 단위로 변환하기
*&---------------------------------------------------------------------*
FORM CONVERT_MAT_UNIT  USING    LV_OLD_UNIT  " ZGTMMT9250_MEINS
                                LV_MATNR     " ZGTMMT9250_MATNR
                                LV_NEW_UNIT  " GS_SCRAP_MEINS
                       CHANGING LV_VALUE.    " GS_SCRAP_MENGE.

  IF LV_OLD_UNIT = LV_NEW_UNIT.
    EXIT.
  ENDIF.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = LV_MATNR
      I_IN_ME              = LV_OLD_UNIT
      I_OUT_ME             = LV_NEW_UNIT
      I_MENGE              = LV_VALUE
    IMPORTING
      E_MENGE              = LV_VALUE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

   IF SY-SUBRC NE 0.
     CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
       EXPORTING
         INPUT                = LV_VALUE
         UNIT_IN              = LV_OLD_UNIT
         UNIT_OUT             = LV_NEW_UNIT
       IMPORTING
         OUTPUT               = LV_VALUE
       EXCEPTIONS
         CONVERSION_NOT_FOUND = 1
         DIVISION_BY_ZERO     = 2
         INPUT_INVALID        = 3
         OUTPUT_INVALID       = 4
         OVERFLOW             = 5
         TYPE_INVALID         = 6
         UNITS_MISSING        = 7
         UNIT_IN_NOT_FOUND    = 8
         UNIT_OUT_NOT_FOUND   = 9
         OTHERS               = 10.

     IF SY-SUBRC NE 0.
       IF SY-MSGTY = 'E'.   "프로그램 덤프 방지 & 초기화
         SY-MSGTY = 'S'.
         LV_VALUE = 0.
       ENDIF.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.

ENDFORM. " Form CONVERT_MAT_UNIT
*&---------------------------------------------------------------------*
*& Form CRE_KFCM_CO_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_KFCM_CO_ORDER .

  DATA : LS_ZCOTP006 TYPE ZCOTP006.

*&---------------------------------------------------------------
*& CO 생산오더 생성
*&---------------------------------------------------------------
  CLEAR: GV_CO_ORDER, GV_MESSAGE_CO.

  PERFORM BDC_KKF1 USING    'C001'              "오더유형
                            GS_SCRAP-SP_MATNR   "원가차감코드
                            GS_ZGTMMT9250-WERKS "플랜트
                            GV_GSBER            "사업영역
                   CHANGING GV_CO_ORDER         "CO_생산오더
                            GV_MESSAGE_CO.      "메세지



*&---------------------------------------------------------------------*
*&  Scarp 대체 테이블 Update
*&---------------------------------------------------------------------*
*  IF GV_CO_ORDER IS NOT INITIAL.
*
*    LS_ZCOTP006 = VALUE #( CO_ORDER  = GV_CO_ORDER
*                           KOSTL     = GS_ZGTMMT9250-KOSTL
*                           SC_REASON = GS_ZGTMMT9250-SC_REASON
*                           BUDAT     = GS_ZGTMMT9250-BUDAT
*                           MATNR     = GS_ZGTMMT9250-MATNR
*                           WERKS     = GS_ZGTMMT9250-WERKS
*                           PRCTR     = GS_SCRAP-PRCTR
*                           LGORT     = GS_ZGTMMT9250-LGORT
*                           SP_MATNR  = GS_SCRAP-SP_MATNR
*                           CHARG     = GS_ZGTMMT9250-CHARG
*                           QTY       = GS_ZGTMMT9250-MENGE
*                           MEINS     = GS_ZGTMMT9250-MEINS
*                           SC_MATNR  = GS_SCRAP-MATNR
*                           SC_LGORT  = GS_SCRAP-LGORT
*                           SC_QTY    = GS_SCRAP-MENGE
*                           SC_MEINS  = GS_SCRAP-MEINS
*                           USNAM     = SY-UNAME
*                           MESSAGE   = GV_MESSAGE_CO ).
*
*    MODIFY ZCOTP006 FROM LS_ZCOTP006.
*    IF SY-SUBRC = 0.
*      COMMIT WORK.
*    ENDIF.
*
*  ELSE.
*    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
*                                            'E'
*                                            GV_MESSAGE_CO.
*
*    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
*                                         'E'
*                                         GV_MESSAGE_CO.
*    GV_ERROR = 'X'.
*    EXIT.
*  ENDIF.

  IF GV_CO_ORDER IS INITIAL.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER 'E' GV_MESSAGE_CO.
    PERFORM SAVE_RESULT_ZGTMMT9250    USING GV_CO_ORDER 'E' GV_MESSAGE_CO.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_CO_ORDER IS NOT INITIAL.

*&---------------------------------------------------------------------*
*& 자재출고처리
*&---------------------------------------------------------------------*
  CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.

*- 처리사유에 따른 SCRAP 이동유형(출고) 가져오기
  SELECT SINGLE OUT_BWART INTO @DATA(LV_BWART)
    FROM ZCOTP005
   WHERE SC_REASON = @GS_ZGTMMT9250-SC_REASON.

  PERFORM BDC_MB1A USING GS_ZGTMMT9250-BUDAT  "전기일
                         LV_BWART             "이동유형(출고)
                         GS_ZGTMMT9250-WERKS  "플랜트
                         GS_ZGTMMT9250-LGORT  "저장위치
                         GS_ZGTMMT9250-MATNR  "자재
                         GS_ZGTMMT9250-CHARG  "배치
                         GS_ZGTMMT9250-MENGE  "수량
                         GV_CO_ORDER          "CO_오더
                         GS_ZGTMMT9250-BKTXT  "폐기사유
                    CHANGING GV_MBLNR_O
                             GV_MESSAGE_MO.

*  PERFORM MODIFY_ZCOTP006_MBLNR_OUT(ZCOR0180)
*                                      USING ''
*                                            GV_CO_ORDER
*                                            GV_MBLNR_O
*                                            GV_MESSAGE_MO.

  IF GV_MBLNR_O IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MO.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING  GV_CO_ORDER
                                          'E'
                                          GV_MESSAGE_MO.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_O IS NOT INITIAL.

*&---------------------------------------------------------------------*
*& SCRAP 입고처리
*&---------------------------------------------------------------------*
  CLEAR : LV_BWART, GV_MBLNR_I, GV_MESSAGE_MI.

*- 처리사유에 따른 SCRAP 이동유형(입고) 가져오기
  SELECT SINGLE IN_BWART INTO @LV_BWART
      FROM ZCOTP005
     WHERE SC_REASON = @GS_ZGTMMT9250-SC_REASON.


  PERFORM BDC_MB1C USING    GS_ZGTMMT9250-BUDAT "전기일
                            LV_BWART            "이동유형
                            GS_ZGTMMT9250-WERKS "플랜트
                            GS_SCRAP-LGORT      "저장위치(SCRAP)
                            GS_SCRAP-MATNR      "자재(SCRAP)
                            ''                  "배치
                            GS_SCRAP-MENGE      "수량
                            GV_CO_ORDER         "CO 오더
                   CHANGING GV_MBLNR_I
                            GV_MESSAGE_MI.

*  PERFORM MODIFY_ZCOTP006_MBLNR_IN(ZCOR0180) USING ''
*                                                   GV_CO_ORDER
*                                                   GV_MBLNR_I
*                                                   GV_MESSAGE_MI.

  IF GV_MBLNR_I IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MI.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                         'E'
                                         GV_MESSAGE_MI.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_I IS NOT INITIAL.
*&---------------------------------------------------------------------*
*& 매출원가 대체용 SCRAP 0 입고처리
*&---------------------------------------------------------------------*
  CLEAR: GV_MBLNR_Z,GV_MESSAGE_MZ.
  PERFORM BDC_MB31 USING    GS_ZGTMMT9250-BUDAT  "전기일
                            '101'                "이동유형
                             GS_ZGTMMT9250-WERKS "플랜트
                             GS_SCRAP-LGORT      "저장위치(SCRAP)
                             GS_SCRAP-SP_MATNR   "원가차감코드
                             0                   "수량
                             GV_CO_ORDER         "CO 오더
                   CHANGING  GV_MBLNR_Z
                             GV_MESSAGE_MZ.

*  PERFORM MODIFY_ZCOTP006_MBLNR_ZERO(ZCOR0180) USING ''
*                                                     GV_CO_ORDER
*                                                     GV_MBLNR_Z
*                                                     GV_MESSAGE_MZ.

  IF GV_MBLNR_Z IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MZ.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                         'E'
                                         GV_MESSAGE_MZ.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_Z IS NOT INITIAL.

*- 성공
  PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                          'Y'
                                          GV_MESSAGE_MZ.

  PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                       'Y'
                                       GV_MESSAGE_MZ.

*&---------------------------------------------------------------------*
*& BDC 처리후 연결된 꼬리표의 잔량에서 처리량 만큼 감소시킴
*&---------------------------------------------------------------------*

*- 한국미래소재는 꼬리표 사용 안함



ENDFORM. "Form CRE_KFCM_CO_ORDER
*&---------------------------------------------------------------------*
*& Form BDC_KKF1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BDC_KKF1  USING VALUE(LV_SCRAP_TYPE) TYPE AUART
                     VALUE(LV_SC_MATNR)   TYPE MATNR
                     VALUE(LV_SC_WERKS)   TYPE WERKS_D
                     VALUE(LV_GSBER)      TYPE GSBER
               CHANGING LV_CO_ORDER       TYPE AUFNR
                        LV_MESSAGE_CO     TYPE BAPI_MSG.

  DATA: LV_SUBRC    TYPE SY-SUBRC,
        LV_ORDER_NO TYPE AUFNR,
        LV_KOKRS    TYPE KOKRS.

*- 관리회계 설정
  PERFORM GET_KOKRS USING LV_SC_WERKS
                    CHANGING LV_KOKRS.

  SET PARAMETER ID 'CAC' FIELD LV_KOKRS.
  PERFORM NUMBER_GET_NEXT CHANGING GV_CO_ORDER_TEMP.
  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0010'.
  PERFORM BDC_FIELD   USING : 'COAS-AUART' LV_SCRAP_TYPE,
                              'AFPO-MATNR' LV_SC_MATNR,
                              'AUFK-WERKS' LV_SC_WERKS,
                              'BDC_OKCODE'  '/00'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER_TEMP,
                              'COAS-GSBER' LV_GSBER,
                              'BDC_OKCODE'  '=SICH'.

  PERFORM BDC_TRANSACTION USING    C_TCODE_KKF1
                          CHANGING LV_SUBRC.

  PERFORM MESSAGE_KKF1 CHANGING LV_CO_ORDER
                                LV_MESSAGE_CO.

  CLEAR: GV_CO_ORDER_TEMP.

ENDFORM. "BDC_KKF1
*&---------------------------------------------------------------------*
*& Form GET_KOKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SC_WERKS
*&      <-- LV_KORKS
*&---------------------------------------------------------------------*
FORM GET_KOKRS  USING    PV_WERKS TYPE WERKS_D
                CHANGING PV_KOKRS TYPE KOKRS.

  IF PV_WERKS IS NOT INITIAL.
    SELECT SINGLE K~KOKRS
      INTO PV_KOKRS
      FROM T001K AS T
      JOIN TKA02 AS K
        ON T~BUKRS = K~BUKRS
     WHERE T~BWKEY = PV_WERKS.
  ENDIF.

ENDFORM. "Form GET_KOKRS
*&---------------------------------------------------------------------*
*& Form NUMBER_GET_NEXT
*&---------------------------------------------------------------------*
*& *       C001 오더 타입에 대한 오더 번호 채번하기
*&---------------------------------------------------------------------*
FORM NUMBER_GET_NEXT  CHANGING LV_SCRAP_ORDER_NO TYPE AUFNR .

  CHECK LV_SCRAP_ORDER_NO IS INITIAL.

  DATA: LV_ORDER_NO(11) TYPE C.
  CLEAR: LV_SCRAP_ORDER_NO.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = C_SCRAP_NO_OBJECT
    IMPORTING
      NUMBER                  = LV_ORDER_NO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF SY-SUBRC EQ 0.
    CONCATENATE 'A' LV_ORDER_NO INTO LV_SCRAP_ORDER_NO.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM. "Form NUMBER_GET_NEXT
*&---------------------------------------------------------------------*
*& Form BDC_DYNPRO
*&---------------------------------------------------------------------*
* 엑셀 정리
*=CONCATENATE("PERFORM bdc_dynpro USING '",B2,"'  '",C2,"'.")
*=CONCATENATE("PERFORM bdc_field USING : '",C3,"'  '",D3,"',")
*=CONCATENATE("                          '",C4,"'  '",D4,"',")
*-----------------------------------------------------------------
*        Start new screen
*-----------------------------------------------------------------
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING PROGRAM DYNPRO.
  CLEAR: GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = PROGRAM.
  GT_BDCDATA-DYNPRO   = DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X' .
  APPEND GT_BDCDATA.
ENDFORM.  "   "bdc_dynpro
*&---------------------------------------------------------------------*
*& Form BDC_FIELD
*&---------------------------------------------------------------------*
*& Insert field
*&---------------------------------------------------------------------*
FORM BDC_FIELD  USING FNAM FVAL.

  CLEAR: GT_BDCDATA.
  GT_BDCDATA-FNAM = FNAM.
  GT_BDCDATA-FVAL = FVAL.
  APPEND GT_BDCDATA.

ENDFORM. "Form BDC_FIELD
*&---------------------------------------------------------------------*
*& Form BDC_TRANSACTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> C_TCODE_KKF1
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
FORM BDC_TRANSACTION  USING    GV_TCODE
                      CHANGING LV_SUBRC.

  DATA: P_DIMODE LIKE CTU_PARAMS-DISMODE,
        P_UPDATE LIKE CTU_PARAMS-UPDMODE.

 "A: show all dynpros
 "E: show dynpro on error only
 "N: do not display dynpro
  P_DIMODE = 'N'.

 "S: synchronously
 "A: asynchronously
 "L: local
  P_UPDATE = 'S'.

  IF GV_TCODE(2) = 'MB'.

    IF GT_BDCDATA[] IS NOT INITIAL.
      CLEAR: GS_HEADER, GS_CODE, GV_MATDOC, GV_DOCYEAR,
             GT_ITEM, GT_ITEM[], GT_RETURN, GT_RETURN[].

      CASE GV_TCODE.
        WHEN 'MB31'.
          GS_CODE-GM_CODE = '02'.
        WHEN 'MB1A'.
          GS_CODE-GM_CODE = '03'.
        WHEN 'MB1B'.
          GS_CODE-GM_CODE = '04'.
        WHEN 'MB1C'.
          GS_CODE-GM_CODE = '05'.
      ENDCASE.

      GS_HEADER-PSTNG_DATE = REPLACE( VAL = VALUE #( GT_BDCDATA[ FNAM = 'MKPF-BUDAT' ]-FVAL OPTIONAL ) SUB = '.' WITH = ' ' OCC =  0 ).   " 전표 전기일
      GS_HEADER-DOC_DATE   = REPLACE( VAL = VALUE #( GT_BDCDATA[ FNAM = 'MKPF-BLDAT' ]-FVAL OPTIONAL ) SUB = '.' WITH = ' ' OCC =  0 )..   " 전표 증빙일

      GT_ITEM-MATERIAL   = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-MATNR(01)' ]-FVAL OPTIONAL ). " 자재번호
      GT_ITEM-PLANT      = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-WERKS' ]-FVAL OPTIONAL ).    " 플랜트
      GT_ITEM-STGE_LOC   = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-LGORT' ]-FVAL OPTIONAL ).    " 저장위치
      GT_ITEM-BATCH      = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-CHARG(01)' ]-FVAL OPTIONAL ). " 배치
      GT_ITEM-MOVE_TYPE  = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-BWARTWA' ]-FVAL OPTIONAL ).  " 이동유형
      GT_ITEM-SPEC_STOCK = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-SOBKZ' ]-FVAL OPTIONAL ).    " 특별재고지시자
      GT_ITEM-ENTRY_QNT  = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-ERFMG(01)' ]-FVAL OPTIONAL ). " 소요량
      GT_ITEM-ORDERID    = VALUE #( GT_BDCDATA[ FNAM = 'COBL-AUFNR' ]-FVAL OPTIONAL ).     " 오더
*      GT_ITEM-SALES_ORD  = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDAUF' ]-FVAL OPTIONAL )." 판매오더번호
*      GT_ITEM-S_ORD_ITEM = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDPOS' ]-FVAL OPTIONAL )." 판매오더 품목번호
      GT_ITEM-VAL_SALES_ORD  = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDAUF' ]-FVAL OPTIONAL )." 판매오더번호
      GT_ITEM-VAL_S_ORD_ITEM = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDPOS' ]-FVAL OPTIONAL )." 판매오더 품목번호
      APPEND GT_ITEM.
    ENDIF.

    CLEAR : GT_BDCDATA, GT_BDCDATA[].

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GS_HEADER
        GOODSMVT_CODE    = GS_CODE
      IMPORTING
        MATERIALDOCUMENT = GV_MATDOC
        MATDOCUMENTYEAR  = GV_DOCYEAR
      TABLES
        GOODSMVT_ITEM    = GT_ITEM
        RETURN           = GT_RETURN.

    IF GV_MATDOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.



  ELSE. "T-CODE : KKF1
    IF P_DIMODE = ''.  P_DIMODE = 'N'. ENDIF.
    IF P_UPDATE = ''.  P_UPDATE = 'S'. ENDIF.

    DATA  LS_OPT LIKE CTU_PARAMS.
    LS_OPT-DISMODE  = P_DIMODE.
    LS_OPT-UPDMODE  = P_UPDATE.
    LS_OPT-CATTMODE = ''.
    LS_OPT-DEFSIZE  = 'X'.    "화면 Default Size 사용
    LS_OPT-RACOMMIT = 'X'.
    LS_OPT-NOBINPT  = 'X'.
    LS_OPT-NOBIEND = 'X'.
    CLEAR  : GT_MESSTAB, LV_SUBRC.
    REFRESH  GT_MESSTAB.
    CALL TRANSACTION GV_TCODE USING        GT_BDCDATA
                              OPTIONS FROM LS_OPT
                              MESSAGES INTO GT_MESSTAB.
    LV_SUBRC = SY-SUBRC.
    REFRESH GT_BDCDATA.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_KKF1
*&---------------------------------------------------------------------*
*&  CO오더 만들기 메시지 처리
*&---------------------------------------------------------------------*
FORM MESSAGE_KKF1  CHANGING LV_CO_ORDER   TYPE AUFNR
                            LV_MESSAGE_CO TYPE BAPI_MSG.

  DATA: LV_LINES TYPE I.
  CLEAR: GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                 MSGNR = '107'.
  IF SY-SUBRC = 0.
    LV_CO_ORDER = GT_MESSTAB-MSGV1.
  ELSE.
*   마지막 에러 메시지만 보여주기
    CLEAR: LV_LINES, GT_MESSTAB.
    DESCRIBE TABLE GT_MESSTAB LINES LV_LINES.
    READ TABLE GT_MESSTAB INDEX LV_LINES.
  ENDIF.

  CLEAR: GV_MESSAGE_CO.
  PERFORM BUILD_MESSAGE_TEXT
             USING GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                   GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                   GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
             CHANGING LV_MESSAGE_CO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_MESSAGE_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MESSTAB_MSGID
*&      --> GT_MESSTAB_MSGNR
*&      --> GT_MESSTAB_MSGV1
*&      --> GT_MESSTAB_MSGV2
*&      --> GT_MESSTAB_MSGV3
*&      --> GT_MESSTAB_MSGV4
*&      <-- LV_MESSAGE_CO
*&---------------------------------------------------------------------*
FORM BUILD_MESSAGE_TEXT  USING MSGID MSGNR MSGV1
                               MSGV2 MSGV3 MSGV4
                        CHANGING MESSAGE.

  CLEAR : MESSAGE.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = MSGID
      MSGNR               = MSGNR
      MSGV1               = MSGV1
      MSGV2               = MSGV2
      MSGV3               = MSGV3
      MSGV4               = MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_MB1A
*&---------------------------------------------------------------------*
*& 출고 BDC 처리해주기
*&---------------------------------------------------------------------*
FORM BDC_MB1A  USING LV_DATE     TYPE DATUM     "전기일
                     LV_BWART    TYPE BWART     "이동유형
                     LV_WERKS    TYPE WERKS_D   "플랜트
                     LV_LGORT    TYPE LGORT_D   "저장위치
                     LV_MATNR    TYPE MATNR     "자재
                     LV_CHARG    TYPE CHARG_D   "배치
                     LV_QTY      TYPE ERFMG     "수량
                     LV_CO_ORDER TYPE AUFNR     "오더
                     LV_TEXT     LIKE G_TXT

           CHANGING LV_MBLNR_O    TYPE MBLNR
                    LV_MESSAGE_MO TYPE BAPI_MSG.

  DATA: LV_SUBRC     TYPE SY-SUBRC,
        LV_CDATE(10) TYPE C,
        LV_CQTY(17)  TYPE C.

  CLEAR   : GS_HEADER, GS_CODE, GV_MATDOC, GV_DOCYEAR,
            GT_RETURN, GT_ITEM.
  REFRESH : GT_RETURN, GT_ITEM.

  GS_HEADER-PSTNG_DATE      = LV_DATE.       "전기일
  GS_HEADER-DOC_DATE        = LV_DATE .      "증빙일
  GS_HEADER-PR_UNAME        = SY-UNAME.      "사용자
  GS_HEADER-HEADER_TXT      = LV_TEXT.       "헤더 텍스트
  GS_HEADER-VER_GR_GI_SLIP  = '2'.
  GS_HEADER-VER_GR_GI_SLIPX = 'X'.

  GS_CODE-GM_CODE           = '03'.          "MB1A : 자재출고

  GT_ITEM-MATERIAL          = LV_MATNR.      "자재
  GT_ITEM-PLANT             = LV_WERKS.      "플랜트
  GT_ITEM-STGE_LOC          = LV_LGORT.      "저장위치
  GT_ITEM-BATCH             = LV_CHARG.      "배치
  GT_ITEM-MOVE_TYPE         = LV_BWART.      "이동유형
  GT_ITEM-ENTRY_QNT         = ABS( LV_QTY ). "수량
  GT_ITEM-ORDERID           = LV_CO_ORDER.   "생산오더

  APPEND GT_ITEM.

  PERFORM BDC_TRANSACTION USING    C_TCODE_MB1A
                          CHANGING LV_SUBRC.

  PERFORM MESSAGE_MB1A CHANGING LV_MBLNR_O
                                LV_MESSAGE_MO.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_MB1A
*&---------------------------------------------------------------------*
*& 메시지 처리하기
*&---------------------------------------------------------------------*
FORM MESSAGE_MB1A CHANGING LV_MBLNR_O
                           LV_MESSAGE_MO.

  IF GV_MATDOC IS NOT INITIAL.
    LV_MBLNR_O = GV_MATDOC.
  ELSE.
    READ TABLE GT_RETURN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETURN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETURN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETURN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      LV_MESSAGE_MO = GT_RETURN-MESSAGE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_MB1C
*&---------------------------------------------------------------------*
*& 기타입고 처리
*&---------------------------------------------------------------------*
FORM BDC_MB1C  USING LV_DATE      TYPE DATUM     "전기일
                    LV_BWART      TYPE BWART     "이동유형
                    LV_WERKS      TYPE WERKS_D   "플랜트
                    LV_LGORT      TYPE LGORT_D   "저장위치
                    LV_MATNR      TYPE MATNR     "자재
                    LV_CHARG      TYPE CHARG_D   "배치
                    LV_QTY        TYPE ERFMG     "수량
                    LV_CO_ORDER   TYPE AUFNR     "오더
           CHANGING LV_MBLNR_I    TYPE MBLNR
                    LV_MESSAGE_MI TYPE BAPI_MSG.

  DATA : LV_SUBRC     TYPE SYSUBRC,
         LV_CDATE(10) TYPE C,
         LV_CQTY(17)  TYPE C.

  CLEAR   : GS_HEADER, GS_CODE, GV_MATDOC, GV_DOCYEAR,
            GT_RETURN, GT_ITEM.
  REFRESH : GT_RETURN, GT_ITEM.

  GS_HEADER-PSTNG_DATE      = LV_DATE.       "전기일
  GS_HEADER-DOC_DATE        = LV_DATE .      "증빙일
  GS_HEADER-PR_UNAME        = SY-UNAME.      "사용자
  GS_HEADER-VER_GR_GI_SLIP  = '2'.
  GS_HEADER-VER_GR_GI_SLIPX = 'X'.

  GS_CODE-GM_CODE           = '05'.          "MB1C : 기타입고

  GT_ITEM-MATERIAL          = LV_MATNR.      "자재
  GT_ITEM-PLANT             = LV_WERKS.      "플랜트
  GT_ITEM-STGE_LOC          = LV_LGORT.      "저장위치
  GT_ITEM-BATCH             = LV_CHARG.      "배치
  GT_ITEM-MOVE_TYPE         = LV_BWART.      "이동유형
  GT_ITEM-ENTRY_QNT         = ABS( LV_QTY ). "수량
  GT_ITEM-ORDERID           = LV_CO_ORDER.   "생산오더

  APPEND GT_ITEM.

  PERFORM BDC_TRANSACTION USING    C_TCODE_MB1C
                          CHANGING LV_SUBRC.

  PERFORM MESSAGE_MB1C CHANGING LV_MBLNR_I
                                LV_MESSAGE_MI.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_MB1C
*&---------------------------------------------------------------------*
*& 메시지 처리하기
*&---------------------------------------------------------------------*
FORM MESSAGE_MB1C CHANGING LV_MBLNR_O
                           LV_MESSAGE_MO.

  IF GV_MATDOC IS NOT INITIAL.
    LV_MBLNR_O = GV_MATDOC.
  ELSE.
    READ TABLE GT_RETURN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETURN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETURN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETURN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      LV_MESSAGE_MO = GT_RETURN-MESSAGE.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_MB31
*&---------------------------------------------------------------------*
*&   오더 입고 처리
*&---------------------------------------------------------------------*
FORM BDC_MB31 USING LV_DATE       TYPE DATUM     "전기일
                    LV_BWART      TYPE BWART     "이동유형
                    LV_SC_WERKS   TYPE WERKS_D   "플랜트
                    LV_SC_LGORT   TYPE LGORT_D   "저장위치
                    LV_SC_MATNR   TYPE MATNR     "자재
                    LV_SC_QTY     TYPE ERFMG     "수량
                    LV_CO_ORDER   TYPE AUFNR
           CHANGING LV_MBLNR_I    TYPE MBLNR
                    LV_MESSAGE_MI TYPE BAPI_MSG.

  DATA : LV_SUBRC     TYPE SYSUBRC,
         LV_CDATE(10) TYPE C,
         LV_CQTY(17)  TYPE C.

  CLEAR   : GS_HEADER, GS_CODE, GV_MATDOC, GV_DOCYEAR,
            GT_RETURN, GT_ITEM.
  REFRESH : GT_RETURN, GT_ITEM.

  GS_HEADER-PSTNG_DATE      = LV_DATE.       "전기일
  GS_HEADER-DOC_DATE        = LV_DATE .      "증빙일
  GS_HEADER-PR_UNAME        = SY-UNAME.      "사용자
  GS_HEADER-VER_GR_GI_SLIP  = '2'.
  GS_HEADER-VER_GR_GI_SLIPX = 'X'.

  GS_CODE-GM_CODE           = '02'.          "MB31 : 생산 오더 입고

  GT_ITEM-MATERIAL          = LV_SC_MATNR.   "자재
  GT_ITEM-PLANT             = LV_SC_WERKS.   "플랜트
  GT_ITEM-STGE_LOC          = LV_SC_LGORT.   "저장위치
  GT_ITEM-MVT_IND           = 'F'.
  GT_ITEM-MOVE_TYPE         = LV_BWART.      "이동유형
  GT_ITEM-ENTRY_QNT         = ABS( LV_SC_QTY ). "수량
  GT_ITEM-ORDERID           = LV_CO_ORDER.   "생산오더
  GT_ITEM-NO_MORE_GR        = 'X'.           "납품완료
  GT_ITEM-STCK_TYPE         = '3'.           "가용재고

  APPEND GT_ITEM.

  PERFORM BDC_TRANSACTION USING    C_TCODE_MB31
                          CHANGING LV_SUBRC.

  PERFORM MESSAGE_MB31 CHANGING LV_MBLNR_I
                                LV_MESSAGE_MI.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_MB31
*&---------------------------------------------------------------------*
*&  입고 메시지 처리
*&---------------------------------------------------------------------*
FORM MESSAGE_MB31 CHANGING LV_MBLNR_I    TYPE MBLNR
                           LV_MESSAGE_MI TYPE BAPI_MSG.

  IF GV_MATDOC IS NOT INITIAL.
    LV_MBLNR_I = GV_MATDOC.
  ELSE.
    READ TABLE GT_RETURN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETURN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETURN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETURN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      LV_MESSAGE_MI = GT_RETURN-MESSAGE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANC_KFCM_MBLNR
*&---------------------------------------------------------------------*
*& 신규 - 한미소(KFCM) SCRAP 처리 자재문서 취소
*&---------------------------------------------------------------------*
FORM CANC_KFCM_MBLNR .

  DATA : LV_MBLNR_C TYPE MBLNR,
         LV_MESSAGE TYPE BAPI_MSG,
         LV_MJAHR   TYPE MJAHR.

*- 자재문서 연도 (MKPF-MJAHR = 전기일 연도)
  LV_MJAHR = GS_ZGTMMT9250C-BUDAT(4).

*&---------------------------------------------------------------------*
*& 자재출고(951) 취소
*&---------------------------------------------------------------------*
  IF GS_ZGTMMT9250C-MBLNR_O  IS NOT INITIAL AND
     GS_ZGTMMT9250C-MBLNR_OC IS INITIAL.

    CLEAR : LV_MBLNR_C, LV_MESSAGE.

    PERFORM BDC_MBST_KFCM USING    'MBLNR_OC'
                                   GS_ZGTMMT9250C-MBLNR_O
                                   LV_MJAHR
                          CHANGING LV_MBLNR_C
                                   LV_MESSAGE.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.

    PERFORM MODIFY_ZGTMMT9250C_MBLNR USING 'MBLNR_OC' LV_MBLNR_C.
  ENDIF.

*&---------------------------------------------------------------------*
*& SCRAP 입고(971) 취소
*&---------------------------------------------------------------------*
  IF GS_ZGTMMT9250C-MBLNR_I  IS NOT INITIAL AND
     GS_ZGTMMT9250C-MBLNR_IC IS INITIAL.

    CLEAR : LV_MBLNR_C, LV_MESSAGE.

    PERFORM BDC_MBST_KFCM USING    'MBLNR_IC'
                                   GS_ZGTMMT9250C-MBLNR_I
                                   LV_MJAHR
                          CHANGING LV_MBLNR_C
                                   LV_MESSAGE.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.

    PERFORM MODIFY_ZGTMMT9250C_MBLNR USING 'MBLNR_IC' LV_MBLNR_C.
  ENDIF.

*&---------------------------------------------------------------------*
*& 매출원가 대체용 0 입고(101) 취소
*&---------------------------------------------------------------------*
  IF GS_ZGTMMT9250C-MBLNR_Z  IS NOT INITIAL AND
     GS_ZGTMMT9250C-MBLNR_ZC IS INITIAL.

    CLEAR : LV_MBLNR_C, LV_MESSAGE.

    PERFORM BDC_MBST_KFCM USING    'MBLNR_ZC'
                                   GS_ZGTMMT9250C-MBLNR_Z
                                   LV_MJAHR
                          CHANGING LV_MBLNR_C
                                   LV_MESSAGE.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.

    PERFORM MODIFY_ZGTMMT9250C_MBLNR USING 'MBLNR_ZC' LV_MBLNR_C.
  ENDIF.

*&---------------------------------------------------------------------*
*& Scrap 취소 성공
*&---------------------------------------------------------------------*
  CHECK GV_ERROR <> 'X'.

  LV_MESSAGE = 'CANCEL SUCCESS'.

  PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                          'Y'
                                          LV_MESSAGE.

  PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                       'Y'
                                       LV_MESSAGE.

ENDFORM. "Form CANC_KFCM_MBLNR
*&---------------------------------------------------------------------*
*& Form BDC_MBST_KFCM
*&---------------------------------------------------------------------*
*& 신규 - BDC_MBST(LZGTMM01F01) 로컬 복사본
*&   원본과의 차이는 자재문서를 못 찾았을 때의 처리다.
*&   원본 : SELECT SINGLE ... FROM MKPF. CHECK SY-SUBRC = 0.
*&          → 못 찾으면 GV_ERROR도 세우지 않고 조용히 종료 → 뒤 단계가 그대로 진행되고
*&            최종적으로 MOM에 '취소 성공(Y)'이 회신되는 조용한 실패가 난다.
*&   본 복사본 : 에러 기록 + GV_ERROR = 'X' 로 중단.
*&   (KSCM이 쓰는 원본 BDC_MBST는 건드리지 않기 위해 복사본으로 분리)
*&---------------------------------------------------------------------*
FORM BDC_MBST_KFCM  USING    PV_FIELDNAME
                             VALUE(PV_MBLNR) TYPE MBLNR
                             VALUE(PV_YEAR)  TYPE MJAHR
                    CHANGING PV_MBLNR_C      TYPE MBLNR
                             PV_MESSAGE      TYPE BAPI_MSG.

  DATA : LV_BUDAT LIKE MKPF-BUDAT.

  CLEAR : LV_BUDAT, GS_HEADRET, GT_RETURN, GT_RETURN[].
  CLEAR : PV_MBLNR_C, PV_MESSAGE.

*- 역분개할 전표의 전기일로 역분개 처리하기
  SELECT SINGLE BUDAT
           INTO LV_BUDAT
           FROM MKPF
          WHERE MBLNR = PV_MBLNR
            AND MJAHR = PV_YEAR.

*---
  IF SY-SUBRC <> 0.
    PV_MESSAGE = |취소할 자재문서({ PV_MBLNR }/{ PV_YEAR })를 찾을 수 없습니다.|.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                            'E'
                                            PV_MESSAGE.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                         'E'
                                         PV_MESSAGE.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PV_MBLNR
      MATDOCUMENTYEAR     = PV_YEAR
      GOODSMVT_PSTNG_DATE = LV_BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = GS_HEADRET
    TABLES
      RETURN              = GT_RETURN.

  IF GS_HEADRET-MAT_DOC IS NOT INITIAL.
*___성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PV_MBLNR_C = GS_HEADRET-MAT_DOC.

    IF PV_FIELDNAME = 'MBLNR_OC'.
      GV_MBLNR_OC = PV_MBLNR_C.
    ELSEIF PV_FIELDNAME = 'MBLNR_IC'.
      GV_MBLNR_IC = PV_MBLNR_C.
    ELSEIF PV_FIELDNAME = 'MBLNR_ZC'.
      GV_MBLNR_ZC = PV_MBLNR_C.
    ENDIF.

  ELSE.
*___실패
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE GT_RETURN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETURN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETURN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETURN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      PV_MESSAGE = GT_RETURN-MESSAGE.
    ELSE.
*--- 원본은 메시지를 못 찾으면 GV_ERROR도 안 세우고 넘어가 성공 처리됨.
      PV_MESSAGE = |자재문서({ PV_MBLNR }) 취소 실패(메시지 없음).|.
    ENDIF.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                            'E'
                                            PV_MESSAGE.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                         'E'
                                         PV_MESSAGE.
    GV_ERROR = 'X'.
  ENDIF.

ENDFORM. "Form BDC_MBST_KFCM
*&---------------------------------------------------------------------*
*& Form MODIFY_ZGTMMT9250C_MBLNR
*&---------------------------------------------------------------------*
*& 신규 - 취소 진행상태를 ZGTMMT9250 원본행(ZFLAG='P',ZRESULT='Y')에 기록
*&
*&  SAVE_RESULT_ZGTMMT9250은 ZFLAG='C'인 새 행을 추가할 뿐 원본행을 갱신하지 않는다.
*&  원본행을 그대로 두면 CHECK_CANC_DATA가 다음 취소 요청 때 "아직 아무것도 취소
*&  안 된 건"으로 판단하여, 이미 취소된 전표를 다시 취소하려 든다.
*&  → 단계별로 원본행의 MBLNR_OC/IC/ZC/MC를 채워 멱등성을 확보한다.
*&  키 : ZSERNO + TIMESTAMP + WERKS (GS_ZGTMMT9250C에 전부 실려 있음)
*&---------------------------------------------------------------------*
FORM MODIFY_ZGTMMT9250C_MBLNR USING PV_FIELD
                                    PV_MBLNR_C.

  CHECK PV_MBLNR_C IS NOT INITIAL.

  CASE PV_FIELD.
    WHEN 'MBLNR_OC'. GS_ZGTMMT9250C-MBLNR_OC = PV_MBLNR_C.
    WHEN 'MBLNR_IC'. GS_ZGTMMT9250C-MBLNR_IC = PV_MBLNR_C.
    WHEN 'MBLNR_ZC'. GS_ZGTMMT9250C-MBLNR_ZC = PV_MBLNR_C.
    WHEN 'MBLNR_MC'. GS_ZGTMMT9250C-MBLNR_MC = PV_MBLNR_C.
    WHEN OTHERS.     EXIT.
  ENDCASE.

  GS_ZGTMMT9250C-ZAENAM = SY-UNAME.
  GS_ZGTMMT9250C-ZAEDAT = SY-DATUM.
  GS_ZGTMMT9250C-ZAEZET = SY-UZEIT.

  UPDATE ZGTMMT9250 FROM GS_ZGTMMT9250C.
  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM. "Form MODIFY_ZGTMMT9250C_MBLNR
*&---------------------------------------------------------------------*
*& Form CHECK_KFCM_IV_EXIST
*&---------------------------------------------------------------------*
*& 구매와 무관한 전표(사내거래 351 등)는 EBELN이 없어 자동으로 제외
*&---------------------------------------------------------------------*
FORM CHECK_KFCM_IV_EXIST  CHANGING PV_ZRESULT
                                   PV_MESSAGE.

  DATA: LV_NETMNG TYPE EKBE-MENGE.

*- 한미소 전용
  CHECK GV_SYSTEM_ID = 'KFCM'.

*- 자재문서의 구매오더 라인 추출
  SELECT ZEILE,EBELN,EBELP
    INTO TABLE @DATA(LT_ITEM)
    FROM MATDOC
   WHERE MJAHR = @GV_MJAHR
     AND MBLNR = @GV_MBLNR
     AND EBELN <> @SPACE
     AND BUKRS = '7000'.

  CHECK LT_ITEM IS NOT INITIAL.

  LOOP AT LT_ITEM INTO DATA(LS_ITEM).

*- GR기준 IV품목만 판정 대상 (수입건은 송장이 먼저 생성)
    SELECT SINGLE WEBRE
      INTO @DATA(LV_WEBRE)
      FROM EKPO
     WHERE EBELN = @LS_ITEM-EBELN
       AND EBELP = @LS_ITEM-EBELP.

    CHECK LV_WEBRE = 'X'.

*- 위 입고 전표/라인을 참조하는 송장 내역
    SELECT SHKZG, MENGE
      INTO TABLE @DATA(LT_EKBE)
      FROM EKBE
     WHERE EBELN = @LS_ITEM-EBELN
       AND EBELP = @LS_ITEM-EBELP
       AND VGABE = '2' "송장
       AND LFBNR = @GV_MBLNR
       AND LFGJA = @GV_MJAHR
       AND LFPOS = @LS_ITEM-ZEILE.

    CHECK LT_EKBE IS NOT INITIAL.

*-  송장 취소분(H) 차감 → 순수량
    CLEAR: LV_NETMNG.
    LOOP AT LT_EKBE INTO DATA(LS_EKBE).
      IF LS_EKBE-SHKZG = 'S'.
        LV_NETMNG = LV_NETMNG + LS_EKBE-MENGE.
      ELSE.
        LV_NETMNG = LV_NETMNG - LS_EKBE-MENGE.
      ENDIF.
    ENDLOOP.

    IF LV_NETMNG > 0 .
      PV_ZRESULT = GC_E.
      PV_MESSAGE = |송장이 발생하여 입고취소할 수 없습니다.| &&
                   |(구매오더 { LS_ITEM-EBELN }-{ LS_ITEM-EBELP }) | .
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.
