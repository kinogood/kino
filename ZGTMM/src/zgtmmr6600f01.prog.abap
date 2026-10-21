*&---------------------------------------------------------------------*
*& Include          ZGTMMR6600F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT.

  P_EKORG = GC_1100.
  P_WERKS = GC_1306.

  CLEAR : S_ERDAT[].
  S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  CHECK P_WERKS IS NOT INITIAL.

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GT_LIST[], GV_CNT.

  SELECT @ICON_LED_YELLOW AS STATUS,
         R~EKORG,
         R~WERKS,
         R~JOB_NO,
         K~LIFNR,
         L~NAME1,
         R~EBELN,
         R~EBELP,
         CASE WHEN P~LOEKZ = @GC_L THEN @ICON_DELETE END AS LOEKZ,
         R~MATNR,
         P~TXZ01,
         S~EINDT,
         P~NETWR,
         K~WAERS,
         P~MENGE,
         P~MEINS,
         S~WEMNG,       "추가(PSJ 25.05.08)
         R~ERNAM,
         R~ERDAT_LOCAL,
         R~ERTIM_LOCAL,
         R~BANFN,
         R~BNFPO,
         R~AENAM,
         R~AEDAT_LOCAL,
         R~AETIM_LOCAL,
         R~JOBLS,
         R~CLCRS,
         ROW_NUMBER( ) OVER( ORDER BY JOB_NO, JOBLS ) AS IDX,
         CASE WHEN P~LOEKZ = @GC_L THEN @GC_C600 END AS R_COL
    FROM ZGTMMT6600 AS R JOIN EKKO AS K
      ON R~EBELN = K~EBELN
    JOIN EKPO AS P
      ON R~EBELN = P~EBELN
     AND R~EBELP = P~EBELP
    JOIN EKET AS S
      ON R~EBELN = S~EBELN
     AND R~EBELP = S~EBELP
     AND S~ETENR = @GC_0001
    LEFT JOIN LFA1 AS L
      ON K~LIFNR = L~LIFNR
     AND L~LOEVM = @SPACE
     AND L~SPRAS = @SY-LANGU
   WHERE R~EKORG        = @P_EKORG
     AND R~WERKS        = @P_WERKS
     AND R~JOB_NO      IN @S_JOBNO
     AND R~EBELN       IN @S_EBELN
     AND R~MATNR       IN @S_MATNR
     AND R~ERDAT_LOCAL IN @S_ERDAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_LIST BY JOB_NO LIFNR EBELN EBELP.

  PERFORM SET_EKES.

  GV_CNT = LINES( GT_LIST ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EKES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EKES.

  RANGES : LR_EBELN FOR EKES-EBELN.


  "Inb수량 정보 추가 구성(PSJ 25.05.08)

  CLEAR : GT_EKES[].
  CHECK GT_LIST[] IS NOT INITIAL.

  LR_EBELN[] = VALUE #( FOR LS_LIST IN GT_LIST
                        ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_LIST-EBELN ) ) ).

  SORT LR_EBELN BY LOW.
  DELETE ADJACENT DUPLICATES FROM LR_EBELN COMPARING LOW.

  SELECT EBELN EBELP SUM( MENGE ) AS MENGE
    FROM EKES
    INTO CORRESPONDING FIELDS OF TABLE GT_EKES
   WHERE EBELN IN LR_EBELN
     AND EBTYP  = GC_LA
     AND LOEKZ  = SPACE
   GROUP BY EBELN EBELP.

  CHECK GT_EKES[] IS NOT INITIAL.
  SORT GT_EKES BY EBELN EBELP.

  DATA(LT_LIST) = GT_LIST[].

  GT_LIST[] = VALUE #( FOR LS_LIST IN LT_LIST INDEX INTO LV_IDX
                       ( VALUE #( BASE CORRESPONDING #( LS_LIST )
                                  IDX   = LV_IDX
                                  IBQTY = VALUE #( GT_EKES[ EBELN = LS_LIST-EBELN
                                                            EBELP = LS_LIST-EBELP ]-MENGE OPTIONAL ) ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_GRID = NEW #( I_PARENT      = GR_DOCK
                   I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYO.

  CLEAR : GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_D.
  GS_LAYO-CWIDTH_OPT = GC_A.
  GS_LAYO-ZEBRA      = GC_X.
  GS_LAYO-INFO_FNAME = GC_R_COL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], GT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_LIST'
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = GT_FCAT[]
    TABLES
      IT_DATA         = GT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    PERFORM SET_LIST_FCAT.
    MODIFY GT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FTXT USING PV_TEXT.

  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Msg'(F01).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F02).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F03).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-JUST    = GC_C.
    WHEN 'JOB_NO'.
      PERFORM SET_FTXT USING '제조지시번호'(F04).
      GS_FCAT-KEY     = GC_X.
    WHEN 'LIFNR'.
      PERFORM SET_FTXT USING '공급업체'(F05).
      GS_FCAT-KEY     = GC_X.
    WHEN 'NAME1'.
      PERFORM SET_FTXT USING '공급업체명'(F06).
      GS_FCAT-KEY     = GC_X.
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더번호'(F07).
      GS_FCAT-KEY     = GC_X.
      GS_FCAT-HOTSPOT = GC_X.
    WHEN 'EBELP'.
      PERFORM SET_FTXT USING '품목'(F08).
      GS_FCAT-KEY     = GC_X.

    WHEN 'LOEKZ'.
      PERFORM SET_FTXT USING 'Del'(F09).
      GS_FCAT-JUST    = GC_C.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재코드'(F10).
    WHEN 'TXZ01'.
      PERFORM SET_FTXT USING '자재내역'(F11).
    WHEN 'EINDT'.
      PERFORM SET_FTXT USING '납품일'(F12).
    WHEN 'NETWR'.
      PERFORM SET_FTXT USING '금액'(F13).
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F14).
    WHEN 'MENGE'.
      PERFORM SET_FTXT USING 'PO 수량'(F15).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING 'OUn'(F16).
    WHEN 'IBQTY'.  "추가(PSJ 25.05.08)
      PERFORM SET_FTXT USING 'Inb수량'(F17).
    WHEN 'WEMNG'.  "추가(PSJ 25.05.08)
      PERFORM SET_FTXT USING '입고수량'(F18).
    WHEN 'ERNAM'.
      PERFORM SET_FTXT USING '삭제 요청자'(F19).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '삭제 요청일'(F20).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'ERTIM_LOCAL'.
      PERFORM SET_FTXT USING '삭제 요청시간'(F21).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'BANFN'.
      PERFORM SET_FTXT USING '구매요청번호'(F22).
      GS_FCAT-EMPHASIZE = GC_C500.
      GS_FCAT-HOTSPOT   = GC_X.
    WHEN 'BNFPO'.
      PERFORM SET_FTXT USING '품목'(F08).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'AENAM'.
      PERFORM SET_FTXT USING '삭제 처리자'(F23).
    WHEN 'AEDAT_LOCAL'.
      PERFORM SET_FTXT USING '삭제 처리일'(F24).
    WHEN 'AETIM_LOCAL'.
      PERFORM SET_FTXT USING '삭제 처리시간'(F25).
    WHEN 'JOBLS'.
      PERFORM SET_FTXT USING '제조지시 요청번호'(F26).
    WHEN 'CLCRS'.
      PERFORM SET_FTXT USING '삭제요청 사유'(F27).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVNT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK  FOR GR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR GR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP.

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD GR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = GS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[].
*     IT_SORT              = GT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_GRID.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD GR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

  CALL METHOD GR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GR_GRID->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_GRID, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFR_DATA.

  PERFORM GET_DATA.
  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form XDEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM XDEL_DATA USING PV_TYPE.

  PERFORM CHECK_XDEL USING PV_TYPE.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01) GV_PMSG.
  CHECK GV_ANS = GC_1.

  SORT GT_XPO BY EBELN EBELP.

  LOOP AT GT_XPO.
    MOVE-CORRESPONDING GT_XPO TO GS_XPO.

    AT NEW EBELN.
      CLEAR : GT_ITM[], GT_ITMX[], GT_RTN[].
    ENDAT.

    PERFORM SET_ITM USING PV_TYPE.

    AT END OF EBELN.
      PERFORM BAPI_PO_CHANGE USING PV_TYPE.
    ENDAT.
  ENDLOOP.

  "ALV List 결과 반영
  LOOP AT GT_XPO.
    READ TABLE GT_LIST WITH KEY IDX = GT_XPO-IDX.
    CHECK SY-SUBRC = 0.
    DATA(LV_TBX) = SY-TABIX.

    MOVE-CORRESPONDING GT_XPO TO GT_LIST.

    GT_LIST-R_COL = SWITCH #( GT_XPO-LOEKZ WHEN ICON_DELETE THEN GC_C600
                                                            ELSE SPACE ).

    MODIFY GT_LIST INDEX LV_TBX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_XDEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM CHECK_XDEL USING PV_TYPE.

  CLEAR : GT_XPO[].

  PERFORM SET_XMSG USING PV_TYPE.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X' GV_EMSG.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_LIST INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF ( PV_TYPE = GC_P AND GT_LIST-LOEKZ = ICON_DELETE )
    OR ( PV_TYPE = GC_C AND GT_LIST-LOEKZ = SPACE ).
      MESSAGE S000 WITH GV_EMSG DISPLAY LIKE 'E'.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF PV_TYPE = GC_P AND GT_LIST-IBQTY IS NOT INITIAL. "추가(PSJ 25.05.08)
      MESSAGE S148 DISPLAY LIKE 'E'. "납품서 수량이 있는 구매오더는 삭제할 수 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    MOVE-CORRESPONDING GT_LIST TO GT_XPO.
    APPEND GT_XPO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XMSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM SET_XMSG USING PV_TYPE.

  DATA : LV_TXT(5).


  CLEAR : GV_EMSG, GV_PMSG.

  LV_TXT = COND #( WHEN PV_TYPE = GC_P THEN '삭제'(M01)
                   WHEN PV_TYPE = GC_C THEN '삭제 취소'(M02) ).

  MESSAGE S146(ZGTMM01) WITH LV_TXT INTO GV_EMSG. "& 할 레코드를 선택하세요.
  MESSAGE S147(ZGTMM01) WITH LV_TXT INTO GV_PMSG. "선택한 레코드의 구매오더를 & 하시겠습니까?

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&      --> P_
*&      --> GV_EMSG
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        IF PV_MSG IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ELSE.
          MESSAGE S004 DISPLAY LIKE 'E'. "라인을 선택하세요.
        ENDIF.
      ENDIF.
    WHEN 1.
      IF PV_MODE = GC_S.
        READ TABLE GT_ROW INTO GS_ROW INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GV_PMSG
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM USING PV_TITLE
                            PV_QTEXT.

  CLEAR : GV_ANS. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      TITLEBAR      = PV_TITLE
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION = PV_QTEXT
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER        = GV_ANS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM SET_ITM USING PV_TYPE.

  CLEAR : GT_ITM, GT_ITMX.

  GT_ITM-PO_ITEM     = GS_XPO-EBELP. "PO항번
  GT_ITM-DELETE_IND  = COND #( WHEN PV_TYPE = GC_P THEN GC_L
                               WHEN PV_TYPE = GC_C THEN SPACE ).

  GT_ITMX-PO_ITEM    = GS_XPO-EBELP. "PO항번
  GT_ITMX-PO_ITEMX   = GC_X.
  GT_ITMX-DELETE_IND = GC_X.

  APPEND : GT_ITM, GT_ITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PO_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&---------------------------------------------------------------------*
