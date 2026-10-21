*&---------------------------------------------------------------------*
*& Include          ZGTSDR0120F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  query_data
*&---------------------------------------------------------------------*
FORM query_data.

  RANGES : lr_wadt FOR likp-wadat_ist.

  DATA : lv_sdt TYPE sy-datum,
         lv_edt TYPE sy-datum.

  CLEAR : g_itab_t, g_itab_t[],
          g_sum_t,  g_sum_t[], g_fdis, gv_bill_yn.

  g_imode  =  pa_imode.

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '리스트를 구성 중입니다 %99999%%'.
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(zsdr0230) USING g_out_text g_linen.

  SELECT  vbap~vbeln AS vgbel
          vbap~posnr AS vgpos
          vbap~kwmeng
          vbap~vrkme AS vrkme_va
          lips~vrkme
          lips~vbeln
          lips~posnr
          lips~matnr
          vbap~arktx AS maktx
          lips~charg
          lips~lfimg
          lips~kcmeng
          vbap~netpr
          vbap~waerk
          vbap~taxm1
          vbkd~kdkg4
          lips~fksta
          likp~kunag
          likp~wadat_ist
          vbap~kpein
          lips~werks
          vbkd~zterm
          vbak~vbtyp
          likp~zout
          mara~zzcolor_base
          mara~zzcolor_stripe
          mara~zziden_code
          mara~zzspec_no
          mara~zzmaktx80
          mara~zzral_code
          mara~zzspec_detail
          lips~fkrel
          vbak~auart
          vbkd~bstkd
          vbak~taxk1
          lips~ladgr
          lips~bwart
          lips~pstyv
          vbkd~fbuda
          vbak~knkli
          vbak~vkbur
          vbak~vkgrp
          vbak~bstnk
          vbak~zpjno
          vbap~netwr AS netwr_p
          vbap~mwsbp
          kna1~name1
          t001w~j_1bbranch
          tvkbt~bezei
          likp~inco1 " CHM2510-00065
*          VKDFS~FAKSK
    INTO  CORRESPONDING FIELDS OF TABLE g_itab_t
    FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                     JOIN vbap ON vbap~vbeln = lips~vgbel
                              AND vbap~posnr = lips~vgpos
                     JOIN vbak ON vbak~vbeln = lips~vgbel
                     JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                              AND vbkd~posnr = '0'
                     JOIN vkdfs ON vkdfs~vbeln = lips~vbeln
                     JOIN mara ON mara~matnr = lips~matnr
                     JOIN makt ON makt~matnr = lips~matnr
                              AND makt~spras = sy-langu
                     LEFT OUTER JOIN kna1 ON kna1~kunnr = likp~kunag
                     LEFT OUTER JOIN t001w ON t001w~werks = likp~werks
                     LEFT OUTER JOIN tvkbt ON tvkbt~vkbur = vbak~vkbur
                                          AND tvkbt~spras = sy-langu
   WHERE  likp~kunag IN so_kunnr
     AND  likp~vkorg EQ pa_vkorg
     AND  lips~vtweg EQ pa_vtweg
     AND  lips~spart EQ pa_spart
     AND  vbak~vkbur IN so_vkbur
     AND  vbak~vkgrp IN so_vkgrp
     AND  likp~wadat_ist IN so_wadat
     AND  likp~wbstk EQ pa_wbstk
     AND  lips~fksta NE 'C'
     AND  lips~bwart NE '687'
     AND  vbkd~kdkg4 EQ p_local
     AND  vkdfs~fktyp IN so_fktyp
     AND  lips~fkrel IN ('K', 'A', 'H')
     AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT')
     AND  vbak~auart IN so_auart.

**********************************************************************
*POD
**********************************************************************

  CONCATENATE  so_wadat-low(6)  '01'  INTO  lv_sdt.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_sdt
    IMPORTING
      last_day_of_month = lv_edt
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lv_sdt = '20000101'.
  __rng lr_wadt 'I' 'BT' lv_sdt lv_edt.

  SELECT  vbap~vbeln AS vgbel
          vbap~posnr AS vgpos
          vbap~kwmeng
          vbap~vrkme AS vrkme_va
          lips~vrkme
          lips~vbeln
          lips~posnr
          lips~matnr
          vbap~arktx AS maktx
          lips~charg
          lips~lfimg
          lips~kcmeng
          vbap~netpr
          vbap~waerk
          vbap~taxm1
          vbkd~kdkg4
          lips~fksta
          likp~kunag
          likp~wadat_ist
          vbap~kpein
          lips~werks
          vbkd~zterm
          vbak~vbtyp
          likp~zout
          mara~zzcolor_base
          mara~zzcolor_stripe
          mara~zziden_code
          mara~zzspec_no
          mara~zzmaktx80
          mara~zzral_code
          mara~zzspec_detail
          lips~fkrel
          vbak~auart
          vbkd~bstkd
          vbak~taxk1
          lips~ladgr
          lips~bwart
          vbkd~fbuda
          vbak~zpjno
          vbak~knkli
          vbak~vkbur
          vbak~vkgrp
          vbak~bstnk
          vbap~netwr AS netwr_p
          vbap~mwsbp
          kna1~name1
          t001w~j_1bbranch
          tvkbt~bezei
          lips~pstyv
          likp~inco1 " CHM2510-00065
    APPENDING  CORRESPONDING FIELDS OF TABLE g_itab_t
    FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                     JOIN vbap ON vbap~vbeln = lips~vgbel
                              AND vbap~posnr = lips~vgpos
                     JOIN vbak ON vbak~vbeln = lips~vgbel
                     JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                              AND vbkd~posnr = '0'
                     JOIN mara ON mara~matnr = lips~matnr
                     JOIN makt ON makt~matnr = lips~matnr
                              AND makt~spras = sy-langu
                     LEFT OUTER JOIN kna1 ON kna1~kunnr = likp~kunag
                     LEFT OUTER JOIN t001w ON t001w~werks = likp~werks
                     LEFT OUTER JOIN tvkbt ON tvkbt~vkbur = vbak~vkbur
                                          AND tvkbt~spras = sy-langu
   WHERE  likp~kunag IN so_kunnr
     AND  likp~vkorg EQ pa_vkorg
     AND  lips~vtweg EQ pa_vtweg
     AND  lips~spart EQ pa_spart
     AND  vbak~vkbur IN so_vkbur
     AND  vbak~vkgrp IN so_vkgrp
     AND  likp~wadat_ist IN lr_wadt
     AND  likp~wbstk EQ pa_wbstk
     AND  lips~fksta NE 'C'
     AND  lips~bwart = '687'
     AND  lips~podrel IN ('A', 'B')
     AND  lips~kzpod  IN ('A', 'B', 'X')
*     AND  VBKD~KDKG4 IN ('4D')
     AND  vbkd~kdkg4 EQ p_local
     AND  lips~fkrel IN ('K', 'A', 'H')
     AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT')
     AND  vbak~auart IN so_auart.
**********************************************************************
  LOOP AT g_itab_t WHERE bwart NE '687'.

    SELECT COUNT(*)
      INTO ll_check_cnt_itab
      FROM vbkd
     WHERE vbeln = g_itab_t-vgbel
       AND posnr = g_itab_t-vgpos.


    IF ll_check_cnt_itab > 0.
      DELETE g_itab_t.
    ENDIF.

    CLEAR : ll_check_cnt_itab.

  ENDLOOP.

  SELECT  vbap~vbeln AS vgbel
          vbap~posnr AS vgpos
          vbap~kwmeng
          vbap~vrkme AS vrkme_va
          lips~vrkme
          lips~vbeln
          lips~posnr
          lips~matnr
          vbap~arktx AS maktx
          lips~charg
          lips~lfimg
          lips~kcmeng
          vbap~netpr
          vbap~waerk
          vbap~taxm1
          vbkd~kdkg4
*          VKDFS~FAKSK
          lips~fksta
          likp~kunag
          likp~wadat_ist
          vbap~kpein
          lips~werks
          vbkd~zterm
          vbak~vbtyp
          likp~zout
          mara~zzcolor_base
          mara~zzcolor_stripe
          mara~zziden_code
          mara~zzspec_no
          mara~zzmaktx80
          mara~zzral_code
          mara~zzspec_detail
          lips~fkrel
          vbak~auart
          vbkd~bstkd
          vbak~taxk1
          vbkd~fbuda
          lips~ladgr
          lips~bwart
          vbak~knkli
          vbak~vkbur
          vbak~vkgrp
          vbak~bstnk
          vbak~zpjno
          vbap~netwr AS netwr_p
          vbap~mwsbp
          kna1~name1
          t001w~j_1bbranch
          tvkbt~bezei
          lips~pstyv
          likp~inco1 " CHM2510-00065
    APPENDING  CORRESPONDING FIELDS OF TABLE g_itab_t
    FROM  lips INNER JOIN likp ON likp~vbeln = lips~vbeln
                     JOIN vbap ON vbap~vbeln = lips~vgbel
                              AND vbap~posnr = lips~vgpos
                     JOIN vbak ON vbak~vbeln = lips~vgbel
                     JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                              AND vbkd~posnr = vbap~posnr
                     JOIN vkdfs ON vkdfs~vbeln = lips~vbeln
                     JOIN mara ON mara~matnr = lips~matnr
                     JOIN makt ON makt~matnr = lips~matnr
                              AND makt~spras = sy-langu
                     LEFT OUTER JOIN kna1  ON kna1~kunnr = likp~kunag
                     LEFT OUTER JOIN t001w ON t001w~werks = likp~werks
                     LEFT OUTER JOIN tvkbt ON tvkbt~vkbur = vbak~vkbur
                                          AND tvkbt~spras = sy-langu
   WHERE  likp~kunag IN so_kunnr
     AND  likp~vkorg EQ pa_vkorg
     AND  lips~vtweg EQ pa_vtweg
     AND  lips~spart EQ pa_spart
     AND  vbak~vkbur IN so_vkbur
     AND  vbak~vkgrp IN so_vkgrp
     AND  likp~wadat_ist IN so_wadat
     AND  likp~wbstk EQ pa_wbstk
     AND  lips~fksta NE 'C'
     AND  lips~bwart NE '687'
     AND  vbkd~kdkg4 EQ p_local
     AND  vkdfs~fktyp IN so_fktyp
     AND  lips~fkrel IN ('K', 'A', 'H')
     AND  vbak~auart NOT IN ('KB', 'KA', 'ZCS', 'VSH1', 'LA',
                             'CQ', 'WK1', 'ZCKB', 'ZITD', 'IN',
                             'ZIPD', 'ZBC1', 'ZBC3', 'QT')
     AND  vbak~auart IN so_auart.

*스크랩 출하관련 통문발행 전 세금계산서 발행
  LOOP AT g_itab_t WHERE zout IS INITIAL.
    SELECT SINGLE matnr
      INTO g_itab_t-matnr
      FROM zsdt0420
     WHERE bukrs = pa_vkorg
       AND matnr = g_itab_t-matnr
       AND lvorm = ' '.

    IF sy-subrc = 0.
      g_itab_t-zout = 'X'.

      MODIFY g_itab_t.
    ENDIF.
  ENDLOOP.

** CR/DR관련 Data Query.
  PERFORM  crdr_data_query.

  DESCRIBE TABLE g_itab_t LINES g_totcnt.

  IF  g_totcnt  >  0.

    PERFORM  data_gethering.

    PERFORM  data_sub_query.

    SORT g_itab_t BY vgbel vgpos.

    DESCRIBE TABLE g_itab_t LINES g_totcnt.

    IF  g_totcnt  >  0.
    ELSE.
      MESSAGE s001 WITH 'Data Not Found..!!'.
      EXIT.
    ENDIF.

  ELSE.
    MESSAGE s001 WITH 'Data Not Found..!!'.
    EXIT.
  ENDIF.

ENDFORM.                    " query_data

*&---------------------------------------------------------------------*
*&      Form  data_gethering
*&---------------------------------------------------------------------*
FORM data_gethering .

  IF  pa_fksta  =  'A'.

    LOOP AT g_itab_t.

      IF  g_itab_t-fksta  <>  'A'.
        DELETE  g_itab_t.
      ENDIF.

    ENDLOOP.

  ELSEIF  pa_fksta  =  'B'.

    LOOP AT g_itab_t.

      IF  g_itab_t-fksta  <>  'B'.
        DELETE  g_itab_t.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " data_gethering

*&---------------------------------------------------------------------*
*&      Form  data_sub_query
*&---------------------------------------------------------------------*
FORM data_sub_query.

  RANGES : lr_zpjno FOR zsdt_d365_021-zpjno.
  DATA : ls_result TYPE mb5sit,
         lt_styl   TYPE lvc_t_styl,
         lt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE,
         lt_join   LIKE TABLE OF g_itab_t WITH EMPTY KEY,
         lt_vbfa   LIKE vbfa OCCURS 0 WITH HEADER LINE.

  DATA : l_shkzg     LIKE vbrp-shkzg,
         l_vf_fkimg  LIKE vbrp-fkimg,
         l_sum_fkimg LIKE vbrp-fkimg,
         l_rfmng     LIKE vbfa-rfmng,
         l_rfmng2    LIKE vbfa-rfmng,
         l_plmin     LIKE vbfa-plmin,
         l_netwr     LIKE vbap-netwr,
         l_tax       LIKE vbap-mwsbp, "TYPE P DECIMALS 2,
         l_knkli     LIKE vbak-knkli,
         l_input     TYPE f,
         l_output    TYPE f,
         lv_mon      TYPE p DECIMALS 3,
         lv_sdt      TYPE sy-datlo,
         lv_first    TYPE c,
         lv_edit     TYPE c,
         lv_chk      TYPE c.

  DATA : lv_zpjno TYPE vbak-zpjno.

  CLEAR : l_shkzg, l_vf_fkimg, l_sum_fkimg,
          l_rfmng, l_rfmng2, l_plmin, l_netwr,
          l_tax, l_knkli, l_input, l_output.

  DATA(lt_for) = g_itab_t[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT a~vbeln, a~kunnr, parvw, b~name1
      FROM vbpa AS a INNER JOIN kna1 AS b
        ON b~kunnr = a~kunnr
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vbeln = @lt_for-vbeln
       AND a~posnr = '0'
       AND a~parvw  IN ('WE')
      INTO TABLE @DATA(lt_kna1).
  ENDIF.

*납품처/ 청구처
  lt_for[] = g_itab_t[].
  SORT lt_for BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vgbel.
  IF lt_for[] IS NOT INITIAL.
    SELECT a~vbeln, a~kunnr, parvw, b~name1
      FROM vbpa AS a INNER JOIN kna1 AS b
        ON b~kunnr = a~kunnr
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vbeln = @lt_for-vgbel
       AND a~posnr = '0'
       AND a~parvw  IN ('RG')
      APPENDING TABLE @lt_kna1.
  ENDIF.

*{ CHM2510-00065 - S
* 담당영업사원
  IF lt_for[] IS NOT INITIAL.
    SELECT a~vbeln, a~lifnr
      FROM vbpa AS a
       FOR ALL ENTRIES IN @lt_for
     WHERE a~vbeln = @lt_for-vgbel
       AND a~parvw  IN ('PE' , 'VE')
      INTO TABLE @DATA(lt_kna2).
  ENDIF.
*} CHM2510-00065 - E


*대금청구수량
  lt_join[] = g_itab_t[].
  SORT lt_join BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln posnr.
  IF lt_join[] IS NOT INITIAL.
    SELECT b~vgbel, b~vgpos,
           SUM( CASE WHEN shkzg = 'X' THEN b~fkimg * -1
                ELSE b~fkimg
                 END ) AS fkimg
      FROM @lt_join AS a INNER JOIN vbrp AS b
        ON b~vgbel = a~vbeln
       AND b~vgpos = a~posnr
       AND b~draft = @space
     INNER JOIN vbrk AS c
        ON b~vbeln = c~vbeln
     WHERE fksto EQ @space
       AND sfakn EQ @space
      GROUP BY b~vgbel, b~vgpos
      INTO TABLE @DATA(lt_vf_qty).
  ENDIF.

  lt_join[] = g_itab_t[].
  DELETE lt_join WHERE charg IS NOT INITIAL
                   AND lfimg > 0.
  SORT lt_join BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln posnr.
  IF lt_join[] IS NOT INITIAL.
    SELECT b~vbeln, b~uecha, SUM( b~lfimg ) AS lfimg
      FROM @lt_join AS a INNER JOIN lips AS b
        ON a~vbeln = b~vbeln
       AND a~posnr = b~uecha
     GROUP BY b~vbeln, b~uecha
    INTO TABLE @DATA(lt_vl_qty).

    SELECT b~vbeln, b~posnr, b~charg,
           CASE WHEN b~uecha IS INITIAL THEN b~posnr ELSE uecha END AS uecha
      FROM @lt_join AS a INNER JOIN lips AS b
        ON a~vbeln = b~vbeln
       AND a~posnr = b~uecha
    INTO TABLE @DATA(lt_charg).
  ENDIF.


  lt_for[] = g_itab_t[].
  DELETE lt_for WHERE zpjno IS INITIAL.
  SORT lt_for BY zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING zpjno.
  IF lt_for[] IS NOT INITIAL.

    LOOP AT lt_for INTO DATA(ls_tmp).
      IF ls_tmp-zpjno(2) = |PD|.
        lv_zpjno = ls_tmp-zpjno.
      ELSE.
        lv_zpjno = ls_tmp-zpjno(8) && |*|.
      ENDIF.
      __rng lr_zpjno 'I' 'CP' lv_zpjno ''.
    ENDLOOP.

    SELECT zpjno, zptxt INTO TABLE @DATA(lt_zpjt)
      FROM zsd0106t
     WHERE zpjno IN @lr_zpjno.
  ENDIF.

*적송처리를 한 주문에 한해서 원주문문서를 보여준다.
  lt_join[] = g_itab_t[].
  DELETE lt_join WHERE vgbel(2) NE '57'.

  SORT lt_join BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vgbel vgpos.
  IF lt_join[] IS NOT INITIAL.
*원주문
    SELECT vbelv, posnv, vgbel, vgpos
      FROM @lt_join AS a INNER JOIN vbfa AS b
        ON a~vgbel = b~vbeln
       AND a~vgpos = b~posnn
     WHERE vbtyp_n  =  'C'
       AND vbtyp_v  =  'C'
      INTO TABLE @DATA(lt_o_va).

*원판매오더 출고일
    SELECT l~wadat_ist, vgbel, vgpos
      FROM @lt_join AS a INNER JOIN vbfa AS b
        ON a~vgbel = b~vbeln
       AND a~vgpos = b~posnn
     INNER JOIN likp AS l
        ON l~vbeln = b~vbelv
     WHERE lfart   <>  'LF3'
       AND vbtyp_v  =  'J'
      INTO TABLE @DATA(lt_o_wadt).
  ENDIF.

*POD 빌링 로그
  lt_join[] = g_itab_t[].
  SORT lt_join BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln.
  IF lt_join[] IS NOT INITIAL.
    WITH +vf AS ( SELECT DISTINCT a~vbeln
                    FROM vbrp AS a INNER JOIN vbrk AS b
                      ON a~vbeln = b~vbeln
                   WHERE fksto NE @space
                      OR sfakn NE @space )
    SELECT b~*, CASE WHEN c~vbeln IS NOT INITIAL    THEN @zgtsd_x
                     WHEN c~vbeln IS INITIAL AND
                          b~vbeln_vf IS NOT INITIAL THEN @zgtsd_x
                     WHEN b~vbeln_vf IS INITIAL     THEN @zgtsd_x
                END AS vbeln_vf
      FROM @lt_join AS a INNER JOIN zgtsdt1010 AS b
        ON a~vbeln = b~vbeln
      LEFT OUTER JOIN +vf AS c
        ON c~vbeln = b~vbeln_vf
*        ON B~VBELN = C~VGBEL
*       AND B~POSNR = C~VGPOS
     WHERE b~loekz = @space
      INTO CORRESPONDING FIELDS OF TABLE @gt_log.
  ENDIF.

*이전오더
  lt_join[] = g_itab_t[].
  SORT lt_join BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vgbel vgpos.
  IF lt_join[] IS NOT INITIAL.
    WITH +lips AS ( SELECT DISTINCT b~vbeln, posnr, vgbel, vgpos, wadat_ist
                      FROM lips AS a INNER JOIN likp AS b
                        ON a~vbeln = b~vbeln
                     WHERE a~uecha IS INITIAL )
    SELECT b~vbeln_n, b~posnr_n, b~vbeln_o, b~posnr_o,
           c~vbeln AS vbevl_o, c~posnr AS posvl_o, b~msg,
           c~wadat_ist AS wadat_ist_o
      FROM @lt_join AS a INNER JOIN zgtsdt9062 AS b
        ON a~vgbel = b~vbeln_n
       AND a~vgpos = b~posnr_n
      LEFT OUTER JOIN +lips AS c
        ON b~vbeln_o = c~vgbel
       AND b~posnr_o = c~vgpos
      INTO TABLE @DATA(lt_ori).
  ENDIF.

  DATA(lt_for2) = lt_ori[].
*  SORT LT_FOR2 BY VBEVL_O.
*  DELETE ADJACENT DUPLICATES FROM LT_FOR2 COMPARING VBEVL_O.
  IF lt_for2[] IS NOT INITIAL.
    WITH +lips AS ( SELECT vbeln, posnr
                      FROM @lt_for2 AS a INNER JOIN lips AS b
                        ON a~vbevl_o = b~vbeln
                       AND a~posvl_o = b~posnr
                     WHERE b~lfimg > 0 )
    SELECT c~vbeln AS vbelv, c~posnr AS posnv, a~vbeln, b~budat_mkpf
      FROM +lips AS c INNER JOIN vbfa AS a
        ON c~vbeln = a~vbelv
       AND c~posnr = a~posnv
      INNER JOIN mseg AS b
        ON a~vbeln = b~mblnr
     WHERE a~bwart = '601'
     INTO TABLE @DATA(lt_budat_o).
    SORT lt_budat_o BY vbelv posnv vbeln.
*    DELETE ADJACENT DUPLICATES FROM LT_BUDAT_O COMPARING VBELV POSNV.
  ENDIF.

  lt_join[] = g_itab_t[].
  SORT lt_join BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_join COMPARING vbeln.
  IF lt_join[] IS NOT INITIAL.
    SELECT vbelv, posnv, vbeln, b~budat_mkpf INTO TABLE @DATA(lt_budat)
      FROM vbfa AS a INNER JOIN mseg AS b
        ON a~vbeln = b~mblnr
       FOR ALL ENTRIES IN @lt_join
     WHERE vbelv   = @lt_join-vbeln
       AND a~bwart = '687'.
    SORT lt_budat BY vbelv posnv vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_budat COMPARING vbelv posnv.
  ENDIF.

  SORT lt_kna1   BY vbeln parvw.
  SORT lt_kna2   BY vbeln.
  SORT lt_vf_qty BY vgbel vgpos.
  SORT lt_vl_qty BY vbeln uecha.
  SORT lt_charg  BY vbeln uecha.
  SORT lt_o_va   BY vgbel vgpos.
  SORT lt_o_wadt BY vgbel vgpos.
  SORT gt_log BY vbeln posnr.
  SORT lt_ori    BY vbeln_n posnr_n.
  SORT lt_budat  BY vbelv posnv.
  SORT lt_budat_o  BY vbelv posnv.

  SORT g_itab_t BY vbeln posnr.

  LOOP AT g_itab_t.

*프로젝트
    READ TABLE lt_zpjt INTO DATA(ls_zpjt) WITH KEY zpjno = g_itab_t-zpjno.
    IF sy-subrc = 0.
      g_itab_t-zptxt = ls_zpjt-zptxt.
    ELSE.
      READ TABLE lt_zpjt INTO ls_zpjt WITH KEY zpjno(8) = g_itab_t-zpjno.
      IF sy-subrc = 0.
        g_itab_t-zptxt = ls_zpjt-zptxt.
      ENDIF.
    ENDIF.
    CLEAR ls_zpjt.

** 납품처
    READ TABLE lt_kna1 INTO DATA(ls_kna)
                       WITH KEY vbeln = g_itab_t-vbeln
                                parvw = 'WE' BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-kunnr_we = ls_kna-kunnr.
      g_itab_t-name2    = ls_kna-name1.
    ENDIF.

** 청구처
    CLEAR ls_kna.
    READ TABLE lt_kna1 INTO ls_kna
                       WITH KEY vbeln = g_itab_t-vgbel
                                parvw = 'RG' BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-kunnr_rg = ls_kna-kunnr.
      g_itab_t-name3    = ls_kna-name1.
    ENDIF.
*{ CHM2510-00065 - S
** 영업사원
    READ TABLE lt_kna2 INTO DATA(ls_kna2)
                       WITH KEY vbeln =  g_itab_t-vgbel
                                  BINARY SEARCH.
    IF sy-subrc = 0.
      g_itab_t-lifnr = lS_kna2-lifnr.
    ENDIF.
*} CHM2510-00065 - E


    IF  g_itab_t-charg = space  AND g_itab_t-lfimg = 0.
      READ TABLE lt_vl_qty INTO DATA(ls_vl)
                           WITH KEY vbeln = g_itab_t-vbeln
                                    uecha = g_itab_t-posnr
                                    BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-lfimg = ls_vl-lfimg.
      ENDIF.
      LOOP AT lt_charg INTO DATA(ls_charg) WHERE vbeln = g_itab_t-vbeln
                                            AND uecha = g_itab_t-posnr.
        READ TABLE gt_log INTO DATA(ls_log) WITH KEY vbeln = g_itab_t-vbeln
                                                     posnr = g_itab_t-posnr
                                                     charg = ls_charg-charg.
        IF sy-subrc NE 0.
          g_itab_t-posnn = ls_charg-posnr.
          g_itab_t-charg = ls_charg-charg.
        ENDIF.
      ENDLOOP.
      IF g_itab_t-charg IS INITIAL.
        READ TABLE lt_charg  INTO ls_charg
                             WITH KEY vbeln = g_itab_t-vbeln
                                      uecha = g_itab_t-posnr.
        IF sy-subrc = 0.
          g_itab_t-posnn = ls_charg-posnr.
          g_itab_t-charg = ls_charg-charg.
        ENDIF.
      ENDIF.
*      READ TABLE LT_CHARG  INTO DATA(LS_CHARG)
*                           WITH KEY VBELN = G_ITAB_T-VBELN
*                                    UECHA = G_ITAB_T-POSNR
*                                    BINARY SEARCH.
*      IF SY-SUBRC = 0.
*        G_ITAB_T-POSNN = LS_CHARG-POSNR.
*        G_ITAB_T-CHARG = LS_CHARG-CHARG.
*      ENDIF.
    ELSE.
      g_itab_t-posnn = g_itab_t-posnr.
    ENDIF.
    CLEAR : ls_kna, ls_vl.

    IF  g_itab_t-kdkg4 = '4L'.
      g_itab_t-ztax  =  0.
    ELSEIF g_itab_t-taxm1  =  '1'.
      g_itab_t-ztax  =  10.
    ELSE.
      g_itab_t-ztax  =  0.
    ENDIF.

**********************************************************************
*POD
**********************************************************************
    IF g_itab_t-bwart = '687'.

      CLEAR lv_edit.
      IF g_itab_t-pstyv NE |ZBIS|.
        g_itab_t-pod_stat = icon_led_red. "
        PERFORM append_msg TABLES g_itab_t-msgpop
                            USING 'E'
                                  TEXT-e06 .
        lv_edit = zgtsd_x.
      ENDIF.

      SELECT SINGLE b~budat_mkpf INTO g_itab_t-wadat_ist2
        FROM vbfa AS a INNER JOIN mseg AS b
          ON a~vbeln = b~mblnr
       WHERE vbelv = g_itab_t-vbeln
         AND a~bwart = '687'.
      CLEAR : g_itab_t-fkimg, g_itab_t-pod_qty.
      READ TABLE lt_charg INTO ls_charg WITH KEY vbeln = g_itab_t-vbeln
                                                 uecha = g_itab_t-posnr.
      IF sy-subrc = 0.
        LOOP AT lt_charg INTO ls_charg WHERE vbeln = g_itab_t-vbeln
                                         AND uecha = g_itab_t-posnr.
          CLEAR ls_result.
          PERFORM call_mb5sit_gi USING ls_charg-vbeln ls_charg-posnr
                              CHANGING ls_result lv_first.

          g_itab_t-pod_qty += ls_result-sit_gi.
          IF ls_result-sit_free > 0.
            g_itab_t-fkimg   += ls_result-sit_free.
          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR ls_result.
        PERFORM call_mb5sit_gi USING g_itab_t-vbeln g_itab_t-posnn
                            CHANGING ls_result lv_first.
        g_itab_t-pod_qty = ls_result-sit_gi.
        IF ls_result-sit_free > 0.
          g_itab_t-fkimg   = ls_result-sit_free.
        ENDIF.
      ENDIF.

      IF g_itab_t-fkimg < 0.
        lv_edit = zgtsd_x.
        g_itab_t-pod_stat = icon_led_red. "
        PERFORM append_msg TABLES g_itab_t-msgpop
                            USING 'E'
                                  TEXT-e05 .
      ELSEIF g_itab_t-fkimg > 0.

        READ TABLE lt_vf_qty INTO DATA(ls_qty)
                             WITH KEY vgbel = g_itab_t-vbeln
                                      vgpos = g_itab_t-posnr
                                      BINARY SEARCH.
        IF sy-subrc = 0.

          IF g_itab_t-fkimg = g_itab_t-lfimg AND g_itab_t-fkimg = ls_qty-fkimg.
            DELETE g_itab_t. CONTINUE.
          ELSE.
            IF g_itab_t-fkimg NE ls_qty-fkimg. "실제 빌링 수량과 MB5SIT 수량을 비교
              lv_edit = zgtsd_x.
              g_itab_t-fkimg    = ls_qty-fkimg.
              g_itab_t-pod_stat = icon_led_red. "
              PERFORM append_msg TABLES g_itab_t-msgpop
                                  USING 'E'
                                        TEXT-e03 .
            ELSE.
              g_itab_t-pod_stat = icon_led_yellow. " POD 납품 진행중 데이터
            ENDIF.

          ENDIF.

        ELSE.

          lv_edit = zgtsd_x.
          g_itab_t-pod_stat = icon_led_red. "
          PERFORM append_msg TABLES g_itab_t-msgpop
                              USING 'E'
                                    TEXT-e05 .
        ENDIF.

      ELSE.

        CLEAR ls_qty.
        g_itab_t-pod_stat = icon_led_inactive. "

      ENDIF.

*      POD_STAT
      CLEAR ls_log.
      READ TABLE gt_log INTO ls_log WITH KEY vbeln = g_itab_t-vbeln
                                             posnr = g_itab_t-posnr
                                             charg = g_itab_t-charg
                                             BINARY SEARCH.
      IF sy-subrc = 0 AND ls_log-vbeln_vf IS NOT INITIAL.
        g_itab_t-pod_stat = icon_led_red. "602 문서 안만들어짐.
        PERFORM append_msg TABLES g_itab_t-msgpop USING 'E' TEXT-e02 .
      ENDIF.

      READ TABLE g_itab_t-msgpop INTO DATA(ls_pop) WITH KEY msgty = 'E'.
      IF sy-subrc = 0.
        g_itab_t-pod_stat = icon_led_red.
*        IF LV_EDIT IS NOT INITIAL.  "마감수량 EDIT
*          PERFORM SET_ALV_FLD_STYLE USING LT_STYL 'X' : 'CHK', 'REMN_QTY'.
*          INSERT LINES OF LT_STYL INTO TABLE G_ITAB_T-CELLS.
*        ENDIF.
      ENDIF.

*1)최초납품문서 2)항목번호 3)최초출고일  필드추가
      READ TABLE lt_ori INTO DATA(ls_ori) WITH KEY vbeln_n = g_itab_t-vgbel
                                                   posnr_n = g_itab_t-vgpos BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-vbeva        = ls_ori-msg.
        g_itab_t-vbevl_o      = ls_ori-vbevl_o.
        g_itab_t-posvl_o      = ls_ori-posvl_o.
        g_itab_t-wadat_ist2   = ls_ori-wadat_ist_o.

        READ TABLE lt_budat_o INTO DATA(ls_budat_o) WITH KEY vbelv = g_itab_t-vbevl_o
                                                             posnv = g_itab_t-posvl_o.
        IF sy-subrc = 0.
          g_itab_t-wadat_ist_o  = ls_budat_o-budat_mkpf.
