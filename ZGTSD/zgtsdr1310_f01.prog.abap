*&---------------------------------------------------------------------*
*& Include          ZGTSDR1080_CHECK_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization .

  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout

  CLEAR : s_auart, s_auart[],
          s_fksta, s_fksta[],
          s_absta, s_absta[].

  s_fksta-sign   =  'I'.
  s_fksta-option =  'EQ'.
  s_fksta-low    =  'A'.
  APPEND  s_fksta.

  s_fksta-sign   =  'I'.
  s_fksta-option =  'EQ'.
  s_fksta-low    =  'B'.
  APPEND  s_fksta.

  s_fksta-sign   =  'I'.
  s_fksta-option =  'EQ'.
  s_fksta-low    =  'C'.
  APPEND  s_fksta.

  s_fksta-sign   =  'I'.
  s_fksta-option =  'EQ'.
  s_fksta-low    =  'X'.
  APPEND  s_fksta.

  s_fksta-sign   =  'I'.
  s_fksta-option =  'EQ'.
  s_fksta-low    =  ' '.
  APPEND  s_fksta.

  s_auart-sign   =  'I'.
  s_auart-option =  'EQ'.
  s_auart-low    =  'ZBC2'.
  APPEND s_auart.

  s_auart-sign   =  'I'.
  s_auart-option =  'EQ'.
  s_auart-low    =  'OR'.
  APPEND s_auart.

  CONCATENATE sy-datlo(6) '01' INTO DATA(lv_dt).
  s_wadat-low  = lv_dt.
  s_wadat-high = sy-datlo.
  APPEND  s_wadat.


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
*----------------------------------------------------------------------*
** 1. 일단 MATDOC에서 해당 이동유형의 모든 데이터를 싹 다 가져온다.
**----------------------------------------------------------------------*
*  SELECT mblnr, zeile, vbeln_im, vbelp_im, matnr, bwart, budat, menge
*    FROM matdoc
*    INTO TABLE @DATA(lt_mat_raw)
*    WHERE budat IN @s_wadat
*      AND bwart IN ('601', '602', '687', '688').
*
*IF lt_mat_raw IS INITIAL.
*   RETURN.
* ENDIF.
**----------------------------------------------------------------------*
** 2. 가져온 데이터를 바탕으로 LIPS/VBAP/VBAK 정보를 "하나씩" 역추적한다.
**----------------------------------------------------------------------*
*SELECT lips~vgbel,     " 오더 번호
*    lips~vgpos,     " 오더 품목
*    lips~posnr,
*    lips~uecha,
*    lips~vrkme,
*    lips~lfimg,
*    likp~kunnr AS sh_kunnr,  " 납품처
*    likp~wadat_ist
*    FROM lips
*     LEFT OUTER JOIN likp ON lips~vbeln EQ likp~vbeln
*    FOR ALL ENTRIES IN @lt_mat_raw
*    WHERE lips~vbeln = @lt_mat_raw-vbeln_im
*      AND lips~posnr = @lt_mat_raw-vbelp_im
*      AND lips~vbeln IN @s_vbeln     " 납품번호 범위
*      AND lips~fksta IN @s_fksta    " 빌링 상태
*      AND ( likp~vstel = '3450' OR likp~vstel IS INITIAL )
*    INTO TABLE @DATA(lt_lips).


*" LIPS가 없는 건(유령건)들은 MATDOC의 vbeln_im을 판매오더로 간주하고 바로 VBAP를 긁는다.
*  SELECT vbeln, posnr, kunwe_ana, netwr, kwmeng, vrkme, waerk, auart, absta
*    FROM vbap
*    FOR ALL ENTRIES IN @lt_mat_raw
*    WHERE vbeln = @lt_mat_raw-vbeln_im
*      AND posnr = @lt_mat_raw-vbelp_im
*    INTO TABLE @DATA(lt_vbap).

*----------------------------------------------------------------------*
* 1. 메인을 [MATDOC] (전기일/마감기준)으로 잡고 오더/납품 테이블 조인
*----------------------------------------------------------------------*
  SELECT
    mat~vbeln_im AS vbeln,
    mat~vbelp_im,
    mat~matnr,
    mat~mblnr,
    mat~bwart,
    mat~shkzg,
    mat~budat,
    mat~menge,
    mat~sjahr,
    mat~smbln,
    mat~mjahr,
    lips~vgbel,     " 오더 번호
    lips~vgpos,     " 오더 품목
    lips~posnr,
    lips~uecha,
    lips~vrkme,
    lips~lfimg,
    likp~kunnr AS sh_kunnr,  " 납품처
    likp~wadat_ist,
    vbak~kunnr AS ag_kunnr,  " 주문처(Sold-to)
    vbpa~kunnr AS py_kunnr,  " 지급처(Payer) - 추가됨
    vbak~vkgrp,
    vbak~vkbur,
    vbak~spart,
    vbap~netwr,
    vbak~auart,
    vbap~kwmeng,
    vbap~vrkme AS vrkme_o,
    vbap~waerk,
    vbkd~kdkg4,               " 조건 그룹 4
    vbkd~kursk
  FROM matdoc AS mat
  LEFT OUTER JOIN lips ON mat~vbeln_im EQ lips~vbeln
                      AND mat~vbelp_im EQ lips~posnr
  LEFT OUTER JOIN likp ON lips~vbeln EQ likp~vbeln
  LEFT OUTER JOIN vbap ON lips~vgbel EQ vbap~vbeln
                     AND ( lips~vgpos EQ vbap~posnr OR
                              vbap~uepos EQ lips~vgpos )
  LEFT OUTER JOIN vbak ON vbap~vbeln EQ vbak~vbeln
  LEFT OUTER JOIN vbpa ON vbak~vbeln EQ vbpa~vbeln
                      AND vbpa~parvw EQ 'RG'
  LEFT OUTER JOIN vbkd ON vbak~vbeln EQ vbkd~vbeln
                      AND vbkd~posnr EQ '000000'
