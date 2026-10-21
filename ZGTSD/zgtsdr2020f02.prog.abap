*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_JS .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID3.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_BILLING_JS_0200.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-03. 매출처리
  PERFORM PROCESS_BILLING_JS_RUN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_JS_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_JS_RUN .
  DATA: LV_FACTOR_I TYPE ZGTSDT9120-MILLCA_FACTOR_M,
        LV_FACTOR_B TYPE ZGTSDT9120-MILLCA_FACTOR_M.
  DATA: LV_CHK1(1), "최초조장수 = 매출조장수
        LV_CHK2(2). "최초조장수 NE 매출조장수

*-01. 납품분할 여부 지정:
  LOOP AT GT_ITEM INTO DATA(LS_ITEM).
    IF LS_ITEM-FACTOR_I EQ LS_ITEM-FACTOR_B.
      LV_CHK1 = GC_X.
    ENDIF.
    IF LS_ITEM-FACTOR_I NE LS_ITEM-FACTOR_B.
      LV_CHK2 = GC_X.
    ENDIF.
  ENDLOOP.

  IF LV_CHK1 EQ GC_X AND LV_CHK2 NE GC_X.
    "원DO 처리
    ZGTSDS1100-ZPROC = GC_O. "원DO 처리
  ELSE.
    "납품분할
    ZGTSDS1100-ZPROC = GC_S. "납품분할
  ENDIF.

*-02. 분할납품번호 존재
  IF ZGTSDS1100-VBELN_VLSP IS NOT INITIAL.
    ZGTSDS1100-SPLIT = GC_C.
  ENDIF.

*-------------------------------------------
*-03. 매출처리
*-------------------------------------------
  PERFORM RUN_BILLING_PROCESS.

*-------------------------------------------

  IF ZGTSDS1100-RSLT EQ GC_E.

    MESSAGE I000 WITH ZGTSDS1100-MESSAGE(50)
                      ZGTSDS1100-MESSAGE+50(50)
                      ZGTSDS1100-MESSAGE+100(50)
                      ZGTSDS1100-MESSAGE+150(50)
    DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH ZGTSDS1100-MESSAGE DISPLAY LIKE GC_S.
  ENDIF.

  PERFORM CELL_ATTRIBUTES_0200.
  PERFORM REFRESH_ALV USING GO_GRID3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_PROCESS .
  CLEAR:ZGTSDS1100-RSLT,ZGTSDS1100-MESSAGE.

*-01. 납품분할
  IF ZGTSDS1100-ZPROC EQ GC_S.
    IF ZGTSDS1100-SPLIT NE GC_C.
      PERFORM RUN_DO_SPLIT.
    ENDIF.
  ENDIF.

*-02. PICKING
  IF ( ZGTSDS1100-ZPROC EQ GC_S AND ZGTSDS1100-SPLIT EQ GC_C ) OR
     ( ZGTSDS1100-ZPROC EQ GC_O AND ZGTSDS1100-SPLIT NE GC_C ).
    IF ZGTSDS1100-KOSTK NE GC_C.
      PERFORM RUN_DO_PICKING.
    ENDIF.
  ENDIF.

*-03. 출고처리
  IF ZGTSDS1100-KOSTK EQ GC_C.
    IF ZGTSDS1100-WBSTK NE GC_C.
      PERFORM RUN_DO_POST_GI.
    ENDIF.
  ENDIF.

*-04. 매출처리
  IF ZGTSDS1100-WBSTK EQ GC_C.
    IF ZGTSDS1100-FKSTK NE GC_C.
      PERFORM RUN_DO_POST_BILL.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_SPLIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_SPLIT .
  DATA: LS_ZGTSDT9130 LIKE LINE OF GT_ZGTSDT9130.

  DATA: LV_VBELN_VLSP TYPE VBELN_VL.
  DATA: LV_VBELN_NEW TYPE LIKP-VBELN,
        LV_VBELN_OLD TYPE LIKP-VBELN,
        LT_BAPIITEM  TYPE BAPIOBDLVITEMDSP OCCURS 0 WITH HEADER LINE,
        LS_BAPIITEM  TYPE BAPIOBDLVITEMDSP,
        LT_RETURN    TYPE BAPIRET2         OCCURS 0 WITH HEADER LINE.
  DATA: LV_Q TYPE INRI-QUANTITY,
        LV_R TYPE INRI-RETURNCODE.
  DATA: LV_LFART TYPE LIKP-LFART,
        LV_NR    TYPE INRI-NRRANGENR.
  DATA: LV_MESSAGE(220).

  CLEAR: GT_ZGTSDT9130[],GT_LIPS[].

*-LIPS
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_LIPS
    FROM LIPS
   WHERE VBELN EQ ZGTSDS1100-VBELN_VL.

*-BAPI PARAMETER 구성
  "분할납품문서 번호
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '6A'
      OBJECT                  = 'RV_BELEG'
      QUANTITY                = '1'
    IMPORTING
      NUMBER                  = LV_VBELN_NEW
      QUANTITY                = LV_Q
      RETURNCODE              = LV_R
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF LV_VBELN_NEW IS INITIAL.
    ZGTSDS1100-RSLT = GC_E.
    ZGTSDS1100-MESSAGE = TEXT-M04.
    EXIT.
  ENDIF.

  LV_VBELN_OLD = ZGTSDS1100-VBELN_VL.

  LOOP AT GT_ITEM INTO DATA(LS_ITEM) WHERE LFIMG_B > 0.
    CLEAR:LS_ZGTSDT9130.
    DATA(LS_LIPS) = VALUE #( GT_LIPS[ POSNR = LS_ITEM-POSNR_VL UECHA = LS_ITEM-UECHA ] OPTIONAL ).
    CHECK LS_LIPS IS NOT INITIAL.

    "원DO
    CLEAR:LS_BAPIITEM.
    LS_BAPIITEM-DELIV_NUMB          = LV_VBELN_OLD.
    LS_BAPIITEM-DELIV_ITEM          = LS_ITEM-POSNR_VL.
    LS_BAPIITEM-CURR_QTY            = 'A'.            ": A-SALES UNIT , B-BASE UNIT
    LS_BAPIITEM-DLV_QTY             = LS_LIPS-LFIMG - LS_ITEM-LFIMG_B.
    LS_BAPIITEM-SALES_UNIT          = LS_LIPS-VRKME.
    LS_BAPIITEM-ISOCODE_SALES_UNIT  = LS_LIPS-VRKME.
*    LS_BAPIITEM-DLV_QTY_STOCK       = LS_LIPS-LFIMG - LS_ITEM-LFIMG_B.
    LS_BAPIITEM-BASE_UOM            = LS_LIPS-MEINS.
    LS_BAPIITEM-BASE_UOM_ISO        = LS_LIPS-MEINS.
    LS_BAPIITEM-SALES_QTY_NUM       = LS_LIPS-UMVKZ.
    LS_BAPIITEM-SALES_QTY_DENOM     = LS_LIPS-UMVKN.
    APPEND LS_BAPIITEM TO LT_BAPIITEM.

    "분할DO
    CLEAR:LS_BAPIITEM.
    LS_BAPIITEM-DELIV_NUMB          = LV_VBELN_NEW.
    LS_BAPIITEM-DELIV_ITEM          = LS_ITEM-POSNR_VL.
    LS_BAPIITEM-CURR_QTY            = 'A'.            ": A-SALES UNIT , B-BASE UNIT
    LS_BAPIITEM-DLV_QTY             = LS_ITEM-LFIMG_B.
    LS_BAPIITEM-SALES_UNIT          = LS_LIPS-VRKME.
    LS_BAPIITEM-ISOCODE_SALES_UNIT  = LS_LIPS-VRKME.
*    LS_BAPIITEM-DLV_QTY_STOCK       = LS_LIPS-LFIMG - LS_ITEM-LFIMG_B.
    LS_BAPIITEM-BASE_UOM            = LS_LIPS-MEINS.
    LS_BAPIITEM-BASE_UOM_ISO        = LS_LIPS-MEINS.
    LS_BAPIITEM-SALES_QTY_NUM       = LS_LIPS-UMVKZ.
    LS_BAPIITEM-SALES_QTY_DENOM     = LS_LIPS-UMVKN.
    APPEND LS_BAPIITEM TO LT_BAPIITEM.

    "분할DO 정보 저장
    LS_ZGTSDT9130 = CORRESPONDING #( LS_LIPS ).
    CLEAR:LS_ZGTSDT9130-ERDAT,LS_ZGTSDT9130-ERNAM,LS_ZGTSDT9130-AEDAT.
    LS_ZGTSDT9130-VBELN     = LV_VBELN_NEW.
    LS_ZGTSDT9130-LFIMG     = LS_ITEM-LFIMG_B.
    LS_ZGTSDT9130-VBELN_OR  = LS_ITEM-VBELN_VL.
    LS_ZGTSDT9130-SPMON     = ZGTSDS1100-SPMON.
    LS_ZGTSDT9130-FKDAT     = ZGTSDS1100-FKDAT.
    LS_ZGTSDT9130-NETWR     = ZGTSDS1100-NETWR_BL_H.
    LS_ZGTSDT9130-NETWR_UBO = ZGTSDS1100-NETWR_UBO.
    LS_ZGTSDT9130-WAERK     = ZGTSDS1100-WAERK.
    APPEND LS_ZGTSDT9130 TO GT_ZGTSDT9130.

    CLEAR LS_LIPS.
  ENDLOOP.

  "적송 납품분할 DO에 납품보류 = 'G4' 지정
  "SAPMV50A=>USEREXIT_SAVE_DOCUMENT_PREPARE=>PERFORM userexit_save_document_pre0014.
  "에서 IMPORT 하여 납품보류 = G4 지정
  LV_VBELN_VLSP = LV_VBELN_NEW.
  EXPORT LV_VBELN_VLSP TO DATABASE INDX(ZX) ID 'ZGTSDR2020_VLSP'.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_SPLIT_DEC'
    EXPORTING
      DELIVERY              = LV_VBELN_OLD
      DELIVERYNEW           = LV_VBELN_NEW
      DELIVERYITEMSBELONGTO = 'N'
      BUSINESSPROCESS       = '0003'       "=> SPLIT PROFILE
    TABLES
      ITEMDATA              = LT_BAPIITEM
      RETURN                = LT_RETURN.

  LOOP AT LT_RETURN WHERE TYPE CA 'AE'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    ZGTSDS1100-RSLT = GC_E.
    ZGTSDS1100-SPLT = ICON_LED_RED.
    LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.

      CLEAR: LV_MESSAGE.
      PERFORM MESSAGE_BUILD USING LS_RETURN-ID
                                  LS_RETURN-NUMBER
                                  LS_RETURN-MESSAGE_V1
                                  LS_RETURN-MESSAGE_V2
                                  LS_RETURN-MESSAGE_V3
                                  LS_RETURN-MESSAGE_V4
                                  LV_MESSAGE.
      IF ZGTSDS1100-MESSAGE IS INITIAL.
        ZGTSDS1100-MESSAGE = LV_MESSAGE.
      ELSE.
        ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
      ENDIF.
    ENDLOOP.

  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    ZGTSDS1100-VBELN_VLSP = LV_VBELN_NEW.

    "CHECK DO
    PERFORM CHECK_SPLIT_DO.
    "ZGTSDT9130 저장
    IF ZGTSDS1100-RSLT NE GC_E.
      ZGTSDS1100-SPLIT = GC_C.
      ZGTSDS1100-SPLT  = ICON_LED_GREEN.

      "상태
      PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.

      "원DO의 수량 0 라인 삭제
      PERFORM DELETE_DO_LINE_ITEM.

      PERFORM SAVE_DB_ZGTSDT9130.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_BUILD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_RETURN_ID
*&      --> LS_RETURN_NUMBER
*&      --> LS_RETURN_MESSAGE_V1
*&      --> LS_RETURN_MESSAGE_V2
*&      --> LS_RETURN_MESSAGE_V3
*&      --> LS_RETURN_MESSAGE_V4
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MESSAGE_BUILD  USING    PV_MSGID
                         PV_MSGNR
                         PV_MSGV1
                         PV_MSGV2
                         PV_MSGV3
                         PV_MSGV4
                         PV_MESSAGE.

  CLEAR : PV_MESSAGE.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = PV_MSGID
      MSGNR               = PV_MSGNR
      MSGV1               = PV_MSGV1
      MSGV2               = PV_MSGV2
      MSGV3               = PV_MSGV3
      MSGV4               = PV_MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = PV_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SPLIT_DO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SPLIT_DO .
  DATA:LV_CHK(1).

  DO 5 TIMES.
    SELECT SINGLE VBELN
      FROM LIKP
     WHERE VBELN EQ @ZGTSDS1100-VBELN_VLSP
      INTO @DATA(LV_VBELN).
    IF SY-SUBRC EQ 0.
      LV_CHK = GC_X.
      EXIT.
    ELSE.
      WAIT UP TO '0.5' SECONDS.
    ENDIF.
  ENDDO.
  IF LV_CHK IS INITIAL.
    ZGTSDS1100-RSLT = GC_E.
    ZGTSDS1100-SPLT = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M05.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DB_ZGTSDT9130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DB_ZGTSDT9130 .

  CHECK ZGTSDS1100-ZNEW EQ GC_X.
  ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9130[] ).

  MODIFY ZGTSDT9130 FROM TABLE GT_ZGTSDT9130.

