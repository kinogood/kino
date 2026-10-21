*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010C01
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.

TYPE-POOLS: SLIS.

DATA: GRID1    TYPE REF TO CL_GUI_ALV_GRID,
      GRID2    TYPE REF TO CL_GUI_ALV_GRID,
      GRID3    TYPE REF TO CL_GUI_ALV_GRID,
      GRID4    TYPE REF TO CL_GUI_ALV_GRID,
      GRID5    TYPE REF TO CL_GUI_ALV_GRID,
      GRID6    TYPE REF TO CL_GUI_ALV_GRID,

      GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID1 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID3 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID4 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID5 TYPE REF TO CL_GUI_ALV_GRID,

      GO_CCON1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON3 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON4 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON5 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

      GO_DCON1 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON2 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON3 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON4 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON5 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON  TYPE REF TO CL_GUI_DOCKING_CONTAINER,

      GO_GCON1 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON2 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON3 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON4 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON5 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON6 TYPE REF TO CL_GUI_CONTAINER.

DATA: GO_ALV_TITLE1 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE2 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE3 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE4 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE  TYPE REF TO CL_DD_DOCUMENT.
DATA: GO_HTML       TYPE REF TO CL_GUI_HTML_VIEWER.

DATA: GO_SPLITTER1 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER2 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER3 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER4 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER  TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
*      GO_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

DATA: GO_TREE   TYPE REF TO CL_GUI_COLUMN_TREE.

DATA: FIELDCAT     TYPE LVC_S_FCAT OCCURS 0 WITH HEADER LINE,
      GT_FIELDCAT  TYPE LVC_T_FCAT,
      GT_FIELDCAT1 TYPE LVC_T_FCAT,
      GT_FIELDCAT2 TYPE LVC_T_FCAT,
      GT_FIELDCAT3 TYPE LVC_T_FCAT,
      GT_FIELDCAT4 TYPE LVC_T_FCAT,
      GT_FIELDCAT5 TYPE LVC_T_FCAT,
      GS_FIELDCAT  TYPE LVC_S_FCAT,
      GT_SORT      TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT1     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT2     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT3     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT4     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT5     TYPE LVC_T_SORT WITH HEADER LINE,
      GS_SORT      TYPE LVC_S_SORT,
      GT_FILTER    TYPE LVC_T_FILT,
      GS_FILTER    TYPE LVC_S_FILT,
      GT_ALV_F4    TYPE LVC_T_F4,
      GS_ALV_F4    TYPE LVC_S_F4,
      GT_F4        TYPE LVC_T_F4,
      GS_F4        TYPE LVC_S_F4,
      GS_LAYOUT    TYPE LVC_S_LAYO,
      GS_LAYOUT1   TYPE LVC_S_LAYO,
      GS_LAYOUT2   TYPE LVC_S_LAYO,
      GS_LAYOUT3   TYPE LVC_S_LAYO,
      GS_LAYOUT4   TYPE LVC_S_LAYO,
      GS_LAYOUT5   TYPE LVC_S_LAYO,
      GS_VARIANT   TYPE DISVARIANT,
      GS_VARIANT1  TYPE DISVARIANT,
      GS_VARIANT2  TYPE DISVARIANT,
      GS_VARIANT3  TYPE DISVARIANT,
      GS_VARIANT4  TYPE DISVARIANT,
      GS_VARIANT5  TYPE DISVARIANT,
      GV_COL_POS   TYPE I.

DATA: GT_COLOR TYPE LVC_T_SCOL,
      GS_COLOR TYPE LVC_S_SCOL,
      GS_COL   TYPE LVC_S_COLO.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GT_EXCLUDE1 TYPE UI_FUNCTIONS,
      GT_EXCLUDE2 TYPE UI_FUNCTIONS,
      GT_EXCLUDE3 TYPE UI_FUNCTIONS,
      GT_EXCLUDE4 TYPE UI_FUNCTIONS,
      GT_EXCLUDE5 TYPE UI_FUNCTIONS.

DATA: BEGIN OF GT_EXCLU OCCURS 0,
        FCODE LIKE SY-UCOMM,
      END OF GT_EXCLU.

DATA: BEGIN OF GT_EXCLU2 OCCURS 0,
        FCODE LIKE SY-UCOMM,
      END OF GT_EXCLU2.

DATA: GT_INDEX_ROWS TYPE LVC_T_ROW,
      GT_ROWS       TYPE LVC_T_ROW,
      GT_ROW_NO     TYPE LVC_T_ROID,
      GS_INDEX_ROWS TYPE LVC_S_ROW,
      GS_ROWS       TYPE LVC_S_ROW,
      GS_ROW_NO     TYPE LVC_S_ROID.

TYPES: BEGIN OF TY_ROW,
         ROW    TYPE I,
         VALUE  TYPE C,
         COL    TYPE I,
         ROW_ID TYPE LVC_S_ROW,
         COL_ID TYPE LVC_S_COL,
         ROW_NO TYPE LVC_S_ROID,
       END OF TY_ROW.

TYPES: BEGIN OF TY_SCROLL,
         ROW_INFO TYPE LVC_S_ROW,
         COL_INFO TYPE LVC_S_COL,
         ROW_NO   TYPE LVC_S_ROID,
       END OF TY_SCROLL.

