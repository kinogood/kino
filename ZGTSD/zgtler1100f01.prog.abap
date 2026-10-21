*&---------------------------------------------------------------------*
*&  Include           ZLER0401F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_init_parameter .
  TYPE-POOLS: vrm.
  DATA: lv_name  TYPE vrm_id,
        lt_list  TYPE vrm_values,
        ls_value LIKE LINE OF lt_list.

  CLEAR   : gr_auart, s_erdat, s_edatu, s_erdat1, lt_list.
  REFRESH : gr_auart, s_erdat, s_edatu, s_erdat1, lt_list.

*___출하요청 대상 오더유형
  set_ranges: gr_auart 'I' 'EQ' 'RE'   ' ',
              gr_auart 'I' 'EQ' 'TA'   ' ',        "OR
              gr_auart 'I' 'EQ' 'ZCS'  ' ',
              gr_auart 'I' 'EQ' 'ZEXE' ' ',
              gr_auart 'I' 'EQ' 'ZFQ'  ' ',
              gr_auart 'I' 'EQ' 'ZFS'  ' ',
              gr_auart 'I' 'EQ' 'ZORQ' ' ',
              gr_auart 'I' 'EQ' 'ZREQ' ' '.

*___Transaction 유형
  CASE sy-tcode.
    WHEN gc_tcode1.                  "생성
      gv_trtyp = 'H'.
      gv_title = '생성'.

    WHEN gc_tcode2.                  "변경
      gv_trtyp = 'V'.
      gv_title = '변경'.

    WHEN gc_tcode4.                  "변경 - 통합물류
      gv_trtyp = 'V'.
      gv_title = '변경 - 통합물류'.

    WHEN OTHERS.                     "조회
      gv_trtyp = 'A'.
      gv_title = '조회'.

  ENDCASE.

  SET TITLEBAR '0100' WITH gv_title.

*___선택조건 기본값
  CASE sy-tcode.
    WHEN gc_tcode1.
*___판매오더 생성일
      s_erdat-sign     = 'I'.
      s_erdat-option   = 'BT'.

      PERFORM add_month_to_date USING sy-datlo '2' '-' s_erdat-low.

*      S_ERDAT-LOW      = SY-DATLO.
      s_erdat-low+6(2) = '01'.
      s_erdat-high     = sy-datlo.
      APPEND s_erdat.

*___납품요청일
      s_edatu-sign   = 'I'.
      s_edatu-option = 'BT'.

*___전월 1일
      PERFORM add_month_to_date USING sy-datlo '1' '-' s_edatu-low.
      s_edatu-low+6(2) = '01'.

*___당월 말일
      PERFORM last_day_of_months USING sy-datlo s_edatu-high.

      APPEND s_edatu.

*___업로드 버튼
      functxt-icon_id       = icon_import.
      functxt-quickinfo     = 'Upload'.
      functxt-icon_text     = 'Upload'.
      sscrfields-functxt_01 = functxt.

    WHEN OTHERS.
*___출하요청 생성일
      s_erdat1-sign     = 'I'.
      s_erdat1-option   = 'BT'.

*      PERFORM ADD_MONTH_TO_DATE USING SY-DATLO '2' '-' S_ERDAT1-LOW.

      s_erdat1-low      = sy-datlo.
      s_erdat1-low+6(2) = '01'.
      s_erdat1-high     = sy-datlo.
      APPEND s_erdat1.

*___운송유형
      lv_name = 'P_TRTYP'.

      ls_value-key  = '00'.
      ls_value-text = '전체'.
      APPEND ls_value TO lt_list.

      SELECT a~domvalue_l
             b~ddtext
        INTO (ls_value-key, ls_value-text)
        FROM dd07l AS a
       INNER JOIN dd07t AS b
          ON a~domname = b~domname
         AND b~ddlanguage = sy-langu
         AND a~as4local   = b~as4local
         AND a~valpos     = b~valpos
         AND a~as4vers    = b~as4vers
       WHERE a~domname    = 'ZDTRTYP'.

        APPEND ls_value TO lt_list.

      ENDSELECT.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = lv_name
          values = lt_list.

  ENDCASE.

ENDFORM.                    " SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHRIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_authrization .
  DATA: BEGIN OF lt_tvst OCCURS 0,
          vstel LIKE tvst-vstel,
        END   OF lt_tvst.

  DATA: lv_subrc    LIKE sy-subrc.

  CLEAR   : lt_tvst.
  REFRESH : lt_tvst.

  CASE sy-tcode.
    WHEN gc_tcode1.
      SELECT vstel
        INTO CORRESPONDING FIELDS OF TABLE lt_tvst
        FROM tvst
       WHERE vstel IN s_vstel.

    WHEN OTHERS.
      SELECT vstel
        INTO CORRESPONDING FIELDS OF TABLE lt_tvst
        FROM tvst
       WHERE vstel IN s_vstel1.

  ENDCASE.

  LOOP AT lt_tvst.
    CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vstel = lt_tvst-vstel
        i_type  = '3'
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
      MESSAGE e004 WITH '출하지점' lt_tvst-vstel
                        '에 대한 권한이 없습니다.'.
    ENDIF.
  ENDLOOP.

*->>[가온전선]------------------------------------------------------S
*-영업그룹
  CASE sy-tcode.
    WHEN gc_tcode1.
      SELECT vkgrp
        FROM tvbvk
       WHERE vkgrp IN @s_vkgrp
        INTO TABLE @DATA(lt_vkgrp).
    WHEN OTHERS.
      SELECT vkgrp
        FROM tvbvk
       WHERE vkgrp IN @s_vkgrp1
        INTO CORRESPONDING FIELDS OF TABLE @lt_vkgrp.

  ENDCASE.

  LOOP AT lt_vkgrp INTO DATA(ls_vkgrp).
    CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vkgrp = ls_vkgrp-vkgrp
        i_type  = '7'
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
      MESSAGE e004 WITH '영업그룹' ls_vkgrp-vkgrp
                        '에 대한 권한이 없습니다.'.
    ENDIF.
  ENDLOOP.

*-<<[가온전선]------------------------------------------------------E

ENDFORM.                    " CHECK_AUTHRIZATION
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_order_data .
  RANGES: lr_kdkg4  FOR  vbkd-kdkg4.

  CLEAR   : gt_main, lr_kdkg4.
  REFRESH : gt_main, lr_kdkg4.

  CASE 'X'.
    WHEN p_r12.      "내수/로컬
      set_ranges: lr_kdkg4 'I' 'EQ' '4D' ' ',
                  lr_kdkg4 'I' 'EQ' '4L' ' '.

    WHEN p_r13.      "수출
      set_ranges: lr_kdkg4 'I' 'EQ' '4E' ' ',
                  lr_kdkg4 'I' 'EQ' '4S' ' '.

    WHEN OTHERS.    "전체

  ENDCASE.


  SELECT b~vbeln,            "판매오더
         b~posnr,            "판매오더품목
         a~auart,            "영업문서유형
         a~vkorg,            "영업조직
         a~vkbur,           "영업팀
         a~vkgrp,            "영업그룹
         g~lifnr,            "영업사원
         a~kunnr AS kunag,   "판매처
         d~kdkg4,            "내수/수출
         b~sobkz,            "특별재고지시자
         b~matnr,            "자재
         b~kwmeng,           "오더수량
         b~vrkme,            "판매단위
         b~vstel,            "출하지점
         b~werks,            "플랜트
         b~lgort,            "저장위치 "기능개선 231127 - 추가
         b~spart,            "제품군
         e~edatu,            "납품일정
         b~abgru,            "거절사유
         a~lifsk,            "납품보류
         a~erdat,
         a~vtweg,

         a~kkber,            "여신영역
         h~assigned_bp AS kunrg, "지급처 BP
         b~waerk,
         b~netwr,            "금액
         b~mwsbp,            "세금
         b~fixmg             "납품일 및 수량(고정)
    FROM vbak AS a
   INNER JOIN vbap AS b
      ON a~vbeln = b~vbeln
   INNER JOIN vbkd AS d
      ON a~vbeln = d~vbeln
     AND d~posnr = '000000'
   INNER JOIN vbep AS e
      ON b~vbeln = e~vbeln
     AND b~posnr = e~posnr
     AND e~etenr = '0001'
     AND e~lifsp = @space    "납품보료 제외
   INNER JOIN vbpa AS g
      ON a~vbeln = g~vbeln
     AND g~posnr = '000000'
     AND g~parvw = 'VE'      "영업사원(PE)
   LEFT OUTER JOIN vbpa AS h
      ON a~vbeln = h~vbeln
     AND h~posnr = '000000'
     AND h~parvw = 'RG'      "지급처
   WHERE a~vkorg =  @gc_vkorg
     AND a~auart IN @s_auart
     AND a~auart IN @gr_auart
     AND a~erdat IN @s_erdat
     AND a~vkbur IN @s_vkbur
     AND a~vkgrp IN @s_vkgrp
     AND a~kunnr IN @s_kunag
     AND a~vbeln IN @s_vbeln
     AND b~vstel IN @s_vstel
     AND a~spart IN @s_spart
     AND b~werks IN @s_werks
     AND b~matnr IN @s_matnr
     AND b~abgru NOT BETWEEN '01' AND '11'
     AND d~kdkg4 IN @lr_kdkg4
     AND e~edatu IN @s_edatu
     AND g~lifnr IN @s_lifnr
     AND b~gbsta <> 'C'
    INTO TABLE @DATA(lt_main).

  CHECK lt_main[] IS NOT INITIAL.
  LOOP AT lt_main ASSIGNING FIELD-SYMBOL(<ls_main>).
    REPLACE FIRST OCCURRENCE OF 'E' IN <ls_main>-lifnr WITH space.
    CLEAR gt_main.
    MOVE-CORRESPONDING <ls_main> TO gt_main.
    gt_main-pernr = <ls_main>-lifnr.
    APPEND gt_main.
  ENDLOOP.

*<-
  PERFORM get_order_data_etc.

ENDFORM.                    " GET_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_DATA_ETC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_order_data_etc .
  DATA: lv_bstkd    LIKE vbkd-bstkd.

  LOOP AT gt_main.
*___납품처
    SELECT SINGLE kunnr
                  adrnr
      INTO (gt_main-kunwe, gt_main-adrnr)
      FROM vbpa
     WHERE vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr
       AND parvw = 'WE'.      "납품처(SH)

    IF sy-subrc <> 0.
      SELECT SINGLE kunnr
                    adrnr
        INTO (gt_main-kunwe, gt_main-adrnr)
        FROM vbpa
       WHERE vbeln = gt_main-vbeln
         AND posnr = '000000'
         AND parvw = 'WE'.      "납품처(SH)
    ENDIF.

    IF gt_main-kunwe NOT IN s_kunwe.
      DELETE gt_main.
      CONTINUE.
    ENDIF.

*___제조지시번호
    PERFORM get_order_jobno USING gt_main-vbeln
                                  gt_main-posnr
                                  gt_main-jobno.

    IF gt_main-jobno NOT IN s_jobno.
      DELETE gt_main.
      CONTINUE.
    ENDIF.

*___PO번호/PO일자
    PERFORM get_customer_po USING gt_main-vbeln
                                  gt_main-posnr
                                  gt_main-bstkd
                                  gt_main-bstdk  "기능개선 161289 - 추가
                                  gt_main-empst. "기능개선 164038 - 추가

*___확정수량
    SELECT SUM( bmeng )
      INTO gt_main-bmeng
      FROM vbep
     WHERE vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr.

*___조장
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_length
                                        gt_main-indlen.

*___색상
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_cbase
                                        gt_main-color.

*{ 기능개선 161289 - 추가
*___절연선심식별 코드
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_inscd
                                        gt_main-inscd.
*} 기능개선 161289 - 추가

*___출하요청정보
    PERFORM get_zlet0401_data.

*___확정수량이 있고 요청가능수량이 없으면 제외
    IF gt_main-auart <> 'RE' AND gt_main-auart <> 'ZREQ' AND
       gt_main-ramng IS INITIAL AND gt_main-bmeng IS NOT INITIAL.
      DELETE gt_main.
      CONTINUE.
    ENDIF.

*___조장수
    IF gt_main-indlen IS NOT INITIAL.
      gt_main-indqty = gt_main-kwmeng / gt_main-indlen.
      gt_main-drind  = gt_main-dlrmg  / gt_main-indlen.
    ENDIF.

*___판매처 명
    PERFORM get_kunnr_desc USING: gt_main-kunag
                                  gt_main-namag.

*___영업사원명
    PERFORM get_pernr_desc USING gt_main-pernr
                                 gt_main-sname.

*___여신상태
    PERFORM get_vbuk_data USING gt_main-vbeln
                                gt_main-cmgst.

*___MTO/MTS
    IF gt_main-fixmg IS NOT INITIAL.
      gt_main-sotxt = 'MTS'.
    ELSE.
      gt_main-sotxt = 'MTO'.
    ENDIF.
*    IF GT_MAIN-SOBKZ IS NOT INITIAL.
*      GT_MAIN-SOTXT = 'MTO'.
*    ELSE.
*      GT_MAIN-SOTXT = 'MTS'.
*    ENDIF.

*___제품명
    PERFORM get_matnr_desc USING gt_main-matnr
                                 gt_main-maktx.

*___출하지점명
    PERFORM get_vstel_desc USING gt_main-vstel
                                 gt_main-vtext.

*___플랜트명
    PERFORM get_werks_desc USING gt_main-werks
                                 gt_main-name1.

*___납품처 정보 - 납품처명/우편번호/국가/운송지역/상세주소/수령인/연락처
    PERFORM get_ship_to_info USING gt_main-adrnr
                                   gt_main-namwe
                                   gt_main-post_code1
                                   gt_main-land1
                                   gt_main-lzone
                                   gt_main-city1
                                   gt_main-extension1
                                   gt_main-tel_number
                                   'X'.

*___운송유형 - 기본값
*    GT_MAIN-TRTYP = '01'.    "차량

*___분할출하 - 기본값
    gt_main-divid = 'X'.

*___가용성
    IF gt_main-bmeng IS INITIAL.
      gt_main-avlbt = '미확정'.
    ELSEIF gt_main-kwmeng > gt_main-bmeng.
      gt_main-avlbt = '부분확정'.
    ELSE.
      gt_main-avlbt = '확정'.
    ENDIF.

*___가용재고/품질재고
    PERFORM get_stock_data USING gt_main-matnr
                                 gt_main-vstel   "기능개선 231127 - 추가
                                 gt_main-werks
                                 gt_main-lgort   "기능개선 231127 - 추가
                                 gt_main-vbeln
                                 gt_main-posnr
                                 gt_main-sobkz
                                 gt_main-vrkme
                                 gt_main-labst
                                 gt_main-insme.

*___특이사항(비고) 기본값
    PERFORM get_remark_data USING gt_main-vstel
                                  gt_main-kunwe
                                  gt_main-remark.

*___수출/내수 구분
    IF gt_main-kdkg4 = '4D' OR gt_main-kdkg4 = '4L'.
      gt_main-trade = 'D'.    "내수
    ELSE.
      gt_main-trade = 'E'.    "수출
    ENDIF.

    gt_main-indmei = 'EA'.

*___출하요납품생성 단위 Key Field
    MOVE-CORRESPONDING gt_main TO gt_main-keyno.

    SELECT SINGLE zterm
      INTO gt_main-zterm
      FROM vbkd
      WHERE vbeln = gt_main-vbeln
      AND   posnr = gt_main-posnr.
    IF sy-subrc <> 0.
      SELECT SINGLE zterm
       INTO gt_main-zterm
       FROM vbkd
       WHERE vbeln = gt_main-vbeln
       AND   posnr =  ' '.
    ENDIF.

    MODIFY gt_main.
  ENDLOOP.

ENDFORM.                    " GET_ORDER_DATA_ETC
*&---------------------------------------------------------------------*
*&      Form  GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_kunnr_desc  USING    pv_kunnr
                              pv_name1.

  CLEAR : pv_name1.

  CHECK pv_kunnr IS NOT INITIAL.

  READ TABLE gt_kna1 WITH KEY kunnr = pv_kunnr
                     BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_kna1.

    SELECT SINGLE kunnr
                  name1
      INTO gt_kna1
      FROM kna1
     WHERE kunnr = pv_kunnr.

    IF sy-subrc = 0.
      APPEND gt_kna1.

      SORT gt_kna1 BY kunnr.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_name1 = gt_kna1-name1.
  ENDIF.

ENDFORM.                    " GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_matnr_desc  USING    pv_matnr
                              pv_maktx.

  CLEAR : pv_maktx.

  CHECK pv_matnr IS NOT INITIAL.

  READ TABLE gt_makt WITH KEY matnr = pv_matnr
                     BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_makt.

    SELECT SINGLE a~matnr
                  b~maktx
      INTO gt_makt
      FROM mara AS a
     INNER JOIN makt AS b
        ON a~matnr = b~matnr
       AND b~spras = sy-langu
     WHERE a~matnr = pv_matnr.

    IF sy-subrc = 0.
      APPEND gt_makt.

      SORT gt_makt BY matnr.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_maktx = gt_makt-maktx.
  ENDIF.

ENDFORM.                    " GET_MATNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_SO_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_so_characteristic USING pv_vbeln
                                 pv_posnr
                                 pv_atnam
                                 pv_atwrt.
  DATA : BEGIN OF ls_char,
           atnam LIKE cabn-atnam,
           atwrt LIKE ibsymbol-atwrt,
           atflv LIKE ibsymbol-atflv,
           atflb LIKE ibsymbol-atflb,
           atfor LIKE cabn-atfor,
           anzdz LIKE cabn-anzdz,
         END   OF ls_char.

  DATA: lv_valid  LIKE ibin-valfr.

  CLEAR : pv_atwrt, ls_char.

  GET TIME STAMP FIELD lv_valid.

  SELECT SINGLE d~atnam c~atwrt c~atflv
                c~atflb d~atfor d~anzdz
    INTO CORRESPONDING FIELDS OF ls_char
    FROM vbap AS a
   INNER JOIN ibin AS b
      ON a~cuobj = b~instance
   INNER JOIN v_ibin_syval AS c
      ON b~in_recno = c~in_recno
   INNER JOIN cabn AS d
      ON c~atinn =  d~atinn
   WHERE a~vbeln =  pv_vbeln
     AND a~posnr =  pv_posnr
     AND b~valfr <= lv_valid
     AND b~valto >= lv_valid
     AND d~atnam =  pv_atnam.

  IF ls_char-atfor = 'NUM'.
    pv_atwrt = ls_char-atflv.
  ELSE.
    pv_atwrt = ls_char-atwrt.
  ENDIF.

ENDFORM.                    " GET_SO_CHARACTERISTIC
*&---------------------------------------------------------------------*
*&      Form  GET_VSTEL_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_vstel_desc  USING    pv_vstel
                              pv_vtext.

  CLEAR : pv_vtext.

  CHECK pv_vstel IS NOT INITIAL.

  READ TABLE gt_tvstt WITH KEY vstel = pv_vstel
                      BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_tvstt.

    SELECT SINGLE a~vstel
                  b~vtext
      INTO gt_tvstt
      FROM tvst AS a
     INNER JOIN tvstt AS b
        ON b~spras = sy-langu
       AND a~vstel = b~vstel
     WHERE a~vstel = pv_vstel.

    IF sy-subrc = 0.
      APPEND gt_tvstt.

      SORT gt_tvstt BY vstel.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_vtext = gt_tvstt-vtext.
  ENDIF.

ENDFORM.                    " GET_VSTEL_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_WERKS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_werks_desc  USING    pv_werks
                              pv_name1.

  CLEAR : pv_name1.

  CHECK pv_werks IS NOT INITIAL.

  READ TABLE gt_t001w WITH KEY werks = pv_werks
                      BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_t001w.

    SELECT SINGLE werks
                  name1
      INTO gt_t001w
      FROM t001w
     WHERE werks = pv_werks.

    IF sy-subrc = 0.
      APPEND gt_t001w.

      SORT gt_t001w BY werks.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_name1 = gt_t001w-name1.
  ENDIF.

ENDFORM.                    " GET_WERKS_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_PERNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_pernr_desc  USING    pv_pernr
                              pv_sname.

  CLEAR : pv_sname.

  CHECK pv_pernr IS NOT INITIAL.

  READ TABLE gt_pa01 WITH KEY pernr = pv_pernr
                     BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_pa01.

    SELECT SINGLE pernr
                  sname
      INTO gt_pa01
      FROM zzpa0001
     WHERE pernr =  pv_pernr
       AND endda >= sy-datlo
       AND begda <= sy-datlo.

    IF sy-subrc = 0.
      APPEND gt_pa01.

      SORT gt_pa01 BY pernr.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_sname = gt_pa01-sname.
  ENDIF.

ENDFORM.                    " GET_PERNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_VHCTP_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_vhctp_desc  USING    pv_sdabw
                              pv_bezei.
  DATA: lv_htype    LIKE dd01v-datatype.

  CLEAR : pv_bezei.

  CHECK pv_sdabw IS NOT INITIAL.

  READ TABLE gt_tvsak WITH KEY sdabw = pv_sdabw
                      BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_tvsak.

    SELECT SINGLE sdabw
                  bezei
      INTO gt_tvsak
      FROM tvsakt
     WHERE spras = sy-langu
       AND sdabw = pv_sdabw.

    IF sy-subrc = 0.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = gt_tvsak-sdabw
        IMPORTING
*         STRING_OUT       =
          htype     = lv_htype.

      IF lv_htype = 'NUMC'.
        CONCATENATE gt_tvsak-bezei '이하'
               INTO gt_tvsak-bezei SEPARATED BY space.
      ENDIF.

      APPEND gt_tvsak.

      SORT gt_tvsak BY sdabw.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_bezei = gt_tvsak-bezei.
  ENDIF.

ENDFORM.                    " GET_VHCTP_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_VBUK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_vbuk_data  USING    pv_vbeln
                             pv_cmgst.

  CLEAR : pv_cmgst.

  CHECK pv_vbeln IS NOT INITIAL.

  READ TABLE gt_vbuk WITH KEY vbeln = pv_vbeln
                     BINARY SEARCH.
  IF sy-subrc <> 0.
    SELECT SINGLE vbeln
                  cmgst
      INTO gt_vbuk
      FROM likp
     WHERE vbeln = pv_vbeln.

    IF sy-subrc = 0.
      APPEND gt_vbuk.

      SORT gt_vbuk BY vbeln.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_cmgst = gt_vbuk-cmgst.
  ENDIF.

