*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1170BDC                                    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bom_modify_by_bdc
*&---------------------------------------------------------------------*
FORM bom_modify_by_bdc.
  DATA: lv_ausch   TYPE char6,
        lv_sortf   TYPE char10,
        lv_wkmgn   TYPE char17,
        lv_wksrt   TYPE char17,
        lv_wkend   TYPE char17,
        lv_fhank   TYPE char17,
        lv_message TYPE char100,
        lv_lgort   LIKE mard-lgort.

*// Modified by ZGODEV06 on 2026-05-28 {
  DATA lv_answer TYPE c.

  gs_grid2->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RETURN.
  ENDIF.
*// }

  READ TABLE gt_tail  WITH KEY chk  = 'X'
                               flag = 'GOOD'.
  IF sy-subrc <> 0.
    MESSAGE s001 WITH 'BOM /LC 정보 수정 대상자료가 없습니다.'.
    RETURN.
  ENDIF.

**// Modified by KSW on 2026-06-17 {
*  READ TABLE gt_tail WITH KEY chk = 'X'
*                              flag = 'ERROR'.
*
*  IF sy-subrc EQ 0.
*    MESSAGE s001 WITH '오류 자재는 선택을 제외하고 저장하세요.'.
*    RETURN.
*  ENDIF.
**// Modified by KSW on 2026-06-17 }

  LOOP AT gt_tail  WHERE chk  = 'X'
                     AND flag = 'GOOD'.
    REFRESH: gt_bdcdata, gt_messtab.
    CLEAR:   gt_bdcdata, gt_messtab, lv_message.

    WRITE: gt_tail-ausch TO lv_ausch  NO-GROUPING,
           gt_tail-wkmgn TO lv_sortf  NO-GROUPING NO-ZERO,
           gt_tail-wkmgn TO lv_wkmgn  NO-GROUPING NO-ZERO,
           gt_tail-wksrt TO lv_wksrt  NO-GROUPING,
           gt_tail-wkend TO lv_wkend  NO-GROUPING,
           gt_tail-fhank TO lv_fhank  NO-GROUPING.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0100'.
    PERFORM bdc_field       USING: 'RC29N-MATNR'
                                   gt_tail-matnr,
                                   'RC29N-WERKS'
                                   gp_werks,
                                   'RC29N-STLAN'
                                   gp_stlan,      " 용도
                                   'RC29N-STLAL'
                                   gt_tail-stlal,
                                   'BDC_OKCODE'
                                   '=KALL'.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '2110'.
    PERFORM bdc_field       USING: 'RC29K-STLST'
                                   '01',
                                   'BDC_OKCODE'
                                   '=FCPU'.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
    PERFORM bdc_field       USING: 'BDC_OKCODE'
                                   '=SETP'.       " 위치

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '0708'.
    PERFORM bdc_field       USING: 'BDC_CURSOR'
                                   'RC29P-SELPO',
                                   'RC29P-SELPO'
                                   gt_tail-posnr,
                                   'BDC_OKCODE'
                                   '=CLWI'.

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '2150'.
    PERFORM bdc_field       USING: 'RC29P-AUSKZ(01)'
                                   'X',
                                   'BDC_OKCODE'
                                   '=PALL'.         " 품목

    PERFORM bdc_dynpro      USING 'SAPLCSDI' '2130'.
    PERFORM bdc_field       USING: 'RC29P-AUSCH'
                                   lv_ausch.

*&  배치관리여부(SPACE=>미관리, 'X'=>관리)
    IF gt_tail-dpcbt = space.
      IF gt_tail-lgflg = 'X'.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=FCBU'.
      ELSE.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=PDAT'.       " 상태/설명 TAB

        PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
        PERFORM bdc_field    USING: 'RC29P-LGORT' gt_tail-lgort,
*// Modified by ZGODEV06 on 2026-05-28 {
                                    'RC29P-BEIKZ' gt_tail-beikz,
