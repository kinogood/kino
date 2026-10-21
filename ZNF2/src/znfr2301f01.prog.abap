*&---------------------------------------------------------------------*
*&  Include           ZNFR2101F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  FILE_F4_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FNAME  text
*----------------------------------------------------------------------*
FORM READ_FILENAME USING P_FNAME.

  DATA:
    LD_DEF_PATH     TYPE STRING,
    LD_RC           TYPE I VALUE 1,
    LD_MASK         TYPE STRING VALUE
                      'All(*.*)|*.*|Excel-Sheet(*.xls)|*.xls|Excel-Sheet(*.xlsx)|*.xlsx|',
    LD_WINDOW_TITLE TYPE STRING,
    LT_FILES        TYPE FILETABLE,
    FILENAME        TYPE STRING.

  IF LD_DEF_PATH IS INITIAL.
    LD_DEF_PATH = 'C:\SAPworkdir\'.
  ENDIF.

* returns default path for up- and download
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_GET_CURRENT
    CHANGING
      CURRENT_DIRECTORY = LD_DEF_PATH.

* calls selection-popup -> returns upload-path + filename
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = LD_WINDOW_TITLE
      DEFAULT_FILENAME  = SPACE
      FILE_FILTER       = LD_MASK
      INITIAL_DIRECTORY = LD_DEF_PATH
    CHANGING
      FILE_TABLE        = LT_FILES
      RC                = LD_RC.

  READ TABLE LT_FILES INTO FILENAME INDEX 1.

  P_FNAME = FILENAME.

ENDFORM.                    " READ_FILENAME

*&---------------------------------------------------------------------*
*&      Form  GET_UPLOAD_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PA_FNAME  text
*----------------------------------------------------------------------*
FORM GET_UPLOAD_FILENAME  CHANGING P_FILENAME.

  DATA: LT_FILE  TYPE FILETABLE,
        LV_RC    TYPE I,
        LV_FNAME TYPE STRING.

  CLEAR P_FILENAME.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    EXPORTING
*      DEFAULT_FILENAME  = '만기이동요청 대량생성.xls'
*      INITIAL_DIRECTORY = 'C:\SAPworkdir\'
    CHANGING
      FILE_TABLE = LT_FILE
      RC         = LV_RC
    EXCEPTIONS
      OTHERS     = 1.

  IF SY-SUBRC EQ 0.
*    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE LT_FILE INDEX 1 INTO LV_FNAME.
  IF LV_FNAME IS INITIAL.
    MESSAGE S002 WITH '작업을 취소하셨습니다.'.
  ELSE.
    MOVE LV_FNAME TO P_FILENAME.
  ENDIF.

ENDFORM.                    " GET_UPLOAD_FILENAME

*&---------------------------------------------------------------------*
*&      Form  SET_DOWNLOAD_LOCATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_SAVE_LOC  text
*----------------------------------------------------------------------*
FORM SET_DOWNLOAD_LOCATION  USING PV_SAVE_LOC.

  DATA : LV_FILENAME TYPE STRING VALUE '만기이동요청 대량생성.xls',
         LV_PATH     TYPE STRING VALUE 'C:\',
         LV_PULLPATH TYPE STRING VALUE 'C:\만기이동요청 대량생성.xls'.

  CLEAR : LV_FILENAME, LV_PATH, LV_PULLPATH.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE        = 'Excel 양식 다운로드 경로 설정'
      DEFAULT_FILE_NAME   = LV_FILENAME
      INITIAL_DIRECTORY   = LV_PATH
      PROMPT_ON_OVERWRITE = 'X'
    CHANGING
      FILENAME            = LV_FILENAME
      PATH                = LV_PATH
      FULLPATH            = LV_PULLPATH.

  GV_SAVE_LOC = LV_PULLPATH.

  IF SY-SUBRC EQ 0.
*    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " SET_DOWNLOAD_LOCATION

*&---------------------------------------------------------------------*
*&      Form  GET_DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DOWNLOAD_EXCEL USING PV_SAVE_LOC.

  DATA: LS_WWWDATATAB TYPE WWWDATATAB,
        LV_RTN_MSG    TYPE CHAR100.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF LS_WWWDATATAB
    FROM WWWDATA
   WHERE OBJID EQ 'ZNFR2301'.

  IF SY-SUBRC EQ 0.

    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LS_WWWDATATAB
        DESTINATION = PV_SAVE_LOC.

    IF SY-SUBRC EQ 0.
      CONCATENATE '[' PV_SAVE_LOC ']로 생성되었습니다.' INTO LV_RTN_MSG.
      MESSAGE LV_RTN_MSG TYPE 'S' DISPLAY LIKE 'S'.
    ENDIF.
  ELSE.
    MESSAGE '[T-CODE : SMW0]에 해당 엑셀파일이 등록되지 않았습니다.'
      TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_DOWNLOAD_EXCEL

*&---------------------------------------------------------------------*
*&      Form  INTERFACE_SETTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INTERFACE_SETTING .

* SCREEN 1000에 버튼생성
  SSCRFIELDS-FUNCTXT_01 = '@AA@ Excel 양식 다운로드'.

*  IF P_FNAME1 IS INITIAL .
*    P_FNAME1 = 'C:\선물요청 대량생성.xls'.
*  ENDIF.

* 사용자별 회사코드 조회
  DATA: LV_BUKRS LIKE ZNFT1010-BUKRS.
  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_UNAME = SY-UNAME
    IMPORTING
      E_BUKRS = LV_BUKRS.

  IF P_BUKRS IS INITIAL.
    P_BUKRS = LV_BUKRS.
  ENDIF.

