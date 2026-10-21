*&---------------------------------------------------------------------*
*& Include          ZGTPPR2030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_parameter_description
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_first_screen
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
FORM GET_PROC .

  CLEAR : GR_DISPO, GR_DISPO[], GS_AUFNR, GT_AUFNR, GT_2010, GS_RESB, GT_RESB,
               GS_STATUS, GT_STATUS, GS_DISP, GT_DISP.      "gt_2000.
*- 생산오더 조회
  PERFORM GET_PROD_ORDER.
*- 조장표 번호
  PERFORM GET_JOJANGPYO_NO.
*- 투입 자재
  PERFORM GET_GI_MATERIAL.
*- 생산 오더 상태
  PERFORM GET_PROD_ORDER_STATUS.
*- 출력 데이터 취합
  PERFORM GET_DISPLAY_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order
*&---------------------------------------------------------------------*
FORM GET_PROD_ORDER .

  GR_DISPO-SIGN = 'I'.
  GR_DISPO-OPTION = 'CP'.
  CONCATENATE P_SPGCD '*' INTO GR_DISPO-LOW.
  APPEND GR_DISPO.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_AUFNR
      FROM ZGTCVORDSYVAL
      WHERE WERKS EQ @P_WERKS
           AND DISPO IN @GR_DISPO
           AND AUART IN @S_AUART
           AND PDCAPROCCODE IN @S_GONG
           AND AUFNR IN @S_AUFNR
           AND KDAUF IN @S_KDAUF
           AND MATNR IN @S_MAT_R
           AND GSTRP IN @S_GSTRP.

  SORT GT_AUFNR BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM GT_AUFNR COMPARING AUFNR.
* 처리 옵션이 체크되어 있을 경우 'TECO/DLFL' 상태의 오더들은 제외
  IF P_CHECK IS NOT INITIAL.
    PERFORM CATCH_AVAILABLE_ORDER TABLES GT_AUFNR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form catch_available_order
*&---------------------------------------------------------------------*
FORM CATCH_AVAILABLE_ORDER TABLES PT_AUFNR STRUCTURE GS_AUFNR.

  DATA : LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.
  DATA : LV_STCD TYPE ZORDSTCD.

  LOOP AT PT_AUFNR.
* 상태값 조회
    CLEAR LV_STCD.
    REFRESH LT_TJ02T.

    CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
      EXPORTING
        IM_AUFNR        = PT_AUFNR-AUFNR
      IMPORTING
        EX_OSTCD        = LV_STCD
      TABLES
        ET_STTXT        = LT_TJ02T
      EXCEPTIONS
        NO_SELECTION    = 1
        NOT_FOUND_OBJNR = 2
        OTHERS          = 3.

    CASE LV_STCD.
      WHEN 'E' OR 'Z'.
        DELETE PT_AUFNR.
        CONTINUE.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_jojangpyo_no
*&---------------------------------------------------------------------*
FORM GET_JOJANGPYO_NO .
* 조장의 연결을 위한 체인 테이블 조회
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LS_2010_CHECK TYPE ZGTPPT2010.
  DATA : LS_GRPNR LIKE GS_GRPNR.
  DATA : LV_CHK_ERR.
  DATA : LV_TABIX TYPE I.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  CHECK GT_AUFNR[] IS NOT INITIAL.
*- 조장표 번호
  LT_AUFNR = VALUE #( FOR LW_MAIN IN GT_AUFNR WHERE ( AUFNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-AUFNR ) ).
  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.
* 공정체인 조회
  SELECT * FROM ZGTPPT2010
      INTO TABLE GT_2010
   WHERE GONG_CD IN S_GONG
        AND ORDNR IN LT_AUFNR.

  DATA(LT_2010_CHK) = GT_2010.
  SORT LT_2010_CHK BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING GRPNR.

  IF LT_2010_CHK IS NOT INITIAL.
    SELECT * FROM ZGTPPT2000
        INTO TABLE GT_2000
        FOR ALL ENTRIES IN LT_2010_CHK
     WHERE GRPNR = LT_2010_CHK-GRPNR
          AND GRPNR IN S_GRPNR.
  ENDIF.
* 조장의 연결을 위한 체인 테이블 조회
  DATA(LT_CHK_GRPNR) = GT_2000.
  SORT LT_CHK_GRPNR BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_GRPNR COMPARING GRPNR.
  IF LT_CHK_GRPNR IS NOT INITIAL.
    SELECT * FROM ZGTPPT2010
      INTO TABLE LT_2010
       FOR ALL ENTRIES IN LT_CHK_GRPNR
     WHERE GRPNR = LT_CHK_GRPNR-GRPNR.
  ENDIF.

  REFRESH GT_GRPNR.
  LOOP AT GT_2010 INTO DATA(LS_2010).
* 해당 조장구성표의 오더번호 찾아가기
    CLEAR : LS_2010_CHECK, LV_CHK_ERR.
    MOVE-CORRESPONDING LS_2010 TO LS_2010_CHECK.
    DO.
      IF LS_2010_CHECK-DMORDTY = 'SO'.
        EXIT.
      ELSE.
        READ TABLE LT_2010 INTO DATA(LS_CHK_2010) WITH KEY ORDNR = LS_2010_CHECK-DMORD
                                                                                      POSNR = LS_2010_CHECK-DMLINE
                                                                                      ORDTY = LS_2010_CHECK-DMORDTY.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010_CHECK.
        ELSE.
          READ TABLE LT_2010 INTO LS_CHK_2010 WITH KEY REORD = LS_2010_CHECK-ORDNR
                                                                               RELINE = LS_2010_CHECK-POSNR
                                                                               REORDTY = LS_2010_CHECK-ORDTY.
          IF SY-SUBRC EQ 0.
            MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010_CHECK.
          ELSE.
            LV_CHK_ERR = ABAP_TRUE.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.

    IF LV_CHK_ERR IS NOT INITIAL.
      CONTINUE.
    ELSE.
      READ TABLE GT_GRPNR TRANSPORTING NO FIELDS WITH KEY GRPNR = LS_2010_CHECK-GRPNR
                                                                                      ORDNO = LS_2010_CHECK-DMORD
                                                                                      POSNR = LS_2010_CHECK-DMLINE
                                                                                      BINARY SEARCH.
      IF SY-SUBRC NE 0.
        CLEAR LV_TABIX.
        LV_TABIX = SY-TABIX.
        READ TABLE GT_2000 INTO DATA(LS_2000) WITH KEY GRPNR = LS_2010_CHECK-GRPNR
                                                                             ORDNO = LS_2010_CHECK-DMORD
                                                                             POSNR = LS_2010_CHECK-DMLINE.
        IF SY-SUBRC EQ 0 .
          CLEAR LS_GRPNR.
          MOVE-CORRESPONDING   LS_2000 TO LS_GRPNR.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = LS_2000-ORDNO
            IMPORTING
              OUTPUT = LS_GRPNR-ORDNO_C.
          LS_GRPNR-ORDNO = LS_2010-ORDNR.
          LS_GRPNR-ORDNO_C = LS_GRPNR-ORDNO_C && '/' && LS_GRPNR-POSNR.
          LS_GRPNR-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_GRPNR-MATNR ).
          LS_GRPNR-NAME1 = ZGTPP_CL_COMMON=>GET_BP_NAME( IV_KUNNR = LS_GRPNR-KUNNR ).

          INSERT LS_GRPNR INTO GT_GRPNR INDEX LV_TABIX.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  DATA(lt_2010_chk) = gt_2010.
*  SORT lt_2010_chk BY grpnr.
*  DELETE ADJACENT DUPLICATES FROM lt_2010_chk COMPARING grpnr.
*
*  IF lt_2010_chk IS NOT INITIAL.
*    SELECT * FROM zgtppt2000
*        INTO TABLE gt_2000
*        FOR ALL ENTRIES IN lt_2010_chk
*     WHERE grpnr = lt_2010_chk-grpnr
*          AND zstatus <> 'D'.
*  ENDIF.
** - 오더 조회 대상에서 공정코드 오더 외 제외
*  LOOP AT gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
*
*    READ TABLE gt_2000 TRANSPORTING NO FIELDS WITH KEY grpnr = <ls_2010>-grpnr.
*    IF sy-subrc NE 0.
*      DELETE gt_2010.
*    ENDIF.
*
*  ENDLOOP.
*
*  LOOP AT gt_aufnr ASSIGNING FIELD-SYMBOL(<ls_main>).
*
*    READ TABLE gt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = <ls_main>-aufnr.
*    IF sy-subrc NE 0.
*      DELETE gt_aufnr.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_gi_material
*&---------------------------------------------------------------------*
FORM GET_GI_MATERIAL .

  CHECK GT_AUFNR[] IS NOT INITIAL.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_RESB
      FROM RESB
      FOR ALL ENTRIES IN @GT_AUFNR
      WHERE WERKS EQ @P_WERKS
           AND AUFNR  EQ @GT_AUFNR-AUFNR
           AND XLOEK <> 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order_status
*&---------------------------------------------------------------------*
FORM GET_PROD_ORDER_STATUS .

  DATA : LV_OBJNR     TYPE JEST-OBJNR,
         LV_LINE      LIKE BSVX-STTXT,
         LV_USER_LINE LIKE BSVX-STTXT.

  CHECK GT_AUFNR[] IS NOT INITIAL.

  LOOP AT GT_AUFNR INTO GS_AUFNR.

    CLEAR : LV_OBJNR, GS_STATUS.
    CONCATENATE 'OR' GS_AUFNR-AUFNR INTO LV_OBJNR.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        FLG_USER_STAT    = 'X'
        OBJNR            = LV_OBJNR
        ONLY_ACTIVE      = 'X'
        SPRAS            = SY-LANGU
        BYPASS_BUFFER    = ABAP_TRUE
      IMPORTING
        LINE             = LV_LINE
        USER_LINE        = LV_USER_LINE
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.
* 오더 상태 필드 출력할 때 우선 순위가 가장 높은 내역만 출력
    FIND ALL OCCURRENCES OF 'CLSD' IN LV_LINE MATCH COUNT DATA(LV_LINE2). "종료
    IF LV_LINE2 > 0.
      PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'CLSD' TEXT-030.
    ELSE.
      FIND ALL OCCURRENCES OF 'TECO' IN LV_LINE MATCH COUNT LV_LINE2. "기술적완료
      IF LV_LINE2 > 0.
        PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'TECO' TEXT-031.
      ELSE.
        FIND ALL OCCURRENCES OF 'DLFL' IN LV_LINE MATCH COUNT LV_LINE2. "삭제
        IF LV_LINE2 > 0.
          PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'DLFL' TEXT-032.
        ELSE.
          FIND ALL OCCURRENCES OF 'DLV' IN LV_LINE MATCH COUNT LV_LINE2. "생산완료
          IF LV_LINE2 > 0.
            PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'DLV' TEXT-005.
          ELSE.
            FIND ALL OCCURRENCES OF 'CNF' IN LV_LINE MATCH COUNT LV_LINE2. "확정처리
            IF LV_LINE2 > 0.
              PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'CNF' TEXT-006.
            ELSE.
              FIND ALL OCCURRENCES OF 'PCNF' IN LV_LINE MATCH COUNT LV_LINE2. "작업중
              IF LV_LINE2 > 0.
                PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'PCNF' TEXT-007.
              ELSE.
                FIND ALL OCCURRENCES OF 'PDLV' IN LV_LINE MATCH COUNT LV_LINE2. "작업중
                IF LV_LINE2 > 0.
                  PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'PDLV' TEXT-007.
                ELSE.
                  FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT LV_LINE2. "Payoff
                  IF LV_LINE2 > 0.
                    PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'PAYO' TEXT-008.
                  ELSE.
                    FIND ALL OCCURRENCES OF 'REL' IN LV_LINE MATCH COUNT LV_LINE2. "릴리즈
                    IF LV_LINE2 > 0.
                      PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'REL' TEXT-009.
                    ELSE.
                      FIND ALL OCCURRENCES OF 'CRTD' IN LV_LINE MATCH COUNT LV_LINE2. "생성
                      IF LV_LINE2 > 0.
                        PERFORM UPDATE_STATUS USING GS_AUFNR-AUFNR 'CRTD' TEXT-010.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_status