*        ELSE.
*          G_ITAB_T-WADAT_IST_O  = G_ITAB_T-WADAT_IST.
          g_itab_t-wadat_ist_o  = ls_ori-wadat_ist_o.
        ENDIF.
      ELSE.

        g_itab_t-vbevl_o      = g_itab_t-vbeln.
        g_itab_t-posvl_o      = g_itab_t-posnr.
        READ TABLE lt_budat INTO DATA(ls_budat) WITH KEY vbelv = g_itab_t-vbeln
                                                         posnv = g_itab_t-posnn.
        IF sy-subrc = 0.
          g_itab_t-wadat_ist_o  = ls_budat-budat_mkpf.
*        ELSE.
*          G_ITAB_T-WADAT_IST_O  = G_ITAB_T-WADAT_IST.
        ENDIF.
      ENDIF.

      IF g_itab_t-pod_stat = icon_led_inactive.
        g_itab_t-wadat_ist = space.
      ENDIF.

*이월기간
      IF g_itab_t-wadat_ist_o > '19000101'.
        g_itab_t-mon = ( sy-datlo(4) - g_itab_t-wadat_ist_o(4) ) * 12 + ( sy-datlo+4(2) - g_itab_t-wadat_ist_o+4(2) ).
      ENDIF.

    ELSE.

** 대금청구수량
      READ TABLE lt_vf_qty INTO ls_qty
                           WITH KEY vgbel = g_itab_t-vbeln
                                    vgpos = g_itab_t-posnr
                                    BINARY SEARCH.
      IF sy-subrc = 0.
        g_itab_t-fkimg = ls_qty-fkimg.
      ELSE.
        g_itab_t-fkimg = 0.
      ENDIF.

    ENDIF.

    CLEAR : ls_log, ls_qty.
**********************************************************************

** 마감수량/잔량 : 납품수량 - 청구수량
    IF  g_itab_t-fkrel  =  'K'.

      IF g_itab_t-auart  = 'RE' OR g_itab_t-auart  = 'ZRET'
      OR g_itab_t-auart  = 'YSRE'.
        g_itab_t-remn_qty2  =  g_itab_t-lfimg  + g_itab_t-fkimg.
        g_itab_t-remn_qty   =  g_itab_t-lfimg  + g_itab_t-fkimg.

      ELSE.

        g_itab_t-remn_qty2  =  g_itab_t-lfimg  -  g_itab_t-fkimg.
        g_itab_t-remn_qty   =  g_itab_t-lfimg  -  g_itab_t-fkimg.

      ENDIF.

    ELSE.

      g_itab_t-remn_qty2  =  g_itab_t-lfimg.
      g_itab_t-remn_qty   =  g_itab_t-lfimg.

    ENDIF.

** New => 단가 : 단가 / 기준량
** Old => 단가 : 단가 / 10.
    IF  g_itab_t-waerk  =  'KRW'.
      g_itab_t-netpr2 =  g_itab_t-netpr  *  100.
      g_itab_t-netpr2 =  g_itab_t-netpr2  /  g_itab_t-kpein.
    ELSE.
      g_itab_t-netpr2 =  g_itab_t-netpr  /  g_itab_t-kpein.
    ENDIF.
    g_itab_t-netpr  =  g_itab_t-netpr  /  g_itab_t-kpein.

** 금액(Tax)을 계산하지 않고 Standard Function을 이용한다.
** 납품관련빌링일 경우에만 새로운 로직을 적용하고
** 오더관련빌링일 경우에는 기존로직을 사용한다.
** (오더관련 정가는 VKDFS에 직접 Query하는것으로 변경 : 2005-08-26)
    IF  g_itab_t-zgubun  =  'D'.

      IF  pa_chk2  =  'X'.
        g_itab_t-netwr  =  g_itab_t-remn_qty  *  g_itab_t-netpr.
      ELSE.

        IF  g_itab_t-auart  =  'RE' OR  g_itab_t-auart  =  'ZRET'
        OR  g_itab_t-auart  =  'YSRE'.

** 주문수량과 납품수량이 다를경우는 원래대로 Function을 이용
          IF  g_itab_t-kwmeng  =  g_itab_t-kcmeng.
            g_itab_t-netwr = g_itab_t-netwr_p.
            l_tax          = g_itab_t-mwsbp.
          ELSE.
            PERFORM  invoice_amount_calc  CHANGING l_tax.
          ENDIF.

        ELSE.
          PERFORM  invoice_amount_calc  CHANGING l_tax.
        ENDIF.

      ENDIF.

      l_netwr = g_itab_t-netwr.

      IF g_itab_t-remn_qty <> g_itab_t-kwmeng .
        PERFORM invoice_biusduct_amt_cals USING g_itab_t-vbeln
                                                g_itab_t-posnr
                                          CHANGING g_itab_t-netwr.
        CLEAR : lv_chk.
        PERFORM check_mch1 USING g_itab_t-vbeln
                                 g_itab_t-posnr
                        CHANGING  lv_chk.
        IF lv_chk = 'X'.
          g_itab_t-pod_stat = icon_led_red. "
          PERFORM append_msg TABLES g_itab_t-msgpop
                              USING 'E'
                                    '배치정보누락'.
        ENDIF.
      ENDIF.

    ELSE.

** New  => 청구액 : 마감수량 * 단가
** Old  => 청구액 : (마감수량 * 단가) / 기준량

      CASE g_itab_t-pstyv.
        WHEN  'TAD' OR 'ZDRN'  OR 'L2W' OR 'L2N' OR 'G2W' OR 'ZCRN' OR 'G2N'   .

        WHEN OTHERS.
          g_itab_t-netwr  =  g_itab_t-remn_qty  *  g_itab_t-netpr.
      ENDCASE.



** Tax : 청구액 * Tax Rate
      IF  g_itab_t-netwr = 0 OR g_itab_t-ztax = 0.
        g_itab_t-ztax2  =  0.
      ELSE.
        l_netwr  =  g_itab_t-netwr  *  100.
        l_tax  =  l_netwr * ( g_itab_t-ztax / 100 ).
      ENDIF.

    ENDIF.



    l_input  =  l_tax.
    IF  g_itab_t-waerk  =  'KRW'.
      l_input  =  l_input  *  100.
    ENDIF.

    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        i_rtype     = '-'   " ' ':반올림, '+':올림, '-':버림
        i_runit     = '1'
        i_value     = l_input
      IMPORTING
        e_value_rnd = l_output.

    g_itab_t-ztax2  =  l_output.

    IF  g_itab_t-vbtyp  =  'H'  OR
        g_itab_t-vbtyp  =  'K'.
      g_itab_t-netwr  =  g_itab_t-netwr  *  -1.
      g_itab_t-ztax2  =  g_itab_t-ztax2  *  -1.
    ENDIF.

***CHOI
    g_itab_t-z_sum = ( l_netwr / 10 ) + ( g_itab_t-ztax2 / 10 ).

    CONCATENATE  g_itab_t-knkli+4(6) '/'     " Payer
                 g_itab_t-vkbur      '/'     " 영업팀
                 g_itab_t-vkgrp      '/'     " 영업부서
                 g_itab_t-j_1bbranch '/'     " 세적지
                 g_itab_t-zterm      '/'      " 지급조건
                 g_itab_t-inco1      '/'     "인코텀즈 " CHM2510-00065
                 g_itab_t-lifnr      '/'     "영업사원  " CHM2510-00065
                 g_itab_t-taxk1              "세금분류 "CHM2512-00025
           INTO  g_itab_t-ztext.

    IF  pa_fkdat  <>  '00000000'.
      g_itab_t-fkdat  =  pa_fkdat.
    ENDIF.
    gl_flag = 'Y'.
** Request by 윤방희위원 2005-01-26
** CR/DR에 대한 금액 및 Tax처리
    IF  g_itab_t-vgbel  =  g_itab_t-vbeln.
      PERFORM  crdr_sub_query.
    ENDIF.

    IF gl_flag = 'Y'.
      CLEAR l_netwr.

      g_sum_t-waerk  =  g_itab_t-waerk.
      l_netwr  =  g_itab_t-netwr  *  100.
      g_sum_t-s_netwr  =  l_netwr + g_itab_t-ztax2.
      g_sum_t-netwr  =  l_netwr.
      g_sum_t-ztax2  =  g_itab_t-ztax2.

      COLLECT  g_sum_t.

      g_itab_t-prsdt  =  g_itab_t-wadat_ist.

** 세금계산서단가(금액/마감수량) 필드 추가
      IF  g_itab_t-netwr  =  0  OR
          g_itab_t-remn_qty  =  0.
        g_itab_t-znetpr  =  0.
      ELSE.
        g_itab_t-znetpr  =  g_itab_t-netwr  /  g_itab_t-remn_qty.
      ENDIF.

      IF  g_itab_t-waerk  =  'KRW'.
        g_itab_t-znetpr  =  g_itab_t-znetpr  *  100.
      ENDIF.

** 적송처리를 한 주문에 한해서 원주문문서를 보여준다.
** 적송처리를 하게되면 Number Range : '571~'.
      IF  g_itab_t-vgbel+0(2)  =  '57'.

*원주문품목
        READ TABLE lt_o_va INTO DATA(ls_va)
                           WITH KEY vgbel = g_itab_t-vgbel
                                    vgpos = g_itab_t-vgpos
                                    BINARY SEARCH.
        IF sy-subrc = 0.
          g_itab_t-o_vbeln = ls_va-vbelv.
          g_itab_t-o_posnr = ls_va-posnv.
        ENDIF.

*       원판매오더 출고일
        READ TABLE lt_o_wadt INTO DATA(ls_dt)
                           WITH KEY vgbel = g_itab_t-vgbel
                                    vgpos = g_itab_t-vgpos
                                    BINARY SEARCH.
        IF sy-subrc = 0.
          g_itab_t-wadat_ist2 = ls_dt-wadat_ist.
        ENDIF.

      ENDIF.

*환율
      SELECT SINGLE kursf
                    fidno
                    fidnp
        INTO ( g_itab_t-kursf, g_itab_t-fidno, g_itab_t-fidnp )
        FROM ztetfdp
        WHERE vbeln = g_itab_t-vbeln
          AND posnr = g_itab_t-posnr
          AND matnr = g_itab_t-matnr.
      IF sy-subrc = 0.
        IF g_itab_t-waerk = 'KRW'.
          g_itab_t-netwr_k = g_itab_t-netwr * g_itab_t-kursf.
          g_itab_t-waerk_k = 'KRW'.
        ELSE.
          g_itab_t-netwr_k = ( g_itab_t-netwr * g_itab_t-kursf ) / 100.
          g_itab_t-waerk_k = 'KRW'.
        ENDIF.

      ENDIF.

      MODIFY  g_itab_t.
      CLEAR : g_itab_t, ls_dt, ls_va.
    ELSE.
      DELETE g_itab_t.
    ENDIF.

    CLEAR : l_vf_fkimg,
            l_rfmng, l_rfmng2, l_plmin, l_netwr,
            l_tax, l_input, l_output.

  ENDLOOP.

  CLEAR : g_netwr.
** Header에 대금청구금액을 보여주기위함.
  READ TABLE g_sum_t INDEX 1.
  g_netwr  =  g_sum_t-s_netwr.                              "  *  10.
  g_p_netwr  =  g_netwr.
  WRITE  g_p_netwr  TO  g_c_netwr RIGHT-JUSTIFIED.

** Request by 최석원D : 2005-04-07
** 선택된 Record의 청구금액을 Header에 Display.
** 최석원D의 요청으로 금액과 부가세를 구분한다 : 2005-07-29
  CLEAR : g_netwr2, g_p_ztax2.
  IF  sy-ucomm  =  'REFS'.
    LOOP AT g_tmp3_t.
      READ TABLE g_itab_t WITH KEY vbeln = g_tmp3_t-vbeln
                                   posnr = g_tmp3_t-posnr.
      g_netwr2  =  g_netwr2 + g_itab_t-netwr.
      g_p_ztax2  =  g_p_ztax2  +  g_itab_t-ztax2.
    ENDLOOP.
  ELSE.
    LOOP AT g_itab_t WHERE chk = 'X'.
      g_netwr2  =  g_netwr2 + g_itab_t-netwr.
      g_p_ztax2  =  g_p_ztax2  +  g_itab_t-ztax2.
    ENDLOOP.
  ENDIF.
  g_netwr2  =  g_netwr2.                                    "  *  10.
  g_p_netwr2  =  g_netwr2.
  g_p_netwr_tot = g_p_netwr2 + g_p_ztax2.

  WRITE  g_p_netwr_tot  TO  g_c_netwr_tot RIGHT-JUSTIFIED.

  WRITE  g_p_netwr2  TO  g_c_netwr2 RIGHT-JUSTIFIED.

  WRITE  g_p_ztax2  TO  g_c_ztax2 RIGHT-JUSTIFIED.

** BDC후 다시 Query할때 BDC수행 메세지 관리를 위함.
  LOOP AT g_itab_t.

    READ TABLE g_bdc_t WITH KEY vbeln = g_itab_t-vbeln
                                posnr = g_itab_t-posnr.

    IF  sy-subrc  =  0.
      g_itab_t-mesg  =  g_bdc_t-mesg.
      MODIFY  g_itab_t.
      CLEAR  g_itab_t.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " data_sub_query
*&---------------------------------------------------------------------*
*&      Form  ALVPRN_HEADER2
*&---------------------------------------------------------------------*
*       ALV HEADER SETTING
*----------------------------------------------------------------------*
FORM alvprn_header2 USING pv_type.

  DATA : l_rfmng  LIKE vbfa-rfmng,
         l_rfmng2 LIKE vbfa-rfmng,
         l_plmin  LIKE vbfa-plmin,
         l_netwr  LIKE vbap-netwr,
         l_total  LIKE vbap-netwr,
         l_tax    TYPE p DECIMALS 2,
         l_knkli  LIKE vbak-knkli,
         l_input  TYPE f,
         l_output TYPE f.
  CLEAR : l_rfmng, l_rfmng2, l_plmin, l_netwr,
          l_tax, l_knkli, l_input, l_output.
  CLEAR : g_sum_t, g_sum_t[].

  IF pv_type IS NOT INITIAL.
    "Selected Rows
    CLEAR g_subrc.
    DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                          io_grid = go_grid
                                                          iv_ck   = zgtsd_x
                                                        IMPORTING
                                                          ev_subrc = g_subrc ).
    CHECK g_subrc IS INITIAL.

    CLEAR g_itab_t.
    MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.

  LOOP AT g_itab_t.

    IF  g_itab_t-vbtyp  =  'H'  OR
        g_itab_t-vbtyp  =  'K'.

      IF  g_itab_t-netwr  >  0.
        g_itab_t-netwr  =  g_itab_t-netwr  *  -1.
      ENDIF.

      IF  g_itab_t-ztax2  >  0.
        g_itab_t-ztax2  =  g_itab_t-ztax2  *  -1.
      ENDIF.

    ENDIF.

    IF p_local = '4L'.
      g_sum_t-waerk  =  g_itab_t-waerk.
      l_total = ( g_itab_t-netwr + g_itab_t-ztax2 ) * g_itab_t-kursf.
      g_sum_t-s_netwr  =  l_total.
    ELSE.
      g_sum_t-waerk  =  g_itab_t-waerk.
      l_netwr  =  g_itab_t-netwr  *  100.
      g_sum_t-s_netwr  =  l_netwr + g_itab_t-ztax2.
    ENDIF.

    COLLECT  g_sum_t.

    MODIFY  g_itab_t  TRANSPORTING netwr ztax2 z_netwr z_mwsbp.
    CLEAR : g_itab_t, l_netwr, l_total.

  ENDLOOP.

  CLEAR : g_netwr.
** Header에 대금청구금액을 보여주기위함.
  READ TABLE g_sum_t INDEX 1.
  g_netwr  =  g_sum_t-s_netwr.                              "  *  10.
  g_p_netwr  =  g_netwr.
  WRITE  g_p_netwr  TO  g_c_netwr RIGHT-JUSTIFIED.

** Request by 최석원D : 2005-04-07
** 선택된 Record의 청구금액을 Header에 Display.
  CLEAR : g_netwr2, g_p_ztax2, l_tax.
  LOOP AT g_itab_t WHERE chk = 'X'.
    IF p_local = '4L'.
      " 총합 계산
      l_total = ( g_itab_t-netwr  + g_itab_t-ztax2 ) * g_itab_t-kursf.

      " 세율 활용해 분리
      l_netwr = l_total / ( 1 + g_itab_t-ztax / 100 ).
      l_tax   = l_total - l_netwr.

      g_netwr2  = g_netwr2  + l_netwr.
      g_p_ztax2 = g_p_ztax2 + l_tax.
    ELSE.
      g_netwr2  =  g_netwr2 + ( g_itab_t-netwr * 100 ).
      g_p_ztax2  =  g_p_ztax2  +  g_itab_t-ztax2.
    ENDIF.
    CLEAR: l_total, l_netwr, l_tax.
  ENDLOOP.
  g_netwr2  =  g_netwr2.                                    "  *  10.
  g_p_netwr2  =  g_netwr2.
  g_p_netwr_tot = g_p_netwr2 + g_p_ztax2.

  WRITE  g_p_netwr_tot  TO  g_c_netwr_tot RIGHT-JUSTIFIED.

  WRITE  g_p_netwr2  TO  g_c_netwr2 RIGHT-JUSTIFIED.

  WRITE  g_p_ztax2  TO  g_c_ztax2 RIGHT-JUSTIFIED.

  PERFORM header_setting_new.

  IF pv_type IS NOT INITIAL.
    CLEAR g_itab_t.
    MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
  ENDIF.

ENDFORM.                    " ALVPRN_HEADER2
*&---------------------------------------------------------------------*
*&      Form  mark_changed
*&---------------------------------------------------------------------*
FORM mark_changed  USING rr_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         rs_mod_cells TYPE lvc_s_modi.

  DATA : l_netwr  LIKE vbap-netwr,
         l_tax    TYPE p DECIMALS 2,
         l_input  TYPE f,
         l_output TYPE f.
  CLEAR : l_netwr, l_tax, l_input, l_output.

  CHECK pa_chk2 NE 'X'.  " add 2005-07-30

  READ TABLE g_itab_t INDEX rs_mod_cells-row_id.

  CHECK g_itab_t-auart NE 'RE'.  " add 2005-09-12
  CHECK g_itab_t-auart NE 'ZRET'.  " add 2005-09-12
  CHECK g_itab_t-auart NE 'YSRE'.  " add 2005-09-12


** Request by 윤방희위원 2005-06-15
** LIPS-FKREL = 'A', 'H'일경우에는 수량변경 못하게 변경.
  IF  g_itab_t-fkrel  NE  'K'.
    MESSAGE i001 WITH '변경된 수량이 반영이 되지 않습니다.'.
  ENDIF.
  CHECK g_itab_t-fkrel = 'K'.

** Request by 윤방희위원 2005-01-26
** CR/DR에 대한 금액 및 Tax는 수량에 관계없이 처음에 가져온 값으로
** 하기위해 CR/DR이 아닌경우에만 수행한다.
  CHECK g_itab_t-vgbel NE g_itab_t-vbeln.

  g_itab_t-remn_qty = rs_mod_cells-value.

  IF  g_itab_t-remn_qty  >  g_itab_t-remn_qty2.
    MESSAGE i001 WITH ' 마감수량이 잔량보다 큽니다.'.
  ENDIF.

** Request By 윤방희 : 2005-06-15
** 금액을 계산하지 않고 Standard Function을 이용한다.
** 납품관련빌링일 경우에만 새로운 로직을 적용하고
** 오더관련빌링일 경우에는 기존로직을 사용한다.
  IF  g_itab_t-zgubun  =  'D'.
    PERFORM  invoice_amount_calc  CHANGING l_tax.
  ELSE.
** New  => 청구액 : 마감수량 * 단가
** Old  => 청구액 : (마감수량 * 단가) / 기준량
    IF  pa_spart  =  '21'  OR      " 자동차전선
        pa_spart  =  '22'  OR      " 튜브
        pa_spart  =  '51'  OR      " 커넥터
        pa_spart  =  '53'.         " 폴리머스위치
      g_itab_t-netwr  =  g_itab_t-remn_qty  *  g_itab_t-netpr2.
      IF  g_itab_t-waerk  =  'KRW'.
        IF  g_itab_t-netwr  NE  0.
          g_itab_t-netwr  =  g_itab_t-netwr  /  100.
        ENDIF.
      ENDIF.
    ELSE.
      g_itab_t-netwr  =  g_itab_t-remn_qty  *  g_itab_t-netpr.
    ENDIF.

** Tax : 청구액 * Tax Rate
    IF  g_itab_t-netwr  =  0  OR
        g_itab_t-ztax   =  0.
      g_itab_t-ztax2  =  0.
    ELSE.
      l_netwr  =  g_itab_t-netwr  *  100.
      l_tax  =  l_netwr * ( g_itab_t-ztax / 100 ).
    ENDIF.

  ENDIF.

  g_itab_t-z_sum = g_itab_t-netwr + l_tax.

  IF  g_itab_t-waerk  =  'KRW'.
    l_tax  =  l_tax  *  100.
  ENDIF.

  l_input  =  l_tax.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '-'   " ' ':반올림, '+':올림, '-':버림
      i_runit     = '1'
      i_value     = l_input
    IMPORTING
      e_value_rnd = l_output.

  g_itab_t-ztax2  =  l_output.


** 세금계산서단가(금액/마감수량) 필드 추가
  IF g_itab_t-netwr  =  0  OR g_itab_t-remn_qty  =  0.
    g_itab_t-znetpr  =  0.
  ELSE.
    g_itab_t-znetpr  =  g_itab_t-netwr  /  g_itab_t-remn_qty.
  ENDIF.

  IF  g_itab_t-waerk  =  'KRW'.
    g_itab_t-znetpr  =  g_itab_t-znetpr  *  100.
  ENDIF.


  MODIFY g_itab_t INDEX rs_mod_cells-row_id
                  TRANSPORTING remn_qty netwr ztax2 z_netwr
                               z_mwsbp znetpr z_sum.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'NETWR'
                            g_itab_t-netwr.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'ZTAX2'
                            g_itab_t-ztax2.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'Z_NETWR'
                            g_itab_t-z_netwr.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'Z_MWSBP'
                            g_itab_t-z_mwsbp.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'ZNETPR'
                            g_itab_t-znetpr.

  PERFORM modify_cell USING rr_data_changed
                            rs_mod_cells-row_id
                            rs_mod_cells-tabix
                            'Z_SUM'
                            g_itab_t-z_sum.

*

ENDFORM.                    " mark_changed

*&---------------------------------------------------------------------*
*&      Form  mark_changed_prsdt
*&---------------------------------------------------------------------*
FORM mark_changed_prsdt  USING rr_data_changed TYPE REF TO
                               cl_alv_changed_data_protocol
                               rs_mod_cells TYPE lvc_s_modi.

  READ TABLE g_itab_t INDEX rs_mod_cells-row_id.

  g_itab_t-prsdt = rs_mod_cells-value.

  MODIFY g_itab_t INDEX rs_mod_cells-row_id
                  TRANSPORTING prsdt.

ENDFORM.                    " mark_changed_prsdt

*&---------------------------------------------------------------------*
*&      Form  call_va03
*&---------------------------------------------------------------------*
FORM call_va03  USING    p_value.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   p_value.

* CALL TRANSACTION
  CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                                                    " call_va03

*&---------------------------------------------------------------------*
*&      Form  call_vl03n
*&---------------------------------------------------------------------*
FORM call_vl03n  USING    p_value.

  IF  p_value+0(3)  =  '511'  OR
      p_value+0(3)  =  '598'  OR
      p_value+0(3)  =  '582'.

* PARAMETER SETTING
    SET PARAMETER ID: 'AUN'    FIELD   p_value.

* CALL TRANSACTION
    CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    COMMIT WORK AND WAIT.

  ELSE.

* PARAMETER SETTING
    SET PARAMETER ID: 'VL'    FIELD   p_value.

* CALL TRANSACTION
    CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
    COMMIT WORK AND WAIT.

  ENDIF.

ENDFORM.                    " call_vl03n

