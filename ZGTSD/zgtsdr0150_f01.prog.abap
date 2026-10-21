*&---------------------------------------------------------------------*
*& Include          ZGTSDR0150_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SELECTOPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selectoption .
  LOOP AT SCREEN.
    IF screen-name = 'S_SPART-LOW'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lt_values TYPE STANDARD TABLE OF dd07v,
        ls_value  TYPE dd07v.

  CLEAR: gs_billing.
  REFRESH: gt_billing.

  SELECT DISTINCT b~zvkbur AS vkbur,
*                  E~VKGRP,
*                  E~VTWEG,
                  b~kunnr,
                  a~zpjt_no AS zpjno,
                  b~zptxt,
                  a~zzjob_type,
                  a~zjob_no AS job_no,
                  a~zjob_name AS job_name,
                  d~vbeln,
                  b~spart,
                  a~zdeliv_date,
                  c~rohcost,
                  c~subconcost,
                  c~insulcost,
                  c~condprdcost,
                  c~assycost,
                  c~cogm,
*                  C~CMAMT,
*                  C~CMRTE,
                  c~waerk,
                  e~netwr AS netwrt,
                  a~zwerks AS werks,
                  e~waerk AS waerkv,
                  f~prsdt
  FROM zgtedt2121 AS a
    INNER JOIN zsd0106t AS b
       ON a~zpjt_no = b~zpjno
    LEFT OUTER JOIN zgtsdt0077 AS c
       ON a~zpjt_no = c~zpjno
      AND a~zjob_no = c~job_no
    LEFT OUTER JOIN zgtsdt0065 AS d
       ON a~zpjt_no = d~zpjno
      AND a~zjob_no = d~job_no
    LEFT OUTER JOIN vbak AS e
      ON a~zpjt_no = e~zpjno
     AND d~vbeln = e~vbeln
    LEFT OUTER JOIN vbkd AS f
      ON e~vbeln = f~vbeln
     AND f~posnr = '000000'
  INTO CORRESPONDING FIELDS OF TABLE @gt_data
  WHERE  a~crdat IN @s_crdat
    AND  b~zvkbur IN @s_vkbur
    AND  a~zjob_no IN @s_jobno
    AND  A~ZPJT_NO IN @S_ZPJNO
    AND  b~erdat  IN @s_erdat
    AND  a~zwerks  IN @s_werks.
*    AND E~VTWEG IN @S_VTWEG
*    AND E~SPART IN @S_SPART
*    AND E~VKGRP IN @S_VKGRP
*    AND B~KUNNR IN @S_KUNNR
*    AND E~VKORG IN @S_VKORG.


  LOOP AT gt_data INTO gs_data.
    "고객명
    SELECT SINGLE name1
      FROM kna1
      INTO gs_data-name1
      WHERE kunnr = gs_data-kunnr.

    "제조지시구분
    SELECT SINGLE fld_03
      FROM zgtppt1010
      INTO gs_data-fld_03
      WHERE module_kind = 'ED'
        AND codegrp = '2002'
        AND fld_02 = gs_data-zzjob_type.


    "매출금액
    PERFORM get_netwr  USING gs_data-vbeln
                       CHANGING gs_data-netwr.

    "견적금액
    PERFORM get_netwrt USING gs_data-waerkv
                       CHANGING gs_data-netwrt.

    "한계이익
    PERFORM get_hangye.

    "적송여부
    PERFORM get_jeoksong USING gs_data-vbeln
                               gs_data-zbcf.

    IF gs_data-waerk IS INITIAL.
      gs_data-waerk = gv_krw.
    ENDIF.

    MODIFY gt_data FROM gs_data.
    CLEAR: gs_data, ls_value.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_date .
  DATA: lv_datum TYPE sy-datum.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      months    = 1
      days      = 0
      years     = 0
      signum    = '-'
    IMPORTING
      calc_date = lv_datum.

  _range: s_crdat 'I' 'BT' lv_datum sy-datum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_hotspot  USING    p_column_id TYPE lvc_s_col
                              ps_row_no TYPE lvc_s_roid.

  READ TABLE gt_data INTO gs_data INDEX ps_row_no-row_id.
  IF sy-subrc = 0.
    CASE p_column_id-fieldname.
      WHEN 'VBELN'.
        SET PARAMETER ID 'AUN' FIELD gs_data-vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      WHEN 'JOB_NO'.
        DATA: lt_sel TYPE TABLE OF rsparams,
              ls_sel TYPE rsparams.

        CLEAR ls_sel.
        ls_sel-selname = 'S_JOBNO'.
        ls_sel-kind    = 'S'.
        ls_sel-sign    = 'I'.
        ls_sel-option  = 'EQ'.
        ls_sel-low     = '10001'.
        APPEND ls_sel TO lt_sel.

        SUBMIT zgtedi2040 WITH p_werks = gs_data-werks
                          WITH SELECTION-TABLE lt_sel
                          AND RETURN.
      WHEN 'KUNNR'.
        SET PARAMETER ID 'KUN' FIELD gs_data-kunnr.
