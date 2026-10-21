*----------------------------------------------------------------------*
***INCLUDE LZGOPP02F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_import_parameter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_IMPORT_PARAMETER  USING PV_WERKS PV_LGORT PT_MATNR TYPE RANGE_T_MATNR
                                 PV_CHARG PV_VBELN PV_POSNR
                                 PS_IMPORT TYPE TY_S_IMPORT_PARA.

  PS_IMPORT = VALUE #( WERKS = COND #( WHEN PV_WERKS IS NOT INITIAL THEN VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_WERKS ) ) )
                       LGORT = COND #( WHEN PV_LGORT IS NOT INITIAL THEN VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_LGORT ) ) )
                       VBELN = COND #( WHEN PV_VBELN IS NOT INITIAL THEN VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_VBELN ) ) )
                       POSNR = COND #( WHEN PV_POSNR IS NOT INITIAL THEN VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_POSNR ) ) )
                       MATNR = PT_MATNR
                       CHARG = COND #( WHEN PV_CHARG IS NOT INITIAL THEN VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_CHARG ) ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_order_allocation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ORDER_ALLOCATION  USING PT_LINK_DETAIL TYPE TY_T_ZGTPPS1005
                                 PS_IMPORT      TYPE TY_S_IMPORT_PARA.

  SELECT A~ZASSIGN_NO, A~ZASSIGN_TYPE, A~WERKS, A~VBELN, A~POSNR, A~ETENR,
         A~EDATU, A~WEMENG, A~VRKME, A~WELENG, A~WECNT, A~MATNR,
         B~ZASSIGN_ITEM, B~LGORT, B~F_CHARG, B~LABST1 AS CLABS,
         B~ZCUT_YN, B~ZCUT_CNT, B~ZREW_YN, B~ZEXCLUDE
    FROM ZGTPPT2170 AS A
    JOIN ZGTPPT2180 AS B
      ON A~ZASSIGN_NO EQ B~ZASSIGN_NO
   WHERE A~WERKS   IN @PS_IMPORT-WERKS
     AND A~VBELN   IN @PS_IMPORT-VBELN
     AND A~POSNR   IN @PS_IMPORT-POSNR
     AND A~MATNR   IN @PS_IMPORT-MATNR
     AND A~LOEKZ   EQ @SPACE
     AND B~LGORT   IN @PS_IMPORT-LGORT
     AND B~F_CHARG IN @PS_IMPORT-CHARG
  ORDER BY A~VBELN, A~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @PT_LINK_DETAIL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_STOCK  USING PT_LINK_STOCK  TYPE TY_T_ZGTPPS1006
                               PT_LINK_DETAIL TYPE TY_T_ZGTPPS1005
                               PS_IMPORT      TYPE TY_S_IMPORT_PARA.

*// 플랜트 재고.
  SELECT MARD~WERKS, MARD~LGORT, MARD~MATNR, MARD~LABST AS LABST1,
         MARA~MEINS,
         @ZGTPP_IF_CONST=>GC_STOCK_TABLE-MARD AS STOCK_TABLE
    FROM MARD
    JOIN MARA
      ON MARD~MATNR EQ MARA~MATNR
     AND MARA~XCHPF EQ @SPACE
   WHERE MARD~WERKS IN @PS_IMPORT-WERKS
     AND MARD~LGORT IN @PS_IMPORT-LGORT
     AND MARD~MATNR IN @PS_IMPORT-MATNR
     AND MARD~LABST GT 0
    INTO CORRESPONDING FIELDS OF TABLE @PT_LINK_STOCK.

*// 배치 재고.
  SELECT MCHB~WERKS, MCHB~LGORT, MCHB~MATNR, MCHB~CHARG, MCHB~CLABS AS LABST1,
         MARA~MEINS,
        @ZGTPP_IF_CONST=>GC_STOCK_TABLE-MCHB AS STOCK_TABLE
    FROM MCHB
    JOIN MARA
      ON MCHB~MATNR EQ MARA~MATNR
   WHERE MCHB~WERKS IN @PS_IMPORT-WERKS
     AND MCHB~LGORT IN @PS_IMPORT-LGORT
     AND MCHB~MATNR IN @PS_IMPORT-MATNR
     AND MCHB~CHARG IN @PS_IMPORT-CHARG
     AND MCHB~CLABS GT 0
APPENDING CORRESPONDING FIELDS OF TABLE @PT_LINK_STOCK.

*// 판매오더 재고.
*  SELECT MSKA~WERKS, MSKA~LGORT, MSKA~MATNR, MSKA~CHARG, MSKA~VBELN, MSKA~POSNR, MSKA~KALAB AS LABST1,
*         MARA~MEINS,
*        @ZGTPP_IF_CONST=>GC_STOCK_TABLE-MSKA AS STOCK_TABLE
*    FROM MSKA
*    JOIN MARA
*      ON MSKA~MATNR EQ MARA~MATNR
*   WHERE MSKA~WERKS IN @PS_IMPORT-WERKS
*     AND MSKA~LGORT IN @PS_IMPORT-LGORT
*     AND MSKA~MATNR IN @PS_IMPORT-MATNR
*     AND MSKA~CHARG IN @PS_IMPORT-CHARG
*     AND MSKA~VBELN IN @PS_IMPORT-VBELN
*     AND MSKA~POSNR IN @PS_IMPORT-POSNR
*APPENDING CORRESPONDING FIELDS OF TABLE @PT_LINK_STOCK.

  SELECT MCH1~MATNR, MCH1~CHARG, KLAH~CLASS
    FROM @PT_LINK_STOCK AS A
    JOIN MCH1
      ON A~MATNR EQ MCH1~MATNR
     AND A~CHARG EQ MCH1~CHARG
    JOIN KSSK
      ON MCH1~CUOBJ_BM EQ KSSK~OBJEK
    JOIN KLAH
      ON KSSK~CLINT EQ KLAH~CLINT
   WHERE A~WERKS IN @PS_IMPORT-WERKS
     AND A~LGORT IN @PS_IMPORT-LGORT
     AND A~MATNR IN @PS_IMPORT-MATNR
   ORDER BY MCH1~MATNR, MCH1~CHARG
    INTO TABLE @DATA(LT_KLAH).

  SELECT MATDOC~MATNR, MATDOC~WERKS, MATDOC~CHARG, MATDOC~BUDAT
    FROM @PT_LINK_STOCK AS ZT01
    JOIN MATDOC
      ON ZT01~MATNR       EQ MATDOC~MATNR
     AND ZT01~WERKS       EQ MATDOC~WERKS
     AND ZT01~CHARG       EQ MATDOC~CHARG
     AND MATDOC~SHKZG     EQ 'S'
     AND MATDOC~CANCELLED EQ @SPACE
   ORDER BY MATDOC~MATNR, MATDOC~WERKS, MATDOC~CHARG
    INTO TABLE @DATA(LT_MATDOC).

  DATA(LT_LINK_DETAIL) = PT_LINK_DETAIL[].

  SELECT WERKS,
         LGORT,
         MATNR,
         F_CHARG AS CHARG,
         SUM( CAST( A~WELENG AS QUAN ) * CAST( A~ZCUT_CNT AS INT4 ) ) AS MENGE
    FROM @LT_LINK_DETAIL AS A
   WHERE ZEXCLUDE EQ @ABAP_FALSE
   GROUP BY WERKS, LGORT, MATNR, F_CHARG
   ORDER BY WERKS, LGORT, MATNR, F_CHARG
    INTO TABLE @DATA(LT_DETAIL).


  SORT PT_LINK_STOCK BY WERKS LGORT MATNR CHARG VBELN POSNR.

  LOOP AT PT_LINK_STOCK REFERENCE INTO DATA(LR_LINK_STOCK).
    IF LR_LINK_STOCK->CHARG IS NOT INITIAL.
      READ TABLE LT_KLAH INTO DATA(LS_KLAH) WITH KEY MATNR = LR_LINK_STOCK->MATNR
                                                     CHARG = LR_LINK_STOCK->CHARG BINARY SEARCH.

      IF SY-SUBRC IS INITIAL.
        PERFORM GET_MAT_BATCH_ATTR USING LR_LINK_STOCK->* LS_KLAH-CLASS.
      ENDIF.
    ENDIF.

    READ TABLE LT_MATDOC INTO DATA(LS_MATDOC) WITH KEY MATNR = LR_LINK_STOCK->MATNR
                                                       WERKS = LR_LINK_STOCK->WERKS
                                                       CHARG = LR_LINK_STOCK->CHARG BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_LINK_STOCK->LWEDT = LS_MATDOC-BUDAT.
    ENDIF.

    READ TABLE LT_DETAIL INTO DATA(LS_DETAIL) WITH KEY WERKS = LR_LINK_STOCK->WERKS
                                                       LGORT = LR_LINK_STOCK->LGORT
                                                       MATNR = LR_LINK_STOCK->MATNR
                                                       CHARG = LR_LINK_STOCK->CHARG BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_LINK_STOCK->LABST2 = LS_DETAIL-MENGE. "// 기할당 재고 = 조장 X 절단 조장 수 .
    ENDIF.

    LR_LINK_STOCK->LABST3 = LR_LINK_STOCK->LABST1 - LR_LINK_STOCK->LABST2. "// 미할당 재고 = 가용 재고 - 기할당 재고
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_parameters_link_info_upd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARAMETERS_LINK_INFO_UPD  TABLES PT_ITEM   STRUCTURE ZGTPPSIF0044
                                            PT_RETURN STRUCTURE ZGTPPSIF0045.

  DATA LT_DD07V TYPE TABLE OF DD07V.

*// 플랜트.
  SELECT SINGLE @ABAP_TRUE INTO @DATA(LV_CHECK) FROM T001W WHERE WERKS EQ @GS_LINK_IMPORT-WERKS.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E011(VF) WITH GS_LINK_IMPORT-WERKS.
  ENDIF.