*  UPDATE LIKP  SET LIFSK = GC_LIFSK_G4
*             WHERE VBELN EQ ZGTSDS1100-VBELN_VLSP.

  COMMIT WORK AND WAIT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK_FIELD_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_FIELD_0200 .
  DATA: LV_FIELD(30),
        LV_LINE TYPE I.

  GET CURSOR FIELD LV_FIELD LINE LV_LINE.

  CASE LV_FIELD.
    WHEN 'ZGTSDS1100-VBELN_VA'."판매문서
      IF ZGTSDS1100-VBELN_VA IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD ZGTSDS1100-VBELN_VA.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'ZGTSDS1100-VBELN_VL'."납품번호
      IF ZGTSDS1100-VBELN_VL IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD ZGTSDS1100-VBELN_VL.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'ZGTSDS1100-VBELN_VLSP'."SPLIT 납품번호
      IF ZGTSDS1100-VBELN_VLSP IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD ZGTSDS1100-VBELN_VLSP.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'ZGTSDS1100-SPLT' OR
         'ZGTSDS1100-PICK' OR
         'ZGTSDS1100-PGIS' OR
         'ZGTSDS1100-BILL'.
      PERFORM DISPLAY_MESSAGE_0200 USING LV_FIELD.

    WHEN OTHERS.


  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DO_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- ZGTSDS1100
*&---------------------------------------------------------------------*
FORM SET_DO_STATUS  CHANGING PS_DATA TYPE ZGTSDS1100.
  DATA: LV_VBELN TYPE LIKP-VBELN.

  CASE PS_DATA-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = PS_DATA-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = PS_DATA-VBELN_VL.
  ENDCASE.

  SELECT SINGLE KOSTK WBSTK FKSTK
    INTO CORRESPONDING FIELDS OF PS_DATA
    FROM LIKP
   WHERE VBELN EQ LV_VBELN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_PICKING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_PICKING .
  DATA: LV_VBELN TYPE LIKP-VBELN.
  DATA: LS_ZGTSDT9130 LIKE LINE OF GT_ZGTSDT9130.
  DATA: LV_MESSAGE(220).

  CLEAR: GT_ZGTSDT9130[],GT_LIPS[].

*-INIT BAPI PARAMETERS
  CLEAR:GS_VBKOK,GT_VBPOK[],GT_PROT[].

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.

*-----원DO의 PICKING시 수량이 0인 아이템 제거
      IF ZGTSDS1100-ZPROC EQ GC_O.
        PERFORM DELETE_DO_LINE_ITEM.
        IF ZGTSDS1100-RSLT EQ GC_E.
          EXIT.
        ENDIF.
      ENDIF.
  ENDCASE.



*-01. LIPS
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_LIPS
    FROM LIPS
   WHERE VBELN EQ LV_VBELN.
  SORT GT_LIPS BY UECHA POSNR.

*-02. BAPI PARAMETER 구성
  "HEADER
  GS_VBKOK-VBELN_VL  = LV_VBELN.

  "ITEM
  LOOP AT GT_LIPS INTO DATA(LS_LIPS) WHERE LFIMG > 0.
    CLEAR:GS_VBPOK.

    GS_VBPOK-VBELN_VL = LS_LIPS-VBELN.
    GS_VBPOK-POSNR_VL = LS_LIPS-POSNR.
    GS_VBPOK-VBELN    = LS_LIPS-VGBEL.
    GS_VBPOK-POSNN    = LS_LIPS-VGPOS.
    GS_VBPOK-TAQUI    = ABAP_TRUE.
    GS_VBPOK-LFIMG    = LS_LIPS-LFIMG.
    APPEND GS_VBPOK TO GT_VBPOK.

  ENDLOOP.

  "원DO처리시 정보저장
  IF ZGTSDS1100-ZPROC EQ GC_O.
    LS_ZGTSDT9130-VBELN     = LV_VBELN.
    LS_ZGTSDT9130-FKDAT     = ZGTSDS1100-FKDAT.
    LS_ZGTSDT9130-NETWR     = ZGTSDS1100-NETWR_BL_H.
    LS_ZGTSDT9130-NETWR_UBO = ZGTSDS1100-NETWR_UBO.
    LS_ZGTSDT9130-WAERK     = ZGTSDS1100-WAERK.
    APPEND LS_ZGTSDT9130 TO GT_ZGTSDT9130.
  ENDIF.


*-PICKING
  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      VBKOK_WA               = GS_VBKOK
      SYNCHRON               = GC_X
      COMMIT                 = ABAP_FALSE
      DELIVERY               = LV_VBELN
      UPDATE_PICKING         = GC_X
      NICHT_SPERREN_1        = GC_Y
      IF_ERROR_MESSAGES_SEND = ' '
    TABLES
      VBPOK_TAB              = GT_VBPOK
      PROT                   = GT_PROT.

  IF GT_PROT[] IS INITIAL.
    __BAPI_TRANSACTION_COMMIT.

    WAIT UP TO '0.5' SECONDS.

    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
    IF ZGTSDS1100-KOSTK EQ GC_C.
      ZGTSDS1100-RSLT   = GC_S.
      ZGTSDS1100-PICK   = ICON_LED_GREEN.

      IF ZGTSDS1100-ZPROC EQ GC_O.
        PERFORM SAVE_DB_ZGTSDT9130.
      ENDIF.

    ELSE.
      ZGTSDS1100-RSLT   = GC_E.
      ZGTSDS1100-PICK   = ICON_LED_RED.
      ZGTSDS1100-MESSAGE = TEXT-M08.
    ENDIF.

  ELSE.
    ZGTSDS1100-RSLT   = GC_E.
    ZGTSDS1100-PICK   = ICON_LED_RED.

    LOOP AT GT_PROT INTO DATA(LS_PROT) WHERE MSGTY CA 'AE'.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_PROT INTO LS_PROT WHERE MSGTY CA 'AE'.
        CLEAR: LV_MESSAGE.
        PERFORM MESSAGE_BUILD USING LS_PROT-MSGID
                                    LS_PROT-MSGNO
                                    LS_PROT-MSGV1
                                    LS_PROT-MSGV2
                                    LS_PROT-MSGV3
                                    LS_PROT-MSGV4
                                    LV_MESSAGE.
        IF ZGTSDS1100-MESSAGE IS INITIAL.
          ZGTSDS1100-MESSAGE = LV_MESSAGE.
        ELSE.
          ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
        ENDIF.
      ENDLOOP.
    ELSE.
      ZGTSDS1100-MESSAGE = TEXT-M08.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_POST_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_POST_GI .
  DATA: LV_VBELN TYPE LIKP-VBELN.
  DATA: LV_MESSAGE(220).

  FIELD-SYMBOLS: <FS_EMKPF> TYPE EMKPF.

  CLEAR: GT_LIPS[].
*-INIT BAPI PARAMETERS
  CLEAR:GS_VBKOK,GT_VBPOK[],GT_PROT[].

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-01. BAPI PARAMETER 구성
  "HEADER
  GS_VBKOK-VBELN_VL  = LV_VBELN.
  GS_VBKOK-WABUC     = GC_X.
  GS_VBKOK-WADAT_IST = ZGTSDS1100-FKDAT.


*-출고
  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      VBKOK_WA               = GS_VBKOK
      SYNCHRON               = GC_X
      COMMIT                 = ABAP_FALSE
      DELIVERY               = LV_VBELN
      NICHT_SPERREN_1        = GC_Y
      IF_ERROR_MESSAGES_SEND = ' '.

  ASSIGN ('(SAPLV50S)EMKPF') TO <FS_EMKPF>.

  IF SY-SUBRC EQ 0.
    IF <FS_EMKPF>-MBLNR IS NOT INITIAL.
      __BAPI_TRANSACTION_COMMIT.
      WAIT UP TO '0.5' SECONDS.

      "상태
      PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
      IF ZGTSDS1100-WBSTK EQ GC_C.
        ZGTSDS1100-RSLT   = GC_S.
        ZGTSDS1100-PGIS   = ICON_LED_GREEN.
      ELSE.
        ZGTSDS1100-RSLT    = GC_E.
        ZGTSDS1100-PGIS   = ICON_LED_RED.
        ZGTSDS1100-MESSAGE = TEXT-M07.
      ENDIF.
    ELSE.
      __BAPI_TRANSACTION_ROLLBACK.

      ZGTSDS1100-RSLT    = GC_E.
      ZGTSDS1100-PGIS   = ICON_LED_RED.

      MESSAGE ID     SY-MSGID
              TYPE   SY-MSGTY
              NUMBER SY-MSGNO
              WITH   SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              INTO   ZGTSDS1100-MESSAGE.
    ENDIF.

  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.

    MESSAGE ID     SY-MSGID
            TYPE   SY-MSGTY
            NUMBER SY-MSGNO
            WITH   SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
            INTO   ZGTSDS1100-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BILLING_JS_RUN_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BILLING_JS_RUN_0100_BOT .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID2.

*-01. CHECK
  CLEAR GV_ERROR.
  IF LINE_EXISTS( GT_SPLIT[ SEL = GC_X ] ).
  ELSE.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM CHECK_BILLING_JS_RUN_0100_BOT.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 적송 매출 처리
  PERFORM RUN_BILLING_PROCESS_0100_BOT.

  PERFORM REFRESH_ALV USING GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_RUN_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_RUN_0100_BOT .
  DATA: LV_CNT TYPE I.

  LOOP AT GT_SPLIT INTO DATA(LS_SPLIT) WHERE SEL EQ GC_X.
    SELECT SINGLE KOSTK,WBSTK,FKSTK
      FROM LIKP
     WHERE VBELN EQ @LS_SPLIT-VBELN_VLSP
      INTO @DATA(LS_LIKP).
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    "청구완료(적송매출 완료) 제외 => PICKING OR PGI OR BILLIING 미완료건
    CHECK LS_LIKP-FKSTK NE GC_C.

    LV_CNT = LV_CNT + 1.
    EXIT.

    CLEAR:LS_LIKP.
  ENDLOOP.

  IF LV_CNT <= 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M09 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_PROCESS_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_PROCESS_0100_BOT .

  CLEAR GV_ERROR.
  LOOP AT GT_SPLIT ASSIGNING FIELD-SYMBOL(<FS_SPLIT>) WHERE SEL EQ GC_X.
    CLEAR: <FS_SPLIT>-RSLT,<FS_SPLIT>-MESSAGE.
    CLEAR: ZGTSDS1100.

    ZGTSDS1100-VBELN_VL   = <FS_SPLIT>-VBELN_VL.  "원 DO
    ZGTSDS1100-VBELN_VLSP = <FS_SPLIT>-VBELN_VLSP."분할DO
    ZGTSDS1100-SPLIT      = GC_C.
    ZGTSDS1100-ZPROC      = GC_S.

    "대상 데이터 발췌
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
    IF ZGTSDS1100-FKSTK EQ GC_C. "매출완료
      IF NOT ( ZGTSDS1100-KOSTK EQ <FS_SPLIT>-KOSTK AND
               ZGTSDS1100-WBSTK EQ <FS_SPLIT>-WBSTK AND
               ZGTSDS1100-FKSTK EQ <FS_SPLIT>-FKSTK      ).
        <FS_SPLIT>-KOSTK = ZGTSDS1100-KOSTK.
        <FS_SPLIT>-WBSTK = ZGTSDS1100-WBSTK.
        <FS_SPLIT>-FKSTK = ZGTSDS1100-FKSTK.

        PERFORM SET_LED_S2 CHANGING <FS_SPLIT>.
      ENDIF.
      CONTINUE.
    ENDIF.

    " LOCK OBJECT
    PERFORM SET_LOCK_OBJECT USING ZGTSDS1100-ZPROC.
    IF ZGTSDS1100-RSLT = GC_E.
      <FS_SPLIT>-MESSAGE = ZGTSDS1100-MESSAGE.
      <FS_SPLIT>-RSLT    = ZGTSDS1100-RSLT.
      GV_ERROR = GC_X.
      PERFORM SET_LED_ERROR_S3 CHANGING <FS_SPLIT>.
      CONTINUE.
    ENDIF.

    "DATA FROM ZGTSDT9130
    PERFORM SET_DATA_ETC_ZGTSDT9130 CHANGING ZGTSDS1100.

