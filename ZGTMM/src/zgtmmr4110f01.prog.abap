*&---------------------------------------------------------------------*
*& Include          ZGTMMR4110F01
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

  PERFORM SET_FUNC_KEY. "추가(SJM 25.02.17)

  CLEAR : S_BUDAT[].
  S_BUDAT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_BT
                         LOW    = SY-DATLO - 30
                         HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FUNC_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FUNC_KEY.

* GS_FKEY-TEXT
  GS_FKEY-ICON_ID   = ICON_TRANSFER.
  GS_FKEY-ICON_TEXT = '재고환입'(B00).
  GS_FKEY-QUICKINFO = '재고환입'(B00).

  SSCRFIELDS-FUNCTXT_01 = GS_FKEY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN P_GOP.
        IF ( ( SCREEN-GROUP3 = GC_HGH OR SCREEN-GROUP3 = GC_VPU )
           AND SCREEN-GROUP4 = GC_005 )
        OR (   SCREEN-GROUP1 = GC_GOP ).
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP4 <> GC_006.
          SCREEN-REQUIRED = GC_2.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_GOD OR P_APD.
        IF ( SCREEN-GROUP1 = GC_MAT ).
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP4 <> GC_005.
          SCREEN-REQUIRED = GC_2.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_APM.
        IF ( SCREEN-GROUP1 = GC_APM )
        OR ( SCREEN-GROUP1 = GC_MAT )
        OR ( SCREEN-GROUP3 = GC_VPU AND SCREEN-GROUP4 = GC_006 ).
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP4 <> GC_004 AND SCREEN-GROUP4 <> GC_005.
          SCREEN-REQUIRED = GC_2.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PBO_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PBO_0300.

  DATA : LT_EXCD TYPE TABLE OF SY-UCOMM.


  CHECK SY-DYNNR = GC_0300.

  LT_EXCD[] = VALUE #( ( 'NONE' )   "Check Input
                       ( 'GET' )    "Get Variant...
                       ( 'SPOS' ) )."Save as Variant...

  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      P_STATUS  = CONV SYST_PFKEY( '%_CSP' ) "RSSYSTDB
      P_PROGRAM = SY-REPID
    TABLES
      P_EXCLUDE = LT_EXCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  "필수 입력 필드 Check
  PERFORM CHECK_NULL USING P_BUKRS 'P_BUKRS' '회사코드'(F01).
  PERFORM CHECK_NULL USING P_WERKS 'P_WERKS' '플랜트'(F04).

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.
  SET PARAMETER ID 'WRK' FIELD P_WERKS.

  IF P_APM <> GC_X.
    PERFORM CHECK_NULL USING P_LGORT 'P_LGORT' '저장위치'(F06).
  ENDIF.

  IF P_GOP = GC_X.
    PERFORM CHECK_NULL USING S_LIFNR-LOW 'S_LIFNR-LOW'
                             %_S_LIFNR_%_APP_%-TEXT. "외주가공업체
  ELSE.
    PERFORM CHECK_NULL USING S_BUDAT-LOW 'S_BUDAT-LOW'
                             %_S_BUDAT_%_APP_%-TEXT. "조회기간
  ENDIF.

  "입력값 유효성 Check
  PERFORM CHECK_BUKRS.
  PERFORM CHECK_WERKS.
  PERFORM CHECK_LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NULL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_NULL USING P_VAL
                      P_FNM
                      P_TXT.

  CHECK GV_ERR IS INITIAL.

  IF P_VAL IS INITIAL.
    PERFORM DYNP_VALUES_READ USING P_FNM
                          CHANGING P_VAL.
  ENDIF.

  CHECK P_VAL IS INITIAL.

  SET CURSOR FIELD P_FNM.
  MESSAGE S015 WITH P_TXT DISPLAY LIKE 'E'. "&를(을) 입력하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BUKRS.

  CHECK GV_ERR  IS INITIAL.
  CHECK P_BUKRS IS NOT INITIAL.

  SELECT SINGLE BUKRS
    FROM T001 INTO @DATA(LV_BUKRS)
   WHERE BUKRS = @P_BUKRS.

  CHECK LV_BUKRS IS INITIAL.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE S016 WITH '회사코드'(F01) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_WERKS.

  "회사코드-플랜트간 종속성 체크

  CHECK GV_ERR  IS INITIAL.
  CHECK P_BUKRS IS NOT INITIAL
    AND P_WERKS IS NOT INITIAL.

  SELECT SINGLE W~WERKS
    FROM T001K AS K INNER JOIN T001W AS W
      ON K~BWKEY = W~BWKEY
    INTO @DATA(LV_WERKS)
   WHERE K~BUKRS = @P_BUKRS
     AND W~WERKS = @P_WERKS.

  CHECK LV_WERKS IS INITIAL.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE S016 WITH '플랜트'(F04) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LGORT.

  "플랜트-저장위치간 종속성 체크

  CHECK GV_ERR  IS INITIAL.
  CHECK P_WERKS IS NOT INITIAL
    AND P_LGORT IS NOT INITIAL.

  SELECT SINGLE LGORT
    FROM T001L INTO @DATA(LV_LGORT)
   WHERE WERKS = @P_WERKS
     AND LGORT = @P_LGORT.

  CHECK LV_LGORT IS INITIAL.

  SET CURSOR FIELD 'P_LGORT'.
  MESSAGE S016 WITH '저장위치'(F06) DISPLAY LIKE 'E'. "&를(을) 확인하세요.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ACTV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ACTV.

  "Pgm.실행 Active Flag Check(SJM 25.04.17)

  SELECT SINGLE FLD_03
    FROM ZGTPPT1010 INTO @DATA(LV_CHK)
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0200
     AND FLD_01      = @GC_ZGTMMR4110.

  CHECK LV_CHK IS INITIAL.
  MESSAGE E134. "해당 Pgm.은 실행 불가한 상태입니다.

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

  "권한 체크 추가(SJM 25.02.17)

  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAI_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PAI_1000.

  "'재고환입' Pgm.이동 기능 추가(SJM 25.02.17)

  CHECK SY-DYNNR = GC_1000.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      SUBMIT ZGTMMR4111 WITH P_BUKRS  = P_BUKRS
                        WITH P_WERKS  = P_WERKS
                        WITH P_LGORT  = P_LGORT
                        WITH S_LIFNR IN S_LIFNR
                        WITH P_ORP    = GC_X
                        VIA SELECTION-SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PAI_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PAI_0300.

  "CRET / CCAN

  CHECK SY-DYNNR = GC_0300.

  GV_OKCODE = SY-UCOMM.

  CASE SY-UCOMM.
    WHEN 'CRET'.
      IF P_FPATH IS INITIAL.
        MESSAGE E023. "파일 경로를 입력하세요.
        GV_ERR = GC_X.
      ELSE.
        GV_ERR = SPACE.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_BUKRS
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING PV_FNAME
                   CHANGING PV_FVAL.

  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  CLEAR : LT_DYN[], PV_FVAL.
  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
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

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_FIELD USING PV_TNAME
                      PV_FNAME
                      PV_SHELP
                      PV_FIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = CONV TABNAME( PV_TNAME )
      FIELDNAME         = CONV FIELDNAME( PV_FNAME )
      SEARCHHELP        = CONV SHLPNAME( PV_SHELP )
*     SHLPPARAM         = ' '
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = CONV DYNFNAM( PV_FIELD )
*     STEPL             = 0
*     VALUE             = ' '
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
*     CALLBACK_METHOD   =
*     SELECTION_SCREEN  = ' '
*   IMPORTING
*     USER_RESET        =
    TABLES
      RETURN_TAB        = GT_RTAB
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_WERKS.

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'T001L'
                           'WERKS'
                           'EDOC_BR_WERKS'
                           'P_WERKS'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_LGORT.

  PERFORM DYNP_VALUES_READ USING 'P_WERKS'
                        CHANGING  P_WERKS.

  SET PARAMETER ID 'WRK' FIELD P_WERKS.

  PERFORM F4IF_FIELD USING 'T001L'
                           'LGORT'
                           'ZH_PP_LGORT'
                           'P_LGORT'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
*FORM F4_LIFNR USING PV_FIELD.
*
*  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
*                        CHANGING  P_BUKRS.
*
*  SET PARAMETER ID 'BUK' FIELD P_BUKRS.
*
*  PERFORM F4IF_FIELD USING 'LFA1'
*                           'LIFNR'
*                           'SH_LIFNR'
*                           PV_FIELD.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAND_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MAND_COND.

  CLEAR : GV_ERR.

  CASE 'X'.
    WHEN P_GOP.
      IF P_BUKRS IS INITIAL OR P_WERKS   IS INITIAL
      OR P_LGORT IS INITIAL OR S_LIFNR[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_GOD OR P_APD.
      IF P_BUKRS IS INITIAL OR P_WERKS   IS INITIAL
      OR P_LGORT IS INITIAL OR S_BUDAT[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

    WHEN P_APM.
      IF P_BUKRS   IS INITIAL OR P_WERKS IS INITIAL
      OR S_BUDAT[] IS INITIAL.
        GV_ERR = GC_X.
      ENDIF.

*   WHEN P_APD.

  ENDCASE.

  IF GV_ERR = GC_X.
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    EXIT.
  ENDIF.

  PERFORM CHECK_COND.

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

  CLEAR : GV_CNT.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM GET_GOP_DATA.

    WHEN P_GOD.
      PERFORM GET_GOD_DATA.

    WHEN P_APM.
      PERFORM GET_APM_DATA.

    WHEN P_APD.
      PERFORM GET_APD_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GOP_DATA.

  CLEAR : GT_HGOP[], GT_IGOP[], GT_BATS[].

  SELECT *
    FROM ZGTMM_CV_SCREQLIST_L
    INTO CORRESPONDING FIELDS OF TABLE @GT_HGOP
   WHERE BUKRS  = @P_BUKRS
     AND WERKS  = @P_WERKS
     AND LGORT  = @P_LGORT
     AND LIFNR IN @S_LIFNR
     AND MATNR IN @S_MATNR. "추가(SJM 25.03.25)

  IF GT_HGOP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  PERFORM GET_GOP_HDR.

  PERFORM SET_STYLE USING 'E' 'ISQTY' GT_HGOP-STYLE.
  MODIFY GT_HGOP TRANSPORTING STYLE WHERE XCHPF IS INITIAL.

  SORT GT_HGOP BY REQTY DESCENDING MATNR ASCENDING.

  GV_CNT = LINES( GT_HGOP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GOP_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GOP_HDR.

  DATA : LV_PREIS LIKE ZMMT0860-PREIS.
  DATA : LV_PREIS_EX LIKE ZMMT0860-PREIS.
  CLEAR : GS_HDR.

  GS_HDR-LIFNR = VALUE #( S_LIFNR[ 1 ]-LOW OPTIONAL ).
  PERFORM SET_LNAME USING GS_HDR-LIFNR
                 CHANGING GS_HDR-NAME1.

  GS_HDR-WERKS = P_WERKS.
  GS_HDR-LGORT = P_LGORT.
  PERFORM SET_LGOBE USING GS_HDR-WERKS
                          GS_HDR-LGORT
                 CHANGING GS_HDR-LGOBE.

  PERFORM SET_BLOCK.

  SELECT SINGLE PREIS,                 "보증금액
                TOTALSCVALUE AS SCVAL, "외주재고액
                APVALUE      AS APVAL, "당월IV금액
                WAERS                  "통화
    FROM ZGTMM_CV_SCSTOCKHEADER
    INTO CORRESPONDING FIELDS OF @GS_HDR
   WHERE BUKRS  = @P_BUKRS
     AND LIFNR IN @S_LIFNR.

*--> [CHM2601-00624] 삭제된 보증금액 반영
  SELECT SUM( PREIS )
    INTO @LV_PREIS
    FROM ZMMT0860
   WHERE BUKRS = @P_BUKRS
     AND LIFNR IN @S_LIFNR
     AND DATAB <= @SY-DATLO
     AND DATAI >= @SY-DATLO
     AND DEL_FLAG <> 'X' "--> 삭제 제외
     AND EXCHK <> 'X'. "--> 만료 제외

  SELECT SUM( PREIS )
    INTO @LV_PREIS_EX
    FROM ZMMT0860
   WHERE BUKRS = @P_BUKRS
     AND LIFNR IN @S_LIFNR
     AND DATAB <= @SY-DATLO
     AND DATAI >= @SY-DATLO
     AND DEL_FLAG <> 'X' "--> 삭제 제외
     AND EXCHK = 'X'. "--> 만료는 포함

  LV_PREIS = LV_PREIS + LV_PREIS_EX.

  IF GS_HDR-PREIS <> LV_PREIS.
    GS_HDR-PREIS = LV_PREIS.
  ENDIF.
*<-- [CHM2601-00624] 삭제된 보증금액 반영

  "출고예정액
  GS_HDR-ISVAL = REDUCE DMBTR_CS( INIT X = CONV DMBTR_CS( 0 )
                                   FOR GT_HGOP IN GT_HGOP
                                  NEXT X = X + GT_HGOP-ISVAL ).

  "출고가용액
  GS_HDR-IAVAL = GS_HDR-PREIS - GS_HDR-SCVAL - GS_HDR-ISVAL.
* IF GS_HDR-IAVAL <= 0.
*   GS_HDR-IAVAL = 0.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HDR_LIFNR
*&      <-- GS_HDR_NAME1
*&---------------------------------------------------------------------*
FORM SET_LNAME USING PV_LIFNR
            CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM LFA1 INTO PV_NAME1
   WHERE LIFNR = PV_LIFNR
     AND LOEVM = SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGOBE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HDR_WERKS
*&      --> GS_HDR_LGORT
*&      <-- GS_HDR_LGOBE
*&---------------------------------------------------------------------*
FORM SET_LGOBE USING PV_WERKS
                     PV_LGORT
            CHANGING PV_LGOBE.

  CLEAR : PV_LGOBE.
  CHECK PV_WERKS IS NOT INITIAL
    AND PV_LGORT IS NOT INITIAL.

  SELECT SINGLE LGOBE
    FROM T001L INTO PV_LGOBE
   WHERE WERKS = PV_WERKS
     AND LGORT = PV_LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BLOCK.

* SELECT SINGLE ZGUID
*   FROM ZGTMMT4110 INTO @DATA(LV_ZGUID)
*  WHERE BUKRS   = @P_BUKRS
*    AND WERKS   = @P_WERKS
*    AND LGORT   = @P_LGORT
*    AND LIFNR  IN @S_LIFNR
*    AND APPSTAT = @SPACE.  "값이 존재하면 Check

* SELECT SINGLE ZGUID
*   FROM ZGTMM_CV_SCAPSTATUS INTO @DATA(LV_ZGUID)
*  WHERE BUKRS   = @P_BUKRS
*    AND WERKS   = @P_WERKS
*    AND LGORT   = @P_LGORT
*    AND LIFNR  IN @S_LIFNR
*    AND BLCHECK = @GC_B.

  CLEAR : GS_HDR-BLOCK, GS_HDR-BLOCK_TXT. "추가(SJM 25.05.15)

  SELECT SINGLE O~WERKS, W~NAME1,
                O~LGORT, L~LGOBE, N~NAME
    FROM ZGTMMT4110 AS O JOIN T001W AS W
      ON O~WERKS = W~WERKS
    JOIN T001L AS L
      ON O~WERKS = L~WERKS
     AND O~LGORT = L~LGORT
    LEFT JOIN ZGTMM_CV_GETUSERNAME AS N
      ON O~ERNAM = N~USERID
   WHERE O~BUKRS  = @P_BUKRS
     AND O~LIFNR IN @S_LIFNR
     AND ( O~APPSTAT = @SPACE
      OR ( O~APPSTAT = @GC_A AND O~MBLNR = @SPACE ) )
     AND O~LOEKZ = @SPACE
    INTO @DATA(LS_BLK).

  CHECK SY-SUBRC = 0.

  GS_HDR-BLOCK     = GC_X.
  GS_HDR-BLOCK_TXT = LS_BLK-NAME1 && ` / `
                  && LS_BLK-LGOBE && ` / `
                  && LS_BLK-NAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_HGOP_STYLE
*&---------------------------------------------------------------------*
FORM SET_STYLE USING PV_MODE
                     PV_FNAME
                     PT_STYLE TYPE LVC_T_STYL.

  DATA : LS_STYLE TYPE LVC_S_STYL.


  LS_STYLE-FIELDNAME = PV_FNAME.

  CASE PV_MODE.
    WHEN 'E'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    WHEN 'D'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  ENDCASE.

  INSERT LS_STYLE INTO TABLE PT_STYLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GOD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GOD_DATA.

  CLEAR : GT_HGOD[], GT_IGOD[].

  SELECT S~*,
         L~NAME1
    FROM ZGTMM_CV_MVT541SUM AS S LEFT JOIN LFA1 AS L
      ON S~LIFNR = L~LIFNR
     AND L~LOEVM = @SPACE
     AND L~SPRAS = @SY-LANGU
   WHERE S~BUKRS   = @P_BUKRS
     AND S~WERKS   = @P_WERKS
     AND S~LGORT   = @P_LGORT
     AND S~LIFNR  IN @S_LIFNR
     AND S~BUDAT  IN @S_BUDAT
     AND S~ZTIGYPE = @GC_A    "추가(SJM 25.03.25)
    INTO CORRESPONDING FIELDS OF TABLE @GT_HGOD.

  IF GT_HGOD[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HGOD BY MJAHR MBLNR.

  GV_CNT = LINES( GT_HGOD ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_APM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_APM_DATA.

  CLEAR : GT_HAPM[], GT_IAPX[].

  IF SY-UNAME = 'ZLSGMM3'.
    SELECT *
      FROM ZGTMM_CV_SCAPPLIST
      INTO CORRESPONDING FIELDS OF TABLE @GT_HAPM
     WHERE BUKRS        = @P_BUKRS
       AND WERKS        = @P_WERKS
       AND APPSTAT      = @SPACE
       AND ERDAT_LOCAL IN @S_BUDAT.
  ELSE.
    SELECT *
      FROM ZGTMM_CV_SCAPPLIST
      INTO CORRESPONDING FIELDS OF TABLE @GT_HAPM
     WHERE BUKRS        = @P_BUKRS
       AND WERKS        = @P_WERKS
       AND APPSTAT      = @SPACE
       AND ERDAT_LOCAL IN @S_BUDAT
       AND ( APPROVER1 = @SY-UNAME
          OR APPROVER2 = @SY-UNAME ).
  ENDIF.

  IF GT_HAPM[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HAPM BY ZGUID.

  GV_CNT = LINES( GT_HAPM ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_APD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_APD_DATA.

  CLEAR : GT_HAPD[], GT_IAPX[].

  IF SY-UNAME = 'ZLSGMM3'.
    "품의상태 Icon 기준 세분화(SJM 25.03.12)
*   SELECT CASE WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO <> ' ' THEN @ICON_LED_GREEN
*               WHEN APPSTAT = 'A' AND MBLNR  = ' '                  THEN @ICON_LED_YELLOW
*               WHEN APPSTAT = 'A' AND IV_NO  = ' '                  THEN @ICON_LED_YELLOW
*               WHEN APPSTAT = 'R'                                   THEN @ICON_LED_RED
    SELECT CASE WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO <> ' ' THEN @ICON_WS_TRUCK "통문증출력
                WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO  = ' ' THEN @ICON_STOCK    "출고
                WHEN APPSTAT = 'A' AND MBLNR  = ' '                  THEN @ICON_ALLOW    "승인
                WHEN APPSTAT = 'R'                                   THEN @ICON_REJECT   "반려
                WHEN APPSTAT = ' '                                   THEN @ICON_MAIL     "상신 중
            END AS STATUS,
           D~*
      FROM ZGTMM_CV_SCAPPLIST AS D
      INTO CORRESPONDING FIELDS OF TABLE @GT_HAPD
     WHERE ZGITYPE      = @GC_A     "추가(SJM 25.03.25)
       AND BUKRS        = @P_BUKRS
       AND WERKS        = @P_WERKS
       AND LGORT        = @P_LGORT
       AND LIFNR       IN @S_LIFNR
       AND ERDAT_LOCAL IN @S_BUDAT.
*       AND ernam        = @sy-uname.
  ELSE.
    "품의상태 Icon 기준 세분화(SJM 25.03.12)
*   SELECT CASE WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO <> ' ' THEN @ICON_LED_GREEN
*               WHEN APPSTAT = 'A' AND MBLNR  = ' '                  THEN @ICON_LED_YELLOW
*               WHEN APPSTAT = 'A' AND IV_NO  = ' '                  THEN @ICON_LED_YELLOW
*               WHEN APPSTAT = 'R'                                   THEN @ICON_LED_RED
    SELECT CASE WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO <> ' ' THEN @ICON_WS_TRUCK "통문증출력
                WHEN APPSTAT = 'A' AND MBLNR <> ' ' AND IV_NO  = ' ' THEN @ICON_STOCK    "출고
                WHEN APPSTAT = 'A' AND MBLNR  = ' '                  THEN @ICON_ALLOW    "승인
                WHEN APPSTAT = 'R'                                   THEN @ICON_REJECT   "반려
                WHEN APPSTAT = ' '                                   THEN @ICON_MAIL     "상신 중
            END AS STATUS,
           D~*
      FROM ZGTMM_CV_SCAPPLIST AS D
      INTO CORRESPONDING FIELDS OF TABLE @GT_HAPD
     WHERE ZGITYPE      = @GC_A     "추가(SJM 25.03.25)
       AND BUKRS        = @P_BUKRS
       AND WERKS        = @P_WERKS
       AND LGORT        = @P_LGORT
       AND LIFNR       IN @S_LIFNR
       AND ERDAT_LOCAL IN @S_BUDAT
       AND ERNAM        = @SY-UNAME.
  ENDIF.

  IF GT_HAPD[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HAPD BY ZGUID.

  GV_CNT = LINES( GT_HAPD ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  CLEAR : GT_EXCD[], GV_TITLE.

  IF SY-DYNNR+1(1) = GC_5.
    CASE GV_PRXX.
      WHEN 'MGI'
        OR 'MOD'. "추가(SJM 25.06.11)
        GV_TITLE = '출고 사유 등록 및 품의'(T01).
        GT_EXCD[] = VALUE #( ( 'YPRX' )
                             ( 'NPRX' )
                             ( 'RJPR' ) ).
      WHEN 'REJ'.
        GV_TITLE = '반려 처리'(T02).
        GT_EXCD[] = VALUE #( ( 'YPRX' )
                             ( 'NPRX' )
                             ( 'GIAR' ) ).
      WHEN OTHERS.
        GV_TITLE = '확인'(T03).
        GT_EXCD[] = VALUE #( ( 'GIAR' )
                             ( 'RJPR' )
                             ( 'CCXX' ) ).
    ENDCASE.

    EXIT.
  ENDIF.

  CASE 'X'.
    WHEN P_GOP.
      GV_TITLE = SY-TITLE && ` - ` && TEXT-R01.
      PERFORM SET_PRGI.

      "출고처리 / 통문증발급 / 보증보험 / [사급Risk 정보 조회]
      GT_EXCD[] = VALUE #( ( 'CCAP' )
                           ( 'DRSK' )
                           ( 'CCGO' )
                           ( 'CCGI' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

    WHEN P_GOD.
      GV_TITLE = SY-TITLE && ` - ` && TEXT-R02.
      PERFORM SET_PRGI. "추가(SJM 25.06.11)

      "통문증발급 / 통문증취소 / 출고취소
      GT_EXCD[] = VALUE #( ( 'CCAP' )
                           ( 'PRGI' )
*                          ( 'ISGO' )
                           ( 'TGIH' )
                           ( 'DRSK' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

    WHEN P_APM.
      GV_TITLE = SY-TITLE && ` - ` && TEXT-R03.

      "승인 / 반려
      GT_EXCD[] = VALUE #( ( 'CCAP' )
                           ( 'PRGI' )
                           ( 'ISGO' )
                           ( 'TGIH' )
                           ( 'DRSK' )
                           ( 'CCGO' )
                           ( 'CCGI' ) ).

    WHEN P_APD.
      GV_TITLE = SY-TITLE && ` - ` && TEXT-R04.
      PERFORM SET_PRGI.

      "상신/확정취소 / 출고처리 / 통문증발급
      GT_EXCD[] = VALUE #( ( 'TGIH' )
                           ( 'DRSK' )
                           ( 'CCGO' )
                           ( 'CCGI' )
                           ( 'APPV' )
                           ( 'REJT' ) ).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PRGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PRGI.

  CLEAR : GV_ZMODE, GV_PRGI.

  SELECT SINGLE ZMODE
    FROM ZGTMMT4100 INTO GV_ZMODE
  WHERE BUKRS = P_BUKRS
    AND WERKS = P_WERKS
    AND LGORT = P_LGORT.

  CASE GV_ZMODE.
    WHEN 'OD'.
      GV_PRGI = '출하지시'(B01).
    WHEN 'GI'.
      GV_PRGI = '출고처리'(B02).
  ENDCASE.

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

  DATA : LV_SIDE TYPE I,
         LV_EXTN TYPE I.


  CASE SY-DYNNR.
    WHEN '0100'.
      LV_SIDE = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM.
      LV_EXTN = 290.
    WHEN '0110'.
      LV_SIDE = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP.
      LV_EXTN = 655.
  ENDCASE.

  CASE SY-DYNNR.
    WHEN '0100' OR '0110'.
      GR_HDOCK = NEW #( REPID     = SY-REPID
                        DYNNR     = SY-DYNNR
                        SIDE      = LV_SIDE
                        EXTENSION = LV_EXTN ).

      GR_SPLIT = NEW #( PARENT  = GR_HDOCK
                        ROWS    = 2
                        COLUMNS = 1 ).

      "#1 Row
      GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW       = 1
                                          COLUMN    = 1 ).

      GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                        I_APPL_EVENTS = GC_X ).

      GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                                HEIGHT = 50 ).

*     GR_SPLIT->SET_COLUMN_WIDTH( ID    = 1
*                                 WIDTH = 60 ).

      "#2 Row
      GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW       = 2
                                          COLUMN    = 1 ).

      GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
                        I_APPL_EVENTS = GC_X ).

    WHEN '0200'.
      GR_PCUST = NEW #( CONTAINER_NAME = 'CC_0200' ).

      GR_PGRID = NEW #( I_PARENT      = GR_PCUST
                        I_APPL_EVENTS = GC_X ).

    WHEN '0400'.
      PERFORM SET_COM_DOCK USING GR_MDOCK
                                 GR_MGRID.

    WHEN '0600'.
      PERFORM SET_COM_DOCK USING GR_TDOCK
                                 GR_TGRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COM_DOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_MDOCK
