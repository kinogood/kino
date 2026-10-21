*&---------------------------------------------------------------------*
*&  Include           MZGTSDR1230O02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0311  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0311 OUTPUT.


  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T01.

ENDMODULE.                 " STATUS_0311  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0312  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0312 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T02.

ENDMODULE.                 " STATUS_0312  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_312  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_312 OUTPUT.

  IF G_CUSTOM_C312 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C312
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_312
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_312
      EXPORTING
        I_PARENT = G_CUSTOM_C312.

*   판매오더로 등록시(멀티선택가능)
    IF GV_MULTI_INPUT = 'X'.
*     alv field catalog 및 layout 설정
      PERFORM FILL_FIELD_CATEGORY_POPU USING    'GS_320'
                                       CHANGING GT_FIELDCAT312.
      PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT312.

      GS_VARIANT-HANDLE = '0109'.
      GS_VARIANT-REPORT = SY-REPID.

      CALL METHOD G_GRID_312->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT      = GS_VARIANT
          IS_LAYOUT       = GS_LAYOUT312
          I_SAVE          = GS_SAVE
        CHANGING
          IT_FIELDCATALOG = GT_FIELDCAT312
          IT_OUTTAB       = GT_320.
    ELSE.
*     alv field catalog 및 layout 설정
      PERFORM FILL_FIELD_CATEGORY_POPU USING    'GS_VBELN'
                                       CHANGING GT_FIELDCAT312.
      PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT312.

      CALL METHOD G_GRID_312->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT       = GS_LAYOUT312
        CHANGING
          IT_FIELDCATALOG = GT_FIELDCAT312
          IT_OUTTAB       = GT_VBELN[].
    ENDIF.
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_312.

ENDMODULE.                 " ALV_INIT_312  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0313  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0313 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T03.

ENDMODULE.                 " STATUS_0313  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_313  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_313 OUTPUT.

  IF G_CUSTOM_C313 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C313
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_313
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_313
      EXPORTING
        I_PARENT = G_CUSTOM_C313.

*   alv field catalog 및 layout 설정
    PERFORM FILL_FIELD_CATEGORY_POPU USING    'GT_TAGNR'
                                     CHANGING GT_FIELDCAT313.
    PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT313.

    GS_VARIANT-HANDLE = '0002'.
    GS_VARIANT-REPORT = SY-REPID.

    CALL METHOD G_GRID_313->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        IS_LAYOUT       = GS_LAYOUT313
        I_SAVE          = GS_SAVE
      CHANGING
        IT_FIELDCATALOG = GT_FIELDCAT313
        IT_OUTTAB       = GT_TAGNR[].
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_313.

ENDMODULE.                 " ALV_INIT_313  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0314  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0314 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T04.

ENDMODULE.                 " STATUS_0314  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_314  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_314 OUTPUT.

  IF G_CUSTOM_C314 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C314
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_314
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_314
      EXPORTING
        I_PARENT = G_CUSTOM_C314.

*   alv field catalog 및 layout 설정
    PERFORM FILL_FIELD_CATEGORY_POPU USING    'GT_PO'
                                     CHANGING GT_FIELDCAT314.
    PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT314.

    GS_VARIANT-HANDLE = '0003'.
    GS_VARIANT-REPORT = SY-REPID.

    CALL METHOD G_GRID_314->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        IS_LAYOUT       = GS_LAYOUT314
        I_SAVE          = GS_SAVE
      CHANGING
        IT_FIELDCATALOG = GT_FIELDCAT314
        IT_OUTTAB       = GT_PO[].
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_314.

ENDMODULE.                 " ALV_INIT_314  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_INIT_DATA_0315  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_INIT_DATA_0315 OUTPUT.

* 판매오더 수정불가
  GS_311-KDAUF = GS_101-KDAUF.

ENDMODULE.                 " SET_INIT_DATA_0315  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_INIT_DATA_0311  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_INIT_DATA_0311 OUTPUT.

