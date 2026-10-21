*&---------------------------------------------------------------------*
*& Include          ZSDR0140F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization .

** Layout관련
  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout
**
  CLEAR : so_fksta, so_fksta[],
          so_absta, so_absta[].

  so_fksta-sign  =  'I'.
  so_fksta-option  =  'NE'.
  so_fksta-low  =  'C'.
  APPEND  so_fksta.

  so_fksta-sign  =  'I'.
  so_fksta-option  =  'BT'.

  CONCATENATE sy-datlo(6) '01' INTO DATA(lv_dt).
  so_wadat-low  = lv_dt.
  so_wadat-high = sy-datlo.
  APPEND  so_wadat.

  gv_change = 'X'.   "기능개선 44758 - 추가

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  query_data
*&---------------------------------------------------------------------*
FORM query_data.

  RANGES : lr_wadt FOR likp-wadat_ist.

  DATA : lv_sdt TYPE sy-datum,
         lv_edt TYPE sy-datum.

  CLEAR : g_itab_t, g_itab_t[].

  SELECT  likp~kunag
          vbkd~bstkd
          lips~werks
          likp~wadat_ist AS wadat
          lips~vbeln
          lips~posnr
          lips~charg
          lips~uecha
          lips~vgbel
          lips~vgpos
          lips~matnr
          makt~maktx
          lips~lfimg
          lips~vrkme
          vbap~vrkme AS vrkme_o
*            vbap~netpr
          vbap~netwr
          vbap~kwmeng
          vbap~waerk
          vbak~spart
          vbak~kunnr
          vbpa~kunnr AS payer
          vbkd~kursk
          vbkd~kdkg4
          vbak~auart
          vbak~vkbur
          vbak~vkgrp
          vbak~bstnk
          likp~vstel
          vbak~vkorg
          vbak~vtweg
          lips~mtart
          vbap~netpr AS netpr_cash
          lips~sobkz AS sobkz
          vbap~prodh AS prodh
          vbak~zpjno
    INTO  CORRESPONDING FIELDS OF TABLE g_itab_t
    FROM  likp INNER JOIN lips ON likp~vbeln = lips~vbeln
                     JOIN vbak ON vbak~vbeln = lips~vgbel
                     JOIN vbap ON vbap~vbeln = lips~vgbel
                              AND vbap~posnr = lips~vgpos
                     JOIN vbkd ON vbkd~vbeln = lips~vgbel
                              AND vbkd~posnr = '0'
                     JOIN vbpa ON vbpa~vbeln = lips~vgbel
                              AND vbpa~posnr = '0'
                              AND vbpa~parvw = 'RG'     " 지급처
                     JOIN makt ON makt~matnr = lips~matnr
                              AND makt~spras = sy-langu
   WHERE  likp~wadat_ist  IN  so_wadat
     AND  likp~vstel  IN  so_vstel
     AND  vbak~auart  IN  so_auart
     AND  vbak~auart  NOT IN ('ZREQ', 'ZORQ', 'ZFQ', 'ZFS')
     AND  vbkd~bstkd  IN  so_bstkd
     AND  likp~lfart  IN  so_lfart
     AND  vbak~vkorg  =   pa_vkorg
     AND  vbak~vtweg  IN  so_vtweg
     AND  vbak~spart  IN  so_spart
     AND  vbak~vkbur  IN  so_vkbur
     AND  vbak~vkgrp  IN  so_vkgrp
     AND  vbak~kunnr  IN  so_kunnr
     AND  vbak~bstnk  IN  so_bstnk
     AND  vbpa~kunnr  IN  so_payer
     AND  vbkd~kdkg4  IN  so_kdkg4
     AND  lips~wbsta  =  'C'
     AND  lips~bwart  NE  '687'
     AND  lips~fksta  IN so_fksta
     AND  vbap~absta  IN so_absta
     AND  lips~lfimg  NE 0
     AND  vbak~zpjno  IN so_zpjno.

**********************************************************************
*POD
  lv_sdt = '20000101'.
  __rng lr_wadt 'I' 'BT' lv_sdt so_wadat-high.

  SELECT  likp~kunag
          vbkd~bstkd
          lips~werks
          likp~wadat_ist AS wadat
          lips~vbeln
          lips~posnr
          lips~charg
          lips~uecha
          lips~vgbel
          lips~vgpos
          lips~matnr
          makt~maktx
          lips~lfimg
          lips~vrkme
          vbap~vrkme AS vrkme_o
*            vbap~netpr
          vbap~netwr
          vbap~kwmeng
          vbap~waerk
          vbak~spart
          vbak~kunnr
          vbpa~kunnr AS payer
          vbkd~kursk
          vbkd~kdkg4
          vbak~auart
          vbak~vkbur
          vbak~vkgrp
          vbak~bstnk
          likp~vstel
          vbak~vkorg
          vbak~vtweg
          lips~mtart
          vbap~netpr AS netpr_cash
          lips~sobkz AS sobkz
          vbap~prodh AS prodh
          vbak~zpjno
    APPENDING  CORRESPONDING FIELDS OF TABLE g_itab_t
    FROM  likp INNER JOIN lips ON likp~vbeln = lips~vbeln
                     JOIN vbak ON vbak~vbeln = lips~vgbel
                     JOIN vbap ON vbap~vbeln = lips~vgbel
                              AND vbap~posnr = lips~vgpos
                     JOIN vbkd ON vbkd~vbeln = lips~vgbel
                              AND vbkd~posnr = '0'
                     JOIN vbpa ON vbpa~vbeln = lips~vgbel
                              AND vbpa~posnr = '0'
                              AND vbpa~parvw = 'RG'     " 지급처
                     JOIN makt ON makt~matnr = lips~matnr
                              AND makt~spras = sy-langu
   WHERE  likp~wadat_ist  IN  lr_wadt
     AND  likp~vstel  IN  so_vstel
     AND  vbak~auart  IN  so_auart
     AND  vbak~auart  NOT IN ('ZREQ', 'ZORQ', 'ZFQ', 'ZFS')
     AND  vbkd~bstkd  IN  so_bstkd
     AND  likp~lfart  IN  so_lfart
     AND  vbak~vkorg  =   pa_vkorg
     AND  vbak~vtweg  IN  so_vtweg
     AND  vbak~spart  IN  so_spart
     AND  vbak~vkbur  IN  so_vkbur
     AND  vbak~vkgrp  IN  so_vkgrp
     AND  vbak~kunnr  IN  so_kunnr
     AND  vbak~bstnk  IN  so_bstnk
     AND  vbpa~kunnr  IN  so_payer
     AND  vbkd~kdkg4  IN  so_kdkg4
     AND  lips~wbsta  =  'C'
     AND  lips~bwart  EQ  '687'
     AND  lips~fksta  IN so_fksta
     AND  vbap~absta  IN so_absta
     AND  lips~lfimg  NE 0
     AND  vbak~zpjno  IN so_zpjno.
  IF r3 = 'X'.
    SELECT  likp~kunag
            vbkd~bstkd
            lips~werks
            likp~wadat_ist AS wadat
            lips~vbeln
            lips~posnr
            lips~charg
            lips~uecha
            lips~vgbel
            lips~vgpos
            lips~matnr
            makt~maktx
            lips~lfimg
            lips~vrkme
            vbap~vrkme AS vrkme_o
            vbap~netwr
            vbap~kwmeng
            vbap~waerk
            vbak~kunnr
            vbpa~kunnr AS payer
            vbkd~kursk
            vbkd~kdkg4
            vbak~auart
            vbak~vkbur
            vbak~vkgrp
            vbak~spart
            vbak~bstnk
            likp~vstel
            vbak~vkorg
            vbak~vtweg
            lips~mtart
            vbap~netpr AS netpr_cash
            lips~sobkz AS sobkz
            vbap~prodh AS prodh
            vbak~zpjno
      APPENDING  CORRESPONDING FIELDS OF TABLE g_itab_t
      FROM  likp INNER JOIN lips ON likp~vbeln = lips~vbeln
                       JOIN vbak ON vbak~vbeln = lips~vgbel
                       JOIN vbap ON vbap~vbeln = lips~vgbel
                                AND vbap~posnr = lips~vgpos
                       JOIN vbkd ON vbkd~vbeln = lips~vgbel
                                AND vbkd~posnr = '0'
                       JOIN vbpa ON vbpa~vbeln = lips~vgbel
                                AND vbpa~posnr = '0'
                                AND vbpa~parvw = 'RG'     " 지급처
                       JOIN makt ON makt~matnr = lips~matnr
                                AND makt~spras = sy-langu
     WHERE  likp~wadat_ist  IN  so_wadat
       AND  likp~wadat_ist <> likp~wadat
       AND  likp~zbcf   IN ('C','E','Z') " Z - MIG 적송대상 추가
       AND  likp~vstel  IN  so_vstel
       AND  vbak~auart  NOT IN ('ZREQ', 'ZORQ', 'ZFQ', 'ZFS')
       AND  vbkd~bstkd  IN  so_bstkd
       AND  likp~lfart  IN  so_lfart
       AND  vbak~vkorg  =   pa_vkorg
       AND  vbak~vtweg  IN  so_vtweg
       AND  vbak~spart  IN  so_spart
       AND  vbak~vkbur  IN  so_vkbur
       AND  vbak~vkgrp  IN  so_vkgrp
       AND  vbak~kunnr  IN  so_kunnr
       AND  vbak~bstnk  IN  so_bstnk
       AND  vbpa~kunnr  IN  so_payer
       AND  vbkd~kdkg4  IN  so_kdkg4
       AND  lips~wbsta  =   'C'
       AND  lips~fksta  IN so_fksta
       AND  vbap~absta  IN so_absta
       AND  lips~lfimg  NE 0
       AND  vbak~zpjno  IN so_zpjno.
    IF '60' IN so_spart.

      SELECT  likp~kunag
              vbkd~bstkd
              lips~werks
              likp~wadat_ist AS wadat
              lips~vbeln
              lips~posnr
              lips~charg
              lips~uecha
              lips~vgbel
              lips~vgpos
              lips~matnr
              makt~maktx
              lips~lfimg
              lips~vrkme
              vbap~vrkme AS vrkme_o
              vbap~netwr
              vbap~kwmeng
              vbap~waerk
              vbak~kunnr
              vbpa~kunnr AS payer
              vbkd~kursk
              vbkd~kdkg4
              vbak~auart
              vbak~vkbur
              vbak~vkgrp
              likp~vstel
              vbak~vkorg
              vbak~vtweg
              vbak~spart
              vbak~bstnk
              lips~mtart
              vbap~netpr AS netpr_cash
              lips~sobkz AS sobkz
              vbap~prodh AS prodh
              vbak~zpjno
        APPENDING  CORRESPONDING FIELDS OF TABLE g_itab_t
        FROM  likp INNER JOIN lips ON likp~vbeln = lips~vbeln
                         JOIN vbak ON vbak~vbeln = lips~vgbel
                         JOIN vbap ON vbap~vbeln = lips~vgbel
                                  AND vbap~posnr = lips~vgpos
                         JOIN vbkd ON vbkd~vbeln = lips~vgbel
                                  AND vbkd~posnr = '0'
                         JOIN vbpa ON vbpa~vbeln = lips~vgbel
                                  AND vbpa~posnr = '0'
                                  AND vbpa~parvw = 'RG'     " 지급처
                         JOIN makt ON makt~matnr = lips~matnr
                                  AND makt~spras = sy-langu
                         JOIN zsd1053t ON zsd1053t~vbeln1 = vbap~vbeln
                                      AND zsd1053t~posnr1 = vbap~posnr
       WHERE  likp~wadat_ist  IN  so_wadat
         AND  likp~vstel  IN  so_vstel
         AND  vbkd~bstkd  IN  so_bstkd
         AND  likp~lfart  IN  so_lfart
         AND  vbak~vkorg  =   pa_vkorg
         AND  vbak~vtweg  IN  so_vtweg
         AND  vbak~spart  =  '60'
         AND  vbak~vkbur  IN  so_vkbur
         AND  vbak~vkgrp  IN  so_vkgrp
         AND  vbak~kunnr  IN  so_kunnr
         AND  vbak~bstnk  IN  so_bstnk
         AND  vbpa~kunnr  IN  so_payer
         AND  vbkd~kdkg4  IN  so_kdkg4
         AND  lips~wbsta  =  'C'
         AND  lips~bwart  NE '687'
         AND  lips~fksta  IN so_fksta
         AND  vbap~absta  IN so_absta
         AND  lips~lfimg  NE 0
         AND  vbak~zpjno  IN so_zpjno.

*POD DATA
      SELECT  likp~kunag
              vbkd~bstkd
              lips~werks
              likp~wadat_ist AS wadat
              lips~vbeln
              lips~posnr
              lips~charg
              lips~uecha
              lips~vgbel
              lips~vgpos
              lips~matnr
              makt~maktx
              lips~lfimg
              lips~vrkme
              vbap~vrkme AS vrkme_o
              vbap~netwr
              vbap~kwmeng
              vbap~waerk
              vbak~kunnr
              vbpa~kunnr AS payer
              vbkd~kursk
              vbkd~kdkg4
              vbak~auart
              vbak~vkbur
              vbak~vkgrp
              vbak~bstnk
              likp~vstel
              vbak~vkorg
              vbak~vtweg
              vbak~spart
              lips~mtart
              vbap~netpr AS netpr_cash
              lips~sobkz AS sobkz
              vbap~prodh AS prodh
              vbak~zpjno
        APPENDING CORRESPONDING FIELDS OF TABLE g_itab_t
        FROM  likp INNER JOIN lips ON likp~vbeln = lips~vbeln
                         JOIN vbak ON vbak~vbeln = lips~vgbel
                         JOIN vbap ON vbap~vbeln = lips~vgbel
                                  AND vbap~posnr = lips~vgpos
                         JOIN vbkd ON vbkd~vbeln = lips~vgbel
                                  AND vbkd~posnr = '0'
                         JOIN vbpa ON vbpa~vbeln = lips~vgbel
                                  AND vbpa~posnr = '0'
                                  AND vbpa~parvw = 'RG'     " 지급처
                         LEFT OUTER JOIN makt ON makt~matnr = lips~matnr
                                  AND makt~spras = sy-langu
       WHERE likp~wadat_ist IN lr_wadt
         AND likp~vstel IN so_vstel
         AND vbkd~bstkd IN so_bstkd
         AND likp~lfart IN so_lfart
         AND vbak~vkorg =  pa_vkorg
         AND vbak~vtweg IN so_vtweg
         AND vbak~auart IN ('TA')
         AND vbak~spart =  '60'
         AND vbak~vkbur IN so_vkbur
         AND vbak~vkgrp IN so_vkgrp
         AND vbak~kunnr IN so_kunnr
         AND vbpa~kunnr IN so_payer
         AND vbak~bstnk IN so_bstnk
         AND vbkd~kdkg4 IN so_kdkg4
         AND lips~wbsta =  'C'
         AND lips~bwart EQ '687'
