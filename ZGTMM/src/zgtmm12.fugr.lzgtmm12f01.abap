*----------------------------------------------------------------------*
***INCLUDE LZGTMM12F01.

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM F_CHECK_INPUT_VALUES_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&      --> IT_TAB
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM f_check_input_values_pogr_rcv  USING    pv_system_id
                                    pt_tab TYPE ty_t_zgtmms4005
                                    pt_tab2 TYPE ty_t_zgtmms4009
                           CHANGING cv_zo_result
                                    cv_zo_message.

  FIELD-SYMBOLS <ls_tab> TYPE zgtmms4005.
  FIELD-SYMBOLS <ls_tab2> TYPE zgtmms4009.

*  1-1) IMPORT PARAMETER 중 필수 전송 정보가 없는 경우 다음 값 RETURN 후 종료
* EXPORT PARAMETER                      VALUE
* ZO_RESULT                     "02"
* ZO_MESSAGE                      "필수 값이 누락되었습니다."

  IF pv_system_id EQ space.
    cv_zo_result = gc_02.
    cv_zo_message = TEXT-e01.
    EXIT.
  ENDIF.


*XCHPF = 'X' 이고, CHARG, LICHA, HSDAT 값이 공백이면 오류 -> 점검 로직 주석처리 2026.02.23
**1-2) BATCH 관리 대상 자재인경우 필수 필드점검, 값이 없는 경우다음 값 RETURN 후 종료
**: BATCH 관리 대상 여부 점검
**TABLE : MARC
**SELECT 조건 : XCHAR
**WHERE 조건:
**WERKS = 수신 받은 PO, ITEM의 플랜트
**MATNR = 수신 받은 PO, ITEM의 MATNR
**
**XCHPF = 'X' 이고, CHARG, LICHA, HSDAT 값이 공백이면 오류
**
**EXPORT PARAMETER                     VALUE
**ZO_RESULT                      "02"
**ZO_MESSAGE                     "필수 값이 누락되었습니다."
*
*  SELECT
*    MC~WERKS,
*    MC~MATNR
*    FROM MARC AS MC
*    WHERE EXISTS (
*        SELECT ZZ~WERKS, ZZ~MATNR
*          FROM @PT_TAB AS ZZ
*          WHERE ZZ~WERKS EQ MC~WERKS
*             AND ZZ~MATNR EQ MC~MATNR
*    )
*    AND MC~XCHPF EQ @ABAP_TRUE
*    ORDER BY MC~WERKS, MC~MATNR
*    INTO TABLE @DATA(LT_XCHAR).
*
*  IF SY-SUBRC EQ 0.
*    LOOP AT PT_TAB ASSIGNING <LS_TAB>.
*      "CHARG, LICHA, HSDAT 값이 공백인 경우 점검
*      CHECK <LS_TAB>-CHARG EQ SPACE OR <LS_TAB>-LICHA EQ SPACE  OR <LS_TAB>-HSDAT IS INITIAL  OR <LS_TAB>-HSDAT EQ SPACE.
*
*      "배치관리 대상인 경우 오류
*      READ TABLE LT_XCHAR WITH KEY WERKS = <LS_TAB>-WERKS MATNR = <LS_TAB>-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
*      CHECK SY-SUBRC EQ 0.
*      CV_ZO_RESULT = GC_02.
*      CV_ZO_MESSAGE = TEXT-E01.
*      EXIT.
*    ENDLOOP.
*  ENDIF.

  "구매오더 범주가 처리 불가능한 경우 오류
  CHECK cv_zo_result NE gc_02.
  LOOP AT pt_tab ASSIGNING <ls_tab>.
    CHECK <ls_tab>-pstyp NE space AND <ls_tab>-pstyp NE gc_3.
    cv_zo_result = gc_02.
    cv_zo_message = TEXT-e03.
    EXIT.
  ENDLOOP.

  LOOP AT pt_tab2 ASSIGNING <ls_tab2>.
    CHECK <ls_tab2>-pstyp NE space AND <ls_tab2>-pstyp NE gc_3.
    cv_zo_result = gc_02.
    cv_zo_message = TEXT-e03.
    EXIT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_CONV_EXIT_IN_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- LT_TAB
*&---------------------------------------------------------------------*
FORM f_conv_exit_in_pogr_rcv  CHANGING ct_tab TYPE ty_t_zgtmms4005
                                                                         ct_tab2 TYPE ty_t_zgtmms4009.

  LOOP AT ct_tab ASSIGNING FIELD-SYMBOL(<ls_tab>).
    <ls_tab>-ebeln = |{ <ls_tab>-ebeln ALPHA = IN }|.
    <ls_tab>-ebelp = |{ <ls_tab>-ebelp ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <ls_tab>-matnr
      IMPORTING
        output = <ls_tab>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = <ls_tab>-meins
      IMPORTING
        output = <ls_tab>-meins.

  ENDLOOP.

  LOOP AT ct_tab2 ASSIGNING FIELD-SYMBOL(<ls_tab2>).
    <ls_tab2>-ebeln = |{ <ls_tab2>-ebeln ALPHA = IN }|.
    <ls_tab2>-ebelp = |{ <ls_tab2>-ebelp ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <ls_tab2>-matnr
      IMPORTING
        output = <ls_tab2>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = <ls_tab2>-meins
      IMPORTING
        output = <ls_tab2>-meins.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SAVE_LOG_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GC_1
*&      --> I_SYSTEM_ID
*&      <-- LS_LOG
*&      <-- LT_LOG_DATA
*&---------------------------------------------------------------------*
FORM f_save_log_pogr_rcv  USING
                                   pt_log_9420 TYPE ty_t_zgtmmt9420
                                   ps_hdret TYPE bapi2017_gm_head_ret
                                   CHANGING ps_log TYPE zgtmmt9000.

  DATA:
    ls_log      TYPE zgtmmt9000,
    lt_log_data TYPE STANDARD TABLE OF zgtmmt9420,
    lt_log_doc  TYPE STANDARD TABLE OF zgtmmt9421.

  ls_log = ps_log.

*  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
*  PS_LOG-ZIFKEY = LS_LOG-ZIFKEY.
  ls_log-erdat = sy-datum.
  ls_log-erdat_local = sy-datlo.
  ls_log-ertim = sy-uzeit.
  ls_log-ertim_local = sy-timlo.
  ls_log-ernam = sy-uname.

  LOOP AT pt_log_9420 ASSIGNING FIELD-SYMBOL(<ls_log_data>).

    <ls_log_data>-zifkey = ls_log-zifkey.
    <ls_log_data>-system_id = ls_log-system_id.

    lt_log_data = VALUE #( BASE lt_log_data
                                          ( CORRESPONDING #( <ls_log_data> ) ) ).

*    CHECK LS_LOG-ZSTAT EQ GC_S. "성공인 경우 자재문서 저장 " 2026.07.12 성공여부와 관계없이 로그 저장
    lt_log_doc = VALUE #( BASE lt_log_doc ( zifkey = ls_log-zifkey
                                                                          system_id = ls_log-system_id
                                                                          ebeln = <ls_log_data>-ebeln
                                                                          ebelp = <ls_log_data>-ebelp
                                                                          delno = <ls_log_data>-delno
                                                                          delitem = <ls_log_data>-delitem
                                                                          mblnr = ps_hdret-mat_doc
                                                                          mjahr = ps_hdret-doc_year ) ).

  ENDLOOP.
  MODIFY zgtmmt9420 FROM TABLE lt_log_data. "PT_LOG_DATA.

  IF lt_log_doc[] IS NOT INITIAL.
    MODIFY zgtmmt9421 FROM TABLE lt_log_doc.
  ENDIF.

  MODIFY zgtmmt9000 FROM ls_log.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SAVE_LOG_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GC_1
*&      --> I_SYSTEM_ID
*&      <-- LS_LOG
*&      <-- LT_LOG_DATA
*&---------------------------------------------------------------------*
FORM f_save_log_pogr_rcv2 USING ps_log TYPE zgtmmt9000
                                   pt_log_data TYPE ty_t_zgtmmt9424
                                   ps_hdret TYPE bapi2017_gm_head_ret.

  DATA:
    ls_log      TYPE zgtmmt9000,
    lt_log_doc  TYPE STANDARD TABLE OF zgtmmt9421,
    lt_log_data TYPE STANDARD TABLE OF zgtmmt9424.

  ls_log = ps_log.

*  IF LS_LOG-ZIFKEY IS INITIAL.

*    GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  ls_log-erdat = sy-datum.
  ls_log-erdat_local = sy-datlo.
  ls_log-ertim = sy-uzeit.
  ls_log-ertim_local = sy-timlo.
  ls_log-ernam = sy-uname.

*    DATA(LV_CHECK) = ABAP_TRUE.
*  ENDIF.

  LOOP AT pt_log_data ASSIGNING FIELD-SYMBOL(<ls_log_data>).
    <ls_log_data>-zifkey = ls_log-zifkey.
    <ls_log_data>-system_id = ls_log-system_id.

    lt_log_data  = VALUE #( BASE lt_log_data
                                           ( CORRESPONDING #( <ls_log_data> ) ) ).

*    CHECK LS_LOG-ZSTAT EQ GC_S. "성공인 경우 자재문서 저장 -> 성공여부 상관없이 자재문서 테이블도 저장
    lt_log_doc = VALUE #( BASE lt_log_doc
                             ( zifkey = ls_log-zifkey
                               system_id = ls_log-system_id
                               ebeln = <ls_log_data>-ebeln
                               ebelp = <ls_log_data>-ebelp
                               mblnr = ps_hdret-mat_doc
                               mjahr = ps_hdret-doc_year ) ).
  ENDLOOP.
  MODIFY zgtmmt9424 FROM TABLE lt_log_data. "PT_LOG_DATA.

  IF lt_log_doc[] IS NOT INITIAL.
    MODIFY zgtmmt9421 FROM TABLE lt_log_doc.
  ENDIF.

*  IF LV_CHECK = ABAP_TRUE.
  MODIFY zgtmmt9000 FROM ls_log.
*  ENDIF.

  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SET_GOODSMVT_HEADER_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_GROUP1>_PSTYP
*&      --> <LS_GROUP2>_BUDAT
*&      --> <LS_GROUP3>_DELNO
*&      <-- LS_HEADER
*&---------------------------------------------------------------------*
FORM f_set_goodsmvt_header_pogr_rcv  USING    pv_pstyp
                                              pv_budat
                                              pv_delno
                                     CHANGING cs_header TYPE bapi2017_gm_head_01.

  "초기화
  CLEAR cs_header.

*  CASE PV_PSTYP.
*    WHEN SPACE. "일반
  cs_header-pstng_date = pv_budat.
  cs_header-doc_date = pv_budat.
  cs_header-ref_doc_no = pv_delno.
  cs_header-pr_uname = sy-uname.
*    WHEN GC_3. "외주 임가공
*      CS_HEADER-PSTING_DATE = PV_BUDAT.
*      CS_HEADER-DOC_DATE = PV_BUDAT.
*      CS_HEADER-REF_DOC_NO = PV_DELNO.
*      CS_HEADER-PR_UNAME = SY-UNAME.
*  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SET_GOODSMVT_ITEM_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM f_set_goodsmvt_item_pogr_rcv  USING  " PS_TAB TYPE ZGTMMS4005
                                                                                pt_resb TYPE ty_t_po_resb_pogr_rcv
                                                                                pt_delcomp TYPE ty_t_po_delcomp_pogr_rcv
                                                                                pt_mslb TYPE ty_t_mslb_pogr_rcv
                                                                                pt_zgtmmt9450 TYPE ty_t_zgtmmt9450
                                                                                pt_po TYPE ty_t_po_drgr_rcv
                                                                                pt_vc TYPE ty_t_batch_vc_value
                                                                                pv_dpcbt
                                   CHANGING ct_item TYPE ty_t_bapi2017_gm_item_create
                                                    ps_tab TYPE zgtmms4005
                                                    cv_check.

  FIELD-SYMBOLS <ls_resb> TYPE ty_po_resb_pogr_rcv.

  DATA ls_item TYPE bapi2017_gm_item_create.
  DATA:
    lt_return   TYPE STANDARD TABLE OF bapiret2,
    lt_alloc    TYPE TABLE OF bapi1003_alloc_values_char,
    lt_alc_num  TYPE TABLE OF bapi1003_alloc_values_num,
    lt_alc_curr TYPE TABLE OF bapi1003_alloc_values_curr,
    lv_class    TYPE klah-class,
    lv_status   TYPE bapi1003_key-status,
    lv_key      TYPE bapi1003_key-object,
    lv_mat18    TYPE matnr18,
    lv_lenth    TYPE atwrt30.

*  CASE PS_LOG_TAB-PSTYP.
*    WHEN SPACE. "일반
  ls_item-material = ps_tab-matnr.
  ls_item-plant = ps_tab-werks.
  ls_item-stge_loc = ps_tab-lgort.
  ls_item-po_number = ps_tab-ebeln.
  ls_item-po_item = ps_tab-ebelp.
  ls_item-move_type = gc_101.
  ls_item-batch = ps_tab-charg.
  ls_item-entry_qnt = ps_tab-menge.
  ls_item-entry_uom = ps_tab-meins.
  ls_item-vendrbatch = ps_tab-licha.
  ls_item-prod_date = ps_tab-hsdat.
*ITEM_TEXT                    DELNO&-&DELITEM GO2026020001-10
  ls_item-item_text = ps_tab-delno && '-' && ps_tab-delitem.

  "STCK_TYPE  EKPO-INSMK
  READ TABLE pt_po ASSIGNING FIELD-SYMBOL(<ls_po>) WITH KEY ebeln = ps_tab-ebeln
                                                                                                  ebelp = ps_tab-ebelp BINARY SEARCH.

  IF sy-subrc EQ 0.
    ls_item-stck_type = <ls_po>-insmk.
  ENDIF.

  CASE ps_tab-pstyp.
    WHEN space. "일반
*      	CASE1. 일반 입고 : IT_TAB-PSTYP = ""
*1)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번
      READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc>)
      WITH KEY ebeln = ps_tab-ebeln
                     ebelp = ps_tab-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_item-batch = CONV i( <vc>-length ).
        CONDENSE ls_item-batch NO-GAPS.
        ps_tab-charg_new = ls_item-batch.

      ELSE.
*2)"처리 자재의  자재유형이 HAWA 이면 DEFAULT 값 채번
*배치번호 : GO00000001"
        SELECT SINGLE
          mtart, matkl
          FROM mara
          WHERE matnr EQ @ps_tab-matnr
          INTO ( @DATA(lv_mtart), @DATA(lv_matkl) ).

        IF lv_mtart EQ 'HAWA'.
          SELECT SINGLE  dpcbt
            FROM marc
            WHERE matnr EQ @ps_tab-matnr
                 AND werks EQ @ps_tab-werks
            INTO @DATA(lv_dpcbt).

          CASE pv_dpcbt.
*2-2)배치유형 'A' OR 공백이면 DEFAULT 값 채번_배치번호 : GO00000001"
            WHEN 'A' OR space.
              ls_item-batch = 'GO00000001'.
              ps_tab-charg_new = ls_item-batch.
*2-1)MARC-DPCBT = 'C'->자동채번
            WHEN 'C'.
              ls_item-batch = ''.
            WHEN OTHERS.
          ENDCASE.

        ELSE.
*3)입고 처리 플랜트와 입고 자재의 자재그룹이 공통 마스터 정보에 존재하면 배치번호=MATNR 값으로 채번
          READ TABLE gt_zgtppt1010 ASSIGNING FIELD-SYMBOL(<pp>)
          WITH KEY fld_01 = ps_tab-werks
                         fld_02 = lv_matkl BINARY SEARCH.
          IF sy-subrc = 0.
            ls_item-batch = ps_tab-matnr.
            ps_tab-charg_new = ls_item-batch.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc2>)
      WITH KEY ebeln = ps_tab-ebeln
                     ebelp = ps_tab-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_item-batch = CONV i( <vc2>-length ).
        CONDENSE ls_item-batch NO-GAPS.
        ps_tab-charg_new = ls_item-batch.
      ENDIF.
  ENDCASE.

