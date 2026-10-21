FUNCTION zgtmm_if_i_scgr_rcv.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_HEAD STRUCTURE  ZGTMMSIF0012
*"      IT_ITEM STRUCTURE  ZGTMMSIF0013
*"      OT_HEAD STRUCTURE  ZGTMMSIF0018
*"      OT_ITEM STRUCTURE  ZGTMMSIF0020 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_SCGR_RCV
*& 프로그램 명 : 외주 가공 입고 및 투입 정보 수신
*& 개요   : 외주 가공 입고 및 투입 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.08
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.06.10
*& 수정자  : ZGSIDEV03
*& 수정개요: 구미 물자 창고 WMS 도입
*&---------------------------------------------------------------------*

  gv_system_id = i_system_id.
  PERFORM set_com_log USING 'S' 'MM00008' ' ' ' '.

  CLEAR : gt_i12[], gt_i13[], gt_i18[], gt_i20[].

  gt_i12[] = it_head[].
  gt_i13[] = it_item[].
  SORT gt_i12 BY vbeln.
  SORT gt_i13 BY vbeln posnr ebeln ebelp.

  PERFORM set_908x_log.


  PERFORM calculate_com_qty.        "구성품 발췌 및 구성품의 소요량 계산
  PERFORM get_vendor_batch_info.    " 구성품 공급업체 재고수량 발췌
  PERFORM distribute_vendor_batch.  " 공급업체 재고수량 선입선출 로직

*- Conversion_exit_alpha_input
  PERFORM conversion_input_m04.

* AS-IS PWC 로직
*  PERFORM get_lips.

  "입고 처리
  PERFORM run_scgr_rcv.

  ot_head[] = gt_i18[].
  ot_item[] = gt_i20[]. "추가(SJM 25.06.10)

  PERFORM rtn_rst_msg TABLES gt_i18.

  PERFORM set_eai_msg USING gv_zstat CHANGING zo_result
                                              zo_message.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_908X_LOG
*&---------------------------------------------------------------------*
FORM set_908x_log.

  DATA : lv_seq TYPE i.


  "수신 Data Log Table 저장

  CLEAR : gt_9080[], gt_9081[], gt_9082[].

  LOOP AT gt_i12.
    gt_i12-vbeln = |{ gt_i12-vbeln ALPHA = IN }|.
    gt_i12-lifnr = |{ gt_i12-lifnr ALPHA = IN }|.
    MODIFY gt_i12 TRANSPORTING vbeln lifnr.

    CLEAR : gt_9080.
    MOVE-CORRESPONDING gt_i12 TO gt_9080.
    gt_9080-zifkey = gt_9000-zifkey.

    APPEND gt_9080.
  ENDLOOP.

  LOOP AT gt_i13.
    gt_i13-vbeln = |{ gt_i13-vbeln ALPHA = IN }|.
    gt_i13-ebeln = |{ gt_i13-ebeln ALPHA = IN }|.
    PERFORM convert_matn1_input USING gt_i13-matnr.
    MODIFY gt_i13 TRANSPORTING vbeln ebeln matnr.

    lv_seq += 1.

    CLEAR : gt_9081.
    MOVE-CORRESPONDING gt_i13 TO gt_9081.
    gt_9081-zifkey = gt_9000-zifkey.
    gt_9081-seqno     = lv_seq.
    gt_9081-lichn     = gt_i13-tagnr.
    CONDENSE gt_9081-seqno.

    APPEND gt_9081.
  ENDLOOP.

  MODIFY zgtmmt9081 FROM TABLE gt_9081.
  MODIFY zgtmmt9080 FROM TABLE gt_9080.

  CHECK sy-subrc = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_COM_QTY
*&---------------------------------------------------------------------*
FORM calculate_com_qty.

* TO-BE 해저 MES 로직과 동일하게 가져감

  DATA: lv_erfmg LIKE resb-erfmg,     " 전체 소요량
        lv_lfimg LIKE ekpo-menge,     " 구매오더 수량
        lv_menge LIKE ekpo-menge,     " 입고수량
        lv_stamp TYPE timestampl.
  DATA : lv_count.

  DATA : lt_i13 LIKE gt_i13 OCCURS 0 WITH HEADER LINE.
  DATA : lt_i13_2 LIKE gt_i13 OCCURS 0 WITH HEADER LINE.

  " 입고자재의 구성품 정보 발췌
  LOOP AT gt_i13.
    IF gt_i13-parent = 'A'.
      GET TIME STAMP FIELD lv_stamp.
      gt_i13-zlink = lv_stamp.
      APPEND gt_i13 TO lt_i13_2.

      SELECT
        @gt_i13-vbeln AS vbeln,
        @gt_i13-posnr AS posnr,
        p~ebeln,
        p~ebelp,
        p~werks,
        b~matnr,
