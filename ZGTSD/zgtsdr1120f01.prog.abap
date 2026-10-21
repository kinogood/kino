*&---------------------------------------------------------------------*
*& Include          ZSDR1005_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .
  DATA: LV_SUBRC  LIKE SY-SUBRC.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VKORG = PA_VKORG
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E200 WITH PA_VKORG.

  ENDIF.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VTWEG = PA_VTWEG
      I_TYPE  = '2'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E201 WITH PA_VTWEG.

  ENDIF.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_SPART = PA_SPART
      I_TYPE  = '3'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E202 WITH PA_SPART.

  ENDIF.

  CLEAR : LV_SUBRC.
  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VKGRP = PA_VKGRP
      I_TYPE  = '7'
    IMPORTING
      E_SUBRC = LV_SUBRC.
  IF LV_SUBRC <> 0.
    MESSAGE E203 WITH PA_VKGRP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_QUERY .

*- Select VBPA, VBAP(영업문서)/ VBRK, VBRP(대금청구)/ KONV(조건) /ZKONA(계약)
  SELECT
         B~VBELN           " 빌링
         C~POSNR           " 청구항목
         F~KSCHL           " 조건유형
         F~KNUMV           " 조건번호
         C~AUBEL           " 판매오더
         C~AUPOS           " 판매품목
         D~KUNNR           " 고객 (VBAK)
         H~NAME1           " 고객 이름
         A~LIFNR           " 에이전트
         I~NAME1 AS L_NAME1" 에이전트 이름
         B~FKDAT           " 매출일자
         C~NETWR           " 매출액
         B~WAERK           " 통화
         F~KBETR           " 조건값(커미션금액)
         F~KWERT           " 조건값(커미션금액)
         F~WAERS           " 통화
    FROM VBPA AS A INNER JOIN VBRK AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBRP AS C
                   ON A~VBELN = C~VBELN
                   INNER JOIN VBAK AS D
                   ON C~AUBEL = D~VBELN
                   INNER JOIN VBAP AS E
                   ON C~AUBEL = E~VBELN
                  AND C~AUPOS = E~POSNR
                   INNER JOIN KONV AS F
                   ON B~KNUMV = F~KNUMV
                  AND C~POSNR = F~KPOSN
                   INNER JOIN KONH AS G
                   ON F~KNUMH = G~KNUMH
                   LEFT OUTER JOIN KNA1 AS H
                   ON H~KUNNR = D~KUNNR
                   LEFT OUTER JOIN LFA1 AS I
                   ON I~LIFNR = A~LIFNR
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
   WHERE A~PARVW  IN ('ZG','ZH')
     AND A~LIFNR  = SO_BONEM-LOW           " AGENT
     AND F~KSCHL BETWEEN 'ZBO1' AND 'ZBO9' " 조건유형
     AND F~KWERT <> 0                      " 커미션금액
     AND B~FKART = 'F2'                    " 청구(송장)
     AND B~FKSTO <> 'X'                    " 취소문서
*     AND E~ZKNUMA = SO_KNUMA-LOW           " 계약번호
     AND B~FKDAT IN SO_FKDAT               " 매출일자
     AND D~VKORG = PA_VKORG                " 영업 조직
     AND D~VTWEG = PA_VTWEG                " 유통 경로
     AND D~SPART = PA_SPART                " 제품군
     AND D~VKBUR = PA_VKBUR                " 영업소
     AND D~VKGRP = PA_VKGRP                " 영업 그룹
     AND G~KOSRT IN SO_KNUMA.              "계약번호


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_COLOR  USING  PV_COL
                       PV_INT.

  DATA : LS_COLTAB TYPE LVC_S_SCOL,
         LT_COLTAB TYPE LVC_T_SCOL.

  LS_COLTAB-COLOR-COL = PV_COL. " <---- BLUE = 1 GREEN = 5 RED = 6
  LS_COLTAB-COLOR-INT = PV_INT. " <---- For intensifying color

  APPEND LS_COLTAB TO LT_COLTAB.
  INSERT LINES OF LT_COLTAB INTO TABLE GS_ITAB-COLTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_FILENAME .

  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.
*{ ZLSGSD4 - s
  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.
  CLEAR   : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
  REFRESH : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
*} ZLSGSD4 - e

  DATA : BEGIN OF LS_VALUE,
           KNUMA TYPE ZKONA-KNUMA,    "계약
           VKORG TYPE ZKONA-VKORG,    "영업조직
           VTWEG TYPE ZKONA-VTWEG,    "유통경로
           SPART TYPE ZKONA-SPART,    "제품군
           VKBUR TYPE ZKONA-VKBUR,    "영업팀
           VKGRP TYPE ZKONA-VKGRP,    "영업그룹
           BONEM TYPE ZKONA-BONEM,    "에이전트(리베이트 수령인)
         END OF LS_VALUE.
  DATA : LT_VALUE LIKE TABLE OF LS_VALUE.


*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VTWEG'. "유통경로
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_SPART'. "제품군
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VKBUR'. "사업장
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VKGRP'. "영업그룹
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'SO_BONEM-LOW'. "AGENT
  APPEND LT_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.
    PA_VKORG = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKORG TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VTWEG'.
  IF SY-SUBRC = 0.
    PA_VTWEG = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VTWEG TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_SPART'.
  IF SY-SUBRC = 0.
    PA_SPART = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_SPART TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKBUR'.
  IF SY-SUBRC = 0.
    PA_VKBUR = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKBUR TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKGRP'.
  IF SY-SUBRC = 0.
    PA_VKGRP = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKGRP TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'SO_BONEM-LOW'.
  IF SY-SUBRC = 0.
    SO_BONEM-LOW = LT_FIELDS-FIELDVALUE.
    TRANSLATE SO_BONEM-LOW TO UPPER CASE.
  ENDIF.