*   [매출처리]
    PERFORM RUN_BILLING_PROCESS.

    "처리결과
    <FS_SPLIT>-KOSTK = ZGTSDS1100-KOSTK.
    <FS_SPLIT>-WBSTK = ZGTSDS1100-WBSTK.
    <FS_SPLIT>-FKSTK = ZGTSDS1100-FKSTK.
    PERFORM SET_LED_S2 CHANGING <FS_SPLIT>.

    IF ZGTSDS1100-RSLT EQ GC_E.
      GV_ERROR = GC_X.
      PERFORM SET_LED_ERROR_S2 CHANGING <FS_SPLIT>.
    ENDIF.

    "청구문서 정보
    IF <FS_SPLIT>-FKSTK EQ GC_C.
      PERFORM GET_BILL_INFO    USING <FS_SPLIT>-VBELN_VLSP
                            CHANGING <FS_SPLIT>-FKDAT
                                     <FS_SPLIT>-NETWR_VF
                                     <FS_SPLIT>-WAERK_VF.
    ENDIF.


    "메세지
    <FS_SPLIT>-MESSAGE = ZGTSDS1100-MESSAGE.
    <FS_SPLIT>-RSLT    = ZGTSDS1100-RSLT.

    "UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT USING ZGTSDS1100-ZPROC.
  ENDLOOP.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH TEXT-M12 DISPLAY LIKE GC_S.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_ETC_ZGTSDT9130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- ZGTSDS1100
*&---------------------------------------------------------------------*
FORM SET_DATA_ETC_ZGTSDT9130  CHANGING PS_DATA TYPE ZGTSDS1100.
  DATA: LV_VBELN TYPE LIKP-VBELN.

  CASE PS_DATA-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = PS_DATA-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = PS_DATA-VBELN_VL.
  ENDCASE.

  SELECT SINGLE *
    FROM ZGTSDT9130
   WHERE VBELN EQ @LV_VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_LINE).
  IF SY-SUBRC EQ 0.
    PS_DATA-SPMON      = LS_LINE-SPMON.     "적송 매출처리 월
    PS_DATA-FKDAT      = LS_LINE-FKDAT.     "청구일
    PS_DATA-NETWR_BL_H = LS_LINE-NETWR.     "실매출금액
    PS_DATA-NETWR_UBO  = LS_LINE-NETWR_UBO. "유보금액
    PS_DATA-WAERK      = LS_LINE-WAERK.     "통화

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_POST_BILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_POST_BILL .
  DATA: LV_VBELN TYPE LIKP-VBELN.
  DATA: LV_FKDAT TYPE VBRK-FKDAT.
  DATA: LV_AMT_IN TYPE ZGTE_AMNT,
        LV_AMT_OT TYPE ZGTE_AMNT.
  DATA: L_MAECHUL.
  DATA: LV_MESSAGE(220).
  DATA: XVBFS TYPE TABLE OF VBFS.

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-BDC
  PERFORM DO_POST_BILL_BDC USING LV_VBELN.

  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.
  CTU_PARAMS-NOBINPT  =  'X'.

* VOFM 청구복사전송 FORM DATEN_KOPIEREN_907 에서 IMPORT
  L_MAECHUL = 'X'.
  EXPORT L_MAECHUL TO MEMORY ID 'ZSD013'.

  SET PARAMETER ID 'VFR' FIELD LV_VBELN.
  CALL TRANSACTION 'VF01'  USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VF' MSGNR = '311' ] ).
    WAIT UP TO '0.5' SECONDS.

    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
    ZGTSDS1100-RSLT   = GC_S.
    ZGTSDS1100-BILL   = ICON_LED_GREEN.
    DATA(LV_BILDOC) = VALUE VBELN_VF( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VF' MSGNR = '311' ]-MSGV1 OPTIONAL ).
    MESSAGE S112 WITH LV_BILDOC INTO ZGTSDS1100-MESSAGE.

  ELSE.
    IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VF' MSGNR = '050' ] ).
      "상태
      PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
      ZGTSDS1100-RSLT   = GC_E.
      ZGTSDS1100-BILL   = ICON_LED_RED.
      CLEAR LV_BILDOC.
      DATA(LS_MSG) = VALUE #( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VF' MSGNR = '050' ] OPTIONAL ).
      CLEAR LV_MESSAGE.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MESSAGE.
      ZGTSDS1100-MESSAGE = LV_MESSAGE.
    ELSE.

      ZGTSDS1100-RSLT    = GC_E.
      ZGTSDS1100-BILL    = ICON_LED_RED.
      ZGTSDS1100-MESSAGE = TEXT-M14.

      LOOP AT GT_RETMSG INTO LS_MSG WHERE MSGTYP CA 'AE'.
        CLEAR LV_MESSAGE.
        PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                    LS_MSG-MSGNR
                                    LS_MSG-MSGV1
                                    LS_MSG-MSGV2
                                    LS_MSG-MSGV3
                                    LS_MSG-MSGV4
                                    LV_MESSAGE.
        IF ZGTSDS1100-MESSAGE IS INITIAL.
          ZGTSDS1100-MESSAGE = LV_MESSAGE.
        ELSE.
          ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
        ENDIF.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        IMPORT XVBFS FROM MEMORY ID 'ZGTSDR2020_VF'.
        IF XVBFS[] IS NOT INITIAL.
          LOOP AT XVBFS INTO DATA(LS_XVBFS) WHERE MSGTY CA 'AE'.
            CLEAR LV_MESSAGE.
            PERFORM MESSAGE_BUILD USING LS_XVBFS-MSGID
                                        LS_XVBFS-MSGNO
                                        LS_XVBFS-MSGV1
                                        LS_XVBFS-MSGV2
                                        LS_XVBFS-MSGV3
                                        LS_XVBFS-MSGV4
                                        LV_MESSAGE.
            IF ZGTSDS1100-MESSAGE IS INITIAL.
              ZGTSDS1100-MESSAGE = LV_MESSAGE.
            ELSE.
              ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

**-INIT BAPI PARAMETERS
*  CLEAR:GT_BDATAIN[],GT_CONDTIN[],GT_SUCCESS[],GT_RETURN[].
*
**-LIPS+LIKP
*  SELECT A~VBELN,A~POSNR,A~UECHA,A~MATNR,A~WERKS,A~LGORT,A~CHARG,A~LFIMG,A~VRKME,
*         B~WADAT_IST,B~VBTYP,B~FKARV
*    FROM LIPS AS A INNER JOIN LIKP AS B
*                   ON A~VBELN = B~VBELN
*   WHERE A~VBELN EQ @LV_VBELN
*    INTO TABLE @DATA(LT_LIPS).
*
*  DATA(LT_LIST) = LT_LIPS[].
*  DELETE LT_LIST WHERE UECHA NE '000000'.
*  SORT LT_LIST BY POSNR.

**-청구일
*  LV_FKDAT = ZGTSDS1100-FKDAT.
*
**-BAPI PARAMETER 구성
*  "ITEM
*  LOOP AT LT_LIST INTO DATA(LS_LIST).
*    CLEAR:GS_BDATAIN.
*
*    GS_BDATAIN-REF_DOC         = LS_LIST-VBELN.
*    GS_BDATAIN-REF_ITEM        = LS_LIST-POSNR.
*    GS_BDATAIN-BILL_DATE       = LV_FKDAT.
*    GS_BDATAIN-REF_DOC_CA_LONG = LS_LIST-VBTYP.
*
*    GS_BDATAIN-REQ_QTY = REDUCE KWMENG( INIT LV_QTY TYPE LFIMG
*                                         FOR LS_LIPS IN LT_LIPS
*                                          WHERE ( POSNR = LS_LIST-POSNR OR
*                                                  UECHA = LS_LIST-POSNR    )
*                                        NEXT LV_QTY = LV_QTY + LS_LIPS-LFIMG  ).
*
*    APPEND GS_BDATAIN TO GT_BDATAIN.
*
*  ENDLOOP.
*
*  "유보금액
*  IF ZGTSDS1100-NETWR_UBO NE 0.
*    CLEAR GS_CONDTIN.
*    GS_CONDTIN-COND_TYPE   = GC_KSCHL_ZRMR.
*    GS_CONDTIN-COND_CURR   = ZGTSDS1100-WAERK.
*
*    LV_AMT_IN = ZGTSDS1100-NETWR_UBO.
*    LV_AMT_OT = ZGTSD_CL_COMMON2=>GET_CURR_EXTERNAL( IV_WAERS = ZGTSDS1100-WAERK
*                                                     IV_AMT   = LV_AMT_IN
*                                                   ).
*    GS_CONDTIN-COND_VALUE  = LV_AMT_OT.
*
*    APPEND GS_CONDTIN TO GT_CONDTIN.
*  ENDIF.
*
**-BAPI CALL
*
** VOFM 청구복사전송 FORM DATEN_KOPIEREN_907 에서 IMPORT
*  L_MAECHUL = 'X'.
*  EXPORT L_MAECHUL TO MEMORY ID 'ZSD013'.
*
*  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
*    TABLES
*      BILLINGDATAIN   = GT_BDATAIN
*      CONDITIONDATAIN = GT_CONDTIN
*      RETURN          = GT_RETURN
*      SUCCESS         = GT_SUCCESS.
*
*  FREE MEMORY ID 'ZSD013'.
*
*  LOOP AT GT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
*    IF LV_MESSAGE IS INITIAL.
*      LV_MESSAGE = LS_RETURN-MESSAGE.
*    ELSE.
*      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
*    ENDIF.
*  ENDLOOP.
*  IF SY-SUBRC EQ 0.
*    __BAPI_TRANSACTION_ROLLBACK.
*
*    ZGTSDS1100-RSLT    = GC_E.
*    ZGTSDS1100-PGIS    = ICON_LED_RED.
*    ZGTSDS1100-MESSAGE = LV_MESSAGE.
*
*  ELSE.
*    __BAPI_TRANSACTION_COMMIT.
*
*    WAIT UP TO '0.5' SECONDS.
*
*    "상태
*    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
*    IF ZGTSDS1100-FKSTK EQ GC_C.
*      ZGTSDS1100-RSLT   = GC_S.
*      ZGTSDS1100-BILL   = ICON_LED_GREEN.
*      CLEAR LS_RETURN.
*      READ TABLE GT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_S
*                                                     ID = 'VF'
*                                                 NUMBER = '311'.
*      IF SY-SUBRC EQ 0.
*        ZGTSDS1100-MESSAGE   = LS_RETURN-MESSAGE.
*      ELSE.
*        "청구문서
*        DATA(LV_VBELN_VF) = VALUE #( GT_SUCCESS[ 1 ]-BILL_DOC OPTIONAL ).
*        SELECT SINGLE VBELN
*          FROM VBRK
*         WHERE VBELN EQ @LV_VBELN_VF
*          INTO @DATA(LV_DOC).
*        MESSAGE S112 WITH LV_DOC INTO ZGTSDS1100-MESSAGE.
*
*      ENDIF.
*    ELSE.
*      ZGTSDS1100-RSLT    = GC_E.
*      ZGTSDS1100-BILL    = ICON_LED_RED.
*      ZGTSDS1100-MESSAGE = TEXT-M10.
*    ENDIF.
*
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_ERROR_S2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_SPLIT>
*&---------------------------------------------------------------------*
FORM SET_LED_ERROR_S2  CHANGING PS_SPLIT LIKE GS_SPLIT.
  "피킹
  IF ZGTSDS1100-PICK EQ ICON_LED_RED.
    PS_SPLIT-ST_PICK = ICON_LED_RED.
  ENDIF.
  "출고
  IF ZGTSDS1100-PGIS EQ ICON_LED_RED.
    PS_SPLIT-ST_PGI = ICON_LED_RED.
  ENDIF.
  "매출
  IF ZGTSDS1100-BILL EQ ICON_LED_RED.
    PS_SPLIT-ST_BILL = ICON_LED_RED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_0200 .
  LOOP AT GT_ITEM INTO DATA(LS_ITEM) WHERE FACTOR_B > 0.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M13 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_0200_S2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_0200_S2 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_POST_BILL_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM DO_POST_BILL_BDC  USING    PV_VBELN.
  DATA:LV_TEXT(20).

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

*  PERFORM DYNPRO USING :
*                        'X'  'SAPMV60A'    '0102',
*                        ' '  'BDC_OKCODE'  '/00',
*                        ' '  'RV60A-FKDAT' ZGTSDS1100-FKDAT.

*  PERFORM  DYNPRO  USING :
*                 'X'  'SAPMV60A'         '0102',
*                 ' '  'BDC_OKCODE'       '=FKAN',
*                 ' '  'KOMFK-VBELN(01)'  ' '.

  PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '/00',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(01)',
               ' '  'RV60A-FKDAT'      ZGTSDS1100-FKDAT,
               ' '  'RV60A-SELKZ(01)'  'X',
               ' '  'KOMFK-VBELN(01)'  PV_VBELN.


  IF ZGTSDS1100-NETWR_UBO NE 0.
    "유보금액
    WRITE: ZGTSDS1100-NETWR_UBO TO LV_TEXT CURRENCY ZGTSDS1100-WAERK NO-GROUPING.
    CONDENSE LV_TEXT.

    PERFORM DYNPRO USING :
                          'X'  'SAPMV60A'    '0104',
                          ' '  'BDC_OKCODE'  '=KFKO'.

    PERFORM DYNPRO USING :
                          'X'  'SAPMV60A'    '6001',
                          ' '  'BDC_OKCODE'  '=V69A_KOAN'.

    PERFORM DYNPRO USING :
                          'X'  'SAPMV60A'    '6001',
                          ' '  'BDC_OKCODE'  '/00',
                          ' '  'KOMV-KSCHL(02)' GC_KSCHL_ZRMR,
                          ' '  'KOMV-KBETR(02)' LV_TEXT,
                          ' '  'RV61A-KOEIN(02)' ZGTSDS1100-WAERK.

    PERFORM DYNPRO USING :
                          'X'  'SAPMV60A'    '6001',
                          ' '  'BDC_OKCODE'  '=BACK'.

  ENDIF.

  PERFORM DYNPRO USING :
                          'X'  'SAPMV60A'    '0104',
                          ' '  'BDC_OKCODE'  '=SICH'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MESSAGE_0200 USING PV_FIELD.

  IF ( ZGTSDS1100-SPLT EQ ICON_LED_RED OR
       ZGTSDS1100-PICK EQ ICON_LED_RED OR
       ZGTSDS1100-PGIS EQ ICON_LED_RED OR
       ZGTSDS1100-BILL EQ ICON_LED_RED    ) AND
      ZGTSDS1100-RSLT EQ GC_E.
    MESSAGE I000 WITH ZGTSDS1100-MESSAGE(50)
                       ZGTSDS1100-MESSAGE+50(50)
                       ZGTSDS1100-MESSAGE+100(50)
                       ZGTSDS1100-MESSAGE+150(50)
     DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_DO_LINE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_DO_LINE_ITEM .
  DATA: LS_HEADER        LIKE  BAPIOBDLVHDRCHG,
        LS_CONTROL       LIKE  BAPIOBDLVHDRCTRLCHG,
        LV_DELIVERY      LIKE  BAPIOBDLVHDRCHG-DELIV_NUMB,
        LS_TECHN_CONTROL LIKE  BAPIDLVCONTROL,
        LT_ITEM_DATA     TYPE TABLE OF BAPIOBDLVITEMCHG,
        LS_ITEM_DATA     TYPE BAPIOBDLVITEMCHG,
        LT_ITEM_CONTROL  TYPE TABLE OF  BAPIOBDLVITEMCTRLCHG,
        LS_ITEM_CONTROL  TYPE BAPIOBDLVITEMCTRLCHG,
        LT_RETURN        TYPE TABLE OF BAPIRET2.

  DATA: LV_LFIMG TYPE LIPS-LFIMG.

  DATA: LV_MESSAGE(200).

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @ZGTSDS1100-VBELN_VL
    INTO TABLE @DATA(LT_LIPS).
  SORT LT_LIPS BY UECHA POSNR.

  DATA(LT_BASE) = LT_LIPS[].
  DELETE LT_BASE WHERE UECHA NE '000000'.

  LOOP AT LT_BASE INTO DATA(LS_BASE).
    CLEAR: LV_LFIMG.

    LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA = LS_BASE-POSNR.
      LV_LFIMG = LV_LFIMG + LS_LIPS-LFIMG.
      IF LS_LIPS-LFIMG <= 0.
        CLEAR:LS_ITEM_DATA.
        LS_ITEM_DATA-DELIV_NUMB = LS_LIPS-VBELN.
        LS_ITEM_DATA-DELIV_ITEM = LS_LIPS-POSNR.
        APPEND LS_ITEM_DATA TO LT_ITEM_DATA.

        CLEAR:LS_ITEM_CONTROL.
        LS_ITEM_CONTROL-DELIV_NUMB = LS_LIPS-VBELN.
        LS_ITEM_CONTROL-DELIV_ITEM = LS_LIPS-POSNR.
        LS_ITEM_CONTROL-DEL_ITEM   = GC_X.
        APPEND LS_ITEM_CONTROL TO LT_ITEM_CONTROL.
      ENDIF.
    ENDLOOP.
    "배치라인이 모두 수량이 0이면 MAIN 아이템도 삭제
    IF LV_LFIMG <= 0.
      CLEAR:LS_ITEM_DATA.
      LS_ITEM_DATA-DELIV_NUMB = LS_BASE-VBELN.
      LS_ITEM_DATA-DELIV_ITEM = LS_BASE-POSNR.
      APPEND LS_ITEM_DATA TO LT_ITEM_DATA.

      CLEAR:LS_ITEM_CONTROL.
      LS_ITEM_CONTROL-DELIV_NUMB = LS_BASE-VBELN.
      LS_ITEM_CONTROL-DELIV_ITEM = LS_BASE-POSNR.
      LS_ITEM_CONTROL-DEL_ITEM   = GC_X.
      APPEND LS_ITEM_CONTROL TO LT_ITEM_CONTROL.
    ENDIF.

  ENDLOOP.

  CHECK LT_ITEM_DATA[] IS NOT INITIAL.

  "헤더
  LS_HEADER-DELIV_NUMB  = ZGTSDS1100-VBELN_VL.
  LS_CONTROL-DELIV_NUMB = ZGTSDS1100-VBELN_VL.

  LV_DELIVERY           = ZGTSDS1100-VBELN_VL.

*-BAPI 수행
  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      HEADER_DATA    = LS_HEADER
      HEADER_CONTROL = LS_CONTROL
      DELIVERY       = LV_DELIVERY
    TABLES
      ITEM_DATA      = LT_ITEM_DATA
      ITEM_CONTROL   = LT_ITEM_CONTROL
      RETURN         = LT_RETURN[].

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    ZGTSDS1100-RSLT    = GC_E.
    ZGTSDS1100-PICK    = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M18.
    ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }{ LV_MESSAGE }|.

  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOCK_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LOCK_OBJECT USING PV_STEP.
  DATA: LV_VBELN TYPE LIKP-VBELN.

  CASE PV_STEP.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTSDT9130'
    EXPORTING
      VBELN          = LV_VBELN
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    CLEAR ZGTSDS1100-LOCK.
    ZGTSDS1100-RSLT = GC_E.
    MESSAGE ID SY-MSGID TYPE GC_I NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
       INTO ZGTSDS1100-MESSAGE.
  ELSE.
    ZGTSDS1100-LOCK = GC_X.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_UNLOCK_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_O