*&---------------------------------------------------------------------*
FORM UPDATE_STATUS USING PV_AUFNR
                                             PV_STAT
                                             PV_STAT_T.

  GS_STATUS-AUFNR = PV_AUFNR.
  GS_STATUS-STAT   = PV_STAT.
  GS_STATUS-STAT_T = PV_STAT_T.
  APPEND GS_STATUS TO GT_STATUS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_display_data
*&---------------------------------------------------------------------*
FORM GET_DISPLAY_DATA .

  LOOP AT GT_AUFNR INTO GS_AUFNR.

    CLEAR GS_DISP.
    MOVE-CORRESPONDING GS_AUFNR TO GS_DISP.
* 오더 상태
    CLEAR GS_STATUS.
    READ TABLE GT_STATUS INTO GS_STATUS WITH KEY AUFNR = GS_DISP-AUFNR.
    IF GS_STATUS IS NOT INITIAL.
      GS_DISP-STAT_T = GS_STATUS-STAT_T.
    ENDIF.
* 조장구성표, 주문번호, 주문품목번호, 판매처, 판매처명
    CLEAR GS_GRPNR.
    READ TABLE GT_GRPNR INTO GS_GRPNR WITH KEY ORDNO = GS_DISP-AUFNR.
    IF GS_GRPNR IS NOT INITIAL.
      GS_DISP-GRPNR = GS_GRPNR-GRPNR.
      SPLIT GS_GRPNR-ORDNO_C AT '/' INTO GS_DISP-KDAUF GS_DISP-KDPOS.
      GS_DISP-KUNNR = GS_GRPNR-KUNNR.
      GS_DISP-NAME1 = GS_GRPNR-NAME1.
* 만약, 조장표 번호 조회 조건이 입력되어있으면 해당 조장표 번호 외에는 걸러낼 것
    ELSE.
      IF S_GRPNR[] IS NOT INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.
*    CLEAR gs_2010.
*    READ TABLE gt_2010 INTO gs_2010 WITH KEY ordnr = gs_disp-aufnr.
*    IF gs_2010 IS NOT INITIAL.
*      gs_disp-grpnr = gs_2010-grpnr.
*    ENDIF.
* 특성
    SELECT SINGLE CUOBJ INTO GS_DISP-CUOBJ FROM MARC
                                       WHERE MATNR EQ GS_DISP-MATNR
                                            AND WERKS EQ GS_DISP-WERKS.
    GS_DISP-CHAR = ICON_CHARACTERISTICS_ACT.
    APPEND GS_DISP TO GT_DISP.

  ENDLOOP.

  SORT GT_DISP BY WERKS PDCAPROCCODE GSTRP AUART MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

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
      ROWS    = 1
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
** bottom 컨테이너
*  CALL METHOD go_splitter->get_container
*    EXPORTING
*      row       = 2
*      column    = 1
*    RECEIVING
*      container = go_contain_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  IF PO_GRID = GO_GRID_0220.

    CLEAR LT_F4.
    LT_F4-FIELDNAME  = 'IDNRK'.
    LT_F4-REGISTER   = 'X'.
    LT_F4-GETBEFORE  = 'X'.
    LT_F4-CHNGEAFTER = SPACE.
    INSERT TABLE LT_F4.
*& ONF4 이벤트 등록
    CALL METHOD PO_GRID->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = LT_F4[].
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
    CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDIF.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.
*// Event Handler ##
  IF PO_GRID = GO_GRID_0400.

    SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR FOR PO_GRID.

  ELSE.

    SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR PO_GRID.

    IF PO_GRID = GO_GRID_0220.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4 FOR PO_GRID.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2030TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP'
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
      IT_DATA         = GT_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).

    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PDCAPROCCODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "공정
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PDCAPROCNAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "공정명
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'AUART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "오더유형
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "생산오더
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
*      WHEN 'POSNR'.
*        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f06. "품목
*        <ls_fcat>-key = abap_true.
*        <ls_fcat>-just = 'C'.
      WHEN 'STAT_T'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "오더상태
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "시작일
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "종료일
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "오더수량
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "단위
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "생산자재
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "자재명
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZZORIGIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "Origin
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "조장구성표
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "주문번호
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "주문품목
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "판매처
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "판매처명
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'CHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "자재 특성
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'RESULT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "처리 결과 신호등
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BAPI_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "처리 메시지
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'CUOBJ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
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
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES P_TABLE
                                                           USING P_VALUE.

  DATA: L_EXCLUDE TYPE UI_FUNC.

  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.
  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS USING PO_SENDER
                                           PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                           R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
           USING : '' '' '' '' '3',            "구분자
                        'RELEASE' ICON_RELEASE TEXT-T02 TEXT-T02 0 , "생산 오더 릴리즈
                        'CHANGE' ICON_CHANGE_TEXT TEXT-T03 TEXT-T03 0 , "생산 오더 수정
                        'DELETE' ICON_DELETE TEXT-T04 TEXT-T04 0 , "생산 오더 삭제
                        '' '' '' '' '3',            "구분자
                        'CHANGE2' ICON_INTERCHANGE TEXT-T05 TEXT-T05 0 , "대체 자재 변경
                        'REWORK' ICON_TOOLS TEXT-T06 TEXT-T06 0 , "탈피 오더 생성
                        'REWORK2' ICON_PPE_ACTNODE TEXT-T07 TEXT-T07 0 . "재작업 오더 생성

    WHEN GO_GRID_0220.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
            USING : '' '' '' '' '3',            "구분자
                        'CHANGE' ICON_INVERT_COLUMN TEXT-T08 TEXT-T08 0 . "대체 자재 일괄 입력

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
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
FORM USER_COMMAND_PROS USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                                        PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'RELEASE'. "생산 오더 릴리즈
          PERFORM PROCESS_RELEASE_ORDER.

        WHEN 'CHANGE'. "생산 오더 수정
          PERFORM PROCESS_CHANGE_ORDER_CO02.

        WHEN 'DELETE'. "생산 오더 삭제
          PERFORM PROCESS_DELETE_ORDER.

        WHEN 'CHANGE2'. "대체 자재 변경
          PERFORM CHANGE_ALTERNATIVE_MATERIAL.

        WHEN 'REWORK'. "탈피 오더 생성
          PERFORM CREATE_TALPI_ORDER.

        WHEN 'REWORK2'. "재작업 오더 생성
          PERFORM REWORK_PROD_ORDER.

      ENDCASE.

    WHEN GO_GRID_0220.
      CASE PV_UCOMM.
        WHEN 'CHANGE'. "대체 자재 일괄 입력
          PERFORM INPUT_MULTI_ALTER_MAT.
      ENDCASE.

  ENDCASE.

  CLEAR PV_UCOMM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                           P_ROW TYPE LVC_S_ROW
                                           P_COLUMN TYPE LVC_S_COL.

  FIELD-SYMBOLS <LS_DATA> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_DISP ASSIGNING <LS_DATA> INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          SET PARAMETER ID 'ANR' FIELD <LV_FIELD>.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'ZZORIGIN'.
          ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          SET PARAMETER ID 'ANR' FIELD <LV_FIELD>.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'CHAR'.
          ASSIGN COMPONENT 'CUOBJ' OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          PERFORM DISPLAY_POPUP_CHARACTICS USING <LV_FIELD>.
        WHEN 'MATNR'.
          ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD <LV_FIELD>.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDCASE.
    WHEN GO_GRID_0220.
      READ TABLE GT_POPUP ASSIGNING <LS_DATA> INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          SET PARAMETER ID 'ANR' FIELD <LV_FIELD>.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'MATNR' OR 'IDNRK'.
          ASSIGN COMPONENT P_COLUMN-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
          IF <LV_FIELD> IS NOT INITIAL.
            SET PARAMETER ID 'WRK' FIELD P_WERKS.
            SET PARAMETER ID 'MXX' FIELD 'K'.
            SET PARAMETER ID 'MAT' FIELD <LV_FIELD>.
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup_charactics
*&---------------------------------------------------------------------*
FORM DISPLAY_POPUP_CHARACTICS USING PV_CUOBJ TYPE CUOBJ_VA.

  DATA : LS_INCL_BILD TYPE INCL_BILD.
* 초기화
  CALL FUNCTION 'CUD0_CONFIGURATION_INITIALIZER'.

  CALL FUNCTION 'VC_I_DISPLAY_CONFIGURATION'
    EXPORTING
      INSTANCE           = PV_CUOBJ
      INCLUDE_SCREEN     = LS_INCL_BILD
      IV_NO_VALUE_CHECK  = ' X'
    EXCEPTIONS
      INSTANCE_NOT_FOUND = 1
      INTERNAL_ERROR     = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_release_order
*&---------------------------------------------------------------------*
FORM PROCESS_RELEASE_ORDER .

  DATA: LT_ORDERS	TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_RETURN	TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE.

  CLEAR : GS_ROW, GT_ROW.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
    RETURN.
  ENDIF.

  CLEAR : GV_OK, GV_ANSWER, GV_CNT, GV_CNT2, GV_CNT3, GV_MESSAGE.
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-STAT_T EQ TEXT-010.
      GV_OK = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.
