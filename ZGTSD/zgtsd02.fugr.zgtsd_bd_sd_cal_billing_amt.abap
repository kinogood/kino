FUNCTION zgtsd_bd_sd_cal_billing_amt.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VBELN) LIKE  LIPS-VBELN OPTIONAL
*"     VALUE(I_POSNR) LIKE  LIPS-POSNR OPTIONAL
*"     VALUE(I_NETWR) LIKE  VBAK-NETWR OPTIONAL
*"     VALUE(I_WAERS) LIKE  KOMV-WAERS OPTIONAL
*"  EXPORTING
*"     VALUE(E_NETWR) LIKE  VBAK-NETWR
*"     VALUE(E_NETWR_GAP) LIKE  VBAK-NETWR
*"     VALUE(E_MWSBP) LIKE  VBAP-MWSBP
*"----------------------------------------------------------------------

  DATA : ls_vbak LIKE vbak,
         ls_vbap LIKE vbap,
         ls_lips LIKE lips,
         ls_mcha LIKE mcha,
         ls_0067 LIKE zgtsdt0067.
  DATA : ls_konv LIKE konv.
  DATA : lv_lfimg LIKE lips-lfimg,
         lv_qamt  LIKE zgtsdt0066-qamt,
         lv_qty   LIKE zgtsdt0066-Qqty.
  DATA : lv_kbetr LIKE konv-kbetr.
  DATA : lt_lips TYPE TABLE OF lips WITH HEADER LINE.
  DATA : lt_mch1 TYPE TABLE OF mch1 WITH HEADER LINE  .
  DATA : lt_0067 TYPE TABLE OF zgtsdt0067 WITH HEADER LINE,
         lt_0066 TYPE TABLE OF zgtsdt0066 WITH HEADER LINE.
  DATA : lv_vbeln  LIKE vbak-vbeln,
         lv_posnr  LIKE vbaP-posnr,
         lv_amount LIKE zgtsdt0066-qamt,
         lv_qqty   LIKE zgtsdt0067-qqty,
         lv_qunit  LIKE zgtsdt0067-qunit.

  DATA : BEGIN OF lt_itab OCCURS 0 .
  DATA :job_no LIKE zgtsdt0066-job_no,
        qcode  LIKE zgtsdt0066-qcode,
        qqty   LIKE zgtsdt0067-qqty.

  DATA : END OF lt_itab.

*____ 판매오더 찾기
  SELECT SINGLE vgbel vgpos
    INTO ( lv_vbeln , lv_posnr )
    FROM lips
    WHERE vbeln = i_vbeln
    AND posnr = I_posnr.

*___ 납품정보 찾기.
  SELECT SINGLE *
    INTO ls_lips
    FROM lips
    WHERE vbeln = i_vbeln
    AND posnr = I_posnr
    AND uecha = ' '.

*___ 판매오더 찾아오기
  SELECT SINGLE *
    INTO ls_vbak
    FROM vbak
    WHERE vbeln = lv_vbeln.

  SELECT SINGLE *
    INTO ls_vbap
    FROM vbap
    WHERE vbeln = lv_vbeln
    AND posnr = lv_posnr.

*___ 납품수량 찾기
  SELECT SINGLE SUM( lfimg )
    INTO lv_lfimg
    FROM lips
    WHERE vbeln = i_vbeln
    AND uecha = i_posnr.

  lv_lfimg = lv_lfimg + ls_lips-lfimg.


*___ 판매오더와 납품수량 비교
  CHECK lv_lfimg <> LS_vbap-kwmeng.


*___ 판매오더의 조정 금액 가져오기
  SELECT SINGLE *
    INTO ls_konv
    FROM konv
    WHERE knumv = ls_vbak-knumv
    AND kposn = lv_posnr
    AND kschl = 'ZIB0'.
  IF sy-subrc = 0.
    lv_kbetr = ls_konv-kbetr * lv_lfimg / ls_vbap-kwmeng.
    i_netwr = i_netwr + lv_kbetr.
  ENDIF.



*___ 납품 정보가져오기
  IF ls_vbap-xchar = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_lips
      FROM  lips
      WHERE vbeln = @i_vbeln
      AND ( posnr = @I_posnr OR uecha = @I_posnr )
      AND charg <> ' '.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_lips
      FROM  lips
      WHERE vbeln = @i_vbeln
      AND ( posnr = @I_posnr OR uecha = @I_posnr ).
  ENDIF.
  CHECK sy-subrc = 0.

*___ 배치정보가져오기
  IF ls_vbap-xchar = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE  lt_mch1
      FROM mch1
      FOR ALL ENTRIES IN lt_lips
      WHERE matnr = lt_lips-matnr
      AND charg = lt_lips-charg.
    CHECK lt_mch1[] IS NOT INITIAL.
  ENDIF.

*___ 견적정보 가져오기.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_0067
    FROM zgtsdt0067
    WHERE vbeln = lv_vbeln
    AND posnr = lv_posnr.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_0066
    FROM zgtsdt0066
    WHERE vbeln = lv_vbeln
    AND posnr = lv_posnr.

*___ 출고된 배치정보의 견적정보를 찾아 금액 계산
  IF ls_vbap-xchar = 'X'.
    LOOP AT lt_mch1.
      CLEAR : lv_qqty, lv_qunit.
      LOOP AT lt_0067 WHERE job_no = lt_mch1-zzjob_no
                             AND    line_no = lt_mch1-zzline_no
                             AND   serial_info = lt_mch1-zzserial_info.
        lt_itab-qcode = lt_0067-qcode.
        lt_itab-job_no = lt_0067-job_no.
        lt_itab-qqty = lt_0067-qqty.
        COLLECT lt_itab. CLEAR lt_itab.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_itab.
      CLEAR : lt_0066.
      READ TABLE lt_0066 WITH KEY job_no = lt_itab-job_no
                                            posnr = lv_posnr
                                           qcode = lt_itab-qcode.
      lv_qamt = round( val = lt_0066-qprice * lt_itab-qqty  dec = 2
           mode = cl_abap_math=>round_half_up ).
      lv_amount = lv_amount + lv_qamt.
    ENDLOOP.


  ELSE.
    LOOP AT lt_0067 WHERE vbeln = lv_vbeln AND posnr = lv_posnr.
      CLEAR : lt_0066.
      READ TABLE lt_0066 WITH KEY job_no = lt_0067-job_no
                                            posnr = lv_posnr
                                            qcode = lt_0067-qcode.
      lt_itab-qcode = lt_0067-qcode.
      lt_itab-job_no = lt_0067-job_no.
      lt_itab-qqty = lt_0067-qqty.
      COLLECT lt_itab. CLEAR lt_itab.
    ENDLOOP.

    LOOP AT lt_itab.
      CLEAR : lt_0066.
      READ TABLE lt_0066 WITH KEY job_no = lt_itab-job_no
                                            posnr = lv_posnr
                                           qcode = lt_itab-qcode.
      lv_qamt = round( val = lt_0066-qprice * lt_itab-qqty  dec = 2
           mode = cl_abap_math=>round_half_up ).
      lv_amount = lv_amount + lv_qamt.
    ENDLOOP.

  ENDIF.

  IF i_netwr <> lv_amount AND lv_amount <> 0 .
    e_netwr_gap =  lv_amount - i_netwr.
    e_netwr = lv_amount.
    e_mwsbp = lv_amount * ( 1 / 10 ) .
  ENDIF.







ENDFUNCTION.
