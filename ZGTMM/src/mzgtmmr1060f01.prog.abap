*&---------------------------------------------------------------------*
*&  Include           MZNF0010F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_select
*&---------------------------------------------------------------------*
FORM data_select .

  CLEAR : gt_znft0001, gt_znft0001[].

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_znft0001
    FROM znft0001                 "일별 비철시세관리(기준정보)
   WHERE indat = znft0001-indat.  "입력일

  IF sy-subrc = 0.

    LOOP AT gt_znft0001.

      CASE gt_znft0001-nfkey.  "비철자재Key

        WHEN 'CU1'.
          gv_cu1_o_cash = gt_znft0001-o_cash.
          gv_cu1_c_cash = gt_znft0001-c_cash.
          gv_cu1_c_3m   = gt_znft0001-c_3m.
          gv_cu1_spread = gt_znft0001-spread.
          gv_cu1_stock  = gt_znft0001-stock.
          gv_cu1_c_6m   = gt_znft0001-c_6m.

        WHEN 'CU2'.
          gv_cu2_c_cash  = gt_znft0001-c_cash.
          gv_cu2_stock   = gt_znft0001-stock.
          gv_cu2_shfe_1m = gt_znft0001-shfe_1m.
          gv_cu3_c_cash  = gt_znft0001-c_cash.
          gv_cu2_shfe_logic1 = gt_znft0001-c_vat.
          gv_cu2_shfe_logic2 = gt_znft0001-c_exchange.

        WHEN 'AL1'.
          gv_al1_o_cash = gt_znft0001-o_cash.
          gv_al1_c_cash = gt_znft0001-c_cash.
          gv_al1_c_3m   = gt_znft0001-c_3m.
          gv_al1_spread = gt_znft0001-spread.
          gv_al1_stock  = gt_znft0001-stock.
          gv_al1_c_6m   = gt_znft0001-c_6m.

        WHEN 'PB1'.
          gv_pb1_o_cash = gt_znft0001-o_cash.
          gv_pb1_c_cash = gt_znft0001-c_cash.
          gv_pb1_c_3m   = gt_znft0001-c_3m.
          gv_pb1_spread = gt_znft0001-spread.
          gv_pb1_stock  = gt_znft0001-stock.
          gv_pb1_c_6m   = gt_znft0001-c_6m.

        WHEN 'NI1'.
          gv_ni1_o_cash = gt_znft0001-o_cash.
          gv_ni1_c_cash = gt_znft0001-c_cash.
          gv_ni1_c_3m   = gt_znft0001-c_3m.
          gv_ni1_spread = gt_znft0001-spread.

        WHEN 'SN1'.
          gv_sn1_o_cash = gt_znft0001-o_cash.
          gv_sn1_c_cash = gt_znft0001-c_cash.

        WHEN 'PE1'.
          gv_pe1_o_cash = gt_znft0001-o_cash.
          gv_pe1_c_cash = gt_znft0001-c_cash.

      ENDCASE.

    ENDLOOP.

    IF     gv_cu1_spread > 0.
      gv_cu1_c_b = 'c'.
    ELSEIF gv_cu1_spread < 0.
      gv_cu1_c_b = 'b'.
    ENDIF.

    IF     gv_al1_spread > 0.
      gv_al1_c_b = 'c'.
    ELSEIF gv_al1_spread < 0.
      gv_al1_c_b = 'b'.
    ENDIF.

    IF     gv_pb1_spread > 0.
      gv_pb1_c_b = 'c'.
    ELSEIF gv_pb1_spread < 0.
      gv_pb1_c_b = 'b'.
    ENDIF.

    IF     gv_ni1_spread > 0.
      gv_ni1_c_b = 'c'.
    ELSEIF gv_ni1_spread < 0.
      gv_ni1_c_b = 'b'.
    ENDIF.

  ELSE.

    MESSAGE s000 WITH '조건에 해당하는 자료가 없습니다.'.

  ENDIF.

ENDFORM.                    " data_select

*&---------------------------------------------------------------------*
*&      Form  data_save
*&---------------------------------------------------------------------*
FORM data_save .

  DATA: lt_znft0001 LIKE znft0001 OCCURS 0 WITH HEADER LINE.
  DATA: lv_indat LIKE znft0001-indat,  "입력일
        lv_dest  LIKE zifdest-dest.

  CLEAR: lt_znft0001[], lt_znft0001, lv_dest.

  lv_indat = znft0001-indat.          "입력일

