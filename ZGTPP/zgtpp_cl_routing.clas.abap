class ZGTPP_CL_ROUTING definition
  public
  final
  create public .

public section.

  data:
    BEGIN OF ms_main_seq_routing,
        seqno     TYPE i,   " 공정단계
        stufe     TYPE histu,
        matnr     TYPE matnr,
        mtart     TYPE mtart,
        chart     TYPE atwrt,
        chart_val TYPE  atwtb30,
        maabc     TYPE marc-maabc, "ABC 지시자
      END OF ms_main_seq_routing .
  data:
    mt_main_seq_routing LIKE TABLE OF ms_main_seq_routing .
  data:
    mt_2010 TYPE TABLE OF zgtppt2010 .
  data:
    mt_2010_target TYPE TABLE OF zgtppt2010 .
  data:
    mt_2020 TYPE TABLE OF zgtppt2020 .
  data:
    mt_2020_lc TYPE TABLE OF zgtppt2020 .
  data MV_WERKS type WERKS_D .
  data MS_2010 type ZGTPPT2010 .
  data MS_2010_SOURCE type ZGTPPT2010 .
  data MS_2020 type ZGTPPT2020 .
  data:
    mt_2020_source TYPE TABLE OF zgtppt2020 .
  data:
    mt_2020_save TYPE TABLE OF zgtppt2020 .
  data MS_2020_SOURCE type ZGTPPT2020 .
  data MV_GRPNR type ZGTEGRPNR .
  data MV_FINDATE type SY-DATUM .
  data MV_RSNUM type RSNUM .
  data MS_BDCPARAMS type CTU_PARAMS .
  data MS_BDCDATA type BDCDATA .
  data:
    mt_bdcdata TYPE TABLE OF bdcdata .
  data:
    mt_messtab TYPE TABLE OF bdcmsgcoll .
  data:
    mt_tot_messtab TYPE TABLE OF bdcmsgcoll .
  data:
    mt_headerdata TYPE TABLE OF bapiplaf_i1 .
  data MV_TOTAL_PLORD_QTY type GSMNG .
  data:
    mt_resb TYPE TABLE OF resb .
  data:
    mt_resb_total TYPE TABLE OF resb .
  data:
    mt_resb_origin TYPE TABLE OF resb .
  data MV_TARGET_ORDER type AUFNR .
  data MT_PLAN_ORDERS type MRPDS_PLONO .
  data MT_PRD_ORDERS type TB_BAPI_ORDER_KEY .
  data:
    BEGIN OF ms_2010_cal.
        INCLUDE TYPE zgtppt2010.
    DATA : plord_qty TYPE gsmng,
        findate   TYPE sy-datum,
      END OF ms_2010_cal .
  data:
    mt_2010_cal LIKE TABLE OF ms_2010_cal .
  data MV_AUART type AUFART .
  data:
    BEGIN OF ms_auart,
        grpnr      TYPE zgtppt2010-grpnr,
        ordnr      TYPE zgtppt2010-ordnr,
        posnr      TYPE zgtppt2010-posnr,
        auart      TYPE aufk-auart,
        last_ordnr TYPE zgtppt2010-ordnr,
        last_auart TYPE aufk-auart,
      END OF ms_auart .
  data:
    mt_auart LIKE TABLE OF ms_auart .

  methods CONSTRUCTOR
    importing
      !IT_SEQ_ROUTING like MT_MAIN_SEQ_ROUTING optional
      !IV_WERKS type WERKS_D optional
      !IV_GRPNR type ZGTEGRPNR optional
      !IV_AUART type AUFART optional .
  methods PROC_MAKE_PLAN_ORDER
    importing
      !IV_ORDER type ZGTEORDNO
      !IV_POSNR type POSNR_VA
      !IV_ORDTY type ZGTEORDTY
      !IV_GONG_CD type ZEGONG_CD
      !IV_MATNR type MATNR
    exporting
      !EV_RESULT type CHAR01
      !EV_MESSAGE type CHAR100
      !EV_ORDER type ZGTEORDNO
      !EV_POSNR type POSNR_VA
      !EV_ORDTY type ZGTEORDTY
      !EV_CHK_SHE type CHAR01
      !ET_PLNUM type MRPDS_PLONO .
  methods CONFIRM .
  methods CONVERSION_PRD_ORDER
    importing
      !IT_2010 like MT_2010
    exporting
      !EV_RESULT type CHAR01
      !EV_MESSAGE type CHAR100
      !EV_CHK_CON type CHAR01 .
  methods EDIT_ADLENGTH
    importing
      !IT_2010 like MT_2010
      !IV_MATNR type MATNR
    exporting
      !EV_RESULT type CHAR01
      !EV_MESSAGE type CHAR100 .
  methods CHANGE_QLENGTH
    importing
      !IT_2010 like MT_2010
      !IV_MATNR type MATNR
    exporting
      !EV_RESULT type CHAR01
      !EV_MESSAGE type CHAR100 .
  methods DELETE_ORDER
    importing
      !IT_2010 like MT_2010
    exporting
      !EV_RESULT type CHAR01
      !ET_ERR_ORDER type BAPI_ORDER_RETURN_TT .
  methods ORDER_RELEASE
    importing
      !IT_2010 like MT_2010
    returning
      value(RT_ERR_ORDER) type BAPI_ORDER_RETURN_TT .
  methods CHANGE_BATCH
    importing
      !IT_2010 like MT_2010
      !IV_PLNFL type PLAS-PLNFL
    returning
      value(RT_ERR_ORDER) type BAPI_ORDER_RETURN_TT .
  methods PROC_PEGGING
    importing
      !IV_TARGET_ORDER type AUFNR
      !IV_TARGET_POSNR type CO_POSNR optional
      !IT_PEGGING_DATA like MT_2010
    returning
      value(RV_MESSAGE) type CHAR100 .
  methods GET_CHAIN_DATA
    importing
      !IT_DATA like MT_2010
    exporting
      !ET_PRE_DATA like MT_2010
      !ET_DEV_DATA like MT_2010
      !ET_EXCEPTION like MT_2010 .
  methods PROC_MULTY_ORDER
    importing
      !IT_2010 like MT_2010
      !IV_AUART like MV_AUART optional
      !IV_CHK_RELEASE type CHAR01 optional
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
  methods SET_CHAIN_HISTORY .
  methods PROCESS_SEPERATE
    importing
      !IT_2010 like MT_2010
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
  methods PROGRESS_INDICATOR
    importing
      !IV_PERCENT type ANY
      !IV_TEXT type ANY .
  class-methods SEND_CHG_MES
    importing
      !IV_WERKS type WERKS_D
      !IV_SPGCD type ZPPT0107-SPGCD
      !IV_GRPNR type ZGTEGRPNR .
  methods GET_METERIAL_BOM_QUAN
    importing
      !IV_DATE type SY-DATUM
      !IV_PLANT type WERKS_D
      !IV_MATNR type MARA-MATNR
      !IV_CHK_MATNR type MARA-MATNR
      !IV_EMENG type STKO-BMENG
    returning
      value(RV_MNGKO) type CS_E_MNGKO .
  methods CONFIRM_QLENGTH
    importing
      !IV_GRPNR type ZGTEGRPNR
      !IV_MATNR type MATNR
      !IV_ORDNR type ZGTPPT2010-ORDNR
      !IV_POSNR type ZGTPPT2010-POSNR
      !IV_ORDTY type ZGTPPT2010-ORDTY
    changing
      !CV_QLENGTH type ZGTEQLENGTH
      !CV_CLENGTH type ZGTECLENGTH .
  methods CHECK_PACK_SET_MENGE
    importing
      !IS_2010 type ZGTPPT2010 .
  methods GET_AUART
    importing
      !IT_2010 like MT_2010
    exporting
      !ET_AUART like MT_AUART .
protected section.
private section.

  data MV_TOTAL_PLORD_QTY02 type GSMNG .
  data:
    BEGIN OF MS_PLAF.
  INCLUDE TYPE PLAF.
  DATA : ERZET TYPE SY-UZEIT,
         END OF MS_PLAF .
  data:
    MT_PLAF LIKE TABLE OF MS_PLAF .

  methods INIT_JOJANG
    importing
      !IV_ORDER type ZGTEORDNO
      !IV_POSNR type POSNR_VA
      !IV_ORDTY type ZGTEORDTY
      !IV_GONG_CD type ZEGONG_CD .
  methods PROC_JOJANG .
  methods CALC_LC
    importing
      !IV_MATNR type MATNR
      !IV_FIXED_SCRAP_QTY type /SAPMP/FIX_AS_J
      !IV_GUBUN type CHAR05
      !IV_ADTYPE type ZGTEADTYPE optional
      !IV_ADLENGTH type ZGTEADLENGTH optional
    exporting
      !EV_RESULT type CHAR01
    changing
      !CT_HEADERDATA like MT_HEADERDATA optional .
  methods CALC_LC_MULTY
    importing
      !IV_MATNR type MATNR
      !IV_FIXED_SCRAP_QTY type /SAPMP/FIX_AS_J
      !IV_ADTYPE type ZGTEADTYPE optional
      !IV_ADLENGTH type ZGTEADLENGTH optional
      !IV_CHK_MERGE type CHAR01 optional
    exporting
      !EV_RESULT type CHAR01
      !ET_RETURN type BAPI_ORDER_RETURN_TT
    changing
      !CT_2010_DEV like MT_2010_CAL .
  methods SET_PRD_CHARICTERISTIC
    importing
      !IS_2010 type ZGTPPT2010
    exporting
      !EV_RESULT type CHAR01 .
  methods CHANGE_JOJANG
    importing
      !IS_2010_OLD type ZGTPPT2010
      !IS_2010_NEW type ZGTPPT2010 .
  methods CHANGE_PRD_ORDER
    returning
      value(RV_RESULT) type CHAR01 .
  methods CHANGE_PLN_ORDER
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PLN_ORDER
    importing
      !IV_MATNR type MATNR
    returning
      value(RV_RESULT) type CHAR01 .
  methods CHANGE_PRD_CHARICTERISTIC
    returning
      value(RV_RESULT) type CHAR01 .
  methods CHANGE_BATCH_BDC
    importing
      !IV_PLNFL type PLAS-PLNFL
    returning
      value(RV_RESULT) type CHAR01 .
  methods GET_TARGET_INFOR .
  methods DELE_PRD_ORDER
    importing
      !IV_AUFNR type AUFNR
    returning
      value(RV_RETURN) type CHAR01 .
  methods DELE_PLN_ORDER
    importing
      !IV_PLANNEDORDER type BAPI_PLDORD-PLDORD_NUM
    returning
      value(RV_RETURN) type CHAR01 .
  methods CREATE_PRD_ORDER
    importing
      !IV_AUFNR type AUFNR
      !IV_MATNR type MATNR
      !IT_2010 like MT_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods SET_DEV_RESB_ON_MERGE
    importing
      !IS_ORIGN type ZGTPPT2010
      !IS_DEV type ZGTPPT2010 .
  methods ROLLBACK_CREATED_ORDER
    importing
      !IT_2010 like MT_2010 .
  methods GET_CHAIN
    importing
      !IV_GRPNR type ZGTEGRPNR
    returning
      value(RT_RETURN) like MT_2010 .
ENDCLASS.



CLASS ZGTPP_CL_ROUTING IMPLEMENTATION.


  METHOD calc_lc.

    DATA : lv_plnum TYPE plnum.
    DATA : lv_aufnr TYPE aufnr.
    DATA : lt_headerdata TYPE TABLE OF bapiplaf_i1.
    DATA : lv_offcut  TYPE bapi_pldordcomp_e1-entry_qty.
    DATA : lv_num_jojang_line TYPE i.
    DATA : lv_inlength TYPE zgtppt2010-inlength. " 총 소요량 계산을 위한 여장
    DATA : ls_2020_source LIKE ms_2020_source.
    DATA : ls_2020_chk LIKE ms_2020_source.
    DATA : ls_2020_chk2 LIKE ms_2020_source.

*    총소요량 계산
* 공정정보 조회
    SELECT a~matnr,
           c~idnrk,
           c~/sapmp/met_lrch,  " 길이 계산 방법
           c~/sapmp/max_fertl,  " 최대생산 길이
           c~/sapmp/fix_as_j,       " 각길이
           c~/sapmp/fix_as_e,       " 첫번째 길이
           c~/sapmp/fix_as_l,        "최종길이
           c~/sapmp/rund_fakt      " 반올림 값
      FROM mast AS a  INNER JOIN stko AS b  ON  b~stlnr = a~stlnr
                                            AND b~stlal = a~stlal
                      INNER JOIN stpo AS c  ON  c~stlnr = b~stlnr
                                            AND c~stlty = b~stlty
     WHERE a~matnr IN ( SELECT itab~matnr
                          FROM @mt_main_seq_routing AS itab
                         WHERE seqno < @ms_main_seq_routing-seqno )
       AND a~werks  = @mv_werks
       AND a~stlan = '1'
       AND a~stlal  = '01'
       AND b~stlty  = 'M'
       AND b~lkenz NE 'X'
       AND c~lkenz NE 'X'
       AND c~idnrk      = @iv_matnr
       INTO TABLE @DATA(lt_calcultab).

    IF sy-subrc NE 0. " 연결된 조장 정보가 없으므로 이전공정들 처리 안함
      ev_result = 'F'.
      RETURN.
    ENDIF.

    CLEAR ls_2020_source.
    READ TABLE lt_calcultab INTO DATA(ls_temp) INDEX 1.

    MOVE-CORRESPONDING ms_2020_source TO ls_2020_chk2.
    DO.
      IF ls_2020_chk2-matnr = ls_temp-matnr.
        MOVE-CORRESPONDING ls_2020_chk2 TO ls_2020_source.
        EXIT.
      ELSE.
        MOVE-CORRESPONDING ls_2020_chk2 TO ls_2020_chk.
        READ TABLE mt_2020 INTO ls_2020_chk2 WITH KEY grpnr = mv_grpnr
                                                      ordnr = ls_2020_chk-dmord
                                                      posnr = ls_2020_chk-dmline
                                                      ordty = ls_2020_chk-dmordty.
        IF sy-subrc NE 0.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF ls_2020_chk2
            FROM zgtppt2010
           WHERE grpnr = mv_grpnr
             AND ordnr = ls_2020_chk-dmord
             AND posnr = ls_2020_chk-dmline
             AND ordty = ls_2020_chk-dmordty.
          IF sy-subrc NE 0.
            ev_result = 'E'.
            RETURN.
          ENDIF. .
        ENDIF.
      ENDIF.
    ENDDO.

    CASE iv_gubun.
      WHEN 'PLN'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_2020_source-ordnr
          IMPORTING
            output = lv_plnum.

        CLEAR : mv_findate, mv_rsnum.  " 후행 공정 시작일

        SELECT SINGLE
          FROM plaf
          FIELDS psttr, rsnum, prsch
         WHERE plnum = @lv_plnum
           INTO ( @mv_findate, @mv_rsnum, @DATA(lv_prsch) ).

        mv_findate = mv_findate - 1.

      WHEN 'PRD'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_2020_source-ordnr
          IMPORTING
            output = lv_aufnr.

        CLEAR : mv_findate, mv_rsnum. " 후행 공정 시작일

        SELECT SINGLE
          FROM afko
          FIELDS gstrp, rsnum
         WHERE aufnr = @lv_aufnr
            INTO ( @mv_findate, @mv_rsnum ).

        mv_findate = mv_findate - 1.
    ENDCASE.

*   이후 공정의 예약 자재 확인후 LC계산
*  - 예약 자재의 갯수로 현재 공정의 조장수 계산
    DATA : BEGIN OF ls_resb,
             rsnum TYPE resb-rsnum,
             rspos TYPE resb-rspos,
             rsart TYPE resb-rsart,
             matnr TYPE resb-matnr,
             bdmng TYPE resb-bdmng,
           END OF ls_resb.
    DATA : lt_resb LIKE TABLE OF ls_resb.

    SELECT rsnum, rspos, rsart, matnr, bdmng
      FROM resb
     WHERE rsnum = @mv_rsnum
        AND matnr = @iv_matnr
        INTO CORRESPONDING FIELDS OF TABLE @lt_resb.

*  조장수( 이후 공정 조정수 * 현공정 원자재수량)
    DATA(lv_num_jojang) = lines( lt_resb ).
    IF lv_num_jojang NE 0.
      ms_2020-infactor = lv_num_jojang + 0.
    ELSE.
      lv_num_jojang = 1.
    ENDIF.

*  이후 공정의 각길이 검사여장 포함 하여 현재 조장수 계산
**  검사여장
    READ TABLE lt_calcultab INTO DATA(ls_calcultab) WITH KEY idnrk = iv_matnr.

    ms_2020-qlength = iv_fixed_scrap_qty.
    ms_2020-adlength = iv_adlength .
    lv_inlength = ls_2020_source-inlength + ls_2020_source-qlength + ls_2020_source-adlength +
                         ls_2020_source-clength + ls_2020_source-slength + ls_2020_source-elength.
    lv_inlength = get_meterial_bom_quan(
                      iv_date      =  mv_findate              " ABAP system field: Current date of application server
                      iv_plant     =  mv_werks                " 플랜트
                      iv_matnr     = ls_calcultab-matnr       " 자재 번호
                      iv_chk_matnr = iv_matnr                 " 자재 번호
                      iv_emeng     = lv_inlength ).           " 기준 수량

    ms_2020-inlength = lv_inlength.

*  각길이, 첫길이, 마지막길이 존재 시 기본조장
    ms_2020-clength = ls_calcultab-/sapmp/fix_as_j.
    ms_2020-slength = ls_calcultab-/sapmp/fix_as_e.
    ms_2020-elength = ls_calcultab-/sapmp/fix_as_l.

    confirm_qlength(
      EXPORTING
        iv_grpnr   = mv_grpnr                  " 조장 구성표 번호
        iv_matnr   = iv_matnr                 " 자재 번호
        iv_ordnr   = ls_2020_source-ordnr                 " 오더번호
        iv_posnr   = ls_2020_source-posnr                 " 판매 문서 항목
        iv_ordty   = ls_2020_source-ordty                 " 오더유형
      CHANGING
        cv_qlength =  ms_2020-qlength                " 검사여장
        cv_clength =  ms_2020-clength                 " 연결여장
    ).

* 총 작업 수량

    REFRESH mt_2020_lc.
* 조장수가 1 이상일 경우 이후 공정의 소요수량 재계산을 위한
    READ TABLE ct_headerdata ASSIGNING FIELD-SYMBOL(<ls_headerdata>) INDEX 1.
    IF ls_2020_source-infactor = 1.
* 조장(총소요량)
      mv_total_plord_qty = lv_inlength + ms_2020-qlength + ms_2020-adlength  + ms_2020-clength + ms_2020-slength + ms_2020-elength.
      <ls_headerdata>-total_plord_qty =  mv_total_plord_qty  * lv_num_jojang.
* 계산된 종료일
      <ls_headerdata>-order_fin_date = mv_findate.
      APPEND ms_2020 TO mt_2020_lc.

    ELSEIF ls_2020_source-infactor > 1. " 후공정 조정수가 1이상일시 LC계산

      READ TABLE lt_calcultab INTO ls_calcultab WITH KEY idnrk = iv_matnr.
      IF sy-subrc EQ  0.
        CASE ls_calcultab-/sapmp/met_lrch.
          WHEN space. " 길이 전달 방법 - 오더 생산량: 조장 * 조장 수
* 조장(총소요량)
            mv_total_plord_qty = lv_inlength * ls_2020_source-infactor.
            mv_total_plord_qty  = mv_total_plord_qty + ms_2020-qlength + ms_2020-adlength  + ms_2020-clength + ms_2020-slength + ms_2020-elength.
            <ls_headerdata>-total_plord_qty =  mv_total_plord_qty  * lv_num_jojang.
* 계산된 종료일
            <ls_headerdata>-order_fin_date = mv_findate.

            ms_2020-infactor = lv_num_jojang.
            APPEND ms_2020 TO mt_2020_lc.

          WHEN '1'.       " 전체 릴 계산 방법 -
*            조장수가 1인 경우 조장 수 계산하지 않음, 계산조장수는 조장수를 넘을 수 없음
*                 검사포함: 조장 + 검사여장
*                 오더 소요량1 = 첫번째길이 + (검사포함 * 계산조장수) + 각길이 > 최대생산길이
*                 계산조장수 : 최대생산길이를 넘기는 첫번째 조장 수, Loop?
*                 잔여조장수 = 조장수 - 계산조장수
*                 Offcut = 소요량1 - 최대생산길이
*                 오더 소요량2 = (검사포함 * 잔여조장수) + 각길이 + Offcut
            CLEAR lv_num_jojang_line.
            READ TABLE ct_headerdata INTO DATA(ls_headerdata) INDEX 1.
            ls_headerdata-order_fin_date = mv_findate.
            DO .
              ADD 1 TO lv_num_jojang_line.
              IF sy-index = 1.
*                초기 길이 계산식구성 ( 첫길이 + 각길이 )
                ls_headerdata-total_plord_qty = ms_2020-slength + ms_2020-clength.
              ENDIF.

*                 조장별 소요량 계산식 ( 현재 길이 + 조장 )
              ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty +  lv_inlength .
              IF ls_headerdata-total_plord_qty > ls_calcultab-/sapmp/max_fertl. " 최대생산량 보다 클시

                IF sy-index = ls_2020_source-infactor. " 최대 조장수 일경우 계산식 반영( 한조장 제외후 offcut 없이  다른 오더 추가)
                  ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty - lv_inlength.
                  mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                  ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-clength - ms_2020-adlength.
                  ms_2020-infactor = lv_num_jojang.

                  APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                  ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                  APPEND ls_headerdata TO lt_headerdata.

*              최종 1개 조장 어팬드 후 종료
                  ls_headerdata-total_plord_qty = ms_2020-elength + lv_inlength + ms_2020-clength.
                  mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                  CLEAR ms_2020-adlength.
                  ms_2020-inlength = lv_inlength.
                  ms_2020-infactor = lv_num_jojang.
                  APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                  ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                  APPEND ls_headerdata TO lt_headerdata.
                  EXIT.
                ELSE.
                  CLEAR lv_offcut.
                  lv_offcut = ls_headerdata-total_plord_qty - ls_calcultab-/sapmp/max_fertl.
*               최대생량량 넘어갈시 (소요량 = 최대길이)
                  ls_headerdata-total_plord_qty = ls_calcultab-/sapmp/max_fertl.
                  mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                  IF mt_2020_lc[] IS INITIAL.
                    ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-adlength - ms_2020-clength.
                  ELSE.
                    ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-clength.
                    CLEAR ms_2020-adlength.
                  ENDIF.
                  ms_2020-infactor = lv_num_jojang.
                  CLEAR lv_num_jojang_line.
                  APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                  ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                  APPEND ls_headerdata TO lt_headerdata.

*              최대생량량 넘어갈시 길이 초기화  및 offcut + 각길이 추가
                  ls_headerdata-total_plord_qty = lv_offcut + ms_2020-clength.
                ENDIF.
              ENDIF.

              IF sy-index = ls_2020_source-infactor.
                ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty + ms_2020-elength.
                mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                IF mt_2020_lc[] IS INITIAL.
                  ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-adlength - ms_2020-clength.
                ELSE.
                  ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-clength.
                  CLEAR ms_2020-adlength.
                ENDIF.
                ms_2020-infactor = lv_num_jojang.
                CLEAR lv_num_jojang_line.
                APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                APPEND ls_headerdata TO lt_headerdata.

                EXIT.
              ENDIF.

            ENDDO.

            IF lt_headerdata[] IS NOT INITIAL.
              ct_headerdata = lt_headerdata.
            ENDIF.

          WHEN '2'.        " 길이 집계 계산 방법
*            검사포함: 조장 + 검사여장
*            조장수가 1인 경우 조장 수 계산하지 않음, 계산조장 수는 조장수를 넘을 수 없음
*            오더 소요량1 = (검사포함 * 계산조장수) + 각길이 < 최대생산길이
*            잔여조장수 = 조장수 - 계산조장수
*            오더 소요량2 = (검사포함 * 잔여조장수) + 각길이 < 최대생산길이
            CLEAR lv_num_jojang_line.
            READ TABLE ct_headerdata INTO ls_headerdata INDEX 1.
            ls_headerdata-order_fin_date = mv_findate.
            DO .
              ADD 1 TO lv_num_jojang_line.
              IF sy-index = 1.
*                초기 길이 계산식구성 ( 각길이 )
                ls_headerdata-total_plord_qty = ms_2020-clength.
              ENDIF.

*            조장별 소요량 계산식 ( 현재 길이 + 조장 )
              ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty + lv_inlength.

              IF ls_headerdata-total_plord_qty > ls_calcultab-/sapmp/max_fertl. " 최대생산량 보다 클시

                IF lv_num_jojang_line = 1.
                ELSE.
                  ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty - lv_inlength.
                ENDIF.
                mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-adlength  - ms_2020-clength.
                ms_2020-infactor = lv_num_jojang.
                APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                APPEND ls_headerdata TO lt_headerdata.


*              한개조장 계산식 생성후
                ls_headerdata-total_plord_qty = ms_2020-clength + lv_inlength.
                lv_num_jojang_line = 1.
              ENDIF.

              IF sy-index = ls_2020_source-infactor.
                mv_total_plord_qty =  mv_total_plord_qty + ls_headerdata-total_plord_qty.

                IF mt_2020_lc IS  INITIAL.
                  ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-clength - ms_2020-adlength.
                ELSE.
                  ms_2020-inlength = ls_headerdata-total_plord_qty - ms_2020-qlength - ms_2020-clength.
                  CLEAR ms_2020-adlength.
                ENDIF.
                ms_2020-infactor = lv_num_jojang.
                APPEND ms_2020 TO mt_2020_lc.

*                LC 계산후 현재 조장수 곱해준다
                ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty * lv_num_jojang.
                APPEND ls_headerdata TO lt_headerdata.

                EXIT.
              ENDIF.

            ENDDO.

            IF lt_headerdata[] IS NOT INITIAL.
              ct_headerdata = lt_headerdata.
            ENDIF.

        ENDCASE.
      ENDIF.
    ENDIF.

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
    DATA : lv_chk_qmat.
    DATA : lv_excluding_length TYPE gsmng.

*  검사 여장 존재시 품질 테이블 적합성 검사
    IF ms_2020-qlength > 0.
      lv_chk_qmat = abap_true.
    ENDIF.
*  추가여장유형 A(추가시료여장) , 추가여장 존재시 품질 테이블 적합성 검사
    IF iv_adtype = 'A' AND iv_adlength NE 0.
      lv_chk_qmat = abap_true.
    ENDIF.

* 품질 검사 적합성 체크후 제외 길이 반영
    CLEAR lv_excluding_length.
    lv_excluding_length = mv_total_plord_qty.
    IF lv_chk_qmat = abap_true.
      SELECT SINGLE matnr FROM qmat
        INTO @DATA(lv_chk_matnr)
       WHERE matnr = @iv_matnr
         AND werks = @mv_werks
         AND art = '04'
         AND aktiv = 'X'.
      IF sy-subrc EQ 0.
        lv_excluding_length = lv_excluding_length - ms_2020-qlength.
        IF iv_adtype = 'A'.
          lv_excluding_length = lv_excluding_length - iv_adlength.
        ENDIF.
      ENDIF.
    ENDIF.


* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
    SELECT a~*
      FROM resb AS a  INNER JOIN mara AS b  ON  b~matnr = a~matnr
                      INNER JOIN marc AS c  ON  c~matnr = a~matnr
      INTO CORRESPONDING FIELDS OF TABLE @mt_resb
     WHERE b~mtart = 'MCHF'
       AND c~werks = @mv_werks
       AND c~beskz = 'E'
       AND a~rsnum = @mv_rsnum.

    mt_resb_origin = mt_resb.

    LOOP AT mt_resb ASSIGNING FIELD-SYMBOL(<ls_resb>).

*      <LS_RESB>-BDMNG = MV_TOTAL_PLORD_QTY + 0.
      <ls_resb>-bdmng = lv_excluding_length + 0.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = <ls_resb>-matnr    " <-- 해당 자재코드
          i_in_me              = <ls_resb>-meins  "<-- 현 수량의 단위
          i_out_me             = <ls_resb>-erfme " <-- 변경되어질 수량의 단위
          i_menge              = lv_excluding_length " <-- 현 수량 변수
*         I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
        IMPORTING
          e_menge              = <ls_resb>-erfmg " <-- 변경되어질 수량변수
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

    ENDLOOP.

    mv_total_plord_qty = mv_total_plord_qty * lv_num_jojang.

  ENDMETHOD.


  METHOD CALC_LC_MULTY.

    DATA : LT_AUFNR TYPE RANGE_T_AUFNR.
    DATA : LS_AUFNR LIKE LINE OF LT_AUFNR.
    DATA : LT_PLNUM TYPE RANGE_T_PLNUM.
    DATA : LS_PLNUM LIKE LINE OF LT_PLNUM.
    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_OFFCUT  TYPE BAPI_PLDORDCOMP_E1-ENTRY_QTY.
    DATA : LV_NUM_JOJANG_LINE TYPE I.
    DATA : LV_INLENGTH TYPE ZGTPPT2010-INLENGTH. " 총 소요량 계산을 위한 여장
    DATA : LV_LENGTH TYPE I.
    DATA : LV_LENGTH_C(11) TYPE C.

    REFRESH MT_2020_LC.

*   이후 공정의 예약 자재 확인후 LC계산
*  - 예약 자재의 갯수로 현재 공정의 조장수 계산
    DATA : BEGIN OF LS_RESB,
             RSNUM TYPE RESB-RSNUM,
             RSPOS TYPE RESB-RSPOS,
             RSART TYPE RESB-RSART,
             MATNR TYPE RESB-MATNR,
             BDMNG TYPE RESB-BDMNG,
           END OF LS_RESB.
    DATA : LT_RESB LIKE TABLE OF LS_RESB.

    REFRESH MT_RESB.

*    총소요량 계산
* 공정정보 조회
    SELECT  A~MATNR,
           C~IDNRK,
           C~/SAPMP/MET_LRCH,  " 길이 계산 방법
           C~/SAPMP/MAX_FERTL,  " 최대생산 길이
           C~/SAPMP/FIX_AS_J,       " 각길이
           C~/SAPMP/FIX_AS_E,       " 첫번째 길이
           C~/SAPMP/FIX_AS_L,        "최종길이
           C~/SAPMP/RUND_FAKT      " 반올림 값
             FROM MAST AS A
             INNER JOIN STKO AS B
                                  ON B~STLNR = A~STLNR
                                 AND B~STLAL = A~STLAL
             INNER JOIN STPO AS C
                                  ON C~STLNR = B~STLNR
                                 AND C~STLTY = B~STLTY
            WHERE A~MATNR IN ( SELECT ITAB~MATNR
                                            FROM @MT_MAIN_SEQ_ROUTING AS ITAB
                                          WHERE SEQNO < @MS_MAIN_SEQ_ROUTING-SEQNO )
                AND A~WERKS  = @MV_WERKS
                AND A~STLAN = '1'
                AND A~STLAL  = '01'
                AND B~STLTY  = 'M'
                AND B~LKENZ NE 'X'
                AND C~LKENZ NE 'X'
                AND C~IDNRK      = @IV_MATNR
             INTO TABLE @DATA(LT_CALCULTAB).

    IF SY-SUBRC NE 0.
      EV_RESULT = 'F'.
      RETURN.
    ENDIF.

* 복조장의 경우 품목이 여러개
    LOOP AT CT_2010_DEV INTO DATA(LS_2010_DEV).
      CASE LS_2010_DEV-ORDTY.
        WHEN 'PRD'.
          CLEAR LS_AUFNR.
          LS_AUFNR-SIGN = 'I'.
          LS_AUFNR-OPTION = 'EQ'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LS_2010_DEV-ORDNR
            IMPORTING
              OUTPUT = LS_AUFNR-LOW.
          COLLECT LS_AUFNR INTO LT_AUFNR.
        WHEN 'PLN'.
          CLEAR LS_PLNUM.
          LS_PLNUM-SIGN = 'I'.
          LS_PLNUM-OPTION = 'EQ'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LS_2010_DEV-ORDNR
            IMPORTING
              OUTPUT = LS_PLNUM-LOW.
          COLLECT LS_PLNUM INTO LT_PLNUM.
      ENDCASE.
    ENDLOOP.

    IF LT_AUFNR[] IS NOT INITIAL.
      SELECT AUFNR AS ORDNR, RSNUM, MIN( GSTRP ) AS GSTRP FROM AFKO
       WHERE AUFNR IN @LT_AUFNR
        GROUP BY AUFNR, RSNUM
        INTO TABLE @DATA(LT_ORDER).
    ENDIF.

    IF LT_PLNUM[] IS NOT INITIAL.
      SELECT PLNUM AS ORDNR, RSNUM, MIN( PSTTR ) AS GSTRP
        FROM PLAF
       WHERE PLNUM IN @LT_PLNUM
         GROUP BY PLNUM, RSNUM
        APPENDING CORRESPONDING FIELDS OF TABLE @LT_ORDER.
    ENDIF.

* 총 작업 수량
    REFRESH MT_2010_CAL.
    READ TABLE LT_CALCULTAB INTO DATA(LS_CALCULTAB) WITH KEY IDNRK = IV_MATNR.
    CLEAR MS_2010_CAL.

* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
    SORT LT_ORDER BY RSNUM.
    DELETE ADJACENT DUPLICATES FROM LT_ORDER COMPARING RSNUM.
    IF LT_ORDER[] IS NOT INITIAL.
      SELECT B~*
        FROM @LT_ORDER AS A
        INNER JOIN RESB AS B
                               ON B~RSNUM = A~RSNUM
        WHERE B~MATNR = @IV_MATNR
        INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
    ENDIF.

    MS_2010_CAL-QLENGTH = IV_FIXED_SCRAP_QTY.
    MS_2010_CAL-CLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_J.

    LOOP AT CT_2010_DEV INTO LS_2010_DEV.

* 계산 첫길이
      IF SY-TABIX = 1.
        CONFIRM_QLENGTH(
          EXPORTING
            IV_GRPNR   = MV_GRPNR                  " 조장 구성표 번호
            IV_MATNR   = IV_MATNR                 " 자재 번호
            IV_ORDNR   = LS_2010_DEV-ORDNR                 " 오더번호
            IV_POSNR   = LS_2010_DEV-POSNR                 " 판매 문서 항목
            IV_ORDTY   = LS_2010_DEV-ORDTY                 " 오더유형
          CHANGING
            CV_QLENGTH =  MS_2010_CAL-QLENGTH                " 검사여장
            CV_CLENGTH =  MS_2010_CAL-CLENGTH ).                " 연결여장