ENDFORM.                    " INTERFACE_SETTING
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL_TO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PA_FNAME  text
*----------------------------------------------------------------------*
FORM UPLOAD_EXCEL_TO_ITAB.
  DATA: LT_TAB(11),
        LV_INAMT   LIKE WMTO_S-AMOUNT,
        LV_OTAMT   LIKE WMTO_S-AMOUNT.
  DATA  LV_EKORG TYPE EKORG.

  DATA: LV_EMENG LIKE ZNFT1030-EMENG,
        LV_ERROR.

  FIELD-SYMBOLS <FS_TAB> TYPE STANDARD TABLE.

  LT_TAB = 'GT_EXCEL'.

  ASSIGN  (LT_TAB)  TO  <FS_TAB>.

  CLEAR   : <FS_TAB>, GT_1020.
  REFRESH : <FS_TAB>, GT_1020.

* EXCEL UPLOAD
** Excel변환 함수 수정 #20221220
  DATA : LV_MESSAGE   TYPE  STRING.

  CALL FUNCTION 'ZCOMM_UPLOAD_EXCEL'
    EXPORTING
      I_HEADERLINE = 1
      I_FILENAME   = P_FNAME1
    IMPORTING
      E_MESSAGE    = LV_MESSAGE
    TABLES
      T_TAB        = <FS_TAB>.

  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE S001 WITH LV_MESSAGE.
  ENDIF.

*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      I_LINE_HEADER        = 'X'
*      I_TAB_RAW_DATA       = GT_RAW_DATA
*      I_FILENAME           = P_FNAME1
*    TABLES
*      I_TAB_CONVERTED_DATA = <FS_TAB>.
*
*  IF SY-SUBRC NE 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    EXIT.
*  ENDIF.
* #20221220

  IF GT_EXCEL IS INITIAL.
    MESSAGE '데이타가 존재하지 않습니다.' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

* ########### MOVE INTERNAL TABLE

* 대문자 변경
  DATA: LV_TABIX TYPE SY-TABIX,
        LV_SEQ   TYPE I,
        LV_LEN   TYPE I,
        LV_NUM_P TYPE P DECIMALS 2,
        LV_NUM   TYPE CHAR15.

  CLEAR : GS_EXCEL, GS_OUTTAB, LV_TABIX, LV_NUM, LV_NUM_P.

  SORT GT_EXCEL BY OFUTN.

  LOOP AT GT_EXCEL INTO GS_EXCEL.
*___만기이동요청 수량의 합 점검을 위해
    GT_1020-NFUTN = GS_EXCEL-OFUTN.
    GT_1020-EMENG = GS_EXCEL-RMENG.

    COLLECT GT_1020.

*___만기이동요청 만기월 점검을 위해
    GT_1020M-NFUTN = GS_EXCEL-OFUTN.
    GT_1020M-ENDMM = GS_EXCEL-REMON.
    GT_1020M-COUNT = 1.

    COLLECT GT_1020M.
  ENDLOOP.

  LV_SEQ = 0.
  LOOP AT GT_EXCEL INTO GS_EXCEL.
    LV_TABIX = SY-TABIX.

*   선물요청번호 체크 ( 선물요청번호가 10자리가 아닌경우 Clear )
    CONDENSE GS_EXCEL-OFUTN NO-GAPS.
    LV_LEN = STRLEN( GS_EXCEL-OFUTN ).
    IF LV_LEN NE 10.
      CLEAR GS_EXCEL-OFUTN.
    ENDIF.

*   요청수량이 소수점이 포함된 경우 Clear
    LV_NUM_P = GS_EXCEL-RMENG.
    LV_NUM = LV_NUM_P.
    CONDENSE LV_NUM NO-GAPS.
    IF LV_NUM CP '*.00'.
    ELSE.
      CLEAR GS_EXCEL-RMENG.
    ENDIF.

*   MODIFY GT_EXCEL FROM GS_EXCEL INDEX LV_TABIX.
    MOVE-CORRESPONDING GS_EXCEL TO GS_OUTTAB.

*   TEXT 및 DEFAULTE DATA
    ADD 1 TO LV_SEQ.

*   Excel Data
    IF GS_OUTTAB-OFUTN IS NOT INITIAL.
*___선물집행정보
      SELECT SINGLE *
        FROM ZNFT1020
       WHERE NFUTN EQ GS_OUTTAB-OFUTN.

      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING ZNFT1020 TO GS_OUTTAB.

        GS_OUTTAB-H_NO2 = ZNFT1020-H_NO1.
      ENDIF.
    ENDIF.

*   H_NO1
    GS_OUTTAB-H_NO1 = LV_SEQ.

*___계약/선물요청 정보
    SELECT SINGLE A~YNFIN
                  A~ENDMM
                  A~EMENG AS EMENG1
                  A~MEINS AS MEINS1
                  B~RQTYP
                  C~CONNO
                  C~COTXT
                  C~KUNNR
                  C~NCUST
      INTO CORRESPONDING FIELDS OF GS_OUTTAB
      FROM ZNFT1011 AS A
     INNER JOIN ZNFT1010 AS B
        ON A~REQNO = B~REQNO
     INNER JOIN ZNFT1000 AS C
        ON A~CONNO = C~CONNO
     WHERE A~REQNO = GS_OUTTAB-REQNO
       AND A~H_NO1 = GS_OUTTAB-H_NO2.

