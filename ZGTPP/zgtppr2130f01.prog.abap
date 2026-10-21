*&---------------------------------------------------------------------*
*& Include          ZGTPPR2130F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_selection_period
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SELECTION_PERIOD .

  IF S_DATE[] IS NOT INITIAL.
    READ TABLE S_DATE INDEX 1.
  ENDIF.

  REFRESH S_DATE[].
  S_DATE-SIGN = 'I'.
  S_DATE-OPTION = 'BT'.


  IF S_DATE-LOW IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '-6'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_DATE-LOW.
  ENDIF.

  IF S_DATE-HIGH IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '6'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_DATE-HIGH.
  ENDIF.
  APPEND S_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 납품처
  IF NOT P_KUNNR IS INITIAL.
    CLEAR KNA1.
    SELECT SINGLE NAME1 INTO P_NAME2
             FROM KNA1
            WHERE KUNNR EQ P_KUNNR.
  ELSE.
    CLEAR P_NAME2.
  ENDIF.

* 자재번호
*  IF NOT P_MATNR IS INITIAL.
*    P_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = P_MATNR ).
*  ELSE.
*    CLEAR P_MAKTX.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_first_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  REFRESH : GT_SUM_QUAN, GT_MAIN_DISP.

  PERFORM GET_MAIN_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAIN_DATA.

  DATA : LV_CHK_EXIST.

  PERFORM SET_INIT_DATA.

  IF S_AUFNR[] IS INITIAL.
    PERFORM GET_MAINDATA_SO TABLES GT_MAIN_DISP GT_SUM_QUAN.
* SO 기준 화면구성
    PERFORM SET_MAIN_DISPLAY.
  ENDIF.

  IF NOT ( S_VBELN[] IS NOT INITIAL OR P_KUNNR IS NOT INITIAL OR S_YUSCD[] IS NOT INITIAL ).
    PERFORM GET_MAINDATA_PO.
  ENDIF.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    IF <LS_MAIN>-GCATG = '판매오더'.
* 특기사항 헤더
      CLEAR <LS_MAIN>-SNOTE.
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'H' <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING <LS_MAIN>-SNOTE.
* 특기사항 item
      CLEAR <LS_MAIN>-SNOTE2.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'I' <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING <LS_MAIN>-SNOTE2.

      IF P_WERKS = '6600' AND P_SPGCD = 'GO'.
        PERFORM GET_FIBER_FR_BOM USING <LS_MAIN>-VBELN <LS_MAIN>-POSNR CHANGING <LS_MAIN>-FIBER.
      ENDIF.

    ELSE.
      CLEAR <LS_MAIN>-SNOTE.
      PERFORM CHK_EXIST_SNOTE_FR_PO USING <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING <LS_MAIN>-SNOTE.
    ENDIF.

    SELECT SINGLE COLORBASE, PDCASPECNO, PDCAPROCOUTDIA FROM ZGTCVMSTVAL
      INTO ( @<LS_MAIN>-COLOR, @<LS_MAIN>-ZSPECNO, @<LS_MAIN>-OUTDIA )
     WHERE WERKS = @P_WERKS
       AND MATNR = @<LS_MAIN>-MATNR.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_ORDER>_STATUS
*&---------------------------------------------------------------------*
FORM GET_STATUS  USING    PV_AUFNR
                 CHANGING PV_STATUS.

  DATA  : LV_STTXT LIKE RC65D-STTXT,
          LV_INDEX LIKE SY-INDEX,
          LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE,
          LV_OBJNR LIKE AUFK-OBJNR,
          LV_TEXT  LIKE ZPPS300-TEXT.

*  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.

  RANGES: LR_STATUS      FOR RC65D-STATUS.

  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      IM_AUFNR        = PV_AUFNR
    TABLES
      ET_STTXT        = LT_TJ02T
    EXCEPTIONS
      NO_SELECTION    = 1
      NOT_FOUND_OBJNR = 2
      OTHERS          = 3.

  REFRESH: LR_STATUS.
  CLEAR: LR_STATUS, LV_INDEX.
  LOOP AT LT_TJ02T.
    MOVE: 'I'                    TO LR_STATUS-SIGN,
          'EQ'                   TO LR_STATUS-OPTION,
          LT_TJ02T-TXT04         TO LR_STATUS-LOW.
    APPEND LR_STATUS.       CLEAR LR_STATUS.
  ENDLOOP.

  LOOP AT LT_TJ02T.
    CASE LT_TJ02T-TXT04.
      WHEN 'TECO' OR 'DLFL' OR 'CLSD' OR 'VCAL' OR 'LKD'.
        PV_STATUS = 'DEL'.
        RETURN.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  IF LINE_EXISTS( LT_TJ02T[ TXT04 = 'DLV' ] ).
    PV_STATUS = 'DLV'.
  ENDIF.


*  LV_OBJNR = 'OR' && PV_AUFNR.
*  CALL FUNCTION 'STATUS_TEXT_EDIT'
*    EXPORTING
*      FLG_USER_STAT    = 'X'
*      OBJNR            = LV_OBJNR
*      ONLY_ACTIVE      = 'X'
*      SPRAS            = SY-LANGU
*      BYPASS_BUFFER    = 'X'
*    IMPORTING
*      USER_LINE        = LV_USER_LINE
*    EXCEPTIONS
*      OBJECT_NOT_FOUND = 1
*      OTHERS           = 2.
*
*  FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
*  IF LV_LINE > 0.
*    PV_STATUS = 'PAYO'.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAIN_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MAIN_DISPLAY .

  DATA : LV_VBELN_C(10).
  DATA : LV_POSNR_C(6).
  DATA : LV_LPRIO_C(2).

  SORT GT_SUM_QUAN BY VBELN POSNR.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
*    범주
    CASE <LS_MAIN>-VBTYP.
      WHEN 'C' OR 'I'.
        <LS_MAIN>-GCATG = '판매오더'.
      WHEN 'B'.
        <LS_MAIN>-GCATG = '견적'.
    ENDCASE.

    LV_VBELN_C = <LS_MAIN>-VBELN.
    LV_POSNR_C = <LS_MAIN>-POSNR.
    LV_LPRIO_C = <LS_MAIN>-LPRIO.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C, LV_LPRIO_C.

*    소요량 요소 : 판매오더/품목번호/우선순위
    CONCATENATE LV_VBELN_C LV_POSNR_C LV_LPRIO_C
                  INTO <LS_MAIN>-REQ_FACTOR SEPARATED BY '/'.
*조장(기본단위)
*조장수
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = <LS_MAIN>-CUOBJ                 " 구성
      IMPORTING
        EV_ZGTEINDLEN = <LS_MAIN>-ZGTEINDLEN
        EV_ZGTEFACTOR = <LS_MAIN>-ZGTEFACTOR
        EV_PACK_YN = <LS_MAIN>-PACK_YN  ).

* 부족량
    READ TABLE GT_SUM_QUAN INTO DATA(LS_SUM) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                         POSNR = <LS_MAIN>-POSNR
                                                                         BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      IF LS_SUM-SHORT_ORDER > 0.
        <LS_MAIN>-SHORT_ORDER = LS_SUM-SHORT_ORDER * -1.

      ELSE.
        <LS_MAIN>-SHORT_ORDER = 0.
      ENDIF.
    ENDIF.

    <LS_MAIN>-SHORT_ORDER2 = <LS_MAIN>-KWMENG * -1.

* 제품내역
    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR ).
*   특성
    <LS_MAIN>-CHAR = ICON_CHARACTERISTICS_ACT.
* 소요량 - 처리
    <LS_MAIN>-KWMENG2 = <LS_MAIN>-KWMENG2 * -1.

    IF <LS_MAIN>-SHORT_ORDER = 0  AND P_ZERO IS INITIAL.
      DELETE GT_MAIN_DISP.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
*      IF GT_ITEM_DISP[] IS INITIAL.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : '' '' '' '' '3',            "구분자
                                      'OPEN' ICON_ALV_COLLAPSE '' '개별 조장 분해'(i01) 0 .
*      ELSE.
*        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
*                             USING : '' '' '' '' '3',            "구분자
*                                       'CLOSE' ICON_ALV_COLLAPSE '' '개별 조장 분해' 0 .
*
*
*      ENDIF.


    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : '' '' '' '' '3',            "구분자
                                      'INSERT' ICON_CREATE ' 신규 조장 구성표 생성'(i02) '신규 조장 구성표 생성'(i02) 0 ,
                                      'APPEND' ICON_CREATE_TEXT ' 기존 조장 구성표에 추가'(i03) '기존 조장 구성표에 추가'(i03) 0 ,
                                      '' '' '' '' '3'.            "구분자
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE PV_TEXT '　'  INTO LS_TOOLBAR-TEXT.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING   PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LV_EINDLEN LIKE VBAP-KWMENG. "부족량 계산
  DATA : LT_2000 TYPE TABLE OF ZGTPPT2000.
  DATA : LT_ITEM LIKE TABLE OF GS_ITEM_DISP.
  DATA : LS_ITEM LIKE GS_ITEM_DISP.
  DATA : LV_CHK_ERR.
  DATA : LV_CHK_EXIST_OEM.

  CALL METHOD PO_SENDER->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

*  커맨드입력시 라인 선택확인
  CASE PV_UCOMM.
    WHEN 'OPEN' OR 'INSERT' OR 'APPEND'..
      IF LT_ROW[] IS INITIAL.
        CASE PO_SENDER.
          WHEN GO_GRID_0100.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 판매오더 품목이 없습니다'(m01).
          WHEN GO_GRID_0101.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 판매오더 품목이 없습니다'(m01).
        ENDCASE.
        RETURN.
      ENDIF.
  ENDCASE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'OPEN'.
          REFRESH GT_ITEM_DISP.
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

            IF GS_MAIN_DISP-CHK_OEM = ABAP_TRUE.
              LV_CHK_EXIST_OEM = ABAP_TRUE.
              CONTINUE.
            ENDIF.

* 장납품 자재 청구 관련해서 조장번호 생성시 판매오더 상태값 체크 제외(포장재, 입회검사여장)
**** 포장재 지정오류
***            IF GS_MAIN_DISP-GCATG EQ '판매오더' AND GS_MAIN_DISP-STATUS_MARKING = ICON_LED_RED.
***              MESSAGE S000 DISPLAY LIKE 'E' WITH '포장재가 지정되지 않아 조장 구성표로 생성할 수 없습니다.'(m27).
***              RETURN.
***            ENDIF.
***
**** 포장재 지정오류
***            IF GS_MAIN_DISP-GCATG EQ '판매오더' AND GS_MAIN_DISP-STATUS_INSPECTION = ICON_LED_RED.
***              MESSAGE S000 DISPLAY LIKE 'E' WITH '입회검사 여장이 지정되지 않아 조장 구성표로 생성할 수 없습니다.'(m28).
***              RETURN.
***            ENDIF.

            LV_EINDLEN = GS_MAIN_DISP-SHORT_ORDER.
            WHILE LV_EINDLEN < 0.
              CLEAR LS_ITEM.
              MOVE-CORRESPONDING  GS_MAIN_DISP TO LS_ITEM.
              LV_EINDLEN = LV_EINDLEN + LS_ITEM-ZGTEINDLEN.
              APPEND LS_ITEM TO GT_ITEM_DISP.
            ENDWHILE.

          ENDLOOP.

          DATA(LT_DUP_CHK) = GT_ITEM_DISP.
          SORT LT_DUP_CHK BY MATNR.
          DELETE ADJACENT DUPLICATES FROM LT_DUP_CHK COMPARING MATNR.

          CLEAR LV_CHK_ERR.
          PERFORM CHK_ROUTING TABLES LT_DUP_CHK CHANGING LV_CHK_ERR.

          IF LV_CHK_ERR IS NOT INITIAL.
            MESSAGE S000 DISPLAY LIKE 'E' WITH '공정이 다른 제품은 같은 조장 구성표로 생성할 수 없습니다.'(m25).
            RETURN.
          ENDIF.

          IF GT_ITEM_DISP[] IS INITIAL.
            IF LV_CHK_EXIST_OEM = ABAP_TRUE.
              MESSAGE S000 DISPLAY LIKE 'E' WITH 'OEM 전환된 소요량 요소가 선택 되었습니다.'(m26).
            ELSE.
              MESSAGE S000 DISPLAY LIKE 'E' WITH '부족 수량이 없어 조장구성표를 생성할 수 없습니다'(m03).
            ENDIF.
            RETURN.
          ENDIF.

          PERFORM REFRESH_GRID_0101.
      ENDCASE.
    WHEN GO_GRID_0101.

      DELETE LT_ROW WHERE ROWTYPE IS NOT INITIAL.
      CASE PV_UCOMM.
        WHEN 'INSERT'.
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_ITEM_DISP INTO GS_ITEM_DISP INDEX LS_ROW-INDEX.
            APPEND GS_ITEM_DISP TO LT_ITEM.
          ENDLOOP.
          CLEAR LV_CHK_ERR.
          PERFORM MAKE_SAVE_ZGTPPT2000 TABLES LT_ITEM LT_2000
                                                             USING 'N' GV_GRPNR
                                                        CHANGING LV_CHK_ERR.

          IF LV_CHK_ERR IS NOT INITIAL.
            RETURN.
          ENDIF.

          PERFORM SAVE_DATA_ZGTPPT2000 TABLES LT_2000
                                                             USING 'N' GV_GRPNR
                                                        CHANGING LV_CHK_ERR.

          IF LV_CHK_ERR IS NOT INITIAL.
            RETURN.
          ENDIF.

          GO_GRID_0101->SET_SELECTED_ROWS( ).

        WHEN 'APPEND'.
          CLEAR GV_GRPNR.
          CALL SCREEN 0200 STARTING AT 10 5 ENDING AT 76 7.
          IF GV_GRPNR IS INITIAL.
            RETURN.
          ENDIF.
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_ITEM_DISP INTO GS_ITEM_DISP INDEX LS_ROW-INDEX.
            APPEND GS_ITEM_DISP TO LT_ITEM.
          ENDLOOP.
          CLEAR LV_CHK_ERR.
          PERFORM MAKE_SAVE_ZGTPPT2000 TABLES LT_ITEM LT_2000
                                                             USING '' GV_GRPNR
                                                        CHANGING LV_CHK_ERR.

          IF LV_CHK_ERR IS NOT INITIAL.
            RETURN.
          ENDIF.
          PERFORM SAVE_DATA_ZGTPPT2000 TABLES LT_2000
                                                             USING '' GV_GRPNR
                                                        CHANGING LV_CHK_ERR.

          IF LV_CHK_ERR IS NOT INITIAL.
            RETURN.
          ENDIF.

          GO_GRID_0101->SET_SELECTED_ROWS( ).

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  FIELD-SYMBOLS <LS_DATA> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP ASSIGNING <LS_DATA> INDEX P_ROW-INDEX.
    WHEN GO_GRID_0101.
      READ TABLE GT_ITEM_DISP ASSIGNING <LS_DATA> INDEX P_ROW-INDEX.
  ENDCASE.

  CASE P_COLUMN-FIELDNAME.
    WHEN 'VBELN' OR 'POSNR'.
      ASSIGN COMPONENT 'GCATG' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      IF <LV_FIELD> NE '생산오더'.
        ASSIGN COMPONENT 'VBELN' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
        SET PARAMETER ID 'AUN' FIELD <LV_FIELD>.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        SET PARAMETER ID 'AUN' FIELD ''.
      ELSE.
        ASSIGN COMPONENT 'VBELN' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
        ASSIGN COMPONENT 'POSNR' OF STRUCTURE <LS_DATA> TO <LV_FIELD2>.
        PERFORM DISP_POPUP_SMORDER USING <LV_FIELD> <LV_FIELD2>.
      ENDIF.
    WHEN 'REQ_FACTOR'.

      ASSIGN COMPONENT 'GCATG' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      IF <LV_FIELD> = '생산오더'.
