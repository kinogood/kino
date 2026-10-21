*----------------------------------------------------------------------*
***INCLUDE LZGTMM03F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DATE_SETTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_AEDAT
*&---------------------------------------------------------------------*
FORM date_setting USING p_date LIKE sy-datum.

  clt : r_date.
  clt : r_matnr.

  r_date-sign   = 'I'.
  IF p_date IS INITIAL.
    r_date-option = 'BT'.
    r_date-low    = sy-datum.
    r_date-high   = sy-datum.
  ELSE.
    r_date-option = 'EQ'.
    r_date-low    = p_date.
  ENDIF.

  app r_date.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_EKPO
*&---------------------------------------------------------------------*
FORM get_other_data USING p_ekpo LIKE zmmti07.

  DATA : l_return TYPE bapiret2_t.
  DATA : lt_char  LIKE e1cuval OCCURS 0 WITH HEADER LINE.
  DATA : l_matnr  LIKE mara-matnr.
  DATA : l_maktx  LIKE makt-maktx.
  DATA : l_float TYPE f,
         l_dec   LIKE estvp-compavg.

* 특성값 가져오기........................
*  CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
*    EXPORTING
*      EBELN                        = P_EKPO-EBELN
*      EBELP                        = P_EKPO-EBELP
*    IMPORTING
*      ET_RETURN                    = L_RETURN
*    TABLES
*      T_E1CUVAL                    = LT_CHAR
*    EXCEPTIONS
*      INSTANCE_NOT_FOUND           = 1
*      INTERNAL_ERROR               = 2
*      INSTANCE_IS_A_CLASSIFICATION = 3
*      OTHERS                       = 4.
*  CHECK SY-SUBRC = 0.

  DATA : lv_subrc TYPE sy-subrc.
  PERFORM zmm_ekpo_spec_get_cached
    TABLES lt_char
    USING  p_ekpo-ebeln
           p_ekpo-ebelp
    CHANGING l_return
             lv_subrc.
  CHECK lv_subrc = 0.

* 조장.....
  READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_LENGTH'.
  IF sy-subrc = 0.
    l_float = lt_char-value.
    PERFORM char_conversion USING l_float CHANGING l_dec.
    WRITE l_dec TO p_ekpo-zrolen DECIMALS 0.
    CALL FUNCTION 'STRING_REPLACE'
      EXPORTING
        pattern             = ','
        substitute          = ''
      CHANGING
        text                = p_ekpo-zrolen
      EXCEPTIONS
        wrong_string_length = 1
        OTHERS              = 2.
    CONDENSE p_ekpo-zrolen NO-GAPS.
  ENDIF.
* 조장수...
  READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_FACTOR'.
  IF sy-subrc = 0.
    l_float = lt_char-value.
    PERFORM char_conversion USING l_float CHANGING l_dec.
    WRITE l_dec TO p_ekpo-zrolcn DECIMALS 0.
    CALL FUNCTION 'STRING_REPLACE'
      EXPORTING
        pattern             = ','
        substitute          = ''
      CHANGING
        text                = p_ekpo-zrolcn
      EXCEPTIONS
        wrong_string_length = 1
        OTHERS              = 2.
    CONDENSE p_ekpo-zrolcn NO-GAPS.
  ENDIF.
* 포장재...
  READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_PACKAGING'.
  IF sy-subrc = 0.
*- ZLSGMMR 2024.01.04, EXIT_MATN1 수정
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = LT_CHAR-VALUE
*      IMPORTING
*        OUTPUT = L_MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = lt_char-value
      IMPORTING
        output = l_matnr.
*- ZLSGMMR 2024.01.04, EXIT_MATN1 수정

    SELECT SINGLE maktx INTO l_maktx
      FROM makt
     WHERE matnr = l_matnr AND spras = sy-langu.
    IF sy-subrc = 0.
      p_ekpo-zpacsp = l_maktx.
    ENDIF.
  ENDIF.
* 포장재유형..
  READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_PACKAGING_CAT'.
  IF sy-subrc = 0. p_ekpo-zpacty = lt_char-value_txt. ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHAR_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> L_FLOAT