*&---------------------------------------------------------------------*
*&      Form  value_request
*&---------------------------------------------------------------------*
FORM value_request  USING    p_gubun.

  TYPE-POOLS vrm.
  DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
  DATA: lv_vrmid   TYPE vrm_id     .

  REFRESH: lt_values.
  CLEAR  : lt_values, lv_vrmid.

  CASE  p_gubun.

    WHEN  'FKSTA'.
      lv_vrmid = 'PA_FKSTA'.
      PERFORM get_vrm_id_values TABLES lt_values
                                USING: 'T' '전체',
                                       'A' '아직 처리되지 않음',
                                       'B' '부분적으로 처리했음'.

  ENDCASE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_vrmid
      values          = lt_values[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF  sy-subrc  <>  0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " value_request

*&---------------------------------------------------------------------*
*&      Form  GET_VRM_ID_VALUES
*&---------------------------------------------------------------------*
FORM get_vrm_id_values  TABLES   t_values TYPE vrm_values
                        USING    p_key
                                 p_text.

  t_values-key    = p_key.
  t_values-text   = p_text.
  APPEND t_values.

ENDFORM.                    " GET_VRM_ID_VALUES

*&---------------------------------------------------------------------*
*&      Form  bdc_data_move
*&---------------------------------------------------------------------*
FORM bdc_data_move .

  DATA : lv_nametxt TYPE user_addr-name_textc,
         lv_kunnr   TYPE kunnr,
         lv_err     TYPE flag.

  DATA : l_ztext(40),
         l_cnt       TYPE i.

  CLEAR : g_bdc_t, g_bdc_t[], g_err,
          g_tmp_t, g_tmp_t[], g_tmp2_t, g_tmp2_t[],
          l_ztext, l_cnt.

  CLEAR : g_it_t, g_it_t[], gt_pod, gt_pod[].

  l_cnt  =  1.

  LOOP AT g_itab_t WHERE chk = 'X'.

** CR/DR일때는 수량 Check를 하지 않는다.
    IF  g_itab_t-vgbel  NE  g_itab_t-vbeln.
      CHECK NOT g_itab_t-remn_qty = 0.
    ENDIF.

    IF  l_cnt  =  1.
      l_ztext  =  g_itab_t-ztext.
    ENDIF.

    MOVE-CORRESPONDING  g_itab_t  TO  g_bdc_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_tmp_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_it_t.

**********************************************************************
*빌링 분할 여부 점검  " CHM2510-00065
**********************************************************************
    IF  g_itab_t-ztext  <>  l_ztext.
      MESSAGE e002 WITH 'Billing이 분할되어야 합니다.'
                        '(청구분할 필드 참조)'.
    ENDIF.
**********************************************************************

    IF  g_itab_t-remn_qty  >  g_itab_t-remn_qty2.
      MESSAGE e001 WITH '마감수량이 잔량보다 큽니다.'.
    ENDIF.

    IF  g_itab_t-zout  =  'X'  OR
        g_itab_t-zout  =  'Y'.
    ELSE.
      IF  g_itab_t-vgbel  =  g_itab_t-vbeln.
      ELSE.
        MESSAGE e001 WITH '통문관련 Flag를 확인하세요.'.
      ENDIF.
    ENDIF.

    IF g_itab_t-pod_stat = icon_led_red.
      MESSAGE e001 WITH 'POD상태를 확인하세요.'.
    ENDIF.

    l_ztext  =  g_itab_t-ztext.

    l_cnt  =  l_cnt  +  1.

***********************************************************************
**POD 대상 주문수량과 납품수량 비교(항상일치 필요) " CHM2510-00065
***********************************************************************
*    IF g_itab_t-bwart = '687' AND g_itab_t-pstyv = 'ZBIS'.
*
*      IF g_itab_t-remn_qty = 0.
*        MESSAGE e001 WITH '마감수량을 입력하세요.'.
*      ENDIF.
*
*      IF g_itab_t-remn_qty <> g_itab_t-kwmeng.
*        MESSAGE e002 WITH G_ITAB_T-VGBEL '주문수량과 납품수량 불일치 오류'.
*      ENDIF.
*    ENDIF.

**********************************************************************
*이동유형이 687인것들만 별도로 처리위해 분기
**********************************************************************
    IF g_itab_t-bwart = '687' AND g_itab_t-pstyv = 'ZBIS'.

      IF g_itab_t-remn_qty = 0.
        MESSAGE e001 WITH '마감수량을 입력하세요.'.
      ENDIF.

      g_itab_t-pod = |X|. MODIFY g_itab_t.
      MOVE-CORRESPONDING g_itab_t TO gt_pod.
      APPEND gt_pod. CLEAR gt_pod.
      CONTINUE.
    ENDIF.
**********************************************************************

    APPEND : g_bdc_t, g_tmp_t, g_it_t.
    CLEAR : g_bdc_t, g_tmp_t, g_it_t.

  ENDLOOP.

  IF sy-subrc <> 0 OR l_cnt  =  1.
    MESSAGE e001 WITH 'Billing처리할 문서를 선택하세요'.
  ENDIF.


**********************************************************************
*POD 오더들의 스케쥴라인 점검 " CHM2510-00065
**********************************************************************
  LOOP AT gt_pod WHERE vgbel IS NOT INITIAL.
    SELECT SINGLE mandt INTO sy-mandt FROM vbep WHERE vbeln = gt_pod-vgbel AND ettyp <> 'NU'.
    IF sy-subrc = 0 .
      MESSAGE e002 WITH
      gt_pod-vgbel
      '판매오더 SLCA오류(GTOSS로 문의필요)'.
    ENDIF.
  ENDLOOP.
**********************************************************************




**********************************************************************
* LOCK 설정 / 확정버튼 제거로 인한 로직 이동 // 선택한 데이터에 에러 없을때 생성 /
**********************************************************************
**********************************************************************
  DATA(lt_tmp) = g_itab_t[].
  DELETE lt_tmp WHERE chk IS INITIAL.
  SORT lt_tmp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING vgbel.
  LOOP AT lt_tmp INTO DATA(ls_tmp).
    CLEAR gs_lock.
    gs_lock-vbeva = ls_tmp-vgbel.

    PERFORM check_lock_code USING    space
                            CHANGING lv_nametxt lv_kunnr lv_err.
    IF lv_err EQ 'X'.
      MESSAGE i104(zgtsd01) WITH lv_nametxt lv_kunnr DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_err IS NOT INITIAL.
    CLEAR g_itab_t.
    MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
    g_err = 'X'. EXIT.
  ENDIF.

  LOOP AT lt_tmp INTO ls_tmp.
    CLEAR gs_lock.
    MOVE-CORRESPONDING ls_tmp TO gs_lock.
    gs_lock-kunnr = ls_tmp-kunag.
    gs_lock-vbeva = ls_tmp-vgbel.
    gs_lock-vbevl = ls_tmp-vbeln.
    PERFORM doc_lock USING 'ZGTSDR0120'.
  ENDLOOP.

**********************************************************************
*POD 빌링
**********************************************************************
  CLEAR g_err.
  SORT gt_pod BY vbeln ASCENDING.
  DELETE ADJACENT DUPLICATES FROM gt_pod COMPARING vbeln.
  IF gt_pod[] IS NOT INITIAL.
**********************************************************************
    PERFORM call_vf01_pod.
**********************************************************************
    gt_pod-mesg  =  g_mesg.
    CLEAR gt_pod-pod.
    MODIFY gt_pod TRANSPORTING mesg pod
                         WHERE chk = 'X' AND pod = |X|.

    LOOP AT g_itab_t WHERE pod = |X| AND chk = 'X' .
      READ TABLE gt_pod INTO DATA(ls_pod) WITH KEY vbeln = g_itab_t-vbeln
                                                   posnr = g_itab_t-posnr.
      IF sy-subrc = 0.
        g_itab_t-vbeln_vf = ls_pod-vbeln_vf.
      ENDIF.
      g_itab_t-mesg = g_mesg.
      MODIFY g_itab_t.
    ENDLOOP.

  ENDIF.

  IF g_err IS NOT INITIAL.
    MESSAGE i001 WITH g_mesg DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
**********************************************************************

  CHECK g_tmp_t[] IS NOT INITIAL.

  DELETE ADJACENT DUPLICATES FROM g_tmp_t COMPARING vbeln.

  LOOP AT g_tmp_t.
    MOVE-CORRESPONDING  g_tmp_t  TO  g_tmp2_t.
    APPEND  g_tmp2_t.
    CLEAR  g_tmp2_t.
  ENDLOOP.

  SORT g_tmp_t BY vbeln.
  SORT g_tmp2_t BY vbeln.
  SORT g_bdc_t BY vbeln.

** 무상빌링의 경우에는 BDC를 다르게 수행한다(내수만 해당됨)
** BDC Recording

  DATA(lt_lock) = g_tmp_t[].
  SORT lt_lock BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_lock COMPARING vbeln.
  LOOP AT lt_lock INTO DATA(ls_lock).
    READ TABLE g_itab_t WITH KEY vbeln = ls_lock-vbeln
                                 chk = 'X'.
    CHECK sy-subrc = 0.
    CLEAR gs_lock.
    gs_lock-vbeva = g_itab_t-vgbel.
    PERFORM doc_unlock USING 'ZGTSDR0120'.
  ENDLOOP.

  IF  g_bdc_gubun  =  '2'.     " 무상빌링
    DATA : l_maechul.
    l_maechul  =  'X'.
    EXPORT l_maechul TO MEMORY ID 'ZSD013'.

    PERFORM  bdc_process_rtn.

  ELSE.


** Changed by SDC06
** 수출과 공통으로 쓰기 위해 BDC Routin를 Function으로 처리.
    CALL FUNCTION 'ZSD_MAECHUL_BILL_BDC'
      EXPORTING
        i_imode  = pa_imode
        i_ucomm  = g_ucomm
        i_fkdat  = pa_fkdat
        i_tcode  = sy-tcode
      IMPORTING
        e_subrc  = g_subrc
        e_mesg   = g_mesg
      TABLES
        izsds011 = g_tmp_t
        izsds012 = g_bdc_t.

    g_itab_t-mesg  =  g_mesg.

    MODIFY g_itab_t TRANSPORTING mesg
                           WHERE chk = 'X' AND pod IS INITIAL.

  ENDIF.

ENDFORM.                    " bdc_data_moveFORM BDC_DATA_MOVE .

*&---------------------------------------------------------------------*
*&      Form  BDC_DATA_MOVE_BDC4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bdc_data_move_bdc4.
  DATA : l_ztext(25),
         l_cnt TYPE i.
  CLEAR : g_bdc_t, g_bdc_t[],
          g_tmp_t, g_tmp_t[], g_tmp2_t, g_tmp2_t[],
          l_ztext, l_cnt.
  CLEAR : g_it_t, g_it_t[].

  l_cnt  =  1.


*--- 선택데이터 점검
  LOOP AT g_itab_t WHERE chk = 'X' AND charg IS NOT INITIAL.
** CR/DR일때는 수량 Check를 하지 않는다.
    IF  g_itab_t-vgbel  NE  g_itab_t-vbeln.
      CHECK NOT g_itab_t-remn_qty = 0.
    ENDIF.

    IF  l_cnt  =  1.
      l_ztext  =  g_itab_t-ztext.
    ENDIF.

    MOVE-CORRESPONDING  g_itab_t  TO  g_bdc_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_tmp_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_it_t.   " Add 2005-04-20

    IF  g_itab_t-remn_qty  >  g_itab_t-remn_qty2.
      MESSAGE e001 WITH '마감수량이 잔량보다 큽니다.'.
    ENDIF.

    IF  g_itab_t-zout  =  'X'  OR
        g_itab_t-zout  =  'Y'.
    ELSE.
      IF  g_itab_t-vgbel  =  g_itab_t-vbeln.
      ELSE.
        MESSAGE e001 WITH '통문관련 Flag를 확인하세요.'.
      ENDIF.
    ENDIF.
    IF  sy-subrc  <>  0 .
      MESSAGE e001 WITH 'Billing처리할 문서를 선택하세요'.
    ENDIF.
  ENDLOOP.


  DATA : lv_charg LIKE lips-charg.

*--- 기대번호별 빌링처리
  LOOP AT g_itab_t WHERE chk = 'X' AND charg IS NOT INITIAL.
    CLEAR : g_bdc_t, g_bdc_t[].
    CLEAR : g_tmp_t, g_tmp_t[].
    CLEAR : g_it_t, g_it_t[].

** CR/DR일때는 수량 Check를 하지 않는다.
    IF  g_itab_t-vgbel  NE  g_itab_t-vbeln.
      CHECK NOT g_itab_t-remn_qty = 0.
    ENDIF.

    IF  l_cnt  =  1.
      l_ztext  =  g_itab_t-ztext.
    ENDIF.

    MOVE-CORRESPONDING  g_itab_t  TO  g_bdc_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_tmp_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_it_t.   " Add 2005-04-20

    l_ztext  =  g_itab_t-ztext.

    l_cnt  =  l_cnt  +  1.

    APPEND : g_bdc_t, g_tmp_t, g_it_t.
    CLEAR : g_bdc_t, g_tmp_t, g_it_t.


    SORT g_tmp_t BY vbeln.
    SORT g_bdc_t BY vbeln.

*    LV_CHARG  = G_ITAB_T-CHARG.
*    EXPORT LV_CHARG  TO MEMORY ID 'ZSDR0120_CHARG'.

    DATA(lt_lock) = g_tmp_t[].
    SORT lt_lock BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_lock COMPARING vbeln.
    LOOP AT lt_lock INTO DATA(ls_lock).
      CLEAR gs_lock.
      gs_lock-vbeva = ls_lock-vbeln.
      PERFORM doc_unlock USING 'ZGTSDR0120'.
    ENDLOOP.

    CALL FUNCTION 'ZSD_MAECHUL_BILL_BDC'
      EXPORTING
        i_imode  = pa_imode
        i_ucomm  = g_ucomm
        i_fkdat  = pa_fkdat
        i_tcode  = sy-tcode
      IMPORTING
        e_subrc  = g_subrc
        e_mesg   = g_mesg
      TABLES
        izsds011 = g_tmp_t
        izsds012 = g_bdc_t.

    g_itab_t-mesg  =  g_mesg.

    MODIFY g_itab_t TRANSPORTING mesg
                           WHERE chk = 'X'
                            AND  charg = g_itab_t-charg.
*    FREE MEMORY ID 'ZSDR0120_CHARG'.
  ENDLOOP.

*--- 배치없는 품목은 묶어서 처리

  CLEAR : g_bdc_t, g_bdc_t[].
  LOOP AT g_itab_t WHERE chk = 'X' AND charg IS INITIAL.


** CR/DR일때는 수량 Check를 하지 않는다.
    IF  g_itab_t-vgbel  NE  g_itab_t-vbeln.
      CHECK NOT g_itab_t-remn_qty = 0.
    ENDIF.

    IF  l_cnt  =  1.
      l_ztext  =  g_itab_t-ztext.
    ENDIF.

    MOVE-CORRESPONDING  g_itab_t  TO  g_bdc_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_tmp_t.
    MOVE-CORRESPONDING  g_itab_t  TO  g_it_t.   " Add 2005-04-20

    l_ztext  =  g_itab_t-ztext.

    l_cnt  =  l_cnt  +  1.

    APPEND : g_bdc_t, g_tmp_t, g_it_t.
    CLEAR : g_bdc_t, g_tmp_t, g_it_t.

    DELETE ADJACENT DUPLICATES FROM g_tmp_t COMPARING vbeln.


    SORT g_tmp_t BY vbeln.
    SORT g_bdc_t BY vbeln.

  ENDLOOP.


** 수출과 공통으로 쓰기 위해 BDC Routin를 Function으로 처리.
  IF g_bdc_t[] IS NOT INITIAL.
    CALL FUNCTION 'ZSD_MAECHUL_BILL_BDC'
      EXPORTING
        i_imode  = pa_imode
        i_ucomm  = g_ucomm
        i_fkdat  = pa_fkdat
        i_tcode  = sy-tcode
      IMPORTING
        e_subrc  = g_subrc
        e_mesg   = g_mesg
      TABLES
        izsds011 = g_tmp_t
        izsds012 = g_bdc_t.

    g_itab_t-mesg  =  g_mesg.

    MODIFY g_itab_t TRANSPORTING mesg
                           WHERE chk = 'X'
                            AND  charg  = ' '.
  ENDIF.

ENDFORM.                    " bdc_data_move

*&---------------------------------------------------------------------*
*&      Form  bdc_process_rtn
*&---------------------------------------------------------------------*
FORM bdc_process_rtn.

  CLEAR : bdctab, g_msg_t, g_cnt.
  REFRESH : bdctab, g_msg_t.

  g_imode  =  pa_imode.

  g_cnt  =  1.

  LOOP AT g_tmp_t.

    PERFORM  record_init_rtn.

**  choi
    LOOP AT g_bdc_t WHERE vbeln = g_tmp_t-vbeln.

      PERFORM  record_rtn.

    ENDLOOP.

    PERFORM  record_end_rtn.

    g_cnt  =  g_cnt  +  1.

  ENDLOOP.

  PERFORM  record_save_rtn.

** Transaction option

  IF  g_ucomm  =  'VF01'.     " 대금청구 온라인
    g_imode  =  'E'.
*     g_imode  = pa_imode.
  ENDIF.

  ctu_params-dismode  =  g_imode.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VF01' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

  g_bdc_t-subrc = sy-subrc.

  IF  g_ucomm  =  'VF01'.     " 대금청구 온라인
    PERFORM  message_rtn_vf01.
  ELSE.
    PERFORM  message_rtn.
  ENDIF.

  MODIFY g_itab_t TRANSPORTING mesg  WHERE chk = 'X'.

ENDFORM.                    " bdc_process_rtn

*&---------------------------------------------------------------------*
*&      Form  record_init_rtn
*&---------------------------------------------------------------------*
FORM record_init_rtn.

  DATA : l_fkdat(8),
         l_vbeln    LIKE lips-vbeln,
         l_cnt      TYPE i.
  CLEAR : l_vbeln, l_cnt.

  IF  pa_fkdat  <>  '00000000'.
    l_fkdat  =  pa_fkdat.
  ELSE.
    l_fkdat  =  space.
  ENDIF.

  IF  g_cnt  =  1.

    DESCRIBE TABLE g_tmp2_t LINES l_cnt.

    IF  l_cnt  >  1.
      READ TABLE g_tmp2_t INDEX 2.
      l_vbeln  =  g_tmp2_t-vbeln.
    ENDIF.

    PERFORM  dynpro  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN',
                 ' '  'KOMFK-VBELN(01)'  ' '.

    PERFORM  dynpro  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      l_fkdat,
               ' '  'RV60A-SELKZ(01)'  'X',
               ' '  'KOMFK-VBELN(01)'  g_tmp_t-vbeln,
               ' '  'KOMFK-VBELN(02)'  l_vbeln.


  ELSEIF  g_cnt  =  2.

    PERFORM  dynpro  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN'.

    PERFORM  dynpro  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(01)',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      l_fkdat,
               ' '  'RV60A-SELKZ(01)'  'X'.



  ELSE.

    PERFORM  dynpro  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN'.


    PERFORM  dynpro  USING :
              'X'  'SAPMV60A'         '0102',
              ' '  'BDC_CURSOR'       'KOMFK-VBELN(02)',
              ' '  'BDC_OKCODE'       '=PICK',
              ' '  'RV60A-FKDAT'      l_fkdat,
              ' '  'RV60A-SELKZ(02)'  'X',
              ' '  'KOMFK-VBELN(02)'  g_tmp_t-vbeln.

  ENDIF.

ENDFORM.                    " record_init_rtn

*&---------------------------------------------------------------------*
*&      Form  record_save_rtn
*&---------------------------------------------------------------------*
FORM record_save_rtn.

  IF  g_ucomm  =  'VF01'.            " 대금청구 온라인
*    PERFORM  DYNPRO  USING :
*                 'X'  'SAPMV60A'         '0102',
*                 ' '  'BDC_OKCODE'       '=UEBK'.
*  ELSE.
    PERFORM  dynpro  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=SICH'.
  ENDIF.

ENDFORM.                    " record_save_rtn

*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
FORM dynpro USING dynbegin fnam fval.

  CLEAR bdctab.

  IF  dynbegin  =  'X'.

    bdctab-dynbegin  =  'X'.
    bdctab-program   =  fnam.
    bdctab-dynpro    =  fval.
    APPEND bdctab.

  ELSE.

    bdctab-fnam      =  fnam.
    bdctab-fval      =  fval.
    APPEND bdctab.

  ENDIF.

ENDFORM.                    " dynpro

*&---------------------------------------------------------------------*
*&      Form  message_rtn
*&---------------------------------------------------------------------*
FORM message_rtn .

  DATA : l_line TYPE i.

  DESCRIBE TABLE g_msg_t LINES l_line.
  READ TABLE g_msg_t INDEX l_line.

  IF  g_msg_t-msgtyp = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
*       msgid               = 'VF'
*       msgnr               = '311'
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = g_bdc_t-mesg.

    g_bdc_t-subrc  =  0.

  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = g_bdc_t-mesg.

  ENDIF.

  g_itab_t-mesg  =  g_bdc_t-mesg.

  MODIFY g_bdc_t TRANSPORTING subrc mesg
                       WHERE vbeln = g_tmp_t-vbeln.

  MODIFY g_itab_t TRANSPORTING mesg
                       WHERE chk = 'X'.

ENDFORM.                    " message_rtn

*&---------------------------------------------------------------------*
*&      Form  message_rtn_vf01
*&---------------------------------------------------------------------*
FORM message_rtn_vf01.

  DATA : l_vbeln    LIKE vbrp-vbeln,
         l_mesg(70).
  CLEAR : l_vbeln, l_mesg.

** VBUP의 FKSTA가 'C'일 경우 대금청구가 완료.
*-> CCM : 18.04.2023 11:58:56 / ZLSGSD4
*  SELECT  SINGLE *
*    FROM  VBUP
*   WHERE  VBELN  =  G_BDC_T-VBELN
*     AND  POSNR  =  G_BDC_T-POSNR
*     AND  FKSTA  =  'C'.

  SELECT SINGLE *
   FROM  lips
  WHERE  vbeln  =  g_bdc_t-vbeln
    AND  posnr  =  g_bdc_t-posnr
    AND  fksta  =  'C'.
*<-

  IF  sy-subrc  =  0.

    SELECT  SINGLE vbeln
      INTO  l_vbeln
      FROM  vbrp
     WHERE  vgbel  =  g_bdc_t-vbeln
*-> CCM : 18.04.2023 11:58:22 / ZLSGSD4
       AND  draft  =  space.
*<-

    CONCATENATE  '대금청구문서 ' l_vbeln '이(가) 생성되었습니다'
           INTO  l_mesg SEPARATED BY space.

    g_bdc_t-mesg   =  l_mesg.
    g_itab_t-mesg  =  l_mesg.

  ELSE.
    g_bdc_t-mesg  =  '비정상적으로 수행.'.
    g_itab_t-mesg  =  g_bdc_t-mesg.
  ENDIF.

  MODIFY g_bdc_t TRANSPORTING subrc mesg
                       WHERE vbeln = g_tmp_t-vbeln.

  MODIFY g_itab_t TRANSPORTING mesg
                       WHERE chk = 'X'.

ENDFORM.                    " message_rtn_vf01

*&---------------------------------------------------------------------*
*&      Form  call_va02
*&---------------------------------------------------------------------*
FORM call_va02 .

  DATA : l_cnt TYPE i.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  CHECK g_subrc IS INITIAL.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.


  l_cnt  =  0.

  LOOP AT g_itab_t WHERE chk = 'X'.
    l_cnt  =  l_cnt  +  1.
  ENDLOOP.

  IF  l_cnt  >  1.
    MESSAGE e001 WITH '하나의 주문번호를 선택하세요.'.
  ELSEIF  l_cnt  =  0.
    MESSAGE e001 WITH '금액변경할 문서를 선택하세요.'.
  ENDIF.

  READ TABLE g_itab_t WITH KEY chk = 'X'.

** PARAMETER SETTING
*  set parameter id: 'AUN'    field  g_itab_t-vgbel.
*
** CALL TRANSACTION
*  call transaction  'VA02' and skip first screen.
*  commit work and wait.

  PERFORM  bdc_call_va02.
  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
ENDFORM.                                                    " call_va02
*&---------------------------------------------------------------------*
*&      Form  value_request_vari
*&---------------------------------------------------------------------*
*  레이아웃관련
*----------------------------------------------------------------------*
FORM value_request_vari .

  CLEAR g_layout.

  MOVE  g_repid  TO  gs_variant-report.
  MOVE  '1'      TO  gs_variant-handle.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = gs_variant
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
*&      Form  crdr_data_query
*&---------------------------------------------------------------------*
FORM crdr_data_query .

  DATA : BEGIN OF l_crdr_t OCCURS 0,
           sortkri LIKE vkdfs-sortkri.
           INCLUDE STRUCTURE g_crdr_t.
  DATA : END OF l_crdr_t.

  DATA : ll_check_cnt TYPE i.

  DATA : l_vkbur LIKE vbak-vkbur,
         l_vkgrp LIKE vbak-vkgrp.

  CLEAR : g_crdr_t, g_crdr_t[],
          l_vkbur, l_vkgrp.

  SELECT  vbap~vbeln AS vgbel
          vbap~posnr AS vgpos
          vbap~kwmeng vbap~vrkme vbap~matnr makt~maktx
          vbap~charg  vbap~lsmeng AS lfimg
          vbap~lsmeng AS kcmeng
          vbap~netpr  vbap~waerk vbap~taxm1 vbkd~kdkg4
          vkdfs~faksk vkdfs~kunnr AS kunag
          vbkd~fkdat AS wadat_ist
          vbap~kpein  vbap~werks vbkd~zterm vbak~vbtyp
          vbap~abgru vbap~pstyv
          vbap~netwr tvap~fkrel AS fkrel vbkd~bstkd AS bstkd
          vbak~taxk1
          vbkd~fbuda
  INTO  CORRESPONDING FIELDS OF TABLE g_crdr_t
    FROM  vkdfs INNER JOIN vbak ON vbak~vbeln = vkdfs~vbeln
                      JOIN vbap ON vbap~vbeln = vkdfs~vbeln
                      JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                               AND vbkd~posnr = '0'
                      JOIN makt ON makt~matnr = vbap~matnr
                               AND makt~spras = sy-langu
                      JOIN tvap ON tvap~pstyv = vbap~pstyv
   WHERE  vkdfs~fktyp EQ 'A'
     AND  vkdfs~fkdat IN so_wadat
     AND  vbkd~kdkg4 EQ p_local
     AND  vkdfs~vkorg EQ pa_vkorg
     AND  vkdfs~vtweg EQ pa_vtweg
     AND  vkdfs~spart EQ pa_spart
     AND  vbak~vkbur IN so_vkbur
     AND  vbak~vkgrp IN so_vkgrp
     AND  vbak~auart NE 'B3'
     AND  vkdfs~fkdat IN so_wadat
     AND  vkdfs~kunnr IN so_kunnr
     AND  vkdfs~faksk EQ ' '
     AND  tvap~fkrel IN ('B','C','F').

  LOOP AT g_crdr_t.

    SELECT COUNT(*)
      INTO ll_check_cnt
      FROM vbkd
     WHERE vbeln = g_crdr_t-vgbel
       AND posnr = g_crdr_t-vgpos.


    IF ll_check_cnt > 0.
      DELETE g_crdr_t.
    ENDIF.

    CLEAR : ll_check_cnt.

  ENDLOOP.

  SELECT  vbap~vbeln AS vgbel
          vbap~posnr AS vgpos
          vbap~kwmeng vbap~vrkme vbap~matnr makt~maktx
          vbap~charg  vbap~lsmeng AS lfimg
          vbap~lsmeng AS kcmeng
          vbap~netpr  vbap~waerk vbap~taxm1 vbkd~kdkg4
          vkdfs~faksk vkdfs~kunnr AS kunag
          vbkd~fkdat AS wadat_ist
          vbap~kpein vbap~werks vbkd~zterm vbak~vbtyp
          vbap~abgru vbap~pstyv
          vbap~netwr tvap~fkrel AS fkrel vbkd~bstkd AS bstkd
          vbak~taxk1
          vbkd~fbuda
  APPENDING  CORRESPONDING FIELDS OF TABLE g_crdr_t
    FROM  vkdfs INNER JOIN vbak ON vbak~vbeln = vkdfs~vbeln
                      JOIN vbap ON vbap~vbeln = vkdfs~vbeln
                      JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                               AND vbkd~posnr = vbap~posnr
                      JOIN makt ON makt~matnr = vbap~matnr
                               AND makt~spras = sy-langu
                      JOIN tvap ON tvap~pstyv = vbap~pstyv
   WHERE  vkdfs~fktyp EQ 'A'
     AND  vkdfs~fkdat IN so_wadat
     AND  vbkd~kdkg4 EQ p_local
     AND  vkdfs~vkorg EQ pa_vkorg
     AND  vkdfs~vtweg EQ pa_vtweg
     AND  vkdfs~spart EQ pa_spart
     AND  vbak~vkbur IN so_vkbur
     AND  vbak~vkgrp IN so_vkgrp
     AND  vbak~auart NE 'B3'
     AND  vbkd~fkdat IN so_wadat
     AND  vkdfs~kunnr IN so_kunnr
     AND  vkdfs~faksk EQ ' '
     AND  tvap~fkrel IN ('B','C','F').

  SELECT  vbap~vbeln AS vgbel
        vbap~posnr AS vgpos
        vbap~kwmeng vbap~vrkme vbap~matnr makt~maktx
        vbap~charg  vbap~lsmeng AS lfimg
        vbap~lsmeng AS kcmeng
        vbap~netpr  vbap~waerk vbap~taxm1 vbkd~kdkg4
        vkdfs~faksk vkdfs~kunnr AS kunag
        fplt~fkdat AS wadat_ist
        vbap~kpein vbap~werks vbkd~zterm vbak~vbtyp
        vbap~abgru vbap~pstyv
        fplt~fakwr AS netwr tvap~fkrel AS fkrel vbkd~bstkd AS bstkd
        vbak~taxk1
        vbkd~fbuda
  APPENDING  CORRESPONDING FIELDS OF TABLE g_crdr_t
  FROM  vkdfs INNER JOIN vbak ON vbak~vbeln = vkdfs~vbeln
                    JOIN vbap ON vbap~vbeln = vkdfs~vbeln
                    JOIN vbkd ON vbkd~vbeln = vbap~vbeln
                              AND vbkd~posnr = vbap~posnr
                    JOIN makt ON makt~matnr = vbap~matnr
                             AND makt~spras = sy-langu
                    JOIN tvap ON tvap~pstyv = vbap~pstyv
                    JOIN fplt ON fplt~fplnr = vbkd~fplnr
 WHERE  vkdfs~fktyp EQ 'A'
   AND  vkdfs~fkdat IN so_wadat
   AND  vbkd~kdkg4 EQ p_local
   AND  vkdfs~vkorg EQ pa_vkorg
   AND  vkdfs~vtweg EQ pa_vtweg
   AND  vkdfs~spart EQ pa_spart
   AND  vbak~vkbur IN so_vkbur
   AND  vbak~vkgrp IN so_vkgrp
   AND  vbak~auart NE 'B3'
   AND  vkdfs~fkdat IN so_wadat
   AND  fplt~fkdat IN so_wadat
   AND  vkdfs~kunnr IN so_kunnr
   AND  vkdfs~faksk EQ ' '
   AND  fplt~faksp  EQ ' '
   AND  fplt~fksaf  <> 'C'
   AND  tvap~fkrel = 'I'
   AND  vkdfs~netwr NE 0.

  SORT g_crdr_t BY vgbel vgpos.

  DELETE ADJACENT DUPLICATES FROM g_crdr_t COMPARING vgbel vgpos.

  LOOP AT g_crdr_t.

    MOVE-CORRESPONDING  g_crdr_t  TO  g_itab_t.

    g_itab_t-vbeln  =  g_itab_t-vgbel.
    g_itab_t-posnr  =  g_itab_t-vgpos.
    g_itab_t-zgubun  =  'O'.    " 오더관련빌링.

    APPEND  g_itab_t.
    CLEAR  g_itab_t.

  ENDLOOP.

  LOOP AT g_itab_t.

    IF  g_itab_t-zgubun IS INITIAL.
      g_itab_t-zgubun  =  'D'.    " 납품관련빌링.
      MODIFY  g_itab_t.
    ENDIF.

    CLEAR  g_itab_t.

  ENDLOOP.

ENDFORM.                    " crdr_data_query

*&---------------------------------------------------------------------*
*&      Form  crdr_sub_query
*&---------------------------------------------------------------------*
FORM crdr_sub_query .

  DATA : l_tax    TYPE p DECIMALS 2,
         l_netwr  LIKE vbap-netwr,
         l_mtart  LIKE mara-mtart,
         l_input  TYPE f,
         l_output TYPE f.
  CLEAR : l_tax, l_input, l_output, l_netwr, l_mtart.

  DATA : l_menge     LIKE matdoc-menge,
         l_sum_menge LIKE matdoc-menge,
         l_pstyv     LIKE vbap-pstyv,
         l_shkzg     LIKE matdoc-shkzg.
  DATA : l_budat LIKE matdoc-budat.

  IF g_itab_t-fkrel = 'I'.
    READ TABLE g_crdr_t WITH KEY vgbel = g_itab_t-vgbel
                                 vgpos = g_itab_t-posnr.
    IF g_crdr_t-kwmeng = 0.
      g_itab_t-netwr  =  g_crdr_t-netwr.
    ELSE.
      g_itab_t-netpr  = ( g_crdr_t-netwr / g_crdr_t-kwmeng ).
      g_itab_t-netwr  =  g_crdr_t-netwr.
    ENDIF.
    l_tax  =  g_crdr_t-netwr * ( 10 / 100 ).
*    l_tax  =  l_tax  *  100.
    g_itab_t-lfimg = 1.

  ELSE.

    SELECT  SUM( netwr ) SUM( mwsbp ) SUM( kwmeng ) SUM( kwmeng )
      INTO (g_itab_t-netwr,
            l_tax,
            g_itab_t-lfimg,
            g_itab_t-kwmeng)
      FROM  vbap
     WHERE  vbeln  =  g_itab_t-vgbel
       AND  posnr  =  g_itab_t-posnr.

    IF g_itab_t-kwmeng = 0.

    ELSE.
      g_itab_t-netpr  = ( g_itab_t-netwr / g_itab_t-kwmeng ).
      g_itab_t-netwr  =  g_itab_t-netwr.
      l_tax  =  l_tax  *  100.
    ENDIF.

  ENDIF.

  IF  g_itab_t-waerk  =  'KRW'.
    l_tax  =  l_tax  *  100.
  ENDIF.

  l_input  =  l_tax.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '-'   " ' ':반올림, '+':올림, '-':버림
      i_runit     = '1'
      i_value     = l_input
    IMPORTING
      e_value_rnd = l_output.

  g_itab_t-ztax2  =  l_output.

  IF  g_itab_t-vbtyp  =  'H'  OR
      g_itab_t-vbtyp  =  'K'.
    g_itab_t-netwr  =  g_itab_t-netwr  *  -1.
    g_itab_t-ztax2  =  g_itab_t-ztax2  *  -1.
  ENDIF.

***CHOI
  g_itab_t-z_sum = g_itab_t-netwr + ( g_itab_t-ztax2 / 100 ).
  g_itab_t-remn_qty2 = g_crdr_t-kwmeng.
  g_itab_t-remn_qty  = g_crdr_t-kwmeng.

  IF pa_spart = '70' AND g_itab_t-pstyv = 'ZDIE'.

    IF so_wadat-option = 'EQ'.
      l_budat = so_wadat+3(8).
    ELSEIF so_wadat-option = 'BT'.
      l_budat = so_wadat+11(8).
    ENDIF.

    SELECT menge shkzg
      INTO (l_menge, l_shkzg)
      FROM matdoc
     WHERE werks = g_itab_t-werks
       AND matnr = g_itab_t-matnr
       AND kdauf = g_itab_t-vgbel
       AND kdpos = g_itab_t-posnr
       AND budat  <= l_budat.


      IF l_shkzg = 'S'.
        l_sum_menge = l_sum_menge + l_menge.
      ELSE.
        l_sum_menge = l_sum_menge - l_menge.
      ENDIF.

    ENDSELECT.

    g_itab_t-lfimg  =  l_sum_menge.

    CLEAR : l_sum_menge, l_menge, l_shkzg.

    g_itab_t-remn_qty2  =  g_itab_t-lfimg  -  g_itab_t-fkimg.
    g_itab_t-remn_qty   =  g_itab_t-lfimg  -  g_itab_t-fkimg.

    IF g_itab_t-remn_qty = 0. "and pa_chk3 NE 'X'.
      gl_flag = 'N'. EXIT.
    ELSE.
      IF  g_itab_t-netwr  =  0  OR
          g_itab_t-remn_qty  =  0.
        g_itab_t-znetpr  =  0.
      ELSE.
        g_itab_t-netwr   =  g_itab_t-netpr *  g_itab_t-remn_qty.
        g_itab_t-znetpr  =  g_itab_t-netwr /  g_itab_t-remn_qty.
        g_itab_t-ztax2   =  g_itab_t-netwr / 10.

        IF g_itab_t-waerk = 'KRW'.
          g_itab_t-ztax2 = g_itab_t-ztax2 * 100.
        ENDIF.
      ENDIF.

      g_itab_t-z_sum = g_itab_t-netwr + ( g_itab_t-ztax2 / 100 ).
      gl_flag = 'Y'.
    ENDIF.

  ENDIF.

** 거절사유가 있으면 금액 및 부가세를 0으로 한다.
  IF  NOT g_itab_t-abgru IS INITIAL.
    g_itab_t-netwr  =  0.
    g_itab_t-znetpr  = 0.
    g_itab_t-netpr   = 0.
    g_itab_t-ztax2  =  0.
    g_itab_t-remn_qty = 0.
  ENDIF.


ENDFORM.                    " crdr_sub_query

*&---------------------------------------------------------------------*
*&      Form  f4_for_vkbur
*&---------------------------------------------------------------------*
FORM f4_for_vkbur .

  DATA : l_selectfield  LIKE help_info-fieldname,
         l_select_value LIKE help_info-fldvalue,
         l_fld_tab      LIKE help_value OCCURS 1 WITH HEADER LINE,
         l_ld_tabix     LIKE sy-tabix,
         l_scr_fields   LIKE dynpread OCCURS 0 WITH HEADER LINE,
         l_vkorg        LIKE vbak-vkorg,
         l_vtweg        LIKE vbak-vtweg,
         l_spart        LIKE vbak-spart,
         l_vkbur        LIKE vbrp-vkbur.
  CLEAR : g_values3_t, g_values3_t[].

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_VKORG'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_vkorg  =  l_scr_fields-fieldvalue.

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_VTWEG'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_vtweg  =  l_scr_fields-fieldvalue.

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_SPART'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_spart  =  l_scr_fields-fieldvalue.

** FILL INTERNAL TABLE FOR POSSIBLE ENTRY
  SELECT   a~vkbur                  " 영업팀
           b~bezei                  " 영업팀 TEXT
     FROM  tvkbz AS a INNER JOIN tvkbt AS b
                         ON a~vkbur = b~vkbur
     INTO  CORRESPONDING FIELDS OF TABLE g_values3_t
    WHERE  a~vkorg = l_vkorg
      AND  a~vtweg = l_vtweg
      AND  a~spart = l_spart
      AND  b~spras = sy-langu.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'VKBUR'
      dynpprog     = 'ZSDR0120'
      dynpnr       = pa_vkorg
      dynprofield  = 'SO_VKBUR'
      window_title = '영업팀'
      value_org    = 'S'
    TABLES
      value_tab    = g_values3_t.

  IF  sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " f4_for_vkbur

*&---------------------------------------------------------------------*
*&      Form  f4_for_vkgrp
*&---------------------------------------------------------------------*
FORM f4_for_vkgrp .

  DATA : l_selectfield  LIKE help_info-fieldname,
         l_select_value LIKE help_info-fldvalue,
         l_fld_tab      LIKE help_value OCCURS 1 WITH HEADER LINE,
         l_ld_tabix     LIKE sy-tabix,
         l_scr_fields   LIKE dynpread OCCURS 0 WITH HEADER LINE,
         l_vkorg        LIKE vbak-vkorg,
         l_vtweg        LIKE vbak-vtweg,
         l_spart        LIKE vbak-spart,
         l_vkbur        LIKE vbrp-vkbur.
  CLEAR : g_values3_t, g_values3_t[].

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_VKORG'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_vkorg  =  l_scr_fields-fieldvalue.

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_VTWEG'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_vtweg  =  l_scr_fields-fieldvalue.

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'PA_SPART'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_spart  =  l_scr_fields-fieldvalue.

  CLEAR : l_scr_fields.
  REFRESH : l_scr_fields.

  l_scr_fields-fieldname  =  'SO_VKBUR-LOW'.
  APPEND  l_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = l_scr_fields.

  READ TABLE l_scr_fields INDEX 1.

  l_vkbur  =  l_scr_fields-fieldvalue.

** FILL INTERNAL TABLE FOR POSSIBLE ENTRY
  SELECT a~vkgrp b~bezei
    FROM tvbvk AS a
    INNER JOIN tvgrt AS b
       ON a~vkgrp = b~vkgrp
    INTO CORRESPONDING FIELDS OF TABLE g_values4_t
   WHERE a~vkbur = l_vkbur
     AND b~spras = sy-langu.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'VKGRP'
      dynpprog     = 'ZSDR0120'
      dynpnr       = pa_vkorg
      dynprofield  = 'SO_VKGRP'
      window_title = '영업그룹'
      value_org    = 'S'
    TABLES
      value_tab    = g_values4_t.

  IF  sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " f4_for_vkgrp

*&---------------------------------------------------------------------*
*&      Form  ztax_calc_rtn
*&---------------------------------------------------------------------*
*  부가세조정
*----------------------------------------------------------------------*
FORM ztax_calc_rtn .

  DATA : l_cnt   TYPE i,
         l_vbeln LIKE vbak-vbeln.
  CLEAR : l_cnt, l_vbeln, g_p_auart, g_p_vkorg, g_p_vtweg,
          g_p_spart, g_p_vkbur, g_p_vkgrp, g_p_date,
          g_p_kunnr, g_p_name1, g_p_matnr, g_p_maktx,
          g_p_tax,   g_c_tax.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  CHECK g_subrc IS INITIAL.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.

  LOOP AT g_itab_t WHERE chk = 'X'.

    g_p_werks  =  g_itab_t-werks.

    l_vbeln  =  g_itab_t-vgbel.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = g_itab_t-kunag
      IMPORTING
        output = g_p_kunnr.

    CONCATENATE  g_p_kunnr '( ' g_itab_t-name1 ' )'
           INTO  g_p_name1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = g_itab_t-matnr
      IMPORTING
        output = g_p_matnr.

    CONCATENATE  g_p_matnr '( ' g_itab_t-maktx ' )'
           INTO  g_p_maktx.

    l_cnt  =  l_cnt  +  1.

  ENDLOOP.

  IF  sy-subrc  <>  0.
    MESSAGE e001 WITH '부가세조정할 문서를 선택하세요.'.
  ELSEIF  sy-subrc  =  0  AND
          l_cnt  >  1.
    MESSAGE e001 WITH '부가세조정은 품목별로 수행됩니다.'.
  ENDIF.

  CALL SCREEN 2000 STARTING AT 15 7 ENDING AT 80 12.

** 부가세조정 BDC수행.
  IF  sy-ucomm  =  'ENTE'  AND
      g_p_tax  <>  0.

    IF  g_p_tax  >  1000  OR
        g_p_tax  < -1000.
      MESSAGE e001 WITH '1000원 이상으로는 조정할수 없습니다.'.
      EXIT.
    ENDIF.

    IF  g_p_tax  >  0.
      g_p_auart  =  'ZDR'.
    ELSEIF  g_p_tax  <  0.
      g_p_auart  =  'ZCR'.
      g_p_tax  =  g_p_tax  *  -1.
    ENDIF.

    g_c_tax  =  g_p_tax.

    SELECT  SINGLE
            vkorg vtweg spart vkbur vkgrp
      INTO (g_p_vkorg, g_p_vtweg, g_p_spart,
            g_p_vkbur, g_p_vkgrp)
      FROM  vbak
     WHERE  vbeln  =  l_vbeln.

    g_p_date  =  pa_fkdat.

    PERFORM  bdc_process_rtn2.

  ENDIF.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
ENDFORM.                    " ztax_calc_rtn

*&---------------------------------------------------------------------*
*&      Form  zamt_calc_rtn
*&---------------------------------------------------------------------*
*  청구액조정
*----------------------------------------------------------------------*
FORM zamt_calc_rtn .

  DATA : l_cnt   TYPE i,
         l_vbeln LIKE vbak-vbeln.
  CLEAR : l_cnt, l_vbeln, g_p_auart, g_p_vkorg, g_p_vtweg,
          g_p_spart, g_p_vkbur, g_p_vkgrp, g_p_date,
          g_p_kunnr, g_p_name1, g_p_matnr, g_p_maktx,
          g_p_zamnt, g_c_zamnt, g_p_waerk.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  CHECK g_subrc IS INITIAL.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.

  LOOP AT g_itab_t WHERE chk = 'X'.

    g_p_werks  =  g_itab_t-werks.

    l_vbeln  =  g_itab_t-vgbel.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = g_itab_t-kunag
      IMPORTING
        output = g_p_kunnr.

    CONCATENATE  g_p_kunnr '( ' g_itab_t-name1 ' )'
           INTO  g_p_name1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = g_itab_t-matnr
      IMPORTING
        output = g_p_matnr.

    CONCATENATE  g_p_matnr '( ' g_itab_t-maktx ' )'
           INTO  g_p_maktx.

    g_p_waerk  =  g_itab_t-waerk.
    g_p_zamnt  =  0.

    l_cnt  =  l_cnt  +  1.

  ENDLOOP.

  IF  sy-subrc  <>  0.
    MESSAGE e001 WITH '청구액조정할 문서를 선택하세요.'.
  ELSEIF  sy-subrc  =  0  AND
          l_cnt  >  1.
    MESSAGE e001 WITH '청구액조정은 품목별로 수행됩니다.'.
  ENDIF.

  CALL SCREEN 3000 STARTING AT 15 7 ENDING AT 80 12.

** 청구액조정 BDC수행.
  IF  sy-ucomm  =  'ENTE'  AND
      g_p_zamnt  <>  0.

*      if  g_p_waerk  =  'KRW'.
*          g_p_zamnt  =  g_p_zamnt  *  100.
*      endif.

    IF  g_p_zamnt  >  1000  OR
        g_p_zamnt  < -1000.
      MESSAGE e001 WITH '1000원 이상으로는 조정할수 없습니다.'.
      EXIT.
    ENDIF.

    IF  g_p_zamnt  >  0.
      g_p_auart  =  'ZDR'.
    ELSEIF  g_p_zamnt  <  0.
      g_p_auart  =  'ZCR'.
      g_p_zamnt  =  g_p_zamnt  *  -1.
    ENDIF.

*      g_c_zamnt  =  g_p_zamnt.
    WRITE: g_p_zamnt CURRENCY g_p_waerk TO g_c_zamnt.

    SELECT  SINGLE
            vkorg vtweg spart vkbur vkgrp
      INTO (g_p_vkorg, g_p_vtweg, g_p_spart,
            g_p_vkbur, g_p_vkgrp)
      FROM  vbak
     WHERE  vbeln  =  l_vbeln.

    g_p_date  =  pa_fkdat.

    PERFORM  bdc_process_rtn3.

  ENDIF.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
ENDFORM.                    " zamt_calc_rtn

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR '2000'.

ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      g_p_tax  =  0.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_3000 OUTPUT.

  SET PF-STATUS '3000'.
  SET TITLEBAR '3000'.

ENDMODULE.                 " STATUS_3000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      g_p_tax  =  0.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Form  bdc_process_rtn2
*&---------------------------------------------------------------------*
FORM bdc_process_rtn2.

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  record_rtn2.

** Transaction option
  ctu_params-dismode  =  g_imode.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VA01' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

  PERFORM  message_rtn2.

ENDFORM.                    " bdc_process_rtn2

*&---------------------------------------------------------------------*
*&      Form  record_rtn2
*&---------------------------------------------------------------------*
FORM record_rtn2.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0101',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'VBAK-AUART'       g_p_auart,
                   ' '  'VBAK-VKORG'       g_p_vkorg,
                   ' '  'VBAK-VTWEG'       g_p_vtweg,
                   ' '  'VBAK-SPART'       g_p_spart,
                   ' '  'VBAK-VKBUR'       g_p_vkbur,
                   ' '  'VBAK-VKGRP'       g_p_vkgrp.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KUAGV-KUNNR'      g_p_kunnr,
                   ' '  'VBKD-FKDAT'       g_p_date,
                   ' '  'RV45A-MABNR(01)'  g_p_matnr,
                   ' '  'VBAP-ZMENG(01)'   '1'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=KPAR_SUB'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4002',
                   ' '  'BDC_OKCODE'       '/EBACK',
                   ' '  'BDC_CURSOR'  'GVS_TC_DATA-REC-PARTNER_EXT(03)',
                   ' '  'GV_FILTER'        'PARALL',
                   ' '  'GVS_TC_DATA-REC-PARTNER_EXT(03)'
                                           g_p_kunnr.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=PDE2',
                   ' '  'RV45A-VBAP_SELKZ(01)'  'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=T\05',
                   ' '  'VBAP-WERKS'       g_p_werks.

*  perform  dynpro  using :
*                   'X'  'SAPMV45A'         '4001',
*                   ' '  'BDC_OKCODE'       '=PKO1',
*                   ' '  'RV45A-VBAP_SELKZ(01)'  'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KOMV-KWERT(02)'   g_c_tax.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '=SICH'.

ENDFORM.                    " record_rtn2

*&---------------------------------------------------------------------*
*&      Form  bdc_process_rtn3
*&---------------------------------------------------------------------*
FORM bdc_process_rtn3.

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  record_rtn3.

** Transaction option
  ctu_params-dismode  =  g_imode.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VA01' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

  PERFORM  message_rtn2.

ENDFORM.                    " bdc_process_rtn3

*&---------------------------------------------------------------------*
*&      Form  record_rtn3
*&---------------------------------------------------------------------*
FORM record_rtn3.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0101',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'VBAK-AUART'       g_p_auart,
                   ' '  'VBAK-VKORG'       g_p_vkorg,
                   ' '  'VBAK-VTWEG'       g_p_vtweg,
                   ' '  'VBAK-SPART'       g_p_spart,
                   ' '  'VBAK-VKBUR'       g_p_vkbur,
                   ' '  'VBAK-VKGRP'       g_p_vkgrp.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KUAGV-KUNNR'      g_p_kunnr,
                   ' '  'VBKD-FKDAT'       g_p_date,
                   ' '  'RV45A-MABNR(01)'  g_p_matnr,
                   ' '  'VBAP-ZMENG(01)'   '1'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=KPAR_SUB'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4002',
                   ' '  'BDC_OKCODE'       '/EBACK',
                   ' '  'BDC_CURSOR'  'GVS_TC_DATA-REC-PARTNER_EXT(03)',
                   ' '  'GV_FILTER'        'PARALL',
                   ' '  'GVS_TC_DATA-REC-PARTNER_EXT(03)'
                                           g_p_kunnr.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=PDE2',
                   ' '  'RV45A-VBAP_SELKZ(01)'  'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=T\05',
                   ' '  'VBAP-WERKS'       g_p_werks.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KOMV-KWERT(01)'   g_c_zamnt.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '=SICH'.

ENDFORM.                    " record_rtn3

*&---------------------------------------------------------------------*
*&      Form  message_rtn2
*&---------------------------------------------------------------------*
FORM message_rtn2 .

  DATA : l_line     TYPE i,
         l_mesg(70).

  DESCRIBE TABLE g_msg_t LINES l_line.
  READ TABLE g_msg_t INDEX l_line.

  IF  g_msg_t-msgtyp = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

  ENDIF.

  g_itab_t-mesg  =  l_mesg.

  MODIFY g_itab_t TRANSPORTING mesg
                       WHERE chk = 'X'.

ENDFORM.                    " message_rtn2

*&---------------------------------------------------------------------*
*&      Form  bdc_call_va02
*&---------------------------------------------------------------------*
FORM bdc_call_va02 .

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0102',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'VBAK-VBELN'       g_itab_t-vgbel.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=POPO'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0251',
                   ' '  'BDC_OKCODE'       '=POSI',
                   ' '  'RV45A-POSNR'      g_itab_t-vgpos.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=PKO1',
                   ' '  'RV45A-VBAP_SELKZ(01)' 'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '=V69A_KOAN'.

  ctu_params-dismode  =  'E'.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VA02' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

ENDFORM.                    " bdc_call_va02

*&---------------------------------------------------------------------*
*&      Form  header_calc_amt
*&---------------------------------------------------------------------*
FORM header_calc_amt .

  CLEAR : g_tmp3_t, g_tmp3_t[].

  LOOP AT g_itab_t WHERE chk = 'X'.
    MOVE-CORRESPONDING  g_itab_t  TO  g_tmp3_t.
    APPEND  g_tmp3_t.
    CLEAR  g_tmp3_t.
  ENDLOOP.

ENDFORM.                    " header_calc_amt

*&---------------------------------------------------------------------*
*&      Form  invoice_amount_calc
*&---------------------------------------------------------------------*
FORM invoice_amount_calc CHANGING p_tax.

  DATA : l_flag,
         lv_msg TYPE char100.
  DATA : lv_netpr LIKE vbap-netpr,
         lv_kpein LIKE vbap-kpein,
         lv_netwr LIKE vbap-netwr,
         lv_mwsbp LIKE vbap-mwsbp.


  IF  pa_chk  =  'X'.
    l_flag  =  'X'.
  ELSE.
    l_flag  =  space.
  ENDIF.

  DATA:   tkomk LIKE STANDARD TABLE OF komk
                     WITH KEY key_uc
                     INITIAL SIZE 2
                     WITH HEADER LINE.
  DATA: knumv LIKE vbak-knumv,
        tkomv LIKE komv OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'PRICING_REFRESH'
    TABLES
      tkomk = tkomk
      tkomv = tkomv.

  IF g_itab_t-remn_qty > 0.
    CALL FUNCTION 'ZSD_PRICING'
      EXPORTING
        vbeln_o     = g_itab_t-vgbel
        posnr_o     = g_itab_t-vgpos
        vbeln_d     = g_itab_t-vbeln
        posnr_d     = g_itab_t-posnr
        fkimg       = g_itab_t-remn_qty
        fkdat       = pa_fkdat
        export_flag = l_flag
      IMPORTING
        netwr       = g_itab_t-z_netwr
        mwsbp       = g_itab_t-z_mwsbp.
  ENDIF.

** 원프로그램에서 '-'처리를 하기때문에 '-'로 넘어오는
** Data는 다시 양수로 만든다.
  IF  g_itab_t-z_netwr  <  0.
    g_itab_t-netwr  =  g_itab_t-z_netwr  *  -1.
  ELSE.
    g_itab_t-netwr  =  g_itab_t-z_netwr.
  ENDIF.
  IF  g_itab_t-z_mwsbp  <  0.
    p_tax  =  g_itab_t-z_mwsbp  *  -1.
  ELSE.
    p_tax  =  g_itab_t-z_mwsbp.
  ENDIF.

ENDFORM.                    " invoice_amount_calc

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       권한(ROLL) CHECK
*----------------------------------------------------------------------*
FORM authority_check.

  DATA: gt_tvtw  LIKE tvtw OCCURS 0 WITH HEADER LINE,
        lv_subrc LIKE sy-subrc.

  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_vkorg = pa_vkorg
      i_type  = '1'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE s002 WITH '영업조직에 대한 권한이 없습니다'
                      pa_vkorg.
    STOP.
  ENDIF.

  CLEAR : lv_subrc.

  CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
    EXPORTING
      i_spart = pa_spart
      i_type  = '3'
    IMPORTING
      e_subrc = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE s002 WITH '제품군에 대한 권한이 없습니다'
                      pa_spart.
    STOP.
  ENDIF.
ENDFORM.                    " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  bdc_data_check
*&---------------------------------------------------------------------*
FORM bdc_data_check .

  DATA : l_flag,
         l_flag2,
         l_cnt   TYPE i,
         l_werks LIKE lips-werks,
         l_ladgr LIKE lips-ladgr.
  CLEAR : l_flag, l_flag2, g_bdc_gubun, g_popup.
  CLEAR : l_cnt, l_werks.
  CLEAR : gv_tbimm.

*  IF  G_UCOMM  =  'BDC2'.        " 적송가매출
*
**___ 트랙터 국내영업팀 적송처리 제어
*    DATA : LV_MONTH LIKE VTBBEWE-ATAGE.
*
*
*
*    L_CNT  =  1.
*
**-- 윤방희 수정 : 납품처 다를 때 체크
*    DATA: COUNT    TYPE I,
*          KUNNR_WE LIKE VBAK-KUNNR.
*
*    COUNT = 1.
*    LOOP AT G_ITAB_T WHERE CHK = 'X'.
*      IF COUNT = 1.
*        KUNNR_WE = G_ITAB_T-KUNNR_WE.
*      ELSE.
*        IF KUNNR_WE NE G_ITAB_T-KUNNR_WE.
*          MESSAGE '납품처가 다르므로 빌링이 분할됩니다.'
*             TYPE 'W'.
*        ENDIF.
*      ENDIF.
*      COUNT = COUNT + 1.
*    ENDLOOP.
*
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        DEFAULTOPTION = 'N'
*        TEXTLINE1     = '적송가매출을 수행하시겠습니까..?'
*        TITEL         = '적송가매출'
*      IMPORTING
*        ANSWER        = G_POPUP.
*
*  ELSE.
  g_popup  =  'J'.
*  ENDIF.

*  IF  G_POPUP NE 'J'.  " YES => 'J',  NO => 'N'
*    MESSAGE E001 WITH '적송가매출을 중단했습니다.'.
*  ENDIF.

  LOOP AT g_itab_t WHERE chk = 'X'.

    CASE g_itab_t-fkrel.
      WHEN 'A' OR 'H' OR 'K'.
        l_flag  =  'Y'.
      WHEN OTHERS.
        IF g_itab_t-auart = 'ZFQ'.
          l_flag  =  'Y'.
        ELSE.
          l_flag2  =  'Y'.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF  l_flag  =  'Y'  AND
      l_flag2 =  'Y'.
    MESSAGE e001 WITH '오더/납품 문서를 구분 선택 바랍니다'. "'선택하신 Record를 확인하세요.'.
  ENDIF.

  IF  l_flag  =  'Y'.
    g_bdc_gubun  =  '1'.
  ELSEIF  l_flag2  =  'Y'.
    g_bdc_gubun  =  '2'.      " 무상빌링
    IF  g_ucomm  =  'BDC2'.   " 적송가매출
      MESSAGE e001 WITH '적당한 기능키를 선택하세요.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " bdc_data_check
*&---------------------------------------------------------------------*
*&      Form  record_end_rtn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM record_end_rtn .

  PERFORM  dynpro  USING :
                'X'  'SAPLV60P'         '4413',
                ' '  'BDC_OKCODE'       '=RUEB'.

ENDFORM.                    " record_end_rtn
*&---------------------------------------------------------------------*
*&      Form  record_rtn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM record_rtn .
  PERFORM  dynpro  USING :
                'X'  'SAPLV60P'         '4413',
                ' '  'BDC_OKCODE'       '=POPO'.

  PERFORM  dynpro  USING :
                   'X'  'SAPLV60P'         '0251',
                   ' '  'BDC_OKCODE'       '=POSI',
                   ' '  'RV45A-POSNR'      g_bdc_t-posnr.

  PERFORM  dynpro  USING :
                   'X'  'SAPLV60P'         '4413',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'RV60A-SELKZ(01)'  'X',
                   ' '  'VDICS-ORFMNG(01)' g_bdc_t-remn_qty.

ENDFORM.                    " record_rtn
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_data USING pv_error.

  DATA : lv_cnt1 TYPE i. "선택한 라인 수
  DATA : lv_cnt2 TYPE i. "tool-auto 자재 라인 수
  DATA : BEGIN OF lt_fidno OCCURS 0,
           fidno TYPE ztefidno,
         END OF lt_fidno.

  CLEAR : g_itab_t, lv_cnt1, lv_cnt2, lt_fidno.
  REFRESH: lt_fidno.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  IF g_subrc IS NOT INITIAL.
    pv_error = 'X'.EXIT.
  ENDIF.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.

*___ 전체 선택 개수와 tool-auto 개수 확인
  LOOP AT g_itab_t WHERE chk = 'X'.

    lv_cnt1 = lv_cnt1 + 1.

    IF g_itab_t-matnr = 'TOOL-AUTO' AND g_itab_t-vkbur = '1800'.

      lv_cnt2 = lv_cnt2 + 1.

    ENDIF.

    lt_fidno-fidno = g_itab_t-fidno.
    APPEND lt_fidno.
    CLEAR: lt_fidno.

  ENDLOOP.

*___선택한 자재가 모두 'tool-auto'일 경우
  IF lv_cnt2 > 0 AND lv_cnt1 = lv_cnt2.

    CALL SCREEN 4000 STARTING AT 15 7 ENDING AT 80 12.

*___TOOL-AUTO 자재가 일반자재와 섞여 있을 경우
  ELSEIF lv_cnt2 > 0 AND lv_cnt1 NE lv_cnt2.

    MESSAGE e003(zsd1) WITH 'TOOL-AUTO 자재는 ' '다른 자재와 함께 '
                            'Billing 할 수 없습니다.'.
    pv_error = 'X'.

  ELSE.
  ENDIF.

*__4L 인 경우 환율 정보가 없는 경우
  CHECK p_local = '4L'.
  SORT lt_fidno BY fidno.
  DELETE ADJACENT DUPLICATES FROM lt_fidno COMPARING ALL FIELDS.
  DATA(lv_line) = lines( lt_fidno ).
  IF lv_line > 1.
    MESSAGE e001(zsd1) WITH '선택된 항목들의 F/D 문서 번호가 서로 다릅니다. 동일한 F/D 문서 번호를 가진 항목만 선택해 주십시오.' .
    pv_error = 'X'.
  ENDIF.

  CHECK pv_error IS INITIAL.

  LOOP AT g_itab_t WHERE chk = 'X'.
    IF g_itab_t-kursf IS INITIAL.
      MESSAGE e001(zsd1) WITH 'L/C 지정이 되지 않은 오더가 있습니다.'.
      pv_error = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_4000 OUTPUT.

  SET PF-STATUS '4000'.
  SET TITLEBAR '4000'.

ENDMODULE.                 " STATUS_4000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_4000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      PERFORM check_bkpf .
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      g_p_tax  =  0.
      gv_error = 'X'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_4000  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_bkpf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bkpf .

  DATA: lv_monat TYPE bkpf-monat.
  DATA: lv_belnr TYPE bkpf-belnr.

  CLEAR: lv_monat, lv_belnr, gv_error.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vbrk-zbelnr
    IMPORTING
      output = lv_belnr.

  SELECT SINGLE monat
    INTO lv_monat
    FROM bkpf
   WHERE bukrs = '3000'
     AND belnr = lv_belnr
     AND gjahr = vbrk-zgjahr.

  IF sy-subrc NE 0.
    gv_error = 'X'.
    MESSAGE s001(zsd1) DISPLAY LIKE 'E'
                               WITH '해당 전표를 확인할 수 없습니다.'.

  ELSEIF lv_monat NE pa_fkdat+4(2).
    gv_error = 'X'.
    MESSAGE s001(zsd1) DISPLAY LIKE 'E'
                             WITH '대금청구 월과 전표의 월이 다릅니다.'
                               .
  ELSE.
    gv_type = 'X'.
    gv_zbelnr = lv_belnr.
    gv_zgjahr = vbrk-zgjahr.
  ENDIF.

ENDFORM.                    " check_bkpf
*&---------------------------------------------------------------------*
*&      Form  UPDATE_VBRK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_MSG_T_MSGV1  text
*----------------------------------------------------------------------*
FORM update_vbrk  USING    p_g_msg_t_msgv1.

  UPDATE vbrk SET zgjahr = gv_zgjahr
                  zbelnr = gv_zbelnr
            WHERE vbeln  = p_g_msg_t_msgv1
*-> CCM : 18.04.2023 11:28:46 / ZLSGSD4
              AND draft  = space.
*<-

  IF sy-subrc NE 0.
    MESSAGE w002(zsd1) WITH '대금청구 문서 생성은 완료 되었으나, '
                            'VBRK 업데이트 중 오류가 발생하였습니다.'.
  ENDIF.

ENDFORM.                    " UPDATE_VBRK
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_NEXT_MONTH_INJECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transfer_next_month_injection .



ENDFORM.                    " TRANSFER_NEXT_MONTH_INJECTION
*&---------------------------------------------------------------------*
*& Form CALL_VF01_POD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_vf01_pod.

  DATA : ls_vbkok  TYPE vbkok,
         lt_vbpok  TYPE TABLE OF vbpok WITH HEADER LINE,
         lt_tvpod  TYPE TABLE OF tvpodvb WITH HEADER LINE,
         lt_itab   LIKE TABLE OF g_itab_t WITH NON-UNIQUE SORTED KEY
         k_key COMPONENTS vbeln,
         lt_filter LIKE TABLE OF gs_lip_sts WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln uecha,
         ls_1010   TYPE zgtsdt1010,
         lv_subrc  TYPE sy-subrc,
         lv_exec   TYPE sy-subrc,
         lv_time   TYPE sy-uzeit,
         lv_err,
         lv_chk,
         lv_posnr  TYPE posnr_vl,
         lv_posnn  TYPE posnr_vl,
         lv_qty    TYPE kwmeng,
         lv_rqty   TYPE kwmeng,
         lv_mblnr  TYPE mblnr,
         lv_msg    TYPE char100,
         lv_cnt    TYPE i.

  CLEAR gs_lip_sts. __cle : gt_lip_sts, gt_mblnr, gt_vbpok.
  SELECT b~vbeln, b~posnr, b~charg, lfimg, meins, b~vgbel, b~vgpos,
         a~fkstk, a~gbstk, a~pdstk, fksta, pdsta, kzpod, uecha
    FROM likp AS a INNER JOIN lips AS b
      ON a~vbeln = b~vbeln
     FOR ALL ENTRIES IN @gt_pod
   WHERE b~vbeln = @gt_pod-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_lip_sts.

  SORT gt_lip_sts BY vgpos posnr .
  DATA(lt_lip_sts) = gt_lip_sts[].
  DELETE lt_lip_sts WHERE lfimg = '0'.
  lt_filter[] = lt_lip_sts[].

  LOOP AT gt_pod.

**********************************************************************
    __cle : lt_vbpok, lt_tvpod. CLEAR ls_vbkok.

    ls_vbkok-vbeln_vl = gt_pod-vbeln.
    ls_vbkok-podat    = ls_vbkok-wadat_ist = pa_fkdat.
    ls_vbkok-kzpod    = 'B'.
    ls_vbkok-wabuc    = 'X'.
    ls_vbkok-potim    = lv_time = sy-timlo.

    CLEAR : lv_posnr, lv_rqty, lv_qty, lv_posnn.
    LOOP AT lt_lip_sts INTO DATA(ls_lip_sts) WHERE vbeln = gt_pod-vbeln.

      IF ls_lip_sts-uecha IS NOT INITIAL.
        SELECT SINGLE charg, meins, vbeln, posnr INTO @DATA(ls_lips)
          FROM lips
         WHERE vbeln = @ls_lip_sts-vbeln
           AND posnr = @ls_lip_sts-uecha.
      ELSE.
        SELECT SINGLE charg, meins, vbeln, posnr INTO @ls_lips
          FROM lips
         WHERE vbeln = @ls_lip_sts-vbeln
           AND posnr = @ls_lip_sts-posnr.
      ENDIF.

      IF lv_posnn NE ls_lips-posnr.
        lv_posnn = ls_lips-posnr.
        CLEAR : lv_rqty, lv_qty.
      ENDIF.

      CLEAR : lt_vbpok, g_itab_t, lv_exec, lv_chk.
      READ TABLE g_itab_t WITH KEY vbeln = ls_lips-vbeln
                                   posnr = ls_lips-posnr
                                   pod   = |X|.
      lv_subrc = sy-subrc.

      READ TABLE gt_log INTO DATA(ls_log) WITH KEY vbeln = ls_lips-vbeln
                                                   posnr = ls_lips-posnr
                                                   posnn = ls_lip_sts-posnr
                                                   charg = ls_lip_sts-charg.
      IF sy-subrc = 0.
        lv_exec = 4.
      ENDIF.

      IF lv_subrc NE 0.
        lv_exec = 4.
      ENDIF.

      DATA(lt_tmp) = FILTER #( lt_filter USING KEY k_key WHERE vbeln = ls_lips-vbeln
                                                           AND uecha = ls_lips-posnr ).
      IF lines( lt_tmp ) >  1.
        lv_chk = |X|.
      ENDIF.

      IF lv_chk = |X|.

        IF lv_exec IS INITIAL.

          lv_rqty = ( g_itab_t-remn_qty - lv_qty ) - ls_lip_sts-lfimg.
          ADD ls_lip_sts-lfimg TO lv_qty.

          MOVE-CORRESPONDING g_itab_t TO lt_vbpok.
          lt_vbpok-pikmg    = g_itab_t-lfimg.

          IF lv_rqty >= 0.
            IF g_itab_t-remn_qty >= ls_lip_sts-lfimg.
              lt_vbpok-pikmg = ls_lip_sts-lfimg.
              lt_vbpok-lfimg = ls_lip_sts-lfimg.
              lt_vbpok-lgmng = ls_lip_sts-lfimg.
            ELSE.
              lt_vbpok-lfimg = g_itab_t-remn_qty.
              lt_vbpok-lgmng = g_itab_t-remn_qty.
            ENDIF.
            lt_vbpok-charg = ls_lip_sts-charg.
          ELSE.
            CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng, lt_vbpok-charg.
          ENDIF.

        ELSE.
          CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng, lt_vbpok-charg.
        ENDIF.

      ELSE.

        IF lv_subrc = 0.
          MOVE-CORRESPONDING g_itab_t TO lt_vbpok.
          lt_vbpok-pikmg    = g_itab_t-lfimg.
          lt_vbpok-lfimg    = g_itab_t-remn_qty.
          lt_vbpok-lgmng    = g_itab_t-remn_qty.
        ELSE.
          CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng.
        ENDIF.

      ENDIF.

      lt_vbpok-vbeln_vl = ls_lip_sts-vbeln.
      lt_vbpok-posnr_vl = ls_lip_sts-posnr.
      lt_vbpok-vbeln    = ls_lip_sts-vbeln.
      lt_vbpok-posnn    = ls_lip_sts-posnr.
      lt_vbpok-lianp = 'X'.
      lt_vbpok-kzpod = 'B'.

      CLEAR lt_vbpok-matnr.
      APPEND lt_vbpok.

      CLEAR lt_vbpok.

      CLEAR lt_tvpod.
      lt_tvpod-vbeln = ls_lip_sts-vbeln.
      lt_tvpod-posnr = ls_lip_sts-posnr.
      lt_tvpod-grund = |DFG2|.

      IF lv_chk = |X|.
        IF lv_exec IS INITIAL.
          IF lv_rqty >= 0.

            IF g_itab_t-remn_qty >= ls_lip_sts-lfimg.
              lt_tvpod-lfimg_diff = ls_lip_sts-lfimg - ls_lip_sts-lfimg.
              lt_tvpod-lgmng_diff = ls_lip_sts-lfimg - ls_lip_sts-lfimg.
              lt_tvpod-podmg = ls_lip_sts-lfimg.
            ELSE.
              lt_tvpod-lfimg_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
              lt_tvpod-lgmng_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
              lt_tvpod-podmg = g_itab_t-remn_qty.
            ENDIF.

          ELSE.
            CLEAR lt_tvpod-podmg.
            lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
            lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
            lt_tvpod-podmg = 0.
          ENDIF.
        ELSE.
          CLEAR lt_tvpod-podmg.
          lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
          lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
        ENDIF.

      ELSE.
        IF lv_subrc = 0.
          lt_tvpod-lfimg_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
          lt_tvpod-lgmng_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
          lt_tvpod-podmg = g_itab_t-remn_qty.
        ELSE.
          CLEAR lt_tvpod-podmg.
          lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
          lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
        ENDIF.
      ENDIF.

      lt_tvpod-vrkme = lt_tvpod-meins = ls_lip_sts-meins.
      APPEND lt_tvpod. CLEAR lt_tvpod.

    ENDLOOP.

    PERFORM update_stat USING gt_pod-vgbel gt_pod-vgpos 'VL'.

    gt_vbpok[] = lt_vbpok[].
    CLEAR lv_msg.
    CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
      EXPORTING
        vbkok_wa        = ls_vbkok
        synchron        = 'X'
        commit          = 'X'
        delivery        = gt_pod-vbeln
        nicht_sperren_1 = 'Y'
      TABLES
        vbpok_tab       = lt_vbpok
        tvpod_tab       = lt_tvpod
      EXCEPTIONS
        error_message   = 0 lv_msg.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      CLEAR : lv_mblnr, gs_lock.
      gs_lock-vbeva = gt_pod-vgbel.
      PERFORM doc_lock USING 'ZGTSDR0120'.

      DO 10 TIMES.
        WITH +vbfa AS ( SELECT vbeln, posnv, vbelv
                          FROM vbfa
                         WHERE bwart = '601'
                           AND vbelv = @gt_pod-vbeln
                           AND erdat = @sy-datlo
                           AND vbeln = ( SELECT MAX( vbeln ) FROM vbfa
                                          WHERE vbelv = @gt_pod-vbeln
                                            AND bwart = '601'
                                            AND erdat = @sy-datlo ) ),
             +mseg AS ( SELECT smbln, vbeln_im, mblnr
                          FROM mseg
                         WHERE bwart = '602'
                           AND vbeln_im = @gt_pod-vbeln )
        SELECT SINGLE b~vbeln , c~smbln, mblnr
          FROM @gt_vbpok AS a INNER JOIN +vbfa AS b
            ON a~vbeln_vl = b~vbelv
           AND a~posnr_vl = b~posnv
          LEFT OUTER JOIN +mseg AS c