*        P~MEINS         "2023.11.23 ZITCS4HDEV01 - 주석
        b~erfme AS meins, "2023.11.23 ZITCS4HDEV01 - 추가
        p~lgort
      FROM ekpo AS p
        INNER JOIN resb AS b
                     ON b~ebeln = p~ebeln
                    AND b~ebelp = p~ebelp
        INTO CORRESPONDING FIELDS OF TABLE @lt_i13
        WHERE p~ebeln = @gt_i13-ebeln
        AND p~ebelp = @gt_i13-ebelp.

      LOOP AT lt_i13.
        lt_i13-parent = 'C'.
***        LT_ITEM-LOTNO = GT_ITEM-LOTNO.
***        LT_ITEM-TAGNR = GT_ITEM-TAGNR.
        lt_i13-hsdat = gt_i13-hsdat.
        lt_i13-zlink = lv_stamp.
        MODIFY lt_i13.

        APPEND lt_i13 TO lt_i13_2.
      ENDLOOP.

    ENDIF.
  ENDLOOP.

  gt_i13[] = lt_i13_2[].

  " 입고  수량에 따른 소요량 계산 로직
  LOOP AT gt_i12.
    LOOP AT gt_i13 WHERE vbeln = gt_i12-vbeln.
      IF gt_i13-parent = 'A'.              " 입고 수량
        lv_menge = gt_i13-lfimg.
      ELSEIF gt_i13-parent = 'C'.        "입고수량에 따른 소요량 계산
        SELECT SINGLE erfmg
           FROM resb
           INTO lv_erfmg
       WHERE ebeln = gt_i13-ebeln
            AND ebelp = gt_i13-ebelp
            AND matnr = gt_i13-matnr.

        IF sy-subrc = 0.
          SELECT SINGLE menge
               INTO lv_lfimg
            FROM ekpo
          WHERE ebeln = gt_i13-ebeln
               AND ebelp = gt_i13-ebelp.

          gt_i13-lfimg = abs( ( lv_erfmg / lv_lfimg ) * lv_menge ). "2023.11.28 ZITCS4HDEV01 ABS 추가
          MODIFY gt_i13.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

* AS-IS PWC 로직 ZMMTI34,35 E-PRO 로직 바라보고 있지만 실제 E-PRO에서 사용 안함
*  "로직 전면 변경(송종면E 24.12.13)
*  " 지중MES 외주 임가공 입고시 투입 배치 정보는 E-Proc에서 등록한 정보를 활용하도록
*
*  DATA : lt_i13 LIKE gt_i13 OCCURS 0 WITH HEADER LINE.
*
*  DATA : BEGIN OF lt_gichk OCCURS 0,
*           vbeln TYPE vbeln_vl,
*         END   OF lt_gichk.
*
*
*  lt_i13[] = gt_i13[].
*  SORT lt_i13 BY vbeln posnr tagnr.
*
*  "외주가공 투입 자재 및 배치 점검
*  " 투입 정보 조회
*  SELECT *
*    FROM zgtmm_cv_sc_543gicheck
*    INTO TABLE @DATA(lt_cdata)
*     FOR ALL ENTRIES IN @lt_i13
*   WHERE vbeln = @lt_i13-vbeln
*     AND posnr = @lt_i13-posnr.
*
*  lt_gichk[] = VALUE #( FOR ls_cdata IN lt_cdata WHERE ( gicheck = gc_n )
*                        ( CORRESPONDING #( ls_cdata ) ) ).
*
*  SELECT vbeln
*    FROM zgtmm_cv_sc_eprocgicheck
*APPENDING CORRESPONDING FIELDS OF TABLE @lt_gichk
*     FOR ALL ENTRIES IN @lt_i13
*   WHERE vbeln   = @lt_i13-vbeln
*     AND posnr   = @lt_i13-posnr
*     AND gicheck = @gc_n.
*
*  SORT lt_cdata BY vbeln posnr tagnr.
*  SORT lt_gichk BY vbeln.
*
*  CLEAR : gt_i13[].
*  DELETE ADJACENT DUPLICATES FROM gt_i12 COMPARING vbeln.
*
*  "구성품 발췌 및 구성품의 소요량 계산
*  LOOP AT gt_i12.
*    READ TABLE lt_gichk WITH KEY vbeln = gt_i12-vbeln BINARY SEARCH.
*
*    IF sy-subrc = 0.
*      CLEAR : gt_i18, gt_9082.
*      PERFORM set_cgr_rcv TABLES gt_9082
*                           USING 'E'
*                                 '투입 자재 불일치'(m21).
*
*      DELETE gt_i12.
*      CONTINUE.
*    ENDIF.
*
*    READ TABLE lt_i13 WITH KEY vbeln = gt_i12-vbeln
*                               BINARY SEARCH.
*
*    CHECK sy-subrc = 0.
*
*    LOOP AT lt_i13 FROM sy-tabix.
*      IF lt_i13-vbeln <> gt_i12-vbeln.
*        EXIT.
*      ENDIF.
*
*      "Input Data 구성(A)
*      CLEAR : gt_i13.
*      MOVE-CORRESPONDING lt_i13 TO gt_i13.
*      gt_i13-parent = gc_a.
*      APPEND gt_i13.
*
*      "조회한 투입 정보 구성(C)
*      READ TABLE lt_cdata INTO DATA(ls_data) WITH KEY vbeln = lt_i13-vbeln
*                                                      posnr = lt_i13-posnr
*                                                      tagnr = lt_i13-tagnr
*                                                      BINARY SEARCH.
*
*      IF sy-subrc = 0.
*        LOOP AT lt_cdata INTO ls_data FROM sy-tabix.
*          IF NOT ( ls_data-vbeln = lt_i13-vbeln
*               AND ls_data-posnr = lt_i13-posnr
*               AND ls_data-tagnr = lt_i13-tagnr ).
*            EXIT.
*          ENDIF.
*
*          gt_i13[] = VALUE #( BASE gt_i13[]
*                               ( VALUE #( BASE CORRESPONDING #( ls_data )
*                                          matnr  = ls_data-idnrk
*                                          lfimg  = SWITCH #( ls_data-xchpf WHEN 'X' THEN ls_data-giqty
*                                                                                    ELSE ls_data-ereqty )
*                                          meins  = ls_data-cmeins
*                                          lgort  = space
*                                          parent = gc_c
*                                          charg  = SWITCH #( ls_data-xchpf WHEN 'X' THEN ls_data-charg
*                                                                                    ELSE space )
*                                          lotno  = space
*                                          tagnr  = ls_data-tagnr
*                                          hsdat  = ls_data-hsdat
*                                          zlink  = space ) ) ).
*        ENDLOOP.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.
*
*  SORT gt_i13 BY vbeln posnr tagnr parent.

