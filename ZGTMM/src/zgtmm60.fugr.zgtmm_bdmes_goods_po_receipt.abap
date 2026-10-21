FUNCTION ZGTMM_BDMES_GOODS_PO_RECEIPT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4 DEFAULT 'KBDM'
*"     VALUE(I_ZGRCD) TYPE  ZGTE_BD_ZGRCD
*"     VALUE(I_ZIFKEY) TYPE  ZGTEIFKEY OPTIONAL
*"     VALUE(IS_HEAD) TYPE  ZGTMMSIF0066
*"  EXPORTING
*"     VALUE(O_MBLNR) TYPE  MBLNR
*"     VALUE(O_MJAHR) TYPE  MJAHR
*"     VALUE(O_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(O_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTMMSIF0067 OPTIONAL
*"      OT_RTN STRUCTURE  ZGTMMSIF0068 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_GOODS_PO_RECEIPT
*& 프로그램 명 : [BD] 구매오더 PO입고 I/F 수신
*& 개요   : 부스닥트 MES에서 원자재를 제외한 구매오더에 대해 구매오더기준 입고를 처리한다
*& 생성일 : 2024.12.27
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
  CLEAR : O_MESSAGE, O_MBLNR, O_MJAHR, OT_RTN[].

  GV_SYSTEM_ID = I_SYSTEM_ID.
  GV_ZGRCD     = I_ZGRCD.
  GV_ZIFKEY    = I_ZIFKEY.
  PERFORM SET_COM_LOG USING 'S' 'MM00063' ' ' ' '.

  CLEAR : GS_I66, GT_I67[], GT_OTN[].
  CLEAR : GV_RST, GV_MSG,   GS_MDOC.

  GS_I66   = IS_HEAD.
  GT_I67[] = IT_ITEM[].
* SORT GT_I67 BY EBELN EBELP MATNR.

  PERFORM CHECK_PGX_RCV.
  PERFORM CREATE_GR_BAT.
  PERFORM SET_6030_LOG USING 'S'.

  IF GT_OTN[] IS NOT INITIAL.
    PERFORM SET_PGX_RTN TABLES OT_RTN
                      CHANGING O_RESULT
                               O_MESSAGE
                               O_MBLNR
                               O_MJAHR.
    RETURN.
  ENDIF.

  CASE GV_ZGRCD.
    WHEN 'C'. "취소
      PERFORM RUN_PGC_RCV.
    WHEN 'R'. "입고
      PERFORM RUN_PGR_RCV.
  ENDCASE.

  PERFORM SET_PGX_RTN TABLES OT_RTN
                    CHANGING O_RESULT
                             O_MESSAGE
                             O_MBLNR
                             O_MJAHR.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form CHECK_PGX_RCV
