*&---------------------------------------------------------------------*
*& Report ZGTMM_GR_RETRY_MES
*& 목적: MES 입고 인터페이스 재처리
*&       1) 조회만 실행 - ZGTMMT9000 기준 대상 리스트를 라벨/품목 단위로 ALV 표시
*&          (성공건은 기존 전표번호 조회, 실패건은 "재처리" 링크 표시, FM 미호출)
*&       2) ALV에서 실패건의 "재처리" 링크를 클릭
*&          -> 해당 행이 속한 ZIFKEY 그룹 단위로 원본 FM 재호출(실입고 발생)
*&
*& [주의] FM(ZGTMM_IF_I_POGR_RCV/ZGTMM_IF_I_DRGR_RCV)은 내부에서 자체
*&        COMMIT WORK를 수행하므로, "재처리" 클릭 즉시 실물 입고가 발생합니다.
*&        반드시 확인 팝업에서 신중히 결정하세요.
*&---------------------------------------------------------------------*
REPORT zgtmmr4331.

TABLES: zgtmmt9000, zgtmmt9420, zgtmmt9422.

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-000.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_pogr RADIOBUTTON GROUP g1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(20) TEXT-p01 FOR FIELD p_pogr.   " PO 입고 라벨
    PARAMETERS p_drgr RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT 40(10) TEXT-p02 FOR FIELD p_drgr.  " DR 입고 라벨
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_fail RADIOBUTTON GROUP g2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(12) TEXT-f01 FOR FIELD p_fail.   " 실패건 라벨
    PARAMETERS p_succ RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT 20(10) TEXT-f02 FOR FIELD p_succ.  " 성공건 라벨
    PARAMETERS p_allz RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT 37(10) TEXT-f03 FOR FIELD p_allz.  " 전체 라벨
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_kgpm RADIOBUTTON GROUP g4 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(15) TEXT-s02 FOR FIELD p_kgom.
    PARAMETERS p_kgom RADIOBUTTON GROUP g4.
    SELECTION-SCREEN COMMENT 21(20) TEXT-s01 FOR FIELD p_kgpm.
  SELECTION-SCREEN END OF LINE.
  SELECT-OPTIONS:
    s_zifkey FOR zgtmmt9000-zifkey,
    s_erdat  FOR zgtmmt9000-erdat DEFAULT sy-datum,
    s_ebeln  FOR zgtmmt9420-ebeln,
    s_delno  FOR zgtmmt9420-delno,
    s_label  FOR zgtmmt9420-labelno,
    s_drlbl  FOR zgtmmt9422-dr_label_no.
  PARAMETERS:
    p_max  TYPE i DEFAULT 10000.
SELECTION-SCREEN END OF BLOCK b1.

TYPES: BEGIN OF ty_result,
         zifkey     TYPE zgtmmt9000-zifkey,
         system_id  TYPE zgtmmt9000-system_id,
         ifdat      TYPE zgtmmt9000-ifdat,
         iftim      TYPE zgtmmt9000-iftim,
         zstat      TYPE zgtmmt9000-zstat,
         retry_txt  TYPE char20,
         ebeln      TYPE ekko-ebeln,
         ebelp      TYPE ekpo-ebelp,
         delno      TYPE zgte_mm_gsrm_delno,
         matnr      TYPE mara-matnr,
         charg      TYPE mch1-charg,
         tagnr      TYPE ztagnr,
         dr_labelno TYPE zgte_mm_mes_dr_labelno,
         labelno    TYPE zgte_mm_gsrm_labelno,
         menge      TYPE mengv13,
         meins      TYPE meins,
         doc_mblnr  TYPE mblnr,
         doc_mjahr  TYPE mjahr,
         cancel_txt TYPE char10,
         cancel_mblnr TYPE mblnr,
         cancel_mjahr TYPE mjahr,
         zo_result  TYPE char2,
         ztype      TYPE bapi_mtype,
         zmessage   TYPE bapi_msg,
       END OF ty_result.