* 플랜트의 초기값을 가져온다.
  IF GS_101-WERKS_M IS INITIAL.
    GS_101-WERKS_M  = GS_100-WERKS_H.       "플랜트
    GS_101-WERKST   = GS_100-WERKST.      "플랜트명
  ENDIF.

ENDMODULE.                 " SET_INIT_DATA_0311  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0320  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0320 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR 'T0000' WITH TEXT-T05.

ENDMODULE.                 " STATUS_0320  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_KDAUF_VBELN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KDAUF_VBELN INPUT.

  CHECK NOT GS_102-KDAUF IS INITIAL AND
        NOT GS_102-VBELN IS INITIAL.

  SELECT SINGLE * FROM LIPS
                 WHERE VBELN = GS_102-VBELN   "납품오더
                   AND VGBEL = GS_102-KDAUF.  "판매오더
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH TEXT-E19.
  ENDIF.

ENDMODULE.                 " CHECK_KDAUF_VBELN  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_INIT_DATA_0316  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_INIT_DATA_0316 OUTPUT.

* 플랜트로 회사코드를 찾아온다.
  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_WERKS = GS_101-WERKS_M
    IMPORTING
      E_BUKRS = GS_316-BUKRS.

ENDMODULE.                 " SET_INIT_DATA_0316  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0321  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0321 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T06.

ENDMODULE.                 " STATUS_0321  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_321  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_321 OUTPUT.

  IF G_CUSTOM_C321 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C321
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_321
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_321
      EXPORTING
        I_PARENT = G_CUSTOM_C321.

*   alv field catalog 및 layout 설정
    PERFORM FILL_FIELD_CATEGORY_POPU USING    'GT_0321'
                                     CHANGING GT_FIELDCAT321.
    PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT321.

    GS_VARIANT-HANDLE = '0004'.
    GS_VARIANT-REPORT = SY-REPID.

    CALL METHOD G_GRID_321->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        IS_LAYOUT       = GS_LAYOUT321
        I_SAVE          = GS_SAVE
      CHANGING
        IT_FIELDCATALOG = GT_FIELDCAT321
        IT_OUTTAB       = GT_0321[].
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_321.

ENDMODULE.                 " ALV_INIT_321  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_MULTI_INPUT_FLAG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_MULTI_INPUT_FLAG OUTPUT.

* 멀티선택 플래그 활성화
  GV_MULTI_INPUT = 'X'.

ENDMODULE.                 " SET_MULTI_INPUT_FLAG  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_AMOUNT  OUTPUT
*&---------------------------------------------------------------------*
*       손실금액을 읽어온다.
*----------------------------------------------------------------------*
MODULE GET_AMOUNT OUTPUT.

*  PERFORM GET_AMOUNT_A.    "물류손실금액을 읽어온다.
*  PERFORM GET_AMOUNT_B.    "CS비용을 읽어온다.
*  PERFORM GET_AMOUNT_C.    "AS손실금액을 읽어온다.
*  PERFORM GET_AMOUNT_S.    "총손실금액을 구한다.

ENDMODULE.                 " GET_AMOUNT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_AMOUNT_810  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_AMOUNT_810 OUTPUT.

* local variable
  DATA: LS_210 LIKE LINE OF GT_210.
  CLEAR: S_810.

* 선택한 항목을 가져온다.
  READ TABLE GT_210 INTO LS_210 WITH KEY MARK = 'X'.
  CHECK SY-SUBRC EQ 0.

* 선택한 항목의 금액을 읽어온다.
  SELECT SINGLE RFAMT RTAMT RTAMT2 GBAMT CLAMT IPCST MVCST
           FROM ZQMT0011M
           INTO S_810
          WHERE RCEPNO  EQ LS_210-RCEPNO
            AND ZMATSEQ EQ LS_210-ZMATSEQ.

ENDMODULE.                 " GET_AMOUNT_810  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_910  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_910 OUTPUT.

  IF G_CUSTOM_C910 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C910
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_910
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_910
      EXPORTING
        I_PARENT          = G_CUSTOM_C910
        I_APPL_EVENTS     = 'X'   "스크린에 이벤트값을 인식함
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1 "ERROR HANDLING
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4.