*        ASSIGN COMPONENT 'REQ_FACTOR' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
*
*        SET PARAMETER ID 'ANR' FIELD <LV_FIELD>.
*        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
*        SET PARAMETER ID 'ANR' FIELD ''.
      ENDIF.

    WHEN 'CHAR'.
      ASSIGN COMPONENT 'GCATG' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      IF <LV_FIELD> NE '생산오더'.
        ASSIGN COMPONENT 'CUOBJ' OF STRUCTURE <LS_DATA> TO <LV_FIELD2>.
        PERFORM DISPLAY_POPUP_CHARACTICS USING <LV_FIELD2>.
      ELSE.

        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <LS_DATA> TO <LV_FIELD2>.
        SELECT SINGLE CUOBJ INTO @DATA(LV_CUOBJ) FROM MARC
          WHERE MATNR = @<LV_FIELD2>
            AND WERKS = @P_WERKS.

        PERFORM DISPLAY_POPUP_CHARACTICS USING LV_CUOBJ.

      ENDIF.

    WHEN 'MATNR'.
      ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      SET PARAMETER ID 'WRK' FIELD P_WERKS.
      SET PARAMETER ID 'MXX' FIELD 'K'.
      SET PARAMETER ID 'MAT' FIELD <LV_FIELD>..
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      SET PARAMETER ID 'WRK' FIELD ''.
      SET PARAMETER ID 'MAT' FIELD ''.

    WHEN 'BANFN' OR 'BNFPO'.
      CHECK P_SENDER = GO_GRID_0100.
      ASSIGN COMPONENT 'BANFN' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      SET PARAMETER ID 'BAN' FIELD <LV_FIELD>.
      CALL TRANSACTION 'ME53N'.
      SET PARAMETER ID 'BAN' FIELD ''.

    WHEN 'EBELN' OR 'EBELP'.
      CHECK P_SENDER = GO_GRID_0100.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
      SET PARAMETER ID 'BES' FIELD <LV_FIELD>.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      SET PARAMETER ID 'BES' FIELD ''.

    WHEN 'SNOTE'.
      MOVE-CORRESPONDING <LS_DATA> TO GS_MAIN_DISP.
      CHECK GS_MAIN_DISP-SNOTE IS NOT INITIAL.
      PERFORM SET_AND_DISP_TEXT.

    WHEN 'SNOTE2'.
      MOVE-CORRESPONDING <LS_DATA> TO GS_MAIN_DISP.
      CHECK GS_MAIN_DISP-SNOTE2 IS NOT INITIAL.
      IF GS_MAIN_DISP-GCATG NE '생산오더'.
        PERFORM SET_AND_DISP_TEXT2.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

*  CREATE OBJECT GO_CONTAINER
*    EXPORTING
*      container_name = 'CONTAINER'.

  CREATE OBJECT GO_DOCKING_CONTAINER
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    45 ).             " Height

* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.


  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2130TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'REQ_FACTOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'REQ_FACTOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량 요소'(f16).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '50'.
    <LS_FCAT>-JUST = 'L'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_OEM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_OEM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'OEM 대응'(f17).
    <LS_FCAT>-COL_POS = 26.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.

  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'REQ_FACTOR'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f01).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZGTEINDLEN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장(기본단위)'(f02).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'ZGTEFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f03).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SHORT_ORDER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '부족량'(f04).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(f05).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(f06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KWMENG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'KWMENG2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량'(f07).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(f22).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(f08).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'CHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특성'(f09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f10).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'(f11).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품코드'(f12).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'LPRIO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '목적지/납품처'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '목적지 내역'(f15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BANFN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'(f18).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'(f19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매납품예정일'(f20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매처리상태'(f21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PR_NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체명'(f23).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SNOTE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(헤더)'(f25).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SNOTE2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(품목)'(f26).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS_MARKING'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재'(f28).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'STATUS_INSPECTION'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입회검사'(f29).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'FIBER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Fiber소요량(Km)'(f30).
        <LS_FCAT>-JUST = 'R'.
        IF P_WERKS = '6600' AND P_SPGCD = 'GO'.
        ELSE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Spec No'(f31).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'OUTDIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '최종외경'(f32).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 1.

      WHEN 'ERDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'S/O 생성일'(f33).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DISPO' OR 'CUOBJ' OR 'VBTYP' OR 'SHORT_ORDER2'.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  IF LINE_EXISTS( GT_MAIN_DISP[ ZGTEINDLEN = 0 ]  ).
    CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
      EXPORTING
        MSGID = 'ZGTPP00'
        MSGTY = 'I'
        MSGNO = '000'
        MSGV1 = '조장(기본단위)가 조회되지 않은 판매오더가 존재합니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_GRID_0101 .

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
*    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .

* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2130TOP'
      I_INTERNAL_TABNAME     = 'GS_ITEM_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_ITEM_DISP
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'REQ_FACTOR'.
  <LS_FCAT>-REPTEXT = '소요량 요소'(f16).
  <LS_FCAT>-COL_POS = 2.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '50'.
  <LS_FCAT>-JUST = 'L'.
  <LS_FCAT>-KEY = ABAP_TRUE.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZGTEINDLEN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장(기본단위)'(f02).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
      WHEN 'SHORT_ORDER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '부족량'(f04).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요일'(f05).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(f06).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KWMENG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'KWMENG2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량'(f07).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특성'(f09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f10).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'(f11).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품코드'(f12).
        <LS_FCAT>-JUST = 'C'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'LPRIO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '목적지/납품처'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '목적지 내역'(f15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'DISPO' OR 'CUOBJ' OR 'SHORT_ORDER2'.
        <LS_FCAT>-TECH = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f27).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'AUFNR' OR 'POSNR_CO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_ITEM_DISP
      IT_SORT              = GT_SORT_0101
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0101 .

  REFRESH GT_SORT_0101.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                            USING : 1 'VBELN' 'X' '' 'X',
                                       2 'POSNR' 'X' '' 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_POPUP_CHARACTICS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_FIELD>
*&---------------------------------------------------------------------*
FORM DISPLAY_POPUP_CHARACTICS  USING    PV_CUOBJ. " TYPE CUOBJ_VA.

  DATA : LS_INCL_BILD TYPE INCL_BILD.
* 초기화
  CALL FUNCTION 'CUD0_CONFIGURATION_INITIALIZER'.

  CALL FUNCTION 'VC_I_DISPLAY_CONFIGURATION'
    EXPORTING
      INSTANCE           = PV_CUOBJ
      INCLUDE_SCREEN     = LS_INCL_BILD
*     APPLICATION        = ' '
*     MATNR_APPL         =
*     WERKS_APPL         =
*     BESKZ_APPL         =
*     SOBSL_APPL         =
*     NO_STRUC           = 'X'
*     NO_RESULT          = 'X'
*     NO_MASTERD         = 'X'
*     NO_PRICE           = 'X'
*     NO_TYPEM           = 'X'
*     IV_INVALID_POSSIBLE       = ' '
      IV_NO_VALUE_CHECK  = ' X'
*     EFFECTIVITY        = ' '
    EXCEPTIONS
      INSTANCE_NOT_FOUND = 1
      INTERNAL_ERROR     = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.

  ENDIF.
  .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_save_ZGTPPT2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_SAVE_ZGTPPT2000  TABLES PT_ITEM STRUCTURE GS_ITEM_DISP
                                                        PT_2000 STRUCTURE ZGTPPT2000
                                                USING PV_GUBUN
                                                         PV_GRPNR TYPE ZGTEGRPNR
                                           CHANGING PV_CHK_ERR.

  DATA : LS_2000 TYPE ZGTPPT2000.
  DATA : LV_INDEX TYPE I.
  DATA : LT_SUM LIKE TABLE OF GS_SUM_QUAN.
  DATA : LT_CHK_2000 TYPE TABLE OF ZGTPPT2000.
  DATA : LT_OLD_2000 TYPE TABLE OF ZGTPPT2000.
  DATA : LV_SUM TYPE P LENGTH 13 DECIMALS 3.
  DATA : LV_CHK_FACTOR TYPE ZGTPPT2000-INFACTOR.
  DATA : LV_OLD_FACTOR TYPE ZGTPPT2000-INFACTOR.
  DATA : LV_STRING TYPE STRING.

  REFRESH PT_2000[].

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).

    CLEAR LS_2000.
    READ TABLE PT_2000 INTO LS_2000 WITH KEY ORDNO = LS_ITEM-VBELN
                                                               POSNR = LS_ITEM-POSNR
                                                               BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 이미 어팬드 처리건 조장수만 더해준다
      LS_2000-INFACTOR = LS_2000-INFACTOR + 1.
      MODIFY PT_2000 FROM LS_2000 INDEX SY-TABIX TRANSPORTING INFACTOR .
    ELSE.
      LV_INDEX = SY-TABIX.
      LS_2000-ORDNO   = LS_ITEM-VBELN.
      LS_2000-POSNR   = LS_ITEM-POSNR.
      LS_2000-LINNO   = '0001'.
      LS_2000-ERDAT = SY-DATUM.
      LS_2000-WERKS = P_WERKS.
      LS_2000-SPGCD = P_SPGCD.
      LS_2000-MATNR = LS_ITEM-MATNR.
      LS_2000-MAKTX = LS_ITEM-MAKTX.
      LS_2000-ZZYUSCD = LS_ITEM-ZZYUSCD.
      LS_2000-KUNNR = LS_ITEM-KUNNR.
      LS_2000-INLENGTH = LS_ITEM-ZGTEINDLEN.
      LS_2000-INFACTOR = LS_2000-INFACTOR + 1.
      LS_2000-EDATU = LS_ITEM-EDATU.
      LS_2000-WMENG = LS_ITEM-KWMENG.
      LS_2000-MEINS = LS_ITEM-MEINS.
      LS_2000-ZSTATUS = ABAP_FALSE.
      LS_2000-GCATG = LS_ITEM-GCATG.
      LS_2000-ERNAM = SY-UNAME.
      LS_2000-AEDAT = SY-DATUM.
      LS_2000-AENAM  = SY-UNAME.
      INSERT LS_2000 INTO PT_2000 INDEX LV_INDEX.
    ENDIF.

  ENDLOOP.

  PERFORM GET_HIST_DATA_2000 TABLES PT_2000 LT_CHK_2000.

  SORT LT_CHK_2000 BY ORDNO POSNR.

  LOOP AT PT_2000 INTO LS_2000.

    CLEAR LV_OLD_FACTOR.
    READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) WITH KEY VBELN = LS_2000-ORDNO
                                                                                 POSNR = LS_2000-POSNR.

    READ TABLE LT_CHK_2000 TRANSPORTING NO FIELDS WITH KEY ORDNO = LS_2000-ORDNO
                                                                                    POSNR = LS_2000-POSNR.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_CHK_2000 INTO DATA(LS_OLD) FROM SY-TABIX.
        IF NOT ( LS_OLD-ORDNO = LS_2000-ORDNO AND  LS_OLD-POSNR = LS_2000-POSNR ).
          EXIT.
        ENDIF.


        IF LS_OLD-WMENG NE LS_MAIN-KWMENG.
          IF LS_MAIN-GCATG = '생산오더'.
            MESSAGE S000 DISPLAY LIKE 'E' WITH LS_MAIN-VBELN '생산오더 소요량이 변경되었습니다. '(m23) '업데이트 하십시오. 기존 소요량 - '(m05) LS_OLD-WMENG.
          ELSE.
            MESSAGE S000 DISPLAY LIKE 'E' WITH LS_MAIN-VBELN '판매오더 소요량이 변경되었습니다. '(m04) '업데이트 하십시오. 기존 소요량 - '(m05) LS_OLD-WMENG.
          ENDIF.
          PV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.

        IF LS_OLD-INLENGTH NE LS_MAIN-ZGTEINDLEN.
          IF LS_MAIN-GCATG = '생산오더'.
            MESSAGE S000 DISPLAY LIKE 'E' WITH LS_MAIN-VBELN '생산오더 개별조장이 변경되었습니다. '(m24) '업데이트 하십시오. 기존 개별조장 - '(m07) LS_OLD-INLENGTH.
          ELSE.
            MESSAGE S000 DISPLAY LIKE 'E' WITH LS_MAIN-VBELN '판매오더 개별조장이 변경되었습니다. '(m06) '업데이트 하십시오. 기존 개별조장 - '(m07) LS_OLD-INLENGTH.
          ENDIF.
          PV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.

        LV_OLD_FACTOR = LV_OLD_FACTOR + LS_OLD-INFACTOR. "  기존에 저장된 누적 조장합

      ENDLOOP.

      IF PV_CHK_ERR IS NOT INITIAL.
        EXIT.
      ENDIF.

      CLEAR LV_SUM.
      CLEAR LV_CHK_FACTOR.

      DO.
        LV_CHK_FACTOR = LV_CHK_FACTOR + 1.
        CLEAR LV_SUM.
        LV_SUM = LS_MAIN-SHORT_ORDER2 + ( LV_CHK_FACTOR * LS_2000-INLENGTH ).

        IF LV_SUM >= 0.
          EXIT.
        ENDIF.
      ENDDO.

      LV_CHK_FACTOR = LV_CHK_FACTOR - LV_OLD_FACTOR - LS_2000-INFACTOR.
      IF LV_CHK_FACTOR < 0 .
        MESSAGE S000 DISPLAY LIKE 'E' WITH LS_MAIN-VBELN '에 대한 조장구성표에 등록된 조장 합이 소요량보다 큽니다.'(m08).
        PV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.


  CHECK PV_GUBUN NE 'N'.
