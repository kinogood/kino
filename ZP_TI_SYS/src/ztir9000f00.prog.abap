************************************************************************
* Title         :  ZTIR9000F00                                         *
*                                                                      *
* Description   : LIV Simulation Funciton용 Sub-routine Include        *
*                                                                      *
* Creation Date : 2004/02/22                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  DOCUMENT_SIMULATION
*&---------------------------------------------------------------------*
FORM DOCUMENT_SIMULATION.

  REFRESH: XACCIT, XACCCR, XCURR.
  CLEAR: RM08R-SUMME_SOLL, RM08R-SUMME_HABN, RM08R-SALDO.

  CLEAR KURSTYP.
  XACCIT_AKTIND = 1.
  XACCIT_PAGIND = 1.

*------- Daten?ernahme aus dem MRM_INVOICE_POST ---------------------*
  CALL FUNCTION 'MRM_XACCITCR_EXPORT'
    TABLES
      T_ACCIT = XACCIT
      T_ACCCR = XACCCR
      T_CURR  = XCURR.
  READ TABLE XACCIT INDEX 1.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  PERFORM CURTP_TEXT_ERMITTELN.
*------- Sortieren (damit Zeilen des Umbwertungsbeleg am Ende sind) --*
  SORT XACCIT BY BELNR+8 POSNR.

*------- Saldo in Hausw?rung bestimmen ------------------------------*
  PERFORM SALDO_BESTIMMEN USING '00'.

*------- Anzahl der W?rungen bestimmen ------------------------------*
  DESCRIBE TABLE XCURR LINES KURSANZ.

  CLEAR: OK-CODE.
  CALL SCREEN '6000' STARTING AT 1 1.

ENDFORM.                    " DOCUMENT_SIMULATION

*&---------------------------------------------------------------------*
*&      Form  curtp_text_ermitteln
*&---------------------------------------------------------------------*
FORM CURTP_TEXT_ERMITTELN.

  DATA: CURTP_DOMAIN LIKE DD07V-DOMVALUE_L.

  LOOP AT XCURR.
    MOVE XCURR-CURTP TO  CURTP_DOMAIN.
    CALL FUNCTION 'GET_DOMAENENTEXT'
      EXPORTING
        DNAME           = 'CURRTYP'
        DVALUE          = CURTP_DOMAIN
      IMPORTING
        DTEXT           = XCURR-CURTP_TEXT
      EXCEPTIONS
        NO_DOMAIN_FOUND = 1.
    IF SY-SUBRC EQ 0.
      MODIFY XCURR.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " curtp_text_ermitteln

*&---------------------------------------------------------------------*
*&      Form  SALDO_BESTIMMEN
*&---------------------------------------------------------------------*
FORM SALDO_BESTIMMEN USING  SB_KURSTYP.

  CLEAR: RM08R-SUMME_SOLL, RM08R-SUMME_HABN, RM08R-SALDO.

  LOOP AT XACCIT.
    READ TABLE XACCCR WITH KEY POSNR = XACCIT-POSNR
                               CURTP = SB_KURSTYP.
*------- Aufbereitung der W?rung ------------------------------------*
    RM08R-AZWAE = XACCCR-WAERS.
*------ Summe Soll ---------------------------------------------------*
    IF XACCCR-WRBTR GE 0.
      RM08R-SUMME_SOLL = RM08R-SUMME_SOLL + XACCCR-WRBTR.
    ELSE.
*------ Summe Haben --------------------------------------------------*
      RM08R-SUMME_HABN = RM08R-SUMME_HABN + XACCCR-WRBTR.
    ENDIF.
  ENDLOOP.
*------ Saldo --------------------------------------------------------*
  RM08R-SUMME_HABN = 0 - RM08R-SUMME_HABN.
  RM08R-SALDO = RM08R-SUMME_SOLL - RM08R-SUMME_HABN.

ENDFORM.                    " SALDO_BESTIMMEN


*&---------------------------------------------------------------------*
*&      Form  SET_ACCIT_FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ACCIT_FILL .

  DATA: TEXT_SAKNR(20).
  STATICS: AF_POSNR LIKE ACCIT-POSNR,
           AF_BELNR LIKE ACCIT-BELNR.
  DATA: S_SKAT LIKE SKAT.              " Kontobezeichung Simulieren


  MOVE-CORRESPONDING XACCIT TO ACCIT.

  IF ACCIT-KTOSL = 'BUV'.
    CLEAR ACCIT-KOART.
  ENDIF.

*------ MAKTX f?len -------------------------------------------------*
  CASE ACCIT-KOART.
    WHEN 'K'.
      IF G_DOCUMENT EQ C_CS.
        IF NOT *LFA1-LIFNR IS INITIAL.
          MOVE *LFA1-NAME1 TO ABTAB-MAKTX.
        ELSE.
          MOVE LFA1-NAME1 TO ABTAB-MAKTX.
        ENDIF.
      ELSE.
        IF ZTITIG00-SJPAP EQ C_CHARV.
          IF NOT *LFA1-LIFNR IS INITIAL.
            MOVE *LFA1-NAME1 TO ABTAB-MAKTX.
          ELSE.
            MOVE LFA1-NAME1 TO ABTAB-MAKTX.
          ENDIF.
        ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
          MOVE ZTSTIG3-NAMET TO ABTAB-MAKTX.
        ENDIF.
      ENDIF.
    WHEN 'M'.
*      LOOP AT ydrseg WHERE matnr = xaccit-matnr
*                     and   rblgp = xaccit-zeile.
*        MOVE ydrseg-txz01 TO abtab-maktx.
*        exit.
*      ENDLOOP.
      IF XACCIT-EBELN IS INITIAL.
        CLEAR: ABTAB-MAKTX.
      ELSE.
        SELECT SINGLE TXZ01 INTO ABTAB-MAKTX
               FROM   EKPO
               WHERE  EBELN EQ ACCIT-EBELN
               AND    EBELP EQ ACCIT-EBELP.
      ENDIF.

    WHEN OTHERS.
      CALL FUNCTION 'READ_HAUPTBUCH_AND_TEXT'
        EXPORTING
          SACHKONTO            = ACCIT-HKONT
          BUCHUNGSKREIS        = ACCIT-BUKRS
          SPRACHE              = SY-LANGU
        IMPORTING
          TEXT_WA              = S_SKAT
        EXCEPTIONS
          KONTENPLAN_NOT_FOUND = 4
          SACHKONTO_NOT_FOUND  = 8
          TEXT_NOT_FOUND       = 12.
      IF SY-SUBRC = 0.
        MOVE S_SKAT-TXT50 TO ABTAB-MAKTX.
      ELSE.
        CLEAR: ABTAB-MAKTX.
      ENDIF.

  ENDCASE.

ENDFORM.                    " SET_ACCIT_FILL
*&---------------------------------------------------------------------*
*&      Form  SET_ACCCR_FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ACCCR_FILL .

  IF KURSTYP IS INITIAL.
    KURSTYP = '00'.
  ENDIF.

  READ TABLE XACCCR WITH KEY POSNR = XACCIT-POSNR
                             CURTP = KURSTYP.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  CHECK ACCIT-POSNR NE 0.
  MOVE-CORRESPONDING XACCCR TO ACCCR.
  MOVE XACCCR-WRBTR TO ABTAB-WRBTR.