*// 처리 구분.
  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      NAME          = 'ZGTDUPD_TYPE'
      LANGU         = SY-LANGU
    TABLES
      DD07V_TAB     = LT_DD07V
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.

  IF NOT LINE_EXISTS( LT_DD07V[ DOMVALUE_L = GS_LINK_IMPORT-UPD_TYPE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

*// Link 업데이트 요청번호.
  CLEAR GS_ZGTPPT3360.

  IF GS_LINK_IMPORT-UPDRQ IS NOT INITIAL.
    SELECT SINGLE * INTO @GS_ZGTPPT3360 FROM ZGTPPT3360 WHERE UPDRQ EQ @GS_LINK_IMPORT-UPDRQ.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E08.
    ENDIF.
  ENDIF.

  PT_RETURN[] = CORRESPONDING #( PT_ITEM[] ).
  SORT PT_RETURN BY SEQNO.

  PERFORM GET_SALES_ORDER TABLES PT_ITEM.

  CLEAR: GT_MCHB, GT_MSKA, GT_ZLET0401, GT_ZGTPPT3360_U2, GT_ZGTPPT3360_U3, GT_ZPPT0001.

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    PERFORM CLEAR_VARIABLES.

    READ TABLE PT_RETURN REFERENCE INTO DATA(LR_RETURN) WITH KEY SEQNO = LS_ITEM-SEQNO BINARY SEARCH.

    CHECK SY-SUBRC IS INITIAL.

    CLEAR: LR_RETURN->CHK_STAT, LR_RETURN->CHK_MSG.

    TRY.
        CASE GS_LINK_IMPORT-UPD_TYPE.
          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U1. "// 절단 실적.
            PERFORM CHECK_UPD_TYPE_U1 USING LS_ITEM LR_RETURN->*.

          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z1. "// 절단 실적 취소.
            PERFORM CHECK_UPD_TYPE_Z1 USING LS_ITEM LR_RETURN->*.

          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U2. "// 출하(Factor).
            PERFORM CHECK_UPD_TYPE_U2 USING LS_ITEM LR_RETURN->*.

          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z2. "// 출하(Factor) 취소.
            PERFORM CHECK_UPD_TYPE_Z2 USING LS_ITEM LR_RETURN->*.

          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U3. "// 출하(Single Unit; 정조장) 스캔.
            PERFORM CHECK_UPD_TYPE_U3 USING LS_ITEM LR_RETURN->*.

          WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3. "// 출하(Single Unit; 정조장) 스캔 취소.
            PERFORM CHECK_UPD_TYPE_Z3 USING LS_ITEM LR_RETURN->*.
        ENDCASE.

        LR_RETURN->CHK_STAT = COND #( WHEN LR_RETURN->CHK_MSG IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-ERROR
                                      ELSE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS ).

      CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
        LR_RETURN->CHK_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        LR_RETURN->CHK_MSG  = LR_EXCEPTION->GET_TEXT( ).
    ENDTRY.
  ENDLOOP.

  IF GS_LINK_IMPORT-UPDRQ IS NOT INITIAL.
    PERFORM UPDATE_CHECK_RESULT TABLES PT_RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form link_info_update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM LINK_INFO_UPDATE  TABLES PT_ITEM   STRUCTURE ZGTPPSIF0044
                              PT_RETURN STRUCTURE ZGTPPSIF0045.

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    READ TABLE PT_RETURN REFERENCE INTO DATA(LR_RETURN) WITH KEY SEQNO = LS_ITEM-SEQNO BINARY SEARCH.

    CHECK SY-SUBRC IS INITIAL.

    CASE GS_LINK_IMPORT-UPD_TYPE."// 처리 구분.
      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U1. "// 절단 실적.
        PERFORM PROCESS_UPD_TYPE_U1 USING LS_ITEM LR_RETURN->*.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z1. "// 절단 실적 취소.
        PERFORM PROCESS_UPD_TYPE_Z1 USING LS_ITEM LR_RETURN->*.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U2. "// 출하(Factor).
        PERFORM PROCESS_UPD_TYPE_U2 USING LS_ITEM LR_RETURN->*.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z2. "// 출하(Factor) 취소.
        PERFORM PROCESS_UPD_TYPE_Z2 USING LS_ITEM LR_RETURN->*.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U3. "// 출하(Single Unit; 정조장) 스캔.
        PERFORM PROCESS_UPD_TYPE_U3 USING LS_ITEM LR_RETURN->*.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3. "// 출하(Single Unit; 정조장) 스캔 취소.
        PERFORM PROCESS_UPD_TYPE_Z3 USING LS_ITEM LR_RETURN->*.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U1  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

  IF PS_ITEM-TAGNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F05.
  ENDIF.

  IF PS_ITEM-ZCUT_ORD_NO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F06.
  ENDIF.

  IF PS_ITEM-ZCUT_ORD_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F07.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_U1_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_Z1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z1  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

  IF PS_ITEM-TAGNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F05.
  ENDIF.

  IF PS_ITEM-ZCUT_ORD_NO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F06.
  ENDIF.

  IF PS_ITEM-ZCUT_ORD_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F07.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_Z1_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U2  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

  IF PS_ITEM-DLVRQ IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F08.
  ENDIF.

  IF PS_ITEM-BUDAT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F09.
  ENDIF.

  IF PS_ITEM-VBELN IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F10.
  ENDIF.

  IF PS_ITEM-POSNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F11.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_U2_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_z2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z2  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

*  IF PS_ITEM-DLVRQ IS INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F08.
*  ENDIF.

*  IF PS_ITEM-BUDAT IS INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F09.
*  ENDIF.

  IF PS_ITEM-VBELN IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F10.
  ENDIF.

  IF PS_ITEM-POSNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F11.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_Z2_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U3  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

  IF PS_ITEM-TAGNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F05.
  ENDIF.

  IF PS_ITEM-VBELN IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F10.
  ENDIF.

  IF PS_ITEM-POSNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F11.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_U3_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_z3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z3  USING PS_ITEM   TYPE ZGTPPSIF0044
                              PS_RETURN TYPE ZGTPPSIF0045
                      RAISING LCX_EXCEPTION.

  IF PS_ITEM-SEQNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ENDIF.

  IF PS_ITEM-TAGNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F05.
  ENDIF.

  IF PS_ITEM-VBELN IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F10.
  ENDIF.

  IF PS_ITEM-POSNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F11.
  ENDIF.

  PERFORM CHECK_UPD_TYPE_Z3_IMPORT_VALUE USING PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_u1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_U1  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  TRY.
      PERFORM MODIFY_ALLOC_FOR_UPD_TYPE_U1  USING PS_RETURN.
      PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_U1 USING PS_ITEM PS_RETURN.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      RETURN.
  ENDTRY.

*// 절단 작업지시 재전송.
  ZGTPP_CL_COMMON=>SUBMIT_ZGTPPI2030( IV_WERKS      = GS_ZGTPPT2190-WERKS
                                      IT_ZASSIGN_NO = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GS_ZGTPPT2190-ZASSIGN_NO ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u1_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U1_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.
  DATA LT_CONFG  TYPE TY_T_CONFG.
  DATA LV_LENGTH TYPE MSKA-KALAB.

*// 실물 스캔 Lot로 배치번호 발췌.
  PERFORM SELECT_ZPPT0001 USING GS_LINK_IMPORT-WERKS PS_ITEM-TAGNR.

  IF GS_ZPPT0001 IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E10.
  ENDIF.

*// 배치재고.
  IF GS_ZGTPPT3360-AL_STAT NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    SELECT MSKA~MATNR, MSKA~WERKS, MSKA~LGORT, MSKA~CHARG, MSKA~VBELN, MSKA~POSNR, MSKA~KALAB
      FROM MSKA
     WHERE MATNR EQ @GS_ZPPT0001-MATNR
       AND WERKS EQ @GS_ZPPT0001-WERKS
       AND CHARG EQ @GS_ZPPT0001-CHARG
       AND KALAB GT 0
      INTO TABLE @DATA(LT_MSKA).

    IF SY-SUBRC IS NOT INITIAL.
      SELECT MCHB~MATNR, MCHB~WERKS, MCHB~LGORT, MCHB~CHARG, MCHB~CLABS
        FROM MCHB
       WHERE MATNR EQ @GS_ZPPT0001-MATNR
         AND WERKS EQ @GS_ZPPT0001-WERKS
         AND CHARG EQ @GS_ZPPT0001-CHARG
         AND CLABS GT 0
        INTO TABLE @DATA(LT_MCHB).

      IF SY-SUBRC IS NOT INITIAL.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
      ENDIF.
    ENDIF.
  ENDIF.

*// 동일 품목-동일 조장 여부 점검.
  DATA(LV_LABST) = COND LABST( WHEN LT_MSKA IS NOT INITIAL THEN VALUE #( LT_MSKA[ 1 ]-KALAB OPTIONAL )
                                                           ELSE VALUE #( LT_MCHB[ 1 ]-CLABS OPTIONAL ) ).

  READ TABLE GT_SLORD INTO DATA(LS_SLORD) WITH KEY VBELN = PS_ITEM-VBELN
                                                   POSNR = PS_ITEM-POSNR BINARY SEARCH.

  PERFORM GET_VC_CONFIGURATION USING LS_SLORD-CUOBJ LT_CONFG.

*  NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( VALUE #( LT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ]-ATWRT OPTIONAL ) )
*                                               IMPORTING EV_OUTPUT = LV_LENGTH ).
*
*  IF LS_SLORD-MATNR NE GS_ZPPT0001-MATNR OR
*     LV_LABST       NE LV_LENGTH.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E18.
*  ENDIF.

*// 절단 작업지시로 주문 할당 정보 발췌.
  SELECT SINGLE ZCUT_ORD_NO, ZCUT_ORD_ITEM, WERKS, ZASSIGN_NO, ZASSIGN_ITEM
    FROM ZGTPPT2190
   WHERE ZCUT_ORD_NO   EQ @PS_ITEM-ZCUT_ORD_NO
     AND ZCUT_ORD_ITEM EQ @PS_ITEM-ZCUT_ORD_ITEM
*     AND ZCUT_MBLNR    EQ @SPACE
*     AND LOEKZ         EQ @SPACE
    INTO CORRESPONDING FIELDS OF @GS_ZGTPPT2190.

*  IF SY-SUBRC IS NOT INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
*  ENDIF.

*// 주문 할당 아이템 정보 발췌.
  SELECT ZT02~ZASSIGN_NO, ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO   EQ ZT02~ZASSIGN_NO
   WHERE ZT02~ZASSIGN_NO   EQ @GS_ZGTPPT2190-ZASSIGN_NO
     AND ZT02~ZASSIGN_ITEM EQ @GS_ZGTPPT2190-ZASSIGN_ITEM
    INTO TABLE @DATA(LT_ZGTPPT2180).

  IF SY-SUBRC IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u2_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U2_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.
  DATA: LT_MCHB TYPE TABLE OF MCHB.

  SELECT SINGLE *
    FROM ZLET0401
   WHERE DLVRQ EQ @PS_ITEM-DLVRQ
     AND VBELN EQ @PS_ITEM-VBELN
     AND POSNR EQ @PS_ITEM-POSNR
    INTO CORRESPONDING FIELDS OF @GS_ZLET0401.

  CHECK SY-SUBRC IS INITIAL AND
        GS_ZGTPPT3360-TR_STAT NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.

  "BATCH 유형 점검
  SELECT SINGLE DPCBT
    FROM MARC
   WHERE MATNR EQ @GS_ZLET0401-MATNR
     AND WERKS EQ @GS_ZLET0401-WERKS
    INTO @DATA(LV_DPCBT).

  IF LV_DPCBT EQ 'A'.
    DATA(LV_CHARG) = CONV CHARG_D( TRUNC( GS_ZLET0401-INDLEN ) ).
    CONDENSE LV_CHARG NO-GAPS.

    CLEAR: LT_MCHB.
    SELECT MCHB~MATNR, MCHB~WERKS, MCHB~LGORT, MCHB~CHARG, MCHB~CLABS
      FROM MCHB
     WHERE MATNR EQ @GS_ZLET0401-MATNR
       AND WERKS EQ @GS_ZLET0401-WERKS
       AND LGORT BETWEEN '3410' AND '3480'
       AND CHARG EQ @LV_CHARG
     ORDER BY MCHB~MATNR, MCHB~WERKS, MCHB~CHARG, MCHB~LGORT
      INTO CORRESPONDING FIELDS OF TABLE @LT_MCHB.

  ELSE.
    CLEAR: LT_MCHB.
    SELECT MCHB~MATNR, MCHB~WERKS, MCHB~LGORT, MCHB~CHARG, MCHB~CLABS
      FROM MCHB
     WHERE MATNR EQ @GS_ZLET0401-MATNR
       AND WERKS EQ @GS_ZLET0401-WERKS
       AND LGORT BETWEEN '3410' AND '3480'
       AND CLABS > 0
     ORDER BY MCHB~MATNR, MCHB~WERKS, MCHB~CHARG, MCHB~LGORT
      INTO CORRESPONDING FIELDS OF TABLE @LT_MCHB.

  ENDIF.

  APPEND GS_ZLET0401 TO GT_ZLET0401.
  APPEND LINES OF LT_MCHB TO GT_MCHB.
  CLEAR: LV_DPCBT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_zppt0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SELECT_ZPPT0001  USING PV_WERKS PV_TAGNR.

  SELECT SINGLE ZT01~WERKS, ZT01~TAGNR, ZT01~MATNR, ZT01~CHARG,
                ZT01~REMAIN, MARA~MEINS
    INTO CORRESPONDING FIELDS OF @GS_ZPPT0001
    FROM ZPPT0001 AS ZT01
    JOIN MARA
      ON ZT01~MATNR EQ MARA~MATNR
   WHERE WERKS EQ @PV_WERKS
     AND TAGNR EQ @PV_TAGNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_z1_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z1_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.

*// 실물 스캔 Lot로 배치번호 발췌.
*  PERFORM SELECT_ZPPT0001 USING GS_LINK_IMPORT-WERKS PS_ITEM-TAGNR.
*
*  IF GS_ZPPT0001 IS INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E10.
*  ENDIF.

*// 절단 작업지시로 주문 할당 정보 발췌.
  SELECT SINGLE ZCUT_ORD_NO, ZCUT_ORD_ITEM, WERKS, ZASSIGN_NO, ZASSIGN_ITEM
    FROM ZGTPPT2190
   WHERE ZCUT_ORD_NO   EQ @PS_ITEM-ZCUT_ORD_NO
     AND ZCUT_ORD_ITEM EQ @PS_ITEM-ZCUT_ORD_ITEM
*     AND ZCUT_MBLNR    EQ @SPACE
*     AND LOEKZ         EQ @SPACE
    INTO CORRESPONDING FIELDS OF @GS_ZGTPPT2190.

*  IF SY-SUBRC IS NOT INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
*  ENDIF.

*// 주문 할당 아이템 정보 발췌.
  SELECT ZT02~ZASSIGN_NO, ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT02~ZASSIGN_NO   EQ @GS_ZGTPPT2190-ZASSIGN_NO
     AND ZT02~ZASSIGN_ITEM EQ @GS_ZGTPPT2190-ZASSIGN_ITEM
    INTO TABLE @DATA(LT_ZGTPPT2180).

  IF SY-SUBRC IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_z2_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z2_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF @GS_ZGTPPT3360_U2
    FROM ZGTPPT3360
   WHERE UPD_TYPE EQ @ZGTPP_IF_CONST=>GC_UPD_TYPE-U2
     AND DLVRQ    EQ @PS_ITEM-DLVRQ
     AND VBELN    EQ @PS_ITEM-VBELN
     AND POSNR    EQ @PS_ITEM-POSNR
     AND LOEKZ    EQ @SPACE.

  IF GS_ZGTPPT3360 IS INITIAL.
    IF GS_ZGTPPT3360_U2-TR_MBLNR IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E15.
    ENDIF.
  ELSE.
    IF GS_ZGTPPT3360_U2-TR_MBLNR IS INITIAL OR GS_ZGTPPT3360-TR_MBLNR IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E15.
    ENDIF.
  ENDIF.

  APPEND GS_ZGTPPT3360_U2 TO GT_ZGTPPT3360_U2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_u3_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_U3_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.

  DATA LT_MSKA TYPE TABLE OF MSKA.

*// 실물 스캔 Lot로 배치번호 발췌.
  PERFORM SELECT_ZPPT0001 USING GS_LINK_IMPORT-WERKS PS_ITEM-TAGNR.

  IF GS_ZPPT0001 IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E10.
  ENDIF.

  CLEAR: LT_MSKA.
*// 배치재고.
  SELECT MATNR, WERKS, LGORT, CHARG, VBELN, POSNR, KALAB
    FROM MSKA
   WHERE MATNR EQ @GS_ZPPT0001-MATNR
     AND WERKS EQ @GS_ZPPT0001-WERKS
     AND LGORT BETWEEN '3410' AND '3480'
     AND CHARG EQ @GS_ZPPT0001-CHARG
     AND KALAB GT 0
   ORDER BY MATNR, WERKS, LGORT, CHARG
    INTO CORRESPONDING FIELDS OF TABLE @LT_MSKA.

  IF SY-SUBRC IS NOT INITIAL.
    SELECT MATNR, WERKS, LGORT, CHARG, CLABS AS KALAB
      FROM MCHB
     WHERE MATNR EQ @GS_ZPPT0001-MATNR
       AND WERKS EQ @GS_ZPPT0001-WERKS
       AND LGORT BETWEEN '3410' AND '3480'
       AND CHARG EQ @GS_ZPPT0001-CHARG
       AND CLABS GT 0
     ORDER BY MATNR, WERKS, LGORT, CHARG
      INTO CORRESPONDING FIELDS OF TABLE @LT_MSKA.

    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
    ENDIF.
  ENDIF.

  SELECT ZT01~ZASSIGN_NO,   ZT01~WERKS, ZT01~VBELN, ZT01~POSNR, ZT01~WELENG, ZT01~WECNT, ZT01~MATNR,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG, ZT02~ZCUT_CNT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~VBELN EQ @PS_ITEM-VBELN
     AND ZT01~POSNR EQ @PS_ITEM-POSNR
     AND ZT01~LOEKZ EQ @SPACE
    INTO TABLE @DATA(LT_ALLOC1).

  SELECT ZT01~ZASSIGN_NO,   ZT01~WERKS, ZT01~VBELN, ZT01~POSNR, ZT01~WELENG, ZT01~WECNT, ZT01~MATNR,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG, ZT02~ZCUT_CNT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~LOEKZ   EQ @SPACE
     AND ZT02~F_CHARG EQ @GS_ZPPT0001-CHARG
    INTO TABLE @DATA(LT_ALLOC2).

*// 주문 할당이 없는 판매오더를 대상으로 다른 주문에 할당된 LOT를 SCAN하는 경우 .
  IF LT_ALLOC1 IS INITIAL AND LT_ALLOC2 IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E029 WITH PS_ITEM-VBELN PS_ITEM-POSNR.
  ENDIF.

*// 재고가 존재하는 경우, 판매오더 정보(VBELN, POSNR)"와 IT_ITEM의 "판매오더 정보(VBELN, POSNR)"가 서로 다른 경우 .
  IF LT_MSKA IS NOT INITIAL.
    DATA(LS_MSKA) = LT_MSKA[ 1 ].

    IF LS_MSKA-VBELN IS NOT INITIAL.
      IF |{ LS_MSKA-VBELN }{ LS_MSKA-POSNR }| NE |{ PS_ITEM-VBELN }{ PS_ITEM-POSNR }|.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E030 WITH PS_ITEM-VBELN PS_ITEM-POSNR.
      ENDIF.
    ENDIF.
  ENDIF.

  APPEND GS_ZPPT0001 TO GT_ZPPT0001.
  APPEND LINES OF LT_MSKA TO GT_MSKA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_z1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_Z1  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  TRY.
      PERFORM MODIFY_ALLOC_FOR_UPD_TYPE_Z1  USING PS_RETURN.
      PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_Z1 USING PS_ITEM PS_RETURN.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      RETURN.
  ENDTRY.

*// 절단 작업지시 재전송.
  ZGTPP_CL_COMMON=>SUBMIT_ZGTPPI2030( IV_WERKS      = GS_ZGTPPT2190-WERKS
                                      IT_ZASSIGN_NO = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GS_ZGTPPT2190-ZASSIGN_NO ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_date_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATE_TIME .

  GS_ZGTPPS1001-CRDAT = SY-DATUM.
  GS_ZGTPPS1001-CRTIM = SY-UZEIT.
  GS_ZGTPPS1001-CRNAM = SY-UNAME.
  GS_ZGTPPS1001-CHDAT = SY-DATUM.
  GS_ZGTPPS1001-CHTIM = SY-UZEIT.
  GS_ZGTPPS1001-CHNAM = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_next_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_NEXT_NUMBER  USING PV_OBJECT PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = COND NRNR( WHEN PV_OBJECT EQ 'ZGTPP_GORD' THEN '03'
                                           ELSE '01'  )
      OBJECT                  = PV_OBJECT
    IMPORTING
      NUMBER                  = PV_NUMBER
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_u2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_U2  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  SORT: GT_ZLET0401 BY DLVRQ VBELN POSNR,
        GT_MCHB BY MATNR WERKS CHARG.

  IF GS_ZGTPPT3360-TR_STAT NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
*// 이전 전기.
    PERFORM TRANSFER_POSTING_UPD_TYPE_U2 USING LS_HEADRET PS_ITEM PS_RETURN.

*// 처리 로그.
    PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_U2 USING LS_HEADRET PS_ITEM PS_RETURN.

*// FACTOR 배치 특성값 업데이트(DPCBT='A')
    IF PS_RETURN-TR_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      PERFORM FACTOR_BATCH_UPD_TYPE_U2 USING PS_ITEM.
    ENDIF.

    IF LS_HEADRET IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

*// 영업오더 할당.
  IF GS_ZGTPPT3360-AL_STAT NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PERFORM ALLOC_SALES_ORDER_UPD_TYPE_U2 USING PS_ITEM PS_RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form transfer_posting_upd_type_u2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM TRANSFER_POSTING_UPD_TYPE_U2  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                         PS_ITEM    TYPE ZGTPPSIF0044
                                         PS_RETURN  TYPE ZGTPPSIF0045.

  DATA LT_RETURN TYPE TABLE OF BAPIRET2.

  CLEAR: GS_ZLET0401.
  READ TABLE GT_ZLET0401 INTO GS_ZLET0401 WITH KEY DLVRQ = PS_ITEM-DLVRQ
                                                   VBELN = PS_ITEM-VBELN
                                                   POSNR = PS_ITEM-POSNR.

  "BATCH 유형 점검
  SELECT SINGLE XCHAR, DPCBT
    FROM MARC
   WHERE MATNR EQ @GS_ZLET0401-MATNR
     AND WERKS EQ @GS_ZLET0401-WERKS
    INTO (@DATA(LV_XCHAR), @DATA(LV_DPCBT)).

  IF LV_XCHAR EQ 'X'.
    IF LV_DPCBT EQ 'A'.
      DATA(LV_CHARG) = CONV CHARG_D( TRUNC( GS_ZLET0401-INDLEN ) ).
      CONDENSE LV_CHARG NO-GAPS.

      READ TABLE GT_MCHB INTO DATA(LS_MCHB) WITH KEY MATNR = GS_ZLET0401-MATNR
                                                     WERKS = GS_ZLET0401-WERKS
                                                     CHARG = LV_CHARG BINARY SEARCH.
    ELSE.
      CLEAR: LS_MCHB.
      READ TABLE GT_MCHB INTO LS_MCHB WITH KEY MATNR = GS_ZLET0401-MATNR
                                               WERKS = GS_ZLET0401-WERKS BINARY SEARCH.

      CLEAR: LV_CHARG.
      LV_CHARG = LS_MCHB-CHARG.
    ENDIF.

  ELSE.
    CLEAR: LS_MCHB.
    SELECT SINGLE LGORT
      FROM MARD
     WHERE MATNR EQ @GS_ZLET0401-MATNR
       AND WERKS EQ @GS_ZLET0401-WERKS
       AND LABST GT 0
      INTO @LS_MCHB-LGORT.

    CLEAR: LV_CHARG.

  ENDIF.

  DATA(LT_ITEM) = VALUE GM_ITEMS_T( ( MATERIAL       = CONV MATNR18( GS_ZLET0401-MATNR )
                                      PLANT          = GS_ZLET0401-WERKS
                                      STGE_LOC       = LS_MCHB-LGORT
                                      BATCH          = LV_CHARG
                                      VAL_SALES_ORD  = SPACE
                                      VAL_S_ORD_ITEM = SPACE
                                      MOVE_TYPE      = '413'
                                      SPEC_STOCK     = SPACE
                                      MOVE_MAT       = CONV MATNR18( GS_ZPPT0001-MATNR )
                                      MOVE_PLANT     = GS_ZLET0401-WERKS
                                      MOVE_STLOC     = LS_MCHB-LGORT
                                      MOVE_BATCH     = LV_CHARG
                                      STCK_TYPE      = SPACE
                                      ENTRY_UOM      = GS_ZLET0401-VRKME
                                      ENTRY_QNT      = GS_ZLET0401-DLRMG
                                      SALES_ORD      = GS_ZLET0401-VBELN
                                      S_ORD_ITEM     = GS_ZLET0401-POSNR  ) ).

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_ITEM-BUDAT
                                                    HEADER_TXT = ZGTPP_IF_CONST=>GC_UPD_TYPE-U2 )
      GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
    IMPORTING
      GOODSMVT_HEADRET = PS_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF PS_HEADRET IS NOT INITIAL.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = TEXT-S12.
  ELSE.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
  ENDIF.

  CLEAR: LV_XCHAR, LV_DPCBT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zgtppt3360_upd_type_u2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_U2  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                          PS_ITEM    TYPE ZGTPPSIF0044
                                          PS_RETURN  TYPE ZGTPPSIF0045.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ     = PS_RETURN-UPDRQ
                                          UPD_TYPE  = ZGTPP_IF_CONST=>GC_UPD_TYPE-U2
                                          LOEKZ     = SPACE
                                          WERKS     = GS_LINK_IMPORT-WERKS
                                          DLVRQ     = PS_ITEM-DLVRQ
                                          VBELN     = PS_ITEM-VBELN
                                          POSNR     = PS_ITEM-POSNR
                                          KWMENG    = GS_ZLET0401-DLRMG
                                          VRKME     = GS_ZLET0401-VRKME
                                          TR_STAT   = PS_RETURN-TR_STAT
                                          TR_MBLNR  = PS_HEADRET-MAT_DOC
                                          TR_MJAHR  = PS_HEADRET-DOC_YEAR
                                          BUDAT     = PS_ITEM-BUDAT
                                          STAT_MSG  = PS_RETURN-STAT_MSG
                                          CHK_STAT  = PS_RETURN-CHK_STAT
                                          CHK_MSG   = PS_RETURN-CHK_MSG  ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zt3360_for_upd_type_u1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_U1  USING PS_ITEM   TYPE ZGTPPSIF0044
                                          PS_RETURN TYPE ZGTPPSIF0045
                                  RAISING LCX_EXCEPTION.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ         = PS_RETURN-UPDRQ
                                          UPD_TYPE      = ZGTPP_IF_CONST=>GC_UPD_TYPE-U1
                                          LOEKZ         = SPACE
                                          WERKS         = GS_LINK_IMPORT-WERKS
                                          TAGNR         = PS_ITEM-TAGNR
                                          ZCUT_ORD_NO   = PS_ITEM-ZCUT_ORD_NO
                                          ZCUT_ORD_ITEM = PS_ITEM-ZCUT_ORD_ITEM
                                          AL_STAT       = PS_RETURN-AL_STAT
                                          STAT_MSG      = PS_RETURN-STAT_MSG
                                          CHK_STAT      = PS_RETURN-CHK_STAT
                                          CHK_MSG       = PS_RETURN-CHK_MSG  ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  IF SY-SUBRC IS INITIAL.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_RETURN-STAT_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zt3360_for_upd_type_z1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_Z1  USING PS_ITEM   TYPE ZGTPPSIF0044
                                          PS_RETURN TYPE ZGTPPSIF0045
                                  RAISING LCX_EXCEPTION.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ         = PS_RETURN-UPDRQ
                                          UPD_TYPE      = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z1
                                          LOEKZ         = SPACE
                                          WERKS         = GS_LINK_IMPORT-WERKS
                                          TAGNR         = PS_ITEM-TAGNR
                                          ZCUT_ORD_NO   = PS_ITEM-ZCUT_ORD_NO
                                          ZCUT_ORD_ITEM = PS_ITEM-ZCUT_ORD_ITEM
                                          AL_STAT       = PS_RETURN-AL_STAT
                                          STAT_MSG      = PS_RETURN-STAT_MSG
                                          CHK_STAT      = PS_RETURN-CHK_STAT
                                          CHK_MSG       = PS_RETURN-CHK_MSG  ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  IF SY-SUBRC IS INITIAL.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_RETURN-STAT_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alloc_sales_order_upd_type_u2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ALLOC_SALES_ORDER_UPD_TYPE_U2  USING PS_ITEM   TYPE ZGTPPSIF0044
                                          PS_RETURN TYPE ZGTPPSIF0045.

  DATA: BEGIN OF LS_ZASSIGN,
          ZASSIGN_NO LIKE ZGTPPT2180-ZASSIGN_NO,
          W_MENGE    LIKE MATDOC-ERFMG,
          A_MENGE    LIKE MATDOC-ERFMG,
          Y_CHK(1),
        END OF LS_ZASSIGN.
  DATA: LT_ZASSIGN LIKE TABLE OF LS_ZASSIGN.
  DATA: LV_REMAIN TYPE ERFMG.

  UPDATE ZGTPPT3360
     SET AL_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
         CHDAT   = GS_ZGTPPS1001-CHDAT
         CHTIM   = GS_ZGTPPS1001-CHTIM
         CHNAM   = GS_ZGTPPS1001-CHNAM
   WHERE UPDRQ EQ PS_RETURN-UPDRQ.

  COMMIT WORK AND WAIT.

  PS_RETURN-AL_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.

  "판매오더 재고 이전전기 수량 점검
  SELECT SUM( ERFMG )
    FROM MATDOC
   WHERE MAT_KDAUF EQ @PS_ITEM-VBELN
     AND MAT_KDPOS EQ @PS_ITEM-POSNR
     AND BWART EQ '413'
     AND CANCELLED EQ @SPACE
    INTO @DATA(LV_ERFMG).

  "판매오더 수량 점검
  SELECT SINGLE KWMENG
    FROM VBAP
   WHERE VBELN EQ @PS_ITEM-VBELN
     AND POSNR EQ @PS_ITEM-POSNR
    INTO @DATA(LV_KWMENG).

  "판매오더 수량 =< 판매오더 재고 이전전기 수량
  IF LV_KWMENG =< LV_ERFMG.
    CLEAR: LT_ZASSIGN.
    SELECT ZASSIGN_NO
      FROM ZGTPPT2170
     WHERE VBELN EQ @PS_ITEM-VBELN
       AND POSNR EQ @PS_ITEM-POSNR
       AND LOEKZ EQ @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @LT_ZASSIGN.

    IF LT_ZASSIGN IS NOT INITIAL.
      LOOP AT LT_ZASSIGN INTO LS_ZASSIGN.
        UPDATE ZGTPPT2170
           SET LOEKZ       = 'C'
               STOCK_COMPL = 'Y'
         WHERE ZASSIGN_NO EQ LS_ZASSIGN-ZASSIGN_NO.

        CLEAR: LS_ZASSIGN.
      ENDLOOP.
    ENDIF.

*    SELECT SINGLE ZASSIGN_NO
*      INTO @DATA(LV_ZASSIGN_NO)
*      FROM ZGTPPT2170
*     WHERE VBELN EQ @PS_ITEM-VBELN
*       AND POSNR EQ @PS_ITEM-POSNR
**     AND DLVRQ EQ @PS_ITEM-DLVRQ  "20260704
*       AND LOEKZ EQ @SPACE.
*
*    CHECK LV_ZASSIGN_NO IS NOT INITIAL.
*
*    UPDATE ZGTPPT2170
*       SET LOEKZ       = 'C' "ABAP_TRUE
*           STOCK_COMPL = 'Y'
*     WHERE ZASSIGN_NO EQ LV_ZASSIGN_NO.

    "판매오더 수량 > 판매오더 재고 이전전기 수량
  ELSEIF LV_KWMENG > LV_ERFMG.
    IF LV_ERFMG > 0. "판매오더 재고 이전전기 수량 > 0
      "판매오더 정보로 주문할당 추출
      SELECT A~ZASSIGN_NO, A~ZASSIGN_ITEM, A~ZCUT_CNT, A~MEINS,
             B~VBELN, B~POSNR, B~WELENG
        FROM ZGTPPT2180 AS A
        JOIN ZGTPPT2170 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
       WHERE B~LOEKZ EQ @SPACE
         AND B~VBELN EQ @PS_ITEM-VBELN
         AND B~POSNR EQ @PS_ITEM-POSNR
        INTO TABLE @DATA(LT_OZASSIGN).

      SORT LT_OZASSIGN BY ZASSIGN_NO ZASSIGN_ITEM.

      CLEAR: LT_ZASSIGN.
      LOOP AT LT_OZASSIGN INTO DATA(LS_O).
        LS_ZASSIGN-ZASSIGN_NO = LS_O-ZASSIGN_NO.
        LS_ZASSIGN-W_MENGE = LS_O-WELENG * LS_O-ZCUT_CNT.
        COLLECT LS_ZASSIGN INTO LT_ZASSIGN.
        CLEAR: LS_ZASSIGN, LS_O.
      ENDLOOP.

      SORT LT_ZASSIGN BY ZASSIGN_NO.

      CLEAR: LV_REMAIN.
      LV_REMAIN = LV_ERFMG.
      LOOP AT LT_ZASSIGN ASSIGNING FIELD-SYMBOL(<FS_A>).
        IF LV_REMAIN >= <FS_A>-W_MENGE.
          <FS_A>-A_MENGE = <FS_A>-W_MENGE.
          LV_REMAIN = LV_REMAIN - <FS_A>-A_MENGE.
          <FS_A>-Y_CHK = 'X'.
        ENDIF.
      ENDLOOP.

      IF LT_ZASSIGN IS NOT INITIAL.
        LOOP AT LT_ZASSIGN INTO LS_ZASSIGN WHERE Y_CHK EQ 'X'.
          UPDATE ZGTPPT2170
             SET LOEKZ       = 'C'
                 STOCK_COMPL = 'Y'
           WHERE ZASSIGN_NO EQ LS_ZASSIGN-ZASSIGN_NO.

          CLEAR: LS_ZASSIGN.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDIF.
*  DATA(ls_mchb) = VALUE #( gt_mchb[ 1 ] OPTIONAL ).
*
*  READ TABLE gt_slord INTO DATA(ls_slord) WITH KEY vbeln = ps_item-vbeln
*                                                   posnr = ps_item-posnr BINARY SEARCH.

*  DATA(ls_zgtppt2170) = VALUE zgtppt2170( zassign_type = zgtpp_if_const=>gc_zassign_type-rw
*                                          loekz        = space
*                                          werks        = gs_zppt0001-werks
*                                          dlvrq        = ps_item-dlvrq
*                                          vbeln        = ps_item-vbeln
*                                          posnr        = ps_item-posnr
*                                          etenr        = '0001'
*                                          edatu        = ls_slord-edatu
*                                          wemeng       = gs_zlet0401-dlrmg
*                                          vrkme        = gs_zlet0401-vrkme
*                                          weleng       = gs_zlet0401-indlen
*                                          wecnt        = COND #( WHEN gs_zlet0401-indlen IS NOT INITIAL THEN gs_zlet0401-dlrmg / gs_zlet0401-indlen )
*                                          matnr        = gs_zppt0001-matnr
*                                          kunnr        = ls_slord-kunnr
*                                          vkorg        = ls_slord-vkorg
*                                          vtweg        = ls_slord-vtweg
*                                          spart        = ls_slord-spart
*                                          vkgrp        = ls_slord-vkgrp
*                                          vkbur        = ls_slord-vkbur ).
*
*  PERFORM get_next_number USING 'ZPP_ASSIGN' ls_zgtppt2170-zassign_no.
*
*  ls_zgtppt2170 = CORRESPONDING #( BASE ( ls_zgtppt2170 ) gs_zgtpps1001 ).
*
*  DATA(ls_zgtppt2180) = VALUE zgtppt2180( BASE CORRESPONDING zgtppt2180( ls_zgtppt2170 )  zassign_item  = '0001'
*                                                                                          lgort         = ls_mchb-lgort
*                                                                                          f_charg       = ls_mchb-charg
*                                                                                          labst1        = ls_mchb-clabs
*                                                                                          labst2        = gs_zlet0401-dlrmg
*                                                                                          zcut_yn       = space
*                                                                                          zcut_cnt      = gs_zlet0401-indqty
*                                                                                          zrew_yn       = space
*                                                                                          zexclude      = space ).
*
*  ls_zgtppt2180-labst3 = ls_zgtppt2180-labst1 - ls_zgtppt2180-labst2.
*
*  MODIFY zgtppt2170 FROM ls_zgtppt2170.
*  MODIFY zgtppt2180 FROM ls_zgtppt2180.

*  UPDATE zgtppt3360
*     SET al_stat = zgtpp_if_const=>gc_result-success
*         chdat   = gs_zgtpps1001-chdat
*         chtim   = gs_zgtpps1001-chtim
*         chnam   = gs_zgtpps1001-chnam
*   WHERE updrq EQ ps_return-updrq.
*
*  COMMIT WORK AND WAIT.
*
*  ps_return-al_stat = zgtpp_if_const=>gc_result-success.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_z2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_Z2  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  SORT GT_ZGTPPT3360_U2 BY DLVRQ VBELN POSNR.

*// 이전전기 취소.
  PERFORM GOODSMVT_CANCEL_UPD_TYPE_Z2 USING LS_HEADRET PS_ITEM PS_RETURN.

*// 처리 결과.
  PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_Z2 USING LS_HEADRET PS_ITEM PS_RETURN.

*// FACTOR 배치 특성값 업데이트(DPCBT='A')
  IF PS_RETURN-TR_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PERFORM FACTOR_BATCH_UPD_TYPE_Z2 USING PS_ITEM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form goodsmvt_cancel_upd_type_z2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GOODSMVT_CANCEL_UPD_TYPE_Z2  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                        PS_ITEM    TYPE ZGTPPSIF0044
                                        PS_RETURN  TYPE ZGTPPSIF0045.

  DATA: BEGIN OF LS_ZASSIGN,
          ZASSIGN_NO LIKE ZGTPPT2180-ZASSIGN_NO,
          W_MENGE    LIKE MATDOC-ERFMG,
          A_MENGE    LIKE MATDOC-ERFMG,
          Y_CHK(1),
        END OF LS_ZASSIGN.
  DATA: LT_ZASSIGN LIKE TABLE OF LS_ZASSIGN.
  DATA: LV_REMAIN TYPE ERFMG.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.

  CLEAR: GS_ZGTPPT3360_U2.
  READ TABLE GT_ZGTPPT3360_U2 INTO GS_ZGTPPT3360_U2 WITH KEY DLVRQ = PS_ITEM-DLVRQ
                                                             VBELN = PS_ITEM-VBELN
                                                             POSNR = PS_ITEM-POSNR.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_ZGTPPT3360_U2-TR_MBLNR
      MATDOCUMENTYEAR     = GS_ZGTPPT3360_U2-TR_MJAHR
      GOODSMVT_PSTNG_DATE = PS_ITEM-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = PS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF PS_HEADRET IS NOT INITIAL.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'S' ]-MESSAGE OPTIONAL ).

    UPDATE ZGTPPT3360
       SET LOEKZ = ABAP_TRUE
           CHDAT = GS_ZGTPPS1001-CHDAT
           CHTIM = GS_ZGTPPS1001-CHTIM
           CHNAM = GS_ZGTPPS1001-CHNAM
     WHERE UPDRQ EQ GS_ZGTPPT3360_U2-UPDRQ.

*    UPDATE ZGTPPT2170
*       SET LOEKZ       = ABAP_FALSE
*           STOCK_COMPL = ABAP_FALSE
*           CHDAT = GS_ZGTPPS1001-CHDAT
*           CHTIM = GS_ZGTPPS1001-CHTIM
*           CHNAM = GS_ZGTPPS1001-CHNAM
*     WHERE VBELN EQ GS_ZGTPPT3360_U2-VBELN
*       AND POSNR EQ GS_ZGTPPT3360_U2-POSNR.
**       and DLVRQ EQ GS_ZGTPPT3360_U2-DLVRQ. "20260704

    "판매오더 재고 이전전기 수량 점검
    SELECT SUM( ERFMG )
      FROM MATDOC
     WHERE MAT_KDAUF EQ @PS_ITEM-VBELN
       AND MAT_KDPOS EQ @PS_ITEM-POSNR
       AND BWART EQ '413'
       AND CANCELLED EQ @SPACE
      INTO @DATA(LV_ERFMG).

    "판매오더 수량 점검
    SELECT SINGLE KWMENG
      FROM VBAP
     WHERE VBELN EQ @PS_ITEM-VBELN
       AND POSNR EQ @PS_ITEM-POSNR
      INTO @DATA(LV_KWMENG).

    "판매오더 수량 =< 판매오더 재고 이전전기 수량
    IF LV_KWMENG =< LV_ERFMG.
*      SELECT SINGLE ZASSIGN_NO
*        INTO @DATA(LV_ZASSIGN_NO)
*        FROM ZGTPPT2170
*       WHERE VBELN EQ @PS_ITEM-VBELN
*         AND POSNR EQ @PS_ITEM-POSNR
*         AND LOEKZ EQ @SPACE.
*
*      CHECK LV_ZASSIGN_NO IS NOT INITIAL.
*
*      UPDATE ZGTPPT2170
*         SET LOEKZ       = ABAP_FALSE
*             STOCK_COMPL = ABAP_FALSE
*             CHDAT = GS_ZGTPPS1001-CHDAT
*             CHTIM = GS_ZGTPPS1001-CHTIM
*             CHNAM = GS_ZGTPPS1001-CHNAM
*       WHERE ZASSIGN_NO EQ LV_ZASSIGN_NO.

      "판매오더 수량 > 판매오더 재고 이전전기 수량
    ELSEIF LV_KWMENG > LV_ERFMG.
      "판매오더 정보로 주문할당 추출
      SELECT A~ZASSIGN_NO, A~ZASSIGN_ITEM, A~ZCUT_CNT, A~MEINS,
             B~VBELN, B~POSNR, B~WELENG
        FROM ZGTPPT2180 AS A
        JOIN ZGTPPT2170 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
       WHERE B~LOEKZ NE 'X'
         AND B~VBELN EQ @PS_ITEM-VBELN
         AND B~POSNR EQ @PS_ITEM-POSNR
        INTO TABLE @DATA(LT_OZASSIGN).

      SORT LT_OZASSIGN BY ZASSIGN_NO ZASSIGN_ITEM.

      CLEAR: LT_ZASSIGN.
      LOOP AT LT_OZASSIGN INTO DATA(LS_O).
        LS_ZASSIGN-ZASSIGN_NO = LS_O-ZASSIGN_NO.
        LS_ZASSIGN-W_MENGE = LS_O-WELENG * LS_O-ZCUT_CNT.
        COLLECT LS_ZASSIGN INTO LT_ZASSIGN.
        CLEAR: LS_ZASSIGN, LS_O.
      ENDLOOP.

      SORT LT_ZASSIGN BY ZASSIGN_NO.

      CLEAR: LV_REMAIN.
      LV_REMAIN = LV_ERFMG.

      LOOP AT LT_ZASSIGN ASSIGNING FIELD-SYMBOL(<FS_A>).
        IF LV_REMAIN >= <FS_A>-W_MENGE.
          <FS_A>-A_MENGE = <FS_A>-W_MENGE.
          LV_REMAIN = LV_REMAIN - <FS_A>-A_MENGE.
          <FS_A>-Y_CHK = 'X'.
        ENDIF.
      ENDLOOP.

      IF LT_ZASSIGN IS NOT INITIAL.
        LOOP AT LT_ZASSIGN INTO LS_ZASSIGN WHERE Y_CHK EQ SPACE.
          UPDATE ZGTPPT2170
             SET LOEKZ       = ABAP_FALSE
                 STOCK_COMPL = ABAP_FALSE
                 CHDAT = GS_ZGTPPS1001-CHDAT
                 CHTIM = GS_ZGTPPS1001-CHTIM
                 CHNAM = GS_ZGTPPS1001-CHNAM
           WHERE ZASSIGN_NO EQ LS_ZASSIGN-ZASSIGN_NO.

          CLEAR: LS_ZASSIGN.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ELSE.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
  ENDIF.

  PS_RETURN-UPDRQ = GS_ZGTPPT3360_U2-UPDRQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_u3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_U3  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  SORT: GT_ZPPT0001 BY TAGNR,
        GT_MSKA BY MATNR WERKS LGORT CHARG.

  CLEAR: GS_ZPPT0001.
  READ TABLE GT_ZPPT0001 INTO GS_ZPPT0001 WITH KEY TAGNR = PS_ITEM-TAGNR.

*// 이전 전기.
  PERFORM TRANSFER_POSTING_UPD_TYPE_U3 USING LS_HEADRET PS_ITEM PS_RETURN.

*// 처리 결과.
  PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_U3 USING LS_HEADRET PS_ITEM PS_RETURN.

  IF LS_HEADRET IS INITIAL.
    RETURN.
  ENDIF.

*// 영업오더 할당 취소.
*  PERFORM CANCEL_SALES_ORDER_ALLOCATION USING PS_RETURN ZGTPP_IF_CONST=>GC_UPD_TYPE-U3.
  PERFORM CANCEL_SALES_ORDER_ALLOC_U3 USING PS_ITEM PS_RETURN.

  IF PS_RETURN-AL_STAT NE ZGTPP_IF_CONST=>GC_RESULT-ERROR.
*// 영업오더 할당.
    PERFORM ALLOC_SALES_ORDER_UPD_TYPE_U3 USING PS_ITEM PS_RETURN.
  ENDIF.

*// 주문 할당 정보의 LOT 정보 업데이트.
  PERFORM UPDATE_LOT_FOR_ORDER_ALLOC USING PS_ITEM.

*// 주문 할당 정보의 LOT 정보 업데이트.
  PERFORM UPDATE_LOT_FOR_ORDER_ALLOC_2 USING PS_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_upd_type_z3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESS_UPD_TYPE_Z3  USING PS_ITEM   TYPE ZGTPPSIF0044
                                PS_RETURN TYPE ZGTPPSIF0045.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  SORT: GT_ZPPT0001 BY TAGNR,
        GT_ZGTPPT3360_U3 BY TAGNR VBELN POSNR.

  CLEAR: GS_ZPPT0001.
  READ TABLE GT_ZPPT0001 INTO GS_ZPPT0001 WITH KEY TAGNR = PS_ITEM-TAGNR.

*// 영업오더 할당 취소.
*  PERFORM CANCEL_SALES_ORDER_ALLOCATION USING PS_RETURN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3.
  PERFORM CANCEL_SALES_ORDER_ALLOC_Z3 USING PS_ITEM PS_RETURN.

  IF PS_RETURN-AL_STAT NE ZGTPP_IF_CONST=>GC_RESULT-ERROR.
*// 이전전기 취소.
    PERFORM GOODSMVT_CANCEL_UPD_TYPE_Z3 USING LS_HEADRET PS_ITEM PS_RETURN.
  ENDIF.

*// 처리 결과.
  PERFORM MODIFY_ZT3360_FOR_UPD_TYPE_Z3 USING LS_HEADRET PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alloc_sales_order_upd_type_u3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ALLOC_SALES_ORDER_UPD_TYPE_U3  USING PS_ITEM   TYPE ZGTPPSIF0044
                                          PS_RETURN TYPE ZGTPPSIF0045.
  DATA LT_CONFG TYPE TY_T_CONFG.
  DATA LV_WEMENG TYPE ZGTPPT2170-WEMENG.

  READ TABLE GT_SLORD INTO DATA(LS_SLORD) WITH KEY VBELN = PS_ITEM-VBELN
                                                   POSNR = PS_ITEM-POSNR BINARY SEARCH.

  PERFORM GET_VC_CONFIGURATION USING LS_SLORD-CUOBJ LT_CONFG.

  NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( VALUE #( LT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ]-ATWRT OPTIONAL ) )
                                               IMPORTING EV_OUTPUT = LV_WEMENG ).

  DATA(LS_ZGTPPT2170) = VALUE ZGTPPT2170( ZASSIGN_TYPE = ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-PC
                                          LOEKZ        = ABAP_TRUE
                                          STOCK_COMPL  = 'Y'
                                          WERKS        = GS_ZPPT0001-WERKS
                                          VBELN        = LS_SLORD-VBELN
                                          POSNR        = LS_SLORD-POSNR
                                          ETENR        = LS_SLORD-ETENR
                                          EDATU        = LS_SLORD-EDATU
                                          WEMENG       = LS_SLORD-WMENG
                                          VRKME        = LS_SLORD-VRKME
                                          WELENG       = LV_WEMENG
                                          WECNT        = VALUE #( LT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_FACTOR ]-ATWRT OPTIONAL )
                                          MATNR        = GS_ZPPT0001-MATNR
                                          KUNNR        = LS_SLORD-KUNNR
                                          VKORG        = LS_SLORD-VKORG
                                          VTWEG        = LS_SLORD-VTWEG
                                          SPART        = LS_SLORD-SPART
                                          VKGRP        = LS_SLORD-VKGRP
                                          VKBUR        = LS_SLORD-VKBUR ).

  PERFORM GET_NEXT_NUMBER USING 'ZPP_ASSIGN' LS_ZGTPPT2170-ZASSIGN_NO.

  DATA(LS_ZGTPPT2180) = VALUE ZGTPPT2180( ZASSIGN_NO   = LS_ZGTPPT2170-ZASSIGN_NO
                                          ZASSIGN_ITEM = '0001'
                                          LGORT        = GS_ZPPT0001-LGORT
                                          F_CHARG      = GS_ZPPT0001-CHARG
                                          LABST1       = COND #( WHEN GT_MSKA IS NOT INITIAL THEN GT_MSKA[ 1 ]-KALAB
                                                                 WHEN GT_MCHB IS NOT INITIAL THEN GT_MCHB[ 1 ]-CLABS )
                                          ZCUT_CNT     = '1' ).

  LS_ZGTPPT2170 = CORRESPONDING #( BASE ( LS_ZGTPPT2170 ) GS_ZGTPPS1001 ).
  LS_ZGTPPT2180 = CORRESPONDING #( BASE ( LS_ZGTPPT2180 ) GS_ZGTPPS1001 ).

  MODIFY ZGTPPT2170 FROM LS_ZGTPPT2170.
  MODIFY ZGTPPT2180 FROM LS_ZGTPPT2180.

  UPDATE ZGTPPT3360
     SET AL_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
         CHDAT   = GS_ZGTPPS1001-CHDAT
         CHTIM   = GS_ZGTPPS1001-CHTIM
         CHNAM   = GS_ZGTPPS1001-CHNAM
   WHERE UPDRQ EQ PS_RETURN-UPDRQ.

  COMMIT WORK AND WAIT.

  PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
  PS_RETURN-STAT_MSG = TEXT-S11.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SALES_ORDER  TABLES PT_ITEM STRUCTURE ZGTPPSIF0044.

  CLEAR GT_SLORD.

  CHECK PT_ITEM[] IS NOT INITIAL.

  SELECT VBAP~VBELN, VBAP~POSNR, VBAP~MATNR, VBAP~CUOBJ,
         VBEP~ETENR, VBEP~WMENG, VBEP~VRKME,
         VBAK~KUNNR, VBAK~VKORG, VBAK~VTWEG,
         VBAK~SPART, VBAK~VKGRP, VBAK~VKBUR
    INTO CORRESPONDING FIELDS OF TABLE @GT_SLORD
    FROM VBAP
    JOIN VBEP
      ON VBAP~VBELN EQ VBEP~VBELN
     AND VBAP~POSNR EQ VBEP~POSNR
     AND VBEP~ETENR EQ '0001'
    JOIN VBAK
      ON VBAP~VBELN EQ VBAK~VBELN
     FOR ALL ENTRIES IN @PT_ITEM[]
   WHERE VBAP~VBELN EQ @PT_ITEM-VBELN
     AND VBAP~POSNR EQ @PT_ITEM-POSNR.

  SORT GT_SLORD BY VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zt3360_for_upd_type_u3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_U3  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                          PS_ITEM    TYPE ZGTPPSIF0044
                                          PS_RETURN  TYPE ZGTPPSIF0045.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ     = PS_RETURN-UPDRQ
                                          UPD_TYPE  = ZGTPP_IF_CONST=>GC_UPD_TYPE-U3
                                          LOEKZ     = SPACE
                                          WERKS     = GS_LINK_IMPORT-WERKS
                                          TAGNR     = PS_ITEM-TAGNR
                                          VBELN     = PS_ITEM-VBELN
                                          POSNR     = PS_ITEM-POSNR
                                          TR_STAT   = PS_RETURN-TR_STAT
                                          TR_MBLNR  = PS_HEADRET-MAT_DOC
                                          TR_MJAHR  = PS_HEADRET-DOC_YEAR
                                          BUDAT     = PS_ITEM-BUDAT
                                          AL_STAT   = PS_RETURN-AL_STAT
                                          STAT_MSG  = PS_RETURN-STAT_MSG
                                          CHK_STAT  = PS_RETURN-CHK_STAT
                                          CHK_MSG   = PS_RETURN-CHK_MSG  ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zt3360_for_upd_type_z3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_Z3  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                          PS_ITEM    TYPE ZGTPPSIF0044
                                          PS_RETURN  TYPE ZGTPPSIF0045.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ    = PS_RETURN-UPDRQ
                                          UPD_TYPE = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3
                                          LOEKZ    = SPACE
                                          WERKS    = GS_LINK_IMPORT-WERKS
                                          TAGNR    = PS_ITEM-TAGNR
                                          VBELN    = PS_ITEM-VBELN
                                          POSNR    = PS_ITEM-POSNR
                                          TR_STAT  = PS_RETURN-TR_STAT
                                          AL_STAT  = PS_RETURN-AL_STAT
                                          STAT_MSG = PS_RETURN-STAT_MSG
                                          CHK_STAT = PS_RETURN-CHK_STAT
                                          CHK_MSG  = PS_RETURN-CHK_MSG  ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_sales_order_allocation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_SALES_ORDER_ALLOCATION  USING PS_RETURN TYPE ZGTPPSIF0045
                                          PV_UPD_TYPE.

  SELECT SINGLE ZT01~ZASSIGN_NO, ZT01~LOEKZ
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~WERKS   EQ @GS_ZPPT0001-WERKS
     AND ZT01~LOEKZ   EQ @SPACE
     AND ZT02~F_CHARG EQ @GS_ZPPT0001-CHARG
    INTO @DATA(LS_ZGTPPT2170).

  IF SY-SUBRC IS NOT INITIAL.
    IF PV_UPD_TYPE EQ ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3.
      PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      PS_RETURN-STAT_MSG = TEXT-E09.
    ENDIF.
  ELSE.
    CASE PV_UPD_TYPE.
      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-U3.
        DATA(LV_LOEKZ) = ABAP_TRUE.

      WHEN ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3.
        LV_LOEKZ = ABAP_TRUE.
    ENDCASE.

    UPDATE ZGTPPT2170
       SET LOEKZ       = LV_LOEKZ
           STOCK_COMPL = ABAP_FALSE
           CHDAT = GS_ZGTPPS1001-CHDAT
           CHTIM = GS_ZGTPPS1001-CHTIM
           CHNAM = GS_ZGTPPS1001-CHNAM
     WHERE ZASSIGN_NO EQ LS_ZGTPPT2170-ZASSIGN_NO.

    IF  PV_UPD_TYPE EQ ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3.
      PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      PS_RETURN-STAT_MSG = TEXT-S11.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_variables
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CLEAR_VARIABLES .

  CLEAR: GS_ZPPT0001, GS_ZGTPPT2190, GS_ZLET0401, "GS_ZGTPPT3360,
         GS_ZGTPPT3360_U2, GS_ZGTPPT3360_U3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_alloc_for_upd_type_u1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ALLOC_FOR_UPD_TYPE_U1 USING PS_RETURN TYPE ZGTPPSIF0045.