ENDFORM.                    " GET_VBUK_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SHIP_TO_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_ship_to_info  USING    pv_adrnr
                                pv_name1
                                pv_post
                                pv_land1
                                pv_lzone
                                pv_city1
                                pv_extension1
                                pv_tel_number
                                pv_all.

  CLEAR : pv_name1.

  IF pv_all = 'X'.
    CLEAR : pv_post,       pv_land1,
            pv_lzone,      pv_city1,
            pv_extension1, pv_tel_number.
  ENDIF.

  READ TABLE gt_adrc WITH KEY addrnumber = pv_adrnr
                              BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR : gt_adrc.

    SELECT SINGLE addrnumber
                  name1
                  post_code1
                  country
                  transpzone
                  city1
                  extension1     "대표자
                  extension2     "제품수령인
                  tel_number
      INTO gt_adrc
      FROM adrc
     WHERE addrnumber = pv_adrnr.

    IF sy-subrc = 0.
      APPEND gt_adrc.

      SORT gt_adrc BY addrnumber.
    ENDIF.
  ENDIF.

  IF sy-subrc = 0.
    pv_name1      = gt_adrc-name1.

    IF pv_all = 'X'.
      pv_post       = gt_adrc-post_code1.
      pv_land1      = gt_adrc-country.
      pv_lzone      = gt_adrc-transpzone.
      pv_city1      = gt_adrc-city1.
      pv_extension1 = gt_adrc-extension2.
      pv_tel_number = gt_adrc-tel_number.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_SHIP_TO_INFO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_layo .

  CLEAR : gs_layout.

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  gs_layout-cwidth_opt = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  gs_layout-zebra      = 'X'.
  gs_layout-smalltitle = 'X'.
*  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines

  IF sy-dynnr = '0100'.
    gs_layout-stylefname = 'CELLTAB'.
    gs_layout-ctab_fname = 'F_COL'.
  ENDIF.

ENDFORM.                    " SET_GRID_LAYO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_fcat .

  CLEAR   : gs_fieldcat, gv_pos.
  REFRESH : gt_fieldcat.

  gv_itab = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  IF gv_trtyp = 'H' OR gv_trtyp = 'V'.

    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'STAT_C'    ' '      ' '     'X ' 'C' ' ' ' '    'X' ' ' ' ' 3
      '여신'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.


    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :

      'HDSEL'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      'S/O선택'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'ITSEL'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '품목선택'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X'.
  ENDIF.


  IF gv_trtyp = 'V' OR gv_trtyp = 'A'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'DLVRQ'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 12
      ' '            'DLVRQ'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '.
  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                  USING :
      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'VBELN'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      ' '            'POSNR'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'VKBUR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'VKBUR'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'VKGRP'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'PERNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '영업사원'     'PERNR'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'SNAME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '영업사원명'   'SNAME'  'ZZPA0001'    ' ' ' '    'X' ' ' ' ' ' '.

  IF gv_trtyp = 'H'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'CMGST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '여신상태'     'CMGST'  'VBUK'      ' ' ' '    'X' ' ' ' ' ' ',

      'LIFSK'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '            'LIFSK'  'VBAK'      ' ' ' '    'X' ' ' ' ' ' '.
  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                  USING :
      'KUNWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNWE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAMWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '납품처명'     'NAME1'  'KNA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'KUNAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNAG'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '판매처명'     'NAME1'  'KNA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BSTKD'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'PO 번호'      'BSTKD'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 161289 - 추가
      'BSTDK'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'PO 일자'      'BSTDK'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 161289 - 추가

*{ 기능개선 164038 - 추가
      'EMPST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 25
      ' '            'EMPST'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' '.
*} 기능개선 164038 - 추가

  IF gv_trtyp = 'H'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'KDKG4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      '내수/수출'    'KDKG4'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'SOTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'MTS/MTO'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.
  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                  USING :
      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '            'MATNR'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'MAKTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'MAKTX'  'MAKT'      ' ' ' '    'X' ' ' ' ' ' ',

      'KWMENG'   ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'KWMENG' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'VRKME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '단위'         'VRKME'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'INDLEN'   ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'INDLEN' 'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'INDQTY'   ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'INDQTY' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'INDMEI'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'MARA'      'X' ' '    'X' ' ' ' ' ' ',

      'COLOR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '색상'         'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 161289 - 추가
      'INSCD'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '절연선심식별' 'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 161289 - 추가

      'JOBNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 30
      '제조지시번호' 'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

      'VSTEL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'VSTEL'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '출하지점명'   'VTEXT'  'TVSTT'     ' ' ' '    'X' ' ' ' ' ' ',

      'WERKS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'WERKS'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '플랜트명'     'NAME1'  'T001W'     ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 231127 - 추가
      'LGORT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 4
      ' '            'LGORT'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 231127 - 추가

      'SPART'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '            'SPART'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'POST_CODE1' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '        'POST_CODE1' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'LAND1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'LAND1'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'LZONE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'LZONE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'CITY1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '상세주소'     'CITY1'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'EXTENSION1' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '수령인'   'EXTENSION1' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'TEL_NUMBER' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '연락처'   'TEL_NUMBER' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ARRDT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ARRDT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ARRTM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      ' '            'ARRTM'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'IMMDT'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'IMMDT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ALONE'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'ALONE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'BKNFT'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'BKNFT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VHCTP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'VHCTP'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VHCTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '차량제한명'   'BEZEI'  'TVSAKT'    ' ' ' '    'X' ' ' ' ' ' ',

      'DIVID'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'DIVID'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ZREQ_TYPE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '직송의뢰 신청 유형'            'ZREQ_TYPE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'TRTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '            'TRTYP'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '.

  IF gv_trtyp = 'V' OR gv_trtyp = 'A'..
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'KDKG4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      '내수/수출'    'KDKG4'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'SOTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'MTS/MTO'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CMGST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '여신상태'     'CMGST'  'VBUK'      ' ' ' '    'X' ' ' ' ' ' '.
  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                  USING :
      'BMENG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '확정수량'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'UDMNG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '미출고(출하요청완료)' 'DLRMG' 'ZLET0401' ' ' ' ' ' ' ' ' ' ' ' ',

      'DCMNG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출고완료'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'DCMNG_R'  ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출고완료(출하요청)' 'DLRMG' 'ZLET0401' ' ' ' ' ' ' ' ' ' ' ' ',

      'RAMNG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '요청가능'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'LABST'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '가용재고'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'INSME'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '품질재고'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'LFIMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '납품수량(납품전체)' 'LFIMG'  'LIPS' ' ' ' '   ' ' ' ' ' ' ' ',

      'LFIMG_M'  ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '납품수량(자신)'     'LFIMG'  'LIPS' ' ' ' '   ' ' ' ' ' ' ' ',

      'LFIMG_R'  ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '납품수량(출하요청)' 'LFIMG'  'LIPS' ' ' ' '   ' ' ' ' ' ' ' '.

*  IF GV_TRTYP = 'V' OR GV_TRTYP = 'A'.
*    PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
*                                    USING :
*      'RVSTA'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
*      '검토상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',
*
*      'REVMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
*      ' '            'REVMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' '.
*  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                  USING :
      'EDATU'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '출하요청일'   'EDATU'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' 'X',

      'DLRMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

*      'DLRMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
*      ' '            'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' 'X',

      'DRIND'    ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '출하요청조장수' 'INDQTY' 'ZLET0401' ' ' ' '   ' ' ' ' ' ' 'X'.

  IF gv_trtyp = 'H'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'AVLBT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '가용성점검'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ABGRU'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      '거부사유'     'ABGRU'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' '.
  ELSE.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'SACPT'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 4
      '선적접수'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'LECFM'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
      ' '            'LECFM'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' '.

*      'SDCFM'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
*      ' '            'SDCFM'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' '.
  ENDIF.

  IF gv_trtyp = 'A'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'VGBEL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '납품문서'     'VGBEL'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'VGPOS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 6
      ' '            'VGPOS'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'LFIMG_D'  ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '납품문서수량'       'LFIMG'  'LIPS' ' ' ' '   ' ' ' ' ' ' ' ',


      'REMARK'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      ' '            'REMARK' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '.
  ELSE.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'REMARK'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      ' '            'REMARK' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' 'X'.
  ENDIF.

  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
  'ZREMARK1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
  '출하실 요청사항'            'REMARK' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '.

  IF gv_trtyp = 'H' OR gv_trtyp = 'V'.
    PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat
                                    USING :
      'MSG'    ' '      ' '     '  ' ' ' ' ' ' '    ' ' ' ' ' ' 80
      '오류메세지'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.



  ENDIF.

ENDFORM.                    " SET_GRID_FCAT
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM make_lvc_fieldcat_data TABLES pt_fieldcat TYPE lvc_t_fcat
                             USING pv_fname
                                   pv_curk
                                   pv_unit
                                   pv_icon
                                   pv_check
                                   pv_just
                                   pv_empha
                                   pv_fix
                                   pv_noout
                                   pv_nozero
                                   pv_length
                                   pv_text
                                   pv_reff
                                   pv_reft
                                   pv_tech
                                   pv_type
                                   pv_nosum
                                   pv_dosum
                                   pv_hotspot
                                   pv_edit.

  CLEAR : gs_fieldcat.

  gv_pos = gv_pos + 1.

  gs_fieldcat-col_pos        = gv_pos.
  gs_fieldcat-fieldname      = pv_fname.
  gs_fieldcat-cfieldname     = pv_curk.
  gs_fieldcat-qfieldname     = pv_unit.
  gs_fieldcat-icon           = pv_icon.
  gs_fieldcat-checkbox       = pv_check.
  gs_fieldcat-just           = pv_just.
  gs_fieldcat-emphasize      = pv_empha.
  gs_fieldcat-fix_column     = pv_fix.
  gs_fieldcat-key            = pv_fix.
  gs_fieldcat-no_out         = pv_noout.
  gs_fieldcat-no_zero        = pv_nozero.
  gs_fieldcat-outputlen      = pv_length.
  gs_fieldcat-coltext        = pv_text.
  gs_fieldcat-scrtext_s      = pv_text.
  gs_fieldcat-scrtext_m      = pv_text.
  gs_fieldcat-scrtext_l      = pv_text.
  gs_fieldcat-reptext        = pv_text.
  gs_fieldcat-ref_field      = pv_reff.
  gs_fieldcat-ref_table      = pv_reft.
  gs_fieldcat-tech           = pv_tech.
  gs_fieldcat-datatype       = pv_type.
  gs_fieldcat-no_sum         = pv_nosum.
  gs_fieldcat-do_sum         = pv_dosum.
  gs_fieldcat-hotspot        = pv_hotspot.
  gs_fieldcat-edit           = pv_edit.
  gs_fieldcat-colddictxt     = 'M'.

  gs_fieldcat-tabname        = gv_itab.

  CASE pv_fname.
    WHEN 'LFIMG'.
      gs_fieldcat-tooltip = '판매오더로 생성된 납품문서 총수량'.

    WHEN 'LFIMG_R'.
      gs_fieldcat-tooltip = '출하요청을 통해 생성된 납품문서 총수량'.

    WHEN 'LFIMG_M'.
      gs_fieldcat-tooltip = '해당 출하요청으로 생성된 납품문서 수량'.

    WHEN 'LFIMG_D'.
      gs_fieldcat-tooltip = '납품번호가 있는 경우 해당 납품의 수량'.

  ENDCASE.

  APPEND gs_fieldcat TO pt_fieldcat.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cell_attribute .
  DATA: lt_celltab TYPE lvc_t_styl,
        lt_color   TYPE lvc_t_scol.

*___각 Cell의 특성 제어
  LOOP AT gt_main.
    CLEAR   : lt_celltab, lt_color.
    REFRESH : lt_celltab, lt_color.

    PERFORM fill_celltab_c CHANGING lt_celltab.
    PERFORM fill_color     CHANGING lt_color.

    REFRESH : gt_main-celltab, gt_main-f_col.

    INSERT LINES OF lt_celltab INTO TABLE gt_main-celltab.
    INSERT LINES OF lt_color   INTO TABLE gt_main-f_col.

    MODIFY gt_main.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_celltab_c  CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.
    ls_celltab-fieldname = l_fieldcat-fieldname.

*___필드 활성화 여부
    IF gt_main-confm  IS INITIAL AND
       gt_main-hlvorm IS INITIAL AND
       gt_main-ilvorm IS INITIAL.
      IF l_fieldcat-edit = 'X' AND gv_trtyp <> 'A'.
