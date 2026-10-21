*----------------------------------------------------------------------*
***INCLUDE LZGTMM11F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_COM_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
*FORM SET_COM_LOG  USING  PV_TYPE
*                                               PV_ZIFNO
*                                               PV_ZSTAT
*                                               PV_MESSAGE
*                                   CHANGING GS_9000 STRUCTURE ZGTMMT9000 .
*
*  CASE PV_TYPE.
*
*    WHEN 'S'. "Start
*
*      CLEAR  GS_9000.
**1차 로그_ZGTMMT9000
*      GET TIME STAMP FIELD GS_9000-ZIFKEY.
*
*      GS_9000-ZIFNO         = PV_ZIFNO.
*      GS_9000-SYSTEM_ID = GV_SYSTEM_ID.
*      GS_9000-IFDAT         = SY-DATLO.
*      GS_9000-IFTIM          = SY-TIMLO.
*      GS_9000-IFNAM        = SY-UNAME.
*
*      MODIFY ZGTMMT9000 FROM GS_9000.
*
**2차 로그_ZGTMMT9000
*    WHEN 'E'. "End
*
*      UPDATE ZGTMMT9000
*
*      SET      ZSTAT             = PV_ZSTAT
*                  MESSAGE        = PV_MESSAGE
*                  ERDAT             = SY-DATUM
*                  ERDAT_LOCAL = SY-DATLO
*                  ERTIM              = SY-UZEIT
*                  ERTIM_LOCAL  = SY-TIMLO
*                  ERNAM            = SY-UNAME
*
*      WHERE ZIFNO              = GS_9000-ZIFNO
*           AND ZIFKEY            = GS_9000-ZIFKEY
*           AND SYSTEM_ID      = GS_9000-SYSTEM_ID.
*
*  ENDCASE.
*
*  CHECK SY-SUBRC = 0.
*  COMMIT WORK.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form SET_92XX_LOG
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> P_
**&      --> P_
**&      --> P_
**&      --> P_
**&---------------------------------------------------------------------*
*FORM SET_92XX_LOG  TABLES PT_PLANT LIKE GT_9231
*                                                PT_PRICE  LIKE GT_9232
*                                    USING   PV_TYPE
*                                                PS_9230 STRUCTURE ZGTMMT9230
*                                                PS_9240 STRUCTURE ZGTMMT9240
*                                                PS_9000 STRUCTURE ZGTMMT9000.
*
*  DATA : LS_9230 LIKE ZGTMMT9230,
*             LS_9240 LIKE ZGTMMT9240.
*  DATA : LT_9231 LIKE TABLE OF ZGTMMT9231,
*             LT_9232 LIKE TABLE OF ZGTMMT9232.
*
*  CASE PV_TYPE.
*
*    WHEN 'INFO'. "단가 계약 정보
**1.ZGTMMT9230
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
*
*      MODIFY ZGTMMT9230 FROM LS_9230.
*
**2.ZGTMMT9231
*      LT_9231 = VALUE #( BASE LT_9231
*                                     FOR WA1 IN PT_PLANT
*                                   ( VALUE #( BASE CORRESPONDING #( WA1 )
*                                     ZIFKEY = GS_9000-ZIFKEY ) ) ).
*
*     MODIFY ZGTMMT9231 FROM TABLE LT_9231.
*
**3.ZGTMMT9232
*      LT_9232 = VALUE #( BASE LT_9232
*                                     FOR WA2 IN PT_PRICE
*                                   ( VALUE #( BASE CORRESPONDING #( WA2 )
*                                     ZIFKEY = GS_9000-ZIFKEY ) ) ).
*
*     MODIFY ZGTMMT9232 FROM TABLE LT_9232.
*
*
*    WHEN 'PO'. "구매오더 확정/반려 업데이트
**ZGTMMT9240
*      LS_9240 = VALUE #(
*                      ZIFKEY      = GS_9000-ZIFKEY
*                      EKORG      = PS_9240-EKORG
*                      EBELN       = PS_9240-EBELN
*                      ZCONFIRM = PS_9240-ZCONFIRM  ).
*
*      MODIFY ZGTMMT9240 FROM LS_9240.
*
*  ENDCASE.
*
*  CHECK SY-SUBRC = 0.
*  COMMIT WORK.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RANGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_C
*&      --> I_DRM_TYPE
*&      <-- LR_TYPE
*&---------------------------------------------------------------------*
FORM SET_RANGES  USING PV_GUBUN  PV_FIELD
                                CHANGING PR_RANGE .

DATA : LR_RANGE TYPE FC00_S_RANGE,
           LR_DEC TYPE FC00_S_RANGE.