* CU1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'CU1'.
  znft0001-nftxt        = 'CU(LME)'.
  znft0001-o_cash       = gv_cu1_o_cash.
  znft0001-o_cash_waers = gv_cu1_o_cash_waers.
  znft0001-c_cash       = gv_cu1_c_cash.
  znft0001-c_cash_waers = gv_cu1_c_cash_waers.
  znft0001-c_3m         = gv_cu1_c_3m.
  znft0001-c_3m_waers   = gv_cu1_c_3m_waers.
  znft0001-spread       = gv_cu1_spread.
  znft0001-spread_waers = gv_cu1_spread_waers.
  znft0001-stock        = gv_cu1_stock.
  znft0001-meins        = gv_cu1_meins.
  znft0001-c_6m         = gv_cu1_c_6m.
  znft0001-c_6m_waers   = gv_cu1_c_6m_waers.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* CU2
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'CU2'.
* znft0001-nftxt        = 'CU(COMEX)'.
  znft0001-nftxt        = 'CU(SHFE)'.
  znft0001-c_cash       = gv_cu2_c_cash.
  znft0001-c_cash_waers = gv_cu2_c_cash_waers.
  znft0001-stock        = gv_cu2_stock.
  znft0001-meins        = gv_cu2_meins.
  znft0001-shfe_1m      = gv_cu2_shfe_1m.
  znft0001-c_vat          = gv_cu2_shfe_logic1.
  znft0001-c_exchange     = gv_cu2_shfe_logic2.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* AL1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'AL1'.
  znft0001-nftxt        = 'Aluminum'.
  znft0001-o_cash       = gv_al1_o_cash.
  znft0001-o_cash_waers = gv_al1_o_cash_waers.
  znft0001-c_cash       = gv_al1_c_cash.
  znft0001-c_cash_waers = gv_al1_c_cash_waers.
  znft0001-c_3m         = gv_al1_c_3m.
  znft0001-c_3m_waers   = gv_al1_c_3m_waers.
  znft0001-spread       = gv_al1_spread.
  znft0001-spread_waers = gv_al1_spread_waers.
  znft0001-stock        = gv_al1_stock.
  znft0001-meins        = gv_al1_meins.
  znft0001-c_6m         = gv_al1_c_6m.
  znft0001-c_6m_waers   = gv_al1_c_6m_waers.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* PB1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'PB1'.
  znft0001-nftxt        = 'Lead'.
  znft0001-o_cash       = gv_pb1_o_cash.
  znft0001-o_cash_waers = gv_pb1_o_cash_waers.
  znft0001-c_cash       = gv_pb1_c_cash.
  znft0001-c_cash_waers = gv_pb1_c_cash_waers.
  znft0001-c_3m         = gv_pb1_c_3m.
  znft0001-c_3m_waers   = gv_pb1_c_3m_waers.
  znft0001-spread       = gv_pb1_spread.
  znft0001-spread_waers = gv_pb1_spread_waers.
  znft0001-stock        = gv_pb1_stock.
  znft0001-meins        = gv_pb1_meins.
  znft0001-c_6m         = gv_pb1_c_6m.
  znft0001-c_6m_waers   = gv_pb1_c_6m_waers.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* NI1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'NI1'.
  znft0001-nftxt        = 'Nickel'.
  znft0001-o_cash       = gv_ni1_o_cash.
  znft0001-o_cash_waers = gv_ni1_o_cash_waers.
  znft0001-c_cash       = gv_ni1_c_cash.
  znft0001-c_cash_waers = gv_ni1_c_cash_waers.
  znft0001-c_3m         = gv_ni1_c_3m.
  znft0001-c_3m_waers   = gv_ni1_c_3m_waers.
  znft0001-spread       = gv_ni1_spread.
  znft0001-spread_waers = gv_ni1_spread_waers.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* SN1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'SN1'.
  znft0001-nftxt        = 'Tin'.
  znft0001-o_cash       = gv_sn1_o_cash.
  znft0001-o_cash_waers = gv_sn1_o_cash_waers.
  znft0001-c_cash       = gv_sn1_c_cash.
  znft0001-c_cash_waers = gv_sn1_c_cash_waers.
  znft0001-meins        = 'TON'.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* PE1
  znft0001-indat        = lv_indat.
  znft0001-nfkey        = 'PE1'.
  znft0001-nftxt        = 'Polyethylene'.
  znft0001-o_cash       = gv_pe1_o_cash.
  znft0001-o_cash_waers = gv_pe1_o_cash_waers.
  znft0001-c_cash       = gv_pe1_c_cash.
  znft0001-c_cash_waers = gv_pe1_c_cash_waers.
  znft0001-aenam        = sy-uname.
  znft0001-aedat        = sy-datum.
  znft0001-aezet        = sy-uzeit.

  MODIFY znft0001.

*-. 2007.12.31 Modified By SHIN
*-. 해외 롤아웃 I/F
  MOVE-CORRESPONDING znft0001 TO lt_znft0001.
  APPEND lt_znft0001.

  CLEAR znft0001.

* 화면 100 입력일
  znft0001-indat = lv_indat.
*
*IF sy-uname NE 'ZLSGMM1'.
*  SELECT SINGLE dest INTO lv_dest
*    FROM zifdest
*   WHERE gubun EQ 'M1'.
*
** 해외 롤아웃 서버로 I/F
*  CALL FUNCTION 'Z_MM_RECV_ZNFT0001'
*    DESTINATION lv_dest
*    TABLES
*      t_inbound = lt_znft0001.
*  ENDIF.

ENDFORM.                    " data_save

