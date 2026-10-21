*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT .

  GO_CONT = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID = NEW #( I_PARENT = GO_CONT ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL .

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO .

  CLEAR:
    GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_A.
  GS_LAYO-ZEBRA      = ABAP_TRUE.
  GS_LAYO-CWIDTH_OPT  = GC_A.
  GS_LAYO-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO-NO_ROWINS = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI .

  CLEAR:
    GS_VARI.

  GS_VARI = VALUE DISVARIANT( REPORT  = SY-REPID
                                                 HANDLE  =  '0001' ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      <-- PT_FCAT
*&---------------------------------------------------------------------*
FORM F_CREATE_FCAT_BY_ITAB  USING    PT_ITAB TYPE ANY TABLE
                            CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA :
    LO_TABDESCR  TYPE REF TO CL_ABAP_TABLEDESCR,
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES     TYPE DDFIELDS.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR ) .

  PT_FCAT[] = CORRESPONDING #( LT_DFIES MAPPING
                                   KEY = KEYFLAG
                                   COLTEXT   = FIELDTEXT
                            EXCEPT ROLLNAME ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_COLTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H01
*&      <-- <LS_FCAT>
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_COLTXT  USING  PV_TEXT
                        CHANGING CS_FCAT TYPE LVC_S_FCAT.

  CS_FCAT-SCRTEXT_S  =
  CS_FCAT-SCRTEXT_M  =
  CS_FCAT-SCRTEXT_L  =
  CS_FCAT-COLTEXT    =
  CS_FCAT-SELTEXT    =
  CS_FCAT-TOOLTIP    =
  CS_FCAT-REPTEXT    = PV_TEXT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT .

  CLEAR : GT_FCAT.

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT.
  PERFORM F_ADJ_FCAT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT .

  CHECK GT_FCAT[] IS NOT INITIAL.

  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H67 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-ICON = ABAP_TRUE.

      WHEN 'SPMON'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."

      WHEN 'BUKRS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."

      WHEN 'LIFNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."

      WHEN 'LIFNR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."

      WHEN 'EKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."

      WHEN 'EBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'EBELP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'VBELN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.

      WHEN 'POSNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."

      WHEN 'VKBUR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H76 CHANGING <LS_FCAT>."
      WHEN 'VKBUR_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H77 CHANGING <LS_FCAT>."

      WHEN 'VKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H78 CHANGING <LS_FCAT>."
      WHEN 'VKGRP_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H79 CHANGING <LS_FCAT>."

      WHEN 'EKGRP'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."

      WHEN 'MATNR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."

      WHEN 'MAKTX'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."

      WHEN 'PRODNAME'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."

      WHEN 'SPECNO'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."

      WHEN 'COLOR'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."

      WHEN 'PO_QTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
       <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'PO_MEINS'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."

      WHEN 'LENGTH'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."

      WHEN 'DRQTY'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.

      WHEN 'MATGR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MATGR_UNIT'.
        <LS_FCAT>-EMPHASIZE = 'C700'.

      WHEN 'MATGR_DR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."

      WHEN 'MATGR_UNIT'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."

      WHEN 'KBETR'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.

      WHEN 'KONWA'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."

      WHEN 'KPEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
       <LS_FCAT>-CFIELDNAME = 'KMEIN'.
      WHEN 'KMEIN'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."

      WHEN 'TOTALPRICE'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C400'.

      WHEN 'TAXVALUE'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H75 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'KONWA'.
        <LS_FCAT>-EMPHASIZE = 'C700'.

      WHEN 'EXRATE_TTS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H68 CHANGING <LS_FCAT>."
      WHEN 'CU_CASH'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H69 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'CU_WAERS'.
      WHEN 'CU_WAERS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'CU_LMC'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H70 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'CU_KWAERS'.
      WHEN 'CU_KWAERS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."

      WHEN 'AL_CASH'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H73 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'AL_WAERS'.
      WHEN 'AL_WAERS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
      WHEN 'AL_LMC'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H74 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'AL_KWAERS'.
      WHEN 'AL_KWAERS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."


      WHEN 'NES_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
      WHEN 'VGW_CU'. ""CU
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_CU'.
      WHEN 'BME_CU'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
      WHEN 'VGE_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_CU'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_CU'.

      WHEN 'NES_AL'. ""AL
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
      WHEN 'VGW_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_AL'.
      WHEN 'BME_AL'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
      WHEN 'VGE_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_AL'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_AL'.

      WHEN 'NES_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
      WHEN 'VGW_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BME_FI'.
      WHEN 'BME_FI'. "
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>."
      WHEN 'VGE_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>."
      WHEN 'MEINS_B_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'VGW_T_FI'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS_B_FI'.

      WHEN 'MWSKZ_S'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H71 CHANGING <LS_FCAT>."
      WHEN 'MWSKZ_S_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
      WHEN 'MWSKZ_P'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H72 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EKPO'.
        <LS_FCAT>-REF_FIELD = 'MWSKZ'.
      WHEN 'MWSKZ_P_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT .

  GO_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT GCL_EVENT.
  SET HANDLER :
    GCL_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID,
    GCL_EVENT->HANDLE_TOOLBAR FOR GO_GRID,
    GCL_EVENT->HANDLE_DATA_CHANGED FOR GO_GRID,
    GCL_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR GO_GRID,
    GCL_EVENT->HANDLE_ON_F4   FOR GO_GRID,
    GCL_EVENT->HANDLE_USER_COMMAND  FOR GO_GRID.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