*            ON B~VBELV = C~VBELN_IM
           ON b~vbeln = c~smbln
          INTO @DATA(ls_mblnr).
        IF ls_mblnr-mblnr IS NOT INITIAL.
          CLEAR lv_mblnr.
        ELSE.
          lv_mblnr = ls_mblnr-vbeln.
        ENDIF.

        IF lv_mblnr IS INITIAL.
          WAIT UP TO '0.3' SECONDS.
        ELSE.
          SELECT SINGLE mandt INTO @sy-mandt
            FROM zgtsdt1010
           WHERE mblnr = @lv_mblnr "로그에 해당 번호가있는지 검색
             AND loekz = @space.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CLEAR lv_mblnr.
          ENDIF.
        ENDIF.
      ENDDO.

*      IF lv_mblnr IS INITIAL.
*        g_err = 'X'. EXIT.
*      ELSE.
*        gt_mblnr-vbeln = gt_pod-vbeln.
*        gt_mblnr-mblnr = lv_mblnr.
*        APPEND gt_mblnr. CLEAR gt_mblnr.
*      ENDIF.

      " [수정] 개별 납품 처리 중 실패 시 전체 EXIT 대신 해당 건 스킵 및 개별 취소
*START CHM2608-00034 부스닥트 POD 프로세스 개선 요청
      IF lv_mblnr IS INITIAL.
        g_err = 'X'.

