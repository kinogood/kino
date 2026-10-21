*----------------------------------------------------------------------*
***INCLUDE LZGTMM10F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM SET_COM_LOG
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_COM_LOG  USING  PV_TYPE
                                               PV_ZIFNO
                                               PV_ZSTAT
                                               PV_MESSAGE
                                   CHANGING GS_9000 STRUCTURE ZGTMMT9000 .

  CASE PV_TYPE.

    WHEN 'S'. "START

      CLEAR  GS_9000.
*1차 로그_ZGTMMT9000
      GET TIME STAMP FIELD GS_9000-ZIFKEY.

      GS_9000-ZIFNO         = PV_ZIFNO.
      GS_9000-SYSTEM_ID = GV_SYSTEM_ID.
      GS_9000-IFDAT         = SY-DATLO.
      GS_9000-IFTIM          = SY-TIMLO.
      GS_9000-IFNAM        = SY-UNAME.

      MODIFY ZGTMMT9000 FROM GS_9000.

*2차 로그_ZGTMMT9000
    WHEN 'E'. "END

      UPDATE ZGTMMT9000

      SET      ZSTAT             = PV_ZSTAT
                  MESSAGE        = PV_MESSAGE
                  ERDAT             = SY-DATUM
                  ERDAT_LOCAL = SY-DATLO
                  ERTIM              = SY-UZEIT
                  ERTIM_LOCAL  = SY-TIMLO
                  ERNAM            = SY-UNAME

      WHERE ZIFNO              = GS_9000-ZIFNO
           AND ZIFKEY            = GS_9000-ZIFKEY
           AND SYSTEM_ID      = GS_9000-SYSTEM_ID.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_92XX_LOG
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_92XX_LOG  "TABLES PT_9230    "LIKE GT_9230
*                                                PT_PLANT "LIKE GT_9231
*                                                PT_PRICE  "LIKE GT_9232
                                    USING   PV_TYPE
                                                "PS_9230 STRUCTURE ZGTMMT9230
                                                PS_9240 STRUCTURE ZGTMMT9240
                                                PS_9000 STRUCTURE ZGTMMT9000.

  DATA : "LS_9230 LIKE ZGTMMT9230,
             LS_9240 LIKE ZGTMMT9240.
*  DATA : LT_9231 LIKE TABLE OF ZGTMMT9231,
*             LT_9232 LIKE TABLE OF ZGTMMT9232.

  CASE PV_TYPE.

    WHEN 'INFO'. "단가 계약 정보
*1.ZGTMMT9230
*      LS_9230 = VALUE #(
*                      ZIFKEY = GS_9000-ZIFKEY
*                      MATNR = PS_9230-MATNR "I_MATNR
*                      LIFNR   = PS_9230-LIFNR
*                      EKORG = PS_9230-EKORG
*                      ESOKZ = PS_9230-ESOKZ
*                      WAERS = PS_9230-WAERS
*                      DATAB  = PS_9230-DATAB
*                      DATBI   = PS_9230-DATBI
*                      NETPR  = PS_9230-NETPR
*                      PEINH   = PS_9230-PEINH
*                      BPRME = PS_9230-BPRME
*                      EKGRP = PS_9230-EKGRP ).
*      MODIFY ZGTMMT9230 FROM TABLE PT_9230.
*      MODIFY ZGTMMT9230 FROM LS_9230.
*
*2.ZGTMMT9231
*      LT_9231 = VALUE #( BASE LT_9231
*                                     FOR WA1 IN PT_PLANT
*                                   ( VALUE #( BASE CORRESPONDING #( WA1 )
*                                     ZIFKEY = GS_9000-ZIFKEY ) ) ).

*      MODIFY ZGTMMT9231 FROM TABLE PT_PLANT.                "LT_9231.
*
*3.ZGTMMT9232
*      LT_9232 = VALUE #( BASE LT_9232
*                                     FOR WA2 IN PT_PRICE
*                                   ( VALUE #( BASE CORRESPONDING #( WA2 )
*                                     ZIFKEY = GS_9000-ZIFKEY ) ) ).

*      MODIFY ZGTMMT9232 FROM TABLE PT_PRICE.                "LT_9232.


    WHEN 'PO'. "구매오더 확정/반려 업데이트
*ZGTMMT9240
      LS_9240 = VALUE #(
                      ZIFKEY      = GS_9000-ZIFKEY
                      EKORG      = PS_9240-EKORG
                      EBELN       = PS_9240-EBELN
                      ZCONFIRM = PS_9240-ZCONFIRM  ).

      MODIFY ZGTMMT9240 FROM LS_9240.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_INFORECORD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_9231
*&      --> GT_RETURN
*&      --> LV_LAND
*&---------------------------------------------------------------------*
FORM SET_INFORECORD  USING LS_9231 STRUCTURE ZGTMMT9231
                                              PV_LAND
                                              PS_MAIN STRUCTURE ZGTMMS1009
                                              PV_MATNR
                                              PV_PTYPE
                                    CHANGING  PS_MSG STRUCTURE ZGTMMS1002
                                     .
  DATA :
    LS_EINA  TYPE MEWIEINA,
    LS_EEINA TYPE  MEWIEINA,
    LS_EINAX TYPE  MEWIEINAX,
    LS_EINE  TYPE  MEWIEINE,
    LS_EEINE TYPE	MEWIEINE,
    LS_EINEX TYPE  MEWIEINEX.

  DATA:
    COND_VALIDITY TYPE TABLE OF MEWIVALIDITY,
    CONDITION     TYPE TABLE OF MEWICONDITION.

  DATA:
    LT_PRITEM  TYPE TABLE OF BAPIMEREQITEMIMP,
    LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  DATA:
    LT_RETURN LIKE TABLE OF BAPIRET2,
    LT_RTN    LIKE TABLE OF BAPIRETURN.

  DATA: LV_MEINS       TYPE MARA-MEINS,
        LV_NUMERATOR   TYPE UMREZ,
        LV_DENOMINATOR TYPE UMREN.


*PR정보가 있으면, PR 평가금액을 업데이트 한 후 인포레코드 생성 진행.
  IF PS_MAIN-BANFN IS INITIAL.
* 바로 인포레코드 생성
  ELSE.
* PR평가금액 업데이트 후 생성
    CLEAR: LT_PRITEM, LT_PRITEMX, LT_RETURN.

    APPEND VALUE #( PREQ_ITEM  = PS_MAIN-BNFPO
                                PREQ_PRICE = PS_MAIN-NETPR
                                PRICE_UNIT   = PS_MAIN-PEINH ) TO LT_PRITEM.

    APPEND VALUE #( PREQ_ITEM   = PS_MAIN-BNFPO
                                 PREQ_ITEMX = GC_X
                                 PREQ_PRICE  = GC_X
                                 PRICE_UNIT    = GC_X ) TO LT_PRITEMX.

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        NUMBER  = PS_MAIN-BANFN
      TABLES
        RETURN  = LT_RETURN
        PRITEM  = LT_PRITEM
        PRITEMX = LT_PRITEMX.

    IF LINE_EXISTS( LT_RETURN[ TYPE = GC_E ] ) .

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      CLEAR PS_MSG.
      READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
      PERFORM SET_COM_LOG USING 'E' 'MM00024' 'E' LS_RETURN-MESSAGE GS_9000.
      PS_MSG = VALUE #( TYPE        = LS_RETURN-TYPE
                                     MESSAGE = LS_RETURN-MESSAGE ).

      DATA(LV_ERR) = GC_X.
      EXIT.
    ELSE.
      PERFORM BAPI_COMMIT.
      CLEAR LV_ERR.
    ENDIF.
  ENDIF.

  CHECK LV_ERR IS INITIAL.


  CLEAR: LS_EINA, LS_EINAX, LS_EINE, LS_EINEX, COND_VALIDITY, CONDITION, LT_RETURN.

  IF PV_PTYPE = GC_B.

    CLEAR: LV_MEINS, LV_NUMERATOR, LV_DENOMINATOR.

    SELECT SINGLE MEINS FROM MARA
      WHERE MATNR = @PV_MATNR
      INTO @LV_MEINS.

    IF SY-SUBRC <> 0.
      CLEAR PS_MSG.
      PS_MSG = VALUE #( TYPE    = GC_E
                                      CODE    = 'ZMM815'
                                      MESSAGE = |자재 { PV_MATNR }의 기본단위(MEINS)를 찾을 수 없습니다.| ).
      PERFORM SET_COM_LOG USING 'E' 'MM00024' 'E' PS_MSG-MESSAGE GS_9000.
      EXIT.
    ENDIF.

    IF PS_MAIN-BPRME = LV_MEINS.
      LV_NUMERATOR   = 1.
      LV_DENOMINATOR = 1.
    ELSE.
      SELECT SINGLE UMREZ, UMREN FROM MARM
        WHERE MATNR = @PV_MATNR
             AND MEINH = @PS_MAIN-BPRME
        INTO (@LV_NUMERATOR, @LV_DENOMINATOR).

      IF SY-SUBRC <> 0.
        CLEAR PS_MSG.
        PS_MSG = VALUE #( TYPE    = GC_E
                                        CODE    = 'ZMM816'
                                        MESSAGE = |자재 { PV_MATNR }의 { PS_MAIN-BPRME } 단위 환산계수가 등록되어 있지 않습니다.| ).
        PERFORM SET_COM_LOG USING 'E' 'MM00024' 'E' PS_MSG-MESSAGE GS_9000.
        EXIT.
      ENDIF.
    ENDIF.

**--> 26.09 정보레코드 누락 추가 수정
    SELECT SINGLE FROM EINA FIELDS INFNR
           WHERE MATNR EQ @PV_MATNR
             AND LIFNR EQ @PS_MAIN-LIFNR
      INTO @DATA(LV_INFNR).
    IF SY-SUBRC IS INITIAL.
      LS_EINA = VALUE #( INFO_REC = LV_INFNR
                         MATERIAL = PV_MATNR
                         VENDOR   = PS_MAIN-LIFNR ).

      LS_EINAX = VALUE #( INFO_REC = GC_X
                          MATERIAL = GC_X
                          VENDOR   = GC_X ).

    ELSE.
      LS_EINA = VALUE #( MATERIAL = PV_MATNR
                         VENDOR    = PS_MAIN-LIFNR ).

      LS_EINAX = VALUE #( MATERIAL = GC_X
                          VENDOR   = GC_X ).
    ENDIF.