*&---------------------------------------------------------------------*
FORM SET_UNLOCK_OBJECT  USING    PV_STEP.
  DATA: LV_VBELN TYPE LIKP-VBELN.

  CASE PV_STEP.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

  CALL FUNCTION 'DEQUEUE_EZGT_ZGTSDT9110'
    EXPORTING
      VBELN = LV_VBELN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_ERROR_S3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_SPLIT>
*&---------------------------------------------------------------------*
FORM SET_LED_ERROR_S3  CHANGING PS_SPLIT LIKE GS_SPLIT.
  "PICKING :
  IF PS_SPLIT-KOSTK NE GC_C.
    PS_SPLIT-ST_PICK = ICON_LED_RED.
    EXIT.
  ENDIF.

  "출고 :
  IF PS_SPLIT-WBSTK NE GC_C.
    PS_SPLIT-ST_PGI = ICON_LED_RED.
    EXIT.
  ENDIF.

  "매출 :
  IF PS_SPLIT-FKSTK NE GC_C.
    PS_SPLIT-ST_BILL = ICON_LED_RED.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BILLING_JS_RUN_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BILLING_JS_RUN_0100_TOP .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID1.

*-01. CHECK
  CLEAR GV_ERROR.
  IF LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
  ELSE.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM CHECK_BILLING_JS_RUN_0100_TOP.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 적송 매출 처리
  PERFORM RUN_BILLING_PROCESS_0100_TOP.

  PERFORM REFRESH_ALV USING: GO_GRID1,
                             GO_GRID2.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH TEXT-M12 DISPLAY LIKE GC_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_RUN_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_RUN_0100_TOP .
  DATA: LV_CNT TYPE I.

  DATA(LS_LIST) = VALUE #( GT_LIST[ SEL = GC_X ] OPTIONAL ).
  SELECT SINGLE KOSTK,WBSTK,FKSTK
    FROM LIKP
   WHERE VBELN EQ @LS_LIST-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF LS_LIKP-KOSTK NE GC_C.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M19 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  IF LS_LIKP-FKSTK EQ GC_C.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M20 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_PROCESS_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_PROCESS_0100_TOP .
  CLEAR GV_ERROR.
  CLEAR: ZGTSDS1100.

  READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WITH KEY SEL = GC_X.
  CHECK SY-SUBRC EQ 0.

  ZGTSDS1100-VBELN_VL   = <FS_LIST>-VBELN_VL.  "원 DO
  ZGTSDS1100-ZPROC      = GC_O.
  "대상 데이터 발췌
  PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
  IF ZGTSDS1100-FKSTK EQ GC_C. "매출완료
    IF NOT ( ZGTSDS1100-KOSTK EQ <FS_LIST>-KOSTK AND
             ZGTSDS1100-WBSTK EQ <FS_LIST>-WBSTK AND
             ZGTSDS1100-FKSTK EQ <FS_LIST>-FKSTK      ).
      <FS_LIST>-KOSTK = ZGTSDS1100-KOSTK.
      <FS_LIST>-WBSTK = ZGTSDS1100-WBSTK.
      <FS_LIST>-FKSTK = ZGTSDS1100-FKSTK.

      PERFORM SET_LED_S4 CHANGING <FS_LIST>.
    ENDIF.
    EXIT.
  ENDIF.

  " LOCK OBJECT
  PERFORM SET_LOCK_OBJECT USING ZGTSDS1100-ZPROC.
  IF ZGTSDS1100-RSLT = GC_E.
    <FS_LIST>-MESSAGE = ZGTSDS1100-MESSAGE.
    <FS_LIST>-RSLT    = ZGTSDS1100-RSLT.
    GV_ERROR = GC_X.
    PERFORM SET_LED_ERROR_S4 CHANGING <FS_LIST>.
    EXIT.
  ENDIF.

  "DATA FROM ZGTSDT9130
  PERFORM SET_DATA_ETC_ZGTSDT9130 CHANGING ZGTSDS1100.

*-------------------------------------------------
* [매출처리]
*-------------------------------------------------
  PERFORM RUN_BILLING_PROCESS.

  "처리결과
  <FS_LIST>-KOSTK = ZGTSDS1100-KOSTK.
  <FS_LIST>-WBSTK = ZGTSDS1100-WBSTK.
  <FS_LIST>-FKSTK = ZGTSDS1100-FKSTK.
  PERFORM SET_LED_S4 CHANGING <FS_LIST>.

  IF ZGTSDS1100-RSLT EQ GC_E.
    GV_ERROR = GC_X.
    PERFORM SET_LED_ERROR_S4 CHANGING <FS_LIST>.
  ENDIF.

  "청구문서 정보
  IF <FS_LIST>-FKSTK EQ GC_C.
    PERFORM GET_BILL_INFO    USING <FS_LIST>-VBELN_VL
                          CHANGING <FS_LIST>-FKDAT
                                   <FS_LIST>-NETWR_VF
                                   <FS_LIST>-WAERK_VF.
  ENDIF.

  "메세지
  <FS_LIST>-MESSAGE = ZGTSDS1100-MESSAGE.
  <FS_LIST>-RSLT    = ZGTSDS1100-RSLT.

  "UNLOCK OBJECT
  PERFORM SET_UNLOCK_OBJECT USING ZGTSDS1100-ZPROC.

*  "DO SPLIT 리스트 구성
*  PERFORM GET_SPLIT_DO_LIST USING <FS_LIST>.
*  PERFORM CELL_ATTRIBUTES_0100_BOT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_S3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED_S4  CHANGING PS_LIST LIKE GT_LIST.
  "PICKING :
  IF PS_LIST-KOSTK EQ GC_C.
    PS_LIST-ST_PICK = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PICK = ICON_LED_YELLOW.
  ENDIF.

  "출고 :
  IF PS_LIST-WBSTK EQ GC_C.
    PS_LIST-ST_PGI = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PGI = ICON_LED_YELLOW.
  ENDIF.

  "매출 :
  IF PS_LIST-FKSTK EQ GC_C.
    PS_LIST-ST_BILL = ICON_LED_GREEN.
    PS_LIST-ST_FINSH = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_BILL = ICON_LED_YELLOW.
    PS_LIST-ST_FINSH = ICON_LED_YELLOW.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_ERROR_S4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED_ERROR_S4  CHANGING PS_LIST LIKE GT_LIST.
  "PICKING :
  IF PS_LIST-KOSTK NE GC_C.
    PS_LIST-ST_PICK = ICON_LED_RED.
    EXIT.
  ENDIF.

  "출고 :
  IF PS_LIST-WBSTK NE GC_C.
    PS_LIST-ST_PGI = ICON_LED_RED.
    EXIT.
  ENDIF.

  "매출 :
  IF PS_LIST-FKSTK NE GC_C.
    PS_LIST-ST_BILL = ICON_LED_RED.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGE_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_COLUMN_FIELDNAME