* 생산 오더 '생성' 상태 만 진행. 그외 상태 Skip.
  IF GV_OK IS NOT INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        TITEL     = TEXT-M01
        TEXTLINE1 = TEXT-M02
      IMPORTING
        ANSWER    = GV_ANSWER.

    CHECK GV_ANSWER = 'J'.

    LOOP AT GT_ROW INTO GS_ROW.

      CLEAR GS_DISP.
      READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
      IF GS_DISP-STAT_T EQ TEXT-010.

        GV_CNT =  GV_CNT + 1.

        CLEAR: LT_RETURN, LT_RETURN[], LT_ORDERS, LT_ORDERS[].
        LT_ORDERS-ORDER_NUMBER = GS_DISP-AUFNR.
        APPEND LT_ORDERS.

        CALL FUNCTION 'BAPI_PRODORD_RELEASE'
          EXPORTING
            RELEASE_CONTROL    = '1'
            WORK_PROCESS_GROUP = 'COWORK_BAPI'
            WORK_PROCESS_MAX   = 99
          IMPORTING
            RETURN             = LT_RETURN
          TABLES
            ORDERS             = LT_ORDERS.

        READ TABLE LT_RETURN WITH KEY TYPE = 'E'.
        IF SY-SUBRC <> 0.

          GV_CNT2 =  GV_CNT2 + 1.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.
          WAIT UP TO '2' SECONDS.

          GS_DISP-RESULT = ICON_LED_GREEN.
          GS_DISP-BAPI_MSG = TEXT-S01.
          GS_DISP-STAT_T = TEXT-009.

        ELSE.

          GV_CNT3 =  GV_CNT3 + 1.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          READ TABLE LT_RETURN WITH KEY TYPE = 'E'.
          GS_DISP-RESULT = ICON_LED_RED.
          GS_DISP-BAPI_MSG = LT_RETURN-MESSAGE.

        ENDIF.

        MODIFY GT_DISP FROM GS_DISP INDEX GS_ROW-INDEX.

      ENDIF.

    ENDLOOP.

    IF GV_CNT3 IS INITIAL.
      GV_CNT3 = '0'.
    ENDIF.

    IF GV_CNT IS NOT INITIAL.

      CONCATENATE TEXT-M03 GV_CNT TEXT-M04 GV_CNT2 TEXT-M05 GV_CNT3 TEXT-M06
                      INTO GV_MESSAGE SEPARATED BY SPACE.
      MESSAGE S003 DISPLAY LIKE 'S' WITH GV_MESSAGE.

    ENDIF.
* REFRESH DISPLAY
    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GV_STABLE.

  ELSE.

    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E02.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_change_order_co02
*&---------------------------------------------------------------------*
FORM PROCESS_CHANGE_ORDER_CO02 .

  CLEAR : GS_ROW, GT_ROW.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E03.
    RETURN.
* 선택 오더가 여러 건일 경우
  ELSE.
    DATA(LV_TCNT) = LINES( GT_ROW ).
    IF LV_TCNT > 1.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E05.
      RETURN.
    ENDIF.
  ENDIF.
* 선택 오더 상태가 생성 및 릴리즈인 것만 수정 가능
  CLEAR : GV_OK.
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-STAT_T EQ TEXT-010 OR GS_DISP-STAT_T EQ TEXT-009.
      GV_OK = 'X'.
    ENDIF.

  ENDLOOP.
  " 생성, 릴리즈 오더 미 선택 시
  IF GV_OK IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E04.
* 생산 오더 수정은 직접 '생산 오더 변경' 스탠다드 화면 띄움
  ELSE.

    CLEAR GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    SET PARAMETER ID 'ANR' FIELD GS_DISP-AUFNR.
    CALL TRANSACTION 'CO02' AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_alternative_material
*&---------------------------------------------------------------------*
FORM CHANGE_ALTERNATIVE_MATERIAL .

  CLEAR : GS_ROW, GT_ROW.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E06.
    RETURN.
  ENDIF.
* 선택 오더 상태가 생성 및 릴리즈인 것만 수정 가능
  CLEAR : GV_ERROR, GS_AUFNR2, GT_AUFNR2, GS_POPUP, GT_POPUP.
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-STAT_T EQ TEXT-010 OR GS_DISP-STAT_T EQ TEXT-009.
      GS_AUFNR2-AUFNR = GS_DISP-AUFNR.
      APPEND GS_AUFNR2 TO GT_AUFNR2.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E07.
      EXIT.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERROR IS INITIAL.
* 선택한 생산 오더로 RESB에서 정보를 가져올 것
  SELECT *
      INTO TABLE @DATA(LT_RESB)
      FROM RESB
      FOR ALL ENTRIES IN @GT_AUFNR2
      WHERE AUFNR EQ @GT_AUFNR2-AUFNR
           AND XLOEK EQ @SPACE.

  LOOP AT LT_RESB INTO DATA(LS_RESB).
* 반제품은 대체 자재로 변경할 수 없으므로 제외
    SELECT SINGLE A~MANDT INTO @DATA(LV_MANDT)
                    FROM MARA AS A INNER JOIN T134 AS B
                        ON A~MTART = B~MTART
                        WHERE A~MATNR EQ @LS_RESB-MATNR
                             AND B~MTREF <> 'HALB'.

    IF LV_MANDT IS NOT INITIAL.

      CLEAR GS_POPUP.
      GS_POPUP-MATNR = LS_RESB-MATNR.
      GS_POPUP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_RESB-MATNR ).
      GS_POPUP-AUFNR = LS_RESB-AUFNR.
      GS_POPUP-POSNR = LS_RESB-POSNR.
      GS_POPUP-ERFMG = LS_RESB-ERFMG.
      GS_POPUP-ERFME = LS_RESB-ERFME.
      APPEND GS_POPUP TO GT_POPUP.

    ENDIF.

    CLEAR LV_MANDT.

  ENDLOOP.

  IF GT_POPUP[] IS INITIAL.

    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E08.

  ELSE.

    SORT GT_POPUP BY MATNR AUFNR POSNR.
    CALL SCREEN 0220 STARTING AT 2 2 ENDING AT 110 20.
* REFRESH DISPLAY
    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GV_STABLE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0220
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0220 .

  CREATE OBJECT GO_CONTAIN_0220
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

  CREATE OBJECT GO_GRID_0220
    EXPORTING
      I_PARENT      = GO_CONTAIN_0220
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0220
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0220 .

  CLEAR GS_LAYOUT_0220.
*  gs_layout_0220-cwidth_opt = abap_true.
  GS_LAYOUT_0220-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0220-SEL_MODE   = 'A'.
  GS_LAYOUT_0220-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0220
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0220 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2030TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0220[]
    TABLES
      IT_DATA         = GT_POPUP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0220 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "원 구성품
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "원 구성품명
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '24'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "생산오더
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "항목
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'ERFMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "투입수량
        <LS_FCAT>-QFIELDNAME = 'ERFME'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'ERFME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "단위
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "대체자재
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-OUTPUTLEN = '8'.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
      WHEN 'MAKTX2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "대체자재명
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '24'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0220
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0220 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0220
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
*& Form call_grid_0220_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0220_DISPLAY .

  CALL METHOD GO_GRID_0220->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0220
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0220
    CHANGING
      IT_OUTTAB            = GT_POPUP
      IT_FIELDCATALOG      = GT_FIELDCAT_0220.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0220->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0220->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_alternative_material
*&---------------------------------------------------------------------*
FORM INPUT_ALTERNATIVE_MATERIAL .

  DATA : LV_TABIX LIKE SY-TABIX.
  DATA : LV_ALL(2)  VALUE '0',
         LV_SUC(2)  VALUE '0',
         LV_PSUC(2) VALUE '0',
         LV_FAIL(2) VALUE '0'.

  CLEAR : GT_ALTER, GT_ALTER[].
  LOOP AT GT_POPUP INTO GS_POPUP.

    IF GS_POPUP-IDNRK IS NOT INITIAL.

      REFRESH: GT_BDCDATA, GT_MSGCOLL.
      CLEAR  : GT_BDCDATA, GT_MSGCOLL, GV_YES, GV_NO.

      PERFORM DYNPRO USING:
        'X'  'SAPLCOKO1'                '0110',
        ' '  'BDC_OKCODE'              '=KPU2',
        ' '  'CAUFVD-AUFNR'            GS_POPUP-AUFNR,
        ' ' 'R62CLORD-FLG_OVIEW' GC_X.

      PERFORM DYNPRO USING:
        'X'  'SAPLCOMK'                '0120',
        '  '  'BDC_OKCODE'           '=AUFS',
        '  '  'FILTER_BOX'              'NO_FIL',
        '  '  'SORT_BOX'                'ST_STA'.

      PERFORM DYNPRO USING:
        'X'  'SAPLCO05'                '0110',
        '  '  'BDC_OKCODE'          '=MORE',
        '  '  'RCOSU-POSNR'       GS_POPUP-POSNR.

      PERFORM DYNPRO USING:
        'X'  'SAPLCOMK'                '0120',
        '  '  'BDC_OKCODE'           '/00',
        '  '  'RESBD-MATNR(01)'   GS_POPUP-IDNRK.

      PERFORM DYNPRO USING:
         'X'  'SAPLCOMK'                '0120',
         '  '  'FILTER_BOX'              'NO_FIL',
         '  '  'SORT_BOX'                'ST_STA',
         '  '  'BDC_OKCODE'           '=BU'.

      GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
      GS_BDCPARAMS-DISMODE = 'N'.
      GS_BDCPARAMS-UPDMODE = 'S'.
      CALL TRANSACTION 'CO02'          "Transaction Call.
                           USING GT_BDCDATA
                           OPTIONS FROM GS_BDCPARAMS
                           MESSAGES INTO GT_MSGCOLL.
* 간혹, 일부 자재 교체 중 세부 사항이 뜨는 경우가 있어
* 처리가 안됐을 경우 한번 더 BDC 태울 것
      CLEAR : GT_MSGCOLL.
      READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'S'
                                                            MSGID = 'CO'
                                                            MSGNR = '100'.
      IF SY-SUBRC <> 0.

        REFRESH: GT_BDCDATA, GT_MSGCOLL.
        CLEAR  : GT_BDCDATA, GT_MSGCOLL.

        PERFORM DYNPRO USING:
          'X'  'SAPLCOKO1'                '0110',
          ' '  'BDC_OKCODE'              '=KPU2',
          ' '  'CAUFVD-AUFNR'            GS_POPUP-AUFNR,
          ' ' 'R62CLORD-FLG_OVIEW' GC_X.

        PERFORM DYNPRO USING:
          'X'  'SAPLCOMK'                '0120',
          '  '  'BDC_OKCODE'           '=AUFS',
          '  '  'FILTER_BOX'              'NO_FIL',
          '  '  'SORT_BOX'                'ST_STA'.

        PERFORM DYNPRO USING:
          'X'  'SAPLCO05'                '0110',
          '  '  'BDC_OKCODE'          '=MORE',
          '  '  'RCOSU-POSNR'       GS_POPUP-POSNR.

        PERFORM DYNPRO USING:
          'X'  'SAPLCOMK'                '0120',
          '  '  'BDC_OKCODE'           '/00',
          '  '  'RESBD-MATNR(01)'   GS_POPUP-IDNRK.

        PERFORM DYNPRO USING:
          'X'  'SAPLCOMD'                '0110',
          '  '  'BDC_OKCODE'           '/00'.

        PERFORM DYNPRO USING:
           'X'  'SAPLCOMK'                '0120',
           '  '  'FILTER_BOX'              'NO_FIL',
           '  '  'SORT_BOX'                'ST_STA',
           '  '  'BDC_OKCODE'           '=BU'.

        GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
        GS_BDCPARAMS-DISMODE = 'N'.
        GS_BDCPARAMS-UPDMODE = 'S'. "COMMIT WORK
        CALL TRANSACTION 'CO02'          "Transaction Call.
                             USING GT_BDCDATA
                             OPTIONS FROM GS_BDCPARAMS
                             MESSAGES INTO GT_MSGCOLL.

        CLEAR : GT_MSGCOLL.
        LV_TABIX = SY-TABIX.
        READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'S'
                                                              MSGID = 'CO'
                                                              MSGNR = '100'.
        IF SY-SUBRC <> 0.
          GV_NO = 1.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
          GV_YES = 1.
        ENDIF.

      ELSE.
        WAIT UP TO '0.5' SECONDS.
        GV_YES = 1.
      ENDIF.

      CLEAR GT_ALTER.
      READ TABLE GT_ALTER WITH KEY AUFNR = GS_POPUP-AUFNR.
      IF SY-SUBRC = 0.
        GT_ALTER-SUC = GT_ALTER-SUC + GV_YES.
        GT_ALTER-FAIL = GT_ALTER-FAIL + GV_NO.
        MODIFY GT_ALTER INDEX SY-TABIX.

      ELSE.

        GT_ALTER-SUC = GV_YES.
        GT_ALTER-FAIL = GV_NO.
        GT_ALTER-AUFNR = GS_POPUP-AUFNR.
        APPEND GT_ALTER.

      ENDIF.

    ENDIF.

  ENDLOOP.