*&      --> GR_MGRID
*&---------------------------------------------------------------------*
FORM SET_COM_DOCK USING PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER
                   PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  PR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  PR_GRID = NEW #( I_PARENT      = PR_DOCK
                   I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEXCL
*&---------------------------------------------------------------------*
FORM SET_EXCL TABLES PT_EXCL TYPE UI_FUNCTIONS.
*              USING PV_TYPE.

  CLEAR : PT_EXCL[].

  CASE SY-DYNNR.
    WHEN '0110'.
      PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL  ) ).

    WHEN OTHERS.
      PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                           ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                           ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

  ENDCASE.

* CASE PV_TYPE.
*   WHEN 'H'.
*
*
*   WHEN 'I'.
*     PT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL  ) ).
*
* ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO
                    PV_TYPE.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.

  CASE PV_TYPE.
    WHEN 'H'.
      CASE 'X'.
        WHEN P_GOP.
          PS_LAYO-GRID_TITLE = '불출대상'(T04).
          PS_LAYO-STYLEFNAME = GC_STYLE.
          PS_LAYO-CTAB_FNAME = GC_COLOR.

        WHEN P_GOD.
          PS_LAYO-GRID_TITLE = '출고리스트'(T05).

        WHEN P_APM.
          PS_LAYO-GRID_TITLE = '외주 초과 업체 List'(T06).

        WHEN P_APD.
          PS_LAYO-GRID_TITLE = '품의 현황 List'(T07).

      ENDCASE.

    WHEN 'I'.
      CASE 'X'.
        WHEN P_GOP.
          PS_LAYO-GRID_TITLE = '소요자재 Detail'(T08).

        WHEN P_GOD.

        WHEN P_APM.
          PS_LAYO-GRID_TITLE = '불출대상'(T04).

        WHEN P_APD.
          PS_LAYO-GRID_TITLE = '투입자재총량'(T09).

      ENDCASE.

    WHEN 'P'.
      PS_LAYO-CTAB_FNAME = GC_COLOR.
      PS_LAYO-SMALLTITLE = SPACE.

    WHEN 'M' OR 'T'.
      PS_LAYO-SMALLTITLE = SPACE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.


  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE 'X'.
        WHEN P_GOP.
          SET HANDLER GR_EVENTS->HANDLE_TOOLBAR       FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND  FOR PR_GRID.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

          PERFORM SET_EVNT_EDIT USING PR_GRID.

        WHEN P_GOD.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

        WHEN P_APM.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

        WHEN P_APD.
          SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

      ENDCASE.

    WHEN 'GR_IGRID'.


    WHEN 'GR_PGRID'.
      PERFORM SET_EVNT_EDIT USING PR_GRID.

    WHEN 'GR_MGRID'.
      SET HANDLER GR_EVENTS->HANDLE_TOOLBAR       FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND  FOR PR_GRID.

      PERFORM SET_EVNT_EDIT USING PR_GRID.

    WHEN 'GR_TGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT_EDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT_EDIT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR PR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR PR_GRID.

  CALL METHOD PR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TTIP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TTIP.

  "품의상태 Icon 기준 세분화(SJM 25.03.12)

  CLEAR : GT_TTIP[].

  CHECK P_APD = GC_X.

  _SET_TTIP 'STATUS' ICON_WS_TRUCK '통문증출력'(I01).
  _SET_TTIP 'STATUS' ICON_STOCK    '출고'(I02).
  _SET_TTIP 'STATUS' ICON_ALLOW    '승인'(I03).
  _SET_TTIP 'STATUS' ICON_REJECT   '반려'(I04).
  _SET_TTIP 'STATUS' ICON_MAIL     '상신 중'(I05).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP
*&      --> GT_IGOP
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_HLIST
                          PT_ILIST.

  PERFORM SET_FCAT TABLES GT_HFCAT
                    USING 'H'.
  PERFORM SET_DISP TABLES GT_HEXCL
                          GT_HFCAT
                          PT_HLIST
                    USING GR_HGRID
                          GS_HLAYO 'H'.

  PERFORM SET_FCAT TABLES GT_IFCAT
                    USING 'I'.
  PERFORM SET_DISP TABLES GT_IEXCL
                          GT_IFCAT
                          PT_ILIST
                    USING GR_IGRID
                          GS_ILAYO 'I'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PV_TYPE.

  CLEAR : PT_FCAT[], GT_FCAT[].

  CASE PV_TYPE.
    WHEN 'H'.
      PERFORM SET_HLIST_FCAT.
    WHEN 'I'.
      PERFORM SET_ILIST_FCAT.
    WHEN 'P'.
      PERFORM SET_PLIST_FCAT.
    WHEN 'M'.
      PERFORM SET_MLIST_FCAT.
    WHEN 'T'.
      PERFORM SET_CLIST_FCAT TABLES  GT_TGIH
                              USING 'GT_TGIH'.
  ENDCASE.

  PT_FCAT[] = GT_FCAT[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM MAKE_FCAT USING PV_GUBUN
                     PV_FNAME
                     PV_FVAL.

  DATA : LV_FNAME(40).
  FIELD-SYMBOLS : <LFS_FVAL>.


  IF PV_GUBUN = GC_S.
    CLEAR : GS_FCAT.
  ENDIF.

  CONCATENATE 'GS_FCAT-' PV_FNAME INTO LV_FNAME.
  ASSIGN (LV_FNAME) TO <LFS_FVAL>.
  MOVE    PV_FVAL   TO <LFS_FVAL>.

  CHECK PV_GUBUN = GC_E.
  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HLIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HLIST_FCAT.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM SET_HGOP_FCAT.

    WHEN P_GOD.
      PERFORM SET_HGOD_FCAT.

    WHEN P_APM.
      PERFORM SET_HAPM_FCAT.

    WHEN P_APD.
      PERFORM SET_HAPD_FCAT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ILIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ILIST_FCAT.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM SET_IGOP_FCAT.

    WHEN P_GOD.
      PERFORM SET_IGOD_FCAT.

    WHEN P_APM OR P_APD.
      PERFORM SET_IAPX_FCAT.

*   WHEN P_APD.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PLIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PLIST_FCAT.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM SET_BGOP_FCAT.

    WHEN P_GOD.

    WHEN P_APM.

    WHEN P_APD.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MLIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MLIST_FCAT.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM SET_MGOP_FCAT.

    WHEN P_GOD.

    WHEN P_APM.

    WHEN P_APD.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CLIST_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_TGIH
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_CLIST_FCAT TABLES PT_LIST
                     USING PV_TNAME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNAME
*     I_STRUCTURE_NAME   =
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
      IT_DATA         = PT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT GT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE PV_TNAME.
      WHEN 'GT_TGIH'.
        PERFORM SET_TGIH_FCAT.

    ENDCASE.

    MODIFY GT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HGOP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HGOP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01), "회사명(F02)

          'S' 'FIELDNAME'  'EKORG',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '구매조직'(F03),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04), "'플랜트명'(F05)

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '공급업체'(F07), "'업체명'(F08)

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재코드'(F09),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재명'(F10),

          'S' 'FIELDNAME'  'XCHPF',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          ' ' 'CHECKBOX'   'X',
          'E' 'COLTEXT'    '배치관리'(F11),

          'S' 'FIELDNAME'  'REQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '총소요량'(F12),

          'S' 'FIELDNAME'  'SCQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '외주재고량'(F13),

          'S' 'FIELDNAME'  'NEQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '필요량'(F14),

          'S' 'FIELDNAME'  'SLQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '창고재고량'(F15),

          'S' 'FIELDNAME'  'ISQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'REF_FIELD'  'MENGE',
          ' ' 'REF_TABLE'  'MSEG',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '출하지시량'(F16),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출하지시금액'(F18),

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고액'(F19),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '연도'(F21),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'MBLNR',
*         ' ' 'REF_TABLE'  'MATDOC',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '자재문서번호'(F22),

          'S' 'FIELDNAME'  'IV_NO',
          ' ' 'OUTPUTLEN'  10,
