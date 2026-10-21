*&---------------------------------------------------------------------*
*& Include          ZGTSDR9001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .

*  SELECT * FROM zgtsdt9062 INTO CORRESPONDING FIELDS OF TABLE gt_data WHERE vbeln_n <> ''.
*  SELECT * FROM zgtppt1010 INTO CORRESPONDING FIELDS OF TABLE GT_9994 WHERE MODULE_KIND = 'SD' AND CODEGRP = '9994'.

  SELECT * FROM zgtppt1010 INTO CORRESPONDING FIELDS OF TABLE gt_Z995
    WHERE module_kind = 'SD' AND codegrp = 'Z995'. "폐기

  SELECT * FROM zgtppt1010 INTO CORRESPONDING FIELDS OF TABLE gt_Z996
    WHERE module_kind = 'SD' AND codegrp = 'Z996'. "413-E




ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .

  CASE 'X'.
    WHEN p_cgi.
      PERFORM bapi_goodsmvt_cgi.
    WHEN p_413e.
      PERFORM bapi_goodsmvt_413e.

  ENDCASE.




*  CLEAR : wa_data.

*  LOOP AT gt_data INTO wa_data WHERE mblnr = ''.
*    IF wa_data-stock_type = 'X'.
*      PERFORM bapi_goodsmvt_413e.
*    ELSE.
*      PERFORM bapi_goodsmvt_413.
*    ENDIF.
*  ENDLOOP.
*
*  UPDATE zgtsdt9062 FROM TABLE gt_data.
*
*  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_413E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_413e .

* FLD_01 - 원본판매오더
* FLD_02 - 원본행번
* FLD_03 - New 판매오더
* FLD_04 - New 행번
* FLD_05 - 자재코드
* FLD_06 - 단위
* FLD_07 - 수량
* FLD_08 - 원본 배치
* FLD_09 - 적송 배치
* FLD_10 - 문서번호 OR 에러

  LOOP AT gt_Z996 INTO wa_Z996.

    gs_goodsmvt_item-material = wa_Z996-fld_05.
    gs_goodsmvt_item-plant = '1306'.
    gs_goodsmvt_item-stge_loc = '3600'. "Z43/E Rev 시 3600으로 전량으로 이동됨
    gs_goodsmvt_item-batch = wa_Z996-fld_08.
    gs_goodsmvt_item-entry_qnt = wa_Z996-fld_07. "수량
    gs_goodsmvt_item-entry_uom = wa_Z996-fld_06. "판매오더 단위.

    gs_goodsmvt_item-move_type = '413'.
    gs_goodsmvt_item-spec_stock = 'E'.
    gs_goodsmvt_item-sales_ord = wa_Z996-fld_03.
    gs_goodsmvt_item-s_ord_item = wa_Z996-fld_04.
    gs_goodsmvt_item-val_sales_ord = wa_Z996-fld_01.
    gs_goodsmvt_item-val_s_ord_item = wa_Z996-fld_02.
    gs_goodsmvt_item-move_stloc = '2550'. "2550으로 이동.
    gs_goodsmvt_item-move_batch = wa_Z996-fld_09.
    gs_goodsmvt_item-move_mat = wa_Z996-fld_05.
    gs_goodsmvt_item-move_plant = '1306'.

    APPEND gs_goodsmvt_item TO gt_goodsmvt_item.

    SELECT SINGLE * FROM zgtppt1010 INTO @DATA(ls_ppt1010) WHERE module_kind = 'DT' AND codegrp = '1030'.
    goodsmvt_header-pstng_date = ls_ppt1010-fld_01.
    goodsmvt_header-doc_date = ls_ppt1010-fld_01.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = '04'
        testrun          = p_check
*       GOODSMVT_REF_EWM =
*       GOODSMVT_PRINT_CTRL           =
      IMPORTING
*       GOODSMVT_HEADRET =
        materialdocument = materialdocument
*       MATDOCUMENTYEAR  =
      TABLES
        goodsmvt_item    = gt_goodsmvt_item
*       GOODSMVT_SERIALNUMBER         =
        return           = gt_return
*       GOODSMVT_SERV_PART_DATA       =
*       EXTENSIONIN      =
*       GOODSMVT_ITEM_CWM             =
      .

    IF materialdocument IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* IMPORTING
