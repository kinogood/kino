*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form check_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> LS_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_STOCK  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                  USING    P_ERROR.

  DATA:LS_LABST     TYPE MARD-LABST,
       LS_STOCK(18).
  DATA:LV_MATNR LIKE MARA-MATNR.
  DATA:LV_HAWA(1).

* 배치체크
  LOOP AT PT_HUTEMP.
    CLEAR LV_MATNR.
*[S/4 HANA PJT]-Conversion_Alpha_input
*[S/4 HANA PJT]-2023.04.10 by 김선우
*    PERFORM conversion_exit_matn1 CHANGING lv_matnr.
*    pt_hutemp-matnr = lv_matnr.
*[S/4 HANA PJT]-Conversion_Alpha_input
*[S/4 HANA PJT]-2023.04.10 by 김선우
*-> CCM : 26.09.2023 09:36:06 / ZLSGSD4
    LV_MATNR = PT_HUTEMP-MATNR.
    PERFORM CONVERSION_EXIT_MATN1 CHANGING LV_MATNR.
*<-

*   상품체크
    CLEAR LV_HAWA.
    PERFORM CHECK_HAWA USING PT_HUTEMP-MATNR LV_HAWA.

    CLEAR MARC.
    SELECT SINGLE XCHPF
      INTO MARC-XCHPF
      FROM MARC
     WHERE MATNR = LV_MATNR
       AND WERKS = PT_HUTEMP-WERKS.

    IF MARC-XCHPF = 'X'.
      IF PT_HUTEMP-CHARG IS INITIAL.
        P_ERROR = 'X'.
        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.
        PT_HUTEMP-ZETXT =
                  'EP03 배치를 입력하세요'.

      ENDIF.
    ELSE.
      CLEAR PT_HUTEMP-CHARG.
    ENDIF.

    IF LV_HAWA = 'X'.
*      CLEAR: PT_HUTEMP-SOBKZ,
*             PT_HUTEMP-LSONR.
      CLEAR : PT_HUTEMP-CHARG.
    ELSE.
      IF MARC-XCHPF = 'X'.
        IF PT_HUTEMP-CHARG IS INITIAL OR
           PT_HUTEMP-SOBKZ IS INITIAL OR
           PT_HUTEMP-LSONR IS INITIAL.
          P_ERROR = 'X'.
          PT_HUTEMP-IFSAP =  GC_ERSAP.
          PT_HUTEMP-ZERET =  GC_ERROR.
          CONCATENATE PT_HUTEMP-ZETXT
                    'EP05 배치/판매오더번호를 입력하세요'
                 INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        ENDIF.
      ELSE.
        IF PT_HUTEMP-SOBKZ IS INITIAL OR
           PT_HUTEMP-LSONR IS INITIAL.
          P_ERROR = 'X'.
          PT_HUTEMP-IFSAP =  GC_ERSAP.
          PT_HUTEMP-ZERET =  GC_ERROR.
          CONCATENATE PT_HUTEMP-ZETXT
                    'EP05 판매오더번호를 입력하세요'
                 INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY PT_HUTEMP.
  ENDLOOP.

* 재고 체크
  CHECK NOT P_ERROR = 'X'.


  LOOP AT PT_HUTEMP.
    CLEAR MARA.
    SELECT SINGLE *
      FROM MARA
     WHERE MATNR = PT_HUTEMP-MATNR.

    IF PT_HUTEMP-SOBKZ = ' '. "창고재고
      CLEAR: LS_LABST.

      IF PT_HUTEMP-CHARG = ' '.
        CLEAR: MARD.
        SELECT SINGLE LABST
          FROM MARD
          INTO LS_LABST
         WHERE MATNR  =  PT_HUTEMP-MATNR
           AND WERKS  =  PT_HUTEMP-WERKS
           AND LGORT  =  PT_HUTEMP-LGORT.
      ELSE.
        CLEAR: MCHB.
        SELECT SINGLE CLABS
          FROM MCHB
          INTO LS_LABST
         WHERE MATNR  =  PT_HUTEMP-MATNR
           AND WERKS  =  PT_HUTEMP-WERKS
           AND LGORT  =  PT_HUTEMP-LGORT
           AND CHARG  =  PT_HUTEMP-CHARG.
      ENDIF.