*         ' ' 'EMPHASIZE'  'C500',
          'E' 'COLTEXT'    '통문번호'(F23),

          'S' 'FIELDNAME'  'PRICE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '평가가격'(F24),

          'S' 'FIELDNAME'  'PEINH',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '가격단위'(F25).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HGOD_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HGOD_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '연도'(F21),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          ' ' 'HOTSPOT'    'X',
          'E' 'COLTEXT'    '자재문서번호'(F22),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '외주공급업체'(F26),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '공급업체명'(F27),

          'S' 'FIELDNAME'  'IV_NO',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '통문번호'(F23),

          'S' 'FIELDNAME'  'BUDAT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '전기일'(F28),

          'S' 'FIELDNAME'  'CPUDT',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '입력일'(F29),

          'S' 'FIELDNAME'  'CPUTM',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '입력시간'(F30),

          'S' 'FIELDNAME'  'USNAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '입력자'(F31),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '총출고액'(F32),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20),

          'S' 'FIELDNAME'  'BKTXT',
          ' ' 'OUTPUTLEN'  25,
          'E' 'COLTEXT'    '비고'(F33).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HAPM_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HAPM_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'GUID'(F34),

          'S' 'FIELDNAME'  'ZGITYPE',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '초과불출유형'(F35),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'ERDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '요청일'(F36),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'LGOBE',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '저장위치명'(F37),

          'S' 'FIELDNAME'  'ERNAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '요청자'(F38),

          'S' 'FIELDNAME'  'REQNAME',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '요청자명'(F39),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '업체'(F26),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F08),

          'S' 'FIELDNAME'  'PREIS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '보증금액'(F40),

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고액'(F19),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '출고예정액'(F41),

          'S' 'FIELDNAME'  'REVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출고가용액'(F42),

          'S' 'FIELDNAME'  'IVVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '당월외상매입금액'(F43),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20),

          'S' 'FIELDNAME'  'ORES',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '초과사유'(F44),

          'S' 'FIELDNAME'  'OREST',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '사유명'(F45),

          'S' 'FIELDNAME'  'OETC',
          ' ' 'OUTPUTLEN'  100,
          'E' 'COLTEXT'    '비고'(F33),

          'S' 'FIELDNAME'  'APPSTAT',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인상태'(F46),

          'S' 'FIELDNAME'  'REJRES',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '반려사유'(F47),

          'S' 'FIELDNAME'  'REJREST',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '반려사유명'(F48),

          'S' 'FIELDNAME'  'RETC',
          ' ' 'OUTPUTLEN'  100,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '비고(반려)'(F49),

          'S' 'FIELDNAME'  'ERDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청일'(F36),

          'S' 'FIELDNAME'  'ERTIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청시간'(F50),

          'S' 'FIELDNAME'  'ERTIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청시간'(F50),

          'S' 'FIELDNAME'  'AEDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)일'(F51),

          'S' 'FIELDNAME'  'AEDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)일'(F51),

          'S' 'FIELDNAME'  'AETIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)시간'(F52),

          'S' 'FIELDNAME'  'AETIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)시간'(F52),

          'S' 'FIELDNAME'  'AENAM',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)자'(F53),

          'S' 'FIELDNAME'  'APPNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)자명'(F54).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HAPD_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HAPD_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'GUID'(F34),

          'S' 'FIELDNAME'  'ZGITYPE',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '초과불출유형'(F35),

          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          ' ' 'KEY'        'X',
          ' ' 'ICON'       'X', "추가(SJM 25.03.12)
          'E' 'COLTEXT'    '상태'(F45),

          'S' 'FIELDNAME'  'ERDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '요청일'(F36),

          'S' 'FIELDNAME'  'AEDAT_LOCAL',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '승인(반려)일'(F51),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'LGOBE',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '저장위치명'(F37),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '업체'(F26),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          'E' 'COLTEXT'    '업체명'(F08),

          'S' 'FIELDNAME'  'PREIS',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '보증금액'(F40),

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고액'(F19),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '출고예정액'(F41),

          'S' 'FIELDNAME'  'REVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출고가용액'(F42),

          'S' 'FIELDNAME'  'IVVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '당월외상매입금액'(F43),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20),

          'S' 'FIELDNAME'  'ORES',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '초과사유'(F44),

          'S' 'FIELDNAME'  'OREST',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '사유명'(F45),

          'S' 'FIELDNAME'  'OETC',
          ' ' 'OUTPUTLEN'  100,
          'E' 'COLTEXT'    '비고'(F33),

          'S' 'FIELDNAME'  'REJRES',
          ' ' 'OUTPUTLEN'  6,
          'E' 'COLTEXT'    '반려사유'(F47),

          'S' 'FIELDNAME'  'REJREST',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '반려사유명'(F48),

          'S' 'FIELDNAME'  'RETC',
          ' ' 'OUTPUTLEN'  100,
          'E' 'COLTEXT'    '비고(반려)'(F49),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '연도'(F21),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '자재문서번호'(F22),

          'S' 'FIELDNAME'  'IV_NO',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '통문번호'(F23),

          'S' 'FIELDNAME'  'APPSTAT',
          ' ' 'OUTPUTLEN'  6,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인상태'(F46),

          'S' 'FIELDNAME'  'ERDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청일'(F36),

          'S' 'FIELDNAME'  'ERTIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청시간'(F50),

          'S' 'FIELDNAME'  'ERTIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '요청시간'(F50),

          'S' 'FIELDNAME'  'ERNAM',
          ' ' 'OUTPUTLEN'  12,
          'E' 'COLTEXT'    '요청자'(F38),

          'S' 'FIELDNAME'  'AEDAT',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)일'(F51),

          'S' 'FIELDNAME'  'AETIM',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)시간'(F52),

          'S' 'FIELDNAME'  'AETIM_LOCAL',
          ' ' 'OUTPUTLEN'  8,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)시간'(F52),

          'S' 'FIELDNAME'  'AENAM',
          ' ' 'OUTPUTLEN'  12,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '승인(반려)자'(F53).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IGOP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IGOP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'BUTXT',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사명'(F02),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'NAME1',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트명'(F05),

          'S' 'FIELDNAME'  'ISSUESL',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체'(F26),

          'S' 'FIELDNAME'  'BPNAME',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '업체명'(F08),

          'S' 'FIELDNAME'  'MTART',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재유형'(F55),

          'S' 'FIELDNAME'  'EBELN',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'CONVEXIT'   'ALPHA',
*         ' ' 'REF_FIELD'  'EBELN',
*         ' ' 'REF_TABLE'  'EKPO',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'PO번호'(F56),

          'S' 'FIELDNAME'  'EBELP',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F57),

          'S' 'FIELDNAME'  'RSNUM',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '예약번호'(F58),

          'S' 'FIELDNAME'  'RSPOS',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F57),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '외주가공품'(F59),

          'S' 'FIELDNAME'  'TXZ01',
          ' ' 'OUTPUTLEN'  30,
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '외주가공품명'(F60),

          'S' 'FIELDNAME'  'BATCHYN',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
*         ' ' 'KEY'        'X',
*         ' ' 'CHECKBOX'   'X',
          'E' 'COLTEXT'    '배치관리'(F11),

          'S' 'FIELDNAME'  'MENGE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '가공수량'(F61),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'CMATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '투입자재코드'(F62),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
*         ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '투입자재명'(F63),

          'S' 'FIELDNAME'  'BDMNG',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'CMEINS',
          'E' 'COLTEXT'    '소요량'(F64),

          'S' 'FIELDNAME'  'CMEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'LGPRO',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '생산저장위치'(F65),

          'S' 'FIELDNAME'  'LGFSB',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '외주저장위치'(F66),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '통화'(F20).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IGOD_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IGOD_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'BUKRS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '회사코드'(F01),

          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'LIFNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '외주공급업체'(F26),

          'S' 'FIELDNAME'  'MJAHR',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'KEY'        'X',
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '연도'(F21),

          'S' 'FIELDNAME'  'MBLNR',
          ' ' 'CONVEXIT'   'ALPHA',
          ' ' 'OUTPUTLEN'  10,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재문서번호'(F22),

          'S' 'FIELDNAME'  'ZEILE',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '항번'(F57),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          'E' 'COLTEXT'    '투입자재코드'(F62),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '투입자재명'(F63),

          'S' 'FIELDNAME'  'CHARG',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '배치번호'(F67),

          'S' 'FIELDNAME'  'MENGE',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '출고수량'(F68),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '출고금액'(F69),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IAPX_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IAPX_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'ZGUID',
          ' ' 'OUTPUTLEN'  32,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    'GUID'(F34),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재코드'(F09),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재명'(F10),

          'S' 'FIELDNAME'  'XCHPF',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'KEY'        'X',
          ' ' 'CHECKBOX'   'X',
          'E' 'COLTEXT'    '배치관리'(F11),

          'S' 'FIELDNAME'  'REQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '총소요량'(F12),

          'S' 'FIELDNAME'  'SCQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '외주재고량'(F13),

          'S' 'FIELDNAME'  'NEQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '필요량'(F14),

          'S' 'FIELDNAME'  'SLQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '창고재고량'(F15),

          'S' 'FIELDNAME'  'ISQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'REF_FIELD'  'MENGE',
          ' ' 'REF_TABLE'  'MSEG',
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '출하지시량'(F16),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'ISVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
*         ' ' 'HOTSPOT'    'X',
          ' ' 'EMPHASIZE'  'C300',
          'E' 'COLTEXT'    '출하지시금액'(F18),

          'S' 'FIELDNAME'  'SCVAL',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'CFIELDNAME' 'WAERS',
          'E' 'COLTEXT'    '외주재고액'(F19),

          'S' 'FIELDNAME'  'WAERS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '통화'(F20).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BGOP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BGOP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'WERKS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '플랜트'(F04),

          'S' 'FIELDNAME'  'LGORT',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '저장위치'(F06),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
*         ' ' 'REF_FIELD'  'MATNR',
*         ' ' 'REF_TABLE'  'MARA',
          ' ' 'NO_OUT'     'X',
          ' ' 'KEY'        'X',
          'E' 'COLTEXT'    '자재코드'(F09),

          'S' 'FIELDNAME'  'UNQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '가용재고 수량'(F70),

          'S' 'FIELDNAME'  'QIQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '검사중 수량'(F71),

          'S' 'FIELDNAME'  'BLQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '불용 수량'(F72),

          'S' 'FIELDNAME'  'CHARG',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '배치번호'(F67),

          'S' 'FIELDNAME'  'XPCBT',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단일배치'(F73), "추가(SJM 25.02.27)

          'S' 'FIELDNAME'  'TAGNR',
          ' ' 'OUTPUTLEN'  17,
          'E' 'COLTEXT'    '꼬리표'(F74),

          'S' 'FIELDNAME'  'ISQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'REF_FIELD'  'MENGE',
          ' ' 'REF_TABLE'  'MSEG',
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'EDIT'       'X',
          'E' 'COLTEXT'    '불출수량'(F75),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MGOP_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MGOP_FCAT.

  PERFORM MAKE_FCAT USING :
          'S' 'FIELDNAME'  'STATUS',
          ' ' 'OUTPUTLEN'  4,
          ' ' 'JUST'       'C',
          'E' 'COLTEXT'    '상태'(F45),

          'S' 'FIELDNAME'  'MATNR',
          ' ' 'OUTPUTLEN'  20,
          ' ' 'CONVEXIT'   'MATN1',
          'E' 'COLTEXT'    '자재코드'(F09),

          'S' 'FIELDNAME'  'MAKTX',
          ' ' 'OUTPUTLEN'  30,
          'E' 'COLTEXT'    '자재명'(F10),

          'S' 'FIELDNAME'  'CHARG',
          ' ' 'OUTPUTLEN'  10,
          'E' 'COLTEXT'    '배치번호'(F67),

          'S' 'FIELDNAME'  'XPCBT',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단일배치'(F73), "추가(SJM 25.02.27)

          'S' 'FIELDNAME'  'SLQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'QFIELDNAME' 'MEINS',
          'E' 'COLTEXT'    '재고수량'(F76),

          'S' 'FIELDNAME'  'ISQTY',
          ' ' 'OUTPUTLEN'  21,
          ' ' 'REF_FIELD'  'MENGE',
          ' ' 'REF_TABLE'  'MSEG',
          ' ' 'QFIELDNAME' 'MEINS',
          ' ' 'EDIT'       'X',
          'E' 'COLTEXT'    '불출수량'(F75),

          'S' 'FIELDNAME'  'MEINS',
          ' ' 'OUTPUTLEN'  5,
          'E' 'COLTEXT'    '단위'(F17),

          'S' 'FIELDNAME'  'MEINS_T',
          ' ' 'OUTPUTLEN'  5,
          ' ' 'NO_OUT'     'X',
          'E' 'COLTEXT'    '재고단위'(F77),

          'S' 'FIELDNAME'  'ETC',
          ' ' 'OUTPUTLEN'  100,
          'E' 'COLTEXT'    '비고'(F33).

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
*& Form SET_TGIH_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TGIH_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F04).
      GS_FCAT-KEY = GC_X.
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F06). "창고
      GS_FCAT-KEY = GC_X.
    WHEN 'MJAHR'.
      PERFORM SET_FTXT USING '연도'(F21).
      GS_FCAT-KEY = GC_X.
    WHEN 'MBLNR'.
      PERFORM SET_FTXT USING '자재문서번호'(F22). "자재문서
      GS_FCAT-KEY = GC_X.
    WHEN 'BUDAT'.
      PERFORM SET_FTXT USING '전기일'(F28).
      GS_FCAT-KEY = GC_X.
    WHEN 'CPUDT'.
      PERFORM SET_FTXT USING '입력일'(F29).
    WHEN 'USNAM'.
      PERFORM SET_FTXT USING '불출담당'(F78).
    WHEN 'ISVAL'.
      PERFORM SET_FTXT USING '불출액(자재문서)'(F79).
    WHEN 'WAERS'.
      PERFORM SET_FTXT USING '통화'(F20).
    WHEN 'ORES'.
      PERFORM SET_FTXT USING '초과불출사유'(F80).
      GS_FCAT-NO_OUT = GC_X. "추가(SJM 25.02.27)
    WHEN 'ORESNAME'.
      PERFORM SET_FTXT USING '사유명'(F45).
    WHEN 'OETC'.             "추가(SJM 25.02.27)
      PERFORM SET_FTXT USING '비고'(F33).
    WHEN 'PREIS'.
      PERFORM SET_FTXT USING '보증보험금액'(F81).
    WHEN 'SCVAL'.
      PERFORM SET_FTXT USING '외주재고액'(F19).
    WHEN 'ISVALUE'.
      PERFORM SET_FTXT USING '불출액'(F82).
    WHEN 'REVAL'.
      PERFORM SET_FTXT USING '출고가용액'(F42).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HEXCL
*&      --> GT_HFCAT
*&      --> PT_HLIST
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_EXCL TYPE UI_FUNCTIONS
                     PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO
                     PV_TYPE.

  CLEAR : GS_VARI.
  CASE PV_TYPE.
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.

  ENDCASE.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = PT_EXCL[]
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
      IT_EXCEPT_QINFO      = GT_TTIP[] "추가(SJM 25.03.12)
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PS_LAYO TYPE LVC_S_LAYO.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = PS_LAYO.

  CALL METHOD PR_GRID->REFRESH_TABLE_DISPLAY
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
      PERFORM FREE_CNTR USING GR_HGRID GR_HCNTR.
      PERFORM FREE_CNTR USING GR_IGRID GR_ICNTR.

      CALL METHOD GR_HDOCK->FREE.
      CLEAR : GR_HDOCK.

      PERFORM FREE_CUST USING GR_PGRID GR_PCUST.

      PERFORM FREE_DOCK USING GR_MGRID GR_MDOCK.
      PERFORM FREE_DOCK USING GR_TGRID GR_TDOCK.

    WHEN '0200'.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_CNTR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GR_HCNTR
*&---------------------------------------------------------------------*
FORM FREE_CNTR USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PR_CNTR TYPE REF TO CL_GUI_CONTAINER.

  CHECK PR_CNTR IS BOUND.

  CALL METHOD PR_GRID->FREE.
  CALL METHOD PR_CNTR->FREE.

  CLEAR : PR_GRID, PR_CNTR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_CUST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_PGRID
*&      --> GR_PCUST
*&---------------------------------------------------------------------*
FORM FREE_CUST USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PR_CUST TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

  CHECK PR_CUST IS BOUND.

  CALL METHOD PR_GRID->FREE.
  CALL METHOD PR_CUST->FREE.

  CLEAR : PR_GRID, PR_CUST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_DOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_MGRID
*&      --> GR_MDOCK
*&---------------------------------------------------------------------*
FORM FREE_DOCK USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER.

  CHECK PR_DOCK IS BOUND.

  CALL METHOD PR_GRID->FREE.
  CALL METHOD PR_DOCK->FREE.

  CLEAR : PR_GRID, PR_DOCK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REFR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REFR.

  PERFORM GET_DATA.

  GV_REF = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          PV_OTEXT.

  DATA : LS_TBAR TYPE STB_BUTTON.


  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.
    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION  = &2.
    LS_TBAR-ICON      = &3.
    LS_TBAR-TEXT      = &4.
    LS_TBAR-QUICKINFO = &4.
*   LS_TBAR-CHECKED   = 'X'.
*   LS_TBAR-DISABLED  = 'X'.
    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 '  ' '  ' '  '.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE 'X'.
        WHEN P_GOP.
          _SET_TBAR 0 'SDIS' ' ' '재고조회'(B03).
          _SET_TBAR 0 'FORM' ' ' '엑셀양식'(B04).
          _SET_TBAR 0 'MASI' ' ' '대량입력'(B05).
*         _SET_TBAR 0 'SNGI' ' ' '추가자재'(B04). "Hidden
        WHEN P_GOD.

        WHEN P_APM.

        WHEN P_APD.

      ENDCASE.

    WHEN 'GR_MGRID'.
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '삭제'(B06).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PV_UCOMM LIKE SY-UCOMM
                               PV_OTEXT.

  CLEAR : GV_REF.

  CASE PV_UCOMM.
    WHEN 'SDIS'. "재고조회
      PERFORM PRCS_SDIS.

    WHEN 'FORM'. "엑셀양식
      PERFORM DOWN_FORM.

    WHEN 'MASI'. "대량입력
      PERFORM PRCS_MASI.

    WHEN 'SNGI'. "추가자재
      "BOM 전체를 보여주기 때문에 해당 기능은 추후 검토
*     PERFORM SNGI_DATA.

    WHEN 'DELE'. "삭제
      PERFORM DELE_LINE.

  ENDCASE.

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
    WHEN 'GR_HGRID'.
      PERFORM READ_LIST_BY_INDEX USING PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'REQTY'.
          PERFORM GET_IGOP_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

        WHEN 'MBLNR'.
          CASE 'X'.
            WHEN P_GOP.
              PERFORM CALL_MIGO USING GT_HGOP-MBLNR
                                      GT_HGOP-MJAHR.
            WHEN P_GOD.
              PERFORM GET_IGOD_DATA.
              PERFORM REFRESH_GRID USING GR_IGRID
                                         GS_ILAYO.
          ENDCASE.

        WHEN 'ISVAL'.
          PERFORM GET_IAPX_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_LIST_BY_INDEX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROW_INDEX