*LEFT OUTER JOIN vbup ON lips~vgbel EQ vbup~vbeln
*                    AND lips~vgpos EQ vbup~posnr
*  WHERE likp~wadat_ist IN @s_wadat
  WHERE mat~budat IN @s_wadat
    AND ( likp~vstel = '3450' OR likp~vstel IS INITIAL )
    AND mat~bwart IN ('601', '602', '687', '688') " <--- 취소 건들까지 포함
    AND vbkd~podkz EQ 'X'
    AND vbak~vkorg EQ @p_vkorg
    AND vbak~vtweg IN @s_vtweg
    AND vbak~spart IN @s_spart
    AND vbak~vkgrp IN @s_vkgrp
*  AND vbak~auart IN @s_auart
    AND vbak~auart  NOT IN ('ZREQ', 'ZORQ', 'ZFQ', 'ZFS')
    AND vbak~kunnr IN @s_kunnr
    AND lips~vbeln IN @s_vbeln
    AND vbak~vkbur IN @s_vkbur
    AND vbpa~kunnr IN @s_payer      " 지급처 조건
    AND vbkd~kdkg4  IN @s_kdkg4    " KDKG4 조건
    AND lips~fksta IN @s_fksta   " 빌링 상태 조건
    AND vbap~absta IN @s_absta   " 거절 상태 조건
   INTO TABLE @DATA(lt_mat_base).
*
*" LIKP/LIPS가 아예 없는 예외 건을 위한 직접 조인 쿼리
  SELECT
    mat~vbeln_im AS vbeln,
    mat~vbelp_im,
    mat~matnr,
    mat~mblnr,
    mat~bwart,
    mat~shkzg,
    mat~budat,
    mat~menge,
    mat~sjahr,
    mat~smbln,
    mat~mjahr,
    vbap~vbeln AS vgbel,      " 오더 번호 직접 매핑
    vbap~posnr AS vgpos,
    vbap~posnr AS posnr,
    vbap~posnr AS uecha,            " LIPS가 없으므로 공백
    vbap~vrkme,
    mat~menge AS lfimg,
    vbap~KUNWE_ANA AS sh_kunnr,           " 납품처 없음(삭제됨)
    mat~budat AS wadat_ist,
    vbak~kunnr AS ag_kunnr,
    vbpa~kunnr AS py_kunnr,
    vbak~vkgrp,
    vbak~vkbur,
    vbak~spart,
    vbap~netwr,
    vbak~auart,
    vbap~kwmeng,
    vbap~vrkme AS vrkme_o,
    vbap~waerk,
    vbkd~kdkg4,
    vbkd~kursk
  APPENDING TABLE @lt_mat_base
  FROM matdoc AS mat
  INNER JOIN vbap ON mat~vbeln_im EQ vbap~vbeln   " LIPS를 타지 않고 VBAP 직접 연결
                 AND mat~vbelp_im EQ vbap~posnr
  INNER JOIN vbak ON vbap~vbeln EQ vbak~vbeln
  LEFT OUTER JOIN vbpa ON vbak~vbeln EQ vbpa~vbeln
                      AND vbpa~parvw EQ 'RG'
  LEFT OUTER JOIN vbkd ON vbak~vbeln EQ vbkd~vbeln
                      AND vbkd~posnr EQ '000000'
  WHERE mat~budat IN @s_wadat
    AND mat~bwart IN ('641', '642', '687', '688') " 적송/이전/조정 유형
    AND vbak~vkorg EQ @p_vkorg
    AND vbak~vtweg IN @s_vtweg
    AND vbak~spart IN @s_spart
    AND vbak~vbeln IN @s_vbeln     " 납품번호 대신 오더번호 조건으로 타야 잡힘
    AND vbak~auart NOT IN ('ZREQ', 'ZORQ', 'ZFQ', 'ZFS')
    AND vbak~kunnr IN @s_kunnr.

  IF lt_mat_base[] IS NOT INITIAL.
    SORT lt_mat_base BY mblnr vbeln vbelp_im.
    DELETE ADJACENT DUPLICATES FROM lt_mat_base COMPARING mblnr vbeln vbelp_im.
  ENDIF.

*----------------------------------------------------------------------*
* 687 이력이 아예 없는 납품 건은 통째로 삭제
*----------------------------------------------------------------------*

  " 1. 조회된 전체 데이터 중 '687'을 가진 납품번호(VBELN)만 따로 복사해서 추려냄
  DATA(lt_687_chk) = lt_mat_base[].
  DELETE lt_687_chk WHERE bwart <> '687'.
  SORT lt_687_chk BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_687_chk COMPARING vbeln.

  " 2. 본 데이터(lt_mat_base)를 돌면서, 687 이력이 없는 납품문서면 싹 다 지움
  LOOP AT lt_mat_base INTO DATA(ls_del_chk).
    DATA(lv_tabix) = sy-tabix.

    READ TABLE lt_687_chk TRANSPORTING NO FIELDS
                          WITH KEY vbeln = ls_del_chk-vbeln BINARY SEARCH.
    IF sy-subrc <> 0.
      " 687로 처리된 적이 단 한 번도 없는 일반 601 납품 건이므로 삭제!
      DELETE lt_mat_base INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