*    LS_EINA = VALUE #( MATERIAL = PV_MATNR
*                                   VENDOR    = PS_MAIN-LIFNR ).
*
*    LS_EINAX = VALUE #( MATERIAL = GC_X
*                                      VENDOR   = GC_X ).
**--< 26.09 정보레코드 누락 추가 수정


    LS_EINE = VALUE #( PURCH_ORG = PS_MAIN-EKORG
                                    PLANT         = LS_9231-WERKS
                                    INFO_TYPE  = PS_MAIN-ESOKZ
                                    DELETE_IND = ''
                                    CURRENCY  = PS_MAIN-WAERS
                                    PUR_GROUP = PS_MAIN-EKGRP
                                    PLND_DELRY = COND #( WHEN LS_9231-APLFZ IS INITIAL
                                                                          THEN GC_1 ELSE LS_9231-APLFZ )
                                    OVERDELTOL = LS_9231-UEBTO
                                    UNDER_TOL   = LS_9231-UNTTO
                                    UNLIMITED     = LS_9231-UEBTK
                                    ACKN_REQD  = LS_9231-KZABS
                                    CONF_CTRL  = LS_9231-BSTAE
                                    NRM_PO_QTY = COND #( WHEN LS_9231-NORBM IS INITIAL
                                                                           THEN GC_1 ELSE LS_9231-NORBM )
                                    MIN_PO_QTY  = LS_9231-MINBM
                                    TAX_CODE     = COND #( WHEN LS_9231-MWSKZ IS INITIAL AND PV_LAND = 'KR' THEN 'VA'
                                                                          WHEN LS_9231-MWSKZ IS INITIAL AND PV_LAND NE 'KR' THEN 'V0'
                                                                          ELSE LS_9231-MWSKZ )
                                    PRICEDATE    = COND #( WHEN LS_9231-MEPRF IS INITIAL AND PV_LAND = 'KR' THEN '5'
                                                                          WHEN LS_9231-MEPRF IS INITIAL AND PV_LAND NE 'KR' THEN SPACE
                                                                          ELSE LS_9231-MEPRF )
                                    INCOTERMS1 = LS_9231-INCO1
                                    GR_BASEDIV  = COND #( WHEN LS_9231-WEBRE IS INITIAL AND PV_LAND = 'KR' THEN GC_X
                                                                         WHEN LS_9231-WEBRE IS INITIAL AND PV_LAND NE 'KR' THEN SPACE
                                                                         ELSE  LS_9231-WEBRE )
                                    VERSION       = COND #( WHEN PS_MAIN-ESOKZ = '3' THEN 'SC01' ELSE SPACE ) ).

    LS_EINEX = VALUE #( PURCH_ORG  = GC_X
                                     PLANT            = GC_X
                                     INFO_TYPE     = GC_X
                                     DELETE_IND   = GC_X
                                     CURRENCY     = GC_X
                                     PUR_GROUP   = GC_X
                                     PLND_DELRY  = GC_X
                                     OVERDELTOL  = COND #( WHEN LS_9231-UEBTO IS INITIAL THEN SPACE ELSE GC_X )
                                     UNDER_TOL    = COND #( WHEN LS_9231-UNTTO IS INITIAL THEN SPACE ELSE GC_X )
                                     UNLIMITED      = COND #( WHEN LS_9231-UEBTK IS INITIAL THEN SPACE ELSE GC_X )
                                     ACKN_REQD   = COND #( WHEN LS_9231-KZABS IS INITIAL THEN SPACE ELSE GC_X )
                                     CONF_CTRL    = COND #( WHEN LS_9231-BSTAE IS INITIAL THEN SPACE ELSE GC_X )
                                     NRM_PO_QTY = GC_X
                                     MIN_PO_QTY  = COND #( WHEN LS_9231-MINBM IS INITIAL THEN SPACE ELSE GC_X )
                                     TAX_CODE     = GC_X
                                     PRICEDATE     = GC_X
                                     INCOTERMS1  = COND #( WHEN LS_9231-INCO1 IS INITIAL THEN SPACE ELSE GC_X )
                                     GR_BASEDIV   = GC_X
                                     VERSION        = COND #( WHEN PS_MAIN-ESOKZ = '3' THEN GC_X ELSE '' ) ).

**--> 26.09.27 플랜트 구매조직 데이터 선생성
*  PO '정보레코드 갱신'으로 구매조직 단위(플랜트 공백)로만 생긴 인포레코드는
*  플랜트 구매조직 데이터와 조건을 한 번에 넣으면 ME816(06725)로 실패
*  → ① 조건 없이 플랜트 구매조직 데이터만 먼저 생성·COMMIT
*    ② 같은 세션은 BAPI 버퍼 때문에 새 플랜트 데이터를 못 보므로 조건 생성은 새 세션(DESTINATION 'NONE')에서 실행
    DATA : LV_NEW_PLANT TYPE ABAP_BOOL,
           LV_RFC_MSG   TYPE C LENGTH 200.
    CLEAR LV_NEW_PLANT.

    IF LV_INFNR IS NOT INITIAL.
      SELECT SINGLE @ABAP_TRUE FROM EINE
        WHERE INFNR = @LV_INFNR
          AND EKORG = @PS_MAIN-EKORG
          AND WERKS = @LS_9231-WERKS
          AND ESOKZ = @PS_MAIN-ESOKZ
        INTO @DATA(LV_EINE_EXIST).
      IF SY-SUBRC <> 0.
        CLEAR LT_RTN.
        CALL FUNCTION 'ME_INFORECORD_MAINTAIN'   "조건 없이 구매조직 데이터만
          EXPORTING
            I_EINA        = LS_EINA
            I_EINAX       = LS_EINAX
            I_EINE        = LS_EINE
            I_EINEX       = LS_EINEX
          TABLES
            COND_VALIDITY = COND_VALIDITY        "이 시점엔 빈 테이블
            CONDITION     = CONDITION            "이 시점엔 빈 테이블
            RETURN        = LT_RTN.

        IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          READ TABLE LT_RTN INTO DATA(LS_RTN_PLANT) WITH KEY TYPE = GC_E.
          CLEAR PS_MSG.
          PS_MSG = VALUE #( TYPE    = GC_E
                            CODE    = LS_RTN_PLANT-CODE
                            MESSAGE = |플랜트 { LS_9231-WERKS } 구매조직 데이터 생성 실패: { LS_RTN_PLANT-MESSAGE }| ).
          PERFORM SET_COM_LOG USING 'E' 'MM00024' 'E' PS_MSG-MESSAGE GS_9000.
          EXIT.
        ENDIF.

        PERFORM BAPI_COMMIT.
        CLEAR LT_RTN.
        LV_NEW_PLANT = ABAP_TRUE.
      ENDIF.
    ENDIF.
**--< 26.09.27 플랜트 구매조직 데이터 선생성

    APPEND VALUE #( SERIAL_ID   = '01'
                                PLANT       = LS_9231-WERKS
                                 BASE_UOM   = LV_MEINS
                                 VALID_FROM = PS_MAIN-DATAB
                                 VALID_TO     = PS_MAIN-DATBI ) TO COND_VALIDITY.

    APPEND VALUE #( SERIAL_ID   = '01'
                                 COND_TYPE   = COND #( WHEN GS_9232-PRE_FEE > 0 THEN 'ZNF1' ELSE 'PB00' )
                                 COND_VALUE  = PS_MAIN-NETPR
                                 CURRENCY      = PS_MAIN-WAERS
                                 COND_P_UNT  = PS_MAIN-PEINH
                                 COND_UNIT     = PS_MAIN-BPRME
                                 BASE_UOM     = LV_MEINS
                                 NUMERATOR    = LV_NUMERATOR
                                 DENOMINATOR = LV_DENOMINATOR ) TO CONDITION.

**--> 26.09.27 플랜트 구매조직 데이터를 방금 만든 경우 조건은 새 세션에서 생성
    IF LV_NEW_PLANT = ABAP_TRUE.
      CALL FUNCTION 'ZGTMM_IF_I_INFODATA_MAINTAIN' DESTINATION 'NONE'
        EXPORTING
          I_EINA                = LS_EINA
          I_EINAX               = LS_EINAX
          I_EINE                = LS_EINE
          I_EINEX               = LS_EINEX
          I_TEST                = SPACE
        IMPORTING
          E_EINA                = LS_EEINA
          E_EINE                = LS_EEINE
        TABLES
          COND_VALIDITY         = COND_VALIDITY
          CONDITION             = CONDITION
          RETURN                = LT_RTN
        EXCEPTIONS
          SYSTEM_FAILURE        = 1 MESSAGE LV_RFC_MSG
          COMMUNICATION_FAILURE = 2 MESSAGE LV_RFC_MSG
          OTHERS                = 3.
      IF SY-SUBRC <> 0.
        APPEND VALUE #( TYPE = GC_E MESSAGE = |조건 생성(새 세션) 호출 실패: { LV_RFC_MSG }| ) TO LT_RTN.
      ENDIF.
      CALL FUNCTION 'RFC_CONNECTION_CLOSE'
        EXPORTING
          DESTINATION = 'NONE'
        EXCEPTIONS
          OTHERS      = 1.
    ELSE.
**--< 26.09.27
    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        I_EINA        = LS_EINA
        I_EINAX       = LS_EINAX
        I_EINE        = LS_EINE
        I_EINEX       = LS_EINEX
      IMPORTING
        E_EINA        = LS_EEINA
        E_EINE        = LS_EEINE
      TABLES
        COND_VALIDITY = COND_VALIDITY
        CONDITION     = CONDITION
        RETURN        = LT_RTN.
    ENDIF.

  ENDIF.

**--> 26.09.27 06725(플랜트 구매조직 데이터 없음)는 BAPI가 S로 돌려주고 아무것도 만들지 않으므로 오류로 처리
  IF LINE_EXISTS( LT_RTN[ CODE = '06725' ] ) AND NOT LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ).
    APPEND VALUE #( TYPE    = GC_E
                    CODE    = '06725'
                    MESSAGE = |플랜트 { LS_9231-WERKS } 구매조직 데이터가 없어 단가가 생성되지 않았습니다| ) TO LT_RTN.
  ENDIF.