*&      --> LS_LIST
*&---------------------------------------------------------------------*
FORM DISPLAY_MESSAGE_0100_H  USING  PV_FIELDNAM
                                    PS_LIST LIKE GT_LIST.
  IF ( PS_LIST-ST_PICK EQ ICON_LED_RED OR
       PS_LIST-ST_PGI EQ ICON_LED_RED OR
       PS_LIST-ST_BILL EQ ICON_LED_RED    ) AND
      PS_LIST-RSLT EQ GC_E.
    MESSAGE I000 WITH PS_LIST-MESSAGE(50)
                       PS_LIST-MESSAGE+50(50)
                       PS_LIST-MESSAGE+100(50)
                       PS_LIST-MESSAGE+150(50)
     DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_CANCEL_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_CANCEL_JS .

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_BILLING_CANCEL_JS_0200.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-03. 매출취소
  PERFORM PROCESS_BILLING_CANCEL_JS_RUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_CANCEL_JS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_CANCEL_JS_0200 .
  DATA:LV_MSG(200).

  "매출처리 전
  IF ( ZGTSDS1100-ZPROC EQ GC_S AND ZGTSDS1100-SPLIT NE GC_C ) OR
     ( ZGTSDS1100-ZPROC EQ GC_O AND ZGTSDS1100-KOSTK NE GC_C ).
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M21 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  "SPLIT DO 취소처리시 원 DO 상태 체크
  IF ZGTSDS1100-ZPROC EQ GC_S.
    PERFORM CHECK_ORIG_DO_STATUS USING ZGTSDS1100-VBELN_VL
                                 CHANGING LV_MSG.
    IF GV_ERROR EQ GC_X.
      MESSAGE I115 WITH ZGTSDS1100-VBELN_VL LV_MSG DISPLAY LIKE GC_E.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BILLING_CANCEL_JS_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BILLING_CANCEL_JS_RUN .

*-------------------------------------------
* 매출취소
*-------------------------------------------
  PERFORM RUN_BILLING_CANCEL_PROCESS.

*-------------------------------------------

  IF ZGTSDS1100-RSLT EQ GC_E.

    MESSAGE I000 WITH ZGTSDS1100-MESSAGE(50)
                      ZGTSDS1100-MESSAGE+50(50)
                      ZGTSDS1100-MESSAGE+100(50)
                      ZGTSDS1100-MESSAGE+150(50)
    DISPLAY LIKE GC_E.
  ELSE.
    "SCREEN 0200 데이터 재구성
    PERFORM REBUILD_SCREEN_0200.

    "상태
    PERFORM SET_STATUS_ITEM USING SPACE.
    PERFORM SET_STATUS_ITEM_LED.

    MESSAGE I000 WITH ZGTSDS1100-MESSAGE DISPLAY LIKE GC_S.
  ENDIF.

  PERFORM CELL_ATTRIBUTES_0200.
  PERFORM REFRESH_ALV USING GO_GRID3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_CANCEL_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_CANCEL_PROCESS .
  CLEAR:ZGTSDS1100-RSLT,ZGTSDS1100-MESSAGE.

*-매출취소
  IF ZGTSDS1100-FKSTK EQ GC_C.
    PERFORM RUN_DO_POST_BILL_CANC.
  ENDIF.

*-출고취소
  IF ZGTSDS1100-FKSTK NE GC_C.
    IF ZGTSDS1100-WBSTK EQ GC_C.
      PERFORM RUN_DO_POST_GI_CANC.
    ENDIF.
  ENDIF.

*-피킹취소 : 원 DO, 납품삭제 - SPLIT DO
  IF ZGTSDS1100-WBSTK NE GC_C.
    IF ZGTSDS1100-KOSTK EQ GC_C.
      CASE ZGTSDS1100-ZPROC.
        WHEN GC_O.
          PERFORM RUN_DO_PICKING_CANCEL.

        WHEN GC_S.
          PERFORM RUN_SPLIT_DO_DELETE.

      ENDCASE.

    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_POST_BILL_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_POST_BILL_CANC .
  DATA: LV_BILLINGDOCUMENT TYPE  BAPIVBRKSUCCESS-BILL_DOC,
        LV_BILLINGDATE     TYPE  BF_DATM1EB,
        LT_RETURN          TYPE TABLE OF  BAPIRETURN1,
        LT_SUCCESS         TYPE TABLE OF BAPIVBRKSUCCESS.

  DATA: LV_STAT TYPE ZGTSDT9110-ZZJS_STATUS,
        LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.
  DATA: LV_VBELN TYPE LIKP-VBELN.
  DATA: LV_MESSAGE(220).

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-청구문서
  SELECT A~VBELN AS VBELN_VL,A~POSNR AS POSNR_VL,
         C~VBELN AS VBELN_VF,C~POSNR AS POSNR_VF,
         D~FKDAT
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBRP AS C
                   ON A~VBELN = C~VGBEL AND
                      A~POSNR = C~VGPOS
                   INNER JOIN VBRK AS D
                   ON C~VBELN = D~VBELN AND
                      D~SFAKN = @SPACE  AND
                      D~FKSTO = @SPACE
   WHERE A~VBELN  EQ @LV_VBELN
     AND A~UECHA  EQ '000000'
     AND B~LFART  EQ @GC_LFART_ZLF3
    INTO TABLE @DATA(LT_VBRP).
  IF SY-SUBRC NE 0.
    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
    ZGTSDS1100-RSLT    = GC_E.
    ZGTSDS1100-BILL    = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M22.
    EXIT.
  ENDIF.

*-청구문서 취소
  DATA(LS_VBRP) = VALUE #( LT_VBRP[ 1 ] OPTIONAL ).

  LV_BILLINGDOCUMENT = LS_VBRP-VBELN_VF.
  LV_BILLINGDATE     = LS_VBRP-FKDAT.

  CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
    EXPORTING
      BILLINGDOCUMENT = LV_BILLINGDOCUMENT
*     NO_COMMIT       = GC_X
      BILLINGDATE     = LV_BILLINGDATE
    TABLES
      RETURN          = LT_RETURN
      SUCCESS         = LT_SUCCESS.

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    ZGTSDS1100-RSLT    = GC_E.
    ZGTSDS1100-BILL    = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M23.
    ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }{ LV_MESSAGE }|.

  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    WAIT UP TO '1' SECONDS.

    ZGTSDS1100-RSLT   = GC_S.
    ZGTSDS1100-BILL   = ICON_LED_YELLOW.
    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_POST_GI_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_POST_GI_CANC .
  DATA: LV_VBELN TYPE LIKP-VBELN,
        LV_BUDAT TYPE MKPF-BUDAT,
        LV_TCODE TYPE SY-TCODE,
        LV_VBTYP TYPE LIKP-VBTYP.
  DATA: LT_MESG  TYPE TABLE OF MESG,
        LV_MBLNR TYPE MBLNR.
  DATA: LV_MESSAGE(200).

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @LV_VBELN
    INTO @DATA(LS_LIKP).

*-출고취소 : CALL 'ZGTSDR0120_CANCELSEL'
  LV_VBELN = LS_LIKP-VBELN.
  LV_BUDAT = LS_LIKP-WADAT_IST.
  LV_VBTYP = LS_LIKP-VBTYP.
  LV_TCODE = 'VL09'.

  SUBMIT ZGTSDR0120_CANCEL WITH P_VBELN = LV_VBELN
                           WITH P_BUDAT = LV_BUDAT
                           WITH P_TCODE = LV_TCODE
                           WITH P_VBTYP = LV_VBTYP
                           AND RETURN.

  IMPORT LV_MBLNR LT_MESG FROM MEMORY ID 'ZGTSDDOCANC'.
  FREE MEMORY ID 'ZGTSDDOCANC'.

  IF LV_MBLNR IS NOT INITIAL.
    WAIT UP TO '0.5' SECONDS.

    ZGTSDS1100-RSLT   = GC_S.
    ZGTSDS1100-PGIS   = ICON_LED_YELLOW.
    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.

  ELSE.

    LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AE'.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE = LS_MESG-TEXT.
      ELSE.
        LV_MESSAGE = |{ LV_MESSAGE }/{ LS_MESG-TEXT }|.
      ENDIF.
    ENDLOOP.

    ZGTSDS1100-RSLT    = GC_E.
    ZGTSDS1100-PGIS    = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M24.
    ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }{ LV_MESSAGE }|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_SPLIT_DO_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_SPLIT_DO_DELETE .
  DATA : LT_RETURN   TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
         LS_HEADER   TYPE BAPIOBDLVHDRCHG,
         LS_CONTROL  TYPE BAPIOBDLVHDRCTRLCHG,
         LV_DELIVERY TYPE BAPIOBDLVHDRCHG-DELIV_NUMB.
  DATA: LV_VBELN TYPE LIKP-VBELN.
  DATA: LS_ZGTSDT9130 LIKE LINE OF GT_ZGTSDT9130.
  DATA: LV_MESSAGE(220).

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-BAPI PARAMETERS
  LS_HEADER-DELIV_NUMB  = LV_VBELN.
  LS_CONTROL-DELIV_NUMB = LV_VBELN.
  LS_CONTROL-DLV_DEL    = GC_X.
  LV_DELIVERY           = LV_VBELN.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      HEADER_DATA    = LS_HEADER
      HEADER_CONTROL = LS_CONTROL
      DELIVERY       = LV_DELIVERY
    TABLES
      RETURN         = LT_RETURN[].

  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    ZGTSDS1100-RSLT    = GC_E.
    ZGTSDS1100-BILL    = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M25.
    ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }{ LV_MESSAGE }|.

  ELSE.

    "ZGTSDT9130 삭제 지시자
    PERFORM SET_DEL_FLAG_ZGTSDT9130 USING LV_VBELN.

    __BAPI_TRANSACTION_COMMIT.

    ZGTSDS1100-RSLT  = GC_S.

*    ZGTSDS1100-SPLIT = GC_A. "납품분할
    ZGTSDS1100-KOSTK = GC_A. "PICKING

*    ZGTSDS1100-SPLT = ICON_LED_YELLOW.
    ZGTSDS1100-PICK = ICON_LED_YELLOW.

*---원DO 배치분할 원복
    PERFORM UNDO_DO_SPLIT USING LV_VBELN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEL_FLAG_ZGTSDT9130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM SET_DEL_FLAG_ZGTSDT9130  USING    PV_VBELN.

  UPDATE ZGTSDT9130 SET LOEVM = GC_X
                  WHERE VBELN EQ PV_VBELN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ORIG_DO_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZGTSDS1100_VBELN_VL
*&---------------------------------------------------------------------*
FORM CHECK_ORIG_DO_STATUS USING PV_VBELN
                          CHANGING PV_MSG.

  SELECT SINGLE *
      FROM LIKP
     WHERE VBELN EQ @PV_VBELN
      INTO @DATA(LS_LIKP).

  IF NOT ( LS_LIKP-KOSTK EQ GC_A AND
           LS_LIKP-WBSTK EQ GC_A AND
           LS_LIKP-FKSTK EQ GC_A      ).

    GV_ERROR = GC_X.
    IF LS_LIKP-KOSTK EQ GC_C.
      PV_MSG = TEXT-004.
    ENDIF.
    IF LS_LIKP-WBSTK EQ GC_C.
      IF PV_MSG IS INITIAL.
        PV_MSG = TEXT-003.
      ELSE.
        PV_MSG = |{ PV_MSG }/{ TEXT-003 }|.
      ENDIF.
    ENDIF.
    IF LS_LIKP-FKSTK EQ GC_C.
      IF PV_MSG IS INITIAL.
        PV_MSG = TEXT-002.
      ELSE.
        PV_MSG = |{ PV_MSG }/{ TEXT-002 }|.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR GV_ERROR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BILLING_JS_CANC_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BILLING_JS_CANC_0100_BOT .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID2.

*-01. CHECK
  CLEAR GV_ERROR.
  IF LINE_EXISTS( GT_SPLIT[ SEL = GC_X ] ).
  ELSE.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM CHECK_BILLING_JS_CANC_0100_BOT.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-02. 적송 매출취소 처리
  PERFORM RUN_BILLING_CANC_0100_BOT.

  PERFORM REFRESH_ALV USING: GO_GRID1,
                             GO_GRID2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNDO_DO_SPLIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM UNDO_DO_SPLIT  USING    PV_VBELN.
  DATA:LV_VBELN_VLSP TYPE LIKP-VBELN, "SPLIT DO
       LV_VBELN_VL   TYPE LIKP-VBELN. "원DO
  DATA:LV_TEXT(20).
  DATA:LV_MESSAGE(200).
  DATA:LV_NO_POPUP(10).

  CLEAR:GT_ZGTSDT9130[],GT_LIPS[].

  "SPLIT DO
  LV_VBELN_VLSP = PV_VBELN.

*-삭제된 SPLIT DO 정보(ZGTSDT9130)
  SELECT *
    FROM ZGTSDT9130
   WHERE VBELN EQ @LV_VBELN_VLSP
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTSDT9130.

