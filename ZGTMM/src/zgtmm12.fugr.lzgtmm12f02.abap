*----------------------------------------------------------------------*
***INCLUDE LZGTMM12F02.

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_CONV_EXIT_IN_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_TAB
*&---------------------------------------------------------------------*
FORM F_CONV_EXIT_IN_DRGR_RCV  CHANGING CT_TAB TYPE TY_T_ZGTMMS4012.

  LOOP AT CT_TAB ASSIGNING FIELD-SYMBOL(<LS_TAB>).
    <LS_TAB>-EBELN = |{ <LS_TAB>-EBELN ALPHA = IN }|.
    <LS_TAB>-EBELP = |{ <LS_TAB>-EBELP ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_TAB>-MATNR
      IMPORTING
        OUTPUT = <LS_TAB>-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_TAB>-MEINS
      IMPORTING
        OUTPUT = <LS_TAB>-MEINS.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_VALUES_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&      --> LT_TAB
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_VALUES_DRGR_RCV  USING     PV_SYSTEM_ID
                                    PT_TAB TYPE TY_T_ZGTMMS4012
                                    PT_TAB2 TYPE TY_T_ZGTMMS4014 "2026.08.06추가
                           CHANGING CV_ZO_RESULT
                                    CV_ZO_MESSAGE.

  FIELD-SYMBOLS <LS_TAB> TYPE ZGTMMS4012.
  FIELD-SYMBOLS <LS_TAB2> TYPE ZGTMMS4014. "2026.08.06추가

*  1-1) Import Parameter 중 필수 전송 정보가 없는 경우 다음 값 Return 후 종료
* Export Parameter                      Value
* ZO_RESULT                     "02"
* ZO_MESSAGE                      "필수 값이 누락되었습니다."

  IF PV_SYSTEM_ID EQ SPACE.
    CV_ZO_RESULT = GC_02.
    CV_ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

  CHECK CV_ZO_RESULT NE GC_02.
*MES 입고수신 이력 점검용
  ##ITAB_KEY_IN_SELECT
  SELECT "MAX( Z22~ZIFKEY ) AS ZIFKEY, "마지막 수신 이력
                     Z22~SYSTEM_ID, Z22~DR_LABEL_NO,
                     Z22~EBELN, Z22~EBELP,
                     Z23~MBLNR, Z23~MJAHR,
                     MAT~CANCELLED AS CANCEL, "취소상태 점검
                     MAT~REVERSAL_MOVEMENT AS REVERSAL

          FROM ZGTMMT9422 AS Z22
          INNER JOIN ZGTMMT9423 AS Z23
          ON   Z23~ZIFKEY = Z22~ZIFKEY
          AND Z23~SYSTEM_ID = Z22~SYSTEM_ID
          LEFT OUTER JOIN MATDOC AS MAT"ZGTMM_CV_GET_MATDOC AS MAT  "2026.08.12 CDS->MATDOC으로 변경
          ON MAT~MBLNR = Z23~MBLNR
          AND MAT~MJAHR = Z23~MJAHR

      "자재문서가 있는 것 중 가장 큰 ZIFKEY
           WHERE Z23~MBLNR NE ''
                AND Z23~ZIFKEY = ( SELECT MAX( SUB23~ZIFKEY )
                         FROM ZGTMMT9422 AS SUB22
                        INNER JOIN ZGTMMT9423 AS SUB23
                           ON SUB23~ZIFKEY    = SUB22~ZIFKEY
                          AND SUB23~SYSTEM_ID = SUB22~SYSTEM_ID
                        WHERE  SUB22~EBELN       = Z22~EBELN
                            AND SUB22~EBELP       = Z22~EBELP
                            AND SUB23~MBLNR      NE '' )

           AND EXISTS ( SELECT @ABAP_TRUE
                                    FROM @PT_TAB AS ZZ
                                    WHERE ZZ~DR_LABELNO = Z22~DR_LABEL_NO
                                        AND ZZ~EBELN = Z22~EBELN
                                        AND ZZ~EBELP = Z22~EBELP            )
*          GROUP BY Z22~SYSTEM_ID, Z22~DR_LABEL_NO, Z22~EBELN, Z22~EBELP,
*                           Z23~MBLNR, Z23~MJAHR,
*                           MAT~CANCELLED, MAT~REVERSAL_MOVEMENT
          INTO TABLE @DATA(LT_MES).
  SORT LT_MES BY DR_LABEL_NO EBELN EBELP.

  LOOP AT PT_TAB ASSIGNING <LS_TAB>.
*1)품목범주 체크.
    IF <LS_TAB>-PSTYP NE SPACE AND <LS_TAB>-PSTYP NE GC_3.
      CV_ZO_RESULT = GC_02.
      CV_ZO_MESSAGE = TEXT-E03.
      EXIT.
    ENDIF.
*2)MES 수신 이력&자재문서 체크
*수신 이력 존재하고, 자재문서가 취소된 상태가 아니면 오류 메시지 리턴.
*취소상태 아닌 자재문서 존재 건은 입고 완료 된 것이므로..
    READ TABLE LT_MES ASSIGNING FIELD-SYMBOL(<MES>)
    WITH KEY DR_LABEL_NO = <LS_TAB>-DR_LABELNO
                   EBELN = <LS_TAB>-EBELN
                   EBELP = <LS_TAB>-EBELP BINARY SEARCH.

    IF SY-SUBRC = 0.
      CHECK <MES>-MBLNR IS NOT INITIAL AND
                 <MES>-CANCEL IS INITIAL AND <MES>-REVERSAL IS INITIAL.
      CV_ZO_RESULT = GC_02.
      CV_ZO_MESSAGE = TEXT-E04. "입고 처리 된 라벨 번호 입니다.
      EXIT.
    ENDIF.
  ENDLOOP.

*>S.2026.08.06_OEM 드럼라벨-납품문서 상태 점검 추가
  CHECK PT_TAB2[] IS NOT INITIAL. "IT_TAB2 수신 시에만..
*ZGTMMT9410_수신 상태 값 체크용
##ITAB_KEY_IN_SELECT
  SELECT MAX( Z10~ZIFKEY ) AS ZIFKEY,
                     Z10~SYSTEM_ID,
                     Z10~DELNO , Z10~DELITEM ,
                     Z10~EBELN , Z10~EBELP ,
                     Z10~STATUS

          FROM ZGTMMT9410 AS Z10
          WHERE EXISTS ( SELECT @ABAP_TRUE
                                    FROM @PT_TAB2 AS ZZ1
                                  WHERE ZZ1~DELNO = Z10~DELNO
                                      AND ZZ1~DELITEM = Z10~DELITEM
                                      AND ZZ1~WERKS = Z10~WERKS
                                  )
                    AND Z10~STATUS = 'X'

          GROUP BY Z10~SYSTEM_ID, Z10~DELNO , Z10~DELITEM ,
                           Z10~EBELN, Z10~EBELP, Z10~STATUS
          INTO TABLE @DATA(LT_9410).

  CHECK LT_9410 IS NOT INITIAL.
  SORT LT_9410 BY DELNO DELITEM.

  LOOP AT PT_TAB2 ASSIGNING <LS_TAB2>.