DATA: GS_V_ROW    TYPE TY_ROW,
      GS_V_SCROLL TYPE TY_SCROLL.

DATA: GT_FIELDS TYPE TABLE OF HELP_VALUE WITH HEADER LINE.

DATA: GV_SVALUE LIKE HELP_INFO-FLDVALUE,
      GV_SFIELD LIKE HELP_INFO-FIELDNAME.

*DATA: GV_REPID        LIKE SY-REPID.
DATA: GV_CPROG        LIKE SY-CPROG,
      GS_VARIANTE     LIKE DISVARIANT,
      GS_DEF_VARIANT  LIKE DISVARIANT,
      GV_VARIANT_EXIT TYPE C.

DATA: GO_ALV_EVT TYPE REF TO CL_GUI_EVENT,
      GO_ALV_OBJ TYPE REF TO CL_GUI_ALV_GRID,
      GO_GUI_OBJ TYPE REF TO CL_GUI_CONTROL.

DATA: GV_GRID_TITLE  TYPE LVC_TITLE,
      GV_GRID_TITLE1 TYPE LVC_TITLE,
      GV_GRID_TITLE2 TYPE LVC_TITLE,
      GV_GRID_TITLE3 TYPE LVC_TITLE.

DATA: GO_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_HANDLER.
*      GO_EVENT_RECEIVER_ALV  TYPE REF TO LCL_EVENT_HANDLER_ALV.

DATA: GT_NODE      TYPE STANDARD TABLE OF TREEV_NODE,
      GT_NODE_ITEM TYPE STANDARD TABLE OF MTREEITM,
      GS_NODE      TYPE TREEV_NODE,
      GS_NODE_ITEM TYPE MTREEITM.


*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.

    METHODS: HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED
                E_ONF4_AFTER
                SENDER.

    METHODS: HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO
                SENDER.

    METHODS: HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                SENDER.

    METHODS: HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS: HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM
                SENDER.

    METHODS: HANDLE_ONF4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY
                SENDER.

    METHODS: HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID
                SENDER.

    METHODS: HANDLE_MENU_BUTTON
      FOR EVENT MENU_BUTTON OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_UCOMM
                SENDER.

    METHODS: HANDLE_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS
                SENDER.

    METHODS HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO
                SENDER.

  PRIVATE SECTION.

ENDCLASS.                    "LCL_EVENT_HANDLER_ALV DEFINITION
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD HANDLE_DATA_CHANGED.
    PERFORM ALV_DATA_CHANGED USING ER_DATA_CHANGED
                                   E_ONF4_AFTER
                                   SENDER.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_CHANGED_FINISHED.
    PERFORM ALV_CHANGED_FINISHED USING E_MODIFIED
                                       ET_GOOD_CELLS
                                       SENDER.
  ENDMETHOD.                    "HANDLE_CHANGED_FINISHED

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM ALV_DOUBLE_CLICK USING E_ROW
                                   E_COLUMN
                                   ES_ROW_NO
                                   SENDER.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_HOTSPOT_CLICK.
*    PERFORM ALV_HOTSPOT_CLICK USING E_ROW_ID
*                                    E_COLUMN_ID
*                                    SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM ALV_TOOLBAR USING E_OBJECT
                              E_INTERACTIVE
                              SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM ALV_USER_COMMAND USING E_UCOMM
                                   SENDER.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_ONF4.
*    PERFORM ALV_ONF4 USING E_FIELDNAME
*                           E_FIELDVALUE
*                           ES_ROW_NO
*                           ER_EVENT_DATA
*                           ET_BAD_CELLS
*                           E_DISPLAY
*                           SENDER.


  ENDMETHOD.                    "HANDLE_ONF4

  METHOD HANDLE_TOP_OF_PAGE.
*    PERFORM ALV_TOP_OF_PAGE USING E_DYNDOC_ID
*                                  SENDER.
  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

  METHOD HANDLE_MENU_BUTTON.
*    PERFORM ALV_MENU_BUTTON USING E_OBJECT
*                                  E_UCOMM
*                                  SENDER.
  ENDMETHOD.                    "HANDLE_MENU_BUTTON

  METHOD HANDLE_BUTTON_CLICK.
    PERFORM ALV_BUTTON_CLICK USING ES_COL_ID
                                   ES_ROW_NO
                                   SENDER.
  ENDMETHOD.