************************************************************************
*AS-IS PWC 로직 PARENT = 'A' /'C'로 나뉘어져 있지만 실제 MES 에서 구분 안함
************************************************************************
*  DATA : LV_ERFMG LIKE RESB-ERFMG, "전체 소요량
*         LV_LFIMG LIKE EKPO-MENGE, "구매오더 수량
*         LV_MENGE LIKE EKPO-MENGE. "입고수량
*
*
*  SORT GT_I13 BY VBELN POSNR EBELN EBELP ZLINK PARENT LFIMG DESCENDING.
*
*  LOOP AT GT_I12.
*    READ TABLE GT_I13 WITH KEY VBELN = GT_I12-VBELN
*                               BINARY SEARCH.
*
*    CHECK SY-SUBRC = 0.
*
*    LOOP AT GT_I13 FROM SY-TABIX.
*      IF GT_I13-VBELN <> GT_I12-VBELN.
*        EXIT.
*      ENDIF.
*
*      IF     GT_I13-PARENT = 'A'.  "입고수량
*        LV_MENGE = GT_I13-LFIMG.   "뭐하는 거지???? 확인?
*
*      ELSEIF GT_I13-PARENT = 'C'.  "입고수량에 따른 소요량 계산
*        IF GT_I13-CHARG IS INITIAL.
*          CLEAR : LV_ERFMG.
*          SELECT SUM( BDMNG ) AS ERFMG
*            FROM RESB INTO LV_ERFMG
*           WHERE EBELN = GT_I13-EBELN
*             AND EBELP = GT_I13-EBELP
*             AND MATNR = GT_I13-MATNR.
*
*          IF SY-SUBRC = 0.
*            SELECT SINGLE MENGE
*              FROM EKPO INTO LV_LFIMG
*             WHERE EBELN = GT_I13-EBELN
*               AND EBELP = GT_I13-EBELP.
*
*            SELECT SINGLE LGORT
*              FROM RESB INTO GT_I13-LGORT
*             WHERE EBELN = GT_I13-EBELN
*               AND EBELP = GT_I13-EBELP
*               AND MATNR = GT_I13-MATNR.
*
**           SELECT SINGLE MEINS
**             FROM RESB
**             INTO LV_MEINS
**            WHERE EBELN = GT_I13-EBELN
**              AND EBELP = GT_I13-EBELP
**              AND MATNR = GT_I13-MATNR.
*
*            GT_I13-LFIMG = ( LV_ERFMG / LV_LFIMG ) * LV_MENGE.
*
*            MODIFY GT_I13.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LIPS
*&---------------------------------------------------------------------*
FORM get_lips.

  "MES에서 외주가공 입고 잡을때, SAP 납품서 존재시 입고문서에 해당정보 Assign(SJM 25.03.04)

  gt_do[] = CORRESPONDING #( gt_i13[] ).

  SORT gt_do BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM gt_do COMPARING vbeln posnr.

  CHECK gt_do[] IS NOT INITIAL.

  SELECT vbeln posnr
    FROM lips
    INTO CORRESPONDING FIELDS OF TABLE gt_do
     FOR ALL ENTRIES IN gt_do
   WHERE vbeln = gt_do-vbeln
     AND posnr = gt_do-posnr.

  SORT gt_do BY vbeln posnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_VENDOR_BATCH_INFO