* 선택 라인에 결과 업데이트
  CLEAR : LV_ALL, LV_SUC, LV_PSUC, LV_FAIL.
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR : GT_ALTER, GS_DISP, GV_ALL.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    READ TABLE GT_ALTER WITH KEY AUFNR = GS_DISP-AUFNR.
    GV_ALL = GT_ALTER-SUC + GT_ALTER-FAIL.
    LV_ALL = LV_ALL + 1.

    IF GT_ALTER-SUC <> 0 AND GT_ALTER-FAIL = 0. "대체 자재 변경 모두 처리 완료
      LV_SUC = LV_SUC + 1.
      GS_DISP-RESULT = ICON_LED_GREEN.
      CONCATENATE TEXT-028 GV_ALL TEXT-016 GT_ALTER-SUC TEXT-018
                      INTO GS_DISP-BAPI_MSG SEPARATED BY SPACE.
    ELSEIF GT_ALTER-SUC <> 0 AND GT_ALTER-FAIL <> 0. "대체 자재 변경 일부 처리 완료
      LV_PSUC = LV_PSUC + 1.
      GS_DISP-RESULT = ICON_LED_YELLOW.
      CONCATENATE TEXT-028 GV_ALL TEXT-016 GT_ALTER-SUC TEXT-017 GT_ALTER-FAIL TEXT-018
                      INTO GS_DISP-BAPI_MSG SEPARATED BY SPACE.
    ELSEIF GT_ALTER-SUC = 0 AND GT_ALTER-FAIL <> 0. "대체 자재 변경 모두 실패
      LV_FAIL = LV_FAIL + 1.
      GS_DISP-RESULT = ICON_LED_RED.
      CONCATENATE TEXT-028 GV_ALL TEXT-027 GT_ALTER-FAIL TEXT-018
                      INTO GS_DISP-BAPI_MSG SEPARATED BY SPACE.
    ENDIF.

    MODIFY GT_DISP FROM GS_DISP INDEX GS_ROW-INDEX.

  ENDLOOP.

  CLEAR GV_MESSAGE.
  CONCATENATE TEXT-015 LV_ALL TEXT-016 LV_SUC TEXT-029 LV_PSUC TEXT-017 LV_FAIL
                          TEXT-018
                  INTO GV_MESSAGE SEPARATED BY SPACE.
  MESSAGE S003 WITH GV_MESSAGE.
* REFRESH DISPLAY
  CALL METHOD GO_CONTAIN_0220->FREE.
  FREE : GO_CONTAIN_0220, GO_GRID_0220.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = GV_STABLE.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                             PV_ONF4 TYPE CHAR1.

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI.
  DATA : LV_MATNR  LIKE MARA-MATNR,
         LV_MATNR2 LIKE MARA-MATNR.

  LOOP AT PR_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.

    IF LS_MOD_CELLS-VALUE IS NOT INITIAL.

      CLEAR : GS_POPUP, GV_MATKL, GV_MATKL2, GV_MATNR, GV_MESSAGE, GS_BOM_P.
      CASE LS_MOD_CELLS-FIELDNAME.

        WHEN 'IDNRK'. "대체 자재

          READ TABLE GT_POPUP INTO GS_POPUP INDEX LS_MOD_CELLS-ROW_ID.

          GV_MATNR = LS_MOD_CELLS-VALUE.
          GV_MATKL = ZGTPP_CL_COMMON=>GET_MATKL(
                                         IV_MATNR = GS_POPUP-MATNR ).
          GV_MATKL2 = ZGTPP_CL_COMMON=>GET_MATKL(
                                         IV_MATNR = GV_MATNR ).
* 동일한 자재 그룹이면 자재명 포함 반영
          IF GV_MATKL = GV_MATKL2.

            GS_POPUP-IDNRK  = LS_MOD_CELLS-VALUE.
            GS_POPUP-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX(
                                          IV_MATNR = GS_POPUP-IDNRK ).

            CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'IDNRK'
                I_VALUE     = GS_POPUP-IDNRK.

            CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'MAKTX2'
                I_VALUE     = GS_POPUP-MAKTX2.
* 자재 그룹이 같을 시에만 반영. 다를 경우 에러 메시지
          ELSE.

            CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
              EXPORTING
                INPUT        = GS_POPUP-MATNR
              IMPORTING
                OUTPUT       = LV_MATNR
              EXCEPTIONS
                LENGTH_ERROR = 1
                OTHERS       = 2.

            CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
              EXPORTING
                INPUT        = GV_MATNR
              IMPORTING
                OUTPUT       = LV_MATNR2
              EXCEPTIONS
                LENGTH_ERROR = 1
                OTHERS       = 2.

            GV_MESSAGE = TEXT-014.
            CONCATENATE TEXT-011 LV_MATNR ':' GV_MATKL TEXT-013
                                    LV_MATNR2 ':' GV_MATKL2 INTO GV_MESSAGE2
                                    SEPARATED BY SPACE.

            PERFORM DATA_INPUT_ERROR USING PR_DATA_CHANGED
                                       LS_MOD_CELLS
                                       'E'
                                       GV_MESSAGE
                                       LS_MOD_CELLS-FIELDNAME.

            PERFORM DATA_INPUT_ERROR USING PR_DATA_CHANGED
                                       LS_MOD_CELLS
                                       'E'
                                       GV_MESSAGE2
                                       LS_MOD_CELLS-FIELDNAME.

            PR_DATA_CHANGED->DISPLAY_PROTOCOL( ).

          ENDIF.

        WHEN 'MENGE'.

          READ TABLE GT_BOM_P INTO GS_BOM_P INDEX LS_MOD_CELLS-ROW_ID.
          GS_BOM_P-MENGE  = LS_MOD_CELLS-VALUE.
          CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'MENGE'
              I_VALUE     = GS_BOM_P-MENGE.

        WHEN  OTHERS.

      ENDCASE.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_input_error
*&---------------------------------------------------------------------*
FORM DATA_INPUT_ERROR USING PR_DATA_CHANGED TYPE REF TO
                                         CL_ALV_CHANGED_DATA_PROTOCOL
                                         PS_MOD_CELLS    TYPE LVC_S_MODI
                                         PV_MSGTY
                                         PV_MSGV1
                                         PV_FIELDNAME.
* Error Message Display
  CALL METHOD PR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = 'ZGTPP00'
      I_MSGNO     = '003'
      I_MSGTY     = PV_MSGTY
      I_MSGV1     = PV_MSGV1
      I_MSGV2     = ''
      I_MSGV3     = ''
      I_FIELDNAME = PV_FIELDNAME
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro
*&---------------------------------------------------------------------*
FORM DYNPRO USING DYNBEGIN NAME VALUE.

  CLEAR GT_BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO GT_BDCDATA-PROGRAM,
          VALUE TO GT_BDCDATA-DYNPRO,
          'X'   TO GT_BDCDATA-DYNBEGIN.
    APPEND GT_BDCDATA.
  ELSE.
    MOVE: NAME  TO GT_BDCDATA-FNAM,
          VALUE TO GT_BDCDATA-FVAL.
    APPEND GT_BDCDATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_multi_alter_mat
*&---------------------------------------------------------------------*
FORM INPUT_MULTI_ALTER_MAT .

  CLEAR : GS_ROW2, GT_ROW2, GV_MATKL, GV_MATKL2, GV_MESSAGE, GV_ERROR, GV_MATNR2,
               GT_MATNR, GV_JOBS.

  CALL METHOD GO_GRID_0220->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW2.
* 선택 라인이 없을 경우
  IF GT_ROW2[] IS INITIAL.
    MESSAGE I003 DISPLAY LIKE 'E' WITH TEXT-E10.
    RETURN.
  ENDIF.
* 동일한 자재 그룹을 선택했는 지 체크. 다른 그룹 존재시 에러 메시지 출력 및 프로세스 중단
  LOOP AT GT_ROW2 INTO GS_ROW2.

    CLEAR GS_POPUP.
    READ TABLE GT_POPUP INTO GS_POPUP INDEX GS_ROW2-INDEX.
    IF SY-SUBRC = 0.
      GV_MATKL = ZGTPP_CL_COMMON=>GET_MATKL(
                                   IV_MATNR = GS_POPUP-MATNR ).
      IF GV_MATKL2 IS INITIAL.
        GV_MATKL2 = GV_MATKL.
      ELSEIF GV_MATKL2 NE GV_MATKL.
        GV_ERROR = 'X'.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            INPUT  = GS_POPUP-MATNR
          IMPORTING
            OUTPUT = GS_POPUP-MATNR.
        CONCATENATE TEXT-011 GS_POPUP-MATNR TEXT-012 GV_MATKL TEXT-019
                                    INTO GV_MESSAGE SEPARATED BY SPACE.
        MESSAGE I003 DISPLAY LIKE 'E' WITH GV_MESSAGE.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERROR IS INITIAL.

  CALL FUNCTION 'ZGTPP_INPUT_ALTER_MAT' STARTING NEW TASK 'MATNR'
    PERFORMING GET_DATA_MATNR ON END OF TASK
    EXPORTING
      I_WERKS = P_WERKS.

  WAIT UNTIL GV_JOBS = '1'.

  IF GT_MATNR[] IS NOT INITIAL.

    READ TABLE GT_MATNR INTO DATA(LS_MATNR) INDEX 1.