*{ ZLSGSD4 - s
  IF PA_VKORG IS NOT INITIAL.
    LR_VKORG-LOW    = PA_VKORG.
    LR_VKORG-SIGN   = 'I'.
    LR_VKORG-OPTION = 'EQ'.
    APPEND LR_VKORG.
  ENDIF.
  IF PA_VTWEG IS NOT INITIAL.
    LR_VTWEG-LOW    = PA_VTWEG.
    LR_VTWEG-SIGN   = 'I'.
    LR_VTWEG-OPTION = 'EQ'.
    APPEND LR_VTWEG.
  ENDIF.
  IF PA_SPART IS NOT INITIAL.
    LR_SPART-LOW    = PA_SPART.
    LR_SPART-SIGN   = 'I'.
    LR_SPART-OPTION = 'EQ'.
    APPEND LR_SPART.
  ENDIF.
  IF PA_VKBUR IS NOT INITIAL.
    LR_VKBUR-LOW    = PA_VKBUR.
    LR_VKBUR-SIGN   = 'I'.
    LR_VKBUR-OPTION = 'EQ'.
    APPEND LR_VKBUR.
  ENDIF.
  IF PA_VKGRP IS NOT INITIAL.
    LR_VKGRP-LOW    = PA_VKGRP.
    LR_VKGRP-SIGN   = 'I'.
    LR_VKGRP-OPTION = 'EQ'.
    APPEND LR_VKGRP.
  ENDIF.
  IF SO_BONEM-LOW IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SO_BONEM-LOW
      IMPORTING
        OUTPUT = SO_BONEM-LOW.

    LR_BONEM-LOW    = SO_BONEM-LOW.
    LR_BONEM-SIGN   = 'I'.
    LR_BONEM-OPTION = 'EQ'.
    APPEND LR_BONEM.
  ENDIF.

**- ZKONA Select
*  SELECT KNUMA
*         VKORG
*         VTWEG
*         SPART
*         VKBUR
*         VKGRP
*         BONEM
*    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
*    FROM ZKONA
*   WHERE VKORG = PA_VKORG
*     AND VTWEG = PA_VTWEG
*     AND SPART = PA_SPART
*     AND VKBUR = PA_VKBUR
*     AND VKGRP = PA_VKGRP
*     AND BONEM = SO_BONEM.
  SELECT KNUMA
         VKORG
         VTWEG
         SPART
         VKBUR
         VKGRP
         BONEM
    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
    FROM ZKONA
   WHERE VKORG IN LR_VKORG
     AND VTWEG IN LR_VTWEG
     AND SPART IN LR_SPART
     AND VKBUR IN LR_VKBUR
     AND VKGRP IN LR_VKGRP
     AND BONEM IN LR_BONEM.
*} ZLSGSD4 - e

*- Search Help 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'SO_KNUMA-LOW'
      VALUE_ORG       = 'S'  "'C'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .
*- DOCKING CONTAINER
  CREATE OBJECT G_DOCKING_CONTAINER
    EXPORTING
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
      EXTENSION = 500
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP.

  CREATE OBJECT GRID
    EXPORTING
      I_PARENT = G_DOCKING_CONTAINER.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT .
  CALL METHOD GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CREATE OBJECT EVENT_RECEIVER.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR       FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4          FOR GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT .
  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'COLTAB'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT .
  GS_VARIANT-REPORT   = SY-CPROG.
  GS_VARIANT-USERNAME = SY-UNAME.
  GS_VARIANT-HANDLE   = SY-DYNNR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT .
  DATA(LO_TABLE) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_ITAB ) ).
  DATA(LO_STRUC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE->GET_TABLE_LINE_TYPE( ) ).
  DATA(LT_DFIES) = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).

  GT_FIELDCAT = CORRESPONDING #( LT_DFIES MAPPING REF_TABLE = REFTABLE
                                                  REF_FIELD = REFFIELD ).


  LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).

    CASE <FS_FCAT>-FIELDNAME.
      WHEN 'KNUMA'.
        <FS_FCAT>-COL_POS   = '1'.
        <FS_FCAT>-COLTEXT   = '계약번호'.
        <FS_FCAT>-HOTSPOT   = 'X'.
        <FS_FCAT>-KEY       = 'X'.
        <FS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'BOTEXT'.
        <FS_FCAT>-COL_POS   = '2'.
        <FS_FCAT>-COLTEXT   = '계약내역'.
        <FS_FCAT>-KEY       = 'X'.
        <FS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'DATAB'.
        <FS_FCAT>-COL_POS   = '3'.
        <FS_FCAT>-COLTEXT   = '효력 시작일'.
        <FS_FCAT>-KEY       = 'X'.
        <FS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'DATBI'.
        <FS_FCAT>-COL_POS   = '4'.
        <FS_FCAT>-COLTEXT   = '효력 종료일'.
        <FS_FCAT>-KEY       = 'X'.
        <FS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'VBELN'.
        <FS_FCAT>-COL_POS   = '5'.
        <FS_FCAT>-COLTEXT   = '빌링'.
        <FS_FCAT>-HOTSPOT   = 'X'.
      WHEN 'POSNR'.
        <FS_FCAT>-COL_POS   = '6'.
        <FS_FCAT>-COLTEXT   = '청구항목'.
      WHEN 'KSCHL'.
        <FS_FCAT>-COL_POS   = '7'.
        <FS_FCAT>-COLTEXT   = '조건유형'.
      WHEN 'ZRATE'.
        <FS_FCAT>-COL_POS   = '8'.
        <FS_FCAT>-COLTEXT   = '커미션요율'.
      WHEN 'AUBEL'.
        <FS_FCAT>-COL_POS   = '9'.
        <FS_FCAT>-COLTEXT   = '판매오더'.
        <FS_FCAT>-HOTSPOT   = 'X'.
      WHEN 'AUPOS'.
        <FS_FCAT>-COL_POS   = '10'.
        <FS_FCAT>-COLTEXT   = '판매항목'.
      WHEN 'KUNNR'.
        <FS_FCAT>-COL_POS   = '11'.
        <FS_FCAT>-COLTEXT   = '고객'.
        <FS_FCAT>-HOTSPOT   = 'X'.
      WHEN 'NAME1'.
        <FS_FCAT>-COL_POS   = '12'.
        <FS_FCAT>-COLTEXT   = '이름'.
      WHEN 'LIFNR'.
        <FS_FCAT>-COL_POS   = '13'.
        <FS_FCAT>-COLTEXT   = '에이전트'.
        <FS_FCAT>-HOTSPOT   = 'X'.
      WHEN 'L_NAME1'.
        <FS_FCAT>-COL_POS   = '14'.
        <FS_FCAT>-COLTEXT   = '이름'.
      WHEN 'FKDAT'.
        <FS_FCAT>-COL_POS   = '15'.
        <FS_FCAT>-COLTEXT   = '매출일자'.
      WHEN 'NETWR'.
        <FS_FCAT>-COL_POS   = '16'.
        <FS_FCAT>-COLTEXT   = '매출액'.
        <FS_FCAT>-CFIELDNAME = 'WAERK'.
      WHEN 'WAERK'.
        <FS_FCAT>-COL_POS   = '17'.
        <FS_FCAT>-COLTEXT   = '통화'.

*-> CCM : 12.09.2023 17:33:28 / ZLSGSD3
*수정
      WHEN 'KWERT'.
        <FS_FCAT>-COL_POS    = '18'.
        <FS_FCAT>-COLTEXT    = '커미션금액'.
        <FS_FCAT>-CFIELDNAME = 'WAERS'.
        <FS_FCAT>-DO_SUM     = 'X'.