*        SET PARAMETER ID 'VKO' FIELD S_VKORG-LOW.
*        SET PARAMETER ID 'VTW' FIELD GS_DATA-VTWEG.
*        SET PARAMETER ID 'SPA' FIELD GS_DATA-SPART.
        CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.
    ENDCASE.

    CLEAR: gs_data.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JEOKSONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA_VBELN
*&---------------------------------------------------------------------*
FORM get_jeoksong  USING    pv_vbeln
                            pv_zbcf.

  RANGES : r_xblnr FOR zmseg-xblnr.
  DATA: lv_wadat LIKE likp-wAdat_ist.
  DATA: lv_wadat_IST LIKE likp-wAdat_ist.
  DATA: lv_kdkg4 LIKE vbkd-kdkg4.


  DATA : BEGIN OF lt_likp OCCURS 0 .
  DATA : vbeln LIKE likp-vbeln.
  DATA : zbcf LIKE likp-zbcf.
  DATA : END OF lt_likp.

  DATA : BEGIN OF lt_zmseg OCCURS 0 .
  DATA :
    sjahr LIKE zmseg-sjahr,
    smbln LIKE zmseg-smbln.
  DATA : END OF lt_zmseg .

  DATA : BEGIN OF Lt_zmseg2 OCCURS 0 .
  DATA :
    mblnr     LIKE zmseg-mblnr,
    mjahr     LIKE zmseg-mjahr,
    zeile     LIKE zmseg-zeile,
    sjahr     LIKE zmseg-sjahr,
    smbln     LIKE zmseg-smbln,
    bwart     LIKE zmseg-bwart,
    mat_kdauf LIKE zmseg-mat_kdauf,
    mat_kdpos LIKE zmseg-mat_kdpos,
    posnr     LIKE lips-posnr,
    uecha     LIKE lips-uecha,
    menge     LIKE zmseg-menge,
    shkzg     LIKE matdoc-shkzg,
    budat     LIKE matdoc-budat.
  DATA : END OF Lt_zmseg2.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_likp
    FROM likp AS h
    INNER JOIN lips AS i
    ON h~vbeln EQ i~vbeln
    WHERE i~vgbel = pv_vbeln.

  SORT lt_likp.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING ALL FIELDS.

  SELECT SINGLE kdkg4
    INTO lv_kdkg4
    FROM vbkd
    WHERE vbeln = pv_vbeln.

  IF lv_kdkg4 = '4D' OR lv_kdkg4 = '4L'.


    CHECK lt_likp[] IS NOT INITIAL.

    r_XBLNR[] = VALUE #( FOR ls_tmp IN lt_likp
                         ( sign = 'I'
                           option = 'EQ'
                           low = ls_tmp-vbeln
                           high = '' ) ).
    SORT r_xblnr.
    DELETE ADJACENT DUPLICATES FROM r_xblnr COMPARING ALL FIELDS.

    REFRESH : lt_zmseg2.
    SELECT
      mat~mblnr AS mblnr
      mat~mjahr AS mjahr
