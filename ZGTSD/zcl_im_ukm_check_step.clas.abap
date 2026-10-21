class ZCL_IM_UKM_CHECK_STEP definition
  public
  final
  create public .

public section.

  interfaces IF_EX_UKM_CHECK_STEP .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_UKM_CHECK_STEP IMPLEMENTATION.


METHOD IF_EX_UKM_CHECK_STEP~CHECK_STEP.
*FLT_VAL              Importing Type  UKM_CHECK_STEP
*IO_ACCOUNT	          Importing	Type Ref To	CL_UKM_ACCOUNT
*IS_PARAMETERS        Importing Type  UKM_CHCK_STEP
*IS_SGMNT_PARAMETERS  Importing Type  UKM_CHCK_CRSGM
*C_PASSED             Changing  Type  UKM_CHECK_PASSED
*CT_RESULTS           Changing  Type  UKM_T_DENIAL_REASON
*---------------------------------------------------------------------
* 고객의 월령이 61 일 이상이면 메시지를 띄워주며 여신 BLOCK 처리한다
  DATA: LV_KUNNR        TYPE KUNNR,
        LV_BUKRS        TYPE BUKRS,
        LV_PARTNER      TYPE PARTNER,
        LV_CREDIT_SGMNT TYPE UKM_CREDIT_SGMNT,
        LV_KKBER        TYPE KKBER,
        LV_XCRITICAL    TYPE UKMBP_CMS_SGM-XCRITICAL,
        LV_VKGRP        TYPE VKGRP,
        LV_SPMON        TYPE SPMON.

  DATA: LV_STAT TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  DATA: LV_RLT(1),
        LV_MSG2 TYPE BAPI_MSG,
        LV_MESSAGE(200).

  DATA: IT_LIST TYPE TABLE OF ZGTFIS0008,
        ET_LIST TYPE TABLE OF ZGTFIS0009.
  DATA: LV_RYUNG     TYPE P.

*-CREDIT ACCOUNT 의 월령체크 헤제
  SELECT SINGLE XCRITICAL
    INTO LV_XCRITICAL
    FROM UKMBP_CMS_SGM
   WHERE PARTNER      EQ IO_ACCOUNT->AO_BUSINESS_PARTNER->A_PARTNER
     AND CREDIT_SGMNT EQ IO_ACCOUNT->A_CREDIT_SGMNT.

*1. 여신세그먼트가 1번째 자리가 G 인 경우만 대상
*2. 여신세그먼트가 'G600' 인 경우는 제외
*3. 월령체크 해제된 고객 제외 (UKMBP_CMS_SGM-XCRITICAL = 'X' 이면 제외)
  CHECK IO_ACCOUNT->A_CREDIT_SGMNT(1) EQ 'G'.
  CHECK IO_ACCOUNT->A_CREDIT_SGMNT    NE 'G600'.
  CHECK LV_XCRITICAL                  NE 'X'.

  LV_PARTNER      = IO_ACCOUNT->AO_BUSINESS_PARTNER->A_PARTNER.
  LV_CREDIT_SGMNT = IO_ACCOUNT->A_CREDIT_SGMNT.

  "CUSTOMER
  SELECT SINGLE B~CUSTOMER
    INTO LV_KUNNR
    FROM BUT000 AS A INNER JOIN CVI_CUST_LINK AS B
                     ON A~PARTNER_GUID = B~PARTNER_GUID
   WHERE A~PARTNER EQ LV_PARTNER.

  "회사코드/여신영역
  SELECT SINGLE B~BUKRS B~KKBER
    INTO (LV_BUKRS,LV_KKBER)
    FROM UKM_KKBER2SGM AS A INNER JOIN T001CM AS B
                            ON A~KKBER = B~KKBER
   WHERE A~CREDIT_SGMNT EQ LV_CREDIT_SGMNT.

  "영업그룹
  IF LV_KKBER IS NOT INITIAL.
    SELECT SINGLE VKGRP
      INTO LV_VKGRP
      FROM ZGTSDT1012
     WHERE KKBER EQ LV_KKBER.
  ENDIF.

  LV_SPMON = SY-DATLO(6).

  APPEND VALUE #( KUNNR = LV_KUNNR
                  WAERS = 'KRW'
                ) TO IT_LIST.

  CALL FUNCTION 'ZGTFI_AR_COLLECT_INFO'
    EXPORTING
      I_BUKRS = LV_BUKRS
      I_SPMON = LV_SPMON
      I_VKGRP = LV_VKGRP
    IMPORTING
      E_STATS = LV_STAT
      E_MESSG = LV_MSG
    TABLES
      IT_DATA = IT_LIST
      ET_DATA = ET_LIST.
  IF LV_STAT EQ 'S'.
    DATA(LS_LIST) = VALUE #( ET_LIST[ 1 ] OPTIONAL ).
    IF LS_LIST IS NOT INITIAL.
      LV_RYUNG = LS_LIST-O_RYUNG.
      IF LV_RYUNG > 61.
        CLEAR C_PASSED.
        LV_RLT = 'E'.
        MESSAGE E000(ZGTSD01) WITH '월령이 61일 초과 입니다.'
                                   SPACE SPACE SPACE
                              INTO LV_MESSAGE.
      ENDIF.

    ELSE.
      CLEAR C_PASSED.
      LV_RLT = 'E'.
      MESSAGE E000(ZGTSD01) WITH '월령 점검을 수행할 수 없습니다.'
                                 SPACE SPACE SPACE
                            INTO LV_MESSAGE.
    ENDIF.

  ELSE.
    CLEAR C_PASSED.
    LV_RLT = 'E'.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG2 = |월령 점검을 수행할 수 없습니다.({ LV_MSG })|.
    ELSE.
      LV_MSG2 = '월령 점검을 수행할 수 없습니다.'.
    ENDIF.
    MESSAGE E000(ZGTSD01) WITH LV_MSG2(50)
                               LV_MSG2+50(50)
                               LV_MSG2+100(50)
                               LV_MSG2+150(50)
                          INTO LV_MESSAGE.
  ENDIF.

  IF LV_RLT EQ 'E'.
    CALL METHOD CL_UKM_CREDIT_CHECKER=>ADD_REASON
      EXPORTING
        I_CHECK_STEP = FLT_VAL
        IO_ACCOUNT   = IO_ACCOUNT
      CHANGING
        CT_RESULTS   = CT_RESULTS.
  ENDIF.

ENDMETHOD.
ENDCLASS.
