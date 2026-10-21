*&---------------------------------------------------------------------*
*& Include          ZGTSDR1420F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .


*  G_CUSTOM_CONTAINER = NEW #( CONTAINER_NAME = G_CON ).

  G_DOCKING_CONTAINER = NEW #( REPID     = SY-REPID
                               DYNNR     = SY-DYNNR
                               EXTENSION = 500
                               SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM ).
*
*  GRID = NEW #( I_PARENT = G_DOCKING_CONTAINER ).


**--SPLIT
  G_SPLITTER = NEW #( PARENT = G_DOCKING_CONTAINER ROWS = 2 COLUMNS = 1 ).

  G_SPLITTER->SET_ROW_MODE( MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_ABSOLUTE ).
  G_SPLITTER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 65 ).

  LCL_PARENT_HTML = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LCL_PARENT_GRID = G_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  "TOP-OF-PAGE / 조회조건, 영업조직
  PERFORM BUILD_TOP_OF_PAGE.

  GRID = NEW #( I_PARENT = LCL_PARENT_GRID ).

*  G_CONTAINER  = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  G_CONTAINER2 = G_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*
*  G_SPLITTER->SET_ROW_MODE( MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_RELATIVE ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 50 ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 2 HEIGHT = 50 ).
*
*  GRID  = NEW #( I_PARENT = G_CONTAINER ).
*  GRID2 = NEW #( I_PARENT = L_B_LEFT ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BUILD_TOP_OF_PAGE .

  LCL_DYNDOC_ID = NEW #( STYLE = 'ALV_GRID' ).
  READ TABLE S_REQD INDEX 1.
  DATA(LV_INFO) = CONV SDYDO_TEXT_ELEMENT( |{ TEXT-001 } :  { S_REQD-LOW DATE = USER } ~ { S_REQD-HIGH DATE = USER } | ).
  LCL_DYNDOC_ID->ADD_TEXT(
    TEXT         = LV_INFO

  ).
  LCL_DYNDOC_ID->NEW_LINE( ).


  CLEAR LV_INFO.
  READ TABLE S_VKORG INDEX 1.
  SELECT SINGLE FROM TVKOT FIELDS VTEXT WHERE VKORG IN @S_VKORG AND SPRAS = @SY-LANGU
    INTO @DATA(LV_VTEXT).
  LV_INFO = |영업조직 :  { S_VKORG-LOW }   /   { LV_VTEXT }|.

  LCL_DYNDOC_ID->ADD_TEXT(
    TEXT      = LV_INFO
  ).

  LCL_DYNDOC_ID->DISPLAY_DOCUMENT( PARENT = LCL_PARENT_HTML ).

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

  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT EVENT_RECEIVER.
*  SET HANDLER EVENT_RECEIVER->HANDLE_TOP_OF_PAGE  FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4         FOR GRID.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT CHANGING PS_LAYOUT TYPE LVC_S_LAYO.
  PS_LAYOUT-SEL_MODE   = 'A'.
  PS_LAYOUT-ZEBRA      = 'X'.
  PS_LAYOUT-CWIDTH_OPT = 'X'.
  PS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOUT-CTAB_FNAME = 'CELLCOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  PT_EXCLUDE[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_GRAPH )
                          ( CL_GUI_ALV_GRID=>MC_FC_INFO )
                          ( CL_GUI_ALV_GRID=>MC_FC_DETAIL )
                          ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                        ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_VARIANT
*&---------------------------------------------------------------------*
FORM SET_VARIANT  CHANGING PS_VARIANT TYPE DISVARIANT.
  PS_VARIANT-REPORT   = SY-CPROG.
  PS_VARIANT-USERNAME = SY-UNAME.
  PS_VARIANT-HANDLE   = SY-DYNNR.

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
  DATA(LO_TABLE) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DATA ) ).
  DATA(LO_STRUC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE->GET_TABLE_LINE_TYPE( ) ).
  DATA(LT_DFIES) = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).

  GT_FIELDCAT = CORRESPONDING #( LT_DFIES MAPPING REF_TABLE = REFTABLE
                                                  REF_FIELD = REFFIELD ).

  DEFINE _FIELDCAT.
    CASE &1-FIELDNAME.
      WHEN &2.
     &1-COLTEXT   = &3.
     &1-CHECKBOX  = &4.
     &1-ICON      = &5.
     &1-HOTSPOT   = &6.
     &1-EDIT      = &7.
     &1-EMPHASIZE = &8.
    ENDCASE.
  END-OF-DEFINITION.


  LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).
