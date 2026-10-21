*----------------------------------------------------------------------*
***INCLUDE LZGTSD10F01.
*----------------------------------------------------------------------*
FORM CHANGE_ATTRIBUTE_DOITEM CHANGING PS_DATA TYPE ZGTSDS0026.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LV_MESSAGE(200).

  CLEAR:GS_LIKP,GT_LIPS[].

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @GS_LIKP.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @GT_LIPS.
  SORT GT_LIPS BY POSNR.

*-CHECK
  IF GS_LIKP-WBSTK EQ GC_C.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M15.
    EXIT.
  ENDIF.

*-ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_D. "배치라인 삭제
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M50.
    EXIT.
  ENDIF.

  "배치분할 라인 삭제 체크
  LOOP AT GT_LIPS INTO DATA(LS_LIPS) WHERE UECHA NE '000000'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M16.
    EXIT.
  ENDIF.

*-CHANGE DO ITEM ATTRIBUTES
  PERFORM CHANGE_DO_ITEM_ATTRS CHANGING PS_DATA.

**-PICKING 수량 0
*  PERFORM CHANGE_PICKING_QTY   TABLES LT_LIPS
*                             CHANGING PS_DATA.
*  IF PS_DATA-MTYPE EQ GC_E.
*    EXIT.
*  ENDIF.


ENDFORM.
FORM CHANGE_PICKING_QTY     TABLES PT_LIPS STRUCTURE LIPS
                          CHANGING PS_DATA TYPE ZGTSDS0026.
  DATA: LS_VBKOK TYPE VBKOK,
        LT_VBPOK TYPE TABLE OF VBPOK,
        LT_PROT  TYPE TABLE OF  PROTT.

*-VBFA
  SELECT *
    FROM VBFA
     FOR ALL ENTRIES IN @PT_LIPS
   WHERE VBELV   EQ @PT_LIPS-VBELN
     AND POSNV   EQ @PT_LIPS-POSNR
     AND VBTYP_N EQ @IF_SD_DOC_CATEGORY=>WMS_TRANS_ORDER "PICKING
     AND VBTYP_V EQ @IF_SD_DOC_CATEGORY=>DELIVERY
     AND RFMNG   <> 0
    INTO TABLE @DATA(LT_VBFA).
  CHECK LT_VBFA[] IS NOT INITIAL.

  SORT LT_VBFA BY VBELV POSNV.
  DELETE ADJACENT DUPLICATES FROM LT_VBFA COMPARING VBELV POSNV.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_DO_ITEM_ATTRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_DO_ITEM_ATTRS CHANGING PS_DATA TYPE ZGTSDS0026.
  DATA: LV_LFIMG(10) VALUE '0'.
  DATA: LV_MSG(200).
  DATA: LV_JSPROC(5),
        LT_ITEM TYPE TABLE OF ZGTSDS0035.

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  CONDENSE LV_LFIMG.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  GS_LIKP-VBELN.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=T\02'.

  LOOP AT GT_LIPS INTO DATA(LS_LIPS).
    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '0111',
                           ' '  'BDC_OKCODE'  '=WEIT',
                           ' '  'RV50A-POSNR' LS_LIPS-POSNR.


    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '/00',
                           ' '  'LIPSD-G_LFIMG(01)' LV_LFIMG,
                           ' '  'LIPSD-PIKMG(01)'   LV_LFIMG.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '/00'.

  ENDLOOP.


  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '/00'.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.


  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

*-DO ITEM의 이동유형(BWART),청구관련(FKREL) 필드값을 SPACE로 지정
*-SAPMV50A의 USER-EXIT : userexit_save_document_prepare =>PERFORM USEREXIT_SAVE_DOCUMENT_PRE0012.
*                       에서 처리.(IMPORT MEMORY ID 로 대상인지 구분)

  LV_JSPROC = 'QT0'.
  EXPORT LV_JSPROC LT_ITEM TO MEMORY ID 'ZGTSDR2010_QT0'.

  CALL TRANSACTION 'VL02N' USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.
  ELSE.
    PS_DATA-MTYPE = GC_E.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AEX'.
      CLEAR LV_MSG.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MSG.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG = LV_MSG.
      ELSE.
        PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MSG }|.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*& Form MESSAGE_BUILD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MSG_MSGID
*&      --> LS_MSG_MSGNR
*&      --> LS_MSG_MSGV1
*&      --> LS_MSG_MSGV2
*&      --> LS_MSG_MSGV3
*&      --> LS_MSG_MSGV4
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
FORM CHECK_JS_DO_CREATE TABLES PT_DATA STRUCTURE ZGTSDS0031
                         USING PV_LFART.
  DATA:LS_DATA TYPE ZGTSDS0031.
  DATA:LV_MSG(200),
       LV_ERR(1).
  DATA:LV_LENGTH_VRKME TYPE LFIMG,
       LV_LFIMG        TYPE LFIMG.

*-중복 체크
  DATA(LT_TEMP1) = PT_DATA[].
  SORT LT_TEMP1 BY VGBEL VGPOS ZZVBELN_JS ZZPOSNR_JS.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP1 COMPARING VGBEL VGPOS ZZVBELN_JS ZZPOSNR_JS.

  IF LINES( LT_TEMP1 ) NE LINES( PT_DATA ).
    CLEAR LS_DATA.
    LS_DATA-MTYPE = GC_E.
    LS_DATA-MSG   = TEXT-M32.
    MODIFY PT_DATA FROM LS_DATA TRANSPORTING MTYPE MSG WHERE MTYPE NE GC_E.
    EXIT.
  ENDIF.

*-ZGTSDT9110
  CLEAR GT_ZGTSDT9110[].
  SORT PT_DATA BY ZZVBELN_JS.
  SELECT *
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @PT_DATA
   WHERE VBELN EQ @PT_DATA-ZZVBELN_JS
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9110.

*-필수필드/ZGTSDT9120 존재 여부
  CLEAR:GT_ZGTSDT9120[].
  SORT PT_DATA BY ZZVBELN_JS ZZPOSNR_JS.
  SELECT *
    FROM ZGTSDT9120
     FOR ALL ENTRIES IN @PT_DATA
   WHERE VBELN EQ @PT_DATA-ZZVBELN_JS
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    CLEAR:LV_MSG,LV_ERR.
    "필수 입력
    IF <FS_DATA>-VGBEL IS INITIAL.
      LV_ERR = GC_X.
      LV_MSG = TEXT-001.
    ENDIF.

    IF <FS_DATA>-VGPOS IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-002.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-002 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-MATNR IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-003.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-003 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-WERKS IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-004.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-004 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-LGORT IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-005.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-005 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-LFIMG IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-006.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-006 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-VRKME IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-007.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-007 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-ZZVBELN_JS IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-008.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-008 }|.
      ENDIF.

    ENDIF.

    IF <FS_DATA>-ZZPOSNR_JS IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-009.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-009 }|.
      ENDIF.

    ENDIF.

    IF LV_ERR IS NOT INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      MESSAGE S007 WITH LV_MSG INTO <FS_DATA>-MSG.
      CONTINUE.
    ENDIF.

*   현재 처리 상태
    DATA(LS_ZGTSDT9110) = VALUE #( GT_ZGTSDT9110[ VBELN = <FS_DATA>-ZZVBELN_JS ] OPTIONAL ).
    IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_H. "가상창고 재고이동
      <FS_DATA>-MTYPE = GC_E.
      <FS_DATA>-MSG   = TEXT-M54.
      CLEAR:LS_ZGTSDT9110.
      CONTINUE.
    ENDIF.

*   당월 vs 익월이후 처리
    DATA(LS_ZGTSDT9120) = VALUE #( GT_ZGTSDT9120[ VBELN = <FS_DATA>-ZZVBELN_JS
                                                  POSNR = <FS_DATA>-ZZPOSNR_JS ] OPTIONAL ).

    "처리대상 미존재
    IF LS_ZGTSDT9120 IS INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      <FS_DATA>-MSG   = TEXT-M19.
    ENDIF.

    "당월 / 익월이후 처리 체크
    IF <FS_DATA>-MTYPE NE GC_E.
      CASE PV_LFART.
        WHEN GC_LFART_ZLF. "당월처리
          IF LS_ZGTSDT9120-MILLCA_FACTOR_M <= 0.
            <FS_DATA>-MTYPE = GC_E.
            <FS_DATA>-MSG   = TEXT-M34.
          ENDIF.

          "수량 체크
          CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
          IF <FS_DATA>-MTYPE NE GC_E.
            PERFORM GET_SAP_LENGTH_VRKME    USING <FS_DATA>-VGBEL <FS_DATA>-VGPOS
                                         CHANGING LV_LENGTH_VRKME.
            LV_LFIMG = LV_LENGTH_VRKME * LS_ZGTSDT9120-MILLCA_FACTOR_M.
            IF LV_LFIMG NE <FS_DATA>-LFIMG.
              <FS_DATA>-MTYPE = GC_E.
              <FS_DATA>-MSG   = TEXT-M36.
            ENDIF.
          ENDIF.

        WHEN GC_LFART_ZLF3. "익월이후 처리
          IF LS_ZGTSDT9120-MILLCA_FACTOR_JS <= 0.
            <FS_DATA>-MTYPE = GC_E.
            <FS_DATA>-MSG   = TEXT-M35.
          ENDIF.

          "수량 체크
          CLEAR:LV_LENGTH_VRKME,LV_LFIMG.
          IF <FS_DATA>-MTYPE NE GC_E.
            PERFORM GET_SAP_LENGTH_VRKME    USING <FS_DATA>-VGBEL <FS_DATA>-VGPOS
                                         CHANGING LV_LENGTH_VRKME.
            LV_LFIMG = LV_LENGTH_VRKME * LS_ZGTSDT9120-MILLCA_FACTOR_JS.
            IF LV_LFIMG NE <FS_DATA>-LFIMG.
              <FS_DATA>-MTYPE = GC_E.
              <FS_DATA>-MSG   = TEXT-M37.
            ENDIF.
          ENDIF.

      ENDCASE.

      "기 생성 체크
      IF <FS_DATA>-MTYPE NE GC_E.
        SELECT SINGLE A~VBELN
          FROM LIPS AS A INNER JOIN LIKP AS B
                         ON A~VBELN = B~VBELN
         WHERE A~VGBEL EQ @<FS_DATA>-VGBEL
           AND A~VGPOS EQ @<FS_DATA>-VGPOS
           AND A~ZZVBELN_JS EQ @<FS_DATA>-ZZVBELN_JS
           AND A~ZZPOSNR_JS EQ @<FS_DATA>-ZZPOSNR_JS
           AND B~VKORG   EQ @GC_VKORG_6000
           AND B~LFART   EQ @PV_LFART
          INTO @DATA(LV_VBELN).
        IF SY-SUBRC EQ 0.
          <FS_DATA>-MTYPE = GC_S.
          <FS_DATA>-MSG   = TEXT-M40.
        ENDIF.
      ENDIF.
    ENDIF.


    CLEAR: LS_ZGTSDT9120,LS_ZGTSDT9110,LV_VBELN.
  ENDLOOP.