*-원DO 정보(LIPS)
  LV_VBELN_VL = VALUE #( GT_ZGTSDT9130[ 1 ]-VBELN_OR OPTIONAL ).

  SELECT *
    FROM LIPS
   WHERE VBELN EQ @LV_VBELN_VL
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIPS.

*-BDC DATA
* 납품분할 원복시(DO변경) 원 DO의 삭제된 아이템 추가시 여신체크 결과에 대한 warning 메세지를
* FM 'SD_DELIVERY_CREDIT_CHECK' LINE 817에서 POP-UP 메세지를 보여줌 => BDC 수행 불가하여
* 원 DO가 납품분할 전으로 원복이 안됨.
* => FM 'SD_DELIVERY_CREDIT_CHECK' LINE 817에서 IMPORT 하여 PASS 처리
  LV_NO_POPUP = 'UNDO_SPLIT'.
  EXPORT LV_NO_POPUP TO MEMORY ID 'ZGTSDR2020_DOSPLIT'.

  "BDC 데이터 작성
  PERFORM MAKE_UNDO_DO_SPLIT_BDC USING LV_VBELN_VLSP LV_VBELN_VL.

  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.
  CTU_PARAMS-NOBINPT  =  'X'.

  "
  CALL TRANSACTION 'VL02N'  USING        GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.
  FREE MEMORY ID 'ZGTSDR2020_DOSPLIT'.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).

    ZGTSDS1100-RSLT  = GC_S.
    ZGTSDS1100-SPLT  = ICON_LED_YELLOW.
    ZGTSDS1100-SPLIT = GC_A.
    CLEAR ZGTSDS1100-VBELN_VLSP. "SPLIT DO
    ZGTSDS1100-MESSAGE = TEXT-M27.

  ELSE.

    ZGTSDS1100-RSLT  = GC_E.
    ZGTSDS1100-SPLT  = ICON_LED_RED.
    LV_MESSAGE = TEXT-M26.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
      CLEAR LV_MESSAGE.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MESSAGE.
      IF ZGTSDS1100-MESSAGE IS INITIAL.
        ZGTSDS1100-MESSAGE = LV_MESSAGE.
      ELSE.
        ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
      ENDIF.
    ENDLOOP.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_UNDO_DO_SPLIT_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VBELN_VLSP
*&      --> LV_VBELN_VL
*&---------------------------------------------------------------------*
FORM MAKE_UNDO_DO_SPLIT_BDC  USING    PV_VBELN_VLSP
                                      PV_VBELN_VL.
  DATA:LV_VBELN_VLSP TYPE LIKP-VBELN, "SPLIT DO
       LV_VBELN_VL   TYPE LIKP-VBELN. "원DO
  DATA:LV_POSNR    TYPE LIPS-POSNR,
       LV_LFIMG    TYPE LIPS-LFIMG,
       LV_TEXT(50).
  DATA:LT_BASE TYPE TABLE OF ZGTSDT9130.

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  LV_VBELN_VLSP = PV_VBELN_VLSP.
  LV_VBELN_VL   = PV_VBELN_VL.

  LT_BASE[] = GT_ZGTSDT9130[].
  SORT LT_BASE BY UECHA.
  DELETE ADJACENT DUPLICATES FROM LT_BASE COMPARING UECHA.

  "LIPS의 POSNR MAX값
  SORT GT_LIPS BY UECHA DESCENDING.
  GV_POSNR = VALUE #( GT_LIPS[ 1 ]-UECHA OPTIONAL ).

  SORT: GT_ZGTSDT9130 BY UECHA POSNR,
        GT_LIPS       BY UECHA POSNR VGBEL VGPOS.



*-VL02N
  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  LV_VBELN_VL.

  LOOP AT LT_BASE INTO DATA(LS_BASE).
    READ TABLE GT_LIPS INTO DATA(LS_LIPS) WITH KEY UECHA = LS_BASE-UECHA
                                                   VGBEL = LS_BASE-VGBEL
                                                   VGPOS = LS_BASE-VGPOS.
    IF SY-SUBRC EQ 0.
*     [ITEM 존재]
      PERFORM DO_ITEM_CHANG_S1 USING LS_BASE.

    ELSE.

*     [ITEM 미 존재]
      PERFORM DO_ITEM_CHANG_S2 USING LS_BASE.

    ENDIF.

  ENDLOOP.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_ITEM_CHANG_S1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_BASE
*&---------------------------------------------------------------------*
FORM DO_ITEM_CHANG_S1  USING    PS_BASE TYPE ZGTSDT9130.
  DATA:LV_POSNR    TYPE LIPS-POSNR,
       LV_LFIMG    TYPE LIPS-LFIMG,
       LV_TEXT(50).


  "ITEM선택
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '1000',
                         ' '  'BDC_OKCODE'  '=POPO_T'.

  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '0111',
                         ' '  'BDC_OKCODE'  '=WEIT',
                         ' '  'RV50A-POSNR'  PS_BASE-UECHA.

  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '1000',
                         ' '  'BDC_CURSOR'  'LIPS-POSNR(01)',
                         ' '  'BDC_OKCODE'  '=IDET_T'.

  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '3000',
                         ' '  'BDC_OKCODE'  '=T\03'.

  "배치분할 화면
  LOOP AT GT_ZGTSDT9130 INTO DATA(LS_ZGTSDT9130) WHERE UECHA = PS_BASE-UECHA
                                                   AND VGBEL = PS_BASE-VGBEL
                                                   AND VGPOS = PS_BASE-VGPOS.
    READ TABLE GT_LIPS INTO DATA(LS_LIPS) WITH KEY POSNR = LS_ZGTSDT9130-POSNR
                                                   UECHA = LS_ZGTSDT9130-UECHA
                                                   CHARG = LS_ZGTSDT9130-CHARG
                                                   VGBEL = LS_ZGTSDT9130-VGBEL
                                                   VGPOS = LS_ZGTSDT9130-VGPOS.
    IF SY-SUBRC EQ 0.
      "배치라인 항번이 있는경우 ZGTSDT9130의 수량을 더한다.
      CLEAR:LV_LFIMG,LV_TEXT.
      LV_LFIMG = LS_ZGTSDT9130-LFIMG + LS_LIPS-LFIMG.
      WRITE:LV_LFIMG TO LV_TEXT UNIT LS_LIPS-VRKME NO-GROUPING.
      CONDENSE LV_TEXT.

      "배치번호 선택
      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'    '3000',
                             ' '  'BDC_OKCODE'  '=POPO_T'.

      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'    '0111',
                             ' '  'BDC_OKCODE'  '=WEIT',
                             ' '  'RV50A-POSNR'  LS_ZGTSDT9130-POSNR.
      "합계수량 지정
      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'        '3000',
                             ' '  'BDC_OKCODE'      '/00',
                             ' '  'LIPS-LFIMG(01)'  LV_TEXT.

    ELSE.


      "동일배치라인 체크
      CLEAR LS_LIPS.
      READ TABLE GT_LIPS INTO LS_LIPS WITH KEY UECHA = LS_ZGTSDT9130-UECHA
                                               CHARG = LS_ZGTSDT9130-CHARG
                                               VGBEL = LS_ZGTSDT9130-VGBEL
                                               VGPOS = LS_ZGTSDT9130-VGPOS.

      IF SY-SUBRC EQ 0.
        CLEAR:LV_LFIMG,LV_TEXT.
        LV_LFIMG = LS_ZGTSDT9130-LFIMG + LS_LIPS-LFIMG.
        WRITE:LV_LFIMG TO LV_TEXT UNIT LS_LIPS-VRKME NO-GROUPING.
        CONDENSE LV_TEXT.
        "배치번호 선택
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '3000',
                               ' '  'BDC_OKCODE'  '=POPO_T'.

        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '0111',
                               ' '  'BDC_OKCODE'  '=WEIT',
                               ' '  'RV50A-POSNR'  LS_LIPS-POSNR.
        "합계수량 지정
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'        '3000',
                               ' '  'BDC_OKCODE'      '/00',
                               ' '  'LIPS-LFIMG(01)'  LV_TEXT.

      ELSE.
        "배치라인 항번이 없는경우 추가
        CLEAR:LV_LFIMG,LV_TEXT.
        WRITE:LS_ZGTSDT9130-LFIMG TO LV_TEXT UNIT LS_LIPS-VRKME NO-GROUPING.
        CONDENSE LV_TEXT.

        "신규라인 추가
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '3000',
                               ' '  'BDC_OKCODE'  '=POAN_T'.

        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'        '3000',
                               ' '  'BDC_OKCODE'      '/00',
                               ' '  'LIPS-CHARG(02)'  LS_ZGTSDT9130-CHARG,
                               ' '  'LIPS-LGORT(02)'  LS_ZGTSDT9130-LGORT,
                               ' '  'LIPS-LFIMG(02)'  LV_TEXT.
      ENDIF.
    ENDIF.

  ENDLOOP.
  "메인화면으로 이동
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'        '3000',
                         ' '  'BDC_OKCODE'      '=BACK_T'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_ITEM_CHANG_S2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_BASE
*&---------------------------------------------------------------------*
FORM DO_ITEM_CHANG_S2  USING    PS_BASE TYPE ZGTSDT9130.
  DATA:LV_POSNR    TYPE LIPS-POSNR,
       LV_LFIMG    TYPE LIPS-LFIMG,
       LV_TEXT(50).

  CLEAR:LV_POSNR.

  LOOP AT GT_LIPS INTO DATA(LS_LIPS) WHERE UECHA EQ '000000'
                                       AND VGBEL EQ PS_BASE-VGBEL
                                       AND VGPOS EQ PS_BASE-VGPOS.
    EXIT.
  ENDLOOP.
*
*  READ TABLE GT_LIPS INTO DATA(LS_LIPS) WITH KEY VGBEL = PS_BASE-VGBEL
*                                                 VGPOS = PS_BASE-VGPOS.
  IF LS_LIPS IS NOT INITIAL. "SY-SUBRC EQ 0.
    "메인아이템 삭제 후 다시 납품분할전으로 원복하면서 신규 아이템 추가 경우
    LV_POSNR = LS_LIPS-POSNR.

    "ITEM선택
    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '0111',
                           ' '  'BDC_OKCODE'  '=WEIT',
                           ' '  'RV50A-POSNR'  LV_POSNR.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_CURSOR'  'LIPS-POSNR(01)',
                           ' '  'BDC_OKCODE'  '=IDET_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '=T\03'.

    "배치분할 화면
    LOOP AT GT_ZGTSDT9130 INTO DATA(LS_ZGTSDT9130) WHERE UECHA = PS_BASE-UECHA
                                                     AND VGBEL = PS_BASE-VGBEL
                                                     AND VGPOS = PS_BASE-VGPOS.
      READ TABLE GT_LIPS INTO LS_LIPS WITH KEY UECHA = LV_POSNR             "LS_ZGTSDT9130-UECHA
                                               CHARG = LS_ZGTSDT9130-CHARG
                                               VGBEL = LS_ZGTSDT9130-VGBEL
                                               VGPOS = LS_ZGTSDT9130-VGPOS.
      IF SY-SUBRC EQ 0.
        "배치라인 항번이 있는경우 ZGTSDT9130의 수량을 더한다.
        CLEAR:LV_LFIMG,LV_TEXT.
        LV_LFIMG = LS_ZGTSDT9130-LFIMG + LS_LIPS-LFIMG.
        WRITE:LV_LFIMG TO LV_TEXT UNIT LS_LIPS-VRKME NO-GROUPING.
        CONDENSE LV_TEXT.

        "배치번호 선택
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '3000',
                               ' '  'BDC_OKCODE'  '=POPO_T'.

        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '0111',
                               ' '  'BDC_OKCODE'  '=WEIT',
                               ' '  'RV50A-POSNR'  LS_ZGTSDT9130-POSNR.
        "합계수량 지정
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'        '3000',
                               ' '  'BDC_OKCODE'      '/00',
                               ' '  'LIPS-LFIMG(01)'  LV_TEXT.

      ELSE.
        "배치라인 항번이 없는경우 추가
        CLEAR:LV_LFIMG,LV_TEXT.
        WRITE:LS_ZGTSDT9130-LFIMG TO LV_TEXT UNIT LS_LIPS-VRKME NO-GROUPING.
        CONDENSE LV_TEXT.
        "신규라인 추가
        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'    '3000',
                               ' '  'BDC_OKCODE'  '=POAN_T'.

        PERFORM DYNPRO USING :
                               'X'  'SAPMV50A'        '3000',
                               ' '  'BDC_OKCODE'      '/00',
                               ' '  'LIPS-CHARG(02)'  LS_ZGTSDT9130-CHARG,
                               ' '  'LIPS-LGORT(02)'  LS_ZGTSDT9130-LGORT,
                               ' '  'LIPS-LFIMG(02)'  LV_TEXT.

      ENDIF.

    ENDLOOP.
    "메인화면으로 이동
    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'        '3000',
                           ' '  'BDC_OKCODE'      '=BACK_T'.

  ELSE.

    GV_POSNR = GV_POSNR + 10.
    PERFORM DO_ITEM_CHANG_S3  USING PS_BASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_ITEM_CHANG_S3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_BASE