*&---------------------------------------------------------------------*
FORM READ_LIST_BY_INDEX USING PV_INDEX.

  CASE 'X'.
    WHEN P_GOP.
      READ TABLE GT_HGOP INDEX PV_INDEX.
    WHEN P_GOD.
      READ TABLE GT_HGOD INDEX PV_INDEX.
    WHEN P_APM.
      READ TABLE GT_HAPM INDEX PV_INDEX.
    WHEN P_APD.
      READ TABLE GT_HAPD INDEX PV_INDEX.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IGOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IGOP_DATA.

  CLEAR : GT_IGOP[], GV_CNT.

  SELECT * FROM ZGTMM_CV_SCREQLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_IGOP
   WHERE BUKRS   = @P_BUKRS
     AND WERKS   = @P_WERKS
     AND ISSUESL = @P_LGORT
     AND LIFNR  IN @S_LIFNR
     AND ELIKZ   = @SPACE
     AND CMATNR  = @GT_HGOP-MATNR.

  IF GT_IGOP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_IGOP BY EBELN EBELP.

  GV_CNT = LINES( GT_IGOP ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MIGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP_MBLNR
*&      --> GT_HGOP_MJAHR
*&---------------------------------------------------------------------*
FORM CALL_MIGO USING PV_MBLNR
                     PV_MJAHR.

  CHECK PV_MBLNR IS NOT INITIAL.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
*     I_ACTION            = 'A04'
*     I_REFDOC            = 'R02'
*     I_NOTREE            = 'X'
*     I_NO_AUTH_CHECK     =
*     I_SKIP_FIRST_SCREEN = 'X'
*     I_DEADEND           = 'X'
*     I_OKCODE            = 'OK_GO'
*     I_LEAVE_AFTER_POST  =
*     I_NEW_ROLLAREA      = 'X'
*     I_SYTCODE           =
*     I_EBELN             =
*     I_EBELP             =
      I_MBLNR             = PV_MBLNR
      I_MJAHR             = PV_MJAHR
*     I_ZEILE             =
*     I_TRANSPORT         =
*     I_ORDER_NUMBER      =
*     I_ORDER_ITEM        =
*     I_TRANSPORT_MEANS   =
*     I_TRANSPORTIDENT    =
*     I_INBOUND_DELIV     =
*     I_OUTBOUND_DELIV    =
*     I_RESERVATION_NUMB  =
*     I_RESERVATION_ITEM  =
*     EXT                 =
*     I_MOVE_TYPE         =
*     I_SPEC_STOCK        =
*     I_PSTNG_DATE        =
*     I_DOC_DATE          =
*     I_REF_DOC_NO        =
*     I_HEADER_TXT        =
    EXCEPTIONS
      ILLEGAL_COMBINATION = 1
      OTHERS              = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IGOD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IGOD_DATA.

  CLEAR : GT_IGOD[], GV_CNT.

  SELECT * FROM ZGTMM_CV_MVT541LIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_IGOD
   WHERE BUKRS = @GT_HGOD-BUKRS
     AND WERKS = @GT_HGOD-WERKS
     AND LGORT = @GT_HGOD-LGORT
     AND LIFNR = @GT_HGOD-LIFNR
     AND MJAHR = @GT_HGOD-MJAHR
     AND MBLNR = @GT_HGOD-MBLNR.

  IF GT_IGOD[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_IGOD BY ZEILE.

  GV_CNT = LINES( GT_IGOD ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IAPX_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IAPX_DATA.

  CLEAR : GT_IAPX[], GV_CNT.

  CASE 'X'.
    WHEN P_APM.
      DATA(LV_ZGUID) = GT_HAPM-ZGUID.
    WHEN P_APD.
      LV_ZGUID       = GT_HAPD-ZGUID.
  ENDCASE.

  SELECT * FROM ZGTMM_CV_SCAPPDETAIL
    INTO CORRESPONDING FIELDS OF TABLE @GT_IAPX
   WHERE ZGUID = @LV_ZGUID.

  IF GT_IAPX[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_IAPX BY MATNR.

  GV_CNT = LINES( GT_IAPX ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PV_OTEXT.

* LOOP AT PR_CHNG->MT_GOOD_CELLS INTO GS_MODI.
*   CASE GS_MODI-FIELDNAME.
*     WHEN 'LGORT'.
*       PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*     WHEN 'ZMODE'.
*       PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*   ENDCASE.
* ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODI
                                        PT_MODI TYPE LVC_T_MODI
                                        PV_OTEXT.

  CHECK PV_MODI IS NOT INITIAL.

  GT_MODI = PT_MODI.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      PERFORM CHNG_FNSH_HGRID.

    WHEN 'GR_IGRID'.

    WHEN 'GR_PGRID'.
      PERFORM CHNG_FNSH_PGRID.

    WHEN 'GR_MGRID'.
      PERFORM CHNG_FNSH_MGRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_HGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_HGRID.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM CHANGE_HGOP_DATA.

    WHEN P_GOD.

    WHEN P_APM.

    WHEN P_APD.

  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_PGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_PGRID.

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE GT_BGOP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_BGOP TO <GFS_COL>.

    CASE GS_MODI-FIELDNAME.
      WHEN 'ISQTY'.
        PERFORM CHANGE_ISQTY_B.

    ENDCASE.

    MODIFY GT_BGOP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_MGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_MGRID.

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE GT_MGOP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    CASE GS_MODI-FIELDNAME.
      WHEN 'ISQTY'.
        PERFORM CHANGE_ISQTY_M.

    ENDCASE.

    MODIFY GT_MGOP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_HGOP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_HGOP_DATA.

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE GT_HGOP INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE GT_HGOP TO <GFS_COL>.

    CASE GS_MODI-FIELDNAME.
      WHEN 'ISQTY'.
        PERFORM CHANGE_ISQTY_H USING 'X'.
*       PERFORM GET_GOP_HDR.

    ENDCASE.

    MODIFY GT_HGOP INDEX GS_MODI-ROW_ID.
  ENDLOOP.

  PERFORM GET_GOP_HDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ISQTY_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ISQTY_H USING PV_GOP.

  IF GT_HGOP-ISQTY > GT_HGOP-SLQTY. "출하지시량 > 창고재고량
    MESSAGE S019 DISPLAY LIKE 'E'. "창고 재고가 부족합니다.
    DATA(LV_ERR) = GC_X.
*   EXIT.
  ELSE.
    IF GT_HGOP-PEINH IS NOT INITIAL.
      GT_HGOP-ISVAL = GT_HGOP-ISQTY * GT_HGOP-PRICE / GT_HGOP-PEINH.
    ELSE.
      GT_HGOP-ISVAL = GT_HGOP-ISQTY * GT_HGOP-PRICE.
    ENDIF.
  ENDIF.

* PERFORM GET_GOP_HDR.

  CHECK PV_GOP = GC_X.

  IF LV_ERR = GC_X.
    PERFORM SET_ERR_COL USING 'ISQTY'.
    GT_HGOP-ERR = GC_X.
  ELSE.
    CLEAR : <GFS_COL>, GT_HGOP-ERR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ISQTY_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ISQTY_M.

  CLEAR : GT_MGOP-STATUS, GT_MGOP-ETC, GT_MGOP-ERR.

  PERFORM CHK_MGOP_SQTY.
  PERFORM SET_MGOP_STATUS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&      --> P_
*&      --> P_
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
*& Form PRCS_SDIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_SDIS.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '조회 대상 자재를 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  PERFORM CHECK_SDIS.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_BHDR.
  PERFORM SET_BITM.

  SORT GT_BGOP BY MATNR CHARG.

  CALL SCREEN 200 STARTING AT 10 5
                    ENDING AT 85 20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SDIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SDIS.

  READ TABLE GT_HGOP INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  IF GT_HGOP-XCHPF <> GC_X.
    MESSAGE S020 DISPLAY LIKE 'E'. "배치 미관리 자재는 직접 출하지시량을 입력하세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  "창고재고량이 없으면 메세지 처리(SJM 25.03.12)
  IF GT_HGOP-SLQTY IS INITIAL.
    MESSAGE S122 DISPLAY LIKE 'E'. "재고가 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

* PERFORM CHECK_MBLNR_EXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BHDR.

  CLEAR : GS_BHDR.

  MOVE-CORRESPONDING GT_HGOP TO GS_BHDR.

  PERFORM SET_WNAME USING GS_BHDR-WERKS
                 CHANGING GS_BHDR-NAME1.

  PERFORM SET_LGOBE USING GS_BHDR-WERKS
                          GS_BHDR-LGORT
                 CHANGING GS_BHDR-LGOBE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_BHDR_WERKS
*&      <-- GS_BHDR_NAME1
*&---------------------------------------------------------------------*
FORM SET_WNAME USING PV_WERKS
            CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_WERKS IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM T001W INTO PV_NAME1
   WHERE WERKS = PV_WERKS.
*    AND LOEVM = SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BITM.

  CLEAR : GT_BGOP[].

  "이미 값을 반영한 경우는 기반영 내용을 다시 불러옴..
  IF GT_HGOP-ISQTY IS NOT INITIAL
 AND GT_HGOP-TYPE  <> GC_M. "대량 입력건 구분자
    GT_BGOP[] = FILTER #( GT_BATS WHERE MATNR = GS_BHDR-MATNR ).
    EXIT.
  ENDIF.

  SELECT S~*
    FROM ZGTMM_CV_STOCKLIST AS S
    INTO CORRESPONDING FIELDS OF TABLE @GT_BGOP
   WHERE WERKS = @GS_BHDR-WERKS
     AND LGORT = @GS_BHDR-LGORT
     AND MATNR = @GS_BHDR-MATNR
     AND UNQTY > 0.

  IF GT_BGOP[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

* SORT GT_BGOP BY MATNR CHARG.

  PERFORM MODIFY_ISQTY_FR_BATS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ISQTY_FR_BATS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_ISQTY_FR_BATS.

  "대량 입력 후 재고조회시 전체 List에 입력된 불출수량 Update
  CHECK GT_HGOP-TYPE = GC_M.

  DATA(LT_BATS) = FILTER #( GT_BATS WHERE MATNR = GS_BHDR-MATNR ).

  LOOP AT LT_BATS INTO DATA(LS_BATS).
    DATA(LV_IDX) = LINE_INDEX( GT_BGOP[ MATNR = LS_BATS-MATNR
                                        CHARG = LS_BATS-CHARG ] ).

    CHECK LV_IDX > 0.
    GT_BGOP[ LV_IDX ]-ISQTY = LS_BATS-ISQTY.
  ENDLOOP.

* SORT GT_BGOP BY MATNR CHARG.
*
* LOOP AT GT_BATS INTO DATA(LS_BATS) GROUP BY ( MATNR = GS_BHDR-MATNR )
*                 INTO DATA(LT_BATS).
*
*   LOOP AT GROUP LT_BATS INTO DATA(WA_BATS).
*     READ TABLE GT_BGOP WITH KEY MATNR = WA_BATS-MATNR
*                                 CHARG = WA_BATS-CHARG
*                                 BINARY SEARCH.
*
*     CHECK SY-SUBRC = 0.
*     DATA(LV_TBX) = SY-TABIX.
*
*     GT_BGOP-ISQTY = WA_BATS-ISQTY.
*     MODIFY GT_BGOP INDEX LV_TBX TRANSPORTING ISQTY.
*   ENDLOOP.
* ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ISQTY_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ISQTY_B.

  "체크로직 추가(SJM 25.02.27)
  IF GT_BGOP-XPCBT = GC_X AND GT_BGOP-ISQTY > 0.
    IF GT_BGOP-ISQTY <> GT_BGOP-UNQTY  "불출수량 <> 가용재고수량
   AND GT_BGOP-ISQTY  < GT_BGOP-UNQTY.
      MESSAGE S119 DISPLAY LIKE 'E'. "단일 배치는 분할 출고 할 수 없습니다.
      CLEAR : GT_BGOP-ISQTY.
      CLEAR : <GFS_COL>, GT_BGOP-ERR.
      EXIT.
    ENDIF.
  ENDIF.

  IF GT_BGOP-ISQTY > GT_BGOP-UNQTY. "불출수량 > 가용재고수량
    MESSAGE S021 DISPLAY LIKE 'E'. "재고 수량을 확인하세요.

*   PERFORM SET_ERR_MSG USING 'ISQTY' 'V'.
    PERFORM SET_ERR_COL USING 'ISQTY'.
    GT_BGOP-ERR = GC_X.
  ELSE.
    CLEAR : <GFS_COL>, GT_BGOP-ERR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ISQTY_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ISQTY_B.

  CLEAR : GV_ERR.

  IF LINE_EXISTS( GT_BGOP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  GT_HGOP-TYPE  = SPACE.
  GT_HGOP-ISQTY = REDUCE MENGE_D( INIT X = CONV MENGE_D( 0 )
                                   FOR GT_BGOP IN GT_BGOP
                                  NEXT X = X + GT_BGOP-ISQTY ).
  PERFORM CHANGE_ISQTY_H USING ' '.

  MODIFY GT_HGOP INDEX GS_ROW-INDEX TRANSPORTING ISQTY ISVAL TYPE.

  PERFORM SET_BATS TABLES GT_BGOP
                    USING GS_BHDR-MATNR.

  PERFORM GET_GOP_HDR.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BATS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_BGOP
*&      --> GS_BHDR_MATNR
*&---------------------------------------------------------------------*
FORM SET_BATS TABLES PT_XBAT
               USING PV_MATNR.

  "기확정된 내역 존재시 삭제 후 다시 담기..
  DELETE GT_BATS WHERE WERKS = P_WERKS
                   AND LGORT = P_LGORT
                   AND MATNR = PV_MATNR.

  GT_BATS[] = CORRESPONDING #( BASE ( GT_BATS[] ) PT_XBAT[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ISQTY_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ISQTY_M.

  DATA : LT_MGOP LIKE SORTED TABLE OF GT_MGOP
                  WITH NON-UNIQUE KEY MATNR CHARG.

  DATA : LT_XGOP LIKE GT_MGOP OCCURS 0 WITH HEADER LINE.


  CLEAR : GV_ERR.

  IF LINE_EXISTS( GT_MGOP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  LT_MGOP[] = GT_MGOP[].

  LOOP AT GT_HGOP.
    READ TABLE GT_MGOP WITH KEY MATNR = GT_HGOP-MATNR
                                BINARY SEARCH.

    CHECK SY-SUBRC = 0.

    IF GT_HGOP-XCHPF IS NOT INITIAL.
      GT_HGOP-TYPE  = GC_M. "대량 입력건 구분자
      GT_HGOP-ISQTY = REDUCE MENGE_D( INIT X = CONV MENGE_D( 0 )
                                       FOR GT_MGOP IN GT_MGOP
                                     WHERE ( MATNR = GT_HGOP-MATNR )
                                      NEXT X = X + GT_MGOP-ISQTY ).

      LT_XGOP[] = FILTER #( LT_MGOP WHERE MATNR = GT_HGOP-MATNR ).
      PERFORM SET_BATS TABLES LT_XGOP
                        USING GT_HGOP-MATNR.
    ELSE.
      GT_HGOP-ISQTY = GT_MGOP-ISQTY.
    ENDIF.

    PERFORM CHANGE_ISQTY_H USING ' '.

    MODIFY GT_HGOP TRANSPORTING ISQTY ISVAL TYPE.
  ENDLOOP.

  PERFORM GET_GOP_HDR.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWN_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOWN_FORM.

  DATA : LV_TITLE TYPE STRING,
         LV_DNAME TYPE STRING,
         LV_FNAME TYPE STRING,
         LV_PATH  TYPE STRING,
         LV_FPATH TYPE STRING.

  DATA : LS_KEY TYPE WWWDATATAB.


  CLEAR : LV_FNAME, LV_PATH, LV_FPATH.

  LV_TITLE = '양식 다운로드 경로 설정'(T10).
  LV_DNAME = '대량입력.xlsx'(T11).

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE        = LV_TITLE
      DEFAULT_FILE_NAME   = LV_DNAME
      INITIAL_DIRECTORY   = 'C:\'
      PROMPT_ON_OVERWRITE = 'X'
    CHANGING
      FILENAME            = LV_FNAME
      PATH                = LV_PATH
      FULLPATH            = LV_FPATH.

  CHECK LV_FPATH IS NOT INITIAL.

  SELECT SINGLE *
    FROM WWWDATA
    INTO CORRESPONDING FIELDS OF LS_KEY
   WHERE OBJID = GC_ZGTMMR4110.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LS_KEY
        DESTINATION = CONV LOCALFILE( LV_FPATH ).

    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MESSAGE S022 DISPLAY LIKE 'E'. "해당 양식이 등록되지 않았습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_MASI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_MASI.

  CLEAR : GV_ERR.

* PERFORM CHECK_MBLNR_EXT.
* CHECK GV_ERR IS INITIAL.

  CALL SELECTION-SCREEN 300 STARTING AT 10 10.

  CHECK GV_OKCODE = 'CRET'. "AND GV_ERR IS INITIAL.

  PERFORM GET_EXCL_DATA.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_EXCL_DATA.

  CALL SCREEN 400 STARTING AT 10 5
                    ENDING AT 85 20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FPATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_FPATH.

  DATA : LT_FILES  TYPE FILETABLE,
         LV_FILTER TYPE STRING,
         LV_PATH   TYPE STRING,
         LV_RC     TYPE I.


  CLEAR : P_FPATH.

  CONCATENATE CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
              'Excel 통합 문서(*.XLSX)|*.XLSX|'
         INTO LV_FILTER.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
*     WINDOW_TITLE            = 'File open'
      FILE_FILTER             = LV_FILTER
      INITIAL_DIRECTORY       = LV_PATH
    CHANGING
      FILE_TABLE              = LT_FILES
      RC                      = LV_RC
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  CHECK SY-SUBRC = 0.

  P_FPATH = VALUE #( LT_FILES[ 1 ]-FILENAME OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXCL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EXCL_DATA.

  DATA : LT_EXCL LIKE ALSMEX_TABLINE OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF LS_MGOP,
           MATNR LIKE MARA-MATNR, "자재코드
           CHARG LIKE MCHB-CHARG, "배치
           ISQTY LIKE MSEG-MENGE, "불출수량
           MEINS LIKE MARA-MEINS, "단위
         END   OF LS_MGOP.


  CLEAR : GT_MGOP[], GT_MATN[], GT_SQTY[].

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FPATH
      I_BEGIN_COL             = 1
      I_BEGIN_ROW             = 2
      I_END_COL               = 4
      I_END_ROW               = 65000
    TABLES
      INTERN                  = LT_EXCL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC = 1.
    MESSAGE E043. "DISPLAY LIKE 'E'. "파일 변환에 실패했습니다.
*   GV_ERR = GC_X. EXIT.
  ELSEIF SY-SUBRC <> 0.
    MESSAGE E044. "DISPLAY LIKE 'E'. "파일 열람중 오류가 발생했습니다.
*   GV_ERR = GC_X. EXIT.
  ENDIF.

  LOOP AT LT_EXCL.
    AT NEW ROW.
      CLEAR : LS_MGOP, GT_MGOP.
    ENDAT.

    ASSIGN COMPONENT LT_EXCL-COL OF STRUCTURE LS_MGOP TO FIELD-SYMBOL(<LFS_VAL>).

    CASE LT_EXCL-COL.
      WHEN 1.
        PERFORM CONV_MATN1_IN USING LT_EXCL-VALUE
                           CHANGING LT_EXCL-VALUE.
      WHEN 3.
        REPLACE ',' WITH ' ' INTO LT_EXCL-VALUE.
        CONDENSE LT_EXCL-VALUE NO-GAPS.
    ENDCASE.

    <LFS_VAL> = TO_UPPER( LT_EXCL-VALUE ).

    AT END OF ROW.
      IF LS_MGOP IS NOT INITIAL.
        MOVE-CORRESPONDING LS_MGOP TO GT_MGOP.
        APPEND GT_MGOP.

        _SET_CON1 GT_MATN GT_MATN-MATNR GT_MGOP-MATNR.
        _SET_CON2 GT_SQTY GT_SQTY-MATNR GT_SQTY-CHARG
                          GT_MGOP-MATNR GT_MGOP-CHARG.
      ENDIF.
    ENDAT.
  ENDLOOP.

  IF GT_MGOP[] IS INITIAL.
    MESSAGE E024. "업로드할 내역이 없습니다.
*   GV_ERR = GC_X. EXIT.
  ELSE.
    SORT GT_MGOP BY MATNR CHARG.
    DELETE ADJACENT DUPLICATES FROM GT_MGOP COMPARING MATNR CHARG.

    "MATNR/CHARG 동일 라인 존재시 업로드를 중단하고 에러 메시지 처리
    IF SY-SUBRC = 0.
      MESSAGE E025. "DISPLAY LIKE 'E'. "중복된 데이터가 존재합니다. 파일 내역을 확인하세요.
*     GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_MATN1_IN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_EXCL_VALUE
*&      <-- LT_EXCL_VALUE
*&---------------------------------------------------------------------*
FORM CONV_MATN1_IN USING PV_IVAL
                CHANGING PV_OVAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_IVAL
    IMPORTING
      OUTPUT       = PV_OVAL
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL_DATA.

  DATA : LT_HGOP LIKE GT_HGOP OCCURS 0 WITH HEADER LINE.


  PERFORM GET_MATN.
  PERFORM GET_SQTY.

  LT_HGOP[] = GT_HGOP[].
  SORT LT_HGOP BY MATNR.

  LOOP AT GT_MGOP.
    PERFORM SET_MATN.
    PERFORM SET_SQTY.

    PERFORM CHK_MGOP_VAL TABLES LT_HGOP.

    MODIFY GT_MGOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MATN.

  CHECK GT_MATN[] IS NOT INITIAL.
  SORT GT_MATN BY MATNR.

  SELECT M~MATNR T~MAKTX M~MEINS
    FROM MARA AS M INNER JOIN MAKT AS T
      ON M~MATNR = T~MATNR
    INTO CORRESPONDING FIELDS OF TABLE GT_MATN
     FOR ALL ENTRIES IN GT_MATN
   WHERE M~MATNR = GT_MATN-MATNR
     AND M~LVORM = SPACE
     AND T~SPRAS = SY-LANGU.

  SORT GT_MATN BY MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SQTY.

  CHECK GT_SQTY[] IS NOT INITIAL.
  SORT GT_SQTY BY MATNR CHARG.

  SELECT WERKS,
         LGORT,
         MATNR,
         CHARG,
         UNQTY,
         QIQTY,
         BLQTY,
         TAGNR,
         XPCBT  "추가(SJM 25.02.27)
    FROM ZGTMM_CV_STOCKLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_SQTY
     FOR ALL ENTRIES IN @GT_SQTY
   WHERE WERKS = @P_WERKS
     AND LGORT = @P_LGORT
     AND MATNR = @GT_SQTY-MATNR
     AND CHARG = @GT_SQTY-CHARG.

  SORT GT_SQTY BY MATNR CHARG.

* GT_SQTY[] = CORRESPONDING #( GT_BGOP[] ).
* SORT GT_BGOP BY MATNR CHARG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MATN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MATN.

  CHECK GT_MGOP-MATNR IS NOT INITIAL.

  READ TABLE GT_MATN WITH KEY MATNR = GT_MGOP-MATNR
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_MGOP-MAKTX   = GT_MATN-MAKTX.
  GT_MGOP-MEINS_T = GT_MATN-MEINS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SQTY.

  CHECK GT_MGOP-MATNR IS NOT INITIAL.
*   AND GT_MGOP-CHARG IS NOT INITIAL.

  READ TABLE GT_SQTY WITH KEY MATNR = GT_MGOP-MATNR
                              CHARG = GT_MGOP-CHARG
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  MOVE-CORRESPONDING GT_SQTY TO GT_MGOP.
  GT_MGOP-SLQTY = GT_SQTY-UNQTY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MGOP_VAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HGOP
*&---------------------------------------------------------------------*
FORM CHK_MGOP_VAL TABLES PT_HGOP STRUCTURE GT_HGOP.

  CLEAR : GT_MGOP-STATUS, GT_MGOP-ETC. "GV_ERR.

  PERFORM CHK_MGOP_MATN TABLES PT_HGOP.

  IF GT_MGOP-ETC IS INITIAL.
    PERFORM CHK_MGOP_SQTY.
  ENDIF.

  PERFORM SET_MGOP_STATUS.

* IF GT_MGOP-ETC IS NOT INITIAL.
*   GT_MGOP-STATUS = ICON_LED_RED.
*   EXIT.
* ENDIF.
*
* IF GT_MGOP-ISQTY IS INITIAL.
*   GT_MGOP-STATUS = ICON_LED_YELLOW.
*   GT_MGOP-ETC    = '출고 수량을 입력하세요'.
* ELSE.
*   GT_MGOP-STATUS = ICON_LED_GREEN.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MGOP_MATN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HGOP
*&---------------------------------------------------------------------*
FORM CHK_MGOP_MATN TABLES PT_HGOP STRUCTURE GT_HGOP.

  "MATNR = ' '이면 Error
  IF GT_MGOP-MATNR IS INITIAL.
    GT_MGOP-ETC = 'EXCEL-자재코드가 누락되었습니다.'(M02).
    EXIT.
  ENDIF.

  "MATNR <> ' ' & MEINS = ' '이면 Error
  IF GT_MGOP-MEINS IS INITIAL.
    GT_MGOP-ETC = 'EXCEL-단위가 누락되었습니다.'(M03).
    EXIT.
  ENDIF.

  "MATNR <> ' ' & MEINS <> ' ' & ( MEINS <> MEINS_T)이면 Error
  IF GT_MGOP-MEINS <> GT_MGOP-MEINS_T.
    GT_MGOP-ETC = 'EXCEL-자재코드와 단위를 점검하세요.'(M04).
    EXIT.
  ENDIF.

* "STOCKQTY < ISSUEQTY 이면 Error
* IF GT_MGOP-SLQTY < GT_MGOP-ISQTY.
*   GT_MGOP-ETC = '출고 가능 수량이 부족합니다.'.
*   EXIT.
* ENDIF.

  "EXCEL-MATNR이 상단 ALV-MATNR에 미존재하면 Error
  READ TABLE PT_HGOP WITH KEY MATNR = GT_MGOP-MATNR
                              BINARY SEARCH.

  IF SY-SUBRC <> 0.
    GT_MGOP-ETC = '사급 BOM에 존재하지 않는 자재입니다.'(M05).
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MGOP_SQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_MGOP_SQTY.

  IF GT_MGOP-ISQTY IS INITIAL.
    GT_MGOP-STATUS = ICON_LED_YELLOW.
    GT_MGOP-ETC    = '출고 수량을 입력하세요'(M06).
    EXIT.
  ENDIF.

  "STOCKQTY < ISSUEQTY 이면 Error
  IF GT_MGOP-SLQTY < GT_MGOP-ISQTY.
    GT_MGOP-ETC = '출고 가능 수량이 부족합니다.'(M07).
    EXIT.
  ENDIF.

  "체크로직 추가(SJM 25.02.27)
  IF GT_MGOP-XPCBT = GC_X AND GT_MGOP-ISQTY > 0.
    IF GT_MGOP-ISQTY <> GT_MGOP-SLQTY.  "불출수량 <> 재고수량
      MESSAGE E119 INTO GT_MGOP-ETC. "단일 배치는 분할 출고 할 수 없습니다.
      CLEAR : GT_MGOP-ISQTY.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MGOP_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MGOP_STATUS.

  IF GT_MGOP-ETC    IS NOT INITIAL
 AND GT_MGOP-STATUS <> ICON_LED_YELLOW. "IS INITIAL.
    GT_MGOP-STATUS = ICON_LED_RED.
  ELSE.
    GT_MGOP-STATUS = ICON_LED_GREEN.
  ENDIF.

  CHECK GT_MGOP-STATUS <> ICON_LED_GREEN.
  GT_MGOP-ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELE_LINE.

  PERFORM GET_SELECTED_ROWS USING GR_MGRID 'M' 'X'
                                  '삭제할 라인을 선택하세요.'(M08).
  CHECK GV_ERR IS INITIAL.
  PERFORM POPUP_TO_CONFIRM USING '확인'(T03)
                                 '선택한 라인를 삭제하시겠습니까?'(M09).

  CHECK GV_ANS = GC_1.

  DELETE GT_ROW WHERE INDEX IS INITIAL.
  SORT GT_ROW BY INDEX DESCENDING.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_MGOP INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    DELETE GT_MGOP INDEX GS_ROW-INDEX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
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
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_500
*&      --> P_10
*&      --> P_5
*&      --> P_70
*&      --> P_8
*&---------------------------------------------------------------------*
FORM CALL_SCREEN USING PV_DYNNR
                       PV_SC
                       PV_SL
                       PV_EC
                       PV_EL.

  CALL SCREEN PV_DYNNR STARTING AT PV_SC PV_SL
                         ENDING AT PV_EC PV_EL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_PRXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_PRXX.

  CLEAR : GV_PRXX, GS_PRXX, GV_ERR.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM CHECK_XCPT_LIF.

      IF GS_HDR-IAVAL >= 0  "즉시 출고 대상
      OR GV_XCPT = GC_X.
        GV_PRXX = 'P' && GV_ZMODE. "(+)
      ELSE.                 "품의 진행 대상
        GV_PRXX = 'M' && GV_ZMODE. "(-)
      ENDIF.

    WHEN P_APD.
      GV_PRXX = 'P' && GV_ZMODE.

  ENDCASE.

  PERFORM CHECK_PRXX.
  CHECK GV_ERR IS INITIAL.

  "(S) ZMODE GI/OD 동일하게 후속 처리하도록 변경(SJM 25.06.11)
  CASE GV_PRXX+0(1).
    WHEN 'P'.
      PERFORM PRCS_PGI.

    WHEN 'M'.
      PERFORM PRCS_MGI.

  ENDCASE.
* CASE GV_PRXX.
*   WHEN 'POD' OR 'MOD'.
*     "YES 선택 시 상단 ALV 정보와 INTERNAL TABLE BATCHSTOCK을 활용하여
*     "재고 출고에 대한 예약정보를 MES(OR LEGACY) 시스템으로 INTERFACE
*     " - 인터페이스 협의 완료 후 후속 진행 예정
**    PERFORM PRCS_PROD.
*     PERFORM CALL_SCREEN USING 500 10 5 70 8. "임시!
*
*   WHEN 'PGI'.
*     PERFORM PRCS_PGI.
*
*   WHEN 'MGI'.
*     PERFORM PRCS_MGI.
*
* ENDCASE.
  "(E) ZMODE GI/OD 동일하게 후속 처리하도록 변경(SJM 25.06.11)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_XCPT_LIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_XCPT_LIF.

  "한도 예외 관리 업체 Check(SJM 25.03.25)
  "초과 불출 예외 업체는 한도 금액 상관없이 즉시 출고 처리(ZGTMMT4110 저장 X)

  CLEAR : GV_XCPT.
*>2026.04.03_가온전선_ZGODEV04_주석해제 시작.
*260128_주석_ZGODEV04*> 시작​
*>2026.01.05_가온전선_ZGODEV04
*한도예외관리 업체 체크 없이 한도 금액 상관없는 즉시 출고 처리위해 구분 로직 추가.
*> 시작​
  IF P_BUKRS = GC_6000.
     GV_XCPT = GC_X.

  ELSE.

  SELECT SINGLE LIFNR
    FROM ZGTMMT4101 INTO @DATA(LV_LIFNR)
   WHERE LIFNR = @S_LIFNR-LOW.

  CHECK SY-SUBRC = 0.

  GV_XCPT = GC_X.

  ENDIF.
**> 끝​
*260128_주석_ZGODEV04*> 끝
*2026.04.03_주석해제_ZGODEV04>끝
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_PGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_PGI.

* CLEAR : GV_ERR, GT_GITM[].
*
* PERFORM CHECK_PGI.
* CHECK GV_ERR IS INITIAL.

  GS_PRXX-BUDAT = SY-DATLO.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PRXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PRXX. "PGI.

  CLEAR : GT_GITM[].

  CASE 'X'.
    WHEN P_GOP.
      PERFORM CHECK_PGI_GOP.

    WHEN P_APD.
      PERFORM CHECK_PGI_APD.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PGI_GOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PGI_GOP.

  IF LINE_EXISTS( GT_HGOP[ ERR = GC_X ] ).
    MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  PERFORM SET_BLOCK. "추가(SJM 25.05.15)

  IF GS_HDR-BLOCK = GC_X.
    "메세지 변경(SJM 25.06.12)
*   MESSAGE S026 DISPLAY LIKE 'E'. "해당 업체 출고 관련 승인 진행 건이 존재합니다.
    MESSAGE S156 DISPLAY LIKE 'E'. "해당 업체 출고 관련 승인 진행 또는 미출고 건이 존재합니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

* PERFORM CHECK_MBLNR_EXT.
* CHECK GV_ERR IS INITIAL.

* CHECK GV_PRXX = GC_PGI.
  "(S) ZMODE GI/OD 동일하게 후속 처리하도록 변경(SJM 25.06.11)
  CASE GV_PRXX+0(1).
    WHEN 'P'.
* CASE GV_PRXX.
*   WHEN 'PGI'.
* "(E) ZMODE GI/OD 동일하게 후속 처리하도록 변경(SJM 25.06.11)
      "For 출고처리: 출하지시량 有 & 자재문서 無 라인 모두
      GT_GITM[] = CORRESPONDING #( GT_HGOP[] ).
      DELETE GT_GITM WHERE NOT ( ISQTY > 0 AND MBLNR IS INITIAL ).
*     DELETE GT_GITM WHERE ISQTY <= 0.

      IF GT_GITM[] IS INITIAL.
        MESSAGE S040 DISPLAY LIKE 'E'. "출고 처리할 품목이 없습니다.
        GV_ERR = GC_X. EXIT.
      ENDIF.

      PERFORM MODIFY_LIFNR USING S_LIFNR-LOW.

    WHEN 'M'. "변경(SJM 25.06.11) 'MGI'.
      "ZGTMMT4113에 승인 담당자 Setting 여부 Check(SJM 25.03.12)
      SELECT SINGLE APPROVER1, APPROVER2
        FROM ZGTMMT4113
        INTO @DATA(LS_APPV)
       WHERE BUKRS = @P_BUKRS
         AND WERKS = @P_WERKS
         AND LGORT = @P_LGORT.

      IF LS_APPV-APPROVER1 IS INITIAL AND LS_APPV-APPROVER2 IS INITIAL.
        MESSAGE S121 DISPLAY LIKE 'E'. "승인자 정보가 없습니다. 초과 불출 승인자를 먼저 등록하세요.
        GV_ERR = GC_X. EXIT.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PGI_APD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PGI_APD.

  CLEAR : GT_GITM[], GT_BATS[].

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '출고 처리할 품의 정보를 선택하세요.'(M10).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HAPD INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  IF NOT ( GT_HAPD-APPSTAT = GC_A AND GT_HAPD-MBLNR IS INITIAL ).
    MESSAGE S039 DISPLAY LIKE 'E'. "출고 처리 대상이 아닙니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  "For 출고처리: 선택한 라인의 ZGUID에 해당하는 Item/Batch 정보
  SELECT * FROM ZGTMMT4111
    INTO CORRESPONDING FIELDS OF TABLE GT_GITM
   WHERE ZGUID = GT_HAPD-ZGUID.

  SELECT * FROM ZGTMMT4112
    INTO CORRESPONDING FIELDS OF TABLE GT_BATS
   WHERE ZGUID = GT_HAPD-ZGUID.

  PERFORM MODIFY_LIFNR USING GT_HAPD-LIFNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HAPD_LIFNR
*&---------------------------------------------------------------------*
FORM MODIFY_LIFNR USING PV_LIFNR.

  DATA : LS_BATS LIKE GT_BGOP.


  GT_GITM-LIFNR = LS_BATS-LIFNR = PV_LIFNR.

  MODIFY GT_GITM TRANSPORTING LIFNR WHERE LIFNR IS INITIAL.
  MODIFY GT_BATS FROM LS_BATS
                 TRANSPORTING LIFNR WHERE LIFNR IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MBLNR_EXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MBLNR_EXT.

* "출고처리 성공 후, 재조회 없이 다른 라인의 자재도 출고처리 가능하도록
* "즉..출고처리 대상은 출하지시량 有 & 자재문서 無
*
* LOOP AT GT_HGOP.
*   IF GT_HGOP-ISQTY > 0 AND GT_HGOP-MBLNR IS INITIAL.
*   "출고 처리 결과가 존재합니다. 다시 조회 후 진행하세요.
*   MESSAGE S027 DISPLAY LIKE 'E'.
*   GV_ERR = GC_X. EXIT.
* ENDLOOP.

************************************************************************
  "상단 ALV-MBLNR(자재문서) 존재시 Error
  " 출고처리/재고조회/대량입력/추가자재 버튼 클릭시 동일하게 적용
  " [보류]출고 결과 존재시에도 미출고 자재 처리 필요한 경우에 대한 처리는 고객 테스트 후 필요 시 추가 보완

  LOOP AT GT_HGOP WHERE MBLNR IS NOT INITIAL.
    "출고 처리 결과가 존재합니다. 다시 조회 후 진행하세요.
    MESSAGE S027 DISPLAY LIKE 'E'.
    GV_ERR = GC_X. EXIT.
  ENDLOOP.

* IF REDUCE I( INIT X = 0 FOR GT_HGOP IN GT_HGOP
*              WHERE ( MBLNR IS NOT INITIAL )
*              NEXT X = X + 1 ) > 0.
*   MESSAGE S027 DISPLAY LIKE 'E'.
*   GV_ERR = GC_X. EXIT.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YPGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YPGI.

  CLEAR : GS_MHDRT, GT_RTN[].

  PERFORM SET_MHDR.
  PERFORM SET_MITM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GS_MHDR
      GOODSMVT_CODE    = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET = GS_MHDRT
    TABLES
      GOODSMVT_ITEM    = GT_MITM
      RETURN           = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    PERFORM SET_PGI_TAG.
    PERFORM SET_PGI_RTN.

    PERFORM SEND_WMS. "추가(SJM 25.06.11)

    MESSAGE S028. "출고 처리를 완료했습니다.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_BAPI_ERR_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MHDR.

  "Header
  CLEAR : GS_MHDR, GS_MCOD.

  GS_MHDR-PSTNG_DATE = GS_PRXX-BUDAT.
  GS_MHDR-DOC_DATE   = SY-DATLO.
  GS_MHDR-PR_UNAME   = SY-UNAME.
  GS_MHDR-HEADER_TXT = GS_PRXX-REMARK.

  GS_MCOD-GM_CODE    = GC_04.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MITM.

  "Item
  CLEAR : GT_MITM[], GR_MATNR[].

  LOOP AT GT_GITM.
    IF GT_GITM-XCHPF IS INITIAL.
      PERFORM SET_XITM USING GT_GITM-MATNR
                             ' '
                             GT_GITM-LIFNR
                             GT_GITM-ISQTY
                             GT_GITM-MEINS
                             ' '.
    ELSE.
      READ TABLE GT_BATS INTO DATA(LS_BATS)
        WITH KEY MATNR = GT_GITM-MATNR BINARY SEARCH.

      IF SY-SUBRC = 0.
        GV_TBX = SY-TABIX.

        APPEND VALUE #( SIGN   = GC_I
                        OPTION = GC_EQ
                        LOW    = GT_GITM-MATNR ) TO GR_MATNR.

        LOOP AT GT_BATS INTO LS_BATS FROM GV_TBX.
          IF LS_BATS-MATNR <> GT_GITM-MATNR.
            EXIT.
          ENDIF.

          PERFORM SET_XITM USING LS_BATS-MATNR
                                 LS_BATS-CHARG
                                 LS_BATS-LIFNR
                                 LS_BATS-ISQTY
                                 LS_BATS-MEINS
                                 LS_BATS-TAGNR.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP-MATNR
*&      --> P_
*&      --> GT_HGOP_ISQTY
*&      --> GT_HGOP_MEINS
*&---------------------------------------------------------------------*
FORM SET_XITM USING PV_MATNR
                    PV_CHARG
                    PV_LIFNR
                    PV_ISQTY
                    PV_MEINS
                    PV_TAGNR. "추가(SJM 25.02.27)

  CLEAR : GT_MITM.
  CHECK PV_ISQTY > 0.

  GT_MITM-MATERIAL   = PV_MATNR.
  GT_MITM-PLANT      = P_WERKS.
  GT_MITM-STGE_LOC   = P_LGORT.
  GT_MITM-BATCH      = PV_CHARG.
  GT_MITM-MOVE_TYPE  = GC_541.
  GT_MITM-VENDOR     = PV_LIFNR. "S_LIFNR-LOW.
  GT_MITM-ENTRY_QNT  = PV_ISQTY.
  GT_MITM-ENTRY_UOM  = PV_MEINS.
  GT_MITM-ITEM_TEXT  = PV_TAGNR. "추가(SJM 25.02.27)

  APPEND GT_MITM.

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
*& Form SET_PGI_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGI_TAG.

  "꼬리표 로직 추가(SJM 25.02.27)

  GT_TAG[] = VALUE #( FOR LS_MITM IN GT_MITM
                       ( VALUE #( WERKS	= LS_MITM-PLANT
                                  TAGNR	= LS_MITM-ITEM_TEXT
                                  CHARG = LS_MITM-BATCH
                                  MATNR = LS_MITM-MATERIAL ) ) ).

  PERFORM GET_TAG.

  CHECK GT_TAG[] IS NOT INITIAL.

  "Update ZPPT0001(꼬리표)
  LOOP AT GT_TAG.
    READ TABLE GT_BATS INTO DATA(LS_BATS)
                       WITH KEY MATNR = GT_TAG-MATNR
                                CHARG = GT_TAG-CHARG
                                WERKS = GT_TAG-WERKS
                                TAGNR = GT_TAG-TAGNR.

    CHECK SY-SUBRC = 0.

    IF ( LS_BATS-XPCBT = GC_X ) OR ( LS_BATS-ISQTY >= GT_TAG-REMAIN ).
      GV_REQTY = SPACE.
      GV_GIF   = GC_Y.
*     GT_TAG-MBLNR = LV_MBLNR. "기존 로직인데 이상. 로직은 구현하되 LV_MBLNR 업데이트는 주석
    ELSE.
      GV_REQTY = GT_TAG-REMAIN - LS_BATS-ISQTY.
      GV_GIF   = GC_N.
    ENDIF.

    PERFORM UPDATE_ZPPT0001.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TAG.

  "꼬리표 정보 조회

  DELETE GT_TAG WHERE TAGNR IS INITIAL.

  SORT GT_TAG BY WERKS TAGNR CHARG MATNR.
  DELETE ADJACENT DUPLICATES FROM GT_TAG
                        COMPARING WERKS TAGNR CHARG MATNR.

  CHECK GT_TAG[] IS NOT INITIAL.

  SELECT WERKS TAGNR CHARG MATNR REMAIN MEINS
    FROM ZPPT0001
    INTO CORRESPONDING FIELDS OF TABLE GT_TAG
     FOR ALL ENTRIES IN GT_TAG
   WHERE WERKS = GT_TAG-WERKS
     AND TAGNR = GT_TAG-TAGNR
     AND CHARG = GT_TAG-CHARG
     AND MATNR = GT_TAG-MATNR.

  SORT GT_TAG BY WERKS TAGNR CHARG MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001.

  UPDATE ZPPT0001 SET REMAIN = GV_REQTY
                      GIFLG  = GV_GIF
                WHERE WERKS  = GT_TAG-WERKS
                  AND TAGNR  = GT_TAG-TAGNR
                  AND CHARG  = GT_TAG-CHARG
                  AND MATNR  = GT_TAG-MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGI_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGI_RTN.

  CASE 'X'.
    WHEN P_GOP.
      PERFORM SET_PGI_GOP_RTN.
    WHEN P_APD.
      PERFORM SET_PGI_APD_RTN.
  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGI_GOP_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGI_GOP_RTN.

  "자재문서 생성 결과 List Update

  SORT GT_GITM BY MATNR.

  SELECT MATNR, "자재코드
         SCQTY, "외주재고량
         NEQTY, "필요량
         SLQTY, "창고재고량
         SCVAL  "외주재고액
    FROM ZGTMM_CV_SCREQLIST_L
     FOR ALL ENTRIES IN @GT_GITM
   WHERE BUKRS = @P_BUKRS
     AND WERKS = @P_WERKS
     AND LGORT = @P_LGORT
     AND LIFNR = @GT_GITM-LIFNR
     AND MATNR = @GT_GITM-MATNR
    INTO TABLE @DATA(LT_HGOP).

  LOOP AT LT_HGOP INTO DATA(LS_HGOP).
    DATA(LV_IDX) = LINE_INDEX( GT_HGOP[ MATNR = LS_HGOP-MATNR ] ).

    CHECK LV_IDX > 0.

    GT_HGOP[ LV_IDX ]-SCQTY = LS_HGOP-SCQTY.    "외주재고량
    GT_HGOP[ LV_IDX ]-NEQTY = LS_HGOP-NEQTY.    "필요량
    GT_HGOP[ LV_IDX ]-SLQTY = LS_HGOP-SLQTY.    "창고재고량
    GT_HGOP[ LV_IDX ]-SCVAL = LS_HGOP-SCVAL.    "외주재고액
    GT_HGOP[ LV_IDX ]-MJAHR = GS_MHDRT-DOC_YEAR.
    GT_HGOP[ LV_IDX ]-MBLNR = GS_MHDRT-MAT_DOC.

    GT_HGOP[ LV_IDX ]-ISQTY = 0. "출하지시량
    GT_HGOP[ LV_IDX ]-ISVAL = 0. "출하지시금액
  ENDLOOP.

* GT_HGOP-MJAHR = GS_MHDRT-DOC_YEAR.
* GT_HGOP-MBLNR = GS_MHDRT-MAT_DOC.
* MODIFY GT_HGOP TRANSPORTING MJAHR MBLNR
*  WHERE ISQTY > 0 AND MBLNR IS INITIAL.

  DELETE GT_BATS WHERE MATNR IN GR_MATNR. "삭제할 필요까지 있을까?

  PERFORM GET_GOP_HDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PGI_APD_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PGI_APD_RTN.

  "자재문서 생성 결과 List 및 Table ZGTMMT4110 Update

  GT_HAPD-STATUS = ICON_STOCK. "추가(SJM 25.03.14)
  GT_HAPD-MJAHR  = GS_MHDRT-DOC_YEAR.
  GT_HAPD-MBLNR  = GS_MHDRT-MAT_DOC.
  MODIFY GT_HAPD INDEX GS_ROW-INDEX TRANSPORTING STATUS MJAHR MBLNR.

  CLEAR : GT_AHDR, GT_AHDR[].
  MOVE-CORRESPONDING GT_HAPD TO GT_AHDR.
  APPEND GT_AHDR.

  MODIFY ZGTMMT4110 FROM TABLE GT_AHDR.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BAPI_ERR_MSG.

  READ TABLE GT_RTN WITH KEY TYPE = 'E'.
  CHECK SY-SUBRC = 0.

  MESSAGE S000 DISPLAY LIKE 'E'
     WITH GT_RTN-MESSAGE+0(50)   GT_RTN-MESSAGE+50(50)
          GT_RTN-MESSAGE+100(50) GT_RTN-MESSAGE+150(50).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VRM_SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_PRXX_ORES
*&---------------------------------------------------------------------*
FORM VRM_SET_VALUES USING PV_ID
                          PV_VAL.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = GT_LBOX.

  PV_VAL = VALUE #( GT_LBOX[ 1 ]-KEY OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_MGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_MGI.

* GS_PRXX-ORES = 999.

*  PERFORM CALL_SCREEN USING 500 10 5
*                                70 10.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REMARK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_PRXX_ORES
*&---------------------------------------------------------------------*
FORM CHECK_REMARK USING PV_XRES.

  CHECK PV_XRES = GC_999  "기타
    AND GS_PRXX-REMARK IS INITIAL.

  MESSAGE S082 DISPLAY LIKE 'E'. "기타인 경우, 비고는 필수 입력값입니다.
  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_GIAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_GIAR.

  PERFORM CHECK_REMARK USING GS_PRXX-ORES.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_AHDR.
  PERFORM SET_AITM.

  IF GT_AITM[] IS INITIAL.
    MESSAGE S031 DISPLAY LIKE 'E'. "품의 진행할 내역이 없습니다.
    EXIT.
  ENDIF.

  MODIFY ZGTMMT4112 FROM TABLE GT_ABAT.
  MODIFY ZGTMMT4111 FROM TABLE GT_AITM.
  MODIFY ZGTMMT4110 FROM TABLE GT_AHDR.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    "상신 Block여부 Check (별도 재조회 및 출하지시량 Clear 작업은 필요없음)
    GS_HDR-BLOCK = GC_X.
    PERFORM SET_BLOCK. "Text도 재조회되도록 추가(SJM 25.03.12)

    MESSAGE S042. "출고 품의 완료되었습니다.

    PERFORM SEND_MAIL.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S032 DISPLAY LIKE 'E'. "품의 진행에 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL.

  "메일 전송 기능 추가(SJM 24.12.20)

  DATA : LV_CHK, LV_CHK2,
         LV_MSG(100), LV_MSG2(100).


  CLEAR : GV_TEXT, GT_MTXT,
          GV_TEXT2, GT_MTXT2.

  CASE GV_OKCODE.
    WHEN 'GIAR'. "출고품의
      PERFORM SET_GIAR_MAIL.

    WHEN 'YPRX'. "승인(Yes)
      IF GV_PRXX = GC_APV. "지금은..없어도 되지만..
        PERFORM SET_XAPV_MAIL USING '승인'(I03).
***<<<CHM2510-00282 승인자 메일 성공시, 구매기획팀 전송(알림용)
        PERFORM SET_XAPV_MAIL2 USING '승인'(I03).
      ENDIF.

    WHEN 'RJPR'. "반려처리
      PERFORM SET_XAPV_MAIL USING '반려'(I04).

  ENDCASE.

  LOOP AT GT_APPV.
    CALL FUNCTION 'Z_MM_SEND_MAIL'
      EXPORTING
        I_UNAME     = CONV SYST_UNAME( GT_APPV-USERID )
        I_EMAIL     = CONV AD_SMTPADR( GT_APPV-EMAIL )
        I_HEAD_TEXT = GV_TEXT
      IMPORTING
        E_RETURN    = LV_CHK
        E_MESSAGE   = LV_MSG
      TABLES
        T_MSG       = GT_MTXT.
  ENDLOOP.

  CHECK LV_CHK = 'S'.

***<<<CHM2510-00282 승인자 메일 성공시, 구매기획팀 전송(알림용)
  LOOP AT GT_APPV2.
    CALL FUNCTION 'Z_MM_SEND_MAIL'
      EXPORTING
        I_UNAME     = CONV SYST_UNAME( GT_APPV2-PERSNUMBER )
        I_EMAIL     = CONV AD_SMTPADR( GT_APPV2-MAIL )
        I_HEAD_TEXT = GV_TEXT2
      IMPORTING
        E_RETURN    = LV_CHK2
        E_MESSAGE   = LV_MSG2
      TABLES
        T_MSG       = GT_MTXT2[].
  ENDLOOP.
***>>>CHM2510-00282 승인자 메일 성공시, 구매기획팀 전송(알림용)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EMAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EMAIL.

  CHECK GT_APPV[] IS NOT INITIAL.
  SORT GT_APPV BY USERID.

  SELECT USERID, EMAIL
    FROM ZGTMM_CV_GETUSERNAME "ZGTMM_CV_GETAPUSERLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_APPV
     FOR ALL ENTRIES IN @GT_APPV
   WHERE USERID = @GT_APPV-USERID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GIAR_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GIAR_MAIL.

  CLEAR : GT_APPV[].

  SELECT APPROVER1 AS USERID
    FROM ZGTMMT4113
    INTO CORRESPONDING FIELDS OF TABLE GT_APPV
   WHERE BUKRS = P_BUKRS
     AND WERKS = P_WERKS
     AND LGORT = P_LGORT.

  PERFORM GET_EMAIL.

  GV_TEXT = '[사급자재불출]사급자재 보증 금액 초과 불출에 대한 승인 요청'(T12).

  "메일 본문에 Plant 정보 추가(SJM 25.05.22)
  GT_MTXT[] = VALUE #( ( LINE = `Plant ` && P_WERKS && '의 사급자재 보증 금액 초과 불출이 필요합니다.'(M11) )
                       ( LINE = '내용 확인 후 승인 요청드립니다.'(M12) )
                       ( LINE = 'T-Code ZGTMMR4110에서 상세 확인하세요.'(M13) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XAPV_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_XAPV_MAIL USING PV_PRCNM.

  PERFORM GET_EMAIL.

  "사급자재 보증 금액 초과 불출요청에 대한 &
  MESSAGE S077 WITH PV_PRCNM INTO GV_TEXT.

  "사급자재 보증 금액 초과 불출 요청에 대해 &합니다.
  MESSAGE S078 WITH PV_PRCNM INTO GS_MTXT-LINE.
  APPEND GS_MTXT TO GT_MTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_GUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_AHDR_ZGUID
*&---------------------------------------------------------------------*
FORM CREATE_GUID CHANGING PV_ZGUID.

* CALL FUNCTION 'GUID_CREATE' "--> Do not use!!
*  IMPORTING
*    EV_GUID_16       =
*    EV_GUID_22       =
*    EV_GUID_32       =

  CLEAR : PV_ZGUID.
  PV_ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TIMESTAMP USING PV_CREA
                         PV_CHNG.

  CLEAR : GS_CREA, GS_CHNG.

  IF PV_CREA = GC_X.
    PERFORM SET_TSTMP USING GS_CREA.
  ENDIF.

  IF PV_CHNG = GC_X.
    PERFORM SET_TSTMP USING GS_CHNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
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
*& Form SET_AHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AHDR.

  CLEAR : GT_AHDR, GT_AHDR[].

  PERFORM CREATE_GUID CHANGING GT_AHDR-ZGUID.

  GT_AHDR-ZGITYPE = GC_A.           "출고유형
  GT_AHDR-BUKRS   = P_BUKRS.        "회사코드
  GT_AHDR-WERKS   = P_WERKS.        "플랜트
  GT_AHDR-LGORT   = P_LGORT.        "저장위치
  GT_AHDR-LIFNR   = S_LIFNR-LOW.    "업체
  GT_AHDR-PREIS   = GS_HDR-PREIS.   "보증금액
  GT_AHDR-SCVAL   = GS_HDR-SCVAL.   "사급재고액
  GT_AHDR-ISVAL   = GS_HDR-ISVAL.   "출고예정액
  GT_AHDR-REVAL   = GS_HDR-IAVAL.   "출고가용액
  GT_AHDR-IVVAL   = GS_HDR-APVAL.   "당월IV 금액
  GT_AHDR-WAERS   = GS_HDR-WAERS.   "통화
  GT_AHDR-ORES    = GS_PRXX-ORES.   "초과사유
  GT_AHDR-OETC    = GS_PRXX-REMARK. "비고

  PERFORM SET_TIMESTAMP USING 'X' 'X'.
  MOVE-CORRESPONDING GS_CREA TO GT_AHDR.
  MOVE-CORRESPONDING GS_CHNG TO GT_AHDR.

  APPEND GT_AHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AITM.

  CLEAR : GT_AITM[], GT_ABAT[].

  "출하지시량 입력된 라인만 모두 대상

  LOOP AT GT_HGOP.
    CHECK GT_HGOP-ISQTY > 0.

    "Item
    PERFORM APPEND_AITM TABLES GT_AITM
                         USING GT_HGOP.

    "Batch
    READ TABLE GT_BATS INTO DATA(LS_BATS)
      WITH KEY MATNR = GT_HGOP-MATNR BINARY SEARCH.

    IF SY-SUBRC = 0.
      LOOP AT GT_BATS INTO LS_BATS FROM SY-TABIX.
        IF LS_BATS-MATNR <> GT_HGOP-MATNR.
          EXIT.
        ENDIF.

        CHECK LS_BATS-ISQTY > 0.
        PERFORM APPEND_AITM TABLES GT_ABAT
                             USING LS_BATS.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_AITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_AITM
*&      --> GT_HGOP
*&---------------------------------------------------------------------*
FORM APPEND_AITM TABLES PT_XITM
                  USING PS_ITEM.

  CLEAR : PT_XITM.
  MOVE-CORRESPONDING PS_ITEM TO PT_XITM.

  ASSIGN COMPONENT 'ZGUID' OF STRUCTURE PT_XITM TO FIELD-SYMBOL(<LFS_ZGUID>).
  <LFS_ZGUID> = GT_AHDR-ZGUID.

  APPEND PT_XITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_ISGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_ISGO.

  "멀티라인 선택 가능으로 변경(SJM 25.03.25)

  CLEAR : GV_ERR. "GV_MBLNR.

  PERFORM CHECK_ISGO.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_BZAREA.

  CLEAR : GT_STAB[].

  PERFORM SET_STAB USING 'R1' 'P' 'X' ' '. "MM 일반(Default)
  PERFORM SET_STAB USING 'R2' 'P' ' ' ' '. "매각/폐기
  PERFORM SET_STAB USING 'R3' 'P' ' ' ' '. "PP일반
  PERFORM SET_STAB USING 'R4' 'P' ' ' ' '. "서비스

  PERFORM SET_STAB USING 'P_BZAREA' 'P' GV_BZAREA ' '. "사업장
  PERFORM SET_STAB USING 'P_BUKRS'  'P' P_BUKRS   ' '. "회사코드

  SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'. "이동유형: 무상사급(Default)

  _CALC_DATE SY-DATLO '00' '06' '-' '00'. "기준 변경(SJM 25.03.10)
  PERFORM SET_STAB USING 'I_CPUDT' 'S' GV_CDATE SY-DATLO.   "자재문서 발행일

  LOOP AT GT_ISGO.
    PERFORM SET_STAB USING 'I_MBLNR' 'S' GT_ISGO-MBLNR ' '. "자재문서 번호
  ENDLOOP.

  CHECK NOT GT_STAB[] IS INITIAL.
*>2026.04.10_가온전선_ZGODEV04
*회사코드(6000_가온전선)로 통문증 발행 프로그램 구분 로직 추가.
*> 시작
  IF P_BUKRS = GC_6000.

  PERFORM SET_STAB USING 'P_WERKS'  'P' P_WERKS   ' '. "회사코드
 "통문증 발행 Pgm.호출(ZGTMMR4500)
  SUBMIT ZGTMMR4500 WITH SELECTION-TABLE GT_STAB
                                   AND RETURN.
  ELSE.
  "통문증 발행 Pgm.호출(ZLER0015)
  SUBMIT ZLER0015 WITH SELECTION-TABLE GT_STAB
*                  VIA SELECTION-SCREEN
                   AND RETURN.
  ENDIF.
*<끝.

  LOOP AT GT_ISGO.
    CASE 'X'.
      WHEN P_GOP.
        PERFORM MODIFY_IV_NO TABLES GT_HGOP.
      WHEN P_GOD.
        PERFORM MODIFY_IV_NO TABLES GT_HGOD.
      WHEN P_APD.
        PERFORM MODIFY_IV_NO TABLES GT_HAPD.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ISGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ISGO.

  CLEAR : GT_ISGO[].

  DATA(LV_MODE) = COND #( WHEN P_GOP = 'X' THEN GC_S
                          WHEN P_GOD = 'X' THEN GC_M
                          WHEN P_APD = 'X' THEN GC_M ).

  PERFORM GET_SELECTED_ROWS USING GR_HGRID LV_MODE 'X' ' '.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    CASE 'X'.
      WHEN P_GOP.
        PERFORM READ_ISGO TABLES GT_HGOP.
      WHEN P_GOD.
        PERFORM READ_ISGO TABLES GT_HGOD.
      WHEN P_APD.
        PERFORM READ_ISGO TABLES GT_HAPD.
    ENDCASE.

    IF GS_ISGO-IV_NO IS NOT INITIAL.
      MESSAGE S029 DISPLAY LIKE 'E'. "이미 통문증이 발급되었습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GS_ISGO-MBLNR IS INITIAL.
      MESSAGE S030 DISPLAY LIKE 'E'. "아직 출고되지 않은 자재입니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    MOVE-CORRESPONDING GS_ISGO TO GT_ISGO.
    COLLECT GT_ISGO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_ISGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP
*&---------------------------------------------------------------------*
FORM READ_ISGO TABLES PT_LIST.

  CLEAR : GS_ISGO.

  READ TABLE PT_LIST INDEX GS_ROW-INDEX.

  CHECK SY-SUBRC = 0.
  MOVE-CORRESPONDING PT_LIST TO GS_ISGO.

* GV_MBLNR = GS_ISGO-MBLNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BZAREA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BZAREA.

  CLEAR : GV_BZAREA.

* LV_BZAREA = COND #( WHEN P_WERKS+0(2) = '13' THEN '2000'
*                          P_WERKS+0(2) = '14' THEN '3000'
*                          P_WERKS+0(2) = '18' THEN '6000' ).

  DATA(LV_WERKS) = P_WERKS+0(2). "ZLET0034-BZAREA
  GV_BZAREA = SWITCH #( LV_WERKS WHEN '13' THEN 2000
                                 WHEN '14' THEN 3000
                                 WHEN '18' THEN 6000 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_STAB USING PV_SNAME
                    PV_KIND
                    PV_LOW
                    PV_HIGH.

  CLEAR : GT_STAB.

  GT_STAB-SELNAME = PV_SNAME.
  GT_STAB-KIND    = PV_KIND.
  GT_STAB-LOW     = PV_LOW.
  GT_STAB-HIGH    = PV_HIGH.

  IF PV_KIND = GC_S. "???
    GT_STAB-SIGN = GC_I.

    IF PV_HIGH IS NOT INITIAL.
      GT_STAB-OPTION = GC_BT.
    ELSE.
      GT_STAB-OPTION = GC_EQ.
    ENDIF.
  ENDIF.

  APPEND GT_STAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_IV_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP
*&---------------------------------------------------------------------*
FORM MODIFY_IV_NO TABLES PT_HXXX.

  DATA : LV_COND TYPE STRING.


* ASSIGN COMPONENT 'MBLNR' OF STRUCTURE PT_HXXX TO FIELD-SYMBOL(<LFS_MBLNR>).
* ASSIGN COMPONENT 'MJAHR' OF STRUCTURE PT_HXXX TO FIELD-SYMBOL(<LFS_MJAHR>).
* ASSIGN COMPONENT 'IV_NO' OF STRUCTURE PT_HXXX TO FIELD-SYMBOL(<LFS_IV_NO>).
*
* PERFORM GET_IV_NO USING <LFS_MBLNR>
*                         <LFS_MJAHR>
*                CHANGING <LFS_IV_NO>.
*
* CHECK <LFS_IV_NO> IS NOT INITIAL.
*
* LV_COND = | MBLNR = GV_MBLNR |.

  ASSIGN COMPONENT 'IV_NO' OF STRUCTURE PT_HXXX TO FIELD-SYMBOL(<LFS_IV_NO>).

  PERFORM GET_IV_NO USING GT_ISGO-MBLNR
                          GT_ISGO-MJAHR
                 CHANGING <LFS_IV_NO>.

  CHECK <LFS_IV_NO> IS NOT INITIAL.



  LV_COND = | MBLNR = GT_ISGO-MBLNR |.

  CASE 'X'.
    WHEN P_APD.
      "통문증 발급 성공시 Status Update(SJM 25.02.27)
      ASSIGN COMPONENT 'STATUS' OF STRUCTURE PT_HXXX TO FIELD-SYMBOL(<LFS_STS>).
      <LFS_STS> = ICON_WS_TRUCK. "변경(SJM 25.03.14) ICON_LED_GREEN.

      MODIFY PT_HXXX TRANSPORTING ('STATUS') ('IV_NO') WHERE (LV_COND).

    WHEN OTHERS.
      MODIFY PT_HXXX TRANSPORTING ('IV_NO') WHERE (LV_COND).

  ENDCASE.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IV_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HGOP_MBLNR
*&      --> GT_HGOP_MJAHR
*&      <-- GT_HGOP_IV_NO
*&---------------------------------------------------------------------*
FORM GET_IV_NO USING PV_MBLNR
                     PV_MJAHR
            CHANGING PV_IV_NO.

  WAIT UP TO 1 SECONDS.

  CLEAR : PV_IV_NO.
  CHECK PV_MBLNR IS NOT INITIAL.

  IF P_BUKRS = GC_6000.
  SELECT SINGLE H~IV_NO
    FROM ZGTMMT4501 AS I INNER JOIN ZGTMMT4500 AS H
      ON I~IV_NO = H~IV_NO
    INTO PV_IV_NO
   WHERE I~MBLNR        = PV_MBLNR
     AND I~MJAHR        = PV_MJAHR
     AND H~IV_CANCEL_YN = SPACE.
  ELSE.


  SELECT SINGLE H~IV_NO
    FROM ZLET0006 AS I INNER JOIN ZLET0005 AS H
      ON I~IV_NO = H~IV_NO
    INTO PV_IV_NO
   WHERE I~MBLNR        = PV_MBLNR
     AND I~MJAHR        = PV_MJAHR
     AND H~IV_CANCEL_YN = SPACE.


 ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_TGIH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_TGIH.

  DATA : LV_BEGDA LIKE SY-DATLO,
         LV_ENDDA LIKE SY-DATLO,
         LV_CANC.

  RANGES : LR_BUDAT FOR SY-DATLO.


  CLEAR : GT_TGIH[].

  _CALC_DATE SY-DATLO '00' '03' '-' '00'.

  CALL FUNCTION 'CNV_DEMO_FM_POPUP_GET_DATES'
    EXPORTING
      IV_BEGDA     = GV_CDATE
      IV_ENDDA     = SY-DATLO
    IMPORTING
      EV_BEGDA     = LV_BEGDA
      EV_ENDDA     = LV_ENDDA
      EV_CANCELLED = LV_CANC.

  CHECK LV_CANC IS INITIAL.

  IF LV_BEGDA IS INITIAL.
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    EXIT.
  ENDIF.

  IF LV_ENDDA IS NOT INITIAL.
    LR_BUDAT[] = VALUE #( ( SIGN   = GC_I
                            OPTION = GC_BT
                            LOW    = LV_BEGDA
                            HIGH   = LV_ENDDA ) ).
  ELSE.
    LR_BUDAT[] = VALUE #( ( SIGN   = GC_I
                            OPTION = GC_EQ
                            LOW    = LV_BEGDA ) ).
  ENDIF.

  SELECT *
    FROM ZGTMM_CV_MVT541_VENDOR
    INTO CORRESPONDING FIELDS OF TABLE @GT_TGIH
   WHERE LIFNR  = @GS_HDR-LIFNR
     AND BUDAT IN @LR_BUDAT.

  IF GT_TGIH[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_TGIH BY BUDAT DESCENDING.

  CALL SCREEN 600 STARTING AT  10  5
                    ENDING AT 130 20.


* DATA : LR_POP TYPE REF TO CL_RECA_GUI_F4_POPUP.
*
* CALL METHOD CL_RECA_GUI_F4_POPUP=>FACTORY_GRID
*   EXPORTING
*     IT_F4VALUE     = GT_TGIH[]
*     IF_MULTI       = ' '
*     ID_TITLE       = '업체 불출 이력'
*   RECEIVING
*     RO_F4_INSTANCE = LR_POP.
*
* CALL METHOD LR_POP->DISPLAY
*   EXPORTING
*     ID_START_COLUMN = 25
*     ID_START_LINE   = 6
*     ID_END_COLUMN   = 180
*     ID_END_LINE     = 20
*   IMPORTING
*     ET_RESULT       = GT_TGIH[]
*     EF_CANCELLED    = LV_CANC.

* CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
*   EXPORTING
*     I_TITLE          = '업체 불출 이력'
*     I_ZEBRA          = GC_X
*     I_TABNAME        = 'LT_TGIH'
*     I_STRUCTURE_NAME = 'ZGTMMS0005'
**    IT_FIELDCAT      = GT_FCAT
**    IT_EXCLUDING     = LT_EXCD
*   TABLES
*     T_OUTTAB         = GT_TGIH
*   EXCEPTIONS
*     PROGRAM_ERROR    = 1
*     OTHERS           = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCGO.

  CLEAR : GV_ERR.

  PERFORM CHECK_CCGO.
  CHECK GV_ERR IS INITIAL.

  PERFORM SET_BZAREA.
* DATA(LV_IV_NO) = GT_HGOD-IV_NO.

  CLEAR : GT_STAB[].

  PERFORM SET_STAB USING 'R1' 'P' 'X' ' '. "MM 일반(Default)
  PERFORM SET_STAB USING 'R2' 'P' ' ' ' '. "매각/폐기
  PERFORM SET_STAB USING 'R3' 'P' ' ' ' '. "PP일반
  PERFORM SET_STAB USING 'R4' 'P' ' ' ' '. "서비스

  PERFORM SET_STAB USING 'P_BZAREA' 'P' GV_BZAREA ' '. "사업장
  PERFORM SET_STAB USING 'P_BUKRS'  'P' P_BUKRS   ' '. "회사코드

** SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'. "이동유형: 무상사급(Default)

  PERFORM SET_STAB USING 'I_DATE' 'S' GS_GOUT-IV_DATE ' '. "통문증 발행일
  PERFORM SET_STAB USING 'I_IVNO' 'S' GS_GOUT-IV_NO   ' '. "통문번호

  CHECK NOT GT_STAB[] IS INITIAL.

  IF P_BUKRS = GC_6000.
  PERFORM SET_STAB USING 'P_WERKS'  'P' P_WERKS   ' '. "플랜트
 SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'. "이동유형: 무상사급(Default)
  "통문증 발행 취소 Pgm.호출(ZLER0016)
  SUBMIT ZGTMMR4510 WITH SELECTION-TABLE GT_STAB
*              VIA SELECTION-SCREEN
                   AND RETURN.
  ELSE.
  "통문증 발행 취소 Pgm.호출(ZLER0016)
  SUBMIT ZLER0016 WITH SELECTION-TABLE GT_STAB
*              VIA SELECTION-SCREEN
                   AND RETURN.
 ENDIF.
  PERFORM GET_IV_NO USING GT_HGOD-MBLNR
                          GT_HGOD-MJAHR
                 CHANGING GT_HGOD-IV_NO.

  "취소하면 통문번호 Clear 하지 않을까?
  MODIFY GT_HGOD TRANSPORTING IV_NO WHERE IV_NO = GS_GOUT-IV_NO.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CCGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CCGO.

  "통문증 취소(단일 라인 Only)

  CLEAR : GS_GOUT.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '취소할 항목을 선택하세요.'(M14).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HGOD INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  IF GT_HGOD-IV_NO IS INITIAL.
    MESSAGE S033 DISPLAY LIKE 'E'. "취소할 통문증이 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF P_BUKRS = GC_6000.
   SELECT SINGLE IV_NO
                IV_DATE
                OUT_YN
    FROM ZGTMMT4500 INTO CORRESPONDING FIELDS OF GS_GOUT
   WHERE IV_NO        = GT_HGOD-IV_NO
     AND IV_CANCEL_YN = SPACE.
  ELSE.
  SELECT SINGLE IV_NO
                IV_DATE
                OUT_YN
    FROM ZLET0005 INTO CORRESPONDING FIELDS OF GS_GOUT
   WHERE IV_NO        = GT_HGOD-IV_NO
     AND IV_CANCEL_YN = SPACE.
  ENDIF.
  IF GS_GOUT-OUT_YN = GC_X.
    MESSAGE S041 DISPLAY LIKE 'E'. "통문이 완료되어 취소할 수 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCGI.

  CLEAR : GV_ERR, GS_PRXX.

  PERFORM CHECK_CGI.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_CGI.
  GS_PRXX-BUDAT = GT_HGOD-BUDAT.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CGI.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '취소할 항목을 선택하세요.'(M14).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HGOD INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

* IF GT_HGOD-MBLNR IS INITIAL.
*   MESSAGE S033 DISPLAY LIKE 'E'. "취소할 자재문서가 없습니다.
*   GV_ERR = GC_X. EXIT.
* ENDIF.

  IF GT_HGOD-IV_NO IS NOT INITIAL.
    MESSAGE S034 DISPLAY LIKE 'E'. "통문증부터 취소하세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YCGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YCGI.

  CLEAR : GS_MHDRT, GT_RTN[].

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GT_HGOD-MBLNR
      MATDOCUMENTYEAR     = GT_HGOD-MJAHR
      GOODSMVT_PSTNG_DATE = GS_PRXX-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = GS_MHDRT
    TABLES
      RETURN              = GT_RTN.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    PERFORM UPDATE_ZGTMMT4110.
    PERFORM SET_CGI_TAG.

    PERFORM SEND_WMS. "추가(SJM 25.06.11)

    PERFORM PRCS_REFR. "Refresh
    MESSAGE S035. "출고 취소했습니다.
  ELSE.
    PERFORM BAPI_ROLLBACK.
    PERFORM SET_BAPI_ERR_MSG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTMMT4110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTMMT4110.

  "출고취소 성공시 ZGTMMT4110 자재문서/연도 Clear(SJM 25.02.27)

  UPDATE ZGTMMT4110 SET MJAHR = SPACE
                        MBLNR = SPACE
                  WHERE MBLNR = GT_HGOD-MBLNR
                    AND MJAHR = GT_HGOD-MJAHR.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGI_TAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CGI_TAG.

  "꼬리표 로직 추가(SJM 25.02.27)

  "취소 대상 원본 자재문서 정보 조회
  SELECT WERKS,
         MATNR,
         CHARG,
         SGTXT AS TAGNR,
         MEINS,
         MENGE,
         ERFMG
    FROM MATDOC
    INTO TABLE @DATA(LT_MDOC)
   WHERE MJAHR = @GT_HGOD-MJAHR
     AND MBLNR = @GT_HGOD-MBLNR
     AND SOBKZ = @SPACE.

  CHECK LT_MDOC[] IS NOT INITIAL.
  SORT LT_MDOC BY WERKS MATNR CHARG TAGNR.

  GT_TAG[] = CORRESPONDING #( LT_MDOC[] ).
  PERFORM GET_TAG.

  CHECK GT_TAG[] IS NOT INITIAL.

  "Update ZPPT0001(꼬리표)
  LOOP AT GT_TAG.
    READ TABLE LT_MDOC INTO DATA(LS_MDOC)
                       WITH KEY WERKS = GT_TAG-WERKS
                                MATNR = GT_TAG-MATNR
                                CHARG = GT_TAG-CHARG
                                TAGNR = GT_TAG-TAGNR
                                BINARY SEARCH.
    CHECK SY-SUBRC = 0.

    GV_QTY = COND #( WHEN GT_TAG-MEINS = LS_MDOC-MEINS THEN LS_MDOC-MENGE
                                                       ELSE LS_MDOC-ERFMG ).

    GV_REQTY = GT_TAG-REMAIN + GV_QTY.
    GV_GIF   = GC_N.

    PERFORM UPDATE_ZPPT0001.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_APPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_APPV.

  CLEAR : GV_PRXX.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '승인대상을 선택하세요.'(M15).
  CHECK GV_ERR IS INITIAL.

