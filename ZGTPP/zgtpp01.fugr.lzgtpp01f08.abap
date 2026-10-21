*&---------------------------------------------------------------------*
*& Include          LZGTPP01F08
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form check_para_wo_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_para_wo_create  USING pv_mode pv_system_id pv_result pv_message
                                 pt_order  TYPE ty_t_zgtppsif0054
                                 pt_result TYPE ty_t_result
                         RAISING lcx_exception.

  pv_result  = zgtpp_if_const=>gc_if_rec_result-success.
  pv_message = TEXT-s00.

  gs_wo_create = VALUE #( mode     = pv_mode
                          zresult  = pv_result
                          zmessage = pv_message
                          order    = CORRESPONDING #( pt_order ) ).

  PERFORM wo_coreate_conv_parameter.

  DATA(lt_zgtppt1010) = zgtpp_cl_common=>get_code_value( iv_codegrp = '0010' ).

  CLEAR: gt_plaf, gt_crhd, gt_mkal, gt_marc, gt_zgtcvmstval.

  SELECT werks INTO TABLE @DATA(lt_t001w) FROM t001w ORDER BY werks.

  IF gs_wo_create-order IS NOT INITIAL.
    SELECT DISTINCT plnum, plwrk, pwwrk, matnr, gsmng, meins
      INTO CORRESPONDING FIELDS OF TABLE @gt_plaf
      FROM plaf
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE plnum EQ @gs_wo_create-order-plnum.

    SELECT DISTINCT matnr, werks, dpcbt
      INTO CORRESPONDING FIELDS OF TABLE @gt_marc
      FROM marc
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE matnr EQ @gs_wo_create-order-matnr
       AND werks EQ @gs_wo_create-order-werks.

    SELECT DISTINCT arbpl, werks, objid
      INTO CORRESPONDING FIELDS OF TABLE @gt_crhd
      FROM crhd
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE objty EQ @zgtpp_if_const=>gc_objty
       AND arbpl EQ @gs_wo_create-order-arbpl
       AND werks EQ @gs_wo_create-order-werks.

    SELECT DISTINCT matnr, werks, verid, plnty, plnnr, alnal
      INTO CORRESPONDING FIELDS OF TABLE @gt_mkal
      FROM mkal
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE matnr EQ @gs_wo_create-order-matnr
       AND werks EQ @gs_wo_create-order-werks
       AND verid EQ @gs_wo_create-order-verid.

    SELECT matnr, werks, pdcaproccode
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtcvmstval
      FROM zgtcvmstval
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE matnr EQ @gs_wo_create-order-matnr
       AND werks EQ @gs_wo_create-order-werks.

    SORT gt_plaf BY plnum.
    SORT gt_marc BY matnr werks.
    SORT gt_crhd BY arbpl werks.
    SORT gt_mkal BY matnr werks verid.
    SORT gt_zgtcvmstval BY matnr werks.
  ENDIF.

**// 송신 시스템.
*  IF pv_system_id IS INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e031 WITH TEXT-f01.
*  ENDIF.
*
**// 처리 모드
*  IF pv_mode IS INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e031 WITH TEXT-f04.
*    RETURN.
*  ELSEIF NOT contains( val = pv_mode  regex = '[C,D]' ).
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-m55.
*    RETURN.
*  ENDIF.
*
*  IF pt_order IS INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e031 WITH TEXT-f05.
*  ENDIF.

  LOOP AT gs_wo_create-order REFERENCE INTO DATA(lr_order).
    GET TIME STAMP FIELD lr_order->zifkey.
    lr_order->zsystem_id = pv_system_id.

    DATA(lv_matnr) = lr_order->matnr.

    PERFORM conversion_exit_matn1_output USING lv_matnr.

