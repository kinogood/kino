*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FILL_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_RETURN
*&      --> TEXT_E02
*&---------------------------------------------------------------------*
FORM FILL_LOG_DATA  USING  PV_TYPE
                           PV_SYSTEM_ID
                           PV_TEXT.

  CLEAR : GT_RETURN, GT_HEADER.
  MOVE-CORRESPONDING GS_ORDER TO GT_RETURN.

  MOVE-CORRESPONDING GT_RETURN TO GT_HEADER.
  GET TIME STAMP FIELD GT_HEADER-ZIFKEY.

  GT_RETURN-ZERP_STAT    = PV_TYPE.
  GT_RETURN-ZERP_MESSAGE = PV_TEXT.
  APPEND GT_RETURN.

  GT_HEADER-ZERP_STAT = PV_TYPE.
  GT_HEADER-ZERP_MESSAGE = PV_TEXT.
  GT_HEADER-ZSYSTEM_ID = PV_SYSTEM_ID.
  GT_HEADER-IFDAT = SY-DATUM.
  GT_HEADER-IFTIM = SY-UZEIT.
  GT_HEADER-IFNAM = SY-UNAME.
  APPEND GT_HEADER.

*** U01
*  LOOP AT GT_ORDERDATA INTO DATA(LS_ITEM) WHERE AUFNR = GS_ORDER-AUFNR.
*
*    CLEAR GT_ITEM.
*    MOVE-CORRESPONDING LS_ITEM  TO GT_ITEM.
*    GT_ITEM-ZSERNO     = GS_ORDER-ZSERNO.
*    GT_ITEM-ZIFKEY     = GT_HEADER-ZIFKEY.
*    GT_ITEM-ZSYSTEM_ID = GT_HEADER-ZSYSTEM_ID.
*    APPEND GT_ITEM.
*
*  ENDLOOP.
*** U01

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_OPERATION_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_OPERATION_DATA USING PV_SYSTEM_ID.

  DATA : LV_MESSAGE(220).

*// Modified by ZGODEV06 on 2026-05-21 {
  SELECT SINGLE CRHD~ARBPL, CRTX~KTEXT
    INTO @DATA(LS_CRHD)
    FROM CRHD
    JOIN CRTX
      ON CRHD~OBJTY EQ CRTX~OBJTY
     AND CRHD~OBJID EQ CRTX~OBJID
   WHERE CRHD~OBJTY EQ @ZGTPP_IF_CONST=>GC_OBJTY
     AND CRHD~WERKS EQ @GS_ORDER-WERKS
     AND CRHD~ARBPL EQ @GS_ORDERDATA-ARBPL.
*// }

  CASE GC_X.
    WHEN GS_ORDERDATA-ARBPLX.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_ORDER-AUFNR,
       '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
       '         ' '    ' ' ' 'BDC_OKCODE' '=ENTK'.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=VGUE'.

      PERFORM BDC_INPUT USING :
       'SAPLCOVG' '0100' 'X' 'BDC_OKCODE' '=AUFS'.

      PERFORM BDC_INPUT USING :
       'SAPLCO05' '0100' 'X' 'BDC_OKCODE' '=MORE'.

      PERFORM BDC_INPUT USING :
*       'SAPLCOVG' '0100' 'X' 'AFVGD-ARBPL(01)' GS_ORDERDATA-ARBPL,
*       '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      'SAPLCOVG' '0100' 'X' 'BDC_OKCODE' '/00',
       '        ' '    ' ' ' 'AFVGD-ARBPL(01)' GS_ORDERDATA-ARBPL,
*// Modified by ZGODEV06 on 2026-01-21 {
       '        ' '    ' ' ' 'AFVGD-LTXA1(01)' LS_CRHD-KTEXT.
*// }

      PERFORM BDC_INPUT USING :
       'SAPLCOVG' '0100' 'X' 'BDC_OKCODE' '=BU'.