*  UPDATE ZGTPPT2180 SET
**                       F_CHARG = GS_ZPPT0001-CHARG    "2026.08.25 주석처리
*                        CHDAT   = GS_ZGTPPS1001-CHDAT
*                        CHTIM   = GS_ZGTPPS1001-CHTIM
*                        CHNAM   = GS_ZGTPPS1001-CHNAM
*                  WHERE ZASSIGN_NO   EQ GS_ZGTPPT2190-ZASSIGN_NO
*                    AND ZASSIGN_ITEM EQ GS_ZGTPPT2190-ZASSIGN_ITEM.

  "절단오더 실적 완료 점검
  SELECT ZCUT_ORD_NO, ZCUT_ORD_ITEM, ZCUT_MBLNR
    FROM ZGTPPT2190
   WHERE ZASSIGN_NO   EQ @GS_ZGTPPT2190-ZASSIGN_NO
*     AND ZASSIGN_ITEM EQ @GS_ZGTPPT2190-ZASSIGN_ITEM "2026.08.25 주석처리
     AND SOBKZ EQ 'E'
     AND LOEKZ NE 'X'
    INTO TABLE @DATA(LT_2190).

  LOOP AT LT_2190 INTO DATA(LS_2190).
    IF LS_2190-ZCUT_MBLNR IS INITIAL.
      DATA(LV_CHK) = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_CHK = 'X'.
    "절단 오더 실적 처리를 부분 또는 아직 완료하지 않은 경우
    PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = TEXT-S13.
  ELSE.
    "주문할당유형 추출
    SELECT SINGLE ZASSIGN_TYPE
      FROM ZGTPPT2170
     WHERE ZASSIGN_NO EQ @GS_ZGTPPT2190-ZASSIGN_NO
      INTO @DATA(LV_ZASSIGN_TYPE).

    IF LV_ZASSIGN_TYPE NE 'AD'.
      "절단 오더 실적 처리를 모두 완료한 경우
      UPDATE ZGTPPT2170 SET LOEKZ       = 'C'
                            STOCK_COMPL = 'Y'  "재고이관상태
                            CHDAT       = GS_ZGTPPS1001-CHDAT
                            CHTIM       = GS_ZGTPPS1001-CHTIM
                            CHNAM       = GS_ZGTPPS1001-CHNAM
                      WHERE ZASSIGN_NO EQ GS_ZGTPPT2190-ZASSIGN_NO.

      IF SY-SUBRC IS INITIAL.
        PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
        PS_RETURN-STAT_MSG = TEXT-S11.

