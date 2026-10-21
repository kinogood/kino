*&---------------------------------------------------------------------*
*&  Include           MZNF0020F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_select
*&---------------------------------------------------------------------*
FORM data_select .

  CLEAR : gt_znft0002, gt_znft0002[], gt_znft0069, gt_znft0069[].

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_znft0002
    FROM znft0002                 "월별 비철시세관리(기준정보)
   WHERE inmon = znft0002-inmon.  "입력월

* IF sy-subrc = 0.

  LOOP AT gt_znft0002.

    CASE gt_znft0002-nfkey.  "비철자재Key

      WHEN 'CU1'.
        gv_cu1_o_cash = gt_znft0002-o_cash.

      WHEN 'CU3'.
*       gv_cu3_o_cash = gt_znft0002-o_cash.
        gv_cu3_o_cash = gt_znft0002-o_cash / 1000.

      WHEN 'AL1'.
        gv_al1_o_cash = gt_znft0002-o_cash.

      WHEN 'AL2'.
        gv_al2_o_cash = gt_znft0002-o_cash / 1000.

      WHEN 'PB1'.
        gv_pb1_o_cash = gt_znft0002-o_cash.

      WHEN 'SN1'.
        gv_sn1_o_cash = gt_znft0002-o_cash.

      WHEN 'NI1'.
        gv_ni1_o_cash = gt_znft0002-o_cash.

      WHEN 'PE1'.
        gv_pe1_o_cash = gt_znft0002-o_cash.

    ENDCASE.

  ENDLOOP.

* ELSE.
*
*   MESSAGE s000 WITH '조건에 해당하는 자료가 없습니다.'.
*
* ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_znft0069
    FROM znft0069                 "월별 비철시세 이자관리(기준정보)
   WHERE inmon = znft0002-inmon.  "입력월

  LOOP AT gt_znft0069.

    CASE gt_znft0069-irkey.  "이자코드

      WHEN 'IR1'.
        gv_rate1 = gt_znft0069-rate.

      WHEN 'IR2'.
        gv_rate2 = gt_znft0069-rate.

    ENDCASE.

  ENDLOOP.

  IF gt_znft0002[] IS INITIAL AND gt_znft0069[] IS INITIAL.
    MESSAGE s000 WITH '조건에 해당하는 자료가 없습니다.'.
  ENDIF.

ENDFORM.                    " data_select

*&---------------------------------------------------------------------*
*&      Form  data_save
*&---------------------------------------------------------------------*
FORM data_save .

  DATA: lt_znft0002 LIKE znft0002 OCCURS 0 WITH HEADER LINE.
  DATA: lv_inmon LIKE znft0002-inmon,  "입력월
        lv_dest  LIKE zifdest-dest.

  CLEAR: lt_znft0002[], lt_znft0002,
         lv_dest.

  lv_inmon = znft0002-inmon.          "입력월

* CU1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'CU1'.
  znft0002-nftxt        = 'CU(LME)'.
  znft0002-o_cash       = gv_cu1_o_cash.
  znft0002-o_cash_waers = gv_cu1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* CU3
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'CU3'.
  znft0002-nftxt        = 'CU(LS-Nikko)'.
* znft0002-o_cash       = gv_cu3_o_cash.
  znft0002-o_cash       = gv_cu3_o_cash * 1000.
  znft0002-o_cash_waers = gv_cu3_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* AL1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'AL1'.
* znft0002-nftxt        = 'Aluminum'.
  znft0002-nftxt        = 'Aluminum(LME)'.
  znft0002-o_cash       = gv_al1_o_cash.
  znft0002-o_cash_waers = gv_al1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* AL2
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'AL2'.
  znft0002-nftxt        = 'Aluminum(KRW)'.
  znft0002-o_cash       = gv_al2_o_cash * 1000.
  znft0002-o_cash_waers = gv_al2_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* PB1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'PB1'.
  znft0002-nftxt        = 'Lead'.
  znft0002-o_cash       = gv_pb1_o_cash.
  znft0002-o_cash_waers = gv_pb1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* SN1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'SN1'.
  znft0002-nftxt        = 'Tin'.
  znft0002-o_cash       = gv_sn1_o_cash.
  znft0002-o_cash_waers = gv_sn1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* NI1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'NI1'.
  znft0002-nftxt        = 'Nickel'.
  znft0002-o_cash       = gv_ni1_o_cash.
  znft0002-o_cash_waers = gv_ni1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* PE1
  znft0002-inmon        = lv_inmon.
  znft0002-nfkey        = 'PE1'.
  znft0002-nftxt        = 'Polyethylene'.
  znft0002-o_cash       = gv_pe1_o_cash.
  znft0002-o_cash_waers = gv_pe1_o_cash_waers.
  znft0002-aenam        = sy-uname.
  znft0002-aedat        = sy-datum.
  znft0002-aezet        = sy-uzeit.

  MODIFY znft0002.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0002 TO lt_znft0002.
  APPEND lt_znft0002.

  CLEAR znft0002.