* 조장(총소요량)
*  각길이, 첫길이, 마지막길이 존재 시 기본조장 " 최초 길이 세팅
        CASE LS_CALCULTAB-/SAPMP/MET_LRCH.
          WHEN SPACE.
            MS_2010_CAL-PLORD_QTY = MS_2010_CAL-CLENGTH  + MS_2010_CAL-QLENGTH.
          WHEN '1'.
            MS_2010_CAL-PLORD_QTY = LS_CALCULTAB-/SAPMP/FIX_AS_E + MS_2010_CAL-CLENGTH + LS_CALCULTAB-/SAPMP/FIX_AS_L  + MS_2010_CAL-QLENGTH.
            MS_2010_CAL-SLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_E.
            MS_2010_CAL-ELENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_L.
          WHEN '2'.
            MS_2010_CAL-PLORD_QTY = MS_2010_CAL-CLENGTH + MS_2010_CAL-QLENGTH.
            MS_2010_CAL-CLENGTH = MS_2010_CAL-CLENGTH.
        ENDCASE.

        READ TABLE LT_ORDER INTO DATA(LS_ORDER) WITH KEY ORDNR = LS_2010_DEV-ORDNR.
      ENDIF.

* 이후공정 총길이
      CLEAR LV_INLENGTH.
      LV_INLENGTH = LS_2010_DEV-INLENGTH + LS_2010_DEV-QLENGTH + LS_2010_DEV-ADLENGTH +
                           LS_2010_DEV-CLENGTH + LS_2010_DEV-SLENGTH + LS_2010_DEV-ELENGTH.

      MS_2010_CAL-INLENGTH = MS_2010_CAL-INLENGTH + (  LV_INLENGTH * LS_2010_DEV-INFACTOR ).

    ENDLOOP.

    MS_2010_CAL-INLENGTH = GET_METERIAL_BOM_QUAN(
                                          IV_DATE      =  LS_ORDER-GSTRP                " ABAP system field: Current date of application server
                                          IV_PLANT     =  MV_WERKS                " 플랜트
                                          IV_MATNR     = LS_CALCULTAB-MATNR                 " 자재 번호
                                          IV_CHK_MATNR = IV_MATNR                 " 자재 번호
                                          IV_EMENG     = MS_2010_CAL-INLENGTH ).                 " 기준 수량

* 조장(총소요량)
    MS_2010_CAL-PLORD_QTY = MS_2010_CAL-PLORD_QTY + MS_2010_CAL-INLENGTH + IV_ADLENGTH.

    IF IV_CHK_MERGE IS INITIAL.
      IF LS_CALCULTAB-/SAPMP/MAX_FERTL NE 0.
        IF MS_2010_CAL-PLORD_QTY > LS_CALCULTAB-/SAPMP/MAX_FERTL.
          READ TABLE MT_MAIN_SEQ_ROUTING INTO MS_MAIN_SEQ_ROUTING WITH KEY MATNR = IV_MATNR.
          LV_LENGTH = LS_CALCULTAB-/SAPMP/MAX_FERTL.
          LV_LENGTH_C = LV_LENGTH.
          CONDENSE LV_LENGTH_C.

          APPEND INITIAL LINE TO ET_RETURN ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
          CONCATENATE MS_MAIN_SEQ_ROUTING-CHART_VAL '공정의 최대 생산 길이를 초과하였습니다. (최대 생산 길이:'  LV_LENGTH_C 'M)'
                        INTO <LS_RESULT>-MESSAGE.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

*  조장수( 이후 공정 조정수 * 현공정 원자재수량)
    IF LINES( LT_ORDER ) NE 0.
      DATA(LV_NUM_JOJANG) = LINES( LT_RESB ) / LINES( LT_ORDER ) .
      IF LV_NUM_JOJANG = 0.
        LV_NUM_JOJANG = 1.
      ENDIF.
    ELSE.
      LV_NUM_JOJANG = 1.
    ENDIF.

    MS_2010_CAL-INFACTOR = LV_NUM_JOJANG + 0.
** 조장(총소요량)
*    MS_2010_CAL-PLORD_QTY = MS_2010_CAL-PLORD_QTY + MS_2010_CAL-QLENGTH + MS_2010_CAL-CLENGTH +
*                                            MS_2010_CAL-SLENGTH + MS_2010_CAL-ELENGTH.
* 작업 시작일
    MS_2010_CAL-FINDATE = LS_ORDER-GSTRP - 1.
    MV_FINDATE = LS_ORDER-GSTRP - 1.

    READ TABLE MT_MAIN_SEQ_ROUTING INTO DATA(LS_ROUTING) WITH KEY MATNR = IV_MATNR.
    IF LS_ROUTING-CHART = 'SHE' AND LV_NUM_JOJANG > 1.
      MV_TOTAL_PLORD_QTY = MS_2010_CAL-PLORD_QTY.
    ELSE.
      MS_2010_CAL-PLORD_QTY = MS_2010_CAL-PLORD_QTY * LV_NUM_JOJANG.
      MV_TOTAL_PLORD_QTY = MS_2010_CAL-PLORD_QTY.
    ENDIF.


* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
    DATA : LV_CHK_QMAT.
    DATA : LV_EXCLUDING_LENGTH TYPE GSMNG.

*  검사 여장 존재시 품질 테이블 적합성 검사
    IF MS_2010_CAL-QLENGTH > 0.
      LV_CHK_QMAT = ABAP_TRUE.
    ENDIF.
*  추가여장유형 A(추가시료여장) , 추가여장 존재시 품질 테이블 적합성 검사
    IF IV_ADTYPE = 'A' AND IV_ADLENGTH NE 0.
      LV_CHK_QMAT = ABAP_TRUE.
    ENDIF.

* 품질 검사 적합성 체크후 제외 길이 반영
    CLEAR LV_EXCLUDING_LENGTH.
    LV_EXCLUDING_LENGTH = MV_TOTAL_PLORD_QTY.
    IF LV_CHK_QMAT = ABAP_TRUE.
      SELECT SINGLE MATNR FROM QMAT
        INTO @DATA(LV_CHK_MATNR)
       WHERE MATNR = @IV_MATNR
         AND WERKS = @MV_WERKS
         AND ART = '04'
         AND AKTIV = 'X'.
      IF SY-SUBRC EQ 0.
        LV_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH - MS_2010_CAL-QLENGTH.
        IF IV_ADTYPE = 'A'.
          LV_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH - IV_ADLENGTH.
        ENDIF.
      ENDIF.
    ENDIF.



* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
    SELECT B~*
      FROM @LT_ORDER AS A
      INNER JOIN RESB AS B
                             ON B~RSNUM = A~RSNUM
      INNER JOIN MARA AS C
                             ON C~MATNR = B~MATNR
      INNER JOIN MARC AS D
                           ON D~MATNR = C~MATNR
      WHERE C~MTART = 'MCHF'
          AND D~WERKS = @MV_WERKS
          AND D~BESKZ = 'E'
      INTO CORRESPONDING FIELDS OF TABLE @MT_RESB.


    LOOP AT MT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

*      <LS_RESB>-BDMNG = MV_TOTAL_PLORD_QTY + 0.
      <LS_RESB>-BDMNG = LV_EXCLUDING_LENGTH + 0.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
          I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
          I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
          I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*         I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
        IMPORTING
          E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.
    ENDLOOP.


  ENDMETHOD.


  METHOD CHANGE_BATCH.

    DATA : LV_CHK_ERR TYPE CHAR01.

    LOOP AT IT_2010 INTO MS_2010.
      CLEAR LV_CHK_ERR.
      LV_CHK_ERR = CHANGE_BATCH_BDC( IV_PLNFL = IV_PLNFL ).
      IF LV_CHK_ERR EQ 'E'.
        APPEND INITIAL LINE TO RT_ERR_ORDER ASSIGNING FIELD-SYMBOL(<LS_ERR_ORDER>).
        <LS_ERR_ORDER>-ORDER_NUMBER = MS_2010-ORDNR.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD CHANGE_BATCH_BDC.

    DATA : LV_PLNFL(6).

    REFRESH : MT_BDCDATA, MT_MESSTAB.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = IV_PLNFL
      IMPORTING
        OUTPUT = LV_PLNFL.

    CONDENSE LV_PLNFL.

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPLCOKO1' '0110'.
    __BDC_FIELD : 'CAUFVD-AUFNR' MS_2010-ORDNR,
                        'R62CLORD-FLG_OVIEW'  'X',
                        'BDC_OKCODE' '=FLGU'.

    __BDC_DYNPRO 'SAPLCOVG' '0200'.
    __BDC_FIELD : 'BDC_OKCODE' '=SEQC'. " 빠른입력화면으로 전환

    __BDC_DYNPRO 'SAPLCOKO1' '0630'.
    __BDC_FIELD :  'BDC_OKCODE' '=POSI'.

    __BDC_DYNPRO 'SAPLSPO4' '0300'.
    __BDC_FIELD :  'SVALD-VALUE(01)' LV_PLNFL,
                         'BDC_OKCODE' '=FURT'.

    __BDC_DYNPRO 'SAPLCOKO1' '0630'.
    __BDC_FIELD :  'BDC_OKCODE' '=ENT1'.


    __BDC_DYNPRO 'SAPLCOVG' '0200'.
    __BDC_FIELD : 'BDC_OKCODE' '=BU'.

    __BDC_TRANSACTION 'CO02'.
    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                           OR MSGTYP = 'E'
                                                           OR MSGTYP = 'X'.
      APPEND LS_MESSTAB TO MT_TOT_MESSTAB.
      RV_RESULT = 'E'.
      RETURN.
    ENDLOOP.

    RV_RESULT = 'S'.

  ENDMETHOD.


  METHOD CHANGE_JOJANG.

    DATA : LT_2010_SAVE TYPE TABLE OF ZGTPPT2010.
    DATA : LT_ZPPTC002 TYPE TABLE OF ZPPTC002.

* 변경 완료된 기존 CHAIN 구성 삭제
    DELETE FROM ZGTPPT2010
    WHERE GRPNR = IS_2010_OLD-GRPNR
       AND GONG_CD = IS_2010_OLD-GONG_CD
       AND ORDNR = IS_2010_OLD-ORDNR
       AND POSNR = IS_2010_OLD-POSNR
       AND ORDTY = IS_2010_OLD-ORDTY.
    COMMIT WORK AND WAIT.

    REFRESH LT_2010_SAVE.
    APPEND IS_2010_NEW TO LT_2010_SAVE.

*    오더 검사여장 시료여장 업데이트
    IF IS_2010_NEW-ORDTY = 'PRD'.
      APPEND INITIAL LINE TO LT_ZPPTC002 ASSIGNING FIELD-SYMBOL(<LS_SAVE_DATA>).
      <LS_SAVE_DATA>-AUFNR = IS_2010_NEW-ORDNR.
      <LS_SAVE_DATA>-POSNR = IS_2010_NEW-POSNR+2(4).
      <LS_SAVE_DATA>-PSAMG = IS_2010_NEW-QLENGTH.
      IF IS_2010_NEW-ADTYPE = 'A'.
        <LS_SAVE_DATA>-PSMNG = IS_2010_NEW-ADLENGTH.
      ENDIF.
    ENDIF.

    IF LT_ZPPTC002[] IS NOT INITIAL.
      MODIFY ZPPTC002 FROM TABLE LT_ZPPTC002.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.


    SELECT *
      FROM ZGTPPT2010
      INTO TABLE @DATA(LT_DEV)
     WHERE GRPNR = @IS_2010_OLD-GRPNR
         AND REORD = @IS_2010_OLD-ORDNR
         AND RELINE = @IS_2010_OLD-POSNR
         AND REORDTY = @IS_2010_OLD-ORDTY.

    IF LT_DEV[] IS NOT INITIAL.
      DELETE ZGTPPT2010 FROM  TABLE LT_DEV. " 새로 구성을 위해 읽은 라인 삭제
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

*  이후 공정 체인 변경
    LOOP AT LT_DEV INTO DATA(LS_DEV).
      LS_DEV-REORD = IS_2010_NEW-ORDNR.
      LS_DEV-RELINE = IS_2010_NEW-POSNR.
      LS_DEV-REORDTY = IS_2010_NEW-ORDTY.
      APPEND LS_DEV TO LT_2010_SAVE.
    ENDLOOP.


    SELECT *
      FROM ZGTPPT2010
      INTO TABLE @DATA(LT_PRE)
     WHERE GRPNR = @IS_2010_OLD-GRPNR
         AND DMORD = @IS_2010_OLD-ORDNR
         AND DMLINE = @IS_2010_OLD-POSNR
         AND DMORDTY = @IS_2010_OLD-ORDTY.

    IF LT_PRE[] IS NOT INITIAL.
      DELETE ZGTPPT2010 FROM  TABLE LT_PRE. " 새로 구성을 위해 읽은 라인 삭제
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

*  이전 공정 체인 변경
    LOOP AT LT_PRE INTO DATA(LS_PRE).
      LS_PRE-DMORD = IS_2010_NEW-ORDNR.
      LS_PRE-DMLINE = IS_2010_NEW-POSNR.
      LS_PRE-DMORDTY = IS_2010_NEW-ORDTY.
      APPEND LS_PRE TO LT_2010_SAVE.
    ENDLOOP.

    IF LT_2010_SAVE IS NOT INITIAL.
      MODIFY ZGTPPT2010 FROM TABLE LT_2010_SAVE.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

*   판매오더에 연결된 생산오더 - 포장재 확인후 속성값 세팅
    IF IS_2010_NEW-DMORDTY = 'SO'.
      CHECK_PACK_SET_MENGE( IS_2010 = IS_2010_NEW ).
    ENDIF.


  ENDMETHOD.


  METHOD CHANGE_PLN_ORDER.

    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.
    DATA : LS_HEADER TYPE BAPIPLAF_I2.
    DATA : LS_HEADERX TYPE BAPIPLAF_I2X.

    LS_HEADER-TOTAL_PLORD_QTY = MV_TOTAL_PLORD_QTY02.
    LS_HEADERX-TOTAL_PLORD_QTY = 'X'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = MS_2010-ORDNR
      IMPORTING
        OUTPUT = LV_PLANNEDORDER.

    CLEAR LS_RETURN.

    CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
      EXPORTING
        PLANNEDORDER = LV_PLANNEDORDER
        HEADERDATA   = LS_HEADER
        HEADERDATAX  = LS_HEADERX
      IMPORTING
        RETURN       = LS_RETURN.
    IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
      RV_RESULT = 'E'.
      RETURN.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
      WAIT UP TO 1 SECONDS.
    ENDIF.

  ENDMETHOD.


  METHOD CHANGE_PRD_CHARICTERISTIC.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_FIELDNAME TYPE FNAM_____4.
    DATA : LV_NUM(2) TYPE N.

    REFRESH : MT_BDCDATA, MT_MESSTAB.

    SELECT AUFNR, POSNR, PSMNG, AMEIN
        FROM AFPO
       WHERE AUFNR = @MS_2010-ORDNR
        INTO TABLE @DATA(LT_AFPO).

    SORT LT_AFPO BY POSNR.

    LV_INLENGTH = MS_2010-INLENGTH.
    LV_INLENGTH_C = LV_INLENGTH.
    CONDENSE LV_INLENGTH_C.

    LV_INFACTOR = MS_2010-INFACTOR.
    LV_INFACTOR_C = LV_INFACTOR.
    CONDENSE LV_INFACTOR_C.

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPLCOKO1' '0110'.
    __BDC_FIELD : 'CAUFVD-AUFNR' MS_2010-ORDNR,
                        'R62CLORD-FLG_OVIEW'  'X',
                        'BDC_OKCODE' '=ENTK'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

    LOOP AT LT_AFPO INTO DATA(LS_AFPO) .

      IF LS_AFPO-POSNR = MS_2010-POSNR+2(4).
        __BDC_DYNPRO 'SAPLCEI0' '0109'.
        __BDC_FIELD : 'RCTMS-MNAME(01)' '조장(기본단위)',
                            'RCTMS-MNAME(02)' '조장수',
                            'RCTMS-MNAME(03)' '전선_공정코드',
                            'RCTMS-MWERT(01)' LV_INLENGTH_C,
                            'RCTMS-MWERT(02)' LV_INFACTOR_C,
                            'RCTMS-MWERT(03)' MS_2010-GONG_CD,
                            'BDC_OKCODE' '=BACK'.
      ELSE.
        __BDC_DYNPRO 'SAPLCEI0' '0109'.
        __BDC_FIELD 'BDC_OKCODE' '=BACK'.
      ENDIF.

    ENDLOOP.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD : 'BDC_OKCODE' '=BU'.

    __BDC_TRANSACTION 'CO02'.

    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                           OR MSGTYP = 'E'
                                                           OR MSGTYP = 'X'.
      APPEND LS_MESSTAB TO MT_TOT_MESSTAB.
      RV_RESULT = 'E'.
      RETURN.
    ENDLOOP.

    RV_RESULT = 'S'.
    WAIT UP TO '0.5' SECONDS.

  ENDMETHOD.


METHOD change_prd_order.

  DATA : lv_aufnr TYPE aufnr.
  DATA : ls_orderdata TYPE  bapi_pp_order_change.
  DATA : ls_orderdatax TYPE  bapi_pp_order_changex.
  DATA : ls_return TYPE bapiret2 .

  IF ms_2010-ordty NE 'PRD'.
    rv_result = abap_true.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ms_2010-ordnr
    IMPORTING
      output = lv_aufnr.

* 품목이 하나 인지 확인.(한개시 바피, 여러개시 bdc)
  SELECT aufnr, posnr FROM afpo
    INTO TABLE @DATA(lt_afpo)
    WHERE aufnr = @lv_aufnr.

  IF 1 = lines( lt_afpo ).
    ls_orderdata-quantity = mv_total_plord_qty02.
    ls_orderdatax-quantity = abap_true.

    CALL FUNCTION 'BAPI_PRODORD_CHANGE'
      EXPORTING
        number     = lv_aufnr
        orderdata  = ls_orderdata
        orderdatax = ls_orderdatax
      IMPORTING
        return     = ls_return.

    IF ls_return-type NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      WAIT UP TO 1 SECONDS.
    ELSE.
      rv_result = abap_true.
      RETURN.
    ENDIF.


  ELSE. " 여러건의 경우 bdc로 처리
    WAIT UP TO 1 SECONDS.
    READ TABLE lt_afpo  TRANSPORTING NO FIELDS  WITH KEY  aufnr = lv_aufnr
                                                          posnr = ms_2010-posnr+2(4).
    IF sy-subrc EQ 0.
      UPDATE afpo SET   psmng = mv_total_plord_qty02
                  WHERE aufnr = lv_aufnr
                    AND posnr = ms_2010-posnr+2(4).
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    REFRESH : mt_bdcdata, mt_messtab.
    CLEAR ms_bdcparams.

    __setting_bdc_params.

    __bdc_dynpro 'SAPLCOKO1' '0110'.
    __bdc_field : 'CAUFVD-AUFNR' lv_aufnr,
                        'R62CLORD-FLG_OVIEW'  'X',
                        'BDC_OKCODE' '=ENTK'.
*     품목전체 선택
    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field : 'BDC_OKCODE' '=MILL_BT_SEL_ALL'.
*     재계산 클릭
    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field : 'BDC_OKCODE' '=MILL_MP_HEADER_QUANT'.
*
    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field : 'BDC_OKCODE' '=ENT1'.

    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field : 'BDC_OKCODE' '=BU'.

*      __BDC_DYNPRO 'SAPLSPO1' '0300'.
*      __BDC_FIELD : 'BDC_OKCODE' 'YES'.

    __bdc_transaction 'CO02'.

    LOOP AT mt_messtab INTO DATA(ls_messtab) WHERE msgtyp = 'A'
                                                OR msgtyp = 'E'
                                                OR msgtyp = 'X'.
      rv_result = 'E'.
      RETURN.
    ENDLOOP.

    rv_result = 'S'.

  ENDIF.



ENDMETHOD.


METHOD confirm.

  DATA : ls_2010     TYPE zgtppt2010,
         lt_2020     TYPE TABLE OF zgtppt2020,
         lt_zpptc002 TYPE TABLE OF zpptc002.


  IF mt_2020_save IS NOT INITIAL.
    APPEND LINES OF mt_2020_save TO mt_2020.
  ENDIF.

  LOOP AT mt_2020 INTO DATA(ls_2020).

*   오더 검사여장 시료여장 업데이트
    IF ls_2020-ordty = 'PRD'.
      APPEND INITIAL LINE TO lt_zpptc002 ASSIGNING FIELD-SYMBOL(<ls_zpptc002>).
      <ls_zpptc002>-aufnr = ls_2020-ordnr.
      <ls_zpptc002>-posnr = ls_2020-posnr+2(4).
      <ls_zpptc002>-psamg = ls_2020-qlength.
      IF ls_2020-adtype = 'A'.
        <ls_zpptc002>-psmng = ls_2020-adlength.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING ls_2020 TO ls_2010.

*   ZGTPPT2010 저장 기존 데이터 삭제후 인서트
    SELECT * FROM zgtppt2010
      INTO TABLE @DATA(ts_chk_2010)
     WHERE grpnr = @ls_2010-grpnr
       AND gong_cd = @ls_2010-gong_cd
       AND ordnr = @ls_2010-ordnr
       AND posnr = @ls_2010-posnr
       AND ordty = @ls_2010-ordty.
    IF sy-subrc EQ 0.
      DELETE FROM zgtppt2010
       WHERE grpnr = ls_2010-grpnr
         AND gong_cd = ls_2010-gong_cd
         AND ordnr = ls_2010-ordnr
         AND posnr = ls_2010-posnr
         AND ordty = ls_2010-ordty.
      IF sy-subrc EQ 0.
        MODIFY zgtppt2010 FROM ls_2010.
      ENDIF.
    ELSE.
      MODIFY zgtppt2010 FROM ls_2010.
    ENDIF.

    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.

* ZGTPPT2020 저장 기존 데이터 맥스순번 + 1 로 어팬드
  SELECT SINGLE MAX( revno ) FROM zgtppt2020
    INTO @DATA(lv_max_revno)
   WHERE grpnr = @mv_grpnr.

  SELECT * FROM zgtppt2010
    INTO CORRESPONDING FIELDS OF TABLE lt_2020
   WHERE grpnr = mv_grpnr.

  LOOP AT lt_2020 ASSIGNING FIELD-SYMBOL(<ls_2020>).
    <ls_2020>-revno = lv_max_revno + 1.
    <ls_2020>-aenam = sy-uname.
    <ls_2020>-aedat = sy-datum.
  ENDLOOP.

  MODIFY zgtppt2020 FROM TABLE lt_2020.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.

  IF lt_zpptc002[] IS NOT INITIAL.
    MODIFY zpptc002 FROM TABLE lt_zpptc002.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF mt_resb_total[] IS NOT INITIAL.
    SORT mt_resb_total BY rsnum rspos rsart.
    DELETE ADJACENT DUPLICATES FROM mt_resb_total COMPARING rsnum rspos rsart.

    LOOP AT mt_resb_total INTO DATA(ls_resb).

      UPDATE resb   SET bdmng = ls_resb-bdmng
                        erfmg = ls_resb-erfmg
                  WHERE rsnum = ls_resb-rsnum
                    AND rspos = ls_resb-rspos
                    AND rsart = ls_resb-rsart.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


  METHOD CONFIRM_QLENGTH.

    DATA : LV_CHK_ORDNR TYPE ZGTPPT2010-ORDNR.
    DATA : LV_CHK_POSNR TYPE ZGTPPT2010-POSNR.
    DATA : LV_CHK_ORDTY TYPE ZGTPPT2010-ORDTY.
    DATA : LV_CHK_DMORD TYPE ZGTPPT2010-DMORD.
    DATA : LV_CHK_DMLINE TYPE ZGTPPT2010-DMLINE.
    DATA : LV_CHK_DMORDTY TYPE ZGTPPT2010-DMORDTY.

    MOVE : IV_ORDNR TO LV_CHK_ORDNR,
              IV_POSNR TO LV_CHK_POSNR,
              IV_ORDTY TO LV_CHK_ORDTY.
    DO.
      IF LV_CHK_DMORDTY = 'SO'.
        EXIT.
      ENDIF.

      SELECT SINGLE DMORD, DMLINE, DMORDTY
         FROM ZGTPPT2010
       WHERE GRPNR = @MV_GRPNR
         AND ORDTY = @LV_CHK_ORDTY
         AND ORDNR = @LV_CHK_ORDNR
         AND POSNR = @LV_CHK_POSNR
        INTO ( @LV_CHK_DMORD, @LV_CHK_DMLINE, @LV_CHK_DMORDTY ).
      IF SY-SUBRC EQ 0.

        MOVE : LV_CHK_DMORD TO LV_CHK_ORDNR,
           LV_CHK_DMLINE TO LV_CHK_POSNR,
           LV_CHK_DMORDTY TO LV_CHK_ORDTY.
      ELSE.
        READ TABLE MT_2020 INTO DATA(LS_2020_CHK2) WITH KEY GRPNR = MV_GRPNR
                                                            ORDNR = LV_CHK_ORDNR
                                                            POSNR = LV_CHK_POSNR
                                                            ORDTY = LV_CHK_ORDTY.
        IF SY-SUBRC EQ 0.
          MOVE : LS_2020_CHK2-DMORD TO LV_CHK_DMORD,
                     LS_2020_CHK2-DMLINE TO LV_CHK_DMLINE,
                     LS_2020_CHK2-DMORDTY TO LV_CHK_DMORDTY.

          MOVE : LS_2020_CHK2-DMORD TO LV_CHK_ORDNR,
                     LS_2020_CHK2-DMLINE TO LV_CHK_POSNR,
                     LS_2020_CHK2-DMORDTY TO LV_CHK_ORDTY.

        ELSE.
          RETURN.
        ENDIF.
      ENDIF.

    ENDDO.

*  판매오더 기준 설정된 표준여장 존재여부 확인
    SELECT SINGLE * FROM ZGTPPT2070
     WHERE GRPNR = @MV_GRPNR
        AND MATNR = @IV_MATNR
        AND ORDNO = @LV_CHK_DMORD
        AND POSNR = @LV_CHK_DMLINE
      INTO  @DATA(LS_2070).
    IF SY-SUBRC EQ 0. " 존재시 여장세팅
      CV_QLENGTH = LS_2070-QLENGTH.
      CV_CLENGTH = LS_2070-CLENGTH.
    ELSE. "자재 기준 표중여장 존재확인
      SELECT SINGLE * FROM ZGTPPT2070
       WHERE GRPNR = @MV_GRPNR
          AND MATNR = @IV_MATNR
          AND ORDNO IS INITIAL
        INTO CORRESPONDING FIELDS OF @LS_2070.
      IF SY-SUBRC EQ 0.
        CV_QLENGTH = LS_2070-QLENGTH.
        CV_CLENGTH = LS_2070-CLENGTH.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD CONSTRUCTOR.

    MT_MAIN_SEQ_ROUTING = IT_SEQ_ROUTING.
    MV_WERKS = IV_WERKS.
    MV_GRPNR = IV_GRPNR.
    MV_AUART = IV_AUART.

  ENDMETHOD.


  METHOD CONVERSION_PRD_ORDER.

    DATA : LS_2010_NEW TYPE ZGTPPT2010.
    DATA : LT_2010_NEW LIKE TABLE OF LS_2010_NEW.
    DATA : LT_2010_OLD LIKE TABLE OF LS_2010_NEW.
    DATA : LV_PLANNED_ORDER TYPE PLNUM.
    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_PERCENT TYPE I.
    DATA : LV_SUM_NUM TYPE I.
    DATA : LV_PLNUM TYPE PLNUM.
    DATA : LT_RESB LIKE MT_RESB.


    LV_PERCENT = 10.
    PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '처리중..' ).

    LV_SUM_NUM = 80 / LINES( IT_2010 ).

    LOOP AT IT_2010 INTO DATA(LS_2010_PLN).

      ADD LV_SUM_NUM TO LV_PERCENT.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '처리중..' ).

      SELECT SINGLE * FROM ZGTPPT2010
          INTO CORRESPONDING FIELDS OF LS_2010_NEW
        WHERE GRPNR = MV_GRPNR
          AND ORDNR = LS_2010_PLN-ORDNR
          AND POSNR = LS_2010_PLN-POSNR
          AND ORDTY = LS_2010_PLN-ORDTY.

*    기존 예약자재 테이블 조회하여 자재 수량 맞춘다.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = LS_2010_NEW-ORDNR
        IMPORTING
          OUTPUT = LV_PLNUM.

      CLEAR : MV_FINDATE, MV_RSNUM.  " 후행 공정 시작일
      SELECT SINGLE
        FROM PLAF
        FIELDS RSNUM
       WHERE PLNUM = @LV_PLNUM
         INTO @MV_RSNUM .

      SELECT A~*
        FROM RESB AS A
        INNER JOIN MARA AS B
                               ON B~MATNR = A~MATNR
        INNER JOIN MARC AS C
                              ON C~MATNR = A~MATNR
        INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
        WHERE B~MTART = 'MCHF'
            AND C~WERKS = @MV_WERKS
            AND C~BESKZ = 'E'
            AND A~RSNUM = @MV_RSNUM.


      MOVE-CORRESPONDING LS_2010_NEW TO LS_2010_PLN.

      CLEAR LV_PLANNED_ORDER.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = LS_2010_PLN-ORDNR
        IMPORTING
          OUTPUT = LV_PLANNED_ORDER.

      CALL FUNCTION 'BAPI_PRODORD_CREATE_FROM_PLORD'
        EXPORTING
          PLANNED_ORDER    = LV_PLANNED_ORDER
          ORDER_TYPE       = MV_AUART
        IMPORTING
          PRODUCTION_ORDER = LV_AUFNR
          RETURN           = LS_RETURN.

      IF LS_RETURN-TYPE NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
        DO .
          SELECT SINGLE AUFNR, POSNR
            FROM AFPO
           WHERE PLNUM = @LV_PLANNED_ORDER
            INTO (@LS_2010_NEW-ORDNR, @LS_2010_NEW-POSNR ).
          IF SY-SUBRC EQ 0.
            EXIT.
          ELSE.
            WAIT UP TO '0.2' SECONDS.
          ENDIF.
        ENDDO.

        LS_2010_NEW-ORDTY = 'PRD'.

        IF SY-SUBRC NE 0.
          EV_MESSAGE = LV_PLANNED_ORDER && '를'.
          CONCATENATE '계획오더' EV_MESSAGE '생산 오더로 전환 중 오류 발생하였습니다.'
                        INTO EV_MESSAGE SEPARATED BY SPACE.
          EV_RESULT = 'E'.
          EXIT.
        ENDIF.

      ELSE.
        EV_MESSAGE = LV_PLANNED_ORDER && '를'.
        CONCATENATE '계획오더' EV_MESSAGE '생산 오더로 전환 중 오류 발생하였습니다.'
                      INTO EV_MESSAGE SEPARATED BY SPACE.
        EV_RESULT = 'E'.
        EXIT.
      ENDIF.

      CASE LS_2010_PLN-DMORDTY.
        WHEN 'SO'.
        WHEN OTHERS.
* 특성값 세팅
          SET_PRD_CHARICTERISTIC(
            EXPORTING
              IS_2010   = LS_2010_NEW                 " [GT] 오더 연결 정보
            IMPORTING
              EV_RESULT = EV_RESULT ).                " 길이 1의 문자 필드
      ENDCASE.

      CLEAR : MV_RSNUM. " 후행 공정 시작일
      SELECT SINGLE
        FROM AFKO
        FIELDS RSNUM
       WHERE AUFNR = @LS_2010_NEW-ORDNR
          INTO @MV_RSNUM .

      SELECT A~*
        FROM RESB AS A
        INNER JOIN MARA AS B
                               ON B~MATNR = A~MATNR
        INNER JOIN MARC AS C
                               ON C~MATNR = A~MATNR
        INTO CORRESPONDING FIELDS OF TABLE @MT_RESB
        WHERE B~MTART = 'MCHF'
            AND C~WERKS = @MV_WERKS
            AND C~BESKZ = 'E'
            AND A~RSNUM = @MV_RSNUM.

*  이후공정 예약 자재 변경
      LOOP AT MT_RESB INTO DATA(LS_RESB).
        READ TABLE LT_RESB INTO DATA(LS_ORIGN) WITH KEY MATNR = LS_RESB-MATNR.
        IF SY-SUBRC EQ 0.
          UPDATE RESB SET BDMNG = LS_ORIGN-BDMNG
                                    ERFMG = LS_ORIGN-ERFMG
                          WHERE  RSNUM = LS_RESB-RSNUM
                              AND  RSPOS = LS_RESB-RSPOS
                              AND  RSART = LS_RESB-RSART.
          IF SY-SUBRC EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.


      EV_CHK_CON = ABAP_TRUE.
      CHANGE_JOJANG(
        IS_2010_OLD =  LS_2010_PLN
        IS_2010_NEW = LS_2010_NEW  ).

    ENDLOOP.


*  히스토리 반영
    SELECT * FROM ZGTPPT2010 INTO CORRESPONDING FIELDS OF TABLE MT_2020_SAVE
       WHERE GRPNR = MV_GRPNR.


* ZGTPPT2020 저장 기존 데이터 맥스순번 + 1 로 어팬드
    SELECT SINGLE MAX( REVNO )  FROM ZGTPPT2020
         INTO @DATA(LV_MAX_REVNO)
        WHERE GRPNR = @MV_GRPNR.
    IF SY-SUBRC EQ 0.
      LV_MAX_REVNO = LV_MAX_REVNO + 1.
    ELSE.
      LV_MAX_REVNO = 1.
    ENDIF.


    LOOP AT MT_2020_SAVE ASSIGNING FIELD-SYMBOL(<LS_2020>).
      <LS_2020>-REVNO = LV_MAX_REVNO.
      <LS_2020>-AENAM = SY-UNAME.
      <LS_2020>-AEDAT = SY-DATUM.
    ENDLOOP.

    IF MT_2020_SAVE[] IS NOT INITIAL.
      MODIFY ZGTPPT2020 FROM TABLE MT_2020_SAVE.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = '100'  IV_TEXT = '완료' ).

  ENDMETHOD.


  METHOD CREATE_PLN_ORDER.

    DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.

    LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
    LS_HEADERDATA-MATERIAL = IV_MATNR.