* validation check
  PERFORM GET_OLD_2000_DATA TABLES LT_OLD_2000
                                               USING PV_GRPNR.
  DELETE LT_OLD_2000 WHERE ZSTATUS <> ''.
  IF SY-SUBRC EQ 0.
    MESSAGE S000 DISPLAY LIKE 'E' WITH PV_GRPNR '처리된 내역이 있어 추가할 수 없습니다.'(m09).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  READ TABLE LT_OLD_2000 INTO DATA(LS_OLD_2000) INDEX 1.

  PERFORM CHK_ROUTING_DB TABLES PT_2000 USING LS_OLD_2000-MATNR CHANGING PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE 'E' WITH PV_GRPNR '와 조장이 틀려 추가할 수 없습니다.'(m18).
    RETURN.
  ENDIF.


* 기존에 조장구성표에 저장된 오더, 품목일 경우 조장수에 더해준다.
  LOOP AT PT_2000 ASSIGNING FIELD-SYMBOL(<LS_2000>).
    READ TABLE LT_OLD_2000 INTO LS_OLD WITH KEY ORDNO = <LS_2000>-ORDNO
                                                                       POSNR = <LS_2000>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_2000>-INFACTOR = <LS_2000>-INFACTOR + LS_OLD-INFACTOR.
      <LS_2000>-ERNAM  = LS_OLD-ERNAM.
      <LS_2000>-ERDAT  = LS_OLD-ERDAT.
    ENDIF.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_OLD_2000_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OLD_2000
*&      --> SORT
*&      --> LT_MAIN
*&      --> BY
*&      --> VBELN
*&      --> POSNR
*&---------------------------------------------------------------------*
FORM GET_OLD_2000_DATA  TABLES   PT_OLD STRUCTURE ZGTPPT2000
                                          USING   PV_GRPNR TYPE ZGTPPT2000-GRPNR.

  SELECT * FROM ZGTPPT2000
    INTO CORRESPONDING FIELDS OF TABLE PT_OLD
   WHERE GRPNR = PV_GRPNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA_ZGTPPT2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2000
*&      --> P_
*&      --> GV_GRPNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SAVE_DATA_ZGTPPT2000  TABLES PT_2000 STRUCTURE ZGTPPT2000
                                                USING PV_GUBUN
                                                         PV_GRPNR TYPE ZGTEGRPNR
                                           CHANGING PV_CHK_ERR.

  DATA : LV_GRPNR TYPE ZGTEGRPNR.
  DATA : LV_NR     LIKE  INRI-NRRANGENR,
         LV_NUMBER TYPE C LENGTH 5.

  CASE PV_GUBUN.
    WHEN 'N'. " 신규 조장 구성표 번호 생성
      LV_NR = P_SPGCD.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR             = LV_NR
          OBJECT                  = 'ZSPG'
        IMPORTING
          NUMBER                  = LV_NUMBER
        EXCEPTIONS
          INTERVAL_NOT_FOUND      = 1
          NUMBER_RANGE_NOT_INTERN = 2
          OBJECT_NOT_FOUND        = 3
          QUANTITY_IS_0           = 4
          QUANTITY_IS_NOT_1       = 5
          INTERVAL_OVERFLOW       = 6
          BUFFER_OVERFLOW         = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
        MESSAGE S000 DISPLAY LIKE 'E' WITH 'SPG는 마스터에 없습니다.'(m10) ' 조장구성표를 생성할 수 없습니다.'(m11).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
      LV_GRPNR = P_SPGCD && SY-DATUM+0(4) && SY-DATUM+4(2) && LV_NUMBER.

    WHEN OTHERS.
      LV_GRPNR = PV_GRPNR.

  ENDCASE.

  LOOP AT PT_2000 ASSIGNING FIELD-SYMBOL(<LS_2000>).
    <LS_2000>-GRPNR = LV_GRPNR.
  ENDLOOP.

  IF PT_2000[] IS NOT INITIAL.
    MODIFY ZGTPPT2000 FROM TABLE PT_2000.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE S000 WITH LV_GRPNR '생성 되었습니다.'(m12).
    ELSE.
      ROLLBACK WORK.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '조장 구성표 생성중 오류 발생하였습니다.!'(m13).
      PV_CHK_ERR = ABAP_TRUE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_GV_GRPNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_GV_GRPNR INPUT.

  DATA: BEGIN OF LT_ZGTPPT2000 OCCURS 0,
          GRPNR TYPE ZGTPPT2000-GRPNR,
          ERDAT TYPE ZGTPPT2000-ERDAT,
          MATNR TYPE ZGTPPT2000-MATNR,
        END   OF LT_ZGTPPT2000.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL.

  SELECT GRPNR    ERDAT    MATNR
    INTO CORRESPONDING FIELDS OF TABLE LT_ZGTPPT2000
    FROM ZGTPPT2000
   WHERE SPGCD = P_SPGCD.

  SORT LT_ZGTPPT2000 BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_ZGTPPT2000 COMPARING GRPNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'GRPNR'
      DYNPPROG     = SY-CPROG
      DYNPNR       = SY-DYNNR
      WINDOW_TITLE = '조장 구성표 번호 선택'(m14)
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = LT_ZGTPPT2000
      RETURN_TAB   = LT_RETURN_TAB.

  READ TABLE LT_RETURN_TAB INTO DATA(LS_RETURN_TAB) INDEX 1.

  GV_GRPNR = LS_RETURN_TAB-FIELDVAL.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_HIST_DATA_2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_2000
