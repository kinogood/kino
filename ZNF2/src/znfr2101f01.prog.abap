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
*      DEFAULT_FILENAME  = '선물요청 대량생성.xls'
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

  DATA : LV_FILENAME TYPE STRING VALUE '선물요청 대량생성.xls',
         LV_PATH     TYPE STRING VALUE 'C:\',
         LV_PULLPATH TYPE STRING VALUE 'C:\선물요청 대량생성.xls'.

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

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_WWWDATATAB
    FROM WWWDATA
   WHERE OBJID EQ 'ZNFR2101'.

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
*&      Form  TRANS_EXCEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TRANS_EXCEL_DATA .

* 01. Upload Excel Data => IT_FILE 데이터로 읽어들인다.
* 02. IT_FILE로 읽은 해당 필드로 복사한다. (해당 컬럼 순번별로).
* 03. SORT 및 중복제거

  DATA : IT_FILE  LIKE ALSMEX_TABLINE OCCURS 0 WITH HEADER LINE.
  REFRESH GT_EXCEL.

* ### STEP - 01 ###

* 헤더라인 제외 2번라인부터 INTERNAL TALBE로 이동
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FNAME1  " 파일명
      I_BEGIN_COL             = 1         " 첫번째 COLUMN
      I_BEGIN_ROW             = 2         " 첫번재 ROW
      I_END_COL               = 7         " 마지막 COLUMN
      I_END_ROW               = 10000     " 마지막 ROW
      " (데이타건수 확인후 지정)
    TABLES
      INTERN                  = IT_FILE   " excel로 읽어온 데이터
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC NE 0.
    MESSAGE '파일 업로드 에러입니다.'
       TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

* ### STEP - 02 ###
  LOOP AT IT_FILE.
    CASE IT_FILE-COL.
      WHEN '0001'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-RQTYP.
      WHEN '0002'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-NFKEY.
      WHEN '0003'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-BY_SL.
      WHEN '0004'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-ENDMM.
      WHEN '0005'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-EMENG.
      WHEN '0006'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-CONNO.
      WHEN '0007'.
        MOVE IT_FILE-VALUE TO GS_EXCEL-BIGO4.
    ENDCASE.
    AT END OF ROW.
      APPEND GS_EXCEL TO GT_EXCEL.
      CLEAR GS_EXCEL.
    ENDAT.
  ENDLOOP.

* ### STEP - 03 ###
  IF GT_EXCEL IS INITIAL.
    MESSAGE '데이타가 존재하지 않습니다.'
      TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
*   정렬 후 / 중복데이터 삭제
    SORT GT_EXCEL BY RQTYP NFKEY BY_SL ENDMM.
    DELETE ADJACENT DUPLICATES FROM GT_EXCEL
      COMPARING RQTYP NFKEY BY_SL ENDMM EMENG CONNO BIGO4.
  ENDIF.

ENDFORM.                    " TRANS_EXCEL_DATA

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

  FIELD-SYMBOLS <FS_TAB> TYPE STANDARD TABLE.

  LT_TAB = 'GT_EXCEL'.

  ASSIGN  (LT_TAB)  TO  <FS_TAB>.

  CLEAR   : <FS_TAB>.
  REFRESH : <FS_TAB>.

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

  LV_SEQ = 0.
  LOOP AT GT_EXCEL INTO GS_EXCEL.

    LV_TABIX = SY-TABIX.

*   계약번호 체크 ( 계약번호가 10자리가 아닌경우 Clear )
    CONDENSE GS_EXCEL-CONNO NO-GAPS.
*    DESCRIBE FIELD : GS_EXCEL-CONNO OUTPUT-LENGTH LV_LEN.
    LV_LEN = STRLEN( GS_EXCEL-CONNO ).
    IF LV_LEN NE 10.
      CLEAR GS_EXCEL-CONNO.
    ENDIF.

*   요청수량이 소수점이 포함된 경우 Clear
    LV_NUM_P = GS_EXCEL-EMENG.
    LV_NUM = LV_NUM_P.
    CONDENSE LV_NUM NO-GAPS.
    IF LV_NUM CP '*.00'.
    ELSE.
      CLEAR GS_EXCEL-EMENG.
    ENDIF.

*   코드값 대문자로 일괄변경
    TRANSLATE : GS_EXCEL-NFKEY TO UPPER CASE,
                GS_EXCEL-BY_SL TO UPPER CASE.

*   MODIFY GT_EXCEL FROM GS_EXCEL INDEX LV_TABIX.
    MOVE-CORRESPONDING GS_EXCEL TO GS_OUTTAB.

*   TEXT 및 DEFAULTE DATA
    ADD 1 TO LV_SEQ.

*   Excel Data
    CLEAR : ZNFT1000.

    IF GS_OUTTAB-CONNO IS NOT INITIAL.
      SELECT SINGLE *
        FROM ZNFT1000
       WHERE CONNO EQ GS_OUTTAB-CONNO.

      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING ZNFT1000 TO GS_OUTTAB.
      ENDIF.
    ENDIF.


*   H_NO1
    GS_OUTTAB-H_NO1 = LV_SEQ.

*   BUKRS
    IF P_BUKRS IS NOT INITIAL.
      GS_OUTTAB-BUKRS = P_BUKRS.
      SELECT SINGLE BUTXT INTO GS_OUTTAB-BUKRS_NM
        FROM T001
       WHERE BUKRS EQ P_BUKRS.
    ENDIF.

*--> 비철 CME 관리 추가
    "--> 기존 주석
*    GS_OUTTAB-MEINS = 'TON'.
    "--> 계약에 물린 단위를 사용 (LB or TON)
    SELECT SINGLE MEINS
      INTO GS_OUTTAB-MEINS
      FROM ZNFT1001
     WHERE CONNO = GS_OUTTAB-CONNO.
*<-- 비철 CME 관리 추가

*   - 선물요청구분
    IF GS_OUTTAB-RQTYP IS NOT INITIAL.
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB-RQTYP
                                     GS_OUTTAB-RQTYP_NM.
    ENDIF.

*   - 비철구분
    IF GS_OUTTAB-NFKEY IS NOT INITIAL.
      PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                     GS_OUTTAB-NFKEY
                                     GS_OUTTAB-NFKEY_NM.
    ENDIF.

*   - Buy-Sell 구
    IF GS_OUTTAB-BY_SL IS NOT INITIAL.
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-BY_SL
                                     GS_OUTTAB-BY_SL_NM.
    ENDIF.

*   - 사업부
    PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-NFCTR
                                 GS_OUTTAB-NFCTR_NM.

*   - 손익센터
    PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PRCTR_NM.

