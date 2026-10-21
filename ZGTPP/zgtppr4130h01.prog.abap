*&---------------------------------------------------------------------*
*& Include          ZGTPPR4130H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HDL_HOTSPOT_CLICK  USING   P_SENDER    TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW_ID    TYPE LVC_S_ROW
                                P_COLUMN_ID TYPE LVC_S_COL
                                PS_ROW_NO   TYPE LVC_S_ROID.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_DATA INTO DATA(LS_DATA) INDEX PS_ROW_NO-ROW_ID.

      CASE P_COLUMN_ID.
        WHEN 'CHARG' OR 'TAGNR'.
          CHECK LS_DATA-CHARG IS NOT INITIAL.

          CLEAR: GV_CHARG, GV_TAGNR.
          GV_CHARG = LS_DATA-CHARG.
          GV_TAGNR = LS_DATA-TAGNR.

          CLEAR: GT_MBLNR_H.
          SELECT DISTINCT
                 A~WERKS, A~LGORT, A~MATNR, A~BWART, A~STOCK_QTY, A~MEINS,
                 A~EBELN, A~EBELP, A~AUFNR, A~KDAUF, A~KDPOS, A~BUDAT,
                 A~CPUDT, A~CPUTM, A~USNAM, A~MBLNR, A~MJAHR, A~ZEILE
            FROM MATDOC AS A
           WHERE A~WERKS EQ @LS_DATA-WERKS
             AND A~MATNR EQ @LS_DATA-MATNR
             AND A~CHARG EQ @LS_DATA-CHARG
             AND A~CANCELLED EQ @SPACE
            INTO CORRESPONDING FIELDS OF TABLE @GT_MBLNR_H.

          LOOP AT GT_MBLNR_H ASSIGNING FIELD-SYMBOL(<FS_MBLNR_H>).
            "자재내역
            SELECT SINGLE MAKTX
              FROM MAKT
             WHERE MATNR EQ @<FS_MBLNR_H>-MATNR
               AND SPRAS EQ @SY-LANGU
              INTO @<FS_MBLNR_H>-MAKTX.

            "이동유형텍스트
            SELECT SINGLE BTEXT
              FROM T156T
             WHERE SPRAS EQ @SY-LANGU
               AND BWART EQ @<FS_MBLNR_H>-BWART
               AND SOBKZ EQ @SPACE
              INTO @<FS_MBLNR_H>-BTEXT.
          ENDLOOP.

          IF GT_MBLNR_H[] IS NOT INITIAL.
            SORT GT_MBLNR_H BY CPUDT CPUTM.
            PERFORM CRE_OBJ_POP_ALV.
          ELSE.
            MESSAGE S001.
          ENDIF.

      ENDCASE.

      CLEAR: LS_DATA.

  ENDCASE .

ENDFORM.