*___고객명
    IF GS_OUTTAB-KUNNR IS NOT INITIAL.
      PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                   GS_OUTTAB-NCUST.
    ENDIF.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                 GS_OUTTAB-NAME1.

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GS_OUTTAB-BY_SL
                                   GS_OUTTAB-BSTXT.

*___집행유형내역
    PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                   GS_OUTTAB-MITYP
                                   GS_OUTTAB-MITPT.

*___요청유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GS_OUTTAB-RQTYP
                                   GS_OUTTAB-RQTPT.
*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PTEXT.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB-CONNO
                                       GS_OUTTAB-NFKEY
                                       GS_OUTTAB-PRIND
                                       GS_OUTTAB-SUJUP
                                       LV_ERROR.

*___청산입력여부
    CLEAR : LV_EMENG.

    SELECT SUM( EMENG )
      INTO LV_EMENG
      FROM ZNFT1030
     WHERE BUKRS = P_BUKRS
       AND NFUTN = GS_OUTTAB-OFUTN
       AND YNCAN = ' '
       AND YNNET = ' '.

    IF LV_EMENG IS INITIAL.
      GS_OUTTAB-SETTL = '미청산'.
    ELSEIF LV_EMENG >= GS_OUTTAB-EMENG.
      GS_OUTTAB-SETTL = '청산완료'.
    ELSE.
      GS_OUTTAB-SETTL = '부분청산'.
    ENDIF.

    PERFORM CHECK_DATA USING GS_OUTTAB
                             GV_EXCEL_FLAG.

    APPEND GS_OUTTAB TO GT_OUTTAB.

    MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING ICON BIGO_CHK
                    WHERE OFUTN = GS_OUTTAB-OFUTN.

    CLEAR : GS_EXCEL, GS_OUTTAB, LV_TABIX, LV_NUM, LV_NUM_P.
  ENDLOOP.

ENDFORM.                    " UPLOAD_EXCEL_TO_ITAB

*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_OUTTAB  text
*----------------------------------------------------------------------*
FORM CHECK_DATA USING PS_OUTTAB LIKE GS_OUTTAB
                      PV_EXCEL_FLAG.
  DATA: LV_DDVALU TYPE DOMVALUE_L,
        LV_DDTEXT TYPE VAL_TEXT.

  DATA: LV_BIGO_CHECK TYPE CHAR200,
        LV_INDEX      TYPE SY-INDEX,
        LV_TABIX      TYPE SY-TABIX,
        LV_SHFNO      LIKE ZNFT1040-SHFNO.

  DATA: LV_CONNO TYPE ZCONNO,
        LV_COTYP TYPE ZCOTYP,
        LV_RQTYP TYPE ZRQTYP_1,
        LV_ENDMM TYPE SY-DATUM,
        LV_CSTAT TYPE ZCSTAT,
        LV_DEC   TYPE P DECIMALS 3,
        LV_MSG   TYPE CHAR50..

  DATA: LV_EMENG_I TYPE CHAR20,
        LV_EMENG_O TYPE CHAR20,
        LV_EMENG   TYPE P DECIMALS 0.

*___이동전 선물집행
  SELECT SINGLE *
    FROM ZNFT1020
   WHERE NFUTN = PS_OUTTAB-OFUTN.

  IF SY-SUBRC = 0.
    IF ZNFT1020-CONFM <> '3' AND ZNFT1020-CONFM <> '7'.
      CONCATENATE LV_BIGO_CHECK '선물집행번호 상태 에러'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF ZNFT1020-YNCAN = 'X'.
      CONCATENATE LV_BIGO_CHECK '취소된 선물집행번호'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF ZNFT1020-YNFIN = 'X'.
      CONCATENATE LV_BIGO_CHECK '정산된 선물집행번호'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF ZNFT1020-YNNET = 'X'.
      CONCATENATE LV_BIGO_CHECK '넷팅처리된 선물집행번호'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF ZNFT1020-ENDAT < SY-DATLO.
      CONCATENATE LV_BIGO_CHECK '선물집행번호 만기일 에러'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '이동전 선물집행번호 존재안함'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   ### 만기월 체크 ###
  LOOP AT GT_1020M WHERE NFUTN = PS_OUTTAB-OFUTN.
    IF GT_1020M-ENDMM IS NOT INITIAL.
      CLEAR: LV_ENDMM.
      CONCATENATE GT_1020M-ENDMM '01' INTO LV_ENDMM.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          DATE                      = LV_ENDMM
        EXCEPTIONS
          PLAUSIBILITY_CHECK_FAILED = 1
          OTHERS                    = 2.
      IF SY-SUBRC NE 0.
        CONCATENATE LV_BIGO_CHECK '만기월형식오류(YYYYMM)'
          INTO LV_BIGO_CHECK SEPARATED BY '/'.
      ELSE.
        IF GT_1020M-ENDMM LT SY-DATLO(6).
          CONCATENATE LV_BIGO_CHECK '과거만기월'
            INTO LV_BIGO_CHECK SEPARATED BY '/'.
        ENDIF.

        IF GT_1020M-ENDMM = PS_OUTTAB-ENDAT(6).
          CONCATENATE LV_BIGO_CHECK '선물집행만기월과 동일만기월'
            INTO LV_BIGO_CHECK SEPARATED BY '/'.
        ENDIF.
      ENDIF.
    ELSE.
      CONCATENATE LV_BIGO_CHECK '요청만기월누락'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF GT_1020M-COUNT > 1.
      CONCATENATE LV_BIGO_CHECK '동일만기월존재'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ENDLOOP.