*         AND LIPS~FKSTA NE 'C'
         AND vbap~absta IN so_absta
         AND lips~lfimg NE 0
         AND vbak~zpjno IN so_zpjno.

*추가 START
SELECT likp~kunag
       vbkd~bstkd
       lips~werks
       likp~wadat_ist AS wadat
       lips~vbeln
       lips~posnr
       lips~charg
       lips~uecha
       lips~vgbel
       lips~vgpos
       lips~matnr
       makt~maktx
       lips~lfimg
       lips~vrkme
       vbap~vrkme AS vrkme_o
       vbap~netwr
       vbap~kwmeng
       vbap~waerk
       vbak~kunnr
       vbpa~kunnr AS payer
       vbkd~kursk
       vbkd~kdkg4
       vbak~auart
       vbak~vkbur
       vbak~vkgrp
       vbak~bstnk
       likp~vstel
       vbak~vkorg
       vbak~vtweg
       vbak~spart
       lips~mtart
       vbap~netpr AS netpr_cash
       lips~sobkz AS sobkz
       vbap~prodh AS prodh
       vbak~zpjno
  APPENDING CORRESPONDING FIELDS OF TABLE g_itab_t
  FROM mkpf INNER JOIN mseg ON mkpf~mblnr = mseg~mblnr
                           AND mkpf~mjahr = mseg~mjahr
            INNER JOIN lips ON lips~vbeln = mseg~VBELN_IM
                           AND lips~posnr = mseg~VBELP_IM
            INNER JOIN likp ON likp~vbeln = lips~vbeln
            INNER JOIN vbak ON vbak~vbeln = lips~vgbel
            INNER JOIN vbap ON vbap~vbeln = lips~vgbel
                           AND vbap~posnr = lips~vgpos
            INNER JOIN vbkd ON vbkd~vbeln = lips~vgbel
                           AND vbkd~posnr = '0'
            INNER JOIN vbpa ON vbpa~vbeln = lips~vgbel
                           AND vbpa~posnr = '0'
                           AND vbpa~parvw = 'RG'
     LEFT OUTER JOIN makt ON makt~matnr = lips~matnr
                         AND makt~spras = sy-langu
 WHERE mkpf~budat     IN lr_wadt
   AND mseg~bwart     =  '687'
   AND lips~wbsta     IN ('B', 'C')
   AND mseg~sobkz     =  'T'
   AND mseg~shkzg     =  'S'
   AND lips~lfimg     NE 0
   AND likp~vstel     IN so_vstel
   AND vbkd~bstkd     IN so_bstkd
   AND likp~lfart     IN so_lfart
   AND vbak~vkorg     =  pa_vkorg
   AND vbak~vtweg     IN so_vtweg
   AND vbak~auart     IN ('TA')
   AND vbak~spart     =  '60'
   AND vbak~vkbur     IN so_vkbur
   AND vbak~vkgrp     IN so_vkgrp
   AND vbak~kunnr     IN so_kunnr
   AND vbpa~kunnr     IN so_payer
   AND vbak~bstnk     IN so_bstnk
   AND vbkd~kdkg4     IN so_kdkg4
   AND vbap~absta     IN so_absta
   AND vbak~zpjno     IN so_zpjno.

*SELECT likp~kunag
*         vbkd~bstkd
*         lips~werks
*         likp~wadat_ist AS wadat
*         lips~vbeln
*         lips~posnr
*         lips~charg
*         lips~uecha
*         lips~vgbel
*         lips~vgpos
*         lips~matnr
*         makt~maktx
*         lips~lfimg
*         lips~vrkme
*         vbap~vrkme AS vrkme_o
*         vbap~netwr
*         vbap~kwmeng
*         vbap~waerk
*         vbak~kunnr
*         vbpa~kunnr AS payer
*         vbkd~kursk
*         vbkd~kdkg4
*         vbak~auart
*         vbak~vkbur
*         vbak~vkgrp
*         vbak~bstnk
*         likp~vstel
*         vbak~vkorg
*         vbak~vtweg
*         vbak~spart
*         lips~mtart
*         vbap~netpr AS netpr_cash
*         lips~sobkz AS sobkz
*         vbap~prodh AS prodh
*         vbak~zpjno
*    APPENDING CORRESPONDING FIELDS OF TABLE g_itab_t
*    FROM likp INNER JOIN lips ON likp~vbeln = lips~vbeln
*                 JOIN vbak ON vbak~vbeln = lips~vgbel
*                 JOIN vbap ON vbap~vbeln = lips~vgbel
*                          AND vbap~posnr = lips~vgpos
*                 JOIN vbkd ON vbkd~vbeln = lips~vgbel
*                          AND vbkd~posnr = '0'
*                 JOIN vbpa ON vbpa~vbeln = lips~vgbel
*                          AND vbpa~posnr = '0'
*                          AND vbpa~parvw = 'RG'
*            LEFT OUTER JOIN makt ON makt~matnr = lips~matnr
*                                AND makt~spras = sy-langu
*   WHERE likp~wadat_ist > so_wadat-high
*     AND likp~erdat     <= so_wadat-high
*     AND lips~wbsta     IN ('B', 'C')
*     AND likp~podat   >  so_wadat-high
*     AND likp~vstel IN so_vstel
*     AND vbkd~bstkd IN so_bstkd
*     AND likp~lfart IN so_lfart
*     AND vbak~vkorg =  pa_vkorg
*     AND vbak~vtweg IN so_vtweg
*     AND vbak~auart IN ('TA')
*     AND vbak~spart =  '60'
*     AND vbak~vkbur IN so_vkbur
*     AND vbak~vkgrp IN so_vkgrp
*     AND vbak~kunnr IN so_kunnr
*     AND vbpa~kunnr IN so_payer
*     AND vbak~bstnk IN so_bstnk
*     AND vbkd~kdkg4 IN so_kdkg4
*     AND lips~bwart =  '687'
*     AND vbap~absta IN so_absta
*     AND lips~lfimg NE 0
*     AND vbak~zpjno IN so_zpjno.
*END FINISH 2026

    ENDIF.

  ENDIF.

  DESCRIBE TABLE g_itab_t LINES g_totcnt.

  IF  g_totcnt  >  0.

*    IF P_NEW = 'X'.
    PERFORM get_other_data_collectively.
    PERFORM data_sub_query.
*    ELSE.
*      PERFORM DATA_SUB_QUERY_OLD.
*    ENDIF.
  ELSE.
    MESSAGE s001 WITH 'Data Not Found..!!'.
    EXIT.
  ENDIF.

ENDFORM.                    " query_data

*&---------------------------------------------------------------------*
*&      Form  data_sub_query
*&---------------------------------------------------------------------*
FORM data_sub_query.

  DATA : l_posnr   LIKE lips-posnr,
         ls_result TYPE mb5sit.

  DATA : lv_quant1 TYPE fco_rquant,
         lv_quant2 TYPE fco_rquant.

  DATA : pv_meins TYPE meinh,
         pv_vrkme TYPE plnme.

  DATA : lv_vgbel LIKE lips-vgbel,
         lv_vgpos LIKE lips-vgpos,
         lv_char.





  LOOP AT g_itab_t.
* 납품예정일
    READ TABLE gt_vbep WITH KEY vbeln = g_itab_t-vgbel
                                posnr = g_itab_t-vgpos
                                BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-edatu = gt_vbep-edatu.
    ENDIF.

* 지급처
    PERFORM get_kunnr_desc USING g_itab_t-payer
                                 g_itab_t-name1.

* H/S Code
    PERFORM get_hscode USING g_itab_t-werks
                             g_itab_t-matnr
                             g_itab_t-stawn.

    IF sy-tcode = 'ZGTSDR0140'.
      READ TABLE gt_zfdp WITH KEY vbeln = g_itab_t-vbeln
                                  posnr = g_itab_t-posnr
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-lfimg = g_itab_t-lfimg - gt_zfdp-wmeng.
      ENDIF.
    ENDIF.

** 단가(소수5자리) : 주문금액 / 주문수량.
    g_itab_t-netpr2  =  g_itab_t-netwr  /  g_itab_t-kwmeng.

** 수량단위 확인
    IF g_itab_t-vrkme <> g_itab_t-vrkme_o.

      CALL FUNCTION 'Z_TE_CALC_ITEM_AMOUNT_DO'
        EXPORTING
          im_vbeln = g_itab_t-vbeln
          im_posnr = g_itab_t-posnr
          im_wmeng = g_itab_t-lfimg
          im_type  = 'D'
        IMPORTING
          ex_netwr = g_itab_t-netwr.

    ELSE.
** 금액 : 단가(소수5자리) * 납품수량.
      g_itab_t-netwr  =  g_itab_t-netpr2  *  g_itab_t-lfimg.
    ENDIF.
** 원화금액
    IF  g_itab_t-waerk  NE  'KRW'.
      g_itab_t-k_netwr  =  g_itab_t-netwr  *  g_itab_t-kursk.
      g_itab_t-k_netwr  =  g_itab_t-k_netwr  /  100.
      g_itab_t-netpr    =  g_itab_t-k_netwr / g_itab_t-lfimg.
    ELSE.
      g_itab_t-k_netwr  =  g_itab_t-netwr.
      g_itab_t-netpr    =  g_itab_t-netpr2.
    ENDIF.

    g_itab_t-waers = 'KRW'.

* 보관품 판매일 경우 납품금액 -> '0'
    IF  g_itab_t-auart = 'ZCS'.
      CLEAR : g_itab_t-netwr, g_itab_t-k_netwr.
    ENDIF.

** 자재 특성관련
    READ TABLE gt_mara WITH KEY matnr = g_itab_t-matnr
                                BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-zzcolor_base   = gt_mara-zzcolor_base.   " 색상Base
      g_itab_t-zzral_code     = gt_mara-zzral_code.     " 상세색상
      g_itab_t-zzcolor_stripe = gt_mara-zzcolor_stripe. " 색상Stripe
      g_itab_t-zziden_code    = gt_mara-zziden_code.    " 절연선심식별
      g_itab_t-zzspec_no      = gt_mara-zzspec_no.      " Spec No
      g_itab_t-zzspec_detail  = gt_mara-zzspec_detail.  " Spec 상세
    ENDIF.

    CLEAR  l_posnr.

    IF  g_itab_t-uecha  NE  '000000'.
      l_posnr  =  g_itab_t-uecha.
    ELSE.
      l_posnr  =  g_itab_t-posnr.
    ENDIF.

** 거래명세서 발행일자.
    READ TABLE gt_0005 WITH KEY vbeln = g_itab_t-vbeln
                                posnr = l_posnr
                                BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-iv_date = gt_0005-iv_date.
    ENDIF.

** 납품처
    PERFORM get_partner_name USING  g_itab_t-vgbel
                                    g_itab_t-vgpos
                                    'WE'
                                    g_itab_t-kunnr2
                                    g_itab_t-name2.

** 사업장명
    READ TABLE gt_tvkbt WITH KEY vkbur = g_itab_t-vkbur
                                 BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-bezei = gt_tvkbt-bezei.
    ENDIF.

** 영업그룹명
    READ TABLE gt_tvgrt WITH KEY vkgrp = g_itab_t-vkgrp
                                 BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-bezei2 = gt_tvgrt-bezei.
    ENDIF.

** 동량 계산
    IF g_itab_t-mtart = 'MCFE' OR g_itab_t-mtart = 'MCHA'.
      CLEAR : lv_chul_qty.

      lv_chul_qty = g_itab_t-lfimg.

*   알루미늄 수량은 사용하지 않는다고 하여 표시 제외함
*      IF G_ITAB_T-VKBUR = '1510' AND G_ITAB_T-MTART = 'MCFE'.
*        PERFORM GET_CU_QTY USING LV_CHUL_QTY.
*      ELSE.
      CALL FUNCTION 'ZSD_CALC_NFM_QTY'
        EXPORTING
          i_vkorg  = g_itab_t-vkorg
          i_vtweg  = g_itab_t-vtweg
          i_matnr  = g_itab_t-matnr
          i_vrkme  = g_itab_t-vrkme
          i_kwmeng = lv_chul_qty         "납품수량
        IMPORTING
          e_cuqty  = g_itab_t-cu_qty
          e_alqty  = g_itab_t-al_qty.
*      ENDIF.

    ENDIF.

* 최초 출고일 가져옴
* 수출로컬/직수출일경우 최초 계획일자
    IF g_itab_t-auart = 'ZEXE' OR g_itab_t-kdkg4 = '4S'.
      CLEAR : likp.
      SELECT SINGLE * FROM likp
      WHERE  vbeln EQ g_itab_t-vbeln.
      IF sy-subrc = 0.
        g_itab_t-f_wadat = likp-wadat.
      ENDIF.