*     포장수량이 가용보다 많으면 에러
      IF PT_HUTEMP-LFIMG  > LS_LABST.
        WRITE LS_LABST TO LS_STOCK UNIT MARA-MEINS.
        CONDENSE LS_STOCK.
        CONCATENATE 'EP41 재고부족' PT_HUTEMP-MATNR
                    PT_HUTEMP-WERKS PT_HUTEMP-LGORT
                    PT_HUTEMP-CHARG LS_STOCK
                    INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        P_ERROR  =  'X'.
      ENDIF.

    ELSE.                     "판매오더재고
      CLEAR: MSKA.
      SELECT SINGLE *
        FROM MSKA
       WHERE MATNR  =  PT_HUTEMP-MATNR
         AND WERKS  =  PT_HUTEMP-WERKS
         AND LGORT  =  PT_HUTEMP-LGORT
         AND CHARG  =  PT_HUTEMP-CHARG
         AND SOBKZ  =  PT_HUTEMP-SOBKZ
         AND VBELN  =  PT_HUTEMP-LSONR+0(10)
         AND POSNR  =  PT_HUTEMP-LSONR+10(6).

*     포장수량이 가용보다 많으면 에러
      IF PT_HUTEMP-LFIMG  > MSKA-KALAB.
        WRITE MSKA-KALAB TO LS_STOCK UNIT MARA-MEINS.
        CONDENSE LS_STOCK.
        CONCATENATE 'EP41 재고부족' PT_HUTEMP-MATNR
                    PT_HUTEMP-WERKS PT_HUTEMP-LGORT
                    PT_HUTEMP-CHARG PT_HUTEMP-SOBKZ
                    PT_HUTEMP-LSONR LS_STOCK
                    INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.
        P_ERROR  =  'X'.
      ENDIF.

    ENDIF.

    MODIFY PT_HUTEMP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_bdc_hu_cr_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&---------------------------------------------------------------------*
FORM BUILD_BDC_HU_CR_O  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB.


  DATA: LS_CNT(2)    TYPE N,
        LS_FIELD(20).

* 포장 HU TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6HUS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.

  CLEAR: LS_CNT, PT_HUTEMP.
  LOOP AT PT_HUTEMP.
    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    LS_CNT  =  LS_CNT  +  1.

*   모든기존 HU(포장가용)
*   Default 화면의 Line인 5개(Recording과 동일)이므로 5개Line까지
*   입력후에는 PageDown버튼을 눌러 Line을 추가 후 Data를 입력한다.
    IF LS_CNT >  4.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=PPLUS'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      LS_CNT =  5.

    ENDIF.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    CONCATENATE 'V51VE-EXIDV(' LS_CNT ')' INTO LS_FIELD.

    IF PT_HUTEMP-INIDV = ' '.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-EXIDV.
      CONCATENATE 'V51VE-VHILM(' LS_CNT ')' INTO LS_FIELD.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-VHILM.
    ELSE.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-INIDV.
    ENDIF.

  ENDLOOP.

* 입력한 처리단위가 자동정렬되므로 순차적으로 Line선택이 곤란함.
* 찾기기능으로 해당 처리단의를 찾으면 자동Line선택이 되므로 해결...ㅋㅋ
  CLEAR: LS_CNT, PT_HUTEMP.
  LOOP AT PT_HUTEMP.
    IF PT_HUTEMP-INIDV = ' '.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
      PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-EXIDV.

    ELSE.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR'
                                       'VEKPVB-EXIDV(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
      PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-INIDV.

    ENDIF.

  ENDLOOP.

* Pack
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HU_VERP'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKPVB-EXIDV(01)'.
* 저장
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKPVB-EXIDV(01)'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING    P_PROGRAM P_DYNPRO.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X'.
  APPEND GT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0329   text
