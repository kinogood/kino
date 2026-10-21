*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  pai_check_period_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_period_scr7000 INPUT.

  IF ztitcsk-bldat IS INITIAL.
    PERFORM no_input_check USING 'ZTITCSK' 'BLDAT' c_error.
  ENDIF.

  IF ztitcsk-budat IS INITIAL.
    PERFORM no_input_check USING 'ZTITCSK' 'BUDAT' c_error.
  ENDIF.

*  IF ZTITCSK-zfbdt IS INITIAL.
*    ZTITCSK-zfbdt = ZTITCSK-budat.
*  ENDIF.
  CLEAR ztitcsk-gjahr.
  g_monat = ztitcsk-monat.

  PERFORM periode_determine USING ztitcsk-bukrs
                                  ztitcsk-budat
                                  ztitcsk-gjahr
                                  ztitcsk-monat.

  IF NOT g_monat IS INITIAL
  AND    g_monat NE ztitcsk-monat
  AND ( sy-binpt = space AND sy-calld = space ).
    MESSAGE w000(f5) WITH g_monat ztitcsk-budat ztitcsk-monat.
  ENDIF.

ENDMODULE.                 " pai_check_period_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  belegart_check_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE belegart_check_scr7000 INPUT.

  IF ztitcsk-blart IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BLART'.
  ENDIF.

*> 문서 종류 체크.
  PERFORM belegart_pruefen(sapff001)
          USING ztitcsk-blart ztitcsk-gjahr.
*> 전기년도 체크.
  bkpf-bukrs = ztitcsk-bukrs.
  PERFORM nummernkreis_lesen(sapff001)
          USING ztitcsk-gjahr.
*> 권한 검증.
  PERFORM belegart_authority_check.

ENDMODULE.                 " belegart_check_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  vendor_account_check_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE vendor_account_check_scr7000 INPUT.