*   - 영업그룹
    PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-VKGRP
                                 GS_OUTTAB-VKGRP_NM.

*   - 계약유형
    GS_OUTTAB-COTYP = ZNFT1000-COTYP.
    IF GS_OUTTAB-COTYP IS NOT INITIAL.
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB-COTYP
                                     GS_OUTTAB-COTYP_NM.
    ENDIF.

    GS_OUTTAB-COTXT = ZNFT1000-COTXT.

*   - 고객코드
    GS_OUTTAB-KUNNR = ZNFT1000-KUNNR.
    PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                 GS_OUTTAB-KUNNR_NM.
    IF GS_OUTTAB-KUNNR_NM IS INITIAL.
      GS_OUTTAB-KUNNR_NM = ZNFT1000-NCUST.
    ENDIF.

    GS_OUTTAB-SALER = ZNFT1000-SALER.

*   - 수주량 & 단위
    SELECT SINGLE EMENG MEINS
           INTO (GS_OUTTAB-CEMENG, GS_OUTTAB-CMEINS)
      FROM ZNFT1001
     WHERE CONNO EQ GS_OUTTAB-CONNO
       AND NFKEY EQ GS_OUTTAB-NFKEY.

*   - 통화 (USD 고정)
    GS_OUTTAB-WAERS = 'USD'.

*   - Buy & Sell
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GS_OUTTAB-BY_SL
                                   GS_OUTTAB-BY_SL_NM.

*   - 가격구분 & 비철 수주가 (공통모듈 로직참조)
    PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB-CONNO
                                       GS_OUTTAB-NFKEY
                                       GS_OUTTAB-PRIND
                                       GS_OUTTAB-SUJUP
                                       GV_ERROR.

    PERFORM CHECK_DATA USING GS_OUTTAB
                             GV_EXCEL_FLAG.

    APPEND GS_OUTTAB TO GT_OUTTAB.
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
        LV_TABIX      TYPE SY-TABIX.

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

*   ### 선물요청유형 체크 ###
  IF PS_OUTTAB-RQTYP IS NOT INITIAL.
    CLEAR : LV_DDVALU, LV_DDTEXT.
    LV_DDVALU = PS_OUTTAB-RQTYP.
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   LV_DDVALU
                                   LV_DDTEXT.
    IF LV_DDTEXT IS INITIAL.
      CONCATENATE LV_BIGO_CHECK '요청유형코드오류'
       INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '요청유형누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   ### 비철구분 체크 ###
  IF PS_OUTTAB-NFKEY IS NOT INITIAL.
    CLEAR : LV_DDVALU, LV_DDTEXT.
    LV_DDVALU = PS_OUTTAB-NFKEY.

    PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                   LV_DDVALU
                                   LV_DDTEXT.
    IF LV_DDTEXT IS INITIAL.
      CONCATENATE LV_BIGO_CHECK '비철구분코드오류'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '비철구분누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   ### Buy-Sell 체크 ###
  IF PS_OUTTAB-BY_SL IS NOT INITIAL.
    CLEAR : LV_DDVALU, LV_DDTEXT.
    LV_DDVALU = PS_OUTTAB-BY_SL.
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   LV_DDVALU
                                   LV_DDTEXT.
    IF LV_DDTEXT IS INITIAL.
      CONCATENATE LV_BIGO_CHECK 'Buy-Sell코드오류'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK 'Buy-Sell누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   ### 만기월 체크 ###
  IF PS_OUTTAB-ENDMM IS NOT INITIAL.
    CLEAR: LV_ENDMM.
    CONCATENATE PS_OUTTAB-ENDMM '01' INTO LV_ENDMM.
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
      IF PS_OUTTAB-ENDMM LT SY-DATLO(6).
        CONCATENATE LV_BIGO_CHECK '과거만기월'
          INTO LV_BIGO_CHECK SEPARATED BY '/'.
      ENDIF.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '만기월누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   ### 요청수량 체크 ###
  IF PS_OUTTAB-EMENG IS NOT INITIAL.
    CLEAR : LV_EMENG_I, LV_EMENG_O.
    LV_EMENG_I = PS_OUTTAB-EMENG.

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
        CONCATENATE PS_OUTTAB-BIGO_CHK '요청수량오류(수량>0)'
          INTO PS_OUTTAB-BIGO_CHK SEPARATED BY '/'.
      ELSE.
        PS_OUTTAB-EMENG = LV_EMENG.
      ENDIF.
    ELSE.
      CONCATENATE LV_BIGO_CHECK '요청수량숫자오류'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '요청수량누락'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

* ### 요청유형 및 계약유형 코드 매칭 체크 ###
  SELECT SINGLE COTYP CSTAT INTO (LV_COTYP, LV_CSTAT)
    FROM ZNFT1000
   WHERE CONNO EQ PS_OUTTAB-CONNO.

  IF SY-SUBRC EQ 0.
    LV_RQTYP = PS_OUTTAB-RQTYP.
    IF LV_COTYP NE LV_RQTYP.
      CONCATENATE LV_BIGO_CHECK '요청-계약유형 상이'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.

    IF LV_CSTAT NE 'L'.
      CONCATENATE LV_BIGO_CHECK '진행상태 계약 아님'
        INTO LV_BIGO_CHECK SEPARATED BY '/'.
    ENDIF.
  ELSE.
    CONCATENATE LV_BIGO_CHECK '미존재 계약번호'
      INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

* ### RQTYP이 '1', '2', '3') 인경우 BUY-SELL = 'B'만 가능 ###
  CASE PS_OUTTAB-RQTYP.
    WHEN '1' OR '2' OR '3'.
      IF PS_OUTTAB-BY_SL EQ 'S'.
        CONCATENATE LV_BIGO_CHECK '해당요청유형은 BUY만 가능'
          INTO LV_BIGO_CHECK SEPARATED BY '/'.
      ENDIF.
  ENDCASE.

* ### 가격구분 & 비철 수주가 (공통모듈 로직참조)
  PERFORM PRICE_CLASSIFICATION USING PS_OUTTAB-CONNO
                                     PS_OUTTAB-NFKEY
                                     PS_OUTTAB-PRIND
                                     PS_OUTTAB-SUJUP
                                     GV_ERROR.

* ### 가격구분 및 비철 수주가 없을경우 ERROR 로그에 추가
  IF GV_ERROR EQ 'X'.
    CONCATENATE PS_OUTTAB-CONNO '&' PS_OUTTAB-NFKEY ':없음'
                INTO LV_MSG.
    CONDENSE LV_MSG NO-GAPS.
    CONCATENATE LV_BIGO_CHECK LV_MSG
           INTO LV_BIGO_CHECK SEPARATED BY '/'.
  ENDIF.