*      -->P_0330   text
*----------------------------------------------------------------------*
FORM BDC_FIELD  USING    P_FNAM P_FVAL.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-FNAM = P_FNAM.
  GT_BDCDATA-FVAL = P_FVAL.
  CONDENSE GT_BDCDATA-FVAL.
  APPEND GT_BDCDATA.
ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------*
*& Form call_transaction_hu_cr_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> P_
*&      --> I_BDC_MODE
*&      --> P_
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_HU_CR_I  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                                USING   TCODE
                                        MODE
                                        P_VALUE.

  DATA: LS_TEXT TYPE CFGNL-MSGLIN.

  GS_CTU_PARAMS-DISMODE  = MODE.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = 'X'. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = 'X'. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = 'X'. "Not as batch input session after end of


  CALL TRANSACTION TCODE    USING GT_BDCDATA
                   OPTIONS   FROM GS_CTU_PARAMS
                   MESSAGES  INTO GT_MESSTAB.

  CLEAR PT_HUTEMP.
  READ TABLE PT_HUTEMP INDEX 1.

  IF SY-SUBRC = 0 AND ( SY-MSGTY = 'S' OR SY-MSGTY = 'I' ).

    IF P_VALUE = 'I'.
*     전기문서번호 가져오기
      SELECT M~MBLNR M~MJAHR
        INTO (PT_HUTEMP-MBLNR,PT_HUTEMP-MJAHR)
        FROM VEKP AS K INNER JOIN VEPO AS P
                               ON K~VENUM =  P~VENUM
                       INNER JOIN HUMSEG AS M
                               ON P~VENUM =  M~VENUM AND
                                  P~VEPOS =  M~VEPOS
          UP TO 1 ROWS
       WHERE K~EXIDV  =  PT_HUTEMP-EXIDV
         AND K~STATUS <> '0060'.
      ENDSELECT.
      IF NOT PT_HUTEMP-MBLNR IS INITIAL.
        PT_HUTEMP-IFSAP =  GC_SUSAP.
        PT_HUTEMP-ZERET =  GC_SUCCESS.
      ELSE.
        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.

      ENDIF.
    ENDIF.
  ELSE.
    PT_HUTEMP-IFSAP =  GC_ERSAP.
    PT_HUTEMP-ZERET =  GC_ERROR.
  ENDIF.

* 메시지 가져오기
  CALL FUNCTION 'RKC_MSG_STRING'
    EXPORTING
      ID      = SY-MSGID
      MTYPE   = SY-MSGTY
      NUMBER  = SY-MSGNO
      PAR1    = SY-MSGV1
      PAR2    = SY-MSGV2
      PAR3    = SY-MSGV3
      PAR4    = SY-MSGV4
    IMPORTING
      MSG_LIN = LS_TEXT.

  PT_HUTEMP-ZETXT = LS_TEXT.
  PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
  PT_HUTEMP-SAP_CTIM+08(06)  =  SY-UZEIT.
  MODIFY PT_HUTEMP TRANSPORTING SAP_CTIM IFSAP ZERET ZETXT
                                MBLNR MJAHR
                          WHERE SAP_CTIM = ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_hu_create_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> LT_HUTAB
*&---------------------------------------------------------------------*
FORM BUILD_HU_CREATE_I  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                         USING   PS_HUTAB  LIKE GT_IFTAB.
  DATA: LS_CNT(2)    TYPE N,
        LS_QTY(16),
        LS_FIELD(20).

* 포장 자재 TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6POS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.
  PERFORM BDC_FIELD  USING 'HUM_MM_KOPFDATEN-WERKS'
                                            PS_HUTAB-WERKS.

  PERFORM BDC_DYNPRO USING 'SAPLV51G'       '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'     '=ENTR'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR'     'V51VE-VHILM(01)'.
  PERFORM BDC_FIELD  USING 'V51VE-EXIDV(01)' PS_HUTAB-EXIDV.
  PERFORM BDC_FIELD  USING 'V51VE-VHILM(01)' PS_HUTAB-VHILM.

  CLEAR LS_CNT.
  LOOP AT PT_HUTEMP.
    CLEAR LS_QTY.
    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    LS_QTY  =  PT_HUTEMP-LFIMG.
    LS_CNT  =  LS_CNT  +  1.