* 실제 절단된 배치번호를 정조장의 계획 배치번호에 업데이트
        "절단실적 등록된 절단지시 배치번호(계획) 추출
        SELECT SINGLE ZT01~F_CHARG, ZT02~ZCUT_MBLNR, ZT02~ZCUT_MJAHR
          FROM ZGTPPT2180 AS ZT01
          JOIN ZGTPPT2190 AS ZT02 ON ZT01~ZASSIGN_NO   EQ ZT02~ZASSIGN_NO
                                 AND ZT01~ZASSIGN_ITEM EQ ZT02~ZASSIGN_ITEM
         WHERE ZT02~ZCUT_ORD_NO   EQ @GS_ZGTPPT2190-ZCUT_ORD_NO
           AND ZT02~ZCUT_ORD_ITEM EQ @GS_ZGTPPT2190-ZCUT_ORD_ITEM
          INTO @DATA(LS_F_CHARG).

        "정조장 존재여부 체크
        SELECT SINGLE *
          FROM ZGTPPT2180
         WHERE F_CHARG EQ @LS_F_CHARG-F_CHARG
           AND ZORD_TYPE EQ 'C0'
          INTO @DATA(LS_2180_C0).

        CHECK LS_2180_C0 IS NOT INITIAL.

        "실제 절단된 배치번호 추출
        SELECT SINGLE CHARG, BUDAT
          FROM MATDOC
         WHERE MBLNR EQ @LS_F_CHARG-ZCUT_MBLNR
           AND MJAHR EQ @LS_F_CHARG-ZCUT_MJAHR
           AND SHKZG EQ 'H'
          INTO @DATA(LS_MATDOC).

        CHECK LS_MATDOC IS NOT INITIAL.

        "절단된 배치번호를 정조장의 배치번호(계획) 필드에 업데이트
        UPDATE ZGTPPT2180 SET F_CHARG = @LS_MATDOC-CHARG
                        WHERE ZASSIGN_NO   EQ @LS_2180_C0-ZASSIGN_NO
                          AND ZASSIGN_ITEM EQ @LS_2180_C0-ZASSIGN_ITEM.

        CLEAR: LS_F_CHARG, LS_2180_C0, LS_MATDOC.

      ELSE.
        PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        PS_RETURN-STAT_MSG = TEXT-E06.
      ENDIF.

    ELSE.
      "절단 오더 실적 처리를 모두 완료한 경우
      UPDATE ZGTPPT2170 SET LOEKZ       = 'X'
                            STOCK_COMPL = 'Y'  "재고이관상태
                            CHDAT       = GS_ZGTPPS1001-CHDAT
                            CHTIM       = GS_ZGTPPS1001-CHTIM
                            CHNAM       = GS_ZGTPPS1001-CHNAM
                      WHERE ZASSIGN_NO EQ GS_ZGTPPT2190-ZASSIGN_NO.

      IF SY-SUBRC IS INITIAL.
        PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
        PS_RETURN-STAT_MSG = TEXT-S11.
      ELSE.
        PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        PS_RETURN-STAT_MSG = TEXT-E06.
      ENDIF.

      "절단오더 실적 완료 점검
      SELECT ZCUT_ORD_NO, ZCUT_ORD_ITEM, ZCUT_MBLNR
        FROM ZGTPPT2190
       WHERE WERKS EQ @GS_ZGTPPT2190-WERKS
         AND ZASSIGN_NO EQ @GS_ZGTPPT2190-ZASSIGN_NO
         AND ZASSIGN_ITEM EQ @GS_ZGTPPT2190-ZASSIGN_ITEM
         AND SOBKZ EQ 'E'
         AND LOEKZ NE 'X'
        INTO TABLE @DATA(LT_2190_AD).

      IF LT_2190_AD IS NOT INITIAL.
        SORT LT_2190_AD BY ZCUT_MBLNR.

        READ TABLE LT_2190_AD INTO DATA(LS_AD) WITH KEY ZCUT_MBLNR = SPACE.
        IF SY-SUBRC NE 0.
          UPDATE ZGTPPT2180 SET STOCK_COMPL = 'Y'  "재고이관상태
                                CHDAT       = GS_ZGTPPS1001-CHDAT
                                CHTIM       = GS_ZGTPPS1001-CHTIM
                                CHNAM       = GS_ZGTPPS1001-CHNAM
                          WHERE ZASSIGN_NO   EQ GS_ZGTPPT2190-ZASSIGN_NO
                            AND ZASSIGN_ITEM EQ GS_ZGTPPT2190-ZASSIGN_ITEM.
        ENDIF.
      ENDIF.

    ENDIF.

    CLEAR: LV_ZASSIGN_TYPE.
  ENDIF.

  CLEAR: LV_CHK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_alloc_for_upd_type_Z1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ALLOC_FOR_UPD_TYPE_Z1  USING PS_RETURN TYPE ZGTPPSIF0045.

  UPDATE ZGTPPT2170 SET LOEKZ       = ABAP_FALSE
                        STOCK_COMPL = ABAP_FALSE
                        CHDAT = GS_ZGTPPS1001-CHDAT
                        CHTIM = GS_ZGTPPS1001-CHTIM
                        CHNAM = GS_ZGTPPS1001-CHNAM
                  WHERE ZASSIGN_NO EQ GS_ZGTPPT2190-ZASSIGN_NO.

  UPDATE ZGTPPT2180 SET STOCK_COMPL = ABAP_FALSE
                        CHDAT = GS_ZGTPPS1001-CHDAT
                        CHTIM = GS_ZGTPPS1001-CHTIM
                        CHNAM = GS_ZGTPPS1001-CHNAM
                  WHERE ZASSIGN_NO EQ GS_ZGTPPT2190-ZASSIGN_NO
                    AND ZASSIGN_ITEM EQ GS_ZGTPPT2190-ZASSIGN_ITEM.

  IF SY-SUBRC IS INITIAL.
    PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = TEXT-S11.
  ELSE.
    PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = TEXT-E06.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_std_time_char_of_manuf_std
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_STD_TIME_CHAR_OF_MANUF_STD USING PV_WERKS PV_SPART PV_GONG_CD
                                          PT_ZPPT0030 TYPE TY_T_ZPPT0030.
  DATA LT_PROCD TYPE RANGE OF ZPPT0030-PROCD.

  IF PV_GONG_CD IS NOT INITIAL.
    LT_PROCD = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_GONG_CD ) ).
  ENDIF.

  WITH +ZPPT0107 AS ( SELECT WERKS, SPGCD, SPART
                        FROM ZPPT0107
                       WHERE WERKS EQ @PV_WERKS
                         AND SPART EQ @PV_SPART )

  SELECT DISTINCT ZT02~WERKS,  ZT01~SPART, ZT02~PROCD AS GONG_CD,
                   ZT02~SEQNO, ZT02~ATNAM AS ATNAM_JS,
                  ZT02~SNGLE, ZT02~MULTI, ZT02~INCLU, ZT02~RANGE
    FROM +ZPPT0107 AS ZT01
    JOIN ZPPT0030  AS ZT02
      ON ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~SPGCD EQ ZT02~SPGCD
   WHERE ZT02~PROCD IN @LT_PROCD
     AND ZT02~SPDFL EQ @ABAP_TRUE
   ORDER BY ZT02~WERKS, ZT01~SPART, ZT02~PROCD, ZT02~SEQNO, ZT02~ATNAM
    INTO TABLE @DATA(LT_ZPPT0030).

  PT_ZPPT0030 = CORRESPONDING #( LT_ZPPT0030 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calc_quot_routing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALC_QUOT_ROUTING  USING PT_CHAR TYPE TY_T_CHAR_DATA
                              PT_WORK TYPE TY_T_WORK_DATA.
  DATA LT_ZPPT0040 TYPE TY_T_ZPPT0040.
  DATA LT_ZPPT0041 TYPE TY_T_ZPPT0041.
  DATA LT_CRCO TYPE TY_T_CRCO.
  DATA LT_APPEND TYPE TY_T_CRCO.
  DATA LV_DCSEQ  TYPE ZGTPPS1007-DCSEQ.
  DATA LT_SEQNO_PREV TYPE RANGE OF ZPPT0040-SEQNO.
  DATA LT_SEQNO_CURR TYPE RANGE OF ZPPT0040-SEQNO.
  DATA LT_CHAR TYPE TY_T_CHAR_DATA.
  DATA LT_CHAR_WORK TYPE TABLE OF ZGTPPS1008.
  DATA LT_WORK TYPE TABLE OF ZGTPPS1008 WITH NON-UNIQUE SORTED KEY SKEY
                                                        COMPONENTS WERKS SPART GONG_SEQ GONG_CD MATNR ARBPL.

  WITH +ZPPT0107 AS ( SELECT DISTINCT ZT01~WERKS, ZT01~SPGCD, ZT01~SPART, ZT02~GONG_SEQ, ZT02~GONG_CD, ZT02~MATNR
                        FROM ZPPT0107 AS ZT01
                        JOIN @PT_CHAR AS ZT02
                          ON ZT01~WERKS EQ ZT02~WERKS
                         AND ZT01~SPART EQ ZT02~SPART )

  SELECT DISTINCT ZT02~WERKS, ZT01~SPART, ZT01~GONG_SEQ, ZT02~PROCD AS GONG_CD,
                  ZT02~SEQNO, ZT01~MATNR, ZT02~ATNAM
    FROM +ZPPT0107 AS ZT01
    JOIN ZPPT0030  AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~GONG_CD EQ ZT02~PROCD
   WHERE ZT02~SPDFL   EQ @ABAP_TRUE
   ORDER BY ZT02~WERKS, ZT01~SPART, ZT01~GONG_SEQ, ZT02~PROCD, ZT02~SEQNO, ZT01~MATNR, ZT02~ATNAM
    INTO TABLE @DATA(LT_ZPPT0030).

  LT_CHAR = PT_CHAR.
  CLEAR PT_CHAR.

  LOOP AT LT_ZPPT0030 INTO DATA(LS_ZPPT0030).
    APPEND INITIAL LINE TO PT_CHAR REFERENCE INTO DATA(LR_DATA).

    READ TABLE LT_CHAR INTO DATA(LS_DATA) WITH KEY WERKS    = LS_ZPPT0030-WERKS
                                                   SPART    = LS_ZPPT0030-SPART
                                                   GONG_SEQ = LS_ZPPT0030-GONG_SEQ
                                                   GONG_CD  = LS_ZPPT0030-GONG_CD
                                                   MATNR    = LS_ZPPT0030-MATNR
                                                   ATNAM    = LS_ZPPT0030-ATNAM.
    IF SY-SUBRC IS NOT INITIAL.
      LR_DATA->* = CORRESPONDING #( LS_ZPPT0030 ).
      LR_DATA->ATWRT = '!'.
    ELSE.
      LR_DATA->* = CORRESPONDING #( LS_DATA ).
    ENDIF.

    CLEAR LS_DATA.
  ENDLOOP.

  CLEAR PT_WORK.

  PERFORM GET_MANUF_STANDARD USING PT_CHAR LT_ZPPT0040 LT_ZPPT0041 LT_CRCO.

  LOOP AT PT_CHAR INTO DATA(LS_KEY)
                  GROUP BY ( WERKS    = LS_KEY-WERKS
                             SPART    = LS_KEY-SPART
                             GONG_SEQ = LS_KEY-GONG_SEQ
                             GONG_CD  = LS_KEY-GONG_CD
                             MATNR    = LS_KEY-MATNR )
                  INTO DATA(LT_GROUP).

    CLEAR LT_SEQNO_PREV.

*// 특성.
    LOOP AT GROUP LT_GROUP REFERENCE INTO DATA(LR_CHAR).
      DATA(LS_CHAR) = LR_CHAR->*.

      CLEAR: LT_CHAR_WORK, LT_APPEND.
      LV_DCSEQ = 9.