**--< 26.09.27

  IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ) .

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR : PS_MSG.
    READ TABLE LT_RTN INTO DATA(LS_RTN) WITH KEY TYPE = 'E'.
    PERFORM SET_COM_LOG USING 'E' 'MM00024' 'E' LS_RTN-MESSAGE GS_9000.

    PS_MSG = VALUE #( TYPE        = LS_RTN-TYPE
                                    CODE       = LS_RTN-CODE
                                    MESSAGE = LS_RTN-MESSAGE ).
    EXIT.

  ELSE.
    IF PV_PTYPE = GC_B.
      PERFORM BAPI_COMMIT.
    ENDIF.

    IF GS_1040 IS NOT INITIAL.
      MODIFY ZGTMMT1040 FROM GS_1040.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT .
      ENDIF.
    ENDIF.

    IF PS_MAIN-BANFN IS NOT INITIAL.
      SELECT FROM ZGTMMT2000
        FIELDS *
        WHERE BANFN = @PS_MAIN-BANFN
             AND BNFPO = @PS_MAIN-BNFPO
            INTO TABLE @DATA(LT_2000).

      IF LT_2000[] IS NOT INITIAL.
        DELETE ZGTMMT2000 FROM TABLE LT_2000.
        IF SY-SUBRC = 0.
          COMMIT WORK AND WAIT .
        ENDIF.
      ENDIF.
    ENDIF.

    IF PV_PTYPE = GC_B.
      PERFORM SET_COM_LOG USING 'E' 'MM00024' 'S' 'INFORECORD MAINTAIN 성공'(M02) GS_9000.
    ELSE.
      PERFORM SET_COM_LOG USING 'E' 'MM00024' 'S' '예가 견적 등록 성공'(M02) GS_9000.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM BAPI_COMMIT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CONFIRM
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_9240
*&---------------------------------------------------------------------*
FORM SET_CONFIRM  USING   PV_CONF TYPE  ZGTE_POCONF
                                              PS_9240 STRUCTURE ZGTMMT9240.

  DATA : LV_MSG   TYPE STRING,
         LV_ETENS TYPE ETENS,
         LV_CODE  TYPE BAPIMMPARA-PO_REL_IND.

  DATA : LS_HEAD  TYPE BAPIMEPOHEADER,
         LS_HEADX TYPE BAPIMEPOHEADERX.

  DATA : LT_XEKES TYPE TABLE OF UEKES,
         LT_YEKES TYPE TABLE OF UEKES.

  DATA : LT_POITEM  LIKE TABLE OF BAPIMEPOITEM,
         LT_POITEMX LIKE TABLE OF BAPIMEPOITEMX.

  SELECT FROM EKPO
  FIELDS *
  WHERE EBELN = @PS_9240-EBELN
       AND LOEKZ IS INITIAL
      INTO TABLE @DATA(LT_EKPO).

  IF LT_EKPO IS NOT INITIAL.
    SORT LT_EKPO BY EBELN EBELP.

    SELECT EBELN, EBELP, ETENS, EBTYP
    FROM EKES "ZGTMM_CV_MAXETENS_EKES
    FOR ALL ENTRIES IN @LT_EKPO
    WHERE EBELN = @LT_EKPO-EBELN
         AND EBELP = @LT_EKPO-EBELP
        INTO TABLE @DATA(LT_EKES).

    SORT LT_EKES BY EBELN EBELP ."EBTYP.
  ENDIF.

  CLEAR GT_RETURN.

  CASE PV_CONF.
*---확정
    WHEN 'C'.
      CLEAR : LS_HEAD, LS_HEADX.
      LS_HEAD = VALUE #( PO_NUMBER = PS_9240-EBELN
                                       REF_1 = PV_CONF ).

      LS_HEADX = VALUE #( PO_NUMBER = PS_9240-EBELN
                                         REF_1 = GC_X ).

      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          PURCHASEORDER = PS_9240-EBELN
          POHEADER      = LS_HEAD
          POHEADERX     = LS_HEADX
        TABLES
          RETURN        = GT_RETURN.

      IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
        PERFORM BAPI_ROLLBACK.
*결과 업데이트_ZGTMMT9000
        READ TABLE GT_RETURN INTO GS_RETURN INDEX 1.
        PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.

      ELSE.
        PERFORM BAPI_COMMIT.
        CLEAR GS_RETURN.
*결과 업데이트_ZGTMMT9000
        PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '구매오더 접수 정보 반영되었습니다.'(m04) GS_9000.
      ENDIF.
*기존로직주석->위 BAPI로 대체.
*      LOOP AT LT_EKPO INTO DATA(LS_EKPO).
*
*        READ TABLE LT_EKES INTO DATA(LS_EKES)
*        WITH KEY EBELN = LS_EKPO-EBELN
*                       EBELP = LS_EKPO-EBELP BINARY SEARCH.
*
*        IF SY-SUBRC = 0.
*          LV_ETENS = LS_EKES-ETENS + 1.  "있으면, 기존데이터에 +1 생성
*        ELSE.
*          LV_ETENS = GC_0001.   " 기존 데이터 없으면, 1부터 생성
*        ENDIF.
*
*        APPEND VALUE #( EBELN  = LS_EKPO-EBELN
*                                     EBELP = LS_EKPO-EBELP
*                                     ETENS = LV_ETENS
*                                     EBTYP = GC_AB
*                                     EINDT  = SY-DATLO
*                                     LPEIN  = GC_1  "NUMBER 1
*                                     UZEIT  = SY-TIMLO
*                                     ERDAT = SY-DATLO
*                                     EZEIT  = SY-TIMLO
*                                     MENGE = LS_EKPO-MENGE
*                                     KZ        = GC_I     "CHARACTOR I
*                                   ) TO LT_XEKES.
*
**기존 확정 정보 있는 것 삭제 하기 위한 세팅
*        IF LS_EKES-EBTYP = GC_AB.
*          APPEND VALUE #(  EBELN  = LS_EKPO-EBELN
*                                        EBELP  = LS_EKPO-EBELP
*                                        ETENS  = LS_EKES-ETENS
*                                        KZ        = GC_D
*                                      ) TO LT_YEKES.
*
*        ELSE.
*          CLEAR LS_EKES.
*          READ TABLE LT_EKES INTO LS_EKES
*          WITH KEY EBELN = LS_EKPO-EBELN
*                         EBELP = LS_EKPO-EBELP
*                         EBTYP = GC_AB BINARY SEARCH.
*
*          IF SY-SUBRC = 0.
*            APPEND VALUE #( EBELN  = LS_EKPO-EBELN
*                                         EBELP  = LS_EKPO-EBELP
*                                         ETENS  = LS_EKES-ETENS
*                                         KZ        = GC_D
*                                       ) TO LT_YEKES.
*          ENDIF.
*        ENDIF.
*
*        CLEAR : LS_EKPO, LS_EKES, LV_ETENS.
*
*      ENDLOOP.
*
*      TRY.
*          CALL FUNCTION 'ME_CONFIRMATION_UPDATE'
*            EXPORTING
*              I_EBELN = PS_9240-EBELN
**             I_UPDATE_CHECK_DEACTIVATED       =
*            TABLES
*              XEKES   = LT_XEKES
*              YEKES   = LT_YEKES.
*        CATCH CX_ROOT INTO DATA(LV_ERROR).
*          LV_MSG = LV_ERROR->GET_TEXT(  ).
*      ENDTRY.
*
**-성공
*      IF SY-SUBRC = 0.
*        CLEAR GS_RETURN.
**생성/변경 결과 업데이트_ZGTMMT9000
*        PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '구매오더 접수 정보 반영 되었습니다.'(M04) GS_9000.
*
**-ERROR.
*      ELSE.
**생성/변경 결과 업데이트_ZGTMMT9000
*        GS_RETURN-MESSAGE = COND #( WHEN LV_MSG IS INITIAL
*                                                             THEN '확정 처리 시 오류가 발생 했습니다.'(M03)
*                                                             ELSE LV_MSG ).
*        PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.
*
*      ENDIF.

*---반려
    WHEN 'R'.

      SELECT SINGLE FRGGR FROM EKKO
        WHERE EBELN = @PS_9240-EBELN
        INTO @DATA(LV_FRGGR).
*  "승인미대상
      IF LV_FRGGR IS INITIAL.
        CLEAR : LS_HEAD, LS_HEADX.

        LS_HEAD = VALUE #( PO_NUMBER = PS_9240-EBELN
                                      REF_1 = PV_CONF ).

        LS_HEADX = VALUE #( PO_NUMBER = PS_9240-EBELN
                                        REF_1 = GC_X ).
*구매오더 헤더 업데이트
        CALL FUNCTION 'BAPI_PO_CHANGE'
          EXPORTING
            PURCHASEORDER = PS_9240-EBELN
            POHEADER      = LS_HEAD
            POHEADERX     = LS_HEADX
          TABLES
            RETURN        = GT_RETURN.

        IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
          PERFORM BAPI_ROLLBACK.
          READ TABLE GT_RETURN INTO GS_RETURN INDEX 1.
          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.

        ELSE.
          PERFORM BAPI_COMMIT.
          CLEAR GS_RETURN.
          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '구매오더 접수 정보 반영되었습니다.'(m04) GS_9000.
        ENDIF.

*"승인대상
      ELSE.
        CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
          EXPORTING
            PURCHASEORDER     = PS_9240-EBELN
            PO_REL_CODE       = 'S1'
            USE_EXCEPTIONS    = GC_X
          IMPORTING
            REL_INDICATOR_NEW = LV_CODE
          TABLES
            RETURN            = GT_RETURN.
        IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
          PERFORM BAPI_ROLLBACK.
          READ TABLE GT_RETURN INTO GS_RETURN INDEX 1.
          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.

        ELSE.
          PERFORM BAPI_COMMIT.
          WAIT UP TO '0.5' SECONDS.
          CLEAR : LS_HEAD, LS_HEADX.

          LS_HEAD = VALUE #( PO_NUMBER = PS_9240-EBELN
                                          REF_1 = PV_CONF ).

          LS_HEADX = VALUE #( PO_NUMBER = PS_9240-EBELN
                                            REF_1 = GC_X ).
*구매오더 헤더 업데이트
          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              PURCHASEORDER = PS_9240-EBELN
              POHEADER      = LS_HEAD
              POHEADERX     = LS_HEADX
            TABLES
              RETURN        = GT_RETURN.

          IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
            PERFORM BAPI_ROLLBACK.
            READ TABLE GT_RETURN INTO GS_RETURN INDEX 1.
            PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.

          ELSE.
            PERFORM BAPI_COMMIT.
            CLEAR GS_RETURN.
            PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '구매오더 접수 정보 반영되었습니다.'(m04) GS_9000.
          ENDIF.

        ENDIF.

      ENDIF.
**기존로직주석->위 BAPI로 대체.
*      LOOP AT LT_EKPO INTO LS_EKPO.
*        CLEAR LS_EKES.
*
*        READ TABLE LT_EKES INTO LS_EKES
*        WITH KEY EBELN = LS_EKPO-EBELN
*                       EBELP = LS_EKPO-EBELP
*                       EBTYP = GC_AB BINARY SEARCH.
*
*        IF SY-SUBRC = 0.
*          APPEND VALUE #( EBELN  = LS_EKPO-EBELN
*                                       EBELP  = LS_EKPO-EBELP
*                                       ETENS  = LS_EKES-ETENS
*                                       KZ        = GC_D
*                                     ) TO LT_YEKES.
*        ENDIF.
*      ENDLOOP.

