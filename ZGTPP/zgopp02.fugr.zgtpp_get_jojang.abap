FUNCTION ZGTPP_GET_JOJANG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      T_INPUT TYPE  ZGTPPY0006
*"      T_RESULT TYPE  ZGTPPY0007
*"----------------------------------------------------------------------

  DATA : LT_RESULT TYPE ZGTPPY0007.
  DATA : LT_RESULT_ORDERS TYPE ZGTPPY0007.
  DATA : LT_INPUT TYPE ZGTPPY0006.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_DEV_2010 LIKE LT_2010.
  DATA : LS_CHK_DEV_2010 TYPE ZGTPPT2010.
  DATA : LT_PRE_2010 LIKE LT_2010.

  LT_INPUT = T_INPUT[].
  SORT LT_INPUT BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_INPUT COMPARING VBELN POSNR.

  LOOP AT LT_INPUT INTO DATA(LS_INPUT).

* 판매오더 대상여부 확인
    SELECT SINGLE VBELN, POSNR, MATNR, WERKS FROM VBAP
      INTO @DATA(LS_VBAP)
     WHERE VBELN = @LS_INPUT-VBELN
       AND POSNR = @LS_INPUT-POSNR.
    IF SY-SUBRC NE 0. " 판매오더 대상 아닐시 추출없음.
      CONTINUE.
    ENDIF.

* 조장 구성표내 모수 추출
    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_MOSU)
     WHERE DMORD = @LS_VBAP-VBELN
       AND DMLINE = @LS_VBAP-POSNR
       AND DMORDTY = 'SO'.

    REFRESH LT_RESULT.
    LOOP AT LT_MOSU INTO DATA(LS_MOSU).
      REFRESH LT_RESULT_ORDERS.

*"----------------------------------------------------------------------
* 조장 체인정보 추출
*"----------------------------------------------------------------------
      REFRESH LT_2010.
      SELECT * FROM ZGTPPT2010
        INTO TABLE LT_2010
       WHERE GRPNR = LS_MOSU-GRPNR.

      APPEND LS_MOSU TO LT_DEV_2010.

      DO.
        REFRESH LT_PRE_2010.
        LOOP AT LT_DEV_2010 INTO DATA(LS_DEV_2010).
          LOOP AT LT_2010 INTO DATA(LS_2010) WHERE GONG_SEQ < LS_DEV_2010-GONG_SEQ
                                               AND DMORD = LS_DEV_2010-ORDNR
                                               AND DMLINE = LS_DEV_2010-POSNR
                                               AND DMORDTY = LS_DEV_2010-ORDTY.
            APPEND   LS_2010 TO LT_PRE_2010.
          ENDLOOP.

          LOOP AT LT_2010 INTO LS_2010 WHERE GONG_SEQ < LS_DEV_2010-GONG_SEQ
                                         AND ORDNR = LS_DEV_2010-REORD
                                         AND POSNR = LS_DEV_2010-RELINE
                                         AND ORDTY = LS_DEV_2010-REORDTY.
            IF LS_2010-DMORD = LS_DEV_2010-ORDNR AND
               LS_2010-DMLINE = LS_DEV_2010-POSNR AND
               LS_2010-DMORDTY = LS_DEV_2010-ORDTY.
            ELSE.
              LOOP AT LT_2010 INTO DATA(LS_PRE_2010) WHERE GONG_SEQ < LS_DEV_2010-GONG_SEQ
                                                       AND DMORD = LS_2010-DMORD
                                                       AND DMLINE = LS_2010-DMLINE
                                                       AND DMORDTY = LS_2010-DMORDTY.
                APPEND   LS_PRE_2010 TO LT_PRE_2010.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

* 오더별 소트
        SORT LT_PRE_2010 BY ORDNR POSNR ORDTY.
        DELETE ADJACENT DUPLICATES FROM LT_PRE_2010 COMPARING ORDNR POSNR ORDTY.

        LOOP AT LT_DEV_2010 INTO LS_DEV_2010.
          IF LS_DEV_2010-ORDTY = 'REF'.
            READ TABLE LT_RESULT_ORDERS INTO DATA(LS_RESULT_ORDERS) WITH KEY ORDNR = LS_DEV_2010-ORDNR.
            IF SY-SUBRC EQ 0.
              CONTINUE.
            ELSE.
              CLEAR LS_RESULT_ORDERS.
              LS_RESULT_ORDERS-GONG_CD = LS_DEV_2010-GONG_CD.
              LS_RESULT_ORDERS-GONG_SEQ = LS_DEV_2010-GONG_SEQ.
              LS_RESULT_ORDERS-ORDNR = LS_DEV_2010-ORDNR.
              LS_RESULT_ORDERS-POSNR_JOJANG = 1 + 0.
              LS_RESULT_ORDERS-ORDTY = 'PRD'.
              APPEND LS_RESULT_ORDERS TO LT_RESULT_ORDERS.
              CONTINUE.
            ENDIF.
          ENDIF.

          IF LS_DEV_2010-REF_TANDEM = 'X'.
            CONTINUE.
          ENDIF.

          IF LS_DEV_2010-ORDTY = 'PO'.
            READ TABLE LT_RESULT_ORDERS INTO LS_RESULT_ORDERS WITH KEY ORDNR = LS_DEV_2010-ORDNR
                                                                       POSNR_JOJANG = LS_DEV_2010-POSNR
                                                                       ORDTY = 'PO'.
            IF SY-SUBRC EQ 0.
              CONTINUE.
            ENDIF.
          ENDIF.

          CLEAR LS_RESULT_ORDERS.
          LS_RESULT_ORDERS-GONG_CD = LS_DEV_2010-GONG_CD.
          LS_RESULT_ORDERS-GONG_SEQ = LS_DEV_2010-GONG_SEQ.
          LS_RESULT_ORDERS-ORDNR = LS_DEV_2010-ORDNR.
          LS_RESULT_ORDERS-POSNR_JOJANG = LS_DEV_2010-POSNR.
          LS_RESULT_ORDERS-ORDTY = LS_DEV_2010-ORDTY.
          APPEND LS_RESULT_ORDERS TO LT_RESULT_ORDERS.

        ENDLOOP.

        IF LT_PRE_2010[] IS INITIAL.
          EXIT.
        ENDIF.

        REFRESH LT_DEV_2010.
        APPEND LINES OF LT_PRE_2010 TO LT_DEV_2010.

      ENDDO.
*"----------------------------------------------------------------------
      REFRESH LT_DEV_2010.

      IF LT_RESULT_ORDERS IS NOT INITIAL.
        APPEND LINES OF LT_RESULT_ORDERS TO LT_RESULT.
      ENDIF .
    ENDLOOP.

    IF LT_RESULT IS NOT INITIAL.
      LOOP AT LT_RESULT ASSIGNING FIELD-SYMBOL(<LS_SET>).
        <LS_SET>-VBELN = LS_VBAP-VBELN.
        <LS_SET>-POSNR = LS_VBAP-POSNR.
        <LS_SET>-WERKS = LS_VBAP-WERKS.
      ENDLOOP.

      APPEND LINES OF LT_RESULT TO T_RESULT.
    ENDIF.

  ENDLOOP.

  SORT T_RESULT BY GONG_SEQ
                   ORDNR DESCENDING
                   POSNR_JOJANG DESCENDING.

ENDFUNCTION.