ENDFORM.

FORM GET_SAP_LENGTH_VRKME    USING PV_VGBEL PV_VGPOS
                          CHANGING PV_LENGTH_VRKME.
  DATA: LT_CHAR LIKE TABLE OF CONF_OUT.
  CONSTANTS:LC_LENGTH_VRKME TYPE ATNAM VALUE 'SAP_LENGTH_VKRME'.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE'
    EXPORTING
      I_VBELN                      = PV_VGBEL
      I_POSNR                      = PV_VGPOS
    TABLES
      ET_CHAR                      = LT_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.
  IF SY-SUBRC = 0.
    DATA(LV_ATWRT) = VALUE #( LT_CHAR[ ATNAM = LC_LENGTH_VRKME ]-ATWRT OPTIONAL ).
    PV_LENGTH_VRKME = CONV LFIMG( LV_ATWRT ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_JS_DO_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_DATA
*&      --> I_LFART
*&      --> I_WADAT
*&---------------------------------------------------------------------*
FORM RUN_JS_DO_CREATE  TABLES   PT_DATA STRUCTURE ZGTSDS0031
                       USING    PV_LFART
                                PV_WADAT.
  DATA: LT_JSDOINFO TYPE TABLE OF ZGTSDS0030,
        LS_JSDOINFO TYPE ZGTSDS0030.
  DATA: LS_TEMP TYPE ZGTSDS0031.

  CLEAR:GS_TECHN_CONTROL,
        GT_REQUEST[],GT_CREATEDITEMS[],GT_RETURN[].
  CLEAR:GT_ZGTSDT9120[],GT_ZGTSDT9110[].

  SELECT *
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @PT_DATA
   WHERE VBELN EQ @PT_DATA-ZZVBELN_JS
    INTO TABLE @GT_ZGTSDT9110.

  SELECT *
    FROM ZGTSDT9120
     FOR ALL ENTRIES IN @PT_DATA
   WHERE VBELN EQ @PT_DATA-ZZVBELN_JS
    INTO TABLE @GT_ZGTSDT9120.

*-BAPI PARAMETER

  GS_TECHN_CONTROL-POST_ASYNC = GC_X.

  SORT PT_DATA BY ZZVBELN_JS ZZPOSNR_JS.

  LOOP AT PT_DATA INTO DATA(LS_DATA).
    CLEAR: GS_REQUEST.

    GS_REQUEST-ID                 = 1.
    GS_REQUEST-DOCUMENT_TYPE      = GC_A.
    GS_REQUEST-DOCUMENT_TYPE_DELIVERY = PV_LFART.
    GS_REQUEST-DOCUMENT_NUMB      = LS_DATA-VGBEL.
    GS_REQUEST-DOCUMENT_ITEM      = LS_DATA-VGPOS.
    GS_REQUEST-MATERIAL_LONG      = LS_DATA-MATNR.
    GS_REQUEST-PLANT              = LS_DATA-WERKS.
    GS_REQUEST-STGE_LOC           = LS_DATA-LGORT.
    GS_REQUEST-QUANTITY_SALES_UOM = LS_DATA-LFIMG.
    GS_REQUEST-SALES_UNIT         = LS_DATA-VRKME.
    APPEND GS_REQUEST TO GT_REQUEST.

    "확장필드 및 납품유형/일자 , ORIGINAL DO
    CLEAR:LS_JSDOINFO.
    LS_JSDOINFO-FLAG_JS     = GC_X.
    LS_JSDOINFO-VKORG       = VALUE #( GT_ZGTSDT9110[ 1 ]-VKORG OPTIONAL ).
    LS_JSDOINFO-LFART       = PV_LFART.
    LS_JSDOINFO-WADAT       = PV_WADAT.
    LS_JSDOINFO-VGBEL       = LS_DATA-VGBEL.
    LS_JSDOINFO-VGPOS       = LS_DATA-VGPOS.
    LS_JSDOINFO-ZZVBELN_JS  = LS_DATA-ZZVBELN_JS.
    LS_JSDOINFO-ZZPOSNR_JS  = LS_DATA-ZZPOSNR_JS.
    APPEND LS_JSDOINFO TO LT_JSDOINFO.

  ENDLOOP.

*-BAPI
  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      STATUS_BUFF_INIT = GC_X.

  IF LT_JSDOINFO[] IS NOT INITIAL.
*   1. FM 'RV_DELIVERY_CREATE' 에서 IMPORT( ENHANCEMENT 'ZGTSD_EH_RV_DELIVERY_CREATE')
*   2. USER-EXIT : SAPMV50A=>PERFORM userexit_save_document_prepare
*                          =>PERFORM USEREXIT_SAVE_DOCUMENT_PRE0012. 에서 IMPORT
    EXPORT LT_JSDOINFO TO MEMORY ID 'ZGTSDR2010_NDC'.
  ENDIF.

  CALL FUNCTION 'BAPI_DELIVERYPROCESSING_EXEC'
    EXPORTING
      TECHN_CONTROL = GS_TECHN_CONTROL
    TABLES
      REQUEST       = GT_REQUEST
      CREATEDITEMS  = GT_CREATEDITEMS
      RETURN        = GT_RETURN.

  FREE MEMORY ID 'ZGTSDR2010_NDC'.

  IF GT_CREATEDITEMS[] IS NOT INITIAL.
    __BAPI_TRANSACTION_COMMIT.

    "처리 결과
    DATA(LV_DELIVERY) = VALUE #( GT_CREATEDITEMS[ 1 ]-DOCUMENT_NUMB OPTIONAL ).
    PERFORM SET_CREATED_DO TABLES PT_DATA
                            USING LV_DELIVERY.

  ELSE.
    __BAPI_TRANSACTION_ROLLBACK.
    LS_TEMP-MTYPE = GC_E.
    LOOP AT GT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
      IF LS_TEMP-MSG IS INITIAL.
        LS_TEMP-MSG = LS_RETURN-MESSAGE.
      ELSE.
        LS_TEMP-MSG = |{ LS_TEMP-MSG }/{ LS_RETURN-MESSAGE }|.
      ENDIF.
    ENDLOOP.
    MODIFY PT_DATA FROM LS_TEMP TRANSPORTING MTYPE MSG WHERE MTYPE NE GC_E.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CREATED_DO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DATA
*&      --> LV_DELIVERY
*&---------------------------------------------------------------------*
FORM SET_CREATED_DO  TABLES   PT_DATA STRUCTURE ZGTSDS0031
                     USING    PV_DELIVERY.
  DATA: LS_TEMP TYPE ZGTSDS0031.
  CLEAR:GT_LIPS[].

  DO 5 TIMES.
    SELECT *
      FROM LIPS
     WHERE VBELN EQ @PV_DELIVERY
      INTO TABLE @GT_LIPS.
    IF SY-SUBRC EQ 0.
      EXIT.
    ELSE.
      WAIT UP TO '0.5' SECONDS.
    ENDIF.
  ENDDO.

  IF GT_LIPS[] IS INITIAL.
    LS_TEMP-MTYPE = GC_E.
    LS_TEMP-MSG   = TEXT-M39.
    MODIFY PT_DATA FROM LS_TEMP TRANSPORTING MTYPE MSG WHERE MTYPE EQ SPACE.
    EXIT.
  ENDIF.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    DATA(LS_LIPS) = VALUE #( GT_LIPS[ VGBEL = <FS_DATA>-VGBEL VGPOS = <FS_DATA>-VGPOS
                                        ZZVBELN_JS = <FS_DATA>-ZZVBELN_JS ZZPOSNR_JS = <FS_DATA>-ZZPOSNR_JS ]
                                      OPTIONAL ).
    IF LS_LIPS IS NOT INITIAL.
      <FS_DATA>-MTYPE = GC_S.<FS_DATA>-MSG = TEXT-S01.
      <FS_DATA>-VBELN = LS_LIPS-VBELN.
      <FS_DATA>-POSNR = LS_LIPS-POSNR.
    ELSE.
      <FS_DATA>-MTYPE = GC_S.<FS_DATA>-MSG = TEXT-M07.
    ENDIF.
    CLEAR LS_LIPS.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JS_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_DATA
*&---------------------------------------------------------------------*
FORM CHECK_JS_GI  TABLES   PT_DATA STRUCTURE ZGTSDS0032.
  DATA: LV_ERR(1),
        LV_MSG(200).

  DATA(LT_TEMP) = PT_DATA[].
  DELETE LT_TEMP WHERE VBELN IS INITIAL.
  SORT LT_TEMP BY VBELN.