*1)납품문서 수신이력 점검
    READ TABLE LT_9410 ASSIGNING FIELD-SYMBOL(<DELNO>)
    WITH KEY  DELNO = <LS_TAB2>-DELNO
                    DELITEM = <LS_TAB2>-DELITEM BINARY SEARCH.

    IF SY-SUBRC = 0 .
      CV_ZO_RESULT = GC_02.
      CV_ZO_MESSAGE = TEXT-E06. "삭제된 납품문서, 항번입니다.
      EXIT.
    ENDIF.

  ENDLOOP.
*>E.2026.08.06_ZGODEV04.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_PO_RESB_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM F_GET_PO_RESB_DRGR_RCV  USING  PT_TAB TYPE TY_T_ZGTMMS4012
                             CHANGING CT_RESB TYPE TY_T_PO_RESB_POGR_RCV.

*3-2-4-3) 납품문서 투입실적, 임가공 투입정보 테이블 정보가 존재하지 않는 경우
* Component 자재 정보추출(PO_COMP)
*Table : RESB
*Select조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
  ##ITAB_KEY_IN_SELECT
  SELECT
    EP~EBELN,
    EP~EBELP,
    EP~MENGE,
    RS~RSNUM,
    RS~RSPOS,
    RS~BDMNG,
    RS~MATNR,
    RS~MEINS,
    RS~WERKS,
    RS~LGORT,
    RS~CHARG,
    MC~XCHPF,
    EK~LIFNR
    FROM EKPO AS EP
              INNER JOIN
            RESB AS RS ON EP~EBELN EQ RS~EBELN
                          AND EP~EBELP EQ RS~EBELP
              INNER JOIN
            MARC AS MC ON RS~MATNR EQ MC~MATNR
                             AND RS~WERKS EQ MC~WERKS
              INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
    WHERE EP~PSTYP EQ @GC_3
    AND EXISTS (
      SELECT ZZ~EBELN, ZZ~EBELP
        FROM @PT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
           AND ZZ~EBELP EQ EP~EBELP
    )
    AND EP~LOEKZ EQ @SPACE
    AND RS~XLOEK EQ @SPACE
    ORDER BY EP~EBELN, EP~EBELP, RS~RSNUM, RS~RSPOS
    INTO TABLE @CT_RESB.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_ZGTMMT9450_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM F_GET_ZGTMMT9450_DRGR_RCV  USING    PT_TAB TYPE TY_T_ZGTMMS4012
                                CHANGING PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450.

*3-2-4-3) 납품문서 투입실적, 임가공 투입정보 테이블 정보가 존재하지 않는 경우
* Component 자재 정보추출(PO_COMP)
*Table : RESB
*Select조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
  ##ITAB_KEY_IN_SELECT
  SELECT
    Z1~EBELN,
    Z1~EBELP,
    Z1~WERKS,
    Z1~IDNRK,
    Z1~CHARG,
    Z1~MENGE,
    Z1~MEINS
    FROM ZGTMMT9450 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
      FROM @PT_TAB AS ZZ
      WHERE ZZ~EBELN EQ Z1~EBELN
        AND ZZ~EBELP EQ Z1~EBELP
        AND ZZ~WERKS EQ Z1~WERKS
    )
    ORDER BY Z1~EBELN, Z1~EBELP, Z1~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTMMT9450.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_MSLB_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RESB
*&      <-- LT_MSLB
*&---------------------------------------------------------------------*
FORM F_GET_MSLB_DRGR_RCV  USING PT_RESB TYPE TY_T_PO_RESB_POGR_RCV
                          CHANGING CT_MSLB TYPE TY_T_MSLB_POGR_RCV.

*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 batch 번호 추출 투입 처리(선입 선출 기준)
*Table : MSLB
*Select 조건 : LBLAB 0 이 아닌 CHARG
*Where 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR"
*"Batch 별 투입 시 지정된 Batch가 단일 배치단위이면 (MCH1-XPCBT='X')
*Batch 가용재고전량투입 처리"

  DATA:
    BEGIN OF LS_KEY,
      MATNR TYPE MSLB-MATNR,
      WERKS TYPE MSLB-WERKS,
      LIFNR TYPE MSLB-LIFNR,
    END OF LS_KEY,
    LT_KEY LIKE STANDARD TABLE OF LS_KEY.

  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  "Key 생성
  SELECT DISTINCT
    ZZ~MATNR,
    ZZ~WERKS,
    ZZ~LIFNR
    FROM @PT_RESB AS ZZ
    WHERE ZZ~XCHPF EQ @ABAP_TRUE
    AND ZZ~CHARG EQ @SPACE
    APPENDING TABLE @LT_KEY.

  "재고조회
  ##ITAB_KEY_IN_SELECT
  SELECT
    MS~MATNR,
    MS~WERKS,
    MS~CHARG,
    MS~LIFNR,
    MS~LBLAB,
    MC~XPCBT
    FROM @LT_KEY AS ZZ
              INNER JOIN
            MSLB AS MS ON ZZ~MATNR EQ MS~MATNR
                              AND ZZ~WERKS EQ MS~WERKS
                              AND ZZ~LIFNR EQ MS~LIFNR
              INNER JOIN
            MCH1 AS MC ON MS~MATNR EQ MC~MATNR
                             AND MS~CHARG EQ MC~CHARG
    WHERE MS~LBLAB IS NOT INITIAL
    ORDER BY MS~MATNR, MS~WERKS, MS~LIFNR, MC~LWEDT, MS~CHARG
    INTO TABLE @CT_MSLB.

  "부분수량 GI 허용 플래그
  ##ITAB_KEY_IN_SELECT
  SELECT MM~MATNR
    FROM MARM AS MM
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_MSLB AS ZZ
        WHERE ZZ~MATNR EQ MM~MATNR
    )
    AND MM~ATINN IS NOT INITIAL
    AND MM~PCBUT EQ @GC_B
    ORDER BY MM~MATNR
    INTO TABLE @DATA(LT_MARM).

  LOOP AT CT_MSLB ASSIGNING FIELD-SYMBOL(<LS_MSLB>).
    READ TABLE LT_MARM WITH KEY MATNR = <LS_MSLB>-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_MSLB>-XPRGI = ABAP_TRUE.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_PO_DISPO_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_DISPO
*&---------------------------------------------------------------------*
FORM F_GET_PO_DISPO_DRGR_RCV  USING  PT_TAB TYPE TY_T_ZGTMMS4012
                             CHANGING CT_DISPO TYPE TY_T_PO_DISPO_POGR_RCV.
  ##ITAB_KEY_IN_SELECT
  SELECT
    EP~EBELN,
    EP~EBELP,
    MC~DISPO
    FROM EKPO AS EP
              INNER JOIN
            MARC AS MC ON EP~WERKS EQ MC~WERKS
                          AND EP~MATNR EQ MC~MATNR
    WHERE EXISTS (
      SELECT ZZ~EBELN, ZZ~EBELP
        FROM @PT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
           AND ZZ~EBELP EQ EP~EBELP
    )
    ORDER BY EP~EBELN, EP~EBELP
    INTO TABLE @CT_DISPO.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GOODSMVT_HEADER_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_GROUP1>_PSTYP