*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_ORDER-AUFNR,
*       '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
*       '         ' '    ' ' ' 'BDC_OKCODE' '=ENTK'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0200' 'X' 'BDC_CURSOR' 'AFFLD-LTXA1(01)',
*       '         ' '    ' ' ' 'BDC_OKCODE' '=SEQC'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=VGUE'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOVG' '0100' 'X' 'AFVGD-ARBPL(01)' GS_ORDERDATA-ARBPL,
*       '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
*
**      IF LV_DSPT = 'X'.
**        PERFORM BDC_INPUT USING :
**         'SAPLSPO1' '0300' 'X' 'BDC_OKCODE' '=YES'.
**      ENDIF.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOVG' '0100' 'X' 'BDC_OKCODE' '=BU'.

    WHEN GS_ORDERDATA-PLNFLX.

      PERFORM BDC_INPUT USING :
      'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_ORDER-AUFNR,
      '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
      '         ' '    ' ' ' 'BDC_OKCODE' '=FLGU'.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0200' 'X' 'BDC_OKCODE' '=SEQC'.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0630' 'X' 'BDC_OKCODE' '=POSI'.

      PERFORM BDC_INPUT USING :
       'SAPLSPO4' '0300' 'X' 'BDC_OKCODE' '=FURT',
       '        ' '    ' ' ' 'SVALD-VALUE(01)' GS_ORDERDATA-PLNFL.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0630' 'X' 'BDC_OKCODE' '=ENT1'.

      PERFORM BDC_INPUT USING :
       'SAPLCOKO1' '0200' 'X' 'BDC_OKCODE' '=BU'.

*      PERFORM BDC_INPUT USING :
*      'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_ORDER-AUFNR,
*      '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
*      '         ' '    ' ' ' 'BDC_OKCODE' '/00'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=SEQC'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0630' 'X' 'BDC_OKCODE' '=POSI'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLSPO4' '0300' 'X' 'BDC_OKCODE' '=FURT',
*       '        ' '    ' ' ' 'SVALD-VALUE(01)' GS_ORDERDATA-PLNFL.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0630' 'X' 'BDC_OKCODE' '=ENT1'.
*
*      PERFORM BDC_INPUT USING :
*       'SAPLCOKO1' '0200' 'X' 'BDC_OKCODE' '=BU'.

  ENDCASE.

  PERFORM FILL_CTU_PARAMS USING 'N'.
  CALL TRANSACTION 'CO02' USING GT_BDCDATA
                          OPTIONS FROM GS_PARAMS
                          MESSAGES INTO GT_MESSAGE.

  READ TABLE GT_MESSAGE INDEX 1.
  PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
  IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = GC_S ] ).
    PERFORM FILL_LOG_DATA USING GC_S PV_SYSTEM_ID TEXT-S01.
  ELSE.
    PERFORM FILL_LOG_DATA USING GC_E PV_SYSTEM_ID LV_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GS_ORDER_AUFNR
*&---------------------------------------------------------------------*
FORM BDC_INPUT  USING P_PROGRAM P_DYNPRO P_DYNBEGIN P_FNAM P_FVAL.

  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = P_DYNBEGIN.
  GT_BDCDATA-FNAM     = P_FNAM.
  GT_BDCDATA-FVAL     = P_FVAL.
  CONDENSE GT_BDCDATA-FVAL.
  APPEND GT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CTU_PARAMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM FILL_CTU_PARAMS  USING PV_MODE.

  GS_PARAMS-DISMODE  = PV_MODE.
  GS_PARAMS-UPDMODE  = GC_S.
  GS_PARAMS-RACOMMIT = GC_X.
  GS_PARAMS-DEFSIZE  = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_FUNCTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MESSAGE
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MESSAGE_FUNCTION   USING PS_MESSAGE STRUCTURE BDCMSGCOLL
                              PV_TEXT.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = PS_MESSAGE-MSGID "SY-MSGID
      MSGNR               = PS_MESSAGE-MSGNR "SY-MSGNO
      MSGV1               = PS_MESSAGE-MSGV1 "SY-MSGV1
      MSGV2               = PS_MESSAGE-MSGV2 "SY-MSGV2
      MSGV3               = PS_MESSAGE-MSGV3 "SY-MSGV3
      MSGV4               = PS_MESSAGE-MSGV4 "SY-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PROD_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM CHANGE_PROD_STATUS  USING    PV_SYSTEM_ID
                                  PV_USER_LINE.

  DATA : LV_PROFILE TYPE CO_STSMA_HDR,
         LV_STATUS  TYPE BAPI_ORDER_FUNC_CNTRL-STATUS,
         LS_RET     TYPE BAPIRET2,
         LT_RET     TYPE TABLE OF BAPI_ORDER_RETURN,
         LT_ORDER   TYPE TABLE OF BAPI_ORDER_KEY WITH HEADER LINE.

  LV_PROFILE = |PPGT0001|.
  LT_ORDER-ORDER_NUMBER = GS_ORDER-AUFNR.
  APPEND LT_ORDER. CLEAR LT_ORDER.

  IF PV_USER_LINE = |PAYO| AND GS_ORDERDATA-STATUS IS INITIAL.
    LV_STATUS = PV_USER_LINE.
  ENDIF.