FORM BAPI_PO_CHANGE USING PV_TYPE.

  CLEAR : GS_XPO-MSG[], GS_CHNG.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GS_XPO-EBELN
    TABLES
      RETURN        = GT_RTN
      POITEM        = GT_ITM
      POITEMX       = GT_ITMX.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0.
    PERFORM BAPI_COMMIT.

    PERFORM SET_TSTMP USING GS_CHNG.

    GS_XPO-STATUS = ICON_LED_GREEN.
    GS_XPO-LOEKZ  = COND #( WHEN PV_TYPE = GC_P THEN ICON_DELETE
                            WHEN PV_TYPE = GC_C THEN SPACE ).
    MOVE-CORRESPONDING GS_CHNG TO GS_XPO.
  ELSE.
    PERFORM BAPI_ROLLBACK.

    ASSIGN COMPONENT 'MSG' OF STRUCTURE GS_XPO TO <GFS_MSG>.

    PERFORM SET_ERR_MSG USING GS_XPO-STATUS.
  ENDIF.

  LOOP AT GT_ITMX.
    PERFORM UPDATE_6600.

    MODIFY GT_XPO FROM GS_XPO
          TRANSPORTING STATUS LOEKZ MSG   AENAM
                       AEDAT_LOCAL  AETIM_LOCAL
                 WHERE EBELN = GS_XPO-EBELN
                   AND EBELP = GT_ITMX-PO_ITEM.
  ENDLOOP.

  GV_REF = GC_X.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CHNG
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_XPO_STATUS
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_STATUS.

  PV_STATUS = ICON_LED_RED.

  LOOP AT GT_RTN.
    CHECK GT_RTN-TYPE = GC_E OR GT_RTN-TYPE = GC_A.

    PERFORM SET_POP_MSG USING GT_RTN-TYPE
                              GT_RTN-ID
                              GT_RTN-NUMBER
                              GT_RTN-MESSAGE_V1
                              GT_RTN-MESSAGE_V2
                              GT_RTN-MESSAGE_V3
                              GT_RTN-MESSAGE_V4.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_RTN_TYPE