*        IF ( L_FIELDCAT-FIELDNAME = 'DLRMG'  AND
*             GT_MAIN-INDLEN IS NOT INITIAL ) OR
        IF ( l_fieldcat-fieldname = 'DRIND'  AND
             gt_main-indlen IS INITIAL ).
          ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*                          + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT ls_celltab INTO TABLE pt_celltab.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM fill_color  CHANGING pt_color TYPE lvc_t_scol.
  DATA: ls_celltab TYPE lvc_s_styl,
        ls_color   TYPE lvc_s_scol,
        l_mode     TYPE raw4.

  DATA: l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.
    ls_color-fname = l_fieldcat-fieldname.

    IF  l_fieldcat-key = 'X'.
      IF ls_color-fname <> 'HDSEL' AND ls_color-fname <> 'ITSEL'.
        ls_color-color-col = 4.
        ls_color-color-int = 1.

        INSERT ls_color INTO TABLE pt_color.
      ENDIF.
    ELSE.
      IF gv_trtyp <> 'A'.
        IF l_fieldcat-edit IS INITIAL.
          IF gt_main-itsel = 'X'.
            ls_color-color-col = 7.
            ls_color-color-int = 0.
          ELSE.
            ls_color-color-col = 2.
            ls_color-color-int = 0.
          ENDIF.

          INSERT ls_color INTO TABLE pt_color.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILL_COLOR
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
  DATA : ls_exclude TYPE ui_func.

  REFRESH : pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM event_handler_register .

  CALL METHOD gc_alv_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*___Event Handler 등록
  CREATE OBJECT gc_event_handler.

  SET HANDLER gc_event_handler->handle_toolbar       FOR gc_alv_grid.
  SET HANDLER gc_event_handler->handle_double_click  FOR gc_alv_grid.
  SET HANDLER gc_event_handler->handle_data_changed  FOR gc_alv_grid.
  SET HANDLER gc_event_handler->handle_data_changed_finished
          FOR gc_alv_grid.
  SET HANDLER gc_event_handler->handle_user_command  FOR gc_alv_grid.

ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_table_for_first_display .

  gs_variant-report = sy-repid.

  CASE gv_trtyp.
    WHEN 'H'.
      gs_variant-handle = '0001'.

    WHEN 'V'.
      gs_variant-handle = '0002'.

    WHEN OTHERS.
      gs_variant-handle = '0003'.

  ENDCASE.

  CALL METHOD gc_alv_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      is_layout            = gs_layout
      i_save               = 'A'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_fieldcatalog      = gt_fieldcat[]
      it_sort              = gt_sort[]
      it_outtab            = gt_main[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_rows .

  CALL METHOD gc_alv_grid->check_changed_data.

  CALL METHOD gc_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  CLEAR : gt_main-mark.
  MODIFY gt_main TRANSPORTING mark
                 WHERE vbeln IS NOT INITIAL.

  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_main INDEX gs_rows-index.
    IF sy-subrc = 0.
      gt_main-mark = 'X'.
      MODIFY gt_main INDEX gs_rows-index.
    ENDIF.
  ENDLOOP.

  CALL METHOD gc_alv_grid->get_selected_columns
    IMPORTING
      et_index_columns = gt_cols.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_selected_rows .

  REFRESH : gt_rows.

  LOOP AT gt_main.
    IF gt_main-mark = 'X'.
      CLEAR : gs_rows.
      gs_rows-index = sy-tabix.
      APPEND gs_rows TO gt_rows.
    ENDIF.
  ENDLOOP.

  IF gt_rows[] IS NOT INITIAL.
    CALL METHOD gc_alv_grid->set_selected_rows
      EXPORTING
        it_index_rows = gt_rows.
  ENDIF.

  IF gt_cols[] IS NOT INITIAL.
    CALL METHOD gc_alv_grid->set_selected_columns
      EXPORTING
        it_col_table = gt_cols.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_ZLET0401_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_zlet0401_data .
  DATA: lv_vgbel LIKE zlet0402-vgbel,
        lv_vgpos LIKE zlet0402-vgpos,
        lv_lfimg LIKE lips-lfimg,
        lv_dcmng LIKE lips-lfimg.

  RANGES: lr_dlvrq  FOR  zlet0400-dlvrq.

  CHECK gt_main-auart <> 'RE'   AND
        gt_main-auart <> 'ZREQ'.

  CLEAR   : gt_0401, lr_dlvrq, lv_dcmng.
  REFRESH : gt_0401, lr_dlvrq.

  IF gv_trtyp = 'V' AND gt_main-dlvrq IS NOT INITIAL.
*___변경인 경우 자기자신의 출하요청수량도 요청가능수량으로 포함하기 위해
    set_ranges: lr_dlvrq 'E' 'EQ' gt_main-dlvrq ' '.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_0401
    FROM zlet0400 AS a
   INNER JOIN zlet0401 AS b
      ON a~dlvrq = b~dlvrq
   WHERE a~dlvrq IN lr_dlvrq
     AND b~vbeln =  gt_main-vbeln
     AND b~posnr =  gt_main-posnr
     AND b~lvorm =  ' '
     AND a~lvorm =  ' '.

  LOOP AT gt_0401.
*___기 출하요청된 수량
    gt_main-drcmg = gt_main-drcmg + gt_0401-dlrmg.

*___출하요청으로 생성된 납품
    CLEAR   : gt_0402.
    REFRESH : gt_0402.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_0402
      FROM zlet0402
     WHERE dlvrq = gt_0401-dlvrq
       AND vbeln = gt_0401-vbeln
       AND posnr = gt_0401-posnr
       .

    LOOP AT gt_0402.
      CLEAR : lv_lfimg.

      SELECT SUM( lfimg )
        INTO lv_lfimg
        FROM lips
       WHERE vbeln = gt_0402-vgbel
         AND ( posnr = gt_0402-vgpos
            OR uecha = gt_0402-vgpos ).

*___납품생성 수량(출하요청)
      gt_main-lfimg_r = gt_main-lfimg_r + lv_lfimg.

*___출고전기 완료 수량(출하요청)
      IF gt_0402-wbsta = 'C'.
        gt_main-dcmng_r = gt_main-dcmng_r + lv_lfimg.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*___미출고(출하요청완료) = 기출하요청 - 출고전기 완료
  gt_main-udmng = gt_main-drcmg - gt_main-dcmng_r.

*___납품생성수량
  SELECT SUM( lfimg )
    INTO gt_main-lfimg
    FROM lips
   WHERE vgbel = gt_main-vbeln
     AND vgpos = gt_main-posnr.

*___출고완료 - 해당 판매오더/품목으로 생성하고 출고전기완료된 납품수량
  SELECT SUM( a~lfimg )
    INTO gt_main-dcmng
    FROM lips AS a
   INNER JOIN likp AS b
      ON a~vbeln = b~vbeln
   WHERE a~vgbel = gt_main-vbeln
     AND a~vgpos = gt_main-posnr
     AND b~wbstk = 'C'.

*___해당 출하요청으로 생성된 납품생성수량
  IF gv_trtyp <> 'H'.
    SELECT vgbel
           vgpos
      INTO (lv_vgbel, lv_vgpos)
      FROM zlet0402
     WHERE dlvrq = gt_main-dlvrq
       AND vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr.

      CLEAR : lv_lfimg.

      SELECT SUM( lfimg )
        INTO lv_lfimg
        FROM lips
       WHERE vbeln = lv_vgbel
         AND ( posnr = lv_vgpos
            OR uecha = lv_vgpos ).

      gt_main-lfimg_m = gt_main-lfimg_m + lv_lfimg.
    ENDSELECT.
  ENDIF.

**___요청가능수량 = 확정수량 - 미출고(출하요청완료) - 출고완료
*  GT_MAIN-RAMNG = GT_MAIN-BMENG - GT_MAIN-UDMNG - GT_MAIN-DCMNG.

*___요청가능수량 = 확정수량 - 납품생성수량
*                - ( 출하요청수량 - (출하요청)납품생성 수량 )
  gt_main-ramng = gt_main-bmeng - gt_main-lfimg - gt_main-drcmg
                + gt_main-lfimg_r.

  IF gt_main-ramng < 0.
    CLEAR : gt_main-ramng.
  ENDIF.

*___출하요청수량 - 기본값
  IF gv_trtyp = 'H'.
    gt_main-dlrmg = gt_main-ramng.
  ELSEIF gt_main-confm IS INITIAL.
    IF gt_main-revmg IS NOT INITIAL.   "검토수량
*      GT_MAIN-DLRMG = GT_MAIN-REVMG.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_ZLET0401_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_STOCK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_stock_data  USING    pv_matnr
                              pv_vstel       "기능개선 231127 - 추가
                              pv_werks
                              pv_lgort       "기능개선 231127 - 추가
                              pv_vbeln
                              pv_posnr
                              pv_sobkz
                              pv_vrkme
                              pv_labst
                              pv_insme.
  DATA: lv_meins LIKE mara-meins,
        lv_raube LIKE mara-raube.    "기능개선 231127 - 추가

  RANGES: lr_lgort  FOR  mard-lgort.

  CLEAR   : lr_lgort, pv_labst, pv_insme.
  REFRESH : lr_lgort.

*___자재기본단위
  SELECT SINGLE raube
                meins
    INTO (lv_raube, lv_meins)
    FROM mara
   WHERE matnr = pv_matnr.

*{ 기능개선 231127 - 추가
  IF pv_lgort IS INITIAL.
*___납품에 대한 저장위치 결정
    SELECT SINGLE lgort
      INTO pv_lgort
      FROM tvkol
     WHERE vstel = pv_vstel
       AND werks = pv_werks
       AND raube = lv_raube.
  ENDIF.

  IF pv_lgort IS NOT INITIAL.
*___저장위치가 있는 경우 해당 저장위치의 재고만 조회
    lr_lgort-sign   = 'I'.
    lr_lgort-option = 'EQ'.
    lr_lgort-low    = pv_lgort.
    APPEND lr_lgort.
  ELSE.
*} 기능개선 231127 - 추가
    SELECT lgort AS low
      INTO CORRESPONDING FIELDS OF TABLE lr_lgort
      FROM zlet0053
     WHERE werks   = pv_werks
       AND zuse_yn = 'Y'.

    lr_lgort-sign   = 'E'.
    lr_lgort-option = 'EQ'.
    MODIFY lr_lgort TRANSPORTING sign option
                    WHERE low IS NOT INITIAL.
  ENDIF.

  IF pv_sobkz IS INITIAL.  "MTS 재고
    SELECT SUM( labst )
           SUM( insme )
      INTO (pv_labst, pv_insme)
      FROM mard
     WHERE matnr =  pv_matnr
       AND werks =  pv_werks
       AND lgort IN lr_lgort.
  ELSE.                    "MTO 재고
    SELECT SUM( kalab )
           SUM( kains )
      INTO (pv_labst, pv_insme)
      FROM mska
     WHERE matnr = pv_matnr
       AND werks = pv_werks
       AND sobkz = pv_sobkz
       AND vbeln = pv_vbeln
       AND posnr = pv_posnr.
  ENDIF.

  CHECK pv_vrkme <> lv_meins.

*___판매오더 단위와 기본단위가 다른 경우 판매오더 단위로 수량 변경
  PERFORM convert_material_unit USING: pv_matnr
                                       pv_vrkme
                                       lv_meins
                                       pv_labst,

                                       pv_matnr
                                       pv_vrkme
                                       lv_meins
                                       pv_insme.

ENDFORM.                    " GET_STOCK_DATA
*&---------------------------------------------------------------------*
*&      Form  CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_material_unit  USING  pv_matnr LIKE mara-matnr
                                   pv_meins LIKE mara-meins
                                   pv_bmein LIKE mara-meins
                                   pv_brgew.
  DATA : lv_brgew  LIKE mara-brgew,
         lv_menge  LIKE ekpo-menge,
         lv_menge1 TYPE p DECIMALS 2,
         lv_meins  LIKE mara-meins.

  CHECK pv_meins <> pv_bmein.

  CLEAR : lv_menge, lv_meins.

  SELECT SINGLE meins
    INTO lv_meins
    FROM mara
   WHERE matnr = pv_matnr.

  CHECK sy-subrc = 0.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      matnr                = pv_matnr
      input                = pv_brgew
      meinh                = pv_meins
      kzmeinh              = 'X'
      meins                = lv_meins
    IMPORTING
      output               = lv_menge
    EXCEPTIONS
      conversion_not_found = 01
      input_invalid        = 02
      material_not_found   = 03
      meinh_not_found      = 04
      meins_missing        = 05
      no_meinh             = 06
      output_invalid       = 07
      overflow             = 08.

  IF sy-subrc = 0.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        matnr                = pv_matnr
        input                = lv_menge
        meinh                = pv_bmein
        kzmeinh              = space
        meins                = lv_meins
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 01
        input_invalid        = 02
        material_not_found   = 03
        meinh_not_found      = 04
        meins_missing        = 05
        no_meinh             = 06
        output_invalid       = 07
        overflow             = 08.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = pv_brgew
        round_sign           = 'X'
        unit_in              = pv_meins
        unit_out             = pv_bmein
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
  ENDIF.

  IF sy-subrc = 0.
    lv_menge1 = lv_menge.
    pv_brgew  = lv_menge1.
  ELSE.
    CLEAR : pv_brgew.
  ENDIF.

ENDFORM.                    " CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM data_changed_finished  USING r_modified
                                  rt_good_cells TYPE lvc_t_modi.
  DATA: ls_good_cells TYPE lvc_s_modi.

  CHECK r_modified = 'X'.

  LOOP AT rt_good_cells INTO ls_good_cells.
    READ TABLE gt_main INDEX ls_good_cells-row_id.
    IF sy-subrc = 0.
      CASE ls_good_cells-fieldname.
        WHEN 'HDSEL'.   "판매오더 선택
          gt_main-itsel = gt_main-hdsel.

          IF gv_trtyp = 'H'.
            MODIFY gt_main TRANSPORTING hdsel itsel
                           WHERE vbeln = gt_main-vbeln
                             AND confm IS INITIAL.
          ELSE.
            MODIFY gt_main TRANSPORTING hdsel itsel
                           WHERE dlvrq = gt_main-dlvrq
                             AND vbeln = gt_main-vbeln
                             AND confm IS INITIAL.
          ENDIF.

        WHEN 'DRIND'.   "출하요청조장수
          gt_main-dlrmg = gt_main-indlen * gt_main-drind.

          MODIFY gt_main INDEX ls_good_cells-row_id.

        WHEN 'DLRMG'.   "출하요청수량
          IF gt_main-indlen IS NOT INITIAL.
            gt_main-drind = gt_main-dlrmg / gt_main-indlen.

            MODIFY gt_main INDEX ls_good_cells-row_id.
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  CREATE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_delivery_req .

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM check_selected_data USING gv_error.

  CHECK gv_error IS INITIAL.

*->>[가온전선]------------------------------------------------------S
* 여신점검
  PERFORM check_credit USING gv_error.

  IF gv_error IS NOT INITIAL.
    PERFORM refresh_alv USING gc_alv_grid.
    EXIT.
  ENDIF.
*-<<[가온전선]------------------------------------------------------E

  PERFORM popup_to_confirm USING '출하요청생성'
                                 '출하요청을 생성하시겠습니까?'
                                 '1'
                                 gv_answer.
  IF gv_answer = '1'.
    PERFORM create_delivery_req_data.

    PERFORM get_order_data.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CREATE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_selected_rows  USING    pv_error.
  DATA: lv_cnt      TYPE i.

  CLEAR : pv_error.

  LOOP AT gt_main WHERE itsel = 'X'.
    lv_cnt = lv_cnt + 1.
  ENDLOOP.

  IF lv_cnt IS INITIAL.
    pv_error = 'X'.

    MESSAGE s100 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_selected_data  USING    pv_error.
  DATA: lv_text(20).
  DATA : lv_ck.

  CLEAR : pv_error.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT gt_main WHERE itsel = 'X'.
    CONCATENATE gt_main-vbeln '-' gt_main-posnr
           INTO lv_text.

*___운송유형
    IF gt_main-trtyp IS INITIAL.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  lv_text
                                  '의 운송유형이 입력되지'
                                  '않았습니다.'.
    ENDIF.

*___운송지역
    IF gt_main-lzone IS INITIAL.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  lv_text
                                  '의 운송지역이 입력되지'
                                  '않았습니다.'.
    ENDIF.


*___우편번호
    IF gt_main-post_code1 IS INITIAL.
      IF gt_main-trade = 'D'.  "내수인 경우 우편번호 필수
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '의 우편번호가 입력되지'
                                    '않았습니다.'.
      ENDIF.
    ELSE.
      PERFORM check_post_code USING gt_main-post_code1
                                    gt_main-lzone
                                    pv_error
                                    lv_text.
    ENDIF.

    IF gv_trtyp = 'H'.     "생성
*___가용성점검
      IF gt_main-avlbt = '미확정'.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '의 가용성 점검을 먼저 수행하세요'
                                    ' '.
      ENDIF.

*___거절사유
      IF gt_main-abgru <> ' '.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '의 거절사유를 먼저 해제하세요'
                                    ' '.
      ENDIF.

*___여신상태
      IF gt_main-cmgst = 'B' OR gt_main-cmgst = 'C'.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더'
                                    gt_main-vbeln
                                    '의 여신보류를 먼저 해제하세요'
                                    ' '.
      ENDIF.

*___납품일 점검
      IF gt_main-edatu < sy-datlo.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '의 납품일을 점검하세요.(과거일자)'
                                    ' '.
      ENDIF.

*___납품보류
      IF gt_main-lifsk IS NOT INITIAL.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '이(가) 납품보류 상태입니다.'
                                    ' '.
      ENDIF.
    ELSE.
*___출하/영업 확정
      IF gt_main-sdcfm IS NOT INITIAL OR gt_main-lecfm IS NOT INITIAL.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '출하요청번호'
                                    gt_main-dlvrq
                                    '은(는) 출하확정 되었습니다.'
                                    ' '.
      ENDIF.

*___출하검토여부
      IF gt_main-reviw IS INITIAL.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    lv_text
                                    '은(는) 출하검토되지 않았습니다.'
                                    ' '.
      ENDIF.
    ENDIF.

*___출하요청수량
    IF gt_main-dlrmg IS INITIAL.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  lv_text
                                  '의 출하요청수량이 ''0'' 입니다.'
                                  '확인하십시오.'.
    ENDIF.

*{CHM2007-00666 -S   추가
*___ 지급조건 초과기준에 해당하는 품목 승인 점검
    CLEAR : lv_ck.
    IF gt_main-auart = 'OR' OR
       gt_main-auart = 'TA' OR
       gt_main-auart = 'ZEXE' OR
       gt_main-auart = 'Z3RD'.
*      IF GT_MAIN-VTWEG = '10'.
*        IF GT_MAIN-ZTERM+1(3) > 150.
*          LV_CK = 'X'.
*        ENDIF.
*      ELSEIF GT_MAIN-VTWEG = '50'.
*        IF GT_MAIN-ZTERM+1(3) > 180.
*          LV_CK = 'X'.
*        ENDIF.
*      ENDIF.
      CALL FUNCTION 'Z_SD_CALCULATE_ZTERM'
        EXPORTING
          i_vbeln  = gt_main-vbeln
          i_posnr  = gt_main-posnr
        IMPORTING
          e_zterm  = gt_main-zterm
          e_target = lv_ck.
    ENDIF.

    IF lv_ck = 'X'.
      SELECT SINGLE mandt
        INTO sy-mandt
        FROM zsdt0620
       WHERE vbeln =  vbak-vbeln
         AND aprv_stat = 'C'.
      IF sy-subrc <> 0 .
        pv_error = 'X'.
        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더'
                                    gt_main-vbeln
                                 '지급조건 기준 초과로 승인이 필요합니다.'
                                    ' '.
      ENDIF.
    ENDIF.
*}CHM2007-00666 -E   추가
  ENDLOOP.

  IF pv_error = 'X'.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        show_linno = space.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup_to_confirm  USING    pv_title
                                pv_text
                                pv_default
                                pv_answer.

  CLEAR : pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = pv_title
      text_question         = pv_text
      text_button_1         = '예'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니오'
      icon_button_2         = 'ICON_CANCEL'
      default_button        = pv_default
      display_cancel_button = ' '
    IMPORTING
      answer                = pv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  CREATE_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_delivery_req_data .
  DATA: lt_0400 LIKE zlet0400 OCCURS 0 WITH HEADER LINE,
        lt_0401 LIKE zlet0401 OCCURS 0 WITH HEADER LINE,
        lt_0406 LIKE zlet0406 OCCURS 0 WITH HEADER LINE,
        lt_0403 LIKE zlet0403 OCCURS 0 WITH HEADER LINE,
        lt_0404 LIKE zlet0404 OCCURS 0 WITH HEADER LINE.

  DATA: lv_tmpno     LIKE zlet0400-dlvrq,
        lv_dlvrq     LIKE zlet0400-dlvrq,
        lv_first     LIKE zlet0400-dlvrq,
        lv_seq(4)    TYPE n,
        lv_last(20),
        lv_cnt(10),
        lv_where(30),
        lv_simul.

  DATA: ls_keyno     LIKE gs_key.

  DATA: lv_suc(1).

  CLEAR   : lt_0400, lt_0401, lt_0406, lt_0403, lt_0404, lv_cnt.
  REFRESH : lt_0400, lt_0401, lt_0406, lt_0403, lt_0404.
  CLEAR   : gt_link[].

*___판매처/납품처/출하지점별로 정렬
  SORT gt_main BY keyno.

  lv_tmpno = 'TMP000000000'.

  CLEAR : ls_keyno, lv_simul.

  LOOP AT gt_main WHERE itsel = 'X'
                    AND dlrmg > 0.
*___판매처/납품처/출하지점 비교하여 다른 경우 출하요청 임시번호 생성
    IF ls_keyno <> gt_main-keyno.
      MOVE-CORRESPONDING gt_main TO ls_keyno.

      lv_tmpno+3(9) = lv_tmpno+3(9) + 1.

      lv_cnt = lv_cnt + 1.

*___출하요청 헤더정보 생성
      CLEAR : lt_0400.

      MOVE-CORRESPONDING gt_main TO lt_0400.

      lt_0400-dlvrq = lv_tmpno.
      lt_0400-erdat = sy-datlo.
      lt_0400-erzet = sy-timlo.
      lt_0400-ernam = sy-uname.

      APPEND lt_0400.

      IF gt_main-trade = 'E'.
        READ TABLE gt_0406 WITH KEY vbeln = gt_main-vbeln
                                    posnr = gt_main-posnr.
        IF sy-subrc = 0.
*___선적 추가정보
          CLEAR : lt_0406.

          MOVE-CORRESPONDING gt_0406 TO lt_0406.

          lt_0406-dlvrq = lv_tmpno.

          APPEND lt_0406.

*___선적 시뮬레이션 헤더정보
          IF gt_0406-cntsm = 'X'.    "컨테이너 선적 시뮬레이션
            lv_simul = 'X'.

            CLEAR : lt_0403.

            lt_0403-shsrq = lv_tmpno.
            lt_0403-edatu = gt_main-edatu.
            lt_0403-conty = gt_0406-conty.
            lt_0403-consz = gt_0406-consz.
            lt_0403-erdat = sy-datlo.
            lt_0403-erzet = sy-timlo.
            lt_0403-ernam = sy-uname.

            APPEND lt_0403.
          ELSE.
            CLEAR : lv_simul.
          ENDIF.
        ELSE.
          CLEAR : lv_simul.
        ENDIF.
      ELSE.
        CLEAR : lv_simul.
      ENDIF.
    ENDIF.

*____출하요청 품목정보 생성
    CLEAR : lt_0401.

    MOVE-CORRESPONDING gt_main TO lt_0401.

    lt_0401-indqty = gt_main-drind.
    lt_0401-dlvrq = lv_tmpno.
    lt_0401-aedat = sy-datlo.
    lt_0401-aezet = sy-timlo.
    lt_0401-aenam = sy-uname.

    APPEND lt_0401.

*___선적 시뮬레이션 품목정보
    IF lv_simul = 'X'.
      CLEAR : lt_0404.

      lt_0404-shsrq = lv_tmpno.
      lt_0404-vbeln = gt_main-vbeln.
      lt_0404-posnr = gt_main-posnr.
      lt_0404-dlrmg = gt_main-dlrmg.
      lt_0404-vrkme = gt_main-vrkme.
      lt_0404-aedat = sy-datlo.
      lt_0404-aezet = sy-timlo.
      lt_0404-aenam = sy-uname.

      APPEND lt_0404.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

*___출하요청 정보를 모두 생성한 후 실제 출하요청번호를 일괄 채번
  CONCATENATE sy-datlo '%' INTO lv_where.

  CLEAR : lv_dlvrq.

  SELECT MAX( dlvrq )
    INTO lv_dlvrq
    FROM zlet0400
   WHERE dlvrq LIKE lv_where.

  IF lv_dlvrq IS INITIAL.
    lv_dlvrq(8)   = sy-datlo.
    lv_dlvrq+8(4) = '0000'.
  ENDIF.

  LOOP AT lt_0400.
    lv_tmpno = lt_0400-dlvrq.

    lv_dlvrq = lv_dlvrq + 1.

    lt_0400-dlvrq = lv_dlvrq.
    lt_0401-dlvrq = lv_dlvrq.
    lt_0406-dlvrq = lv_dlvrq.

    IF lv_first IS INITIAL.
      lv_first = lv_dlvrq.
    ENDIF.

    lv_last = lv_dlvrq.

    PERFORM message_store USING 'ZLE1' 'S' '004'
                                '출하요청번호'
                                lv_dlvrq
                                '을(를) 생성하였습니다.'
                                ' '.

    MODIFY lt_0400.

    MODIFY lt_0401 TRANSPORTING dlvrq
                   WHERE dlvrq = lv_tmpno.

    MODIFY lt_0406 TRANSPORTING dlvrq
                   WHERE dlvrq = lv_tmpno.
  ENDLOOP.

*___선적시뮬레이션 정보를 모두 생성한 후 실제 선적시뮬레이션 요청번호를
*   일괄 채번
  CONCATENATE 'CS' sy-datlo+2(6) '%' INTO lv_where.

  CLEAR : lv_dlvrq.

  SELECT MAX( shsrq )
    INTO lv_dlvrq
    FROM zlet0403
   WHERE shsrq LIKE lv_where.

  IF lv_dlvrq IS INITIAL.
    lv_seq = '0000'.
    CONCATENATE 'CS' sy-datlo+2(6) '0000' INTO lv_dlvrq.
  ELSE.
    lv_seq = lv_dlvrq+8(4).
  ENDIF.

  LOOP AT lt_0403.
    lv_tmpno      = lt_0403-shsrq.

    lv_seq        = lv_seq + 1.
    lv_dlvrq+8(4) = lv_seq.
    lt_0403-shsrq = lv_dlvrq.
    lt_0404-shsrq = lv_dlvrq.

    PERFORM message_store USING 'ZLE1' 'S' '004'
                                '선적시뮬레이션 요청번호'
                                lv_dlvrq
                                '을(를) 생성하였습니다.'
                                ' '.

    MODIFY lt_0403.

    MODIFY lt_0404 TRANSPORTING shsrq
                   WHERE shsrq = lv_tmpno.
  ENDLOOP.

  MODIFY zlet0400 FROM TABLE lt_0400.
  IF sy-subrc = 0.
    MODIFY zlet0401 FROM TABLE lt_0401.
    IF sy-subrc = 0.
      IF lt_0406[] IS NOT INITIAL.
        MODIFY zlet0406 FROM TABLE lt_0406.
        IF sy-subrc <> 0.
          ROLLBACK WORK.

          MESSAGE s004 DISPLAY LIKE 'E'
             WITH '출하요청 선적추가정보 저장 시'
                  '오류가 발생하였습니다.'.
        ENDIF.
      ENDIF.

      IF sy-subrc = 0 AND lt_0403[] IS NOT INITIAL.
        MODIFY zlet0403 FROM TABLE lt_0403.
        IF sy-subrc = 0.
          MODIFY zlet0404 FROM TABLE lt_0404.
          IF sy-subrc <> 0.
            ROLLBACK WORK.

            MESSAGE s004 DISPLAY LIKE 'E'
               WITH '선적 시뮬레이션 요청 품목정보 저장 시'
                    '오류가 발생하였습니다.'.
          ENDIF.
        ELSE.
          ROLLBACK WORK.

          MESSAGE s004 DISPLAY LIKE 'E'
             WITH '선적 시뮬레이션 요청 헤더정보 저장 시'
                  '오류가 발생하였습니다.'.
        ENDIF.
      ENDIF.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.

*-      LAN CABLE : PP FM'ZGTPP_LINK_INFO_UPDATE' 호출
        CLEAR:gt_link[].
        gt_link[] = CORRESPONDING #( lt_0401[] ).
        PERFORM call_pp_link_info_chg USING gc_i.


        CALL FUNCTION 'MESSAGES_SHOW'
          EXPORTING
            show_linno = space.

        IF lv_first = lv_last.
          MESSAGE s004 WITH '출하요청번호' lv_first
                            '을(를) 생성하였습니다.'.
        ELSE.
          CONCATENATE '~' lv_last INTO lv_last SEPARATED BY space.

          MESSAGE s004 WITH '출하요청번호' lv_first lv_last
                            '을(를) 생성하였습니다.'.
        ENDIF.

*        MESSAGE S004 WITH '출하요청' LV_CNT
*                          '건을 저장하였습니다.'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '출하요청 품목정보 저장 시 오류가 발생하였습니다.'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '출하요청 헤더정보 저장 시 오류가 발생하였습니다.'.
  ENDIF.



ENDFORM.                    " CREATE_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  CHANGE_DELIVERY_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM change_delivery_info .
  DATA: BEGIN OF lt_0400 OCCURS 0,
          dlvrq LIKE zlet0400-dlvrq,
          trade,
        END   OF lt_0400.

  PERFORM check_delivert_info USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM popup_to_confirm USING '변경'
                                 '납품정보를 변경하시겠습니까?'
                                 '1'
                                 gv_answer.
  IF gv_answer = '1'.
    CLEAR   : lt_0400.
    REFRESH : lt_0400.

    CLEAR : gt_main.

    LOOP AT gt_main WHERE itsel = 'X'.
      lt_0400-dlvrq = gt_main-dlvrq.
      lt_0400-trade = gt_main-trade.

      COLLECT lt_0400.
    ENDLOOP.

    LOOP AT lt_0400.
      MOVE-CORRESPONDING: gs_delv TO gt_main,
                          gs_delv TO gt_main-keyno.

      IF lt_0400-dlvrq IS NOT INITIAL.

        MODIFY gt_main TRANSPORTING keyno
                                    post_code1      "우편번호
                                    land1           "국가
                                    lzone           "운송지역
                                    city1           "상세주소
                                    extension1      "수령인
                                    tel_number      "연락처
                                    arrdt           "도착일
                                    arrtm           "도착시간
                                    immdt           "긴급출하
                                    alone           "단독여부(혼적)
                                    vhctp           "차량제한여부
                                    vhctx           "차량제한여부
                                    bknft           "왕복여부
                                    divid           "분할출하
                                    trtyp           "운송유형
                                    remark          "비고
                                    zremark1        "출하실 요청사항
                              WHERE dlvrq = lt_0400-dlvrq.

*___선적정보 변경
        IF lt_0400-trade = 'E'.
          READ TABLE gt_0406 TRANSPORTING NO FIELDS
                             WITH KEY dlvrq = lt_0400-dlvrq.
          IF sy-subrc = 0.
            MODIFY gt_0406 INDEX sy-tabix.
          ELSE.
            APPEND gt_0406.
          ENDIF.
        ENDIF.

      ELSE.

*       직송의뢰 신청유형
        IF gv_trtyp EQ 'H'.
          PERFORM set_vstel_for_zreq_type USING gt_main.
          CLEAR:gt_main-keyno.
          "출하요납품생성 단위 Key Field
          MOVE-CORRESPONDING gt_main TO gt_main-keyno.
        ENDIF.
        MODIFY gt_main TRANSPORTING keyno
                                    post_code1      "우편번호
                                    land1           "국가
                                    lzone           "운송지역
                                    city1           "상세주소
                                    extension1      "수령인
                                    tel_number      "연락처
                                    arrdt           "도착일
                                    arrtm           "도착시간
                                    immdt           "긴급출하
                                    alone           "단독여부(혼적)
                                    vhctp           "차량제한여부
                                    vhctx           "차량제한여부
                                    bknft           "왕복여부
                                    divid           "분할출하
                                    zreq_type       "직송의뢰 신청 유형
                                    trtyp           "운송유형
                                    remark          "비고
                                    vstel           "출하지점
                                    zremark1        "출하실 요청사항
                              WHERE dlvrq IS INITIAL
                                AND itsel = 'X'.
*___선적정보 변경
        IF lt_0400-trade = 'E'.
          LOOP AT gt_main WHERE dlvrq IS INITIAL
                            AND itsel = 'X'.
            READ TABLE gt_0406 TRANSPORTING NO FIELDS
                               WITH KEY dlvrq = gt_main-dlvrq
                                        vbeln = gt_main-vbeln
                                        posnr = gt_main-posnr.
            IF sy-subrc = 0.
              gt_0406-dlvrq = gt_main-dlvrq.
              gt_0406-vbeln = gt_main-vbeln.
              gt_0406-posnr = gt_main-posnr.

              MODIFY gt_0406 INDEX sy-tabix.
            ELSE.
              gt_0406-dlvrq = gt_main-dlvrq.
              gt_0406-vbeln = gt_main-vbeln.
              gt_0406-posnr = gt_main-posnr.

              APPEND gt_0406.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gv_edatu IS NOT INITIAL.
      gt_main-edatu = gv_edatu.

      MODIFY gt_main TRANSPORTING edatu         "납품일
                            WHERE itsel = 'X'.
    ENDIF.

    IF sy-subrc = 0.
      MESSAGE s004 WITH '납품처 정보가 변경되었습니다.'.

      PERFORM refresh_alv USING gc_alv_grid.

      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CHANGE_DELIVERY_INFO
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_screen_0200 .
  DATA: lv_dscrp    LIKE zlet0013-dscrp,
        lv_kunag    LIKE zlet0400-kunag,
        lv_kunwe    LIKE zlet0400-kunwe,
        lv_vstel    LIKE zlet0400-vstel,
        lv_trade,
        lv_text(50).

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

  CLEAR : lv_kunag, lv_kunwe, lv_vstel, lv_trade.

  IF gv_trtyp = 'H'.
    lv_text = '판매오더'.
  ELSE.
    lv_text = '출하요청번호'.
  ENDIF.

  LOOP AT gt_main WHERE itsel = 'X'.
    IF lv_kunag IS INITIAL.
      lv_kunag = gt_main-kunag.
    ENDIF.

    IF lv_kunwe IS INITIAL.
      lv_kunwe = gt_main-kunwe.
    ENDIF.

    IF lv_vstel IS INITIAL.
      lv_vstel = gt_main-vstel.
    ENDIF.

    IF lv_trade IS INITIAL.
      lv_trade = gt_main-trade.
    ENDIF.

    IF lv_kunag <> gt_main-kunag OR lv_kunwe <> gt_main-kunwe.
      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '판매처/납품처가 다른' lv_text '를 선택하셨습니다.'.

      RETURN.
    ENDIF.

    IF lv_trade <> gt_main-trade.
      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '출하지점이 다른' lv_text '를 선택하셨습니다.'.

      RETURN.
    ENDIF.

    IF lv_trade <> gt_main-trade.
      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '수출구분이 다른' lv_text '를 선택하셨습니다.'.

      RETURN.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_main WITH KEY itsel = 'X'.
  IF sy-subrc = 0.
    CLEAR : gs_delv, gv_edatu.

    MOVE-CORRESPONDING gt_main TO gs_delv.


    IF gt_main-trade = 'E'.
*___선적정보 기본값
      PERFORM set_shipment_info.
    ENDIF.

    IF gv_trtyp = 'H'.
      IF gs_delv-vhctp IS INITIAL.
*___차량제한여부
        SELECT SINGLE ton
          INTO gs_delv-vhctp
          FROM zlet0012
         WHERE vstel = gt_main-vstel
           AND kunnr = gt_main-kunwe.
      ENDIF.

*___단독여부
      IF gs_delv-alone IS INITIAL.
        CLEAR : lv_dscrp.

        SELECT SINGLE dscrp
          INTO lv_dscrp
          FROM zlet0013
         WHERE vstel = gt_main-vstel
           AND kunnr = gt_main-kunwe.

        IF lv_dscrp IS NOT INITIAL.
          gs_delv-alone = 'X'.
        ENDIF.
      ENDIF.

      IF gt_main-trade = 'E' AND gt_0406-agent1 IS INITIAL.
*___에이전트/대체수취인
        SELECT SINGLE kunnr
          INTO gt_0406-agent1
          FROM vbpa
         WHERE vbeln = gt_main-vbeln
           AND posnr = gt_main-posnr
           AND parvw = 'ZG'.      "Agent Vendor

        IF sy-subrc <> 0.
          SELECT SINGLE kunnr
            INTO gt_0406-agent1
            FROM vbpa
           WHERE vbeln = gt_main-vbeln
             AND posnr = '000000'
             AND parvw = 'ZG'.      "Agent Vendor
        ENDIF.

        IF gt_0406-agent1 IS NOT INITIAL.
          gt_0406-comms = 'X'.
          gt_0406-abwze = gt_0406-agent1.

          PERFORM get_kunnr_desc USING: gt_0406-agent1 gv_agnnm1,
                                        gt_0406-abwze  gv_abwnm.
        ENDIF.
      ENDIF.
    ELSE.
      gv_edatu = gt_main-edatu.
    ENDIF.

    IF gt_main-trade = 'E'.
      IF gt_0406-sacpt IS INITIAL.
        gv_icon = '@5C@'.   "ICON_LED_RED
      ELSE.
        gv_icon = '@5B@'.   "ICON_LED_GREEN
      ENDIF.
*->[가온전선]--------------------CHG S
*      GV_SUBSCR = '0201'.
      gv_subscr = '0202'.
*-<[가온전선]--------------------CHG E
    ELSE.
      IF gs_delv-land1 IS INITIAL.
        gs_delv-land1 = 'KR'.
      ENDIF.

      gv_subscr = '0202'.
    ENDIF.

    CLEAR : gv_cursor2.
    gv_cursor1 = 'GS_DELV-POST_CODE1'.

    CALL SCREEN 0200 STARTING AT 20 2.
  ENDIF.

ENDFORM.                    " CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*&      Form  CHECK_POST_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_post_code USING pv_post1
                           pv_lzone
                           pv_error
                           pv_text.

  DATA: lv_lzone    LIKE zgtsdt9121-zone1.

  CLEAR : lv_lzone.

  SELECT SINGLE zone1
    INTO lv_lzone
    FROM zgtsdt9121
   WHERE post_code = pv_post1.

  IF sy-subrc = 0.
    pv_lzone = lv_lzone.

*    IF PV_LZONE <> LV_LZONE AND LV_LZONE IS NOT INITIAL.
*      IF PV_ERROR = 'E'.
*        MESSAGE E004
*           WITH '우편번호와 운송지역 정보가'
*                '일치하지 않습니다.'.
*      ELSE.
*        PV_ERROR = 'X'.
*
*        PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
*                                    '판매오더-품목'
*                                    PV_TEXT
*                                    '우편번호와 운송지역 정보가'
*                                    '일치하지 않습니다.'.
*      ENDIF.
*    ENDIF.
  ELSE.
    IF pv_error = 'E'.
      MESSAGE e004 WITH '유효하지 않은 우편번호입니다.'.
    ELSE.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  pv_text
                                  '의 우편번호가'
                                  '유효하지 않습니다.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_POST_CODE
*&---------------------------------------------------------------------*
*&      Form  CHECK_TRANSPORT_ZONE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_transport_zone .


  CHECK gs_delv-land1 IS NOT INITIAL OR
        gs_delv-lzone IS NOT INITIAL.

  IF ( gs_delv-land1 IS NOT INITIAL AND gs_delv-lzone IS INITIAL ) OR
     ( gs_delv-lzone IS NOT INITIAL AND gs_delv-land1 IS INITIAL ).
    MESSAGE e004 WITH '국가키와 운송경로를 모두 입력하십시오.'.
  ELSE.
    SELECT SINGLE zone1
      INTO gs_delv-lzone
      FROM tzone
     WHERE land1 = gs_delv-land1
       AND zone1 = gs_delv-lzone.

    IF sy-subrc <> 0.
      MESSAGE e004 WITH '유효하지 않은 운송경로입니다.'
                        '국가키와 운송경로를 확인하십시오.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_TRANSPORT_ZONE
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM select_all .

  IF ok_save = 'ASEL'.
    gt_main-hdsel = 'X'.
    gt_main-itsel = 'X'.
  ELSE.
    CLEAR : gt_main-hdsel, gt_main-itsel.
  ENDIF.

  MODIFY gt_main TRANSPORTING hdsel itsel
                 WHERE vbeln  IS NOT INITIAL
                   AND confm  IS INITIAL
                   AND hlvorm IS INITIAL
                   AND ilvorm IS INITIAL..

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM data_changed USING rr_data_changed TYPE REF TO
                                        cl_alv_changed_data_protocol
                        r_onf4
                        r_ucomm TYPE sy-ucomm.

  DATA: ls_mod_cells TYPE lvc_s_modi,
        ls_cells     TYPE lvc_s_modi.

  DATA: lv_dlrmg LIKE zlet0401-dlrmg,
        lv_drind LIKE zlet0401-indqty,
        lv_edatu LIKE zlet0401-edatu,
        lv_check.

  CALL METHOD rr_data_changed->refresh_protocol.

  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN  'DLRMG'.
        READ TABLE gt_main INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          CALL METHOD rr_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = ls_mod_cells-fieldname
            IMPORTING
              e_value     = lv_dlrmg.

          IF lv_dlrmg > gt_main-ramng.
            CALL METHOD rr_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZLE1'
                i_msgno     = '004'
                i_msgty     = 'E'
                i_msgv1     = '출하요청수량은 출하가능수량을'
                i_msgv2     = '초과할 수 없습니다.'
                i_msgv3     = ' '
                i_msgv4     = ' '
                i_fieldname = ls_mod_cells-fieldname
                i_row_id    = ls_mod_cells-row_id.
          ELSEIF lv_dlrmg < gt_main-lfimg_m.
            CALL METHOD rr_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZLE1'
                i_msgno     = '004'
                i_msgty     = 'E'
                i_msgv1     = '출하요청수량은 납품생성수량보다'
                i_msgv2     = '작을수 없습니다.'
                i_msgv3     = ' '
                i_msgv4     = ' '
                i_fieldname = ls_mod_cells-fieldname
                i_row_id    = ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN  'DRIND'.
        READ TABLE gt_main INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          CALL METHOD rr_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = ls_mod_cells-fieldname
            IMPORTING
              e_value     = lv_drind.

          lv_dlrmg = gt_main-indlen * lv_drind.

          IF lv_dlrmg > gt_main-ramng.
            CALL METHOD rr_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZLE1'
                i_msgno     = '004'
                i_msgty     = 'E'
                i_msgv1     = '출하요청수량은 출하가능수량을'
                i_msgv2     = '초과할 수 없습니다.'
                i_msgv3     = ' '
                i_msgv4     = ' '
                i_fieldname = ls_mod_cells-fieldname
                i_row_id    = ls_mod_cells-row_id.
          ELSEIF lv_dlrmg < gt_main-lfimg_m.
            CALL METHOD rr_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZLE1'
                i_msgno     = '004'
                i_msgty     = 'E'
                i_msgv1     = '출하요청수량은 납품생성수량보다'
                i_msgv2     = '작을수 없습니다.'
                i_msgv3     = ' '
                i_msgv4     = ' '
                i_fieldname = ls_mod_cells-fieldname
                i_row_id    = ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN 'EDATU'.
        READ TABLE gt_main INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          CALL METHOD rr_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = ls_mod_cells-fieldname
            IMPORTING
              e_value     = lv_edatu.

          IF lv_edatu < sy-datlo.
            CALL METHOD rr_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZLE1'
                i_msgno     = '004'
                i_msgty     = 'E'
                i_msgv1     = '납품일에 과거일자를'
                i_msgv2     = '입력할 수 없습니다.'
                i_msgv3     = ' '
                i_msgv4     = ' '
                i_fieldname = ls_mod_cells-fieldname
                i_row_id    = ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN 'HDSEL' OR 'ITSEL'.
        READ TABLE gt_main INDEX ls_mod_cells-row_id.
        IF sy-subrc = 0.
          CALL METHOD rr_data_changed->get_cell_value
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = ls_mod_cells-fieldname
            IMPORTING
              e_value     = lv_check.

          READ TABLE gt_main INTO gs_main WITH KEY itsel = 'X'.
          IF sy-subrc = 0.
            IF gv_trtyp = 'H'.
*              IF GS_MAIN-TRADE <> GT_MAIN-TRADE.
*                CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*                  EXPORTING
*                    I_MSGID     = 'ZLE1'
*                    I_MSGNO     = '004'
*                    I_MSGTY     = 'E'
*                    I_MSGV1     = '내수와 수출 판매오더를'
*                    I_MSGV2     = '동시에 선택할 수 없습니다.'
*                    I_MSGV3     = ' '
*                    I_MSGV4     = ' '
*                    I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*                    I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
*              ENDIF.
*
*              IF GS_MAIN-KUNAG <> GT_MAIN-KUNAG OR
*                 GS_MAIN-KUNWE <> GT_MAIN-KUNWE.
*                CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*                  EXPORTING
*                    I_MSGID     = 'ZLE1'
*                    I_MSGNO     = '004'
*                    I_MSGTY     = 'E'
*                    I_MSGV1     = '판매처와 납품처가 다른 건을'
*                    I_MSGV2     = '동시에 선택할 수 없습니다.'
*                    I_MSGV3     = ' '
*                    I_MSGV4     = ' '
*                    I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*                    I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
*              ENDIF.
*
*              IF GS_MAIN-VSTEL <> GT_MAIN-VSTEL.
*                CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
*                  EXPORTING
*                    I_MSGID     = 'ZLE1'
*                    I_MSGNO     = '004'
*                    I_MSGTY     = 'E'
*                    I_MSGV1     = '출하지점이 다른 건을'
*                    I_MSGV2     = '동시에 선택할 수 없습니다.'
*                    I_MSGV3     = ' '
*                    I_MSGV4     = ' '
*                    I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*                    I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
*              ENDIF.
            ELSE.
              IF gs_main-dlvrq <> gt_main-dlvrq.
                CALL METHOD rr_data_changed->add_protocol_entry
                  EXPORTING
                    i_msgid     = 'ZLE1'
                    i_msgno     = '004'
                    i_msgty     = 'E'
                    i_msgv1     = '출하요청번호가 다른 건을'
                    i_msgv2     = '동시에 선택할 수 없습니다.'
                    i_msgv3     = ' '
                    i_msgv4     = ' '
                    i_fieldname = ls_mod_cells-fieldname
                    i_row_id    = ls_mod_cells-row_id.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  CALL METHOD rr_data_changed->display_protocol.

ENDFORM.                    " DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  GET_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_delivery_req_data .
  DATA: lt_main LIKE gt_main  OCCURS 0 WITH HEADER LINE,
        lt_0402 LIKE zlet0402 OCCURS 0 WITH HEADER LINE.

  RANGES: lr_kdkg4  FOR  vbkd-kdkg4,
          lr_trtyp  FOR  zlet0400-trtyp.

  CLEAR   : gt_main, gt_0406, lr_kdkg4, lr_trtyp.
  REFRESH : gt_main, gt_0406, lr_kdkg4, lr_trtyp.

  CASE 'X'.
    WHEN p_r22.      "내수/로컬
      set_ranges: lr_kdkg4 'I' 'EQ' '4D' ' ',
                  lr_kdkg4 'I' 'EQ' '4L' ' '.

    WHEN p_r23.      "수출
      set_ranges: lr_kdkg4 'I' 'EQ' '4E' ' ',
                  lr_kdkg4 'I' 'EQ' '4S' ' '.

    WHEN OTHERS.    "전체

  ENDCASE.

  IF p_trtyp <> '00'.
    set_ranges: lr_trtyp 'I' 'EQ' p_trtyp ' '.
  ENDIF.

  SELECT a~dlvrq            "출하요청번호
         b~vbeln            "판매오더
         b~posnr            "판매오더품목
         a~auart            "오더유형
         a~vkorg            "영업조직
         a~vkbur            "영업팀
         a~vkgrp            "영업그룹
         a~pernr            "영업사원
         a~kunwe            "납품처
         a~kunag            "판매처
         a~kdkg4            "내수/수출
         b~sobkz            "특별재고지시자
         b~matnr            "자재
         b~kwmeng           "오더수량
         b~vrkme            "판매단위
         b~indlen           "조장
         b~indqty           "조장수
         a~vstel            "출하지점
         b~werks            "플랜트
         c~lgort            "저장위치   "기능개선 231127 - 추가
         a~spart            "제품군
         a~post_code1       "우편번호
         a~land1            "국가
         a~lzone            "운송지역
         a~city1            "상세주소
         a~extension1       "수령인
         a~tel_number       "연락처
         a~arind            "도착시간 입력여부
         a~arrdt            "도착일
         a~arrtm            "도착시간
         a~immdt            "긴급출하
         a~alone            "단독여부(혼적)
         a~vhctp            "차량제한여부
         a~bknft            "왕복여부
         a~divid            "분할출하
         a~zreq_type        "직송의뢰 신청 유형
         a~trtyp            "운송유형
         b~edatu            "납품일정
         b~dlrmg            "출하요청수량
         b~reviw            "출하검토여부
         b~revmg            "출하검토수량
         b~lecfm            "출하확정
         b~sdcfm            "영업확정
         a~remark           "비고
         a~lvorm AS hlvorm  "삭제지시자(헤더)
         b~lvorm AS ilvorm  "삭제지시자(품목)
*->>[가온전선]-----------------------------------------S
         a~zremark1
         c~netwr
         c~waerk
         d~kkber
         e~assigned_bp AS kunrg
         c~mwsbp
         c~fixmg
*-<<[가온전선]-----------------------------------------E
    INTO CORRESPONDING FIELDS OF TABLE gt_main
    FROM zlet0400 AS a
   INNER JOIN zlet0401 AS b
      ON a~dlvrq  = b~dlvrq
   INNER JOIN vbap AS c        "기능개선 143708 - 추가
      ON b~vbeln  = c~vbeln    "기능개선 143708 - 추가
     AND b~posnr  = c~posnr    "기능개선 143708 - 추가
*->>[가온전선]-----------------------------------------S
   INNER JOIN vbak AS d
      ON c~vbeln = d~vbeln
   INNER JOIN vbpa AS e
      ON c~vbeln = e~vbeln
     AND e~posnr = '000000'
     AND e~parvw = 'RG'      "지급처
*-<<[가온전선]-----------------------------------------E
   WHERE a~vkorg  =  gc_vkorg
     AND a~dlvrq  IN s_dlvrq
     AND a~erdat  IN s_erdat1
     AND b~edatu  IN s_edatu1
     AND a~vkbur  IN s_vkbur1
     AND a~vkgrp  IN s_vkgrp1
     AND a~kunag  IN s_kunag1
     AND a~kunwe  IN s_kunwe1
     AND b~vbeln  IN s_vbeln1
     AND a~vstel  IN s_vstel1
*     AND C~VSTEL  IN S_VSTEL1
     AND a~spart  IN s_spart1
     AND b~werks  IN s_werks1
     AND b~matnr  IN s_matnr1
     AND a~kdkg4  IN lr_kdkg4
     AND a~pernr  IN s_pernr1
     AND a~trtyp  IN lr_trtyp.


  LOOP AT gt_main.

*___출하/영업 확정 선택조건
    IF ( p_r32 = 'X' AND ( gt_main-lecfm =  'CM'      OR
                           gt_main-lecfm =  'CS'      OR
                           gt_main-sdcfm =  'CM'      OR
                           gt_main-sdcfm =  'CS'  ) ) OR
       ( p_r33 = 'X' AND ( gt_main-lecfm <> 'CM'      AND
                           gt_main-lecfm <> 'CS'      AND
                           gt_main-sdcfm <> 'CM'      AND
                           gt_main-sdcfm <> 'CS' ) ).
      DELETE gt_main.
      CONTINUE.
    ENDIF.


*___삭제여부 선택조건
    IF p_r41 = 'X' AND ( gt_main-hlvorm = 'X' OR
                         gt_main-ilvorm = 'X' ).
      DELETE gt_main.
      CONTINUE.
    ENDIF.

*___제조지시번호
    PERFORM get_order_jobno USING gt_main-vbeln
                                  gt_main-posnr
                                  gt_main-jobno.

    IF gt_main-jobno NOT IN s_jobno1.
      DELETE gt_main.
      CONTINUE.
    ENDIF.

*___PO번호
    PERFORM get_customer_po USING gt_main-vbeln
                                  gt_main-posnr
                                  gt_main-bstkd
                                  gt_main-bstdk  "기능개선 161289 - 추가
                                  gt_main-empst. "기능개선 164038 - 추가

*___출하/영업 확정여부
    IF gt_main-lecfm = 'CM' OR gt_main-sdcfm = 'CS' OR
       gt_main-sdcfm = 'CM'.
      gt_main-confm = 'X'.
    ENDIF.

*___확정수량
    SELECT SUM( bmeng )
      INTO gt_main-bmeng
      FROM vbep
     WHERE vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr.

*___조장
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_length
                                        gt_main-indlen.

*___색상
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_cbase
                                        gt_main-color.

*{ 기능개선 161289 - 추가
*___절연선심식별 코드
    PERFORM get_so_characteristic USING gt_main-vbeln
                                        gt_main-posnr
                                        gc_inscd
                                        gt_main-inscd.
*} 기능개선 161289 - 추가

*___출하요청정보
    PERFORM get_zlet0401_data.

*___조장수
    IF gt_main-indlen IS NOT INITIAL.
      gt_main-drind  = gt_main-dlrmg  / gt_main-indlen.
    ENDIF.

*___납품완료 구분
    IF ( p_r52 = 'X' AND gt_main-dlrmg >  gt_main-dcmng_r ) OR
       ( p_r53 = 'X' AND gt_main-dlrmg <= gt_main-dcmng_r ).
      DELETE gt_main.
      CONTINUE.
    ENDIF.


*___수출/내수 구분
    IF gt_main-kdkg4 = '4D' OR gt_main-kdkg4 = '4L'.
      gt_main-trade = 'D'.    "내수


      IF p_r61 <> 'X'.    "선적접수를 '전체'로 선택한 경우만 조회됨
        DELETE gt_main.
        CONTINUE.
      ENDIF.

    ELSE.
      gt_main-trade = 'E'.    "수출

*___선적 추가정보
      READ TABLE gt_0406 WITH KEY dlvrq = gt_main-dlvrq
                                  BINARY SEARCH.
      IF sy-subrc <> 0.
        CLEAR : gt_0406.

        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF gt_0406
          FROM zlet0406
         WHERE dlvrq = gt_main-dlvrq.

        IF sy-subrc = 0.

          IF ( p_r62 = 'X' AND gt_0406-sacpt = ' ' ) OR
             ( p_r63 = 'X' AND gt_0406-sacpt = 'X' ).
            DELETE gt_main.
            CONTINUE.
          ENDIF.


          APPEND gt_0406.

          SORT gt_0406 BY dlvrq.
        ELSE.
          DELETE gt_main.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF gt_0406-sacpt = 'X'.
        gt_main-sacpt = '@5B@'.
      ELSE.
        gt_main-sacpt = '@5C@'.
      ENDIF.

*___수출인 경우 선적 시뮬레이션 요청이 있는 경우 제외
      SELECT SINGLE vbeln
        INTO gt_main-vbeln
        FROM zlet0404 AS a
       INNER JOIN zlet0403 AS b
          ON a~shsrq = b~shsrq
       WHERE a~vbeln = gt_main-vbeln
         AND a~posnr = gt_main-posnr
         AND a~lvorm = ' '
         AND b~ifdat = '0000000'
         AND b~lvorm = ' '.

      IF sy-subrc = 0.
        DELETE gt_main.
        CONTINUE.
      ENDIF.
    ENDIF.

*___출하검토상태
*    IF GT_MAIN-LECFM IS NOT INITIAL OR GT_MAIN-SDCFM IS NOT INITIAL.
*      GT_MAIN-RVSTA = 'CM'.            "출하확정
*    ELSE.
*      IF GT_MAIN-REVIW IS NOT INITIAL.
*        IF GT_MAIN-DIVID = 'X'.
*          GT_MAIN-RVSTA = 'P'.         "분할납품/검토완료
*        ELSE.
*          GT_MAIN-RVSTA = 'C'.         "검토완료
*        ENDIF.
*      ENDIF.
*    ENDIF.

*___판매처 명
    PERFORM get_kunnr_desc USING: gt_main-kunag
                                  gt_main-namag.

*___납품처명
    SELECT SINGLE adrnr
      INTO gt_main-adrnr
      FROM vbpa
     WHERE vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr
       AND parvw = 'WE'.

    IF sy-subrc <> 0.
      SELECT SINGLE adrnr
        INTO gt_main-adrnr
        FROM vbpa
       WHERE vbeln = gt_main-vbeln
         AND posnr = '000000'
         AND parvw = 'WE'.
    ENDIF.

    PERFORM get_ship_to_info USING gt_main-adrnr
                                   gt_main-namwe
                                   ' ' ' ' ' ' ' ' ' ' ' '
                                   ' '  .

*___영업사원명
    PERFORM get_pernr_desc USING gt_main-pernr
                                 gt_main-sname.

*___여신상태
    PERFORM get_vbuk_data USING gt_main-vbeln
                                gt_main-cmgst.

*___MTO/MTS
    IF gt_main-fixmg IS NOT INITIAL.
      gt_main-sotxt = 'MTS'.
    ELSE.
      gt_main-sotxt = 'MTO'.
    ENDIF.
*    IF GT_MAIN-SOBKZ IS NOT INITIAL.
*      GT_MAIN-SOTXT = 'MTO'.
*    ELSE.
*      GT_MAIN-SOTXT = 'MTS'.
*    ENDIF.

*___제품명
    PERFORM get_matnr_desc USING gt_main-matnr
                                 gt_main-maktx.

*___출하지점명
    PERFORM get_vstel_desc USING gt_main-vstel
                                 gt_main-vtext.

*___플랜트명
    PERFORM get_werks_desc USING gt_main-werks
                                 gt_main-name1.

*___차량제한
    PERFORM get_vhctp_desc USING gt_main-vhctp
                                 gt_main-vhctx.

*___가용재고/품질재고
    PERFORM get_stock_data USING gt_main-matnr
                                 gt_main-vstel   "기능개선 231127 - 추가
                                 gt_main-werks
                                 gt_main-lgort   "기능개선 231127 - 추가
                                 gt_main-vbeln
                                 gt_main-posnr
                                 gt_main-sobkz
                                 gt_main-vrkme
                                 gt_main-labst
                                 gt_main-insme.

    gt_main-indmei = 'EA'.

*___납품생성 단위 Key Field
    MOVE-CORRESPONDING gt_main TO gt_main-keyno.

    IF gt_main-jobno IS NOT INITIAL.
      gt_main-keyno-keyno = gt_main-jobno.   "제조지시번호
    ELSE.
      gt_main-keyno-keyno = gt_main-dlvrq.   "출하요청번호
    ENDIF.

*->>[가온전선]-----------------------------------------S
    "DB의 출하요청수량 별도 저장
    gt_main-dlrmg_old = gt_main-dlrmg.
*-<<[가온전선]-----------------------------------------E
    MODIFY gt_main.
  ENDLOOP.

*___조회인 경우 납품문서 정보 추가
  IF gv_trtyp = 'A'.
    lt_main[] = gt_main[].

    CLEAR   : gt_main.
    REFRESH : gt_main.

    LOOP AT lt_main.
      CLEAR   : lt_0402, gt_main.
      REFRESH : lt_0402.

      MOVE-CORRESPONDING lt_main TO gt_main.

      SELECT *
        INTO TABLE lt_0402
        FROM zlet0402
       WHERE dlvrq =  lt_main-dlvrq
         AND vbeln =  lt_main-vbeln
         AND posnr =  lt_main-posnr
         AND vgbel IN s_vgbel1.

      LOOP AT lt_0402.
        gt_main-vgbel = lt_0402-vgbel.
        gt_main-vgpos = lt_0402-vgpos.

*___납품문서 수량
        SELECT SUM( lfimg )
          INTO gt_main-lfimg_d
          FROM lips
         WHERE vbeln = gt_main-vgbel
           AND ( posnr = gt_main-vgpos
              OR uecha = gt_main-vgpos ).

        APPEND gt_main.
      ENDLOOP.

      IF s_vgbel1[] IS INITIAL AND sy-subrc <> 0.
        APPEND gt_main.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  F4HELP_POST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4help_post  USING    pv_pcode.
  DATA: selectfield  LIKE  help_info-fieldname,
        it_fields    LIKE  help_value OCCURS 1 WITH HEADER LINE,
        select_value LIKE  help_info-fldvalue,
        ld_tabix     LIKE  sy-tabix.

  DATA: scr_fields LIKE dynpread OCCURS 0 WITH HEADER LINE,
        feld_table LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_9121 OCCURS 0,
          post_code LIKE zgtsdt9121-post_code,
          post_name LIKE zgtsdt9121-post_name,
        END   OF lt_9121.

  CLEAR   : selectfield, select_value, ld_tabix,
            it_fields, scr_fields, feld_table, lt_9121.
  REFRESH : it_fields, scr_fields, feld_table, lt_9121.

  SELECT post_code
         post_name
    INTO CORRESPONDING FIELDS OF TABLE lt_9121
    FROM zgtsdt9121.

  IF sy-subrc <> 0.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '설정된 우편번호가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  it_fields-tabname    = 'ZGTSDT9121'.
  it_fields-fieldname  = 'POST_CODE'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname    = 'ZGTSDT9121'.
  it_fields-fieldname  = 'POST_NAME'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = lt_9121
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.

  READ TABLE lt_9121 INDEX ld_tabix.
  IF sy-subrc = 0.
    pv_pcode = lt_9121-post_code.
  ENDIF.

ENDFORM.                    " F4HELP_POST
*&---------------------------------------------------------------------*
*&      Form  SD_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sd_confirm .

  IF sy-sysid CA 'P'.
    MESSAGE i004 WITH '현재 운영에서는 출하확정을 할 수 없습니다.'
                      '(테스트 기간)'.
    EXIT.
  ENDIF.

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM check_selected_data USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM popup_to_confirm USING '확인'
                                 '출하확정 하시겠습니까?'
                                 '1'
                                 gv_answer.
  IF gv_answer = '1'.
    PERFORM create_delivery_data.

    PERFORM get_delivery_req_data.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SD_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  CREATE_DELIVERY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_delivery_data .
  DATA: lv_indqty   TYPE i.

  CLEAR : gv_error, gs_main.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  SORT gt_main BY keyno.

*___운송유형이 '02'(로베드)인 경우 조장수만큼 납품 생성
  LOOP AT gt_main WHERE itsel  =  'X'
                    AND trtyp  =  '02'   "로베드
                    AND indlen >  0
                    AND dlrmg  >  0.
*___출하요청 조장수
    lv_indqty = gt_main-dlrmg / gt_main-indlen.

    gs_main       = gt_main.
    gt_main-dlrmg = gt_main-indlen.

    DO lv_indqty TIMES.
      CLEAR   : gt_bdctab, gt_retmsg, gt_0402, gv_posnr.
      REFRESH : gt_bdctab, gt_retmsg, gt_0402.

      PERFORM fill_bdc_header.

      PERFORM fill_bdc_item USING 'X'.

      PERFORM fill_bdc_last.

      PERFORM call_transaction USING gv_error.
    ENDDO.
  ENDLOOP.

*___운송유형이 '02'(로베드)가 아닌 경우
  LOOP AT gt_main WHERE itsel  =  'X'
                    AND ( trtyp  <> '02' OR indlen = 0 )
                    AND dlrmg  >  0.
    IF gs_main-keyno <> gt_main-keyno.
      IF gs_main IS NOT INITIAL.
        PERFORM fill_bdc_last.

        PERFORM call_transaction USING gv_error.
      ENDIF.

      CLEAR   : gt_bdctab, gt_retmsg, gt_0402, gv_posnr.
      REFRESH : gt_bdctab, gt_retmsg, gt_0402.

      gs_main = gt_main.

      PERFORM fill_bdc_header.

      PERFORM fill_bdc_item USING 'X'.
    ELSE.
      PERFORM fill_bdc_item USING ' '.
    ENDIF.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM fill_bdc_last.

    PERFORM call_transaction USING gv_error.
  ENDIF.

  IF gv_error IS INITIAL.
    MESSAGE s004 WITH '출하확정을 완료하였습니다.'.
  ENDIF.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno = space.

ENDFORM.                    " CREATE_DELIVERY_DATA
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM dynpro  USING  pv_dynbegin
                    pv_fnam
                    pv_fval.

  CLEAR : gt_bdctab.

  IF  pv_dynbegin =  'X'.
    gt_bdctab-dynbegin  =  'X'.
    gt_bdctab-program   =  pv_fnam.
    gt_bdctab-dynpro    =  pv_fval.
    APPEND gt_bdctab.
  ELSE.
    gt_bdctab-fnam      =  pv_fnam.
    gt_bdctab-fval      =  pv_fval.
    APPEND gt_bdctab.
  ENDIF.

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_bdc_header .
  DATA: lv_edatu     LIKE vbep-edatu,
        lv_datum(10).

  lv_edatu = '99991231'.
  WRITE: lv_edatu TO lv_datum.

  PERFORM  dynpro  USING :
               'X'  'SAPMV50A'              '4001',
               ' '  'BDC_OKCODE'            '/00',
               ' '  'LIKP-VSTEL'            gt_main-vstel,
               ' '  'LV50C-DATBI'           lv_datum,
               ' '  'LV50C-VBELN'           gt_main-vbeln,
               ' '  'LV50C-ABPOS'           gt_main-posnr,
               ' '  'LV50C-BIPOS'           gt_main-posnr.

ENDFORM.                    " FILL_BDC_HEADER
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_bdc_item USING pv_first.
  DATA: lv_lfimg(20).

  gv_posnr = gv_posnr + 10.

  WRITE : gt_main-dlrmg TO lv_lfimg UNIT gt_main-vrkme
                                    LEFT-JUSTIFIED.

  CLEAR : gt_0402.
  gt_0402-dlvrq = gt_main-dlvrq.
  gt_0402-vbeln = gt_main-vbeln.
  gt_0402-posnr = gt_main-posnr.
  gt_0402-vgpos = gv_posnr.
  gt_0402-wbsta = 'A'.
  APPEND gt_0402.

  IF pv_first IS INITIAL.
    PERFORM  dynpro  USING :
                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '=RAUF_T',    "판매오더 납품

                 'X'  'SAPMV50A'          '0105',
                 ' '  'BDC_OKCODE'        '=ENT1',
                 ' '  'LV50C-VBELN'       gt_main-vbeln,
                 ' '  'LV50C-ABPOS'       gt_main-posnr,
                 ' '  'LV50C-BIPOS'       gt_main-posnr.
  ENDIF.

  PERFORM  dynpro  USING :
                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '=POPO_T',    "품목선택

                 'X'  'SAPMV50A'          '0111',
                 ' '  'BDC_OKCODE'        '=WEIT',      "품목입력
                 ' '  'RV50A-POSNR'       gv_posnr,

                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '/00',
                 ' '  'LIPSD-G_LFIMG(01)' lv_lfimg.

ENDFORM.                    " FILL_BDC_ITEM
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_LAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_bdc_last.
  DATA: lv_datum1(10),
        lv_datum2(10),
        lv_text(40).

  WRITE : gs_main-edatu TO lv_datum1,
          gs_main-arrdt TO lv_datum2.

  CONCATENATE gs_main-extension1 '/' gs_main-tel_number
         INTO lv_text.

  PERFORM  dynpro  USING :
               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=WADR_T',    "납품처주소

               'X'  'SAPLV09C'              '5000',
               ' '  'BDC_OKCODE'            '=ENT1',
               ' '  'ADDR1_DATA-POST_CODE1' gs_main-post_code1,
               ' '  'ADDR1_DATA-CITY1'      gs_main-city1,
               ' '  'ADDR1_DATA-COUNTRY'    gs_main-land1,
               ' '  'ADDR1_DATA-TRANSPZONE' gs_main-lzone,
               ' '  'SZA1_D0100-TEL_NUMBER' gs_main-tel_number,
               ' '  'ADDR1_DATA-EXTENSION2' lv_text,

               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=HTRA_T',    "헤더-선적

               'X'  'SAPMV50A'              '2000',
               ' '  'BDC_OKCODE'            '=BACK_T'.    "BACK

  IF gs_main-edatu IS NOT INITIAL.
    PERFORM  dynpro  USING :
               ' '  'LIKP-WADAT'            lv_datum1.
  ENDIF.

  IF gs_main-arrdt IS NOT INITIAL.
    PERFORM  dynpro  USING :
               ' '  'LIKP-LFDAT'            lv_datum2.
  ENDIF.

  PERFORM  dynpro  USING :
               ' '  'LIKP-LFUHR'            gs_main-arrtm(4),

               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=SICH_T'.    "저장

ENDFORM.                    " FILL_BDC_LAST
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_transaction USING pv_error.
  DATA: ls_main     LIKE gt_main.

  DATA: lv_flag.

** Transaction option
  CLEAR : ctu_params.
  ctu_params-dismode  =  gv_mode.
  ctu_params-updmode  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VL01N' USING         gt_bdctab
                           OPTIONS  FROM ctu_params
                           MESSAGES INTO gt_retmsg.

  CLEAR : gt_retmsg.

  READ TABLE gt_retmsg WITH KEY msgtyp = 'S'
                                msgid  = 'VL'
                                msgnr  = '311'.
  IF sy-subrc = 0.
    PERFORM message_store USING 'ZLE1' 'E' '004'
                                '출하요청번호'
                                gs_main-dlvrq
                                '의 납품문서가 생성되었습니다.'
                                gt_retmsg-msgv2.

    gt_0402-vgbel = gt_retmsg-msgv2.

    MODIFY gt_0402 TRANSPORTING vgbel
                   WHERE dlvrq IS NOT INITIAL.

    CLEAR : lv_flag.

    LOOP AT gt_main INTO ls_main WHERE keyno = gs_main-keyno
                                   AND itsel = 'X'.
      IF ls_main-trtyp = '02' AND ls_main-indlen > 0.
*___운송유형이 '02'(로베드)인 경우 해당 품목만 CM을 입력하기 위해 점검
        CHECK ls_main-posnr = gs_main-posnr.
      ENDIF.

      UPDATE zlet0401 SET edatu = ls_main-edatu
                          dlrmg = ls_main-dlrmg
                          sdcfm = 'CM'
                          aedat = sy-datlo
                          aezet = sy-timlo
                          aenam = sy-uname
                    WHERE dlvrq = ls_main-dlvrq
                      AND vbeln = ls_main-vbeln
                      AND posnr = ls_main-posnr.

      IF sy-subrc <> 0.
        lv_flag = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_flag IS INITIAL.
      MODIFY zlet0402 FROM TABLE gt_0402.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '출하요청번호'
                                    gs_main-dlvrq
                                    '의 납품정보(ZLET0402) 생성 시'
                                    '오류가 발생하였습니다.'.

        ROLLBACK WORK.
      ENDIF.
    ELSE.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '출하요청번호'
                                  gs_main-dlvrq
                                  '의 품목정보 Update 시'
                                  '오류가 발생하였습니다.'.

      ROLLBACK WORK.
    ENDIF.
  ELSE.
    pv_error = 'X'.

    PERFORM append_message.
  ENDIF.

ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  APPEND_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_message .

  PERFORM message_store USING 'ZLE1' 'E' '004'
                              '출하요청번호'
                              gs_main-dlvrq
                              '의 납품문서 생성 시'
                              '오류가 발생하였습니다.'.

  LOOP AT gt_retmsg.
    PERFORM message_store USING gt_retmsg-msgid
                                gt_retmsg-msgtyp
                                gt_retmsg-msgnr
                                gt_retmsg-msgv1
                                gt_retmsg-msgv2
                                gt_retmsg-msgv3
                                gt_retmsg-msgv4.
  ENDLOOP.

ENDFORM.                    " APPEND_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STORE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM message_store  USING    pv_msgid
                             pv_msgtyp
                             pv_msgnr
                             pv_msgv1
                             pv_msgv2
                             pv_msgv3
                             pv_msgv4.

  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      arbgb = pv_msgid
      msgty = pv_msgtyp
      msgv1 = pv_msgv1
      msgv2 = pv_msgv2
      msgv3 = pv_msgv3
      msgv4 = pv_msgv4
      txtnr = pv_msgnr.

ENDFORM.                    " MESSAGE_STORE
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_row .

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM check_delivery_doc USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM popup_to_confirm USING '삭제'
                                 '선택한 라인을 삭제하시겠습니까?'
                                 '2'
                                 gv_answer.
  IF gv_answer = '1'.
    PERFORM delete_delivery_req.

    PERFORM get_delivery_req_data.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_ROW
*&---------------------------------------------------------------------*
*&      Form  DELETE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_delivery_req .
  DATA: lv_vbeln LIKE zlet0401-vbeln,
        lv_posnr LIKE zlet0401-posnr,
        lv_flag.

  CLEAR: gt_link[].

  CLEAR : lv_flag.

  LOOP AT gt_main WHERE itsel = 'X'.
    UPDATE zlet0401 SET lvorm = 'X'
                        aedat = sy-datlo
                        aezet = sy-timlo
                        aenam = sy-uname
                  WHERE dlvrq = gt_main-dlvrq
                    AND vbeln = gt_main-vbeln
                    AND posnr = gt_main-posnr.

    IF sy-subrc = 0.
*___해당 출하요청번호에 삭제되지 않은 품목 존재여부 점검
      CLEAR : lv_vbeln, lv_posnr.

      SELECT SINGLE vbeln
                    posnr
        INTO (lv_vbeln, lv_posnr)
        FROM zlet0401
       WHERE dlvrq = gt_main-dlvrq
         AND lvorm = ' '.

      IF sy-subrc <> 0.
        UPDATE zlet0400 SET lvorm = 'X'
                      WHERE dlvrq = gt_main-dlvrq.

        IF sy-subrc <> 0.
          lv_flag = 'X'.

          EXIT.
        ENDIF.

*->>----[LINK INFO 구성]-S
        CLEAR:gs_link.
        MOVE-CORRESPONDING gt_main TO gs_link.
        gs_link-updkz = gc_d.
        APPEND gs_link TO gt_link.
*-<<----[LINK INFO 구성]-E
      ENDIF.
    ELSE.
      lv_flag = 'X'.

      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_flag IS INITIAL.
    COMMIT WORK.

*-  LAN CABLE : PP FM'ZGTPP_LINK_INFO_UPDATE' 호출
    PERFORM call_pp_link_info_chg USING gc_d.

    MESSAGE s004 WITH '선택한 라인이 삭제되었습니다.'.
  ELSE.
    ROLLBACK WORK.

    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '출하요청' gt_main-dlvrq
            '삭제 시 오류가 발생하였습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_screen_0300 .

  CLEAR   : gt_0402.
  REFRESH : gt_0402.

  LOOP AT gt_main WHERE mark = 'X'.
    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE gt_0402
      FROM lips AS a
     INNER JOIN zlet0402 AS b
        ON a~vbeln = b~vgbel
       AND a~posnr = b~vgpos
     WHERE b~dlvrq = gt_main-dlvrq
       AND b~vbeln = gt_main-vbeln
       AND b~posnr = gt_main-posnr.
  ENDLOOP.

  IF sy-subrc <> 0.
    MESSAGE s100 DISPLAY LIKE 'E'.
  ENDIF.

  IF gt_0402[] IS NOT INITIAL.
    LOOP AT gt_0402.
      CLEAR : gt_0402-lfimg.

      SELECT SUM( lfimg )
        INTO gt_0402-lfimg
        FROM lips
       WHERE vbeln = gt_0402-vgbel
         AND ( posnr = gt_0402-vgpos
            OR uecha = gt_0402-vgpos ).

      MODIFY gt_0402.
    ENDLOOP.

    CALL SCREEN 0300 STARTING AT 20 2.
  ELSE.
    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '생성된 납품문서가 없습니다.'.
  ENDIF.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_grid_fcat_1 .

  CLEAR   : gs_fieldcat, gv_pos.
  REFRESH : gt_fieldcat1.

  gv_itab = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM make_lvc_fieldcat_data TABLES gt_fieldcat1
                                  USING :
      'DLVRQ'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 12
      ' '            'DLVRQ'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'VBELN'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      ' '            'POSNR'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'VGBEL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'VGBEL'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'VGPOS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 6
      ' '            'VGPOS'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'LFIMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'LFIMG'  'LIPS'      ' ' ' '    ' ' ' ' ' ' ' ',

      'VRKME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'VRKME'  'LIPS'      ' ' ' '    'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FCAT_1
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM event_handler_register_1 .

  CALL METHOD gc_alv_grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*___Event Handler 등록
  CREATE OBJECT gc_event_handler1.

  SET HANDLER gc_event_handler1->handle_double_click1 FOR gc_alv_grid1.

ENDFORM.                    " EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_table_for_first_display_1 .

  gs_variant-handle = '0004'.
  gs_variant-report = sy-repid.

  CALL METHOD gc_alv_grid1->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      is_layout            = gs_layout
      i_save               = 'A'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_fieldcatalog      = gt_fieldcat1[]
      it_sort              = gt_sort[]
      it_outtab            = gt_0402[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_1
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM double_click  USING  e_flag
                          e_row
                          e_column.

  CASE e_flag.
    WHEN '1'.
      READ TABLE gt_main INDEX e_row.
      IF sy-subrc  = 0.
        CASE e_column.
          WHEN 'VBELN'.
            IF gt_main-vbeln IS NOT INITIAL.
              SET PARAMETER ID 'AUN' FIELD gt_main-vbeln.
              SET PARAMETER ID 'VPO' FIELD gt_main-posnr.

              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
            ENDIF.

          WHEN 'VGBEL'.
            IF gt_main-vgbel IS NOT INITIAL.
              SET PARAMETER ID 'VL ' FIELD gt_main-vgbel.
              SET PARAMETER ID 'VLP' FIELD gt_main-vgpos.

              CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
            ENDIF.

          WHEN 'LABST' OR 'INSME'.
            IF gt_main-labst IS NOT INITIAL OR
               gt_main-insme IS NOT INITIAL.
              PERFORM submit_zler0011.
            ENDIF.

          WHEN  OTHERS.

        ENDCASE.
      ENDIF.

    WHEN '2'.
      READ TABLE gt_0402 INDEX e_row.
      IF sy-subrc  = 0.
        CASE e_column.
          WHEN 'VBELN'.
            IF gt_0402-vbeln IS NOT INITIAL.
              SET PARAMETER ID 'AUN' FIELD gt_0402-vbeln.
              SET PARAMETER ID 'VPO' FIELD gt_0402-posnr.

              CALL TRANSACTION 'VA03'  AND SKIP FIRST SCREEN.
            ENDIF.

          WHEN 'VGBEL'.
            IF gt_0402-vgbel IS NOT INITIAL.
              SET PARAMETER ID 'VL ' FIELD gt_0402-vgbel.
              SET PARAMETER ID 'VPL' FIELD gt_0402-vgpos.

              CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
            ENDIF.

          WHEN  OTHERS.

        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  SAVE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_delivery_req .

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

*->>[가온전선]------------------------------------------------------S
* 여신점검
  PERFORM check_credit_chg USING gv_error.

  IF gv_error IS NOT INITIAL.
    PERFORM refresh_alv USING gc_alv_grid.
    EXIT.
  ENDIF.
*-<<[가온전선]------------------------------------------------------E

  PERFORM popup_to_confirm USING '저장'
                                 '선택한 라인을 저장하시겠습니까?'
                                 '1'
                                 gv_answer.
  IF gv_answer = '1'.
    PERFORM save_zlet0401_data.

    PERFORM get_delivery_req_data.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_DELIVERY_REQ
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZLET0401_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_zlet0401_data .
  DATA: ls_0406     LIKE zlet0406.

  DATA: lv_dlvrq LIKE zlet0400-dlvrq,
        lv_lecfm LIKE zlet0401-lecfm,
        lv_flag.
  CLEAR : gt_link[].
  CLEAR : lv_flag.

  SORT gt_main BY dlvrq.

  CLEAR : lv_dlvrq.

  LOOP AT gt_main WHERE itsel = 'X'.
    IF lv_dlvrq <> gt_main-dlvrq.
      lv_dlvrq = gt_main-dlvrq.

*___헤더정보 변경
      UPDATE zlet0400 SET post_code1 = gt_main-post_code1 "우편번호
                          land1      = gt_main-land1      "국가
                          lzone      = gt_main-lzone      "운송 지역
                          city1      = gt_main-city1      "상세 주소
                          extension1 = gt_main-extension1 "수령인
                          tel_number = gt_main-tel_number "연락처
                          arrdt      = gt_main-arrdt      "도착일
                          arrtm      = gt_main-arrtm      "도착일시
                          immdt      = gt_main-immdt      "긴급출하
                          alone      = gt_main-alone      "단독여부
                          vhctp      = gt_main-vhctp      "차량제한여부
                          bknft      = gt_main-bknft      "왕복여부
                          divid      = gt_main-divid      "분할출하
                          zreq_type  = gt_main-zreq_type  "직송의뢰 신청 유형
                          trtyp      = gt_main-trtyp      "운송유형
                          remark     = gt_main-remark     "비고
                          zremark1   = gt_main-zremark1   "출하실 요청사항
                    WHERE dlvrq = gt_main-dlvrq.

      IF sy-subrc <> 0.
        lv_flag = 'X'.

        EXIT.
      ENDIF.

*___선적 추가정보
      READ TABLE gt_0406 WITH KEY dlvrq = gt_main-dlvrq.
      IF sy-subrc = 0.
        CLEAR : ls_0406.

        MOVE-CORRESPONDING gt_0406 TO ls_0406.

        MODIFY zlet0406 FROM ls_0406.
        IF sy-subrc <> 0.
          lv_flag = 'X'.

          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

*___출하요청 변경 수량이 출하확정(납품생성) 수량과 동일하면
*   출하확정을 완료(CM)로 변경
    IF gt_main-dlrmg = gt_main-lfimg_m.
      lv_lecfm = 'CM'.
    ELSE.
      IF gt_main-lfimg_m IS NOT INITIAL.
        lv_lecfm = 'CP'.
      ELSE.
        CLEAR : lv_lecfm.
      ENDIF.
    ENDIF.

    UPDATE zlet0401 SET edatu = gt_main-edatu
                        dlrmg = gt_main-dlrmg
                        lecfm = lv_lecfm
                        aedat = sy-datlo
                        aezet = sy-timlo
                        aenam = sy-uname
                  WHERE dlvrq = gt_main-dlvrq
                    AND vbeln = gt_main-vbeln
                    AND posnr = gt_main-posnr.

    IF sy-subrc <> 0.
      lv_flag = 'X'.

      EXIT.
    ENDIF.
*->>[LINK INFO 구성]-S
    CLEAR:gs_link.
    MOVE-CORRESPONDING gt_main TO gs_link.
    gs_link-updkz = gc_u.
    APPEND gs_link TO gt_link.
*-<<[LINK INFO 구성]-E
  ENDLOOP.

  IF lv_flag IS INITIAL.
    COMMIT WORK.

*-  LAN CABLE : PP FM'ZGTPP_LINK_INFO_UPDATE' 호출
    PERFORM call_pp_link_info_chg USING gc_u.

    MESSAGE s004 WITH '저장되었습니다.'.
  ELSE.
    ROLLBACK WORK.

    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '저장 시 오류가 발생하였습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_ZLET0401_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_REMARK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_remark_data  USING    pv_vstel
                               pv_kunwe
                               pv_remark.

  CLEAR : pv_remark.

  SELECT SINGLE remark
    INTO pv_remark
    FROM zlet0405
   WHERE vstel = pv_vstel
     AND kunwe = pv_kunwe.

ENDFORM.                    " GET_REMARK_DATA
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM download_data .

  IF gv_trtyp = 'A'.
    gt_main-itsel = 'X'.
    MODIFY gt_main TRANSPORTING itsel
                   WHERE dlvrq IS NOT INITIAL.
  ENDIF.

  PERFORM check_selected_rows USING gv_error.

  CHECK gv_error IS INITIAL.

  PERFORM download_excel.

  IF gv_trtyp = 'A'.
    CLEAR : gt_main-itsel.
    MODIFY gt_main TRANSPORTING itsel
                   WHERE dlvrq IS NOT INITIAL.
  ENDIF.

ENDFORM.                    " DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_excel .
  DATA: BEGIN OF lt_file OCCURS 0,
          text TYPE string,
        END   OF lt_file.

  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string,
        lv_action   TYPE i.

  DATA: tabulator_hex(2) TYPE x VALUE 9,
        tabulator        TYPE c.

  DATA: lv_kwmeng(20),
        lv_dlrmg(20),
        lv_lfimg(20),
        lv_labst(20),
        lv_insme(20),
        lv_ramng(20),
        lv_indlen(20),
        lv_indqty(20),
        lv_sacpt.

  CALL METHOD cl_abap_conv_in_ce=>uccp
    EXPORTING
      uccp = tabulator_hex
    RECEIVING
      char = tabulator.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    CHANGING
      filename    = lv_filename
      path        = lv_path
      fullpath    = lv_fullpath
      user_action = lv_action.

  IF lv_action = 9.
    MESSAGE s001 WITH '취소되었습니다.'.
    EXIT.
  ENDIF.

  CLEAR   : lt_file.
  REFRESH : lt_file.

  IF NOT lv_filename IS INITIAL.
    SEARCH lv_filename FOR '.xls'.
    IF sy-subrc <> 0.
      SEARCH lv_filename FOR '.XLS'.
      IF sy-subrc <> 0.
        CONCATENATE lv_filename '.xls' INTO lv_filename.
      ENDIF.
    ENDIF.

    IF gv_trtyp = 'A'.
*___헤더 정보
      CONCATENATE '출하요청번호'
                  '판매문서'
                  '품목'
                  '자재'
                  '자재내역'
                  '단위'
                  '조장'
                  '납품문서번호'
                  '항목'
                  '납품문서수량'
                  '출하요청일'
                  '우편번호'
                  '지역'
                  '상세주소'
                  '수령인'
                  '연락처'
                  '도착일'
                  '도착시간'
                  '납품처명'
                  '판매처명'
                  '선적접수'
             INTO lt_file-text SEPARATED BY tabulator.

    ELSE.
*___헤더 정보
      CONCATENATE '판매문서'
                  '품목'
                  '판매처'
                  '판매처명'
                  '납품처'
                  '납품처명'
                  '자재'
                  '자재내역'
                  '오더수량'
                  '단위'
                  '조장'
                  '조장수'
                  '가용성점검'
                  '여신상태'
                  '거부사유'
                  '가용재고'
                  '품질재고'
                  '요청가능'
                  '출하요청일'
                  '출하요청'
                  '비고'
                  '우편번호'
                  '국가'
                  '지역'
                  '상세주소'
                  '수령인'
                  '연락처'
                  '도착일'
                  '도착시간'
                  '긴급출하'
                  '단독여부'
                  '왕복여부'
                  '차량제한'
                  '차량제한명'
                  '분할출하'
                  '운송유형'
             INTO lt_file-text SEPARATED BY tabulator.
    ENDIF.

    APPEND lt_file.

    LOOP AT gt_main WHERE itsel = 'X'.
      CLEAR : lt_file.

      WRITE: gt_main-kwmeng TO lv_kwmeng UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-dlrmg  TO lv_dlrmg  UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-lfimg_d TO lv_lfimg UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-labst  TO lv_labst  UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-insme  TO lv_insme  UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-ramng  TO lv_ramng  UNIT gt_main-vrkme
                                         LEFT-JUSTIFIED NO-GROUPING,
             gt_main-indlen TO lv_indlen LEFT-JUSTIFIED NO-GROUPING,
             gt_main-indqty TO lv_indqty LEFT-JUSTIFIED NO-GROUPING.

      IF gt_main-sacpt = '@5B@'.
        lv_sacpt = 'Y'.
      ELSEIF gt_main-sacpt = '@5C@'.
        lv_sacpt = 'N'.
      ELSE.
        CLEAR : lv_sacpt.
      ENDIF.

      IF gv_trtyp = 'A'.
        CONCATENATE gt_main-dlvrq          "출하요청번호
                    gt_main-vbeln          "판매오더
                    gt_main-posnr          "품목
                    gt_main-matnr          "자재
                    gt_main-maktx          "자재내역
                    gt_main-vrkme          "판매단위
                    lv_indlen              "조장
                    gt_main-vgbel          "납품문서
                    gt_main-vgpos          "납품품목
                    lv_lfimg               "납품수량
                    gt_main-edatu          "출하요청일
                    gt_main-post_code1     "우편번호
                    gt_main-lzone          "운송지역
                    gt_main-city1          "상세주소
                    gt_main-extension1     "수령인
                    gt_main-tel_number     "연락처
                    gt_main-arrdt          "도착일
                    gt_main-arrtm          "도착시간
                    gt_main-namwe          "납품처명
                    gt_main-namag          "판매처명
                    lv_sacpt               "선적접수
               INTO lt_file-text SEPARATED BY tabulator.
      ELSE.
        CONCATENATE gt_main-vbeln          "판매오더
                    gt_main-posnr          "품목
                    gt_main-kunag          "판매처
                    gt_main-namag          "판매처명
                    gt_main-kunwe          "납품처
                    gt_main-namwe          "납품처명
                    gt_main-matnr          "자재
                    gt_main-maktx          "자재내역
                    lv_kwmeng              "오더수량
                    gt_main-vrkme          "단위
                    lv_indlen              "조장
                    lv_indqty              "조장수
                    gt_main-avlbt          "가용성점검
                    gt_main-cmgst          "여신상태
                    gt_main-abgru          "거부사유
                    lv_labst               "가용재고
                    lv_insme               "품질재고
                    lv_ramng               "요청가능
                    gt_main-edatu          "출하요청일
                    lv_dlrmg               "출하요청
                    gt_main-remark         "비고
                    gt_main-post_code1     "우편번호
                    gt_main-land1          "국가
                    gt_main-lzone          "지역
                    gt_main-city1          "상세주소
                    gt_main-extension1     "수령인
                    gt_main-tel_number     "연락처
                    gt_main-arrdt          "도착일
                    gt_main-arrtm          "도착시간
                    gt_main-immdt          "긴급출하
                    gt_main-alone          "단독여부
                    gt_main-bknft          "왕복여부
                    gt_main-vhctp          "차량제한
                    gt_main-vhctx          "차량제한명
                    gt_main-divid          "분할출하
                    gt_main-trtyp          "운송유형
               INTO lt_file-text SEPARATED BY tabulator.
      ENDIF.

      APPEND lt_file.
    ENDLOOP.

*___BOM : codepage '4102', '4103', '4110'(unicode)인 경우
*   파일 첫머리에 구분자 추가
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_filename
        filetype                = 'ASC'   "'DAT' 도 가능
        codepage                = '4103'
        write_bom               = 'X'     "BOM = Byte Ordre Mark
      TABLES
        data_tab                = lt_file
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

ENDFORM.                    " DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*&      Form  EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM excel_upload .
  TYPES : truxs_t_text_data(4096) TYPE c OCCURS 0.

  DATA: lv_act  TYPE i,
        lv_rc   TYPE i,
        lv_file LIKE rlgrap-filename.

  DATA : lv_data TYPE truxs_t_text_data,
         lt_file TYPE file_table OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF ls_order,
          vkorg LIKE vbak-vkorg,
          auart LIKE vbak-auart,
          vstel LIKE vbap-vstel,
          abgru LIKE vbap-abgru,
          gbsta LIKE vbup-gbsta,
        END   OF ls_order.

  DATA: lv_tabix    LIKE sy-tabix.

*___Upload File명
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table  = lt_file[]
      rc          = lv_rc
      user_action = lv_act.

  IF lv_act = 9.
    MESSAGE s004 WITH '취소되었습니다'.
    EXIT.
  ENDIF.

  READ TABLE lt_file INDEX 1.
  lv_file = lt_file-filename.

*___File Upload
  CLEAR   : gt_upld, gv_msg.
  REFRESH : gt_upld.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = 'X'
      i_tab_raw_data       = lv_data
      i_filename           = lv_file
    TABLES
      i_tab_converted_data = gt_upld
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF gt_upld[] IS INITIAL.
    MESSAGE s004 DISPLAY LIKE 'E'
       WITH 'Upload Data가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT gt_upld.
    PERFORM conversion_exit_alpha USING: 'I' gt_upld-posnr,
                                         'I' gt_upld-kunag,
                                         'I' gt_upld-kunwe,
                                         'I' gt_upld-trtyp.

    PERFORM conversion_exit_matn1 USING: 'I' gt_upld-matnr.

    PERFORM replace_all USING: 'D' gt_upld-edatu,
                               'D' gt_upld-arrdt,
                               'T' gt_upld-arrtm,
                               'Q' gt_upld-dlrmg.

    MODIFY gt_upld.
  ENDLOOP.

  SORT gt_upld BY vbeln posnr.

  CLEAR   : gt_main.
  REFRESH : gt_main.

*-> S4HANA 영업사원변경 : 2023.07.19
*  SELECT b~vbeln            "판매오더
*         b~posnr            "판매오더품목
*         a~auart            "영업문서유형
*         a~vkorg            "영업조직
*         a~vkbur            "영업팀
*         a~vkgrp            "영업그룹
*         g~pernr            "영업사원
*         a~kunnr AS kunag   "판매처
*         d~kdkg4            "내수/수출
*         b~sobkz            "특별재고지시자
*         b~matnr            "자재
*         b~kwmeng           "오더수량
*         b~vrkme            "판매단위
*         b~vstel            "출하지점
*         b~werks            "플랜트
*         b~spart            "제품군
*         e~edatu            "납품일정
*         b~abgru            "거절사유
*    INTO CORRESPONDING FIELDS OF TABLE gt_main
*    FROM vbak AS a
*   INNER JOIN vbap AS b
*      ON a~vbeln = b~vbeln
*   INNER JOIN vbkd AS d
*      ON a~vbeln = d~vbeln
*     AND d~posnr = '000000'
*   INNER JOIN vbep AS e
*      ON b~vbeln = e~vbeln
*     AND b~posnr = e~posnr
*     AND e~etenr = '0001'
*   INNER JOIN vbpa AS g
*      ON a~vbeln = g~vbeln
*     AND g~posnr = '000000'
*     AND g~parvw = 'VE'      "영업사원(PE)
**   INNER JOIN VBUP AS H
**      ON B~VBELN = H~VBELN
**     AND B~POSNR = H~POSNR
*     FOR ALL ENTRIES IN gt_upld
*   WHERE a~vkorg =  gc_vkorg
*     AND a~vbeln =  gt_upld-vbeln
*     AND a~auart IN gr_auart
*     AND b~vstel IN s_vstel
*     AND b~abgru NOT BETWEEN '01' AND '11'
*     AND b~gbsta <> 'C'.
  SELECT b~vbeln,            "판매오더
         b~posnr,            "판매오더품목
         a~auart,            "영업문서유형
         a~vkorg,            "영업조직
         a~vkbur,            "영업팀
         a~vkgrp,            "영업그룹
         g~lifnr,            "영업사원
         a~kunnr AS kunag,   "판매처
         d~kdkg4,            "내수/수출
         b~sobkz,            "특별재고지시자
         b~matnr,            "자재
         b~kwmeng,           "오더수량
         b~vrkme,            "판매단위
         b~vstel,            "출하지점
         b~werks,            "플랜트
         b~spart,            "제품군
         e~edatu,            "납품일정
         b~abgru,            "거절사유
*->>[가온전선]-----------------------------------------S
         a~kkber,
         h~assigned_bp AS kunrg,
         b~waerk,
         b~netwr,
         b~mwsbp
*-<<[가온전선]-----------------------------------------E
    FROM vbak AS a
   INNER JOIN vbap AS b
      ON a~vbeln = b~vbeln
   INNER JOIN vbkd AS d
      ON a~vbeln = d~vbeln
     AND d~posnr = '000000'
   INNER JOIN vbep AS e
      ON b~vbeln = e~vbeln
     AND b~posnr = e~posnr
     AND e~etenr = '0001'
   INNER JOIN vbpa AS g
      ON a~vbeln = g~vbeln
     AND g~posnr = '000000'
     AND g~parvw = 'VE'      "영업사원(PE)
   INNER JOIN vbpa AS h
      ON a~vbeln = h~vbeln
     AND h~posnr = '000000'
     AND h~parvw = 'RG'      "지급처
     FOR ALL ENTRIES IN @gt_upld
   WHERE a~vkorg =  @gc_vkorg
     AND a~vbeln =  @gt_upld-vbeln
     AND a~auart IN @gr_auart
     AND b~vstel IN @s_vstel
     AND b~abgru NOT BETWEEN '01' AND '11'
     AND b~gbsta <> 'C'
    INTO TABLE @DATA(lt_main).

  LOOP AT lt_main ASSIGNING FIELD-SYMBOL(<ls_main>).
    REPLACE FIRST OCCURRENCE OF 'E' IN <ls_main>-lifnr WITH space.
    CLEAR gt_main.
    MOVE-CORRESPONDING <ls_main> TO gt_main.
    gt_main-pernr = <ls_main>-lifnr.
    APPEND gt_main.
  ENDLOOP.
*<-
*___Upload된 판매오더 품목이 아니면 제외
  LOOP AT gt_main.
    READ TABLE gt_upld WITH KEY vbeln = gt_main-vbeln
                                posnr = gt_main-posnr.
    IF sy-subrc <> 0.
      DELETE gt_main.
      CONTINUE.
    ENDIF.
  ENDLOOP.

*___판매오더 기타 정보
  PERFORM get_order_data_etc.

*___Upload 파일의 판매오더 품목이 대상에서 제외된 경우 메시지 팝업
  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  CLEAR   : gt_vbap.
  REFRESH : gt_vbap.

  SORT gt_upld BY vbeln posnr.

*___동일 판매오더/품목을 여러 라인으로 Upload한 경우 수량 집계
  LOOP AT gt_upld.
    CLEAR : gt_vbap.

    gt_vbap-vbeln = gt_upld-vbeln.
    gt_vbap-posnr = gt_upld-posnr.
    gt_vbap-dlrmg = gt_upld-dlrmg.

    COLLECT gt_vbap.
  ENDLOOP.

  LOOP AT gt_vbap.
    CONCATENATE gt_vbap-vbeln '-' gt_vbap-posnr
           INTO gv_text.

    READ TABLE gt_main WITH KEY vbeln = gt_vbap-vbeln
                                posnr = gt_vbap-posnr.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.

      READ TABLE gt_upld WITH KEY vbeln = gt_vbap-vbeln
                                  posnr = gt_vbap-posnr
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        PERFORM check_upload_data USING gv_error.

        IF gv_error IS NOT INITIAL.
          gv_msg = 'X'.
        ELSE.
*          READ TABLE GT_MAIN INTO GS_MAIN WITH KEY ITSEL = 'X'.
*          IF SY-SUBRC <> 0 OR GS_MAIN-VBELN = GT_MAIN-VBELN.
**___다른 판매오더가 동시에 선택되지 않도록
*            GT_MAIN-ITSEL = 'X'.
*          ENDIF.

          MOVE-CORRESPONDING gt_upld TO gt_main.

          gt_main-itsel = 'X'.
          gt_main-dlrmg = gt_vbap-dlrmg.

          IF gt_upld-arrdt IS NOT INITIAL.
            gt_main-arind = 'X'.
          ELSE.
            CLEAR : gt_main-arind.
          ENDIF.

          IF gt_main-indlen IS NOT INITIAL.
            gt_main-drind = gt_main-dlrmg / gt_main-indlen.
          ENDIF.

          MOVE-CORRESPONDING gt_main TO gt_main-keyno.

          MODIFY gt_main INDEX lv_tabix.
        ENDIF.
      ELSE.
        gv_msg = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    gv_text
                                    '의 Upload 정보를 찾지 못했습니다.'
                                    ' '.
      ENDIF.
    ELSE.
      gv_msg = 'X'.

*___영업조직/오더유형/출하지점/거절사유/전체처리상태
      CLEAR : ls_order.

      SELECT SINGLE a~vkorg
                    a~auart
                    b~vstel
                    b~abgru
                    b~gbsta
        INTO ls_order
        FROM vbak AS a
       INNER JOIN vbap AS b
          ON a~vbeln = b~vbeln
*       INNER JOIN VBUP AS C
*          ON B~VBELN = C~VBELN
*         AND B~POSNR = C~POSNR
       WHERE b~vbeln = gt_vbap-vbeln
         AND b~posnr = gt_vbap-posnr.

      IF sy-subrc = 0.
        IF ls_order-vkorg <> gc_vkorg.
          PERFORM message_store USING 'ZLE1' 'E' '004'
                                      '판매오더-품목'
                                      gv_text
                                      '의 영업조직을 점검하십시오.'
                                      ls_order-vkorg.
        ENDIF.

        IF ls_order-auart NOT IN gr_auart.
          PERFORM message_store USING 'ZLE1' 'E' '004'
                                      '판매오더-품목'
                                      gv_text
                                      '의 오더유형을 점검하십시오.'
                                      ls_order-auart.
        ENDIF.

        IF ls_order-vstel NOT IN s_vstel.
          PERFORM message_store USING 'ZLE1' 'E' '004'
                                      '판매오더-품목'
                                      gv_text
                                      '의 출하지점을 점검하십시오.'
                                      ls_order-vstel.
        ENDIF.

        IF ls_order-abgru BETWEEN '01' AND '11'.
          PERFORM message_store USING 'ZLE1' 'E' '004'
                                      '판매오더-품목'
                                      gv_text
                                      '의 거절사유를 점검하십시오.'
                                      ls_order-abgru.
        ENDIF.

        IF ls_order-gbsta = 'C'.
          PERFORM message_store USING 'ZLE1' 'E' '004'
                                      '판매오더-품목'
                                      gv_text
                                      '의 전체처리상태를 점검하십시오.'
                                      ls_order-gbsta.
        ENDIF.
      ELSE.
        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    gv_text
                                    '이(가) 존재하지 않습니다.'
                                    ' '.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_main[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    IF gv_msg IS NOT INITIAL.
      CALL FUNCTION 'MESSAGES_SHOW'
        EXPORTING
          show_linno = space.
    ENDIF.
  ENDIF.

ENDFORM.                    " EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM conversion_exit_alpha  USING pv_flag
                                  pv_value.

  IF pv_flag = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = pv_value
      IMPORTING
        output = pv_value.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = pv_value
      IMPORTING
        output = pv_value.
  ENDIF.

ENDFORM.                    " CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_MATN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM conversion_exit_matn1  USING pv_flag
                                  pv_value.

  IF pv_flag = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = pv_value
      IMPORTING
        output       = pv_value
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = pv_value
      IMPORTING
        output = pv_value.
  ENDIF.

ENDFORM.                    " CONVERSION_EXIT_MATN1
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_JOBNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_order_jobno  USING   pv_vbeln
                              pv_posnr
                              pv_jobno.

  CLEAR : pv_jobno.

*___판매오더 특성 - 제조지시번호
  PERFORM get_so_characteristic USING pv_vbeln
                                      pv_posnr
                                      gc_jobno
                                      pv_jobno.

  CHECK pv_jobno IS INITIAL.

*___판매오더 특성에 제조지시번호가 없는 경우
*2025/02/21 bstkd_e 필드 대체
*> 시작
  SELECT SINGLE bstnk INTO pv_jobno
    FROM vbak
   WHERE vbeln = pv_vbeln.
  IF sy-subrc NE 0.
    SELECT SINGLE bstkd INTO pv_jobno
      FROM vbkd
     WHERE vbeln = pv_vbeln
       AND posnr = space.
  ENDIF.
*< 끝
**********************************************************************
*기존 로직 주석 처리
**********************************************************************
*  SELECT SINGLE bstkd_e
*    INTO pv_jobno
*    FROM vbkd
*   WHERE vbeln = pv_vbeln
*     AND posnr = pv_posnr.
*
*  IF sy-subrc <> 0.
*    SELECT SINGLE bstkd_e
*      INTO pv_jobno
*      FROM vbkd
*     WHERE vbeln = pv_vbeln
*       AND posnr = '000000'.
*  ENDIF.
**********************************************************************

ENDFORM.                    " GET_ORDER_JOBNO
*&---------------------------------------------------------------------*
*&      Form  SET_SHIPMENT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_shipment_info .

  IF gt_main-dlvrq IS NOT INITIAL.
    READ TABLE gt_0406 WITH KEY dlvrq = gt_main-dlvrq.
  ELSE.
    READ TABLE gt_0406 WITH KEY vbeln = gt_main-vbeln
                                posnr = gt_main-posnr.
  ENDIF.

  IF sy-subrc <> 0.
    gt_0406-dlvrq = gt_main-dlvrq.

*___인도조건
    SELECT SINGLE inco1
                  inco2
      INTO (gt_0406-inco1, gt_0406-inco2)
      FROM vbkd
     WHERE vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr.

    IF sy-subrc <> 0.
      SELECT SINGLE inco1
                    inco2
        INTO (gt_0406-inco1, gt_0406-inco2)
        FROM vbkd
       WHERE vbeln = gt_main-vbeln
         AND posnr = '000000'.
    ENDIF.

    gt_0406-srdat	= sy-datlo.        "선적요청일
    gt_0406-paymt = 'L/C'.           "결제방법
    gt_0406-addrs	= gt_main-city1.   "도착지
  ENDIF.

*___에이전트/대체수취인 명
  PERFORM get_kunnr_desc USING: gt_0406-agent1
                                gv_agnnm1,

                                gt_0406-agent2
                                gv_agnnm2,

                                gt_0406-abwze
                                gv_abwnm.

ENDFORM.                    " SET_SHIPMENT_INFO
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELIVERT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_delivert_info  USING    pv_error.

  CLEAR : pv_error, gv_cursor1, gv_cursor2.

  IF gs_delv-lzone IS INITIAL.
    pv_error   = 'X'.
    gv_cursor1 = 'GS_DELV-LZONE'.

    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '운송지역을 입력하십시오.'.

    EXIT.
  ENDIF.

  IF gs_delv-arind = 'X' AND gs_delv-arrdt IS INITIAL.
    pv_error   = 'X'.
    gv_cursor1 = 'GS_DELV-ARRDT'.

    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '도착일/시간을 입력하십시오.'.

    EXIT.
  ENDIF.

  CHECK gt_main-trade = 'E'.

*->[가온전선]--------------------CHG S
**___인도조건1이 'D'로 시작하는 경우 도착지
*  IF GT_0406-INCO1(1) = 'D' AND GT_0406-ADDRS IS INITIAL.
*    PV_ERROR   = 'X'.
*    GV_CURSOR2 = 'GT_0406-ADDRS'.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '도착지를 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___결제방법이 'L/C'인 경우 L/C 번호 입력
*  IF GT_0406-PAYMT = 'L/C' AND GT_0406-ZLCNO IS INITIAL.
*    PV_ERROR   = 'X'.
*    GV_CURSOR2 = 'GT_0406-ZLCNO'.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH 'L/C 번호를 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___운송유형1이 'O'(Ocean)인 경우 운송유형2 입력여부
*  IF GT_0406-TRTYP1 = 'O' AND GT_0406-TRTYP2 IS INITIAL.
*    PV_ERROR   = 'X'.
*    GV_CURSOR2 = 'GT_0406-TRTYP2'.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '운송유형2를 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___컨테이너 시뮬레이션
*  IF GT_0406-CNTSM = 'X' AND
*   ( GT_0406-CONTY IS INITIAL OR GT_0406-CONSZ IS INITIAL ).
*    PV_ERROR   = 'X'.
*
*    IF GT_0406-CONTY IS INITIAL.
*      GV_CURSOR2 = 'GT_0406-CONTY'.
*    ELSE.
*      GV_CURSOR2 = 'GT_0406-CONSZ'.
*    ENDIF.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '컨테이너 Type과 규격을 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___리텐션
*  IF GT_0406-RETNT = 'X' AND
*   ( GT_0406-RTRAT1 IS INITIAL OR GT_0406-RTTRM1 IS INITIAL ).
*    PV_ERROR   = 'X'.
*
*    IF GT_0406-RTRAT1 IS INITIAL.
*      GV_CURSOR2 = 'GT_0406-RTRAT1'.
*    ELSE.
*      GV_CURSOR2 = 'GT_0406-RTTRM1'.
*    ENDIF.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '리텐션 요율과 기간을 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___커미션
*  IF GT_0406-COMMS = 'X' AND GT_0406-AGENT1 IS INITIAL.
*    PV_ERROR   = 'X'.
*
*    GV_CURSOR2 = 'GT_0406-AGENT1'.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '에이전트를 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*
**___입회검사
*  IF GT_0406-INSPC = 'X' AND GT_0406-INSCD IS INITIAL.
*    PV_ERROR   = 'X'.
*    GV_CURSOR2 = 'GT_0406-INSCD'.
*
*    MESSAGE S004 DISPLAY LIKE 'E'
*       WITH '입회검사 예정일을 입력하십시오.'.
*
*    EXIT.
*  ENDIF.
*-<[가온전선]--------------------CHG E
ENDFORM.                    " CHECK_DELIVERT_INFO
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DELIVERY_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_delivery_info .
  DATA: lv_cnt      TYPE i.

  CLEAR : lv_cnt.

  LOOP AT gt_main WHERE mark = 'X'.
    lv_cnt = lv_cnt + 1.
  ENDLOOP.

  IF lv_cnt > 1.
    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하고 실행하십시오.'.
    EXIT.
  ELSEIF lv_cnt < 1.
    MESSAGE s004 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR : gs_delv, gv_edatu.

  MOVE-CORRESPONDING gt_main TO gs_delv.

  gv_edatu = gt_main-edatu.

  IF gt_main-trade = 'E'.
    READ TABLE gt_0406 WITH KEY dlvrq = gt_main-dlvrq.
    IF sy-subrc = 0.
      IF gt_0406-sacpt = 'X'.
        gv_icon = '@5B@'.    "ICON_LED_GREEN
      ELSE.
        gv_icon = '@5C@'.    "ICON_LED_RED
      ENDIF.
    ENDIF.

    gv_subscr = '0201'.
  ELSE.
    gv_subscr = '0202'.
  ENDIF.

  CLEAR : gv_cursor2.
  gv_cursor1 = 'GS_DELV-POST_CODE1'.

  gv_disp = 'X'.

  CALL SCREEN 0200 STARTING AT 20 2.

  CLEAR : gv_disp.

ENDFORM.                    " DISPLAY_DELIVERY_INFO
*&---------------------------------------------------------------------*
*&      Form  SHIPMENT_ACCEPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM shipment_accept  USING pv_sacpt.
  DATA: lv_text1(20),
        lv_text2(100).

  IF pv_sacpt = 'X'.
    lv_text1 = '선적접수'.
  ELSE.
    lv_text1 = '선적접수 취소'.
  ENDIF.

  CONCATENATE lv_text1 '하시겠습니까?'
         INTO lv_text2 SEPARATED BY space.

  PERFORM popup_to_confirm USING '확인'
                                 lv_text2
                                 '1'
                                 gv_answer.
  IF gv_answer = '1'.
    UPDATE zlet0406 SET sacpt = pv_sacpt
                  WHERE dlvrq = gt_0406-dlvrq.
    IF sy-subrc = 0.
      READ TABLE gt_0406 TRANSPORTING NO FIELDS
                             WITH KEY dlvrq = gt_0406-dlvrq.
      IF sy-subrc = 0.
        gt_0406-sacpt = pv_sacpt.
        IF gt_0406-sacpt IS INITIAL.
          gv_icon = '@5C@'.     "ICON_LED_RED
        ELSE.
          gv_icon = '@5B@'.     "ICON_LED_GREEN
        ENDIF.

        MODIFY gt_0406 INDEX sy-tabix
                       TRANSPORTING sacpt.
        IF sy-subrc = 0.
          gt_main-sacpt = gv_icon.
          MODIFY gt_main TRANSPORTING sacpt
                         WHERE dlvrq = gt_0406-dlvrq.
          IF sy-subrc = 0.
            COMMIT WORK.

            MESSAGE s004 WITH lv_text1 '하였습니다.'.
          ELSE.
            ROLLBACK WORK.

            MESSAGE s004 DISPLAY LIKE 'E'
               WITH 'Internal Error!'.
          ENDIF.
        ELSE.
          ROLLBACK WORK.

          MESSAGE s004 DISPLAY LIKE 'E'
             WITH 'Internal Error!'.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '선적접수 시 오류 발생!'.
    ENDIF.
  ELSE.
    MESSAGE s004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SHIPMENT_ACCEPT
*&---------------------------------------------------------------------*
*&      Form  REPLACE_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM replace_all  USING  pv_flag
                         pv_value.

  CASE pv_flag.
    WHEN 'D'.  "DATE
      REPLACE ALL OCCURRENCES OF: '/' IN pv_value WITH '',
                                  '-' IN pv_value WITH '',
                                  '.' IN pv_value WITH ''.

    WHEN 'T'.  "TIME
      REPLACE ALL OCCURRENCES OF: ':' IN pv_value WITH ''.

    WHEN 'Q'.  "Quantity
      REPLACE ALL OCCURRENCES OF: ',' IN pv_value WITH ''.

  ENDCASE.

  CONDENSE pv_value NO-GAPS.

ENDFORM.                    " REPLACE_ALL
*&---------------------------------------------------------------------*
*&      Form  CHECK_UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_upload_data  USING pv_error.
  DATA: lv_ddtext LIKE dd07t-ddtext,
        lv_mod    TYPE i.

  CLEAR : pv_error.

  IF gt_vbap-dlrmg > gt_main-ramng.
    pv_error = 'X'.

    PERFORM message_store USING 'ZLE1' 'E' '004'
                                '판매오더-품목'
                                gv_text
                                '의 출하요청수량이 출하요청'
                                '가능수량을 초과합니다.'.
  ELSEIF gt_vbap-dlrmg <= 0.
    pv_error = 'X'.

    PERFORM message_store USING 'ZLE1' 'E' '004'
                                '판매오더-품목'
                                gv_text
                                '의 출하요청수량이'
                                '입력되지 않았습니다.'.
  ELSE.
    IF gt_main-indlen IS NOT INITIAL.
      lv_mod = gt_vbap-dlrmg MOD gt_main-indlen.

      IF lv_mod IS NOT INITIAL.
        pv_error = 'X'.

        PERFORM message_store USING 'ZLE1' 'E' '004'
                                    '판매오더-품목'
                                    gv_text
                                    '의 출하요청수량과 조장을'
                                    '확인하십시오.'.
      ENDIF.
    ENDIF.
  ENDIF.

*___우편번호/운송경로
  PERFORM check_post_code USING gt_upld-post_code1
                                gt_upld-lzone
                                pv_error
                                gv_text.

*___출하요청일
  IF gt_upld-edatu <> ' ' AND gt_upld-edatu <> '00000000'.
    IF gt_upld-edatu < sy-datlo.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  gv_text
                                  '의 출하요청일이'
                                  '과거일입니다.'.
    ENDIF.
  ELSE.
    pv_error = 'X'.

    PERFORM message_store USING 'ZLE1' 'W' '004'
                                '판매오더-품목'
                                gv_text
                                '의 출하요청일이'
                                '입력되지 않았습니다.'.
  ENDIF.

*___국가코드/운송지역
  IF gt_upld-land1 IS NOT INITIAL AND
     gt_upld-lzone IS NOT INITIAL.
    SELECT SINGLE zone1
      INTO gt_upld-lzone
      FROM tzone
     WHERE land1 = gt_upld-land1
       AND zone1 = gt_upld-lzone.

    IF sy-subrc <> 0.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  gv_text
                                  '의 국가키와 운송경로를'
                                  '확인하십시오.'.
    ENDIF.
  ELSE.
    pv_error = 'X'.

    PERFORM message_store USING 'ZLE1' 'E' '004'
                                '판매오더-품목'
                                gv_text
                                '의 국가키 또는 운송지역이'
                                '입력되지 않았습니다.'.
  ENDIF.

*___운송유형
  IF gt_upld-trtyp IS NOT INITIAL.
    PERFORM domain_value_get USING 'ZDTRTYP'
                                   gt_upld-trtyp
                                   lv_ddtext.

    IF lv_ddtext IS INITIAL.
      pv_error = 'X'.

      PERFORM message_store USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  gv_text
                                  '의 운송유형을'
                                  '확인하십시오.'.
    ENDIF.
  ELSE.
    pv_error = 'X'.

    PERFORM message_store USING 'ZLE1' 'E' '004'
                                '판매오더-품목'
                                gv_text
                                '의 운송유형이'
                                '입력되지 않았습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  DOMAIN_VALUE_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM domain_value_get  USING    pv_dname
                                pv_value
                                pv_ddtext.
  DATA: lv_dname  LIKE dd07v-domname,
        lv_dvalue LIKE dd07v-domvalue_l,
        lv_ddtext LIKE dd07v-ddtext.

  CLEAR : pv_ddtext.

  lv_dname  = pv_dname.
  lv_dvalue = pv_value.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      i_domname  = lv_dname
      i_domvalue = lv_dvalue
    IMPORTING
      e_ddtext   = lv_ddtext
    EXCEPTIONS
      not_exist  = 1
      OTHERS     = 2.

  IF sy-subrc = 0.
    pv_ddtext = lv_ddtext.
  ENDIF.

ENDFORM.                    " DOMAIN_VALUE_GET
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTE_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_screen_attribute_1000 .

  IF gv_trtyp <> 'A'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G11'.
        screen-input     = 0.
        screen-invisible = 1.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SET_SCREEN_ATTRIBUTE_1000
*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMER_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_customer_po  USING    pv_vbeln
                               pv_posnr
                               pv_bstkd
                               pv_bstdk
                               pv_empst.

  CLEAR : pv_bstkd, pv_bstdk, pv_empst.

  SELECT SINGLE bstkd
                bstdk
                empst
    INTO (pv_bstkd, pv_bstdk,
          pv_empst)
    FROM vbkd
   WHERE vbeln = pv_vbeln
     AND posnr = pv_posnr.

  IF sy-subrc <> 0.
    SELECT SINGLE bstkd
                  bstdk
                  empst
      INTO (pv_bstkd, pv_bstdk,
            pv_empst)
      FROM vbkd
     WHERE vbeln = pv_vbeln
       AND posnr = '000000'.
  ENDIF.

ENDFORM.                    " GET_CUSTOMER_PO
*&---------------------------------------------------------------------*
*&      Form  ADD_MONTH_TO_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_month_to_date  USING    pv_datin
                                 pv_month
                                 pv_sign
                                 pv_daout.

  CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
    EXPORTING
      dmm_datin = pv_datin
      dmm_count = pv_month
      dmm_oper  = pv_sign
      dmm_pos   = ' '
    IMPORTING
      dmm_daout = pv_daout.

ENDFORM.                    " ADD_MONTH_TO_DATE
*&---------------------------------------------------------------------*
*&      Form  LAST_DAY_OF_MONTHS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM last_day_of_months  USING   pv_datin
                                 pv_daout.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pv_datin
    IMPORTING
      last_day_of_month = pv_daout
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

ENDFORM.                    " LAST_DAY_OF_MONTHS
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELIVERY_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_delivery_doc  USING    pv_error.
  DATA: lv_vgbel     LIKE zlet0402-vgbel,
        lv_vgpos     LIKE zlet0402-vgpos,
        lv_text1(50),
        lv_text2(50).

  CLEAR : pv_error.

  LOOP AT gt_main WHERE itsel = 'X'.
    CLEAR : lv_vgbel, lv_vgpos.

    SELECT SINGLE vgbel
                  vgpos
      INTO (lv_vgbel, lv_vgpos)
      FROM zlet0402
     WHERE dlvrq = gt_main-dlvrq
       AND vbeln = gt_main-vbeln
       AND posnr = gt_main-posnr.

    IF sy-subrc = 0.
      pv_error = 'X'.

      CONCATENATE gt_main-dlvrq gt_main-vbeln gt_main-posnr
             INTO lv_text1 SEPARATED BY '-'.
      CONCATENATE lv_vgbel lv_vgpos
             INTO lv_text2 SEPARATED BY '-'.

      MESSAGE s004 DISPLAY LIKE 'E'
         WITH '출하요청-판매오더-품목' lv_text1
              '(으)로 생성된 납품문서가 존재합니다.' lv_text2.

      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_DELIVERY_DOC
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_ZLER0011
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM submit_zler0011 .
  DATA: lt_params   LIKE rsparams OCCURS 0 WITH HEADER LINE.

  CLEAR   : lt_params.
  REFRESH : lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'S_WERKS'.
  lt_params-kind    = 'S'.
  lt_params-sign    = 'I'.
  lt_params-option  = 'EQ'.
  lt_params-low     = gt_main-werks.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'S_LGORT'.
  lt_params-kind    = 'S'.
  lt_params-sign    = 'I'.
  lt_params-option  = 'CP'.
  lt_params-low     = '*'.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'S_MATNR'.
  lt_params-kind    = 'S'.
  lt_params-sign    = 'I'.
  lt_params-option  = 'EQ'.
  lt_params-low     = gt_main-matnr.
  APPEND lt_params.

  IF gt_main-sobkz IS INITIAL.
    CLEAR   : lt_params.
    lt_params-selname = 'CK_MTO'.
    lt_params-kind    = 'P'.
    lt_params-low     = ' '.
    APPEND lt_params.
  ELSE.
    CLEAR   : lt_params.
    lt_params-selname = 'R1'.
    lt_params-kind    = 'P'.
    lt_params-low     = ' '.
    APPEND lt_params.

    CLEAR   : lt_params.
    lt_params-selname = 'R2'.
    lt_params-kind    = 'P'.
    lt_params-low     = 'X'.
    APPEND lt_params.

    CLEAR   : lt_params.
    lt_params-selname = 'CK_MTS'.
    lt_params-kind    = 'P'.
    lt_params-low     = ' '.
    APPEND lt_params.

    CLEAR   : lt_params.
    lt_params-selname = 'S_VBELN'.
    lt_params-kind    = 'S'.
    lt_params-sign    = 'I'.
    lt_params-option  = 'EQ'.
    lt_params-low     = gt_main-vbeln.
    APPEND lt_params.
  ENDIF.

  SUBMIT zler0011 WITH SELECTION-TABLE lt_params
                  AND RETURN.

ENDFORM.                    " SUBMIT_ZLER0011
*&---------------------------------------------------------------------*
*& Form CHECK_SALES_GROUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_sales_group .

**-영업팀
*  CASE SY-TCODE.
*    WHEN GC_TCODE1.
*      SELECT VKBUR
*        FROM TVKBZ
*       WHERE VKORG EQ @GC_VKORG
*         AND
*        INTO TABLE @DATA(LT_VKBUR).
*
*
*    WHEN OTHERS.
*      SELECT VKBUR
*        FROM TVKBZ
*       WHERE VKORG EQ @GC_VKORG
*         AND VKBUR IN @S_VKBUR
*        INTO TABLE @DATA(LT_VKBUR).
*
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CREDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_ERROR
*&---------------------------------------------------------------------*
FORM check_credit  USING    pv_error.
  DATA: ls_main LIKE gt_main.

  DATA: lv_amt_fr TYPE wrbtr,
        lv_amt_lo TYPE wrbtr,
        lv_date   TYPE sy-datum.
  DATA: lv_ukm_amount TYPE ukm_amount.
  DATA: ls_result  TYPE ukm_s_query_result.
  DATA: lv_segment  TYPE ukm_credit_sgmnt,
        lv_partner  TYPE bu_partner,
        lv_currency TYPE waers_curc,
        lv_flag     TYPE flag.
  DATA: lv_cof_amount TYPE ukm_comm_actual_item.

  DATA: lv_chk(1),
        lv_zcs_chk(1),
        lv_oth_chk(1).
  DATA: lv_cnt TYPE i.


*-이전 여신 점검 오류 메세지 CLEAR
  MODIFY gt_main FROM ls_main TRANSPORTING stat_c msg WHERE vbeln IS NOT INITIAL.

  lv_date = sy-datlo.

*-판매오더 유형 보관 'ZCS' 만 선택시 여신점검 패스
  DATA(lt_temp) = gt_main[].
  DELETE lt_temp WHERE itsel EQ space.
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    LOOP AT lt_temp INTO DATA(ls_temp).
      IF ls_temp-auart EQ 'ZCS'."보관
        lv_zcs_chk = gc_x.
      ELSE.
        lv_oth_chk = gc_x.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF lv_zcs_chk = gc_x AND lv_oth_chk IS INITIAL.
    EXIT.
  ENDIF.



*-여신점검
  LOOP AT gt_main INTO DATA(ls_data) WHERE itsel = 'X'
                                      GROUP BY ( kunrg = ls_data-kunrg
                                                 kkber = ls_data-kkber
                                                 itsel = 'X'
                                                                             )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).

    CLEAR:lv_ukm_amount,lv_chk.

    "출하요청 금액
    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).
      CLEAR:lv_amt_fr,lv_amt_lo.

      CHECK <fs_line>-dlrmg > 0 AND <fs_line>-kkber IS NOT INITIAL.
      lv_chk = 'X'. "여신점검 수행

      lv_amt_fr =
         ( ( <fs_line>-netwr + <fs_line>-mwsbp ) / <fs_line>-kwmeng ) * <fs_line>-dlrmg.

      IF <fs_line>-waerk NE gc_waerk_krw.
        PERFORM convert_to_local_currency    USING lv_date
                                                   lv_amt_fr
                                                   <fs_line>-waerk
                                                   gc_waerk_krw
                                          CHANGING lv_amt_lo.
      ELSE.
        lv_amt_lo = lv_amt_fr.
      ENDIF.

      lv_ukm_amount = lv_ukm_amount + lv_amt_lo.
    ENDLOOP.

    "여신점검
    IF lv_chk EQ 'X'.
      CLEAR:lv_segment,lv_partner,lv_currency,lv_flag.
      CLEAR:lv_cof_amount.

      "미 출하확정금액
      PERFORM get_ship_req_due_list_amt USING <fs_line>-kunrg
                                              <fs_line>-kkber
                                        CHANGING lv_cof_amount.

      "여신점검금액 = 미 출하확정 금액 + 출하요청 금액
      lv_ukm_amount = lv_cof_amount + lv_ukm_amount.

      "여신점검
      lv_partner  = <fs_line>-kunrg.
      lv_segment  = <fs_line>-kkber.
      lv_currency = gc_waerk_krw.
      lv_flag     = 'X'.
      CALL FUNCTION 'UKM_CREDIT_CHECK_SIMU'
        EXPORTING
          i_partner      = lv_partner
          i_segment      = lv_segment
*         I_LIMIT_RULE   =
*         I_CHECK_RULE   =
          i_amount       = lv_ukm_amount
          i_currency     = lv_currency
          i_no_dialog    = lv_flag
          i_date         = lv_date
        IMPORTING
          e_check_result = ls_result.
      IF ls_result-passed EQ 'X'.
      ELSE.
        pv_error = 'X'.
        LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line1>).
          CHECK <fs_line>-dlrmg > 0.
          <fs_line1>-stat_c = icon_led_red.
          <fs_line1>-msg    = TEXT-m01.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_DATE