*>S.26.07.29_3-2) BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
*배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
  IF pv_dpcbt = 'A'. "FACTOR BATCH
    CLEAR lv_lenth.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
    READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc3>)
    WITH KEY ebeln = ps_tab-ebeln
                   ebelp = ps_tab-ebelp BINARY SEARCH.
    IF sy-subrc = 0.
      lv_lenth = CONV i( <vc3>-length ).
      CONDENSE lv_lenth NO-GAPS.
    ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: lv_class.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ps_tab-matnr "입고자재
        plant              = ps_tab-werks "플랜트
        classtype          = '023'       "클래스유형(배치)
      IMPORTING
        class              = lv_class
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 3.

    CHECK lv_class IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR lt_alc_num.
    lt_alc_num[] = VALUE #( BASE lt_alc_num
                                                ( charact = 'SAP_MILLCA_LENGTH'
                                                  value_from = lv_lenth )
                                                ( charact = 'SAP_MILLCA_LENGTH_SUB'
                                                  value_from = lv_lenth ) ).
    CLEAR : lt_return.
    SELECT SINGLE cuobj_bm
       FROM mch1
       WHERE matnr = @ps_tab-matnr
           AND charg = @ls_item-batch
          INTO @DATA(lv_objkey).

    IF lv_objkey IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_alc_num
          allocvalueschar_new = lt_alloc
          allocvaluescurr_new = lt_alc_curr
          return              = lt_return.
*        CLEAR LV_LENTH.
**3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
*        READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC3>)
*        WITH KEY EBELN = PS_TAB-EBELN
*                       EBELP = PS_TAB-EBELP BINARY SEARCH.
*        IF SY-SUBRC = 0.
*          LV_LENTH = CONV I( <VC3>-LENGTH ).
*          CONDENSE LV_LENTH NO-GAPS.
*        ENDIF.
**3-2-2) FACTOR 배치 자재의 CLASS 조회
** CLASS번호
*        CLEAR: LV_CLASS.
*        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
*          EXPORTING
*            MATERIAL         = PS_TAB-MATNR "입고자재
*            PLANT              = PS_TAB-WERKS "플랜트
*            CLASSTYPE      = '023'       "클래스유형(배치)
*          IMPORTING
*            CLASS              = LV_CLASS
*          EXCEPTIONS
*            NO_CLASS_FOUND     = 1
*            NO_CLASSTYPE_FOUND = 2
*            OTHERS             = 3.
*
*        CHECK LV_CLASS IS NOT INITIAL.
**3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
*        CLEAR LT_ALLOC.
*        LT_ALLOC[] = VALUE #( BASE LT_ALLOC
*                                              ( CHARACT = 'SAP_MILLCA_LENGTH'
*                                                VALUE_CHAR = LV_LENTH )
*                                              ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
*                                                VALUE_CHAR = LV_LENTH ) ).
*
*      CLEAR : LV_MAT18, LV_KEY, LT_RETURN.
*      LV_MAT18 = |{ PS_TAB-MATNR ALPHA = IN }|.
*      LV_KEY(18) = LV_MAT18.
*      LV_KEY+18(10) = LV_LENTH. "선수행시에는 배치번호 없음->조장=배치번호
*
*        CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*          EXPORTING
*            OBJECTKEY          = LV_KEY
*            OBJECTTABLE        = 'MCH1'
*            CLASSNUM           = LV_CLASS
*            CLASSTYPE          = '023'
*          TABLES
*            ALLOCVALUESNUMNEW  = LT_ALC_NUM
*            ALLOCVALUESCHARNEW = LT_ALLOC
*            ALLOCVALUESCURRNEW = LT_ALC_CURR
*            RETURN             = LT_RETURN
*            .
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_r2turn>) WITH KEY type = gc_e.
      IF sy-subrc EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
*<E.26.07.29_ZGODEV04.

  ls_item-mvt_ind = gc_b.
  ls_item-line_id = lines( ct_item ) + 1.
  ct_item = VALUE #( BASE ct_item ( ls_item ) ).

  CHECK ps_tab-pstyp EQ gc_3. "외주 임가공인 경우

*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
  DATA:
    lv_erfmg   TYPE mengv13,
    lv_erfmg_o TYPE erfmg.

  FIELD-SYMBOLS <ls_mslb> TYPE ty_mslb_pogr_rcv.

  DATA ls_comp TYPE bapi2017_gm_item_create.
  ls_comp-parent_id	 = ls_item-line_id.
  ls_comp-line_id = ls_item-line_id.

  READ TABLE pt_delcomp WITH KEY ebeln = ps_tab-ebeln
                                                    ebelp = ps_tab-ebelp
                                                    delno = ps_tab-delno
                                                    delitem = ps_tab-delitem BINARY SEARCH TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    "납품문서 COMPONENT 기준
    LOOP AT pt_delcomp ASSIGNING FIELD-SYMBOL(<ls_delcomp>) FROM sy-tabix.
      IF <ls_delcomp>-ebeln NE ps_tab-ebeln
        OR <ls_delcomp>-ebelp NE ps_tab-ebelp
        OR <ls_delcomp>-delno NE ps_tab-delno
        OR <ls_delcomp>-delitem NE ps_tab-delitem.
        EXIT.
      ENDIF.

      ls_comp-material = <ls_delcomp>-idnrk.
      ls_comp-plant = <ls_delcomp>-werks.
      ls_comp-stge_loc = <ls_delcomp>-lgort.
      ls_comp-po_number = <ls_delcomp>-ebeln.
      ls_comp-po_item = <ls_delcomp>-ebelp.
      ls_comp-move_type = gc_543.
      ls_comp-batch = <ls_delcomp>-charg.
      ls_comp-entry_qnt = <ls_delcomp>-issue_qty.
      ls_comp-entry_uom = <ls_delcomp>-issue_unit.
      ls_comp-mvt_ind = gc_b.

      "라인추가
      IF <ls_delcomp>-xchpf EQ abap_true AND <ls_delcomp>-charg EQ space.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
        lv_erfmg = ls_comp-entry_qnt. "대상 출고 수량
        READ TABLE pt_mslb WITH KEY matnr = <ls_delcomp>-idnrk
                                                   werks = <ls_delcomp>-werks
                                                   lifnr = <ls_delcomp>-lifnr BINARY SEARCH TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          LOOP AT pt_mslb ASSIGNING <ls_mslb> FROM sy-tabix.
            IF <ls_mslb>-matnr NE <ls_delcomp>-idnrk
              OR <ls_mslb>-werks NE <ls_delcomp>-werks
              OR <ls_mslb>-lifnr NE <ls_delcomp>-lifnr.
              EXIT.
            ENDIF.

            CHECK <ls_mslb>-lblab GE 0. "재고수량이 0보다 큰 경우만 진행

            "적용 수량 빼기
            lv_erfmg_o = lv_erfmg.
            lv_erfmg -= <ls_mslb>-lblab.

            ls_comp-batch = <ls_mslb>-charg.

            IF lv_erfmg LT 0.
              "적용한 수량이 대상 출고수량 보다 큰 경우
              IF <ls_mslb>-xpcbt EQ abap_true AND <ls_mslb>-xprgi EQ space.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                ls_comp-entry_qnt = <ls_mslb>-lblab.
              ELSE.
                "단일 배치단위가 아니면 잔량적용
                ls_comp-entry_qnt = lv_erfmg_o.
              ENDIF.
            ELSE.
              ls_comp-entry_qnt = <ls_mslb>-lblab.
            ENDIF.

            "재고수량에서 적용수량 빼기
            <ls_mslb>-lblab -=  ls_comp-entry_qnt.

            ls_comp-line_id += 1.
            ct_item = VALUE #( BASE ct_item ( ls_comp ) ). "라인추가


            "적용 수량이 대상 출고수량을 초과한 경우 종료
            IF lv_erfmg LE 0.
              EXIT.
            ENDIF.

          ENDLOOP.
        ELSE.
          ls_comp-line_id += 1.
          ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
        ENDIF.
      ELSE.
        ls_comp-line_id += 1.
        ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
      ENDIF.
    ENDLOOP.
  ELSE.
    READ TABLE pt_zgtmmt9450 WITH KEY ebeln = ps_tab-ebeln
                                                          ebelp = ps_tab-ebelp
                                                          werks = ps_tab-werks BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
*
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

      LOOP AT pt_zgtmmt9450 ASSIGNING FIELD-SYMBOL(<ls_zgtmmt9450>).

        ls_comp-material = <ls_zgtmmt9450>-idnrk.
        ls_comp-plant = ps_tab-werks.
        ls_comp-po_number = <ls_zgtmmt9450>-ebeln.
        ls_comp-po_item = <ls_zgtmmt9450>-ebelp.
        ls_comp-move_type = gc_543.
        ls_comp-batch = <ls_zgtmmt9450>-charg.
        ls_comp-entry_uom = <ls_zgtmmt9450>-meins.
        ls_comp-mvt_ind = gc_b.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

        IF <ls_zgtmmt9450>-charg IS NOT INITIAL.
          ls_comp-entry_qnt = <ls_zgtmmt9450>-menge.
        ELSE.

          READ TABLE pt_resb ASSIGNING <ls_resb> WITH KEY  ebeln = <ls_zgtmmt9450>-ebeln
                                                                                                ebelp = <ls_zgtmmt9450>-ebelp
                                                                                                matnr = <ls_zgtmmt9450>-idnrk.
          IF sy-subrc EQ 0.
            IF <ls_resb>-menge IS NOT INITIAL.
              ls_comp-entry_qnt = ps_tab-menge * ( <ls_resb>-bdmng / <ls_resb>-menge ).
            ELSE.
              ls_comp-entry_qnt = 0.
            ENDIF.
          ELSE.
            cv_check = gc_e.
            EXIT.
          ENDIF.
        ENDIF.

        ls_comp-line_id += 1.
        ct_item = VALUE #( BASE ct_item ( ls_comp ) ).

      ENDLOOP.

    ELSE.
      "PO COMPONENT 기준
      READ TABLE pt_resb WITH KEY ebeln = ps_tab-ebeln
                                                ebelp = ps_tab-ebelp BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        LOOP AT pt_resb ASSIGNING <ls_resb> FROM sy-tabix.
          IF <ls_resb>-ebeln NE ps_tab-ebeln
            OR <ls_resb>-ebelp NE ps_tab-ebelp.
            EXIT.
          ENDIF.

          ls_comp-material = <ls_resb>-matnr.
          ls_comp-plant = <ls_resb>-werks.
          ls_comp-stge_loc = <ls_resb>-lgort.
          ls_comp-po_number = <ls_resb>-ebeln.
          ls_comp-po_item = <ls_resb>-ebelp.
          ls_comp-move_type = gc_543.
          ls_comp-batch = <ls_resb>-charg.
          IF <ls_resb>-menge IS NOT INITIAL.
            ls_comp-entry_qnt = ps_tab-menge * ( <ls_resb>-bdmng / <ls_resb>-menge ).
          ELSE.
            ls_comp-entry_qnt = 0.
          ENDIF.
          ls_comp-entry_uom = <ls_resb>-meins.
          ls_comp-mvt_ind = gc_b.


          "라인추가
          IF <ls_resb>-xchpf EQ abap_true AND <ls_resb>-charg EQ space.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
            lv_erfmg = ls_comp-entry_qnt. "대상 출고 수량
            READ TABLE pt_mslb WITH KEY matnr = <ls_resb>-matnr
                                                       werks = <ls_resb>-werks
                                                       lifnr = <ls_resb>-lifnr BINARY SEARCH TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              LOOP AT pt_mslb ASSIGNING <ls_mslb> FROM sy-tabix.
                IF <ls_mslb>-matnr NE <ls_resb>-matnr
                  OR <ls_mslb>-werks NE <ls_resb>-werks
                  OR <ls_mslb>-lifnr NE <ls_resb>-lifnr.
                  EXIT.
                ENDIF.

                CHECK <ls_mslb>-lblab GE 0. "재고수량이 0보다 큰 경우만 진행

                "적용 수량 빼기
                lv_erfmg_o = lv_erfmg.
                lv_erfmg -= <ls_mslb>-lblab.

                ls_comp-batch = <ls_mslb>-charg.

                IF lv_erfmg LT 0.
                  "적용한 수량이 대상 출고수량 보다 큰 경우
                  IF <ls_mslb>-xpcbt EQ abap_true AND <ls_mslb>-xprgi EQ space.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                    ls_comp-entry_qnt = <ls_mslb>-lblab.
                  ELSE.
                    "단일 배치단위가 아니면 잔량적용
                    ls_comp-entry_qnt = lv_erfmg_o.
                  ENDIF.
                ELSE.
                  ls_comp-entry_qnt = <ls_mslb>-lblab.
                ENDIF.

                "재고수량에서 적용수량 빼기
                <ls_mslb>-lblab -=  ls_comp-entry_qnt.

                ls_comp-line_id += 1.
                ct_item = VALUE #( BASE ct_item ( ls_comp ) ). "라인추가

                "적용 수량이 대상 출고수량을 초과한 경우 종료
                IF lv_erfmg LE 0.
                  EXIT.
                ENDIF.

              ENDLOOP.
            ELSE.
              ls_comp-line_id += 1.
              ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
            ENDIF.
          ELSE.
            ls_comp-line_id += 1.
            ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
          ENDIF.

        ENDLOOP.
      ENDIF.


    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SET_GOODSMVT_ITEM_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_LOG_TAB>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM f_set_goodsmvt_item_pogr_rcv2  USING  "PS_TAB TYPE ZGTMMS4009
                                                                                pt_resb TYPE ty_t_po_resb_pogr_rcv
                                                                                pt_delcomp TYPE ty_t_po_delcomp_pogr_rcv
                                                                                pt_mslb TYPE ty_t_mslb_pogr_rcv
                                                                                pt_zgtmmt9450 TYPE ty_t_zgtmmt9450
                                                                                pt_po TYPE ty_t_po_drgr_rcv
                                                                                pt_vc TYPE ty_t_batch_vc_value
                                   CHANGING ct_item TYPE ty_t_bapi2017_gm_item_create
                                                    ps_tab TYPE zgtmms4009
                                                    cv_check.

  DATA:
    lt_return   TYPE STANDARD TABLE OF bapiret2,
    lt_alloc    TYPE TABLE OF bapi1003_alloc_values_char,
    lt_alc_num  TYPE TABLE OF bapi1003_alloc_values_num,
    lt_alc_curr TYPE TABLE OF bapi1003_alloc_values_curr,
    lv_class    TYPE bapi1003_key-classnum, "KLAH-CLASS,
    lv_status   TYPE bapi1003_key-status,
    lv_lenth    TYPE atwrt30.

  FIELD-SYMBOLS <ls_resb> TYPE ty_po_resb_pogr_rcv.

  DATA ls_item TYPE bapi2017_gm_item_create.

  ls_item-material = ps_tab-matnr.
  ls_item-plant = ps_tab-werks.
  ls_item-stge_loc = ps_tab-lgort.
  ls_item-po_number = ps_tab-ebeln.
  ls_item-po_item = ps_tab-ebelp.
  ls_item-move_type = gc_101.
  ls_item-batch = ps_tab-charg.
  ls_item-entry_qnt = ps_tab-menge.
  ls_item-entry_uom = ps_tab-meins.
*  LS_ITEM-VENDRBATCH = PS_TAB-LICHA.
*  LS_ITEM-PROD_DATE = PS_TAB-HSDAT.
*ITEM_TEXT
  ls_item-item_text = ps_tab-ebeln && '-' && ps_tab-ebelp.

  "STCK_TYPE  EKPO-INSMK
  READ TABLE pt_po ASSIGNING FIELD-SYMBOL(<ls_po>) WITH KEY ebeln = ps_tab-ebeln
                                                                                                  ebelp = ps_tab-ebelp BINARY SEARCH.
  IF sy-subrc EQ 0.
    ls_item-stck_type = <ls_po>-insmk.
  ENDIF.

*배치유형 가져오기(배치특성 선수행 위함)
  SELECT SINGLE dpcbt
     FROM marc
   WHERE matnr EQ @ps_tab-matnr
        AND werks EQ @ps_tab-werks
       INTO @DATA(lv_dpcbt).

  CASE ps_tab-pstyp.
    WHEN space. "일반
*      	CASE1. 일반 입고 : IT_TAB-PSTYP = ""
*1)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번
      READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc>)
      WITH KEY ebeln = ps_tab-ebeln
                     ebelp = ps_tab-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_item-batch = CONV i( <vc>-length ).
        CONDENSE ls_item-batch NO-GAPS.
        ps_tab-charg_new = ls_item-batch.

      ELSE.
*FACTOR BATCH 아니면,
*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정
        SELECT SINGLE
          mtart, matkl
          FROM mara
          WHERE matnr EQ @ps_tab-matnr
          INTO ( @DATA(lv_mtart), @DATA(lv_matkl) ).

        IF lv_mtart EQ 'HAWA'.
*          SELECT SINGLE  DPCBT
*            FROM MARC
*            WHERE MATNR EQ @PS_TAB-MATNR
*                 AND WERKS EQ @PS_TAB-WERKS
*            INTO @DATA(LV_DPCBT). "위치이동 라인 858_260804

          CASE lv_dpcbt.