*&---------------------------------------------------------------------*
FORM get_vendor_batch_info.

  DATA : lt_i13 LIKE TABLE OF gt_i13.

  lt_i13 = gt_i13[].
  DELETE lt_i13 WHERE parent =  'A'.
  SORT lt_i13 BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM lt_i13 COMPARING werks matnr.

  PERFORM conversion_alpha_input USING gt_i12-lifnr.
  MODIFY gt_i12 INDEX 1.

  " 외주임가공은 한번에 하나씩만 수신
  READ TABLE gt_i12 INDEX 1.

  "배치자재별 재고정보 발췌
  IF sy-subrc = 0.
    SELECT a~matnr,
           a~werks,
           a~charg,
           a~sobkz,
           a~lifnr,
           a~lblab,
           c~meins
      FROM mslb AS a INNER JOIN @lt_i13 AS b
                        ON a~matnr = b~matnr
                       AND a~werks = b~werks
                     INNER JOIN mara AS c
                        ON a~matnr = c~matnr
     WHERE a~lifnr = @gt_i12-lifnr
       AND a~lblab > 0
      INTO CORRESPONDING FIELDS OF TABLE @gt_mslb.
  ENDIF.

  SORT gt_mslb BY matnr charg.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_SCGR_RCV
*&---------------------------------------------------------------------*
FORM run_scgr_rcv.

  DATA : lv_matnr TYPE mara-matnr.

* DELETE ADJACENT DUPLICATES FROM GT_I12 COMPARING VBELN.

  LOOP AT gt_i12.
    "Header
    PERFORM set_cgr_head. "FILL_GR_BAPI_HEADER_M04.

    "Item
    CLEAR : gv_lineid, gv_lineid_p, gt_t20[].
    READ TABLE gt_i13 WITH KEY vbeln = gt_i12-vbeln
                               BINARY SEARCH.

    IF sy-subrc = 0.

      LOOP AT gt_i13 FROM sy-tabix.
        IF gt_i13-vbeln <> gt_i12-vbeln.
          EXIT.
        ENDIF.

        gv_lineid += 1.
        IF gv_lineid_p IS INITIAL.
          gv_lineid_p = gv_lineid.
        ENDIF.

        "위치변경 320->333으로
        SELECT SINGLE matnr INTO @lv_matnr
          FROM zmmt0343
          WHERE matnr = @gt_i13-matnr
          AND werks = @gt_i13-werks.

        IF lv_matnr IS NOT INITIAL.
          PERFORM set_scgr_item_compd USING lv_matnr. "FILL_GR_BAPI_ITEM_M04.
        ELSE.
          PERFORM set_scgr_item. "FILL_GR_BAPI_ITEM_M04.

          "배치 및 특성 업데이트
          IF gt_i13-parent = gc_a AND gt_i13-charg IS NOT INITIAL.
            PERFORM create_cgr_batch USING gt_i13. "INPUT_BATCH_CREATE USING PV_ERROR 'X'.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

    "MIGO
    PERFORM goodsmvt_sccgr_rcv TABLES gt_9082
                              USING 'S'.
  ENDLOOP.

  CHECK gt_9082[] IS NOT INITIAL.
  MODIFY zgtmmt9082 FROM TABLE gt_9082.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCGR_ITEM
*&---------------------------------------------------------------------*
FORM set_scgr_item.

  CLEAR : gt_mitm.

  gt_mitm-material  = gt_i13-matnr. "자재번호
  gt_mitm-plant     = gt_i13-werks. "플랜트
  gt_mitm-stge_loc  = gt_i13-lgort. "저장위치
  gt_mitm-po_number = gt_i13-ebeln. "구매오더 번호
  gt_mitm-po_item   = gt_i13-ebelp. "구매문서의 품목 번호
  gt_mitm-mvt_ind   = gc_b.         "이동지시자(구매 오더 대한 자재 이동)
  gt_mitm-batch     = gt_i13-charg. "배치번호
  gt_mitm-entry_qnt = gt_i13-lfimg. "입력단위 수량
  gt_mitm-entry_uom = gt_i13-meins. "입력단위
  gt_mitm-line_id   = gv_lineid.    "문서라인의 고유식별
  gt_mitm-prod_date = gt_i13-hsdat. "제조일
* T0-BE 로직 추가
  gt_mitm-deliv_numb_to_search = gt_i13-vbeln.
  gt_mitm-deliv_item_to_search = gt_i13-posnr.
  gt_mitm-deliv_numb           = gt_i13-vbeln.
  gt_mitm-deliv_item           = gt_i13-posnr.


  CASE gt_i13-parent.
    WHEN 'A'.  "PARENT
      gt_mitm-move_type = gc_101.       "이동유형(구매입고)
      gt_mitm-parent_id = gc_000000.    "바로 상위라인 ID
      gt_mitm-item_text = gt_i13-lotno. "MES LOT No

      gv_lineid_p = gv_lineid.          "Parent Line ID KEEP

*      PERFORM set_xgr_lot TABLES gt_t20
*                           USING gt_i13
*                                 gv_lineid.

    WHEN 'C'.
      gt_mitm-move_type = gc_543.       "이동유형(임가공 완료 후 제품 입고)
      gt_mitm-parent_id = gv_lineid_p.  "바로 상위라인 ID

  ENDCASE.