*   RETURN        =

      READ TABLE gt_return INTO gs_return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        wa_Z996-fld_10 = gs_return-message.
        CLEAR : gs_return.
      ELSE.
        CLEAR : gs_return.
      ENDIF.

        MODIFY gt_Z996 FROM wa_Z996.
    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      wa_Z996-fld_10 = materialdocument.

      MODIFY gt_Z996 FROM wa_Z996.
    ENDIF.

      CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
      REFRESH : gt_goodsmvt_item, gt_return.
  ENDLOOP.

*  UPDATE ZGTPPT1010 FROM GT_Z996.
  IF 1 = 1. "Debug.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_413E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_413 .

  CLEAR : wa_vbap, wa_mska.
  REFRESH : gt_mska.

  SELECT SINGLE * FROM vbap INTO CORRESPONDING FIELDS OF wa_vbap
    WHERE vbeln = wa_data-vbeln_n AND posnr = wa_data-posnr_n.

  IF sy-subrc NE 0.
    wa_data-msg = '신규판매오더 데이터 미 존재'.
    wa_data-ernam = sy-uname.
    wa_data-erdat = sy-datum.
    wa_data-erzeit = sy-uzeit.

    MODIFY gt_data FROM wa_data.

    CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
    REFRESH : gt_goodsmvt_item, gt_return.
    EXIT.
  ELSE.

    SELECT SINGLE xchpf FROM marc INTO @DATA(lv_xchpf) WHERE werks = '1306' AND matnr = @wa_vbap-matnr.
    IF lv_xchpf = 'X'.
*      CLEAR : lv_xchpf.
*      wa_data-msg = '413 처리대상 중 배치관리대상(EX. 완제품 중 상품 케이스), 수기처리 요망'.
*      wa_data-ernam = sy-uname.
*      wa_data-erdat = sy-datum.
*      wa_data-erzeit = sy-uzeit.
*      MODIFY gt_data FROM wa_data.
*      CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
*      REFRESH : gt_goodsmvt_item, gt_return.
*
*      READ TABLE GT_9994 INTO WA_9994 WITH KEY FLD_01 = WA_DATA-VBELN_O
*                                                                            FLD_02 = WA_DATA-POSNR_O.
*
*      IF sy-subrc = 0.
*      gs_goodsmvt_item-batch = wa_9994-fld_03.
*      gs_goodsmvt_item-move_batch = wa_9994-fld_03.
*      ELSE.

      gs_goodsmvt_item-batch = wa_data-flag.
      gs_goodsmvt_item-move_batch = wa_data-flag.

      IF gs_goodsmvt_item-batch IS INITIAL.
        wa_data-msg = '원본배치 데이터 미존재. SD9092-flag 확인 요망'.
        wa_data-ernam = sy-uname.
        wa_data-erdat = sy-datum.
        wa_data-erzeit = sy-uzeit.

        MODIFY gt_data FROM wa_data.

        CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
        REFRESH : gt_goodsmvt_item, gt_return.
        EXIT.
      ENDIF.
    ENDIF.

    gs_goodsmvt_item-material = wa_vbap-matnr.
    gs_goodsmvt_item-plant = wa_vbap-werks.
    gs_goodsmvt_item-stge_loc = '2550'.
*    gs_goodsmvt_item-batch = wa_vbap-charg.
    gs_goodsmvt_item-entry_qnt = wa_vbap-kwmeng. "판매오더 수량
    gs_goodsmvt_item-entry_uom = wa_vbap-vrkme. "판매오더 단위.

    gs_goodsmvt_item-move_type = '413'.
*    gs_goodsmvt_item-spec_stock = 'E'.
*    gs_goodsmvt_item-sales_ord = wa_data-vbeln_o.
*    gs_goodsmvt_item-s_ord_item = wa_data-posnr_o.
    gs_goodsmvt_item-val_sales_ord = wa_data-vbeln_n.
    gs_goodsmvt_item-val_s_ord_item = wa_data-posnr_n.
    gs_goodsmvt_item-move_stloc = '2550'. "2550으로 이동.
*      gs_goodsmvt_item-move_batch = wa_mska-charg.
    gs_goodsmvt_item-move_mat = wa_vbap-matnr.
    gs_goodsmvt_item-move_plant = wa_vbap-werks.

    APPEND gs_goodsmvt_item TO gt_goodsmvt_item.

    SELECT SINGLE * FROM zgtppt1010 INTO @DATA(ls_ppt1010) WHERE module_kind = 'DT' AND codegrp = '1030'.
    goodsmvt_header-pstng_date = ls_ppt1010-fld_01.
    goodsmvt_header-doc_date = ls_ppt1010-fld_01.


    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = '04'
        testrun          = p_check