* 내수/내수로컬일경우
    ELSE.

      CLEAR   : gt_vbfa, gv_wadat_ist, likp.
      REFRESH : gt_vbfa.

      READ TABLE gt_vbfa_all WITH KEY vbeln = g_itab_t-vbeln
                                      posnn = g_itab_t-posnr.
      IF sy-subrc = 0.
        LOOP AT gt_vbfa_all FROM sy-tabix.
          IF gt_vbfa_all-vbeln <> g_itab_t-vbeln OR
             gt_vbfa_all-posnn <> g_itab_t-posnr.
            EXIT.
          ENDIF.

          CLEAR : gt_vbfa.

          MOVE-CORRESPONDING gt_vbfa_all TO gt_vbfa.

          APPEND gt_vbfa.
        ENDLOOP.

        SORT gt_vbfa BY vbelv.
        READ TABLE gt_vbfa INDEX 1.
        IF sy-subrc = 0.
          IF gt_vbfa-bwart NE |687|.
            SELECT SINGLE *
              FROM likp
             WHERE lfart EQ c_lfart
               AND vbeln EQ gt_vbfa-vbelv.

            IF sy-subrc = 0.
              g_itab_t-vbeln_v = gt_vbfa-vbelv.
              g_itab_t-f_wadat = likp-wadat_ist.
            ENDIF.

          ELSE.
*원주문 번호및 일자
            SELECT SINGLE b~vbeln, b~posnr, c~wadat_ist, a~posnr_o, a~vbeln_o
              FROM zgtsdt9062 AS a INNER JOIN lips AS b  "마이그레이션 데이터
                ON a~vbeln_o = b~vgbel
               AND a~posnr_o = b~vgpos
             INNER JOIN likp AS c
                ON b~vbeln = c~vbeln
             WHERE vbeln_n = @g_itab_t-vgbel
               AND posnr_n = @g_itab_t-vgpos
              INTO @DATA(ls_ori).
            IF sy-subrc = 0.

              g_itab_t-vbeln_o = ls_ori-vbeln_o.
              g_itab_t-posnr_o = ls_ori-posnr_o.
              g_itab_t-vbeln_v = ls_ori-vbeln.
              g_itab_t-sit_dt  = ls_ori-wadat_ist.
              g_itab_t-f_wadat = ls_ori-wadat_ist.

            ELSE.

              SELECT SINGLE *
                FROM likp
               WHERE vbeln EQ gt_vbfa-vbeln.
              IF sy-subrc = 0.
                g_itab_t-vbeln_v = likp-vbeln.
                g_itab_t-sit_dt  = likp-wadat_ist.

                SELECT SINGLE b~budat_mkpf INTO g_itab_t-f_wadat
                  FROM vbfa AS a INNER JOIN mseg AS b
                    ON a~vbeln = b~mblnr
                 WHERE vbelv = g_itab_t-vbeln_v
                   AND a~bwart = '687'.

              ENDIF.

            ENDIF.

            CLEAR ls_result.
            "출고수량 가져오기
            PERFORM call_mb5sit_gi USING g_itab_t-vbeln
                                         g_itab_t-posnr
                                CHANGING ls_result.



            g_itab_t-fkimg  = ls_result-sit_free.
            g_itab_t-sit_gi = g_itab_t-lfimg - g_itab_t-fkimg.

          ENDIF.
        ENDIF.
      ENDIF.


      IF G_ITAB_T-SPART = '60'.

      IF g_itab_t-bwart NE |687|.

        IF gt_vbfa[] IS INITIAL.
          lv_vgpos = g_itab_t-vgpos.
          lv_char = lv_vgpos+0(1).
          IF lv_char NE '0'.
            REPLACE lv_char IN lv_vgpos WITH '0'.
          ENDIF.

          SELECT SINGLE a~vbeln a~wadat_ist
            FROM zlikp_r3 AS a
           INNER JOIN zlips_r3 AS b
              ON a~vbeln EQ b~vbeln
            INTO (g_itab_t-vbeln_v, g_itab_t-f_wadat)
           WHERE b~vgbel EQ g_itab_t-vgbel  "부스덕트는 원오더로 적송오더번호 이관됨
             AND b~vgpos EQ lv_vgpos.

          CLEAR lv_vgpos.
        ELSE.
*<-
          PERFORM get_spart60_data USING gt_vbfa-vbelv
                                         gt_vbfa-posnv
                                         g_itab_t-f_wadat
                                         g_itab_t-vbeln_v.
        ENDIF.
      ENDIF.

      ELSE.
        PERFORM GET_EXCEPT60_DATA USING G_ITAB_T-F_WADAT
                                        G_ITAB_T-VBELN_V.

      ENDIF.


    ENDIF.

* 드럼번호
    READ TABLE gt_vbkd WITH KEY vbeln = g_itab_t-vgbel
                                posnr = g_itab_t-vgpos
                                BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-empst = gt_vbkd-empst.
    ENDIF.

* PJT&APPL명추가.
    READ TABLE gt_0106 WITH KEY zpjno = g_itab_t-zpjno
                                BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-zptxt = gt_0106-zptxt.
    ENDIF.

***[start]단위환산결과
    CLEAR : lv_quant1,lv_quant2, pv_meins, pv_vrkme.

    lv_quant1 =  g_itab_t-lfimg.
    pv_meins  =  g_itab_t-vrkme.
    pv_vrkme  =  'KG'.

    CALL FUNCTION 'FCO_CONVERT_FROM_BASE_UNIT'
      EXPORTING
        i_matnr       = g_itab_t-matnr
        i_quant       = lv_quant1
        i_meinh       = pv_meins
        i_plnme       = pv_vrkme
        i_umrez       = '1'
        i_umren       = '1'
      IMPORTING
        e_quant       = lv_quant2
      EXCEPTIONS
        error_occured = 1
        OTHERS        = 2.

    g_itab_t-lfimg_ch = lv_quant2.

***[end]단위환산결과

    READ TABLE gt_ords INTO DATA(wa_ords)
                       WITH KEY vbeln = g_itab_t-vgbel
                                posnv = g_itab_t-vgpos
                                BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE gt_ordvals INTO DATA(wa_ovals)
                            WITH KEY objek = wa_ords-objek
                                     atnam = so_length      "조장
                                     BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-length = wa_ovals-atwrt.
      ENDIF.

      READ TABLE gt_ordvals INTO wa_ovals
                            WITH KEY objek = wa_ords-objek
                                     atnam = so_factor      "조장수
                                     BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-factor = wa_ovals-atwrt.
      ENDIF.

      READ TABLE gt_ordvals INTO wa_ovals
                            WITH KEY objek = wa_ords-objek
                                     atnam = ba_pd_tb_print_app"인쇄사양
                                     BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-tb_print = wa_ovals-atwrt.
      ENDIF.
    ENDIF.

    IF  g_itab_t-auart = 'RE'   OR
        g_itab_t-auart = 'ZRET' OR
        g_itab_t-auart = 'YSRE' OR
        g_itab_t-auart = 'ZBC1' OR
        g_itab_t-auart = 'ZBC3'.
      g_itab_t-lfimg   = g_itab_t-lfimg   *  -1.
      g_itab_t-netwr   = g_itab_t-netwr   *  -1.
      g_itab_t-k_netwr = g_itab_t-k_netwr *  -1.
    ENDIF.

    IF r3 = |X|.
      CLEAR gt_4180.
      READ TABLE gt_4180 WITH KEY vbeln = g_itab_t-vbeln
                                  posnr = g_itab_t-posnr
                                  matnr = g_itab_t-matnr
                                  werks = g_itab_t-werks.
      IF sy-subrc = 0.
        IF gt_4180-lbkum NE 0.
          g_itab_t-salk3 = gt_4180-salk3.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY  g_itab_t.
  ENDLOOP.

ENDFORM.                    " data_sub_query

*&---------------------------------------------------------------------*
*&      Form  alv_write_rtn
*&---------------------------------------------------------------------*
FORM alv_write_rtn.

** ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM  alvprn_basic.
* perform  alvprn_header.
  PERFORM  alvprn_field.

** ALV DISPLAY
  PERFORM  alv_display.

ENDFORM.                    " alv_write_rtn

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_BASIC
*&---------------------------------------------------------------------*
*       ALV를 실행하기위한 기본 정보 SETTING
*----------------------------------------------------------------------*
FORM alvprn_basic.

  CLEAR:   g_events_t, g_layout_s.
  REFRESH: g_events_t.

** Default SETTING
  g_layout_s-detail_popup      = 'X'.
*  g_layout_s-no_totalline      = 'X'.    " 합계필드의 사용여부
  g_layout_s-zebra             = 'X'.
  g_layout_s-box_fieldname     = 'MARK'.
* G_LAYOUT_S-CELL_MERGE        = 'X'.
  g_layout_s-colwidth_optimize = 'X'.

** FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = g_events_t.

** FORM문   생성
  PERFORM form_setting  TABLES g_events_t
                         USING : slis_ev_pf_status_set  c_status_set,
                                 slis_ev_user_command   c_user_command.
**   SLIS_EV_TOP_OF_PAGE    C_TOP_OF_PAGE.  " Grapic Display

** PROGRAM  ID
  g_program = sy-repid.

ENDFORM.                    " ALVPRN_BASIC

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_HEADER
*&---------------------------------------------------------------------*
*       ALV HEADER SETTING
*----------------------------------------------------------------------*
FORM alvprn_header.

*  refresh g_list_top_of_page_t.
*
*  perform header_setting tables g_list_top_of_page_t
*                          using: 'S'  '고객 NO : ' g_data1,
*                                 'S'  '고객명 : '  g_data2.

ENDFORM.                    " ALVPRN_HEADER

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_FIELD
*&---------------------------------------------------------------------*
*       ALV FIELD  SETTING
*----------------------------------------------------------------------*
FORM   alvprn_field.

  REFRESH: g_field_t, g_fieldcat_t.

* FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_program
      i_internal_tabname     = 'G_ITAB_T'
      i_client_never_display = 'X'
      i_inclname             = g_program
      i_bypassing_buffer     = 'X'
      i_buffer_active        = 'X'
    CHANGING
      ct_fieldcat            = g_field_t[].

  PERFORM  field_setting  TABLES g_fieldcat_t

                          USING: 'S' 'PAYER'       ' ',
                                 ' ' 'SELTEXT_L'   '지급처',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '1',
                                 'E' 'KEY'         'X',

                                 'S' 'NAME1'       ' ',
                                 ' ' 'SELTEXT_L'   '지급처명',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '35',
                                 'E' 'COL_POS'     '2',

                                 'S' 'BSTKD'       ' ',
                                 ' ' 'SELTEXT_L'   '고객계약번호',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '12',
                                 'E' 'COL_POS'     '3',

                                 'S' 'WADAT'       ' ',
                                 ' ' 'SELTEXT_L'   'G/I Date',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '4',
                                 'E' 'KEY'         ' ',

                                 'S' 'EDATU'       ' ',
                                 ' ' 'SELTEXT_L'   '납품예정일',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '4',
                                 'E' 'KEY'         ' ',

                                 'S' 'VBELN'       ' ',
                                 ' ' 'SELTEXT_L'   '납품번호',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '5',
                                 'E' 'KEY'         'X'.
  IF r3 = 'X'.
    PERFORM  field_setting  TABLES g_fieldcat_t
                            USING: 'S' 'BSTNK'       ' ',
                                   ' ' 'SELTEXT_L'   '제조지시번호',
                                   ' ' 'DDICTXT'     'L',
                                   ' ' 'OUTPUTLEN'   '10',
                                   ' ' 'COL_POS'     '6',
                                   'E' 'KEY'         'X',

                                   'S' 'SALK3'      ' ',
                                   ' ' 'SELTEXT_L'   '재고가액',
                                   ' ' 'DDICTXT'     'L',
                                   ' ' 'OUTPUTLEN'   '20',
                                   ' ' 'JUST'        'R',
                                   'E' 'COL_POS'     '13'.
  ENDIF.

  PERFORM  field_setting  TABLES g_fieldcat_t
                          USING: 'S' 'POSNR'       ' ',
                                 ' ' 'SELTEXT_L'   '품목번호',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '6',
                                 'E' 'KEY'         'X',

                                 'S' 'CHARG'       ' ',
                                 ' ' 'SELTEXT_L'   '배치번호',
                                 ' ' 'DDICTXT'     'L',
                                 'E' 'OUTPUTLEN'   '10',

                                 'S' 'STAWN'       ' ',
                                 ' ' 'SELTEXT_L'   'HS Code',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '17',
                                 'E' 'COL_POS'     '7',

                                 'S' 'MATNR'       ' ',
                                 ' ' 'SELTEXT_L'   '자재코드',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '18',
                                 'E' 'COL_POS'     '8',

                                 'S' 'MAKTX'       ' ',
                                 ' ' 'SELTEXT_L'   '자재명',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 'E' 'COL_POS'     '9',

                                 'S' 'IV_DATE'     ' ',
                             ' ' 'SELTEXT_L'   '거래명세서 발행일자',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 'E' 'COL_POS'     '10',

                                 'S' 'LFIMG'       ' ',
                                 ' ' 'SELTEXT_L'   '납품수량',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '15',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '11',

                                 'S' 'VRKME'       ' ',
                                 ' ' 'SELTEXT_S'   'UOM',
                                 'E' 'COL_POS'     '12',

                                 'S' 'NETPR'      ' ',
                                 ' ' 'SELTEXT_L'   '단가',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '13'.

  IF  sy-tcode  =  'ZGTSDR0140'.
    PERFORM  field_setting  TABLES g_fieldcat_t
                       USING:  'S' 'NETWR'       ' ',
                               ' ' 'SELTEXT_L'   '계약금액',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '20',
                               ' ' 'JUST'        'R',
                               'E' 'COL_POS'     '14'.
  ELSE.
    PERFORM  field_setting  TABLES g_fieldcat_t
                       USING:

                               'S' 'NETPR_CASH'       ' ',
                               ' ' 'SELTEXT_L'   '단가(문서통화)',
                               ' ' 'CFIELDNAME'  'WAERK',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '20',
                               ' ' 'JUST'        'R',
                               'E' 'COL_POS'     '14',

                               'S' 'NETWR'       ' ',
                               ' ' 'SELTEXT_L'   '납품금액(문서통화)',
                               ' '   'CFIELDNAME'  'WAERK',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '20',
                               ' ' 'JUST'        'R',
                               'E' 'COL_POS'     '14'.
  ENDIF.

  PERFORM  field_setting  TABLES g_fieldcat_t
                     USING:  'S' 'WAERK'       ' ',
                             ' ' 'SELTEXT_S'   '통화',
                             'E' 'COL_POS'     '15',

                             'S' 'OFFER_NO'    ' ',
                             ' ' 'SELTEXT_L'   'Offer No',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '20',
                             'E' 'COL_POS'     '16',

                             'S' 'ZZCOLOR_BASE' ' ',
                             ' ' 'SELTEXT_L'   '색상Base',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '8',
                             'E' 'COL_POS'     '17',

                             'S' 'ZZRAL_CODE'  ' ',
                             ' ' 'SELTEXT_L'   '상세색상',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '10',
                             'E' 'COL_POS'     '18',

                             'S' 'ZZCOLOR_STRIPE' ' ',
                             ' ' 'SELTEXT_L'   '색상Stripe',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '10',
                             'E' 'COL_POS'     '19',

                             'S' 'ZZIDEN_CODE' ' ',
                             ' ' 'SELTEXT_L'   '절연선심식별',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '30',
                             'E' 'COL_POS'     '20',

                             'S' 'ZZSPEC_NO'   ' ',
                             ' ' 'SELTEXT_L'   'Spec No',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '20',
                             'E' 'COL_POS'     '21',

                             'S' 'ZZSPEC_DETAIL' ' ',
                             ' ' 'SELTEXT_L'   'Spec상세',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '30',
                             'E' 'COL_POS'     '22',

                             'S' 'AUART'       ' ',
                             ' ' 'SELTEXT_L'   '오더유형',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '8',
                             'E' 'COL_POS'     '26',

                             'S' 'BEZEI'       ' ',
                             ' ' 'SELTEXT_L'   '영업팀',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '20',
                             'E' 'COL_POS'     '27',

                             'S' 'BEZEI2'      ' ',
                             ' ' 'SELTEXT_L'   '영업그룹',
                             ' ' 'DDICTXT'     'L',
                             ' ' 'OUTPUTLEN'   '20',
                             'E' 'COL_POS'     '28'.

  IF  sy-tcode  =  'ZGTSDR0140_2'.

    PERFORM  field_setting  TABLES g_fieldcat_t
                        USING: 'S' 'KUNNR2'      ' ',
                               ' ' 'SELTEXT_L'   '납품처',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '23',

                               'S' 'NAME2'       ' ',
                               ' ' 'SELTEXT_L'   '납품처명',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '35',
                               'E' 'COL_POS'     '24',

                               'S' 'K_NETWR'     ' ',
                               ' ' 'SELTEXT_L'   '납품금액(원화)',
                               ' ' 'CFIELDNAME'  'WAERS',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '20',
                               ' ' 'JUST'        'R',