*&---------------------------------------------------------------------*
FORM CHECK_PGX_RCV.

  DATA : LV_MSG(100),
         LV_QTY LIKE EKET-MENGE.


  CLEAR : GT_PCHK[].

  "입력값 점검

  CASE GV_ZGRCD.
    WHEN 'R'. "입고
      IF GT_I67[] IS INITIAL.
        PERFORM SET_RTN_MSG USING 'E' '입고 처리할 아이템을 입력하세요.'(M06).
        EXIT.
      ENDIF.

      LOOP AT GT_I67.
        GT_I67-EBELN = |{ GT_I67-EBELN ALPHA = IN }|.
        GT_I67-EMLIF = |{ GT_I67-EMLIF ALPHA = IN }|.
        PERFORM CONVERT_MATN1_INPUT USING GT_I67-MATNR.
        MODIFY GT_I67 TRANSPORTING EBELN MATNR EMLIF.
      ENDLOOP.

      PERFORM GET_PCHK_DATA.

      LOOP AT GT_PCHK.
        LV_MSG = GT_PCHK-EBELN && '/' && GT_PCHK-EBELP.
        LV_QTY = GT_PCHK-MENGE - GT_PCHK-WEMNG.

        IF GT_PCHK-BSTAE <> GC_0007.
          LV_MSG = LV_MSG && '는 구매오더 입고건이 아닙니다.'(M07).
          PERFORM SET_RTN_MSG USING 'E' LV_MSG.
          EXIT.
        ENDIF.

        IF GT_PCHK-MTART = GC_ROH OR GT_PCHK-MTART = GC_ROH1 OR GT_PCHK-MTART = GC_ROH2
        OR GT_PCHK-MTART = GC_HAWA. "추가(PSJ 25.03.18)
          LV_MSG = LV_MSG && '는 입고처리 대상 자재유형이 아닙니다.'(M08).
          PERFORM SET_RTN_MSG USING 'E' LV_MSG.
          EXIT.
        ENDIF.

        IF GT_PCHK-ELIKZ = GC_X OR LV_QTY <= 0.
          LV_MSG = LV_MSG && '는 납품완료 되었습니다.'(M09).
          PERFORM SET_RTN_MSG USING 'E' LV_MSG.
          EXIT.
        ENDIF.
      ENDLOOP.

    WHEN 'C'. "취소
      IF GS_I66-SMBLN IS INITIAL AND GS_I66-SJAHR IS INITIAL.
        PERFORM SET_RTN_MSG USING 'E' '취소할 자재문서를 입력하세요.'(M10).
        EXIT.
      ENDIF.

    WHEN OTHERS.
      PERFORM SET_RTN_MSG USING 'E' '처리 구분값은 R 또는 C를 입력해야 합니다.'(M11).
      EXIT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PCHK_DATA
*&---------------------------------------------------------------------*
FORM GET_PCHK_DATA.

  CHECK GT_I67[] IS NOT INITIAL.
  SORT GT_I67 BY EBELN EBELP.

  SELECT K~LIFNR,
         P~EBELN,
         P~EBELP,
         P~BEDNR, "Requirement Tracking Number
         P~PSTYP, "Item Cat.
         P~KNTTP, "Account Assignment Cat.
         P~LGORT AS HLGORT,
         P~EMLIF, "Supplier
         P~LBLKZ, "Subcontracting Supplier
         P~ELIKZ, "Delivery Completed Indicator
         P~MTART, "Material Type
         P~BSTAE, "Confirmation Control Key
         S~MENGE, "Scheduled Quantity
         S~WEMNG, "Quantity of Goods Received
         A~VBELN,
         A~VBELP,
         R~MATNR,
         R~WERKS,
         R~LGORT,
         R~SOBKZ, "Special Stock Indicator
         R~KDAUF, "SO No.
         R~KDPOS  "SO Item
*   FROM @GT_I67 AS I INNER JOIN EKPO AS P
*     ON I~EBELN = P~EBELN AND I~EBELP = P~EBELP
*  INNER JOIN EKKO AS K
*     ON P~EBELN = K~EBELN
    FROM EKPO AS P INNER JOIN EKKO AS K
      ON P~EBELN = K~EBELN
   INNER JOIN EKET AS S
      ON P~EBELN = S~EBELN AND P~EBELP = S~EBELP AND S~ETENR = @GC_0001
    LEFT JOIN EKKN AS A
      ON P~EBELN = A~EBELN AND P~EBELP = A~EBELP AND A~ZEKKN = @GC_01
    LEFT JOIN RESB AS R
      ON P~EBELN = R~EBELN AND P~EBELP = R~EBELP AND R~XLOEK = @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_PCHK
     FOR ALL ENTRIES IN @GT_I67
   WHERE P~EBELN = @GT_I67-EBELN
     AND P~EBELP = @GT_I67-EBELP.

  SORT GT_PCHK BY EBELN EBELP MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_GR_BAT