*&      <-- L_DEC
*&---------------------------------------------------------------------*
FORM char_conversion USING p_float
                  CHANGING p_dec.

  CLEAR p_dec.

  CALL FUNCTION 'C14W_NUMBER_CHAR_CONVERSION'
    EXPORTING
      i_float    = p_float
      i_decimals = 3
    IMPORTING
      e_dec      = p_dec.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ZPPTIF33
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_EKPO
*&---------------------------------------------------------------------*
FORM select_zpptif33 USING p_ekpo LIKE zmmti07.

  DATA : lv_knumh_bd  LIKE a017-knumh,
         lv_menge2_bd LIKE zpptif33-menge2,
         lv_infnr_bd  LIKE eina-infnr,
         lv_date      LIKE sy-datum.

  CLEAR : lv_knumh_bd, lv_menge2_bd, lv_infnr_bd, lv_date.

  SELECT SINGLE infnr menge2 bedat
    INTO (lv_infnr_bd, lv_menge2_bd, lv_date)
    FROM zpptif33
   WHERE ebeln = p_ekpo-ebeln
     AND ebelp = p_ekpo-ebelp
     AND lifnr = p_ekpo-lifnr
     AND werks = p_ekpo-werks
     AND knttp = 'M'
     AND epstp = 'L'
     AND zflag = 'I'
     AND zeret = '00'.

  IF sy-subrc EQ 0.

*& 자재그룹 정보레코드 정보를 가져옴
    SELECT SINGLE knumh INTO lv_knumh_bd FROM a025
     WHERE kappl = 'M'
       AND kschl = 'PB00'
       AND lifnr = p_ekpo-lifnr
       AND infnr = lv_infnr_bd
       AND ekorg = '1100'
       AND esokz = '3'
       AND werks = p_ekpo-werks
       AND datab <= lv_date
       AND datbi >= lv_date.

    IF sy-subrc NE 0.
      SELECT SINGLE knumh INTO lv_knumh_bd FROM a025
       WHERE kappl = 'M'
         AND kschl = 'PB00'
         AND lifnr = p_ekpo-lifnr
         AND infnr = lv_infnr_bd
         AND ekorg = '1100'
         AND esokz = '0'
         AND werks = p_ekpo-werks
         AND datab <= lv_date
         AND datbi >= lv_date.
    ENDIF.

    IF lv_knumh_bd IS NOT INITIAL.

      SELECT SINGLE kbetr kpein kmein
        FROM konp
        INTO (p_ekpo-netpr_bd, p_ekpo-peinh_bd, p_ekpo-meins_bd)
       WHERE kappl = 'M'
         AND kschl = 'PB00'
         AND knumh = lv_knumh_bd
         AND loevm_ko = ' '.

      p_ekpo-menge_bd = lv_menge2_bd.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LONGTEXT_VIEW_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_EKPO
*&      --> IT_TXT
*&---------------------------------------------------------------------*
FORM longtext_view_c USING p_ekpo LIKE zmmti07
                           p_txt  LIKE zmmti39.

  DATA : BEGIN OF lt_line OCCURS 0.
           INCLUDE STRUCTURE tline.
  DATA : END   OF lt_line.
  DATA : l_tdname   LIKE stxh-tdname,              "OBJECT조회용....
         l_cnt(02)  TYPE n,
         l_text(30).

  CONCATENATE p_ekpo-ebeln p_ekpo-ebelp INTO l_tdname.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'F01'
      language                = sy-langu
      name                    = l_tdname
      object                  = 'EKPO'
    TABLES
      lines                   = lt_line
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  CHECK sy-subrc = 0.

  FIELD-SYMBOLS: <fs_text>.

  IF NOT lt_line[] IS INITIAL.
    LOOP AT lt_line.
      l_cnt = sy-tabix.
      CLEAR: l_text.
      CONCATENATE 'P_TXT-ZTEXTL' l_cnt INTO l_text.
      ASSIGN (l_text) TO <fs_text>.

      MOVE lt_line-tdline TO <fs_text>.

      CONCATENATE p_ekpo-ztext lt_line-tdline INTO p_ekpo-ztext
                  SEPARATED BY space.
    ENDLOOP.
*- ZLSGMM4 2024.01.02, SY-MADNT 할당 수정
    p_txt-mandt = sy-mandt.
    MOVE p_ekpo-ebeln TO p_txt-ebeln.
    MOVE p_ekpo-ebelp TO p_txt-ebelp.