*--> [CHM2603-00206] 불출 요청자 = 승인자 처리 불가
  LOOP AT GT_ROW INTO GS_ROW.
    " 1건만 존재함
    READ TABLE GT_HAPM INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HAPM-ERNAM = SY-UNAME.
      GV_ERR = GC_X.
      "--> 현재 MESSAGE 타 CTS랑 묶여있어서 별수 없이 하드코딩
      MESSAGE S000 WITH '요청자=승인자 처리 불가합니다.' DISPLAY LIKE 'E'.
    ENDIF.

*    IF SY-UNAME = '20220164' OR SY-UNAME = 'ZLSGMM3'. "* TEST
*    ELSE.
*      IF GT_HAPM-ERNAM = SY-UNAME.
*        GV_ERR = GC_X.
*        "--> 현재 MESSAGE 타 CTS랑 묶여있어서 별수 없이 하드코딩
*        MESSAGE S000 WITH '요청자=승인자 처리 불가합니다.' DISPLAY LIKE 'E'.
*      ENDIF.
*    ENDIF.
  ENDLOOP.
  CHECK GV_ERR IS INITIAL.
*<-- [CHM2603-00206] 불출 요청자 = 승인자 처리 불가

  GV_PRXX = GC_APV.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_XAPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_XAPV USING PV_APPSTAT
                     PV_PRCNAME.

  IF PV_APPSTAT = GC_R.
    PERFORM CHECK_REMARK USING GS_PRXX-REJRES.
    CHECK GV_ERR IS INITIAL.
  ENDIF.

  CLEAR : GT_AHDR[], GT_APPV[].

  PERFORM SET_TIMESTAMP USING ' ' 'X'.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HAPM INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CLEAR : GT_AHDR.
    MOVE-CORRESPONDING GT_HAPM TO GT_AHDR.
    MOVE-CORRESPONDING GS_CHNG TO GT_AHDR.

    GT_AHDR-APPSTAT = PV_APPSTAT.

    IF PV_APPSTAT <> GC_A.
      GT_AHDR-REJRES = GS_PRXX-REJRES.
      GT_AHDR-RETC   = GS_PRXX-REMARK.
    ENDIF.

    APPEND GT_AHDR.

    GT_APPV-USERID = GT_HAPM-ERNAM.
    COLLECT GT_APPV.
  ENDLOOP.

  MODIFY ZGTMMT4110 FROM TABLE GT_AHDR.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM PRCS_REFR. "Refresh
    MESSAGE S036 WITH PV_PRCNAME. "& 성공했습니다.

    PERFORM SEND_MAIL.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S037 WITH PV_PRCNAME DISPLAY LIKE 'E'. "& 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REJT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REJT.

  CLEAR : GV_PRXX, GS_PRXX.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '반려대상을 선택하세요.'(M16).
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_REJ.
* GS_PRXX-REJRES = 999.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CCAP.

  CLEAR : GV_ERR.

  PERFORM CHECK_CAP.
  CHECK GV_ERR IS INITIAL.

  GV_PRXX = GC_CAP.

  PERFORM CALL_SCREEN USING 500 10 5
                                80 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CAP.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X'
                                  '상신/확정취소할 품의 정보를 선택하세요.'(M17).
  CHECK GV_ERR IS INITIAL.

  READ TABLE GT_HAPD INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  "Check 기준 변경(SJM 25.02.27)
  IF ( GT_HAPD-APPSTAT = GC_A AND GT_HAPD-MBLNR IS NOT INITIAL )
  OR ( GT_HAPD-APPSTAT = GC_R ).
    MESSAGE S038 DISPLAY LIKE 'E'. "반려된 상신 및 이미 출고 처리된 품의 정보는 취소할 수 없습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.