*&      --> LV_AMT_FR
*&      --> <FS_LINE>_WAERK
*&      --> GC_WAERK_KRW
*&      <-- LV_AMT_LO
*&---------------------------------------------------------------------*
FORM convert_to_local_currency  USING    pv_date
                                         pv_amt_fr
                                         pv_waers_fr
                                         pv_waers_lo
                                CHANGING pv_amt_lo.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      date             = pv_date
      foreign_amount   = pv_amt_fr
      foreign_currency = pv_waers_fr
      local_currency   = pv_waers_lo
    IMPORTING
*     exchange_rate    =
*     foreign_factor   =
      local_amount     = pv_amt_lo
*     LOCAL_FACTOR     =
*     EXCHANGE_RATEX   =
*     FIXED_RATE       =
*     DERIVED_RATE_TYPE       =
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ALV_GRID
*&---------------------------------------------------------------------*
FORM refresh_alv  USING   pc_grid
                         TYPE REF TO cl_gui_alv_grid.
  DATA: ls_stable TYPE lvc_s_stbl.
  ls_stable-row = 'X'.
  ls_stable-col = 'X'.
  IF pc_grid IS NOT INITIAL.
    CALL METHOD pc_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VSTEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vstel  USING    pv_fname.

  SELECT DISTINCT b~vstel,c~vtext
    FROM tvkwz AS a INNER JOIN tvswz AS b
                    ON a~werks = b~werks
                    INNER JOIN tvstt AS c
                    ON b~vstel = c~vstel AND
                       c~spras = @sy-langu
   WHERE a~vkorg EQ @gc_vkorg
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vstel.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VSTEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_werks  USING    pv_fname.

  SELECT DISTINCT a~werks,b~name1
    FROM tvkwz AS a INNER JOIN t001w AS b
                    ON a~werks = b~werks
   WHERE a~vkorg EQ @gc_vkorg
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY werks.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkbur  USING    pv_fname.

  SELECT DISTINCT a~vkbur,b~bezei
    FROM tvkbz AS a INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur

   WHERE a~vkorg EQ @gc_vkorg
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vkbur.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKBUR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkgrp  USING    pv_fname.
  RANGES: lr_vkbur FOR vbak-vkbur.

  IF gv_trtyp EQ 'H'.
    lr_vkbur[] = CORRESPONDING #( s_vkbur[] ).
  ELSE.
    lr_vkbur[] = CORRESPONDING #( s_vkbur1[] ).
  ENDIF.

  SELECT DISTINCT a~vkbur,b~bezei,a~vkgrp,c~bezei AS vkgrp_txt
    FROM tvkbz AS h INNER JOIN tvbvk AS a
                    ON h~vkbur = a~vkbur
                    INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur AND
                       b~spras = @sy-langu
                    INNER JOIN tvgrt AS c
                    ON a~vkgrp = c~vkgrp AND
                       c~spras = @sy-langu
   WHERE h~vkorg EQ @gc_vkorg
     AND a~vkbur IN @lr_vkbur
    INTO TABLE @DATA(lt_value).

  SORT lt_value BY vkbur.

  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_LZONE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DELV_LZONE