*&      --> LT_CHK_2000
*&---------------------------------------------------------------------*
FORM GET_HIST_DATA_2000  TABLES   PT_2000 STRUCTURE ZGTPPT2000
                                  PT_CHK_2000 STRUCTURE ZGTPPT2000.

  DATA(LT_CHK_DATA) = PT_2000[].

  SORT LT_CHK_DATA BY ORDNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_DATA COMPARING ORDNO POSNR.

  IF LT_CHK_DATA[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT2000
      INTO CORRESPONDING FIELDS OF TABLE PT_CHK_2000
      FOR ALL ENTRIES IN LT_CHK_DATA
     WHERE ORDNO = LT_CHK_DATA-ORDNO
        AND POSNR = LT_CHK_DATA-POSNR
*        AND GCATG = '판매오더'
        AND ZSTATUS = ABAP_FALSE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION .

*  IF S_MATNR[] IS INITIAL AND S_VBELN[] IS INITIAL.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '자재나 판매오더 중 하나는 입력해야 합니다..'(M15).
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA .

  GV_DISPO = P_SPGCD && '%'. "

* 조회조건의 자재와 자내내역을 조합하여 추출 자재범위 세팅
  SELECT 'I' AS SIGN, 'EQ' AS OPTION, A~MATNR AS LOW
    FROM MARC AS A
    INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
    INNER JOIN MARA AS C ON C~MATNR = A~MATNR
    INNER JOIN T134 AS D ON D~MTART = C~MTART
   WHERE A~MATNR IN @S_MATNR
      AND A~WERKS = @P_WERKS
      AND A~LVORM = ' '
      AND A~DISPO LIKE @GV_DISPO
      AND B~MAKTX IN @S_MAKTX
      AND D~MTREF = 'FERT'
    INTO CORRESPONDING FIELDS OF TABLE @GT_RANGE_MATNR.

  SORT GT_RANGE_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_RANGE_MATNR COMPARING LOW.

  IF GT_RANGE_MATNR[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAINDATA_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MAIN
*&      --> PT_SUM_QUAN
*&---------------------------------------------------------------------*
FORM GET_MAINDATA_SO  TABLES   PT_MAIN   STRUCTURE GS_MAIN_DISP
                                             PT_SUM_QUAN STRUCTURE GS_SUM_QUAN.

  DATA : LV_STATUS TYPE CHAR10.
  RANGES : LT_KUNNR FOR KNA1-KUNNR.
  DATA : BEGIN OF LS_AUFNR_STATUS,
           AUFNR  TYPE AUFK-AUFNR,
           STATUS TYPE CHAR10,
         END OF LS_AUFNR_STATUS.
  DATA : LT_AUFNR_STATUS LIKE TABLE OF LS_AUFNR_STATUS.
  DATA : LV_TABIX TYPE I.
  DATA : BEGIN OF LS_CHK_2010,
           ORDNR TYPE ZGTPPT2010-ORDNR,
           POSNR TYPE  ZGTPPT2010-POSNR,
         END OF LS_CHK_2010.
  DATA : LT_CHK_2010 LIKE TABLE OF LS_CHK_2010.
  DATA : LT_ABGRU TYPE RANGE OF VBAP-ABGRU.

  DATA : BEGIN OF LS_COLLECT_STOCKVAL,
           VBELN TYPE ZGTCV_STOCKVAL-VBELN,
           POSNR TYPE ZGTCV_STOCKVAL-POSNR,
           MATNR TYPE ZGTCV_STOCKVAL-MATNR,
           MENGE TYPE MENGE_D,
         END OF LS_COLLECT_STOCKVAL.

  DATA : LT_COLLECT_STOCKVAL LIKE TABLE OF LS_COLLECT_STOCKVAL.


  IF P_KUNNR IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING FIELD-SYMBOL(<LS_KUNNR>).
    <LS_KUNNR>-SIGN = 'I'.
    <LS_KUNNR>-OPTION = 'EQ'.
    <LS_KUNNR>-LOW = P_KUNNR.
  ENDIF.

* 주문 거부사유가 없는 대상이 조건이나 거부사야 G2는 대상에 포함
  APPEND INITIAL LINE TO LT_ABGRU ASSIGNING FIELD-SYMBOL(<LS_ABGRU>).
  <LS_ABGRU>-SIGN = 'I'.
  <LS_ABGRU>-OPTION = 'EQ'.
*  APPEND INITIAL LINE TO LT_ABGRU ASSIGNING <LS_ABGRU>.
*  <LS_ABGRU>-SIGN = 'I'.
*  <LS_ABGRU>-OPTION = 'EQ'.
*  <LS_ABGRU>-LOW = 'G2'.
  UNASSIGN <LS_ABGRU>.

* 판매오더 기준
  SELECT DISTINCT K~VBELN, P~POSNR, K~KUNNR, P~MATNR, P~VRKME, P~MEINS,
             P~KWMENG AS KWMENG2, "판매단위 수량
             P~KLMENG AS KWMENG,  " 기준단위 수량
             P~LPRIO,
             C~DISPO, KNA1~NAME1, A~EDATU, P~CUOBJ, K~VBTYP,
             K~VKORG, K~VKGRP, B~KDKG4, K~ERDAT
    FROM VBEP AS A
    INNER JOIN  VBAK AS K
                           ON K~VBELN   = A~VBELN
    INNER JOIN VBKD AS B
                           ON B~VBELN = A~VBELN
    INNER JOIN VBAP AS P
                           ON P~VBELN = A~VBELN
                          AND P~POSNR = A~POSNR
    INNER JOIN MARC AS C
                           ON C~MATNR = P~MATNR
                          AND C~WERKS = P~WERKS
    INNER JOIN KNA1 AS KNA1
                           ON KNA1~KUNNR = K~KUNNR
 WHERE A~EDATU IN @S_DATE
      AND A~VBELN IN @S_VBELN
      AND K~VBTYP IN ( 'B', 'C', 'I' )
      AND CONCAT( CONCAT( A~VBELN, A~POSNR ), A~ETENR ) IN
                            ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
                                FROM VBEP
                              WHERE VBELN  = A~VBELN
                                 AND POSNR   = A~POSNR
                                 AND LIFSP = ' '
                                 AND WMENG    NE 0
                        GROUP BY VBELN, POSNR )
      AND CONCAT( P~VBELN, P~POSNR ) NOT IN
       ( SELECT  CONCAT( VBELN, POSNR )
            FROM VBEP
          WHERE VBELN = A~VBELN
              AND POSNR   = A~POSNR
              AND  ETTYP = 'CN'
              AND EDATU  = ( SELECT MAX( EDATU ) AS EDATU
                                FROM VBEP
                            WHERE VBELN = A~VBELN
                                AND POSNR   = A~POSNR
                       GROUP BY VBELN, POSNR ) )
        AND P~ABGRU IN @LT_ABGRU
        AND P~FIXMG = ''
        AND P~MATNR IN @GT_RANGE_MATNR
        AND P~LFSTA IN ( '', 'A' )
        AND C~WERKS = @P_WERKS
        AND C~DISPO LIKE @GV_DISPO
        AND KNA1~KUNNR IN @LT_KUNNR
        INTO  TABLE @DATA(LT_MAIN).

  CHECK LT_MAIN IS NOT INITIAL.
*  추출한 주문 번호로 생산 계획 및 생산 오더 조회
  DATA(LT_CHK_ORDER) = LT_MAIN[].

  SORT LT_CHK_ORDER BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_ORDER COMPARING VBELN POSNR.
  IF LT_CHK_ORDER[] IS NOT INITIAL.
    SELECT KDAUF, KDPOS, PLNUM, GSMNG, AVMNG
      FROM PLAF
      INTO TABLE @DATA(LT_PLAF)
      FOR ALL ENTRIES IN @LT_CHK_ORDER
    WHERE KDAUF   = @LT_CHK_ORDER-VBELN
        AND KDPOS  = @LT_CHK_ORDER-POSNR
        AND AUFFX      = 'X'.

*  생산오더 상태값 조회를 위해 마스터테이블 조회
* 생산 오더 상태 삭제(DLFL/TECO/CLSD) 제외
    SELECT KDAUF, KDPOS, AUFNR, POSNR, PSMNG, WEMNG, PSAMG
      FROM AFPO
      INTO TABLE @DATA(LT_AFPO)
      FOR ALL ENTRIES IN @LT_CHK_ORDER
    WHERE KDAUF   = @LT_CHK_ORDER-VBELN
        AND KDPOS  = @LT_CHK_ORDER-POSNR.

* 수량 계산을 위해 기존 생성된 조장구성표 오더 조회
    LOOP AT LT_CHK_ORDER INTO DATA(LS_CHK_ORDER).
      APPEND INITIAL LINE TO LT_CHK_2010 ASSIGNING FIELD-SYMBOL(<LS_CHK_2010>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LS_CHK_ORDER-VBELN
        IMPORTING
          OUTPUT = LS_CHK_ORDER-VBELN.
      <LS_CHK_2010>-ORDNR = LS_CHK_ORDER-VBELN.
      <LS_CHK_2010>-POSNR = LS_CHK_ORDER-POSNR.
    ENDLOOP.

    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_2010)
     FOR ALL ENTRIES IN @LT_CHK_2010
     WHERE DMORD = @LT_CHK_2010-ORDNR
       AND DMLINE = @LT_CHK_2010-POSNR
       AND DMORDTY = 'SO'.

    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
      FROM ZGTPPT1010
      INTO @GS_EKORG
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = ' '
       AND FLD_02 = @P_WERKS.

* 범주 판매오더의 OEM 구매요청 확인
    SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, B~VBELN, B~VBELP, A~LIFNR, C~NAME1
      FROM EBAN AS A
      INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
                                AND B~BNFPO = A~BNFPO
      LEFT JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      FOR ALL ENTRIES IN @LT_CHK_ORDER
     WHERE B~VBELN =  @LT_CHK_ORDER-VBELN
        AND B~VBELP =  @LT_CHK_ORDER-POSNR
        AND A~MATNR =  @LT_CHK_ORDER-MATNR
        AND A~WERKS =  @P_WERKS
        AND A~BSTYP = 'B'
        AND A~EKORG = @GS_EKORG-EKORG
        AND A~EKGRP = @GS_EKORG-EKGRP
        AND A~LOEKZ = ''
      INTO TABLE @DATA(LT_EBAN).

    SELECT DISTINCT A~VBELN, A~VBELP AS POSNR, C~LIFNR, A~EBELN, A~EBELP, B~BANFN, B~BNFPO, D~NAME1
      FROM EKKN AS A
      INNER JOIN EKPO AS B ON B~EBELN = A~EBELN
                          AND B~EBELP = A~EBELP
      INNER JOIN EKKO AS C ON C~EBELN = A~EBELN
      INNER JOIN LFA1 AS D ON D~LIFNR = C~LIFNR
      INNER JOIN @LT_CHK_ORDER AS E ON E~VBELN = A~VBELN
                                         AND E~POSNR = A~VBELP
                                         AND E~MATNR = B~MATNR
     WHERE B~LOEKZ = ''
      INTO TABLE @DATA(LT_EKKO).

* 기초제고 마이그 수량추출 로직
*    WITH +BWART_561 AS (
    SELECT DISTINCT B~MATNR, B~MAT_KDAUF AS KDAUF, B~MAT_KDPOS AS KDPOS, B~CHARG
      FROM @LT_CHK_ORDER AS A
      INNER JOIN MSEG AS B ON B~MATNR = A~MATNR
                                  AND B~MAT_KDAUF = A~VBELN
                                  AND B~MAT_KDPOS = A~POSNR
      WHERE B~WERKS = @P_WERKS
        AND B~BWART = '561'
       INTO TABLE @DATA(LT_BWART_561).

    SELECT DISTINCT B~MATNR, B~KDAUF, B~KDPOS, B~CHARG
      FROM @LT_CHK_ORDER AS A
      INNER JOIN MSEG AS B ON B~MATNR = A~MATNR
                                  AND B~KDAUF = A~VBELN
                                  AND B~KDPOS = A~POSNR
      WHERE B~WERKS = @P_WERKS
        AND B~BWART = '413'
       APPENDING TABLE @LT_BWART_561.

    SORT LT_BWART_561 BY MATNR KDAUF KDPOS CHARG.
    DELETE ADJACENT DUPLICATES FROM LT_BWART_561 COMPARING MATNR KDAUF KDPOS CHARG.

    IF LT_BWART_561 IS NOT INITIAL.
      SELECT *
        FROM ZGTCV_STOCKVAL
        FOR ALL ENTRIES IN @LT_BWART_561
        WHERE MATNR = @LT_BWART_561-MATNR
          AND VBELN = @LT_BWART_561-KDAUF
          AND POSNR = @LT_BWART_561-KDPOS
          AND CHARG = @LT_BWART_561-CHARG
        INTO TABLE @DATA(LT_STOCKVAL).
    ENDIF.

    LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
      CLEAR LS_COLLECT_STOCKVAL.
      LS_COLLECT_STOCKVAL-VBELN = LS_STOCKVAL-VBELN.
      LS_COLLECT_STOCKVAL-POSNR = LS_STOCKVAL-POSNR.
      LS_COLLECT_STOCKVAL-MATNR = LS_STOCKVAL-MATNR.
      LS_COLLECT_STOCKVAL-MENGE = LS_STOCKVAL-LABST + LS_STOCKVAL-INSME.
      COLLECT LS_COLLECT_STOCKVAL INTO LT_COLLECT_STOCKVAL.
    ENDLOOP.
  ENDIF.


  DATA(LT_CHK_AFPO) = LT_AFPO[].
  SORT LT_CHK_AFPO BY AUFNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AFPO COMPARING AUFNR POSNR.

  IF LT_CHK_AFPO[] IS NOT INITIAL.
* 생산이력
*  생산 수량: MSEG-BWART = '102' 이면 * -1, SUM(MSEG-MENGE - AFPO-PSAMG)
    SELECT A~AUFNR, A~AUFPS, A~BWART, A~MENGE, B~PSAMG
      FROM MSEG AS A
         INNER JOIN @LT_CHK_AFPO AS B
                                              ON A~AUFNR = B~AUFNR
                                             AND A~AUFPS = B~POSNR
         WHERE A~BWART IN ('101', '102')
         INTO TABLE @DATA(LT_MSEG).
  ENDIF.

  DATA : BEGIN OF LS_SUM_MSEG,
           AUFNR LIKE MSEG-AUFNR,
           AUFPS LIKE MSEG-AUFPS,
           MENGE LIKE MSEG-MENGE,
         END OF LS_SUM_MSEG.
  DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.

  LOOP AT LT_MSEG INTO DATA(LS_MSEG).
    CLEAR LS_SUM_MSEG.
    LS_SUM_MSEG-AUFNR = LS_MSEG-AUFNR.
    LS_SUM_MSEG-AUFPS = LS_MSEG-AUFPS.

    READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_MSEG-AUFNR
                                                                  POSNR+2(4) = LS_MSEG-AUFPS
                                                                  ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      CASE LS_MSEG-BWART.
        WHEN '101'.
          LS_SUM_MSEG-MENGE = LS_MSEG-MENGE - LS_MSEG-PSAMG.
          IF LS_SUM_MSEG-MENGE NE 0.
            LS_SUM_MSEG-MENGE = LS_SUM_MSEG-MENGE - ( LS_2010-QLENGTH + LS_2010-ADLENGTH ) .
          ENDIF.
        WHEN '102'.
          LS_SUM_MSEG-MENGE = LS_MSEG-MENGE - LS_MSEG-PSAMG.
          IF LS_SUM_MSEG-MENGE NE 0.
            LS_SUM_MSEG-MENGE = ( LS_SUM_MSEG-MENGE - ( LS_2010-QLENGTH + LS_2010-ADLENGTH ) ) * -1.
          ENDIF.
      ENDCASE.
    ELSE.
      CASE LS_MSEG-BWART.
        WHEN '101'.
          LS_SUM_MSEG-MENGE = LS_MSEG-MENGE - LS_MSEG-PSAMG.
        WHEN '102'.
          LS_SUM_MSEG-MENGE = ( LS_MSEG-MENGE - LS_MSEG-PSAMG ) * -1.
      ENDCASE.
    ENDIF.

    COLLECT LS_SUM_MSEG INTO LT_SUM_MSEG.
  ENDLOOP.

  REFRESH PT_SUM_QUAN[].

* 계획오더 수량
  LOOP AT LT_PLAF INTO DATA(LS_PLAF).
    CLEAR GS_SUM_QUAN.
    GS_SUM_QUAN-VBELN = LS_PLAF-KDAUF.
    GS_SUM_QUAN-POSNR = LS_PLAF-KDPOS.
    READ TABLE LT_2010 INTO LS_2010 WITH KEY ORDNR = LS_PLAF-PLNUM
                                                                  ORDTY = 'PLN'.
    IF SY-SUBRC EQ 0. " 조장구성표에 오더 존재하면 조장구성표의 추가여장 빼준다.
      GS_SUM_QUAN-GSMNG = LS_PLAF-GSMNG - ( LS_2010-QLENGTH + LS_2010-ADLENGTH ).
    ELSE.
      GS_SUM_QUAN-GSMNG = LS_PLAF-GSMNG - LS_PLAF-AVMNG.
    ENDIF.
    COLLECT  GS_SUM_QUAN INTO PT_SUM_QUAN .
  ENDLOOP.

* 생산오더 잔량
  LOOP AT LT_AFPO ASSIGNING FIELD-SYMBOL(<LS_AFPO>).

*  상태값조회후 삭제 상태 제외
    READ TABLE LT_AUFNR_STATUS INTO LS_AUFNR_STATUS WITH KEY AUFNR = <LS_AFPO>-AUFNR BINARY SEARCH.
    LV_TABIX = SY-TABIX.
    IF SY-SUBRC EQ 0.
    ELSE.
      CLEAR LV_STATUS.
      PERFORM GET_STATUS USING <LS_AFPO>-AUFNR
                            CHANGING LV_STATUS.

      LS_AUFNR_STATUS-AUFNR = <LS_AFPO>-AUFNR.
      LS_AUFNR_STATUS-STATUS = LV_STATUS.
      INSERT LS_AUFNR_STATUS INTO LT_AUFNR_STATUS INDEX LV_TABIX.

    ENDIF.

    IF LS_AUFNR_STATUS-STATUS = 'DEL'.

    ELSE.

* 완료처리된건이나 입고
      IF LS_AUFNR_STATUS-STATUS = 'DLV' AND <LS_AFPO>-WEMNG = 0.
        CONTINUE.
      ENDIF.

      CLEAR GS_SUM_QUAN.
      GS_SUM_QUAN-VBELN = <LS_AFPO>-KDAUF.
      GS_SUM_QUAN-POSNR = <LS_AFPO>-KDPOS.
      GS_SUM_QUAN-PSMNG = <LS_AFPO>-PSMNG - <LS_AFPO>-WEMNG.
      IF GS_SUM_QUAN-PSMNG NE 0. " 계산후 수량이 0 이라면 스크랩수량 제외 없음
        READ TABLE LT_2010 INTO LS_2010 WITH KEY ORDNR = <LS_AFPO>-AUFNR
                                                                      POSNR+2(4) = <LS_AFPO>-POSNR
                                                                      ORDTY = 'PRD'.
        IF SY-SUBRC EQ 0.
          GS_SUM_QUAN-PSMNG = GS_SUM_QUAN-PSMNG - <LS_AFPO>-PSAMG - ( LS_2010-QLENGTH + LS_2010-ADLENGTH ).
        ELSE.
          GS_SUM_QUAN-PSMNG = GS_SUM_QUAN-PSMNG - <LS_AFPO>-PSAMG.
        ENDIF.
      ENDIF.
      COLLECT  GS_SUM_QUAN INTO PT_SUM_QUAN .
    ENDIF.


    READ TABLE LT_SUM_MSEG INTO LS_SUM_MSEG WITH KEY AUFNR = <LS_AFPO>-AUFNR
                                                                    AUFPS = <LS_AFPO>-POSNR.
    IF SY-SUBRC EQ 0.
*  생산이력
      CLEAR GS_SUM_QUAN.
      GS_SUM_QUAN-VBELN = <LS_AFPO>-KDAUF.
      GS_SUM_QUAN-POSNR = <LS_AFPO>-KDPOS.
      GS_SUM_QUAN-INVENTORY = LS_SUM_MSEG-MENGE.
      COLLECT  GS_SUM_QUAN INTO PT_SUM_QUAN .
    ENDIF.

  ENDLOOP.

  SORT LT_MAIN BY VBELN POSNR.
  SORT LT_EBAN BY VBELN VBELP.
  DATA : LV_INLENGTH TYPE ZGTPPT2000-INLENGTH.
  DATA : LV_INFACTOR TYPE ZGTPPT2000-INFACTOR.
  DATA : LV_INSPE_YN      TYPE CHAR20,
         LV_INSPE_QLENGTH TYPE CHAR20,
         LV_INSPE_SPENGTH TYPE CHAR20.
  DATA : LV_MENGE TYPE MSEG-MENGE.
  DATA : LV_CHK_EXIST_561.
  DATA : LV_KWMENG TYPE VBAP-KLMENG.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    CLEAR LV_CHK_EXIST_561.
    READ TABLE LT_COLLECT_STOCKVAL INTO LS_COLLECT_STOCKVAL WITH KEY VBELN = LS_MAIN-VBELN
                                                                                                  POSNR = LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0.
      IF LS_COLLECT_STOCKVAL-MENGE >= LS_MAIN-KWMENG.
        CONTINUE.
      ELSE.
        IF LS_COLLECT_STOCKVAL-MENGE > 0.
          LV_CHK_EXIST_561 = ABAP_TRUE.
        ENDIF.

      ENDIF.
    ENDIF.

    CLEAR : GS_MAIN_DISP, LV_INSPE_YN, LV_INSPE_QLENGTH, LV_INSPE_SPENGTH.

    CLEAR : LV_INLENGTH, LV_INFACTOR, LV_MENGE.

*조장(기본단위)
*조장수
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = LS_MAIN-CUOBJ                 " 구성
      IMPORTING
        EV_ZGTEINDLEN = LV_INLENGTH
        EV_ZGTEFACTOR = LV_INFACTOR
        EV_PACK_YN = GS_MAIN_DISP-PACK_YN
        EV_INSPECTION    = LV_INSPE_YN
        EV_INSP_QLENG    = LV_INSPE_QLENGTH
        EV_INSP_SPLENG    = LV_INSPE_SPENGTH  ).

    IF LS_MAIN-KWMENG = 0.
      LS_MAIN-KWMENG = LV_INLENGTH * LV_INFACTOR.
    ENDIF.

    IF LV_CHK_EXIST_561 = ABAP_TRUE.
      CLEAR LV_KWMENG.
      LV_KWMENG = TRUNC( LS_COLLECT_STOCKVAL-MENGE / LV_INLENGTH ).
      LV_KWMENG = LV_KWMENG * LV_INLENGTH.
      LS_MAIN-KWMENG = LS_MAIN-KWMENG - LV_KWMENG.
    ENDIF.

    CASE GS_MAIN_DISP-PACK_YN.
      WHEN 'CM' OR 'NA'.
        GS_MAIN_DISP-STATUS_MARKING = ICON_LED_GREEN.
      WHEN OTHERS.
        GS_MAIN_DISP-STATUS_MARKING = ICON_LED_RED.
    ENDCASE.

    IF LV_INSPE_YN = '유'.
      LV_MENGE = LV_INSPE_QLENGTH + LV_INSPE_SPENGTH + 0.
      IF LV_MENGE = 0.
        GS_MAIN_DISP-STATUS_INSPECTION = ICON_LED_RED.
      ELSE.
        GS_MAIN_DISP-STATUS_INSPECTION = ICON_LED_GREEN.
      ENDIF.

    ELSE.
      GS_MAIN_DISP-STATUS_INSPECTION = ICON_LED_INACTIVE.
    ENDIF.

    GS_MAIN_DISP-ERDAT = LS_MAIN-ERDAT.

    READ TABLE PT_SUM_QUAN ASSIGNING FIELD-SYMBOL(<LS_DATA>) WITH KEY VBELN = LS_MAIN-VBELN
                                                                                                           POSNR =  LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0.
*    판매 오더 요구 부족량 계산
*    판매 오더 품목 수량 - (계획 오더 수량+ 생산 오더 잔량) - 판매오더 재고
      <LS_DATA>-SHORT_ORDER = LS_MAIN-KWMENG - ( <LS_DATA>-GSMNG + <LS_DATA>-PSMNG ) - <LS_DATA>-INVENTORY.

    ELSE.
      APPEND INITIAL LINE TO PT_SUM_QUAN ASSIGNING <LS_DATA>.
      <LS_DATA>-VBELN = LS_MAIN-VBELN.
      <LS_DATA>-POSNR =  LS_MAIN-POSNR.

      <LS_DATA>-SHORT_ORDER = LS_MAIN-KWMENG - ( <LS_DATA>-GSMNG + <LS_DATA>-PSMNG ) - <LS_DATA>-INVENTORY.
    ENDIF.

    MOVE-CORRESPONDING LS_MAIN TO GS_MAIN_DISP.
*  영업소 확인
    CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
      EXPORTING
        I_VKORG   = LS_MAIN-VKORG
        I_VKGRP   = LS_MAIN-VKGRP
        I_KDKG4   = LS_MAIN-KDKG4
      IMPORTING
        E_ZZYUSCD = GS_MAIN_DISP-ZZYUSCD.
    APPEND GS_MAIN_DISP TO PT_MAIN.
  ENDLOOP.

  IF S_YUSCD[] IS NOT INITIAL.
    DELETE PT_MAIN WHERE ZZYUSCD NOT IN S_YUSCD.
  ENDIF.

*  MOVE-CORRESPONDING LT_MAIN[] TO PT_MAIN[].

  LOOP AT PT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
* OEM 구매요청 확인
    READ TABLE  LT_EBAN INTO DATA(LS_EBAN) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                 VBELP = <LS_MAIN>-POSNR
                                                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHK_OEM = ABAP_TRUE.
      <LS_MAIN>-BANFN = LS_EBAN-BANFN.
      <LS_MAIN>-BNFPO = LS_EBAN-BNFPO.
      <LS_MAIN>-LFDAT = LS_EBAN-LFDAT.
      <LS_MAIN>-STATU = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                    IV_DOMNAME  = 'BANST'
                                    IV_DOMVALUE = CONV #( LS_EBAN-STATU ) ).

      <LS_MAIN>-PR_NAME1 = LS_EBAN-NAME1.
    ENDIF.

    READ TABLE LT_EKKO INTO DATA(LS_EKKO) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                      POSNR = <LS_MAIN>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHK_OEM = ABAP_TRUE.
      <LS_MAIN>-EBELN = LS_EKKO-EBELN.
      <LS_MAIN>-EBELP = LS_EKKO-EBELP.

      <LS_MAIN>-PR_NAME1 = LS_EKKO-NAME1.
    ENDIF.



  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAINDATA_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MAIN
*&      --> PT_SUM_QUAN
*&---------------------------------------------------------------------*
FORM GET_MAINDATA_PO.

  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : LS_MAIN LIKE  GS_MAIN_DISP.

  DATA : LV_STATUS TYPE CHAR10.
  DATA : BEGIN OF LS_CHK_2000,
           ORDNO TYPE ZGTPPT2000-ORDNO,
           POSNR TYPE  ZGTPPT2000-POSNR,
         END OF LS_CHK_2000.
  DATA : LT_CHK_2000 LIKE TABLE OF LS_CHK_2000.

  DATA : LT_2001 TYPE TABLE OF ZGTPPT2001.

  SELECT * FROM ZGTPPT2001
    INTO TABLE LT_2001
   WHERE ORDNO IN S_AUFNR
     AND WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND GLTRP >= S_DATE-LOW
     AND GSTRP <= S_DATE-HIGH
     AND MATNR IN S_MATNR
     AND ZDEL = ''.

  REFRESH LT_CHK_2000.
  MOVE-CORRESPONDING LT_2001 TO LT_CHK_2000.

  SORT LT_CHK_2000 BY ORDNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_2000 COMPARING ORDNO POSNR.

* 조장생성이력 조회
  IF LT_CHK_2000[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT2000
      INTO TABLE @DATA(LT_2000)
     FOR ALL ENTRIES IN @LT_CHK_2000
     WHERE ORDNO = @LT_CHK_2000-ORDNO
        AND POSNR = @LT_CHK_2000-POSNR
        AND GCATG = '생산오더'
        AND WERKS = @P_WERKS
        AND SPGCD = @P_SPGCD
        AND ZSTATUS NE 'D'.
  ENDIF.


  DATA : LV_VBELN_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LV_LPRIO_C(3).

* 모수 기준으로 조회
  LOOP AT LT_2001 INTO DATA(LS_2001).
    CLEAR LS_MAIN.

    LS_MAIN-GCATG = '생산오더'.

    LV_VBELN_C = LS_2001-ORDNO.
    LV_POSNR_C = LS_2001-POSNR.
    LV_LPRIO_C = LS_2001-ZZPRIORITY.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C, LV_LPRIO_C.

*    소요량 요소 : 판매오더/품목번호/우선순위
    CONCATENATE LV_VBELN_C LV_POSNR_C LV_LPRIO_C
                  INTO LS_MAIN-REQ_FACTOR SEPARATED BY '/'.

* 오더번호
    LS_MAIN-VBELN = LS_2001-ORDNO.

* 품목
    LS_MAIN-POSNR = LS_2001-POSNR + 0.

*조장(기본단위)
    LS_MAIN-ZGTEINDLEN = LS_2001-INLENGTH.
*조장수
    LS_MAIN-ZGTEFACTOR = LS_2001-INFACTOR.


    LS_MAIN-MATNR = LS_2001-MATNR.
* 제품내역
    LS_MAIN-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MAIN-MATNR ).

*   특성
    LS_MAIN-MEINS = LS_2001-MEINS.

* 오더 수량 총계
    LS_MAIN-KWMENG = LS_2001-GAMNG.

*   소요일
    LS_MAIN-EDATU = LS_2001-GLTRP.

*   우선순위
    LS_MAIN-LPRIO = LS_2001-ZZPRIORITY + 0.

*  가용수량 계산
    LS_MAIN-SHORT_ORDER = LS_MAIN-KWMENG.

    LOOP AT LT_2000 INTO DATA(LS_2000) WHERE ORDNO = LS_2001-ORDNO
                                                             AND POSNR = LS_2001-POSNR.

      LS_MAIN-SHORT_ORDER = LS_MAIN-SHORT_ORDER - ( LS_2000-INLENGTH * LS_2000-INFACTOR ).
    ENDLOOP.

    LS_MAIN-SHORT_ORDER2 = LS_MAIN-KWMENG * -1.
    LS_MAIN-SHORT_ORDER = LS_MAIN-SHORT_ORDER * -1.
    LS_MAIN-KWMENG2 = LS_MAIN-KWMENG * -1.

*  SM 오더의 경우 영업소 코드 '생관'
    LS_MAIN-ZZYUSCD = '생관'.
*   특성
    LS_MAIN-CHAR = ICON_CHARACTERISTICS_ACT.

    IF LS_MAIN-SHORT_ORDER = 0 AND P_ZERO IS INITIAL.
      CONTINUE.
    ENDIF.
    APPEND LS_MAIN TO GT_MAIN_DISP.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DUP_CHK
*&      --> LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_ROUTING  TABLES   PT_DUP_CHK STRUCTURE GS_ITEM_DISP
                  CHANGING    PV_CHK_ERR.

  LOOP AT PT_DUP_CHK INTO DATA(LS_TEMP).

    IF SY-TABIX = 1.
      SELECT B~GONG_SEQ, B~GONG_CD
        FROM ZGTCVMSTVAL AS A
        INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                          AND B~REV_SEQ = A~PDCADESIGNREVNO
        WHERE A~MATNR = @LS_TEMP-MATNR
          AND A~WERKS = @P_WERKS
        INTO TABLE @DATA(LT_ORIGN).

      SORT LT_ORIGN BY GONG_SEQ GONG_CD.
      DELETE ADJACENT DUPLICATES FROM LT_ORIGN COMPARING GONG_SEQ GONG_CD.

    ELSE.
      SELECT B~GONG_SEQ, B~GONG_CD
        FROM ZGTCVMSTVAL AS A
        INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                          AND B~REV_SEQ = A~PDCADESIGNREVNO
        WHERE A~MATNR = @LS_TEMP-MATNR
          AND A~WERKS = @P_WERKS
        INTO TABLE @DATA(LT_COMPARE).

      SORT LT_COMPARE BY GONG_SEQ GONG_CD.
      DELETE ADJACENT DUPLICATES FROM LT_COMPARE COMPARING GONG_SEQ GONG_CD.

      IF LINES( LT_ORIGN ) NE LINES( LT_COMPARE ).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      LOOP AT LT_ORIGN INTO DATA(LS_ORIGN).
        READ TABLE LT_COMPARE ASSIGNING FIELD-SYMBOL(<LS_COMPARE>) WITH KEY GONG_SEQ = LS_ORIGN-GONG_SEQ.
        IF SY-SUBRC EQ 0.
          IF LS_ORIGN-GONG_CD = <LS_COMPARE>-GONG_CD.
            DELETE TABLE LT_COMPARE FROM <LS_COMPARE>.
          ELSE.
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.
        ELSE.
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDLOOP.

      IF LT_COMPARE[] IS NOT INITIAL.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_ROUTING_DB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_2000
*&      --> LS_OLD_2000_MATNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_ROUTING_DB  TABLES   PT_2000 STRUCTURE ZGTPPT2000
                     USING    PV_MATNR
                     CHANGING PV_CHK_ERR.

  READ TABLE PT_2000 TRANSPORTING NO FIELDS WITH KEY MATNR = PV_MATNR.
  IF SY-SUBRC EQ 0. " 동일 생성자재가 있으므로 조장 동일하다고 판단
    RETURN.
  ENDIF.

* 조장 구성 비교
  SELECT B~GONG_SEQ, B~GONG_CD
    FROM ZGTCVMSTVAL AS A
    INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                      AND B~REV_SEQ = A~PDCADESIGNREVNO
    WHERE A~MATNR = @PV_MATNR
      AND A~WERKS = @P_WERKS
    INTO TABLE @DATA(LT_ORIGN).

* 저장대상끼리는 사전에 점검 되었으므로 1개의 자재만 가져와서 비교
  READ TABLE PT_2000 INTO DATA(LS_2000) INDEX 1.

  SELECT B~GONG_SEQ, B~GONG_CD
    FROM ZGTCVMSTVAL AS A
    INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                      AND B~REV_SEQ = A~PDCADESIGNREVNO
    WHERE A~MATNR = @LS_2000-MATNR
      AND A~WERKS = @P_WERKS
    INTO TABLE @DATA(LT_COMPARE).

  IF LINES( LT_ORIGN ) NE LINES( LT_COMPARE ).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_ORIGN INTO DATA(LS_ORIGN).
    READ TABLE LT_COMPARE ASSIGNING FIELD-SYMBOL(<LS_COMPARE>) WITH KEY GONG_SEQ = LS_ORIGN-GONG_SEQ.
    IF SY-SUBRC EQ 0.
      IF LS_ORIGN-GONG_CD = <LS_COMPARE>-GONG_CD.
        DELETE TABLE LT_COMPARE FROM <LS_COMPARE>.
      ELSE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ELSE.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDLOOP.

  IF LT_COMPARE[] IS NOT INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CREATE .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.
  DATA : LV_STRING TYPE STRING.
*  필드 빈값 체크
  CLEAR LV_MESSAGE.
  PERFORM SCREEN_400_CHK_INIT CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM SCREEN_400_CHK_VALIDATION  CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  CALL METHOD GO_TEXT_300->GET_TEXT_AS_R3TABLE( EXPORTING ONLY_WHEN_MODIFIED = ' ' IMPORTING TABLE = GT_TEXT ).
  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    LV_STRING = |{ LV_STRING }{ LS_TEXT }{  CL_ABAP_CHAR_UTILITIES=>NEWLINE }|.
  ENDLOOP.

  IF CHARLEN( LV_STRING ) > 255.
    MESSAGE I003 WITH '특기사항은 255자를 넘을수 없습니다.'.
    RETURN.
  ENDIF.

  PERFORM CREATE_ORDERS CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    GV_CHK_CREATE = 'E'. " 실패
  ELSE.
    GV_CHK_CREATE = 'S'. " 성공
  ENDIF.

  GO_CONTAINER_300->FREE( ).
  GO_TEXT_300->FREE( ).
  FREE : GO_CONTAINER_300, GO_TEXT_300.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_INIT  CHANGING PV_MESSAGE.

  IF GS_MAKE_ORDER-MATNR IS INITIAL.
    PV_MESSAGE = TEXT-E01.
  ENDIF.

*  IF GS_MAKE_ORDER-GAMNG IS INITIAL OR GS_MAKE_ORDER-GAMNG = 0.
*    PV_MESSAGE = TEXT-E02.
*  ENDIF.


  IF GS_MAKE_ORDER-GSTRP IS INITIAL OR GS_MAKE_ORDER-GSTRP = '00000000'.
    PV_MESSAGE = TEXT-E03.
  ENDIF.

  IF GS_MAKE_ORDER-GLTRP IS INITIAL OR GS_MAKE_ORDER-GLTRP = '00000000'.
    PV_MESSAGE = TEXT-E04.
  ENDIF.


  IF GS_MAKE_ORDER-INLENGTH IS INITIAL OR GS_MAKE_ORDER-INLENGTH = 0.
    PV_MESSAGE = TEXT-E05.
  ENDIF.

  IF GS_MAKE_ORDER-INFACTOR IS INITIAL OR GS_MAKE_ORDER-INFACTOR = 0.
    PV_MESSAGE = TEXT-E06.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_VALIDATION  CHANGING PV_MESSAGE.

* 생산자재
  SELECT * FROM ZGTCVMSTVAL
       INTO TABLE @DATA(LT_MATNR)
     WHERE WERKS = @P_WERKS
       AND MATNR = @GS_MAKE_ORDER-MATNR
       AND SPG = @P_SPGCD
       AND MTREF = 'FERT'
       AND LVORMC = ''
       AND LVORMP = ''
       AND MMSTA = ''
       AND ( BESKZ <> 'F'
        OR BESKZ = 'F' AND SOBSL = '30' ).

  IF SY-SUBRC NE 0.
    PV_MESSAGE = TEXT-E07.
    RETURN.
  ENDIF.

  GS_MAKE_ORDER-GAMNG = GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR.
  IF GS_MAKE_ORDER-GAMNG <= 0.
    PV_MESSAGE = TEXT-E18.
    RETURN.
  ENDIF.

  IF GS_MAKE_ORDER-GSTRP > GS_MAKE_ORDER-GLTRP.
    PV_MESSAGE = TEXT-E08.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_ORDERS  CHANGING PV_CHK_ERR.

  DATA : LS_SAVE_2001 TYPE ZGTPPT2001.
  DATA : LV_CHK_ERR.

* SM 생산오더는 ZGTPPT2001 테이블에 저장
  CLEAR LS_SAVE_2001.
  PERFORM GET_ORDNO CHANGING LS_SAVE_2001-ORDNO LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    PV_CHK_ERR = 'E'.
    MESSAGE S006 WITH '생산오더(SM) 생성중 오류 발생하였습니다.'  INTO GV_MESSAGE_300.
    RETURN.
  ENDIF.

  LS_SAVE_2001-POSNR = 1.
  LS_SAVE_2001-WERKS = P_WERKS.
  LS_SAVE_2001-SPGCD = P_SPGCD.
  LS_SAVE_2001-GSTRP = GS_MAKE_ORDER-GSTRP.
  LS_SAVE_2001-GLTRP = GS_MAKE_ORDER-GLTRP.
  LS_SAVE_2001-MATNR = GS_MAKE_ORDER-MATNR.
  LS_SAVE_2001-INLENGTH = GS_MAKE_ORDER-INLENGTH.
  LS_SAVE_2001-INFACTOR = GS_MAKE_ORDER-INFACTOR.
  LS_SAVE_2001-GAMNG = GS_MAKE_ORDER-GAMNG.
  LS_SAVE_2001-MEINS = GS_MAKE_ORDER-GMEIN.
  LS_SAVE_2001-ZPMAT = GS_MAKE_ORDER-COV_MATNR.
  LS_SAVE_2001-ZZPRIORITY = GS_MAKE_ORDER-ZZPRIORITY.

  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    LS_SAVE_2001-SNOTE = |{ LS_SAVE_2001-SNOTE }{ LS_TEXT }{  CL_ABAP_CHAR_UTILITIES=>NEWLINE }|.
  ENDLOOP.
*  LS_SAVE_2001-SNOTE = GS_MAKE_ORDER-SNOTE.
*LS_SAVE_2001-ZDEL
  LS_SAVE_2001-CRNAM  = SY-UNAME.

  MODIFY ZGTPPT2001 FROM LS_SAVE_2001.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PV_CHK_ERR = 'E'.
    MESSAGE S006 WITH '생산오더(SM) 생성중 오류 발생하였습니다.'  INTO GV_MESSAGE_300.
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.


**  DATA : LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.
**  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
**  DATA: LS_RETURN TYPE BAPIRET2.
**  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
**
**
**  CLEAR : LS_ORDER, LS_RETURN, LV_ORDER_NUMBER.
***  오더 생성
**  LS_ORDER-MATERIAL = GS_MAKE_ORDER-MATNR.
**  LS_ORDER-PLANT = P_WERKS.
**  LS_ORDER-ORDER_TYPE = 'PP05'.
**  LS_ORDER-BASIC_START_DATE = GS_MAKE_ORDER-GSTRP.
**  LS_ORDER-BASIC_END_DATE = GS_MAKE_ORDER-GLTRP.
**  LS_ORDER-QUANTITY = GS_MAKE_ORDER-GAMNG.
**  IF GS_MAKE_ORDER-ZZPRIORITY NE 0.
**    LS_ORDER-ORDER_PRIORITY = GS_MAKE_ORDER-ZZPRIORITY.
**  ENDIF.
**  LS_ORDER-BASIC_SCHEDULING_TYPE = '7'.
**
**  CALL FUNCTION 'BAPI_PRODORD_CREATE'
**    EXPORTING
**      ORDERDATA    = LS_ORDER
**    IMPORTING
**      RETURN       = LS_RETURN
**      ORDER_NUMBER = LV_ORDER_NUMBER.
**
**  IF LS_RETURN-TYPE NE 'E'.
**    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**      EXPORTING
**        WAIT = ABAP_TRUE.
**
***      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
**    DO .
**      SELECT SINGLE AUFNR, POSNR
**        FROM AFPO
**       WHERE AUFNR = @LV_ORDER_NUMBER
**        INTO @DATA(LS_AFPO).
**      IF SY-SUBRC EQ 0.
**        EXIT.
**      ELSE.
**        WAIT UP TO '0.5' SECONDS.
**      ENDIF.
**    ENDDO.
**
**    PERFORM CHANG_BDC_JOJANG USING LV_ORDER_NUMBER PV_CHK_ERR.
**    IF PV_CHK_ERR = ABAP_TRUE.
**      PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
**      MESSAGE S003 WITH TEXT-E10 INTO GV_MESSAGE_300.
**      RETURN.
**    ENDIF.
**
**    APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
**    <LS_ORDER>-ORDER_NUMBER =  LV_ORDER_NUMBER.
**  ELSE.
**    PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
**    MESSAGE S003 WITH TEXT-E09 INTO GV_MESSAGE_300.
**    PV_CHK_ERR = ABAP_TRUE.
**    RETURN.
**  ENDIF.

  MESSAGE S006 WITH '생산오더(SM) 생성되었습니다. -' LS_SAVE_2001-ORDNO  INTO GV_MESSAGE_300.


**  DATA : LT_ZPPTC002 TYPE TABLE OF ZPPTC002.
**  LOOP AT LT_PRD_ORDERS INTO DATA(LS_PRD_ORDERS).
**    APPEND INITIAL LINE TO LT_ZPPTC002 ASSIGNING FIELD-SYMBOL(<LS_SAVE_DATA>).
**    <LS_SAVE_DATA>-AUFNR = LS_PRD_ORDERS-ORDER_NUMBER.
**    <LS_SAVE_DATA>-POSNR = '0001'.
**    <LS_SAVE_DATA>-PSAMG = GS_MAKE_ORDER-QLENGTH.
**  ENDLOOP.
**
**  IF LT_ZPPTC002[] IS NOT INITIAL.
**    MODIFY ZPPTC002 FROM TABLE LT_ZPPTC002.
**    IF SY-SUBRC EQ 0.
**      COMMIT WORK AND WAIT.
**    ENDIF.
**  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANG_BDC_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ORDER_NUMBER
*&      --> PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHANG_BDC_JOJANG  USING    PV_AUFNR
                                                 PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LV_PSMNG_C(30) TYPE C.
  DATA : LV_TABIX TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FNAM_____4.
  REFRESH : GT_BDCDATA, GT_MESSTAB.

  LV_INLENGTH = GS_MAKE_ORDER-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  LV_INFACTOR = 1.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_AUFNR,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=+COI'. " 빠른입력화면으로 전환



  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=KOTA', " 빠른입력화면으로 전환
                      'GV_ZZPRIORITY' GS_MAKE_ORDER-ZZPRIORITY. " 빠른입력화면으로 전환

  CLEAR LV_TABIX.
  DO GS_MAKE_ORDER-INFACTOR TIMES.
    ADD 1 TO LV_TABIX.
    IF LV_NUM < 2 .
      ADD 1 TO LV_NUM.
    ENDIF.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD : 'BDC_OKCODE' '/00'. " 빠른입력화면으로 전환


    IF LV_TABIX NE 1.
*      자재정보
      LV_FIELDNAME = 'MILL_PP_SE-MATNR(' && LV_NUM && ')'.
      __BDC_FIELD :  LV_FIELDNAME GS_MAKE_ORDER-MATNR.
*      단위
      LV_FIELDNAME = 'MILL_PP_SE-AMEIN(' && LV_NUM && ')'.
      __BDC_FIELD :  LV_FIELDNAME GS_MAKE_ORDER-GMEIN.
    ENDIF.

*    수량 입력
    LV_FIELDNAME = 'MILL_PP_SE-PSMNG(' && LV_NUM && ')'.
    LV_PSMNG_C = GS_MAKE_ORDER-INLENGTH.

    CONDENSE LV_PSMNG_C.
    __BDC_FIELD :  LV_FIELDNAME LV_PSMNG_C.

    IF LV_TABIX >= 3.
      __BDC_DYNPRO 'SAPLKOBS' '0130'.
      __BDC_FIELD :  'BDC_OKCODE' '=BACK'.
    ENDIF.


    IF LV_TABIX = 1.
*       최초 특성값 복사 때문에 1번 라인은 2번 클릭
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
      LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
      __BDC_FIELD :  LV_FIELDNAME 'X'.

      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
    ELSE.
      __BDC_DYNPRO 'SAPLCOKO1' '0115'.
      __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
      LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
      __BDC_FIELD :  LV_FIELDNAME 'X'.
    ENDIF.

    __BDC_DYNPRO 'SAPLCEI0' '0109'.
    __BDC_FIELD : 'RCTMS-MNAME(01)' '조장(기본단위)',
                        'RCTMS-MNAME(02)' '조장수',
                        'RCTMS-MWERT(01)' LV_INLENGTH_C,
                        'RCTMS-MWERT(02)' LV_INFACTOR_C,
                        'BDC_OKCODE' '=BACK'.

    __BDC_DYNPRO 'SAPLCOKO1' '0115'.
    __BDC_FIELD :  'BDC_OKCODE' '/00'.
    LV_FIELDNAME = 'MILL_PP_SE-MARK(01)'.
    __BDC_FIELD :  LV_FIELDNAME ' '.

  ENDDO.

*  수량 재계산
  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_MP_HEADER_QUANT'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  EXPORT LV_CHK_MULTY = ABAP_TRUE TO MEMORY ID 'ZBDC'.

  __BDC_TRANSACTION 'CO02'.

  FREE MEMORY ID 'ZBDC'.

  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.
    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.

  COMMIT WORK AND  WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLLBACK_ORDES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRD_ORDERS
*&---------------------------------------------------------------------*
FORM ROLLBACK_ORDES  TABLES   PT_PRD_ORDERS STRUCTURE BAPI_ORDER_KEY.

  DATA : LS_RETURN2 TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN2
    TABLES
      ORDERS        = PT_PRD_ORDERS[]
      DETAIL_RETURN = LT_DETAIL_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_PO .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_ORDERS TYPE TABLE OF ZGTPPT2001.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
  DATA : LV_STATUS TYPE CHAR10.
  DATA : LV_AUFNR TYPE AUFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.
    IF GS_MAIN_DISP-GCATG = '생산오더'.
* 유효성 확인
*      1)조장구성표 존재시 삭제불가
      SELECT SINGLE * FROM ZGTPPT2000
        WHERE ORDNO = @GS_MAIN_DISP-VBELN
          AND ZSTATUS NE 'D'
        INTO @DATA(LS_2000).
      IF SY-SUBRC EQ 0 OR LS_2000 IS NOT INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 생산오더(SM)가 조장구성표에 포함되어 있습니다. - '(m21)  GS_MAIN_DISP-VBELN.
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDNO>).
      <LS_ORDNO>-ORDNO = GS_MAIN_DISP-VBELN.

    ENDIF.

  ENDLOOP.

  IF LT_ORDERS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 생산오더가 없습니다'(m20).
    GV_CHK_DEL = 'E'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ORDERS INTO DATA(LS_ORDERS).
    UPDATE ZGTPPT2001 SET ZDEL = ABAP_TRUE
     WHERE ORDNO = LS_ORDERS-ORDNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      GV_CHK_DEL = 'E'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF GV_CHK_DEL NE 'E'.
    COMMIT WORK AND WAIT.
    GV_CHK_DEL = 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : BEGIN OF LS_CHK_2000,
           ORDNO TYPE ZGTPPT2000-ORDNO,
           POSNR TYPE  ZGTPPT2000-POSNR,
         END OF LS_CHK_2000.
  DATA : LV_CHK_ERR.

  DATA : LT_LIFNR LIKE TABLE OF GS_LIFNR.

  REFRESH GT_LIFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @GS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

    IF GS_MAIN_DISP-GCATG NE '판매오더'.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '판매오더만 OEM 구매요청 진행 할 수 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-CHK_OEM IS NOT INITIAL.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청 진행 중인 판매오더 입니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-STATUS_INSPECTION = ICON_LED_RED.
      GV_CHK_CREATE = 'E'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '입회검사여장 대상이나 검사여장 지정되지 않은 S/O 입니다.' '확인 후 재 작업 해주세요.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-STATUS_MARKING = ICON_LED_RED.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '포장재 확정이 진행되지 않은 S/O 입니다. 확인 후 재 작업 해주세요.'.
      RETURN.
    ENDIF.

    CLEAR LS_CHK_2000.
    LS_CHK_2000-ORDNO = GS_MAIN_DISP-VBELN.
    LS_CHK_2000-POSNR = GS_MAIN_DISP-POSNR.