* 입력 받은 대체 자재를 선택 라인에 일괄 반영
    LOOP AT GT_ROW2 INTO GS_ROW2.

      CLEAR GS_DISP.
      READ TABLE GT_POPUP INTO GS_POPUP INDEX GS_ROW2-INDEX.
      IF SY-SUBRC = 0.
        GS_POPUP-IDNRK = LS_MATNR-MATNR.
        GS_POPUP-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_POPUP-IDNRK ).
        MODIFY GT_POPUP FROM GS_POPUP INDEX GS_ROW2-INDEX.
      ENDIF.

    ENDLOOP.
* REFRESH DISPLAY
    CALL METHOD GO_GRID_0220->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GV_STABLE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rework_prod_order
*&---------------------------------------------------------------------*
FORM REWORK_PROD_ORDER .

  DATA : LS_REFCOPY	   TYPE BAPI_ORDER_COPY,
         LV_ORDER_TYPE LIKE	BAPI_ORDER_COPY-ORDER_TYPE,
         LS_RETURN     LIKE BAPIRET2.

  DATA: LS_ORDDATA  TYPE BAPI_PP_ORDER_CHANGE,
        LS_ORDDATAX TYPE BAPI_PP_ORDER_CHANGEX,
        LS_RETURN2  TYPE BAPIRET2.
*- Start 2025.06.02
  CLEAR : GV_ERROR, GV_ANSWER, GV_S_DAY, GV_E_DAY, GV_ALL, GV_YES, GV_NO, GV_MESSAGE.
*- End 2025.06.02
* 라인 선택 및 오류 체크
  PERFORM CHECK_ERROR_REWORK_ORDER.
* 재작업 오더 " RP01" 생성
  IF GV_ERROR IS INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        TITEL     = TEXT-M07
        TEXTLINE1 = TEXT-M08
      IMPORTING
        ANSWER    = GV_ANSWER.

    CHECK GV_ANSWER = 'J'.
* 생산 일정 받을 것( 시작일, 종료일 )
    CALL SCREEN '0300' STARTING AT 1 1 ENDING AT 23 4.

    IF GV_OK_CODE4 = 'INPUT'.

      LOOP AT GT_ROW INTO GS_ROW.

        CLEAR : GS_DISP, LS_REFCOPY, GV_ORDER_NUMBER, LV_ORDER_TYPE, LS_RETURN, GV_MANDT,
                GV_ZZORIGIN, GV_AUFNR, LS_ORDDATA, LS_ORDDATAX, LS_RETURN.

        READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
* 오더 유형 "RW01" 은 원 오더(ZZORIGIN) 기준으로 생성
        IF GS_DISP-AUART = 'RW01'.
* 선택된 재작업 오더의 원 표준 오더 확인
          IF GS_DISP-ZZORIGIN IS NOT INITIAL.
            PERFORM CONVERSION_EXIT USING GS_DISP-ZZORIGIN '+' CHANGING GV_ZZORIGIN.
          ENDIF.
          LS_REFCOPY-REFERENCE_ORDER = GV_ZZORIGIN.
* 기준 오더 유형 "PP01", "PP05" 는 기존 오더 생산 자재가 그대로 투입되어 재작업되는 케이스
        ELSEIF GS_DISP-AUART = 'PP01' OR GS_DISP-AUART = 'PP05'. "선택 라인 생산 오더 참조로 생성
          PERFORM CONVERSION_EXIT USING GS_DISP-AUFNR '+' CHANGING LS_REFCOPY-REFERENCE_ORDER.
        ENDIF.
        LS_REFCOPY-ORDER_TYPE = 'RP01'. "재작업 오더
        LS_REFCOPY-BASIC_START_DATE = GV_S_DAY.
        LS_REFCOPY-BASIC_END_DATE = GV_E_DAY.

        GV_ALL = GV_ALL + 1.

        CALL FUNCTION 'BAPI_PRODORD_CREATE_FROM_REF'
          EXPORTING
            REFCOPY      = LS_REFCOPY
          IMPORTING
            ORDER_NUMBER = GV_ORDER_NUMBER
            ORDER_TYPE   = LV_ORDER_TYPE
            RETURN       = LS_RETURN.

        IF GV_ORDER_NUMBER IS NOT INITIAL.

          WAIT UP TO '0.5' SECONDS.

          GV_YES = GV_YES + 1.
          GS_DISP-RESULT     = ICON_LED_GREEN.
          GS_DISP-BAPI_MSG = TEXT-S02.
* 재작업 오더 추가 필드 설정
          SELECT SINGLE MANDT INTO GV_MANDT FROM AUFK
                                            WHERE AUFNR EQ GV_ORDER_NUMBER.
          IF GV_MANDT IS INITIAL.
            COMMIT WORK AND WAIT.
          ENDIF.

          IF GS_DISP-AUART = 'RW01' AND GV_ZZORIGIN IS NOT INITIAL.
            PERFORM CONVERSION_EXIT USING GV_ZZORIGIN '-' CHANGING GV_ZZORIGIN.
            UPDATE AUFK SET ZZORIGIN = GV_ZZORIGIN
                        WHERE AUFNR EQ GV_ORDER_NUMBER.
            GS_DISP-ZZORIGIN = GV_ZZORIGIN.
          ELSEIF GS_DISP-AUART = 'PP01' OR GS_DISP-AUART = 'PP05'.
            PERFORM CONVERSION_EXIT USING GS_DISP-AUFNR '-' CHANGING GV_AUFNR.
            UPDATE AUFK SET ZZORIGIN = GV_AUFNR
                        WHERE AUFNR EQ GV_ORDER_NUMBER.
            GS_DISP-ZZORIGIN = GV_AUFNR.
          ENDIF.

          IF SY-SUBRC = 0.
            COMMIT WORK.
          ENDIF.
* 오더 우선 순위 반영
          LS_ORDDATA-ORDER_PRIORITY  = '8'.
          LS_ORDDATAX-ORDER_PRIORITY = 'X'.

          CALL FUNCTION 'BAPI_PRODORD_CHANGE'
            EXPORTING
              NUMBER     = GV_ORDER_NUMBER
              ORDERDATA  = LS_ORDDATA
              ORDERDATAX = LS_ORDDATAX
            IMPORTING
              RETURN     = LS_RETURN2.

          WAIT UP TO '0.5' SECONDS.
          COMMIT WORK AND WAIT.
* 기준 오더 유형 "PP01", "PP05" 에 한정하여 기존 BOM 삭제 후 생산 자재와 동일한 자재 및 수량 구성
          IF GS_DISP-AUART = 'PP01' OR GS_DISP-AUART = 'PP05'.
            PERFORM THIRD_MODIFY_BOM_ORDER.
          ENDIF.

          WAIT UP TO '0.5' SECONDS.

*        기존 조장구성표에 페깅추가
          IF GV_ZZORIGIN IS NOT INITIAL.
            PERFORM SET_2010_PEGGING USING GV_ZZORIGIN GV_ORDER_NUMBER.
          ENDIF.

        ELSE.

          GV_NO = GV_NO + 1.
          GS_DISP-RESULT   = ICON_LED_RED.
          GS_DISP-BAPI_MSG = LS_RETURN-MESSAGE.

        ENDIF.

        MODIFY GT_DISP FROM GS_DISP INDEX GS_ROW-INDEX.

      ENDLOOP.
* 에러 건이 있을 시에만 처리 결과를 반영하고, 없으면 데이터 REFRESH할 것
      IF GV_NO <> 0.

        IF GV_YES <> 0 AND GV_NO <> 0.
          CONCATENATE TEXT-020 GV_ALL TEXT-016 GV_YES TEXT-017 GV_NO TEXT-018
                 INTO GV_MESSAGE SEPARATED BY SPACE.
          MESSAGE S003 WITH GV_MESSAGE.
        ELSEIF GV_YES = 0 AND GV_NO <> 0.
          CONCATENATE TEXT-020 GV_ALL TEXT-017 GV_NO TEXT-018 INTO GV_MESSAGE
            SEPARATED BY SPACE.
          MESSAGE S003 DISPLAY LIKE 'E' WITH GV_MESSAGE.
        ENDIF.

      ELSE.

        PERFORM GET_PROC.

      ENDIF.
* REFRESH DISPLAY
      CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
        EXPORTING
          I_SOFT_REFRESH = 'X'
          IS_STABLE      = GV_STABLE.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_talpi_prod_order
*&---------------------------------------------------------------------*
FORM CREATE_TALPI_PROD_ORDER .
*- Start 2025.06.02
* 생산에 투입된 반제품 수량 취합 후 탈피 수량 기본값으로 제안
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR : GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.

    PERFORM MERGE_POPUP_MENGE.

  ENDLOOP.
* 사용자 입력 정보 받을 것( 탈피 자재, 수량, 시작일, 종료일 )
  CALL SCREEN '0301' STARTING AT 1 1 ENDING AT 74 6.
*- End 2025.06.02
  IF GV_S_DAY NE '00000000'.
* 탈피 오더의 추가 투입 자재 확인
    CLEAR : GS_BOM_P, GT_BOM_P, GT_BOM_P2.
    LOOP AT GT_ROW INTO GS_ROW.

      CLEAR : GS_DISP, GS_TOPMAT, GS_CSCMAT, GT_STB, GT_CSCMAT.
      READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = GV_MATNR4
        IMPORTING
          OUTPUT       = GV_MATNR4
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.
* BOM 하위전개
      CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
        EXPORTING
          AUMGB                 = ABAP_ON
          CAPID                 = 'PP01'
          DATUV                 = SY-DATUM
          EHNDL                 = '1'
          MKTLS                 = ABAP_ON
          MMORY                 = '1'
          MTNRV                 = GV_MATNR4
          WERKS                 = P_WERKS
*- Start 2025.06.02
          EMENG                 = GV_MENGE
*- End 2025.06.02
        IMPORTING
          TOPMAT                = GS_TOPMAT
        TABLES
          STB                   = GT_STB
          MATCAT                = GT_CSCMAT
        EXCEPTIONS
          ALT_NOT_FOUND         = 1
          CALL_INVALID          = 2
          MATERIAL_NOT_FOUND    = 3
          MISSING_AUTHORIZATION = 4
          NO_BOM_FOUND          = 5
          NO_PLANT_DATA         = 6
          NO_SUITABLE_BOM_FOUND = 7
          CONVERSION_ERROR      = 8
          OTHERS                = 9.

      LOOP AT GT_STB INTO DATA(LS_STB).

        SELECT SINGLE A~MANDT INTO @DATA(LV_MANDT)
                       FROM MARA AS A INNER JOIN T134 AS B
                            ON A~MTART EQ B~MTART
                            WHERE A~MATNR EQ @LS_STB-IDNRK
                                 AND B~MTREF EQ 'ROH'.
        IF LV_MANDT IS NOT INITIAL.

          CLEAR GS_BOM_P.
          PERFORM CONVERSION_EXIT USING GS_DISP-AUFNR '-' CHANGING GS_BOM_P-AUFNR.