**-기존 PO 중 EBTYP = AB인 데이터가 없는 경우,PO 삭제(최초반려)
*      IF LT_YEKES IS INITIAL.
*        LT_POITEM = VALUE #( BASE LT_POITEM
*                                            FOR WA1 IN LT_EKPO
*                                            ( VALUE #( PO_ITEM      = WA1-EBELP
*                                                              DELETE_IND = GC_X ) ) ).
*
*        LT_POITEMX = VALUE #( BASE LT_POITEMX
*                                              FOR WA2 IN LT_EKPO
*                                            ( VALUE #( PO_ITEM      = WA2-EBELP
*                                                              PO_ITEMX    = GC_X
*                                                              DELETE_IND = GC_X ) ) ).
*
*        CALL FUNCTION 'BAPI_PO_CHANGE'
*          EXPORTING
*            PURCHASEORDER = PS_9240-EBELN
*          TABLES
*            RETURN        = GT_RETURN
*            POITEM        = LT_POITEM
*            POITEMX       = LT_POITEMX.
*
*        IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
*          PERFORM BAPI_ROLLBACK.
**결과 업데이트_ZGTMMT9000
*          READ TABLE GT_RETURN INTO GS_RETURN INDEX 1.
*          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.
*
*        ELSE.
*          PERFORM BAPI_COMMIT.
*          CLEAR GS_RETURN.
**결과 업데이트_ZGTMMT9000
*          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '반려되었습니다.'(M05) GS_9000.
*        ENDIF.
*
*
**-EBTYP = AB인 데이터가 있는 경우, 업데이트
*      ELSE.
*        TRY.
*            CALL FUNCTION 'ME_CONFIRMATION_UPDATE'
*              EXPORTING
*                I_EBELN = PS_9240-EBELN
**               I_UPDATE_CHECK_DEACTIVATED       =
*              TABLES
*                XEKES   = LT_XEKES
*                YEKES   = LT_YEKES.
*          CATCH CX_ROOT INTO LV_ERROR.
*            LV_MSG = LV_ERROR->GET_TEXT(  ).
*        ENDTRY.
*
**성공
*        IF SY-SUBRC = 0.
*          CLEAR GS_RETURN.
**결과 업데이트_ZGTMMT9000
*          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'S' '접수 해제 되었습니다.'(M06) GS_9000.
*
**ERROR.
*        ELSE.
**결과 업데이트_ZGTMMT9000
*          GS_RETURN-MESSAGE = COND #( WHEN LV_MSG IS INITIAL
*                                                               THEN '접수 해제 시 오류가 발생 했습니다.'(M07)
*                                                                ELSE LV_MSG ).
*          PERFORM SET_COM_LOG USING 'E' 'MM00025' 'E' GS_RETURN-MESSAGE GS_9000.
*
*        ENDIF.
*
*      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_ERROR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> I_TYPE
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM CHECK_ERROR  TABLES PT_TRUCK STRUCTURE ZGTMMS4502
*                                   USING   PV_TYPE
                             CHANGING  PO_RESULT  TYPE ZO_RESULT
                                              PO_MESSAGE TYPE ZO_MESSAGE.

  LOOP AT PT_TRUCK ASSIGNING FIELD-SYMBOL(<FS>).
*0.타입 구분없이 공통 필수 필드 확인
    IF <FS>-BUKRS IS INITIAL OR <FS>-ZREQ_TYPE IS INITIAL OR
      <FS>-DLVRQ IS INITIAL OR <FS>-VBELN IS INITIAL OR <FS>-POSNR IS INITIAL OR
      <FS>-ZTRTYPE IS INITIAL OR <FS>-LOADQTY IS INITIAL OR <FS>-DR_MEINS IS INITIAL .

      PO_RESULT    = GC_02.
      PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
      EXIT.
    ENDIF.

*1.직송의뢰 신청 유형
    CASE <FS>-ZREQ_TYPE.
*1-1.OEM직송
      WHEN GC_A.
*2.직송 거래 운송 방식
        CASE <FS>-ZTRTYPE.
*2-1.운송
          WHEN GC_T.
            IF <FS>-EBELN IS INITIAL OR <FS>-EBELP IS INITIAL OR
               <FS>-REGIONT IS INITIAL OR <FS>-NO2DIGIT IS INITIAL OR
               <FS>-CH1DIGIT IS INITIAL OR <FS>-NO4DIGIT IS INITIAL OR
               <FS>-TEL IS INITIAL OR <FS>-NAME IS INITIAL OR
               <FS>-DELNO IS INITIAL OR <FS>-DELITEM IS INITIAL.

              PO_RESULT    = GC_02.
              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
              EXIT.
            ENDIF.
*2-2.택배
          WHEN GC_S.
            IF <FS>-EBELN IS INITIAL OR <FS>-EBELP IS INITIAL OR <FS>-PARCELNAME IS INITIAL
                 OR <FS>-DELNO IS INITIAL OR <FS>-DELITEM IS INITIAL..

              PO_RESULT    = GC_02.
              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
              EXIT.
            ENDIF.

          WHEN OTHERS.
        ENDCASE.

*1-2.매입 보관품 직송
      WHEN GC_B.
*2.직송 거래 운송 방식
        CASE <FS>-ZTRTYPE.
*2-1.운송
          WHEN GC_T.
            IF <FS>-REGIONT IS INITIAL OR <FS>-NO2DIGIT IS INITIAL OR
               <FS>-CH1DIGIT IS INITIAL OR <FS>-NO4DIGIT IS INITIAL OR
               <FS>-TEL IS INITIAL OR <FS>-NAME IS INITIAL.

              PO_RESULT    = GC_02.
              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
              EXIT.
            ENDIF.
*2-2.택배
          WHEN GC_S.
            IF <FS>-PARCELNAME IS INITIAL.

              PO_RESULT    = GC_02.
              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(e04).
              EXIT.
            ENDIF.

          WHEN OTHERS.
        ENDCASE.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

*20260204주석_위 로직으로 변경_ZGODEV04
*  READ TABLE PT_TRUCK INTO DATA(LS_TRUCK) INDEX 1.
*  IF LS_TRUCK-ZTRTYPE IS INITIAL.
*       PO_RESULT    = GC_02.
*       PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*       EXIT.
*  ENDIF.
*
*   CASE PV_TYPE.
*      WHEN GC_A. ""A: 배차등록
*        IF LS_TRUCK-ZTRTYPE = GC_T.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ REGIONT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO2DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ CH1DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO4DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ TEL = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] )  .
*
*            PO_RESULT    = GC_02.
*            PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*
*        ELSEIF LS_TRUCK-ZTRTYPE = GC_S.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ PARCELNAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] )  .
*
*              PO_RESULT    = GC_02.
*              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*        ENDIF.
*
*       WHEN GC_B OR GC_D. "B:거래명세서 등록/ D:거래명세서 삭제
*        IF LS_TRUCK-ZTRTYPE = GC_T.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZSEQ = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ REGIONT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO2DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ CH1DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO4DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ TEL = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZDOC_NO = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZDOC_ITEM_NO = '' ] )  .
*
*            PO_RESULT    = GC_02.
*            PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*
*        ELSEIF LS_TRUCK-ZTRTYPE = GC_S.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZSEQ = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ PARCELNAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZDOC_NO = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZDOC_ITEM_NO = '' ] ) .
*
*              PO_RESULT    = GC_02.
*              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*        ENDIF.
*
*
*      WHEN GC_C.   "C : 배차삭제
*        IF LS_TRUCK-ZTRTYPE = GC_T.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZSEQ = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ REGIONT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO2DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ CH1DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NO4DIGIT = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ TEL = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ NAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] )   .
*
*            PO_RESULT    = GC_02.
*            PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*
*        ELSEIF LS_TRUCK-ZTRTYPE = GC_S.
*         IF LINE_EXISTS( PT_TRUCK[ BUKRS = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ ZREQ_TYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DLVRQ = '' ] )  OR
*           LINE_EXISTS( PT_TRUCK[ VBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ POSNR = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELN = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ EBELP = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZSEQ = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ ZTRTYPE = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ PARCELNAME = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ LOADQTY = '' ] ) OR
*           LINE_EXISTS( PT_TRUCK[ DR_MEINS = '' ] ) .
*
*              PO_RESULT    = GC_02.
*              PO_MESSAGE = '요청 정보 중 필수 값이 누락 되었습니다.'(E04).
*         ENDIF.
*        ENDIF.
*
*
*      WHEN OTHERS.
*   ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_SAVE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> I_TYPE
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM SET_SAVE  TABLES  PT_DATA STRUCTURE ZGTMMT4403
                              USING   PV_TYPE
                         CHANGING  PO_RESULT  TYPE ZO_RESULT
                                           PO_MESSAGE TYPE ZO_MESSAGE.

  DATA : LT_SAVE LIKE TABLE OF ZGTMMT4403,
         LS_SAVE LIKE ZGTMMT4403.

*변경 정보 기준의 기존 데이터 가져오기..(PV_TYPE 'B,C,D'용)
  SELECT FROM ZGTMMT4403
       FIELDS *
       FOR ALL ENTRIES IN @PT_DATA
       WHERE BUKRS = @PT_DATA-BUKRS
            AND ZREQ_TYPE = @PT_DATA-ZREQ_TYPE
            AND DLVRQ = @PT_DATA-DLVRQ
            AND VBELN = @PT_DATA-VBELN
            AND POSNR = @PT_DATA-POSNR
            AND EBELN = @PT_DATA-EBELN
            AND EBELP = @PT_DATA-EBELP
            AND ZSEQ  = @PT_DATA-ZSEQ
            INTO TABLE @DATA(LT_4403).
  SORT LT_4403 BY BUKRS ZREQ_TYPE DLVRQ VBELN POSNR EBELN EBELP.