*      WHEN 'KBETR'.
*        <FS_FCAT>-COL_POS   = '18'.
*        <FS_FCAT>-COLTEXT   = '커미션금액'.
*        <FS_FCAT>-CFIELDNAME = 'WAERS'.
*<-

      WHEN 'WAERS'.
        <FS_FCAT>-COL_POS   = '19'.
        <FS_FCAT>-COLTEXT   = '통화'.
      WHEN 'VBELN_SE'.
        <FS_FCAT>-COL_POS   = '20'.
        <FS_FCAT>-COLTEXT   = '정산오더'.
        <FS_FCAT>-HOTSPOT   = 'X'.

      WHEN OTHERS.
        <FS_FCAT>-TECH      = ABAP_TRUE.
    ENDCASE.
    <FS_FCAT>-KEY = ''.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_SETTLEMENT_BP_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_SETTLEMENT_BP_SAVE .

  DATA : LS_SCROLL           TYPE LVC_S_STBL.
  DATA : LV_LINES            TYPE I,
         LV_COUNT            TYPE I,
*{ SRM2402-06908 - s
*         lv_sum_kbetr        TYPE konv-kbetr,
*         lv_sum_kbetr        TYPE bapicurr-bapicurr,
         LV_SUM_KBETR        TYPE STRING,
*} SRM2402-06908 - e
         LV_SUM_KBETR_C(50),
         LV_BDC_RESULT(1),
         LV_BDC_MESSAGE(120).

  DATA : LS_KNA1    TYPE ZBP0001S, "ZBP0006S (VEND),
         LV_KUNNR   TYPE KUNNR,
         LT_KNB1    LIKE TABLE OF ZBP0002S,
         LS_KNB1    LIKE LINE OF LT_KNB1,
*         LT_LFB1    LIKE TABLE OF ZBP0007S,
*         LS_LFB1    LIKE LINE OF LT_LFB1,
*         LV_LIFNR   TYPE LIFNR,
         LV_BP      LIKE BUT000-PARTNER,
         LV_RESULT  TYPE MSGTY,
         LV_MESSAGE TYPE BAPI_MSG.

  DATA : LV_EMESSAGE(100),
         LV_FIVIEW(1).
*-> CCM : 13.09.2023 01:06:53 / ZLSGSD3
  DATA: LV_INTERNAL TYPE BAPICURR-BAPICURR,
        LV_EXTERNAL TYPE BAPICURR-BAPICURR,
*        lv_sum_out  TYPE c LENGTH 16,
        LV_SUM_OUT  TYPE STRING,
        LV_KRW(1).
*<-

  DATA : L_ANSWER,
         L_QUESTION(100).
  CLEAR : L_ANSWER , L_QUESTION.

  DESCRIBE TABLE GT_ITAB LINES LV_COUNT.
  READ TABLE GT_ITAB INTO DATA(LS_ITAB) INDEX LV_COUNT.

  IF SY-SUBRC = 0.


    READ TABLE GT_ITAB INTO LS_ITAB INDEX 1.

    IF SY-SUBRC = 0.

      IF LS_ITAB-VBELN_SE IS INITIAL.

        CLEAR : LV_INTERNAL, LV_EXTERNAL, LV_SUM_KBETR, LV_KRW.

        LV_INTERNAL = GV_TOTAL_SUM.

        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
          EXPORTING
            CURRENCY        = LS_ITAB-WAERS
            AMOUNT_INTERNAL = LV_INTERNAL
          IMPORTING
            AMOUNT_EXTERNAL = LV_EXTERNAL.

        LV_SUM_KBETR = LV_EXTERNAL.

        IF LS_ITAB-WAERS = 'KRW'.
          LV_KRW = 'X'.
          LV_SUM_OUT = LV_SUM_KBETR.

          CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
            CHANGING
              VALUE = LV_SUM_OUT.

          SHIFT LV_SUM_OUT RIGHT DELETING TRAILING '0 '.
          REPLACE ALL OCCURRENCES OF '.' IN LV_SUM_OUT WITH SPACE.

        ELSE.
          LV_SUM_OUT = LV_SUM_KBETR.
          CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
            CHANGING
              VALUE = LV_SUM_OUT.

          SHIFT LV_SUM_OUT RIGHT DELETING TRAILING '0'.
          CONDENSE LV_SUM_OUT NO-GAPS.

        ENDIF.

        L_QUESTION = |{ LV_SUM_OUT }{ LS_ITAB-WAERS }을 정산 처리 하시겠습니까?'|.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR      = '저장'
            TEXT_QUESTION = L_QUESTION
            TEXT_BUTTON_1 = 'Yes'
            TEXT_BUTTON_2 = 'No'
          IMPORTING
            ANSWER        = L_ANSWER.

        IF L_ANSWER = '1'.
*- 에이전트 회계뷰(FLCU00) 생성여부 확인
*<-  CONFS = '1'확인중...
*        SELECT *
*          FROM LFB1
*          INTO TABLE @DATA(LT_LFB1_C)
*         WHERE LIFNR = @LS_ITAB-LIFNR
*           AND BUKRS = @PA_VKORG
*           AND CONFS = '1'.
          SELECT *
            FROM KNB1
            INTO TABLE @DATA(LT_KNB1_C)
           WHERE KUNNR = @LS_ITAB-LIFNR
             AND BUKRS = @PA_VKORG.

*->
          IF SY-SUBRC = 0.
            LV_FIVIEW = 'X'.
          ELSE.


            SELECT SINGLE *
              INTO @DATA(LS_KNA1_T)
              FROM KNA1
              WHERE LIFNR = @LS_ITAB-LIFNR.

            MOVE-CORRESPONDING LS_KNA1_T TO LS_KNA1.
            LS_KNA1-COUNTRY = LS_KNA1_T-LAND1.

            LS_KNB1-LIFNR = LS_ITAB-LIFNR.
            LS_KNB1-BUKRS = PA_VKORG.
            LS_KNB1-AKONT = '0001140101'.
            APPEND LS_KNB1 TO LT_KNB1.

            CALL FUNCTION 'Z_BP_CUST_MAINTAIN_S4H'
              EXPORTING
                I_KNA1    = LS_KNA1
                I_TASK    = 'U'
              IMPORTING
                E_KUNNR   = LV_KUNNR
                E_BP      = LV_BP
                E_RESULT  = LV_RESULT
                E_MESSAGE = LV_MESSAGE
              TABLES
                T_KNB1    = LT_KNB1.


            IF LV_RESULT <> 'S'.
              LV_EMESSAGE = |정산 중 { LS_ITAB-LIFNR }오류발생:{ LV_MESSAGE }|.
              MESSAGE S000 DISPLAY LIKE 'E' WITH LV_EMESSAGE.
              EXIT.
            ELSE.
              LV_FIVIEW = 'X'.