*   포장예정 자재
*   Default 화면의 Line인 7개(Recording과 동일)이므로 7개Line까지
*   입력후에는 PageDown버튼을 눌러 Line을 추가 후 Data를 입력한다.
    IF LS_CNT >  6.
      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=PPLUS'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VP-TMENG(01)'.

      PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VP-TMENG(01)'.

      LS_CNT =  7.
    ENDIF.

    CONCATENATE 'V51VP-WERKS(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-WERKS.

    CONCATENATE 'V51VP-MATNR(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-MATNR.

    CONCATENATE 'V51VP-LFIMG(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD LS_QTY.

    CONCATENATE 'V51VP-LGORT(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-LGORT.

    CONCATENATE 'V51VP-UMLGO(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-UMLGO.

    CLEAR MARC.
    SELECT SINGLE XCHPF
      INTO MARC-XCHPF
      FROM MARC
     WHERE MATNR = PT_HUTEMP-MATNR
       AND WERKS = PT_HUTEMP-WERKS.
    IF MARC-XCHPF = 'X'.
      CONCATENATE 'V51VP-CHARG(' LS_CNT ')' INTO LS_FIELD.
      PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-CHARG.
    ENDIF.

    CONCATENATE 'V51VP-SOBKZ(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-SOBKZ.

    CONCATENATE 'V51VP-LSONR(' LS_CNT ')' INTO LS_FIELD.
    PERFORM BDC_FIELD  USING LS_FIELD PT_HUTEMP-LSONR.

  ENDLOOP.

* 포장 예정자재 전체선택
  PERFORM BDC_DYNPRO USING 'SAPLV51G'        '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'      '=HU_MARKA'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR'    'V51VP-MATNR(01)'.
* Pack
  PERFORM BDC_DYNPRO USING 'SAPLV51G'        '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE'      '=HU_VERP'.
  PERFORM BDC_FIELD  USING 'V51VE-SELKZ(01)' 'X'.
* 저장
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_hu_dismantle_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&---------------------------------------------------------------------*
FORM BUILD_HU_DISMANTLE_O  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB.


* 포장 HU TAB
  PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=UE6HUS'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'HEADER51-PLANHU'.

  CLEAR PT_HUTEMP.
  LOOP AT PT_HUTEMP.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.
    PERFORM BDC_FIELD  USING 'V51VE-EXIDV(01)'
                                  PT_HUTEMP-EXIDV.
*   찾기로 Line 선택
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HUSUCH'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6001'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ENTR'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VEKP-EXIDV'.
    PERFORM BDC_FIELD  USING 'VEKP-EXIDV' PT_HUTEMP-EXIDV.
*   Empty
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=HULEE'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.

*   저장
    PERFORM BDC_DYNPRO USING 'SAPLV51G'   '6000'.
    PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.
    PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'V51VE-EXIDV(01)'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_hawa
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HUTEMP_MATNR
*&      --> LV_HAWA
*&---------------------------------------------------------------------*
FORM CHECK_HAWA  USING    P_MATNR
                          P_HAWA.

  CLEAR MARA.
  SELECT SINGLE MTART
    INTO MARA-MTART
    FROM MARA
   WHERE MATNR = P_MATNR.

  IF MARA-MTART = 'HAWA' OR MARA-MTART = 'ROH' OR
     MARA-MTART = 'ROH1' OR MARA-MTART = 'ROH2'.
    P_HAWA = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MATNR
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1  CHANGING PV_MATNR.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reverse_hu_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTEMP
*&      --> I_BDC_MODE
*&---------------------------------------------------------------------*
FORM REVERSE_HU_DOC  TABLES   PT_HUTEMP STRUCTURE GT_IFTAB
                      USING   P_MODE.
  DATA: PD_ZETXT    LIKE ZPPTIF43-ZETXT,
        PD_CHECK(1).

  LOOP AT PT_HUTEMP.
    CLS  : GT_BDCDATA, GT_MESSTAB.
    CLEAR: GS_CTU_PARAMS, PD_CHECK.

    IF PT_HUTEMP-MBLNR IS INITIAL.