*//  MES 작업지시 번호.
    IF lr_order->workorderid IS INITIAL.
      MESSAGE e031 WITH TEXT-f06 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 플랜트.
    IF lr_order->werks IS INITIAL.
      MESSAGE e031 WITH TEXT-f07 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ELSE.
      READ TABLE lt_t001w TRANSPORTING NO FIELDS WITH KEY werks = lr_order->werks BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e093(c1) WITH lr_order->werks INTO lr_order->zerp_message.
        PERFORM append_check_message USING lr_order->* pt_result.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 계획 오더.
    IF lr_order->plnum IS NOT INITIAL.
      READ TABLE gt_plaf TRANSPORTING NO FIELDS WITH KEY plnum = lr_order->plnum BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e022 WITH lr_order->plnum INTO lr_order->zerp_message.
        PERFORM append_check_message USING lr_order->* pt_result.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 자재코드.
    IF lr_order->matnr IS INITIAL.
      MESSAGE e031 WITH TEXT-f09 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ELSE.
      READ TABLE gt_marc TRANSPORTING NO FIELDS WITH KEY matnr = lr_order->matnr
                                                         werks = lr_order->werks BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e023 WITH lv_matnr lr_order->werks INTO lr_order->zerp_message.
        PERFORM append_check_message USING lr_order->* pt_result.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 설비.
    IF lr_order->arbpl IS INITIAL.
      MESSAGE e031 WITH TEXT-f10 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ELSE.
      READ TABLE gt_crhd TRANSPORTING NO FIELDS WITH KEY arbpl = lr_order->arbpl
                                                         werks = lr_order->werks BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e024 WITH lr_order->arbpl INTO lr_order->zerp_message.
        PERFORM append_check_message USING lr_order->* pt_result.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 생산버전.
    IF lr_order->verid IS INITIAL.
      MESSAGE e031 WITH TEXT-f11 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ELSE.
      READ TABLE gt_mkal TRANSPORTING NO FIELDS WITH KEY matnr = lr_order->matnr
                                                         werks = lr_order->werks
                                                         verid = lr_order->verid BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e039(cfv) WITH lr_order->werks lv_matnr lr_order->verid INTO lr_order->zerp_message.
        PERFORM append_check_message USING lr_order->* pt_result.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 조장.
    IF lr_order->inlength IS INITIAL.
      MESSAGE e031 WITH TEXT-f12 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 조장수.
    IF lr_order->infactor IS INITIAL.
      MESSAGE e031 WITH TEXT-f13 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 조장 단위.
    IF lr_order->erfme IS INITIAL.
      MESSAGE e031 WITH TEXT-f14 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 총 오더 수량.
    IF lr_order->gamng IS INITIAL.
      MESSAGE e031 WITH TEXT-f15 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 오더 단위.
    IF lr_order->gmein IS INITIAL.
      MESSAGE e031 WITH TEXT-f16 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 기본 시작일.
    IF lr_order->gstrp IS INITIAL.
      MESSAGE e031 WITH TEXT-f17 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

*// 기본 종료일.
    IF lr_order->gltrp IS INITIAL.
      MESSAGE e031 WITH TEXT-f18 INTO lr_order->zerp_message.
      PERFORM append_check_message USING lr_order->* pt_result.
      CONTINUE.
    ENDIF.

    MOVE lr_order->zzorigin TO gv_origin.
  ENDLOOP.

  CONCATENATE '000' gv_origin INTO gv_origin.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form save_wo_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_wo_create RAISING lcx_exception.

  DATA lt_zgtppt2380 TYPE TABLE OF zgtppt2380.

  CLEAR gt_zgtppt2370.

  lt_zgtppt2380 = VALUE #( FOR ls_item IN gs_wo_create-order
                         ( VALUE #( BASE CORRESPONDING #( ls_item )  workorderid_o = ls_item-workorderid
                                                                     plnum_o       = ls_item-plnum
                                                                     zmode         = gs_wo_create-mode
                                                                     zstat         = gs_wo_create-zresult
                                                                     zmessage      = gs_wo_create-zmessage
                                                                     ifdat         = sy-datum
                                                                     iftim         = sy-uzeit
                                                                     ifnam         = sy-uname ) ) ).

  TRY.
      MODIFY zgtppt2380 FROM TABLE lt_zgtppt2380.

      COMMIT WORK AND WAIT.

    CATCH cx_root INTO DATA(lr_root).
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e00.
  ENDTRY.

  CHECK lt_zgtppt2380 IS NOT INITIAL.

  SORT lt_zgtppt2380 BY workorderid.
  DELETE ADJACENT DUPLICATES FROM lt_zgtppt2380 COMPARING workorderid.

  SELECT zt01~workorderid,
         coalesce( zt02~crdat, zt01~ifdat ) AS crdat,
         coalesce( zt02~crtim, zt01~iftim ) AS crtim,
         coalesce( zt02~crnam, zt01~ifdat ) AS crnam,
         zt01~ifdat AS chdat,
         zt01~iftim AS chtim,
         zt01~ifnam AS chnam
    FROM @lt_zgtppt2380  AS zt01
    LEFT JOIN zgtppt2370 AS zt02
      ON zt01~workorderid EQ zt02~workorderid
   WHERE zt01~workorderid NE @space
   ORDER BY zt01~workorderid
    INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt2370.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_work_order  USING pt_result TYPE ty_t_result.

  LOOP AT gs_wo_create-order INTO DATA(ls_order).
    READ TABLE gt_zgtppt2370 INTO DATA(ls_zgtppt2370)
                             WITH KEY workorderid = ls_order-workorderid BINARY SEARCH.

    APPEND INITIAL LINE TO pt_result[] REFERENCE INTO DATA(lr_result).

    TRY.