*              DATA : LV_RISK_CLASS TYPE UKM_RISK_CLASS,
*                     LV_RES        TYPE AS4FLAG,
*                     LV_MSG        TYPE MSGTXT.
*
*              LV_RISK_CLASS = '002'.
*
*              CALL FUNCTION 'Z_BP_CREDIT_RISK_CHG'
*                EXPORTING
*                  IV_KUNNR      = LV_KUNNR
*                  IV_RISK_CLASS = LV_RISK_CLASS
*                IMPORTING
*                  E_RESULT      = LV_RES
*                  E_MSG         = LV_MSG.
            ENDIF.
          ENDIF.

*- 정산 판매오더 생성
          "오더유형 B3 생성
          IF LV_FIVIEW = 'X'.

            IF LV_KRW = 'X'.
              PERFORM BDC_PROCESS_CREATE_B3 USING LS_ITAB
                                                  LV_SUM_OUT
                                                  LV_BDC_RESULT
                                                  LV_BDC_MESSAGE.
            ELSE.
              PERFORM BDC_PROCESS_CREATE_B3 USING LS_ITAB
*                                                  lv_sum_kbetr
                                                  LV_SUM_OUT
                                                  LV_BDC_RESULT
                                                  LV_BDC_MESSAGE.
            ENDIF.

            IF LV_BDC_RESULT = 'S'.
              LOOP AT GT_ITAB ASSIGNING FIELD-SYMBOL(<FS_ITAB>) WHERE LINE IS NOT INITIAL.
                MOVE-CORRESPONDING <FS_ITAB> TO GT_ZSD0018T.
*->[CHG]-------------------------S 2026.02.04
                GT_ZSD0018T-SPMON     = PA_DATE.   "정산일
*                GT_ZSD0018T-SPMON     = LS_ITAB-FKDAT.
*-<[CHG]-------------------------E 2026.02.04
                GT_ZSD0018T-VBELN_SE  = LS_ITAB-VBELN_SE.

                <FS_ITAB>-KBETR     = ABS( <FS_ITAB>-KWERT ) * -1.
                GT_ZSD0018T-KWERT_K = <FS_ITAB>-KBETR.

                GT_ZSD0018T-KWAEH     = <FS_ITAB>-WAERS.
                GT_ZSD0018T-ERNAM     = SY-UNAME.
                GT_ZSD0018T-ERDAT     = SY-DATUM.
                GT_ZSD0018T-ERZET     = SY-UZEIT.
                APPEND GT_ZSD0018T. CLEAR GT_ZSD0018T.

*- ALV 정산오더 필드 갱신
                <FS_ITAB>-VBELN_SE     = LS_ITAB-VBELN_SE.
              ENDLOOP.
              MESSAGE LV_BDC_MESSAGE TYPE 'S'.
              GV_SUCCES = 'X'.
            ELSE.
              MESSAGE LV_BDC_MESSAGE TYPE 'I'.
            ENDIF.
          ENDIF.
        ELSE.  "데이터 저장 X
          EXIT.
        ENDIF.

      ELSE. "정산오더 존재
        LV_EMESSAGE = TEXT-E02."|정산오더가 존재합니다|.
        MESSAGE S000 DISPLAY LIKE 'E' WITH LV_EMESSAGE.
        EXIT.
      ENDIF.

    ENDIF.
  ENDIF.

  IF GT_ZSD0018T[] IS NOT INITIAL.
    MODIFY ZSD0018T FROM TABLE GT_ZSD0018T[].

    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.


  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT.

  CALL METHOD GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_PROCESS_CREATE_B3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_PROCESS_CREATE_B3 USING PS_SELECT STRUCTURE GS_ITAB
                                 PV_SUM_KBETR
                                 PV_BDC_RESULT
                                 PV_BDC_MESSAGE.
  DATA : LV_MESSAGE TYPE STRING.

  DATA : LV_MABNR TYPE MATNR18.


  CLEAR : GT_BDCDATA, GT_BDCDATA[],
          GS_MODE,
          GT_BDCMSG, GT_BDCMSG[].