*----------------------------------------------------------------------*
* 2. 마스터 명칭(자재명, 고객명) 일괄 가져오기
*----------------------------------------------------------------------*
  SELECT matnr, maktx FROM makt
    INTO TABLE @DATA(lt_makt)
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE matnr EQ @lt_mat_base-matnr
      AND spras EQ @sy-langu.

  SELECT kunnr, name1 FROM kna1
    INTO TABLE @DATA(lt_kna1)
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE kunnr EQ @lt_mat_base-sh_kunnr
       OR kunnr EQ @lt_mat_base-ag_kunnr.

*----------------------------------------------------------------------*
* 영업소/영업그룹 텍스트 마스터 일괄 가져오기
*----------------------------------------------------------------------*
  SELECT vkbur, bezei
    INTO TABLE @DATA(gt_tvkbt)
    FROM tvkbt
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE spras EQ @sy-langu
      AND vkbur EQ @lt_mat_base-vkbur.

  SORT gt_tvkbt BY vkbur.

  SELECT vkgrp, bezei
    INTO TABLE @DATA(gt_tvgrt)
    FROM tvgrt
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE spras EQ @sy-langu
      AND vkgrp EQ @lt_mat_base-vkgrp.

  SORT gt_tvgrt BY vkgrp.

*----------------------------------------------------------------------*
* 3-1. 영업문서 흐름(VBFA) 정보 미리 가져오기
*----------------------------------------------------------------------*
  SELECT vbelv, posnv, vbeln, posnn, bwart, erdat
    INTO TABLE @DATA(gt_vbfa_all)
    FROM vbfa
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE vbeln   EQ @lt_mat_base-vbeln
      AND posnn   EQ @lt_mat_base-uecha
      AND vbtyp_n EQ @c_vbtyp_n
      AND vbtyp_v EQ @c_vbtyp_v.

  SELECT vbelv, posnv, vbeln, posnn, bwart, erdat
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_vbfa_all
    FROM vbfa
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE vbeln   EQ @lt_mat_base-vbeln
      AND posnn   EQ @lt_mat_base-uecha
      AND bwart   EQ '687'
      AND vbtyp_n EQ @c_vbtyp_n
      AND vbtyp_v EQ 'C'.

  SORT gt_vbfa_all BY vbeln posnn.

*----------------------------------------------------------------------*
* 3-2. 빌링(청구) 정보 가져오기 (VBRP / VBRK)
*----------------------------------------------------------------------*
  SELECT
    vbrp~vgbel,
    vbrp~vgpos,
    vbrp~fkimg,
    vbrp~netwr,
    vbrk~fkdat
  FROM vbrp
  INNER JOIN vbrk ON vbrp~vbeln EQ vbrk~vbeln
  FOR ALL ENTRIES IN @lt_mat_base
  WHERE vbrp~vgbel EQ @lt_mat_base-vbeln
    AND vbrp~vgpos EQ @lt_mat_base-uecha
    AND vbrk~sfakn EQ @space
    AND vbrk~fksto EQ @space
*  AND vbrk~fkdat IN @s_fkdat
  INTO TABLE @DATA(lt_vbrp_raw).

*----------------------------------------------------------------------*
* 3-3. 거래명세서 발행일자 가져오기 (추가)
*----------------------------------------------------------------------*
  SELECT a~vbeln, a~posnr, b~iv_date
    FROM zlet0006 AS a
    INNER JOIN zlet0005 AS b ON b~iv_no EQ a~iv_no
    INTO TABLE @DATA(lt_iv_date)
    FOR ALL ENTRIES IN @lt_mat_base
    WHERE a~vbeln EQ @lt_mat_base-vbeln
      AND a~posnr EQ @lt_mat_base-uecha
      AND ( b~iv_cancel_yn EQ ' ' OR b~iv_cancel_yn IS NULL ).

* 중복 제거 및 최종 데이터를 위해 SORT
  SORT lt_iv_date BY vbeln posnr.

* 2. COLLECT나 루프를 통해 수량/금액 합산 및 Max 일자 처리
  TYPES: BEGIN OF ty_vbrp_sum,
           vgbel TYPE vbrp-vgbel,
           vgpos TYPE vbrp-vgpos,
           fkimg TYPE vbrp-fkimg,
           netwr TYPE vbrp-netwr,
           fkdat TYPE vbrk-fkdat,
         END OF ty_vbrp_sum.

  DATA: lt_vbrp TYPE STANDARD TABLE OF ty_vbrp_sum,
        ls_vbrp TYPE ty_vbrp_sum.

  SORT lt_vbrp_raw BY vgbel vgpos.
  LOOP AT lt_vbrp_raw INTO DATA(ls_raw).
    CLEAR ls_vbrp.
    ls_vbrp-vgbel = ls_raw-vgbel.
    ls_vbrp-vgpos = ls_raw-vgpos.
    ls_vbrp-fkimg = ls_raw-fkimg.
    ls_vbrp-netwr = ls_raw-netwr.
    ls_vbrp-fkdat = ls_raw-fkdat.

* 동일 주문/품목에 대해 수량/금액 누적
    COLLECT ls_vbrp INTO lt_vbrp.
  ENDLOOP.