*
  IF LV_STATUS IS NOT INITIAL.

    CALL FUNCTION 'BAPI_PRODORD_REVOKEUSERSTATUS'
      EXPORTING
        STATUS_PROFILE = LV_PROFILE
        STATUS         = LV_STATUS
      IMPORTING
        RETURN         = LS_RET
      TABLES
        ORDERS         = LT_ORDER
        DETAIL_RETURN  = LT_RET.

  ELSE.

    CALL FUNCTION 'BAPI_PRODORD_SETUSERSTATUS'
      EXPORTING
        STATUS_PROFILE = LV_PROFILE
        STATUS         = GS_ORDERDATA-STATUS
      IMPORTING
        RETURN         = LS_RET
      TABLES
        ORDERS         = LT_ORDER
        DETAIL_RETURN  = LT_RET.
  ENDIF.

  IF LS_RET-TYPE = GC_E.
    PERFORM FILL_LOG_DATA USING GC_E PV_SYSTEM_ID LS_RET-MESSAGE.
  ELSE.

*// Modified by ZGODEV06 on 2026-04-02 {
    IF PV_USER_LINE EQ 'LBCO'.
      UPDATE ZGTPPT2190
         SET PRINT_STAT = 'Y'      "라벨 발행 완료
       WHERE ZCUT_ORD_NO EQ GS_ORDER-AUFNR.
    ENDIF.
*// }

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PERFORM FILL_LOG_DATA USING GC_S PV_SYSTEM_ID TEXT-S02.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PROD_SCHEDULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM CHANGE_PROD_SCHEDULE  USING    PV_SYSTEM_ID.

  DATA : LS_ORDERDATA  TYPE BAPI_PP_ORDER_CHANGE,
         LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX,
         LS_RET        TYPE BAPIRET2.

  IF GS_ORDERDATA-GSTRP IS NOT INITIAL.
    LS_ORDERDATA-BASIC_START_DATE = GS_ORDERDATA-GSTRP.
    LS_ORDERDATAX-BASIC_START_DATE = GC_X.
  ENDIF.

  IF GS_ORDERDATA-GLTRP IS NOT INITIAL.
    LS_ORDERDATA-BASIC_END_DATE = GS_ORDERDATA-GLTRP.
    LS_ORDERDATAX-BASIC_END_DATE = GC_X.
  ENDIF.

*// Modified by ZGODEV06 on 2026-04-02 {
* ls_orderdata-basic_scheduling_type = |3|.

  IF PV_SYSTEM_ID EQ 'KGPM' OR PV_SYSTEM_ID EQ 'KGOM'. "// 가온전선일 경우.
    LS_ORDERDATA-BASIC_SCHEDULING_TYPE = |7|.
  ELSE.
    LS_ORDERDATA-BASIC_SCHEDULING_TYPE = |3|.
  ENDIF.