*                               ' ' 'CURRENCY'    'KRW',
                               'E' 'COL_POS'     '25',

                               'S' 'VGBEL'       ' ',
                               ' ' 'SELTEXT_L'   '주문번호',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '29',

                               'S' 'VGPOS'       ' ',
                               ' ' 'SELTEXT_L'   '주문품목',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '30',

                               'S' 'VSTEL'       ' ',
                               ' ' 'SELTEXT_L'   '출하지점',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '8',
                               'E' 'COL_POS'     '31',

                               'S' 'CU_QTY'       ' ',
                               ' ' 'SELTEXT_L'   '출하동량(KG)',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '12',
                               'E' 'COL_POS'     '32',

                               'S' 'AL_QTY'       ' ',
                               ' ' 'SELTEXT_L'   '출하AL량(KG)',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '12',
                               'E' 'COL_POS'     '33',

                               'S' 'WAERS'       ' ',
                               ' ' 'SELTEXT_S'   '통화(원화)',
                               'E' 'COL_POS'     '37',

                               'S' 'SOBKZ'       ' ',
                               ' ' 'SELTEXT_L'   '특별재고구분',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '5',
                               'E' 'COL_POS'     '36',

                               'S' 'PRODH'       ' ',
                               ' ' 'SELTEXT_S'   '제품계층구조',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '18',
                               'E' 'COL_POS'     '37',

                               'S' 'EMPST'       ' ',
                               ' ' 'SELTEXT_L'   '드럼번',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '25',
                               'E' 'COL_POS'     '38',

                               'S' 'ZPJNO'       ' ',
                               ' ' 'SELTEXT_L'   'PJT&APPL 번호',
                               ' ' 'DDICTXT'     'L',
                               'E' 'COL_POS'     '39',

                               'S' 'ZPTXT'       ' ',
                               ' ' 'SELTEXT_L'   'PJT&APPL명',
                               ' ' 'DDICTXT'     'L',
                               'E' 'COL_POS'     '40',

                              'S' 'LFIMG_CH'       ' ',
                               ' ' 'SELTEXT_L'   '단위변환KG)',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '12',
                               'E' 'COL_POS'     '41',

                              'S'   'VRKME'       ' ',
                              ' '   'SELTEXT_M'   '단위',
                              ' '   'KEY'         ' ',
                              'E'   'DDICTXT'     'M',

                              'S'   'LENGTH'       ' ',
                              ' '   'SELTEXT_M'   '조장',
                              ' '   'KEY'         ' ',
                              ' '   'JUST'        'R',
                              'E'   'DDICTXT'     'M',

                              'S'   'FACTOR'       ' ',
                              ' '   'SELTEXT_M'   '조장수',
                              ' '   'KEY'         ' ',
                              ' '   'JUST'        'R',
                              'E'   'DDICTXT'     'M',

                              'S'   'TB_PRINT'       ' ',
                              ' '   'SELTEXT_M'   '튜브인쇄사양',
                              ' '   'KEY'         ' ',
                              'E'   'DDICTXT'     'M'.
  ENDIF.

  IF r3 = 'X'.

    PERFORM  field_setting  TABLES g_fieldcat_t
                        USING: 'S' 'VBELN_O'     ' ',
                               ' ' 'SELTEXT_L'   '최초주문문서',
                               ' ' 'DDICTXT'     'L',
                               'E' 'OUTPUTLEN'   '10',

                               'S' 'POSNR_O'     ' ',
                               ' ' 'SELTEXT_L'   '최초주문 품목번호',
                               ' ' 'DDICTXT'     'L',
                               'E' 'OUTPUTLEN'   '10',

                               'S' 'F_WADAT'     ' ',
                               ' ' 'SELTEXT_L'   '최초출고일',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '34',

                               'S' 'SIT_DT'     ' ',
                               ' ' 'SELTEXT_L'   '운송중재고 매출처리일',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '35',

                               'S' 'VBELN_V'     ' ',
                               ' ' 'SELTEXT_L'   '최초납품문서',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '36',

                               'S' 'FKIMG'     ' ',
                               ' ' 'SELTEXT_L'   '매출마감 수량',
                               ' ' 'QFIELDNAME'  'VRKME',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '37',

                               'S' 'SIT_GI'     ' ',
                               ' ' 'SELTEXT_L'   '운송중재고 수량',
                               ' ' 'QFIELDNAME'  'VRKME',
                               ' ' 'DDICTXT'     'L',
                               ' ' 'OUTPUTLEN'   '10',
                               'E' 'COL_POS'     '38'.
  ENDIF.

ENDFORM.                    " ALVPRN_FIELD

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM alv_display.

  g_save  =  'A'.

  IF r3 EQ 'X'.
    DELETE g_itab_t[] WHERE sit_gi EQ 0.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
* call function 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = g_program
      is_layout               = g_layout_s
      i_save                  = g_save
      is_variant              = gs_variant
      it_events               = g_events_t[]
      it_fieldcat             = g_fieldcat_t[]
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = g_exit_caused_by_user_s
    TABLES
      t_outtab                = g_itab_t.

ENDFORM.                    " ALV_DISPLAY

*-------------------------------------------------------------------*
*        Form  PF_STATUS_SET
*-------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*-------------------------------------------------------------------*
FORM pf_status_set USING p_rt_extab TYPE slis_t_extab.

  IF  sy-tcode  =  'ZGTSDR0140'.
    SET PF-STATUS '1000'.
    SET TITLEBAR '1000'.
  ELSE.
    SET PF-STATUS '2000'.
    SET TITLEBAR '2000'.
  ENDIF.

ENDFORM.                    "pf_status_set

*---------------------------------------------------------------------*
*      Form  TOP_OF_PAGE
*---------------------------------------------------------------------*
*      TOP의 로그 부분 SETTING.
*---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = ' '
      it_list_commentary = g_list_top_of_page_t.

ENDFORM.                    "top_of_page

*---------------------------------------------------------------------*
*      Form  USER COMMAND
*---------------------------------------------------------------------*
*      USER COMMAND 정의.
*---------------------------------------------------------------------*
FORM  user_command USING p_ucomm    LIKE sy-ucomm
                         p_selfield TYPE slis_selfield.

  CASE p_ucomm.

    WHEN '&IC1'.

      CASE p_selfield-sel_tab_field.

        WHEN 'G_ITAB_T-VGBEL'.
          CHECK p_selfield-value IS NOT INITIAL.
          SET PARAMETER ID 'AUN' FIELD p_selfield-value.
          CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
        WHEN 'G_ITAB_T-VBELN' OR 'G_ITAB_T-VBELN_V'.
          PERFORM  call_vl02n  USING  p_selfield-value.

      ENDCASE.

    WHEN  'BDC'.
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
      PERFORM  bdc_data_move.

      PERFORM  query_data.

    WHEN  'FORM'.              " Offer Sheet
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
*     perform  print_rtn.
      g_work_flag  =  'A'.     " Offer Sheet
      PERFORM  excel_down_rtn.

    WHEN  'FORM2'.             " 구매승인요청서
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
*     perform  print_rtn2.
      g_work_flag  =  'B'.     " 구매승인요청서
      PERFORM  excel_down_rtn.

    WHEN  'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM free_object.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  call_vl02n
*&---------------------------------------------------------------------*
FORM call_vl02n  USING    p_value.

  IF p_value(1) = '6'.
* PARAMETER SETTING
    SET PARAMETER ID: 'VL'    FIELD   p_value.

* CALL TRANSACTION
    CALL TRANSACTION  'VL02N' AND SKIP FIRST SCREEN.
    COMMIT WORK AND WAIT.
  ELSEIF p_value(1) = '5'.
    SET PARAMETER ID 'AUN' FIELD p_value.
    CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.                                                    " call_va43

*&---------------------------------------------------------------------*
*&      Form  bdc_data_move
*&---------------------------------------------------------------------*
FORM bdc_data_move .

ENDFORM.                    " bdc_data_move

*&---------------------------------------------------------------------*
*&      Form  print_rtn
*&---------------------------------------------------------------------*
FORM print_rtn .

  DATA : l_tmp_netwr LIKE vbap-netwr.
  CLEAR : l_tmp_netwr.

** Offer no의 채번여부 Check하는것 추가할것.

  LOOP AT g_itab_t WHERE mark = 'X'.

    g_h_offer  =  g_itab_t-offer_no.
    g_h_offer  =  '20041105001'.
    g_h_waerk  =  g_itab_t-waerk.
    l_tmp_netwr  =  l_tmp_netwr  +  g_itab_t-netwr.

    MOVE-CORRESPONDING  g_itab_t  TO g_form_t.
*    g_form_t-netwr  =  123456789.
    APPEND  g_form_t.
    CLEAR  g_form_t.

  ENDLOOP.

  IF  g_h_waerk  =  'KRW'.
    l_tmp_netwr  =  l_tmp_netwr  *  100.
  ENDIF.
  g_h_total  =  l_tmp_netwr.
*  g_h_total  =  12345678900.

  IF  sy-subrc  =  0.

** 납품 Header Text를 가져온다.
    PERFORM  do_get_text.

    PERFORM  form_data_control.

    PERFORM  printer.         " PRINTER SETTING
    PERFORM  call_smartforms.

  ELSE.
    MESSAGE e000 WITH '발행할 Data를 선택하세요.'.
  ENDIF.

ENDFORM.                    " print_rtn

*&---------------------------------------------------------------------*
*&      Form  print_rtn
*&---------------------------------------------------------------------*
FORM print_rtn2 .

  DATA : l_tmp_netwr LIKE vbap-netwr.
  CLEAR : l_tmp_netwr.

** Offer no의 채번여부 Check하는것 추가할것.

  LOOP AT g_itab_t WHERE mark = 'X'.

    g_h_offer  =  g_itab_t-offer_no.
    g_h_offer  =  '20041105001'.
    g_h_waerk  =  g_itab_t-waerk.
    g_h_hsno   =  g_itab_t-stawn.
    l_tmp_netwr  =  l_tmp_netwr  +  g_itab_t-netwr.

    MOVE-CORRESPONDING  g_itab_t  TO g_form_t.
*    g_form_t-netwr  =  123456789.
    APPEND  g_form_t.
    CLEAR  g_form_t.

  ENDLOOP.

  IF  g_h_waerk  =  'KRW'.
    l_tmp_netwr  =  l_tmp_netwr  *  100.
  ENDIF.
  g_h_total  =  l_tmp_netwr.
*  g_h_total  =  12345678900.

  IF  sy-subrc  =  0.

    PERFORM  form_data_control.

    PERFORM  printer.         " PRINTER SETTING
    PERFORM  call_smartforms2.

  ELSE.
    MESSAGE e000 WITH '발행할 Data를 선택하세요.'.
  ENDIF.