*----------------------------------------------------------------------*
* 4. 데이터 집계 및 GT_DATA 매핑
*----------------------------------------------------------------------*
  TYPES: BEGIN OF ty_sum,
           vbeln    TYPE vbeln_vl,
           posnr    TYPE posnr_vl,
           menge601 TYPE menge_d,
           menge687 TYPE menge_d,
         END OF ty_sum.

  DATA: lt_sum_mat TYPE TABLE OF ty_sum,
        ls_sum_mat TYPE ty_sum.

  DATA: lv_qty_601 TYPE menge_d,
        lv_qty_687 TYPE menge_d.

  DATA(lt_cancel_map) = lt_mat_base.
  LOOP AT lt_cancel_map ASSIGNING FIELD-SYMBOL(<fs_c>).
    IF <fs_c>-sjahr IS INITIAL OR <fs_c>-smbln IS INITIAL.
      CLEAR: <fs_c>-sjahr, <fs_c>-smbln.
    ENDIF.
  ENDLOOP.
  SORT lt_cancel_map BY sjahr smbln.
  DELETE ADJACENT DUPLICATES FROM lt_cancel_map COMPARING sjahr smbln.

  " 2. 출고 정보 SUM 집계 루프
  CLEAR lt_sum_mat.
  REFRESH lt_sum_mat.

  LOOP AT lt_mat_base INTO DATA(ls_m).

    " A. 취소된 원본 전표인지 체크 (존재 여부만 확인하므로 TRANSPORTING NO FIELDS 사용)
    READ TABLE lt_cancel_map TRANSPORTING NO FIELDS
                             WITH KEY sjahr = ls_m-mjahr
                                      smbln = ls_m-mblnr BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE. " 취소된 원본이므로 스킵
    ENDIF.

    " B. 취소 전표 자체인 경우 스킵
    IF ls_m-sjahr IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    " C. 687 중 S(입고/취소 성격)인 경우 스킵
    IF ls_m-bwart = '687' AND ls_m-shkzg = 'S'.
      CONTINUE.
    ENDIF.

    " D. 정상 데이터 매핑 및 집계
    CLEAR ls_sum_mat.

    ls_sum_mat-posnr = ls_m-posnr.
    ls_sum_mat-vbeln = ls_m-vbeln.

    IF ls_m-bwart = '601'.
      ls_sum_mat-menge601 = ls_m-menge.
    ELSEIF ls_m-bwart = '687'.
      ls_sum_mat-menge687 = ls_m-menge.
    ENDIF.

    COLLECT ls_sum_mat INTO lt_sum_mat.

  ENDLOOP.

* 최종 인터널 테이블 조합
  LOOP AT lt_sum_mat INTO DATA(ls_sm).
    CLEAR gs_data.

* 기본 키 매핑
    READ TABLE lt_mat_base INTO DATA(ls_mbase) WITH KEY vbeln = ls_sm-vbeln
                                                        posnr = ls_sm-posnr.
    IF sy-subrc = 0.
      gs_data-vkgrp     = ls_mbase-vkgrp.
      gs_data-vkbur     = ls_mbase-vkbur.
      gs_data-kunag     = ls_mbase-ag_kunnr.
      gs_data-kunnr     = ls_mbase-sh_kunnr.
      gs_data-matnr     = ls_mbase-matnr.
      gs_data-vrkme     = ls_mbase-vrkme.
      gs_data-vbeln     = ls_sm-vbeln.
      gs_data-posnr     = ls_sm-posnr.
      gs_data-vgbel     = ls_mbase-vgbel.
      gs_data-vgpos     = ls_mbase-vgpos.
      gs_data-wadat_ist = ls_mbase-wadat_ist.
      gs_data-kwmeng   = ls_mbase-kwmeng.
      gs_data-netwr       = ls_mbase-netwr.
      gs_data-waerk      = ls_mbase-waerk.
      gs_data-vrkme_o = ls_mbase-vrkme_o.
      gs_data-lfimg       = ls_mbase-lfimg.
    ENDIF.

*------------------------------------------------------------------*
* 거래명세서 발행일자(iv_date) 매핑 추가
*------------------------------------------------------------------*
    READ TABLE lt_iv_date INTO DATA(ls_iv) WITH KEY vbeln = ls_sm-vbeln
                                                  posnr = ls_sm-posnr
                                                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_data-iv_date = ls_iv-iv_date.
    ENDIF.
*------------------------------------------------------------------*
*   IF ls_mbase-spart = '60' AND ls_mbase-bwart NE '687'.
*   IF ls_mbase-spart = '60'.

    DATA: lv_vgpos   TYPE lips-vgpos,
          lv_char    TYPE c LENGTH 1,
          lv_vbeln_v TYPE vbeln_vl,
          lv_f_wadat TYPE d.

*" 문서 흐름(VBFA)에서 해당 납품 건을 찾음
    READ TABLE gt_vbfa_all INTO DATA(ls_vbfa)
      WITH KEY vbeln = ls_mbase-vbeln
               posnn = ls_mbase-posnr
      BINARY SEARCH.

    lv_vgpos = ls_mbase-vgpos.
    lv_char  = lv_vgpos+0(1).
    IF lv_char NE '0'.
      REPLACE lv_char IN lv_vgpos WITH '0'.
    ENDIF.