*CASE PV_GUBUN.
*  WHEN GC_C.
*    PR_RANGE = VALUE #( LR_RANGE-SIGN = GC_I
*                                       LR_RANGE-OPTION = GC_EQ
*                                       LR_RANGE-LOW = PV_FIELD
*                                       LR_RANGE-HIGH = SPACE ) .
*  WHEN GC_D.
**     APPEND VALUE #( LR_RANGE-SIGN = GC_I
**                                  LR_RANGE-OPTION = GC_EQ
**                                  LR_RANGE-LOW = PV_FIELD
**                                  LR_RANGE-HIGH = SPACE ) TO PR_RANGE.
*  WHEN OTHERS.
*    CLEAR : PR_RANGE.
*ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form CONVERT_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_CURRENCY  USING PV_PRICE
                                       CHANGING PV_EX_PRICE .

  DATA LV_AMOUNT(20) TYPE C.
  LV_AMOUNT = PV_PRICE.  CONDENSE LV_AMOUNT NO-GAPS.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
    EXPORTING
      CURRENCY          = 'KRW'
      SAP_AMOUNT      = LV_AMOUNT
    IMPORTING
      IDOC_AMOUNT     = LV_AMOUNT
            .
    PV_EX_PRICE = LV_AMOUNT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_EBELN
*&      --> IT_VBELN
*&      --> IT_DOC
*&---------------------------------------------------------------------*
*FORM SET_RANGE  TABLES   PT_EBELN STRUCTURE ZGTMMS4513
*                                             PT_VBELN STRUCTURE ZGTMMS4514
*                                             PT_DOC STRUCTURE ZGTMMS4515.
FORM SET_RANGE  USING   PT_EBELN TYPE TY_T_4513
                                           PT_VBELN TYPE TY_T_4514
                                           PT_DOC TYPE TY_T_4515 .
* CLEAR : GR_EBELN, GR_EBELN[], GR_VBELN, GR_VBELN[].
 CLEAR : GR_EBELN[], GR_VBELN[].

  IF PT_EBELN[] IS NOT INITIAL.
*     CLEAR : GR_EBELN, GR_EBELN[].
*  ELSE.
     LOOP AT PT_EBELN ASSIGNING FIELD-SYMBOL(<FS>).
        APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = <FS>-EBELN HIGH = SPACE )
        TO GR_EBELN.
     ENDLOOP.
  ENDIF.

  IF PT_VBELN[] IS NOT INITIAL.
*     CLEAR : GR_VBELN, GR_VBELN[].
*  ELSE.
     LOOP AT PT_VBELN ASSIGNING FIELD-SYMBOL(<FSV>).
        APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = <FSV>-VBELN HIGH = SPACE )
        TO GR_VBELN.
     ENDLOOP.
  ENDIF.

*  IF PT_DOC IS INITIAL.
*     CLEAR : GR_DOC, GR_DOC[].
*  ELSE.
*     LOOP AT PT_DOC ASSIGNING FIELD-SYMBOL(<FSD>).
*        APPEND VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = <FSD> HIGH = SPACE )
*        TO GR_DOC.
*     ENDLOOP.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_RDATE_F
*&      --> I_WERKS
*&      --> I_CNAME
*&      --> I_MATNR
*&      --> I_MAKTX
*&      --> I_ZVD_STAT
*&      <-- LV_COND
*&---------------------------------------------------------------------*
FORM SET_COND  USING    PV_RDATE_F
                                         PV_WERKS
                                         PV_ZVD_STAT
                                         PV_AR_DATE_F                 " ★ 추가
                                         PV_AR_DATE_T                 " ★ 추가
                      CHANGING   PV_COND.

IF PV_RDATE_F IS NOT INITIAL.
   PV_COND &&= | AND REQDATE >= '{ PV_RDATE_F }' |.
ENDIF.

IF PV_WERKS IS NOT INITIAL.
   PV_COND &&= | AND WERKS = '{ PV_WERKS }' |.
ENDIF.

IF PV_ZVD_STAT IS NOT INITIAL.
   PV_COND &&= | AND ZVD_STAT = '{ PV_ZVD_STAT }' |.
ENDIF.

* ★ 추가 - 도착요청일 시작
IF PV_AR_DATE_F IS NOT INITIAL.
   PV_COND &&= | AND AR_DATE >= '{ PV_AR_DATE_F }' |.
ENDIF.

* ★ 추가 - 도착요청일 종료
IF PV_AR_DATE_T IS NOT INITIAL.
   PV_COND &&= | AND AR_DATE <= '{ PV_AR_DATE_T }' |.
ENDIF.

ENDFORM.