*       GOODSMVT_REF_EWM =
*       GOODSMVT_PRINT_CTRL           =
      IMPORTING
*       GOODSMVT_HEADRET =
        materialdocument = materialdocument
*       MATDOCUMENTYEAR  =
      TABLES
        goodsmvt_item    = gt_goodsmvt_item
*       GOODSMVT_SERIALNUMBER         =
        return           = gt_return
*       GOODSMVT_SERV_PART_DATA       =
*       EXTENSIONIN      =
*       GOODSMVT_ITEM_CWM             =
      .

    IF materialdocument IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* IMPORTING
*   RETURN        =

      wa_data-ernam = sy-uname.
      wa_data-erdat = sy-datum.
      wa_data-erzeit = sy-uzeit.

      READ TABLE gt_return INTO gs_return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        wa_data-msg = gs_return-message.
        CLEAR : gs_return.
      ELSE.
        CLEAR : gs_return.
      ENDIF.

      CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
      REFRESH : gt_goodsmvt_item, gt_return.

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
*  IMPORTING
*    RETURN        =

      wa_data-ernam = sy-uname.
      wa_data-erdat = sy-datum.
      wa_data-erzeit = sy-uzeit.
      wa_data-mblnr = materialdocument.

      MODIFY gt_data FROM wa_data.

      CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
      REFRESH : gt_goodsmvt_item, gt_return.

    ENDIF.
  ENDIF.


  CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
  REFRESH : gt_goodsmvt_item, gt_return.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_cgi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_cgi .

* FLD_01 - 자재코드
* FLD_02 - 단위
* FLD_03 - 수량
* FLD_04 - 원본 배치
* FLD_05 - 문서번호 OR 에러
* FLD_06 - TBA
* FLD_07 - TBA
* FLD_08 - TBA
* FLD_09 - TBA
* FLD_10 - TBA

LOOP AT gt_Z995 into wa_Z995.

    gs_goodsmvt_item-material = wa_Z995-fld_01.
    gs_goodsmvt_item-plant = '1306'.
    gs_goodsmvt_item-stge_loc = '2550'.
    gs_goodsmvt_item-batch = wa_z995-fld_04.
    gs_goodsmvt_item-entry_qnt = wa_Z995-fld_03. "판매오더 수량
    gs_goodsmvt_item-entry_uom = wa_Z995-fld_02. "판매오더 단위.
    gs_goodsmvt_item-move_type = 'Z95'. "이동유형 정의 필요

    APPEND gs_goodsmvt_item TO gt_goodsmvt_item.

    SELECT SINGLE * FROM zgtppt1010 INTO @DATA(ls_ppt1010) WHERE module_kind = 'DT' AND codegrp = '1030'.
    goodsmvt_header-pstng_date = ls_ppt1010-fld_01.
    goodsmvt_header-doc_date = ls_ppt1010-fld_01.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = '03'
        testrun          = p_check
*       GOODSMVT_REF_EWM =
*       GOODSMVT_PRINT_CTRL           =
      IMPORTING
*       GOODSMVT_HEADRET =
        materialdocument = materialdocument
*       MATDOCUMENTYEAR  =
      TABLES
        goodsmvt_item    = gt_goodsmvt_item
*       GOODSMVT_SERIALNUMBER         =
        return           = gt_return
*       GOODSMVT_SERV_PART_DATA       =
*       EXTENSIONIN      =
*       GOODSMVT_ITEM_CWM             =
.


    IF materialdocument IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* IMPORTING
*   RETURN        =

      READ TABLE gt_return INTO gs_return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        wa_Z995-fld_10 = gs_return-message.
        CLEAR : gs_return.
      ELSE.
        CLEAR : gs_return.
      ENDIF.

        MODIFY gt_Z995 FROM wa_Z995.
    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      wa_Z995-fld_10 = materialdocument.

      MODIFY gt_Z995 FROM wa_Z995.
    ENDIF.

      CLEAR : gs_goodsmvt_item, goodsmvt_header, gs_return.
      REFRESH : gt_goodsmvt_item, gt_return.
  ENDLOOP.

*  UPDATE ZGTPPT1010 FROM GT_Z996.
  IF 1 = 1. "Debug.

  ENDIF.

ENDFORM.