* 레거시/이관 테이블에서 최초 납품 정보 조회
    SELECT SINGLE a~vbeln, a~wadat_ist
      FROM zlikp_r3 AS a
      INNER JOIN zlips_r3 AS b ON a~vbeln EQ b~vbeln
      INTO (@lv_vbeln_v, @lv_f_wadat)
      WHERE b~vgbel EQ @ls_mbase-vgbel
        AND b~vgpos EQ @lv_vgpos.

    IF sy-subrc = 0 AND lv_f_wadat IS NOT INITIAL.
      gs_data-f_wadat = lv_f_wadat.   " 최초 납품일자 매핑
      gs_data-vbeln_v = lv_vbeln_v.   " 최초 납품문서 매핑
    ELSE.
      PERFORM get_spart60_data USING ls_vbfa-vbelv
                                                          ls_vbfa-posnv
                                                          gs_data-f_wadat
                                                          gs_data-vbeln_v.
    ENDIF.

*  ELSE.
    IF gs_data-vbeln_v IS INITIAL AND gs_data-f_wadat IS INITIAL.
      gs_data-vbeln_v = ls_mbase-vbeln.
      gs_data-f_wadat = ls_mbase-wadat_ist.
    ENDIF.
*  ENDIF.

* 텍스트 매핑 (지급처명 / 납품처명 / 자재명)
    READ TABLE lt_kna1 INTO DATA(ls_kna1) WITH KEY kunnr = gs_data-kunag.
    IF sy-subrc = 0. gs_data-name1 = ls_kna1-name1. ENDIF.

    READ TABLE lt_kna1 INTO DATA(ls_kna1_sh) WITH KEY kunnr = gs_data-kunnr.
    IF sy-subrc = 0. gs_data-name1_sh = ls_kna1_sh-name1. ENDIF.

    READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = gs_data-matnr.
    IF sy-subrc = 0.
      gs_data-maktx = ls_makt-maktx.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gs_data-matnr
      IMPORTING
        output = gs_data-matnr.

    READ TABLE gt_tvkbt INTO DATA(ls_tvkbt) WITH KEY vkbur = gs_data-vkbur
                                                BINARY SEARCH.
    IF sy-subrc = 0.
      gs_data-bezei = ls_tvkbt-bezei.  " 사업장명/영업소명
    ENDIF.

    READ TABLE gt_tvgrt INTO DATA(ls_tvgrt) WITH KEY vkgrp = gs_data-vkgrp
                                              BINARY SEARCH.
    IF sy-subrc = 0.
      gs_data-bezei2 = ls_tvgrt-bezei. " 영업그룹명
    ENDIF.

* 빌링 정보 매핑
    CLEAR ls_vbrp.
    READ TABLE lt_vbrp INTO ls_vbrp WITH KEY vgbel = gs_data-vbeln
                                              vgpos = gs_data-posnr.
    IF sy-subrc = 0.
      gs_data-fkdat  = ls_vbrp-fkdat.
      gs_data-fk_qty = ls_vbrp-fkimg.
      gs_data-netwr  = ls_vbrp-netwr.
    ENDIF.

    " 집계 테이블에서 값 가져오기
    READ TABLE lt_sum_mat INTO DATA(ls_s_sum) WITH KEY vbeln = ls_sm-vbeln
                                                       posnr = ls_sm-posnr.
    IF sy-subrc = 0.
      lv_qty_601 = ls_s_sum-menge601.
      lv_qty_687 = ls_s_sum-menge687.
    ENDIF.

    " 최종 수량 산출
    gs_data-gi_qty   = lv_qty_601.
    gs_data-stock_it = lv_qty_687.

* 운송중 재고 수량 산출 (출고 - 청구)
*  gs_data-stock_it = gs_data-gi_qty - gs_data-fk_qty.
* 운송중 재고 수량 산출 (출고 - 운송중재고수량)
  gs_data-stock_it = gs_data-stock_it - gs_data-gi_qty.
  IF gs_data-stock_it < 0.
    gs_data-stock_it = 0.
  ENDIF.

*  IF gs_data-stock_it < 0.
*    gs_data-stock_it = 0.
*  ENDIF.

* 단가(소수5자리) : 주문금액 / 주문수량
    IF gs_data-kwmeng NE 0.
      gs_data-netpr2 = gs_data-netwr / gs_data-kwmeng.
    ENDIF.

* 수량단위 확인 및 금액 산출
    IF gs_data-vrkme <> gs_data-vrkme_o.
      CALL FUNCTION 'Z_TE_CALC_ITEM_AMOUNT_DO'
        EXPORTING
          im_vbeln = gs_data-vbeln
          im_posnr = gs_data-posnr
          im_wmeng = gs_data-lfimg
          im_type  = 'D'
        IMPORTING
          ex_netwr = gs_data-netwr.
    ELSE.
* 금액 : 단가(소수5자리) * 납품수량
      gs_data-netwr = gs_data-netpr2 * gs_data-lfimg.
    ENDIF.

* 원화금액 환산
    IF gs_data-waerk NE 'KRW'.
      gs_data-k_netwr = gs_data-netwr * gs_data-kursk.
      gs_data-k_netwr = gs_data-k_netwr / 100.
      IF gs_data-lfimg NE 0.
        gs_data-netpr = gs_data-k_netwr / gs_data-lfimg.
      ENDIF.
    ELSE.
      gs_data-k_netwr = gs_data-netwr.
      gs_data-netpr   = gs_data-netpr2.
    ENDIF.

    APPEND gs_data TO gt_data.
  ENDLOOP.