*     전기 문서번호 읽기
      CLEAR: HUMSEG.
      SELECT M~MBLNR M~MJAHR
        INTO (PT_HUTEMP-MBLNR,PT_HUTEMP-MJAHR)
        FROM VEKP AS K INNER JOIN VEPO AS P
                               ON K~VENUM =  P~VENUM
                       INNER JOIN HUMSEG AS M
                               ON P~VENUM =  M~VENUM AND
                                  P~VEPOS =  M~VEPOS
       WHERE K~EXIDV  =  PT_HUTEMP-EXIDV
         AND K~STATUS <> '0060'.
      ENDSELECT.
    ENDIF.

    IF PT_HUTEMP-MBLNR2 IS INITIAL.
      PERFORM BDC_DYNPRO USING 'RHU_GOODS_MOVEMENT_CANCEL' '1000'.
      PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=ONLI'.
      PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'SP_MBLNR'.
      PERFORM BDC_FIELD  USING 'SP_PSTDA' PT_HUTEMP-BUDAT.
      PERFORM BDC_FIELD  USING 'SP_MBLNR' PT_HUTEMP-MBLNR.
      PERFORM BDC_FIELD  USING 'SP_MJAHR' PT_HUTEMP-MJAHR.

      PERFORM CALL_TRANSACTION_HUCANC USING 'HUCANC' P_MODE
                                            PT_HUTEMP.

    ENDIF.

*    IF PT_HUTEMP-IFSAP = GC_SUSAP AND PT_HUTEMP-ZERET = GC_SUCCESS.
    IF NOT PT_HUTEMP-MBLNR2 IS INITIAL.
      CLS GT_RETURN.
      CALL FUNCTION 'BAPI_HU_DELETE'
        EXPORTING
          HUKEY  = PT_HUTEMP-EXIDV
        TABLES
          RETURN = GT_RETURN.

      CLEAR GT_RETURN.
      READ TABLE GT_RETURN WITH KEY TYPE = 'S'.
      IF SY-SUBRC = '0'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        PT_HUTEMP-IFSAP =  GC_SUSAP.
        PT_HUTEMP-ZERET =  GC_SUCCESS.
        CONCATENATE PT_HUTEMP-ZETXT GT_RETURN-TYPE GT_RETURN-ID
                    GT_RETURN-NUMBER GT_RETURN-MESSAGE
               INTO PT_HUTEMP-ZETXT SEPARATED BY SPACE.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PT_HUTEMP-IFSAP =  GC_ERSAP.
        PT_HUTEMP-ZERET =  GC_ERROR.
*       Error Message 전체를 Text로..

        CLEAR: PD_ZETXT, GT_RETURN.
        LOOP AT GT_RETURN WHERE TYPE <> 'S'.
          CONCATENATE PD_ZETXT GT_RETURN-TYPE GT_RETURN-ID
                      GT_RETURN-NUMBER
                      INTO PD_ZETXT.
          CONCATENATE PD_ZETXT GT_RETURN-MESSAGE
                      INTO PD_ZETXT SEPARATED BY SPACE.

        ENDLOOP.

        PT_HUTEMP-ZETXT = PD_ZETXT.
      ENDIF.

    ENDIF.

    PT_HUTEMP-SAP_CTIM+00(08)  =  SY-DATUM.
    PT_HUTEMP-SAP_CTIM+08(06)  =  SY-UZEIT.
    MODIFY PT_HUTEMP TRANSPORTING SAP_CTIM IFSAP ZERET ZETXT
                                  MBLNR MJAHR MBLNR2 MJAHR2
                            WHERE SAP_CTIM = ' '.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_hucanc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_MODE
*&      --> PT_HUTEMP
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_HUCANC  USING    TCODE
                                       MODE
                                       PS_HUTEMP LIKE GT_IFTAB.
  DATA: LV_TEXT LIKE CFGNL-MSGLIN,
        LS_VEKP LIKE VEKP.


  GS_CTU_PARAMS-DISMODE  = MODE.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = 'X'. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = 'X'. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = 'X'. "Not as batch input session after end of


  CALL TRANSACTION TCODE    USING GT_BDCDATA
                   OPTIONS   FROM GS_CTU_PARAMS
                   MESSAGES  INTO GT_MESSTAB.


  IF SY-SUBRC = 0 AND
      ( SY-MSGTY = 'S' OR SY-MSGTY = 'I' OR SY-MSGTY = ' ' ).
    PS_HUTEMP-IFSAP =  GC_SUSAP.
    PS_HUTEMP-ZERET =  GC_SUCCESS.

*   취소 문서번호가져오기
    CLEAR LS_VEKP.
    SELECT SINGLE *
      INTO LS_VEKP
      FROM VEKP
     WHERE EXIDV  = PS_HUTEMP-EXIDV
       AND STATUS = '0020'.

    SELECT MBLNR MJAHR
      INTO (PS_HUTEMP-MBLNR2,PS_HUTEMP-MJAHR2)
      FROM HUMSEG
        UP TO 1 ROWS
     WHERE VENUM = LS_VEKP-VENUM.
    ENDSELECT.