*// 생산오더 생성.
        PERFORM create_production_order USING ls_order lr_result->* ls_zgtppt2370.

*// 계획오더 변경.
        PERFORM change_planned_order USING ls_order lr_result->*.

        PERFORM update_wo_create_log USING ls_order lr_result->* ls_zgtppt2370.

*// 생산오더 변경.
        PERFORM change_production_order_by_bdc USING ls_order lr_result->*.

      CATCH lcx_exception INTO DATA(lr_exception).
        ROLLBACK WORK.

        PERFORM update_wo_create_log USING ls_order lr_result->* ls_zgtppt2370.
    ENDTRY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_production_order_by_bdc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_production_order_by_bdc  USING ps_order  TYPE ty_s_order
                                           ps_result TYPE zgtppsif0055
                                   RAISING lcx_exception.

  DATA lt_bdcdata  TYPE TABLE OF bdcdata.
  DATA lt_messtab  TYPE TABLE OF bdcmsgcoll.
  DATA lv_inlength TYPE char18.
  DATA lv_infactor TYPE char18.
  DATA lv_aufnr TYPE aufnr.

  CLEAR: lv_aufnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ps_result-aufnr
    IMPORTING
      output = lv_aufnr.

  "ZZORIGN Update
  UPDATE aufk SET zzorigin = ps_order-zzorigin
            WHERE aufnr = lv_aufnr.

  READ TABLE gt_marc INTO DATA(ls_marc) WITH KEY matnr = ps_order-matnr
                                                 werks = ps_order-werks BINARY SEARCH.
  CHECK: sy-subrc          IS INITIAL,
         ps_order-inlength IS NOT INITIAL,
         ls_marc-dpcbt     IS NOT INITIAL.

  CHECK gs_kdauf IS INITIAL.  "판매오더 기준으로 오더를 생성시, 특성 변경 CO02 불가하므로 배제

  DO 10 TIMES.
    SELECT SINGLE @abap_true INTO @DATA(lv_check) FROM aufk WHERE aufnr EQ @lv_aufnr. "ps_result-aufnr.
    IF sy-subrc IS INITIAL.
      EXIT.
    ELSE.
      WAIT UP TO '0.5' SECONDS.
    ENDIF.
  ENDDO.

  READ TABLE gt_zgtcvmstval INTO DATA(ls_zgtcvmstval) WITH KEY matnr = ps_order-matnr
                                                               werks = ps_order-werks BINARY SEARCH.

  WRITE ps_order-inlength UNIT ps_order-erfme TO lv_inlength LEFT-JUSTIFIED.
  lv_infactor = ps_order-infactor.
  CONDENSE lv_infactor NO-GAPS.

  lt_bdcdata = VALUE #( ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0110' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=ENTK' )
                        ( dynbegin = ' '  fnam    = 'CAUFVD-AUFNR'        fval   = lv_aufnr ) "ps_result-aufnr )
                        ( dynbegin = ' '  fnam    = 'R62CLORD-FLG_OVIEW'  fval   = 'X' )

                        ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0115' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=KOTA' )

                        ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0115' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=MILL_BT_SEL_ALL' )

                        ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0115' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=MILL_BT_CONFIG' )

                        ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0115' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=MILL_BT_CONFIG' )

                        ( dynbegin = 'X'  program = 'SAPLCEI0'            dynpro = '0109' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=BACK' )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MNAME(01)'     fval   = 'SAP_MILLCA_LENGTH' )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MWERT(01)'     fval   = lv_inlength )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MNAME(02)'     fval   = 'SAP_MILLCA_FACTOR' )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MWERT(02)'     fval   = lv_infactor )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MNAME(03)'     fval   = 'PD_CA_PROC_NAME' )
                        ( dynbegin = ' '  fnam    = 'RCTMS-MWERT(03)'     fval   = ls_zgtcvmstval-pdcaproccode )

                        ( dynbegin = 'X'  program = 'SAPLCOKO1'           dynpro = '0115' )
                        ( dynbegin = ' '  fnam    = 'BDC_OKCODE'          fval   = '=BU'  ) ).

  DATA(ls_option) = VALUE ctu_params( dismode = 'N'
                                      updmode = 'S' ).

  CALL TRANSACTION 'CO02' USING lt_bdcdata OPTIONS  FROM ls_option
                                           MESSAGES INTO lt_messtab.

  READ TABLE lt_messtab INTO DATA(ls_messtab) WITH KEY msgtyp = 'S'
                                                       msgid  = 'CO'
                                                       msgnr  = '100'.
  IF sy-subrc IS INITIAL.
    DATA(lv_subrc) = sy-subrc.
  ELSE.
    lv_subrc = sy-subrc.
    ls_messtab = VALUE #( lt_messtab[ msgtyp = 'E' ] OPTIONAL ).
  ENDIF.

  DATA lv_message TYPE char100.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = ls_messtab-msgid
      msgnr               = ls_messtab-msgnr
      msgv1               = ls_messtab-msgv1
      msgv2               = ls_messtab-msgv2
      msgv3               = ls_messtab-msgv3
      msgv4               = ls_messtab-msgv4
    IMPORTING
      message_text_output = lv_message.

  ps_result = VALUE #( BASE ps_result  zerp_stat    = COND #( WHEN lv_subrc IS INITIAL THEN zgtpp_if_const=>gc_result-success
                                                              ELSE zgtpp_if_const=>gc_result-error )
                                       zerp_message = lv_message ).

  CHECK ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-error.

  RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH ps_result-zerp_message.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_work_order  USING pt_result TYPE ty_t_result.

  IF gs_wo_create-order IS NOT INITIAL.
    SELECT aufnr, werks, crtd, rel, del, dlfl, lkd, teco, clsd,
           pcnf, cnf, pdlv, dlv, payo
      INTO TABLE @DATA(lt_ord_stat)
      FROM zgtpp_cv_ord_stat
       FOR ALL ENTRIES IN @gs_wo_create-order
     WHERE aufnr EQ @gs_wo_create-order-aufnr.

    SORT lt_ord_stat BY aufnr.
  ENDIF.

  LOOP AT gs_wo_create-order INTO DATA(ls_order).
    READ TABLE gt_zgtppt2370 INTO DATA(ls_zgtppt2370)
                             WITH KEY workorderid = ls_order-workorderid BINARY SEARCH.

    APPEND INITIAL LINE TO pt_result[] REFERENCE INTO DATA(lr_result).
    lr_result->* = VALUE #( workorderid = ls_order-workorderid
                            aufnr       = ls_order-aufnr
                            plnum       = ls_order-plnum ).

    READ TABLE lt_ord_stat INTO DATA(ls_ord_stat) WITH KEY aufnr = ls_order-aufnr BINARY SEARCH.

    IF ls_ord_stat-del  EQ abap_true OR ls_ord_stat-dlfl EQ abap_true OR
       ls_ord_stat-teco EQ abap_true OR ls_ord_stat-clsd EQ abap_true.
      lr_result->zerp_stat    = zgtpp_if_const=>gc_result-error.
      lr_result->zerp_message = TEXT-s51.
    ELSEIF ls_ord_stat-pcnf EQ abap_true OR ls_ord_stat-cnf EQ abap_true OR
           ls_ord_stat-pdlv EQ abap_true OR ls_ord_stat-dlv EQ abap_true OR
           ls_ord_stat-payo EQ abap_true.
      lr_result->zerp_stat = zgtpp_if_const=>gc_result-error.
      MESSAGE e034 WITH ls_order-aufnr INTO lr_result->zerp_message.
    ENDIF.

    IF lr_result->zerp_stat IS NOT INITIAL.
      PERFORM update_wo_create_log USING ls_order lr_result->* ls_zgtppt2370.
      CONTINUE.
    ENDIF.

    TRY.
        PERFORM delete_production_order USING ls_order lr_result->* ls_zgtppt2370.

        IF lr_result->zerp_stat EQ zgtpp_if_const=>gc_result-success.
          PERFORM change_planned_order USING ls_order lr_result->*.
        ENDIF.

        PERFORM update_wo_create_log USING ls_order lr_result->* ls_zgtppt2370.

      CATCH lcx_exception INTO DATA(lr_exception).
        ROLLBACK WORK.

        PERFORM update_wo_create_log USING ls_order lr_result->* ls_zgtppt2370.
    ENDTRY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WO_COREATE_CONV_PARAMETER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM wo_coreate_conv_parameter .

  LOOP AT gs_wo_create-order REFERENCE INTO DATA(lr_order).