ENDCLASS.                    "LCL_EVENT_HANDLER_ALV IMPLEMENTATION
*&---------------------------------------------------------------------*
*& Form ALV_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4_AFTER
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_DATA_CHANGED  USING    PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4_AFTER
                                PV_SENDER.

  FIELD-SYMBOLS:<FS_VALUE> TYPE ANY.

  CASE PV_SENDER.
    WHEN GO_GRID.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
        IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
        ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_0100 TO <FS_VALUE>.
        CHECK SY-SUBRC EQ 0.

        CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
          IMPORTING
            E_VALUE     = <FS_VALUE>.

        CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            I_VALUE     = <FS_VALUE>.
      ENDLOOP.
    WHEN GO_GRID1.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
        ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_0200 TO <FS_VALUE>.
        CHECK SY-SUBRC EQ 0.

        CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
          IMPORTING
            E_VALUE     = <FS_VALUE>.

        CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            I_VALUE     = <FS_VALUE>.
      ENDLOOP.

    WHEN GO_GRID2.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
        ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_0210 TO <FS_VALUE>.
        CHECK SY-SUBRC EQ 0.

        CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
          IMPORTING
            E_VALUE     = <FS_VALUE>.

        CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            I_VALUE     = <FS_VALUE>.
      ENDLOOP.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                    PT_GOOD_CELLS TYPE LVC_T_MODI
                                    PV_SENDER.

  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.

  CHECK PV_MODIFIED IS NOT INITIAL.

  CASE PV_SENDER.
    WHEN GO_GRID.  "MAIN 화면(0100)
      PERFORM REFRESH_ALV USING GO_GRID.

    WHEN GO_GRID1. "적송지정 ITEM(0200 TOP)
      PERFORM ALV_CHANGE_FINISHED_0200 USING PT_GOOD_CELLS.

    WHEN GO_GRID2. "적송지정 ITEM DETAIL(0200 BOTTOM)
      PERFORM ALV_CHANGE_FINISHED_0210 USING PT_GOOD_CELLS.
      PERFORM REFRESH_ALV USING GO_GRID2.

    WHEN OTHERS.

  ENDCASE.
  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_BUTTON_CLICK  USING    PS_COL_ID TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID
                                PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID.
      PERFORM BUTTON_CLICK_0100 USING PS_COL_ID
                                      PS_ROW_NO.

    WHEN OTHERS.



  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUTTON_CLICK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_COL_ID
*&      --> PS_ROW_NO
*&---------------------------------------------------------------------*
FORM BUTTON_CLICK_0100  USING   PS_COL_ID TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID.

  DATA: LV_CBO(1).
  DATA: LV_TAB_H TYPE TABNAME,
        LV_TAB_I TYPE TABNAME.
  DATA: LV_LENGTH_VRKME TYPE LFIMG.

  CHECK PS_COL_ID-FIELDNAME EQ 'BUTN'.

  CLEAR:ZGTSDS0020,GT_0200[],GT_0210[],GT_0210_LIST[],GT_LIKP[],GT_LIPS[].

  CLEAR GS_0100.
  READ TABLE GT_0100 INTO GS_0100 INDEX PS_ROW_NO-ROW_ID.

*-01. ZGTSDT9110 존재여부
  SELECT SINGLE VBELN
    FROM ZGTSDT9110
   WHERE VBELN EQ @GS_0100-VBELN_VL
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_VBELN).
  IF SY-SUBRC EQ 0.
    LV_TAB_H = 'ZGTSDT9110'.
    LV_TAB_I = 'ZGTSDT9120'.
    LV_CBO   = GC_X.
  ELSE.
    LV_TAB_H = 'LIKP'.
    LV_TAB_I = 'LIPS'.
    CLEAR LV_CBO.
  ENDIF.

*-02. GET 납품 데이터
  "LIKP
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIKP
    FROM (LV_TAB_H)
   WHERE VBELN EQ @GS_0100-VBELN_VL.

  "LIPS
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIPS
    FROM (LV_TAB_I)
   WHERE VBELN EQ @GS_0100-VBELN_VL.

*-03. DBS : 원처 데이터 저장
  IF LV_CBO NE GC_X.
    "DBS 상태 지정
    GT_LIKP[ 1 ]-ZZJS_STATUS = GC_A.
    CLEAR:GV_ERROR.
    PERFORM SAVE_DO_INFO USING PS_ROW_NO.
    PERFORM REFRESH_ALV USING GO_GRID.
    IF GV_ERROR IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDIF.


*-04. HEADER 구성
  DATA(LS_HEAD) = VALUE #( GT_LIKP[ 1 ] OPTIONAL ).
  MOVE-CORRESPONDING LS_HEAD TO ZGTSDS0020.
  ZGTSDS0020-KUNNR = LS_HEAD-KUNAG.
  ZGTSDS0020-KUNWE = LS_HEAD-KUNNR.
  DATA(LS_ITEM) = VALUE #( GT_LIPS[ 1 ] OPTIONAL ).
  MOVE-CORRESPONDING LS_ITEM TO ZGTSDS0020.

  "당월매출일 일자 지정
  PERFORM SET_FKDAT_M.

  SELECT SINGLE AUART,BSTNK
    INTO CORRESPONDING FIELDS OF @ZGTSDS0020
    FROM VBAK
   WHERE VBELN EQ @LS_ITEM-VGBEL.
  "SET TEXT FILED
  PERFORM SET_HTEXT_FIELDS.

  "LOCK CHECK 'ZGTSDT9110' => 상태가 원처데이터저장(DBS) 이하인 경우만 대상
  IF ZGTSDS0020-ZZJS_STATUS <= GC_A.
    PERFORM SET_LOCK_OBJECT20    USING ZGTSDS0020-VBELN
                              CHANGING ZGTSDS0020-LOCK.
  ENDIF.

*-05. ITEM 구성
  DATA(LT_BASE) = GT_LIPS[].
  DELETE LT_BASE WHERE UECHA NE '000000'.
  SORT LT_BASE BY POSNR.

  "SO ITEM
  SELECT *
    FROM VBAP
     FOR ALL ENTRIES IN @LT_BASE
   WHERE VBELN EQ @LT_BASE-VGBEL
    INTO TABLE @DATA(LT_VBAP).

  DATA:LV_CHK1(1).

  LOOP AT LT_BASE INTO DATA(LS_BASE).
    CLEAR:GS_0200,LV_CHK1.