*// 특성/SEQ.
      LOOP AT LT_ZPPT0040  INTO DATA(LS_ZPPT0040)
                          WHERE WERKS EQ LS_CHAR-WERKS
                            AND SPART EQ LS_CHAR-SPART
                            AND PROCD EQ LS_CHAR-GONG_CD
                            AND ATNAM EQ LS_CHAR-ATNAM
                            AND SEQNO IN LT_SEQNO_PREV.
        PERFORM MATCHING_CHAR_VALUE USING LS_CHAR LS_ZPPT0040.

        IF LS_CHAR-ATWRT_JS IS NOT INITIAL.
          IF LS_CHAR-DCSEQ <= LV_DCSEQ.
            LV_DCSEQ = LS_CHAR-DCSEQ.
          ELSE.
            CONTINUE.
          ENDIF.

          IF NOT LINE_EXISTS( LT_SEQNO_CURR[ LOW = LS_ZPPT0040-SEQNO ] ).
            APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_ZPPT0040-SEQNO ) TO LT_SEQNO_CURR.
          ENDIF.

          READ TABLE LT_ZPPT0041 INTO DATA(LS_ZPPT0041) WITH KEY WERKS = LS_ZPPT0040-WERKS
                                                                 SPGCD = LS_ZPPT0040-SPGCD
                                                                 PROCD = LS_ZPPT0040-PROCD
                                                                 SEQNO = LS_ZPPT0040-SEQNO
                                                                 ARBPL = LS_ZPPT0040-ARBPL BINARY SEARCH.
          IF SY-SUBRC IS INITIAL.
            LR_CHAR->ATWRT_JS = LS_CHAR-ATWRT_JS.
            LR_CHAR->DCSEQ    = LS_CHAR-DCSEQ.

            READ TABLE LT_APPEND TRANSPORTING NO FIELDS WITH TABLE KEY SKEY COMPONENTS WERKS = LS_ZPPT0041-WERKS
                                                                                       SEQNO = LS_ZPPT0041-SEQNO
                                                                                       ARBPL = LS_ZPPT0041-ARBPL.
            IF SY-SUBRC IS NOT INITIAL.
              APPEND INITIAL LINE TO LT_APPEND REFERENCE INTO DATA(LR_APPEND).
              LR_APPEND->WERKS = LS_ZPPT0041-WERKS.
              LR_APPEND->SEQNO = LS_ZPPT0041-SEQNO.
              LR_APPEND->ARBPL = LS_ZPPT0041-ARBPL.

              LOOP AT LT_CRCO  INTO DATA(LS_CRCO)
                              USING KEY SKEY
                              WHERE WERKS EQ LS_ZPPT0041-WERKS
                                AND SEQNO EQ LS_ZPPT0041-SEQNO
                                AND ARBPL EQ LS_ZPPT0041-ARBPL.
                APPEND INITIAL LINE TO LT_CHAR_WORK REFERENCE INTO DATA(LR_WORK).
                LR_WORK->* = CORRESPONDING #( LS_ZPPT0041 MAPPING GONG_CD = PROCD
                                                                  BMSCH   = BASMN
                                                                  MEINH   = MEINS ).
                LR_WORK->* = VALUE #( BASE LR_WORK->*  GONG_SEQ = LS_CHAR-GONG_SEQ
                                                       MATNR    = LS_CHAR-MATNR
                                                       LSTAR    = LS_CRCO-LSTAR
                                                       VGWRT    = COND #( WHEN LS_CRCO-FORML EQ 'SAP007' THEN LS_ZPPT0041-WKTIM
                                                                          WHEN LS_CRCO-FORML EQ 'ZLS001'
                                                                            OR LS_CRCO-FORML EQ 'SAP001' THEN LS_ZPPT0041-RUEZT
                                                                                                         ELSE LS_ZPPT0041-OPTIM )
                                                       VGWRTEH  = LS_ZPPT0041-MEINH ).
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LT_SEQNO_PREV = LT_SEQNO_CURR.
      CLEAR LT_SEQNO_CURR.

      IF LT_CHAR_WORK IS INITIAL.
        EXIT.
      ELSE.
        LT_WORK = LT_CHAR_WORK.
      ENDIF.
    ENDLOOP.

    IF LT_WORK IS INITIAL.
      EXIT.
    ENDIF.

    APPEND LINES OF LT_WORK TO PT_WORK.
    CLEAR LT_WORK.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_manuf_standard
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MANUF_STANDARD  USING PT_CHAR TYPE TY_T_CHAR_DATA
                               PT_ZPPT0040 TYPE TY_T_ZPPT0040
                               PT_ZPPT0041 TYPE TY_T_ZPPT0041
                               PT_CRCO TYPE TY_T_CRCO.

  CHECK PT_CHAR IS NOT INITIAL.

  SELECT ZT03~WERKS, ZT01~SPART, ZT03~PROCD, ZT03~ATNAM, ZT03~SEQNO,
         ZT03~ARBPL, ZT03~ATWRT, ZT03~SPGCD
    FROM @PT_CHAR AS ZT01
    JOIN ZPPT0107 AS ZT02
      ON ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~SPART EQ ZT02~SPART
    JOIN ZPPT0040 AS ZT03
      ON ZT02~WERKS   EQ ZT03~WERKS
     AND ZT02~SPGCD   EQ ZT03~SPGCD
     AND ZT01~GONG_CD EQ ZT03~PROCD
     AND ZT01~ATNAM   EQ ZT03~ATNAM
   ORDER BY ZT03~WERKS, ZT01~SPART, ZT03~PROCD, ZT03~ATNAM, ZT03~SEQNO
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZPPT0040.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~PROCD, ZT02~SEQNO, ZT02~ARBPL,
         ZT02~BASMN, ZT02~MEINS, ZT02~RUEZT, ZT02~ZFLUX, ZT02~OPTIM,
         ZT02~RDRNP, ZT02~WKTIM, ZT02~MEINH, ZT01~SPART
    FROM @PT_ZPPT0040 AS ZT01
    JOIN ZPPT0041 AS ZT02
      ON ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~SPGCD EQ ZT02~SPGCD
     AND ZT01~PROCD EQ ZT02~PROCD
     AND ZT01~SEQNO EQ ZT02~SEQNO
     AND ZT01~ARBPL EQ ZT02~ARBPL
   ORDER BY ZT02~WERKS, ZT01~SPGCD, ZT02~PROCD, ZT02~SEQNO, ZT02~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZPPT0041.

  SELECT DISTINCT CRHD~WERKS, CRHD~ARBPL, ZT01~SEQNO, CRCO~LSTAR, CRCO~FORML
    FROM @PT_ZPPT0041 AS ZT01
    JOIN CRHD
      ON ZT01~WERKS EQ CRHD~WERKS
     AND ZT01~ARBPL EQ CRHD~ARBPL
     AND CRHD~OBJTY EQ @ZGTPP_IF_CONST=>GC_OBJTY
    JOIN CRCO
      ON CRHD~OBJTY EQ CRCO~OBJTY
     AND CRHD~OBJID EQ CRCO~OBJID
   ORDER BY CRHD~WERKS, ZT01~SEQNO, CRHD~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE @PT_CRCO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form matching_char_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MATCHING_CHAR_VALUE  USING PS_CHAR     TYPE ZGTPPS1007
                                PS_ZPPT0040 TYPE TY_S_ZPPT0040.

  CLEAR: PS_CHAR-ATWRT_JS, PS_CHAR-DCSEQ.

  IF NOT CONTAINS( VAL = PS_ZPPT0040-ATWRT REGEX = '[~,*]' ). "// ~,* 포함여부
    PS_CHAR-ATWRT_JS = COND #( WHEN PS_CHAR-ATWRT EQ PS_ZPPT0040-ATWRT THEN PS_CHAR-ATWRT ).
    PS_CHAR-DCSEQ    = COND #( WHEN PS_CHAR-ATWRT_JS IS NOT INITIAL THEN 1 ).
  ELSE.
    IF CONTAINS( VAL = PS_ZPPT0040-ATWRT REGEX = '[,]' ).    "// ,로 구분.
      SPLIT PS_ZPPT0040-ATWRT AT ',' INTO TABLE DATA(LT_ATWRT).
      READ TABLE LT_ATWRT TRANSPORTING NO FIELDS WITH KEY TABLE_LINE = PS_CHAR-ATWRT.
      IF SY-SUBRC IS INITIAL.
        PS_CHAR-ATWRT_JS = PS_CHAR-ATWRT.
        PS_CHAR-DCSEQ    = 2.
        RETURN.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

    IF CONTAINS( VAL = PS_ZPPT0040-ATWRT REGEX = '[*]' ).
      IF CONTAINS( VAL = PS_ZPPT0040-ATWRT REGEX = PS_CHAR-ATWRT ).
        PS_CHAR-ATWRT_JS = PS_CHAR-ATWRT.
        PS_CHAR-DCSEQ    = 3.
        RETURN.
      ENDIF.
    ENDIF.

    IF CONTAINS( VAL = PS_ZPPT0040-ATWRT REGEX = '[~]' ).
      IF PS_ZPPT0040-ATWRT NE '~'.
        SPLIT PS_ZPPT0040-ATWRT AT '~' INTO TABLE LT_ATWRT.
        IF LINES( LT_ATWRT ) EQ 2.
          IF PS_CHAR-ATWRT BETWEEN LT_ATWRT[ 1 ] AND LT_ATWRT[ 2 ].
            PS_CHAR-ATWRT_JS = PS_ZPPT0040-ATWRT.
            PS_CHAR-DCSEQ = 4.
          ENDIF.
        ENDIF.
      ELSE.
        PS_CHAR-ATWRT_JS = PS_ZPPT0040-ATWRT.
        PS_CHAR-DCSEQ    = 5.
      ENDIF.
      RETURN.
    ENDIF.

    IF PS_ZPPT0040-ATWRT > PS_CHAR-ATWRT.
      PS_CHAR-ATWRT_JS = PS_ZPPT0040-ATWRT.
      PS_CHAR-DCSEQ    = 6.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_import_para_link_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_IMPORT_PARA_LINK_INFO  USING PV_WERKS PV_UPD_TYPE PV_UPDRQ.

  GS_LINK_IMPORT = VALUE #( WERKS    = PV_WERKS
                            UPD_TYPE = PV_UPD_TYPE
                            UPDRQ    = PV_UPDRQ ).

  PERFORM GET_DATE_TIME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zt3360_for_upd_type_z2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZT3360_FOR_UPD_TYPE_Z2  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                          PS_ITEM    TYPE ZGTPPSIF0044
                                          PS_RETURN  TYPE ZGTPPSIF0045.

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' PS_RETURN-UPDRQ.
  ELSE.
    PS_RETURN-UPDRQ = GS_LINK_IMPORT-UPDRQ.
  ENDIF.

  DATA(LS_ZGTPPT3360) = VALUE ZGTPPT3360( UPDRQ    = PS_RETURN-UPDRQ
                                          UPD_TYPE = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z2
                                          LOEKZ    = SPACE
                                          WERKS    = GS_LINK_IMPORT-WERKS
                                          TAGNR    = PS_ITEM-TAGNR
                                          VBELN    = PS_ITEM-VBELN
                                          POSNR    = PS_ITEM-POSNR
                                          TR_STAT  = PS_RETURN-TR_STAT
                                          AL_STAT  = PS_RETURN-AL_STAT
                                          STAT_MSG = PS_RETURN-STAT_MSG
                                          CHK_STAT = PS_RETURN-CHK_STAT
                                          CHK_MSG  = PS_RETURN-CHK_MSG ).

  IF GS_LINK_IMPORT-UPDRQ IS INITIAL.
    LS_ZGTPPT3360 = CORRESPONDING #( BASE ( LS_ZGTPPT3360 ) GS_ZGTPPS1001 ).
  ELSE.
    LS_ZGTPPT3360 = VALUE #( BASE LS_ZGTPPT3360 CRDAT = GS_ZGTPPT3360-CRDAT
                                                CRTIM = GS_ZGTPPT3360-CRTIM
                                                CRNAM = GS_ZGTPPT3360-CRNAM
                                                CHDAT = GS_ZGTPPS1001-CHDAT
                                                CHTIM = GS_ZGTPPS1001-CHTIM
                                                CHNAM = GS_ZGTPPS1001-CHNAM ).
  ENDIF.

  MODIFY ZGTPPT3360 FROM LS_ZGTPPT3360.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_check_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_CHECK_RESULT TABLES PT_RETURN STRUCTURE ZGTPPSIF0045.

  DATA(LS_RETURN) = VALUE #( PT_RETURN[ 1 ] OPTIONAL ).

  UPDATE ZGTPPT3360 SET CHK_STAT = LS_RETURN-CHK_STAT
                        CHK_MSG  = LS_RETURN-CHK_MSG
                        CHDAT    = GS_ZGTPPS1001-CHDAT
                        CHTIM    = GS_ZGTPPS1001-CHTIM
                        CHNAM    = GS_ZGTPPS1001-CHNAM
                  WHERE UPDRQ EQ GS_LINK_IMPORT-UPDRQ.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_bdc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_BDC_DATA  USING PS_HEADER TYPE ZGTPPS1012
                           PS_ITEM   TYPE ZGTPPS1010.

  DATA LV_MENGE TYPE CHAR18.
  DATA LV_ERFMG TYPE CHAR18.

  SELECT SINGLE CLABS
    INTO @DATA(LV_CLABS)
    FROM MCHB
   WHERE MATNR EQ @PS_HEADER-MATNR
     AND WERKS EQ @PS_HEADER-WERKS
     AND LGORT EQ @PS_HEADER-LGORT
     AND CHARG EQ @PS_HEADER-CHARG.

  WRITE PS_ITEM-ZCUT_LEN UNIT PS_HEADER-MEINS TO LV_MENGE LEFT-JUSTIFIED.
  WRITE LV_CLABS         UNIT PS_HEADER-MEINS TO LV_ERFMG LEFT-JUSTIFIED.

  GT_BDCDATA = VALUE #( ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = 'CUT_OK_DETAIL_CLOSE' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_GO' )
                        ( DYNBEGIN = ' '  FNAM    = 'GOHEAD-MUEBS'           FVAL   = 'MM_001' )
                        ( DYNBEGIN = ' '  FNAM    = 'GOHEAD-BUDAT'           FVAL   = |{ PS_HEADER-BUDAT DATE = USER }| )
                        ( DYNBEGIN = ' '  FNAM    = 'GOHEAD-MTSNR'           FVAL   = 'MILL_CUT' )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-MAKTX'  FVAL   = PS_HEADER-MATNR )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-NAME1'  FVAL   = PS_HEADER-WERKS )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-LGOBE'  FVAL   = PS_HEADER-LGORT )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-CHARG'  FVAL   = PS_HEADER-CHARG )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-ERFMG'  FVAL   = LV_ERFMG )
                        ( DYNBEGIN = ' '  FNAM    = 'MILL_ISSUE_ITEM-ERFME'  FVAL   = PS_HEADER-MEINS )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_GO' )
                        ( DYNBEGIN = ' '  FNAM    = 'GOITEM-ERFMG(01)'       FVAL   = LV_MENGE )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_GO' )
                        ( DYNBEGIN = ' '  FNAM    = 'GOITEM-MAKTX(01)'       FVAL   = PS_HEADER-MATNR )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_GO' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_GO' )
                        ( DYNBEGIN = ' '  FNAM    = 'GOITEM-CHARG(01)'       FVAL   = PS_ITEM-T_CHARG )
                        ( DYNBEGIN = ' '  FNAM    = 'GOITEM-XPCBT(01)'       FVAL   = 'X' )
                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=OK_POST' )
                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLMILL_CUT'           DYNPRO = '0001' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/EOK_END' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_result_bdc_mill_cut
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_RESULT_BDC_MILL_CUT  USING PS_HEADER TYPE ZGTPPS1012
                                    PS_ITEM   TYPE ZGTPPS1010
                                    PS_RETURN TYPE ZGTPPS1011
                           RAISING LCX_EXCEPTION.

  DATA LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.

  DATA(LS_OPTION) = VALUE CTU_PARAMS( DISMODE = 'N'
                                      UPDMODE = 'S' ).

  CALL TRANSACTION 'MILL_CUT' USING GT_BDCDATA OPTIONS  FROM LS_OPTION
                                               MESSAGES INTO LT_MESSTAB.

  READ TABLE LT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = 'S'
                                                       MSGID  = 'MIGO'
                                                       MSGNR  = '012'.
  DATA(LV_SUBRC) = SY-SUBRC.

  PS_RETURN = VALUE #( ZCUT_ORD_NO   = PS_ITEM-ZCUT_ORD_NO
                       ZCUT_ORD_ITEM = PS_ITEM-ZCUT_ORD_ITEM
                       ZCUT_MBLNR    = COND #( WHEN LV_SUBRC IS INITIAL THEN LS_MESSTAB-MSGV1 )
                       ZCUT_MJAHR    = COND #( WHEN LV_SUBRC IS INITIAL THEN PS_HEADER-BUDAT+0(4) )
                       ZERP_STAT     = COND #( WHEN LV_SUBRC IS INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                               ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                       ZERP_MESSAGE  = COND #( WHEN LV_SUBRC IS INITIAL THEN TEXT-S01
                                               ELSE TEXT-E16 ) ).

  CHECK LV_SUBRC IS NOT INITIAL.

  RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_RETURN-ZERP_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form transfer_posting_upd_type_u3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM TRANSFER_POSTING_UPD_TYPE_U3  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                         PS_ITEM    TYPE ZGTPPSIF0044
                                         PS_RETURN  TYPE ZGTPPSIF0045.

  DATA LT_RETURN TYPE TABLE OF BAPIRET2.

  READ TABLE GT_MSKA INTO DATA(LS_MSKA) WITH KEY MATNR = GS_ZPPT0001-MATNR
                                                 WERKS = GS_ZPPT0001-WERKS
*                                                 LGORT = GS_ZPPT0001-LGORT
                                                 CHARG = GS_ZPPT0001-CHARG BINARY SEARCH.

  DATA(LT_ITEM) = VALUE GM_ITEMS_T( ( MATERIAL       = CONV MATNR18( GS_ZPPT0001-MATNR )
                                      PLANT          = LS_MSKA-WERKS
                                      STGE_LOC       = LS_MSKA-LGORT
                                      BATCH          = LS_MSKA-CHARG
                                      VAL_SALES_ORD  = LS_MSKA-VBELN
                                      VAL_S_ORD_ITEM = LS_MSKA-POSNR
                                      MOVE_TYPE      = '413'
                                      SPEC_STOCK     = SPACE
                                      MOVE_MAT       = CONV MATNR18( GS_ZPPT0001-MATNR )
                                      MOVE_PLANT     = LS_MSKA-WERKS
                                      MOVE_STLOC     = LS_MSKA-LGORT
                                      MOVE_BATCH     = LS_MSKA-CHARG
                                      STCK_TYPE      = SPACE
                                      ENTRY_UOM      = GS_ZPPT0001-MEINS
                                      ENTRY_QNT      = LS_MSKA-KALAB
                                      SALES_ORD      = PS_ITEM-VBELN
                                      S_ORD_ITEM     = PS_ITEM-POSNR  ) ).

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_ITEM-BUDAT
                                                    HEADER_TXT = ZGTPP_IF_CONST=>GC_UPD_TYPE-U2 )
      GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
    IMPORTING
      GOODSMVT_HEADRET = PS_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF PS_HEADRET IS NOT INITIAL.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = TEXT-S12.
  ELSE.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_upd_type_z3_import_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_UPD_TYPE_Z3_IMPORT_VALUE  USING PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045
                                   RAISING LCX_EXCEPTION.

*// 실물 스캔 Lot로 배치번호 발췌.
  PERFORM SELECT_ZPPT0001 USING GS_LINK_IMPORT-WERKS PS_ITEM-TAGNR.

  IF GS_ZPPT0001 IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E10.
  ENDIF.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF @GS_ZGTPPT3360_U3
    FROM ZGTPPT3360
   WHERE UPD_TYPE EQ @ZGTPP_IF_CONST=>GC_UPD_TYPE-U3
     AND TAGNR    EQ @PS_ITEM-TAGNR
     AND VBELN    EQ @PS_ITEM-VBELN
     AND POSNR    EQ @PS_ITEM-POSNR
     AND LOEKZ    NE 'X'.

  IF GS_ZGTPPT3360 IS INITIAL.
    IF GS_ZGTPPT3360_U3-TR_MBLNR IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E15.
    ENDIF.
  ELSE.
    IF GS_ZGTPPT3360_U3-TR_MBLNR IS INITIAL OR GS_ZGTPPT3360-TR_MBLNR IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E15.
    ENDIF.
  ENDIF.

  APPEND GS_ZPPT0001 TO GT_ZPPT0001.
  APPEND GS_ZGTPPT3360_U3 TO GT_ZGTPPT3360_U3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form goodsmvt_cancel_upd_type_z3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GOODSMVT_CANCEL_UPD_TYPE_Z3  USING PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                        PS_ITEM    TYPE ZGTPPSIF0044
                                        PS_RETURN  TYPE ZGTPPSIF0045.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.

  CLEAR: GS_ZGTPPT3360_U3.
  READ TABLE GT_ZGTPPT3360_U3 INTO GS_ZGTPPT3360_U3 WITH KEY DLVRQ = PS_ITEM-TAGNR
                                                             VBELN = PS_ITEM-VBELN
                                                             POSNR = PS_ITEM-POSNR.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_ZGTPPT3360_U3-TR_MBLNR
      MATDOCUMENTYEAR     = GS_ZGTPPT3360_U3-TR_MJAHR
      GOODSMVT_PSTNG_DATE = PS_ITEM-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = PS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF PS_HEADRET IS NOT INITIAL.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'S' ]-MESSAGE OPTIONAL ).

    UPDATE ZGTPPT3360
       SET LOEKZ = ABAP_TRUE
           CHDAT = GS_ZGTPPS1001-CHDAT
           CHTIM = GS_ZGTPPS1001-CHTIM
           CHNAM = GS_ZGTPPS1001-CHNAM
     WHERE UPDRQ EQ GS_ZGTPPT3360_U3-UPDRQ.