* IF GT_HAPD-APPSTAT IS NOT INITIAL.
*   MESSAGE S038 DISPLAY LIKE 'E'. "이미 승인(반려)처리된 품의 정보는 취소할 수 없습니다.
*   GV_ERR = GC_X. EXIT.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_YCAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_YCAP.

  DELETE FROM ZGTMMT4112 WHERE ZGUID = GT_HAPD-ZGUID.
  DELETE FROM ZGTMMT4111 WHERE ZGUID = GT_HAPD-ZGUID.
  DELETE FROM ZGTMMT4110 WHERE ZGUID = GT_HAPD-ZGUID.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM PRCS_REFR. "재조회(H/I)
    MESSAGE S036 WITH '상신/확정취소'. "& 성공했습니다.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S037 WITH '상신/확정취소' DISPLAY LIKE 'E'. "& 실패했습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_WMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_WMS.

  RANGES : LR_MJAHR FOR MKPF-MJAHR,
           LR_MBLNR FOR MKPF-MBLNR.


  "출고(취소)정보 전송 대상 저장위치(WMS 활용 저장위치)인 경우, 출고(취소) 처리후 I/F(SJM 25.06.11)

  CHECK GV_ZMODE = GC_OD.

  LR_MJAHR[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GS_MHDRT-DOC_YEAR ) ).
  LR_MBLNR[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GS_MHDRT-MAT_DOC ) ).

  SUBMIT ZGTMMR4917 WITH P_ILOG   = SPACE
                    WITH P_SEND   = GC_X
                    WITH P_IFSYT  = GC_KPCM
                    WITH S_MJAHR IN LR_MJAHR
                    WITH S_MBLNR IN LR_MBLNR
                    WITH P_BAT    = GC_X