*    mat~zeile AS zeile
      mat~sjahr AS sjahr
      mat~smbln AS smbln
      mat~bwart AS bwart
      mat~budat AS budat
      INTO CORRESPONDING FIELDS OF TABLE Lt_zmseg2
      FROM matdoc AS mat
      WHERE xblnr IN r_xblnr.

    lt_zmseg[] = VALUE #( FOR ls_tmp2 IN Lt_zmseg2
                         ( sjahr = ls_tmp2-sjahr
                           smbln = ls_tmp2-smbln ) ).
    SORT lt_zmseg BY sjahr smbln.
    DELETE ADJACENT DUPLICATES FROM lt_zmseg COMPARING ALL FIELDS.

    SORT lt_zmseg2 BY budat mjahr mblnr zeile .
    LOOP AT Lt_zmseg2.
      READ TABLE lt_zmseg WITH KEY sjahr = Lt_zmseg2-mjahr smbln = Lt_zmseg2-mblnr BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE lt_zmseg2.
      ENDIF.
      IF lt_zmseg2-bwart = '687'.
        lv_wadat = lt_zmseg2-budat.
      ENDIF.
      IF lt_zmseg2-bwart = '601'.
        lv_wadat_IST = lt_zmseg2-budat.
      ENDIF.
    ENDLOOP.

    IF lv_wadat_ist IS INITIAL AND
       lv_wadat+0(6) <> sy-datum+0(6).
      pv_zbcf = 'X'.
    ENDIF.
    IF lv_wadat_ist IS NOT INITIAL AND
       lv_wadat+0(6) <> lv_wadat_ist+0(6).
      pv_zbcf = 'X'.
    ENDIF.


  ELSE."수출
    READ TABLE lt_likp WITH KEY zbcf = 'X'.
    IF sy-subrc = 0 .
      pv_zbcf = 'X'.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HANGYE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_hangye .

  IF gs_data-waerkv <> 'KRW'.
    CALL FUNCTION 'CONVERT_AMOUNT_TO_CURRENCY'
      EXPORTING
        date             = sy-datum
        foreign_currency = gs_data-waerkv
        foreign_amount   = gs_data-netwrt
        local_currency   = gv_krw
      IMPORTING
        local_amount     = gs_data-netwrt
*       TABLES
*       t_c_errors       =
      EXCEPTIONS
        error            = 1
        OTHERS           = 2.

  ENDIF.

  IF gs_data-waerk <> 'KRW'.
    CALL FUNCTION 'CONVERT_AMOUNT_TO_CURRENCY'
      EXPORTING
        date             = sy-datum
        foreign_currency = gs_data-waerk
        foreign_amount   = gs_data-cogm
        local_currency   = gv_krw
      IMPORTING
        local_amount     = gs_data-cogm
*       TABLES
*       t_c_errors       =
      EXCEPTIONS
        error            = 1
        OTHERS           = 2.
  ENDIF.

  IF gs_data-netwrt <> 0.
    "한계이익
    IF gs_data-netwrt < gs_data-cogm.
      gs_data-cmamt = 0.
    ELSE.
      gs_data-cmamt = gs_data-netwrt - gs_data-cogm.
    ENDIF.

    "한계이익률
    TRY.
        " 한계이익률 = (한계이익 / 견적가) * 100
        gs_data-cmrte = round(
          val = ( gs_data-cmamt / gs_data-netwrt ) * 100
          dec = 0   " 소수점 첫째 자리에서 반올림
        ).

      CATCH cx_sy_zerodivide.
        gs_data-cmrte = 0.
    ENDTRY.

  ELSE.
    gs_data-cmamt = 0.
    gs_data-cmrte = 0.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NETWR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_netwrt  USING pv_waerkv
                 CHANGING pv_netwrt .

  CHECK ( pv_netwrt IS INITIAL OR pv_waerkv NE gv_krw ).

  CLEAR: gs_billing.

  IF pv_waerkv NE gv_krw.
    CALL FUNCTION 'CONVERT_AMOUNT_TO_CURRENCY'
      EXPORTING
        date             = gs_data-prsdt
        foreign_currency = pv_waerkv
        foreign_amount   = pv_netwrt
        local_currency   = gv_krw
      IMPORTING
        local_amount     = pv_netwrt