*&      --> <LS_GROUP2>_BUDAT
*&      <-- LS_HEADER
*&---------------------------------------------------------------------*
FORM F_SET_GOODSMVT_HEADER_DRGR_RCV  USING    PV_PSTYP
                                              PV_BUDAT
                                     CHANGING CS_HEADER TYPE BAPI2017_GM_HEAD_01.

  "초기화
  CLEAR CS_HEADER.
  CS_HEADER-PSTNG_DATE = PV_BUDAT.
  CS_HEADER-DOC_DATE = PV_BUDAT.
  CS_HEADER-PR_UNAME = SY-UNAME.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GOODSMVT_ITEM_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_TAB>
*&      --> LT_RESB
*&      --> LT_MSLB
*&      --> LT_ZGTMMT9450
*&      <-- LT_ITEM
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_GOODSMVT_ITEM_DRGR_RCV  USING  "PS_TAB TYPE ZGTMMS4012
                                                                                PT_RESB TYPE TY_T_PO_RESB_POGR_RCV
                                                                                PT_MSLB TYPE TY_T_MSLB_POGR_RCV
                                                                                PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                                                PT_PO TYPE TY_T_PO_DRGR_RCV
                                                                                PT_VC TYPE TY_T_BATCH_VC_VALUE
                                                                                PV_ITEMTXT "26.08.06추가
                                   CHANGING PS_TAB TYPE ZGTMMS4012
                                                   CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM,
    LV_STATUS  TYPE BAPI1003_KEY-STATUS,
    LV_LENTH    TYPE ATWRT30.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB_POGR_RCV.
  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

  LS_ITEM-MATERIAL = PS_TAB-MATNR.
  LS_ITEM-PLANT = PS_TAB-WERKS.
  LS_ITEM-STGE_LOC = PS_TAB-LGORT.
  LS_ITEM-PO_NUMBER = PS_TAB-EBELN.
  LS_ITEM-PO_ITEM = PS_TAB-EBELP.
  LS_ITEM-MOVE_TYPE = GC_101.
  LS_ITEM-BATCH = PS_TAB-CHARG.
  LS_ITEM-ENTRY_QNT = PS_TAB-MENGE.
  LS_ITEM-ENTRY_UOM = PS_TAB-MEINS.
  LS_ITEM-MVT_IND = GC_B.
*>S.1)기존ITEM_TEXT에 설정하던 드럼라벨번호를 UNLOAD_PT로 변경
*  LS_ITEM-ITEM_TEXT = PS_TAB-DR_LABELNO.
  LS_ITEM-UNLOAD_PT = PS_TAB-DR_LABELNO.
*2)ITEM_TEXT는 납품서 &품목 조합으로 변경
  LS_ITEM-ITEM_TEXT = PV_ITEMTXT.
*<E.2026.08.06

  "STCK_TYPE  EKPO-INSMK
  READ TABLE PT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>) WITH KEY EBELN = PS_TAB-EBELN
                                                                                                  EBELP = PS_TAB-EBELP BINARY SEARCH.

  IF SY-SUBRC EQ 0.
    LS_ITEM-STCK_TYPE = <LS_PO>-INSMK.
  ENDIF.

*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정 위해 담아두기
  SELECT SINGLE  DPCBT
      FROM MARC
    WHERE MATNR EQ @PS_TAB-MATNR
         AND WERKS EQ @PS_TAB-WERKS
        INTO @DATA(LV_DPCBT).

  CASE PS_TAB-PSTYP.
*      	Case1. 일반 입고 : IT_TAB-PSTYP = ""
    WHEN SPACE. "일반
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC>)
      WITH KEY EBELN = PS_TAB-EBELN
                     EBELP = PS_TAB-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
        PS_TAB-CHARG_NEW = LS_ITEM-BATCH.

      ELSE.
*FACTOR BATCH 아니면,
*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정
        SELECT SINGLE
          MTART
          FROM MARA
          WHERE MATNR EQ @PS_TAB-MATNR
          INTO @DATA(LV_MTART).

        IF LV_MTART EQ 'HAWA'.
*          SELECT SINGLE  DPCBT
*            FROM MARC
*            WHERE MATNR EQ @PS_TAB-MATNR
*                 AND WERKS EQ @PS_TAB-WERKS
*            INTO @DATA(LV_DPCBT).  "LINE 463으로 이동_260804

          CASE LV_DPCBT.
*2-2)'A' OR 공백이면 Default 값 채번_배치번호 : GO00000001"
            WHEN 'A' OR SPACE.
              LS_ITEM-BATCH = 'GO00000001'.
*2-1)MARC-DPCBT = 'C'->자동채번
            WHEN 'C'.
              LS_ITEM-BATCH = PS_TAB-CHARG.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC2>)
      WITH KEY EBELN = PS_TAB-EBELN
                     EBELP = PS_TAB-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VC2>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
        PS_TAB-CHARG_NEW = LS_ITEM-BATCH.
      ENDIF.
  ENDCASE.

*>S.26.08.06_3-2) 배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
*BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
  IF LV_DPCBT = 'A'. "FACTOR BATCH
    CLEAR LV_LENTH.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
    READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC3>)
    WITH KEY EBELN = PS_TAB-EBELN
                   EBELP = PS_TAB-EBELP BINARY SEARCH.
    IF SY-SUBRC = 0.
      LV_LENTH = CONV I( <VC3>-LENGTH ).
      CONDENSE LV_LENTH NO-GAPS.
    ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL         = PS_TAB-MATNR "입고자재
        PLANT              = PS_TAB-WERKS "플랜트
        CLASSTYPE      = '023'       "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

      CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
      CLEAR LT_ALC_NUM.
      LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                              ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                VALUE_FROM = LV_LENTH )
                                              ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                 VALUE_FROM = LV_LENTH ) ).
      CLEAR : LT_RETURN.
      SELECT SINGLE CUOBJ_BM
                 FROM MCH1
               WHERE MATNR = @PS_TAB-MATNR
                    AND CHARG = @LS_ITEM-BATCH
               INTO @DATA(LV_OBJKEY).

      IF LV_OBJKEY IS NOT INITIAL.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
                  CLOBJECTKEY             = LV_OBJKEY
                  CLASSNUM                  = LV_CLASS
          IMPORTING
                 CLASSIF_STATUS            = LV_STATUS
          TABLES
                  ALLOCVALUESNUM_NEW        = LT_ALC_NUM
                  ALLOCVALUESCHAR_NEW       = LT_ALLOC
                  ALLOCVALUESCURR_NEW       = LT_ALC_CURR
                  RETURN                    = LT_RETURN
                      .
        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*      오류
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
*      배치특성 성공
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.
  ENDIF.
*<E.26.08.06_ZGODEV04.

  LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

  CHECK PS_TAB-PSTYP EQ GC_3. "외주 임가공인 경우

*3-2-4-2) Component 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*Component 자재 항목 라인별로 BAPI ITEM 라인 추가
  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB_POGR_RCV.
  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.

  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
  LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

  READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_TAB-EBELN
                                                            EBELP = PS_TAB-EBELP
                                                            WERKS = PS_TAB-WERKS BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*Table : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*