*    SELECT M~MBLNR M~MJAHR
*      INTO (PS_HUTEMP-MBLNR2,PS_HUTEMP-MJAHR2)
*      FROM VEKP AS K INNER JOIN HUMSEG AS M
*                        ON K~VENUM = M~VENUM
*        UP TO 1 ROWS
*     WHERE K~EXIDV  =  PS_HUTEMP-EXIDV
*       AND K~STATUS = '0020'.   "삭제
*
*    ENDSELECT.

  ELSE.                  "실패
    PS_HUTEMP-IFSAP =  GC_ERSAP.
    PS_HUTEMP-ZERET =  GC_ERROR.
  ENDIF.

* 메시지 가져오기
  CALL FUNCTION 'RKC_MSG_STRING'
    EXPORTING
      ID      = SY-MSGID
      MTYPE   = SY-MSGTY
      NUMBER  = SY-MSGNO
      PAR1    = SY-MSGV1
      PAR2    = SY-MSGV2
      PAR3    = SY-MSGV3
      PAR4    = SY-MSGV4
    IMPORTING
      MSG_LIN = LV_TEXT.

  PS_HUTEMP-ZETXT = LV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HUTAB
*&      --> GC_TABLE43
*&---------------------------------------------------------------------*
FORM UPDATE_TABLE  TABLES PAR_ITAB USING TABLE_NAME.
  ASSIGN (TABLE_NAME) TO <TN>.
  MOVE-CORRESPONDING PAR_ITAB TO <TN>.
  UPDATE (TABLE_NAME) FROM <TN>.
  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_CHANGE_SO_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_CHANGE_SO_BAPI USING PV_VBELN
                               PV_ZSEQNO
                      CHANGING PV_SUBRC.

  DATA: LV_FLAG         TYPE CHAR01,
        LS_HEADERX      TYPE BAPISDH1X,
        LS_LOGIC_SWITCH LIKE BAPISDLS,
        LT_RETURN       TYPE ZBAPIRET2TAB,
        LT_ITEM_IN      TYPE CRMT_BAPISDITM_T WITH HEADER LINE,
        LT_ITEM_INX     TYPE CRMT_BAPISDITMX_T WITH HEADER LINE.

*LOG 읽어 거부사유 체크
  SELECT * INTO TABLE @DATA(LT_ABGRU)
    FROM ZGTSDT1014
   WHERE VBELN    = @PV_VBELN
     AND ZSEQNO   = @PV_ZSEQNO
     AND CHANGENR IN ( SELECT MAX( CHANGENR )
                        FROM ZGTSDT1014
                       WHERE VBELN  = @PV_VBELN
                         AND ZSEQNO = @PV_ZSEQNO
                       GROUP BY VBELN, POSNR, ZSEQNO ).

  LS_HEADERX-UPDATEFLAG = 'U'.

  SELECT VBELN, POSNR, ABGRU INTO TABLE @DATA(LT_VBAP)
    FROM VBAP
   WHERE VBELN = @PV_VBELN.
  LOOP AT LT_VBAP INTO DATA(LS_VBAP).

    IF LS_VBAP-ABGRU = 'Z2'.
      LT_ITEM_IN-REASON_REJ  = SPACE.
    ELSE.
      LT_ITEM_IN-REASON_REJ  = LS_VBAP-ABGRU.
    ENDIF.

    READ TABLE LT_ABGRU INTO DATA(LS_ABGRU) WITH KEY POSNR = LS_VBAP-POSNR.
    IF SY-SUBRC = 0.
      LT_ITEM_IN-REASON_REJ  = LS_ABGRU-ABGRU.
    ENDIF.
    LT_ITEM_IN-ITM_NUMBER  = LS_VBAP-POSNR.
    APPEND LT_ITEM_IN. CLEAR LT_ITEM_IN.

    LT_ITEM_INX-ITM_NUMBER   = LS_VBAP-POSNR.  "영업문서품목
    LT_ITEM_INX-UPDATEFLAG = 'U'.
    LT_ITEM_INX-REASON_REJ = 'X'.
    APPEND LT_ITEM_INX. CLEAR LT_ITEM_INX.
  ENDLOOP.

  LV_FLAG = 'X'.
  EXPORT LV_FLAG TO MEMORY ID 'ZGTSD_UPD_STS'.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      SALESDOCUMENT    = PV_VBELN
      ORDER_HEADER_INX = LS_HEADERX
      LOGIC_SWITCH     = LS_LOGIC_SWITCH
    TABLES
      RETURN           = LT_RETURN
      ORDER_ITEM_IN    = LT_ITEM_IN
      ORDER_ITEM_INX   = LT_ITEM_INX.

  FREE MEMORY ID 'ZGTSD_UPD_STS'.
  DESCRIBE TABLE LT_RETURN LINES DATA(LV_COUNT).
  READ TABLE LT_RETURN INTO DATA(LS_RET) INDEX LV_COUNT.
  IF LS_RET-TYPE  =  'S'.