TYPES: BEGIN OF ty_merge,
         dr_labelno TYPE zgte_mm_mes_dr_labelno,
         ebeln      TYPE bstnr,
         ebelp      TYPE ebelp,
         delno      TYPE zgte_mm_gsrm_delno,
         matnr      TYPE matnr,
         charg      TYPE charg_d,
         tagnr      TYPE ztagnr,
         menge      TYPE mengv13,
         meins      TYPE meins,
       END OF ty_merge.

DATA: gt_9000         TYPE STANDARD TABLE OF zgtmmt9000,
      gt_retry_result TYPE STANDARD TABLE OF ty_result,
      gv_zifno        TYPE zgtmmt9000-zifno,
      go_salv         TYPE REF TO cl_salv_table.

*----------------------------------------------------------------------*
* ALV HOTSPOT 클릭 이벤트 핸들러
*----------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_link_click
      FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_link_click.
    IF column = 'RETRY_TXT'.
      PERFORM retry_one_row USING row.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  PERFORM build_result_list.

  IF gt_retry_result IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'I'.
    RETURN.
  ENDIF.

  PERFORM display_alv.

*&---------------------------------------------------------------------*
*& FORM BUILD_RESULT_LIST
*&---------------------------------------------------------------------*
FORM build_result_list.

  CLEAR gt_retry_result.

  DATA: lv_sysid TYPE zgtmmt9000-system_id.                       " ★ 추가
  lv_sysid = COND #( WHEN p_kgpm = abap_true THEN 'KGPM'           " ★ 추가
                      ELSE 'KGOM' ).                                " ★ 추가

  gv_zifno = COND #( WHEN p_pogr = abap_true THEN 'MM00061'
                      ELSE 'MM00035' ).

  DATA: lt_zstat TYPE RANGE OF zgtmmt9000-zstat.
  IF p_fail = abap_true.
    lt_zstat = VALUE #( ( sign = 'I' option = 'EQ' low = 'E' ) ).
  ELSEIF p_succ = abap_true.
    lt_zstat = VALUE #( ( sign = 'I' option = 'EQ' low = 'S' ) ).
  ELSE.
    CLEAR lt_zstat.
  ENDIF.

  SELECT *
    FROM zgtmmt9000
    INTO TABLE @gt_9000
    UP TO @p_max ROWS
    WHERE zifno     = @gv_zifno
      AND system_id = @lv_sysid                                    " ★ 수정: p_sysid → lv_sysid
      AND zstat     IN @lt_zstat
      AND zifkey   IN @s_zifkey
      AND erdat    IN @s_erdat
    ORDER BY erdat DESCENDING, ertim DESCENDING.

  LOOP AT gt_9000 ASSIGNING FIELD-SYMBOL(<fs_9000>).
    IF p_pogr = abap_true.
      PERFORM build_pogr_rows USING <fs_9000> abap_false.
    ELSE.
      PERFORM build_drgr_rows USING <fs_9000> abap_false.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_retry_result ASSIGNING FIELD-SYMBOL(<fs_r>) WHERE zstat = 'E'.
    <fs_r>-retry_txt = '재처리'.
  ENDLOOP.

  PERFORM fill_cancel_info.

  SORT gt_retry_result BY ifdat DESCENDING iftim DESCENDING zifkey DESCENDING.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM FILL_CANCEL_INFO