*    MOVE P_EKPO-LOEKZ TO P_TXT-LOEKZ.
*    APPEND P_TXT. CLEAR P_TXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_AMOUNT
*&---------------------------------------------------------------------*
*       금액수정...
*&---------------------------------------------------------------------*
*&      --> LT_ITAB06_ZAMT
*&---------------------------------------------------------------------*
FORM change_amount USING p_amount.

  CALL FUNCTION 'STRING_REPLACE'
    EXPORTING
      pattern             = ','
      substitute          = ''
    CHANGING
      text                = p_amount
    EXCEPTIONS
      wrong_string_length = 1
      OTHERS              = 2.
*  DO.
*    REPLACE ',' WITH C_BLANK INTO P_AMOUNT.
*    IF SY-SUBRC NE 0. EXIT. ENDIF.
*  ENDDO.

* MINUS금액을 +로 변경....
*_ksj_2005.05.24 -- 막음
*  REPLACE '-' WITH c_blank INTO p_amount.
* Minus금액의 부호를 앞으로 붙임.
  DATA: text1(1) TYPE c.

  SEARCH p_amount FOR '-'.
  IF sy-subrc = 0 AND sy-fdpos <> 0.
    SPLIT p_amount AT '-' INTO p_amount text1.
    CONDENSE p_amount.
    CONCATENATE '-' p_amount INTO p_amount.
  ELSE.
    CONDENSE p_amount.
  ENDIF.

* 공백을 없앤다...
  CONDENSE p_amount NO-GAPS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITAB07
*&      --> IT_EKPO
*&---------------------------------------------------------------------*
FORM select_kunnr USING p_itab07 LIKE zgtmmsif0042 "ZMMSI07 구조변경(25.02.06)
                        p_ekpo   LIKE zmmti07.

  DATA : l_name1 LIKE kna1-name1,
         l_ort01 LIKE kna1-ort01,
         l_stras LIKE kna1-stras.

  IF NOT p_ekpo-kunnr IS INITIAL.
    SELECT SINGLE name1 ort01 stras telf1
      INTO (l_name1, l_ort01, l_stras, p_itab07-tel)
      FROM kna1
     WHERE kunnr = p_ekpo-kunnr.
    IF sy-subrc = 0.
      p_itab07-name1 = l_name1.
      CONCATENATE l_ort01 l_stras INTO p_itab07-city1
                  SEPARATED BY space.
    ENDIF.
  ENDIF.

  IF NOT p_ekpo-emlif IS INITIAL.
    SELECT SINGLE name1 ort01 stras telf1
      INTO (l_name1, l_ort01, l_stras, p_itab07-tel)
      FROM lfa1
     WHERE lifnr = p_ekpo-emlif.
    IF sy-subrc = 0.
      p_itab07-name1 = l_name1.
      CONCATENATE l_ort01 l_stras INTO p_itab07-city1
                  SEPARATED BY space.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LONGTEXT_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITAB07
*&---------------------------------------------------------------------*
FORM longtext_view USING p_ekpo LIKE zgtmmsif0042. "ZMMSI07. 구조변경(25.02.06)
  DATA : BEGIN OF lt_line OCCURS 0.
           INCLUDE STRUCTURE tline.
  DATA : END   OF lt_line.
  DATA : l_tdname   LIKE stxh-tdname,              "OBJECT조회용....
         l_cnt(02)  TYPE n,
         l_text(30).

  CONCATENATE p_ekpo-ebeln p_ekpo-ebelp INTO l_tdname.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'F01'
      language                = sy-langu
      name                    = l_tdname
      object                  = 'EKPO'
    TABLES
      lines                   = lt_line
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  CHECK sy-subrc = 0.

  FIELD-SYMBOLS: <fs_text>.

  IF NOT lt_line[] IS INITIAL.
    LOOP AT lt_line.
      l_cnt = sy-tabix.
      CLEAR: l_text.
      CONCATENATE 'LT_ITAB39-ZTEXTL' l_cnt INTO l_text.
      ASSIGN (l_text) TO <fs_text>.

      MOVE lt_line-tdline TO <fs_text>.

      CONCATENATE p_ekpo-ztext lt_line-tdline INTO p_ekpo-ztext
                  SEPARATED BY space.
    ENDLOOP.