*2-2)공백이면 DEFAULT 값 채번_배치번호 : GO00000001"
            WHEN 'A' OR space.
              ls_item-batch = 'GO00000001'.
              ps_tab-charg_new = ls_item-batch.
*2-1)MARC-DPCBT = 'C'->자동채번
            WHEN 'C'.
              ls_item-batch = ''.
            WHEN OTHERS.
          ENDCASE.

        ELSE.
*3)입고 처리 플랜트와 입고 자재의 자재그룹이 공통 마스터 정보에 존재하면 배치번호=MATNR 값으로 채번
          READ TABLE gt_zgtppt1010 ASSIGNING FIELD-SYMBOL(<pp>)
          WITH KEY fld_01 = ps_tab-werks
                         fld_02 = lv_matkl BINARY SEARCH.
          IF sy-subrc = 0.

            DATA: lv_matnr_ext TYPE matnr.
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
              EXPORTING
                input  = ps_tab-matnr
              IMPORTING
                output = lv_matnr_ext.
            ls_item-batch = lv_matnr_ext.

*            LS_ITEM-BATCH = PS_TAB-MATNR.
            ps_tab-charg_new = ls_item-batch.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc2>)
      WITH KEY ebeln = ps_tab-ebeln
                     ebelp = ps_tab-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        ls_item-batch = CONV i( <vc2>-length ).
        ps_tab-charg_new = ls_item-batch.
      ENDIF.
  ENDCASE.

*>S.26.08.04_3-2) BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
*배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
  IF lv_dpcbt = 'A'. "FACTOR BATCH
    CLEAR lv_lenth.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
    READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc3>)
    WITH KEY ebeln = ps_tab-ebeln
                   ebelp = ps_tab-ebelp BINARY SEARCH.
    IF sy-subrc = 0.
      lv_lenth = CONV i( <vc3>-length ).
      CONDENSE lv_lenth NO-GAPS.
    ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: lv_class.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ps_tab-matnr "입고자재
        plant              = ps_tab-werks "플랜트
        classtype          = '023'       "클래스유형(배치)
      IMPORTING
        class              = lv_class
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 3.

    CHECK lv_class IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR lt_alc_num.
    lt_alc_num[] = VALUE #( BASE lt_alc_num
                                                  ( charact = 'SAP_MILLCA_LENGTH'
                                                    value_from = lv_lenth )
                                                  ( charact = 'SAP_MILLCA_LENGTH_SUB'
                                                    value_from = lv_lenth ) ).
    CLEAR : lt_return.
    SELECT SINGLE cuobj_bm
         FROM mch1
         WHERE matnr = @ps_tab-matnr
             AND charg = @ls_item-batch
            INTO @DATA(lv_objkey).

    IF lv_objkey IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_alc_num
          allocvalueschar_new = lt_alloc
          allocvaluescurr_new = lt_alc_curr
          return              = lt_return.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_r2turn>) WITH KEY type = gc_e.
      IF sy-subrc EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
*<E.26.08.04_ZGODEV04.

  ls_item-mvt_ind = gc_b.
  ls_item-line_id = lines( ct_item ) + 1.
  ct_item = VALUE #( BASE ct_item ( ls_item ) ).

  CHECK ps_tab-pstyp EQ gc_3. "외주 임가공인 경우

*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
  DATA:
    lv_erfmg   TYPE mengv13,
    lv_erfmg_o TYPE erfmg.

  FIELD-SYMBOLS <ls_mslb> TYPE ty_mslb_pogr_rcv.

  DATA ls_comp TYPE bapi2017_gm_item_create.
  ls_comp-parent_id	 = ls_item-line_id.
  ls_comp-line_id = ls_item-line_id.

  READ TABLE pt_delcomp WITH KEY ebeln = ps_tab-ebeln
                                                    ebelp = ps_tab-ebelp BINARY SEARCH TRANSPORTING NO FIELDS.
*                                                    DELNO = PS_TAB-DELNO
*                                                    DELITEM = PS_TAB-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    "납품문서 COMPONENT 기준
    LOOP AT pt_delcomp ASSIGNING FIELD-SYMBOL(<ls_delcomp>) FROM sy-tabix.
      IF <ls_delcomp>-ebeln NE ps_tab-ebeln
        OR <ls_delcomp>-ebelp NE ps_tab-ebelp.
*        OR <LS_DELCOMP>-DELNO NE PS_TAB-DELNO
*        OR <LS_DELCOMP>-DELITEM NE PS_TAB-DELITEM.
        EXIT.
      ENDIF.

      ls_comp-material = <ls_delcomp>-idnrk.
      ls_comp-plant = <ls_delcomp>-werks.
      ls_comp-stge_loc = <ls_delcomp>-lgort.
      ls_comp-po_number = <ls_delcomp>-ebeln.
      ls_comp-po_item = <ls_delcomp>-ebelp.
      ls_comp-move_type = gc_543.
      ls_comp-batch = <ls_delcomp>-charg.
      ls_comp-entry_qnt = <ls_delcomp>-issue_qty.
      ls_comp-entry_uom = <ls_delcomp>-issue_unit.
      ls_comp-mvt_ind = gc_b.

      "라인추가
      IF <ls_delcomp>-xchpf EQ abap_true AND <ls_delcomp>-charg EQ space.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
        lv_erfmg = ls_comp-entry_qnt. "대상 출고 수량
        READ TABLE pt_mslb WITH KEY matnr = <ls_delcomp>-idnrk
                                                   werks = <ls_delcomp>-werks
                                                   lifnr = <ls_delcomp>-lifnr BINARY SEARCH TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          LOOP AT pt_mslb ASSIGNING <ls_mslb> FROM sy-tabix.
            IF <ls_mslb>-matnr NE <ls_delcomp>-idnrk
              OR <ls_mslb>-werks NE <ls_delcomp>-werks
              OR <ls_mslb>-lifnr NE <ls_delcomp>-lifnr.
              EXIT.
            ENDIF.

            CHECK <ls_mslb>-lblab GE 0. "재고수량이 0보다 큰 경우만 진행

            "적용 수량 빼기
            lv_erfmg_o = lv_erfmg.
            lv_erfmg -= <ls_mslb>-lblab.

            ls_comp-batch = <ls_mslb>-charg.

            IF lv_erfmg LT 0.
              "적용한 수량이 대상 출고수량 보다 큰 경우
              IF <ls_mslb>-xpcbt EQ abap_true AND <ls_mslb>-xprgi EQ space.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                ls_comp-entry_qnt = <ls_mslb>-lblab.
              ELSE.
                "단일 배치단위가 아니면 잔량적용
                ls_comp-entry_qnt = lv_erfmg_o.
              ENDIF.
            ELSE.
              ls_comp-entry_qnt = <ls_mslb>-lblab.
            ENDIF.

            "재고수량에서 적용수량 빼기
            <ls_mslb>-lblab -=  ls_comp-entry_qnt.

            ls_comp-line_id += 1.
            ct_item = VALUE #( BASE ct_item ( ls_comp ) ). "라인추가


            "적용 수량이 대상 출고수량을 초과한 경우 종료
            IF lv_erfmg LE 0.
              EXIT.
            ENDIF.

          ENDLOOP.
        ELSE.
          ls_comp-line_id += 1.
          ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
        ENDIF.
      ELSE.
        ls_comp-line_id += 1.
        ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
      ENDIF.
    ENDLOOP.

  ELSE.
    READ TABLE pt_zgtmmt9450 WITH KEY ebeln = ps_tab-ebeln
                                                          ebelp = ps_tab-ebelp
                                                          werks = ps_tab-werks BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

      LOOP AT pt_zgtmmt9450 ASSIGNING FIELD-SYMBOL(<ls_zgtmmt9450>).

        ls_comp-material = <ls_zgtmmt9450>-idnrk.
        ls_comp-plant = ps_tab-werks.
        ls_comp-po_number = <ls_zgtmmt9450>-ebeln.
        ls_comp-po_item = <ls_zgtmmt9450>-ebelp.
        ls_comp-move_type = gc_543.
        ls_comp-batch = <ls_zgtmmt9450>-charg.
        ls_comp-entry_uom = <ls_zgtmmt9450>-meins.
        ls_comp-mvt_ind = gc_b.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

        IF <ls_zgtmmt9450>-charg IS NOT INITIAL.
          ls_comp-entry_qnt = <ls_zgtmmt9450>-menge.
        ELSE.

          READ TABLE pt_resb ASSIGNING <ls_resb> WITH KEY  ebeln = <ls_zgtmmt9450>-ebeln
                                                                                                ebelp = <ls_zgtmmt9450>-ebelp
                                                                                                matnr = <ls_zgtmmt9450>-idnrk.
          IF sy-subrc EQ 0.
            IF <ls_resb>-menge IS NOT INITIAL.
              ls_comp-entry_qnt = ps_tab-menge * ( <ls_resb>-bdmng / <ls_resb>-menge ).
            ELSE.
              ls_comp-entry_qnt = 0.
            ENDIF.
          ELSE.
            cv_check = gc_e.
            EXIT.
          ENDIF.
        ENDIF.

        ls_comp-line_id += 1.
        ct_item = VALUE #( BASE ct_item ( ls_comp ) ).

      ENDLOOP.

    ELSE.
      "PO COMPONENT 기준
      READ TABLE pt_resb WITH KEY ebeln = ps_tab-ebeln
                                                ebelp = ps_tab-ebelp BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        LOOP AT pt_resb ASSIGNING <ls_resb> FROM sy-tabix.
          IF <ls_resb>-ebeln NE ps_tab-ebeln
            OR <ls_resb>-ebelp NE ps_tab-ebelp.
            EXIT.
          ENDIF.

          ls_comp-material = <ls_resb>-matnr.
          ls_comp-plant = <ls_resb>-werks.
          ls_comp-stge_loc = <ls_resb>-lgort.
          ls_comp-po_number = <ls_resb>-ebeln.
          ls_comp-po_item = <ls_resb>-ebelp.
          ls_comp-move_type = gc_543.
          ls_comp-batch = <ls_resb>-charg.
          IF <ls_resb>-menge IS NOT INITIAL.
            ls_comp-entry_qnt = ps_tab-menge * ( <ls_resb>-bdmng / <ls_resb>-menge ).
          ELSE.
            ls_comp-entry_qnt = 0.
          ENDIF.
          ls_comp-entry_uom = <ls_resb>-meins.
          ls_comp-mvt_ind = gc_b.

          "라인추가
          IF <ls_resb>-xchpf EQ abap_true AND <ls_resb>-charg EQ space.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
            lv_erfmg = ls_comp-entry_qnt. "대상 출고 수량
            READ TABLE pt_mslb WITH KEY matnr = <ls_resb>-matnr
                                                       werks = <ls_resb>-werks
                                                       lifnr = <ls_resb>-lifnr BINARY SEARCH TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              LOOP AT pt_mslb ASSIGNING <ls_mslb> FROM sy-tabix.
                IF <ls_mslb>-matnr NE <ls_resb>-matnr
                  OR <ls_mslb>-werks NE <ls_resb>-werks
                  OR <ls_mslb>-lifnr NE <ls_resb>-lifnr.
                  EXIT.
                ENDIF.

                CHECK <ls_mslb>-lblab GE 0. "재고수량이 0보다 큰 경우만 진행

                "적용 수량 빼기
                lv_erfmg_o = lv_erfmg.
                lv_erfmg -= <ls_mslb>-lblab.

                ls_comp-batch = <ls_mslb>-charg.

                IF lv_erfmg LT 0.
                  "적용한 수량이 대상 출고수량 보다 큰 경우
                  IF <ls_mslb>-xpcbt EQ abap_true AND <ls_mslb>-xprgi EQ space.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                    ls_comp-entry_qnt = <ls_mslb>-lblab.
                  ELSE.
                    "단일 배치단위가 아니면 잔량적용
                    ls_comp-entry_qnt = lv_erfmg_o.
                  ENDIF.
                ELSE.
                  ls_comp-entry_qnt = <ls_mslb>-lblab.
                ENDIF.

                "재고수량에서 적용수량 빼기
                <ls_mslb>-lblab -=  ls_comp-entry_qnt.

                ls_comp-line_id += 1.
                ct_item = VALUE #( BASE ct_item ( ls_comp ) ). "라인추가

                "적용 수량이 대상 출고수량을 초과한 경우 종료
                IF lv_erfmg LE 0.
                  EXIT.
                ENDIF.

              ENDLOOP.
            ELSE.
              ls_comp-line_id += 1.
              ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
            ENDIF.
          ELSE.
            ls_comp-line_id += 1.
            ct_item = VALUE #( BASE ct_item ( ls_comp ) ).
          ENDIF.

        ENDLOOP.
      ENDIF.


    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_RESB_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM f_get_po_resb_pogr_rcv  USING  pt_tab TYPE ty_t_zgtmms4005
                             CHANGING ct_resb TYPE ty_t_po_resb_pogr_rcv.

*3-2-4) BAPI ITEM 설정 -  투입 COMPONENT 자재
*
*	3-2-4-1) COMPONENT 자재 정보추출(PO_COMP)
*	TABLE ; RESB
*	SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*	WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
*
  ##ITAB_KEY_IN_SELECT
  SELECT
    ep~ebeln,
    ep~ebelp,
    ep~menge,
    rs~rsnum,
    rs~rspos,
    rs~bdmng,
    rs~matnr,
    rs~meins,
    rs~werks,
    rs~lgort,
    rs~charg,
    mc~xchpf,
    ek~lifnr
    FROM ekpo AS ep
              INNER JOIN
            resb AS rs ON ep~ebeln EQ rs~ebeln
                          AND ep~ebelp EQ rs~ebelp
              INNER JOIN
            marc AS mc ON rs~matnr EQ mc~matnr
                             AND rs~werks EQ mc~werks
              INNER JOIN
            ekko AS ek ON ep~ebeln EQ ek~ebeln
    WHERE ep~pstyp EQ @gc_3
    AND EXISTS (
      SELECT zz~ebeln, zz~ebelp
        FROM @pt_tab AS zz
        WHERE zz~ebeln EQ ep~ebeln
           AND zz~ebelp EQ ep~ebelp
    )
    AND ep~loekz EQ @space
    AND rs~xloek EQ @space
    ORDER BY ep~ebeln, ep~ebelp, rs~rsnum, rs~rspos
    INTO TABLE @ct_resb.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_RESB_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM f_get_po_resb_pogr_rcv2  USING  pt_tab TYPE ty_t_zgtmms4009
                             CHANGING ct_resb TYPE ty_t_po_resb_pogr_rcv.

*3-2-4) BAPI ITEM 설정 -  투입 COMPONENT 자재
*
*	3-2-4-1) COMPONENT 자재 정보추출(PO_COMP)
*	TABLE ; RESB
*	SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*	WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
*
  ##ITAB_KEY_IN_SELECT
  SELECT
    ep~ebeln,
    ep~ebelp,
    ep~menge,
    rs~rsnum,
    rs~rspos,
    rs~bdmng,
    rs~matnr,
    rs~meins,
    rs~werks,
    rs~lgort,
    rs~charg,
    mc~xchpf,
    ek~lifnr
    FROM ekpo AS ep
              INNER JOIN
            resb AS rs ON ep~ebeln EQ rs~ebeln
                          AND ep~ebelp EQ rs~ebelp
              INNER JOIN
            marc AS mc ON rs~matnr EQ mc~matnr
                             AND rs~werks EQ mc~werks
              INNER JOIN
            ekko AS ek ON ep~ebeln EQ ek~ebeln
    WHERE ep~pstyp EQ @gc_3
    AND EXISTS (
      SELECT zz~ebeln, zz~ebelp
        FROM @pt_tab AS zz
        WHERE zz~ebeln EQ ep~ebeln
           AND zz~ebelp EQ ep~ebelp
    )
    AND ep~loekz EQ @space
    AND rs~xloek EQ @space
    ORDER BY ep~ebeln, ep~ebelp, rs~rsnum, rs~rspos
    APPENDING TABLE @ct_resb.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SAVE_ZPPT0001_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      --> LS_HDRET
*&---------------------------------------------------------------------*
FORM f_save_zppt0001_pogr_rcv  USING  pt_log_data TYPE ty_t_zgtmmt9420
                                        ps_hdret TYPE bapi2017_gm_head_ret
                                        pt_dispo TYPE ty_t_po_dispo_pogr_rcv.


  DATA:
    lv_zspgcd TYPE zspgcd,
    lt_pp     TYPE STANDARD TABLE OF zppt0001.

  LOOP AT pt_log_data ASSIGNING FIELD-SYMBOL(<ls_log_data>).
    CHECK <ls_log_data>-charg IS NOT INITIAL OR <ls_log_data>-charg_new IS NOT INITIAL.