*&---------------------------------------------------------------------*
FORM CREATE_GR_BAT.

  DATA : LV_MSG(100).


  "배치관리 자재일 경우, 배치 및 특성치를 미리 생성 후 입고 진행(PSJ 25.03.12)

  CHECK GT_OTN[] IS INITIAL.
  CHECK GV_ZGRCD = GC_R. "Only 입고

  CLEAR : GV_ERR.

  LOOP AT GT_I67.
    READ TABLE GT_PCHK WITH KEY EBELN = GT_I67-EBELN
                                EBELP = GT_I67-EBELP
                                BINARY SEARCH.

    CHECK SY-SUBRC = 0.
    CHECK GT_PCHK-MTART = GC_FERT AND GT_PCHK-VBELN IS NOT INITIAL.

    SELECT SINGLE XCHAR
      FROM MARC INTO @DATA(LV_XCHAR)
     WHERE MATNR = @GT_I67-MATNR
       AND WERKS = @GT_I67-WERKS
       AND LVORM = @SPACE.

    CHECK LV_XCHAR = GC_X.

    GV_MATNR = GT_I67-MATNR.
    PERFORM CONVERT_MATN1_OUTPUT USING GV_MATNR.

    IF GT_I67-CHARG IS INITIAL.
      LV_MSG = GV_MATNR && ': 배치번호를 입력하세요.'(M45).
      PERFORM SET_RTN_MSG USING 'E' LV_MSG.
      EXIT.
    ENDIF.

    CLEAR : GS_PJT.
    SELECT SINGLE ZPJT_NO,
                  JOB_NO,
                  LINE_NO,
                  SERIAL_INFO
      FROM ZGTMM_CV_BD_JNPO_LIST
      INTO CORRESPONDING FIELDS OF @GS_PJT
     WHERE EBELN = @GT_I67-EBELN
       AND EBELP = @GT_I67-EBELP.

    IF GS_PJT-ZPJT_NO IS INITIAL.
      LV_MSG = GV_MATNR && ': 배치 생성 할 프로젝트를 찾지 못했습니다.'(M46).
      PERFORM SET_RTN_MSG USING 'E' LV_MSG.
      EXIT.
    ENDIF.

    PERFORM VB_CREATE_BATCH USING GT_I67-MATNR
                                  GT_I67-WERKS
                                  GT_I67-CHARG.

    IF GV_ERR = GC_X.
      EXIT.
    ENDIF.

    PERFORM BAPI_OBJCL_CHANGE USING GT_PCHK-VBELN
                                    GT_PCHK-VBELP
                                    GT_PCHK-EBELN
                                    GT_PCHK-EBELP
                                    GT_I67-WERKS
                                    GT_I67-MATNR
                                    GT_I67-CHARG.

    IF GV_ERR = GC_X.
      EXIT.
    ENDIF.
  ENDLOOP.