*   BIGO_CHK 필드에 데이터 점검결과 입력
  IF LV_BIGO_CHECK+0(1) EQ '/'.
    PS_OUTTAB-BIGO_CHK = LV_BIGO_CHECK+1(199).
  ELSE.
    PS_OUTTAB-BIGO_CHK = LV_BIGO_CHECK.
  ENDIF.

*   상태값 갱신
  IF PS_OUTTAB-BIGO_CHK IS NOT INITIAL.
    PS_OUTTAB-ICON = '@S_TL_R@'.
    PV_EXCEL_FLAG = 'Y'.
  ELSE.
    PS_OUTTAB-ICON = '@S_TL_G@'.
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

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'H_NO1'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
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

  PERFORM SET_FIELDCAT USING:
    'ICON'            '상태'            '10'     'C'    ' '     ,
*    'REQNO'           '요청번호'        '10'     'C'    ' '     ,
    'H_NO1'           '항번'            '10'     'C'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
*    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'RQTYP'           '요청유형'        '10'     'C'    ' '     ,
    'RQTYP_NM'        '요청유형명'      '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    'ALPHA' ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    'ALPHA' ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'VKGRP'           '영업조직'        '10'     'C'    ' '     ,
    'VKGRP_NM'        '영업조직명'      '10'     'L'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
*    'NFKEY_NM'        '비철구분'        '10'     'L'    ' '     ,
    'BY_SL'           'Buy-Sell'        '10'     'C'    ' '     ,
    'BY_SL_NM'        'Buy-Sell명'      '10'     'C'    ' '     ,
    'ENDMM'           '만기월'          '10'     'C'    'PERI'  ,
    'EMENG'           '요청수량'        '10'     'R'    ' '     ,
    'MEINS'           '단위'            '10'     'C'    ' '     ,
    'CONNO'           '계약 No.'        '10'     'L'    ' '     ,
*    'COTYP'           '계약유형'        '10'     'C'    ' '     ,
    'COTYP_NM'        '계약유형명'      '10'     'L'    ' '     ,
    'COTXT'           '계약명'          '10'     'L'    ' '     ,
    'KUNNR'           '고객'            '10'     'C'    'ALPHA' ,
    'KUNNR_NM'        '고객명'          '10'     'L'    ''      ,
    'SALER'           '영업담당자'      '10'     'C'    ' '     ,
    'CEMENG'          '수주량'          '10'     'R'    ' '     ,
    'CMEINS'          '단위'            '10'     'C'    ' '     ,
    'WAERS'           '통화'            '10'     'C'    ' '     ,
    'PRIND'           '가격구분'        '10'     'C'    ' '     ,
    'SUJUP'           '비철수주가'      '10'     'R'    ' '     ,
    'BIGO4'           '비고'            '40'     'L'    ' '     ,
    'BIGO_CHK'        'Excel Error Log' '10'     'L'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT-JUST       = P_JUST      .
  GS_FIELDCAT-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'RQTYP' OR 'NFKEY' OR 'BY_SL'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-F4AVAILABL = 'X'.
*      GS_FIELDCAT-REF_FIELD  = 'RQTYP'.
*      GS_FIELDCAT-REF_TABLE  = 'ZNFT1010'.
    WHEN 'CONNO'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-F4AVAILABL = 'X'.
    WHEN  'ENDMM'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-F4AVAILABL = 'X'.
    WHEN 'BIGO4'.
      GS_FIELDCAT-EDIT       = 'X'.
    WHEN 'EMENG'.
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-QUANTITY   = 'TON'.
      GS_FIELDCAT-REF_TABLE  = 'ZNFT1011'.
      GS_FIELDCAT-REF_FIELD  = 'EMENG'.
  ENDCASE.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         L_INDEX    TYPE I.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB-CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX L_INDEX.
  ENDLOOP.