ENDFORM.                    " SET_ACCCR_FILL
*&---------------------------------------------------------------------*
*&      Form  CALL_INVOICE_CREATE_FUNC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_INVOICE_CREATE_FUNC  USING    P_SIMULATION
                                        P_EMPFK    LIKE ZTITCSK-EMPFK
                                        P_BUPLA    LIKE ZTITCSK-BUPLA
                                        P_SUBRC.

  DATA: L_SIMULATION LIKE        BOOLE-BOOLE.
  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.
  DATA: LT_EVENTS    TYPE        MMPUR_EVENTS,
        L_HANDLE     TYPE REF TO CL_HANDLE_MM,
        L_MSG        TYPE REF TO CL_MESSAGE_MM,
        L_SUBRC      LIKE        SY-SUBRC.

  FIELD-SYMBOLS: <EVENT> LIKE LINE OF LT_EVENTS.

  CLEAR: P_SUBRC.
*>------------------------------------------------------
*> Begin transaction.
*>------------------------------------------------------
*  IF p_simulation NE c_true.
*    SET UPDATE TASK LOCAL.
*  ENDIF.
*
  L_SIMULATION = P_SIMULATION.
*  refresh nfmetallitms.
*>> FUNCTION CALL
*  FUNCTION_NAME = 'Z_TI_BAPI_INVOICE_CREATE'.
*  CALL FUNCTION FUNCTION_NAME
*  BREAK-POINT.

  HEADERDATA-PAYEE_PAYER = P_EMPFK.

*  IF sy-uname EQ 'X'.
*    BREAK-POINT.
*  ENDIF.

  IF P_SIMULATION EQ 'X'.
*  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
    CALL FUNCTION 'Z_TI_BAPI_INVOICE_CREATE'
            EXPORTING
                 HEADERDATA             = HEADERDATA
                 ADDRESSDATA            = ADDRESSDATA
*                 empfb                  = p_empfk
*                 bupla                  = p_bupla
                 SIMULATION             = L_SIMULATION
            IMPORTING
                 INVOICEDOCNUMBER       = INVOICEDOCNUMBER
                 FISCALYEAR             = FISCALYEAR
            TABLES
                 ITEMDATA               = ITEMDATA
                 ACCOUNTINGDATA         = ACCOUNTINGDATA
                 GLACCOUNTDATA          = GLACCOUNTDATA
                 TAXDATA                = TAXDATA
*               materialdata           = materialdata
                 NFMETALLITMS           = NFMETALLITMS
                 WITHTAXDATA            = WITHTAXDATA
                 VENDORITEMSPLITDATA    = VENDORITEMSPLITDATA
                 RETURN                 = RETURN.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*     IMPORTING
*       RETURN        =

  ELSE.
    CALL FUNCTION '/NFM/MRM_DATA_REFRESH'.

    CALL FUNCTION 'MRM_DBTAB_REFRESH'.

    CALL FUNCTION 'MRM_PUFFER_REFRESH'.

    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
          EXPORTING
                 HEADERDATA             = HEADERDATA
                 ADDRESSDATA            = ADDRESSDATA
          IMPORTING
                 INVOICEDOCNUMBER       = INVOICEDOCNUMBER
                 FISCALYEAR             = FISCALYEAR
          TABLES
                 ITEMDATA               = ITEMDATA
                 ACCOUNTINGDATA         = ACCOUNTINGDATA
                 GLACCOUNTDATA          = GLACCOUNTDATA
                 TAXDATA                = TAXDATA
*               materialdata           = materialdata
                 NFMETALLITMS           = NFMETALLITMS
                 WITHTAXDATA            = WITHTAXDATA
                 VENDORITEMSPLITDATA    = VENDORITEMSPLITDATA
                 RETURN                 = RETURN.
  ENDIF.
*  BREAK-POINT.

  IF NOT INVOICEDOCNUMBER IS INITIAL.        "> ERROR
    P_SUBRC = 0.
  ELSE.
    READ TABLE RETURN WITH KEY TYPE = 'E'.
    IF SY-SUBRC EQ 0.
      L_SUBRC = 4.
    ENDIF.

* Message preparations
    PERFORM  SET_MESSAGE_PREPARATIONS.

    LOOP AT RETURN.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID RETURN-ID TYPE RETURN-TYPE
                  NUMBER RETURN-NUMBER
                  WITH   RETURN-MESSAGE_V1  RETURN-MESSAGE_V2
                         RETURN-MESSAGE_V3  RETURN-MESSAGE_V4.
      ELSE.
        MESSAGE ID RETURN-ID TYPE C_SUCCESS NUMBER RETURN-NUMBER
                  WITH   RETURN-MESSAGE_V1  RETURN-MESSAGE_V2
                         RETURN-MESSAGE_V3  RETURN-MESSAGE_V4.
        PERFORM SET_RETURN_MESSAGE_FILL USING RETURN-TYPE.
      ENDIF.
    ENDLOOP.

    IF L_SUBRC  NE C_ZERO AND
       SY-SUBRC NE C_ZERO.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE E851.
      ELSE.
        MESSAGE S851.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
    ENDIF.

    IF P_SIMULATION NE C_TRUE AND
       L_SUBRC      NE C_ZERO.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ROLLBACK WORK.
    ENDIF.

*> Error Message
*> 오류정보가 존재시 메시지 상자 POPUP.
    G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

    IF G_LINE GT 0.
      IF SY-CALLD EQ C_TRUE.
*> List of Events
        CALL METHOD G_MESSAGE_HANDLER->GETLIST
          EXPORTING
            IM_OBJECT = L_HANDLE
          IMPORTING
            EX_EVNT   = LT_EVENTS.

        CLEAR: G_CNT.
        LOOP AT LT_EVENTS ASSIGNING <EVENT>.
          MMPUR_DYNAMIC_CAST L_MSG <EVENT>-EVENT.
          CHECK NOT L_MSG    IS INITIAL.
          CHECK L_MSG->MSGTY EQ C_ERROR.
          MESSAGE ID     L_MSG->MSGID
                  TYPE   L_MSG->MSGTY
                  NUMBER L_MSG->MSGNO
                  WITH   L_MSG->MSGV1
                         L_MSG->MSGV2
                         L_MSG->MSGV3
                         L_MSG->MSGV4.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC NE 0.
          LOOP AT LT_EVENTS ASSIGNING <EVENT>.
            MMPUR_DYNAMIC_CAST L_MSG <EVENT>-EVENT.
            CHECK NOT L_MSG    IS INITIAL.
            MESSAGE ID     L_MSG->MSGID
                    TYPE   L_MSG->MSGTY
                    NUMBER L_MSG->MSGNO
                    WITH   L_MSG->MSGV1
                           L_MSG->MSGV2
                           L_MSG->MSGV3
                           L_MSG->MSGV4.
            EXIT.
          ENDLOOP.
        ENDIF.
      ELSE.
        CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
          IM_AMODAL = C_FALSE ).
      ENDIF.
    ENDIF.
    P_SUBRC = L_SUBRC.
  ENDIF.

ENDFORM.                    " CALL_INVOICE_CREATE_FUNC
*&---------------------------------------------------------------------*
*&      Form  INVOICE_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INVOICE_DOCUMENT_CREATE  USING P_EMPFK    LIKE ZTITCSK-EMPFK
                                    P_BUPLA    LIKE ZTITCSK-BUPLA
                                    P_PTDCL    LIKE ZTITCSK-PTDCL.

 DATA: LV_NPOST_CHK.

*> 공용 대화상자(메시지 통일).
  IF OK_CODE EQ 'ZTIPOST'.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        XMODE  = C_CHARP
      IMPORTING
        ANSWER = G_ANSWER.

    IF G_ANSWER NE C_CHARY.
      EXIT.
    ENDIF.
  ENDIF.