*&      --> GT_RTN_ID
*&      --> GT_RTN_NUMBER
*&      --> GT_RTN_MESSAGE_V1
*&      --> GT_RTN_MESSAGE_V2
*&      --> GT_RTN_MESSAGE_V3
*&      --> GT_RTN_MESSAGE_V4
*&---------------------------------------------------------------------*
FORM SET_POP_MSG USING PV_MSGTY
                       PV_MSGID
                       PV_MSGNO
                       PV_MSGV1
                       PV_MSGV2
                       PV_MSGV3
                       PV_MSGV4.

  APPEND VALUE #( MSGTY = PV_MSGTY
                  MSGID = PV_MSGID
                  MSGNO = PV_MSGNO
                  MSGV1 = PV_MSGV1
                  MSGV2 = PV_MSGV2
                  MSGV3 = PV_MSGV3
                  MSGV4 = PV_MSGV4 ) TO <GFS_MSG>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_6600
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_6600.

  "성공시 Table ZGTMMT6600 Update

  CHECK GS_CHNG IS NOT INITIAL.

  UPDATE ZGTMMT6600 SET AEDAT       = GS_CHNG-AEDAT
                        AEDAT_LOCAL = GS_CHNG-AEDAT_LOCAL
                        AETIM       = GS_CHNG-AETIM
                        AETIM_LOCAL = GS_CHNG-AETIM_LOCAL
                        AENAM       = GS_CHNG-AENAM
                  WHERE EBELN = GS_XPO-EBELN
                    AND EBELP = GT_ITMX-PO_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PS_ROW  TYPE LVC_S_ROW
                               PS_COL  TYPE LVC_S_COL
                               PS_ROID TYPE LVC_S_ROID
                               PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      CHECK PS_COL-FIELDNAME = GC_STATUS.

      READ TABLE GT_LIST INDEX PS_ROW-INDEX.
      CHECK SY-SUBRC = 0.

      ASSIGN COMPONENT 'MSG' OF STRUCTURE GT_LIST TO <GFS_MSG>.
      PERFORM DISPLAY_MSG.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MSG.

  DATA : LS_LOG TYPE BAL_S_LOG,
         LS_MSG TYPE BAL_S_MSG,
         LS_PRF TYPE BAL_S_PROF.


  IF <GFS_MSG> IS INITIAL.
    EXIT.
  ENDIF.

  IF GS_HND IS NOT INITIAL.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        I_LOG_HANDLE = GS_HND
      EXCEPTIONS
        OTHERS       = 1.

    CLEAR : GS_HND.
  ENDIF.

  "Create an initial log file
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      I_S_LOG      = LS_LOG
    IMPORTING
      E_LOG_HANDLE = GS_HND
    EXCEPTIONS
      OTHERS       = 1.

  LOOP AT <GFS_MSG> INTO LS_MSG.
    "Add message to log file
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        I_LOG_HANDLE = GS_HND
        I_S_MSG      = LS_MSG
      EXCEPTIONS
        OTHERS       = 1.
  ENDLOOP.

  "Get a prepared profile
  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      E_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

  LS_PRF-USE_GRID          = GC_X.
  LS_PRF-DISVARIANT-REPORT = SY-REPID.
  LS_PRF-DISVARIANT-HANDLE = 'LOG'.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      I_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_ROW  TYPE LVC_S_ROW
                                PS_COL  TYPE LVC_S_COL
                                PS_ROID TYPE LVC_S_ROID
                                PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_GRID'.
      READ TABLE GT_LIST INDEX PS_ROW-INDEX.
      CHECK SY-SUBRC = 0.

      CASE PS_COL-FIELDNAME.
        WHEN 'BANFN'.
          CHECK GT_LIST-BANFN IS NOT INITIAL.
          SET PARAMETER ID 'BAN' FIELD GT_LIST-BANFN.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

        WHEN 'EBELN'.
          CHECK GT_LIST-EBELN IS NOT INITIAL.
          SET PARAMETER ID 'BES' FIELD GT_LIST-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
