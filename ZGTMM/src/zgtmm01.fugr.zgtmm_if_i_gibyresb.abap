FUNCTION zgtmm_if_i_gibyresb.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMSIF0040
*"      OT_TAB STRUCTURE  ZGTMMSIF0041
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_GIBYRESB
*& 프로그램 명 : 예약 불출 정보 수신
*& 개요   : 예약 불출 정보 수신용 RFC (From 지중MES)
*&            이동유형 311 예약 불출 목적의 I/F
*& 생성일 : 2024.11.25
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  IF it_tab[] IS INITIAL.
    zo_result  = gc_01.
    zo_message = '전송된 데이터가 없습니다'(m10).
    RETURN.
  ENDIF.

  gv_system_id = i_system_id.
  PERFORM set_com_log USING 'S' 'MM00012' ' ' ' '.

  CLEAR : gt_i40[], gt_i41[].

  gt_i40[] = it_tab[].
  SORT gt_i40 BY rsnum rspos.

  PERFORM set_912x_log.

  "예약 불출처리
  PERFORM run_gibyresb.

  ot_tab[] = gt_i41[].

  PERFORM rtn_rst_msg TABLES gt_i41.

  PERFORM set_eai_msg USING gv_zstat CHANGING zo_result
                                              zo_message.

* "Export Parameter : 고정값
* ZO_RESULT  = '00'.
* ZO_MESSAGE = 'DATA 전송 성공'.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_912X_LOG
*&---------------------------------------------------------------------*
FORM set_912x_log.

  "수신 Data Log Table 저장

  CLEAR : gt_9120[], gt_9121[].

  gt_9120[] = VALUE #( FOR ls_i40 IN gt_i40
                       ( VALUE #( BASE CORRESPONDING #( ls_i40 )
                                  zifkey = gt_9000-zifkey ) ) ).

  MODIFY zgtmmt9120 FROM TABLE gt_9120.

  CHECK sy-subrc = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_GIBYRESB
*&---------------------------------------------------------------------*
FORM run_gibyresb.

  CLEAR : gs_mhdr,   gs_mcod,   gs_mhdrt,
          gt_mitm[], gt_msrn[], gt_rtn[],
          gt_res_change[], gt_res_changex[], gv_resb.

  LOOP AT gt_i40.
    MOVE-CORRESPONDING gt_i40 TO gs_i40.
*   MOVE-CORRESPONDING GT_I40 TO GT_I41.
*   APPEND GT_I41.

    IF gs_i40-erfmg = 0.
      PERFORM set_resb_item.
    ELSE.
      IF sy-tabix = 1.
        PERFORM set_gibyresb_head.
      ENDIF.

      PERFORM set_gibyresb_item.
    ENDIF.
  ENDLOOP.

  IF gv_resb ='X'.
    PERFORM bapi_reservation_change.
  ELSE.
    PERFORM bapi_goodsmvt_create.
  ENDIF.

  "예약변경 return
  IF gv_resb = 'X'.
    READ TABLE gt_rtn2 WITH KEY type ='S'.
    IF sy-subrc = 0.
      PERFORM bapi_commit.
      PERFORM rtn_gibyresb_rcv USING 'S' '예약에 대한 변경을 성공했습니다'.
    ELSE.
      PERFORM bapi_rollback.

      READ TABLE gt_rtn2 WITH KEY type = 'E'.
      PERFORM rtn_gibyresb_rcv USING 'E' gt_rtn2-message.
    ENDIF.

    "자재불출 or Transfer Posting
  ELSE.
    IF gs_mhdrt IS NOT INITIAL.
      PERFORM bapi_commit.
      PERFORM rtn_gibyresb_rcv USING 'S' '예약에 대한 처리를 성공했습니다'(m11).
    ELSE.
      PERFORM bapi_rollback.

      READ TABLE gt_rtn WITH KEY type = 'E'.
      PERFORM rtn_gibyresb_rcv USING 'E' gt_rtn-message.
    ENDIF.
  ENDIF.

  CHECK gt_9121[] IS NOT INITIAL.
  MODIFY zgtmmt9121 FROM TABLE gt_9121.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GIBYRESB_HEAD
*&---------------------------------------------------------------------*
FORM set_gibyresb_head.

  gs_mhdr-pstng_date = gs_i40-budat.
  gs_mhdr-doc_date   = sy-datlo.
  gs_mhdr-header_txt = '지중 MES 예약 불출'(t03).

*--> [CHM2509-00567] 예약 이동유형에 따른 구분
*  GS_MCOD-GM_CODE = '04'. "Transfer posting

  CLEAR : gv_bwart.
  SELECT SINGLE bwart
    INTO gv_bwart
    FROM resb
   WHERE rsnum = gs_i40-rsnum
     AND rspos = gs_i40-rspos.

  IF gv_bwart = '201'.
    gs_mcod-gm_code = '03'. "Goods Issue
  ELSE.
    gs_mcod-gm_code = '04'. "Transfer posting
  ENDIF.
*<-- [CHM2509-00567] 예약 이동유형에 따른 구분

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GIBYRESB_ITEM
*&---------------------------------------------------------------------*
FORM set_gibyresb_item.

  CLEAR : gt_mitm.