* IF GT_OTN[] IS INITIAL.
*   PERFORM BAPI_COMMIT.
* ELSE.
*   PERFORM BAPI_ROLLBACK.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_6030_LOG
*&---------------------------------------------------------------------*
FORM SET_6030_LOG USING PV_TYPE.

  "수신 Data Log Table 저장

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_6030, GT_6030[].

      MOVE-CORRESPONDING GS_I66 TO GT_6030.
      GT_6030-ZIFNO     = GT_9000-ZIFNO.
      GT_6030-ZIFKEY    = GT_9000-ZIFKEY.
      GT_6030-SYSTEM_ID = GT_9000-SYSTEM_ID.
      GT_6030-ZGRCD     = GV_ZGRCD.

      CASE GV_ZGRCD.
        WHEN 'R'. "입고
          GT_6030[] = CORRESPONDING #( GT_I67[] ).
          MODIFY GT_6030 TRANSPORTING ZIFNO
                                      ZIFKEY
                                      SYSTEM_ID
                                      ZGRCD
                                      BUDAT
                                      SMBLN
                                      SJAHR
                                      BLDAT
                                      LFSNR
                                      BKTXT
                                WHERE ZIFNO IS INITIAL.

        WHEN 'C'.
          APPEND GT_6030.

      ENDCASE.

      MODIFY ZGTMMT6030 FROM TABLE GT_6030.

    WHEN 'E'. "End
      UPDATE ZGTMMT6030 SET MBLNR1      = GS_MDOC-MBLNR1
                            MJAHR1      = GS_MDOC-MJAHR1
                            MBLNR2      = GS_MDOC-MBLNR2
                            MJAHR2      = GS_MDOC-MJAHR2
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
*& Form SET_PGX_RTN
*&---------------------------------------------------------------------*
FORM SET_PGX_RTN TABLES PT_RTN STRUCTURE ZGTMMSIF0068
               CHANGING PV_RESULT
                        PV_MESSAGE
                        PV_MBLNR
                        PV_MJAHR.

  PV_RESULT  = GV_RST.
  PV_MESSAGE = GV_MSG.
  PV_MBLNR   = GS_MDOC-MBLNR1.
  PV_MJAHR   = GS_MDOC-MJAHR1.
  PT_RTN[]   = GT_OTN[].

  PERFORM SET_TIMESTAMP USING 'X' ' '.

  PERFORM SET_6030_LOG USING 'E'.
  PERFORM SET_COM_LOG  USING 'E' ' ' GV_RST GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_PGC_RCV
*&---------------------------------------------------------------------*
FORM RUN_PGC_RCV.

  CLEAR : GS_XGR, GT_CGR, GT_CGR[].

  "입고 처리된 문서 정보
  SELECT SINGLE MBLNR1 MJAHR1 MBLNR2 MJAHR2
    FROM ZGTMMT6030
    INTO CORRESPONDING FIELDS OF GS_XGR
   WHERE ZGRCD  = GC_R
     AND MBLNR1 = GS_I66-SMBLN
     AND MJAHR1 = GS_I66-SJAHR.

  IF SY-SUBRC <> 0.
    PERFORM SET_RTN_MSG USING 'E' '취소할 자재문서 번호가 없습니다.'(M12).
    EXIT.
  ENDIF.

  "취소 이력 정보
  SELECT ZIFKEY, MBLNR1, MJAHR1, MBLNR2, MJAHR2
    FROM ZGTMMT6030
   WHERE ZGRCD = @GC_C
     AND SMBLN = @GS_I66-SMBLN
     AND SJAHR = @GS_I66-SJAHR
     AND ERDAT IS NOT INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @GT_CGR.

  SORT GT_CGR BY ZIFKEY DESCENDING.
  READ TABLE GT_CGR INDEX 1.

  IF GT_CGR-MBLNR1 IS NOT INITIAL.
    PERFORM SET_RTN_MSG USING 'E' '이미 취소한 자재문서 입니다.'(M13).
    EXIT.
  ENDIF.

  "후속문서 존재시 후속문서 취소(취소 이력 문서가 없고, 입고 처리된 문서의 MBLNR2 값이 있으면)
  PERFORM BAPI_PGC_RCV USING GS_XGR-MBLNR2
                             GS_XGR-MJAHR2
                             'S'.

  "IS_HEAD-SMBLN 취소
  PERFORM BAPI_PGC_RCV USING GS_I66-SMBLN
                             GS_I66-SJAHR
                             ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PGC_RCV
*&---------------------------------------------------------------------*
FORM BAPI_PGC_RCV USING PV_MBLNR
                        PV_MJAHR
                        PV_TYPE.

  CHECK PV_MBLNR IS NOT INITIAL.

  PERFORM GET_BUDAT USING PV_MBLNR
                          PV_MJAHR.

  PERFORM BAPI_GOODSMVT_CANCEL USING PV_MBLNR
                                     PV_MJAHR
                                     GV_BUDAT.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    IF PV_TYPE = GC_S.
      PERFORM SET_BAPI_MSG USING 'E' '직납 후속 처리 문서를 취소하지 못했습니다.'(M14).
      MOVE-CORRESPONDING GS_XGR TO GS_MDOC.
    ELSE.
      PERFORM SET_BAPI_MSG USING 'E' '자재문서를 취소하지 못했습니다.'(M15).
      MOVE-CORRESPONDING GT_CGR TO GS_MDOC.
    ENDIF.

  ELSE.
    PERFORM BAPI_COMMIT.
    PERFORM SET_PGX_SUC USING PV_TYPE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGX_SUC