ENDFORM.                    " print_rtn2

*&---------------------------------------------------------------------*
*&      Form  do_get_text
*&---------------------------------------------------------------------*
FORM do_get_text .

  READ TABLE g_itab_t WITH KEY mark = 'X'.

  g_tname  =  g_itab_t-vbeln.

  PERFORM  read_text_rtn  USING 'Z081'.  " Offer Date
  READ TABLE g_ltext INDEX 1.
  g_h_z081  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z082'.  " Offer Validity
  READ TABLE g_ltext INDEX 1.
  g_h_z082  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z091'.  " Offer Messers
  CLEAR g_ltext.
  READ TABLE g_ltext INDEX 1.
  g_h_z091  =  g_ltext-tdline.
  CLEAR g_ltext.
  READ TABLE g_ltext INDEX 2.
  g_h_z091_2  =  g_ltext-tdline.
  CLEAR g_ltext.
  READ TABLE g_ltext INDEX 3.
  g_h_z091_3  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z092'.  " Offer Packing
  READ TABLE g_ltext INDEX 1.
  g_h_z092  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z093'.  " Offer Inspection
  READ TABLE g_ltext INDEX 1.
  g_h_z093  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z094'.  " Offer Payment
  READ TABLE g_ltext INDEX 1.
  g_h_z094  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z095'.  " Offer Shipment
  READ TABLE g_ltext INDEX 1.
  g_h_z095  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z096'.  " Offer Destination
  READ TABLE g_ltext INDEX 1.
  g_h_z096  =  g_ltext-tdline.

  PERFORM  read_text_rtn  USING 'Z097'.  " Offer Remarks
  READ TABLE g_ltext INDEX 1.
  g_h_z097  =  g_ltext-tdline.

ENDFORM.                    " do_get_text

*&--------------------------------------------------------------------
*&      Form  read_text_rtn
*&--------------------------------------------------------------------
FORM read_text_rtn  USING    VALUE(p_id).

  CLEAR : g_htext, g_ltext, g_ltext[].

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = p_id
      language                = sy-langu
      name                    = g_tname
      object                  = 'VBBK'
      archive_handle          = 0
      local_cat               = ' '
    IMPORTING
      header                  = g_htext
    TABLES
      lines                   = g_ltext
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

ENDFORM.                    " read_text_rtn

*&---------------------------------------------------------------------*
*&      Form  form_data_control
*&---------------------------------------------------------------------*
FORM form_data_control .

ENDFORM.                    " form_data_control

*&---------------------------------------------------------------------*
*&      Form  printer
*&---------------------------------------------------------------------*
FORM printer .

  device-preview     = 'X'.    " popup창 안띄우고 바로 미리보기
  device-no_dialog   = 'X'.

  options-tdimmed    = 'X'.    " 즉시인쇄
  options-tddelete   = 'X'.    " 인쇄후 삭제
  options-tdnewid    = 'X'.    " 신규스풀요청
* OPTIONS-TDNOPREV   = 'X'.    " No print preview
  options-tdcover    = space.  " SAP 표지
  options-tdlifetime = '7'.    " 스풀보유기간

ENDFORM.                    " printer

*&---------------------------------------------------------------------*
*&      Form  call_smartforms
*&---------------------------------------------------------------------*
FORM call_smartforms .

  DATA: l_fname(30).

  SELECT  SINGLE funcname
    INTO  l_fname
    FROM  tftit
   WHERE  spras = '3'
     AND  stext LIKE '%Z_SD_OFFER_SHEET1%'.

  IF  sy-subrc <> 0.
    RAISE not_found_sform.
  ENDIF.

*  if  g_popup_flag  <>  'Y'.
*      g_c_netwr  =  g_tot_netwr.
*  endif.

  CALL FUNCTION l_fname
    EXPORTING
      control_parameters = device
      output_options     = options
      user_settings      = ' '
      g_h_offer          = g_h_offer
      g_h_waerk          = g_h_waerk
      g_h_total          = g_h_total
      g_h_z081           = g_h_z081
      g_h_z082           = g_h_z082
      g_h_z091           = g_h_z091
      g_h_z091_2         = g_h_z091_2
      g_h_z091_3         = g_h_z091_3
      g_h_z092           = g_h_z092
      g_h_z093           = g_h_z093
      g_h_z094           = g_h_z094
      g_h_z095           = g_h_z095
      g_h_z096           = g_h_z096
      g_h_z097           = g_h_z097
    TABLES
      g_form_t           = g_form_t
    EXCEPTIONS
      not_found          = 1
      OTHERS             = 2.

  MESSAGE s001 WITH 'PRINT OK.'.

ENDFORM.                    " call_smartforms

*&---------------------------------------------------------------------*
*&      Form  call_smartforms2
*&---------------------------------------------------------------------*
FORM call_smartforms2 .

  DATA: l_fname(30).

  SELECT  SINGLE funcname
    INTO  l_fname
    FROM  tftit
   WHERE  spras = '3'
     AND  stext LIKE '%Z_SD_OFFER_SHEET2%'.

  IF  sy-subrc <> 0.
    RAISE not_found_sform.
  ENDIF.

*  if  g_popup_flag  <>  'Y'.
*      g_c_netwr  =  g_tot_netwr.
*  endif.

  CALL FUNCTION l_fname
    EXPORTING
      control_parameters = device
      output_options     = options
      user_settings      = ' '
      g_h_offer          = g_h_offer
      g_h_waerk          = g_h_waerk
      g_h_total          = g_h_total
      g_h_hsno           = g_h_hsno
    TABLES
      g_form_t           = g_form_t
    EXCEPTIONS
      not_found          = 1
      OTHERS             = 2.

  MESSAGE s001 WITH 'PRINT OK.'.

ENDFORM.                    " call_smartforms2

*&---------------------------------------------------------------------*
*&      Form  data_gethering
*&---------------------------------------------------------------------*
FORM data_gethering .

  DATA : l_tmp_netwr LIKE vbap-netwr,
         l_tmp_stawn LIKE marc-stawn,
         l_currdec   LIKE tcurx-currdec.
  CLEAR : l_tmp_netwr, l_tmp_stawn, l_currdec.
  CLEAR : g_sum_t, g_sum_t[], g_excel_t, g_excel_t[].

  LOOP AT g_itab_t WHERE mark = 'X'.

    g_h_offer  =  g_itab_t-offer_no.
    g_h_waerk  =  g_itab_t-waerk.
    g_h_hsno   =  g_itab_t-stawn.
    l_tmp_netwr  =  l_tmp_netwr  +  g_itab_t-netwr.

    MOVE-CORRESPONDING  g_itab_t  TO  g_sum_t.

    COLLECT  g_sum_t.
    CLEAR : g_sum_t, g_itab_t.

  ENDLOOP.

*  loop at g_itab_t where mark = 'X'.
*
*    g_h_offer  =  g_itab_t-offer_no.
*    g_h_waerk  =  g_itab_t-waerk.
*    g_h_hsno   =  g_itab_t-stawn.
*    l_tmp_netwr  =  l_tmp_netwr  +  g_itab_t-netwr.
*
*    move-corresponding  g_itab_t  to g_excel_t.
*
*    if  l_tmp_stawn  =  g_excel_t-stawn.
*        g_excel_t-stawn  =  space.
*    endif.
*
*    if  g_itab_t-waerk  =  'KRW'.
*        g_itab_t-netpr  =  g_itab_t-netpr  *  100.
*        g_itab_t-netwr  =  g_itab_t-netwr  *  100.
*    endif.
*
*    g_excel_t-netpr  =  g_itab_t-netpr.
*    g_excel_t-netwr  =  g_itab_t-netwr.
*
*    l_tmp_stawn  =  g_excel_t-stawn.
*
*    append  g_excel_t.
*    clear  g_excel_t.
*
*  endloop.

  SELECT  SINGLE currdec
    INTO  l_currdec
    FROM  tcurx
   WHERE  currkey  =  g_h_waerk.

  IF  sy-subrc  =  0.
    IF  l_currdec  =  0.
      l_tmp_netwr  =  l_tmp_netwr  *  100.
    ELSEIF  l_currdec  =  3.
      l_tmp_netwr  =  l_tmp_netwr  /  10.
    ENDIF.
  ENDIF.
  g_h_total  =  l_tmp_netwr.

  LOOP AT g_sum_t.

    CLEAR  l_currdec.

    MOVE-CORRESPONDING  g_sum_t  TO g_excel_t.

    IF  l_tmp_stawn  =  g_excel_t-stawn.
      g_excel_t-stawn  =  space.
    ENDIF.

    SELECT  SINGLE currdec
      INTO  l_currdec
      FROM  tcurx
     WHERE  currkey  =  g_sum_t-waerk.

    IF  sy-subrc  =  0.
      IF  l_currdec  =  0.
        g_sum_t-netpr  =  g_sum_t-netpr  *  100.
        g_sum_t-netwr  =  g_sum_t-netwr  *  100.
      ELSEIF  l_currdec  =  3.
        g_sum_t-netpr  =  g_sum_t-netpr  /  10.
        g_sum_t-netwr  =  g_sum_t-netwr  /  10.
      ENDIF.
    ENDIF.

    g_excel_t-netpr  =  g_sum_t-netpr2.
    g_excel_t-netwr  =  g_sum_t-netwr.

    l_tmp_stawn  =  g_excel_t-stawn.

    APPEND  g_excel_t.
    CLEAR  g_excel_t.

  ENDLOOP.

ENDFORM.                    " data_gethering

*&---------------------------------------------------------------------*
*&      Form  value_request_vari
*&---------------------------------------------------------------------*
FORM value_request_vari .

  CLEAR g_layout.

  MOVE  g_repid  TO  g_layout-report.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = g_layout
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = spec_layout
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF  sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF  g_exit NE 'X'.
** set name of layout on selection screen
      p_vari  =  spec_layout-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " value_request_vari
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
FORM authority_check .

  DATA: gt_tspa  LIKE tspa OCCURS 0 WITH HEADER LINE,
        lv_subrc LIKE sy-subrc.


  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_vkorg = pa_vkorg
      i_type  = '1'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE e002 WITH '영업조직에 대한 권한이 없읍니다'
                      pa_vkorg.
  ENDIF.

  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_vtweg = so_vtweg-low
      i_type  = '2'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE e002 WITH '유통채널에 대한 권한이 없읍니다'
                      so_vtweg-low.
  ENDIF.


  SELECT *
  INTO TABLE gt_tspa
  FROM tspa
 WHERE spart IN so_spart.

  LOOP  AT  gt_tspa.
    CLEAR : lv_subrc.
    CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
      EXPORTING
        i_spart = gt_tspa-spart
        i_type  = '3'
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
      MESSAGE e002 WITH '제품군에 대한 권한이 없읍니다'
                        gt_tspa-spart.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM screen_field_chang .

  CHECK gv_change = 'X'.

  CLEAR : gv_change.

* 초기화면 상태
  IF r1 = 'X'.
    PERFORM init_set_variant.
* 전체 출고조회 : 전체 대금청구 상태의 출고실적 조회
  ELSEIF r2 = 'X'.
    PERFORM all_out_variant.
* 적송 조회 : 출고일이 매월1일이며 오더유형ZBC2, 전체 대금청구상태
* 수출적송 포함
  ELSEIF r3 = 'X'.
    PERFORM zbc2_variant.
  ELSE.

  ENDIF.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'M1'.
        IF r3 = 'X'.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
*&      Form  INIT_SET_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_set_variant .
** Layout관련
  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout

  CLEAR : so_auart, so_auart[],
          so_fksta, so_fksta[],
          so_absta, so_absta[].

  so_fksta-sign  =  'I'.
  so_fksta-option  =  'NE'.
  so_fksta-low  =  'C'.
  APPEND  so_fksta.
ENDFORM.                    " INIT_SET_VARIANT
*&---------------------------------------------------------------------*
*&      Form  ALL_OUT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM all_out_variant .
** Layout관련
  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout

  CLEAR : so_auart, so_auart[],
          so_fksta, so_fksta[],
          so_absta, so_absta[].

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'A'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'B'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'C'.
  APPEND  so_fksta.

  so_fksta-low    =  'X'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  ' '.
  APPEND  so_fksta.


ENDFORM.                    " ALL_OUT_VARIANT
*&---------------------------------------------------------------------*
*&      Form  ZBC2_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zbc2_variant .
** Layout관련
  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout

  CLEAR : so_auart, so_auart[],
          so_fksta, so_fksta[],
          so_absta, so_absta[].

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'A'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'B'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'C'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  'X'.
  APPEND  so_fksta.

  so_fksta-sign   =  'I'.
  so_fksta-option =  'EQ'.
  so_fksta-low    =  ' '.
  APPEND  so_fksta.

  so_auart-sign   =  'I'.
  so_auart-option =  'EQ'.
  so_auart-low    =  'ZBC2'.
  APPEND so_auart.

  so_auart-sign   =  'I'.
  so_auart-option =  'EQ'.
  so_auart-low    =  'OR'.
  APPEND so_auart.
ENDFORM.                    " ZBC2_VARIANT
*&---------------------------------------------------------------------*
*&      Form  CHANGE_CHAR_POINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_p_chr  text
*----------------------------------------------------------------------*
FORM change_char_point  CHANGING p_chr.

*--[START]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건

*Declaration.
  CONSTANTS:con_dot   TYPE c VALUE '.',
            con_comma TYPE c VALUE ',',
            con_space TYPE c VALUE ' '.

  DATA:
    tmp_chr(100)  TYPE c,           "help sting to convert
*the char format
    z             LIKE sy-subrc VALUE 0,
    j             LIKE sy-subrc,                           "
    i             TYPE p,
    sign_count    TYPE i  VALUE 0, "counts the signs ',' '.' in the string
    decimal_point TYPE i.

  DATA: p_chr_string TYPE string.
  DATA: length TYPE i.