*입고처리플랜트&입고자재의 자재그룹이 공통마스터 정보에 존재하면 꼬리표 업데이트 제외.
    SELECT SINGLE matkl FROM mara
      WHERE matnr = @<ls_log_data>-matnr INTO @DATA(lv_matkl).

    READ TABLE gt_zgtppt1010 TRANSPORTING NO FIELDS
    WITH KEY fld_01 = <ls_log_data>-werks
                   fld_02 = lv_matkl BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR lv_zspgcd.
    READ TABLE pt_dispo ASSIGNING FIELD-SYMBOL(<ls_dispo>) WITH KEY ebeln = <ls_log_data>-ebeln
                                                                                                       ebelp = <ls_log_data>-ebelp BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_zspgcd = <ls_dispo>-dispo.
    ENDIF.

    lt_pp[] = VALUE #( BASE lt_pp (
          werks = <ls_log_data>-werks
          aufnr = <ls_log_data>-ebeln
          tagnr = <ls_log_data>-tagnr
          posnr = <ls_log_data>-ebelp
          charg = COND #( WHEN <ls_log_data>-charg_new IS NOT INITIAL
                                       THEN <ls_log_data>-charg_new
                                       ELSE <ls_log_data>-charg )
          mblnr = ps_hdret-mat_doc
          matnr = <ls_log_data>-matnr
          spgcd = lv_zspgcd
          mgvrg = <ls_log_data>-menge
          fostcnt = 1
          remain = <ls_log_data>-menge
          meins = <ls_log_data>-meins
          outflg = COND #( WHEN <ls_log_data>-pstyp EQ gc_3 THEN abap_true ELSE space )
          giflg = gc_n
          grflg = gc_y
          inspflg = gc_ok
          lgort = <ls_log_data>-lgort
          grindat = sy-datum
          grintim = sy-uzeit
          grinnam = sy-uname
    ) ).
  ENDLOOP.

  CHECK lt_pp[] IS NOT INITIAL.

  MODIFY zppt0001 FROM TABLE lt_pp.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SAVE_ZPPT0001_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      --> LS_HDRET
*&---------------------------------------------------------------------*
FORM f_save_zppt0001_pogr_rcv2  USING  pt_log_data TYPE ty_t_zgtmmt9424
                                        ps_hdret TYPE bapi2017_gm_head_ret
                                        pt_dispo TYPE ty_t_po_dispo_pogr_rcv.


  DATA:
    lv_zspgcd TYPE zspgcd,
    lt_pp     TYPE STANDARD TABLE OF zppt0001.

  LOOP AT pt_log_data ASSIGNING FIELD-SYMBOL(<ls_log_data>).
    CHECK <ls_log_data>-charg IS NOT INITIAL OR <ls_log_data>-charg_new IS NOT INITIAL.
*입고처리플랜트&입고자재의 자재그룹이 공통마스터 정보에 존재하면 꼬리표 업데이트 제외.
    SELECT SINGLE matkl FROM mara
      WHERE matnr = @<ls_log_data>-matnr INTO @DATA(lv_matkl).

    READ TABLE gt_zgtppt1010 TRANSPORTING NO FIELDS
    WITH KEY fld_01 = <ls_log_data>-werks
                   fld_02 = lv_matkl BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR lv_zspgcd.
    READ TABLE pt_dispo ASSIGNING FIELD-SYMBOL(<ls_dispo>) WITH KEY ebeln = <ls_log_data>-ebeln
                                                                                                       ebelp = <ls_log_data>-ebelp BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_zspgcd = <ls_dispo>-dispo.
    ENDIF.

    lt_pp[] = VALUE #( BASE lt_pp (
          werks = <ls_log_data>-werks
          aufnr = <ls_log_data>-ebeln
          tagnr = <ls_log_data>-tagnr
          posnr = <ls_log_data>-ebelp
          charg = COND #( WHEN <ls_log_data>-charg_new IS NOT INITIAL
                                      THEN <ls_log_data>-charg_new
                                      ELSE <ls_log_data>-charg )
          mblnr = ps_hdret-mat_doc
          matnr = <ls_log_data>-matnr
          spgcd = lv_zspgcd
          mgvrg = <ls_log_data>-menge
          fostcnt = 1
          remain = <ls_log_data>-menge
          meins = <ls_log_data>-meins
          outflg = COND #( WHEN <ls_log_data>-pstyp EQ gc_3 THEN abap_true ELSE space )
          giflg = gc_n
          grflg = gc_y
          inspflg = gc_ok
          lgort = <ls_log_data>-lgort
          grindat = sy-datum
          grintim = sy-uzeit
          grinnam = sy-uname
    ) ).
  ENDLOOP.

  CHECK lt_pp[] IS NOT INITIAL.

  MODIFY zppt0001 FROM TABLE lt_pp.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_DISPO_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_DISPO
*&---------------------------------------------------------------------*
FORM f_get_po_dispo_pogr_rcv  USING  pt_tab TYPE ty_t_zgtmms4005
                             CHANGING ct_dispo TYPE ty_t_po_dispo_pogr_rcv.
  ##ITAB_KEY_IN_SELECT
  SELECT
    ep~ebeln,
    ep~ebelp,
    mc~dispo
    FROM ekpo AS ep
              INNER JOIN
            marc AS mc ON ep~werks EQ mc~werks
                          AND ep~matnr EQ mc~matnr
    WHERE EXISTS (
      SELECT zz~ebeln, zz~ebelp
        FROM @pt_tab AS zz
        WHERE zz~ebeln EQ ep~ebeln
           AND zz~ebelp EQ ep~ebelp
    )
    ORDER BY ep~ebeln, ep~ebelp
    INTO TABLE @ct_dispo.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_DISPO_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_DISPO
*&---------------------------------------------------------------------*
FORM f_get_po_dispo_pogr_rcv2  USING  pt_tab TYPE ty_t_zgtmms4009
                             CHANGING ct_dispo TYPE ty_t_po_dispo_pogr_rcv.
  ##ITAB_KEY_IN_SELECT
  SELECT
    ep~ebeln,
    ep~ebelp,
    mc~dispo
    FROM ekpo AS ep
              INNER JOIN
            marc AS mc ON ep~werks EQ mc~werks
                          AND ep~matnr EQ mc~matnr
    WHERE EXISTS (
      SELECT zz~ebeln, zz~ebelp
        FROM @pt_tab AS zz
        WHERE zz~ebeln EQ ep~ebeln
           AND zz~ebelp EQ ep~ebelp
    )
    ORDER BY ep~ebeln, ep~ebelp
    APPENDING TABLE @ct_dispo.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_DELCOMP_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_DELCOMP
*&---------------------------------------------------------------------*
FORM f_get_po_delcomp_pogr_rcv  USING  pt_tab TYPE ty_t_zgtmms4005
                             CHANGING ct_delcomp TYPE ty_t_po_delcomp_pogr_rcv.


*3-2-4-1) 납품문서 기준 COMPONENT 투입 정보가 존재하는 경우 정보 추출(DEL_COMP)
*            납품 문서 기준 마지막 수신 받은 KEY 기준 ZGTMMT9410-STATUS <>X 인 대상
*	TABLE: ZGTMMT9412
*	SELECT조건 : IDNRK,CHARG,WERKS,WERKS,ISSUE_QTY,ISSUE_UNIT,EBELN,EBELP
*	WHERE 조건:
*	DELNO = IT_TAB-DELNO
*	DELITEM = IT_TAB-DELITEM
*	EBELN = IT_TAB-EBELN
*	EBELP = IT_TAB-EBELP
  ##ITAB_KEY_IN_SELECT
  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9410 AS z1
      WHERE EXISTS (
        SELECT zz~delno
          FROM @pt_tab AS zz
          WHERE zz~ebeln EQ z1~ebeln
          AND zz~ebelp EQ z1~ebelp
          AND zz~delno EQ z1~delno
          AND zz~delitem EQ z1~delitem
          AND zz~werks EQ z1~werks
      )
      AND z1~system_id EQ @gc_ksrm
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z1~ebeln,
      z1~ebelp,
      z1~delno,
      z1~delitem,
      z2~idnrk,
      z2~lifnr,
      z2~charg,
      z2~werks,
      z2~lgort,
      z2~issue_qty,
      z2~issue_unit,
      mc~xchpf
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9410 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
                INNER JOIN
           zgtmmt9412 AS z2 ON v1~system_id EQ z2~system_id
                                       AND v1~delno EQ z2~delno
                                       AND v1~delitem EQ z2~delitem
                                       AND v1~werks EQ z2~werks
                                       AND v1~zifkey EQ z2~zifkey
                INNER JOIN
           marc AS mc ON z2~idnrk EQ mc~matnr
                            AND z2~werks EQ mc~werks
      WHERE z1~status EQ @space
     ORDER BY z1~ebeln, z1~ebelp, z1~delno, z1~delitem
     APPENDING CORRESPONDING FIELDS OF TABLE @ct_delcomp.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_PO_DELCOMP_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_DELCOMP
*&---------------------------------------------------------------------*
FORM f_get_po_delcomp_pogr_rcv2  USING  pt_tab TYPE ty_t_zgtmms4009
                             CHANGING ct_delcomp TYPE ty_t_po_delcomp_pogr_rcv.


*3-2-4-1) 납품문서 기준 COMPONENT 투입 정보가 존재하는 경우 정보 추출(DEL_COMP)
*            납품 문서 기준 마지막 수신 받은 KEY 기준 ZGTMMT9410-STATUS <>X 인 대상
*	TABLE: ZGTMMT9412
*	SELECT조건 : IDNRK,CHARG,WERKS,WERKS,ISSUE_QTY,ISSUE_UNIT,EBELN,EBELP
*	WHERE 조건:
*	DELNO = IT_TAB-DELNO
*	DELITEM = IT_TAB-DELITEM
*	EBELN = IT_TAB-EBELN
*	EBELP = IT_TAB-EBELP
  ##ITAB_KEY_IN_SELECT
  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9410 AS z1
      WHERE EXISTS (
        SELECT @abap_true
          FROM @pt_tab AS zz
          WHERE zz~ebeln EQ z1~ebeln
          AND zz~ebelp EQ z1~ebelp
*          AND ZZ~DELNO EQ Z1~DELNO
*          AND ZZ~DELITEM EQ Z1~DELITEM
          AND zz~werks EQ z1~werks
      )
      AND z1~system_id EQ @gc_ksrm
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z1~ebeln,
      z1~ebelp,
      z1~delno,
      z1~delitem,
      z2~idnrk,
      z2~lifnr,
      z2~charg,
      z2~werks,
      z2~lgort,
      z2~issue_qty,
      z2~issue_unit,
      mc~xchpf
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9410 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
                INNER JOIN
           zgtmmt9412 AS z2 ON v1~system_id EQ z2~system_id
                                       AND v1~delno EQ z2~delno
                                       AND v1~delitem EQ z2~delitem
                                       AND v1~werks EQ z2~werks
                                       AND v1~zifkey EQ z2~zifkey
                INNER JOIN
           marc AS mc ON z2~idnrk EQ mc~matnr
                            AND z2~werks EQ mc~werks
      WHERE z1~status EQ @space
     ORDER BY z1~ebeln, z1~ebelp, z1~delno, z1~delitem
     APPENDING CORRESPONDING FIELDS OF TABLE @ct_delcomp.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_MSLB_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_RESB
*&      --> LT_DELCOMP
*&      <-- LT_MSLB
*&---------------------------------------------------------------------*
FORM f_get_mslb_pogr_rcv  USING pt_resb TYPE ty_t_po_resb_pogr_rcv
                                   pt_delcomp TYPE ty_t_po_delcomp_pogr_rcv
                          CHANGING ct_mslb TYPE ty_t_mslb_pogr_rcv.

*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR"
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"

  DATA:
    BEGIN OF ls_key,
      matnr TYPE mslb-matnr,
      werks TYPE mslb-werks,
      lifnr TYPE mslb-lifnr,
    END OF ls_key,
    lt_key LIKE STANDARD TABLE OF ls_key.

  "KEY 생성
  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  SELECT DISTINCT
    zz~matnr,
    zz~werks,
    zz~lifnr
    FROM @pt_resb AS zz
    WHERE zz~xchpf EQ @abap_true
    AND zz~charg EQ @space
    APPENDING TABLE @lt_key.
  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  SELECT DISTINCT
    zz~idnrk,
    zz~werks,
    zz~lifnr
    FROM @pt_delcomp AS zz
    WHERE zz~xchpf EQ @abap_true
    AND zz~charg EQ @space
    APPENDING TABLE @lt_key.

  "중복제거
  SORT lt_key BY matnr werks lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_key COMPARING matnr werks lifnr.

  ##ITAB_KEY_IN_SELECT
  "재고조회
  SELECT
    ms~matnr,
    ms~werks,
    ms~charg,
    ms~lifnr,
    ms~lblab,
    mc~xpcbt
    FROM @lt_key AS zz
              INNER JOIN
            mslb AS ms ON zz~matnr EQ ms~matnr
                              AND zz~werks EQ ms~werks
                              AND zz~lifnr EQ ms~lifnr
              INNER JOIN
            mch1 AS mc ON ms~matnr EQ mc~matnr
                             AND ms~charg EQ mc~charg
    WHERE ms~lblab IS NOT INITIAL
    ORDER BY ms~matnr, ms~werks, ms~lifnr, mc~lwedt, ms~charg
    INTO TABLE @ct_mslb.


  "부분수량 GI 허용 플래그
  ##ITAB_KEY_IN_SELECT
  SELECT mm~matnr
    FROM marm AS mm
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_mslb AS zz
        WHERE zz~matnr EQ mm~matnr
    )
    AND mm~atinn IS NOT INITIAL
    AND mm~pcbut EQ @gc_b
    ORDER BY mm~matnr
    INTO TABLE @DATA(lt_marm).

  LOOP AT ct_mslb ASSIGNING FIELD-SYMBOL(<ls_mslb>).
    READ TABLE lt_marm WITH KEY matnr = <ls_mslb>-matnr BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK sy-subrc EQ 0.
    <ls_mslb>-xprgi = abap_true.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_BATCH_CHANGE_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_TAB>
*&---------------------------------------------------------------------*
FORM f_batch_change_pogr_rcv  USING   " PS_TAB TYPE ZGTMMS4005
                                                                        pv_mblnr TYPE mblnr
                                                                        pt_vc TYPE ty_t_batch_vc_value
                                                          CHANGING ps_tab TYPE zgtmms4005.
*C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*
*	데이터 설정
* BAPI 필드             VAULE
* MATERIAL              MATDOC-MATNR
* BATCH             MATDOC-CHARG
* PLANT             MATDOC-PLANT
*
*	BATCHATTRIBUTES	BATCHATTRIBUTES
* BAPI 필드             VAULE
* PROD_DATE             IT_TAB-HSDAT
*
*	BATCHATTRIBUTESX
* BAPI 필드             VAULE
* PROD_DATE             X
*
*   BAPI_BATCH_CHANGE 수행
*
*   4-5-1) RETURN-TYPE = E 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*   4-5-2) RETURN-TYPE = S 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*
  DATA:
    ls_attr   TYPE bapibatchatt,
    ls_attrx  TYPE bapibatchattx,
    lt_return TYPE STANDARD TABLE OF bapiret2.

  DATA:
    lv_matnr TYPE bapibatchkey-material,
    lv_charg TYPE bapibatchkey-batch,
    lv_werks TYPE bapibatchkey-plant.

  DATA:
    lt_alloc    TYPE TABLE OF bapi1003_alloc_values_char,
    lt_alc_num  TYPE TABLE OF bapi1003_alloc_values_num,
    lt_alc_curr TYPE TABLE OF bapi1003_alloc_values_curr,
    lv_class    TYPE bapi1003_key-classnum,
    lv_status   TYPE bapi1003_key-status,
    lv_key      TYPE bapi1003_key-object,
    lv_mat18    TYPE matnr18,
    lv_lenth    TYPE atwrt30.

  lv_matnr = CONV matnr18( ps_tab-matnr ).
  lv_charg = ps_tab-charg.
  lv_werks = ps_tab-werks.

  IF lv_charg IS INITIAL.
    CLEAR ps_tab-charg_new.

    SELECT SINGLE charg_sid
    FROM matdoc
    WHERE werks = @ps_tab-werks
         AND matnr = @ps_tab-matnr
         AND mblnr = @pv_mblnr
    INTO @lv_charg.

    IF lv_charg IS NOT INITIAL.
      ps_tab-charg_new = lv_charg.
    ENDIF.
  ENDIF.

  ls_attr-prod_date = ps_tab-hsdat.
  ls_attrx-prod_date = abap_true.

  CALL FUNCTION 'BAPI_BATCH_CHANGE'
    EXPORTING
      material         = lv_matnr
      batch            = lv_charg
      plant            = lv_werks
      batchattributes  = ls_attr
      batchattributesx = ls_attrx
    TABLES
      return           = lt_return.

  READ TABLE lt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDIF.