ENDFORM.                    " SET_CELL_ATTRIBUTE
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

  GS_F4-FIELDNAME = 'BY_SL'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'CONNO'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'ENDMM'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'NFKEY'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.


  GS_F4-FIELDNAME = 'RQTYP'.
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
    WHEN 'RQTYP'.
      CLEAR: LV_CODE, LV_TEXT.

      SELECT DOMVALUE_L DDTEXT
        FROM DD07T
        INTO CORRESPONDING FIELDS OF TABLE LT_FVAL
       WHERE DOMNAME EQ 'ZRQTYP_1'
         AND DDLANGUAGE EQ SY-LANGU.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD        = 'RQTYP'
          VALUE_ORG       = 'S'
        TABLES
          VALUE_TAB       = LT_FVAL
          RETURN_TAB      = LT_RETURN
        EXCEPTIONS
          PARAMETER_ERROR = 1
          NO_VALUES_FOUND = 2
          OTHERS          = 3.

      IF SY-SUBRC EQ 0.
        READ TABLE LT_RETURN INDEX 1.
        IF SY-SUBRC EQ 0.
          LV_TEXT = LT_RETURN-FIELDVAL.

          SELECT SINGLE DOMVALUE_L INTO LV_CODE
            FROM DD07T
           WHERE DOMNAME    EQ 'ZRQTYP_1'
             AND DDTEXT     EQ LV_TEXT
             AND DDLANGUAGE EQ SY-LANGU.

          IF SY-SUBRC EQ 0.
            CONDENSE : LV_CODE NO-GAPS, LV_CODE NO-GAPS.
            GS_OUTTAB-RQTYP    = LV_CODE.
            GS_OUTTAB-RQTYP_NM = LV_TEXT.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'BY_SL'.
      CLEAR: LV_CODE, LV_TEXT.

      SELECT DOMVALUE_L DDTEXT
        FROM DD07T
        INTO CORRESPONDING FIELDS OF TABLE LT_FVAL
       WHERE DOMNAME EQ 'ZBY_SL'
         AND DDLANGUAGE EQ SY-LANGU.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD        = 'BY_SL'
          VALUE_ORG       = 'S'
        TABLES
          VALUE_TAB       = LT_FVAL
          RETURN_TAB      = LT_RETURN
        EXCEPTIONS
          PARAMETER_ERROR = 1
          NO_VALUES_FOUND = 2
          OTHERS          = 3.

      IF SY-SUBRC EQ 0.
        READ TABLE LT_RETURN INDEX 1.
        IF SY-SUBRC EQ 0.
          LV_TEXT = LT_RETURN-FIELDVAL.

          SELECT SINGLE DOMVALUE_L INTO LV_CODE
            FROM DD07T
           WHERE DOMNAME    EQ 'ZBY_SL'
             AND DDTEXT     EQ LV_TEXT
             AND DDLANGUAGE EQ SY-LANGU.

          IF SY-SUBRC EQ 0.
            CONDENSE : LV_CODE NO-GAPS, LV_CODE NO-GAPS.
            GS_OUTTAB-BY_SL    = LV_CODE.
            GS_OUTTAB-BY_SL_NM = LV_TEXT.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'NFKEY'.
      CLEAR: LV_CODE, LV_TEXT.

      SELECT DOMVALUE_L DDTEXT
        FROM DD07T
        INTO CORRESPONDING FIELDS OF TABLE LT_FVAL
       WHERE DOMNAME EQ 'ZNFKEY_1'
         AND DDLANGUAGE EQ SY-LANGU.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD        = 'NFKEY'
          VALUE_ORG       = 'S'
        TABLES
          VALUE_TAB       = LT_FVAL
          RETURN_TAB      = LT_RETURN
        EXCEPTIONS
          PARAMETER_ERROR = 1
          NO_VALUES_FOUND = 2
          OTHERS          = 3.

      IF SY-SUBRC EQ 0.
        READ TABLE LT_RETURN INDEX 1.
        IF SY-SUBRC EQ 0.
          LV_TEXT = LT_RETURN-FIELDVAL.

          SELECT SINGLE DOMVALUE_L INTO LV_CODE
            FROM DD07T
           WHERE DOMNAME    EQ 'ZNFKEY_1'
             AND DDTEXT     EQ LV_TEXT
             AND DDLANGUAGE EQ SY-LANGU.

          IF SY-SUBRC EQ 0.
            CONDENSE : LV_CODE NO-GAPS, LV_CODE NO-GAPS.
            GS_OUTTAB-NFKEY    = LV_CODE.
            GS_OUTTAB-NFKEY_NM = LV_TEXT.
            MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'CONNO'.  "계약번호
      READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
      LV_NFKEY = GS_OUTTAB-NFKEY.
      LV_RQTYP = GS_OUTTAB-RQTYP.
      IF LV_RQTYP IS INITIAL.
        MESSAGE I001 DISPLAY LIKE 'E'
           WITH '요청유형은 필수입니다.'.
      ENDIF.
      IF SY-SUBRC = 0.
        PERFORM F4HELP_CONNO USING LV_RQTYP LV_NFKEY.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
      ENDIF.
    WHEN 'ENDMM'.  "만기월
      CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
        EXPORTING
          ACTUAL_MONTH   = SY-DATLO(6)
        IMPORTING
          SELECTED_MONTH = GS_OUTTAB-ENDMM.

      IF GS_OUTTAB-ENDMM LT SY-DATLO(6).
        MESSAGE I001 DISPLAY LIKE 'E'
           WITH '만기월은 당월 이후로 입력해야 합니다.'.
      ELSE.
        MODIFY GT_OUTTAB FROM GS_OUTTAB
                         INDEX ES_ROW_NO-ROW_ID TRANSPORTING ENDMM.
      ENDIF.

  ENDCASE.

** To avoid standard f4-help.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                    " ALV_EVENT_ON_F4
*&---------------------------------------------------------------------*
*&      Form  F4HELP_CONNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_CONNO  text
*----------------------------------------------------------------------*
FORM F4HELP_CONNO USING P_RQTYP P_NFKEY.

  DATA: LV_DDVALU LIKE DD07V-DOMVALUE_L,
        LV_DDTEXT LIKE DD07V-DDTEXT.

  DATA: LV_TABIX TYPE SY-TABIX.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE.

* FILL INTERNAL TABLE : GT_CONNO
  SELECT A~BUKRS  "사업부
         A~COTYP  "계약유형
         A~NFCTR  "사업부
         A~PRCTR  "손익센터
         A~VKGRP  "영업그룹
         A~CONNO  "계약번호
         A~ERDAT  "생성일
         A~COTXT  "계약명(PJT명)
         A~KUNNR  "고객코드
         A~NCUST  "고객명
         A~SUJUD  "수주일
         A~SALER  "영업담당자
         B~NFKEY  "비철구분
         B~EMENG  "수주량
         B~MEINS  "단위
    INTO CORRESPONDING FIELDS OF TABLE GT_CONNO
    FROM ZNFT1000 AS A
         INNER JOIN ZNFT1001 AS B
            ON A~CONNO EQ B~CONNO
   WHERE A~CSTAT EQ 'L'
     AND A~COTYP EQ P_RQTYP
     AND A~BUKRS EQ P_BUKRS
     AND B~NFKEY EQ P_NFKEY.

  IF SY-SUBRC EQ 0.
    LOOP AT GT_CONNO INTO GS_CONNO.
*     가격구분/비철수주가격
      LV_TABIX = SY-TABIX.
      PERFORM PRICE_CLASSIFICATION USING GS_CONNO-CONNO
                                         GS_CONNO-NFKEY
                                         GS_CONNO-PRIND
                                         GS_CONNO-SUJUP
                                         GV_ERROR.

      MODIFY GT_CONNO FROM GS_CONNO INDEX LV_TABIX.
      CLEAR : GS_CONNO, LV_TABIX.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조건에 해당하는 계약이 존재하지 않습니다.'.
  ENDIF.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'BUKRS'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'COTYP'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'CONNO'.
  IT_FIELDS-SELECTFLAG = 'X'.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'ERDAT'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'COTXT'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'KUNNR'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'NCUST'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'SUJUD'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.    IT_FIELDS-FIELDNAME  = 'SALER'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1001'.    IT_FIELDS-FIELDNAME  = 'NFKEY'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.    IT_FIELDS-FIELDNAME  = 'PRIND'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.    IT_FIELDS-FIELDNAME  = 'SUJUP'.
  IT_FIELDS-SELECTFLAG = ' '.           APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = GT_CONNO
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_CONNO INTO GS_CONNO INDEX LD_TABIX.

* ### 해당 계약정보에 해당하는 CODE & TEXT 가져오기 ###
  IF SY-SUBRC EQ 0.
*    MOVE-CORRESPONDING GS_CONNO TO GS_OUTTAB.
    GS_OUTTAB-BUKRS = GS_CONNO-BUKRS.
    GS_OUTTAB-CONNO = GS_CONNO-CONNO.
    GS_OUTTAB-NFCTR = GS_CONNO-NFCTR.
    GS_OUTTAB-PRCTR = GS_CONNO-PRCTR.
    GS_OUTTAB-VKGRP = GS_CONNO-VKGRP.
    GS_OUTTAB-COTYP = GS_CONNO-COTYP.
    GS_OUTTAB-COTXT = GS_CONNO-COTXT.
    GS_OUTTAB-KUNNR = GS_CONNO-KUNNR.
    GS_OUTTAB-SALER = GS_CONNO-SALER.