*> Fields check.
  PERFORM  CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
  IF G_LINE EQ 0.
    MESSAGE S911.
  ELSE.
    EXIT.
  ENDIF.

  IF OK_CODE EQ 'ZTISIMUL'.
    G_SIMULATION = C_TRUE.
  ELSE.
    G_SIMULATION = SPACE.
  ENDIF.

*> Set posting용 데이타 Move
  PERFORM  SET_INVOICE_DATA.
  CHECK G_ANSWER EQ C_CHARY.

*> 비용처리일 경우.
  IF G_DOCUMENT EQ C_CS.
    PERFORM  CHECK_NO_DRAFT_ITEM IN PROGRAM ZTIR9000 USING G_ANSWER.
    CHECK G_ANSWER EQ 'J'.
  ENDIF.

*> 전기용 BAPI 함수 Call
  CASE P_PTDCL.
    WHEN C_CHARM.   ">물류송장검증.
      PERFORM  CALL_INVOICE_CREATE_FUNC USING   G_SIMULATION
                                                P_EMPFK
                                                P_BUPLA
                                                G_SUBRC.
    WHEN C_CHARF.    ">회계기표(BAPIs).
      PERFORM  CALL_ACCOUNT_CREATE_FUNC USING   G_SIMULATION
                                                G_SUBRC.
*> 회계전표 부가세 기표일 경우.
    WHEN C_CHARV.
      PERFORM  CALL_VAT_CREATE_FUNC     USING   G_SIMULATION
                                                G_SUBRC.
  ENDCASE.

  IF G_SUBRC EQ 0.    ">Success
    IF G_SIMULATION = C_TRUE.
      CASE P_PTDCL.
        WHEN C_CHARM.   ">물류송장검증.
          PERFORM DOCUMENT_SIMULATION.
        WHEN C_CHARF.   ">회계검증.
          PERFORM DOCUMENT_SIMULATION_FI IN PROGRAM (G_REPID)
                                         USING OK-CODE.
        WHEN C_CHARV.   ">회계검증.
          PERFORM DOCUMENT_SIMULATION_FI IN PROGRAM (G_REPID)
                                         USING OK-CODE.
        WHEN OTHERS.
          MESSAGE S869.
      ENDCASE.


      IF ok-code EQ fcobu.
        CLEAR: G_SIMULATION.


*- [CHM2110-00555] 유형별 전표처리가능 여부체크  -[s]
      PERFORM CHECK_POST_POSSIBLE IN PROGRAM (G_REPID) IF FOUND
                                   USING LV_NPOST_CHK.
      CHECK LV_NPOST_CHK IS INITIAL.
*- [CHM2110-00555] 유형별 전표처리가능 여부체크 -[e]


        CASE P_PTDCL.
          WHEN C_CHARM.   ">물류송장검증.
            PERFORM  CALL_INVOICE_CREATE_FUNC USING   G_SIMULATION
                                                      P_EMPFK
                                                      P_BUPLA
                                                      G_SUBRC.

          WHEN C_CHARF.    ">회계기표.
            PERFORM  CALL_ACCOUNT_CREATE_FUNC USING   G_SIMULATION
                                                      G_SUBRC.
*> 회계전표 부가세 기표일 경우.
          WHEN C_CHARV.
            PERFORM  CALL_VAT_CREATE_FUNC     USING   G_SIMULATION
                                                      G_SUBRC.
        ENDCASE.

        IF G_SUBRC EQ 0.    ">Success
          PERFORM P8000_SAVE_MASTER_DATA USING 'H'.
          CASE P_PTDCL.
            WHEN C_CHARM.   ">물류송장검증.
              MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
            WHEN OTHERS.
              MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
          ENDCASE.


*- [CHM2110-00555] 세금계산서 매핑 해당DB 업데이트
          PERFORM SET_ZDTV3T_AP_EXT_USE_DOC
                                     IN PROGRAM (G_REPID) IF FOUND .
          PERFORM P9000_CAME_TO_AN_END.
          PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
        ENDIF.
      ENDIF.
    ELSE.
*>Data Save.
      PERFORM P8000_SAVE_MASTER_DATA USING 'H'.
      CASE P_PTDCL.
        WHEN C_CHARM.   ">물류송장검증.
          MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
        WHEN OTHERS.
          MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
      ENDCASE.

*- [CHM2110-00555] 세금계산서 매핑 해당DB 업데이트
      PERFORM SET_ZDTV3T_AP_EXT_USE_DOC IN PROGRAM (G_REPID) IF FOUND.
      PERFORM P9000_CAME_TO_AN_END.
      PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
    ENDIF.
  ENDIF.

ENDFORM.                    " INVOICE_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  invoice_document_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INVOICE_DOCUMENT_CANCEL USING P_PTDCL LIKE ZTITCSK-PTDCL.

  CLEAR: OK-CODE.
*  CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
*    EXPORTING
*      xmode  = c_charr
*    IMPORTING
*      answer = g_answer.
*
*  IF g_answer EQ c_charn.
*    EXIT.
*  ENDIF.

  PERFORM  SET_CANCEL_DOCUMENT_NUMBER USING ZTISSCRCOM.

  CALL SCREEN  6010 STARTING AT 01    01
                    ENDING   AT 43    12.

  CHECK OK-CODE EQ 'ZTIOKAY'.

  MOVE: ZTISSCRCOM-STGRD     TO   REASONREVERSAL,
        ZTISSCRCOM-CBUDAT    TO   POSTINGDATE.

  REFRESH RETURN.
*>Begin of transactions
  SET UPDATE TASK LOCAL.

  IF P_PTDCL EQ C_CHARM.  ">물류송장검증.
    PERFORM  CALL_INVOICE_CANCEL_FUNC USING G_SUBRC
                                            P_PTDCL.
  ELSE.
    PERFORM  CALL_ACCOUNT_CANCEL_FUNC USING ZTISSCRCOM-BUKRS
                                            ZTISSCRCOM-GJAHR
                                            ZTISSCRCOM-BELNR
                                            ZTISSCRCOM-BLART
                                            G_SUBRC
                                            P_PTDCL.
  ENDIF.

  IF G_SUBRC EQ C_ZERO.
    PERFORM P8000_SAVE_MASTER_DATA USING 'R'.

*    MESSAGE s282(m8) WITH invoicedocnumber_reversal.
    MESSAGE S873 WITH INVOICEDOCNUMBER_REVERSAL.
*    CASE p_ptdcl.
*      WHEN c_charm.   ">물류송장검증.
*        MESSAGE s260(m8) WITH invoicedocnumber.
*      WHEN OTHERS.
*        MESSAGE s260(m8) WITH invoicedocnumber.
*    ENDCASE.

*- [CHM2110-00555] 세금계산서 매핑 DB업데이트 취소
    PERFORM UNSET_ZDTV3T_AP_EXT_USE_DOC IN PROGRAM (G_REPID) IF FOUND .
    PERFORM P9000_CAME_TO_AN_END.
    PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
  ENDIF.

ENDFORM.                    " invoice_document_cancel
*&---------------------------------------------------------------------*
*&      Form  call_account_create_func
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_ACCOUNT_CREATE_FUNC  USING    P_SIMULATION
                                        P_SUBRC.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  REFRESH: IT_RETURN.
  CLEAR: P_SUBRC.

  IF P_SIMULATION EQ C_TRUE.