* 1. 현재 실패한 건 로그/상태 기록
        APPEND ls_pod_err TO lt_pod_err.

* 2. 이 건만 즉시 602 역분개(취소) 태우기
*      PERFORM create_single_pod_602 USING gt_pod-vbeln
*                                                   CHANGING lv_single_err.

* 3. 상태 롤백 (이 건에 대한 LIKP/LIPS 변경분 원복)
        PERFORM roll_back_single_status USING ls_pod_err-vbeln.

* 4. 메인 루프 다음 건으로 스킵
        CONTINUE.

      ELSE.
        gt_mblnr-vbeln = gt_pod-vbeln.
        gt_mblnr-mblnr = lv_mblnr.
        APPEND gt_mblnr. CLEAR gt_mblnr.
      ENDIF.
*END CHM2608-00034 부스닥트 POD 프로세스 개선 요청

    ELSE.

*      g_err = 'X'. EXIT.
      g_err = 'X'.
      CONTINUE.

    ENDIF.

**********************************************************************
*LOG 생성
**********************************************************************
    IF lv_mblnr IS NOT INITIAL.

      gt_pod-mblnr  = lv_mblnr.

      LOOP AT gt_lip_sts INTO ls_lip_sts WHERE vbeln = gt_pod-vbeln.
        CLEAR ls_1010.

        IF ls_lip_sts-uecha IS NOT INITIAL.
          lv_posnr = ls_lip_sts-uecha.
        ELSE.
          lv_posnr = ls_lip_sts-posnr.
        ENDIF.

        READ TABLE g_itab_t WITH KEY vbeln = ls_lip_sts-vbeln
                                     posnr = lv_posnr
                                     pod  = |X|.
        IF sy-subrc = 0.
          READ TABLE gt_vbpok INTO DATA(ls_chk) WITH KEY posnr_vl = ls_lip_sts-posnr
                                                            charg = ls_lip_sts-charg.
          CHECK sy-subrc = 0.

          MOVE-CORRESPONDING ls_lip_sts TO ls_1010.
          ls_1010-mblnr = gt_pod-mblnr.
          ls_1010-lfimg = ls_lip_sts-lfimg.
          ls_1010-posnr = g_itab_t-posnr.
          ls_1010-posnn = ls_lip_sts-posnr.
          ls_1010-charg = ls_lip_sts-charg.
          ls_1010-kwmeng = g_itab_t-kwmeng.
          ls_1010-vrkme = g_itab_t-vrkme.
          ls_1010-podat = pa_fkdat.
          ls_1010-bwart = |601|.
          CLEAR ls_1010-vbeln_vf.
          zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_c
                                           CHANGING cs_timestamp = ls_1010-timestamp ).
          MODIFY zgtsdt1010 FROM ls_1010.
          COMMIT WORK.
          ls_lip_sts-mblnr = gt_pod-mblnr.
        ENDIF.

        MODIFY gt_pod.
        MODIFY gt_lip_sts FROM ls_lip_sts.
      ENDLOOP.

    ENDIF.
**********************************************************************
    CLEAR lv_mblnr.

  ENDLOOP.

*START CHM2608-00034 부스닥트 POD 프로세스 개선 요청
**********************************************************************
* 빌링  " 성공한 건들만 모아서 빌링 진행
**********************************************************************
  IF gt_pod[] IS NOT INITIAL AND gt_mblnr[] IS NOT INITIAL.

    " gt_mblnr(성공 목록)에 없는 건들은 gt_pod에서 날려버림
    LOOP AT gt_pod INTO DATA(ls_pod_chk).
      READ TABLE gt_mblnr WITH KEY vbeln = ls_pod_chk-vbeln TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        DELETE gt_pod.
      ENDIF.
    ENDLOOP.

    IF gt_pod[] IS NOT INITIAL.
      PERFORM create_vf.
    ENDIF.

*END CHM2608-00034 부스닥트 POD 프로세스 개선 요청
**********************************************************************
  ELSE.

    CONCATENATE  '출고중 에러가 발생 했습니다.' '(' gt_pod-vbeln ')'
           INTO  g_mesg SEPARATED BY space.

    DATA(lt_ul) = g_itab_t[].
    DELETE lt_ul WHERE chk IS INITIAL.
    SORT lt_ul BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING vgbel.
    LOOP AT lt_ul INTO DATA(ls_ul).
      CLEAR : gs_lock.
      gs_lock-vbeva = ls_ul-vgbel.
      PERFORM doc_unlock USING 'ZGTSDR0120'.
    ENDLOOP.

**********************************************************************
**601문서 생성중 에러가 있을경우 전체 다 취소 한다.
**********************************************************************
*    PERFORM create_pod_602 USING lv_err.
**********************************************************************
*이전 상태
**********************************************************************
*    PERFORM roll_back_status .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_VF01_POD_1
*&---------------------------------------------------------------------*
*& 소스 백업용 기존 로직을 복사해서 둔다.
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_vf01_pod_1.

  DATA : ls_vbkok  TYPE vbkok,
         lt_vbpok  TYPE TABLE OF vbpok WITH HEADER LINE,
         lt_tvpod  TYPE TABLE OF tvpodvb WITH HEADER LINE,
         lt_itab   LIKE TABLE OF g_itab_t WITH NON-UNIQUE SORTED KEY
         k_key COMPONENTS vbeln,
         lt_filter LIKE TABLE OF gs_lip_sts WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln uecha,
         ls_1010   TYPE zgtsdt1010,
         lv_subrc  TYPE sy-subrc,
         lv_exec   TYPE sy-subrc,
         lv_time   TYPE sy-uzeit,
         lv_err,
         lv_chk,
         lv_posnr  TYPE posnr_vl,
         lv_posnn  TYPE posnr_vl,
         lv_qty    TYPE kwmeng,
         lv_rqty   TYPE kwmeng,
         lv_mblnr  TYPE mblnr,
         lv_msg    TYPE char100,
         lv_cnt    TYPE i.

  CLEAR gs_lip_sts. __cle : gt_lip_sts, gt_mblnr, gt_vbpok.
  SELECT b~vbeln, b~posnr, b~charg, lfimg, meins, b~vgbel, b~vgpos,
         a~fkstk, a~gbstk, a~pdstk, fksta, pdsta, kzpod, uecha
    FROM likp AS a INNER JOIN lips AS b
      ON a~vbeln = b~vbeln
     FOR ALL ENTRIES IN @gt_pod
   WHERE b~vbeln = @gt_pod-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_lip_sts.

  SORT gt_lip_sts BY vgpos posnr .
  DATA(lt_lip_sts) = gt_lip_sts[].
  DELETE lt_lip_sts WHERE lfimg = '0'.
  lt_filter[] = lt_lip_sts[].

  LOOP AT gt_pod.

**********************************************************************
    __cle : lt_vbpok, lt_tvpod. CLEAR ls_vbkok.

    ls_vbkok-vbeln_vl = gt_pod-vbeln.
    ls_vbkok-podat    = ls_vbkok-wadat_ist = pa_fkdat.
    ls_vbkok-kzpod    = 'B'.
    ls_vbkok-wabuc    = 'X'.
    ls_vbkok-potim    = lv_time = sy-timlo.

    CLEAR : lv_posnr, lv_rqty, lv_qty, lv_posnn.
    LOOP AT lt_lip_sts INTO DATA(ls_lip_sts) WHERE vbeln = gt_pod-vbeln.

      IF ls_lip_sts-uecha IS NOT INITIAL.
        SELECT SINGLE charg, meins, vbeln, posnr INTO @DATA(ls_lips)
          FROM lips
         WHERE vbeln = @ls_lip_sts-vbeln
           AND posnr = @ls_lip_sts-uecha.
      ELSE.
        SELECT SINGLE charg, meins, vbeln, posnr INTO @ls_lips
          FROM lips
         WHERE vbeln = @ls_lip_sts-vbeln
           AND posnr = @ls_lip_sts-posnr.
      ENDIF.

      IF lv_posnn NE ls_lips-posnr.
        lv_posnn = ls_lips-posnr.
        CLEAR : lv_rqty, lv_qty.
      ENDIF.

      CLEAR : lt_vbpok, g_itab_t, lv_exec, lv_chk.
      READ TABLE g_itab_t WITH KEY vbeln = ls_lips-vbeln
                                   posnr = ls_lips-posnr
                                   pod   = |X|.
      lv_subrc = sy-subrc.

      READ TABLE gt_log INTO DATA(ls_log) WITH KEY vbeln = ls_lips-vbeln
                                                   posnr = ls_lips-posnr
                                                   posnn = ls_lip_sts-posnr
                                                   charg = ls_lip_sts-charg.
      IF sy-subrc = 0.
        lv_exec = 4.
      ENDIF.

      IF lv_subrc NE 0.
        lv_exec = 4.
      ENDIF.

      DATA(lt_tmp) = FILTER #( lt_filter USING KEY k_key WHERE vbeln = ls_lips-vbeln
                                                           AND uecha = ls_lips-posnr ).
      IF lines( lt_tmp ) >  1.
        lv_chk = |X|.
      ENDIF.

      IF lv_chk = |X|.

        IF lv_exec IS INITIAL.

          lv_rqty = ( g_itab_t-remn_qty - lv_qty ) - ls_lip_sts-lfimg.
          ADD ls_lip_sts-lfimg TO lv_qty.

          MOVE-CORRESPONDING g_itab_t TO lt_vbpok.
          lt_vbpok-pikmg    = g_itab_t-lfimg.

          IF lv_rqty >= 0.
            IF g_itab_t-remn_qty >= ls_lip_sts-lfimg.
              lt_vbpok-pikmg = ls_lip_sts-lfimg.
              lt_vbpok-lfimg = ls_lip_sts-lfimg.
              lt_vbpok-lgmng = ls_lip_sts-lfimg.
            ELSE.
              lt_vbpok-lfimg = g_itab_t-remn_qty.
              lt_vbpok-lgmng = g_itab_t-remn_qty.
            ENDIF.
            lt_vbpok-charg = ls_lip_sts-charg.
          ELSE.
            CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng, lt_vbpok-charg.
          ENDIF.

        ELSE.
          CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng, lt_vbpok-charg.
        ENDIF.

      ELSE.

        IF lv_subrc = 0.
          MOVE-CORRESPONDING g_itab_t TO lt_vbpok.
          lt_vbpok-pikmg    = g_itab_t-lfimg.
          lt_vbpok-lfimg    = g_itab_t-remn_qty.
          lt_vbpok-lgmng    = g_itab_t-remn_qty.
        ELSE.
          CLEAR : lt_vbpok-pikmg, lt_vbpok-lfimg, lt_vbpok-lgmng.
        ENDIF.

      ENDIF.

      lt_vbpok-vbeln_vl = ls_lip_sts-vbeln.
      lt_vbpok-posnr_vl = ls_lip_sts-posnr.
      lt_vbpok-vbeln    = ls_lip_sts-vbeln.
      lt_vbpok-posnn    = ls_lip_sts-posnr.
      lt_vbpok-lianp = 'X'.
      lt_vbpok-kzpod = 'B'.

      CLEAR lt_vbpok-matnr.
      APPEND lt_vbpok.

      CLEAR lt_vbpok.

      CLEAR lt_tvpod.
      lt_tvpod-vbeln = ls_lip_sts-vbeln.
      lt_tvpod-posnr = ls_lip_sts-posnr.
      lt_tvpod-grund = |DFG2|.

      IF lv_chk = |X|.
        IF lv_exec IS INITIAL.
          IF lv_rqty >= 0.

            IF g_itab_t-remn_qty >= ls_lip_sts-lfimg.
              lt_tvpod-lfimg_diff = ls_lip_sts-lfimg - ls_lip_sts-lfimg.
              lt_tvpod-lgmng_diff = ls_lip_sts-lfimg - ls_lip_sts-lfimg.
              lt_tvpod-podmg = ls_lip_sts-lfimg.
            ELSE.
              lt_tvpod-lfimg_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
              lt_tvpod-lgmng_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
              lt_tvpod-podmg = g_itab_t-remn_qty.
            ENDIF.

          ELSE.
            CLEAR lt_tvpod-podmg.
            lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
            lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
            lt_tvpod-podmg = 0.
          ENDIF.
        ELSE.
          CLEAR lt_tvpod-podmg.
          lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
          lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
        ENDIF.

      ELSE.
        IF lv_subrc = 0.
          lt_tvpod-lfimg_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
          lt_tvpod-lgmng_diff = g_itab_t-lfimg - g_itab_t-remn_qty.
          lt_tvpod-podmg = g_itab_t-remn_qty.
        ELSE.
          CLEAR lt_tvpod-podmg.
          lt_tvpod-lfimg_diff = ls_lip_sts-lfimg.
          lt_tvpod-lgmng_diff = ls_lip_sts-lfimg.
        ENDIF.
      ENDIF.

      lt_tvpod-vrkme = lt_tvpod-meins = ls_lip_sts-meins.
      APPEND lt_tvpod. CLEAR lt_tvpod.

    ENDLOOP.

    PERFORM update_stat USING gt_pod-vgbel gt_pod-vgpos 'VL'.

    gt_vbpok[] = lt_vbpok[].
    CLEAR lv_msg.
    CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
      EXPORTING
        vbkok_wa        = ls_vbkok
        synchron        = 'X'
        commit          = 'X'
        delivery        = gt_pod-vbeln
        nicht_sperren_1 = 'Y'
      TABLES
        vbpok_tab       = lt_vbpok
        tvpod_tab       = lt_tvpod
      EXCEPTIONS
        error_message   = 0 lv_msg.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      CLEAR : lv_mblnr, gs_lock.
      gs_lock-vbeva = gt_pod-vgbel.
      PERFORM doc_lock USING 'ZGTSDR0120'.

      DO 10 TIMES.
        WITH +vbfa AS ( SELECT vbeln, posnv, vbelv
                          FROM vbfa
                         WHERE bwart = '601'
                           AND vbelv = @gt_pod-vbeln
                           AND erdat = @sy-datlo
                           AND vbeln = ( SELECT MAX( vbeln ) FROM vbfa
                                          WHERE vbelv = @gt_pod-vbeln
                                            AND bwart = '601'
                                            AND erdat = @sy-datlo ) ),
             +mseg AS ( SELECT smbln, vbeln_im, mblnr
                          FROM mseg
                         WHERE bwart = '602'
                           AND vbeln_im = @gt_pod-vbeln )
        SELECT SINGLE b~vbeln , c~smbln, mblnr
          FROM @gt_vbpok AS a INNER JOIN +vbfa AS b
            ON a~vbeln_vl = b~vbelv
           AND a~posnr_vl = b~posnv
          LEFT OUTER JOIN +mseg AS c
*            ON B~VBELV = C~VBELN_IM
           ON b~vbeln = c~smbln
          INTO @DATA(ls_mblnr).
        IF ls_mblnr-mblnr IS NOT INITIAL.
          CLEAR lv_mblnr.
        ELSE.
          lv_mblnr = ls_mblnr-vbeln.
        ENDIF.

        IF lv_mblnr IS INITIAL.
          WAIT UP TO '0.3' SECONDS.
        ELSE.
          SELECT SINGLE mandt INTO @sy-mandt
            FROM zgtsdt1010
           WHERE mblnr = @lv_mblnr "로그에 해당 번호가있는지 검색
             AND loekz = @space.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CLEAR lv_mblnr.
          ENDIF.
        ENDIF.
      ENDDO.

      IF lv_mblnr IS INITIAL.
        g_err = 'X'. EXIT.
      ELSE.
        gt_mblnr-vbeln = gt_pod-vbeln.
        gt_mblnr-mblnr = lv_mblnr.
        APPEND gt_mblnr. CLEAR gt_mblnr.
      ENDIF.

    ELSE.

      g_err = 'X'. EXIT.

    ENDIF.

**********************************************************************
*LOG 생성
**********************************************************************
    IF lv_mblnr IS NOT INITIAL.

      gt_pod-mblnr  = lv_mblnr.
      LOOP AT gt_lip_sts INTO ls_lip_sts WHERE vbeln = gt_pod-vbeln.
        CLEAR ls_1010.

        IF ls_lip_sts-uecha IS NOT INITIAL.
          lv_posnr = ls_lip_sts-uecha.
        ELSE.
          lv_posnr = ls_lip_sts-posnr.
        ENDIF.

        READ TABLE g_itab_t WITH KEY vbeln = ls_lip_sts-vbeln
                                     posnr = lv_posnr
                                     pod  = |X|.
        IF sy-subrc = 0.
          READ TABLE gt_vbpok INTO DATA(ls_chk) WITH KEY posnr_vl = ls_lip_sts-posnr
                                                            charg = ls_lip_sts-charg.
          CHECK sy-subrc = 0.

          MOVE-CORRESPONDING ls_lip_sts TO ls_1010.
          ls_1010-mblnr = gt_pod-mblnr.
          ls_1010-lfimg = ls_lip_sts-lfimg.
          ls_1010-posnr = g_itab_t-posnr.
          ls_1010-posnn = ls_lip_sts-posnr.
          ls_1010-charg = ls_lip_sts-charg.
          ls_1010-kwmeng = g_itab_t-kwmeng.
          ls_1010-vrkme = g_itab_t-vrkme.
          ls_1010-podat = pa_fkdat.
          ls_1010-bwart = |601|.
          CLEAR ls_1010-vbeln_vf.
          zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_c
                                           CHANGING cs_timestamp = ls_1010-timestamp ).
          MODIFY zgtsdt1010 FROM ls_1010.
          COMMIT WORK.
          ls_lip_sts-mblnr = gt_pod-mblnr.
        ENDIF.

        MODIFY gt_pod.
        MODIFY gt_lip_sts FROM ls_lip_sts.
      ENDLOOP.

    ENDIF.
**********************************************************************
    CLEAR lv_mblnr.

  ENDLOOP.

**********************************************************************
* 빌링  "전체 성공후 빌링
**********************************************************************
  IF g_err IS INITIAL.

    PERFORM create_vf.

**********************************************************************
  ELSE.

    CONCATENATE  '출고중 에러가 발생 했습니다.' '(' gt_pod-vbeln ')'
           INTO  g_mesg SEPARATED BY space.

    DATA(lt_ul) = g_itab_t[].
    DELETE lt_ul WHERE chk IS INITIAL.
    SORT lt_ul BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING vgbel.
    LOOP AT lt_ul INTO DATA(ls_ul).
      CLEAR : gs_lock.
      gs_lock-vbeva = ls_ul-vgbel.
      PERFORM doc_unlock USING 'ZGTSDR0120'.
    ENDLOOP.

**********************************************************************
**601문서 생성중 에러가 있을경우 전체 다 취소 한다.
**********************************************************************
    PERFORM create_pod_602 USING lv_err.
**********************************************************************
*이전 상태
**********************************************************************
    PERFORM roll_back_status .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&      --> G_ITAB_T_POSNR
*&---------------------------------------------------------------------*
FORM update_stat  USING pv_vbeln_vl pv_posnr pv_type.

  DATA : lv_posnr TYPE posnr,
         lv_fksta TYPE char1,
         lv_gbsta TYPE char1,
         lv_pdsta TYPE char1.

  SELECT SINGLE vbeln INTO @DATA(lv_vbeln) FROM lips WHERE vgbel = @pv_vbeln_vl.

  CASE pv_type.
    WHEN 'VL'.

      UPDATE likp
         SET fkstk = 'A'
             gbstk = 'B'
             pdstk = 'B'
       WHERE vbeln = lv_vbeln.

      UPDATE lips
         SET fksta = 'A'
             gbsta = 'B'
             pdsta = 'B'
       WHERE vgbel = pv_vbeln_vl.
*         AND VGPOS = PV_POSNR.

    WHEN 'VF'.

      LOOP AT gt_lip_sts INTO DATA(ls_sts) WHERE vbeln = pv_vbeln_vl
                                             AND lfimg > 0.
        IF ls_sts-uecha IS NOT INITIAL.
          lv_posnr = ls_sts-uecha.
        ELSE.
          lv_posnr = ls_sts-posnr.
        ENDIF.

        UPDATE likp
           SET fkstk = 'A'
               gbstk = 'B'
               pdstk = 'C'
         WHERE vbeln = ls_sts-vbeln.

        READ TABLE g_itab_t WITH KEY vbeln = ls_sts-vbeln
                                     posnr = lv_posnr
                                     pod  = |X|.
        IF sy-subrc = 0.
          lv_fksta = 'A'.
          lv_gbsta = 'B'.
          lv_pdsta = 'C'.
        ELSE.
          lv_fksta = 'C'.
          lv_gbsta = 'C'.
          lv_pdsta = 'C'.
        ENDIF.

        UPDATE lips
           SET gbsta = lv_gbsta
               pdsta = lv_pdsta
               fksta = lv_fksta
         WHERE vbeln = ls_sts-vbeln
           AND posnr = lv_posnr.