*   조장구성 플랜트
    LS_HEADERDATA-PLAN_PLANT = MV_WERKS.
    LS_HEADERDATA-PROD_PLANT = MV_WERKS.
*  검사 여장
*    LS_HEADERDATA-FIXED_SCRAP_QTY = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
*  확정
    LS_HEADERDATA-FIRMING_IND = 'X'.
*  일정 계획 수립
    LS_HEADERDATA-DET_SCHEDULE = 'X'.
* 계산된 종료일(문서 종료일 -1)
    LS_HEADERDATA-ORDER_FIN_DATE = MV_FINDATE.
* 소요량
    LS_HEADERDATA-TOTAL_PLORD_QTY = MV_TOTAL_PLORD_QTY02.

    CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
      EXPORTING
        HEADERDATA   = LS_HEADERDATA
      IMPORTING
        RETURN       = LS_RETURN
        PLANNEDORDER = LV_PLANNEDORDER.

    IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
      RV_RESULT = 'E'.
      RETURN.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF..

    MS_2010-ORDNR = LV_PLANNEDORDER.

* 계획오더정보 조회
    DATA : LT_CAPACITYDATA1 TYPE TABLE OF BAPI_PLDORDCAPA_E1.
    DATA : LT_COMPONENTSDATA TYPE TABLE OF BAPI_PLDORDCOMP_E1.

    CALL FUNCTION 'BAPI_PLANNEDORDER_GET_DETAIL'
      EXPORTING
        PLANNEDORDER   = LV_PLANNEDORDER
      TABLES
        COMPONENTSDATA = LT_COMPONENTSDATA
        CAPACITYDATA1  = LT_CAPACITYDATA1.

* 리턴된 생산 일정으로 계획 오더 시작 및 종료일 수정
    DATA : LS_HEADER TYPE BAPIPLAF_I2.
    DATA : LS_HEADERX TYPE BAPIPLAF_I2X.

    SORT LT_CAPACITYDATA1 BY START_DATE.
    READ TABLE LT_CAPACITYDATA1 INTO DATA(LS_CAPACITYDATA1) INDEX 1.
    LS_HEADER-ORDER_START_DATE = LS_CAPACITYDATA1-START_DATE.

    SORT LT_CAPACITYDATA1 BY FIN_DATE DESCENDING.
    READ TABLE LT_CAPACITYDATA1 INTO LS_CAPACITYDATA1 INDEX 1.
    LS_HEADER-ORDER_FIN_DATE = LS_CAPACITYDATA1-FIN_DATE.

    LS_HEADERX-ORDER_START_DATE = 'X'.
    LS_HEADERX-ORDER_FIN_DATE = 'X'.

    CLEAR LS_RETURN.

    CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
      EXPORTING
        PLANNEDORDER = LV_PLANNEDORDER
        HEADERDATA   = LS_HEADER
        HEADERDATAX  = LS_HEADERX
      IMPORTING
        RETURN       = LS_RETURN.
    IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
      RV_RESULT = 'E'.
      RETURN.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.

  ENDMETHOD.


  METHOD create_prd_order.

    DATA : lv_fieldname TYPE fnam_____4.
    DATA : lv_inlength TYPE i.
    DATA : lv_inlength_c(10) TYPE c.
    DATA : lv_infactor TYPE i.
    DATA : lv_infactor_c(10) TYPE c.
    DATA : lv_num(2) TYPE n.
    DATA : lv_psmng_c(30) TYPE c.
    DATA : lv_tabix TYPE i.
    DATA : lv_idx TYPE i.

    READ TABLE mt_main_seq_routing INTO DATA(ls_routing) WITH KEY matnr = iv_matnr.

    REFRESH : mt_bdcdata, mt_messtab.

    SELECT b~aufnr, b~posnr, b~psmng, b~amein
      FROM @it_2010 AS a
      INNER JOIN afpo AS b
                            ON b~aufnr = a~ordnr
    INTO TABLE @DATA(lt_afpo).

    __setting_bdc_params.

    __bdc_dynpro  'SAPLCOKO1' '0110'.
    __bdc_field : 'CAUFVD-AUFNR' iv_aufnr,
                  'R62CLORD-FLG_OVIEW'  'X',
                  'BDC_OKCODE' '=ENTK'.

    lv_idx = lines( it_2010 ).
    CLEAR lv_num.
    LOOP AT it_2010 INTO DATA(ls_2010).
      READ TABLE lt_afpo INTO DATA(ls_afpo) WITH KEY aufnr = ls_2010-ordnr
                                                     posnr = ls_2010-posnr+2(4).

      IF lv_num < 2 .
        ADD 1 TO lv_num.
      ENDIF.
      lv_tabix = sy-tabix.

      __bdc_dynpro  'SAPLCOKO1' '0115'.
      __bdc_field : 'BDC_OKCODE' '/00'.

      IF lv_tabix NE 1.
*      자재정보
        lv_fieldname = 'MILL_PP_SE-MATNR(' && lv_num && ')'.
        __bdc_field :  lv_fieldname iv_matnr.
*      단위
        lv_fieldname = 'MILL_PP_SE-AMEIN(' && lv_num && ')'.
        __bdc_field :  lv_fieldname ls_afpo-amein.
      ENDIF.

*    수량 입력
      lv_fieldname = 'MILL_PP_SE-PSMNG(' && lv_num && ')'.


      IF lv_tabix NE 1 AND ls_2010-qlength NE 0.
        IF ls_routing-seqno = 1. "
          lv_psmng_c = ls_afpo-psmng.
        ELSE.
          lv_psmng_c = ls_afpo-psmng - ( ls_2010-qlength * ls_2010-infactor ).
        ENDIF.
      ELSE.
        lv_psmng_c = ls_afpo-psmng.
      ENDIF.

      CONDENSE lv_psmng_c.
      __bdc_field :  lv_fieldname lv_psmng_c.

      IF lv_tabix >= 3.
        __bdc_dynpro 'SAPLKOBS' '0130'.
        __bdc_field :  'BDC_OKCODE' '=BACK'.
      ENDIF.


      IF ls_2010-dmordty NE 'SO'.

        IF lv_tabix = 1.
*       최초 특성값 복사 때문에 1번 라인은 2번 클릭
          __bdc_dynpro 'SAPLCOKO1' '0115'.
          __bdc_field :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
          lv_fieldname = 'MILL_PP_SE-MARK(01)'.
          __bdc_field :  lv_fieldname 'X'.

          __bdc_dynpro 'SAPLCOKO1' '0115'.
          __bdc_field :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
        ELSE.
          __bdc_dynpro 'SAPLCOKO1' '0115'.
          __bdc_field :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
          lv_fieldname = 'MILL_PP_SE-MARK(01)'.
          __bdc_field :  lv_fieldname 'X'.
        ENDIF.

*   특성 세팅
        __bdc_dynpro 'SAPLCEI0' '0109'.
        __bdc_field :  'BDC_OKCODE' '=BACK'.

        lv_inlength = ls_2010-inlength.
        lv_inlength_c = lv_inlength.
        CONDENSE lv_inlength_c.

        lv_infactor = ls_2010-infactor.
        lv_infactor_c = lv_infactor.
        CONDENSE lv_infactor_c.

        __bdc_field : 'RCTMS-MNAME(01)' '조장(기본단위)',
                      'RCTMS-MNAME(02)' '조장수',
                      'RCTMS-MNAME(03)' '전선_공정코드',
                      'RCTMS-MWERT(01)' lv_inlength_c,
                      'RCTMS-MWERT(02)' lv_infactor_c,
                      'RCTMS-MWERT(03)' ls_2010-gong_cd.

        __bdc_dynpro 'SAPLCOKO1' '0115'.
        __bdc_field :  'BDC_OKCODE' '/00'.
        lv_fieldname = 'MILL_PP_SE-MARK(01)'.
        __bdc_field :  lv_fieldname ' '.

      ENDIF.

    ENDLOOP.

*  수량 재계산
    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

    __bdc_dynpro 'SAPLCOKO1' '0115'.
    __bdc_field :  'BDC_OKCODE' '=MILL_MP_HEADER_QUANT'.

    IF mv_auart = 'RP01'.
      __bdc_dynpro 'SAPLCOKO1' '0115'.
      __bdc_field : 'BDC_OKCODE' '=KOZE'.

      __bdc_dynpro 'SAPLCOKO1' '0115'.
      __bdc_field : 'BDC_OKCODE' '=BU',
                    'CAUFVD-APRIO' '9'. "8->9로 변경.SRM2607-10582.2026.07.28.zlsgpp5.
    ELSE.
      __bdc_dynpro 'SAPLCOKO1' '0115'.
      __bdc_field : 'BDC_OKCODE' '=BU'.
    ENDIF.

    EXPORT lv_chk_multy = abap_true TO MEMORY ID 'ZBDC'.

    __bdc_transaction 'CO02'.

    FREE MEMORY ID 'ZBDC'.

    LOOP AT mt_messtab INTO DATA(ls_messtab) WHERE msgtyp = 'A'
                                                           OR msgtyp = 'E'
                                                           OR msgtyp = 'X'.
      APPEND ls_messtab TO mt_tot_messtab.
      rv_result = 'E'.
      RETURN.
    ENDLOOP.



    rv_result = 'S'.


  ENDMETHOD.


  METHOD DELETE_ORDER.

    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LT_DEL_2010 TYPE TABLE OF ZGTPPT2010.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
    DATA : LV_PERCENT TYPE I.
    DATA : LV_SUM_NUM TYPE I.
    DATA : LV_CHK_ERR.
    DATA : LV_SEQNO TYPE I.

    DATA : BEGIN OF LS_CHK_ORDNR,
             ORDNR TYPE ZGTPPT2010-ORDNR,
             ORDTY TYPE ZGTPPT2010-ORDTY,
           END OF LS_CHK_ORDNR.
    DATA : LT_CHK_ORDNR LIKE TABLE OF LS_CHK_ORDNR.

    LV_PERCENT = 10.
    PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '처리중..' ).

    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_2010)
       FOR ALL ENTRIES IN @IT_2010
     WHERE GRPNR = @MV_GRPNR
       AND ORDNR = @IT_2010-ORDNR.

    LV_SUM_NUM = 80 / LINES( LT_2010 ).

    REFRESH MT_2020.

    LV_SEQNO = LINES( MT_MAIN_SEQ_ROUTING ).

    DO.

      IF LV_SEQNO = 0.
        EXIT.
      ENDIF.

      READ TABLE MT_MAIN_SEQ_ROUTING INTO DATA(LS_ROUTING) WITH KEY SEQNO = LV_SEQNO.
      IF LS_ROUTING-MAABC = 'B'.
        LV_SEQNO = LV_SEQNO - 1.
        CONTINUE.
      ENDIF.

      LOOP AT LT_2010 INTO DATA(LS_2010) WHERE GONG_CD = LS_ROUTING-CHART
                                           AND MATNR = LS_ROUTING-MATNR.
        CLEAR LV_CHK_ERR.
        ADD LV_SUM_NUM TO LV_PERCENT.
        PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '처리중..' ).

        READ TABLE LT_CHK_ORDNR TRANSPORTING NO FIELDS  WITH KEY  ORDNR = LS_2010-ORDNR
                                                                  ORDTY = LS_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          APPEND INITIAL LINE TO MT_2020 ASSIGNING FIELD-SYMBOL(<LS_2020>).
          MOVE-CORRESPONDING LS_2010 TO <LS_2020>.
          CONTINUE.
        ENDIF.

        CASE LS_2010-ORDTY.
          WHEN 'PLN'.
            LV_PLANNEDORDER = LS_2010-ORDNR.
            CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
              EXPORTING
                PLANNEDORDER = LV_PLANNEDORDER
              IMPORTING
                RETURN       = LS_RETURN.

            IF NOT ( LS_RETURN-TYPE EQ 'S' OR LS_RETURN-TYPE EQ '' ).
              APPEND INITIAL LINE TO ET_ERR_ORDER ASSIGNING FIELD-SYMBOL(<LS_ERR_ORDER>).
              <LS_ERR_ORDER>-ORDER_NUMBER = LS_2010-ORDNR.
              EV_RESULT = 'E'.
              LV_CHK_ERR = ABAP_TRUE.
              EXIT.
            ENDIF.

          WHEN 'PRD'.
            REFRESH : LT_ORDERS, LT_DETAIL_RETURN.
            APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
            <LS_ORDER>-ORDER_NUMBER = LS_2010-ORDNR.
            CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
              IMPORTING
                RETURN        = LS_RETURN2
              TABLES
                ORDERS        = LT_ORDERS
                DETAIL_RETURN = LT_DETAIL_RETURN.

            IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).

*            IF NOT ( LS_RETURN2-TYPE EQ 'S' OR LS_RETURN2-TYPE EQ '' ).
              APPEND LINES OF LT_DETAIL_RETURN TO ET_ERR_ORDER.
              EV_RESULT = 'E'.
              LV_CHK_ERR = ABAP_TRUE.
              EXIT.
            ENDIF.

        ENDCASE.

        APPEND INITIAL LINE TO LT_CHK_ORDNR ASSIGNING FIELD-SYMBOL(<LS_CHK_ORDNR>).
        <LS_CHK_ORDNR>-ORDNR = LS_2010-ORDNR.
        <LS_CHK_ORDNR>-ORDTY = LS_2010-ORDTY.

*      IF LV_CHK_ERR IS INITIAL.
        APPEND INITIAL LINE TO MT_2020 ASSIGNING <LS_2020>.
        MOVE-CORRESPONDING LS_2010 TO <LS_2020>.
*      ENDIF.

      ENDLOOP.

      IF EV_RESULT = 'E'.
        EXIT.
      ENDIF.

      LV_SEQNO = LV_SEQNO - 1.

    ENDDO.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

* 공정체인에서 데이터 삭제후 히스토리 반영
    IF MT_2020[] IS NOT INITIAL.
      SELECT B~*
        FROM @MT_2020 AS A  INNER JOIN  ZGTPPT2010 AS B ON  B~GRPNR = A~GRPNR
                                                        AND B~ORDNR = A~ORDNR
                                                        AND B~POSNR = A~POSNR
                                                        AND B~ORDTY = A~ORDTY
       INTO TABLE @LT_DEL_2010.
      IF LT_DEL_2010[] IS NOT INITIAL.
        DELETE ZGTPPT2010 FROM TABLE LT_DEL_2010.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.
* 히스토리 반영
    SELECT SINGLE MAX( REVNO )  FROM ZGTPPT2020
      INTO @DATA(LV_MAX_REVNO)
     WHERE GRPNR = @MV_GRPNR.

    SELECT * FROM ZGTPPT2010
      INTO CORRESPONDING FIELDS OF TABLE MT_2020_SAVE
     WHERE GRPNR = MV_GRPNR.

    LOOP AT MT_2020_SAVE ASSIGNING <LS_2020>.
      <LS_2020>-REVNO = LV_MAX_REVNO + 1.
      <LS_2020>-AENAM = SY-UNAME.
      <LS_2020>-AEDAT = SY-DATUM.
    ENDLOOP.

    MODIFY ZGTPPT2020 FROM TABLE MT_2020_SAVE.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = '100'  IV_TEXT = '완료' ).

  ENDMETHOD.


  METHOD DELE_PLN_ORDER.

    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IV_PLANNEDORDER
      IMPORTING
        OUTPUT = LV_PLANNEDORDER.

*   계획오더 삭제 진행
    CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
      EXPORTING
        PLANNEDORDER = LV_PLANNEDORDER
      IMPORTING
        RETURN       = LS_RETURN.

    IF LS_RETURN = 'E'.
      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

  ENDMETHOD.


  METHOD DELE_PRD_ORDER.

    DATA : LV_AUFNR TYPE AUFK-AUFNR.
    DATA : LV_STCD TYPE ZORDSTCD.
    DATA : LV_OBJNR TYPE JEST-OBJNR.
    DATA : LV_USER_LINE TYPE BSVX-STTXT.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IV_AUFNR
      IMPORTING
        OUTPUT = LV_AUFNR.

*    상태값 조회
    CLEAR LV_STCD.
    CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
      EXPORTING
        IM_AUFNR        = LV_AUFNR
      IMPORTING
        EX_OSTCD        = LV_STCD
      EXCEPTIONS
        NO_SELECTION    = 1
        NOT_FOUND_OBJNR = 2
        OTHERS          = 3.

    CLEAR LV_USER_LINE.
    LV_OBJNR = 'OR' && LV_AUFNR.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        FLG_USER_STAT    = 'X'
        OBJNR            = LV_OBJNR
        ONLY_ACTIVE      = 'X'
        SPRAS            = SY-LANGU
      IMPORTING
        USER_LINE        = LV_USER_LINE
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.


*  삭제 유효성 체크
    CASE LV_STCD. " 상태값 체크
      WHEN 'E' OR 'Z' OR 'D' OR 'G' OR 'F' OR 'C'.. " 종료된 오더 혹은 비정상 오더, " 작업완료, 장업중인오더
        RV_RETURN = 'W'.
        RETURN.
    ENDCASE.

    IF LV_USER_LINE CO 'PAYO'. "
      RV_RETURN = 'W'.
      RETURN.
    ENDIF.

    REFRESH : LT_ORDERS, LT_DETAIL_RETURN.
    APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
    <LS_ORDER>-ORDER_NUMBER = LV_AUFNR.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = LT_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.

    IF LS_RETURN2 = 'E'.
      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    WAIT UP TO '0.5' SECONDS.


  ENDMETHOD.


  METHOD edit_adlength.

    DATA : ls_headerdata TYPE bapiplaf_i1.
    DATA : lt_headerdata TYPE TABLE OF bapiplaf_i1.
    DATA : ls_2000 TYPE zgtppt2000.
    DATA : lt_2010_temp TYPE TABLE OF zgtppt2010.
    DATA : lt_result TYPE bapi_order_return_tt.
    DATA : lt_2010_dev TYPE TABLE OF zgtppt2010.
    DATA : lt_2010_pre TYPE TABLE OF zgtppt2010.
    DATA : lv_seqno TYPE i.
    DATA : lt_cal_2010 LIKE mt_2010_cal.
    DATA : lv_chk_she.
    DATA : lv_bdmng TYPE resb-bdmng.

    DATA : lt_2020_save LIKE mt_2020_save.

    DATA : lv_percent TYPE i.
    DATA : lv_sum_num TYPE i.

    lv_percent = 10.
    progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

*&---------------------------------------------------------------------*
* 여장 변경된 최초 공정 구성
*&---------------------------------------------------------------------*
    mt_2010 = it_2010.

    READ TABLE mt_main_seq_routing  INTO ms_main_seq_routing WITH KEY matnr = iv_matnr." 자재번호로 공정정보 추출
    lv_seqno = ms_main_seq_routing-seqno.

    IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
      READ TABLE it_2010 INTO DATA(ls_2010_chk) INDEX 1.
      SELECT SINGLE plnbez AS matnr, gamng, gasmg
        FROM afko
        INTO @DATA(ls_she_order)
        WHERE aufnr = @ls_2010_chk-ordnr.
    ENDIF.

    get_chain_data(
      EXPORTING
        it_data     = it_2010
      IMPORTING
        et_pre_data = lt_2010_pre
        et_dev_data = lt_2010_dev ).
    MOVE-CORRESPONDING lt_2010_dev TO mt_2020_source.

    IF mt_2020_source IS INITIAL. "후공정 오더가 없으면 공정마스터 조회

      SELECT SINGLE b~*
        FROM @it_2010 AS a  INNER JOIN zgtppt2000 AS b  ON  b~grpnr = a~grpnr
                                                        AND b~ordno = a~dmord
                                                        AND b~posnr = a~dmline
        INTO CORRESPONDING FIELDS OF @ls_2000.

      ms_2020_source-ordty = 'SO'.
      ms_2020_source-inlength = ls_2000-inlength.
      ms_2020_source-infactor = 1.
      APPEND ms_2020_source TO mt_2020_source.
    ENDIF.

*  공정의 검사여장 정보 조회
    SELECT a~matnr, a~mtart, c~/sapmp/fix_as_j
      FROM @mt_main_seq_routing AS m  INNER JOIN mara AS a  ON a~matnr = m~matnr
                                      INNER JOIN mapl AS b  ON b~matnr = a~matnr
                                      INNER JOIN plpo AS c  ON c~plnnr = b~plnnr
      WHERE b~werks = @mv_werks
        AND b~plnty = 'N'
        AND b~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
        AND c~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
        AND c~plnty = 'N'
        AND c~plnkn = '00000001'
      ORDER BY a~matnr
      INTO TABLE @DATA(lt_infor_matnr).

    READ TABLE lt_infor_matnr INTO DATA(ls_infor_matnr) WITH KEY matnr = iv_matnr.

* 선택 오더 여장 추가(여장 추가 오더는 이후공정 예약자재 수량 변경만 존재)
    READ TABLE mt_2010 INTO ms_2010 INDEX 1.

    IF lines( mt_2020_source ) = 1.
      READ TABLE  mt_2020_source INTO ms_2020_source INDEX 1.

      CASE ms_2020_source-ordty.
        WHEN 'SO'. " 현재 정보로 바로 수량 변경후 반영, 최초 여장추가건만 가능
          mv_total_plord_qty02 = ( ms_2010-inlength + ms_2010-qlength + ms_2010-slength +
                                   ms_2010-elength + ms_2010-clength + ms_2010-adlength ) * ms_2010-infactor.
          ev_result = change_prd_order( ).
          IF ev_result = 'E'.
            ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
            RETURN.
          ENDIF.

          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_2020_source>).
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING FIELD-SYMBOL(<ls_2020_save>).
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.

        WHEN 'PLN' OR 'PRD'.
          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.

          calc_lc(
          EXPORTING
            iv_matnr            = ls_infor_matnr-matnr            " 자재 번호
            iv_fixed_scrap_qty  = ls_infor_matnr-/sapmp/fix_as_j  " 계획된 스크랩 수량
            iv_gubun            = ms_2010-ordty
            iv_adtype           = ms_2010-adtype
            iv_adlength         = ms_2010-adlength
          IMPORTING
            ev_result           = ev_result
          CHANGING
            ct_headerdata       = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

          IF ev_result = 'F'.
            ev_message = '연결된 이후공정 자재가 없습니다.'.
            RETURN.
          ENDIF.

          IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
            READ TABLE mt_2020_lc INTO DATA(ls_2020_lc) INDEX 1.
            IF ls_2020_lc-infactor = 0.
              ls_2020_lc-infactor = 1.
            ENDIF.
            mv_total_plord_qty02 = mv_total_plord_qty / ls_2020_lc-infactor.
          ELSE.
            mv_total_plord_qty02 = mv_total_plord_qty.
          ENDIF.

          CASE ms_2010-ordty.
            WHEN 'PRD'.
              ev_result = change_prd_order( ).
              IF ev_result = 'E'.
                ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                RETURN.
              ENDIF.

            WHEN 'PLN'.
              ev_result = change_pln_order( ).
              IF ev_result = 'E'.
                ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                RETURN.
              ENDIF.

          ENDCASE.

          IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
            lv_bdmng = ls_she_order-gamng.
            READ TABLE mt_resb_origin INTO DATA(ls_she_resb) WITH KEY matnr = ls_she_order-matnr
                                                                      bdmng = lv_bdmng.
            IF sy-subrc EQ 0.
              ls_she_resb-bdmng = mv_total_plord_qty02.
              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  i_matnr              = ls_she_resb-matnr    " <-- 해당 자재코드
                  i_in_me              = ls_she_resb-meins  "<-- 현 수량의 단위
                  i_out_me             = ls_she_resb-erfme " <-- 변경되어질 수량의 단위
                  i_menge              = mv_total_plord_qty02 " <-- 현 수량 변수
                IMPORTING
                  e_menge              = ls_she_resb-erfmg " <-- 변경되어질 수량변수
                EXCEPTIONS
                  error_in_application = 1
                  error                = 2
                  OTHERS               = 3.



              UPDATE resb SET   bdmng = ls_she_resb-bdmng
                                erfmg = ls_she_resb-erfmg
                          WHERE rsnum = ls_she_resb-rsnum
                            AND rspos = ls_she_resb-rspos
                            AND rsart = ls_she_resb-rsart.
              IF sy-subrc EQ 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
                EXIT.
              ENDIF.
            ENDIF.


          ELSE.
*  이후공정 예약 자재 변경
            LOOP AT mt_resb INTO DATA(ls_resb).
              UPDATE resb SET   bdmng = ls_resb-bdmng
                                erfmg = ls_resb-erfmg
                          WHERE rsnum = ls_resb-rsnum
                            AND rspos = ls_resb-rspos
                            AND rsart = ls_resb-rsart.
              IF sy-subrc EQ 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
* CHAIN 변경 데이터 옮겨준다.
          IF mt_2010[] IS NOT INITIAL.
            REFRESH mt_2020_source.
            LOOP AT mt_2010 INTO ms_2010.
              APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
              APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
            ENDLOOP.
          ENDIF.
      ENDCASE.
    ELSE. " 이후 공정이 여러건일시 복조장 아닐시 계산 불가
      DATA(lt_chk_2020) = mt_2020_source.
      SORT lt_chk_2020 BY ordnr.
      DELETE ADJACENT DUPLICATES FROM lt_chk_2020 COMPARING ordnr.

      IF lines( lt_chk_2020 ) NE 1.
        ev_result = 'E'.
        ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
        RETURN.
      ELSE. " 복조장 일시 오더소요량 변경, 이후공정 예약자재 수량 변경

        REFRESH lt_cal_2010.
        MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

        calc_lc_multy(
          EXPORTING
            iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
            iv_adtype          = ms_2010-adtype
            iv_adlength        = ms_2010-adlength        " 추가여장
          IMPORTING
            ev_result          = ev_result
            et_return          = lt_result                 " 길이 1의 문자 필드
          CHANGING
            ct_2010_dev        = lt_cal_2010 ).

        IF ev_result = 'F'.
          ev_message = '연결된 이후공정 자재가 없습니다.'.
          RETURN.
        ENDIF.

        IF lt_result[] IS NOT INITIAL.
          READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
          ev_message = ls_result-message.
          RETURN.
        ENDIF.

        mv_total_plord_qty02 = mv_total_plord_qty.

        CASE ms_2010-ordty.
          WHEN 'PRD'.
            ev_result = change_prd_order( ).
            IF ev_result = 'E'.
              ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.

          WHEN 'PLN'.
            ev_result = change_pln_order( ).
            IF ev_result = 'E'.
              ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.

        ENDCASE.

*  이후공정 예약 자재 변경
        LOOP AT mt_resb INTO ls_resb.
          UPDATE resb SET   bdmng = ls_resb-bdmng
                            erfmg = ls_resb-erfmg
                      WHERE rsnum = ls_resb-rsnum
                        AND rspos = ls_resb-rspos
                        AND rsart = ls_resb-rsart.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.

      ENDIF.
    ENDIF.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*  이후 공정 오더가 복조장인지 확인
    IF mt_2020_source[] IS NOT INITIAL.
      SELECT b~*
        FROM @mt_2020_source AS a INNER JOIN  zgtppt2010 AS b ON  b~grpnr = a~grpnr
                                                              AND b~ordty = a~ordty
                                                              AND b~ordnr = a~ordnr
        INTO TABLE @DATA(lt_2010_dev_chk).
      SORT lt_2010_dev_chk BY ordty ordnr posnr.
      DELETE ADJACENT DUPLICATES FROM lt_2010_dev_chk COMPARING ordty ordnr posnr.
      LOOP AT lt_2010_dev_chk INTO DATA(ls_2010_dev_chk).
        READ TABLE mt_2020_source TRANSPORTING NO FIELDS  WITH KEY  ordty = ls_2010_dev_chk-ordty
                                                                    ordnr = ls_2010_dev_chk-ordnr
                                                                    posnr = ls_2010_dev_chk-posnr.
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_chk_source>).
          READ TABLE mt_2020_save INTO DATA(ls_chg_2010)  WITH KEY  ordty = ls_2010_dev_chk-ordty
                                                                    ordnr = ls_2010_dev_chk-ordnr
                                                                    posnr = ls_2010_dev_chk-posnr.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING ls_chg_2010 TO <ls_chk_source>.
          ELSE.
            MOVE-CORRESPONDING ls_2010_dev_chk TO <ls_chk_source>.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
*&---------------------------------------------------------------------*
    lv_percent = 20.
    progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).



*&---------------------------------------------------------------------*
*  이전 공정들에 대한 LC 재계산
*&---------------------------------------------------------------------*
    DO.

      ADD 10 TO lv_percent.
      progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).
      ADD 1 TO lv_seqno.
      READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY seqno = lv_seqno.
      IF sy-subrc EQ 0.
        IF ms_main_seq_routing-maabc = 'B'. " ABC 지시자가 B라면 다음으로 공정에 포함안됨
          CONTINUE.
        ENDIF.
      ELSE. " 조회 대상 없을시 완료
        EXIT.
      ENDIF.

      REFRESH mt_2010.
      mt_2010 = VALUE #( FOR wa_2010 IN lt_2010_pre WHERE ( gong_cd = ms_main_seq_routing-chart AND
                                                            matnr   = ms_main_seq_routing-matnr )
                         ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).

      get_chain_data(
        EXPORTING
          it_data      = mt_2010
        IMPORTING
          et_dev_data  = DATA(lt_2010_temp_dev) ).

      DATA(lt_chk_2010) = lt_2010_temp_dev.
      SORT lt_chk_2010 BY ordnr.
      DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING ordnr.
      IF lines( lt_chk_2010 ) = 1. " 이후공정이 복조장 일시만 이후공정에 포함
        LOOP AT lt_2010_temp_dev INTO DATA(ls_temp_dev).
          READ TABLE mt_2020_source TRANSPORTING NO FIELDS  WITH KEY  ordnr = ls_temp_dev-ordnr
                                                                      posnr = ls_temp_dev-posnr
                                                                      ordty = ls_temp_dev-ordty.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_source_dev>).
            MOVE-CORRESPONDING ls_temp_dev TO <ls_source_dev>.
          ENDIF.
        ENDLOOP.
      ENDIF.
      REFRESH lt_chk_2010.

      READ TABLE lt_infor_matnr INTO ls_infor_matnr WITH KEY matnr = ms_main_seq_routing-matnr.
      IF lv_chk_she IS NOT INITIAL. " 연합 이후 쉬스 공정 있을경우 각각 계산 해줘야 한다.

        REFRESH lt_chk_2010.
        MOVE-CORRESPONDING mt_2020_source TO lt_chk_2010.
        SORT lt_chk_2010 BY ordnr.
        DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING ordnr.
        IF lines( lt_chk_2010 ) = 1.
*          이후공정이 복조장 일시
* 이전 수정한 여장을 추가하기 위해 조회데이터에 변경적용
          MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

          calc_lc_multy(
            EXPORTING
              iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
            IMPORTING
              ev_result          = ev_result
              et_return          = lt_result                 " 길이 1의 문자 필드
            CHANGING
              ct_2010_dev        = lt_cal_2010 ).

          IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
            EXIT.
          ENDIF.

          IF lt_result[] IS NOT INITIAL.
            READ TABLE lt_result INTO ls_result INDEX 1.
            ev_message = ls_result-message.
            RETURN.
          ENDIF.

          IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
            mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
          ELSE.
            mv_total_plord_qty02 = mv_total_plord_qty.
          ENDIF.

          LOOP AT mt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
            <ls_2010>-inlength = ms_2010_cal-inlength.
            IF lv_chk_she IS NOT INITIAL.
              <ls_2010>-infactor = 1.
            ELSE.
              <ls_2010>-infactor = ms_2010_cal-infactor.
            ENDIF.
            <ls_2010>-qlength = ms_2010_cal-qlength.
            <ls_2010>-clength = ms_2010_cal-clength.
            <ls_2010>-slength = ms_2010_cal-slength.
            <ls_2010>-elength = ms_2010_cal-elength.
            <ls_2010>-adlength = ms_2010_cal-adlength.
            <ls_2010>-adtype = ms_2010_cal-adtype.
            MOVE-CORRESPONDING <ls_2010> TO ms_2010.

            CASE <ls_2010>-ordty.
              WHEN 'PRD'.
                ev_result = change_prd_order( ).
                IF ev_result = 'E'.
                  ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                  RETURN.
                ENDIF.

              WHEN 'PLN'.
                ev_result = change_pln_order( ).
                IF ev_result = 'E'.
                  ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                  RETURN.
                ENDIF.
            ENDCASE.
          ENDLOOP.