*조회된  Component 자재,배치별 BAPI ITEM 라인 추가

    LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

      LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
      LS_COMP-PLANT = PS_TAB-WERKS.
      LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
      LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
      LS_COMP-MOVE_TYPE = GC_543.
      LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
      LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
      LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

      IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
        LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.
      ELSE.

        READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                              EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                              MATNR = <LS_ZGTMMT9450>-IDNRK.
        IF SY-SUBRC EQ 0.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = PS_TAB-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
        ELSE.
          CV_CHECK = GC_E.
          EXIT.
        ENDIF.
      ENDIF.

      LS_COMP-LINE_ID += 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).

    ENDLOOP.

  ELSE.
    "PO Component 기준
    READ TABLE PT_RESB WITH KEY EBELN = PS_TAB-EBELN
                                              EBELP = PS_TAB-EBELP BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE PS_TAB-EBELN
          OR <LS_RESB>-EBELP NE PS_TAB-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
        LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
        LS_COMP-MOVE_TYPE = GC_543.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = PS_TAB-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.
        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.


        "라인추가
        IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 batch 번호 추출 투입 처리(선입 선출 기준)
*Table : MSLB
*Select 조건 : LBLAB 0 이 아닌 CHARG
*Where 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                     WERKS = <LS_RESB>-WERKS
                                                     LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"Batch 별 투입 시 지정된 Batch가 단일 배치단위이면 (MCH1-XPCBT='X')
*Batch 가용재고전량투입 처리"
* & 부분수량 GI 허용이 space 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          ENDIF.
        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
        ENDIF.

      ENDLOOP.
    ENDIF.


  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GOODSMVT_ITEM_DRGR_RCV2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_TAB>
*&      --> LT_RESB
*&      --> LT_MSLB
*&      --> LT_ZGTMMT9450
*&      <-- LT_ITEM
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_GOODSMVT_ITEM_DRGR_RCV2  USING  "PS_TAB TYPE ZGTMMS4012
                                                                                PT_RESB TYPE TY_T_PO_RESB_POGR_RCV
                                                                                PT_MSLB TYPE TY_T_MSLB_POGR_RCV
                                                                                PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                                                                PT_PO TYPE TY_T_PO_DRGR_RCV
                                                                                PT_VC TYPE TY_T_BATCH_VC_VALUE
                                                                                PV_ITEMTXT "26.08.06추가
                                   CHANGING PS_TAB TYPE ZGTMMS4012
                                                    PS_TAB2 TYPE ZGTMMS4014
                                                   CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                                    CV_CHECK.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM,
    LV_STATUS  TYPE BAPI1003_KEY-STATUS,
    LV_LENTH    TYPE ATWRT30.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB_POGR_RCV.
  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

  LS_ITEM-MATERIAL = PS_TAB-MATNR.
  LS_ITEM-PLANT = PS_TAB-WERKS.
  LS_ITEM-STGE_LOC = PS_TAB-LGORT.
  LS_ITEM-PO_NUMBER = PS_TAB-EBELN.
  LS_ITEM-PO_ITEM = PS_TAB-EBELP.
  LS_ITEM-MOVE_TYPE = GC_101.
  LS_ITEM-BATCH = PS_TAB-CHARG.
  LS_ITEM-ENTRY_QNT = PS_TAB-MENGE.
  LS_ITEM-ENTRY_UOM = PS_TAB-MEINS.
  LS_ITEM-MVT_IND = GC_B.
*>S.1)기존ITEM_TEXT에 설정하던 드럼라벨번호를 UNLOAD_PT로 변경
*  LS_ITEM-ITEM_TEXT = PS_TAB-DR_LABELNO.
  LS_ITEM-UNLOAD_PT = PS_TAB-DR_LABELNO.
*2)ITEM_TEXT는 납품서 &품목 조합으로 변경
  LS_ITEM-ITEM_TEXT = PV_ITEMTXT.
*<E.2026.08.06

  "STCK_TYPE  EKPO-INSMK
  READ TABLE PT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>) WITH KEY EBELN = PS_TAB-EBELN
                                                                                                  EBELP = PS_TAB-EBELP BINARY SEARCH.

  IF SY-SUBRC EQ 0.
    LS_ITEM-STCK_TYPE = <LS_PO>-INSMK.
  ENDIF.

*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정 위해 담아두기
  SELECT SINGLE  DPCBT
      FROM MARC
    WHERE MATNR EQ @PS_TAB-MATNR
         AND WERKS EQ @PS_TAB-WERKS
        INTO @DATA(LV_DPCBT).

  CASE PS_TAB-PSTYP.
*      	Case1. 일반 입고 : IT_TAB-PSTYP = ""
    WHEN SPACE. "일반
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC>)
      WITH KEY EBELN = PS_TAB-EBELN
                     EBELP = PS_TAB-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VC>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
        PS_TAB-CHARG_NEW = LS_ITEM-BATCH.

      ELSE.
*FACTOR BATCH 아니면,
*2)처리 자재의  자재유형이 HAWA 일때, 배치관리유형에 따라 설정
        SELECT SINGLE
          MTART
          FROM MARA
          WHERE MATNR EQ @PS_TAB-MATNR
          INTO @DATA(LV_MTART).

        IF LV_MTART EQ 'HAWA'.
*          SELECT SINGLE  DPCBT
*            FROM MARC
*            WHERE MATNR EQ @PS_TAB-MATNR
*                 AND WERKS EQ @PS_TAB-WERKS
*            INTO @DATA(LV_DPCBT).  "LINE 463으로 이동_260804

          CASE LV_DPCBT.
*2-2)'A' OR 공백이면 Default 값 채번_배치번호 : GO00000001"
            WHEN 'A' OR SPACE.
              LS_ITEM-BATCH = 'GO00000001'.
*2-1)MARC-DPCBT = 'C'->자동채번
            WHEN 'C'.
              LS_ITEM-BATCH = PS_TAB-CHARG.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.

    WHEN '3'.  "외주 임가공_메인품목 자재 배치 설정 조건 체크 추가
*3)배치관리 유형 FACTOR BATCH이면(DPCBT = 'A') 조장정보로 채번,없으면 자동채번
      READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC2>)
      WITH KEY EBELN = PS_TAB-EBELN
                     EBELP = PS_TAB-EBELP BINARY SEARCH.
      IF SY-SUBRC = 0.
        LS_ITEM-BATCH = CONV I( <VC2>-LENGTH ).
        CONDENSE LS_ITEM-BATCH NO-GAPS.
        PS_TAB-CHARG_NEW = LS_ITEM-BATCH.
      ENDIF.
  ENDCASE.

*>S.26.08.06_3-2) 배치 클래스의 속성 정보 특성 업데이트 BAPI 선 수행
*BAP_GOODSMVT_CREATE 실행 전 FACTOR 배치 유형인 경우
  IF LV_DPCBT = 'A'. "FACTOR BATCH
    CLEAR LV_LENTH.
*3-2-1) FACTOR BATCH 여부 체크 & 조장정보 가져오기.
    READ TABLE PT_VC ASSIGNING FIELD-SYMBOL(<VC3>)
    WITH KEY EBELN = PS_TAB-EBELN
                   EBELP = PS_TAB-EBELP BINARY SEARCH.
    IF SY-SUBRC = 0.
      LV_LENTH = CONV I( <VC3>-LENGTH ).
      CONDENSE LV_LENTH NO-GAPS.
    ENDIF.