*- ZLSGMM4 2024.01.02, SY-MADNT 할당 수정
    lt_itab39-mandt = sy-mandt.
    MOVE p_ekpo-ebeln TO lt_itab39-ebeln.
    MOVE p_ekpo-ebelp TO lt_itab39-ebelp.
    MOVE p_ekpo-loekz TO lt_itab39-loekz.
    APPEND lt_itab39. CLEAR lt_itab39.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LONGTEXT_VIEW_04
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITAB07
*&---------------------------------------------------------------------*
FORM longtext_view_04 USING p_ekpo LIKE zgtmmsif0042. "ZMMSI07. 구조변경(25.02.06)
  DATA : BEGIN OF lt_line OCCURS 0.
           INCLUDE STRUCTURE tline.
  DATA : END   OF lt_line.
  DATA : l_tdname   LIKE stxh-tdname,              "OBJECT조회용....
         l_cnt(02)  TYPE n,
         l_text(30).

  CONCATENATE p_ekpo-ebeln p_ekpo-ebelp INTO l_tdname.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'F04'   "납품PO Text
      language                = sy-langu
      name                    = l_tdname
      object                  = 'EKPO'
    TABLES
      lines                   = lt_line
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  CHECK sy-subrc = 0.

  FIELD-SYMBOLS: <fs_text>.

  IF NOT lt_line[] IS INITIAL.
    LOOP AT lt_line.
      MOVE lt_line-tdline TO p_ekpo-ztext04.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZMM_EKPO_SPEC_GET_CACHED
*&---------------------------------------------------------------------*
*  ZMM_EKPO_SPEC_GET 원본과 로직 100% 동일 + CABN/CABNT/CAWN 캐시버퍼
*  ZGTMM_IF_O_PO_ER 전용. 공용 FM 'ZMM_EKPO_SPEC_GET'은 별도로 그대로
*  존재하며 다른 프로그램은 계속 그걸 씀.
*&---------------------------------------------------------------------*
*&      --> PV_EBELN
*&      --> PV_EBELP
*&      <-- PT_E1CUVAL
*&      <-- PV_ET_RETURN
*&      <-- PV_SUBRC (0=성공, 1=instance_not_found, 2=internal_error,
*&                     3=instance_is_a_classification)
*&---------------------------------------------------------------------*
FORM zmm_ekpo_spec_get_cached
  TABLES pt_e1cuval STRUCTURE e1cuval
  USING    pv_ebeln LIKE ekpo-ebeln
           pv_ebelp LIKE ekpo-ebelp
  CHANGING pv_et_return TYPE bapiret2_t
           pv_subrc     TYPE sy-subrc.

  CLEAR pv_subrc.

  DATA: ls_cfg_head   LIKE cuxt_cucfg_s,
        ls_instances  LIKE cuxt_cuins_s,
        ls_values     LIKE cuxt_cuval_s,
        ls_e1cucfg    LIKE e1cucfg,
        ls_e1cuins    LIKE e1cuins,
        ls_e1cuval    LIKE e1cuval,
        ls_profile    LIKE e1cucom,
        ls_ekpo       LIKE ekpo,
        l_cuobj       LIKE inob-cuobj,
        l_atinn       LIKE cabn-atinn.

  DATA: lt_instances  LIKE cuxt_cuins_s OCCURS 0,
        lt_part_of    LIKE cuxt_cuprt_s OCCURS 0,
        lt_values     LIKE cuxt_cuval_s OCCURS 0,
        lt_var_keys   LIKE cuxt_cuvk_s  OCCURS 0,
        lt_ksml       LIKE ksml         OCCURS 0 WITH HEADER LINE,
        BEGIN OF lt_clint OCCURS 0,
          clint  LIKE kssk-clint,
        END OF lt_clint.

*-[성능개선] 이름충돌 방지용 로컬변수 분리
  DATA : lv_ebeln LIKE ekpo-ebeln,
         lv_ebelp LIKE ekpo-ebelp.

