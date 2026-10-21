class ZCL_IM_GT_PP_COGI_DEL_AUTH definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_GOODSMVT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_GT_PP_COGI_DEL_AUTH IMPLEMENTATION.


  method IF_EX_WORKORDER_GOODSMVT~BACKFLUSH.
  endmethod.


  METHOD IF_EX_WORKORDER_GOODSMVT~COGI_AUTHORITY_CHECK.

    CASE I_UCOMM.
      WHEN 'BU'.
        IF LINE_EXISTS( IT_AFFWB[ VBKZ = 'D' ] ).

          DATA(LT_AFFWB) = IT_AFFWB.

          SELECT D~*
             FROM ZGTPPT1010 AS D
            WHERE CONCAT( FLD_01, FLD_02 ) IN
        ( SELECT CONCAT( C~WERKS, LEFT( C~DISPO, 2 ) )
            FROM @LT_AFFWB AS A
            INNER JOIN AFPO AS B
                                  ON B~AUFNR = A~AUFNR
            INNER JOIN MARC AS C
                                 ON C~WERKS = A~WERKS
                                AND C~MATNR = B~MATNR
           WHERE A~VBKZ = 'D' )
              AND D~MODULE_KIND = 'PP'
              AND D~CODEGRP = '3010'
            INTO TABLE @DATA(LT_CHK_DEL_AUTH).

          IF SY-SUBRC EQ 0.
            READ TABLE LT_CHK_DEL_AUTH INTO DATA(LS_CHK_DEL_AUTH) INDEX 1.
            MESSAGE S006(ZGTPP00) WITH TEXT-M01 LS_CHK_DEL_AUTH-FLD_02 TEXT-M02 DISPLAY LIKE 'E'.
            C_ERROR_FLG = 'X'.

          ENDIF.

        ENDIF.


    ENDCASE.

  ENDMETHOD.


  method IF_EX_WORKORDER_GOODSMVT~COGI_POST.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~COMPLETE_GOODSMOVEMENT.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~GM_SCREEN_LINE_CHECK.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~GM_SCREEN_OKCODE_CHECK.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~GM_WIPBATCH_CHECK.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~GM_WIPBATCH_PROPOSE.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~GOODS_RECEIPT.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~IM_CALLED.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~MANUAL_GOODS_RECEIPT.
  endmethod.


  method IF_EX_WORKORDER_GOODSMVT~PICKLIST.
  endmethod.
ENDCLASS.