*3-2-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL         = PS_TAB-MATNR "입고자재
        PLANT              = PS_TAB-WERKS "플랜트
        CLASSTYPE      = '023'       "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

      CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
      CLEAR LT_ALC_NUM.
      LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                              ( CHARACT = 'SAP_MILLCA_LENGTH'
                                                VALUE_FROM = LV_LENTH )
                                              ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                                 VALUE_FROM = LV_LENTH ) ).
      CLEAR : LT_RETURN.
      SELECT SINGLE CUOBJ_BM
                 FROM MCH1
               WHERE MATNR = @PS_TAB-MATNR
                    AND CHARG = @LS_ITEM-BATCH
               INTO @DATA(LV_OBJKEY).

      IF LV_OBJKEY IS NOT INITIAL.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
                  CLOBJECTKEY             = LV_OBJKEY
                  CLASSNUM                  = LV_CLASS
          IMPORTING
                 CLASSIF_STATUS            = LV_STATUS
          TABLES
                  ALLOCVALUESNUM_NEW        = LT_ALC_NUM
                  ALLOCVALUESCHAR_NEW       = LT_ALLOC
                  ALLOCVALUESCURR_NEW       = LT_ALC_CURR
                  RETURN                    = LT_RETURN
                      .
        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
*      오류
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
*      배치특성 성공
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.
  ENDIF.
*<E.26.08.06_ZGODEV04.

  LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).

  CHECK PS_TAB-PSTYP EQ GC_3. "외주 임가공인 경우

*3-2-4-2) Component 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*Component 자재 항목 라인별로 BAPI ITEM 라인 추가
  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB_POGR_RCV.
  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.

  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID.
  LS_COMP-LINE_ID = LS_ITEM-LINE_ID.

  READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_TAB-EBELN
                                                            EBELP = PS_TAB-EBELP
                                                            WERKS = PS_TAB-WERKS BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*
*Table : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*
*조회된  Component 자재,배치별 BAPI ITEM 라인 추가

    LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

      LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
      LS_COMP-PLANT = PS_TAB-WERKS.
      LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
      LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
      LS_COMP-MOVE_TYPE = GC_543.
      LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
      LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
      LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

      IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
        LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.
      ELSE.

        READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                              EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                              MATNR = <LS_ZGTMMT9450>-IDNRK.
        IF SY-SUBRC EQ 0.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            LS_COMP-ENTRY_QNT = PS_TAB-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
        ELSE.
          CV_CHECK = GC_E.
          EXIT.
        ENDIF.
      ENDIF.

      LS_COMP-LINE_ID += 1.
      CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).

    ENDLOOP.

  ELSE.
    "PO Component 기준
    READ TABLE PT_RESB WITH KEY EBELN = PS_TAB-EBELN
                                              EBELP = PS_TAB-EBELP BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
        IF <LS_RESB>-EBELN NE PS_TAB-EBELN
          OR <LS_RESB>-EBELP NE PS_TAB-EBELP.
          EXIT.
        ENDIF.

        LS_COMP-MATERIAL = <LS_RESB>-MATNR.
        LS_COMP-PLANT = <LS_RESB>-WERKS.
        LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
        LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
        LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
        LS_COMP-MOVE_TYPE = GC_543.
        LS_COMP-BATCH = <LS_RESB>-CHARG.
        IF <LS_RESB>-MENGE IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = PS_TAB-MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
        ELSE.
          LS_COMP-ENTRY_QNT = 0.
        ENDIF.
        LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
        LS_COMP-MVT_IND = GC_B.


        "라인추가
        IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 batch 번호 추출 투입 처리(선입 선출 기준)
*Table : MSLB
*Select 조건 : LBLAB 0 이 아닌 CHARG
*Where 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
          LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
          READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                     WERKS = <LS_RESB>-WERKS
                                                     LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC EQ 0.
            LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
              IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                EXIT.
              ENDIF.

              CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

              "적용 수량 빼기
              LV_ERFMG_O = LV_ERFMG.
              LV_ERFMG -= <LS_MSLB>-LBLAB.

              LS_COMP-BATCH = <LS_MSLB>-CHARG.

              IF LV_ERFMG LT 0.
                "적용한 수량이 대상 출고수량 보다 큰 경우
                IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"Batch 별 투입 시 지정된 Batch가 단일 배치단위이면 (MCH1-XPCBT='X')
*Batch 가용재고전량투입 처리"
* & 부분수량 GI 허용이 space 인 경우
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ELSE.
                  "단일 배치단위가 아니면 잔량적용
                  LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                ENDIF.
              ELSE.
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ENDIF.

              "재고수량에서 적용수량 빼기
              <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가

              "적용 수량이 대상 출고수량을 초과한 경우 종료
              IF LV_ERFMG LE 0.
                EXIT.
              ENDIF.

            ENDLOOP.
          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
          ENDIF.
        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
        ENDIF.

      ENDLOOP.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_LOG_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LOG
*&      --> LT_LOG_DATA
*&      --> LS_HDRET
*&---------------------------------------------------------------------*
FORM F_SAVE_LOG_DRGR_RCV  USING PS_LOG TYPE ZGTMMT9000
*                                   PT_LOG_DATA TYPE TY_T_ZGTMMT9422
                                   PT_LOG_DATA TYPE TY_T_ZGTMMT9422_N
                                   PS_HDRET TYPE BAPI2017_GM_HEAD_RET
                                   PT_TAB TYPE TY_T_ZGTMMS4014.

  DATA:
    LS_LOG      TYPE ZGTMMT9000,
    LT_LOG_DATA TYPE TY_T_ZGTMMT9422,
    LT_LOG_DOC  TYPE STANDARD TABLE OF ZGTMMT9423,
    LT_LOG_9425 TYPE STANDARD TABLE OF ZGTMMT9425.

  LS_LOG = PS_LOG.

*  GET TIME STAMP FIELD LS_LOG-ZIFKEY.  "I/F KEY는 최초 1회 채번으로 변경
  LS_LOG-ERDAT = SY-DATUM.
  LS_LOG-ERDAT_LOCAL = SY-DATLO.
  LS_LOG-ERTIM = SY-UZEIT.
  LS_LOG-ERTIM_LOCAL = SY-TIMLO.
  LS_LOG-ERNAM = SY-UNAME.

  LOOP AT PT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).
    <LS_LOG_DATA>-ZIFKEY = LS_LOG-ZIFKEY.
    <LS_LOG_DATA>-SYSTEM_ID = LS_LOG-SYSTEM_ID.

    LT_LOG_DATA = VALUE #( BASE LT_LOG_DATA
                                          ( CORRESPONDING #( <LS_LOG_DATA> ) ) ).

*    CHECK LS_LOG-ZSTAT EQ GC_S. "성공인 경우 자재문서 저장 --> 2026.07.12 상태 상관없이 로그 남기기로 변경
    LT_LOG_DOC = VALUE #( BASE LT_LOG_DOC ( ZIFKEY = LS_LOG-ZIFKEY
                                                                          SYSTEM_ID = LS_LOG-SYSTEM_ID
                                                                          EBELN = <LS_LOG_DATA>-EBELN
                                                                          EBELP = <LS_LOG_DATA>-EBELP
                                                                          DR_LABEL_NO = <LS_LOG_DATA>-DR_LABEL_NO
                                                                          MBLNR = PS_HDRET-MAT_DOC
                                                                          MJAHR = PS_HDRET-DOC_YEAR ) ).
  ENDLOOP.

  MODIFY ZGTMMT9422 FROM TABLE LT_LOG_DATA.

  IF LT_LOG_DOC[] IS NOT INITIAL.
    MODIFY ZGTMMT9423 FROM TABLE LT_LOG_DOC.
  ENDIF.

  MODIFY ZGTMMT9000 FROM LS_LOG.
  COMMIT WORK.