*-[성능개선] CABN/CABNT/CAWN+CAWNT 캐시버퍼 (내부세션 유지)
  STATICS : gt_cabn_buf TYPE HASHED TABLE OF ty_cabn_buf
                        WITH UNIQUE KEY atnam,
            gt_cawn_buf TYPE HASHED TABLE OF ty_cawn_buf
                        WITH UNIQUE KEY atinn atwrt.

  DATA : ls_cabn_buf TYPE ty_cabn_buf,
         ls_cawn_buf TYPE ty_cawn_buf.

  REFRESH pt_e1cuval.

  lv_ebeln = pv_ebeln.
  lv_ebelp = pv_ebelp.

  CLEAR ls_ekpo.
  SELECT SINGLE cuobj INTO CORRESPONDING FIELDS OF ls_ekpo
                            FROM ekpo WHERE ebeln = lv_ebeln
                                        AND ebelp = lv_ebelp.
  IF sy-subrc <> 0.
    pv_subrc = 1.  "instance_not_found
    EXIT.
  ENDIF.

  CALL FUNCTION 'CUXI_GET_SINGLE_CONFIGURATION'
    EXPORTING
      i_root_instance               = ls_ekpo-cuobj
    IMPORTING
      e_cfg_head                    = ls_cfg_head
      es_profile                    = ls_profile
      et_return                     = pv_et_return
    TABLES
      e_tab_instances                = lt_instances
      e_tab_part_of                  = lt_part_of
      e_tab_values                   = lt_values
      e_tab_var_keys                 = lt_var_keys
    EXCEPTIONS
      invalid_instance               = 1
      instance_is_a_classification   = 2
      OTHERS                         = 3.

  CASE sy-subrc.
    WHEN 1.
      pv_subrc = 1.  "instance_not_found
      EXIT.
    WHEN 2.
      pv_subrc = 3.  "instance_is_a_classification
      EXIT.
    WHEN 3.
      pv_subrc = 2.  "internal_error
      EXIT.
  ENDCASE.

  CLEAR: l_cuobj, ls_instances.
  READ TABLE lt_instances INTO ls_instances INDEX 1.
  SELECT cuobj INTO l_cuobj
               FROM inob WHERE klart = ls_instances-class_type
                           AND obtab = ls_instances-obj_type
                           AND objek = ls_instances-obj_key.
    EXIT.
  ENDSELECT.
  SELECT clint INTO TABLE lt_clint
               FROM kssk WHERE objek = l_cuobj
                           AND mafid = 'O'
                           AND klart = ls_instances-class_type.
  SELECT * INTO TABLE lt_ksml
           FROM ksml FOR ALL ENTRIES IN lt_clint
           WHERE clint = lt_clint-clint.

  LOOP AT lt_values INTO ls_values.

*-[성능개선] CABN/CABNT 캐시조회
    READ TABLE gt_cabn_buf INTO ls_cabn_buf
         WITH TABLE KEY atnam = ls_values-charc.
    IF sy-subrc = 0.
      l_atinn             = ls_cabn_buf-atinn.
      ls_values-charc_txt = ls_cabn_buf-atbez.
    ELSE.
      CLEAR l_atinn.
      SELECT atinn INTO l_atinn
                   FROM cabn WHERE atnam = ls_values-charc.
        EXIT.
      ENDSELECT.
      CLEAR ls_values-charc_txt.
      SELECT SINGLE atbez INTO ls_values-charc_txt
                          FROM cabnt WHERE atinn = l_atinn.

      ls_cabn_buf-atnam = ls_values-charc.
      ls_cabn_buf-atinn = l_atinn.
      ls_cabn_buf-atbez = ls_values-charc_txt.
      INSERT ls_cabn_buf INTO TABLE gt_cabn_buf.
    ENDIF.

    CLEAR lt_ksml.
    READ TABLE lt_ksml WITH KEY imerk = l_atinn.
    IF sy-subrc = 0.

*-[성능개선] CAWN/CAWNT 캐시조회
      READ TABLE gt_cawn_buf INTO ls_cawn_buf
           WITH TABLE KEY atinn = l_atinn atwrt = ls_values-value.
      IF sy-subrc = 0.
        ls_values-value_txt = ls_cawn_buf-atwtb.
      ELSE.
        CLEAR ls_values-value_txt.
        SELECT b~atwtb INTO ls_values-value_txt
               FROM cawn AS a INNER JOIN cawnt AS b
                 ON a~atinn = b~atinn
                AND a~atzhl = b~atzhl
              WHERE a~atinn = lt_ksml-imerk
                AND a~atwrt = ls_values-value
                AND b~spras = sy-langu.
          EXIT.
        ENDSELECT.

        ls_cawn_buf-atinn = l_atinn.
        ls_cawn_buf-atwrt = ls_values-value.
        ls_cawn_buf-atwtb = ls_values-value_txt.
        INSERT ls_cawn_buf INTO TABLE gt_cawn_buf.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING ls_values TO ls_e1cuval.
    APPEND ls_e1cuval TO pt_e1cuval.
  ENDLOOP.