*// }

  LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = GC_X.

  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
    EXPORTING
      NUMBER     = GS_ORDER-AUFNR
      ORDERDATA  = LS_ORDERDATA
      ORDERDATAX = LS_ORDERDATAX
    IMPORTING
      RETURN     = LS_RET.

  IF LS_RET-TYPE = GC_E.
    PERFORM FILL_LOG_DATA USING GC_E PV_SYSTEM_ID LS_RET-MESSAGE.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PERFORM FILL_LOG_DATA USING GC_S PV_SYSTEM_ID TEXT-S03.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_prod_quantity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM CHANGE_PROD_QUANTITY  USING    PV_SYSTEM_ID.

  DATA : LS_ORDERDATA  TYPE BAPI_PP_ORDER_CHANGE,
         LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX,
         LS_RET        TYPE BAPIRET2.
  DATA : LV_CHK_ERR.

  IF GS_ORDERDATA-PSMNG IS NOT INITIAL.
    LS_ORDERDATA-QUANTITY = GS_ORDERDATA-PSMNG.
    LS_ORDERDATAX-QUANTITY = GC_X.
  ENDIF.

  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
    EXPORTING
      NUMBER     = GS_ORDER-AUFNR
      ORDERDATA  = LS_ORDERDATA
      ORDERDATAX = LS_ORDERDATAX
    IMPORTING
      RETURN     = LS_RET.

  IF LS_RET-TYPE = GC_E.
    PERFORM FILL_LOG_DATA USING GC_E PV_SYSTEM_ID LS_RET-MESSAGE.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    WAIT UP TO '0.3' SECONDS.
*  수량 변경건에 대한 BDC
    CLEAR LV_CHK_ERR.
    PERFORM SET_CHG_PRD_CHARJOJANG USING GS_ORDER-AUFNR GS_ORDERDATA-PSMNG
                                CHANGING LV_CHK_ERR.

    CASE GS_ORDER-WERKS.
      WHEN '6500' OR '6600'.
        PERFORM CHG_PROD_PLAN.
    ENDCASE.

    IF LV_CHK_ERR = ABAP_TRUE.
      PERFORM FILL_LOG_DATA USING GC_S PV_SYSTEM_ID TEXT-S32.
    ELSE.
      PERFORM FILL_LOG_DATA USING GC_S PV_SYSTEM_ID TEXT-S30.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHG_PRD_CHARJOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORDER_AUFNR
*&      --> GS_ORDERDATA_PSMNG
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_CHG_PRD_CHARJOJANG  USING   PV_AUFNR TYPE AUFNR
                                      PV_PSMNG TYPE ZGTE_PSMNG_C
                             CHANGING PV_CHK_ERR.

  DATA : LV_PSMNG TYPE AFPO-PSMNG.
  DATA : LV_CUOBJ TYPE CUOBJ_VA.
  DATA : LV_INLENGTH TYPE ZGTPPT2010-INLENGTH.
  DATA : LV_INLENGTH_C TYPE CHAR20.
  DATA : LV_INFACTOR TYPE ZGTPPT2010-INFACTOR.
  DATA : LV_INFACTOR_C TYPE CHAR20.
  DATA : LV_TEST01 TYPE CABNT-ATBEZ.
  DATA : LV_TEST02 TYPE CABNT-ATBEZ.


* BDC 테이블
  DATA : LS_BDCPARAMS TYPE CTU_PARAMS .
  DATA : LS_BDCDATA TYPE BDCDATA .
  DATA : LT_BDCDATA TYPE TABLE OF BDCDATA .
  DATA : LT_MESSTAB TYPE TABLE OF BDCMSGCOLL .

  DEFINE __SETTING_BDC_PARAMS.
    CLEAR: ls_bdcparams.
    ls_bdcparams-dismode  = 'N'.   " 처리모드
    ls_bdcparams-updmode  = 'S'.   " 갱신세션
*  MS_BDCPARAMS-CATTMODE = ''.   " CATT모드
    ls_bdcparams-defsize  = 'X'.   " 기본화면