* BDC Processing MODE 지정
  GS_MODE-DISMODE  = 'N'.
  GS_MODE-UPDMODE  = 'S'.
  GS_MODE-RACOMMIT = 'X'.
  GS_MODE-DEFSIZE  = 'X'.

  LV_MABNR = |COMM_{ PA_SPART }|.
  CONDENSE LV_MABNR.
  PS_SELECT-LIFNR = |{ PS_SELECT-LIFNR ALPHA = OUT }|.

  PERFORM BDC_INPUT USING :
  'SAPMV45A' '0101' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBAK-AUART',
  '        ' '    ' ' ' 'BDC_OKCODE' '=ENT2',
  '        ' '    ' ' ' 'VBAK-AUART' 'B3',              " 오더유형
  '        ' '    ' ' ' 'VBAK-VKORG'  PA_VKORG,         " 영업조직
  '        ' '    ' ' ' 'VBAK-VTWEG'  PA_VTWEG,         " 유통경로
  '        ' '    ' ' ' 'VBAK-SPART'  PA_SPART,         " 제품군
  '        ' '    ' ' ' 'VBAK-VKBUR'  PA_VKBUR,         " 사업장
  '        ' '    ' ' ' 'VBAK-VKGRP'  PA_VKGRP,         " 영업그룹

  'SAPMV45A' '4001' 'X' ' ' ' ',               " 항목개요탭
  '        ' '    ' ' ' 'BDC_OKCODE' '/00',
  '        ' '    ' ' ' 'BDC_CURSOR' 'KUAGV-KUNNR',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,  " AGENT
  '        ' '    ' ' ' 'VBAK-FAKSK'  '08',             " SD 문서의 청구 보류:대변메모점검
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,         " 가격결정일

  'SAPMV45A' '4001' 'X' ' ' ' ',               " 항목개요탭
  '        ' '    ' ' ' 'BDC_OKCODE' '=HEAD',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,  " 판매처
  '        ' '    ' ' ' 'VBKD-FKDAT'  PS_SELECT-FKDAT,  " 청구일(매출일자)
  '        ' '    ' ' ' 'VBAK-FAKSK'  '08',             " SD 문서의 청구 보류:대변메모점검
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,         " 가격결정일
  '        ' '    ' ' ' 'BDC_CURSOR'  'RV45A-MABNR(01)',

  'SAPMV45A' '4002' 'X' ' ' ' ',               " 회계탭
  '        ' '    ' ' ' 'BDC_OKCODE' '/00',
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBAK-WAERK',
  '        ' '    ' ' ' 'VBAK-AUDAT'  SY-DATUM,        " 증빙일
  '        ' '    ' ' ' 'VBAK-VKBUR'  PA_VKBUR,        " 사업장
  '        ' '    ' ' ' 'VBAK-VKGRP'  PA_VKGRP,        " 영업그룹
  '        ' '    ' ' ' 'VBAK-WAERK'  PS_SELECT-WAERS, " 전표통화
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,        " 가격결정일

  'SAPMV45A' '4002' 'X' ' ' ' ',               " 회계탭
  '        ' '    ' ' ' 'BDC_OKCODE' '=T\04',
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBAK-AUDAT',
  '        ' '    ' ' ' 'VBAK-AUDAT'  SY-DATUM,        " 증빙일
  '        ' '    ' ' ' 'VBAK-VKBUR'  PA_VKBUR,        " 사업장
  '        ' '    ' ' ' 'VBAK-VKGRP'  PA_VKGRP,        " 영업그룹
  '        ' '    ' ' ' 'VBAK-WAERK'  PS_SELECT-WAERS, " 전표통화
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,        " 가격결정일

  'SAPMV45A' '4002' 'X' ' ' ' ',               " 회계탭
  '        ' '    ' ' ' 'BDC_OKCODE' '/EBACK',
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBAK-XBLNR',
  '        ' '    ' ' ' 'VBAK-XBLNR' PS_SELECT-KNUMA,  " 참조 문서 번호(계약번호)

  'SAPMV45A' '4001' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_OKCODE' '/00',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,  " 판매처
  '        ' '    ' ' ' 'VBKD-FKDAT'  PS_SELECT-FKDAT,  " 청구일
  '        ' '    ' ' ' 'VBAK-FAKSK'  '08',             " SD 문서의 청구 보류:대변메모점검
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,         " 가격결정일
  '        ' '    ' ' ' 'BDC_CURSOR'  'RV45A-MABNR(01)',
  '        ' '    ' ' ' 'RV45A-MABNR(01)' LV_MABNR,     " 자재 (COMM_41)

  'SAPMV45A' '4001' 'X' ' ' ' ', "
  '        ' '    ' ' ' 'BDC_OKCODE' '/00',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,  " 판매처
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBKD-FBUDA',
  '        ' '    ' ' ' 'VBKD-FKDAT'  PS_SELECT-FKDAT,  " 청구일(매출일자)
  '        ' '    ' ' ' 'VBKD-FBUDA'  PA_DATE,          " 서비스가 제공된 일자 -> 정산일
  '        ' '    ' ' ' 'VBAK-FAKSK'  '08',             " SD 문서의 청구 보류:대변메모점검
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,         " 가격결정일

  'SAPMV45A' '4001' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_OKCODE' '=T\06',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,  " 판매처
  '        ' '    ' ' ' 'VBKD-FKDAT'  PS_SELECT-FKDAT,  " 청구일
  '        ' '    ' ' ' 'VBAK-FAKSK'  '08',             " SD 문서의 청구 보류:대변메모점검
  '        ' '    ' ' ' 'VBKD-PRSDT'  SY-DATUM,         " 가격결정일
  '        ' '    ' ' ' 'BDC_CURSOR'  'RV45A-MABNR(02)',

  'SAPMV45A' '4001' 'X' ' ' ' ',                        " 구성탭
  '        ' '    ' ' ' 'BDC_OKCODE'     '/00',
  '        ' '    ' ' ' 'KUAGV-KUNNR'    PS_SELECT-LIFNR,  " 판매처
  '        ' '    ' ' ' 'BDC_CURSOR'     'KOMV-KBETR(01)',
  '        ' '    ' ' ' 'KOMV-KBETR(01)' PV_SUM_KBETR,     " 조건금액  "PS_SELECT-KBETR,

  'SAPMV45A' '4001' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_OKCODE' '=SICH',
  '        ' '    ' ' ' 'KUAGV-KUNNR' PS_SELECT-LIFNR,    " 판매처
  '        ' '    ' ' ' 'BDC_CURSOR'  'RV45A-MABNR(02)',

  'SAPLSPO2' '0101' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_OKCODE' '=OPT1'.



  CALL TRANSACTION 'VA01' USING GT_BDCDATA[]
                          OPTIONS FROM GS_MODE
                          MESSAGES INTO GT_BDCMSG.

  READ TABLE GT_BDCMSG WITH KEY MSGTYP = 'S'
                                MSGID = 'V1'
                                MSGNR = '311'.

  IF SY-SUBRC = 0.
    PV_BDC_RESULT = 'S'.
    PV_BDC_MESSAGE = TEXT-S01."'정산이 완료 되었습니다.'.
    PS_SELECT-VBELN_SE = GT_BDCMSG-MSGV2.
  ELSE.
    READ TABLE GT_BDCMSG WITH KEY MSGTYP = 'E'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = GT_BDCMSG-MSGID
        MSGNR               = GT_BDCMSG-MSGNR
        MSGV1               = GT_BDCMSG-MSGV1
        MSGV2               = GT_BDCMSG-MSGV2
        MSGV3               = GT_BDCMSG-MSGV3
        MSGV4               = GT_BDCMSG-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = LV_MESSAGE.

    PV_BDC_RESULT = 'E'.
    PV_BDC_MESSAGE = |{ TEXT-E03 }: { LV_MESSAGE }|.
    "|정산오더 생성 중 오류 발생 : { LV_MESSAGE }|.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_INPUT  USING P_PROGRAM P_DYNPRO P_DYNBEGIN P_FNAM P_FVAL.

  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = P_DYNBEGIN.
  GT_BDCDATA-FNAM     = P_FNAM.
  GT_BDCDATA-FVAL     = P_FVAL.
  CONDENSE GT_BDCDATA-FVAL.
  APPEND GT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_SETTLEMENT_BP_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_SETTLEMENT_BP_SAVE .

  DATA : LS_SCROLL TYPE LVC_S_STBL.
  DATA : LV_LINES            TYPE I,
         LV_VBELN_SE_N(1),
         LV_BDC_RESULT(1),
         LV_BDC_MESSAGE(120).

  DATA : L_ANSWER,
         L_QUESTION(100).
  CLEAR : L_ANSWER , L_QUESTION.


  READ TABLE GT_ITAB INTO DATA(LS_ITAB) INDEX 1.
  IF SY-SUBRC = 0.
    IF LS_ITAB-VBELN_SE IS NOT INITIAL.
      L_QUESTION = |정산오더 { LS_ITAB-VBELN_SE } 를 삭제 하시겠습니까?'|.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR      = '삭제'
          TEXT_QUESTION = L_QUESTION
          TEXT_BUTTON_1 = 'Yes'
          TEXT_BUTTON_2 = 'No'
        IMPORTING
          ANSWER        = L_ANSWER.

      IF L_ANSWER = '1'. "삭제 BDC

*- 미지급전표 생성 Check
        SELECT SINGLE BSTKD
          INTO @DATA(LS_VBKD)
          FROM VBKD
         WHERE VBELN = @LS_ITAB-VBELN_SE
           AND POSNR = '000000'.

        IF LS_VBKD IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E'  WITH | 미지급전표 { LS_VBKD } 가 존재하는 정산오더입니다. |.
          EXIT.
        ELSE.


          PERFORM BDC_PROCESS_DELETE_B3 USING LS_ITAB-VBELN_SE
                                              LV_BDC_RESULT
                                              LV_BDC_MESSAGE.

          IF LV_BDC_RESULT = 'S'.