*   - 회사코드
    PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-BUKRS_NM.

*   - 사업부
    PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-NFCTR
                                 GS_OUTTAB-NFCTR_NM.

*   - 손익센터
    PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PRCTR_NM.

*   - 영업그룹
    PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-VKGRP
                                 GS_OUTTAB-VKGRP_NM.

*   - 계약유형
    PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                   GS_OUTTAB-COTYP
                                   GS_OUTTAB-COTYP_NM.

*   - 고객명
    PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                 GS_OUTTAB-KUNNR_NM.

    IF SY-SUBRC NE 0 AND GS_OUTTAB-KUNNR_NM IS INITIAL.
      GS_OUTTAB-KUNNR_NM = GS_CONNO-NCUST.
    ENDIF.

*   - 계약 수주량 & 단위
    GS_OUTTAB-CEMENG = GS_CONNO-EMENG.
    GS_OUTTAB-CMEINS = GS_CONNO-MEINS.
  ENDIF.

ENDFORM.                    " F4HELP_CONNO
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
      WHEN 'CONNO'.
        CLEAR : GS_CONNO, LV_CONNO, LV_RQTYP, LV_NFKEY.
        CONDENSE LS_GOOD_CELLS-VALUE NO-GAPS.
        LV_CONNO = LS_GOOD_CELLS-VALUE.

        READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC EQ 0.
          LV_RQTYP = GS_OUTTAB-RQTYP.
          LV_NFKEY = GS_OUTTAB-NFKEY.
        ENDIF.

        SELECT SINGLE
               A~BUKRS  "사업부
               A~COTYP  "계약유형
               A~NFCTR  "사업부
               A~PRCTR  "손익센터
               A~VKGRP  "영업그룹
               A~CONNO  "계약번호
               A~ERDAT  "생성일
               A~COTXT  "계약명(PJT명)
               A~KUNNR  "고객코드
               A~NCUST  "고객명
               A~SUJUD  "수주일
               A~SALER  "영업담당자
               B~NFKEY  "비철구분
               B~EMENG  "수주량
               B~MEINS  "단위
          INTO CORRESPONDING FIELDS OF GS_CONNO
          FROM ZNFT1000 AS A
               INNER JOIN ZNFT1001 AS B
                  ON A~CONNO EQ B~CONNO
         WHERE A~CSTAT EQ 'L'
           AND A~BUKRS EQ P_BUKRS
           AND A~CONNO EQ LV_CONNO
           AND A~COTYP EQ LV_RQTYP
           AND B~NFKEY EQ LV_NFKEY.

        IF SY-SUBRC EQ 0.
*         입력한 계약번호에 관련된 추가정보 반영
          PERFORM PRICE_CLASSIFICATION USING LV_CONNO
                                             GS_OUTTAB-NFKEY
                                             GS_OUTTAB-PRIND
                                             GS_OUTTAB-SUJUP
                                             GV_ERROR.

*         - 비철구분
          PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                         GS_OUTTAB-NFKEY
                                         GS_OUTTAB-NFKEY_NM.


*         - 회사코드
          GS_OUTTAB-BUKRS = GS_CONNO-BUKRS.
*          PERFORM GET_DEFAULT_COMPANY_DATA USING GS_OUTTAB-BUKRS
*                                                 ''  ''
*                                                 GS_OUTTAB-BUKRS_NM
*                                                 ''  ''.

*          - 사업부
          GS_OUTTAB-NFCTR = GS_CONNO-NFCTR.
          PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                       GS_OUTTAB-NFCTR
                                       GS_OUTTAB-NFCTR_NM.


*         - 손익센터
          GS_OUTTAB-PRCTR = GS_CONNO-PRCTR.
          PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                       GS_OUTTAB-PRCTR
                                       GS_OUTTAB-PRCTR_NM.

*         -	영업그룹
          GS_OUTTAB-VKGRP = GS_CONNO-VKGRP.
          PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                       GS_OUTTAB-VKGRP
                                       GS_OUTTAB-VKGRP_NM.

*         - 계약유형
          CLEAR : LV_DDVALU, LV_DDTEXT.
          GS_OUTTAB-COTYP = GS_CONNO-COTYP.
          PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                         GS_OUTTAB-COTYP
                                         GS_OUTTAB-COTYP_NM.

          GS_OUTTAB-COTXT = GS_CONNO-COTXT.

*         - 고객명
          GS_OUTTAB-KUNNR = GS_CONNO-KUNNR.
          PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                       GS_OUTTAB-KUNNR_NM.
          IF GS_OUTTAB-KUNNR_NM IS INITIAL.
            GS_OUTTAB-KUNNR_NM = GS_CONNO-NCUST.
          ENDIF.

          GS_OUTTAB-SALER = GS_CONNO-SALER.

*         계약 수주량 & 단위
          GS_OUTTAB-CEMENG = GS_CONNO-EMENG.
          GS_OUTTAB-CMEINS = GS_CONNO-MEINS.

          PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                         GS_OUTTAB-BY_SL
                                         GS_OUTTAB-BY_SL_NM.

          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
          CLEAR GS_OUTTAB.
        ENDIF.

      WHEN 'RQTYP'.
        READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE COTYP INTO LV_COTYP
            FROM ZNFT1000
           WHERE CONNO EQ GS_OUTTAB-CONNO.

          IF SY-SUBRC EQ 0.
            LV_RQTYP = LS_GOOD_CELLS-VALUE.
            IF LV_COTYP NE LV_RQTYP.
*              MESSAGE S001 DISPLAY LIKE 'W'
*              WITH '계약유형과 요청유형의 코드값이 일치하지 않습니다.'.
            ENDIF.
          ENDIF.
        ENDIF.

        CLEAR : LV_DDVALU, LV_DDTEXT.
        LV_DDVALU = LS_GOOD_CELLS-VALUE.
        CALL FUNCTION 'DOMAIN_VALUE_GET'
          EXPORTING
            I_DOMNAME  = 'ZRQTYP_1'
            I_DOMVALUE = LV_DDVALU
          IMPORTING
            E_DDTEXT   = LV_DDTEXT
          EXCEPTIONS
            NOT_EXIST  = 1
            OTHERS     = 2.
        IF LV_DDTEXT IS NOT INITIAL.
          GS_OUTTAB-RQTYP    = LV_DDVALU.
          GS_OUTTAB-RQTYP_NM = LV_DDTEXT.