*   ITEM 라인
    GS_0200-VBELN            = LS_BASE-VBELN.
    GS_0200-POSNR            = LS_BASE-POSNR.
    GS_0200-MATNR            = LS_BASE-MATNR.
    GS_0200-WAERK            = LS_HEAD-WAERK.
    GS_0200-VGBEL            = LS_BASE-VGBEL.
    GS_0200-VGPOS            = LS_BASE-VGPOS.
    GS_0200-ZZJS_MVT         = LS_BASE-ZZJS_MVT.
    GS_0200-ZZJS_ASN_STS_I   = LS_BASE-ZZJS_ASN_STS_I.
    GS_0200-MILLCA_FACTOR_M  = LS_BASE-MILLCA_FACTOR_M.
    GS_0200-MILLCA_FACTOR_JS = LS_BASE-MILLCA_FACTOR_JS.
    GS_0200-VRKME            = LS_BASE-VRKME.
    GS_0200-NETPR            = VALUE #( LT_VBAP[ POSNR = GS_0200-VGPOS ]-NETPR OPTIONAL ).

    "조장
    CLEAR:LV_LENGTH_VRKME.
    PERFORM GET_SAP_LENGTH_VRKME    USING GS_0200-VGBEL GS_0200-VGPOS
                                 CHANGING LV_LENGTH_VRKME.
    GS_0200-LENGTH_JS        = LV_LENGTH_VRKME.

    "적송지정 상태
    CASE GS_0200-ZZJS_ASN_STS_I.
      WHEN GC_C.
        GS_0200-ST_STSI = ICON_LED_GREEN.
      WHEN OTHERS.
        GS_0200-ST_STSI = ICON_LED_YELLOW.
    ENDCASE.

*---ITEM 세부라인 구성
    PERFORM SET_ITEM_DETAILS CHANGING GS_0200.

*   ITEM 라인 APPEND
    APPEND GS_0200 TO GT_0200.

  ENDLOOP.
  SORT GT_0200 BY POSNR.

*-OUTPUT LIST 구성
  "ITEM LINE 첫번째 항목 선택
*  READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) INDEX 1.
*  CHECK SY-SUBRC EQ 0.
*  <FS_0200>-SEL = GC_X.

  "ITEM 세부라인
  CLEAR:GT_0210[].
*  DELETE GT_0210_LIST WHERE POSNR NE <FS_0200>-POSNR.
*  APPEND LINES OF GT_0210_LIST TO GT_0210.
*  SORT GT_0210 BY POSNR POSNR_B.

  CALL SCREEN 200.