*    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    CALL FUNCTION 'Z_TS_BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        DOCUMENTHEADER    = GS_DOCUMENTHEADER
        CUSTOMERCPD       = GS_CUSTOMERCPD
        CONTRACTHEADER    = GS_FICA_HD
        IM_MODIFIED       = SPACE
        IM_ANBWA          = '100'
      TABLES
        ACCOUNTGL         = IT_ACCOUNTGL
        ACCOUNTRECEIVABLE = IT_ACCOUNTRECEIVABLE
        ACCOUNTPAYABLE    = IT_ACCOUNTPAYABLE
        ACCOUNTTAX        = IT_ACCOUNTTAX
        CURRENCYAMOUNT    = IT_CURRENCYAMOUNT
        CRITERIA          = IT_CRITERIA
        VALUEFIELD        = IT_VALUEFIELD
        EXTENSION1        = IT_EXT
        RETURN            = IT_RETURN
        PAYMENTCARD       = IT_PAYMENTCARD
        CONTRACTITEM      = IT_FICA_IT
        EXTENSION2        = IT_EXT2
        REALESTATE        = IT_RE.
  ELSE.
*    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*    CALL FUNCTION 'Z_TS_BAPI_ACC_DOCUMENT_POST'
    CALL FUNCTION 'Z_TS_BAPI_ACC_DOCUMENT_POST_N' "231215, 김예슬
      EXPORTING
        DOCUMENTHEADER    = GS_DOCUMENTHEADER
        CUSTOMERCPD       = GS_CUSTOMERCPD
        CONTRACTHEADER    = GS_FICA_HD
        IM_MODIFIED       = SPACE
        IM_ANBWA          = '100'
      IMPORTING
        OBJ_TYPE          = G_TYPE
        OBJ_KEY           = G_KEY
        OBJ_SYS           = G_SYS
      TABLES
        ACCOUNTGL         = IT_ACCOUNTGL
        ACCOUNTRECEIVABLE = IT_ACCOUNTRECEIVABLE
        ACCOUNTPAYABLE    = IT_ACCOUNTPAYABLE
        ACCOUNTTAX        = IT_ACCOUNTTAX
        CURRENCYAMOUNT    = IT_CURRENCYAMOUNT
        CRITERIA          = IT_CRITERIA
        VALUEFIELD        = IT_VALUEFIELD
        EXTENSION1        = IT_EXT
        RETURN            = IT_RETURN
        PAYMENTCARD       = IT_PAYMENTCARD
        CONTRACTITEM      = IT_FICA_IT
        EXTENSION2        = IT_EXT2
        REALESTATE        = IT_RE.
  ENDIF.

*  READ TABLE it_return WITH KEY type = 'E'.
*                                type = 'A'.
*  IF sy-subrc EQ 0.
*    p_subrc = 4.
*  ENDIF.
*
* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  LOOP AT IT_RETURN WHERE TYPE EQ 'E'
                      OR  TYPE EQ 'A'.
    IF NOT ( IT_RETURN-TYPE   EQ C_ERROR AND
             IT_RETURN-ID     EQ 'RW'    AND
             IT_RETURN-NUMBER EQ '609' ).
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID     IT_RETURN-ID TYPE IT_RETURN-TYPE
                NUMBER IT_RETURN-NUMBER
                WITH   IT_RETURN-MESSAGE_V1  IT_RETURN-MESSAGE_V2
                       IT_RETURN-MESSAGE_V3  IT_RETURN-MESSAGE_V4.
        PERFORM SET_RETURN_MESSAGE_FILL USING IT_RETURN-TYPE.
      ELSE.
        MESSAGE ID     IT_RETURN-ID TYPE C_SUCCESS
                NUMBER IT_RETURN-NUMBER
                WITH   IT_RETURN-MESSAGE_V1  IT_RETURN-MESSAGE_V2
                       IT_RETURN-MESSAGE_V3  IT_RETURN-MESSAGE_V4.
        PERFORM SET_RETURN_MESSAGE_FILL USING IT_RETURN-TYPE.
      ENDIF.
    ENDIF.
    P_SUBRC = 4.
  ENDLOOP.

  IF P_SUBRC  NE C_ZERO AND
     SY-SUBRC NE C_ZERO.
    MESSAGE S851.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

  IF P_SIMULATION EQ C_TRUE AND
     P_SUBRC      NE C_ZERO.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ROLLBACK WORK.
  ELSE.
    IF P_SIMULATION NE C_TRUE.
      FISCALYEAR           =  G_KEY+14(4).
      INVOICEDOCNUMBER     =  G_KEY(10).
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ELSE.
    MESSAGE S911.
  ENDIF.

ENDFORM.                    " call_account_create_func
*&---------------------------------------------------------------------*
*&      Form  call_invoice_cancel_func
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_INVOICE_CANCEL_FUNC USING P_SUBRC
                                    P_PTDCL.

  DATA: L_AWTYP        LIKE ACCDN-AWTYP,
        L_AWREF        LIKE ACCDN-AWREF,
        L_AWORG        LIKE ACCDN-AWORG,
        L_AWSYS        LIKE ACCDN-AWSYS,
        L_BUKRS        LIKE ACCDN-BUKRS,
        LT_ACCDN       LIKE ACCDN OCCURS 0 WITH HEADER LINE,
        LT_ACCDN_CANC  LIKE ACCDN OCCURS 0 WITH HEADER LINE,
        L_SUBRC        LIKE SY-SUBRC,
        L_INV_DOC_NO   LIKE BAPI_INCINV_FLD-INV_DOC_NO,
        L_FISC_YEAR    LIKE BAPI_INCINV_FLD-FISC_YEAR.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  CLEAR : INVOICEDOCNUMBER_REVERSAL,
          FISCALYEAR_REVERSAL,
          RETURN,
          P_SUBRC.

  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
    EXPORTING
      INVOICEDOCNUMBER          = ZTISSCRCOM-BELNR
      FISCALYEAR                = ZTISSCRCOM-GJAHR
      REASONREVERSAL            = REASONREVERSAL
      POSTINGDATE               = POSTINGDATE
    IMPORTING
      INVOICEDOCNUMBER_REVERSAL = INVOICEDOCNUMBER_REVERSAL
      FISCALYEAR_REVERSAL       = FISCALYEAR_REVERSAL
    TABLES
      RETURN                    = RETURN.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  IF INVOICEDOCNUMBER_REVERSAL IS INITIAL.
    READ TABLE RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      IF RETURN-ID     EQ 'M8' AND
         RETURN-NUMBER EQ '184'.
        MESSAGE I951 WITH ZTISSCRCOM-GJAHR ZTISSCRCOM-BELNR '송장'.
        G_LINE  = 0.
        P_SUBRC = 0.
        EXIT.
      ENDIF.
    ENDIF.

    P_SUBRC = C_CHAR4.
    LOOP AT RETURN.
      MESSAGE ID RETURN-ID TYPE C_SUCCESS NUMBER RETURN-NUMBER
                WITH   RETURN-MESSAGE_V1  RETURN-MESSAGE_V2
                       RETURN-MESSAGE_V3  RETURN-MESSAGE_V4.
      PERFORM SET_RETURN_MESSAGE_FILL USING RETURN-TYPE.
    ENDLOOP.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    ROLLBACK WORK.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
    P_SUBRC = C_CHAR4.
    EXIT.
  ENDIF.
  COMMIT WORK.

*> 전기용 회계전표.
  PERFORM  GET_FI_DOCUMENT_NUMBER  TABLES LT_ACCDN
                                   USING  'RMRP '
                                          ZTISSCRCOM-BELNR
                                          ZTISSCRCOM-GJAHR
                                          ZTISSCRCOM-BUKRS
                                          L_SUBRC.