* 화면 100 입력월
  znft0002-inmon = lv_inmon.

* 이자 IR1
  znft0069-inmon = lv_inmon.
  znft0069-irkey = 'IR1'.
  znft0069-irtxt = '회사채'.
  znft0069-rate  = gv_rate1.
  znft0069-aenam = sy-uname.
  znft0069-aedat = sy-datum.
  znft0069-aezet = sy-uzeit.

  MODIFY znft0069.
  CLEAR znft0069.

* 이자 IR2
  znft0069-inmon = lv_inmon.
  znft0069-irkey = 'IR2'.
*.IR2를 CP+0.2%로 변경(Req.by 김유정)
* (C20110208_20134/11.02.08/EDB03)
  znft0069-irtxt = 'CP+0.2%'.
  znft0069-rate  = gv_rate2.
  znft0069-aenam = sy-uname.
  znft0069-aedat = sy-datum.
  znft0069-aezet = sy-uzeit.

  MODIFY znft0069.
  CLEAR znft0069.

*IF sy-uname NE 'ZLSGMM1'.
*
*  SELECT SINGLE dest INTO lv_dest
*    FROM zifdest
*   WHERE gubun EQ 'M1'.
*
** 해외 롤아웃 서버로 I/F
*  CALL FUNCTION 'Z_MM_RECV_ZNFT0002'
*    DESTINATION lv_dest
*    TABLES
*      t_inbound = lt_znft0002.
*ENDIF.

ENDFORM.                    " data_save

*&---------------------------------------------------------------------*
*&      Form  data_bdc
*&---------------------------------------------------------------------*
FORM data_bdc .

  CLEAR : bdctab, bdctab[], messtab, messtab[], t100.

  DATA : lv_cu1_o_cash(21),
         lv_cu3_o_cash(21),
         lv_al1_o_cash(21),
         lv_al2_o_cash(21),
         lv_pb1_o_cash(21),
         lv_datum LIKE sy-datum.

  lv_cu1_o_cash = gv_cu1_o_cash.