*    "배치 SPLIT 체크
*    IF LINE_EXISTS( GT_LIPS[ VBELN = LS_BASE-VBELN UECHA = LS_BASE-POSNR ] ).
*      LV_CHK1 = GC_X.
*    ENDIF.
*
**   ITEM 상세라인(당월처리)
*    "BATCH SPLIT
*    IF LV_CHK1 EQ GC_X.
*      LOOP AT GT_LIPS INTO DATA(LS_LIPS) WHERE VBELN = LS_BASE-VBELN
*                                           AND UECHA = LS_BASE-POSNR.
*        CLEAR GS_0210.
*        GS_0210-POSNR            = LS_BASE-POSNR.
*        GS_0210-POSNR_B          = LS_LIPS-POSNR.
*        GS_0210-MATNR            = LS_LIPS-MATNR.
*        GS_0210-CHARG            = LS_LIPS-CHARG.
*        GS_0210-VRKME            = LS_LIPS-VRKME.
*        "최초수량
*        GS_0210-LFIMG            = LS_LIPS-LFIMG.
*        "단가
*        GS_0210-NETPR            = GS_0200-NETPR.
*        GS_0210-WAERK            = GS_0200-WAERK.
*
*        GS_0210-ZZJS_MVT         = LS_LIPS-ZZJS_MVT.        "적송창고 이동 지시자
*        GS_0210-ZZJS_ASN_STS_I   = LS_LIPS-ZZJS_ASN_STS_I.  "적송지정상태
*        GS_0210-MILLCA_FACTOR_M  = LS_LIPS-MILLCA_FACTOR_M. "당월조장수
*        GS_0210-MILLCA_FACTOR_JS = LS_LIPS-MILLCA_FACTOR_JS."적송조장수
*
*        "조장
*        GS_0210-LENGTH_JS = GS_0200-LENGTH_JS.
*
*        "최초조장수 : 최초수량 / 조장
*        IF GS_0210-LENGTH_JS NE 0.
*          GS_0210-FACTOR_I = GS_0210-LFIMG / GS_0210-LENGTH_JS.
*        ENDIF.
*
*        "적송조장수
*        GS_0210-FACTOR_JS  = LS_LIPS-MILLCA_FACTOR_JS.
*
*        "당월조장수: 최초조장수 - 적송조장수
*        GS_0210-FACTOR_M   = GS_0210-FACTOR_I - GS_0210-FACTOR_JS.
*
*        "당월수량 : 당월조장수 * 조장
*        GS_0210-LFIMG_M     = GS_0210-FACTOR_M * GS_0210-LENGTH_JS.
*
*        "당월금액 : 당월수량 * 단가
*        GS_0210-NETWR_DW    = GS_0210-FACTOR_M * GS_0210-NETPR.
*
*        "적송수량 : 적송조장수 * 조장
*        GS_0210-LFIMG_JS    = GS_0210-FACTOR_JS * GS_0210-LENGTH_JS.
*
*        "적송금액 : 적송수량 * 단가
*        GS_0210-NETWR_JS    = GS_0210-LFIMG_JS * GS_0210-NETPR.
*
*
*
*        APPEND GS_0210 TO GT_0210_LIST.
*
*        "ITEM 라인 의 최초수량    : ITEM 상세라인의 SUM
*        GS_0200-LFIMG  = GS_0200-LFIMG + GS_0210-LFIMG.
*        "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
*        GS_0200-FACTOR_M = GS_0200-FACTOR_M + GS_0210-FACTOR_M.
*        "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
*        GS_0200-FACTOR_JS = GS_0200-FACTOR_JS + GS_0210-FACTOR_JS.
*      ENDLOOP.
*
*
*    ELSE.
*      LOOP AT GT_LIPS INTO LS_LIPS WHERE VBELN = LS_BASE-VBELN
*                                     AND POSNR = LS_BASE-POSNR.
*        CLEAR GS_0210.
*        GS_0210-POSNR            = LS_BASE-POSNR.
**        GS_0210-POSNR_B          = LS_LIPS-POSNR.
*        GS_0210-MATNR            = LS_LIPS-MATNR.
*        GS_0210-CHARG            = LS_LIPS-CHARG.
*        GS_0210-VRKME            = LS_LIPS-VRKME.
*        "최초수량
*        GS_0210-LFIMG            = LS_LIPS-LFIMG.
*        "단가
*        GS_0210-NETPR            = GS_0200-NETPR.
*        GS_0210-WAERK            = GS_0200-WAERK.
*
*        GS_0210-ZZJS_MVT         = LS_LIPS-ZZJS_MVT.        "적송창고 이동 지시자
*        GS_0210-ZZJS_ASN_STS_I   = LS_LIPS-ZZJS_ASN_STS_I.  "적송지정상태
*        GS_0210-MILLCA_FACTOR_M  = LS_LIPS-MILLCA_FACTOR_M. "당월조장수
*        GS_0210-MILLCA_FACTOR_JS = LS_LIPS-MILLCA_FACTOR_JS."적송조장수
*
*        "조장
*        GS_0210-LENGTH_JS = GS_0200-LENGTH_JS.
*
*        "최초조장수 : 최초수량 / 조장
*        IF GS_0210-LENGTH_JS NE 0.
*          GS_0210-FACTOR_I = GS_0210-LFIMG / GS_0210-LENGTH_JS.
*        ENDIF.
*
*
*
*        "적송조장수
*        GS_0210-FACTOR_JS  = LS_LIPS-MILLCA_FACTOR_JS.
*
*        "당월조장수: 최초조장수 - 적송조장수
*        GS_0210-FACTOR_M   = GS_0210-FACTOR_I - GS_0210-FACTOR_JS.
*
*        "당월수량 : 당월조장수 * 조장
*        GS_0210-LFIMG_M     = GS_0210-FACTOR_M * GS_0210-LENGTH_JS.
*
*        "당월금액 : 당월수량 * 단가
*        GS_0210-NETWR_DW    = GS_0210-FACTOR_M * GS_0210-NETPR.
*
*        "적송수량 : 적송조장수 * 조장
*        GS_0210-LFIMG_JS    = GS_0210-FACTOR_JS * GS_0210-LENGTH_JS.
*
*        "적송금액 : 적송수량 * 단가
*        GS_0210-NETWR_JS    = GS_0210-LFIMG_JS * GS_0210-NETPR.
*
*
*
*        APPEND GS_0210 TO GT_0210_LIST.
*
*        "ITEM 라인 의 최초수량    : ITEM 상세라인의 SUM
*        GS_0200-LFIMG  = GS_0200-LFIMG + GS_0210-LFIMG.
*        "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
*        GS_0200-FACTOR_M = GS_0200-FACTOR_M + GS_0210-FACTOR_M.
*        "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
*        GS_0200-FACTOR_JS = GS_0200-FACTOR_JS + GS_0210-FACTOR_JS.
*      ENDLOOP.
*    ENDIF.
*
*    "저장위치
*    GS_0200-LGORT = LS_LIPS-LGORT.
*    GS_0200-LGOBE = ZGTSD_CL_COMMON2=>GET_LGORT_TEXT( IV_WERKS = LS_LIPS-WERKS
*                                                      IV_LGORT = LS_LIPS-LGORT ).
*
*    "당월수량 : 당월조장수 * 조장
*    GS_0200-LFIMG_M  = GS_0200-FACTOR_M * GS_0200-LENGTH_JS.
*    "적송수량 : 적송조장수 * 조장
*    GS_0200-LFIMG_JS = GS_0200-FACTOR_JS * GS_0200-LENGTH_JS.
*    "최초금액 :최초수량 * 단가
*    GS_0200-NETWR_INI = GS_0200-LFIMG * GS_0200-NETPR.
*    "당월금액 : 당월수량 * 단가
*    GS_0200-NETWR_DW  = GS_0200-LFIMG_M * GS_0200-NETPR.
*    "적송금액 : 적송수량 * 단가
*    GS_0200-NETWR_JS  = GS_0200-LFIMG_JS * GS_0200-NETPR.
*
**   ITEM 라인 APPEND
*    APPEND GS_0200 TO GT_0200.
*  ENDLOOP.