* 조장생성이력 조회
    SELECT SINGLE * FROM ZGTPPT2000
      INTO @DATA(LS_2000)
     WHERE ORDNO = @LS_CHK_2000-ORDNO
        AND POSNR = @LS_CHK_2000-POSNR
        AND WERKS = @P_WERKS
        AND SPGCD = @P_SPGCD
        AND ZSTATUS NE 'D'.

    IF SY-SUBRC EQ 0.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '조장구성표 생성된 판매오더 입니다.'.
      RETURN.
    ENDIF.

*    REFRESH LT_LIFNR.
** 공급업체 정보 추출
*    SELECT A~MATNR, A~INFNR, A~LIFNR, C~NAME1
*      FROM EINA AS A
*      INNER JOIN EINE AS B ON B~INFNR = A~INFNR
*      INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
*    WHERE A~MATNR = @GS_MAIN_DISP-MATNR
*       AND A~LOEKZ = ''
*       AND B~EKORG = @GS_EKORG-EKORG
*      INTO CORRESPONDING FIELDS OF TABLE @LT_LIFNR.
*    IF LT_LIFNR[] IS INITIAL.
*      GV_CHK_CREATE = 'E'.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH '제품을 공급할 업체가 등록되지 않았습니다.'.
*      RETURN.
*    ENDIF.