*- Start 2025.06.02
*          gs_bom_p-gamng = gs_disp-gamng.
          GS_BOM_P-GAMNG = GV_MENGE.
*- End 2025.06.02
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              INPUT  = LS_STB-IDNRK
            IMPORTING
              OUTPUT = GS_BOM_P-MATNR.
          GS_BOM_P-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX(
                              IV_MATNR = GS_BOM_P-MATNR ).
*          gs_bom_p-menge = ls_stb-menge.
          GS_BOM_P-MEINS = LS_STB-MEINS.
          APPEND GS_BOM_P TO GT_BOM_P.

        ENDIF.

        CLEAR : LV_MANDT, LS_STB.

      ENDLOOP.

    ENDLOOP.
* 취합된 데이터가 있으면 팝업 띄움
    IF GT_BOM_P[] IS NOT INITIAL.
      SORT GT_BOM_P BY AUFNR MATNR.
      CALL SCREEN 0400 STARTING AT 2 2 ENDING AT 110 20.
    ENDIF.

    CHECK GV_STOP IS INITIAL.

    LOOP AT GT_ROW INTO GS_ROW.

      CLEAR : GS_DISP, GV_ZZORIGIN.
      READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
* 탈피 오더 생성
      PERFORM FIRST_CREATE_TALPI.
*- Start 2025.06.02
** 라우팅 변경
*      PERFORM second_modify_rout_order.
*- End 2025.06.02
* BOM 변경
      PERFORM THIRD_MODIFY_BOM_ORDER.
* 재작업 오더 추가 필드 설정
      SELECT SINGLE MANDT INTO GV_MANDT FROM AUFK
                                        WHERE AUFNR EQ GV_ORDER_NUMBER.
      IF GV_MANDT IS INITIAL.
        COMMIT WORK AND WAIT.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GS_DISP-AUFNR
        IMPORTING
          OUTPUT = GV_ZZORIGIN.

      UPDATE AUFK SET ZZORIGIN = GV_ZZORIGIN
                  WHERE AUFNR EQ GV_ORDER_NUMBER.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

      MODIFY GT_DISP FROM GS_DISP INDEX GS_ROW-INDEX.

    ENDLOOP.
* 에러 건이 있을 시에만 처리 결과를 반영하고, 없으면 데이터 REFRESH할 것
    IF GV_NO <> 0.

*      IF gv_yes <> 0 AND gv_no = 0.
*        CONCATENATE TEXT-026 gv_all TEXT-016 gv_yes TEXT-018 INTO gv_message
*             SEPARATED BY space.
*        MESSAGE s003 WITH gv_message.
*      ELSEIF gv_yes <> 0 AND gv_no <> 0.
      IF GV_YES <> 0 AND GV_NO <> 0.
        CONCATENATE TEXT-026 GV_ALL TEXT-016 GV_YES TEXT-017 GV_NO TEXT-018
               INTO GV_MESSAGE SEPARATED BY SPACE.
        MESSAGE S003 WITH GV_MESSAGE.
      ELSEIF GV_YES = 0 AND GV_NO <> 0.
        CONCATENATE TEXT-026 GV_ALL TEXT-017 GV_NO TEXT-018 INTO GV_MESSAGE
          SEPARATED BY SPACE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH GV_MESSAGE.
      ENDIF.

    ELSE.

      PERFORM GET_PROC.

    ENDIF.
* REFRESH DISPLAY
    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GV_STABLE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form first_create_talpi
*&---------------------------------------------------------------------*
FORM FIRST_CREATE_TALPI.

  CLEAR : GS_ORDERDATA, GS_RETURN, GV_ORDER_NUMBER, GV_ORDER_TYPE.
  GV_ALL = GV_ALL + 1.
  GS_ORDERDATA-MATERIAL = GV_MATNR4. "선택한 탈피 자재
  GS_ORDERDATA-PLANT = P_WERKS. "플랜트
  GS_ORDERDATA-ORDER_TYPE = 'RW01'. "탈피
  GS_ORDERDATA-BASIC_START_DATE = GV_S_DAY. "시작일
  GS_ORDERDATA-BASIC_END_DATE = GV_E_DAY. "종료일
  GS_ORDERDATA-ORDER_PRIORITY = '8'. "오더 우선순위
*- Start 2025.06.02
  GS_ORDERDATA-QUANTITY = GV_MENGE.
  GS_ORDERDATA-QUANTITY_UOM = GS_DISP-MEINS.
*- End 2025.06.02
  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = GS_ORDERDATA
    IMPORTING
      RETURN       = GS_RETURN
      ORDER_NUMBER = GV_ORDER_NUMBER
      ORDER_TYPE   = GV_ORDER_TYPE.

  IF GV_ORDER_NUMBER IS INITIAL.

    GV_NO = GV_NO + 1.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GS_DISP-RESULT   = ICON_LED_RED.
    GS_DISP-BAPI_MSG = GS_RETURN-MESSAGE.

  ELSE.

    GV_YES = GV_YES + 1.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    WAIT UP TO '0.5' SECONDS.

    GS_DISP-RESULT = ICON_LED_GREEN.
    CONCATENATE TEXT-021 GV_ORDER_NUMBER INTO GS_DISP-BAPI_MSG
                                         SEPARATED BY SPACE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form second_modify_rout_order
*&---------------------------------------------------------------------*
FORM SECOND_MODIFY_ROUT_ORDER .

  DATA : LV_BMSCH(13) VALUE '1000',
*         lv_meinh     LIKE afvgd-meinh VALUE 'M',
         LV_UMREZ(5)  VALUE '1'.

  CHECK GV_ORDER_NUMBER IS NOT INITIAL.

  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOKO1'                '0110',
    ' '  'BDC_OKCODE'              '=VGUE',
    ' '  'CAUFVD-AUFNR'            GV_ORDER_NUMBER,
    ' ' 'R62CLORD-FLG_OVIEW' GC_X.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOVG'                '0100',
    ' '  'BDC_OKCODE'              '=ALAV',
    ' '  'RC27X-FLG_SEL(01)'    GC_X.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOVF'                '0100',
    ' '  'BDC_OKCODE'              '=VOGW'.

  CONDENSE : LV_BMSCH, LV_UMREZ.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOVF'                '0100',
    ' '   'BDC_OKCODE'            '=BU',
    ' '   'AFVGD-BMSCH'     LV_BMSCH,
*    ' '   'AFVGD-MEINH'       lv_meinh,
    ' '   'AFVGD-UMREZ'     LV_UMREZ,
    ' '   'AFVGD-UMREN'     LV_UMREZ,
    ' '   'AFVGD-VGW01'      SPACE,
    ' '   'AFVGD-VGW02'      SPACE,
    ' '   'AFVGD-VGW03'      SPACE,
    ' '   'AFVGD-VGW04'      SPACE,
    ' '   'AFVGD-VGW05'      SPACE,
    ' '   'AFVGD-VGW06'      SPACE.

  GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
  GS_BDCPARAMS-DISMODE = 'N'.
  GS_BDCPARAMS-UPDMODE = 'S'.
  CALL TRANSACTION 'CO02'          "Transaction Call.
             USING GT_BDCDATA
             OPTIONS FROM GS_BDCPARAMS
             MESSAGES INTO GT_MSGCOLL.

  CLEAR : GT_MSGCOLL.
  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'S'
                                 MSGID  = 'CO'
                                 MSGNR  = '100'.

  IF SY-SUBRC = 0.

    WAIT UP TO '0.5' SECONDS.
    GS_DISP-RESULT = ICON_LED_GREEN.
    CONCATENATE GS_DISP-BAPI_MSG '//' TEXT-022 INTO GS_DISP-BAPI_MSG
                                               SEPARATED BY SPACE.

  ELSE.

    GS_DISP-RESULT = ICON_LED_RED.
    CONCATENATE GS_DISP-BAPI_MSG '//' TEXT-023 INTO GS_DISP-BAPI_MSG
                                               SEPARATED BY SPACE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form third_modify_bom_order
*&---------------------------------------------------------------------*
FORM THIRD_MODIFY_BOM_ORDER .

  DATA : LV_MENGE(13),
         LV_VORNR(4)  VALUE '0010',
         LV_LGPRO(4),
         LV_AUFNR     LIKE AUFK-AUFNR.

  CHECK GV_ORDER_NUMBER IS NOT INITIAL.

  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL, LV_MENGE.
*- Start 2025.06.02
*  lv_menge = gs_disp-gamng.
  LV_MENGE = GV_MENGE.
*- End 2025.06.02
  SELECT SINGLE LGPRO INTO LV_LGPRO FROM MARC
                                    WHERE WERKS EQ P_WERKS
                                      AND MATNR EQ GS_DISP-MATNR.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOKO1'                '0110',
    ' '  'BDC_OKCODE'               '=KPU2',
    ' '  'CAUFVD-AUFNR'             GV_ORDER_NUMBER,
    ' '  'R62CLORD-FLG_OVIEW'       GC_X.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOMK'                '0120',
    ' '  'BDC_OKCODE'              '=AMAK'.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOMK'                '0120',
    ' '  'BDC_OKCODE'              '=DEL'.

  PERFORM DYNPRO USING:
  'X'  'SAPLSPO2'                '0200',
  ' '  'BDC_OKCODE'              '=OPT1'.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOMK'           '0120',
    ' '   'BDC_OKCODE'        '/00',
    ' '   'RESBD-MATNR(01)'   GS_DISP-MATNR,
    ' '   'RESBD-MENGE(01)'   LV_MENGE,
    ' '   'RESBD-POSTP(01)'   GC_L,
    ' '   'RESBD-VORNR(01)'   LV_VORNR,
    ' '   'RESBD-WERKS(01)'   P_WERKS,
    ' '   'RESBD-LGORT(01)'   LV_LGPRO.