*I_TYPE 데이터 별 처리 구분
  CASE PV_TYPE.
    WHEN GC_A.  "배차등록
      LOOP AT PT_DATA INTO DATA(LS_DATA).

        SELECT SINGLE MAX( ZSEQ ) FROM ZGTMMT4403
        WHERE BUKRS = @LS_DATA-BUKRS
            AND ZREQ_TYPE = @LS_DATA-ZREQ_TYPE
            AND DLVRQ = @LS_DATA-DLVRQ
            AND VBELN = @LS_DATA-VBELN
            AND POSNR = @LS_DATA-POSNR
            AND EBELN = @LS_DATA-EBELN
            AND EBELP = @LS_DATA-EBELP
            INTO @DATA(LV_SEQ).

        LS_DATA = VALUE #( BASE CORRESPONDING #( LS_DATA )
                                         ZSEQ = LV_SEQ + 1
                                         ZDOC_DATE = SY-DATLO
                                         ERDAT = SY-DATUM
                                         ERDAT_LOCAL  = SY-DATLO
                                         ERTIM  = SY-UZEIT
                                         ERTIM_LOCAL  = SY-TIMLO
                                         ERNAM  = SY-UNAME
                                         AEDAT =  SY-DATUM
                                         AEDAT_LOCAL =  SY-DATLO
                                         AETIM  = SY-UZEIT
                                         AETIM_LOCAL  = SY-TIMLO
                                         AENAM  = SY-UNAME ) .

        APPEND LS_DATA TO LT_SAVE.
        CLEAR : LS_DATA, LV_SEQ.
      ENDLOOP.

    WHEN GC_B. "거래명세서 등록
      LOOP AT PT_DATA INTO LS_DATA.

        READ TABLE LT_4403 ASSIGNING FIELD-SYMBOL(<FS>)
        WITH KEY BUKRS = LS_DATA-BUKRS
                       ZREQ_TYPE = LS_DATA-ZREQ_TYPE
                       DLVRQ = LS_DATA-DLVRQ
                       VBELN = LS_DATA-VBELN
                       POSNR = LS_DATA-POSNR
                       EBELN = LS_DATA-EBELN
                       EBELP = LS_DATA-EBELP BINARY SEARCH.

        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING <FS> TO LS_SAVE.
          LS_SAVE-ZDOC_NO = LS_DATA-ZDOC_NO.
          LS_SAVE-ZDOC_ITEM_NO = LS_DATA-ZDOC_ITEM_NO.
          LS_SAVE-ZDOC_DATE = LS_DATA-ZDOC_DATE.
          LS_SAVE-AEDAT =  SY-DATUM.
          LS_SAVE-AEDAT_LOCAL =  SY-DATLO.
          LS_SAVE-AETIM  = SY-UZEIT.
          LS_SAVE-AETIM_LOCAL  = SY-TIMLO.
          LS_SAVE-AENAM  = SY-UNAME.

          APPEND LS_SAVE TO LT_SAVE.
          CLEAR : LS_DATA, LS_SAVE.
        ENDIF.

      ENDLOOP.

    WHEN GC_C. "배차삭제

      CLEAR LT_SAVE.
      DELETE ZGTMMT4403 FROM TABLE PT_DATA.

    WHEN GC_D. "거래명세서 삭제
      DATA LV_DATE TYPE DATUM.

      LT_SAVE[] = VALUE #( BASE LT_SAVE FOR WA IN LT_4403
                                        ( VALUE #( BASE CORRESPONDING #( WA )
                                          ZDOC_NO = ''
                                          ZDOC_ITEM_NO = ''
                                          ZDOC_DATE = LV_DATE
                                          AEDAT =  SY-DATUM
                                          AEDAT_LOCAL =  SY-DATLO
                                          AETIM  = SY-UZEIT
                                          AETIM_LOCAL  = SY-TIMLO
                                          AENAM  = SY-UNAME ) ) ).

    WHEN OTHERS.
  ENDCASE.

  IF LT_SAVE[] IS NOT INITIAL.
    MODIFY ZGTMMT4403 FROM TABLE LT_SAVE.
  ENDIF.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
    PO_RESULT    = GC_00."NUMBER 00
    PO_MESSAGE = '직송 배차 정보가 저장 되었습니다.'(m09) .
  ELSE.
    PO_RESULT    = GC_02. "02
    PO_MESSAGE = '직송 배차 정보 등록이 실패하였습니다.'(e08) .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SAVE_DATA_A
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> IT_TRUCK
*&      --> GT_4403
*&      --> GT_4405
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM SAVE_DATA_A  TABLES   PT_TRUCK STRUCTURE ZGTMMS4502
                           CHANGING PO_RESULT
                                            PO_MESSAGE
                                            PO_ZDOC_NO
                                            PO_ZDOC_ITEM.

  DATA : LT_SAVE  TYPE TABLE OF ZGTMMT4403,
         LS_SAVE  TYPE ZGTMMT4403,
         LV_DATE  TYPE DATUM,
         LV_SEQ   TYPE ZGTMMT4403-ZSEQ,
         LV_TABIX TYPE SY-TABIX.


  LOOP AT PT_TRUCK ASSIGNING FIELD-SYMBOL(<FS>).
*OEM 직송요청
    CHECK <FS>-ZREQ_TYPE = GC_A.

    IF GT_4403[] IS INITIAL.
      PO_ZDOC_ITEM  +=  1.
      LS_SAVE = VALUE #( BASE CORRESPONDING #( <FS> )
                                          ZSEQ = LV_SEQ + 1
                                          ZDOC_NO = PO_ZDOC_NO
                                          ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                          ZDOC_DATE = LV_DATE
                                          ERDAT = SY-DATUM
                                          ERDAT_LOCAL = SY-DATLO
                                          ERTIM = SY-UZEIT
                                          ERTIM_LOCAL = SY-TIMLO
                                          ERNAM = SY-UNAME
                                          AEDAT = SY-DATUM
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM = SY-UZEIT
                                          AETIM_LOCAL = SY-TIMLO
                                          AENAM = SY-UNAME  ).
      APPEND LS_SAVE TO LT_SAVE.
*>S.2026.09.28_부여한 순번 등록 → 같은 호출의 같은 PO 품목은 다음 순번(002…)
      APPEND CORRESPONDING TY_4403( LS_SAVE ) TO GT_4403.
*<E.2026.09.28
      CLEAR : LV_SEQ, LS_SAVE.

    ELSE.
      READ TABLE GT_4403 ASSIGNING FIELD-SYMBOL(<FSA>)
      WITH KEY BUKRS = <FS>-BUKRS
                     ZREQ_TYPE = <FS>-ZREQ_TYPE
                     DLVRQ = <FS>-DLVRQ
                     VBELN = <FS>-VBELN
                     POSNR = <FS>-POSNR
                     EBELN = <FS>-EBELN
                     EBELP = <FS>-EBELP BINARY SEARCH.
      LV_TABIX = SY-TABIX. "미존재 시 정렬 유지용 삽입 위치

      IF SY-SUBRC = 0.
        PO_ZDOC_ITEM  +=  1.
        LS_SAVE = VALUE #( BASE CORRESPONDING #( <FS> )
                                      ZSEQ = <FSA>-ZSEQ + 1
                                      ZDOC_NO = PO_ZDOC_NO
                                      ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                      ZDOC_DATE = LV_DATE
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME
                                      AEDAT = SY-DATUM
                                      AEDAT_LOCAL = SY-DATLO
                                      AETIM = SY-UZEIT
                                      AETIM_LOCAL = SY-TIMLO
                                      AENAM = SY-UNAME  ).
        APPEND LS_SAVE TO LT_SAVE.
        <FSA>-ZSEQ = LS_SAVE-ZSEQ.
        CLEAR : LV_SEQ, LS_SAVE.

      ELSE.
        PO_ZDOC_ITEM  +=  1.
        LS_SAVE = VALUE #( BASE CORRESPONDING #( <FS> )
                                          ZSEQ = LV_SEQ + 1
                                          ZDOC_NO = PO_ZDOC_NO
                                          ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                          ZDOC_DATE = LV_DATE
                                          ERDAT = SY-DATUM
                                          ERDAT_LOCAL = SY-DATLO
                                          ERTIM = SY-UZEIT
                                          ERTIM_LOCAL = SY-TIMLO
                                          ERNAM = SY-UNAME
                                          AEDAT = SY-DATUM
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM = SY-UZEIT
                                          AETIM_LOCAL = SY-TIMLO
                                          AENAM = SY-UNAME  ).
        APPEND LS_SAVE TO LT_SAVE.
*>S.2026.09.28_부여한 순번 등록(정렬 위치) → 같은 호출의 같은 PO 품목은 다음 순번
        INSERT CORRESPONDING TY_4403( LS_SAVE ) INTO GT_4403 INDEX LV_TABIX.
*<E.2026.09.28
        CLEAR : LV_SEQ, LS_SAVE.
      ENDIF.

    ENDIF.
  ENDLOOP.


  IF LT_SAVE[] IS NOT INITIAL.
*>S.2026.09.28_기존 배차 줄 덮어쓰기 차단 (MODIFY → INSERT)
*  배차순번이 이미 있으면(동시 수신 등) 전체 취소 후 오류 반환 → G-PRO 재전송
*    MODIFY ZGTMMT4403 FROM TABLE LT_SAVE.
    INSERT ZGTMMT4403 FROM TABLE LT_SAVE ACCEPTING DUPLICATE KEYS.
    IF SY-SUBRC = 4.
      ROLLBACK WORK.
      PO_RESULT  = GC_02.
      PO_MESSAGE = '이미 등록된 배차순번이 있어 저장하지 않았습니다. 다시 전송하세요.'(e25).
      CLEAR PO_ZDOC_NO.
      RETURN.
    ENDIF.
*<E.2026.09.28

    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
      PO_RESULT    = GC_00."NUMBER 00
      PO_MESSAGE = '직송 배차 정보가 저장 되었습니다.'(m09) .

**거래명세서번호 채번
*      CALL FUNCTION 'NUMBER_GET_NEXT'
*        EXPORTING
*          NR_RANGE_NR = '01'
*          OBJECT      = 'ZTRDOCNO'
*        IMPORTING
*          NUMBER      = PO_ZDOC_NO.
*      IF SY-SUBRC <> 0.
** IMPLEMENT SUITABLE ERROR HANDLING HERE
*      ENDIF.

    ELSE.
      PO_RESULT    = GC_02. "02
      PO_MESSAGE = '직송 배차 정보 등록이 실패하였습니다.'(e08) .
      CLEAR PO_ZDOC_NO.
    ENDIF.
  ENDIF.

*  IF LT_SAVE_B[] IS NOT INITIAL.
*    MODIFY ZGTMMT4405 FROM TABLE LT_SAVE_B.
*  ENDIF.

*  IF ( LT_SAVE[] IS NOT INITIAL OR LT_SAVE_B[] IS NOT INITIAL ) AND SY-SUBRC = 0.
*    COMMIT WORK AND WAIT.
*    PO_RESULT    = GC_00."NUMBER 00
*    PO_MESSAGE = '직송 배차 정보가 저장 되었습니다.'(M09) .
*
**거래명세서번호 채번
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        NR_RANGE_NR = '01'
*        OBJECT      = 'ZTRDOCNO'
*      IMPORTING
*        NUMBER      = PO_ZDOC_NO.
*    IF SY-SUBRC <> 0.
** IMPLEMENT SUITABLE ERROR HANDLING HERE
*    ENDIF.
*
*  ELSEIF ( LT_SAVE[] IS NOT INITIAL OR LT_SAVE_B[] IS NOT INITIAL ) AND SY-SUBRC NE 0.
*    PO_RESULT    = GC_02. "02
*    PO_MESSAGE = '직송 배차 정보 등록이 실패하였습니다.'(E08) .
*    CLEAR PO_ZDOC_NO.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SAVE_DATA_B
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> IT_TRUCK
*&      --> GT_4403
*&      --> GT_4405
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM SAVE_DATA_B  TABLES   PT_TRUCK STRUCTURE ZGTMMS4502
                                     CHANGING PO_RESULT
                                                     PO_MESSAGE
                                                     PO_ZDOC_NO
                                                     PO_ZDOC_ITEM.
  DATA :
    LT_SAVE_B TYPE TABLE OF ZGTMMT4405,
    LS_SAVE_B TYPE ZGTMMT4405,
    LV_DATE   TYPE DATUM,
    LV_SEQ    TYPE ZGTMMT4403-ZSEQ,
    LV_TABIX  TYPE SY-TABIX.

  LOOP AT PT_TRUCK ASSIGNING FIELD-SYMBOL(<FS>).