*&---------------------------------------------------------------------*
FORM f4help_lzone  USING    pv_lzone.
  DATA: selectfield  LIKE  help_info-fieldname,
        lt_fields    LIKE  help_value OCCURS 1 WITH HEADER LINE,
        select_value LIKE  help_info-fldvalue,
        lt_return    LIKE  ddshretval OCCURS 0 WITH HEADER LINE,
        ld_tabix     LIKE  sy-tabix.

  DATA: scr_fields LIKE dynpread OCCURS 0 WITH HEADER LINE,
        feld_table LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: lt_dynpfields TYPE TABLE OF dynpread,
        ls_dynpfields LIKE LINE OF lt_dynpfields.


  RANGES: lr_land1 FOR tzone-land1.

  ls_dynpfields-fieldname = 'GS_DELV-LAND1'.
  APPEND ls_dynpfields TO lt_dynpfields.

  ls_dynpfields-fieldname = 'GS_DELV-LZONE'.
  APPEND ls_dynpfields TO lt_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc EQ 0.
    APPEND VALUE #( sign = 'I' option = 'EQ'
                    low = VALUE #( lt_dynpfields[ fieldname = 'GS_DELV-LAND1' ]-fieldvalue OPTIONAL ) )
        TO lr_land1.
  ENDIF.

  SELECT a~land1,a~zone1,b~vtext
    FROM tzone AS a INNER JOIN tzont AS b
                    ON a~land1 = b~land1 AND
                       a~zone1 = b~zone1 AND
                       b~spras = @sy-langu
   WHERE a~land1 IN @lr_land1
    INTO TABLE @DATA(lt_value).

  CHECK lt_value[] IS NOT INITIAL.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ZONE1'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