*> 전기용 회계전표.
  DO.
    PERFORM  GET_FI_DOCUMENT_NUMBER  TABLES LT_ACCDN_CANC
                                     USING  'RMRP '
                                            INVOICEDOCNUMBER_REVERSAL
                                            FISCALYEAR_REVERSAL
                                            ZTISSCRCOM-BUKRS
                                            L_SUBRC.
    IF L_SUBRC EQ 0.
      EXIT.
    ENDIF.
  ENDDO.
*  l_awtyp = 'RMRP '.
*  l_awref = ztisscrcom-belnr.
*  l_aworg = ztisscrcom-gjahr.
**  l_awsys =
*  l_bukrs = ztisscrcom-bukrs.
*
*  REFRESH: lt_accdn.  CLEAR: lt_accdn.
**>Specify Name of Current Logged-on System (client in R/3 System)
*  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
*    IMPORTING
*      own_logical_system             = l_awsys
*    EXCEPTIONS
*      own_logical_system_not_defined = 1
*      OTHERS                         = 2.
*  IF sy-subrc NE 0.
*    p_subrc = c_char4.
*    EXIT.
*  ENDIF.
*
**>FI: General Document Access Routines
*  CALL FUNCTION 'FI_DOCUMENT_FIND_FOR_INTERFACE'
*   EXPORTING
*     i_awtyp            = l_awtyp
*     i_awref            = l_awref
*     i_aworg            = l_aworg
*     i_awsys            = l_awsys
*     i_bukrs            = l_bukrs
*    TABLES
*     e_accdn            = lt_accdn
**     I_ACCDN            =
*   EXCEPTIONS
*     no_doc_found       = 1
*     OTHERS             = 2.
*  IF sy-subrc <> 0.
*    p_subrc = c_char4.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    MESSAGE ID sy-msgid TYPE c_success NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*    PERFORM set_return_message_fill USING c_error.
*
**> 오류정보가 존재시 메시지 상자 POPUP.
*    g_line = g_message_handler->get_severity_bo(
*                            im_business_obj          = l_if_null
*                            im_include_child_objects = c_true ).
*
*    IF g_line GT 0.
*      CALL METHOD g_message_handler->show( im_popup = c_true
*        im_amodal = c_false ).
*      p_subrc = c_char4.
*    ENDIF.
*    EXIT.
*  ENDIF.
*
*
  LOOP AT LT_ACCDN.
    SELECT SINGLE *
      FROM BKPF
     WHERE BUKRS EQ LT_ACCDN-BUKRS
       AND BELNR EQ LT_ACCDN-BELNR
       AND GJAHR EQ LT_ACCDN-GJAHR.
    IF SY-SUBRC EQ 0.
      IF BKPF-BLART NE 'ML'.
        P_SUBRC = C_CHAR0.
        EXIT.
      ENDIF.
    ELSE.
      P_SUBRC = C_CHAR4.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF P_SUBRC  NE C_CHAR0.
    EXIT.
  ENDIF.

  LOOP AT LT_ACCDN_CANC.
    SELECT SINGLE *
      FROM BKPF
     WHERE BUKRS EQ LT_ACCDN_CANC-BUKRS
       AND BELNR EQ LT_ACCDN_CANC-BELNR
       AND GJAHR EQ LT_ACCDN_CANC-GJAHR.
    IF SY-SUBRC EQ 0.
      IF BKPF-BLART NE 'ML'.
        P_SUBRC = C_CHAR0.
        EXIT.
      ENDIF.
    ELSE.
      P_SUBRC = C_CHAR4.
      EXIT.
    ENDIF.
  ENDLOOP.

*  break-point.

*  READ TABLE lt_accdn INDEX 1.
*  IF sy-subrc NE 0.
*  ELSE.
*
*  ENDIF.
*
*  READ TABLE lt_accdn_canc INDEX 1.
*  IF sy-subrc NE 0.
*    p_subrc = c_char4.
*    EXIT.
*  ELSE.
*
*  ENDIF.

*
*> 반제 BDC ..
  PERFORM  CALL_ACCOUNT_PAY_BACK_FUNC USING LT_ACCDN-BUKRS
                                            LT_ACCDN-GJAHR
                                            LT_ACCDN-BELNR
                                            LT_ACCDN_CANC-BUKRS
                                            LT_ACCDN_CANC-GJAHR
                                            LT_ACCDN_CANC-BELNR
                                            ZTISSCRCOM-LIFNR
                                            ZTISSCRCOM-WAERS
                                            ZTISSCRCOM-WRBTR
                                            P_SUBRC.

ENDFORM.                    " call_invoice_cancel_func
*&---------------------------------------------------------------------*
*&      Form  call_account_cancel_func
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_ACCOUNT_CANCEL_FUNC  USING  P_BUKRS
                                      P_GJAHR
                                      P_BELNR
                                      P_BLART
                                      P_SUBRC
                                      P_PTDCL.

  TABLES : T003, T020.

  DATA: ARCHBSEG  LIKE          BSEG OCCURS 0 WITH HEADER LINE.
  DATA: TACCDN    TYPE TABLE OF ACCDN WITH HEADER LINE.
  DATA: L_IF_NULL TYPE REF TO   IF_MESSAGE_OBJ_MM.


  DATA: REV     LIKE BAPIACREV,
        REV_KEY LIKE BAPIACHE01-OBJ_KEY,
        REF_KEY LIKE BAPIACHE01-OBJ_KEY.

  DATA : L_NRRANGENR LIKE INRI-NRRANGENR,
         L_OBJECT    LIKE INRI-OBJECT,
         L_RET_CD    LIKE INRI-RETURNCODE,
         L_RET_CODE  LIKE SY-SUBRC,
         L_SUBRC     LIKE SY-SUBRC,
         L_DATE(10)  TYPE C.

  CLEAR : INVOICEDOCNUMBER_REVERSAL,
          FISCALYEAR_REVERSAL,
          RETURN,
          P_SUBRC.

  IF P_BELNR IS INITIAL.
    EXIT.
  ENDIF.

  SELECT SINGLE *
    FROM T020
   WHERE TCODE EQ 'FB03'.

  CALL FUNCTION 'READ_DOCUMENT_HEADER'
    EXPORTING
      BELNR          = P_BELNR
      BUKRS          = P_BUKRS
      GJAHR          = P_GJAHR
      XBSTV          = 'X'
      XBSTD          = 'X'
      XBSTM          = 'X'
    IMPORTING
      E_BKPF         = BKPF
      E_ARCHIVED     = T020-DYNCL
    TABLES
      T_ACCDN        = TACCDN
    EXCEPTIONS
      EXIT           = 4
      NOT_FOUND      = 8
      ARCHIVE_CANCEL = 12
      OTHERS         = 16.

*------- Beleg gefunden, nicht gefunden, archiviert? ------------------*
  CASE SY-SUBRC.
    WHEN 0.
      SET PARAMETER ID 'GJR' FIELD BKPF-GJAHR.
    WHEN 4.
      MESSAGE E429(F5) WITH P_BELNR P_BUKRS.
    WHEN 8.
      MESSAGE E429(F5) WITH P_BUKRS P_BELNR.
    WHEN 12.
      MESSAGE E881(F5) WITH P_BELNR P_BUKRS.
    WHEN OTHERS.
      MESSAGE A370(F5) WITH 'READ_DOCUMENT_HEADER'.
  ENDCASE.