*           TABLES
*       T_C_ERRORS       =
      EXCEPTIONS
        error            = 1
        OTHERS           = 2.

    gs_data-waerkv = gv_krw.

  ELSEIF pv_netwrt IS INITIAL.
    SELECT SINGLE SUM( qamt ) AS qamt,
                  qwaerk
    INTO @DATA(ls_0066)
    FROM zgtsdt0066
    WHERE job_no = @gs_data-job_no
    GROUP BY job_no, qwaerk.
    IF sy-subrc = 0.
      IF ls_0066-qwaerk <> gv_krw.
        CALL FUNCTION 'CONVERT_AMOUNT_TO_CURRENCY'
          EXPORTING
            date             = sy-datum
            foreign_currency = ls_0066-qwaerk
            foreign_amount   = ls_0066-qamt
            local_currency   = gv_krw
          IMPORTING
            local_amount     = pv_netwrt
*           TABLES
*           T_C_ERRORS       =
          EXCEPTIONS
            error            = 1
            OTHERS           = 2.

        gs_data-waerkv = gv_krw.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NETWR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_netwr USING pv_vbeln
               CHANGING pv_netwr.


  DATA :BEGIN OF lt_vbrp OCCURS 0 .
  DATA :
    netwr LIKE vbrp-netwr,
    waerk LIKE vbrk-waerk,
    kurrf LIKE vbrk-kurrf.
  DATA : END OF lt_vbrp.

  DATA : lv_netwr LIKE vbak-netwr.

  SELECT
    h~waerk AS waerk
    h~kurrf AS kurrf
    i~netwr AS netwr
    INTO CORRESPONDING FIELDS OF TABLE lt_vbrp
    FROM vbrk AS h
    INNER JOIN vbrp AS i
      ON h~vbeln EQ i~vbeln
    WHERE i~aubel = pv_vbeln
    AND h~sfakn = ' '
    AND h~FKSTO = ' '.

  LOOP AT lt_vbrp.
    PERFORM decimal_point_compute_dmbtr USING lt_vbrp-waerk.

    IF lt_vbrp-waerk = 'KRW'.
      lv_netwr = lv_netwr + ( lt_vbrp-netwr  / gv_point  ).
    ELSEIF lt_vbrp-waerk = 'JPY'.
      lv_netwr = lv_netwr +  ( lt_vbrp-netwr * lt_vbrp-kurrf / 100 /  gv_point  ) .
    ELSE.
      lv_netwr = lv_netwr +  ( lt_vbrp-netwr * lt_vbrp-kurrf /   gv_point  ).
    ENDIF.
  ENDLOOP.

  pv_netwr = lv_netwr.

ENDFORM.
FORM decimal_point_compute_dmbtr  USING    p_gt_billdata_waerk.
  gv_point = 1.

  CLEAR tcurx.

  SELECT  SINGLE currdec
    FROM  tcurx
    INTO  tcurx-currdec
   WHERE  currkey EQ p_gt_billdata_waerk.

  IF  sy-subrc  NE  0.
    tcurx-currdec  =  2.
  ENDIF.

  IF  tcurx-currdec  =  2.
    gv_point  =  100.
  ELSEIF  tcurx-currdec  =  3.
    gv_point  =  1000.
  ELSEIF  tcurx-currdec  =  4.
    gv_point  =  10000.
  ELSEIF  tcurx-currdec  =  5.
    gv_point  =  100000.
  ENDIF.

ENDFORM.