*  CALL SCREEN 200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGE_FINISHED_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM ALV_CHANGE_FINISHED_0200  USING PT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.
  DATA: LS_0200_BF LIKE GT_0200.
  DATA: LV_CHECKED(1).

  LT_MODI[] = PT_GOOD_CELLS[].
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.
  LS_MODI = VALUE #( LT_MODI[ 1 ] OPTIONAL ).
  CHECK LS_MODI IS NOT INITIAL.

  READ TABLE GT_0200 INTO GS_0200 INDEX LS_MODI-ROW_ID.
  CHECK SY-SUBRC EQ 0.

  CLEAR: GT_0210_CLER[],GT_0210_LIST[].

  IF GS_0200-SEL EQ GC_X. "라인 선택
    LV_CHECKED = GC_X.
  ELSE.
    "라인선택 해제
    MOVE-CORRESPONDING GS_0200 TO LS_0200_BF.
    DELETE GT_0210 WHERE POSNR EQ GS_0200-POSNR.
  ENDIF.

*----------------------------------------------------------
*-ITEM 세부라인(GT_0210) 구성 : 선택 ITEM(GT_0200)에 대하여 ITEM DETAIL(GT_0210)을 구성한다.
*----------------------------------------------------------
  IF LV_CHECKED EQ GC_X.
    "ITEM 라인(TOP) : 최초조장수/당월조장수/적송조장수 CLEAR
    PERFORM CLEAR_ITEM_FIELDS CHANGING GS_0200.
    PERFORM SET_ITEM_DETAILS  CHANGING GS_0200.

    APPEND LINES OF GT_0210_LIST TO GT_0210.
    SORT GT_0210 BY POSNR POSNR_B.
  ENDIF.

* ITEM 세부라인 입력필드 제어
  LOOP AT GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>).
    PERFORM SET_ATTRIBUTES_LINE_0210 CHANGING <FS_0210>.
  ENDLOOP.

*----------------------------------------------------------
* ITEM(GT_0200) 선택 해제시 ITEM 라인 재계산
*   => 적송조장수 변경 후 적송지정하지 않는 경우 고려(원복)
*----------------------------------------------------------
  IF LS_0200_BF IS NOT INITIAL.
    CLEAR: GT_0210_LIST[].
    PERFORM CLEAR_ITEM_FIELDS CHANGING LS_0200_BF.
    PERFORM SET_ITEM_DETAILS  CHANGING LS_0200_BF.
    READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200_TMP>) WITH KEY POSNR = LS_0200_BF-POSNR.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_0200_BF TO <FS_0200_TMP>.
    ENDIF.
  ENDIF.


  PERFORM REFRESH_ALV USING GO_GRID1. "ITEM 라인(TOP)
  PERFORM REFRESH_ALV USING GO_GRID2. "ITEM 세부라인(BOTTOM)

*---------------------------------------------------------------
**----------------------------------------------------------
** ITEM 라인 이전 선택한 선택라인 CLEAR
**----------------------------------------------------------
*  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>).
*    DATA(LV_INDEX) = SY-TABIX.
*    IF LV_INDEX NE LS_MODI-ROW_ID.
*      IF <FS_0200>-SEL EQ GC_X.
*        CLEAR <FS_0200>-SEL.
*        "아래 이전선택라인 재계산을 위해 사용
*        MOVE-CORRESPONDING <FS_0200> TO LS_0200_BF.
*      ELSE.
*        CLEAR <FS_0200>-SEL.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*
*  READ TABLE GT_0200 INTO GS_0200 INDEX LS_MODI-ROW_ID.
*  CHECK SY-SUBRC EQ 0.
*
**----------------------------------------------------------
**-ITEM 세부라인 구성
**----------------------------------------------------------
*  CLEAR: GT_0210_LIST[],GT_0210[].
*  "ITEM 라인(TOP) : 최초조장수/당월조장수/적송조장수 CLEAR
*  PERFORM CLEAR_ITEM_FIELDS CHANGING GS_0200.
*  PERFORM SET_ITEM_DETAILS CHANGING GS_0200.
*
*  APPEND LINES OF GT_0210_LIST TO GT_0210.
*  SORT GT_0210 BY POSNR POSNR_B.
*
** ITEM 세부라인 입력필드 제어
*  LOOP AT GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>).
*    PERFORM SET_ATTRIBUTES_LINE_0210 CHANGING <FS_0210>.
*  ENDLOOP.