*   ### 요청수량 체크 ###
  IF PS_OUTTAB-RMENG IS NOT INITIAL.
    CLEAR : LV_EMENG_I, LV_EMENG_O.
    LV_EMENG_I = PS_OUTTAB-RMENG.

*   입력값 유형 체크
    CALL FUNCTION 'CATS_NUMERIC_INPUT_CHECK'
      EXPORTING
        INPUT      = LV_EMENG_I
      IMPORTING
        OUTPUT     = LV_EMENG_O
      EXCEPTIONS
        NO_NUMERIC = 1
        OTHERS     = 2.

    IF SY-SUBRC EQ 0.
      LV_EMENG = LV_EMENG_O.

*   요청수량 체크 (0보다 큰값)
      IF LV_EMENG LE 0.
        CONCATENATE LV_BIGO_CHECK '요청수량오류(수량>0)'
          INTO LV_BIGO_CHECK SEPARATED BY '/'.
      ELSE.
        PS_OUTTAB-RMENG = LV_EMENG.
      ENDIF.
    ELSE.
      CONCATENATE LV_BIGO_CHECK '요청수량숫자오류'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '요청수량누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*___만기이동사유 입력여부
  IF PS_OUTTAB-BIGO3 IS INITIAL.
    CONCATENATE LV_BIGO_CHECK '만기이동사유누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*___만기이동요청된 선물집행번호 제외(저장된 후에는 점검하지 않음)
  IF GV_COMPLETE_SAVE <> 'Y'.
    SELECT SINGLE SHFNO
      INTO LV_SHFNO
      FROM ZNFT1040
     WHERE OFUTN = PS_OUTTAB-OFUTN
       AND YNCAN = ' '.

    IF SY-SUBRC = 0.
      CONCATENATE LV_BIGO_CHECK '/만기이동요청된 선물집행번호:'
                  LV_SHFNO
        INTO LV_BIGO_CHECK.
    ENDIF.
  ENDIF.

*___만기이동요청 수량 합 점검
  READ TABLE GT_1020 WITH KEY NFUTN = GS_OUTTAB-OFUTN.
  IF SY-SUBRC = 0.
    IF GT_1020-EMENG > PS_OUTTAB-EMENG.
      CONCATENATE LV_BIGO_CHECK '/만기이동요청수량 에러'
                  LV_SHFNO
        INTO LV_BIGO_CHECK.
    ENDIF.
  ENDIF.

*   BIGO_CHK 필드에 데이터 점검결과 입력
  IF LV_BIGO_CHECK+0(1) EQ '/'.
    PS_OUTTAB-BIGO_CHK = LV_BIGO_CHECK+1(199).
  ELSE.
    PS_OUTTAB-BIGO_CHK = LV_BIGO_CHECK.
  ENDIF.

*   상태값 갱신
  IF PS_OUTTAB-BIGO_CHK IS NOT INITIAL.
    PS_OUTTAB-ICON = '@5C@'.
    PV_EXCEL_FLAG = 'Y'.
  ELSE.
    PS_OUTTAB-ICON = '@5B@'.
    PV_EXCEL_FLAG = 'N'.
  ENDIF.

ENDFORM.                    " CHECK_DATA
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT .

  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT .

  CLEAR : GS_SORT, GT_SORT.
  REFRESH GT_SORT.

  GS_SORT-SPOS      = 1.
  GS_SORT-FIELDNAME = 'OFUTN'.
  GS_SORT-UP        = 'X'.
  GS_SORT-COMP      = 'X'.
  GS_SORT-SUBTOT    = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS      = 2.
  GS_SORT-FIELDNAME = 'H_NO1'.
  GS_SORT-UP        = 'X'.
  GS_SORT-COMP      = 'X'.
  GS_SORT-SUBTOT    = 'X'.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " SET_GRID_SORT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_OUTTAB'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'ICON'     ' '      ' '     'X' ' ' ' ' ' '    'X' ' ' ' ' 4
      '상태'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'BUKRS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'OFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '선물집행번호' 'NFUTN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    'X' ' ' ' ' 5
      ' '            'H_NO1'  'ZNFT1041'  ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO_CHK' ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 200
      'Excel Error Log' ' '   ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'BIGO3'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '요청사유'     'BIGO4'  'ZNFT1040'  ' ' ' '    'X' ' ' ' ' 'X',

      'REMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '요청만기월'   'REMON'  'ZNFT1041'  ' ' ' '    'X' ' ' ' ' 'X',

      'RMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'RMENG'  'ZNFT1041'  ' ' ' '    ' ' ' ' ' ' 'X',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO2'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'H_NO1'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터 명'    'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' 'X' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'YNFIN'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG1'   ' '     'MEINS1' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SETTL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '청산상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                             USING PV_FNAME
                                   PV_CURK
                                   PV_UNIT
                                   PV_ICON
                                   PV_CHECK
                                   PV_JUST
                                   PV_EMPHA
                                   PV_FIX
                                   PV_NOOUT
                                   PV_NOZERO
                                   PV_LENGTH
                                   PV_TEXT
                                   PV_REFF
                                   PV_REFT
                                   PV_TECH
                                   PV_TYPE
                                   PV_NOSUM
                                   PV_DOSUM
                                   PV_HOTSPOT
                                   PV_EDIT.

  CLEAR : GS_FIELDCAT.

  GV_POS = GV_POS + 1.

  GS_FIELDCAT-COL_POS        = GV_POS.
  GS_FIELDCAT-FIELDNAME      = PV_FNAME.
  GS_FIELDCAT-CFIELDNAME     = PV_CURK.
  GS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  GS_FIELDCAT-ICON           = PV_ICON.
  GS_FIELDCAT-CHECKBOX       = PV_CHECK.
  GS_FIELDCAT-JUST           = PV_JUST.
  GS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  GS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  GS_FIELDCAT-KEY            = PV_FIX.
  GS_FIELDCAT-NO_OUT         = PV_NOOUT.
  GS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  GS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  GS_FIELDCAT-COLTEXT        = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_S      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_M      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_L      = PV_TEXT.
  GS_FIELDCAT-REPTEXT        = PV_TEXT.
  GS_FIELDCAT-REF_FIELD      = PV_REFF.
  GS_FIELDCAT-REF_TABLE      = PV_REFT.
  GS_FIELDCAT-TECH           = PV_TECH.
  GS_FIELDCAT-DATATYPE       = PV_TYPE.
  GS_FIELDCAT-NO_SUM         = PV_NOSUM.
  GS_FIELDCAT-DO_SUM         = PV_DOSUM.
  GS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  GS_FIELDCAT-EDIT           = PV_EDIT.

  IF PV_FNAME = 'REMON'.
    GS_FIELDCAT-F4AVAILABL   = 'X'.
  ENDIF.

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND GS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