**&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV TABLES PT_LIST PT_FCAT
                                  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

*F4 대상 필드 등록
  DATA: LT_F4 TYPE LVC_T_F4.
  LT_F4 = VALUE #( ( FIELDNAME = 'MWSKZ' REGISTER   = 'X' ) ).

  CALL METHOD PO_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.


  CALL METHOD PO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
      IS_VARIANT           = GS_VARI
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[]
*      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_HD
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM TOOLBAR  USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PO_SENDER.

    WHEN GO_GRID.
        _SET_TBAR 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
        _SET_TBAR 0 'CHANGE'  '' 'TAX 변환'(B01).
        _SET_TBAR 0 'SAVE' '' 'TAX 저장'(B02).
        _SET_TBAR 0 'DELETE' '' 'TAX 삭제'(B03).
        _SET_TBAR 0 'BILL' '' '정산서'(B04).

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& FORM USER_COMMAND
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

  CASE PV_UCOMM.

    WHEN 'CHANGE'. " 'TAX 변환
      PERFORM SET_CHANGE_TAX.

    WHEN 'SAVE' . "'TAX 저장
      PERFORM SET_SAVE_TAX.

    WHEN 'DELETE'. "'TAX 삭제
      PERFORM SET_DEL_TAX.

    WHEN 'BILL'. "'정산서'
*      PERFORM SET_BILLING.
      PERFORM SET_BILLING_NEW.

    WHEN OTHERS.
  ENDCASE.

  PERFORM F_REFRESH_ALV USING GO_GRID.

*상단 스크린 필드 업데이트_강제 PBO 실행
  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& FORM DATA_CHANGED
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                               PO_ONF4_AFTER
                                                PO_SENDER.

  CASE PO_SENDER.

    WHEN GO_GRID.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

  PERFORM F_REFRESH_ALV USING GO_GRID.

*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.

ENDFORM.
*
**&---------------------------------------------------------------------*
**&      FORM  DATA_CHANGED_1
**&---------------------------------------------------------------------*
**       TEXT
**----------------------------------------------------------------------*
**      -->P_PO_DATA_CHANGED  TEXT
**----------------------------------------------------------------------*
FORM DATA_CHANGED_1 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
  CLEAR : GV_ERR.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'MWSKZ_P'. "환율
        PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MWSKZ_P'
                                              LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
        SELECT SINGLE TEXT1
          FROM T007S
          WHERE KALSM = 'TAXKR'
              AND SPRAS = @SY-LANGU
              AND MWSKZ = @LS_MOD_CELLS-VALUE
          INTO @DATA(LV_TEXT).

          IF SY-SUBRC = 0 OR LV_TEXT IS NOT INITIAL.
             LS_LIST-MWSKZ_P_N = LV_TEXT.
             LS_LIST-STATUS = ICON_CHANGE.
          ENDIF.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
    CLEAR LS_LIST.
  ENDLOOP.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

ENDFORM. " DATA_CHANGED_1

*&---------------------------------------------------------------------*
*& FORM MODIFY_CELL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_FVAL
                                           PV_INDEX.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_ENTRY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_ENTRY     USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_INDEX.

  CALL METHOD PR_CHNG->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = 'ZGTMM01'
      I_MSGNO     = '013'
      I_MSGV1     = PV_FNAME
      I_MSGTY     = ZGTFI_E
      I_FIELDNAME = PV_FNAME
      I_ROW_ID    = PV_INDEX.

ENDFORM.
*
*&---------------------------------------------------------------------*
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PS_ROW_NO TYPE LVC_S_ROW
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CASE PO_SENDER.
    WHEN GO_GRID.

        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'VBELN'.
          CHECK LS_LIST-VBELN IS NOT INITIAL.

          SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        ELSEIF PS_COLUMN-FIELDNAME = 'EBELN'.
          CHECK LS_LIST-EBELN IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ELSE.
          EXIT.
        ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LV_MSG TYPE BAPI_MSG.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.
    MESSAGE S000 WITH TEXT-M07 DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
**&---------------------------------------------------------------------*
**&      FORM  ON_F4
**&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
         LS_RETURN TYPE DDSHRETVAL,
         LS_MODI   TYPE LVC_S_MODI.
  DATA : LV_MWSKZ TYPE MWSKZ.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
  ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

  CLEAR : LS_RETURN, LT_RETURN.

  IF E_FIELDNAME = 'MWSKZ'.
*"데이터 추출 (KALSM = 'TAXKR' 필터 및 텍스트 조인)
    SELECT A~KALSM, A~MWSKZ, S~TEXT1
      FROM T007A AS A
      LEFT JOIN T007S AS S ON A~KALSM  = S~KALSM
                                      AND A~MWSKZ = S~MWSKZ
                                      AND S~SPRAS  = @SY-LANGU
      WHERE A~KALSM = 'TAXKR'
      INTO TABLE @DATA(LT_TEMP).

*F4 HELP 호출
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'MWSKZ'         " 내부 테이블에서 가져올 필드명
        WINDOW_TITLE    = '세금 코드 선택'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_TEMP       " 데이터가 담긴 ITAB
        RETURN_TAB      = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

      CLEAR : LS_MODI.
      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME =  'MWSKZ_P' .
      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
      APPEND LS_MODI TO <F4TAB>.
    ENDIF.

  ENDIF.

  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F41