*>S.2026.08.06_1차 로그저장 대상 테이블 추가_ZGTMMT9425
  CHECK PT_TAB IS NOT INITIAL. "IT_TAB2 수신 시에만..

  LOOP AT PT_TAB ASSIGNING FIELD-SYMBOL(<TAB>).

    LT_LOG_9425 = VALUE #( BASE LT_LOG_9425
                                          ( VALUE #( BASE CORRESPONDING #( <TAB> )
                                                             ZIFKEY = LS_LOG-ZIFKEY
                                                             SYSTEM_ID = LS_LOG-SYSTEM_ID
                                                             DR_LABEL_NO = <TAB>-DR_LABELNO ) )
                                           ).
  ENDLOOP.

  IF LT_LOG_9425[] IS NOT INITIAL.
    MODIFY ZGTMMT9425 FROM TABLE LT_LOG_9425.
    COMMIT WORK.
  ENDIF.
*>E.2026.08.06_ZGODEV04.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_ZPPT0001_DRGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      --> LS_HDRET
*&      --> LT_DISPO
*&---------------------------------------------------------------------*
FORM F_SAVE_ZPPT0001_DRGR_RCV  USING  "PT_LOG_DATA TYPE TY_T_ZGTMMT9422
                                                                      PT_LOG_DATA TYPE TY_T_ZGTMMT9422_N
                                        PS_HDRET TYPE BAPI2017_GM_HEAD_RET
                                        PT_DISPO TYPE TY_T_PO_DISPO_POGR_RCV
                                        PV_CHK
                                        PS_0001 TYPE ZPPT0001
                                        PT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE . "LT_ITEM


  DATA:
    LV_ZSPGCD TYPE ZSPGCD,
    LT_PP        TYPE STANDARD TABLE OF ZPPT0001.

*>S.2026.08.12_생성된 자재문서 번호로 MATDOC정보 가져오기. 배치체크
    SELECT MBLNR, MJAHR, MATNR, WERKS, CHARG_SID, LGORT_SID
      FROM MATDOC
      WHERE MBLNR = @PS_HDRET-MAT_DOC
           AND MJAHR = @PS_HDRET-DOC_YEAR
      INTO TABLE @DATA(LT_MAT).
      SORT LT_MAT BY MBLNR MATNR WERKS.
*<E.2026.08.12

  LOOP AT PT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).

    "<--2026.07.12 배치 존재여부 조건 변경
**      CHECK <LS_LOG_DATA>-CHARG IS NOT INITIAL OR
**                <LS_LOG_DATA>-CHARG_NEW IS NOT INITIAL.
*    READ TABLE PT_ITEM ASSIGNING <LS_ITEM> WITH KEY MATERIAL = <LS_LOG_DATA>-MATNR
*                                                                                       PLANT = <LS_LOG_DATA>-WERKS
*                                                                                       STGE_LOC = <LS_LOG_DATA>-LGORT.
    READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<MAT>)
    WITH KEY MBLNR = PS_HDRET-MAT_DOC
                   MATNR = <LS_LOG_DATA>-MATNR
                   WERKS = <LS_LOG_DATA>-WERKS BINARY SEARCH.
    CHECK SY-SUBRC = 0.
    CHECK <MAT>-CHARG_SID IS NOT INITIAL.
*    CHECK <LS_ITEM>-BATCH IS NOT INITIAL.
    "-->2026.07.12 배치 존재여부 조건 변경

    CLEAR LV_ZSPGCD.
    READ TABLE PT_DISPO ASSIGNING FIELD-SYMBOL(<LS_DISPO>) WITH KEY EBELN = <LS_LOG_DATA>-EBELN
                                                                                                       EBELP = <LS_LOG_DATA>-EBELP BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LV_ZSPGCD = <LS_DISPO>-DISPO.
    ENDIF.

*>S.2026.08.06_플랜트/구매오더/꼬리표 기준으로 기존 데이터 존재하면, 업데이트..
    IF PS_0001 IS NOT INITIAL.
      UPDATE ZPPT0001
            SET POSNR = <LS_LOG_DATA>-EBELP
                   CHARG = <MAT>-CHARG_SID "<LS_ITEM>-BATCH
                   MBLNR = PS_HDRET-MAT_DOC
                   MGVRG = <LS_LOG_DATA>-MENGE
                   REMAIN = <LS_LOG_DATA>-MENGE
                   GRFLG = GC_Y
                   LGORT = <LS_LOG_DATA>-LGORT
                   GRINDAT = SY-DATUM
                   GRINTIM = SY-UZEIT
                   GRINNAM = SY-UNAME
       WHERE WERKS = PS_0001-WERKS
            AND AUFNR = PS_0001-AUFNR
            AND TAGNR = PS_0001-TAGNR.

      IF SY-SUBRC = 0.
         COMMIT WORK.
      ENDIF.

    ELSE. "없으면, 신규저장.
      LT_PP[] = VALUE #( BASE LT_PP (
          WERKS = <LS_LOG_DATA>-WERKS
          AUFNR = <LS_LOG_DATA>-EBELN
          TAGNR = <LS_LOG_DATA>-TAGNR
          POSNR = <LS_LOG_DATA>-EBELP
"FECTOR BATCH인 경우 별도 배치 번호 채번되기 때문에 조건 별 구분.
*          CHARG = COND #( WHEN <LS_LOG_DATA>-CHARG_NEW IS NOT INITIAL
*                                       THEN <LS_LOG_DATA>-CHARG_NEW "채번된 배치번호 담고있음.
*                                       ELSE <LS_LOG_DATA>-CHARG )  "기존수신받은 배치번호.
          CHARG = <MAT>-CHARG_SID "<LS_ITEM>-BATCH   "2026.07.12 자재문서 기준 배치번호로 변경
          MBLNR = PS_HDRET-MAT_DOC
          MATNR = <LS_LOG_DATA>-MATNR
          SPGCD = LV_ZSPGCD
          MGVRG = <LS_LOG_DATA>-MENGE
          FOSTCNT = 1
          REMAIN = <LS_LOG_DATA>-MENGE
          MEINS = <LS_LOG_DATA>-MEINS
          OUTFLG = COND #( WHEN <LS_LOG_DATA>-PSTYP EQ GC_3 THEN ABAP_TRUE ELSE SPACE )
          GIFLG = GC_N
          GRFLG = GC_Y
          INSPFLG = GC_OK
          LGORT = <LS_LOG_DATA>-LGORT
          GRINDAT = SY-DATUM
          GRINTIM = SY-UZEIT
          GRINNAM = SY-UNAME
      ) ).
    ENDIF.