*                        FIELDNAME    COLTEXT  CHECKOBX ICON HOTSPOT EDIT EMPHASIZE
    _FIELDCAT :
                <FS_FCAT> 'REQNO    ' TEXT-F01 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'VBELN    ' TEXT-F02 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'POSNR    ' TEXT-F03 ' '      ' '  ' '    ' '   '    '   ,
*                <FS_FCAT> 'ETENR    ' TEXT-F04 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'MATNR    ' TEXT-F05 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'ARKTX    ' TEXT-F06 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'ATWRT    ' TEXT-F07 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'REQDATE  ' TEXT-F08 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'REQTYPE  ' TEXT-F09 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'REASON   ' TEXT-F10 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'READTL   ' TEXT-F11 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'EDATU_N  ' TEXT-F12 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'KWMENG_N ' TEXT-F13 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'STATUS_PP' TEXT-F14 ' '      'X'  ' '    ' '   'C300'   ,
                <FS_FCAT> 'STATUS_MM' TEXT-F15 ' '      'X'  ' '    ' '   'C300'   ,
                <FS_FCAT> 'STATUS_ST' TEXT-F16 ' '      'X'  ' '    ' '   'C300'   ,
*                <FS_FCAT> 'CFMPP    ' TEXT-F14 ' '      ' '  ' '    ' '   'C300'   ,
*                <FS_FCAT> 'CFMMM    ' TEXT-F15 ' '      ' '  ' '    ' '   'C300'   ,
*                <FS_FCAT> 'PSTAT    ' TEXT-F16 ' '      ' '  ' '    ' '   'C300'   ,
                <FS_FCAT> 'KUNNR    ' TEXT-F17 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'NAME1    ' TEXT-F18 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'SM_OM    ' TEXT-F19 ' '      ' '  ' '    ' '   '    '   ,