*&---------------------------------------------------------------------*
FORM DO_ITEM_CHANG_S3  USING    PS_BASE TYPE ZGTSDT9130.
  DATA:LV_POSNR        TYPE LIPS-POSNR,
       LV_LFIMG        TYPE LIPS-LFIMG,
       LV_INDEX        TYPE SY-TABIX,
       LV_N(2)         TYPE N,
       LV_CHARG_TX(20),
       LV_LGORT_TX(20),
       LV_LFIMG_TX(20),
       LV_TEXT(50).

  "아이템수량
  LOOP AT GT_ZGTSDT9130 INTO DATA(LS_LINE) WHERE UECHA = PS_BASE-UECHA.
    LV_LFIMG =  LV_LFIMG + LS_LINE-LFIMG.
  ENDLOOP.
  WRITE:LV_LFIMG TO LV_TEXT UNIT PS_BASE-VRKME NO-GROUPING.
  CONDENSE LV_TEXT.

  "판매오더 문서를 참조하여 ITEM 생성
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '1000',
                         ' '  'BDC_OKCODE'  '=RAUF_T'.

  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '0105',
                         ' '  'BDC_OKCODE'  '=ENT1',
                         ' '  'LV50C-DATBI'  '9999.12.31',
                         ' '  'LV50C-VBELN'  PS_BASE-VGBEL,
                         ' '  'LV50C-ABPOS'  PS_BASE-VGPOS,
                         ' '  'LV50C-BIPOS'  PS_BASE-VGPOS.

  "생성된 ITEM 선택
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '1000',
                         ' '  'BDC_OKCODE'  '=POPO_T'.

  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'    '0111',
                         ' '  'BDC_OKCODE'  '=WEIT',
                         ' '  'RV50A-POSNR'  GV_POSNR.

  "저장위치 지정
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'           '1000',
                         ' '  'BDC_OKCODE'         '/00',
                         ' '  'LIPSD-G_LFIMG(01)'  LV_TEXT,
                         ' '  'LIPS-LGORT(01)'     PS_BASE-LGORT.

  "라인 떠블클릭
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'       '1000',
                         ' '  'BDC_OKCODE'     '=IDET_T'.
  "배치분할 TAB
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'       '3000',
                         ' '  'BDC_OKCODE'     '=T\03'.


  "배치분할 라인 추가
  LOOP AT GT_ZGTSDT9130 INTO DATA(LS_ZGTSDT9130) WHERE UECHA = PS_BASE-UECHA.
    LV_INDEX = SY-TABIX.
    CLEAR:LV_CHARG_TX,LV_LGORT_TX,LV_LFIMG_TX.
    IF LV_INDEX = 1.
      LV_N = '01'.
    ELSE.
      LV_N = '02'.
    ENDIF.

    LV_CHARG_TX = |LIPS-CHARG({ LV_N })|.
    LV_LGORT_TX = |LIPS-LGORT({ LV_N })|.
    LV_LFIMG_TX = |LIPS-LFIMG({ LV_N })|.


    CLEAR:LV_LFIMG,LV_TEXT.
    WRITE:LS_ZGTSDT9130-LFIMG TO LV_TEXT UNIT LS_ZGTSDT9130-VRKME NO-GROUPING.
    CONDENSE LV_TEXT.

    "신규라인 추가
    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '=POAN_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'        '3000',
                           ' '  'BDC_OKCODE'      '/00',
                           ' '  LV_CHARG_TX       LS_ZGTSDT9130-CHARG,
                           ' '  LV_LGORT_TX       LS_ZGTSDT9130-LGORT,
                           ' '  LV_LFIMG_TX       LV_TEXT.



  ENDLOOP.

  "메인화면으로 이동
  PERFORM DYNPRO USING :
                         'X'  'SAPMV50A'        '3000',
                         ' '  'BDC_OKCODE'      '=BACK_T'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_DO_PICKING_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_DO_PICKING_CANCEL .
  DATA: LV_VBELN TYPE LIKP-VBELN.

  DATA:LV_MESSAGE(200).

  CASE ZGTSDS1100-ZPROC.
    WHEN GC_S. "분할 DO
      LV_VBELN = ZGTSDS1100-VBELN_VLSP.
    WHEN GC_O. "원 DO
      LV_VBELN = ZGTSDS1100-VBELN_VL.
  ENDCASE.

*-LIPS
  CLEAR:GT_LIPS[].
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @LV_VBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIPS.
  SORT GT_LIPS BY UECHA POSNR.

*-BDC DATA
  PERFORM MAKE_UNDO_DO_PICKING_BDC USING LV_VBELN.

  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.
  CTU_PARAMS-NOBINPT  =  'X'.

  CALL TRANSACTION 'VL02N'  USING        GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.
  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).

    ZGTSDS1100-RSLT  = GC_S.
    ZGTSDS1100-PICK  = ICON_LED_YELLOW.
    ZGTSDS1100-MESSAGE = TEXT-M27.

    "상태
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.

  ELSE.
    ZGTSDS1100-RSLT  = GC_E.
    ZGTSDS1100-PICK  = ICON_LED_RED.
    ZGTSDS1100-MESSAGE = TEXT-M29.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
      CLEAR LV_MESSAGE.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MESSAGE.
      IF ZGTSDS1100-MESSAGE IS INITIAL.
        ZGTSDS1100-MESSAGE = LV_MESSAGE.
      ELSE.
        ZGTSDS1100-MESSAGE = |{ ZGTSDS1100-MESSAGE }/{ LV_MESSAGE }|.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_UNDO_DO_PICKING_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM MAKE_UNDO_DO_PICKING_BDC  USING    PV_VBELN.
  DATA:LV_TEXT(15).

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  DATA(LT_BASE) = GT_LIPS[].
  SORT LT_BASE BY UECHA.
  DELETE LT_BASE WHERE UECHA NE '000000'.

*-VL02N
  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  PV_VBELN.

  LOOP AT LT_BASE INTO DATA(LS_BASE).

    "메인아이템 선택
    PERFORM DYNPRO USING :
                          'X'  'SAPMV50A'    '1000',
                          ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                          'X'  'SAPMV50A'    '0111',
                          ' '  'BDC_OKCODE'  '=WEIT',
                          ' '  'RV50A-POSNR' LS_BASE-POSNR .

    "배치분할 버튼 선택
    PERFORM DYNPRO USING :
                          'X'  'SAPMV50A'    '1000',
                          ' '  'BDC_OKCODE'  '=CHPL_T01'.

    LOOP AT GT_LIPS INTO DATA(LS_LIPS) WHERE UECHA = LS_BASE-POSNR.
      "배치라인 선택
      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'      '1000',
                             ' '  'BDC_OKCODE'    '=POPO_T'.

      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'      '0111',
                             ' '  'BDC_OKCODE'    '=WEIT',
                             ' '  'RV50A-POSNR'    LS_LIPS-POSNR .
      "PICKING 수량 삭제
      PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'        '1000',
                             ' '  'BDC_OKCODE'      '/00',
                             ' '  'LIPSD-PIKMG(01)' LV_TEXT.

    ENDLOOP.

    PERFORM DYNPRO USING :
                             'X'  'SAPMV50A'      '1000',
                             ' '  'BDC_OKCODE'    '=BACK_T'.

  ENDLOOP.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_LIST_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REBUILD_LIST_0100 .
  CLEAR:GT_LIST[].

  PERFORM GET_DATA.
  PERFORM MAKE_LIST.
  PERFORM CELL_ATTRIBUTES_0100_TOP.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE VBELN_VA = ZGTSDS1100-VBELN_VA
                                                      AND VBELN_VL = ZGTSDS1100-VBELN_VL.
    <FS_LIST>-SEL = GC_X.
    EXIT.
  ENDLOOP.

  "DO SPLIT 리스트 구성
  PERFORM GET_SPLIT_DO_LIST USING <FS_LIST>.
  PERFORM CELL_ATTRIBUTES_0100_BOT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_CANC_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_CANC_0100_BOT .
  DATA: LV_CNT TYPE I.
  DATA: LV_VLC(1).
  DATA: LV_MSG(100).

  LOOP AT GT_SPLIT INTO DATA(LS_SPLIT) WHERE SEL EQ GC_X.
    SELECT SINGLE KOSTK,WBSTK,FKSTK
      FROM LIKP
     WHERE VBELN EQ @LS_SPLIT-VBELN_VLSP
      INTO @DATA(LS_LIKP).
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    "PICKING 미완료 건 제외 => PICKING OR PGI OR BILLING 완료건이 대상임
    CHECK LS_LIKP-KOSTK EQ GC_C.

    "원 DO 상태 체크 => 원 DO가 PICKING/GI/BILLING 상태가 아니어야 함
    CLEAR LS_LIKP.
    SELECT SINGLE KOSTK,WBSTK,FKSTK
      FROM LIKP
     WHERE VBELN EQ @LS_SPLIT-VBELN_VL
      INTO @LS_LIKP.
    IF LS_LIKP-KOSTK EQ GC_C OR
       LS_LIKP-WBSTK EQ GC_C OR
       LS_LIKP-FKSTK EQ GC_C.
      LV_VLC = GC_X.
      PERFORM GET_STATUS_TEXT    USING LS_LIKP-KOSTK
                                       LS_LIKP-WBSTK
                                       LS_LIKP-FKSTK
                              CHANGING LV_MSG.
      MESSAGE I116 WITH LS_SPLIT-VBELN_VL LV_MSG DISPLAY LIKE GC_E.
      EXIT.
    ENDIF.

    LV_CNT = LV_CNT + 1.
    EXIT.

    CLEAR:LS_LIKP.
  ENDLOOP.

  IF LV_VLC EQ GC_X.
    GV_ERROR = GC_X.
    EXIT.
  ENDIF.

  IF LV_CNT <= 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M09 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_CANC_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_CANC_0100_BOT .
  CLEAR GV_ERROR.
  LOOP AT GT_SPLIT ASSIGNING FIELD-SYMBOL(<FS_SPLIT>) WHERE SEL EQ GC_X.

    CLEAR: <FS_SPLIT>-RSLT,<FS_SPLIT>-MESSAGE.
    CLEAR: ZGTSDS1100.

    ZGTSDS1100-VBELN_VA   = <FS_SPLIT>-VBELN_VA.
    ZGTSDS1100-VBELN_VL   = <FS_SPLIT>-VBELN_VL.  "원 DO
    ZGTSDS1100-VBELN_VLSP = <FS_SPLIT>-VBELN_VLSP."분할DO
    ZGTSDS1100-SPLIT      = GC_C.
    ZGTSDS1100-ZPROC      = GC_S.
    "대상 데이터 발췌
    PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
    IF ZGTSDS1100-KOSTK NE GC_C. "PICKING

      <FS_SPLIT>-KOSTK = ZGTSDS1100-KOSTK.
      <FS_SPLIT>-WBSTK = ZGTSDS1100-WBSTK.
      <FS_SPLIT>-FKSTK = ZGTSDS1100-FKSTK.

      PERFORM SET_LED_S2 CHANGING <FS_SPLIT>.
      SELECT SINGLE VBELN
        FROM LIKP
       WHERE VBELN EQ @ZGTSDS1100-VBELN_VLSP
        INTO @DATA(LV_DODOC).
      IF SY-SUBRC EQ 0.
        <FS_SPLIT>-RSLT    = GC_E.
        <FS_SPLIT>-MESSAGE = TEXT-M30.
        <FS_SPLIT>-ST_FINSH  = ICON_LED_RED.
      ENDIF.
      CONTINUE.
    ENDIF.

    " LOCK OBJECT
    PERFORM SET_LOCK_OBJECT USING ZGTSDS1100-ZPROC.
    IF ZGTSDS1100-RSLT = GC_E.
      <FS_SPLIT>-MESSAGE = ZGTSDS1100-MESSAGE.
      <FS_SPLIT>-RSLT    = ZGTSDS1100-RSLT.
      GV_ERROR = GC_X.
      PERFORM SET_LED_ERROR_S3 CHANGING <FS_SPLIT>.
      CONTINUE.
    ENDIF.

*-------------------------------------------
*   매출취소
*-------------------------------------------
    PERFORM RUN_BILLING_CANCEL_PROCESS.

