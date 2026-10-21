*&---------------------------------------------------------------------*
*& Include          ZGTLER1130F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REQUEST_CAR_DISPATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REQUEST_CAR_DISPATCH .


*/ 에러 체크
*  PERFORM ERROR_CHECK_BEFORE_SHIP1.

  LOOP AT GT_ALV1 WHERE SEL = GC_X.
    APPEND  GT_ALV1  TO GT_HEADER_SEL.
  ENDLOOP.

  PERFORM GET_GRID2 TABLES GT_HEADER_SEL GT_ITEM_SEL.

  LOOP AT GT_HEADER_SEL.
    LOOP AT GT_ITEM_SEL WHERE VBELN EQ GT_HEADER_SEL-VBELN
                          AND LFIMG NE 0 .
      CLEAR GT_ALV3.
      MOVE-CORRESPONDING GT_HEADER_SEL TO GT_ALV3.
      MOVE-CORRESPONDING GT_ITEM_SEL  TO GT_ALV3.

      CLEAR : GT_ALV3-DATLT, GT_ALV3-TELF1, GT_ALV3-TELF2,
              GT_ALV3-LOGI_STATUS.

      SELECT SINGLE DATLT TELF1  TELF2
        INTO (GT_ALV3-DATLT ,GT_ALV3-TELF1, GT_ALV3-TELF2)
        FROM KNA1 WHERE KUNNR EQ GT_ALV3-KUNNR.
*->2023.07.27 ZITCS4HDEV01 - 추가
      PERFORM GET_DATLT USING 'C' GT_ALV3-KUNNR GT_ALV3-DATLT.
*<-
      GT_ALV3-WADAT  = SY-DATUM.
      GT_ALV3-WAUHR  = SY-UZEIT.

      PERFORM GET_ADDRESS_AVL3_2 USING GT_ALV3-ORT01
                              CHANGING GT_ALV3-ORT01.

*      CALL FUNCTION 'ISHMED_ROUND_TIME' "30분 단위정각
*        EXPORTING
*          I_ROUND_MINUTE = 30
*        CHANGING
*          C_DATE         = GT_ALV3-WADAT
*          C_TIME         = GT_ALV3-WAUHR.

      PERFORM ISHMED_ROUND_TIME USING 30
                                      GT_ALV3-WADAT
                                      GT_ALV3-WAUHR.

      GT_ALV3-GEWEI  = 'KG'.
      GT_ALV3-NO_CAR = 1.


      READ TABLE GT_0105 WITH KEY VBELN = GT_ALV3-VBELN
                                  POSNR = GT_ALV3-POSNR .
      IF SY-SUBRC EQ 0 .
        IF GT_0105-ORD_NUM IS NOT INITIAL .
*          GT_ALV3-STATUS      = GT_0105-STATUS.
*          GT_ALV3-ORD_NUM     = GT_0105-ORD_NUM.
*          GT_ALV3-ORT01       = GT_0105-ORT01.
          MOVE-CORRESPONDING  GT_0105 TO  GT_ALV3.
          GT_ALV3-LOGI_STATUS = ICON_LED_GREEN.
          READ TABLE F4_TAB WITH KEY FVAL = GT_ALV3-TRK_TON.
          IF SY-SUBRC EQ 0.
            CONCATENATE F4_TAB-FVAL ` ` F4_TAB-FNAM
               INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.
          ENDIF.

        ELSE.
          CLEAR : GT_ALV3-STATUS.
        ENDIF.

        IF GT_0105-LOGI_STATUS EQ 'F'.
          GT_ALV3-LOGI_STATUS = ICON_LED_RED.
        ENDIF.
      ELSE.
        CLEAR : GT_ALV3-STATUS.
      ENDIF.


      IF GT_ALV3-LOGI_STATUS IS INITIAL  OR
         GT_0105-LOGI_STATUS EQ 'C'  .
        GT_ALV3-LOGI_STATUS = ICON_LED_YELLOW .
        CLEAR GT_ALV3-ORD_NUM.
      ENDIF.

      CLEAR : GT_ALV3-STRAS.
      APPEND GT_ALV3.
    ENDLOOP.

  ENDLOOP.


  SORT GT_ALV3 BY KUNNR ARKTX.

  GS_RECEIVER-MCHK3       = GC_X.
  GS_RECEIVER-MCHK3_REF1  = GC_X.
  GS_RECEIVER-MCHK3_REF2  = GC_X.

  GV_TITLE    = '주문배차'.
  GT_EXCL3    = 'MAP_VLN' .  APPEND GT_EXCL3.
  GT_EXCL3    = 'MAP_CAN' .  APPEND GT_EXCL3.
  GT_EXCL3    = 'GATING' .  APPEND GT_EXCL3.
  GF_EDIT     = GC_X.
  GF_ALV_FIRST = GC_X.


  ST_ATTACH_KEY-ICON_TEXT = '자료첨부'.
  ST_ATTACH_KEY-TEXT      = '관련자료첨부'.

  CLEAR GV_ATTACH_KEY.

  CALL SCREEN '400' STARTING AT 1  1.

  CLEAR :   GT_HEADER_SEL, GT_HEADER_SEL[],
            GT_ITEM_SEL  , GT_ITEM_SEL[],
            GT_ALV3      , GT_ALV3[],
            GT_ALV4      , GT_ALV4[],
            GS_SENDER    , GS_RECEIVER,
            GV_CALLBACK  , GV_MOBILE,
            GV_CONTENT   , GV_STATUS  ,
            GV_PERNR_SH_T, GV_TDLNR_SH_T,
            GT_SMS       , GT_SMS[],
            GT_SMS_1     , GT_SMS_1[],
            GT_EXCL3     , GT_EXCL3[],
            GV_POSNR.

ENDFORM.                    " REQUEST_CAR_DISPATCH
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_grid3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS_GRID3 .

* FIELD발췌
  REFRESH: GT_LVC3[].

  PERFORM FILL_FIELD_CATALOGS3
          USING:

          'S' 'FIELDNAME'   'ATTACH_ICON',
          ' ' 'COLTEXT'     '파일',
          ' ' 'JUST'        'C',
          ' ' 'KEY'         'X',
          ' ' 'ICON'        'X',
          ' ' 'COL_OPT'     'X',
          'E' 'OUTPUTLEN'   '',

          'S' 'FIELDNAME'   'LOGI_STATUS',
          ' ' 'COLTEXT'     '상태',
          ' ' 'JUST'        'C',
          ' ' 'KEY'         'X',
          ' ' 'ICON'        'X',
          ' ' 'COL_OPT'     'X',
          'E' 'OUTPUTLEN'   '',



          'S' 'FIELDNAME'   'POSNR_CHK',
          ' ' 'COLTEXT'     '품목공통',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'EDIT'         GF_EDIT,
          ' ' 'COL_OPT'     'X',
          ' ' 'CHECKBOX'    'X',
          'E' 'OUTPUTLEN'   ''.


  IF GF_NREQUEST IS  INITIAL.
    PERFORM FILL_FIELD_CATALOGS3
        USING:

          'S' 'FIELDNAME'   'VBELN',
          ' ' 'COLTEXT'     '납품문서',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'REF_TABLE'   'ZLET0105',
          ' ' 'REF_FIELD'   'VBELN',
          ' ' 'F4AVAILABL'   'X',
          ' ' 'EDIT'        GF_MAPPING,
          'E' 'OUTPUTLEN'   '',


          'S' 'FIELDNAME'   'STATUS',
          ' ' 'COLTEXT'     '합짐/분할',
          ' ' 'JUST'        'C',
          ' ' 'KEY'         'X',
          'E' 'OUTPUTLEN'   '8'.
  ENDIF.

  PERFORM FILL_FIELD_CATALOGS3
      USING:
        'S' 'FIELDNAME'   'ORT01',
        ' ' 'COLTEXT'     '인도처주소',
        ' ' 'JUST'        'L',
        ' ' 'KEY'         'X',
        ' ' 'EDIT'        GF_EDIT,
        ' ' 'COL_OPT'     'X',
        'E' 'OUTPUTLEN'    '100',

        'S' 'FIELDNAME'   'KUNNR_T',
        ' ' 'COLTEXT'     '납품처',
        ' ' 'JUST'        'L',
        ' ' 'KEY'         'X',
        ' ' 'EDIT'        GF_EDIT,
        ' ' 'COL_OPT'     'X',
        'E' 'OUTPUTLEN'   '30'.


  IF GF_NREQUEST IS NOT INITIAL.
    PERFORM FILL_FIELD_CATALOGS3
        USING:
          'S' 'FIELDNAME'   'WERKS',
          ' ' 'COLTEXT'     '플랜트',
          ' ' 'REF_TABLE'    'T001W',
          ' ' 'REF_FIELD'    'WERKS',
          ' ' 'CHECKTABLE'   'T001W',
          ' ' 'EDIT'         GF_EDIT,
          'E' 'OUTPUTLEN'   '6'.

  ENDIF.

  PERFORM FILL_FIELD_CATALOGS3
      USING:
        'S' 'FIELDNAME'   'TRK_TON_T',
        ' ' 'COLTEXT'     '차종(톤수)',
        ' ' 'JUST'        'L',
        ' ' 'DRDN_HNDL'   '1',
*          ' ' 'DRDN_ALIAS'  'X',
        ' ' 'EDIT'         GF_EDIT,
        'E' 'OUTPUTLEN'   '15',



        'S' 'FIELDNAME'   'TBRGEW',
        ' ' 'COLTEXT'     '총중량(kg)',
        ' ' 'JUST'        'L',
        ' ' 'EDIT'        GF_EDIT,
        ' ' 'NO_ZERO'     'X',
*          ' ' 'QUANTITY'    'KG',
*          ' ' 'DECIMALS_O'   '0',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'GROES',
        ' ' 'COLTEXT'     '단위포장SIZE',
        ' ' 'JUST'        'L',
        ' ' 'EDIT'        GF_EDIT,
        'E' 'OUTPUTLEN'   '12',


        'S' 'FIELDNAME'   'WADAT',
        ' ' 'COLTEXT'     '출고일',
        ' ' 'JUST'        'L',
        ' ' 'EDIT'        GF_EDIT,
        'E' 'OUTPUTLEN'   '10',


        'S' 'FIELDNAME'   'WAUHR',
        ' ' 'COLTEXT'     '출하예정시간',
        ' ' 'JUST'        'L',
        ' ' 'KEY'         ' ',
        ' ' 'edit_mask'   '__:__',
        ' ' 'EDIT'        GF_EDIT,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'DAY_CHK',
        ' ' 'COLTEXT'     '당일도착',
        ' ' 'JUST'        'L',
        ' ' 'CHECKBOX'    'X',
        ' ' 'EDIT'        GF_EDIT,
        'E' 'OUTPUTLEN'   '8',


        'S' 'FIELDNAME'   'ARKTX',
        ' ' 'COLTEXT'     '제품명',
        ' ' 'JUST'        'L',
        ' ' 'EDIT'        GF_EDIT,
        ' ' 'COL_OPT'     'X',
        'E' 'OUTPUTLEN'   '100',


        'S'  'FIELDNAME'   'NOTE',
        ' '  'COLTEXT'     '특이사항',
        ' '  'JUST'        'L',
        ' '  'EDIT'         GF_EDIT,
        ' '  'COL_OPT'      'X',
        'E'  'OUTPUTLEN'  '100',


        'S' 'FIELDNAME'   'ORD_NUM',
        ' ' 'COLTEXT'     'Logi ID',
        ' ' 'JUST'        'L',
        ' ' 'EDIT'        GF_MAPPING,
        'E' 'OUTPUTLEN'   '10'.

  IF GF_NREQUEST IS NOT INITIAL.
    PERFORM FILL_FIELD_CATALOGS3
        USING:
          'S'  'FIELDNAME'   'ZROUTE',
          ' '  'COLTEXT'     '운송경로',
          ' '  'JUST'        'C',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '10',



          'S'  'FIELDNAME'   'ZDEPARTURE',
          ' '  'COLTEXT'     '출발지',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '10',




          'S'  'FIELDNAME'   'ZDEPARTURET',
          ' '  'COLTEXT'     '출발지명',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '20',


          'S'  'FIELDNAME'   'ZARRIVAL',
          ' '  'COLTEXT'     '도착지',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '10',




          'S'  'FIELDNAME'   'ZARRIVALT',
          ' '  'COLTEXT'     '도착지명',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '20',


          'S'  'FIELDNAME'   'PRICE',
          ' '  'COLTEXT'     '금액',
          ' '  'JUST'        'L',
          ' '  'CFIELDNAME'   'WAERS',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '12',

          'S'  'FIELDNAME'   'WAERS',
          ' '  'COLTEXT'      '통화',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '5',


          'S'  'FIELDNAME'   'IV_NO',
          ' '  'COLTEXT'     '통문번호',
          ' '  'JUST'        'L',
          ' '  'COL_OPT'      'X',
          'E'  'OUTPUTLEN'   '10'.


  ENDIF.



  IF GF_MAPPING IS NOT INITIAL.
    PERFORM FILL_FIELD_CATALOGS3
          USING:
          'S' 'FIELDNAME'   'VBELN_PT',
          ' ' 'COLTEXT'     '비고',
          ' ' 'JUST'        'L',
          ' ' 'REF_TABLE'   'ZLET0105',
          ' ' 'REF_FIELD'   'VBELN',
          ' ' 'F4AVAILABL'   'X',
          'E' 'OUTPUTLEN'   ''.
  ENDIF.


  IF GF_NREQUEST IS NOT INITIAL.

    PERFORM FILL_FIELD_CATALOGS3
        USING:
            'S' 'FIELDNAME'   'DRIVER_NM',
            ' ' 'COLTEXT'     '운전자명',
            ' ' 'JUST'        'C',
            ' ' 'COL_OPT'     'X',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'DRIVER_TELNO',
            ' ' 'COLTEXT'     '운전자전화번호',
            ' ' 'COL_OPT'     'X',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '20',

            'S' 'FIELDNAME'   'TRUCK_NO',
            ' ' 'COLTEXT'     '차량번호',
            ' ' 'COL_OPT'     'X',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10'.

  ENDIF.

ENDFORM.                    " set_field_catalogs_grid3
" F4_GV_PERNR_SH INPUT*&------------------------------------------------
"---------------------*
*&      Form  SET_DROPDOWN2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DROPDOWN3 .


  DATA: LT_DROPDOWN TYPE LVC_T_DRAL,
        LS_DROPDOWN TYPE LVC_S_DRAL.

  CLEAR: LS_DROPDOWN, LT_DROPDOWN, LT_DROPDOWN[].

  LOOP AT F4_TAB .
    LS_DROPDOWN-HANDLE = '1'.

    CONDENSE : F4_TAB-FVAL NO-GAPS,
               F4_TAB-FNAM NO-GAPS.
    CONCATENATE F4_TAB-FVAL ` ` F4_TAB-FNAM
                INTO LS_DROPDOWN-VALUE SEPARATED BY SPACE.

    LS_DROPDOWN-INT_VALUE = F4_TAB-FVAL.
    APPEND LS_DROPDOWN TO LT_DROPDOWN.
  ENDLOOP.

  CALL METHOD GRID3->SET_DROP_DOWN_TABLE
    EXPORTING
      IT_DROP_DOWN_ALIAS = LT_DROPDOWN.

ENDFORM.                    " SET_DROPDOWN2
*&---------------------------------------------------------------------*
*&      Form  SET_DISPATCH_MIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DISPATCH_MIX .

  DATA : LV_CNT(3)      TYPE N, LV_CNT_NEXT(3) TYPE N .
  DATA : LV_TRK_TON_T LIKE GT_ALV3-TRK_TON_T,
         LV_WADAT     LIKE GT_ALV3-WADAT,
         LV_WAUHR     LIKE GT_ALV3-WAUHR,
         LV_DAY_CHK   LIKE GT_ALV3-DAY_CHK,
         LV_ADDRESS   LIKE GT_ALV3-ADDRESS.
*         LV_ORT01     LIKE GT_ALV3-ORT01,
*         LV_ORT01_CHK.
*         LV_NOTE      LIKE GT_ALV3-NOTE.

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.


*- Check 로직
  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_ROWS LINES SY-TFILL.

  IF SY-TFILL < 2.
    MESSAGE I001 WITH '합짐은 두라인 이상 가능합니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_ALV3  WHERE  STATUS(4) EQ 'MIX#'.
    LV_CNT = GT_ALV3-STATUS+4(3) .
    IF LV_CNT > LV_CNT_NEXT .
      LV_CNT_NEXT = LV_CNT.
    ENDIF.
  ENDLOOP.

  LV_CNT_NEXT = LV_CNT_NEXT + 1.

  LOOP AT GT_ROWS.
    IF SY-TABIX EQ 1.
      READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
      LV_TRK_TON_T  = GT_ALV3-TRK_TON_T.
      LV_WADAT      = GT_ALV3-WADAT.
      LV_WAUHR      = GT_ALV3-WAUHR.
      LV_DAY_CHK    = GT_ALV3-DAY_CHK.
      PERFORM GET_ADDRESS_ALV3_1 USING    GT_ALV3-ORT01
                               CHANGING LV_ADDRESS .

    ENDIF.

    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.

    IF GT_ALV3-STATUS IS NOT INITIAL.
      MESSAGE I001 WITH '이미 합짐/분할된 라인이 있습니다.'.
      RETURN.
    ENDIF.

    PERFORM GET_ADDRESS_ALV3_1   USING GT_ALV3-ORT01
                             CHANGING GT_ALV3-ADDRESS .

    IF GT_ALV3-ADDRESS NE LV_ADDRESS.
      MESSAGE I001 WITH '주소가 우편번호를 제외한'
      '첫번째 단어와 동일해야 합니다'.
      RETURN.
    ENDIF.

    IF GT_ALV3-TRK_TON_T NE LV_TRK_TON_T.
      MESSAGE I001 WITH '차종(톤수)은 동일해야 합니다.  '.
      RETURN.
    ENDIF.

    IF GT_ALV3-TRK_TON_T  IS INITIAL.
      MESSAGE I001 WITH '차종(톤수)를 동일하게 입력해주십시오'.
      RETURN.
    ENDIF.

    IF GT_ALV3-NO_CAR NE 1.
      MESSAGE I001 WITH '차량대수는 1대로 동일히야 합니다.'.
      RETURN.
    ENDIF.

    IF GT_ALV3-WADAT      NE LV_WADAT OR
       GT_ALV3-DAY_CHK    NE LV_DAY_CHK.
      MESSAGE I001 WITH '출고일은 동일해야 합니다. '.
      RETURN.
    ENDIF.

*--> [기능개선 298596] 예정시간은 첫번째 행값으로 자동처리 대체
*    IF GT_ALV3-WAUHR NE LV_WAUHR.
*      MESSAGE I001 WITH '출고예정시간은 동일해야 합니다. '.
*      RETURN.
*    ENDIF.
*<-- [기능개선 298596] 예정시간은 첫번째 행값으로 자동처리 대체

  ENDLOOP .



  LOOP AT GT_ROWS.
    CONCATENATE 'MIX#' LV_CNT_NEXT INTO GT_ALV3-STATUS .
    CONDENSE GT_ALV3-STATUS NO-GAPS.

*--> [기능개선 298596] 출고시간과 비고는 첫번째항으로 일괄입력
    GT_ALV3-WAUHR = LV_WAUHR.
*<-- [기능개선 298596] 출고시간과 비고는 첫번째항으로 일괄입력

    MODIFY GT_ALV3 INDEX  GT_ROWS-INDEX
                    TRANSPORTING STATUS WAUHR.
  ENDLOOP.


  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.
ENDFORM.                    " SET_DISPATCH_MIX
*&---------------------------------------------------------------------*
*&      Form  SET_DISPATCH_MIX_CANC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DISPATCH_MIX_CANC .

  DATA : LV_STATUS LIKE GT_ALV3-STATUS.

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.

  DATA : LV_CNT(3), LV_CNT_NEXT(3) .

  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    LV_STATUS =  GT_ALV3-STATUS .
    IF LV_STATUS(3) EQ 'MIX'.
      CLEAR GT_ALV3-STATUS .
      MODIFY GT_ALV3 TRANSPORTING STATUS
                     WHERE STATUS EQ LV_STATUS .
    ENDIF.
  ENDLOOP .

  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.

ENDFORM.                    " SET_DISPATCH_MIX_CANC

*&---------------------------------------------------------------------*
*&      Form  SET_DISPATCH_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DISPATCH_DIV .


  DATA : LV_CNT(3), LV_CNT_NEXT(3) , LV_CNT_NEXT1(3),
         LV_INDEX  LIKE SY-INDEX.


  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_ROWS LINES SY-TFILL.

  IF SY-TFILL NE 1.
    MESSAGE I001 WITH '분할은 한라인만 가능합니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_ALV3  WHERE  STATUS(4) EQ 'DIV#'.
    LV_CNT = GT_ALV3-STATUS+4(1) .
    IF LV_CNT > LV_CNT_NEXT .
      LV_CNT_NEXT = LV_CNT.
    ENDIF.
  ENDLOOP.

  LV_CNT_NEXT = LV_CNT_NEXT + 1.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF GT_ALV3-STATUS(3) EQ 'MIX'.
      MESSAGE I001 WITH '합짐된 라인입니다.'.
      RETURN.
    ENDIF.

    IF GT_ALV3-STATUS IS INITIAL.
      IF LV_CNT_NEXT > 9.
        MESSAGE I001 WITH '분할은 최대 9번가능합니다. '.
        RETURN.
      ENDIF.
      CONCATENATE 'DIV#' LV_CNT_NEXT '-1' INTO GT_ALV3-STATUS .
      CONDENSE GT_ALV3-STATUS NO-GAPS.
      MODIFY GT_ALV3 INDEX  GT_ROWS-INDEX
                    TRANSPORTING STATUS .

      CONCATENATE 'DIV#' LV_CNT_NEXT '-2' INTO GT_ALV3-STATUS .
      CONDENSE GT_ALV3-STATUS NO-GAPS.
      LV_INDEX  = GT_ROWS-INDEX + 1.
    ELSE.

      LOOP AT GT_ALV3  WHERE  STATUS(6) EQ GT_ALV3-STATUS(6).
        LV_INDEX = SY-TABIX + 1.
        LV_CNT = GT_ALV3-STATUS+6(3) .
        IF LV_CNT > LV_CNT_NEXT1 .
          LV_CNT_NEXT1 = LV_CNT.
        ENDIF.
      ENDLOOP.

      LV_CNT_NEXT1 = LV_CNT_NEXT1 + 1.

      IF LV_CNT_NEXT1 > 9.
        MESSAGE I001 WITH '분할은 최대 9번가능합니다. '.
        RETURN.
      ENDIF.
      CONCATENATE GT_ALV3-STATUS(6) LV_CNT_NEXT1 INTO GT_ALV3-STATUS .
      CONDENSE GT_ALV3-STATUS NO-GAPS.
    ENDIF.

    CLEAR GT_ALV3-TBRGEW.

    INSERT GT_ALV3 INDEX LV_INDEX.
  ENDLOOP .

  CALL METHOD GRID3->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = GT_ROWS[].


  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.
ENDFORM.                    " SET_DISPATCH_DIV
*&---------------------------------------------------------------------*
*&      Form  SET_DISPATCH_DIV_CANC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DISPATCH_DIV_CANC .

  DATA : LT_ALV3_DEL LIKE TABLE OF GT_ALV3 WITH HEADER LINE,
         LT_ALV3     LIKE TABLE OF GT_ALV3 WITH HEADER LINE.
  DATA : LV_STATUS LIKE GT_ALV3-STATUS,
         LV_TBRGEW LIKE GT_ALV3-TBRGEW,
         LV_TABIX  LIKE SY-TABIX.

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.

  DATA : LV_CNT(3) .

  CHECK GV_CHK IS INITIAL.
  CLEAR : LT_ALV3_DEL, LT_ALV3_DEL[] ,
          LT_ALV3, LT_ALV3[] .

  MOVE GT_ALV3[] TO  LT_ALV3[].

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    APPEND GT_ALV3 TO LT_ALV3_DEL.
  ENDLOOP.

  LOOP AT LT_ALV3_DEL WHERE STATUS(3) EQ 'DIV'.
    DELETE GT_ALV3 WHERE STATUS EQ  LT_ALV3_DEL-STATUS .
  ENDLOOP .


  SORT LT_ALV3_DEL BY STATUS.

  LOOP AT LT_ALV3_DEL WHERE STATUS(3) EQ 'DIV'.

    IF LT_ALV3_DEL-STATUS(5) <> LV_STATUS.
      CLEAR LV_CNT.
      LOOP AT GT_ALV3 WHERE STATUS(5) EQ LT_ALV3_DEL-STATUS(5).
        LV_CNT = LV_CNT + 1.
      ENDLOOP.

      IF LV_CNT EQ 1.
        CLEAR : GT_ALV3-STATUS.
        LV_STATUS = LT_ALV3_DEL-STATUS(5).
        MODIFY  GT_ALV3 TRANSPORTING STATUS
                        WHERE STATUS(5) EQ LT_ALV3_DEL-STATUS(5).

      ENDIF.

      IF LV_CNT IS INITIAL.
        LV_STATUS = LT_ALV3_DEL-STATUS(5).
        LOOP AT LT_ALV3 WHERE STATUS(5) EQ LV_STATUS .
          IF LV_TABIX IS INITIAL.
            LV_TABIX  = SY-TABIX.
          ENDIF.
          DELETE LT_ALV3.
        ENDLOOP .

        CLEAR LT_ALV3_DEL-STATUS .
        INSERT LT_ALV3_DEL INTO GT_ALV3 INDEX LV_TABIX.
        INSERT LT_ALV3_DEL INTO LT_ALV3 INDEX LV_TABIX.
        CLEAR LV_TABIX.
      ENDIF.

    ENDIF.

  ENDLOOP.


  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.

ENDFORM.                    " SET_DISPATCH_DIV_CANC
*&---------------------------------------------------------------------*
*&      Form  GET_SELECT_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SELECT_ROWS  TABLES PT_ROWS TYPE LVC_T_ROW
                      USING PV_GRID TYPE REF TO CL_GUI_ALV_GRID
                      CHANGING PV_CHK.

  DATA : LV_LINE  TYPE I,
         LV_EBELN LIKE EKKO-EBELN.

  CLEAR : PV_CHK, PT_ROWS, PT_ROWS[].

*--화면상 선택한 라인을 불러옴
  CALL METHOD PV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = PT_ROWS[].

  IF PT_ROWS[] IS INITIAL.
    PV_CHK =  GC_X.
    MESSAGE I100 .
  ENDIF.

ENDFORM.                    "GET_SELECT_ROWS
*&---------------------------------------------------------------------*
*&      Form  REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ALV_GRID3  text
*----------------------------------------------------------------------*
FORM REFRESH_TABLE_DISPLAY  USING  P_GRID TYPE REF TO CL_GUI_ALV_GRID.


  CALL METHOD P_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = GC_X
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh



ENDFORM.                    " REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  SEND_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MSG_TO_TDLNR .

  DATA : LT_0105   TYPE TABLE OF ZLET0105 WITH HEADER LINE,
         LV_NUM(3) TYPE N.

  CLEAR  : GT_SMS     , GT_SMS[]   ,
           GT_SMS_1   , GT_SMS_1[] ,
           GT_ALV3_SEL, GT_ALV3_SEL[].

  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING   GRID3
                        CHANGING   GV_CHK.

  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF SY-SUBRC EQ  0.
      GT_ALV3-ROW_INDEX  = GT_ROWS-INDEX.
      APPEND GT_ALV3  TO GT_ALV3_SEL.
    ENDIF.
  ENDLOOP.

  PERFORM CHECK_INPUT_DATA_ALV3 .
  CHECK GV_CHK IS INITIAL.

  IF GF_EXIST  IS INITIAL.
    PERFORM POPUP_TO_CONFIRM
      USING '운송사 배차요청'
      '선택한 내용을 운송사에게 요청하시겠습니까?'
             '1'     GV_ANSWER.
  ELSE.

    IF OK_CODE EQ 'SEND_RE'.
      PERFORM POPUP_TO_CONFIRM
        USING '운송사 배차변경요청'
        '기전송된 내역을 변경요청 하시겠습니까?'
               '1'     GV_ANSWER.

    ELSE.
      PERFORM POPUP_TO_CONFIRM
        USING '운송사 배차(재)요청'
        '기전송된 내역이있습니다. 요청하시겠습니까?'
               '1'     GV_ANSWER.

    ENDIF.
  ENDIF.

  CHECK GV_ANSWER EQ '1'.
  CLEAR : GV_TIMELINE, GF_LOGI_ERR.
  CONCATENATE SY-DATUM SY-UZEIT INTO GV_TIMELINE.


  COMMIT WORK AND WAIT. "첨부파일 DB저장
  PERFORM SEND_MSG_TO_TDLNT_BY_LOGISPOT. "[기능개선309608] 로지스팟 연동