*& 입고 전표의 취소 이력(ZGTMMT9100: ZGTMM_IF_I_GRREV_RCV [MES] 입고 취소 처리 결과) 표시
*&---------------------------------------------------------------------*
FORM fill_cancel_info.

  DATA lt_docs TYPE STANDARD TABLE OF zgtmmt9100.

  lt_docs = VALUE #( FOR ls_r IN gt_retry_result
                     WHERE ( doc_mblnr IS NOT INITIAL )
                     ( mblnr_i = ls_r-doc_mblnr mjahr_i = ls_r-doc_mjahr ) ).
  SORT lt_docs BY mblnr_i mjahr_i.
  DELETE ADJACENT DUPLICATES FROM lt_docs COMPARING mblnr_i mjahr_i.
  CHECK lt_docs IS NOT INITIAL.

  SELECT mblnr_i, mjahr_i, mblnr_c, mjahr_c
    FROM zgtmmt9100
    FOR ALL ENTRIES IN @lt_docs
    WHERE mblnr_i  = @lt_docs-mblnr_i
      AND mjahr_i  = @lt_docs-mjahr_i
      AND mblnr_c <> @space
    INTO TABLE @DATA(lt_cancel).
  SORT lt_cancel BY mblnr_i mjahr_i.

  LOOP AT gt_retry_result ASSIGNING FIELD-SYMBOL(<fs_c>)
       WHERE doc_mblnr IS NOT INITIAL.
    READ TABLE lt_cancel ASSIGNING FIELD-SYMBOL(<fs_cn>)
         WITH KEY mblnr_i = <fs_c>-doc_mblnr mjahr_i = <fs_c>-doc_mjahr
         BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_c>-cancel_txt   = '취소'.
      <fs_c>-cancel_mblnr = <fs_cn>-mblnr_c.
      <fs_c>-cancel_mjahr = <fs_cn>-mjahr_c.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM BUILD_POGR_ROWS