*                    VIA SELECTION-SCREEN
                     AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_xapv_mail2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_XAPV_MAIL2  USING    VALUE(PV_PRCNM).

  DATA : LV_PREIS      TYPE ZGTMM_CV_SCAPPLIST-PREIS,
         LV_MATNR      TYPE ZGTMM_CV_SCAPPDETAIL-MATNR,
         LV_MAKTX      TYPE ZGTMM_CV_SCAPPDETAIL-MAKTX,
         LV_SCQTY      TYPE ZGTMM_CV_SCAPPDETAIL-SCQTY, "외주재고량
         LV_MEINS      TYPE ZGTMM_CV_SCAPPDETAIL-MEINS,
         LV_OSCQTY(20) TYPE C, "외주재고량
         LV_SCVAL      TYPE ZGTMMT4111-SCVAL, "외주재고금액
         LV_LIFNR      TYPE ZGTMMT4110-LIFNR,
         LV_NAME1      LIKE LFA1-NAME1,
         LV_OPREIS(20) TYPE C,
         LV_OSCVAL(20) TYPE C,
         LV_ISVAL(20)  TYPE C,
         LV_ORES(50)   TYPE C,
         LV_ERNAM      TYPE ADRP-NAME_LAST,
         LV_AENAM      TYPE ADRP-NAME_LAST.
  DATA :        GT_VALUES TYPE VRM_VALUES WITH HEADER LINE.

  DATA : LT_VALUES_TAB  LIKE DD07V OCCURS 0 WITH HEADER LINE.

  CLEAR : LV_MATNR, LV_MAKTX, LV_PREIS, LV_SCQTY, LV_SCVAL,
          GT_MTXT2,GT_MTXT2[], LV_NAME1, LV_AENAM, LV_ERNAM.

  "불출 알림 메일 대상자
  SELECT PERSNUMBER, MAIL
    FROM ZGTMMT4115
    INTO CORRESPONDING FIELDS OF TABLE @GT_APPV2.

  "USER ID ALPHA OUT
  LOOP AT GT_APPV2.
    GT_APPV2-PERSNUMBER = |{ GT_APPV2-PERSNUMBER ALPHA = OUT }|.
  ENDLOOP.

  LOOP AT GT_AHDR.

    "보증금액
    SELECT H~*
      FROM ZGTMM_CV_SCSTOCKDAILYH( P_STARTDATE  = @SY-DATUM,
                                   P_ENDDATE    = @SY-DATUM,
                                   P_PERIODTYPE = @GC_D ) AS H
     WHERE BUKRS     = @P_BUKRS
       AND SUPPLIER = @GT_AHDR-LIFNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST.

    READ TABLE GT_HLIST INDEX 1.

    IF SY-SUBRC = 0.
      LV_PREIS = GT_HLIST-PREIS.
    ENDIF.

    SELECT SINGLE MATNR, MAKTX, SCQTY, SCVAL, MEINS
      FROM ZGTMM_CV_SCAPPDETAIL
      INTO (@LV_MATNR, @LV_MAKTX, @LV_SCQTY , @LV_SCVAL, @LV_MEINS)
      WHERE ZGUID = @GT_AHDR-ZGUID.

    SELECT SINGLE NAME1
      FROM LFA1
      INTO (@LV_NAME1)
      WHERE LIFNR = @GT_AHDR-LIFNR.

    WRITE LV_PREIS TO LV_OPREIS CURRENCY 'KRW'.  "보증보험금액
    WRITE LV_SCVAL TO LV_OSCVAL CURRENCY 'KRW'.  "외주재고액
    WRITE GT_AHDR-ISVAL TO LV_ISVAL CURRENCY 'KRW'. "출고예정액
    WRITE LV_SCQTY TO LV_OSCQTY UNIT LV_MEINS.

    CONDENSE LV_OPREIS NO-GAPS.
    CONDENSE LV_OSCVAL NO-GAPS.
    CONDENSE LV_OSCQTY NO-GAPS.

    LV_lifnr = |{ GT_AHDR-LIFNR ALPHA = OUT }|.
    LV_MATNR = |{ LV_MATNR ALPHA = OUT }|.

    "요청자 NAME
    SELECT SINGLE B~NAME_LAST INTO LV_ERNAM
      FROM USR21 AS A INNER JOIN ADRP AS B
      ON A~PERSNUMBER = B~PERSNUMBER
      WHERE A~BNAME = GT_AHDR-ERNAM.

    "승인자 NAME
    SELECT SINGLE B~NAME_LAST INTO LV_AENAM
      FROM USR21 AS A INNER JOIN ADRP AS B
      ON A~PERSNUMBER = B~PERSNUMBER
      WHERE A~BNAME = GT_AHDR-AENAM.


    "초과사유 text
    IF GT_AHDR-ORES IS NOT INITIAL.
      CALL FUNCTION 'GET_DOMAIN_VALUES'
        EXPORTING
          DOMNAME    = 'ZGTDMMRES'
        TABLES
          VALUES_TAB = LT_VALUES_TAB.

      LOOP AT LT_VALUES_TAB WHERE DOMVALUE_L = GT_AHDR-ORES.
        CLEAR GT_VALUES.
        GT_VALUES-KEY  = LT_VALUES_TAB-DOMVALUE_L.
        GT_VALUES-TEXT = LT_VALUES_TAB-DDTEXT.
        APPEND GT_VALUES.
      ENDLOOP.
    ENDIF.

    "메일전문
    GV_TEXT2 = '[사급자재 초과불출 알림]'.

    CONCATENATE '업체코드 :　' LV_LIFNR '　/　업체명 :　' LV_NAME1 '　/　보증보험금액 :　' LV_OPREIS INTO WA_MTXT2.
    APPEND WA_MTXT2 TO GT_MTXT2.

    CLEAR WA_MTXT2.
    CONCATENATE '자재코드 :　' LV_MATNR '　/　자재명 :　' LV_MAKTX '　/　PLANT :　' P_WERKS INTO WA_MTXT2.
    APPEND WA_MTXT2 TO GT_MTXT2.

    CLEAR WA_MTXT2.
    CONCATENATE '외주재고량 :　' LV_OSCQTY '　/　외주재고액 :　' LV_OSCVAL'　/　출고예정액 :　' LV_ISVAL INTO WA_MTXT2.
    APPEND WA_MTXT2 TO GT_MTXT2.

    CLEAR WA_MTXT2.
    CONCATENATE '입력자 :　' LV_ERNAM '('GT_AHDR-ERNAM')　/　승인자 :　' LV_AENAM '('GT_AHDR-AENAM')　/　승인일 :　' GT_AHDR-AEDAT_LOCAL INTO WA_MTXT2.
    APPEND WA_MTXT2 TO GT_MTXT2.

    CLEAR WA_MTXT2.
    CONCATENATE '초과사유 :　'LT_VALUES_TAB-DDTEXT'　/　비고 :　' GT_AHDR-OETC INTO WA_MTXT2.
    APPEND WA_MTXT2 TO GT_MTXT2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OVER_SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM OVER_SET_VALUES CHANGING PV_OVVAL
                              PV_GAP
                              PV_CNT.