*-LIKP
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VBELN,WADAT_IST,WBSTK
      FROM LIKP
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VBELN EQ @LT_TEMP-VBELN
      INTO TABLE @DATA(LT_LIKP).
    SORT LT_LIKP BY VBELN.
  ENDIF.

*-CHECK
  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    CLEAR:LV_ERR,LV_MSG.

    "필수필드
    IF <FS_DATA>-VBELN IS INITIAL.
      LV_ERR = GC_X.
      LV_MSG = TEXT-010.
    ENDIF.

    IF <FS_DATA>-WADAT_IST IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-011.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-011 }|.
      ENDIF.
    ENDIF.
    IF LV_ERR IS NOT INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      MESSAGE S007 WITH LV_MSG INTO <FS_DATA>-MSG.
      CONTINUE.
    ENDIF.

*    "ZGTSDT9110-ZZJS_STATUS
*    SELECT SINGLE B~ZZJS_STATUS
*      FROM LIPS AS A INNER JOIN ZGTSDT9110 AS B
*                     ON A~ZZVBELN_JS = B~VBELN
*     WHERE A~VBELN EQ @<FS_DATA>-VBELN
*       INTO @DATA(LV_STATUS).
*    IF LV_STATUS NE GC_J. "DO에 배치지정 - 'J'
*      <FS_DATA>-MTYPE = GC_E.
*      <FS_DATA>-MSG   = TEXT-M55.
*
*      CLEAR LV_STATUS.
*      CONTINUE.
*    ENDIF.


    "납품문서
    DATA(LS_LIKP) = VALUE #( LT_LIKP[ VBELN = <FS_DATA>-VBELN ] OPTIONAL ).
    IF LS_LIKP IS INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      <FS_DATA>-MSG   = TEXT-M42.
    ENDIF.

    IF <FS_DATA>-MTYPE NE GC_E.
      IF LS_LIKP-WBSTK EQ GC_C. "출고완료
        <FS_DATA>-MTYPE = GC_S.
        <FS_DATA>-MSG   = TEXT-M43.
      ENDIF.
    ENDIF.

    CLEAR:LS_LIKP.
*    CLEAR:LV_STATUS.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_JS_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_DATA
*&---------------------------------------------------------------------*
FORM RUN_JS_GI  TABLES   PT_DATA STRUCTURE ZGTSDS0032.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE MTYPE EQ SPACE.
    "PGI
    PERFORM DO_PGI_PROC CHANGING <FS_DATA>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_PGI_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_DATA>
*&---------------------------------------------------------------------*
FORM DO_PGI_PROC  CHANGING PS_DATA TYPE ZGTSDS0032.
  DATA: LV_STEP TYPE I.
  DATA: LV_MESSAGE(220).

  FIELD-SYMBOLS: <FS_EMKPF> TYPE EMKPF.

*-INIT BAPI PARAMETERS
  CLEAR:GS_VBKOK,GT_VBPOK[],GT_PROT[].

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @DATA(LT_LIPS).


*-BAPI PARAMETER 구성

  DATA(LT_XLIPS) = LT_LIPS[].
  DELETE LT_XLIPS WHERE UECHA NE '000000'.

  "HEADER
  GS_VBKOK-VBELN_VL  = PS_DATA-VBELN.
  GS_VBKOK-WABUC     = GC_X.
  GS_VBKOK-KOMUE     = GC_X.
  GS_VBKOK-WADAT_IST = PS_DATA-WADAT_IST.

  "ITEM
  LOOP AT LT_XLIPS INTO DATA(LS_XLIPS).

    IF LS_XLIPS-XCHAR EQ GC_X.  "BATCH
      DATA(LV_CNT) = REDUCE I( INIT LV_I TYPE I
                                FOR LS_TEMP IN LT_LIPS
                                 WHERE ( VBELN = LS_XLIPS-VBELN AND UECHA = LS_XLIPS-POSNR )
                                NEXT LV_I = LV_I + 1   ).
      IF LV_CNT = 0.
        CLEAR:GS_VBPOK.
        GS_VBPOK-VBELN_VL  = LS_XLIPS-VBELN.
        GS_VBPOK-POSNR_VL  = LS_XLIPS-POSNR.
        GS_VBPOK-VBELN     = LS_XLIPS-VGBEL.
        GS_VBPOK-POSNN     = LS_XLIPS-VGPOS.
        GS_VBPOK-MATNR     = LS_XLIPS-MATNR.
        GS_VBPOK-WERKS     = LS_XLIPS-WERKS.
        GS_VBPOK-LGORT     = LS_XLIPS-LGORT.
        IF LS_XLIPS-CHARG IS NOT INITIAL.
          GS_VBPOK-CHARG     = LS_XLIPS-CHARG.
        ENDIF.
        GS_VBPOK-PIKMG     = LS_XLIPS-LFIMG.
        GS_VBPOK-LFIMG     = LS_XLIPS-LFIMG.
        APPEND GS_VBPOK TO GT_VBPOK.

      ELSE.
        CLEAR:LV_STEP.
        LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA = LS_XLIPS-POSNR.
          LV_STEP = LV_STEP + 1.

          "상위 MAIN ITEM
          IF LV_STEP EQ 1.
            CLEAR:GS_VBPOK.
            GS_VBPOK-VBELN_VL  = LS_XLIPS-VBELN.
            GS_VBPOK-POSNR_VL  = LS_XLIPS-POSNR.
            GS_VBPOK-VBELN     = LS_XLIPS-VGBEL.
            GS_VBPOK-POSNN     = LS_XLIPS-VGPOS.
            GS_VBPOK-MATNR     = LS_XLIPS-MATNR.
            GS_VBPOK-WERKS     = LS_XLIPS-WERKS.
            GS_VBPOK-LGORT     = LS_XLIPS-LGORT.
            IF LS_XLIPS-CHARG IS NOT INITIAL.
              GS_VBPOK-CHARG     = LS_XLIPS-CHARG.
            ENDIF.
            GS_VBPOK-PIKMG     = LS_XLIPS-LFIMG.
            GS_VBPOK-LFIMG     = LS_XLIPS-LFIMG.
            APPEND GS_VBPOK TO GT_VBPOK.

          ENDIF.

          "하위 BATCH ITEM
          CLEAR:GS_VBPOK.
          GS_VBPOK-VBELN_VL  = LS_LIPS-VBELN.
          GS_VBPOK-POSNR_VL  = LS_LIPS-POSNR.
          GS_VBPOK-VBELN     = LS_LIPS-VGBEL.
          GS_VBPOK-POSNN     = LS_LIPS-VGPOS.
          GS_VBPOK-MATNR     = LS_LIPS-MATNR.
          GS_VBPOK-WERKS     = LS_LIPS-WERKS.
          GS_VBPOK-LGORT     = LS_LIPS-LGORT.
          IF LS_LIPS-CHARG IS NOT INITIAL.
            GS_VBPOK-CHARG     = LS_LIPS-CHARG.
          ENDIF.
          GS_VBPOK-PIKMG     = LS_LIPS-LFIMG.
          GS_VBPOK-LFIMG     = LS_LIPS-LFIMG.
          APPEND GS_VBPOK TO GT_VBPOK.

        ENDLOOP.

      ENDIF.

    ELSE.
      "NON BATCH 관리
      CLEAR:GS_VBPOK.
      GS_VBPOK-VBELN_VL  = LS_XLIPS-VBELN.
      GS_VBPOK-POSNR_VL  = LS_XLIPS-POSNR.
      GS_VBPOK-VBELN     = LS_XLIPS-VGBEL.
      GS_VBPOK-POSNN     = LS_XLIPS-VGPOS.
      GS_VBPOK-MATNR     = LS_XLIPS-MATNR.
      GS_VBPOK-WERKS     = LS_XLIPS-WERKS.
      GS_VBPOK-LGORT     = LS_XLIPS-LGORT.
      GS_VBPOK-PIKMG     = LS_XLIPS-LFIMG.
      GS_VBPOK-LFIMG     = LS_XLIPS-LFIMG.
      APPEND GS_VBPOK TO GT_VBPOK.

    ENDIF.

    CLEAR LV_CNT.
  ENDLOOP.


*-츌고처리 수행
  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      VBKOK_WA               = GS_VBKOK
      SYNCHRON               = GC_X
      COMMIT                 = ABAP_FALSE
      DELIVERY               = PS_DATA-VBELN
      UPDATE_PICKING         = GC_X
      NICHT_SPERREN_1        = GC_Y
      IF_ERROR_MESSAGES_SEND = ' '
    TABLES
      VBPOK_TAB              = GT_VBPOK
      PROT                   = GT_PROT.

  ASSIGN ('(SAPLV50S)EMKPF') TO <FS_EMKPF>.

  IF GT_PROT[] IS INITIAL.
    IF <FS_EMKPF>-MBLNR IS NOT INITIAL.
      __BAPI_TRANSACTION_COMMIT.

      PS_DATA-MTYPE = GC_S.
      PS_DATA-MSG   = TEXT-S01.

    ELSE.
      __BAPI_TRANSACTION_ROLLBACK.

      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M26.
    ENDIF.

  ELSE.
    LOOP AT GT_PROT INTO DATA(LS_PROT) WHERE MSGTY CA 'AE'.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      PS_DATA-MTYPE = GC_E.

      LOOP AT GT_PROT INTO LS_PROT WHERE MSGTY CA 'AE'.
        CLEAR: LV_MESSAGE.
        PERFORM MESSAGE_BUILD USING LS_PROT-MSGID
                                    LS_PROT-MSGNO
                                    LS_PROT-MSGV1
                                    LS_PROT-MSGV2
                                    LS_PROT-MSGV3
                                    LS_PROT-MSGV4
                                    LV_MESSAGE.
        IF PS_DATA-MSG IS INITIAL.
          PS_DATA-MSG = LV_MESSAGE.
        ELSE.
          PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MESSAGE }|.
        ENDIF.
      ENDLOOP.

    ELSE.
      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M26.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JS_BILLING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_DATA