*보관 매입 재고 직송
    CHECK <FS>-ZREQ_TYPE = GC_B.

    IF GT_4405[] IS INITIAL.
      PO_ZDOC_ITEM  +=  1.
      LS_SAVE_B = VALUE #( BASE CORRESPONDING #( <FS> )
                                      ZSEQ = LV_SEQ + 1
                                      ZDOC_NO = PO_ZDOC_NO
                                      ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                      ZDOC_DATE = LV_DATE
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME
                                      AEDAT = SY-DATUM
                                      AEDAT_LOCAL = SY-DATLO
                                      AETIM = SY-UZEIT
                                      AETIM_LOCAL = SY-TIMLO
                                      AENAM = SY-UNAME  ).
      APPEND LS_SAVE_B TO LT_SAVE_B.
*>S.2026.09.28_부여한 순번 등록 → 같은 호출의 같은 판매오더 품목은 다음 순번
      APPEND CORRESPONDING TY_4405( LS_SAVE_B ) TO GT_4405.
*<E.2026.09.28
      CLEAR : LV_SEQ, LS_SAVE_B.

    ELSE.
      READ TABLE GT_4405 ASSIGNING FIELD-SYMBOL(<FSB>)
      WITH KEY BUKRS = <FS>-BUKRS
                     ZREQ_TYPE = <FS>-ZREQ_TYPE
                     DLVRQ = <FS>-DLVRQ
                     VBELN = <FS>-VBELN
                     POSNR = <FS>-POSNR  BINARY SEARCH.
      LV_TABIX = SY-TABIX. "미존재 시 정렬 유지용 삽입 위치

      IF SY-SUBRC = 0.
        PO_ZDOC_ITEM  +=  1.
        LS_SAVE_B = VALUE #( BASE CORRESPONDING #( <FS> )
                                      ZSEQ = <FSB>-ZSEQ + 1
                                      ZDOC_NO = PO_ZDOC_NO
                                      ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                      ZDOC_DATE = LV_DATE
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME
                                      AEDAT = SY-DATUM
                                      AEDAT_LOCAL = SY-DATLO
                                      AETIM = SY-UZEIT
                                      AETIM_LOCAL = SY-TIMLO
                                      AENAM = SY-UNAME  ).
        APPEND LS_SAVE_B TO LT_SAVE_B.
        <FSB>-ZSEQ = LS_SAVE_B-ZSEQ.
        CLEAR LS_SAVE_B.

      ELSE.
        PO_ZDOC_ITEM  +=  1.
        LS_SAVE_B = VALUE #( BASE CORRESPONDING #( <FS> )
                                          ZSEQ = LV_SEQ + 1
                                          ZDOC_NO = PO_ZDOC_NO
                                          ZDOC_ITEM_NO = PO_ZDOC_ITEM
                                          ZDOC_DATE = LV_DATE
                                          ERDAT = SY-DATUM
                                          ERDAT_LOCAL = SY-DATLO
                                          ERTIM = SY-UZEIT
                                          ERTIM_LOCAL = SY-TIMLO
                                          ERNAM = SY-UNAME
                                          AEDAT = SY-DATUM
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM = SY-UZEIT
                                          AETIM_LOCAL = SY-TIMLO
                                          AENAM = SY-UNAME  ).
        APPEND LS_SAVE_B TO LT_SAVE_B.
*>S.2026.09.28_부여한 순번 등록(정렬 위치)
        INSERT CORRESPONDING TY_4405( LS_SAVE_B ) INTO GT_4405 INDEX LV_TABIX.
*<E.2026.09.28
        CLEAR : LV_SEQ, LS_SAVE_B.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LT_SAVE_B[] IS NOT INITIAL.
*>S.2026.09.28_기존 배차 줄 덮어쓰기 차단 (MODIFY → INSERT)
*    MODIFY ZGTMMT4405 FROM TABLE LT_SAVE_B.
    INSERT ZGTMMT4405 FROM TABLE LT_SAVE_B ACCEPTING DUPLICATE KEYS.
    IF SY-SUBRC = 4.
      ROLLBACK WORK.
      PO_RESULT  = GC_02.
      PO_MESSAGE = '이미 등록된 배차순번이 있어 저장하지 않았습니다. 다시 전송하세요.'(e25).
      CLEAR PO_ZDOC_NO.
      RETURN.
    ENDIF.
*<E.2026.09.28

    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
      PO_RESULT    = GC_00."NUMBER 00
      PO_MESSAGE = '직송 배차 정보가 저장 되었습니다.'(m09) .
*
**거래명세서번호 채번
*      CALL FUNCTION 'NUMBER_GET_NEXT'
*        EXPORTING
*          NR_RANGE_NR = '01'
*          OBJECT      = 'ZTRDOCNO'
*        IMPORTING
*          NUMBER      = PO_ZDOC_NO.
*      IF SY-SUBRC <> 0.
** IMPLEMENT SUITABLE ERROR HANDLING HERE
*      ENDIF.

    ELSE.
      PO_RESULT    = GC_02. "02
      PO_MESSAGE = '직송 배차 정보 등록이 실패하였습니다.'(e08) .
      CLEAR PO_ZDOC_NO.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_TRUCK_LOG_END
*&---------------------------------------------------------------------*
*& 배차정보 수신(ZGTMM_IF_I_TRUCK_INFO) 호출 로그 종료 - 2026.09.28
*& 1) ZGTMMT4406 : 수신 원문(ZGTMMS4502) 행별 + SAP 저장 결과
*&    (저장 테이블, SAP 부여 배차순번, 거래명세서번호/항번)
*&    거래명세서 항번은 SAVE_DATA_A(A행) → SAVE_DATA_B(B행) 순서로
*&    수신 순서대로 1부터 매겨지므로, 같은 규칙으로 행과 저장 결과를 연결
*& 2) ZGTMMT9000(MM00048) MESSAGE : 결과 / 거래명세서번호 / 건수 / 납품서-항번
*&    (MESSAGE 220자 초과분은 잘림)
*&---------------------------------------------------------------------*
*&      --> PT_TRUCK   : 수신 배차 데이터(IT_TRUCK)
*&      --> PV_RESULT  : ZO_RESULT
*&      --> PV_MESSAGE : ZO_MESSAGE
*&      --> PV_ZDOC_NO : 채번한 거래명세서번호(저장 실패 시 공백)
*&---------------------------------------------------------------------*
FORM SET_TRUCK_LOG_END TABLES PT_TRUCK STRUCTURE ZGTMMS4502
                        USING  PV_RESULT
                               PV_MESSAGE
                               PV_ZDOC_NO.

  DATA : LV_LOGMSG TYPE ZGTEBAPIMSG,
         LV_DELIST TYPE STRING,
         LV_ZSTAT  TYPE C LENGTH 1,
         LT_4406   TYPE TABLE OF ZGTMMT4406,
         LV_ITEM   TYPE ZGTMMT4403-ZDOC_ITEM_NO.

*1) 수신 원문 행별 이력(ZGTMMT4406)
  LOOP AT PT_TRUCK ASSIGNING FIELD-SYMBOL(<LS_TRUCK>).
    APPEND VALUE #( BASE CORRESPONDING #( <LS_TRUCK> )
                    ZIFKEY    = GS_9000-ZIFKEY
                    SYSTEM_ID = GS_9000-SYSTEM_ID
                    ZLINE     = SY-TABIX
                    ZRESULT   = PV_RESULT
                    ZMESSAGE  = PV_MESSAGE
                    IFDAT     = GS_9000-IFDAT
                    IFTIM     = GS_9000-IFTIM
                    IFNAM     = SY-UNAME ) TO LT_4406.

    LV_DELIST = COND #( WHEN LV_DELIST IS INITIAL
                        THEN |{ <LS_TRUCK>-DELNO }-{ <LS_TRUCK>-DELITEM }|
                        ELSE |{ LV_DELIST },{ <LS_TRUCK>-DELNO }-{ <LS_TRUCK>-DELITEM }| ).
  ENDLOOP.

*   SAP 저장 결과 연결(거래명세서번호가 있을 때 = 저장 성공)
  IF PV_ZDOC_NO IS NOT INITIAL.
    SELECT ZDOC_ITEM_NO, ZSEQ
      FROM ZGTMMT4403
     WHERE ZDOC_NO = @PV_ZDOC_NO
      INTO TABLE @DATA(LT_SEQ_A).

    SELECT ZDOC_ITEM_NO, ZSEQ
      FROM ZGTMMT4405
     WHERE ZDOC_NO = @PV_ZDOC_NO
      INTO TABLE @DATA(LT_SEQ_B).

    CLEAR LV_ITEM.
    LOOP AT LT_4406 ASSIGNING FIELD-SYMBOL(<LS_4406>) WHERE ZREQ_TYPE = GC_A.
      LV_ITEM += 1.
      <LS_4406>-ZTABNM       = 'ZGTMMT4403'.
      <LS_4406>-ZDOC_NO      = PV_ZDOC_NO.
      <LS_4406>-ZDOC_ITEM_NO = LV_ITEM.
      READ TABLE LT_SEQ_A INTO DATA(LS_SEQ_A) WITH KEY ZDOC_ITEM_NO = LV_ITEM.
      IF SY-SUBRC = 0.
        <LS_4406>-ZSEQ_SAP = LS_SEQ_A-ZSEQ.
      ENDIF.
    ENDLOOP.

    LOOP AT LT_4406 ASSIGNING <LS_4406> WHERE ZREQ_TYPE = GC_B.
      LV_ITEM += 1.
      <LS_4406>-ZTABNM       = 'ZGTMMT4405'.
      <LS_4406>-ZDOC_NO      = PV_ZDOC_NO.
      <LS_4406>-ZDOC_ITEM_NO = LV_ITEM.
      READ TABLE LT_SEQ_B INTO DATA(LS_SEQ_B) WITH KEY ZDOC_ITEM_NO = LV_ITEM.
      IF SY-SUBRC = 0.
        <LS_4406>-ZSEQ_SAP = LS_SEQ_B-ZSEQ.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF LT_4406[] IS NOT INITIAL.
    MODIFY ZGTMMT4406 FROM TABLE @LT_4406.
  ENDIF.

*2) 호출 로그 종료(ZGTMMT9000)
  LV_LOGMSG = |{ PV_RESULT } { PV_MESSAGE } / 거래명세서 { PV_ZDOC_NO } / { LINES( PT_TRUCK ) }건 / { LV_DELIST }|.

  LV_ZSTAT = COND #( WHEN PV_RESULT = GC_00 THEN 'S' ELSE 'E' ).
  PERFORM SET_COM_LOG USING 'E' GC_MM00048 LV_ZSTAT LV_LOGMSG
                   CHANGING GS_9000.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DAILY_RESULT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_RESULT