*   Transaction Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    WAIT UP TO 1 SECONDS.
    PV_SUBRC = 0.
  ELSE.
*   Transaction Rollback
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PV_SUBRC = 4.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_SO_HISTORY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SO
*&---------------------------------------------------------------------*
FORM MAKE_DATA_SO_HISTORY  TABLES   PT_SO STRUCTURE GS_SO_HIS.

  CONSTANTS : LC_VBAP TYPE TABNAME    VALUE 'VBAP',
              LC_FPLT TYPE TABNAME    VALUE 'FPLT'.

  DATA : LV_AMTC  TYPE P DECIMALS 2.

  DATA(LT_FOR) = PT_SO[].
  SORT LT_FOR BY VBELN POSNR ZSEQNO CHANGENR.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING VBELN POSNR ZSEQNO CHANGENR.

* 1-1) 사용자 입력 거부사유 값
  IF LT_FOR[] IS NOT INITIAL.
    SELECT * INTO TABLE @DATA(LT_ABGRU)
      FROM ZGTSDT1014
       FOR ALL ENTRIES IN @LT_FOR
     WHERE VBELN = @LT_FOR-VBELN
       AND ZSEQNO = @LT_FOR-ZSEQNO.

    IF LT_ABGRU[] IS NOT INITIAL.
      SORT LT_ABGRU BY VBELN ZSEQNO POSNR ASCENDING CHANGENR DESCENDING.
      DELETE ADJACENT DUPLICATES FROM LT_ABGRU COMPARING VBELN ZSEQNO POSNR.

      SORT PT_SO BY CHANGENR DESCENDING UTIME DESCENDING.
      READ TABLE PT_SO INDEX 1 INTO DATA(LS_SO).
      DELETE PT_SO WHERE TABNAME IS INITIAL.

      LOOP AT LT_ABGRU INTO DATA(LS_ABGRU).

        APPEND VALUE #( ZSEQNO           = LS_ABGRU-ZSEQNO
                        VBELN            = LS_ABGRU-VBELN
                        POSNR            = LS_ABGRU-POSNR
                        APPROVED_STATUS  = LS_SO-APPROVED_STATUS
                        TRTYP            = LS_SO-TRTYP
                        TABNAME          = SPACE
                        FNAME            = 'ABGRU'
                        CHNGIND          = 'U'
                        FLDTXT           = LS_SO-FLDTXT
                        ZLEVEL           = LS_SO-ZLEVEL
                        CHANGENR         = LS_ABGRU-CHANGENR
                        UDATE            = LS_SO-UDATE
                        UTIME            = LS_SO-UTIME
                        TCODE            = LS_SO-TCODE
                        USERID           = LS_SO-USERID
                        USERNAME         = LS_SO-USERNAME
                        ABGRU            = LS_ABGRU-ABGRU ) TO PT_SO.
      ENDLOOP.
    ENDIF.
  ENDIF.


  CLEAR LS_SO.
  LOOP AT PT_SO INTO LS_SO.
* 2-0) 청구계획 품목 번호, 청구계획 변경된 Item 번호
    IF LS_SO-TABNAME EQ LC_FPLT. "FPLT
      DATA(LV_FPLNR) = SUBSTRING( VAL = LS_SO-TABKEY OFF = 3 LEN = 11 ).
      LS_SO-FPLTR    = SUBSTRING( VAL = LS_SO-TABKEY OFF = 13 LEN = 6 ).

      SELECT SINGLE POSNR INTO LS_SO-POSNR
        FROM VBAP
       WHERE VBELN     EQ LS_SO-VBELN
         AND FPLNR_ANA EQ LV_FPLNR.
    ENDIF.