*&---------------------------------------------------------------------*
FORM CHECK_JS_BILLING  TABLES   PT_DATA STRUCTURE ZGTSDS0033.
  DATA: LV_ERR(1),
        LV_MSG(200).

  DATA(LT_TEMP) = PT_DATA[].
  DELETE LT_TEMP WHERE VBELN IS INITIAL.
  SORT LT_TEMP BY VBELN.

*-LIKP
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT *
      FROM LIKP
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VBELN EQ @LT_TEMP-VBELN
      INTO TABLE @DATA(LT_LIKP).
    SORT LT_LIKP BY VBELN.
  ENDIF.

*-CHECK
  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    CLEAR:LV_ERR,LV_MSG.

    "필수필드
    IF <FS_DATA>-VBELN IS INITIAL.
      LV_ERR = GC_X.
      LV_MSG = TEXT-010.
    ENDIF.

    IF <FS_DATA>-WADAT_IST IS INITIAL.
      LV_ERR = GC_X.
      IF LV_MSG IS INITIAL.
        LV_MSG = TEXT-011.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ TEXT-011 }|.
      ENDIF.
    ENDIF.
    IF LV_ERR IS NOT INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      MESSAGE S007 WITH LV_MSG INTO <FS_DATA>-MSG.
      CONTINUE.
    ENDIF.

    "납품문서
    DATA(LS_LIKP) = VALUE #( LT_LIKP[ VBELN = <FS_DATA>-VBELN ] OPTIONAL ).
    IF LS_LIKP IS INITIAL.
      <FS_DATA>-MTYPE = GC_E.
      <FS_DATA>-MSG   = TEXT-M42.
    ENDIF.

    IF <FS_DATA>-MTYPE NE GC_E.
      IF LS_LIKP-WBSTK NE GC_C. "출고완료
        <FS_DATA>-MTYPE = GC_E.
        <FS_DATA>-MSG   = TEXT-M45.
      ENDIF.
    ENDIF.

    IF <FS_DATA>-MTYPE NE GC_E.
      IF LS_LIKP-FKSTK EQ GC_C. "청구완료
        <FS_DATA>-MTYPE = GC_S.
        <FS_DATA>-MSG   = TEXT-M46.
      ENDIF.
    ENDIF.

    CLEAR:LS_LIKP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_JS_BILLING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_DATA
*&---------------------------------------------------------------------*
FORM RUN_JS_BILLING  TABLES   PT_DATA STRUCTURE ZGTSDS0033.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE MTYPE EQ SPACE.
    "청구문서 생성
    PERFORM DO_BILLING_PROC CHANGING <FS_DATA>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_BILLING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_DATA>
*&---------------------------------------------------------------------*
FORM DO_BILLING_PROC  CHANGING PS_DATA TYPE ZGTSDS0033.
  DATA: LV_MESSAGE(220).
  DATA: L_MAECHUL.
  DATA: LV_FKDAT TYPE VBRK-FKDAT.

*-INIT BAPI PARAMETERS
  CLEAR:GT_BDATAIN[],GT_SUCCESS[],GT_RETURN[].

*-LIKP+LIPS
  SELECT A~VBELN,A~POSNR,A~UECHA,A~MATNR,A~WERKS,A~LGORT,A~CHARG,A~LFIMG,A~VRKME,
         A~ZZVBELN_JS,
         B~WADAT_IST,B~VBTYP,B~FKARV
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
   WHERE A~VBELN EQ @PS_DATA-VBELN
    INTO TABLE @DATA(LT_LIPS).

  "청구일
  LV_FKDAT = VALUE #( LT_LIPS[ 1 ]-WADAT_IST OPTIONAL ).

*-ZGTSDT9110
  DATA(LV_VBELN_ORGIN) = VALUE #( LT_LIPS[ 1 ]-ZZVBELN_JS OPTIONAL ).
  IF LV_VBELN_ORGIN IS NOT INITIAL.
    SELECT SINGLE *
      FROM ZGTSDT9110
     WHERE VBELN EQ @LV_VBELN_ORGIN
      INTO @DATA(LS_ZGTSDT9110).
    IF SY-SUBRC EQ 0.
      LV_FKDAT = LS_ZGTSDT9110-FKDAT_M.
    ENDIF.
  ENDIF.

*-BAPI PARAMETER 구성
  DATA(LT_LIST) = LT_LIPS[].
  DELETE LT_LIST WHERE UECHA NE '000000'.
  SORT LT_LIST BY POSNR.

  LOOP AT LT_LIST INTO DATA(LS_LIST).
    CLEAR:GS_BDATAIN.

    GS_BDATAIN-REF_DOC         = LS_LIST-VBELN.
    GS_BDATAIN-REF_ITEM        = LS_LIST-POSNR.
    GS_BDATAIN-BILL_DATE       = LV_FKDAT.        "PS_DATA-WADAT_IST.
    GS_BDATAIN-REF_DOC_CA_LONG = LS_LIST-VBTYP.

    GS_BDATAIN-REQ_QTY = REDUCE KWMENG( INIT LV_QTY TYPE LFIMG
                                         FOR LS_LIPS IN LT_LIPS
                                          WHERE ( POSNR = LS_LIST-POSNR OR
                                                  UECHA = LS_LIST-POSNR    )
                                        NEXT LV_QTY = LV_QTY + LS_LIPS-LFIMG  ).

    APPEND GS_BDATAIN TO GT_BDATAIN.
  ENDLOOP.

*-BAPI CALL

* VOFM 청구복사전송 FORM DATEN_KOPIEREN_907 에서 IMPORT
  L_MAECHUL = 'X'.
  EXPORT L_MAECHUL TO MEMORY ID 'ZSD013'.

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
    TABLES
      BILLINGDATAIN = GT_BDATAIN
      RETURN        = GT_RETURN
      SUCCESS       = GT_SUCCESS.

  FREE MEMORY ID 'ZSD013'.

  LOOP AT GT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      LV_MESSAGE = |{ LV_MESSAGE }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG = LV_MESSAGE.

  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    "청구문서
    PS_DATA-VBELN_VF = VALUE #( GT_SUCCESS[ 1 ]-BILL_DOC OPTIONAL ).

    PS_DATA-MTYPE = GC_S.

    CLEAR LS_RETURN.
    READ TABLE GT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_S
                                                   ID = 'VF'
                                               NUMBER = '311'.
    IF SY-SUBRC EQ 0.
      PS_DATA-MSG   = LS_RETURN-MESSAGE.
    ELSE.
      PS_DATA-MSG   = TEXT-S01.
    ENDIF.
  ENDIF.
ENDFORM.

FORM CANCEL_DO CHANGING PS_DATA TYPE ZGTSDS0021.
  DATA: LV_VBELN TYPE LIKP-VBELN,
        LV_BUDAT TYPE MKPF-BUDAT,
        LV_TCODE TYPE SY-TCODE,
        LV_VBTYP TYPE LIKP-VBTYP.
  DATA: LT_MESG  TYPE TABLE OF MESG,
        LV_MBLNR TYPE MBLNR.
  DATA: LV_MSG(200).

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-출고 완료
  IF LS_LIKP-WBSTK NE GC_C.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M08.
    EXIT.
  ENDIF.

*-ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_A. "지정
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M47.
    EXIT.
  ENDIF.

*-ZGTSDT9120-ZZJS_ASN_STS_I
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN          EQ @PS_DATA-VBELN
     AND ZZJS_ASN_STS_I NE @GC_C
     AND LOEVM          EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT9120).
  IF LT_ZGTSDT9120[] IS NOT INITIAL.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M48.
    EXIT.
  ENDIF.

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
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.

  ELSE.
    PS_DATA-MTYPE = GC_E.
    LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AEX'.
      IF LV_MSG IS INITIAL.
        LV_MSG = LS_MESG-TEXT.
      ELSE.
        LV_MSG = |{ LV_MSG }/{ LS_MESG-TEXT }|.
      ENDIF.
    ENDLOOP.


    PS_DATA-MSG = LV_MSG.
  ENDIF.

ENDFORM.

FORM DELETE_ITEM_BATCH_SPLIT CHANGING PS_DATA TYPE ZGTSDS0025.
  DATA: LT_ITEM  TYPE TABLE OF ZGTSDS0023,
        LS_ITEM  TYPE ZGTSDS0023,
        LT_BATCH TYPE TABLE OF ZGTSDS0024,
        LS_BATCH TYPE ZGTSDS0024,
        LV_TYPE  TYPE BAPI_MTYPE,
        LV_MSG   TYPE BAPI_MSG.

  DATA: LV_MESSAGE(200).

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_C. "납품보류 설정
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M49.
    EXIT.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @DATA(LT_LIPS).
  SORT LT_LIPS BY POSNR UECHA.

  LOOP AT LT_LIPS INTO DATA(LS_TEMP) WHERE UECHA NE '000000'.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-M11.
    EXIT.
  ENDIF.