*& IV_DO_RETRY = 'X' 이면 실제 FM 호출(재처리), 공백이면 조회만
*&---------------------------------------------------------------------*
FORM build_pogr_rows USING is_9000 TYPE zgtmmt9000
                            iv_do_retry TYPE abap_bool.

  DATA lt_it_tab_pogr  TYPE STANDARD TABLE OF zgtmms4005.
  DATA lt_it_tab2_pogr TYPE STANDARD TABLE OF zgtmms4009.
  DATA: lv_zo_result TYPE char2,
        lv_mblnr     TYPE mblnr,
        lv_mjahr     TYPE mjahr,
        lv_ztype     TYPE bapi_mtype,
        lv_zmessage  TYPE bapi_msg.
  CLEAR: lt_it_tab_pogr, lt_it_tab2_pogr,
         lv_zo_result, lv_mblnr, lv_mjahr, lv_ztype, lv_zmessage.

  SELECT *
    FROM zgtmmt9420
    INTO TABLE @DATA(lt_9420)
    WHERE zifkey    = @is_9000-zifkey
      AND system_id = @is_9000-system_id.

  SELECT *
    FROM zgtmmt9424
    INTO TABLE @DATA(lt_9424)
    WHERE zifkey    = @is_9000-zifkey
      AND system_id = @is_9000-system_id.

  DATA(lt_9420_chk) = lt_9420.
  IF s_ebeln IS NOT INITIAL. DELETE lt_9420_chk WHERE ebeln NOT IN s_ebeln. ENDIF.
  IF s_delno IS NOT INITIAL. DELETE lt_9420_chk WHERE delno NOT IN s_delno. ENDIF.
  IF s_label IS NOT INITIAL. DELETE lt_9420_chk WHERE labelno NOT IN s_label. ENDIF.

  DATA(lt_9424_chk) = lt_9424.
  IF s_ebeln IS NOT INITIAL. DELETE lt_9424_chk WHERE ebeln NOT IN s_ebeln. ENDIF.

  IF lt_9420_chk IS INITIAL AND lt_9424_chk IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT lt_9420 ASSIGNING FIELD-SYMBOL(<fs_9420>).
    lt_it_tab_pogr = VALUE #( BASE lt_it_tab_pogr
      ( ebeln = <fs_9420>-ebeln ebelp = <fs_9420>-ebelp
        delno = <fs_9420>-delno delitem = <fs_9420>-delitem
        werks = <fs_9420>-werks lgort = <fs_9420>-lgort
        matnr = <fs_9420>-matnr budat = <fs_9420>-budat
        menge = <fs_9420>-menge meins = <fs_9420>-meins
        charg = <fs_9420>-charg licha = <fs_9420>-licha
        hsdat = <fs_9420>-hsdat tagnr = <fs_9420>-tagnr
        pstyp = <fs_9420>-pstyp seqno = <fs_9420>-seqno
        labelno = <fs_9420>-labelno labelitem = <fs_9420>-labelitem )
    ).
  ENDLOOP.

  LOOP AT lt_9424 ASSIGNING FIELD-SYMBOL(<fs_9424>).
    lt_it_tab2_pogr = VALUE #( BASE lt_it_tab2_pogr
      ( ebeln = <fs_9424>-ebeln ebelp = <fs_9424>-ebelp
        werks = <fs_9424>-werks lgort = <fs_9424>-lgort
        matnr = <fs_9424>-matnr budat = <fs_9424>-budat
        menge = <fs_9424>-menge meins = <fs_9424>-meins
        charg = <fs_9424>-charg tagnr = <fs_9424>-tagnr
        pstyp = <fs_9424>-pstyp )
    ).
  ENDLOOP.

  "성공건 - 기존 전표번호만 조회
  IF is_9000-zstat = 'S'.
    LOOP AT lt_it_tab_pogr ASSIGNING FIELD-SYMBOL(<fs_tp>).
      SELECT SINGLE mblnr, mjahr FROM zgtmmt9421
        INTO (@DATA(lv_doc_m1), @DATA(lv_doc_j1))
        WHERE zifkey = @is_9000-zifkey AND system_id = @is_9000-system_id
          AND ebeln = @<fs_tp>-ebeln AND ebelp = @<fs_tp>-ebelp.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_tp>-ebeln ebelp = <fs_tp>-ebelp delno = <fs_tp>-delno
          matnr = <fs_tp>-matnr charg = <fs_tp>-charg tagnr = <fs_tp>-tagnr
          labelno = <fs_tp>-labelno menge = <fs_tp>-menge meins = <fs_tp>-meins
          doc_mblnr = lv_doc_m1 doc_mjahr = lv_doc_j1 )
      ).
    ENDLOOP.
    LOOP AT lt_it_tab2_pogr ASSIGNING FIELD-SYMBOL(<fs_tp2>).
      SELECT SINGLE mblnr, mjahr FROM zgtmmt9421
        INTO (@DATA(lv_doc_m2), @DATA(lv_doc_j2))
        WHERE zifkey = @is_9000-zifkey AND system_id = @is_9000-system_id
          AND ebeln = @<fs_tp2>-ebeln AND ebelp = @<fs_tp2>-ebelp.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_tp2>-ebeln ebelp = <fs_tp2>-ebelp
          matnr = <fs_tp2>-matnr charg = <fs_tp2>-charg tagnr = <fs_tp2>-tagnr
          menge = <fs_tp2>-menge meins = <fs_tp2>-meins
          doc_mblnr = lv_doc_m2 doc_mjahr = lv_doc_j2 )
      ).
    ENDLOOP.
    RETURN.
  ENDIF.

  "실패건 - 조회만(IV_DO_RETRY 공백)
  IF iv_do_retry = abap_false.
    LOOP AT lt_it_tab_pogr ASSIGNING <fs_tp>.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_tp>-ebeln ebelp = <fs_tp>-ebelp delno = <fs_tp>-delno
          matnr = <fs_tp>-matnr charg = <fs_tp>-charg tagnr = <fs_tp>-tagnr
          labelno = <fs_tp>-labelno menge = <fs_tp>-menge meins = <fs_tp>-meins
          zmessage = is_9000-message )
      ).
    ENDLOOP.
    LOOP AT lt_it_tab2_pogr ASSIGNING <fs_tp2>.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_tp2>-ebeln ebelp = <fs_tp2>-ebelp
          matnr = <fs_tp2>-matnr charg = <fs_tp2>-charg tagnr = <fs_tp2>-tagnr
          menge = <fs_tp2>-menge meins = <fs_tp2>-meins
          zmessage = is_9000-message )
      ).
    ENDLOOP.
    RETURN.
  ENDIF.

  "실제 재처리
  CALL FUNCTION 'ZGTMM_IF_I_POGR_RCV'
    EXPORTING
      i_system_id = is_9000-system_id
    IMPORTING
      zo_result   = lv_zo_result
      mblnr       = lv_mblnr
      mjahr       = lv_mjahr
      ztype       = lv_ztype
      zmessage    = lv_zmessage
    TABLES
      it_tab      = lt_it_tab_pogr
      it_tab2     = lt_it_tab2_pogr
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    lv_zmessage = |FM 호출 예외 SY-SUBRC={ sy-subrc }|.
  ENDIF.

  LOOP AT lt_it_tab_pogr ASSIGNING <fs_tp>.
    gt_retry_result = VALUE #( BASE gt_retry_result
      ( zifkey = is_9000-zifkey system_id = is_9000-system_id
        ifdat = is_9000-ifdat iftim = is_9000-iftim
        zstat = COND #( WHEN lv_zo_result = '00' THEN 'S' ELSE 'E' )
        ebeln = <fs_tp>-ebeln ebelp = <fs_tp>-ebelp delno = <fs_tp>-delno
        matnr = <fs_tp>-matnr charg = <fs_tp>-charg tagnr = <fs_tp>-tagnr
        labelno = <fs_tp>-labelno menge = <fs_tp>-menge meins = <fs_tp>-meins
        doc_mblnr = lv_mblnr doc_mjahr = lv_mjahr
        zo_result = lv_zo_result ztype = lv_ztype zmessage = lv_zmessage )
    ).
  ENDLOOP.
  LOOP AT lt_it_tab2_pogr ASSIGNING <fs_tp2>.
    gt_retry_result = VALUE #( BASE gt_retry_result
      ( zifkey = is_9000-zifkey system_id = is_9000-system_id
        ifdat = is_9000-ifdat iftim = is_9000-iftim
        zstat = COND #( WHEN lv_zo_result = '00' THEN 'S' ELSE 'E' )
        ebeln = <fs_tp2>-ebeln ebelp = <fs_tp2>-ebelp
        matnr = <fs_tp2>-matnr charg = <fs_tp2>-charg tagnr = <fs_tp2>-tagnr
        menge = <fs_tp2>-menge meins = <fs_tp2>-meins
        doc_mblnr = lv_mblnr doc_mjahr = lv_mjahr
        zo_result = lv_zo_result ztype = lv_ztype zmessage = lv_zmessage )
    ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM BUILD_DRGR_ROWS
