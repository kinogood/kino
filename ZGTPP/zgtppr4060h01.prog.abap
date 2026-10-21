*&---------------------------------------------------------------------*
*& Include          ZGTPPR4060H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HDL_USER_COMMAND  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF P_R1 EQ GC_X.
        IF P_RP EQ GC_X.
          CASE PV_UCOMM.
            WHEN 'PROC'.
              PERFORM PROCESS_P.      "실적 추출 및 수량 할당
          ENDCASE.
        ELSEIF P_RC EQ GC_X.
          CASE PV_UCOMM.
            WHEN 'GI'.
              PERFORM PROCESS_GI_C.    "투입 처리(정산자재)
          ENDCASE.
        ENDIF.
      ELSEIF P_R2 EQ GC_X.
        IF P_RP EQ GC_X.
          CASE PV_UCOMM.
            WHEN 'REGI'.
              PERFORM PROCESS_REGI.     "투입 재처리
            WHEN 'CANGI'.
              PERFORM PROCESS_CANGI.    "투입 처리 취소(포장재)
            WHEN 'CANPROC'.
              PERFORM PROCESS_CANPROC.  "실적 추출 및 수량 할당 취소
          ENDCASE.
        ELSEIF P_RC EQ GC_X.
          CASE PV_UCOMM.
            WHEN 'CANGI'.
              PERFORM PROCESS_CANGI_C.    "투입 처리 취소(정산자재)
          ENDCASE.
        ENDIF.
      ENDIF.

    WHEN GO_GRID_0101.
      IF P_R1 EQ GC_X AND P_RP EQ GC_X.
        CASE PV_UCOMM.
          WHEN 'GI'.
            PERFORM PROCESS_GI.         "투입 처리(포장재)
        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM HDL_TOOLBAR  USING    PO_SENDER
                           PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF P_R1 EQ GC_X.
        IF P_RP EQ GC_X.
          READ TABLE GT_PDATA INTO DATA(LS_PDATA) WITH KEY UP_STAT = ICON_LED_RED.
          IF SY-SUBRC NE 0.
            PERFORM SET_TOOLBAR
              TABLES PO_OBJECT->MT_TOOLBAR
               USING: 'PROC' SPACE TEXT-B01 TEXT-B01 SPACE 0. "실적 추출 및 수량 할당
          ENDIF.
        ELSEIF P_RC EQ GC_X.
          READ TABLE GT_CDATA INTO DATA(LS_CDATA) WITH KEY GI_STAT = ICON_LED_RED.
          IF SY-SUBRC NE 0.
            PERFORM SET_TOOLBAR
              TABLES PO_OBJECT->MT_TOOLBAR
               USING: 'GI' SPACE TEXT-B05 TEXT-B05 SPACE 0. "투입 처리
          ENDIF.
        ENDIF.
      ELSEIF P_R2 EQ GC_X.
        IF P_RP EQ GC_X.
          READ TABLE GT_REVDATA INTO DATA(LS_REVDATA) WITH KEY GI_STAT = ICON_LED_RED.
          IF SY-SUBRC NE 0.
            PERFORM SET_TOOLBAR
              TABLES PO_OBJECT->MT_TOOLBAR
               USING: 'REGI' SPACE TEXT-B02 TEXT-B02 SPACE 0, "투입 재처리
                      SPACE SPACE SPACE SPACE SPACE 3,
                      'CANGI' SPACE TEXT-B03 TEXT-B03 SPACE 0, "투입 처리 취소
                      SPACE SPACE SPACE SPACE SPACE 3,
                      'CANPROC' SPACE TEXT-B04 TEXT-B04 SPACE 0. "실적 추출 및 수량 할당 취소
          ENDIF.
        ELSEIF P_RC EQ GC_X.
          READ TABLE GT_CREVDATA INTO DATA(LS_CREVDATA) WITH KEY GI_STAT = ICON_LED_RED.
          IF SY-SUBRC NE 0.
            PERFORM SET_TOOLBAR
              TABLES PO_OBJECT->MT_TOOLBAR
               USING: 'CANGI' SPACE TEXT-B03 TEXT-B03 SPACE 0. "투입 처리 취소
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR
        TABLES PO_OBJECT->MT_TOOLBAR
         USING: 'GI' SPACE TEXT-B05 TEXT-B05 SPACE 0. "투입 처리
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HDL_DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW TYPE LVC_S_ROW
                                P_COLUMN TYPE LVC_S_COL.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      IF P_R1 EQ GC_X.
        IF P_RC EQ GC_X.
          READ TABLE GT_CDATA INTO DATA(LS_CDATA) INDEX P_ROW-INDEX.

          CASE P_COLUMN-FIELDNAME.
            WHEN 'AUFNR'.
              CHECK LS_CDATA-AUFNR IS NOT INITIAL.

              SET PARAMETER ID 'ANR' FIELD LS_CDATA-AUFNR.
              CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

            WHEN 'MBLNR'.
              CHECK LS_CDATA-MBLNR IS NOT INITIAL.

              CALL FUNCTION 'MIGO_DIALOG'
                EXPORTING
                  I_ACTION            = 'A04'
                  I_REFDOC            = 'R02'
                  I_MBLNR             = LS_CDATA-MBLNR
                  I_MJAHR             = LS_CDATA-MJAHR
                EXCEPTIONS
                  ILLEGAL_COMBINATION = 1
                  OTHERS              = 2.

          ENDCASE.

        ENDIF.
      ELSEIF P_R2 EQ GC_X.
        IF P_RP EQ GC_X.
          READ TABLE GT_REVDATA INTO DATA(LS_REV) INDEX P_ROW-INDEX.

          CASE P_COLUMN-FIELDNAME.
            WHEN 'AUFNR'.
              CHECK LS_REV-AUFNR IS NOT INITIAL.

              SET PARAMETER ID 'ANR' FIELD LS_REV-AUFNR.
              CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

            WHEN 'MBLNR'.
              CHECK LS_REV-MBLNR IS NOT INITIAL.

              CALL FUNCTION 'MIGO_DIALOG'
                EXPORTING
                  I_ACTION            = 'A04'
                  I_REFDOC            = 'R02'
                  I_MBLNR             = LS_REV-MBLNR
                  I_MJAHR             = LS_REV-MJAHR
                EXCEPTIONS
                  ILLEGAL_COMBINATION = 1
                  OTHERS              = 2.

          ENDCASE.

        ELSEIF P_RC EQ GC_X.
          READ TABLE GT_CREVDATA INTO DATA(LS_CREV) INDEX P_ROW-INDEX.

          CASE P_COLUMN-FIELDNAME.
            WHEN 'AUFNR'.
              CHECK LS_CREV-AUFNR IS NOT INITIAL.

              SET PARAMETER ID 'ANR' FIELD LS_CREV-AUFNR.
              CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

            WHEN 'MBLNR'.
              CHECK LS_CREV-MBLNR IS NOT INITIAL.

              CALL FUNCTION 'MIGO_DIALOG'
                EXPORTING
                  I_ACTION            = 'A04'
                  I_REFDOC            = 'R02'
                  I_MBLNR             = LS_CREV-MBLNR
                  I_MJAHR             = LS_CREV-MJAHR
                EXCEPTIONS
                  ILLEGAL_COMBINATION = 1
                  OTHERS              = 2.

          ENDCASE.

        ENDIF.
      ENDIF.

    WHEN GO_GRID_0101.
      IF P_R1 EQ GC_X AND P_RP EQ GC_X.
        READ TABLE GT_BOTTOM INTO DATA(LS_BTM) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'AUFNR'.
            CHECK LS_BTM-AUFNR IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_BTM-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          WHEN 'MBLNR'.
            CHECK LS_BTM-MBLNR IS NOT INITIAL.

            CALL FUNCTION 'MIGO_DIALOG'
              EXPORTING
                I_ACTION            = 'A04'
                I_REFDOC            = 'R02'
                I_MBLNR             = LS_BTM-MBLNR
                I_MJAHR             = LS_BTM-MJAHR
              EXCEPTIONS
                ILLEGAL_COMBINATION = 1
                OTHERS              = 2.

        ENDCASE.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM HDL_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                               PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA: LS_STR TYPE CHAR255.

  DATA: LV_SPMON TYPE STRING.

  CLEAR: LV_SPMON.
  LV_SPMON = P_SPMON+0(4) && |.| && P_SPMON+4(2).

  CLEAR: LS_STR.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF P_R1 EQ GC_X.
        IF P_RP EQ GC_X.
          CONCATENATE TEXT-T01 ':' TEXT-001 ' / '
                      TEXT-T02 ':' TEXT-003 ' / '
                      %_P_WERKS_%_APP_%-TEXT ':' P_WERKS ' / '
                      %_P_LGORT_%_APP_%-TEXT ':' P_LGORT ' / '
                      %_P_SPMON_%_APP_%-TEXT ':' LV_SPMON
                 INTO LS_STR SEPARATED BY SPACE.

        ELSEIF P_RC EQ GC_X.
          CONCATENATE TEXT-T01 ':' TEXT-001 ' / '
                      TEXT-T02 ':' TEXT-004 ' / '
                      %_P_WERKS_%_APP_%-TEXT ':' P_WERKS ' / '
                      %_P_LGORT_%_APP_%-TEXT ':' P_LGORT ' / '
                      %_P_SPMON_%_APP_%-TEXT ':' LV_SPMON
                 INTO LS_STR SEPARATED BY SPACE.

        ENDIF.

      ELSEIF P_R2 EQ GC_X.
        IF P_RP EQ GC_X.
          CONCATENATE TEXT-T01 ':' TEXT-002 ' / '
                      TEXT-T02 ':' TEXT-003 ' / '
                      %_P_WERKS_%_APP_%-TEXT ':' P_WERKS ' / '
                      %_P_LGORT_%_APP_%-TEXT ':' P_LGORT ' / '
                      %_P_SPMON_%_APP_%-TEXT ':' LV_SPMON
                 INTO LS_STR SEPARATED BY SPACE.

        ELSEIF P_RC EQ GC_X.
          CONCATENATE TEXT-T01 ':' TEXT-002 ' / '
                      TEXT-T02 ':' TEXT-004 ' / '
                      %_P_WERKS_%_APP_%-TEXT ':' P_WERKS ' / '
                      %_P_LGORT_%_APP_%-TEXT ':' P_LGORT ' / '
                      %_P_SPMON_%_APP_%-TEXT ':' LV_SPMON
                 INTO LS_STR SEPARATED BY SPACE.

        ENDIF.
      ENDIF.

      CALL METHOD PV_DYNDOC_ID->ADD_TEXT
        EXPORTING
          TEXT         = LS_STR
          SAP_STYLE    = PV_DYNDOC_ID->LIST_KEY_INV
          SAP_FONTSIZE = PV_DYNDOC_ID->MEDIUM.

      CALL METHOD PV_DYNDOC_ID->DISPLAY_DOCUMENT
        EXPORTING
          PARENT        = GO_CONTAIN_TOP_0100
          REUSE_CONTROL = GC_X.

  ENDCASE.
ENDFORM.