*&---------------------------------------------------------------------*
FORM SET_PGX_SUC USING PV_TYPE.

  IF PV_TYPE = GC_S.
    GS_MDOC-MBLNR2 = GS_MHDRT-MAT_DOC.
    GS_MDOC-MJAHR2 = GS_MHDRT-DOC_YEAR.
  ELSE.
    GS_MDOC-MBLNR1 = GS_MHDRT-MAT_DOC.
    GS_MDOC-MJAHR1 = GS_MHDRT-DOC_YEAR.

    DATA(LV_MSG) = GS_MHDRT-MAT_DOC && '/' && GS_MHDRT-DOC_YEAR && ` ` && '생성'(M16).
    PERFORM SET_RTN_MSG USING 'S' LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_PGR_RCV
*&---------------------------------------------------------------------*
FORM RUN_PGR_RCV.

  CLEAR : GT_DITM[].

  "Header
  PERFORM SET_PGR_HEAD.

  CLEAR : GV_LINEID, GV_LINEID_P.

  SORT GT_I67 BY EBELN EBELP ZSCMAT MATNR.

  LOOP AT GT_I67.
    CLEAR : GT_PCHK.
    IF GT_I67-ZSCMAT IS INITIAL.
      READ TABLE GT_PCHK WITH KEY EBELN = GT_I67-EBELN
                                  EBELP = GT_I67-EBELP
                                  BINARY SEARCH.
    ELSE.
      READ TABLE GT_PCHK WITH KEY EBELN = GT_I67-EBELN
                                  EBELP = GT_I67-EBELP
                                  MATNR = GT_I67-MATNR
                                  BINARY SEARCH.
    ENDIF.

    "직납 구분
    PERFORM SET_PGR_DIR.

    GV_LINEID += 1.
    IF GV_LINEID_P IS INITIAL.
      GV_LINEID_P = GV_LINEID.
    ENDIF.

    "Item
    PERFORM SET_PGR_ITEM.
    PERFORM SET_DGR_ITEM.
  ENDLOOP.

  PERFORM BAPI_PGR_RCV USING ' '.

  "지정한 저장위치 입고 후 후속 541O처리 대상 존재시 후속작업 추가 진행
  IF GV_RST = GC_S AND GT_DITM[] IS NOT INITIAL.
    PERFORM SET_DGR_DATA.
    PERFORM BAPI_PGR_RCV USING 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_HEAD
*&---------------------------------------------------------------------*
FORM SET_PGR_HEAD.

  CLEAR : GS_MHDR,   GS_MCOD,  GS_MHDRT,
          GT_MITM[], GT_RTN[].

  GS_MHDR-PSTNG_DATE = SWITCH #( GS_I66-BUDAT WHEN ' ' THEN SY-DATLO ELSE GS_I66-BUDAT ).
  GS_MHDR-DOC_DATE   = SWITCH #( GS_I66-BLDAT WHEN ' ' THEN SY-DATLO ELSE GS_I66-BLDAT ).
  GS_MHDR-REF_DOC_NO = GS_I66-LFSNR.
  GS_MHDR-HEADER_TXT = GS_I66-BKTXT.

  GS_MCOD-GM_CODE = GC_01. "구매입고(구매오더 참조입고)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_DIR