*>S.FACTOR BATCH 자재의 경우, 자재문서 생성 성공 후 배치 클래스 속성정보 업데이트 수행
*FACTOR BATCH 여부 체크 & 조장정보 가져오기.
  READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc>)
  WITH KEY ebeln = ps_tab-ebeln
                 ebelp = ps_tab-ebelp BINARY SEARCH.
  IF sy-subrc = 0.
    CLEAR lv_lenth.
    lv_lenth = <vc>-length.

* CLASS번호
    CLEAR: lv_class.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ps_tab-matnr "입고자재
        plant              = ps_tab-werks "플랜트
        classtype          = '023'       "클래스유형(배치)
      IMPORTING
        class              = lv_class
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 3.

    CHECK lv_class IS NOT INITIAL.
*배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR lt_alc_num.
    lt_alc_num[] = VALUE #( BASE lt_alc_num
                                                  ( charact = 'SAP_MILLCA_LENGTH'
                                                    value_from = lv_lenth )
                                                  ( charact = 'SAP_MILLCA_LENGTH_SUB'
                                                    value_from = lv_lenth ) ).
    CLEAR : lt_return.
    SELECT SINGLE cuobj_bm
         FROM mch1
         WHERE matnr = @ps_tab-matnr
             AND charg = @lv_charg
            INTO @DATA(lv_objkey).

    IF lv_objkey IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_alc_num
          allocvalueschar_new = lt_alloc
          allocvaluescurr_new = lt_alc_curr
          return              = lt_return.
*    CLEAR LT_ALLOC.
*    LT_ALLOC[] = VALUE #( BASE LT_ALLOC
*                                        ( CHARACT = 'SAP_MILLCA_LENGTH'
*                                          VALUE_CHAR = LV_LENTH )
*                                        ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
*                                           VALUE_CHAR = LV_LENTH ) ).
*
*    CLEAR : LV_KEY, LT_RETURN.
*    LV_MATNR = |{ LV_MATNR ALPHA = IN }|.
*    LV_KEY(18) = LV_MATNR.
*    LV_KEY+18(10) = LV_CHARG.
*
*    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*       EXPORTING
*         OBJECTKEY          = LV_KEY
*         OBJECTTABLE       = 'MCH1'
*         CLASSNUM           = LV_CLASS
*         CLASSTYPE          = '023'
*       TABLES
*         ALLOCVALUESNUMNEW  = LT_ALC_NUM
*         ALLOCVALUESCHARNEW = LT_ALLOC
*         ALLOCVALUESCURRNEW = LT_ALC_CURR
*         RETURN             = LT_RETURN
*            .
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_r2turn>) WITH KEY type = gc_e.
      IF sy-subrc EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
*<E.2026.07.22_ZGODEV04.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_BATCH_CHANGE_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_TAB>
*&---------------------------------------------------------------------*
FORM f_batch_change_pogr_rcv2  USING    ps_tab TYPE zgtmms4009
                                                                          pv_mblnr TYPE mblnr
                                                                          pt_vc TYPE ty_t_batch_vc_value.
*C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
*
*	데이터 설정
* BAPI 필드             VAULE
* MATERIAL              MATDOC-MATNR
* BATCH             MATDOC-CHARG
* PLANT             MATDOC-PLANT
*
*	BATCHATTRIBUTES	BATCHATTRIBUTES
* BAPI 필드             VAULE
* PROD_DATE             IT_TAB-HSDAT
*
*	BATCHATTRIBUTESX
* BAPI 필드             VAULE
* PROD_DATE             X
*
*   BAPI_BATCH_CHANGE 수행
*
*   4-5-1) RETURN-TYPE = E 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*   4-5-2) RETURN-TYPE = S 이면
*     : CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*
  DATA:
    ls_attr   TYPE bapibatchatt,
    ls_attrx  TYPE bapibatchattx,
    lt_return TYPE STANDARD TABLE OF bapiret2.

  DATA:
    lv_matnr TYPE bapibatchkey-material,
    lv_charg TYPE bapibatchkey-batch,
    lv_werks TYPE bapibatchkey-plant.

  DATA:
    lt_alloc    TYPE TABLE OF bapi1003_alloc_values_char,
    lt_alc_num  TYPE TABLE OF bapi1003_alloc_values_num,
    lt_alc_curr TYPE TABLE OF bapi1003_alloc_values_curr,
    lv_class    TYPE bapi1003_key-classnum,
    lv_status   TYPE bapi1003_key-status,
    lv_key      TYPE bapi1003_key-object,
    lv_mat18    TYPE matnr18,
    lv_lenth    TYPE atwrt30.

  lv_matnr = CONV matnr18( ps_tab-matnr ).
  lv_charg = ps_tab-charg.
  lv_werks = ps_tab-werks.

  IF lv_charg IS INITIAL.
*BAPI_배치자재(라벨정보) 제조일 업데이트
    SELECT SINGLE charg_sid
    FROM matdoc
    WHERE werks = @ps_tab-werks
         AND matnr = @ps_tab-matnr
         AND mblnr = @pv_mblnr
    INTO @lv_charg.

    IF lv_charg IS NOT INITIAL.
      ps_tab-charg_new = lv_charg.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'BAPI_BATCH_CHANGE'
    EXPORTING
      material         = lv_matnr
      batch            = lv_charg
      plant            = lv_werks
      batchattributes  = ls_attr
      batchattributesx = ls_attrx
    TABLES
      return           = lt_return.

  READ TABLE lt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDIF.

*>S.FACTOR BATCH 자재의 경우, 자재문서 생성 성공 후 배치 클래스 속성정보 업데이트 수행
*FACTOR BATCH 여부 체크 & 조장정보 가져오기.
  READ TABLE pt_vc ASSIGNING FIELD-SYMBOL(<vc>)
  WITH KEY ebeln = ps_tab-ebeln
                 ebelp = ps_tab-ebelp BINARY SEARCH.
  IF sy-subrc = 0.
    CLEAR lv_lenth.
    lv_lenth = <vc>-length.

* CLASS번호
    CLEAR: lv_class.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ps_tab-matnr "입고자재
        plant              = ps_tab-werks "플랜트
        classtype          = '023'       "클래스유형(배치)
      IMPORTING
        class              = lv_class
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 3.

    CHECK lv_class IS NOT INITIAL.
*배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR lt_alc_num.
    lt_alc_num[] = VALUE #( BASE lt_alc_num
                                                  ( charact = 'SAP_MILLCA_LENGTH'
                                                    value_from = lv_lenth )
                                                  ( charact = 'SAP_MILLCA_LENGTH_SUB'
                                                    value_from = lv_lenth ) ).
    CLEAR : lt_return.
    SELECT SINGLE cuobj_bm
         FROM mch1
         WHERE matnr = @ps_tab-matnr
             AND charg = @lv_charg
            INTO @DATA(lv_objkey).

    IF lv_objkey IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_alc_num
          allocvalueschar_new = lt_alloc
          allocvaluescurr_new = lt_alc_curr
          return              = lt_return.
*    LV_MATNR = |{ LV_MATNR ALPHA = IN }|.
*    LV_KEY(18) = LV_MATNR.
*    LV_KEY+18(10) = LV_CHARG.
*
*    CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*       EXPORTING
*         OBJECTKEY          = LV_KEY
*         OBJECTTABLE       = 'MCH1'
*         CLASSNUM           = LV_CLASS
*         CLASSTYPE          = '023'
*       TABLES
*         ALLOCVALUESNUMNEW  = LT_ALC_NUM
*         ALLOCVALUESCHARNEW = LT_ALLOC
*         ALLOCVALUESCURRNEW = LT_ALC_CURR
*         RETURN             = LT_RETURN
*            .
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_r2turn>) WITH KEY type = gc_e.
      IF sy-subrc EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
*<E.2026.07.22_ZGODEV04.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_ZGTMMT9450_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM f_get_zgtmmt9450_pogr_rcv  USING    pt_tab TYPE ty_t_zgtmms4005
                                CHANGING pt_zgtmmt9450 TYPE ty_t_zgtmmt9450.

*	TABLE : ZGTMMT9450
*	SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*	WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
  ##ITAB_KEY_IN_SELECT
  SELECT
    z1~ebeln,
    z1~ebelp,
    z1~werks,
    z1~idnrk,
    z1~charg,
    z1~menge,
    z1~meins
    FROM zgtmmt9450 AS z1
    WHERE EXISTS (
      SELECT @abap_true
      FROM @pt_tab AS zz
      WHERE zz~ebeln EQ z1~ebeln
        AND zz~ebelp EQ z1~ebelp
        AND zz~werks EQ z1~werks
    )
    ORDER BY z1~ebeln, z1~ebelp, z1~werks
    INTO CORRESPONDING FIELDS OF TABLE @pt_zgtmmt9450.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_ZGTMMT9450_POGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM f_get_zgtmmt9450_pogr_rcv2  USING    pt_tab TYPE ty_t_zgtmms4009
                                CHANGING pt_zgtmmt9450 TYPE ty_t_zgtmmt9450.

*	TABLE : ZGTMMT9450
*	SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*	WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
  ##ITAB_KEY_IN_SELECT
  SELECT
    z1~ebeln,
    z1~ebelp,
    z1~werks,
    z1~idnrk,
    z1~charg,
    z1~menge,
    z1~meins
    FROM zgtmmt9450 AS z1
    WHERE EXISTS (
      SELECT @abap_true
      FROM @pt_tab AS zz
      WHERE zz~ebeln EQ z1~ebeln
        AND zz~ebelp EQ z1~ebelp
        AND zz~werks EQ z1~werks
    )
    ORDER BY z1~ebeln, z1~ebelp, z1~werks
    APPENDING CORRESPONDING FIELDS OF TABLE @pt_zgtmmt9450.