*         RQTYP이 '1', '2', '3') 인경우 BUY-SELL = 'B'만 가능
          CASE GS_OUTTAB-RQTYP.
            WHEN '1' OR '2' OR '3'.
              CLEAR : LV_DDVALU, LV_DDTEXT.
              LV_DDVALU = 'B'.
              CALL FUNCTION 'DOMAIN_VALUE_GET'
                EXPORTING
                  I_DOMNAME  = 'ZBY_SL'
                  I_DOMVALUE = LV_DDVALU
                IMPORTING
                  E_DDTEXT   = LV_DDTEXT
                EXCEPTIONS
                  NOT_EXIST  = 1
                  OTHERS     = 2.
              GS_OUTTAB-BY_SL    = LV_DDVALU.
              GS_OUTTAB-BY_SL_NM = LV_DDTEXT.
              MODIFY GT_OUTTAB FROM GS_OUTTAB
              INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING RQTYP RQTYP_NM
                                                      BY_SL BY_SL_NM.
            WHEN OTHERS.
              MODIFY GT_OUTTAB FROM GS_OUTTAB
              INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING RQTYP RQTYP_NM.
          ENDCASE.
        ENDIF.

      WHEN 'BY_SL'.
        CLEAR : LV_DDVALU, LV_DDTEXT.
        LV_DDVALU = LS_GOOD_CELLS-VALUE.
        CALL FUNCTION 'DOMAIN_VALUE_GET'
          EXPORTING
            I_DOMNAME  = 'ZBY_SL'
            I_DOMVALUE = LV_DDVALU
          IMPORTING
            E_DDTEXT   = LV_DDTEXT
          EXCEPTIONS
            NOT_EXIST  = 1
            OTHERS     = 2.
        IF LV_DDTEXT IS NOT INITIAL.
          GS_OUTTAB-BY_SL    = LV_DDVALU.
          GS_OUTTAB-BY_SL_NM = LV_DDTEXT.
          MODIFY GT_OUTTAB FROM GS_OUTTAB
            INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING BY_SL BY_SL_NM.
        ENDIF.

      WHEN 'NFKEY'.
        CLEAR : LV_DDVALU, LV_DDTEXT.
        LV_DDVALU = LS_GOOD_CELLS-VALUE.
        CALL FUNCTION 'DOMAIN_VALUE_GET'
          EXPORTING
            I_DOMNAME  = 'ZNFKEY_1'
            I_DOMVALUE = LV_DDVALU
          IMPORTING
            E_DDTEXT   = LV_DDTEXT
          EXCEPTIONS
            NOT_EXIST  = 1
            OTHERS     = 2.
        IF LV_DDTEXT IS NOT INITIAL.
          GS_OUTTAB-NFKEY    = LV_DDVALU.
          GS_OUTTAB-NFKEY_NM = LV_DDTEXT.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                                          TRANSPORTING NFKEY NFKEY_NM.
        ENDIF.

      WHEN 'EMENG'.
        CLEAR : LV_DEC.
        LV_DEC = FRAC( LS_GOOD_CELLS-VALUE ).
        IF LV_DEC IS NOT INITIAL.
*          MESSAGE S001 DISPLAY LIKE 'W'
*             WITH '요청량은 정수로 입력해야 합니다.'.
*          CLEAR : GS_OUTTAB-EMENG.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                                          TRANSPORTING EMENG.
        ENDIF.

      WHEN 'ENDMM'.
        GS_OUTTAB-ENDMM = LS_GOOD_CELLS-VALUE.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                                        TRANSPORTING ENDMM.
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

  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  CLEAR: GS_OUTTAB, GV_EXCEL_FLAG.
  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      PERFORM CHECK_DATA USING GS_OUTTAB
                               GV_EXCEL_FLAG.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
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

  DATA: LV_RSTAT TYPE ZRSTAT.    " 요청상태
  CLEAR GV_EXCEL_FLAG.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

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

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 '선물요청을 저장하시겠습니까?'
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER EQ '1'.

    LV_RSTAT = '1'. " 요청상태 : 입력
    PERFORM SAVE_REQ_DATA USING LV_RSTAT.

*   변경이력 저장
    PERFORM SAVE_CHANGE_DOC.

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
  DATA: LV_RSTAT TYPE ZRSTAT,    " 요청상태
        LV_FLAG.

  CLEAR GV_EXCEL_FLAG.

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

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

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 '선물요청을 결재요청 하시겠습니까?'
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER EQ '1'.
    CLEAR : GV_PERNR.
    CALL SCREEN 1200 STARTING AT 20 5.

    IF OK_SAVE EQ 'CANC'.
      MESSAGE S003 WITH '작업이 취소되었습니다.'.
      EXIT.
    ENDIF.

    LV_RSTAT = '2'. " 요청상태 : 승인대기
    PERFORM SAVE_REQ_DATA USING LV_RSTAT.

*   저장 및 결재요청의 DB처리가 완료된경우만
    CHECK GV_COMPLETE_SAVE = 'Y' OR GV_COMPLETE_REQ = 'Y'.

*   변경이력 저장
    PERFORM SAVE_CHANGE_DOC.

*___선물요청 메일 전송
    PERFORM SEND_EMAIL USING LV_FLAG.

*   저장시 ALV 수정불가로 변경
    PERFORM ALV_EDIT_CHANGE.

    IF LV_FLAG = 'X'.
      MESSAGE I003 WITH '결재요청 메일전송에 실패하였습니다.'.
    ENDIF.

*___간편결재 전송
    PERFORM SEND_SIMPLE_APV.

    LEAVE TO SCREEN 0.

  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DATA_SIGN

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC .
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  LOOP AT GT_ZNFT1010 INTO GS_ZNFT1010.
    CLEAR   : XGT_1011, YGT_1011, ZNFT1010, YZNFT1010.
    REFRESH : XGT_1011, YGT_1011.

    MOVE-CORRESPONDING GS_ZNFT1010 TO ZNFT1010.

    LOOP AT GT_ZNFT1011 INTO GS_ZNFT1011
                        WHERE REQNO EQ GS_ZNFT1010-REQNO.
      CLEAR : XGT_1011.

      MOVE-CORRESPONDING GS_ZNFT1011 TO XGT_1011.

      XGT_1011-KZ = 'I'.

      APPEND XGT_1011.
    ENDLOOP.

    LV_OBJECTID = GS_ZNFT1010-REQNO.
    LV_TCODE    = SY-TCODE.

    CALL FUNCTION 'ZNFT1010CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
*       PLANNED_CHANGE_NUMBER         = ' '
*       OBJECT_CHANGE_INDICATOR       = 'U'
*       PLANNED_OR_REAL_CHANGES       = ' '
*       NO_CHANGE_POINTERS            = ' '
        N_ZNFT1010   = ZNFT1010
        O_ZNFT1010   = YZNFT1010
        UPD_ZNFT1010 = 'I'
        UPD_ZNFT1011 = 'I'
      TABLES
        XZNFT1011    = XGT_1011
        YZNFT1011    = YGT_1011.
  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC

*&---------------------------------------------------------------------*
*&      Form  SAVE_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_RSTAT  text
*----------------------------------------------------------------------*
FORM SAVE_REQ_DATA USING P_RSTAT.

  DATA: LV_REQNO TYPE REQNO,
        LV_H_NO1 TYPE I,
        LV_TABIX TYPE SY-TABIX.

  DATA: LS_OUTTAB LIKE GS_OUTTAB.

  SORT GT_OUTTAB BY CONNO H_NO1.

* 문서변경이력 INTERNAL TABLE
  CLEAR   : GS_ZNFT1010, GS_ZNFT1011, GS_ZNFT1091.
  REFRESH : GT_ZNFT1010, GT_ZNFT1011, GT_ZNFT1091.

* 계약번호별로 요청번호 생성 / 항번 재조정
  CLEAR: LV_REQNO, LV_H_NO1, GS_OUTTAB, LS_OUTTAB.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_TABIX = SY-TABIX.
*   ##### HEADER #####
*   계약번호가 변경될경우 ZNFT1010 헤더 정보를 생성
    AT NEW CONNO.
*     요청번호 신규 채번
      READ TABLE GT_OUTTAB INTO LS_OUTTAB INDEX LV_TABIX.
      MOVE-CORRESPONDING LS_OUTTAB TO GS_ZNFT1010.
      IF LS_OUTTAB-REQNO IS INITIAL.
        PERFORM GET_REQUEST_NO USING LV_REQNO.
      ENDIF.

*     항번 초기화
      LV_H_NO1 = 1.
*     NFT1010 데이터 생성
      GS_ZNFT1010-BUKRS = LS_OUTTAB-BUKRS.
      GS_ZNFT1010-RQTYP = LS_OUTTAB-RQTYP.

      IF LS_OUTTAB-REQNO IS INITIAL.
        GS_ZNFT1010-REQNO = LV_REQNO.
      ENDIF.

*     저장시 : RSTAT = '1' 요청상태 = 생성
      GS_ZNFT1010-RSTAT = P_RSTAT.

*     결재요청버튼에 의한 저장인 경우
      IF LS_OUTTAB-REQNO IS INITIAL.
        GS_ZNFT1010-ERNAM = SY-UNAME.
        GS_ZNFT1010-ERDAT = SY-DATLO.
        GS_ZNFT1010-ERZET = SY-TIMLO.
      ELSE.
        SELECT SINGLE ERNAM ERDAT ERZET
               INTO (GS_ZNFT1010-ERNAM,
                     GS_ZNFT1010-ERDAT,
                     GS_ZNFT1010-ERZET)
          FROM ZNFT1010
         WHERE REQNO EQ GS_ZNFT1010-REQNO.
      ENDIF.

      GS_ZNFT1010-AENAM = SY-UNAME.
      GS_ZNFT1010-AEDAT = SY-DATLO.
      GS_ZNFT1010-AEZET = SY-TIMLO.

      APPEND GS_ZNFT1010 TO GT_ZNFT1010.

      IF P_RSTAT EQ '2'.
*       요청자에 대한 승인이력관리 데이터 생성
        IF LV_REQNO IS NOT INITIAL.
          GS_ZNFT1091-NFNUM = LV_REQNO.
        ELSE.
          GS_ZNFT1091-NFNUM = LS_OUTTAB-REQNO.
        ENDIF.

        GS_ZNFT1091-CONSQ = '1'.
        GS_ZNFT1091-CONGB = '2'.
        GS_ZNFT1091-BUKRS = LS_OUTTAB-BUKRS.
        GS_ZNFT1091-PERNR = GV_PERNR.
        GS_ZNFT1091-USRID = SY-UNAME.
        GS_ZNFT1091-CONST = 'B'.
        GS_ZNFT1091-ERDAT = SY-DATLO.
        GS_ZNFT1091-ERZET = SY-TIMLO.
        GS_ZNFT1091-ERNAM = SY-UNAME.
        GS_ZNFT1091-AEDAT = SY-DATLO.
        GS_ZNFT1091-AEZET = SY-TIMLO.
        GS_ZNFT1091-AENAM = SY-UNAME.
        APPEND GS_ZNFT1091 TO GT_ZNFT1091.
      ENDIF.

*     저장결과 메시지 생성 : GV_RNT_MSG
      IF LV_TABIX EQ 1.
        IF P_RSTAT EQ '1'.
          GV_RNT_MSG = LV_REQNO.
        ELSE.
          IF LS_OUTTAB-REQNO IS INITIAL.
            GV_RNT_MSG = LV_REQNO.
          ELSE.
            GV_RNT_MSG = LS_OUTTAB-REQNO.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDAT.

    AT LAST.
      IF P_RSTAT EQ '1'.
        CONCATENATE '선물요청번호 : ' GV_RNT_MSG ' - '
                    LV_REQNO '까지 저장되었습니다.'
               INTO GV_RNT_MSG.
      ELSE.
        READ TABLE GT_OUTTAB INTO LS_OUTTAB INDEX LV_TABIX.
        IF LS_OUTTAB-REQNO IS INITIAL.
          CONCATENATE '선물요청번호 : ' GV_RNT_MSG ' - '
                      LV_REQNO '까지 저장되었습니다.'
                 INTO GV_RNT_MSG.
        ELSE.
          CONCATENATE '선물요청번호 : ' GV_RNT_MSG ' - '
                      LS_OUTTAB-REQNO '까지 결재요청되었습니다.'
                 INTO GV_RNT_MSG.
        ENDIF.
      ENDIF.
    ENDAT.

    ADD 1 TO LV_H_NO1.

*   ##### ITEM #####
*   ZNFT1011 데이터 생성
    MOVE-CORRESPONDING GS_OUTTAB TO GS_ZNFT1011.