*                <FS_FCAT> 'FIXMG    ' TEXT-F19 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'EDATU    ' TEXT-F20 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'KWMENG   ' TEXT-F21 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'GRQTY    ' TEXT-F22 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'GIQTY    ' TEXT-F23 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'REASONX  ' TEXT-F24 ' '      ' '  ' '    ' '   '    '   ,
*                <FS_FCAT> 'CFMNAME  ' TEXT-F25 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'CFMNAME_T' TEXT-F25 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'CFMDATE  ' TEXT-F26 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'CFMTIME  ' TEXT-F27 ' '      ' '  ' '    ' '   '    '   ,
*                <FS_FCAT> 'PMVNAME  ' TEXT-F28 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'PMVNAME_T' TEXT-F28 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'PMVDATE  ' TEXT-F29 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'PMVTIME  ' TEXT-F30 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'STATUS_SM' TEXT-F31 ' '      'X'  ' '    ' '   '    '   ,
                <FS_FCAT> 'STATUS_AU' TEXT-F32 ' '      'X'  ' '    ' '   '    '   ,
                <FS_FCAT> 'STATUS_PO' TEXT-F33 ' '      'X'  ' '    ' '   '    '   ,
                <FS_FCAT> 'UPDRQ    ' TEXT-F34 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'AUFNR    ' TEXT-F35 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'AUPOS    ' TEXT-F36 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'EBELN    ' TEXT-F37 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'EBELP    ' TEXT-F38 ' '      ' '  ' '    ' '   '    '   .

    CASE <FS_FCAT>-FIELDNAME.
      WHEN 'FIXMG' OR 'CFMPP' OR 'CFMMM' OR 'PSTAT'
              OR 'CFMNAME' OR 'PMVNAME' OR 'MEINS'.

        <FS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT .
  CASE SY-TCODE.
    WHEN SY-REPID.
      P_MODULE = 'SD'.
    WHEN 'ZGTSDR1421'.
      P_MODULE = 'PP'.
    WHEN 'ZGTSDR1422'.
      P_MODULE = 'MM'.
  ENDCASE.

  S_REQD[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 10 HIGH = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  APPEND GS_DATA TO GT_DATA.
*  CLEAR : GS_DATA. REFRESH GT_DATA.
**--------------------------------------------------------------------*
***--  초기 값 체크
**--------------------------------------------------------------------*
*  PERFORM GET_CHECK_DATA.
*  CHECK GV_ERROR IS INITIAL.
*
**--------------------------------------------------------------------*
**1) 판매오더번호와 요청구분, 정정사유, 세부원인을 입력하고 실행하면
**    판매처 정보와 품목의 Data 를 조회 해 준다.
**      VBAK + VBAP + VBEP
**--------------------------------------------------------------------*
*
  SELECT FROM VBAK AS A INNER JOIN VBAP AS B
                       ON A~VBELN EQ B~VBELN
                        INNER JOIN VBEP AS C
                       ON A~VBELN EQ C~VBELN
                      AND B~POSNR EQ C~POSNR
                      AND C~ETENR EQ '0001'
                        INNER JOIN KNA1 AS D
                        ON A~KUNNR EQ D~KUNNR
         FIELDS A~VBELN,
                B~POSNR, B~ARKTX, B~MATNR,
                C~ETENR, C~WMENG AS KWMENG, C~VRKME AS MEINS, C~EDATU,
                B~FIXMG, C~LIFSP,
                C~BANFN, C~BNFPO,
                D~KUNNR, D~NAME1,
                CASE  WHEN ( B~FIXMG = 'X'  ) THEN 'SM'
                      ELSE 'OM' END AS SM_OM
        WHERE A~VBELN IN @S_VBELN
          AND A~VKORG IN @S_VKORG
          AND A~SPART IN @S_SPART
          AND A~KUNNR IN @S_KUNNR
          AND A~VTWEG IN @S_VTWEG
          INTO TABLE @DATA(LT_DATA).


  IF LT_DATA[] IS INITIAL.
    MESSAGE S010 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "SM LINK 체크
  SELECT FROM @LT_DATA AS Z INNER JOIN ZGTPPT3360 AS A
                            ON Z~VBELN EQ A~VBELN
                           AND Z~POSNR EQ A~POSNR
    FIELDS Z~VBELN, Z~POSNR, A~UPDRQ, A~WERKS,
           CASE WHEN A~UPDRQ <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_SM
      INTO TABLE @DATA(LT_3360).

  "생산오더 체크
  SELECT FROM @LT_DATA AS Z INNER JOIN AFPO AS A
                            ON Z~VBELN EQ A~KDAUF
                           AND Z~POSNR EQ A~KDPOS
         FIELDS Z~VBELN, Z~POSNR, A~AUFNR, A~POSNR AS CO_POSNR,
                CASE WHEN A~AUFNR <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_AU
      INTO TABLE @DATA(LT_AFPO).

  "구매오더 체크
  DATA(LT_DATA2) = LT_DATA[].
  SORT LT_DATA2 BY VBELN POSNR BANFN BNFPO.
  DELETE LT_DATA2 WHERE BANFN EQ SPACE.

  IF LT_DATA2[] IS NOT INITIAL.
    SELECT FROM @LT_DATA2 AS Z  INNER JOIN EKPO AS A
                              ON Z~BANFN EQ A~BANFN
                             AND Z~BNFPO EQ A~BNFPO
           FIELDS Z~VBELN, Z~POSNR, A~EBELN, A~EBELP,
                  CASE WHEN A~EBELN <> @SPACE THEN '@5B@' ELSE ' ' END AS STATUS_PO
         INTO TABLE @DATA(LT_EKPO).
  ENDIF.

  "ZGTSDT1410 테이블 조인
  SELECT FROM @LT_DATA AS Z INNER JOIN ZGTSDT1410 AS A
                            ON Z~VBELN EQ A~VBELN
                           AND Z~POSNR EQ A~POSNR
                            LEFT OUTER JOIN USR21 AS B
                            ON A~CFMNAME EQ B~BNAME
                            LEFT OUTER JOIN ADRP AS C
                            ON B~PERSNUMBER EQ C~PERSNUMBER
                            LEFT OUTER JOIN USR21 AS B2
                            ON A~PMVNAME EQ B2~BNAME
                            LEFT OUTER JOIN ADRP AS C2
                            ON B2~PERSNUMBER EQ C2~PERSNUMBER

    FIELDS Z~VBELN, Z~POSNR,
           A~REQNO, A~REQTYPE, A~REASON, A~READTL,
           A~KWMENG_N, A~EDATU_N, A~CFMPP, A~CFMMM, A~PSTAT, A~REASONX,
           C~NAME_TEXT AS CFMNAME_T,
           C2~NAME_TEXT AS PMVNAME_T
      INTO TABLE @DATA(LT_1410).

  "자재특성(스펙) 확인
  DATA(LT_DATA3) = LT_DATA[].
  SORT LT_DATA3 BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_DATA3 COMPARING MATNR.
  SELECT FROM @LT_DATA3 AS Z INNER JOIN AUSP AS A
                        ON Z~MATNR EQ A~OBJEK
         FIELDS Z~MATNR, A~ATWRT
    WHERE A~ATINN EQ '0000000805' "'PD_CA_SPEC_NO'
    INTO TABLE @DATA(LT_AUSP).

  "입고 수량 확인