*&---------------------------------------------------------------------*
FORM build_drgr_rows USING is_9000 TYPE zgtmmt9000
                            iv_do_retry TYPE abap_bool.

  DATA lt_it_tab_drgr  TYPE STANDARD TABLE OF zgtmms4012.
  DATA lt_it_tab2_drgr TYPE STANDARD TABLE OF zgtmms4014.
  DATA lt_merge TYPE STANDARD TABLE OF ty_merge.
  DATA: lv_zo_result TYPE char2,
        lv_mblnr     TYPE mblnr,
        lv_mjahr     TYPE mjahr,
        lv_ztype     TYPE bapi_mtype,
        lv_zmessage  TYPE bapi_msg.
  CLEAR: lt_it_tab_drgr, lt_it_tab2_drgr, lt_merge,
         lv_zo_result, lv_mblnr, lv_mjahr, lv_ztype, lv_zmessage.

  SELECT *
    FROM zgtmmt9422
    INTO TABLE @DATA(lt_9422)
    WHERE zifkey    = @is_9000-zifkey
      AND system_id = @is_9000-system_id.

  SELECT *
    FROM zgtmmt9425
    INTO TABLE @DATA(lt_9425)
    WHERE zifkey    = @is_9000-zifkey
      AND system_id = @is_9000-system_id.

  DATA(lt_9422_chk) = lt_9422.
  IF s_ebeln IS NOT INITIAL. DELETE lt_9422_chk WHERE ebeln NOT IN s_ebeln. ENDIF.
  IF s_drlbl IS NOT INITIAL. DELETE lt_9422_chk WHERE dr_label_no NOT IN s_drlbl. ENDIF.

  DATA(lt_9425_chk) = lt_9425.
  IF s_ebeln IS NOT INITIAL. DELETE lt_9425_chk WHERE ebeln NOT IN s_ebeln. ENDIF.
  IF s_delno IS NOT INITIAL. DELETE lt_9425_chk WHERE delno NOT IN s_delno. ENDIF.
  IF s_drlbl IS NOT INITIAL. DELETE lt_9425_chk WHERE dr_label_no NOT IN s_drlbl. ENDIF.

  IF lt_9422_chk IS INITIAL AND lt_9425_chk IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT lt_9422 ASSIGNING FIELD-SYMBOL(<fs_9422>).
    lt_it_tab_drgr = VALUE #( BASE lt_it_tab_drgr
      ( dr_labelno = <fs_9422>-dr_label_no ebeln = <fs_9422>-ebeln ebelp = <fs_9422>-ebelp
        werks = <fs_9422>-werks lgort = <fs_9422>-lgort matnr = <fs_9422>-matnr
        budat = <fs_9422>-budat menge = <fs_9422>-menge meins = <fs_9422>-meins
        charg = <fs_9422>-charg tagnr = <fs_9422>-tagnr pstyp = <fs_9422>-pstyp )
    ).
  ENDLOOP.

  LOOP AT lt_9425 ASSIGNING FIELD-SYMBOL(<fs_9425>).
    lt_it_tab2_drgr = VALUE #( BASE lt_it_tab2_drgr
      ( delno = <fs_9425>-delno delitem = <fs_9425>-delitem
        ebeln = <fs_9425>-ebeln ebelp = <fs_9425>-ebelp
        werks = <fs_9425>-werks lgort = <fs_9425>-lgort matnr = <fs_9425>-matnr
        menge = <fs_9425>-menge meins = <fs_9425>-meins
        dr_labelno = <fs_9425>-dr_label_no )
    ).
  ENDLOOP.

  LOOP AT lt_it_tab_drgr ASSIGNING FIELD-SYMBOL(<fs_m1>).
    READ TABLE lt_it_tab2_drgr ASSIGNING FIELD-SYMBOL(<fs_m2>)
      WITH KEY dr_labelno = <fs_m1>-dr_labelno
               ebeln      = <fs_m1>-ebeln
               ebelp      = <fs_m1>-ebelp.
    lt_merge = VALUE #( BASE lt_merge
      ( dr_labelno = <fs_m1>-dr_labelno ebeln = <fs_m1>-ebeln ebelp = <fs_m1>-ebelp
        delno      = COND #( WHEN sy-subrc = 0 THEN <fs_m2>-delno ELSE space )
        matnr = <fs_m1>-matnr charg = <fs_m1>-charg tagnr = <fs_m1>-tagnr
        menge = <fs_m1>-menge meins = <fs_m1>-meins )
    ).
  ENDLOOP.

  LOOP AT lt_it_tab2_drgr ASSIGNING <fs_m2>.
    READ TABLE lt_it_tab_drgr TRANSPORTING NO FIELDS
      WITH KEY dr_labelno = <fs_m2>-dr_labelno
               ebeln      = <fs_m2>-ebeln
               ebelp      = <fs_m2>-ebelp.
    CHECK sy-subrc <> 0.
    lt_merge = VALUE #( BASE lt_merge
      ( dr_labelno = <fs_m2>-dr_labelno ebeln = <fs_m2>-ebeln ebelp = <fs_m2>-ebelp
        delno = <fs_m2>-delno matnr = <fs_m2>-matnr
        menge = <fs_m2>-menge meins = <fs_m2>-meins )
    ).
  ENDLOOP.

  "성공건 - 기존 전표번호만 조회
  IF is_9000-zstat = 'S'.
    LOOP AT lt_merge ASSIGNING FIELD-SYMBOL(<fs_mg>).
      SELECT SINGLE mblnr, mjahr FROM zgtmmt9423
        INTO (@DATA(lv_doc_m3), @DATA(lv_doc_j3))
        WHERE zifkey = @is_9000-zifkey AND system_id = @is_9000-system_id
          AND ebeln = @<fs_mg>-ebeln AND ebelp = @<fs_mg>-ebelp
          AND dr_label_no = @<fs_mg>-dr_labelno.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_mg>-ebeln ebelp = <fs_mg>-ebelp delno = <fs_mg>-delno
          matnr = <fs_mg>-matnr charg = <fs_mg>-charg tagnr = <fs_mg>-tagnr
          dr_labelno = <fs_mg>-dr_labelno menge = <fs_mg>-menge meins = <fs_mg>-meins
          doc_mblnr = lv_doc_m3 doc_mjahr = lv_doc_j3 )
      ).
    ENDLOOP.
    RETURN.
  ENDIF.

  "실패건 - 조회만(IV_DO_RETRY 공백)
  IF iv_do_retry = abap_false.
    LOOP AT lt_merge ASSIGNING <fs_mg>.
      gt_retry_result = VALUE #( BASE gt_retry_result
        ( zifkey = is_9000-zifkey system_id = is_9000-system_id
          ifdat = is_9000-ifdat iftim = is_9000-iftim zstat = is_9000-zstat
          ebeln = <fs_mg>-ebeln ebelp = <fs_mg>-ebelp delno = <fs_mg>-delno
          matnr = <fs_mg>-matnr charg = <fs_mg>-charg tagnr = <fs_mg>-tagnr
          dr_labelno = <fs_mg>-dr_labelno menge = <fs_mg>-menge meins = <fs_mg>-meins
          zmessage = is_9000-message )
      ).
    ENDLOOP.
    RETURN.
  ENDIF.

  "실제 재처리
  CALL FUNCTION 'ZGTMM_IF_I_DRGR_RCV'
    EXPORTING
      i_system_id = is_9000-system_id
    IMPORTING
      zo_result   = lv_zo_result
      mblnr       = lv_mblnr
      mjahr       = lv_mjahr
      ztype       = lv_ztype
      zmessage    = lv_zmessage
    TABLES
      it_tab      = lt_it_tab_drgr
      it_tab2     = lt_it_tab2_drgr
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    lv_zmessage = |FM 호출 예외 SY-SUBRC={ sy-subrc }|.
  ENDIF.

  LOOP AT lt_merge ASSIGNING <fs_mg>.
    gt_retry_result = VALUE #( BASE gt_retry_result
      ( zifkey = is_9000-zifkey system_id = is_9000-system_id
        ifdat = is_9000-ifdat iftim = is_9000-iftim
        zstat = COND #( WHEN lv_zo_result = '00' THEN 'S' ELSE 'E' )
        ebeln = <fs_mg>-ebeln ebelp = <fs_mg>-ebelp delno = <fs_mg>-delno
        matnr = <fs_mg>-matnr charg = <fs_mg>-charg tagnr = <fs_mg>-tagnr
        dr_labelno = <fs_mg>-dr_labelno menge = <fs_mg>-menge meins = <fs_mg>-meins
        doc_mblnr = lv_mblnr doc_mjahr = lv_mjahr
        zo_result = lv_zo_result ztype = lv_ztype zmessage = lv_zmessage )
    ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM RETRY_ONE_ROW