*     DYNPROFIELD     = 'GS_DELV-LZONE'
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  DATA(ls_line) = VALUE #( lt_dynpfields[ fieldname = 'GS_DELV-LZONE' ] OPTIONAL ).
  CHECK ls_line-fieldinp EQ 'X'.

  IF line_exists( lt_return[ 1 ] ).
    CLEAR:lt_dynpfields[],ls_dynpfields.
    ls_dynpfields-fieldname = 'GS_DELV-LZONE'.
    ls_dynpfields-fieldvalue = VALUE #( lt_return[ 1 ]-fieldval ).
    APPEND ls_dynpfields TO lt_dynpfields.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname               = sy-cprog
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = lt_dynpfields
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        undefind_error       = 7
        OTHERS               = 8.



  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SHIP_REQ_DUE_LIST_AMT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_LINE>_KUNRG
*&      --> <FS_LINE>_KKBER
*&      <-- LV_COF_AMOUNT
*&---------------------------------------------------------------------*
FORM get_ship_req_due_list_amt  USING    pv_kunrg
                                         pv_kkber
                                CHANGING pv_amount.
  DATA: lv_amount  TYPE ukm_comm_actual_item,
        lv_partner TYPE bu_partner,
        lv_segment TYPE kkber,
        lv_waers   TYPE waers,
        lv_type    TYPE bapi_mtype,
        lv_msg     TYPE bapi_msg.

  lv_partner = pv_kunrg.
  lv_segment = pv_kkber.

  CALL FUNCTION 'ZGTSD_SHIP_REQ_DUE_LIST_AMT'
    EXPORTING
      i_partner = lv_partner
      i_segment = lv_segment