* AS-IS PWC 로직 likp assign

*  "MES에서 외주가공 입고 잡을때, SAP 납품서 존재시 입고문서에 해당정보 Assign(SJM 25.03.04)
*  READ TABLE gt_do WITH KEY vbeln = gt_i13-vbeln
*                            posnr = gt_i13-posnr
*                            BINARY SEARCH.
*
*  IF sy-subrc = 0.
*    gt_mitm-deliv_numb_to_search = gt_i13-vbeln. "추가(SJM 25.03.05)
*    gt_mitm-deliv_item_to_search = gt_i13-posnr. "추가(SJM 25.03.05)
*    gt_mitm-deliv_numb           = gt_i13-vbeln.
*    gt_mitm-deliv_item           = gt_i13-posnr.
*  ENDIF.
*
  APPEND gt_mitm.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_SCGR_ITEM
*&---------------------------------------------------------------------*
FORM set_scgr_item_compd USING lv_matnr.

  DATA : temp_line(6) TYPE n,
         lv_flag(1) .

  CLEAR : temp_line, lv_flag, gt_mitm.

  IF gt_i13-parent = 'A'.
    gt_mitm-move_type = gc_101.       "이동유형(구매입고)
    gt_mitm-parent_id = gc_000000.    "바로 상위라인 ID
    gt_mitm-item_text = gt_i13-lotno. "MES LOT No
    gt_mitm-batch     = gt_i13-charg. "배치번호
    gt_mitm-entry_qnt = gt_i13-lfimg. "입력단위 수량
    gt_mitm-material  = gt_i13-matnr. "자재번호
    gt_mitm-plant     = gt_i13-werks. "플랜트
    gt_mitm-stge_loc  = gt_i13-lgort. "저장위치
    gt_mitm-po_number = gt_i13-ebeln. "구매오더 번호
    gt_mitm-po_item   = gt_i13-ebelp. "구매문서의 품목 번호
    gt_mitm-mvt_ind   = gc_b.         "이동지시자(구매 오더 대한 자재 이동)
    gt_mitm-entry_uom = gt_i13-meins. "입력단위
    gt_mitm-line_id   = gv_lineid.    "문서라인의 고유식별
    gt_mitm-prod_date = gt_i13-hsdat. "제조일

    PERFORM set_xgr_lot TABLES gt_t20 "추가(SJM 25.06.10)
                         USING gt_i13
                               gv_lineid.

    IF gt_i13-parent = gc_a AND gt_i13-charg IS NOT INITIAL.
      PERFORM create_cgr_batch USING gt_i13. "INPUT_BATCH_CREATE USING PV_ERROR 'X'.
    ENDIF.

    IF gt_sub_lineid = '000000'.
      gt_mitm-line_id = gt_sub_lineid + 1.
      gt_sub_lineid += 1.
    ELSE.
      temp_line = lines( gt_mitm ) + 1.
      gt_mitm-line_id = |{ temp_line ALPHA = IN }|.
      gt_sub_lineid = temp_line.
    ENDIF.


    APPEND gt_mitm.

    "반도전compd 배치분할 대상자재
    IF lv_matnr IS NOT INITIAL.
      SELECT a~matnr, b~idnrk,b~charg, b~lfimg, b~meins
        INTO CORRESPONDING FIELDS OF TABLE @gt_sub
        FROM zmmti34 AS a INNER JOIN zmmti35 AS b
        ON a~vbeln = b~vbeln
        AND a~posnr = b~posnr
        AND a~matnr = b~matnr
        AND a~tagnr = b~tagnr
        WHERE b~vbeln = @gt_i13-vbeln
        AND b~posnr = @gt_i13-posnr
        AND a~ebeln = @gt_i13-ebeln
        AND a~ebelp = @gt_i13-ebelp
        AND a~matnr = @gt_i13-matnr.

      IF sy-subrc = 0.
        gt_i13-parent = 'C'.
      ENDIF.
    ENDIF.

    IF gt_i13-parent = 'C'.
      gt_mitm-move_type = gc_543.       "이동유형(임가공 완료 후 제품 입고)

      IF gt_sub_lineid_p = '000000'.
        gt_sub_lineid_p += 1.
      ELSE.
        gt_sub_lineid_p = temp_line.
      ENDIF.

      gt_sub_lineid += 1.                   "반도전COMPD 용

      IF lv_matnr IS NOT INITIAL.
        LOOP AT gt_sub.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
              input  = gt_sub-idnrk
            IMPORTING
              output = gt_sub-idnrk.

          gt_mitm-parent_id = gt_sub_lineid_p.  "바로 상위라인 ID
          gt_mitm-item_text = gt_i13-lotno. "MES LOT No
          gt_mitm-batch     = gt_sub-charg. "배치번호
          gt_mitm-spec_stock = 'O'.         "공급업체 특별재고
          gt_mitm-entry_qnt = gt_sub-lfimg. "입력단위 수량
          gt_mitm-material  = gt_sub-idnrk. "자재번호
          gt_mitm-plant     = gt_i13-werks. "플랜트
          gt_mitm-stge_loc  = gt_i13-lgort. "저장위치
          gt_mitm-po_number = gt_i13-ebeln. "구매오더 번호
          gt_mitm-po_item   = gt_i13-ebelp. "구매문서의 품목 번호
          gt_mitm-mvt_ind   = gc_b.         "이동지시자(구매 오더 대한 자재 이동)
          gt_mitm-entry_uom = gt_sub-meins. "입력단위
          gt_mitm-line_id   = gt_sub_lineid.    "문서라인의 고유식별
          gt_mitm-prod_date = gt_i13-hsdat. "제조일
          APPEND gt_mitm.

          gt_sub_lineid += 1.

        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_SCGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_zppt0001_scgr.

  DATA(lt_item) = gt_i13[].

  LOOP AT lt_item INTO DATA(ls_item) WHERE parent = gc_a.
    CHECK ls_item-charg IS NOT INITIAL.

    CLEAR : gv_aufnr, gs_mseg.
    gv_aufnr = |{ ls_item-ebeln ALPHA = IN }|.

    "단위환산 정보(자재전표로 가져오기)
    SELECT SINGLE menge meins
      FROM mseg
      INTO CORRESPONDING FIELDS OF gs_mseg
     WHERE mblnr = gs_mhdrt-mat_doc
       AND mjahr = gs_mhdrt-doc_year
       AND ebeln = ls_item-ebeln
       AND ebelp = ls_item-ebelp
       AND charg = ls_item-charg.

    "SPC
    PERFORM get_dispo USING ls_item-werks
                            ls_item-matnr.

    SELECT SINGLE mgvrg, remain
      FROM zppt0001
      INTO ( @DATA(lv_mgvrg1), @DATA(lv_remain1) )
     WHERE werks = @ls_item-werks
       AND aufnr = @gv_aufnr
       AND tagnr = @ls_item-tagnr.

    IF sy-subrc <> 0.
      CLEAR : gs_zppt0001.

      gs_zppt0001-werks   = ls_item-werks.
      gs_zppt0001-aufnr   = gv_aufnr.
      gs_zppt0001-tagnr   = ls_item-tagnr.
      gs_zppt0001-posnr   = ls_item-ebelp.
      gs_zppt0001-charg   = ls_item-charg.
      gs_zppt0001-matnr   = ls_item-matnr.
      gs_zppt0001-mblnr   = gs_mhdrt-mat_doc.
      gs_zppt0001-mgvrg   = gs_mseg-menge.
      gs_zppt0001-remain  = gs_mseg-menge.
      gs_zppt0001-lgort   = ls_item-lgort.
      gs_zppt0001-meins   = gs_mseg-meins.
      gs_zppt0001-spgcd   = gv_dispo+0(2).
      gs_zppt0001-fostcnt = 1.
      gs_zppt0001-outflg  = gc_x.
      gs_zppt0001-giflg   = gc_n.
      gs_zppt0001-grflg   = gc_y.
      gs_zppt0001-inspflg = gc_ok.
      gs_zppt0001-wkdat   = sy-datum.
      gs_zppt0001-grindat = sy-datum.
      gs_zppt0001-grintim = sy-uzeit.
      gs_zppt0001-grinnam = sy-uname.

      MODIFY zppt0001 FROM gs_zppt0001.

    ELSE.
      DATA(lv_mgvrg)  = gs_mseg-menge + lv_mgvrg1.
      DATA(lv_remain) = gs_mseg-menge + lv_remain1.

      UPDATE zppt0001 SET mgvrg  = lv_mgvrg
                          remain = lv_mgvrg "확인!! 왜 LV_REMAIN이 아니고??
                          lgort  = ls_item-lgort
                          mblnr  = gs_mhdrt-mat_doc
                          charg  = ls_item-charg
                          grflg  = gc_y
                    WHERE werks  = ls_item-werks
                      AND aufnr  = gv_aufnr
                      AND tagnr  = ls_item-tagnr.

    ENDIF.

    CHECK sy-subrc = 0.
    COMMIT WORK.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODSMVT_CGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_9082