*    SELECT SINGLE ZT01~ZASSIGN_NO
*     INTO @DATA(LV_ZASSIGN_NO)
*     FROM ZGTPPT2170 AS ZT01
*     JOIN ZGTPPT2180 AS ZT02
*       ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
*    WHERE ZT01~VBELN   EQ @PS_ITEM-VBELN
*      AND ZT01~POSNR   EQ @PS_ITEM-POSNR
*      AND ZT02~F_CHARG EQ @GS_ZPPT0001-CHARG
*      AND ZT01~LOEKZ   EQ @SPACE.
*
*    UPDATE ZGTPPT2170
*       SET LOEKZ = ABAP_TRUE
*           CHDAT = GS_ZGTPPS1001-CHDAT
*           CHTIM = GS_ZGTPPS1001-CHTIM
*           CHNAM = GS_ZGTPPS1001-CHNAM
*     WHERE ZASSIGN_NO EQ LV_ZASSIGN_NO.
  ELSE.
    PS_RETURN-TR_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
  ENDIF.

  PS_RETURN-UPDRQ = GS_ZGTPPT3360_U3-UPDRQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mill_cut_bdc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MILL_CUT_BDC  USING PS_HEADER TYPE ZGTPPS1012
                         PS_ITEM   TYPE ZGTPPS1010
                         PS_RETURN TYPE ZGTPPS1011
                 RAISING LCX_EXCEPTION.

  PERFORM BUILD_BDC_DATA USING PS_HEADER PS_ITEM.

  PERFORM GET_RESULT_BDC_MILL_CUT USING PS_HEADER PS_ITEM PS_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form material_transfer_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MATERIAL_TRANSFER_POSTING   USING PS_HEADER TYPE ZGTPPS1012
                                       PS_ITEM   TYPE ZGTPPS1010
                                       PS_RETURN TYPE ZGTPPS1011
                               RAISING LCX_EXCEPTION.

  READ TABLE GT_CUT_ORDER INTO DATA(LS_CUT_ORDER) WITH KEY ZCUT_ORD_NO   = PS_ITEM-ZCUT_ORD_NO
                                                           ZCUT_ORD_ITEM = PS_ITEM-ZCUT_ORD_ITEM BINARY SEARCH.

  IF LS_CUT_ORDER-SOBKZ EQ 'E' AND LS_CUT_ORDER-ZASSIGN_TYPE NE 'AD'.
    DATA(LT_ITEM) = VALUE GM_ITEMS_T( ( MATERIAL   = CONV MATNR18( PS_HEADER-MATNR )
                                        PLANT      = PS_HEADER-WERKS
                                        STGE_LOC   = '3410'    "PS_HEADER-LGORT
                                        BATCH      = PS_ITEM-T_CHARG
                                        MOVE_TYPE  = '413'
                                        MOVE_MAT   = CONV MATNR18( PS_HEADER-MATNR )
                                        MOVE_PLANT = PS_HEADER-WERKS
                                        MOVE_STLOC = '3410'     "PS_HEADER-LGORT
                                        MOVE_BATCH = PS_ITEM-T_CHARG
                                        ENTRY_UOM  = PS_HEADER-MEINS
                                        ENTRY_QNT  = PS_ITEM-ZCUT_LEN
                                        SALES_ORD  = LS_CUT_ORDER-VBELN
                                        S_ORD_ITEM = LS_CUT_ORDER-POSNR ) ).

    DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
    DATA LT_RETURN  TYPE TABLE OF BAPIRET2.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_HEADER-BUDAT
                                                      HEADER_TXT = PS_ITEM-ZCUT_ORD_NO )
        GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    PS_RETURN = VALUE #( BASE PS_RETURN  ZTR_MBLNR    = LS_HEADRET-MAT_DOC
                                         ZTR_MJAHR    = LS_HEADRET-DOC_YEAR
                                         ZERP_STAT    = COND #( WHEN PS_RETURN-ZTR_MBLNR IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                                ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                                         ZERP_MESSAGE = COND #( WHEN PS_RETURN-ZTR_MBLNR IS NOT INITIAL THEN TEXT-S01
                                                                ELSE TEXT-E17 ) ).

    IF LS_HEADRET IS NOT INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_RETURN-ZERP_MESSAGE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form initial_setup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIAL_SETUP  USING PS_HEADER TYPE ZGTPPS1012.

  CLEAR GT_CUT_ORDER.

*// 절달작업지시.
  SELECT ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM, ZT01~SOBKZ,
         ZT02~VBELN, ZT02~POSNR, ZT02~ZASSIGN_TYPE
    INTO CORRESPONDING FIELDS OF TABLE @GT_CUT_ORDER
    FROM ZGTPPT2190      AS ZT01
    LEFT JOIN ZGTPPT2170 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~ZCUT_ORD_NO EQ @PS_HEADER-ZCUT_ORD_NO
   ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mill_cut
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MILL_CUT  USING PS_HEADER TYPE ZGTPPS1012
                     PS_ITEM   TYPE ZGTPPS1010
                     PS_RETURN TYPE ZGTPPS1011
             RAISING LCX_EXCEPTION.

  DATA(LS_IMKPF) = VALUE IMKPF( BLDAT    = PS_HEADER-BUDAT
                                BUDAT    = PS_HEADER-BUDAT
                                PR_PRINT = '2'
                                XCOMPL   =  ABAP_TRUE ).

  DATA(LT_IMSEG) = VALUE TY_T_IMSEG( ( BWART  = '903'
                                       XNOCON = ABAP_TRUE
                                       XMENGE = ABAP_TRUE
                                       MATNR  = PS_HEADER-MATNR
                                       WERKS  = PS_HEADER-WERKS
                                       LGORT  = PS_HEADER-LGORT
                                       CHARG  = PS_HEADER-CHARG     "절단 전 배치
                                       ERFMG  = PS_ITEM-ZCUT_LEN
                                       ERFME  = PS_HEADER-MEINS
                                       MENGE  = PS_ITEM-ZCUT_LEN
                                       MEINS  = PS_HEADER-MEINS
                                       UMMAT  = PS_HEADER-MATNR
                                       UMWRK  = PS_HEADER-WERKS
                                       UMLGO  = '3410'   "PS_HEADER-LGORT
                                       UMCHA  = PS_ITEM-T_CHARG  ) ).    "절단 후 배치

  DATA LS_EMKPF TYPE EMKPF.
  DATA LT_EMSEG TYPE TABLE OF EMSEG.

  CALL FUNCTION 'MB_CREATE_GOODS_MOVEMENT'
    EXPORTING
      CTCOD = 'MILL_CUT'
      IMKPF = LS_IMKPF
      XALLP = ABAP_TRUE
      XALLB = ABAP_TRUE
      XALLR = ABAP_TRUE
    IMPORTING
      EMKPF = LS_EMKPF
    TABLES
      EMSEG = LT_EMSEG
      IMSEG = LT_IMSEG.

  IF LS_EMKPF-SUBRC EQ 1.
    CALL FUNCTION 'MB_POST_GOODS_MOVEMENT'.
    COMMIT WORK AND WAIT.
  ENDIF.

  PS_RETURN = VALUE #( ZCUT_ORD_NO   = PS_ITEM-ZCUT_ORD_NO
                       ZCUT_ORD_ITEM = PS_ITEM-ZCUT_ORD_ITEM
                       ZCUT_MBLNR    = COND #( WHEN LS_EMKPF-SUBRC EQ 1 THEN LS_EMKPF-MBLNR )
                       ZCUT_MJAHR    = COND #( WHEN LS_EMKPF-SUBRC EQ 1 THEN LS_EMKPF-MJAHR )
                       ZERP_STAT     = COND #( WHEN LS_EMKPF-SUBRC EQ 1 THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                               ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                       ZERP_MESSAGE  = COND #( WHEN LS_EMKPF-SUBRC EQ 1 THEN TEXT-S01
                                               ELSE TEXT-E16 ) ).

  CHECK LS_EMKPF-SUBRC NE 1.

  RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_RETURN-ZERP_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_batch_attr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_BATCH_ATTR  USING PS_LINK_STOCK TYPE ZGTPPS1006
                               PV_CLASS.
  DATA LT_ALLOCVALUESNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM.
  DATA LT_ALLOCVALUESCHAR	TYPE TABLE OF	BAPI1003_ALLOC_VALUES_CHAR.
  DATA LT_ALLOCVALUESCURR	TYPE TABLE OF	BAPI1003_ALLOC_VALUES_CURR.
  DATA LT_RETURN          TYPE TABLE OF BAPIRET2.
  DATA LV_VALUE TYPE CHA_CLASS_VIEW-SOLLWERT .

  CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
    EXPORTING
      OBJECTKEY       = CONV OBJNUM( PS_LINK_STOCK-MATNR && PS_LINK_STOCK-CHARG )
      OBJECTTABLE     = 'MCH1'
      CLASSNUM        = PV_CLASS
      CLASSTYPE       = '023'
    TABLES
      ALLOCVALUESNUM  = LT_ALLOCVALUESNUM
      ALLOCVALUESCHAR = LT_ALLOCVALUESCHAR
      ALLOCVALUESCURR = LT_ALLOCVALUESCURR
      RETURN          = LT_RETURN.

  DATA(LS_ALLOCVALUESNUM) = VALUE #( LT_ALLOCVALUESNUM[ CHARACT = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ] OPTIONAL ).

  CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
    EXPORTING
      I_NUMBER_OF_DIGITS = 10
      I_FLTP_VALUE       = LS_ALLOCVALUESNUM-VALUE_FROM
    IMPORTING
      E_CHAR_FIELD       = LV_VALUE.

  PS_LINK_STOCK-WELENG = LV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_overview_from_zassignMNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_OVERVIEW_FROM_ZASSIGNMNT TABLES PT_ITEM           STRUCTURE ZGTPPS1015
                                         PT_STAT_OVERVIEW  STRUCTURE ZGTPPS1013
                                         PT_STAT_DETAIL    STRUCTURE ZGTPPS1014.

  DATA LV_LINES TYPE I.
  DATA LV_CNT   TYPE I.
  DATA LV_SEQ   TYPE ZGTPPS1014-SEQUANCE.
  DATA: BEGIN OF LS_WEMNG,
          VBELN TYPE VBELN,
          POSNR TYPE POSNR,
          WEMNG TYPE MENGE_D,
        END OF LS_WEMNG.
  DATA: LT_WEMNG LIKE TABLE OF LS_WEMNG.

  SELECT ZT01~VBELN, ZT01~POSNR, ZT01~WERKS, ZT01~WELENG,
         ZT01~ZASSIGN_NO,  ZT02~ZASSIGN_ITEM, ZT02~ZORD_TYPE,
         ZT02~F_CHARG, ZT02~ZCUT_CNT,
         ZT03~ZCUT_ORD_NO, ZT03~ZCUT_ORD_ITEM, ZT03~ZCUT_MBLNR, ZT03~ZCUT_MJAHR,
         ZT03~CRDAT, ZT03~ZCUT_LEN
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    LEFT JOIN ZGTPPT2190 AS ZT03
      ON ZT02~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
     AND ZT02~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM
     AND ZT03~LOEKZ        EQ @SPACE
     AND ZT03~SOBKZ        NE @SPACE
     FOR ALL ENTRIES IN @PT_ITEM
   WHERE ZT01~LOEKZ        NE 'X'
     AND ZT01~VBELN        EQ @PT_ITEM-VBELN
     AND ZT01~POSNR        EQ @PT_ITEM-POSNR
     AND ZT01~ZASSIGN_TYPE NE 'PC'
     AND ZT02~ZORD_TYPE    NE @ZGTPP_IF_CONST=>GC_ZORD_TYPE-C9   "// 재고 비활성 건 제외.
    INTO TABLE @DATA(LT_ASSIGN).

  CLEAR: LT_WEMNG.
  SORT LT_ASSIGN BY VBELN POSNR ZASSIGN_NO ZASSIGN_ITEM ZCUT_ORD_NO ZCUT_ORD_ITEM.

  LOOP AT LT_ASSIGN  INTO DATA(LS_KEY)
                    GROUP BY ( VBELN        = LS_KEY-VBELN
                               POSNR        = LS_KEY-POSNR
                               ZASSIGN_NO   = LS_KEY-ZASSIGN_NO
                               ZASSIGN_ITEM = LS_KEY-ZASSIGN_ITEM
                               ZORD_TYPE    = LS_KEY-ZORD_TYPE )
                    INTO DATA(LT_GROUP).

    IF LT_GROUP-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C1. "// 절단.

      CLEAR: LV_LINES, LV_CNT, LV_SEQ.

      LOOP AT GROUP LT_GROUP INTO DATA(LS_ASSIGN).
        LV_LINES += 1.

        LV_SEQ += 1.

        "DETAIL 구성
        APPEND INITIAL LINE TO PT_STAT_DETAIL REFERENCE INTO DATA(LR_STAT_DETAIL).

        IF LS_ASSIGN-ZCUT_MBLNR IS NOT INITIAL.
          LV_CNT += 1.
        ENDIF.

        "OVERVIEW 구성
        APPEND INITIAL LINE TO PT_STAT_OVERVIEW REFERENCE INTO DATA(LR_STAT_OVERVIEW).

        SELECT SINGLE ERFMG, BUDAT, ERFME
          FROM MATDOC
         WHERE MBLNR EQ @LS_ASSIGN-ZCUT_MBLNR
           AND MJAHR EQ @LS_ASSIGN-ZCUT_MJAHR
          INTO (@DATA(LV_ERFMG), @DATA(LV_BUDAT), @DATA(LV_ERFME)).

        LR_STAT_OVERVIEW->* = VALUE #( VBELN = LS_ASSIGN-VBELN
                                       POSNR = LS_ASSIGN-POSNR
                                       GRDAT = LV_BUDAT
                                       PODAT = LS_ASSIGN-CRDAT
                                       MEINS = LV_ERFME ).

        LR_STAT_DETAIL->* = VALUE #( VBELN    = LS_ASSIGN-VBELN
                                     POSNR    = LS_ASSIGN-POSNR
                                     SEQUANCE = LV_SEQ
                                     GONG_CD  = 'CT'
                                     PSMNG    = LS_ASSIGN-ZCUT_LEN
                                     WEMNG    = LV_ERFMG
                                     MEINS    = LV_ERFME
                                     STATUS   = COND #( WHEN LS_ASSIGN-ZCUT_MBLNR IS INITIAL THEN TEXT-T13   "미진행
                                                                                             ELSE TEXT-T11 ) "생산완료
                                     PLDAT    = LS_ASSIGN-CRDAT
                                     PRDAT    = LV_BUDAT
                                     CHARG    = LS_ASSIGN-F_CHARG ).

        CLEAR: LS_WEMNG.
        LS_WEMNG-VBELN = LS_ASSIGN-VBELN.
        LS_WEMNG-POSNR = LS_ASSIGN-POSNR.
        LS_WEMNG-WEMNG = LV_ERFMG.
        COLLECT LS_WEMNG INTO LT_WEMNG.

        CLEAR: LV_ERFMG, LV_BUDAT, LV_ERFME.

*          LV_CNT += 1.
*
*        ENDIF.
      ENDLOOP.

      SORT LT_WEMNG BY VBELN POSNR.

      LOOP AT PT_STAT_OVERVIEW ASSIGNING FIELD-SYMBOL(<FS_S>) WHERE VBELN = LT_GROUP-VBELN
                                                                AND POSNR = LT_GROUP-POSNR.
        <FS_S>-STATUS = COND #( WHEN LV_CNT   IS INITIAL THEN TEXT-T02    "// 절단지시.
                                WHEN LV_LINES EQ LV_CNT  THEN TEXT-T03    "// 절단완료.
                                                         ELSE TEXT-T04 ). "// 일부절단.

        CLEAR: LS_WEMNG.
        READ TABLE LT_WEMNG INTO LS_WEMNG WITH KEY VBELN = LT_GROUP-VBELN
                                                   POSNR = LT_GROUP-POSNR.
        <FS_S>-GRQTY = LS_WEMNG-WEMNG.
        <FS_S>-PRQTY = LS_WEMNG-WEMNG.
      ENDLOOP.

    ELSE.  "절단 아닐때
      "OVERVIEW 구성
      APPEND INITIAL LINE TO PT_STAT_OVERVIEW REFERENCE INTO LR_STAT_OVERVIEW.

      LR_STAT_OVERVIEW->* = VALUE #( VBELN  = LT_GROUP-VBELN
                                     POSNR  = LT_GROUP-POSNR ).

      CLEAR: LS_ASSIGN.
      LOOP AT GROUP LT_GROUP INTO LS_ASSIGN.
        LV_SEQ += 1.

        "DETAIL 구성
        APPEND INITIAL LINE TO PT_STAT_DETAIL REFERENCE INTO LR_STAT_DETAIL.

        LR_STAT_DETAIL->* = VALUE #( VBELN    = LS_ASSIGN-VBELN
                                     POSNR    = LS_ASSIGN-POSNR
                                     SEQUANCE = LV_SEQ
                                     GONG_CD  = 'ST'
                                     PSMNG    = LS_ASSIGN-WELENG * LS_ASSIGN-ZCUT_CNT
                                     STATUS   = TEXT-T14              "주문할당
                                     CHARG    = LS_ASSIGN-F_CHARG ).
      ENDLOOP.
    ENDIF.
  ENDLOOP.


*  LOOP AT lt_assign  INTO DATA(ls_key)
*                    GROUP BY ( vbeln        = ls_key-vbeln
*                               posnr        = ls_key-posnr
*                               zassign_no   = ls_key-zassign_no
*                               zassign_item = ls_key-zassign_item
*                               zord_type    = ls_key-zord_type )
*                    INTO DATA(lt_group).
*
*    APPEND INITIAL LINE TO pt_stat_overview REFERENCE INTO DATA(lr_stat_overview).
*    lr_stat_overview->* = VALUE #( vbeln  = lt_group-vbeln
*                                   posnr  = lt_group-posnr
*                                   status = COND #( WHEN lt_group-zord_type NE zgtpp_if_const=>gc_zord_type-c1 THEN TEXT-t01 ) ). "// 정조장.
*
*    CHECK lt_group-zord_type EQ zgtpp_if_const=>gc_zord_type-c1. "// 절단.
*
*    CLEAR: lv_lines, lv_cnt.
*
*    LOOP AT GROUP lt_group INTO DATA(ls_assign).
*      lv_lines += 1.
*
*      IF ls_assign-zcut_mblnr IS NOT INITIAL.
*        lv_cnt += 1.
*      ENDIF.
*    ENDLOOP.
*
*    lr_stat_overview->status = COND #( WHEN lv_cnt   IS INITIAL THEN TEXT-t02    "// 절단지시.
*                                       WHEN lv_lines EQ lv_cnt  THEN TEXT-t03    "// 절단완료.
*                                                                ELSE TEXT-t04 ). "// 일부절단.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detail_from_zgtppt2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DETAIL_FROM_ZGTPPT2000  TABLES PT_ITEM          STRUCTURE ZGTPPS1015
                                        PT_STAT_OVERVIEW STRUCTURE ZGTPPS1013
                                        PT_STAT_DETAIL   STRUCTURE ZGTPPS1014.

  DATA LT_ITEM TYPE TABLE OF ZGTPPS1015.
  DATA LV_STATUS1 TYPE ZGTPPS1014-STATUS.
  DATA LV_STATUS2 TYPE ZGTPPS1014-STATUS.

  DATA: BEGIN OF LS_STAT_DETAIL.
          INCLUDE STRUCTURE ZGTPPS1014.
  DATA:   ERDAT LIKE AUFK-ERDAT,
        END OF LS_STAT_DETAIL.
  DATA: LT_STAT_DETAIL LIKE TABLE OF LS_STAT_DETAIL.

  DATA: LT_INPUT  TYPE ZGTPPY0006,
        LT_RESULT TYPE ZGTPPY0007.

  DATA: LS_INPUT  TYPE ZGTPPS0006,
        LS_RESULT TYPE ZGTPPS0007.

  CLEAR: LT_INPUT, LS_INPUT.

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    READ TABLE PT_STAT_OVERVIEW TRANSPORTING NO FIELDS WITH KEY VBELN = LS_ITEM-VBELN
                                                                POSNR = LS_ITEM-POSNR.
    CHECK SY-SUBRC IS NOT INITIAL.

    APPEND LS_ITEM TO LT_ITEM.

    LS_INPUT-VBELN = LS_ITEM-VBELN.
    LS_INPUT-POSNR = LS_ITEM-POSNR.
    COLLECT LS_INPUT INTO LT_INPUT.
    CLEAR: LS_INPUT.
  ENDLOOP.

  CHECK LT_ITEM IS NOT INITIAL.

  SELECT ZT01~VBELN, ZT01~POSNR