*>E.2026.08.06_ZGODEV04
  ENDLOOP.

  CHECK LT_PP[] IS NOT INITIAL.

  MODIFY ZPPT0001 FROM TABLE LT_PP.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_ZPPT0001_DRGR_RCV_311
*&---------------------------------------------------------------------*
*& 2026.09.29 재고이전(311) 꼬리표 저장
*&  - 311 은 플랜트 이동이 아니므로 꼬리표 WERKS 는 재고 플랜트(자재문서 플랜트)로 저장
*&  - 재고 플랜트 기준으로 기존 꼬리표 조회, 없으면 수신 플랜트 기준으로 재조회
*&    (수신 플랜트로 등록된 기존 꼬리표는 재고 플랜트로 이관)
*&  - 기존 꼬리표 AUFNR 공백: 삭제 후 신규 저장 / AUFNR 존재: 기존 값 유지하고 311 값 반영
*&---------------------------------------------------------------------*
*&      --> PT_LOG_DATA
*&      --> PS_HDRET
*&      --> PT_DISPO
*&---------------------------------------------------------------------*
FORM F_SAVE_ZPPT0001_DRGR_RCV_311  USING  PT_LOG_DATA TYPE TY_T_ZGTMMT9422_N
                                          PS_HDRET TYPE BAPI2017_GM_HEAD_RET
                                          PT_DISPO TYPE TY_T_PO_DISPO_POGR_RCV.

  DATA:
    LV_ZSPGCD TYPE ZSPGCD,
    LV_WERKS  TYPE WERKS_D,
    LS_OLD    TYPE ZPPT0001,
    LS_NEW    TYPE ZPPT0001.

  "생성된 자재문서의 입고(SHKZG=S) 라인 -> 재고 플랜트/배치
  SELECT MBLNR, MJAHR, MATNR, WERKS, CHARG_SID
    FROM MATDOC
    WHERE MBLNR = @PS_HDRET-MAT_DOC
      AND MJAHR = @PS_HDRET-DOC_YEAR
      AND SHKZG = 'S'
    INTO TABLE @DATA(LT_MAT).
  SORT LT_MAT BY MBLNR MATNR.

  LOOP AT PT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).

    READ TABLE LT_MAT ASSIGNING FIELD-SYMBOL(<MAT>)
    WITH KEY MBLNR = PS_HDRET-MAT_DOC
                   MATNR = <LS_LOG_DATA>-MATNR BINARY SEARCH.
    CHECK SY-SUBRC = 0.
    CHECK <MAT>-CHARG_SID IS NOT INITIAL.

    LV_WERKS = <MAT>-WERKS.

    CLEAR LV_ZSPGCD.
    READ TABLE PT_DISPO ASSIGNING FIELD-SYMBOL(<LS_DISPO>) WITH KEY EBELN = <LS_LOG_DATA>-EBELN
                                                                     EBELP = <LS_LOG_DATA>-EBELP BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LV_ZSPGCD = <LS_DISPO>-DISPO.
    ENDIF.

    "기존 꼬리표 조회: 재고 플랜트 -> 없으면 수신 플랜트
    CLEAR: LS_OLD, LS_NEW.
    SELECT SINGLE *
      FROM ZPPT0001
      WHERE WERKS EQ @LV_WERKS
        AND TAGNR EQ @<LS_LOG_DATA>-TAGNR
      INTO @LS_OLD.
    IF SY-SUBRC NE 0 AND <LS_LOG_DATA>-WERKS NE LV_WERKS.
      SELECT SINGLE *
        FROM ZPPT0001
        WHERE WERKS EQ @<LS_LOG_DATA>-WERKS
          AND TAGNR EQ @<LS_LOG_DATA>-TAGNR
        INTO @LS_OLD.
    ENDIF.

    IF LS_OLD IS NOT INITIAL AND LS_OLD-AUFNR IS NOT INITIAL.
      "기존 꼬리표 유지, 311 결과 반영 (기존 UPDATE 분기와 동일한 항목)
      LS_NEW = LS_OLD.
      LS_NEW-WERKS   = LV_WERKS.
      LS_NEW-POSNR   = <LS_LOG_DATA>-EBELP.
      LS_NEW-CHARG   = <MAT>-CHARG_SID.
      LS_NEW-MBLNR   = PS_HDRET-MAT_DOC.
      LS_NEW-MGVRG   = <LS_LOG_DATA>-MENGE.
      LS_NEW-REMAIN  = <LS_LOG_DATA>-MENGE.
      LS_NEW-GRFLG   = GC_Y.
      LS_NEW-LGORT   = <LS_LOG_DATA>-LGORT.
      LS_NEW-GRINDAT = SY-DATUM.
      LS_NEW-GRINTIM = SY-UZEIT.
      LS_NEW-GRINNAM = SY-UNAME.
    ELSE.
      "없거나 AUFNR 공백: 신규 저장 값 (F_SAVE_ZPPT0001_DRGR_RCV 신규와 동일)
      LS_NEW = VALUE #(
          WERKS = LV_WERKS
          AUFNR = <LS_LOG_DATA>-EBELN
          TAGNR = <LS_LOG_DATA>-TAGNR
          POSNR = <LS_LOG_DATA>-EBELP
          CHARG = <MAT>-CHARG_SID
          MBLNR = PS_HDRET-MAT_DOC
          MATNR = <LS_LOG_DATA>-MATNR
          SPGCD = LV_ZSPGCD
          MGVRG = <LS_LOG_DATA>-MENGE
          FOSTCNT = 1
          REMAIN = <LS_LOG_DATA>-MENGE
          MEINS = <LS_LOG_DATA>-MEINS
          OUTFLG = COND #( WHEN <LS_LOG_DATA>-PSTYP EQ GC_3 THEN ABAP_TRUE ELSE SPACE )
          GIFLG = GC_N
          GRFLG = GC_Y
          INSPFLG = GC_OK
          LGORT = <LS_LOG_DATA>-LGORT
          GRINDAT = SY-DATUM
          GRINTIM = SY-UZEIT
          GRINNAM = SY-UNAME ).
    ENDIF.

    "WERKS 가 키 일부이므로 기존 행 삭제 후 저장 (저장 확정된 경우에만 삭제)
    IF LS_OLD IS NOT INITIAL.
      DELETE ZPPT0001 FROM @LS_OLD.
    ENDIF.
    MODIFY ZPPT0001 FROM @LS_NEW.

  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_ZPPT0001_DRGR_RCV2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      --> LS_HDRET
*&      --> LT_DISPO
*&---------------------------------------------------------------------*
FORM F_SAVE_ZPPT0001_DRGR_RCV2  USING  "PT_LOG_DATA TYPE TY_T_ZGTMMT9422
                                                                      PT_LOG_DATA TYPE TY_T_ZGTMMT9422_N
                                        PS_HDRET TYPE BAPI2017_GM_HEAD_RET
                                        PT_DISPO TYPE TY_T_PO_DISPO_POGR_RCV
                                        PV_CHK
                                        PS_0001 TYPE ZPPT0001
                                        PT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE . "LT_ITEM


  DATA:
    LV_ZSPGCD TYPE ZSPGCD,
    LT_PP        TYPE STANDARD TABLE OF ZPPT0001,
    LT_PP_NEW  TYPE STANDARD TABLE OF ZPPT0001.

  LOOP AT PT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).

    "<--2026.07.12 배치 존재여부 조건 변경