*-배치분할 삭제 데이터 구성
  DATA(LT_MAIN) = LT_LIPS[].
  DELETE LT_MAIN WHERE UECHA NE '000000'.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    CLEAR:LS_ITEM.
    LS_ITEM-VBELN = LS_MAIN-VBELN.
    LS_ITEM-POSNR = LS_MAIN-POSNR.
    LS_ITEM-MATNR = LS_MAIN-MATNR.
    LS_ITEM-WERKS = LS_MAIN-WERKS.
    LS_ITEM-LGORT = LS_MAIN-LGORT.
    LS_ITEM-CHARG = LS_MAIN-CHARG.
    LS_ITEM-VRKME = LS_MAIN-VRKME.
    LS_ITEM-UPDKZ = GC_U.

    "BATCH 분할 라인
    IF NOT ( LINE_EXISTS( LT_LIPS[ UECHA = LS_MAIN-POSNR ] ) ).
      CONTINUE.
    ENDIF.

    LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA = LS_MAIN-POSNR.
      CLEAR:LS_BATCH.
      LS_BATCH-VBELN = LS_LIPS-VBELN.
      LS_BATCH-UECHA = LS_LIPS-UECHA.
      LS_BATCH-POSNR = LS_LIPS-POSNR.
      LS_BATCH-MATNR = LS_LIPS-MATNR.
      LS_BATCH-WERKS = LS_LIPS-WERKS.
      LS_BATCH-LGORT = LS_LIPS-LGORT.
      LS_BATCH-CHARG = LS_LIPS-CHARG.
      LS_BATCH-LFIMG = LS_LIPS-LFIMG.
      LS_BATCH-UPDKZ = GC_D.

      LS_ITEM-LFIMG = LS_ITEM-LFIMG + LS_BATCH-LFIMG.

      APPEND LS_BATCH TO LT_BATCH.
    ENDLOOP.

    APPEND LS_ITEM TO LT_ITEM.
  ENDLOOP.

*-배치분할 라인 일괄 삭제
  CALL FUNCTION 'ZGTSD_DO_BATCH_SPLIT'
    IMPORTING
      E_TYPE   = LV_TYPE
      E_MSG    = LV_MSG
    TABLES
      IT_ITEM  = LT_ITEM
      IT_BATCH = LT_BATCH.

  IF LV_TYPE EQ GC_S.
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.

  ELSE.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = LV_MSG.
  ENDIF.

ENDFORM.

FORM CHECK_JS_GOODSMVT_CREATE TABLES PT_DATA STRUCTURE ZGTSDS0029.
  DATA: LT_MAIN TYPE TABLE OF ZGTSDS0029,
        LS_DATA TYPE ZGTSDS0029.
  DATA: LV_CNT    TYPE I,
        LV_CHK(1).

  LT_MAIN[] = CORRESPONDING #( PT_DATA[] ).

  SORT LT_MAIN BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN POSNR.

  LS_DATA-MTYPE = GC_E.
  LS_DATA-MSG   = TEXT-M28.


  LOOP AT LT_MAIN INTO DATA(LS_MAIN) GROUP BY ( VBELN = LS_MAIN-VBELN )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).

*-01. 중복라인 체크
    CLEAR LV_CHK.
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      CLEAR LV_CNT.
      LOOP AT PT_DATA INTO DATA(LS_TEMP) WHERE VBELN = <FS_LINE>-VBELN
                                           AND POSNR = <FS_LINE>-POSNR.
        LV_CNT = LV_CNT + 1.
      ENDLOOP.
      IF LV_CNT > 1.
        LV_CHK = GC_X.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_CHK EQ GC_X.
      MODIFY PT_DATA FROM LS_DATA TRANSPORTING MTYPE MSG WHERE VBELN = <FS_LINE>-VBELN.
      CONTINUE.
    ENDIF.

  ENDLOOP.

*-02. 입력 데이터 vs ZGTSDT9120 비교
  CLEAR LT_MAIN[].
  LT_MAIN[] = CORRESPONDING #( PT_DATA[] ).
  DELETE LT_MAIN WHERE MTYPE EQ GC_E.

  CHECK LT_MAIN[] IS NOT INITIAL.
  SORT LT_MAIN BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN.
  CLEAR:GT_LIKP[],GT_LIPS[],GT_ZGTSDT9110[],GT_ZGTSDT9120[].

*-LIKP
  SELECT *
    FROM LIKP
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
    INTO TABLE @GT_LIKP.

*-LIPS
  SELECT *
    FROM LIPS
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
    INTO TABLE @GT_LIPS.
  SORT GT_LIPS BY VBELN POSNR.

*-ZGTSDT9110
  SELECT *
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9110.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.

  LOOP AT LT_MAIN INTO LS_MAIN.
*   ZGTSDT9110-ZZJS_STATUS
    CLEAR LS_DATA.
    DATA(LS_ZGTSDT9110) = VALUE #( GT_ZGTSDT9110[ VBELN = LS_MAIN-VBELN ] OPTIONAL ).
    IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_G. "서비스 출고
      LS_DATA-MTYPE = GC_E.
      LS_DATA-MSG   = TEXT-M53.
    ENDIF.
    IF LS_DATA-MTYPE = GC_E.
      CLEAR LS_ZGTSDT9110.
      MODIFY PT_DATA FROM LS_DATA TRANSPORTING MTYPE MSG WHERE VBELN = LS_MAIN-VBELN
                                                           AND MTYPE NE GC_E.
      CONTINUE.
    ENDIF.

*   ZGTSDT9120 존재 여부 체크 => DO번호 전체 에러 처리
    CLEAR LS_DATA.
    LOOP AT PT_DATA INTO DATA(LS_ITEM) WHERE VBELN EQ LS_MAIN-VBELN
                                         AND MTYPE NE GC_E.
      DATA(LS_ZGTSDT9120) = VALUE #( GT_ZGTSDT9120[ VBELN = LS_ITEM-VBELN POSNR = LS_ITEM-POSNR ] OPTIONAL ).
      IF LS_ZGTSDT9120 IS INITIAL.
        LS_DATA-MTYPE = GC_E.
        MESSAGE S207 WITH LS_ITEM-VBELN LS_ITEM-POSNR INTO LS_DATA-MSG.
        EXIT.
      ENDIF.
      CLEAR: LS_ZGTSDT9120.
    ENDLOOP.
    IF LS_DATA-MTYPE = GC_E.
      MODIFY PT_DATA FROM LS_DATA TRANSPORTING MTYPE MSG WHERE VBELN = LS_MAIN-VBELN
                                                           AND MTYPE NE GC_E.
      CONTINUE.
    ENDIF.
*   기처리 여부
    LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE VBELN EQ LS_MAIN-VBELN
                                                        AND MTYPE NE GC_E.
      CLEAR LS_ZGTSDT9120.
      LS_ZGTSDT9120 = VALUE #( GT_ZGTSDT9120[ VBELN = LS_ITEM-VBELN POSNR = LS_ITEM-POSNR ] OPTIONAL ).
      IF LS_ZGTSDT9120-ZZJS_MVT EQ GC_X AND LS_ZGTSDT9120-MBLNR IS NOT INITIAL.
        <FS_DATA>-MTYPE = GC_S.
        <FS_DATA>-MSG   = |{ TEXT-M29 }({ LS_ZGTSDT9120-MBLNR }/{ LS_ZGTSDT9120-MJAHR })|.
      ENDIF.
    ENDLOOP.

    CLEAR: LS_ZGTSDT9120.
    CLEAR: LS_ZGTSDT9110.
  ENDLOOP.


ENDFORM.

FORM RUN_JS_GOODSMVT_CREATE TABLES PT_DATA STRUCTURE ZGTSDS0029.
  DATA: LT_MAIN TYPE TABLE OF ZGTSDS0029.
  DATA: LV_MSG(200).

  LT_MAIN[] = CORRESPONDING #( PT_DATA[] ).

  DELETE LT_MAIN WHERE MTYPE IS NOT INITIAL.
  SORT LT_MAIN BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN POSNR.

  CHECK LT_MAIN[] IS NOT INITIAL.
  CLEAR:GT_LIKP[],GT_LIPS[],GT_ZGTSDT9110[],GT_ZGTSDT9120[].

*-ZGTSDT9110
  SELECT *
    FROM ZGTSDT9110
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9110.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
     FOR ALL ENTRIES IN @LT_MAIN
   WHERE VBELN EQ @LT_MAIN-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.

  SORT PT_DATA BY VBELN POSNR.

  "납품문서별로 자재이동
  LOOP AT PT_DATA INTO DATA(LS_DATA) WHERE MTYPE EQ SPACE GROUP BY ( VBELN = LS_DATA-VBELN )
                                                          ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).

    CLEAR:GS_GOODSMVT_HEADER,GS_GOODSMVT_CODE,GS_GOODSMVT_HEADRET,
          GT_GOODSMVT_ITEM[],GT_RETURN[].
    CLEAR:LV_MSG.

    "ITEM 구성
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
      IF LINE_EXISTS( GT_ZGTSDT9120[ VBELN = <FS_ITEM>-VBELN UECHA = <FS_ITEM>-POSNR ] ).
        PERFORM BUILD_BAPI_ITEMS USING <FS_ITEM> GC_A.
      ELSE.
        PERFORM BUILD_BAPI_ITEMS USING <FS_ITEM> GC_B.
      ENDIF.
    ENDLOOP.

    "HEADER
    GS_GOODSMVT_HEADER-PSTNG_DATE = VALUE #( GT_ZGTSDT9110[ VBELN = <FS_ITEM>-VBELN ]-WADAT_IST OPTIONAL ).
    GS_GOODSMVT_HEADER-DOC_DATE   = SY-DATLO.

    GS_GOODSMVT_CODE-GM_CODE      = GC_CODE_04.

    "BAPI
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GS_GOODSMVT_HEADER
        GOODSMVT_CODE    = GS_GOODSMVT_CODE
      IMPORTING
        GOODSMVT_HEADRET = GS_GOODSMVT_HEADRET
      TABLES
        GOODSMVT_ITEM    = GT_GOODSMVT_ITEM
        RETURN           = GT_RETURN.
    IF GS_GOODSMVT_HEADRET-MAT_DOC IS NOT INITIAL.
      LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_ITEM>.
        "처리결과
        <FS_ITEM>-MTYPE = GC_S.
        <FS_ITEM>-MSG   = TEXT-S01.
        <FS_ITEM>-MBLNR = GS_GOODSMVT_HEADRET-MAT_DOC.

        "UPDATE ZGTSDT9120
        UPDATE ZGTSDT9120 SET ZZJS_MVT = GC_X
                              MBLNR    = GS_GOODSMVT_HEADRET-MAT_DOC
                              MJAHR    = GS_GOODSMVT_HEADRET-DOC_YEAR
                              MBLNR_C  = SPACE
                              MJAHR_C  = '0000'
                        WHERE ( VBELN EQ <FS_ITEM>-VBELN AND
                                POSNR EQ <FS_ITEM>-POSNR     )
                           OR ( VBELN EQ <FS_ITEM>-VBELN AND
                                UECHA EQ <FS_ITEM>-POSNR     ).
      ENDLOOP.
      __BAPI_TRANSACTION_COMMIT.

    ELSE.
      __BAPI_TRANSACTION_ROLLBACK.
      LOOP AT GT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AEX'.
        IF LV_MSG IS INITIAL.
          LV_MSG = LS_RETURN-MESSAGE.
        ELSE.
          LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
        ENDIF.
      ENDLOOP.

      LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_ITEM>.
        "처리결과
        <FS_ITEM>-MTYPE = GC_E.
        IF LV_MSG IS NOT INITIAL.
          <FS_ITEM>-MSG   = LV_MSG.
        ELSE.
          <FS_ITEM>-MSG   = TEXT-M30.
        ENDIF.
      ENDLOOP.

    ENDIF.


  ENDLOOP.