*    APPEND LINES OF LT_LIFNR TO GT_LIFNR.
    APPEND GS_MAIN_DISP TO LT_MAIN.

  ENDLOOP.

*  SORT GT_LIFNR BY MATNR INFNR LIFNR.
*  DELETE ADJACENT DUPLICATES FROM GT_LIFNR COMPARING MATNR INFNR LIFNR.


  IF LT_MAIN[] IS INITIAL.
    GV_CHK_CREATE = 'E'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
    RETURN.
  ENDIF.

  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  LOOP AT LT_MAIN INTO GS_MAIN_DISP.
    CLEAR LV_CHK_ERR.
    CLEAR GS_PR_INFOR.

    GS_PR_INFOR-ORGNO = GS_MAIN_DISP-VBELN. "오더번호
    GS_PR_INFOR-POSNR = GS_MAIN_DISP-POSNR. "품목
    GS_PR_INFOR-EKORG = GS_EKORG-EKORG. "구매조직
    GS_PR_INFOR-EKGRP = GS_EKORG-EKGRP. " 완제품 구매그룹
    GS_PR_INFOR-MATNR = GS_MAIN_DISP-MATNR.
    GS_PR_INFOR-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP-MATNR ).
    GS_PR_INFOR-EEIND = GS_MAIN_DISP-EDATU - 1.

    ADD 1 TO LV_TOT_CNT.