* DATA가 변경될 경우
  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER.
  SET HANDLER :
    GRF_EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED  FOR GRF_GRID,
    GRF_EVENT_RECEIVER->HANDLE_ON_F4                  FOR GRF_GRID.

ENDFORM.                    " SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

* FieldName별 소트해서 APPEND

  GS_F4-FIELDNAME = 'REMON'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

  GS_VARIANT-HANDLE = '0001'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT[]
      IT_SORT                       = GT_SORT[]
      IT_OUTTAB                     = GT_OUTTAB[]
      IT_FILTER                     = GT_FILTER
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_SENDER  text
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_ON_F4  USING SENDER        TYPE REF TO CL_GUI_ALV_GRID
                            E_FIELDNAME   TYPE LVC_FNAME
                            E_FIELDVALUE  TYPE LVC_VALUE
                            ES_ROW_NO     TYPE LVC_S_ROID
                            ER_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                            ET_BAD_CELLS  TYPE LVC_T_MODI
                            E_DISPLAY     TYPE CHAR01.

  DATA: LV_RQTYP TYPE ZRQTYP_1,
        LV_NFKEY TYPE ZNFKEY1.

  DATA: LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.

  DATA: LV_CODE TYPE DOMVALUE_L,
        LV_TEXT TYPE VAL_TEXT.

  DATA: LS_OUTTAB   LIKE GS_OUTTAB.

  TYPES: BEGIN OF ST_FVAL,
           DOMVALUE_L TYPE DD07T-DOMVALUE_L,
           DDTEXT     TYPE DD07T-DDTEXT.
  TYPES: END OF ST_FVAL.

  DATA: LT_FVAL TYPE TABLE OF ST_FVAL,
        LS_FVAL TYPE ST_FVAL.

  IF GRF_GRID->IS_READY_FOR_INPUT( ) = 0.  "조회모드
    EXIT.
  ENDIF.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.

  CASE E_FIELDNAME.
    WHEN 'REMON'.   "요청만기월
      CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
        EXPORTING
          ACTUAL_MONTH   = SY-DATLO(6)
        IMPORTING
          SELECTED_MONTH = GS_OUTTAB-REMON.

      IF GS_OUTTAB-REMON LT SY-DATLO(6).
        MESSAGE I001 DISPLAY LIKE 'E'
           WITH '만기월은 당월 이후로 입력해야 합니다.'.
      ELSE.
        MODIFY GT_OUTTAB FROM GS_OUTTAB
                         INDEX ES_ROW_NO-ROW_ID TRANSPORTING REMON.
      ENDIF.

  ENDCASE.

  CLEAR   : GT_1020, GT_1020M.
  REFRESH : GT_1020, GT_1020M.

  LOOP AT GT_OUTTAB INTO LS_OUTTAB.
*___만기이동요청 수량의 합 점검을 위해
    GT_1020-NFUTN = LS_OUTTAB-OFUTN.
    GT_1020-EMENG = LS_OUTTAB-RMENG.

    COLLECT GT_1020.

*___만기이동요청 만기월 점검을 위해
    GT_1020M-NFUTN = LS_OUTTAB-OFUTN.
    GT_1020M-ENDMM = LS_OUTTAB-REMON.
    GT_1020M-COUNT = 1.

    COLLECT GT_1020M.
  ENDLOOP.

  PERFORM CHECK_DATA USING GS_OUTTAB
                           GV_EXCEL_FLAG.

  MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING ICON BIGO_CHK
                  WHERE OFUTN = GS_OUTTAB-OFUTN.

** To avoid standard f4-help.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                    " ALV_EVENT_ON_F4
*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHG_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHG_FINISHED  USING  E_MODIFIED
                                         ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  DATA: LV_DDVALU LIKE DD07V-DOMVALUE_L,
        LV_DDTEXT LIKE DD07V-DDTEXT.

  DATA: LV_TABIX TYPE SY-TABIX.

  DATA: LV_CONNO TYPE ZCONNO,
        LV_COTYP TYPE ZCOTYP,
        LV_RQTYP TYPE ZRQTYP_1,
        LV_NFKEY TYPE ZNFKEY1,
        LV_DEC   TYPE P DECIMALS 3.

  CLEAR : LV_CONNO, LV_COTYP, LV_RQTYP, LV_DEC.
  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'RMENG'.
        CLEAR : LV_DEC.
        LV_DEC = FRAC( LS_GOOD_CELLS-VALUE ).
        IF LV_DEC IS NOT INITIAL.