*&---------------------------------------------------------------------*
FORM SET_PGR_DIR.

  "직납 구분
  CLEAR : GV_DIR.

  IF     GT_I67-ZSCMAT = GC_X. "직납처리 X
    GV_DIR = GC_L. "지정한 저장위치입고
  ELSEIF GT_PCHK-LBLKZ = GC_X. "직납처리 O
    GV_DIR = GC_V. "공급업체 재고입고
  ELSEIF GT_PCHK-LBLKZ = SPACE AND GT_I67-EMLIF IS NOT INITIAL
                               AND GT_I67-EMLIF <> GT_PCHK-LIFNR.
    GV_DIR = GC_D. "지정한 저장위치 입고 후 후속 541O처리 (직납처리 레코드로 후속으로 541O 처리 해야 할 대상)

    IF GT_PCHK-KNTTP = GC_M OR GT_PCHK-KNTTP = GC_Q.
      GV_DIR = GC_S. "외주창고 저장위치 입고(특별재고 대상 입고로 특정창고(5430:외주창고)로 입고할 대상)
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGR_ITEM
*&---------------------------------------------------------------------*
FORM SET_PGR_ITEM.

  CLEAR : GT_MITM.

  GT_MITM-MATERIAL  = GT_MITM-MATERIAL_LONG = GT_I67-MATNR. "자재번호
  GT_MITM-ENTRY_QNT = GT_I67-LFIMG. "입력단위 수량
  GT_MITM-ENTRY_UOM = GT_I67-MEINS. "입력단위
  GT_MITM-LINE_ID   = GV_LINEID.    "문서라인의 고유식별

  CASE GT_I67-ZSCMAT.
    WHEN ' '.  "상위라인
      GT_MITM-PLANT = GT_I67-WERKS. "플랜트

      "저장위치(By 직납구분)
      CASE GV_DIR.
        WHEN 'L' OR 'D'.
          IF GT_I67-LGORT IS INITIAL.
            GT_MITM-STGE_LOC = GT_PCHK-HLGORT.
          ELSE.
            GT_MITM-STGE_LOC = GT_I67-LGORT.
          ENDIF.
        WHEN 'V'.
          GT_MITM-STGE_LOC = SPACE.
        WHEN 'S'.
          GT_MITM-STGE_LOC = GC_2530.
      ENDCASE.

      GT_MITM-MOVE_TYPE = GC_101.       "이동유형(구매입고)
      GT_MITM-PO_NUMBER = GT_I67-EBELN. "구매오더 번호
      GT_MITM-PO_ITEM   = GT_I67-EBELP. "구매문서의 품목 번호
      GT_MITM-UNLOAD_PT = GT_I67-ABLAD.
      GT_MITM-MVT_IND   = GC_B.         "이동지시자(구매 오더 대한 자재 이동)
*     GT_MITM-PARENT_ID = GC_000000.    "바로 상위라인 ID

      GV_LINEID_P = GV_LINEID.          "Parent Line ID KEEP

    WHEN 'X'.
      GT_MITM-PLANT = GT_PCHK-WERKS. "플랜트

      IF GT_PCHK-SOBKZ = GC_E.
        GT_MITM-STGE_LOC = GT_PCHK-LGORT. "출고저장위치
      ENDIF.

      GT_MITM-MOVE_TYPE = GC_543.       "이동유형(임가공 완료 후 제품 입고)

      IF GT_PCHK-SOBKZ IS NOT INITIAL.
        GT_MITM-STCK_TYPE = GT_PCHK-SOBKZ.
      ELSE.
        GT_MITM-STCK_TYPE = GC_O. "외주 재고
        GT_MITM-VENDOR    = GT_PCHK-LIFNR.
      ENDIF.

      IF GT_PCHK-KNTTP = GC_M.
        CASE GT_PCHK-SOBKZ.
          WHEN ' '.
            GT_MITM-SALES_ORD  = GT_PCHK-VBELN.
            GT_MITM-S_ORD_ITEM = GT_PCHK-VBELP.
          WHEN 'E'.
            GT_MITM-VAL_SALES_ORD  = GT_PCHK-KDAUF.
            GT_MITM-VAL_S_ORD_ITEM = GT_PCHK-KDPOS.
        ENDCASE.
      ENDIF.

      GT_MITM-PARENT_ID = GV_LINEID_P.  "바로 상위라인 ID

  ENDCASE.

  "저장위치(앞 조건식에 따른 값이 없음 But 입력받은 값이 있다면 그것으로!
  IF GT_MITM-STGE_LOC IS INITIAL AND GT_I67-LGORT IS NOT INITIAL.
    GT_MITM-STGE_LOC = GT_I67-LGORT.
  ENDIF.

  "배치번호
  IF GT_I67-CHARG IS INITIAL.
    SELECT SINGLE XCHAR
      FROM MARC INTO @DATA(LV_XCHAR)
     WHERE MATNR = @GT_I67-MATNR
       AND WERKS = @GT_MITM-PLANT "GT_I67-WERKS
       AND LVORM = @SPACE.

    IF LV_XCHAR = GC_X.
      GT_MITM-BATCH = GT_PCHK-BEDNR.
    ENDIF.
  ELSE.
    GT_MITM-BATCH = GT_I67-CHARG.
  ENDIF.

  APPEND GT_MITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DGR_ITEM