*   Tool Bar 버튼 제거 필요없는 버튼 추가.
*C20111123_03752 합계버튼 추가
* PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.
    PERFORM EXCLUDE_OF_TOOLBAR_BUTTON_910 USING 'GT_EXCLUDE'.

*   alv field catalog 및 layout 설정
    PERFORM GET_DATA_ZQMT0016F.
    PERFORM FILL_FIELD_CATEGORY_POPU USING    'GS_ZQMT0016F'
                                     CHANGING GT_FIELDCAT910.
    PERFORM MODIFY_FIELDCAT_910      CHANGING GT_FIELDCAT910.
    PERFORM PRO_LAYOUT_POPU USING GS_LAYOUT910.
    GS_LAYOUT910-NO_ROWMARK = 'X'.

*   Edit Event 및 Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_910.

    GS_VARIANT910-HANDLE = '0111'.
    GS_VARIANT910-REPORT = SY-REPID.

    CALL METHOD G_GRID_910->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT           = GS_VARIANT910
        IS_LAYOUT            = GS_LAYOUT910
        I_SAVE               = GS_SAVE
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      CHANGING
        IT_FIELDCATALOG      = GT_FIELDCAT910
        IT_OUTTAB            = GT_ZQMT0016F.
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_910.

ENDMODULE.                 " ALV_INIT_910  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  BELART_LIST_BOX  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE BELART_LIST_BOX OUTPUT.