*// 계획 오더.
    IF lr_order->plnum IS NOT INITIAL.
      lr_order->plnum = |{ lr_order->plnum ALPHA = IN }|.
    ENDIF.

*// 생산 오더.
    IF lr_order->aufnr IS NOT INITIAL.
      lr_order->aufnr = |{ lr_order->aufnr ALPHA = IN }|.
    ENDIF.

    IF  lr_order->matnr IS NOT INITIAL.
      PERFORM conversion_exit_matn1_input USING lr_order->matnr.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_planned_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_planned_order   USING ps_order  TYPE ty_s_order
                                  ps_result TYPE zgtppsif0055
                          RAISING lcx_exception.

  DATA ls_headerdata  TYPE bapiplaf_i2.
  DATA ls_headerdatax TYPE bapiplaf_i2x.
  DATA ls_return TYPE bapireturn1.

  CHECK ps_order-plnum IS NOT INITIAL.

  PERFORM set_para_change_planned_order USING ps_order ls_headerdata ls_headerdatax.

  CHECK ls_headerdata-total_plord_qty IS NOT INITIAL.

  CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
    EXPORTING
      plannedorder = ps_order-plnum
      headerdata   = ls_headerdata
      headerdatax  = ls_headerdatax
    IMPORTING
      return       = ls_return.

  ps_result = VALUE #( BASE ps_result  zerp_stat    = COND #( WHEN ls_return-type NE zgtpp_if_const=>gc_result-success THEN zgtpp_if_const=>gc_result-error
                                                              ELSE zgtpp_if_const=>gc_result-success )
                                       zerp_message = ls_return-message ).

  IF ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-error.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH ps_result-zerp_message.
  ELSE.
    IF gs_wo_create-mode EQ 'C'. "// 생성.
      PERFORM insert_zgtppt2340 USING ps_order ps_result.
    ELSE.                        "// 삭제.
      PERFORM delete_zgtppt2340 USING ps_order ps_result.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_production_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_production_order  USING  ps_order      TYPE ty_s_order
                                     ps_result     TYPE zgtppsif0055
                                     ps_zgtppt2370 TYPE zgtppt2370
                             RAISING lcx_exception.