**----------------------------------------------------------
** 이전 선택라인 재계산 => 적송조장수 변경 후 적송지정하지 않는 경우 고려
**----------------------------------------------------------
*  IF LS_0200_BF IS NOT INITIAL.
*    CLEAR: GT_0210_LIST[].
*    PERFORM CLEAR_ITEM_FIELDS CHANGING LS_0200_BF.
*    PERFORM SET_ITEM_DETAILS CHANGING LS_0200_BF.
*    READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200_TMP>) WITH KEY POSNR = LS_0200_BF-POSNR.
*    IF SY-SUBRC EQ 0.
*      MOVE-CORRESPONDING LS_0200_BF TO <FS_0200_TMP>.
*    ENDIF.
*  ENDIF.
*
*  PERFORM REFRESH_ALV USING GO_GRID1. "ITEM 라인(TOP)
*  PERFORM REFRESH_ALV USING GO_GRID2. "ITEM 세부라인(BOTTOM)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGE_FINISHED_0210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM ALV_CHANGE_FINISHED_0210  USING    PT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.

  LT_MODI[] = PT_GOOD_CELLS[].
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.

  LOOP AT LT_MODI INTO LS_MODI.
    READ TABLE GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>) INDEX LS_MODI-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "CHECK
    CLEAR:<FS_0210>-RSLT,<FS_0210>-ST_STSD.
    PERFORM CHECK_CHANGED_LINE_0210 CHANGING <FS_0210>.
    CHECK <FS_0210>-RSLT NE GC_E.

    PERFORM SET_ITEM_DETAILS_CHANGED CHANGING <FS_0210>.

*---[CHG]----S  2026.03.11
    "ITEM LINE
    READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WITH KEY POSNR = <FS_0210>-POSNR.
    IF SY-SUBRC EQ 0.
      PERFORM SET_ITEM_LINE_VALUE CHANGING <FS_0200>.
    ENDIF..
*---[CHG]----E  2026.03.11
  ENDLOOP.

*  "ITEM LINE
*  READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_200>) WITH KEY SEL = GC_X.
*
*  "ITEM LINE FIELD VALUE 계산
*  CLEAR:<FS_200>-FACTOR_M,<FS_200>-FACTOR_JS.
*  LOOP AT GT_0210 INTO GS_0210.
*    "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
*    <FS_200>-FACTOR_M  = <FS_200>-FACTOR_M + GS_0210-FACTOR_M.
*    "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
*    <FS_200>-FACTOR_JS = <FS_200>-FACTOR_JS + GS_0210-FACTOR_JS.
*  ENDLOOP.
*
*  "당월수량 : 당월조장수 * 조장
*  <FS_200>-LFIMG_M   = <FS_200>-FACTOR_M * <FS_200>-LENGTH_JS.
*  "적송수량 : 적송조장수 * 조장
*  <FS_200>-LFIMG_JS  = <FS_200>-FACTOR_JS * <FS_200>-LENGTH_JS.
*  "최초금액 :최초수량 * 단가
*  <FS_200>-NETWR_INI = <FS_200>-LFIMG * <FS_200>-NETPR.
*  "당월금액 : 당월수량 * 단가
*  <FS_200>-NETWR_DW  = <FS_200>-LFIMG_M * <FS_200>-NETPR.
*  "적송금액 : 적송수량 * 단가
*  <FS_200>-NETWR_JS  = <FS_200>-LFIMG_JS * <FS_200>-NETPR.
*
  PERFORM REFRESH_ALV USING GO_GRID1.
  PERFORM REFRESH_ALV USING GO_GRID2.

  IF LINE_EXISTS( GT_0210[ RSLT = GC_E ] ).
    DATA(LV_MSG) = VALUE #( GT_0210[ RSLT = GC_E ]-MESSAGE OPTIONAL ).
    MESSAGE S000 WITH LV_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_LINE_0210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0210>
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_LINE_0210  CHANGING PS_0210 LIKE GT_0210.

  "적송조장수 > 최초조장수 => 에러
  IF PS_0210-FACTOR_I < PS_0210-FACTOR_JS.
    PS_0210-RSLT    = GC_E.
    PS_0210-ST_STSD = ICON_LED_RED.
    PS_0210-MESSAGE = TEXT-M02.
    EXIT.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_DETAILS_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0210>