*   결재요청버튼에 의한 저장인 경우
    IF GS_OUTTAB-REQNO IS INITIAL.
      GS_ZNFT1011-REQNO = LV_REQNO.
      GS_ZNFT1011-ERNAM = SY-UNAME.
      GS_ZNFT1011-ERDAT = SY-DATLO.
      GS_ZNFT1011-ERZET = SY-TIMLO.
    ELSE.
      SELECT SINGLE ERNAM ERDAT ERZET
             INTO (GS_ZNFT1011-ERNAM,
                   GS_ZNFT1011-ERDAT,
                   GS_ZNFT1011-ERZET)
        FROM ZNFT1011
       WHERE REQNO EQ GS_ZNFT1011-REQNO
         AND H_NO1 EQ GS_ZNFT1011-H_NO1.
    ENDIF.

    GS_ZNFT1011-H_NO1 = LV_H_NO1 - 1.
    GS_ZNFT1011-AENAM = SY-UNAME.
    GS_ZNFT1011-AEDAT = SY-DATLO.
    GS_ZNFT1011-AEZET = SY-TIMLO.

    APPEND GS_ZNFT1011 TO GT_ZNFT1011.

    IF GS_OUTTAB-REQNO IS INITIAL.
      GS_OUTTAB-REQNO = LV_REQNO.
      GS_OUTTAB-H_NO1 = LV_H_NO1 - 1.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX
                       TRANSPORTING REQNO H_NO1.
    ENDIF.
    CLEAR: GS_OUTTAB, LS_OUTTAB, LV_TABIX.

  ENDLOOP.

  CHECK GT_OUTTAB IS NOT INITIAL.

  IF GT_ZNFT1010 IS NOT INITIAL AND GT_ZNFT1011 IS NOT INITIAL.
    MODIFY ZNFT1011 FROM TABLE GT_ZNFT1011.
    IF SY-SUBRC EQ 0.
      MODIFY ZNFT1010 FROM TABLE GT_ZNFT1010.
      IF SY-SUBRC EQ 0.
        IF P_RSTAT EQ '2'.
          MODIFY ZNFT1091 FROM TABLE GT_ZNFT1091.
          IF SY-SUBRC EQ 0.
            COMMIT WORK.
            MESSAGE GV_RNT_MSG TYPE 'S' DISPLAY LIKE'S'.
            IF P_RSTAT EQ '1'.
              GV_COMPLETE_SAVE = 'Y'.
            ELSE.
              GV_COMPLETE_REQ = 'Y'.
            ENDIF.
          ELSE.
            ROLLBACK WORK.
            IF P_RSTAT EQ '1'.
              GV_COMPLETE_SAVE = 'N'.
            ELSE.
              GV_COMPLETE_REQ = 'N'.
            ENDIF.
          ENDIF.
        ELSE.
          COMMIT WORK.
          MESSAGE GV_RNT_MSG TYPE 'S' DISPLAY LIKE'S'.
          IF P_RSTAT EQ '1'.
            GV_COMPLETE_SAVE = 'Y'.
          ELSE.
            GV_COMPLETE_REQ = 'Y'.
          ENDIF.
        ENDIF.
      ELSE.
        ROLLBACK WORK.
        IF P_RSTAT EQ '1'.
          GV_COMPLETE_SAVE = 'N'.
        ELSE.
          GV_COMPLETE_REQ = 'N'.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    MESSAGE I001 DISPLAY LIKE 'E' WITH '저장시 오류입니다.'.
  ENDIF.

ENDFORM.                    " SAVE_REQ_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_REQUEST_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_REQUEST_NO USING P_REQNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00002'
    IMPORTING
      NUMBER                  = P_REQNO
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
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_REQUEST_NO
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
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SEND_EMAIL  USING    PV_FLAG.
  DATA: RESULT_TAB  TYPE MATCH_RESULT_TAB.

  CLEAR : PV_FLAG.

  PERFORM FILL_EMAIL_CONTENTS.

  IF GV_ADDRESS IS INITIAL.
    PV_FLAG = 'X'.
    EXIT.
  ENDIF.

  TRY.
      GC_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      GC_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                            I_TYPE    = 'HTM'
                                            I_TEXT    = GT_MESSAGE
                                            I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      GC_EMAIL->SET_DOCUMENT( GC_EMAIL_BODY ).

      GF_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      GC_EMAIL->ADD_RECIPIENT( I_RECIPIENT = GF_RECEIVER
                               I_EXPRESS   = 'X' ).

      GC_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      GC_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT              = GV_SEND_RESULT ).

    CATCH CX_BCS INTO GC_EXCEPTION.
      PV_FLAG = 'X'.

  ENDTRY.

ENDFORM.                    " SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_EMAIL_CONTENTS .
  DATA: LS_MESSAGE  LIKE SOLI.

  DATA: LV_COTXT    LIKE ZNFT1000-COTXT.

*___수신자
  CLEAR : GV_ADDRESS.

  IF SY-SYSID = 'R3T'.
    GV_ADDRESS = 'jhyukim@lscns.com'.
  ELSE.
    SELECT SINGLE USRID
      INTO GV_ADDRESS
      FROM PA0105
     WHERE PERNR = GV_PERNR
       AND SUBTY = '0007'
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
  ENDIF.

  CHECK GV_ADDRESS IS NOT INITIAL.

*___메일 제목
  GV_SUBJECT = '선물요청에 대한 승인요청'.

  CLEAR   : LS_MESSAGE.
  REFRESH : GT_MESSAGE.

*___메일 내용
  PERFORM APPEND_MESSAGE USING : '<html>',
                                 '<body>',
                                 '선물요청<br>',
                                 '<br>'.

  LOOP AT GT_ZNFT1010 INTO GS_ZNFT1010.
    CLEAR : GS_ZNFT1011, LV_COTXT.

    READ TABLE GT_ZNFT1011 INTO GS_ZNFT1011
                           WITH KEY REQNO = GS_ZNFT1010-REQNO.

    SELECT SINGLE COTXT
      INTO LV_COTXT
      FROM ZNFT1000
     WHERE CONNO = GS_ZNFT1011-CONNO.

    CONCATENATE GS_ZNFT1010-REQNO '(계약명:' LV_COTXT ')<br>'
           INTO LS_MESSAGE.

    PERFORM APPEND_MESSAGE USING : LS_MESSAGE.
  ENDLOOP.

  PERFORM APPEND_MESSAGE USING : '<br>',
                                 '에 대해 승인바랍니다.',
                                 '<br>',
                                 '<br>',
                                 '감사합니다.<br>',
                                 '</body>',
                                 '</html>'.

ENDFORM.                    " FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*&      Form  APPEND_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_MESSAGE  USING    PS_MESSAGE.

  APPEND PS_MESSAGE TO GT_MESSAGE.

ENDFORM.                    " APPEND_MESSAGE
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APV.

  CLEAR : GS_ZNFT1010.
  LOOP AT GT_ZNFT1010 INTO GS_ZNFT1010.
*--- 간편결재 전송.
    PERFORM SEND_SIMPLE_APPROVAL
    USING GS_ZNFT1010-REQNO
          GS_ZNFT1010-BUKRS
          '2A'.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZNFT1010_REQNO
*&      --> GS_ZNFT1010_BUKRS
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