* local variable
  TYPE-POOLS VRM.  "vrm type group 선언
  DATA: LT_ZQMT0017 LIKE ZQMT0017 OCCURS 0 WITH HEADER LINE,
        LT_VALUES TYPE VRM_VALUES WITH HEADER LINE,
        LV_BUKRS TYPE BUKRS.

  PERFORM GET_BUKRS USING GS_100-WERKS_H
                    CHANGING LV_BUKRS.

  SELECT QCODE1 HKONT BTEXT
    INTO CORRESPONDING FIELDS OF TABLE LT_ZQMT0017
    FROM ZQMT0017
   WHERE GJAHR = SY-DATUM(4)
     AND BUKRS = LV_BUKRS.

  DELETE ADJACENT DUPLICATES FROM LT_ZQMT0017
         COMPARING QCODE1 BTEXT.

  CLEAR   : LT_VALUES.
  REFRESH : LT_VALUES.

  LOOP AT LT_ZQMT0017.
    LT_VALUES-KEY  = LT_ZQMT0017-QCODE1.
    LT_VALUES-TEXT = LT_ZQMT0017-BTEXT.
    APPEND LT_VALUES.
    CLEAR: LT_VALUES.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'S_910-BELART'
      VALUES          = LT_VALUES[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.
  IF SY-SUBRC NE 0.
  ENDIF.

ENDMODULE.                 " BELART_LIST_BOX  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_920  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_920 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR 'T0000' WITH '전표추가'.

ENDMODULE.                 " STATUS_920  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_930  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_950 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR 'T0000' WITH '문서추가'.

ENDMODULE.                 " STATUS_920  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_930  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_INIT_930 OUTPUT.

* local variable
  DATA: LW_NAME1 LIKE KNA1-NAME1,
        LL_CHECK(1).

  PERFORM GET_BUKRS USING GS_100-WERKS_H
                    CHANGING LV_BUKRS.

  MOVE-CORRESPONDING GS_100 TO ZQMS301.
  ZQMS301-WERKS  = GS_100-WERKS_H.
  ZQMS301-BUKRS  = LV_BUKRS.
  ZQMS301-BLART  = 'KQ'.
  ZQMS301-NEWBS1 = '40'.
  ZQMS301-NEWKO1 = S_910-HKONT.
  ZQMS301-NEWBS2 = '31'.

  CONCATENATE '고객불만 ' GS_100-RCEPNO '번' INTO ZQMS301-BKTXT.

  IF ZQMS301-NEWKO2 IS INITIAL.
    SELECT SINGLE A~LIFNR
             INTO ZQMS301-NEWKO2
             FROM KNA1 AS A
             JOIN LFA1 AS B
               ON A~LIFNR EQ B~LIFNR
            WHERE A~KUNNR EQ GS_100-KUNUM.
  ENDIF.

  IF ZQMS301-NEWKO2 IS INITIAL.
*    SELECT SINGLE NAME1
*             INTO LW_NAME1
*             FROM KNA1
*            WHERE KUNNR EQ GS_100-KUNUM.
*
*    CHECK SY-SUBRC EQ 0.
*    SELECT SINGLE LIFNR INTO ZQMS301-NEWKO2
*                        FROM LFA1
*                       WHERE NAME1 EQ LW_NAME1.
  ENDIF.

  IF SY-SUBRC NE 0 OR ZQMS301-NEWKO2 EQ ' '.
    CLEAR: LL_CHECK.
    SELECT SINGLE CHK_VENDOR
             INTO LL_CHECK
             FROM ZQMT0017
            WHERE BUKRS EQ LV_BUKRS
              AND GJAHR EQ SY-DATUM(4)
              AND QCODE1 EQ S_910-BELART
              AND HKONT EQ ZQMS301-NEWKO1.
    IF LL_CHECK EQ 'X'.
      MESSAGE S002  WITH 'Vendor Master에 등록되지 않은'
                         'Customer 입니다.'.
      LEAVE TO SCREEN 0.
      EXIT.
    ENDIF.
  ENDIF.

*-  LSM의 경우에 한함.
*-  ZLOCK 칼럼 추가 : Y 값은 비용제한함. N 값은 비용 제한 안함.
*-  더 이상 사용 안하는 영업팀도 당해로 등록할것임.
*-  신규 영업팀은 당해년도로 등록하고 더 이상 사용하지 않는 영업팀도 당해로 등록함.
*-  신규 영업팀은 ZLOCK 칼럼을 사용안함.
*-  미사용 영업팀 만 ZLOCK 칼럼을 사용하여 Y 면 통제, N 이면 통제 안함.

**& C20120703_39817: 사업영역, 코스트 센터 자동입력
*  SELECT SINGLE GSBER KOSTL
*    INTO (ZQMS301-GSBER, ZQMS301-KOSTL)
*    FROM ZCOTA031
*   WHERE VKGRP = GS_100-VKGRP
*     AND GJAHR = GS_100-RCEPDT(4)
*     AND KOKRS = ZQMS301-BUKRS.
 IF ZQMS301-BUKRS EQ '3000'. "LSM
    SELECT SINGLE GSBER KOSTL
      INTO (ZQMS301-GSBER, ZQMS301-KOSTL)
      FROM ZCOTA031
     WHERE VKGRP = GS_100-VKGRP
       AND GJAHR = GS_100-RCEPDT(4)
       AND KOKRS = ZQMS301-BUKRS
       AND ZLOCK = ''.
  ELSE.
    SELECT SINGLE GSBER KOSTL
      INTO (ZQMS301-GSBER, ZQMS301-KOSTL)
      FROM ZCOTA031
     WHERE VKGRP = GS_100-VKGRP
       AND GJAHR = GS_100-RCEPDT(4)
       AND KOKRS = ZQMS301-BUKRS.
  ENDIF.

ENDMODULE.                 " SCREEN_INIT_930  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  LIST_BOX  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LIST_BOX OUTPUT.

  TYPE-POOLS VRM.  "vrm type group 선언
  DATA VALUES1 TYPE VRM_VALUES WITH HEADER LINE.

  FREE VALUES1.

  VALUES1-KEY = 'A'.
  VALUES1-TEXT = 'DISPLAY MODE'.
  APPEND VALUES1.
  VALUES1-KEY = 'E'.
  VALUES1-TEXT = 'ERROR MODE'.
  APPEND VALUES1.
  VALUES1-KEY = 'N'.
  VALUES1-TEXT = 'NO DISPLAY MODE'.
  APPEND VALUES1.

  CLEAR VALUES1.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'G_DIMODE'
      VALUES          = VALUES1[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0.

  ENDIF.

ENDMODULE.                 " LIST_BOX  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_940  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_940 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T07.

ENDMODULE.                 " STATUS_940  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_940  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_INIT_940 OUTPUT.


  PERFORM GET_USRID USING    S_940-CPERNR
                    CHANGING S_940-CPERNRT
                             S_940-CNAM
                             S_940-CNAMT.

  IF S_940-BUKRS IS INITIAL.
    PERFORM GET_BUKRS USING GS_100-WERKS_H
                    CHANGING LV_BUKRS.

    S_940-BUKRS = LV_BUKRS.
  ENDIF.
  IF S_940-GJAHR IS INITIAL.
*    S_940-GJAHR = SY-DATUM(4).
    S_940-GJAHR = S_940-GJAHR.
  ENDIF.

  LOOP AT SCREEN.

    IF SCREEN-NAME EQ 'PB_CONF'.
      IF S_940-BELNR IS INITIAL.
        SCREEN-INPUT =  0.
      ELSE.
        SCREEN-INPUT =  1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SCREEN_INIT_940  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_950  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_INIT_950 OUTPUT.

  PERFORM GET_USRID USING    S_950-CPERNR
                    CHANGING S_950-CPERNRT
                             S_950-CNAM
                             S_950-CNAMT.

  IF S_950-BUKRS IS INITIAL.
    PERFORM GET_BUKRS USING GS_100-WERKS_H
                    CHANGING LV_BUKRS.

    S_950-BUKRS = LV_BUKRS.
  ENDIF.
  IF S_950-GJAHR IS INITIAL.
*    S_950-GJAHR = SY-DATUM(4).
    S_950-GJAHR = S_950-GJAHR.
  ENDIF.


  IF GV_TRTYP = 'A' .

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.


ENDMODULE.                 " SCREEN_INIT_950  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SET_INIT_DATA_910  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_INIT_DATA_910 OUTPUT.

  CHECK GT_ZQMT0016F IS INITIAL.
  PERFORM FI_COST.

ENDMODULE.                 " SET_INIT_DATA_910  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0323  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0323 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR  'T0000' WITH TEXT-T01.

ENDMODULE.                 " STATUS_0323  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_323  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_INIT_323 OUTPUT.

  IF G_CUSTOM_C323 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C323
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_323
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_323
      EXPORTING
        I_PARENT = G_CUSTOM_C323.

*   alv field catalog 및 layout 설정
    PERFORM SET_FIELD_DETAIL USING    '0323'
                             CHANGING GT_FIELDCAT323.
    PERFORM PRO_LAYOUT_POPU          USING GS_LAYOUT323.

    GS_VARIANT-HANDLE = '0005'.
    GS_VARIANT-REPORT = SY-REPID.

    CALL METHOD G_GRID_323->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        IS_LAYOUT       = GS_LAYOUT323
        I_SAVE          = GS_SAVE
      CHANGING
        IT_FIELDCATALOG = GT_FIELDCAT323
        IT_OUTTAB       = GT_MTBLN.
  ENDIF .

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_323.

ENDMODULE.                 " ALV_INIT_323  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CLM_COUNT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CLM_COUNT OUTPUT.

  READ TABLE GT_100 INDEX TC_100-CURRENT_LINE.

* 불만집계의 누적값을 구한다.
  IF GT_100-MATCT IS INITIAL.
    PERFORM GET_COUNT_MATCT USING    GT_100-WERKS_M
                                     GT_100-MATNR
                                     GS_100-RCEPNO
                                     GT_100-ZMATSEQ
                            CHANGING GT_100-MATCT.
  ENDIF.

* 불만주의의 누적값을 구한다.
  IF GT_100-KUNCT IS INITIAL.
    PERFORM GET_COUNT_KUNCT USING    GS_100-KUNUM
                                     GT_100-WERKS_M
                                     GT_100-MATNR
                                     GS_100-RCEPNO
                                     GT_100-ZMATSEQ
                            CHANGING GT_100-KUNCT.
  ENDIF.

* 불만집계 / 불만주의 누적값 업데이트
  MODIFY GT_100 INDEX TC_100-CURRENT_LINE
                TRANSPORTING MATCT KUNCT.

  GT_100_OLD[] = GT_100[].

ENDMODULE.                 " SET_CLM_COUNT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CLR_COUNT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CLR_COUNT OUTPUT.

  READ TABLE GT_120 INDEX TC_120-CURRENT_LINE.

* 불만재발 누적값을 구한다.
  IF GT_120-REDCT IS INITIAL.
    PERFORM GET_COUNT_REDCT USING    GS_100-KUNUM    "고객
                                     GT_120-FTGRP    "코드그룹
                                     GT_120-FLTTP    "코드
                                     GS_100-RCEPNO   "접수번호
                                     GS_101-ZMATSEQ  "자재Seq
                                     GT_120-ZBADSEQ  "불량Seq
                                     GS_101-WERKS_M  "플랜트
                            CHANGING GT_120-REDCT.   "불만재발
  ENDIF.

* 불만재발 누적값 업데이트
  MODIFY GT_120 INDEX TC_120-CURRENT_LINE
                TRANSPORTING REDCT.

ENDMODULE.                 " SET_CLR_COUNT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0316  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0316 OUTPUT.



* C20111012_79186  : START   호사코드 1000인경우 필드값 제어추가
  LOOP AT  SCREEN.
    IF GS_100-STATUS <> 'CL30'.

    ELSE.
      IF SCREEN-NAME = 'GS_316-FTGRP' AND G_BUKRS = '6000'.
        SCREEN-REQUIRED = 1.
      ENDIF.
      IF SCREEN-NAME = 'GS_316-FLTTP' AND G_BUKRS = '6000'.
        SCREEN-REQUIRED = 1.
      ENDIF.
    ENDIF.

    MODIFY    SCREEN.
  ENDLOOP.
* C20111012_79186  : end


ENDMODULE.                 " MODIFY_SCREEN_0316  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_960  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_INIT_960 OUTPUT.


  IF G_CUSTOM_C960 IS INITIAL.
    CREATE OBJECT G_CUSTOM_C960
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_960
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    IF SY-SUBRC NE 0 .
    ENDIF.

    CREATE OBJECT G_GRID_960
      EXPORTING
        I_PARENT          = G_CUSTOM_C960
        I_APPL_EVENTS     = 'X'   "스크린에 이벤트값을 인식함
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1 "ERROR HANDLING
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4.



*   alv field catalog 및 layout 설정
    PERFORM GET_DATA_ZQMT0018M.
    PERFORM FILL_FIELD_CATEGORY_POPU USING    'GS_ZQMT0018M'
                                     CHANGING GT_FIELDCAT960.
    PERFORM MODIFY_FIELDCAT_960      CHANGING GT_FIELDCAT960.

    PERFORM PRO_LAYOUT_POPU_960 USING GS_LAYOUT960.


*   Edit Event 및 Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_960.

    GS_VARIANT960-HANDLE = '0111'.
    GS_VARIANT960-REPORT = SY-REPID.

  ENDIF .
*   Tool Bar 버튼 제거 필요없는 버튼 추가.
  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON_GRID  USING 'GT_EXCLUDE'.

  CALL METHOD G_GRID_960->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT960
      IS_LAYOUT            = GS_LAYOUT960
      I_SAVE               = GS_SAVE
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT960
      IT_OUTTAB            = GT_ZQMT0018M.





ENDMODULE.                 " SCREEN_INIT_960  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_960  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_960 OUTPUT.
  SET PF-STATUS 'POP3'.
  SET TITLEBAR 'T0000' WITH '문서관리'.

ENDMODULE.                 " STATUS_960  OUTPUT