*> 역분개 전표가 있을 경우.
  IF NOT BKPF-STBLG IS INITIAL.
    INVOICEDOCNUMBER_REVERSAL = BKPF-STBLG.
    FISCALYEAR_REVERSAL       = BKPF-STJAH.
    EXIT.
  ENDIF.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'N'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  IF POSTINGDATE IS INITIAL.
    CLEAR: L_DATE.
  ELSE.
    WRITE POSTINGDATE TO L_DATE.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD  USING :
      'X' 'SAPMF05A'    '0105',
      ' ' 'RF05A-BELNS' P_BELNR,         ">전표번호..
      ' ' 'BKPF-BUKRS'  P_BUKRS,         " Company Code
      ' ' 'RF05A-GJAHS' P_GJAHR,         " 회계연도.
      ' ' 'UF05A-STGRD' REASONREVERSAL,  " 취소사유.
*      ' ' 'BSIS-BUDAT'  postingdate,     " ?????.
      ' ' 'BSIS-BUDAT'  L_DATE,          " 전기취소일.
      ' ' 'BSIS-MONAT'  SPACE,           " 전기월.
      ' ' 'RF05A-VOIDR' SPACE,           " .
      ' ' 'BDC_OKCODE'  '=BU'.           " .

  SET PARAMETER ID 'BLN' FIELD ''.        " .
  SET PARAMETER ID 'GJR' FIELD ''.        " .

  PERFORM BDC_TRANSACTION USING 'FB08' L_SUBRC.

  IF L_SUBRC  EQ  C_ZERO.
    GET PARAMETER ID 'BLN' FIELD INVOICEDOCNUMBER_REVERSAL.
    GET PARAMETER ID 'GJR' FIELD FISCALYEAR_REVERSAL.

    IF INVOICEDOCNUMBER_REVERSAL IS INITIAL OR
       FISCALYEAR_REVERSAL       IS INITIAL.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE E926.
      ENDIF.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      L_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID MESSTAB-MSGID TYPE MESSTAB-MSGTYP
                  NUMBER MESSTAB-MSGNR
                  WITH   MESSTAB-MSGV1  MESSTAB-MSGV2
                         MESSTAB-MSGV3  MESSTAB-MSGV4.

      ENDIF.

      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
      MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
  ENDIF.

  P_SUBRC = L_SUBRC.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ENDIF.



*  PERFORM fill_account_header.         ">Header
*
*  gs_documentheader-obj_type = bkpf-awtyp.
*
*  ref_key        = bkpf-awkey.
*  rev_key        = ref_key.
**  rev_key(1)     = 'R'.
*  rev-obj_type   = gs_documentheader-obj_type.
*  rev-obj_key    = rev_key.
*  rev-obj_sys    = gs_documentheader-obj_sys.
*  rev-obj_key_r  = ref_key.
*
*  REFRESH: return.
*  CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_CHECK'
*    EXPORTING
*      reversal = rev
*      bus_act  = gs_documentheader-bus_act
*    TABLES
*      return   = return.
*
*  REFRESH it_msg.
*  IF NOT return[] IS INITIAL.
*    p_subrc = c_char4.
*    LOOP AT return.
*      IF NOT ( return-id       EQ 'RW'  AND
*             ( return-number   EQ '609' OR
*               return-number   EQ '632' ) ).
*        MESSAGE ID     return-id
*                TYPE   c_success
*                NUMBER return-number
*                WITH   return-message_v1  return-message_v2
*                       return-message_v3  return-message_v4.
*        PERFORM set_return_message_fill USING return-type.
*      ENDIF.
*    ENDLOOP.
*
**    LOOP AT IT_MSG.
**      IF it_msg-msgid = 'F5' AND
**         it_msg-msgno = '361'.
**
**      ENDIF.
**    ENDLOOP.
**
**> Error Message
*    DESCRIBE TABLE it_msg LINES g_line.
*    IF g_line GT 0.
*      CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*        TABLES
*          xmsg = it_msg.
*    ENDIF.
*    EXIT.
*  ELSE.
*    ref_key(10)    = p_belnr(10).
*    ref_key+10(10) = p_gjahr.
*    l_object      = 'RF_BELEG'.
*
**> Getting IMG 전표 유형 정의 테이블.
*    CLEAR: t003.
*    SELECT SINGLE *
*      FROM t003
*     WHERE blart  EQ  ( SELECT stbla
*                          FROM t003
*                         WHERE blart  =  p_blart ).
*    IF sy-subrc NE 0.
*      p_subrc = c_char4.
*      EXIT.
*    ELSE.
*      l_nrrangenr = t003-numkr.
*    ENDIF.
**> 취소할 전표번호 생성.
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*         EXPORTING
*              nr_range_nr      =   l_nrrangenr
*              object           =   l_object
***            QUANTITY         =   '1'
*              subobject        =   p_bukrs
*              toyear           =   p_gjahr
***            IGNORE_BUFFER    =   SPACE
*         IMPORTING
*              number           =   rev_key(10)
**            QUANTITY         =
*              returncode       =   l_ret_cd
*         EXCEPTIONS
*              interval_not_found      =  1 ">Interval not found
*             number_range_not_intern  =  2 ">Number range is
*              object_not_found        =  3 ">Object not defined in TNRO
*              quantity_is_0           =  4
*              quantity_is_not_1       =  5
*              interval_overflow       =  6.
*
*    l_ret_code = l_ret_cd.
*    IF sy-subrc <> 0.
*      p_subrc = c_char4.
*      MESSAGE a417(62).
*    ELSEIF l_ret_code >= 2.
*      p_subrc = c_char4.
*      MESSAGE a593(60).
*    ENDIF.
*
*    rev_key+10(10) = p_gjahr.
*    rev-obj_type   = gs_documentheader-obj_type.
*    rev-obj_key    = rev_key.
*    rev-obj_sys    = gs_documentheader-obj_sys.
*    rev-obj_key_r  = ref_key.
*
*  ENDIF.
*
**> 회계전표 취소.
*  CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
*    EXPORTING
*      reversal = rev
*      bus_act  = gs_documentheader-bus_act
*    IMPORTING
*      obj_type = g_type
*      obj_key  = g_key
*      obj_sys  = g_sys
*    TABLES
*      return   = return.
*
*  REFRESH it_msg.
*  IF invoicedocnumber_reversal IS INITIAL.
*    p_subrc = c_char4.
*    LOOP AT return.
*      IF NOT ( return-id       EQ 'RW'  AND
*             ( return-number   EQ '609' OR
*               return-number   EQ '632' ) ).
*
*        MESSAGE ID     return-id TYPE c_success NUMBER return-number
*                WITH   return-message_v1  return-message_v2
*                       return-message_v3  return-message_v4.
*        PERFORM set_return_message_fill USING return-type.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
**> Error Message
*  DESCRIBE TABLE it_msg LINES g_line.
*  IF g_line GT 0.
*    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*      TABLES
*        xmsg = it_msg.
*    EXIT.
*  ENDIF.
*
*  IF p_ptdcl NE c_charm.
*    invoicedocnumber_reversal = rev_key(10).
*    fiscalyear_reversal       = p_gjahr.
*  ENDIF.