*     I_FROMDATE       =
    IMPORTING
      e_amount  = lv_amount
      e_waers   = lv_waers
      e_type    = lv_type
      e_msg     = lv_msg.

  IF lv_type EQ 'S'.
    pv_amount = lv_amount.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CREDIT_CHG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_ERROR
*&---------------------------------------------------------------------*
FORM check_credit_chg  USING    pv_error.
  DATA: ls_main LIKE gt_main.

  DATA: lv_amt_fr TYPE wrbtr,
        lv_amt_lo TYPE wrbtr,
        lv_date   TYPE sy-datum.
  DATA: lv_ukm_amount TYPE ukm_amount.
  DATA: ls_result  TYPE ukm_s_query_result.
  DATA: lv_segment  TYPE ukm_credit_sgmnt,
        lv_partner  TYPE bu_partner,
        lv_currency TYPE waers_curc,
        lv_flag     TYPE flag.
  DATA: lv_cof_amount TYPE ukm_comm_actual_item.

  DATA: lv_chk(1),
        lv_zcs_chk(1),
        lv_oth_chk(1).
  DATA: lv_cnt TYPE i.


*-이전 여신 점검 오류 메세지 CLEAR
  MODIFY gt_main FROM ls_main TRANSPORTING stat_c msg WHERE vbeln IS NOT INITIAL.