*  SELECT
*    lips~vbeln
*    lips~posnr
*    lips~ormng AS lfimg
*    lips~vgbel
*    lips~vgpos
*
*   INTO CORRESPONDING FIELDS OF TABLE GT_dATA
*    FROM likp AS likp
*    INNER JOIN lips AS lips
*      ON likp~vbeln EQ lips~vbeln
*    WHERE likp~vstel = '3450'
*    AND likp~wadat_ist IN s_wadat
*    AND lips~bwart = '687'
*    AND lips~vtweg = '10'
*    AND lips~spart = '60'
*    AND lips~vbeln IN s_vbeln
*    AND likp~kunag IN s_kunnr
*    AND lips~vkgrp IN s_vkgrp
*    AND lips~uecha = ' '.
*
*  CHECK gt_data[] IS NOT INITIAL.
*
*  r_XBLNR[] = VALUE #( FOR ls_tmp IN GT_dATA
*                       ( sign = 'I'
*                         option = 'EQ'
*                         low = ls_tmp-vbeln
*                         high = '' ) ).
*  SORT r_xblnr.
*  DELETE ADJACENT DUPLICATES FROM r_xblnr COMPARING ALL FIELDS.
*
*
*  SELECT
*    mat~mblnr AS mblnr
*    mat~mjahr AS mjahr
*    mat~zeile AS zeile
*    mat~sjahr AS sjahr
*    mat~smbln AS smbln
*    mat~bwart AS bwart
*    mat~vbeln_im AS mat_kdauf
**  VBELP_IM AS MAT_KDPOS
*    mat~menge AS menge
*    lips~posnr AS posnr
*    lips~uecha AS uecha
*    mat~shkzg AS shkzg
*    INTO CORRESPONDING FIELDS OF TABLE gt_zmseg
*    FROM matdoc AS mat
*    INNER JOIN lips AS lips
*     ON mat~vbeln_im EQ lips~vbeln
*    AND mat~vbelp_im EQ lips~posnr
*    WHERE xblnr IN r_xblnr
*    AND budat IN s_fkdat.
*
*  lt_zmseg[] = VALUE #( FOR ls_tmp2 IN gt_zmseg
*                       ( sjahr = ls_tmp2-sjahr
*                         smbln = ls_tmp2-smbln ) ).
*  SORT lt_zmseg BY sjahr smbln.
*  DELETE ADJACENT DUPLICATES FROM lt_zmseg COMPARING ALL FIELDS.
*
*
**___ 출고정보 가져오기
*  SELECT
*    * INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
*    FROM vbrp AS vbrp
*    INNER JOIN vbrk
*    ON vbrp~vbeln EQ vbrk~vbeln
*    FOR ALL ENTRIES IN gt_data
*    WHERE vbrp~vgbel = gt_data-vbeln
*    AND   vbrp~vgpos = gt_data-posnr
*    AND   vbrk~sfakn = ' '
*    AND   vbrk~fksto = ' '
*    AND   vbrk~fkdat IN s_fkdat.
*
**___ 출고정보 SUM
*  LOOP AT Gt_zmseg.
*
*    READ TABLE lt_zmseg WITH KEY sjahr = gt_zmseg-mjahr smbln = gt_zmseg-mblnr BINARY SEARCH.
*    IF sy-subrc = 0.
*      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
*    ELSEIF gt_zmseg-sjahr <> ' '.
*      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
*    ELSEIF gt_zmseg-bwart = '687' AND gt_zmseg-shkzg = 'S'.
*      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
*    ELSE.
*      MOVE-CORRESPONDING gt_zmseg TO gt_SUM.
*      IF gt_zmseg-uecha IS NOT INITIAL.
*        gt_sum-mat_kdpos = gt_zmseg-uecha.
*      ELSE.
*        gt_sum-mat_kdpos = gt_zmseg-posnr.
*      ENDIF.
*      IF gt_ZMSEG-bwart = '601'.
*        gt_SUM-601 = gt_zmseg-menge.
*      ELSEIF gt_ZMSEG-bwart = '687'.
*        gt_SUM-687 = gt_zmseg-menge.
*      ELSE.
*        gt_SUM-etc = gt_zmseg-menge.
*      ENDIF.
*      COLLECT gt_SUM . CLEAR : gt_SUM.
*    ENDIF.
*  ENDLOOP.
*
**___ 판매정보 SUM
*  LOOP AT gt_vbrp.
*    gt_SUM-mat_kdauf = gt_vbrp-vgbel.
*    gt_SUM-mat_kdpos = gt_vbrp-vgpos.
*    gt_sum-fkimg = gt_vbrp-fkimg.
*
*    COLLECT gt_sum. CLEAR  :gt_sum.
*  ENDLOOP.
*
**___납품문서별 정보 입력
*  SORT gt_sum BY mat_kdauf mat_kdpos.
*  LOOP AT gt_data .
*    READ TABLE gt_sum WITH KEY mat_kdauf = gt_data-vbeln
*                               mat_kdpos = gt_data-posnr
*                               BINARY SEARCH.
*    CHECK sy-subrc = 0 .
*
*    MOVE-CORRESPONDING gt_sum TO gt_data.
*    gt_data-lfimg601 = gt_sum-601.
*    gt_data-lfimg687 = gt_sum-687.
*
*    MODIFY gt_data.  CLEAR : gt_data.
*  ENDLOOP.
*
**___ 차이수량 계산
*  LOOP AT gt_data .
*    gt_data-gap1 = gt_data-lfimg601 - gt_data-fkimg. " 출고는 했지만 매출처리 안됨
*    gt_data-gap2 = gt_data-fkimg - gt_data-lfimg601. " 매출은 되었지만 출고안됨.
*    IF gt_data-gap1 < 0 .
*      gt_data-gap1 = 0.
*    ENDIF.
*    IF gt_data-gap2 < 0 .
*      gt_data-gap2 = 0.
*    ENDIF.
*    MODIFY gt_data.  CLEAR : gt_data.
*  ENDLOOP.
*
*  DELETE gt_data WHERE gap1 = 0 AND gap2 = 0.
*
**___ 기타정보 가져오기
*  LOOP AT gt_data.
*    SELECT SINGLE vgbel vgpos matnr
*      INTO (gt_data-vgbel, gt_data-vgpos, gt_data-matnr)
*      FROM lips
*      WHERE vbeln = gt_data-vbeln
*      AND   posnr = gt_data-posnr.
*
*    SELECT SINGLE kunnr
*      INTO GT_dATA-kunnr
*      FROM vbak
*      WHERE vbeln = gt_data-vgbel.
*
*    SELECT SINGLE kdkg4
*      INTO GT_dATA-kdkg4
*      FROM vbkd
*      WHERE vbeln = GT_dATA-vgbel.
*
*    MODIFY gt_data . CLEAR : GT_dATA.
*  ENDLOOP.
*
*  IF s_kdkg4[] IS NOT INITIAL.
*    DELETE gt_data WHERE kdkg4 NOT IN s_kdkg4.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_WRITE_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_write_rtn .

** ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM  alvprn_basic.
*  PERFORM  alvprn_header.
  PERFORM  alvprn_field.

** ALV DISPLAY
  PERFORM  alv_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_BASIC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_basic .


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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_header .


  DATA : l_data1(100),
         l_data2(100),
         l_data3(100),
         l_data4(100),
         l_data5(100),
         l_kunnr LIKE kna1-kunnr.

  REFRESH g_list_top_of_page_t.


*  CONCATENATE  G_ITAB_T-VKBUR '(' G_ITAB_T-TEXT02 ')'
*         INTO  L_DATA1.
*
*  CONCATENATE  G_ITAB_T-VKGRP '(' G_ITAB_T-TEXT03 ')'
*         INTO  L_DATA2.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = G_ITAB_T-KUNNR
*    IMPORTING
*      OUTPUT = L_KUNNR.
*
*  CONCATENATE  L_KUNNR '(' G_ITAB_T-NAME1 ')'
*         INTO  L_DATA3.

  PERFORM header_setting TABLES g_list_top_of_page_t
                          USING: 'S'  '출고-빌링  : ' '출고후 빌링 미처리 수량',
                                 'S'  '빌링-출고  : ' '빌링은 되었으나 미출고 수량'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_field .

  REFRESH: g_field_t, g_fieldcat_t.

* FIELD발췌
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_program_name         = g_program
*      i_internal_tabname     = 'GT_DATA'
*      i_client_never_display = 'X'
*      i_inclname             = g_program
*      i_bypassing_buffer     = 'X'
*      i_buffer_active        = 'X'
*    CHANGING
*      ct_fieldcat            = g_field_t[].

  DATA(lo_struct) = CAST cl_abap_structdescr(
    cl_abap_typedescr=>describe_by_data( gs_data )
  ).
  DATA(lt_dfies) = cl_salv_data_descr=>read_structdescr( lo_struct ).
  DATA(lt_fcat) = CORRESPONDING lvc_t_fcat( lt_dfies MAPPING ref_table = reftable
                                                  ref_field = reffield ).

  CALL FUNCTION 'LVC_TRANSFER_TO_SLIS'
    EXPORTING
      it_fieldcat_lvc = lt_fcat
    IMPORTING
      et_fieldcat_alv = g_field_t[].

  PERFORM field_setting TABLES g_fieldcat_t
    USING :

      'S' 'VKBUR'   ' ',
      ' ' 'SELTEXT_L'   '영업팀',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '1',

       'S' 'BEZEI'       ' ',
        ' ' 'SELTEXT_L'   '영업팀',
       ' ' 'DDICTXT'     'L',
       ' ' 'OUTPUTLEN'   '20',
       'E' 'COL_POS'     '2',

      'S' 'VKGRP'   ' ',
      ' ' 'SELTEXT_L'   '영업그룹',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '3',

     'S' 'BEZEI2'      ' ',
     ' ' 'SELTEXT_L'   '영업그룹',
     ' ' 'DDICTXT'     'L',
     ' ' 'OUTPUTLEN'   '20',
     'E' 'COL_POS'     '4',

      'S' 'KUNAG'   ' ',
       ' ' 'SELTEXT_L'   '지급처',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '5',

      'S' 'NAME1'   ' ',
      ' ' 'SELTEXT_L'   '지급처명',
      ' ' 'DDICTXT'     'L',
    ' ' 'OUTPUTLEN'   '35',
     'E' 'COL_POS'     '6',

      'S' 'MATNR'   ' ',
      ' ' 'SELTEXT_L'   '자재코드',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '7',

      'S' 'MAKTX'   ' ',
      ' ' 'SELTEXT_L'   '자재명',
     ' ' 'DDICTXT'     'L',
     ' ' 'OUTPUTLEN'   '20',
     'E' 'COL_POS'     '8',

      'S' 'STOCK_IT'   ' ',
     ' ' 'SELTEXT_L'   '운송중재고 수량',
    ' ' 'QFIELDNAME'  'VRKME',
    ' ' 'DDICTXT'     'L',
    ' ' 'OUTPUTLEN'   '10',
     'E' 'COL_POS'     '9',

    'S'   'VRKME'       ' ',
   ' '   'SELTEXT_M'   '단위',
   ' '   'KEY'         ' ',
  'E'   'DDICTXT'     'M',

       'S' 'F_WADAT'     ' ',
       ' ' 'SELTEXT_L'   '최초출고일',
       ' ' 'DDICTXT'     'L',
       ' ' 'OUTPUTLEN'   '10',
       'E' 'COL_POS'     '11',

      'S' 'IV_DATE'     ' ',
      ' ' 'SELTEXT_L'   '거래명세서 발행일자',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '12',

      'S' 'WADAT_IST'       ' ',
      ' ' 'SELTEXT_L'   'G/I Date',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '13',
      'E' 'KEY'         ' ',

       'S' 'VBELN'       ' ',
       ' ' 'SELTEXT_L'   '납품번호',
       ' ' 'DDICTXT'     'L',
       ' ' 'OUTPUTLEN'   '10',
       ' ' 'COL_POS'     '14',
       'E' 'KEY'         'X',

      'S' 'VBELN_V'     ' ',
      ' ' 'SELTEXT_L'   '최초납품문서',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '15',

      'S' 'VGBEL'       ' ',
      ' ' 'SELTEXT_L'   '주문번호',
     ' ' 'DDICTXT'     'L',
     ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '16',

      'S' 'VGPOS'       ' ',
      ' ' 'SELTEXT_L'   '주문품목',
     ' ' 'DDICTXT'     'L',
     ' ' 'OUTPUTLEN'   '10',
    'E' 'COL_POS'     '17',

    'S' 'NAME1_SH'       ' ',
     ' ' 'SELTEXT_L'   '납품처명',
    ' ' 'DDICTXT'     'L',
   ' ' 'OUTPUTLEN'   '35',
   'E' 'COL_POS'     '18',

    'S' 'K_NETWR'     ' ',
   ' ' 'SELTEXT_L'   '납품금액(원화)',
   ' ' 'CFIELDNAME'  'WAERK',
   ' ' 'DDICTXT'     'L',
  ' ' 'OUTPUTLEN'   '20',
 ' ' 'JUST'        'R',