*-------------------------------------------
    "처리결과
    <FS_SPLIT>-KOSTK = ZGTSDS1100-KOSTK.
    <FS_SPLIT>-WBSTK = ZGTSDS1100-WBSTK.
    <FS_SPLIT>-FKSTK = ZGTSDS1100-FKSTK.
    PERFORM SET_LED_S2 CHANGING <FS_SPLIT>.

    IF ZGTSDS1100-RSLT EQ GC_E.
      GV_ERROR = GC_X.
      PERFORM SET_LED_ERROR_S2 CHANGING <FS_SPLIT>.
    ENDIF.

    "청구문서 정보
    IF <FS_SPLIT>-FKSTK NE GC_C.
      PERFORM GET_BILL_INFO    USING <FS_SPLIT>-VBELN_VLSP
                            CHANGING <FS_SPLIT>-FKDAT
                                     <FS_SPLIT>-NETWR_VF
                                     <FS_SPLIT>-WAERK_VF.
    ENDIF.


    "메세지
    <FS_SPLIT>-MESSAGE = ZGTSDS1100-MESSAGE.
    <FS_SPLIT>-RSLT    = ZGTSDS1100-RSLT.

    "UNLOCK OBJECT
    PERFORM SET_UNLOCK_OBJECT USING ZGTSDS1100-ZPROC.

  ENDLOOP.

  "성공건 삭제
  DELETE GT_SPLIT WHERE SEL  EQ GC_X
                    AND RSLT EQ GC_S.

  "TOP LIST 재구성
  CLEAR:GT_LIST[].
  PERFORM GET_DATA.
  PERFORM MAKE_LIST.
  PERFORM CELL_ATTRIBUTES_0100_TOP.
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE VBELN_VA = ZGTSDS1100-VBELN_VA
                                                      AND VBELN_VL = ZGTSDS1100-VBELN_VL.
    <FS_LIST>-SEL = GC_X.
    EXIT.
  ENDLOOP.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH TEXT-M12 DISPLAY LIKE GC_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BILLING_JS_CANC_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BILLING_JS_CANC_0100_TOP .
  PERFORM CHECK_CHANGED_DATA USING GO_GRID1.

*-01. CHECK
  CLEAR GV_ERROR.
  IF LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
  ELSE.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  PERFORM CHECK_BILLING_JS_CANC_0100_TOP.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-02. 적송 매출취소 처리
  PERFORM RUN_BILLING_CANC_0100_TOP.

  PERFORM REFRESH_ALV USING: GO_GRID1,
                             GO_GRID2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BILLING_JS_CANC_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BILLING_JS_CANC_0100_TOP .

  DATA(LS_LIST) = VALUE #( GT_LIST[ SEL = GC_X ] OPTIONAL ).
  SELECT SINGLE KOSTK,WBSTK,FKSTK
    FROM LIKP
   WHERE VBELN EQ @LS_LIST-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF LS_LIKP-KOSTK NE GC_C.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M32 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_BILLING_CANC_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_BILLING_CANC_0100_TOP .

  CLEAR: ZGTSDS1100.

  READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WITH KEY SEL = GC_X.
  CHECK SY-SUBRC EQ 0.

  ZGTSDS1100-VBELN_VA   = <FS_LIST>-VBELN_VA.
  ZGTSDS1100-VBELN_VL   = <FS_LIST>-VBELN_VL.  "원 DO
  ZGTSDS1100-ZPROC      = GC_O.

*-01. CHECK
  "대상 데이터 발췌
  PERFORM SET_DO_STATUS CHANGING ZGTSDS1100.
  IF ZGTSDS1100-KOSTK NE GC_C. "PICKING
    <FS_LIST>-KOSTK = ZGTSDS1100-KOSTK.
    <FS_LIST>-WBSTK = ZGTSDS1100-WBSTK.
    <FS_LIST>-FKSTK = ZGTSDS1100-FKSTK.

    PERFORM SET_LED_S3 CHANGING <FS_LIST>.
    EXIT.
  ENDIF.

  " LOCK OBJECT
  PERFORM SET_LOCK_OBJECT USING ZGTSDS1100-ZPROC.
  IF ZGTSDS1100-RSLT = GC_E.
    <FS_LIST>-MESSAGE = ZGTSDS1100-MESSAGE.
    <FS_LIST>-RSLT    = ZGTSDS1100-RSLT.
    GV_ERROR = GC_X.
    PERFORM SET_LED_ERROR_S5 CHANGING <FS_LIST>.
    EXIT.
  ENDIF.

*-------------------------------------------
*   매출취소
*-------------------------------------------
  PERFORM RUN_BILLING_CANCEL_PROCESS.

*-------------------------------------------

  "처리결과 각단계별 상태 LED
  <FS_LIST>-KOSTK = ZGTSDS1100-KOSTK.
  <FS_LIST>-WBSTK = ZGTSDS1100-WBSTK.
  <FS_LIST>-FKSTK = ZGTSDS1100-FKSTK.
  PERFORM SET_LED_S3 CHANGING <FS_LIST>.

  IF ZGTSDS1100-RSLT EQ GC_E.
    GV_ERROR = GC_X.
    PERFORM SET_LED_ERROR_S5 CHANGING <FS_LIST>.
  ENDIF.

  "청구문서 정보
  IF <FS_LIST>-FKSTK NE GC_C.
    PERFORM GET_BILL_INFO    USING <FS_LIST>-VBELN_VL
                          CHANGING <FS_LIST>-FKDAT
                                   <FS_LIST>-NETWR_VF
                                   <FS_LIST>-WAERK_VF.
  ENDIF.


  "메세지
  <FS_LIST>-MESSAGE = ZGTSDS1100-MESSAGE.
  <FS_LIST>-RSLT    = ZGTSDS1100-RSLT.

  "UNLOCK OBJECT
  PERFORM SET_UNLOCK_OBJECT USING ZGTSDS1100-ZPROC.

*  "DO SPLIT 리스트 구성=> 원 DO의 처리 상태에 따라 분할납품문서 선택 체크박스 제어
*  PERFORM GET_SPLIT_DO_LIST USING <FS_LIST>.
*  PERFORM CELL_ATTRIBUTES_0100_BOT.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH TEXT-M12 DISPLAY LIKE GC_S.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_0100 .
  CLEAR: GT_LIST[],GT_SPLIT[].

  PERFORM GET_DATA.
  PERFORM MAKE_LIST.
  PERFORM CELL_ATTRIBUTES_0100_TOP.

  PERFORM REFRESH_ALV USING: GO_GRID1,
                             GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_S3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED_S3  CHANGING PS_LIST LIKE GT_LIST.
  "PICKING :
  IF PS_LIST-KOSTK EQ GC_C.
    PS_LIST-ST_PICK = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PICK = ICON_LED_YELLOW.
  ENDIF.

  "출고 :
  IF PS_LIST-WBSTK EQ GC_C.
    PS_LIST-ST_PGI = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PGI = ICON_LED_YELLOW.
  ENDIF.

  "매출 :
  IF PS_LIST-FKSTK EQ GC_C.
    PS_LIST-ST_BILL = ICON_LED_GREEN.
    PS_LIST-ST_FINSH = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_BILL = ICON_LED_YELLOW.
    PS_LIST-ST_FINSH = ICON_LED_YELLOW.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_ERROR_S5
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED_ERROR_S5  CHANGING PS_LIST LIKE GT_LIST.
  "매출 :
  IF PS_LIST-FKSTK NE GC_C.
    PS_LIST-ST_BILL = ICON_LED_RED.
    EXIT.
  ENDIF.

  "출고 :
  IF PS_LIST-WBSTK NE GC_C.
    PS_LIST-ST_PGI = ICON_LED_RED.
    EXIT.
  ENDIF.

  "PICKING :
  IF PS_LIST-KOSTK NE GC_C.
    PS_LIST-ST_PICK = ICON_LED_RED.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BILL_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SPLIT>_VBELN_VLSP
*&      <-- <FS_SPLIT>_FKDAT
*&      <-- <FS_SPLIT>_NETWR_VL
*&      <-- <FS_SPLIT>_WAERK_VL
*&---------------------------------------------------------------------*
FORM GET_BILL_INFO  USING    PV_VBELN
                    CHANGING PV_FKDAT
                             PV_NETWR_VF
                             PV_WAERK_VF.

  SELECT SINGLE A~VGBEL,
                B~FKDAT,B~NETWR AS NETWR_VF, B~WAERK AS WAERK_VF
    FROM VBRP AS A INNER JOIN VBRK AS B
                   ON A~VBELN = B~VBELN AND
                      B~FKSTO = @SPACE  AND
                      B~SFAKN = @SPACE
   WHERE A~VGBEL EQ @PV_VBELN
    INTO @DATA(LS_VBRK).
  IF SY-SUBRC EQ 0.
    PV_FKDAT     = LS_VBRK-FKDAT.
    PV_NETWR_VF  = LS_VBRK-NETWR_VF.
    PV_WAERK_VF  = LS_VBRK-WAERK_VF.
  ELSE.
    CLEAR:PV_FKDAT,PV_NETWR_VF,PV_WAERK_VF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_SCREEN_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REBUILD_SCREEN_0200 .
  CLEAR:GT_ITEM[].

  SELECT A~VBELN AS VBELN_VL,A~POSNR AS POSNR_VL,A~UECHA,
         A~MATNR,A~CHARG,A~LFIMG,A~VRKME,
         A~VGBEL,A~VGPOS,
         B~WAERK,
         C~NETPR
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBAP AS C
                   ON A~VGBEL = C~VBELN AND
                      A~VGPOS = C~POSNR
   WHERE A~VBELN EQ @ZGTSDS1100-VBELN_VL
     AND A~VGBEL EQ @ZGTSDS1100-VBELN_VA
     AND A~MATNR IN @S_MATNR
     AND A~LGORT IN @S_LGORT
    INTO TABLE @DATA(LT_LIPS).

  CHECK LT_LIPS[] IS NOT INITIAL.
  SORT LT_LIPS BY POSNR_VL.
  DATA(LT_TEMP) = LT_LIPS[].
  DELETE LT_TEMP WHERE UECHA NE '000000'.

*-ITEM 리스트 구성.
  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
    CLEAR GS_ITEM.
    LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE VBELN_VL = LS_TEMP-VBELN_VL
                                         AND UECHA    = LS_TEMP-POSNR_VL.
      CLEAR GS_ITEM.
      GS_ITEM-VBELN_VL = LS_LIPS-VBELN_VL.
      GS_ITEM-UECHA    = LS_LIPS-UECHA.
      GS_ITEM-POSNR_VL = LS_LIPS-POSNR_VL.
      GS_ITEM-MATNR    = LS_LIPS-MATNR.
      GS_ITEM-CHARG    = LS_LIPS-CHARG.
      GS_ITEM-VRKME    = LS_LIPS-VRKME.
      GS_ITEM-LFIMG    = LS_LIPS-LFIMG.
      GS_ITEM-NETPR    = LS_LIPS-NETPR.
      GS_ITEM-VGBEL    = LS_LIPS-VGBEL.
      GS_ITEM-VGPOS    = LS_LIPS-VGPOS.
      GS_ITEM-WAERK    = LS_LIPS-WAERK.

      "조장
      IF GS_ITEM-VGBEL IS NOT INITIAL AND
         GS_ITEM-VGPOS IS NOT INITIAL.
        PERFORM SET_CHARACTERISTIC_VALUES    USING GS_ITEM-VGBEL GS_ITEM-VGPOS
                                                   'SAP_LENGTH_VKRME'
                                          CHANGING GS_ITEM-LENGTH_JS.
      ENDIF.

      "조장수/수량/금액
      PERFORM SET_QTY_AMT_VALUES      USING GC_X
                                   CHANGING GS_ITEM.

*      PERFORM SET_ATTRIBUTES_LINE_ITEM CHANGING GS_ITEM.
      APPEND GS_ITEM TO GT_ITEM.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      CLEAR GS_ITEM.
      GS_ITEM-VBELN_VL = LS_LIPS-VBELN_VL.
      GS_ITEM-UECHA    = LS_LIPS-UECHA.
      GS_ITEM-POSNR_VL = LS_LIPS-POSNR_VL.
      GS_ITEM-MATNR    = LS_LIPS-MATNR.
      GS_ITEM-CHARG    = LS_LIPS-CHARG.
      GS_ITEM-VRKME    = LS_LIPS-VRKME.
      GS_ITEM-LFIMG    = LS_LIPS-LFIMG.
      GS_ITEM-NETPR    = LS_LIPS-NETPR.
      GS_ITEM-VGBEL    = LS_LIPS-VGBEL.
      GS_ITEM-VGPOS    = LS_LIPS-VGPOS.
      GS_ITEM-WAERK    = LS_LIPS-WAERK.

      "조장
      IF GS_ITEM-VGBEL IS NOT INITIAL AND
         GS_ITEM-VGPOS IS NOT INITIAL.
        PERFORM SET_CHARACTERISTIC_VALUES    USING GS_ITEM-VGBEL GS_ITEM-VGPOS
                                                   'SAP_LENGTH_VKRME'
                                          CHANGING GS_ITEM-LENGTH_JS.
      ENDIF.

      "조장수/수량/금액
      PERFORM SET_QTY_AMT_VALUES    USING GC_X
                                 CHANGING GS_ITEM.

*      PERFORM SET_ATTRIBUTES_LINE_ITEM CHANGING GS_ITEM.
      APPEND GS_ITEM TO GT_ITEM.
    ENDIF.
  ENDLOOP.

*-최초수량 = 0 인건 제외
  DELETE GT_ITEM WHERE LFIMG <= 0.

*-실매출 금액 : 매출금액 SUM - 유보금액
  PERFORM SET_REAL_NETWR USING ZGTSDS1100-VBELN_VL.
ENDFORM.