*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO ls_resb.
            UPDATE resb SET   bdmng = ls_resb-bdmng
                              erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
          IF mt_2010[] IS NOT INITIAL.
            REFRESH mt_2020_source.
            LOOP AT mt_2010 INTO ms_2010.
              APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
              APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
            ENDLOOP.
          ENDIF.

        ELSEIF lines( lt_chk_2010 ) NE lines( mt_2020_source ). " 이후 공정 구성(복조장 + 단일조장)
          LOOP AT lt_chk_2010 INTO DATA(ls_chk_2010).
            REFRESH lt_cal_2010.
            LOOP AT mt_2020_source ASSIGNING <ls_2020_source> WHERE ordnr = ls_chk_2010-ordnr.
              APPEND INITIAL LINE TO lt_cal_2010 ASSIGNING FIELD-SYMBOL(<ls_cal_2010>).
              MOVE-CORRESPONDING <ls_2020_source> TO <ls_cal_2010>.
            ENDLOOP.

            IF lines( lt_cal_2010 ) = 1. " 단일 오더의 경우

              REFRESH lt_headerdata.
              APPEND INITIAL LINE TO lt_headerdata.
              MOVE-CORRESPONDING ls_chk_2010 TO ms_2020_source.

              calc_lc(
              EXPORTING
                iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
                iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
                iv_gubun           = ms_2020_source-ordty
              IMPORTING
                ev_result        = ev_result
              CHANGING
                ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

              IF ev_result = 'F'.
                EXIT.
              ENDIF.

              LOOP AT mt_2020_lc INTO DATA(ls_2020).
                DATA(lv_tabix) = sy-tabix.
                READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
                IF lv_tabix = 1.
                  LOOP AT mt_2010 ASSIGNING <ls_2010> WHERE dmord = ls_chk_2010-ordnr
                                                        AND dmline = ls_chk_2010-posnr.
                    <ls_2010>-inlength = ls_2020-inlength.
                    <ls_2010>-infactor = 1.
                    <ls_2010>-qlength = ls_2020-qlength.
                    <ls_2010>-clength = ls_2020-clength.
                    <ls_2010>-slength = ls_2020-slength.
                    <ls_2010>-elength = ls_2020-elength.
                    <ls_2010>-adlength = ls_2020-adlength.
                    <ls_2010>-adtype = ls_2020-adtype.
                    MOVE-CORRESPONDING <ls_2010> TO ms_2010.

                    mv_total_plord_qty02 = ls_headerdata-total_plord_qty / ls_2020-infactor.
                    CASE <ls_2010>-ordty.
                      WHEN 'PRD'.
                        ev_result = change_prd_order( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                        ev_result = change_prd_charicteristic( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
                      WHEN 'PLN'.
                        ev_result = change_pln_order( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
                    ENDCASE.
                  ENDLOOP.
                ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                  ev_result = 'E'.
                  ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                  RETURN.
                ENDIF.
              ENDLOOP.

            ELSE. " 복조장의 경우
              calc_lc_multy(
                EXPORTING
                  iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
                  iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
                IMPORTING
                  ev_result          = ev_result
                  et_return          = lt_result                 " 길이 1의 문자 필드
                CHANGING
                  ct_2010_dev        = lt_cal_2010 ).

              IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
                EXIT.
              ENDIF.

              IF lt_result[] IS NOT INITIAL.
                READ TABLE lt_result INTO ls_result INDEX 1.
                ev_message = ls_result-message.
                RETURN.
              ENDIF.

              IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
                mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
              ELSE.
                mv_total_plord_qty02 = mv_total_plord_qty.
              ENDIF.

              LOOP AT mt_2010 ASSIGNING <ls_2010> WHERE dmord = ls_chk_2010-ordnr .
                <ls_2010>-inlength = ms_2010_cal-inlength.
                IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
                  <ls_2010>-infactor = 1.
                ELSE.
                  <ls_2010>-infactor = ms_2010_cal-infactor.
                ENDIF.
                <ls_2010>-qlength = ms_2010_cal-qlength.
                <ls_2010>-clength = ms_2010_cal-clength.
                <ls_2010>-slength = ms_2010_cal-slength.
                <ls_2010>-elength = ms_2010_cal-elength.
                <ls_2010>-adlength = ms_2010_cal-adlength.
                <ls_2010>-adtype = ms_2010_cal-adtype.
                MOVE-CORRESPONDING <ls_2010> TO ms_2010.

                CASE <ls_2010>-ordty.
                  WHEN 'PRD'.
                    ev_result = change_prd_order( ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.

                  WHEN 'PLN'.
                    ev_result = change_pln_order( ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
                ENDCASE.
              ENDLOOP.
            ENDIF.

*  이후공정 예약 자재 변경
            LOOP AT mt_resb INTO ls_resb.
              UPDATE resb SET   bdmng = ls_resb-bdmng
                                erfmg = ls_resb-erfmg
                          WHERE rsnum = ls_resb-rsnum
                            AND rspos = ls_resb-rspos
                            AND rsart = ls_resb-rsart.
              IF sy-subrc EQ 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
          IF mt_2010[] IS NOT INITIAL.
            REFRESH mt_2020_source.
            LOOP AT mt_2010 INTO ms_2010.
              APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
              APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
            ENDLOOP.
          ENDIF.

        ELSE.

          LOOP AT mt_2020_source INTO ms_2020_source.
            READ TABLE mt_2010  ASSIGNING FIELD-SYMBOL(<ms_2010>) WITH KEY  ordnr = ms_2020_source-reord
                                                                            posnr = ms_2020_source-reline
                                                                            ordty = ms_2020_source-reordty.
            IF sy-subrc NE 0.
              ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.

            REFRESH lt_headerdata.
            APPEND INITIAL LINE TO lt_headerdata.

            calc_lc(
            EXPORTING
              iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
              iv_gubun           = ms_2020_source-ordty
            IMPORTING
              ev_result        = ev_result
            CHANGING
              ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

            IF ev_result = 'F'.
              EXIT.
            ENDIF.

            LOOP AT mt_2020_lc INTO ls_2020.

              READ TABLE lt_headerdata INTO ls_headerdata INDEX sy-tabix.
              IF sy-tabix = 1.
                <ms_2010>-inlength = ls_2020-inlength.
                <ms_2010>-infactor = ls_2020-infactor.
                <ms_2010>-qlength = ls_2020-qlength.
                <ms_2010>-clength = ls_2020-clength.
                <ms_2010>-slength = ls_2020-slength.
                <ms_2010>-elength = ls_2020-elength.
                <ms_2010>-adlength = ls_2020-adlength.
                <ms_2010>-adtype = ls_2020-adtype.
                MOVE-CORRESPONDING <ms_2010> TO ms_2010.

                mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
                CASE <ms_2010>-ordty.
                  WHEN 'PRD'.
                    ev_result = change_prd_order( ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                    ev_result = change_prd_charicteristic( ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
                  WHEN 'PLN'.
                    ev_result = change_pln_order( ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
                ENDCASE.
              ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 오류종료
                ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                RETURN.
              ENDIF.
            ENDLOOP.

*  이후공정 예약 자재 변경
            LOOP AT mt_resb INTO ls_resb.
              UPDATE resb SET   bdmng = ls_resb-bdmng
                                erfmg = ls_resb-erfmg
                          WHERE rsnum = ls_resb-rsnum
                            AND rspos = ls_resb-rspos
                            AND rsart = ls_resb-rsart.
              IF sy-subrc EQ 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
          IF mt_2010[] IS NOT INITIAL.
            REFRESH mt_2020_source.
            LOOP AT mt_2010 INTO ms_2010.
              APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
              APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
              MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        IF lines( mt_2020_source ) = 1.
          READ TABLE  mt_2020_source INTO ms_2020_source INDEX 1.

* LC계산이후 이후공정 예약 자재 수량 업데이트가 진행되므로 이후 공정이 복조장일시 전체 오더 수량을 체크해야한다.
          SELECT aufnr, posnr FROM afpo
            INTO TABLE @DATA(lt_afpo)
            WHERE aufnr = @ms_2020_source-ordnr.

          IF 1 = lines( lt_afpo ) OR 0 = lines( lt_afpo ). " 복조장이 아닐시 이후공정 자체만으로 비교
            REFRESH lt_headerdata.
            APPEND INITIAL LINE TO lt_headerdata.

            calc_lc(
            EXPORTING
              iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
              iv_gubun           = ms_2020_source-ordty
            IMPORTING
              ev_result        = ev_result
            CHANGING
              ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

            IF ev_result = 'F'.
              EXIT.
            ENDIF.

            IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
              lv_chk_she = abap_true.

              LOOP AT mt_2020_lc INTO ls_2020.
                lv_tabix = sy-tabix.
                READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
                IF lv_tabix = 1.
                  LOOP AT mt_2010 ASSIGNING <ls_2010>.
                    <ls_2010>-inlength = ls_2020-inlength.
                    <ls_2010>-infactor = 1.
                    <ls_2010>-qlength = ls_2020-qlength.
                    <ls_2010>-clength = ls_2020-clength.
                    <ls_2010>-slength = ls_2020-slength.
                    <ls_2010>-elength = ls_2020-elength.
                    <ls_2010>-adlength = ls_2020-adlength.
                    <ls_2010>-adtype = ls_2020-adtype.
                    MOVE-CORRESPONDING <ls_2010> TO ms_2010.

                    mv_total_plord_qty02 = ls_headerdata-total_plord_qty / ls_2020-infactor.
                    CASE <ls_2010>-ordty.
                      WHEN 'PRD'.
                        ev_result = change_prd_order( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                        ev_result = change_prd_charicteristic( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
                      WHEN 'PLN'.
                        ev_result = change_pln_order( ).
                        IF ev_result = 'E'.
                          ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                          RETURN.
                        ENDIF.
                    ENDCASE.
                  ENDLOOP.
                ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                  ev_result = 'E'.
                  ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                  RETURN.
                ENDIF.
              ENDLOOP.

            ELSE.
              LOOP AT mt_2020_lc INTO ls_2020.
                lv_tabix = sy-tabix.
                READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
                READ TABLE mt_2010 ASSIGNING <ls_2010>  INDEX lv_tabix.
                IF sy-subrc EQ 0.
                  <ls_2010>-inlength = ls_2020-inlength.
                  <ls_2010>-infactor = ls_2020-infactor.
                  <ls_2010>-qlength = ls_2020-qlength.
                  <ls_2010>-clength = ls_2020-clength.
                  <ls_2010>-slength = ls_2020-slength.
                  <ls_2010>-elength = ls_2020-elength.
                  <ls_2010>-adlength = ls_2020-adlength.
                  <ls_2010>-adtype = ls_2020-adtype.
                  MOVE-CORRESPONDING <ls_2010> TO ms_2010.
                  mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
                  CASE <ls_2010>-ordty.
                    WHEN 'PRD'.
                      ev_result = change_prd_order( ).
                      IF ev_result = 'E'.
                        ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                        RETURN.
                      ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                      ev_result = change_prd_charicteristic( ).
                      IF ev_result = 'E'.
                        ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                        RETURN.
                      ENDIF.
                    WHEN 'PLN'.
                      ev_result = change_pln_order( ).
                      IF ev_result = 'E'.
                        ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                        RETURN.
                      ENDIF.
                  ENDCASE.
                ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                  IF lines( mt_2010 ) = 1.
                    APPEND INITIAL LINE TO mt_2010 ASSIGNING <ls_2010>.
                    <ls_2010>-grpnr = ms_2020_source-grpnr.
                    <ls_2010>-ordty = 'PLN'.
                    <ls_2010>-dmord = ms_2020_source-ordnr.
                    <ls_2010>-dmline = ms_2020_source-posnr.
                    <ls_2010>-dmordty = ms_2020_source-ordty.
                    <ls_2010>-inlength = ls_2020-inlength.
                    <ls_2010>-infactor = ls_2020-infactor.
                    <ls_2010>-qlength = ls_2020-qlength.
                    <ls_2010>-clength = ls_2020-clength.
                    <ls_2010>-slength = ls_2020-slength.
                    <ls_2010>-elength = ls_2020-elength.
                    <ls_2010>-adlength = ls_2020-adlength.
                    <ls_2010>-adtype = ls_2020-adtype.
                    MOVE-CORRESPONDING <ls_2010> TO ms_2010.
                    mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
                    ev_result = create_pln_order( iv_matnr = iv_matnr ).
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
                    MOVE-CORRESPONDING ms_2010 TO <ls_2010>.
                  ELSE. "
                    IF ev_result = 'E'.
                      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                      RETURN.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ELSE.
            IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
              lv_chk_she = abap_true.
            ENDIF.

*                  이후공정이 복조장 일시 복조장 데이터 전부 읽어 데이터 확인
            get_chain_data(
              EXPORTING
                it_data      = mt_2010
              IMPORTING
                et_dev_data  = lt_2010_dev ).

            REFRESH lt_cal_2010.
            MOVE-CORRESPONDING lt_2010_dev TO lt_cal_2010.

* 이전 수정한 여장을 추가하기 위해 조회데이터에 변경적용
            LOOP AT lt_cal_2010 ASSIGNING <ls_cal_2010>.
              READ TABLE mt_2020_source INTO ms_2020_source WITH KEY  ordnr = <ls_cal_2010>-ordnr
                                                                      posnr = <ls_cal_2010>-posnr
                                                                      ordty = <ls_cal_2010>-ordty.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ms_2020_source TO <ls_cal_2010>.
              ENDIF.
            ENDLOOP.

            calc_lc_multy(
              EXPORTING
                iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
                iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j      " 검사여장
              IMPORTING
                ev_result        = ev_result
                et_return          = lt_result                 " 길이 1의 문자 필드
              CHANGING
                ct_2010_dev        = lt_cal_2010 ).

            IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
              EXIT.
            ENDIF.

            IF lt_result[] IS NOT INITIAL.
              READ TABLE lt_result INTO ls_result INDEX 1.
              ev_message = ls_result-message.
              RETURN.
            ENDIF.

            IF lv_chk_she IS NOT INITIAL.
              mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
            ELSE.
              mv_total_plord_qty02 = mv_total_plord_qty.
            ENDIF.

            LOOP AT mt_2010 ASSIGNING <ls_2010>.
              <ls_2010>-inlength = ms_2010_cal-inlength.
              IF lv_chk_she IS NOT INITIAL.
                <ls_2010>-infactor = 1.
              ELSE.
                <ls_2010>-infactor = ms_2010_cal-infactor.
              ENDIF.
              <ls_2010>-qlength = ms_2010_cal-qlength.
              <ls_2010>-clength = ms_2010_cal-clength.
              <ls_2010>-slength = ms_2010_cal-slength.
              <ls_2010>-elength = ms_2010_cal-elength.
              <ls_2010>-adlength = ms_2010_cal-adlength.
              <ls_2010>-adtype = ms_2010_cal-adtype.
              MOVE-CORRESPONDING <ls_2010> TO ms_2010.

              CASE <ls_2010>-ordty.
                WHEN 'PRD'.
                  ev_result = change_prd_order( ).
                  IF ev_result = 'E'.
                    ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                    RETURN.
                  ENDIF.

                WHEN 'PLN'.
                  ev_result = change_pln_order( ).
                  IF ev_result = 'E'.
                    ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                    RETURN.
                  ENDIF.
              ENDCASE.
            ENDLOOP.

          ENDIF.

        ELSE. " 이후 공정이 여러건일시 복조장 아닐시 계산 불가

          IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
            lv_chk_she = abap_true.
          ENDIF.

          IF lines( mt_2010 ) > 1 AND NOT line_exists( mt_2010[ gong_cd = 'SHE' ] ).
            ev_result = 'E'.
            ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
          ENDIF.

          REFRESH lt_chk_2020.
          lt_chk_2020 = mt_2020_source.
          SORT lt_chk_2020 BY ordnr.
          DELETE ADJACENT DUPLICATES FROM lt_chk_2020 COMPARING ordnr.

          IF lines( lt_chk_2020 ) NE 1.
            ev_result = 'E'.
            ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
            RETURN.
          ELSE. " 복조장 일시 오더소요량 변경, 이후공정 예약자재 수량 변경

            REFRESH lt_cal_2010.
            MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

            calc_lc_multy(
              EXPORTING
                iv_matnr           =  ls_infor_matnr-matnr                " 자재 번호
                iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
              IMPORTING
                ev_result        = ev_result
                et_return          = lt_result                 " 길이 1의 문자 필드
              CHANGING
                ct_2010_dev        = lt_cal_2010 ).

            IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
              EXIT.
            ENDIF.

            IF lt_result[] IS NOT INITIAL.
              READ TABLE lt_result INTO ls_result INDEX 1.
              ev_message = ls_result-message.
              RETURN.
            ENDIF.

            mv_total_plord_qty02 = mv_total_plord_qty.

            LOOP AT mt_2010 ASSIGNING <ls_2010>.
              <ls_2010>-inlength = ms_2010_cal-inlength.
              IF lv_chk_she IS NOT INITIAL.
                <ls_2010>-infactor = 1.
              ELSE.
                <ls_2010>-infactor = ms_2010_cal-infactor.
              ENDIF.
              <ls_2010>-qlength = ms_2010_cal-qlength.
              <ls_2010>-clength = ms_2010_cal-clength.
              <ls_2010>-slength = ms_2010_cal-slength.
              <ls_2010>-elength = ms_2010_cal-elength.
              <ls_2010>-adlength = ms_2010_cal-adlength.
              <ls_2010>-adtype = ms_2010_cal-adtype.
              MOVE-CORRESPONDING <ls_2010> TO ms_2010.

              CASE <ls_2010>-ordty.
                WHEN 'PRD'.
                  ev_result = change_prd_order( ).
                  IF ev_result = 'E'.
                    ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                    RETURN.
                  ENDIF.

                WHEN 'PLN'.
                  ev_result = change_pln_order( ).
                  IF ev_result = 'E'.
                    ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
                    RETURN.
                  ENDIF.
              ENDCASE.
            ENDLOOP.

          ENDIF.
        ENDIF.

*  이후공정 예약 자재 변경
        LOOP AT mt_resb INTO ls_resb.
          UPDATE resb SET   bdmng = ls_resb-bdmng
                            erfmg = ls_resb-erfmg
                      WHERE rsnum = ls_resb-rsnum
                        AND rspos = ls_resb-rspos
                        AND rsart = ls_resb-rsart.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDDO.
*&---------------------------------------------------------------------*
    progress_indicator( iv_percent = '100'  iv_text = '완료' ).
    APPEND LINES OF mt_2020 TO mt_2020_save.

  ENDMETHOD.


  METHOD get_chain_data.

    DATA : lt_temp_pre TYPE TABLE OF zgtppt2010.
    DATA : lt_data LIKE mt_2010.
    DATA : lv_chk_multy.
    DATA : lv_times TYPE i.


*__복조장 여부 확인.
    LOOP AT it_data INTO DATA(ls_data).
      SELECT aufnr, posnr FROM afpo
        INTO TABLE @DATA(lt_afpo)
        WHERE aufnr = @ls_data-ordnr.

      IF lines( lt_afpo ) > 1. "복조장
        lv_chk_multy = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.


*&---------------------------------------------------------------------*
* 1) 해당 오더의 이후공정 조회
*&---------------------------------------------------------------------*
    IF lv_chk_multy IS NOT INITIAL.
      SELECT b~*
        FROM @it_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                        AND b~ordnr = a~dmord
*                                                       AND B~POSNR = A~DMLINE
                                                        AND b~ordty = a~dmordty
        INTO CORRESPONDING FIELDS OF TABLE @et_dev_data.
*     이전 공정으로 현 오더가 등록되어 있는 공정 조회
      SELECT b~*
        FROM @it_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                        AND b~reord = a~ordnr
*                                                       AND B~RELINE = A~POSNR
                                                        AND b~reordty = a~ordty
        APPENDING CORRESPONDING FIELDS OF TABLE @et_dev_data.
    ELSE.
      SELECT b~*
        FROM @it_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                        AND b~ordnr = a~dmord
                                                        AND b~posnr = a~dmline
                                                        AND b~ordty = a~dmordty
        INTO CORRESPONDING FIELDS OF TABLE @et_dev_data.
*     이전 공정으로 현 오더가 등록되어 있는 공정 조회
      SELECT b~*
        FROM @it_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                        AND b~reord = a~ordnr
                                                        AND b~reline = a~posnr
                                                        AND b~reordty = a~ordty
        APPENDING CORRESPONDING FIELDS OF TABLE @et_dev_data.
    ENDIF.
    SORT et_dev_data BY ordnr posnr ordty.
    DELETE ADJACENT DUPLICATES FROM et_dev_data COMPARING ordnr posnr ordty.


*&---------------------------------------------------------------------*
* 2) 이전공정 조회
*   - 이전 공정에 대해 단계별로 조회 조회대상 없으면 종료
*   - LT_TEMP_PRE 기준으로 조회
*&---------------------------------------------------------------------*
    lt_temp_pre[] = it_data[].

    DO.
      ADD 1 TO lv_times.
      IF lv_chk_multy IS NOT INITIAL AND lv_times = 1.
*       해당 오더의 등록된 이전 공정 조회
        SELECT b~*
          FROM @lt_temp_pre AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                              AND b~ordnr = a~reord
*                                                             AND B~POSNR = A~RELINE
                                                              AND b~ordty = a~reordty
          APPENDING TABLE @DATA(lt_pre_data).
*       상위 오더로 해당 오더가 등록되어 있는 공정 추출
        SELECT b~*
          FROM @lt_temp_pre AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                              AND b~dmord = a~ordnr
*                                                             AND B~DMLINE = A~POSNR
                                                              AND b~dmordty = a~ordty
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_pre_data.
      ELSE.
*       해당 오더의 등록된 이전 공정 조회
        SELECT b~*
          FROM @lt_temp_pre AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                              AND b~ordnr = a~reord
                                                              AND b~posnr = a~reline
                                                              AND b~ordty = a~reordty
          APPENDING TABLE @lt_pre_data.
*       상위 오더로 해당 오더가 등록되어 있는 공정 추출
        SELECT b~*
          FROM @lt_temp_pre AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                              AND b~dmord = a~ordnr
                                                              AND b~dmline = a~posnr
                                                              AND b~dmordty = a~ordty
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_pre_data.
      ENDIF.

      IF lt_pre_data[] IS NOT INITIAL.
        APPEND LINES OF lt_pre_data TO et_pre_data.
        REFRESH lt_temp_pre.
        lt_temp_pre[] = lt_pre_data[].
        REFRESH lt_pre_data.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    SORT et_pre_data BY ordnr posnr ordty.
    DELETE ADJACENT DUPLICATES FROM et_pre_data COMPARING ordnr posnr ordty.


*&---------------------------------------------------------------------*
* 3) 현재 조장구성표에서 삭제나 변경되면 안되는 체인목록 조회
*   - 추출된 이전 공정들 기준으로 해당 공정의
*     상위 오더 확인하여 다른 연결이 있다면 제외 대상에 포함
*&---------------------------------------------------------------------*

*   대상 오더의 이후공정 조회
    SELECT b~*
      FROM @et_pre_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                          AND b~ordnr = a~dmord
                                                          AND b~posnr = a~dmline
                                                          AND b~ordty = a~dmordty
      INTO TABLE @DATA(lt_chk_data).
*   이전 공정으로 대상 오더가 등록되어 있는 공정 조회
    SELECT b~*
      FROM @et_pre_data AS a  INNER JOIN zgtppt2010 AS b  ON  b~grpnr = a~grpnr
                                                          AND b~reord = a~ordnr
                                                          AND b~reline = a~posnr
                                                          AND b~reordty = a~ordty
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_chk_data.

    SORT lt_chk_data BY ordnr posnr ordty.
    DELETE ADJACENT DUPLICATES FROM lt_chk_data COMPARING ordnr posnr ordty.

*  조회된 대상중 현재공정의 이전공정 체인에 없는 데이터만 남겨
*  남겨진 데이터의 체인 대상 추출
    LOOP AT lt_chk_data INTO DATA(ls_chk_data).
*     투입된 인풋과 비교
      READ TABLE it_data  TRANSPORTING NO FIELDS  WITH KEY  ordnr = ls_chk_data-ordnr
                                                            posnr = ls_chk_data-posnr
                                                            ordty = ls_chk_data-ordty.
      IF sy-subrc EQ 0.
        DELETE TABLE lt_chk_data FROM ls_chk_data.
        CONTINUE.
      ENDIF.

*     추출된 이전공정 체인과 비교
      READ TABLE et_pre_data  TRANSPORTING NO FIELDS  WITH KEY  ordnr = ls_chk_data-ordnr
                                                                posnr = ls_chk_data-posnr
                                                                ordty = ls_chk_data-ordty.
      IF sy-subrc EQ 0.
        DELETE TABLE lt_chk_data FROM ls_chk_data.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF lt_chk_data[] IS NOT INITIAL.
      LOOP AT et_pre_data INTO DATA(ls_pre_data).
        READ TABLE lt_chk_data  TRANSPORTING NO FIELDS  WITH KEY  ordnr = ls_pre_data-dmord
                                                                  posnr = ls_pre_data-dmline
                                                                  ordty = ls_pre_data-dmordty.
        IF sy-subrc EQ 0.
          APPEND ls_pre_data TO et_exception.
        ELSE.
          READ TABLE lt_chk_data  TRANSPORTING NO FIELDS  WITH KEY  reord = ls_pre_data-ordnr
                                                                    reline = ls_pre_data-posnr
                                                                    reordty = ls_pre_data-ordty.
          IF sy-subrc EQ 0.
            APPEND ls_pre_data TO et_exception.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD GET_METERIAL_BOM_QUAN.

    DATA : LT_STB TYPE TABLE OF STPOX.

    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        CAPID                 = 'PP01'
        DATUV                 = IV_DATE
        EMENG                 = IV_EMENG
        MTNRV                 = IV_MATNR " 자재
        WERKS                 = IV_PLANT " 플랜트
        MMORY                = '0'
      TABLES
        STB                   = LT_STB
      EXCEPTIONS
        ALT_NOT_FOUND         = 1
        CALL_INVALID          = 2
        MATERIAL_NOT_FOUND    = 3
        MISSING_AUTHORIZATION = 4
        NO_BOM_FOUND          = 5
        NO_PLANT_DATA         = 6
        NO_SUITABLE_BOM_FOUND = 7
        CONVERSION_ERROR      = 8
        OTHERS                = 9.

    READ TABLE LT_STB INTO DATA(LS_STB) WITH KEY IDNRK = IV_CHK_MATNR.

    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = '+'
        I_RUNIT     = 1
        I_VALUE     = LS_STB-MNGKO
      IMPORTING
        E_VALUE_RND = RV_MNGKO.
    .


  ENDMETHOD.


  METHOD GET_TARGET_INFOR.

    CHECK MV_TARGET_ORDER IS NOT INITIAL.
    REFRESH MT_2010_TARGET.
    SELECT * FROM ZGTPPT2010
      INTO CORRESPONDING FIELDS OF TABLE MT_2010_TARGET
    WHERE ORDNR = MV_TARGET_ORDER.

  ENDMETHOD.


  METHOD INIT_JOJANG.

    DATA : LS_2000 TYPE ZGTPPT2000.
    CLEAR : MS_2010, MS_2010_SOURCE, MS_2020, MS_2020_SOURCE.
*   상위 공정 세팅
    IF IV_ORDTY EQ 'SO'.
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF LS_2000
        FROM ZGTPPT2000
      WHERE GRPNR = MV_GRPNR
         AND ORDNO = IV_ORDER
         AND POSNR = IV_POSNR.

      MS_2020_SOURCE-ORDTY = 'SO'.
      MS_2020_SOURCE-INLENGTH = LS_2000-INLENGTH.
      MV_FINDATE = LS_2000-EDATU - 1.
      MS_2020_SOURCE-INFACTOR = 1.
      MS_2020_SOURCE-MATNR = LS_2000-MATNR.
    ELSE.
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF MS_2020_SOURCE
        FROM ZGTPPT2010
      WHERE GRPNR = MV_GRPNR
         AND ORDNR = IV_ORDER
         AND POSNR = IV_POSNR
         AND ORDTY = IV_ORDTY.
      IF SY-SUBRC NE 0.
        READ TABLE MT_2020 INTO MS_2020_SOURCE WITH KEY GRPNR = MV_GRPNR
                                                                              ORDNR = IV_ORDER
                                                                              POSNR = IV_POSNR
                                                                              ORDTY = IV_ORDTY.
      ENDIF.
    ENDIF.

*   현재 공정 준비
    MS_2020-GRPNR  = MV_GRPNR.
    MS_2020-DMORD = IV_ORDER.
    MS_2020-DMLINE = IV_POSNR.
    MS_2020-GONG_CD = IV_GONG_CD.
    MS_2020-DMORDTY = IV_ORDTY.

  ENDMETHOD.


  METHOD ORDER_RELEASE.

    DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LV_SUM_NUM TYPE I.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).


    LOOP AT IT_2010 INTO DATA(LS_2010).
*   판매오더에 연결된 생산오더 - 포장재 확인후 속성값 세팅
      IF LS_2010-DMORDTY = 'SO'.
        CHECK_PACK_SET_MENGE( IS_2010 = LS_2010 ).
      ENDIF.

      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
      <LS_ORDERS>-ORDER_NUMBER = LS_2010-ORDNR.
    ENDLOOP.

    WAIT UP TO 1 SECONDS.

    CALL FUNCTION 'BAPI_PRODORD_RELEASE'
      TABLES
        ORDERS        = LT_ORDERS
        DETAIL_RETURN = RT_ERR_ORDER.

    PROGRESS_INDICATOR( IV_PERCENT = '100'  IV_TEXT = '완료' ).

  ENDMETHOD.


  METHOD process_seperate.

    DATA : lt_next           TYPE TABLE OF zgtppt2010,
           lt_prev           TYPE TABLE OF zgtppt2010,
           lt_del_plnorder   TYPE mrpds_plono,
           lt_del_prdorder   TYPE bapi_order_key,
           lt_chg_orderchain TYPE zgtppt2010,
           lt_cal_2010       LIKE mt_2010_cal,
           lt_del_2010       TYPE TABLE OF zgtppt2010,
           lt_new_2010       TYPE TABLE OF zgtppt2010,
           lt_result         TYPE bapi_order_return_tt,
           lv_seqno          TYPE i,
           lt_headerdata     TYPE TABLE OF bapiplaf_i1,
           lv_return         TYPE char01.
*  오더생성 후 변경 형태로 진행
    DATA : ls_order        TYPE bapi_pp_order_create,
           ls_return       TYPE bapiret2,
           lv_order_number TYPE bapi_order_key-order_number,
           lv_percent      TYPE i,
           lv_sum_num      TYPE i,
           lv_tabix        TYPE i,
           lv_check        TYPE char01,
           lv_chk_multy    TYPE i,
           lt_multy_source LIKE mt_2020_source,
           lt_auart        LIKE mt_auart.

    lv_percent = 10.
    progress_indicator( iv_percent = lv_percent iv_text = '처리중..' ).


*   2026.04.29.zlsgpp5.CHM2604-00316.개별오더 전환시 오더유형 결정
    get_auart(
      EXPORTING
        it_2010   = it_2010
      IMPORTING
        et_auart  = lt_auart ).


*  선택된 오더 정보의 체인 구조 가져오기
    get_chain_data(
      EXPORTING
        it_data      = it_2010
      IMPORTING
        et_pre_data  = lt_prev
        et_dev_data  = lt_next ).


*  공정의 검사여장 정보 조회
    SELECT a~matnr, a~mtart, c~/sapmp/fix_as_j
      FROM @mt_main_seq_routing AS m
      INNER JOIN mara AS a  ON a~matnr = m~matnr
      INNER JOIN mapl AS b  ON b~matnr = a~matnr
      INNER JOIN plpo AS c  ON c~plnnr = b~plnnr
     WHERE b~werks = @mv_werks
       AND b~plnty = 'N'
       AND b~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~plnty = 'N'
       AND c~plnkn = '00000001'
      ORDER BY a~matnr
      INTO TABLE @DATA(lt_plpo).


* 선택된 공정의 복조장 해제.
*   - 선택된 공정의 체인 데이터 삭제후
*   - 이전 공정들에 대한 개별오더 생성
*   - 공정을 순차적으로 내리면서 개별 오더들 생성
    REFRESH : mt_plan_orders, mt_prd_orders.

    APPEND LINES OF it_2010 TO lt_del_2010. "선택 공정
    APPEND LINES OF lt_prev TO lt_del_2010. "이전 공정
    LOOP AT lt_del_2010 INTO DATA(ls_2010_del).
      CASE ls_2010_del-ordty.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO mt_plan_orders ASSIGNING FIELD-SYMBOL(<ls_plan_orders>).
          <ls_plan_orders> = ls_2010_del-ordnr.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO mt_prd_orders ASSIGNING FIELD-SYMBOL(<ls_prd_orders>).
          <ls_prd_orders>-order_number = ls_2010_del-ordnr.
      ENDCASE.
    ENDLOOP.

* 이후 공정 오더는 오더 삭제대상 아님, 체인테이블만 삭제후 재구성
    APPEND LINES OF lt_next TO lt_del_2010.

    MOVE-CORRESPONDING lt_next TO mt_2020_source.
    READ TABLE mt_2020_source INTO ms_2020_source INDEX 1.

    READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY matnr = ms_2020_source-matnr.
    lv_seqno = ms_main_seq_routing-seqno.

    lv_sum_num = 60 / ( lines( it_2010 ) * ( lines( mt_main_seq_routing ) - lv_seqno ) ).


*----------------------------------------------------------------------*
*   해당오더 이후공정이 없을경우 현재 공정이 완제품이라는 의미 현재 공정에 대해 구성
*----------------------------------------------------------------------*
    IF mt_2020_source[] IS INITIAL.
      LOOP AT it_2010 INTO DATA(ls_2010).

*/s     2026.04.29.zlsgpp5.CHM2604-00316.개별오더 전환시 오더유형 결정
*         lt_auart-ordnr 값이 변하므로 binary search 하면 안됨.
        READ TABLE lt_auart ASSIGNING FIELD-SYMBOL(<ls_auart>)
                            WITH KEY ordnr = ls_2010-ordnr
                                     posnr = ls_2010-posnr.
        IF sy-subrc EQ 0.
          IF <ls_auart>-auart EQ 'RP01'.
            mv_auart = <ls_auart>-auart.
          ELSEIF <ls_auart>-last_auart EQ 'PP05'.
            mv_auart = 'PP01'.
          ELSE.
            mv_auart = <ls_auart>-last_auart.
          ENDIF.
        ENDIF.
*/e     2026.04.29.zlsgpp5.CHM2604-00316.

        READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY matnr = ls_2010-matnr.
        lv_seqno = ms_main_seq_routing-seqno.
        READ TABLE lt_plpo INTO DATA(ls_plpo) WITH KEY matnr = ms_main_seq_routing-matnr.


*  오더 생성
        ls_order-material = ls_plpo-matnr.
        ls_order-plant = mv_werks.
        ls_order-order_type = mv_auart.

        SELECT SINGLE edatu FROM zgtppt2000
          INTO @DATA(lv_edatu)
         WHERE grpnr = @ls_2010-grpnr
           AND ordno = @ls_2010-dmord
           AND posnr = @ls_2010-dmline.

        mv_findate = lv_edatu - 1.

        ls_order-basic_start_date = mv_findate.
        ls_order-basic_end_date = mv_findate.
        ls_order-quantity = ( ( ls_2010-inlength + ls_plpo-/sapmp/fix_as_j ) * ls_2010-infactor ).
        ls_order-basic_scheduling_type = '3'.

        CALL FUNCTION 'BAPI_PRODORD_CREATE'
          EXPORTING
            orderdata    = ls_order
          IMPORTING
            return       = ls_return
            order_number = lv_order_number.

*  복조장 구성 BDC
        IF ls_return-type NE 'E'.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
          DO .
            SELECT SINGLE aufnr, posnr
              FROM afpo
             WHERE aufnr = @lv_order_number
              INTO @DATA(ls_afpo).
            IF sy-subrc EQ 0.
              EXIT.
            ELSE.
              WAIT UP TO '0.5' SECONDS.
            ENDIF.
          ENDDO.

        ELSE.
          APPEND INITIAL LINE TO rt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
          CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'
                INTO <ls_result>-message SEPARATED BY space.
          RETURN.
        ENDIF.


* 현재 공정 체인데이터 세팅
        APPEND INITIAL LINE TO mt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
        MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        <ls_2010>-grpnr    = mv_grpnr.
        <ls_2010>-gong_cd = ms_main_seq_routing-chart.
        <ls_2010>-ordnr = lv_order_number.
        <ls_2010>-posnr = 1 + 0.
        <ls_2010>-ordty = 'PRD'.
        <ls_2010>-matnr = ms_main_seq_routing-matnr.
        <ls_2010>-inlength = ls_2010-inlength.
        <ls_2010>-infactor = 1.
        <ls_2010>-qlength = ls_plpo-/sapmp/fix_as_j.

* 2026.04.29.zlsgpp5.CHM2604-00316.최상위 오더유형을 찾기위해 생성된 오더번호를 입력.
        <ls_auart>-ordnr = <ls_2010>-ordnr.
        <ls_auart>-posnr = <ls_2010>-posnr.

      ENDLOOP.

      REFRESH mt_2020_source.
      LOOP AT mt_2010 INTO ms_2010.
        APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_2020_source>).
        MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
      ENDLOOP.

    ENDIF.


*----------------------------------------------------------------------*
*   최초 오더 생성 시작지점 찾기
*----------------------------------------------------------------------*
    DO.
      MOVE-CORRESPONDING mt_2020_source TO mt_2020.

      IF lv_check = 'F'.
        EXIT.
      ENDIF.

      ADD 1 TO lv_seqno.
      READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY seqno = lv_seqno.
      IF sy-subrc EQ 0.
        IF ms_main_seq_routing-maabc = 'B'. " ABC 지시자가 B라면 다음으로 공정에 포함안됨
          CONTINUE.
        ENDIF.
      ELSE. " 조회 대상 없을시 완료
        LOOP AT mt_2010 INTO ms_2010.
          APPEND INITIAL LINE TO mt_2020_save ASSIGNING FIELD-SYMBOL(<ls_2020_save>).
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
        ENDLOOP.
        EXIT.
      ENDIF.

      READ TABLE lt_plpo INTO ls_plpo WITH KEY matnr = ms_main_seq_routing-matnr.

      REFRESH mt_2010.
      DATA(lt_2020_source_re) = mt_2020_source.
      SORT lt_2020_source_re BY ordnr.
      DELETE ADJACENT DUPLICATES FROM lt_2020_source_re COMPARING ordnr.


      LOOP AT lt_2020_source_re INTO ms_2020_source.

*/s     2026.04.29.zlsgpp5.CHM2604-00316.개별오더 전환시 오더유형 결정
*         처음에는 이전오더번호로 찾고 이후부터는 생성된 오더번호로 찾음.
*         lt_auart-ordnr 값이 변하므로 binary search 하면 안됨.
        READ TABLE lt_auart ASSIGNING <ls_auart>
                            WITH KEY ordnr = ms_2020_source-reord
                                     posnr = ms_2020_source-reline.
        IF sy-subrc NE 0.
          READ TABLE lt_auart ASSIGNING <ls_auart>
                              WITH KEY ordnr = ms_2020_source-ordnr
                                       posnr = ms_2020_source-posnr.
        ENDIF.
        IF sy-subrc EQ 0.
          IF <ls_auart>-auart EQ 'RP01'.
            mv_auart = <ls_auart>-auart.
          ELSEIF <ls_auart>-last_auart EQ 'PP05'.
            mv_auart = 'PP01'.
          ELSE.
            mv_auart = <ls_auart>-last_auart.
          ENDIF.
        ENDIF.
*/e     2026.04.29.zlsgpp5.CHM2604-00316.

        IF ms_main_seq_routing-seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
          REFRESH lt_headerdata.
          CLEAR lv_check.
          APPEND INITIAL LINE TO lt_headerdata.
          calc_lc(
            EXPORTING
              iv_matnr           =  ls_plpo-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_plpo-/sapmp/fix_as_j     " 계획된 스크랩 수량
              iv_gubun           = ms_2020_source-ordty
            IMPORTING
              ev_result             = lv_check
            CHANGING
              ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

          IF lv_check = 'F'.
*      현재 공정 생성 완료후 이후 공정 저장 테이블로 모디
            APPEND INITIAL LINE TO mt_2020_save ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2020_source TO <ls_2020_save>.
            CONTINUE.
          ENDIF.

          READ TABLE mt_2020_lc INTO DATA(ls_2010_lc) INDEX 1.
*        쉬스공정 이후 공정의 봄 자재 수량이 1보다 크면 쉬스를 자재별로 생성
          IF ls_2010_lc-infactor > 1.

            ADD lv_sum_num TO lv_percent.
            progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).
            CLEAR lv_tabix.
            DO ls_2010_lc-infactor TIMES.
              ADD 1 TO lv_tabix.
              CLEAR : ls_order.
*  오더 생성
              ls_order-material = ls_plpo-matnr.
              ls_order-plant = mv_werks.
              ls_order-order_type = mv_auart.
              ls_order-basic_start_date = mv_findate.
              ls_order-basic_end_date = mv_findate.
              ls_order-quantity = mv_total_plord_qty / ls_2010_lc-infactor.
              ls_order-basic_scheduling_type = '3'.

              CALL FUNCTION 'BAPI_PRODORD_CREATE'
                EXPORTING
                  orderdata    = ls_order
                IMPORTING
                  return       = ls_return
                  order_number = lv_order_number.

*  복조장 구성 BDC
              IF ls_return-type NE 'E'.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = abap_true.

*               커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
                DO .
                  SELECT SINGLE aufnr, posnr
                    FROM afpo
                   WHERE aufnr = @lv_order_number
                    INTO @ls_afpo.
                  IF sy-subrc EQ 0.
                    EXIT.
                  ELSE.
                    WAIT UP TO '0.5' SECONDS.
                  ENDIF.
                ENDDO.

              ELSE.
                APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
                CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'
                       INTO <ls_result>-message SEPARATED BY space.
                RETURN.
              ENDIF.

* 현재 공정 체인데이터 세팅
              APPEND INITIAL LINE TO mt_2010 ASSIGNING <ls_2010>.
              <ls_2010>-grpnr = mv_grpnr.
              <ls_2010>-gong_cd = ms_main_seq_routing-chart.
              <ls_2010>-ordnr = lv_order_number.
              <ls_2010>-posnr = 1 + 0.
              <ls_2010>-ordty = 'PRD'.
              <ls_2010>-matnr = ms_main_seq_routing-matnr.
              <ls_2010>-dmord = ms_2020_source-ordnr.
              <ls_2010>-dmline = ms_2020_source-posnr.
              <ls_2010>-dmordty = ms_2020_source-ordty.
              <ls_2010>-inlength = ls_2010_lc-inlength.
              <ls_2010>-infactor = 1.
              <ls_2010>-qlength = ls_2010_lc-qlength.
              <ls_2010>-clength = ls_2010_lc-clength.
              <ls_2010>-slength = ls_2010_lc-slength.
              <ls_2010>-elength = ls_2010_lc-elength.

              IF lv_tabix = 1.
                ms_2020_source-reord = lv_order_number.
                ms_2020_source-reline = 1 + 0.
                ms_2020_source-reordty = 'PRD'.
              ENDIF.

* 2026.04.29.zlsgpp5.CHM2604-00316.최상위 오더유형을 찾기위해 생성된 오더번호를 입력.
              <ls_auart>-ordnr = <ls_2010>-ordnr.
              <ls_auart>-posnr = <ls_2010>-posnr.

* 특성값 세팅
              set_prd_charicteristic(
                EXPORTING
                  is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
                IMPORTING
                  ev_result = lv_return ).                " 길이 1의 문자 필드

              IF lv_return = 'E'.
                APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
                CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'
                       INTO <ls_result>-message SEPARATED BY space.
                RETURN.
              ENDIF.

*  이후공정 예약 자재 변경
              LOOP AT mt_resb INTO DATA(ls_resb).
                UPDATE resb SET   bdmng = ls_resb-bdmng
                                  erfmg = ls_resb-erfmg
                            WHERE rsnum = ls_resb-rsnum
                              AND rspos = ls_resb-rspos
                              AND rsart = ls_resb-rsart.
                IF sy-subrc EQ 0.
                  COMMIT WORK AND WAIT.
                ELSE.
                  ROLLBACK WORK.
                  EXIT.
                ENDIF.
              ENDLOOP.

            ENDDO.
*      현재 공정 생성 완료후 이후 공정 저장 테이블로 모디
            APPEND INITIAL LINE TO mt_2020_save ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2020_source TO <ls_2020_save>.

            CONTINUE.
          ENDIF.

        ENDIF.

        ADD lv_sum_num TO lv_percent.
        progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

        CLEAR lv_chk_multy.
        REFRESH lt_multy_source.
        LOOP AT mt_2020_source INTO DATA(ls_2020_source) WHERE ordnr = ms_2020_source-ordnr.
          ADD 1 TO lv_chk_multy.
          APPEND ls_2020_source TO lt_multy_source.
        ENDLOOP.

        IF lv_chk_multy = 1.

          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.
          CLEAR lv_check.
          calc_lc(
          EXPORTING
            iv_matnr           = ls_plpo-matnr            " 자재 번호
            iv_fixed_scrap_qty = ls_plpo-/sapmp/fix_as_j  " 계획된 스크랩 수량
            iv_gubun           = ms_2020_source-ordty
          IMPORTING
            ev_result          = lv_check
          CHANGING
            ct_headerdata      = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

          IF lv_check = 'F'.
*      현재 공정 생성 완료후 이후 공정 저장 테이블로 모디
            APPEND INITIAL LINE TO mt_2020_save ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2020_source TO <ls_2020_save>.
            CONTINUE.
          ENDIF.

*  오더 생성
          ls_order-material = ls_plpo-matnr.
          ls_order-plant = mv_werks.
          ls_order-order_type = mv_auart.
          ls_order-basic_start_date = mv_findate.
          ls_order-basic_end_date = mv_findate.
          ls_order-quantity = mv_total_plord_qty.
          ls_order-basic_scheduling_type = '3'.

          CALL FUNCTION 'BAPI_PRODORD_CREATE'
            EXPORTING
              orderdata    = ls_order
            IMPORTING
              return       = ls_return
              order_number = lv_order_number.

*  복조장 구성 BDC
          IF ls_return-type NE 'E'.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
            DO .
              SELECT SINGLE aufnr, posnr
                FROM afpo
               WHERE aufnr = @lv_order_number
                INTO @ls_afpo.
              IF sy-subrc EQ 0.
                EXIT.
              ELSE.
                WAIT UP TO '0.5' SECONDS.
              ENDIF.
            ENDDO.

          ELSE.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

* 현재 공정 체인데이터 세팅
          APPEND INITIAL LINE TO mt_2010 ASSIGNING <ls_2010>.
          <ls_2010>-grpnr   = mv_grpnr.
          <ls_2010>-gong_cd = ms_main_seq_routing-chart.
          <ls_2010>-ordnr   = lv_order_number.
          <ls_2010>-posnr   = 1 + 0.
          <ls_2010>-ordty   = 'PRD'.
          <ls_2010>-matnr   = ms_main_seq_routing-matnr.
          <ls_2010>-dmord   = ms_2020_source-ordnr.
          <ls_2010>-dmline  = ms_2020_source-posnr.
          <ls_2010>-dmordty = ms_2020_source-ordty.

          READ TABLE mt_2020_lc INTO ls_2010_lc INDEX 1.
          <ls_2010>-inlength  = ls_2010_lc-inlength.
          <ls_2010>-infactor  = ls_2010_lc-infactor.
          <ls_2010>-qlength   = ls_2010_lc-qlength.
          <ls_2010>-clength   = ls_2010_lc-clength.
          <ls_2010>-slength   = ls_2010_lc-slength.
          <ls_2010>-elength   = ls_2010_lc-elength.

          ms_2020_source-reord = lv_order_number.
          ms_2020_source-reline = 1 + 0.
          ms_2020_source-reordty = 'PRD'.

* 2026.04.29.zlsgpp5.CHM2604-00316.최상위 오더유형을 찾기위해 생성된 오더번호를 입력.
          <ls_auart>-ordnr = <ls_2010>-ordnr.
          <ls_auart>-posnr = <ls_2010>-posnr.

* 특성값 세팅
          set_prd_charicteristic(
            EXPORTING
              is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
            IMPORTING
              ev_result = lv_return ).                " 길이 1의 문자 필드

          IF lv_return = 'E'.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'
                   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO ls_resb.
            UPDATE resb SET   bdmng = ls_resb-bdmng
                              erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

*      현재 공정 생성 완료후 이후 공정 저장 테이블로 모디
          APPEND INITIAL LINE TO mt_2020_save ASSIGNING <ls_2020_save>.
          MOVE-CORRESPONDING ms_2020_source TO <ls_2020_save>.
        ELSE.

          REFRESH lt_cal_2010.
          MOVE-CORRESPONDING lt_multy_source TO lt_cal_2010.

          calc_lc_multy(
            EXPORTING
              iv_matnr           =  ls_plpo-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_plpo-/sapmp/fix_as_j                 " 검사여장
              iv_chk_merge      = 'X'                 " 추가여장
            IMPORTING
              ev_result              = lv_check
              et_return          = lt_result                 " 길이 1의 문자 필드
            CHANGING
              ct_2010_dev        = lt_cal_2010 ).

          IF lv_check = 'F'.
            RETURN.
          ENDIF.

          IF lt_result[] IS NOT INITIAL.
            APPEND LINES OF lt_result TO rt_result.
            RETURN.
          ENDIF.

*  오더생성 후 변경 형태로 진행
*  오더 생성
          CLEAR : ls_order, ls_return, lv_order_number.
          ls_order-material = ls_plpo-matnr.
          ls_order-plant = mv_werks.
          ls_order-order_type = mv_auart.
          ls_order-basic_start_date = mv_findate.
          ls_order-basic_end_date = mv_findate.
          ls_order-quantity = mv_total_plord_qty.

          CALL FUNCTION 'BAPI_PRODORD_CREATE'
            EXPORTING
              orderdata    = ls_order
            IMPORTING
              return       = ls_return
              order_number = lv_order_number.

*  복조장 구성 BDC
          IF ls_return-type NE 'E'.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
            DO .
              SELECT SINGLE aufnr, posnr
                FROM afpo
               WHERE aufnr = @lv_order_number
                INTO @ls_afpo.
              IF sy-subrc EQ 0.
                EXIT.
              ELSE.
                WAIT UP TO '0.5' SECONDS.
              ENDIF.
            ENDDO.

          ELSE.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            <ls_result>-message = '개별오더 전환 중 오류 발생하였습니다.'.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO mt_2010 ASSIGNING <ls_2010>.
          <ls_2010>-grpnr    = mv_grpnr.
          <ls_2010>-gong_cd = ms_main_seq_routing-chart.
          <ls_2010>-ordnr = lv_order_number.
          <ls_2010>-posnr = 1 + 0.
          <ls_2010>-ordty = 'PRD'.
          <ls_2010>-matnr = ms_main_seq_routing-matnr.
          <ls_2010>-dmord = ms_2020_source-ordnr.
          <ls_2010>-dmline = 1.
          <ls_2010>-dmordty = ms_2020_source-ordty.

          READ TABLE mt_2020_lc INTO ls_2010_lc INDEX 1.
          <ls_2010>-inlength = ms_2010_cal-inlength.
          <ls_2010>-infactor = ms_2010_cal-infactor.
          <ls_2010>-qlength = ms_2010_cal-qlength.
          <ls_2010>-clength = ms_2010_cal-clength.
          <ls_2010>-slength = ms_2010_cal-slength.
          <ls_2010>-elength = ms_2010_cal-elength.

          LOOP AT lt_multy_source ASSIGNING FIELD-SYMBOL(<ms_2020_source>).
            <ms_2020_source>-reord = lv_order_number.
            <ms_2020_source>-reline = 1 + 0.
            <ms_2020_source>-reordty = 'PRD'.
          ENDLOOP.

* 2026.04.29.zlsgpp5.CHM2604-00316.최상위 오더유형을 찾기위해 생성된 오더번호를 입력.
          <ls_auart>-ordnr = <ls_2010>-ordnr.
          <ls_auart>-posnr = <ls_2010>-posnr.

* 특성값 세팅
          set_prd_charicteristic(
            EXPORTING
              is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
            IMPORTING
              ev_result = lv_return ).                " 길이 1의 문자 필드

          IF lv_return = 'E'.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO ls_resb.
            UPDATE resb SET bdmng = ls_resb-bdmng
                            erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

*      현재 공정 생성 완료후 이후 공정 저장 테이블로 모디
          LOOP AT lt_multy_source ASSIGNING <ms_2020_source>.
            APPEND INITIAL LINE TO mt_2020_save ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING <ms_2020_source> TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.

      ENDLOOP.


* CHAIN 변경 데이터 옮겨준다.
      IF mt_2010[] IS NOT INITIAL.
        REFRESH mt_2020_source.
        LOOP AT mt_2010 INTO ms_2010.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
        ENDLOOP.
      ENDIF.

    ENDDO.

*----------------------------------------------------------------------*
*  복조장 구성 완료, 체인테이블 구성
*----------------------------------------------------------------------*
    IF lt_del_2010[] IS NOT INITIAL.
      DELETE zgtppt2010 FROM TABLE lt_del_2010.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    IF mt_2020_save[] IS NOT INITIAL.

      DATA : lt_zpptc002 TYPE TABLE OF zpptc002.
      LOOP AT mt_2020_save INTO DATA(ls_2020_save).
*    오더 검사여장 시료여장 업데이트
        IF ls_2020_save-ordty = 'PRD'.
          APPEND INITIAL LINE TO lt_zpptc002 ASSIGNING FIELD-SYMBOL(<ls_save_data>).
          <ls_save_data>-aufnr = ls_2020_save-ordnr.
          <ls_save_data>-posnr = ls_2020_save-posnr+2(4).
          <ls_save_data>-psamg = ls_2020_save-qlength.
          IF ls_2020_save-adtype = 'A'.
            <ls_save_data>-psmng = ls_2020_save-adlength.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lt_zpptc002[] IS NOT INITIAL.
        MODIFY zpptc002 FROM TABLE lt_zpptc002.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING mt_2020_save TO mt_2010_target.
      MODIFY zgtppt2010 FROM TABLE mt_2010_target.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.


*----------------------------------------------------------------------*
* 계획오더 삭제
*----------------------------------------------------------------------*
    IF mt_plan_orders[] IS NOT INITIAL.
      LOOP AT mt_plan_orders INTO DATA(lv_plnum).
        lv_return = dele_pln_order( iv_plannedorder = lv_plnum ).
      ENDLOOP.
    ENDIF.

*----------------------------------------------------------------------*
* 생산오더 삭제 플레그
*----------------------------------------------------------------------*
    IF mt_prd_orders[] IS NOT INITIAL.
      LOOP AT mt_prd_orders INTO DATA(ls_aufnr).
        lv_return = dele_prd_order( iv_aufnr = ls_aufnr-order_number ).
      ENDLOOP.
    ENDIF.


    progress_indicator( iv_percent = '100'  iv_text = '완료' ).

  ENDMETHOD.


  METHOD PROC_JOJANG.


    IF MS_2020_SOURCE-ORDTY = 'SO'. "최상단 공정으로 저장 안함 하위 맵핑 없음
      APPEND LINES OF MT_2020_LC TO MT_2020.
    ELSE.
      APPEND LINES OF MT_2020_LC TO MT_2020.

      LOOP AT MT_2020_LC INTO MS_2020.
        IF SY-TABIX = 1.
          READ TABLE MT_2020 ASSIGNING FIELD-SYMBOL(<LS_2020>)
                                        WITH KEY GRPNR = MS_2020_SOURCE-GRPNR
                                                   GONG_CD = MS_2020_SOURCE-GONG_CD
                                                   ORDNR = MS_2020_SOURCE-ORDNR
                                                   POSNR = MS_2020_SOURCE-POSNR
                                                   ORDTY = MS_2020_SOURCE-ORDTY.

          IF SY-SUBRC EQ 0.
            <LS_2020>-REORD = MS_2020-ORDNR.
            <LS_2020>-RELINE = MS_2020-POSNR.
            <LS_2020>-REORDTY = MS_2020-ORDTY.
          ELSE.
            MS_2020_SOURCE-REORD = MS_2020-ORDNR.
            MS_2020_SOURCE-RELINE = MS_2020-POSNR.
            MS_2020_SOURCE-REORDTY = MS_2020-ORDTY.
            MS_2020_SOURCE-AENAM = SY-UNAME.
            MS_2020_SOURCE-AEDAT = SY-DATUM.
            APPEND MS_2020_SOURCE TO MT_2020_SAVE.
          ENDIF.
        ENDIF..

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD proc_make_plan_order.

    DATA : ls_headerdata TYPE bapiplaf_i1.
    DATA : lt_headerdata TYPE TABLE OF bapiplaf_i1.
    DATA : lv_plannedorder TYPE bapi_pldord-pldord_num.
    DATA : ls_return TYPE bapireturn1.
    DATA : lv_vbeln TYPE vbeln.
    DATA : lv_plnum TYPE plnum.
    DATA : lv_aufnr TYPE aufnr.
    DATA : ls_2000 TYPE zgtppt2000.
    DATA : lv_findate TYPE sy-datum. " 공정종료일
    DATA : lv_matnr TYPE matnr.
    DATA : lt_resb LIKE mt_resb.
    DATA : lt_2010_del TYPE TABLE OF zgtppt2010.

    CLEAR mv_total_plord_qty.

    READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY chart = iv_gong_cd " 공정코드로 자재정보 가져온다.
                                                                     matnr = iv_matnr.

    SELECT SINGLE a~matnr, a~mtart, c~/sapmp/fix_as_j
      FROM mara AS a  INNER JOIN mapl AS b  ON b~matnr = a~matnr
                      INNER JOIN plpo AS c  ON c~plnnr = b~plnnr
     WHERE a~matnr = @ms_main_seq_routing-matnr
       AND b~werks = @mv_werks
       AND b~plnty = 'N'
       AND b~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~plnty = 'N'
       AND c~plnkn = '00000001'
       INTO @DATA(ls_infor_matnr).

* 상위오더 정보 세팅
    init_jojang(
      iv_order   = iv_order                 " 오더번호
      iv_posnr   = iv_posnr                 " 판매 문서 항목
      iv_ordty   = iv_ordty                 " 오더유형
      iv_gong_cd = iv_gong_cd                 " 공정코드
    ).

    ms_2020-matnr = ms_main_seq_routing-matnr.

* 계획 오더 생성을 위한 정보 세팅
* 완제품 자재유형(MARA-MTART = 'MCFE') 'KD' 그 외, 'LA'
    CASE ls_infor_matnr-mtart.
      WHEN 'MCFE'.
        ls_headerdata-pldord_profile = 'KD'.
      WHEN OTHERS.
        ls_headerdata-pldord_profile  = 'LA'.
    ENDCASE.
*  현재 공정 자재
    ls_headerdata-material = ms_main_seq_routing-matnr.
*   조장구성 플랜트
    ls_headerdata-plan_plant = mv_werks.
    ls_headerdata-prod_plant = mv_werks.
*  검사 여장
*    LS_HEADERDATA-FIXED_SCRAP_QTY = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
*  확정
    ls_headerdata-firming_ind = 'X'.
*  일정 계획 수립
    ls_headerdata-det_schedule = 'X'.

    APPEND ls_headerdata TO lt_headerdata.

    REFRESH mt_2020_lc.

    CASE iv_ordty.
      WHEN 'SO'.
        READ TABLE lt_headerdata ASSIGNING FIELD-SYMBOL(<ls_headerdata>) INDEX 1.
* 조장
        <ls_headerdata>-total_plord_qty = ms_2020_source-inlength + ls_infor_matnr-/sapmp/fix_as_j.
* 계산된 종료일(문서 종료일 -1)
        <ls_headerdata>-order_fin_date = mv_findate.
*  현재 완제품 자재 유형인 경우, 후 공정 판매 오더
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = iv_order
          IMPORTING
            output = lv_vbeln.
        <ls_headerdata>-sales_ord = lv_vbeln.
*   현재 완제품 자재 유형인 경우, 후 공정 판매 오더 품목
        <ls_headerdata>-s_ord_item = iv_posnr.

* 현재 정보 저장(SO와 동일, 검사여장만 추가)
        ms_2020-inlength = ms_2020_source-inlength.
        ms_2020-qlength = ls_infor_matnr-/sapmp/fix_as_j.
        ms_2020-infactor = ms_2020_source-infactor.

        APPEND ms_2020 TO mt_2020_lc.

      WHEN 'PLN' OR 'PRD'.
        calc_lc(
        EXPORTING
          iv_matnr           =  ms_main_seq_routing-matnr                " 자재 번호
          iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
          iv_gubun           = iv_ordty                 " 문자 필드(길이 5)
        IMPORTING
          ev_result         = ev_result
        CHANGING
          ct_headerdata = lt_headerdata
        ).

        IF ev_result = 'F'.
          RETURN.
        ENDIF.

        IF ev_result = 'E'.
          RETURN.
        ENDIF.

      WHEN 'PO'. "차후적용

      WHEN 'PR'.  " 차후적용

    ENDCASE.

    IF ms_main_seq_routing-chart = 'SHE' AND ms_main_seq_routing-seqno NE 1.
      lt_resb = VALUE #( FOR ws_resb IN mt_resb WHERE ( matnr = ms_main_seq_routing-matnr ) ( CORRESPONDING  #( ws_resb ) ) ).
      IF lines( lt_resb ) > 1.
        ev_chk_she = abap_true.
        READ TABLE lt_headerdata INTO ls_headerdata INDEX 1.
        REFRESH lt_headerdata.

        ls_headerdata-total_plord_qty = ls_headerdata-total_plord_qty / lines( lt_resb ).

        READ TABLE mt_2020_lc INTO DATA(ls_2020) INDEX 1.
        REFRESH mt_2020_lc.
        ls_2020-infactor = 1.

        DO lines( lt_resb ) TIMES.
          APPEND ls_headerdata TO lt_headerdata.
          APPEND ls_2020 TO mt_2020_lc.
        ENDDO.

      ENDIF.
    ENDIF.

    LOOP AT lt_headerdata INTO  ls_headerdata.

      READ TABLE mt_2020_lc ASSIGNING FIELD-SYMBOL(<ls_2020>)  INDEX sy-tabix.

      CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
        EXPORTING
          headerdata   = ls_headerdata
        IMPORTING
          return       = ls_return
          plannedorder = lv_plannedorder.

      IF ls_return-type NE 'S'. "성공건에 대해 후행 로직 진행

        DATA : lv_i_inlength TYPE i.
        DATA : lv_c_inlength TYPE c LENGTH 10.

        ev_result = 'E'.
        SELECT SINGLE gong_nm
          INTO ev_message
          FROM zedt0011
          WHERE gong_cd = <ls_2020>-gong_cd.

        lv_i_inlength = ms_2020_source-inlength.
        lv_c_inlength = lv_i_inlength.
        CONDENSE lv_c_inlength.

        CONCATENATE ev_message lv_c_inlength '계획 오더 생성 중 오류가 발생했습니다.' INTO ev_message SEPARATED BY space.

        IF mt_2020[] IS NOT INITIAL.
          MOVE-CORRESPONDING mt_2020 TO lt_2010_del.
          rollback_created_order( it_2010 = lt_2010_del ).
        ENDIF.
        RETURN.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.

**      SELECT A~*, @SY-UZEIT AS ERZET
**        FROM PLAF AS A
**        APPENDING CORRESPONDING FIELDS OF TABLE @MT_PLAF
**       WHERE PLNUM = @LV_PLANNEDORDER.

      <ls_2020>-ordnr = lv_plannedorder.
      <ls_2020>-ordty = 'PLN'.

*** 계획오더정보 조회
      DATA : lt_capacitydata1 TYPE TABLE OF bapi_pldordcapa_e1.
      DATA : lt_componentsdata TYPE TABLE OF bapi_pldordcomp_e1.

      CALL FUNCTION 'BAPI_PLANNEDORDER_GET_DETAIL'
        EXPORTING
          plannedorder   = lv_plannedorder
        TABLES
          componentsdata = lt_componentsdata
          capacitydata1  = lt_capacitydata1.

* 리턴된 생산 일정으로 계획 오더 시작 및 종료일 수정
      DATA : ls_header TYPE bapiplaf_i2.
      DATA : ls_headerx TYPE bapiplaf_i2x.

      SORT lt_capacitydata1 BY start_date.
      READ TABLE lt_capacitydata1 INTO DATA(ls_capacitydata1) INDEX 1.
      ls_header-order_start_date = ls_capacitydata1-start_date.

      SORT lt_capacitydata1 BY fin_date DESCENDING.
      READ TABLE lt_capacitydata1 INTO ls_capacitydata1 INDEX 1.
      ls_header-order_fin_date = ls_capacitydata1-fin_date.

      ls_headerx-order_start_date = 'X'.
      ls_headerx-order_fin_date = 'X'.

      CLEAR ls_return.

      CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
        EXPORTING
          plannedorder = lv_plannedorder
          headerdata   = ls_header
          headerdatax  = ls_headerx
        IMPORTING
          return       = ls_return.
      IF ls_return-type NE 'S'. "성공건에 대해 후행 로직 진행

        ev_result = 'E'.
        SELECT SINGLE gong_nm
          INTO ev_message
          FROM zedt0011
          WHERE gong_cd = <ls_2020>-gong_cd.

        lv_i_inlength = ms_2020_source-inlength.
        lv_c_inlength = lv_i_inlength.
        CONDENSE lv_c_inlength.

        CONCATENATE ev_message lv_c_inlength '계획 오더 생성 중 오류가 발생했습니다.' INTO ev_message SEPARATED BY space.
        IF mt_2020[] IS NOT INITIAL.
          MOVE-CORRESPONDING mt_2020 TO lt_2010_del.
          rollback_created_order( it_2010 = lt_2010_del ).
        ENDIF.
        RETURN.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
**        SELECT A~*, @SY-UZEIT AS ERZET
**          FROM PLAF AS A
**          APPENDING CORRESPONDING FIELDS OF TABLE @MT_PLAF
**         WHERE PLNUM = @LV_PLANNEDORDER.
      ENDIF.

      IF ev_chk_she = abap_true.
        APPEND INITIAL LINE TO et_plnum ASSIGNING FIELD-SYMBOL(<ls_plnum>).
        <ls_plnum> = lv_plannedorder.
      ENDIF.

    ENDLOOP.

*    총소요량 세팅
    IF mt_resb IS NOT INITIAL.
      APPEND LINES OF mt_resb TO mt_resb_total.
*      LOOP AT MT_RESB INTO DATA(LS_RESB).
*        UPDATE RESB SET BDMNG = LS_RESB-BDMNG
*                                  ERFMG = LS_RESB-ERFMG
*        WHERE  RSNUM = LS_RESB-RSNUM
*           AND  RSPOS = LS_RESB-RSPOS.
**           AND  RSART = LS_RESB-RSART.
*        IF SY-SUBRC EQ 0.
*          COMMIT WORK AND WAIT.
*        ELSE.
*          ROLLBACK WORK.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
    ENDIF.

*    오더 생성후 공정테이블 관리
    proc_jojang( ).

*    성공결과 리턴
    ev_result = 'S'.
    ev_order = lv_plannedorder.
*    EV_POSNR " 계획 오더는 품목없음
    ev_ordty = 'PLN'.

  ENDMETHOD.


  METHOD proc_multy_order.

    DATA : lt_source_dev TYPE TABLE OF zgtppt2010.
    DATA : lt_source_pre TYPE TABLE OF zgtppt2010.
    DATA : lt_exception_del TYPE TABLE OF zgtppt2010.
    DATA : lt_del_plnorder TYPE mrpds_plono.
    DATA : lt_del_prdorder TYPE bapi_order_key.
    DATA : lt_chg_orderchain TYPE zgtppt2010.
    DATA : lt_cal_2010 LIKE mt_2010_cal.
    DATA : lt_del_2010 TYPE TABLE OF zgtppt2010.
    DATA : lt_new_2010 TYPE TABLE OF zgtppt2010.
    DATA : lt_result TYPE bapi_order_return_tt.
    DATA : ls_order TYPE bapi_pp_order_create.
    DATA : ls_return TYPE bapiret2.
    DATA : lv_order_number TYPE bapi_order_key-order_number.
    DATA : lv_chk_she.
    DATA : lv_tabix TYPE i.
    DATA : lv_so_vbeln TYPE vbap-vbeln.
    DATA : lv_so_posnr TYPE vbap-posnr.
    DATA : lv_loop_idx TYPE i.

    DATA : lv_percent TYPE i.
    DATA : lv_sum_num TYPE i.

    mv_auart = iv_auart.

    lv_percent = 10.
    progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

    lv_sum_num = 80 / lines( it_2010 ).

*  선택된 오더 정보의 체인 구조 가져오기
    get_chain_data(
      EXPORTING
        it_data      =  it_2010
      IMPORTING
        et_pre_data  = lt_source_pre
        et_dev_data  = lt_source_dev
        et_exception = lt_exception_del ).

*  공정의 검사여장 정보 조회
    SELECT a~matnr, a~mtart, c~/sapmp/fix_as_j
      FROM @mt_main_seq_routing AS m
      INNER JOIN mara AS a  ON a~matnr = m~matnr
      INNER JOIN mapl AS b  ON b~matnr = a~matnr
      INNER JOIN plpo AS c  ON c~plnnr = b~plnnr
     WHERE b~werks = @mv_werks
       AND b~plnty = 'N'
       AND b~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
       AND c~plnty = 'N'
       AND c~plnkn = '00000001'
      ORDER BY a~matnr
      INTO TABLE @DATA(lt_infor_matnr).

* 선택된 공정의 복조장 전환.
    READ TABLE it_2010 INTO DATA(ls_2010_temp) INDEX 1.
    READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY chart = ls_2010_temp-gong_cd
                                                                     matnr = ls_2010_temp-matnr.
    READ TABLE lt_infor_matnr INTO DATA(ls_infor_matnr) WITH KEY matnr = ms_main_seq_routing-matnr.

    IF ms_main_seq_routing-seqno = 1.
*  오더 생성
      ls_order-material = ms_main_seq_routing-matnr.
      ls_order-plant = mv_werks.
      IF mv_auart = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
        ls_order-order_type = mv_auart.
      ELSE.
        ls_order-order_type = 'PP05'.
      ENDIF.

      SELECT SINGLE edatu FROM zgtppt2000
        INTO @DATA(lv_edatu)
       WHERE grpnr = @ls_2010_temp-grpnr
         AND ordno = @ls_2010_temp-dmord
         AND posnr = @ls_2010_temp-dmline.

      mv_findate = lv_edatu - 1.

      ls_order-basic_start_date = mv_findate.
      ls_order-basic_end_date = mv_findate.
      ls_order-basic_scheduling_type = '3'.

      CLEAR ls_order-quantity.
      LOOP AT it_2010 INTO DATA(ls_2010_so).
        ls_order-quantity = ls_order-quantity + ( ( ls_2010_so-inlength + ls_infor_matnr-/sapmp/fix_as_j ) * ls_2010_so-infactor ).
      ENDLOOP.

      CALL FUNCTION 'BAPI_PRODORD_CREATE'
        EXPORTING
          orderdata    = ls_order
        IMPORTING
          return       = ls_return
          order_number = lv_order_number.

*  복조장 구성 BDC
      IF ls_return-type NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
        DO .
          SELECT SINGLE aufnr, posnr
            FROM afpo
           WHERE aufnr = @lv_order_number
            INTO @DATA(ls_afpo).
          IF sy-subrc EQ 0.
            EXIT.
          ELSE.
            WAIT UP TO '0.5' SECONDS.
          ENDIF.
        ENDDO.

      ELSE.
        APPEND INITIAL LINE TO rt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
        <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
        RETURN.
      ENDIF.

      DATA(lv_return) = create_prd_order(
                          iv_aufnr = lv_order_number
                          iv_matnr = ms_main_seq_routing-matnr                 " 자재 번호
                          it_2010  = it_2010 ).

      IF lv_return = 'E'.
        APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
        <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
        lv_return = dele_prd_order( iv_aufnr = lv_order_number ).
        RETURN.
      ENDIF.

      IF iv_chk_release = abap_true. " 기존 오더에 릴리즈건이 있다면 릴리즈 처리

        DATA : lt_orders TYPE TABLE OF bapi_order_key.

        APPEND INITIAL LINE TO lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
        <ls_orders>-order_number = lv_order_number.

        CLEAR ls_return.

        CALL FUNCTION 'BAPI_PRODORD_RELEASE'
          IMPORTING
            return        = ls_return
          TABLES
            orders        = lt_orders
            detail_return = rt_result.

        IF ls_return-type = 'E'.
          RETURN.
        ELSE.
          REFRESH rt_result.
        ENDIF.

      ENDIF.

      ADD lv_sum_num TO lv_percent.
      progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

*  복조장 구성 완료후 체인 테이블 정비
*  - 선택된 조장은 생성된 오더와 품목번호 세팅, 기존 공정은 삭제
*  - 이후 공정은 이전공정 항목 변경
*  - 이전 공정 삭제 처리후 신규 공정 생산오더로 생성
      REFRESH : mt_plan_orders, mt_prd_orders.

      APPEND LINES OF it_2010 TO lt_del_2010.
      APPEND LINES OF lt_source_pre TO lt_del_2010.

* 복조장 삭제건 재작업을 빼기위해 오더로 소트
      SORT lt_del_2010 BY ordnr ordty.
      DELETE ADJACENT DUPLICATES FROM lt_del_2010 COMPARING ordnr ordty.

      LOOP AT lt_del_2010 INTO DATA(ls_2010_del).
        CASE ls_2010_del-ordty.
          WHEN 'PLN'.
            APPEND INITIAL LINE TO mt_plan_orders ASSIGNING FIELD-SYMBOL(<ls_plan_orders>).
            <ls_plan_orders> = ls_2010_del-ordnr.
          WHEN 'PRD'.
            APPEND INITIAL LINE TO mt_prd_orders ASSIGNING FIELD-SYMBOL(<ls_prd_orders>).
            <ls_prd_orders>-order_number = ls_2010_del-ordnr.
        ENDCASE.
      ENDLOOP.

      DATA : lv_posnr(4) TYPE n.
*  현재 공정, ORDNR, POSNR, ORDTY만 변경
      LOOP AT it_2010 INTO DATA(ls_2010).
        ADD 1 TO lv_posnr.
        APPEND INITIAL LINE TO lt_new_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
        MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        <ls_2010>-ordnr = lv_order_number.
        <ls_2010>-posnr = lv_posnr.
        <ls_2010>-ordty = 'PRD'.
      ENDLOOP.

      LOOP AT lt_new_2010 INTO DATA(ls_save_so).
        CLEAR : lv_so_vbeln, lv_so_posnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_save_so-dmord
          IMPORTING
            output = lv_so_vbeln.
        lv_so_posnr = ls_save_so-dmline + 0.

        UPDATE afpo SET kdauf = lv_so_vbeln
                              kdpos = lv_so_posnr
                      WHERE aufnr = ls_save_so-ordnr
                          AND posnr = ls_save_so-posnr+2(4).
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
          APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
          <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
          RETURN.
        ENDIF.
      ENDLOOP.

    ELSE.

      REFRESH lt_cal_2010.
      MOVE-CORRESPONDING lt_source_dev TO lt_cal_2010.

      calc_lc_multy(
        EXPORTING
          iv_matnr           =  ls_infor_matnr-matnr                " 자재 번호
          iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
          iv_chk_merge      = 'X'                 " 추가여장
        IMPORTING
          ev_result              = DATA(lv_check)
          et_return          = lt_result                 " 길이 1의 문자 필드
        CHANGING
          ct_2010_dev        = lt_cal_2010 ).

      IF lv_check = 'F'.
        RETURN.
      ENDIF.

      IF lt_result[] IS NOT INITIAL.
        APPEND LINES OF lt_result TO rt_result.
        RETURN.
      ENDIF.

*  오더생성 후 변경 형태로 진행
*  오더 생성
      ls_order-material = ls_infor_matnr-matnr.
      ls_order-plant = mv_werks.
      IF mv_auart = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
        ls_order-order_type = mv_auart.
      ELSE.
        ls_order-order_type = 'PP05'.
      ENDIF.
      ls_order-basic_start_date = mv_findate.
      ls_order-basic_end_date = mv_findate.
      ls_order-quantity = ms_2010_cal-plord_qty.
      ls_order-basic_scheduling_type = '3'.

      CALL FUNCTION 'BAPI_PRODORD_CREATE'
        EXPORTING
          orderdata    = ls_order
        IMPORTING
          return       = ls_return
          order_number = lv_order_number.

*  복조장 구성 BDC
      IF ls_return-type NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
        DO .
          SELECT SINGLE aufnr, posnr
            FROM afpo
           WHERE aufnr = @lv_order_number
            INTO @ls_afpo.
          IF sy-subrc EQ 0.
            EXIT.
          ELSE.
            WAIT UP TO '0.5' SECONDS.
          ENDIF.
        ENDDO.

      ELSE.
        APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
        <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
        lv_return = dele_prd_order( iv_aufnr = lv_order_number ).
        RETURN.
      ENDIF.

      CLEAR lv_return.
      lv_return = create_prd_order(
                          iv_aufnr = lv_order_number
                          iv_matnr = ls_infor_matnr-matnr                 " 자재 번호
                          it_2010  = it_2010 ).

      IF lv_return = 'E'.
        APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
        <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
        lv_return = dele_prd_order( iv_aufnr = lv_order_number ).
        RETURN.
      ENDIF.

*    복조장 오더 품목 갯수 맞게 생겼는지 확인
      SELECT aufnr, posnr
         FROM afpo
        WHERE aufnr = @lv_order_number
         INTO TABLE @DATA(lt_afpo).
      IF lines( lt_afpo ) NE lines( it_2010 ).
        APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
        <ls_result>-message = '복조장 생산오더 생성중 오류 발생하였습니다.'.
        lv_return = dele_prd_order( iv_aufnr = lv_order_number ).
        RETURN.
      ENDIF.

      IF iv_chk_release = abap_true. " 기존 오더에 릴리즈건이 있다면 릴리즈 처리

        APPEND INITIAL LINE TO lt_orders ASSIGNING <ls_orders>.
        <ls_orders>-order_number = lv_order_number.

        CLEAR ls_return.

        CALL FUNCTION 'BAPI_PRODORD_RELEASE'
          IMPORTING
            return        = ls_return
          TABLES
            orders        = lt_orders
            detail_return = rt_result.

        IF ls_return-type = 'E'.
          RETURN.
        ELSE.
          REFRESH rt_result.
        ENDIF.

      ENDIF.

      ADD lv_sum_num TO lv_percent.
      progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

*  복조장 구성 완료후 체인 테이블 정비
*  - 선택된 조장은 생성된 오더와 품목번호 세팅, 기존 공정은 삭제
*  - 이후 공정은 이전공정 항목 변경
*  - 이전 공정 삭제 처리후 신규 공정 생산오더로 생성
      REFRESH : mt_plan_orders, mt_prd_orders.

      APPEND LINES OF it_2010 TO lt_del_2010.
      APPEND LINES OF lt_source_pre TO lt_del_2010.
      LOOP AT lt_del_2010 INTO ls_2010_del.
        CASE ls_2010_del-ordty.
          WHEN 'PLN'.
            APPEND INITIAL LINE TO mt_plan_orders ASSIGNING <ls_plan_orders>.
            <ls_plan_orders> = ls_2010_del-ordnr.
          WHEN 'PRD'.
            APPEND INITIAL LINE TO mt_prd_orders ASSIGNING <ls_prd_orders>.
            <ls_prd_orders>-order_number = ls_2010_del-ordnr.
        ENDCASE.
      ENDLOOP.

* 이후 공정 오더는 오더 삭제대상 아님
      APPEND LINES OF lt_source_dev TO lt_del_2010.

*  현재 공정, ORDNR, POSNR, ORDTY만 변경
      LOOP AT it_2010 INTO ls_2010.
        ADD 1 TO lv_posnr.
        APPEND INITIAL LINE TO lt_new_2010 ASSIGNING <ls_2010>.
        MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        <ls_2010>-ordnr = lv_order_number.
        <ls_2010>-posnr = lv_posnr.
        <ls_2010>-ordty = 'PRD'.
*     해당 계약 상위 공정 변경
        CLEAR lv_loop_idx.
        LOOP AT lt_source_dev ASSIGNING FIELD-SYMBOL(<ls_2010_dev>) WHERE reord = ls_2010-ordnr
                                                                      AND reline = ls_2010-posnr
                                                                      AND reordty = ls_2010-ordty.
          ADD 1 TO lv_loop_idx.
          <ls_2010_dev>-reord = lv_order_number.
          <ls_2010_dev>-reline = lv_posnr.
          <ls_2010_dev>-reordty = 'PRD'.
*      1번 품목아닌경우 검사 여장 제외후 이후공정 예약자재 소요량 변경
          IF lv_posnr NE 1 AND <ls_2010>-qlength NE 0 AND lv_loop_idx = 1.
            set_dev_resb_on_merge(
              is_orign = <ls_2010>             " 현재공정
              is_dev   =  <ls_2010_dev> ).   " 이후공정
          ENDIF.
        ENDLOOP.

        IF lv_posnr NE 1.
          CLEAR <ls_2010>-qlength.
        ENDIF.

      ENDLOOP.
*  수정된 이후 공정 수정 목록에 어팬드
      APPEND LINES OF lt_source_dev TO lt_new_2010.

    ENDIF.

    DATA : lv_seqno TYPE i.
*   이전 공정 생성
    REFRESH lt_cal_2010.
    lv_seqno = ms_main_seq_routing-seqno.
    DO.
      MOVE-CORRESPONDING lt_new_2010 TO mt_2020.
*    오더 생성할 정보의 이후 공정
      IF lt_cal_2010[] IS INITIAL.
        MOVE-CORRESPONDING lt_new_2010 TO lt_cal_2010.
        DELETE lt_cal_2010 WHERE matnr NE ms_main_seq_routing-matnr.
      ENDIF.

      ADD 1 TO lv_seqno.
      READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY seqno = lv_seqno.
      IF sy-subrc EQ 0.
        IF ms_main_seq_routing-maabc = 'B'. " ABC 지시자가 B라면 다음으로 공정에 포함안됨
          CONTINUE.
        ENDIF.
      ELSE. " 조회 대상 없을시 완료
        EXIT.
      ENDIF.

      READ TABLE lt_infor_matnr INTO ls_infor_matnr WITH KEY matnr = ms_main_seq_routing-matnr.

      IF lv_chk_she IS NOT INITIAL.
        LOOP AT lt_cal_2010 ASSIGNING FIELD-SYMBOL(<ls_cal_2010>).
          DATA : lt_headerdata TYPE TABLE OF bapiplaf_i1.
          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.

          MOVE-CORRESPONDING <ls_cal_2010> TO ms_2020_source.
          calc_lc(
          EXPORTING
            iv_matnr           =  ms_main_seq_routing-matnr                " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
            iv_gubun           = ms_2020_source-ordty                 " 문자 필드(길이 5)
          IMPORTING
            ev_result            = lv_check
          CHANGING
            ct_headerdata = lt_headerdata
          ).

          IF lv_check = 'F'. " 연결된 이후공정 자재가 없으면 생성종료
            EXIT.
          ENDIF.

*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO DATA(ls_resb).
            UPDATE resb SET bdmng = ls_resb-bdmng
                                      erfmg = ls_resb-erfmg
                            WHERE  rsnum = ls_resb-rsnum
                                AND  rspos = ls_resb-rspos
                                AND  rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

*  오더 생성
          CLEAR : ls_order, ls_return, lv_order_number.
          ls_order-material = ls_infor_matnr-matnr.
          ls_order-plant = mv_werks.
          IF mv_auart = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
            ls_order-order_type = mv_auart.
          ELSE.
            ls_order-order_type = 'PP01'.
          ENDIF.
          ls_order-basic_start_date = mv_findate.
          ls_order-basic_end_date = mv_findate.
          ls_order-quantity = mv_total_plord_qty.
*      LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

          CALL FUNCTION 'BAPI_PRODORD_CREATE'
            EXPORTING
              orderdata    = ls_order
            IMPORTING
              return       = ls_return
              order_number = lv_order_number.

*  복조장 구성 BDC
          IF ls_return-type NE 'E'.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
            DO .
              SELECT SINGLE aufnr, posnr
                FROM afpo
               WHERE aufnr = @lv_order_number
                INTO @ls_afpo.
              IF sy-subrc EQ 0.
                EXIT.
              ELSE.
                WAIT UP TO '0.5' SECONDS.
              ENDIF.
            ENDDO.

          ELSE.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

* 이전공정 입력값 세팅
          APPEND INITIAL LINE TO lt_new_2010 ASSIGNING <ls_2010>.
          <ls_2010>-grpnr    = mv_grpnr.
          <ls_2010>-gong_cd = ms_main_seq_routing-chart.
          <ls_2010>-ordnr = lv_order_number.
          <ls_2010>-posnr = 1 + 0.
          <ls_2010>-ordty = 'PRD'.
          <ls_2010>-matnr = ms_main_seq_routing-matnr.
          <ls_2010>-dmord = <ls_cal_2010>-ordnr.
          <ls_2010>-dmline = <ls_cal_2010>-posnr.
          <ls_2010>-dmordty = <ls_cal_2010>-ordty.

          READ TABLE lt_new_2010 ASSIGNING FIELD-SYMBOL(<ls_new_2010>) WITH KEY ordnr = <ls_cal_2010>-ordnr
                                                                                posnr = <ls_cal_2010>-posnr
                                                                                ordty = <ls_cal_2010>-ordty.
          <ls_new_2010>-reord = lv_order_number.
          <ls_new_2010>-reline = 1 + 0.
          <ls_new_2010>-reordty = 'PRD'.

          IF mt_2020_lc[] IS NOT INITIAL.
            READ TABLE mt_2020_lc INTO DATA(ls_2010_lc) INDEX 1.
            <ls_2010>-inlength = ls_2010_lc-inlength.
            <ls_2010>-infactor = ls_2010_lc-infactor.
            <ls_2010>-qlength = ls_2010_lc-qlength.
            <ls_2010>-clength = ls_2010_lc-clength.
            <ls_2010>-slength = ls_2010_lc-slength.
            <ls_2010>-elength = ls_2010_lc-elength.
          ELSE.
            <ls_2010>-inlength = ms_2010_cal-inlength.
            <ls_2010>-infactor = ms_2010_cal-infactor.
            <ls_2010>-qlength = ms_2010_cal-qlength.
            <ls_2010>-clength = ms_2010_cal-clength.
            <ls_2010>-slength = ms_2010_cal-slength.
            <ls_2010>-elength = ms_2010_cal-elength.
          ENDIF.

* 특성값 세팅
          set_prd_charicteristic(
            EXPORTING
              is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
            IMPORTING
              ev_result = lv_return ).                " 길이 1의 문자 필드

          IF lv_return = 'E'.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

        ENDLOOP.
        REFRESH lt_cal_2010.

      ELSE.

        IF lines( lt_cal_2010 ) > 1.

          calc_lc_multy(
            EXPORTING
              iv_matnr           =  ls_infor_matnr-matnr                " 자재 번호
               iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
*         IV_ADLENGTH        =                  " 추가여장
            IMPORTING
              ev_result            = lv_check
              et_return          = lt_result                 " 길이 1의 문자 필드
            CHANGING
              ct_2010_dev        = lt_cal_2010 ).

          IF lt_result[] IS NOT INITIAL.
            APPEND LINES OF lt_result TO rt_result.
*  생성된 오더 삭제 처리후 종료
            rollback_created_order( it_2010 = lt_new_2010 ).

            RETURN.
          ENDIF.

        ELSE.

          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.
          READ TABLE lt_cal_2010 INTO DATA(ls_2010_cal) INDEX 1.
          MOVE-CORRESPONDING ls_2010_cal TO ms_2020_source.

          calc_lc(
          EXPORTING
            iv_matnr           =  ms_main_seq_routing-matnr                " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
            iv_gubun           = ms_2020_source-ordty                 " 문자 필드(길이 5)
          IMPORTING
            ev_result            = lv_check
          CHANGING
            ct_headerdata = lt_headerdata
          ).

        ENDIF.

        IF lv_check = 'F'.
          EXIT.
        ENDIF.

*  이후공정 예약 자재 변경
        LOOP AT mt_resb INTO ls_resb.
          UPDATE resb SET bdmng = ls_resb-bdmng
                                    erfmg = ls_resb-erfmg
                          WHERE  rsnum = ls_resb-rsnum
                              AND  rspos = ls_resb-rspos
                              AND  rsart = ls_resb-rsart.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDLOOP.

*      SHE 공정은 이후공정의 봄 자재 수량 1개 이상시 자재수량만큼 오더추가
        IF lines( lt_cal_2010 ) > 1 AND ms_main_seq_routing-seqno NE 1 AND ms_main_seq_routing-chart = 'SHE' AND ms_2010_cal-infactor > 1.
          lv_chk_she = abap_true.
          CLEAR lv_tabix.
          DATA(lv_lines) = lines( lt_cal_2010 ).
          DO  ms_2010_cal-infactor  TIMES.
*  오더 생성
            CLEAR : ls_order, ls_return, lv_order_number.
            ls_order-material = ls_infor_matnr-matnr.
            ls_order-plant = mv_werks.
            IF mv_auart = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
              ls_order-order_type = mv_auart.
            ELSE.
              ls_order-order_type = 'PP01'.
            ENDIF.
            ls_order-basic_start_date = mv_findate.
            ls_order-basic_end_date = mv_findate.
            ls_order-quantity = mv_total_plord_qty.
**      LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

            CALL FUNCTION 'BAPI_PRODORD_CREATE'
              EXPORTING
                orderdata    = ls_order
              IMPORTING
                return       = ls_return
                order_number = lv_order_number.

*  복조장 구성 BDC
            IF ls_return-type NE 'E'.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
              DO .
                SELECT SINGLE aufnr, posnr
                  FROM afpo
                 WHERE aufnr = @lv_order_number
                  INTO @ls_afpo.
                IF sy-subrc EQ 0.
                  EXIT.
                ELSE.
                  WAIT UP TO '0.5' SECONDS.
                ENDIF.
              ENDDO.

            ELSE.
              APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
              CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
              RETURN.
            ENDIF.

            ADD 1 TO lv_tabix.
* 이전공정 입력값 세팅
            APPEND INITIAL LINE TO lt_new_2010 ASSIGNING <ls_2010>.
            <ls_2010>-grpnr    = mv_grpnr.
            <ls_2010>-gong_cd = ms_main_seq_routing-chart.
            <ls_2010>-ordnr = lv_order_number.
            <ls_2010>-posnr = 1 + 0.
            <ls_2010>-ordty = 'PRD'.
            <ls_2010>-matnr = ms_main_seq_routing-matnr.
            IF lv_tabix > lv_lines.
              lv_tabix = lv_lines.
            ENDIF.

            READ TABLE lt_cal_2010 ASSIGNING <ls_cal_2010> INDEX lv_tabix.
            IF sy-subrc EQ 0.
              <ls_2010>-dmord = <ls_cal_2010>-ordnr.
              <ls_2010>-dmline = <ls_cal_2010>-posnr.
              <ls_2010>-dmordty = <ls_cal_2010>-ordty.
              IF sy-tabix <= lv_lines.

                READ TABLE lt_new_2010 ASSIGNING <ls_new_2010> WITH KEY ordnr = <ls_cal_2010>-ordnr
                                                                        posnr = <ls_cal_2010>-posnr
                                                                        ordty = <ls_cal_2010>-ordty.
                <ls_new_2010>-reord = lv_order_number.
                <ls_new_2010>-reline = 1 + 0.
                <ls_new_2010>-reordty = 'PRD'.
              ENDIF.
            ENDIF.

*  마지막 라인의경우
            IF lv_tabix = ms_2010_cal-infactor  AND lv_tabix < lv_lines.
              DO.
                ADD 1 TO lv_tabix.
                READ TABLE lt_cal_2010 ASSIGNING <ls_cal_2010> INDEX lv_tabix.
                IF sy-subrc EQ 0.

                  READ TABLE lt_new_2010 ASSIGNING <ls_new_2010> WITH KEY ordnr = <ls_cal_2010>-ordnr
                                                                          posnr = <ls_cal_2010>-posnr
                                                                          ordty = <ls_cal_2010>-ordty.
                  <ls_new_2010>-reord = lv_order_number.
                  <ls_new_2010>-reline = 1 + 0.
                  <ls_new_2010>-reordty = 'PRD'.
                ENDIF.

                IF lv_tabix = lv_lines.
                  EXIT.
                ENDIF.
              ENDDO.
            ENDIF.

            IF mt_2020_lc[] IS NOT INITIAL.
              READ TABLE mt_2020_lc INTO ls_2010_lc INDEX 1.
              <ls_2010>-inlength = ls_2010_lc-inlength.
              <ls_2010>-infactor = 1.
              <ls_2010>-qlength = ls_2010_lc-qlength.
              <ls_2010>-clength = ls_2010_lc-clength.
              <ls_2010>-slength = ls_2010_lc-slength.
              <ls_2010>-elength = ls_2010_lc-elength.
            ELSE.
              <ls_2010>-inlength = ms_2010_cal-inlength.
              <ls_2010>-infactor = 1.
              <ls_2010>-qlength = ms_2010_cal-qlength.
              <ls_2010>-clength = ms_2010_cal-clength.
              <ls_2010>-slength = ms_2010_cal-slength.
              <ls_2010>-elength = ms_2010_cal-elength.
            ENDIF.

* 특성값 세팅
            set_prd_charicteristic(
              EXPORTING
                is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
              IMPORTING
                ev_result = lv_return ).                " 길이 1의 문자 필드

            IF lv_return = 'E'.
              APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
              CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
              RETURN.
            ENDIF.
          ENDDO.

          REFRESH lt_cal_2010.

        ELSE.

*  오더 생성
          CLEAR : ls_order, ls_return, lv_order_number.
          ls_order-material = ls_infor_matnr-matnr.
          ls_order-plant = mv_werks.
          IF mv_auart = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
            ls_order-order_type = mv_auart.
          ELSE.
            ls_order-order_type = 'PP01'.
          ENDIF.
          ls_order-basic_start_date = mv_findate.
          ls_order-basic_end_date = mv_findate.
          ls_order-quantity = mv_total_plord_qty.
*      LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

          CALL FUNCTION 'BAPI_PRODORD_CREATE'
            EXPORTING
              orderdata    = ls_order
            IMPORTING
              return       = ls_return
              order_number = lv_order_number.

*  복조장 구성 BDC
          IF ls_return-type NE 'E'.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
            DO .
              SELECT SINGLE aufnr, posnr
                FROM afpo
               WHERE aufnr = @lv_order_number
                INTO @ls_afpo.
              IF sy-subrc EQ 0.
                EXIT.
              ELSE.
                WAIT UP TO '0.5' SECONDS.
              ENDIF.
            ENDDO.

          ELSE.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

* 이전공정 입력값 세팅
          APPEND INITIAL LINE TO lt_new_2010 ASSIGNING <ls_2010>.
          <ls_2010>-grpnr    = mv_grpnr.
          <ls_2010>-gong_cd = ms_main_seq_routing-chart.
          <ls_2010>-ordnr = lv_order_number.
          <ls_2010>-posnr = 1 + 0.
          <ls_2010>-ordty = 'PRD'.
          <ls_2010>-matnr = ms_main_seq_routing-matnr.
          LOOP AT lt_cal_2010 INTO DATA(ls_2010_cal_dev).
            IF sy-tabix = 1.
              <ls_2010>-dmord = ls_2010_cal_dev-ordnr.
              <ls_2010>-dmline = ls_2010_cal_dev-posnr.
              <ls_2010>-dmordty = ls_2010_cal_dev-ordty.
            ENDIF.
            READ TABLE lt_new_2010 ASSIGNING <ls_new_2010> WITH KEY ordnr = ls_2010_cal_dev-ordnr
                                                                    posnr = ls_2010_cal_dev-posnr
                                                                    ordty = ls_2010_cal_dev-ordty.
            <ls_new_2010>-reord = lv_order_number.
            <ls_new_2010>-reline = 1 + 0.
            <ls_new_2010>-reordty = 'PRD'.
          ENDLOOP.
          IF mt_2020_lc[] IS NOT INITIAL.
            READ TABLE mt_2020_lc INTO ls_2010_lc INDEX 1.
            <ls_2010>-inlength = ls_2010_lc-inlength.
            <ls_2010>-infactor = ls_2010_lc-infactor.
            <ls_2010>-qlength = ls_2010_lc-qlength.
            <ls_2010>-clength = ls_2010_lc-clength.
            <ls_2010>-slength = ls_2010_lc-slength.
            <ls_2010>-elength = ls_2010_lc-elength.
          ELSE.
            <ls_2010>-inlength = ms_2010_cal-inlength.
            <ls_2010>-infactor = ms_2010_cal-infactor.
            <ls_2010>-qlength = ms_2010_cal-qlength.
            <ls_2010>-clength = ms_2010_cal-clength.
            <ls_2010>-slength = ms_2010_cal-slength.
            <ls_2010>-elength = ms_2010_cal-elength.
          ENDIF.

* 특성값 세팅
          set_prd_charicteristic(
            EXPORTING
              is_2010   = <ls_2010>                 " [GT] 오더 연결 정보
            IMPORTING
              ev_result = lv_return ).                " 길이 1의 문자 필드

          IF lv_return = 'E'.
            APPEND INITIAL LINE TO rt_result ASSIGNING <ls_result>.
            CONCATENATE '공정' ms_main_seq_routing-chart_val '생산오더 생성중 오류 발생하였습니다.'   INTO <ls_result>-message SEPARATED BY space.
            RETURN.
          ENDIF.

          REFRESH lt_cal_2010[].
        ENDIF.
      ENDIF.

    ENDDO.

    ADD lv_sum_num TO lv_percent.
    progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

*  복조장 구성 완료, 체인테이블 구성
    IF lt_del_2010[] IS NOT INITIAL.
      DELETE zgtppt2010 FROM TABLE lt_del_2010.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    IF lt_new_2010[] IS NOT INITIAL.

      DATA : lt_zpptc002 TYPE TABLE OF zpptc002.
      LOOP AT lt_new_2010 INTO DATA(ls_new_2010).
*    오더 검사여장 시료여장 업데이트
        IF ls_new_2010-ordty = 'PRD'.
          APPEND INITIAL LINE TO lt_zpptc002 ASSIGNING FIELD-SYMBOL(<ls_save_data>).
          <ls_save_data>-aufnr = ls_new_2010-ordnr.
          <ls_save_data>-posnr = ls_new_2010-posnr+2(4).
          <ls_save_data>-psamg = ls_new_2010-qlength.
          IF ls_new_2010-adtype = 'A'.
            <ls_save_data>-psmng = ls_new_2010-adlength.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lt_zpptc002[] IS NOT INITIAL.
        MODIFY zpptc002 FROM TABLE lt_zpptc002.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.

      MODIFY zgtppt2010 FROM TABLE lt_new_2010.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

* 계획오더 삭제
    IF mt_plan_orders[] IS NOT INITIAL.
      LOOP AT mt_plan_orders INTO DATA(lv_plnum).
        lv_return = dele_pln_order( iv_plannedorder = lv_plnum ).
      ENDLOOP.
    ENDIF.

* 생산오더 삭제 플레그
    IF mt_prd_orders[] IS NOT INITIAL.
      LOOP AT mt_prd_orders INTO DATA(ls_aufnr).
        lv_return = dele_prd_order( iv_aufnr = ls_aufnr-order_number ).
      ENDLOOP.
    ENDIF.

    progress_indicator( iv_percent = '100'  iv_text = '완료' ).

  ENDMETHOD.


  METHOD proc_pegging.

    DATA : lt_target_dev TYPE TABLE OF zgtppt2010.
    DATA : lt_target_pre TYPE TABLE OF zgtppt2010.
    DATA : lt_source_dev TYPE TABLE OF zgtppt2010.
    DATA : lt_source_pre TYPE TABLE OF zgtppt2010.
    DATA : lt_exception_del TYPE TABLE OF zgtppt2010.
    DATA : lt_exception_del2 TYPE TABLE OF zgtppt2010.

    DATA : BEGIN OF ls_afpo,
             aufnr        TYPE afpo-aufnr,
             posnr        TYPE afpo-posnr,
             psmng        TYPE afpo-psmng,
             matnr        TYPE matnr,
             millcalength TYPE zgtcvordsyval-millcalength,
             millcafactor TYPE zgtcvordsyval-millcafactor,
           END OF ls_afpo.
    DATA : lt_afpo LIKE TABLE OF ls_afpo.
    DATA : lt_afpo_orign LIKE TABLE OF ls_afpo.
    DATA : BEGIN OF ls_del_2010,
             ordnr TYPE zgtppt2010-ordnr,
             ordty TYPE zgtppt2010-ordty,
           END OF ls_del_2010.
    DATA : lt_del_2010 LIKE TABLE OF ls_del_2010.
    DATA : lv_seqno TYPE i.
    DATA : lt_del_tab TYPE TABLE OF zgtppt2010.
    DATA : lt_save_2020 TYPE TABLE OF zgtppt2020.
    DATA : lt_chk_2010 LIKE mt_2010.
    DATA : lt_current LIKE  mt_2010.
    DATA : lt_current_chk LIKE  mt_2010.
    DATA : lv_percent TYPE i.
    DATA : lv_posnr(6) TYPE n.


    progress_indicator( iv_percent = '10'  iv_text = '처리중..' ).


*   변경대상 오더 접합성 체크
*   해당 오더가 조정구성표에 존재하는지 확인
    mv_target_order = iv_target_order.
    get_target_infor( ).

    get_chain_data(
      EXPORTING
        it_data      =  it_pegging_data
      IMPORTING
        et_pre_data  = lt_source_pre
        et_dev_data  = lt_source_dev
        et_exception = lt_exception_del ).

*     체인구성
*   선택된 오더들 매핑
    SELECT aufnr, posnr, psmng, matnr, millcalength, millcafactor
      FROM  zgtcvordsyval
     WHERE aufnr = @iv_target_order
       INTO CORRESPONDING FIELDS OF TABLE @lt_afpo.

    IF mt_2010_target[] IS INITIAL AND NOT
      ( iv_target_posnr EQ '0000' OR
       iv_target_posnr IS INITIAL ).
      DELETE lt_afpo WHERE posnr NE iv_target_posnr.
    ENDIF.

    READ TABLE it_pegging_data INTO DATA(ls_2010) INDEX 1.
    SELECT aufnr, posnr, psmng
      FROM  afpo
     WHERE aufnr = @ls_2010-ordnr
       INTO CORRESPONDING FIELDS OF TABLE @lt_afpo_orign.

    REFRESH mt_2010.

    APPEND LINES OF it_pegging_data TO lt_del_tab.
    APPEND LINES OF lt_source_dev TO lt_del_tab.

    SORT lt_afpo BY psmng DESCENDING.
    SORT lt_afpo_orign BY psmng DESCENDING.

*    동일 속성값(품목소요량) 을 체크하여 현재 구성 체인에 오더번호, 품목번호 세팅
    LOOP AT lt_afpo_orign INTO DATA(ls_afpo_orign).
      lv_posnr = ls_afpo_orign-posnr + 0.
      READ TABLE it_pegging_data  INTO ls_2010 WITH KEY ordnr = ls_afpo_orign-aufnr
                                                        posnr = lv_posnr.

      IF lines( lt_afpo ) = 1 AND lines( it_pegging_data ) > 1.
        READ TABLE lt_afpo INTO ls_afpo INDEX 1.

        APPEND INITIAL LINE TO  mt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
        MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        <ls_2010>-ordnr = ls_afpo-aufnr.
        <ls_2010>-posnr = ls_afpo-posnr.
        CLEAR : <ls_2010>-reord, <ls_2010>-reline, <ls_2010>-reordty.
        MOVE : ls_afpo-millcalength TO <ls_2010>-inlength,
                ls_afpo-millcafactor TO <ls_2010>-infactor.
        IF ls_afpo-matnr  NE <ls_2010>-matnr.
          MOVE ls_afpo-matnr TO <ls_2010>-real_matnr.
        ENDIF.

*        이후 공정하위 품목에 타겟 속성 세팅
        LOOP AT lt_source_dev INTO DATA(ls_source_dev).
          APPEND INITIAL LINE TO  mt_2010 ASSIGNING <ls_2010>.
          MOVE-CORRESPONDING ls_source_dev TO <ls_2010>.
          <ls_2010>-reord = ls_afpo-aufnr.
          <ls_2010>-reline = ls_afpo-posnr.
        ENDLOOP.

        EXIT.

      ELSE.

        LOOP AT lt_afpo INTO ls_afpo WHERE psmng >= ls_afpo_orign-psmng. " 소요량 값은 기준
          DATA(lv_txbix) = sy-tabix.
*      이후 공정 체인 하위오더로 타켓오더 연결
          APPEND INITIAL LINE TO  mt_2010 ASSIGNING <ls_2010>.

          MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
          <ls_2010>-ordnr = ls_afpo-aufnr.
          <ls_2010>-posnr = ls_afpo-posnr.
          CLEAR : <ls_2010>-reord, <ls_2010>-reline, <ls_2010>-reordty.

          lv_posnr = ls_afpo-posnr + 0.
          READ TABLE mt_2010_target INTO DATA(ls_2010_target) WITH KEY  ordnr = ls_afpo-aufnr
                                                                        posnr = lv_posnr.
          IF sy-subrc EQ 0.
            MOVE : ls_2010_target-inlength TO <ls_2010>-inlength,
                      ls_2010_target-infactor TO <ls_2010>-infactor,
                      ls_2010_target-qlength TO <ls_2010>-qlength,
                      ls_2010_target-clength TO <ls_2010>-clength,
                      ls_2010_target-slength TO <ls_2010>-slength,
                      ls_2010_target-elength TO <ls_2010>-elength,
                      ls_2010_target-adlength TO <ls_2010>-adlength,
                      ls_2010_target-adtype TO <ls_2010>-adtype,
                      ls_2010_target-reord TO <ls_2010>-reord,
                      ls_2010_target-reline TO <ls_2010>-reline,
                      ls_2010_target-reordty TO <ls_2010>-reordty.
            IF ls_2010_target-matnr  NE <ls_2010>-matnr.
              MOVE ls_2010_target-matnr TO <ls_2010>-real_matnr.
            ENDIF.

          ELSE.
            MOVE : ls_afpo-millcalength TO <ls_2010>-inlength,
                       ls_afpo-millcafactor TO <ls_2010>-infactor.
            IF ls_afpo-matnr  NE <ls_2010>-matnr.
              MOVE ls_afpo-matnr TO <ls_2010>-real_matnr.
            ENDIF.
          ENDIF.

*        이후 공정하위 품목에 타겟 속성 세팅
          LOOP AT lt_source_dev INTO ls_source_dev WHERE reord = ls_2010-ordnr
                                                     AND reline = ls_2010-posnr.
            APPEND INITIAL LINE TO  mt_2010 ASSIGNING <ls_2010>.
            MOVE-CORRESPONDING ls_source_dev TO <ls_2010>.
            <ls_2010>-reord = ls_afpo-aufnr.
            <ls_2010>-reline = ls_afpo-posnr.
          ENDLOOP.
* 선택된 오더는 다시 선택 없도록 제외
          DELETE lt_afpo INDEX lv_txbix.
          EXIT. " 한건 맵핑후 다음 순번으로 넘겨준다.
        ENDLOOP.
      ENDIF.

    ENDLOOP.


    progress_indicator( iv_percent = '50'  iv_text = '처리중..' ).

*    현재 공정의 삭제처리
*      - 현재 공정
    READ TABLE it_pegging_data INTO ls_2010 INDEX 1.
    DATA(lv_err_chk) = dele_prd_order( iv_aufnr = CONV #( ls_2010-ordnr ) ).

    REFRESH lt_del_2010.
*      - 이전 공정
    READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY chart = ls_2010-gong_cd.
    lv_seqno = ms_main_seq_routing-seqno.
    DO.
      lv_seqno = lv_seqno + 1.
      CLEAR ms_main_seq_routing.
      READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY seqno = lv_seqno.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      IF ms_main_seq_routing-maabc = 'B'.
        CONTINUE.
      ENDIF.

      LOOP AT lt_source_pre INTO DATA(ls_pre_data) WHERE gong_cd = ms_main_seq_routing-chart
                                                     AND matnr = ms_main_seq_routing-matnr.

        CLEAR ls_del_2010.
        ls_del_2010-ordnr = ls_pre_data-ordnr.
        ls_del_2010-ordty = ls_pre_data-ordty.
        COLLECT ls_del_2010 INTO lt_del_2010.

      ENDLOOP.
    ENDDO.

    progress_indicator( iv_percent = '90'  iv_text = '처리중..' ).

* 오더 삭제처리
    LOOP AT lt_del_2010 INTO ls_del_2010.
      CASE ls_del_2010-ordty.
        WHEN 'PRD'.
          lv_err_chk = dele_prd_order( iv_aufnr = CONV #( ls_del_2010-ordnr ) ).
        WHEN 'PLN'.
          lv_err_chk = dele_pln_order( iv_plannedorder = CONV #( ls_del_2010-ordnr ) ).
      ENDCASE.
    ENDLOOP.

*  조장구성표 체인 삭제를 위해 삭제테이블에 모디.
    LOOP AT lt_source_pre INTO ls_pre_data.
      READ TABLE lt_del_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = ls_pre_data-ordnr.
      IF sy-subrc EQ 0.
        SELECT * FROM zgtppt2010
          INTO TABLE @DATA(lt_del_pre)
          WHERE grpnr = @ls_pre_data-grpnr
             AND ordty = @ls_pre_data-ordty
             AND ordnr = @ls_pre_data-ordnr.
        APPEND LINES OF lt_del_pre TO lt_del_tab.
      ENDIF.
    ENDLOOP.

    SORT lt_del_tab BY grpnr ordty ordnr posnr.
    DELETE ADJACENT DUPLICATES FROM lt_del_tab COMPARING grpnr ordty ordnr posnr.


*     타겟 조장 구성표중 옮겨지는 대상 삭제, 현재 조정구성표에 옮김
    IF mt_2010_target IS NOT INITIAL. " 조장 구성표에 연결되어있는 오더의 경우
*      타겟오더의 체인구성 조회
      get_chain_data(
         EXPORTING
            it_data      =  mt_2010_target
         IMPORTING
            et_pre_data  = lt_target_pre
            et_dev_data  = lt_target_dev
            et_exception = lt_exception_del2 ).

      APPEND LINES OF mt_2010_target TO lt_del_tab.
      APPEND LINES OF lt_target_dev TO lt_del_tab.

*        이후 공정하위 품목 삭제(체인에서만 빠진다)
      REFRESH lt_del_2010.
      LOOP AT mt_2010_target INTO DATA(ls_target).
        LOOP AT lt_target_dev INTO DATA(ls_target_dev) WHERE grpnr = ls_target-grpnr
                                                         AND reord = ls_target-ordnr
                                                         AND reline = ls_target-posnr.
          APPEND INITIAL LINE TO  mt_2010 ASSIGNING <ls_2010>.
          MOVE-CORRESPONDING ls_target_dev TO <ls_2010>.
          CLEAR : <ls_2010>-reord, <ls_2010>-reline.
        ENDLOOP.
      ENDLOOP.


      READ TABLE it_pegging_data INTO ls_2010 INDEX 1.

*    이전공정 체인 삭제를 확인을 위한 전체 모수 조회
      READ TABLE mt_2010_target INTO ls_2010_target INDEX 1.
      REFRESH lt_chk_2010.
      lt_chk_2010 = get_chain( iv_grpnr = ls_2010_target-grpnr ).

*  옮겨지는 오더의 이전 이력중 삭제 대상이 아닌경우 삭제제외
      REFRESH lt_current.
      lt_current = mt_2010_target.

      DO.
        IF lt_current[] IS INITIAL.
          EXIT.
        ENDIF.

        REFRESH lt_current_chk.

        LOOP AT lt_current INTO DATA(ls_current).

          LOOP AT lt_target_pre INTO ls_pre_data WHERE ordnr = ls_current-reord
                                                   AND posnr = ls_current-reline.
            APPEND ls_pre_data TO lt_current_chk.
          ENDLOOP.
        ENDLOOP.

        SORT lt_current_chk BY ordnr posnr.
        DELETE ADJACENT DUPLICATES FROM  lt_current_chk COMPARING ordnr posnr.

        LOOP AT lt_current_chk INTO DATA(ls_current_chk).

          LOOP AT lt_chk_2010 INTO DATA(ls_chk_2010) WHERE reord = ls_current_chk-ordnr
                                                       AND reline = ls_current_chk-posnr.
            READ TABLE lt_current TRANSPORTING NO FIELDS WITH KEY ordnr = ls_chk_2010-ordnr
                                                                  posnr = ls_chk_2010-posnr.
            IF sy-subrc NE 0. " 연결된 하위 정보에 매핑되지 않는 이전 공정이 존재한다면 삭제 제외
              DATA(lv_chk_stop) = abap_true.
            ENDIF.
          ENDLOOP.
          IF lv_chk_stop IS NOT INITIAL.
            EXIT.
          ELSE.
            APPEND ls_current_chk TO lt_del_tab.
          ENDIF.

        ENDLOOP.

        IF lv_chk_stop IS NOT INITIAL.
          EXIT.
        ELSE.
          REFRESH lt_current.
          lt_current = lt_current_chk.
        ENDIF.

      ENDDO.
*      - 현재 공정
    ENDIF.

*   타겟오더 이전공정 체인들 옮기는 작업
*      LOOP AT LT_TARGET_PRE INTO DATA(LS_2010_SAVE).
**        조장구성번호 변경
*        LS_2010_SAVE-GRPNR = LS_2010-GRPNR.
*        APPEND LS_2010_SAVE TO MT_2010.
*      ENDLOOP.
*    ENDIF.

*  체인 저장
* - 삭제 진행
    IF lt_del_tab[] IS NOT INITIAL.
      DELETE zgtppt2010 FROM TABLE lt_del_tab.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        rv_message = 'Pegging 진행중 오류 발생하였습니다. '.
        RETURN.
      ENDIF.
    ENDIF.

*  변경정보 저장
    IF mt_2010[] IS NOT INITIAL.
      DATA : lt_zpptc002 TYPE TABLE OF zpptc002.
      LOOP AT mt_2010 INTO ls_2010.

*    오더 검사여장 시료여장 업데이트
        IF ls_2010-ordty = 'PRD'.
          APPEND INITIAL LINE TO lt_zpptc002 ASSIGNING FIELD-SYMBOL(<ls_save_data>).
          <ls_save_data>-aufnr = ls_2010-ordnr.
          <ls_save_data>-posnr = ls_2010-posnr+2(4).
          <ls_save_data>-psamg = ls_2010-qlength.
          IF ls_2010-adtype = 'A'.
            <ls_save_data>-psmng = ls_2010-adlength.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lt_zpptc002[] IS NOT INITIAL.
        MODIFY zpptc002 FROM TABLE lt_zpptc002.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.

      MODIFY zgtppt2010 FROM TABLE mt_2010.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        rv_message = 'Pegging 진행중 오류 발생하였습니다. '.
        RETURN.
      ENDIF.

*  히스토리 테이블 진행.
      SELECT b~grpnr, MAX( b~revno ) AS revno
        FROM @mt_2010 AS a INNER JOIN zgtppt2020 AS b  ON b~grpnr = a~grpnr
        GROUP BY b~grpnr
        ORDER BY b~grpnr
        INTO TABLE @DATA(lt_chk_grpnr).

      SORT lt_chk_grpnr BY grpnr.
      DELETE ADJACENT DUPLICATES FROM lt_chk_grpnr COMPARING grpnr.

      IF lt_chk_grpnr[] IS NOT INITIAL.
        SELECT * FROM zgtppt2010
          INTO CORRESPONDING FIELDS OF TABLE lt_save_2020
           FOR ALL ENTRIES IN lt_chk_grpnr
         WHERE grpnr = lt_chk_grpnr-grpnr.
      ENDIF.

      LOOP AT lt_save_2020 ASSIGNING FIELD-SYMBOL(<ls_save_2020>).
        READ TABLE lt_chk_grpnr INTO DATA(ls_chk_grpnr) WITH KEY grpnr = <ls_save_2020>-grpnr.
        IF sy-subrc EQ 0.
          <ls_save_2020>-revno = ls_chk_grpnr-revno + 1.
          <ls_save_2020>-aenam = sy-uname.
          <ls_save_2020>-aedat = sy-datum.
        ENDIF.
      ENDLOOP.

      IF lt_save_2020[] IS NOT INITIAL.
        MODIFY zgtppt2020 FROM TABLE lt_save_2020.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT. " 최종업로드 완료
        ELSE.
          ROLLBACK WORK.
          rv_message = 'Pegging 진행중 오류 발생하였습니다. '.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    progress_indicator( iv_percent = '100'  iv_text = '완료' ).

  ENDMETHOD.


  METHOD PROGRESS_INDICATOR.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = IV_PERCENT                 "indicator에 진행률(%)
        TEXT       = IV_TEXT.  "텍스트 표시

  ENDMETHOD.


  METHOD ROLLBACK_CREATED_ORDER.

    DATA : LT_DEL_PLNORDER TYPE MRPDS_PLONO.
    DATA : LT_DEL_PRDORDER TYPE TB_BAPI_ORDER_KEY.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.

    SELECT * FROM ZGTPPT2010
      INTO TABLE LT_2010
      WHERE GRPNR = MV_GRPNR.

    LOOP AT IT_2010 INTO DATA(LS_2010).
      READ TABLE LT_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_2010-ORDNR
                                                                                   POSNR = LS_2010-POSNR
                                                                                   ORDTY = LS_2010-ORDTY.
      IF SY-SUBRC NE 0. " 기존 체인에 없는 데이터만 삭제처리
        CASE LS_2010-ORDTY.
          WHEN 'PLN'.
            APPEND INITIAL LINE TO LT_DEL_PLNORDER ASSIGNING FIELD-SYMBOL(<LS_PLAN_ORDERS>).
            <LS_PLAN_ORDERS> = LS_2010-ORDNR.
          WHEN 'PRD'.
            APPEND INITIAL LINE TO LT_DEL_PRDORDER ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDERS>).
            <LS_PRD_ORDERS>-ORDER_NUMBER = LS_2010-ORDNR.
        ENDCASE.
      ENDIF.
    ENDLOOP.

* 계획오더 삭제
    IF LT_DEL_PLNORDER[] IS NOT INITIAL.
      LOOP AT LT_DEL_PLNORDER INTO DATA(LV_PLNUM).
        LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LV_PLNUM ).
      ENDLOOP.
    ENDIF.

* 생산오더 삭제 플레그
    IF LT_DEL_PRDORDER[] IS NOT INITIAL.
      LOOP AT LT_DEL_PRDORDER INTO DATA(LS_AUFNR).
        LV_RETURN = DELE_PRD_ORDER( IV_AUFNR = LS_AUFNR-ORDER_NUMBER ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD SEND_CHG_MES.

    DATA : LV_JOBNAME  TYPE TBTCJOB-JOBNAME VALUE 'ZGTPPI2020',
           LV_JOBNAME2 TYPE TBTCJOB-JOBNAME,
           LV_JOBCOUNT TYPE TBTCJOB-JOBCOUNT,
           LV_RELEASED TYPE  BTCH0000-CHAR1,
           LV_UZEIT    TYPE SY-UZEIT.

    CHECK SY-SYSID NE 'S4D'.

    SELECT SINGLE FLD_02
      FROM ZGTPPT1010
      WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '9999'
      AND FLD_01 = @SY-CPROG
      INTO @DATA(LV_CHK_SWITCH).

    CHECK LV_CHK_SWITCH IS INITIAL.

*   송신 대상 시스템
    SELECT SINGLE *
      FROM ZGTPPT1010
      WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '0010'
      AND FLD_03 = @IV_WERKS
      AND FLD_04 = @IV_SPGCD
      INTO @DATA(LS_IFDEST).

* 조장 구성표 번호 생성일 조회
    SELECT SINGLE MIN( ERDAT ) AS FRDATE, MAX( ERDAT ) AS TODATE
      FROM ZGTPPT2000
     WHERE GRPNR = @IV_GRPNR
      GROUP BY GRPNR
      INTO @DATA(LS_DATE).

    CLEAR : LV_JOBNAME2, LV_JOBCOUNT, LV_RELEASED, LV_UZEIT.

    CLEAR LV_JOBNAME2.
    CONCATENATE LV_JOBNAME '_' SY-DATUM '_' SY-UZEIT INTO LV_JOBNAME2.

    CLEAR LV_JOBCOUNT.
    DO.
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          JOBNAME          = LV_JOBNAME2
        IMPORTING
          JOBCOUNT         = LV_JOBCOUNT
        EXCEPTIONS
          CANT_CREATE_JOB  = 1
          INVALID_JOB_DATA = 2
          JOBNAME_MISSING  = 3
          OTHERS           = 4.
      IF SY-SUBRC = 0.
        EXIT.
      ENDIF.
    ENDDO.

* 대상 MES 전송
    SUBMIT ZGTPPI2020 VIA JOB LV_JOBNAME2
                               NUMBER LV_JOBCOUNT
                               WITH SO_SPGCD EQ IV_SPGCD
                               WITH SO_WERKS EQ IV_WERKS
                               WITH SO_GRPNR EQ IV_GRPNR
                               WITH RA_SEND EQ 'X'
                               WITH PA_BATCH EQ 'X'
                               WITH PA_FLD01 EQ LS_IFDEST-FLD_01
                               WITH SO_DATE BETWEEN LS_DATE-FRDATE AND LS_DATE-TODATE
                               AND RETURN.

*  DATA: sv_uzeit  LIKE sy-uzeit.
    CLEAR LV_UZEIT.
    LV_UZEIT = SY-UZEIT + 10.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        JOBCOUNT             = LV_JOBCOUNT
        JOBNAME              = LV_JOBNAME2
        SDLSTRTDT            = SY-DATUM
        SDLSTRTTM            = LV_UZEIT
        STRTIMMED            = 'X'  "즉시 기동
      IMPORTING
        JOB_WAS_RELEASED     = LV_RELEASED
      EXCEPTIONS
        CANT_START_IMMEDIATE = 1
        INVALID_STARTDATE    = 2
        JOBNAME_MISSING      = 3
        JOB_CLOSE_FAILED     = 4
        JOB_NOSTEPS          = 5
        JOB_NOTEX            = 6
        LOCK_FAILED          = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDMETHOD.


  METHOD SET_CHAIN_HISTORY.

    REFRESH MT_2020_SAVE.

    SELECT * FROM ZGTPPT2010
       INTO CORRESPONDING FIELDS OF TABLE MT_2020_SAVE
      WHERE GRPNR = MV_GRPNR.

* ZGTPPT2020 저장 기존 데이터 맥스순번 + 1 로 어팬드
    SELECT SINGLE MAX( REVNO )  FROM ZGTPPT2020
         INTO @DATA(LV_MAX_REVNO)
        WHERE GRPNR = @MV_GRPNR.

    LOOP AT MT_2020_SAVE ASSIGNING FIELD-SYMBOL(<LS_2020>).
      <LS_2020>-REVNO = LV_MAX_REVNO + 1.
      <LS_2020>-AENAM = SY-UNAME.
      <LS_2020>-AEDAT = SY-DATUM.
    ENDLOOP.

    MODIFY ZGTPPT2020 FROM TABLE MT_2020_SAVE.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD SET_DEV_RESB_ON_MERGE.

    DATA : LV_PLNUM TYPE PLNUM.
    DATA : LV_AUFNR TYPE AUFNR.

    CASE IS_DEV-ORDTY.
      WHEN 'PRD'.
        CLEAR LV_AUFNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = IS_DEV-ORDNR
          IMPORTING
            OUTPUT = LV_AUFNR.

        SELECT SINGLE RSNUM
           FROM AFKO
         WHERE AUFNR = @LV_AUFNR
          INTO @DATA(LV_RSNUM).

      WHEN 'PLN'.
        CLEAR LV_PLNUM.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = IS_DEV-ORDNR
          IMPORTING
            OUTPUT = LV_PLNUM.

        SELECT SINGLE RSNUM
           FROM PLAF
         WHERE PLNUM = @LV_PLNUM
          INTO @LV_RSNUM.

    ENDCASE.

    REFRESH MT_RESB.
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
    SELECT A~*
      FROM RESB AS A
      INNER JOIN MARA AS B
                             ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                             ON C~MATNR = A~MATNR
      WHERE A~RSNUM = @LV_RSNUM
          AND B~MTART = 'MCHF'
          AND C~WERKS = @MV_WERKS
          AND C~BESKZ = 'E'
         INTO CORRESPONDING FIELDS OF TABLE @MT_RESB.

    CHECK MT_RESB[] IS NOT INITIAL.

    LOOP AT MT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).
      <LS_RESB>-BDMNG = <LS_RESB>-BDMNG - ( IS_ORIGN-QLENGTH * IS_ORIGN-INFACTOR ).
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
          I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
          I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
          I_MENGE              = <LS_RESB>-BDMNG " <-- 현 수량 변수
        IMPORTING
          E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.
    ENDLOOP.

*  이후공정 예약 자재 변경
    LOOP AT MT_RESB INTO DATA(LS_RESB).
      UPDATE RESB SET BDMNG = LS_RESB-BDMNG
                                ERFMG = LS_RESB-ERFMG
                      WHERE  RSNUM = LS_RESB-RSNUM
                          AND  RSPOS = LS_RESB-RSPOS
                          AND  RSART = LS_RESB-RSART.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        EXIT.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD SET_PRD_CHARICTERISTIC.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    REFRESH : MT_BDCDATA, MT_MESSTAB.

    LV_INLENGTH = IS_2010-INLENGTH.
    LV_INLENGTH_C = LV_INLENGTH.
    CONDENSE LV_INLENGTH_C.

    LV_INFACTOR = IS_2010-INFACTOR.
    LV_INFACTOR_C = LV_INFACTOR.
    CONDENSE LV_INFACTOR_C.

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPLCOKO1' '0110'.
    __BDC_FIELD : 'CAUFVD-AUFNR' IS_2010-ORDNR,
                        'R62CLORD-FLG_OVIEW'  'X',
                        'BDC_OKCODE' '=ENTK'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환


    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

    __BDC_DYNPRO 'SAPLCEI0' '0109'.
    __BDC_FIELD : 'RCTMS-MNAME(01)' '조장(기본단위)',
                        'RCTMS-MNAME(02)' '조장수',
                        'RCTMS-MNAME(03)' '전선_공정코드',
                        'RCTMS-MWERT(01)' LV_INLENGTH_C,
                        'RCTMS-MWERT(02)' LV_INFACTOR_C,
                        'RCTMS-MWERT(03)' IS_2010-GONG_CD,
                        'BDC_OKCODE' '=BACK'.

    IF MV_AUART = 'RP01'.
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=KOZE'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU',
                          'CAUFVD-APRIO' '8'.

    ELSE.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.
    ENDIF.                 .

    __BDC_TRANSACTION 'CO02'.
    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                           OR MSGTYP = 'E'
                                                           OR MSGTYP = 'X'.
      APPEND LS_MESSTAB TO MT_TOT_MESSTAB.
      EV_RESULT = 'E'.
      RETURN.
    ENDLOOP.

    EV_RESULT = 'S'.
    COMMIT WORK AND  WAIT.
  ENDMETHOD.


  METHOD CHECK_PACK_SET_MENGE.

    DATA :LV_VBELN TYPE VBAK-VBELN.
    DATA :LV_POSNR TYPE VBAP-POSNR.
    DATA : LV_PACK_YN TYPE CHAR10.
    DATA : LV_PACK_NO TYPE MATNR.
    DATA : LV_PACK_TYPE TYPE CHAR10.
    DATA : LV_AUFNR TYPE AUFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IS_2010-DMORD
      IMPORTING
        OUTPUT = LV_VBELN.

    LV_POSNR = IS_2010-DMLINE + 0..

    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
        IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
      IMPORTING
        EV_PACK_YN    = LV_PACK_YN
        EV_PACK_NO    = LV_PACK_NO
        EV_PACK_TYPE  = LV_PACK_TYPE
    ).

    IF LV_PACK_YN = 'CM' AND LV_PACK_TYPE = 'DM'. " 포장재 지정상태와 드럼유형만 대상
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IS_2010-ORDNR
        IMPORTING
          OUTPUT = LV_AUFNR.

      SELECT B~*
        FROM AFKO AS A
        INNER JOIN RESB AS B
                               ON B~RSNUM = A~RSNUM
       WHERE A~AUFNR = @LV_AUFNR
          AND B~MATNR = @LV_PACK_NO
         INTO TABLE @DATA(LT_RESB).
      IF SY-SUBRC EQ 0.
        LOOP AT LT_RESB INTO DATA(LS_RESB).

          LS_RESB-BDMNG = 1.
          LS_RESB-ERFMG = 1.
          UPDATE RESB SET BDMNG = LS_RESB-BDMNG
                                    ERFMG = LS_RESB-ERFMG
          WHERE  RSNUM = LS_RESB-RSNUM
             AND  RSPOS = LS_RESB-RSPOS.
*           AND  RSART = LS_RESB-RSART.
          IF SY-SUBRC EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE."생산 오더 BOM에 없는 경우 오더 BOM 추가
        SELECT B~*
                FROM AFKO AS A
                INNER JOIN RESB AS B
                                       ON B~RSNUM = A~RSNUM
               INNER JOIN MARA AS C
                                       ON C~MATNR = B~MATNR
               WHERE A~AUFNR = @LV_AUFNR
                 AND C~MTART LIKE 'MRM%'
                 INTO TABLE @LT_RESB.
        IF SY-SUBRC EQ 0.
          LOOP AT LT_RESB INTO LS_RESB.
            LS_RESB-MATNR = LV_PACK_NO.
            LS_RESB-BDMNG = 1.
            LS_RESB-ERFMG = 1.
            UPDATE RESB SET MATNR = LS_RESB-MATNR
                                      BDMNG = LS_RESB-BDMNG
                                      ERFMG = LS_RESB-ERFMG
            WHERE  RSNUM = LS_RESB-RSNUM
               AND  RSPOS = LS_RESB-RSPOS.
*           AND  RSART = LS_RESB-RSART.
            IF SY-SUBRC EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE.
          DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
          DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
          DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
          DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.
          DATA : LS_RETURN TYPE COXT_BAPIRETURN.
          DATA : LV_ERROR.

          SELECT SINGLE B~APLZL, B~PLNFL
            INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
            FROM AFKO AS A
           INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
           WHERE A~AUFNR EQ @LV_AUFNR
              AND B~APLFL = '000000'
              AND B~RUECK NE ''.

          SELECT SINGLE MEINS FROM MARA
            INTO @DATA(LV_MEINS)
           WHERE MATNR = @LV_PACK_NO.


          LS_REQU_QUAN-QUANTITY = 1.
          LS_REQU_QUAN-UOM = LV_MEINS.

          LV_STORAGE_LOCATION-WERKS = MV_WERKS.
          LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.
          IF MV_WERKS = '1302'.
            SELECT SINGLE MATNR FROM MARD
              WHERE MATNR = @LV_PACK_NO
                 AND WERKS = @MV_WERKS
                 AND LGORT = '2110'
               INTO @DATA(LV_MATNR).
            IF SY-SUBRC EQ 0.

              LV_STORAGE_LOCATION-LGORT = '2110'.
              LV_STORAGE_LOCATIONX-LGORT = ABAP_TRUE.
            ENDIF.

          ENDIF.

          SELECT SINGLE MAX( B~POSNR ) AS POSNR
            FROM AFKO AS A
            INNER JOIN RESB AS B
                                   ON B~RSNUM = A~RSNUM
           WHERE A~AUFNR = @LV_AUFNR
             GROUP BY B~RSNUM
             INTO @DATA(LV_RESBPOSNR).

          LV_RESBPOSNR = LV_RESBPOSNR + 10.

          CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
            EXPORTING
              INPUT  = LV_RESBPOSNR
            IMPORTING
              OUTPUT = LV_RESBPOSNR.
          LV_POSNO = LV_RESBPOSNR.

          CALL FUNCTION 'CO_XT_COMPONENT_ADD'
            EXPORTING
              IS_ORDER_KEY         = LV_AUFNR
              I_MATERIAL           = LV_PACK_NO
              IS_REQU_QUAN         = LS_REQU_QUAN
              I_OPERATION          = LV_OPERATION
              I_SEQUENCE           = LV_SEQUENCE
              IS_STORAGE_LOCATION  = LV_STORAGE_LOCATION
              IS_STORAGE_LOCATIONX = LV_STORAGE_LOCATIONX
              I_POSTP              = 'L'
              I_POSNO              = LV_POSNO
            IMPORTING
              ES_BAPIRETURN        = LS_RETURN
              E_ERROR_OCCURRED     = LV_ERROR.
          IF LV_ERROR = SPACE.

            ASSIGN ('(SAPLCOBC)RESB_BT[]') TO FIELD-SYMBOL(<FT_RESB_BT>).
            LOOP AT <FT_RESB_BT> ASSIGNING FIELD-SYMBOL(<FS_RESB_BT>).

              ASSIGN COMPONENT 'MATNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_MATNR>).
              IF <LV_MATNR> = LV_PACK_NO.

                ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_POSNR>).
                <LV_POSNR> = LV_POSNO.
                ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_RGEKZ>).
                <LV_RGEKZ> = ABAP_TRUE.
              ENDIF.
            ENDLOOP.


            CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
              IMPORTING
                ES_BAPIRETURN    = LS_RETURN
                E_ERROR_OCCURRED = LV_ERROR.
            IF ( LS_RETURN-TYPE = 'S' OR
                 LS_RETURN-TYPE = 'W' OR
                 LS_RETURN-TYPE = 'I' ) OR
                 LS_RETURN IS INITIAL.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
              CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
            ELSE.
              CLEAR: LV_ERROR,
                     LS_RETURN.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            ENDIF.
          ELSE.
            CLEAR LV_ERROR.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD GET_CHAIN.

    SELECT * FROM ZGTPPT2010
      INTO CORRESPONDING FIELDS OF TABLE RT_RETURN
      WHERE GRPNR = IV_GRPNR.

  ENDMETHOD.


METHOD get_auart.
*----------------------------------------------------------------------*
* 2026.04.29.zlsgpp5.CHM2604-00316.개별오더 전환시 오더유형 결정
*   - RP01 이면 기존 로직 유지. 선택된 오더유형과 동일.
*   - PP05 이면 최상위 오더유형에 따라 결정.
*     : 최상위 오더유형이 PP05 이면 PP01.
*----------------------------------------------------------------------*

  DATA: lv_ordnr TYPE zgtppt2010-ordnr,
        lv_posnr TYPE zgtppt2010-posnr.

  CHECK it_2010 IS NOT INITIAL.

* 1) 조장구성표번호 전체데이터 가져옴.
  SELECT b~*
    FROM @it_2010 AS a INNER JOIN zgtppt2010 AS b ON b~grpnr = a~grpnr
    INTO TABLE @DATA(lt_2010t).


* 2) 선택된 오더의 유형
  CLEAR: et_auart.
  LOOP AT it_2010 ASSIGNING FIELD-SYMBOL(<is_2010>).
    CHECK <is_2010>-ordnr IS NOT INITIAL.

    APPEND INITIAL LINE TO et_auart ASSIGNING FIELD-SYMBOL(<es_auart>).
    <es_auart>-grpnr = <is_2010>-grpnr.
    <es_auart>-ordnr = <is_2010>-ordnr.
    <es_auart>-posnr = <is_2010>-posnr.
    SELECT SINGLE auart FROM aufk WHERE aufnr = @<is_2010>-ordnr INTO @<es_auart>-auart.
  ENDLOOP.


* 3) 최상위 오더유형 찾기.
  SORT lt_2010t BY grpnr ordnr posnr.
  LOOP AT et_auart ASSIGNING <es_auart>.
    lv_ordnr = <es_auart>-ordnr.
    lv_posnr = <es_auart>-posnr.

    DO .
      READ TABLE lt_2010t ASSIGNING FIELD-SYMBOL(<ls_2010t>)
                          WITH KEY  grpnr = <es_auart>-grpnr
                                    ordnr = lv_ordnr
                                    posnr = lv_posnr
                                    BINARY SEARCH.
      IF sy-subrc EQ 0.
        "다음 오더 찾기.
        lv_ordnr = <ls_2010t>-dmord.
        lv_posnr = <ls_2010t>-dmline.

        "판매오더이면 최상위.
        IF <ls_2010t>-dmordty EQ 'SO'.
          <es_auart>-last_ordnr = <ls_2010t>-ordnr.
          SELECT SINGLE auart FROM aufk WHERE aufnr = @<ls_2010t>-ordnr
            INTO @<es_auart>-last_auart.
          EXIT.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDLOOP.

ENDMETHOD.


METHOD change_qlength.
*----------------------------------------------------------------------*
* 2026.07.28.zlsgpp5.SRM2607-10582.고정 스크랩(각길이) 수정 가능하도록 개선
*   - "여장편집" 버튼과 별도의 버튼 클릭 후 사용자 입력하는 형태로 진행
*   - 완제품일 경우에만 처리.
*   - 여장편집 로직 복사 생성.
*----------------------------------------------------------------------*

  CONSTANTS: BEGIN OF c_msg,
               e01 TYPE char100 VALUE '고정스크랩 변경 작업중 오류 발생하였습니다.',
             END OF c_msg.

  DATA : ls_headerdata TYPE bapiplaf_i1,
         lt_headerdata TYPE TABLE OF bapiplaf_i1,
         lt_result     TYPE bapi_order_return_tt,

         ls_2000       TYPE zgtppt2000,
         lt_2010_temp  TYPE TABLE OF zgtppt2010,
         lt_2010_dev   TYPE TABLE OF zgtppt2010,
         lt_2010_pre   TYPE TABLE OF zgtppt2010,

         lv_seqno      TYPE i,
         lt_cal_2010   LIKE mt_2010_cal,
         lv_chk_she,
         lv_bdmng      TYPE resb-bdmng.

  DATA : lt_2020_save LIKE mt_2020_save.

  DATA : lv_percent TYPE i.
  DATA : lv_sum_num TYPE i.

  lv_percent = 10.
  progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

*&---------------------------------------------------------------------*
* 여장 변경된 최초 공정 구성
*&---------------------------------------------------------------------*
  mt_2010 = it_2010.

  READ TABLE mt_main_seq_routing  INTO ms_main_seq_routing
                                  WITH KEY matnr = iv_matnr." 자재번호로 공정정보 추출
  lv_seqno = ms_main_seq_routing-seqno.

  IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
    READ TABLE it_2010 INTO DATA(ls_2010_chk) INDEX 1.
    SELECT SINGLE plnbez AS matnr, gamng, gasmg
      FROM afko
      INTO @DATA(ls_she_order)
      WHERE aufnr = @ls_2010_chk-ordnr.
  ENDIF.

  get_chain_data(
    EXPORTING
      it_data     = it_2010
    IMPORTING
      et_pre_data = lt_2010_pre
      et_dev_data = lt_2010_dev ).
  MOVE-CORRESPONDING lt_2010_dev TO mt_2020_source.


* 후공정 오더가 없으면 공정마스터 조회
  IF mt_2020_source IS INITIAL.
    SELECT SINGLE b~*
      FROM @it_2010 AS a  INNER JOIN zgtppt2000 AS b  ON  b~grpnr = a~grpnr
                                                      AND b~ordno = a~dmord
                                                      AND b~posnr = a~dmline
      INTO CORRESPONDING FIELDS OF @ls_2000.

    ms_2020_source-ordty = 'SO'.
    ms_2020_source-inlength = ls_2000-inlength.
    ms_2020_source-infactor = 1.
    APPEND ms_2020_source TO mt_2020_source.
  ENDIF.


* 공정의 검사여장 정보 조회
  SELECT a~matnr, a~mtart, c~/sapmp/fix_as_j
    FROM @mt_main_seq_routing AS m  INNER JOIN mara AS a  ON a~matnr = m~matnr
                                    INNER JOIN mapl AS b  ON b~matnr = a~matnr
                                    INNER JOIN plpo AS c  ON c~plnnr = b~plnnr
   WHERE b~werks = @mv_werks
     AND b~plnty = 'N'
     AND b~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
     AND c~loekz = @space  "2026.04.28.zlsgpp5.CHM2604-00316.
     AND c~plnty = 'N'
     AND c~plnkn = '00000001'
    ORDER BY a~matnr
    INTO TABLE @DATA(lt_infor_matnr).


* 선택 오더 고정스크랩(각길이) 변경 (여장 추가 오더는 이후공정 예약자재 수량 변경만 존재)
  READ TABLE lt_infor_matnr INTO DATA(ls_infor_matnr) WITH KEY matnr = iv_matnr.
  READ TABLE mt_2010 INTO ms_2010 INDEX 1.

  IF lines( mt_2020_source ) = 1.
    READ TABLE  mt_2020_source INTO ms_2020_source INDEX 1.

    CASE ms_2020_source-ordty.
      WHEN 'SO'. " 현재 정보로 바로 수량 변경후 반영, 최초 여장추가건만 가능
        mv_total_plord_qty02 = ( ms_2010-inlength + ms_2010-qlength + ms_2010-slength +
                                 ms_2010-elength + ms_2010-clength + ms_2010-adlength ) * ms_2010-infactor.
        ev_result = change_prd_order( ).
        IF ev_result = 'E'.
          ev_message = c_msg-e01.
          RETURN.
        ENDIF.

        REFRESH mt_2020_source.
        LOOP AT mt_2010 INTO ms_2010.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_2020_source>).
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
          APPEND INITIAL LINE TO mt_2020 ASSIGNING FIELD-SYMBOL(<ls_2020_save>).
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
        ENDLOOP.

      WHEN 'PLN' OR 'PRD'.
        REFRESH lt_headerdata.
        APPEND INITIAL LINE TO lt_headerdata.

        calc_lc(
        EXPORTING
          iv_matnr            = ls_infor_matnr-matnr            " 자재 번호
          iv_fixed_scrap_qty  = ls_infor_matnr-/sapmp/fix_as_j  " 계획된 스크랩 수량
          iv_gubun            = ms_2010-ordty
          iv_adtype           = ms_2010-adtype
          iv_adlength         = ms_2010-adlength
        IMPORTING
          ev_result           = ev_result
        CHANGING
          ct_headerdata       = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

        IF ev_result = 'F'.
          ev_message = '연결된 이후공정 자재가 없습니다.'.
          RETURN.
        ENDIF.

        IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
          READ TABLE mt_2020_lc INTO DATA(ls_2020_lc) INDEX 1.
          IF ls_2020_lc-infactor = 0.
            ls_2020_lc-infactor = 1.
          ENDIF.
          mv_total_plord_qty02 = mv_total_plord_qty / ls_2020_lc-infactor.
        ELSE.
          mv_total_plord_qty02 = mv_total_plord_qty.
        ENDIF.

        CASE ms_2010-ordty.
          WHEN 'PRD'.
            ev_result = change_prd_order( ).
            IF ev_result = 'E'.
              ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.

          WHEN 'PLN'.
            ev_result = change_pln_order( ).
            IF ev_result = 'E'.
              ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.

        ENDCASE.

        IF lv_seqno NE 1 AND ms_main_seq_routing-chart = 'SHE'.
          lv_bdmng = ls_she_order-gamng.
          READ TABLE mt_resb_origin INTO DATA(ls_she_resb)
                                    WITH KEY  matnr = ls_she_order-matnr
                                              bdmng = lv_bdmng.
          IF sy-subrc EQ 0.
            ls_she_resb-bdmng = mv_total_plord_qty02.
            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                i_matnr              = ls_she_resb-matnr    " <-- 해당 자재코드
                i_in_me              = ls_she_resb-meins  "<-- 현 수량의 단위
                i_out_me             = ls_she_resb-erfme " <-- 변경되어질 수량의 단위
                i_menge              = mv_total_plord_qty02 " <-- 현 수량 변수
              IMPORTING
                e_menge              = ls_she_resb-erfmg " <-- 변경되어질 수량변수
              EXCEPTIONS
                error_in_application = 1
                error                = 2
                OTHERS               = 3.



            UPDATE resb SET   bdmng = ls_she_resb-bdmng
                              erfmg = ls_she_resb-erfmg
                        WHERE rsnum = ls_she_resb-rsnum
                          AND rspos = ls_she_resb-rspos
                          AND rsart = ls_she_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDIF.


        ELSE.
*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO DATA(ls_resb).
            UPDATE resb SET   bdmng = ls_resb-bdmng
                              erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
* CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.
    ENDCASE.
  ELSE. " 이후 공정이 여러건일시 복조장 아닐시 계산 불가
    DATA(lt_chk_2020) = mt_2020_source.
    SORT lt_chk_2020 BY ordnr.
    DELETE ADJACENT DUPLICATES FROM lt_chk_2020 COMPARING ordnr.

    IF lines( lt_chk_2020 ) NE 1.
      ev_result = 'E'.
      ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
      RETURN.
    ELSE. " 복조장 일시 오더소요량 변경, 이후공정 예약자재 수량 변경

      REFRESH lt_cal_2010.
      MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

      calc_lc_multy(
        EXPORTING
          iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
          iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j                 " 검사여장
          iv_adtype          = ms_2010-adtype
          iv_adlength        = ms_2010-adlength        " 추가여장
        IMPORTING
          ev_result          = ev_result
          et_return          = lt_result                 " 길이 1의 문자 필드
        CHANGING
          ct_2010_dev        = lt_cal_2010 ).

      IF ev_result = 'F'.
        ev_message = '연결된 이후공정 자재가 없습니다.'.
        RETURN.
      ENDIF.

      IF lt_result[] IS NOT INITIAL.
        READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
        ev_message = ls_result-message.
        RETURN.
      ENDIF.

      mv_total_plord_qty02 = mv_total_plord_qty.

      CASE ms_2010-ordty.
        WHEN 'PRD'.
          ev_result = change_prd_order( ).
          IF ev_result = 'E'.
            ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
            RETURN.
          ENDIF.

        WHEN 'PLN'.
          ev_result = change_pln_order( ).
          IF ev_result = 'E'.
            ev_message = '추가 여장 변경 작업중 오류 발생하였습니다.'.
            RETURN.
          ENDIF.

      ENDCASE.

*  이후공정 예약 자재 변경
      LOOP AT mt_resb INTO ls_resb.
        UPDATE resb SET   bdmng = ls_resb-bdmng
                          erfmg = ls_resb-erfmg
                    WHERE rsnum = ls_resb-rsnum
                      AND rspos = ls_resb-rspos
                      AND rsart = ls_resb-rsart.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
          EXIT.
        ENDIF.
      ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
      IF mt_2010[] IS NOT INITIAL.
        REFRESH mt_2020_source.
        LOOP AT mt_2010 INTO ms_2010.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
          APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*  이후 공정 오더가 복조장인지 확인
  IF mt_2020_source[] IS NOT INITIAL.
    SELECT b~*
      FROM @mt_2020_source AS a INNER JOIN  zgtppt2010 AS b ON  b~grpnr = a~grpnr
                                                            AND b~ordty = a~ordty
                                                            AND b~ordnr = a~ordnr
      INTO TABLE @DATA(lt_2010_dev_chk).

    SORT lt_2010_dev_chk BY ordty ordnr posnr.
    DELETE ADJACENT DUPLICATES FROM lt_2010_dev_chk COMPARING ordty ordnr posnr.

    LOOP AT lt_2010_dev_chk INTO DATA(ls_2010_dev_chk).
      READ TABLE mt_2020_source TRANSPORTING NO FIELDS
                                WITH KEY  ordty = ls_2010_dev_chk-ordty
                                          ordnr = ls_2010_dev_chk-ordnr
                                          posnr = ls_2010_dev_chk-posnr.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_chk_source>).
        READ TABLE mt_2020_save INTO DATA(ls_chg_2010)
                                WITH KEY  ordty = ls_2010_dev_chk-ordty
                                          ordnr = ls_2010_dev_chk-ordnr
                                          posnr = ls_2010_dev_chk-posnr.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_chg_2010 TO <ls_chk_source>.
        ELSE.
          MOVE-CORRESPONDING ls_2010_dev_chk TO <ls_chk_source>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&---------------------------------------------------------------------*
  lv_percent = 20.
  progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).



*&---------------------------------------------------------------------*
* 이전 공정들에 대한 LC 재계산
*&---------------------------------------------------------------------*
  DO.

    ADD 10 TO lv_percent.
    progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

    ADD 1 TO lv_seqno.
    READ TABLE mt_main_seq_routing INTO ms_main_seq_routing WITH KEY seqno = lv_seqno.
    IF sy-subrc EQ 0.
      IF ms_main_seq_routing-maabc = 'B'. " ABC 지시자가 B라면 다음으로 공정에 포함안됨
        CONTINUE.
      ENDIF.
    ELSE. " 조회 대상 없을시 완료
      EXIT.
    ENDIF.

    REFRESH mt_2010.
    mt_2010 = VALUE #( FOR wa_2010 IN lt_2010_pre WHERE ( gong_cd = ms_main_seq_routing-chart AND
                                                          matnr   = ms_main_seq_routing-matnr )
                       ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).

    get_chain_data(
      EXPORTING
        it_data      = mt_2010
      IMPORTING
        et_dev_data  = DATA(lt_2010_temp_dev) ).

    DATA(lt_chk_2010) = lt_2010_temp_dev.
    SORT lt_chk_2010 BY ordnr.
    DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING ordnr.
    IF lines( lt_chk_2010 ) = 1. " 이후공정이 복조장 일시만 이후공정에 포함
      LOOP AT lt_2010_temp_dev INTO DATA(ls_temp_dev).
        READ TABLE mt_2020_source TRANSPORTING NO FIELDS
                                  WITH KEY  ordnr = ls_temp_dev-ordnr
                                            posnr = ls_temp_dev-posnr
                                            ordty = ls_temp_dev-ordty.
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING FIELD-SYMBOL(<ls_source_dev>).
          MOVE-CORRESPONDING ls_temp_dev TO <ls_source_dev>.
        ENDIF.
      ENDLOOP.
    ENDIF.
    REFRESH lt_chk_2010.

    READ TABLE lt_infor_matnr INTO ls_infor_matnr WITH KEY matnr = ms_main_seq_routing-matnr.
    IF lv_chk_she IS NOT INITIAL. " 연합 이후 쉬스 공정 있을경우 각각 계산 해줘야 한다.

      REFRESH lt_chk_2010.
      MOVE-CORRESPONDING mt_2020_source TO lt_chk_2010.
      SORT lt_chk_2010 BY ordnr.
      DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING ordnr.
      IF lines( lt_chk_2010 ) = 1.