*&---------------------------------------------------------------------*
FORM SET_DGR_ITEM.

  CLEAR : GT_DITM.
  CHECK GV_DIR = GC_D.

  GT_DITM-MATERIAL  = GT_DITM-MATERIAL_LONG = GT_MITM-MATERIAL_LONG.
  GT_DITM-PLANT     = GT_MITM-PLANT.
  GT_DITM-STGE_LOC  = GT_MITM-STGE_LOC.
  GT_DITM-BATCH     = GT_MITM-BATCH.
  GT_DITM-MOVE_TYPE = GC_541. "GI->외주재고
  GT_DITM-STCK_TYPE = GC_O.
  GT_DITM-VENDOR    = GT_I67-EMLIF.
  GT_DITM-ENTRY_QNT = GT_I67-LFIMG.
  GT_DITM-ENTRY_UOM = GT_I67-MEINS.
  GT_DITM-PO_NUMBER = GT_I67-EBELN.
  GT_DITM-PO_ITEM   = GT_I67-EBELP.
  GT_DITM-UNLOAD_PT = GT_I67-ABLAD.

  APPEND GT_DITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PGR_RCV
*&---------------------------------------------------------------------*
FORM BAPI_PGR_RCV USING PV_TYPE.

  PERFORM BAPI_GOODSMVT_CREATE.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    IF PV_TYPE = GC_S.
      PERFORM SET_BAPI_MSG USING 'E' '직납 후속 처리 에러: 운영 담당자에게 연락 하세요.'(M17).
    ELSE.
      PERFORM SET_BAPI_MSG USING 'E' GT_RTN-MESSAGE.
    ENDIF.

  ELSE.
    PERFORM BAPI_COMMIT.
    PERFORM SET_PGX_SUC USING PV_TYPE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DGR_DATA
*&---------------------------------------------------------------------*
FORM SET_DGR_DATA.

  CLEAR : GS_MHDR,   GS_MCOD,  GS_MHDRT,
          GT_MITM[], GT_RTN[].

  GS_MHDR-PSTNG_DATE = SWITCH #( GS_I66-BUDAT WHEN ' ' THEN SY-DATLO ELSE GS_I66-BUDAT ).
  GS_MHDR-DOC_DATE   = SWITCH #( GS_I66-BLDAT WHEN ' ' THEN SY-DATLO ELSE GS_I66-BLDAT ).
  GS_MHDR-REF_DOC_NO = GS_MDOC-MBLNR1 && GS_MDOC-MJAHR1. "입고처리한 자재문서 번호/연도
  GS_MHDR-HEADER_TXT = GS_I66-BKTXT.

  GS_MCOD-GM_CODE = GC_04. "이전전기

  GT_MITM[] = GT_DITM[].

ENDFORM.