ENDFORM.
FORM BUILD_BAPI_ITEMS USING PS_DATA TYPE  ZGTSDS0029
                            PV_STEP.


  CASE PV_STEP.
    WHEN GC_A.  "BATCH SPLIT
      LOOP AT GT_ZGTSDT9120 INTO DATA(LS_ITEM) WHERE VBELN = PS_DATA-VBELN
                                                 AND UECHA = PS_DATA-POSNR.
        CLEAR:GS_GOODSMVT_ITEM.
        GS_GOODSMVT_ITEM-MATERIAL_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-PLANT         = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-STGE_LOC      = LS_ITEM-LGORT.
        GS_GOODSMVT_ITEM-BATCH         = LS_ITEM-CHARG.
        GS_GOODSMVT_ITEM-MOVE_TYPE     = GC_BWART_311.
        GS_GOODSMVT_ITEM-SPEC_STOCK    = GC_E.
        GS_GOODSMVT_ITEM-SALES_ORD     = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-S_ORD_ITEM    = LS_ITEM-VGPOS.
        GS_GOODSMVT_ITEM-ENTRY_QNT     = LS_ITEM-LFIMG.
        GS_GOODSMVT_ITEM-ENTRY_UOM     = LS_ITEM-VRKME.

        GS_GOODSMVT_ITEM-MOVE_MAT_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-MOVE_PLANT    = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-MOVE_STLOC    = GC_LGORT_3499.
        GS_GOODSMVT_ITEM-MOVE_BATCH    = LS_ITEM-CHARG.

        GS_GOODSMVT_ITEM-VAL_SALES_ORD  = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-VAL_S_ORD_ITEM = LS_ITEM-VGPOS.

        GS_GOODSMVT_ITEM-DELIV_NUMB     = LS_ITEM-VBELN.
        GS_GOODSMVT_ITEM-DELIV_ITEM     = LS_ITEM-UECHA.

        GS_GOODSMVT_ITEM-ITEM_TEXT      = TEXT-012.

        APPEND GS_GOODSMVT_ITEM TO GT_GOODSMVT_ITEM.
      ENDLOOP.

    WHEN GC_B.
      LOOP AT GT_ZGTSDT9120 INTO LS_ITEM WHERE VBELN = PS_DATA-VBELN
                                           AND POSNR = PS_DATA-POSNR.
        CLEAR:GS_GOODSMVT_ITEM.
        GS_GOODSMVT_ITEM-MATERIAL_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-PLANT         = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-STGE_LOC      = LS_ITEM-LGORT.
        GS_GOODSMVT_ITEM-BATCH         = LS_ITEM-CHARG.
        GS_GOODSMVT_ITEM-MOVE_TYPE     = GC_BWART_311.
        GS_GOODSMVT_ITEM-SPEC_STOCK    = GC_E.
        GS_GOODSMVT_ITEM-SALES_ORD     = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-S_ORD_ITEM    = LS_ITEM-VGPOS.
        GS_GOODSMVT_ITEM-ENTRY_QNT     = LS_ITEM-LFIMG.
        GS_GOODSMVT_ITEM-ENTRY_UOM     = LS_ITEM-VRKME.

        GS_GOODSMVT_ITEM-MOVE_MAT_LONG = LS_ITEM-MATNR.
        GS_GOODSMVT_ITEM-MOVE_PLANT    = LS_ITEM-WERKS.
        GS_GOODSMVT_ITEM-MOVE_STLOC    = GC_LGORT_3499.
        GS_GOODSMVT_ITEM-MOVE_BATCH    = LS_ITEM-CHARG.

        GS_GOODSMVT_ITEM-VAL_SALES_ORD  = LS_ITEM-VGBEL.
        GS_GOODSMVT_ITEM-VAL_S_ORD_ITEM = LS_ITEM-VGPOS.

        GS_GOODSMVT_ITEM-DELIV_NUMB     = LS_ITEM-VBELN.
        GS_GOODSMVT_ITEM-DELIV_ITEM     = LS_ITEM-POSNR.

        GS_GOODSMVT_ITEM-ITEM_TEXT      = TEXT-012.

        APPEND GS_GOODSMVT_ITEM TO GT_GOODSMVT_ITEM.
      ENDLOOP.

  ENDCASE.
ENDFORM.

FORM SERVICE_GI_JS CHANGING PS_DATA TYPE ZGTSDS0028.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.
  DATA: LV_MESSAGE(220).

  CLEAR:GS_LIKP,GT_LIPS[],GT_ZGTSDT9110[],GT_ZGTSDT9120[].

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @GS_LIKP.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @GT_LIPS.
  SORT GT_LIPS BY POSNR.

*-ZGTSDT9110
  SELECT *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9110.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M18.
    EXIT.
  ENDIF.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M18.
    EXIT.
  ENDIF.

  DATA(LS_ZGTSDT9110) = VALUE #( GT_ZGTSDT9110[ 1 ] OPTIONAL ).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_F. "중량정보 업데이트
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M52.
    EXIT.
  ENDIF.

  IF PS_DATA-WADAT_IST IS INITIAL AND
     LS_ZGTSDT9110-WADAT_IST IS INITIAL.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M25.
    EXIT.
  ENDIF.

*-CHECK
  PERFORM CHECK_SERVICE_GI_JS CHANGING PS_DATA.
  IF PS_DATA-MTYPE EQ GC_E.
    EXIT.
  ENDIF.

*-서비스 출고
  CLEAR: GS_VBKOK,GT_VBPOK[],GT_PROT[].

  "헤더
  GS_VBKOK-VBELN_VL = PS_DATA-VBELN.
  GS_VBKOK-WABUC    = GC_X.
  IF PS_DATA-WADAT_IST IS NOT INITIAL.
    GS_VBKOK-WADAT_IST = PS_DATA-WADAT_IST.
  ELSE.
    GS_VBKOK-WADAT_IST = LS_ZGTSDT9110-WADAT_IST.
  ENDIF.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      VBKOK_WA               = GS_VBKOK
      SYNCHRON               = GC_X
      COMMIT                 = GC_X
      DELIVERY               = PS_DATA-VBELN
      IF_NO_MES_UPD_PACK     = GC_X
      IF_ERROR_MESSAGES_SEND = ' '
    TABLES
      VBPOK_TAB              = GT_VBPOK
      PROT                   = GT_PROT.
  IF SY-SUBRC EQ 0.
    IF GT_PROT[] IS INITIAL.
      PERFORM CHECK_AFTER_PGI CHANGING PS_DATA.

    ELSE.
      LOOP AT GT_PROT INTO DATA(LS_PROT) WHERE MSGTY CA 'AE'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PS_DATA-MTYPE = GC_E.

        LOOP AT GT_PROT INTO LS_PROT WHERE MSGTY CA 'AE'.
          CLEAR: LV_MESSAGE.
          PERFORM MESSAGE_BUILD USING LS_PROT-MSGID
                                      LS_PROT-MSGNO
                                      LS_PROT-MSGV1
                                      LS_PROT-MSGV2
                                      LS_PROT-MSGV3
                                      LS_PROT-MSGV4
                                      LV_MESSAGE.
          IF PS_DATA-MSG IS INITIAL.
            PS_DATA-MSG = LV_MESSAGE.
          ELSE.
            PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MESSAGE }|.
          ENDIF.
        ENDLOOP.

      ELSE.
        PERFORM CHECK_AFTER_PGI CHANGING PS_DATA.
      ENDIF.
    ENDIF.

  ELSE.

    PS_DATA-MTYPE = GC_E.

    IF GT_PROT[] IS INITIAL.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
           INTO LV_MESSAGE.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE = TEXT-M26.
      ENDIF.
      PS_DATA-MSG = LV_MESSAGE.

    ELSE.
      LOOP AT GT_PROT INTO LS_PROT WHERE MSGTY CA 'AE'.
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
          IF PS_DATA-MSG IS INITIAL.
            PS_DATA-MSG = LV_MESSAGE.
          ELSE.
            PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MESSAGE }|.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
           INTO LV_MESSAGE.
        IF LV_MESSAGE IS INITIAL.
          LV_MESSAGE = TEXT-M26.
        ENDIF.
        PS_DATA-MSG = LV_MESSAGE.
      ENDIF.
    ENDIF.
  ENDIF.