*&      --> P_
*&---------------------------------------------------------------------*
FORM goodsmvt_sccgr_rcv TABLES pt_90x2 STRUCTURE zgtmmt9082
                       USING pv_type.

  PERFORM bapi_goodsmvt_create.

  IF gs_mhdrt IS NOT INITIAL.
    PERFORM bapi_commit.
    PERFORM rtn_sccgr_rcv TABLES pt_90x2 USING 'S'.


*&-----------------------------------------
* 한미소(KFCM)의 경우 꼬리표 관리 안함 - S
*&-----------------------------------------
   "주서처리
*    CASE pv_type.
*      WHEN 'S'.
*        PERFORM modify_zppt0001_scgr.
*      WHEN 'N'.
*        PERFORM modify_zppt0001_gr.
*    ENDCASE.

    CASE gv_system_id.
      WHEN 'KFCM'.

      WHEN OTHERS.
        CASE pv_type.
          WHEN 'S'.
            PERFORM modify_zppt0001_scgr.
          WHEN 'N'.
            PERFORM modify_zppt0001_gr.
        ENDCASE.
    ENDCASE.

*&-----------------------------------------
* 한미소(KFCM)의 경우 꼬리표 관리 안함 - E
*&-----------------------------------------



  ELSE.
    PERFORM bapi_rollback.

    READ TABLE gt_rtn WITH KEY type = gc_a.
    IF sy-subrc <> 0.
      READ TABLE gt_rtn WITH KEY type = gc_e.
      IF sy-subrc <> 0.
        READ TABLE gt_rtn WITH KEY type = gc_w.
        IF sy-subrc <> 0.
          READ TABLE gt_rtn WITH KEY type = gc_i.
          IF sy-subrc <> 0.
            READ TABLE gt_rtn INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF sy-subrc = 0.
      PERFORM rtn_cgr_rcv TABLES pt_90x2 USING 'E'.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPD_SCXGR_LOT