ENDFORM.                    " ZMM_EKPO_SPEC_GET_CACHED


*&---------------------------------------------------------------------*
*& Form Z_LE_GET_CHARACTERISTIC_CACHED
*&---------------------------------------------------------------------*
*  Z_LE_GET_CHARACTERISTIC 원본과 로직 100% 동일 + CABN/CABNT/CAWN
*  캐시버퍼. ZGTMM_IF_O_PO_ER 전용. 공용 FM은 그대로 존재.
*  FLTP_TO_CHAR_CONVERSION은 재구현하지 않고 원본 함수그룹(SAPLZLE001)
*  의 진짜 FORM을 그대로 외부호출함 - 스텁 리스크 없음.
*&---------------------------------------------------------------------*
FORM z_le_get_characteristic_cached
  TABLES pt_list STRUCTURE zles001
  USING    pv_vbeln  LIKE vbap-vbeln
           pv_posnr  LIKE vbap-posnr
           pv_object LIKE vbap-matnr
           pv_werks  LIKE vbap-werks
  CHANGING pv_subrc TYPE sy-subrc.

  CLEAR pv_subrc.

  DATA: lt_e1cuval        TYPE TABLE OF e1cuval.
  DATA: wa_e1cuval        TYPE e1cuval.
  DATA: ls_cfg_head   LIKE cuxt_cucfg_s,
        ls_instances  LIKE cuxt_cuins_s,
        ls_values     LIKE cuxt_cuval_s,
        ls_e1cucfg    LIKE e1cucfg,
        ls_e1cuins    LIKE e1cuins,
        ls_e1cuval    LIKE e1cuval,
        ls_profile    LIKE e1cucom,
        ls_vbap       LIKE vbap,
        l_cuobj       LIKE inob-cuobj,
        l_atinn       LIKE cabn-atinn,
        lv_et_return  TYPE bapiret2_t.

  DATA: lt_instances  LIKE cuxt_cuins_s OCCURS 0,
        lt_part_of    LIKE cuxt_cuprt_s OCCURS 0,
        lt_values     LIKE cuxt_cuval_s OCCURS 0,
        lt_var_keys   LIKE cuxt_cuvk_s  OCCURS 0,
        lt_ksml       LIKE ksml         OCCURS 0 WITH HEADER LINE,
        BEGIN OF lt_clint OCCURS 0,
          clint  LIKE kssk-clint,
        END OF lt_clint.
  DATA: lt_cuib       LIKE cuib_cuobj_s OCCURS 0 WITH HEADER LINE.