*&      --> LT_1042
*&---------------------------------------------------------------------*
FORM SET_DAILY_RESULT  TABLES   PT_RESULT  STRUCTURE ZGTMMS9002
                                                         PT_4272.

*
*LT_RESULT SUM                    "LZGTMM10F01 LINE 1271~
*(FM -> SET_DAILY_RESULT 서브루틴)"   "LT_RESULT = OT_RESULT
*(I/F 변경후) MATNR가 PO별로 쪼개져서 들어오게 됨
*--> ZGTMMT4272는 MATNR 키값이므로 MATNR 기준으로 말아올려야 함"        LT_RESULT 자체를 가공하면 안될 것 같음 (기존 로직 영향도)
*                       "1) PT_RESULT-MATNR 기준 아래 필드를 SUM 하여 별도 ITAB에 저장
*DRM_COUNT, BOARD_COUNT, MARK_COUNT, DIS_COUNT
*
*2) LOOP AT PT_RESULT를 1)에서 저장한 ITAB으로 변경"
*

  DATA:
    BEGIN OF LS_KEY,
      EKORG TYPE ZGTMMS9002-EKORG,
      WERKS TYPE ZGTMMS9002-WERKS,
      LIFNR TYPE ZGTMMS9002-LIFNR,
      MATNR TYPE ZGTMMS9002-MATNR,
      ZDATE TYPE ZGTMMS9002-ZDATE,
    END OF LS_KEY,
    LT_KEY  LIKE HASHED TABLE OF LS_KEY WITH UNIQUE KEY EKORG WERKS LIFNR MATNR ZDATE,
    LT_4272 TYPE SORTED TABLE OF ZGTMMT4272 WITH UNIQUE KEY EKORG WERKS LIFNR ZDATE MATNR,
    LS_4272 TYPE ZGTMMT4272.


  LOOP AT PT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
    READ TABLE LT_KEY WITH TABLE KEY EKORG = <LS_RESULT>-EKORG
                                                     WERKS = <LS_RESULT>-WERKS
                                                     LIFNR = <LS_RESULT>-LIFNR
                                                     MATNR = <LS_RESULT>-MATNR
                                                     ZDATE = <LS_RESULT>-ZDATE TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC NE 0.
    LT_KEY[] = VALUE #( BASE LT_KEY ( CORRESPONDING #( <LS_RESULT> ) ) ).
  ENDLOOP.

  "인포레코드
  SELECT
    EE~EKORG,
    EE~WERKS,
    EA~LIFNR,
    EA~MATNR,
    ZZ~ZDATE,
    KP~KBETR
    FROM EINA AS EA
                INNER JOIN
              EINE AS EE ON EA~INFNR EQ EE~INFNR
                INNER JOIN
              A017 AS AA ON EA~LIFNR EQ AA~LIFNR
                              AND EA~MATNR EQ AA~MATNR
                              AND EE~EKORG EQ AA~EKORG
                              AND EE~WERKS EQ AA~WERKS
                              AND EE~ESOKZ EQ AA~ESOKZ
                INNER JOIN
              KONH AS KH ON AA~KNUMH EQ KH~KNUMH
                                AND AA~KAPPL EQ KH~KAPPL
                                AND AA~KSCHL EQ KH~KSCHL
                INNER JOIN
              KONP AS KP ON KH~KNUMH EQ KP~KNUMH
                               AND KH~KAPPL EQ KP~KAPPL
                               AND KH~KSCHL EQ KP~KSCHL
                INNER JOIN
             @LT_KEY AS ZZ ON EE~EKORG EQ ZZ~EKORG
                                 AND EE~WERKS EQ ZZ~WERKS
                                 AND EA~LIFNR EQ ZZ~LIFNR
                                 AND EA~MATNR EQ ZZ~MATNR
                                 AND AA~DATAB LE ZZ~ZDATE
                                 AND AA~DATBI GE ZZ~ZDATE
    WHERE EA~LOEKZ EQ @SPACE
    AND EE~LOEKZ EQ @SPACE
    AND KP~LOEVM_KO EQ @SPACE
    AND EE~ESOKZ EQ '3'
    AND AA~KAPPL EQ 'M'
    AND AA~KSCHL EQ 'PB00'
    ORDER BY ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~MATNR, ZZ~ZDATE
    INTO TABLE @DATA(LT_INFO).
  CLEAR LT_KEY[].


  LOOP AT PT_RESULT ASSIGNING FIELD-SYMBOL(<FS>).

    LS_4272 = CORRESPONDING #( <FS> ).
*목드럼 단가 데이터 가져오기.
    READ TABLE GT_1042 WITH KEY BUKRS = <FS>-BUKRS
                                                    EKORG = <FS>-EKORG
                                                    WERKS = <FS>-WERKS
                                                      LIFNR = <FS>-LIFNR
                                                     ZYEAR = <FS>-ZDATE(4)
                                                     MATNR = <FS>-MATNR
    INTO DATA(LS_1042) BINARY SEARCH.

    IF SY-SUBRC = 0.
      LS_4272-DRM_TYPE       = LS_1042-DRM_TYPE.
      LS_4272-DRM_LV           = LS_1042-DRM_LV.
      LS_4272-DRM_SG_TYPE = LS_1042-DRM_SG_TYPE.
      LS_4272-DRM_NETPR     = LS_1042-GDR_NETPR.
      LS_4272-BOARD_NETPR = LS_1042-BOARD_NETPR.
      LS_4272-MARK_NETPR   = LS_1042-MARK_NETPR.
      LS_4272-MARK_N_NETPR   = LS_1042-MARK_NETPR.
      LS_4272-MARK_H_NETPR   = LS_1042-MARK_H_NETPR.
      LS_4272-DIS_NETPR       = LS_1042-DIS_NETPR.
      LS_4272-WAERS            = LS_1042-WAERS.
      LS_4272-MEINS             = LS_1042-MEINS.
      LS_4272-PEINH              = LS_1042-PEINH.
      LS_4272-BPRME            = LS_1042-BPRME.
    ENDIF.

*신드럼은 INFO RECORD 단가 정보로 설정.
    IF LS_4272-DRM_SG_TYPE = GC_S.
*      SELECT SINGLE KBETR
*        FROM ZGTMM_CV_GET_INFOPRICE
*        WHERE LIFNR = @<FS>-LIFNR
*             AND MATNR = @<FS>-MATNR
*             AND EKORG = @<FS>-EKORG
*             AND WERKS = @<FS>-WERKS
*             AND DATAB <= @<FS>-ZDATE
*             AND DATBI >= @<FS>-ZDATE INTO @DATA(LV_KBETR).
*
*      IF LV_KBETR IS NOT INITIAL.
*        LS_4272-DRM_NETPR = LV_KBETR.
*        CLEAR LV_KBETR.
*      ENDIF.
      READ TABLE LT_INFO ASSIGNING FIELD-SYMBOL(<LS_INFO>) WITH KEY EKORG = LS_4272-EKORG
                                                                                                         WERKS = LS_4272-WERKS
                                                                                                         LIFNR = LS_4272-LIFNR
                                                                                                         MATNR = LS_4272-MATNR
                                                                                                         ZDATE = LS_4272-ZDATE BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LS_4272-DRM_NETPR = <LS_INFO>-KBETR.
      ENDIF.
    ENDIF.

    LS_4272-DRM_PRICE = LS_4272-DRM_COUNT * LS_4272-DRM_NETPR.             "드럼입고금액
    LS_4272-BOARD_PRICE = LS_4272-BOARD_COUNT * LS_4272-BOARD_NETPR. "골판지조립금액
    LS_4272-MARK_PRICE = LS_4272-MARK_COUNT * LS_4272-MARK_NETPR. "신드럼마킹금액
    LS_4272-MARK_N_PRICE = LS_4272-MARK_N_COUNT * LS_4272-MARK_N_NETPR. "일반마킹
    LS_4272-MARK_H_PRICE = LS_4272-MARK_H_COUNT * LS_4272-MARK_H_NETPR. "한전마킹
    LS_4272-DIS_PRICE = LS_4272-DIS_COUNT * LS_4272-DIS_NETPR.             "고드럼해체금액

    LS_4272-ERDAT = SY-DATUM.
    LS_4272-ERDAT_LOCAL = SY-DATLO.
    LS_4272-ERTIM = SY-UZEIT.
    LS_4272-ERTIM_LOCAL = SY-TIMLO.
    LS_4272-ERNAM = SY-UNAME.

    READ TABLE LT_4272 ASSIGNING FIELD-SYMBOL(<LS_4272>) WITH TABLE KEY EKORG = LS_4272-EKORG
                                                                                                                   WERKS = LS_4272-WERKS
                                                                                                                   LIFNR = LS_4272-LIFNR
                                                                                                                   ZDATE = LS_4272-ZDATE
                                                                                                                   MATNR = LS_4272-MATNR.
    IF SY-SUBRC EQ 0.
      <LS_4272>-DRM_COUNT += LS_4272-DRM_COUNT.
      <LS_4272>-BOARD_COUNT += LS_4272-BOARD_COUNT.
      <LS_4272>-MARK_COUNT += LS_4272-MARK_COUNT.
      <LS_4272>-MARK_N_COUNT += LS_4272-MARK_N_COUNT.
      <LS_4272>-MARK_H_COUNT += LS_4272-MARK_H_COUNT.
      <LS_4272>-DIS_COUNT += LS_4272-DIS_COUNT.

      <LS_4272>-DRM_PRICE += LS_4272-DRM_PRICE.
      <LS_4272>-BOARD_PRICE += LS_4272-BOARD_PRICE.
      <LS_4272>-MARK_PRICE += LS_4272-MARK_PRICE.
      <LS_4272>-MARK_N_PRICE += LS_4272-MARK_N_PRICE.
      <LS_4272>-MARK_H_PRICE += LS_4272-MARK_H_PRICE.
      <LS_4272>-DIS_PRICE += LS_4272-DIS_PRICE.
    ELSE.
      INSERT LS_4272 INTO TABLE LT_4272.
    ENDIF.
  ENDLOOP.

  PT_4272[] = LT_4272[]. "리턴 값