**  MS_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
**  MS_BDCPARAMS-NOBINPT  = ' '.   " BI 세션
  END-OF-DEFINITION.

  DEFINE __BDC_DYNPRO.
    CLEAR ls_bdcdata.
    ls_bdcdata-program  = &1.
    ls_bdcdata-dynpro   = &2.
    ls_bdcdata-dynbegin = 'X'.
    APPEND ls_bdcdata TO lt_bdcdata.
  END-OF-DEFINITION.

  DEFINE __BDC_FIELD.
    CLEAR ls_bdcdata.
    ls_bdcdata-fnam = &1.
    ls_bdcdata-fval = CONV #( &2 ).
    APPEND ls_bdcdata TO lt_bdcdata.
  END-OF-DEFINITION.


  DEFINE __BDC_TRANSACTION.
    CALL TRANSACTION &1 USING lt_bdcdata
                                OPTIONS FROM ls_bdcparams
                              MESSAGES INTO lt_messtab.
  END-OF-DEFINITION.


  LV_PSMNG = PV_AUFNR.

  SELECT A~ATNAM, B~ATBEZ
    FROM CABN AS A
    INNER JOIN CABNT AS B ON B~ATINN = A~ATINN
  WHERE A~ATNAM IN ( 'SAP_MILLCA_LENGTH', 'SAP_MILLCA_FACTOR' )
    AND B~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_CHAR_NAME).

  LOOP AT LT_CHAR_NAME INTO DATA(LS_CHAR_NAME).
    CASE LS_CHAR_NAME-ATNAM.
      WHEN 'SAP_MILLCA_LENGTH'.
        LV_TEST01 = LS_CHAR_NAME-ATBEZ.
      WHEN 'SAP_MILLCA_FACTOR'.
        LV_TEST02 = LS_CHAR_NAME-ATBEZ.
    ENDCASE.
  ENDLOOP.


  SELECT SINGLE CUOBJ FROM AFPO
    INTO LV_CUOBJ
    WHERE AUFNR = PV_AUFNR.
  IF SY-SUBRC NE 0.
    RETURN.
  ENDIF.

* 오더의 조장 정보 가져오기
  ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
    EXPORTING
      IV_CUOBJ        = LV_CUOBJ                 " 구성
    IMPORTING
      EV_ZGTEINDLEN   = LV_INLENGTH  ).

  IF LV_INLENGTH NE 0.
    LV_INFACTOR = PV_PSMNG / LV_INLENGTH.
  ELSE.
    LV_INLENGTH = PV_PSMNG.
    LV_INFACTOR = 1.
  ENDIF.

  LV_INLENGTH_C = LV_INLENGTH.
  LV_INFACTOR_C = LV_INFACTOR.

  REFRESH : LT_BDCDATA, LT_MESSTAB.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_AUFNR,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환


  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __BDC_DYNPRO 'SAPLCEI0' '0109'.
  __BDC_FIELD : 'RCTMS-MNAME(01)' LV_TEST01,
                      'RCTMS-MNAME(02)' LV_TEST02,
                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
                      'RCTMS-MWERT(02)' LV_INFACTOR_C,
                      'BDC_OKCODE' '=BACK'.


  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.
  LOOP AT LT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.
    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHG_PROD_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHG_PROD_PLAN .

* 플랜트 6500 6600 대상
*  생산작업지시(ZGTPPT2340) 에 적용된 MTO 생산오더의 수량변경시
*  생산오더 특성값에서 조장수 변경을 할 수 없기 때문에
*  관리테이블 ZGTPPT2340 에 특성값 재저장 하는 프로세스

  SELECT SINGLE A~*
    FROM ZGTPPT2340 AS A
    INNER JOIN ZGTPPT2340 AS B ON B~MATNR = A~MATNR
                              AND B~ZWKREQ = A~ZWKREQ
                              AND B~RQMON = A~RQMON
   WHERE A~ORDNR = @GS_ORDER-AUFNR
     AND B~DMORD IS NOT INITIAL
    INTO @DATA(LS_2340).

  IF SY-SUBRC EQ 0 AND LS_2340 IS NOT INITIAL.
    IF LS_2340-INFACTOR = 1.
      LS_2340-INLENGTH = GS_ORDERDATA-PSMNG.
    ELSE.
      LS_2340-INFACTOR = GS_ORDERDATA-PSMNG / LS_2340-INLENGTH.
      PERFORM CONV_ROUND USING '1' CHANGING LS_2340-INFACTOR.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- LS_2340_INFACTOR
*&---------------------------------------------------------------------*
FORM CONV_ROUND  USING    PV_DIGIT
                 CHANGING PV_MENGE.

  DATA : LV_RUNIT TYPE VTBFIMA-RUNIT.
  DATA : LV_VALUE TYPE MENGE_D.

  LV_RUNIT = PV_DIGIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = ' '
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_MENGE
    IMPORTING
      E_VALUE_RND = PV_MENGE.

ENDFORM.