* move the chr field to a string field
  p_chr_string = p_chr.

* work out the length
  length = strlen( p_chr_string ).

  DO length TIMES.
    IF p_chr+z(1) = con_comma OR p_chr+z(1) =
con_dot
                               OR p_chr+z(1) = con_space.
      sign_count = sign_count + 1.
    ENDIF.
    z =  z + 1.
  ENDDO.


*in case there are more then one sign
  IF sign_count > 0.
    decimal_point = sign_count.
* Z = Z - 1.
    j = z.
*loop on the string leave only one dot to seprate to decimal digits
    WHILE  ( z >= 0 ) AND ( NOT p_chr+i(1) IS INITIAL ).

      IF p_chr+z(1) = con_comma OR p_chr+z(1) =
con_dot.
*if it is the last doe or coma from right side put dote insted
        IF decimal_point = sign_count.
          IF  p_chr+z(1) = con_dot
           OR  p_chr+z(1) = con_comma
           OR  p_chr+z(1) = con_comma.
            WRITE con_dot TO tmp_chr+j(1).
            j = j - 1.
          ENDIF.
        ENDIF.
        sign_count = sign_count - 1.
      ELSEIF p_chr+z(1) = con_space.
      ELSE.
        WRITE p_chr+z(1) TO tmp_chr+j(1).
        j = j - 1.
      ENDIF. .
      z = z - 1.
    ENDWHILE.
    p_chr = tmp_chr.
    SHIFT p_chr LEFT DELETING LEADING space.
  ENDIF.


*--[END]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건


ENDFORM.                    " CHANGE_CHAR_POINT
*&---------------------------------------------------------------------*
*&      Form  GET_CU_QTY
*&---------------------------------------------------------------------*
FORM get_cu_qty USING lv_chul_qty.

  DATA : wa_cstmat LIKE cstmat.
  DATA : lv_kwmeng TYPE vbap-kwmeng.
  DATA : lv_cu_qty LIKE vbap-brgew.
  DATA : BEGIN OF it_stb OCCURS  0.
           INCLUDE STRUCTURE   stpox.
  DATA : mark,
           beskz LIKE marc-beskz.
  DATA : END OF it_stb.
  DATA : lv_stlal LIKE mast-stlal.
  DATA : lv_werks LIKE marc-werks.

  CLEAR: it_stb, it_stb[], wa_cstmat, lv_stlal, lv_werks.


  "보관품 플랜트일 경우 일반 플랜트로 변경
  lv_werks = g_itab_t-werks.

  IF lv_werks+2(2) = '91'.
    lv_werks+2(2) = '01'.
  ENDIF.

  "대체BOM이 가장 최신인 것을 찾음
  SELECT SINGLE MAX( t~stlal )
    INTO lv_stlal
    FROM mast AS t
    JOIN stko AS o
      ON t~stlnr = o~stlnr "BOM코드
     AND t~stlal = o~stlal "대체BOM
   WHERE t~matnr = g_itab_t-matnr"자재코드
     AND t~werks = lv_werks "플랜트
     AND t~stlan = '1'   "BOM 용도
     AND o~stlst = '1'.  "BOM 활성화 여부

  "BOM 전개 후 5000003의 수량 합을 구함
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'ED01'
      datuv                 = sy-datlo
      emeng                 = '1'
      mdmps                 = ' '
      mehrs                 = 'X'
      mtnrv                 = g_itab_t-matnr
      stlal                 = lv_stlal
      stlan                 = '1'
      werks                 = lv_werks
    IMPORTING
      topmat                = wa_cstmat
    TABLES
      stb                   = it_stb
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  IF sy-subrc = 0.

    CLEAR lv_cu_qty.

    LOOP AT it_stb WHERE idnrk = '000000000005000003'.

      lv_cu_qty = lv_cu_qty + it_stb-mngko.

    ENDLOOP.

*     판매단위와 기본단위가 상이할 경우 기본단위로 판매수량을 변환한다.
    CLEAR : lv_kwmeng.
    CALL FUNCTION 'FCO_CONVERT_TO_BASE_UNIT'
      EXPORTING
        i_matnr = g_itab_t-matnr
        i_quant = lv_chul_qty
        i_meinh = g_itab_t-vrkme
        i_plnme = g_itab_t-vrkme
        i_umrez = 1
        i_umren = 1
      IMPORTING
        e_quant = lv_kwmeng.

    IF sy-subrc = 0.

      CLEAR g_itab_t-cu_qty.

      g_itab_t-cu_qty = ( lv_cu_qty / 1000 ) * lv_kwmeng.

    ENDIF.

  ELSE.

    g_itab_t-cu_qty = 0.

  ENDIF.

ENDFORM.                    " GET_CU_QTY
*&---------------------------------------------------------------------*
*& Form get_spart60_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_spart60_data  USING  pv_vbelv      "납품문서
                              pv_posnv      "납품문서 품목
                              pv_wadat_ist  "최초 납품일자
                              pv_vbeln_v.  "최초 납품문서

  DATA: lv_vgbel LIKE lips-vgbel,
        lv_vgpos LIKE lips-vgpos,
        lv_vbeln LIKE zsd1053t-vbeln,
        lv_posnr LIKE zsd1053t-posnr.

  SELECT SINGLE a~vbeln a~posnr
    FROM vbap AS a
   INNER JOIN lips AS b
      ON a~vbeln EQ b~vgbel
     AND a~posnr EQ b~vgpos
    INTO (lv_vgbel, lv_vgpos)
   WHERE b~vbeln EQ pv_vbelv
     AND b~posnr EQ pv_posnv.

  IF lv_vgbel IS NOT INITIAL.
    SELECT SINGLE vbeln posnr
      FROM zsd1053T
      INTO (lv_vbeln, lv_posnr)
     WHERE vbeln1 EQ lv_vgbel
       AND posnr1 EQ lv_vgpos.
  ENDIF.


*__S/4HANA에서 적송 시작한 경우
* 최초납품일자 및 최초납품문서 그대로 사용
  IF lv_vbeln IS NOT INITIAL.

    SELECT SINGLE MIN( vbelv )
      FROM zvbfa_r3
      INTO pv_vbeln_v
     WHERE vbtyp_v EQ c_vbtyp_v
       AND vbeln   EQ lv_vbeln
       AND posnn   EQ lv_posnr.

    IF pv_vbeln_v IS NOT INITIAL.
      SELECT SINGLE wadat_ist
        FROM zlikp_r3
        INTO pv_wadat_ist
       WHERE vbeln EQ pv_vbeln_v.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_except60_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_except60_data  USING  pv_wadat_ist  "최초 납품일자
                               pv_vbeln_v.  "최초 납품문서


  DATA: lv_vgbel LIKE lips-vgbel,
        lv_vgpos LIKE lips-vgpos.

*최초납품문서가 없을 경우 납품문서 찾기
  IF pv_vbeln_v IS INITIAL.
*Mig된 후 납품일자 찾기
    SELECT SINGLE MIN( vbelv )
      INTO pv_vbeln_v
      FROM zvbfa_r3
     WHERE vbeln = g_itab_t-vgbel
       AND posnn = g_itab_t-vgpos
       AND vbtyp_v = c_vbtyp_v. " 'J'

*ZVBFA에서 최초 납품문서 찾으면 ZLIKP_R3에서 최초 납품일자
    IF pv_vbeln_v IS NOT INITIAL.
      SELECT SINGLE wadat_ist
        INTO pv_wadat_ist
        FROM zlikp_r3
       WHERE lfart EQ c_lfart
         AND vbeln EQ pv_vbeln_v.

    ELSE.
* Mig된 이후 추가 적송 시, 납품일자 찾기
      CLEAR : lv_vgbel, lv_vgpos.
      SELECT SINGLE MIN( a~vbelv ) a~posnv
        INTO (lv_vgbel, lv_vgpos)
        FROM vbfa AS a
       INNER JOIN vbak AS b
          ON a~vbelv EQ b~vbeln
       WHERE b~auart = 'ZBC2' "적송오더
         AND a~vbeln = g_itab_t-vbeln  "적송납품
         AND a~posnn = g_itab_t-posnr "품목
       GROUP BY  a~posnv.


      IF lv_vgbel IS NOT INITIAL.
*-> CCM : 04.01.2024 09:43:26 / ZLSGSD4
*            SELECT SINGLE MIN( a~vbelv )
*              FROM zvbfa_r3 AS a
*             INNER JOIN zlips_r3 AS b
*                ON a~vbeln EQ b~vbeln
*               AND a~posnn EQ b~posnr
*              INTO pv_vbeln_v
*             WHERE a~vbtyp_v EQ c_vbtyp_v
*               AND b~vgbel   EQ lv_vgbel
*               AND b~vgpos   EQ lv_vgpos.

        SELECT SINGLE MIN( vbelv )
          FROM zvbfa_r3
          INTO pv_vbeln_v
         WHERE vbtyp_v EQ c_vbtyp_v
           AND vbeln   EQ lv_vgbel
           AND posnn   EQ lv_vgpos.
*<-

        IF pv_vbeln_v IS NOT INITIAL.
          SELECT SINGLE wadat_ist
            FROM zlikp_r3
            INTO pv_wadat_ist
           WHERE vbeln EQ pv_vbeln_v.

*            SELECT SINGLE MIN( a~vbelv ) c~wadat_ist
*              FROM zvbfa_r3 AS a
*             INNER JOIN zlips_r3 AS b
*                ON a~vbeln EQ b~vbeln
*               AND a~posnn EQ b~posnr
*             INNER JOIN zlikp_r3 AS c
*                ON a~vbeln EQ c~vbeln
*              INTO (pv_vbeln_v, pv_wadat_ist)
*             WHERE a~vbtyp_v EQ c_vbtyp_v
*               AND b~vgbel   EQ lv_vgbel
*               AND b~vgpos   EQ lv_vgpos
*             GROUP BY c~wadat_ist.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_default_layout .

  IF  default  =  ' '.

    CLEAR def_layout.
    MOVE  g_repid   TO  def_layout-report.

    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = def_layout
      EXCEPTIONS
        not_found  = 2.

    IF  sy-subrc  =  2.
*          message s001 with '레이아웃 기본세팅이 없습니다.'.
    ELSE.
*
** set name of layout on selection screen
*         perform activate_def_v.
      p_vari = def_layout-variant.
      default = 'X'.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_layout .