ENDFORM.                    " call_account_cancel_func
*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_DOCUMENT_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ACCOUNT_DOCUMENT_DISPLAY  USING    P_BUKRS
                                        P_GJAHR
                                        P_BELNR.

  DATA: L_AWTYP       LIKE  ACCHD-AWTYP,
        L_AWREF       LIKE  ACCHD-AWREF,
        L_AWORG       LIKE  ACCHD-AWORG,
        L_AWSYS       LIKE  ACCHD-AWSYS,
        L_AWTYP_INCL  LIKE  ACCHD-AWTYP,
        L_AWTYP_EXCL  LIKE  ACCHD-AWTYP,
        L_BUKRS       LIKE  ACCIT-BUKRS,
        L_VALUTYP     LIKE  ACCCR-VALUTYP   VALUE '0'.

  CHECK NOT P_BELNR IS INITIAL.

  SELECT SINGLE *
    FROM RBKP
   WHERE BELNR  =  P_BELNR
     AND GJAHR  =  P_GJAHR.

  IF SY-SUBRC EQ 0.
    L_AWREF  =  P_BELNR.
    L_AWORG  =  P_GJAHR.
    L_AWTYP  = 'RMRP'.
    L_AWSYS  =  RBKP-LOGSYS.
    L_BUKRS  =  P_BUKRS.
  ELSE.
    EXIT.
  ENDIF.


  CALL FUNCTION 'AC_DOCUMENT_RECORD'
    EXPORTING
      I_AWTYP            = L_AWTYP
      I_AWREF            = L_AWREF
      I_AWORG            = L_AWORG
      I_AWSYS            = L_AWSYS
*     I_AWTYP_INCL       = ' '
*     I_AWTYP_EXCL       = ' '
      I_BUKRS            = L_BUKRS
*     I_VALUTYP          = '0'
*     X_DIALOG           = 'X'
*   TABLES
*     T_DOCUMENTS        =
    EXCEPTIONS
      NO_REFERENCE       = 1
      NO_DOCUMENT        = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " ACCOUNT_DOCUMENT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  CALL_VAT_CREATE_FUNC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_VAT_CREATE_FUNC  USING    P_SIMULATION
                                    P_SUBRC.

  DATA: L_SUBRC LIKE SY-SUBRC.
  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  CLEAR: P_SUBRC.

  IF P_SIMULATION EQ C_TRUE.
*    MESSAGE s869.
*    p_subrc     = 4.
    EXIT.
  ENDIF.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = 'X' .
  CTU_PARAMS-NOBIEND  = ' '.

  SET PARAMETER ID 'BLN' FIELD ''.
  SET PARAMETER ID 'GJR' FIELD ''.

  PERFORM BDC_TRANSACTION USING 'FB01' L_SUBRC.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  IF L_SUBRC  EQ  C_ZERO.
    GET PARAMETER ID 'BLN' FIELD INVOICEDOCNUMBER.
    GET PARAMETER ID 'GJR' FIELD FISCALYEAR.
    IF INVOICEDOCNUMBER IS INITIAL OR
       FISCALYEAR       IS INITIAL.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE E870.
      ELSE.
        MESSAGE S870.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      L_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID MESSTAB-MSGID TYPE MESSTAB-MSGTYP
                  NUMBER MESSTAB-MSGNR
                  WITH   MESSTAB-MSGV1  MESSTAB-MSGV2
                         MESSTAB-MSGV3  MESSTAB-MSGV4.
      ELSE.
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
      ENDIF.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      CLEAR: G_TABIX.
      LOOP AT MESSTAB WHERE MSGTYP EQ 'S'.
        G_TABIX = SY-TABIX.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        IF SY-CALLD EQ C_TRUE.
          MESSAGE E870.
        ENDIF.
      ENDIF.
      IF G_TABIX NE 0.

        READ TABLE MESSTAB INDEX G_TABIX.
        IF SY-SUBRC EQ 0.
          SY-MSGNO = MESSTAB-MSGNR.
          ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
              MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
        ELSE.
          MESSAGE S870.
          PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  P_SUBRC = L_SUBRC.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ENDIF.

ENDFORM.                    " CALL_VAT_CREATE_FUNC
*&---------------------------------------------------------------------*
*&      Form  call_account_pay_back_func
*&---------------------------------------------------------------------*
*       반제 BDC 루틴
*----------------------------------------------------------------------*
FORM CALL_ACCOUNT_PAY_BACK_FUNC  USING    P_BUKRS
                                          P_GJAHR
                                          P_BELNR
                                          P_BUKRSC
                                          P_GJAHRC
                                          P_BELNRC
                                          P_LIFNR
                                          P_WAERS
                                          P_WRBTR
                                          P_SUBRC.

  DATA: L_INV_DOC_NO    LIKE BAPI_INCINV_FLD-INV_DOC_NO,
        L_FISC_YEAR     LIKE BAPI_INCINV_FLD-FISC_YEAR,
        L_TEXT_M(18)    TYPE C,
        L_TEXT(18)      TYPE C,
        L_FIELDNAME(20) TYPE C,
        L_KOART         TYPE KOART,   ">계정유형.
        L_FELDN         TYPE FNAME_D. ">필드이름.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  WRITE P_WRBTR TO L_TEXT CURRENCY P_WAERS.
  PERFORM  SET_WRITE_NO_MASK     CHANGING  L_TEXT.

  P_WRBTR = P_WRBTR * -1.
  WRITE P_WRBTR TO L_TEXT_M CURRENCY P_WAERS.
  PERFORM  SET_WRITE_NO_MASK     CHANGING  L_TEXT_M.

  CLEAR: P_SUBRC.

  REFRESH: BDCDATA.
  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = 'X' .
  CTU_PARAMS-NOBIEND  = 'X'.

* 초기화면 FIELD
*> [TraSys] 미결항목 선택시 라디오버튼 위치를 찾는 함수
  L_FELDN = 'BELNR'.
*  l_koart = p_agkoa.
*  l_koart = c_chars.

  CALL FUNCTION 'Z_TS_GET_OPEN_SEL_POSITION'
    EXPORTING
      IM_KOART  = L_KOART
      IM_FELDN  = L_FELDN
    IMPORTING
      EX_T021R  = T021R
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  T021R-SELPS = T021R-SELPS + 1.
  CONCATENATE 'RF05A-XPOS1(' T021R-SELPS ')' INTO L_FIELDNAME.

  PERFORM BDC_DYNPRO_BUILD USING :
      'X' 'SAPMF05A'          '0131',
      ' ' 'RF05A-AGKON'       P_LIFNR,
      ' ' 'BKPF-BUDAT'        POSTINGDATE,
      ' ' 'BKPF-MONAT'        POSTINGDATE+4(2),
      ' ' 'BKPF-BUKRS'        P_BUKRS,
      ' ' 'BKPF-WAERS'        P_WAERS,
      ' ' 'RF05A-XNOPS'       C_TRUE,
*      ' ' 'RF05A-XPOS1(01)'   c_false,
      ' '  L_FIELDNAME        C_TRUE,
      ' ' 'BDC_OKCODE'        '/00'.             " 전기.

* NEXT SCREEN
  PERFORM BDC_DYNPRO_BUILD USING :
      'X' 'SAPMF05A'          '0731',
      ' ' 'RF05A-SEL01(01)'   P_BELNR,
      ' ' 'RF05A-SEL01(02)'   P_BELNRC,
      ' ' 'BDC_OKCODE'        '=PA'.         " 전기.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_OKCODE'      '=PART'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'RF05A-ABPOS'     '1',
         ' ' 'BDC_OKCODE'      '/00'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_CURSOR'      'RFOPS_DK-BELNR(01)',
*         ' ' 'RF05A-AKOBT'      '0',
         ' ' 'BDC_OKCODE'        '=Z+'.         " 전기.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'DF05B-PSZAH(01)' L_TEXT_M,
         ' ' 'RF05A-AKOBT'     '0',
         ' ' 'BDC_OKCODE'      '/00'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'RF05A-ABPOS'     '2',
         ' ' 'BDC_OKCODE'      '/00'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_CURSOR'      'RFOPS_DK-BELNR(01)',