* 오더별 추가 BOM 반영 ( 해당 BDC 파트는 탈피 오더 생성시에만 탐 )
  PERFORM CONVERSION_EXIT USING GS_DISP-AUFNR '-' CHANGING LV_AUFNR.
  LOOP AT GT_BOM_P2 INTO GS_BOM_P WHERE AUFNR EQ LV_AUFNR.

    CLEAR : LV_MENGE, LV_LGPRO.
    LV_MENGE = GS_BOM_P-MENGE.
    SELECT SINGLE LGPRO INTO LV_LGPRO FROM MARC
                                      WHERE WERKS EQ P_WERKS
                                        AND MATNR EQ GS_BOM_P-MATNR.

    PERFORM DYNPRO USING:
      'X'  'SAPLCOMK'              '0120',
      ' '  'BDC_OKCODE'            '=P+'.

    PERFORM DYNPRO USING:
      'X'  'SAPLCOMK'           '0120',
      ' '   'BDC_OKCODE'        '/00',
      ' '   'RESBD-MATNR(02)'   GS_BOM_P-MATNR,
      ' '   'RESBD-MENGE(02)'   LV_MENGE,
      ' '   'RESBD-EINHEIT(02)' GS_BOM_P-MEINS,
      ' '   'RESBD-POSTP(02)'   GC_L,
      ' '   'RESBD-VORNR(02)'   LV_VORNR,
      ' '   'RESBD-WERKS(02)'   P_WERKS,
      ' '   'RESBD-LGORT(02)'   LV_LGPRO.

  ENDLOOP.

  PERFORM DYNPRO USING:
    'X'  'SAPLCOMK'              '0120',
    ' '  'BDC_OKCODE'            '=BU'.

  GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
  GS_BDCPARAMS-DISMODE = 'E'.
  GS_BDCPARAMS-UPDMODE = 'S'.
  CALL TRANSACTION 'CO02'          "Transaction Call.
             USING GT_BDCDATA
             OPTIONS FROM GS_BDCPARAMS
             MESSAGES INTO GT_MSGCOLL.

  CLEAR : GT_MSGCOLL.
  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'S'
                                 MSGID  = 'CO'
                                 MSGNR  = '100'.

  IF SY-SUBRC = 0.

    WAIT UP TO '0.5' SECONDS.
    GS_DISP-RESULT = ICON_LED_GREEN.
    CONCATENATE GS_DISP-BAPI_MSG '//' TEXT-024 INTO GS_DISP-BAPI_MSG
                                               SEPARATED BY SPACE.

  ELSE.

    GS_DISP-RESULT = ICON_LED_RED.
    CONCATENATE GS_DISP-BAPI_MSG '//' TEXT-025 INTO GS_DISP-BAPI_MSG
                                               SEPARATED BY SPACE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FIELDNAME   TYPE LVC_FNAME
                                 PV_FIELDVALUE  TYPE LVC_VALUE
                                 PS_ROW_NO     TYPE LVC_S_ROID
                                 PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                                 PT_BAD_CELLS  TYPE LVC_T_MODI
                                 PV_DISPLAY     TYPE CHAR01.

  FIELD-SYMBOLS <FS_MODI> TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING.
  DATA : LV_MATKL LIKE MARA-MATKL.

  READ TABLE GT_POPUP INTO GS_POPUP INDEX PS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC = 0.

  CASE PV_FIELDNAME.
    WHEN 'IDNRK'.

      SELECT SINGLE MATKL INTO LV_MATKL FROM MARA
                   WHERE MATNR EQ GS_POPUP-MATNR.

      PERFORM        SEARCH_HELP_FOR_IDNRK
            CHANGING GS_POPUP-IDNRK GS_POPUP-MAKTX2 LV_MATKL.

      IF NOT GS_POPUP IS INITIAL AND
             PV_DISPLAY    IS INITIAL.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <FS_MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GS_POPUP-IDNRK.
        APPEND LS_MODI TO <FS_MODI>.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <FS_MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'MAKTX2'.
        LS_MODI-VALUE     = GS_POPUP-MAKTX2.
        APPEND LS_MODI TO <FS_MODI>.

        MODIFY GT_POPUP FROM GS_POPUP INDEX PS_ROW_NO-ROW_ID.

      ENDIF.

  ENDCASE.

  PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form search_help_for_idnrk
*&---------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_IDNRK CHANGING PV_MATNR PV_MAKTX PV_MATKL.

  CLEAR GT_MATNR2.

  CALL FUNCTION 'ZGTPP_INPUT_ALTER_F4' STARTING NEW TASK 'F4'
    PERFORMING GET_DATA_MATNR_F4 ON END OF TASK
    EXPORTING
      I_MATKL = PV_MATKL
      I_WERKS = P_WERKS.

  WAIT UNTIL GV_JOBS = '1'.

  PV_MATNR = GV_MATNR3.
  PV_MAKTX = GV_MAKTX3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_delete_order
*&---------------------------------------------------------------------*
FORM PROCESS_DELETE_ORDER .

  DATA: LT_ORDERS	       TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN OCCURS 0 WITH HEADER LINE.

  CLEAR : GS_ROW, GT_ROW, GV_ERROR, GV_ANSWER, GV_CNT, GV_CNT2, GV_CNT3, GV_MESSAGE.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E17.
    RETURN.
  ENDIF.

  LOOP AT GT_ROW INTO GS_ROW.
* 오더 유형 "RP01", "RW01". 오더 상태 "생성", "릴리즈"만 삭제 가능
    CLEAR GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-AUART = 'RP01' OR "재생산(Reprocess) 오더
      GS_DISP-AUART = 'RW01'. "재작업(Rework), 수리(Repair) 오더
      IF GS_DISP-STAT_T EQ TEXT-010 OR "생성
        GS_DISP-STAT_T EQ TEXT-009. "릴리즈
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E18.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E18.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF GV_ERROR IS INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        TITEL     = TEXT-M11
        TEXTLINE1 = TEXT-M12
      IMPORTING
        ANSWER    = GV_ANSWER.

    CHECK GV_ANSWER = 'J'.

    LOOP AT GT_ROW INTO GS_ROW.

      CLEAR GS_DISP.
      READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
      GV_CNT =  GV_CNT + 1.

      CLEAR: LT_DETAIL_RETURN, LT_DETAIL_RETURN[], LT_ORDERS, LT_ORDERS[].
      LT_ORDERS-ORDER_NUMBER = GS_DISP-AUFNR.
      APPEND LT_ORDERS.

      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        EXPORTING
          WORK_PROCESS_GROUP = 'COWORK_BAPI'
          WORK_PROCESS_MAX   = 99
        TABLES
          ORDERS             = LT_ORDERS
          DETAIL_RETURN      = LT_DETAIL_RETURN.

      READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.

        GV_CNT2 =  GV_CNT2 + 1.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        GS_DISP-RESULT = ICON_LED_GREEN.
        GS_DISP-BAPI_MSG = TEXT-S03.
        GS_DISP-STAT_T = TEXT-032.

      ELSE.

        GV_CNT3 =  GV_CNT3 + 1.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = 'E'.
        GS_DISP-RESULT = ICON_LED_RED.
        GS_DISP-BAPI_MSG = LT_DETAIL_RETURN-MESSAGE.

      ENDIF.

      MODIFY GT_DISP FROM GS_DISP INDEX GS_ROW-INDEX.

    ENDLOOP.
* 에러 건이 있을 시에만 처리 결과를 반영하고, 없으면 데이터 REFRESH할 것
    IF GV_CNT3 IS NOT INITIAL.

      CONCATENATE TEXT-M13 GV_CNT TEXT-M04 GV_CNT2 TEXT-M05 GV_CNT3 TEXT-M06
                      INTO GV_MESSAGE SEPARATED BY SPACE.
      MESSAGE S003 DISPLAY LIKE 'S' WITH GV_MESSAGE.

    ELSE.

      PERFORM GET_PROC.

    ENDIF.
* REFRESH DISPLAY
    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GV_STABLE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_matnr
*&---------------------------------------------------------------------*
FORM GET_DATA_MATNR USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_INPUT_ALTER_MAT'
    TABLES
      IT_MATNR = GT_MATNR.

  GV_JOBS = '1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_matnr_f4
*&---------------------------------------------------------------------*
FORM GET_DATA_MATNR_F4 USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_INPUT_ALTER_F4'
  TABLES
    IT_MATNR = GT_MATNR2.

  READ TABLE GT_MATNR2 INTO DATA(LS_MATNR2) INDEX 1.
  IF SY-SUBRC = 0.
    GV_MATNR3 = LS_MATNR2-MATNR.
    GV_MAKTX3 = LS_MATNR2-MAKTX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_talpi_order
*&---------------------------------------------------------------------*
FORM CREATE_TALPI_ORDER .

  DATA : LV_OBJNR     TYPE JEST-OBJNR,
         LV_LINE      LIKE BSVX-STTXT,
         LV_USER_LINE LIKE BSVX-STTXT.
  DATA : LV_AUFNR LIKE AUFK-AUFNR.

  CLEAR : GS_ROW, GT_ROW.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E14.
    RETURN.
  ENDIF.
* 표준 생산 오더 "PP01" OR "PP05" 아니면 오류
  CLEAR : GV_ERROR, GV_ANSWER, GV_S_DAY, GV_E_DAY, GV_ALL, GV_YES, GV_NO, GV_MESSAGE,
          GT_AUFNR3, GT_AUFNR3[], GT_MATNR3, GT_MATNR3[], GS_MSEG, GT_MSEG, GV_MATNR4,
          GV_MAKTX4, GV_STOP, GV_MENGE.

  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR : GS_DISP, GV_ZZORIGIN, LV_AUFNR.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-AUART EQ 'PP01' OR GS_DISP-AUART EQ 'PP05'.
* 선택한 오더로 생성된 "RW01"건이 있는 지 확인
      PERFORM CONVERSION_EXIT USING GS_DISP-AUFNR '-' CHANGING GV_ZZORIGIN.
      SELECT SINGLE AUFNR INTO @LV_AUFNR FROM AUFK
                                         WHERE ZZORIGIN = @GV_ZZORIGIN
                                           AND AUART = 'RW01'.
* 해당 오더가 삭제되었는 지 체크
      IF LV_AUFNR IS NOT INITIAL.

        CLEAR : LV_OBJNR, LV_LINE, LV_USER_LINE.
        CONCATENATE 'OR' LV_AUFNR INTO LV_OBJNR.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            FLG_USER_STAT    = 'X'
            OBJNR            = LV_OBJNR
            ONLY_ACTIVE      = 'X'
            SPRAS            = SY-LANGU
            BYPASS_BUFFER    = ABAP_TRUE
          IMPORTING
            LINE             = LV_LINE
            USER_LINE        = LV_USER_LINE
          EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'DLFL' IN LV_LINE MATCH COUNT DATA(LV_LINE2). "삭제
        IF LV_LINE2 = 0.
          MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E24.
          GV_ERROR = 'X'.
          EXIT.
        ENDIF.

      ENDIF.

      GT_AUFNR3-AUFNR = GS_DISP-AUFNR.
      APPEND GT_AUFNR3.
      CLEAR GT_AUFNR3.

      GT_MATNR3-MATNR = GS_DISP-MATNR.
      APPEND GT_MATNR3.
      CLEAR GT_MATNR3.

    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E16.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERROR IS INITIAL.

  SORT GT_MATNR3 BY MATNR.
  DELETE ADJACENT DUPLICATES FROM GT_MATNR3 COMPARING MATNR.