ENDFORM.
**&---------------------------------------------------------------------*
**& FORM F_GET_STOCK_DRGR_RCV
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
**&      --> LT_TAB
**&---------------------------------------------------------------------*
*FORM F_GET_STOCK_DRGR_RCV  USING    PT_TAB TYPE TY_T_ZGTMMS4012.
*  "BAPI 사용
*  DATA:
*    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
*    LS_CODE   TYPE BAPI2017_GM_CODE,
*    LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
*    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
*    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
*    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.
*
**수신 받은 구매오더 정보로 재고 정보 조회
*
** 3-1) 구매오더 판매오더 정보 조회
*##ITAB_KEY_IN_SELECT
*  SELECT ZZ~MATNR,
*       ZZ~WERKS,
*       EK~VBELN,
*       EK~VBELP AS POSNR
*  FROM EKKN AS EK
*  INNER JOIN @PT_TAB AS ZZ
*    ON EK~EBELN = ZZ~EBELN
*   AND EK~EBELP = ZZ~EBELP
*  WHERE EK~VBELN IS NOT INITIAL
*    AND EK~VBELP IS NOT INITIAL
*  INTO TABLE @DATA(LT_BASE_SO).
*##ITAB_KEY_IN_SELECT
*  SELECT ZZ~MATNR,
*       ZZ~WERKS,
*       EK~VBELN,
*       EK~VBELP AS POSNR
*  FROM EKKN AS EK
*  INNER JOIN @PT_TAB AS ZZ
*    ON EK~EBELN = ZZ~EBELN
*   AND EK~EBELP = ZZ~EBELP
*  WHERE EK~VBELN = @SPACE
*     OR EK~VBELP = @SPACE
*  INTO TABLE @DATA(LT_BASE_NSO).
*
*  IF LT_BASE_SO IS NOT INITIAL.
**3-2) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨의 재고 조회
*    SELECT ST~MATNR, ST~WERKS, ST~LGORT,
*                 ST~CHARG, ST~VBELN, ST~POSNR,
*                 ST~LABST
*        FROM ZGTMM_CV_GET_STOCKLIST AS ST
*        INNER JOIN ZGTPPT1010 AS P10
*           ON P10~FLD_01 = ST~WERKS
*          AND P10~FLD_02 = ' '
*          AND ST~LGORT   = P10~FLD_03
*        FOR ALL ENTRIES IN @LT_BASE_SO
*        WHERE ST~MATNR = @LT_BASE_SO-MATNR
*          AND ST~WERKS   = @LT_BASE_SO-WERKS
*          AND ST~VBELN    = @LT_BASE_SO-VBELN
*          AND ST~POSNR    = @LT_BASE_SO-POSNR
*          AND P10~CODEGRP = '0830'
*        INTO TABLE @DATA(LT_STOCK_SO).
*      SORT LT_STOCK_SO BY MATNR WERKS LGORT CHARG.
*  ENDIF.
*
**3-3) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 조회
*  IF LT_BASE_NSO IS NOT INITIAL.
*    SELECT ST~MATNR, ST~WERKS, ST~LGORT, ST~CHARG, ST~LABST
*        FROM ZGTMM_CV_GET_STOCKLIST AS ST
*        INNER JOIN ZGTPPT1010 AS P10
*           ON P10~FLD_01 = ST~WERKS
*          AND P10~FLD_02 = ' '
*          AND ST~LGORT   = P10~FLD_03
*        FOR ALL ENTRIES IN @LT_BASE_NSO
*        WHERE ST~MATNR   = @LT_BASE_NSO-MATNR
*            AND ST~WERKS   = @LT_BASE_NSO-WERKS
*            AND P10~CODEGRP = '0830'
*        INTO TABLE @DATA(LT_STOCK_NSO).
*        SORT LT_STOCK_NSO BY MATNR WERKS LGORT .
*  ENDIF.
*
**  DATA(LT_FINAL_STOCK) = LT_STOCK_SO.
**  APPEND LINES OF LT_STOCK_NSO TO LT_FINAL_STOCK.
*
**특성값 조회 위한 변환
*  DATA: LV_ATINN TYPE ATINN.
*  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*    EXPORTING
*      INPUT  = 'SAP_MILLCA_LENGTH'
*    IMPORTING
*      OUTPUT = LV_ATINN.
*
**3-2) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨의 재고 존재 시,
*  IF LT_STOCK_SO[] IS INITIAL.
*    IF LT_STOCK_NSO[] IS INITIAL.
**3-2)/3-3)"재고 존재 하지 않으면, 기존 구매입고 처리..
*      EXIT.
*
**3-3) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 존재 시,
*    ELSE.
**3-3-1) 재고 수량이 0이 아닌 데이터의 배치-공급업체 정보 확인
*      SELECT MATNR, CHARG, LIFNR
*      FROM MCH1
*      FOR ALL ENTRIES IN @LT_STOCK_NSO
*      WHERE MATNR = @LT_STOCK_NSO-MATNR
*           AND CHARG = @LT_STOCK_NSO-CHARG
*      INTO TABLE @DATA(LT_MCH1_NSO).
*      SORT LT_MCH1_NSO BY LIFNR.
*
*      LOOP AT PT_TAB ASSIGNING FIELD-SYMBOL(<TAB1>).
*        SELECT SINGLE LIFNR
*        FROM EKKO
*        WHERE EBELN = @<TAB1>-EBELN
*        INTO @DATA(LV_LIFNR).
**3-2-1) 조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 동일한 '배치번호의 배치 특성'과 'PO 의 조장 정보 '비교
*        READ TABLE LT_MCH1_NSO TRANSPORTING NO FIELDS
*        WITH KEY LIFNR = LV_LIFNR BINARY SEARCH.
*
*      IF SY-SUBRC = 0.
**3-2-2) 구매오더 조장 길이
*        SELECT SINGLE LENGTH
*          FROM ZGTMM_CV_PO_VCVALUE_MAIN
*          WHERE PDOC = @<TAB1>-EBELN
*               AND PDOCITEM = @<TAB1>-EBELP
*          INTO @DATA(LV_LENGTH).
**3-2-3) 배치번호의 조장 길이
*        READ TABLE LT_STOCK_NSO ASSIGNING FIELD-SYMBOL(<NSO>)
*        WITH KEY MATNR = <TAB1>-MATNR
*                       WERKS = <TAB1>-WERKS BINARY SEARCH.
*        IF SY-SUBRC = 0.
*          SELECT SINGLE ATFLV
*          FROM ZGTSD_CV_GET_VCOFBATCH
*          WHERE MATNR = @<NSO>-MATNR
*               AND CHARG = @<NSO>-CHARG
*               AND LGORT = @<NSO>-LGORT
*               AND ATINN = @LV_ATINN "SAP_MILLCA_LENGTH
*          INTO @DATA(LV_ATFLV).
*        ENDIF.
*
*        IF LV_LENGTH = LV_ATFLV.
**3-3-2)/3-3-3) 같으면, 311 재고이전 입고
*
*        ELSE.
**3-3-2)/3-3-3)     다르면, 기존 구매입고 처리..
*          EXIT.
*        ENDIF.
*
**3-2-1)조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 다르면, 기존 구매입고 처리..
*      ELSE.
*          EXIT.
*      ENDIF.
*
*      CLEAR : LV_LENGTH, LV_ATFLV, LV_LIFNR.
*      ENDLOOP.
*    ENDIF.
*
**3-2) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨의 재고 존재 시,
*  ELSE.
**3-2-1) 재고 수량이 0이 아닌 데이터의 배치-공급업체 정보 확인
*    SELECT MATNR, CHARG, LIFNR
*      FROM MCH1
*      FOR ALL ENTRIES IN @LT_STOCK_SO
*      WHERE MATNR = @LT_STOCK_SO-MATNR
*           AND CHARG = @LT_STOCK_SO-CHARG
*      INTO TABLE @DATA(LT_MCH1_SO).
*      SORT LT_MCH1_SO BY MATNR CHARG LIFNR.
*
*    LOOP AT PT_TAB ASSIGNING FIELD-SYMBOL(<TAB>).
*      CLEAR LV_LIFNR.
*      SELECT SINGLE LIFNR
*        FROM EKKO
*        WHERE EBELN = @<TAB>-EBELN
*        INTO @LV_LIFNR.
**3-2-1) 조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 동일한 '배치번호의 배치 특성'과 'PO 의 조장 정보 '비교
*      READ TABLE LT_MCH1_SO ASSIGNING FIELD-SYMBOL(<MCH1>)
*      WITH KEY LIFNR = LV_LIFNR BINARY SEARCH.
*
*      IF SY-SUBRC = 0.
*        CLEAR : LV_LENGTH, LV_ATFLV.
**3-2-2) 구매오더 조장 길이
*        SELECT SINGLE LENGTH
*          FROM ZGTMM_CV_PO_VCVALUE_MAIN
*          WHERE PDOC = @<TAB>-EBELN
*               AND PDOCITEM = @<TAB>-EBELP
*          INTO @LV_LENGTH.
**3-2-3) 배치번호의 조장 길이
*        SELECT SINGLE ATFLV
*          FROM ZGTSD_CV_GET_VCOFBATCH
*          WHERE MATNR = @<TAB>-MATNR
*               AND CHARG = @<MCH1>-CHARG
*               AND ATINN = @LV_ATINN "SAP_MILLCA_LENGTH
*          INTO @LV_ATFLV.
*
*        IF LV_LENGTH = LV_ATFLV.
**3-2-2)/3-2-3) 같으면, 311 재고이전 입고
*        "초기화
*          CLEAR:
*            LS_CODE,
*            LS_HEADER,
*            LS_ITEM,
*            LT_ITEM[],
*            LT_RETURN[],
*            LS_HDRET.
*
*        "CODE 설정
*          LS_CODE-GM_CODE = GC_04.
*
*         "HEADER 설정
*          LS_HEADER-PSTNG_DATE = <TAB>-BUDAT.
*          LS_HEADER-DOC_DATE = <TAB>-BUDAT.
*          LS_HEADER-PR_UNAME = SY-UNAME.
*
*
*        "ITEM 설정
*          READ TABLE LT_STOCK_SO ASSIGNING FIELD-SYMBOL(<LST>)
*          WITH KEY MATNR = <TAB>-MATNR
*                         WERKS = <TAB>-WERKS
*                         LGORT = <TAB>-LGORT
*                         CHARG = <TAB>-CHARG BINARY SEARCH.
*          IF SY-SUBRC = 0.
*
*          ENDIF.
*
*          LS_ITEM-MATERIAL = <LST>-MATNR.
*          LS_ITEM-PLANT = <LST>-WERKS.
*          LS_ITEM-STGE_LOC = '3497'.
*          LS_ITEM-MOVE_STLOC = <LST>-LGORT.
**          LS_ITEM-PO_NUMBER = PS_TAB-EBELN.
**          LS_ITEM-PO_ITEM = PS_TAB-EBELP.
*          LS_ITEM-MOVE_TYPE = GC_311."'311'.
*          LS_ITEM-SPEC_STOCK = COND #( WHEN <LST>-VBELN IS INITIAL THEN ''
*                                                               ELSE GC_E ).
*          LS_ITEM-BATCH = <LST>-CHARG.
*          LS_ITEM-MOVE_BATCH = <LST>-CHARG.
*          LS_ITEM-VAL_SALES_ORD = <LST>-VBELN.
*          LS_ITEM-VAL_S_ORD_ITEM = <LST>-POSNR.
*          LS_ITEM-ENTRY_QNT = <TAB>-MENGE.
*          LS_ITEM-ENTRY_UOM = <TAB>-MEINS.
*          LS_ITEM-MVT_IND = COND #( WHEN <LST>-VBELN IS INITIAL
*                                                        THEN GC_B  ELSE '' ).
**          LS_ITEM-ITEM_TEXT = <TAB>-DR_LABELNO.
*
*          "BAPI실행
*          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*            EXPORTING
*              GOODSMVT_HEADER  = LS_HEADER
*              GOODSMVT_CODE    = LS_CODE
*            IMPORTING
*              GOODSMVT_HEADRET = LS_HDRET
*            TABLES
*              GOODSMVT_ITEM    = LT_ITEM
*              RETURN           = LT_RETURN.
*
*          READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = GC_E.
*          IF SY-SUBRC EQ 0.
*          "오류
*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*            LS_LOG-ZSTAT = GC_E.
*            LS_LOG-MESSAGE = <LS_RETURN>-MESSAGE.
*
*            ZO_RESULT = GC_02.
*            ZO_MESSAGE = TEXT-M02.""입고처리 실패"
*            MBLNR = SPACE.
*            MJAHR = SPACE.
*            ZTYPE = GC_E.
*            ZMESSAGE = <LS_RETURN>-MESSAGE.
*
*          ELSE.
*          "성공
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                WAIT = ABAP_TRUE.
*
*            LS_LOG-ZSTAT = GC_S.
*            LS_LOG-MESSAGE = SPACE.
*
*            ZO_RESULT = GC_00.
*            ZO_MESSAGE = TEXT-M01."입고처리 성공"
*            MBLNR = LS_HDRET-MAT_DOC.
*            MJAHR = LS_HDRET-DOC_YEAR.
*            ZTYPE = GC_S.
*            ZMESSAGE = SPACE.
*          ENDIF.
*
*
*
*        ELSE.
**3-2-2)/3-2-3)     다르면, 기존 구매입고 처리..
*        ENDIF.
*
**3-2-1)조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 다르면, 기존 구매입고 처리..
*      ELSE.
*          EXIT.
*      ENDIF.
*
*      CLEAR : LV_LENGTH, LV_ATFLV, LV_LIFNR.
*    ENDLOOP.
*
*  ENDIF.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_STOCK_DRGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&---------------------------------------------------------------------*
FORM f_get_stock_drgr_rcv  USING   " PT_TAB TYPE TY_T_ZGTMMS4012
                                                                 pt_dispo TYPE  ty_t_po_dispo_pogr_rcv
                                                                 pt_tab2 TYPE ty_t_zgtmms4014
                                       CHANGING pt_tab TYPE ty_t_zgtmms4012
                                                       ps_log TYPE zgtmmt9000
                                                       po_result
                                                       po_message
                                                       pv_mblnr
                                                       pv_mjahr
                                                       pv_ztype
                                                       pv_zmessage
                                                        pv_chk.
  "BAPI 사용
  DATA:
    ls_header TYPE bapi2017_gm_head_01,
    ls_code   TYPE bapi2017_gm_code,
    ls_item   TYPE bapi2017_gm_item_create,
    lt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lt_return TYPE STANDARD TABLE OF bapiret2,
    ls_hdret  TYPE bapi2017_gm_head_ret.

  DATA:
    ls_0001     TYPE zppt0001,
    lt_log_data TYPE STANDARD TABLE OF ty_zgtmmt9422,
    lt_log_doc  TYPE STANDARD TABLE OF zgtmmt9423,
    lt_dispo    TYPE ty_t_po_dispo_pogr_rcv.

  CLEAR pv_chk.

*수신 받은 구매오더 정보로 재고 정보 조회
  READ TABLE pt_tab ASSIGNING FIELD-SYMBOL(<tab>) INDEX 1.
  IF sy-subrc = 0.
*수신 구매오더의 공급처 확인.
    SELECT SINGLE lifnr
      FROM ekko
      WHERE ebeln = @<tab>-ebeln
      INTO @DATA(lv_lifnr).

* 3-1) 구매오더의 판매오더 정보 조회
    SELECT SINGLE @<tab>-matnr AS matnr,
                            @<tab>-werks AS werks,
                            vbeln, vbelp
    FROM ekkn
   WHERE ebeln = @<tab>-ebeln
        AND ebelp = @<tab>-ebelp
    INTO @DATA(ls_base).

*3-2) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 조회
    IF ls_base-vbeln IS INITIAL.
      SELECT st~matnr, st~werks, st~lgort,
                   st~charg, st~labst
          FROM zgtmm_cv_get_stocklist AS st
          INNER JOIN zgtppt1010 AS p10
             ON p10~fld_01 = st~werks
            AND p10~fld_02 = ' '
            AND st~lgort   = p10~fld_03
          WHERE st~matnr = @<tab>-matnr
            AND st~werks   = @<tab>-werks
            AND st~labst GT 0
            AND p10~module_kind = 'MM'  "코드 마스터 모듈 조건 추가
            AND p10~codegrp = '0830'
            AND st~sobkz EQ @space    "20260704 판매오더 연동 없는 경우 특별 재고 NULL 조건 추가
          INTO TABLE @DATA(lt_stock_nso).
      SORT lt_stock_nso BY matnr werks lgort charg.

*3-2) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨의 재고 조회
    ELSE.
      SELECT st~matnr, st~werks, st~lgort,
                   st~charg, st~vbeln, st~posnr,
                   st~labst
          FROM zgtmm_cv_get_stocklist AS st
          INNER JOIN zgtppt1010 AS p10
             ON p10~fld_01 = st~werks
            AND p10~fld_02 = ' '
            AND st~lgort   = p10~fld_03
          WHERE st~matnr = @ls_base-matnr
            AND st~werks   = @ls_base-werks
            AND st~vbeln    = @ls_base-vbeln
            AND st~posnr   = @ls_base-vbelp
            AND st~labst GT 0
            AND p10~module_kind = 'MM'  "코드 마스터 모듈 조건 추가
            AND p10~codegrp = '0830'
          INTO TABLE @DATA(lt_stock_so).
      SORT lt_stock_so BY matnr werks lgort charg.
    ENDIF.

  ENDIF.

*특성값 조회 위한 변환
  DATA: lv_atinn TYPE atinn.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = 'SAP_MILLCA_LENGTH'
    IMPORTING
      output = lv_atinn.

*3-3) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨
  IF ls_base-vbeln IS INITIAL.
    IF lt_stock_nso[] IS INITIAL.
*3-3)"재고 존재 하지 않으면, 기존 구매입고 처리..
      EXIT.
*3-3) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 존재 시,
    ELSE.
*3-3-1) 재고 수량이 0이 아닌 데이터의 배치-공급업체 정보 확인
      SELECT matnr, charg, lifnr
      FROM mch1
      FOR ALL ENTRIES IN @lt_stock_nso
      WHERE matnr = @lt_stock_nso-matnr
           AND charg = @lt_stock_nso-charg
      INTO TABLE @DATA(lt_mch1_nso).
      SORT lt_mch1_nso BY lifnr.

      LOOP AT pt_tab ASSIGNING FIELD-SYMBOL(<tab1>).
*3-2-1) 조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 동일한 '배치번호의 배치 특성'과 'PO 의 조장 정보 '비교
        READ TABLE lt_mch1_nso TRANSPORTING NO FIELDS
        WITH KEY lifnr = lv_lifnr BINARY SEARCH.

        IF sy-subrc = 0.
*3-2-2) 구매오더 조장 길이
          SELECT SINGLE length
            FROM zgtmm_cv_po_vcvalue_main
            WHERE pdoc = @<tab1>-ebeln
                 AND pdocitem = @<tab1>-ebelp
            INTO @DATA(lv_length).
*3-2-3) 배치번호의 조장 길이
          READ TABLE lt_stock_nso ASSIGNING FIELD-SYMBOL(<nso>)
          WITH KEY matnr = <tab1>-matnr
                         werks = <tab1>-werks BINARY SEARCH.
          IF sy-subrc = 0.
            SELECT SINGLE atflv
            FROM zgtsd_cv_get_vcofbatch
            WHERE matnr = @<nso>-matnr
                 AND charg = @<nso>-charg
                 AND lgort = @<nso>-lgort
                 AND atinn = @lv_atinn "SAP_MILLCA_LENGTH
            INTO @DATA(lv_atflv).
          ENDIF.

          IF lv_length = lv_atflv.
*3-4) 3-2) 와 3-3) 에서 조회된 재고 정보가 존재하고 구매오더 조장과 배치 특성의 조장 길이가 일치하는 경우
*         311  재고 이전 BAPI 처리 수행
            "초기화
            CLEAR:
              ls_code,
              ls_header,
              ls_item,
              lt_item[],
              lt_return[],
              ls_hdret.

            "CODE 설정
            ls_code-gm_code = gc_04.

            "HEADER 설정
            ls_header-pstng_date = <tab1>-budat.
            ls_header-doc_date = <tab1>-budat.
            ls_header-pr_uname = sy-uname.


            "ITEM 설정
            READ TABLE lt_stock_nso ASSIGNING FIELD-SYMBOL(<lst>)  "판매오더 없는 경우 LT_STOCK_NSO READ
            WITH KEY matnr = <tab1>-matnr
                           werks = <tab1>-werks BINARY SEARCH.
            IF sy-subrc = 0.
              ls_item-material = <lst>-matnr.
              ls_item-plant = <lst>-werks.
              ls_item-move_plant = <lst>-werks.
              ls_item-stge_loc = '3497'.
              ls_item-move_stloc = <tab1>-lgort.
              ls_item-move_type = gc_311."'311'.
*              LS_ITEM-SPEC_STOCK = COND #( WHEN <LST>-VBELN IS INITIAL THEN "판매오더 없는 경우 주석처리
*                                                                   ELSE GC_E ).
              ls_item-batch = <lst>-charg.
              ls_item-move_batch = <lst>-charg.
*              LS_ITEM-VAL_SALES_ORD = <LST>-VBELN."판매오더 없는 경우 주석처리
*              LS_ITEM-VAL_S_ORD_ITEM = <LST>-POSNR."판매오더 없는 경우 주석처리
              ls_item-entry_qnt = <tab1>-menge.
              ls_item-entry_uom = <tab1>-meins.
              ls_item-mvt_ind = space."GC_B."COND #( WHEN <LST>-VBELN IS INITIAL "판매오더 없는 경우 B로 고정
*                                                            THEN GC_B  ELSE '' ).
              APPEND ls_item TO lt_item.
*수신받은 배치없는데 재고배치가 있으면 자재문서 생성할 재고배치 정보 담아두기
*꼬리표테이블 업데이트용
              <tab1>-charg_new =
               COND #( WHEN <tab1>-charg IS INITIAL AND ls_item-batch IS NOT INITIAL
                              THEN ls_item-batch ELSE '' ).
            ENDIF.

            IF lt_item IS NOT INITIAL.
              "BAPI실행
              CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                EXPORTING
                  goodsmvt_header  = ls_header
                  goodsmvt_code    = ls_code
                IMPORTING
                  goodsmvt_headret = ls_hdret
                TABLES
                  goodsmvt_item    = lt_item
                  return           = lt_return.

              READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_retn>) WITH KEY type = gc_e.
              IF sy-subrc EQ 0.
                "오류
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                ps_log-zstat = gc_e.
                ps_log-message = <ls_retn>-message.

                po_result = gc_02.
                po_message = TEXT-m02.""입고처리 실패"
                pv_mblnr = space.
                pv_mjahr = space.
                pv_ztype = gc_e.
                pv_zmessage = <ls_retn>-message.
                pv_chk = abap_true.

              ELSE.
                "성공
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true.

                ps_log-zstat = gc_s.
                ps_log-message = space.

                po_result = gc_00.
                po_message = TEXT-m01."입고처리 성공"
                pv_mblnr = ls_hdret-mat_doc.
                pv_mjahr = ls_hdret-doc_year.
                pv_ztype = gc_s.
                pv_zmessage = space.
                pv_chk = abap_true.

              ENDIF.
              "로그 데이터 생성
              CLEAR lt_log_data[].

              APPEND VALUE #( BASE CORRESPONDING #( <tab1> )
                                         dr_label_no = <tab1>-dr_labelno
                                       ) TO lt_log_data.