*-  ZSD0018T 삭제
            DELETE FROM ZSD0018T WHERE VBELN_SE = LS_ITAB-VBELN_SE.

            IF SY-SUBRC = 0.
              COMMIT WORK.
            ENDIF.
*- ALV 정산오더 필드 갱신
            LOOP AT GT_ITAB ASSIGNING FIELD-SYMBOL(<FS_ITAB>) WHERE VBELN_SE = LS_ITAB-VBELN_SE.
              <FS_ITAB>-VBELN_SE     = ' '.
            ENDLOOP.

            MESSAGE LV_BDC_MESSAGE TYPE 'S'.
            GV_SUCCES = 'X'.
          ELSE.
            MESSAGE LV_BDC_MESSAGE TYPE 'I'.
          ENDIF.
        ENDIF.
      ELSE.  " 삭제 X
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S000 DISPLAY LIKE 'I'  WITH TEXT-010."'정산오더가 존재하지 않습니다.'.
      EXIT.
    ENDIF.
  ENDIF.




  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT.

  CALL METHOD GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_PROCESS_DELETE_B3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ITAB_VBELN_SE
*&      --> LV_BDC_RESULT
*&      --> LV_BDC_MESSAGE
*&---------------------------------------------------------------------*
FORM BDC_PROCESS_DELETE_B3  USING PV_VBELN_SE
                                  PV_BDC_RESULT
                                  PV_BDC_MESSAGE.

  DATA : LV_MESSAGE TYPE STRING.

  CLEAR : GT_BDCDATA, GT_BDCDATA[],
          GS_MODE,
          GT_BDCMSG, GT_BDCMSG[].

* BDC Processing MODE 지정
  GS_MODE-DISMODE  = 'N'.
  GS_MODE-UPDMODE  = 'S'.
  GS_MODE-RACOMMIT = 'X'.
  GS_MODE-DEFSIZE  = 'X'.

*  PV_VBELN_SE = |{ PV_VBELN_SE ALPHA = OUT }|.

  PERFORM BDC_INPUT USING :
  'SAPMV45A' '0102' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_CURSOR' 'VBAK-VBELN',
  '        ' '    ' ' ' 'BDC_OKCODE' '=ENT2',
  '        ' '    ' ' ' 'VBAK-VBELN' PV_VBELN_SE,       " 정산오더

  'SAPMV45A' '4001' 'X' ' ' ' ',
  '        ' '    ' ' ' 'BDC_OKCODE'  '/ELOES'.

  CALL TRANSACTION 'VA02' USING GT_BDCDATA[]
                          OPTIONS FROM GS_MODE
                          MESSAGES INTO GT_BDCMSG.

  READ TABLE GT_BDCMSG WITH KEY MSGTYP = 'S'
                                MSGID = 'V1'
                                MSGNR = '008'.

  IF SY-SUBRC = 0.
    PV_BDC_RESULT = 'S'.
    PV_BDC_MESSAGE = TEXT-S02."'정산오더가 삭제되었습니다.'.
  ELSE.
    READ TABLE GT_BDCMSG WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC <> 0.
      READ TABLE GT_BDCMSG WITH KEY MSGTYP = 'I'.
    ENDIF.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = GT_BDCMSG-MSGID
        MSGNR               = GT_BDCMSG-MSGNR
        MSGV1               = GT_BDCMSG-MSGV1
        MSGV2               = GT_BDCMSG-MSGV2
        MSGV3               = GT_BDCMSG-MSGV3
        MSGV4               = GT_BDCMSG-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = LV_MESSAGE.

    PV_BDC_RESULT = 'E'.
    PV_BDC_MESSAGE = |{ TEXT-E04 }: { LV_MESSAGE }|.
    "|정산오더 삭제 중 오류 발생 : { LV_MESSAGE }|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN_ID
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM CALL_TRAN  USING P_COLUMN_ID TYPE  LVC_S_COL
                      P_ROW_NO TYPE  LVC_S_ROW.

  CLEAR GS_ITAB.

*-> CCM : 12.09.2023 23:02:27 / ZLSGSD3
  CHECK P_ROW_NO-ROWTYPE+0(1) IS INITIAL.
*<-

  GS_ITAB = GT_ITAB[ P_ROW_NO-INDEX ].

  IF SY-SUBRC = 0.

    CASE P_COLUMN_ID.

      WHEN 'KNUMA'.                                       " 계약번호
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-KNUMA IS NOT INITIAL.
*<-
        GS_ITAB-KNUMA = |{ GS_ITAB-KNUMA ALPHA = OUT }|.
        SET PARAMETER ID 'REQ' FIELD GS_ITAB-KNUMA.
        CALL TRANSACTION 'ZVBO3' AND SKIP FIRST SCREEN.

      WHEN 'VBELN'.                                       " 빌링
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-VBELN IS NOT INITIAL.
*<-
        SET PARAMETER ID 'VF' FIELD GS_ITAB-VBELN.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

      WHEN 'AUBEL'.                                       " 판매오더
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-AUBEL IS NOT INITIAL.
*<-
        SET PARAMETER ID 'AUN' FIELD GS_ITAB-AUBEL.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      WHEN 'KUNNR'.                                       " 고객
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-KUNNR IS NOT INITIAL.
*<-
        SET PARAMETER ID 'KUN' FIELD GS_ITAB-KUNNR.
        SET PARAMETER ID 'VKO' FIELD PA_VKORG.
        SET PARAMETER ID 'VTW' FIELD PA_VTWEG.
        SET PARAMETER ID 'SPA' FIELD PA_SPART.
        CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.

      WHEN 'LIFNR'.                                       " 에이전트
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-LIFNR IS NOT INITIAL.
*<-
        SET PARAMETER ID 'KUN' FIELD GS_ITAB-LIFNR.
        SET PARAMETER ID 'VKO' FIELD PA_VKORG.
        SET PARAMETER ID 'VTW' FIELD PA_VTWEG.
        SET PARAMETER ID 'SPA' FIELD PA_SPART.
        CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.

      WHEN 'VBELN_SE'.                                    " 정산오더
*-> CCM : 12.09.2023 22:54:33 / ZLSGSD3
        CHECK GS_ITAB-VBELN_SE IS NOT INITIAL.
*<-
        SET PARAMETER ID 'AUN' FIELD GS_ITAB-VBELN_SE.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    ENDCASE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT .

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'KNUMA'.
  GS_SORT-UP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.
  CLEAR GS_SORT.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_PROCESSING .
  DATA : LV_SUM_KBETR    TYPE KONV-KBETR,
         LV_KBETR        TYPE P DECIMALS 5,
         LV_KBETR_F      TYPE BSEG-DMBTR,
         LV_MULTIP_K     TYPE P DECIMALS 5,
         LV_UKURS_WAERS  TYPE TCURR-UKURS,
         LV_UKURS_WAERK  TYPE TCURR-UKURS,
         LV_FKDAT        TYPE TCURR-GDATU,
         LV_UKURS(1),
         LV_UKURS_M(100).

  DATA : LV_LINE  TYPE I,
         LV_COUNT TYPE I.

  CLEAR : GV_TOTAL_SUM.