*  IF SY-DATUM <= '20200301'.
*    PERFORM SET_DATA_SEND_MSG.
*    PERFORM SEND_SMS .
*  ENDIF.
*
*  PERFORM SEND_MAIL.

  PERFORM SET_DATA_SEND_MSG.


  IF GS_RECEIVER-MCHK1 IS NOT INITIAL OR
     GS_RECEIVER-MCHK3  IS NOT INITIAL.
    PERFORM SEND_SMS .
  ENDIF.

  IF GS_RECEIVER-MCHK2 IS NOT INITIAL OR
     GS_RECEIVER-MCHK3 IS NOT INITIAL.
    PERFORM SEND_MAIL.
  ENDIF.


  LOOP AT GT_ALV3_SEL.
    MOVE-CORRESPONDING GT_ALV3_SEL TO LT_0105 .

    IF GT_ALV3_SEL-ADD_LINE_CHK IS NOT INITIAL.
      LV_NUM = LV_NUM + 1.
      CONCATENATE 'MAP#'  LV_NUM INTO LT_0105-VBELN .
      CONDENSE LT_0105-VBELN  NO-GAPS.
    ENDIF.

    LT_0105-TIMELINE    = GV_TIMELINE.
    LT_0105-SEND_STATUS = GV_STATUS .
    LT_0105-PERNR      = GS_SENDER-PERNR .
    LT_0105-TDLNR      = GS_RECEIVER-LIFNR.
    LT_0105-TPLST      = WA-TPLST .
    LT_0105-CALLBACK   = GS_SENDER-TEL_NO.

    LT_0105-MOBILE     = GS_RECEIVER-TEL_NO.
    LT_0105-MOBILE_REF1     = GS_RECEIVER-TEL_NO_REF1.
    LT_0105-MOBILE_REF2     = GS_RECEIVER-TEL_NO_REF2.

    LT_0105-CONTENT    = GV_CONTENT_CLT.

    LT_0105-EMAIL_SDR  = GS_SENDER-EMAIL.
    LT_0105-EMAIL_RCR  = GS_RECEIVER-EMAIL.
    LT_0105-EMAIL_REF1 = GS_RECEIVER-EMAIL_REF1.
    LT_0105-EMAIL_REF2 = GS_RECEIVER-EMAIL_REF2.

    IF GT_ALV3_SEL-ORD_NUM IS NOT INITIAL.
      LT_0105-LOGI_STATUS = 'S'.

      IF OK_CODE EQ 'SEND_RE' AND  "변경 실패일경우
         GT_ALV3_SEL-LOGI_STATUS EQ ICON_LED_RED.
        CLEAR LT_0105 .
        CONTINUE.
      ENDIF.

      "변경 성공일 경우 이전 생성기록 삭제 후 저장
      IF OK_CODE EQ 'SEND_RE' AND
         GT_ALV3_SEL-LOGI_STATUS EQ ICON_LED_GREEN.
        DELETE FROM ZLET0105 WHERE ORD_NUM EQ GT_ALV3_SEL-ORD_NUM.
        COMMIT WORK AND WAIT.
      ENDIF.

      LT_0105-ORD_NUM = GT_ALV3_SEL-ORD_NUM.
    ELSE.
      LT_0105-LOGI_STATUS = 'F'.
      CLEAR LT_0105-ORD_NUM.
    ENDIF.

    APPEND LT_0105 .
  ENDLOOP.

  IF LT_0105[] IS NOT INITIAL.
    CALL FUNCTION 'ZMM_SET_CBO_DATE_SINGLE'
      TABLES
        PT_DATA = LT_0105.

    MODIFY ZLET0105 FROM TABLE LT_0105.
  ENDIF.

  IF SY-SUBRC EQ 0.
    IF GF_LOGI_ERR IS INITIAL.
      "1회성일 경우 비활성화 처리
      IF ZLET0210 IS NOT INITIAL AND ZLET0210-CHK_SPOT IS NOT INITIAL.
        UPDATE ZLET0210 SET CHK_INACT = 'X'
                      WHERE BUKRS  EQ ZLET0210-BUKRS
                        AND ZROUTE EQ ZLET0210-ZROUTE
                        AND TDLNR  EQ ZLET0210-TDLNR
                        AND DATAB  EQ ZLET0210-DATAB
                        AND DATBI  EQ ZLET0210-DATBI
                        AND CHK_INACT EQ SPACE.

      ENDIF.

      MESSAGE I001 WITH '정상 전송되었습니다. '.
    ELSE.
      MESSAGE I001 WITH '일부(전부) 전송실패한 내역이 있습니다.'.
    ENDIF.

    CLEAR : GT_ALV1 , GT_ALV1[].
    PERFORM DATA_QUERY TABLES GT_ALV1
                              R_VBELN.

    MESSAGE S001 WITH '화면의 내용을 저장합니다. '.
*    LEAVE TO SCREEN 0.  "임시주석처리

    PERFORM REFRESH_TABLE_DISPLAY USING GRID1.

  ENDIF.


ENDFORM.                    " SEND_MSG
*&---------------------------------------------------------------------*
*&      Form  SET_REQUEST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_REQUEST_DATA TABLES   PT_ALV1 LIKE GT_ALV1[].

  DATA : LV_MIX_CHK,
         LV_DIV_CHK,
         LV_LOGI_CHK_F, "전송실패
         LV_LOGI_CHK_C, "취소요청
         LV_ORD_CHK1,
         LV_ORD_CHK2.

  DATA : BEGIN OF LT_LIKPS OCCURS 0,
           VBELN LIKE LIPS-VBELN,
           POSNR LIKE LIPS-POSNR,
           UECHA LIKE LIPS-UECHA ,  "배치분할상위레벨품목
         END OF LT_LIKPS,
         LT_0108 LIKE TABLE OF ZLET0108 WITH HEADER LINE.




  IF PT_ALV1[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_0105
      FROM ZLET0105 FOR ALL ENTRIES IN PT_ALV1
     WHERE VBELN EQ PT_ALV1-VBELN .

    SORT GT_0105 BY VBELN POSNR
                          TIMELINE DESCENDING. "최종전송내역만 조회

    DELETE ADJACENT DUPLICATES FROM GT_0105 COMPARING VBELN POSNR.


    IF GT_0105[] IS NOT INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0108
        FROM ZLET0108 FOR ALL ENTRIES IN GT_0105
       WHERE ORD_NUM  EQ GT_0105-ORD_NUM.

      SORT LT_0108 BY ORD_NUM.
    ENDIF.


    IF PT_ALV1[] IS NOT INITIAL.
      SELECT VBELN POSNR UECHA
         INTO CORRESPONDING FIELDS OF TABLE LT_LIKPS
        FROM LIPS FOR ALL ENTRIES IN PT_ALV1
       WHERE VBELN EQ PT_ALV1-VBELN
         AND LFIMG NE 0.
      SORT  LT_LIKPS BY VBELN POSNR.
    ENDIF.


    LOOP AT PT_ALV1.

      CLEAR : LV_DIV_CHK, LV_MIX_CHK, LV_LOGI_CHK_F, LV_LOGI_CHK_C,
              LV_ORD_CHK1,LV_ORD_CHK2.

      READ TABLE GT_0105 WITH KEY VBELN = PT_ALV1-VBELN.
      IF SY-SUBRC EQ 0.
        CASE GT_0105-SEND_STATUS.
          WHEN 'FF'.
            PT_ALV1-SEND_STATUS = '전송실패'.

          WHEN 'S1'.
            PT_ALV1-SEND_STATUS = '문자전송'.

          WHEN 'S2'.
            PT_ALV1-SEND_STATUS = '메일전송'.

          WHEN 'SF'.
            PT_ALV1-SEND_STATUS = '문자전송,메일실패'.

          WHEN 'FS'.
            PT_ALV1-SEND_STATUS = '메일전송,문자실패'.

          WHEN 'SS'.
            PT_ALV1-SEND_STATUS = '모두전송'.
        ENDCASE.


        IF GT_0105-SEND_STATUS NE 'FF'.
          LOOP AT GT_0105 WHERE  VBELN   EQ PT_ALV1-VBELN.

            IF GT_0105-STATUS(3) EQ 'MIX'.
              LV_MIX_CHK = GC_X.
            ENDIF.
            IF GT_0105-STATUS(3) EQ 'DIV'.
              LV_DIV_CHK = GC_X.
            ENDIF.

            IF GT_0105-LOGI_STATUS EQ 'F' .
              LV_LOGI_CHK_F = GC_X.
            ENDIF.

            IF GT_0105-LOGI_STATUS EQ 'C'.
              LV_LOGI_CHK_C = GC_X.
            ENDIF.

            LV_ORD_CHK1  = GC_X.

          ENDLOOP.

          LOOP AT LT_LIKPS WHERE  VBELN  EQ PT_ALV1-VBELN.
            READ TABLE GT_0105 WITH KEY VBELN = LT_LIKPS-VBELN
                                        POSNR = LT_LIKPS-POSNR
                                        BINARY SEARCH .

            IF SY-SUBRC NE 0  AND LV_ORD_CHK1 IS NOT INITIAL.
              READ TABLE GT_0105 WITH KEY VBELN = LT_LIKPS-VBELN
                                         POSNR = LT_LIKPS-UECHA
                                         BINARY SEARCH .

              "배치인경우 전기된 케이스 추가 확인
              IF SY-SUBRC NE 0  AND LV_ORD_CHK1 IS NOT INITIAL.
                LV_ORD_CHK2 = GC_X.
              ENDIF.
            ENDIF.
          ENDLOOP.

        ENDIF.


        IF LV_LOGI_CHK_F IS NOT INITIAL OR   "실패 또는
           LV_LOGI_CHK_C IS NOT INITIAL OR   "취소 또는
           LV_ORD_CHK2   IS NOT INITIAL .    "미처리
          PT_ALV1-SEND_STATUS_L = ICON_LED_RED.

        ELSEIF GT_0105-ORD_NUM IS NOT INITIAL. "그외 오더번호
          PT_ALV1-SEND_STATUS_L = ICON_LED_YELLOW.
          PT_ALV1-ORD_NUM  = PT_ALV1-ORD_NUM_OLD   = GT_0105-ORD_NUM.
          READ TABLE LT_0108 WITH KEY ORD_NUM = GT_0105-ORD_NUM
                                                   BINARY SEARCH.
          IF SY-SUBRC EQ 0 .
            PT_ALV1-LOGI_STATUS     = LT_0108-STATUS ."배차상태

            IF LT_0108-STATUS EQ '2' OR  "배차완료시
               LT_0108-STATUS EQ '3' OR
               LT_0108-STATUS EQ '4'   .

              PT_ALV1-DRIVER_NM       = LT_0108-DRIVER_NM    .
              PT_ALV1-DRIVER_TELNO    = LT_0108-DRIVER_TELNO .
              PT_ALV1-TRUCK_NO        = LT_0108-TRUCK_NO     .
              PT_ALV1-TDLNR           = LT_0108-TDLNR        .
              PT_ALV1-TRK_TON         = GT_0105-TRK_TON      .
              PT_ALV1-SEND_STATUS_L   = ICON_LED_GREEN       .

              "[CHM2210-00014] 컨테이너 차량 관련 필드 조회
              PT_ALV1-CTNR_NO1   = LT_0108-CTNR_NO1     .
              PT_ALV1-CTNR_NO2   = LT_0108-CTNR_NO2     .
              PT_ALV1-SEAL_NO1   = LT_0108-SEAL_NO1     .
              PT_ALV1-SEAL_NO2   = LT_0108-SEAL_NO2     .
              PT_ALV1-CTNR_WT1   = LT_0108-CTNR_WT1     .
              PT_ALV1-CTNR_WT2   = LT_0108-CTNR_WT2     .

            ENDIF.
          ENDIF.
        ENDIF.


        IF LV_MIX_CHK IS NOT INITIAL.
          IF PT_ALV1-SEND_STATUS  IS INITIAL.
            PT_ALV1-SEND_STATUS = '합짐포함'.
          ELSE.
            CONCATENATE PT_ALV1-SEND_STATUS ',합짐포함' INTO
            PT_ALV1-SEND_STATUS.
          ENDIF.

        ENDIF.

        IF LV_DIV_CHK IS NOT INITIAL.
          IF PT_ALV1-SEND_STATUS  IS INITIAL.
            PT_ALV1-SEND_STATUS = '분할포함'.
          ELSE.
            CONCATENATE PT_ALV1-SEND_STATUS ',분할포함' INTO
            PT_ALV1-SEND_STATUS.
          ENDIF.
        ENDIF.


      ENDIF.

      MODIFY PT_ALV1  .
    ENDLOOP.

  ENDIF.

ENDFORM.                    " SET_REQUEST_DATA
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING    PV_TITLE
                                PV_TEXT
                                PV_DEFAULT
                                PV_ANSWER.

  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL .

  DATA : LT_ALV3 LIKE TABLE OF GT_ALV3 WITH HEADER LINE.

  DATA : LV_TEXT(200) , LV_TEXT1(200), LV_TEXT2(200),
         LV_TEXT3(200), LV_TEXT4(200), LV_TEXT5(30),
         LV_CNT(3)      TYPE N,
         LV_NO_CAR      TYPE I,
         LV_STR_OLD(10),
         LV_MIX_CHK,
         LV_NOTE(255),
         LV_ORT01       LIKE GT_ALV3-ORT01,
         LV_ORT01_CHK,
         LV_TAB_CNT     LIKE SY-TABIX.

  CLEAR : GT_BODY, GT_BODY[],
          LT_ALV3, LT_ALV3[] .

  MOVE GT_ALV3_SEL[] TO LT_ALV3[].

  PERFORM APPEND_BODY USING  :
        '<BODY STYLE="FONT-SIZE: 9PT; FONT-FAMILY: 맑은 고딕;">',
        '안녕하세요. LS엠트론입니다.  <BR> '.

  IF OK_CODE EQ 'SEND_MSG' .
    PERFORM APPEND_BODY USING  :  '배차요청 안내메일입니다.<BR> '.
  ELSEIF OK_CODE EQ 'SEND_CAN' .
    PERFORM APPEND_BODY USING  :  '배차취소 안내메일입니다.<BR> '.
  ELSE.
    PERFORM APPEND_BODY USING  :  '배차변경 안내메일입니다.<BR> '.
  ENDIF.

  PERFORM APPEND_BODY USING  :
         '자세한 내용은 하기 테이블의 내용을  참조바랍니다.<BR><BR> '.

  PERFORM APPEND_BODY USING  :
'<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; MSO-BORDER-LEFT-ALT: SOLID ' &
 'BLACK 0.25PT;'
  .
  PERFORM APPEND_BODY USING  :
' MSO-BORDER-TOP-ALT: SOLID BLACK 0.25PT; MSO-BORDER-RIGHT-ALT: SOLID' &
' BLACK 0.25PT;'
  .
  PERFORM APPEND_BODY USING  :
' MSO-BORDER-BOTTOM-ALT: SOLID BLACK 0.25PT;FONT-SIZE: 9PT; FONT-FAMI' &
  'LY: 맑은 고딕;'
  .
  PERFORM APPEND_BODY USING  :
' MSO-PADDING-ALT: 3PT 0PT 3PT 0PT"  CELLSPACING=8 CELLPADDING=8 BORD' &
 'ER=1>'
  .
  PERFORM APPEND_BODY USING  :  '<STYLE>TH,TD{PADDING:10PX;}</STYLE>'.

*- [기능개선 291679] 운송계획 지점 메일추가  -[s]
  PERFORM APPEND_BODY USING  :
  '<TD COLSPAN="5" ALIGN="LEFT"  STYLE=''BORDER:1 SOLID WHITE''>'.
  PERFORM APPEND_BODY USING  :  '<B>운송계획지점:', WA-TPLST_T,
  '</B></TD>'.
*- [기능개선 291679] 운송계획 지점 메일추가  -[e]


  PERFORM APPEND_BODY USING  :
  '<TD COLSPAN="5" ALIGN="RIGHT"  STYLE=''BORDER:1 SOLID WHITE''>'.
  PERFORM APPEND_BODY USING  :  '<B>배차담당자 :', GV_PERNR_SH_T1,
  '</B></TD></TR>'.

  PERFORM APPEND_BODY USING  :
  ' <TR BGCOLOR=''YELLOW'' STYLE=''BORDER:1.1 SOLID BLACK''>'.

  PERFORM APPEND_HTML_TD USING :  '<B>인도처주소',   '<B>납품처',
               '<B>출고일' ,      '<B>출하예정시간', '<B>당일도착' ,
               '<B>차종(톤수)',   '<B>총중량(KG)',  '<B>단위포장SIZE',
               '<B>제품명'   ,   '<B>비고' .


  SORT GT_ALV3_SEL BY WADAT WAUHR STATUS .
  "[기능개선 298596] 출고날짜. 시간 오름차순 정렬

  DELETE LT_ALV3 WHERE ORD_NUM IS INITIAL.

  LOOP AT GT_ALV3_SEL WHERE ORD_NUM IS NOT INITIAL .

    IF  ( OK_CODE EQ 'SEND_RE' OR OK_CODE EQ 'SEND_CAN' ) AND
          GT_ALV3_SEL-LOGI_STATUS EQ ICON_LED_RED.
      CONTINUE.
    ENDIF.

    LV_TAB_CNT = LV_TAB_CNT + 1.

    "합짐체크
    IF GT_ALV3_SEL-STATUS(3) EQ 'MIX'.
      IF LV_STR_OLD <> GT_ALV3_SEL-STATUS(7).
        CLEAR LV_CNT.
        LV_MIX_CHK = GC_X.
        LV_STR_OLD = GT_ALV3_SEL-STATUS(7).
        LV_ORT01      = GT_ALV3_SEL-ORT01.
        LOOP AT LT_ALV3 WHERE STATUS(7) EQ LV_STR_OLD.
          LV_CNT = LV_CNT + 1.
          IF LT_ALV3-NOTE IS NOT INITIAL.
            CONCATENATE LV_NOTE LT_ALV3-NOTE INTO LV_NOTE
            SEPARATED BY '<BR>'.
          ENDIF.

          IF LV_ORT01 <> LT_ALV3-ORT01.
            LV_ORT01_CHK = GC_X.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.

    LV_TEXT4 = GT_ALV3_SEL-TRK_TON_T.

    CONCATENATE '<CENTER>' LV_TEXT4 '</CENTER>' INTO LV_TEXT4.

    PERFORM APPEND_BODY USING  :  ' <TR>'.

    CONCATENATE GT_ALV3_SEL-ORT01 GT_ALV3_SEL-STRAS INTO LV_TEXT
    SEPARATED BY SPACE.
    WRITE GT_ALV3_SEL-WADAT TO LV_TEXT1 USING EDIT MASK '____.__.__'.
    WRITE GT_ALV3_SEL-WAUHR TO LV_TEXT2 USING EDIT MASK '__:__'.


    PERFORM APPEND_HTML_TD USING :  LV_TEXT.  "주소
    PERFORM APPEND_HTML_TD USING :  GT_ALV3_SEL-KUNNR_T. "납품처

    IF LV_MIX_CHK IS INITIAL. "출고일. 시간
      IF LV_CNT EQ 0.
        PERFORM APPEND_HTML_TD USING : LV_TEXT1,
                                       LV_TEXT2.
      ENDIF.
    ELSE.
      PERFORM APPEND_HTML_TD_ROWSPAN USING : LV_TEXT1  LV_CNT,
                                             LV_TEXT2  LV_CNT.
    ENDIF.


    IF LV_MIX_CHK IS INITIAL. "당일도착
      IF LV_CNT EQ 0.
        PERFORM APPEND_HTML_TD_CHK USING :  GT_ALV3_SEL-DAY_CHK.
      ENDIF.
    ELSE.
      PERFORM APPEND_HTML_TD_CHK_ROWSPAN USING :  GT_ALV3_SEL-DAY_CHK
 LV_CNT
      .
    ENDIF.


    IF LV_MIX_CHK IS INITIAL.  "차종
      IF LV_CNT EQ 0.
        PERFORM APPEND_HTML_TD USING : LV_TEXT4.
      ENDIF.
    ELSE.
      PERFORM APPEND_HTML_TD_ROWSPAN USING : LV_TEXT4    LV_CNT.
    ENDIF.



    PERFORM APPEND_HTML_TD USING :  GT_ALV3_SEL-TBRGEW,
                                    GT_ALV3_SEL-GROES.



    PERFORM APPEND_HTML_TD USING :  GT_ALV3_SEL-ARKTX.
*                                    GT_ALV3_SEL-NOTE.


    IF LV_MIX_CHK IS INITIAL.
      IF LV_CNT EQ 0. "[기능개선 298596] 비고 합짐일경우 셀병합
        PERFORM APPEND_HTML_TD USING : GT_ALV3_SEL-NOTE.
      ENDIF.
    ELSE.

      IF LV_ORT01_CHK IS NOT INITIAL.
        CONCATENATE '경유'  LV_NOTE INTO LV_NOTE
        SEPARATED BY '<BR>'.
      ENDIF.

      PERFORM APPEND_HTML_TD_ROWSPAN USING : LV_NOTE  LV_CNT.
    ENDIF.

    PERFORM APPEND_BODY USING  :  ' </TR>'.

    IF LV_MIX_CHK IS NOT INITIAL.
      CLEAR LV_MIX_CHK.
      LV_CNT = LV_CNT  - 1.
      "[기능개선 298596] 합짐일 경우부터 카운터처리
    ELSE.
      IF LV_CNT > 0.
        LV_CNT = LV_CNT  - 1.
      ENDIF.
    ENDIF.

    CLEAR : LV_NOTE, LV_ORT01_CHK.

  ENDLOOP.

  CHECK LV_TAB_CNT > 0.

  PERFORM APPEND_BODY USING  :  '</TABLE>'.


  TRY.

      IF OK_CODE EQ 'SEND_MSG' .
        GV_SUBJECT = '[LS엠트론] 배차요청 안내메일입니다'.

      ELSEIF OK_CODE EQ 'SEND_CAN' .
        GV_SUBJECT = '[LS엠트론] 배차취소 안내메일입니다'.
      ELSE.
        GV_SUBJECT = '[LS엠트론] 배차변경 안내메일입니다'.
      ENDIF.


      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).
      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_BODY
                      I_SUBJECT = GV_SUBJECT ).


      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

      LOOP AT GT_ALV3_SEL WHERE ORD_NUM IS NOT INITIAL .
        PERFORM ATTACH_TO_MAIL . "파일첨부
      ENDLOOP.

*      G_SENDER =  CL_SAPUSER_BCS=>CREATE( GV_SENDER ). "발신자
*      G_SENDER =  CL_SAPUSER_BCS=>CREATE( 'ZLSGMM' ).
*      G_EMAIL->SET_SENDER( I_SENDER = G_SENDER ). "DEFALUT는 SY-UNAME


      G_SENDER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
      GS_SENDER-EMAIL ).

      G_RECEIVER =  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
      GS_RECEIVER-EMAIL ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = GC_X ).

      "참조자 (필요시)
      G_RECEIVER =  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
      GS_SENDER-EMAIL  ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = GC_X ).


      IF GS_RECEIVER-EMAIL_REF1 IS NOT INITIAL.
        G_RECEIVER =  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
        GS_RECEIVER-EMAIL_REF1 ).
        G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                I_EXPRESS   = GC_X ).
      ENDIF.

      IF GS_RECEIVER-EMAIL_REF2 IS NOT INITIAL.
        G_RECEIVER =  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
        GS_RECEIVER-EMAIL_REF2 ).
        G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                I_EXPRESS   = GC_X ).
      ENDIF.

      G_EMAIL->SET_SENDER( I_SENDER = G_SENDER ).
      G_EMAIL->SET_SEND_IMMEDIATELY( GC_X ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = GC_X
                     RECEIVING RESULT = GV_SEND_RESULT ).

      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.


  ENDTRY.

  IF G_EXCEPTION IS INITIAL.
*    MESSAGE S001 WITH '메일전송을 완료하였습니다.'.
    IF GV_STATUS IS INITIAL .
      GV_STATUS = 'S2'.
    ENDIF.
    IF GV_STATUS EQ 'S1'.
      GV_STATUS = 'SS'.
    ENDIF.
    IF GV_STATUS EQ 'F1'.
      GV_STATUS = 'FS'.
    ENDIF.
  ELSE.
    IF GV_STATUS IS INITIAL .
      GV_STATUS = 'F2'.
    ENDIF.
    IF GV_STATUS EQ 'S1'.
      GV_STATUS = 'SF'.
    ENDIF.
    IF GV_STATUS EQ 'F1'.
      GV_STATUS = 'FF'.
    ENDIF.
  ENDIF.

ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  APPEND_BODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_BODY USING P_TEXT.

  DATA : LS_MSG   TYPE SO_TEXT255.
  LS_MSG = P_TEXT.
  APPEND LS_MSG TO GT_BODY. CLEAR LS_MSG.

ENDFORM.                    "APPEND_BODY
*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0140   text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD  USING  P_TEXT.

  DATA : LV_LINE(100).

  LV_LINE =  P_TEXT .
  CONDENSE : LV_LINE.
  CONCATENATE GV_LINE '<TD>'  LV_LINE '</TD>' INTO  GV_LINE .
  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD
*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD_ROWSPAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0140   text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD_ROWSPAN USING  P_TEXT
                                   P_ROWS.

  DATA : LV_LINE(100).

  LV_LINE =  P_TEXT .
  CONDENSE : LV_LINE, P_ROWS.
  CONCATENATE GV_LINE '<TD ROWSPAN=''' P_ROWS '''>'  LV_LINE '</TD>'
  INTO  GV_LINE .
  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD

*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD_CHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_MAIL_DATA_CSSID_CR  text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD_CHK  USING    P_TEXT.

  DATA : LV_LINE(100).

  LV_LINE =  P_TEXT .
  CONDENSE LV_LINE.

  IF P_TEXT IS NOT INITIAL.
    GV_LINE = '<TD ALIGN=CENTER >●</TD>'.
*GV_LINE = '<TD ALIGN=CENTER > <INPUT TYPE="CHECKBOX" CHECKED
*DISABLED></TD>'.
  ELSE.
    GV_LINE = '<TD ALIGN=CENTER ></TD>'.
*GV_LINE = '<TD ALIGN=CENTER > <INPUT TYPE="CHECKBOX" DISABLED></TD>'.
  ENDIF.


  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD_CHK


*&---------------------------------------------------------------------*
*&      Form  APPEND_HTML_TD_CHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_MAIL_DATA_CSSID_CR  text
*----------------------------------------------------------------------*
FORM APPEND_HTML_TD_CHK_ROWSPAN  USING    P_TEXT P_ROWS.

  DATA : LV_LINE(100).

  LV_LINE =  P_TEXT .
  CONDENSE : LV_LINE,P_ROWS .

  IF P_TEXT IS NOT INITIAL.
    CONCATENATE '<TD ROWSPAN=''' P_ROWS  '''ALIGN=CENTER >●</TD>'
    INTO GV_LINE .
  ELSE.
    CONCATENATE '<TD ROWSPAN=''' P_ROWS  '''ALIGN=CENTER ></TD>'
    INTO GV_LINE .
  ENDIF.

  PERFORM APPEND_BODY USING GV_LINE .
  CLEAR GV_LINE.

ENDFORM.                    "APPEND_HTML_TD_CHK



*&---------------------------------------------------------------------*
*&      Form  GRID_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ALV_GRID99  text
*----------------------------------------------------------------------*
FORM GRID_CHECK_CHANGED_DATA  USING PV_GRID  TYPE REF TO CL_GUI_ALV_GRID
.

  DATA : LV_VALID.

*  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*    EXPORTING
*      FUNCTIONCODE           = 'ENTER'
*    EXCEPTIONS
*      FUNCTION_NOT_SUPPORTED = 1
*      OTHERS                 = 2.

  "ALV최신화
  CALL METHOD PV_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.

ENDFORM.                    "GRID_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_SMS .


  DATA : LV_CNT(100),
           LV_CNT_R(100),
           LV_LINE  LIKE SY-TFILL.

  CLEAR :  GV_CONTENT, GV_CONTENT_CLT.

  CHECK GT_SMS_1[] IS NOT INITIAL.

  DESCRIBE TABLE GT_SMS_1 LINES LV_LINE.

  IF GS_RECEIVER-MCHK3 IS NOT INITIAL.
    READ TABLE GT_SMS_1 INDEX 1.

    IF OK_CODE EQ 'SEND_RE' .
      CONCATENATE '[LS배차변경요청]' GT_SMS_1-CONTENT INTO GV_CONTENT.
    ELSEIF OK_CODE EQ 'SEND_CAN' .
      CONCATENATE '[LS배차취소요청]' GT_SMS_1-CONTENT INTO GV_CONTENT.
    ELSE.
      CONCATENATE '[LS배차요청]' GT_SMS_1-CONTENT INTO GV_CONTENT.
    ENDIF.

    IF LV_LINE > 1.
      LV_CNT = LV_LINE - 1.
      CONDENSE LV_CNT.
      CONCATENATE '외' LV_CNT '건' INTO LV_CNT_R.
      CONDENSE LV_CNT_R NO-GAPS.
      CONCATENATE GV_CONTENT LV_CNT_R  INTO GV_CONTENT SEPARATED BY
      SPACE.
    ENDIF.
    CONCATENATE GV_CONTENT'[메일참조]' INTO GV_CONTENT .

    PERFORM SEND_SMS_EXEC USING : GS_RECEIVER-TEL_NO,
                                  GS_RECEIVER-TEL_NO_REF1,
                                  GS_RECEIVER-TEL_NO_REF2.

    IF GF_CALL_FIRST IS INITIAL.
      PERFORM SEND_SMS_EXEC USING : GV_CALLBACK.
      CLEAR GF_CALL_FIRST.
    ENDIF.

    GV_CONTENT_CLT = GV_CONTENT.
  ENDIF.

  IF GS_RECEIVER-MCHK1 IS NOT INITIAL.
    LOOP AT GT_SMS_1.
      LV_CNT = SY-TABIX.
      CONDENSE LV_CNT.
      CONCATENATE  '[LS배차요청#'  ']' GT_SMS_1-CONTENT
       INTO GV_CONTENT.

      IF OK_CODE EQ 'SEND_RE' .
        CONCATENATE '[LS배차변경요청#' LV_CNT ']'
                      GT_SMS_1-CONTENT INTO GV_CONTENT.
      ELSEIF OK_CODE EQ 'SEND_CAN' .
        CONCATENATE '[LS배차취소요청#' LV_CNT ']'
                     GT_SMS_1-CONTENT INTO GV_CONTENT.
      ELSE.
        CONCATENATE '[LS배차요청#' LV_CNT ']'
                     GT_SMS_1-CONTENT INTO GV_CONTENT.
      ENDIF.


      IF LV_CNT <= 3.
        IF LV_CNT = 3 AND LV_LINE > 3.
          LV_CNT = LV_LINE - 3.
          CONDENSE LV_CNT.
          CONCATENATE '외' LV_CNT '건' INTO LV_CNT_R.
          CONDENSE LV_CNT_R NO-GAPS.
          CONCATENATE GV_CONTENT LV_CNT_R  INTO GV_CONTENT SEPARATED BY
          SPACE.
        ENDIF.

        PERFORM SEND_SMS_EXEC USING : GS_RECEIVER-TEL_NO,
                                      GS_RECEIVER-TEL_NO_REF1,
                                      GS_RECEIVER-TEL_NO_REF2.

        IF GF_CALL_FIRST_1 IS INITIAL.
          PERFORM SEND_SMS_EXEC USING : GV_CALLBACK.
        ENDIF.

        CONCATENATE GV_CONTENT_CLT GV_CONTENT INTO GV_CONTENT_CLT.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.

    CLEAR GF_CALL_FIRST_1.
  ENDIF.


  IF GV_STATUS IS INITIAL .
    GV_STATUS = 'S1'.
  ELSE.
    GV_STATUS = 'F1'.
  ENDIF.


ENDFORM.                    " SEND_SMS
*&---------------------------------------------------------------------*
*&      Form  CHECK_REQUEST
*&---------------------------------------------------------------------*
*       배차담당자 등록된 사용자와 관리자만 사용가능
*----------------------------------------------------------------------*
FORM CHECK_REQUEST .

  CLEAR GF_REQUEST.

  SELECT SINGLE * FROM  ZLET0106 WHERE UNAME EQ SY-UNAME.

  IF SY-SUBRC EQ 0."  OR ( SY-UNAME(4) EQ 'ZGOD' OR SY-UNAME(4) EQ 'ZGOS' ).
    GF_REQUEST = GC_X.
    GT_EXCL = 'MGMT1'.   APPEND  GT_EXCL .
    GT_EXCL = 'MGMT2'.   APPEND  GT_EXCL .

    GT_EXCL2 = 'VT01N_BDC'. APPEND GT_EXCL2.

    SELECT DOMVALUE_L AS FVAL DDTEXT AS FNAM
     INTO CORRESPONDING FIELDS OF TABLE  F4_TAB
     FROM DD07T
    WHERE DOMNAME    = 'ZTRKTON'
      AND DDLANGUAGE = SY-LANGU
      AND AS4LOCAL   = 'A'.

  ELSE.
    GT_EXCL = 'REQUEST'. APPEND  GT_EXCL .
    GT_EXCL = 'MGMT1'.   APPEND  GT_EXCL .
    GT_EXCL = 'MGMT2'.   APPEND  GT_EXCL .
    GT_EXCL = 'MAP'.      APPEND  GT_EXCL .
    GT_EXCL = 'MSETUP'.   APPEND  GT_EXCL .
    GT_EXCL = 'JOB_ORD'.  APPEND  GT_EXCL .

    GT_EXCL2 = 'VT01N_BDC'. APPEND GT_EXCL2.
  ENDIF.

ENDFORM.                    " CHECK_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UCOMM  text
*----------------------------------------------------------------------*
FORM CALL_TRANACTION  USING    P_UCOMM.

  CASE P_UCOMM.
    WHEN 'MGMT1'.
      CALL TRANSACTION 'ZLEV0106'.
    WHEN 'MGMT2'.
      CALL TRANSACTION 'ZLEV0107'.

  ENDCASE.

ENDFORM.                    " CALL_TRANACTION
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS_EXEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_SMS_EXEC USING P_MOBILE.

  IF P_MOBILE IS NOT INITIAL.

    REPLACE ALL OCCURRENCES OF  '-' IN P_MOBILE WITH SPACE.
    CONDENSE P_MOBILE.
    GV_MOBILE  = P_MOBILE .

*    CALL FUNCTION 'Z_LE_IF_SMS'
*      EXPORTING
*        I_CALLBACK = GV_CALLBACK  "송신자번호
*        I_MOBILE   = GV_MOBILE     "수신자번호
*        I_CONTENT  = GV_CONTENT
*      IMPORTING
*        E_ZERET    = GV_ZERET
*        E_ZEMSG    = GV_ZEMSG.
  ENDIF.

  IF GV_ZERET EQ '99' AND GV_STATUS IS INITIAL.
    GV_STATUS = 'F'.
  ENDIF.

ENDFORM.                    " SEND_SMS_EXEC
*&---------------------------------------------------------------------*
*&      Form  SET_DATA_SEND_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATA_SEND_MSG .


  DATA  : LV_MIX_CHK, LV_MIX_CHK1.

  DATA : LV_FIELD1(20), LV_FIELD2(20), LV_FIELD3(20),
         LV_FIELD4(20), LV_FIELD5(20).

  DATA  : LV_WADAT(10),  LV_CONTENT(100),
          LV_NO_CAR(10),
          LV_WAUHR(8).

  CLEAR :  GT_SMS, GT_SMS[],
           GT_SMS_1, GT_SMS_1[].

  IF SY-SYSID(1) CA 'DQ'.
    GV_CALLBACK = '07078458504'.
    GV_MOBILE   = '01023720609'.
    GS_SENDER-EMAIL    = 'HEOKD@LSGLOBALINC.COM'.
    GS_RECEIVER-EMAIL  = 'HEOKD@LSGLOBALINC.COM'.
  ELSE.

    "운영테스트 기간 중 배차담당자만 문자와 메일이 오도록 설정
    IF SY-DATUM  <= '20190915'.
      GS_RECEIVER-TEL_NO = GS_SENDER-TEL_NO .
      GS_RECEIVER-EMAIL  = GS_SENDER-EMAIL.
      CLEAR : GS_RECEIVER-EMAIL_REF1,  GS_RECEIVER-EMAIL_REF2,
              GS_RECEIVER-TEL_NO_REF1, GS_RECEIVER-TEL_NO_REF2.
    ELSE.
      GV_CALLBACK = GS_SENDER-TEL_NO.
      GV_MOBILE   = GS_RECEIVER-TEL_NO.
    ENDIF.
  ENDIF.

  IF GS_SENDER-DEPT IS NOT INITIAL.
    CONCATENATE GS_SENDER-DEPT  GV_PERNR_SH_T
                GS_SENDER-TEL_NO  GS_SENDER-EMAIL
           INTO GV_PERNR_SH_T1 SEPARATED BY SPACE.
  ELSE.
    CONCATENATE GV_PERNR_SH_T GS_SENDER-TEL_NO  GS_SENDER-EMAIL
           INTO GV_PERNR_SH_T1 SEPARATED BY SPACE.
  ENDIF.


*-- 문자메세지 내용 작성시작
  SORT GT_ALV3_SEL BY STATUS .

  LOOP AT GT_ALV3_SEL WHERE ORD_NUM IS NOT INITIAL .
    "주소, 차종 필요명칭만 추출

    PERFORM GET_ADDRESS_ALV3 USING    GT_ALV3_SEL-ORT01
                          CHANGING   GT_ALV3_SEL-ADDRESS .

    SPLIT GT_ALV3_SEL-TRK_TON_T AT SPACE
      INTO GT_ALV3_SEL-TRK_TON GT_ALV3_SEL-TRK_TON_T.

    CONDENSE GT_ALV3_SEL-TRK_TON_T.

    IF ( OK_CODE EQ 'SEND_RE'  OR OK_CODE EQ 'SEND_CAN' ) AND
        GT_ALV3_SEL-LOGI_STATUS EQ ICON_LED_RED.
      DELETE GT_ALV3_SEL.
      CONTINUE.
    ENDIF.

    MODIFY GT_ALV3_SEL.
  ENDLOOP.


  LOOP AT GT_ALV3_SEL WHERE ORD_NUM IS NOT INITIAL .
    AT NEW STATUS.
      CLEAR LV_MIX_CHK1.
      IF GT_ALV3_SEL-STATUS(3) EQ 'MIX'. "합짐체크
        LV_MIX_CHK = GC_X.
      ELSE.
        CLEAR LV_MIX_CHK.
      ENDIF.
    ENDAT.

    MOVE-CORRESPONDING GT_ALV3_SEL TO GT_SMS.

    IF LV_MIX_CHK IS NOT INITIAL. "새로운 합짐코드일 경우
      "다음라인 동일한 합짐코드 여부 체크하여 처음라인만 입력
      IF LV_MIX_CHK1 IS INITIAL.
        LV_MIX_CHK1 = GC_X.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF GT_ALV3_SEL-DAY_CHK IS INITIAL.
      WRITE GT_SMS-WADAT+4(4) TO LV_WADAT USING EDIT MASK '__월__일'.
    ELSE.
      LV_WADAT = '당일도착' .
    ENDIF.

* 합짐에서 광역시 체크
    LOOP AT GT_ALV3_SEL WHERE STATUS EQ GT_ALV3_SEL-STATUS
                     AND  STATUS(3) EQ 'MIX'
                     AND  ORD_NUM IS NOT INITIAL .
      IF GT_ALV3_SEL-ADDRESS  NE GT_SMS-ADDRESS.
        PERFORM GET_ADDRESS_ALV3_1 USING    GT_ALV3_SEL-ORT01
                                CHANGING  GT_SMS-ADDRESS  .
        EXIT.
      ENDIF.
    ENDLOOP.

    IF GS_RECEIVER-MCHK1 IS NOT INITIAL.
      "[기능개선 291679] 문자일 경우 배차시간도 전송
      WRITE GT_SMS-WAUHR TO LV_WAUHR USING EDIT MASK '__:__'.
      CONCATENATE LV_WADAT LV_WAUHR GT_SMS-ADDRESS INTO  GT_SMS-KEY
      SEPARATED BY SPACE.
    ELSE.
      CLEAR GT_SMS-WAUHR.
      CONCATENATE LV_WADAT  GT_SMS-ADDRESS INTO  GT_SMS-KEY SEPARATED BY
      SPACE.
    ENDIF.

    CONDENSE GT_SMS-KEY.
    COLLECT GT_SMS.

  ENDLOOP.


  SORT  GT_SMS BY KEY TRK_TON_T NO_CAR.

  LOOP AT GT_SMS.
    AT NEW KEY .
      LV_CONTENT = GT_SMS-KEY .
    ENDAT.
    LV_NO_CAR = GT_SMS-NO_CAR .
    CONDENSE LV_NO_CAR.
    CONCATENATE LV_NO_CAR  '대.' INTO LV_NO_CAR.
    CONCATENATE LV_CONTENT GT_SMS-TRK_TON_T LV_NO_CAR
           INTO LV_CONTENT SEPARATED BY SPACE.

    AT END OF KEY.
      GT_SMS_1-CONTENT  = LV_CONTENT.
      APPEND GT_SMS_1.
      CLEAR LV_CONTENT.
    ENDAT.

  ENDLOOP.


*-- 문자메세지 내용 작성 완료

ENDFORM.                    " SET_DATA_SEND_MSG
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_DATA_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_DATA_ALV3 .

  DATA : LV_HYPE    LIKE DD01V-DATATYPE,
         LV_ORD_NUM LIKE GT_ALV3-ORD_NUM,
         LT_ALV3    LIKE TABLE OF GT_ALV3 WITH HEADER LINE,
         LV_TPLST_L LIKE ZLET0108C-TPLST_L.

  CLEAR : GV_CHK, GF_EXIST, GF_NEW, GF_MIX_CHG,
          LT_ALV3, LT_ALV3[], LV_TPLST_L.

  IF GS_SENDER-PERNR IS INITIAL.
    PERFORM SET_MANDATORY USING '출하담당자는 필수입력입니다. '
                                 'GS_SENDER-PERNR'.
    EXIT.
  ENDIF.

  IF GS_RECEIVER-LIFNR IS INITIAL.
    PERFORM SET_MANDATORY USING '운송업체는 필수입력입니다'
                                 'GS_RECEIVER-LIFNR'.
    EXIT.
  ENDIF.



  IF WA-TPLST IS INITIAL.
    PERFORM SET_MANDATORY USING '운송계획지점 필수입력입니다'
                                 'WA-TPLST'.
    EXIT.

  ELSE.
    SELECT SINGLE TPLST_L INTO LV_TPLST_L
      FROM ZLET0108C
      WHERE TPLST  EQ WA-TPLST.

    IF SY-SUBRC NE 0 OR LV_TPLST_L IS INITIAL.
      PERFORM SET_MANDATORY USING
            '로지스팟에 등록되지않은 출하지점(화주그룹)입니다. '
            'WA-TPLST'.
      EXIT.
    ENDIF.
  ENDIF.

  IF GS_RECEIVER-MCHK1 IS INITIAL AND GS_RECEIVER-MCHK2 IS INITIAL AND
  "전송방법 미선택
     GS_RECEIVER-MCHK3 IS INITIAL.

    PERFORM SET_MANDATORY USING
    '운송업체 메시지 전송방법을 체크해주십시오.'
                              'GS_RECEIVER-MCHK1'.
    EXIT.
  ENDIF.


  IF GS_RECEIVER-MCHK1 IS NOT INITIAL OR GS_RECEIVER-MCHK3 IS NOT
  INITIAL .  "문자전송인경우
    IF GS_SENDER-TEL_NO IS INITIAL .
      PERFORM SET_MANDATORY USING
      '문자전송시 출하담당자 전화번호는 필수입력입니다.'
                                  'GS_SENDER-TEL_NO'.
      EXIT.
    ENDIF.

    IF GS_SENDER-TEL_NO(2) NE '01'. "휴대폰 시작번호
      PERFORM SET_MANDATORY USING '휴대폰번호(01X)를 입력해 주십시오 '
                                  'GS_SENDER-TEL_NO'.
      EXIT.
    ELSE.  "휴대폰번호 숫자와 하이픈(-)제외 체크
      GV_CALLBACK = GS_SENDER-TEL_NO.
      REPLACE ALL OCCURRENCES OF  '-' IN GV_CALLBACK WITH SPACE.
      CONDENSE : GV_CALLBACK NO-GAPS.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN = GV_CALLBACK
        IMPORTING
          HTYPE     = LV_HYPE.

      IF LV_HYPE NE 'NUMC'.
        PERFORM SET_MANDATORY USING
        '휴대폰번호에 미사용 문자가 들어있습니다. '
                                    'GS_SENDER-TEL_NO'.
        EXIT.
      ENDIF.

    ENDIF.


    IF GS_RECEIVER-TEL_NO IS INITIAL .
      PERFORM SET_MANDATORY USING
      '문자전송시 운송업체 전화번호는 필수입력입니다. '
                                  'GS_RECEIVER-TEL_NO'.
      EXIT.
    ENDIF.

    IF GS_RECEIVER-TEL_NO(2) NE '01'.
      PERFORM SET_MANDATORY USING '휴대폰번호(01X)를 입력해 주십시오 '
                                  'GS_RECEIVER-TEL_NO'.
      EXIT.
    ELSE.
      GV_MOBILE = GS_RECEIVER-TEL_NO.
      REPLACE ALL OCCURRENCES OF  '-' IN GV_MOBILE WITH SPACE.
      CONDENSE : GV_MOBILE NO-GAPS.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN = GV_MOBILE
        IMPORTING
          HTYPE     = LV_HYPE.

      IF LV_HYPE NE 'NUMC'.
        PERFORM SET_MANDATORY USING
        '휴대폰번호에 미사용 문자가 들어있습니다. '
                                    'GS_RECEIVER-TEL_NO'.
        EXIT.
      ENDIF.
    ENDIF.

  ENDIF.

  IF GS_RECEIVER-MCHK2 IS NOT INITIAL .  "메일전송인 경우


    IF GS_SENDER-EMAIL IS INITIAL .
      PERFORM SET_MANDATORY USING
      '메일전송시 출하담당자 E-MAIL은 필수입력입니다. '
                                  'GS_SENDER-EMAIL'.
      EXIT.
    ENDIF.

    IF GS_RECEIVER-EMAIL IS INITIAL .
      PERFORM SET_MANDATORY USING
      '메일전송시 운송업체 E-MAIL은 필수입력입니다. '
                                  'GS_RECEIVER-EMAIL'.
      EXIT.
    ENDIF.


  ENDIF.



  MOVE GT_ALV3[] TO  LT_ALV3[].

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.

    IF GT_ALV3-ORD_NUM IS NOT INITIAL.
      GF_EXIST = GC_X.
*      MESSAGE S001 WITH '이미 요청된 내역이 있습니다. '.
*      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ORD_NUM '.
*      EXIT.
    ELSE.
      GF_NEW  = GC_X.
    ENDIF.



    IF GT_ALV3-STATUS IS NOT INITIAL.
      IF LV_ORD_NUM IS INITIAL AND GT_ALV3-ORD_NUM IS NOT INITIAL.
        LV_ORD_NUM = GT_ALV3-ORD_NUM.
      ENDIF.

      IF LV_ORD_NUM NE GT_ALV3-ORD_NUM AND
         GT_ALV3-ORD_NUM IS NOT INITIAL AND
         LV_ORD_NUM IS NOT INITIAL .
        GF_MIX_CHG = GC_X.
      ENDIF.

    ENDIF.


    IF GT_ALV3-ORT01 IS INITIAL.
      MESSAGE S001 WITH '인도처주소는 필수입력입니다.'.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ORT01'.
      EXIT.
    ENDIF.

    IF GT_ALV3-KUNNR_T IS INITIAL.
      MESSAGE S001 WITH '납품처는 필수입력입니다.'.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'KUNNR_T'.
      EXIT.
    ENDIF.


    IF GT_ALV3-TRK_TON_T IS INITIAL.
      MESSAGE S001 WITH '차종(톤수)은 필수입력입니다.'.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'TRK_TON_T'.
      EXIT.
    ENDIF.

    IF GT_ALV3-WADAT IS INITIAL.
      MESSAGE S001 WITH '출고예정일은 필수입력입니다.'.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'WADAT'.
      EXIT.
    ENDIF.

    IF GT_ALV3-NO_CAR IS INITIAL.
      MESSAGE S001 WITH '차량대수는 필수 입력입니다. '.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'NO_CAR'.
      EXIT.
    ENDIF.


    IF GT_ALV3-ARKTX IS INITIAL.
      MESSAGE S001 WITH '제품명은 필수 입력입니다. '.
      PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ARKTX'.
      EXIT.
    ENDIF.


    IF GF_NREQUEST IS NOT INITIAL. "비주문배차일 경우

      IF GT_ALV3-TBRGEW IS INITIAL.
        MESSAGE S001 WITH '총중량은 필수입력입니다. ' .
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'TBRGEW'.
        EXIT.
      ENDIF.

      IF GT_ALV3-GROES   IS INITIAL.
        MESSAGE S001 WITH '단위포장사이즈는 필수입력입니다. ' .
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'GROES  '.
        EXIT.
      ENDIF.

      IF GT_ALV3-ZROUTE IS INITIAL.
        MESSAGE S001 WITH '운송경로는 필수입력입니다. ' .
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ZROUTE'.
        EXIT.
      ENDIF.


    ENDIF.

    IF OK_CODE EQ 'SEND_MSG'. "배차요청일 경우
      IF GT_ALV3-WADAT < SY-DATUM .
        MESSAGE S001 WITH '출고일이 과거입니다. '.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'WADAT'.
        EXIT.
      ENDIF.

      IF GT_ALV3-WADAT EQ  SY-DATUM AND
         GT_ALV3-WAUHR < SY-UZEIT.
        MESSAGE S001 WITH '출고시간이  과거입니다. '.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'WAUHR'.
        EXIT.
      ENDIF.

      IF GT_ALV3-WAUHR+2(2) NE '00' AND
         GT_ALV3-WAUHR+2(2) NE '30' .
        MESSAGE S001 WITH '출고시간은 30분단위로만 입력이 가능합니다. '.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'WAUHR'.
        EXIT.
      ENDIF.

    ELSE. "변경 또는 취소 요청일  경우
      IF GF_NEW IS NOT INITIAL.
        MESSAGE S001 WITH '미전송된 내역이 있습니다. '.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'STATUS'.
        EXIT.
      ENDIF.


      IF GF_MIX_CHG IS NOT INITIAL AND OK_CODE NE 'SEND_CAN'.
        MESSAGE S001 WITH '전송오더 한건만 처리가 가능합니다. '.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'STATUS'.
        EXIT.
      ENDIF.

    ENDIF.

    IF GT_ALV3-STATUS(3) EQ 'MIX' AND
       OK_CODE NE 'SEND_CAN'.
      LOOP AT  LT_ALV3 WHERE STATUS EQ GT_ALV3-STATUS.
        IF LT_ALV3-WADAT NE GT_ALV3-WADAT OR
           LT_ALV3-WAUHR NE GT_ALV3-WAUHR OR
           LT_ALV3-TRK_TON_T NE GT_ALV3-TRK_TON_T OR
           LT_ALV3-DAY_CHK NE GT_ALV3-DAY_CHK .

          MESSAGE S001 WITH
                 '합짐은 날짜와 시간 톤수가 동일해야 합니다.'.
          PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'STATUS'.
          PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'STATUS'.
          EXIT.
        ENDIF.

        IF GV_CHK IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " CHECK_INPUT_DATA_ALV3
*&---------------------------------------------------------------------*
*&      Form  SET_MANDATORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2868   text
*      -->P_2869   text
*----------------------------------------------------------------------*
FORM SET_MANDATORY  USING  P_MANDT  P_FIELD.
  GV_SCREEN_FILED = P_FIELD.
  MESSAGE S001 WITH P_MANDT .
  GV_CHK = GC_X.

ENDFORM.                    " SET_MANDATORY
*&---------------------------------------------------------------------*
*&      Form  SET_FOCUS_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_TABIX  text
*      -->P_3067   text
*----------------------------------------------------------------------*
FORM SET_FOCUS_ALV3  USING    P_INDEX
                              P_FIELDNAME .

  DATA : LS_ROW TYPE LVC_S_ROW,
         LS_COL TYPE LVC_S_COL.

  LS_ROW-INDEX = P_INDEX . "ROW NUMBER
  LS_COL-FIELDNAME = P_FIELDNAME . "FIELD NAME
  CALL METHOD GRID3->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = LS_ROW
      IS_COLUMN_ID = LS_COL.

  GV_CHK = GC_X.

ENDFORM.                    " SET_FOCUS_ALV3
*&---------------------------------------------------------------------*
*&      Form  GET_ADDRESS_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ADDRESS_ALV3  USING    P_ORT01
                       CHANGING P_ADDRESS.

  DATA : LV_FIELD1(20), LV_FIELD2(20), LV_FIELD3(20),
         LV_FIELD4(20), LV_FIELD5(20).


  SPLIT P_ORT01 AT SPACE
   INTO LV_FIELD1 LV_FIELD2 LV_FIELD3 LV_FIELD4 LV_FIELD5.

  IF LV_FIELD1(4) CA '01234567890-'.  "우편번호는 패스
    LV_FIELD1  = LV_FIELD2.
    LV_FIELD2  = LV_FIELD3.
  ENDIF.
  CONCATENATE LV_FIELD1 LV_FIELD2 INTO P_ADDRESS
                                  SEPARATED BY SPACE.


ENDFORM.                    " GET_ADDRESS_ALV3

*&---------------------------------------------------------------------*
*&      Form  GET_ADDRESS_ALV3_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ADDRESS_ALV3_1  USING    P_ORT01
                       CHANGING P_ADDRESS.

  DATA : LV_FIELD1(20), LV_FIELD2(20), LV_FIELD3(20),
         LV_FIELD4(20), LV_FIELD5(20).


  SPLIT P_ORT01 AT SPACE
   INTO LV_FIELD1 LV_FIELD2 LV_FIELD3 LV_FIELD4 LV_FIELD5.

  IF LV_FIELD1(4) CA '01234567890-'.  "우편번호는 패스
    LV_FIELD1  = LV_FIELD2.
    LV_FIELD2  = LV_FIELD3.
  ENDIF.

  P_ADDRESS = LV_FIELD1  .

ENDFORM.                    " GET_ADDRESS_ALV3
*&---------------------------------------------------------------------*
*&      Form  DEL_LINE_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_LINE_ALV3 .

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING    GRID3
                        CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF GT_ALV3-ADD_LINE_CHK IS INITIAL.
      MESSAGE I001 WITH '추가된 라인만 삭제할수 있습니다.'.
      RETURN .
    ENDIF.
  ENDLOOP .

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    GT_ALV3-ADD_LINE_CHK = GC_D.
    MODIFY GT_ALV3  INDEX GT_ROWS-INDEX
             TRANSPORTING ADD_LINE_CHK.
  ENDLOOP.

  DELETE GT_ALV3 WHERE ADD_LINE_CHK EQ GC_D.

  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.

ENDFORM.                    " DEL_LINE_ALV3
*&---------------------------------------------------------------------*
*&      Form  ADD_LINE_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_LINE_ALV3 .

  GV_POSNR = GV_POSNR + 1.
  CLEAR GT_ALV3 .

  GT_ALV3-WADAT  = SY-DATUM.
  GT_ALV3-WAUHR  = SY-UZEIT.
  GT_ALV3-GEWEI  = 'KG'.
  GT_ALV3-NO_CAR = 1.
  GT_ALV3-ADD_LINE_CHK = GC_C.
  GT_ALV3-POSNR  = GV_POSNR.


*  CALL FUNCTION 'ISHMED_ROUND_TIME' "30분 단위정각
*    EXPORTING
*      I_ROUND_MINUTE = 30
*    CHANGING
*      C_DATE         = GT_ALV3-WADAT
*      C_TIME         = GT_ALV3-WAUHR.

  PERFORM ISHMED_ROUND_TIME USING 30
                                  GT_ALV3-WADAT
                                  GT_ALV3-WAUHR.

  APPEND GT_ALV3.

  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.

ENDFORM.                    " ADD_LINE_ALV3
*&---------------------------------------------------------------------*
*&      Form  MAPPING_DISPATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAPPING_DISPATCH .

  GS_RECEIVER-MCHK3       = GC_X.
  GS_RECEIVER-MCHK3_REF1  = GC_X.
  GS_RECEIVER-MCHK3_REF2  = GC_X.
  GF_MAPPING  = GC_X.
  GT_EXCL3    = 'SEND_MSG' .  APPEND GT_EXCL3.
  GT_EXCL3    = 'SEND_CAN' .  APPEND GT_EXCL3.
  GF_ALV_FIRST = GC_X.
  GV_SCHK3 = GC_X.
  CLEAR : GV_SCHK1,GV_SCHK2, GF_EDIT,GV_SDATE.

  ST_ATTACH_KEY-ICON_TEXT = '첨부파일'.
  ST_ATTACH_KEY-TEXT      = '첨부파일조회'.


*CONCATENATE  '납품문서매핑' GT_ALV1-VBELN  INTO   GV_TITLE SEPARATED BY
*SPACE.
  GV_TITLE = '납품문서매핑'.
  CALL SCREEN '500' STARTING AT 1  1.

  CLEAR :   GT_HEADER_SEL, GT_HEADER_SEL[],
            GT_ITEM_SEL  , GT_ITEM_SEL[],
            GT_ALV3      , GT_ALV3[],
            GS_SENDER    , GS_RECEIVER,
            GV_CALLBACK  , GV_MOBILE,
            GV_CONTENT   , GV_STATUS  ,
            GV_PERNR_SH_T, GV_TDLNR_SH_T,
            GT_SMS       , GT_SMS[],
            GT_SMS_1     , GT_SMS_1[],
            GT_EXCL3     , GT_EXCL3[],
            GF_MAPPING,    GV_POSNR.

ENDFORM.                    " MAPPING_DISPATCH
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ALV3_NO_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ALV3_NO_VBELN .

  DATA : LT_0105            TYPE TABLE OF ZLET0105 WITH HEADER LINE,
         LS_CELLTAB         TYPE LVC_S_STYL,
         LT_CELLTAB         TYPE LVC_T_STYL,
         LV_SUB_QUERY(100),
         LV_SUB_QUERY1(100),

         LT_AREA            LIKE TABLE OF ZLET0212-AREA WITH HEADER LINE,
         LT_0212            LIKE TABLE OF ZLET0212 WITH HEADER LINE.

  CHECK GF_MAPPING IS NOT INITIAL.

  IF GS_RECEIVER-LIFNR IS INITIAL.
    MESSAGE S001 WITH '운송업체를 입력해주십시오.'.
    LEAVE SCREEN.
  ENDIF.

  IF GS_SENDER-PERNR IS INITIAL.
    MESSAGE S001 WITH '출하담당자를 입력해주십시오.'.
    LEAVE SCREEN.
  ENDIF.


  CASE GC_X.
    WHEN GV_SCHK1.
    WHEN GV_SCHK2.
      LV_SUB_QUERY = ' VBELN NOT LIKE ''MAP#%'' AND MAP_CANC EQ SPACE '.
    WHEN GV_SCHK3.
      LV_SUB_QUERY = ' VBELN LIKE ''MAP#%'' OR MAP_CANC NE SPACE '.
  ENDCASE.

  IF GV_SDATE IS NOT INITIAL.
    CONCATENATE '''' GV_SDATE '''' INTO LV_SUB_QUERY1.
    CONCATENATE 'ERDAT EQ'  LV_SUB_QUERY1 INTO LV_SUB_QUERY1
                                          SEPARATED BY SPACE.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_0105
    FROM ZLET0105
   WHERE PERNR EQ GS_SENDER-PERNR
     AND TDLNR EQ GS_RECEIVER-LIFNR
     AND (LV_SUB_QUERY)
     AND (LV_SUB_QUERY1).


*- 경로가 있는 경우 출발, 목적지 명칭 추출  -[s]
  LOOP AT LT_0105 .
    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
      LT_AREA = LT_0105-ZDEPARTURE.
      APPEND LT_AREA.
    ENDIF.

    IF LT_0105-ZARRIVAL IS NOT INITIAL.
      LT_AREA = LT_0105-ZARRIVAL.
      APPEND LT_AREA.
    ENDIF.
  ENDLOOP.

  SORT LT_AREA BY TABLE_LINE.
  DELETE ADJACENT DUPLICATES FROM LT_AREA COMPARING ALL FIELDS.

  IF LT_AREA[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0212
      FROM ZLET0212 FOR ALL ENTRIES IN LT_AREA
     WHERE  AREA EQ LT_AREA-TABLE_LINE.
    SORT LT_0212 BY AREA.
  ENDIF.

*- 경로가 있는 경우 출발, 목적지 명칭 추출 -[e]

  CLEAR : GT_ALV3, GT_ALV3[].

  LS_CELLTAB-FIELDNAME = 'POSNR'.
  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.

  LS_CELLTAB-FIELDNAME = 'VBELN'.
  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.

  LOOP AT LT_0105.
    CLEAR : GT_ALV3.
    MOVE-CORRESPONDING LT_0105 TO GT_ALV3.

*- 출발, 목적지 명칭
    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZDEPARTURE
                                         BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_ALV3-ZDEPARTURET  = LT_0212-TEXT1.
      ENDIF.
    ENDIF.

    IF LT_0105-ZARRIVAL IS NOT INITIAL.
      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZARRIVAL
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_ALV3-ZARRIVALT = LT_0212-TEXT1.
      ENDIF.
    ENDIF.

*- 차종
    READ TABLE F4_TAB WITH KEY FVAL = GT_ALV3-TRK_TON.
    IF SY-SUBRC EQ 0.
      CONCATENATE F4_TAB-FVAL ` ` F4_TAB-FNAM
             INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.
    ENDIF.

    IF GT_ALV3-VBELN(3) EQ 'MAP' OR GT_ALV3-MAP_CANC IS NOT INITIAL .
      GT_ALV3-VBELN_PT  = GT_ALV3-VBELN.
      CLEAR : GT_ALV3-VBELN.
    ELSE.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_ALV3-CELLTAB.
    ENDIF.


    IF GT_ALV3-ATTACH_KEY IS NOT INITIAL.
      GT_ALV3-ATTACH_ICON = ICON_ATTACHMENT.
    ENDIF.

    APPEND GT_ALV3.
  ENDLOOP.



  GF_ALV_FIRST = GC_X.


ENDFORM.                    " GET_DATA_ALV3_NO_VBELN
*&---------------------------------------------------------------------*
*&      Form  MAPPING_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAPPING_VBELN .

  DATA : LV_MESSAGE(100),
         LT_ZLET0105 TYPE TABLE OF ZLET0105 WITH HEADER LINE.

  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING    GRID3
                        CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.


    IF GT_ALV3-VBELN IS INITIAL.
      MESSAGE S001 WITH '납품번호는 필수입력입니다.'.
      RETURN .
    ENDIF.


    IF GT_ALV3-POSNR IS INITIAL.
      MESSAGE S001 WITH '품목번호는 필수입력입니다.'.
      RETURN .
    ENDIF.


    IF GT_ALV3-VBELN IS NOT INITIAL AND
        GT_ALV3-VBELN_PT IS INITIAL.
      MESSAGE S001 WITH '이미 매핑된 납품문서가 있습니다.'.
      RETURN .
    ENDIF.


    SELECT SINGLE * FROM ZLET0105 INTO LT_ZLET0105
      WHERE VBELN   = GT_ALV3-VBELN
       AND  POSNR   = GT_ALV3-POSNR
       AND TIMELINE = GT_ALV3-TIMELINE
       AND STATUS   = GT_ALV3-STATUS.

    IF SY-SUBRC EQ 0.
      MESSAGE S004 WITH GT_ALV3-VBELN '는 이미 매핑된 납품문서 입니다. '
      .
      RETURN .
    ENDIF.

  ENDLOOP .


*CONCATENATE '선택한 내용을 납품문서'  GT_ALV1-VBELN '에
*연결하시겠습니까?'
*               INTO LV_MESSAGE SEPARATED BY SPACE.

  LV_MESSAGE = '선택한 내용을 납품문서에 연결하시겠습니까?'.

  PERFORM POPUP_TO_CONFIRM
    USING '납품문서 연결'  LV_MESSAGE
           '1'     GV_ANSWER.

  CHECK GV_ANSWER EQ '1'.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.

    UPDATE ZLET0105  SET  VBELN  = GT_ALV3-VBELN
                          AENAM  = SY-UNAME
                          AEDAT  = SY-DATUM
                          AEZET  = SY-UZEIT
                          MAP_CANC = SPACE
                    WHERE TIMELINE EQ GT_ALV3-TIMELINE
                      AND VBELN    EQ GT_ALV3-VBELN_PT
                      AND STATUS   EQ GT_ALV3-STATUS
                      AND POSNR    EQ GT_ALV3-POSNR.

  ENDLOOP .

  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '정상 처리되었습니다.' .
  ELSE.
    MESSAGE S001 WITH '매핑에 실패한 내역이 있습니다.' DISPLAY LIKE 'E'.
  ENDIF.

  PERFORM GET_DATA_ALV3_NO_VBELN.

ENDFORM.                    " MAPPING_VBELN
*&---------------------------------------------------------------------*
*&      Form  MAPPING_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAPPING_CANCEL .

  DATA : LV_MESSAGE(100),
         LT_ZLET0105 TYPE TABLE OF ZLET0105 WITH HEADER LINE.

  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING    GRID3
                        CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.

    IF GT_ALV3-VBELN IS INITIAL.
      MESSAGE S001 WITH '매핑되지 않는 납품문서가 있습니다.'.
      RETURN .
    ENDIF.

  ENDLOOP .


  PERFORM POPUP_TO_CONFIRM
    USING '납품문서 연결취소'  '선택한 내용의 매핑을 취소하시겠습니까?'
           '1'     GV_ANSWER.

  CHECK GV_ANSWER EQ '1'.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    UPDATE ZLET0105  SET  AENAM  = SY-UNAME
                          AEDAT  = SY-DATUM
                          AEZET  = SY-UZEIT
                          MAP_CANC = 'X'
                    WHERE TIMELINE = GT_ALV3-TIMELINE
                      AND VBELN    = GT_ALV3-VBELN
                      AND POSNR    = GT_ALV3-POSNR
                      AND STATUS   EQ GT_ALV3-STATUS
                      .


    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '매핑취소에 실패한 내역이 있습니다.' DISPLAY
      LIKE 'E'.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

  ENDLOOP .

  MESSAGE S001 WITH '정상 처리되었습니다.' .


  PERFORM GET_DATA_ALV3_NO_VBELN.
ENDFORM.                    " MAPPING_CANCEL
*&---------------------------------------------------------------------*
*&      Form  SET_ATTACHMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ATTACHMENT .

  DATA: L_ROL   TYPE OBLROLTYPE VALUE 'GOSAPPLOBJ',
        LT_LINK TYPE OBL_T_LINK,
        LV_MODE .

  GS_BOBJ-TYPEID = 'ZLER0101'.
  GS_BOBJ-CATID = 'BO'.

  IF SY-DYNNR EQ '0400' . "요청

    PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                             USING    GRID3
                          CHANGING GV_CHK.
    CHECK GV_CHK IS INITIAL.

    DESCRIBE TABLE GT_ROWS LINES SY-TFILL.
    IF SY-TFILL > 2.
      MESSAGE S001 WITH '첨부파일은 한라인만 선택가능합니다. '.
      EXIT.
    ENDIF.

    LOOP AT  GT_ROWS.
      READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
      IF GT_ALV3-ATTACH_KEY IS INITIAL.
        CONCATENATE  'ATT_' SY-DATUM '_' SY-UZEIT '_' GT_ALV3-VBELN
                        '_' GT_ALV3-POSNR
         INTO GT_ALV3-ATTACH_KEY .
      ENDIF.
      EXIT.
    ENDLOOP.

    GS_BOBJ-INSTID =  GT_ALV3-ATTACH_KEY  .
    LV_MODE = 'E'. "편집
  ELSE.  "조회
    LV_MODE = 'D'.  "조회
    GS_BOBJ-INSTID = GT_ALV3-ATTACH_KEY.
  ENDIF.


*-- Call File Attachment Dialog Box
  CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
    EXPORTING
      IS_OBJECT = GS_BOBJ
      IP_MODE   = LV_MODE.


  IF LV_MODE = 'E'. "편집시 링크확인
    CLEAR : LT_LINK, LT_LINK[].

    CALL METHOD CL_BINARY_RELATION=>READ_LINKS_OF_BINREL
      EXPORTING
        IS_OBJECT   = GS_BOBJ
        IP_LOGSYS   = 'BO'
        IP_RELATION = 'ATTA'
        IP_ROLE     = L_ROL
      IMPORTING
        ET_LINKS    = LT_LINK.


    IF LT_LINK[] IS NOT  INITIAL.
      GT_ALV3-ATTACH_ICON = ICON_ATTACHMENT.
    ELSE.
      CLEAR : GT_ALV3-ATTACH_KEY, GT_ALV3-ATTACH_ICON.
    ENDIF.

    MODIFY GT_ALV3 INDEX GT_ROWS-INDEX
                       TRANSPORTING ATTACH_KEY ATTACH_ICON.

  ENDIF.

ENDFORM.                    " SET_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  ATTACH_TO_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ATTACH_TO_MAIL .


*-- Get Attached File Counter

  DATA: LS_BOBJ TYPE SIBFLPORB,
        LS_STAT TYPE SGS_S_ACNT,
        LT_STAT TYPE SGS_T_ACNT,
        LV_MODE .


*>> 메일용 data
  DATA : LT_PLIST     LIKE SOPCKLSTI1 OCCURS 2 WITH HEADER LINE,
         LT_REC_TAB   LIKE SOMLRECI1 OCCURS 1 WITH HEADER LINE,
         LV_LINE_SIZE TYPE I VALUE 255.

  DATA : LV_DOCUMENT_ID        TYPE SOFOLENTI1-DOC_ID,
         LT_LINKS              TYPE TABLE OF RELGRAPHLK,
         LWA_DOCUMENT_DATA     LIKE SOFOLENTI1,
         LT_OBJECT_CONTENT_TMP LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE,
         LT_OBJECT_CONTENT     LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE,
         LT_OBJECT_TEXT        LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE.

  DATA : LT_GOS_CON TYPE TABLE OF BDN_CON,
         LS_GOS_CON TYPE BDN_CON.

  DATA : LV_CLASS LIKE BAPIBDS01-CLASSNAME,
         LV_OBJKE LIKE SWOTOBJID-OBJKEY.

  DATA : LV_LINE TYPE SOLISTI1.


  DATA : LV_TYPE    TYPE SOODK-OBJTP,
         LV_SUBJECT TYPE SOOD-OBJDES.


*  COMMIT WORK AND WAIT. "첨부파일 DB저장

  CHECK GT_ALV3_SEL-ATTACH_KEY IS NOT INITIAL..
  CLEAR LT_STAT.

  GS_BOBJ-INSTID = GT_ALV3_SEL-ATTACH_KEY .
  CALL METHOD CL_GOS_ATTACHMENT_QUERY=>COUNT_FOR_OBJECT
    EXPORTING
      IS_OBJECT = GS_BOBJ
      IP_ARL    = SPACE
    RECEIVING
      RT_STAT   = LT_STAT.

  CLEAR LS_STAT.
  READ TABLE LT_STAT INTO LS_STAT INDEX 1.
  GV_ATTACH_CNT = LS_STAT-COUNTER.

  CHECK GV_ATTACH_CNT > 0. "1건 이상인 경우 첨부


  LV_CLASS = GS_BOBJ-TYPEID.
  LV_OBJKE = GS_BOBJ-INSTID.

  "저장된 첨부파일 데이터 추출
  CALL FUNCTION 'BDS_GOS_CONNECTIONS_GET'
    EXPORTING
      CLASSNAME          = LV_CLASS
      OBJKEY             = LV_OBJKE
      CLIENT             = SY-MANDT
    TABLES
      GOS_CONNECTIONS    = LT_GOS_CON
    EXCEPTIONS
      NO_OBJECTS_FOUND   = 1
      INTERNAL_ERROR     = 2
      INTERNAL_GOS_ERROR = 3
      OTHERS             = 4.

  LOOP AT LT_GOS_CON INTO LS_GOS_CON.

    REFRESH  G_OBJCONT1.
    MOVE LS_GOS_CON-LOIO_ID TO LV_DOCUMENT_ID.

* Read the data
    CALL FUNCTION 'SO_DOCUMENT_READ_API1'
      EXPORTING
        DOCUMENT_ID                = LV_DOCUMENT_ID
      IMPORTING
        DOCUMENT_DATA              = LWA_DOCUMENT_DATA
      TABLES
        OBJECT_CONTENT             = LT_OBJECT_CONTENT_TMP
      EXCEPTIONS
        DOCUMENT_ID_NOT_EXIST      = 1
        OPERATION_NO_AUTHORIZATION = 2
        X_ERROR                    = 3
        OTHERS                     = 4.


    LOOP AT LT_OBJECT_CONTENT_TMP.
      LV_LINE = LT_OBJECT_CONTENT_TMP .
      APPEND LV_LINE TO G_OBJCONT1.
    ENDLOOP.

*TRY.
    LV_TYPE   = LS_GOS_CON-DOCUCLASS.
    LV_SUBJECT = LS_GOS_CON-DESCRIPT.

    CALL METHOD G_EMAIL_BODY->ADD_ATTACHMENT
      EXPORTING
        I_ATTACHMENT_TYPE    = LV_TYPE
        I_ATTACHMENT_SUBJECT = LV_SUBJECT
        I_ATT_CONTENT_TEXT   = G_OBJCONT1.

  ENDLOOP.


ENDFORM.                    " ATTACH_TO_MAIL
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  PV_ROW    TYPE LVC_S_ROW
                          PV_COLUMN TYPE LVC_S_COL.

  CLEAR : GT_ALV3-ATTACH_KEY.
  READ TABLE GT_ALV3 INDEX PV_ROW.
  IF  GT_ALV3-ATTACH_KEY IS NOT INITIAL  .
    PERFORM SET_ATTACHMENT.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  GET_LINE_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LINE_ALV3 .

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING    GRID3
                        CHANGING GV_CHK.
  CHECK GV_CHK IS INITIAL.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    EXIT.
  ENDLOOP.

ENDFORM.                    " GET_LINE_ALV3
*&---------------------------------------------------------------------*
*&      Form  SEND_MSG_TO_TDLNT_BY_LOGISPOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MSG_TO_TDLNT_BY_LOGISPOT .

  DATA : LT_PLACE        LIKE TABLE OF ZLES0106 WITH HEADER LINE,
         LT_PAYS         LIKE TABLE OF ZLES0107 WITH HEADER LINE,
         LT_MEMO         LIKE TABLE OF ZLES0108 WITH HEADER LINE,

         LS_REQ_DATA     LIKE ZLES0105,
         LV_ORD_NUM(10),
         LV_RESULT,
         LV_ERR_MSG(255),
         LV_STATUS,

         LV_WADAT        LIKE LIKP-WADAT,
         LV_TOKEN        TYPE STRING,
         LV_DEST         TYPE ZIFDEST-DEST,
         LV_GROES(15).

  DATA  : LT_0108  LIKE TABLE OF ZLET0108 WITH HEADER LINE,
          LT_0108A LIKE TABLE OF ZLET0108A WITH HEADER LINE.

  DATA : LT_ALV3  LIKE TABLE OF GT_ALV3 WITH HEADER LINE,
         LT_FILES TYPE ZLET0109.

  DATA : LV_CNT(3)        TYPE N,
         LV_NO_CAR        TYPE I,
         LV_STR_OLD(10),
         LV_MIX_CHK,
         LV_TBRGEW        LIKE LS_REQ_DATA-TBRGEW,
         LV_NOTE_GLOSS    LIKE LS_REQ_DATA-NOTE,
         LV_NOTE          LIKE LS_REQ_DATA-NOTE,
         LV_FREIGHT_COUNT LIKE LS_REQ_DATA-FREIGHT_COUNT,
         LV_ORT01         LIKE GT_ALV3-ORT01,
         LV_ORT01_CHK,
         LV_TYPE .

  PERFORM CONNECT_LOGIST USING LV_DEST LV_TOKEN.

  IF SY-UNAME(4) <> 'ZLSG' OR SY-DATUM > '20230930'.
    IF LV_TOKEN IS INITIAL OR LV_DEST  IS INITIAL.
      MESSAGE A001 WITH '로지스팟 접속실패.담당자에게 문의하십시오'.
    ENDIF.
  ELSE.
*___HANA 통합테스트용
    MESSAGE I004 WITH '현재 사용자 ID는 로지스팟 접속여부를'
                      '점검하지 않고 실행합니다.'.

    LV_TOKEN = 'X'.
    LV_DEST  = 'SAPPIDEV'.
  ENDIF.

  CHECK LV_TOKEN IS NOT INITIAL AND
        LV_DEST IS NOT INITIAL.

  MOVE GT_ALV3_SEL[] TO LT_ALV3[].

  SORT GT_ALV3_SEL BY WADAT WAUHR STATUS ORT01.

  LOOP AT GT_ALV3_SEL.
*-- 합짐설정 [s]
    IF GT_ALV3_SEL-STATUS(3) EQ 'MIX'.
      IF LV_STR_OLD <> GT_ALV3_SEL-STATUS(7).
        CLEAR LV_CNT.
        LV_ORT01 = GT_ALV3_SEL-ORT01.
        LV_MIX_CHK = GC_X.
        LV_STR_OLD = GT_ALV3_SEL-STATUS(7).
        LOOP AT LT_ALV3 WHERE STATUS(7) EQ LV_STR_OLD.
          LV_CNT = LV_CNT + 1.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF LV_CNT > 0.
      LV_CNT = LV_CNT  - 1.
    ENDIF.
*-- 합짐설정 [e]

    LV_FREIGHT_COUNT = LV_FREIGHT_COUNT + 1.

    MOVE-CORRESPONDING GT_ALV3_SEL TO LS_REQ_DATA.

    LS_REQ_DATA-TPLST    =  WA-TPLST.
    LS_REQ_DATA-TDLNR    =  GS_RECEIVER-LIFNR.
    LS_REQ_DATA-IS_ROUND = '0'.    "1: 왕복, 0: 편도
    LS_REQ_DATA-IS_MIX   = '0'.    "1: 혼적, 0: 독차

    LS_REQ_DATA-TBRGEW = LS_REQ_DATA-TBRGEW / 1000. "톤수




*- 하차지 주소지 공통  설정
    LV_WADAT        = GT_ALV3_SEL-WADAT + 1.
    IF GT_ALV3_SEL-DAY_CHK IS INITIAL.
      WRITE LV_WADAT  TO LT_PLACE-WADAT
      USING EDIT MASK '____-__-__'.
      LT_PLACE-WAUHR       = '0900'.
    ELSE.
      WRITE GT_ALV3_SEL-WADAT TO LT_PLACE-WADAT
      USING EDIT MASK '____-__-__'.
      LT_PLACE-WAUHR = 'today_unload'.
    ENDIF.

    PERFORM GET_ADDRESS_AVL3_2 USING GT_ALV3_SEL-ORT01
                            CHANGING LT_PLACE-ORT01.

    LT_PLACE-KUNNR_T    = GT_ALV3_SEL-KUNNR_T.  "납품처명
    LT_PLACE-PERNR_T    = GT_ALV3_SEL-DATLT.      "하차담당자
    LT_PLACE-CALLBACK   = GT_ALV3_SEL-TELF2.    "하차전화번호

    IF GT_ALV3_SEL-TELF2 IS INITIAL.
      LT_PLACE-CALLBACK = GT_ALV3_SEL-TELF1.
    ENDIF.


*-- 합짐설정 [s]
    IF LV_MIX_CHK IS INITIAL.  "합짐설정
      LT_PLACE-PLACES_TYPE  = '2'.  "하차
      LT_PLACE-PLACES_SEQUENCE = '1'.
      APPEND :  LT_PLACE. CLEAR :  LT_PLACE.
      LV_TBRGEW  = LS_REQ_DATA-TBRGEW .
      LV_GROES = LS_REQ_DATA-GROES.
      LV_NOTE  = LS_REQ_DATA-NOTE.
    ELSE.
      IF LT_PLACE-PLACES_TYPE IS INITIAL.
        LT_PLACE-PLACES_TYPE  = '2'.  "하차
        LT_PLACE-PLACES_SEQUENCE = '1'.
        APPEND :  LT_PLACE.
      ELSE.
        READ TABLE LT_PLACE WITH KEY ORT01    = LT_PLACE-ORT01
                                     KUNNR_T  = GT_ALV3_SEL-KUNNR_T
                                     PERNR_T  = GT_ALV3_SEL-DATLT.
        IF SY-SUBRC NE 0.
          LT_PLACE-PLACES_TYPE  = '4'.  "경유하차
          APPEND :  LT_PLACE.
        ENDIF.
      ENDIF.
      LV_TBRGEW  = LV_TBRGEW + LS_REQ_DATA-TBRGEW .
      LV_GROES  = '전달사항참고'.
      IF LV_NOTE_GLOSS IS INITIAL.
        LV_NOTE_GLOSS = LS_REQ_DATA-GROES.
      ELSE.
        CONCATENATE LV_NOTE_GLOSS LS_REQ_DATA-GROES INTO LV_NOTE_GLOSS
        SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
      ENDIF.

      IF LV_NOTE IS INITIAL.
        LV_NOTE  = LS_REQ_DATA-NOTE.
      ELSE.
        CONCATENATE LV_NOTE LS_REQ_DATA-NOTE INTO LV_NOTE
        SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
      ENDIF.

      IF LV_ORT01 <> GT_ALV3_SEL-ORT01.
        LV_ORT01_CHK = GC_X.
      ENDIF.

    ENDIF.
*-- 합짐설정 [e]


    CONDENSE LS_REQ_DATA-TBRGEW NO-GAPS.


*- 차주전달사항(상세물품명)
    IF LS_REQ_DATA-REMARK_DRIVER  IS INITIAL.
      LS_REQ_DATA-REMARK_DRIVER = GT_ALV3_SEL-ARKTX.
    ELSE.
      CONCATENATE LS_REQ_DATA-REMARK_DRIVER  GT_ALV3_SEL-ARKTX
         INTO LS_REQ_DATA-REMARK_DRIVER SEPARATED BY
         CL_ABAP_CHAR_UTILITIES=>NEWLINE.
    ENDIF.

    CONDENSE LS_REQ_DATA-REMARK_DRIVER .

*- 자체코드 (납품문서)
    IF LT_MEMO-MEMO IS INITIAL.
      LT_MEMO-MEMO  = GT_ALV3_SEL-VBELN.
    ELSE.
      FIND GT_ALV3_SEL-VBELN IN LT_MEMO-MEMO.
      IF SY-SUBRC NE 0.
        CONCATENATE  LT_MEMO-MEMO GT_ALV3_SEL-VBELN
              INTO LT_MEMO-MEMO SEPARATED BY ' / ' .
      ENDIF.
    ENDIF.

    SPLIT GT_ALV3_SEL-TRK_TON_T AT SPACE
     INTO LS_REQ_DATA-TRK_TON GT_ALV3_SEL-TRK_TON_T.

    IF LT_MEMO-MEMO IS INITIAL.
      CONCATENATE  '[' LS_REQ_DATA-TRK_TON ']'
            INTO    LT_MEMO-MEMO   SEPARATED BY SPACE.
    ELSE.
      CONCATENATE  LT_MEMO-MEMO '['
                   LS_REQ_DATA-TRK_TON  ']'
            INTO    LT_MEMO-MEMO  SEPARATED BY SPACE.

    ENDIF.

*****
    IF LV_CNT EQ 0 OR LV_CNT IS INITIAL.
      CLEAR LV_MIX_CHK.
      LS_REQ_DATA-TBRGEW = LV_TBRGEW.
      LS_REQ_DATA-GROES  = LV_GROES.

*- 지급방법설정
      LT_PAYS-PMT_METHOD = '1'. "0: 선착불, 1: 계산서
      LT_PAYS-PMT_TYPE   = '0'. "일반

      APPEND :  LT_PAYS.
      CLEAR  :  LT_PAYS .

*- 메모설정
      LT_MEMO-M_TYPE    = '1'. "1.자체관리코드 .2: 내부메
      APPEND LT_MEMO.


      LT_MEMO-M_TYPE    = '2'. "1.자체관리코드 .2: 내부메모
      LT_MEMO-MEMO      =  GS_SENDER-DEPT. "부서명
      APPEND LT_MEMO.

      CLEAR LT_MEMO.

      IF LV_NOTE IS INITIAL AND LV_NOTE_GLOSS IS NOT INITIAL.
        LS_REQ_DATA-NOTE = LV_NOTE_GLOSS .
      ELSEIF ( LV_NOTE IS NOT INITIAL AND LV_NOTE_GLOSS IS INITIAL ).
        LS_REQ_DATA-NOTE = LV_NOTE .
      ELSEIF ( LV_NOTE  IS NOT INITIAL AND
               LV_NOTE_GLOSS IS NOT INITIAL ).
        CONCATENATE  LV_NOTE LV_NOTE_GLOSS
        INTO LS_REQ_DATA-NOTE
        SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
      ENDIF.

      IF LV_ORT01_CHK IS NOT INITIAL.
        CONCATENATE  '경유' LS_REQ_DATA-NOTE
              INTO LS_REQ_DATA-NOTE
              SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
      ENDIF.

      CASE LS_REQ_DATA-TRK_TON .
        WHEN 'T250'.
          CONCATENATE '평카' LS_REQ_DATA-NOTE INTO LS_REQ_DATA-NOTE
          SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
        WHEN 'L34' .
          CONCATENATE '소형' LS_REQ_DATA-NOTE INTO LS_REQ_DATA-NOTE
          SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
        WHEN'L38'.
          CONCATENATE '중형' LS_REQ_DATA-NOTE INTO LS_REQ_DATA-NOTE
          SEPARATED BY CL_ABAP_CHAR_UTILITIES=>NEWLINE.
      ENDCASE.

*- 상차지 주소지 공통 설정
      CLEAR LT_PLACE.
      WRITE GT_ALV3_SEL-WADAT TO LT_PLACE-WADAT USING EDIT MASK
  '____-__-__'.
      LT_PLACE-WAUHR   = GT_ALV3_SEL-WAUHR(4).
      LT_PLACE-PLACES_TYPE  = '1'.              " 상차
      LT_PLACE-PERNR_T    = GV_PERNR_SH_T.      " 상차담당자
      LT_PLACE-CALLBACK   = GS_SENDER-TEL_NO.   " 전화번호
      LT_PLACE-ORT01      = '전북 완주군 과학로 886'.
      LT_PLACE-KUNNR_T   =  '엘에스엠트론' .     " 회사명
      LT_PLACE-PLACES_SEQUENCE = '1'.
      APPEND LT_PLACE.

      "로지스팟 차종 및 물품명 변경
      PERFORM SET_ARKTX_TRK_TYPE USING LS_REQ_DATA-ARKTX
                                       LS_REQ_DATA-TRK_TYPE
                                       LS_REQ_DATA-TRK_TON.

      " 운송경로가 있는 기타운송일 경우는 물품명을 그대로 사용
      IF GT_ALV3_SEL-VBELN IS INITIAL      AND
         GT_ALV3_SEL-ZROUTE IS NOT INITIAL.
        LS_REQ_DATA-ARKTX =  GT_ALV3_SEL-ARKTX.
      ENDIF.

    ENDIF.

    GS_BOBJ-INSTID = GT_ALV3_SEL-ATTACH_KEY.
    PERFORM ATTACH_TO_MAIL_A TABLES LT_FILES.  "파일첨부

    LS_REQ_DATA-FREIGHT_COUNT = LV_FREIGHT_COUNT.
    CONDENSE LS_REQ_DATA-FREIGHT_COUNT NO-GAPS.

    IF LV_MIX_CHK IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    IF OK_CODE EQ 'SEND_RE'.
      LV_TYPE = 'M'.
      LV_ORD_NUM = GT_ALV3_SEL-ORD_NUM.
    ELSE.
      LV_TYPE = 'R'.
    ENDIF.

    CALL FUNCTION 'ZLE_RFC_LOGISPOT_REQ'
      EXPORTING
        I_TYPE     = LV_TYPE
        I_REQ_DATA = LS_REQ_DATA
        I_ORD_NUM  = LV_ORD_NUM
        I_TOKEN    = LV_TOKEN
        I_DEST     = LV_DEST
        IT_FILES   = LT_FILES
      IMPORTING
        E_ORD_NUM  = LV_ORD_NUM
        E_RESULT   = LV_RESULT
        E_ERR_MSG  = LV_ERR_MSG
        E_STATUS   = LV_STATUS
      TABLES
        PT_PLACE   = LT_PLACE
        PT_PAYS    = LT_PAYS
        PT_MEMO    = LT_MEMO.


    IF SY-UNAME(4) = 'ZLSG' AND SY-DATUM < '20231001'.
*___HANA 통합테스트용
      SELECT MAX( ORD_NUM )
        INTO LV_ORD_NUM
        FROM ZLET0108
       WHERE ORD_NUM BETWEEN '1794000' AND '1799999'.

      LV_ORD_NUM = LV_ORD_NUM + 1.
      CONDENSE LV_ORD_NUM NO-GAPS.
    ENDIF.

    IF LV_ORD_NUM IS INITIAL.
      CLEAR : LT_MEMO , LT_MEMO[],
              LT_PAYS , LT_PAYS[],
              LT_PLACE, LT_PLACE[],
              LT_FILES[],
              LS_REQ_DATA , LV_TBRGEW , LV_NOTE,
              LV_GROES , LV_NOTE_GLOSS , LV_FREIGHT_COUNT ,
              LV_ORT01_CHK,   LV_ORT01.


      GF_LOGI_ERR = GC_X.

*-  상태표시
      GT_ALV3_SEL-LOGI_STATUS = ICON_LED_RED.

      IF GT_ALV3_SEL-STATUS(3) NE 'MIX'.
        MODIFY GT_ALV3_SEL TRANSPORTING ORD_NUM LOGI_STATUS.
      ELSE.
        MODIFY GT_ALV3_SEL TRANSPORTING ORD_NUM LOGI_STATUS
                             WHERE STATUS = GT_ALV3_SEL-STATUS.
      ENDIF.

      CONTINUE.

    ELSE.
      CLEAR : LT_0108, LT_0108A, LT_0108A[].

      GT_ALV3_SEL-ORD_NUM     = LV_ORD_NUM.

*-  상태표시
      IF   LV_TYPE = 'R'   OR       "요청이거나
         ( LV_TYPE = 'M' AND LV_STATUS EQ '5' ).  "정상변경이 성공한경우
        GT_ALV3_SEL-LOGI_STATUS =  ICON_LED_GREEN.

        CLEAR : GT_ALV3-ORD_NUM, GT_ALV3-STATUS.
        MODIFY GT_ALV3 TRANSPORTING ORD_NUM  STATUS
                             WHERE ORD_NUM = GT_ALV3_SEL-ORD_NUM.


      ELSE. "정상변경이 실패한 경우
        GT_ALV3_SEL-LOGI_STATUS = ICON_LED_RED.
        GF_LOGI_ERR = GC_X.
      ENDIF.

      IF GT_ALV3_SEL-STATUS(3) NE 'MIX'.
        MODIFY GT_ALV3_SEL TRANSPORTING ORD_NUM LOGI_STATUS.
      ELSE.
        MODIFY GT_ALV3_SEL TRANSPORTING ORD_NUM LOGI_STATUS
                             WHERE STATUS = GT_ALV3_SEL-STATUS.
      ENDIF.

    ENDIF .

    IF LV_TYPE = 'M' AND LV_STATUS NE '5'. "정상변경 실패시
      CLEAR : LT_MEMO  , LT_MEMO[],
              LT_PLACE , LT_PLACE[],
              LT_PAYS  , LT_PAYS[],
              LV_TBRGEW, LV_GROES, LV_NOTE,
              LT_FILES[],
              LS_REQ_DATA, LV_NOTE_GLOSS, LV_FREIGHT_COUNT,
              LV_ORT01_CHK,   LV_ORT01.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING LS_REQ_DATA TO LT_0108.

    LOOP AT LT_MEMO.
      IF LT_MEMO-M_TYPE EQ '1'.
        LT_0108-MEMO_1 = LT_MEMO-MEMO.
      ENDIF.
      IF LT_MEMO-M_TYPE EQ '2'.
        LT_0108-MEMO_2 = LT_MEMO-MEMO.
      ENDIF.
    ENDLOOP.

    LT_0108-ORD_NUM =  LV_ORD_NUM.
    LT_0108-STATUS  =  LV_STATUS.

    CALL FUNCTION 'ZMM_SET_CBO_DATE_SINGLE'
      CHANGING
        PS_DATA = LT_0108.


    MODIFY ZLET0108 FROM LT_0108.

    LOOP AT LT_PLACE.
      CLEAR LT_0108A.
      MOVE-CORRESPONDING LT_PLACE TO LT_0108A.
      LT_0108A-ORD_NUM  =  LT_0108-ORD_NUM.
      APPEND LT_0108A.
    ENDLOOP.

    MODIFY ZLET0108A FROM TABLE LT_0108A.

    CLEAR : LT_MEMO  , LT_MEMO[],
            LT_PLACE , LT_PLACE[],
            LT_PAYS  , LT_PAYS[],
            LV_TBRGEW, LV_GROES, LV_NOTE,
            LT_FILES[],
            LS_REQ_DATA, LV_NOTE_GLOSS, LV_FREIGHT_COUNT,
            LV_ORT01_CHK,   LV_ORT01.
  ENDLOOP.


  LOOP AT GT_ALV3_SEL.
    MODIFY GT_ALV3 FROM  GT_ALV3_SEL
                  INDEX  GT_ALV3_SEL-ROW_INDEX
                  TRANSPORTING LOGI_STATUS ORD_NUM.
  ENDLOOP.



*  LOOP AT GT_ALV3_SEL.
*    MODIFY GT_ALV3 FROM  GT_ALV3_SEL
*                  TRANSPORTING LOGI_STATUS ORD_NUM
*                  WHERE VBELN EQ GT_ALV3_SEL-VBELN
*                    AND POSNR EQ GT_ALV3_SEL-POSNR .
*  ENDLOOP.



ENDFORM.                    " SEND_MSG_TO_TDLNT_BY_LOGISPOT
*&---------------------------------------------------------------------*
*&      Form  GET_ADDRESS_AVL3_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV3_ORT01  text
*      <--P_LT_PLACE_ORT01  text
*----------------------------------------------------------------------*
FORM GET_ADDRESS_AVL3_2   USING   P_ORT01
                       CHANGING   P_ADDRESS.

  DATA : LV_FIELD1(20), LV_FIELD2(20), LV_FIELD3(20),
         LV_FIELD4(20), LV_FIELD5(20).


  CONDENSE P_ORT01.

  P_ADDRESS = P_ORT01 .

  SPLIT P_ORT01 AT SPACE
   INTO LV_FIELD1 LV_FIELD2 LV_FIELD3 LV_FIELD4 LV_FIELD5.

  IF LV_FIELD1(4) CA '01234567890-'.  "우편번호는 패스
    REPLACE ALL OCCURRENCES OF LV_FIELD1  IN P_ADDRESS  WITH SPACE.
  ENDIF.

  CONDENSE P_ADDRESS.

ENDFORM.                    " GET_ADDRESS_AVL3_2
*&---------------------------------------------------------------------*
*&      Form  CONNECT_LOGIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_DEST  text
*      -->P_LV_TOKEN  text
*----------------------------------------------------------------------*
FORM CONNECT_LOGIST  USING    P_DEST
                              P_TOKEN.

  DATA : LV_TOKEN TYPE STRING.
  DATA: LV_DEST  TYPE ZIFDEST-DEST,
        LV_GUBUN TYPE ZIFDEST-GUBUN VALUE 'LE'.

  DATA : LV_CLINT_ID      TYPE  CHAR100,
         LV_CLIENT_SECRET TYPE  CHAR100,
         LV_GRANT_TYPE    TYPE  CHAR100 VALUE 'client_credentials'.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = LV_GUBUN
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.


  CHECK LV_DEST IS NOT INITIAL.

  LV_CLINT_ID        = GS_SENDER-CLINT_ID.
  LV_CLIENT_SECRET   = GS_SENDER-CLIENT_SECRET.


  IF LV_CLINT_ID IS INITIAL  OR LV_CLIENT_SECRET IS INITIAL.
    SELECT SINGLE CLINT_ID CLIENT_SECRET
       INTO (LV_CLINT_ID, LV_CLIENT_SECRET)
      FROM ZLET0106
     WHERE INACTIVE      EQ SPACE
       AND CLINT_ID      NE SPACE
       AND CLIENT_SECRET NE SPACE .

  ENDIF.

  CALL FUNCTION 'ZLE_RFC_LOGISPOT_CONNECT'
    DESTINATION LV_DEST
    EXPORTING
      CLINT_ID              = LV_CLINT_ID
      CLIENT_SECRET         = LV_CLIENT_SECRET
      GRANT_TYPE            = LV_GRANT_TYPE
    IMPORTING
      TOKEN                 = LV_TOKEN
    EXCEPTIONS
      SYSTEM_FAILURE        = 1
      COMMUNICATION_FAILURE = 2
                              OTHERS.


  IF LV_TOKEN IS  INITIAL.
    EXIT.
  ENDIF.

  P_DEST = LV_DEST.
  P_TOKEN = LV_TOKEN.

ENDFORM.                    " CONNECT_LOGIST
*&---------------------------------------------------------------------*
*&      Form  SET_ARKTX_TRK_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ARKTX_TRK_TYPE  USING    P_ARKTX
                                  P_TRK_TYPE
                                  P_TRK_TON.

  DATA : LV_TRK_TON  LIKE ZLET0108B-LTRK_TON,
         LV_TRK_TYPE LIKE ZLET0108B-LTRK_TYPE,
         LV_TRKTON   LIKE ZLET0108B-TRKTON,
         LT_TEMP(20).


  SELECT SINGLE  BEZEI INTO WA-TPLST_T
     FROM TTDST
    WHERE TPLST = WA-TPLST.

  FIND '트랙터'  IN  WA-TPLST_T.
  IF SY-SUBRC EQ 0.
    P_ARKTX = '트랙터'.
  ELSE.
    FIND '사출'  IN  WA-TPLST_T.
    IF SY-SUBRC EQ 0.
      P_ARKTX = '사출기'.
    ELSE.
      FIND '특수'  IN  WA-TPLST_T.
      IF SY-SUBRC EQ 0.
        P_ARKTX = '방산품'.
      ELSE.
        P_ARKTX =  '기타'.
      ENDIF.
    ENDIF.
  ENDIF.


  LV_TRKTON = P_TRK_TON.

  SELECT SINGLE LTRK_TON LTRK_TYPE
    INTO (LV_TRK_TON, LV_TRK_TYPE)
    FROM ZLET0108B
   WHERE TRKTON EQ LV_TRKTON.

  P_TRK_TON  = LV_TRK_TON.
  P_TRK_TYPE = LV_TRK_TYPE.

ENDFORM.                    " SET_ARKTX_TRK_TYPE
*&---------------------------------------------------------------------*
*&      Form  CANCEL_MSG_TO_TDLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_MSG_TO_TDLNR .

  DATA : LT_ALV3_TMP LIKE TABLE OF  GT_ALV3_SEL  WITH HEADER LINE,
         LV_ORD_NUM  LIKE GT_ALV3-ORD_NUM.

  CLEAR  : GT_SMS     , GT_SMS[]   ,
           GT_SMS_1   , GT_SMS_1[] ,
           GT_ALV3_SEL, GT_ALV3_SEL[].


  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                            USING   GRID3
                         CHANGING   GV_CHK.
  CHECK GV_CHK IS INITIAL.

  CLEAR GF_LOGI_ERR.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF SY-SUBRC EQ  0.
      IF GT_ALV3-ORD_NUM IS INITIAL.
        PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ORD_NUM '.
        MESSAGE E001 WITH '배차요청되지 않은 내역이 있습니다.'.
      ENDIF.
    ENDIF.
  ENDLOOP.


  PERFORM CHECK_INPUT_DATA_ALV3 .
  CHECK GV_CHK IS INITIAL.


  PERFORM POPUP_TO_CONFIRM
    USING '운송사 배차취소'
    '선택한 라인의 배차요청을 취소하시겠습니까?'
           '1'     GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.
  PERFORM CONNECT_LOGIST USING GV_DEST GV_TOKEN.


*-[CHM2209-00002] 복수의 다른 배차오더처리 허용 로직 수정 -[s]

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF SY-SUBRC EQ 0 AND GT_ALV3-ORD_NUM IS NOT INITIAL.
      APPEND GT_ALV3  TO LT_ALV3_TMP.
    ENDIF.
  ENDLOOP.


  SORT LT_ALV3_TMP BY ORD_NUM .

  LOOP AT LT_ALV3_TMP.

    IF LV_ORD_NUM  IS INITIAL.
      LV_ORD_NUM  = LT_ALV3_TMP-ORD_NUM .
    ENDIF.

    IF LV_ORD_NUM  EQ LT_ALV3_TMP-ORD_NUM .
      APPEND LT_ALV3_TMP  TO GT_ALV3_SEL.
      CONTINUE.
    ENDIF.

    IF LV_ORD_NUM <>  LT_ALV3_TMP-ORD_NUM .
      PERFORM EXECU_CANC_REQUEST USING LV_ORD_NUM.
      LV_ORD_NUM = LT_ALV3_TMP-ORD_NUM.
      CLEAR : GT_ALV3_SEL, GT_ALV3_SEL[].
      APPEND LT_ALV3_TMP  TO GT_ALV3_SEL.
    ENDIF.
  ENDLOOP.


  IF GT_ALV3_SEL[] IS NOT INITIAL.
    PERFORM EXECU_CANC_REQUEST USING LV_ORD_NUM.
  ENDIF.

*-[CHM2209-00002] 복수의 다른 배차오더처리 허용 로직 수정 -[e]


  IF GF_LOGI_ERR IS INITIAL.
    MESSAGE I001 WITH '정상 취소요청 되었습니다. '.
  ELSE.
    MESSAGE I001 WITH '일부(전부) 실패한 내역이 있습니다.'.
  ENDIF.

  PERFORM DATA_QUERY TABLES GT_ALV1
                            R_VBELN.


ENDFORM.                    " CANCEL_MSG_TO_TDLNR

*&---------------------------------------------------------------------*
*&      Form  ATTACH_TO_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ATTACH_TO_MAIL_A TABLES PT_FILES .

*-- Get Attached File Counter

  DATA: LS_BOBJ TYPE SIBFLPORB,
        LS_STAT TYPE SGS_S_ACNT,
        LT_STAT TYPE SGS_T_ACNT,
        LV_MODE .

  DATA : LV_DOCUMENT_ID        TYPE SOFOLENTI1-DOC_ID,
         LWA_DOCUMENT_DATA     LIKE SOFOLENTI1,
         LT_OBJECT_CONTENT_TMP LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE.

  DATA : LT_GOS_CON TYPE TABLE OF BDN_CON,
         LS_GOS_CON TYPE BDN_CON.

  DATA : LV_CLASS LIKE BAPIBDS01-CLASSNAME,
         LV_OBJKE LIKE SWOTOBJID-OBJKEY.

  DATA : LV_SIZE TYPE I,
         LV_FILE TYPE XSTRING,
         EV_FILE TYPE STRING.

  DATA : LT_FILES TYPE ZLET0109 WITH HEADER LINE.


*  COMMIT WORK AND WAIT.

  CLEAR LT_STAT.
  CALL METHOD CL_GOS_ATTACHMENT_QUERY=>COUNT_FOR_OBJECT
    EXPORTING
      IS_OBJECT = GS_BOBJ
      IP_ARL    = SPACE
    RECEIVING
      RT_STAT   = LT_STAT.

  CLEAR LS_STAT.
  READ TABLE LT_STAT INTO LS_STAT INDEX 1.
  GV_ATTACH_CNT = LS_STAT-COUNTER.

  CHECK GV_ATTACH_CNT > 0. "1건 이상인 경우 첨부

  LV_CLASS = GS_BOBJ-TYPEID.
  LV_OBJKE = GS_BOBJ-INSTID.


*-- 송신시(테스트)

  "저장된 첨부파일 데이터 추출
  CALL FUNCTION 'BDS_GOS_CONNECTIONS_GET'
    EXPORTING
      CLASSNAME          = LV_CLASS
      OBJKEY             = LV_OBJKE
      CLIENT             = SY-MANDT
    TABLES
      GOS_CONNECTIONS    = LT_GOS_CON
    EXCEPTIONS
      NO_OBJECTS_FOUND   = 1
      INTERNAL_ERROR     = 2
      INTERNAL_GOS_ERROR = 3
      OTHERS             = 4.

  LOOP AT LT_GOS_CON INTO LS_GOS_CON.

    REFRESH  G_OBJCONT1.
    MOVE LS_GOS_CON-LOIO_ID TO LV_DOCUMENT_ID.


    DATA LT_OBJECT_HEX LIKE SOLIX OCCURS 0 WITH HEADER LINE.

* Read the data
    CALL FUNCTION 'SO_DOCUMENT_READ_API1'
      EXPORTING
        DOCUMENT_ID                = LV_DOCUMENT_ID
      IMPORTING
        DOCUMENT_DATA              = LWA_DOCUMENT_DATA
      TABLES
*       OBJECT_CONTENT             = LT_OBJECT_CONTENT_TMP
        CONTENTS_HEX               = LT_OBJECT_HEX
      EXCEPTIONS
        DOCUMENT_ID_NOT_EXIST      = 1
        OPERATION_NO_AUTHORIZATION = 2
        X_ERROR                    = 3
        OTHERS                     = 4.

    LV_SIZE  = LWA_DOCUMENT_DATA-DOC_SIZE.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        INPUT_LENGTH = LV_SIZE
      IMPORTING
        BUFFER       = LV_FILE
      TABLES
*       BINARY_TAB   = LT_OBJECT_CONTENT_TMP
        BINARY_TAB   = LT_OBJECT_HEX
      EXCEPTIONS
        FAILED       = 1
        OTHERS       = 2.


    CALL FUNCTION 'SSFC_BASE64_ENCODE'
      EXPORTING
        BINDATA = LV_FILE  " xstring
      IMPORTING
        B64DATA = EV_FILE  " string
      EXCEPTIONS
        OTHERS  = 1. " Over simplifying exception handling

    LT_FILES-TYPE     =  LWA_DOCUMENT_DATA-OBJ_TYPE.
    CONCATENATE LWA_DOCUMENT_DATA-OBJ_DESCR '.'
                LWA_DOCUMENT_DATA-OBJ_TYPE
    INTO LT_FILES-NAME.

    LT_FILES-CONTENT  =  EV_FILE .
    APPEND LT_FILES TO PT_FILES .


*
**-- 수신시(테스트)
*    CALL FUNCTION 'SSFC_BASE64_DECODE'
*      EXPORTING
*        B64DATA = EV_FILE
*      IMPORTING
*        BINDATA = LV_FILE
*      EXCEPTIONS
*        OTHERS  = 1. " Over simplifying exception handling
*
*
*    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*      EXPORTING
*        BUFFER        = LV_FILE
*      IMPORTING
*        OUTPUT_LENGTH = LV_SIZE
*      TABLES
*        BINARY_TAB    = LT_OBJECT_HEX.
*
*    DATA: LS_FOLDER TYPE SOODK.
*
*    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
*      EXPORTING
*        REGION    = 'B'
*      IMPORTING
*        FOLDER_ID = LS_FOLDER
*      EXCEPTIONS
*        OTHERS    = 1.
*
*
*
*    DATA:  LS_DOCDAT  TYPE SODOCCHGI1,
*           IV_DOCTYPE  TYPE SO_OBJ_TP VALUE 'PDF' .
*
*    LS_DOCDAT-DOC_SIZE  = LV_SIZE.
*    LS_DOCDAT-OBJ_NAME  = 'OBJ_NAME'.
*    LS_DOCDAT-OBJ_DESCR = 'OBJ_DESCR'.
*
*    CLEAR LWA_DOCUMENT_DATA.
*
*    CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
*      EXPORTING
*        FOLDER_ID                  = LS_FOLDER
*        DOCUMENT_DATA              = LS_DOCDAT
*        DOCUMENT_TYPE              = IV_DOCTYPE
*      IMPORTING
*        DOCUMENT_INFO              = LWA_DOCUMENT_DATA
*      TABLES
*        CONTENTS_HEX               = LT_OBJECT_HEX
*      EXCEPTIONS
*        FOLDER_NOT_EXIST           = 1
*        DOCUMENT_TYPE_NOT_EXIST    = 2
*        OPERATION_NO_AUTHORIZATION = 3
*        PARAMETER_ERROR            = 4
*        X_ERROR                    = 5
*        ENQUEUE_ERROR              = 6
*        OTHERS                     = 7.

  ENDLOOP.

*
*
*  DATA:   LS_OBJECT        TYPE BORIDENT,
*          LS_ATTACHMNT     TYPE BORIDENT.
*
*  CONCATENATE  'ATT_' SY-DATUM '_' SY-UZEIT INTO LS_OBJECT-OBJKEY.
*  LS_OBJECT-OBJTYPE = 'ZLER0101'.
*
*  LS_ATTACHMNT-OBJTYPE = 'MESSAGE'.
*  LS_ATTACHMNT-OBJKEY  = LWA_DOCUMENT_DATA-DOC_ID(34).
*
*  CALL FUNCTION 'BINARY_RELATION_CREATE'
*    EXPORTING
*      OBJ_ROLEA      = LS_OBJECT
*      OBJ_ROLEB      = LS_ATTACHMNT
*      RELATIONTYPE   = 'ATTA'
*      FIRE_EVENTS    = ABAP_FALSE
*    EXCEPTIONS
*      NO_MODEL       = 1
*      INTERNAL_ERROR = 2
*      UNKNOWN        = 3
*      OTHERS         = 4.
*
*  IF SY-SUBRC <> 0.
*  ELSE.
*    COMMIT WORK AND WAIT.
*  ENDIF.



ENDFORM.                    " ATTACH_TO_MAIL
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_ALV1 .
    GT_ALV1-SEL = GC_X.
    MODIFY GT_ALV1 TRANSPORTING SEL.
  ENDLOOP.


  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESELECT_ALL .

  LOOP AT GT_ALV1 .
    CLEAR GT_ALV1-SEL.
    MODIFY GT_ALV1 TRANSPORTING SEL.
  ENDLOOP.


  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

ENDFORM.                    " DESELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  PRINT_JOB_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_JOB_ORD .

  DATA: LV_FM_NAME      TYPE RS38L_FNAM.


  PERFORM CALL_FUNCTION_SSF_NAME USING 'Z_LE_DTP_FORM'
                              CHANGING  LV_FM_NAME.


  PERFORM SET_CONTROL_OPTIONS.
  PERFORM CALL_FUNCTION_SSF_OPEN.
  PERFORM CALL_SSF_FUNCTION USING LV_FM_NAME.
  PERFORM CALL_FUNCTION_SSF_CLOSE.



ENDFORM.                    " PRINT_JOB_ORD
*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_SSF_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_PO_LIST  text
*      <--P_LV_FM_NAME  text
*----------------------------------------------------------------------*
FORM CALL_FUNCTION_SSF_NAME  USING    PV_SMARTFORMS
                             CHANGING PV_FM_NAME.


  CLEAR PV_FM_NAME.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = PV_SMARTFORMS
    IMPORTING
      FM_NAME            = PV_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.




ENDFORM.                    " call_function_ssf_name
*&---------------------------------------------------------------------*
*&      Form  CALL_SSF_FUNCTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FM_NAME  text
*----------------------------------------------------------------------*
FORM CALL_FUNCTION_SSF_OPEN .

  CALL FUNCTION 'SSF_OPEN'
    EXPORTING
      CONTROL_PARAMETERS = GS_CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = GS_OUTPUT_OPTIONS
    EXCEPTIONS
      FORMATTING_ERROR   = 1
      INTERNAL_ERROR     = 2
      SEND_ERROR         = 3
      USER_CANCELED      = 4
      OTHERS             = 5.

ENDFORM.                    " call_function_ssf_open
*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_SSF_CLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_FUNCTION_SSF_CLOSE .
  CALL FUNCTION 'SSF_CLOSE'
    EXCEPTIONS
      FORMATTING_ERROR = 1
      INTERNAL_ERROR   = 2
      SEND_ERROR       = 3
      OTHERS           = 4.

ENDFORM.                    " CALL_FUNCTION_SSF_CLOSE
*&---------------------------------------------------------------------*
*&      Form  SET_CONTROL_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CONTROL_OPTIONS .


  CLEAR: GS_CONTROL_PARAMETERS,   GS_OUTPUT_OPTIONS.

  GS_CONTROL_PARAMETERS-PREVIEW    = GC_X.
  GS_CONTROL_PARAMETERS-NO_OPEN    = GC_X.
  GS_CONTROL_PARAMETERS-NO_CLOSE   = GC_X.
  GS_CONTROL_PARAMETERS-NO_DIALOG  = GC_X.
  GS_CONTROL_PARAMETERS-LANGU      = SY-LANGU.
  GS_OUTPUT_OPTIONS-TDDELETE       = GC_X.


ENDFORM.                    " SET_CONTROL_OPTIONS
*&---------------------------------------------------------------------*
*&      Form  CALL_SSF_FUNCTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FM_NAME  text
*----------------------------------------------------------------------*
FORM CALL_SSF_FUNCTION  USING    PV_FM_NAME.

  CALL FUNCTION PV_FM_NAME
    EXPORTING
      WORK_ORDER         = ZLES042
      CONTROL_PARAMETERS = GS_CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = GS_OUTPUT_OPTIONS
*    TABLES
*     T_INTERFACE        = GT_INTERFACE
    EXCEPTIONS
      FORMATTING_ERROR   = 1
      INTERNAL_ERROR     = 2
      SEND_ERROR         = 3
      USER_CANCELED      = 4
      OTHERS             = 5.


ENDFORM.                    " CALL_SSF_FUNCTION
*&---------------------------------------------------------------------*
*&      Form  SET_JOB_ORDER_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_JOB_ORDER_INIT .


  DATA : LV_TOKEN TYPE STRING,
         LV_DEST  TYPE ZIFDEST-DEST.


  DATA : LT_PLACE        LIKE TABLE OF ZLES0106 WITH HEADER LINE,
         LT_PAYS         LIKE TABLE OF ZLES0107 WITH HEADER LINE,
         LT_MEMO         LIKE TABLE OF ZLES0108 WITH HEADER LINE,
         LT_ETC          LIKE TABLE OF ZLES0111 WITH HEADER LINE,

         LT_PLACE_T      LIKE TABLE OF ZLES0106 WITH HEADER LINE,
         LT_PAYS_T       LIKE TABLE OF ZLES0107 WITH HEADER LINE,
         LT_MEMO_T       LIKE TABLE OF ZLES0108 WITH HEADER LINE,
         LT_REQ_DATA_T   LIKE TABLE OF ZLES0105 WITH HEADER LINE,

         LS_REQ_DATA     LIKE ZLES0105,
         LV_ORD_NUM(10),
         LV_RESULT,
         LV_ERR_MSG(255),
         LV_STATUS,

         LV_TEMP(100),
         LV_TEMP1(20),
         LV_TEMP2(20),
         LV_NUM(2).

  FIELD-SYMBOLS : <LV_FIELD>  TYPE ANY,
                  <LV_FIELD2> TYPE ANY.

  CLEAR : GT_ALV3-ORD_NUM.

  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                           USING   GRID3
                        CHANGING   GV_CHK.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
    IF SY-SUBRC EQ  0 AND GT_ALV3-ORD_NUM IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF GT_ALV3-ORD_NUM IS  INITIAL.
    MESSAGE S001 WITH '배차완료된 라인을 선택해주십시오'
        DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM CONNECT_LOGIST USING LV_DEST LV_TOKEN.

  IF LV_TOKEN IS INITIAL OR LV_DEST  IS INITIAL.
    MESSAGE S001 WITH '로지스팟 접속실패.담당자에게 문의하십시오'
      DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  CLEAR : ZLES042.

  CALL FUNCTION 'ZLE_RFC_LOGISPOT_REQ'
    EXPORTING
      I_TYPE     = 'D'
      I_ORD_NUM  = GT_ALV3-ORD_NUM
      I_TOKEN    = LV_TOKEN
      I_DEST     = LV_DEST
    IMPORTING
      E_ORD_NUM  = LV_ORD_NUM
      E_RESULT   = LV_RESULT
      E_ERR_MSG  = LV_ERR_MSG
      E_STATUS   = LV_STATUS
      E_REQ_DATA = LS_REQ_DATA
    TABLES
      PT_PLACE   = LT_PLACE
      PT_PAYS    = LT_PAYS
      PT_MEMO    = LT_MEMO
      PT_ETC     = LT_ETC.


  IF LS_REQ_DATA-REMARK_DRIVER IS NOT INITIAL.
    SPLIT  LS_REQ_DATA-REMARK_DRIVER AT
                           CL_ABAP_CHAR_UTILITIES=>NEWLINE
    INTO  ZLES042-PRODUCT_1 ZLES042-PRODUCT_2
          ZLES042-PRODUCT_3 ZLES042-PRODUCT_4
          ZLES042-PRODUCT_5 ZLES042-PRODUCT_6
          ZLES042-PRODUCT_7 ZLES042-PRODUCT_8
          ZLES042-PRODUCT_9 ZLES042-PRODUCT_10.
  ENDIF.

*  ZLES042-NAME        =  LS_REQ_DATA-DRIVER_NM.
*  ZLES042-CONTACT_NO  =  LS_REQ_DATA-DRIVER_TELNO.
  ZLES042-CAR_NO      =  LS_REQ_DATA-TRUCK_NO.
*  ZLES042-ITEM_QTY    =  LS_REQ_DATA-FREIGHT_COUNT.



  SELECT SINGLE TPLST INTO ZLES042-DELV_PLACE
    FROM ZLET0108C
    WHERE TPLST_L  EQ LS_REQ_DATA-TPLST.


  IF ZLES042-DELV_PLACE IS NOT INITIAL.
    SELECT SINGLE  BEZEI INTO ZLES042-DELV_PLACE
       FROM TTDST
      WHERE TPLST = ZLES042-DELV_PLACE.
  ENDIF.

*  FIND '-' IN ZLES042-DELV_PLACE .
*  IF SY-SUBRC EQ 0.
*    SPLIT ZLES042-DELV_PLACE  AT '-' INTO LV_TEMP
*                               ZLES042-DELV_PLACE.
*  ENDIF.

  FIND '트랙터'  IN  ZLES042-DELV_PLACE.
  IF SY-SUBRC EQ 0.
    ZLES042-TYPE = '트랙터'.
*      CONCATENATE ZLES042-ITEM_QTY '대' INTO ZLES042-ITEM_QTY.
  ELSE.
    FIND '사출'  IN  ZLES042-DELV_PLACE.
    IF SY-SUBRC EQ 0.
      ZLES042-TYPE = '사출기'.
*        CONCATENATE ZLES042-ITEM_QTY '대' INTO ZLES042-ITEM_QTY.
    ELSE.
      FIND '특수'  IN  ZLES042-DELV_PLACE.
      IF SY-SUBRC EQ 0.
        ZLES042-TYPE = '방산품'.
*          CONCATENATE ZLES042-ITEM_QTY '개' INTO ZLES042-ITEM_QTY.
      ELSE.
        ZLES042-TYPE =  '기타'.
*          CONCATENATE ZLES042-ITEM_QTY '개' INTO ZLES042-ITEM_QTY.
      ENDIF.
    ENDIF.
  ENDIF.




  LOOP AT GT_ALV3 WHERE ORD_NUM EQ GT_ALV3-ORD_NUM.
    LV_NUM = SY-TABIX.
    CONDENSE LV_NUM NO-GAPS.
    CONCATENATE 'ZLES042-PRODUCT_' LV_NUM INTO LV_TEMP1.
    CONCATENATE 'ZLES042-ITEM_QTY_' LV_NUM INTO LV_TEMP2.

    ASSIGN (LV_TEMP1) TO <LV_FIELD>.
    ASSIGN (LV_TEMP2) TO <LV_FIELD2>.
    IF <LV_FIELD> IS ASSIGNED.
      <LV_FIELD> = GT_ALV3-ARKTX.
    ENDIF.

    IF <LV_FIELD2> IS ASSIGNED.
      IF  GT_ALV3-LFIMG IS NOT INITIAL.
*          <LV_FIELD2> = GT_ALV3-LFIMG.
        WRITE GT_ALV3-LFIMG TO <LV_FIELD2> UNIT GT_ALV3-VRKME .
      ELSE.
        <LV_FIELD2> = 1.
      ENDIF.
    ENDIF.

    CONDENSE <LV_FIELD2> NO-GAPS.

    CASE ZLES042-TYPE.
      WHEN '트랙터' OR '사출' .
        CONCATENATE <LV_FIELD2> '대' INTO <LV_FIELD2>.
      WHEN OTHERS.
        CONCATENATE <LV_FIELD2> '개' INTO <LV_FIELD2>.
    ENDCASE.

  ENDLOOP.


  CLEAR ZLES042-DELV_PLACE.
  LOOP AT LT_PLACE WHERE PLACES_TYPE NE '1'.
    IF ZLES042-DELV_ADDRESS1 IS INITIAL.
      ZLES042-DELV_ADDRESS1 =  LT_PLACE-KUNNR_T  .
    ELSE.
      ZLES042-DELV_ADDRESS2  =  LT_PLACE-KUNNR_T  .
    ENDIF.

    IF ZLES042-DELV_PLACE IS INITIAL.
      PERFORM GET_ADDRESS_ALV3 USING   LT_PLACE-ORT01
                            CHANGING   ZLES042-DELV_PLACE.
    ENDIF.
  ENDLOOP.


  WRITE : SY-DATUM TO  ZLES042-WORK_DATE USING EDIT MASK
  '____ . __. __.'.


  SPLIT GT_ALV3-TRK_TON_T AT ` ` INTO LV_TEMP1 ZLES042-CAR_TYPE .

  CONDENSE ZLES042-CAR_TYPE NO-GAPS.


  CALL SCREEN '700' STARTING AT 1  1.


ENDFORM.                    " SET_JOB_ORDER_INIT

*&---------------------------------------------------------------------*
*&      Form  save4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE4 .

  PERFORM ERROR_CHECK_BEFORE_SAVE3.

  PERFORM EXEC_VT01N_M.

ENDFORM.                                                    " save3
*&---------------------------------------------------------------------*
*&      Form  EXEC_VT01N_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_VT01N_M .

  DATA: LS_DATA LIKE ZLES043.

  READ TABLE GT_ALV1 WITH KEY SEL = 'X'.
  CHECK SY-SUBRC EQ 0.

  IF GT_ALV1-LOGI_STATUS NE 2 AND
     GT_ALV1-LOGI_STATUS NE 3 AND
     GT_ALV1-LOGI_STATUS NE 4  .
    MESSAGE E000 WITH '배차완료되지 않은 항목입니다.'.
  ENDIF.


  MOVE-CORRESPONDING GT_ALV1 TO LS_DATA.

  CLEAR: GV_RETURN, GV_ZMSG.

  BDC_MODE = 'E'.
  CALL FUNCTION 'Z_LE_VT01N_M'
    EXPORTING
      I_TPLST  = WA-TPLST
      I_SHTYP  = WA-SHTYP
      I_MODE   = BDC_MODE
      I_DATA   = LS_DATA
    IMPORTING
      RETURN   = GV_RETURN
      ZMESSAGE = GV_ZMSG
    TABLES
      TAB1     = GT_TAB1.

  SET SCREEN 0.


ENDFORM.                    " EXEC_VT01N_M
*&---------------------------------------------------------------------*
*&      Form  REQUEST_CHECK_RB03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4259   text
*----------------------------------------------------------------------*
FORM REQUEST_CHECK_R03  USING  P_REQUEST.

  CHECK R03 IS NOT INITIAL.

  LOOP AT GT_ALV1 WHERE SEL = 'X'.

    IF P_REQUEST EQ 'R' AND  "요청상태
        GT_ALV1-FLAG IS NOT INITIAL.
      MESSAGE S000 WITH '요청완료된 항목이 존재합니다.'.
      LEAVE SCREEN.
    ELSEIF  P_REQUEST EQ 'C' AND  "요청완료상태
           GT_ALV1-FLAG IS INITIAL.
      MESSAGE S000 WITH '미요청된 항목이 존재합니다.'.
      LEAVE SCREEN.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " REQUEST_CHECK_RB03
*&---------------------------------------------------------------------*
*&      Form  RMODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RMODIFY .

*/ 에러 체크
  PERFORM ERROR_CHECK_BEFORE_SHIP1.

  PERFORM GRID_CHECK_CHANGED_DATA USING GRID1."ALV최신화

  LOOP AT GT_ALV1 WHERE SEL = 'X'.

    IF GT_ALV1-LOGI_STATUS  NE 2 AND
       GT_ALV1-LOGI_STATUS  NE 3 AND
       GT_ALV1-LOGI_STATUS  NE 4   .
      MESSAGE S000 WITH '배차완료된 항목만 수정가능합니다'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

  PERFORM POPUP_TO_CONFIRM
    USING '배차정보수정'
    '선택한 내용을 수정등록하시겠습니까?'
           '2'     GV_ANSWER.

  CHECK GV_ANSWER EQ '1'.

  LOOP AT GT_ALV1 WHERE SEL = 'X' .

    UPDATE ZLET0105 SET  ORD_NUM     = GT_ALV1-ORD_NUM
                   WHERE VBELN  EQ GT_ALV1-VBELN
                    AND ORD_NUM      = GT_ALV1-ORD_NUM_OLD.
    IF SY-SUBRC EQ 0.
      GT_ALV1-ORD_NUM_OLD = GT_ALV1-ORD_NUM .
      MODIFY GT_ALV1 TRANSPORTING ORD_NUM_OLD.
    ENDIF.

  ENDLOOP.

  MESSAGE S001 WITH '정상변경되었습니다'.

ENDFORM.                    " RMODIFY
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING    PR_DATA_CHANGED  TYPE REF TO
                                   CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LT_GOOD_CELLS TYPE LVC_T_MODI,
         LS_GOOD       TYPE LVC_S_MODI.

  CLEAR : LT_GOOD_CELLS, LT_GOOD_CELLS[], LS_GOOD.
  SORT PR_DATA_CHANGED->MT_GOOD_CELLS BY ROW_ID.

  LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
    CASE LS_GOOD-FIELDNAME.
      WHEN 'ORD_NUM'.
        READ TABLE GT_ALV1 INDEX LS_GOOD-ROW_ID.
        CHECK LS_GOOD-VALUE IS NOT INITIAL.

        CLEAR ZLET0108.
        SELECT SINGLE * FROM ZLET0108 WHERE ORD_NUM =  LS_GOOD-VALUE.
        IF SY-SUBRC NE 0.
          MESSAGE S001 WITH '존재하지 않는 로지스팟번호입니다'.
          CLEAR GT_ALV1-ORD_NUM .
          PERFORM MODIFY_CELL USING PR_DATA_CHANGED
                                    LS_GOOD-ROW_ID
                                    'ORD_NUM'    GT_ALV1-ORD_NUM.
          CONTINUE.
        ENDIF.

        SELECT SINGLE TRKTON INTO GT_ALV1-TRK_TON
          FROM ZLET0108B
          WHERE LTRK_TYPE EQ ZLET0108-TRK_TYPE
            AND LTRK_TON  EQ ZLET0108-TRK_TON .

        PERFORM MODIFY_CELL USING PR_DATA_CHANGED
                                  LS_GOOD-ROW_ID
                             : 'DRIVER_NM'    ZLET0108-DRIVER_NM,
                               'DRIVER_TELNO' ZLET0108-DRIVER_TELNO,
                               'TRUCK_NO'     ZLET0108-TRUCK_NO,
                               'TDLNR'        ZLET0108-TDLNR ,
                               'TRK_TON'       GT_ALV1-TRK_TON .

    ENDCASE.
  ENDLOOP.
ENDFORM.                    " HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PR_DATA_CHANGED  text
*      -->P_LS_GOOD_ROW_ID  text
*      -->P_0004   text
*      -->P_0005   text
*----------------------------------------------------------------------*
FORM MODIFY_CELL  USING    PR_DATA_CHANGED TYPE REF TO
                                   CL_ALV_CHANGED_DATA_PROTOCOL
                           P_LOW
                           P_FIELD
                           P_VALUE.

  CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = P_LOW
      I_FIELDNAME = P_FIELD
      I_VALUE     = P_VALUE.


ENDFORM.                    " MODIFY_CELL
*&---------------------------------------------------------------------*
*&      Form  ROUTE_LINE_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ROUTE_LINE_ALV3 .

  IF GS_RECEIVER-LIFNR IS INITIAL.
    MESSAGE I001 WITH '운송업체는 필수 입력입니다. '.
    EXIT.
  ENDIF.

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_ROWS LINES SY-TFILL.

  IF SY-TFILL > 1.
    MESSAGE I001 WITH '한 라인만 선택하실수 있습니다. '.
    EXIT.
  ENDIF.

  CLEAR : ZLET0210, GV_TRK_TONT.
  READ TABLE GT_ROWS INDEX 1.

  READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.

  IF GT_ALV3-ORD_NUM IS NOT INITIAL.
    MESSAGE I001 WITH '배차요청된 내역은 변경이 불가합니다. '.
    EXIT.
  ENDIF.


  MOVE-CORRESPONDING GT_ALV3 TO ZLET0210.
  ZLET0210-TDLNR = GS_RECEIVER-LIFNR.
  ZLET0210-TDLNRT = GV_TDLNR_SH_T.

  IF GT_ALV3-ZROUTE IS INITIAL.
    ZLET0210-TRK_TON =  GT_ALV3-TRK_TON_T(4).
  ENDIF.

  PERFORM GET_TRK_TONT.

  IF GF_SPOT IS NOT INITIAL.
    ZLET0210-WAERS = 'KRW'.
  ENDIF.

  CALL SCREEN '800' STARTING AT 2  2.

  PERFORM REFRESH_TABLE_DISPLAY USING GRID3.

ENDFORM.                    " ROUTE_LINE_ALV3
*&---------------------------------------------------------------------*
*&      Form  GET_TRK_TONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TRK_TONT .

  IF ZLET0210-TRK_TON IS NOT INITIAL.
    READ TABLE  F4_TAB WITH KEY  FVAL = ZLET0210-TRK_TON.
    IF SY-SUBRC EQ 0.
      ZLET0210-TRK_TONT = F4_TAB-FNAM.
    ELSE.
      MESSAGE S001 WITH '존재하지 않는 차종입니다.'.
      CLEAR ZLET0210-TRK_TONT.
    ENDIF.
  ELSE.
    CLEAR ZLET0210-TRK_TONT.
  ENDIF.

ENDFORM.                    " GET_TRK_TONT
*&---------------------------------------------------------------------*
*&      Form  ENTER_ZROUTE_TO_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENTER_ZROUTE_TO_ALV3 .


  CLEAR GF_ZROUTE.

  IF ZLET0210-ZROUTE IS INITIAL.
    MESSAGE  S001 WITH '운송경로가 비어있습니다.'.
    EXIT.
  ENDIF.

  SELECT SINGLE *
  FROM ZLET0210
 WHERE ZROUTE     EQ  ZLET0210-ZROUTE
   AND DATAB      LE  SY-DATUM
   AND DATBI      GE  SY-DATUM
   AND CHK_INACT  EQ  SPACE
   AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
           CHK_SPOT NE SPACE ) .

  IF SY-SUBRC NE 0.
    MESSAGE  S001 WITH '존재하지않는 운송경로입니다.'.
    EXIT.
  ENDIF.

  IF GT_ALV3-TRK_TON_T(4)  <> ZLET0210-TRK_TON.
    MESSAGE I004 WITH '차종이' ZLET0210-TRK_TONT
                               '으로 변경되었습니다. '.
  ENDIF.


  MOVE-CORRESPONDING ZLET0210  TO GT_ALV3.
  CONCATENATE ZLET0210-TRK_TON ` ` ZLET0210-TRK_TONT
         INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.


  MODIFY GT_ALV3 INDEX GT_ROWS-INDEX.


  LEAVE TO SCREEN 0.

ENDFORM.                    " ENTER_ZROUTE_TO_ALV3
*&---------------------------------------------------------------------*
*&      Form  DELETE_ZROUTE_TO_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ZROUTE_TO_ALV3 .
  CLEAR ZLET0210.
  ZLET0210-TDLNR = GS_RECEIVER-LIFNR.

  MOVE-CORRESPONDING ZLET0210  TO GT_ALV3.
  MODIFY GT_ALV3 INDEX GT_ROWS-INDEX.

  LEAVE TO SCREEN 0.
ENDFORM.                    " DELETE_ZROUTE_TO_ALV3
*&---------------------------------------------------------------------*
*&      Form  EXEC_ZROUTE_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_ZROUTE_F4 .
  DATA: LT_0210     LIKE ZLET0210 OCCURS 0 WITH HEADER LINE.

  DATA: SELECTFIELD  LIKE  HELP_INFO-FIELDNAME,
        IT_FIELDS    LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
        SELECT_VALUE LIKE  HELP_INFO-FLDVALUE,
        LD_TABIX     LIKE  SY-TABIX.

  DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
        FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF HEAD_TAB OCCURS 0,
          TABNAME   LIKE HELP_INFO-TABNAME,
          FIELDNAME LIKE HELP_INFO-FIELDNAME,
          HEAD_TEXT LIKE SHSTRUC-KEYWORD,
        END   OF HEAD_TAB.

  CLEAR GF_ZROUTE_F4.

  CHECK GF_SPOT IS INITIAL .

  CLEAR   : LT_0210.
  REFRESH : LT_0210.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0210
    FROM ZLET0210
   WHERE TDLNR      IN LR_TDLNR
     AND TRK_TON    IN LR_TRK_TON
     AND ZARRIVAL   IN LR_ZARRIVAL
     AND ZDEPARTURE IN LR_ZDEPARTURE
     AND DATAB      LE  SY-DATUM
     AND DATBI      GE  SY-DATUM
     AND CHK_INACT  EQ  SPACE
     AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
            CHK_SPOT NE SPACE ) .

  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH '조건에 맞는 운송경로가 없습니다'.
    EXIT.
  ENDIF.

  LOOP AT LT_0210.
    CLEAR : LT_ZROUTE.

    MOVE-CORRESPONDING LT_0210 TO LT_ZROUTE.

    WRITE LT_0210-PRICE TO LT_ZROUTE-PRICE CURRENCY  LT_ZROUTE-WAERS.

    APPEND LT_ZROUTE.
  ENDLOOP.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZLET0210'.
  IT_FIELDS-FIELDNAME  = 'ZROUTE'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0210'.
  IT_FIELDS-FIELDNAME  = 'ZDEPARTURET'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0210'.
  IT_FIELDS-FIELDNAME  = 'ZARRIVALT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0210'.
  IT_FIELDS-FIELDNAME  = 'TRK_TONT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'TVKOT'.
  IT_FIELDS-FIELDNAME  = 'VTEXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZLET0210'.
  IT_FIELDS-FIELDNAME  = 'WAERS'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

*___조회되는 팝업창의 필드명 변경
  HEAD_TAB-TABNAME    = 'TVKOT'.
  HEAD_TAB-FIELDNAME  = 'VTEXT'.
  HEAD_TAB-HEAD_TEXT  = '운송단가'.
  APPEND HEAD_TAB.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      DISPLAY                      = ' '     "'X': 조회모드
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = LT_ZROUTE
      HEADING_TABLE                = HEAD_TAB
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.

  READ TABLE LT_ZROUTE INDEX LD_TABIX.
  IF SY-SUBRC EQ 0.
    ZLET0210-ZROUTE = LT_ZROUTE-ZROUTE.
  ENDIF.

  CHECK ZLET0210-ZROUTE IS NOT  INITIAL .

  SELECT SINGLE *
    FROM ZLET0210
   WHERE ZROUTE     EQ  ZLET0210-ZROUTE
     AND DATAB      LE  SY-DATUM
     AND DATBI      GE  SY-DATUM
     AND CHK_INACT  EQ  SPACE
     AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
           CHK_SPOT NE SPACE ) .

ENDFORM.                    " EXEC_ZROUTE_F4
*&---------------------------------------------------------------------*
*&      Form  EXEC_ZDEPARTURE_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_ZDEPARTURE_F4 .
  CLEAR GF_ZDEPARTURE_F4.

  IF GF_SPOT IS INITIAL.
    SELECT DISTINCT ZDEPARTURE ZDEPARTURET
       INTO CORRESPONDING FIELDS OF TABLE LT_ZDEPARTURE
      FROM ZLET0210
     WHERE TDLNR      IN LR_TDLNR
       AND TRK_TON    IN LR_TRK_TON
       AND ZARRIVAL   IN LR_ZARRIVAL
       AND ZDEPARTURE IN LR_ZDEPARTURE
       AND DATAB      LE  SY-DATUM
       AND DATBI      GE  SY-DATUM.

    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '조건에 맞는 운송경로가 없습니다'.
      EXIT.
    ENDIF.

  ELSE.
    SELECT  AREA  AS ZDEPARTURE
            TEXT1 AS ZDEPARTURET
      INTO CORRESPONDING FIELDS OF TABLE LT_ZDEPARTURE
     FROM ZLET0212.

  ENDIF.


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = 'ZLET0210'
    TABLES
      DFIES_TAB = LT_DFIES.


  LOOP AT LT_DFIES.
    CLEAR LT_DFIES-TABNAME.
    CASE LT_DFIES-FIELDNAME .
      WHEN 'ZDEPARTURE'.
        LT_DFIES-POSITION  = 1.
        LT_DFIES-OFFSET  = 0.
        LT_DFIES-KEYFLAG = GC_X.


      WHEN 'ZDEPARTURET'.
        LT_DFIES-POSITION  = 2.
        LT_DFIES-OFFSET  = 6.


      WHEN OTHERS.
        DELETE LT_DFIES.
        CONTINUE.
    ENDCASE.

    MODIFY LT_DFIES.
  ENDLOOP.


  SORT LT_DFIES BY POSITION.

  LV_TITLE = '도착지선택'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZDEPARTURE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = LV_TITLE
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_ZDEPARTURE
      FIELD_TAB       = LT_DFIES
      RETURN_TAB      = LT_RTN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3. "


  CHECK LT_RTN[] IS NOT INITIAL.
  READ TABLE LT_RTN INDEX 1 .
  IF SY-SUBRC EQ 0.
    ZLET0210-ZDEPARTURE = LT_RTN-FIELDVAL.
  ENDIF.

  READ TABLE LT_ZDEPARTURE WITH KEY ZDEPARTURE = ZLET0210-ZDEPARTURE.
  IF SY-SUBRC EQ 0.
    ZLET0210-ZDEPARTURET = LT_ZDEPARTURE-ZDEPARTURET.
  ENDIF.

  IF GF_SPOT IS INITIAL.
    PERFORM SET_ROUTE_VALUE .
  ELSE.
    PERFORM SET_SPOT_ROUTE_VALUE.
  ENDIF.


ENDFORM.                    " EXEC_ZDEPARTURE_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ROUTE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ROUTE_VALUE .

  CHECK ZLET0210-TRK_TON     IS NOT INITIAL AND
        ZLET0210-ZARRIVAL    IS NOT INITIAL AND
        ZLET0210-ZDEPARTURE  IS NOT INITIAL .

  SELECT SINGLE *
    FROM ZLET0210
   WHERE TDLNR      EQ  ZLET0210-TDLNR
     AND TRK_TON    EQ  ZLET0210-TRK_TON
     AND ZARRIVAL   EQ  ZLET0210-ZARRIVAL
     AND ZDEPARTURE EQ  ZLET0210-ZDEPARTURE
     AND DATAB      LE  SY-DATUM
     AND DATBI      GE  SY-DATUM
     AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
             CHK_SPOT NE SPACE ) .


  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH '조건에 부합하는 운송경로가 존재하지 않습니다'.
    CLEAR : ZLET0210-ZROUTE,
            ZLET0210-PRICE,
            ZLET0210-WAERS.
  ENDIF.


ENDFORM.                    " SET_ROUTE_VALUE
*&---------------------------------------------------------------------*
*&      Form  EXEC_ZARRIVAL_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_ZARRIVAL_F4 .

  CLEAR GF_ZARRIVAL_F4.


  IF GF_SPOT IS INITIAL.
    SELECT DISTINCT ZARRIVAL ZARRIVALT
       INTO CORRESPONDING FIELDS OF TABLE LT_ZARRIVAL
      FROM ZLET0210
     WHERE TDLNR      IN LR_TDLNR
       AND TRK_TON    IN LR_TRK_TON
       AND ZARRIVAL   IN LR_ZARRIVAL
       AND ZDEPARTURE IN LR_ZDEPARTURE
       AND DATAB      LE  SY-DATUM
       AND DATBI      GE  SY-DATUM.


    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '조건에 맞는 운송경로가 없습니다'.
      EXIT.
    ENDIF.

  ELSE.
    SELECT  AREA  AS ZARRIVAL
            TEXT1 AS ZARRIVALT
      INTO CORRESPONDING FIELDS OF TABLE LT_ZARRIVAL
     FROM ZLET0212.

  ENDIF.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = 'ZLET0210'
    TABLES
      DFIES_TAB = LT_DFIES.


  LOOP AT LT_DFIES.
    CLEAR LT_DFIES-TABNAME.
    CASE LT_DFIES-FIELDNAME .
      WHEN 'ZARRIVAL'.
        LT_DFIES-POSITION  = 1.
        LT_DFIES-OFFSET  = 0.
        LT_DFIES-KEYFLAG = GC_X.


      WHEN 'ZARRIVALT'.
        LT_DFIES-POSITION  = 2.
        LT_DFIES-OFFSET  = 6.


      WHEN OTHERS.
        DELETE LT_DFIES.
        CONTINUE.
    ENDCASE.

    MODIFY LT_DFIES.
  ENDLOOP.


  SORT LT_DFIES BY POSITION.

  LV_TITLE = '도착지선택'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZARRIVAL'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = LV_TITLE
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_ZARRIVAL
      FIELD_TAB       = LT_DFIES
      RETURN_TAB      = LT_RTN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3. "


  CHECK LT_RTN[] IS NOT INITIAL.
  READ TABLE LT_RTN INDEX 1 .
  IF SY-SUBRC EQ 0.
    ZLET0210-ZARRIVAL = LT_RTN-FIELDVAL.
  ENDIF.

  READ TABLE LT_ZARRIVAL WITH KEY ZARRIVAL = ZLET0210-ZARRIVAL.
  IF SY-SUBRC EQ 0.
    ZLET0210-ZARRIVALT = LT_ZARRIVAL-ZARRIVALT.
  ENDIF.

  IF GF_SPOT IS INITIAL.
    PERFORM SET_ROUTE_VALUE .
  ELSE.
    PERFORM SET_SPOT_ROUTE_VALUE.
  ENDIF.

ENDFORM.                    " EXEC_ZARRIVAL_F4
*&---------------------------------------------------------------------*
*&      Form  EXEC_TRK_TON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_TRK_TON_F4 .

  CLEAR GF_TRK_TON_F4.


  IF GF_SPOT IS INITIAL.

    SELECT DISTINCT TRK_TON TRK_TONT
       INTO CORRESPONDING FIELDS OF TABLE LT_TRK_TON
      FROM ZLET0210
     WHERE TDLNR      IN LR_TDLNR
       AND TRK_TON    IN LR_TRK_TON
       AND ZARRIVAL   IN LR_ZARRIVAL
       AND ZDEPARTURE IN LR_ZDEPARTURE
       AND DATAB      LE SY-DATUM
       AND DATBI      GE SY-DATUM.


    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '조건에 맞는 운송경로가 없습니다'.
      EXIT.
    ENDIF.

  ELSE.
    LOOP AT F4_TAB .
      LT_TRK_TON-TRK_TON  = F4_TAB-FVAL.
      LT_TRK_TON-TRK_TONT = F4_TAB-FNAM.
      APPEND LT_TRK_TON.
    ENDLOOP.
  ENDIF.


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = 'ZLET0210'
    TABLES
      DFIES_TAB = LT_DFIES.


  LOOP AT LT_DFIES.
    CLEAR LT_DFIES-TABNAME.
    CASE LT_DFIES-FIELDNAME .
      WHEN 'TRK_TON'.
        LT_DFIES-POSITION  = 1.
        LT_DFIES-OFFSET  = 0.
        LT_DFIES-KEYFLAG = GC_X.


      WHEN 'TRK_TONT'.
        LT_DFIES-POSITION  = 2.
        LT_DFIES-OFFSET  = 8.


      WHEN OTHERS.
        DELETE LT_DFIES.
        CONTINUE.
    ENDCASE.

    MODIFY LT_DFIES.
  ENDLOOP.


  SORT LT_DFIES BY POSITION.

  LV_TITLE = '도착지선택'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'TRK_TON'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = LV_TITLE
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_TRK_TON
      FIELD_TAB       = LT_DFIES
      RETURN_TAB      = LT_RTN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3. "


  CHECK LT_RTN[] IS NOT INITIAL.
  READ TABLE LT_RTN INDEX 1 .
  IF SY-SUBRC EQ 0.
    ZLET0210-TRK_TON = LT_RTN-FIELDVAL.
  ENDIF.

  READ TABLE LT_TRK_TON WITH KEY TRK_TON = ZLET0210-TRK_TON.
  IF SY-SUBRC EQ 0.
    ZLET0210-TRK_TONT = LT_TRK_TON-TRK_TONT.
  ENDIF.

  IF GF_SPOT IS INITIAL.
    PERFORM SET_ROUTE_VALUE .
  ELSE.
    PERFORM SET_SPOT_ROUTE_VALUE.
  ENDIF.


ENDFORM.                    " EXEC_TRK_TON_F4
*&---------------------------------------------------------------------*
*&      Form  CREATE_GATING_DOCUMENT
*&---------------------------------------------------------------------*
*       통문증 생성 및 자동 매핑
*----------------------------------------------------------------------*
FORM CREATE_GATING_DOCUMENT .

  DATA : LT_PARAM LIKE TABLE OF RSPARAMS WITH HEADER LINE,

         BEGIN OF LT_GATE ,
           ORD_NUM    LIKE GT_ALV3-ORD_NUM,
           WERKS      LIKE GT_ALV3-WERKS,
           ARKTX      LIKE GT_ALV2-ARKTX,
           GROES      LIKE GT_ALV2-GROES,
           KUNNR_T    LIKE GT_ALV1-KUNNR_T,  "납품처명
           ORT01(100),
           PERNR      LIKE PA0001-PERNR,
         END OF LT_GATE.


*- INPUT CHECK .
  PERFORM CHECK_CREATE_GATING.
  CHECK GV_CHK IS INITIAL.

  LT_PARAM-SELNAME = 'P_BUKRS'.
  LT_PARAM-KIND    = 'P'.
  LT_PARAM-SIGN    = 'I'.
  LT_PARAM-OPTION  = 'EQ'.
  LT_PARAM-LOW     = '3000'.

  APPEND LT_PARAM.

  LT_PARAM-SELNAME = 'P_GUBUN1'.
  LT_PARAM-LOW     = 'E99'.
  APPEND LT_PARAM.

  MOVE-CORRESPONDING GT_ALV3 TO LT_GATE.
  LT_GATE-PERNR = GV_PERNR_PG.

  EXPORT LT_GATE TO MEMORY ID 'ZLE0101T'.


  SUBMIT ZLER0019 WITH SELECTION-TABLE LT_PARAM
                   EXPORTING LIST TO MEMORY
                   AND RETURN .

  PERFORM GET_NREQUEST_DATA .

ENDFORM.                    " CREATE_GATING_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CHECK_CREATE_GATING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CREATE_GATING .
  CLEAR  GV_CHK.
  PERFORM GRID_CHECK_CHANGED_DATA USING GRID3."ALV최신화

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                            USING   GRID3
                         CHANGING   GV_CHK.
  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_ROWS LINES SY-TFILL.
  IF SY-TFILL > 1.
    MESSAGE S001 WITH '한건만 처리 가능합니다. '
        DISPLAY LIKE 'E'.
    GV_CHK    =  GC_X.     EXIT.
  ENDIF.

  LOOP AT GT_ROWS.
    READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
  ENDLOOP.

  IF GT_ALV3-IV_NO IS NOT INITIAL.
    MESSAGE S001 WITH '이미 통문이 신청된 내역입니다.'
                       DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'IV_NO'.
    EXIT.
  ENDIF.

  IF GT_ALV3-ORD_NUM IS  INITIAL.
    MESSAGE S001 WITH '배차완료된 라인을 선택해주십시오'
                       DISPLAY LIKE 'E'.
    GV_CHK    =  GC_X.
    EXIT.
  ENDIF.

  IF GT_ALV3-WERKS IS  INITIAL.
    MESSAGE S001 WITH '플랜트는 필수입력입니다.'
                       DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'WERKS'.
    EXIT.
  ENDIF.

  IF GT_ALV3-GROES IS  INITIAL.
    MESSAGE S001 WITH '단취포장사이즈는 필수입력입니다. '
                       DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'GROES'.
    EXIT.
  ENDIF.

  IF GT_ALV3-KUNNR_T IS  INITIAL.
    MESSAGE S001 WITH '납품처명은 필수입력입니다. '
        DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'KUNNR_T'.
    EXIT.
  ENDIF.


  IF GT_ALV3-ORT01 IS INITIAL.
    MESSAGE S001 WITH '인도처주소는 필수입력입니다. '
        DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ORT01'.
    EXIT.
  ENDIF.

  IF GT_ALV3-ZROUTE IS INITIAL.
    MESSAGE S001 WITH '운송경로는 필수입력입니다. '
        DISPLAY LIKE 'E'.
    PERFORM SET_FOCUS_ALV3 USING GT_ROWS-INDEX 'ZROUTE'.
    EXIT.
  ENDIF.

  IF GV_PERNR_PG IS INITIAL.
    MESSAGE S001 WITH '통문요청자(사번)는 필수입력입니다. '
        DISPLAY LIKE 'E'.
    GV_SCREEN_FILED = 'GV_PERNR_PG'.
    GV_CHK = GC_X.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_CREATE_GATING
*&---------------------------------------------------------------------*
*&      Form  NREQUEST_CAR_DISPATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM NREQUEST_CAR_DISPATCH .

  PERFORM GET_NREQUEST_DATA .
*
*  DATA : LT_0105 TYPE TABLE OF ZLET0105 WITH HEADER LINE,
*         LS_CELLTAB TYPE LVC_S_STYL,
*         LT_CELLTAB TYPE LVC_T_STYL,
*         LT_AREA LIKE TABLE OF ZLET0212-AREA WITH HEADER LINE,
*         LT_0212 LIKE TABLE OF ZLET0212 WITH HEADER LINE.
*
*
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE LT_0105
*    FROM ZLET0105
*   WHERE ERDAT IN S_ERDAT
*     AND VBELN LIKE 'MAP#%' AND ZROUTE NE SPACE.
*
*
**- 경로가 있는 경우 출발, 목적지 명칭 추출  -[s]
*  LOOP AT LT_0105 .
*    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
*      LT_AREA = LT_0105-ZDEPARTURE.
*      APPEND LT_AREA.
*    ENDIF.
*
*    IF LT_0105-ZARRIVAL IS NOT INITIAL.
*      LT_AREA = LT_0105-ZARRIVAL.
*      APPEND LT_AREA.
*    ENDIF.
*  ENDLOOP.
*
*  SORT LT_AREA BY TABLE_LINE.
*  DELETE ADJACENT DUPLICATES FROM LT_AREA COMPARING ALL FIELDS.
*
*  IF LT_AREA[] IS NOT INITIAL.
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0212
*      FROM ZLET0212 FOR ALL ENTRIES IN LT_AREA
*     WHERE  AREA EQ LT_AREA-TABLE_LINE.
*    SORT LT_0212 BY AREA.
*  ENDIF.
*
**- 경로가 있는 경우 출발, 목적지 명칭 추출 -[e]
*
*  CLEAR : GT_ALV3, GT_ALV3[].
*
*  LS_CELLTAB-FIELDNAME = 'POSNR'.
*  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*
*  LS_CELLTAB-FIELDNAME = 'VBELN'.
*  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*
*  LOOP AT LT_0105.
*    CLEAR : GT_ALV3.
*    MOVE-CORRESPONDING LT_0105 TO GT_ALV3.
*
**- 출발, 목적지 명칭
*    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
*      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZDEPARTURE
*                                         BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        GT_ALV3-ZDEPARTURET  = LT_0212-TEXT1.
*      ENDIF.
*    ENDIF.
*
*    IF LT_0105-ZARRIVAL IS NOT INITIAL.
*      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZARRIVAL
*                                  BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        GT_ALV3-ZARRIVALT = LT_0212-TEXT1.
*      ENDIF.
*    ENDIF.
*
**- 차종
*    READ TABLE F4_TAB WITH KEY FVAL = GT_ALV3-TRK_TON.
*    IF SY-SUBRC EQ 0.
*      CONCATENATE F4_TAB-FVAL ` ` F4_TAB-FNAM
*             INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.
*    ENDIF.
*
*    IF GT_ALV3-VBELN(3) EQ 'MAP' OR GT_ALV3-MAP_CANC IS NOT INITIAL .
*      GT_ALV3-VBELN_PT  = GT_ALV3-VBELN.
*      CLEAR : GT_ALV3-VBELN.
*    ELSE.
*      INSERT LINES OF LT_CELLTAB INTO TABLE GT_ALV3-CELLTAB.
*    ENDIF.
*
*
*    IF GT_ALV3-ATTACH_KEY IS NOT INITIAL.
*      GT_ALV3-ATTACH_ICON = ICON_ATTACHMENT.
*    ENDIF.
*
*    IF GT_ALV3-ORD_NUM IS NOT INITIAL .
*      GT_ALV3-LOGI_STATUS = ICON_LED_GREEN.
*    ELSE.
*      CLEAR : GT_ALV3-STATUS.
*    ENDIF.
*
*    IF GT_ALV3-LOGI_STATUS EQ 'F'.
*      GT_ALV3-LOGI_STATUS = ICON_LED_RED.
*    ENDIF.
*
*    IF GT_ALV3-LOGI_STATUS IS INITIAL  OR
*       GT_ALV3-LOGI_STATUS EQ 'C'  .
*      GT_ALV3-LOGI_STATUS = ICON_LED_YELLOW .
*      CLEAR GT_ALV3-ORD_NUM.
*    ENDIF.
*
*
*    APPEND GT_ALV3.
*  ENDLOOP.
*
*  SORT GT_ALV3 BY WADAT DESCENDING WAUHR DESCENDING.

  GS_RECEIVER-MCHK3       = GC_X.
  GS_RECEIVER-MCHK3_REF1  = GC_X.
  GS_RECEIVER-MCHK3_REF2  = GC_X.

  GV_TITLE = '비주문배차(운송경로필수)'.
  GT_EXCL3    = 'MAP_VLN' .  APPEND GT_EXCL3.
  GT_EXCL3    = 'MAP_CAN' .  APPEND GT_EXCL3.
  GF_EDIT     = GC_X.
  GF_ALV_FIRST = GC_X.


  ST_ATTACH_KEY-ICON_TEXT = '자료첨부'.
  ST_ATTACH_KEY-TEXT      = '관련자료첨부'.


  CLEAR GV_ATTACH_KEY.
  GF_NREQUEST = GC_X.

  CALL SCREEN '400' STARTING AT 1  1.

  CLEAR :   GT_HEADER_SEL, GT_HEADER_SEL[],
            GT_ITEM_SEL  , GT_ITEM_SEL[],
            GT_ALV3      , GT_ALV3[],
            GT_ALV4      , GT_ALV4[],
            GS_SENDER    , GS_RECEIVER,
            GV_CALLBACK  , GV_MOBILE,
            GV_CONTENT   , GV_STATUS  ,
            GV_PERNR_SH_T, GV_TDLNR_SH_T,
            GT_SMS       , GT_SMS[],
            GT_SMS_1     , GT_SMS_1[],
            GT_EXCL3     , GT_EXCL3[],
            GF_NREQUEST,
            GV_POSNR.




ENDFORM.                    " NREQUEST_CAR_DISPATCH
*&---------------------------------------------------------------------*
*&      Form  GET_NREQUEST_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NREQUEST_DATA .


  DATA : LT_0105    TYPE TABLE OF ZLET0105 WITH HEADER LINE,
         LS_CELLTAB TYPE LVC_S_STYL,
         LT_CELLTAB TYPE LVC_T_STYL,
         LT_AREA    LIKE TABLE OF ZLET0212-AREA WITH HEADER LINE,
         LT_0212    LIKE TABLE OF ZLET0212 WITH HEADER LINE,
         LT_0108    LIKE TABLE OF ZLET0108 WITH HEADER LINE.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_0105
    FROM ZLET0105
   WHERE ERDAT IN S_ERDAT
     AND VBELN LIKE 'MAP#%' AND ZROUTE NE SPACE.


*- 경로가 있는 경우 출발, 목적지 명칭 추출  -[s]
  LOOP AT LT_0105 .
    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
      LT_AREA = LT_0105-ZDEPARTURE.
      APPEND LT_AREA.
    ENDIF.

    IF LT_0105-ZARRIVAL IS NOT INITIAL.
      LT_AREA = LT_0105-ZARRIVAL.
      APPEND LT_AREA.
    ENDIF.
  ENDLOOP.


  IF LT_0105[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0108
       FROM ZLET0108 FOR ALL ENTRIES IN LT_0105
     WHERE ORD_NUM  EQ LT_0105-ORD_NUM.
  ENDIF.

  SORT LT_0108 BY ORD_NUM.



  SORT LT_AREA BY TABLE_LINE.
  DELETE ADJACENT DUPLICATES FROM LT_AREA COMPARING ALL FIELDS.

  IF LT_AREA[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0212
      FROM ZLET0212 FOR ALL ENTRIES IN LT_AREA
     WHERE  AREA EQ LT_AREA-TABLE_LINE.
    SORT LT_0212 BY AREA.
  ENDIF.

*- 경로가 있는 경우 출발, 목적지 명칭 추출 -[e]

  CLEAR : GT_ALV3, GT_ALV3[].

  LS_CELLTAB-FIELDNAME = 'POSNR'.
  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.

  LS_CELLTAB-FIELDNAME = 'VBELN'.
  LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.

  LOOP AT LT_0105.
    CLEAR : GT_ALV3.
    MOVE-CORRESPONDING LT_0105 TO GT_ALV3.

*- 출발, 목적지 명칭
    IF LT_0105-ZDEPARTURE IS NOT INITIAL.
      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZDEPARTURE
                                         BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_ALV3-ZDEPARTURET  = LT_0212-TEXT1.
      ENDIF.
    ENDIF.

    IF LT_0105-ZARRIVAL IS NOT INITIAL.
      READ TABLE LT_0212 WITH KEY AREA = LT_0105-ZARRIVAL
                                  BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GT_ALV3-ZARRIVALT = LT_0212-TEXT1.
      ENDIF.
    ENDIF.

*- 차종
    READ TABLE F4_TAB WITH KEY FVAL = GT_ALV3-TRK_TON.
    IF SY-SUBRC EQ 0.
      CONCATENATE F4_TAB-FVAL ` ` F4_TAB-FNAM
             INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.
    ENDIF.

    IF GT_ALV3-VBELN(3) EQ 'MAP' OR GT_ALV3-MAP_CANC IS NOT INITIAL .
      GT_ALV3-VBELN_PT  = GT_ALV3-VBELN.
      CLEAR : GT_ALV3-VBELN.
    ELSE.
      INSERT LINES OF LT_CELLTAB INTO TABLE GT_ALV3-CELLTAB.
    ENDIF.


    IF GT_ALV3-ATTACH_KEY IS NOT INITIAL.
      GT_ALV3-ATTACH_ICON = ICON_ATTACHMENT.
    ENDIF.

    IF GT_ALV3-ORD_NUM IS NOT INITIAL .
      GT_ALV3-LOGI_STATUS = ICON_LED_GREEN.
    ELSE.
      CLEAR : GT_ALV3-STATUS.
    ENDIF.

    IF GT_ALV3-LOGI_STATUS EQ 'F'.
      GT_ALV3-LOGI_STATUS = ICON_LED_RED.
    ENDIF.

    IF GT_ALV3-LOGI_STATUS IS INITIAL  OR
       GT_ALV3-LOGI_STATUS EQ 'C'  .
      GT_ALV3-LOGI_STATUS = ICON_LED_YELLOW .
      CLEAR GT_ALV3-ORD_NUM.
    ENDIF.


    READ TABLE LT_0108 WITH KEY ORD_NUM = LT_0105-ORD_NUM
                                             BINARY SEARCH.
    IF SY-SUBRC EQ 0 .
      IF LT_0108-STATUS EQ '2' OR  "배차완료시
         LT_0108-STATUS EQ '3' OR
         LT_0108-STATUS EQ '4'   .
        GT_ALV3-DRIVER_NM       = LT_0108-DRIVER_NM    .
        GT_ALV3-DRIVER_TELNO    = LT_0108-DRIVER_TELNO .
        GT_ALV3-TRUCK_NO        = LT_0108-TRUCK_NO  .
      ENDIF.
    ENDIF.

    APPEND GT_ALV3.
  ENDLOOP.

  SORT GT_ALV3 BY WADAT DESCENDING WAUHR DESCENDING.


ENDFORM.                    " GET_NREQUEST_DATA
*&---------------------------------------------------------------------*
*&      Form  MAP_ZGATING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAP_ZGATING .

  PERFORM SET_INIT_0900.

  PERFORM EXEC_SEARCH_0900.

  CALL SCREEN '0900' STARTING AT 3 3.

ENDFORM.                    " MAP_ZGATING
*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_CATALOGS_GRID4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS_GRID4 .

  CLEAR : GT_FIELD,GT_FIELD[].

* 선언된 인터럴 테이블 값을 가지고 옴
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GT_0005'
      I_INCLNAME         = 'ZLER0101M01'
    CHANGING
      CT_FIELDCAT        = GT_FIELD[].


* 펑션구조로된 FIELDCAT을 클래스 FIELDCAT으로 변환
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = GT_FIELD
    IMPORTING
      ET_FIELDCAT_LVC = GT_LVC4[]
    TABLES
      IT_DATA         = GT_0005
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.


  LOOP AT GT_LVC4.

    GT_LVC4-COL_OPT = GC_X.
    CASE GT_LVC4-FIELDNAME.
      WHEN 'IV_NO'.
        GT_LVC4-COLTEXT = '통문번호'.
      WHEN 'CREATE_DATE'.
        GT_LVC4-COLTEXT = '생성일'.
      WHEN 'NAME'.
        GT_LVC4-COLTEXT = '구매처'.
      WHEN 'NAME1'.
        GT_LVC4-COLTEXT = '납품처'.
      WHEN 'KUNNR2'.
        GT_LVC4-COLTEXT = '수기고객명'.
      WHEN 'KUNNR' OR 'KUNNR1'.
        GT_LVC4-TECH = GC_X.
      WHEN 'MAP_CHK'.
        GT_LVC4-COLTEXT = '매핑여부'.
        GT_LVC4-CHECKBOX = GC_X.
    ENDCASE.

    IF GT_LVC4-COLTEXT IS NOT INITIAL.
      GT_LVC4-SCRTEXT_L = GT_LVC4-SCRTEXT_M =
      GT_LVC4-SCRTEXT_S = GT_LVC4-COLTEXT .
    ENDIF.


    MODIFY GT_LVC4.
  ENDLOOP.

ENDFORM.                    " SET_FIELD_CATALOGS_GRID4
*&---------------------------------------------------------------------*
*&      Form  SET_OPTION_GRID4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_OPTION_GRID4 .

  GS_LAYOUT4-SEL_MODE   = 'S'.
  GS_LAYOUT4-ZEBRA      = GC_X.
*  GS_LAYOUT3-STYLEFNAME      = 'CELLTAB'.

ENDFORM.                    " SET_OPTION_GRID4
*&---------------------------------------------------------------------*
*&      Form  EXEC_SEARCH_0900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_SEARCH_0900 .


  DATA : BEGIN OF LT_KNA1 OCCURS 0,
           KUNNR LIKE KNA1-KUNNR,
           NAME1 LIKE KNA1-NAME1,
         END OF LT_KNA1,
         LT_KUNNR LIKE TABLE OF KNA1-KUNNR WITH HEADER LINE,

         BEGIN OF LT_IV_NO  OCCURS 0 ,
           IV_NO TYPE ZLET0105-IV_NO,
         END OF LT_IV_NO.

  CLEAR : GT_0005, GT_0005[] .

  SELECT *  INTO CORRESPONDING FIELDS OF TABLE GT_0005
    FROM ZLET0005
   WHERE IV_NO        IN S_IV_NO
    AND  BZAREA       IN S_BZAREA
    AND  WERKS        IN S_WERKS
    AND  IV_NO        IN S_IV_NO
    AND  OUT_DATE     EQ '00000000'
    AND  CREATE_DATE  IN S_CRT_DT
    AND  PERNR        IN S_PERNR1
    AND  IV_TYPE      IN S_TYPE .


  LOOP AT GT_0005.
    IF GT_0005-KUNNR IS NOT INITIAL.
      LT_KUNNR = GT_0005-KUNNR.
      APPEND LT_KUNNR.
    ENDIF.

    IF GT_0005-KUNNR1 IS NOT INITIAL.
      LT_KUNNR = GT_0005-KUNNR1.
      APPEND LT_KUNNR.
    ENDIF.
  ENDLOOP.


  IF GT_0005[] IS NOT INITIAL.
    SELECT DISTINCT IV_NO INTO CORRESPONDING FIELDS OF TABLE LT_IV_NO
      FROM ZLET0105 FOR ALL ENTRIES IN GT_0005
     WHERE IV_NO EQ GT_0005-IV_NO.
    SORT LT_IV_NO BY IV_NO.
  ENDIF.


  SORT LT_KUNNR BY TABLE_LINE.
  DELETE ADJACENT DUPLICATES FROM LT_KUNNR COMPARING ALL FIELDS .

  IF LT_KUNNR[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_KNA1
      FROM KNA1 FOR ALL ENTRIES IN LT_KUNNR
     WHERE KUNNR EQ LT_KUNNR-TABLE_LINE.
  ENDIF.

  LOOP AT GT_0005.
    READ TABLE LT_KNA1 WITH KEY KUNNR = GT_0005-KUNNR
                       BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_0005-NAME = LT_KNA1-NAME1.
    ENDIF.

    READ TABLE LT_KNA1 WITH KEY KUNNR = GT_0005-KUNNR1
                       BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_0005-NAME1 = LT_KNA1-NAME1.
    ENDIF.

    READ TABLE LT_IV_NO WITH KEY IV_NO = GT_0005-IV_NO
                                         BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_0005-MAP_CHK = GC_X.
    ENDIF.

    MODIFY GT_0005 TRANSPORTING NAME NAME1 MAP_CHK.

  ENDLOOP.


ENDFORM.                    " EXEC_SEARCH_0900
*&---------------------------------------------------------------------*
*&      Form  SET_INIT_0900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INIT_0900 .

  CLEAR : S_CRT_DT, S_CRT_DT[],
          S_WERKS , S_WERKS[] ,
          S_PERNR1 , S_PERNR1[].

  LOOP AT S_ERDAT.
    MOVE-CORRESPONDING S_ERDAT TO S_CRT_DT.
    APPEND S_CRT_DT.
  ENDLOOP.

  IF GT_ALV4-WERKS IS NOT INITIAL.
    %%RA_ITAB_EQ : S_WERKS      'I' 'EQ' GT_ALV4-WERKS      ''.
  ENDIF.

  IF GS_SENDER-PERNR IS NOT INITIAL.
    %%RA_ITAB_EQ : S_PERNR1      'I' 'EQ' GS_SENDER-PERNR     ''.
  ENDIF.


  IF S_BZAREA[] IS INITIAL  "기본전주공장
     AND S_WERKS[] IS INITIAL.
    %%RA_ITAB_EQ : S_BZAREA     'I' 'BT'  5000     5999.
  ENDIF.


  IF S_TYPE[] IS INITIAL  "기본기타통문
     AND S_WERKS[] IS INITIAL.
    %%RA_ITAB_EQ : S_TYPE     'I' 'EQ'  'E99'   ''.
  ENDIF.



ENDFORM.                    " SET_INIT_0900
*&---------------------------------------------------------------------*
*&      Form  ZGATE_MAP_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ZGATE_MAP_ALV3 .

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID3
                          CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_ROWS LINES SY-TFILL.

  IF SY-TFILL > 1.
    MESSAGE I001 WITH '한 라인만 선택하실수 있습니다. '.
    EXIT.
  ENDIF.

  READ TABLE GT_ROWS INDEX 1.
  READ TABLE GT_ALV3 INDEX GT_ROWS-INDEX.
  GF_ZGATING = GC_X.

ENDFORM.                    " ZGATE_MAP_ALV3
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZLET0005
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZLET0005 .

  PERFORM GET_SELECT_ROWS TABLES   GT_ROWS
                          USING    GRID4
                          CHANGING GV_CHK.

  CHECK GV_CHK IS INITIAL.


  READ TABLE GT_ROWS INDEX 1.
  READ TABLE GT_0005 INDEX GT_ROWS-INDEX.


  IF GT_0005-MAP_CHK IS INITIAL.
    PERFORM POPUP_TO_CONFIRM
      USING '매핑확인'
      '선택한 통문번호로 매핑하시겠습니까?'
             '1'     GV_ANSWER.
  ELSE.
    PERFORM POPUP_TO_CONFIRM
       USING '매핑확인'
       '기매핑된 통문번호입니다. 매핑하시겠습니까?'
             '1'     GV_ANSWER.
  ENDIF.

  CHECK GV_ANSWER EQ '1'.

  IF GT_ALV3-ORD_NUM IS NOT  INITIAL.
    UPDATE ZLET0105  SET   IV_NO = GT_0005-IV_NO
                 WHERE ORD_NUM EQ  GT_ALV3-ORD_NUM.

    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE I001 WITH '통문번호가 정상 매핑되었습니다. '.
      PERFORM GET_NREQUEST_DATA .
      LEAVE TO SCREEN 0.
    ELSE.
      MESSAGE I001 WITH '매핑중 오류가 발생하였습니다.' .
    ENDIF.

  ENDIF.



ENDFORM.                    " UPDATE_ZLET0005
*&---------------------------------------------------------------------*
*&      Form  F4_IV_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_IV_TYPE .

  DATA : LT_RTN       LIKE TABLE OF DDSHRETVAL WITH HEADER LINE,
         LT_DFIES     LIKE TABLE OF DFIES  WITH HEADER LINE,
         LV_TITLE(40) VALUE '통문유형선택',

         BEGIN OF LT_0007 OCCURS 0,
           IV_TYPE    LIKE ZLET0007-IV_TYPE,
           IV_TYPE_NM LIKE ZLET0007-IV_TYPE_NM,
         END OF LT_0007.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_0007
    FROM ZLET0007
    WHERE GUBUN = 'MA'
      AND COCD3 = 'X'. "엠트론


  CLEAR LT_DFIES.
  LT_DFIES-SCRTEXT_S = LT_DFIES-SCRTEXT_M =
  LT_DFIES-FIELDTEXT = LT_DFIES-SCRTEXT_L = '통문유형'.

  LT_DFIES-FIELDNAME = 'F0001'.
  LT_DFIES-KEYFLAG  = GC_X.
  LT_DFIES-POSITION  = 1.
  LT_DFIES-OFFSET  =  0.
  LT_DFIES-LENG  = LT_DFIES-INTLEN =
  LT_DFIES-OUTPUTLEN  = 3.
  APPEND LT_DFIES.

  CLEAR LT_DFIES.
  LT_DFIES-SCRTEXT_S = LT_DFIES-SCRTEXT_M =
  LT_DFIES-FIELDTEXT = LT_DFIES-SCRTEXT_L = '유형설명'.

  LT_DFIES-FIELDNAME = 'F0002'.
  LT_DFIES-POSITION  = 2.
  LT_DFIES-OFFSET  =  3.
  LT_DFIES-LENG  = LT_DFIES-INTLEN =
  LT_DFIES-OUTPUTLEN  = 40.
  APPEND LT_DFIES.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'F0001'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = LV_TITLE
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_0007
      FIELD_TAB       = LT_DFIES
      RETURN_TAB      = LT_RTN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


  CHECK LT_RTN[] IS NOT INITIAL.
  READ TABLE LT_RTN INDEX 1 .
  IF SY-SUBRC EQ 0.
    S_TYPE-LOW = LT_RTN-FIELDVAL.
  ENDIF.


ENDFORM.                    " F4_IV_TYPE
*&---------------------------------------------------------------------*
*&      Form  REQUEST_APPROVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REQUEST_APPROVAL .

  DATA : LV_EXENO       LIKE  ZMMT0152M-EXENO, "품의번호
         LV_EXITM(5),  "품의 품목
         LV_APPNO       LIKE ZMMT0145M-APPNO,
         LV_APCNT       LIKE ZMMT0145M-APCNT,
         LV_PRICE       LIKE ZLET0210-PRICE,
         LV_PRICE_T(20).


  CLEAR: LV_EXITM, LV_EXENO, ZMMT0152M, GF_APPRQ.

  PERFORM SET_SPOT_ROUTE_VALUE.
  IF ZLET0210-ZROUTE IS INITIAL.
    MESSAGE  I001 WITH '운송경로가 비어있습니다.'.
    EXIT.
  ENDIF.


  SELECT SINGLE PRICE INTO LV_PRICE
  FROM ZLET0210
 WHERE ZROUTE     EQ  ZLET0210-ZROUTE
   AND DATAB      EQ  SY-DATUM
   AND DATBI      EQ  SY-DATUM
   AND TDLNR      EQ  ZLET0210-TDLNR
   AND TRK_TON    EQ  ZLET0210-TRK_TON
   AND CHK_INACT  EQ  SPACE
   AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
           CHK_SPOT NE SPACE ) .

  IF SY-SUBRC EQ 0.
    WRITE LV_PRICE TO LV_PRICE_T CURRENCY ZLET0210-WAERS.
    MESSAGE  I001 WITH LV_PRICE_T
                       '로 승인요청(완료)된 운송경로가 존재합니다. '.
    EXIT.
  ENDIF.



  PERFORM SELECT_EXENO USING LV_EXENO.
  CHECK LV_EXENO IS NOT INITIAL.

  PERFORM EXEC_FCODE_REGISTER.  "결제자등록

* /결재요청자 필드가 존재하는지 확인
  CLEAR GS_APPROVAL.
  MOVE-CORRESPONDING ZMMT0152M TO GS_APPROVAL.
  IF GS_APPROVAL IS INITIAL.
    MESSAGE S001 WITH TEXT-E03.
    EXIT.
  ENDIF.


  ZLET0210-BUKRS = '3000'.
  ZLET0210-ESTAT =  GC_A.
  ZLET0210-EXENO = LV_EXENO.
  ZLET0210-EXCNT = 1.
  ZLET0210-DATAB = ZLET0210-DATBI = SY-DATUM.

  ADD 10 TO  LV_EXITM.
  ZLET0210-EXITM = LV_EXITM.

  ZLET0210-ERNAM = SY-UNAME.
  ZLET0210-ERZET = SY-UZEIT.
  ZLET0210-ERDAT = SY-DATUM.
  ZLET0210-CHK_SPOT = GC_X.
  ZLET0210-WAERS    = GC_KRW.
  MODIFY ZLET0210.

  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE 'E'
                 WITH '운송비내역 저장 중 오류가 발생했습니다!'.
    EXIT.
  ENDIF.

  COMMIT WORK AND WAIT.

* 승인번호 채번 : 회사코드(4) + 현재년월(6) + 품의번호(10)
  CONCATENATE '3000' SY-DATUM(6) LV_EXENO INTO LV_APPNO.
  LV_APCNT = 1.          "품목


  ZMMT0152M-BUKRS  = '3000'.
  ZMMT0152M-APPNO  = LV_APPNO.
  ZMMT0152M-APCNT  = LV_APCNT.
  ZMMT0152M-EXENO  = LV_EXENO.
  ZMMT0152M-EXCNT  = 1.
  ZMMT0152M-ZTITL  = '1회성 운송비 단가 승인 요청'.
  ZMMT0152M-DTYPE  = GC_S.
  ZMMT0152M-ZDIST  = GC_I.          "개별
  ZMMT0152M-DSTAT  = GC_P.          "진행
  ZMMT0152M-RQDAT  = SY-DATUM.
  ZMMT0152M-RQNAM  = SY-UNAME.

  INSERT ZMMT0152M .

  IF SY-SUBRC = 0.
    PERFORM TRANSPORT_EMAIL_MSG.

    MESSAGE I001 WITH '일회성 운송비가 승인요청 되었습니다.'.
  ELSE.
    MESSAGE S000 DISPLAY LIKE 'E'
                 WITH '운송비 승인요청 중 오류가 발생했습니다!'.
    DELETE ZLET0210 .

    EXIT.
  ENDIF.

  IF GT_ALV3-TRK_TON_T(4)  <> ZLET0210-TRK_TON.
    MESSAGE I004 WITH '차종이' ZLET0210-TRK_TONT
                               '으로 변경되었습니다. '.
  ENDIF.


  MOVE-CORRESPONDING ZLET0210  TO GT_ALV3.
  CONCATENATE ZLET0210-TRK_TON ` ` ZLET0210-TRK_TONT
         INTO GT_ALV3-TRK_TON_T SEPARATED BY SPACE.


  MODIFY GT_ALV3 INDEX GT_ROWS-INDEX.


  LEAVE TO SCREEN 0.


ENDFORM.                    " REQUEST_APPROVAL
*&---------------------------------------------------------------------*
*&      Form  SELECT_EXENO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_EXENO  text
*----------------------------------------------------------------------*
FORM SELECT_EXENO  USING    P_EXENO.

* 품의번호 자동생성
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZEXENO'
    IMPORTING
      NUMBER                  = P_EXENO
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
    MESSAGE ID 'ZMM2' TYPE 'S' NUMBER 007.
    EXIT.
  ENDIF.


ENDFORM.                    " SELECT_EXENO
*&---------------------------------------------------------------------*
*&      Form  EXEC_FCODE_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_FCODE_REGISTER .


  DATA: LS_APPROVAL LIKE ZMMS0319,
*         LV_BUKRS        LIKE ZMMT0139M-BUKRS,
        LV_ZAUTH    LIKE ZMMT0139M-ZAUTH VALUE 'I',
        LV_XDIMM    TYPE CHAR1.


  REFRESH GT_APPROVAL.
  CLEAR: GS_APPROVAL, LS_APPROVAL,
         ZMMT0152M.

  MOVE-CORRESPONDING ZMMT0152M TO LS_APPROVAL.
  APPEND LS_APPROVAL TO GT_APPROVAL.

  CALL FUNCTION 'Z_MM2_CALL_APPROVE'
    EXPORTING
      IMP_BUKRS  = '3000'
      IMP_ZAUTH  = LV_ZAUTH
      IMP_DIMM   = LV_XDIMM
    TABLES
      T_APPROVAL = GT_APPROVAL.


  READ TABLE GT_APPROVAL INTO GS_APPROVAL INDEX 1.
  IF LS_APPROVAL NE GS_APPROVAL.
    MOVE-CORRESPONDING GS_APPROVAL TO ZMMT0152M.
    IF NOT LS_APPROVAL IS INITIAL.
      MESSAGE S001 WITH TEXT-T01.
    ELSE.
      MESSAGE S001 WITH TEXT-T02.
    ENDIF.
  ELSE.
    MESSAGE S001 WITH TEXT-T03.
  ENDIF.


ENDFORM.                    " EXEC_FCODE_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_SPOT_ROUTE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SPOT_ROUTE_VALUE .

  IF ZLET0210-TRK_TON    IS NOT INITIAL   AND
     ZLET0210-ZARRIVAL   IS NOT INITIAL  AND
     ZLET0210-ZDEPARTURE IS NOT INITIAL.

    LV_LENGTH  = STRLEN( ZLET0210-TRK_TON ).

    IF LV_LENGTH EQ 3.
      CONCATENATE ZLET0210-ZDEPARTURE ZLET0210-ZARRIVAL '0'
                  ZLET0210-TRK_TON INTO ZLET0210-ZROUTE.
    ELSE.
      CONCATENATE ZLET0210-ZDEPARTURE ZLET0210-ZARRIVAL
                  ZLET0210-TRK_TON INTO ZLET0210-ZROUTE.
    ENDIF.

  ENDIF.

ENDFORM.                    " SET_SPOT_ROUTE_VALUE
*&---------------------------------------------------------------------*
*&      Form  TRANSPORT_EMAIL_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TRANSPORT_EMAIL_MSG .



  DATA: LV_OBJ_DESC TYPE SO_OBJ_DES.

  CLEAR:   LV_OBJ_DESC.

* /email title
  CONCATENATE '품의번호' ZMMT0152M-APPNO '결재승인 요청'
                                 INTO LV_OBJ_DESC SEPARATED BY SPACE.
  IF GS_APPROVAL-XEMERG EQ GC_X.    " 긴급
    CONCATENATE '[긴급]' LV_OBJ_DESC INTO LV_OBJ_DESC
                             SEPARATED BY SPACE.
  ENDIF.

* /to email
  PERFORM GET_EMAIL_ADD  USING LV_OBJ_DESC.


ENDFORM.                    " TRANSPORT_EMAIL_MSG
*&---------------------------------------------------------------------*
*&      Form  GET_EMAIL_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_OBJ_DESC  text
*----------------------------------------------------------------------*
FORM GET_EMAIL_ADD  USING   PV_OBJ_DESC.


  DATA: LV_COUNT    TYPE NUMC2,
        LV_BUKRS    LIKE ZMMT0139M-BUKRS,
        LV_USRID    LIKE ZMMT0139M-USRID,
        LV_AUTXT    TYPE CHAR30,

        LV_DOMNAME  LIKE DD07L-DOMNAME VALUE 'ZDAPP_SEQ',
        LV_FNAME1   TYPE CHAR9 VALUE 'USR_APPXX',
        LV_FNAME2   TYPE CHAR9 VALUE 'AUT_APPXX',
        LV_OBJ_NAME TYPE SO_OBJ_NAM VALUE 'MAIL',
        LV_RETURN   LIKE BAPIRET2-TYPE,
        LV_MESSAGE  LIKE BAPIRET2-MESSAGE,

        LS_SOLISTI1 LIKE SOLISTI1,

        LT_EMAIL    LIKE STANDARD TABLE OF SOLISTI1
                    INITIAL SIZE 0,
        LT_TEXTS    LIKE STANDARD TABLE OF SOLISTI1
                    INITIAL SIZE 0,
        LT_BINTX    LIKE STANDARD TABLE OF SOLISTI1
                    INITIAL SIZE 0.

  REFRESH: LT_EMAIL,   LT_TEXTS.
  CLEAR: LV_COUNT.
  LV_BUKRS = ZMMT0152M-BUKRS.

  DO.

    CLEAR: ZMMT0139M.


    ADD 1 TO LV_COUNT.
    LV_FNAME1+7(2) = LV_COUNT.
    LV_FNAME2+7(2) = LV_COUNT.

    ASSIGN COMPONENT LV_FNAME1 OF STRUCTURE GS_APPROVAL TO <FS>.

    IF <FS> IS ASSIGNED.

      LV_USRID = <FS>.

      IF NOT <FS> IS INITIAL.

        SELECT SINGLE *
               FROM  ZMMT0139M
              WHERE  BUKRS  EQ  LV_BUKRS
                AND  USRID  EQ  LV_USRID
                AND  ZAUTH  EQ  'I'
                .
        IF SY-SUBRC  EQ  0.

          CLEAR LV_AUTXT.
          ASSIGN COMPONENT LV_FNAME2 OF STRUCTURE GS_APPROVAL TO <FS>.
          IF <FS> IS ASSIGNED.
            DOMAIN_TEXT 'ZDAUT_APP' <FS> LV_AUTXT.
          ENDIF.


*         /address
          LS_SOLISTI1-LINE = ZMMT0139M-EMAIL.
          APPEND LS_SOLISTI1 TO LT_EMAIL.



*         /contents
          CLEAR LS_SOLISTI1.   APPEND LS_SOLISTI1 TO LT_TEXTS.

          "기안의견: 품의제목
          CONCATENATE '[긴급]' ZMMT0152M-ZTITL
                      INTO LS_SOLISTI1 SEPARATED BY SPACE.
          APPEND LS_SOLISTI1 TO LT_TEXTS.   CLEAR LS_SOLISTI1.

          "품의번호: 구매요청번호
          CONCATENATE '품의번호:' ZMMT0152M-APPNO ZMMT0152M-APCNT
                      INTO LS_SOLISTI1 SEPARATED BY SPACE.
          APPEND LS_SOLISTI1 TO LT_TEXTS.   CLEAR LS_SOLISTI1.

          "품의권한: 최종승인 OR 검토 OR 승인
          CONCATENATE '품의권한:' LV_AUTXT INTO LS_SOLISTI1
                                SEPARATED BY SPACE.
          APPEND LS_SOLISTI1 TO LT_TEXTS.


          CALL FUNCTION 'Z_MM_SIMPLE_SEND_MAIL'
            EXPORTING
              I_OBJ_NAME = LV_OBJ_NAME
              I_OBJ_DESC = PV_OBJ_DESC
            IMPORTING
              E_RETURN   = LV_RETURN
              E_MESSAGE  = LV_MESSAGE
            TABLES
              IT_EMAIL   = LT_EMAIL
              IT_TEXTS   = LT_TEXTS
              IT_BINTX   = LT_BINTX.


          REFRESH: LT_EMAIL,   LT_TEXTS.


        ENDIF.

      ENDIF.

      UNASSIGN <FS>.

    ELSE.
      EXIT.

    ENDIF.

  ENDDO.

ENDFORM.                    " GET_EMAIL_ADD
*&---------------------------------------------------------------------*
*&      Form  SET_FUNTIONCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7754   text
*----------------------------------------------------------------------*
FORM SET_FUNTIONCODE  USING  FCODE.

*   강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = FCODE
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.

ENDFORM.                    " SET_FUNTIONCODE
*&---------------------------------------------------------------------*
*&      Form  EXECU_CANC_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_ORD_NUM  text
*----------------------------------------------------------------------*
FORM EXECU_CANC_REQUEST  USING    P_ORD_NUM.

  DATA : LV_STATUS.

  CALL FUNCTION 'ZLE_RFC_LOGISPOT_REQ'
    EXPORTING
      I_TYPE    = 'C'
      I_ORD_NUM = P_ORD_NUM
      I_TOKEN   = GV_TOKEN
      I_DEST    = GV_DEST
    IMPORTING
      E_STATUS  = LV_STATUS.


  IF LV_STATUS EQ '9' AND
     P_ORD_NUM IS NOT INITIAL. "정상 취소요청
    GT_ALV3-LOGI_STATUS = ICON_LED_YELLOW.
    UPDATE ZLET0108 SET STATUS = LV_STATUS
                        AENAM  = SY-UNAME
                        AEDAT  = SY-DATUM
                        AEZET  = SY-UZEIT
                  WHERE ORD_NUM EQ P_ORD_NUM.

    UPDATE ZLET0105 SET LOGI_STATUS = 'C'
                        AENAM  = SY-UNAME
                        AEDAT  = SY-DATUM
                        AEZET  = SY-UZEIT
                  WHERE ORD_NUM EQ P_ORD_NUM.

    CLEAR GT_ALV3-ORD_NUM.
    MODIFY GT_ALV3  TRANSPORTING  ORD_NUM LOGI_STATUS
                    WHERE ORD_NUM EQ P_ORD_NUM.
  ELSE.
    GT_ALV3-LOGI_STATUS = ICON_LED_RED.
    MODIFY GT_ALV3  TRANSPORTING  LOGI_STATUS
                    WHERE ORD_NUM EQ P_ORD_NUM.

    GF_LOGI_ERR = GC_X.
  ENDIF.


  PERFORM SET_DATA_SEND_MSG.

  IF GS_RECEIVER-MCHK1 IS NOT INITIAL OR
     GS_RECEIVER-MCHK3  IS NOT INITIAL.
    PERFORM SEND_SMS .
  ENDIF.

  IF GS_RECEIVER-MCHK2 IS NOT INITIAL OR
     GS_RECEIVER-MCHK3 IS NOT INITIAL.
    PERFORM SEND_MAIL.
  ENDIF.



ENDFORM.                    " EXECU_CANC_REQUEST
*&---------------------------------------------------------------------*
*& Form ISHMED_ROUND_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ISHMED_ROUND_TIME  USING    I_ROUND_MINUTE
                        CHANGING C_DATE
                                 C_TIME.
  DATA: L_HOUR TYPE I,
        L_MIN  TYPE I,
        L_SEC  TYPE I,
*       L_SUM muss Typ 'F' sein, sonst wird falsch gerechnet!!!
        L_SUM  TYPE F,
        L_TIME TYPE SY-UZEIT.


* Fichte, Nr 2845: Neue Rundungsmethode
  IF C_DATE < '19000101'.
    C_DATE = SY-DATUM.
    C_TIME = SY-UZEIT.
  ENDIF.
  L_HOUR = C_TIME(2).
  L_MIN  = C_TIME+2(2).
  L_SEC  = C_TIME+4(2).
* Achtung: 00:00:00 soll 00:00:00 bleiben. Erst 00:00:01
* wird z.B zu 00:30:00
  L_SUM  = L_HOUR * 3600 + L_MIN * 60 + L_SEC - 1.
  IF L_SUM < 0.
    L_SUM = 24 * 60 * 60 - 1.
  ENDIF.
  L_SUM = ( TRUNC( L_SUM / ( I_ROUND_MINUTE * 60 ) ) + 1 )
            * ( I_ROUND_MINUTE * 60 ).
  IF L_SUM >= 86400.            " 60 Sec * 60 Min * 24 Hour
    L_SUM = L_SUM - 86400.
  ENDIF.
  L_HOUR = TRUNC( L_SUM / 3600 ).
  L_MIN  = TRUNC( ( L_SUM - L_HOUR * 3600 ) / 60 ).
  WRITE L_HOUR TO L_TIME(2)   USING EDIT MASK 'RR__'.
  WRITE L_MIN  TO L_TIME+2(2) USING EDIT MASK 'RR__'.
  WRITE '00' TO L_TIME+4(2).
  TRANSLATE L_TIME USING ' 0'.
  IF L_TIME < C_TIME.
    C_DATE = C_DATE + 1.
  ENDIF.
  C_TIME = L_TIME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATLT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_ALV3_KUNNR
*&      --> GT_ALV3_DATLT
*&---------------------------------------------------------------------*
FORM GET_DATLT  USING      PV_FLAG
                           PV_CODE
                           PV_DATLT.

  DATA : LV_LIFNR      LIKE LFA1-LIFNR,
         LV_EXTENSION1 LIKE ADRC-EXTENSION1.
  CLEAR: LV_LIFNR, LV_EXTENSION1.

  LV_LIFNR = PV_CODE.

  IF PV_FLAG = 'V'.
    CALL FUNCTION 'Z_FI_GET_DATLT'
      EXPORTING
        I_LIFNR      = LV_LIFNR
      IMPORTING
        E_EXTENSION1 = LV_EXTENSION1.
  ELSEIF PV_FLAG = 'C'.
    CALL FUNCTION 'Z_FI_GET_DATLT'
      EXPORTING
        I_KUNNR      = LV_LIFNR
      IMPORTING
        E_EXTENSION1 = LV_EXTENSION1.
  ENDIF.

  PV_DATLT = LV_EXTENSION1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_BOT .
  CLEAR GT_ALV2.
  GT_ALV2-SEL2 = 'X'.
  MODIFY GT_ALV2 TRANSPORTING SEL2 WHERE SEL2 EQ SPACE.



  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GRID2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_BOT .
  CLEAR GT_ALV2.
  MODIFY GT_ALV2 TRANSPORTING SEL2 WHERE SEL2 EQ 'X'.



  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GRID2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS_9000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_9000 .
  IF GRID9 IS NOT INITIAL.
    CALL METHOD GRID9->FREE.
    CLEAR GRID9.
  ENDIF.
  IF CONTAINER_SUB9 IS NOT INITIAL.
    CALL METHOD CONTAINER_SUB9->FREE.
    CLEAR:CONTAINER_SUB9.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGORT_9000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LGORT_9000 .
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3410' ) TO GR_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3420' ) TO GR_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3430' ) TO GR_LGORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHARACTERISTIC_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ALV2_VGBEL
*&      --> PT_ALV2_VGPOS
*&      --> P_
*&      <-- PT_ALV2_LENGTH
*&      <-- CLEAR
*&      <-- GV_MENGE
*&---------------------------------------------------------------------*
FORM SET_CHARACTERISTIC_VALUES  USING    PV_VGBEL
                                         PV_VGPOS
                                         PV_ATNAM
                                CHANGING PV_ATWRT.

  DATA: LT_CHAR  LIKE CONF_OUT OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
    EXPORTING
      I_VBELN                      = PV_VGBEL
      I_POSNR                      = PV_VGPOS
    TABLES
      ET_CHAR                      = LT_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.

  CHECK LT_CHAR[] IS NOT INITIAL.

  PV_ATWRT = VALUE #( LT_CHAR[ ATNAM = PV_ATNAM ]-ATWRT OPTIONAL ).


ENDFORM.