*-[성능개선] CABN/CABNT/CAWN+CAWNT 캐시버퍼 (내부세션 유지)
  STATICS : gt_cabn_buf2 TYPE HASHED TABLE OF ty_cabn_buf
                         WITH UNIQUE KEY atnam,
            gt_cawn_buf2 TYPE HASHED TABLE OF ty_cawn_buf
                         WITH UNIQUE KEY atinn atwrt.

  DATA : ls_cabn_buf TYPE ty_cabn_buf,
         ls_cawn_buf TYPE ty_cawn_buf.

  REFRESH lt_e1cuval.

  CLEAR ls_vbap.
  SELECT SINGLE cuobj INTO CORRESPONDING FIELDS OF ls_vbap
                            FROM vbap WHERE vbeln = pv_vbeln
                                        AND posnr = pv_posnr.
  IF sy-subrc <> 0.
    pv_subrc = 1.  "instance_not_found
    EXIT.
  ENDIF.

  REFRESH lt_cuib. CLEAR lt_cuib.
  lt_cuib-instance = ls_vbap-cuobj.
  APPEND lt_cuib.
  CALL FUNCTION 'CUCB_INITIALIZER'
    EXPORTING
      it_instances = lt_cuib[].

  CALL FUNCTION 'CUXI_GET_SINGLE_CONFIGURATION'
    EXPORTING
      i_root_instance               = ls_vbap-cuobj
    IMPORTING
      e_cfg_head                    = ls_cfg_head
      es_profile                    = ls_profile
      et_return                     = lv_et_return
    TABLES
      e_tab_instances                = lt_instances
      e_tab_part_of                  = lt_part_of
      e_tab_values                   = lt_values
      e_tab_var_keys                 = lt_var_keys
    EXCEPTIONS
      invalid_instance               = 1
      no_root_instance               = 2
      instance_is_a_classification   = 3
      internal_error                 = 4
      no_profile_found               = 5
      invalid_data                   = 6
      OTHERS                         = 7.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        pv_subrc = 1.  "instance_not_found
      WHEN 3.
        pv_subrc = 2.  "instance_is_a_classification
      WHEN OTHERS.
        pv_subrc = 3.  "invalid_data
    ENDCASE.
    EXIT.
  ENDIF.

  CLEAR: l_cuobj, ls_instances.
  READ TABLE lt_instances INTO ls_instances INDEX 1.

  SELECT cuobj INTO l_cuobj
               FROM inob UP TO 1 ROWS
              WHERE klart = ls_instances-class_type
                AND obtab = ls_instances-obj_type
                AND objek = ls_instances-obj_key.
  ENDSELECT.

  SELECT clint INTO TABLE lt_clint
               FROM kssk
              WHERE objek = l_cuobj
                AND mafid = 'O'
                AND klart = ls_instances-class_type.

  SELECT * INTO TABLE lt_ksml
           FROM ksml FOR ALL ENTRIES IN lt_clint
          WHERE clint = lt_clint-clint.

  LOOP AT lt_values INTO ls_values.

*-[성능개선] CABN/CABNT 캐시조회
    READ TABLE gt_cabn_buf2 INTO ls_cabn_buf
         WITH TABLE KEY atnam = ls_values-charc.
    IF sy-subrc = 0.
      l_atinn             = ls_cabn_buf-atinn.
      ls_values-charc_txt = ls_cabn_buf-atbez.
    ELSE.
      CLEAR l_atinn.
      SELECT atinn INTO l_atinn
                   FROM cabn UP TO 1 ROWS
                  WHERE atnam = ls_values-charc.
      ENDSELECT.

      CLEAR ls_values-charc_txt.
      SELECT SINGLE atbez INTO ls_values-charc_txt
                          FROM cabnt
                         WHERE atinn = l_atinn.

      ls_cabn_buf-atnam = ls_values-charc.
      ls_cabn_buf-atinn = l_atinn.
      ls_cabn_buf-atbez = ls_values-charc_txt.
      INSERT ls_cabn_buf INTO TABLE gt_cabn_buf2.
    ENDIF.

    CLEAR lt_ksml.
    READ TABLE lt_ksml WITH KEY imerk = l_atinn.

    IF sy-subrc = 0.

*-[성능개선] CAWN/CAWNT 캐시조회
      READ TABLE gt_cawn_buf2 INTO ls_cawn_buf
           WITH TABLE KEY atinn = l_atinn atwrt = ls_values-value.
      IF sy-subrc = 0.
        ls_values-value_txt = ls_cawn_buf-atwtb.
      ELSE.
        CLEAR ls_values-value_txt.
        SELECT b~atwtb INTO ls_values-value_txt
               FROM cawn AS a INNER JOIN cawnt AS b
                 ON a~atinn = b~atinn
                AND a~atzhl = b~atzhl
              WHERE a~atinn = lt_ksml-imerk
                AND a~atwrt = ls_values-value
                AND b~spras = sy-langu.
          EXIT.
        ENDSELECT.

        ls_cawn_buf-atinn = l_atinn.
        ls_cawn_buf-atwrt = ls_values-value.
        ls_cawn_buf-atwtb = ls_values-value_txt.
        INSERT ls_cawn_buf INTO TABLE gt_cawn_buf2.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING ls_values TO ls_e1cuval.

    APPEND ls_e1cuval TO lt_e1cuval.

  ENDLOOP.

