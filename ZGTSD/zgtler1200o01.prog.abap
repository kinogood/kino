*----------------------------------------------------------------------*
***INCLUDE ZLER1200_O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  IF SY-TCODE = GC_TCODE2.
    GT_EXCL-FCODE = 'SEND'.  APPEND GT_EXCL.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EXCL.
  SET TITLEBAR  '0100' WITH GV_TITLE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID OUTPUT.

  IF GC_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_CONTAINER.

    PERFORM SET_GRID_LAYO1 CHANGING GS_LAYOUT1.
    PERFORM SET_GRID_LAYO2 CHANGING GS_LAYOUT2.
    PERFORM SET_GRID_LAYO3 CHANGING GS_LAYOUT3.
    PERFORM SET_GRID_LAYO4 CHANGING GS_LAYOUT4.

*___계약정보/수작업미지급전표금액 ALV 구성
    PERFORM SET_GRID_FCAT1 TABLES GT_FIELDCAT1.
    PERFORM SET_GRID_FCAT2 TABLES GT_FIELDCAT2.
    PERFORM SET_GRID_FCAT3 TABLES GT_FIELDCAT3.
    PERFORM SET_GRID_FCAT4 TABLES GT_FIELDCAT4.

    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM EXCLUDE_TB_FUNCTIONS_TWO CHANGING GT_EXCLUDE2.

*   Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER1.

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

    CASE GC_X.
      WHEN P_RAD1 OR P_RAD2.

      WHEN P_RAD3 OR P_RAD4.
*-  Preparing the table for sorting settings
        PERFORM PREPARE_SORT_TABLE CHANGING GT_SORT[].

    ENDCASE.

*   화면 display
    CASE GC_X.
      WHEN P_RAD1 OR P_RAD2.
        PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID1
                                                   '0001'
                                                   GS_LAYOUT1
                                                   GT_FIELDCAT1[]
                                                   GT_TOP_LEFT[]
                                                   GT_EXCLUDE.

      WHEN P_RAD3 OR P_RAD4.
        PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID1
                                                   '0001'
                                                   GS_LAYOUT1
                                                   GT_FIELDCAT1[]
                                                   GT_TOP_LEFT[]
                                                   GT_EXCLUDE2.

    ENDCASE.

    REFRESH GT_SORT.
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID2
                                               '0002'
                                               GS_LAYOUT2
                                               GT_FIELDCAT2[]
                                               GT_TOP_RIGHT[]
                                               GT_EXCLUDE.

    PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID3
                                               '0003'
                                               GS_LAYOUT3
                                               GT_FIELDCAT3[]
                                               GT_BOTTOM_LEFT[]
                                               GT_EXCLUDE.

    PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID4
                                               '0004'
                                               GS_LAYOUT4
                                               GT_FIELDCAT4[]
                                               GT_BOTTOM_RIGHT[]
                                               GT_EXCLUDE.

*    PERFORM SET_TABLE_FOR_FIRST_DISPLAY1 USING GC_ALV_GRID3 '0003'
*gs_layout3 gt_fieldcat3[] gt_vbap[].


    CASE GC_X.
      WHEN P_RAD1 OR P_RAD2.

        CALL METHOD GC_ALV_GRID1->SET_READY_FOR_INPUT
          EXPORTING
            I_READY_FOR_INPUT = 1.

      WHEN P_RAD3 OR P_RAD4.

        CALL METHOD GC_ALV_GRID1->SET_READY_FOR_INPUT
          EXPORTING
            I_READY_FOR_INPUT = 1.

        CALL METHOD GC_ALV_GRID4->SET_READY_FOR_INPUT
          EXPORTING
            I_READY_FOR_INPUT = 1.

*-  Preparing the table for sorting settings
        PERFORM PREPARE_SORT_TABLE CHANGING GT_SORT[].

    ENDCASE.

  ENDIF.

ENDMODULE.                 " CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING P_LT_COLOR.



ENDFORM.                    " FILL_COLOR