*  IF ztitcsk-lifnr IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'LIFNR'.
*  ENDIF.
*
*  CALL FUNCTION 'FI_POSTING_KEY_DATA'
*    EXPORTING
*      i_bschl       = '31'
*      i_umskz       = space       ">bseg-umskz
*    IMPORTING
*      e_t074u       = t074u
*      e_tbsl        = tbsl
*      e_tbslt       = tbslt
*    EXCEPTIONS
*      error_message = 1.
*
** 1. PBO: no message if bschl request umskz
*  IF sy-subrc = 1.
** (del) if not ( firstcall = 'X'                           "Note 352492
*    IF tbsl-xsonu NE space.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH
*              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*  ENDIF.
*
**>> VENDOR MASTER DEFINE.
*  CLEAR : lfa1.
*  SELECT SINGLE * INTO lfa1 FROM lfa1
*                  WHERE lifnr EQ ztitcsk-lifnr.
*  IF sy-subrc NE 0.
*    MESSAGE e924 WITH '구매처' ztitcsk-lifnr.
*  ENDIF.
*
*  CALL FUNCTION 'FI_VENDOR_DATA'
*    EXPORTING
*      i_bukrs = ztitcsk-bukrs
*      i_lifnr = ztitcsk-lifnr
*    IMPORTING
*      e_kred  = vf_kred.
*
*  ztitcsk-xcpdk = vf_kred-xcpdk.
*
**    IF ZTBKPF-ZTERM IS INITIAL.
**       ZTBKPF-ZTERM = VF_KRED-ZTERM.
**    ELSEIF ZTBKPF-ZTERM NE VF_KRED-ZTERM.
*  IF ztitcsk-zterm NE vf_kred-zterm.
*    IF ztitcsk-zterm IS INITIAL.
*      ztitcsk-zterm = vf_kred-zterm.
*    ELSE.
*      IF g_term_changed EQ 'X'.
*        MESSAGE w855 WITH ztitcsk-zterm
*                        ztitcsk-lifnr vf_kred-zterm.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
**> 지급조건.
*  IF ztitcsk-zterm IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-ZTERM' c_error.
*  ELSE.
*    SELECT * FROM t052
*             WHERE zterm EQ ztitcsk-zterm.
*    ENDSELECT.
*
*    IF sy-subrc NE 0.
*      MESSAGE e839(f5) WITH ztitcsk-zterm.
*    ENDIF.
*  ENDIF.
*
**  IF ztitcsk-zterm NE ztstiga-zterm.
*  IF NOT ztitcsk-zterm IS INITIAL.
*    SELECT SINGLE *
*      FROM ztstiga
*     WHERE zterm EQ ztitcsk-zterm.
*    IF sy-subrc NE 0.
*      MESSAGE e002(zmts00) WITH ztitcsk-zterm.
*    ENDIF.
*  ELSE.
*    CLEAR ztstiga.
*  ENDIF.
**  ENDIF.
*
*  IF NOT ztitcsk-empfk IS INITIAL.
**> IMG화.
*    IF ztitig00-lfzac EQ c_charp.
*      CLEAR: g_bukrs.
*    ELSEIF ztitig00-lfzac EQ c_chara.
*      g_bukrs = ztitcsk-bukrs.
*    ENDIF.
*
*    SELECT SINGLE empfk INTO ztitcsk-empfk
*           FROM   lfza
*           WHERE  lifnr = ztitcsk-lifnr
*           AND    bukrs = g_bukrs
*           AND    empfk = ztitcsk-empfk.
*    IF sy-subrc NE 0.
**      IF vf_kred-lnrza NE ZTITCSK-empfk.
*      SET CURSOR FIELD 'ZTITCSK-EMPFK'.
*      MESSAGE e858 .
**      ENDIF.
*    ENDIF.
*  ENDIF.
*  IF NOT ztitcsk-empfk IS INITIAL.
*    SELECT SINGLE * INTO *lfa1
*           FROM lfa1
*           WHERE  lifnr EQ ztitcsk-empfk.
*  ELSE.
*    CLEAR *lfa1.
*  ENDIF.
*
**  IF ZTITCSK-mwskz IS INITIAL.
**    PERFORM  check_mandatory_input USING 'ZTITCSK-MWSKZ' c_error.
**  ENDIF.
*
*  IF ztitcsk-akont IS INITIAL.
*    ztitcsk-akont = vf_kred-akont.
*  ENDIF.
*  IF ztitcsk-akont IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-AKONT' c_error.
*  ENDIF.
*
**>> TAX CODE CHECK.
*  CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
*    EXPORTING
*      i_bukrs  = ztitcsk-bukrs
*      i_hkont  = vf_kred-akont
*      i_koart  = 'K'
*      i_mwskz  = ztitcsk-mwskz
*      i_stbuk  = space
*      x_dialog = 'X'
*    IMPORTING
*      e_egrkz  = g_egrkz.
**> ??????.
**   IF ZTBKPF-WRBTR IS INITIAL AND ZTBKPF-WMWST IS INITIAL.
***      PERFORM NO_INPUT(SAPFMMEX) USING 'ZTBKPF' 'WRBTR'.
**      PERFORM P2000_NO_INPUT USING 'ZTBKPF' 'WRBTR'.
**      MESSAGE E934.
**   ENDIF.
**> ??.
*  IF ztitcsk-waers IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WAERS'.
*  ENDIF.
*
*  IF NOT ztitig00-chkbp IS INITIAL.
*    IF ztitcsk-bupla IS INITIAL.    ">
**      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
*      PERFORM  check_mandatory_input     USING  :
*                                    'ZTITCSK-BUPLA' ztitig00-chkbp.
*    ENDIF.
*  ENDIF.
*
*  IF NOT ztitig00-chkba IS INITIAL.
*    IF ztitcsk-gsber IS INITIAL.    ">
**      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
*      PERFORM  check_mandatory_input     USING  :
*                                    'ZTITCSK-GSBER' ztitig00-chkba.
*    ENDIF.
*  ENDIF.
*
*
************************************************************************
*
**> '03/12/02 -
**>  FI 모듈과 협의 후 사업영역은 스탠다드에서 자동 Setting되도록 함.
************************************************************************
*
**************************> Begin of Deleted<**************************
***> 사업영역 체크
**  IF ZTITCSK-gsber IS INITIAL.    ">
**    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'GSBER'.
**  ENDIF.
**
**  PERFORM  check_business_area  USING ZTITCSK-gsber.
*
*************************> End of Deleted <****************************
************************************************************************
*
**> Get Vendor master
*  PERFORM  get_import_vendors_text  USING c_success.
*
***>> TAX CALC..
**   IF ZTITCSK-XMWST EQ 'X'.
**      SELECT SINGLE * FROM T007A
**             WHERE KALSM EQ  T005-KALSM
**             AND   MWSKZ EQ  ZTITCSK-MWSKZ.
**      IF SY-SUBRC NE 0.
**         MESSAGE E495 WITH T005-KALSM ZTITCSK-MWSKZ.
**      ENDIF.
**
**      SELECT * FROM  KONP
**               WHERE KAPPL EQ 'TX'       ">??.
**               AND   KSCHL EQ 'KRIT'     ">?????.
**               AND   MWSK1 EQ ZTITCSK-MWSKZ.
**
**         MOVE: KONP-KBETR   TO   W_KBETR,         ">??.
**               KONP-KONWA   TO   W_KONWA.         ">??.
**         IF NOT W_KBETR IS INITIAL.
**            W_KBETR = W_KBETR / 10.
**         ENDIF.
**      ENDSELECT.
**
**      IF SY-SUBRC EQ 0.
**         IF NOT W_KBETR IS INITIAL.
**            PERFORM SET_CURR_CONV_TO_EXTERNAL
**                    USING ZTITCSK-WRBTR ZTITCSK-WAERS
**                          ZTITCSK-WMWST.
***>>>> ?? : (100 + %) =  X : % ======>
**            W_WMWST = ZTITCSK-WMWST.
**            BAPICURR-BAPICURR = ZTITCSK-WMWST * W_KBETR * 1000.
**            W_KBETR1 = W_KBETR.
**            W_KBETR = ( W_KBETR + 100 ).
**            BAPICURR-BAPICURR = BAPICURR-BAPICURR / W_KBETR.
**
***          ZTBKPF-WMWST = W_WMWST - ( BAPICURR-BAPICURR * 100 / 1000)
*  .
***           ZTBKPF-WMWST = ZTBKPF-WMWST / 10.
**            BAPICURR-BAPICURR = BAPICURR-BAPICURR / 1000.
**            ZTITCSK-WMWST = BAPICURR-BAPICURR.
***            COMPUTE ZTBKPF-WMWST = TRUNC( BAPICURR-BAPICURR ).
***            ZTBKPF-WMWST = ZTBKPF-WMWST * 10.
**
**            PERFORM SET_CURR_CONV_TO_INTERNAL
**                    USING ZTITCSK-WMWST ZTITCSK-WAERS.
**         ELSE.
**            CLEAR : ZTITCSK-WMWST.
**         ENDIF.
**      ELSE.
**         CLEAR : ZTITCSK-WMWST.
**      ENDIF.
**   ENDIF.
*
**> 물류송장검증일 경우.
***> 직기표일 경우.
**  IF ZTITCSK-ptdcl EQ c_charm.
**    IF ZTITCSK-wrbtr IS INITIAL.
**      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
**    ENDIF.
**  ENDIF.
*
**> 직기표일 경우.
*  IF ztitcsk-ptdcl EQ c_charf.
*    IF ztitcsk-akont IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'AKONT'.
*    ENDIF.
*    IF ztitcsk-wrbtr IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
*    ENDIF.
*  ENDIF.
*
**> 부가세 전기일 경우.
*  IF ztitcsk-ptdcl EQ c_charv.
*    IF ztitcsk-akont IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'AKONT'.
*    ENDIF.
**    IF ZTITCSK-wmwst IS INITIAL.
**      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WMWST'.
**    ENDIF.
*    IF NOT ztitcsk-wrbtr IS INITIAL.
*      IF ztitcsk-wmwst EQ ztitcsk-wrbtr.
*        IF ztitcsk-fwbas IS INITIAL.
**           PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'FWBAS'.
*          MESSAGE w857.
*          ztitcsk-fwbas = ztitcsk-wmwst * 10.
*        ENDIF.
*      ELSE.
*        MESSAGE e856.
*      ENDIF.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " vendor_account_check_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  determine_due_date_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE determine_due_date_scr7000 INPUT.

  g_term_changed = 'X'.

ENDMODULE.                 " determine_due_date_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_banktype_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_banktype_scr7000 INPUT.

  CLEAR: bseg, knb1, kna1.

*  break-point.
  CALL FUNCTION 'Z_TS_CHECK_BANK_TYPE'
    EXPORTING
      i_bukrs   = ztitcsk-bukrs
      i_bvtyp   = ztitcsk-bvtyp
      i_lifnr   = ztitcsk-lifnr
      i_empfb   = ztitcsk-empfk
    EXCEPTIONS
      no_input  = 1
      not_found = 2
      OTHERS    = 3.
  IF sy-subrc <> 0.
    SET CURSOR FIELD 'ZTITCSK-BVTYP'.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " check_banktype_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_fields_scr7000 INPUT.

  IF ztitcsk-vorgang IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'VORGANG'.
  ENDIF.

  IF ztitcsk-waers IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WAERS'.
  ENDIF.

  IF ztitcsk-cstyp IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'CSTYP'.
  ELSE.
*> 업무가불일 경우.
    IF ztitcsk-cstyp EQ c_chara.
*> Get 업무가불 Default value
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND cstct EQ c_charl.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ztitcsk-iname IS INITIAL.
        PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'INAME'.
      ENDIF.
      IF ztitcsk-hkont IS INITIAL.
        PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'HKONT'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ztitcsk-lifnr IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'LIFNR'.
  ENDIF.

  CALL FUNCTION 'FI_POSTING_KEY_DATA'
    EXPORTING
      i_bschl       = '31'
      i_umskz       = space       ">bseg-umskz
    IMPORTING
      e_t074u       = t074u
      e_tbsl        = tbsl
      e_tbslt       = tbslt
    EXCEPTIONS
      error_message = 1.

* 1. PBO: no message if bschl request umskz
  IF sy-subrc = 1.
* (del) if not ( firstcall = 'X'                           "Note 352492
    IF tbsl-xsonu NE space.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*>> VENDOR MASTER DEFINE.
  CLEAR : lfa1.
  SELECT SINGLE * INTO lfa1 FROM lfa1
                  WHERE lifnr EQ ztitcsk-lifnr.
  IF sy-subrc NE 0.
    MESSAGE e924 WITH '구매처' ztitcsk-lifnr.
  ENDIF.

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      i_bukrs = ztitcsk-bukrs
      i_lifnr = ztitcsk-lifnr
    IMPORTING
      e_kred  = vf_kred.

  ztitcsk-xcpdk = vf_kred-xcpdk.

*    IF ZTBKPF-ZTERM IS INITIAL.
*       ZTBKPF-ZTERM = VF_KRED-ZTERM.
*    ELSEIF ZTBKPF-ZTERM NE VF_KRED-ZTERM.
  IF ztitcsk-zterm NE vf_kred-zterm.
    IF ztitcsk-zterm IS INITIAL.
      ztitcsk-zterm = vf_kred-zterm.
    ELSE.
      IF g_term_changed EQ 'X'.
        MESSAGE w855 WITH ztitcsk-zterm
                        ztitcsk-lifnr vf_kred-zterm.
      ENDIF.
    ENDIF.
  ENDIF.

*> 지급조건.
  IF ztitcsk-zterm IS INITIAL.
    PERFORM  check_mandatory_input USING 'ZTITCSK-ZTERM' c_error.
  ELSE.
    SELECT * FROM t052
             WHERE zterm EQ ztitcsk-zterm.
    ENDSELECT.

    IF sy-subrc NE 0.
      MESSAGE e839(f5) WITH ztitcsk-zterm.
    ENDIF.
  ENDIF.

**  IF ztitcsk-zterm NE ztstiga-zterm.
*  IF NOT ztitcsk-zterm IS INITIAL.
*    SELECT SINGLE *
*      FROM ztstiga
*     WHERE zterm EQ ztitcsk-zterm.
*    IF sy-subrc NE 0.
*      MESSAGE e002(zmts00) WITH ztitcsk-zterm.
*    ENDIF.
*  ELSE.
*    CLEAR ztstiga.
*  ENDIF.
**  ENDIF.
*
  IF NOT ztitcsk-empfk IS INITIAL.
*by YSH(070628)JS전선 프로젝트시 회계뷰로 정의 --> 회사코드 인식
*> IMG화.
*    IF ztitig00-lfzac EQ c_charp.
*      CLEAR: g_bukrs.
*    ELSEIF ztitig00-lfzac EQ c_chara.
      g_bukrs = ztitcsk-bukrs.
*    ENDIF.

    SELECT SINGLE empfk INTO ztitcsk-empfk
           FROM   lfza
           WHERE  lifnr = ztitcsk-lifnr
           AND    bukrs = g_bukrs
           AND    empfk = ztitcsk-empfk.
    IF sy-subrc NE 0.
*      IF vf_kred-lnrza NE ZTITCSK-empfk.
      SET CURSOR FIELD 'ZTITCSK-EMPFK'.
      MESSAGE e858 .
*      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT ztitcsk-empfk IS INITIAL.
    SELECT SINGLE * INTO *lfa1
           FROM lfa1
           WHERE  lifnr EQ ztitcsk-empfk.
  ELSE.
    CLEAR *lfa1.
  ENDIF.

*  IF ZTITCSK-mwskz IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-MWSKZ' c_error.
*  ENDIF.

  IF ztitcsk-akont IS INITIAL.
    ztitcsk-akont = vf_kred-akont.
  ENDIF.
  IF ztitcsk-akont IS INITIAL.
    PERFORM  check_mandatory_input USING 'ZTITCSK-AKONT' c_error.
  ENDIF.

*>> TAX CODE CHECK.
  CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
    EXPORTING
      i_bukrs  = ztitcsk-bukrs
      i_hkont  = vf_kred-akont
      i_koart  = 'K'
      i_mwskz  = ztitcsk-mwskz
      i_stbuk  = space
      x_dialog = 'X'
    IMPORTING
      e_egrkz  = g_egrkz.
*> ??????.
*   IF ZTBKPF-WRBTR IS INITIAL AND ZTBKPF-WMWST IS INITIAL.
**      PERFORM NO_INPUT(SAPFMMEX) USING 'ZTBKPF' 'WRBTR'.
*      PERFORM P2000_NO_INPUT USING 'ZTBKPF' 'WRBTR'.
*      MESSAGE E934.
*   ENDIF.
*> ??.
  IF ztitcsk-waers IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WAERS'.
  ENDIF.

  IF NOT ztitig00-chkbp IS INITIAL.
    IF ztitcsk-bupla IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.

       PERFORM  check_mandatory_input     USING  :
                                   'ZTITCSK-BUPLA' ztitig00-chkbp.
    ENDIF.
  ENDIF.


  IF NOT ztitig00-chkba IS INITIAL.
    IF ztitcsk-gsber IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
       PERFORM  check_mandatory_input     USING  :
                                  'ZTITCSK-GSBER' ztitig00-chkba.
    ENDIF.
  ENDIF.


************************************************************************
*> '03/12/02 -
*>  FI 모듈과 협의 후 사업영역은 스탠다드에서 자동 Setting되도록 함.
************************************************************************
**************************> Begin of Deleted <**************************
**> 사업영역 체크
*  IF ZTITCSK-gsber IS INITIAL.    ">
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'GSBER'.
*  ENDIF.
*
*  PERFORM  check_business_area  USING ZTITCSK-gsber.

**************************> End of Deleted <****************************
************************************************************************
*> Get Vendor master
  PERFORM  get_import_vendors_text  USING c_success.

**>> TAX CALC..
*   IF ZTITCSK-XMWST EQ 'X'.
*      SELECT SINGLE * FROM T007A
*             WHERE KALSM EQ  T005-KALSM
*             AND   MWSKZ EQ  ZTITCSK-MWSKZ.
*      IF SY-SUBRC NE 0.
*         MESSAGE E495 WITH T005-KALSM ZTITCSK-MWSKZ.
*      ENDIF.
*
*      SELECT * FROM  KONP
*               WHERE KAPPL EQ 'TX'       ">??.
*               AND   KSCHL EQ 'KRIT'     ">?????.
*               AND   MWSK1 EQ ZTITCSK-MWSKZ.
*
*         MOVE: KONP-KBETR   TO   W_KBETR,         ">??.
*               KONP-KONWA   TO   W_KONWA.         ">??.
*         IF NOT W_KBETR IS INITIAL.
*            W_KBETR = W_KBETR / 10.
*         ENDIF.
*      ENDSELECT.
*
*      IF SY-SUBRC EQ 0.
*         IF NOT W_KBETR IS INITIAL.
*            PERFORM SET_CURR_CONV_TO_EXTERNAL
*                    USING ZTITCSK-WRBTR ZTITCSK-WAERS
*                          ZTITCSK-WMWST.
**>>>> ?? : (100 + %) =  X : % ======>
*            W_WMWST = ZTITCSK-WMWST.
*            BAPICURR-BAPICURR = ZTITCSK-WMWST * W_KBETR * 1000.
*            W_KBETR1 = W_KBETR.
*            W_KBETR = ( W_KBETR + 100 ).
*            BAPICURR-BAPICURR = BAPICURR-BAPICURR / W_KBETR.
*
**           ZTBKPF-WMWST = W_WMWST - ( BAPICURR-BAPICURR * 100 / 1000 )
  .
**           ZTBKPF-WMWST = ZTBKPF-WMWST / 10.
*            BAPICURR-BAPICURR = BAPICURR-BAPICURR / 1000.
*            ZTITCSK-WMWST = BAPICURR-BAPICURR.
**            COMPUTE ZTBKPF-WMWST = TRUNC( BAPICURR-BAPICURR ).
**            ZTBKPF-WMWST = ZTBKPF-WMWST * 10.
*
*            PERFORM SET_CURR_CONV_TO_INTERNAL
*                    USING ZTITCSK-WMWST ZTITCSK-WAERS.
*         ELSE.
*            CLEAR : ZTITCSK-WMWST.
*         ENDIF.
*      ELSE.
*         CLEAR : ZTITCSK-WMWST.
*      ENDIF.
*   ENDIF.

*> 물류송장검증일 경우.
**> 직기표일 경우.
*  IF ZTITCSK-ptdcl EQ c_charm.
*    IF ZTITCSK-wrbtr IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
*    ENDIF.
*  ENDIF.

*> 직기표일 경우.
  IF ztitcsk-ptdcl EQ c_charf.
    IF ztitcsk-akont IS INITIAL.
      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'AKONT'.
    ENDIF.
    IF ztitcsk-wrbtr IS INITIAL.
      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
    ENDIF.
  ENDIF.

*> 부가세 전기일 경우.
  IF ztitcsk-ptdcl EQ c_charv.
    IF ztitcsk-akont IS INITIAL.
      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'AKONT'.
    ENDIF.
*    IF ZTITCSK-wmwst IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WMWST'.
*    ENDIF.
    IF NOT ztitcsk-wrbtr IS INITIAL.
      IF ztitcsk-wmwst EQ ztitcsk-wrbtr.
        IF ztitcsk-fwbas IS INITIAL.
*           PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'FWBAS'.
          MESSAGE w857.
          ztitcsk-fwbas = ztitcsk-wmwst * 10.
        ENDIF.
      ELSE.
        MESSAGE e856.
      ENDIF.
    ENDIF.
  ENDIF.


  IF g_term_changed EQ c_true.
*    IF ztitcsk-zfbdt IS INITIAL.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        i_bldat = ztitcsk-bldat
        i_budat = ztitcsk-budat
        i_cpudt = sy-datlo
        i_zfbdt = ztitcsk-zfbdt
        i_zterm = ztitcsk-zterm
      IMPORTING
        e_zbd1t = ztitcsk-zbd1t
        e_zbd1p = ztitcsk-zbd1p
        e_zbd2t = ztitcsk-zbd2t
        e_zbd2p = ztitcsk-zbd2p
        e_zbd3t = ztitcsk-zbd3t
        e_zlsch = ztitcsk-zlsch
        e_zschf = ztitcsk-zlspr
*        e_zschf = g_zlspr
        e_zfbdt = ztitcsk-zfbdt.
*    ELSE.
*      CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
*        EXPORTING
*          i_bldat = ztitcsk-bldat
*          i_budat = ztitcsk-budat
*          i_cpudt = sy-datlo
*          i_zfbdt = ztitcsk-zfbdt
*          i_zterm = ztitcsk-zterm
*        IMPORTING
*          e_zbd1t = ztitcsk-zbd1t
*          e_zbd1p = ztitcsk-zbd1p
*          e_zbd2t = ztitcsk-zbd2t
*          e_zbd2p = ztitcsk-zbd2p
*          e_zbd3t = ztitcsk-zbd3t
*          e_zlsch = ztitcsk-zlsch
**          e_zschf = ztitcsk-zlspr.
*          e_zschf = ztitcsk-zlspr.
**          e_zfbdt = ztitcsk-zfbdt.
*    ENDIF.
*
  ENDIF.
  CLEAR g_term_changed.

*> 기준일 오류..
*  IF NOT ztstiga-fbdtm IS INITIAL.
    IF ztitcsk-zfbdt IS INITIAL.
      PERFORM  check_mandatory_input
*               USING 'ZTITCSK-ZFBDT' ztstiga-fbdtm.
               USING 'ZTITCSK-ZFBDT' 'E'.
    ENDIF.
*  ENDIF.

*> 만기일 계산.
  CLEAR: faede.

  faede-shkzg = 'H'.
  faede-koart = 'K'.
  faede-zfbdt = ztitcsk-zfbdt.
  faede-zbd1t = ztitcsk-zbd1t.
  faede-zbd2t = ztitcsk-zbd2t.
  faede-zbd3t = ztitcsk-zbd3t.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
  faede-bldat = ztitcsk-bldat.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede = faede
    IMPORTING
      e_faede = faede
    EXCEPTIONS
      OTHERS  = 1.

  ztitcsk-netdt = faede-netdt.

*> 현지통화 계산.
  IF ztitcsk-waers EQ  ztitcsk-hwaer.
    ztitcsk-dmbtr = ztitcsk-wrbtr.
  ELSE.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        client                  = sy-mandt
        date                    = ztitcsk-wwert
        foreign_amount          = ztitcsk-wrbtr
        foreign_currency        = ztitcsk-waers
        local_currency          = ztitcsk-hwaer
        rate                    = ztitcsk-kursf
        type_of_rate            = 'M'
*      READ_TCURR              = 'X'
       IMPORTING
*       EXCHANGE_RATE           =
*       FOREIGN_FACTOR          =
         local_amount            = ztitcsk-dmbtr
*       LOCAL_FACTOR            =
*       EXCHANGE_RATEX          =
*       FIXED_RATE              =
*       DERIVED_RATE_TYPE       =
       EXCEPTIONS
         no_rate_found           = 1
         overflow                = 2
         no_factors_found        = 3
         no_spread_found         = 4
         derived_2_times         = 5
         OTHERS                  = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

**> 지급보류 변경 가능일 경우.
**  IF NOT ztstiga-zlspm IS INITIAL AND
**     ztitcsk-zlspr IS INITIAL.
*  IF ztitcsk-zlspr IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-ZLSPR' ztstiga-zlspm.
*  ENDIF.

**> 지급방법 변경 가능일 경우.
**  IF NOT ztstiga-zlscm IS INITIAL AND
**     ztitcsk-zlsch IS INITIAL .
*  IF ztitcsk-zlsch IS INITIAL .
*    PERFORM  check_mandatory_input USING 'ZTITCSK-ZLSCH' ztstiga-zlscm.
*  ENDIF.

**> 지급방법보충 변경 가능이
**  IF NOT ztstiga-uzawm IS INITIAL AND
**     ztitcsk-uzawe IS INITIAL.
*  IF ztitcsk-uzawe IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-UZAWE' ztstiga-uzawm
.
*  ENDIF.
*
ENDMODULE.                 " check_input_fields_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7000 INPUT.

  CLEAR: g_term_changed .

  IF g_empfk_changed IS INITIAL.
    CALL FUNCTION 'Z_TI_EMPFK_NO_INPUT_CONFIRM'
      EXPORTING
        im_ztitig00 = ztitig00
        im_lifnr    = ztitcsk-lifnr
        im_empfk    = ztitcsk-empfk
      IMPORTING
        ex_answer   = g_answer.

    g_empfk_changed = 'X'.
  ENDIF.

*  CALL METHOD cl_gui_cfw=>dispatch
*    IMPORTING
*      return_code = g_return_code.
*  IF g_return_code <> cl_gui_cfw=>rc_noevent.
*    " a control event occured => exit PAI
*    CLEAR g_ok_code.
*    EXIT.
*  ENDIF.

  ok_code_old = ok-code.
  CASE ok-code.
    WHEN 'ABBR'.
      g_answer = 'A'.
      IF g_init EQ 'X'.
*        CALL METHOD g_docking->free.
        CLEAR: g_tree_7000, g_application.
        CLEAR: g_init.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      CLEAR: g_success_cnt, g_error_cnt.
      CLEAR: g_cnt.
      LOOP AT it_ztitcsk WHERE flag EQ 'X'.
        ADD 1 TO g_cnt.
      ENDLOOP.

      IF g_cnt EQ 0.
        MESSAGE e909.
      ENDIF.

*> 일괄전기 확인메시지 사용시.
*      IF ztitig00-pstcm EQ 'X'.
        CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
          EXPORTING
            xmode  = 'P'
*            im_doc = 'CS'
          IMPORTING
            answer = g_answer.

        IF g_answer EQ 'N'.
          ok_code = 'ABBR'.
          MESSAGE s900.
          IF g_init EQ 'X'.
            CALL METHOD g_docking->free.
            CLEAR: g_tree_7000, g_application.
            CLEAR: g_init.
          ENDIF.
          LEAVE TO SCREEN 0.
          EXIT.
        ELSEIF g_answer EQ 'A'.
          EXIT.
        ENDIF.
*      ENDIF.

*     Message Initialize
      CALL FUNCTION 'MESSAGES_INITIALIZE'
        EXPORTING
          reset = 'X'.

*> Screen상의 정보를 Setting
      g_icsno = ztitcsk-icsno.
      PERFORM get_new_node_data  USING g_icsno.
      MOVE-CORRESPONDING ztitcsk TO it_ztitcsk.

      CLEAR: g_count.
      LOOP AT it_ztitcsk WHERE flag EQ 'X'.
*        BREAK-POINT.
        PERFORM check_posting_data  USING g_subrc.
        IF g_subrc NE 0.
          ADD 1 TO g_count.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF g_count NE 0.
*> 메시지 Show...
        CALL FUNCTION 'MESSAGES_SHOW'
          EXPORTING
            show_linno = ' '.
        EXIT.
      ENDIF.

      LOOP AT it_ztitcsk WHERE flag EQ 'X'.
        g_tabix2 = sy-tabix.
        CLEAR: sy, g_subrc, bdcdata.
*> build BDC data
        PERFORM build_posting_data       USING g_subrc.
        IF g_subrc EQ 0.
*> Memory Clear
          CLEAR: *ztitcsk.
          EXPORT *ztitcsk TO MEMORY ID 'ZTIR9000'.
*> Call transaction
          PERFORM bdc_transaction        USING 'ZTIT901' g_subrc.
*> build Message internal table.
          CLEAR: *ztitcsk.
          IMPORT *ztitcsk FROM MEMORY ID 'ZTIR9000'.
          FREE MEMORY ID 'ZTIR9000'.
          IF *ztitcsk-icsno IS INITIAL.
            g_subrc = 4.
          ELSE.
            MOVE: *ztitcsk-icsno TO it_ztitcsk-icsex,
                  *ztitcsk-belnr TO it_ztitcsk-belnr,
                  *ztitcsk-bukrs TO it_ztitcsk-bukrs,
                  *ztitcsk-gjahr TO it_ztitcsk-gjahr,
                  *ztitcsk-livst TO it_ztitcsk-livst.
            MODIFY it_ztitcsk INDEX g_tabix2.

            REFRESH: it_ztstfbc.
            LOOP AT xztitcsp INTO it_ztitcsp.
              CHECK NOT it_ztitcsp-finno IS INITIAL.
              SELECT *
                INTO CORRESPONDING FIELDS OF it_ztstfbc
                FROM ztstfbc
               WHERE finno EQ it_ztitcsp-finno
                 AND fbseq EQ it_ztitcsp-fbseq.
                it_ztstfbc-sysyn = 'Y'.
                it_ztstfbc-bukrs = *ztitcsk-bukrs.
                it_ztstfbc-gjahr = *ztitcsk-gjahr.
                it_ztstfbc-icsno = *ztitcsk-icsno.
                it_ztstfbc-belnr = *ztitcsk-belnr.
                APPEND it_ztstfbc.
              ENDSELECT.
            ENDLOOP.
            DESCRIBE TABLE it_ztstfbc LINES g_line1.
            IF g_line1 GT 0.
              MODIFY ztstfbc FROM TABLE it_ztstfbc.
            ENDIF.
          ENDIF.

*> build Message internal table.
          PERFORM build_posted_message   USING g_subrc.
        ENDIF.

        IF g_subrc EQ 0.
          ADD 1 TO g_success_cnt.
        ELSE.
          ADD 1 TO g_error_cnt.
        ENDIF.
      ENDLOOP.

*> 메시지 Show...
      CALL FUNCTION 'MESSAGES_SHOW'
        EXPORTING
          show_linno = ' '.

      g_answer = 'Y'.

      IF g_init EQ 'X'.
        CALL METHOD g_docking->free.
        CLEAR: g_tree_7000, g_application.
        CLEAR: g_init.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

  CLEAR: ok-code.


ENDMODULE.                 " user_command_7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr7000 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITCSK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro USING ztitcsk-zterm.

ENDMODULE.                 " help_payment_term_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payer_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payer_scr7000 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITCSK-EMPKF'.
      IF screen-input EQ '1'.
        CLEAR: g_display.
      ELSE.
        g_display = 'X'.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.

*by YSH(070628)JS전선 프로젝트시 회계뷰로 정의 --> 회사코드 인식
*> IMG화.
*  IF ztitig00-lfzac EQ c_charp.
*    CLEAR: g_bukrs.
*  ELSEIF ztitig00-lfzac EQ c_chara.
    g_bukrs = ztitcsk-bukrs.
*  ENDIF.

  SELECT p~bukrs p~lifnr p~empfk h~name1
         INTO CORRESPONDING FIELDS OF TABLE xlfza
         FROM   lfa1 AS h INNER JOIN lfza AS p
         ON     h~lifnr   EQ  p~empfk
         WHERE  p~bukrs   EQ  g_bukrs
         AND    p~lifnr   EQ  ztitcsk-lifnr.

  IF sy-subrc NE 0.
    MESSAGE s854 WITH ztitcsk-lifnr.
    EXIT.
  ENDIF.

  dynprog = sy-repid.
  dynnr   = sy-dynnr.

  g_window_title = '대체 수취인 Help'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
           EXPORTING
*                RETFIELD        = 'OTYPE'
                retfield        = 'EMPFK'
                dynpprog        = dynprog
                dynpnr          = dynnr
                dynprofield     = 'ZTITCSK-EMPFK'
                window_title    = g_window_title
                value_org       = 'S'
                display         = g_display
           TABLES
                value_tab       = xlfza
           EXCEPTIONS
                parameter_error = 1
                no_values_found = 2
                OTHERS          = 3.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

ENDMODULE.                 " help_payer_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_bvtyp_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_bvtyp_scr7000 INPUT.

  CLEAR: g_kunnr.
  g_lifnr = ztitcsk-lifnr.

*------- Read alternative payee from dynpro ----------------------------
  PERFORM dynp_values_read
          USING 'ZTITCSK-EMPFK' g_f4rcode.                 "Note 206687
  IF g_f4rcode = 0.                                        "Note 206687
    READ TABLE f4hlp INDEX 1.                              "Note 206687
    IF NOT f4hlp-fieldvalue IS INITIAL.                    "Note 206687
      PERFORM alphaformat(sapff001)                        "Note 206687
        USING f4hlp-fieldvalue                             "Note 206687
              ztitcsk-empfk.                               "Note 206687
    ENDIF.                                                 "Note 206687
  ENDIF.                                                   "Note 206687

*------- Alternative payee/payer may be filled into LIFNR / KUNNR ------
  CALL FUNCTION 'LINEITEM_REPLACE_WITH_ALT_PAYE'
    EXPORTING
      i_filkd = ztitcsk-filkd
      i_bukrs = ztitcsk-bukrs
      i_empfb = ztitcsk-empfk                              "Note 206687
    CHANGING
      c_lifnr = g_lifnr
      c_kunnr = g_kunnr.

*------- Partnerbanktypen anzeigen -------------------------------------
  CALL FUNCTION 'FI_F4_BVTYP'
    EXPORTING
      i_kunnr = g_kunnr
      i_lifnr = g_lifnr
      i_xshow = space
    IMPORTING
      e_bvtyp = g_bvtyp.
  IF NOT g_bvtyp IS INITIAL.
    ztitcsk-bvtyp = g_bvtyp.
  ENDIF.

ENDMODULE.                 " help_bvtyp_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr7000 INPUT.

  g_answer = 'A'.
  IF g_init EQ 'X'.
    CALL METHOD g_docking->free.
    CLEAR: g_tree_7000, g_application.
    CLEAR: g_init.
  ENDIF.
  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr7000  INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_7000_user_command  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_7000'. do not change this line!
*> process user command
*----------------------------------------------------------------------*
MODULE tc_7000_user_command INPUT.
  ok-code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_7000'
                              'G_TC_7000_ITAB'
                              'FLAG'
                     CHANGING ok-code.
  sy-ucomm = ok-code.
ENDMODULE.                    "TC_7000_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_7000_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_7000_modify INPUT.

  MOVE-CORRESPONDING ztiscsit TO xztitcsp.

  MODIFY  xztitcsp
    INDEX tc_7000-current_line.

ENDMODULE.                 " tc_7000_modify  INPUT