*- Start 2025.06.02
* 생산 오더는 한 건만 선택되어야 함.
  IF LINES( GT_AUFNR3 ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E20.
    RETURN.
*- End 2025.06.02
* 탈피 오더 생성
  ELSE.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        TITEL     = TEXT-M09
        TEXTLINE1 = TEXT-M10
      IMPORTING
        ANSWER    = GV_ANSWER.

    CHECK GV_ANSWER = 'J'.
* 탈피 오더 생성 및 라우팅, BOM 업데이트
    PERFORM CREATE_TALPI_PROD_ORDER.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_error_rework_order
*&---------------------------------------------------------------------*
FORM CHECK_ERROR_REWORK_ORDER .

  DATA : LV_OBJNR     TYPE JEST-OBJNR,
         LV_LINE      LIKE BSVX-STTXT,
         LV_USER_LINE LIKE BSVX-STTXT.
  DATA : LV_AUFNR LIKE AUFK-AUFNR.

  CLEAR : GS_ROW, GT_ROW.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.
* 라인 선택 확인
  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E12.
    RETURN.
  ENDIF.
* 오더 유형 "RW01" 기준 원 오더 RESB에 탈피 오더 RW01 오더 자재 없으면 오류 메시지 처리
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR : GS_DISP, GV_MANDT, GV_ZZORIGIN.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
    IF GS_DISP-AUART = 'RW01'.
* 선택한 오더의 ZZORIGIN으로 생성된 "RP01"건이 있는 지 확인
      PERFORM CONVERSION_EXIT USING GS_DISP-ZZORIGIN '-' CHANGING GV_ZZORIGIN.
      SELECT SINGLE AUFNR INTO @LV_AUFNR FROM AUFK
                                         WHERE ZZORIGIN = @GV_ZZORIGIN
                                           AND AUART = 'RP01'.
* 해당 오더가 삭제되었는 지 체크
      IF LV_AUFNR IS NOT INITIAL.
        CLEAR : LV_OBJNR, LV_LINE, LV_USER_LINE.
        CONCATENATE 'OR' LV_AUFNR INTO LV_OBJNR.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            FLG_USER_STAT    = 'X'
            OBJNR            = LV_OBJNR
            ONLY_ACTIVE      = 'X'
            SPRAS            = SY-LANGU
            BYPASS_BUFFER    = ABAP_TRUE
          IMPORTING
            LINE             = LV_LINE
            USER_LINE        = LV_USER_LINE
          EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'DLFL' IN LV_LINE MATCH COUNT DATA(LV_LINE2). "삭제
        IF LV_LINE2 = 0.
          MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E25.
          GV_ERROR = 'X'.
          EXIT.
        ENDIF.

      ENDIF.

      IF GS_DISP-ZZORIGIN IS NOT INITIAL.
        PERFORM CONVERSION_EXIT USING GS_DISP-ZZORIGIN '+' CHANGING GV_ZZORIGIN.
      ENDIF.

      SELECT SINGLE MANDT INTO @GV_MANDT FROM RESB
                                         WHERE AUFNR EQ @GV_ZZORIGIN
                                           AND MATNR EQ @GS_DISP-MATNR
                                           AND XLOEK EQ @SPACE.

      IF GV_MANDT IS INITIAL.
        GV_ERROR = 'X'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E15.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT USING PV_VALUE PV_SIGN
                                    CHANGING PV_VALUE2.

  IF PV_SIGN = '+'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE2.

  ELSE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0400
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0400 .

  CREATE OBJECT GO_CONTAIN_0400
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

  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0400
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0400 .

  CLEAR GS_LAYOUT_0220.
*  gs_layout_0220-cwidth_opt = abap_true.
  GS_LAYOUT_0220-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0220-SEL_MODE   = 'A'.
  GS_LAYOUT_0220-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0400
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0400 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2030TOP'
      I_INTERNAL_TABNAME     = 'GS_BOM_P'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_BOM_P
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "기존오더
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "오더수량
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "탈피오더투입자재
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "투입자재명
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '24'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "투입수량
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "단위
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0400
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0400 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
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
*& Form call_grid_0400_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0400_DISPLAY .

  CALL METHOD GO_GRID_0400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0400
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0400
    CHANGING
      IT_OUTTAB            = GT_BOM_P
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_bom_data
*&---------------------------------------------------------------------*
FORM INPUT_BOM_DATA .

  DATA : LV_ERROR.

  CLEAR : GS_ROW3, GT_ROW3, GT_BOM_P2, LV_ERROR.
  CALL METHOD GO_GRID_0400->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW3.
* 선택 라인 중 투입 수량이 비어있으면 에러메시지
  LOOP AT GT_ROW3 INTO GS_ROW3.

    CLEAR GS_BOM_P.
    READ TABLE GT_BOM_P INTO GS_BOM_P INDEX GS_ROW3-INDEX.
    IF GS_BOM_P-MENGE = 0.
      APPEND GS_BOM_P TO GT_BOM_P2.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E23.
      LV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  CHECK LV_ERROR IS INITIAL.

  IF GT_ROW3[] IS NOT INITIAL.

    LOOP AT GT_ROW3 INTO GS_ROW3.

      CLEAR GS_BOM_P.
      READ TABLE GT_BOM_P INTO GS_BOM_P INDEX GS_ROW3-INDEX.
      IF SY-SUBRC = 0.
        APPEND GS_BOM_P TO GT_BOM_P2.
      ENDIF.

    ENDLOOP.
* 선택이 없을 경우 투입 수량이 있는 건만 반영
  ELSE.

    LOOP AT GT_BOM_P INTO GS_BOM_P WHERE MENGE > 0.
      APPEND GS_BOM_P TO GT_BOM_P2.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
                      ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH TEXT-033 P_WERKS TEXT-E26.
  ELSE.
*& SPG에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
                        ID 'WERKS'  FIELD P_WERKS
                        ID 'SPGCD'  FIELD P_SPGCD.

    IF SY-SUBRC <> 0.
      MESSAGE E006 WITH 'SPG {' P_SPGCD TEXT-E26.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form merge_popup_menge
*&---------------------------------------------------------------------*
FORM MERGE_POPUP_MENGE .

  SELECT A~AUFNR, A~MATNR, A~BWART, A~MENGE
      INTO CORRESPONDING FIELDS OF TABLE @GT_MSEG
      FROM MSEG AS A INNER JOIN MARA AS B
        ON A~MATNR EQ B~MATNR
        INNER JOIN T134 AS C
        ON B~MTART EQ C~MTART
        WHERE A~AUFNR EQ @GS_DISP-AUFNR
           AND BWART IN ( '101', '102' ).
* 입고 데이터를 먼저 체크하고, 없으면 예약 데이터를 체크
  IF GT_MSEG[] IS NOT INITIAL.

    LOOP AT GT_MSEG INTO GS_MSEG.

      IF GS_MSEG-BWART = '102'.
        GS_MSEG-MENGE = GS_MSEG-MENGE * -1.
      ENDIF.
      GV_MENGE = GV_MENGE + GS_MSEG-MENGE. "계산된 재작업 생산 수량

    ENDLOOP.
* 입고 내역이 없으면 원 오더의 생산량
  ELSE.

    GV_MENGE = GS_DISP-GAMNG.

  ENDIF.
* 생산량 < 투입 수량인 경우, 생산량 = 투입 수량으로 변경
  IF GS_DISP-GAMNG < GV_MENGE.
    GV_MENGE = GS_DISP-GAMNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_2010_PEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_ZZORIGIN
*&---------------------------------------------------------------------*
FORM SET_2010_PEGGING  USING    PV_ZZORIGIN TYPE AUFNR
                                                 PV_TO_ORDER TYPE AUFNR.

  DATA : LV_ORIGN TYPE AUFNR.
  DATA : LV_TO_ORDER TYPE AUFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_ZZORIGIN
    IMPORTING
      OUTPUT = LV_ORIGN.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_TO_ORDER
    IMPORTING
      OUTPUT = LV_TO_ORDER.

  SELECT * FROM ZGTPPT2010
       INTO TABLE @DATA(LT_ORIGN)
     WHERE ORDNR  = @LV_ORIGN
         AND ORDTY  = 'PRD'.

  SELECT DISTINCT B~*
    FROM @LT_ORIGN AS A
    INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                        AND B~REORD = A~ORDNR
                                        AND B~RELINE = A~POSNR
    INTO TABLE @DATA(LT_DEV).

  SELECT DISTINCT B~*
    FROM @LT_ORIGN AS A
    INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                        AND B~DMORD = A~ORDNR
                                        AND B~DMLINE = A~POSNR
    INTO TABLE @DATA(LT_PRE).

* 현재 참조 오더의 변경
  IF LT_ORIGN IS NOT INITIAL.
    DELETE ZGTPPT2010 FROM TABLE LT_ORIGN.

    LOOP AT LT_ORIGN ASSIGNING FIELD-SYMBOL(<LS_ORIGN>).
      <LS_ORIGN>-ORDNR = LV_TO_ORDER.
    ENDLOOP.

    MODIFY ZGTPPT2010 FROM TABLE LT_ORIGN.
  ENDIF.

* 현재 참조 오더의 이후공정 변경
  IF LT_DEV IS NOT INITIAL.
    DELETE ZGTPPT2010 FROM TABLE LT_DEV.

    LOOP AT LT_DEV ASSIGNING FIELD-SYMBOL(<LS_DEV>).
      <LS_DEV>-REORD = LV_TO_ORDER.
    ENDLOOP.

    MODIFY ZGTPPT2010 FROM TABLE LT_DEV.
  ENDIF.


* 현재 참조 오더의 이전공정 변경
  IF LT_PRE IS NOT INITIAL.
    DELETE ZGTPPT2010 FROM TABLE LT_PRE.

    LOOP AT LT_PRE ASSIGNING FIELD-SYMBOL(<LS_PRE>).
      <LS_PRE>-DMORD = LV_TO_ORDER.
    ENDLOOP.

    MODIFY ZGTPPT2010 FROM TABLE LT_PRE.
  ENDIF.

  COMMIT WORK AND WAIT.
* 히스토리 테이블 저장.
  READ TABLE LT_ORIGN INTO DATA(LS_ORIGN) INDEX 1.

  DATA LT_2020_SAVE TYPE TABLE OF ZGTPPT2020 .

  SELECT * FROM ZGTPPT2010
    INTO CORRESPONDING FIELDS OF TABLE LT_2020_SAVE
    WHERE GRPNR = LS_ORIGN-GRPNR.

* ZGTPPT2020 저장 기존 데이터 맥스순번 + 1 로 어팬드
  SELECT SINGLE MAX( REVNO )  FROM ZGTPPT2020
       INTO @DATA(LV_MAX_REVNO)
      WHERE GRPNR = @LS_ORIGN-GRPNR.
  IF SY-SUBRC EQ 0.
    LV_MAX_REVNO = LV_MAX_REVNO + 1.
  ELSE.
    LV_MAX_REVNO = 1.
  ENDIF.


  LOOP AT LT_2020_SAVE ASSIGNING FIELD-SYMBOL(<LS_2020>).
    <LS_2020>-REVNO = LV_MAX_REVNO.
    <LS_2020>-AENAM = SY-UNAME.
    <LS_2020>-AEDAT = SY-DATUM.
  ENDLOOP.

  IF LT_2020_SAVE[] IS NOT INITIAL.
    MODIFY ZGTPPT2020 FROM TABLE LT_2020_SAVE.
  ENDIF.
  COMMIT WORK AND WAIT.

  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS                 " 플랜트
    IV_SPGCD = P_SPGCD                 " SPG 코드
    IV_GRPNR = LS_ORIGN-GRPNR                 " 조장 구성표 번호
  ).

ENDFORM.