*&---------------------------------------------------------------------*
*&      Form  data_bdc
*&---------------------------------------------------------------------*
FORM data_bdc .

  CLEAR : bdctab, bdctab[], messtab, messtab[], t100.

  DATA : lv_cu1_o_cash(21),
         lv_al1_o_cash(21),
         lv_pb1_o_cash(21).

  lv_cu1_o_cash = gv_cu1_o_cash.
  lv_al1_o_cash = gv_al1_o_cash.
  lv_pb1_o_cash = gv_pb1_o_cash.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0100',
                         ' ' 'BDC_OKCODE'               '/00',
                         ' ' '/NFM/RATES_DIA-KDT'       znft0001-indat,
                         ' ' '/NFM/RATES_DIA-NKW'       'USD',
                         ' ' '/NFM/RATES_DIA-BOESL'     'LME',
                         ' ' 'T024E-EKORG'              ' ',
                         ' ' '/NFM/RATES_DIA-BUKRS'     ' ',
                         ' ' '/NFM/RATES_DIA-TKU'       'X'.

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

    PERFORM data_save.

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
    bdctab-program = fnam.
    bdctab-dynpro = fval.

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
          gv_cu1_c_cash,
          gv_cu1_c_3m,
          gv_cu1_c_b,
          gv_cu1_spread,
          gv_cu1_stock,
          gv_cu1_c_6m,

          gv_cu2_c_cash,
          gv_cu2_stock,
          gv_cu2_shfe_1m,

          gv_al1_o_cash,
          gv_al1_c_cash,
          gv_al1_c_3m,
          gv_al1_c_b,
          gv_al1_spread,
          gv_al1_stock,
          gv_al1_c_6m,

          gv_pb1_o_cash,
          gv_pb1_c_cash,
          gv_pb1_c_3m,
          gv_pb1_c_b,
          gv_pb1_spread,
          gv_pb1_stock,
          gv_pb1_c_6m,

          gv_ni1_o_cash,
          gv_ni1_c_cash,
          gv_ni1_c_3m,
          gv_ni1_c_b,
          gv_ni1_spread,

          gv_sn1_o_cash,
          gv_sn1_c_cash,

          gv_pe1_o_cash,
          gv_pe1_c_cash.

ENDFORM.                    " data_clear
*&---------------------------------------------------------------------*
*&      Form  DATA_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_delete .

  DATA : ls_znft0001 LIKE znft0001,
         lt_znft0001 LIKE znft0001 OCCURS 0 WITH HEADER LINE.

  CLEAR : ls_znft0001, lt_znft0001, lt_znft0001[].


*...화면 100 입력일 데이터 인터널테이블에 저장
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE lt_znft0001
  FROM znft0001
  WHERE indat = znft0001-indat.


*...화면 100 입력일 CBO 데이터 삭제
  LOOP AT lt_znft0001.
    MOVE-CORRESPONDING lt_znft0001 TO ls_znft0001.
    DELETE znft0001 FROM ls_znft0001.
  ENDLOOP.

  IF sy-subrc = '0'.
    MESSAGE s398(00) WITH lt_znft0001-indat '자료가 삭제 되었습니다.'.
  ENDIF.

  PERFORM data_clear.


ENDFORM.                    " DATA_DELETE
*&---------------------------------------------------------------------*
*&      Form  DATA_BDC_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_bdc_delete .

  CLEAR : bdctab, bdctab[], messtab, messtab[].

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0100',
                         ' ' 'BDC_OKCODE'               '/00',
                         ' ' '/NFM/RATES_DIA-KDT'       znft0001-indat,
                         ' ' '/NFM/RATES_DIA-NKW'       'USD',
                         ' ' '/NFM/RATES_DIA-BOESL'     'LME',
                         ' ' 'T024E-EKORG'              ' ',
                         ' ' '/NFM/RATES_DIA-BUKRS'     ' ',
                         ' ' '/NFM/RATES_DIA-TKU'       'X'.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                         ' ' 'BDC_OKCODE'               '=KSLO',
                         ' ' '/NFM/RATES_DIA-SELKZ(01)' 'X',
                         ' ' '/NFM/RATES_DIA-SELKZ(02)' 'X',
                         ' ' '/NFM/RATES_DIA-SELKZ(03)' 'X'.

  PERFORM dynpro USING : 'X' '/NFM/SAPLRATES'           '0101',
                         ' ' 'BDC_OKCODE'               '=SICH'.

  CALL TRANSACTION '/NFM/RATM1' USING bdctab
                                 MODE hrvcost-mode
                               UPDATE 'S'
                             MESSAGES INTO messtab.

*... BDC 후 삭제 PERFORM
  IF sy-subrc = 0.
    PERFORM data_delete.
  ENDIF.

ENDFORM.                    " DATA_BDC_DELETE
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_check .
  DATA : ls_znft0001 LIKE znft0001.

* 입력일의 자료가 CBO 테이블에 있는지 확인
  SELECT SINGLE *
  INTO ls_znft0001
  FROM znft0001
  WHERE indat = znft0001-indat.

  IF sy-subrc = 0.
    PERFORM popup_to_confirm.

    IF gv_answer = '1'.
      PERFORM data_bdc_delete.
    ENDIF.

  ELSE.
    MESSAGE s398(00) WITH '해당 날짜의 자료가 없습니다.' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " DATA_CHECK