*      CHECK <LS_LOG_DATA>-CHARG IS NOT INITIAL OR
*                <LS_LOG_DATA>-CHARG_NEW IS NOT INITIAL.
    READ TABLE PT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY MATERIAL = <LS_LOG_DATA>-MATNR
                                                                                                   PLANT = <LS_LOG_DATA>-WERKS
                                                                                                   STGE_LOC = <LS_LOG_DATA>-LGORT.
    CHECK SY-SUBRC = 0.
    CHECK <LS_ITEM>-BATCH IS NOT INITIAL.
    "-->2026.07.12 배치 존재여부 조건 변경

    CLEAR LV_ZSPGCD.
    READ TABLE PT_DISPO ASSIGNING FIELD-SYMBOL(<LS_DISPO>) WITH KEY EBELN = <LS_LOG_DATA>-EBELN
                                                                                                       EBELP = <LS_LOG_DATA>-EBELP BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LV_ZSPGCD = <LS_DISPO>-DISPO.
    ENDIF.

*>S.2026.08.06_꼬리표 기준으로 AUFNR 공백인 경우 삭제 후 INSERT/아닌 경우 업데이트 로 구분..
    IF PS_0001-AUFNR IS INITIAL.
      LT_PP_NEW[] = VALUE #( BASE LT_PP_NEW (
          WERKS = <LS_LOG_DATA>-WERKS
          AUFNR = <LS_LOG_DATA>-EBELN
          TAGNR = <LS_LOG_DATA>-TAGNR
          POSNR = <LS_LOG_DATA>-EBELP
          CHARG = <LS_ITEM>-BATCH
          MBLNR = PS_HDRET-MAT_DOC
          MATNR = <LS_LOG_DATA>-MATNR
          SPGCD = LV_ZSPGCD
          MGVRG = <LS_LOG_DATA>-MENGE
          FOSTCNT = 1
          REMAIN = <LS_LOG_DATA>-MENGE
          MEINS = <LS_LOG_DATA>-MEINS
          OUTFLG = COND #( WHEN <LS_LOG_DATA>-PSTYP EQ GC_3 THEN ABAP_TRUE ELSE SPACE )
          GIFLG = GC_N
          GRFLG = GC_Y
          INSPFLG = GC_OK
          LGORT = <LS_LOG_DATA>-LGORT
          GRINDAT = SY-DATUM
          GRINTIM = SY-UZEIT
          GRINNAM = SY-UNAME
           ) ).
    ELSE.
      LT_PP[] = VALUE #( BASE LT_PP (
          WERKS = <LS_LOG_DATA>-WERKS
          AUFNR = <LS_LOG_DATA>-EBELN
          TAGNR = <LS_LOG_DATA>-TAGNR
          POSNR = <LS_LOG_DATA>-EBELP
"FECTOR BATCH인 경우 별도 배치 번호 채번되기 때문에 조건 별 구분.
*          CHARG = COND #( WHEN <LS_LOG_DATA>-CHARG_NEW IS NOT INITIAL
*                                       THEN <LS_LOG_DATA>-CHARG_NEW "채번된 배치번호 담고있음.
*                                       ELSE <LS_LOG_DATA>-CHARG )  "기존수신받은 배치번호.
          CHARG = <LS_ITEM>-BATCH   "2026.07.12 자재문서 기준 배치번호로 변경
          MBLNR = PS_HDRET-MAT_DOC
          MATNR = <LS_LOG_DATA>-MATNR
          SPGCD = LV_ZSPGCD
          MGVRG = <LS_LOG_DATA>-MENGE
          FOSTCNT = 1
          REMAIN = <LS_LOG_DATA>-MENGE
          MEINS = <LS_LOG_DATA>-MEINS
          OUTFLG = COND #( WHEN <LS_LOG_DATA>-PSTYP EQ GC_3 THEN ABAP_TRUE ELSE SPACE )
          GIFLG = GC_N
          GRFLG = GC_Y
          INSPFLG = GC_OK
          LGORT = <LS_LOG_DATA>-LGORT
          GRINDAT = SY-DATUM
          GRINTIM = SY-UZEIT
          GRINNAM = SY-UNAME
      ) ).
    ENDIF.
  ENDLOOP.

  IF LT_PP_NEW[] IS NOT INITIAL.
    INSERT ZPPT0001 FROM TABLE LT_PP_NEW.
    COMMIT WORK.
  ENDIF.

*  CHECK LT_PP[] IS NOT INITIAL.
  IF LT_PP[] IS NOT INITIAL.
    MODIFY ZPPT0001 FROM TABLE LT_PP.
    COMMIT WORK.
  ENDIF.
*>E.2026.08.06_ZGODEV04

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_UPDATE_CLASS_BATCH_DRGR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM F_UPDATE_CLASS_BATCH_DRGR USING  PS_TAB TYPE  ZGTMMS4012.


  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

*1)FACTOR BATCH 여부 체크
  SELECT SINGLE  DPCBT
      FROM MARC
      WHERE MATNR EQ @PS_TAB-MATNR
           AND WERKS EQ @PS_TAB-WERKS
          INTO @DATA(LV_DPCBT).

  IF LV_DPCBT = 'A'. "FACTOR BATCH
    CLEAR LV_LENTH.
*2)조장정보 설정(수신받은 배치 정보가 조장 정보임)
*기존 배치(CHARG) 말고 조장정보로 배치 설정한 필드(CHARG_NEW)
    LV_LENTH = PS_TAB-CHARG_NEW.
    CONDENSE LV_LENTH NO-GAPS.
*3) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL           = PS_TAB-MATNR "입고자재
        PLANT              = PS_TAB-WERKS "플랜트
        CLASSTYPE          = '023'       "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

    CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
    CLEAR LT_ALC_NUM.
    LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                             ( CHARACT = 'SAP_MILLCA_LENGTH'
                                               VALUE_FROM = LV_LENTH )
                                             ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                               VALUE_FROM = LV_LENTH ) ).
    CLEAR : LT_RETURN.
    SELECT SINGLE CUOBJ_BM
         FROM MCH1
         WHERE MATNR = @PS_TAB-MATNR
             AND CHARG = @PS_TAB-CHARG_NEW
            INTO @DATA(LV_OBJKEY).

    IF LV_OBJKEY IS NOT INITIAL.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          CLOBJECTKEY         = LV_OBJKEY
          CLASSNUM            = LV_CLASS
        IMPORTING
          CLASSIF_STATUS      = LV_STATUS
        TABLES
          ALLOCVALUESNUM_NEW  = LT_ALC_NUM
          ALLOCVALUESCHAR_NEW = LT_ALLOC
          ALLOCVALUESCURR_NEW = LT_ALC_CURR
          RETURN              = LT_RETURN
          .
      READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
      IF SY-SUBRC EQ 0.
*      오류
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
*      배치특성 성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.