*빌링 상태 업데이트는 선택된 항번으로만 업데이트 한다.
        IF ls_sts-uecha IS NOT INITIAL.
          UPDATE lips
             SET fksta = space
                 gbsta = lv_gbsta
           WHERE vbeln = ls_sts-vbeln
             AND posnr = ls_sts-posnr.
        ENDIF.

      ENDLOOP.

    WHEN 'F_VL'.  ""빌링후 잔량이 있으면 출고 가능한 상태로 변경

      UPDATE likp
         SET fkstk = 'B'
             gbstk = 'B'
             pdstk = 'B'
             wbstk = 'C'
       WHERE vbeln = pv_vbeln_vl.

      UPDATE lips
         SET fksta = 'B'
             gbsta = 'B'
             pdsta = 'B'
             wbsta = 'C'
       WHERE vbeln = pv_vbeln_vl
         AND posnr = pv_posnr.

    WHEN 'F_VL2'.  ""부분 완료일경우 WBSTK, WBSTA  = C

      UPDATE likp
         SET fkstk = 'B'
             gbstk = 'B'
             pdstk = 'B'
             wbstk = 'C'
       WHERE vbeln = pv_vbeln_vl.

      UPDATE lips
         SET fksta = 'C'
             gbsta = 'C'
             pdsta = 'B'
             wbsta = 'C'
       WHERE vbeln = pv_vbeln_vl
         AND posnr = pv_posnr.

    WHEN 'FN'.  "최종 완료

      UPDATE likp
         SET fkstk = 'C'
             gbstk = 'C'
             pdstk = 'C'
       WHERE vbeln = pv_vbeln_vl.

      UPDATE lips
         SET fksta = 'C'
             gbsta = 'C'
             pdsta = 'C'
       WHERE vbeln = pv_vbeln_vl.

    WHEN '602'.

      UPDATE likp
         SET fkstk = 'A'
             gbstk = 'B'
             pdstk = 'B'
       WHERE vbeln = pv_vbeln_vl.

      UPDATE lips
         SET fksta = 'A'
             gbsta = 'B'
             pdsta = 'B'
             kzpod = 'A'
       WHERE vbeln = pv_vbeln_vl.

  ENDCASE.

  COMMIT WORK AND WAIT. "WAIT UP TO 1 SECONDS.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_VF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_vf.

  DATA : ls_result    TYPE mb5sit,
         lt_itab      LIKE TABLE OF g_itab_t WITH NON-UNIQUE SORTED KEY
         k_key COMPONENTS vbeln,
         ls_1010      TYPE zgtsdt1010,
         lv_podmg     TYPE tvpod-podmg,
         l_vbeln      TYPE vbeln_vf,
         lv_posnr     TYPE posnr,
         lv_exec,
         lv_chk,
         lv_err,
         l_maechul,
         lv_cnt       TYPE i,
         lv_cnt2      TYPE i,
         lv_cnt3      TYPE i,
         lv_mod       TYPE i,
         lv_tcnt      TYPE i,
         lv_kursf(16).

  DATA : BEGIN OF lt_tvpod OCCURS 0,
           vbeln     TYPE tvpod-vbeln,
           posnr     TYPE tvpod-posnr,
           podmg     TYPE tvpod-podmg,
           podmg_lme TYPE tvpod-podmg_lme,
         END OF lt_tvpod.

  DATA : lt_billing TYPE TABLE OF bapivbrk,
         lt_return  TYPE TABLE OF bapiret1,
         lt_success TYPE TABLE OF bapivbrksuccess.

   DATA: l_line TYPE i.

  l_maechul  =  'X'.
  EXPORT l_maechul TO MEMORY ID 'ZSD013'.
  SORT gt_lip_sts BY vgpos posnr.

*청구분할별 빌링문서 생성
  DATA(lt_do) = gt_pod[].
  SORT lt_do BY ztext.
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING ztext.

  LOOP AT lt_do INTO DATA(ls_do).

    CLEAR : bdctab, g_msg_t, g_cnt, g_mesg, lv_cnt, lv_cnt2.
    REFRESH : bdctab, g_msg_t.

    DATA(lt_lip_sts) = gt_lip_sts[].
    DELETE lt_lip_sts WHERE lfimg = '0'.
    DATA(lt_lip) = gt_lip_sts[].
    SORT lt_lip BY vbeln ASCENDING posnr ASCENDING.
    DELETE lt_lip WHERE uecha IS NOT INITIAL.
*    DELETE ADJACENT DUPLICATES FROM LT_LIP COMPARING VBELN.

    PERFORM  dynpro  USING :
                  'X'  'SAPMV60A'         '0102'.

    LOOP AT gt_pod WHERE ztext = ls_do-ztext.

      ADD 1 TO lv_cnt.
      ADD 1 TO lv_cnt2.
      ADD 1 TO  lv_cnt3.
**********************************************************************
*N차 VF 일때는 TVPOD 10 항목 PODMG_LME PODMG 수량 SUM UPDATE 후 BDC 실행 한다.
**********************************************************************
      LOOP AT lt_lip INTO DATA(ls_lip) WHERE vbeln = gt_pod-vbeln.

        READ TABLE g_itab_t WITH KEY vbeln = ls_lip-vbeln
                                     posnr = ls_lip-posnr
                                     pod  = |X|.
        CHECK sy-subrc = 0.

*수량 업데이트 실패
        SELECT vbeln, posnr, podmg, podmg_lme  " 롤백 데이터
          FROM tvpod
         WHERE vbeln = @ls_lip-vbeln
           AND posnr = @ls_lip-posnr
     APPENDING CORRESPONDING FIELDS OF TABLE @lt_tvpod.

        CLEAR : lv_posnr, lv_podmg, lv_exec.
        LOOP AT lt_lip_sts INTO DATA(ls_lip_sts) WHERE vbeln = ls_lip-vbeln.

          IF ls_lip_sts-uecha IS NOT INITIAL.
            lv_posnr = ls_lip_sts-uecha.
          ELSE.
            lv_posnr = ls_lip_sts-posnr.
          ENDIF.

          CHECK lv_posnr = ls_lip-posnr.

          READ TABLE gt_vbpok INTO DATA(ls_tmp) WITH KEY vbeln_vl = ls_lip_sts-vbeln
                                                         posnr_vl = ls_lip_sts-posnr
                                                         charg    = ls_lip_sts-charg.
          IF sy-subrc = 0.
            lv_exec = |X|.
          ENDIF.

          CLEAR ls_result.
          PERFORM call_mb5sit_gi2 USING gt_pod-vbeln
                                        ls_lip_sts-posnr
                               CHANGING ls_result.

          lv_podmg = lv_podmg + ( ls_lip_sts-lfimg - ls_result-sit_gi ).
          IF lv_podmg < 0.
            lv_podmg = 0.
          ENDIF.

          ls_lip_sts-mblnr = gt_pod-mblnr.
          MODIFY lt_lip_sts FROM ls_lip_sts.
        ENDLOOP.

        UPDATE tvpod
           SET podmg     = lv_podmg
               podmg_lme = lv_podmg
         WHERE vbeln = ls_lip-vbeln
           AND posnr = ls_lip-posnr.
        COMMIT WORK AND WAIT.

      ENDLOOP.
**********************************************************************

      PERFORM update_stat USING gt_pod-vbeln gt_pod-posnr 'VF'.
      DATA(lv_text) = |KOMFK-VBELN(| && lv_cnt && |)|.
      PERFORM  dynpro  USING :
                    ' '  lv_text   gt_pod-vbeln.
      IF lv_cnt = 14.
        lv_cnt = 1.
        lv_cnt2 = 0.
        PERFORM  dynpro  USING :
                      ' '  'BDC_OKCODE'       '=FKAN'.
        PERFORM  dynpro  USING :
                      'X'  'SAPMV60A'         '0102'.
      ENDIF.
    ENDLOOP.

    IF p_local = '4L'.
      CLEAR: lv_kursf.
      lv_kursf = gt_pod-kursf.
      CONDENSE lv_kursf NO-GAPS.
      PERFORM  dynpro  USING :
                  ' '  'BDC_OKCODE'        '=UEBK'.
      PERFORM  dynpro  USING :
           'X'  'SAPMV60A'         '9000',
           ' '  'BDC_OKCODE'       '=FKVW',
           ' '  'GV_KURSK'         lv_kursf.

    ELSE.
      PERFORM  dynpro  USING :
                  ' '  'BDC_OKCODE'        '=FKAN'.

      IF  lv_cnt3 <> 1.
        PERFORM  dynpro  USING :
                    'X'  'SAPMV60A'         '0102',
                    ' '  'BDC_OKCODE'       '=FAKT'.
      ENDIF.
    ENDIF.


*    PERFORM  DYNPRO  USING :
*                  'X'  'SAPMV60A'         '0104',
*                  ' '  'BDC_OKCODE'       '=BACK'.


    PERFORM  dynpro  USING :
                  'X'  'SAPMV60A'         '0104',
                  ' '  'BDC_OKCODE'       '=SICH'.

    ctu_params-dismode  =  pa_imode.
    ctu_params-updmode  =  'S'.
    ctu_params-racommit =  'X'.

    DATA(lt_lock) = gt_pod[].
    DELETE lt_lock WHERE ztext NE ls_do-ztext.
    SORT lt_lock BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_lock COMPARING vgbel.
    LOOP AT lt_lock INTO DATA(ls_lock).
      CLEAR gs_lock.
      gs_lock-vbeva = ls_lock-vgbel.
      PERFORM doc_unlock USING 'ZGTSDR0120'.
    ENDLOOP.

    CALL TRANSACTION 'VF01' USING bdctab
                            OPTIONS FROM ctu_params
                            MESSAGES INTO g_msg_t.

    CLEAR l_vbeln.
    DO 10 TIMES.
      SELECT SINGLE a~vbeln INTO @l_vbeln
        FROM vbrp AS a INNER JOIN vbrk AS b
          ON a~vbeln = b~vbeln
       WHERE vgbel = @gt_pod-vbeln
         AND fksto = @space
         AND sfakn = @space
         AND fkdat = @pa_fkdat
         AND b~erdat = @sy-datlo
         AND b~erzet = ( SELECT MAX( b~erzet )
                           FROM vbrp AS a INNER JOIN vbrk AS b
                             ON a~vbeln = b~vbeln
                          WHERE vgbel = @gt_pod-vbeln
                            AND fksto = @space
                            AND sfakn = @space
                            AND fkdat = @pa_fkdat
                            AND b~erdat = @sy-datlo ).

      IF l_vbeln IS INITIAL.
*        WAIT UP TO '0.3' SECONDS.
        WAIT UP TO '1' SECONDS.
      ELSE.
        SELECT SINGLE mandt INTO @sy-mandt
          FROM zgtsdt1010
         WHERE vbeln_vf = @l_vbeln "로그에 해당 빌링 번호가있는지 검색
           AND loekz    = @space.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDDO.



    IF l_vbeln IS NOT INITIAL.  "빌링 성공

      "빌링 성공후 MB5SIT에 운송중 재고를 확인하고 DO당 아이템이 하나라도 종결이 안났으면 FKSTK = A
      LOOP AT gt_pod WHERE ztext = ls_do-ztext.

        CLEAR : lv_chk, lv_cnt, lv_tcnt.

        LOOP AT lt_lip_sts INTO ls_lip_sts WHERE vbeln = gt_pod-vbeln.

          CLEAR lv_posnr.
          IF ls_lip_sts-uecha IS NOT INITIAL.
            lv_posnr = ls_lip_sts-uecha.
          ELSE.
            lv_posnr = ls_lip_sts-posnr.
          ENDIF.

          CLEAR ls_result.
          PERFORM call_mb5sit_gi2 USING ls_lip_sts-vbeln ls_lip_sts-posnr
                               CHANGING ls_result.
          IF ls_result-sit_gi = 0.
            lv_chk = |X|.
            ADD 1 TO lv_cnt.
          ENDIF.
          ADD 1 TO lv_tcnt.
        ENDLOOP.

        LOOP AT lt_lip_sts INTO ls_lip_sts WHERE vbeln = gt_pod-vbeln.

          CLEAR lv_posnr.
          IF ls_lip_sts-uecha IS NOT INITIAL.
            lv_posnr = ls_lip_sts-uecha.
          ELSE.
            lv_posnr = ls_lip_sts-posnr.
          ENDIF.

          IF lv_tcnt = lv_cnt.
            PERFORM update_stat USING ls_lip_sts-vbeln lv_posnr 'FN'.
          ELSE.
            "빌링후 잔량이 있으면 출고 가능한 상태로 변경
            CLEAR ls_result.
            PERFORM call_mb5sit_gi2 USING ls_lip_sts-vbeln ls_lip_sts-posnr
                                 CHANGING ls_result.
            IF ls_result-sit_gi = 0.
              PERFORM update_stat USING ls_lip_sts-vbeln lv_posnr 'F_VL2'.
            ELSE.
              PERFORM update_stat USING ls_lip_sts-vbeln lv_posnr 'F_VL'.
            ENDIF.
          ENDIF.

**********************************************************************
*LOG 업데이트
**********************************************************************
          zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun = zgtsd_u
                                          CHANGING  cs_timestamp = ls_1010-timestamp ).

          UPDATE zgtsdt1010
             SET vbeln_vf = l_vbeln
                 aedat    = ls_1010-aedat
                 aezeit   = ls_1010-aezeit
                 aenam    = ls_1010-aenam
                 aedatlo  = ls_1010-aedatlo
                 aetimlo  = ls_1010-aetimlo
           WHERE vbeln = ls_lip_sts-vbeln
             AND posnr = lv_posnr
             AND mblnr = ls_lip_sts-mblnr
             AND charg = ls_lip_sts-charg
             AND loekz = space.

        ENDLOOP.
        COMMIT WORK.
        gt_pod-vbeln_vf = l_vbeln.
        MODIFY gt_pod.
      ENDLOOP.

      CONCATENATE  '대금청구문서 ' '생성되었습니다.'
             INTO  g_mesg SEPARATED BY space.

      LOOP AT lt_lock INTO ls_lock.
        CLEAR gs_lock.
        gs_lock-vbeva = ls_lock-vgbel.
        PERFORM doc_unlock USING 'ZGTSDR0120'.
      ENDLOOP.

    ELSE.

      g_err = |X|.
*START CHM2608-00545 부스닥트 대금청구문서 "오류 메세지" 수정 요청
*대금청구실패 메시지로 후속 작업이 불가하여
*SAP에서 보여주는 메시지 그대로 출력하도록 수정

      DESCRIBE TABLE g_msg_t LINES l_line.
      IF l_line > 0.
        READ TABLE g_msg_t INDEX l_line.
        IF sy-subrc = 0.
          g_mesg = g_msg_t-msgv1.
        ENDIF.
      ELSE.
        CONCATENATE '' '대금청구문서 생성에 실패했습니다' INTO g_mesg SEPARATED BY space.
      ENDIF.

      g_itab_t-mesg = g_mesg.

*      CONCATENATE  '' ' 대금청구문서 생성에 실패했습니다'
*            INTO  g_mesg SEPARATED BY space.

*END CHM202608-00545 2026.09.02

      LOOP AT lt_tvpod INTO DATA(ls_tvpod).
        UPDATE tvpod
           SET podmg     = ls_tvpod-podmg
               podmg_lme = ls_tvpod-podmg_lme
         WHERE vbeln = ls_tvpod-vbeln
           AND posnr = ls_tvpod-posnr.
      ENDLOOP.

**********************************************************************
**601문서 생성중 에러가 있을경우 취소 한다.
**********************************************************************
      LOOP AT lt_lock INTO ls_lock.
        CLEAR gs_lock.
        gs_lock-vbeva = ls_lock-vgbel.
        PERFORM doc_unlock USING 'ZGTSDR0120'.
      ENDLOOP.

      PERFORM create_pod_602 USING lv_err.
      PERFORM roll_back_status_vf USING ls_do-ztext.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLL_BACK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM roll_back_status .

  LOOP AT gt_lip_sts INTO gs_lip_sts.

    UPDATE likp
       SET fkstk = gs_lip_sts-fkstk
           gbstk = gs_lip_sts-gbstk
           pdstk = gs_lip_sts-pdstk
     WHERE vbeln = gs_lip_sts-vbeln.

    UPDATE lips
       SET fksta = gs_lip_sts-fksta
           pdsta = gs_lip_sts-pdsta
           kzpod = gs_lip_sts-kzpod
     WHERE vbeln = gs_lip_sts-vbeln
       AND posnr = gs_lip_sts-posnr.
  ENDLOOP.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLL_BACK_SINGLE_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM roll_back_single_status USING pv_vbeln.

  UPDATE likp
     SET fkstk = 'A'
         gbstk = 'B'
         pdstk = 'B'
   WHERE vbeln = pv_vbeln.

  UPDATE lips
     SET fksta = 'A'
         pdsta = 'B'
         kzpod = 'B'
   WHERE vbeln = pv_vbeln.
  .
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MB5SIT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM call_mb5sit_gi  USING    pv_vbeln pv_posnr
                     CHANGING ps_result TYPE mb5sit
                              pv_first.

  STATICS : lt_stock TYPE TABLE OF mb5sit WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln posnr.

  DATA : lt_result TYPE TABLE OF mb5sit WITH DEFAULT KEY WITH HEADER LINE,
         lt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE.

  RANGES : lr_sobkz FOR lips-sobkz,
           lr_ebeln FOR lips-ebeln,
           lr_ebelp FOR lips-ebelp,
           lr_lifnr FOR likp-lifnr.

  IF pv_first IS INITIAL.
    CLEAR : lt_stock, lt_stock[].
    pv_first = 'X'.
  ENDIF.

  TRY.

      READ TABLE lt_stock INTO ps_result WITH KEY k_key COMPONENTS vbeln = pv_vbeln
                                                                   posnr = pv_posnr.
      IF sy-subrc NE 0.
        __rng : lt_deli 'I' 'EQ' pv_vbeln ''.
        CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
          EXPORTING
            i_wi_gm               = 'X'
            i_condense            = space
          TABLES
            t_result              = lt_result
            t_ra_sobkz            = lr_sobkz
            t_ra_ebeln            = lr_ebeln
            t_ra_ebelp            = lr_ebelp
            t_ra_lifnr            = lr_lifnr
            t_ra_del_out          = lt_deli[] "delivery outbound
          EXCEPTIONS
            parameter_error       = 1
            missing_authorization = 2
            OTHERS                = 3.

        IF lt_result[] IS NOT INITIAL.
          lt_stock[] = CORRESPONDING #( BASE ( lt_stock  ) lt_result[] ).
          READ TABLE lt_result INTO ps_result WITH KEY posnr = pv_posnr.
        ENDIF.

      ENDIF.
    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE zgtsd_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_EDIT_FLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_edit_fld USING pv_type.

  DATA : lt_styl TYPE lvc_t_styl,
         lv_chk.

  DATA : lv_nametxt TYPE user_addr-name_textc,
         lv_kunnr   TYPE kunnr,
         lv_err     TYPE flag.

  CLEAR gv_valid.
  CALL METHOD go_grid->check_changed_data( IMPORTING e_valid = gv_valid ).
  CHECK gv_valid EQ |X|.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  IF pv_type IS NOT INITIAL.
    "Selected Rows
    CLEAR g_subrc.
    DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                          io_grid = go_grid
                                                          iv_ck   = zgtsd_x
                                                        IMPORTING
                                                          ev_subrc = g_subrc ).
    CHECK g_subrc IS INITIAL.
    LOOP AT lt_rows INTO DATA(ls_row).

      READ TABLE g_itab_t INDEX ls_row-index.
      CHECK sy-subrc = 0 AND g_itab_t-pod_stat NE icon_led_red.

      g_itab_t-chk = zgtsd_x.
      MODIFY g_itab_t INDEX ls_row-index.
    ENDLOOP.
  ENDIF.

**********************************************************************
*마감확정 대상 S/O LOCK 여부 체크
**********************************************************************
  DATA(lt_tmp) = g_itab_t[].
  IF pv_type IS NOT INITIAL. "확정시
    DELETE lt_tmp WHERE chk IS INITIAL.
  ENDIF.
  SORT lt_tmp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING vgbel.
  IF pv_type IS NOT INITIAL.
    LOOP AT lt_tmp INTO DATA(ls_tmp).
      CLEAR gs_lock.
      gs_lock-vbeva = ls_tmp-vgbel.

      PERFORM check_lock_code USING    space
                              CHANGING lv_nametxt lv_kunnr lv_err.
      IF lv_err EQ 'X'.
        MESSAGE i104(zgtsd01) WITH lv_nametxt lv_kunnr DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF lv_err IS NOT INITIAL.
    CLEAR g_itab_t.
    MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
    EXIT.
  ENDIF.

  IF pv_type IS INITIAL.
    CLEAR g_fdis.
  ELSE.
    g_fdis = |X|.
  ENDIF.

  IF g_fdis IS NOT INITIAL.

    READ TABLE g_itab_t WITH KEY chk = 'X' .
    IF sy-subrc NE 0.
      MESSAGE s001 WITH TEXT-m02 DISPLAY LIKE 'E'.
      CLEAR g_fdis. EXIT.
    ENDIF.

    CLEAR gv_answer.
    gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                   iv_messa = TEXT-m01 ).
    IF gv_answer NE zgtsd_j.
      CLEAR : g_fdis, g_itab_t.
      MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.
      EXIT.
    ENDIF.

  ENDIF.

  PERFORM alvprn_header2 USING space.

*  LOOP AT G_ITAB_T.  "마감수량 EDIT
*    CLEAR G_ITAB_T-CELLS.
*    PERFORM SET_ALV_FLD_STYLE USING LT_STYL G_FDIS  : 'REMN_QTY'. "'CHK',
*    INSERT LINES OF LT_STYL INTO TABLE G_ITAB_T-CELLS.
*
*    MODIFY G_ITAB_T.
*  ENDLOOP.

**********************************************************************
*마감확정한 S/O LOCK
**********************************************************************
  LOOP AT lt_tmp INTO ls_tmp.
    CLEAR gs_lock.
    MOVE-CORRESPONDING ls_tmp TO gs_lock.
    gs_lock-kunnr = ls_tmp-kunag.
    gs_lock-vbeva = ls_tmp-vgbel.
    gs_lock-vbevl = ls_tmp-vbeln.

    IF pv_type IS NOT INITIAL.
      PERFORM doc_lock USING 'ZGTSDR0120'.
    ELSE.
      PERFORM doc_unlock USING 'ZGTSDR0120'.
    ENDIF.
  ENDLOOP.