*          MESSAGE S001 DISPLAY LIKE 'W'
*             WITH '요청량은 정수로 입력해야 합니다.'.
*          CLEAR : GS_OUTTAB-EMENG.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                                          TRANSPORTING RMENG.
        ENDIF.

      WHEN 'REMON'.
        GS_OUTTAB-REMON = LS_GOOD_CELLS-VALUE.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                                        TRANSPORTING REMON.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHG_FINISHED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_FINISHED_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_FINISHED_CHECK USING ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI,
        LS_OUTTAB     LIKE GS_OUTTAB.

  CLEAR: GS_OUTTAB, GV_EXCEL_FLAG.
  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      CLEAR   : GT_1020, GT_1020M.
      REFRESH : GT_1020, GT_1020M.

      LOOP AT GT_OUTTAB INTO LS_OUTTAB.
*___만기이동요청 수량의 합 점검을 위해
        GT_1020-NFUTN = LS_OUTTAB-OFUTN.
        GT_1020-EMENG = LS_OUTTAB-RMENG.

        COLLECT GT_1020.

*___만기이동요청 만기월 점검을 위해
        GT_1020M-NFUTN = LS_OUTTAB-OFUTN.
        GT_1020M-ENDMM = LS_OUTTAB-REMON.
        GT_1020M-COUNT = 1.

        COLLECT GT_1020M.
      ENDLOOP.

      PERFORM CHECK_DATA USING GS_OUTTAB
                               GV_EXCEL_FLAG.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.

      MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING ICON BIGO_CHK
                      WHERE OFUTN = GS_OUTTAB-OFUTN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_FINISHED_CHECK

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_ON_F4_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_ON_F4_CHECK USING ES_ROW_NO TYPE LVC_S_ROID.

  CLEAR: GS_OUTTAB, GV_EXCEL_FLAG.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
  IF SY-SUBRC EQ 0.
    PERFORM CHECK_DATA USING GS_OUTTAB
                             GV_EXCEL_FLAG.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
  ENDIF.

ENDFORM.                    " ALV_EVENT_ON_F4_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE .
  DATA: LV_CFUTN     LIKE ZNFT1030-CFUTN,
        LV_FIRST,
        LV_LAST,
        LV_TEXT(200).

  CLEAR GV_EXCEL_FLAG.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

  CLEAR   : GT_1020, GT_1020M.
  REFRESH : GT_1020, GT_1020M.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
*___만기이동요청 수량의 합 점검을 위해
    GT_1020-NFUTN = GS_OUTTAB-OFUTN.
    GT_1020-EMENG = GS_OUTTAB-RMENG.

    COLLECT GT_1020.

*___만기이동요청 만기월 점검을 위해
    GT_1020M-NFUTN = GS_OUTTAB-OFUTN.
    GT_1020M-ENDMM = GS_OUTTAB-REMON.
    GT_1020M-COUNT = 1.

    COLLECT GT_1020M.
  ENDLOOP.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    PERFORM CHECK_DATA USING GS_OUTTAB
                             GV_EXCEL_FLAG.
    IF GV_EXCEL_FLAG EQ 'Y'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF GV_EXCEL_FLAG EQ 'Y'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'DATA에 오류가 존재합니다. 수정 후 저장하십시오.'.
    EXIT.
  ENDIF.

  CLEAR : LV_CFUTN.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
*___청산선물집행 정보
    SELECT SINGLE CFUTN
      INTO LV_CFUTN
      FROM ZNFT1030
     WHERE NFUTN =  GS_OUTTAB-OFUTN
       AND YNCAN =  ' '
       AND YNNET =  ' '.

    IF SY-SUBRC = 0.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_CFUTN IS NOT INITIAL.
    CONCATENATE '청산 완료된 건이 존재합니다.'
                '만기이동요청을 저장 하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    LV_TEXT = '만기이동요청을 저장 하시겠습니까?'.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER EQ '1'.
    CLEAR : LV_FIRST, LV_LAST.

    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      AT NEW OFUTN.
        LV_FIRST = 'X'.
      ENDAT.

      IF LV_FIRST = 'X'.
        CLEAR : LV_FIRST.

        PERFORM MAKE_BDC_HEADER_DATA.

        PERFORM MAKE_BDC_ITEM_DATA USING 'X'.
      ELSE.
        PERFORM MAKE_BDC_ITEM_DATA USING ' '.
      ENDIF.


      AT END OF OFUTN.
        LV_LAST = 'X'.
      ENDAT.

      IF LV_LAST = 'X'.
        CLEAR : LV_LAST.

        PERFORM MAKE_BDC_LAST_DATA USING ' '.    "저장

        PERFORM CALL_TRANSACTION USING ' '
                                       'ZNF2M2301'.
      ENDIF.
    ENDLOOP.

*   저장시 ALV 수정불가로 변경
    PERFORM ALV_EDIT_CHANGE.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DATA_SAVE