*& HOTSPOT 클릭된 1개 행의 ZIFKEY만 재처리
*&---------------------------------------------------------------------*
FORM retry_one_row USING iv_row TYPE i.

  READ TABLE gt_retry_result INTO DATA(ls_sel) INDEX iv_row.
  CHECK sy-subrc = 0.
  CHECK ls_sel-zstat = 'E'.

  DATA: lv_answer TYPE c LENGTH 1.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = '재처리 확인'
      text_question  = |ZIFKEY { ls_sel-zifkey } 건을 재처리합니다. 실제 입고가 발생합니다. 계속하시겠습니까?|
      text_button_1  = '예'
      text_button_2  = '아니오'
      default_button = '2'
    IMPORTING
      answer         = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.

  DELETE gt_retry_result WHERE zifkey = ls_sel-zifkey.

  READ TABLE gt_9000 INTO DATA(ls_9000) WITH KEY zifkey = ls_sel-zifkey.
  CHECK sy-subrc = 0.

  IF p_pogr = abap_true.
    PERFORM build_pogr_rows USING ls_9000 abap_true.
  ELSE.
    PERFORM build_drgr_rows USING ls_9000 abap_true.
  ENDIF.

  LOOP AT gt_retry_result ASSIGNING FIELD-SYMBOL(<fs_r>) WHERE zstat = 'E'.
    <fs_r>-retry_txt = '재처리'.
  ENDLOOP.

  PERFORM fill_cancel_info.

  SORT gt_retry_result BY ifdat DESCENDING iftim DESCENDING zifkey DESCENDING.

  go_salv->refresh( ).

  MESSAGE |ZIFKEY { ls_sel-zifkey } 재처리를 완료했습니다.| TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv.

  DATA: lo_columns TYPE REF TO cl_salv_columns_table,
        lo_col     TYPE REF TO cl_salv_column_table,
        lo_col_txt TYPE REF TO cl_salv_column_table,
        lo_events  TYPE REF TO cl_salv_events_table,
        lo_handler TYPE REF TO lcl_handler.

  CREATE OBJECT lo_handler.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = go_salv
        CHANGING  t_table      = gt_retry_result ).

      go_salv->get_functions( )->set_all( abap_true ).
      go_salv->get_columns( )->set_optimize( abap_true ).

      lo_columns = go_salv->get_columns( ).
      lo_col ?= lo_columns->get_column( 'ZIFKEY' ).      lo_col->set_short_text( 'ZIFKEY' ).
      lo_col ?= lo_columns->get_column( 'IFDAT' ).       lo_col->set_short_text( '수신일자' ).
      lo_col ?= lo_columns->get_column( 'IFTIM' ).       lo_col->set_short_text( '수신시간' ).
      lo_col ?= lo_columns->get_column( 'ZSTAT' ).       lo_col->set_short_text( '상태' ).
      lo_col_txt ?= lo_columns->get_column( 'RETRY_TXT' ).
      lo_col_txt->set_short_text( '재처리' ).
      lo_col_txt->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lo_col ?= lo_columns->get_column( 'EBELN' ).       lo_col->set_short_text( 'PO번호' ).
      lo_col ?= lo_columns->get_column( 'EBELP' ).       lo_col->set_short_text( 'PO품목' ).
      lo_col ?= lo_columns->get_column( 'DELNO' ).       lo_col->set_short_text( '납품서번호' ).
      lo_col ?= lo_columns->get_column( 'MATNR' ).       lo_col->set_short_text( '자재' ).
      lo_col ?= lo_columns->get_column( 'CHARG' ).       lo_col->set_short_text( '배치' ).
      lo_col ?= lo_columns->get_column( 'TAGNR' ).       lo_col->set_short_text( '꼬리표' ).
      lo_col ?= lo_columns->get_column( 'DR_LABELNO' ).  lo_col->set_short_text( '드럼라벨' ).
      lo_col ?= lo_columns->get_column( 'LABELNO' ).     lo_col->set_short_text( '라벨번호' ).
      lo_col ?= lo_columns->get_column( 'MENGE' ).       lo_col->set_short_text( '수량' ).
      lo_col ?= lo_columns->get_column( 'MEINS' ).       lo_col->set_short_text( '단위' ).
      lo_col ?= lo_columns->get_column( 'DOC_MBLNR' ).   lo_col->set_short_text( '전표번호' ).
      lo_col ?= lo_columns->get_column( 'DOC_MJAHR' ).   lo_col->set_short_text( '전표연도' ).
      lo_col ?= lo_columns->get_column( 'CANCEL_TXT' ).  lo_col->set_short_text( '취소여부' ).
      lo_col ?= lo_columns->get_column( 'CANCEL_MBLNR' ). lo_col->set_short_text( '취소전표' ).
      lo_col ?= lo_columns->get_column( 'CANCEL_MJAHR' ). lo_col->set_short_text( '취소연도' ).
      lo_col ?= lo_columns->get_column( 'ZO_RESULT' ).   lo_col->set_short_text( '재처리결과' ).
      lo_col ?= lo_columns->get_column( 'ZTYPE' ).       lo_col->set_short_text( '메시지TYPE' ).
      lo_col ?= lo_columns->get_column( 'ZMESSAGE' ).    lo_col->set_short_text( '메시지' ).

      lo_events = go_salv->get_event( ).
      SET HANDLER lo_handler->on_link_click FOR lo_events.

      go_salv->display( ).
    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