*  SELECT FROM @LT_DATA AS Z INNER JOIN MATDOC AS A
*                        ON A~EBELN EQ
*         FIELDS


  SORT LT_DATA BY VBELN POSNR.
  SORT LT_3360 BY VBELN POSNR.
  SORT LT_AFPO BY VBELN POSNR.
  SORT LT_EKPO BY VBELN POSNR.
  SORT LT_1410 BY VBELN POSNR.
  SORT LT_AUSP BY MATNR.
**--------------------------------------------------------------------*
*  "DATA MERGE
**--------------------------------------------------------------------*
  GT_DATA = VALUE #(
      FOR LS_DATA IN LT_DATA
      LET LS_3360 = VALUE #( LT_3360[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_AFPO = VALUE #( LT_AFPO[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_EKPO = VALUE #( LT_EKPO[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_1410 = VALUE #( LT_1410[ VBELN = LS_DATA-VBELN
                                      POSNR = LS_DATA-POSNR ] OPTIONAL )
          LS_AUSP = VALUE #( LT_AUSP[ MATNR = LS_DATA-MATNR ] OPTIONAL )

      IN ( VALUE #( BASE CORRESPONDING #( LS_DATA )

          UPDRQ     = LS_3360-UPDRQ
          STATUS_SM = LS_3360-STATUS_SM

          AUFNR     = LS_AFPO-AUFNR
          AUPOS     = LS_AFPO-CO_POSNR
          STATUS_AU = LS_AFPO-STATUS_AU

          EBELN     = LS_EKPO-EBELN
          EBELP     = LS_EKPO-EBELP
          STATUS_PO = LS_EKPO-STATUS_PO

          REQNO     = LS_1410-REQNO
          REQTYPE   = LS_1410-REQTYPE
          REASON    = LS_1410-REASON
          READTL    = LS_1410-READTL
          KWMENG_N  = LS_1410-KWMENG_N
          EDATU_N   = LS_1410-EDATU_N
          CFMPP     = LS_1410-CFMPP
          CFMMM     = LS_1410-CFMMM
          PSTAT     = LS_1410-PSTAT
          REASONX   = LS_1410-REASONX
          CFMNAME_T = LS_1410-CFMNAME_T
          PMVNAME_T = LS_1410-PMVNAME_T

          ATWRT     = LS_AUSP-ATWRT

          STATUS_PP = COND #( WHEN LS_1410-CFMPP = 'A' THEN ICON_LED_YELLOW
                              WHEN LS_1410-CFMPP = 'C' THEN ICON_LED_GREEN
                              WHEN LS_1410-CFMPP = 'P' THEN ICON_MOVE
                              WHEN LS_1410-CFMPP = 'X' THEN ICON_CANCEL
                              WHEN LS_1410-CFMPP = 'Y' THEN ICON_LED_INACTIVE
                              ELSE SPACE )
          STATUS_MM = COND #( WHEN LS_1410-CFMPP = 'A' THEN ICON_LED_YELLOW
                              WHEN LS_1410-CFMPP = 'C' THEN ICON_LED_GREEN
                              WHEN LS_1410-CFMPP = 'X' THEN ICON_CANCEL
                              WHEN LS_1410-CFMPP = 'Y' THEN ICON_LED_INACTIVE
                              ELSE SPACE )

          STATUS_ST = COND #( WHEN LS_1410-PSTAT = 'A' THEN ICON_LED_INACTIVE
                              WHEN ( LS_1410-CFMMM EQ 'C' OR LS_1410-CFMMM EQ 'Y' )
                                OR ( LS_1410-CFMPP EQ 'C' OR LS_1410-CFMPP EQ 'Y' )
                                                       THEN ICON_LED_YELLOW
                              WHEN LS_1410-PSTAT = 'C' THEN ICON_LED_GREEN
                              WHEN LS_1410-PSTAT = 'E' THEN ICON_LED_RED
                              WHEN LS_1410-PSTAT = 'X' THEN ICON_CANCEL
                              ELSE SPACE )
                              )

        )
      ) .


  SORT GT_DATA BY VBELN POSNR .
**--------------------------------------------------------------------*

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .
*  LOOP AT SCREEN.
*    CASE SCREEN-GROUP1.
*      WHEN 'KN'.    "판매처 INPUT 제외
*        SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*    ENDCASE.
*    CASE SCREEN-NAME.
*      WHEN 'P_VBELN' OR 'P_REQT' OR 'P_REASON' OR 'P_READTL'.
*        SCREEN-REQUIRED = 2.
*        MODIFY SCREEN.
*    ENDCASE.
*
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_VARI
*&---------------------------------------------------------------------*
FORM F4_VARI  CHANGING P_VARI.
  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.
*  LS_VARIANT-HANDLE = '1'.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2
      OTHERS        = 3.

  IF SY-SUBRC = 0.
    P_VARI = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.