*    4-4) 처리 결과 LOG 저장 및 RETURN
              PERFORM f_save_log_drgr_rcv USING ps_log lt_log_data ls_hdret pt_tab2.

              "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
              IF ps_log-zstat EQ gc_s.
                " 기존 꼬리표 테이블에 동일 WERKS 동일 TAGNR 존재하는 경우 -> 업데이트 제외
*>S.2026.08.06_재고이전의 경우, 동일한 꼬리표 번호가 존재하고 AUFNR = 공백이면 기존 라인 삭제 후 신규 Insert
                SELECT SINGLE *
                      FROM zppt0001
                      WHERE werks EQ @<tab1>-werks
                      AND tagnr EQ @<tab1>-tagnr
                                  INTO @ls_0001.
                IF ls_0001 IS NOT INITIAL AND ls_0001-aufnr IS INITIAL.
                  DELETE zppt0001 FROM @ls_0001.
                  COMMIT WORK.
                ENDIF.
                PERFORM f_save_zppt0001_drgr_rcv USING lt_log_data ls_hdret lt_dispo pv_chk ls_0001 lt_item.
*                SELECT SINGLE @ABAP_TRUE
*                  FROM ZPPT0001
*                  WHERE WERKS EQ @<TAB1>-WERKS
*                  AND TAGNR EQ @<TAB1>-TAGNR
*                                  INTO @DATA(LV_CHK).
*                IF LV_CHK IS INITIAL.
*                  PERFORM F_SAVE_ZPPT0001_DRGR_RCV USING LT_LOG_DATA LS_HDRET LT_DISPO PV_CHK LS_0001 LT_ITEM.
*                ENDIF.
*<E.2026.08.06_ZGODEV04
              ENDIF.
            ENDIF.

          ELSE.
*3-3-2)/3-3-3)     다르면, 기존 구매입고 처리..
            EXIT.
          ENDIF.

*3-2-1)조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 다르면, 기존 구매입고 처리..
        ELSE.
          EXIT.
        ENDIF.

        CLEAR : lv_length, lv_atflv, lv_lifnr.
      ENDLOOP.
    ENDIF.

*3-2) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨
  ELSE.
    IF lt_stock_so[] IS INITIAL.
*3-2)"재고 존재 하지 않으면, 기존 구매입고 처리..
      EXIT.

    ELSE.
*3-2-1) 재고 수량이 0이 아닌 데이터의 배치-공급업체 정보 확인
      SELECT matnr, charg, lifnr
        FROM mch1
        FOR ALL ENTRIES IN @lt_stock_so
        WHERE matnr = @lt_stock_so-matnr
             AND charg = @lt_stock_so-charg
        INTO TABLE @DATA(lt_mch1_so).
      SORT lt_mch1_so BY matnr charg lifnr.

      LOOP AT pt_tab ASSIGNING FIELD-SYMBOL(<tab2>).
*3-2-1) 조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 동일한 '배치번호의 배치 특성'과 'PO 의 조장 정보 '비교
        READ TABLE lt_mch1_so ASSIGNING FIELD-SYMBOL(<mch1s>)
        WITH KEY lifnr = lv_lifnr BINARY SEARCH.

        IF sy-subrc = 0.
          CLEAR : lv_length, lv_atflv.
*3-2-2) 구매오더 조장 길이
          SELECT SINGLE length
            FROM zgtmm_cv_po_vcvalue_main
            WHERE pdoc = @<tab2>-ebeln
                 AND pdocitem = @<tab2>-ebelp
            INTO @lv_length.
*3-2-3) 배치번호의 조장 길이
          SELECT SINGLE atflv
            FROM zgtsd_cv_get_vcofbatch
            WHERE matnr = @<tab2>-matnr
                 AND charg = @<mch1s>-charg
                 AND atinn = @lv_atinn "SAP_MILLCA_LENGTH
            INTO @lv_atflv.

          IF lv_length = lv_atflv.
*3-2-2)/3-2-3) 구매오더&배치 조장길이 같으면, 311 재고이전 입고

            "초기화
            CLEAR:
              ls_code,
              ls_header,
              ls_item,
              lt_item[],
              lt_return[],
              ls_hdret.

            "CODE 설정
            ls_code-gm_code = gc_04.

            "HEADER 설정
            ls_header-pstng_date = <tab2>-budat.
            ls_header-doc_date = <tab2>-budat.
            ls_header-pr_uname = sy-uname.


            "ITEM 설정
            READ TABLE lt_stock_so ASSIGNING FIELD-SYMBOL(<so>)
            WITH KEY matnr = <tab2>-matnr
                           werks = <tab2>-werks  BINARY SEARCH.
            IF sy-subrc = 0.
              ls_item-material = <so>-matnr.
              ls_item-plant = <so>-werks.
              ls_item-move_plant = <so>-werks.
              ls_item-stge_loc = '3497'.
              ls_item-move_stloc = <tab2>-lgort.
              ls_item-move_type = gc_311."'311'.
              ls_item-spec_stock = COND #( WHEN <so>-vbeln IS INITIAL THEN ''
                                                                   ELSE gc_e ).
              ls_item-batch = <so>-charg.
              ls_item-move_batch = <so>-charg.
              ls_item-val_sales_ord = <so>-vbeln.
              ls_item-val_s_ord_item = <so>-posnr.
              ls_item-entry_qnt = <tab2>-menge.
              ls_item-entry_uom = <tab2>-meins.
              ls_item-mvt_ind = COND #( WHEN <so>-vbeln IS INITIAL
                                                            THEN gc_b  ELSE '' ).
              APPEND ls_item TO lt_item.
*수신받은 배치없는데 재고배치가 있으면 자재문서 생성할 재고배치 정보 담아두기
*꼬리표테이블 업데이트용
              <tab2>-charg_new =
              COND #( WHEN <tab2>-charg IS INITIAL AND ls_item-batch IS NOT INITIAL
                             THEN ls_item-batch ELSE '' ).
            ENDIF.

            IF lt_item IS NOT INITIAL.
              "BAPI실행
              CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                EXPORTING
                  goodsmvt_header  = ls_header
                  goodsmvt_code    = ls_code
                IMPORTING
                  goodsmvt_headret = ls_hdret
                TABLES
                  goodsmvt_item    = lt_item
                  return           = lt_return.

              READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = gc_e.
              IF sy-subrc EQ 0.
                "오류
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                ps_log-zstat = gc_e.
                ps_log-message = <ls_return>-message.

                po_result = gc_02.
                po_message = TEXT-m02.""입고처리 실패"
                pv_mblnr = space.
                pv_mjahr = space.
                pv_ztype = gc_e.
                pv_zmessage = <ls_return>-message.
                pv_chk = abap_true.

              ELSE.
                "성공
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true.

                ps_log-zstat = gc_s.
                ps_log-message = space.

                po_result = gc_00.
                po_message = TEXT-m01."입고처리 성공"
                pv_mblnr = ls_hdret-mat_doc.
                pv_mjahr = ls_hdret-doc_year.
                pv_ztype = gc_s.
                pv_zmessage = space.
                pv_chk = abap_true.
              ENDIF.
              "로그 데이터 생성
              CLEAR lt_log_data[].
              APPEND VALUE #( BASE CORRESPONDING #( <tab2> )
                                         dr_label_no = <tab2>-dr_labelno
                                       ) TO lt_log_data.
*    4-4) 처리 결과 LOG 저장 및 RETURN
              PERFORM f_save_log_drgr_rcv USING ps_log lt_log_data ls_hdret pt_tab2.

              "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
              IF ps_log-zstat EQ gc_s.
                " 기존 꼬리표 테이블에 동일 WERKS 동일 TAGNR 존재하는 경우 -> 업데이트 제외
*>S.2026.08.06_재고이전의 경우, 동일한 꼬리표 번호가 존재하고 AUFNR = 공백이면 기존 라인 삭제 후 신규 Insert
                SELECT SINGLE *
                      FROM zppt0001
                      WHERE werks EQ @<tab1>-werks
                      AND tagnr EQ @<tab1>-tagnr
                                  INTO @ls_0001.
                IF ls_0001 IS NOT INITIAL AND ls_0001-aufnr IS INITIAL.
                  DELETE zppt0001 FROM @ls_0001.
                  COMMIT WORK.
                ENDIF.
                PERFORM f_save_zppt0001_drgr_rcv USING lt_log_data ls_hdret lt_dispo pv_chk ls_0001 lt_item.
*                SELECT SINGLE @ABAP_TRUE
*                  FROM ZPPT0001
*                  WHERE WERKS EQ @<TAB1>-WERKS
*                  AND TAGNR EQ @<TAB1>-TAGNR
*                                  INTO @DATA(LV_CHK).
*                IF LV_CHK IS INITIAL.
*                  PERFORM F_SAVE_ZPPT0001_DRGR_RCV USING LT_LOG_DATA LS_HDRET LT_DISPO PV_CHK LS_0001 LT_ITEM.
*                ENDIF.
*<E.2026.08.06_ZGODEV04
              ENDIF.
            ENDIF.

          ELSE.
*3-2-2)/3-2-3)  구매오더&배치 조장길이 다르면, 기존 구매입고 처리..
            EXIT.
          ENDIF.

*3-2-1)조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 다르면, 기존 구매입고 처리..
        ELSE.
          EXIT.
        ENDIF.

        CLEAR : lv_length, lv_atflv, lv_lifnr.
      ENDLOOP.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_GET_STOCK_DRGR_RCV2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&---------------------------------------------------------------------*
FORM f_get_stock_drgr_rcv2  USING pt_dispo TYPE  ty_t_po_dispo_pogr_rcv
                                       CHANGING pt_tab TYPE ty_t_zgtmms4012
                                                       pt_tab2 TYPE ty_t_zgtmms4014
                                                       ps_log TYPE zgtmmt9000
                                                       po_result
                                                       po_message
                                                       pv_mblnr
                                                       pv_mjahr
                                                       pv_ztype
                                                       pv_zmessage
                                                       pv_chk.
  "BAPI 사용
  DATA:
    ls_header TYPE bapi2017_gm_head_01,
    ls_code   TYPE bapi2017_gm_code,
    ls_item   TYPE bapi2017_gm_item_create,
    lt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
    lt_return TYPE STANDARD TABLE OF bapiret2,
    ls_hdret  TYPE bapi2017_gm_head_ret,
    ls_0001   TYPE zppt0001.

  DATA:
    lt_log_data  TYPE STANDARD TABLE OF ty_zgtmmt9422,
    lt_log_doc   TYPE STANDARD TABLE OF zgtmmt9423,
    lt_dispo     TYPE ty_t_po_dispo_pogr_rcv,
    lv_charg_rcv TYPE charg_d,           "PO기반 원입고 배치번호
    lv_length    TYPE atwrt,             "PO 조장길이 (ZGTMM_CV_PO_VCVALUE_MAIN-LENGTH)
    lv_atflv     TYPE atflv.             "배치 조장길이 (ZGTSD_CV_GET_VCOFBATCH-ATFLV)

  CLEAR pv_chk.

  CHECK pt_tab2 IS NOT INITIAL.
*납품번호 기준의 납품서유형 정보 가져오기.
  SELECT delno,
               delitem,
               deltype
    FROM zgtmmt9410
    FOR ALL ENTRIES IN @pt_tab2
    WHERE delno = @pt_tab2-delno
        AND delitem = @pt_tab2-delitem
    INTO TABLE @DATA(lt_9410).
  SORT lt_9410 BY delno delitem deltype.

  READ TABLE pt_tab2 ASSIGNING FIELD-SYMBOL(<tab22>) INDEX 1.
  IF sy-subrc = 0.
    "납품문서의 유형 체크
    "<-- 2026.08.12 A or B일때로 수정
*    READ TABLE LT_9410 ASSIGNING FIELD-SYMBOL(<DTYPE>)
*    WITH KEY DELNO = <TAB22>-DELNO
*                   DELITEM = <TAB22>-DELITEM
*                   DELTYPE = 'A' BINARY SEARCH.
*    IF SY-SUBRC = 0.
    READ TABLE lt_9410 ASSIGNING FIELD-SYMBOL(<dtype>)
    WITH KEY delno = <tab22>-delno
                   delitem = <tab22>-delitem.

*1)DELTYPE= A or B  이면 재고 이전처리대상-> 311  재고 이전 BAPI 처리 수행
    IF <dtype>-deltype EQ gc_a OR <dtype>-deltype EQ gc_b.
      "--> 2026.08.12 A or B일때로 수정

*)수신 받은 구매오더 정보로 재고 정보 조회(IT_TAB 기준으로 재고 조회)
      READ TABLE pt_tab ASSIGNING FIELD-SYMBOL(<tab>) INDEX 1.
      IF sy-subrc = 0.
*수신 구매오더의 공급처 확인.
        SELECT SINGLE lifnr
          FROM ekko
          WHERE ebeln = @<tab>-ebeln
          INTO @DATA(lv_lifnr).

* 1-1) 구매오더의 판매오더 정보 조회
        SELECT SINGLE @<tab>-matnr AS matnr,
                                @<tab>-werks AS werks,
                                vbeln, vbelp
        FROM ekkn
       WHERE ebeln = @<tab>-ebeln
            AND ebelp = @<tab>-ebelp
        INTO @DATA(ls_base).

* <--2026.08.13 DELTYPE B인경우 재고 로직 변경
* LS_BASE의 판매문서를 그대로 사용하지 않고 VBAP의 VGBEL/VGPOS로 판매문서 재조회
        IF <dtype>-deltype EQ gc_b.
          SELECT SINGLE vbeln, posnr
            FROM vbap
            WHERE vgbel EQ @ls_base-vbeln
            AND vgpos EQ @ls_base-vbelp
            INTO @DATA(ls_base_b).

          IF sy-subrc EQ 0.
            CLEAR ls_base.
            ls_base = VALUE #( matnr = <tab>-matnr
                                             werks = <tab>-werks
                                             vbeln = ls_base_b-vbeln
                                             vbelp = ls_base_b-posnr ).
          ENDIF.
        ENDIF.
* -->2026.08.13 DELTYPE B인경우 재고 로직 변경

        " 코드마스터 조회 (보관품 명세서 처리 기준)
        SELECT SINGLE
                fld_01 AS deltype,
                fld_02 AS werks,
                fld_03 AS werks_stock,
                fld_04 AS lgort
          FROM zgtppt1010
          WHERE module_kind = 'MM'
          AND codegrp = @gc_0780
          AND fld_01 EQ @<dtype>-deltype
          AND fld_02 EQ @<tab>-werks
          INTO @DATA(ls_1010).

*1-2) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 조회
        IF ls_base-vbeln IS INITIAL.
          SELECT matnr, werks, lgort, charg, labst  "코드마스터 기반 수정
             FROM zgtmm_cv_get_stocklist
            WHERE matnr EQ @<tab>-matnr
                AND werks EQ @ls_1010-werks_stock
                AND lgort EQ @ls_1010-lgort
                AND labst GT 0
                AND sobkz EQ @space    "20260704 판매오더 연동 없는 경우 특별 재고 NULL 조건 추가
                INTO TABLE @DATA(lt_stock_nso).
          SORT lt_stock_nso BY matnr werks lgort charg.

*1-3) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨의 재고 조회
        ELSE.

          SELECT matnr, werks, lgort, charg, vbeln, posnr, labst
             FROM zgtmm_cv_get_stocklist
            WHERE matnr EQ @ls_base-matnr
                AND vbeln  EQ @ls_base-vbeln
                AND posnr  EQ @ls_base-vbelp
                AND werks EQ @ls_1010-werks_stock
                AND lgort EQ @ls_1010-lgort
                AND labst GT 0
              INTO TABLE @DATA(lt_stock_so).
          SORT lt_stock_so BY matnr werks lgort charg.

        ENDIF.
      ENDIF.

*특성값 조회 위한 변환
      DATA: lv_atinn TYPE atinn.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          input  = 'SAP_MILLCA_LENGTH'
        IMPORTING
          output = lv_atinn.

*1-2) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨
      IF ls_base-vbeln IS INITIAL.
        IF lt_stock_nso[] IS INITIAL.
*1-2-1) 재고 존재 하지 않으면, 기존 구매입고 처리..
          EXIT.
*1-2-2) 구매오더 품목에 VBELN,VBELP 값이 없는 라벨의 재고 존재 시,
        ELSE.

          LOOP AT PT_TAB ASSIGNING FIELD-SYMBOL(<TAB2>).