*- //정산오더 ZSD0018T Select
  SELECT *
    INTO TABLE @DATA(LT_ZSD0018T)
    FROM ZSD0018T
    FOR ALL ENTRIES IN @GT_DATA
   WHERE KNUMA = @GT_DATA-KNUMA
     AND VBELN = @GT_DATA-VBELN
     AND POSNR = @GT_DATA-POSNR
     AND AUBEL = @GT_DATA-AUBEL
     AND AUPOS = @GT_DATA-AUPOS.


  SORT : LT_ZSD0018T BY KNUMA VBELN POSNR AUBEL AUPOS,
         GT_DATA     BY KNUMA VBELN POSNR AUBEL AUPOS.

  DESCRIBE TABLE GT_DATA LINES LV_COUNT.

*- ZB 금액 합산 (KONV-KBETR)
  LOOP AT GT_DATA INTO DATA(LS_DATA) .
    READ TABLE LT_ZSD0018T INTO DATA(LS_ZSD0018T) WITH KEY KNUMA = LS_DATA-KNUMA
                                                           VBELN = LS_DATA-VBELN
                                                           AUBEL = LS_DATA-AUBEL
                                                           BINARY SEARCH.
    IF SY-SUBRC = 0.
      LS_DATA-VBELN_SE  = LS_ZSD0018T-VBELN_SE. " 정산오더

      IF P_R1 EQ 'X'. "정산오더 생성의 경우, 정산오더 있으면 제외
        IF LS_ZSD0018T-VBELN_SE IS NOT INITIAL.
          CONTINUE.
        ENDIF.
      ELSEIF P_R2 EQ 'X'."정산오더 삭제의 경우, 정산오더 없으면 제외
        IF LS_ZSD0018T-VBELN_SE IS INITIAL.
          CONTINUE.
        ENDIF.
      ENDIF.

*->[CHG]------------------------------------S 2026.02.09
    ELSE.
      "정산오더 삭제의 경우 ZSD0018T에 없으면 제외
      IF P_R2 EQ 'X'.
        CONTINUE.
      ENDIF.
*-<[CHG]------------------------------------S 2026.02.09
    ENDIF.

    IF LS_DATA-WAERS = ' '.

      LS_DATA-KBETR = ABS( LS_DATA-KBETR / 10 ).
      LS_DATA-ZRATE = |{ LS_DATA-KBETR }% |.



      " Rate 커미션 금액 합산
      SELECT SINGLE WAERS
        INTO LS_DATA-WAERS
        FROM ZKONA
        WHERE KNUMA = LS_DATA-KNUMA.
      IF LS_DATA-WAERS <> LS_DATA-WAERK.
        CLEAR : LV_KBETR_F.
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            DATE             = LS_DATA-FKDAT
            FOREIGN_CURRENCY = LS_DATA-WAERS    "FORIGN_CURRENCY 에는 결과치로 나올 Currency type
            LOCAL_AMOUNT     = LS_DATA-NETWR
            LOCAL_CURRENCY   = LS_DATA-WAERK     "LOCAL_CURRENCY 에는 입력되는 Currency type
            TYPE_OF_RATE     = 'M'        " 'M', 'BS', 'PL'
            READ_TCURR       = 'X'
          IMPORTING
*           EXCHANGE_RATE    =
            FOREIGN_AMOUNT   = LV_KBETR_F
          EXCEPTIONS
            NO_RATE_FOUND    = 1
            OVERFLOW         = 2
            NO_FACTORS_FOUND = 3
            NO_SPREAD_FOUND  = 4
            DERIVED_2_TIMES  = 5
            OTHERS           = 6.


*- 환율 공란 Check
        IF LV_KBETR_F IS INITIAL.
          LV_UKURS = 'X'.
          LV_UKURS_M = |환율이 등록되지 않은 날이 있어, 커미션 금액이 공란이 있습니다. 확인해주세요 : { LV_FKDAT }|.


          CLEAR : LS_DATA-KWERT.

        ENDIF.

        IF LV_UKURS <> 'X'.

          "  커미션 요율 곱할 때 3.1 이면 0.031 로 곱하기
          LV_MULTIP_K = LS_DATA-KBETR / 100.
          LV_KBETR = LV_KBETR_F.
          LV_KBETR = LV_KBETR * LV_MULTIP_K.

          CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
            EXPORTING
              I_RTYPE     = ' ' "반올림 (+올림, -버림)
              I_RUNIT     = '0.01'
              I_VALUE     = LV_KBETR
            IMPORTING
              E_VALUE_RND = LV_KBETR.

          LS_DATA-KWERT = LV_KBETR.

        ENDIF.

      ENDIF.
    ELSE.

      LS_DATA-KBETR =  LS_DATA-KWERT .
    ENDIF.


    LV_LINE = LV_LINE + 1.
    MOVE-CORRESPONDING LS_DATA TO GS_ITAB.

    GS_ITAB-LINE = LV_LINE.
    GS_ITAB-KWERT = ABS( GS_ITAB-KWERT ) * -1.

    GV_TOTAL_SUM = GV_TOTAL_SUM + GS_ITAB-KWERT. "추후 정산오더 생성용 총합

    APPEND GS_ITAB TO GT_ITAB.

    CLEAR : LV_UKURS_WAERS,
            LV_UKURS_WAERK,
            LV_KBETR.

    CLEAR : LV_UKURS.
  ENDLOOP.

  IF LV_UKURS_M IS NOT INITIAL.
    MESSAGE I000  WITH LV_UKURS_M.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KNUMA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_KNUMA .

  DATA : LT_KONV TYPE TABLE OF KONV WITH HEADER LINE.
  DATA : LV_KOSRT TYPE KONH-KOSRT.

  LOOP AT GT_DATA  INTO DATA(LS_DATA) .
    CLEAR : LT_KONV, LT_KONV[].
    CLEAR : LV_KOSRT.

*___ 조건에서 리베이트 찾기
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_KONV
      FROM V_KONV_CDS
      WHERE KNUMV EQ LS_DATA-KNUMV
      AND KPOSN EQ LS_DATA-POSNR
      AND KSCHL EQ LS_DATA-KSCHL