* 공급업체 선정 제외
*    REFRESH LT_LIFNR.
*    LT_LIFNR = VALUE #( FOR LW_LIFNR IN GT_LIFNR WHERE ( MATNR = GS_MAIN_DISP-MATNR )
*                              ( CORRESPONDING #( LW_LIFNR ) ) ).
*
*    READ TABLE LT_LIFNR INTO DATA(LS_LIFNR) INDEX 1.
*    GS_PR_INFOR-INFNR = LS_LIFNR-INFNR. "구매정보레코드
*    GS_PR_INFOR-LIFNR = LS_LIFNR-LIFNR. " 구매처
*    GS_PR_INFOR-NAME1 = LS_LIFNR-NAME1.
*
*    REFRESH GT_DISP_LIFNR.
*    MOVE-CORRESPONDING LT_LIFNR TO GT_DISP_LIFNR.
*    CALL SCREEN '0400' STARTING AT 10 5 ENDING AT 93 10.
*    IF GS_PR_INFOR IS INITIAL.
*      CONTINUE. " 실패로 처리
*    ENDIF.

    PERFORM CREATE_PR CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ENDIF.
  ENDLOOP.

  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.

  LV_MESSAGE = |선택 주문 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 생성되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.

  GV_CHK_CREATE = 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : BEGIN OF LS_CHK_2000,
           ORDNO TYPE ZGTPPT2000-ORDNO,
           POSNR TYPE  ZGTPPT2000-POSNR,
         END OF LS_CHK_2000.
  DATA : LV_CHK_ERR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

    IF GS_MAIN_DISP-GCATG NE '판매오더'.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청되지 않은 라인이 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-CHK_OEM IS INITIAL.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청되지 않은 라인이 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-EBELN IS NOT INITIAL.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 오더로 생성된 구매 요청으로 삭제 할 수 없습니다.'.
      RETURN.
    ENDIF.

    APPEND GS_MAIN_DISP TO LT_MAIN.

  ENDLOOP.

  IF LT_MAIN[] IS INITIAL.
    GV_CHK_DEL = 'E'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매요청이 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  LOOP AT LT_MAIN INTO GS_MAIN_DISP.
    CLEAR LV_CHK_ERR.
    ADD 1 TO LV_TOT_CNT.
    PERFORM DELETE_PR CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ENDIF.
  ENDLOOP.

  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.

  LV_MESSAGE = |선택 구매요청 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 삭제되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.

  GV_CHK_DEL = 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PR  CHANGING PV_CHK_ERR.

*BDC로 전환
***  DATA : LS_PRHEADER TYPE BAPIMEREQHEADER.
***  DATA : LS_PRHEADERX TYPE BAPIMEREQHEADERX.
***  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
***  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
***  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
***  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.
***  DATA : LT_PRACCOUNT  TYPE TABLE OF BAPIMEREQACCOUNT.
***  DATA : LT_PRACCOUNTX  TYPE TABLE OF BAPIMEREQACCOUNTX.
***  DATA : LT_PRACCOUNTPROITSEGMENT TYPE TABLE OF BAPIMEREQACCOUNTPROFITSEG.
***
**** Header 정보 입력
***  LS_PRHEADER-PR_TYPE = 'NB'.
***  LS_PRHEADERX-PR_TYPE = ABAP_TRUE.
***
**** Item 정보 입력
***  APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
***  <LS_PRITEM>-PREQ_ITEM = '0010'.
***  <LS_PRITEM>-ACCTASSCAT = 'M'.
***  <LS_PRITEM>-MATERIAL = GS_MAIN_DISP-MATNR.
***  <LS_PRITEM>-PLANT = P_WERKS.
***  <LS_PRITEM>-QUANTITY = GS_MAIN_DISP-KWMENG2 * -1.
***  <LS_PRITEM>-DELIV_DATE = GS_MAIN_DISP-EDATU - 1.
***  <LS_PRITEM>-PURCH_ORG = '1400'.
***  <LS_PRITEM>-PUR_GROUP = 'Z33'.
***  <LS_PRITEM>-PREQ_NAME = SY-UNAME.
***
**** ItemX 정보 입력
***  APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
***  <LS_PRITEMX>-PREQ_ITEM = '0010'.
***  <LS_PRITEMX>-ACCTASSCAT = ABAP_TRUE.
***  <LS_PRITEMX>-MATERIAL = ABAP_TRUE.
***  <LS_PRITEMX>-PLANT = ABAP_TRUE.
***  <LS_PRITEMX>-QUANTITY = ABAP_TRUE.
***  <LS_PRITEMX>-DELIV_DATE = ABAP_TRUE.
***  <LS_PRITEMX>-PURCH_ORG = ABAP_TRUE.
***  <LS_PRITEMX>-PUR_GROUP = ABAP_TRUE.
***  <LS_PRITEMX>-PREQ_NAME = ABAP_TRUE.
***
**** Praccount 정보 입력
***  APPEND INITIAL LINE TO LT_PRACCOUNT ASSIGNING FIELD-SYMBOL(<LS_PRACCOUNT>).
***  <LS_PRACCOUNT>-PREQ_ITEM = '0010'.
***  <LS_PRACCOUNT>-SERIAL_NO = '01'.
***  <LS_PRACCOUNT>-SD_DOC = GS_MAIN_DISP-VBELN.
***  <LS_PRACCOUNT>-ITM_NUMBER = GS_MAIN_DISP-POSNR.
***
**** PraccountX 정보 입력
***  APPEND INITIAL LINE TO LT_PRACCOUNTX ASSIGNING FIELD-SYMBOL(<LS_PRACCOUNTX>).
***  <LS_PRACCOUNTX>-PREQ_ITEM = '0010'.
***  <LS_PRACCOUNTX>-SERIAL_NO = '01'.
***  <LS_PRACCOUNTX>-SD_DOC = ABAP_TRUE.
***  <LS_PRACCOUNTX>-ITM_NUMBER = ABAP_TRUE.
***
***  CALL FUNCTION 'BAPI_PR_CREATE'
***    EXPORTING
***      PRHEADER              = LS_PRHEADER
***      PRHEADERX             = LS_PRHEADERX
***    IMPORTING
***      NUMBER                = LV_NUMBER
***    TABLES
***      RETURN                = LT_RETURN
***      PRITEM                = LT_PRITEM
***      PRITEMX               = LT_PRITEMX
***      PRACCOUNT             = LT_PRACCOUNT
***      PRACCOUNTX            = LT_PRACCOUNTX.
***
***  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
***    PV_CHK_ERR = ABAP_TRUE.
***    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
***  ELSE.
***    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
***      EXPORTING
***        WAIT = ABAP_TRUE.
***  ENDIF.


* 펑션 대체로 bdc로직 삭제
**  DATA : LV_INLENGTH TYPE I.
**  DATA : LV_INLENGTH_C(10) TYPE C.
**  DATA : LV_INFACTOR TYPE I.
**  DATA : LV_INFACTOR_C(10) TYPE C.
**  DATA : LV_PSMNG_C(30) TYPE C.
**  DATA : LV_DATE TYPE SY-DATUM.
**  DATA : LV_TABIX TYPE I.
**  DATA : LV_NUM(2) TYPE N.
**  DATA : LV_FIELDNAME TYPE FNAM_____4.
**  REFRESH : GT_BDCDATA, GT_MESSTAB.
**
**  LV_INLENGTH = GS_MAIN_DISP-ZGTEINDLEN.
**  LV_INLENGTH_C = LV_INLENGTH.
**  CONDENSE LV_INLENGTH_C.
**
**  LV_INFACTOR = GS_MAIN_DISP-ZGTEFACTOR.
**  LV_INFACTOR_C = LV_INFACTOR.
**  CONDENSE LV_INFACTOR_C.
**
**  LV_PSMNG_C = GS_MAIN_DISP-KWMENG2 * -1.
**  CONDENSE : LV_INLENGTH_C, LV_INFACTOR_C, LV_PSMNG_C.
**
**  LV_DATE = GS_MAIN_DISP-EDATU - 1.
**
**  __SETTING_BDC_PARAMS.
**
**  __BDC_DYNPRO 'SAPMM06B' '0100'.
**  __BDC_FIELD : 'BDC_OKCODE' '=AB',
**                      'EBAN-BSART'  'NB',
**                      'EBAN-KNTTP' 'M',
**                      'RM06B-EEIND' LV_DATE,
**                      'RM06B-LPEIN' 'T',
**                      'EBAN-WERKS' P_WERKS,
**                      'EBAN-EKGRP' 'Z33',
**                      'EBAN-AFNAM' SY-UNAME.
**
**
**
**  __BDC_DYNPRO 'SAPMM06B' '0106'.
**  __BDC_FIELD : 'BDC_OKCODE' '=DETA',
**                      'RM06B-TCSELFLAG(01)'  'X',
**                      'EBAN-MATNR(01)' GS_MAIN_DISP-MATNR,
**                      'EBAN-MENGE(01)' LV_PSMNG_C.
**
**  __BDC_DYNPRO 'SAPMM06B' '0102'.
**  __BDC_FIELD : 'BDC_OKCODE' '=KN',
**                      'EBAN-EKORG'  '1400',
**
**
**  __BDC_DYNPRO 'SAPMM06B' '0505'.
**  __BDC_FIELD : 'BDC_OKCODE' '=KWE'.
**
**  __BDC_DYNPRO 'SAPLKACB' '0002'.
**  __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
**                      'COBL-KDAUF' GS_MAIN_DISP-VBELN,
**                      'COBL-KDPOS' GS_MAIN_DISP-POSNR.
**
**  __BDC_DYNPRO 'SAPMM06B' '0106'.
**  __BDC_FIELD : 'BDC_OKCODE' '=KONF',
**                      'RM06B-TCSELFLAG(01)'  'X',
**                      'RM06B-BNFPO' '0010'.
**
**  __BDC_DYNPRO 'SAPMM06B' '0102'.
**  __BDC_FIELD : 'BDC_OKCODE' '=KONF'.
**
**  __BDC_DYNPRO 'SAPLCEI0' '0109'.
**  __BDC_FIELD : 'BDC_OKCODE' '=BACK',
**                      'RCTMS-MNAME(01)'  'SAP_MILLCA_LENGTH',
**                      'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
**                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
**                      'RCTMS-MWERT(02)' LV_INFACTOR_C.
**
**  __BDC_DYNPRO 'SAPMM06B' '0106'.
**  __BDC_FIELD : 'BDC_OKCODE' '=BU'.
**
**
**  __BDC_TRANSACTION 'ME51'.
**
**  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
**                                                         AND MSGID = '06'
**                                                         OR MSGNR = '406'.
**    DATA(LV_CHK_SUCESS) = ABAP_TRUE.
**  ENDLOOP.
**
**  IF LV_CHK_SUCESS IS INITIAL.
**    PV_CHK_ERR = 'E'.
**    RETURN.
**  ENDIF.
**
**  COMMIT WORK AND  WAIT.

  DATA : LV_INLENGTH TYPE MENGE_D.
  DATA : LV_INLENGTH_C(20) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(20) TYPE C.
  DATA : LS_PR_INFOR TYPE ZGTPPS0004.
  DATA : LT_CHART TYPE ZGTPPY0005.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_PSMNG_C(30) TYPE C.

  LV_INLENGTH = GS_MAIN_DISP-ZGTEINDLEN.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
  <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
  <LS_CHART>-ATWRT = LV_INLENGTH_C.


  LV_INFACTOR = GS_MAIN_DISP-ZGTEFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
  <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
  <LS_CHART>-ATWRT = LV_INFACTOR_C.

  LV_PSMNG_C = GS_MAIN_DISP-KWMENG.
  CONDENSE : LV_PSMNG_C.


  CLEAR LS_PR_INFOR.
  LS_PR_INFOR-BSART = 'NB'.
  LS_PR_INFOR-KNTTP = 'M'.
*  LV_DATE = GS_MAIN_DISP-EDATU - 1.
  LS_PR_INFOR-EEIND = GS_PR_INFOR-EEIND.
  LS_PR_INFOR-LPEIN = 'T'.
  LS_PR_INFOR-WERKS = P_WERKS.
  LS_PR_INFOR-EKGRP = GS_EKORG-EKGRP.
  LS_PR_INFOR-AFNAM = SY-UNAME.
  LS_PR_INFOR-MATNR = GS_MAIN_DISP-MATNR.
  LS_PR_INFOR-EKORG = GS_EKORG-EKORG.
  LS_PR_INFOR-MENGE = LV_PSMNG_C.

*  LS_PR_INFOR-INFNR = GS_PR_INFOR-INFNR.
*  LS_PR_INFOR-LIFNR = GS_PR_INFOR-LIFNR.
  LS_PR_INFOR-KDAUF = GS_MAIN_DISP-VBELN.
  LS_PR_INFOR-KDPOS = GS_MAIN_DISP-POSNR.

  DATA : LV_RESULT TYPE CHAR01.

  CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
    EXPORTING
      IS_PR_INFOR = LS_PR_INFOR
    IMPORTING
      EV_RESULT   = LV_RESULT
    TABLES
      IT_CHART    = LT_CHART.

  IF LV_RESULT NE 'S'.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM DELETE_PR  CHANGING PV_CHK_ERR.

  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  LV_NUMBER = GS_MAIN_DISP-BANFN.

* Item 정보 입력
  APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
  <LS_PRITEM>-PREQ_ITEM = '0010'.
  <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
  APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
  <LS_PRITEMX>-PREQ_ITEM = '0010'.
  <LS_PRITEMX>-DELETE_IND = 'X'.

  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      NUMBER  = LV_NUMBER
    TABLES
      RETURN  = LT_RETURN
      PRITEM  = LT_PRITEM
      PRITEMX = LT_PRITEMX.

  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
    PV_CHK_ERR = ABAP_TRUE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  SET TITLEBAR '0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form F4HELP_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_LIFNR .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA : BEGIN OF LS_LIFNR,
           LIFNR TYPE EBAN-LIFNR,
           NAME1 TYPE LFA1-NAME1,
         END OF LS_LIFNR.
  DATA : LT_LIFNR LIKE TABLE OF LS_LIFNR.

  DATA : LV_LIFNR TYPE EBAN-LIFNR.

  MOVE-CORRESPONDING GT_DISP_LIFNR TO LT_LIFNR.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_LIFNR.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'LIFNR'.
        <LS_FIELD_TAB>-REPTEXT  = '구매처'.
      WHEN 'NAME1'.
        <LS_FIELD_TAB>-REPTEXT  = '내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPROFIELD     = 'GS_PR_INFOR-LIFNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '구매처 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_LIFNR                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*  구매처
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_PR_INFOR-LIFNR'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CLEAR LV_LIFNR.
    LV_LIFNR = LS_RETURN_TAB-FIELDVAL..
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_LIFNR
      IMPORTING
        OUTPUT = LV_LIFNR.

    READ TABLE LT_LIFNR INTO LS_LIFNR WITH KEY LIFNR = LV_LIFNR.

*  구매처 내역
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_PR_INFOR-NAME1'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_LIFNR-NAME1.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_AND_SET_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_AND_SET_LIFNR .

  IF GS_PR_INFOR-LIFNR IS INITIAL.
    MESSAGE I006 WITH '구매처가 지정되지 않았습니다.'.
    RETURN.
  ELSE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_PR_INFOR-LIFNR
      IMPORTING
        OUTPUT = GS_PR_INFOR-LIFNR.

    READ TABLE GT_DISP_LIFNR INTO DATA(LS_CHK) WITH KEY LIFNR = GS_PR_INFOR-LIFNR.
    IF SY-SUBRC NE 0.
      MESSAGE I006 WITH '유효한 구매처가 아닙니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  GS_PR_INFOR-INFNR = LS_CHK-INFNR.

  LEAVE TO SCREEN 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ORDNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_ORDNO  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_ORDNO,
           ORDNO TYPE ZGTPPT2001-ORDNO,
           POSNR TYPE ZGTPPT2001-POSNR,
           WERKS TYPE ZGTPPT2001-WERKS,
           SPGCD TYPE ZGTPPT2001-SPGCD,
         END OF LS_ORDNO.
  DATA : LT_ORDNO LIKE TABLE OF LS_ORDNO.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  PERFORM GET_DYNP_VALUE USING 'P_WERKS'.
  PERFORM GET_DYNP_VALUE USING 'P_SPGCD'.

  CHECK P_WERKS IS NOT INITIAL AND P_SPGCD IS NOT INITIAL.

  REFRESH LT_ORDNO.
  SELECT ORDNO POSNR WERKS SPGCD
    FROM ZGTPPT2001
    INTO CORRESPONDING FIELDS OF TABLE LT_ORDNO
   WHERE WERKS = P_WERKS
      AND SPGCD = P_SPGCD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_ORDNO.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'ORDNO'.
        <LS_FIELD_TAB>-REPTEXT  = '오더번호'.
      WHEN 'POSNR'.
        <LS_FIELD_TAB>-REPTEXT  = '항목'.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'SPGCD'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG 코드'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'ORDNO'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = 'SM 오더 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_ORDNO
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_ORDNO INTO LS_ORDNO WITH KEY  ORDNO = LS_RETURN_TAB-FIELDVAL.
    IF SY-SUBRC EQ 0.

      REFRESH LT_DYNPFIELDS.
      PERFORM GET_STEPL USING LV_LINE.
*      SM 오더번호
      APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
      <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      <LS_DYNPFIELDS>-FIELDVALUE = LS_ORDNO-ORDNO.


      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          DYNAME               = SY-CPROG
          DYNUMB               = SY-DYNNR
        TABLES
          DYNPFIELDS           = LT_DYNPFIELDS
        EXCEPTIONS
          INVALID_ABAPWORKAREA = 1
          INVALID_DYNPROFIELD  = 2
          INVALID_DYNPRONAME   = 3
          INVALID_DYNPRONUMMER = 4
          INVALID_REQUEST      = 5
          NO_FIELDDESCRIPTION  = 6
          UNDEFIND_ERROR       = 7
          OTHERS               = 8.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_DYNP_VALUE  USING  PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  ASSIGN (PV_FIELDNAME) TO FIELD-SYMBOL(<LV_VALUE>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-CPROG
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = <LV_VALUE>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORDNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_SAVE_2001_ORDNO
*&---------------------------------------------------------------------*
FORM GET_ORDNO  CHANGING PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                         PV_CHK_ERR.

  DATA : LV_NR     LIKE  INRI-NRRANGENR.

  LV_NR = '01'.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
      OBJECT                  = 'ZGTPP_GORD'
    IMPORTING
      NUMBER                  = PV_ORDNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_300 .

  CREATE OBJECT GO_CONTAINER_300
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_300
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_300                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_300 .

  GO_TEXT_300->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_300->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_300->SET_READONLY_MODE( EXPORTING READONLY_MODE = 0 ).

  GO_TEXT_300->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT .

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.

  CASE GS_MAIN_DISP-GCATG.
    WHEN '생산오더'.
      SELECT SINGLE * FROM ZGTPPT2001
        WHERE ORDNO = @GS_MAIN_DISP-VBELN
          AND POSNR = @GS_MAIN_DISP-POSNR
         INTO @DATA(LS_2001).

      SPLIT LS_2001-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE LT_TEXT.
    WHEN OTHERS.
      LV_NAME = GS_MAIN_DISP-VBELN.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          ID                      = '0001'
          LANGUAGE                = SY-LANGU
          NAME                    = LV_NAME
          OBJECT                  = 'VBBK'
        TABLES
          LINES                   = LT_LINE
        EXCEPTIONS
          ID                      = 1
          LANGUAGE                = 2
          NAME                    = 3
          NOT_FOUND               = 4
          OBJECT                  = 5
          REFERENCE_CHECK         = 6
          WRONG_ACCESS_TO_ARCHIVE = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      IF LT_LINE[] IS NOT INITIAL.
        LOOP AT LT_LINE INTO DATA(LS_LINE).
          APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
          <LS_TEXT> = LS_LINE-TDLINE.
        ENDLOOP.
      ENDIF.
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT2 .

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_POSNR TYPE POSNR.
  LV_VBELN = GS_MAIN_DISP-VBELN.
  LV_POSNR = GS_MAIN_DISP-POSNR + 0.

  LV_NAME = LV_VBELN && LV_POSNR.

*  LV_NAME = GS_MAIN_DISP-VBELN.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = '0001'
      LANGUAGE                = SY-LANGU
      NAME                    = LV_NAME
      OBJECT                  = 'VBBP'
    TABLES
      LINES                   = LT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  IF LT_LINE[] IS NOT INITIAL.
    LOOP AT LT_LINE INTO DATA(LS_LINE).
      APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
      <LS_TEXT> = LS_LINE-TDLINE.
    ENDLOOP.
  ENDIF.


  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EXIST_SNOTE_FR_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- LV_CHK_EXIST
*&---------------------------------------------------------------------*
FORM CHK_EXIST_SNOTE_FR_SO  USING    PV_GUBUN
                                     PV_VBELN
                                     PV_POSNR
                            CHANGING PV_SNOTE.

  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_POSNR TYPE POSNR.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_OBJECT TYPE THEAD-TDOBJECT.

  LV_VBELN = PV_VBELN.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = PV_POSNR + 0.

  CLEAR LV_NAME.
  CASE PV_GUBUN.
    WHEN 'H'. " 특기사항 헤더
      LV_NAME = LV_VBELN.
      LV_OBJECT = 'VBBK'.
    WHEN 'I'. " 특기사항 아이템
      LV_NAME = LV_VBELN && LV_POSNR.
      LV_OBJECT = 'VBBP'.
  ENDCASE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = '0001'
      LANGUAGE                = SY-LANGU
      NAME                    = LV_NAME
      OBJECT                  = LV_OBJECT
    TABLES
      LINES                   = LT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  IF LT_LINE IS NOT INITIAL.
    LOOP AT LT_LINE INTO DATA(LS_LINE).
      IF  PV_SNOTE IS INITIAL.
        PV_SNOTE = LS_LINE-TDLINE.
      ELSE.
        CONCATENATE PV_SNOTE LS_LINE-TDLINE INTO PV_SNOTE SEPARATED BY SPACE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EXIST_SNOTE_FR_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- LV_CHK_EXIST
*&---------------------------------------------------------------------*
FORM CHK_EXIST_SNOTE_FR_PO  USING    PV_VBELN
                                     PV_POSNR
                            CHANGING PV_SNOTE.

  SELECT SINGLE * FROM ZGTPPT2001
    WHERE ORDNO = @PV_VBELN
      AND POSNR = @PV_POSNR
     INTO @DATA(LS_2001).

  IF LS_2001-SNOTE IS NOT INITIAL.
    PV_SNOTE = LS_2001-SNOTE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIBER_FR_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- <LS_MAIN>_FIBER
*&---------------------------------------------------------------------*
FORM GET_FIBER_FR_BOM  USING    PV_VBELN TYPE ZGTPPT2000-ORDNO
                                PV_POSNR TYPE VBAP-POSNR
                       CHANGING PV_FIBER TYPE MSEG-MENGE.

  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_MENGE TYPE EKPO-MENGE.
  DATA : LS_FIBER TYPE /NFM/TKGW.
  DATA : LV_EMENG TYPE STKO-BMENG.

  LV_VBELN = PV_VBELN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = LV_VBELN
    IMPORTING
      OUTPUT = LV_VBELN.

  SELECT SINGLE VBELN, POSNR, MATNR, KLMENG FROM VBAP
    INTO @DATA(LS_VBAP)
   WHERE VBELN = @LV_VBELN
     AND POSNR = @PV_POSNR.

  LV_EMENG = LS_VBAP-KLMENG.

* fiber 정보 추출
  CLEAR LS_FIBER.
  SELECT SINGLE * FROM /NFM/TKGW
    INTO LS_FIBER
   WHERE WERKS = P_WERKS
     AND MATNR = LS_VBAP-MATNR
     AND NES = 'FI'.

  IF SY-SUBRC EQ 0.
    PV_FIBER = ( LS_VBAP-KLMENG * ( LS_FIBER-KGW / LS_FIBER-KGU ) / 1000 ).
  ENDIF.


*
*
** BOM 하위전개
*  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
*    EXPORTING
*      AUMGB                 = ABAP_ON
*      CAPID                 = 'PP01'
*      DATUV                 = SY-DATUM
*      EHNDL                 = '1'
*      MKTLS                 = ABAP_ON
*      MEHRS                 = ABAP_ON
*      MMORY                 = '1'
*      EMENG                 = LV_EMENG
*      MTNRV                 = LS_VBAP-MATNR
*      WERKS                 = P_WERKS
*    IMPORTING
*      TOPMAT                = LS_TOPMAT
*    TABLES
*      STB                   = LT_STB
*      MATCAT                = LT_CSCMAT
*    EXCEPTIONS
*      ALT_NOT_FOUND         = 1
*      CALL_INVALID          = 2
*      MATERIAL_NOT_FOUND    = 3
*      MISSING_AUTHORIZATION = 4
*      NO_BOM_FOUND          = 5
*      NO_PLANT_DATA         = 6
*      NO_SUITABLE_BOM_FOUND = 7
*      CONVERSION_ERROR      = 8
*      OTHERS                = 9.
*
*  IF LT_CSCMAT[] IS NOT INITIAL.
*    SELECT A~*
*      FROM @LT_STB AS A
*     WHERE A~MTART  = 'ROH1'  " 완제품 반제품만 공정대상
*       AND A~MATMK IN ( 'RW600101', 'RW600102' )
*      INTO TABLE @DATA(LT_STB_SUM).
*  ENDIF.
*
*  LOOP AT LT_STB_SUM INTO DATA(LS_STB_SUM).
*    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
*      EXPORTING
*        I_MATNR              = LS_STB_SUM-IDNRK    " <-- 해당 자재코드
*        I_IN_ME              = LS_STB_SUM-MEINS  "<-- 현 수량의 단위
*        I_OUT_ME             = 'KM' " <-- 변경되어질 수량의 단위
*        I_MENGE              = LS_STB_SUM-MNGKO " <-- 현 수량 변수
*      IMPORTING
*        E_MENGE              = LV_MENGE " <-- 변경되어질 수량변수
*      EXCEPTIONS
*        ERROR_IN_APPLICATION = 1
*        ERROR                = 2
*        OTHERS               = 3.
*
*    ADD LV_MENGE TO PV_FIBER.
*
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_popup_smorder
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_FIELD>
*&      --> <LV_FIELD2>
*&---------------------------------------------------------------------*
FORM DISP_POPUP_SMORDER  USING    PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                  PV_POSNR TYPE ZGTPPT2001-POSNR.

  CLEAR GS_MAKE_ORDER2.
  SELECT SINGLE ORDNO, POSNR, MATNR, GAMNG, MEINS AS GMEIN, GSTRP, GLTRP,
               INLENGTH, INFACTOR, ZPMAT AS COV_MATNR, ZZPRIORITY, SNOTE
    INTO CORRESPONDING FIELDS OF @GS_MAKE_ORDER2
    FROM ZGTPPT2001
   WHERE ORDNO = @PV_ORDNO
      AND POSNR = @PV_POSNR.

  IF SY-SUBRC NE 0.
    RETURN.
  ENDIF.

  REFRESH GT_TEXT.
  SPLIT GS_MAKE_ORDER2-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE GT_TEXT.

  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 83 19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_500 .

  CREATE OBJECT GO_CONTAINER_500
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_500
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_500                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_500 .

  GO_TEXT_500->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_500->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_500->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).

  GO_TEXT_500->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