*-판매오더 유형 보관 'ZCS' 만 선택시 여신점검 패스
  DATA(lt_temp) = gt_main[].
  DELETE lt_temp WHERE itsel EQ space.
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    LOOP AT lt_temp INTO DATA(ls_temp).
      IF ls_temp-auart EQ 'ZCS'."보관
        lv_zcs_chk = gc_x.
      ELSE.
        lv_oth_chk = gc_x.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF lv_zcs_chk = gc_x AND lv_oth_chk IS INITIAL.
    EXIT.
  ENDIF.


*-이전 여신 점검 오류 메세지 CLEAR
  MODIFY gt_main FROM ls_main TRANSPORTING stat_c msg WHERE vbeln IS NOT INITIAL.

*-여신점검
  LOOP AT gt_main INTO DATA(ls_data) WHERE itsel = 'X'
                                      GROUP BY ( kunrg = ls_data-kunrg
                                                 kkber = ls_data-kkber
                                                                             )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).

    CLEAR:lv_ukm_amount,lv_chk.

    "출하요청 금액
    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).
      CLEAR:lv_amt_fr,lv_amt_lo.

      CHECK <fs_line>-dlrmg > 0            AND
            <fs_line>-kkber IS NOT INITIAL AND
            <fs_line>-dlrmg > <fs_line>-dlrmg_old.  "출하요청 수량 증가의 경우만 점검

      lv_chk = 'X'. "여신점검 수행

      lv_amt_fr =
         ( ( <fs_line>-netwr + <fs_line>-mwsbp ) / <fs_line>-kwmeng ) *
         ( <fs_line>-dlrmg - <fs_line>-dlrmg_old ).

      IF <fs_line>-waerk NE gc_waerk_krw.
        PERFORM convert_to_local_currency USING lv_date
                                                lv_amt_fr
                                                <fs_line>-waerk
                                                gc_waerk_krw
                                          CHANGING lv_amt_lo.
      ELSE.
        lv_amt_lo = lv_amt_fr.
      ENDIF.

      lv_ukm_amount = lv_ukm_amount + lv_amt_lo.
    ENDLOOP.

    "여신점검
    IF lv_chk EQ 'X'.
      CLEAR:lv_segment,lv_partner,lv_currency,lv_flag.
      CLEAR:lv_cof_amount.

      "미 출하확정금액
      PERFORM get_ship_req_due_list_amt    USING <fs_line>-kunrg
                                                 <fs_line>-kkber
                                        CHANGING lv_cof_amount.

      "여신점검금액 = 미 출하확정 금액 + 출하요청 금액(증가분)
      lv_ukm_amount = lv_cof_amount + lv_ukm_amount.

      "여신점검
      lv_partner  = <fs_line>-kunrg.
      lv_segment  = <fs_line>-kkber.
      lv_currency = gc_waerk_krw.
      lv_flag     = 'X'.

      CALL FUNCTION 'UKM_CREDIT_CHECK_SIMU'
        EXPORTING
          i_partner      = lv_partner
          i_segment      = lv_segment
*         I_LIMIT_RULE   =
*         I_CHECK_RULE   =
          i_amount       = lv_ukm_amount
          i_currency     = lv_currency
          i_no_dialog    = lv_flag
          i_date         = lv_date
        IMPORTING
          e_check_result = ls_result.
      IF ls_result-passed EQ 'X'.
      ELSE.
        pv_error = 'X'.
        LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line1>).
          CHECK <fs_line>-dlrmg > 0.
          <fs_line1>-stat_c = icon_led_red.
          <fs_line1>-msg    = TEXT-m02.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VSTEL_FOR_ZREQ_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
FORM set_vstel_for_zreq_type  USING    ps_main LIKE gt_main.
  CASE ps_main-zreq_type.
    WHEN gc_a OR gc_b OR gc_c.
      IF ps_main-vstel+2(2) NE '98'.
        ps_main-vstel+2(2) = '98'.
      ENDIF.

    WHEN OTHERS.
      IF ps_main-vstel+2(2) EQ '98'.
        SELECT SINGLE vstel
          INTO @DATA(lv_vstel)
          FROM vbap
         WHERE vbeln EQ @ps_main-vbeln
           AND posnr EQ @ps_main-posnr.
        IF sy-subrc EQ 0.
          ps_main-vstel = lv_vstel.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_POST_CODE_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DELV_POST_CODE1
*&---------------------------------------------------------------------*
FORM check_post_code_new  USING    pv_post1.

  SELECT SINGLE post_code
    INTO @DATA(lv_post_code)
    FROM zgtsdt9121
   WHERE post_code EQ @pv_post1.

  IF sy-subrc NE 0.
    MESSAGE e004 WITH '유효하지 않은 우편번호입니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_PP_LINK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_0401
*&---------------------------------------------------------------------*
FORM call_pp_link_info  TABLES   pt_0401 STRUCTURE zlet0401.
  DATA: lt_zlet0401 TYPE TABLE OF zlet0401.
  DATA: lt_item   TYPE TABLE OF zgtppsif0044,
        lt_return TYPE TABLE OF zgtppsif0045.

  DATA: lv_werks       TYPE werks_d,
        lv_upd_type(2) TYPE c VALUE 'U2'.
  DATA: lv_seqno    TYPE zgteseqno.

  CHECK pt_0401[] IS NOT INITIAL.

  lt_zlet0401[] = CORRESPONDING #( pt_0401[] ).

  SELECT a~dlvrq,a~vbeln,a~posnr,a~werks,a~matnr
*         B~SPART
    FROM @lt_zlet0401 AS a INNER JOIN marc AS b
                           ON a~matnr = b~matnr
                           AND a~werks EQ b~werks
                           AND b~dpcbt EQ 'A'
*   WHERE B~SPART EQ '43'
    INTO TABLE @DATA(lt_list).

  SORT lt_list BY vbeln posnr werks.

  SELECT a~vbeln, a~posnr, b~kwmeng, SUM( c~kalab ) AS kalab
    FROM @lt_zlet0401 AS a INNER JOIN vbap AS b
                           ON a~vbeln EQ b~vbeln
                           AND a~posnr EQ b~posnr
                           INNER JOIN mska AS c
                           ON a~vbeln EQ c~vbeln
                           AND a~posnr EQ c~posnr
                           AND c~kalab GT 0
    GROUP BY a~vbeln, a~posnr, b~kwmeng
    INTO TABLE @DATA(lt_estock).

  SORT lt_estock BY vbeln posnr kwmeng.

  CHECK lt_list[] IS NOT INITIAL.

  SORT lt_list BY werks vbeln posnr.

  LOOP AT lt_list INTO DATA(ls_list) GROUP BY ( werks = ls_list-werks )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).
    CLEAR:lt_item[],lt_return[],lv_werks,lv_seqno.
    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).

      READ TABLE lt_estock INTO DATA(ls_estock) WITH KEY vbeln = <fs_line>-vbeln
                                                         posnr = <fs_line>-posnr.

      IF sy-subrc NE 0 OR ls_estock-kalab LT ls_estock-kwmeng.

        lv_werks = <fs_line>-werks.

        lv_seqno = lv_seqno + 1.

        APPEND VALUE #( seqno = lv_seqno
                        dlvrq = <fs_line>-dlvrq
                        budat = sy-datlo
                        vbeln = <fs_line>-vbeln
                        posnr = <fs_line>-posnr
                      ) TO lt_item.
      ENDIF.

    ENDLOOP.

    CHECK lt_item[] IS NOT INITIAL.

    CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
      EXPORTING
        i_werks    = lv_werks
        i_upd_type = lv_upd_type
      TABLES
        it_item    = lt_item
        ot_return  = lt_return.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_PP_LINK_INFO_CHG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_pp_link_info_chg  USING p_step.
  DATA: lt_zlet0401 TYPE TABLE OF zlet0401.
  DATA: lt_item   TYPE TABLE OF zgtppsif0044,
        lt_return TYPE TABLE OF zgtppsif0045.
  DATA: lv_werks          TYPE werks_d,
        lv_upd_type_u2(2) TYPE c VALUE 'U2',
        lv_upd_type_z2(2) TYPE c VALUE 'Z2'.
  DATA: lv_seqno    TYPE zgteseqno.

  CHECK gt_link[] IS NOT INITIAL.

*  SELECT a~dlvrq,a~vbeln,a~posnr,a~werks,a~matnr,
*         b~spart
*    FROM @gt_link AS a INNER JOIN mara AS b
*                       ON a~matnr = b~matnr
*   WHERE b~spart EQ '43'
*    INTO TABLE @DATA(lt_list).

  " 기준변경: 통합배선 (=LAN 케이블)->Factor Batch
  " 기준추가: Single Unit/Factor Batch 미사용 AND Batch 관리
  " 기준추가: 배관 제품(Plant: 6581)
  SELECT a~dlvrq, a~vbeln, a~posnr, a~werks, a~matnr
      FROM @gt_link AS a
     INNER JOIN marc AS b
        ON a~matnr EQ b~matnr
       AND a~werks EQ b~werks
     WHERE ( b~dpcbt EQ 'A' )
        OR ( a~werks EQ '6581' )
        OR ( b~dpcbt EQ @space AND b~xchpf EQ 'X' )
      INTO TABLE @DATA(lt_list).


  SORT lt_list BY vbeln posnr werks.

  SELECT a~vbeln, a~posnr, b~kwmeng, SUM( c~kalab ) AS kalab
    FROM @gt_link AS a INNER JOIN vbap AS b
                           ON a~vbeln EQ b~vbeln
                           AND a~posnr EQ b~posnr
                           INNER JOIN mska AS c
                           ON a~vbeln EQ c~vbeln
                           AND a~posnr EQ c~posnr
                           AND c~kalab GT 0
    GROUP BY a~vbeln, a~posnr, b~kwmeng
    INTO TABLE @DATA(lt_estock).

  SORT lt_estock BY vbeln posnr.

  CHECK lt_list[] IS NOT INITIAL.

  SORT lt_list BY werks dlvrq vbeln posnr.

  LOOP AT lt_list INTO DATA(ls_list) GROUP BY ( werks = ls_list-werks )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main>).

    CLEAR:lt_item[],lt_return[],lv_werks,lv_seqno.
    LOOP AT GROUP <fs_main> ASSIGNING FIELD-SYMBOL(<fs_line>).

      DATA(lv_append_flag) = abap_false.

      IF p_step EQ gc_u OR p_step EQ gc_i.
        READ TABLE lt_estock INTO DATA(ls_estock) WITH KEY vbeln = <fs_line>-vbeln
                                                           posnr = <fs_line>-posnr
                                                  BINARY SEARCH.
        IF sy-subrc NE 0 OR ls_estock-kalab LT ls_estock-kwmeng.
          lv_append_flag = abap_true.
        ENDIF.
      ELSE.
        lv_append_flag = abap_true.
      ENDIF.

      IF lv_append_flag EQ abap_true.
        lv_werks = <fs_line>-werks.
        lv_seqno += 1.

        APPEND VALUE #( seqno = lv_seqno
                        dlvrq = <fs_line>-dlvrq
                        budat = sy-datlo
                        vbeln = <fs_line>-vbeln
                        posnr = <fs_line>-posnr ) TO lt_item.
      ENDIF.

    ENDLOOP.
    CHECK lt_item[] IS NOT INITIAL.

    "삭제
    IF p_step EQ gc_u OR p_step EQ gc_d.  "변경/삭제
      CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
        EXPORTING
          i_werks    = lv_werks
          i_upd_type = lv_upd_type_z2
        TABLES
          it_item    = lt_item
          ot_return  = lt_return.
    ENDIF.

    "신규
    IF p_step EQ gc_u OR p_step EQ gc_i. "변경/신규
      CLEAR:lt_return[].
      CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
        EXPORTING
          i_werks    = lv_werks
          i_upd_type = lv_upd_type_u2
        TABLES
          it_item    = lt_item
          ot_return  = lt_return.
    ENDIF.

  ENDLOOP.
ENDFORM.