*      AND ( KSCHL EQ 'ZBO1' OR
*            KSCHL EQ 'ZBO2' OR
*            KSCHL EQ 'ZBO3' OR
*            KSCHL EQ 'ZBO4' OR
*            KSCHL EQ 'ZBO5' OR
*            KSCHL EQ 'ZBO6' OR
*            KSCHL EQ 'ZBO7' OR
*            KSCHL EQ 'ZBO8'      )
      AND KWERT <> 0
      AND KVSL1 = 'ERB'.

    IF SY-SUBRC <> 0 .
      DELETE GT_DATA .
      CONTINUE.
    ENDIF.

*___ 계약번호 가져오기
    READ TABLE LT_KONV INDEX 1.
    SELECT SINGLE KOSRT
      INTO LV_KOSRT
      FROM KONH
     WHERE KNUMH = LT_KONV-KNUMH.

    IF LV_KOSRT IS INITIAL.
      DELETE GT_DATA .
      CONTINUE.
    ELSE.
      LS_DATA-KNUMA = LV_KOSRT.
    ENDIF.

*__ 조회조건과 계약번호 일치 여부
    IF LS_DATA-KNUMA <> SO_KNUMA-LOW .
      DELETE GT_DATA .
      CONTINUE.
    ENDIF.

*___계약 내용 가져오기
    SELECT SINGLE
                  BOTEXT
                  DATAB
                  DATBI
     INTO CORRESPONDING FIELDS OF LS_DATA
     FROM ZKONA
    WHERE KNUMA EQ LS_DATA-KNUMA.


    MODIFY GT_DATA FROM LS_DATA.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_KNUMA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KNUMA  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.
*{ ZLSGSD4 - s
  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.
  CLEAR   : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
  REFRESH : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
*} ZLSGSD4 - e

  DATA : BEGIN OF LS_VALUE,
           KNUMA TYPE ZKONA-KNUMA,    "계약
           VKORG TYPE ZKONA-VKORG,    "영업조직
           VTWEG TYPE ZKONA-VTWEG,    "유통경로
           SPART TYPE ZKONA-SPART,    "제품군
           VKBUR TYPE ZKONA-VKBUR,    "영업팀
           VKGRP TYPE ZKONA-VKGRP,    "영업그룹
           BONEM TYPE ZKONA-BONEM,    "에이전트(리베이트 수령인)
         END OF LS_VALUE.
  DATA : LT_VALUE LIKE TABLE OF LS_VALUE.


*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VTWEG'. "유통경로
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_SPART'. "제품군
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VKBUR'. "사업장
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VKGRP'. "영업그룹
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'SO_BONEM-LOW'. "AGENT
  APPEND LT_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.
    PA_VKORG = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKORG TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VTWEG'.
  IF SY-SUBRC = 0.
    PA_VTWEG = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VTWEG TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_SPART'.
  IF SY-SUBRC = 0.
    PA_SPART = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_SPART TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKBUR'.
  IF SY-SUBRC = 0.
    PA_VKBUR = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKBUR TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKGRP'.
  IF SY-SUBRC = 0.
    PA_VKGRP = LT_FIELDS-FIELDVALUE.
    TRANSLATE PA_VKGRP TO UPPER CASE.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'SO_BONEM-LOW'.
  IF SY-SUBRC = 0.
    SO_BONEM-LOW = LT_FIELDS-FIELDVALUE.
    TRANSLATE SO_BONEM-LOW TO UPPER CASE.
  ENDIF.

*{ ZLSGSD4 - s
  IF PA_VKORG IS NOT INITIAL.
    LR_VKORG-LOW    = PA_VKORG.
    LR_VKORG-SIGN   = 'I'.
    LR_VKORG-OPTION = 'EQ'.
    APPEND LR_VKORG.
  ENDIF.
  IF PA_VTWEG IS NOT INITIAL.
    LR_VTWEG-LOW    = PA_VTWEG.
    LR_VTWEG-SIGN   = 'I'.
    LR_VTWEG-OPTION = 'EQ'.
    APPEND LR_VTWEG.
  ENDIF.
  IF PA_SPART IS NOT INITIAL.
    LR_SPART-LOW    = PA_SPART.
    LR_SPART-SIGN   = 'I'.
    LR_SPART-OPTION = 'EQ'.
    APPEND LR_SPART.
  ENDIF.
  IF PA_VKBUR IS NOT INITIAL.
    LR_VKBUR-LOW    = PA_VKBUR.
    LR_VKBUR-SIGN   = 'I'.
    LR_VKBUR-OPTION = 'EQ'.
    APPEND LR_VKBUR.
  ENDIF.
  IF PA_VKGRP IS NOT INITIAL.
    LR_VKGRP-LOW    = PA_VKGRP.
    LR_VKGRP-SIGN   = 'I'.
    LR_VKGRP-OPTION = 'EQ'.
    APPEND LR_VKGRP.
  ENDIF.
  IF SO_BONEM-LOW IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SO_BONEM-LOW
      IMPORTING
        OUTPUT = SO_BONEM-LOW.

    LR_BONEM-LOW    = SO_BONEM-LOW.
    LR_BONEM-SIGN   = 'I'.
    LR_BONEM-OPTION = 'EQ'.
    APPEND LR_BONEM.
  ENDIF.

**- ZKONA Select
  SELECT KNUMA
         VKORG
         VTWEG
         SPART
         VKBUR
         VKGRP
         BONEM
    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
    FROM ZKONA
   WHERE VKORG IN LR_VKORG
     AND VTWEG IN LR_VTWEG
     AND SPART IN LR_SPART
     AND VKBUR IN LR_VKBUR
     AND VKGRP IN LR_VKGRP
     AND BONEM IN LR_BONEM.
*} ZLSGSD4 - e

*- Search Help 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'  "'C'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
*-영업조직
  PA_VKORG = GC_VKORG_6000.

*-정산일
*  PERFORM SET_DATE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VTWEG  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  SELECT A~VKORG,A~VTWEG,B~VTEXT
    FROM TVKOV AS A INNER JOIN TVTWT AS B
                    ON A~VTWEG = B~VTWEG AND
                       B~SPRAS = @SY-LANGU
   WHERE A~VKORG IN @LR_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKORG VTWEG.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VTWEG'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING   PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VTWEG'. "유통경로
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VTWEG'.
  IF SY-SUBRC = 0.
    DATA(LV_VTWEG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VTWEG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VTWEG ) TO LR_VTWEG.
  ENDIF.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @LR_VKORG
     AND VTWEG IN @LR_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING  PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.


  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG IN @LR_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING  PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'PA_VKBUR'. "사업장
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKBUR'.
  IF SY-SUBRC = 0.
    DATA(LV_VKBUR) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKBUR TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKBUR ) TO LR_VKBUR.
  ENDIF.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG IN @LR_VKORG
     AND A~VKBUR IN @LR_VKBUR
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATE .
  DATA:LV_DATE TYPE SY-DATUM.

  LV_DATE = SY-DATUM.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = LV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = LV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

  PA_DATE = LV_DATE.
ENDFORM.