*/ CLASS LIST (원본과 동일 - 공용 FM 그대로 호출)
  DATA: lt_feature TYPE TABLE OF clx2f.
  DATA: wa_feature TYPE clx2f.
  DATA: lt_value   TYPE TABLE OF clx2v.
  DATA: wa_value   TYPE clx2v.

  CALL FUNCTION 'Z_LE_GET_CLASS_LIST'
    EXPORTING
      i_object         = pv_object
      i_werks          = pv_werks
    TABLES
      gt_feature       = lt_feature
      gt_value         = lt_value.

*/
  DATA: wa_list         TYPE zles001.
  DATA: lv_atwrt         TYPE atwrt,
        lv_fltp_value    TYPE atflv.

  SORT lt_e1cuval  BY charc.
  SORT lt_feature  BY atnam.
  SORT lt_value    BY atinn atwrt.

  LOOP AT lt_feature INTO wa_feature.
    CLEAR: wa_list, wa_e1cuval, wa_value.

    MOVE-CORRESPONDING wa_feature TO wa_list.
    wa_list-vbeln = pv_vbeln.
    wa_list-posnr = pv_posnr.
* 영업문서 입력정보 유무 체크.
    READ TABLE lt_e1cuval
                 WITH KEY charc = wa_feature-atnam
                 BINARY SEARCH
            INTO wa_e1cuval.
    IF sy-subrc = 0.
      CASE wa_feature-atfor.
        WHEN 'CHAR'.
          READ TABLE lt_value WITH KEY atinn = wa_feature-atinn
                                       atwrt = wa_e1cuval-value
                        BINARY SEARCH
                        INTO wa_value.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING wa_value TO wa_list.
          ELSE.
            wa_list-atwrt = wa_e1cuval-value.
          ENDIF.
        WHEN 'NUM'.
          lv_fltp_value = wa_e1cuval-value.

*         [원본 그대로] SAPLZLE001의 진짜 FLTP_TO_CHAR_CONVERSION을
*         외부호출. 재구현/스텁 아님 - 원본과 100% 동일 동작 보장.
*         *** 실제 함수그룹 메인프로그램명이 SAPLZLE001이 맞는지
*         *** SE37 > Z_LE_GET_CHARACTERISTIC > 속성 탭에서 반드시 확인!
          PERFORM fltp_to_char_conversion(saplzle001)
                                    USING wa_feature-anzdz
                                          lv_fltp_value
                                 CHANGING lv_atwrt.
          wa_list-atwrt = lv_atwrt.
          wa_list-atflv = wa_e1cuval-value.
          wa_list-atwtb = wa_feature-msehi.
        WHEN OTHERS.
          wa_list-atwrt = wa_e1cuval-value.
          wa_list-atwtb = wa_feature-msehi.
      ENDCASE.
      APPEND wa_list TO pt_list.
    ELSE.
      IF wa_feature-atfor = 'NUM'.
        wa_list-atwtb = wa_feature-msehi.
      ENDIF.
      APPEND wa_list TO pt_list.
    ENDIF.
  ENDLOOP.

  SORT pt_list.

ENDFORM.                    " Z_LE_GET_CHARACTERISTIC_CACHED
*----------------------------------------------------------------------*
* [기존 GET_CHARACTERISTIC 수정본]
* 원본 대비 바뀐 부분: CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC' 블록만
* PERFORM Z_LE_GET_CHARACTERISTIC_CACHED 로 교체.
*----------------------------------------------------------------------*
FORM get_characteristic  TABLES   t_char
                         USING    p_vbeln
                                  p_posnr
                                  p_werks
                                  p_matnr.

  DATA:
    lv_vbeln TYPE vbap-vbeln,
    lv_posnr TYPE vbap-posnr,
    lv_matnr TYPE vbap-matnr,
    lv_werks TYPE vbap-werks,
    lv_subrc TYPE sy-subrc.          "*** 추가

  lv_vbeln = p_vbeln.
  lv_posnr = p_posnr.
  lv_matnr = p_matnr.
  lv_werks = p_werks.

  PERFORM z_le_get_characteristic_cached
    TABLES t_char
    USING  lv_vbeln
           lv_posnr
           lv_matnr
           lv_werks
    CHANGING lv_subrc.

  IF lv_subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_CHARACTERISTIC