* lv_cu3_o_cash = gv_cu3_o_cash * 100.
  lv_cu3_o_cash = gv_cu3_o_cash * 100000.
  lv_al1_o_cash = gv_al1_o_cash.
  lv_al2_o_cash = gv_al2_o_cash * 100000.
  lv_pb1_o_cash = gv_pb1_o_cash.

  CONCATENATE znft0002-inmon '01' INTO lv_datum.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0100',
                         ' ' 'BDC_OKCODE'               '/00',
                         ' ' '/NFM/RATES_DIA-KDT'       lv_datum,
                         ' ' '/NFM/RATES_DIA-NKW'       'USD',
                         ' ' '/NFM/RATES_DIA-BOESL'     'LME',
                         ' ' 'T024E-EKORG'              ' ',
                         ' ' '/NFM/RATES_DIA-BUKRS'     ' ',
                         ' ' '/NFM/RATES_DIA-MKU'       'X'.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                         ' ' 'BDC_OKCODE'               '=KSLO',
                         ' ' '/NFM/RATES_DIA-SELKZ(01)' 'X',
                         ' ' '/NFM/RATES_DIA-SELKZ(02)' 'X',
                         ' ' '/NFM/RATES_DIA-SELKZ(03)' 'X'.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                         ' ' 'BDC_OKCODE'               '=SICH',
                         ' ' '/NFM/TRATES-NES(01)'      'CU',
                         ' ' '/NFM/TRATES-NKU(01)'      lv_cu1_o_cash,
                         ' ' '/NFM/TRATES-NES(02)'      'AL',
                         ' ' '/NFM/TRATES-NKU(02)'      lv_al1_o_cash,
                         ' ' '/NFM/TRATES-NES(03)'      'PB',
                         ' ' '/NFM/TRATES-NKU(03)'      lv_pb1_o_cash.

  CALL TRANSACTION '/NFM/RATM1' USING bdctab
                                 MODE hrvcost-mode
                               UPDATE 'S'
                             MESSAGES INTO messtab.

  READ TABLE messtab WITH KEY msgtyp = 'E'.

  IF sy-subrc = 0.

    SELECT SINGLE *
      FROM t100                     "메세지
     WHERE sprsl = messtab-msgspra  "언어 키
       AND arbgb = messtab-msgid    "어플리케이션영역
       AND msgnr = messtab-msgnr.   "메시지번호

    MESSAGE i000 WITH t100-text.    "메세지텍스트

  ELSE.

    CLEAR : bdctab, bdctab[], messtab, messtab[], t100.

    PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0100',
                           ' ' 'BDC_OKCODE'               '/00',
                           ' ' '/NFM/RATES_DIA-KDT'       lv_datum,
                           ' ' '/NFM/RATES_DIA-NKW'       'KRW',
                           ' ' '/NFM/RATES_DIA-BOESL'     'LOP',
                           ' ' 'T024E-EKORG'              ' ',
                           ' ' '/NFM/RATES_DIA-BUKRS'     ' ',
                           ' ' '/NFM/RATES_DIA-MKU'       'X'.

    PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                           ' ' 'BDC_OKCODE'               '=KSLO',
                           ' ' '/NFM/RATES_DIA-SELKZ(01)' 'X',
                           ' ' '/NFM/RATES_DIA-SELKZ(02)' 'X'.

    PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                           ' ' 'BDC_OKCODE'               '=SICH',
                           ' ' '/NFM/TRATES-NES(01)'      'CU',
                           ' ' '/NFM/TRATES-NKU(01)'      lv_cu3_o_cash,
                           ' ' '/NFM/TRATES-NES(02)'      'AL',
                           ' ' '/NFM/TRATES-NKU(02)'      lv_al2_o_cash.

    CALL TRANSACTION '/NFM/RATM1' USING bdctab
                                   MODE hrvcost-mode
                                 UPDATE 'S'
                               MESSAGES INTO messtab.

    READ TABLE messtab WITH KEY msgtyp = 'E'.

    IF sy-subrc = 0.

      SELECT SINGLE *
        FROM t100                     "메세지
       WHERE sprsl = messtab-msgspra  "언어 키
         AND arbgb = messtab-msgid    "어플리케이션영역
         AND msgnr = messtab-msgnr.   "메시지번호

      MESSAGE i000 WITH t100-text.    "메세지텍스트

    ELSE.

      PERFORM data_save.

    ENDIF.

  ENDIF.

ENDFORM.                    " data_bdc

*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       BDC RECORDING APPEND
*----------------------------------------------------------------------*
*      -->SCREEN
*      -->FIELD NAME
*      -->FIELD VALUE
*----------------------------------------------------------------------*
FORM dynpro USING dynbegin fnam fval.

  CLEAR bdctab.

  IF dynbegin = 'X'.

    bdctab-dynbegin = 'X'.
    bdctab-program  = fnam.
    bdctab-dynpro   = fval.

    APPEND bdctab.

  ELSE.

    bdctab-fnam = fnam.
    bdctab-fval = fval.

    APPEND bdctab.

  ENDIF.

ENDFORM.                    " DYNPRO

*&---------------------------------------------------------------------*
*&      Form  data_clear
*&---------------------------------------------------------------------*
FORM data_clear .

  CLEAR : gv_cu1_o_cash,
          gv_cu3_o_cash,
          gv_al1_o_cash,
          gv_al2_o_cash,
          gv_pb1_o_cash,
          gv_sn1_o_cash,
          gv_ni1_o_cash,
          gv_pe1_o_cash,

          gv_rate1,
          gv_rate2.

ENDFORM.                    " data_clear