ENDFORM.

FORM CHECK_SERVICE_GI_JS CHANGING PS_DATA TYPE ZGTSDS0028.

*-01. 서비스 출고 완료
  IF GS_LIKP-WBSTK EQ GC_B OR GS_LIKP-WBSTK EQ GC_C.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M24.
    EXIT.
  ENDIF.

*-02. 이전상태
  LOOP AT GT_LIPS INTO DATA(LS_LIPS).
    "ZGTSDT9120
    IF NOT ( LINE_EXISTS( GT_ZGTSDT9120[ VBELN = LS_LIPS-VBELN POSNR = LS_LIPS-POSNR ] ) ).
      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M19.
    ENDIF.

    "이동유형
    IF LS_LIPS-BWART NE SPACE.
      PS_DATA-MTYPE = GC_E.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG   = TEXT-M21.
      ELSE.
        PS_DATA-MSG   = |{ PS_DATA-MSG }/{ TEXT-M21 }|.
      ENDIF.
    ENDIF.

    "청구관련
    IF LS_LIPS-FKREL NE SPACE.
      PS_DATA-MTYPE = GC_E.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG   = TEXT-M22.
      ELSE.
        PS_DATA-MSG   = |{ PS_DATA-MSG }/{ TEXT-M22 }|.
      ENDIF.
    ENDIF.

    "수량
    IF LS_LIPS-LFIMG NE 0.
      PS_DATA-MTYPE = GC_E.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG   = TEXT-M23.
      ELSE.
        PS_DATA-MSG   = |{ PS_DATA-MSG }/{ TEXT-M23 }|.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM CHECK_AFTER_PGI CHANGING PS_DATA TYPE ZGTSDS0028.
  DATA: LV_SUBRC TYPE SY-SUBRC.

  WAIT UP TO '0.2' SECONDS.
  LV_SUBRC = 4.
  DO 3 TIMES.
    SELECT SINGLE WBSTK
      FROM LIKP
     WHERE VBELN EQ @PS_DATA-VBELN
      INTO @DATA(LV_WBSTK).
    IF LV_WBSTK EQ GC_C.
      LV_SUBRC = 0.
      EXIT.
    ELSE.
      CLEAR LV_WBSTK.
    ENDIF.
  ENDDO.

  CASE LV_SUBRC.
    WHEN 0.
      PS_DATA-MTYPE = GC_S.
      PS_DATA-MSG   = TEXT-S01.
    WHEN OTHERS.
      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M26.
  ENDCASE.

ENDFORM.

FORM SET_DO_BLOCK CHANGING PS_DATA TYPE ZGTSDS0022.
  DATA: LS_HEADER_DATA    LIKE  BAPIOBDLVHDRCHG,
        LS_HEADER_CONTROL LIKE  BAPIOBDLVHDRCTRLCHG,
        LV_DELIVERY       LIKE  BAPIOBDLVHDRCHG-DELIV_NUMB,
        LS_TECHN_CONTROL  LIKE  BAPIDLVCONTROL,
        LT_RETURN         TYPE TABLE OF BAPIRET2.

  DATA: LV_MSG(200).


*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ELSE.
    IF LS_LIKP-WBSTK EQ GC_C. "출고취소
      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M15.
      EXIT.
    ENDIF.
  ENDIF.

*-ZGTSDT9110
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_B. "출고취소
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M15.
    EXIT.
  ENDIF.

*-납품보류 코드
  IF PS_DATA-LIFSK IS INITIAL.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M09.
    EXIT.

  ELSE.
    SELECT SINGLE LIFSP
      FROM TVLS
     WHERE LIFSP EQ @PS_DATA-LIFSK
      INTO @DATA(LV_LIFSK).
    IF SY-SUBRC NE 0.
      PS_DATA-MTYPE = GC_E.
      MESSAGE S206 WITH PS_DATA-LIFSK INTO PS_DATA-MSG.
      EXIT.
    ENDIF.
  ENDIF.

  IF LS_LIKP-LIFSK EQ PS_DATA-LIFSK.
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.
    EXIT.
  ENDIF.

*-납품보류

  LS_HEADER_DATA-DELIV_NUMB = PS_DATA-VBELN.
  LS_HEADER_DATA-DLV_BLOCK  = PS_DATA-LIFSK.

  LS_HEADER_CONTROL-DELIV_NUMB    = PS_DATA-VBELN.
  LS_HEADER_CONTROL-DLV_BLOCK_FLG = GC_X.

  LV_DELIVERY = PS_DATA-VBELN.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      HEADER_DATA    = LS_HEADER_DATA
      HEADER_CONTROL = LS_HEADER_CONTROL
      DELIVERY       = LV_DELIVERY
    TABLES
      RETURN         = LT_RETURN.
  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AEX'.
    IF LV_MSG IS INITIAL.
      LV_MSG = LS_RETURN-MESSAGE.
    ELSE.
      LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = |{ TEXT-M10 }:{ LV_MSG }|.
  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01..
  ENDIF.

ENDFORM.

FORM UPDATE_WEIGHT_DOITEM CHANGING PS_DATA TYPE ZGTSDS0027.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LV_MESSAGE(200).

  CLEAR:GS_LIKP,GT_LIPS[],GT_ZGTSDT9110[],GT_ZGTSDT9120[].

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @GS_LIKP.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @GT_LIPS.
  SORT GT_LIPS BY POSNR.

*-ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_E. "속성정보 업데이트
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M51.
    EXIT.
  ENDIF.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M18.
    EXIT.
  ENDIF.


  LOOP AT GT_LIPS INTO DATA(LS_LIPS).
    IF NOT ( LINE_EXISTS( GT_ZGTSDT9120[ VBELN = LS_LIPS-VBELN POSNR = LS_LIPS-POSNR ] ) ).
      PS_DATA-MTYPE = GC_E.
      PS_DATA-MSG   = TEXT-M19.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF PS_DATA-MTYPE = GC_E.
    EXIT.
  ENDIF.

*-DO ITEM 중량 UPDATE
  PERFORM UPDATE_WEIGHT_DOITEM_PROC CHANGING PS_DATA.

ENDFORM.

FORM UPDATE_WEIGHT_DOITEM_PROC CHANGING PS_DATA TYPE ZGTSDS0027.
  DATA: LV_NTGEW TYPE LIPS-NTGEW,
        LV_BRGEW TYPE LIPS-BRGEW,
        LV_GEWEI TYPE LIPS-GEWEI.
  DATA: LV_NTGEW_TX(20),
        LV_BRGEW_TX(20).

  DATA: LV_MSG(200).

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  GS_LIKP-VBELN.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=T\01'.

  LOOP AT GT_LIPS INTO DATA(LS_LIPS).
    CLEAR:LV_NTGEW,LV_BRGEW,LV_GEWEI,LV_NTGEW_TX,LV_BRGEW_TX.
    LOOP AT GT_ZGTSDT9120 INTO DATA(LS_LINE) WHERE ( POSNR = LS_LIPS-POSNR OR
                                                     UECHA = LS_LIPS-POSNR    )
                                               AND NTGEW > 0.

      LV_GEWEI = LS_LINE-GEWEI.
      "순중량
      LV_NTGEW = LV_NTGEW + LS_LINE-NTGEW.
      "총중량
      LV_BRGEW = LV_BRGEW + LS_LINE-BRGEW.

    ENDLOOP.

    "순중량
    WRITE: LV_NTGEW TO LV_NTGEW_TX UNIT LV_GEWEI. CONDENSE LV_NTGEW_TX.
    "총중량
    WRITE: LV_BRGEW TO LV_BRGEW_TX UNIT LV_GEWEI. CONDENSE LV_BRGEW_TX.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '0111',
                           ' '  'BDC_OKCODE'  '=WEIT',
                           ' '  'RV50A-POSNR' LS_LIPS-POSNR.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=IDET_T',
                           ' '  'BDC_CURSOR'  'LIPS-POSNR(01)'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '=T\04'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '/00',
                           ' '  'LIPS-NTGEW'  LV_NTGEW_TX,
                           ' '  'LIPS-BRGEW'  LV_BRGEW_TX.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '/00'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '=BACK_T'.

  ENDLOOP.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '/00'.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.


  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.


  CALL TRANSACTION 'VL02N' USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.
  ELSE.
    PS_DATA-MTYPE = GC_E.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AEX'.
      CLEAR LV_MSG.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MSG.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG = LV_MSG.
      ELSE.
        PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MSG }|.
      ENDIF.
    ENDLOOP.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_RESTORE_ATTR_DOITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_DATA>
*&---------------------------------------------------------------------*
FORM UPDATE_RESTORE_ATTR_DOITEM  CHANGING PS_DATA TYPE ZGTSDS0034.
  DATA: LV_MESSAGE(200).

  CLEAR:GS_LIKP,GT_LIPS[],GT_ZGTSDT9110[],GT_ZGTSDT9120[].

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @GS_LIKP.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.
  ENDIF.

*-LIPS
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @GT_LIPS.
  SORT GT_LIPS BY POSNR.

*-ZGTSDT9110-ZZJS_STATUS
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF LS_ZGTSDT9110-ZZJS_STATUS NE GC_E AND "속성정보 업데이트
     LS_ZGTSDT9110-ZZJS_STATUS NE GC_F.    "중량정보 업데이트
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M57.
    EXIT.
  ENDIF.

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_DATA-VBELN
     AND LOEVM EQ @SPACE
    INTO TABLE @GT_ZGTSDT9120.
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M18.
    EXIT.
  ENDIF.

  IF PS_DATA-MTYPE = GC_E.
    EXIT.
  ENDIF.