*
*  DATA LS_4272 TYPE ZGTMMT4272.
*
*  LOOP AT PT_RESULT ASSIGNING FIELD-SYMBOL(<FS>).
*
*    LS_4272 = CORRESPONDING #( <FS> ).
**목드럼 단가 데이터 가져오기.
*    READ TABLE GT_1042 WITH KEY BUKRS = <FS>-BUKRS
*                                                    EKORG = <FS>-EKORG
*                                                    WERKS = <FS>-WERKS
*                                                      LIFNR = <FS>-LIFNR
*                                                     ZYEAR = <FS>-ZDATE(4)
*                                                     MATNR = <FS>-MATNR
*    INTO DATA(LS_1042) BINARY SEARCH.
*
*    IF SY-SUBRC = 0.
*      LS_4272-DRM_TYPE       = LS_1042-DRM_TYPE.
*      LS_4272-DRM_LV           = LS_1042-DRM_LV.
*      LS_4272-DRM_SG_TYPE = LS_1042-DRM_SG_TYPE.
*      LS_4272-DRM_NETPR     = LS_1042-GDR_NETPR.
*      LS_4272-BOARD_NETPR = LS_1042-BOARD_NETPR.
*      LS_4272-MARK_NETPR   = LS_1042-MARK_NETPR.
*      LS_4272-DIS_NETPR       = LS_1042-DIS_NETPR.
*      LS_4272-WAERS            = LS_1042-WAERS.
*      LS_4272-MEINS             = LS_1042-MEINS.
*      LS_4272-PEINH              = LS_1042-PEINH.
*      LS_4272-BPRME            = LS_1042-BPRME.
*    ENDIF.
*
**신드럼은 INFO RECORD 단가 정보로 설정.
*    IF LS_4272-DRM_SG_TYPE = GC_S.
*      SELECT SINGLE KBETR
*        FROM ZGTMM_CV_GET_INFOPRICE
*        WHERE LIFNR = @<FS>-LIFNR
*             AND MATNR = @<FS>-MATNR
*             AND EKORG = @<FS>-EKORG
*             AND WERKS = @<FS>-WERKS
*             AND DATAB <= @<FS>-ZDATE
*             AND DATBI >= @<FS>-ZDATE INTO @DATA(LV_KBETR).
*
*      IF LV_KBETR IS NOT INITIAL.
*        LS_4272-DRM_NETPR = LV_KBETR.
*        CLEAR LV_KBETR.
*      ENDIF.
*    ENDIF.
*
*    LS_4272-DRM_PRICE = LS_4272-DRM_COUNT * LS_4272-DRM_NETPR.             "드럼입고금액
*    LS_4272-BOARD_PRICE = LS_4272-BOARD_COUNT * LS_4272-BOARD_NETPR. "골판지조립금액
*    LS_4272-MARK_PRICE = LS_4272-MARK_COUNT * LS_4272-MARK_NETPR. "신드럼마킹금액
*    LS_4272-DIS_PRICE = LS_4272-DIS_COUNT * LS_4272-DIS_NETPR.             "고드럼해체금액
*
*    LS_4272-ERDAT = SY-DATUM.
*    LS_4272-ERDAT_LOCAL = SY-DATLO.
*    LS_4272-ERTIM = SY-UZEIT.
*    LS_4272-ERTIM_LOCAL = SY-TIMLO.
*    LS_4272-ERNAM = SY-UNAME.
*
*    APPEND LS_4272 TO PT_4272.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT  CHANGING   PV_MATNR.
*40->18
  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_INPUT  CHANGING   PV_MATNR.
*18->40
  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- IT_MAIN
*&      <-- IT_PLANT
*&      <-- IT_PRICE
*&---------------------------------------------------------------------*
FORM CONV_DATA  TABLES  PT_PRICE STRUCTURE ZGTMMS1013.

  DATA : LS_PRICE TYPE ZGTMMS1001.   "IT_PRICE  ZGTMMS1013
  CLEAR GT_PRICE.

  LOOP AT PT_PRICE ASSIGNING FIELD-SYMBOL(<FSP>).

    CLEAR LS_PRICE.

    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CU_QT WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CU_PRC WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CU_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-AL_QT WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-AL_PRC WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-AL_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CUTAPE_QT WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CUTAPE_PRC WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-CUTAPE_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-RQ_RAW_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND1_QT WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND1_PRC WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND1_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND2_QT WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND2_PRC WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-COMPOUND1_SUM WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-MAT_COST WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-PAK_COST WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-MFG_COST WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN <FSP>-LMEPRICE WITH ''.

    CONDENSE <FSP>-CU_QT NO-GAPS.
    CONDENSE <FSP>-CU_PRC NO-GAPS.
    CONDENSE <FSP>-CU_SUM NO-GAPS.
    CONDENSE <FSP>-AL_QT NO-GAPS.
    CONDENSE <FSP>-AL_PRC NO-GAPS.
    CONDENSE <FSP>-AL_SUM NO-GAPS.
    CONDENSE <FSP>-CUTAPE_QT NO-GAPS.
    CONDENSE <FSP>-CUTAPE_PRC NO-GAPS.
    CONDENSE <FSP>-CUTAPE_SUM NO-GAPS.
    CONDENSE <FSP>-RQ_RAW_SUM NO-GAPS.
    CONDENSE <FSP>-COMPOUND1_QT NO-GAPS.
    CONDENSE <FSP>-COMPOUND1_PRC NO-GAPS.
    CONDENSE <FSP>-COMPOUND1_SUM NO-GAPS.
    CONDENSE <FSP>-COMPOUND2_QT NO-GAPS.
    CONDENSE <FSP>-COMPOUND2_PRC NO-GAPS.
    CONDENSE <FSP>-COMPOUND1_SUM NO-GAPS.
    CONDENSE <FSP>-MAT_COST NO-GAPS.
    CONDENSE <FSP>-PAK_COST NO-GAPS.
    CONDENSE <FSP>-MFG_COST NO-GAPS.
    CONDENSE <FSP>-LMEPRICE  NO-GAPS.

    LS_PRICE = CORRESPONDING #( <FSP> ).
    APPEND LS_PRICE TO GT_PRICE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_GR_SEND_LOG
*&---------------------------------------------------------------------*
*& 입고실적 전송(ZGTMM_IF_O_GR_RESULT_SEND) 전송 이력
*& 2026.09.28 : ZGTMMT9426 - 호출(ZIFKEY)마다 반환 행 전체 저장
*& 2026.09.29 : ZGTMMT9427 - 라인당 1행으로 변경(저장량 축소)
*&   키 = SYSTEM_ID + 조회기간(SDATE/EDATE) + 납품서/항번 + 자재문서/품목
*&   처음 보낸 호출(FIRST_*)은 유지, 마지막 보낸 호출(LAST_*)·전송 값은 갱신
*&   SEND_CNT = 그 라인이 포함된 호출 수
*&   이번 호출에 없는 기존 라인은 LAST_*가 갱신되지 않음
*&   → LAST_ZIFKEY가 그 조회기간의 마지막 호출보다 이르면 "중간에 빠진 라인"
*& 같은 품목이 한 호출에 2행 이상이면 1행만 저장
*& COMMIT은 호출부의 SET_COM_LOG('E')에서 수행
*&---------------------------------------------------------------------*
*&      --> PT_TAB    : 이번 호출 반환 데이터(OT_TAB)
*&      --> PV_SDATE  : 조회 시작일(I_SDATE)
*&      --> PV_EDATE  : 조회 종료일(I_EDATE)
*&---------------------------------------------------------------------*
FORM SET_GR_SEND_LOG TABLES PT_TAB STRUCTURE ZGTMMS1011
                      USING  PV_SDATE TYPE DATUM
                             PV_EDATE TYPE DATUM.

  DATA:
    LT_LOG TYPE SORTED TABLE OF ZGTMMT9427
                WITH UNIQUE KEY DELNO DELITEM MJAHR MBLNR ZEILE,
    LS_LOG TYPE ZGTMMT9427.

  CHECK PT_TAB[] IS NOT INITIAL.

*1) 이번 호출 반환 행 구성
  LOOP AT PT_TAB ASSIGNING FIELD-SYMBOL(<LS_TAB>).

    "ZGTMMS1011 전송 값 그대로(필드 동일), 키 MBLNR만 내부형식
    LS_LOG = CORRESPONDING #( <LS_TAB> ).
    LS_LOG-MBLNR = |{ <LS_TAB>-MBLNR ALPHA = IN }|.

    READ TABLE LT_LOG TRANSPORTING NO FIELDS
      WITH TABLE KEY DELNO   = LS_LOG-DELNO
                     DELITEM = LS_LOG-DELITEM
                     MJAHR   = LS_LOG-MJAHR
                     MBLNR   = LS_LOG-MBLNR
                     ZEILE   = LS_LOG-ZEILE.
    IF SY-SUBRC = 0.
      CONTINUE.   "같은 품목 중복 행은 1행만 저장
    ENDIF.

    LS_LOG-SYSTEM_ID    = GS_9000-SYSTEM_ID.
    LS_LOG-SDATE        = PV_SDATE.
    LS_LOG-EDATE        = PV_EDATE.
    "PO 직접입고는 DELNO에 EBELN을 채워 보냄
    LS_LOG-ZPATH        = COND #( WHEN <LS_TAB>-DELNO = <LS_TAB>-EBELN THEN 'P' ELSE 'D' ).
    LS_LOG-FIRST_ZIFKEY = LS_LOG-LAST_ZIFKEY = GS_9000-ZIFKEY.
    LS_LOG-FIRST_IFDAT  = LS_LOG-LAST_IFDAT  = GS_9000-IFDAT.
    LS_LOG-FIRST_IFTIM  = LS_LOG-LAST_IFTIM  = GS_9000-IFTIM.
    LS_LOG-SEND_CNT     = 1.

    INSERT LS_LOG INTO TABLE LT_LOG.
  ENDLOOP.

*2) 같은 조회기간의 기존 이력 : 처음 보낸 호출 유지, 송신 횟수 누적
  SELECT DELNO, DELITEM, MJAHR, MBLNR, ZEILE,
         FIRST_ZIFKEY, FIRST_IFDAT, FIRST_IFTIM, SEND_CNT
    FROM ZGTMMT9427
   WHERE SYSTEM_ID = @GS_9000-SYSTEM_ID
     AND SDATE     = @PV_SDATE
     AND EDATE     = @PV_EDATE
    INTO TABLE @DATA(LT_OLD).

  LOOP AT LT_OLD ASSIGNING FIELD-SYMBOL(<LS_OLD>).
    READ TABLE LT_LOG ASSIGNING FIELD-SYMBOL(<LS_LOG>)
      WITH TABLE KEY DELNO   = <LS_OLD>-DELNO
                     DELITEM = <LS_OLD>-DELITEM
                     MJAHR   = <LS_OLD>-MJAHR
                     MBLNR   = <LS_OLD>-MBLNR
                     ZEILE   = <LS_OLD>-ZEILE.
    CHECK SY-SUBRC = 0.   "이번 호출에 없는 라인은 그대로 둠(LAST_* 미갱신)

    <LS_LOG>-FIRST_ZIFKEY = <LS_OLD>-FIRST_ZIFKEY.
    <LS_LOG>-FIRST_IFDAT  = <LS_OLD>-FIRST_IFDAT.
    <LS_LOG>-FIRST_IFTIM  = <LS_OLD>-FIRST_IFTIM.
    <LS_LOG>-SEND_CNT     = <LS_OLD>-SEND_CNT + 1.
  ENDLOOP.

  MODIFY ZGTMMT9427 FROM TABLE @LT_LOG.

ENDFORM.