* GS_HDR-PREIS : 보증금액
* GS_HDR-SCVAL : 외주재고액
* GS_HDR-ISVAL : 출고예정액 (=불출할 사급자재금액)
* GS_HDR-IAVAL : 출고가용금액 (=보증금액 - (외주재고액 + 출고예정액)

  "--> 1. 사급자재 불출 및 담보 초과금액 계산
  "*** 사급자재 불출금액 = 외주재고액 + 출고예정액
  "*** 담보 초과금액 = 사급자재 불출금액 - 보증(담보)금액

  "--> 사급자재 불출금액
  PV_OVVAL = GS_HDR-SCVAL + GS_HDR-ISVAL.
  "--> 담보 초과금액
  PV_GAP = PV_OVVAL - GS_HDR-PREIS.

  "--> 2. 초과횟수 계산
  DATA : LV_DATLO(8).
  CONCATENATE SY-DATLO+0(4) '0101' INTO LV_DATLO.
  CLEAR : GT_HLIST_OLD, GT_HLIST_OLD[].

  "--> TEST
*  LV_DATLO = '20250101'.

*  IF SY-UNAME = 'ZLSGMM3'.
*    SELECT *
*      FROM ZGTMM_CV_SCAPPLIST
*      INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST_OLD
*     WHERE BUKRS = @P_BUKRS
*       AND WERKS = @P_WERKS
*       AND ZGITYPE IN ('A','E')
*       AND LIFNR IN @S_LIFNR
*       AND BUDAT >= @LV_DATLO.
*  ELSE.
*    SELECT *
*      FROM ZGTMM_CV_SCAPPLIST
*      INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST_OLD
*     WHERE BUKRS = @P_BUKRS
*       AND WERKS = @P_WERKS
*       AND ZGITYPE IN ('A','E')
*       AND LIFNR IN @S_LIFNR
*       AND BUDAT >= @LV_DATLO
*       AND ERNAM = @SY-UNAME.
*  ENDIF.

  SELECT *
    FROM ZGTMM_CV_SCAPPLIST
    INTO CORRESPONDING FIELDS OF TABLE @GT_HLIST_OLD
   WHERE BUKRS = @P_BUKRS
     AND WERKS = @P_WERKS
     AND ZGITYPE IN ('A','E')
     AND LIFNR IN @S_LIFNR
     AND BUDAT >= @LV_DATLO
     AND ERNAM = @SY-UNAME.

  PV_CNT = LINES( GT_HLIST_OLD ).

ENDFORM.