*-RESTORE DO ITEM ATTRIBUTES
  PERFORM RESTORE_DO_ITEM_ATTRS CHANGING PS_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESTORE_DO_ITEM_ATTRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_DATA
*&---------------------------------------------------------------------*
FORM RESTORE_DO_ITEM_ATTRS  CHANGING PS_DATA TYPE ZGTSDS0034.
  DATA: LV_LFIMG_TXT(20),
        LV_LFIMG TYPE LIPS-LFIMG.
  DATA: LV_MSG(200).

  DATA: LV_JSPROC(5),
        LT_ITEM TYPE TABLE OF ZGTSDS0035.

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  GS_LIKP-VBELN.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=T\02'.

  LOOP AT GT_LIPS INTO DATA(LS_LIPS).
    CLEAR: LV_LFIMG,LV_LFIMG_TXT.
    "ITEM 수량
    LOOP AT GT_ZGTSDT9120 INTO DATA(LS_ITEM) WHERE VBELN EQ LS_LIPS-VBELN
                                                AND ( POSNR EQ LS_LIPS-POSNR OR
                                                      UECHA EQ LS_LIPS-POSNR    ).
      LV_LFIMG = LV_LFIMG + LS_ITEM-LFIMG.
    ENDLOOP.
    WRITE: LV_LFIMG TO LV_LFIMG_TXT UNIT LS_ITEM-VRKME.CONDENSE LV_LFIMG_TXT.

    "속성
    APPEND VALUE #( VBELN = LS_LIPS-VBELN
                    POSNR = LS_LIPS-POSNR
                    BWART = VALUE #( GT_ZGTSDT9120[ VBELN = LS_LIPS-VBELN POSNR = LS_LIPS-POSNR ]-BWART OPTIONAL )
                    FKREL = VALUE #( GT_ZGTSDT9120[ VBELN = LS_LIPS-VBELN POSNR = LS_LIPS-POSNR ]-FKREL OPTIONAL )
                  ) TO LT_ITEM.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '0111',
                           ' '  'BDC_OKCODE'  '=WEIT',
                           ' '  'RV50A-POSNR' LS_LIPS-POSNR.


    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '/00',
                           ' '  'LIPSD-G_LFIMG(01)' LV_LFIMG_TXT.


    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '/00'.

  ENDLOOP.


  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '/00'.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.


  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

*-DO ITEM의 이동유형(BWART),청구관련(FKREL) 필드값을 원복
*-SAPMV50A의 USER-EXIT : userexit_save_document_prepare =>PERFORM USEREXIT_SAVE_DOCUMENT_PRE0012.
*                       에서 처리.(IMPORT MEMORY ID 로 대상인지 구분)

  LV_JSPROC = 'QT0_C'.
  EXPORT LV_JSPROC LT_ITEM TO MEMORY ID 'ZGTSDR2010_QT0'.

  CALL TRANSACTION 'VL02N' USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.
  ELSE.
    PS_DATA-MTYPE = GC_E.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
      CLEAR LV_MSG.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MSG.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG = LV_MSG.
      ELSE.
        PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MSG }|.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNSET_DO_BLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_DATA>
*&---------------------------------------------------------------------*
FORM UNSET_DO_BLOCK  CHANGING PS_DATA TYPE ZGTSDS0022.
  DATA: LS_HEADER_DATA    LIKE  BAPIOBDLVHDRCHG,
        LS_HEADER_CONTROL LIKE  BAPIOBDLVHDRCTRLCHG,
        LV_DELIVERY       LIKE  BAPIOBDLVHDRCHG-DELIV_NUMB,
        LS_TECHN_CONTROL  LIKE  BAPIDLVCONTROL,
        LT_RETURN         TYPE TABLE OF BAPIRET2.

  DATA: LV_MSG(200).

*-LIKP
  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M07.
    EXIT.

  ELSE.
    IF LS_LIKP-LIFSK IS INITIAL.
      PS_DATA-MTYPE = GC_S.
      EXIT.
    ENDIF.
  ENDIF.

*-납품보류 해제

  LS_HEADER_DATA-DELIV_NUMB = PS_DATA-VBELN.
  LS_HEADER_DATA-DLV_BLOCK  = ' '.

  LS_HEADER_CONTROL-DELIV_NUMB    = PS_DATA-VBELN.
  LS_HEADER_CONTROL-DLV_BLOCK_FLG = GC_X.

  LV_DELIVERY = PS_DATA-VBELN.

  CALL FUNCTION 'RV_DELIVERY_INIT'
    EXPORTING
      IF_NO_DEQUE = GC_X.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      HEADER_DATA    = LS_HEADER_DATA
      HEADER_CONTROL = LS_HEADER_CONTROL
      DELIVERY       = LV_DELIVERY
    TABLES
      RETURN         = LT_RETURN.
  LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
    IF LV_MSG IS INITIAL.
      LV_MSG = LS_RETURN-MESSAGE.
    ELSE.
      LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    __BAPI_TRANSACTION_ROLLBACK.

    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = |{ TEXT-M10 }:{ LV_MSG }|.
  ELSE.
    __BAPI_TRANSACTION_COMMIT.

    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01..
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form JS_RESTORE_BATCH_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_DATA>
*&---------------------------------------------------------------------*
FORM JS_RESTORE_BATCH_LINE  CHANGING PS_DATA TYPE ZGTSDS0036.
  DATA: LV_LFIMG_TXT(20),
        LV_LFIMG TYPE LIPS-LFIMG.
  DATA: LV_MSG(200).
  DATA: LV_CHK(1).

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @DATA(LT_ZGTSDT9120).
  SORT LT_ZGTSDT9120 BY POSNR UECHA.

*-기존 DO
  SELECT *
    FROM LIPS
   WHERE VBELN EQ @PS_DATA-VBELN
    INTO TABLE @DATA(LT_LIPS).
  SORT LT_LIPS BY POSNR UECHA.

*-BATCH 지정 체크
  DATA(LT_ITEM) = LT_LIPS[].
  LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE UECHA EQ '000000'.
    IF LS_LIPS-LFIMG EQ 0 AND
      LINE_EXISTS( LT_ITEM[ UECHA = LS_LIPS-POSNR ] ).
      LV_CHK = GC_X.
      EXIT.
    ELSE.

    ENDIF.
  ENDLOOP.

  IF LV_CHK IS NOT INITIAL.
    PS_DATA-MTYPE = GC_E.
    PS_DATA-MSG   = TEXT-M58.
    EXIT.
  ENDIF.

  CLEAR: CTU_PARAMS.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '4004',
                        ' '  'BDC_OKCODE'  '=ENT2',
                        ' '  'LIKP-VBELN'  PS_DATA-VBELN.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=T\01'.

  LOOP AT LT_LIPS INTO LS_LIPS WHERE UECHA EQ '000000'
                                 AND LFIMG NE 0.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=POPO_T'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '0111',
                           ' '  'BDC_OKCODE'  '=WEIT',
                           ' '  'RV50A-POSNR' LS_LIPS-POSNR.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '1000',
                           ' '  'BDC_OKCODE'  '=IDET_T',
                           ' '  'BDC_CURSOR'  'LIPS-POSNR(01)'.

    PERFORM DYNPRO USING :
                           'X'  'SAPMV50A'    '3000',
                           ' '  'BDC_OKCODE'  '=T\03'.

    LOOP AT LT_ZGTSDT9120 INTO DATA(LS_BATCH) WHERE UECHA EQ LS_LIPS-POSNR.
      CLEAR:LV_LFIMG_TXT.
      WRITE: LS_BATCH-LFIMG TO LV_LFIMG_TXT UNIT LS_LIPS-VRKME. CONDENSE LV_LFIMG_TXT.

      PERFORM DYNPRO USING :
                            'X'  'SAPMV50A'    '3000',
                            ' '  'BDC_OKCODE'  '=POAN_T'.

      PERFORM DYNPRO USING :
                            'X'  'SAPMV50A'    '3000',
                            ' '  'BDC_OKCODE'  '/00',
                            ' ' 'LIPS-CHARG(02)' LS_BATCH-CHARG,
                            ' ' 'LIPS-LGORT(02)' LS_BATCH-LGORT,
                            ' ' 'LIPS-LFIMG(02)' LV_LFIMG_TXT.



    ENDLOOP.

    PERFORM DYNPRO USING :
                            'X'  'SAPMV50A'    '3000',
                            ' '  'BDC_OKCODE'  '=BACK_T'.






  ENDLOOP.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '/00'.

  PERFORM DYNPRO USING :
                        'X'  'SAPMV50A'    '1000',
                        ' '  'BDC_OKCODE'  '=SICH_T'.


  CTU_PARAMS-DISMODE  =  GC_N.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'VL02N' USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  IF LINE_EXISTS( GT_RETMSG[ MSGTYP = GC_S MSGID = 'VL' MSGNR = '311' ] ).
    PS_DATA-MTYPE = GC_S.
    PS_DATA-MSG   = TEXT-S01.
  ELSE.
    PS_DATA-MTYPE = GC_E.

    LOOP AT GT_RETMSG INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
      CLEAR LV_MSG.
      PERFORM MESSAGE_BUILD USING LS_MSG-MSGID
                                  LS_MSG-MSGNR
                                  LS_MSG-MSGV1
                                  LS_MSG-MSGV2
                                  LS_MSG-MSGV3
                                  LS_MSG-MSGV4
                                  LV_MSG.
      IF PS_DATA-MSG IS INITIAL.
        PS_DATA-MSG = LV_MSG.
      ELSE.
        PS_DATA-MSG = |{ PS_DATA-MSG }/{ LV_MSG }|.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