*// }
                                    'BDC_OKCODE'  '=FCBU'.
      ENDIF.
    ELSEIF gp_stlan = '6'.
      PERFORM bdc_field    USING: 'BDC_OKCODE'
                                  '=FCBU'.
    ELSE.
      IF gt_tail-calcm = '2'.
        PERFORM bdc_field USING: 'RC29P-SORTF'
                                 lv_sortf.
      ENDIF.

      IF gt_tail-lgflg = 'X'.                    " 저장위치 존재하면
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=CAB/CS_DATA'.
      ELSE.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=PDAT'.    " 상태/설명 TAB

        PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
        PERFORM bdc_field    USING: 'RC29P-LGORT' gt_tail-lgort,
*// Modified by ZGODEV06 on 2026-05-28 {
                                    'RC29P-BEIKZ' gt_tail-beikz,
*// }
                                    'BDC_OKCODE'  '=CAB/CS_DATA'.
      ENDIF.

      PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
      PERFORM bdc_field    USING: 'RC29P-/SAPMP/MET_LRCH'
                                  gt_tail-calcm,
                                  'RC29P-/SAPMP/FIX_AS_J'
                                  lv_wkmgn,
                                  'RC29P-/SAPMP/RUND_FAKT'
                                  '1',
                                  'BDC_OKCODE'
                                  '/00'.

      IF gt_tail-calcm = '2'.
        PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
        PERFORM bdc_field    USING: 'RC29P-/SAPMP/MAX_FERTL'
                                    lv_fhank,
                                    'BDC_OKCODE'
                                    '=FCBU'.
      ELSEIF gt_tail-calcm = 'Z1'.
        PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
        PERFORM bdc_field    USING: 'RC29P-/SAPMP/MAX_FERTL'
                                    lv_fhank,
                                    'RC29P-/SAPMP/FIX_AS_E'
                                    lv_wksrt,
                                    'RC29P-/SAPMP/FIX_AS_L'
                                    lv_wkend,
                                    'BDC_OKCODE'
                                    '=FCBU'.
      ELSEIF gt_tail-calcm = space.
        PERFORM bdc_dynpro   USING 'SAPLCSDI' '2130'.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=FCBU'.
      ENDIF.
    ENDIF.

    PERFORM bdc_transaction USING 'CS02'.

*&  처리결과를 읽는다.
    PERFORM edit_error_message  USING lv_message.

*&  BDC처리시 에러발생 여부 체크
    IF NOT lv_message IS INITIAL.
      gt_tail-message = lv_message.
    ELSE.
      COMMIT WORK  AND WAIT.

      gt_tail-flag = 'SUCC'.

*& 2010.08.10 CSR : C20100810_17193
*& 1801일 경우 해당 bom에 대하여 1xxx의 생산버젼이 있을 경우 BOM 변경
*반영
      IF gp_werks EQ '1801'.

        CLEAR : lv_message.
        PERFORM change_prod_version USING lv_message.

        IF NOT lv_message IS INITIAL.
          gt_tail-message = lv_message.
        ELSE.
          COMMIT WORK AND WAIT.
          gt_tail-flag = 'SUCC'.
        ENDIF.

      ENDIF.

*& 2014.03.03 CSR:기능개선_11724 저장위치 확인
*// Modified by ZGODEV06 on 2026-05-12 {
*      IF gt_tail-flag = 'SUCC'.
*        SELECT SINGLE lgort
*          INTO lv_lgort
*          FROM mard
*         WHERE matnr = gt_tail-idnrk
*           AND werks = gp_werks
*           AND lgort = gt_tail-lgort.
*
** 저장위치가 확장 않된 경우
*        IF sy-subrc NE 0.
*          PERFORM mmsc_extention_lgort USING gt_tail-idnrk
*                                             gt_tail-lgort
*                                             gt_tail-flag.
*          IF gt_tail-flag = 'E'.
*            gt_tail-message = '저장위치 확장 오류'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*// }
    ENDIF.

    MODIFY gt_tail.
  ENDLOOP.

ENDFORM.                    " bom_modify_by_bdc