*-{기능개선 44758 - 추가
  IF sy-ucomm = 'UCOMM'.
    gv_change = 'X'.
  ENDIF.
*-{기능개선 44758_2014.09.25

** Layout 입력안했을때 Default(기본) Layout Display.
  CLEAR spec_layout.

  IF  p_vari IS INITIAL.
    MOVE  def_layout-variant  TO  spec_layout-variant.
  ELSE.
    MOVE  p_vari  TO  spec_layout-variant.
  ENDIF.

* 권한 CHECK
  PERFORM authority_check.

** 기본세팅이 없는 리스트도 있기때문에...
  CHECK spec_layout-variant NE space.

  MOVE  g_repid  TO  spec_layout-report.

  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    EXPORTING
      i_save        = g_save
    CHANGING
      cs_variant    = spec_layout
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.

  IF  sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  data_sub_query
*&---------------------------------------------------------------------*
*FORM DATA_SUB_QUERY_OLD.
*
*  DATA : L_WMENG   LIKE ZTETFDP-WMENG,
*         L_POSNR   LIKE LIPS-POSNR,
*         L_CURRDEC LIKE TCURX-CURRDEC.
*
*  DATA : LV_QUANT1 TYPE FCO_RQUANT,
*         LV_QUANT2 TYPE FCO_RQUANT.
*
*  DATA : PV_MEINS TYPE MEINH,
*         PV_VRKME TYPE PLNME.
*
**-> CCM : 04.01.2024 09:43:26 / ZLSGSD4
*  DATA : LV_VGBEL LIKE LIPS-VGBEL,
*         LV_VGPOS LIKE LIPS-VGPOS,
*         LV_CHAR.
**<-
*
*  LOOP AT G_ITAB_T.
*
*    CLEAR : L_WMENG, L_CURRDEC.
*
***납품예정일
*    SELECT  SINGLE EDATU
*      INTO  G_ITAB_T-EDATU
*      FROM  VBEP
*     WHERE  VBELN  =  G_ITAB_T-VGBEL
*       AND  POSNR  =  G_ITAB_T-VGPOS.
*
*** 지급처
*    SELECT  SINGLE NAME1
*      INTO  G_ITAB_T-NAME1
*      FROM  KNA1
*     WHERE  KUNNR  =  G_ITAB_T-PAYER.
*
*    SELECT  SINGLE STAWN
*      INTO  G_ITAB_T-STAWN
*      FROM  MARC
*     WHERE  MATNR  =  G_ITAB_T-MATNR
*       AND  WERKS  =  G_ITAB_T-WERKS.
*
*    IF  SY-TCODE  =  'ZGTSDR0140'.
*
*** 납품수량 - L/C Open된 수량.
*      SELECT  SINGLE WMENG
*        INTO  L_WMENG
*        FROM  ZTETFDP
*       WHERE  VBELN  =  G_ITAB_T-VBELN
*         AND  POSNR  =  G_ITAB_T-POSNR.
*
*      G_ITAB_T-LFIMG  =  G_ITAB_T-LFIMG  -  L_WMENG.
*
*    ENDIF.
*
*** 단가(소수5자리) : 주문금액 / 주문수량.
*    G_ITAB_T-NETPR2  =  G_ITAB_T-NETWR  /  G_ITAB_T-KWMENG.
*
*** 수량단위 확인
*    SELECT SINGLE MANDT
*      INTO SY-MANDT
*      FROM VBAP
*     WHERE VBELN =  G_ITAB_T-VGBEL
*       AND POSNR =  G_ITAB_T-VGPOS
*       AND VRKME =  G_ITAB_T-VRKME.
*
*    IF SY-SUBRC NE 0.
*
*      CALL FUNCTION 'Z_TE_CALC_ITEM_AMOUNT_DO'
*        EXPORTING
*          IM_VBELN = G_ITAB_T-VBELN
*          IM_POSNR = G_ITAB_T-POSNR
*          IM_WMENG = G_ITAB_T-LFIMG
*          IM_TYPE  = 'D'
*        IMPORTING
*          EX_NETWR = G_ITAB_T-NETWR.
*
*    ELSE.
*** 금액 : 단가(소수5자리) * 납품수량.
*      G_ITAB_T-NETWR  =  G_ITAB_T-NETPR2  *  G_ITAB_T-LFIMG.
*    ENDIF.
*** 원화금액
*    IF  G_ITAB_T-WAERK  NE  'KRW'.
*      G_ITAB_T-K_NETWR  =  G_ITAB_T-NETWR  *  G_ITAB_T-KURSK.
*      G_ITAB_T-K_NETWR  =  G_ITAB_T-K_NETWR  /  100.
*      G_ITAB_T-NETPR    =  G_ITAB_T-K_NETWR / G_ITAB_T-LFIMG.
*    ELSE.
*      G_ITAB_T-K_NETWR  =  G_ITAB_T-NETWR.
*      G_ITAB_T-NETPR    =  G_ITAB_T-NETPR2.
*    ENDIF.
*
*    G_ITAB_T-WAERS = 'KRW'.
*
*    IF  G_ITAB_T-AUART = 'ZCS'.
*      CLEAR : G_ITAB_T-NETWR, G_ITAB_T-K_NETWR.
*    ENDIF.
*
*** 자재 특성관련
*    SELECT  SINGLE
*            ZZCOLOR_BASE      " 색상Base
*            ZZRAL_CODE        " 상세색상
*            ZZCOLOR_STRIPE    " 색상Stripe
*            ZZIDEN_CODE       " 절연선심식별
*            ZZSPEC_NO         " Spec No
*            ZZSPEC_DETAIL     " Spec 상세
*      INTO  CORRESPONDING FIELDS OF G_ITAB_T
*      FROM  MARA
*     WHERE  MATNR  =  G_ITAB_T-MATNR.
*
*    CLEAR  L_POSNR.
*
*    IF  G_ITAB_T-UECHA  NE  '000000'.
*      L_POSNR  =  G_ITAB_T-UECHA.
*    ELSE.
*      L_POSNR  =  G_ITAB_T-POSNR.
*    ENDIF.
*
*** 거래명세서 발행일자.
*    SELECT  SINGLE ZLET0005~IV_DATE
*      INTO  G_ITAB_T-IV_DATE
*      FROM  ZLET0006 INNER JOIN ZLET0005
*                     ON ZLET0005~IV_NO  =  ZLET0006~IV_NO
*     WHERE  ZLET0006~VBELN  =  G_ITAB_T-VBELN
*       AND  ZLET0006~POSNR  =  L_POSNR
*       AND  ( ZLET0005~IV_CANCEL_YN  =  ' '
*        OR    ZLET0005~IV_CANCEL_YN  IS NULL ).
*
*** 납품처
*    SELECT  SINGLE KUNNR
*      INTO  G_ITAB_T-KUNNR2
*      FROM  VBPA
*     WHERE  VBELN  =  G_ITAB_T-VGBEL
*       AND  POSNR  =  '0'
*       AND  PARVW  =  'WE'.     " 납품처
*
*    SELECT  SINGLE NAME1
*      INTO  G_ITAB_T-NAME2
*      FROM  KNA1
*     WHERE  KUNNR  =  G_ITAB_T-KUNNR2.
*
*** 사업장명
*    SELECT  SINGLE BEZEI
*      INTO  G_ITAB_T-BEZEI
*      FROM  TVKBT
*     WHERE  SPRAS  =  SY-LANGU
*       AND  VKBUR  =  G_ITAB_T-VKBUR.
*
*** 영업그룹명
*    SELECT  SINGLE BEZEI
*      INTO  G_ITAB_T-BEZEI2
*      FROM  TVGRT
*     WHERE  SPRAS  =  SY-LANGU
*       AND  VKGRP  =  G_ITAB_T-VKGRP.
*
*** 동량 계산
*    IF G_ITAB_T-MTART = 'MCFE' OR G_ITAB_T-MTART = 'MCHA'.
*      CLEAR : LV_CHUL_QTY.
*
*      LV_CHUL_QTY = G_ITAB_T-LFIMG.
*
**__ 기능개선 111262 - 선박해양영업팀 동량 계산 로직 변경 {
**   알루미늄 수량은 사용하지 않는다고 하여 표시 제외함
*
*      IF G_ITAB_T-VKBUR = '1510' AND G_ITAB_T-MTART = 'MCFE'.
*        PERFORM GET_CU_QTY USING LV_CHUL_QTY.
*      ELSE.
*        CALL FUNCTION 'ZSD_CALC_NFM_QTY'
*          EXPORTING
*            I_VKORG  = G_ITAB_T-VKORG
*            I_VTWEG  = G_ITAB_T-VTWEG
*            I_MATNR  = G_ITAB_T-MATNR
*            I_VRKME  = G_ITAB_T-VRKME
*            I_KWMENG = LV_CHUL_QTY         "납품수량
*          IMPORTING
*            E_CUQTY  = G_ITAB_T-CU_QTY
*            E_ALQTY  = G_ITAB_T-AL_QTY.
*      ENDIF.
*    ENDIF.
*
** 최초 출고일 가져옴
** 수출로컬/직수출일경우 최초 계획일자
*    IF G_ITAB_T-AUART = 'ZEXE' OR G_ITAB_T-KDKG4 = '4S'.
*      CLEAR : LIKP.
*      SELECT SINGLE * FROM LIKP
*      WHERE  VBELN EQ G_ITAB_T-VBELN.
*      IF SY-SUBRC = 0.
*        G_ITAB_T-F_WADAT = LIKP-WADAT.
*      ENDIF.
** 내수/내수로컬일경우
*    ELSE.
*
*      CLEAR : GT_VBFA, GT_VBFA[], GV_WADAT_IST, LIKP.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_VBFA
*         FROM VBFA
*         WHERE VBELN = G_ITAB_T-VBELN
*           AND POSNN = G_ITAB_T-POSNR
*           AND VBTYP_N =  C_VBTYP_N
*           AND VBTYP_V =  C_VBTYP_V.
*
*      IF SY-SUBRC = 0.
*        SORT GT_VBFA BY VBELV.
*        READ TABLE GT_VBFA INDEX 1.
*        SELECT SINGLE * FROM LIKP
*        WHERE  LFART EQ C_LFART
*        AND    VBELN EQ GT_VBFA-VBELV.
*        IF SY-SUBRC = 0.
*          G_ITAB_T-VBELN_V = GT_VBFA-VBELV.
*          G_ITAB_T-F_WADAT = LIKP-WADAT_IST.
*        ENDIF.
*
*      ENDIF.
*
**-> CCM : 28.12.2023 11:04:33 / ZLSGSD4
*      IF G_ITAB_T-SPART = '60'.
**-> CCM : 04.01.2024 09:43:26 / ZLSGSD4
**-- 부스덕트 mig한 첫 달에는 gt_vbfa에 값 X
*        IF GT_VBFA[] IS INITIAL.
*          LV_VGPOS = G_ITAB_T-VGPOS.
**{ SRM2402-03430 - s
*          LV_CHAR = LV_VGPOS+0(1).
*          IF LV_CHAR NE '0'.
*            REPLACE LV_CHAR IN LV_VGPOS WITH '0'.
*          ENDIF.
**} SRM2402-03430 - e
*
*          SELECT SINGLE A~VBELN A~WADAT_IST
*            FROM ZLIKP_R3 AS A
*           INNER JOIN ZLIPS_R3 AS B
*              ON A~VBELN EQ B~VBELN
*            INTO (G_ITAB_T-VBELN_V, G_ITAB_T-F_WADAT)
*           WHERE B~VGBEL EQ G_ITAB_T-VGBEL  "부스덕트는 원오더로 적송오더번호 이관됨
*             AND B~VGPOS EQ LV_VGPOS.
*
*          CLEAR LV_VGPOS.
*        ELSE.
**<-
*          PERFORM GET_SPART60_DATA USING GT_VBFA-VBELV
*                                         GT_VBFA-POSNV
*                                         G_ITAB_T-F_WADAT
*                                         G_ITAB_T-VBELN_V.
*        ENDIF.
*      ELSE.
*        PERFORM GET_EXCEPT60_DATA USING G_ITAB_T-F_WADAT
*                                        G_ITAB_T-VBELN_V.
*      ENDIF.
**<-
*
*    ENDIF.
** 여기까지
***[START]C20100723_07992 \
****드럼번호 추가
*    SELECT SINGLE EMPST
*      INTO G_ITAB_T-EMPST
*      FROM VBKD
*     WHERE VBELN = G_ITAB_T-VGBEL
*       AND POSNR = G_ITAB_T-VGPOS.
****[END]C20100723_07992
*
**[Start CSR:C20100928_44362]PJT&APPL명추가.
*    SELECT SINGLE ZPTXT
*      INTO G_ITAB_T-ZPTXT
*      FROM ZSD0106T
*     WHERE ZPJNO = G_ITAB_T-ZPJNO.
**[End CSR:C20100928_44362]
****[start]단위환산결과
*
*    CLEAR : LV_QUANT1,LV_QUANT2, PV_MEINS, PV_VRKME.
*
*    LV_QUANT1 =  G_ITAB_T-LFIMG.
*    PV_MEINS  =  G_ITAB_T-VRKME.
*    PV_VRKME  =  'KG'.
*
*    CALL FUNCTION 'FCO_CONVERT_FROM_BASE_UNIT'
*      EXPORTING
*        I_MATNR       = G_ITAB_T-MATNR
*        I_QUANT       = LV_QUANT1
*        I_MEINH       = PV_MEINS
*        I_PLNME       = PV_VRKME
*        I_UMREZ       = '1'
*        I_UMREN       = '1'
*      IMPORTING
*        E_QUANT       = LV_QUANT2
*      EXCEPTIONS
*        ERROR_OCCURED = 1
*        OTHERS        = 2.
*
*    G_ITAB_T-LFIMG_CH = LV_QUANT2.
*
*    REFRESH: GT_CHAR1.
*
*    CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE'
*      EXPORTING
**       i_vbeln                      = g_itab_t-vbeln
**       i_posnr                      = g_itab_t-posnr
*        I_VBELN                      = G_ITAB_T-VGBEL
*        I_POSNR                      = G_ITAB_T-VGPOS
** IMPORTING
**       ET_RETURN                    =
*      TABLES
*        ET_CHAR                      = GT_CHAR1
*      EXCEPTIONS
*        INSTANCE_NOT_FOUND           = 1
*        INSTANCE_IS_A_CLASSIFICATION = 2
*        INVALID_DATA                 = 3
*        OTHERS                       = 4.
*
*    IF NOT GT_CHAR1[] IS INITIAL.
**   조장
*      READ TABLE GT_CHAR1 WITH KEY ATNAM = SO_LENGTH.
*      IF SY-SUBRC = 0.
*        G_ITAB_T-LENGTH = GT_CHAR1-ATWRT.
*        PERFORM CHANGE_CHAR_POINT CHANGING G_ITAB_T-LENGTH.
*      ENDIF.
**   조장수
*      READ TABLE GT_CHAR1 WITH KEY ATNAM = SO_FACTOR.
*      IF SY-SUBRC = 0.
*        G_ITAB_T-FACTOR = GT_CHAR1-ATWRT.
*      ENDIF.
**   튜브 프린트
*      READ TABLE GT_CHAR1 WITH KEY
*            ATNAM = 'PD_TB_PRINT_APP'.
*      IF SY-SUBRC = 0.
*        G_ITAB_T-TB_PRINT = GT_CHAR1-ATWRT.
*      ENDIF.
*    ENDIF.
*
*    MODIFY  G_ITAB_T.
*    CLEAR  G_ITAB_T.
*
*  ENDLOOP.
*
*** 반품유형인 경우 : 'RE', 'ZBC1', 'ZBC3'인경우 수량 및 금액에
*** (-1)해서 계산한다.
*  LOOP AT G_ITAB_T.
*
*    IF  G_ITAB_T-AUART  =  'RE'    OR
*        G_ITAB_T-AUART  =  'ZRET'    OR
*        G_ITAB_T-AUART  =  'YSRE'    OR
*        G_ITAB_T-AUART  =  'ZBC1'  OR
*        G_ITAB_T-AUART  =  'ZBC3'.
*      G_ITAB_T-LFIMG  =  G_ITAB_T-LFIMG  *  -1.
*      G_ITAB_T-NETWR  =  G_ITAB_T-NETWR  *  -1.
*      G_ITAB_T-K_NETWR  =  G_ITAB_T-K_NETWR  *  -1.
*    ENDIF.
*
*    MODIFY  G_ITAB_T.
*    CLEAR  G_ITAB_T.
*
*  ENDLOOP.
*
*
*
*ENDFORM.                    " data_sub_query_old
*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA_COLLECTIVELY
*&---------------------------------------------------------------------*
*& SRM2403-04408 - 추가
*&---------------------------------------------------------------------*
FORM get_other_data_collectively .
  DATA: BEGIN OF lt_marc OCCURS 0,
          matnr LIKE marc-matnr,
          werks LIKE marc-werks,
        END   OF lt_marc.


  RANGES : lr_sobkz FOR lips-sobkz,
           lr_ebeln FOR lips-ebeln,
           lr_ebelp FOR lips-ebelp,
           lr_lifnr FOR likp-lifnr.

  CHECK g_itab_t[] IS NOT INITIAL.

  REFRESH : gr_atnamo, gt_ords,  gt_ordvals,
            gt_tvkbt,  gt_tvgrt,
            gt_kna1,   gt_marc,  gt_vbfa_all,
            gt_vbep,   gt_vbpa,  gt_vbkd,
            gt_zfdp,   gt_0005,  gt_0106.

*___영업팀
  SELECT *
    INTO TABLE gt_tvkbt
    FROM tvkbt
     FOR ALL ENTRIES IN g_itab_t
   WHERE spras = sy-langu
     AND vkbur = g_itab_t-vkbur.

  SORT gt_tvkbt BY vkbur.

*___영업그룹
  SELECT *
    INTO TABLE gt_tvgrt
    FROM tvgrt
     FOR ALL ENTRIES IN g_itab_t
   WHERE spras = sy-langu
     AND vkgrp = g_itab_t-vkgrp.

  SORT gt_tvgrt BY vkgrp.

*___납품예정일
  SELECT vbeln
         posnr
         edatu
    INTO TABLE gt_vbep
    FROM vbep
     FOR ALL ENTRIES IN g_itab_t
   WHERE vbeln = g_itab_t-vgbel
     AND posnr = g_itab_t-vgpos
     AND etenr = '0001'.

  SORT gt_vbep BY vbeln posnr.

*___파트너
  SELECT a~vbeln
         a~posnr
         a~parvw
         a~kunnr
         a~lifnr
         a~adrnr
         b~name1
         c~name1 AS name2
         d~name1 AS namad
    INTO TABLE gt_vbpa
    FROM vbpa AS a
    LEFT OUTER JOIN kna1 AS b
      ON a~kunnr = b~kunnr
    LEFT OUTER JOIN lfa1 AS c
      ON a~lifnr = c~lifnr
    LEFT OUTER JOIN adrc AS d
      ON a~adrnr     =  d~addrnumber
     AND d~date_from <= sy-datum
     AND d~nation    =  ' '
     FOR ALL ENTRIES IN g_itab_t
   WHERE vbeln =   g_itab_t-vgbel
     AND parvw IN ('WE', 'VE').         "납품처, 영업사원

  SORT gt_vbpa BY vbeln posnr parvw.

*___Business Data
  SELECT vbeln
         posnr
         empst
    INTO TABLE gt_vbkd
    FROM vbkd
     FOR ALL ENTRIES IN g_itab_t
   WHERE vbeln = g_itab_t-vgbel
     AND posnr = g_itab_t-vgpos.

  SORT gt_vbkd BY vbeln posnr.

*___영업문서흐름
  SELECT vbelv
         posnv
         vbeln
         posnn
         bwart
         erdat
    INTO TABLE gt_vbfa_all
    FROM vbfa
     FOR ALL ENTRIES IN g_itab_t
   WHERE vbeln   = g_itab_t-vbeln
     AND posnn   = g_itab_t-posnr
     AND vbtyp_n = c_vbtyp_n
     AND vbtyp_v = c_vbtyp_v.

  SELECT vbelv
         posnv
         vbeln
         posnn
         bwart
         erdat
    APPENDING CORRESPONDING FIELDS OF TABLE gt_vbfa_all
    FROM vbfa
     FOR ALL ENTRIES IN g_itab_t
   WHERE vbeln   = g_itab_t-vbeln
     AND posnn   = g_itab_t-posnr
     AND bwart   = '687'
     AND vbtyp_n = c_vbtyp_n
     AND vbtyp_v = 'C'.

  SORT gt_vbfa_all BY vbeln posnn.

*___고객명
  SELECT kunnr
         name1
    INTO TABLE gt_kna1
    FROM kna1
     FOR ALL ENTRIES IN g_itab_t
   WHERE kunnr = g_itab_t-payer.

  SORT gt_kna1 BY kunnr.

*___자재특성
  SELECT matnr
         zzcolor_base      " 색상Base
         zzral_code        " 상세색상
         zzcolor_stripe    " 색상Stripe
         zziden_code       " 절연선심식별
         zzspec_no         " Spec No
         zzspec_detail     " Spec 상세
    INTO TABLE gt_mara
    FROM mara
     FOR ALL ENTRIES IN g_itab_t
   WHERE matnr = g_itab_t-matnr.

  SORT gt_mara BY matnr.

*___HS Code
  SELECT werks
         matnr
         stawn
    INTO TABLE gt_marc
    FROM marc
     FOR ALL ENTRIES IN g_itab_t
   WHERE matnr = g_itab_t-matnr
     AND werks = g_itab_t-werks.

  SORT gt_marc BY werks matnr.

  IF  sy-tcode  =  'ZGTSDR0140'.
*___[Export] Financial Document Item - L/C Open된 수량
    SELECT vbeln
           posnr
           wmeng
      INTO TABLE gt_zfdp
      FROM ztetfdp
       FOR ALL ENTRIES IN g_itab_t
     WHERE vbeln = g_itab_t-vbeln
       AND posnr = g_itab_t-posnr.

    SORT gt_zfdp BY vbeln posnr.
  ENDIF.

*___거래명세서 발행일
  SELECT a~vbeln
         a~posnr
         b~iv_date
    INTO TABLE gt_0005
    FROM zlet0006 AS a
   INNER JOIN zlet0005 AS b
      ON b~iv_no = a~iv_no
     FOR ALL ENTRIES IN g_itab_t
   WHERE a~vbeln = g_itab_t-vbeln
     AND ( a~posnr = g_itab_t-posnr
        OR a~posnr = g_itab_t-uecha )
     AND ( b~iv_cancel_yn =  ' '
        OR b~iv_cancel_yn IS NULL ).

  SORT gt_0005 BY vbeln posnr.

*___Project 명
  SELECT zpjno
         zptxt
    INTO TABLE gt_0106
    FROM zsd0106t
     FOR ALL ENTRIES IN g_itab_t
   WHERE zpjno = g_itab_t-zpjno.

  SORT gt_0106 BY zpjno.

*___오더 특성
  gr_atnamo = VALUE #( BASE gr_atnamo
                         sign = 'I' option = 'EQ'
                         ( low = so_length          )
                         ( low = so_factor          )
                         ( low = ba_pd_tb_print_app ) ).
  gt_ords   = VALUE #( BASE gt_ords
                       FOR lw_list IN g_itab_t
                         WHERE ( vgbel IS NOT INITIAL )
                         ( vbeln = lw_list-vgbel
                           posnv = lw_list-vgpos ) ).

*___오더 특성
  CALL FUNCTION 'Z_GET_CHAR_OF_ORDER'
    EXPORTING
      ir_atnam = gr_atnamo
    TABLES
      it_ords  = gt_ords
      et_vals  = gt_ordvals.

  IF r3 = |X|.

    RANGES : lr_jah FOR zgtcot4180-jahrper.
    DATA : lv_sdt  TYPE sy-datum,
           lv_jah  TYPE zgtcot4180-jahrper,
           lv_jaht TYPE zgtcot4180-jahrper.

    lv_sdt = sy-datum(6) && '01'.
    lv_sdt = lv_sdt - 1.
    lv_jaht = lv_sdt(4) && '0' && lv_sdt+4(2).

    lv_sdt = lv_sdt(6) && '01'.
    lv_sdt = lv_sdt - 1.
    lv_jah = lv_sdt(4) && '0' && lv_sdt+4(2).

    __rng lr_jah 'I' 'BT' lv_jah lv_jaht.

    SELECT * INTO TABLE @gt_4180
      FROM zgtcot4180
       FOR ALL ENTRIES IN @g_itab_t
     WHERE bukrs = '1000'
       AND curtp = '10'
       AND categ = 'EB'
       AND matnr = @g_itab_t-matnr
       AND werks = @g_itab_t-werks
       AND vbeln = @g_itab_t-vbeln
       AND posnr = @g_itab_t-posnr
       AND jahrper IN @lr_jah.

    SORT gt_4180 BY vbeln posnr matnr werks ASCENDING jahrper DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_4180 COMPARING vbeln posnr matnr werks.

    Gt_deli[] = VALUE #( FOR ls_tmp IN g_itab_t
                   ( sign = 'I'
                     option = 'EQ'
                     low = ls_tmp-vbeln
                     high = '' ) ).
    SORT gt_deli.
    DELETE ADJACENT DUPLICATES FROM gt_deli COMPARING ALL FIELDS.



    TRY.
        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
          EXPORTING
            i_wi_gm               = 'X'
            i_condense            = space
          TABLES
            t_result              = Gt_result
            t_ra_sobkz            = lr_sobkz
            t_ra_ebeln            = lr_ebeln
            t_ra_ebelp            = lr_ebelp
            t_ra_lifnr            = lr_lifnr
            t_ra_del_out          = Gt_deli[] "delivery outbound
          EXCEPTIONS
            parameter_error       = 1
            missing_authorization = 2
            OTHERS                = 3.

      CATCH cx_root INTO DATA(lo_err).
        MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE zgtsd_e.
        LEAVE LIST-PROCESSING.
    ENDTRY.

    SORT GT_RESULT BY VBELN POSNR.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_kunnr_desc  USING    pv_kunnr
                     CHANGING pv_name1.

  CLEAR : pv_name1.

  READ TABLE gt_kna1 WITH KEY kunnr = pv_kunnr
                              BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_kna1.

    gt_kna1-kunnr = pv_kunnr.

    SELECT SINGLE name1
      INTO gt_kna1-name1
      FROM kna1
     WHERE kunnr = pv_kunnr.

    APPEND gt_kna1.

    SORT gt_kna1 BY kunnr.
  ENDIF.

  pv_name1 = gt_kna1-name1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HSCODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_hscode  USING    pv_werks
                          pv_matnr
                 CHANGING pv_stawn.

  CLEAR : pv_stawn.

  READ TABLE gt_marc WITH KEY werks = pv_werks
                              matnr = pv_matnr
                              BINARY SEARCH.
  IF sy-subrc = 0.
    pv_stawn = gt_marc-stawn.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_partner_name
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_partner_name  USING    pv_vbeln
                                pv_posnr
                                pv_parvw
                        CHANGING pv_kunnr
                                 pv_name1.

  READ TABLE gt_vbpa WITH KEY vbeln = pv_vbeln
                              posnr = pv_posnr
                              parvw = pv_parvw
                              BINARY SEARCH.
  IF sy-subrc <> 0.
    READ TABLE gt_vbpa WITH KEY vbeln = pv_vbeln
                                posnr = '000000'
                                parvw = pv_parvw
                                BINARY SEARCH.
  ENDIF.

  IF sy-subrc = 0.
    IF gt_vbpa-kunnr IS NOT INITIAL.
      pv_kunnr = gt_vbpa-kunnr.
      IF gt_vbpa-namad IS NOT INITIAL.
        pv_name1 = gt_vbpa-namad.
      ELSE.
        pv_name1 = gt_vbpa-name1.
      ENDIF.
    ELSE.
      pv_kunnr = gt_vbpa-lifnr.
      IF gt_vbpa-namad IS NOT INITIAL.
        pv_name1 = gt_vbpa-namad.
      ELSE.
        pv_name1 = gt_vbpa-name2.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PARAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_param .
  DATA : l_datediff TYPE p,
         l_perc     TYPE i.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE  =  l_perc
      text   = 'Data Loading....'
    EXCEPTIONS
      OTHERS = 1.

  READ TABLE so_wadat INDEX 1.

  IF  so_wadat-high  <>  '00000000'.
    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
        date1            = so_wadat-low
        time1            = sy-uzeit
        date2            = so_wadat-high
        time2            = sy-uzeit
      IMPORTING
        datediff         = l_datediff
      EXCEPTIONS
        invalid_datetime = 1
        OTHERS           = 2.

    IF  l_datediff  >  31 AND r3 = ' '..
      MESSAGE i002 WITH '조회기간을 31일 이상으로 하는 경우'
                        '많은 시간이 소요됩니다.'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MB5SIT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LIKP_VBELN
