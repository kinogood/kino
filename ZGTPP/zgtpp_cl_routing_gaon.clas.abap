class ZGTPP_CL_ROUTING_GAON definition
  public
  final
  create public .

public section.

  data:
    BEGIN OF MS_MAKED_2010.
        INCLUDE TYPE ZGTPPT2010.
    DATA : USE_CHK    TYPE CHAR01,
        STATUS     TYPE CHAR01,
        CHECK_JEGO TYPE CHAR01,
        CHECK_ZERO TYPE CHAR01,
        CHK_CHAR   TYPE CHAR02,
        CHK_PRD    TYPE CHAR01, "생산중 확인
      END OF MS_MAKED_2010 .
  data:
    MT_MAKED_2010 LIKE TABLE OF MS_MAKED_2010 .
  data:
    MT_NEW_2010 TYPE TABLE OF ZGTPPT2010 .
  data:
    MT_DEL_2010 TYPE TABLE OF ZGTPPT2010 .
  data:
    MT_2000 TYPE TABLE OF ZGTPPT2000 .
  data:
    BEGIN OF MS_CHAIN_2010,
        DMORD      TYPE ZGTPPT2010-DMORD,
        DMLINE     TYPE ZGTPPT2010-DMLINE,
        DMORDTY    TYPE ZGTPPT2010-DMORDTY,
        DM_SEQNO   TYPE ZGTPPT2010-ETC_SEQ,
        DM_STATUS  TYPE CHAR01,
        ORDNR      TYPE ZGTPPT2010-ORDNR,
        POSNR      TYPE ZGTPPT2010-POSNR,
        ORDTY      TYPE ZGTPPT2010-ORDTY,
        SEQ_MATNR  TYPE ZGTPPT2010-MATNR,
        ETC_SEQ    TYPE ZGTPPT2010-ETC_SEQ,
        CHK_DUP    TYPE CHAR01,
        IN_SEQNO   TYPE I,
        CHK_STATUS TYPE C,
      END OF MS_CHAIN_2010 .
  data:
    MT_CHAIN_2010 LIKE TABLE OF MS_CHAIN_2010 .
  data:
    BEGIN OF MS_GONG_2010,
        SEQNO    TYPE I,   " 공정단계
        GONG_SEQ TYPE ZEDT1010-GONG_SEQ,
        CHART    TYPE ATWRT,
        T_CHAIN  LIKE TABLE OF MS_CHAIN_2010,
      END OF MS_GONG_2010 .
  data:
    MT_GONG_2010 LIKE TABLE OF MS_GONG_2010 .
  data:
    BEGIN OF MS_MAKE_DISPLAY,
        END_ORDNR TYPE ZGTPPT2010-ORDNR,
        END_POSNR TYPE ZGTPPT2010-POSNR,
        END_ORDTY TYPE ZGTPPT2010-ORDTY,
        END_SEQNO TYPE ZGTPPT2010-ETC_SEQ,
        GCATG     TYPE ZGTPPT2000-GCATG,
        MATNR     TYPE MATNR,
        MAX_LINES TYPE I,
        T_GONG    LIKE TABLE OF MS_GONG_2010,
      END OF MS_MAKE_DISPLAY .
  data:
    MT_MAKE_DISPLAY LIKE TABLE OF MS_MAKE_DISPLAY .
  data:
    BEGIN OF MS_SEQ_ROUTING_HEADER,
        SEQNO     TYPE I,   " 공정단계
        GONG_SEQ  TYPE ZEDT1010-GONG_SEQ,
        CHART     TYPE ATWRT,
        CHART_VAL TYPE  ATWTB30,
      END OF MS_SEQ_ROUTING_HEADER .
  data:
    MT_SEQ_ROUTING_HEADER LIKE TABLE OF MS_SEQ_ROUTING_HEADER .
  data:
    BEGIN OF MS_INSP_QLENGTH,
        ORDNO   TYPE ZGTPPT2000-ORDNO,
        POSNR   TYPE ZGTPPT2000-POSNR,
        QLENGTH TYPE ZGTPPT2010-QLENGTH,
      END OF MS_INSP_QLENGTH .
  data:
    MT_INSP_QLENGTH LIKE TABLE OF MS_INSP_QLENGTH .
  data:
    BEGIN OF MS_ROUTING_CHAIN,
        MATCH_SEQNO  TYPE I,
        UP_CHART_SEQ TYPE I,
        UP_SEQNO     TYPE I,
        UP_MATNR     TYPE MATNR,
        SEQNO        TYPE I,
        MATNR        TYPE MATNR,
        MTART        TYPE MTART,
      END OF MS_ROUTING_CHAIN .
  data:
    BEGIN OF MS_SEQ_ROUTING,
        SEQNO    TYPE I,
        GONG_SEQ TYPE ZEDT1010-GONG_SEQ,
        CHART    TYPE ATWRT,
        BESKZ    TYPE ZEDT1010-BESKZ,
        NR_NEXT  TYPE I,
        T_BOM    LIKE TABLE OF MS_ROUTING_CHAIN,
      END OF MS_SEQ_ROUTING .
  data:
    MT_SEQ_ROUTING LIKE TABLE OF MS_SEQ_ROUTING .
  data:
    BEGIN OF MS_SEQ_ROUTING_SUB,
        MATNR     TYPE MATNR,
        MTART     TYPE MTART,
        T_ROUTING LIKE TABLE OF MS_SEQ_ROUTING,
      END OF MS_SEQ_ROUTING_SUB .
  data:
    MT_SEQ_ROUTING_SUB LIKE TABLE OF MS_SEQ_ROUTING_SUB .
  data MT_PLAN_ORDERS type MRPDS_PLONO .
  data MT_NEW_PLAN_ORDERS type MRPDS_PLONO .
  data MT_PRD_ORDERS type TB_BAPI_ORDER_KEY .
  data MT_PO_ORDERS type WSPO_T_EBELN .
  data MS_BDCPARAMS type CTU_PARAMS .
  data MS_BDCDATA type BDCDATA .
  data:
    MT_BDCDATA TYPE TABLE OF BDCDATA .
  data:
    MT_MESSTAB TYPE TABLE OF BDCMSGCOLL .
  data:
    MT_TOT_MESSTAB TYPE TABLE OF BDCMSGCOLL .
  data:
    MT_RESB TYPE TABLE OF RESB .
  data MV_WERKS type WERKS_D .
  data MV_GRPNR type ZGTPPT2000-GRPNR .
  data MS_2010 type ZGTPPT2010 .
  data:
    MT_2010 LIKE TABLE OF MS_2010 .
  data MV_SUCC_CNT type INT4 .
  data MV_MESSAGE type CHAR100 .
  data MV_MESSAGE_BWD type CHAR255 .
  data:
    MT_MESSAGE_BWD LIKE TABLE OF MV_MESSAGE_BWD .
  data:
    BEGIN OF MS_INFNR_INFOR,
        MATNR    TYPE MATNR,
        INFNR    TYPE INFNR,
        LIFNR    TYPE LIFNR,
        EEIND    TYPE SY-DATUM,
        LGFSB    TYPE MARC-LGFSB,
        GONG_SEQ TYPE ZEGONG_SEQ,
      END OF MS_INFNR_INFOR .
  data:
    MT_INFNR_INFOR LIKE TABLE OF MS_INFNR_INFOR .
  data:
    BEGIN OF MS_PR_ORDERS,
        BANFN TYPE EBAN-BANFN,
        BNFPO TYPE EBAN-BNFPO,
      END OF MS_PR_ORDERS .
  data:
    MT_PR_ORDERS LIKE TABLE OF MS_PR_ORDERS .
  data MV_GROUP_NAME type RZLLITAB-CLASSNAME .
  data MV_JOBNUM type I .        " Number of parallel jobs.
  data MV_SENDJOBS type I .      " Sent jobs.
  data MV_RECVJOBS type I .      " Received replies.
  data MV_EXCPFLAG type C .             " Number of RESOURCE_FAILUREs.
  data MV_PROCESSED_COUNT type I .
  data MV_RUNNING_ARFC_WPS type I .   "Counter for running WPS.
  data:
    MV_TASKNAME(20)     TYPE N .        "Task name admin..
  data MV_CALL_DRUM type CHAR01 .

  methods CONSTRUCTOR
    importing
      value(IV_WERKS) like MV_WERKS optional
      value(IV_GRPNR) like MV_GRPNR optional
      !IT_MAIN like MT_MAKE_DISPLAY optional
      !IT_SEQ_ROUTING_HEADER like MT_SEQ_ROUTING_HEADER optional
      !IT_SEQ_ROUTING_SUB like MT_SEQ_ROUTING_SUB optional
      !IT_MAKED_2010 like MT_MAKED_2010 optional
      !IT_INFNR_INFOR like MT_INFNR_INFOR optional
      !IT_INSP_QLENGTH like MT_INSP_QLENGTH optional .
  methods PROC_MAKE_PLAN_ORDER
    exporting
      !EV_RETURN type CHAR01
      !ES_MESSAGE type BAPIRETURN1 .
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
  methods CONFIRM .
  methods DELETE_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
    exporting
      !EV_RETURN type CHAR01
      !ES_MESSAGE type BAPIRETURN1 .
  methods CONVERSION_PRD_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
      !IV_AUART type AUFART
    exporting
      !EV_RETURN type CHAR01
      !ES_MESSAGE type BAPIRETURN1 .
  methods PROC_MULTY_ORDER
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
  methods PROCESS_SEPERATE
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
  methods EDIT_ADLENGTH
    importing
      !IV_ADTYPE type ZGTEADTYPE
      !IV_ADLENGTH type ZGTEADLENGTH
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_MESSAGE) type CHAR100 .
  methods CHANGE_BATCH
    importing
      !IT_2010 like MT_MAKED_2010
      !IV_PLNFL type PLAS-PLNFL
    returning
      value(RT_ERR_ORDER) type BAPI_ORDER_RETURN_TT .
  methods CREATE_PURCHASE_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PURCHASE_REQUEST
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods PROCESS_UNPEGGING_FORCE
    importing
      !IS_2010 like MS_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods PROCESS_UNPEGGING
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods PROC_PEGGING
    importing
      !IT_PEGGING_DATA like MT_MAKED_2010
      !IV_TARGET_ORDER type ZGTPPT2010-ORDNR
      !IV_TARGET_POSNR type ZGTPPT2010-POSNR
      !IV_TATGET_ORDTY type ZGTPPT2010-ORDTY
    returning
      value(RV_MESSAGE) type CHAR100 .
  methods PROCESS_SEPERATE_PR
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
  methods PROGRESS_INDICATOR
    importing
      !IV_PERCENT type ANY
      !IV_TEXT type ANY .
  methods CHECK_PACK_SET_MENGE
    importing
      !IS_2010 type ZGTPPT2010 .
  methods PROC_TANDEM_CREATE
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods PROC_TANDEM_CANCEL
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods RETURNING_PARALLEL_PRD_BDC
    importing
      !P_TASK type ANY .
  methods PROC_MERGE_ORDER
    returning
      value(RT_RESULT) type BAPI_ORDER_RETURN_TT .
protected section.
private section.

  methods GO_PARALLEL_PRD_BDC
    importing
      !IT_2010 like MT_NEW_2010 .
  methods CHECK_MAKE_PLAN_ORDER
    exporting
      !EV_RETURN type CHAR01
      !ES_MESSAGE type BAPIRETURN1 .
  methods GET_DEV_CHAIN
    importing
      !IT_2010 like MT_2010
    returning
      value(RT_RETURN) like MT_2010 .
  methods CREATE_PLAN_ORDER
    importing
      !IV_MAIN_SEQ type INT4
      !IV_GONG_SEQ type INT4
      !IS_DEV_2010 like MS_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods GET_JOJANG_MASTER .
  methods GET_FINDATE
    importing
      !IV_ORDNR type ZGTPPT2010-ORDNR
      !IV_ORDTY type ZGTPPT2010-ORDTY
    exporting
      !EV_FINDATE type SY-DATUM
      !EV_RSNUM type RSNUM .
  methods CAL_LC
    importing
      !IV_DEV_2010 type ZGTPPT2010
      !IV_BASE_DATE type SY-DATUM
      !IV_ADTYPE type ZGTEADTYPE optional
      !IV_ADLENGTH type ZGTEADLENGTH optional
    exporting
      !EV_RESULT type CHAR01
      !EV_TOTAL_PLORD_QTY type GSMNG
    changing
      !CS_CURRENT_2010 type ZGTPPT2010 .
  methods SET_CHAIN_TABLE
    importing
      !IV_MAIN_SEQ type INT4
      !IV_GONG_SEQ type ZEGONG_SEQ
      !IV_MATNR type MATNR
      !IV_SEQNO type INT4
      !IV_GUBUN type CHAR01
      !IS_2010 type ZGTPPT2010 .
  methods DELE_PLN_ORDER
    importing
      !IV_PLANNEDORDER type BAPI_PLDORD-PLDORD_NUM
    returning
      value(RV_RETURN) type CHAR01 .
  methods GET_CHAIN_TO_DELETE
    importing
      !IV_MAIN_SEQ type INT4
      !IV_GONG_SEQ type INT4
      !IS_2010 like MS_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods PROC_CONVERSION
    importing
      !IV_AUART type AUART
    changing
      !CS_2010 like MS_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods SET_PRD_CHARICTERISTIC
    importing
      !IS_2010 like MS_MAKED_2010
      !IV_GUBUN type CHAR01 optional
      !IV_SKIP_DELAY type CHAR01 optional
    returning
      value(RV_RESULT) type CHAR01 .
  methods GET_MODIFIED_FROM_CHAIN
    importing
      !IS_2010_ORIGN like MS_MAKED_2010
      !IS_2010_CHG like MS_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods MULTY_ORDER_TO_MERGE
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods MULTY_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods CALC_LC_MULTY
    importing
      !IT_DEV_2010 like MT_NEW_2010
      !IV_BASE_DATE type SY-DATUM
      !IV_ADTYPE type ZGTEADTYPE optional
      !IV_ADLENGTH type ZGTEADLENGTH optional
      !IV_MATNR type MATNR
    exporting
      !EV_RESULT type CHAR01
      !EV_TOTAL_QTY type GAMNG
    changing
      !CS_2010 type ZGTPPT2010 .
  methods CREATE_PRD_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
      !IV_MATNR type MATNR
      !IV_AUFNR type AUFNR
      !IV_AUART type AUART
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PRD_ORDER_BY_BAPI
    importing
      !IV_AUART type AUART
      !IV_FINDATE type SY-DATUM
      !IV_TOTAL_QTY type GAMNG
      !IV_CHK_RELEASE type CHAR01 optional
    changing
      !CS_2010 type ZGTPPT2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CHANGE_PRD_ORDER
    importing
      !IV_TOTAL_QTY type GAMNG
      !IV_ORDNR type ZGTPPT2010-ORDNR
      !IT_2010 like MT_NEW_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CHANGE_PLN_ORDER
    importing
      !IV_TOTAL_QTY type GAMNG
      !IV_ORDNR type ZGTPPT2010-ORDNR
    returning
      value(RV_RESULT) type CHAR01 .
  methods UPDATE_RESB
    importing
      !IT_2010 like MT_NEW_2010 .
  methods CHANGE_BATCH_BDC
    importing
      !IV_PLNFL type PLAS-PLNFL
      !IV_ORDNR type ZGTPPT2010-ORDNR
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PURCHASE_REQUEST_SINGLE
    importing
      !IS_2010 like MS_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PURCHASE_ORDER_SINGLE
    importing
      !IS_2010 like MS_MAKED_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PURCHASE_ORDER_BDC
    importing
      !IT_2010 like MT_MAKED_2010
      !IT_RESB_2010 like MT_NEW_2010
    returning
      value(RV_RESULT) type EBELN .
  methods DEL_PO_ORDER
    importing
      !IV_EBELN type ANY
      !IV_EBELP type ZGTPPT2010-POSNR optional
    returning
      value(RV_RESULT) type CHAR01 .
  methods GET_ORD_INFOR_OF_PEGGING
    importing
      !IV_ORDNR type ZGTPPT2010-ORDNR
      !IV_POSNR type ZGTPPT2010-POSNR
      !IV_ORDTY type ZGTPPT2010-ORDTY
    exporting
      !ET_2010 like MT_NEW_2010
      !ET_2010_FULL like MT_NEW_2010
      !EV_CHK_JOJANG type CHAR01 .
  methods CREATE_PR_ORDER
    importing
      !IV_FINDATE type SY-DATUM
    changing
      !CS_2010 type ZGTPPT2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods DELETE_PR_ORDER
    returning
      value(RV_RESULT) type CHAR01 .
  methods CREATE_PR_ORDER_MULTY
    importing
      !IV_FINDATE type SY-DATUM
    changing
      !CT_2010 like MT_NEW_2010
    returning
      value(RV_RESULT) type CHAR01 .
  methods CRT_PURCHASE_REQUEST
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RESULT) type BANFN .
  methods CHK_BWD_QUANTITY_DIFFERENCE .
  methods UPDATE_TANDEM_RESB
    importing
      !IS_CURRENT like MS_MAKED_2010
      !IT_CHAIN_PRE like MT_MAKED_2010
      !IV_GUBUN type CHAR01 optional .
  methods CHANGE_TANDEM_ARBPL
    importing
      !IT_2010 like MT_MAKED_2010
      !IV_GUBUN type CHAR01 .
  methods CHG_PACK_COFIRM .
  methods INIT_PARALLEL_CONDITION
    importing
      !IV_MAX_SEQ type I .
  methods MERGE_ORDER
    importing
      !IT_2010 like MT_MAKED_2010
    returning
      value(RV_RETURN) type CHAR01 .
  methods SET_DRUM_NO .
ENDCLASS.



CLASS ZGTPP_CL_ROUTING_GAON IMPLEMENTATION.


  METHOD CALC_LC_MULTY.

    DATA : LV_INLENGTH TYPE ZGTPPT2010-INLENGTH. " 총 소요량 계산을 위한 여장
    DATA : LV_CHK_SKIP_BOM.

*  검사여장 조회
    SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
      FROM MARA AS A
      INNER JOIN MAPL AS B
                           ON B~MATNR = A~MATNR
      INNER JOIN PLPO AS C
                           ON C~PLNNR = B~PLNNR
     WHERE A~MATNR = @IV_MATNR
        AND B~WERKS = @MV_WERKS
        AND B~PLNTY = 'N'
        AND B~LOEKZ = ' '
        AND C~PLNTY = 'N'
        AND C~LOEKZ = ' '
        AND C~PLNKN = '00000001'
        INTO @DATA(LS_INFOR_MATNR).

    READ TABLE IT_DEV_2010 INTO DATA(LS_DEV_2010) INDEX 1.

*  공정정보 조회
    SELECT DISTINCT A~MATNR,
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
            WHERE A~MATNR = @LS_DEV_2010-MATNR
                AND A~WERKS  = @MV_WERKS
                AND A~STLAN = '1'
                AND A~STLAL  = '01'
                AND B~STLTY  = 'M'
                AND B~LKENZ NE 'X'
                AND C~LKENZ NE 'X'
                AND C~IDNRK      = @IV_MATNR
             INTO TABLE @DATA(LT_CALCULTAB).
    .
* 하나의 공정만 이용 가능
    READ TABLE LT_CALCULTAB INTO DATA(LS_CALCULTAB) INDEX 1.

    CS_2010-ADTYPE = IV_ADTYPE.
    CS_2010-QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
    CS_2010-ADLENGTH = IV_ADLENGTH .

    CS_2010-CLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_J.
    CS_2010-SLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_E.
    CS_2010-ELENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_L.

    CLEAR LV_CHK_SKIP_BOM.
** 표중여장에 여장이 0으로 들어가 있을 경우 봄으로 수량 조회 하는 부분 스킵.
*    SELECT SINGLE * FROM ZGTPPT2070
*     WHERE GRPNR = @MV_GRPNR
*        AND MATNR = @CS_2010-MATNR
*        AND ORDNO IS INITIAL
*       INTO @DATA(LS_2070).
*    IF SY-SUBRC EQ 0.
*      IF LS_2070-QLENGTH = 0 AND LS_2070-CLENGTH = 0.
*        LV_CHK_SKIP_BOM = ABAP_TRUE.
*      ENDIF.
*    ENDIF.

    IF LV_CHK_SKIP_BOM = ABAP_FALSE.
      CONFIRM_QLENGTH(
        EXPORTING
          IV_GRPNR   = MV_GRPNR                  " 조장 구성표 번호
          IV_MATNR   = IV_MATNR                 " 자재 번호
          IV_ORDNR   = LS_DEV_2010-ORDNR                 " 오더번호
          IV_POSNR   = LS_DEV_2010-POSNR                 " 판매 문서 항목
          IV_ORDTY   = LS_DEV_2010-ORDTY                 " 오더유형
        CHANGING
          CV_QLENGTH =  CS_2010-QLENGTH                " 검사여장
          CV_CLENGTH =  CS_2010-CLENGTH                 " 연결여장
      ).
    ENDIF.

    CASE CS_2010-DMORDTY.
      WHEN 'SM' OR 'SO'.
        ADD CS_2010-CLENGTH TO CS_2010-QLENGTH.
        CLEAR CS_2010-CLENGTH.
    ENDCASE.

* LC 계산

* 조장(총소요량)
    CLEAR EV_TOTAL_QTY.
    LOOP AT IT_DEV_2010 INTO LS_DEV_2010.
      CLEAR LV_INLENGTH.
      LV_INLENGTH = LS_DEV_2010-INLENGTH + LS_DEV_2010-QLENGTH + LS_DEV_2010-ADLENGTH +
                           LS_DEV_2010-CLENGTH + LS_DEV_2010-SLENGTH + LS_DEV_2010-ELENGTH.

      LV_INLENGTH =  LV_INLENGTH * LS_DEV_2010-INFACTOR.

      LV_INLENGTH = GET_METERIAL_BOM_QUAN(
                                  IV_DATE      =  IV_BASE_DATE                " ABAP system field: Current date of application server
                                  IV_PLANT     =  MV_WERKS                " 플랜트
                                  IV_MATNR     = LS_DEV_2010-MATNR                 " 자재 번호
                                  IV_CHK_MATNR = IV_MATNR                 " 자재 번호
                                  IV_EMENG     = LV_INLENGTH ).                 " 기준 수량

      ADD LV_INLENGTH TO EV_TOTAL_QTY.

    ENDLOOP.


    CS_2010-INLENGTH = EV_TOTAL_QTY.
    CS_2010-INFACTOR = 1.

    EV_TOTAL_QTY  = EV_TOTAL_QTY + CS_2010-QLENGTH + CS_2010-ADLENGTH +
                             CS_2010-CLENGTH + CS_2010-SLENGTH + CS_2010-ELENGTH.

* 계산식 존재하나 후행 공정이 하나씩만 생길수 있기 때문에 미적용
    CASE LS_CALCULTAB-/SAPMP/MET_LRCH.
      WHEN SPACE. " 길이 전달 방법 - 오더 생산량: 조장 * 조장 수

      WHEN '1'.       " 전체 릴 계산 방법 -
*            조장수가 1인 경우 조장 수 계산하지 않음, 계산조장수는 조장수를 넘을 수 없음
*                 검사포함: 조장 + 검사여장
*                 오더 소요량1 = 첫번째길이 + (검사포함 * 계산조장수) + 각길이 > 최대생산길이
*                 계산조장수 : 최대생산길이를 넘기는 첫번째 조장 수, Loop?
*                 잔여조장수 = 조장수 - 계산조장수
*                 Offcut = 소요량1 - 최대생산길이
*                 오더 소요량2 = (검사포함 * 잔여조장수) + 각길이 + Offcut


      WHEN '2'.        " 길이 집계 계산 방법
*            검사포함: 조장 + 검사여장
*            조장수가 1인 경우 조장 수 계산하지 않음, 계산조장 수는 조장수를 넘을 수 없음
*            오더 소요량1 = (검사포함 * 계산조장수) + 각길이 < 최대생산길이
*            잔여조장수 = 조장수 - 계산조장수
*            오더 소요량2 = (검사포함 * 잔여조장수) + 각길이 < 최대생산길이


    ENDCASE.

    IF EV_TOTAL_QTY > LS_CALCULTAB-/SAPMP/MAX_FERTL AND
      ( LS_CALCULTAB-/SAPMP/MET_LRCH = '1' OR LS_CALCULTAB-/SAPMP/MET_LRCH = '2' ).
      EV_RESULT = 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD CAL_LC.

    DATA : LV_INLENGTH TYPE ZGTPPT2010-INLENGTH. " 총 소요량 계산을 위한 여장
    DATA : LV_CHK_SKIP_BOM.

    SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
      FROM MARA AS A
      INNER JOIN MAPL AS B
                           ON B~MATNR = A~MATNR
      INNER JOIN PLPO AS C
                           ON C~PLNNR = B~PLNNR
     WHERE A~MATNR = @CS_CURRENT_2010-MATNR
        AND B~WERKS = @MV_WERKS
        AND B~PLNTY = 'N'
        AND B~LOEKZ = ' '
        AND C~PLNTY = 'N'
        AND C~LOEKZ = ' '
        AND C~PLNKN = '00000001'
        INTO @DATA(LS_INFOR_MATNR).

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
            WHERE A~MATNR = @IV_DEV_2010-MATNR
                AND A~WERKS  = @MV_WERKS
                AND A~STLAN = '1'
                AND A~STLAL  = '01'
                AND B~STLTY  = 'M'
                AND B~LKENZ NE 'X'
                AND C~LKENZ NE 'X'
                AND C~IDNRK      = @CS_CURRENT_2010-MATNR
             INTO TABLE @DATA(LT_CALCULTAB).

* 하나의 공정만 이용 가능
    READ TABLE LT_CALCULTAB INTO DATA(LS_CALCULTAB) INDEX 1.

    CS_CURRENT_2010-ADTYPE = IV_ADTYPE.
    CS_CURRENT_2010-QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
    CS_CURRENT_2010-ADLENGTH = IV_ADLENGTH .

    LV_INLENGTH = IV_DEV_2010-INLENGTH + IV_DEV_2010-QLENGTH + IV_DEV_2010-ADLENGTH +
                         IV_DEV_2010-CLENGTH + IV_DEV_2010-SLENGTH + IV_DEV_2010-ELENGTH.

    CLEAR LV_CHK_SKIP_BOM.
* 표중여장에 여장이 0으로 들어가 있을 경우 봄으로 수량 조회 하는 부분 스킵.
    SELECT SINGLE * FROM ZGTPPT2070
     WHERE GRPNR = @MV_GRPNR
        AND MATNR = @CS_CURRENT_2010-MATNR
        AND ORDNO IS INITIAL
       INTO @DATA(LS_2070).
    IF SY-SUBRC EQ 0.
      IF LS_2070-QLENGTH = 0 AND LS_2070-CLENGTH = 0.
        LV_CHK_SKIP_BOM = ABAP_TRUE.
      ENDIF.
    ENDIF.

    IF LV_CHK_SKIP_BOM = ABAP_FALSE.
      LV_INLENGTH = GET_METERIAL_BOM_QUAN(
                        IV_DATE      =  IV_BASE_DATE                " ABAP system field: Current date of application server
                        IV_PLANT     =  MV_WERKS                " 플랜트
                        IV_MATNR     = IV_DEV_2010-MATNR                 " 자재 번호
                        IV_CHK_MATNR = CS_CURRENT_2010-MATNR                 " 자재 번호
                        IV_EMENG     = LV_INLENGTH ).                 " 기준 수량
    ENDIF.

    CS_CURRENT_2010-INLENGTH = LV_INLENGTH.

    CS_CURRENT_2010-CLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_J.
    CS_CURRENT_2010-SLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_E.
    CS_CURRENT_2010-ELENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_L.

    CONFIRM_QLENGTH(
      EXPORTING
        IV_GRPNR   = MV_GRPNR                  " 조장 구성표 번호
        IV_MATNR   = CS_CURRENT_2010-MATNR                 " 자재 번호
        IV_ORDNR   = IV_DEV_2010-ORDNR                 " 오더번호
        IV_POSNR   = IV_DEV_2010-POSNR                 " 판매 문서 항목
        IV_ORDTY   = IV_DEV_2010-ORDTY                 " 오더유형
      CHANGING
        CV_QLENGTH =  CS_CURRENT_2010-QLENGTH                " 검사여장
        CV_CLENGTH =  CS_CURRENT_2010-CLENGTH                 " 연결여장
    ).

    CASE CS_CURRENT_2010-DMORDTY.
      WHEN 'SM' OR 'SO'.
        ADD CS_CURRENT_2010-CLENGTH TO CS_CURRENT_2010-QLENGTH.
        CLEAR CS_CURRENT_2010-CLENGTH.
    ENDCASE.

* LC 계산 상위 오더 단일 조장수 이므로 바로 계산후 종료
    EV_TOTAL_PLORD_QTY = LV_INLENGTH * IV_DEV_2010-INFACTOR.
    EV_TOTAL_PLORD_QTY  = EV_TOTAL_PLORD_QTY + CS_CURRENT_2010-QLENGTH + CS_CURRENT_2010-ADLENGTH +
                                         CS_CURRENT_2010-CLENGTH + CS_CURRENT_2010-SLENGTH + CS_CURRENT_2010-ELENGTH.

    IF EV_TOTAL_PLORD_QTY > LS_CALCULTAB-/SAPMP/MAX_FERTL AND
      ( LS_CALCULTAB-/SAPMP/MET_LRCH = '1' OR LS_CALCULTAB-/SAPMP/MET_LRCH = '2' ).
      EV_RESULT = 'E'.
    ENDIF.

    CS_CURRENT_2010-INFACTOR = 1.

  ENDMETHOD.


  METHOD CHANGE_BATCH.

    DATA : LV_CHK_ERR TYPE CHAR01.

    LOOP AT IT_2010 INTO DATA(LS_2010).
      CLEAR LV_CHK_ERR.
      LV_CHK_ERR = CHANGE_BATCH_BDC( IV_PLNFL = IV_PLNFL IV_ORDNR = LS_2010-ORDNR ).
      IF LV_CHK_ERR EQ 'E'.
        APPEND INITIAL LINE TO RT_ERR_ORDER ASSIGNING FIELD-SYMBOL(<LS_ERR_ORDER>).
        <LS_ERR_ORDER>-ORDER_NUMBER = MS_2010-ORDNR.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method CHANGE_BATCH_BDC.

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
    __BDC_FIELD : 'CAUFVD-AUFNR' IV_ORDNR,
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

  endmethod.


  METHOD CHANGE_PLN_ORDER.

    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.
    DATA : LS_HEADER TYPE BAPIPLAF_I2.
    DATA : LS_HEADERX TYPE BAPIPLAF_I2X.

    LS_HEADER-TOTAL_PLORD_QTY = IV_TOTAL_QTY.
    LS_HEADERX-TOTAL_PLORD_QTY = 'X'.

    LV_PLANNEDORDER = IV_ORDNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_PLANNEDORDER
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


  METHOD CHANGE_PRD_ORDER.

    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_LINE_TOTAL TYPE GAMNG.
    DATA : LS_ORDERDATA TYPE  BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE  BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2 .

    LV_AUFNR = IV_ORDNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_AUFNR
      IMPORTING
        OUTPUT = LV_AUFNR.

* 품목이 하나 인지 확인.(한개시 바피, 여러개시 bdc)
    SELECT AUFNR, POSNR FROM AFPO
      INTO TABLE @DATA(LT_AFPO)
      WHERE AUFNR = @LV_AUFNR.

    IF 1 = LINES( LT_AFPO ).
      LS_ORDERDATA-QUANTITY = IV_TOTAL_QTY.
      LS_ORDERDATAX-QUANTITY = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
        EXPORTING
          NUMBER     = LV_AUFNR
          ORDERDATA  = LS_ORDERDATA
          ORDERDATAX = LS_ORDERDATAX
        IMPORTING
          RETURN     = LS_RETURN.

      IF LS_RETURN-TYPE NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
        WAIT UP TO 1 SECONDS.
      ELSE.
        RV_RESULT = ABAP_TRUE.
        RETURN.
      ENDIF.


    ELSE. " 여러건의 경우 bdc로 처리
      WAIT UP TO 1 SECONDS.
      LOOP AT IT_2010 INTO DATA(LS_2010).
        CLEAR LV_LINE_TOTAL.
        LV_LINE_TOTAL = ( LS_2010-INLENGTH * LS_2010-INFACTOR ) +
                                LS_2010-QLENGTH + LS_2010-CLENGTH + LS_2010-SLENGTH +
                                LS_2010-ELENGTH + LS_2010-ADLENGTH.

        UPDATE AFPO SET PSMNG = LV_LINE_TOTAL
          WHERE AUFNR = LV_AUFNR
            AND POSNR = LS_2010-POSNR+2(4).
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDLOOP.

      REFRESH : MT_BDCDATA, MT_MESSTAB.
      CLEAR MS_BDCPARAMS.

      __SETTING_BDC_PARAMS.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_AUFNR,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.
*     품목전체 선택
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=MILL_BT_SEL_ALL'.
*     재계산 클릭
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=MILL_MP_HEADER_QUANT'.
*
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

*      __BDC_DYNPRO 'SAPLSPO1' '0300'.
*      __BDC_FIELD : 'BDC_OKCODE' 'YES'.

      __BDC_TRANSACTION 'CO02'.

      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                             OR MSGTYP = 'E'
                                                             OR MSGTYP = 'X'.
        RV_RESULT = 'E'.
        RETURN.
      ENDLOOP.

      RV_RESULT = 'S'.

    ENDIF.

  ENDMETHOD.


  METHOD CHECK_MAKE_PLAN_ORDER.

    DATA : LV_CHK_AVAILABLE. " 조장 구성 가능 여부 체크
    DATA : LT_IN_TAB LIKE MT_2010.
    DATA : LT_OUT_TAB LIKE MT_2010.

    LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

      LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER.
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        IF SY-SUBRC EQ 0.
          LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>).
            IF <LS_CHAIN>-ORDNR IS INITIAL.
              CASE <LS_CHAIN>-DMORDTY.
                WHEN 'PO' OR 'SO'." 해당 오더가 완제품 공정일경우 체크없음
                  LV_CHK_AVAILABLE = ABAP_TRUE.
                  EV_RETURN = 'S'.
                  RETURN.
                WHEN 'PO'. "구매오더 구조상 상응하는 이후공정정보를 찾을수 없으므로 건너띄어준다.
                  CONTINUE.
                WHEN 'PRD'. " 현재는 생산 오더만 체크
                  CLEAR MS_MAKED_2010.
                  READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                                  POSNR = <LS_CHAIN>-DMLINE
                                                                                                  ORDTY = <LS_CHAIN>-DMORDTY.
                  IF SY-SUBRC EQ 0.
                    IF <LS_CHAIN>-CHK_DUP = ABAP_TRUE.
                      READ TABLE MT_MAKED_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = MS_MAKED_2010-REORD
                                                                                                POSNR = MS_MAKED_2010-RELINE
                                                                                                ORDTY = MS_MAKED_2010-REORDTY.
                      IF SY-SUBRC EQ 0. " 해당오더 이전 공정 존재시 생성 대상 아님
                        CONTINUE.
                      ENDIF.
                    ENDIF.

                    CASE  MS_MAKED_2010-STATUS.
                      WHEN 'C'.
                        LV_CHK_AVAILABLE = ABAP_TRUE.
                        EV_RETURN = 'S'.
                        RETURN.
                      WHEN 'E'. "오류 이므로 처리 불가능.
                      WHEN 'R'.
                        IF MS_MAKED_2010-CHK_PRD IS INITIAL.
                          LV_CHK_AVAILABLE = ABAP_TRUE.
                          EV_RETURN = 'S'.
                          RETURN.
                        ENDIF.
                    ENDCASE.

                  ENDIF.

                WHEN OTHERS.
                  LV_CHK_AVAILABLE = ABAP_TRUE.
                  EV_RETURN = 'S'.
                  RETURN.
              ENDCASE.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF LV_CHK_AVAILABLE IS INITIAL.
      EV_RETURN = 'E'.
      ES_MESSAGE-MESSAGE = '개별조장 구성할 수 있는 공정이 없습니다.'(E01).
    ENDIF.

  ENDMETHOD.


  METHOD CONFIRM.

    DATA : LS_2010 TYPE ZGTPPT2010.
    DATA : LT_2020 TYPE TABLE OF ZGTPPT2020.
    DATA : LT_ZPPTC002 TYPE TABLE OF ZPPTC002.

*  신선 작업 지시된 경우 변경된 조장체인의 데이터가
*  신선작업지시에 등록된 조장체인의 수량보다 클경우 메시지 처리를 위해 로직구성
    IF MV_WERKS = '6500'.
      SELECT SINGLE * FROM ZGTPPT2013
        INTO @DATA(LS_2013)
       WHERE GRPNR = @MV_GRPNR.
      IF SY-SUBRC EQ 0 AND LS_2013 IS NOT INITIAL.
        CHK_BWD_QUANTITY_DIFFERENCE( ).
      ENDIF.
    ENDIF.

*  전주(광) 조장 저장시 드럼넘버 채번
    SET_DRUM_NO( ).

*    CHG_PACK_COFIRM( ).


    LOOP AT MT_NEW_2010 INTO LS_2010.

*    오더 검사여장 시료여장 업데이트
      IF LS_2010-ORDTY = 'PRD'.
        APPEND INITIAL LINE TO LT_ZPPTC002 ASSIGNING FIELD-SYMBOL(<LS_SAVE_DATA>).
        <LS_SAVE_DATA>-AUFNR = LS_2010-ORDNR.
        <LS_SAVE_DATA>-POSNR = LS_2010-POSNR+2(4).
        <LS_SAVE_DATA>-PSAMG = LS_2010-QLENGTH + LS_2010-CLENGTH.
*        IF ( LS_2010-DMORDTY = 'SO' OR LS_2010-DMORDTY = 'SM' ) AND LS_2010-INLENGTH > TRUNC( LS_2010-INLENGTH ).
*          <LS_SAVE_DATA>-PSAMG = <LS_SAVE_DATA>-PSAMG + 1 - ( LS_2010-INLENGTH - TRUNC( LS_2010-INLENGTH ) ).
*        ENDIF.

        IF LS_2010-ADTYPE = 'A'.
          <LS_SAVE_DATA>-PSMNG = LS_2010-ADLENGTH.
        ENDIF.
      ENDIF.
    ENDLOOP.


    DELETE FROM ZGTPPT2010 WHERE GRPNR = MV_GRPNR.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
    IF MT_NEW_2010[] IS NOT INITIAL.
      MODIFY ZGTPPT2010 FROM TABLE MT_NEW_2010.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.


* ZGTPPT2020 저장 기존 데이터 맥스순번 + 1 로 어팬드
    SELECT SINGLE MAX( REVNO )  FROM ZGTPPT2020
         INTO @DATA(LV_MAX_REVNO)
        WHERE GRPNR = @MV_GRPNR.

    SELECT * FROM ZGTPPT2010
      INTO CORRESPONDING FIELDS OF TABLE LT_2020
      WHERE GRPNR = MV_GRPNR.

    LOOP AT LT_2020 ASSIGNING FIELD-SYMBOL(<LS_2020>).
      <LS_2020>-REVNO = LV_MAX_REVNO + 1.
      <LS_2020>-AENAM = SY-UNAME.
      <LS_2020>-AEDAT = SY-DATUM.
    ENDLOOP.

    IF LT_2020[] IS NOT INITIAL.
      MODIFY ZGTPPT2020 FROM TABLE LT_2020.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    IF LT_ZPPTC002[] IS NOT INITIAL.
      MODIFY ZPPTC002 FROM TABLE LT_ZPPTC002.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

* 군포 포장재 자동지정 수행 추가
    IF MV_CALL_DRUM = ABAP_TRUE.
      DATA : LT_AUFNR TYPE RANGE OF AUFNR.

      LT_AUFNR = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( ( DMORDTY = 'SM'
                                                        OR   DMORDTY = 'SO' )
                                                       AND   ORDTY = 'PRD' )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).

      IF LT_AUFNR[] IS NOT INITIAL.
        SORT LT_AUFNR BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

        SUBMIT ZGTPPR2330
                         WITH P_SLSORD = ' '
                         WITH P_PRDORD = 'X'
                         WITH S_AUFNR IN LT_AUFNR
                         WITH P_DRUM = 'H'
                         WITH P_AUTO = ABAP_TRUE
                         WITH P_BATCH = ABAP_TRUE
                         AND RETURN.

      ENDIF.

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
       WHERE GRPNR = @IV_GRPNR
         AND ORDTY = @LV_CHK_ORDTY
         AND ORDNR = @LV_CHK_ORDNR
         AND POSNR = @LV_CHK_POSNR
        INTO ( @LV_CHK_DMORD, @LV_CHK_DMLINE, @LV_CHK_DMORDTY ).
      IF SY-SUBRC EQ 0.
* (SM) 생산오더 완제품의 경우 상위와 자신이 동일
        IF LV_CHK_DMORDTY = LV_CHK_ORDTY AND
           LV_CHK_DMORD = LV_CHK_ORDNR AND
           LV_CHK_DMLINE = LV_CHK_POSNR.
          EXIT.
        ENDIF.

        MOVE : LV_CHK_DMORD TO LV_CHK_ORDNR,
           LV_CHK_DMLINE TO LV_CHK_POSNR,
           LV_CHK_DMORDTY TO LV_CHK_ORDTY.
      ELSE.
        READ TABLE MT_NEW_2010 INTO DATA(LS_2020_CHK2) WITH KEY GRPNR = IV_GRPNR
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
          EXIT.
        ENDIF.
      ENDIF.

    ENDDO.

*  판매오더 기준 설정된 표준여장 존재여부 확인
    SELECT SINGLE * FROM ZGTPPT2070
     WHERE GRPNR = @IV_GRPNR
        AND MATNR = @IV_MATNR
        AND ORDNO = @LV_CHK_DMORD
        AND POSNR = @LV_CHK_DMLINE
      INTO  @DATA(LS_2070).
    IF SY-SUBRC EQ 0. " 존재시 여장세팅
      CV_QLENGTH = LS_2070-QLENGTH.
      CV_CLENGTH = LS_2070-CLENGTH.
    ELSE. "자재 기준 표중여장 존재확인
      SELECT SINGLE * FROM ZGTPPT2070
       WHERE GRPNR = @IV_GRPNR
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

    MV_WERKS = IV_WERKS.
    MV_GRPNR = IV_GRPNR.

    MT_MAKE_DISPLAY = IT_MAIN.
    MT_SEQ_ROUTING_HEADER = IT_SEQ_ROUTING_HEADER.
    SORT MT_SEQ_ROUTING_HEADER BY SEQNO DESCENDING.
    MT_SEQ_ROUTING_SUB = IT_SEQ_ROUTING_SUB.
    MT_MAKED_2010 = IT_MAKED_2010.
    MT_INFNR_INFOR = IT_INFNR_INFOR.
    MT_INSP_QLENGTH = IT_INSP_QLENGTH.

  ENDMETHOD.


  METHOD CONVERSION_PRD_ORDER.

    DATA : LS_2010 LIKE MS_MAKED_2010.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_CONTINUE.
    DATA : LV_PERCENT(2) TYPE N.
    DATA : LT_CHG_2010 LIKE MT_NEW_2010.
    DATA : LT_PARALLEL_MOSU TYPE TABLE OF ZGTPPT2010.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_INDEX TYPE I.

    DATA : BEGIN OF LS_HISTORY,
             ASIS_ORDER TYPE ZGTPPT2010-ORDNR,
             TOBE_ORDER TYPE ZGTPPT2010-ORDNR,
           END OF LS_HISTORY.
    DATA : LT_HISTORY LIKE TABLE OF LS_HISTORY.

    DATA : LV_CHK_LINE TYPE I.
    DATA : LV_CHK_PARALLEL.

* 100건 이상의 건에 병렬처리로 bdc 진행함. 병렬처리를 위한 초기 세팅
    LV_CHK_LINE = LINES( IT_2010 ).
    IF LV_CHK_LINE > 100.
      LV_CHK_PARALLEL = ABAP_TRUE.
      INIT_PARALLEL_CONDITION( IV_MAX_SEQ = 5 ).
    ENDIF.

    CLEAR MV_SUCC_CNT.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    LV_PERCENT = '20'.

    REFRESH MT_RESB.
    REFRESH MT_MESSTAB.

    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      ADD 1 TO LV_INDEX.

      IF LS_CHK_2010-ORDTY NE 'PLN'.
        CONTINUE.
      ENDIF.

      IF LV_PERCENT < 60.
        ADD 1 TO LV_PERCENT.
      ENDIF.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '처리중..' ).

      CLEAR LS_2010.
      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      EV_RETURN = PROC_CONVERSION(
                    EXPORTING
                      IV_AUART = IV_AUART                 " 판매 문서 유형
                    CHANGING
                      CS_2010  = LS_2010 ).

      IF EV_RETURN = 'E'.
        APPEND INITIAL LINE TO MT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSTAB>).
        <LS_MESSTAB>-MSGV1 = MV_MESSAGE.
        EXIT.
      ENDIF.

      LV_CHK_CONTINUE = ABAP_TRUE.
* 오더가 변경된 내역은 체인구성 반영되어야 한다.
* 생산오더로 변경시 기존 계획 오더 삭제 됨
* 변경된 현재 오더로 연결된 이전 공정과 이후 공정의 연결고리 변경
      LV_RETURN = GET_MODIFIED_FROM_CHAIN(
                    IS_2010_ORIGN = LS_CHK_2010                 " [GT] 오더 연결 정보
                    IS_2010_CHG   = LS_2010 ).                " [GT] 오더 연결 정보

      CLEAR LS_HISTORY.
      LS_HISTORY-ASIS_ORDER = LS_CHK_2010-ORDNR.
      LS_HISTORY-TOBE_ORDER = LS_2010-ORDNR.
      APPEND LS_HISTORY TO LT_HISTORY.

      IF LV_CHK_PARALLEL = ABAP_TRUE.
        APPEND INITIAL LINE TO LT_CHG_2010 ASSIGNING FIELD-SYMBOL(<LS_CHG_2010>).
        MOVE LS_2010 TO <LS_CHG_2010>.

*      20건 단위로 병렬 처리
        IF LINES( LT_CHG_2010 ) = 20.
          GO_PARALLEL_PRD_BDC( IT_2010 = LT_CHG_2010 ).
          REFRESH LT_CHG_2010.

        ELSE.
*        마지막 라인처리
          IF LV_INDEX = LV_CHK_LINE AND LT_CHG_2010 IS NOT INITIAL.
            GO_PARALLEL_PRD_BDC( IT_2010 = LT_CHG_2010 ).
            REFRESH LT_CHG_2010.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.



    WAIT UP TO '0.3' SECONDS.

    IF LV_CHK_PARALLEL = ABAP_TRUE.
* 병렬처리 종료까지 기다린다.
      IF EV_RETURN = 'E' AND LT_CHG_2010 IS NOT INITIAL.
        GO_PARALLEL_PRD_BDC( IT_2010 = LT_CHG_2010 ).
        REFRESH LT_CHG_2010.
      ENDIF.

      WAIT UNTIL MV_RECVJOBS >= MV_SENDJOBS.

    ELSE.

      LV_PERCENT = '80'.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '생산오더 특성값 반영중..' ).



* 성공한 오더의 특성값 반영
      LOOP AT LT_HISTORY INTO LS_HISTORY.

        ADD 1 TO MV_SUCC_CNT.

        READ TABLE MT_NEW_2010 INTO DATA(LS_NEW_2010) WITH KEY ORDNR = LS_HISTORY-TOBE_ORDER
                                                                              ORDTY = 'PRD'.
        IF SY-SUBRC EQ 0.
          CASE LS_NEW_2010-DMORDTY.
            WHEN 'SO'.
*        MOVE-CORRESPONDING CS_2010 TO LS_2010.
*        CHECK_PACK_SET_MENGE( IS_2010 = LS_2010 ).

            WHEN OTHERS.
* 특성값 세팅
              CLEAR LS_2010.
              MOVE-CORRESPONDING LS_NEW_2010 TO LS_2010.
              CLEAR LV_RETURN.
              LV_RETURN = SET_PRD_CHARICTERISTIC(
                                  EXPORTING  IS_2010   = LS_2010
                                                   IV_SKIP_DELAY = ABAP_TRUE ).                " [GT] 오더 연결 정보
              IF LV_RETURN = 'E'.
                MV_MESSAGE = LS_HISTORY-ASIS_ORDER && '를'.
                CONCATENATE '계획오더' MV_MESSAGE '생산 오더로 전환 중 오류 발생하였습니다. - BDC'
                              INTO MV_MESSAGE SEPARATED BY SPACE.
                APPEND INITIAL LINE TO MT_MESSTAB ASSIGNING <LS_MESSTAB>.
                <LS_MESSTAB>-MSGV1 = MV_MESSAGE.
                MV_SUCC_CNT = MV_SUCC_CNT - 1.

                EV_RETURN = 'E'.

              ENDIF.
          ENDCASE.
        ENDIF.
      ENDLOOP.

    ENDIF.
    WAIT UP TO '0.3' SECONDS.

    LV_PERCENT = '90'.
    PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '구성부품 반영중..' ).

    LOOP AT LT_HISTORY INTO LS_HISTORY.

      SELECT A~*
        FROM RESB AS A
        INNER JOIN MARA AS B
                        ON B~MATNR = A~MATNR
        INNER JOIN MARC AS C
                        ON C~MATNR = A~MATNR
        INNER JOIN ZGTCVMSTVAL AS D
                        ON D~MATNR = C~MATNR
                       AND D~WERKS = C~WERKS
        INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
        WHERE B~MTART = 'MCHF'
          AND C~WERKS = @MV_WERKS
          AND C~BESKZ IN ('E', 'X')
          AND D~PDCAPROCCODE NE 'BWD'
          AND A~AUFNR = @LS_HISTORY-TOBE_ORDER.

*  이후공정 예약 자재 변경
      LOOP AT LT_RESB INTO DATA(LS_RESB).
        READ TABLE MT_RESB INTO DATA(LS_ORIGN) WITH KEY RSNUM = LS_HISTORY-ASIS_ORDER
                                                                      MATNR = LS_RESB-MATNR.
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

    ENDLOOP.


* 오더가 변경된 정보가 있다면 변경된 정보 수정
    IF LV_CHK_CONTINUE = ABAP_TRUE.
      PROGRESS_INDICATOR( IV_PERCENT = 98  IV_TEXT = '조장체인 저장중..' ).

* 오더 정보 변경 되었으므로 포장재 확인후 재설정.
      CHG_PACK_COFIRM( ).

      CONFIRM( ).

      IF EV_RETURN = 'E'.
        RETURN.
      ENDIF.
      DATA : LV_INDEX_C(10).
      LV_INDEX_C = MV_SUCC_CNT.
      CONDENSE LV_INDEX_C.

      EV_RETURN = 'S'.
      CONCATENATE MV_GRPNR '계획오더' LV_INDEX_C '건 전환하였습니다.' INTO ES_MESSAGE-MESSAGE SEPARATED BY SPACE.

    ENDIF.


  ENDMETHOD.


  METHOD CREATE_PLAN_ORDER.

    DATA : LT_2010_TEMP TYPE TABLE OF ZGTPPT2010. " 생산할 하위 공정.
    DATA : LS_2010_TEMP TYPE ZGTPPT2010. " 생산할 하위 공정.
    DATA : LT_2010_CHK TYPE TABLE OF ZGTPPT2010. " 생산할 하위 공정.

    DATA : BEGIN OF LS_MATNR,
             MATNR TYPE MATNR,
           END OF LS_MATNR.
    DATA : LT_MATNR LIKE TABLE OF LS_MATNR.

    DATA : BEGIN OF LS_CHAINS,
             GUBUN     TYPE CHAR01,
             GONG_SEQ  TYPE ZEDT1010-GONG_SEQ,
             CHART_SEQ TYPE I,
             DM_MATNR  TYPE MATNR,
             DM_SEQNO  TYPE I,
             MATNR     TYPE MATNR,
             MTART     TYPE MTART,
             BESKZ     TYPE ZEDT1010-BESKZ,
             IN_ORDNR  TYPE ZGTPPT2010-ORDNR,
             IN_SEQNO  TYPE I,
           END OF LS_CHAINS.
    DATA : LS_CHAINS_D LIKE LS_CHAINS.
    DATA : LT_CHAINS LIKE TABLE OF LS_CHAINS.

    DATA : LV_DEV_MATNR TYPE MATNR.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_RESULT TYPE CHAR01.

    DATA : LV_QLENGTH TYPE ZGTPPT2010-QLENGTH.
    DATA : LV_CLENGTH TYPE ZGTPPT2010-CLENGTH.

    DATA : LV_TABIX TYPE I.

    DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
    DATA : LT_HEADERDATA TYPE TABLE OF BAPIPLAF_I1.
    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.

    READ TABLE MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WITH KEY END_SEQNO = IV_MAIN_SEQ.
    IF SY-SUBRC EQ 0.
      READ TABLE <LS_MAIN>-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = IV_GONG_SEQ.

      READ TABLE MT_SEQ_ROUTING_SUB INTO MS_SEQ_ROUTING_SUB WITH KEY MATNR = <LS_MAIN>-MATNR.

      LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO MS_SEQ_ROUTING WHERE SEQNO = IV_GONG_SEQ.
        LOOP AT MS_SEQ_ROUTING-T_BOM INTO MS_ROUTING_CHAIN WHERE UP_SEQNO = IS_DEV_2010-MATNR_SEQ
                                                                                         AND UP_MATNR = IS_DEV_2010-MATNR.

          READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY SEQ_MATNR = MS_ROUTING_CHAIN-MATNR
                                                                                    IN_SEQNO = MS_ROUTING_CHAIN-SEQNO.
          IF SY-SUBRC EQ 0 AND LS_CHAIN-ORDNR IS INITIAL.

            CLEAR LS_CHAINS.
            LS_CHAINS-GUBUN = 'D'.
            LS_CHAINS-GONG_SEQ = MS_SEQ_ROUTING-GONG_SEQ.
            LS_CHAINS-CHART_SEQ = MS_SEQ_ROUTING-SEQNO.
            LS_CHAINS-MATNR = MS_ROUTING_CHAIN-MATNR.
            LS_CHAINS-MTART = MS_ROUTING_CHAIN-MTART.
            LS_CHAINS-BESKZ = MS_SEQ_ROUTING-BESKZ.
            LS_CHAINS-IN_SEQNO = MS_ROUTING_CHAIN-SEQNO.
            APPEND LS_CHAINS TO LT_CHAINS.

            CLEAR LS_MATNR.
            LS_MATNR-MATNR = MS_ROUTING_CHAIN-MATNR.
            COLLECT LS_MATNR INTO LT_MATNR.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF LT_CHAINS[] IS INITIAL. " 공정내 조회대상이 없을경우 최상위 공정이므로 공정 헤더 정보 입력
        CLEAR LS_CHAINS.
        LS_CHAINS-GUBUN = 'D'.
        LS_CHAINS-GONG_SEQ = MS_SEQ_ROUTING-GONG_SEQ.
        LS_CHAINS-CHART_SEQ = MS_SEQ_ROUTING-SEQNO.
        LS_CHAINS-MATNR = MS_SEQ_ROUTING_SUB-MATNR.
        LS_CHAINS-MTART = MS_SEQ_ROUTING_SUB-MTART.
        LS_CHAINS-IN_SEQNO = 1.
        APPEND LS_CHAINS TO LT_CHAINS.

        CLEAR LS_MATNR.
        LS_MATNR-MATNR = MS_ROUTING_CHAIN-MATNR.
        COLLECT LS_MATNR INTO LT_MATNR.
      ENDIF.

* 해당 오더 생성후 하위 공정 오더 생성을 위해 각각 자리에 세팅.
      LOOP AT LT_CHAINS INTO LS_CHAINS WHERE GUBUN = 'D'.
        LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO MS_SEQ_ROUTING WHERE SEQNO < LS_CHAINS-CHART_SEQ.
          LOOP AT MS_SEQ_ROUTING-T_BOM INTO MS_ROUTING_CHAIN WHERE UP_CHART_SEQ = LS_CHAINS-CHART_SEQ
                                                                                           AND UP_SEQNO = LS_CHAINS-IN_SEQNO
                                                                                           AND UP_MATNR = LS_CHAINS-MATNR.

            CLEAR LS_CHAINS_D.
            LS_CHAINS_D-GUBUN = 'U'.
            LS_CHAINS_D-GONG_SEQ = MS_SEQ_ROUTING-GONG_SEQ.
            LS_CHAINS_D-CHART_SEQ = MS_SEQ_ROUTING-SEQNO.
            LS_CHAINS_D-DM_MATNR = LS_CHAINS-MATNR.
            LS_CHAINS_D-DM_SEQNO = LS_CHAINS-IN_SEQNO.
            LS_CHAINS_D-MATNR = MS_ROUTING_CHAIN-MATNR.
            LS_CHAINS_D-IN_SEQNO = MS_ROUTING_CHAIN-SEQNO.
            APPEND LS_CHAINS_D TO LT_CHAINS.
          ENDLOOP.
        ENDLOOP.


      ENDLOOP.

    ENDIF.

    IF LT_CHAINS[] IS INITIAL.
      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

* 계획 오더 헤더 구성
* 계획 오더 생성을 위한 정보 세팅
*   조장구성 플랜트
    LS_HEADERDATA-PLAN_PLANT = MV_WERKS.
    LS_HEADERDATA-PROD_PLANT = MV_WERKS.
    LS_HEADERDATA-VERSION = '1000'.

*  확정
    LS_HEADERDATA-FIRMING_IND = 'X'.
*  일정 계획 수립
    LS_HEADERDATA-DET_SCHEDULE = 'X'.

* 공정정보 조회
    SELECT  A~MATNR,
           C~STPOZ,
           C~IDNRK,
           E~VERID AS VERID_O,
           G~VERID
      FROM MAST AS A
      INNER JOIN MKAL AS E ON E~WERKS = A~WERKS
                                AND E~MATNR = A~MATNR
                                AND E~STLAN = A~STLAN
                                AND E~STLAL = A~STLAL
      INNER JOIN STKO AS B
                             ON B~STLNR = A~STLNR
                            AND B~STLAL = A~STLAL
      INNER JOIN STPO AS C
                             ON C~STLNR = B~STLNR
                            AND C~STLTY = B~STLTY
      INNER JOIN STAS AS D ON D~STLAL = A~STLAL
                              AND D~STLNR = C~STLNR
                              AND D~STLTY = C~STLTY
                              AND D~STLKN = C~STLKN
      INNER JOIN MAST AS F ON F~WERKS = A~WERKS
                                  AND F~MATNR = C~IDNRK
      INNER JOIN MKAL AS G ON G~WERKS = F~WERKS
                                AND G~MATNR = F~MATNR
                                AND G~STLAN = F~STLAN
                                AND G~STLAL = F~STLAL
     WHERE A~MATNR = @IS_DEV_2010-MATNR
       AND A~WERKS  = @MV_WERKS
       AND E~VERID IN ( '1000', 'SC10' )
       AND G~VERID IN ( '1000', 'SC10' )
       AND B~STLTY  = 'M'
       AND B~LKENZ NE 'X'
       AND C~LKENZ NE 'X'
      INTO TABLE @DATA(LT_IDNRK).

    SELECT A~STPOZ, A~MATNR, A~IDNRK, A~VERID_O, A~VERID
      FROM @LT_IDNRK AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~IDNRK
      INNER JOIN MARC AS C
                            ON C~MATNR = A~IDNRK
                          AND C~WERKS = @MV_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND C~DISMM IN ( 'X0', 'PD' )
       AND ( C~BESKZ = 'E' OR
            ( C~BESKZ = 'F' AND
              C~SOBSL = 30 ) OR
            ( C~BESKZ = 'F' AND
            C~SOBSL = 50 ) OR
            ( C~BESKZ = 'F' AND
              C~SOBSL LIKE '4%' ) OR
              C~BESKZ = 'X'  OR
             ( C~BESKZ = 'F' AND
               C~SOBSL = '' ) )
       AND C~MAABC NE 'C'
       AND C~DPCBT EQ 'C'
      INTO TABLE @DATA(LT_ROUTING).

    SORT LT_ROUTING BY STPOZ MATNR IDNRK VERID_O VERID.
    DELETE ADJACENT DUPLICATES FROM LT_ROUTING COMPARING STPOZ MATNR IDNRK.


    IF NOT ( IS_DEV_2010-ORDTY EQ 'SO' OR IS_DEV_2010-ORDTY EQ 'SM' ).

* 이후공정 오더 시작일 - 1
      GET_FINDATE(
        EXPORTING
          IV_ORDNR   = IS_DEV_2010-ORDNR                 " 오더번호
          IV_ORDTY   = IS_DEV_2010-ORDTY                 " 오더유형
        IMPORTING
          EV_FINDATE = LV_FINDATE                 " ABAP system field: Current date of application server
          EV_RSNUM   = LV_RSNUM  ).               " 예약/종속 소요량의 번호

      LOOP AT LT_MATNR INTO LS_MATNR.
        CLEAR LS_2010_TEMP.
        LS_2010_TEMP-MATNR = LS_MATNR-MATNR.
        CAL_LC(
          EXPORTING
            IV_DEV_2010        = IS_DEV_2010                 " [GT] 오더 연결 정보
            IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
*            IV_ADTYPE          =                  " 추가여장 유형
*            IV_ADLENGTH        =                  " 추가여장
          IMPORTING
            EV_RESULT          = LV_RESULT " 길이 1의 문자 필드
            EV_TOTAL_PLORD_QTY = LS_HEADERDATA-TOTAL_PLORD_QTY                 " 계획 오더 수량 총계
          CHANGING
            CS_CURRENT_2010    = LS_2010_TEMP                 " [GT] 오더 연결 정보
        ).

        IF LV_RESULT EQ 'E'.
          READ TABLE LT_CHAINS INTO LS_CHAINS WITH KEY MATNR = LS_MATNR-MATNR.
          READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.

          CONCATENATE LS_ROUTING-CHART_VAL '계획 오더 생성 중 오류가 발생했습니다. - 조장' INTO MV_MESSAGE SEPARATED BY SPACE.
          RV_RETURN = 'E'.
          RETURN.
        ENDIF.

        APPEND LS_2010_TEMP TO LT_2010_TEMP.

* 완제품 자재유형(MARA-MTART = 'MCFE') 'KD' 그 외, 'LA'
        READ TABLE LT_CHAINS INTO LS_CHAINS WITH KEY GUBUN = 'D'
                                                                       MATNR = LS_MATNR-MATNR.
        CASE LS_CHAINS-MTART.
          WHEN 'MCFE'.
            IF IS_DEV_2010-ORDTY EQ 'SM'.
              LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
            ELSE.
              LS_HEADERDATA-PLDORD_PROFILE = 'KD'.
            ENDIF.
          WHEN OTHERS.
            LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
        ENDCASE.

* 계산된 종료일(이후공정 오더 시작일 -1)
        LS_HEADERDATA-ORDER_FIN_DATE = LV_FINDATE.
*  현재 공정 자재
        LS_HEADERDATA-MATERIAL = LS_MATNR-MATNR.

        READ TABLE LT_ROUTING ASSIGNING FIELD-SYMBOL(<LS_ROUTING>) WITH KEY IDNRK = LS_HEADERDATA-MATERIAL.
        IF SY-SUBRC EQ 0.
          LS_HEADERDATA-VERSION = <LS_ROUTING>-VERID.
        ENDIF.

        APPEND LS_HEADERDATA TO LT_HEADERDATA.

      ENDLOOP.

    ELSE. " 완제품 공정시 LC계산 없이 세팅

      SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
        FROM MARA AS A
        INNER JOIN MAPL AS B
                             ON B~MATNR = A~MATNR
        INNER JOIN PLPO AS C
                             ON C~PLNNR = B~PLNNR
       WHERE A~MATNR = @IS_DEV_2010-MATNR
          AND B~WERKS = @MV_WERKS
          AND B~PLNTY = 'N'
          AND B~LOEKZ = ' '
          AND C~PLNTY = 'N'
          AND C~LOEKZ = ' '
          AND C~PLNKN = '00000001'
          INTO @DATA(LS_INFOR_MATNR).

      READ TABLE MT_2000 INTO DATA(LS_2000) WITH KEY ORDNO = IS_DEV_2010-ORDNR
                                                                        POSNR = IS_DEV_2010-POSNR.

* 완제품 자재유형(MARA-MTART = 'MCFE') 'KD' 그 외, 'LA'
      READ TABLE LT_CHAINS INTO LS_CHAINS WITH KEY GUBUN = 'D'
                                                               MATNR = LS_MATNR-MATNR.
      CASE LS_CHAINS-MTART.
        WHEN 'MCFE'.
          IF IS_DEV_2010-ORDTY EQ 'SM'.
            LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
          ELSE.
            LS_HEADERDATA-PLDORD_PROFILE = 'KD'.
          ENDIF.
        WHEN OTHERS.
          LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
      ENDCASE.

*  현재 공정 자재
      LS_HEADERDATA-MATERIAL = IS_DEV_2010-MATNR.
      READ TABLE LT_ROUTING ASSIGNING <LS_ROUTING> WITH KEY MATNR = LS_HEADERDATA-MATERIAL.
      IF SY-SUBRC EQ 0.
        LS_HEADERDATA-VERSION = <LS_ROUTING>-VERID_O.
      ELSE.
        READ TABLE LT_IDNRK INTO DATA(LS_IDNRK)  WITH KEY MATNR = LS_HEADERDATA-MATERIAL.
        IF SY-SUBRC EQ 0.
          LS_HEADERDATA-VERSION = LS_IDNRK-VERID_O.
        ENDIF.

      ENDIF.

      CLEAR : LV_QLENGTH, LV_CLENGTH.
* 표준여장 추가되어있는지 확인
      SELECT SINGLE * FROM ZGTPPT2070
       WHERE GRPNR = @MV_GRPNR
          AND MATNR = @IS_DEV_2010-MATNR
          AND ORDNO IS INITIAL
        INTO @DATA(LS_2070).
      IF SY-SUBRC EQ 0.
        LV_QLENGTH = LS_2070-QLENGTH.
        LV_CLENGTH = LS_2070-CLENGTH.

        LV_QLENGTH = LV_QLENGTH + LV_CLENGTH.
        CLEAR LV_CLENGTH.
        LS_HEADERDATA-TOTAL_PLORD_QTY = LS_2000-INLENGTH + LV_QLENGTH.
      ELSE.
        LV_QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
        LS_HEADERDATA-TOTAL_PLORD_QTY = LS_2000-INLENGTH + LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
      ENDIF.

* 조장
      CLEAR MS_INSP_QLENGTH.
      READ TABLE MT_INSP_QLENGTH INTO MS_INSP_QLENGTH WITH KEY ORDNO = IS_DEV_2010-ORDNR
                                                                                           POSNR = IS_DEV_2010-POSNR.
      IF SY-SUBRC EQ 0.
        LS_HEADERDATA-TOTAL_PLORD_QTY = LS_HEADERDATA-TOTAL_PLORD_QTY + MS_INSP_QLENGTH-QLENGTH.
      ENDIF.

* 계산된 종료일(문서 종료일 -1)
      LS_HEADERDATA-ORDER_FIN_DATE = LS_2000-EDATU - 1.
      IF LS_HEADERDATA-ORDER_FIN_DATE < SY-DATUM.
        LS_HEADERDATA-ORDER_FIN_DATE = SY-DATUM.
      ENDIF.

*   현재 완제품 자재 유형인 경우, 후 공정 판매 오더 품목
      IF IS_DEV_2010-ORDTY EQ 'SO' .
        LS_HEADERDATA-SALES_ORD = LS_2000-ORDNO.
        LS_HEADERDATA-S_ORD_ITEM = LS_2000-POSNR.
      ENDIF.
      APPEND LS_HEADERDATA TO LT_HEADERDATA.

* 해당 오더의 조장체인 구성
      APPEND INITIAL LINE TO LT_2010_TEMP ASSIGNING FIELD-SYMBOL(<LS_2010>).
      <LS_2010>-GRPNR = MV_GRPNR.
      READ TABLE MS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_CHART) INDEX 1.
      <LS_2010>-GONG_CD = LS_CHART-CHART.
      <LS_2010>-DMORD = IS_DEV_2010-ORDNR.
      <LS_2010>-DMLINE = IS_DEV_2010-POSNR.

      <LS_2010>-DMORDTY = IS_DEV_2010-ORDTY.
      <LS_2010>-INLENGTH = LS_2000-INLENGTH.
*     검사여장 - 표준여장 존재시 표준여장으로 세팅 아니면 스탠다드 세팅
      IF LV_QLENGTH NE 0.
        <LS_2010>-QLENGTH = LV_QLENGTH.
      ELSE.
        <LS_2010>-QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.
      ENDIF.

*      <LS_2010>-CLENGTH = LV_CLENGTH.

      CLEAR MS_INSP_QLENGTH.
      READ TABLE MT_INSP_QLENGTH INTO MS_INSP_QLENGTH WITH KEY ORDNO = IS_DEV_2010-ORDNR
                                                                                           POSNR = IS_DEV_2010-POSNR.
      IF SY-SUBRC EQ 0.
        <LS_2010>-QLENGTH = <LS_2010>-QLENGTH  + MS_INSP_QLENGTH-QLENGTH.
      ENDIF.

      <LS_2010>-INFACTOR = 1.
      <LS_2010>-GONG_SEQ = LS_CHART-GONG_SEQ.
      <LS_2010>-MATNR = IS_DEV_2010-MATNR.
      <LS_2010>-MATNR_SEQ = 1.
      <LS_2010>-ETC_SEQ = IS_DEV_2010-ETC_SEQ.
    ENDIF.

    CLEAR LV_TABIX.
*  생성된 정보로 계획오더 생성
    LOOP AT LT_CHAINS INTO LS_CHAINS WHERE GUBUN = 'D'.
      ADD 1 TO LV_TABIX.
      READ TABLE LT_HEADERDATA INTO LS_HEADERDATA WITH KEY MATERIAL = LS_CHAINS-MATNR.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE * FROM ZGTCVMSTVAL
          INTO @DATA(LS_CVMSTVAL)
         WHERE WERKS = @MV_WERKS
           AND MATNR = @LS_CHAINS-MATNR.
* 생산오더 생성시 pr생성 추가
        IF LS_CHAINS-BESKZ = 'EP' AND LS_CVMSTVAL-BESKZ = 'F' AND LS_CVMSTVAL-SOBSL = ''.

          CLEAR LS_2010_TEMP.
          READ TABLE LT_2010_TEMP INTO LS_2010_TEMP WITH KEY MATNR = LS_CHAINS-MATNR.
          IF SY-SUBRC EQ 0.
            IF LS_2010_TEMP-DMORDTY = 'SO' OR LS_2010_TEMP-DMORDTY = 'SM'.
              CLEAR LV_RESULT.
              LV_RESULT = CREATE_PR_ORDER(
                            EXPORTING
                              IV_FINDATE = LS_HEADERDATA-ORDER_FIN_DATE " ABAP system field: Current date of application server
                            CHANGING
                              CS_2010    = LS_2010_TEMP ).                 " [GT] 오더 연결 정보

              IF LV_RESULT = ABAP_TRUE.
                RV_RETURN = 'E'.
                RETURN.
              ENDIF.
              ADD 1 TO MV_SUCC_CNT.

              APPEND LS_2010_TEMP TO MT_NEW_2010.
              APPEND LS_2010_TEMP TO LT_2010_CHK.
            ELSE.

              LS_2010_TEMP-GRPNR = MV_GRPNR.
              READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.
              LS_2010_TEMP-GONG_CD = LS_ROUTING-CHART.
              LS_2010_TEMP-DMORD = IS_DEV_2010-ORDNR.
              LS_2010_TEMP-DMLINE = IS_DEV_2010-POSNR.
              LS_2010_TEMP-DMORDTY = IS_DEV_2010-ORDTY.
              LS_2010_TEMP-GONG_SEQ = LS_ROUTING-GONG_SEQ.
              LS_2010_TEMP-MATNR = LS_CHAINS-MATNR.
              LS_2010_TEMP-MATNR_SEQ = LS_CHAINS-IN_SEQNO.
              LS_2010_TEMP-ETC_SEQ = LS_CHAINS-IN_SEQNO.

              CLEAR LV_RESULT.
              LV_RESULT = CREATE_PR_ORDER(
                            EXPORTING
                              IV_FINDATE = LS_HEADERDATA-ORDER_FIN_DATE " ABAP system field: Current date of application server
                            CHANGING
                              CS_2010    = LS_2010_TEMP ).                 " [GT] 오더 연결 정보

              IF LV_RESULT = ABAP_TRUE.
                RV_RETURN = 'E'.
                RETURN.
              ENDIF.
              ADD 1 TO MV_SUCC_CNT.

              APPEND LS_2010_TEMP TO MT_NEW_2010.
              APPEND LS_2010_TEMP TO LT_2010_CHK.

* 이후공정 연결고리 업데이트
              IF LV_TABIX = 1 .
                READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>) WITH KEY GONG_SEQ = IS_DEV_2010-GONG_SEQ
                                                                                                         ORDNR = IS_DEV_2010-ORDNR
                                                                                                         POSNR = IS_DEV_2010-POSNR
                                                                                                         ORDTY = IS_DEV_2010-ORDTY.
                IF SY-SUBRC EQ 0.
                  READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_PRE) WITH KEY ORDNR = <LS_NEW_2010>-REORD
                                                                                           POSNR = <LS_NEW_2010>-RELINE
                                                                                           ORDTY = <LS_NEW_2010>-REORDTY.
                  IF SY-SUBRC NE 0.
                    <LS_NEW_2010>-REORD = LS_2010_TEMP-ORDNR.
                    <LS_NEW_2010>-RELINE = LS_2010_TEMP-POSNR.
                    <LS_NEW_2010>-REORDTY = LS_2010_TEMP-ORDTY.
                  ENDIF.
                ENDIF.
              ENDIF.

            ENDIF.

          ELSE.
            READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.

            CONCATENATE LS_ROUTING-CHART_VAL '구매요청 생성 중 오류가 발생했습니다.' INTO MV_MESSAGE SEPARATED BY SPACE.
            RV_RETURN = 'E'.
            RETURN.
          ENDIF.

        ELSE.

          CLEAR : LV_PLANNEDORDER, LS_RETURN.
          CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
            EXPORTING
              HEADERDATA   = LS_HEADERDATA
            IMPORTING
              RETURN       = LS_RETURN
              PLANNEDORDER = LV_PLANNEDORDER.

          IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행

            READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.

            MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER
                  WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
                  INTO MV_MESSAGE.
            CONCATENATE LS_ROUTING-CHART_VAL '계획 오더 생성 오류-' MV_MESSAGE INTO MV_MESSAGE SEPARATED BY SPACE.
            RV_RETURN = 'E'.
            RETURN.

          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.

            APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PLAN_ORDER>).
            <LS_PLAN_ORDER> = LV_PLANNEDORDER.


*** 계획오더정보 조회
            DATA : LT_CAPACITYDATA1 TYPE TABLE OF BAPI_PLDORDCAPA_E1.
            DATA : LT_COMPONENTSDATA TYPE TABLE OF BAPI_PLDORDCOMP_E1.

            REFRESH : LT_COMPONENTSDATA, LT_CAPACITYDATA1.

            CALL FUNCTION 'BAPI_PLANNEDORDER_GET_DETAIL'
              EXPORTING
                PLANNEDORDER   = LV_PLANNEDORDER
              TABLES
                COMPONENTSDATA = LT_COMPONENTSDATA
                CAPACITYDATA1  = LT_CAPACITYDATA1.

            IF LT_CAPACITYDATA1[] IS NOT INITIAL.

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

                READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.

                CONCATENATE LS_ROUTING-CHART_VAL '계획 오더 생성 중 오류가 발생했습니다.' INTO MV_MESSAGE SEPARATED BY SPACE.
                RV_RETURN = 'E'.
                RETURN.

              ELSE.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    WAIT = ABAP_TRUE.
              ENDIF.
            ENDIF.

            ADD 1 TO MV_SUCC_CNT.

            CLEAR LS_2010_TEMP.
            READ TABLE LT_2010_TEMP INTO LS_2010_TEMP WITH KEY MATNR = LS_CHAINS-MATNR.
            IF SY-SUBRC EQ 0.
              IF LS_2010_TEMP-DMORDTY = 'SO' OR LS_2010_TEMP-DMORDTY = 'SM'.
                LS_2010_TEMP-ORDNR = LV_PLANNEDORDER.
                LS_2010_TEMP-ORDTY = 'PLN'.
                APPEND LS_2010_TEMP TO MT_NEW_2010.
                APPEND LS_2010_TEMP TO LT_2010_CHK.
              ELSE.

                LS_2010_TEMP-GRPNR = MV_GRPNR.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.
                LS_2010_TEMP-GONG_CD = LS_ROUTING-CHART.
                LS_2010_TEMP-ORDNR = LV_PLANNEDORDER.
                LS_2010_TEMP-ORDTY = 'PLN'.
                LS_2010_TEMP-DMORD = IS_DEV_2010-ORDNR.
                LS_2010_TEMP-DMLINE = IS_DEV_2010-POSNR.
                LS_2010_TEMP-DMORDTY = IS_DEV_2010-ORDTY.
                LS_2010_TEMP-GONG_SEQ = LS_ROUTING-GONG_SEQ.
                LS_2010_TEMP-MATNR = LS_CHAINS-MATNR.
                LS_2010_TEMP-MATNR_SEQ = LS_CHAINS-IN_SEQNO.
                LS_2010_TEMP-ETC_SEQ = LS_CHAINS-IN_SEQNO.
                APPEND LS_2010_TEMP TO MT_NEW_2010.
                APPEND LS_2010_TEMP TO LT_2010_CHK.

* 이후공정 연결고리 업데이트
                IF LV_TABIX = 1 .
                  READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY GONG_SEQ = IS_DEV_2010-GONG_SEQ
                                                                                                   ORDNR = IS_DEV_2010-ORDNR
                                                                                                    POSNR = IS_DEV_2010-POSNR
                                                                                                    ORDTY = IS_DEV_2010-ORDTY.
                  IF SY-SUBRC EQ 0.
                    READ TABLE MT_NEW_2010 INTO LS_CHK_PRE WITH KEY ORDNR = <LS_NEW_2010>-REORD
                                                                                             POSNR = <LS_NEW_2010>-RELINE
                                                                                             ORDTY = <LS_NEW_2010>-REORDTY.
                    IF SY-SUBRC NE 0.
                      <LS_NEW_2010>-REORD = LS_2010_TEMP-ORDNR.
                      <LS_NEW_2010>-RELINE = LS_2010_TEMP-POSNR.
                      <LS_NEW_2010>-REORDTY = LS_2010_TEMP-ORDTY.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDIF.

            ELSE.
              READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_CHAINS-GONG_SEQ.

              CONCATENATE LS_ROUTING-CHART_VAL '계획 오더 생성 중 오류가 발생했습니다.' INTO MV_MESSAGE SEPARATED BY SPACE.
              RV_RETURN = 'E'.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

* 반제품 생성시 RESB테이블 업데이트
    CASE IS_DEV_2010-ORDTY.
      WHEN 'SO' OR 'SM'.

      WHEN OTHERS.
* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
        DATA : LV_CHK_QMAT.
        DATA : LV_EXCLUDING_LENGTH TYPE GSMNG.
        DATA : LV_CHK_EXCLUDING_LENGTH TYPE GSMNG.

*  검사 여장 존재시 품질 테이블 적합성 검사
        LOOP AT LT_2010_TEMP INTO LS_2010_TEMP.
          CLEAR LV_CHK_QMAT.
          IF LS_2010_TEMP-QLENGTH > 0.
            LV_CHK_QMAT = ABAP_TRUE.
          ENDIF.

          READ TABLE LT_HEADERDATA INTO LS_HEADERDATA WITH KEY MATERIAL = LS_2010_TEMP-MATNR.

          CLEAR LV_EXCLUDING_LENGTH.
          IF LV_CHK_QMAT = ABAP_TRUE.
            SELECT SINGLE MATNR FROM QMAT
              INTO @DATA(LV_CHK_MATNR)
             WHERE MATNR = @LS_2010_TEMP-MATNR
               AND WERKS = @MV_WERKS
               AND ART = '04'
               AND AKTIV = 'X'.
            IF SY-SUBRC EQ 0.
              LV_EXCLUDING_LENGTH = LS_HEADERDATA-TOTAL_PLORD_QTY - LS_2010_TEMP-QLENGTH.
            ELSE.
              LV_EXCLUDING_LENGTH = LS_HEADERDATA-TOTAL_PLORD_QTY.
            ENDIF.
          ELSE.
            LV_EXCLUDING_LENGTH = LS_HEADERDATA-TOTAL_PLORD_QTY.
          ENDIF.

          IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
            LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
          ENDIF.
        ENDLOOP.

* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
        DATA : LT_RESB TYPE TABLE OF RESB.
        DATA : LT_MATNR_CHK TYPE RANGE OF MATNR.
        DATA : LT_EXCEPT_GONG_CD TYPE RANGE OF ZEDT1010-GONG_CD.

        SELECT 'I' AS SIGN, 'EQ' AS OPTION,  FLD_02 AS LOW
          FROM ZGTPPT1010
          INTO CORRESPONDING FIELDS OF TABLE @LT_EXCEPT_GONG_CD
         WHERE MODULE_KIND = 'PP'
            AND CODEGRP = '2020'
            AND FLD_01 = @MV_WERKS.

        SELECT A~*
          FROM RESB AS A
          INNER JOIN MARA AS B
                          ON B~MATNR = A~MATNR
          INNER JOIN MARC AS C
                          ON C~MATNR = A~MATNR
          INNER JOIN ZGTCVMSTVAL AS D
                          ON D~MATNR = C~MATNR
                         AND D~WERKS = C~WERKS
          INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
          WHERE B~MTART = 'MCHF'
            AND C~WERKS = @MV_WERKS
            AND C~BESKZ IN ('E', 'X')
            AND D~PDCAPROCCODE NE 'BWD'
            AND A~RSNUM = @LV_RSNUM.

        LT_MATNR_CHK = VALUE #( FOR LW_RESB IN LT_RESB WHERE ( MATNR IS NOT INITIAL )
                          ( SIGN = 'I' OPTION = 'EQ' LOW =   LW_RESB-MATNR ) ).

        SELECT DISTINCT WERKS, MATNR FROM ZGTCVMSTVAL
          INTO TABLE @DATA(LT_MSTVAL)
         WHERE WERKS = @MV_WERKS
           AND MATNR IN @LT_MATNR_CHK
           AND PDCAPROCCODE NOT IN @LT_EXCEPT_GONG_CD.

        LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

          <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
              I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
              I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
              I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*             I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
            IMPORTING
              E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
            EXCEPTIONS
              ERROR_IN_APPLICATION = 1
              ERROR                = 2
              OTHERS               = 3.

        ENDLOOP.

        LOOP AT LT_RESB INTO DATA(LS_RESB).
          READ TABLE LT_MSTVAL TRANSPORTING NO FIELDS WITH KEY MATNR = LS_RESB-MATNR.
          IF SY-SUBRC EQ 0.

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
          ENDIF.
        ENDLOOP.

    ENDCASE.

* 화면 구성 테이블에 업데이트
    LOOP AT LT_CHAINS INTO LS_CHAINS WHERE GUBUN = 'D'.
      READ TABLE LT_2010_CHK INTO DATA(LS_2010_CHK) WITH KEY MATNR = LS_CHAINS-MATNR
                                                                                         MATNR_SEQ = LS_CHAINS-IN_SEQNO.

      SET_CHAIN_TABLE(
        IV_MAIN_SEQ = IV_MAIN_SEQ                 " 자재 번호
        IV_GONG_SEQ = LS_CHAINS-GONG_SEQ                 " 공정SEQ
        IV_MATNR    = LS_CHAINS-MATNR                 " 자재 번호
        IV_SEQNO    = LS_CHAINS-IN_SEQNO                 " 4바이트 부호 있는 정수
        IV_GUBUN    = LS_CHAINS-GUBUN                 " 길이 1의 문자 필드
        IS_2010     = LS_2010_CHK                 " [GT] 오더 연결 정보
      ).

      LOOP AT LT_CHAINS INTO LS_CHAINS_D WHERE GUBUN = 'U'
                                                                 AND DM_MATNR = LS_CHAINS-MATNR
                                                                 AND DM_SEQNO = LS_CHAINS-IN_SEQNO.

        SET_CHAIN_TABLE(
          IV_MAIN_SEQ = IV_MAIN_SEQ                 " 자재 번호
          IV_GONG_SEQ = LS_CHAINS_D-GONG_SEQ                 " 공정SEQ
          IV_MATNR    = LS_CHAINS_D-MATNR                 " 자재 번호
          IV_SEQNO    = LS_CHAINS_D-IN_SEQNO                 " 4바이트 부호 있는 정수
          IV_GUBUN    = LS_CHAINS_D-GUBUN                 " 길이 1의 문자 필드
          IS_2010     = LS_2010_CHK                 " [GT] 오더 연결 정보
        ).

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD CREATE_PRD_ORDER.

    DATA : LV_FIELDNAME TYPE FNAM_____4.
    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_NUM(2) TYPE N.
    DATA : LV_PSMNG_C(30) TYPE C.
    DATA : LV_TABIX TYPE I.
    DATA : LV_IDX TYPE I.

    DATA : LV_TEST01 TYPE CABNT-ATBEZ.
    DATA : LV_TEST02 TYPE CABNT-ATBEZ.
    DATA : LV_TEST03 TYPE CABNT-ATBEZ.

    SELECT A~ATNAM, B~ATBEZ
      FROM CABN AS A
      INNER JOIN CABNT AS B ON B~ATINN = A~ATINN
    WHERE A~ATNAM IN ( 'SAP_MILLCA_LENGTH', 'SAP_MILLCA_FACTOR', 'PD_CA_PROC_NAME' )
      AND B~SPRAS = @SY-LANGU
     INTO TABLE @DATA(LT_CHAR_NAME).

    LOOP AT LT_CHAR_NAME INTO DATA(LS_CHAR_NAME).
      CASE LS_CHAR_NAME-ATNAM.
        WHEN 'SAP_MILLCA_LENGTH'.
          LV_TEST01 = LS_CHAR_NAME-ATBEZ.
        WHEN 'SAP_MILLCA_FACTOR'.
          LV_TEST02 = LS_CHAR_NAME-ATBEZ.
        WHEN 'PD_CA_PROC_NAME'.
          LV_TEST03 = LS_CHAR_NAME-ATBEZ.
      ENDCASE.
    ENDLOOP.


    REFRESH : MT_BDCDATA, MT_MESSTAB.

    SELECT B~AUFNR, B~POSNR, B~PSMNG, B~AMEIN
      FROM @IT_2010 AS A
      INNER JOIN AFPO AS B
                            ON B~AUFNR = A~ORDNR
    INTO TABLE @DATA(LT_AFPO).

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPLCOKO1' '0110'.
    __BDC_FIELD : 'CAUFVD-AUFNR' IV_AUFNR,
                        'R62CLORD-FLG_OVIEW'  'X',
                        'BDC_OKCODE' '=ENTK'.

    LV_IDX = LINES( IT_2010 ).
    CLEAR LV_NUM.
    LOOP AT IT_2010 INTO DATA(LS_2010).
      LV_TABIX = SY-TABIX.
      READ TABLE LT_AFPO INTO DATA(LS_AFPO) WITH KEY AUFNR = LS_2010-ORDNR
                                                                            POSNR = LS_2010-POSNR+2(4).

      IF LV_NUM < 2 .
        ADD 1 TO LV_NUM.
      ENDIF.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '/00'.

      IF LV_TABIX NE 1.
*      자재정보
        LV_FIELDNAME = 'MILL_PP_SE-MATNR(' && LV_NUM && ')'.
        __BDC_FIELD :  LV_FIELDNAME IV_MATNR.
*      단위
        LV_FIELDNAME = 'MILL_PP_SE-AMEIN(' && LV_NUM && ')'.
        __BDC_FIELD :  LV_FIELDNAME LS_AFPO-AMEIN.
      ENDIF.

*    수량 입력
      LV_FIELDNAME = 'MILL_PP_SE-PSMNG(' && LV_NUM && ')'.

      CASE LS_2010-DMORDTY.
        WHEN 'SM' OR 'SO'.
          LV_PSMNG_C = LS_AFPO-PSMNG.
        WHEN OTHERS.
          IF LV_TABIX NE 1 AND LS_2010-QLENGTH NE 0.
            LV_PSMNG_C = LS_AFPO-PSMNG - ( LS_2010-QLENGTH * LS_2010-INFACTOR ).
          ELSE.
            LV_PSMNG_C = LS_AFPO-PSMNG.
          ENDIF.
      ENDCASE.


      CONDENSE LV_PSMNG_C.
      __BDC_FIELD :  LV_FIELDNAME LV_PSMNG_C.

      IF LV_TABIX >= 3.
        __BDC_DYNPRO 'SAPLKOBS' '0130'.
        __BDC_FIELD :  'BDC_OKCODE' '=BACK'.
      ENDIF.


*      IF LS_2010-DMORDTY NE 'SO'.

      IF LV_TABIX = 1.
*       최초 특성값 복사 때문에 1번 라인은 2번 클릭
        __BDC_DYNPRO 'SAPLCOKO1' '0115'.
        __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
        LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
        __BDC_FIELD :  LV_FIELDNAME 'X'.

        __BDC_DYNPRO 'SAPLCOKO1' '0115'.
        __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
      ELSE.
        __BDC_DYNPRO 'SAPLCOKO1' '0115'.
        __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
        LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
        __BDC_FIELD :  LV_FIELDNAME 'X'.
      ENDIF.

*   특성 세팅
      __BDC_DYNPRO 'SAPLCEI0' '0109'.
      __BDC_FIELD :  'BDC_OKCODE' '=BACK'.

      LV_INLENGTH = LS_2010-INLENGTH.
      LV_INLENGTH_C = LV_INLENGTH.
      CONDENSE LV_INLENGTH_C.

      LV_INFACTOR = LS_2010-INFACTOR.
      LV_INFACTOR_C = LV_INFACTOR.
      CONDENSE LV_INFACTOR_C.

      __BDC_FIELD : 'RCTMS-MNAME(01)' LV_TEST01,
                          'RCTMS-MNAME(02)' LV_TEST02,
                          'RCTMS-MNAME(03)' LV_TEST03,
                          'RCTMS-MWERT(01)' LV_INLENGTH_C,
                          'RCTMS-MWERT(02)' LV_INFACTOR_C,
                          'RCTMS-MWERT(03)' LS_2010-GONG_CD.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '/00'.
      LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
      __BDC_FIELD :  LV_FIELDNAME ' '.

*      ENDIF.

    ENDLOOP.

*  수량 재계산
    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_MP_HEADER_QUANT'.

    IF IV_AUART = 'RP01'.
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=KOZE'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU',
                          'CAUFVD-APRIO' '8'.

    ELSE.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.
    ENDIF.

    EXPORT LV_CHK_MULTY = ABAP_TRUE TO MEMORY ID 'ZBDC'.

    __BDC_TRANSACTION 'CO02'.

    FREE MEMORY ID 'ZBDC'.

    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                           OR MSGTYP = 'E'
                                                           OR MSGTYP = 'X'.
      APPEND LS_MESSTAB TO MT_TOT_MESSTAB.
      RV_RESULT = 'E'.
      RETURN.
    ENDLOOP.



    RV_RESULT = 'S'.

  ENDMETHOD.


  METHOD CREATE_PRD_ORDER_BY_BAPI.

    DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
    DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
    DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.
    DATA : LT_RETURN2 TYPE BAPI_ORDER_RETURN_TT.
    DATA : LS_2010 LIKE MS_MAKED_2010.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LV_CHK_OK.

    LS_ORDER-MATERIAL = CS_2010-MATNR.
    LS_ORDER-PLANT = MV_WERKS.
    LS_ORDER-BASIC_START_DATE = IV_FINDATE.
    LS_ORDER-BASIC_END_DATE = IV_FINDATE.
    LS_ORDER-ORDER_TYPE = IV_AUART.
    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
    LS_ORDER-QUANTITY = IV_TOTAL_QTY.


* 생산오더 생성
    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_ORDER_NUMBER.

*  복조장 구성 BDC
    IF LS_RETURN-TYPE NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      CLEAR LS_ORDER_KEY.
      LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
      COLLECT LS_ORDER_KEY INTO MT_PRD_ORDERS.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE AUFNR, POSNR
          FROM AFPO
         WHERE AUFNR = @LV_ORDER_NUMBER
          INTO @DATA(LS_AFPO).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.1' SECONDS.
        ENDIF.
      ENDDO.

    ELSE.
      RV_RESULT = 'E'.
      RETURN.
    ENDIF.


    CS_2010-ORDNR = LV_ORDER_NUMBER.
    CS_2010-POSNR = 1 + 0.
    CS_2010-ORDTY = 'PRD'.
    CLEAR LS_2010.
    MOVE-CORRESPONDING CS_2010 TO LS_2010.

    IF LS_2010-DMORDTY NE 'SO'.
      RV_RESULT = SET_PRD_CHARICTERISTIC( EXPORTING IS_2010   = LS_2010 ).
      IF RV_RESULT = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

*    탄뎀 복조장시 탄뎀 설정
    IF CS_2010-REF_TANDEM = 'T'.
* 탄뎀설정
      UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
        WHERE AUFNR = LV_ORDER_NUMBER.

      REFRESH : MT_BDCDATA, MT_MESSTAB.
      __SETTING_BDC_PARAMS.
      MS_BDCPARAMS-NOBINPT = ABAP_TRUE.
      MS_BDCPARAMS-NOBIEND = ABAP_TRUE.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_ORDER_NUMBER,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0131'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                          'RC62F-VER_SEL' 'X',
                          'RC62F-PROD_VERS' 'TD10',
                          'RC62F-NEW_ROUT' 'X',
                          'RC62F-PLAUF' SY-DATUM,
                          'RC62F-NEW_BOM' 'X',
                          'RC62F-AUFLD' SY-DATUM.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

      __BDC_TRANSACTION 'CO02'.

      CLEAR LV_CHK_OK.
      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGID = 'CO'
                                                             AND MSGNR = '100'.
        LV_CHK_OK = ABAP_TRUE.
        EXIT.
      ENDLOOP.

      IF LV_CHK_OK = ABAP_TRUE.
        COMMIT WORK AND WAIT.
        WAIT UP TO '0.3' SECONDS.

      ELSE.
        RV_RESULT = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

    IF IV_CHK_RELEASE = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
      <LS_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

      CALL FUNCTION 'BAPI_PRODORD_RELEASE'
        IMPORTING
          RETURN        = LS_RETURN
        TABLES
          ORDERS        = LT_ORDERS
          DETAIL_RETURN = LT_RETURN2.
    ENDIF.

    ADD 1 TO MV_SUCC_CNT.
    RV_RESULT = 'S'.

  ENDMETHOD.


  METHOD CREATE_PR_ORDER.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LS_PR_INFOR TYPE ZGTPPS0004.
    DATA : LT_CHART TYPE ZGTPPY0005.
    DATA : LV_PSMNG_C(30) TYPE C.
    DATA : LV_PSMNG TYPE MENGE_D.
    DATA : LV_BANFN TYPE BANFN.
    DATA : LV_RESULT TYPE CHAR01.


    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
      FROM ZGTPPT1010
      INTO @DATA(LS_EKORG)
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = ' '
       AND FLD_02 = @MV_WERKS.

    LV_PSMNG_C = ( CS_2010-INLENGTH + CS_2010-QLENGTH + CS_2010-CLENGTH +
                           CS_2010-SLENGTH + CS_2010-ELENGTH + CS_2010-ADLENGTH )
                         * CS_2010-INFACTOR.
    CONDENSE : LV_PSMNG_C.

    CLEAR LS_PR_INFOR.
    LS_PR_INFOR-BSART = 'NB'.
    CASE CS_2010-DMORDTY.
      WHEN 'SO'.
        LS_PR_INFOR-KNTTP = 'M'.
        LS_PR_INFOR-KDAUF = CS_2010-DMORD.
        LS_PR_INFOR-KDPOS = CS_2010-DMLINE.
    ENDCASE.

*        입력값 세팅
    LS_PR_INFOR-EEIND = IV_FINDATE.
    LS_PR_INFOR-LPEIN = 'T'.
    LS_PR_INFOR-WERKS = MV_WERKS.
    LS_PR_INFOR-EKGRP = LS_EKORG-EKGRP.
    LS_PR_INFOR-AFNAM = SY-UNAME.
    LS_PR_INFOR-MATNR = CS_2010-MATNR.
    LS_PR_INFOR-EKORG = LS_EKORG-EKORG.
    LS_PR_INFOR-MENGE = LV_PSMNG_C.

    REFRESH LT_CHART.

*        특성값 세팅
* 조장 - 총 생산 길이와 동일하게 매핑
    LV_INLENGTH = CS_2010-INLENGTH + CS_2010-QLENGTH + CS_2010-CLENGTH +
                  CS_2010-SLENGTH + CS_2010-ELENGTH + CS_2010-ADLENGTH.
    LV_INLENGTH_C = LV_INLENGTH.
    CONDENSE LV_INLENGTH_C.

    APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
    <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
    <LS_CHART>-ATWRT = LV_INLENGTH_C.

    LV_INFACTOR = CS_2010-INFACTOR.
    LV_INFACTOR_C = LV_INFACTOR.
    CONDENSE LV_INFACTOR_C.

    APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
    <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
    <LS_CHART>-ATWRT = LV_INFACTOR_C.


    CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
      EXPORTING
        IS_PR_INFOR = LS_PR_INFOR
      IMPORTING
        EV_RESULT   = LV_RESULT
        EV_BANFN    = LV_BANFN
      TABLES
        IT_CHART    = LT_CHART.

    IF LV_RESULT NE 'S'.
      READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = CS_2010-GONG_SEQ.
      CONCATENATE LS_ROUTING-CHART_VAL '구매요청 생성 중 오류가 발생했습니다.' INTO MV_MESSAGE SEPARATED BY SPACE.
      RV_RESULT = 'X'.
      RETURN.
    ENDIF.

    CS_2010-ORDNR = LV_BANFN.
    CS_2010-POSNR = 10.
    CS_2010-ORDTY = 'PR'.

    APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
    <LS_BANFN>-BANFN = LV_BANFN.

  ENDMETHOD.


  METHOD CREATE_PURCHASE_ORDER.

    DATA : LV_RETURN TYPE CHAR01.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    LOOP AT IT_2010 INTO DATA(LS_2010).
      LV_RETURN = CREATE_PURCHASE_ORDER_SINGLE( IS_2010 = LS_2010 ).
      IF LV_RETURN = 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_RETURN = 'E'.
      LOOP AT MT_NEW_PLAN_ORDERS INTO DATA(LS_PLAN).
        LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      ENDLOOP.

      LOOP AT MT_PO_ORDERS INTO DATA(LS_PO).
        CLEAR LV_RETURN.
        LV_RETURN = DEL_PO_ORDER( IV_EBELN = LS_PO-EBELN ).
        IF LV_RETURN = 'E'.
          APPEND INITIAL LINE TO MT_TOT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
          <LS_MESSAGE>-MSGTYP = 'E'.
          <LS_MESSAGE>-MSGV1 = |오류로 인한 구매오더({ LS_PO-EBELN }) 삭제중 오류발생하였습니다.|.
        ENDIF.
      ENDLOOP.

      RV_RESULT = 'E'.
      RETURN.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 80  IV_TEXT = '임가공 생성완료. 오더정보 변경중..' ).

    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
      ENDCASE.
    ENDLOOP.

    LOOP AT MT_PLAN_ORDERS INTO LS_PLAN.
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        RV_RESULT = 'E'.
      ENDIF.
    ENDLOOP.

    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        RV_RESULT = 'E'.
      ENDIF.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).
    CONFIRM( ).

  ENDMETHOD.


  METHOD CREATE_PURCHASE_ORDER_BDC.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_FIELDNAME TYPE FNAM_____4.
    DATA : LV_NUM(2) TYPE N.
    DATA : LV_POSNR(4) TYPE N.
    DATA : LV_POSNR2(4) TYPE N.
    DATA : LV_PSMNG_C(30) TYPE C.
*  구매조직 관련 스트럭처
    DATA : BEGIN OF LS_EKORG,
             WEREKS TYPE WERKS_D,
             EKORG  TYPE EKORG,
             EKGRP  TYPE EKGRP,
           END OF LS_EKORG.
    DATA : BEGIN OF LS_RSNUM,
             RSNUM TYPE RSNUM,
           END OF LS_RSNUM.
    DATA : LT_RSNUM LIKE TABLE OF LS_RSNUM.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : BEGIN OF LS_COLLECT_RESB,
             MATNR TYPE RESB-MATNR,
             ERFMG TYPE RESB-ERFMG,
             ERFME TYPE RESB-ERFME,
             BDMNG TYPE RESB-BDMNG,
             MEINS TYPE RESB-MEINS,
             WERKS TYPE RESB-WERKS,
             BDTER TYPE RESB-BDTER,
           END OF LS_COLLECT_RESB.
    DATA : LT_COLLECT_RESB LIKE TABLE OF LS_COLLECT_RESB.
    DATA : LV_TOTAL_MENGE TYPE GSMNG.
    DATA : LV_CAL_MENGE TYPE GSMNG.
    DATA :LV_VBELN TYPE VBAK-VBELN.
    DATA : LV_PACK_YN TYPE CHAR10.
    DATA : LV_PACK_NO TYPE MATNR.


    CLEAR LS_EKORG.
    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @LS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = 'L'
     AND FLD_02 = @MV_WERKS.

    READ TABLE IT_2010 INTO DATA(LS_2010) INDEX 1.
    READ TABLE MT_INFNR_INFOR INTO MS_INFNR_INFOR WITH KEY MATNR = LS_2010-MATNR.

    CASE LS_2010-ORDTY.
      WHEN 'PLN'.
        SELECT PLNUM, GSMNG
          FROM PLAF
         WHERE PLNUM = @LS_2010-ORDNR
        INTO TABLE @DATA(LT_PLAF).
      WHEN 'PRD'.
        SELECT AUFNR, POSNR, PSMNG, AMEIN
          FROM AFPO
         WHERE AUFNR = @LS_2010-ORDNR
        INTO TABLE @DATA(LT_AFPO).

        SORT LT_AFPO BY AUFNR POSNR.
        DELETE ADJACENT DUPLICATES FROM LT_AFPO COMPARING AUFNR POSNR.

    ENDCASE.

* 예약자재
    DATA(LT_RESB_2010) = IT_RESB_2010.
    SORT LT_RESB_2010 BY ORDNR.
    DELETE ADJACENT DUPLICATES FROM LT_RESB_2010 COMPARING ORDNR.

    LOOP AT LT_RESB_2010 INTO DATA(LS_RESB_2010).
      CLEAR LS_RSNUM.
      CASE LS_RESB_2010-ORDTY.
        WHEN 'PLN'.
          SELECT SINGLE RSNUM
            FROM PLAF
           WHERE PLNUM = @LS_RESB_2010-ORDNR
          INTO @LS_RSNUM-RSNUM.
        WHEN 'PRD'.
          SELECT SINGLE RSNUM
            FROM AFKO
           WHERE AUFNR = @LS_RESB_2010-ORDNR
          INTO @LS_RSNUM-RSNUM.
      ENDCASE.
      IF LS_RSNUM-RSNUM IS NOT INITIAL.
        COLLECT LS_RSNUM INTO LT_RSNUM.
      ENDIF.
    ENDLOOP.

    IF LT_RSNUM[] IS NOT INITIAL.
      SELECT * FROM RESB
        INTO TABLE LT_RESB
        FOR ALL ENTRIES IN LT_RSNUM
       WHERE RSNUM = LT_RSNUM-RSNUM.

      LOOP AT LT_RESB INTO DATA(LS_RESB).
        CLEAR LS_COLLECT_RESB.
        MOVE-CORRESPONDING LS_RESB TO LS_COLLECT_RESB.
        COLLECT LS_COLLECT_RESB INTO LT_COLLECT_RESB.
      ENDLOOP.
    ENDIF.


    REFRESH : MT_BDCDATA, MT_MESSTAB.

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPMM06E' '0100'.
    __BDC_FIELD : 'BDC_OKCODE' '/00',
                        'EKKO-LIFNR' MS_INFNR_INFOR-LIFNR,
                        'RM06E-BSART' 'NB',
                        'RM06E-BEDAT' MS_INFNR_INFOR-EEIND,
                        'EKKO-EKORG' LS_EKORG-EKORG,
                        'EKKO-EKGRP' LS_EKORG-EKGRP,
                        'RM06E-EPSTP' 'L',
                        'RM06E-EEIND' MS_INFNR_INFOR-EEIND,
                        'RM06E-LGORT' MS_INFNR_INFOR-LGFSB,
                        'RM06E-LPEIN' 'T',
                        'RM06E-WERKS' MV_WERKS.

    __BDC_DYNPRO 'SAPMM06E' '0101'.
    __BDC_FIELD : 'BDC_OKCODE' '=AB',
                        'EKKO-EKGRP' LS_EKORG-EKGRP,
                        'EKKO-PINCR' '10',
                        'EKKO-SPRAS' 'KO'.

    CLEAR LV_NUM.
    LOOP AT IT_2010 INTO LS_2010.
      ADD 1 TO LV_NUM.

      __BDC_DYNPRO 'SAPMM06E' '0120'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

*     자재코드
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = |EKPO-EMATN({ LV_NUM })|.
      __BDC_FIELD : LV_FIELDNAME LS_2010-MATNR.
*     단위
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = |EKPO-MEINS({ LV_NUM })|.
      __BDC_FIELD : LV_FIELDNAME 'M'.

      CASE LS_2010-ORDTY.
        WHEN 'PLN'.
          READ TABLE LT_PLAF INTO DATA(LS_PLAF) INDEX 1.
          LV_PSMNG_C = LS_PLAF-GSMNG.
          ADD LS_PLAF-GSMNG TO LV_TOTAL_MENGE.
          CONDENSE LV_PSMNG_C.
        WHEN 'PRD'.
          READ TABLE LT_AFPO INTO DATA(LS_AFPO) WITH KEY AUFNR = LS_2010-ORDNR
                                                                              POSNR = LS_2010-POSNR+2(4).
          LV_PSMNG_C = LS_AFPO-PSMNG.
          ADD LS_AFPO-PSMNG TO LV_TOTAL_MENGE.
          CONDENSE LV_PSMNG_C.
      ENDCASE.

*     수량
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = |EKPO-MENGE({ LV_NUM })|.
      __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

*    판매오더 참조 완제품의 경우
      IF LS_2010-DMORDTY = 'SO'.
*     수량
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |EKPO-KNTTP({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME 'M'.

        __BDC_DYNPRO 'SAPMM06E' '0511'.
        __BDC_FIELD : 'BDC_OKCODE' '=UMOD'.

        __BDC_DYNPRO 'SAPLKACB' '0002'.
        __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
                            'COBL-KDAUF' LS_2010-DMORD,
                            'COBL-KDPOS' LS_2010-DMLINE+1(5).

        __BDC_DYNPRO 'SAPMM06E' '0113'.
        __BDC_FIELD : 'BDC_OKCODE' '=BACK'.

      ENDIF.
    ENDLOOP.


    CLEAR LV_POSNR2.
    LOOP AT IT_2010 INTO LS_2010.
      ADD 10 TO LV_POSNR2.

      __BDC_DYNPRO 'SAPMM06E' '0120'.
      __BDC_FIELD : 'BDC_OKCODE' '/00',
                          'RM06E-EBELP' LV_POSNR2.

      __BDC_DYNPRO 'SAPMM06E' '0120'.
      __BDC_FIELD : 'BDC_OKCODE' '=LB',
                          'RM06E-EBELP' LV_POSNR2.

      __BDC_DYNPRO 'SAPLM61Q' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=MALL'.

      __BDC_DYNPRO 'SAPLM61Q' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=DELE'.

      __BDC_DYNPRO 'SAPLM61Q' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=POS1'.

      __BDC_DYNPRO 'SAPLM61Q' '0110'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      CLEAR : LV_POSNR, LV_NUM.
      LOOP AT LT_COLLECT_RESB INTO LS_COLLECT_RESB.
        ADD 1 TO LV_NUM.
        ADD 10 TO LV_POSNR.
*     자재코드
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-MATNR({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LS_COLLECT_RESB-MATNR.
*     단위
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-ERFME({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LS_COLLECT_RESB-ERFME.

**     단위(기존)
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |MDPM-MEINS({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME LS_COLLECT_RESB-MEINS.

*     플랜트
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-WERKS({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LS_COLLECT_RESB-WERKS.

*     구성부품 소요일
*     구성부품 소요일이 구매오더 입고일보다 클경우
        LS_COLLECT_RESB-BDTER =  MS_INFNR_INFOR-EEIND.

        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-BDTER({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LS_COLLECT_RESB-BDTER.

*     구성부품 품목
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-POSNR({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LV_POSNR.


        CLEAR LV_CAL_MENGE.
        CASE LS_2010-ORDTY.
          WHEN 'PLN'.
            READ TABLE LT_PLAF INTO LS_PLAF INDEX 1.
            LV_CAL_MENGE = LS_PLAF-GSMNG.
          WHEN 'PRD'.
            READ TABLE LT_AFPO INTO LS_AFPO WITH KEY AUFNR = LS_2010-ORDNR
                                                                     POSNR = LS_2010-POSNR+2(4).
            LV_CAL_MENGE = LS_AFPO-PSMNG.
        ENDCASE.

*     수량
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-ERFMG({ LV_NUM })|.
        CLEAR LV_PSMNG_C.
        LV_PSMNG_C = LS_COLLECT_RESB-ERFMG * ( LV_CAL_MENGE / LV_TOTAL_MENGE ).
        CONDENSE LV_PSMNG_C.
        __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

**     수량(기본단위)
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |MDPM-BDMNG({ LV_NUM })|.
*        CLEAR LV_PSMNG_C.
*        LV_PSMNG_C = LS_COLLECT_RESB-BDMNG * ( LV_CAL_MENGE / LV_TOTAL_MENGE ).
*        CONDENSE LV_PSMNG_C.
*        __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.
      ENDLOOP.

      IF LS_2010-DMORDTY = 'SO'. "판매오더 베이스 일경우 포장재 자재 포함
*       포장재 포함
        CLEAR : LV_VBELN.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LS_2010-DMORD
          IMPORTING
            OUTPUT = LV_VBELN.


*        ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
*          EXPORTING
*            IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
*            IV_POSNR      = LS_2010-POSNR                 " SD 문서의 품목 번호
*          IMPORTING
*            EV_PACK_NO    = LV_PACK_NO ).

        ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
          EXPORTING
            IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
            IV_POSNR      = LS_2010-DMLINE                 " SD 문서의 품목 번호
          IMPORTING
            EV_PACK_NO    = LV_PACK_NO ).

        ADD 1 TO LV_NUM.
        ADD 10 TO LV_POSNR.
*     자재코드
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-MATNR({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LV_PACK_NO.
*     단위
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-ERFME({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME 'EA'.

*     플랜트
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-WERKS({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME MV_WERKS.

*     구성부품 소요일
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-BDTER({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME MS_INFNR_INFOR-EEIND.

*     구성부품 품목
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-POSNR({ LV_NUM })|.
        __BDC_FIELD : LV_FIELDNAME LV_POSNR.

*     수량
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = |MDPM-ERFMG({ LV_NUM })|.
        CLEAR LV_PSMNG_C.
        LV_PSMNG_C = 1.
        CONDENSE LV_PSMNG_C.
        __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

      ENDIF.

      __BDC_DYNPRO 'SAPLM61Q' '0110'.
      __BDC_FIELD : 'BDC_OKCODE' '=BACK'.
    ENDLOOP.


* 특성입력
    CLEAR LV_POSNR2.
    LOOP AT IT_2010 INTO LS_2010.
      ADD 10 TO LV_POSNR2.

      __BDC_DYNPRO 'SAPMM06E' '0120'.
      __BDC_FIELD : 'BDC_OKCODE' '/00',
                          'RM06E-EBELP' LV_POSNR2.

      __BDC_DYNPRO 'SAPMM06E' '0120'.
      __BDC_FIELD : 'BDC_OKCODE' '=KONF',
                          'RM06E-EBELP' LV_POSNR2.

      CLEAR LV_CAL_MENGE.
      CASE LS_2010-ORDTY.
        WHEN 'PLN'.
          READ TABLE LT_PLAF INTO LS_PLAF INDEX 1.
          LV_CAL_MENGE = LS_PLAF-GSMNG.
        WHEN 'PRD'.
          READ TABLE LT_AFPO INTO LS_AFPO WITH KEY AUFNR = LS_2010-ORDNR
                                                                   POSNR = LS_2010-POSNR+2(4).
          LV_CAL_MENGE = LS_AFPO-PSMNG.
      ENDCASE.

      LV_INLENGTH = LV_CAL_MENGE.
      LV_INLENGTH_C = LV_INLENGTH.
      CONDENSE LV_INLENGTH_C.

      LV_INFACTOR = 1.
      LV_INFACTOR_C = LV_INFACTOR.
      CONDENSE LV_INFACTOR_C.


      __BDC_DYNPRO 'SAPLCEI0' '0109'.
      __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                          'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
                          'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
                          'RCTMS-MWERT(01)' LV_INLENGTH_C,
                          'RCTMS-MWERT(02)' LV_INFACTOR_C.

    ENDLOOP.

    __BDC_DYNPRO 'SAPMM06E' '0120'.
    __BDC_FIELD : 'BDC_OKCODE' '=BU'.

    __BDC_TRANSACTION 'ME21'.

    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                           AND MSGID = '06'
                                                           AND MSGNR = '017'.

      RV_RESULT = LS_MESSTAB-MSGV2.
    ENDLOOP.

    READ TABLE MT_MESSTAB INTO LS_MESSTAB WITH KEY MSGTYP = 'E'.
    APPEND INITIAL LINE TO MT_TOT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
    <LS_MESSAGE>-MSGTYP = 'E'.
    MESSAGE ID LS_MESSTAB-MSGID TYPE 'S' NUMBER LS_MESSTAB-MSGNR
            WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
            INTO <LS_MESSAGE>-MSGV1.

  ENDMETHOD.


  METHOD CREATE_PURCHASE_ORDER_SINGLE.

    DATA : LT_BACKUP_2010 LIKE TABLE OF MS_2010.
    DATA : LT_RESB_2010 LIKE TABLE OF MS_2010.
    DATA : LV_CRT_SEQ TYPE I.
    DATA : LV_CRT_SEQ_C(10).
    DATA : LV_CHK_CREATE.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LS_2010_NEW LIKE MS_2010.
    DATA : LT_2010_INPUT LIKE TABLE OF MS_MAKED_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LV_TABIX TYPE I.
    DATA : LT_BACKUP_PLAN_ORDERS TYPE MRPDS_PLONO .
    DATA : LV_FINDATE TYPE SY-DATUM.

    IF MT_PLAN_ORDERS IS NOT INITIAL.
      MOVE-CORRESPONDING MT_PLAN_ORDERS TO LT_BACKUP_PLAN_ORDERS.
    ENDIF.

    LOOP AT MT_MAKED_2010 INTO DATA(LS_TEMP) WHERE ORDNR = IS_2010-ORDNR.
      APPEND LS_TEMP TO  LT_2010_INPUT.
    ENDLOOP.

    READ TABLE MT_INFNR_INFOR INTO MS_INFNR_INFOR WITH KEY MATNR = IS_2010-MATNR.

    GET_FINDATE(
      EXPORTING
        IV_ORDNR   = IS_2010-DMORD  " 오더번호
        IV_ORDTY   = IS_2010-DMORDTY" 오더유형
    IMPORTING
      EV_FINDATE = LV_FINDATE  ).               " ABAP system field: Current date of application server

    LV_FINDATE = LV_FINDATE + 1.
    IF MS_INFNR_INFOR-EEIND > LV_FINDATE.
      APPEND INITIAL LINE TO MT_TOT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
      <LS_MESSAGE>-MSGV1 = |공급요청일이 후공정{ IS_2010-DMORD } 시작일보다 큽니다.|.
      <LS_MESSAGE>-MSGV2 = |오더를 확인하세요.|.
    ENDIF.


    LV_CHK_CREATE = ABAP_TRUE.

    DO. " 생성할수 있는 오더 전부 생성후 종료

      IF LV_CHK_CREATE IS INITIAL.
        EXIT.
      ENDIF.

      CLEAR LV_CHK_CREATE.
      CLEAR LS_2010.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LV_RETURN.

      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

        READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_CURRNET_ROUTING) WITH KEY GONG_SEQ = IS_2010-GONG_SEQ.
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG_CURRENT>) WITH KEY SEQNO = LS_CURRNET_ROUTING-SEQNO.

        READ TABLE <LS_GONG_CURRENT>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN_CURRENT>)  WITH KEY ORDNR = IS_2010-ORDNR
                                                                                                                                              POSNR = IS_2010-POSNR.
        IF SY-SUBRC EQ 0.

          LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ < IS_2010-GONG_SEQ.
            READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
            IF SY-SUBRC EQ 0.
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>).
                IF <LS_CHAIN>-ORDNR IS INITIAL.
                  CASE <LS_CHAIN>-DMORDTY.
                    WHEN 'SM' OR 'SO'." 해당 오더가 완제품 공정일경우 체크없음
                      LS_2010-ORDNR = <LS_MAIN>-END_ORDNR.
                      LS_2010-POSNR = <LS_MAIN>-END_POSNR.
                      LS_2010-ORDTY = <LS_MAIN>-END_ORDTY.
                      LS_2010-ETC_SEQ = <LS_MAIN>-END_SEQNO.
                      LS_2010-GONG_SEQ = <LS_GONG>-GONG_SEQ.
                      LS_2010-MATNR_SEQ = 1.
                      LS_2010-MATNR = <LS_MAIN>-MATNR.
                      LV_CHK_CREATE = ABAP_TRUE.
                      LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                      LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                      EXIT.

                    WHEN 'PRD'. " 현재는 생산 오더만 체크
                      CLEAR MS_MAKED_2010.
                      READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                                      POSNR = <LS_CHAIN>-DMLINE
                                                                                                      ORDTY = <LS_CHAIN>-DMORDTY.
                      IF SY-SUBRC EQ 0.
                        IF <LS_CHAIN>-CHK_DUP = ABAP_TRUE.
                          READ TABLE MT_MAKED_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = MS_MAKED_2010-REORD
                                                                                                    POSNR = MS_MAKED_2010-RELINE
                                                                                                    ORDTY = MS_MAKED_2010-REORDTY.
                          IF SY-SUBRC EQ 0. " 해당오더 이전 공정 존재시 생성 대상 아님
                            CONTINUE.
                          ENDIF.
                        ENDIF.

                        CASE  MS_MAKED_2010-STATUS.
                          WHEN 'C'. " 신규 생성된 오더 이므로 처리가능
                            MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                            LV_CHK_CREATE = ABAP_TRUE.
                            LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                            LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                            EXIT.
                          WHEN 'E'. "오류 이므로 처리 불가능.
* 일단은 건너띄고 혼자만 남았을경우 에러로 사전 처리됨
                          WHEN 'R'. " 가동중인 오더 제외0
                            IF MS_MAKED_2010-CHK_PRD IS INITIAL.
                              MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                              LV_CHK_CREATE = ABAP_TRUE.
                              LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                              LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                              EXIT.
                            ENDIF.
                        ENDCASE.

                      ENDIF.

                    WHEN 'PLN'.
                      READ TABLE MT_NEW_2010 INTO LS_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                              POSNR = <LS_CHAIN>-DMLINE
                                                                                              ORDTY = <LS_CHAIN>-DMORDTY.
                      IF SY-SUBRC EQ 0.
                        LV_CHK_CREATE = ABAP_TRUE.
                        LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                        LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                        EXIT.
                      ENDIF.
                    WHEN OTHERS. " 현재 적용사항 없음. 차후 적용예정

                  ENDCASE.
                ENDIF.
              ENDLOOP.
              IF LV_CHK_CREATE IS NOT INITIAL.
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF LV_CHK_CREATE IS NOT INITIAL.
            EXIT.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF LV_CHK_CREATE = ABAP_TRUE.

        READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.

        LV_RETURN = CREATE_PLAN_ORDER(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_DEV_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
            LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
          ENDLOOP.
          RV_RESULT = 'E'.
          RETURN.
        ENDIF.

      ENDIF.

    ENDDO.

    IF MT_PLAN_ORDERS IS NOT INITIAL.
      APPEND LINES OF MT_PLAN_ORDERS TO MT_NEW_PLAN_ORDERS.
    ENDIF.

    IF LT_BACKUP_PLAN_ORDERS IS NOT INITIAL.
      REFRESH MT_PLAN_ORDERS.
      APPEND LINES OF LT_BACKUP_PLAN_ORDERS TO MT_PLAN_ORDERS.
    ENDIF.

* 선택공정 이전의 정보들은 남겨둔다.
    DATA : LS_CHAIN LIKE MS_CHAIN_2010.
    DATA : LT_CHAIN LIKE MT_CHAIN_2010.
    DATA : LT_PRE_CHAIN LIKE MT_CHAIN_2010.

    LOOP AT MT_MAKE_DISPLAY ASSIGNING <LS_MAIN>.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_CURRNET_ROUTING WITH KEY GONG_SEQ = IS_2010-GONG_SEQ.
      READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG_CURRENT> WITH KEY SEQNO = LS_CURRNET_ROUTING-SEQNO.

      READ TABLE <LS_GONG_CURRENT>-T_CHAIN ASSIGNING <LS_CHAIN_CURRENT>  WITH KEY ORDNR = IS_2010-ORDNR
                                                                                                                         POSNR = IS_2010-POSNR.
      IF SY-SUBRC EQ 0.
        APPEND <LS_CHAIN_CURRENT> TO LT_CHAIN.
        APPEND <LS_CHAIN_CURRENT> TO LT_PRE_CHAIN.

        DO.
          IF LT_PRE_CHAIN IS INITIAL.
            EXIT.
          ENDIF.
          REFRESH LT_PRE_CHAIN.

          LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ <= LS_CURRNET_ROUTING-GONG_SEQ.
            READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG> WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
            IF SY-SUBRC EQ 0.
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN>.
                READ TABLE LT_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                              POSNR = <LS_CHAIN>-DMLINE.
                IF SY-SUBRC EQ 0.
                  READ TABLE LT_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_CHAIN>-ORDNR
                                                                                               POSNR = <LS_CHAIN>-POSNR.
                  IF SY-SUBRC NE 0.
                    APPEND <LS_CHAIN> TO LT_PRE_CHAIN.

                    IF <LS_GONG>-GONG_SEQ <= MS_INFNR_INFOR-GONG_SEQ.
                      READ TABLE MT_NEW_2010 INTO DATA(LS_BACK_UP) WITH KEY GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                                         ORDNR = <LS_CHAIN>-ORDNR
                                                                                                        POSNR = <LS_CHAIN>-POSNR
                                                                                                        ORDTY = <LS_CHAIN>-ORDTY.
                      IF SY-SUBRC EQ 0.
                        APPEND LS_BACK_UP TO LT_BACKUP_2010.
                      ENDIF.
                    ENDIF.

                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDLOOP.

          IF LT_PRE_CHAIN IS NOT INITIAL.
            APPEND LINES OF LT_PRE_CHAIN TO LT_CHAIN.
          ENDIF.

        ENDDO.
      ENDIF.
    ENDLOOP.


* 체인구성을 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT LT_2010_INPUT INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING <LS_MAIN>.
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG> WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN> WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                              POSNR = LS_CHK_2010-POSNR
                                                                                              ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RESULT = 'E'.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


*  구매오더 생성
    REFRESH LT_RESB_2010.
    LT_RESB_2010 = VALUE #( FOR LW_2010 IN LT_BACKUP_2010 WHERE ( GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ )
                                      ( CORRESPONDING #( LW_2010 ) ) ).

    IF LT_RESB_2010 IS INITIAL.
      CLEAR LS_2010.
      MOVE-CORRESPONDING IS_2010 TO LS_2010.
      APPEND LS_2010 TO LT_RESB_2010.
    ENDIF.

    DATA : LV_EBELN TYPE EBELN.

    LV_EBELN = CREATE_PURCHASE_ORDER_BDC(
                  IT_2010      = LT_2010_INPUT
                  IT_RESB_2010 = LT_RESB_2010 ).

    IF LV_EBELN IS INITIAL.
      RV_RESULT = 'E'.
      RETURN.
    ENDIF.

    APPEND INITIAL LINE TO MT_PO_ORDERS ASSIGNING FIELD-SYMBOL(<LS_EBELN>).
    <LS_EBELN>-EBELN = LV_EBELN.

    DATA : LV_EBELP TYPE EBELP.

*  생성된 구매오더 정보로 체인구성
    LOOP AT LT_2010_INPUT INTO LS_2010.
      ADD 10 TO LV_EBELP.
*     이후공정 체인 구성
      LOOP AT  MT_MAKED_2010 INTO MS_MAKED_2010 WHERE REORD = LS_2010-ORDNR
                                                                          AND RELINE = LS_2010-POSNR
                                                                          AND REORDTY = LS_2010-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_SET>) WITH KEY ORDNR = MS_MAKED_2010-ORDNR
                                                                                                     POSNR = MS_MAKED_2010-POSNR
                                                                                                     ORDTY = MS_MAKED_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_DEV_SET>-REORD = LV_EBELN.
          <LS_DEV_SET>-RELINE = LV_EBELP + 0.
          <LS_DEV_SET>-REORDTY = 'PO'.
        ENDIF.

      ENDLOOP.
*     현재공정 체인 구성
      LS_2010-ORDNR = LV_EBELN.
      LS_2010-POSNR = LV_EBELP + 0.
      LS_2010-ORDTY = 'PO'.
      APPEND LS_2010 TO MT_NEW_2010.

*     이전공정 체인 구성(선택공정까지 po로 전부 세팅)
      LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ < LS_2010-GONG_SEQ.
        IF MS_INFNR_INFOR-GONG_SEQ > MS_SEQ_ROUTING_HEADER-GONG_SEQ.
          EXIT.
        ENDIF.

        CLEAR LS_2010_NEW.
        MOVE-CORRESPONDING LS_2010 TO LS_2010_NEW.
        LS_2010_NEW-GONG_CD = MS_SEQ_ROUTING_HEADER-CHART.
        LS_2010_NEW-GONG_SEQ = MS_SEQ_ROUTING_HEADER-GONG_SEQ.
        LS_2010_NEW-DMORD = LS_2010_NEW-ORDNR.
        LS_2010_NEW-DMLINE = LS_2010_NEW-POSNR.
        LS_2010_NEW-DMORDTY = LS_2010_NEW-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING <LS_DEV_SET> WITH KEY GONG_SEQ = LS_2010-GONG_SEQ
                                                                                        ORDNR = LS_2010-ORDNR
                                                                                        POSNR = LS_2010-POSNR
                                                                                        ORDTY = LS_2010-ORDTY.

        IF SY-SUBRC EQ 0.
          <LS_DEV_SET>-REORD = LS_2010-ORDNR.
          <LS_DEV_SET>-RELINE = LS_2010-POSNR.
          <LS_DEV_SET>-REORDTY = LS_2010-ORDTY.
        ENDIF.
        APPEND LS_2010_NEW TO MT_NEW_2010.

        MOVE-CORRESPONDING LS_2010_NEW TO LS_2010.

      ENDLOOP.

    ENDLOOP.

*     이전공정 체인 구성(선택공정 이전)
    DELETE LT_BACKUP_2010 WHERE GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ.
    LOOP AT LT_BACKUP_2010 ASSIGNING FIELD-SYMBOL(<LS_BACKUP>).
* 오더 삭제 테이블에서 제외
      CASE <LS_BACKUP>-ORDTY.
        WHEN 'PLN'.
          DELETE MT_PLAN_ORDERS WHERE TABLE_LINE = <LS_BACKUP>-ORDNR.
        WHEN 'PRD'.
          DELETE MT_PRD_ORDERS WHERE ORDER_NUMBER = <LS_BACKUP>-ORDNR.
        WHEN 'PO'.
          DELETE MT_PO_ORDERS WHERE EBELN = <LS_BACKUP>-ORDNR.
      ENDCASE.
      DELETE MT_DEL_2010 WHERE GONG_SEQ = <LS_BACKUP>-GONG_SEQ
                                    AND ORDNR = <LS_BACKUP>-ORDNR
                                    AND POSNR = <LS_BACKUP>-POSNR
                                    AND ORDTY = <LS_BACKUP>-ORDTY.

      READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_BACKUP>-DMORD
                                                                                   POSNR = <LS_BACKUP>-DMLINE
                                                                                   ORDTY = <LS_BACKUP>-DMORDTY.
      IF SY-SUBRC EQ 0.
        IF MS_MAKED_2010-GONG_SEQ BETWEEN MS_INFNR_INFOR-GONG_SEQ AND IS_2010-GONG_SEQ.
          <LS_BACKUP>-DMORD = LV_EBELN.
          <LS_BACKUP>-DMLINE = 10 + 0.
          <LS_BACKUP>-DMORDTY = 'PO'.

          IF <LS_BACKUP>-MATNR_SEQ = 1.

            IF MS_INFNR_INFOR-GONG_SEQ = MS_MAKED_2010-GONG_SEQ.

              LOOP AT MT_NEW_2010 ASSIGNING <LS_DEV_SET> WHERE GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ
                                                                                         AND ORDNR = LS_2010-ORDNR
                                                                                         AND ORDTY = LS_2010-ORDTY.

                <LS_DEV_SET>-REORD = <LS_BACKUP>-ORDNR.
                <LS_DEV_SET>-RELINE = <LS_BACKUP>-POSNR.
                <LS_DEV_SET>-REORDTY = <LS_BACKUP>-ORDTY.

              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    APPEND LINES OF LT_BACKUP_2010 TO MT_NEW_2010.

  ENDMETHOD.


  METHOD DELETE_ORDER.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          EV_RETURN = 'E'.
          ES_MESSAGE-MESSAGE = MV_MESSAGE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

    IF MT_DEL_2010 IS NOT INITIAL.
      SORT MT_DEL_2010 BY GONG_CD ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM MT_DEL_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.
    ENDIF.

    MV_SUCC_CNT = LINES( MT_DEL_2010 ).

    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS, MT_PR_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
        WHEN 'PO'.
          APPEND INITIAL LINE TO MT_PO_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PURCHASE_ORDER>).
          <LV_PURCHASE_ORDER>-EBELN = LS_DEL_2010-ORDNR.
        WHEN 'PR' OR 'UPR'.
          APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
          <LS_BANFN>-BANFN = LS_DEL_2010-ORDNR.
          <LS_BANFN>-BNFPO = LS_DEL_2010-POSNR + 0.

      ENDCASE.
    ENDLOOP.

    PROGRESS_INDICATOR( IV_PERCENT = 80  IV_TEXT = ' 삭제 처리중..' ).

    SORT MT_PO_ORDERS BY EBELN.
    DELETE ADJACENT DUPLICATES FROM MT_PO_ORDERS COMPARING EBELN.

    LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        EV_RETURN = 'E'.
        ES_MESSAGE-MESSAGE = '계획오더 삭제중 오류 발생하였습니다.'(E02).
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        ES_MESSAGE-MESSAGE = '생산오더 삭제중 오류 발생하였습니다.'(E03).
        EV_RETURN = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

    IF MT_PR_ORDERS[] IS NOT INITIAL.
      LV_RETURN = DELETE_PR_ORDER( ).
      IF LV_RETURN = ABAP_TRUE.
        ES_MESSAGE-MESSAGE = MV_MESSAGE.
        EV_RETURN = 'E'.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT MT_PO_ORDERS INTO DATA(LS_PO).
      CLEAR LV_RETURN.
      LV_RETURN = DEL_PO_ORDER( IV_EBELN = LS_PO-EBELN ).
      IF LV_RETURN = 'E'.
        EV_RETURN = 'E'.
        ES_MESSAGE-MESSAGE = |구매오더({ LS_PO-EBELN }) 삭제중 오류발생하였습니다.|.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF MV_SUCC_CNT NE 0.
      DATA : LV_INDEX_C(10).
      PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).
      CONFIRM( ).

      LV_INDEX_C = MV_SUCC_CNT.
      CONDENSE LV_INDEX_C.
      EV_RETURN = 'S'.
      CONCATENATE MV_GRPNR '총' LV_INDEX_C '건 오더 삭제되었습니다.' INTO ES_MESSAGE-MESSAGE SEPARATED BY SPACE.
    ENDIF.


  ENDMETHOD.


  METHOD DELETE_PR_ORDER.

    DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
    DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
    DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
    DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

    LOOP AT MT_PR_ORDERS INTO DATA(LS_PR_ORDERS).
      REFRESH : LT_PRITEM, LT_PRITEMX.
* ITEM 정보 입력
      APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
      <LS_PRITEM>-PREQ_ITEM = LS_PR_ORDERS-BNFPO.
      <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
      APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
      <LS_PRITEMX>-PREQ_ITEM = LS_PR_ORDERS-BNFPO.
      <LS_PRITEMX>-DELETE_IND = 'X'.

      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          NUMBER  = LS_PR_ORDERS-BANFN
        TABLES
          RETURN  = LT_RETURN
          PRITEM  = LT_PRITEM
          PRITEMX = LT_PRITEMX.

      IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
        RV_RESULT = ABAP_TRUE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

    REFRESH MT_PR_ORDERS.

  ENDMETHOD.


  method DELE_PLN_ORDER.

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

  endmethod.


  METHOD DEL_PO_ORDER.

    DATA : BEGIN OF LS_EKKO,
             EBELN TYPE EBELN,
             EBELP TYPE EBELP,
           END OF LS_EKKO.
    DATA : LT_EKKO LIKE TABLE OF LS_EKKO.
    DATA : LV_PURCHASEORDER   TYPE BAPIMEPOHEADER-PO_NUMBER.
    DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
    DATA : LT_POITEM   TYPE TABLE OF BAPIMEPOITEM.
    DATA : LT_POITEMX   TYPE TABLE OF BAPIMEPOITEMX.

    IF IV_EBELP IS INITIAL OR IV_EBELP = '000000'.
      SELECT EBELN EBELP FROM EKPO
        INTO CORRESPONDING FIELDS OF TABLE LT_EKKO
       WHERE EBELN = IV_EBELN.
    ELSE.
      APPEND INITIAL LINE TO LT_EKKO ASSIGNING FIELD-SYMBOL(<LS_EKKO>).
      <LS_EKKO>-EBELN = IV_EBELN.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = <LS_EKKO>-EBELN
        IMPORTING
          OUTPUT = <LS_EKKO>-EBELN.
      <LS_EKKO>-EBELP = IV_EBELP + 0.
    ENDIF.

    LOOP AT LT_EKKO INTO LS_EKKO.
      LV_PURCHASEORDER = LS_EKKO-EBELN.

      APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
      <LS_POITEM>-PO_ITEM = LS_EKKO-EBELP.
      <LS_POITEM>-DELETE_IND = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
      <LS_POITEMX>-PO_ITEM = LS_EKKO-EBELP.
      <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
      <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_PURCHASEORDER
      TABLES
        RETURN        = LT_RETURN
        POITEM        = LT_POITEM
        POITEMX       = LT_POITEMX.

    READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = 'E'.
    IF SY-SUBRC NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ELSE.
      ROLLBACK WORK.
      RV_RESULT = 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD EDIT_ADLENGTH.

    DATA : LV_TABIX TYPE I.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LV_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_CHK_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_TMP LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_SORT LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_CURRENT LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 TYPE ZGTPPT2010.
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LT_NEW_2010_SORT LIKE MT_NEW_2010.
    DATA : LT_NEW_2010_TEMP LIKE MT_NEW_2010.
    DATA : LT_MOSU_2010_PR LIKE MT_NEW_2010.
    DATA : LT_MOSU_2010_PR_TOT LIKE MT_NEW_2010.
    DATA : LT_MOSU_2010_PR_TEMP LIKE MT_NEW_2010.
    DATA : LV_CHK_QMAT.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_LOOP_IDX TYPE I.
    DATA : LS_2010 LIKE MS_MAKED_2010.
    DATA : LS_TEMP_2010 TYPE ZGTPPT2010.
    DATA : LV_SEQNO TYPE I.
    DATA : LT_PRE_2010 LIKE MT_MAKED_2010.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

* 복조장 이전공정 세팅.
    CLEAR LV_TABIX.
    DO.
      ADD 1 TO LV_TABIX.

      IF LV_TABIX = 1.
        LT_NEW_2010_SORT = IT_2010.
        SORT LT_NEW_2010_SORT BY ORDNR.
        DELETE ADJACENT DUPLICATES FROM LT_NEW_2010_SORT COMPARING ORDNR.

        LOOP AT LT_NEW_2010_SORT INTO DATA(LS_NEW_2010_SORT).
          CLEAR LV_TOTAL_QTY.

          REFRESH LT_NEW_2010.
          LT_NEW_2010 = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( ORDNR = LS_NEW_2010_SORT-ORDNR )
                                           ( CORRESPONDING #( LW_2010 ) ) ).

          IF LS_NEW_2010_SORT-MULTY_REF = ABAP_TRUE.
            LOOP AT LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).

              <LS_NEW_2010>-ADTYPE = IV_ADTYPE.
              <LS_NEW_2010>-ADLENGTH = IV_ADLENGTH.
              APPEND <LS_NEW_2010> TO LT_NEW_2010_TEMP.

              LV_TOTAL_QTY = LV_TOTAL_QTY +
                                      ( <LS_NEW_2010>-INLENGTH + <LS_NEW_2010>-QLENGTH +
                                        <LS_NEW_2010>-CLENGTH + <LS_NEW_2010>-SLENGTH +
                                        <LS_NEW_2010>-ELENGTH + <LS_NEW_2010>-ADLENGTH ) * <LS_NEW_2010>-INFACTOR.
            ENDLOOP.
          ELSE.
            LOOP AT LT_NEW_2010 ASSIGNING <LS_NEW_2010>.
              READ TABLE IT_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_NEW_2010>-ORDNR
                                                                                         POSNR = <LS_NEW_2010>-POSNR
                                                                                         ORDTY = <LS_NEW_2010>-ORDTY.
              IF SY-SUBRC EQ 0.
                <LS_NEW_2010>-ADTYPE = IV_ADTYPE.
                <LS_NEW_2010>-ADLENGTH = IV_ADLENGTH.
                APPEND <LS_NEW_2010> TO LT_NEW_2010_TEMP.
              ENDIF.
              LV_TOTAL_QTY = LV_TOTAL_QTY +
                                      ( <LS_NEW_2010>-INLENGTH + <LS_NEW_2010>-QLENGTH +
                                        <LS_NEW_2010>-CLENGTH + <LS_NEW_2010>-SLENGTH +
                                        <LS_NEW_2010>-ELENGTH + <LS_NEW_2010>-ADLENGTH ) * <LS_NEW_2010>-INFACTOR.
            ENDLOOP.
          ENDIF.

          APPEND LINES OF LT_NEW_2010 TO LT_DEV_2010.
*          오더변경
          CASE LS_NEW_2010_SORT-ORDTY.
            WHEN 'PRD'.
              LV_RETURN = CHANGE_PRD_ORDER(
                            IV_TOTAL_QTY = LV_TOTAL_QTY " 오더 수량 총계
                            IV_ORDNR     = LS_NEW_2010_SORT-ORDNR" 오더번호
                            IT_2010      = LT_NEW_2010 ).
            WHEN 'PLN'.
              LV_RETURN = CHANGE_PLN_ORDER(
                            IV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                            IV_ORDNR     = LS_NEW_2010_SORT-ORDNR ).                 " 오더번호
            WHEN OTHERS.
          ENDCASE.

*      최초 작업이 조장체인 중간케이스인 경우 resb테이블 업데이트
          IF NOT ( LINE_EXISTS( IT_2010[ DMORDTY = 'SO' ] ) OR  LINE_EXISTS( IT_2010[ DMORDTY = 'SM' ] ) ).
            CASE LS_NEW_2010_SORT-ORDTY.
              WHEN 'PRD' OR 'PLN'.
                UPDATE_RESB( IT_2010 = LT_NEW_2010 ).
            ENDCASE.
          ENDIF.

        ENDLOOP.

      ELSE.

        LT_NEW_2010_SORT = LT_NEW_2010.
        SORT LT_NEW_2010_SORT BY ORDNR POSNR.
        DELETE ADJACENT DUPLICATES FROM LT_NEW_2010_SORT COMPARING ORDNR.

        LOOP AT LT_NEW_2010_SORT INTO LS_NEW_2010_SORT.
          REFRESH LT_DEV_2010_TMP.
* 해당 공정의 이후 공정을 찾아 조장 계산후 resb적용
          READ TABLE MT_NEW_2010 INTO DATA(LS_TEMP_DEV) WITH KEY ORDNR = LS_NEW_2010_SORT-DMORD
                                                                                        POSNR = LS_NEW_2010_SORT-DMLINE
                                                                                        ORDTY = LS_NEW_2010_SORT-DMORDTY.
          IF SY-SUBRC EQ 0.
            LOOP AT MT_NEW_2010 INTO LS_DEV_2010 WHERE REORD = LS_TEMP_DEV-REORD
                                                                       AND RELINE = LS_TEMP_DEV-RELINE
                                                                       AND REORDTY = LS_TEMP_DEV-REORDTY.
              APPEND LS_DEV_2010 TO LT_DEV_2010_TMP.
            ENDLOOP.

          ENDIF.


          SORT LT_DEV_2010_TMP BY GONG_CD GONG_SEQ ORDNR POSNR ORDTY.
          DELETE ADJACENT DUPLICATES FROM LT_DEV_2010_TMP COMPARING GONG_CD GONG_SEQ ORDNR POSNR ORDTY.

          CLEAR : LV_FINDATE.
          GET_FINDATE(
            EXPORTING
              IV_ORDNR   = LS_NEW_2010_SORT-DMORD  " 오더번호
              IV_ORDTY   = LS_NEW_2010_SORT-DMORDTY" 오더유형
          IMPORTING
            EV_FINDATE = LV_FINDATE ).               " ABAP system field: Current date of application server

          REFRESH LT_NEW_2010_TEMP.
          LT_NEW_2010_TEMP = VALUE #( FOR LW_2010 IN LT_NEW_2010 WHERE ( ORDNR = LS_NEW_2010_SORT-ORDNR )
                                           ( CORRESPONDING #( LW_2010 ) ) ).

          LOOP AT LT_NEW_2010_TEMP ASSIGNING <LS_NEW_2010>.
            IF LINES( LT_DEV_2010_TMP ) = 1.
              READ TABLE LT_DEV_2010_TMP INTO DATA(LS_DEV_2010_TMP) INDEX 1.
              CAL_LC(
                EXPORTING
                  IV_DEV_2010        = LS_DEV_2010_TMP                 " [GT] 오더 연결 정보
                  IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
                IMPORTING
                  EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                  EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
                CHANGING
                  CS_CURRENT_2010    = <LS_NEW_2010> ).                " [GT] 오더 연결 정보
            ELSEIF LINES( LT_DEV_2010_TMP ) > 1.
              CALC_LC_MULTY(
                EXPORTING
                  IT_DEV_2010  = LT_DEV_2010_TMP
                  IV_BASE_DATE = LV_FINDATE " ABAP system field: Current date of application server
                  IV_MATNR     = <LS_NEW_2010>-MATNR                 " 자재 번호
                IMPORTING
                  EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
                  EV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                CHANGING
                  CS_2010      = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보
            ENDIF.

*          해당 라인 PR생성 대상인 경우 PR변경없이 새로 생성을 해야함
            READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
            LOOP AT MT_SEQ_ROUTING_SUB INTO MS_SEQ_ROUTING_SUB.
              LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_ROUTING).
                LOOP AT LS_ROUTING-T_BOM INTO DATA(LS_BOM) WHERE  SEQNO = <LS_NEW_2010>-MATNR_SEQ
                                                                               AND MATNR = <LS_NEW_2010>-MATNR.
                  CASE LS_ROUTING-BESKZ.
                    WHEN 'EP'.
                      IF <LS_NEW_2010>-ORDTY = 'PR' OR <LS_NEW_2010>-ORDTY = 'UPR'.
                        READ TABLE LT_DEV_2010_TMP INTO DATA(LS_CHK_DATA) WITH KEY ORDNR = <LS_NEW_2010>-DMORD
                                                                                        POSNR = <LS_NEW_2010>-DMLINE
                                                                                        ORDTY = <LS_NEW_2010>-DMORDTY.
                        IF SY-SUBRC EQ 0.
                          APPEND <LS_NEW_2010> TO LT_MOSU_2010_PR.
                        ELSE.
                          DELETE TABLE LT_NEW_2010_TEMP FROM <LS_NEW_2010>.
                        ENDIF.
                      ENDIF.
                  ENDCASE.
                  EXIT.
                ENDLOOP.
                IF LT_NEW_2010_TEMP IS INITIAL.
                  EXIT.
                ENDIF.
              ENDLOOP.
              IF LT_NEW_2010_TEMP IS INITIAL.
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDLOOP.

          IF LV_RETURN = 'E'.
            EXIT.
          ENDIF.


          APPEND LINES OF LT_NEW_2010_TEMP TO LT_DEV_2010.

*          오더변경
          CASE LS_NEW_2010_SORT-ORDTY.
            WHEN 'PRD'.
              LV_RETURN = CHANGE_PRD_ORDER(
                            IV_TOTAL_QTY = LV_TOTAL_QTY " 오더 수량 총계
                            IV_ORDNR     = LS_NEW_2010_SORT-ORDNR" 오더번호
                            IT_2010      = LT_NEW_2010_TEMP ).

              LOOP AT LT_NEW_2010_TEMP INTO DATA(LS_NEW_2010_TEMP).
                CLEAR LS_2010.
                MOVE-CORRESPONDING LS_NEW_2010_TEMP TO LS_2010.
                LV_RETURN = SET_PRD_CHARICTERISTIC( EXPORTING IS_2010   = LS_2010 IV_GUBUN = 'C' ).
                IF LV_RETURN = 'E'.
                  EXIT.
                ENDIF.
              ENDLOOP.

            WHEN 'PLN'.
              LV_RETURN = CHANGE_PLN_ORDER(
                            IV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                            IV_ORDNR     = LS_NEW_2010_SORT-ORDNR ).                 " 오더번호
            WHEN OTHERS.
          ENDCASE.


          IF LV_RETURN = 'E'.
            EXIT.
          ENDIF.

        ENDLOOP.

*      최초 작업이 조장체인 중간케이스인 경우 resb테이블 업데이트
        CASE LS_NEW_2010_SORT-ORDTY.
          WHEN 'PRD' OR 'PLN' OR 'PR'.
            READ TABLE LT_DEV_2010_TMP INTO LS_DEV_2010_TMP INDEX 1.
            IF LS_DEV_2010_TMP-ORDTY NE 'PR'.
              UPDATE_RESB( IT_2010 = LT_DEV_2010 ).
            ENDIF.
        ENDCASE.

        PROGRESS_INDICATOR( IV_PERCENT = 50  IV_TEXT = '변경여장 계산완료 오더 변경중..' ).

      ENDIF.

      IF LV_RETURN = 'E'. " 에러시 종료 처리후 메시지, 롤백처리
        EXIT.
      ENDIF.

      REFRESH LT_NEW_2010.

      LOOP AT LT_DEV_2010 INTO LS_DEV_2010.
        READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY ORDNR = LS_DEV_2010-ORDNR
                                                                                               POSNR = LS_DEV_2010-POSNR
                                                                                               ORDTY = LS_DEV_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_DEV_2010 TO <LS_NEW_2010>.
        ENDIF.

        READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_DEV_2010-GONG_SEQ.
        LV_SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO - 1.
        LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
          LOOP AT <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WHERE SEQNO < MS_SEQ_ROUTING_HEADER-SEQNO.
            IF LS_DEV_2010-REF_TANDEM = 'T' AND LV_SEQNO =  <LS_GONG>-SEQNO. " 현재 작업 공정이 탄뎀 이라면 중복체크 적용 없음. 대신 REF_TANDEM = 'X'
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WHERE DMORD = LS_DEV_2010-ORDNR
                                                                                                                  AND  DMLINE = LS_DEV_2010-POSNR
                                                                                                                  AND  DMORDTY = LS_DEV_2010-ORDTY.

                READ TABLE MT_NEW_2010 INTO DATA(MS_NEW_2010) WITH KEY ORDNR = <LS_CHAIN>-ORDNR
                                                                                             POSNR = <LS_CHAIN>-POSNR
                                                                                             ORDTY = <LS_CHAIN>-ORDTY
                                                                                             REF_TANDEM = ABAP_TRUE.
                IF SY-SUBRC EQ 0.
                  APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_GET_DATA>).
                  MOVE-CORRESPONDING MS_NEW_2010 TO <LS_GET_DATA>.
                ENDIF.
              ENDLOOP.

            ELSE.
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN> WHERE DMORD = LS_DEV_2010-ORDNR
                                                                                              AND  DMLINE = LS_DEV_2010-POSNR
                                                                                              AND  DMORDTY = LS_DEV_2010-ORDTY
                                                                                              AND  CHK_DUP = ''.

                READ TABLE MT_NEW_2010 INTO MS_NEW_2010 WITH KEY ORDNR = <LS_CHAIN>-ORDNR
                                                                                       POSNR = <LS_CHAIN>-POSNR
                                                                                       ORDTY = <LS_CHAIN>-ORDTY.
                IF SY-SUBRC EQ 0.
                  APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_GET_DATA>.
                  MOVE-CORRESPONDING MS_NEW_2010 TO <LS_GET_DATA>.
                ENDIF.
              ENDLOOP.

            ENDIF.

          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
      SORT LT_NEW_2010 BY GONG_CD GONG_SEQ ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM LT_NEW_2010 COMPARING GONG_CD GONG_SEQ ORDNR POSNR ORDTY.

      REFRESH LT_DEV_2010.

* 이전공정 존재하지 않는다면 종료
      IF LT_NEW_2010[] IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.

    IF LV_RETURN = 'E'.
      RETURN.
    ENDIF.

*   PR은 변경안하고 새로 생성해야함. 대상건 존재시 생성하여 반영
    IF LT_MOSU_2010_PR[] IS NOT INITIAL.
      DATA : LT_PR_ORDERS LIKE MT_PR_ORDERS.
      DATA : LT_PR_ORDERS_ORIGN LIKE MT_PR_ORDERS.

      LOOP AT LT_MOSU_2010_PR INTO DATA(LS_DEL_PR).
        CASE LS_DEL_PR-ORDTY.
          WHEN 'PR' OR 'UPR'.
            APPEND INITIAL LINE TO LT_PR_ORDERS_ORIGN ASSIGNING FIELD-SYMBOL(<LS_PR_ORDERS_ORIGN>).
            <LS_PR_ORDERS_ORIGN>-BANFN = LS_DEL_PR-ORDNR.
            <LS_PR_ORDERS_ORIGN>-BNFPO = LS_DEL_PR-POSNR+1(5).
          WHEN 'PRD'.
            APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
            <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_PR-ORDNR.
          WHEN 'PLN'.
            APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
            <LV_PLAN_ORDER> = LS_DEL_PR-ORDNR.
        ENDCASE.

      ENDLOOP.

      SORT LT_MOSU_2010_PR BY ORDNR.
      DELETE ADJACENT DUPLICATES FROM LT_MOSU_2010_PR COMPARING ORDNR.

      LOOP AT LT_MOSU_2010_PR INTO DATA(LS_MOSU).

        REFRESH LT_MOSU_2010_PR_TEMP.
        LT_MOSU_2010_PR_TEMP = VALUE #( FOR LW_PR IN MT_NEW_2010 WHERE ( ORDNR = LS_MOSU-ORDNR )
                                                         ( CORRESPONDING #( LW_PR ) ) ).

        REFRESH LT_DEV_2010.
        LT_DEV_2010 = VALUE #( FOR LW_PR IN MT_NEW_2010 WHERE ( ORDNR = LS_MOSU-DMORD )
                                                      ( CORRESPONDING #( LW_PR ) ) ).


        READ TABLE  LT_DEV_2010 INTO LS_DEV_2010 INDEX 1.

        CLEAR : LV_FINDATE, LV_RSNUM.
        GET_FINDATE(
          EXPORTING
            IV_ORDNR   = LS_DEV_2010-ORDNR  " 오더번호
            IV_ORDTY   = LS_DEV_2010-ORDTY" 오더유형
        IMPORTING
          EV_FINDATE = LV_FINDATE
          EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

        CLEAR LV_LOOP_IDX.

        LOOP AT LT_MOSU_2010_PR_TEMP ASSIGNING FIELD-SYMBOL(<LS_TEMP_MOSU>).

          ADD 1 TO LV_LOOP_IDX.

          READ TABLE LT_DEV_2010 INTO LS_DEV_2010 WITH KEY REORD = <LS_TEMP_MOSU>-ORDNR
                                                                                RELINE = <LS_TEMP_MOSU>-POSNR.
          CAL_LC(
            EXPORTING
              IV_DEV_2010        = LS_DEV_2010                 " [GT] 오더 연결 정보
              IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
            IMPORTING
              EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
              EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
            CHANGING
              CS_CURRENT_2010    = <LS_TEMP_MOSU>                 " [GT] 오더 연결 정보
          ).

          IF LV_RETURN = 'E'.
            RV_MESSAGE = '여장 추가중 오류 발생하였습니다.'.
            RETURN.
          ENDIF.

          IF LV_LOOP_IDX = 1.
            CLEAR LS_TEMP_2010.
            MOVE <LS_TEMP_MOSU> TO LS_TEMP_2010.

            CALC_LC_MULTY(
              EXPORTING
                IT_DEV_2010  = LT_DEV_2010
                IV_BASE_DATE = LV_FINDATE " ABAP system field: Current date of application server
                IV_MATNR     = LS_TEMP_2010-MATNR                 " 자재 번호
              IMPORTING
                EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
                EV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
              CHANGING
                CS_2010      = LS_TEMP_2010 ).                 " [GT] 오더 연결 정보

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
            CLEAR LV_CHK_QMAT.
            IF LS_TEMP_2010-QLENGTH > 0.
              LV_CHK_QMAT = ABAP_TRUE.
            ENDIF.

            CLEAR LV_EXCLUDING_LENGTH.
            IF LV_CHK_QMAT = ABAP_TRUE.
              SELECT SINGLE MATNR FROM QMAT
                INTO @DATA(LV_CHK_MATNR)
               WHERE MATNR = @LS_TEMP_2010-MATNR
                 AND WERKS = @MV_WERKS
                 AND ART = '04'
                 AND AKTIV = 'X'.
              IF SY-SUBRC EQ 0.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - LS_TEMP_2010-QLENGTH.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
              ENDIF.
            ELSE.
              LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
            ENDIF.

            IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
              LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
            ENDIF.
          ELSE.
            CLEAR : <LS_TEMP_MOSU>-CLENGTH, <LS_TEMP_MOSU>-CLENGTH,
                    <LS_TEMP_MOSU>-SLENGTH, <LS_TEMP_MOSU>-ELENGTH.

          ENDIF.

        ENDLOOP.

        LV_RETURN = CREATE_PR_ORDER_MULTY(
                    EXPORTING
                      IV_FINDATE = LV_FINDATE                 " ABAP system field: Current date of application server
                    CHANGING
                      CT_2010    = LT_MOSU_2010_PR_TEMP ).

        IF LV_RETURN = 'E'.
          RV_MESSAGE = '여장 추가중 오류 발생하였습니다.'.
          RETURN.
        ENDIF.

        LOOP AT LT_MOSU_2010_PR_TEMP INTO DATA(LS_NEW_2010).
          READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_SET_DMORD>) WITH KEY  ORDNR = LS_NEW_2010-DMORD
                                                                                                                  POSNR = LS_NEW_2010-DMLINE
                                                                                                                  ORDTY = LS_NEW_2010-DMORDTY.
          IF SY-SUBRC EQ 0.

            READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY ORDNR = <LS_SET_DMORD>-REORD
                                                                                            POSNR = <LS_SET_DMORD>-RELINE
                                                                                            ORDTY = <LS_SET_DMORD>-REORDTY.
            IF SY-SUBRC EQ 0.

              APPEND INITIAL LINE TO LT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PR_ORDER>).
              <LS_PR_ORDER>-BANFN = <LS_NEW_2010>-ORDNR.
              <LS_PR_ORDER>-BNFPO = <LS_NEW_2010>-POSNR + 0.


              MOVE-CORRESPONDING LS_NEW_2010 TO <LS_NEW_2010>.
            ENDIF.

            <LS_SET_DMORD>-REORD = LS_NEW_2010-ORDNR.
            <LS_SET_DMORD>-RELINE = LS_NEW_2010-POSNR.
            <LS_SET_DMORD>-REORDTY = LS_NEW_2010-ORDTY.

          ENDIF.
        ENDLOOP.

* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
        REFRESH LT_RESB.
        SELECT A~*
          FROM RESB AS A
          INNER JOIN MARA AS B
                          ON B~MATNR = A~MATNR
          INNER JOIN MARC AS C
                          ON C~MATNR = A~MATNR
          INNER JOIN ZGTCVMSTVAL AS D
                          ON D~MATNR = C~MATNR
                         AND D~WERKS = C~WERKS
          INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
          WHERE B~MTART = 'MCHF'
            AND A~STLTY = 'M' " BOM 대상
            AND A~DUMPS = '' " 가상품목이 아닌경우
            AND C~WERKS = @MV_WERKS
            AND C~BESKZ IN ('E', 'X')
            AND D~PDCAPROCCODE NE 'BWD'
            AND A~RSNUM = @LV_RSNUM.

        LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

          <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
              I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
              I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
              I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*             I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
            IMPORTING
              E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
            EXCEPTIONS
              ERROR_IN_APPLICATION = 1
              ERROR                = 2
              OTHERS               = 3.

        ENDLOOP.

        LOOP AT LT_RESB INTO DATA(LS_RESB).

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

* 업데이트 되는 이후 공정이 탄뎀 참조 오더라면 탄뎀 공정에 resb 업데이트
        READ TABLE MT_MAKED_2010 INTO DATA(LS_MAKED_2010) WITH KEY ORDNR = LS_DEV_2010-DMORD
                                                                                     POSNR = LS_DEV_2010-DMLINE
                                                                                     ORDTY = LS_DEV_2010-DMORDTY.
        IF SY-SUBRC EQ 0 AND LS_MAKED_2010-REF_TANDEM = ABAP_TRUE.

          REFRESH LT_PRE_2010.
          READ TABLE MT_MAKED_2010 INTO DATA(LS_CHK_DEV_2010) WITH KEY ORDNR = LS_MAKED_2010-DMORD
                                                                                                POSNR = LS_MAKED_2010-DMLINE
                                                                                                ORDTY = LS_MAKED_2010-DMORDTY
                                                                                                REF_TANDEM = 'T'.
          IF SY-SUBRC EQ 0.
            LOOP AT MT_MAKED_2010 INTO DATA(LS_PRE) WHERE DMORD = LS_CHK_DEV_2010-ORDNR
                                                                    AND DMLINE = LS_CHK_DEV_2010-POSNR
                                                                    AND DMORDTY = LS_CHK_DEV_2010-ORDTY.

              APPEND LS_PRE TO LT_PRE_2010.
            ENDLOOP.

* 탄뎀공정의 RESB반영
            UPDATE_TANDEM_RESB(
              IS_CURRENT   = LS_CHK_DEV_2010
              IT_CHAIN_PRE = LT_PRE_2010
              IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

          ENDIF.
        ENDIF.


      ENDLOOP.

      IF LT_PR_ORDERS[] IS NOT INITIAL.
        REFRESH MT_PR_ORDERS[].
        MT_PR_ORDERS = LT_PR_ORDERS.
        LV_RETURN = DELETE_PR_ORDER( ).
      ENDIF.
    ENDIF.

    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

    ENDIF.

    IF LT_PR_ORDERS_ORIGN[] IS NOT INITIAL.
      REFRESH MT_PR_ORDERS[].
      MT_PR_ORDERS = LT_PR_ORDERS_ORIGN.
      LV_RETURN = DELETE_PR_ORDER( ).
    ENDIF.

    LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
    ENDLOOP.


    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).

*  완제품 변경건 존재시 포장재 확인 로직
    IF LINE_EXISTS( IT_2010[ DMORDTY = 'SO' ] ) OR LINE_EXISTS( IT_2010[ DMORDTY = 'SM' ] ).
      CHG_PACK_COFIRM( ).
    ENDIF.


    CONFIRM( ).


  ENDMETHOD.


  METHOD GET_CHAIN_TO_DELETE.

    DATA : LT_CHK_DEL_2010 LIKE TABLE OF MS_2010.
    DATA : LV_SEQNO TYPE I.
    DATA : LV_TABIX TYPE I.
    DATA : LV_TABIX2 TYPE I.

    READ TABLE MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WITH KEY END_SEQNO = IV_MAIN_SEQ.
    IF SY-SUBRC EQ 0.
      READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = IV_GONG_SEQ.
      LOOP AT  <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WHERE ORDNR = IS_2010-ORDNR
                                                                                                      AND POSNR = IS_2010-POSNR
                                                                                                      AND ORDTY = IS_2010-ORDTY.
        IF SY-SUBRC EQ 0 AND <LS_CHAIN>-CHK_STATUS NE 'D'.
          <LS_CHAIN>-CHK_STATUS = 'D'.
* 해당 공정을 하위로 가지는 이후공정오더 변경
          LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WHERE REORD = IS_2010-ORDNR
                                                                                                  AND  RELINE = IS_2010-POSNR
                                                                                                  AND  REORDTY = IS_2010-ORDTY.
            CLEAR :  <LS_DEV_2010>-REORD, <LS_DEV_2010>-RELINE, <LS_DEV_2010>-REORDTY.
          ENDLOOP.

* 해당 공정을 삭제 테이블로 가져 간다.
          READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WITH KEY GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                                              ORDNR = <LS_CHAIN>-ORDNR
                                                                                                              POSNR = <LS_CHAIN>-POSNR
                                                                                                              ORDTY = <LS_CHAIN>-ORDTY.
          IF SY-SUBRC EQ 0.
            LV_TABIX = SY-TABIX.
            APPEND <LS_2010> TO MT_DEL_2010.

* * 완제품 Factor Batch 복조장의 경우 참조 테이블 확인
            IF <LS_2010>-MULTY_REF = ABAP_TRUE.
              LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_CHK_REF>) WHERE GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                                    AND ORDNR = <LS_CHAIN>-ORDNR
                                                                                                    AND POSNR NE <LS_CHAIN>-POSNR
                                                                                                    AND ORDTY = 'REF'.

                LV_TABIX2 = SY-TABIX.
                APPEND <LS_CHK_REF> TO MT_DEL_2010.
                DELETE MT_NEW_2010 INDEX LV_TABIX2.
              ENDLOOP.
            ENDIF.

            DELETE MT_NEW_2010 INDEX LV_TABIX.

          ELSE.
            READ TABLE MT_DEL_2010 TRANSPORTING NO FIELDS WITH KEY GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                          ORDNR = <LS_CHAIN>-ORDNR
                                                                                          POSNR = <LS_CHAIN>-POSNR
                                                                                          ORDTY = <LS_CHAIN>-ORDTY.
            IF SY-SUBRC EQ 0.
              " 삭제 테이블에 이미 적재되어 있으므로 정상
            ELSE.
              RV_RETURN = 'E'.
              MV_MESSAGE = '오더 삭제 중 오류 발생하였습니다.'.
              RETURN.
            ENDIF.
          ENDIF.

* 해당 공정을 이후 공정으로 가져가는 이전 공정들 전체 삭제대상
          LV_SEQNO = IV_GONG_SEQ - 1.
          DO.
            IF LV_SEQNO = 0.
              EXIT.
            ENDIF.
            READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_PRE_GONG>) WITH KEY SEQNO = LV_SEQNO.
            LOOP AT  <LS_PRE_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_PRE_CHAIN>).
              IF <LS_PRE_CHAIN>-CHK_STATUS = 'D'.
                CONTINUE.
              ENDIF.

              IF <LS_PRE_CHAIN>-ORDNR IS INITIAL.
                CONTINUE.
              ENDIF.

              READ TABLE MT_NEW_2010 ASSIGNING <LS_DEV_2010> WITH KEY GONG_SEQ = <LS_PRE_GONG>-GONG_SEQ
                                                                                                       ORDNR = <LS_PRE_CHAIN>-ORDNR
                                                                                                       POSNR = <LS_PRE_CHAIN>-POSNR
                                                                                                       ORDTY = <LS_PRE_CHAIN>-ORDTY.
              IF SY-SUBRC EQ 0.
                LV_TABIX = SY-TABIX.
                READ TABLE MT_DEL_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_PRE_CHAIN>-DMORD
                                                                                             POSNR = <LS_PRE_CHAIN>-DMLINE
                                                                                             ORDTY = <LS_PRE_CHAIN>-DMORDTY.
                IF SY-SUBRC EQ 0.
                  APPEND <LS_DEV_2010> TO MT_DEL_2010.
                  DELETE MT_NEW_2010 INDEX LV_TABIX.
                  <LS_PRE_CHAIN>-CHK_STATUS = 'D'.
                  CONTINUE.
                ENDIF.

                READ TABLE MT_DEL_2010 TRANSPORTING NO FIELDS WITH KEY REORD = <LS_PRE_CHAIN>-ORDNR
                                                                                             RELINE = <LS_PRE_CHAIN>-POSNR
                                                                                             REORDTY = <LS_PRE_CHAIN>-ORDTY.

                IF SY-SUBRC EQ 0.
                  APPEND <LS_DEV_2010> TO MT_DEL_2010.
                  DELETE MT_NEW_2010 INDEX LV_TABIX.
                  <LS_PRE_CHAIN>-CHK_STATUS = 'D'.
                  CONTINUE.
                ENDIF.

*     해당단계까지 체인구성 못찾으면 대상 아님
              ELSE.
                READ TABLE MT_DEL_2010 TRANSPORTING NO FIELDS WITH KEY     GONG_SEQ = <LS_PRE_GONG>-GONG_SEQ
                                                                                                          ORDNR = <LS_PRE_CHAIN>-ORDNR
                                                                                                          POSNR = <LS_PRE_CHAIN>-POSNR
                                                                                                          ORDTY = <LS_PRE_CHAIN>-ORDTY.
                IF SY-SUBRC EQ 0.
                  " 삭제 테이블에 이미 적재되어 있으므로 정상
                ELSE.
                  RV_RETURN = 'E'.
                  MV_MESSAGE = '오더 삭제 중 오류 발생하였습니다.'.
                  RETURN.
                ENDIF.
              ENDIF.

            ENDLOOP.

            LV_SEQNO = LV_SEQNO - 1.

          ENDDO.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  method GET_DEV_CHAIN.



  endmethod.


  METHOD GET_FINDATE.

    DATA : LV_PLNUM TYPE PLNUM.
    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_EDATU TYPE ZGTPPT2000-EDATU.

    CASE IV_ORDTY.
      WHEN 'SO' OR 'SM'. " 판매오더 기준, SM 생산오더 기준, resb번호는 없음
        SELECT SINGLE EDATU
          FROM ZGTPPT2000
         WHERE GRPNR = @MV_GRPNR
            AND WERKS = @MV_WERKS
            AND ORDNO = @IV_ORDNR
           INTO ( @LV_EDATU ).
        EV_FINDATE = LV_EDATU - 1.

      WHEN 'PLN'.
        LV_PLNUM = IV_ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_PLNUM
          IMPORTING
            OUTPUT = LV_PLNUM.

        SELECT SINGLE
          FROM PLAF
          FIELDS PSTTR, RSNUM
         WHERE PLNUM = @LV_PLNUM
           INTO ( @EV_FINDATE, @EV_RSNUM ).

        EV_FINDATE = EV_FINDATE - 1.

      WHEN 'PRD'.
        LV_AUFNR = IV_ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_AUFNR
          IMPORTING
            OUTPUT = LV_AUFNR.

        SELECT SINGLE
          FROM AFKO
          FIELDS GSTRP, RSNUM
         WHERE AUFNR = @LV_AUFNR
            INTO ( @EV_FINDATE, @EV_RSNUM ).

        EV_FINDATE = EV_FINDATE - 1.
      WHEN 'PO'.
        SELECT SINGLE MIN( BDTER ) FROM RESB
          INTO EV_FINDATE
         WHERE EBELN = IV_ORDNR.
        EV_FINDATE = EV_FINDATE - 1.
    ENDCASE.

    IF EV_FINDATE < SY-DATUM.
      EV_FINDATE = SY-DATUM.
    ENDIF.

  ENDMETHOD.


  METHOD GET_JOJANG_MASTER.

    REFRESH MT_2000.
    SELECT * FROM ZGTPPT2000
      INTO TABLE MT_2000
     WHERE GRPNR = MV_GRPNR
        AND ZSTATUS NE 'D'.

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
        MMORY                 = '0'
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

  ENDMETHOD.


  METHOD GET_MODIFIED_FROM_CHAIN.

* 이후공정의 연결된 하위 공정 오더 변경
    LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WHERE REORD = IS_2010_ORIGN-ORDNR
                                                                                            AND  RELINE = IS_2010_ORIGN-POSNR
                                                                                            AND  REORDTY = IS_2010_ORIGN-ORDTY.
      <LS_DEV_2010>-REORD = IS_2010_CHG-ORDNR.
      <LS_DEV_2010>-RELINE = IS_2010_CHG-POSNR.
      <LS_DEV_2010>-REORDTY = IS_2010_CHG-ORDTY.
    ENDLOOP.

* 이전 공정의 연결된 이후 공정오더 변경
    LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_PRE_2010>) WHERE DMORD = IS_2010_ORIGN-ORDNR
                                                                                            AND  DMLINE = IS_2010_ORIGN-POSNR
                                                                                            AND  DMORDTY = IS_2010_ORIGN-ORDTY.
      <LS_PRE_2010>-DMORD = IS_2010_CHG-ORDNR.
      <LS_PRE_2010>-DMLINE = IS_2010_CHG-POSNR.
      <LS_PRE_2010>-DMORDTY = IS_2010_CHG-ORDTY.
    ENDLOOP.

* 현재 공정 변경
    LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WHERE ORDNR = IS_2010_ORIGN-ORDNR
                                                                                            AND  POSNR = IS_2010_ORIGN-POSNR
                                                                                            AND  ORDTY = IS_2010_ORIGN-ORDTY.
      <LS_2010>-ORDNR = IS_2010_CHG-ORDNR.
      <LS_2010>-POSNR = IS_2010_CHG-POSNR.
      <LS_2010>-ORDTY = IS_2010_CHG-ORDTY.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_ORD_INFOR_OF_PEGGING.

    DATA : LS_2010 TYPE ZGTPPT2010.

* Pegging 될 오더가 조장 구성표에 존재하는지 확인
    SELECT * FROM ZGTPPT2010
      INTO TABLE ET_2010
     WHERE ORDNR = IV_ORDNR
       AND ORDTY = IV_ORDTY.

    IF SY-SUBRC EQ 0.
      EV_CHK_JOJANG = ABAP_TRUE.
      READ TABLE ET_2010 INTO DATA(LS_TEMP) INDEX 1.
      SELECT * FROM ZGTPPT2010
        INTO TABLE ET_2010_FULL
       WHERE GRPNR = LS_TEMP-GRPNR.
    ELSE.

* 원천테이블에서 데이터 조회하여 pegging table 구성
      CASE IV_ORDTY.
        WHEN 'PRD'.
          SELECT AUFNR, POSNR, PSMNG, MATNR, MILLCALENGTH, MILLCAFACTOR
            FROM  ZGTCVORDSYVAL
           WHERE AUFNR = @IV_ORDNR
             INTO TABLE @DATA(LT_AFPO).

          IF IV_POSNR NE '000000'.
            DELETE LT_AFPO WHERE POSNR NE IV_POSNR+2(4).
          ENDIF.
          LOOP AT LT_AFPO INTO DATA(LS_AFPO).
            CLEAR LS_2010.
            LS_2010-ORDNR = LS_AFPO-AUFNR.
            LS_2010-POSNR = LS_AFPO-POSNR + 0.
            LS_2010-ORDTY = 'PRD'.
            IF LS_AFPO-MILLCALENGTH = 0.
              LS_2010-INLENGTH = LS_AFPO-PSMNG.
              LS_AFPO-MILLCALENGTH = LS_AFPO-PSMNG.
            ELSE.
              LS_2010-INLENGTH = LS_AFPO-MILLCALENGTH.
            ENDIF.

            IF LS_AFPO-MILLCAFACTOR = 0.
              LS_AFPO-MILLCAFACTOR = 1.
              LS_2010-INFACTOR = 1.
            ELSE.
              LS_2010-INFACTOR = LS_AFPO-MILLCAFACTOR.
            ENDIF.

            IF LS_2010-INFACTOR = 1.
              LS_2010-QLENGTH = LS_AFPO-PSMNG - LS_AFPO-MILLCALENGTH.
            ELSE.
              LS_2010-QLENGTH = ( LS_AFPO-PSMNG / LS_2010-INFACTOR ) - LS_AFPO-MILLCALENGTH.
            ENDIF.

            LS_2010-REAL_MATNR = LS_AFPO-MATNR.
            APPEND LS_2010 TO ET_2010.
          ENDLOOP.
        WHEN 'PO'.
          SELECT EBELN, EBELP, MATNR, MENGE, CUOBJ
            FROM  EKPO
           WHERE EBELN = @IV_ORDNR
             INTO TABLE @DATA(LT_EKPO).

          IF IV_POSNR NE '000000'.
            DELETE LT_EKPO WHERE EBELP NE IV_POSNR+1(5).
          ENDIF.
          LOOP AT LT_EKPO INTO DATA(LS_EKPO).
            CLEAR LS_2010.
            LS_2010-ORDNR = LS_EKPO-EBELN.
            LS_2010-POSNR = LS_EKPO-EBELP.
            LS_2010-ORDTY = 'PO'.
            ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
              EXPORTING
                IV_CUOBJ      = LS_EKPO-CUOBJ                 " 구성
              IMPORTING
                EV_ZGTEINDLEN = LS_2010-INLENGTH
                EV_ZGTEFACTOR = LS_2010-INFACTOR  ).

            IF LS_2010-INLENGTH = 0.
              LS_2010-INLENGTH = LS_EKPO-MENGE.
              LS_2010-INFACTOR = 1.
            ENDIF.

            IF LS_2010-INFACTOR = 0.
              LS_2010-INFACTOR = 1.
            ENDIF.

            IF LS_2010-INFACTOR = 1.
              LS_2010-QLENGTH = LS_EKPO-MENGE - LS_2010-INLENGTH.
            ELSE.
              LS_2010-QLENGTH = ( LS_EKPO-MENGE / LS_2010-INFACTOR ) - LS_2010-INLENGTH.
            ENDIF.

            LS_2010-MATNR = LS_EKPO-MATNR.
            APPEND LS_2010 TO ET_2010.
          ENDLOOP.
      ENDCASE.
    ENDIF.



  ENDMETHOD.


  METHOD MULTY_ORDER.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 TYPE ZGTPPT2010.
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LS_NEW_2010 TYPE ZGTPPT2010.
    DATA : LS_TEMP_2010 TYPE ZGTPPT2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_RELEASE.
    DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
    DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.
    DATA : LT_ORDER_KEY TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LV_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_CHK_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_TABIX TYPE I.
    DATA : LV_SO_VBELN TYPE VBAP-VBELN.
    DATA : LV_SO_POSNR TYPE VBAP-POSNR.
    DATA : LT_RETURN2 TYPE BAPI_ORDER_RETURN_TT.
    DATA : LV_TOP_MATNR TYPE MATNR.
    DATA : LV_CHK_QMAT.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_LOOP_IDX TYPE I.
    DATA : LV_CHK_USE.
    DATA : LV_CHK_INLENGTH TYPE ZGTPPT2010-INLENGTH.
    DATA : LV_TANDEM_REF_SEQNO TYPE I.
*    탄뎀 참조 필드 어팬드시 탄뎀 공정의 resb 업데이트 추가
    DATA : LS_DEV_TANDEM LIKE MS_MAKED_2010.
    DATA : LT_PRE_TANDEM LIKE MT_MAKED_2010.
    DATA : LV_CHK_PR.
    DATA : LV_CHK_OK.


* 복조장 생산 오더 생성.
    CLEAR LS_ORDER.
    REFRESH LT_DEV_2010.
    LOOP AT IT_2010 INTO LS_2010.
      CLEAR LV_FINDATE.
      GET_FINDATE(
        EXPORTING
          IV_ORDNR   = LS_2010-DMORD  " 오더번호
          IV_ORDTY   = LS_2010-DMORDTY" 오더유형
      IMPORTING
        EV_FINDATE = LV_FINDATE  ).               " ABAP system field: Current date of application server

      IF LS_ORDER-BASIC_START_DATE < LV_FINDATE.
        LS_ORDER-BASIC_START_DATE = LV_FINDATE.
        LS_ORDER-BASIC_END_DATE = LV_FINDATE.
      ENDIF.

      CASE LS_2010-DMORDTY.
        WHEN 'SO' OR 'SM'. " 복조장 선행이 판매오더나 SM 생산오더일시 조장으로 수량 계산
          LS_ORDER-QUANTITY = LS_ORDER-QUANTITY +
                                        ( ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-SLENGTH +
                                          LS_2010-CLENGTH + LS_2010-ADLENGTH ) * LS_2010-INFACTOR ).

*          ADD  LS_2010-INLENGTH TO LS_ORDER-QUANTITY.
        WHEN OTHERS.
          CLEAR LV_CHK_USE.
          LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV>) WHERE REORD = LS_2010-ORDNR
                                                                                              AND RELINE = LS_2010-POSNR
                                                                                              AND REORDTY = LS_2010-ORDTY.
            READ TABLE LT_DEV_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WITH KEY ORDNR = <LS_DEV>-ORDNR
                                                                                                                    POSNR = <LS_DEV>-POSNR
                                                                                                                    ORDTY = <LS_DEV>-ORDTY
                                                                                                                    BINARY SEARCH.
            IF SY-SUBRC NE 0.
              LV_CHK_USE = ABAP_TRUE.
              CLEAR LS_DEV_2010.
              MOVE-CORRESPONDING <LS_DEV> TO LS_DEV_2010.
              INSERT LS_DEV_2010 INTO  LT_DEV_2010 INDEX SY-TABIX.
            ENDIF.
          ENDLOOP.

          IF LV_CHK_USE IS INITIAL.
            READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_TEMP) WITH KEY ORDNR = LS_2010-DMORD
                                                                                          POSNR = LS_2010-DMLINE
                                                                                          ORDTY = LS_2010-DMORDTY.


            IF SY-SUBRC EQ 0.
              LOOP AT MT_NEW_2010 ASSIGNING <LS_DEV> WHERE REORD = LS_CHK_TEMP-REORD
                                                                                   AND RELINE = LS_CHK_TEMP-RELINE
                                                                                   AND REORDTY = LS_CHK_TEMP-REORDTY.
                READ TABLE LT_DEV_2010 ASSIGNING <LS_DEV_2010> WITH KEY ORDNR = <LS_DEV>-ORDNR
                                                                                               POSNR = <LS_DEV>-POSNR
                                                                                               ORDTY = <LS_DEV>-ORDTY
                                                                                               BINARY SEARCH.
                IF SY-SUBRC NE 0.
                  LV_CHK_USE = ABAP_TRUE.
                  CLEAR LS_DEV_2010.
                  MOVE-CORRESPONDING <LS_DEV> TO LS_DEV_2010.
                  INSERT LS_DEV_2010 INTO  LT_DEV_2010 INDEX SY-TABIX.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
      ENDCASE.

    ENDLOOP.

    READ TABLE IT_2010 INTO LS_DEV_2010 INDEX 1.

    IF LT_DEV_2010[] IS NOT INITIAL.
      CALC_LC_MULTY(
        EXPORTING
          IT_DEV_2010  = LT_DEV_2010
          IV_BASE_DATE = LS_ORDER-BASIC_START_DATE " ABAP system field: Current date of application server
          IV_MATNR     = LS_2010-MATNR                 " 자재 번호
        IMPORTING
          EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
          EV_TOTAL_QTY = LS_ORDER-QUANTITY                 " 오더 수량 총계
        CHANGING
          CS_2010      = LS_2010 ).                 " [GT] 오더 연결 정보

      IF LV_RETURN = 'E'.
        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.
    ENDIF.

    LS_ORDER-MATERIAL = LS_DEV_2010-MATNR.
    LS_ORDER-PLANT = MV_WERKS.

* 완제품 Factor Batch 확인
    SELECT SINGLE * FROM ZGTCVMSTVAL
       INTO @DATA(LS_CVMSTVAL)
    WHERE WERKS = @MV_WERKS
      AND MATNR = @LS_DEV_2010-MATNR.
    IF SY-SUBRC EQ 0 AND LS_CVMSTVAL-MTREF = 'FERT' AND LS_CVMSTVAL-DPCBT = 'A'.
      DATA(LV_CHK_FACTOR_BATCH) = ABAP_TRUE.
      CLEAR LV_CHK_INLENGTH.
      LOOP AT IT_2010 INTO DATA(LS_CHK_LENGTH).
        IF LV_CHK_INLENGTH = 0.
          LV_CHK_INLENGTH = LS_CHK_LENGTH-INLENGTH.
        ELSE.
          IF LV_CHK_INLENGTH NE LS_CHK_LENGTH-INLENGTH.
            RV_RETURN = 'E'.
            CLEAR MV_MESSAGE.
            CONCATENATE '공정코드' LS_2010-GONG_CD  '완제품 Factor Batch 조장차이' INTO MV_MESSAGE SEPARATED BY SPACE.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.


    ENDIF.

    SELECT SINGLE AUART FROM AUFK
      INTO @DATA(LV_AUART)
      WHERE AUFNR = @LS_DEV_2010-ORDNR.

    IF LV_AUART = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
      LS_ORDER-ORDER_TYPE = LV_AUART.
    ELSE.
      IF LV_CHK_FACTOR_BATCH = ABAP_TRUE.
        LS_ORDER-ORDER_TYPE = 'PP01'.
        IF LS_DEV_2010-DMORDTY = 'SO'.
          LS_ORDER-SALES_ORDER = LS_DEV_2010-DMORD.
          LS_ORDER-SALES_ORDER_ITEM = LS_DEV_2010-DMLINE.
        ENDIF.
      ELSE.
        LS_ORDER-ORDER_TYPE = 'PP05'.
      ENDIF.
    ENDIF.

    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

    IF LINE_EXISTS( IT_2010[ STATUS = 'R' ] ).
      LV_CHK_RELEASE = ABAP_TRUE.
    ENDIF.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_ORDER_NUMBER.

*  복조장 구성 BDC
    IF LS_RETURN-TYPE NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      CLEAR LS_ORDER_KEY.
      LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
      COLLECT LS_ORDER_KEY INTO MT_PRD_ORDERS.
      COLLECT LS_ORDER_KEY INTO LT_ORDER_KEY.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE AUFNR, POSNR
          FROM AFPO
         WHERE AUFNR = @LV_ORDER_NUMBER
          INTO @DATA(LS_AFPO).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

    ELSE.
      RV_RETURN = 'E'.
      CLEAR MV_MESSAGE.
      CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BAPI' INTO MV_MESSAGE SEPARATED BY SPACE.
      RETURN.
    ENDIF.

    IF LV_CHK_FACTOR_BATCH IS INITIAL.

* 특별절단사유 체크 완제품 복조장시
      CASE LS_DEV_2010-DMORDTY.
        WHEN 'SM' OR 'SO'.
*          WAIT UP TO '0.1' SECONDS.
*          UPDATE AUFK SET ZZCUT_REQ = ABAP_TRUE
*           WHERE AUFNR = LV_ORDER_NUMBER.
*          COMMIT WORK AND WAIT.
      ENDCASE.

      CLEAR LV_RETURN.
      LV_RETURN = CREATE_PRD_ORDER(
                          IV_AUFNR = LV_ORDER_NUMBER
                          IV_MATNR = LS_DEV_2010-MATNR                 " 자재 번호
                          IV_AUART =  LS_ORDER-ORDER_TYPE
                          IT_2010  = IT_2010 ).

      IF LV_RETURN = 'E'.
        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.

*    복조장 오더 품목 갯수 맞게 생겼는지 확인
      SELECT AUFNR, POSNR
         FROM AFPO
        WHERE AUFNR = @LV_ORDER_NUMBER
         INTO TABLE @DATA(LT_AFPO).
      IF LINES( LT_AFPO ) NE LINES( IT_2010 ).
        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.
    ENDIF.

*    탄뎀 복조장시 탄뎀 설정
    IF LS_DEV_2010-REF_TANDEM = 'T'.
* 탄뎀설정
      UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
        WHERE AUFNR = LV_ORDER_NUMBER.

*     변경전 탄뎀 세팅
      REFRESH : MT_BDCDATA, MT_MESSTAB.
      __SETTING_BDC_PARAMS.
      MS_BDCPARAMS-NOBINPT = ABAP_TRUE.
      MS_BDCPARAMS-NOBIEND = ABAP_TRUE.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_ORDER_NUMBER,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0131'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                          'RC62F-VER_SEL' 'X',
                          'RC62F-PROD_VERS' 'TD10',
                          'RC62F-NEW_ROUT' 'X',
                          'RC62F-PLAUF' SY-DATUM,
                          'RC62F-NEW_BOM' 'X',
                          'RC62F-AUFLD' SY-DATUM.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

      __BDC_TRANSACTION 'CO02'.

      CLEAR LV_CHK_OK.
      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGID = 'CO'
                                                             AND MSGNR = '100'.
        LV_CHK_OK = ABAP_TRUE.
        EXIT.
      ENDLOOP.

      IF LV_CHK_OK = ABAP_TRUE.
        COMMIT WORK AND WAIT.
        WAIT UP TO '0.3' SECONDS.
      ELSE.

        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BAPI, 탄뎀설정중' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.
    ENDIF.

    IF LV_CHK_RELEASE = ABAP_TRUE. " 기존 오더에 릴리즈건이 있다면 릴리즈 처리

      DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.

      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
      <LS_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

      CLEAR LS_RETURN.

      CALL FUNCTION 'BAPI_PRODORD_RELEASE'
        IMPORTING
          RETURN        = LS_RETURN
        TABLES
          ORDERS        = LT_ORDERS
          DETAIL_RETURN = LT_RETURN2.

      IF LS_RETURN-TYPE = 'E'.
        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  '오더 릴리즈' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.

    ENDIF.


* 복조장 구성을 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF LV_TABIX = 1.
            LV_TOP_MATNR = <LS_MAIN>-MATNR.
          ENDIF.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RETURN = 'E'.
          CLEAR MV_MESSAGE.
          CONCATENATE '공정코드' LS_2010-GONG_CD  '기존오더 삭제' INTO MV_MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


* 현재 공정 조장체인에 추가
* -- 현재 공정을 이전공정으로 등록한 후행 오더찾아 현재 공정 체인구성
    REFRESH LT_NEW_2010.

    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_2010_SET).
      ADD 1 TO LV_TABIX.
      CLEAR LS_NEW_2010.
      MOVE-CORRESPONDING LS_2010_SET TO LS_NEW_2010.
      LS_NEW_2010-ORDNR = LV_ORDER_NUMBER.
      LS_NEW_2010-POSNR = LV_TABIX + 0.
      IF LV_CHK_FACTOR_BATCH = ABAP_TRUE.
        IF LV_TABIX = 1.
          LS_NEW_2010-ORDTY = 'PRD'.
          LS_NEW_2010-MULTY_REF = ABAP_TRUE.
        ELSE.
          LS_NEW_2010-ORDTY = 'REF'.
        ENDIF.
      ELSE.
        LS_NEW_2010-ORDTY = 'PRD'.
        CASE LS_NEW_2010-DMORDTY.
          WHEN 'SM' OR 'SO'.
          WHEN OTHERS.
            IF LV_TABIX = 1.
            ELSE.
              CLEAR : LS_NEW_2010-QLENGTH.
            ENDIF.

        ENDCASE.
      ENDIF.
      CLEAR : LS_NEW_2010-REORD, LS_NEW_2010-RELINE, LS_NEW_2010-REORDTY.
      APPEND LS_NEW_2010 TO LT_NEW_2010.

      LOOP AT MT_MAKED_2010 INTO MS_MAKED_2010 WHERE REORD = LS_2010_SET-ORDNR
                                                                      AND RELINE = LS_2010_SET-POSNR
                                                                      AND REORDTY = LS_2010_SET-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING <LS_DEV> WITH KEY ORDNR = MS_MAKED_2010-ORDNR
                                                                                   POSNR = MS_MAKED_2010-POSNR
                                                                                   ORDTY = MS_MAKED_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_DEV>-REORD = LV_ORDER_NUMBER.
          <LS_DEV>-RELINE = LV_TABIX.
          <LS_DEV>-REORDTY = 'PRD'.
        ENDIF.
      ENDLOOP.

      IF ( LV_CHK_FACTOR_BATCH IS INITIAL AND LS_NEW_2010-DMORDTY = 'SO' ) OR
        ( LV_CHK_FACTOR_BATCH = ABAP_TRUE AND
          LS_NEW_2010-DMORDTY = 'SO' AND
          LS_NEW_2010-POSNR = '000001' ).
        CLEAR : LV_SO_VBELN, LV_SO_POSNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LS_NEW_2010-DMORD
          IMPORTING
            OUTPUT = LV_SO_VBELN.
        LV_SO_POSNR = LS_NEW_2010-DMLINE + 0.

        UPDATE AFPO SET KDAUF = LV_SO_VBELN
                              KDPOS = LV_SO_POSNR
                              SOBKZ = 'E'
                              KZBWS = 'A'
                      WHERE AUFNR = LS_NEW_2010-ORDNR
                          AND POSNR = LS_NEW_2010-POSNR+2(4).
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
          RV_RETURN = 'E'.
          CLEAR MV_MESSAGE.
          CONCATENATE '공정코드' LS_2010-GONG_CD  'SO 레퍼런스 업데이트' INTO MV_MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

    IF LV_AUART = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
    ELSE.
      LV_AUART = 'PP01'.
    ENDIF.

    REFRESH LT_DEV_2010.
    LT_DEV_2010 = LT_NEW_2010.

* 복조장 이전공정 세팅.
    READ TABLE MT_SEQ_ROUTING_SUB INTO MS_SEQ_ROUTING_SUB WITH KEY MATNR = LV_TOP_MATNR.
    CLEAR LV_TABIX.
    DO.
      ADD 1 TO LV_TABIX.
      IF LT_NEW_2010[] IS INITIAL.
        EXIT.
      ENDIF.
      REFRESH LT_NEW_2010.

      CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.
      IF LV_TABIX = 1.
* 1번 품목 기준 추출
        READ TABLE  LT_DEV_2010 INTO LS_DEV_2010 WITH KEY POSNR = '000001'.

        CLEAR : LV_FINDATE, LV_RSNUM.
        GET_FINDATE(
          EXPORTING
            IV_ORDNR   = LS_DEV_2010-ORDNR  " 오더번호
            IV_ORDTY   = LS_DEV_2010-ORDTY" 오더유형
        IMPORTING
          EV_FINDATE = LV_FINDATE
          EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

        CLEAR LV_LOOP_IDX.
        LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_ROUTING).

          READ TABLE LS_ROUTING-T_BOM INTO DATA(LS_CHK_BESKZ) INDEX 1.

          SELECT SINGLE *
             FROM ZGTCVMSTVAL
               INTO @DATA(LS_CVMSTVAL_CHK)
              WHERE WERKS = @MV_WERKS
                AND MATNR = @LS_CHK_BESKZ-MATNR.

          IF LS_ROUTING-BESKZ = 'EP' AND LS_CVMSTVAL_CHK-BESKZ = 'F' AND LS_CVMSTVAL_CHK-SOBSL = ''.
            CLEAR LV_CHK_PR.
            CLEAR LV_LOOP_IDX.
            LOOP AT LT_DEV_2010 INTO LS_DEV_2010.
              LOOP AT LS_ROUTING-T_BOM INTO DATA(LS_BOM) WHERE  UP_SEQNO = LS_DEV_2010-MATNR_SEQ
                                                                             AND UP_MATNR = LS_DEV_2010-MATNR.
                LV_CHK_PR = ABAP_TRUE.
                ADD 1 TO LV_LOOP_IDX.

                APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).

                <LS_NEW_2010>-GRPNR = MV_GRPNR.
                <LS_NEW_2010>-DMORD = LS_DEV_2010-ORDNR.
                <LS_NEW_2010>-DMLINE = LS_DEV_2010-POSNR.
                <LS_NEW_2010>-DMORDTY = LS_DEV_2010-ORDTY.
                <LS_NEW_2010>-MATNR = LS_BOM-MATNR.
                <LS_NEW_2010>-MATNR_SEQ = LS_BOM-SEQNO.
                <LS_NEW_2010>-GONG_SEQ = LS_ROUTING-GONG_SEQ.
                <LS_NEW_2010>-GONG_CD = LS_ROUTING-CHART.

                CAL_LC(
                  EXPORTING
                    IV_DEV_2010        = LS_DEV_2010                 " [GT] 오더 연결 정보
                    IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
                  IMPORTING
                    EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                    EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
                  CHANGING
                    CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                ).

                IF LV_RETURN = 'E'.
                  RV_RETURN = 'E'.
                  CLEAR MV_MESSAGE.
                  CONCATENATE '공정코드' LS_2010-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
                  RETURN.
                ENDIF.

                IF LV_LOOP_IDX = 1.
                  CLEAR LS_TEMP_2010.
                  MOVE <LS_NEW_2010> TO LS_TEMP_2010.

                  CALC_LC_MULTY(
                    EXPORTING
                      IT_DEV_2010  = LT_DEV_2010
                      IV_BASE_DATE = LV_FINDATE " ABAP system field: Current date of application server
                      IV_MATNR     = LS_TEMP_2010-MATNR                 " 자재 번호
                    IMPORTING
                      EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
                      EV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                    CHANGING
                      CS_2010      = LS_TEMP_2010 ).                 " [GT] 오더 연결 정보

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
                  CLEAR LV_CHK_QMAT.
                  IF LS_TEMP_2010-QLENGTH > 0.
                    LV_CHK_QMAT = ABAP_TRUE.
                  ENDIF.

                  CLEAR LV_EXCLUDING_LENGTH.
                  IF LV_CHK_QMAT = ABAP_TRUE.
                    SELECT SINGLE MATNR FROM QMAT
                      INTO @DATA(LV_CHK_MATNR)
                     WHERE MATNR = @LS_TEMP_2010-MATNR
                       AND WERKS = @MV_WERKS
                       AND ART = '04'
                       AND AKTIV = 'X'.
                    IF SY-SUBRC EQ 0.
                      LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - LS_TEMP_2010-QLENGTH.
                    ELSE.
                      LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
                    ENDIF.
                  ELSE.
                    LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
                  ENDIF.

                  IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
                    LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
                  ENDIF.
                ELSE.
                  CLEAR : <LS_NEW_2010>-CLENGTH, <LS_NEW_2010>-CLENGTH,
                          <LS_NEW_2010>-SLENGTH, <LS_NEW_2010>-ELENGTH.

                ENDIF.

              ENDLOOP.
            ENDLOOP.

            IF LV_CHK_PR = ABAP_TRUE.
              LV_RETURN = CREATE_PR_ORDER_MULTY(
                            EXPORTING
                              IV_FINDATE = LV_FINDATE                 " ABAP system field: Current date of application server
                            CHANGING
                              CT_2010    = LT_NEW_2010 ).

              IF LV_RETURN = 'E'.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  '구매요청 생성 오류' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.

              LOOP AT LT_NEW_2010 INTO LS_NEW_2010.
                READ TABLE LT_DEV_2010 ASSIGNING FIELD-SYMBOL(<LS_SET_DMORD>) WITH KEY  ORDNR = LS_NEW_2010-DMORD
                                                                                                                        POSNR = LS_NEW_2010-DMLINE
                                                                                                                        ORDTY = LS_NEW_2010-DMORDTY.
                IF SY-SUBRC EQ 0.
                  <LS_SET_DMORD>-REORD = LS_NEW_2010-ORDNR.
                  <LS_SET_DMORD>-RELINE = LS_NEW_2010-POSNR.
                  <LS_SET_DMORD>-REORDTY = LS_NEW_2010-ORDTY.
                ENDIF.
              ENDLOOP.
            ENDIF.


          ELSE.

            LOOP AT LS_ROUTING-T_BOM INTO LS_BOM WHERE  UP_SEQNO = LS_DEV_2010-MATNR_SEQ
                                                                           AND UP_MATNR = LS_DEV_2010-MATNR.

              ADD 1 TO LV_LOOP_IDX.

              APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.

              <LS_NEW_2010>-GRPNR = MV_GRPNR.
              <LS_NEW_2010>-DMORD = LS_DEV_2010-ORDNR.
              <LS_NEW_2010>-DMLINE = LS_DEV_2010-POSNR.
              <LS_NEW_2010>-DMORDTY = LS_DEV_2010-ORDTY.
              <LS_NEW_2010>-MATNR = LS_BOM-MATNR.
              <LS_NEW_2010>-MATNR_SEQ = LS_BOM-SEQNO.
              <LS_NEW_2010>-GONG_SEQ = LS_ROUTING-GONG_SEQ.
              <LS_NEW_2010>-GONG_CD = LS_ROUTING-CHART.
* 이후공정이 탄뎀 일시
              IF  LS_DEV_2010-REF_TANDEM = 'T'.
                CLEAR LV_TANDEM_REF_SEQNO.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_TANDEM_SEQ) WITH KEY GONG_SEQ = LS_DEV_2010-GONG_SEQ.
                IF SY-SUBRC EQ 0.
                  LV_TANDEM_REF_SEQNO = LS_TANDEM_SEQ-SEQNO - 1.
* 탄뎀공정의 직전 공정만 ref_tandem = 'X' 세팅
                  IF LS_ROUTING-SEQNO = LV_TANDEM_REF_SEQNO.
                    <LS_NEW_2010>-REF_TANDEM = ABAP_TRUE.
                  ENDIF.
                ENDIF.
              ENDIF.

              CALC_LC_MULTY(
                EXPORTING
                  IT_DEV_2010  = LT_DEV_2010
                  IV_BASE_DATE = LV_FINDATE " ABAP system field: Current date of application server
                  IV_MATNR     = <LS_NEW_2010>-MATNR                 " 자재 번호
                IMPORTING
                  EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
                  EV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                CHANGING
                  CS_2010      = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

              IF LV_RETURN = 'E'.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.

* 생산오더 생성
              LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                            EXPORTING
                              IV_AUART       = LV_AUART                 " 판매 문서 유형
                              IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                              IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                              IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                            CHANGING
                              CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                          ).
              IF LV_RETURN = 'E'.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
              CLEAR LV_CHK_QMAT.
              IF <LS_NEW_2010>-QLENGTH > 0.
                LV_CHK_QMAT = ABAP_TRUE.
              ENDIF.

              CLEAR LV_EXCLUDING_LENGTH.
              IF LV_CHK_QMAT = ABAP_TRUE.
                SELECT SINGLE MATNR FROM QMAT
                  INTO @LV_CHK_MATNR
                 WHERE MATNR = @<LS_NEW_2010>-MATNR
                   AND WERKS = @MV_WERKS
                   AND ART = '04'
                   AND AKTIV = 'X'.
                IF SY-SUBRC EQ 0.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - <LS_NEW_2010>-QLENGTH.
                ELSE.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
                ENDIF.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
              ENDIF.

              IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
                LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
              ENDIF.

              IF LV_LOOP_IDX = 1.
                LOOP AT LT_DEV_2010 ASSIGNING <LS_DEV_2010>.
                  <LS_DEV_2010>-REORD = <LS_NEW_2010>-ORDNR.
                  <LS_DEV_2010>-RELINE = <LS_NEW_2010>-POSNR.
                  <LS_DEV_2010>-REORDTY = <LS_NEW_2010>-ORDTY.
                ENDLOOP.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDLOOP.

        IF LT_NEW_2010[] IS NOT INITIAL AND LS_DEV_2010-REF_TANDEM NE 'T'.

* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
          REFRESH LT_RESB.
          SELECT A~*
            FROM RESB AS A
            INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
            INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
            INNER JOIN ZGTCVMSTVAL AS D
                            ON D~MATNR = C~MATNR
                           AND D~WERKS = C~WERKS
            INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
            WHERE B~MTART = 'MCHF'
              AND C~WERKS = @MV_WERKS
              AND C~BESKZ IN ('E', 'X')
              AND D~PDCAPROCCODE NE 'BWD'
              AND A~RSNUM = @LV_RSNUM.

          LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

            <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
                I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
                I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
                I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*               I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
              IMPORTING
                E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
              EXCEPTIONS
                ERROR_IN_APPLICATION = 1
                ERROR                = 2
                OTHERS               = 3.

          ENDLOOP.

          LOOP AT LT_RESB INTO DATA(LS_RESB).

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
        ENDIF.

      ELSE.

        LOOP AT LT_DEV_2010 ASSIGNING <LS_DEV_2010>.
          CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.
          CLEAR : LV_FINDATE, LV_RSNUM.
          GET_FINDATE(
            EXPORTING
              IV_ORDNR   = <LS_DEV_2010>-ORDNR  " 오더번호
              IV_ORDTY   = <LS_DEV_2010>-ORDTY" 오더유형
          IMPORTING
            EV_FINDATE = LV_FINDATE
            EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

          CLEAR LV_LOOP_IDX.
          LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO LS_ROUTING.
            LOOP AT LS_ROUTING-T_BOM INTO LS_BOM WHERE  UP_SEQNO = <LS_DEV_2010>-MATNR_SEQ
                                                                           AND UP_MATNR = <LS_DEV_2010>-MATNR.
              ADD 1 TO LV_LOOP_IDX.
              APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.

              <LS_NEW_2010>-GRPNR = MV_GRPNR.
              <LS_NEW_2010>-DMORD = <LS_DEV_2010>-ORDNR.
              <LS_NEW_2010>-DMLINE = <LS_DEV_2010>-POSNR.
              <LS_NEW_2010>-DMORDTY = <LS_DEV_2010>-ORDTY.
              <LS_NEW_2010>-MATNR = LS_BOM-MATNR.
              <LS_NEW_2010>-MATNR_SEQ = LS_BOM-SEQNO.
              <LS_NEW_2010>-GONG_SEQ = LS_ROUTING-GONG_SEQ.
              <LS_NEW_2010>-GONG_CD = LS_ROUTING-CHART.

              CAL_LC(
                EXPORTING
                  IV_DEV_2010        = <LS_DEV_2010>                 " [GT] 오더 연결 정보
                  IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
                IMPORTING
                  EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                  EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
                CHANGING
                  CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
              ).

              IF LV_RETURN = 'E'.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.

              SELECT SINGLE * FROM ZGTCVMSTVAL
                INTO @DATA(LS_CVMSTVAL_RE)
               WHERE WERKS = @MV_WERKS
                 AND MATNR = @<LS_NEW_2010>-MATNR.

              IF LS_ROUTING-BESKZ = 'EP' AND LS_CVMSTVAL_RE-BESKZ = 'F' AND LS_CVMSTVAL_RE-SOBSL = ''. " 외주공정일시 구매요청생성
                LV_RETURN = CREATE_PR_ORDER(
                              EXPORTING
                                IV_FINDATE = LV_FINDATE " ABAP system field: Current date of application server
                              CHANGING
                                CS_2010    = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

                IF LV_RETURN = ABAP_TRUE.
                  RV_RETURN = 'E'.
                  CLEAR MV_MESSAGE.
                  CONCATENATE '공정코드' LS_2010-GONG_CD  '구매요청 생성오류' INTO MV_MESSAGE SEPARATED BY SPACE.
                  RETURN.
                ENDIF.

              ELSE.
* 생산오더 생성
                LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                              EXPORTING
                                IV_AUART       = LV_AUART                 " 판매 문서 유형
                                IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                                IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                                IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                              CHANGING
                                CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                            ).
                IF LV_RETURN = 'E'.
                  RV_RETURN = 'E'.
                  CLEAR MV_MESSAGE.
                  CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
                  RETURN.
                ENDIF.
              ENDIF.

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
              CLEAR LV_CHK_QMAT.
              IF <LS_NEW_2010>-QLENGTH > 0.
                LV_CHK_QMAT = ABAP_TRUE.
              ENDIF.

              CLEAR LV_EXCLUDING_LENGTH.
              IF LV_CHK_QMAT = ABAP_TRUE.
                CLEAR LV_CHK_MATNR.
                SELECT SINGLE MATNR FROM QMAT
                  INTO @LV_CHK_MATNR
                 WHERE MATNR = @<LS_NEW_2010>-MATNR
                   AND WERKS = @MV_WERKS
                   AND ART = '04'
                   AND AKTIV = 'X'.
                IF SY-SUBRC EQ 0.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - <LS_NEW_2010>-QLENGTH.
                ELSE.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
                ENDIF.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
              ENDIF.

              IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
                LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
              ENDIF.

              IF LV_LOOP_IDX = 1.
                <LS_DEV_2010>-REORD = <LS_NEW_2010>-ORDNR.
                <LS_DEV_2010>-RELINE = <LS_NEW_2010>-POSNR.
                <LS_DEV_2010>-REORDTY = <LS_NEW_2010>-ORDTY.
              ENDIF.

            ENDLOOP.
          ENDLOOP.

          IF LT_NEW_2010[] IS NOT INITIAL.
* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
            REFRESH LT_RESB.
            SELECT A~*
              FROM RESB AS A
              INNER JOIN MARA AS B
                              ON B~MATNR = A~MATNR
              INNER JOIN MARC AS C
                              ON C~MATNR = A~MATNR
              INNER JOIN ZGTCVMSTVAL AS D
                              ON D~MATNR = C~MATNR
                             AND D~WERKS = C~WERKS
              INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
              WHERE B~MTART = 'MCHF'
                AND C~WERKS = @MV_WERKS
                AND C~BESKZ IN ('E', 'X')
                AND D~PDCAPROCCODE NE 'BWD'
                AND A~RSNUM = @LV_RSNUM.

            LOOP AT LT_RESB ASSIGNING <LS_RESB>.

              <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
                  I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
                  I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
                  I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*                 I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
                IMPORTING
                  E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
                EXCEPTIONS
                  ERROR_IN_APPLICATION = 1
                  ERROR                = 2
                  OTHERS               = 3.

            ENDLOOP.

            LOOP AT LT_RESB INTO LS_RESB.

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

          ENDIF.

        ENDLOOP.

      ENDIF.

*     탄뎀 참조공정의 resb 변경시 탄뎀 설정된 공정의 resb 변경
      REFRESH LT_PRE_TANDEM.
      CLEAR LS_DEV_TANDEM.

      READ TABLE LT_DEV_2010 INTO DATA(LS_CHK_REF_TEANDEM) WITH KEY REF_TANDEM = 'X'.
      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LT_DEV_2010 TO LT_PRE_TANDEM.
        READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_DEV_2010) WITH KEY ORDNR = LS_CHK_REF_TEANDEM-DMORD
                                                                                           POSNR = LS_CHK_REF_TEANDEM-DMLINE
                                                                                           ORDTY = LS_CHK_REF_TEANDEM-DMORDTY
                                                                                            REF_TANDEM = 'T'.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_CHK_DEV_2010 TO LS_DEV_TANDEM.

* 탄뎀공정의 RESB반영
          UPDATE_TANDEM_RESB(
            IS_CURRENT   = LS_DEV_TANDEM
            IT_CHAIN_PRE = LT_PRE_TANDEM
            IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소
        ENDIF.

      ENDIF.

      APPEND LINES OF LT_DEV_2010 TO MT_NEW_2010.
      REFRESH LT_DEV_2010.
      LT_DEV_2010 = LT_NEW_2010.

    ENDDO.


  ENDMETHOD.


  METHOD PROCESS_SEPERATE.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_TABIX TYPE I.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LV_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_CHK_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_TMP LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_SORT LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_CURRENT LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 TYPE ZGTPPT2010.
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LS_NEW_2010 TYPE ZGTPPT2010.
    DATA : LV_SO_VBELN TYPE VBAP-VBELN.
    DATA : LV_SO_POSNR TYPE VBAP-POSNR.
    DATA : LT_RETURN2 TYPE BAPI_ORDER_RETURN_TT.
    DATA : LV_CHK_RELEASE.
    DATA : LV_TOP_MATNR TYPE MATNR.
    DATA : LV_CHK_QMAT.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_LOOP_IDX TYPE I.
    DATA : LV_TANDEM_REF_SEQNO TYPE I.
*    탄뎀 참조 필드 어팬드시 탄뎀 공정의 resb 업데이트 추가
    DATA : LS_DEV_TANDEM LIKE MS_MAKED_2010.
    DATA : LT_PRE_TANDEM LIKE MT_MAKED_2010.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

* 복조장 분리를 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      IF LS_CHK_2010-ORDTY = 'REF'.
        DATA(LV_CHK_FACTOR_BATCH) = ABAP_TRUE.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF LV_TABIX = 1.
            LV_TOP_MATNR = <LS_MAIN>-MATNR.
          ENDIF.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.

          APPEND INITIAL LINE TO RT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
          <LS_RESULT>-TYPE = 'E'.
          CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '개별오더 전환중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


    CLEAR MV_SUCC_CNT.
* 시작전 세팅 사항. 오더타입, 릴리즈 여부(릴리즈시 이전공정 릴리즈처리)
    READ TABLE IT_2010 INTO LS_DEV_2010 INDEX 1.

    SELECT SINGLE AUART FROM AUFK
      INTO @DATA(LV_AUART)
      WHERE AUFNR = @LS_DEV_2010-ORDNR.

    IF LV_AUART = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
    ELSE.
      LV_AUART = 'PP01'.
    ENDIF.

    IF LINE_EXISTS( IT_2010[ STATUS = 'R' ] ).
      LV_CHK_RELEASE = ABAP_TRUE.
    ENDIF.

    LT_NEW_2010 = IT_2010.

* 복조장 이전공정 세팅.
    READ TABLE MT_SEQ_ROUTING_SUB INTO MS_SEQ_ROUTING_SUB WITH KEY MATNR = LV_TOP_MATNR.
    CLEAR LV_TABIX.
    DO.
      ADD 1 TO LV_TABIX.
      IF LT_NEW_2010[] IS INITIAL.
        EXIT.
      ENDIF.
      REFRESH LT_NEW_2010.

      CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.
      IF LV_TABIX = 1.


        REFRESH LT_DEV_2010_TMP.
        REFRESH LT_DEV_2010.
        LOOP AT IT_2010 INTO DATA(LS_TEMP_PRE).
          CASE LS_TEMP_PRE-DMORDTY.
            WHEN 'SO' OR 'SM'.
            WHEN OTHERS.
              LOOP AT MT_MAKED_2010 INTO MS_MAKED_2010 WHERE ORDNR = LS_TEMP_PRE-DMORD
                                                                              AND POSNR = LS_TEMP_PRE-DMLINE
                                                                              AND ORDTY = LS_TEMP_PRE-DMORDTY.

                LOOP AT MT_MAKED_2010 INTO DATA(LS_DATA_TEMP) WHERE REORD = MS_MAKED_2010-REORD
                                                                                          AND RELINE = MS_MAKED_2010-RELINE
                                                                                          AND REORDTY = MS_MAKED_2010-REORDTY.

                  APPEND INITIAL LINE TO LT_DEV_2010_TMP ASSIGNING FIELD-SYMBOL(<LS_TEMP_DEV>).
                  MOVE-CORRESPONDING LS_DATA_TEMP TO <LS_TEMP_DEV>.
                ENDLOOP.

              ENDLOOP.
          ENDCASE.
        ENDLOOP.

        IF LT_DEV_2010_TMP IS NOT INITIAL AND LT_DEV_2010 IS INITIAL.
          SORT LT_DEV_2010_TMP BY ORDNR POSNR ORDTY.
          DELETE ADJACENT DUPLICATES FROM LT_DEV_2010_TMP COMPARING ORDNR POSNR ORDTY.

          LT_DEV_2010_SORT = LT_DEV_2010_TMP.
          SORT LT_DEV_2010_SORT BY ORDNR ORDTY.
          DELETE ADJACENT DUPLICATES FROM LT_DEV_2010_SORT COMPARING ORDNR ORDTY.
        ENDIF.


* 최초 분리작업
        LT_DEV_2010 = IT_2010.

*      복조장 상위 오더를 참조하여 해당 라인 구성
        LOOP AT LT_DEV_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>).

          CLEAR : LV_FINDATE, LV_RSNUM.
          GET_FINDATE(
            EXPORTING
              IV_ORDNR   = <LS_DEV_2010>-DMORD  " 오더번호
              IV_ORDTY   = <LS_DEV_2010>-DMORDTY" 오더유형
          IMPORTING
            EV_FINDATE = LV_FINDATE ).

          CASE <LS_DEV_2010>-DMORDTY.
            WHEN 'SO' OR 'SM'. " 최초 생성할 오더가 판매오더거나 sm생산오더일경우
*              LV_TOTAL_QTY = <LS_DEV_2010>-INFACTOR * <LS_DEV_2010>-INLENGTH.

              LV_TOTAL_QTY = ( <LS_DEV_2010>-INLENGTH + <LS_DEV_2010>-QLENGTH + <LS_DEV_2010>-SLENGTH +
                                        <LS_DEV_2010>-CLENGTH + <LS_DEV_2010>-ADLENGTH ) * <LS_DEV_2010>-INFACTOR.

              APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).
              MOVE-CORRESPONDING <LS_DEV_2010> TO <LS_NEW_2010>.

* * 완제품 Factor Batch 복조장대상
              IF LV_CHK_FACTOR_BATCH = ABAP_TRUE.
                IF <LS_NEW_2010>-POSNR = '000001'.
                  CLEAR <LS_NEW_2010>-MULTY_REF.
                ELSE.
                  <LS_NEW_2010>-ORDTY = 'PRD'.
                ENDIF.
              ENDIF.


* 생산오더 생성
              LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                            EXPORTING
                              IV_AUART       = LV_AUART                 " 판매 문서 유형
                              IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                              IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                              IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                            CHANGING
                              CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                          ).
              IF LV_RETURN = 'E'.
                APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                <LS_RESULT>-TYPE = 'E'.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                EXIT.
              ENDIF.

              IF <LS_NEW_2010>-DMORDTY = 'SO'.
                CLEAR : LV_SO_VBELN, LV_SO_POSNR.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    INPUT  = <LS_NEW_2010>-DMORD
                  IMPORTING
                    OUTPUT = LV_SO_VBELN.
                LV_SO_POSNR = <LS_NEW_2010>-DMLINE + 0.

                UPDATE AFPO SET KDAUF = LV_SO_VBELN
                                      KDPOS = LV_SO_POSNR
                                      SOBKZ = 'E'
                                      KZBWS = 'A'
                              WHERE AUFNR = <LS_NEW_2010>-ORDNR
                                  AND POSNR = <LS_NEW_2010>-POSNR+2(4).
                IF SY-SUBRC EQ 0.
                  COMMIT WORK AND WAIT.
                ELSE.
                  ROLLBACK WORK.

                  LV_RETURN = 'E'.
                  APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                  <LS_RESULT>-TYPE = 'E'.
                  READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                  CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                  EXIT.
                ENDIF.
              ENDIF.

            WHEN OTHERS.

*  최초생성할 오더가 조장체인 중간 단계일 경우
*   이후 공정별로 해당 자재 생산(이후 공정이 복조장일시, 단일조장일시 고려)
              REFRESH LT_DEV_2010_CURRENT.
              LOOP AT LT_DEV_2010_TMP INTO LS_DATA_TEMP WHERE REORD = <LS_DEV_2010>-ORDNR
                                                                                       AND RELINE = <LS_DEV_2010>-POSNR
                                                                                       AND REORDTY = <LS_DEV_2010>-ORDTY.
                APPEND LS_DATA_TEMP TO LT_DEV_2010_CURRENT.
              ENDLOOP.

              IF LT_DEV_2010_CURRENT[] IS INITIAL.
                LOOP AT LT_DEV_2010_TMP INTO LS_DATA_TEMP WHERE ORDNR = <LS_DEV_2010>-DMORD
                                                                                       AND POSNR = <LS_DEV_2010>-DMLINE
                                                                                       AND ORDTY = <LS_DEV_2010>-DMORDTY.
                  APPEND LS_DATA_TEMP TO LT_DEV_2010_CURRENT.
                ENDLOOP.
              ENDIF.

              SORT LT_DEV_2010_CURRENT BY POSNR.

* 중간단계시 이후 공정들을 찾아 각각의 이전 공정들 생성
              IF LINES( LT_DEV_2010_CURRENT ) > 1. " 복조장 구성

                READ TABLE LT_DEV_2010_CURRENT INTO LS_DEV_2010 INDEX 1.


                APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.
                <LS_NEW_2010>-GRPNR = MV_GRPNR.
                <LS_NEW_2010>-DMORD = LS_DEV_2010-ORDNR.
                <LS_NEW_2010>-DMLINE = LS_DEV_2010-POSNR.
                <LS_NEW_2010>-DMORDTY = LS_DEV_2010-ORDTY.
                <LS_NEW_2010>-MATNR = <LS_DEV_2010>-MATNR.
                <LS_NEW_2010>-MATNR_SEQ = <LS_DEV_2010>-MATNR_SEQ.
                <LS_NEW_2010>-GONG_SEQ = <LS_DEV_2010>-GONG_SEQ.
                <LS_NEW_2010>-GONG_CD = <LS_DEV_2010>-GONG_CD.

                CALC_LC_MULTY(
                  EXPORTING
                    IT_DEV_2010  = LT_DEV_2010_CURRENT
                    IV_BASE_DATE = LV_FINDATE " ABAP system field: Current date of application server
                    IV_MATNR     = <LS_NEW_2010>-MATNR                 " 자재 번호
                  IMPORTING
                    EV_RESULT    =  LV_RETURN                " 길이 1의 문자 필드
                    EV_TOTAL_QTY = LV_TOTAL_QTY                 " 오더 수량 총계
                  CHANGING
                    CS_2010      = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

                IF LV_RETURN = 'E'.
                  APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                  <LS_RESULT>-TYPE = 'E'.
                  READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                  CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                  EXIT.
                ENDIF.

* 생산오더 생성
                LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                              EXPORTING
                                IV_AUART       = LV_AUART                 " 판매 문서 유형
                                IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                                IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                                IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                              CHANGING
                                CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                            ).
                IF LV_RETURN = 'E'.
                  APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                  <LS_RESULT>-TYPE = 'E'.
                  READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                  CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                  EXIT.
                ENDIF.

* 최초 라인의 체인구성
                IF LS_DEV_2010-REORD = <LS_DEV_2010>-ORDNR AND
                  LS_DEV_2010-RELINE = <LS_DEV_2010>-POSNR AND
                  LS_DEV_2010-REORDTY = <LS_DEV_2010>-ORDTY.

                  LOOP AT LT_DEV_2010_CURRENT INTO DATA(LS_TEMP_DATA).
                    READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010_UP>) WITH KEY ORDNR = LS_TEMP_DATA-ORDNR
                                                                                                     POSNR = LS_TEMP_DATA-POSNR
                                                                                                     ORDTY = LS_TEMP_DATA-ORDTY.
                    <LS_NEW_2010_UP>-REORD = <LS_NEW_2010>-ORDNR.
                    <LS_NEW_2010_UP>-RELINE = <LS_NEW_2010>-POSNR.
                    <LS_NEW_2010_UP>-REORDTY = <LS_NEW_2010>-ORDTY.
                  ENDLOOP.
                ENDIF.

              ELSE.
                READ TABLE LT_DEV_2010_CURRENT INTO LS_DEV_2010 INDEX 1.


                APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.

                <LS_NEW_2010>-GRPNR = MV_GRPNR.
                <LS_NEW_2010>-DMORD = LS_DEV_2010-ORDNR.
                <LS_NEW_2010>-DMLINE = LS_DEV_2010-POSNR.
                <LS_NEW_2010>-DMORDTY = LS_DEV_2010-ORDTY.
                <LS_NEW_2010>-MATNR = <LS_DEV_2010>-MATNR.
                <LS_NEW_2010>-MATNR_SEQ = <LS_DEV_2010>-MATNR_SEQ.
                <LS_NEW_2010>-GONG_SEQ = <LS_DEV_2010>-GONG_SEQ.
                <LS_NEW_2010>-GONG_CD = <LS_DEV_2010>-GONG_CD.

                CAL_LC(
                  EXPORTING
                    IV_DEV_2010        = LS_DEV_2010                 " [GT] 오더 연결 정보
                    IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
                  IMPORTING
                    EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                    EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
                  CHANGING
                    CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                ).

                IF LV_RETURN = 'E'.
                  APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                  <LS_RESULT>-TYPE = 'E'.
                  READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                  CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                  EXIT.
                ENDIF.

* 생산오더 생성
                LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                              EXPORTING
                                IV_AUART       = LV_AUART                 " 판매 문서 유형
                                IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                                IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                                IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                              CHANGING
                                CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                            ).
                IF LV_RETURN = 'E'.
                  APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                  <LS_RESULT>-TYPE = 'E'.
                  READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                  CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                  EXIT.
                ENDIF.

              ENDIF.

* 최초 라인의 체인구성
              IF LS_DEV_2010-REORD = <LS_DEV_2010>-ORDNR AND
                LS_DEV_2010-RELINE = <LS_DEV_2010>-POSNR AND
                LS_DEV_2010-REORDTY = <LS_DEV_2010>-ORDTY.

                LOOP AT LT_DEV_2010_CURRENT INTO LS_TEMP_DATA.
                  READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010_UP> WITH KEY ORDNR = LS_TEMP_DATA-ORDNR
                                                                                                   POSNR = LS_TEMP_DATA-POSNR
                                                                                                   ORDTY = LS_TEMP_DATA-ORDTY.
                  <LS_NEW_2010_UP>-REORD = <LS_NEW_2010>-ORDNR.
                  <LS_NEW_2010_UP>-RELINE = <LS_NEW_2010>-POSNR.
                  <LS_NEW_2010_UP>-REORDTY = <LS_NEW_2010>-ORDTY.
                ENDLOOP.
              ENDIF.

          ENDCASE.
        ENDLOOP.
      ELSE.

        LOOP AT LT_DEV_2010 ASSIGNING <LS_DEV_2010>.
          CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.
          CLEAR : LV_FINDATE, LV_RSNUM.
          GET_FINDATE(
            EXPORTING
              IV_ORDNR   = <LS_DEV_2010>-ORDNR  " 오더번호
              IV_ORDTY   = <LS_DEV_2010>-ORDTY" 오더유형
          IMPORTING
            EV_FINDATE = LV_FINDATE
            EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

          CLEAR LV_LOOP_IDX.
          LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_ROUTING).
            LOOP AT LS_ROUTING-T_BOM INTO DATA(LS_BOM) WHERE  UP_SEQNO = <LS_DEV_2010>-MATNR_SEQ
                                                                           AND UP_MATNR = <LS_DEV_2010>-MATNR.
              ADD 1 TO LV_LOOP_IDX.
              APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.

              <LS_NEW_2010>-GRPNR = MV_GRPNR.
              <LS_NEW_2010>-DMORD = <LS_DEV_2010>-ORDNR.
              <LS_NEW_2010>-DMLINE = <LS_DEV_2010>-POSNR.
              <LS_NEW_2010>-DMORDTY = <LS_DEV_2010>-ORDTY.
              <LS_NEW_2010>-MATNR = LS_BOM-MATNR.
              <LS_NEW_2010>-MATNR_SEQ = LS_BOM-SEQNO.
              <LS_NEW_2010>-GONG_SEQ = LS_ROUTING-GONG_SEQ.
              <LS_NEW_2010>-GONG_CD = LS_ROUTING-CHART.

* 이후공정이 탄뎀 일시
              IF  <LS_DEV_2010>-REF_TANDEM = 'T'.
                CLEAR LV_TANDEM_REF_SEQNO.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_TANDEM_SEQ) WITH KEY GONG_SEQ = <LS_DEV_2010>-GONG_SEQ.
                IF SY-SUBRC EQ 0.
                  LV_TANDEM_REF_SEQNO = LS_TANDEM_SEQ-SEQNO - 1.
* 탄뎀공정의 직전 공정만 ref_tandem = 'X' 세팅
                  IF LS_ROUTING-SEQNO = LV_TANDEM_REF_SEQNO.
                    <LS_NEW_2010>-REF_TANDEM = ABAP_TRUE.
                  ENDIF.
                ENDIF.
              ENDIF.

              CAL_LC(
                EXPORTING
                  IV_DEV_2010        = <LS_DEV_2010>                 " [GT] 오더 연결 정보
                  IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
                IMPORTING
                  EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                  EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
                CHANGING
                  CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
              ).

              IF LV_RETURN = 'E'.
                APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                <LS_RESULT>-TYPE = 'E'.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                EXIT.
              ENDIF.

              CASE LS_ROUTING-BESKZ.
                WHEN 'EP'.

                  LV_RETURN = CREATE_PR_ORDER(
                                EXPORTING
                                  IV_FINDATE = LV_FINDATE " ABAP system field: Current date of application server
                                CHANGING
                                  CS_2010    = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

                WHEN OTHERS.
* 생산오더 생성
                  LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                                EXPORTING
                                  IV_AUART       = LV_AUART                 " 판매 문서 유형
                                  IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                                  IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                                  IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                                CHANGING
                                  CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                              ).
              ENDCASE.
              IF LV_RETURN = 'E'.
                APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
                <LS_RESULT>-TYPE = 'E'.
                READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
                CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '생산오더 생성중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
                EXIT.
              ENDIF.

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
              CLEAR LV_CHK_QMAT.
              IF <LS_NEW_2010>-QLENGTH > 0.
                LV_CHK_QMAT = ABAP_TRUE.
              ENDIF.

              CLEAR LV_EXCLUDING_LENGTH.
              IF LV_CHK_QMAT = ABAP_TRUE.
                SELECT SINGLE MATNR FROM QMAT
                  INTO @DATA(LV_CHK_MATNR)
                 WHERE MATNR = @<LS_NEW_2010>-MATNR
                   AND WERKS = @MV_WERKS
                   AND ART = '04'
                   AND AKTIV = 'X'.
                IF SY-SUBRC EQ 0.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - <LS_NEW_2010>-QLENGTH.
                ELSE.
                  LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
                ENDIF.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
              ENDIF.

              IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
                LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
              ENDIF.

              IF LV_LOOP_IDX = 1.
                <LS_DEV_2010>-REORD = <LS_NEW_2010>-ORDNR.
                <LS_DEV_2010>-RELINE = <LS_NEW_2010>-POSNR.
                <LS_DEV_2010>-REORDTY = <LS_NEW_2010>-ORDTY.
              ENDIF.

            ENDLOOP.
          ENDLOOP.

          IF LT_NEW_2010[] IS NOT INITIAL AND <LS_DEV_2010>-REF_TANDEM NE 'T'.
* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
            REFRESH LT_RESB.
            SELECT A~*
              FROM RESB AS A
              INNER JOIN MARA AS B
                              ON B~MATNR = A~MATNR
              INNER JOIN MARC AS C
                              ON C~MATNR = A~MATNR
              INNER JOIN ZGTCVMSTVAL AS D
                              ON D~MATNR = C~MATNR
                             AND D~WERKS = C~WERKS
              INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
              WHERE B~MTART = 'MCHF'
                AND C~WERKS = @MV_WERKS
                AND C~BESKZ IN ('E', 'X')
                AND D~PDCAPROCCODE NE 'BWD'
                AND A~RSNUM = @LV_RSNUM.

            LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

              <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
                  I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
                  I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
                  I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*                 I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
                IMPORTING
                  E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
                EXCEPTIONS
                  ERROR_IN_APPLICATION = 1
                  ERROR                = 2
                  OTHERS               = 3.

            ENDLOOP.

            LOOP AT LT_RESB INTO DATA(LS_RESB).

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
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF LV_RETURN = 'E'. " 에러시 종료 처리후 메시지, 롤백처리
        EXIT.
      ENDIF.

*     탄뎀 참조공정의 resb 변경시 탄뎀 설정된 공정의 resb 변경
      REFRESH LT_PRE_TANDEM.
      CLEAR LS_DEV_TANDEM.

      READ TABLE LT_DEV_2010 INTO DATA(LS_CHK_REF_TEANDEM) WITH KEY REF_TANDEM = 'X'.
      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LT_DEV_2010 TO LT_PRE_TANDEM.
        READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_DEV_2010) WITH KEY ORDNR = LS_CHK_REF_TEANDEM-DMORD
                                                                                           POSNR = LS_CHK_REF_TEANDEM-DMLINE
                                                                                           ORDTY = LS_CHK_REF_TEANDEM-DMORDTY
                                                                                            REF_TANDEM = 'T'.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_CHK_DEV_2010 TO LS_DEV_TANDEM.

* 탄뎀공정의 RESB반영
          UPDATE_TANDEM_RESB(
            IS_CURRENT   = LS_DEV_TANDEM
            IT_CHAIN_PRE = LT_PRE_TANDEM
            IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소
        ENDIF.

      ENDIF.


      IF LV_TABIX NE 1.
        APPEND LINES OF LT_DEV_2010 TO MT_NEW_2010.
      ENDIF.
      REFRESH LT_DEV_2010.
      LT_DEV_2010 = LT_NEW_2010.

    ENDDO.


* 에러발생시 생성된 오더 삭제후 종료
    IF LV_RETURN = 'E'.
      DATA : LS_RETURN2 TYPE BAPIRET2.
      DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

      IF MT_PRD_ORDERS[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
          IMPORTING
            RETURN        = LS_RETURN2
          TABLES
            ORDERS        = MT_PRD_ORDERS
            DETAIL_RETURN = LT_DETAIL_RETURN.
      ENDIF.

      IF MT_PR_ORDERS[] IS NOT INITIAL.
        LV_RETURN = DELETE_PR_ORDER( ).
      ENDIF.

      RETURN.
    ENDIF.

*  생성 완료시 기존 조장 체인정보 삭제
    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS, MT_PR_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
        WHEN 'PR' OR 'UPR'.
          APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
          <LS_BANFN>-BANFN = LS_DEL_2010-ORDNR.
      ENDCASE.
    ENDLOOP.

    LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 계획오더 삭제중 오류 발생하였습니다.'(E04) && '-' && LS_PLAN.
      ENDIF.
    ENDLOOP.


    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 생산오더 삭제중 오류 발생하였습니다.'(E05).
      ENDIF.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).

*  완제품 변경건 존재시 포장재 확인 로직
    IF LINE_EXISTS( IT_2010[ DMORDTY = 'SO' ] ) OR LINE_EXISTS( IT_2010[ DMORDTY = 'SM' ] ).
      CHG_PACK_COFIRM( ).
    ENDIF.

    CONFIRM( ).

    APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
    <LS_RESULT>-TYPE = 'S'.
    DATA : LV_TABIX_C(10).
    LV_TABIX_C = MV_SUCC_CNT.
    CONDENSE LV_TABIX_C.
    <LS_RESULT>-MESSAGE = LV_TABIX_C && '건의 개별 오더로 전환 되었습니다.'(m01).


  ENDMETHOD.


  METHOD PROCESS_UNPEGGING.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RESULT = 'E'.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

* Pegging 삭제는 오더삭제 없이 체인변경만 저장
    CONFIRM( ).

  ENDMETHOD.


  METHOD PROCESS_UNPEGGING_FORCE.

    DATA : LV_CHK_DEL.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LS_INSERT_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_CONVERSION.


    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

*  복조장 구성시 현재 오더 품목 1번일 경우만 하위 오더 삭제 되므로 1번으로 변경필요
    IF IS_2010-POSNR EQ '1'.
      MOVE-CORRESPONDING IS_2010 TO LS_2010.
    ELSE.
      READ TABLE MT_NEW_2010 INTO LS_2010 WITH KEY GONG_SEQ = IS_2010-GONG_SEQ
                                                                        ORDNR = IS_2010-ORDNR
                                                                        POSNR = 1.
      IF SY-SUBRC EQ 0.
        LV_CHK_CONVERSION = ABAP_TRUE.
      ELSE. " 1번 품목 미존재시 하위 품목이 없다는 의미이므로 현재 오더정보만 삭제
        MOVE-CORRESPONDING IS_2010 TO LS_2010.
      ENDIF.
    ENDIF.

    READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
    LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
      READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
      READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_2010-ORDNR
                                                                                                                        POSNR = LS_2010-POSNR
                                                                                                                        ORDTY = LS_2010-ORDTY.
      IF SY-SUBRC EQ 0.
        LV_CHK_DEL = ABAP_TRUE.
        LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
        LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_CHK_DEL = ABAP_TRUE.

      LV_RETURN = GET_CHAIN_TO_DELETE(
                    IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                    IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                    IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                  ).
      IF LV_RETURN = 'E'.
        RV_RESULT = 'E'.
        RETURN.
      ENDIF.

    ENDIF.

* Pegging 삭제는 오더삭제 없이 체인변경만 저장
    IF LV_CHK_CONVERSION = ABAP_TRUE. "오더 체인정보 현재 정보로 변경
* 1번 품목은 다시 살려놓는다
      APPEND LS_2010 TO MT_NEW_2010.

      LOOP AT MT_MAKED_2010 INTO DATA(LS_ORIGN) WHERE REORD = LS_2010-ORDNR
                                                                       AND RELINE = LS_2010-POSNR
                                                                       AND REORDTY = LS_2010-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>) WITH KEY GONG_SEQ = LS_ORIGN-GONG_SEQ
                                                                                                             ORDNR = LS_ORIGN-ORDNR
                                                                                                             POSNR = LS_ORIGN-POSNR
                                                                                                             ORDTY = LS_ORIGN-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_NEW_2010>-REORD = LS_2010-ORDNR.
          <LS_NEW_2010>-RELINE = LS_2010-POSNR.
          <LS_NEW_2010>-REORDTY = LS_2010-ORDTY.
        ENDIF.

      ENDLOOP.

*      현재 공정정보 삭제
      READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY GONG_SEQ = IS_2010-GONG_SEQ
                                                                                    ORDNR = IS_2010-ORDNR
                                                                                    POSNR = IS_2010-POSNR
                                                                                    ORDTY = IS_2010-ORDTY.
      IF SY-SUBRC EQ 0.
        DELETE MT_NEW_2010 INDEX SY-TABIX.
      ENDIF.

      LOOP AT MT_NEW_2010 ASSIGNING <LS_NEW_2010> WHERE REORD = IS_2010-ORDNR
                                                                       AND RELINE = IS_2010-POSNR
                                                                       AND REORDTY = IS_2010-ORDTY.
        CLEAR : <LS_NEW_2010>-REORD, <LS_NEW_2010>-RELINE, <LS_NEW_2010>-REORDTY.
      ENDLOOP.

    ENDIF.

    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_POSNR TYPE AFPO-POSNR.
    DATA : LV_KDAUF TYPE VBAP-VBELN.
    DATA : LV_KDPOS TYPE VBAP-POSNR.
    DATA : LV_SOBKZ TYPE AFPO-SOBKZ.
    DATA : LV_KZBWS TYPE AFPO-KZBWS.


    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      IF LS_DEL_2010-DMORDTY = 'SO'.
        CASE LS_DEL_2010-ORDTY.
          WHEN 'PLN'.

          WHEN 'PRD'.
            LV_AUFNR = LS_DEL_2010-ORDNR.
            IF LV_CHK_CONVERSION = ABAP_TRUE.
              LV_POSNR = IS_2010-POSNR + 0.
            ELSE.
              LV_POSNR = LS_DEL_2010-POSNR + 0.
            ENDIF.

            UPDATE AFPO SET KDAUF = LV_KDAUF
                                 KDPOS = LV_KDPOS
                                 SOBKZ = LV_SOBKZ
                                 KZBWS = LV_KZBWS
              WHERE AUFNR = LV_AUFNR
                 AND POSNR = LV_POSNR.
            IF SY-SUBRC EQ 0.
              COMMIT WORK AND WAIT.
            ENDIF.

        ENDCASE.
      ENDIF.
    ENDLOOP.

    CONFIRM( ).


  ENDMETHOD.


  METHOD PROC_CONVERSION.

    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_POSNR TYPE CO_POSNR.
    DATA : LV_PLNUM TYPE PLNUM.
    DATA : LV_PLANNED_ORDER TYPE PLNUM.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LT_RESB LIKE MT_RESB.
    DATA : LS_2010_NEW LIKE MS_MAKED_2010.
    DATA : LS_2010 TYPE ZGTPPT2010.
    DATA : LV_RSNUM TYPE PLAF-RSNUM.

    MOVE-CORRESPONDING CS_2010 TO LS_2010_NEW.

*    기존 예약자재 테이블 조회하여 자재 수량 맞춘다.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = CS_2010-ORDNR
      IMPORTING
        OUTPUT = LV_PLNUM.

    CLEAR : LV_RSNUM.
    SELECT SINGLE
      FROM PLAF
      FIELDS RSNUM
     WHERE PLNUM = @LV_PLNUM
       INTO @LV_RSNUM .

    SELECT A~*
      FROM RESB AS A
      INNER JOIN MARA AS B
                      ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                      ON C~MATNR = A~MATNR
      INNER JOIN ZGTCVMSTVAL AS D
                      ON D~MATNR = C~MATNR
                     AND D~WERKS = C~WERKS
      INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
      WHERE B~MTART = 'MCHF'
          AND C~WERKS = @MV_WERKS
          AND C~BESKZ IN ('E', 'X')
          AND D~PDCAPROCCODE NE 'BWD'
          AND A~RSNUM = @LV_RSNUM.

    IF LT_RESB[] IS NOT INITIAL.
      APPEND LINES OF LT_RESB TO MT_RESB.
    ENDIF.


    CALL FUNCTION 'BAPI_PRODORD_CREATE_FROM_PLORD'
      EXPORTING
        PLANNED_ORDER    = LV_PLNUM
        ORDER_TYPE       = IV_AUART
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
         WHERE PLNUM = @LV_PLNUM
          INTO (@LV_AUFNR, @LV_POSNR ).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.1' SECONDS.
        ENDIF.
      ENDDO.

      CS_2010-ORDTY = 'PRD'.
      CS_2010-ORDNR = LV_AUFNR.
      CS_2010-POSNR = LV_POSNR + 0.

      IF SY-SUBRC NE 0.
        MV_MESSAGE = LV_PLNUM && '를'.
        CONCATENATE '계획오더' MV_MESSAGE '생산 오더로 전환 중 오류 발생하였습니다.'
                      INTO MV_MESSAGE SEPARATED BY SPACE.
        RV_RETURN = 'E'.
        RETURN.
      ENDIF.

    ELSE.
      MV_MESSAGE = LV_PLNUM && '를'.
      CONCATENATE '계획오더' MV_MESSAGE '생산 오더로 전환 중 오류 발생하였습니다.'
                    INTO MV_MESSAGE SEPARATED BY SPACE.
      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD PROC_MAKE_PLAN_ORDER.

    DATA : LV_CRT_SEQ TYPE I.
    DATA : LV_CRT_SEQ_C(10).
    DATA : LV_CHK_CREATE.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).

    CHECK_MAKE_PLAN_ORDER(
      IMPORTING
        EV_RETURN  = EV_RETURN                " 길이 1의 문자 필드
        ES_MESSAGE = ES_MESSAGE                 " 리턴 매개변수
    ).

    IF EV_RETURN = 'E'. " 조장 구성 가능한 자리가 없는경우 종료처리
      RETURN.
    ENDIF.

    GET_JOJANG_MASTER( ).

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    CLEAR MV_SUCC_CNT.
    LV_CHK_CREATE = ABAP_TRUE.

    DO. " 생성할수 있는 오더 전부 생성후 종료

      IF LV_CHK_CREATE IS INITIAL.
        EXIT.
      ENDIF.
      CLEAR LV_CHK_CREATE.
      CLEAR LS_2010.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LV_RETURN.

      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

        LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER.
          READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
          IF SY-SUBRC EQ 0.
            LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>).
              IF <LS_CHAIN>-ORDNR IS INITIAL.
                CASE <LS_CHAIN>-DMORDTY.
                  WHEN 'SM' OR 'SO'." 해당 오더가 완제품 공정일경우 체크없음
                    LS_2010-ORDNR = <LS_MAIN>-END_ORDNR.
                    LS_2010-POSNR = <LS_MAIN>-END_POSNR.
                    LS_2010-ORDTY = <LS_MAIN>-END_ORDTY.
                    LS_2010-ETC_SEQ = <LS_MAIN>-END_SEQNO.
                    LS_2010-GONG_SEQ = <LS_GONG>-GONG_SEQ.
                    LS_2010-MATNR_SEQ = 1.
                    LS_2010-MATNR = <LS_MAIN>-MATNR.
                    LV_CHK_CREATE = ABAP_TRUE.
                    LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                    LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                    EXIT.
                  WHEN 'PO'. "구매오더 구조상 상응하는 이후공정정보를 찾을수 없으므로 건너띄어준다.
                    CONTINUE.


                  WHEN 'PRD'. " 현재는 생산 오더만 체크
                    CLEAR MS_MAKED_2010.
                    READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                                    POSNR = <LS_CHAIN>-DMLINE
                                                                                                    ORDTY = <LS_CHAIN>-DMORDTY.
                    IF SY-SUBRC EQ 0.
                      IF <LS_CHAIN>-CHK_DUP = ABAP_TRUE.
                        READ TABLE MT_MAKED_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = MS_MAKED_2010-REORD
                                                                                                  POSNR = MS_MAKED_2010-RELINE
                                                                                                  ORDTY = MS_MAKED_2010-REORDTY.
                        IF SY-SUBRC EQ 0. " 해당오더 이전 공정 존재시 생성 대상 아님
                          CONTINUE.
                        ENDIF.
                      ENDIF.

                      CASE  MS_MAKED_2010-STATUS.
                        WHEN 'C'. " 신규 생성된 오더 이므로 처리가능
                          MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                          LV_CHK_CREATE = ABAP_TRUE.
                          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                          EXIT.
                        WHEN 'E'. "오류 이므로 처리 불가능.
* 일단은 건너띄고 혼자만 남았을경우 에러로 사전 처리됨
                        WHEN 'R'. " 가동중인 오더 제외0
                          IF MS_MAKED_2010-CHK_PRD IS INITIAL.
                            MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                            LV_CHK_CREATE = ABAP_TRUE.
                            LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                            LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                            EXIT.
                          ENDIF.
                      ENDCASE.

                    ENDIF.

                  WHEN 'PLN'.
                    READ TABLE MT_NEW_2010 INTO LS_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                            POSNR = <LS_CHAIN>-DMLINE
                                                                                            ORDTY = <LS_CHAIN>-DMORDTY.
                    IF SY-SUBRC EQ 0.
                      LV_CHK_CREATE = ABAP_TRUE.
                      LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                      LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                      EXIT.
                    ENDIF.
                  WHEN OTHERS. " 현재 적용사항 없음. 차후 적용예정

                ENDCASE.
              ENDIF.
            ENDLOOP.
            IF LV_CHK_CREATE IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF LV_CHK_CREATE IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_CREATE = ABAP_TRUE.

        READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.

        LV_RETURN = CREATE_PLAN_ORDER(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_DEV_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
            LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
          ENDLOOP.

          IF MT_PR_ORDERS[] IS NOT INITIAL.
            LV_RETURN = DELETE_PR_ORDER( ).
          ENDIF.

          EV_RETURN = 'E'.
          ES_MESSAGE-MESSAGE = MV_MESSAGE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDDO.

    IF MV_SUCC_CNT NE 0.
      DATA : LV_INDEX_C(10).

      PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).

      CONFIRM( ).

      LV_INDEX_C = MV_SUCC_CNT.
      CONDENSE LV_INDEX_C.
      EV_RETURN = 'S'.
      CONCATENATE MV_GRPNR '계획오더' LV_INDEX_C '건 생성하였습니다.' INTO ES_MESSAGE-MESSAGE SEPARATED BY SPACE.
    ENDIF.

  ENDMETHOD.


  METHOD PROC_MULTY_ORDER.

    DATA : LT_CHK_2010 LIKE MT_MAKED_2010.
    DATA : LT_MULTY_2010 LIKE MT_MAKED_2010.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_PERCENT(2) TYPE N.
    DATA : LT_CHK_GONG LIKE MT_SEQ_ROUTING_HEADER.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

    LT_CHK_2010 = VALUE #( FOR LW_2010 IN MT_MAKED_2010 WHERE ( CHK_CHAR IS NOT INITIAL )
                                     ( CORRESPONDING #( LW_2010 ) ) ).

    SORT LT_CHK_2010 BY CHK_CHAR.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_2010 COMPARING CHK_CHAR.

* 최초 공정 복조장시 수량 머지를 위한 체크로직
    LT_CHK_GONG = MT_SEQ_ROUTING_HEADER.
    SORT LT_CHK_GONG BY SEQNO.
    READ TABLE LT_CHK_GONG INTO DATA(LS_CHK_GONG) INDEX 1.

    LV_PERCENT = '20'.
    LOOP AT LT_CHK_2010 INTO DATA(LS_CHK_CHAR).
      IF LV_PERCENT < 80.
        ADD 10 TO LV_PERCENT.
      ENDIF.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '복조장 구성중..' ).

      REFRESH LT_MULTY_2010.
      LT_MULTY_2010 = VALUE #( FOR LW_2010 IN MT_MAKED_2010 WHERE ( CHK_CHAR = LS_CHK_CHAR-CHK_CHAR )
                                    ( CORRESPONDING #( LW_2010 ) ) ).

      IF LS_CHK_CHAR-GONG_SEQ = LS_CHK_GONG-GONG_SEQ AND LINES( MT_SEQ_ROUTING_HEADER ) > 1.
        LV_RETURN = MULTY_ORDER_TO_MERGE( IT_2010 = LT_MULTY_2010 ).
      ELSE.
        LV_RETURN = MULTY_ORDER( IT_2010 = LT_MULTY_2010 ).
      ENDIF.
      IF LV_RETURN = 'E'.
        REFRESH RT_RESULT.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
        <LS_RESULT>-TYPE = 'E'.
        CONCATENATE '복조장 구성 문자 ' LS_CHK_CHAR-CHK_CHAR '작업 중 오류 발생하였습니다. -' MV_MESSAGE INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
        EXIT.
      ELSE.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'S'.
        CONCATENATE '복조장 구성 문자 ' LS_CHK_CHAR-CHK_CHAR '에 대해 완료하였습니다.' INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.

      ENDIF.
    ENDLOOP.

* 에러발생시 생성된 오더 삭제후 종료
    IF LV_RETURN = 'E'.
      DATA : LS_RETURN2 TYPE BAPIRET2.
      DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

      IF MT_PRD_ORDERS[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
          IMPORTING
            RETURN        = LS_RETURN2
          TABLES
            ORDERS        = MT_PRD_ORDERS
            DETAIL_RETURN = LT_DETAIL_RETURN.
      ENDIF.

      IF MT_PR_ORDERS[] IS NOT INITIAL.
        LV_RETURN = DELETE_PR_ORDER( ).
      ENDIF.

      RETURN.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 85  IV_TEXT = '복조장 구성완료 오더생성 및 변경..' ).
*  생성 완료시 기존 조장 체인정보 삭제
    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS, MT_PR_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
        WHEN 'PR' OR 'UPR'.
          APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
          <LS_BANFN>-BANFN = LS_DEL_2010-ORDNR.
          <LS_BANFN>-BNFPO = LS_DEL_2010-POSNR + 0.
      ENDCASE.
    ENDLOOP.

    LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 계획오더 삭제중 오류 발생하였습니다.'(E04).
      ENDIF.
    ENDLOOP.


    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 생산오더 삭제중 오류 발생하였습니다.'(E05).
      ENDIF.
    ENDIF.


    IF MT_PR_ORDERS[] IS NOT INITIAL.
      LV_RETURN = DELETE_PR_ORDER( ).
      IF LV_RETURN = ABAP_TRUE.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = MV_MESSAGE.
        RETURN.
      ENDIF.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).

*  완제품 변경건 존재시 포장재 확인 로직
    IF LINE_EXISTS( LT_CHK_2010[ DMORDTY = 'SO' ] ) OR LINE_EXISTS( LT_CHK_2010[ DMORDTY = 'SM' ] ).
      CHG_PACK_COFIRM( ).
    ENDIF.

    CONFIRM( ).


  ENDMETHOD.


  METHOD PROC_PEGGING.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.

    DATA : LT_2010_PEGGING LIKE MT_NEW_2010.
    DATA : LT_2010_FULL LIKE MT_NEW_2010.
    DATA : LV_CHK_JOJANG.
    DATA : LT_2010_NEW LIKE MT_NEW_2010.
    DATA : BEGIN OF LS_2010_MENGE.
             INCLUDE TYPE ZGTPPT2010.
    DATA :   MENGE TYPE MENGE_D,
           END OF LS_2010_MENGE.
    DATA : LT_ORIGN LIKE TABLE OF LS_2010_MENGE.
    DATA : LT_PEGGING LIKE TABLE OF LS_2010_MENGE.

    DATA : LT_PRE_2010 LIKE MT_NEW_2010.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 LIKE LINE OF MT_NEW_2010.
    DATA : LV_CHK_OTHER_CHAIN.


* 선택된 Pegging 정보로 itab구성
    GET_ORD_INFOR_OF_PEGGING(
      EXPORTING
        IV_ORDNR      =  IV_TARGET_ORDER                " 오더번호
        IV_POSNR      =   IV_TARGET_POSNR               " 판매 문서 항목
        IV_ORDTY      =   IV_TATGET_ORDTY               " 오더유형
     IMPORTING
       ET_2010       = LT_2010_PEGGING
       ET_2010_FULL  = LT_2010_FULL
       EV_CHK_JOJANG = LV_CHK_JOJANG ).                 " 길이 1의 문자 필드

    LOOP AT LT_2010_PEGGING INTO DATA(LS_TEMP).
      APPEND INITIAL LINE TO LT_PEGGING ASSIGNING FIELD-SYMBOL(<LS_PEGGING>).
      MOVE-CORRESPONDING LS_TEMP TO <LS_PEGGING>.
      <LS_PEGGING>-MENGE = ( LS_TEMP-INLENGTH + LS_TEMP-QLENGTH + LS_TEMP-CLENGTH +
                                           LS_TEMP-SLENGTH + LS_TEMP-ELENGTH + LS_TEMP-ADLENGTH ) *
                                           LS_TEMP-INFACTOR.
    ENDLOOP.

    LOOP AT IT_PEGGING_DATA INTO DATA(LS_TEMP_ORIGN).
      APPEND INITIAL LINE TO LT_ORIGN ASSIGNING FIELD-SYMBOL(<LS_ORIGN>).
      MOVE-CORRESPONDING LS_TEMP_ORIGN TO <LS_ORIGN>.
      <LS_ORIGN>-MENGE = ( LS_TEMP_ORIGN-INLENGTH + LS_TEMP_ORIGN-QLENGTH + LS_TEMP_ORIGN-CLENGTH +
                                       LS_TEMP_ORIGN-SLENGTH + LS_TEMP_ORIGN-ELENGTH + LS_TEMP_ORIGN-ADLENGTH ) *
                                       LS_TEMP_ORIGN-INFACTOR.
    ENDLOOP.


    SORT LT_ORIGN BY MENGE DESCENDING.
    SORT LT_PEGGING BY MENGE DESCENDING.

*    동일 속성값(품목소요량) 을 체크하여 현재 구성 체인에 오더번호, 품목번호 세팅
    LOOP AT LT_ORIGN INTO DATA(LS_ORIGN).
      LOOP AT LT_PEGGING INTO DATA(LS_PEGGING) WHERE MENGE >= LS_ORIGN-MENGE. " 소요량 값은 기준
        DATA(LV_TXBIX) = SY-TABIX.
*      이후 공정 체인 하위오더로 타켓오더 연결
        APPEND INITIAL LINE TO  LT_2010_NEW ASSIGNING FIELD-SYMBOL(<LS_2010>).

        MOVE-CORRESPONDING LS_ORIGN TO <LS_2010>.
        <LS_2010>-ORDNR = LS_PEGGING-ORDNR.
        <LS_2010>-POSNR = LS_PEGGING-POSNR.
        <LS_2010>-ORDTY = LS_PEGGING-ORDTY.
        CLEAR : <LS_2010>-REORD, <LS_2010>-RELINE, <LS_2010>-REORDTY.


        MOVE : LS_PEGGING-INLENGTH TO <LS_2010>-INLENGTH,
                  LS_PEGGING-INFACTOR TO <LS_2010>-INFACTOR,
                  LS_PEGGING-QLENGTH TO <LS_2010>-QLENGTH,
                  LS_PEGGING-CLENGTH TO <LS_2010>-CLENGTH,
                  LS_PEGGING-SLENGTH TO <LS_2010>-SLENGTH,
                  LS_PEGGING-ELENGTH TO <LS_2010>-ELENGTH,
                  LS_PEGGING-ADLENGTH TO <LS_2010>-ADLENGTH,
                  LS_PEGGING-ADTYPE TO <LS_2010>-ADTYPE.

        IF LS_PEGGING-MATNR  NE <LS_2010>-MATNR.
          MOVE LS_PEGGING-MATNR TO <LS_2010>-REAL_MATNR.
        ENDIF.

        LOOP AT MT_MAKED_2010 INTO DATA(LS_DEV) WHERE REORD = LS_ORIGN-ORDNR
                                                                  AND RELINE = LS_ORIGN-POSNR
                                                                  AND REORDTY = LS_ORIGN-ORDTY.
          CLEAR LS_DEV_2010.
          MOVE-CORRESPONDING LS_DEV TO LS_DEV_2010.
          LS_DEV_2010-REORD = <LS_2010>-REORD.
          LS_DEV_2010-RELINE = <LS_2010>-RELINE.
          LS_DEV_2010-REORDTY = <LS_2010>-REORDTY.
          APPEND LS_DEV_2010 TO LT_DEV_2010.
        ENDLOOP.

* 선택된 오더는 다시 선택 없도록 제외
        DELETE LT_PEGGING INDEX LV_TXBIX.
        EXIT. " 한건 맵핑후 다음 순번으로 넘겨준다.
      ENDLOOP.

    ENDLOOP.

    IF LT_PEGGING[] IS NOT INITIAL.
      RV_MESSAGE = 'Pegging 진행중 오류 발생하였습니다. '.
      RETURN.
    ENDIF.

* Pegging   정보 저장을 위해 현재 공정정보 삭제
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    LOOP AT IT_PEGGING_DATA INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_MESSAGE = 'Pegging 진행중 오류 발생하였습니다. '.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


    IF LT_DEV_2010[] IS NOT INITIAL.
      LOOP AT LT_DEV_2010 INTO LS_DEV_2010.
        READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_CHG>) WITH KEY ORDNR = LS_DEV_2010-ORDNR
                                                                                                                  POSNR = LS_DEV_2010-POSNR
                                                                                                                  ORDTY = LS_DEV_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_DEV_CHG>-REORD = LS_DEV_2010-REORD.
          <LS_DEV_CHG>-RELINE = LS_DEV_2010-RELINE.
          <LS_DEV_CHG>-REORDTY = LS_DEV_2010-REORDTY.
        ENDIF.

      ENDLOOP.

      REFRESH LT_DEV_2010.
    ENDIF.

    APPEND LINES OF LT_2010_NEW TO MT_NEW_2010.
* 현재 공정 정보 저장
    CONFIRM( ).

* 옮겨진 Pegging 정보다 조장구성표에 존재하는 건이라면 해당 조장구성표 Pegging 라인 삭제
    IF LV_CHK_JOJANG = ABAP_TRUE.
      READ TABLE LT_2010_PEGGING INTO LS_TEMP INDEX 1.
      MV_GRPNR = LS_TEMP-GRPNR.
      LT_DEV_2010 = LT_2010_PEGGING.
      MT_NEW_2010 = LT_2010_FULL.

      DO.
        IF LT_DEV_2010 IS INITIAL.
          EXIT.
        ENDIF.

        LOOP AT LT_DEV_2010 INTO LS_DEV_2010.
* 이후 공정 오더 가 존재 하면
          LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV>) WHERE REORD = LS_DEV_2010-ORDNR
                                                                                           AND  RELINE = LS_DEV_2010-POSNR
                                                                                           AND  REORDTY = LS_DEV_2010-ORDTY.
            CLEAR : <LS_DEV>-REORD, <LS_DEV>-RELINE, <LS_DEV>-REORDTY.
          ENDLOOP.
*          현재 공정 삭제
          LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_CURRENT>) WHERE ORDNR = LS_DEV_2010-ORDNR
                                                                                           AND  POSNR = LS_DEV_2010-POSNR
                                                                                           AND  ORDTY = LS_DEV_2010-ORDTY.
            DELETE TABLE MT_NEW_2010 FROM <LS_CURRENT>.
          ENDLOOP.

* 이전 공정 중 삭제 대상만 추출
          IF LS_DEV_2010-REORD IS NOT INITIAL.
            CLEAR LV_CHK_OTHER_CHAIN.
            LOOP AT LT_2010_FULL INTO DATA(LS_DEV_CHK) WHERE REORD = LS_DEV_2010-REORD
                                                                                  AND RELINE = LS_DEV_2010-RELINE
                                                                                  AND REORDTY = LS_DEV_2010-REORDTY.

              READ TABLE LT_DEV_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_DEV_CHK-ORDNR
                                                                                             POSNR = LS_DEV_CHK-POSNR
                                                                                             ORDTY = LS_DEV_CHK-ORDTY.
              IF SY-SUBRC NE 0. "
                LV_CHK_OTHER_CHAIN = ABAP_TRUE.
              ENDIF.
            ENDLOOP.

            IF LV_CHK_OTHER_CHAIN IS INITIAL.
              READ TABLE LT_2010_FULL INTO DATA(LV_PRE_CHK) WITH KEY ORDNR = LS_DEV_2010-REORD
                                                                                  POSNR = LS_DEV_2010-RELINE
                                                                                  ORDTY = LS_DEV_2010-REORDTY.
              IF SY-SUBRC EQ 0.
                LOOP AT LT_2010_FULL INTO DATA(LV_PRE_2010) WHERE DMORD = LV_PRE_CHK-DMORD
                                                                                   AND DMLINE = LV_PRE_CHK-DMLINE
                                                                                   AND DMORDTY = LV_PRE_CHK-DMORDTY.

                  READ TABLE LT_PRE_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LV_PRE_2010-ORDNR
                                                                                          POSNR = LV_PRE_2010-POSNR
                                                                                          ORDTY = LV_PRE_2010-ORDTY.
                  IF SY-SUBRC NE 0.
                    APPEND LV_PRE_2010 TO LT_PRE_2010.
                  ENDIF.

                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.


        IF LT_PRE_2010 IS NOT INITIAL.
          SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
          DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.
          REFRESH LT_DEV_2010.
          MOVE-CORRESPONDING LT_PRE_2010 TO LT_DEV_2010.
        ENDIF.
      ENDDO.

* Pegging 조장의 정보 저장
      CONFIRM( ).
    ENDIF.

  ENDMETHOD.


  METHOD SET_CHAIN_TABLE.

    READ TABLE MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WITH KEY END_SEQNO = IV_MAIN_SEQ.

    READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY GONG_SEQ = IV_GONG_SEQ.

    CASE IV_GUBUN.
      WHEN 'D'. " 현재 공정
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY SEQ_MATNR = IV_MATNR
                                                                                                                  IN_SEQNO = IV_SEQNO.
        IF SY-SUBRC EQ 0.
          <LS_CHAIN>-ORDNR = IS_2010-ORDNR.
          <LS_CHAIN>-POSNR = IS_2010-POSNR.
          <LS_CHAIN>-ORDTY = IS_2010-ORDTY.
          <LS_CHAIN>-CHK_STATUS = 'N'.
        ENDIF.
      WHEN 'U'.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN> WITH KEY SEQ_MATNR = IV_MATNR
                                                                                          IN_SEQNO = IV_SEQNO.
        IF SY-SUBRC EQ 0.
          <LS_CHAIN>-DMORD = IS_2010-ORDNR.
          <LS_CHAIN>-DMLINE = IS_2010-POSNR.
          <LS_CHAIN>-DMORDTY = IS_2010-ORDTY.
          <LS_CHAIN>-DM_STATUS = 'N'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD SET_PRD_CHARICTERISTIC.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_FIELDNAME TYPE FNAM_____4.
    DATA : LV_NUM(2) TYPE N.

    DATA : LV_TEST01 TYPE CABNT-ATBEZ.
    DATA : LV_TEST02 TYPE CABNT-ATBEZ.
    DATA : LV_TEST03 TYPE CABNT-ATBEZ.

    SELECT A~ATNAM, B~ATBEZ
      FROM CABN AS A
      INNER JOIN CABNT AS B ON B~ATINN = A~ATINN
    WHERE A~ATNAM IN ( 'SAP_MILLCA_LENGTH', 'SAP_MILLCA_FACTOR', 'PD_CA_PROC_NAME' )
      AND B~SPRAS = @SY-LANGU
     INTO TABLE @DATA(LT_CHAR_NAME).

    LOOP AT LT_CHAR_NAME INTO DATA(LS_CHAR_NAME).
      CASE LS_CHAR_NAME-ATNAM.
        WHEN 'SAP_MILLCA_LENGTH'.
          LV_TEST01 = LS_CHAR_NAME-ATBEZ.
        WHEN 'SAP_MILLCA_FACTOR'.
          LV_TEST02 = LS_CHAR_NAME-ATBEZ.
        WHEN 'PD_CA_PROC_NAME'.
          LV_TEST03 = LS_CHAR_NAME-ATBEZ.
      ENDCASE.
    ENDLOOP.

    REFRESH : MT_BDCDATA, MT_MESSTAB.

    SELECT AUFNR, POSNR, PSMNG, AMEIN
        FROM AFPO
       WHERE AUFNR = @IS_2010-ORDNR
        INTO TABLE @DATA(LT_AFPO).

    SORT LT_AFPO BY POSNR.

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

    IF IV_GUBUN NE 'C'.
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
    ENDIF.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

    LOOP AT LT_AFPO INTO DATA(LS_AFPO) .

      IF LS_AFPO-POSNR = IS_2010-POSNR+2(4).
        __BDC_DYNPRO 'SAPLCEI0' '0109'.
        __BDC_FIELD : 'RCTMS-MNAME(01)' LV_TEST01,
                            'RCTMS-MNAME(02)' LV_TEST02,
                            'RCTMS-MNAME(03)' LV_TEST03,
                            'RCTMS-MWERT(01)' LV_INLENGTH_C,
                            'RCTMS-MWERT(02)' LV_INFACTOR_C,
                            'RCTMS-MWERT(03)' IS_2010-GONG_CD,
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
    IF IV_SKIP_DELAY IS INITIAL.
      WAIT UP TO '0.5' SECONDS.
    ENDIF.

  ENDMETHOD.


  METHOD UPDATE_RESB.

    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_TOTALQTY TYPE GAMNG.
    DATA : LV_TOTALQTY_NEW TYPE GAMNG.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LT_DEV_2010_TAN LIKE MT_NEW_2010.
    DATA : LT_SORT_TAN LIKE MT_NEW_2010.
    DATA : LS_DEV_2010_CHK TYPE ZGTPPT2010.
    DATA : LS_DEV_2010_CHK2 TYPE ZGTPPT2010.
    DATA : LT_CHK_DEV_2010 LIKE MT_NEW_2010.
    DATA : LT_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_MODI_CHK.
    DATA : LV_CHK_MATNR TYPE MATNR.
    DATA : LT_CHK_GONG LIKE MT_SEQ_ROUTING_HEADER.
    DATA : LV_MENGE TYPE MENGE_D.
    DATA : LV_MENGE_NOMAL TYPE MENGE_D.
    DATA : LV_MENGE_LAST TYPE MENGE_D.
    DATA : BEGIN OF LS_ORDER_MENGE,
             ORDNR TYPE ZGTPPT2010-ORDNR,
             ORDTY TYPE ZGTPPT2010-ORDTY,
             GSMNG TYPE MENGE_D,
           END OF  LS_ORDER_MENGE.
    DATA : LT_ORDER_MENGE LIKE TABLE OF LS_ORDER_MENGE.
    DATA : LV_CHK_MINUS.
    DATA : LV_DEV_INDEX TYPE I.
    DATA : LV_INDEX TYPE I.
    DATA : LV_CHK_MULTY.

* 최초 공정인지 확인
    LT_CHK_GONG = MT_SEQ_ROUTING_HEADER.
    SORT LT_CHK_GONG BY SEQNO.
    READ TABLE LT_CHK_GONG INTO DATA(LS_CHK_GONG) INDEX 1.

    LOOP AT IT_2010 INTO DATA(LS_2010).
      CLEAR LV_CHK_MULTY.
* 탄뎀공정의 참조데이터는 이후공정 resb 업데이트 바로 적용 안함.
      IF LS_2010-REF_TANDEM = ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_2010-GONG_SEQ = LS_CHK_GONG-GONG_SEQ AND LINES( MT_SEQ_ROUTING_HEADER ) > 1.

* 연선 복조장의 경우인지 확인.
        REFRESH LT_CHK_DEV_2010.
        LOOP AT MT_NEW_2010 INTO DATA(LS_CHK_DEV) WHERE REORD = LS_2010-ORDNR
                                                                   AND RELINE = LS_2010-POSNR
                                                                   AND REORDTY = LS_2010-ORDTY
                                                                   AND ( ORDTY = 'PRD'
                                                                    OR  ORDTY = 'PLN' ).
          APPEND LS_CHK_DEV TO LT_CHK_DEV_2010.
        ENDLOOP.
        SORT LT_CHK_DEV_2010 BY ORDNR POSNR ORDTY.
        DELETE ADJACENT DUPLICATES FROM LT_CHK_DEV_2010 COMPARING ORDNR POSNR ORDTY.
      ENDIF.

      REFRESH LT_ORDER_MENGE.
      IF LINES( LT_CHK_DEV_2010 ) > 1.

        LV_CHK_MULTY = ABAP_TRUE.
        LOOP AT LT_CHK_DEV_2010 INTO LS_CHK_DEV.
          CLEAR LS_ORDER_MENGE.
          LS_ORDER_MENGE-ORDNR = LS_CHK_DEV-ORDNR.
          LS_ORDER_MENGE-ORDTY = LS_CHK_DEV-ORDTY.
          LS_ORDER_MENGE-GSMNG = ( LS_CHK_DEV-INLENGTH +
                                                    LS_CHK_DEV-CLENGTH + LS_CHK_DEV-SLENGTH +
                                                    LS_CHK_DEV-ELENGTH + LS_CHK_DEV-QLENGTH +
                                                    LS_CHK_DEV-ADLENGTH ) * LS_CHK_DEV-INFACTOR .
          COLLECT LS_ORDER_MENGE INTO LT_ORDER_MENGE.
        ENDLOOP.
        SORT LT_ORDER_MENGE BY GSMNG.

        CLEAR LV_CHK_MATNR.
        SELECT SINGLE MATNR FROM QMAT
          INTO @LV_CHK_MATNR
         WHERE MATNR = @LS_2010-MATNR
           AND WERKS = @MV_WERKS
           AND ART = '04'
           AND AKTIV = 'X'.

        READ TABLE MT_MAKED_2010 INTO DATA(LS_ORIGN_2010) WITH KEY ORDNR = LS_2010-ORDNR
                                                                                   POSNR = LS_2010-POSNR
                                                                                   ORDTY = LS_2010-ORDTY.
        IF LV_CHK_MATNR IS NOT INITIAL AND LS_ORIGN_2010-ADTYPE = 'A'.
          LS_ORIGN_2010-ADLENGTH = 0.
        ENDIF.

        CLEAR LV_MENGE_LAST.
        IF LV_CHK_MATNR IS NOT INITIAL AND LS_ORIGN_2010-ADTYPE = 'A'.
          LV_MENGE_LAST = 0.
        ELSE.
          LV_MENGE_LAST = LS_2010-ADLENGTH.
        ENDIF.


        LV_MENGE_LAST = LV_MENGE_LAST - LS_ORIGN_2010-ADLENGTH.
        IF LV_MENGE_LAST = 0. " 적용사항 없음
        ELSE.
          IF LV_MENGE_LAST < 0.
            LV_CHK_MINUS = ABAP_TRUE.
            LV_MENGE_LAST = LV_MENGE_LAST * -1.
          ENDIF.

          REFRESH LT_RESB.
          LOOP AT LT_ORDER_MENGE INTO LS_ORDER_MENGE.
            CASE LS_ORDER_MENGE-ORDTY.
              WHEN 'PRD'.
                SELECT DISTINCT B~*
                  FROM AFKO AS A
                  INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
                  APPENDING TABLE @LT_RESB
                 WHERE A~AUFNR = @LS_ORDER_MENGE-ORDNR
                    AND B~MATNR = @LS_2010-MATNR.
              WHEN 'PLN'.
                SELECT DISTINCT B~*
                  FROM PLAF AS A
                  INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
                  APPENDING TABLE @LT_RESB
                 WHERE A~PLNUM = @LS_ORDER_MENGE-ORDNR
                    AND B~MATNR = @LS_2010-MATNR.
            ENDCASE.
          ENDLOOP.

          LV_DEV_INDEX = LINES( LT_RESB ).
          LV_MENGE = FLOOR( LV_MENGE_LAST / LV_DEV_INDEX ).

          LOOP AT LT_RESB INTO DATA(LS_RESB_UPDATE).
            LV_INDEX = SY-TABIX.

            IF LV_INDEX = LV_DEV_INDEX.
              IF LV_CHK_MINUS = ABAP_TRUE.
                LS_RESB_UPDATE-BDMNG = LS_RESB_UPDATE-BDMNG - LV_MENGE_LAST.
              ELSE.
                LS_RESB_UPDATE-BDMNG = LS_RESB_UPDATE-BDMNG + LV_MENGE_LAST.
              ENDIF.
            ELSE.
              IF LV_CHK_MINUS = ABAP_TRUE.
                LS_RESB_UPDATE-BDMNG = LS_RESB_UPDATE-BDMNG - LV_MENGE.
              ELSE.
                LS_RESB_UPDATE-BDMNG = LS_RESB_UPDATE-BDMNG + LV_MENGE.
              ENDIF.

              LV_MENGE_LAST = LV_MENGE_LAST - LV_MENGE.

            ENDIF.

            UPDATE RESB SET BDMNG = LS_RESB_UPDATE-BDMNG
                                      ERFMG = LS_RESB_UPDATE-ERFMG
             WHERE RSNUM = LS_RESB_UPDATE-RSNUM
               AND  RSPOS = LS_RESB_UPDATE-RSPOS
               AND  RSART = LS_RESB_UPDATE-RSART.
            IF SY-SUBRC EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              CONTINUE.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ELSE.
        CLEAR LV_MODI_CHK.
        CLEAR LV_TOTALQTY_NEW.
        CLEAR LV_TOTALQTY.

        CLEAR LV_CHK_MATNR.
        SELECT SINGLE MATNR FROM QMAT
          INTO @LV_CHK_MATNR
         WHERE MATNR = @LS_2010-MATNR
           AND WERKS = @MV_WERKS
           AND ART = '04'
           AND AKTIV = 'X'.

        LV_TOTALQTY_NEW =  ( LS_2010-INLENGTH +
                                          LS_2010-CLENGTH + LS_2010-SLENGTH +
                                          LS_2010-ELENGTH + LS_2010-QLENGTH +
                                          LS_2010-ADLENGTH ) * LS_2010-INFACTOR .

        IF LV_CHK_MATNR IS NOT INITIAL.
          IF MS_MAKED_2010-ADTYPE = 'A'.
            LV_TOTALQTY_NEW = LV_TOTALQTY_NEW - LS_2010-QLENGTH - LS_2010-ADLENGTH.
          ELSE.
            LV_TOTALQTY_NEW = LV_TOTALQTY_NEW - LS_2010-QLENGTH.
          ENDIF.
        ENDIF.

        READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = LS_2010-ORDNR
                                                                                            POSNR = LS_2010-POSNR
                                                                                            ORDTY = LS_2010-ORDTY.

        IF SY-SUBRC EQ 0.
          LV_TOTALQTY =  ( MS_MAKED_2010-INLENGTH  +
                                     MS_MAKED_2010-CLENGTH + MS_MAKED_2010-SLENGTH +
                                     MS_MAKED_2010-ELENGTH + MS_MAKED_2010-QLENGTH +
                                     MS_MAKED_2010-ADLENGTH ) * MS_MAKED_2010-INFACTOR .

          IF LV_CHK_MATNR IS NOT INITIAL.
            IF MS_MAKED_2010-ADTYPE = 'A'.
              LV_TOTALQTY = LV_TOTALQTY - MS_MAKED_2010-QLENGTH - MS_MAKED_2010-ADLENGTH.
            ELSE.
              LV_TOTALQTY = LV_TOTALQTY - MS_MAKED_2010-QLENGTH.
            ENDIF.
          ENDIF.
        ENDIF.

        CLEAR : LV_RSNUM.
        GET_FINDATE(
          EXPORTING
            IV_ORDNR   = LS_2010-DMORD  " 오더번호
            IV_ORDTY   = LS_2010-DMORDTY" 오더유형
          IMPORTING
            EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

        REFRESH LT_RESB.
        SELECT A~*
          FROM RESB AS A
          INNER JOIN MARA AS B
                          ON B~MATNR = A~MATNR
          INNER JOIN MARC AS C
                          ON C~MATNR = A~MATNR
          INNER JOIN ZGTCVMSTVAL AS D
                          ON D~MATNR = C~MATNR
                         AND D~WERKS = C~WERKS
          INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
          WHERE B~MTART = 'MCHF'
            AND A~STLTY = 'M' " BOM 대상
            AND A~DUMPS = '' " 가상품목이 아닌경우
            AND C~WERKS = @MV_WERKS
            AND C~BESKZ IN ('E', 'X')
            AND D~PDCAPROCCODE NE 'BWD'
            AND A~RSNUM = @LV_RSNUM.

        READ TABLE LT_RESB INTO DATA(LS_RESB) WITH KEY MATNR = LS_2010-MATNR
                                                                          BDMNG = LV_TOTALQTY.
        IF SY-SUBRC EQ 0.
          LV_MODI_CHK = ABAP_TRUE.
        ELSE.
          SORT LT_RESB BY MATNR BDMNG.
          READ TABLE LT_RESB INTO LS_RESB WITH KEY MATNR = LS_2010-MATNR.
          IF SY-SUBRC EQ 0.
            LV_MODI_CHK = ABAP_TRUE.
          ENDIF.
        ENDIF.

        IF LV_MODI_CHK = ABAP_TRUE.
          LS_RESB-BDMNG = LV_TOTALQTY_NEW.
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              I_MATNR              = LS_RESB-MATNR    " <-- 해당 자재코드
              I_IN_ME              = LS_RESB-MEINS  "<-- 현 수량의 단위
              I_OUT_ME             = LS_RESB-ERFME " <-- 변경되어질 수량의 단위
              I_MENGE              = LV_TOTALQTY_NEW " <-- 현 수량 변수
            IMPORTING
              E_MENGE              = LS_RESB-ERFMG " <-- 변경되어질 수량변수
            EXCEPTIONS
              ERROR_IN_APPLICATION = 1
              ERROR                = 2
              OTHERS               = 3.

          UPDATE RESB SET BDMNG = LS_RESB-BDMNG
                                    ERFMG = LS_RESB-ERFMG
           WHERE RSNUM = LS_RESB-RSNUM
             AND  RSPOS = LS_RESB-RSPOS
             AND  RSART = LS_RESB-RSART.
          IF SY-SUBRC EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            CONTINUE.
          ENDIF.

        ENDIF.

      ENDIF.

* 업데이트 되는 이후 공정이 탄뎀 참조 오더라면 탄뎀 공정에 resb 업데이트
      READ TABLE MT_MAKED_2010 INTO DATA(LS_MAKED_2010) WITH KEY ORDNR = LS_2010-DMORD
                                                                                   POSNR = LS_2010-DMLINE
                                                                                   ORDTY = LS_2010-DMORDTY.
      IF SY-SUBRC EQ 0 AND LS_MAKED_2010-REF_TANDEM = ABAP_TRUE.
        REFRESH LT_DEV_2010.

        IF LV_CHK_MULTY = ABAP_TRUE. " 탄뎀 설정된 공정이 복조장이 있을수도 있어 멀티로 반영
          LOOP AT MT_MAKED_2010 INTO LS_MAKED_2010 WHERE REORD = LS_2010-ORDNR
                                                                         AND RELINE = LS_2010-POSNR
                                                                         AND REORDTY = LS_2010-ORDTY.
            CLEAR LS_DEV_2010_CHK.
            MOVE-CORRESPONDING LS_MAKED_2010 TO LS_DEV_2010_CHK.
            APPEND LS_DEV_2010_CHK TO LT_DEV_2010.
          ENDLOOP.


          REFRESH LT_DEV_2010_TAN.
          LOOP AT LT_DEV_2010 INTO LS_DEV_2010_CHK.
            READ TABLE MT_MAKED_2010 INTO DATA(LS_DEV_2010) WITH KEY ORDNR = LS_DEV_2010_CHK-DMORD
                                                                                              POSNR = LS_DEV_2010_CHK-DMLINE
                                                                                              ORDTY = LS_DEV_2010_CHK-DMORDTY
                                                                                              REF_TANDEM = 'T'.
            IF SY-SUBRC EQ 0.
              LOOP AT MT_MAKED_2010 INTO DATA(LS_DEV_2010_TAN) WHERE REORD = LS_DEV_2010-REORD
                                                                                               AND RELINE = LS_DEV_2010-RELINE
                                                                                               AND REORDTY = LS_DEV_2010-REORDTY
                                                                                               AND REF_TANDEM = 'T'.

                CLEAR LS_DEV_2010_CHK2.
                MOVE-CORRESPONDING LS_DEV_2010_TAN TO LS_DEV_2010_CHK2.
                APPEND LS_DEV_2010_CHK2 TO LT_DEV_2010_TAN.
              ENDLOOP.
            ENDIF.

            IF LT_DEV_2010_TAN[] IS INITIAL.
              READ TABLE MT_MAKED_2010 INTO LS_DEV_2010 WITH KEY REORD = LS_MAKED_2010-ORDNR
                                                                                        RELINE = LS_MAKED_2010-POSNR
                                                                                        REORDTY = LS_MAKED_2010-ORDTY
                                                                                        REF_TANDEM = 'T'.
              IF SY-SUBRC EQ 0.
                LOOP AT MT_MAKED_2010 INTO LS_DEV_2010_TAN WHERE REORD = LS_DEV_2010-REORD
                                                                                                 AND RELINE = LS_DEV_2010-RELINE
                                                                                                 AND REORDTY = LS_DEV_2010-REORDTY
                                                                                                 AND REF_TANDEM = 'T'.

                  CLEAR LS_DEV_2010_CHK2.
                  MOVE-CORRESPONDING LS_DEV_2010_TAN TO LS_DEV_2010_CHK2.
                  APPEND LS_DEV_2010_CHK2 TO LT_DEV_2010_TAN.
                ENDLOOP.
              ENDIF.

            ENDIF.
          ENDLOOP.

          SORT LT_DEV_2010_TAN BY GONG_CD ORDNR POSNR ORDTY.
          DELETE ADJACENT DUPLICATES FROM LT_DEV_2010_TAN COMPARING GONG_CD ORDNR POSNR ORDTY.

          REFRESH LT_SORT_TAN.
          LT_SORT_TAN = LT_DEV_2010_TAN.
          SORT LT_SORT_TAN BY GONG_CD ORDNR POSNR.
          DELETE ADJACENT DUPLICATES FROM LT_SORT_TAN COMPARING GONG_CD ORDNR POSNR.

          LOOP AT LT_SORT_TAN INTO LS_DEV_2010.

            REFRESH LT_PRE_2010.

            LOOP AT MT_MAKED_2010 INTO DATA(LS_PRE) WHERE DMORD = LS_DEV_2010-ORDNR
                                                        AND DMLINE = LS_DEV_2010-POSNR
                                                        AND DMORDTY = LS_DEV_2010-ORDTY.

              APPEND LS_PRE TO LT_PRE_2010.
            ENDLOOP.

            LOOP AT MT_MAKED_2010 INTO LS_PRE WHERE ORDNR = LS_DEV_2010-REORD
                                                        AND POSNR = LS_DEV_2010-RELINE
                                                        AND ORDTY = LS_DEV_2010-REORDTY.

              APPEND LS_PRE TO LT_PRE_2010.
            ENDLOOP.

            SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
            DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.


* 탄뎀공정의 RESB반영
            UPDATE_TANDEM_RESB(
              IS_CURRENT   = LS_DEV_2010
              IT_CHAIN_PRE = LT_PRE_2010
              IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소


          ENDLOOP.


        ELSE.
          REFRESH LT_PRE_2010.
          READ TABLE MT_MAKED_2010 INTO LS_DEV_2010 WITH KEY ORDNR = LS_MAKED_2010-DMORD
                                                                                      POSNR = LS_MAKED_2010-DMLINE
                                                                                      ORDTY = LS_MAKED_2010-DMORDTY
                                                                                      REF_TANDEM = 'T'.
          IF SY-SUBRC EQ 0.
            LOOP AT MT_MAKED_2010 INTO LS_PRE WHERE DMORD = LS_DEV_2010-ORDNR
                                                                    AND DMLINE = LS_DEV_2010-POSNR
                                                                    AND DMORDTY = LS_DEV_2010-ORDTY.

              APPEND LS_PRE TO LT_PRE_2010.
            ENDLOOP.

* 탄뎀공정의 RESB반영
            UPDATE_TANDEM_RESB(
              IS_CURRENT   = LS_DEV_2010
              IT_CHAIN_PRE = LT_PRE_2010
              IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD CREATE_PR_ORDER_MULTY.

    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_PSMNG_C(30) TYPE C.
    DATA : LV_PSMNG TYPE MENGE_D.
    DATA : LV_BANFN TYPE BANFN.
    DATA : LV_RESULT TYPE CHAR01.
    DATA : LV_FIELDNAME TYPE FNAM_____4.
    DATA : LV_POSNR(5) TYPE N.
    DATA : LV_INDEX TYPE I.
    DATA : LV_MATNR TYPE MATNR.

    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
      FROM ZGTPPT1010
      INTO @DATA(LS_EKORG)
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = ' '
       AND FLD_02 = @MV_WERKS.


    REFRESH : MT_BDCDATA, MT_MESSTAB.

    __SETTING_BDC_PARAMS.

    __BDC_DYNPRO 'SAPMM06B' '0100'.
    __BDC_FIELD : 'BDC_OKCODE' '=AB',
                        'EBAN-BSART'  'NB',
                        'RM06B-EEIND' IV_FINDATE,
                        'RM06B-LPEIN' 'T',
                        'EBAN-WERKS' MV_WERKS,
                        'EBAN-EKGRP' LS_EKORG-EKGRP,
                        'EBAN-AFNAM' SY-UNAME.

    CLEAR LV_INDEX.

    LOOP AT CT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>).
      CLEAR LV_PSMNG_C.
      LV_PSMNG_C = ( <LS_2010>-INLENGTH + <LS_2010>-QLENGTH + <LS_2010>-CLENGTH +
                           <LS_2010>-SLENGTH + <LS_2010>-ELENGTH + <LS_2010>-ADLENGTH )
                         * <LS_2010>-INFACTOR.
      CONDENSE LV_PSMNG_C.

      IF <LS_2010>-REAL_MATNR IS NOT INITIAL AND <LS_2010>-MATNR NE <LS_2010>-REAL_MATNR.
        LV_MATNR = <LS_2010>-REAL_MATNR.
      ELSE.
        LV_MATNR = <LS_2010>-MATNR.
      ENDIF.

      ADD 1 TO LV_INDEX.

      IF LV_INDEX = 1.
        __BDC_DYNPRO 'SAPMM06B' '0106'.
        __BDC_FIELD : 'BDC_OKCODE' '=DETA',
                            'RM06B-TCSELFLAG(01)'  'X',
                            'EBAN-MATNR(01)' LV_MATNR,
                            'EBAN-MENGE(01)' LV_PSMNG_C.

        CASE <LS_2010>-DMORDTY.
          WHEN 'SO'.
            __BDC_FIELD : 'EBAN-KNTTP(01)' 'M'.
        ENDCASE.

      ELSE.
        __BDC_DYNPRO 'SAPMM06B' '0106'.
        __BDC_FIELD : 'BDC_OKCODE' '=DETA',
                            'RM06B-TCSELFLAG(02)'  'X',
                            'EBAN-MATNR(02)' LV_MATNR,
                            'EBAN-MENGE(02)' LV_PSMNG_C.

        CASE <LS_2010>-DMORDTY.
          WHEN 'SO'.
            __BDC_FIELD : 'EBAN-KNTTP(02)' 'M'.
        ENDCASE.


      ENDIF.

      __BDC_DYNPRO 'SAPMM06B' '0102'.
      __BDC_FIELD : 'BDC_OKCODE' '=KN',
                          'EBAN-EKORG'  LS_EKORG-EKORG.


      CASE <LS_2010>-DMORDTY.
        WHEN 'SO'.
          __BDC_DYNPRO 'SAPMM06B' '0505'.
          __BDC_FIELD : 'BDC_OKCODE' '=KWE'.

          __BDC_DYNPRO 'SAPLKACB' '0002'.
          __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
                              'COBL-KDAUF' <LS_2010>-DMORD,
                              'COBL-KDPOS' <LS_2010>-DMLINE.
      ENDCASE.

      LV_POSNR = LV_INDEX * 10.
      <LS_2010>-POSNR = LV_INDEX * 10.

      __BDC_DYNPRO 'SAPMM06B' '0106'.
      __BDC_FIELD : 'BDC_OKCODE' '/00',
                          'RM06B-BNFPO' LV_POSNR .

      __BDC_DYNPRO 'SAPMM06B' '0106'.
      __BDC_FIELD : 'BDC_OKCODE' '=KONF',
                          'RM06B-TCSELFLAG(01)'  'X'.

      __BDC_DYNPRO 'SAPMM06B' '0102'.
      __BDC_FIELD : 'BDC_OKCODE' '=KONF'.

*      특성정보 입력
* 조장 - 총 생산 길이와 동일하게 매핑
      LV_INLENGTH = <LS_2010>-INLENGTH + <LS_2010>-QLENGTH + <LS_2010>-CLENGTH +
                  <LS_2010>-SLENGTH + <LS_2010>-ELENGTH + <LS_2010>-ADLENGTH.
      LV_INLENGTH_C = LV_INLENGTH.
      CONDENSE LV_INLENGTH_C.

      LV_INFACTOR = <LS_2010>-INFACTOR.
      LV_INFACTOR_C = LV_INFACTOR.
      CONDENSE LV_INFACTOR_C.

      __BDC_DYNPRO 'SAPLCEI0' '0109'.
      __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                          'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
                          'RCTMS-MWERT(01)' LV_INLENGTH_C,
                          'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
                          'RCTMS-MWERT(02)' LV_INFACTOR_C.

    ENDLOOP.

    __BDC_DYNPRO 'SAPMM06B' '0106'.
    __BDC_FIELD : 'BDC_OKCODE' '=BU'.


    __BDC_TRANSACTION 'ME51'.

    LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                           AND MSGID = '06'
                                                           AND MSGNR = '402'.
      DATA(LV_CHK_SUCESS) = ABAP_TRUE.
      LOOP AT CT_2010 ASSIGNING <LS_2010>.
        <LS_2010>-ORDNR = LS_MESSTAB-MSGV1.
        <LS_2010>-ORDTY = 'PR'.

        APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
        <LS_BANFN>-BANFN = <LS_2010>-ORDNR.
        <LS_BANFN>-BNFPO = <LS_2010>-POSNR + 0.
      ENDLOOP.

    ENDLOOP.

    IF LV_CHK_SUCESS IS INITIAL.
      RV_RESULT = 'E'.
    ELSE.
      RV_RESULT = 'S'.
      COMMIT WORK AND  WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD CHANGE_TANDEM_ARBPL.

    DATA : LT_1010 TYPE TABLE OF ZGTPPT1010.
    DATA : LT_ARBPL TYPE RANGE OF CRHD-ARBPL.
    DATA : LT_AUFNR TYPE RANGE OF AUFNR.
    DATA : LT_MATNR TYPE RANGE OF MATNR.
    DATA : LV_CHK_ERR TYPE CHAR01.

    LT_AUFNR = VALUE #( FOR LW_2010 IN IT_2010 WHERE ( ORDNR IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).

    IF LT_AUFNR IS INITIAL.
      RETURN.
    ENDIF.

    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

    LT_MATNR = VALUE #( FOR LW_2010 IN IT_2010 WHERE ( MATNR IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).

    IF LT_MATNR IS INITIAL.
      RETURN.
    ENDIF.

    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

    CASE IV_GUBUN.
      WHEN 'C'.
* 탐뎀 구성을 위한 기준정보 추출
        SELECT * FROM ZGTPPT1010
          INTO TABLE LT_1010
         WHERE MODULE_KIND = 'PP'
           AND CODEGRP = '1060'
           AND FLD_02 = MV_WERKS
           AND FLD_07 = 'Y'.

        IF LT_1010[] IS INITIAL.
          RETURN.
        ENDIF.

        LT_ARBPL = VALUE #( FOR LW_1010 IN LT_1010 WHERE ( FLD_04 IS NOT INITIAL )
                                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

        SORT LT_ARBPL BY LOW.
        DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING LOW.

        SELECT DISTINCT
          A~AUFNR, F~KTEXT, E~ARBPL, B~APLFL AS PLNFL
         FROM AFKO         AS A
         INNER JOIN AFVC   AS B
                                 ON B~AUFPL = A~AUFPL
         INNER JOIN CRHD  AS E
                                 ON E~OBJID = B~ARBID
         INNER JOIN CRTX   AS F
                                 ON F~OBJID = E~OBJID
                                AND F~OBJTY = E~OBJTY
         WHERE A~AUFNR IN @LT_AUFNR
          AND E~ARBPL IN @LT_ARBPL
          AND  F~SPRAS = @SY-LANGU
         INTO TABLE @DATA(LT_MOSU_ARBPL).

        SORT LT_MOSU_ARBPL BY PLNFL.

        LOOP AT IT_2010 INTO DATA(LS_2010).
          READ TABLE LT_MOSU_ARBPL INTO DATA(LS_MOSU_ARBPL) WITH KEY AUFNR = LS_2010-ORDNR.
          CLEAR LV_CHK_ERR.
          LV_CHK_ERR = CHANGE_BATCH_BDC( IV_PLNFL = LS_MOSU_ARBPL-PLNFL IV_ORDNR = LS_2010-ORDNR ).
        ENDLOOP.

      WHEN 'E'.
        SELECT * FROM ZGTCVROUTING
          INTO TABLE @DATA(LT_ROUTING)
         WHERE MATNR IN @LT_MATNR
            AND WERKS = @MV_WERKS.

        SORT LT_ROUTING BY MATNR PLNFL.

        SELECT DISTINCT
          A~AUFNR, F~KTEXT, E~ARBPL, B~APLFL AS PLNFL
         FROM AFKO         AS A
         INNER JOIN AFVC   AS B
                                 ON B~AUFPL = A~AUFPL
         INNER JOIN CRHD  AS E
                                 ON E~OBJID = B~ARBID
         INNER JOIN CRTX   AS F
                                 ON F~OBJID = E~OBJID
                                AND F~OBJTY = E~OBJTY
         WHERE A~AUFNR IN @LT_AUFNR
          AND  F~SPRAS = @SY-LANGU
         INTO CORRESPONDING FIELDS OF TABLE @LT_MOSU_ARBPL.

        LOOP AT IT_2010 INTO LS_2010.
          READ TABLE LT_ROUTING INTO DATA(LS_ROUTING) WITH KEY MATNR = LS_2010-MATNR.

          READ TABLE LT_MOSU_ARBPL INTO LS_MOSU_ARBPL WITH KEY AUFNR = LS_2010-ORDNR
                                                                                           ARBPL = LS_ROUTING-ARBPL.
          CLEAR LV_CHK_ERR.
          LV_CHK_ERR = CHANGE_BATCH_BDC( IV_PLNFL = LS_MOSU_ARBPL-PLNFL IV_ORDNR = LS_2010-ORDNR ).
        ENDLOOP.

    ENDCASE.


  ENDMETHOD.


  METHOD CHECK_PACK_SET_MENGE.

    DATA :LV_VBELN TYPE VBAK-VBELN.
    DATA :LV_POSNR TYPE VBAP-POSNR.
    DATA : LV_PACK_YN TYPE CHAR10.
    DATA : LV_PACK_NO TYPE MATNR.
    DATA : LV_PACK_DM TYPE MATNR.
    DATA : LV_PACK_TYPE TYPE CHAR10.
    DATA : LV_AUFNR TYPE AUFNR.
    DATA : LV_DISPO TYPE MARC-DISPO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IS_2010-DMORD
      IMPORTING
        OUTPUT = LV_VBELN.

    LV_POSNR = IS_2010-DMLINE + 0.

    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
        IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
      IMPORTING
        EV_PACK_YN    = LV_PACK_YN
        EV_PACK_NO    = LV_PACK_NO
        EV_PACK_TYPE  = LV_PACK_TYPE
        EV_PACK_DM = LV_PACK_DM
    ).

    IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL.  " 포장재 지정상태와 드럼유형만 대상
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IS_2010-ORDNR
        IMPORTING
          OUTPUT = LV_AUFNR.

      LV_PACK_NO = LV_PACK_DM.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = LV_PACK_NO
        IMPORTING
          OUTPUT       = LV_PACK_NO
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.
      IF SY-SUBRC <> 0.
      ENDIF.


      SELECT B~*
        FROM AFKO AS A
        INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
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
        SELECT SINGLE DISPO FROM MARC
          INTO LV_DISPO
         WHERE MATNR = LV_PACK_NO
           AND WERKS = MV_WERKS.

        SELECT B~*
                FROM AFKO AS A
                INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
               INNER JOIN MARA AS C ON C~MATNR = B~MATNR
               INNER JOIN MARC AS D ON D~MATNR = B~MATNR
                                             AND D~WERKS = @MV_WERKS
               WHERE A~AUFNR = @LV_AUFNR
                 AND C~MTART LIKE 'MRM%'
                 AND D~DISPO = @LV_DISPO
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


  METHOD CHG_PACK_COFIRM.

    IF MV_WERKS = '6500'. " 군포는 조장체인저장후 목드럼재지정 프로그램 수행으로 처리
      MV_CALL_DRUM = ABAP_TRUE.
      RETURN.
    ENDIF.

    DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
    DATA : LT_2010_CURRNT TYPE TABLE OF ZGTPPT2010.
    DATA : LT_2010_SORT_ORD TYPE TABLE OF ZGTPPT2010.
    DATA : BEGIN OF LS_POJANG_SET,
             MATNR TYPE MATNR,
             MENGE TYPE MENGE_D,
           END OF LS_POJANG_SET.
    DATA : LT_POJANG_SET LIKE TABLE OF LS_POJANG_SET.
    DATA : LV_VBELN TYPE VBAP-VBELN.
    DATA : LV_POSNR TYPE VBAP-POSNR.
    DATA : LV_AUFNR TYPE AFKO-AUFNR.
    DATA : LV_PACK_YN TYPE CHAR10.
    DATA : LV_PACK_NO TYPE MATNR.
    DATA : LV_PACK_DM TYPE MATNR.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_TABIX TYPE I.
    DATA : LV_CHK_EXIST.

* 바피 object
    DATA : LS_RETURN TYPE COXT_BAPIRETURN.
    DATA : LT_RESBKEYS TYPE COXT_T_RESBDEL,
           LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
           LV_ERROR    TYPE FLAG.

    DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
    DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
    DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
    DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.


    LT_2010 = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( ( DMORDTY = 'SM'
                                                     OR     DMORDTY = 'SO' )
                                                    AND   ORDTY = 'PRD' )
                              ( CORRESPONDING #( LW_2010 ) ) ).

    LT_2010_SORT_ORD = LT_2010.
    SORT LT_2010_SORT_ORD BY ORDNR.
    DELETE ADJACENT DUPLICATES FROM LT_2010_SORT_ORD COMPARING ORDNR.

    LOOP AT LT_2010_SORT_ORD INTO DATA(LS_SORT).
      READ TABLE MT_MAKED_2010 INTO DATA(LS_CHK_PRD) WITH KEY GONG_SEQ = LS_SORT-GONG_SEQ
                                                                              ORDNR = LS_SORT-ORDNR
                                                                              POSNR = LS_SORT-POSNR
                                                                              CHK_PRD = ABAP_TRUE.
      IF SY-SUBRC EQ 0. " 생산중인 오더는 대상이 아닙니다.
        CONTINUE.
      ENDIF.

      REFRESH LT_2010_CURRNT.
      LT_2010_CURRNT = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( GONG_SEQ = LS_SORT-GONG_SEQ
                                              AND   ORDNR = LS_SORT-ORDNR )
                        ( CORRESPONDING #( LW_2010 ) ) ).

*   - 포장재 재지정상태 확인.
      SELECT B~*
        FROM AFKO AS A
        INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
       INNER JOIN MARA AS C ON C~MATNR = B~MATNR
       WHERE A~AUFNR = @LS_SORT-ORDNR
         AND B~SORTF = '1'
         AND B~XLOEK = ''
         AND C~MTART LIKE 'MRM%'
         INTO TABLE @LT_RESB.
      IF SY-SUBRC EQ 0. " 해당 생산오더 판매오더가 재 지정되었다는 의미이므로 해당 오더 전체 품목건 포장재 OK
        CONTINUE.
      ENDIF.

      REFRESH LT_POJANG_SET.
      CLEAR : LV_VBELN, LV_POSNR, LV_AUFNR.

      LV_AUFNR = LS_SORT-ORDNR.

      IF LS_SORT-MULTY_REF = ABAP_TRUE. " 팩터배치건 복조장일시 포장재 한건에 수량만 오더수만큼 적용.
        IF LS_SORT-DMORDTY = 'SO'.

          LV_VBELN = LS_SORT-DMORD.
          LV_POSNR = LS_SORT-DMLINE.

          ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
            EXPORTING
              IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
              IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
            IMPORTING
              EV_PACK_YN    = LV_PACK_YN
              EV_PACK_NO    = LV_PACK_NO
              EV_PACK_DM  = LV_PACK_DM ).

          IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
              EXPORTING
                INPUT        = LV_PACK_DM
              IMPORTING
                OUTPUT       = LV_PACK_DM
              EXCEPTIONS
                LENGTH_ERROR = 1
                OTHERS       = 2.

            CLEAR LS_POJANG_SET.
            LS_POJANG_SET-MATNR = LV_PACK_DM.
            LS_POJANG_SET-MENGE = LINES( LT_2010_CURRNT ).
            APPEND LS_POJANG_SET TO LT_POJANG_SET.

            READ TABLE LT_2010_CURRNT ASSIGNING FIELD-SYMBOL(<LS_2010_CURRNT>) WITH KEY ORDNR = LS_SORT-ORDNR
                                                                                        POSNR = LS_SORT-POSNR.
            IF SY-SUBRC EQ 0.
              <LS_2010_CURRNT>-MATNR_DM = LV_PACK_DM.
            ENDIF.

          ELSE.
            CONTINUE.
          ENDIF.

        ELSE.
          CONTINUE.
        ENDIF.

      ELSE.
        IF LINES( LT_2010_CURRNT ) > 1. " 복조장
          LOOP AT LT_2010_CURRNT ASSIGNING <LS_2010_CURRNT>.
            CLEAR : LV_VBELN, LV_POSNR.

            IF <LS_2010_CURRNT>-DMORDTY = 'SO'.

              LV_VBELN = <LS_2010_CURRNT>-DMORD.
              LV_POSNR = <LS_2010_CURRNT>-DMLINE.

              ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
                EXPORTING
                  IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
                  IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
                IMPORTING
                  EV_PACK_YN    = LV_PACK_YN
                  EV_PACK_NO    = LV_PACK_NO
                  EV_PACK_DM  = LV_PACK_DM ).

              IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
                CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                  EXPORTING
                    INPUT        = LV_PACK_DM
                  IMPORTING
                    OUTPUT       = LV_PACK_DM
                  EXCEPTIONS
                    LENGTH_ERROR = 1
                    OTHERS       = 2.

                <LS_2010_CURRNT>-MATNR_DM = LV_PACK_DM.

                CLEAR LS_POJANG_SET.
                LS_POJANG_SET-MATNR = LV_PACK_DM.
                LS_POJANG_SET-MENGE = 1.
                COLLECT LS_POJANG_SET INTO LT_POJANG_SET.
              ELSE.
                CLEAR <LS_2010_CURRNT>-MATNR_DM.
                CONTINUE.
              ENDIF.

            ENDIF.
          ENDLOOP.

        ELSE.
          IF LS_SORT-DMORDTY = 'SO'.

            LV_VBELN = LS_SORT-DMORD.
            LV_POSNR = LS_SORT-DMLINE.

            ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
              EXPORTING
                IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
                IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
              IMPORTING
                EV_PACK_YN    = LV_PACK_YN
                EV_PACK_NO    = LV_PACK_NO
                EV_PACK_DM  = LV_PACK_DM ).

            IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
              CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                EXPORTING
                  INPUT        = LV_PACK_DM
                IMPORTING
                  OUTPUT       = LV_PACK_DM
                EXCEPTIONS
                  LENGTH_ERROR = 1
                  OTHERS       = 2.

              READ TABLE LT_2010_CURRNT ASSIGNING <LS_2010_CURRNT> WITH KEY ORDNR = LS_SORT-ORDNR
                                                                                                        POSNR = LS_SORT-POSNR.
              IF SY-SUBRC EQ 0.
                <LS_2010_CURRNT>-MATNR_DM = LV_PACK_DM.
              ENDIF.

              CLEAR LS_POJANG_SET.
              LS_POJANG_SET-MATNR = LV_PACK_DM.
              LS_POJANG_SET-MENGE = 1.
              APPEND LS_POJANG_SET TO LT_POJANG_SET.
            ELSE.
              READ TABLE LT_2010_CURRNT ASSIGNING <LS_2010_CURRNT> WITH KEY ORDNR = LS_SORT-ORDNR
                                                                                                        POSNR = LS_SORT-POSNR.
              IF SY-SUBRC EQ 0.
                CLEAR <LS_2010_CURRNT>-MATNR_DM.
              ENDIF.

              CONTINUE.
            ENDIF.

          ENDIF.

        ENDIF.
      ENDIF.

      IF LT_POJANG_SET[] IS INITIAL.
        CONTINUE.
      ENDIF.
* 기존 등록된 포장재 수량 확인.
      SELECT B~*
         FROM AFKO AS A
         INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
        INNER JOIN MARA AS C ON C~MATNR = B~MATNR
        WHERE A~AUFNR = @LV_AUFNR
          AND B~XLOEK = ''
          AND C~MTART LIKE 'MRM%'
          INTO TABLE @LT_RESB.

      DATA(LT_RESB_CHK) = LT_RESB.

      CLEAR LV_CHK_EXIST.
      LOOP AT LT_POJANG_SET INTO LS_POJANG_SET.
        READ TABLE LT_RESB_CHK INTO DATA(LS_RESB_CHK) WITH KEY MATNR = LS_POJANG_SET-MATNR.
        IF SY-SUBRC EQ 0.
          LV_TABIX = SY-TABIX.
          IF LS_RESB_CHK-BDMNG = LS_POJANG_SET-MENGE.
            DELETE LT_RESB_CHK INDEX LV_TABIX.
          ENDIF.
        ELSE.
          LV_CHK_EXIST = ABAP_TRUE.
        ENDIF.
      ENDLOOP.

      IF LT_RESB IS NOT INITIAL AND LT_RESB_CHK IS INITIAL AND LV_CHK_EXIST IS INITIAL. " 변경할 내용 없음 종료
        LOOP AT LT_2010_CURRNT INTO DATA(LS_2010_CURRENT).
* 포장재 정보 조장체인테이블에 반영.
          READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>) WITH KEY GONG_CD = LS_2010_CURRENT-GONG_CD
                                                                                                             ORDNR = LS_2010_CURRENT-ORDNR
                                                                                                             POSNR = LS_2010_CURRENT-POSNR
                                                                                                             ORDTY = LS_2010_CURRENT-ORDTY.
          IF SY-SUBRC EQ 0.
            IF <LS_NEW_2010>-MATNR_DM NE LS_2010_CURRENT-MATNR_DM.
              <LS_NEW_2010>-MATNR_DM = LS_2010_CURRENT-MATNR_DM.
            ENDIF.
          ENDIF.
        ENDLOOP.

        CONTINUE.
      ENDIF.


* 기존 포장재 삭제 작업
      SELECT B~RSNUM, B~RSPOS
         FROM AFKO AS A
         INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
        INNER JOIN MARA AS C ON C~MATNR = B~MATNR
        WHERE A~AUFNR = @LV_AUFNR
          AND B~XLOEK = ''
          AND C~MTART LIKE 'MRM%'
          INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
      IF SY-SUBRC EQ 0.

        REFRESH : LT_RESBKEYS, LT_RETURN.
        CLEAR : LV_ERROR, LS_RETURN.

        IF SY-SUBRC EQ 0.
          LT_RESBKEYS = CORRESPONDING #( LT_RESB ).
        ENDIF.

* BAPI to delete the components of Production Order
        CALL FUNCTION 'CO_XT_COMPONENTS_DELETE'
          EXPORTING
            IT_RESBKEYS_TO_DELETE = LT_RESBKEYS
          IMPORTING
            E_ERROR_OCCURRED      = LV_ERROR
          TABLES
            CT_BAPIRETURN         = LT_RETURN
          EXCEPTIONS
            DELETE_FAILED         = 1
            OTHERS                = 2.

        PERFORM CHANGE_FLAG_SET IN PROGRAM  SAPLCOZV.

        CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.
        IF LV_ERROR = SPACE.
          CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
            IMPORTING
              ES_BAPIRETURN    = LS_RETURN
              E_ERROR_OCCURRED = LV_ERROR.
          IF ( LS_RETURN-TYPE = 'S' OR
               LS_RETURN-TYPE = 'W' OR
               LS_RETURN-TYPE = 'I' ) OR
               LS_RETURN IS INITIAL.

            COMMIT WORK AND WAIT.
            WAIT UP TO '0.3' SECONDS.

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

* 드럼추가

      SELECT SINGLE B~APLZL, B~PLNFL
        INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
        FROM AFKO AS A
       INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
       WHERE A~AUFNR EQ @LV_AUFNR
          AND B~APLFL = '000000'
          AND B~RUECK NE ''.

      LOOP AT LT_POJANG_SET INTO LS_POJANG_SET.

        CLEAR : LS_REQU_QUAN, LV_STORAGE_LOCATION, LV_STORAGE_LOCATIONX, LV_POSNO, LS_RETURN, LV_ERROR.

        SELECT SINGLE MEINS FROM MARA
          INTO @DATA(LV_MEINS)
         WHERE MATNR = @LS_POJANG_SET-MATNR.


        LS_REQU_QUAN-QUANTITY = LS_POJANG_SET-MENGE.
        LS_REQU_QUAN-UOM = LV_MEINS.

        LV_STORAGE_LOCATION-WERKS = MV_WERKS.
        LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.

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
            I_MATERIAL           = LS_POJANG_SET-MATNR
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
            IF <LV_MATNR> = LS_POJANG_SET-MATNR.

              ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_POSNR>).
              <LV_POSNR> = LV_POSNO.
*              ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_RGEKZ>).
*              <LV_RGEKZ> = ABAP_TRUE.
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
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.

            WAIT UP TO '0.3' SECONDS.

            CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.


            LOOP AT LT_2010_CURRNT INTO LS_2010_CURRENT.
* 포장재 정보 조장체인테이블에 반영.
              READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY GONG_CD = LS_2010_CURRENT-GONG_CD
                                                                                                   ORDNR = LS_2010_CURRENT-ORDNR
                                                                                                   POSNR = LS_2010_CURRENT-POSNR
                                                                                                   ORDTY = LS_2010_CURRENT-ORDTY.
              IF SY-SUBRC EQ 0.
                <LS_NEW_2010>-MATNR_DM = LS_2010_CURRENT-MATNR_DM.
              ENDIF.
            ENDLOOP.


          ELSE.
            CLEAR: LV_ERROR,
                   LS_RETURN.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
        ELSE.
          CLEAR LV_ERROR.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD CHK_BWD_QUANTITY_DIFFERENCE.

    DATA : LT_MATNR TYPE RANGE OF MATNR.
    DATA : BEGIN OF LS_SUM_MATNR,
             GONG_CD TYPE ZGTPPT2010-GONG_CD,
             MATNR   TYPE ZGTPPT2010-MATNR,
             GAMNG   TYPE MENGE_D,
           END OF LS_SUM_MATNR.
    DATA : LT_SUM_BWD LIKE TABLE OF LS_SUM_MATNR.
    DATA : LT_SUM_JOJANG LIKE TABLE OF LS_SUM_MATNR.
    DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
    DATA : LV_MENGE TYPE MENGE_D.
    DATA : LV_MENGE_C TYPE CHAR20.
    DATA : LV_NUM(2) TYPE N.

    SELECT DISTINCT * FROM ZGTPPT2013
      INTO TABLE @DATA(LT_2013)
     WHERE GRPNR = @MV_GRPNR.

    IF LT_2013[] IS NOT INITIAL.
      LT_MATNR = VALUE #( FOR LW_2013 IN LT_2013 WHERE ( MATNR IS NOT INITIAL )
                                   ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-MATNR ) ).
      SORT LT_MATNR BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

      LT_2010 = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( GRPNR = MV_GRPNR
                                                                           AND   MATNR IN LT_MATNR
                                                                           AND   ORDTY NE 'PLN' )
                               ( CORRESPONDING #( LW_2010 ) ) ).

      SORT LT_2010 BY ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING ORDNR POSNR ORDTY.

*    신선작업지시에 등록된 자재별 수량 섬
      LOOP AT LT_2013 INTO DATA(LS_2013).
        CLEAR LS_SUM_MATNR.
        LS_SUM_MATNR-MATNR = LS_2013-MATNR.
        LS_SUM_MATNR-GAMNG = LS_2013-INLENGTH.
        COLLECT LS_SUM_MATNR INTO LT_SUM_BWD.
      ENDLOOP.

*    조장체인으로 저장될 해당 자재의 구성수량 섬
      LOOP AT LT_2010 INTO DATA(LS_2010).
        CLEAR LS_SUM_MATNR.
        LS_SUM_MATNR-MATNR = LS_2010-MATNR.
        LS_SUM_MATNR-GAMNG = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-SLENGTH +
                                              LS_2010-CLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                                            * LS_2010-INFACTOR.
        COLLECT LS_SUM_MATNR INTO LT_SUM_JOJANG.
      ENDLOOP.

      LOOP AT LT_SUM_BWD INTO LS_SUM_MATNR.

        READ TABLE LT_SUM_JOJANG INTO DATA(LS_SUM_JOJANG) WITH KEY MATNR = LS_SUM_MATNR-MATNR.
        IF SY-SUBRC EQ 0 AND LS_SUM_JOJANG-GAMNG > LS_SUM_MATNR-GAMNG.
          CLEAR : LV_MENGE, LV_MENGE_C, LV_NUM.
          LV_MENGE = LS_SUM_JOJANG-GAMNG - LS_SUM_MATNR-GAMNG.
          LV_MENGE_C = LV_MENGE.
          CONDENSE LV_MENGE_C.

          READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY CHART = LS_SUM_JOJANG-GONG_CD.
          LV_NUM = MS_SEQ_ROUTING_HEADER-SEQNO + 0.

          APPEND INITIAL LINE TO MT_MESSAGE_BWD ASSIGNING FIELD-SYMBOL(<LV_MESSAGE>).
          <LV_MESSAGE> = |조장내 공정({ LV_NUM }_{ MS_SEQ_ROUTING_HEADER-CHART_VAL }) 의 오더 수량 합이 신선재 작업지시 등록된 길이보다 { LV_MENGE_C }(M)  초과 되었습니다.|.
        ENDIF.

      ENDLOOP.

      IF MT_MESSAGE_BWD[] IS NOT INITIAL.
        APPEND INITIAL LINE TO MT_MESSAGE_BWD ASSIGNING <LV_MESSAGE>.
        <LV_MESSAGE> = '★ 신선재 작업지시 반드시 확인 바랍니다.'.
      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD CREATE_PURCHASE_REQUEST.

    DATA : LV_RETURN TYPE CHAR01.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).

    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    LOOP AT IT_2010 INTO DATA(LS_2010).
      LV_RETURN = CREATE_PURCHASE_REQUEST_SINGLE( IS_2010 = LS_2010 ).
      IF LV_RETURN = 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_RETURN = 'E'.
      LOOP AT MT_NEW_PLAN_ORDERS INTO DATA(LS_PLAN).
        LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      ENDLOOP.

      LV_RETURN = DELETE_PR_ORDER( ).
      IF LV_RETURN = ABAP_TRUE.
        APPEND INITIAL LINE TO MT_TOT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
        <LS_MESSAGE>-MSGTYP = 'E'.
        <LS_MESSAGE>-MSGV1 = |오류로 인한 구매요청 삭제중 오류발생하였습니다.|.
      ENDIF.

      RV_RESULT = 'E'.
      RETURN.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 80  IV_TEXT = '구매요청 생성완료. 오더정보 변경중..' ).

    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
      ENDCASE.
    ENDLOOP.

    LOOP AT MT_PLAN_ORDERS INTO LS_PLAN.
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        RV_RESULT = 'E'.
      ENDIF.
    ENDLOOP.

    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        RV_RESULT = 'E'.
      ENDIF.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).
    CONFIRM( ).

  ENDMETHOD.


  METHOD CREATE_PURCHASE_REQUEST_SINGLE.

    DATA : LT_BACKUP_2010 LIKE TABLE OF MS_2010.
    DATA : LT_RESB_2010 LIKE TABLE OF MS_2010.
    DATA : LV_CRT_SEQ TYPE I.
    DATA : LV_CRT_SEQ_C(10).
    DATA : LV_CHK_CREATE.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LS_2010_NEW LIKE MS_2010.
    DATA : LT_2010_INPUT LIKE TABLE OF MS_MAKED_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LV_TABIX TYPE I.
    DATA : LT_BACKUP_PLAN_ORDERS TYPE MRPDS_PLONO .
    DATA : LV_FINDATE TYPE SY-DATUM.

    IF MT_PLAN_ORDERS IS NOT INITIAL.
      MOVE-CORRESPONDING MT_PLAN_ORDERS TO LT_BACKUP_PLAN_ORDERS.
    ENDIF.

    LOOP AT MT_MAKED_2010 INTO DATA(LS_TEMP) WHERE ORDNR = IS_2010-ORDNR.
      APPEND LS_TEMP TO  LT_2010_INPUT.
    ENDLOOP.

    READ TABLE MT_INFNR_INFOR INTO MS_INFNR_INFOR WITH KEY MATNR = IS_2010-MATNR.

    GET_FINDATE(
      EXPORTING
        IV_ORDNR   = IS_2010-DMORD  " 오더번호
        IV_ORDTY   = IS_2010-DMORDTY" 오더유형
    IMPORTING
      EV_FINDATE = LV_FINDATE  ).               " ABAP system field: Current date of application server

* 납기요청일 세팅
    MS_INFNR_INFOR-EEIND =  LV_FINDATE.

    LV_CHK_CREATE = ABAP_TRUE.

    DO. " 생성할수 있는 오더 전부 생성후 종료

      IF LV_CHK_CREATE IS INITIAL.
        EXIT.
      ENDIF.

      CLEAR LV_CHK_CREATE.
      CLEAR LS_2010.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LV_RETURN.

      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

        READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_CURRNET_ROUTING) WITH KEY GONG_SEQ = IS_2010-GONG_SEQ.
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG_CURRENT>) WITH KEY SEQNO = LS_CURRNET_ROUTING-SEQNO.

        READ TABLE <LS_GONG_CURRENT>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN_CURRENT>)  WITH KEY ORDNR = IS_2010-ORDNR
                                                                                                                                              POSNR = IS_2010-POSNR.
        IF SY-SUBRC EQ 0.

          LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ < IS_2010-GONG_SEQ.
            READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
            IF SY-SUBRC EQ 0.
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>).
                IF <LS_CHAIN>-ORDNR IS INITIAL.
                  CASE <LS_CHAIN>-DMORDTY.
                    WHEN 'SM' OR 'SO'." 해당 오더가 완제품 공정일경우 체크없음
                      LS_2010-ORDNR = <LS_MAIN>-END_ORDNR.
                      LS_2010-POSNR = <LS_MAIN>-END_POSNR.
                      LS_2010-ORDTY = <LS_MAIN>-END_ORDTY.
                      LS_2010-ETC_SEQ = <LS_MAIN>-END_SEQNO.
                      LS_2010-GONG_SEQ = <LS_GONG>-GONG_SEQ.
                      LS_2010-MATNR_SEQ = 1.
                      LS_2010-MATNR = <LS_MAIN>-MATNR.
                      LV_CHK_CREATE = ABAP_TRUE.
                      LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                      LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                      EXIT.

                    WHEN 'PRD'. " 현재는 생산 오더만 체크
                      CLEAR MS_MAKED_2010.
                      READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                                      POSNR = <LS_CHAIN>-DMLINE
                                                                                                      ORDTY = <LS_CHAIN>-DMORDTY.
                      IF SY-SUBRC EQ 0.
                        IF <LS_CHAIN>-CHK_DUP = ABAP_TRUE.
                          READ TABLE MT_MAKED_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = MS_MAKED_2010-REORD
                                                                                                    POSNR = MS_MAKED_2010-RELINE
                                                                                                    ORDTY = MS_MAKED_2010-REORDTY.
                          IF SY-SUBRC EQ 0. " 해당오더 이전 공정 존재시 생성 대상 아님
                            CONTINUE.
                          ENDIF.
                        ENDIF.

                        CASE  MS_MAKED_2010-STATUS.
                          WHEN 'C'. " 신규 생성된 오더 이므로 처리가능
                            MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                            LV_CHK_CREATE = ABAP_TRUE.
                            LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                            LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                            EXIT.
                          WHEN 'E'. "오류 이므로 처리 불가능.
* 일단은 건너띄고 혼자만 남았을경우 에러로 사전 처리됨
                          WHEN 'R'. " 가동중인 오더 제외0
                            IF MS_MAKED_2010-CHK_PRD IS INITIAL.
                              MOVE-CORRESPONDING MS_MAKED_2010 TO LS_2010.
                              LV_CHK_CREATE = ABAP_TRUE.
                              LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                              LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                              EXIT.
                            ENDIF.
                        ENDCASE.

                      ENDIF.

                    WHEN 'PLN'.
                      READ TABLE MT_NEW_2010 INTO LS_2010 WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                              POSNR = <LS_CHAIN>-DMLINE
                                                                                              ORDTY = <LS_CHAIN>-DMORDTY.
                      IF SY-SUBRC EQ 0.
                        LV_CHK_CREATE = ABAP_TRUE.
                        LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
                        LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
                        EXIT.
                      ENDIF.
                    WHEN OTHERS. " 현재 적용사항 없음. 차후 적용예정

                  ENDCASE.
                ENDIF.
              ENDLOOP.
              IF LV_CHK_CREATE IS NOT INITIAL.
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF LV_CHK_CREATE IS NOT INITIAL.
            EXIT.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF LV_CHK_CREATE = ABAP_TRUE.

        READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.

        LV_RETURN = CREATE_PLAN_ORDER(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_DEV_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
            LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
          ENDLOOP.
          RV_RESULT = 'E'.
          RETURN.
        ENDIF.

      ENDIF.

    ENDDO.

    IF MT_PLAN_ORDERS IS NOT INITIAL.
      APPEND LINES OF MT_PLAN_ORDERS TO MT_NEW_PLAN_ORDERS.
    ENDIF.

    IF LT_BACKUP_PLAN_ORDERS IS NOT INITIAL.
      REFRESH MT_PLAN_ORDERS.
      APPEND LINES OF LT_BACKUP_PLAN_ORDERS TO MT_PLAN_ORDERS.
    ENDIF.

* 선택공정 이전의 정보들은 남겨둔다.
    DATA : LS_CHAIN LIKE MS_CHAIN_2010.
    DATA : LT_CHAIN LIKE MT_CHAIN_2010.
    DATA : LT_PRE_CHAIN LIKE MT_CHAIN_2010.

    LOOP AT MT_MAKE_DISPLAY ASSIGNING <LS_MAIN>.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_CURRNET_ROUTING WITH KEY GONG_SEQ = IS_2010-GONG_SEQ.
      READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG_CURRENT> WITH KEY SEQNO = LS_CURRNET_ROUTING-SEQNO.

      READ TABLE <LS_GONG_CURRENT>-T_CHAIN ASSIGNING <LS_CHAIN_CURRENT>  WITH KEY ORDNR = IS_2010-ORDNR
                                                                                                                         POSNR = IS_2010-POSNR.
      IF SY-SUBRC EQ 0.
        APPEND <LS_CHAIN_CURRENT> TO LT_CHAIN.
        APPEND <LS_CHAIN_CURRENT> TO LT_PRE_CHAIN.

        DO.
          IF LT_PRE_CHAIN IS INITIAL.
            EXIT.
          ENDIF.
          REFRESH LT_PRE_CHAIN.

          LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ <= LS_CURRNET_ROUTING-SEQNO.
            READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG> WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
            IF SY-SUBRC EQ 0.
              LOOP AT <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN>.
                READ TABLE LT_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_CHAIN>-DMORD
                                                                                              POSNR = <LS_CHAIN>-DMLINE.
                IF SY-SUBRC EQ 0.
                  READ TABLE LT_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_CHAIN>-ORDNR
                                                                                               POSNR = <LS_CHAIN>-POSNR.
                  IF SY-SUBRC NE 0.
                    APPEND <LS_CHAIN> TO LT_PRE_CHAIN.

                    IF <LS_GONG>-GONG_SEQ <= MS_INFNR_INFOR-GONG_SEQ.
                      READ TABLE MT_NEW_2010 INTO DATA(LS_BACK_UP) WITH KEY GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                                         ORDNR = <LS_CHAIN>-ORDNR
                                                                                                        POSNR = <LS_CHAIN>-POSNR
                                                                                                        ORDTY = <LS_CHAIN>-ORDTY.
                      IF SY-SUBRC EQ 0.
                        APPEND LS_BACK_UP TO LT_BACKUP_2010.
                      ENDIF.
                    ENDIF.

                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDLOOP.

          IF LT_PRE_CHAIN IS NOT INITIAL.
            APPEND LINES OF LT_PRE_CHAIN TO LT_CHAIN.
          ENDIF.

        ENDDO.
      ENDIF.
    ENDLOOP.


* 체인구성을 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT LT_2010_INPUT INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING <LS_MAIN>.
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING <LS_GONG> WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING <LS_CHAIN> WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                              POSNR = LS_CHK_2010-POSNR
                                                                                              ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RESULT = 'E'.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


*  구매오더 생성
    REFRESH LT_RESB_2010.
    LT_RESB_2010 = VALUE #( FOR LW_2010 IN LT_BACKUP_2010 WHERE ( GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ )
                                      ( CORRESPONDING #( LW_2010 ) ) ).

    IF LT_RESB_2010 IS INITIAL.
      CLEAR LS_2010.
      MOVE-CORRESPONDING IS_2010 TO LS_2010.
      APPEND LS_2010 TO LT_RESB_2010.
    ENDIF.

    DATA : LV_BANFN TYPE BANFN.

    LV_BANFN = CRT_PURCHASE_REQUEST(
                  IT_2010      = LT_2010_INPUT ).

    IF LV_BANFN IS INITIAL.
      RV_RESULT = 'E'.
      RETURN.
    ENDIF.

    DATA : LV_BNFPO TYPE BNFPO.

*  생성된 구매요청 정보로 체인구성
    LOOP AT LT_2010_INPUT INTO LS_2010.
      ADD 10 TO LV_BNFPO.
*     이후공정 체인 구성
      LOOP AT  MT_MAKED_2010 INTO MS_MAKED_2010 WHERE REORD = LS_2010-ORDNR
                                                                          AND RELINE = LS_2010-POSNR
                                                                          AND REORDTY = LS_2010-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_SET>) WITH KEY ORDNR = MS_MAKED_2010-ORDNR
                                                                                                     POSNR = MS_MAKED_2010-POSNR
                                                                                                     ORDTY = MS_MAKED_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_DEV_SET>-REORD = LV_BANFN.
          <LS_DEV_SET>-RELINE = LV_BNFPO + 0.
          <LS_DEV_SET>-REORDTY = 'UPR'.
        ENDIF.

      ENDLOOP.
*     현재공정 체인 구성
      LS_2010-ORDNR = LV_BANFN.
      LS_2010-POSNR = LV_BNFPO + 0.
      LS_2010-ORDTY = 'UPR'.
      APPEND LS_2010 TO MT_NEW_2010.

*     이전공정 체인 구성(선택공정까지 po로 전부 세팅)
      LOOP AT MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WHERE GONG_SEQ < LS_2010-GONG_SEQ.
        IF MS_INFNR_INFOR-GONG_SEQ > MS_SEQ_ROUTING_HEADER-GONG_SEQ.
          EXIT.
        ENDIF.

        CLEAR LS_2010_NEW.
        MOVE-CORRESPONDING LS_2010 TO LS_2010_NEW.
        LS_2010_NEW-GONG_CD = MS_SEQ_ROUTING_HEADER-CHART.
        LS_2010_NEW-GONG_SEQ = MS_SEQ_ROUTING_HEADER-GONG_SEQ.
        LS_2010_NEW-DMORD = LS_2010_NEW-ORDNR.
        LS_2010_NEW-DMLINE = LS_2010_NEW-POSNR.
        LS_2010_NEW-DMORDTY = LS_2010_NEW-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING <LS_DEV_SET> WITH KEY GONG_SEQ = LS_2010-GONG_SEQ
                                                                                        ORDNR = LS_2010-ORDNR
                                                                                        POSNR = LS_2010-POSNR
                                                                                        ORDTY = LS_2010-ORDTY.

        IF SY-SUBRC EQ 0.
          <LS_DEV_SET>-REORD = LS_2010-ORDNR.
          <LS_DEV_SET>-RELINE = LS_2010-POSNR.
          <LS_DEV_SET>-REORDTY = LS_2010-ORDTY.
        ENDIF.
        APPEND LS_2010_NEW TO MT_NEW_2010.

        MOVE-CORRESPONDING LS_2010_NEW TO LS_2010.

      ENDLOOP.

    ENDLOOP.

*     이전공정 체인 구성(선택공정 이전)
    DELETE LT_BACKUP_2010 WHERE GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ.
    LOOP AT LT_BACKUP_2010 ASSIGNING FIELD-SYMBOL(<LS_BACKUP>).
* 오더 삭제 테이블에서 제외
      CASE <LS_BACKUP>-ORDTY.
        WHEN 'PLN'.
          DELETE MT_PLAN_ORDERS WHERE TABLE_LINE = <LS_BACKUP>-ORDNR.
        WHEN 'PRD'.
          DELETE MT_PRD_ORDERS WHERE ORDER_NUMBER = <LS_BACKUP>-ORDNR.
        WHEN 'PO'.
          DELETE MT_PO_ORDERS WHERE EBELN = <LS_BACKUP>-ORDNR.
        WHEN 'PR' OR 'UPR'.
          DELETE MT_PO_ORDERS WHERE EBELN = <LS_BACKUP>-ORDNR.
      ENDCASE.
      DELETE MT_DEL_2010 WHERE GONG_SEQ = <LS_BACKUP>-GONG_SEQ
                                    AND ORDNR = <LS_BACKUP>-ORDNR
                                    AND POSNR = <LS_BACKUP>-POSNR
                                    AND ORDTY = <LS_BACKUP>-ORDTY.

      READ TABLE MT_MAKED_2010 INTO MS_MAKED_2010 WITH KEY ORDNR = <LS_BACKUP>-DMORD
                                                                                   POSNR = <LS_BACKUP>-DMLINE
                                                                                   ORDTY = <LS_BACKUP>-DMORDTY.
      IF SY-SUBRC EQ 0.
        IF MS_MAKED_2010-GONG_SEQ BETWEEN MS_INFNR_INFOR-GONG_SEQ AND IS_2010-GONG_SEQ.
          <LS_BACKUP>-DMORD = LV_BANFN.
          <LS_BACKUP>-DMLINE = 10 + 0.
          <LS_BACKUP>-DMORDTY = 'UPR'.

          IF <LS_BACKUP>-MATNR_SEQ = 1.

            IF MS_INFNR_INFOR-GONG_SEQ = MS_MAKED_2010-GONG_SEQ.

              LOOP AT MT_NEW_2010 ASSIGNING <LS_DEV_SET> WHERE GONG_SEQ = MS_INFNR_INFOR-GONG_SEQ
                                                                                         AND ORDNR = LS_2010-ORDNR
                                                                                         AND ORDTY = LS_2010-ORDTY.

                <LS_DEV_SET>-REORD = <LS_BACKUP>-ORDNR.
                <LS_DEV_SET>-RELINE = <LS_BACKUP>-POSNR.
                <LS_DEV_SET>-REORDTY = <LS_BACKUP>-ORDTY.

              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    APPEND LINES OF LT_BACKUP_2010 TO MT_NEW_2010.

  ENDMETHOD.


  METHOD CRT_PURCHASE_REQUEST.

    DATA : LS_PR_INFOR TYPE ZGTPPS0004.
    DATA : LT_CHART TYPE ZGTPPY0005.
    DATA : LV_INLENGTH TYPE I.
    DATA : LV_INLENGTH_C(10) TYPE C.
    DATA : LV_INFACTOR TYPE I.
    DATA : LV_INFACTOR_C(10) TYPE C.
    DATA : LV_PSMNG_C(30) TYPE C.
    DATA : LV_PSMNG TYPE MENGE_D.
    DATA : LV_BANFN TYPE BANFN.
    DATA : LV_RESULT TYPE CHAR01.
    DATA : LV_NUM(2) TYPE N.
    DATA : LV_NUM2(2) TYPE N.
    DATA : LV_FIELDNAME TYPE FNAM_____4.

*  구매조직 관련 스트럭처
    DATA : BEGIN OF LS_EKORG,
             WEREKS TYPE WERKS_D,
             EKORG  TYPE EKORG,
             EKGRP  TYPE EKGRP,
           END OF LS_EKORG.

    CLEAR LS_EKORG.
    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @LS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = 'L'
     AND FLD_02 = @MV_WERKS.

    IF LINES( IT_2010 ) = 1.
      READ TABLE IT_2010 INTO DATA(LS_2010) INDEX 1.

      LV_PSMNG_C = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                             LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                           * LS_2010-INFACTOR.
      CONDENSE : LV_PSMNG_C.

      CLEAR LS_PR_INFOR.
      LS_PR_INFOR-BSART = 'NB'.
      CASE LS_2010-DMORDTY.
        WHEN 'SO'.
          LS_PR_INFOR-KNTTP = 'M'.
          LS_PR_INFOR-KDAUF = LS_2010-DMORD.
          LS_PR_INFOR-KDPOS = LS_2010-DMLINE.

      ENDCASE.

      LS_PR_INFOR-EEIND = MS_INFNR_INFOR-EEIND.
      LS_PR_INFOR-WERKS = MV_WERKS.
      LS_PR_INFOR-EKGRP = LS_EKORG-EKGRP.
      LS_PR_INFOR-AFNAM = SY-UNAME.
      LS_PR_INFOR-MATNR = LS_2010-MATNR.
      LS_PR_INFOR-EKORG = LS_EKORG-EKORG.
      LS_PR_INFOR-MENGE = LV_PSMNG_C.

*        특성값 세팅
      LV_INLENGTH = LS_2010-INLENGTH.
      LV_INLENGTH_C = LV_INLENGTH.
      CONDENSE LV_INLENGTH_C.

      APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
      <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
      <LS_CHART>-ATWRT = LV_INLENGTH_C.

      LV_INFACTOR = LS_2010-INFACTOR.
      LV_INFACTOR_C = LV_INFACTOR.
      CONDENSE LV_INFACTOR_C.

      APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
      <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
      <LS_CHART>-ATWRT = LV_INFACTOR_C.

      CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
        EXPORTING
          IS_PR_INFOR = LS_PR_INFOR
        IMPORTING
          EV_RESULT   = LV_RESULT
          EV_BANFN    = LV_BANFN
        TABLES
          IT_CHART    = LT_CHART.

      IF LV_RESULT NE 'S'.
        READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
        CONCATENATE LS_ROUTING-CHART_VAL '구매요청 생성 중 오류가 발생했습니다.' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.

      RV_RESULT = LV_BANFN.

      APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
      <LS_BANFN>-BANFN = LV_BANFN.
      <LS_BANFN>-BNFPO = 10.

    ELSE.

      REFRESH : MT_BDCDATA, MT_MESSTAB.

      __SETTING_BDC_PARAMS.


      __BDC_DYNPRO 'SAPMM06B' '0100'.
      __BDC_FIELD : 'BDC_OKCODE' '=AB',
                          'EBAN-BSART'  'NB',
                          'EBAN-KNTTP' '',
                          'RM06B-EEIND' MS_INFNR_INFOR-EEIND,
                          'RM06B-LPEIN' 'T',
                          'EBAN-WERKS' MV_WERKS,
                          'EBAN-EKGRP' LS_EKORG-EKGRP,
                          'EBAN-AFNAM' SY-UNAME.

      CLEAR LV_NUM.

      LOOP AT IT_2010 INTO LS_2010.

        ADD 1 TO LV_NUM.

        CLEAR LV_PSMNG_C.
        LV_PSMNG_C = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                               LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                             * LS_2010-INFACTOR.
        CONDENSE : LV_PSMNG_C.

*        특성값 세팅
        LV_INLENGTH = LS_2010-INLENGTH.
        LV_INLENGTH_C = LV_INLENGTH.
        CONDENSE LV_INLENGTH_C.

        LV_INFACTOR = LS_2010-INFACTOR.
        LV_INFACTOR_C = LV_INFACTOR.
        CONDENSE LV_INFACTOR_C.

        __BDC_DYNPRO 'SAPMM06B' '0106'.
        __BDC_FIELD : 'BDC_OKCODE' '=DETA'.
* 체크박스
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = 'RM06B-TCSELFLAG(' && LV_NUM && ')'.
        __BDC_FIELD : LV_FIELDNAME 'X'.
* 자재코드
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = 'EBAN-MATNR(' && LV_NUM && ')'.
        __BDC_FIELD : LV_FIELDNAME LS_2010-MATNR.
* 수량
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = 'EBAN-MENGE(' && LV_NUM && ')'.
        __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.
* 계정지정범주(이후공정이 판매오더일시)
        IF LS_2010-DMORDTY = 'SO'.
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = 'EBAN-KNTTP(' && LV_NUM && ')'.
          __BDC_FIELD : LV_FIELDNAME 'M'.
        ENDIF.

        __BDC_DYNPRO 'SAPMM06B' '0102'.
        __BDC_FIELD : 'BDC_OKCODE' '=KN',
                            'EBAN-EKORG'  LS_EKORG-EKORG.

        IF LS_2010-DMORDTY = 'SO'.
          __BDC_DYNPRO 'SAPMM06B' '0505'.
          __BDC_FIELD : 'BDC_OKCODE' '=KWE'.

          __BDC_DYNPRO 'SAPLKACB' '0002'.
          __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
                              'COBL-KDAUF' LS_2010-DMORD,
                              'COBL-KDPOS' LS_2010-DMLINE.
        ENDIF.

* 특성값 입역
        __BDC_DYNPRO 'SAPMM06B' '0106'.
        __BDC_FIELD : 'BDC_OKCODE' '=KONF'.
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = 'RM06B-TCSELFLAG(' && LV_NUM && ')'.
        __BDC_FIELD : LV_FIELDNAME 'X'.

        __BDC_DYNPRO 'SAPMM06B' '0102'.
        __BDC_FIELD : 'BDC_OKCODE' '=KONF'.

        __BDC_DYNPRO 'SAPLCEI0' '0109'.
        __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                            'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
                            'RCTMS-MWERT(01)' LV_INLENGTH_C,
                            'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
                            'RCTMS-MWERT(02)' LV_INFACTOR_C.

      ENDLOOP.

      __BDC_DYNPRO 'SAPMM06B' '0106'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.


      __BDC_TRANSACTION 'ME51'.

      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                             AND MSGID = '06'
                                                             AND MSGNR = '402'.
        RV_RESULT = LS_MESSTAB-MSGV1.
        COMMIT WORK AND  WAIT.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD GO_PARALLEL_PRD_BDC.

    DO.
      WAIT UNTIL MV_RUNNING_ARFC_WPS < MV_JOBNUM.

      CALL FUNCTION 'ZGTPPT_BDC_PRD_CHART'
        STARTING NEW TASK MV_TASKNAME
        DESTINATION IN GROUP MV_GROUP_NAME
        CALLING ME->RETURNING_PARALLEL_PRD_BDC
        ON END OF TASK
        TABLES
          IT_2010 = IT_2010.

      IF SY-SUBRC EQ 0.
        MV_TASKNAME = MV_TASKNAME + 1.
        MV_SENDJOBS = MV_SENDJOBS + 1.
        MV_RUNNING_ARFC_WPS = MV_RUNNING_ARFC_WPS + 1.
        EXIT.
      ENDIF.
    ENDDO.


  ENDMETHOD.


  METHOD INIT_PARALLEL_CONDITION.


    DATA: LV_MAX  TYPE I,
          LV_FREE TYPE I.

    CLEAR: MV_EXCPFLAG, MV_GROUP_NAME.

    MV_SENDJOBS         =  1.
    MV_RECVJOBS         =  1.
    MV_TASKNAME         = '0001'.
    MV_RUNNING_ARFC_WPS = 0.
    MV_PROCESSED_COUNT  = 0.


    CASE SY-SYSID.
      WHEN 'R3T'.
        MV_GROUP_NAME = 'LGCR3T'.
      WHEN OTHERS.
        MV_GROUP_NAME = 'parallel_generators'.
    ENDCASE.

    CALL FUNCTION 'SPBT_INITIALIZE'
      EXPORTING
        GROUP_NAME                     = MV_GROUP_NAME
        MAX_WAIT_TIME                  = 1
      IMPORTING
        MAX_PBT_WPS                    = LV_MAX
        FREE_PBT_WPS                   = LV_FREE
      EXCEPTIONS
        INVALID_GROUP_NAME             = 1
        INTERNAL_ERROR                 = 2
        PBT_ENV_ALREADY_INITIALIZED    = 3
        CURRENTLY_NO_RESOURCES_AVAIL   = 4
        NO_PBT_RESOURCES_FOUND         = 5
        CANT_INIT_DIFFERENT_PBT_GROUPS = 6
        OTHERS                         = 7.

    IF SY-SUBRC = 0.
      IF LV_FREE < IV_MAX_SEQ.
        MV_JOBNUM = LV_FREE.
      ELSE.
        MV_JOBNUM = IV_MAX_SEQ.
      ENDIF.
    ELSE.
      MV_JOBNUM = IV_MAX_SEQ.
    ENDIF.

*    MV_JOBNUM = 60.

  ENDMETHOD.


  METHOD MULTY_ORDER_TO_MERGE.

* 최초 공정의 복조장시 단일오더로 수량 섬하여 생성
*  --> 이전 공정이 조장내 존재 하지 않으므로 현재 공정기준으로 조장구성
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_MIN_FINDATE TYPE SY-DATUM.
    DATA : LV_TABIX TYPE I.
    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_RELEASE.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
    DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.
    DATA : LT_ORDER_KEY TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LT_RETURN2 TYPE BAPI_ORDER_RETURN_TT.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 TYPE ZGTPPT2010.
    DATA : LS_MAKED_2010 LIKE MS_MAKED_2010.


* 복조장 구성을 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RETURN = 'E'.
          CLEAR MV_MESSAGE.
          CONCATENATE '공정코드' LS_2010-GONG_CD  '기존오더 삭제' INTO MV_MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

*  해당공정의 오더들의 머지 라인 구성
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_ORIGIN).

      ADD 1 TO LV_TABIX.

      CLEAR LV_FINDATE.
      GET_FINDATE(
        EXPORTING
          IV_ORDNR   = LS_2010-DMORD  " 오더번호
          IV_ORDTY   = LS_2010-DMORDTY" 오더유형
      IMPORTING
        EV_FINDATE = LV_FINDATE  ).               " ABAP system field: Current date of application server

* 이후공정 시작일 기준으로 생성일자 세팅
      IF LV_MIN_FINDATE = '00000000'.
        LV_MIN_FINDATE = LV_FINDATE.
      ELSEIF LV_MIN_FINDATE > LV_FINDATE.
        LV_MIN_FINDATE = LV_FINDATE.
      ENDIF.

      IF LV_TABIX = 1.
        APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).
        MOVE-CORRESPONDING LS_ORIGIN TO <LS_NEW_2010>.
        CLEAR : <LS_NEW_2010>-INLENGTH,
                <LS_NEW_2010>-QLENGTH,
                <LS_NEW_2010>-CLENGTH,
                <LS_NEW_2010>-SLENGTH,
                <LS_NEW_2010>-ELENGTH,
                <LS_NEW_2010>-ADLENGTH,
                <LS_NEW_2010>-ADTYPE.
        <LS_NEW_2010>-INFACTOR = 1.
* 조장 계산
        <LS_NEW_2010>-INLENGTH = ( LS_ORIGIN-INLENGTH + LS_ORIGIN-QLENGTH + LS_ORIGIN-CLENGTH +
                                                  LS_ORIGIN-SLENGTH + LS_ORIGIN-ELENGTH + LS_ORIGIN-ADLENGTH ) * LS_ORIGIN-INFACTOR.
* 그외 기본 여장은 첫번째 라인 기준으로 세팅
      ELSE.
        <LS_NEW_2010>-INLENGTH = <LS_NEW_2010>-INLENGTH +
                                                 ( ( LS_ORIGIN-INLENGTH + LS_ORIGIN-QLENGTH + LS_ORIGIN-CLENGTH +
                                                  LS_ORIGIN-SLENGTH + LS_ORIGIN-ELENGTH + LS_ORIGIN-ADLENGTH ) * LS_ORIGIN-INFACTOR ).
      ENDIF.

    ENDLOOP.

* 기본설비 만권량 과 총 생산 길이 비교
    SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
     WHERE WERKS = @MV_WERKS
       AND MATNR = @<LS_NEW_2010>-MATNR
       AND FLGAT = '0' "대표설비
       INTO @DATA(LV_FERTL).

* 생성라인 총 길이
    LV_TOTAL_QTY = <LS_NEW_2010>-INLENGTH.

    IF LV_FERTL NE 0 AND LV_TOTAL_QTY > LV_FERTL.
      CLEAR MV_MESSAGE.
      CONCATENATE '공정코드' <LS_NEW_2010>-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

* 생산오더 생성
    LS_ORDER-MATERIAL = <LS_NEW_2010>-MATNR.
    LS_ORDER-PLANT = MV_WERKS.
    LS_ORDER-BASIC_START_DATE = LV_MIN_FINDATE.
    LS_ORDER-BASIC_END_DATE = LV_MIN_FINDATE.
    LS_ORDER-ORDER_TYPE = 'PP01'.
    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
    LS_ORDER-QUANTITY = LV_TOTAL_QTY.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_ORDER_NUMBER.

*  복조장 구성 BDC
    IF LS_RETURN-TYPE NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      CLEAR LS_ORDER_KEY.
      LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
      COLLECT LS_ORDER_KEY INTO MT_PRD_ORDERS.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE AUFNR, POSNR
          FROM AFPO
         WHERE AUFNR = @LV_ORDER_NUMBER
          INTO @DATA(LS_AFPO).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

      <LS_NEW_2010>-ORDNR = LV_ORDER_NUMBER.
      <LS_NEW_2010>-POSNR = 1.
      <LS_NEW_2010>-ORDTY = 'PRD'.


* 특성값 세팅
      CLEAR LS_MAKED_2010.
      MOVE <LS_NEW_2010> TO LS_MAKED_2010.
      RV_RETURN = SET_PRD_CHARICTERISTIC(
                          EXPORTING  IS_2010   = LS_MAKED_2010 ).                " [GT] 오더 연결 정보
      IF RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' <LS_NEW_2010>-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.

    ELSE.
      RV_RETURN = 'E'.
      CLEAR MV_MESSAGE.
      CONCATENATE '공정코드' <LS_NEW_2010>-GONG_CD  '오더생성 BAPI' INTO MV_MESSAGE SEPARATED BY SPACE.
      RETURN.
    ENDIF.

    IF LINE_EXISTS( IT_2010[ STATUS = 'R' ] ).
      LV_CHK_RELEASE = ABAP_TRUE.
    ENDIF.

    IF LV_CHK_RELEASE = ABAP_TRUE.
      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
      <LS_ORDERS>-ORDER_NUMBER = LV_ORDER_NUMBER.

      CLEAR LS_RETURN.

      CALL FUNCTION 'BAPI_PRODORD_RELEASE'
        IMPORTING
          RETURN        = LS_RETURN
        TABLES
          ORDERS        = LT_ORDERS
          DETAIL_RETURN = LT_RETURN2.

      IF LS_RETURN-TYPE = 'E'.
        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' <LS_NEW_2010>-GONG_CD  '오더 릴리즈' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.
    ENDIF.

*   기존 상위 오더 테이블 체인 변경
    LOOP AT IT_2010 INTO DATA(LS_MOSU).

      REFRESH LT_DEV_2010.
      READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_TEMP) WITH KEY ORDNR = LS_MOSU-DMORD
                                                                                    POSNR = LS_MOSU-DMLINE
                                                                                    ORDTY = LS_MOSU-DMORDTY.


      IF SY-SUBRC EQ 0.
        LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV>) WHERE REORD = LS_CHK_TEMP-REORD
                                                                                               AND RELINE = LS_CHK_TEMP-RELINE
                                                                                               AND REORDTY = LS_CHK_TEMP-REORDTY.
          READ TABLE LT_DEV_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WITH KEY ORDNR = <LS_DEV>-ORDNR
                                                                                                              POSNR = <LS_DEV>-POSNR
                                                                                                              ORDTY = <LS_DEV>-ORDTY
                                                                                                              BINARY SEARCH.
          IF SY-SUBRC NE 0.
            CLEAR LS_DEV_2010.
            MOVE-CORRESPONDING <LS_DEV> TO LS_DEV_2010.
            INSERT LS_DEV_2010 INTO  LT_DEV_2010 INDEX SY-TABIX.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT LT_DEV_2010 INTO LS_CHK_2010.
        READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_MODI>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                    POSNR = LS_CHK_2010-POSNR
                                                                                                    ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_MODI>-REORD = <LS_NEW_2010>-ORDNR.
          <LS_MODI>-RELINE = <LS_NEW_2010>-POSNR.
          <LS_MODI>-REORDTY = <LS_NEW_2010>-ORDTY.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    UNASSIGN <LS_NEW_2010>.
    APPEND LINES OF LT_NEW_2010 TO MT_NEW_2010.

  ENDMETHOD.


  METHOD PROCESS_SEPERATE_PR.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_TABIX TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LV_TOTAL_QTY2 TYPE GAMNG.
* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
    DATA : LV_CHK_QMAT.
    DATA : LV_EXCLUDING_LENGTH TYPE GSMNG.
    DATA : LV_CHK_EXCLUDING_LENGTH TYPE GSMNG.
    DATA : LT_RESB TYPE TABLE OF RESB.


    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

* 복조장 분리를 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
          APPEND INITIAL LINE TO RT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
          <LS_RESULT>-TYPE = 'E'.
          CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '개별오더 전환중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

    CLEAR MV_SUCC_CNT.

    READ TABLE IT_2010 INTO DATA(LS_MOSU) INDEX 1. " 이후공정 정보를 찾아오기 위함

    GET_FINDATE(
      EXPORTING
        IV_ORDNR   = LS_MOSU-DMORD  " 오더번호
        IV_ORDTY   = LS_MOSU-DMORDTY" 오더유형
    IMPORTING
      EV_FINDATE = LV_FINDATE
      EV_RSNUM = LV_RSNUM ).

    REFRESH MT_PR_ORDERS.

    LOOP AT IT_2010 INTO LS_MOSU.
      READ TABLE MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WITH KEY ORDNR = LS_MOSU-DMORD
                                                                                                               POSNR = LS_MOSU-DMLINE
                                                                                                               ORDTY = LS_MOSU-DMORDTY.

      IF SY-SUBRC EQ 0.
        APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).

        MOVE-CORRESPONDING LS_MOSU TO <LS_NEW_2010>.
        CLEAR <LS_NEW_2010>-REAL_MATNR.

        CAL_LC(
          EXPORTING
            IV_DEV_2010        = <LS_DEV_2010>                 " [GT] 오더 연결 정보
            IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
          IMPORTING
            EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
            EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
          CHANGING
            CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
        ).

        IF LV_RETURN = ABAP_TRUE.
          READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
          APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
          <LS_RESULT>-TYPE = 'E'.
          CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '개별오더 전환중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
          EXIT.
        ENDIF.

        CLEAR LV_RETURN.
        LV_RETURN = CREATE_PR_ORDER(
                      EXPORTING
                        IV_FINDATE = LV_FINDATE " ABAP system field: Current date of application server
                      CHANGING
                        CS_2010    = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

        IF LV_RETURN = ABAP_TRUE.
          READ TABLE MT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = <LS_NEW_2010>-GONG_SEQ.
          APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
          <LS_RESULT>-TYPE = 'E'.
          CONCATENATE '공정' MS_SEQ_ROUTING_HEADER-CHART_VAL '개별오더 전환중 오류 발생하였습니다.'   INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
          EXIT.
        ENDIF.

* 이후공정 체인구성
        <LS_DEV_2010>-REORD = <LS_NEW_2010>-ORDNR.
        <LS_DEV_2010>-RELINE = <LS_NEW_2010>-POSNR.
        <LS_DEV_2010>-REORDTY = <LS_NEW_2010>-ORDTY.

* 구성품자재 길이결정을 위해 ㅈ품질테이블 적함성체크

        CLEAR LV_CHK_QMAT.
        IF <LS_NEW_2010>-QLENGTH > 0.
          LV_CHK_QMAT = ABAP_TRUE.
        ENDIF.

        CLEAR LV_EXCLUDING_LENGTH.
        IF LV_CHK_QMAT = ABAP_TRUE.
          SELECT SINGLE MATNR FROM QMAT
            INTO @DATA(LV_CHK_MATNR)
           WHERE MATNR = @<LS_NEW_2010>-MATNR
             AND WERKS = @MV_WERKS
             AND ART = '04'
             AND AKTIV = 'X'.
          IF SY-SUBRC EQ 0.
            LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - <LS_NEW_2010>-QLENGTH.
          ELSE.
            LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
          ENDIF.
        ELSE.
          LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
        ENDIF.

        ADD LV_EXCLUDING_LENGTH TO LV_TOTAL_QTY2.

      ELSE.
        LV_RETURN = 'E'.
        EXIT.
      ENDIF.

    ENDLOOP.

* 오류처리후 진행
    IF LV_RETURN IS NOT INITIAL.
      IF MT_PR_ORDERS[] IS NOT INITIAL.
        LV_RETURN = DELETE_PR_ORDER( ).
      ENDIF.
      RETURN.
    ENDIF.

*  후속진행
*   1) 기존 PR삭제
    REFRESH : MT_PR_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PR' OR 'UPR'.
          APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
          <LS_BANFN>-BANFN = LS_DEL_2010-ORDNR.
          <LS_BANFN>-BNFPO = LS_DEL_2010-POSNR + 0.

      ENDCASE.
    ENDLOOP.

    IF MT_PR_ORDERS[] IS NOT INITIAL.
      LV_RETURN = DELETE_PR_ORDER( ).
    ENDIF.

* 2) resb테이블 업데이트
* 최종 resb 업데이트 길이         LV_TOTAL_QTY2
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
    REFRESH LT_RESB.
    SELECT A~*
      FROM RESB AS A
      INNER JOIN MARA AS B
                      ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                      ON C~MATNR = A~MATNR
      INNER JOIN ZGTCVMSTVAL AS D
                      ON D~MATNR = C~MATNR
                     AND D~WERKS = C~WERKS
      INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
     WHERE B~MTART = 'MCHF'
       AND C~WERKS = @MV_WERKS
       AND C~BESKZ IN ('E', 'X')
       AND D~PDCAPROCCODE NE 'BWD'
       AND A~RSNUM = @LV_RSNUM.

    LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

      <LS_RESB>-BDMNG = LV_TOTAL_QTY2 + 0.

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

    LOOP AT LT_RESB INTO DATA(LS_RESB).

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


* 3) 변경된 조장구성표 체인 반영
    IF LT_NEW_2010[] IS NOT INITIAL.
      APPEND LINES OF LT_NEW_2010 TO MT_NEW_2010.
    ENDIF.

    CONFIRM( ).

    APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
    <LS_RESULT>-TYPE = 'S'.
    DATA : LV_TABIX_C(10).
    LV_TABIX_C = LINES( LT_NEW_2010 ).
    CONDENSE LV_TABIX_C.
    <LS_RESULT>-MESSAGE = LV_TABIX_C && '건의 개별 오더로 전환 되었습니다.'(m01).

  ENDMETHOD.


  METHOD PROC_TANDEM_CANCEL.

    DATA : LT_SORTED_2010 LIKE MT_MAKED_2010.
    DATA : LT_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LT_FUL_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LT_CURREN_2010 LIKE MT_MAKED_2010.
* 롤백처리를 위한 테이블 구성
    DATA : LT_MOSU_ORDNR LIKE MT_PRD_ORDERS.
    DATA : LT_MOSU_PRE_ORDNR LIKE MT_PRD_ORDERS.
* 오더 변경을 위한 파라미터
    DATA : LV_NUMBER TYPE AUFNR.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_SEQNO TYPE I.
    DATA : LV_CHK_ERR.
    DATA : LV_PERCENT(2) TYPE N.
    DATA : LV_CHK_OK.
    DATA : LV_SO_VBELN TYPE VBAP-VBELN.
    DATA : LV_SO_POSNR TYPE VBAP-POSNR.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    LV_PERCENT = 10.
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

* 탄뎀 세팅은 오더단위로 구성된다.
    LT_SORTED_2010 = IT_2010.
    SORT LT_SORTED_2010 BY ORDNR.
    DELETE ADJACENT DUPLICATES FROM LT_SORTED_2010 COMPARING ORDNR.

    LOOP AT LT_SORTED_2010 INTO DATA(LS_MAIN).
* 현재 공정의 동일오더 데이터 전부 찾아오기.
      LT_CURREN_2010 = VALUE #( FOR WA_2010 IN MT_MAKED_2010 WHERE ( GONG_SEQ = LS_MAIN-GONG_SEQ
                                                                                                AND   ORDNR = LS_MAIN-ORDNR )
                                            ( CORRESPONDING #( WA_2010 ) ) ).

* 현재 공정의 이전 직전공정 찾기.
      REFRESH LT_PRE_2010.
      LOOP AT LT_CURREN_2010 INTO DATA(LS_CURREN_2010).
        LOOP AT MT_MAKED_2010 INTO DATA(LS_PRE_2010) WHERE DMORD = LS_CURREN_2010-ORDNR
                                                                                  AND DMLINE = LS_CURREN_2010-POSNR
                                                                                  AND DMORDTY = LS_CURREN_2010-ORDTY.
          APPEND LS_PRE_2010 TO LT_PRE_2010.
        ENDLOOP.

        LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE ORDNR = LS_CURREN_2010-REORD
                                                                          AND POSNR = LS_CURREN_2010-RELINE
                                                                          AND ORDTY = LS_CURREN_2010-REORDTY.
          APPEND LS_PRE_2010 TO LT_PRE_2010.
        ENDLOOP.
      ENDLOOP.

      SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.

*    처리할 공정의 바로 이전 공정만 확인하여 탐뎀마크 세팅
      READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ORIGN) WITH KEY GONG_SEQ = LS_MAIN-GONG_SEQ.
      IF SY-SUBRC EQ 0.
        LV_SEQNO = LS_ORIGN-SEQNO - 1. "이전 공정
        READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_PRE_GONG) WITH KEY SEQNO = LV_SEQNO.
      ELSE.
        MV_MESSAGE = '탄뎀 취소 중 오류 발생하였습니다.'.
        EXIT.
      ENDIF.

      IF LV_PERCENT < 80.
        ADD 10 TO LV_PERCENT.
      ENDIF.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '탄뎀 취소 중..' ).

*    생산오더 변경처리
      CLEAR LV_NUMBER.
      LV_NUMBER = LS_MAIN-ORDNR.

* 생성 실패시 롤백처리를 위해 탄뎀 기준정보 담아준다.
      APPEND INITIAL LINE TO LT_MOSU_ORDNR ASSIGNING FIELD-SYMBOL(<LS_MOSU_ORDNR>).
      <LS_MOSU_ORDNR>-ORDER_NUMBER = LV_NUMBER.

      UPDATE AUFK SET ZZTANDEM = ' '
        WHERE AUFNR = LV_NUMBER.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
*     변경전 탄뎀 세팅

      REFRESH : MT_BDCDATA, MT_MESSTAB.
      __SETTING_BDC_PARAMS.
      MS_BDCPARAMS-NOBINPT = ABAP_TRUE.
      MS_BDCPARAMS-NOBIEND = ABAP_TRUE.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_NUMBER,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0131'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                          'RC62F-VER_SEL' 'X',
                          'RC62F-PROD_VERS' '1000',
                          'RC62F-NEW_ROUT' 'X',
                          'RC62F-PLAUF' SY-DATUM,
                          'RC62F-NEW_BOM' 'X',
                          'RC62F-AUFLD' SY-DATUM.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

      __BDC_TRANSACTION 'CO02'.

      CLEAR LV_CHK_OK.
      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGID = 'CO'
                                                             AND MSGNR = '100'.
        LV_CHK_OK = ABAP_TRUE.
        EXIT.
      ENDLOOP.

*      CLEAR LS_ORDERDATA.
*      CLEAR LS_ORDERDATAX.
*      CLEAR LS_RETURN.
*
*      UPDATE AFPO SET VERID = '1000'
*        WHERE AUFNR = LV_NUMBER
*           AND POSNR = '0001'.
*      COMMIT WORK AND WAIT.
*
*      LS_ORDERDATA-EXPLODE_NEW = ABAP_TRUE.
*      LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '3'.
*      LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
*      LS_ORDERDATA-PROD_VERSION = '1000'. " 탄뎀 라우팅 설정
*      LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = ABAP_TRUE.
*      LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
*      LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
*
*      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
*        EXPORTING
*          NUMBER     = LV_NUMBER
*          ORDERDATA  = LS_ORDERDATA
*          ORDERDATAX = LS_ORDERDATAX
*        IMPORTING
*          RETURN     = LS_RETURN.

      IF LV_CHK_OK = ABAP_TRUE.
        COMMIT WORK AND WAIT.
        WAIT UP TO '0.3' SECONDS.
* RESB 테이블 업데이트(탐뎀 공정은 이전 공정의 RESB 수량 으로 업데이트 된다.)
        UPDATE_TANDEM_RESB(
          IS_CURRENT   = LS_MAIN
          IT_CHAIN_PRE = LT_PRE_2010
          IV_GUBUN     = 'E' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

      ELSE.
        MV_MESSAGE = '탄뎀 취소 중 오류 발생하였습니다.'.
        LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

      LOOP AT LT_PRE_2010 INTO LS_PRE_2010.
        IF LS_PRE_2010-GONG_SEQ = LS_PRE_GONG-GONG_SEQ.
          APPEND LS_PRE_2010 TO LT_FUL_PRE_2010.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    IF LV_CHK_ERR = ABAP_TRUE.
* 에러처리
      LOOP AT LT_MOSU_ORDNR INTO DATA(LS_MOSU_ORDNR).
        UPDATE AUFK SET ZZTANDEM = 'X'
          WHERE AUFNR = LS_MOSU_ORDNR-ORDER_NUMBER.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.


        SELECT SINGLE VERID FROM AFPO
          INTO @DATA(LV_VERID)
         WHERE AUFNR = @LS_MOSU_ORDNR-ORDER_NUMBER
           AND POSNR = '0001'.
        IF LV_VERID = '1000'. " 생산버전 변경시 오더 변경된 건이므로 원래 대로 돌려준다.

          REFRESH : MT_BDCDATA, MT_MESSTAB.
*          __SETTING_BDC_PARAMS.

          __BDC_DYNPRO 'SAPLCOKO1' '0110'.
          __BDC_FIELD : 'CAUFVD-AUFNR' LS_MOSU_ORDNR-ORDER_NUMBER,
                              'R62CLORD-FLG_OVIEW'  'X',
                              'BDC_OKCODE' '=ENTK'.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '/00'.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

          __BDC_DYNPRO 'SAPLCOKO1' '0131'.
          __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                              'RC62F-VER_SEL' 'X',
                              'RC62F-PROD_VERS' 'TD10',
                              'RC62F-NEW_ROUT' 'X',
                              'RC62F-PLAUF' SY-DATUM,
                              'RC62F-NEW_BOM' 'X',
                              'RC62F-AUFLD' SY-DATUM.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '=BU'.

          __BDC_TRANSACTION 'CO02'.

          CLEAR LV_CHK_OK.
          LOOP AT MT_MESSTAB INTO LS_MESSTAB WHERE MSGID = 'CO'
                                                                 AND MSGNR = '100'.
            LV_CHK_OK = ABAP_TRUE.
            EXIT.
          ENDLOOP.

*          LV_NUMBER = LS_MOSU_ORDNR-ORDER_NUMBER.
*          CLEAR LS_ORDERDATA.
*          CLEAR LS_ORDERDATAX.
*          CLEAR LS_RETURN.
*
*          LS_ORDERDATA-EXPLODE_NEW = ABAP_TRUE.
*          LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '3'.
*          LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
*          LS_ORDERDATA-PROD_VERSION = 'TD10'. " 탄뎀 라우팅 설정
*          LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = ABAP_TRUE.
*          LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
*          LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
*
*          CALL FUNCTION 'BAPI_PRODORD_CHANGE'
*            EXPORTING
*              NUMBER     = LV_NUMBER
*              ORDERDATA  = LS_ORDERDATA
*              ORDERDATAX = LS_ORDERDATAX
*            IMPORTING
*              RETURN     = LS_RETURN.

          IF LV_CHK_OK = ABAP_TRUE.
            COMMIT WORK AND WAIT.
            WAIT UP TO '0.3' SECONDS.

            READ TABLE LT_SORTED_2010 INTO LS_MAIN WITH KEY ORDNR = LS_MOSU_ORDNR-ORDER_NUMBER.
            IF SY-SUBRC EQ 0.
              REFRESH LT_CURREN_2010.
              LT_CURREN_2010 = VALUE #( FOR WA_2010 IN MT_MAKED_2010 WHERE ( GONG_SEQ = LS_MAIN-GONG_SEQ
                                                                                                        AND   ORDNR = LS_MAIN-ORDNR )
                                                    ( CORRESPONDING #( WA_2010 ) ) ).

* 현재 공정의 이전 직전공정 찾기.
              REFRESH LT_PRE_2010.
              LOOP AT LT_CURREN_2010 INTO LS_CURREN_2010.
                LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE DMORD = LS_CURREN_2010-ORDNR
                                                                                    AND DMLINE = LS_CURREN_2010-POSNR
                                                                                    AND DMORDTY = LS_CURREN_2010-ORDTY.
                  APPEND LS_PRE_2010 TO LT_PRE_2010.
                ENDLOOP.

                LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE ORDNR = LS_CURREN_2010-REORD
                                                                                  AND POSNR = LS_CURREN_2010-RELINE
                                                                                  AND ORDTY = LS_CURREN_2010-REORDTY.
                  APPEND LS_PRE_2010 TO LT_PRE_2010.
                ENDLOOP.
              ENDLOOP.

              SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
              DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.

* RESB 테이블 업데이트(탐뎀 공정은 이전 공정의 RESB 수량 으로 업데이트 된다.)
              UPDATE_TANDEM_RESB(
                IS_CURRENT   = LS_MAIN
                IT_CHAIN_PRE = LT_PRE_2010
                IV_GUBUN     = 'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

            ENDIF.

          ELSE.
            APPEND INITIAL LINE TO MT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
            <LS_MESSAGE>-MSGV1 = '탄뎀 취소 중 오류 발생하였습니다.- 오더' && LV_NUMBER && ' 롤백 중 오류. 오더 확인 필요합니다.'.
          ENDIF.

        ENDIF.

      ENDLOOP.


      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

*  완료된 오더에 대해 설비변경
    WAIT UP TO '0.5' SECONDS.
    CHANGE_TANDEM_ARBPL(
      IT_2010  = LT_SORTED_2010
      IV_GUBUN = 'E'                 " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소
    ).

*   탄뎀 변경건에 대해 조장체인 변경
    LOOP AT IT_2010 INTO DATA(LS_DATA).
      LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>) WHERE GONG_SEQ = LS_DATA-GONG_SEQ
                                                                                                   AND ORDNR = LS_DATA-ORDNR
                                                                                                   AND ORDTY = LS_DATA-ORDTY.

        CLEAR <LS_NEW_2010>-REF_TANDEM.

        IF <LS_NEW_2010>-DMORDTY = 'SO'.

          CLEAR : LV_SO_VBELN, LV_SO_POSNR.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = <LS_NEW_2010>-DMORD
            IMPORTING
              OUTPUT = LV_SO_VBELN.
          LV_SO_POSNR = <LS_NEW_2010>-DMLINE + 0.

          UPDATE AFPO SET KDAUF = LV_SO_VBELN
                                KDPOS = LV_SO_POSNR
                                SOBKZ = 'E'
                                KZBWS = 'A'
                        WHERE AUFNR = <LS_NEW_2010>-ORDNR
                            AND POSNR = <LS_NEW_2010>-POSNR+2(4).
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    LOOP AT LT_FUL_PRE_2010 INTO LS_DATA.
      READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY GONG_SEQ = LS_DATA-GONG_SEQ
                                                                                     ORDNR = LS_DATA-ORDNR
                                                                                     POSNR = LS_DATA-POSNR
                                                                                     ORDTY = LS_DATA-ORDTY.
      IF SY-SUBRC EQ 0.
        CLEAR <LS_NEW_2010>-REF_TANDEM.
      ENDIF.

    ENDLOOP.

* 완료 처리후 조장체인 적용
    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).
    CONFIRM( ).

  ENDMETHOD.


  METHOD PROC_TANDEM_CREATE.

    DATA : LT_SORTED_2010 LIKE MT_MAKED_2010.
    DATA : LT_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LT_FUL_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LT_CURREN_2010 LIKE MT_MAKED_2010.
* 롤백처리를 위한 테이블 구성
    DATA : LT_MOSU_ORDNR LIKE MT_PRD_ORDERS.
    DATA : LT_MOSU_PRE_ORDNR LIKE MT_PRD_ORDERS.
* 오더 변경을 위한 파라미터
    DATA : LV_NUMBER TYPE AUFNR.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_SEQNO TYPE I.
    DATA : LV_CHK_ERR.
    DATA : LV_PERCENT(2) TYPE N.
    DATA : LV_CHK_OK.
    DATA : LV_SO_VBELN TYPE VBAP-VBELN.
    DATA : LV_SO_POSNR TYPE VBAP-POSNR.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    LV_PERCENT = 10.
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

* 탄뎀 세팅은 오더단위로 구성된다.
    LT_SORTED_2010 = IT_2010.
    SORT LT_SORTED_2010 BY ORDNR.
    DELETE ADJACENT DUPLICATES FROM LT_SORTED_2010 COMPARING ORDNR.

    LOOP AT LT_SORTED_2010 INTO DATA(LS_MAIN).
* 현재 공정의 동일오더 데이터 전부 찾아오기.
      LT_CURREN_2010 = VALUE #( FOR WA_2010 IN MT_MAKED_2010 WHERE ( GONG_SEQ = LS_MAIN-GONG_SEQ
                                                                                                AND   ORDNR = LS_MAIN-ORDNR )
                                            ( CORRESPONDING #( WA_2010 ) ) ).

* 현재 공정의 이전 직전공정 찾기.
      REFRESH LT_PRE_2010.
      LOOP AT LT_CURREN_2010 INTO DATA(LS_CURREN_2010).
        LOOP AT MT_MAKED_2010 INTO DATA(LS_PRE_2010) WHERE DMORD = LS_CURREN_2010-ORDNR
                                                                                  AND DMLINE = LS_CURREN_2010-POSNR
                                                                                  AND DMORDTY = LS_CURREN_2010-ORDTY.
          APPEND LS_PRE_2010 TO LT_PRE_2010.
        ENDLOOP.

        LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE ORDNR = LS_CURREN_2010-REORD
                                                                          AND POSNR = LS_CURREN_2010-RELINE
                                                                          AND ORDTY = LS_CURREN_2010-REORDTY.
          APPEND LS_PRE_2010 TO LT_PRE_2010.
        ENDLOOP.
      ENDLOOP.

      SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.

*    처리할 공정의 바로 이전 공정만 확인하여 탐뎀마크 세팅
      READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_ORIGN) WITH KEY GONG_SEQ = LS_MAIN-GONG_SEQ.
      IF SY-SUBRC EQ 0.
        LV_SEQNO = LS_ORIGN-SEQNO - 1. "이전 공정
        READ TABLE MT_SEQ_ROUTING_HEADER INTO DATA(LS_PRE_GONG) WITH KEY SEQNO = LV_SEQNO.
      ELSE.
        MV_MESSAGE = '탄뎀 오더 변경중 오류 발생하였습니다.'.
        EXIT.
      ENDIF.

      IF LV_PERCENT < 80.
        ADD 10 TO LV_PERCENT.
      ENDIF.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '탄뎀 설정 중..' ).

*    생산오더 변경처리
      CLEAR LV_NUMBER.
      LV_NUMBER = LS_MAIN-ORDNR.

* 생성 실패시 롤백처리를 위해 탄뎀 기준정보 담아준다.
      APPEND INITIAL LINE TO LT_MOSU_ORDNR ASSIGNING FIELD-SYMBOL(<LS_MOSU_ORDNR>).
      <LS_MOSU_ORDNR>-ORDER_NUMBER = LV_NUMBER.

      UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
        WHERE AUFNR = LV_NUMBER.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
*     변경전 탄뎀 세팅

      REFRESH : MT_BDCDATA, MT_MESSTAB.
      __SETTING_BDC_PARAMS.
      MS_BDCPARAMS-NOBINPT = ABAP_TRUE.
      MS_BDCPARAMS-NOBIEND = ABAP_TRUE.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_NUMBER,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0131'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                          'RC62F-VER_SEL' 'X',
                          'RC62F-PROD_VERS' 'TD10',
                          'RC62F-NEW_ROUT' 'X',
                          'RC62F-PLAUF' SY-DATUM,
                          'RC62F-NEW_BOM' 'X',
                          'RC62F-AUFLD' SY-DATUM.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

      __BDC_TRANSACTION 'CO02'.

      CLEAR LV_CHK_OK.
      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGID = 'CO'
                                                             AND MSGNR = '100'.
        LV_CHK_OK = ABAP_TRUE.
        EXIT.
      ENDLOOP.



*      CLEAR LS_ORDERDATA.
*      CLEAR LS_ORDERDATAX.
*      CLEAR LS_RETURN.
*
*      UPDATE AFPO SET VERID = 'TD10'
*        WHERE AUFNR = LV_NUMBER
*           AND POSNR = '0001'.
*      COMMIT WORK AND WAIT.
*
*      LS_ORDERDATA-EXPLODE_NEW = ABAP_TRUE.
*      LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '3'.
*      LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
*      LS_ORDERDATA-PROD_VERSION = 'TD10'. " 탄뎀 라우팅 설정
*      LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = ABAP_TRUE.
*      LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
*      LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
*
*      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
*        EXPORTING
*          NUMBER     = LV_NUMBER
*          ORDERDATA  = LS_ORDERDATA
*          ORDERDATAX = LS_ORDERDATAX
*        IMPORTING
*          RETURN     = LS_RETURN.

      IF LV_CHK_OK = ABAP_TRUE.
        COMMIT WORK AND WAIT.
        WAIT UP TO '0.3' SECONDS.

* RESB 테이블 업데이트(탐뎀 공정은 이전 공정의 RESB 수량 으로 업데이트 된다.)
        UPDATE_TANDEM_RESB(
          IS_CURRENT   = LS_MAIN
          IT_CHAIN_PRE = LT_PRE_2010
          IV_GUBUN     = 'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

      ELSE.
        MV_MESSAGE = '탄뎀 오더 변경중 오류 발생하였습니다.'.
        LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

      LOOP AT LT_PRE_2010 INTO LS_PRE_2010.
        IF LS_PRE_2010-GONG_SEQ = LS_PRE_GONG-GONG_SEQ.
          APPEND LS_PRE_2010 TO LT_FUL_PRE_2010.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    IF LV_CHK_ERR = ABAP_TRUE.
* 에러처리
      LOOP AT LT_MOSU_ORDNR INTO DATA(LS_MOSU_ORDNR).
        UPDATE AUFK SET ZZTANDEM = ''
          WHERE AUFNR = LS_MOSU_ORDNR-ORDER_NUMBER.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

        SELECT SINGLE VERID FROM AFPO
          INTO @DATA(LV_VERID)
         WHERE AUFNR = @LS_MOSU_ORDNR-ORDER_NUMBER
           AND POSNR = '0001'.
        IF LV_VERID = 'TD10'. " 생산버전 변경시 오더 변경된 건이므로 원래 대로 돌려준다.

          REFRESH : MT_BDCDATA, MT_MESSTAB.

          __BDC_DYNPRO 'SAPLCOKO1' '0110'.
          __BDC_FIELD : 'CAUFVD-AUFNR' LS_MOSU_ORDNR-ORDER_NUMBER,
                              'R62CLORD-FLG_OVIEW'  'X',
                              'BDC_OKCODE' '=ENTK'.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '/00'.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

          __BDC_DYNPRO 'SAPLCOKO1' '0131'.
          __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                              'RC62F-VER_SEL' 'X',
                              'RC62F-PROD_VERS' '1000',
                              'RC62F-NEW_ROUT' 'X',
                              'RC62F-PLAUF' SY-DATUM,
                              'RC62F-NEW_BOM' 'X',
                              'RC62F-AUFLD' SY-DATUM.

          __BDC_DYNPRO 'SAPLCOKO1' '0115'.
          __BDC_FIELD : 'BDC_OKCODE' '=BU'.

          __BDC_TRANSACTION 'CO02'.

          CLEAR LV_CHK_OK.
          LOOP AT MT_MESSTAB INTO LS_MESSTAB WHERE MSGID = 'CO'
                                                                 AND MSGNR = '100'.
            LV_CHK_OK = ABAP_TRUE.
            EXIT.
          ENDLOOP.


*
*          LV_NUMBER = LS_MOSU_ORDNR-ORDER_NUMBER.
*          CLEAR LS_ORDERDATA.
*          CLEAR LS_ORDERDATAX.
*          CLEAR LS_RETURN.
*
*          LS_ORDERDATA-EXPLODE_NEW = ABAP_TRUE.
*          LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '3'.
*          LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
*          LS_ORDERDATA-PROD_VERSION = '1000'. " 탄뎀 라우팅 설정
*          LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = ABAP_TRUE.
*          LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
*          LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
*
*          CALL FUNCTION 'BAPI_PRODORD_CHANGE'
*            EXPORTING
*              NUMBER     = LV_NUMBER
*              ORDERDATA  = LS_ORDERDATA
*              ORDERDATAX = LS_ORDERDATAX
*            IMPORTING
*              RETURN     = LS_RETURN.

          IF LV_CHK_OK = ABAP_TRUE.
            COMMIT WORK AND WAIT.
            WAIT UP TO '0.3' SECONDS.

            READ TABLE LT_SORTED_2010 INTO LS_MAIN WITH KEY ORDNR = LS_MOSU_ORDNR-ORDER_NUMBER.
            IF SY-SUBRC EQ 0.
              REFRESH LT_CURREN_2010.
              LT_CURREN_2010 = VALUE #( FOR WA_2010 IN MT_MAKED_2010 WHERE ( GONG_SEQ = LS_MAIN-GONG_SEQ
                                                                                                        AND   ORDNR = LS_MAIN-ORDNR )
                                                    ( CORRESPONDING #( WA_2010 ) ) ).

* 현재 공정의 이전 직전공정 찾기.
              REFRESH LT_PRE_2010.
              LOOP AT LT_CURREN_2010 INTO LS_CURREN_2010.
                LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE DMORD = LS_CURREN_2010-ORDNR
                                                                                    AND DMLINE = LS_CURREN_2010-POSNR
                                                                                    AND DMORDTY = LS_CURREN_2010-ORDTY.
                  APPEND LS_PRE_2010 TO LT_PRE_2010.
                ENDLOOP.

                LOOP AT MT_MAKED_2010 INTO LS_PRE_2010 WHERE ORDNR = LS_CURREN_2010-REORD
                                                                                  AND POSNR = LS_CURREN_2010-RELINE
                                                                                  AND ORDTY = LS_CURREN_2010-REORDTY.
                  APPEND LS_PRE_2010 TO LT_PRE_2010.
                ENDLOOP.
              ENDLOOP.

              SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
              DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.

* RESB 테이블 업데이트(탐뎀 공정은 이전 공정의 RESB 수량 으로 업데이트 된다.)
              UPDATE_TANDEM_RESB(
                IS_CURRENT   = LS_MAIN
                IT_CHAIN_PRE = LT_PRE_2010
                IV_GUBUN     = 'E' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소

            ENDIF.

          ELSE.
            APPEND INITIAL LINE TO MT_MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>).
            <LS_MESSAGE>-MSGV1 = '탄뎀 오더 변경중 오류 발생하였습니다.- 오더' && LV_NUMBER && ' 롤백 중 오류. 오더 확인 필요합니다.'.
          ENDIF.

        ENDIF.

      ENDLOOP.


      RV_RETURN = 'E'.
      RETURN.
    ENDIF.

*  완료된 오더에 대해 설비변경
    WAIT UP TO '0.5' SECONDS.
    CHANGE_TANDEM_ARBPL(
      IT_2010  = LT_SORTED_2010
      IV_GUBUN = 'C'                 " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소
    ).

*   탄뎀 변경건에 대해 조장체인 변경
    LOOP AT IT_2010 INTO DATA(LS_DATA).
      LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>) WHERE GONG_SEQ = LS_DATA-GONG_SEQ
                                                                                             AND ORDNR = LS_DATA-ORDNR
                                                                                             AND ORDTY = LS_DATA-ORDTY.
        <LS_NEW_2010>-REF_TANDEM = 'T'.
        IF <LS_NEW_2010>-DMORDTY = 'SO'.

          CLEAR : LV_SO_VBELN, LV_SO_POSNR.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = <LS_NEW_2010>-DMORD
            IMPORTING
              OUTPUT = LV_SO_VBELN.
          LV_SO_POSNR = <LS_NEW_2010>-DMLINE + 0.

          UPDATE AFPO SET KDAUF = LV_SO_VBELN
                                KDPOS = LV_SO_POSNR
                                SOBKZ = 'E'
                                KZBWS = 'A'
                        WHERE AUFNR = <LS_NEW_2010>-ORDNR
                            AND POSNR = <LS_NEW_2010>-POSNR+2(4).
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    LOOP AT LT_FUL_PRE_2010 INTO LS_DATA.
      READ TABLE MT_NEW_2010 ASSIGNING <LS_NEW_2010> WITH KEY GONG_SEQ = LS_DATA-GONG_SEQ
                                                                                     ORDNR = LS_DATA-ORDNR
                                                                                     POSNR = LS_DATA-POSNR
                                                                                     ORDTY = LS_DATA-ORDTY.
      IF SY-SUBRC EQ 0.
        <LS_NEW_2010>-REF_TANDEM = 'X'.
      ENDIF.

    ENDLOOP.

* 완료 처리후 조장체인 적용
    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).
    CONFIRM( ).


  ENDMETHOD.


  METHOD PROGRESS_INDICATOR.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = IV_PERCENT                 "indicator에 진행률(%)
        TEXT       = IV_TEXT.  "텍스트 표시

  ENDMETHOD.


  METHOD RETURNING_PARALLEL_PRD_BDC.


    DATA: LT_MESSAGE TYPE TABLE OF BDCMSGCOLL.
    DATA : LV_SUCCSEQ TYPE I.

    RECEIVE RESULTS FROM FUNCTION 'ZGTPPT_BDC_PRD_CHART'
        IMPORTING
          EV_SUCCSEQ = LV_SUCCSEQ
        TABLES
          ET_MESSAGE            = LT_MESSAGE.

    IF SY-SUBRC EQ 0.
      MV_RUNNING_ARFC_WPS = MV_RUNNING_ARFC_WPS - 1.
      MV_RECVJOBS         = MV_RECVJOBS + 1.
      MV_PROCESSED_COUNT  = MV_PROCESSED_COUNT + 1.

      ADD LV_SUCCSEQ TO MV_SUCC_CNT.

      IF LT_MESSAGE[] IS NOT INITIAL.
        APPEND LINES OF LT_MESSAGE TO MT_MESSTAB.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD UPDATE_TANDEM_RESB.

    DATA : LT_CURRENT_RESB TYPE TABLE OF RESB.
    DATA : LT_PRE_RESB TYPE TABLE OF RESB.
    DATA : LT_PRE_2010 LIKE MT_MAKED_2010.
    DATA : LV_TABIX TYPE I.
    DATA : LV_EXCLUDING_LENGTH TYPE RESB-BDMNG.
    DATA : LV_CHK_MATNR TYPE MATNR.

* 변경될 현재 공정의 RESB정보
    SELECT B~*
      FROM AFKO AS A
      INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
      INNER JOIN MARA AS C ON C~MATNR = B~MATNR
      INNER JOIN MARC AS D ON D~MATNR = B~MATNR
      INNER JOIN ZGTCVMSTVAL AS E
                           ON E~MATNR = D~MATNR
                          AND E~WERKS = D~WERKS
      INTO TABLE @LT_CURRENT_RESB
     WHERE A~AUFNR = @IS_CURRENT-ORDNR
       AND B~STLTY = 'M' " BOM 대상
       AND B~DUMPS = '' " 가상품목이 아닌경우
       AND C~MTART = 'MCHF'
       AND D~WERKS = @MV_WERKS
       AND E~PDCAPROCCODE NE 'BWD'
       AND D~BESKZ IN ('E', 'X').

* 참고될 이전공정의 정보를 찾아와 매핑
    CASE IV_GUBUN.
      WHEN 'C'. " 탐뎀설정시 이전 공정의 RESB정보를 읽어 resb 정보 세팅
        LOOP AT IT_CHAIN_PRE INTO DATA(LS_PRE_2010).

          CASE LS_PRE_2010-ORDTY.
            WHEN 'PRD'.

              SELECT B~*
                FROM AFKO AS A
                INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
                INNER JOIN MARA AS C ON C~MATNR = B~MATNR
                INNER JOIN MARC AS D ON D~MATNR = B~MATNR
                APPENDING TABLE @LT_PRE_RESB
               WHERE A~AUFNR = @LS_PRE_2010-ORDNR
                 AND B~STLTY = 'M' " BOM 대상
                 AND B~DUMPS = '' " 가상품목이 아닌경우
                 AND C~MTART = 'MCHF'
                 AND D~WERKS = @MV_WERKS
                 AND D~BESKZ IN ('E', 'X').

            WHEN 'PLN'.

              SELECT B~*
                FROM PLAF AS A
                INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
                INNER JOIN MARA AS C ON C~MATNR = B~MATNR
                INNER JOIN MARC AS D ON D~MATNR = B~MATNR
                APPENDING TABLE @LT_PRE_RESB
               WHERE A~PLNUM = @LS_PRE_2010-ORDNR
                 AND B~STLTY = 'M' " BOM 대상
                 AND B~DUMPS = '' " 가상품목이 아닌경우
                 AND C~MTART = 'MCHF'
                 AND D~WERKS = @MV_WERKS
                 AND D~BESKZ IN ('E', 'X').

          ENDCASE.

        ENDLOOP.

        LOOP AT LT_CURRENT_RESB INTO DATA(LS_RESB).
          READ TABLE LT_PRE_RESB INTO DATA(LS_PRE_RESB) WITH KEY MATNR = LS_RESB-MATNR.
          IF SY-SUBRC EQ 0.
            LV_TABIX = SY-TABIX.
            UPDATE RESB SET BDMNG = LS_PRE_RESB-BDMNG
                                      ERFMG = LS_PRE_RESB-ERFMG
             WHERE  RSNUM = LS_RESB-RSNUM
               AND  RSPOS = LS_RESB-RSPOS
               AND  RSART = LS_RESB-RSART.

            DELETE LT_PRE_RESB  INDEX LV_TABIX.
          ENDIF.
        ENDLOOP.

      WHEN 'E'. " 탄뎀 취소시 이전공정의 LC정보를 확인하여 RESB 정보 세팅

        LT_PRE_2010 = IT_CHAIN_PRE.
        LOOP AT LT_CURRENT_RESB INTO LS_RESB.
          READ TABLE LT_PRE_2010 INTO LS_PRE_2010 WITH KEY MATNR = LS_RESB-MATNR.
          IF SY-SUBRC EQ 0.
            LV_TABIX = SY-TABIX.

            CLEAR LV_CHK_MATNR.
            SELECT SINGLE MATNR FROM QMAT
              INTO @LV_CHK_MATNR
             WHERE MATNR = @LS_PRE_2010-MATNR
               AND WERKS = @MV_WERKS
               AND ART = '04'
               AND AKTIV = 'X'.


            LV_EXCLUDING_LENGTH = ( LS_PRE_2010-INLENGTH + LS_PRE_2010-QLENGTH + LS_PRE_2010-SLENGTH +
                                                 LS_PRE_2010-CLENGTH + LS_PRE_2010-ELENGTH + LS_PRE_2010-ADLENGTH )
                                               * LS_PRE_2010-INFACTOR.


            IF LV_CHK_MATNR IS NOT INITIAL.
              IF LS_PRE_2010-ADTYPE = 'A'.
                LV_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH - LS_PRE_2010-QLENGTH - LS_PRE_2010-ADLENGTH.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH - LS_PRE_2010-QLENGTH.
              ENDIF.
            ENDIF.


            UPDATE RESB SET BDMNG = LV_EXCLUDING_LENGTH
                                      ERFMG = LV_EXCLUDING_LENGTH
                         WHERE  RSNUM = LS_RESB-RSNUM
                           AND  RSPOS = LS_RESB-RSPOS
                           AND  RSART = LS_RESB-RSART.

            DELETE LT_PRE_2010  INDEX LV_TABIX.

          ENDIF.
        ENDLOOP.

    ENDCASE.

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD MERGE_ORDER.

    DATA : LV_CHK_DEL.
    DATA : LV_CHK_ALREADY.
    DATA : LS_2010 LIKE MS_2010.
    DATA : LT_DEV_2010 LIKE MT_NEW_2010.
    DATA : LS_DEV_2010 TYPE ZGTPPT2010.
    DATA : LT_NEW_2010 LIKE MT_NEW_2010.
    DATA : LS_TEMP_2010 LIKE MS_MAKED_2010.
    DATA : LV_MAIN_SEQ TYPE I.
    DATA : LV_GONG_SEQ TYPE I.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_CHK_RELEASE.
    DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2.
    DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
    DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.
    DATA : LT_ORDER_KEY TYPE TABLE OF BAPI_ORDER_KEY.
    DATA : LV_TOTAL_QTY TYPE GAMNG.
    DATA : LV_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_CHK_EXCLUDING_LENGTH TYPE GAMNG.
    DATA : LV_FINDATE TYPE SY-DATUM.
    DATA : LV_RSNUM TYPE RSNUM.
    DATA : LV_TABIX TYPE I.
    DATA : LV_SO_VBELN TYPE VBAP-VBELN.
    DATA : LV_SO_POSNR TYPE VBAP-POSNR.
    DATA : LT_RETURN2 TYPE BAPI_ORDER_RETURN_TT.
    DATA : LV_TOP_MATNR TYPE MATNR.
    DATA : LV_CHK_QMAT.
    DATA : LT_RESB TYPE TABLE OF RESB.
    DATA : LV_LOOP_IDX TYPE I.
    DATA : LV_CHK_USE.
    DATA : LV_CHK_INLENGTH TYPE ZGTPPT2010-INLENGTH.
    DATA : LV_TANDEM_REF_SEQNO TYPE I.
*    탄뎀 참조 필드 어팬드시 탄뎀 공정의 resb 업데이트 추가
    DATA : LS_DEV_TANDEM LIKE MS_MAKED_2010.
    DATA : LT_PRE_TANDEM LIKE MT_MAKED_2010.
    DATA : LV_CHK_PR.
    DATA : LV_CHK_OK.


* 복조장 생산 오더 생성.
    CLEAR LS_ORDER.
    REFRESH LT_DEV_2010.
    LOOP AT IT_2010 INTO LS_2010.
      CLEAR LV_FINDATE.
      GET_FINDATE(
        EXPORTING
          IV_ORDNR   = LS_2010-DMORD  " 오더번호
          IV_ORDTY   = LS_2010-DMORDTY" 오더유형
      IMPORTING
        EV_FINDATE = LV_FINDATE  ).               " ABAP system field: Current date of application server

      IF LS_ORDER-BASIC_START_DATE < LV_FINDATE.
        LS_ORDER-BASIC_START_DATE = LV_FINDATE.
        LS_ORDER-BASIC_END_DATE = LV_FINDATE.
      ENDIF.

      CLEAR LV_CHK_USE.
      LOOP AT MT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV>) WHERE REORD = LS_2010-ORDNR
                                                                                          AND RELINE = LS_2010-POSNR
                                                                                          AND REORDTY = LS_2010-ORDTY.
        READ TABLE LT_DEV_2010 ASSIGNING FIELD-SYMBOL(<LS_DEV_2010>) WITH KEY ORDNR = <LS_DEV>-ORDNR
                                                                                                                POSNR = <LS_DEV>-POSNR
                                                                                                                ORDTY = <LS_DEV>-ORDTY
                                                                                                                BINARY SEARCH.
        IF SY-SUBRC NE 0.
          LV_CHK_USE = ABAP_TRUE.
          CLEAR LS_DEV_2010.
          MOVE-CORRESPONDING <LS_DEV> TO LS_DEV_2010.
          INSERT LS_DEV_2010 INTO  LT_DEV_2010 INDEX SY-TABIX.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_USE IS INITIAL.
* 에러처리 예정
      ENDIF.

    ENDLOOP.

    READ TABLE IT_2010 INTO LS_DEV_2010 INDEX 1.


* 생산오더 수량
    LOOP AT IT_2010 INTO DATA(LS_SUM_2010).
      LS_ORDER-QUANTITY = LS_ORDER-QUANTITY +
                          ( ( LS_SUM_2010-INLENGTH + LS_SUM_2010-QLENGTH + LS_SUM_2010-SLENGTH +
                              LS_SUM_2010-CLENGTH + LS_SUM_2010-ADLENGTH ) * LS_SUM_2010-INFACTOR ).
    ENDLOOP.

    LS_ORDER-MATERIAL = LS_DEV_2010-MATNR.
    LS_ORDER-PLANT = MV_WERKS.

    SELECT SINGLE AUART FROM AUFK
      INTO @DATA(LV_AUART)
      WHERE AUFNR = @LS_DEV_2010-ORDNR.

    IF LV_AUART = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
      LS_ORDER-ORDER_TYPE = LV_AUART.
    ELSE.
      LS_ORDER-ORDER_TYPE = 'PP01'.
    ENDIF.

    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_ORDER_NUMBER.

*  복조장 구성 BDC
    IF LS_RETURN-TYPE NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      CLEAR LS_ORDER_KEY.
      LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
      COLLECT LS_ORDER_KEY INTO MT_PRD_ORDERS.
      COLLECT LS_ORDER_KEY INTO LT_ORDER_KEY.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE AUFNR, POSNR
          FROM AFPO
         WHERE AUFNR = @LV_ORDER_NUMBER
          INTO @DATA(LS_AFPO).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.1' SECONDS.
        ENDIF.
      ENDDO.

    ELSE.
      RV_RETURN = 'E'.
      CLEAR MV_MESSAGE.
      CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BAPI' INTO MV_MESSAGE SEPARATED BY SPACE.
      RETURN.
    ENDIF.

    REFRESH LT_NEW_2010.
    APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING FIELD-SYMBOL(<LS_NEW_2010>).
    MOVE-CORRESPONDING LS_DEV_2010 TO <LS_NEW_2010>.
    <LS_NEW_2010>-ORDNR = LV_ORDER_NUMBER.
    <LS_NEW_2010>-POSNR = '000001'.
    <LS_NEW_2010>-ORDTY = 'PRD'.

    CLEAR : <LS_NEW_2010>-INLENGTH, <LS_NEW_2010>-INFACTOR, <LS_NEW_2010>-QLENGTH,
            <LS_NEW_2010>-CLENGTH, <LS_NEW_2010>-SLENGTH, <LS_NEW_2010>-ADLENGTH.
    <LS_NEW_2010>-INLENGTH = LS_ORDER-QUANTITY.
    <LS_NEW_2010>-INFACTOR = 1.

    CLEAR LS_TEMP_2010.
    MOVE-CORRESPONDING <LS_NEW_2010> TO LS_TEMP_2010.
    LV_RETURN = SET_PRD_CHARICTERISTIC( EXPORTING IS_2010   = LS_TEMP_2010 ).
    IF LV_RETURN = 'E'.
      RV_RETURN = 'E'.
      CLEAR MV_MESSAGE.
      CONCATENATE '공정코드' LS_2010-GONG_CD  '특성입력 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
    ENDIF.

*    탄뎀 복조장시 탄뎀 설정
    IF LS_DEV_2010-REF_TANDEM = 'T'.
* 탄뎀설정
      UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
        WHERE AUFNR = LV_ORDER_NUMBER.

*     변경전 탄뎀 세팅
      REFRESH : MT_BDCDATA, MT_MESSTAB.
      __SETTING_BDC_PARAMS.
      MS_BDCPARAMS-NOBINPT = ABAP_TRUE.
      MS_BDCPARAMS-NOBIEND = ABAP_TRUE.

      __BDC_DYNPRO 'SAPLCOKO1' '0110'.
      __BDC_FIELD : 'CAUFVD-AUFNR' LV_ORDER_NUMBER,
                          'R62CLORD-FLG_OVIEW'  'X',
                          'BDC_OKCODE' '=ENTK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '/00'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=STAK'.

      __BDC_DYNPRO 'SAPLCOKO1' '0131'.
      __BDC_FIELD : 'BDC_OKCODE' '=ENT1',
                          'RC62F-VER_SEL' 'X',
                          'RC62F-PROD_VERS' 'TD10',
                          'RC62F-NEW_ROUT' 'X',
                          'RC62F-PLAUF' SY-DATUM,
                          'RC62F-NEW_BOM' 'X',
                          'RC62F-AUFLD' SY-DATUM.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD : 'BDC_OKCODE' '=BU'.

      __BDC_TRANSACTION 'CO02'.

      CLEAR LV_CHK_OK.
      LOOP AT MT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGID = 'CO'
                                                             AND MSGNR = '100'.
        LV_CHK_OK = ABAP_TRUE.
        EXIT.
      ENDLOOP.

      IF LV_CHK_OK = ABAP_TRUE.
        COMMIT WORK AND WAIT.
        WAIT UP TO '0.3' SECONDS.
      ELSE.

        RV_RETURN = 'E'.
        CLEAR MV_MESSAGE.
        CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BAPI, 탄뎀설정중' INTO MV_MESSAGE SEPARATED BY SPACE.
        RETURN.
      ENDIF.
    ENDIF.

* 복조장 구성을 위해 기존 체인 구성 삭제후 진행
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_CHK_2010).
      CLEAR LV_CHK_DEL.
      CLEAR LV_CHK_ALREADY.
      CLEAR LV_MAIN_SEQ.
      CLEAR LV_GONG_SEQ.
      CLEAR LS_2010.
      ADD 1 TO LV_TABIX.

      MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010.

      READ TABLE MT_SEQ_ROUTING_HEADER INTO MS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ.
      LOOP AT MT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
        READ TABLE <LS_MAIN>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY SEQNO = MS_SEQ_ROUTING_HEADER-SEQNO.
        READ TABLE <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN>) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                                                          POSNR = LS_CHK_2010-POSNR
                                                                                                                          ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0.

          IF LV_TABIX = 1.
            LV_TOP_MATNR = <LS_MAIN>-MATNR.
          ENDIF.

          IF <LS_CHAIN>-CHK_STATUS = 'D'.
            LV_CHK_ALREADY = ABAP_TRUE.
          ENDIF.
          LV_CHK_DEL = ABAP_TRUE.
          LV_MAIN_SEQ = <LS_MAIN>-END_SEQNO.
          LV_GONG_SEQ = MS_SEQ_ROUTING_HEADER-SEQNO.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_DEL = ABAP_TRUE AND LV_CHK_ALREADY IS INITIAL.

        LV_RETURN = GET_CHAIN_TO_DELETE(
                      IV_MAIN_SEQ = LV_MAIN_SEQ                 " 4바이트 부호 있는 정수
                      IV_GONG_SEQ = LV_GONG_SEQ                 " 4바이트 부호 있는 정수
                      IS_2010 = LS_2010                 " [GT] 오더 연결 정보
                    ).
        IF LV_RETURN = 'E'.
          RV_RETURN = 'E'.
          CLEAR MV_MESSAGE.
          CONCATENATE '공정코드' LS_2010-GONG_CD  '기존오더 삭제' INTO MV_MESSAGE SEPARATED BY SPACE.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.


* 현재 공정 조장체인에 추가
* -- 현재 공정을 이전공정으로 등록한 후행 오더찾아 현재 공정 체인구성
    CLEAR LV_TABIX.
    LOOP AT IT_2010 INTO DATA(LS_2010_SET).
      LOOP AT MT_MAKED_2010 INTO MS_MAKED_2010 WHERE REORD = LS_2010_SET-ORDNR
                                                                      AND RELINE = LS_2010_SET-POSNR
                                                                      AND REORDTY = LS_2010_SET-ORDTY.

        READ TABLE MT_NEW_2010 ASSIGNING <LS_DEV> WITH KEY ORDNR = MS_MAKED_2010-ORDNR
                                                                                   POSNR = MS_MAKED_2010-POSNR
                                                                                   ORDTY = MS_MAKED_2010-ORDTY.
        IF SY-SUBRC EQ 0.
          <LS_DEV>-REORD = LV_ORDER_NUMBER.
          <LS_DEV>-RELINE = '000001'.
          <LS_DEV>-REORDTY = 'PRD'.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF LV_AUART = 'RP01'. " 재생산 오더는 재생산 오더로만 생성
    ELSE.
      LV_AUART = 'PP01'.
    ENDIF.

    REFRESH LT_DEV_2010.
    LT_DEV_2010 = LT_NEW_2010.

* 복조장 이전공정 세팅.
    READ TABLE MT_SEQ_ROUTING_SUB INTO MS_SEQ_ROUTING_SUB WITH KEY MATNR = LV_TOP_MATNR.
    CLEAR LV_TABIX.
    DO.
      ADD 1 TO LV_TABIX.
      IF LT_NEW_2010[] IS INITIAL.
        EXIT.
      ENDIF.
      REFRESH LT_NEW_2010.

      CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.


      LOOP AT LT_DEV_2010 ASSIGNING <LS_DEV_2010>.
        CLEAR : LV_EXCLUDING_LENGTH, LV_TOTAL_QTY, LV_CHK_EXCLUDING_LENGTH.
        CLEAR : LV_FINDATE, LV_RSNUM.
        GET_FINDATE(
          EXPORTING
            IV_ORDNR   = <LS_DEV_2010>-ORDNR  " 오더번호
            IV_ORDTY   = <LS_DEV_2010>-ORDTY" 오더유형
        IMPORTING
          EV_FINDATE = LV_FINDATE
          EV_RSNUM   = LV_RSNUM ).               " ABAP system field: Current date of application server

        CLEAR LV_LOOP_IDX.
        LOOP AT MS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_ROUTING).
          LOOP AT LS_ROUTING-T_BOM INTO DATA(LS_BOM) WHERE  UP_SEQNO = <LS_DEV_2010>-MATNR_SEQ
                                                       AND UP_MATNR = <LS_DEV_2010>-MATNR.
            ADD 1 TO LV_LOOP_IDX.
            APPEND INITIAL LINE TO LT_NEW_2010 ASSIGNING <LS_NEW_2010>.

            <LS_NEW_2010>-GRPNR = MV_GRPNR.
            <LS_NEW_2010>-DMORD = <LS_DEV_2010>-ORDNR.
            <LS_NEW_2010>-DMLINE = <LS_DEV_2010>-POSNR.
            <LS_NEW_2010>-DMORDTY = <LS_DEV_2010>-ORDTY.
            <LS_NEW_2010>-MATNR = LS_BOM-MATNR.
            <LS_NEW_2010>-MATNR_SEQ = LS_BOM-SEQNO.
            <LS_NEW_2010>-GONG_SEQ = LS_ROUTING-GONG_SEQ.
            <LS_NEW_2010>-GONG_CD = LS_ROUTING-CHART.

            CAL_LC(
              EXPORTING
                IV_DEV_2010        = <LS_DEV_2010>                 " [GT] 오더 연결 정보
                IV_BASE_DATE       = LV_FINDATE                 " 고정 스크랩 - 모든 길이
              IMPORTING
                EV_RESULT          = LV_RETURN " 길이 1의 문자 필드
                EV_TOTAL_PLORD_QTY = LV_TOTAL_QTY                 " 계획 오더 수량 총계
              CHANGING
                CS_CURRENT_2010    = <LS_NEW_2010>                 " [GT] 오더 연결 정보
            ).

            IF LV_RETURN = 'E'.
              RV_RETURN = 'E'.
              CLEAR MV_MESSAGE.
              CONCATENATE '공정코드' LS_2010-GONG_CD  'LC 계산 오류(최대생산길이)' INTO MV_MESSAGE SEPARATED BY SPACE.
              RETURN.
            ENDIF.

            SELECT SINGLE * FROM ZGTCVMSTVAL
              INTO @DATA(LS_CVMSTVAL_RE)
             WHERE WERKS = @MV_WERKS
               AND MATNR = @<LS_NEW_2010>-MATNR.

            IF LS_ROUTING-BESKZ = 'EP' AND LS_CVMSTVAL_RE-BESKZ = 'F' AND LS_CVMSTVAL_RE-SOBSL = ''. " 외주공정일시 구매요청생성
              LV_RETURN = CREATE_PR_ORDER(
                            EXPORTING
                              IV_FINDATE = LV_FINDATE " ABAP system field: Current date of application server
                            CHANGING
                              CS_2010    = <LS_NEW_2010> ).                 " [GT] 오더 연결 정보

              IF LV_RETURN = ABAP_TRUE.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  '구매요청 생성오류' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.

            ELSE.
* 생산오더 생성
              LV_RETURN = CREATE_PRD_ORDER_BY_BAPI(
                            EXPORTING
                              IV_AUART       = LV_AUART                 " 판매 문서 유형
                              IV_FINDATE     = LV_FINDATE                 " ABAP system field: Current date of application server
                              IV_TOTAL_QTY   = LV_TOTAL_QTY                 " 오더 수량 총계
                              IV_CHK_RELEASE = LV_CHK_RELEASE                 " 길이 1의 문자 필드
                            CHANGING
                              CS_2010        = <LS_NEW_2010>                 " [GT] 오더 연결 정보
                          ).
              IF LV_RETURN = 'E'.
                RV_RETURN = 'E'.
                CLEAR MV_MESSAGE.
                CONCATENATE '공정코드' LS_2010-GONG_CD  '오더생성 BDC' INTO MV_MESSAGE SEPARATED BY SPACE.
                RETURN.
              ENDIF.
            ENDIF.

* 검사 여장과 추가 시료 여장 존재건은 해당 길이 제외하여 resb테이블 업데이트
* 최종 길이는 가장 긴 항목의 길이
            CLEAR LV_CHK_QMAT.
            IF <LS_NEW_2010>-QLENGTH > 0.
              LV_CHK_QMAT = ABAP_TRUE.
            ENDIF.

            CLEAR LV_EXCLUDING_LENGTH.
            IF LV_CHK_QMAT = ABAP_TRUE.
              SELECT SINGLE MATNR FROM QMAT
                INTO @DATA(LV_CHK_MATNR)
               WHERE MATNR = @<LS_NEW_2010>-MATNR
                 AND WERKS = @MV_WERKS
                 AND ART = '04'
                 AND AKTIV = 'X'.
              IF SY-SUBRC EQ 0.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY - <LS_NEW_2010>-QLENGTH.
              ELSE.
                LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
              ENDIF.
            ELSE.
              LV_EXCLUDING_LENGTH = LV_TOTAL_QTY.
            ENDIF.

            IF LV_CHK_EXCLUDING_LENGTH < LV_EXCLUDING_LENGTH.
              LV_CHK_EXCLUDING_LENGTH = LV_EXCLUDING_LENGTH.
            ENDIF.

            IF LV_LOOP_IDX = 1.
              <LS_DEV_2010>-REORD = <LS_NEW_2010>-ORDNR.
              <LS_DEV_2010>-RELINE = <LS_NEW_2010>-POSNR.
              <LS_DEV_2010>-REORDTY = <LS_NEW_2010>-ORDTY.
            ENDIF.

          ENDLOOP.
        ENDLOOP.

        IF LT_NEW_2010[] IS NOT INITIAL AND LS_DEV_2010-REF_TANDEM NE 'T'.
* 최종 resb 업데이트 길이         LV_CHK_EXCLUDING_LENGTH
* 이후공정 예약자재 소요량 조정을 위해 RESB테이블 조회후 변경 업데이트는 오더 생성후
          REFRESH LT_RESB.
          SELECT A~*
            FROM RESB AS A
            INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
            INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
            INNER JOIN ZGTCVMSTVAL AS D
                            ON D~MATNR = C~MATNR
                           AND D~WERKS = C~WERKS
            INTO CORRESPONDING FIELDS OF TABLE @LT_RESB
           WHERE B~MTART = 'MCHF'
             AND C~WERKS = @MV_WERKS
             AND C~BESKZ IN ('E', 'X')
             AND D~PDCAPROCCODE NE 'BWD'
             AND A~RSNUM = @LV_RSNUM.

          LOOP AT LT_RESB ASSIGNING FIELD-SYMBOL(<LS_RESB>).

            <LS_RESB>-BDMNG = LV_CHK_EXCLUDING_LENGTH + 0.

            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                I_MATNR              = <LS_RESB>-MATNR    " <-- 해당 자재코드
                I_IN_ME              = <LS_RESB>-MEINS  "<-- 현 수량의 단위
                I_OUT_ME             = <LS_RESB>-ERFME " <-- 변경되어질 수량의 단위
                I_MENGE              = LV_EXCLUDING_LENGTH " <-- 현 수량 변수
*               I_MENGE              = MV_TOTAL_PLORD_QTY " <-- 현 수량 변수
              IMPORTING
                E_MENGE              = <LS_RESB>-ERFMG " <-- 변경되어질 수량변수
              EXCEPTIONS
                ERROR_IN_APPLICATION = 1
                ERROR                = 2
                OTHERS               = 3.

          ENDLOOP.

          LOOP AT LT_RESB INTO DATA(LS_RESB).

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

        ENDIF.

      ENDLOOP.

*     탄뎀 참조공정의 resb 변경시 탄뎀 설정된 공정의 resb 변경
      REFRESH LT_PRE_TANDEM.
      CLEAR LS_DEV_TANDEM.

      READ TABLE LT_DEV_2010 INTO DATA(LS_CHK_REF_TEANDEM) WITH KEY REF_TANDEM = 'X'.
      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LT_DEV_2010 TO LT_PRE_TANDEM.
        READ TABLE MT_NEW_2010 INTO DATA(LS_CHK_DEV_2010) WITH KEY ORDNR = LS_CHK_REF_TEANDEM-DMORD
                                                                                           POSNR = LS_CHK_REF_TEANDEM-DMLINE
                                                                                           ORDTY = LS_CHK_REF_TEANDEM-DMORDTY
                                                                                            REF_TANDEM = 'T'.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_CHK_DEV_2010 TO LS_DEV_TANDEM.

* 탄뎀공정의 RESB반영
          UPDATE_TANDEM_RESB(
            IS_CURRENT   = LS_DEV_TANDEM
            IT_CHAIN_PRE = LT_PRE_TANDEM
            IV_GUBUN     =  'C' ).                " 'C' = 탄뎀 설정시, 'E' = 탄뎀취소
        ENDIF.

      ENDIF.

      APPEND LINES OF LT_DEV_2010 TO MT_NEW_2010.
      REFRESH LT_DEV_2010.
      LT_DEV_2010 = LT_NEW_2010.

    ENDDO.


  ENDMETHOD.


  METHOD PROC_MERGE_ORDER.


    DATA : LT_CHK_2010 LIKE MT_MAKED_2010.
    DATA : LT_MULTY_2010 LIKE MT_MAKED_2010.
    DATA : LV_RETURN TYPE CHAR01.
    DATA : LV_PERCENT(2) TYPE N.
    DATA : LT_CHK_GONG LIKE MT_SEQ_ROUTING_HEADER.

    PROGRESS_INDICATOR( IV_PERCENT = 10  IV_TEXT = '처리중..' ).
    REFRESH MT_NEW_2010.
    MOVE-CORRESPONDING MT_MAKED_2010 TO MT_NEW_2010.

    REFRESH MT_DEL_2010.

    LT_CHK_2010 = VALUE #( FOR LW_2010 IN MT_MAKED_2010 WHERE ( CHK_CHAR IS NOT INITIAL )
                                     ( CORRESPONDING #( LW_2010 ) ) ).

    SORT LT_CHK_2010 BY CHK_CHAR.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_2010 COMPARING CHK_CHAR.

    LV_PERCENT = '20'.
    LOOP AT LT_CHK_2010 INTO DATA(LS_CHK_CHAR).
      IF LV_PERCENT < 80.
        ADD 10 TO LV_PERCENT.
      ENDIF.
      PROGRESS_INDICATOR( IV_PERCENT = LV_PERCENT  IV_TEXT = '병합 구성중..' ).

      REFRESH LT_MULTY_2010.
      LT_MULTY_2010 = VALUE #( FOR LW_2010 IN MT_MAKED_2010 WHERE ( CHK_CHAR = LS_CHK_CHAR-CHK_CHAR )
                                    ( CORRESPONDING #( LW_2010 ) ) ).

      LV_RETURN = MERGE_ORDER( IT_2010 = LT_MULTY_2010 ).

      IF LV_RETURN = 'E'.
        REFRESH RT_RESULT.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
        <LS_RESULT>-TYPE = 'E'.
        CONCATENATE '병합 구성 문자 ' LS_CHK_CHAR-CHK_CHAR '작업 중 오류 발생하였습니다. -' MV_MESSAGE INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.
        EXIT.
      ELSE.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'S'.
        CONCATENATE '병합 구성 문자 ' LS_CHK_CHAR-CHK_CHAR '에 대해 완료하였습니다.' INTO <LS_RESULT>-MESSAGE SEPARATED BY SPACE.

      ENDIF.
    ENDLOOP.

* 에러발생시 생성된 오더 삭제후 종료
    IF LV_RETURN = 'E'.
      DATA : LS_RETURN2 TYPE BAPIRET2.
      DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

      IF MT_PRD_ORDERS[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
          IMPORTING
            RETURN        = LS_RETURN2
          TABLES
            ORDERS        = MT_PRD_ORDERS
            DETAIL_RETURN = LT_DETAIL_RETURN.
      ENDIF.

      IF MT_PR_ORDERS[] IS NOT INITIAL.
        LV_RETURN = DELETE_PR_ORDER( ).
      ENDIF.

      RETURN.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 85  IV_TEXT = '병합 구성완료 오더생성 및 변경..' ).
*  생성 완료시 기존 조장 체인정보 삭제
    REFRESH : MT_PLAN_ORDERS, MT_PRD_ORDERS, MT_PR_ORDERS.

    LOOP AT MT_DEL_2010 INTO DATA(LS_DEL_2010).
      CASE LS_DEL_2010-ORDTY.
        WHEN 'PRD'.
          APPEND INITIAL LINE TO MT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDER>).
          <LS_PRD_ORDER>-ORDER_NUMBER = LS_DEL_2010-ORDNR.
        WHEN 'PLN'.
          APPEND INITIAL LINE TO MT_PLAN_ORDERS ASSIGNING FIELD-SYMBOL(<LV_PLAN_ORDER>).
          <LV_PLAN_ORDER> = LS_DEL_2010-ORDNR.
        WHEN 'PR' OR 'UPR'.
          APPEND INITIAL LINE TO MT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
          <LS_BANFN>-BANFN = LS_DEL_2010-ORDNR.
          <LS_BANFN>-BNFPO = LS_DEL_2010-POSNR + 0.
      ENDCASE.
    ENDLOOP.

    LOOP AT MT_PLAN_ORDERS INTO DATA(LS_PLAN).
      LV_RETURN = DELE_PLN_ORDER( IV_PLANNEDORDER = LS_PLAN ).
      IF LV_RETURN = 'E'.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 계획오더 삭제중 오류 발생하였습니다.'(E04).
      ENDIF.
    ENDLOOP.


    IF MT_PRD_ORDERS[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = MT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.

      IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = '기존 생산오더 삭제중 오류 발생하였습니다.'(E05).
      ENDIF.
    ENDIF.


    IF MT_PR_ORDERS[] IS NOT INITIAL.
      LV_RETURN = DELETE_PR_ORDER( ).
      IF LV_RETURN = ABAP_TRUE.
        APPEND INITIAL LINE TO RT_RESULT ASSIGNING <LS_RESULT>.
        <LS_RESULT>-TYPE = 'W'.
        <LS_RESULT>-MESSAGE = MV_MESSAGE.
        RETURN.
      ENDIF.
    ENDIF.

    PROGRESS_INDICATOR( IV_PERCENT = 90  IV_TEXT = '조장체인 저장중..' ).

*  완제품 변경건 존재시 포장재 확인 로직
    IF LINE_EXISTS( LT_CHK_2010[ DMORDTY = 'SO' ] ) OR LINE_EXISTS( LT_CHK_2010[ DMORDTY = 'SM' ] ).
      CHG_PACK_COFIRM( ).
    ENDIF.

    CONFIRM( ).

  ENDMETHOD.


  METHOD SET_DRUM_NO.

    DATA : LT_AUFNR TYPE RANGE OF AUFNR.
    DATA : LV_DRUM_NO(4) TYPE N.
    DATA : LV_RETURN TYPE ZO_RESULT.
    DATA : LV_CHK_PRD TYPE C.
    DATA : LV_CHK_EXIST TYPE C.
    DATA : LS_CHK_2010 TYPE ZGTPPT2010.


    DATA : LV_CHK_INIT_DRUM_NO.


    CHECK MV_WERKS = '6600' AND MV_GRPNR+0(2) = 'GO'.

    LT_AUFNR = VALUE #( FOR LW_2010 IN MT_NEW_2010 WHERE ( ORDTY = 'PRD' )
                      ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).
    CHECK LT_AUFNR[] IS NOT INITIAL.
    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.


    SELECT AUFNR, ZZBUNDLE FROM AUFK
      INTO TABLE @DATA(LT_AUFK)
     WHERE AUFNR IN @LT_AUFNR.

    DO.
      CLEAR LV_CHK_INIT_DRUM_NO.

      LOOP AT LT_AUFK ASSIGNING FIELD-SYMBOL(<LS_AUFK>).
        IF <LS_AUFK>-ZZBUNDLE IS INITIAL.
          READ TABLE MT_NEW_2010 INTO DATA(LS_CURRENT) WITH KEY ORDNR = <LS_AUFK>-AUFNR
                                                                ORDTY = 'PRD'.
          IF SY-SUBRC EQ 0.
            CASE LS_CURRENT-DMORDTY.
              WHEN 'SM' OR 'SO'. " 채번 대상
                CALL FUNCTION 'ZGTPP_DRUM_NO_GET_NEXT'
                  EXPORTING
                    IV_WERKS  = MV_WERKS
                    IV_MATNR  = LS_CURRENT-MATNR
                  IMPORTING
                    EV_NUMBER = LV_DRUM_NO.

                <LS_AUFK>-ZZBUNDLE = LV_DRUM_NO.
                UPDATE AUFK SET ZZBUNDLE = LV_DRUM_NO
                 WHERE AUFNR = <LS_AUFK>-AUFNR.
                COMMIT WORK AND WAIT.

              WHEN 'PRD'.
                READ TABLE LT_AUFK INTO DATA(LS_DEV_AUFK) WITH KEY AUFNR = LS_CURRENT-DMORD.
                IF SY-SUBRC EQ 0.
                  IF LS_DEV_AUFK-ZZBUNDLE IS INITIAL. " 이후공정 드럼번호가 비어있다면 차후 재처리
                    LV_CHK_INIT_DRUM_NO = ABAP_TRUE.
                  ELSE.
                    <LS_AUFK>-ZZBUNDLE = LS_DEV_AUFK-ZZBUNDLE.
                    UPDATE AUFK SET ZZBUNDLE = LS_DEV_AUFK-ZZBUNDLE
                     WHERE AUFNR = <LS_AUFK>-AUFNR.
                    COMMIT WORK AND WAIT.
                  ENDIF.
                ENDIF.
              WHEN OTHERS.
* 해당 조장체인의 생산오더가 존재하는 시점까지 올라간다.
                CLEAR LV_CHK_PRD.
                LS_CHK_2010 = LS_CURRENT.
                DO.
                  CLEAR LV_CHK_EXIST.
                  LOOP AT MT_NEW_2010 INTO DATA(LS_CHK_DEV) WHERE GONG_SEQ > LS_CHK_2010-GONG_SEQ
                                                              AND ORDNR = LS_CHK_2010-DMORD
                                                              AND POSNR = LS_CHK_2010-DMLINE.

                    LV_CHK_EXIST = ABAP_TRUE.
                    EXIT.
                  ENDLOOP.

                  IF LV_CHK_EXIST = ABAP_TRUE.
                    IF LS_CHK_DEV-ORDTY = 'PRD'.
                      LV_CHK_PRD = ABAP_TRUE.

                      READ TABLE LT_AUFK INTO LS_DEV_AUFK WITH KEY AUFNR = LS_CHK_DEV-ORDNR.
                      IF SY-SUBRC EQ 0.
                        IF LS_DEV_AUFK-ZZBUNDLE IS INITIAL. " 이후공정 드럼번호가 비어있다면 차후 재처리
                          LV_CHK_INIT_DRUM_NO = ABAP_TRUE.
                        ELSE.
                          <LS_AUFK>-ZZBUNDLE = LS_DEV_AUFK-ZZBUNDLE.
                          UPDATE AUFK SET ZZBUNDLE = LS_DEV_AUFK-ZZBUNDLE
                           WHERE AUFNR = <LS_AUFK>-AUFNR.
                          COMMIT WORK AND WAIT.
                        ENDIF.
                      ENDIF.
                    ELSE.
                      CASE LS_CHK_DEV-DMORDTY.
                        WHEN 'SM' OR 'SO'. " 찾은 이후공정이 최종공정이라면 업데이트 대상이 없으므로 해당 오더 찾기 종료처리
                          CALL FUNCTION 'ZGTPP_DRUM_NO_GET_NEXT'
                            EXPORTING
                              IV_WERKS  = MV_WERKS
                              IV_MATNR  = LS_CHK_DEV-MATNR
                            IMPORTING
                              EV_NUMBER = LV_DRUM_NO.

                          <LS_AUFK>-ZZBUNDLE = LV_DRUM_NO.
                          UPDATE AUFK SET ZZBUNDLE = LV_DRUM_NO
                           WHERE AUFNR = <LS_AUFK>-AUFNR.
                          COMMIT WORK AND WAIT.

                          EXIT.
                        WHEN OTHERS.
                          CLEAR LS_CHK_2010.
                          LS_CHK_2010 = LS_CHK_DEV.

                      ENDCASE.
                    ENDIF.

                  ELSE.
*                  상위 오더 찾을수 없다면 해당 오더 찾기 종료처리
                    DELETE LT_AUFK WHERE AUFNR = <LS_AUFK>-AUFNR.
                    EXIT.

                  ENDIF.

                  IF LV_CHK_PRD = ABAP_TRUE.
                    EXIT.
                  ENDIF.
                ENDDO.

            ENDCASE.

          ENDIF.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_INIT_DRUM_NO IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.


  ENDMETHOD.
ENDCLASS.