*         ZT03~GONG_SEQ, ZT03~GONG_CD, AFPO~MEINS,
*         SUM( AFPO~PSMNG ) AS PSMNG, SUM( AFPO~WEMNG ) AS WEMNG
    FROM @LT_ITEM   AS ZT01
    JOIN ZGTPPT2000 AS ZT02
      ON ZT01~VBELN   EQ ZT02~ORDNO
     AND ZT01~POSNR   EQ ZT02~POSNR
     AND ZT02~ZSTATUS NE 'D'
*    LEFT JOIN ZGTPPT2010 AS ZT03
*      ON ZT02~GRPNR EQ ZT03~GRPNR
*    JOIN AFPO
*      ON ZT03~DMORD EQ AFPO~AUFNR
*     AND SUBSTRING( ZT03~DMLINE, 3, 4 ) EQ AFPO~POSNR
*   GROUP BY ZT01~VBELN, ZT01~POSNR, ZT03~GONG_SEQ, ZT03~GONG_CD, AFPO~MEINS
*   ORDER BY ZT01~VBELN, ZT01~POSNR, ZT03~GONG_SEQ, ZT03~GONG_CD
    INTO TABLE @DATA(LT_T2000).

  SELECT VBELN, POSNR, KWMENG, VRKME
    FROM VBAP
     FOR ALL ENTRIES IN @LT_ITEM
   WHERE VBELN EQ @LT_ITEM-VBELN
     AND POSNR EQ @LT_ITEM-POSNR
    INTO TABLE @DATA(LT_VBAP).

  SORT LT_VBAP BY VBELN POSNR.

  CLEAR: LT_RESULT.
  CALL FUNCTION 'ZGTPP_GET_JOJANG'
    TABLES
      T_INPUT  = LT_INPUT
      T_RESULT = LT_RESULT.

  IF LT_RESULT[] IS NOT INITIAL.
    SELECT A~VBELN, A~POSNR, A~GONG_SEQ, A~GONG_CD,
           AFPO~MEINS,
           SUM( AFPO~PSMNG ) AS PSMNG, SUM( AFPO~WEMNG ) AS WEMNG, MAX( AFPO~LTRMI ) AS LTRMI,
           MIN( AFKO~GSTRP ) AS GSTRP,
           MIN( AUFK~ERDAT ) AS ERDAT
      FROM @LT_RESULT AS A
      JOIN AFPO ON AFPO~AUFNR EQ A~ORDNR
               AND AFPO~POSNR EQ SUBSTRING( A~POSNR_JOJANG, 3, 4 )
      JOIN AFKO ON AFKO~AUFNR EQ AFPO~AUFNR
      JOIN AUFK ON AUFK~AUFNR EQ AFKO~AUFNR
     WHERE A~ORDTY EQ 'PRD'
     GROUP BY A~VBELN, A~POSNR, A~GONG_SEQ, A~GONG_CD, AFPO~MEINS
     ORDER BY A~VBELN, A~POSNR, A~GONG_SEQ, A~GONG_CD
      INTO TABLE @DATA(LT_JOJANG).

    DATA: LS_JOJANG_F LIKE LINE OF LT_JOJANG.
    DATA: LT_JOJANG_F LIKE TABLE OF LS_JOJANG_F.

    CLEAR: LT_JOJANG_F.
    APPEND LINES OF LT_JOJANG TO LT_JOJANG_F.
    SORT LT_JOJANG_F BY VBELN POSNR GONG_SEQ DESCENDING.

    DELETE ADJACENT DUPLICATES FROM LT_JOJANG_F COMPARING VBELN POSNR.

  ENDIF.

  LOOP AT LT_ITEM INTO LS_ITEM.
    READ TABLE LT_T2000 TRANSPORTING NO FIELDS WITH KEY VBELN = LS_ITEM-VBELN
                                                        POSNR = LS_ITEM-POSNR BINARY SEARCH.
    IF SY-SUBRC IS NOT INITIAL.
      APPEND INITIAL LINE TO PT_STAT_OVERVIEW REFERENCE INTO DATA(LR_STAT_OVERVIEW).

      LR_STAT_OVERVIEW->* = VALUE #( VBELN  = LS_ITEM-VBELN
                                     POSNR  = LS_ITEM-POSNR
                                     STATUS = TEXT-T05 ).   "미진행

    ELSE.
      APPEND INITIAL LINE TO PT_STAT_OVERVIEW REFERENCE INTO LR_STAT_OVERVIEW.

      LR_STAT_OVERVIEW->* = VALUE #( VBELN  = LS_ITEM-VBELN
                                     POSNR  = LS_ITEM-POSNR ).

      CLEAR: LT_STAT_DETAIL.
      LOOP AT LT_JOJANG INTO DATA(LS_JOJANG) WHERE VBELN EQ LS_ITEM-VBELN
                                               AND POSNR EQ LS_ITEM-POSNR.

        APPEND INITIAL LINE TO PT_STAT_DETAIL REFERENCE INTO DATA(LR_STAT_DETAIL).

        LR_STAT_DETAIL->* = CORRESPONDING #( LS_JOJANG MAPPING SEQUANCE = GONG_SEQ ).

        LR_STAT_DETAIL->PLDAT = LS_JOJANG-GSTRP.  "계획일자
        LR_STAT_DETAIL->PRDAT = LS_JOJANG-LTRMI.  "작업일자

        READ TABLE LT_JOJANG_F INTO LS_JOJANG_F WITH KEY VBELN = LS_ITEM-VBELN
                                                         POSNR = LS_ITEM-POSNR.

        IF LS_JOJANG_F-GONG_SEQ = LS_JOJANG-GONG_SEQ. "최종공정
          READ TABLE LT_VBAP INTO DATA(LS_VBAP1) WITH KEY VBELN = LS_ITEM-VBELN
                                                          POSNR = LS_ITEM-POSNR.

          IF SY-SUBRC EQ 0.
            LR_STAT_DETAIL->STATUS = COND #( WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG > 0 AND LS_VBAP1-KWMENG <= LS_JOJANG-WEMNG THEN TEXT-T11
                                             WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG > 0 AND LS_VBAP1-KWMENG >  LS_JOJANG-WEMNG THEN TEXT-T12
                                             WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG = 0 THEN TEXT-T13 ).
            CLEAR: LS_VBAP1.
          ENDIF.
        ELSE.
          LR_STAT_DETAIL->STATUS = COND #( WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG > 0 AND LS_JOJANG-PSMNG <= LS_JOJANG-WEMNG THEN TEXT-T11
                                           WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG > 0 AND LS_JOJANG-PSMNG >  LS_JOJANG-WEMNG THEN TEXT-T12
                                           WHEN LS_JOJANG-PSMNG > 0 AND LS_JOJANG-WEMNG = 0 THEN TEXT-T13 ).
        ENDIF.

        LV_STATUS1 = LR_STAT_DETAIL->STATUS.
        LV_STATUS2 = COND #( WHEN LR_STAT_DETAIL->STATUS EQ TEXT-T12 THEN LR_STAT_DETAIL->STATUS
                                                                     ELSE LV_STATUS2 ).

        MOVE-CORRESPONDING LR_STAT_DETAIL->* TO LS_STAT_DETAIL.
        LS_STAT_DETAIL-ERDAT = LS_JOJANG-ERDAT.

        APPEND LS_STAT_DETAIL TO LT_STAT_DETAIL.

        CLEAR: LS_JOJANG, LS_STAT_DETAIL.
      ENDLOOP.

*      LOOP AT LT_T2000 INTO DATA(LS_T2000) WHERE VBELN EQ LS_ITEM-VBELN
*                                             AND POSNR EQ LS_ITEM-POSNR.
*        APPEND INITIAL LINE TO PT_STAT_DETAIL REFERENCE INTO DATA(LR_STAT_DETAIL).
*
*        SELECT SINGLE MAX( AFPO~LTRMI ), MIN( AFKO~GSTRP ), MIN( AUFK~ERDAT )
*          FROM ZGTPPT2000 AS A
*          JOIN ZGTPPT2010 AS B ON B~GRPNR EQ A~GRPNR
*          JOIN AFPO ON AFPO~AUFNR EQ B~DMORD
*                   AND AFPO~POSNR EQ SUBSTRING( B~DMLINE, 3, 4 )
*          JOIN AFKO ON AFKO~AUFNR EQ AFPO~AUFNR
*          JOIN AUFK ON AUFK~AUFNR EQ AFKO~AUFNR
*         WHERE A~ORDNO = @LS_T2000-VBELN
*           AND A~POSNR = @LS_T2000-POSNR
*           AND B~GONG_SEQ EQ @LS_T2000-GONG_SEQ
*           AND B~GONG_CD EQ @LS_T2000-GONG_CD
*         GROUP BY A~ORDNO, A~POSNR, B~GONG_SEQ, B~GONG_CD
*          INTO (@DATA(LV_LTRMI), @DATA(LV_GSTRP), @DATA(LV_ERDAT)).
*
*        LR_STAT_DETAIL->* = CORRESPONDING #( LS_T2000 MAPPING SEQUANCE = GONG_SEQ ).
*
*        LR_STAT_DETAIL->PLDAT = LV_GSTRP.  "계획일자
*        LR_STAT_DETAIL->PRDAT = LV_LTRMI.  "작업일자
*
*        LR_STAT_DETAIL->STATUS = COND #( WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG > 0 AND LS_T2000-PSMNG <= LS_T2000-WEMNG THEN TEXT-T11
*                                         WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG > 0 AND LS_T2000-PSMNG >  LS_T2000-WEMNG THEN TEXT-T12
*                                         WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG = 0 THEN TEXT-T13 ).
*
*        LV_STATUS1 = LR_STAT_DETAIL->STATUS.
*        LV_STATUS2 = COND #( WHEN LR_STAT_DETAIL->STATUS EQ TEXT-T12 THEN LR_STAT_DETAIL->STATUS
*                                                                     ELSE LV_STATUS2 ).
*
*        MOVE-CORRESPONDING LR_STAT_DETAIL->* TO LS_STAT_DETAIL.
*        LS_STAT_DETAIL-ERDAT = LV_ERDAT.
*
*        APPEND LS_STAT_DETAIL TO LT_STAT_DETAIL.
*
*        CLEAR: LV_LTRMI, LV_GSTRP, LS_STAT_DETAIL.
*      ENDLOOP.

      LR_STAT_OVERVIEW->STATUS = COND #( WHEN LV_STATUS1 EQ TEXT-T11 THEN TEXT-T11
                                         WHEN LV_STATUS2 EQ TEXT-T12 THEN TEXT-T12
                                                                     ELSE TEXT-T13 ).

      SORT LT_STAT_DETAIL BY SEQUANCE DESCENDING.
      READ TABLE LT_STAT_DETAIL INTO LS_STAT_DETAIL WITH KEY VBELN = LS_ITEM-VBELN
                                                             POSNR = LS_ITEM-POSNR
                                                             BINARY SEARCH.

      LR_STAT_OVERVIEW->PODAT = LS_STAT_DETAIL-ERDAT.  "지시일자
      LR_STAT_OVERVIEW->PRQTY = LS_STAT_DETAIL-WEMNG.  "생산수량

      "판매오더 품목코드 추출
      SELECT SINGLE VBELN, POSNR, MATNR, WERKS
        FROM VBAP
       WHERE VBELN EQ @LS_ITEM-VBELN
         AND POSNR EQ @LS_ITEM-POSNR
        INTO @DATA(LS_VBAP).

      "검사재고로 전기 설정 여부 추출
      SELECT SINGLE INSMK
        FROM MARC
       WHERE MATNR EQ @LS_VBAP-MATNR
         AND WERKS EQ @LS_VBAP-WERKS
        INTO @DATA(LV_INSMK).

      IF LV_INSMK EQ 'X'.
        SELECT SINGLE SUM( ERFMG ) AS ERFMG, MAX( BUDAT ) AS BUDAT, ERFME
          FROM MATDOC
         WHERE BWART EQ '321'
           AND MAT_KDAUF EQ @LS_ITEM-VBELN
           AND MAT_KDPOS EQ @LS_ITEM-POSNR
           AND XAUTO EQ @SPACE
           AND CANCELLED EQ @SPACE
         GROUP BY MAT_KDAUF, MAT_KDPOS, ERFME
          INTO @DATA(LS_MATDOC).

      ELSE.
        SELECT SINGLE SUM( ERFMG ) AS ERFMG, MAX( BUDAT ) AS BUDAT, ERFME
          FROM MATDOC
         WHERE BWART EQ '101'
           AND AUFNR NE @SPACE
           AND MAT_KDAUF EQ @LS_ITEM-VBELN
           AND MAT_KDPOS EQ @LS_ITEM-POSNR
           AND XAUTO EQ @SPACE
           AND CANCELLED EQ @SPACE
         GROUP BY MAT_KDAUF, MAT_KDPOS, ERFME
          INTO @LS_MATDOC.
      ENDIF.

      LR_STAT_OVERVIEW->GRDAT = LS_MATDOC-BUDAT.  "입고일자
      LR_STAT_OVERVIEW->GRQTY = LS_MATDOC-ERFMG.  "입고수량
      LR_STAT_OVERVIEW->MEINS = LS_MATDOC-ERFME.  "단위

      CLEAR: LS_MATDOC.
    ENDIF.
  ENDLOOP.

*  SELECT ZT01~VBELN, ZT01~POSNR, ZT02~GRPNR, ZT03~GONG_SEQ, ZT03~GONG_CD, AFPO~MEINS,
*         SUM( AFPO~PSMNG ) AS PSMNG, SUM( AFPO~WEMNG ) AS WEMNG
*    FROM @LT_ITEM   AS ZT01
*    JOIN ZGTPPT2000 AS ZT02
*      ON ZT01~VBELN   EQ ZT02~ORDNO
*     AND ZT01~POSNR   EQ ZT02~POSNR
*     AND ZT02~ZSTATUS NE 'D'
*    LEFT JOIN ZGTPPT2010 AS ZT03
*      ON ZT02~GRPNR EQ ZT03~GRPNR
*    JOIN AFPO
*      ON ZT03~DMORD EQ AFPO~AUFNR
*     AND SUBSTRING( ZT03~DMLINE, 3, 4 ) EQ AFPO~POSNR
*   GROUP BY ZT01~VBELN, ZT01~POSNR, ZT02~GRPNR, ZT03~GONG_SEQ, ZT03~GONG_CD, AFPO~MEINS
*   ORDER BY ZT01~VBELN, ZT01~POSNR, ZT02~GRPNR, ZT03~GONG_SEQ, ZT03~GONG_CD
*    INTO TABLE @DATA(LT_T2000).
*
*  LOOP AT LT_ITEM INTO LS_ITEM.
*    APPEND INITIAL LINE TO PT_STAT_OVERVIEW REFERENCE INTO DATA(LR_STAT_OVERVIEW).
*    LR_STAT_OVERVIEW->* = VALUE #( VBELN  = LS_ITEM-VBELN
*                                   POSNR  = LS_ITEM-POSNR ).
*
*    READ TABLE LT_T2000 TRANSPORTING NO FIELDS WITH KEY VBELN = LS_ITEM-VBELN
*                                                        POSNR = LS_ITEM-POSNR BINARY SEARCH.
*    IF SY-SUBRC IS NOT INITIAL.
*      LR_STAT_OVERVIEW->STATUS = TEXT-T05.
*    ELSE.
*      LOOP AT LT_T2000 FROM SY-TABIX
*                       INTO DATA(LS_T2000).
*        IF LS_T2000-VBELN NE LS_ITEM-VBELN AND LS_T2000-POSNR NE LS_ITEM-POSNR.
*          EXIT.
*        ENDIF.
*
*        APPEND INITIAL LINE TO PT_STAT_DETAIL REFERENCE INTO DATA(LR_STAT_DETAIL).
*        LR_STAT_DETAIL->* = CORRESPONDING #( LS_T2000 MAPPING SEQUANCE = GONG_SEQ ).
*
*        LR_STAT_DETAIL->STATUS = COND #( WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG > 0 AND LS_T2000-PSMNG <= LS_T2000-WEMNG THEN TEXT-T11
*                                         WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG > 0 AND LS_T2000-PSMNG >  LS_T2000-WEMNG THEN TEXT-T12
*                                         WHEN LS_T2000-PSMNG > 0 AND LS_T2000-WEMNG = 0 THEN TEXT-T13 ).
*
*        LV_STATUS1 = LR_STAT_DETAIL->STATUS.
*        LV_STATUS2 = COND #( WHEN LR_STAT_DETAIL->STATUS EQ TEXT-T12 THEN LR_STAT_DETAIL->STATUS
*                                                                     ELSE LV_STATUS2 ).
*      ENDLOOP.
*
*      LR_STAT_OVERVIEW->STATUS = COND #( WHEN LV_STATUS1 EQ TEXT-T11 THEN TEXT-T11
*                                         WHEN LV_STATUS2 EQ TEXT-T12 THEN TEXT-T12
*                                                                     ELSE TEXT-T13 ).
*    ENDIF.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vc_configuration
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_VC_CONFIGURATION  USING PV_CUOBJ
                                 PT_CONFG TYPE TY_T_CONFG.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = PV_CUOBJ
    TABLES
      CONFIGURATION       = PT_CONFG
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_lot_for_order_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_LOT_FOR_ORDER_ALLOC  USING PS_ITEM TYPE ZGTPPSIF0044.

  SELECT ZT01~ZASSIGN_NO,   ZT01~WERKS, ZT01~VBELN, ZT01~POSNR, ZT01~WELENG, ZT01~WECNT, ZT01~MATNR,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG, ZT02~ZCUT_CNT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~LOEKZ   EQ @SPACE
     AND ZT02~F_CHARG EQ @GS_ZPPT0001-CHARG
    INTO TABLE @DATA(LT_ALLOC1).

  SELECT ZT01~ZASSIGN_NO,   ZT01~WERKS, ZT01~VBELN, ZT01~POSNR, ZT01~WELENG, ZT01~WECNT, ZT01~MATNR,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT, ZT02~F_CHARG, ZT02~ZCUT_CNT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~VBELN EQ @PS_ITEM-VBELN
     AND ZT01~POSNR EQ @PS_ITEM-POSNR
     AND ZT01~LOEKZ EQ @SPACE
    INTO TABLE @DATA(LT_ALLOC2).

  CHECK LT_ALLOC1 IS NOT INITIAL AND LT_ALLOC2 IS NOT INITIAL.

  DATA(LS_ALLOC1) = LT_ALLOC1[ 1 ].
  DATA(LS_ALLOC2) = LT_ALLOC2[ 1 ].

  CHECK |{ LS_ALLOC1-VBELN }{ LS_ALLOC1-POSNR }| NE |{ LS_ALLOC2-VBELN }{ LS_ALLOC2-POSNR }|.

  UPDATE ZGTPPT2180
     SET F_CHARG = LS_ALLOC2-F_CHARG
   WHERE ZASSIGN_NO   EQ LS_ALLOC1-ZASSIGN_NO
     AND ZASSIGN_ITEM EQ LS_ALLOC1-ZASSIGN_ITEM.

  UPDATE ZGTPPT2180
     SET F_CHARG = LS_ALLOC1-F_CHARG
   WHERE ZASSIGN_NO   EQ LS_ALLOC2-ZASSIGN_NO
     AND ZASSIGN_ITEM EQ LS_ALLOC2-ZASSIGN_ITEM.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LR_ORDER_BOM_>AUFNR
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_INPUT  USING    PV_ROUTINE PV_VALUE.
  DATA LV_FNAME TYPE STRING.

  CHECK PV_VALUE IS NOT INITIAL.

  LV_FNAME = |CONVERSION_EXIT_{ PV_ROUTINE }_INPUT|.

  CALL FUNCTION LV_FNAME
    EXPORTING
      INPUT  = PV_VALUE
    IMPORTING
      OUTPUT = PV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_order_bom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_ORDER_BOM  USING    PV_ERROR.


*- 플랜트 존재여부 체크
  SELECT SINGLE MANDT
   FROM T001W
   WHERE WERKS = @GS_ORDER_BOM-WERKS
   INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M06 "존재하지 않는 플랜트 입니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- 플랜트 누락 체크
  IF GS_ORDER_BOM-WERKS IS INITIAL  .

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M08 "필수값 '플랜트' 누락되었습니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.


*- 일련번호 누락 체크
  IF GS_ORDER_BOM-ZSERNO IS INITIAL  .

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M09 "필수값 '일련번호' 누락되었습니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.