* 2-1) 품목번호 conversion
    IF LS_SO-POSNR IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LS_SO-POSNR
        IMPORTING
          OUTPUT = LS_SO-POSNR.
    ENDIF.

* 2-1) 청구계획 품목번호 conversion
    IF LS_SO-FPLTR IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LS_SO-FPLTR
        IMPORTING
          OUTPUT = LS_SO-FPLTR.
    ENDIF.

* 2-2) 주문통제 내역 삭제
    IF LS_SO-VALUE_NEW = |Z2| AND LS_SO-ABGRU IS INITIAL.
      DELETE PT_SO. CONTINUE.
    ENDIF.

* 2-3) 사용자 입력 거부사유 값 구성
    IF LS_SO-ABGRU IS NOT INITIAL.

      LS_SO-TABNAME   = LC_VBAP.
      LS_SO-FNAME     = 'ABGRU'.
      LS_SO-CHNGIND   = 'U'.
      LS_SO-VALUE_NEW = LS_SO-ABGRU.

      SELECT SINGLE DDTEXT INTO @LS_SO-FLDTXT
        FROM DD03L AS A LEFT OUTER JOIN DD04T AS C
          ON A~ROLLNAME   EQ C~ROLLNAME
         AND C~DDLANGUAGE EQ @SY-LANGU
       WHERE TABNAME = @LS_SO-TABNAME
         AND FIELDNAME   = @LS_SO-FNAME.
      CONTINUE.
    ENDIF.

* 2-4) 중복된 내용 삭제
    IF LS_SO-ZLEVEL = 'H' AND LS_SO-POSNR IS NOT INITIAL.
      DELETE PT_SO. CONTINUE.
    ENDIF.

* 2-5) 최초 생성된 로그 데이터 삭제..
    IF LS_SO-CHANGENR IS INITIAL AND LS_SO-TRTYP = 'H' AND
       LS_SO-POSNR IS INITIAL.
      DELETE PT_SO. CONTINUE.
    ENDIF.

* 2-6) Field 단위 데이터 조정
    CASE LS_SO-FNAME.
* Pricing Procedure의 문제로 NETPR 값이 정상적으로 조회되지 않아 변경이력 출력하지 않음
      WHEN 'NETPR'.
        DELETE PT_SO. CONTINUE.

      WHEN 'KBETR'.

        DATA(LV_LEN) = STRLEN( LS_SO-TABKEY ).
        DATA(LV_SLEN) = LV_LEN - 4.
        IF LS_SO-TABKEY+LV_SLEN(4) = |ZPR0|.
          LS_SO-FLDTXT = |단가|.

          LV_AMTC = LS_SO-VALUE_NEW.
          WRITE LV_AMTC TO LS_SO-VALUE_NEW CURRENCY LS_SO-CUKY_NEW.
          LV_AMTC = LS_SO-VALUE_OLD.
          WRITE LV_AMTC TO LS_SO-VALUE_OLD CURRENCY LS_SO-CUKY_OLD.
          CONDENSE : LS_SO-VALUE_OLD, LS_SO-VALUE_NEW.
        ELSE.
          DELETE PT_SO. CONTINUE.
        ENDIF.

      WHEN 'KEY'.
        CASE LS_SO-CHNGIND.
          WHEN ZGTSD_I.
            LS_SO-FNAME     = 'Item Added'.
            LS_SO-FLDTXT    = |품목 추가|.
          WHEN ZGTSD_D.
            LS_SO-FNAME     = 'Item Deleted'.
            LS_SO-FLDTXT    = |품목 삭제|.
          WHEN OTHERS.
        ENDCASE.

        CASE LS_SO-TABNAME.
          WHEN LC_VBAP.
            LS_SO-VALUE_NEW = LS_SO-POSNR.
          WHEN LC_FPLT.
            LS_SO-VALUE_NEW = LS_SO-FPLTR.
          WHEN OTHERS.
        ENDCASE.

    ENDCASE.

    MODIFY PT_SO FROM LS_SO.
  ENDLOOP.

ENDFORM.