*          이후공정이 복조장 일시
* 이전 수정한 여장을 추가하기 위해 조회데이터에 변경적용
        MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

        calc_lc_multy(
          EXPORTING
            iv_matnr           = ls_infor_matnr-matnr           " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j " 검사여장
          IMPORTING
            ev_result          = ev_result
            et_return          = lt_result                 " 길이 1의 문자 필드
          CHANGING
            ct_2010_dev        = lt_cal_2010 ).

        IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
          EXIT.
        ENDIF.

        IF lt_result[] IS NOT INITIAL.
          READ TABLE lt_result INTO ls_result INDEX 1.
          ev_message = ls_result-message.
          RETURN.
        ENDIF.

        IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
          mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
        ELSE.
          mv_total_plord_qty02 = mv_total_plord_qty.
        ENDIF.

        LOOP AT mt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
          <ls_2010>-inlength = ms_2010_cal-inlength.
          IF lv_chk_she IS NOT INITIAL.
            <ls_2010>-infactor = 1.
          ELSE.
            <ls_2010>-infactor = ms_2010_cal-infactor.
          ENDIF.
          <ls_2010>-qlength = ms_2010_cal-qlength.
          <ls_2010>-clength = ms_2010_cal-clength.
          <ls_2010>-slength = ms_2010_cal-slength.
          <ls_2010>-elength = ms_2010_cal-elength.
          <ls_2010>-adlength = ms_2010_cal-adlength.
          <ls_2010>-adtype = ms_2010_cal-adtype.
          MOVE-CORRESPONDING <ls_2010> TO ms_2010.

          CASE <ls_2010>-ordty.
            WHEN 'PRD'.
              ev_result = change_prd_order( ).
              IF ev_result = 'E'.
                ev_message = c_msg-e01.
                RETURN.
              ENDIF.

            WHEN 'PLN'.
              ev_result = change_pln_order( ).
              IF ev_result = 'E'.
                ev_message = c_msg-e01.
                RETURN.
              ENDIF.
          ENDCASE.
        ENDLOOP.