*1-2-3) MATDOC에서 EBELN/EBELP 기반 입고 배치 전체 조회 (최신순)
            CLEAR LV_CHARG_RCV.
            SELECT CHARG
              FROM MATDOC
              WHERE EBELN = @<TAB2>-EBELN
                AND EBELP = @<TAB2>-EBELP
                AND MATNR = @<TAB2>-MATNR
                AND WERKS = @LS_1010-WERKS_STOCK
                AND BWART = '101'
                AND SHKZG = 'S'
              ORDER BY MJAHR DESCENDING, MBLNR DESCENDING, ZEILE DESCENDING
              INTO TABLE @DATA(LT_MATDOC_CHARG).

*1-2-4) MATDOC 배치 중 보관창고 재고 있는 배치 선택
            LOOP AT LT_MATDOC_CHARG ASSIGNING FIELD-SYMBOL(<LMC>).
              READ TABLE LT_STOCK_NSO TRANSPORTING NO FIELDS
                WITH KEY MATNR = <TAB2>-MATNR
                         CHARG = <LMC>-CHARG.
              IF SY-SUBRC EQ 0.
                LV_CHARG_RCV = <LMC>-CHARG.
                EXIT.
              ENDIF.
            ENDLOOP.

*1-2-4F) MATDOC 미조회/재고없음 → ZPPT0001 fallback (P배치 등)
            IF LV_CHARG_RCV IS INITIAL.
              SELECT SINGLE CHARG
                FROM ZPPT0001
                WHERE WERKS = @<TAB2>-WERKS
                  AND TAGNR = @<TAB2>-DR_LABELNO
                  AND CHARG IS NOT INITIAL
                INTO @LV_CHARG_RCV.
              IF LV_CHARG_RCV IS INITIAL.
                EXIT. "ZPPT0001도 없음 → 기존 구매입고 처리
              ENDIF.
            ENDIF.

*1-2-4G) 최종 재고 확인 및 <LST> 설정 (MATDOC/ZPPT0001 공통)
            READ TABLE LT_STOCK_NSO ASSIGNING FIELD-SYMBOL(<LST>)
              WITH KEY MATNR = <TAB2>-MATNR
                       CHARG = LV_CHARG_RCV.
            IF SY-SUBRC NE 0.
              EXIT. "재고 없음 → 기존 구매입고 처리
            ENDIF.

*1-2-4-1) 조장길이 검증: PO 조장 vs 배치 조장
            CLEAR: LV_LENGTH, LV_ATFLV.
            SELECT SINGLE LENGTH
              FROM ZGTMM_CV_PO_VCVALUE_MAIN
              WHERE PDOC     = @<TAB2>-EBELN
                AND PDOCITEM = @<TAB2>-EBELP
              INTO @LV_LENGTH.

            SELECT SINGLE ATFLV
              FROM ZGTSD_CV_GET_VCOFBATCH
              WHERE MATNR = @<LST>-MATNR
                AND CHARG = @<LST>-CHARG
                AND LGORT = @<LST>-LGORT
                AND ATINN = @LV_ATINN
              INTO @LV_ATFLV.

            IF LV_LENGTH NE LV_ATFLV.
              EXIT. "조장 불일치 → 기존 구매입고 처리
            ENDIF.

*1-2-5) 311 재고이전 BAPI 처리
                CLEAR:
                  ls_code,
                  ls_header,
                  ls_item,
                  lt_item[],
                  lt_return[],
                  ls_hdret.

                "CODE 설정
                ls_code-gm_code = gc_04.

                "HEADER 설정
                ls_header-pstng_date = <tab2>-budat.
                ls_header-doc_date   = <tab2>-budat.
                ls_header-pr_uname   = sy-uname.
                ls_header-header_txt = <tab2>-dr_labelno.

                "ITEM 설정 - PO기반으로 특정된 배치(<lst>-charg) 사용
                ls_item-material   = <lst>-matnr.
                ls_item-plant      = <lst>-werks.
                ls_item-move_plant = <lst>-werks.
                ls_item-stge_loc   = ls_1010-lgort.
                ls_item-move_stloc = <tab2>-lgort.
                ls_item-move_type  = gc_311.
                ls_item-batch      = <lst>-charg.
                ls_item-move_batch = <lst>-charg.
                ls_item-entry_qnt  = <tab2>-menge.
                ls_item-entry_uom  = <tab2>-meins.
                ls_item-mvt_ind    = space.
                APPEND ls_item TO lt_item.
*수신받은 배치없는데 재고배치가 있으면 자재문서 생성할 재고배치 정보 담아두기
*꼬리표테이블 업데이트용
                <tab2>-charg_new =
                  COND #( WHEN <tab2>-charg IS INITIAL AND ls_item-batch IS NOT INITIAL
                               THEN ls_item-batch ELSE '' ).

                IF lt_item IS NOT INITIAL.
                  "BAPI실행
                  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                    EXPORTING
                      goodsmvt_header  = ls_header
                      goodsmvt_code    = ls_code
                    IMPORTING
                      goodsmvt_headret = ls_hdret
                    TABLES
                      goodsmvt_item    = lt_item
                      return           = lt_return.

                  READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_retn>) WITH KEY type = gc_e.
                  IF sy-subrc EQ 0.
                    "오류
                    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                    ps_log-zstat = gc_e.
                    ps_log-message = <ls_retn>-message.

                    po_result = gc_02.
                    po_message = TEXT-m02.""입고처리 실패"
                    pv_mblnr = space.
                    pv_mjahr = space.
                    pv_ztype = gc_e.
                    pv_zmessage = <ls_retn>-message.
                    pv_chk = abap_true.

                  ELSE.
                    "성공
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        wait = abap_true.

                    ps_log-zstat = gc_s.
                    ps_log-message = space.

                    po_result = gc_00.
                    po_message = TEXT-m01."입고처리 성공"
                    pv_mblnr = ls_hdret-mat_doc.
                    pv_mjahr = ls_hdret-doc_year.
                    pv_ztype = gc_s.
                    pv_zmessage = space.
                    pv_chk = abap_true.
*>S.입고처리 성공 후 배치특성 업데이트 로직 추가
                    PERFORM f_update_class_batch_drgr USING <tab2> .
*<E.2026.08.06_ZGODEV04
                  ENDIF.
                  "로그 데이터 생성
                  CLEAR lt_log_data[].

                  APPEND VALUE #( BASE CORRESPONDING #( <tab2> )
                                             dr_label_no = <tab2>-dr_labelno
                                           ) TO lt_log_data.
*    4-4) 처리 결과 LOG 저장 및 RETURN
                  PERFORM f_save_log_drgr_rcv USING ps_log lt_log_data ls_hdret pt_tab2.

                  "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
                  IF ps_log-zstat EQ gc_s.
*>S.2026.08.06_재고이전의 경우, 동일한 꼬리표 번호가 존재하고 AUFNR = 공백이면 기존 라인 삭제 후 신규 Insert
*>2026.09.29_311은 플랜트 이동이 아니므로 꼬리표는 재고 플랜트 기준으로 저장(전용 루틴)
                    PERFORM f_save_zppt0001_drgr_rcv_311 USING lt_log_data ls_hdret lt_dispo.
*<E.2026.08.06_ZGODEV04
                  ENDIF.
                ENDIF.
          ENDLOOP.
        ENDIF.

*1-3) 구매오더 품목에 VBELN,VBELP 값이 존재하는 라벨
      ELSE.
        IF lt_stock_so[] IS INITIAL.
*1-3-1) 재고 존재 하지 않으면, 기존 구매입고 처리..
          EXIT.

        ELSE.
*재고 수량이 0이 아닌 데이터의 배치-공급업체 정보 확인
          SELECT matnr, charg, lifnr
            FROM mch1
            FOR ALL ENTRIES IN @lt_stock_so
            WHERE matnr = @lt_stock_so-matnr
                 AND charg = @lt_stock_so-charg
            INTO TABLE @DATA(lt_mch1_so).
          SORT lt_mch1_so BY matnr charg lifnr.

          LOOP AT pt_tab ASSIGNING <tab2>.
*1-3-2) 조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 동일한 '배치번호의 배치 특성'과 'PO 의 조장 정보 '비교
*>2026.09.29_정렬 키가 matnr/charg/lifnr 이므로 lifnr 단독 BINARY SEARCH 불가 -> 순차 조회
            READ TABLE lt_mch1_so ASSIGNING FIELD-SYMBOL(<mch1s>)
            WITH KEY lifnr = lv_lifnr.

            IF sy-subrc = 0.
              CLEAR : lv_length, lv_atflv.
*구매오더 조장 길이
              SELECT SINGLE length
                FROM zgtmm_cv_po_vcvalue_main
                WHERE pdoc = @<tab2>-ebeln
                     AND pdocitem = @<tab2>-ebelp
                INTO @lv_length.
*배치번호의 조장 길이
              SELECT SINGLE atflv
                FROM zgtsd_cv_get_vcofbatch
                WHERE matnr = @<tab2>-matnr
                     AND charg = @<mch1s>-charg
                     AND atinn = @lv_atinn "SAP_MILLCA_LENGTH
                INTO @lv_atflv.

              IF lv_length = lv_atflv.
*1-3-3) 구매오더&배치 조장길이 같으면, 311 재고이전 입고

                CLEAR:
                  ls_code,
                  ls_header,
                  ls_item,
                  lt_item[],
                  lt_return[],
                  ls_hdret.

                "CODE 설정
                ls_code-gm_code = gc_04.

                "HEADER 설정
                ls_header-pstng_date = <tab2>-budat.
                ls_header-doc_date = <tab2>-budat.
                ls_header-pr_uname = sy-uname.
                ls_header-header_txt = <tab2>-dr_labelno.  "2026.08.14 헤더 텍스트에 라벨번호 추가

                "ITEM 설정
                " 2026.08.13 READ 기준 오름차순 1건으로 변경
                READ TABLE lt_stock_so ASSIGNING FIELD-SYMBOL(<so>) INDEX 1.
*                WITH KEY MATNR = <TAB2>-MATNR
*                               WERKS = <TAB2>-WERKS  BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_item-material = <so>-matnr.
                  ls_item-plant = <so>-werks.
                  ls_item-move_plant = <so>-werks.
                  ls_item-stge_loc = ls_1010-lgort. "'3497'.  "2026.08.12 코드마스터 지정된 저장위치에서 출고
                  ls_item-move_stloc = <tab2>-lgort.
                  ls_item-move_type = gc_311."'311'.
                  ls_item-spec_stock = COND #( WHEN <so>-vbeln IS INITIAL THEN ''
                                                                       ELSE gc_e ).
                  ls_item-batch = <so>-charg.
                  ls_item-move_batch = <so>-charg.
                  ls_item-val_sales_ord = <so>-vbeln.
                  ls_item-val_s_ord_item = <so>-posnr.
                  ls_item-entry_qnt = <tab2>-menge.
                  ls_item-entry_uom = <tab2>-meins.
                  ls_item-mvt_ind = COND #( WHEN <so>-vbeln IS INITIAL
                                                                THEN gc_b  ELSE '' ).
                  APPEND ls_item TO lt_item.
*수신받은 배치없는데 재고배치가 있으면 자재문서 생성할 재고배치 정보 담아두기
*꼬리표테이블 업데이트용
                  <tab2>-charg_new =
                  COND #( WHEN <tab2>-charg IS INITIAL AND ls_item-batch IS NOT INITIAL
                                 THEN ls_item-batch ELSE '' ).
                ENDIF.

                IF lt_item IS NOT INITIAL.
                  "BAPI실행
                  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
                    EXPORTING
                      goodsmvt_header  = ls_header
                      goodsmvt_code    = ls_code
                    IMPORTING
                      goodsmvt_headret = ls_hdret
                    TABLES
                      goodsmvt_item    = lt_item
                      return           = lt_return.

                  READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY type = gc_e.
                  IF sy-subrc EQ 0.
                    "오류
                    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                    ps_log-zstat = gc_e.
                    ps_log-message = <ls_return>-message.

                    po_result = gc_02.
                    po_message = TEXT-m02.""입고처리 실패"
                    pv_mblnr = space.
                    pv_mjahr = space.
                    pv_ztype = gc_e.
                    pv_zmessage = <ls_return>-message.
                    pv_chk = abap_true.

                  ELSE.
                    "성공
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        wait = abap_true.

                    ps_log-zstat = gc_s.
                    ps_log-message = space.

                    po_result = gc_00.
                    po_message = TEXT-m01."입고처리 성공"
                    pv_mblnr = ls_hdret-mat_doc.
                    pv_mjahr = ls_hdret-doc_year.
                    pv_ztype = gc_s.
                    pv_zmessage = space.
                    pv_chk = abap_true.
*>S.입고처리 성공 후 배치특성 업데이트 로직 추가
                    PERFORM f_update_class_batch_drgr USING <tab2> .
*<E.2026.08.06_ZGODEV04
                  ENDIF.
                  "로그 데이터 생성
                  CLEAR lt_log_data[].
                  APPEND VALUE #( BASE CORRESPONDING #( <tab2> )
                                             dr_label_no = <tab2>-dr_labelno
                                           ) TO lt_log_data.
*    4-4) 처리 결과 LOG 저장 및 RETURN
                  PERFORM f_save_log_drgr_rcv USING ps_log lt_log_data ls_hdret pt_tab2.

                  "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
                  IF ps_log-zstat EQ gc_s.
                    " 기존 꼬리표 테이블에 동일 WERKS 동일 TAGNR 존재하는 경우 -> 업데이트 제외
*>S.2026.08.06_재고이전의 경우, 동일한 꼬리표 번호가 존재하고 AUFNR = 공백이면 기존 라인 삭제 후 신규 Insert
*>2026.09.29_311은 플랜트 이동이 아니므로 꼬리표는 재고 플랜트 기준으로 저장(전용 루틴)
                    PERFORM f_save_zppt0001_drgr_rcv_311 USING lt_log_data ls_hdret lt_dispo.
                  ENDIF.
*<E.2026.08.06_ZGODEV04
                ENDIF.

              ELSE.
*3-2-2)/3-2-3)  구매오더&배치 조장길이 다르면, 기존 구매입고 처리..
                EXIT.
              ENDIF.

*3-2-1)조회한 LIFNR 과 수신한 구매오더의 LIFNR 값이 다르면, 기존 구매입고 처리..
            ELSE.
              EXIT.
            ENDIF.

            CLEAR : lv_length, lv_atflv, lv_lifnr.
          ENDLOOP.

        ENDIF.
      ENDIF.

*1-2)DELTYPE NE 'A' ->기존 구매입고 처리..
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM UPDATE_CLASS_BATCH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <LS_ZGTMMT9440>
*&---------------------------------------------------------------------*
FORM update_class_batch  USING  ps_9440 TYPE  zgtmmt9440.

  DATA:
    lt_return   TYPE STANDARD TABLE OF bapiret2,
    lt_alloc    TYPE TABLE OF bapi1003_alloc_values_char,
    lt_alc_num  TYPE TABLE OF bapi1003_alloc_values_num,
    lt_alc_curr TYPE TABLE OF bapi1003_alloc_values_curr,
    lv_class    TYPE klah-class,
    lv_status   TYPE bapi1003_key-status,
    lv_key      TYPE bapi1003_key-object,
    lv_mat18    TYPE matnr18,
    lv_lenth    TYPE atwrt30.

*1)FACTOR BATCH 여부 체크
  SELECT SINGLE  dpcbt
      FROM marc
      WHERE matnr EQ @ps_9440-matnr
           AND werks EQ @ps_9440-werks
          INTO @DATA(lv_dpcbt).

  IF lv_dpcbt = 'A'. "FACTOR BATCH
    CLEAR lv_lenth.
*2)조장정보 설정(수신받은 배치 정보가 조장 정보임)
    lv_lenth = ps_9440-charg.
    CONDENSE lv_lenth NO-GAPS.
*3) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: lv_class.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        material           = ps_9440-matnr "입고자재
        plant              = ps_9440-werks "플랜트
        classtype          = '023'       "클래스유형(배치)
      IMPORTING
        class              = lv_class
      EXCEPTIONS
        no_class_found     = 1
        no_classtype_found = 2
        OTHERS             = 3.

    CHECK lv_class IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR lt_alc_num.
    lt_alc_num[] = VALUE #( BASE lt_alc_num
                                             ( charact = 'SAP_MILLCA_LENGTH'
                                               value_from = lv_lenth )
                                             ( charact = 'SAP_MILLCA_LENGTH_SUB'
                                               value_from = lv_lenth ) ).
    CLEAR : lt_return.
    SELECT SINGLE cuobj_bm
         FROM mch1
         WHERE matnr = @ps_9440-matnr
             AND charg = @ps_9440-charg
            INTO @DATA(lv_objkey).

    IF lv_objkey IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_alc_num
          allocvalueschar_new = lt_alloc
          allocvaluescurr_new = lt_alc_curr
          return              = lt_return.
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_r2turn>) WITH KEY type = gc_e.
      IF sy-subrc EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.