*&---------------------------------------------------------------------*
*&      Form  DATA_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SIGN .
  DATA: LV_CFUTN     LIKE ZNFT1030-CFUTN,
        LV_FIRST,
        LV_LAST,
        LV_TEXT(200).

  CLEAR GV_EXCEL_FLAG.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

  CLEAR   : GT_1020, GT_1020M.
  REFRESH : GT_1020, GT_1020M.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
*___만기이동요청 수량의 합 점검을 위해
    GT_1020-NFUTN = GS_OUTTAB-OFUTN.
    GT_1020-EMENG = GS_OUTTAB-RMENG.

    COLLECT GT_1020.

*___만기이동요청 만기월 점검을 위해
    GT_1020M-NFUTN = GS_OUTTAB-OFUTN.
    GT_1020M-ENDMM = GS_OUTTAB-REMON.
    GT_1020M-COUNT = 1.

    COLLECT GT_1020M.
  ENDLOOP.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    PERFORM CHECK_DATA USING GS_OUTTAB
                             GV_EXCEL_FLAG.
    MODIFY GT_OUTTAB FROM GS_OUTTAB.

    IF GV_EXCEL_FLAG EQ 'Y'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF GV_EXCEL_FLAG EQ 'Y'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'DATA에 오류가 존재합니다. 수정 후 저장하십시오.'.
    EXIT.
  ENDIF.

  CLEAR : LV_CFUTN.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
*___청산선물집행 정보
    SELECT SINGLE CFUTN
      INTO LV_CFUTN
      FROM ZNFT1030
     WHERE NFUTN =  GS_OUTTAB-OFUTN
       AND YNCAN =  ' '
       AND YNNET =  ' '.

    IF SY-SUBRC = 0.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_CFUTN IS NOT INITIAL AND GV_COMPLETE_SAVE <> 'Y'.
    CONCATENATE '청산 완료된 건이 존재합니다.'
                '만기이동요청을 결재요청 하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    LV_TEXT = '만기이동요청을 결재요청 하시겠습니까?'.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER EQ '1'.
    CLEAR : GV_PERNR.
    CALL SCREEN 1200 STARTING AT 20 5.

    IF OK_SAVE EQ 'CANC'.
      MESSAGE S003 WITH '작업이 취소되었습니다.'.
      EXIT.
    ENDIF.

    CLEAR : LV_FIRST, LV_LAST.

    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      AT NEW OFUTN.
        LV_FIRST = 'X'.
      ENDAT.

      IF LV_FIRST = 'X'.
        CLEAR : LV_FIRST.

        PERFORM MAKE_BDC_HEADER_DATA.

        PERFORM MAKE_BDC_ITEM_DATA USING 'X'.
      ELSE.
        PERFORM MAKE_BDC_ITEM_DATA USING ' '.
      ENDIF.

      AT END OF OFUTN.
        LV_LAST = 'X'.
      ENDAT.

      IF LV_LAST = 'X'.
        CLEAR : LV_LAST.

        PERFORM MAKE_BDC_LAST_DATA USING 'X'.    "결재요청

        IF GS_OUTTAB-SHFNO IS INITIAL.
          PERFORM CALL_TRANSACTION USING 'X'
                                         'ZNF2M2301'.
        ELSE.
          PERFORM CALL_TRANSACTION USING 'X'
                                         'ZNF2M2302'.
        ENDIF.
      ENDIF.
    ENDLOOP.

*   저장 및 결재요청의 DB처리가 완료된경우만
    CHECK GV_COMPLETE_SAVE = 'Y' OR GV_COMPLETE_REQ = 'Y'.

*--- 간편결재 전송.
    PERFORM SEND_SIMPLE_APV.

*   저장시 ALV 수정불가로 변경
    PERFORM ALV_EDIT_CHANGE.

    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DATA_SIGN
*&---------------------------------------------------------------------*
*&      Form  ALV_EDIT_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_EDIT_CHANGE .
  DATA : LV_TABIX TYPE SY-TABIX.
  DATA : LS_LVC_STYL TYPE LVC_S_STYL,
         LT_LVC_STYL TYPE LVC_T_STYL.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_TABIX = SY-TABIX.
    CLEAR LT_LVC_STYL. REFRESH LT_LVC_STYL.
    LOOP AT GT_FIELDCAT INTO GS_FIELDCAT.
      LS_LVC_STYL-FIELDNAME = GS_FIELDCAT-FIELDNAME.
      CASE LS_LVC_STYL-FIELDNAME.
        WHEN OTHERS.
          LS_LVC_STYL-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      ENDCASE.
      INSERT LS_LVC_STYL INTO TABLE LT_LVC_STYL.
    ENDLOOP.
    CLEAR GS_OUTTAB-CELLTAB.
    INSERT LINES OF LT_LVC_STYL INTO TABLE GS_OUTTAB-CELLTAB.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
  ENDLOOP.

ENDFORM.                    " ALV_EDIT_CHANGE

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHANGED USING
                P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.


*  CHECK P_DATA_CHANGED IS INITIAL.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_PERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_PERNR USING PV_ERROR.

  IF GV_PERNR IS INITIAL.
    MESSAGE '사번을 입력하십시오.' TYPE 'S' DISPLAY LIKE 'E'.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " DATA_CHECK_PERNR
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_BDC_HEADER_DATA.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  IF GS_OUTTAB-SHFNO IS INITIAL.
    PERFORM DYNPRO USING :
                  'X' 'SAPMZNF2300'        '0100',
                  ' ' 'BDC_OKCODE'         '=ENTR',            "Enter
                  ' ' 'GV_BUKRS'           GS_OUTTAB-BUKRS,
                  ' ' 'GV_OFUTN'           GS_OUTTAB-OFUTN.