*--> [CHM2509-00567] 예약 이동유형에 따른 구분
  DATA : lv_parbu LIKE rkpf-parbu,
         lv_pargb LIKE rkpf-pargb,
         lv_lgpro LIKE marc-lgpro,
         lv_lgfsb LIKE marc-lgfsb,
         lv_beskz LIKE marc-beskz,
         lv_kostl LIKE rkpf-kostl.
*<-- [CHM2509-00567] 예약 이동유형에 따른 구분

  gt_mitm-batch     = gs_i40-charg.
  gt_mitm-entry_qnt = gs_i40-erfmg.
  gt_mitm-entry_uom = gs_i40-meins.
  gt_mitm-reserv_no = gs_i40-rsnum.
  gt_mitm-res_item  = gs_i40-rspos.
  gt_mitm-withdrawn = gs_i40-kzear.
  gt_mitm-item_text = gs_i40-sgtxt.

*--> [CHM2509-00567] 예약 이동유형에 따른 구분
  IF gv_bwart = '201'.
    CLEAR : lv_parbu, lv_pargb, lv_kostl.

    SELECT  SINGLE
            a~kostl a~parbu a~pargb
      INTO  (lv_kostl, lv_parbu, lv_pargb)
      FROM  rkpf AS a
     WHERE  a~rsnum = gs_i40-rsnum.

    gt_mitm-costcenter = lv_kostl.
    gt_mitm-par_compco = lv_parbu.
    gt_mitm-tr_part_ba = lv_pargb.

    CLEAR : lv_lgpro, lv_lgfsb, lv_beskz.

    SELECT  SINGLE
            a~lgpro a~lgfsb a~beskz
      INTO  (lv_lgpro, lv_lgfsb, lv_beskz)
      FROM  marc AS a
            INNER JOIN resb AS b
              ON a~werks = b~werks
              AND a~matnr = b~matnr
     WHERE  b~rsnum = gs_i40-rsnum
       AND  b~rspos = gs_i40-rspos.

    IF lv_beskz = 'E'.
      gt_mitm-stge_loc = lv_lgpro.
    ELSEIF lv_beskz = 'F'.
      gt_mitm-stge_loc = lv_lgfsb.
    ENDIF.
  ENDIF.
*<-- [CHM2509-00567] 예약 이동유형에 따른 구분
  APPEND gt_mitm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_GIBYRESB_RCV
*&---------------------------------------------------------------------*
FORM rtn_gibyresb_rcv USING pv_rst
                            pv_msg.

*  CLEAR : GT_I41, GT_9121.
*
*  GT_I41-MBLNR   = GS_MHDRT-MAT_DOC.  "자재문서번호
*  GT_I41-MJAHR   = GS_MHDRT-DOC_YEAR. "자재전표연도
*  GT_I41-ZRESULT = PV_RST.
*  GT_I41-MESSAGE = PV_MSG.
*
*  MODIFY GT_I41 TRANSPORTING MBLNR MJAHR ZRESULT MESSAGE
*                       WHERE ZRESULT IS INITIAL.


  "Log table
  gt_9121[] = VALUE #( FOR ls_i40 IN gt_i40
                       ( VALUE #( BASE CORRESPONDING #( ls_i40 )
                                  zifkey  = gt_9000-zifkey
                                  mblnr   = gs_mhdrt-mat_doc
                                  mjahr   = gs_mhdrt-doc_year
                                  zresult = pv_rst
                                  message = pv_msg ) ) ).

* GT_I41[]  = VALUE #( FOR LS_9121 IN GT_9121
*                      ( VALUE #( BASE CORRESPONDING #( LS_9121 )
*                                 MBLNR = |{ LS_9121-MBLNR ALPHA = OUT }| ) ) ).
  LOOP AT gt_9121.
    CLEAR : gt_i41.
    MOVE-CORRESPONDING gt_9121 TO gt_i41.

    SHIFT gt_i41-rsnum LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT gt_i41-rspos LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    gt_i41-mblnr = |{ gt_i41-mblnr ALPHA = OUT }|.

    APPEND gt_i41.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RESB_ITEM
*&---------------------------------------------------------------------*
FORM set_resb_item.

  CLEAR : gt_res_change, gt_res_changex.

  gs_i40-rspos = |{ gs_i40-rspos ALPHA = IN }|.

  IF gs_i40-kzear = 'X'.
    gt_res_change-withdrawn = gs_i40-kzear. " 출고 완료
    gt_res_changex-withdrawn = gs_i40-kzear. " 출고 완료
  ELSE.
    gt_res_change-withdrawn = '　'.
    gt_res_changex-withdrawn = '　'.
  ENDIF.

  gt_res_change-res_item = gs_i40-rspos.  " 품목 번호
  APPEND gt_res_change.

  gt_res_changex-res_item = gs_i40-rspos.  " 품목 번호
  APPEND gt_res_changex.

  gv_resb = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_reservation_change
*&---------------------------------------------------------------------*
FORM bapi_reservation_change.

  gs_i40-rsnum = |{ gs_i40-rsnum ALPHA = IN }|.

  CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
    EXPORTING
      reservation               = gs_i40-rsnum
    TABLES
      reservationitems_changed  = gt_res_change
      reservationitems_changedx = gt_res_changex
      reservationitems_new      = gt_res_new
      return                    = gt_rtn2.

ENDFORM.