*         ' ' 'RF05A-AKOBT'      '0',
         ' ' 'BDC_OKCODE'        '=Z+'.         " 전기.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'DF05B-PSZAH(01)' L_TEXT,
         ' ' 'RF05A-AKOBT'     '0',
         ' ' 'BDC_OKCODE'      '/00'.

** NEXT SCREEN
*  PERFORM bdc_dynpro_build USING :
*      'X' 'SAPDF05X'          '3100',
***      ' ' 'RF05A-AKOBT'       l_text,
*      ' ' 'BDC_OKCODE'        '=Z+'.         " 전기.
*
* NEXT SCREEN
  PERFORM BDC_DYNPRO_BUILD USING :
      'X' 'SAPDF05X'          '3100',
      ' ' 'BDC_OKCODE'        '=BU'.         " 전기.
*
** NEXT SCREEN
*  PERFORM bdc_dynpro_build USING :
*      'X' 'SAPMF05A'          '0700',
*      ' ' 'BDC_OKCODE'        '=S--'.         " 전기.
*
** NEXT SCREEN
*  PERFORM bdc_dynpro_build USING :
*      'X' 'SAPMF05A'          '0302',
*      ' ' 'BSEG-ZUONR'        '수입반제',
*      ' ' 'BSEG-SGTXT'        '수입시스템 반제전표',
*      ' ' 'BDC_OKCODE'        '=BU'.         " 전기.
*
  SET PARAMETER ID 'BLN' FIELD ''.        " 전표번호.
  SET PARAMETER ID 'GJR' FIELD ''.        " 회계년도.

*>> BDC CALL.
  PERFORM BDC_TRANSACTION USING 'F-44'  P_SUBRC.

  GET PARAMETER ID 'BLN' FIELD L_INV_DOC_NO.
  GET PARAMETER ID 'GJR' FIELD L_FISC_YEAR.    " 회계년도.

  IF P_SUBRC EQ 0.
*    PERFORM set_return_message_fill USING c_success.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID MESSTAB-MSGID TYPE MESSTAB-MSGTYP
                  NUMBER MESSTAB-MSGNR
                  WITH   MESSTAB-MSGV1  MESSTAB-MSGV2
                         MESSTAB-MSGV3  MESSTAB-MSGV4.

      ENDIF.
      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
          MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE E926.
      ENDIF.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ENDIF.

ENDFORM.                    " call_account_pay_back_func
*&---------------------------------------------------------------------*
*&      Form  display_tax_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_TAX_DOCUMENT  USING    P_TAXNO.

  CHECK NOT P_TAXNO IS INITIAL.

  SET PARAMETER ID 'ZTITAXNO' FIELD P_TAXNO.
  CALL TRANSACTION 'ZTIT743' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_tax_document
*&---------------------------------------------------------------------*
*&      Form  get_tax_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TAX_DOCUMENT  USING        P_TAXNO
                                    P_DOCNM
                                    P_ZTITTXK LIKE ZTITTXK.
  CLEAR: P_DOCNM, P_ZTITTXK.

  SELECT SINGLE *
    INTO P_ZTITTXK
    FROM ZTITTXK
   WHERE TAXNO  EQ P_TAXNO.

  IF SY-SUBRC NE 0.
    MESSAGE E742 WITH P_TAXNO.
  ENDIF.

  IF P_ZTITTXK-TXRNO IS INITIAL.
    CONCATENATE '관리번호:' P_ZTITTXK-TAXNO INTO P_DOCNM.
  ELSE.
    P_DOCNM = P_ZTITTXK-TXRNO.
  ENDIF.

ENDFORM.                    " get_tax_document
*&---------------------------------------------------------------------*
*&      Form  currency_convert_to_internal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CURRENCY_CONVERT_TO_INTERNAL  CHANGING P_WRBTR
                                            P_WRBTR_TO
                                            P_WAERS
                                            P_ISOCD.

  DATA: L_WAERS_FROM   LIKE TCURC-WAERS,
        L_WAERS_TO     LIKE TCURC-WAERS,
        L_DIGITS       TYPE I            VALUE 20.

*> ISO CODE 통화로 내부 코드 찾기.
  L_WAERS_FROM = P_WAERS.

  SELECT ISOCD
    INTO L_WAERS_TO
    FROM TCURC UP TO 1 ROWS
   WHERE WAERS EQ L_WAERS_FROM.
  ENDSELECT.

  P_ISOCD           = L_WAERS_TO.
  BAPICURX-BAPICURX = P_WRBTR.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
    EXPORTING
      CURRENCY             = L_WAERS_TO
      AMOUNT_EXTERNAL      = BAPICURX-BAPICURX
      MAX_NUMBER_OF_DIGITS = L_DIGITS
    IMPORTING
      AMOUNT_INTERNAL      = P_WRBTR_TO.
*     RETURN                     =
  .


ENDFORM.                    " currency_convert_to_internal
*&---------------------------------------------------------------------*
*&      Form  get_fi_document_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FI_DOCUMENT_NUMBER  TABLES   PT_ACCDN STRUCTURE ACCDN
                             USING    P_AWTYP
                                      P_BELNR
                                      P_GJAHR
                                      P_BUKRS
                                      P_SUBRC.

  DATA: L_AWTYP        LIKE ACCDN-AWTYP,
        L_AWREF        LIKE ACCDN-AWREF,
        L_AWORG        LIKE ACCDN-AWORG,
        L_AWSYS        LIKE ACCDN-AWSYS,
        L_BUKRS        LIKE ACCDN-BUKRS,
        L_SUBRC        LIKE SY-SUBRC,
        L_INV_DOC_NO   LIKE BAPI_INCINV_FLD-INV_DOC_NO,
        L_FISC_YEAR    LIKE BAPI_INCINV_FLD-FISC_YEAR.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  CLEAR: P_SUBRC.

  L_AWTYP = P_AWTYP.
  L_AWREF = P_BELNR.
  L_AWORG = P_GJAHR.
  L_BUKRS = P_BUKRS.
*  l_awsys =

  REFRESH: PT_ACCDN.  CLEAR: PT_ACCDN.
*>Specify Name of Current Logged-on System (client in R/3 System)
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM             = L_AWSYS
    EXCEPTIONS
      OWN_LOGICAL_SYSTEM_NOT_DEFINED = 1
      OTHERS                         = 2.
  IF SY-SUBRC NE 0.
    P_SUBRC = C_CHAR4.
    EXIT.
  ENDIF.

*>FI: General Document Access Routines
  CALL FUNCTION 'FI_DOCUMENT_FIND_FOR_INTERFACE'
   EXPORTING
     I_AWTYP            = L_AWTYP
     I_AWREF            = L_AWREF
     I_AWORG            = L_AWORG
     I_AWSYS            = L_AWSYS
     I_BUKRS            = L_BUKRS
    TABLES
     E_ACCDN            = PT_ACCDN
*     I_ACCDN            =
   EXCEPTIONS
     NO_DOC_FOUND       = 1
     OTHERS             = 2.

  IF SY-SUBRC <> 0.
    P_SUBRC = C_CHAR4.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    MESSAGE ID SY-MSGID TYPE C_SUCCESS NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.

*> 오류정보가 존재시 메시지 상자 POPUP.
    G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                            IM_BUSINESS_OBJ          = L_IF_NULL
                            IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

    IF G_LINE GT 0.
      CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
        IM_AMODAL = C_FALSE ).
      P_SUBRC = C_CHAR4.
    ENDIF.
    EXIT.
  ENDIF.


  READ TABLE PT_ACCDN INDEX 1.
  IF SY-SUBRC NE 0.
    P_SUBRC = C_CHAR4.
    EXIT.
  ENDIF.

ENDFORM.                    " get_fi_document_number