**********************************************************************

  PERFORM refresh_table_display USING go_grid space.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM init_alv_0100  CHANGING po_dcon TYPE REF TO cl_gui_docking_container
                             po_grid TYPE REF TO cl_gui_alv_grid.

  PERFORM create_doc_container CHANGING po_dcon.

  CASE sy-dynnr.

    WHEN 0100.
      "Create Main Container

      "Split
      go_split = NEW #( parent = po_dcon rows = 2 columns = 1 ).

      go_con_top       = go_split->get_container( row = 1 column = 1 ).
      DATA(lo_con_btt) = go_split->get_container( row = 2 column = 1 ).

      go_split->set_row_height( id = 1 height = 15 ).

      "Create Object
      go_docu = NEW #( style = 'ALV_GRID' ).  "Top-Of-Page

      PERFORM create_alv USING    lo_con_btt
                         CHANGING po_grid.

    WHEN OTHERS.
      PERFORM create_alv USING    po_dcon
                         CHANGING po_grid.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_doc_container CHANGING po_dcon TYPE REF TO cl_gui_docking_container.

  CREATE OBJECT po_dcon
    EXPORTING
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        =
                                    cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_alv CHANGING po_con
                         po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_attributes_0100 .

  "Layout 지정
  PERFORM set_grid_layout USING 'X' 'CELLS' zgtsd_d.

  "Field Catalog
  PERFORM set_fieldcatalog.

  "Toolbar 제외
  PERFORM exclude_toolbar TABLES gt_toolbar.

  "Event Handler 등록
  PERFORM create_event_receiver USING go_grid.

  "F4 필드 등록
  PERFORM register_f4_fields.

  "SORT
  PERFORM set_alv_sort CHANGING gt_sort.

  "Top-Of-Page Event 등록
  PERFORM set_top_of_page_event.

  "ALV Grid Display
  PERFORM set_table_for_first_display USING go_grid
                                            g_itab_t[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_grid_layout USING pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  CLEAR gs_layout.
  gs_layout = VALUE #( sel_mode   = pv_sel_mode
                       no_rowmove      = zgtsd_x
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
*                       NO_ROWMARK = 'X'
                       stylefname = pv_stylefname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog .

  "Get Field Catalog
  PERFORM get_field_catalog USING g_itab_t[] CHANGING gt_fcat.

  "Set Field Catalog
  PERFORM set_fieldcatalog_main.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_field_catalog USING pt_table TYPE table
                    CHANGING pt_fcat TYPE lvc_t_fcat.

  REFRESH pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_x
                                                iv_cellc = zgtsd_x ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_main .


  SORT gt_fcat BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat USING :

*      'S' 'FIELDNAME'   'CHK',
*      ' ' 'COLTEXT'     '선택',
*      ' ' 'OUTPUTLEN'   '2',
*      ' ' 'COL_POS'     '1',
**      ' ' 'EDIT'        'X',
*      ' ' 'CHECKBOX'    'X',
*      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POD_STAT',
      ' ' 'COLTEXT'     'POD상태',
      ' ' 'HOTSPOT'     'X',
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VGBEL',
      ' ' 'COLTEXT'   '주문번호',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'VGPOS',
      ' ' 'COLTEXT'   '주문품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'ZPJNO',
      ' ' 'COLTEXT'   '프로젝트',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'ZPTXT',
      ' ' 'COLTEXT'   '프로젝트명',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'KUNAG',
      ' ' 'COLTEXT'   '거래처',
      ' ' 'COL_POS'     '4',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'NAME1',
      ' ' 'COLTEXT'   '거래처명',
      ' ' 'COL_POS'     '5',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'WADAT_IST',
      ' ' 'COLTEXT'   'POD/Billing일자',
      ' ' 'COL_POS'     '6',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'KWMENG',
      ' ' 'COLTEXT'   '주문수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '7',

      'S' 'FIELDNAME' 'VRKME',
      ' ' 'COLTEXT'   '판매단위',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '8',

      'S' 'FIELDNAME' 'VBELN',
      ' ' 'COLTEXT'   '납품문서',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '9',

      'S' 'FIELDNAME' 'POSNR',
      ' ' 'COLTEXT'   '납품품목',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '10',

      'S' 'FIELDNAME' 'CHARG',
      ' ' 'COLTEXT'   '배치번호',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '11',

      'S' 'FIELDNAME' 'MATNR',
      ' ' 'COLTEXT'   '자재코드',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '13',

      'S' 'FIELDNAME' 'MAKTX',
      ' ' 'COLTEXT'   '자재내역',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '14',

      'S' 'FIELDNAME' 'BSTNK',
      ' ' 'COLTEXT'   '제조지시번호',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '14',

      'S' 'FIELDNAME' 'FKIMG',
      ' ' 'COLTEXT'   '기청구수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '15',

      'S' 'FIELDNAME' 'REMN_QTY2',
      ' ' 'COLTEXT'   '잔량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '16',

      'S' 'FIELDNAME' 'REMN_QTY',
      ' ' 'COLTEXT'   '마감수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
*      ' ' 'EDIT'        'X',
      'E' 'COL_POS'     '17',

      'S' 'FIELDNAME' 'WAERK',
      ' ' 'COLTEXT'   '통화',
      'E' 'COL_POS'     '18',

      'S' 'FIELDNAME' 'NETWR',
      ' ' 'COLTEXT'   '청구액',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '19',

      'S' 'FIELDNAME' 'ZTAX',
      ' ' 'COLTEXT'   'Tax %',
      ' ' 'OUTPUTLEN'   '6',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '20',

      'S' 'FIELDNAME' 'ZTAX2',
      ' ' 'COLTEXT'   'Tax',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '21',

      'S' 'FIELDNAME' 'Z_SUM',
      ' ' 'COLTEXT'   '청구액+TAX',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      ' ' 'TECH'        'X',
      'E' 'COL_POS'     '22',


      'S' 'FIELDNAME' 'KDKG4',
      ' ' 'COLTEXT'   '내수/로칼구분',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '23',

      'S' 'FIELDNAME' 'FAKSK',
      ' ' 'COLTEXT'   '대금청구보류',
      ' ' 'OUTPUTLEN'   '12',
      'E' 'COL_POS'     '24',

      'S' 'FIELDNAME' 'ZTEXT',
      ' ' 'COLTEXT'   '청구분할',
      ' ' 'OUTPUTLEN'   '22',
      'E' 'COL_POS'     '25',

      'S' 'FIELDNAME' 'FKDAT',
      ' ' 'COLTEXT'   '대금청구일',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '26',

      'S' 'FIELDNAME' 'ZOUT',
      ' ' 'COLTEXT'   '통문관련',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '27',

      'S' 'FIELDNAME' 'BEZEI',
      ' ' 'COLTEXT'   '영업팀',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '28',

      'S' 'FIELDNAME' 'NAME2',
      ' ' 'COLTEXT'   '납품처',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '29',

      'S' 'FIELDNAME' 'NAME3',
      ' ' 'COLTEXT'   '청구처',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '30',

      'S' 'FIELDNAME' 'ZZCOLOR_BASE',
      ' ' 'COLTEXT'   '색상Base',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '31',

      'S' 'FIELDNAME' 'ZZCOLOR_STRIPE',
      ' ' 'COLTEXT'   '색상Stripe',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '32',

      'S' 'FIELDNAME' 'ZZIDEN_CODE',
      ' ' 'COLTEXT'   '절연선심식별',
      ' ' 'OUTPUTLEN'   '30',
      'E' 'COL_POS'     '33',

      'S' 'FIELDNAME'   'ZZSPEC_NO',
      ' ' 'COLTEXT'   'Spec_No',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '34',

      'S' 'FIELDNAME'   'ZZMAKTX80',
      ' ' 'COLTEXT'   '전체품명',
      ' ' 'OUTPUTLEN'   '80',
      'E' 'COL_POS'     '35',

      'S' 'FIELDNAME'   'ZZRAL_CODE',
      ' ' 'COLTEXT'   '색상(상세)',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '36',

      'S' 'FIELDNAME' 'ZZSPEC_DETAIL',
      ' ' 'COLTEXT'   'Spec상세내용',
      ' ' 'OUTPUTLEN'   '30',
      'E' 'COL_POS'     '37',

      'S' 'FIELDNAME' 'ZNETPR',
      ' ' 'COLTEXT'   '세금계산서단가',
*      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '38',

      'S' 'FIELDNAME' 'O_VBELN',
      ' ' 'COLTEXT'   '원주문번호',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '40',

      'S' 'FIELDNAME' 'O_POSNR',
      ' ' 'COLTEXT'   '원주문품목',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '41',

      'S' 'FIELDNAME' 'BSTKD',
      ' ' 'COLTEXT'   'PO 번호',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '42',

      'S' 'FIELDNAME' 'TAXK1',
      ' ' 'COLTEXT'   '세금분류',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '43',

      'S' 'FIELDNAME' 'MESG',
      ' ' 'COLTEXT'   'BDC메세지',
      ' ' 'OUTPUTLEN'   '70',
      'E' 'COL_POS'     '44',

      'S' 'FIELDNAME' 'FBUDA',
      ' ' 'COLTEXT'   '서비스제공일',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '45',

      'S' 'FIELDNAME' 'LADGR',
      ' ' 'COLTEXT'   '적하그룹',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '46',

      'S' 'FIELDNAME'  'WADAT_IST2',
      ' ' 'COLTEXT'   '통문(GI)일자',
      'E' 'COL_POS'     '47',

      'S' 'FIELDNAME' 'VBEVA',
      ' ' 'COLTEXT'   '기존적송주문',
      'E' 'OUTPUTLEN'   '10',


      'S' 'FIELDNAME' 'VBEVL_O',
      ' ' 'COLTEXT'   '최초납품문서',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME' 'POSVL_O',
      ' ' 'COLTEXT'   '최초납품품목',
      'E' 'OUTPUTLEN'   '8',

      'S' 'FIELDNAME' 'WADAT_IST_O',
      ' ' 'COLTEXT'   '최초출고일',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME' 'MON',
      ' ' 'COLTEXT'   '이월기간',
      ' ' 'NO_ZERO'   'X',
      'E' 'OUTPUTLEN'   '10'.

  IF  pa_spart  =  '21'  OR      " 자동차전선
      pa_spart  =  '22'  OR      " 튜브
      pa_spart  =  '51'  OR      " 커넥터
      pa_spart  =  '53' .        " 폴리머스위치

    PERFORM reset_field_catalog TABLES gt_fcat USING :
       'S' 'FIELDNAME' 'NETPR2',
       ' ' 'COLTEXT'   '단가',
*       ' ' 'CFIELDNAME' 'WAERK',
       ' ' 'OUTPUTLEN'   '10',
       ' ' 'JUST'        'R',
       'E' 'COL_POS'     '16'.

  ELSEIF  pa_spart  =  '54'.      " 동박
    PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME' 'PRSDT',
      ' ' 'COLTEXT'   '가격결정일',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'EDIT'        'X',
      'E' 'COL_POS'     '30'.

  ELSE.

    PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME' 'NETPR',
      ' ' 'COLTEXT'   '단가',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '16'.

  ENDIF.

  IF  pa_spart  =  '70'.

    PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME' 'LFIMG',
      ' ' 'COLTEXT'   '입고/납품수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '13'.


  ELSE.

    PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME' 'LFIMG',
      ' ' 'COLTEXT'   '납품수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '13'.

  ENDIF.


  IF p_local = '4L'.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME' 'KURSF',
      ' ' 'COLTEXT'   '환율',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '18',

      'S' 'FIELDNAME' 'NETWR_K',
      ' ' 'COLTEXT'   '환율 반영 금액',
      ' ' 'CFIELDNAME' 'WAERK_K',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '18',

      'S' 'FIELDNAME' 'FIDNO',
      ' ' 'COLTEXT'   'F/D No',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '18',


      'S' 'FIELDNAME' 'FIDNP',
      ' ' 'COLTEXT'   'F/D 품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '18'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM reset_field_catalog TABLES pt_fcat TYPE lvc_t_fcat
                         USING  pv_flag
                                pv_fname
                                pv_value.

  STATICS : ls_fcat   TYPE lvc_s_fcat,
            lv_colpos TYPE lvc_colpos,
            lv_tabix  TYPE sytabix.

  IF pv_flag = zgtsd_s.  "Start
    CLEAR ls_fcat.
    READ TABLE pt_fcat INTO ls_fcat WITH KEY fieldname = pv_value BINARY
    SEARCH.
    CHECK sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  ENDIF.

  CASE pv_fname.
    WHEN 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    WHEN OTHERS.
      ASSIGN COMPONENT pv_fname OF STRUCTURE ls_fcat TO
      FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = pv_value.
  ENDCASE.

  IF pv_flag = zgtsd_e.  "End
    MODIFY pt_fcat FROM ls_fcat INDEX lv_tabix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM exclude_toolbar TABLES pt_exclude TYPE ui_functions.

  REFRESH pt_exclude.

  APPEND : cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_data_save           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_cut             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_delete_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_insert_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_move_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_append_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_refresh             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_check               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_print               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_views               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_graph               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_event_receiver USING po_sender TYPE REF TO cl_gui_alv_grid.

  "Create Event
  DATA(lo_event) = NEW lcl_event_receiver( ).

  CASE po_sender.
    WHEN go_grid.
      SET HANDLER : lo_event->handle_top_of_page FOR po_sender.
  ENDCASE.

  SET HANDLER : lo_event->handle_hotspot_click         FOR po_sender,
                lo_event->handle_dbl_click             FOR po_sender,
                lo_event->handle_data_changed          FOR po_sender.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  "Set Ready for Input
  go_grid->set_ready_for_input( SWITCH #( gv_edit WHEN zgtsd_x THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM register_f4_fields .

  DATA : lt_f4   TYPE lvc_t_f4,
         lt_fcat TYPE TABLE OF lvc_s_fcat
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS f4availabl fieldname.

  lt_fcat = gt_fcat.
  LOOP AT lt_fcat INTO DATA(ls_fcat) USING KEY key_mode
                  WHERE f4availabl = zgtsd_x.
    lt_f4 = VALUE #( BASE lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  ENDLOOP.

  go_grid->register_f4_for_fields( EXPORTING it_f4 = lt_f4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_top_of_page_event .

  CHECK go_docu IS BOUND.

  go_docu->initialize_document( background_color =
  cl_dd_area=>col_textarea ).

  CALL METHOD go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_table_for_first_display USING po_sender TYPE REF TO cl_gui_alv_grid
                                       pt_data TYPE table.
  DATA : lv_handl TYPE slis_handl.

  "레이아웃 Variant 구분자
  PERFORM set_variant_handle USING po_sender CHANGING lv_handl.
  IF gs_variant-report IS INITIAL.
    gs_variant-report = sy-cprog.
  ENDIF.
  gs_variant-handle = lv_handl.

  DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD po_sender->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      is_variant           = gs_variant "VALUE #( REPORT = SY-REPID
*     HANDLE               = LV_HANDL )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    CHANGING
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_variant_handle USING po_sender TYPE REF TO cl_gui_alv_grid
                         CHANGING pv_handl.

  CLEAR pv_handl.
  CASE po_sender.
    WHEN go_grid. "Main
      pv_handl = '1'.
    WHEN go_grid2. "Main
      pv_handl = '2'.
    WHEN OTHERS.

  ENDCASE.
  CONDENSE pv_handl.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_dbl_click  USING    pv_row     TYPE lvc_s_row
                                pv_column  TYPE lvc_s_col.

  RANGES : lr_do FOR lips-vbeln.

  CHECK pv_row-rowtype EQ space.
  READ TABLE g_itab_t INTO DATA(ls_tab) INDEX pv_row-index.
  CHECK sy-subrc = 0 .

  CASE pv_column.
    WHEN 'VBEVA'.
      CHECK ls_tab-vbeva IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   ls_tab-vbeva.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    WHEN 'VBEVL_O'.
      CHECK ls_tab-vbevl_o IS NOT INITIAL.
      SET PARAMETER ID: 'VL' FIELD   ls_tab-vbevl_o.
      CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
    WHEN 'VBELN'.
      CHECK ls_tab-vbeln IS NOT INITIAL.

      CASE g_itab_t-pstyv.
        WHEN  'TAD' OR 'ZDRN'  OR 'L2W' OR 'L2N' OR 'G2W' OR 'ZCRN' OR 'G2N'   .
          SET PARAMETER ID: 'AUN' FIELD   ls_tab-vbeln.
          CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
          SET PARAMETER ID: 'VL' FIELD   ls_tab-vbeln.
          CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
      ENDCASE.
    WHEN 'VBELN_VF'.
      CHECK ls_tab-vbeln_vf IS NOT INITIAL.
      SET PARAMETER ID: 'VF' FIELD   ls_tab-vbeln_vf.
      CALL TRANSACTION  'VF03' AND SKIP FIRST SCREEN.
    WHEN 'VGBEL'.
      CHECK ls_tab-vgbel IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   ls_tab-vgbel.
*      IF G_FDIS IS INITIAL AND P_LOCK IS INITIAL.
      CALL TRANSACTION  'VA02' AND SKIP FIRST SCREEN.
*      ELSE.
*        CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
*      ENDIF.

    WHEN 'O_VBELN'.
      CHECK ls_tab-o_vbeln IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   ls_tab-o_vbeln.
      CALL TRANSACTION  'VA02' AND SKIP FIRST SCREEN.
    WHEN 'KUNNR_RG'.
      CHECK ls_tab-kunnr_rg IS NOT INITIAL.
      SET PARAMETER ID: 'KUN' FIELD   ls_tab-kunnr_rg.
      SET PARAMETER ID: 'VKO' FIELD   pa_vkorg.
      SET PARAMETER ID: 'VTW' FIELD   pa_vtweg.
      SET PARAMETER ID: 'SPA' FIELD   pa_spart.
      CALL TRANSACTION  'VD03' AND SKIP FIRST SCREEN.
    WHEN 'KUNNR_WE'.
      CHECK ls_tab-kunnr_we IS NOT INITIAL.
      SET PARAMETER ID: 'KUN' FIELD   ls_tab-kunnr_we.
      SET PARAMETER ID: 'VKO' FIELD   pa_vkorg.
      SET PARAMETER ID: 'VTW' FIELD   pa_vtweg.
      SET PARAMETER ID: 'SPA' FIELD   pa_spart.
      CALL TRANSACTION  'VD03' AND SKIP FIRST SCREEN.
    WHEN 'FKIMG'.
      CHECK ls_tab-vbeln IS NOT INITIAL AND ls_tab-pod_stat IS NOT INITIAL.
      __cle lr_do.
      __rng lr_do 'I' 'EQ' ls_tab-vbeln ''.
      SUBMIT rm07sit WITH so_delou IN lr_do AND RETURN.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM set_alv_sort  CHANGING pt_sort TYPE lvc_t_sort.

  CLEAR : pt_sort[].

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'KUNNR' GC_X '' '',
*                                PT_SORT 'AEDAT' GC_X '' '',
*                                PT_SORT 'AEZET' GC_X '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_field  USING pt_sort TYPE lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  APPEND VALUE #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) TO pt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_top_of_page USING po_docu TYPE REF TO cl_dd_document
                              po_sender.

  DATA : lv_text TYPE sdydo_text_element.

  CHECK po_sender = go_grid "Main
    AND po_docu IS BOUND.

  "Set Column Width
  po_docu->add_table( EXPORTING no_of_columns = 3 border = '0'
                      IMPORTING table = DATA(lo_table) ).

  lo_table->add_column( EXPORTING width = '20%'
                        IMPORTING column = DATA(lo_col_key) ).

  lo_table->add_column( EXPORTING width = '3%'
                        IMPORTING column = DATA(lo_col_sep) ).

  lo_table->add_column( EXPORTING width = '77%'
                        IMPORTING column = DATA(lo_col_val) ).

  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_p : '청구금액(Vat포함)  '    g_c_netwr,
                                          '선택된 금액(VAT포함) '  g_c_netwr_tot,
                                          '선택된청구금액  '       g_c_netwr2,
                                          '선택된부가세액  '       g_c_ztax2.

  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( EXPORTING
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             EXCEPTIONS
                               html_display_error = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_text_common USING po_col_key TYPE REF TO cl_dd_area
                               po_col_sep TYPE REF TO cl_dd_area
                               po_col_val TYPE REF TO cl_dd_area
                               po_table   TYPE REF TO
                               cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  FIELD-SYMBOLS : <lt_selopt> TYPE table.
  DATA lv_text TYPE char255.

  CASE pv_flag.
    WHEN zgtsd_p. "Parameter
      CHECK pv_value IS NOT INITIAL.
      lv_text = CONV sdydo_text_element( pv_value ).
    WHEN zgtsd_s. "Select-Option
      ASSIGN (pv_value) TO <lt_selopt>.
      CHECK sy-subrc = 0.

      CHECK lines( <lt_selopt> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <lt_selopt>[ 1 ] TO
      FIELD-SYMBOL(<lv_low>).
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <lt_selopt>[ 1 ] TO
      FIELD-SYMBOL(<lv_high>).
      CHECK sy-subrc = 0.

      IF <lv_high> IS INITIAL.
        lv_text = <lv_low>.
      ELSEIF <lv_low> IS INITIAL.
        lv_text = `~ ` &&  <lv_low>.
      ELSE.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      ENDIF.
  ENDCASE.

  po_col_key->add_text( text = CONV sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = CONV sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_hotspot_click USING ps_column TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid
                                po_sender.

  CHECK po_sender = go_grid. "Main

  DATA : lt_msg TYPE rs_t_msg.

  CASE ps_column-fieldname.

    WHEN 'POD_STAT'.

      READ TABLE g_itab_t INTO DATA(ls_main) INDEX ps_row_no-row_id.
      CHECK sy-subrc = 0.
      CHECK ls_main-msgpop[] IS NOT INITIAL.
      lt_msg[] = ls_main-msgpop[].

      CALL FUNCTION 'RSDC_SHOW_MESSAGES_POPUP'
        EXPORTING
          i_t_msg           = lt_msg
          i_txt             = 'POD상태 에러 메세지'
          i_with_s_on_empty = rs_c_true
          i_one_msg_direct  = ''
          i_one_msg_type_s  = rs_c_true.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed USING po_data_changed TYPE REF TO
                                 cl_alv_changed_data_protocol
                                 po_sender.

  CHECK po_sender = go_grid.  "Main

  DATA(lt_mod_cells) = po_data_changed->mt_good_cells.
  SORT lt_mod_cells BY row_id fieldname.

  REFRESH gt_chg.

  LOOP AT lt_mod_cells INTO DATA(ls_mod_temp).

    DATA(ls_mod_cells) = ls_mod_temp.

    AT NEW row_id.
      READ TABLE g_itab_t INTO DATA(ls_main) INDEX ls_mod_cells-row_id.
      CHECK sy-subrc = 0.
    ENDAT.

    "체크사항 점검 및 Set Value
    PERFORM check_value_in_datachd USING    po_data_changed
                                            ls_mod_cells
                                   CHANGING ls_main.

    AT END OF row_id.
      "변경상태 Update
      PERFORM update_statu USING    po_data_changed
                                    ls_mod_cells
                           CHANGING ls_main-statu
                                    ls_main-modi.
      MODIFY g_itab_t FROM ls_main INDEX ls_mod_cells-row_id.
      APPEND CORRESPONDING #( ls_main ) TO gt_chg.
    ENDAT.

  ENDLOOP.

  "Display Protocol
  po_data_changed->display_protocol( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_value_in_datachd USING po_data_changed TYPE REF TO
                                      cl_alv_changed_data_protocol
                                      ps_mod_cells TYPE lvc_s_modi
                            CHANGING ps_data STRUCTURE g_itab_t.

  CASE ps_mod_cells-fieldname.
    WHEN 'REMN_QTY'.
      PERFORM mark_changed USING po_data_changed ps_mod_cells.

    WHEN 'PRSDT'.
      PERFORM mark_changed_prsdt USING po_data_changed ps_mod_cells.

    WHEN OTHERS.
      ASSIGN COMPONENT ps_mod_cells-fieldname OF STRUCTURE ps_data TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_changed_data USING po_grid TYPE REF TO cl_gui_alv_grid
                              pv_ck.

  CLEAR gv_error.
  CHECK po_grid IS BOUND.

  po_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF pv_ck = zgtsd_x AND lv_valid IS INITIAL.
    gv_error = zgtsd_x. "오류 Flag
    MESSAGE s029 DISPLAY LIKE zgtsd_e. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_statu USING po_data_changed TYPE REF TO
                            cl_alv_changed_data_protocol
                            ps_mod_cells TYPE lvc_s_modi
                   CHANGING pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  PERFORM modify_cell USING po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_cell_value USING po_data_changed TYPE REF TO
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     CHANGING pv_value.

  CLEAR pv_value.
  po_data_changed->get_cell_value( EXPORTING
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   IMPORTING
                                     e_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_protocol_entry USING po_data_changed TYPE REF TO
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  DATA : lt_data TYPE TABLE OF lvc_s_msg1
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  CHECK NOT line_exists( lt_data[ KEY key_mode COMPONENTS msgid     =
  pv_msgid
                                                          msgno     =
                                                          pv_msgno
                                                          msgv1     =
                                                          pv_msgv1
                                                          msgv2     =
                                                          pv_msgv2
                                                          fieldname =
                                                          pv_fieldname
                                                          row_id    =
                                                          pv_row_id ] )
                                                          .

  po_data_changed->add_protocol_entry(
      EXPORTING
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell USING po_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_finished USING pv_modified
                                            pt_good_cells TYPE
                                            lvc_t_modi
                                            po_sender.

  CHECK pv_modified = zgtsd_x
    AND po_sender   = go_grid
    AND gt_chg IS NOT INITIAL.

*  변경사항 반영
  PERFORM update_edit_fields USING gt_chg.

  "Refresh Grid
  PERFORM refresh_table_display USING po_sender space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_edit_fields USING pt_chg TYPE ty_t_chg.

*  "Set 수정 필드
*DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING
*PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar USING po_object TYPE REF TO cl_alv_event_toolbar_set
                              po_sender.
  DEFINE _add_toolbar.
    ls_toolbar = VALUE #( function   = &1
                          icon       = &2
                          quickinfo  = &3
                          text       = &4
                          butn_type  = &5 ).

    CASE &6.
      WHEN zgtsd_a. "Append
        APPEND ls_toolbar TO po_object->mt_toolbar.
      WHEN zgtsd_i. "Insert
        INSERT ls_toolbar INTO po_object->mt_toolbar INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : ls_toolbar TYPE stb_button.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*_ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3
*ZPS01_A.
*_ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0
*ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_table_display USING po_grid TYPE REF TO cl_gui_alv_grid
                                  pv_soft_refresh.

  CHECK po_grid IS BOUND.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable      = CONV #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_on_f4 USING pv_fieldname TYPE lvc_fname
                            pv_fieldvalue  TYPE lvc_value
                            ps_row_no      TYPE lvc_s_roid
                            po_event_data  TYPE REF TO cl_alv_event_data
                            pv_display     TYPE char01
                            po_sender.
  DATA : lv_value TYPE lvc_value.
  FIELD-SYMBOLS : <lt_data> TYPE table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_object .
* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid->free.

  CLEAR: go_grid.

* Container Clear
  CALL METHOD: go_con->free,
               go_split->free,
               go_con_top->free.

  CLEAR: go_con, go_split, go_con_top.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HEADER_SETTING_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM header_setting_new .

  DATA : lv_text TYPE sdydo_text_element.

  CHECK go_docu IS BOUND.

  CALL METHOD go_docu->initialize_document.

  CALL METHOD go_grid->list_processing_events          "Top-of-Page 문서 출력
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'       "List_Processing_Events를 더블클릭해서 들어가보면 명시되어 있음
      i_dyndoc_id  = go_docu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FLD_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_STYL
*&---------------------------------------------------------------------*
FORM set_alv_fld_style  USING  pt_styl TYPE lvc_t_styl
                               pv_type
                               pv_name.

  DATA : ls_styl TYPE lvc_s_styl.
  ls_styl-fieldname = pv_name.

  IF pv_type IS NOT INITIAL.
    ls_styl-style = cl_gui_alv_grid=>mc_style_disabled.
  ELSE.
    ls_styl-style = cl_gui_alv_grid=>mc_style_disabled.
*    LS_STYL-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
  ENDIF.

  INSERT ls_styl INTO TABLE pt_styl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_select  USING  pv_type.

  CLEAR gv_valid.
  CALL METHOD go_grid->check_changed_data( IMPORTING e_valid = gv_valid ).
  CHECK gv_valid EQ |X|.

  LOOP AT g_itab_t.
    CHECK g_itab_t-pod_stat NE icon_led_red.
    g_itab_t-chk = pv_type.
    MODIFY g_itab_t.
  ENDLOOP.
  PERFORM refresh_table_display USING go_grid space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLL_BACK_STATUS_VF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM roll_back_status_vf USING pv_ztext.

  LOOP AT gt_pod WHERE ztext = pv_ztext.

    LOOP AT gt_lip_sts INTO gs_lip_sts WHERE vbeln = gt_pod-vbeln.
      IF sy-tabix = 1.
        UPDATE likp
           SET fkstk = gs_lip_sts-fkstk
               gbstk = gs_lip_sts-gbstk
               pdstk = gs_lip_sts-pdstk
         WHERE vbeln = gs_lip_sts-vbeln.
      ENDIF.

      UPDATE lips
         SET fksta = gs_lip_sts-fksta
             pdsta = gs_lip_sts-pdsta
             kzpod = gs_lip_sts-kzpod
       WHERE vbeln = gs_lip_sts-vbeln
         AND posnr = gs_lip_sts-posnr.
    ENDLOOP.

  ENDLOOP.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_POD_602
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MBLNR_MBLNR
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM create_pod_602 USING pv_err.

  DATA : ls_1010  TYPE zgtsdt1010,
         lv_mblnr TYPE mblnr.

  __cle : gt_1010.

*D/O : 자재이동문서 = 1: N .
  DATA(lt_for) = gt_mblnr[].
  SORT lt_for BY mblnr.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING mblnr.
  IF lt_for[] IS NOT INITIAL.
    SELECT zgtsdt1010~* INTO CORRESPONDING FIELDS OF TABLE @gt_1010
      FROM zgtsdt1010
       FOR ALL ENTRIES IN @lt_for
     WHERE mblnr = @lt_for-mblnr
       AND loekz = @space.
  ENDIF.

  DATA(lt_do) = gt_1010[].
  SORT lt_do BY mblnr.
  DELETE ADJACENT DUPLICATES FROM lt_do COMPARING mblnr.
  LOOP AT lt_do INTO DATA(ls_sts) .

*602생성 전 LIKP/LIPS 상태값을 조정한다.
    PERFORM update_stat USING ls_sts-vbeln '' '602'.

*해당 601이동문서를 문서범주를 'R'로 변경
    UPDATE vbfa
       SET vbtyp_n = 'R'
     WHERE vbeln = ls_sts-mblnr.
    COMMIT WORK.

*WS_REVERSE_GOODS_ISSUE
    SUBMIT zgtsdr0120_cancel WITH p_vbeln  = ls_sts-vbeln
                             WITH p_budat  = ls_sts-podat
                             WITH p_mblnr  = ls_sts-mblnr
                             WITH p_tcode  = 'VL09'
                             WITH p_vbtyp  = 'T'
                             WITH p_mjahr  = ls_sts-podat(4)
                             AND RETURN.

    IMPORT lv_mblnr FROM MEMORY ID 'ZPODCANC'.
    FREE MEMORY ID 'ZPODCANC'.

    IF lv_mblnr IS INITIAL.

      DATA(lt_tmp) = FILTER #( gt_1010[] USING KEY k_key3 WHERE vbeln = ls_sts-vbeln ).
      SORT lt_tmp BY mblnr.
      DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING mblnr.
      IF lines( lt_tmp ) = 1.
*WS_REVERSE_GOODS_ISSUE 실패시 VLPOD BDC 수행
        PERFORM pod_cancel_bdc USING ls_sts pv_err.
      ELSE.
        pv_err = |X|.
      ENDIF.

    ELSE.

* 강제 취소시 문서흐름에 나타나지 않는 문제가 있음 VBFA Table에 Insert
      PERFORM make_vbfa_602 USING ls_sts lv_mblnr.

      " T성공후 상태 업데이트
      PERFORM set_cancel_status_ok USING ls_sts lv_mblnr.

    ENDIF.

  ENDLOOP.

ENDFORM.
**&---------------------------------------------------------------------*
**& Form CREATE_SINGLE_POD_602 (특정 납품 건만 개별 취소)
**&---------------------------------------------------------------------*
*FORM create_single_pod_602  USING iv_vbeln TYPE vbeln_vl
*                                             CHANGING pv_err.
*
*  DATA : ls_1010 TYPE zgtsdt1010,
*         lv_mblnr TYPE mblnr,
*         lt_1010_single TYPE TABLE OF zgtsdt1010,
*         lv_dummy_err    TYPE char100.
*
*  __cle : gt_1010.
*
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_1010_single
*    FROM zgtsdt1010
*   WHERE vbeln = @iv_vbeln
*     AND loekz = @space.
*
*  LOOP AT lt_1010_single INTO DATA(ls_sts).
*    " LIKP/LIPS 상태값 조정
*    PERFORM update_stat USING ls_sts-vbeln '' '602'.
*
*    " 601 문서 범주 변경
*    UPDATE vbfa SET vbtyp_n = 'R' WHERE vbeln = ls_sts-mblnr.
*    COMMIT WORK.
*
*    " 602 역분개 수행
*    SUBMIT zgtsdr0120_cancel WITH p_vbeln  = ls_sts-vbeln
*                             WITH p_budat  = ls_sts-podat
*                             WITH p_mblnr  = ls_sts-mblnr
*                             WITH p_tcode  = 'VL09'
*                             WITH p_vbtyp  = 'T'
*                             WITH p_mjahr  = ls_sts-podat(4)
*                             AND RETURN.
*
*    IMPORT lv_mblnr FROM MEMORY ID 'ZPODCANC'.
*    FREE MEMORY ID 'ZPODCANC'.
*
*    IF lv_mblnr IS INITIAL.
*      DATA(lt_tmp) = FILTER #( gt_1010[] USING KEY k_key3 WHERE vbeln = ls_sts-vbeln ).
*      SORT lt_tmp BY mblnr.
*      DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING mblnr.
*      IF lines( lt_tmp ) = 1.
*        PERFORM pod_cancel_bdc USING ls_sts lv_dummy_err.
*      ELSE.
*        pv_err = |X|.
*      ENDIF.
*
*    ELSE.
*
** 강제 취소시 문서흐름에 나타나지 않는 문제가 있음 VBFA Table에 Insert
*      PERFORM make_vbfa_602 USING ls_sts lv_mblnr.
*
*      PERFORM set_cancel_status_ok USING ls_sts lv_mblnr.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.


*&---------------------------------------------------------------------*
*& Form ROLL_BACK_SINGLE_STATUS (특정 납품 건 상태 원복)
*&---------------------------------------------------------------------*
*FORM roll_back_single_status USING iv_vbeln TYPE vbeln_vl.
*
*  LOOP AT gt_lip_sts INTO gs_lip_sts WHERE vbeln = iv_vbeln.
*    UPDATE likp
*       SET fkstk = gs_lip_sts-fkstk
*           gbstk = gs_lip_sts-gbstk
*           pdstk = gs_lip_sts-pdstk
*     WHERE vbeln = gs_lip_sts-vbeln.
*
*    UPDATE lips
*       SET fksta = gs_lip_sts-fksta
*           pdsta = gs_lip_sts-pdsta
*           kzpod = gs_lip_sts-kzpod
*     WHERE vbeln = gs_lip_sts-vbeln
*       AND posnr = gs_lip_sts-posnr.
*  ENDLOOP.
*  COMMIT WORK.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_MSGPOP
*&      --> P_
*&      --> TEXT_E02
*&---------------------------------------------------------------------*
FORM append_msg  TABLES   pt_msg TYPE rs_t_msg
                 USING    pv_type
                          pv_text.

  DATA : ls_msg TYPE rs_s_msg.

  ls_msg-msgty = pv_type.
  ls_msg-msgid = 'ZGTSD01'.
  ls_msg-msgno = '000'.
  ls_msg-msgv1 =  pv_text.
  APPEND ls_msg TO pt_msg.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POD_REVERSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pod_reverse .

  DATA : lv_err.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  CHECK g_subrc IS INITIAL.
  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    g_itab_t-chk = zgtsd_x.
    MODIFY g_itab_t INDEX ls_row-index.
  ENDLOOP.

  __cle : gt_mblnr.
  LOOP AT g_itab_t WHERE chk = 'X'.

    IF g_itab_t-pod_stat NE icon_led_red.
      MESSAGE e001 WITH '선택된 데이터의 POD상태를 확인하세요.'.
    ENDIF.

    READ TABLE gt_log INTO DATA(ls_log) WITH KEY vbeln = g_itab_t-vbeln
                                                 posnr = g_itab_t-posnr
                                                 BINARY SEARCH.
    IF sy-subrc = 0.
      IF ls_log-vbeln_vf IS NOT INITIAL.

        SELECT SINGLE mandt INTO @sy-mandt
          FROM vbrk
         WHERE vbeln = @ls_log-vbeln_vf
           AND fksto = @space
           AND sfakn = @space.
        IF sy-subrc = 0.
          MESSAGE e001 WITH '선택된 데이터의 대금청구 상태를 확인하세요.'.
        ENDIF.

        MOVE-CORRESPONDING ls_log TO gt_mblnr.
        APPEND gt_mblnr. CLEAR gt_mblnr.
      ELSE.
        MESSAGE e001 WITH '선택된 데이터의 POD상태를 확인하세요.'.
      ENDIF.
    ELSE.
      MESSAGE e001 WITH '선택된 데이터의 POD상태를 확인하세요.'.
    ENDIF.

  ENDLOOP.

  IF gt_mblnr[] IS NOT INITIAL.
    PERFORM create_pod_602 USING lv_err.
    IF lv_err IS NOT INITIAL.
      MESSAGE i000 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ENDIF.

    PERFORM query_data.
    PERFORM alvprn_header2 USING space..   " Header의 금액을 Change하기위함.
    PERFORM refresh_table_display USING go_grid space.
  ELSE.
    MESSAGE s001 WITH '납품문서 역분개 처리할 데이터를 선택하세요.'.
  ENDIF.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VIEW_QUOTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM view_quote .

  DATA : lt_join  LIKE TABLE OF g_itab_t WITH EMPTY KEY,
         ls_join  LIKE g_itab_t,
         l_input  TYPE f,
         l_output TYPE f,
         lv_qty   TYPE kwmeng.

  __cle gt_s0200.

  "Selected Rows
  CLEAR g_subrc.
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = g_subrc ).
  IF g_subrc IS NOT INITIAL.
    EXIT.
  ENDIF.

  CLEAR g_itab_t.
  MODIFY g_itab_t TRANSPORTING chk WHERE chk IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE g_itab_t INDEX ls_row-index.
    CHECK sy-subrc = 0.
    CLEAR ls_join.
    MOVE-CORRESPONDING g_itab_t TO ls_join .
    APPEND ls_join TO lt_join.
  ENDLOOP.

  IF lt_join[] IS NOT INITIAL.

*    SELECT B~VBELN, B~POSNR, B~QCODE, B~QNAME_PRNT, B~CONF_PRICE, B~QPRICE,
*           B~QQTY, B~QUNIT, B~QWAERK,
*           A~VGBEL, A~VGPOS,  A~KWMENG, A~VRKME_VA, A~VRKME,
*           A~VBELN AS VBEVL, A~POSNR AS POSVL,
*           A~MATNR,  A~MAKTX, A~CHARG,
*           A~LFIMG, A~KCMENG, A~NETPR,  A~WAERK, A~TAXM1,
*           A~KDKG4, A~FKSTA,  A~KUNAG,  A~WADAT_IST, A~KPEIN,
*           A~WERKS, A~ZTERM,  A~VBTYP,  A~ZOUT, A~ZZCOLOR_BASE,
*           A~ZZCOLOR_STRIPE,  A~ZZIDEN_CODE, A~ZZSPEC_NO,
*           A~ZZMAKTX80, A~ZZRAL_CODE, A~ZZSPEC_DETAIL,
*           A~FKREL, A~AUART, A~BSTKD, A~TAXK1, A~LADGR, A~BWART,
*           A~FBUDA, A~KNKLI, A~VKBUR, A~VKGRP, A~BSTNK, A~NETWR_P,
*           A~MWSBP, A~NAME1, A~J_1BBRANCH, A~BEZEI, A~PSTYV
*      FROM @LT_JOIN AS A INNER JOIN ZGTSDT0066 AS B
*        ON A~VGBEL EQ B~VBELN
*       AND A~VGPOS EQ B~POSNR
*      INTO TABLE @DATA(LT_QCODE).


    WITH +so_info AS ( SELECT a~vgbel, a~vgpos,
                              a~vbeln, a~posnr
                         FROM @lt_join AS a ),

         +charg AS ( SELECT DISTINCT b~vbeln, b~charg, b~matnr, b~vgbel, b~vgpos,
                            CASE WHEN b~uecha IS NOT NULL THEN b~uecha ELSE b~posnr END AS posnr
                       FROM +so_info AS a INNER JOIN lips AS b
                         ON a~vgbel = b~vgbel
                        AND a~vgpos = b~vgpos
                      WHERE b~lfimg > 0  ),

        +qty_67 AS ( SELECT d~vbeln, d~posnr, a~vgbel, a~vgpos, qcode, SUM( c~qqty ) AS qqty
                       FROM +so_info AS a INNER JOIN +charg AS d
                         ON a~vbeln = d~vbeln
                        AND a~posnr = d~posnr
                      INNER JOIN mch1 AS b
                         ON b~charg = d~charg
                        AND b~matnr = d~matnr
                      INNER JOIN zgtsdt0067 AS c
                         ON c~job_no = b~zzjob_no
                        AND c~line_no = b~zzline_no
                        AND c~serial_info = b~zzserial_info
                      GROUP BY a~vgbel, a~vgpos, d~vbeln, d~posnr, qcode ),

       +qty_66 AS ( SELECT a~vbeln,  a~posnr,  a~qcode,  a~qname,  a~qname_prnt,
                           a~qunit,  b~vbeln AS vbeln_j, b~posnr AS posnr_j, qqty,
                           a~conf_price, a~qprice, a~qwaerk
                      FROM zgtsdt0066 AS a INNER JOIN +so_info AS b
                        ON a~vbeln EQ b~vgbel
                       AND a~posnr EQ b~vgpos )

      SELECT b~vbeln, b~posnr, b~qcode, b~qname_prnt, b~conf_price, b~qprice,
             b~qunit, b~qwaerk,
             CASE WHEN c~qqty > 0 THEN c~qqty ELSE b~qqty END AS qqty
        FROM +qty_66 AS b LEFT OUTER JOIN +qty_67 AS c
          ON b~vbeln = c~vgbel
         AND b~posnr = c~vgpos
         AND b~qcode = c~qcode
         AND b~vbeln_j = c~vbeln
       ORDER BY b~vbeln, b~posnr
        INTO TABLE @DATA(lt_qcode).
  ENDIF.
  SORT lt_qcode BY vbeln  posnr.
  LOOP AT lt_qcode INTO DATA(ls_qcode).
    CLEAR : gs_s0200.
    READ TABLE lt_join INTO DATA(ls_tab) WITH KEY vgbel = ls_qcode-vbeln
                                                  vgpos = ls_qcode-posnr.
    CHECK sy-subrc = 0.
    MOVE-CORRESPONDING ls_tab TO gs_s0200.
    gs_s0200-vbeln       = ls_qcode-vbeln.
    gs_s0200-posnr       = ls_qcode-posnr.
    gs_s0200-qcode       = ls_qcode-qcode.
    gs_s0200-qname_prnt  = ls_qcode-qname_prnt.
    gs_s0200-conf_price  = ls_qcode-conf_price.
    gs_s0200-qprice      = ls_qcode-qprice.
    gs_s0200-qqty        = ls_qcode-qqty.
    gs_s0200-qunit       = ls_qcode-qunit.
    gs_s0200-qwaerk      = ls_qcode-qwaerk.

    IF gs_s0200-kwmeng NE 0.
      lv_qty =  gs_s0200-lfimg / gs_s0200-kwmeng.
    ENDIF.

    gs_s0200-dlv_qamt = gs_s0200-qqty * gs_s0200-qprice .
*    GS_S0200-DLV_QAMT = LV_QTY * ( GS_S0200-QQTY * GS_S0200-QPRICE ).
    gs_s0200-ztax3    = ls_tab-z_mwsbp.

*    L_INPUT  =  GS_S0200-ZTAX3.
**    IF  GS_S0200-WAERK  =  'KRW'.
**      L_INPUT  =  L_INPUT  /  100.
**    ENDIF.
*
*    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
*      EXPORTING
*        I_RTYPE     = '-'   " ' ':반올림, '+':올림, '-':버림
*        I_RUNIT     = '1'
*        I_VALUE     = L_INPUT
*      IMPORTING
*        E_VALUE_RND = L_OUTPUT.
*
*    GS_S0200-ZTAX3  =  L_OUTPUT.
*
*    IF  GS_S0200-WAERK  =  'KRW'.
*      GS_S0200-ZTAX3  =  GS_S0200-ZTAX3  /  100.
*    ENDIF.

    APPEND gs_s0200 TO gt_s0200.
  ENDLOOP.

  IF gt_s0200[] IS NOT INITIAL.
    CALL SCREEN 0200 STARTING AT 10 01 ENDING AT 160 30.
  ELSE.
    MESSAGE s010(zgtsd01)  DISPLAY LIKE zgtsd_e.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_attributes_0200 .

  "Layout 지정
  PERFORM set_grid_layout2 USING 'X' 'CELLS' zgtsd_d.

  "Field Catalog
  PERFORM set_fieldcatalog2.

  "Toolbar 제외
  PERFORM exclude_toolbar TABLES gt_toolbar2.

  "Event Handler 등록
  PERFORM create_event_receiver USING go_grid2.

*  "F4 필드 등록
*  PERFORM REGISTER_F4_FIELDS.

  "SORT
  PERFORM set_alv_sort CHANGING gt_sort2.

  "ALV Grid Display
  PERFORM set_table_for_first_display2  USING go_grid2
                                              gt_s0200[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_grid_layout2 USING pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  CLEAR gs_layout2.
  gs_layout2 = VALUE #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
*                       NO_ROWMARK = 'X'
                       stylefname = pv_stylefname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog2 .

  "Get Field Catalog
  PERFORM get_field_catalog USING gt_s0200[] CHANGING gt_fcat2.

  "Set Field Catalog
  PERFORM set_fieldcatalog_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_0200.


  SORT gt_fcat2 BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat2 USING :

      'S' 'FIELDNAME' 'VBELN',
      ' ' 'COLTEXT'   '주문번호',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'POSNR',
      ' ' 'COLTEXT'   '주문품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'KUNAG',
      ' ' 'COLTEXT'   '거래처',
      ' ' 'COL_POS'     '4',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'NAME1',
      ' ' 'COLTEXT'   '거래처명',
      ' ' 'COL_POS'     '5',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'KWMENG',
      ' ' 'COLTEXT'   '주문수량',
      ' ' 'QFIELDNAME' 'VRKME',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '7',

      'S' 'FIELDNAME' 'VRKME',
      ' ' 'COLTEXT'   '판매단위',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '8',

      'S' 'FIELDNAME' 'VBELN',
      ' ' 'COLTEXT'   '납품문서',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '9',

      'S' 'FIELDNAME' 'POSNR',
      ' ' 'COLTEXT'   '납품품목',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '10',

      'S' 'FIELDNAME' 'MATNR',
      ' ' 'COLTEXT'   '자재코드',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '13',

      'S' 'FIELDNAME' 'MAKTX',
      ' ' 'COLTEXT'   '자재내역',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '14',

      'S' 'FIELDNAME' 'QNAME_PRNT',
      ' ' 'COLTEXT'   '견적자재내역',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '14',

      'S' 'FIELDNAME' 'QQTY',
      ' ' 'COLTEXT'   '견적수량',
      ' ' 'QFIELDNAME' 'QUNIT',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '15',

      'S' 'FIELDNAME' 'QUNIT',
      ' ' 'COLTEXT'   '견적단위',
      ' ' 'OUTPUTLEN'   '15',
      'E' 'COL_POS'     '16',

      'S' 'FIELDNAME' 'QPRICE',
      ' ' 'COLTEXT'   '견적단가',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '17',

      'S' 'FIELDNAME' 'DLV_QAMT',
      ' ' 'COLTEXT'   '견적금액',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '18',

      'S' 'FIELDNAME' 'NETWR',
      ' ' 'COLTEXT'   '청구액',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '19',

      'S' 'FIELDNAME' 'ZTAX',
      ' ' 'COLTEXT'   'Tax %',
      ' ' 'OUTPUTLEN'   '6',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '20',

      'S' 'FIELDNAME' 'ZTAX3',
      ' ' 'COLTEXT'   'Tax',
      ' ' 'OUTPUTLEN'   '15',
      ' ' 'CFIELDNAME' 'WAERK',
      ' ' 'JUST'        'R',
      'E' 'COL_POS'     '21',

      'S' 'FIELDNAME' 'BEZEI',
      ' ' 'COLTEXT'   '영업팀',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '28',

      'S' 'FIELDNAME' 'NAME2',
      ' ' 'COLTEXT'   '납품처',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '29',

      'S' 'FIELDNAME' 'NAME3',
      ' ' 'COLTEXT'   '청구처',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '30',

      'S' 'FIELDNAME' 'ZZCOLOR_BASE',
      ' ' 'COLTEXT'   '색상Base',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '31',

      'S' 'FIELDNAME' 'ZZCOLOR_STRIPE',
      ' ' 'COLTEXT'   '색상Stripe',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '32',

      'S' 'FIELDNAME' 'ZZIDEN_CODE',
      ' ' 'COLTEXT'   '절연선심식별',
      ' ' 'OUTPUTLEN'   '30',
      'E' 'COL_POS'     '33',

      'S' 'FIELDNAME'   'ZZSPEC_NO',
      ' ' 'COLTEXT'   'Spec_No',
      ' ' 'OUTPUTLEN'   '20',
      'E' 'COL_POS'     '34',

      'S' 'FIELDNAME'   'ZZMAKTX80',
      ' ' 'COLTEXT'   '전체품명',
      ' ' 'OUTPUTLEN'   '80',
      'E' 'COL_POS'     '35',

      'S' 'FIELDNAME'   'ZZRAL_CODE',
      ' ' 'COLTEXT'   '색상(상세)',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '36',

      'S' 'FIELDNAME' 'ZZSPEC_DETAIL',
      ' ' 'COLTEXT'   'Spec상세내용',
      ' ' 'OUTPUTLEN'   '30',
      'E' 'COL_POS'     '37',

      'S' 'FIELDNAME' 'TAXK1',
      ' ' 'COLTEXT'   '세금분류',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '43'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID2
*&      --> GT_S0200[]
*&---------------------------------------------------------------------*
FORM set_table_for_first_display2  USING po_sender TYPE REF TO cl_gui_alv_grid
                                         pt_data TYPE table.
  DATA : lv_handl TYPE slis_handl.

  "레이아웃 Variant 구분자
  PERFORM set_variant_handle USING po_sender CHANGING lv_handl.

  DELETE gt_fcat2 WHERE tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD po_sender->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout2
      is_variant           = VALUE #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    CHANGING
      it_fieldcatalog      = gt_fcat2
      it_sort              = gt_sort2[]
      it_outtab            = pt_data[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_bd .
  DATA : lv_active TYPE char01.

  CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
    EXPORTING
      i_prog    = sy-cprog
      i_perform = 'CHECK_BD'
      i_vkorg   = pa_vkorg
      i_vtweg   = pa_vtweg
      i_spart   = pa_spart
    IMPORTING
      e_active  = lv_active.
  IF lv_active NE 'Y'.
    MESSAGE e001 WITH 'ZSD1R0012 프로그램 을 사용하세요 !' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POD_CANCEL_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pod_cancel_bdc USING ps_sts STRUCTURE zgtsdt1010
                          pv_err.

  CLEAR : bdctab, g_msg_t, g_cnt, g_mesg.
  REFRESH : bdctab, g_msg_t.

*POD 취소를 위한 상태 업데이트
  UPDATE lips
     SET pdsta = 'C'
   WHERE vbeln = ps_sts-vbeln.
  COMMIT WORK.

  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '4006',
                ' '  'BDC_CURSOR'       'LIKP-VBELN',
                ' '  'LIKP-VBELN'       ps_sts-vbeln,
                ' '  'BDC_OKCODE'       '=ENT2'.


  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '1000',
                ' '  'BDC_SUBSCR'       'SAPMV50A',
                ' '  'BDC_OKCODE'       '=PODS'.

  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '1000',
                ' '  'BDC_SUBSCR'       'SAPMV50A',
                ' '  'LIKP-PODAT'       ps_sts-podat,
                ' '  'BDC_OKCODE'       '=SICH_T'.

  ctu_params-dismode  =  'E'.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VLPOD' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.
  DO 5 TIMES.

    SELECT SINGLE mblnr INTO @DATA(lv_mblnr)
      FROM mseg
     WHERE smbln = @ps_sts-mblnr.
    IF sy-subrc = 0.
      EXIT.
    ELSE.
      WAIT UP TO '0.3' SECONDS.
    ENDIF.
  ENDDO.

*602  이동 문서 생성시 VBFA로그생성...
  IF lv_mblnr IS INITIAL.
    pv_err = |X|.
  ELSE.

* 강제 취소시 문서흐름에 나타나지 않는 문제가 있음 VBFA Table에 Insert
    PERFORM make_vbfa_602 USING ps_sts lv_mblnr.

    " T성공후 상태 업데이트
    PERFORM set_cancel_status_ok USING ps_sts lv_mblnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CANCEL_STATUS_OK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STS
*&---------------------------------------------------------------------*
FORM set_cancel_status_ok  USING    ps_sts STRUCTURE zgtsdt1010
                                    pv_mblnr.

  DATA : ls_1010  TYPE zgtsdt1010,
         lv_mblnr TYPE mblnr.

**********************************************************************
*601 업데이트
**********************************************************************
  UPDATE vbfa
     SET vbtyp_n = 'p'
   WHERE vbeln = ps_sts-mblnr.

  UPDATE likp
     SET wbstk = 'C'
   WHERE vbeln = ps_sts-vbeln.

  UPDATE lips
     SET wbsta = 'C'
         kzpod = 'B'
   WHERE vbeln = ps_sts-vbeln.

**********************************************************************
*602 업데이트
**********************************************************************
  UPDATE vbfa
     SET vbtyp_n = 'p'
   WHERE vbeln = pv_mblnr.

* 서비스 취소 데이터 삭제
  DELETE FROM vbfa
   WHERE vbelv    = @ps_sts-vbeln
     AND bwart    = @space
     AND plmin    = '-'
     AND rfmng    = 0
     AND vbtyp_n  = 'h'.
**********************************************************************
*LOG 업데이트
**********************************************************************
  zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun     = zgtsd_u
                                  CHANGING  cs_timestamp = ls_1010-timestamp ).

  UPDATE zgtsdt1010
     SET loekz    = 'X'
         message  = g_mesg
         aedat    = ls_1010-aedat
         aezeit   = ls_1010-aezeit
         aenam    = ls_1010-aenam
         aedatlo  = ls_1010-aedatlo
         aetimlo  = ls_1010-aetimlo
   WHERE vbeln = ps_sts-vbeln
     AND mblnr = ps_sts-mblnr
     AND loekz = space.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_VBFA_602
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_STS
*&---------------------------------------------------------------------*
FORM make_vbfa_602  USING  ps_sts STRUCTURE zgtsdt1010
                           pv_mblnr.

  DATA : lt_vbapf   TYPE TABLE OF vbapf  WITH HEADER LINE,
         lt_vbfavb  TYPE TABLE OF vbfavb WITH HEADER LINE,
         lt_vbfavby TYPE TABLE OF vbfavb WITH HEADER LINE,
         ls_vbfa    TYPE vbfa,
         ls_vbfad   TYPE vbfad.

  SELECT SINGLE mseg~* INTO @DATA(ls_mseg)
    FROM mseg
   WHERE mblnr = @pv_mblnr
     AND mjahr = @ps_sts-podat(4)
     AND bwart = '602'.

  LOOP AT gt_1010 INTO DATA(ls_1010) USING KEY k_key2
                                     WHERE mblnr = ps_sts-mblnr.

    ls_vbfa-vbelv    = ls_1010-vbeln.
    ls_vbfa-posnv    = ls_1010-posnn.
    ls_vbfa-vbeln    = pv_mblnr.
    ls_vbfa-posnn    = ls_mseg-line_id.
    ls_vbfa-vbtyp_n  = 'p'.
    ls_vbfa-rfmng    = ls_1010-lfimg.
    ls_vbfa-meins    = ls_1010-vrkme.
    ls_vbfa-vbtyp_v  = 'J'.
    ls_vbfa-plmin    = '-'.
    ls_vbfa-bwart    = '602'.

    READ TABLE g_itab_t INTO DATA(ls_itab) WITH KEY vbeln = ls_1010-vbeln
                                                    posnr = ls_1010-posnr.
    IF sy-subrc = 0.
      ls_vbfa-matnr  = ls_itab-matnr.
      ls_vbfa-waers  = ls_itab-waerk.
      ls_vbfad-aubel = ls_itab-vgbel.
      ls_vbfad-aupos = ls_itab-vgpos.
    ENDIF.

    ls_vbfad-autyp = 'C'.

    CALL FUNCTION 'RV_XVBFA_MAINTAIN'
      EXPORTING
        fvbfa     = ls_vbfa
        fvbfad    = ls_vbfad
        f_vorgang = 'H'
      TABLES
        fxvbapf   = lt_vbapf
        fxvbfa    = lt_vbfavb
        fyvbfa    = lt_vbfavby.

    READ TABLE lt_vbfavb INDEX 1.
    IF lt_vbfavb-ruuid IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOC_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM doc_lock  USING  pv_prog.

  DATA : lv_nametxt TYPE user_addr-name_textc,
         lv_kunnr   TYPE kunnr,
         lv_err     TYPE flag.

  PERFORM check_lock_code USING    pv_prog
                          CHANGING lv_nametxt lv_kunnr lv_err.
  IF lv_err EQ 'X'.
    MESSAGE i103(zgtsd01) WITH lv_nametxt lv_kunnr DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*SALEORDER LOCK
  CALL FUNCTION 'ENQUEUE_EVVBAKE'
    EXPORTING
      mandt          = sy-mandt
      vbeln          = gs_lock-vbeva
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  CASE sy-subrc.
    WHEN 0.

    WHEN 1.
      PERFORM get_lock_user USING    pv_prog
                            CHANGING lv_nametxt.

      MESSAGE i103(zgtsd01) WITH lv_nametxt gs_lock-vbeva DISPLAY LIKE 'E'.
      RETURN.

    WHEN OTHERS.
      MESSAGE s098(zgtsd01) DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LOCK_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_lock_code USING pv_prog TYPE cprog
                  CHANGING pv_nametxt pv_code  pv_err.

  DATA : lt_enq  TYPE TABLE OF seqg3,
         lv_garg TYPE seqg3-garg.

  CLEAR : pv_nametxt, pv_code, pv_err, lv_garg.
  CONCATENATE sy-mandt gs_lock-vbeva INTO lv_garg.
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |VBAK| )
      garg                  = lv_garg
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).

    CHECK ls_enq-garg+00(03) EQ sy-mandt          AND
          ls_enq-garg+03(10) EQ gs_lock-vbeva(10).

    pv_code = ls_enq-garg+03(10).
    pv_err  = 'X'.  EXIT.

  ENDLOOP.

  CHECK pv_err EQ 'X'.

  SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
    FROM user_addr
   WHERE bname EQ @ls_enq-guname.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_LOCK_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_lock_user USING pv_prog TYPE cprog
                CHANGING pv_nametxt.

  DATA : lt_enq  TYPE TABLE OF seqg3,
         lv_garg TYPE seqg3-garg.

  CLEAR pv_nametxt.
  CONCATENATE sy-mandt gs_lock-vbeva INTO lv_garg.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |VBAK| )
      garg                  = lv_garg
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).
    CHECK ls_enq-garg+00(03) EQ sy-mandt          AND
          ls_enq-garg+03(10) EQ gs_lock-vbeva(10).

    SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
      FROM user_addr
     WHERE bname EQ @ls_enq-guname.
*    PV_NAMETXT = LS_ENQ-GUNAME.
    EXIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOC_UNLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM doc_unlock USING pv_prog.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
    EXPORTING
      mandt = sy-mandt
      vbeln = gs_lock-vbeva.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROG_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LOCK
*&---------------------------------------------------------------------*
FORM prog_lock  USING    pv_lock
                         pv_prog.

  DATA : lv_nametxt TYPE user_addr-name_textc,
         lv_kunnr   TYPE kunnr,
         lv_err     TYPE flag.

  PERFORM check_lock_code_zgtsd1080 USING    pv_prog
                          CHANGING lv_nametxt lv_kunnr lv_err.
  IF lv_err EQ 'X'.
    MESSAGE i103(zgtsd01) WITH lv_nametxt lv_kunnr DISPLAY LIKE 'E'.
    pv_lock = 'X'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTSD1080'
    EXPORTING
      mandt          = sy-mandt
      prog           = pv_prog
      vkbur          = g_itab_t-vkbur
      vkgrp          = g_itab_t-vkgrp
      kunnr          = g_itab_t-kunag
      spmon          = gv_spmon
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  CASE sy-subrc.
    WHEN 0.

    WHEN 1.
      PERFORM get_lock_user_zgtsds1080 USING pv_prog
                                    CHANGING lv_nametxt.

      MESSAGE i103(zgtsd01) WITH lv_nametxt g_itab_t-kunag DISPLAY LIKE 'E'.
      pv_lock = 'X'.
      RETURN.

    WHEN OTHERS.
      MESSAGE s098(zgtsd01) DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHECK_LOCK_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_lock_code_zgtsd1080 USING pv_prog TYPE cprog
                  CHANGING pv_nametxt pv_code  pv_err.

  DATA : lt_enq  TYPE TABLE OF seqg3.

  CLEAR : pv_nametxt, pv_code, pv_err.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |ZGTSDS1080| )
*     GARG                  = LV_GARG
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).

    CHECK ls_enq-garg+00(03) EQ sy-mandt   AND
          ls_enq-garg+03(40) EQ pv_prog    AND
          ls_enq-garg+43(04) EQ g_itab_t-vkbur AND
          ls_enq-garg+47(03) EQ g_itab_t-vkgrp AND
          ls_enq-garg+50(10) EQ g_itab_t-kunag AND
          ls_enq-garg+60(06) EQ gv_spmon.

    pv_code = ls_enq-garg+50(10).
    pv_err  = 'X'.  EXIT.

  ENDLOOP.

  CHECK pv_err EQ 'X'.

  SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
    FROM user_addr
   WHERE bname EQ @ls_enq-guname.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_LOCK_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_lock_user_zgtsds1080 USING pv_prog TYPE cprog
                CHANGING pv_nametxt.

  DATA : lt_enq  TYPE TABLE OF seqg3.

  CLEAR pv_nametxt.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gname                 = CONV eqegraname( |ZGTSDS1080| )
*     GARG                  = LV_GARG
      guname                = space
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_enq INTO DATA(ls_enq).
    CHECK ls_enq-garg+00(03) EQ sy-mandt         AND
          ls_enq-garg+03(40) EQ pv_prog          AND
          ls_enq-garg+43(04) EQ g_itab_t-vkbur AND
          ls_enq-garg+47(03) EQ g_itab_t-vkgrp AND
          ls_enq-garg+50(10) EQ g_itab_t-kunag AND
          ls_enq-garg+60(06) EQ gv_spmon.

    SELECT SINGLE bname && '(' && name_textc && ')' INTO @pv_nametxt
      FROM user_addr
     WHERE bname EQ @ls_enq-guname.
*    PV_NAMETXT = LS_ENQ-GUNAME.
    EXIT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROG_UNLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prog_unlock USING pv_prog.

  CALL FUNCTION 'DEQUEUE_EZGT_ZGTSD1080'
    EXPORTING
      mandt = sy-mandt
      prog  = pv_prog
      vkbur = g_itab_t-vkbur
      vkgrp = g_itab_t-vkgrp
      kunnr = g_itab_t-kunag
      spmon = gv_spmon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_obj .

* Field Catalog
  CLEAR: gt_fcat2[].

* Grid Clear
  CALL METHOD: go_grid2->free.

  CLEAR: go_grid2.

* Container Clear
  CALL METHOD: go_con2->free.

  CLEAR: go_con2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MB5SIT_GI2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIP_STS_VBELN
*&      --> LS_LIP_STS_POSNR
*&      <-- LS_RESULT
*&---------------------------------------------------------------------*
FORM call_mb5sit_gi2  USING    pv_vbeln pv_posnr
                     CHANGING ps_result TYPE mb5sit.

  DATA : lt_result TYPE TABLE OF mb5sit WITH DEFAULT KEY WITH HEADER LINE,
         lt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE.

  RANGES : lr_sobkz FOR lips-sobkz,
           lr_ebeln FOR lips-ebeln,
           lr_ebelp FOR lips-ebelp,
           lr_lifnr FOR likp-lifnr.

  TRY.
      __rng : lt_deli 'I' 'EQ' pv_vbeln ''.
      CALL FUNCTION 'MB_SELECT_STOCK_IN_TRANSIT'
        EXPORTING
          i_wi_gm               = 'X'
          i_condense            = space
        TABLES
          t_result              = lt_result
          t_ra_sobkz            = lr_sobkz
          t_ra_ebeln            = lr_ebeln
          t_ra_ebelp            = lr_ebelp
          t_ra_lifnr            = lr_lifnr
          t_ra_del_out          = lt_deli[] "delivery outbound
        EXCEPTIONS
          parameter_error       = 1
          missing_authorization = 2
          OTHERS                = 3.

      IF lt_result[] IS NOT INITIAL.
        READ TABLE lt_result INTO ps_result WITH KEY posnr = pv_posnr.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE zgtsd_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form invoice_biusduct_amt_cals
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&      --> G_ITAB_T_POSNR
*&      <-- G_ITAB_T_NETWR
*&---------------------------------------------------------------------*
FORM invoice_biusduct_amt_cals  USING    p_vbeln
                                         p_posnr
                                CHANGING p_netwr.

  DATA : lv_netwr_i LIKE vbak-netwr.
  DATA : lv_xkwert LIKE komv-kwert.
  DATA : lv_netwr_e   LIKE vbak-netwr,
         lv_netwr_gap LIKE vbak-netwr,
         lv_mwsbp     LIKE vbap-mwsbp.

  lv_netwr_i = g_itab_t-netwr.


  CALL FUNCTION 'ZGTSD_BD_SD_CAL_BILLING_AMT1'
    EXPORTING
      i_vbeln     = p_vbeln
      i_posnr     = p_posnr
      i_netwr     = lv_netwr_i
      i_waers     = g_itab_t-waerk
    IMPORTING
      e_netwr     = lv_netwr_e
      e_netwr_gap = lv_netwr_gap
      e_mwsbp     = lv_mwsbp.

  IF lv_netwr_e IS NOT INITIAL.
    p_netwr = lv_netwr_e.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MCH1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&      --> G_ITAB_T_POSNR
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM check_mch1  USING    i_vbeln
                          i_posnr
                 CHANGING p_chk.

  DATA : lt_lips TYPE TABLE OF lips WITH HEADER LINE.
  DATA : lt_mch1 TYPE TABLE OF mch1 WITH HEADER LINE  .

  SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_lips
  FROM  lips
  WHERE vbeln = @i_vbeln
  AND ( posnr = @I_posnr OR uecha = @I_posnr )
  AND charg <> ' '.
  CHECK sy-subrc = 0.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE  lt_mch1
  FROM mch1
  FOR ALL ENTRIES IN lt_lips
  WHERE matnr = lt_lips-matnr
  AND charg = lt_lips-charg.

  IF lt_mch1[] IS INITIAL.
    p_chk = 'X'.
    EXIT.
  ENDIF.

  LOOP AT lt_mch1 WHERE zzjob_no IS INITIAL
    OR zzline_no IS INITIAL
    OR zzserial_info IS INITIAL.
    p_chk = 'X'.
    EXIT.
  ENDLOOP.

ENDFORM.