*--{기능개선_257127 - 수정
*    IF GS_OUTTAB-SETTL = '청산완료'.
*      PERFORM DYNPRO USING :
*                  'X' 'SAPLSPO1'           '0500',
*                  ' ' 'BDC_OKCODE'         '=OPT1'.
*    ENDIF.
*--}기능개선_257127 - 2018.12.13
  ELSE.
    PERFORM DYNPRO USING :
                  'X' 'SAPMZNF2300'        '0110',
                  ' ' 'BDC_OKCODE'         '=ENTR',            "Enter
                  ' ' 'GV_SHFNO'           GS_OUTTAB-SHFNO.
  ENDIF.

ENDFORM.                    " MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_ITEM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_BDC_ITEM_DATA USING PV_FLAG.
  DATA: LV_RMENG(15).

  CHECK GV_COMPLETE_SAVE <> 'Y'.

  WRITE : GS_OUTTAB-RMENG TO LV_RMENG UNIT GS_OUTTAB-MEINS
                                      NO-GROUPING.

  PERFORM DYNPRO USING :
                'X' 'SAPMZNF2300'        '0200',
                ' ' 'BDC_OKCODE'         '/00',
                ' ' 'GT_1041-REMON(02)'  GS_OUTTAB-REMON,
                ' ' 'GT_1041-RMENG(02)'  LV_RMENG.

  IF PV_FLAG = 'X'.
    PERFORM DYNPRO USING :
                ' ' 'ZNFT1040-BIGO4'     GS_OUTTAB-BIGO3.
  ENDIF.

  PERFORM DYNPRO USING :
                'X' 'SAPMZNF2300'        '0200',
                ' ' 'BDC_OKCODE'         '=RADD'.

ENDFORM.                    " MAKE_BDC_ITEM_DATA
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_LAST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_BDC_LAST_DATA  USING PV_FLAG.
  DATA: LV_OKCODE   LIKE SY-UCOMM.

  IF PV_FLAG IS INITIAL.
    LV_OKCODE = '=SAVE'.
  ELSE.
    LV_OKCODE = '=REQT'.
  ENDIF.

  PERFORM DYNPRO USING :
                'X' 'SAPMZNF2300'        '0200',
                ' ' 'BDC_OKCODE'         LV_OKCODE,

                'X' 'SAPLSPO1'           '0500',
                ' ' 'BDC_OKCODE'         '=OPT1'.

  IF PV_FLAG IS NOT INITIAL.
    PERFORM DYNPRO USING :
                'X' 'SAPMZNF2300'        '0300',
                ' ' 'BDC_OKCODE'         '=CONT',
                ' ' 'GV_PERNR'           GV_PERNR.
  ENDIF.

ENDFORM.                    " MAKE_BDC_LAST_DATA
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2953   text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION  USING  PV_FLAG
                              PV_TCODE.
  DATA: LV_MSGNR        LIKE BDCMSGCOLL-MSGNR,
        LV_MESSAGE(200).

  CLEAR : CTU_PARAMS.

  CTU_PARAMS-DISMODE  =  'N'.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION PV_TCODE USING         GT_BDCTAB
                            OPTIONS  FROM CTU_PARAMS
                            MESSAGES INTO GT_RETMSG.

  IF PV_FLAG IS INITIAL.
    LV_MSGNR = '010'.
  ELSE.
    LV_MSGNR = '011'.
  ENDIF.

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                MSGID  = 'ZNF1'
                                MSGNR  = LV_MSGNR.
  IF SY-SUBRC = 0.
    IF PV_FLAG IS INITIAL.
      GV_COMPLETE_SAVE = 'Y'.
    ELSE.
      GV_COMPLETE_REQ  = 'Y'.
    ENDIF.

    GS_OUTTAB-SHFNO = GT_RETMSG-MSGV2.
  ELSE.
    IF PV_FLAG IS INITIAL.
      GV_COMPLETE_SAVE = 'N'.
    ELSE.
      GV_COMPLETE_REQ  = 'N'.
    ENDIF.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    MESSAGE ID GT_RETMSG-MSGID
            TYPE 'S'
            NUMBER GT_RETMSG-MSGNR
            WITH   GT_RETMSG-MSGV1
                   GT_RETMSG-MSGV2
                   GT_RETMSG-MSGV3
                   GT_RETMSG-MSGV4
            DISPLAY LIKE GT_RETMSG-MSGTYP.
*    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*      EXPORTING
*        MSGID                     = GT_RETMSG-MSGID
*        MSGNR                     = GT_RETMSG-MSGNR
*        MSGV1                     = GT_RETMSG-MSGV1
*        MSGV2                     = GT_RETMSG-MSGV2
*        MSGV3                     = GT_RETMSG-MSGV3
*        MSGV4                     = GT_RETMSG-MSGV4
*      IMPORTING
*        MESSAGE_TEXT_OUTPUT       = LV_MESSAGE.
  ENDIF.

  MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING SHFNO
                  WHERE OFUTN = GS_OUTTAB-OFUTN.

ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APV .
    CLEAR : GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      PERFORM SEND_SIMPLE_APPROVAL
      USING GS_OUTTAB-SHFNO
            GS_OUTTAB-BUKRS
            '2B'.
    ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_OUTTAB_SHFNO
*&      --> GS_OUTTAB_BUKRS
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APPROVAL  USING    P_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.

  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.

ENDFORM.