*- 생산오더 번호
  SELECT SINGLE MANDT
    FROM AUFK
    WHERE AUFNR = @GS_ORDER_BOM-AUFNR
    INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_ORDER_BOM USING 'E'
                                     TEXT-M13. "'존재하지 않는 생산오더 입니다.'
    .
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- 생산오더 누락 체크
  IF GS_ORDER_BOM-AUFNR IS INITIAL  .

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M10 "필수값 '오더번호' 누락되었습니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.

*- 예약번호 누락 체크
  IF GS_ORDER_BOM-RSNUM IS INITIAL  .

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M11 "필수값 '예약번호' 누락되었습니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.

*- 예약번호 누락 체크
  IF GS_ORDER_BOM-RSPOS IS INITIAL  .

    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                      TEXT-M12 "필수값 '예약품목번호' 누락되었습니다.
                                      .
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_order_bom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_M06
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_ORDER_BOM  USING    PV_FLAG
                                       PV_MESSAGE.

  CLEAR :  GS_RESULT.

  GS_RESULT = VALUE #(
                            WERKS         = GS_ORDER_BOM-WERKS
                            ZSERNO        = GS_ORDER_BOM-ZSERNO
                            AUFNR         = GS_ORDER_BOM-AUFNR
                            RSNUM         = GS_ORDER_BOM-RSNUM
                            RSPOS         = GS_ORDER_BOM-RSPOS
                            ZERP_STAT     = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE
                         ).
  APPEND GS_RESULT TO GT_RESULT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reservation_item_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM RESERVATION_ITEM_CHECK  USING    PV_ERROR.

  DATA : LV_MESSAGE_MARD(220).

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_RESB
    FROM RESB
   WHERE AUFNR = GS_ORDER_BOM-AUFNR
     AND WERKS = GS_ORDER_BOM-WERKS
     AND RSNUM = GS_ORDER_BOM-RSNUM
     AND RSPOS = GS_ORDER_BOM-RSPOS.
  .

  IF SY-SUBRC = 0.
    READ TABLE GT_RESB INTO GS_RESB
                       WITH KEY MATNR = GS_ORDER_BOM-MATNR_FROM.
    IF SY-SUBRC <> 0.
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        TEXT-M14 "오더의 품목에 투입처리된 내역이 있어 대체자재 변경할 수 없습니다
                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDIF.



  SELECT  A~MATNR,
          A~WERKS,
          A~LVORM,
          B~LVORM AS LVORM_MARA,
          A~MMSTA
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARC
    FROM MARC AS A INNER JOIN MARA AS B
                   ON A~MATNR = B~MATNR
   WHERE A~MATNR = @GS_ORDER_BOM-MATNR_TO
     AND A~WERKS = @GS_ORDER_BOM-WERKS.

  IF SY-SUBRC = 0.
    READ TABLE GT_MARC INTO GS_MARC
                       WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO.
    IF SY-SUBRC = 0.
      IF GS_MARC-LVORM = 'X' OR GS_MARC-LVORM_MARA = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M28 "변경하고자 하는 자재가 삭제 상태입니다.
                                          .
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

*--RESB에서 추출한 저장위치 & MATNR_TO & 플랜트를 조건으로 MARD의 값이 존재하는지 점검.
*--MARD 값이 없을 경우 오류

  READ TABLE GT_RESB INTO GS_RESB
                     WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO
                              WERKS = GS_ORDER_BOM-WERKS.

  IF SY-SUBRC = 0 .

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_MARD
      FROM MARD
     WHERE MATNR = GS_RESB-MATNR
       AND WERKS = GS_RESB-WERKS
       AND LGORT = GS_RESB-LGORT.
    .
    IF SY-SUBRC <> 0.
      CLEAR : LV_MESSAGE_MARD.
      CONCATENATE TEXT-M32
                  GS_ORDER_BOM-MATNR_TO
                  TEXT-M33
                  GS_RESB-LGORT
                  TEXT-M34
             INTO LV_MESSAGE_MARD. "대체자재 {MATNR_TO}의 오더 BOM 저장위치 {RESB-LGORT}가 없습니다."
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        LV_MESSAGE_MARD .                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDIF.

  READ TABLE GT_MARC INTO GS_MARC
                     WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO
                              WERKS = GS_ORDER_BOM-WERKS.
  IF SY-SUBRC = 0.
    IF GS_MARC-MMSTA IS NOT INITIAL.
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        TEXT-M35 "대체자재의 자재상태가 설계상태가 양산 가능 상태가 아닙니다
                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form order_status_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM ORDER_STATUS_CHECK  USING    PV_ERROR
                                  PV_MESSAGE.

  SELECT AUFNR, CRTD, REL,  DEL,  DLFL,
         LKD,   TECO, CLSD, PCNF, CNF,
         PDLV,  DLV,  PAYO, GISTART
    INTO TABLE @DATA(LT_STAT)
    FROM ZGTPP_CV_ORD_STAT
   WHERE AUFNR = @GS_ORDER_BOM-AUFNR
     AND WERKS = @GS_ORDER_BOM-WERKS.
  SORT LT_STAT BY AUFNR .

  IF SY-SUBRC = 0.
    READ TABLE LT_STAT INTO DATA(LS_STAT)
                       WITH KEY AUFNR = GS_ORDER_BOM-AUFNR
                       BINARY SEARCH.
    IF SY-SUBRC = 0.

      IF ( LS_STAT-DEL = 'X' OR LS_STAT-DLFL = 'X').
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M15. "생산오더가 'DEL, DLFL' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M15.
        EXIT.
      ELSEIF  LS_STAT-LKD  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M16. "생산오더가 'LKD' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M16.
        EXIT.
      ELSEIF  LS_STAT-TECO  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M17. "생산오더가 'TECO' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M17.
        EXIT.
      ELSEIF  LS_STAT-CLSD  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M18. "생산오더가 'CLSD' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M18.
        EXIT.
      ELSEIF  LS_STAT-PCNF  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M19. "생산오더가 'PCNF' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M19.
        EXIT.
      ELSEIF  LS_STAT-CNF  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M20. "생산오더가 'CNF' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M20.
        EXIT.
      ELSEIF  LS_STAT-PDLV  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M21. "생산오더가 'PDLV' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M21.
        EXIT.
      ELSEIF  LS_STAT-DLV  = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M22. "생산오더가 'DLV' 상태이므로 처리할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M22.
        EXIT.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form qty_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM QTY_CHECK  USING    PV_ERROR
                         PV_MESSAGE.

  SELECT AUFNR, MBLNR
    INTO TABLE @DATA(LT_MATDOC)
    FROM MATDOC
   WHERE AUFNR = @GS_ORDER_BOM-AUFNR
     AND WERKS = @GS_ORDER_BOM-WERKS
     AND RSNUM = @GS_ORDER_BOM-RSNUM
     AND RSPOS = @GS_ORDER_BOM-RSPOS
     AND BWART = '261'
     AND CANCELLED = ' '.
  SORT LT_MATDOC BY AUFNR MBLNR.

  IF SY-SUBRC = 0.
    READ TABLE LT_MATDOC INTO DATA(LS_MATDOC)
                       WITH KEY AUFNR = GS_ORDER_BOM-AUFNR
                       BINARY SEARCH.
    IF LS_MATDOC-MBLNR IS NOT INITIAL.
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        TEXT-M23. "오더의 품목에 투입처리된 내역이 있어 대체자재 변경할 수 없습니다
      PV_ERROR = 'X'.
      PV_MESSAGE = TEXT-M23.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO  USING    DYNBEGIN NAME VALUE.

  CLEAR GS_BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO GS_BDCDATA-PROGRAM,
          VALUE TO GS_BDCDATA-DYNPRO,
          'X'   TO GS_BDCDATA-DYNBEGIN.
    APPEND GS_BDCDATA TO GT_BDCDATA.
  ELSE.
    MOVE: NAME  TO GS_BDCDATA-FNAM,
          VALUE TO GS_BDCDATA-FVAL.
    APPEND GS_BDCDATA TO GT_BDCDATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form message_function
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MSGCOLL
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MESSAGE_FUNCTION  USING    PS_MESSAGE STRUCTURE BDCMSGCOLL
                              PV_TEXT.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = PS_MESSAGE-MSGID "SY-MSGID
      MSGNR               = PS_MESSAGE-MSGNR "SY-MSGNO
      MSGV1               = PS_MESSAGE-MSGV1 "SY-MSGV1
      MSGV2               = PS_MESSAGE-MSGV2 "SY-MSGV2
      MSGV3               = PS_MESSAGE-MSGV3 "SY-MSGV3
      MSGV4               = PS_MESSAGE-MSGV4 "SY-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_read_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORDER_BOM
*&      --> LV_ZERP_STAT
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM APPEND_READ_DATA  USING     PS_ORDER_BOM TYPE ZGTPPS1017
                                PV_ZERP_STAT
                                PV_MESSAGE.

  DATA  : LS_ZGTPPSIF0033 LIKE GS_ORDER_BOM_S.
  CLEAR : LS_ZGTPPSIF0033.



  LS_ZGTPPSIF0033 = VALUE #( BASE  CORRESPONDING #( PS_ORDER_BOM )
                             ZERP_STAT    = PV_ZERP_STAT
                             ZERP_MESSAGE = PV_MESSAGE
                             ).

  APPEND LS_ZGTPPSIF0033 TO GT_ORDER_BOM_S.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_input_gt_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_GT_RESULT .


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ORDER_BOM-AUFNR
    IMPORTING
      OUTPUT = GS_ORDER_BOM-AUFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ORDER_BOM-RSNUM
    IMPORTING
      OUTPUT = GS_ORDER_BOM-RSNUM.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ORDER_BOM-RSPOS
    IMPORTING
      OUTPUT = GS_ORDER_BOM-RSPOS.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GS_ORDER_BOM-MATNR_FROM
    IMPORTING
      OUTPUT = GS_ORDER_BOM-MATNR_FROM.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GS_ORDER_BOM-MATNR_TO
    IMPORTING
      OUTPUT = GS_ORDER_BOM-MATNR_TO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FACTOR_BATCH_UPD_TYPE_U2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ITEM
*&---------------------------------------------------------------------*
FORM FACTOR_BATCH_UPD_TYPE_U2  USING    PS_ITEM    TYPE ZGTPPSIF0044.

  DATA: LT_RETURN  TYPE TABLE OF BAPIRET2,
        LV_CLASS   TYPE KLAH-CLASS,
        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
        LV_STATUS  TYPE BAPI1003_KEY-STATUS.

  WAIT UP TO 1 SECONDS.

  CLEAR: GS_ZLET0401.
  READ TABLE GT_ZLET0401 INTO GS_ZLET0401 WITH KEY DLVRQ = PS_ITEM-DLVRQ
                                                   VBELN = PS_ITEM-VBELN
                                                   POSNR = PS_ITEM-POSNR.

  "BATCH 유형 점검
  SELECT SINGLE DPCBT
    FROM MARC
   WHERE MATNR EQ @GS_ZLET0401-MATNR
     AND WERKS EQ @GS_ZLET0401-WERKS
    INTO @DATA(LV_DPCBT).

  IF LV_DPCBT EQ 'A'.
    DATA(LV_CHARG) = CONV CHARG_D( TRUNC( GS_ZLET0401-INDLEN ) ).
    CONDENSE LV_CHARG NO-GAPS.

    CLEAR: LT_VALNUM, LT_VALCHAR, LT_VALCURR.

* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL           = GS_ZLET0401-MATNR "입고자재
        PLANT              = GS_ZLET0401-WERKS "플랜트
        CLASSTYPE          = '023'             "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

    CHECK LV_CLASS IS NOT INITIAL.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH_SUB'.
    LS_VALNUM-VALUE_FROM = ''.
    APPEND LS_VALNUM TO LT_VALNUM.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH'.
    LS_VALNUM-VALUE_FROM = LV_CHARG.
    APPEND LS_VALNUM TO LT_VALNUM.

*- 배치 특성 업데이트(펑션 호출)
    SELECT SINGLE CUOBJ_BM
      INTO @DATA(LV_OBJKEY)
      FROM MCH1
     WHERE MATNR = @GS_ZLET0401-MATNR
       AND CHARG = @LV_CHARG.

    CLEAR : LT_RETURN.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        CLOBJECTKEY         = LV_OBJKEY
        CLASSNUM            = LV_CLASS
      IMPORTING
        CLASSIF_STATUS      = LV_STATUS
      TABLES
        ALLOCVALUESNUM_NEW  = LT_VALNUM
        ALLOCVALUESCHAR_NEW = LT_VALCHAR
        ALLOCVALUESCURR_NEW = LT_VALCURR
        RETURN              = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

    ENDIF.
  ENDIF.

  CLEAR: LV_DPCBT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FACTOR_BATCH_UPD_TYPE_Z2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ITEM
*&---------------------------------------------------------------------*
FORM FACTOR_BATCH_UPD_TYPE_Z2  USING    PS_ITEM    TYPE ZGTPPSIF0044.

  DATA: LT_RETURN  TYPE TABLE OF BAPIRET2,
        LV_CLASS   TYPE KLAH-CLASS,
        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
        LV_STATUS  TYPE BAPI1003_KEY-STATUS.

  CLEAR: GS_ZGTPPT3360_U2.
  READ TABLE GT_ZGTPPT3360_U2 INTO GS_ZGTPPT3360_U2 WITH KEY DLVRQ = PS_ITEM-DLVRQ
                                                             VBELN = PS_ITEM-VBELN
                                                             POSNR = PS_ITEM-POSNR.

  IF GS_ZGTPPT3360_U2-TR_MBLNR IS NOT INITIAL.
    SELECT SINGLE MATNR, WERKS, CHARG
      FROM MATDOC
     WHERE MBLNR EQ @GS_ZGTPPT3360_U2-TR_MBLNR
       AND MJAHR EQ @GS_ZGTPPT3360_U2-TR_MJAHR
      INTO @DATA(LS_MATDOC).

    IF LS_MATDOC IS NOT INITIAL.
      "BATCH 유형 점검
      SELECT SINGLE DPCBT
        FROM MARC
       WHERE MATNR EQ @LS_MATDOC-MATNR
         AND WERKS EQ @LS_MATDOC-WERKS
        INTO @DATA(LV_DPCBT).

      IF LV_DPCBT EQ 'A'.
        CLEAR: LT_VALNUM, LT_VALCHAR, LT_VALCURR.

* CLASS번호
        CLEAR: LV_CLASS.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = LS_MATDOC-MATNR "입고자재
            PLANT              = LS_MATDOC-WERKS "플랜트
            CLASSTYPE          = '023'           "클래스유형(배치)
          IMPORTING
            CLASS              = LV_CLASS
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        CHECK LV_CLASS IS NOT INITIAL.

        CLEAR: LS_VALNUM.
        LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH_SUB'.
        LS_VALNUM-VALUE_FROM = ''.
        APPEND LS_VALNUM TO LT_VALNUM.

        CLEAR: LS_VALNUM.
        LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH'.
        LS_VALNUM-VALUE_FROM = LS_MATDOC-CHARG.
        APPEND LS_VALNUM TO LT_VALNUM.

*- 배치 특성 업데이트(펑션 호출)
        SELECT SINGLE CUOBJ_BM
          INTO @DATA(LV_OBJKEY)
          FROM MCH1
         WHERE MATNR = @LS_MATDOC-MATNR
           AND CHARG = @LS_MATDOC-CHARG.

        CLEAR : LT_RETURN.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
            CLOBJECTKEY         = LV_OBJKEY
            CLASSNUM            = LV_CLASS
          IMPORTING
            CLASSIF_STATUS      = LV_STATUS
          TABLES
            ALLOCVALUESNUM_NEW  = LT_VALNUM
            ALLOCVALUESCHAR_NEW = LT_VALCHAR
            ALLOCVALUESCURR_NEW = LT_VALCURR
            RETURN              = LT_RETURN.

        IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.

        ENDIF.
      ENDIF.

      CLEAR: LV_DPCBT.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_SALES_ORDER_ALLOC_U3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ITEM
*&      --> PS_RETURN
*&---------------------------------------------------------------------*
FORM CANCEL_SALES_ORDER_ALLOC_U3  USING    PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045.

  "판매오더 재고 이전전기 수량 점검
  SELECT SUM( ERFMG )
    FROM MATDOC
   WHERE MAT_KDAUF EQ @PS_ITEM-VBELN
     AND MAT_KDPOS EQ @PS_ITEM-POSNR
     AND BWART EQ '413'
     AND CANCELLED EQ @SPACE
    INTO @DATA(LV_ERFMG).

  "판매오더 수량 점검
  SELECT SINGLE KWMENG
    FROM VBAP
   WHERE VBELN EQ @PS_ITEM-VBELN
     AND POSNR EQ @PS_ITEM-POSNR
    INTO @DATA(LV_KWMENG).

  "판매오더 수량 =< 판매오더 재고 이전전기 수량
  CHECK LV_KWMENG =< LV_ERFMG.

  UPDATE ZGTPPT2170
     SET LOEKZ       = 'C'
         STOCK_COMPL = ABAP_FALSE
         CHDAT       = GS_ZGTPPS1001-CHDAT
         CHTIM       = GS_ZGTPPS1001-CHTIM
         CHNAM       = GS_ZGTPPS1001-CHNAM
   WHERE VBELN        EQ PS_ITEM-VBELN
     AND POSNR        EQ PS_ITEM-POSNR
     AND ZASSIGN_TYPE NE 'PC'
     AND LOEKZ        NE 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_SALES_ORDER_ALLOC_Z3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ITEM
*&      --> PS_RETURN
*&---------------------------------------------------------------------*
FORM CANCEL_SALES_ORDER_ALLOC_Z3  USING    PS_ITEM   TYPE ZGTPPSIF0044
                                           PS_RETURN TYPE ZGTPPSIF0045.

  "판매문서 존재 여부 확인
  SELECT ZT01~ZASSIGN_NO, ZT01~ZASSIGN_TYPE
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~VBELN EQ @PS_ITEM-VBELN
     AND ZT01~POSNR EQ @PS_ITEM-POSNR
    INTO TABLE @DATA(LT_ZGTPPT2170).

  IF LT_ZGTPPT2170[] IS INITIAL.
    PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_RETURN-STAT_MSG = TEXT-E09.
  ELSE.
    UPDATE ZGTPPT2170
       SET LOEKZ       = ABAP_FALSE
           STOCK_COMPL = ABAP_FALSE
           CHDAT       = GS_ZGTPPS1001-CHDAT
           CHTIM       = GS_ZGTPPS1001-CHTIM
           CHNAM       = GS_ZGTPPS1001-CHNAM
     WHERE VBELN EQ PS_ITEM-VBELN
       AND POSNR EQ PS_ITEM-POSNR
       AND ZASSIGN_TYPE NE 'PC'.

    SORT LT_ZGTPPT2170 BY ZASSIGN_NO.
    LOOP AT LT_ZGTPPT2170 INTO DATA(LS_2170) WHERE ZASSIGN_TYPE EQ 'PC'.
      DELETE FROM ZGTPPT2170 WHERE ZASSIGN_NO = LS_2170-ZASSIGN_NO.
      DELETE FROM ZGTPPT2180 WHERE ZASSIGN_NO = LS_2170-ZASSIGN_NO.
    ENDLOOP.

    PS_RETURN-AL_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_RETURN-STAT_MSG = TEXT-S11.

    CLEAR: LT_ZGTPPT2170, LT_ZGTPPT2170[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_LOT_FOR_ORDER_ALLOC_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ITEM
*&---------------------------------------------------------------------*
FORM UPDATE_LOT_FOR_ORDER_ALLOC_2  USING PS_ITEM TYPE ZGTPPSIF0044.

  SELECT SINGLE ZT02~ZASSIGN_NO, ZT02~ZASSIGN_ITEM
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~VBELN EQ @PS_ITEM-VBELN
     AND ZT01~POSNR EQ @PS_ITEM-POSNR
     AND ZT01~LOEKZ EQ @SPACE
     AND ZT02~STOCK_COMPL EQ @SPACE
     AND ZT01~ZASSIGN_TYPE NE 'PC'
    INTO @DATA(LS_ALLOC).

  CHECK LS_ALLOC-ZASSIGN_NO IS NOT INITIAL.

  UPDATE ZGTPPT2180
     SET STOCK_COMPL = 'Y'
   WHERE ZASSIGN_NO   EQ LS_ALLOC-ZASSIGN_NO
     AND ZASSIGN_ITEM EQ LS_ALLOC-ZASSIGN_ITEM.

  COMMIT WORK AND WAIT.

ENDFORM.