*&---------------------------------------------------------------------*
FORM upd_scxgr_lot TABLES pt_t2x
                        pt_i2x
                  USING pv_rst.

  "입고 성공시 검사 Lot 정보 조회
  IF pv_rst = gc_s.

    SELECT vbeln_im AS vbeln,
           vbelp_im AS posnr,
           a~mblnr,
           a~mjahr,
           a~ebeln,
           a~ebelp,
           a~zeile,
           b~prueflos
      INTO CORRESPONDING FIELDS OF TABLE @pt_i2x
      FROM matdoc AS a
      LEFT OUTER JOIN qals AS b
        ON a~mjahr = b~mjahr
       AND a~mblnr = b~mblnr
       AND a~zeile = b~zeile
     WHERE a~mblnr = @gs_mhdrt-mat_doc
       AND a~mjahr = @gs_mhdrt-doc_year
       AND a~line_depth = '00'
       AND a~shkzg = 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_scCGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_9082
*&      --> P_
*&---------------------------------------------------------------------*
FORM rtn_sccgr_rcv TABLES pt_90x2 STRUCTURE zgtmmt9082
                  USING pv_rst.

  DATA : lv_msg TYPE bapi_msg.


  CLEAR : gt_i18, pt_90x2.

  CASE pv_rst.
    WHEN 'S'.
      gt_i18-mblnr = gs_mhdrt-mat_doc.
      gt_i18-mjahr = gs_mhdrt-doc_year.

      CONCATENATE 'Material Doc.'(m17)
                  gs_mhdrt-mat_doc
                  gs_mhdrt-doc_year
                  'was created.'(m18)
             INTO lv_msg SEPARATED BY space.

    WHEN 'E'.
      lv_msg = gt_rtn-message && '(4)'.

  ENDCASE.

  PERFORM set_cgr_rcv TABLES pt_90x2
                       USING pv_rst
                             lv_msg.

  PERFORM upd_scxgr_lot TABLES gt_t20  "추가(SJM 25.06.10)
                             gt_i20
                       USING pv_rst.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_ALPHA_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEAD_VBELN
*&---------------------------------------------------------------------*
FORM conversion_alpha_input    USING  p_var.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_var
    IMPORTING
      output = p_var.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_ITEAM_MATNR
*&---------------------------------------------------------------------*
FORM conversion_matn1_input  CHANGING pv_matnr.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = pv_matnr
    IMPORTING
      output       = pv_matnr
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_CUNIT_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ITEM_MEINS
*&---------------------------------------------------------------------*
FORM conversion_cunit_input  USING    p_var.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input  = p_var
    IMPORTING
      output = p_var.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ITEM_C_MATNR