*       이후공정 예약 자재 변경
        LOOP AT mt_resb INTO ls_resb.
          UPDATE resb SET   bdmng = ls_resb-bdmng
                            erfmg = ls_resb-erfmg
                      WHERE rsnum = ls_resb-rsnum
                        AND rspos = ls_resb-rspos
                        AND rsart = ls_resb-rsart.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            EXIT.
          ENDIF.
        ENDLOOP.

*       CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.

      ELSEIF lines( lt_chk_2010 ) NE lines( mt_2020_source ). " 이후 공정 구성(복조장 + 단일조장)
        LOOP AT lt_chk_2010 INTO DATA(ls_chk_2010).
          REFRESH lt_cal_2010.
          LOOP AT mt_2020_source ASSIGNING <ls_2020_source> WHERE ordnr = ls_chk_2010-ordnr.
            APPEND INITIAL LINE TO lt_cal_2010 ASSIGNING FIELD-SYMBOL(<ls_cal_2010>).
            MOVE-CORRESPONDING <ls_2020_source> TO <ls_cal_2010>.
          ENDLOOP.

          IF lines( lt_cal_2010 ) = 1. " 단일 오더의 경우

            REFRESH lt_headerdata.
            APPEND INITIAL LINE TO lt_headerdata.
            MOVE-CORRESPONDING ls_chk_2010 TO ms_2020_source.

            calc_lc(
            EXPORTING
              iv_matnr            = ls_infor_matnr-matnr                " 자재 번호
              iv_fixed_scrap_qty  = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
              iv_gubun            = ms_2020_source-ordty
            IMPORTING
              ev_result           = ev_result
            CHANGING
              ct_headerdata       = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

            IF ev_result = 'F'.
              EXIT.
            ENDIF.

            LOOP AT mt_2020_lc INTO DATA(ls_2020).
              DATA(lv_tabix) = sy-tabix.
              READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
              IF lv_tabix = 1.
                LOOP AT mt_2010 ASSIGNING <ls_2010> WHERE dmord = ls_chk_2010-ordnr
                                                      AND dmline =  ls_chk_2010-posnr.
                  <ls_2010>-inlength = ls_2020-inlength.
                  <ls_2010>-infactor = 1.
                  <ls_2010>-qlength = ls_2020-qlength.
                  <ls_2010>-clength = ls_2020-clength.
                  <ls_2010>-slength = ls_2020-slength.
                  <ls_2010>-elength = ls_2020-elength.
                  <ls_2010>-adlength = ls_2020-adlength.
                  <ls_2010>-adtype = ls_2020-adtype.
                  MOVE-CORRESPONDING <ls_2010> TO ms_2010.

                  mv_total_plord_qty02 = ls_headerdata-total_plord_qty / ls_2020-infactor.
                  CASE <ls_2010>-ordty.
                    WHEN 'PRD'.
                      ev_result = change_prd_order( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                      ev_result = change_prd_charicteristic( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
                    WHEN 'PLN'.
                      ev_result = change_pln_order( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
                  ENDCASE.
                ENDLOOP.
              ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                ev_result = 'E'.
                ev_message = c_msg-e01.
                RETURN.
              ENDIF.
            ENDLOOP.

          ELSE. " 복조장의 경우
            calc_lc_multy(
              EXPORTING
                iv_matnr           = ls_infor_matnr-matnr           " 자재 번호
                iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j " 검사여장
              IMPORTING
                ev_result          = ev_result
                et_return          = lt_result                 " 길이 1의 문자 필드
              CHANGING
                ct_2010_dev        = lt_cal_2010 ).

            IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
              EXIT.
            ENDIF.

            IF lt_result[] IS NOT INITIAL.
              READ TABLE lt_result INTO ls_result INDEX 1.
              ev_message = ls_result-message.
              RETURN.
            ENDIF.

            IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
              mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
            ELSE.
              mv_total_plord_qty02 = mv_total_plord_qty.
            ENDIF.

            LOOP AT mt_2010 ASSIGNING <ls_2010> WHERE dmord = ls_chk_2010-ordnr .
              <ls_2010>-inlength = ms_2010_cal-inlength.
              IF line_exists( mt_2010[ gong_cd = 'SHE' ] ) AND ms_2010_cal-infactor > 1.
                <ls_2010>-infactor = 1.
              ELSE.
                <ls_2010>-infactor = ms_2010_cal-infactor.
              ENDIF.
              <ls_2010>-qlength = ms_2010_cal-qlength.
              <ls_2010>-clength = ms_2010_cal-clength.
              <ls_2010>-slength = ms_2010_cal-slength.
              <ls_2010>-elength = ms_2010_cal-elength.
              <ls_2010>-adlength = ms_2010_cal-adlength.
              <ls_2010>-adtype = ms_2010_cal-adtype.
              MOVE-CORRESPONDING <ls_2010> TO ms_2010.

              CASE <ls_2010>-ordty.
                WHEN 'PRD'.
                  ev_result = change_prd_order( ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.

                WHEN 'PLN'.
                  ev_result = change_pln_order( ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
              ENDCASE.
            ENDLOOP.
          ENDIF.

*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO ls_resb.
            UPDATE resb SET   bdmng = ls_resb-bdmng
                              erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.

      ELSE.

        LOOP AT mt_2020_source INTO ms_2020_source.
          READ TABLE mt_2010  ASSIGNING FIELD-SYMBOL(<ms_2010>)
                              WITH KEY  ordnr = ms_2020_source-reord
                                        posnr = ms_2020_source-reline
                                        ordty = ms_2020_source-reordty.
          IF sy-subrc NE 0.
            ev_message = c_msg-e01.
            RETURN.
          ENDIF.

          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.

          calc_lc(
          EXPORTING
            iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
            iv_gubun           = ms_2020_source-ordty
          IMPORTING
            ev_result        = ev_result
          CHANGING
            ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

          IF ev_result = 'F'.
            EXIT.
          ENDIF.

          LOOP AT mt_2020_lc INTO ls_2020.

            READ TABLE lt_headerdata INTO ls_headerdata INDEX sy-tabix.
            IF sy-tabix = 1.
              <ms_2010>-inlength = ls_2020-inlength.
              <ms_2010>-infactor = ls_2020-infactor.
              <ms_2010>-qlength = ls_2020-qlength.
              <ms_2010>-clength = ls_2020-clength.
              <ms_2010>-slength = ls_2020-slength.
              <ms_2010>-elength = ls_2020-elength.
              <ms_2010>-adlength = ls_2020-adlength.
              <ms_2010>-adtype = ls_2020-adtype.
              MOVE-CORRESPONDING <ms_2010> TO ms_2010.

              mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
              CASE <ms_2010>-ordty.
                WHEN 'PRD'.
                  ev_result = change_prd_order( ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                  ev_result = change_prd_charicteristic( ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
                WHEN 'PLN'.
                  ev_result = change_pln_order( ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
              ENDCASE.
            ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 오류종료
              ev_message = c_msg-e01.
              RETURN.
            ENDIF.
          ENDLOOP.

*  이후공정 예약 자재 변경
          LOOP AT mt_resb INTO ls_resb.
            UPDATE resb SET   bdmng = ls_resb-bdmng
                              erfmg = ls_resb-erfmg
                        WHERE rsnum = ls_resb-rsnum
                          AND rspos = ls_resb-rspos
                          AND rsart = ls_resb-rsart.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
        IF mt_2010[] IS NOT INITIAL.
          REFRESH mt_2020_source.
          LOOP AT mt_2010 INTO ms_2010.
            APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
            APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
            MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.
      IF lines( mt_2020_source ) = 1.
        READ TABLE  mt_2020_source INTO ms_2020_source INDEX 1.

* LC계산이후 이후공정 예약 자재 수량 업데이트가 진행되므로 이후 공정이 복조장일시 전체 오더 수량을 체크해야한다.
        SELECT aufnr, posnr FROM afpo
          INTO TABLE @DATA(lt_afpo)
          WHERE aufnr = @ms_2020_source-ordnr.

        IF 1 = lines( lt_afpo ) OR 0 = lines( lt_afpo ). " 복조장이 아닐시 이후공정 자체만으로 비교
          REFRESH lt_headerdata.
          APPEND INITIAL LINE TO lt_headerdata.

          calc_lc(
          EXPORTING
            iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
            iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j     " 계획된 스크랩 수량
            iv_gubun           = ms_2020_source-ordty
          IMPORTING
            ev_result        = ev_result
          CHANGING
            ct_headerdata = lt_headerdata  ). " 작업 소요량 정보 추출을 위한 테이블

          IF ev_result = 'F'.
            EXIT.
          ENDIF.

          IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
            lv_chk_she = abap_true.

            LOOP AT mt_2020_lc INTO ls_2020.
              lv_tabix = sy-tabix.
              READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
              IF lv_tabix = 1.
                LOOP AT mt_2010 ASSIGNING <ls_2010>.
                  <ls_2010>-inlength = ls_2020-inlength.
                  <ls_2010>-infactor = 1.
                  <ls_2010>-qlength = ls_2020-qlength.
                  <ls_2010>-clength = ls_2020-clength.
                  <ls_2010>-slength = ls_2020-slength.
                  <ls_2010>-elength = ls_2020-elength.
                  <ls_2010>-adlength = ls_2020-adlength.
                  <ls_2010>-adtype = ls_2020-adtype.
                  MOVE-CORRESPONDING <ls_2010> TO ms_2010.

                  mv_total_plord_qty02 = ls_headerdata-total_plord_qty / ls_2020-infactor.
                  CASE <ls_2010>-ordty.
                    WHEN 'PRD'.
                      ev_result = change_prd_order( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                      ev_result = change_prd_charicteristic( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
                    WHEN 'PLN'.
                      ev_result = change_pln_order( ).
                      IF ev_result = 'E'.
                        ev_message = c_msg-e01.
                        RETURN.
                      ENDIF.
                  ENDCASE.
                ENDLOOP.
              ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                ev_result = 'E'.
                ev_message = c_msg-e01.
                RETURN.
              ENDIF.
            ENDLOOP.

          ELSE.
            LOOP AT mt_2020_lc INTO ls_2020.
              lv_tabix = sy-tabix.
              READ TABLE lt_headerdata INTO ls_headerdata INDEX lv_tabix.
              READ TABLE mt_2010 ASSIGNING <ls_2010>  INDEX lv_tabix.
              IF sy-subrc EQ 0.
                <ls_2010>-inlength = ls_2020-inlength.
                <ls_2010>-infactor = ls_2020-infactor.
                <ls_2010>-qlength = ls_2020-qlength.
                <ls_2010>-clength = ls_2020-clength.
                <ls_2010>-slength = ls_2020-slength.
                <ls_2010>-elength = ls_2020-elength.
                <ls_2010>-adlength = ls_2020-adlength.
                <ls_2010>-adtype = ls_2020-adtype.
                MOVE-CORRESPONDING <ls_2010> TO ms_2010.
                mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
                CASE <ls_2010>-ordty.
                  WHEN 'PRD'.
                    ev_result = change_prd_order( ).
                    IF ev_result = 'E'.
                      ev_message = c_msg-e01.
                      RETURN.
                    ENDIF.
*                 특성정보 입력 - 추가여장 변경건은 특성입력 없음
                    ev_result = change_prd_charicteristic( ).
                    IF ev_result = 'E'.
                      ev_message = c_msg-e01.
                      RETURN.
                    ENDIF.
                  WHEN 'PLN'.
                    ev_result = change_pln_order( ).
                    IF ev_result = 'E'.
                      ev_message = c_msg-e01.
                      RETURN.
                    ENDIF.
                ENDCASE.
              ELSE. " LC 계산후 초과 수량이 존재 한다는 의미 이므로 계획오더 생성
                IF lines( mt_2010 ) = 1.
                  APPEND INITIAL LINE TO mt_2010 ASSIGNING <ls_2010>.
                  <ls_2010>-grpnr = ms_2020_source-grpnr.
                  <ls_2010>-ordty = 'PLN'.
                  <ls_2010>-dmord = ms_2020_source-ordnr.
                  <ls_2010>-dmline = ms_2020_source-posnr.
                  <ls_2010>-dmordty = ms_2020_source-ordty.
                  <ls_2010>-inlength = ls_2020-inlength.
                  <ls_2010>-infactor = ls_2020-infactor.
                  <ls_2010>-qlength = ls_2020-qlength.
                  <ls_2010>-clength = ls_2020-clength.
                  <ls_2010>-slength = ls_2020-slength.
                  <ls_2010>-elength = ls_2020-elength.
                  <ls_2010>-adlength = ls_2020-adlength.
                  <ls_2010>-adtype = ls_2020-adtype.
                  MOVE-CORRESPONDING <ls_2010> TO ms_2010.
                  mv_total_plord_qty02 = ls_headerdata-total_plord_qty.
                  ev_result = create_pln_order( iv_matnr = iv_matnr ).
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
                  MOVE-CORRESPONDING ms_2010 TO <ls_2010>.
                ELSE. "
                  IF ev_result = 'E'.
                    ev_message = c_msg-e01.
                    RETURN.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
            lv_chk_she = abap_true.
          ENDIF.

* 이후공정이 복조장 일시 복조장 데이터 전부 읽어 데이터 확인
          get_chain_data(
            EXPORTING
              it_data      = mt_2010
            IMPORTING
              et_dev_data  = lt_2010_dev ).

          REFRESH lt_cal_2010.
          MOVE-CORRESPONDING lt_2010_dev TO lt_cal_2010.

* 이전 수정한 여장을 추가하기 위해 조회데이터에 변경적용
          LOOP AT lt_cal_2010 ASSIGNING <ls_cal_2010>.
            READ TABLE mt_2020_source INTO ms_2020_source
                                      WITH KEY  ordnr = <ls_cal_2010>-ordnr
                                                posnr = <ls_cal_2010>-posnr
                                                ordty = <ls_cal_2010>-ordty.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ms_2020_source TO <ls_cal_2010>.
            ENDIF.
          ENDLOOP.

          calc_lc_multy(
            EXPORTING
              iv_matnr           = ls_infor_matnr-matnr                " 자재 번호
              iv_fixed_scrap_qty = ls_infor_matnr-/sapmp/fix_as_j      " 검사여장
            IMPORTING
              ev_result        = ev_result
              et_return          = lt_result                 " 길이 1의 문자 필드
            CHANGING
              ct_2010_dev        = lt_cal_2010 ).

          IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
            EXIT.
          ENDIF.

          IF lt_result[] IS NOT INITIAL.
            READ TABLE lt_result INTO ls_result INDEX 1.
            ev_message = ls_result-message.
            RETURN.
          ENDIF.

          IF lv_chk_she IS NOT INITIAL.
            mv_total_plord_qty02 = mv_total_plord_qty / ms_2010_cal-infactor.
          ELSE.
            mv_total_plord_qty02 = mv_total_plord_qty.
          ENDIF.

          LOOP AT mt_2010 ASSIGNING <ls_2010>.
            <ls_2010>-inlength = ms_2010_cal-inlength.
            IF lv_chk_she IS NOT INITIAL.
              <ls_2010>-infactor = 1.
            ELSE.
              <ls_2010>-infactor = ms_2010_cal-infactor.
            ENDIF.
            <ls_2010>-qlength = ms_2010_cal-qlength.
            <ls_2010>-clength = ms_2010_cal-clength.
            <ls_2010>-slength = ms_2010_cal-slength.
            <ls_2010>-elength = ms_2010_cal-elength.
            <ls_2010>-adlength = ms_2010_cal-adlength.
            <ls_2010>-adtype = ms_2010_cal-adtype.
            MOVE-CORRESPONDING <ls_2010> TO ms_2010.

            CASE <ls_2010>-ordty.
              WHEN 'PRD'.
                ev_result = change_prd_order( ).
                IF ev_result = 'E'.
                  ev_message = c_msg-e01.
                  RETURN.
                ENDIF.

              WHEN 'PLN'.
                ev_result = change_pln_order( ).
                IF ev_result = 'E'.
                  ev_message = c_msg-e01.
                  RETURN.
                ENDIF.
            ENDCASE.
          ENDLOOP.

        ENDIF.

      ELSE. " 이후 공정이 여러건일시 복조장 아닐시 계산 불가

        IF line_exists( mt_2010[ gong_cd = 'SHE' ] ).
          lv_chk_she = abap_true.
        ENDIF.

        IF lines( mt_2010 ) > 1 AND NOT line_exists( mt_2010[ gong_cd = 'SHE' ] ).
          ev_result = 'E'.
          ev_message = c_msg-e01.
        ENDIF.

        REFRESH lt_chk_2020.
        lt_chk_2020 = mt_2020_source.
        SORT lt_chk_2020 BY ordnr.
        DELETE ADJACENT DUPLICATES FROM lt_chk_2020 COMPARING ordnr.

        IF lines( lt_chk_2020 ) NE 1.
          ev_result = 'E'.
          ev_message = c_msg-e01.
          RETURN.
        ELSE. " 복조장 일시 오더소요량 변경, 이후공정 예약자재 수량 변경

          REFRESH lt_cal_2010.
          MOVE-CORRESPONDING mt_2020_source TO lt_cal_2010.

          calc_lc_multy(
            EXPORTING
              iv_matnr            = ls_infor_matnr-matnr           " 자재 번호
              iv_fixed_scrap_qty  = ls_infor_matnr-/sapmp/fix_as_j " 검사여장
            IMPORTING
              ev_result           = ev_result
              et_return           = lt_result                 " 길이 1의 문자 필드
            CHANGING
              ct_2010_dev         = lt_cal_2010 ).

          IF ev_result = 'F'. " 연결된 이후공정 자재가 없으면 이전공정 생성없음
            EXIT.
          ENDIF.

          IF lt_result[] IS NOT INITIAL.
            READ TABLE lt_result INTO ls_result INDEX 1.
            ev_message = ls_result-message.
            RETURN.
          ENDIF.

          mv_total_plord_qty02 = mv_total_plord_qty.

          LOOP AT mt_2010 ASSIGNING <ls_2010>.
            <ls_2010>-inlength = ms_2010_cal-inlength.
            IF lv_chk_she IS NOT INITIAL.
              <ls_2010>-infactor = 1.
            ELSE.
              <ls_2010>-infactor = ms_2010_cal-infactor.
            ENDIF.
            <ls_2010>-qlength = ms_2010_cal-qlength.
            <ls_2010>-clength = ms_2010_cal-clength.
            <ls_2010>-slength = ms_2010_cal-slength.
            <ls_2010>-elength = ms_2010_cal-elength.
            <ls_2010>-adlength = ms_2010_cal-adlength.
            <ls_2010>-adtype = ms_2010_cal-adtype.
            MOVE-CORRESPONDING <ls_2010> TO ms_2010.

            CASE <ls_2010>-ordty.
              WHEN 'PRD'.
                ev_result = change_prd_order( ).
                IF ev_result = 'E'.
                  ev_message = c_msg-e01.
                  RETURN.
                ENDIF.

              WHEN 'PLN'.
                ev_result = change_pln_order( ).
                IF ev_result = 'E'.
                  ev_message = c_msg-e01.
                  RETURN.
                ENDIF.
            ENDCASE.
          ENDLOOP.

        ENDIF.
      ENDIF.

* 이후공정 예약 자재 변경
      LOOP AT mt_resb INTO ls_resb.
        UPDATE resb   SET bdmng = ls_resb-bdmng
                          erfmg = ls_resb-erfmg
                    WHERE rsnum = ls_resb-rsnum
                      AND rspos = ls_resb-rspos
                      AND rsart = ls_resb-rsart.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
          EXIT.
        ENDIF.
      ENDLOOP.

* CHAIN 변경 데이터 옮겨준다.
      IF mt_2010[] IS NOT INITIAL.
        REFRESH mt_2020_source.
        LOOP AT mt_2010 INTO ms_2010.
          APPEND INITIAL LINE TO mt_2020_source ASSIGNING <ls_2020_source>.
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_source>.
          APPEND INITIAL LINE TO mt_2020 ASSIGNING <ls_2020_save>.
          MOVE-CORRESPONDING ms_2010 TO <ls_2020_save>.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDDO.
*&---------------------------------------------------------------------*
  progress_indicator( iv_percent = '100'  iv_text = '완료' ).
  APPEND LINES OF mt_2020 TO mt_2020_save.

ENDMETHOD.
ENDCLASS.