*&---------------------------------------------------------------------*
FORM SET_ITEM_DETAILS_CHANGED  CHANGING PS_0210 LIKE GT_0210.

  "당월조장수: 최초조장수 - 적송조장수
  PS_0210-FACTOR_M    = PS_0210-FACTOR_I - PS_0210-FACTOR_JS.

  "당월수량 : 당월조장수 * 조장
  PS_0210-LFIMG_M     = PS_0210-FACTOR_M * PS_0210-LENGTH_JS.

  "당월금액 : 당월수량 * 단가
  PS_0210-NETWR_DW    = PS_0210-LFIMG_M * PS_0210-NETPR.

  "적송수량 : 적송조장수 * 조장
  PS_0210-LFIMG_JS    = PS_0210-FACTOR_JS * PS_0210-LENGTH_JS.

  "적송금액 : 적송수량 * 단가
  PS_0210-NETWR_JS    = PS_0210-LFIMG_JS * PS_0210-NETPR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK  USING    PS_E_ROW  TYPE LVC_S_ROW
                                PS_E_COLUMN TYPE LVC_S_COL
                                PS_ES_ROW_NO TYPE LVC_S_ROID
                                PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID.
      PERFORM ALV_DOUBLE_CLICK_0100 USING PS_E_ROW PS_E_COLUMN.

    WHEN GO_GRID1.
      PERFORM ALV_DOUBLE_CLICK_0200 USING PS_E_ROW PS_E_COLUMN.

    WHEN GO_GRID2.

    WHEN GO_GRID3.
      PERFORM ALV_DOUBLE_CLICK_0900 USING PS_E_ROW PS_E_COLUMN.


  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0200  USING  PS_E_ROW  TYPE LVC_S_ROW
                                   PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_0200 INTO DATA(LS_0200) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'VGBEL'.
      IF LS_0200-VGBEL IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_0200-VGBEL.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN OTHERS.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0100  USING  PS_E_ROW  TYPE LVC_S_ROW
                                   PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_0100 INTO DATA(LS_0100) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'VBELN_VA'.
      IF LS_0100-VBELN_VA IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_0100-VBELN_VA.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN_VL'.
      IF LS_0100-VBELN_VL IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD LS_0100-VBELN_VL.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'TKNUM'.
      IF LS_0100-TKNUM IS NOT INITIAL.
        SET PARAMETER ID 'TNR' FIELD LS_0100-TKNUM.
        CALL TRANSACTION 'VT03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'ST_NDC'. "신규생성 DO LIST POP-UP
      PERFORM CREATED_DO_LIST_DISPLAY USING LS_0100.

    WHEN 'STAT'.
      IF LS_0100-RSLT_PROC EQ GC_E AND LS_0100-MESSAGE IS NOT INITIAL.
        MESSAGE I000 WITH LS_0100-MESSAGE(50)
                          LS_0100-MESSAGE+50(50)
                          LS_0100-MESSAGE+100(50)
                          LS_0100-MESSAGE+150(50) DISPLAY LIKE GC_E.

      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR  USING    PE_OBJECT
                                TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           PE_INTERACTIVE
                           PV_SENDER.
  DATA: LS_TOOLBAR TYPE STB_BUTTON.

  CASE PV_SENDER.
    WHEN GO_GRID.
      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-BUTN_TYPE = '3'.
      LS_TOOLBAR-DISABLED = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'ZREFR'.
      LS_TOOLBAR-ICON     = ICON_REFRESH.
      LS_TOOLBAR-BUTN_TYPE = '0'.
      LS_TOOLBAR-DISABLED = SPACE.
      LS_TOOLBAR-TEXT  = TEXT-B01.
      LS_TOOLBAR-QUICKINFO = SPACE.
      LS_TOOLBAR-CHECKED   = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-BUTN_TYPE = '3'.
      LS_TOOLBAR-DISABLED = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'ZSELA'.
      LS_TOOLBAR-ICON     = ICON_SELECT_ALL.
      LS_TOOLBAR-BUTN_TYPE = '0'.
      LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
      LS_TOOLBAR-QUICKINFO = SPACE.
      LS_TOOLBAR-CHECKED   = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-BUTN_TYPE = '3'.
      LS_TOOLBAR-DISABLED = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'ZDSEL'.
      LS_TOOLBAR-ICON     = ICON_DESELECT_ALL.
      LS_TOOLBAR-BUTN_TYPE = '0'.
      LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
      LS_TOOLBAR-QUICKINFO = SPACE.
      LS_TOOLBAR-CHECKED   = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

    WHEN GO_GRID1.
      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-BUTN_TYPE = '3'.
      LS_TOOLBAR-DISABLED = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'ZSELA1'.
      LS_TOOLBAR-ICON     = ICON_SELECT_ALL.
      LS_TOOLBAR-BUTN_TYPE = '0'.
      LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
      LS_TOOLBAR-QUICKINFO = SPACE.
      LS_TOOLBAR-CHECKED   = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-BUTN_TYPE = '3'.
      LS_TOOLBAR-DISABLED = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION = 'ZDSEL1'.
      LS_TOOLBAR-ICON     = ICON_DESELECT_ALL.
      LS_TOOLBAR-BUTN_TYPE = '0'.
      LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
      LS_TOOLBAR-QUICKINFO = SPACE.
      LS_TOOLBAR-CHECKED   = SPACE.
      APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

    WHEN OTHERS.

  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_USER_COMMAND  USING    PV_UCOMM
                                PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID.
      CASE PV_UCOMM.
        WHEN 'ZREFR'.
          PERFORM REBUILD_LIST_0100.

        WHEN 'ZSELA'. "전체선택
          PERFORM SELECT_ALL_0100.

        WHEN 'ZDSEL'. "전체해제
          PERFORM DESELECT_ALL_0100.

        WHEN OTHERS.

      ENDCASE.
    WHEN GO_GRID1.
      CASE PV_UCOMM.
        WHEN 'ZSELA1'. "전체선택
          PERFORM SELECT_ALL_0200.

        WHEN 'ZDSEL1'. "전체해제
          PERFORM DESELECT_ALL_0200.
      ENDCASE.
    WHEN GO_GRID2.

    WHEN GO_GRID3.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0900  USING  PS_E_ROW  TYPE LVC_S_ROW
                                   PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_0900 INTO DATA(LS_0900) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'VBELN_VL'.
      IF LS_0900-VBELN_VL IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD LS_0900-VBELN_VL.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN_VA'.
      IF LS_0900-VBELN_VA IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_0900-VBELN_VA.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