*&      --> L_POSNR
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM call_mb5sit_gi  USING    pv_vbeln pv_posnr
                     CHANGING ps_result TYPE mb5sit.
*
*  DATA : lt_result TYPE TABLE OF mb5sit WITH DEFAULT KEY WITH HEADER LINE,
*         lt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE.
*
*  RANGES : lr_sobkz FOR lips-sobkz,
*           lr_ebeln FOR lips-ebeln,
*           lr_ebelp FOR lips-ebelp,
*           lr_lifnr FOR likp-lifnr.
*
*  TRY.
*
*      IF sy-uname = 'ZLSGSD2'.
*        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
*          EXPORTING
*            i_wi_gm               = 'X'
*            i_condense            = space
*          TABLES
*            t_result              = lt_result
*            t_ra_sobkz            = lr_sobkz
*            t_ra_ebeln            = lr_ebeln
*            t_ra_ebelp            = lr_ebelp
*            t_ra_lifnr            = lr_lifnr
*            t_ra_del_out          = Gt_deli[] "delivery outbound
*          EXCEPTIONS
*            parameter_error       = 1
*            missing_authorization = 2
*            OTHERS                = 3.
*
*      ELSE.
*        __rng : lt_deli 'I' 'EQ' pv_vbeln ''.
*        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
*          EXPORTING
*            i_wi_gm               = 'X'
*            i_condense            = space
*          TABLES
*            t_result              = lt_result
*            t_ra_sobkz            = lr_sobkz
*            t_ra_ebeln            = lr_ebeln
*            t_ra_ebelp            = lr_ebelp
*            t_ra_lifnr            = lr_lifnr
*            t_ra_del_out          = lt_deli[] "delivery outbound
*          EXCEPTIONS
*            parameter_error       = 1
*            missing_authorization = 2
*            OTHERS                = 3.
*
*      ENDIF.
*    CATCH cx_root INTO DATA(lo_err).
*      MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE zgtsd_e.
*      LEAVE LIST-PROCESSING.
*  ENDTRY.

  READ TABLE Gt_result INTO ps_result WITH KEY VBELN = PV_VBELN
                                                posnr = pv_posnr
                                               Binary Search.
ENDFORM.