*                               ' ' 'CURRENCY'    'KRW',
 'E' 'COL_POS'     '19'.

ENDFORM.

FORM alv_display.

  g_save  =  'A'.

 IF NOT ( SY-UNAME = 'ZLSGSD6' AND SY-TCODE NE 'ZGTSDR1310' ).
       DELETE gt_data WHERE stock_it EQ 0.
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
*       it_fieldcat             = g_field_t[]
      IMPORTING
        e_exit_caused_by_caller = g_exit_caused_by_caller
        es_exit_caused_by_user  = g_exit_caused_by_user_s
      TABLES
        t_outtab                = gt_data.

ENDFORM.
*-------------------------------------------------------------------*
*        Form  PF_STATUS_SET
*-------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*-------------------------------------------------------------------*
FORM pf_status_set USING p_rt_extab TYPE slis_t_extab.

    SET PF-STATUS '1000'.
    SET TITLEBAR '1000'.

ENDFORM.                    "pf_status_set
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = ' '
      it_list_commentary = g_list_top_of_page_t.

ENDFORM.

FORM  user_command USING p_ucomm    LIKE sy-ucomm
                         p_selfield TYPE slis_selfield.

  CASE p_ucomm.

    WHEN '&IC1'.

      CASE p_selfield-sel_tab_field.

        WHEN 'GT_DATA-VGBEL'.
*          READ TABLE gt_data INDEX p_selfield-tabindex.
*          PERFORM  call_va03  USING  gt_data-vgbel.

        WHEN 'GT_DATA-VBELN'.
*          READ TABLE gt_data INDEX p_selfield-tabindex.
*          PERFORM  call_vbeln  USING  gt_data-vbeln.
      ENDCASE.


    WHEN  'BACK' OR 'EXIT' OR 'CANC'.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.
FORM call_va03  USING    p_value.

  CHECK NOT p_value IS INITIAL.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   p_value.

* CALL TRANSACTION
  CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.
FORM call_vbeln  USING    pv_vbeln.

  SELECT SINGLE mandt INTO sy-mandt
    FROM vbrk
   WHERE vbeln = pv_vbeln.
    IF sy-subrc = 0.
      SET PARAMETER ID: 'VF'    FIELD   pv_vbeln.
      CALL TRANSACTION  'VF03' AND SKIP FIRST SCREEN.
      COMMIT WORK AND WAIT.
      EXIT.
    ENDIF.

    SELECT SINGLE mandt INTO sy-mandt
      FROM likp
     WHERE vbeln = pv_vbeln.
      IF sy-subrc = 0.
        SET PARAMETER ID: 'VL'    FIELD   pv_vbeln.
        CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
        EXIT.
      ENDIF.

      SELECT SINGLE mandt INTO sy-mandt
        FROM vbak
       WHERE vbeln = pv_vbeln.
        IF sy-subrc = 0.
          SET PARAMETER ID: 'AUN'    FIELD   pv_vbeln.
          CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
          EXIT.
        ENDIF.

ENDFORM.
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