**** Start. 2026.07.20 기존 생산오더의 판매오더 존재시, 대입 추가
  SELECT SINGLE kdauf, kdpos
     FROM afpo
   WHERE aufnr = @gv_origin
       INTO CORRESPONDING FIELDS OF @gs_kdauf.

  DATA(ls_orderdata) = VALUE bapi_pp_order_create( material              = CONV co_matnr18( ps_order-matnr )
                                                   plant                 = ps_order-werks
                                                   order_type            = 'PP01'
                                                   basic_start_date      = ps_order-gstrp
                                                   basic_end_date        = ps_order-gltrp
                                                   quantity              = ps_order-gamng
                                                   quantity_uom          = ps_order-gmein
                                                   prod_version          = ps_order-verid
                                                   basic_scheduling_type = '7'
                                                   sales_order         =  gs_kdauf-kdauf
                                                   sales_order_item = gs_kdauf-kdpos ).
*** End. 2026.07.20 기존 생산오더의 판매오더 존재시, 대입 추가


  DATA lt_return TYPE TABLE OF bapi_order_return.
  DATA ls_return TYPE bapiret2.
  DATA lv_aufnr  TYPE bapi_order_key-order_number.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      orderdata    = ls_orderdata
    IMPORTING
      return       = ls_return
      order_number = lv_aufnr.

  ps_result = VALUE #( workorderid  = ps_order-workorderid
                       aufnr        = |{ lv_aufnr ALPHA = OUT }|
                       plnum        = |{ ps_order-plnum ALPHA = OUT }|
                       zerp_stat    = COND #( WHEN lv_aufnr IS NOT INITIAL THEN zgtpp_if_const=>gc_result-success
                                              ELSE zgtpp_if_const=>gc_result-error )
                       zerp_message = COND #( WHEN ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-success THEN |생산오더번호 { ps_result-aufnr } 를 생성했습니다.|
                                              ELSE ls_return-message ) ).

  ps_zgtppt2370 = VALUE #( BASE ps_zgtppt2370  aufnr = lv_aufnr
                                               plnum = ps_order-plnum ).

  IF lv_aufnr IS NOT INITIAL.
    WAIT UP TO '0.5' SECONDS.

    DATA(lt_orders) = VALUE tb_bapi_order_key( ( order_number = lv_aufnr ) ).

    CALL FUNCTION 'BAPI_PRODORD_RELEASE'
      TABLES
        orders        = lt_orders
        detail_return = lt_return.

    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type   = 'I'
                                                         id     = 'CO'
                                                         number = '093'.
    IF sy-subrc IS NOT INITIAL.
      ps_result-zerp_stat   = zgtpp_if_const=>gc_result-error.
      ps_result-zerp_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    ENDIF.
  ENDIF.

  CHECK ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-error.

  RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH ps_result-zerp_message.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delete_production_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_production_order  USING  ps_order      TYPE ty_s_order
                                     ps_result     TYPE zgtppsif0055
                                     ps_zgtppt2370 TYPE zgtppt2370
                             RAISING lcx_exception.

  DATA lt_return TYPE TABLE OF bapi_order_return.

  DATA(lt_orders) = VALUE tb_bapi_order_key( ( order_number = ps_order-aufnr  ) ).

  CALL FUNCTION 'BAPI_PRODORD_COMPLETE_TECH'
    TABLES
      orders        = lt_orders
      detail_return = lt_return.

  DATA(ls_return) = VALUE #( lt_return[ 1 ] OPTIONAL ).

  ps_result = VALUE #( BASE ps_result zerp_stat    = COND #( WHEN ls_return-type NE zgtpp_if_const=>gc_result-error THEN zgtpp_if_const=>gc_result-success
                                                             ELSE zgtpp_if_const=>gc_result-error )
                                      zerp_message = ls_return-message ).

  ps_zgtppt2370 = VALUE #( BASE ps_zgtppt2370 aufnr = ps_order-aufnr
                                              plnum = ps_order-plnum
                                              lkenz = COND #( WHEN ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-success THEN abap_true ) ).

  CHECK ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-error.

  RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH ps_result-zerp_message.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_para_change_planned_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_para_change_planned_order  USING  ps_order       TYPE ty_s_order
                                           ps_headerdata  TYPE bapiplaf_i2
                                           ps_headerdatax TYPE bapiplaf_i2x.

  DATA lt_operation TYPE TABLE OF capp_opr.

  READ TABLE gt_mkal INTO DATA(ls_mkal) WITH KEY matnr = ps_order-matnr
                                                 werks = ps_order-werks
                                                 verid = ps_order-verid BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'CARO_ROUTING_READ'
      EXPORTING
        plnty        = ls_mkal-plnty
        plnnr        = ls_mkal-plnnr
        plnal        = ls_mkal-alnal
        matnr        = ls_mkal-matnr
        werks        = ls_mkal-werks
      TABLES
        opr_tab      = lt_operation
      EXCEPTIONS
        not_found    = 1
        ref_not_exp  = 2
        not_valid    = 3
        no_authority = 4
        OTHERS       = 5.

    READ TABLE gt_crhd INTO DATA(ls_crhd) WITH KEY arbpl = ps_order-arbpl
                                                   werks = ps_order-werks BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      READ TABLE lt_operation INTO DATA(ls_operation) WITH KEY arbid = ls_crhd-objid.
    ENDIF.
  ENDIF.

  CHECK ls_operation-/sapmp/max_fertl IS NOT INITIAL.

  READ TABLE gt_plaf INTO DATA(ls_plaf) WITH KEY plnum = ps_order-plnum BINARY SEARCH.

  IF gs_wo_create-mode EQ 'C'.
    ls_plaf-gsmng = ls_plaf-gsmng - ps_order-gamng.
  ELSE.
    ls_plaf-gsmng = ls_plaf-gsmng + ps_order-gamng.
  ENDIF.

  IF ls_plaf-gsmng LT ls_operation-/sapmp/max_fertl.
    ls_plaf-gsmng = ls_operation-/sapmp/max_fertl.  "// 최대 생산 길이.
  ENDIF.

  ps_headerdata  = VALUE #( total_plord_qty = ls_plaf-gsmng ).
  ps_headerdatax = VALUE #( total_plord_qty = abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_wo_create_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_wo_create_log  USING  ps_order      TYPE ty_s_order
                                  ps_result     TYPE zgtppsif0055
                                  ps_zgtppt2370 TYPE zgtppt2370.

  UPDATE zgtppt2380
     SET workorderid_o = ps_result-workorderid
         aufnr_o       = ps_result-aufnr
         plnum_o       = ps_result-plnum
         zstat         = gs_wo_create-zresult
         zmessage      = gs_wo_create-zmessage
         zerp_stat     = ps_result-zerp_stat
         zerp_message  = ps_result-zerp_message
   WHERE zifkey      EQ ps_order-zifkey
     AND zsystem_id  EQ ps_order-zsystem_id
     AND workorderid EQ ps_order-workorderid.

  IF ps_result-zerp_stat EQ zgtpp_if_const=>gc_result-success.
    MODIFY zgtppt2370 FROM ps_zgtppt2370.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_zgtppt2340
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_zgtppt2340  USING ps_order  TYPE ty_s_order
                              ps_result TYPE zgtppsif0055.

  SELECT SINGLE *
    INTO @DATA(ls_zgtppt2330)
    FROM zgtppt2330
   WHERE werks EQ @ps_order-werks
     AND plnum EQ @ps_order-plnum.

  CHECK sy-subrc IS INITIAL.

  MODIFY zgtppt2340 FROM @( VALUE #( werks    = ls_zgtppt2330-werks
                                     spgcd    = ls_zgtppt2330-spgcd
                                     rqmon    = ls_zgtppt2330-rqmon
                                     gong_cd  = ls_zgtppt2330-gong_cd
                                     zwkreq   = ls_zgtppt2330-zwkreq
                                     matnr    = ps_order-matnr
                                     ordnr    = |{ ps_result-aufnr ALPHA = IN }|
                                     posnr    = '000001'
                                     ordty    = 'PRD'
                                     inlength = COND #( WHEN ps_order-inlength IS NOT INITIAL THEN ps_order-inlength
                                                        ELSE ps_order-gamng )
                                     infactor = COND #( WHEN ps_order-infactor IS NOT INITIAL THEN ps_order-infactor
                                                        ELSE 1 )
                                     gong_seq = ls_zgtppt2330-gong_seq ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_zgtppt2340
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_zgtppt2340  USING ps_order  TYPE ty_s_order
                              ps_result TYPE zgtppsif0055.

  DELETE FROM zgtppt2340 WHERE werks EQ ps_order-werks
                           AND ordnr EQ ps_order-aufnr
                           AND posnr EQ '000001'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_check_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM append_check_message  USING  ps_order  TYPE ty_s_order
                                  pt_result TYPE ty_t_result.

  ps_order-zerp_stat = zgtpp_if_const=>gc_result-error.

  APPEND INITIAL LINE TO pt_result REFERENCE INTO DATA(lr_result).

  lr_result->* = VALUE #( workorderid  = ps_order-workorderid
                          zerp_stat    = ps_order-zerp_stat
                          zerp_message = ps_order-zerp_message ).

ENDFORM.