*&      --> LS_ITEM_C_MEINS
*&      --> LS_ITEM_C_MEINS_S
*&      --> LS_ITEM_C_LFIMG
*&---------------------------------------------------------------------*
FORM convert_material_unit  USING    pv_matnr
                                     pv_meins_fr
                                     pv_meins_to
                                     pv_lfimg_fr
                                     pv_lfimg_to.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = pv_matnr
      i_in_me              = pv_meins_fr
      i_out_me             = pv_meins_to
      i_menge              = pv_lfimg_fr
    IMPORTING
      e_menge              = pv_lfimg_to
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ITEM
*&---------------------------------------------------------------------*
FORM get_stock_info  USING    ps_item STRUCTURE gt_i13
                              pv_toqty
                              pv_saved.

  LOOP AT gt_mslb WHERE matnr = ps_item-matnr
                    AND werks = ps_item-werks
                    AND lblab > 0.
    IF pv_toqty =< gt_mslb-lblab.
      ps_item-charg = gt_mslb-charg.
      ps_item-lfimg = pv_toqty.
      gt_mslb-lblab = gt_mslb-lblab - pv_toqty.
      MODIFY gt_mslb TRANSPORTING lblab.
      CLEAR pv_toqty.
      pv_saved = 'X'.
    ELSEIF pv_toqty > gt_mslb-lblab.
      ps_item-charg = gt_mslb-charg.
      ps_item-lfimg = gt_mslb-lblab.
      pv_toqty = pv_toqty - gt_mslb-lblab.
      CLEAR gt_mslb-lblab.
      pv_saved = 'X'.
      MODIFY gt_mslb TRANSPORTING lblab.
    ENDIF.

    EXIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISTRIBUTE_VENDOR_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM distribute_vendor_batch .

  DATA : lt_i13_A LIKE TABLE OF gt_i13.

  DATA : BEGIN OF ls_i13_C.
           INCLUDE STRUCTURE gt_i13.
  DATA :   lfimg_s LIKE gt_i13-lfimg,
           meins_s LIKE mara-meins,
         END OF ls_i13_C.
  DATA : lt_i13_C LIKE TABLE OF ls_i13_C.

  DATA : lv_saved(1).

  " PO 구성품의 단위와 자재마스터가 다르면 단위환산 로직
  LOOP AT gt_i13 INTO DATA(ls_i13).
    IF ls_i13-parent = 'A'.
      APPEND ls_i13 TO lt_i13_A.
    ELSEIF gt_i13-parent = 'C'.
      CLEAR ls_i13_C.
      MOVE-CORRESPONDING ls_i13 TO ls_i13_C.

      SELECT SINGLE meins
        INTO @DATA(lv_meins)
        FROM mara
       WHERE matnr = @ls_i13-matnr.

      IF ls_i13_C-meins <> lv_meins.
        ls_i13_C-meins_s = lv_meins.
        PERFORM convert_material_unit USING ls_i13_C-matnr
                                            ls_i13_C-meins
                                            ls_i13_C-meins_s
                                            ls_i13_C-lfimg
                                            ls_i13_C-lfimg_s.
      ELSE.
        ls_i13_C-lfimg_s = ls_i13_C-lfimg.
        ls_i13_C-meins_s = ls_i13_C-meins.
      ENDIF.

      APPEND ls_i13_C TO lt_i13_C.
    ENDIF.
  ENDLOOP.

  "배치 별 선입선출로 계산하는 로직
  CLEAR : GT_i13, GT_i13[].
  SORT lt_i13_C BY zlink.
  LOOP AT lt_i13_A INTO DATA(ls_i13_a).
    CLEAR lv_saved.
    CLEAR gt_i13.
    MOVE-CORRESPONDING ls_i13_a TO gt_i13.
    APPEND gt_i13.

    CLEAR : gt_i13.
    LOOP AT lt_i13_c INTO ls_i13_c WHERE zlink = ls_i13_a-zlink.
      CLEAR lv_saved.
      DATA(lv_toqty) = ls_i13_c-lfimg_s.
      DO 100 TIMES.
        IF lv_toqty = 0.
          EXIT.
        ENDIF.

        CLEAR gt_i13.
        MOVE-CORRESPONDING ls_i13_c TO gt_i13.

        PERFORM get_stock_info USING gt_i13
                                     lv_toqty
                                     lv_saved.

        IF ls_i13_c-meins <> ls_i13_c-meins_s.
          PERFORM convert_material_unit USING ls_i13_c-matnr
                                              ls_i13_c-meins_s
                                              ls_i13_c-meins
                                              gt_i13-lfimg
                                              gt_i13-lfimg.
        ENDIF.

        IF lv_saved EQ 'X'.
          APPEND gt_i13.
        ENDIF.
      ENDDO.
    ENDLOOP.

  ENDLOOP.
*<-
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_M04
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM conversion_input_m04 .

*- CONVERSION_EXIT_ALPHA_INPUT.
  LOOP AT GT_i12.
    PERFORM conversion_alpha_input USING GT_i12-vbeln.
    PERFORM conversion_alpha_input USING GT_i12-lifnr.

    MODIFY GT_i12 INDEX sy-tabix TRANSPORTING vbeln lifnr.
    CLEAR : GT_i12.
  ENDLOOP.

*~ M03
*  LOOP AT GT_ITEAM.
*    PERFORM CONVERSION_DATA_INPUT_M04.
*
*    MODIFY GT_ITEAM INDEX SY-TABIX TRANSPORTING VBELN EBELN MATNR.
*    CLEAR : GT_ITEAM.
*  ENDLOOP.

*~M004
  LOOP AT gt_i13.
    PERFORM conversion_matn1_input CHANGING gt_i13-matnr.
    PERFORM conversion_alpha_input USING gt_i13-ebeln.
    PERFORM conversion_alpha_input USING gt_i13-ebelp.
    PERFORM conversion_alpha_input USING gt_i13-vbeln.
    PERFORM conversion_alpha_input USING gt_i13-posnr.
    PERFORM conversion_cunit_input USING gt_i13-meins.

    MODIFY gt_i13. " INDEX SY-TABIX TRANSPORTING VBELN EBELN MATNR.
    CLEAR : gt_i13.
  ENDLOOP.

ENDFORM.
