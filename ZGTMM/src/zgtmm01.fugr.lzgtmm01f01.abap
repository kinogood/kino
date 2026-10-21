*----------------------------------------------------------------------*
***INCLUDE LZGTMM01F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_COM_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_COM_LOG USING PV_TYPE
                       PV_ZIFNO
                       PV_ZSTAT
                       PV_MESSAGE.

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_9000, GT_9000[].

      GET TIME STAMP FIELD GT_9000-ZIFKEY.

      GT_9000-ZIFNO     = PV_ZIFNO.
      GT_9000-SYSTEM_ID = GV_SYSTEM_ID.
      GT_9000-IFDAT     = SY-DATLO.
      GT_9000-IFTIM     = SY-TIMLO.
      GT_9000-IFNAM     = SY-UNAME.

      MODIFY ZGTMMT9000 FROM GT_9000.

    WHEN 'E'. "End
      UPDATE ZGTMMT9000 SET ZSTAT       = PV_ZSTAT
                            MESSAGE     = PV_MESSAGE
                            ERDAT       = SY-DATUM
                            ERDAT_LOCAL = SY-DATLO
                            ERTIM       = SY-UZEIT
                            ERTIM_LOCAL = SY-TIMLO
                            ERNAM       = SY-UNAME
                      WHERE ZIFNO       = GT_9000-ZIFNO
                        AND ZIFKEY      = GT_9000-ZIFKEY
                        AND SYSTEM_ID   = GT_9000-SYSTEM_ID.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MD_CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZTISCCIT_MATNR
*&      --> GT_I10_MEINS
*&      --> P_
*&      <-- GT_I10_GRMNG
*&---------------------------------------------------------------------*
FORM MD_CONVERT_MATERIAL_UNIT USING PV_MATNR
                                    PV_I_MEINS
                                    PV_O_MEINS
                           CHANGING PV_MENGE.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_I_MEINS
      I_OUT_ME             = PV_O_MEINS
      I_MENGE              = PV_MENGE
    IMPORTING
      E_MENGE              = PV_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_ZTISCCIT_MATNR
*&---------------------------------------------------------------------*
FORM GET_DISPO USING PV_WERKS
                     PV_MATNR.

  CLEAR : GV_DISPO.

  SELECT SINGLE DISPO
    FROM MARC INTO GV_DISPO
   WHERE WERKS = PV_WERKS
     AND MATNR = PV_MATNR
     AND LVORM = SPACE.

  IF SY-SUBRC <>  0.
    GV_DISPO = GC_AU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_HEAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CGR_HEAD.

  CLEAR : GS_MHDR,   GS_MCOD,   GS_MHDRT,
          GT_MITM[], GT_MSRN[], GT_RTN[].

  GS_MHDR-PSTNG_DATE = GT_I12-LFDAT. "전기일
  GS_MHDR-DOC_DATE   = GT_I12-LFDAT. "증빙일
  GS_MHDR-REF_DOC_NO = GT_I12-VBELN.

  GS_MCOD-GM_CODE = GC_01. "구매입고

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CGR_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I13
*&---------------------------------------------------------------------*
FORM CREATE_CGR_BATCH USING PS_ITEM.

  DATA : LT_RTN TYPE TABLE OF BAPIRET2.

  DATA : LV_FACTOR,
         LS_ATTR   TYPE BAPIBATCHATT,
         LS_CTRL   LIKE BAPIBATCHCTRL.


  CLEAR : GS_PBV.
  MOVE-CORRESPONDING PS_ITEM TO GS_PBV.

  SELECT SINGLE MANDT
    FROM MARA INTO @SY-MANDT
   WHERE MATNR = @GS_PBV-MATNR
     AND KZWSM = @GC_B
     AND DPCBT = @GC_A.

  CHECK SY-SUBRC = 0.
  LV_FACTOR = GC_X. "왜???????? 확인?

  "Factor 배치
  SELECT SINGLE MANDT
    FROM MCHA INTO @SY-MANDT
   WHERE MATNR = @GS_PBV-MATNR
     AND WERKS = @GS_PBV-WERKS
     AND CHARG = @GS_PBV-CHARG.

  IF SY-SUBRC <> 0.
    "배치가 없는 경우 생성
    LS_ATTR-STATUSKEY  = GC_1.
    LS_CTRL-DOCLASSIFY = GC_X.

    "클래스번호
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL       = GS_PBV-MATNR
        PLANT          = GS_PBV-WERKS
        CLASSTYPE      = '023'
      IMPORTING
        CLASS          = LS_CTRL-CLASS_NUM
      EXCEPTIONS
        NO_CLASS_FOUND = 1
        OTHERS         = 2.

    CALL FUNCTION 'BAPI_BATCH_CREATE'
      EXPORTING
        MATERIAL             = CONV MATNR18( GS_PBV-MATNR )
        BATCH                = GS_PBV-CHARG
        PLANT                = GS_PBV-WERKS
        BATCHATTRIBUTES      = LS_ATTR
        BATCHCONTROLFIELDS   = LS_CTRL
        BATCHSTORAGELOCATION = GS_PBV-LGORT
      TABLES
        RETURN               = LT_RTN.

    IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ).
      PERFORM BAPI_ROLLBACK.
    ELSE.
      PERFORM BAPI_COMMIT.
    ENDIF.
  ENDIF.

  "배치 특성 업데이트
  PERFORM UPDATE_PO_BATCH_CHARACTERISTIC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_PO_BATCH_CHARACTERISTIC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_PO_BATCH_CHARACTERISTIC.

  DATA : LS_RETURN   TYPE BAPIRET2_T.
  DATA : LT_CHARLIST LIKE E1CUVAL OCCURS 0 WITH HEADER LINE.
  DATA : LV_VALUE_3(16) TYPE P DECIMALS 3.


  "특성값 가져오기........................
  CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
    EXPORTING
      EBELN                        = GS_PBV-EBELN
      EBELP                        = GS_PBV-EBELP
    IMPORTING
      ET_RETURN                    = LS_RETURN
    TABLES
      T_E1CUVAL                    = LT_CHARLIST
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INTERNAL_ERROR               = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      OTHERS                       = 4.

  CHECK SY-SUBRC = 0.

  LOOP AT LT_CHARLIST.
    CASE LT_CHARLIST-CHARC.
      WHEN 'SAP_MILLCA_LENGTH'.          "조장(기본단위)
        PERFORM CHAR_FLTP_CONVERSION USING LT_CHARLIST-VALUE
                                  CHANGING LV_VALUE_3.
*     WHEN 'SAP_MILLCA_LENGTH_SUB'.      "Ind. 길이(기본 단위 "M") -> 미사용인듯!
*       PERFORM char_fltp_conversion USING lt_charlist-value
*                                  CHANGING lv_value_4.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  IF ( LV_VALUE_3 > 0 ).
    DATA(LV_CHOJANG) = GS_PBV-LFIMG MOD LV_VALUE_3.
    IF LV_CHOJANG <> 0.
      LV_VALUE_3 = GS_PBV-LFIMG.
    ENDIF.

    PERFORM MSC2N_BDC_CST USING GS_PBV-MATNR
                                GS_PBV-CHARG
                                GS_PBV-WERKS
                                LV_VALUE_3.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GOODSMVT_CGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_9082
*&      --> P_
*&---------------------------------------------------------------------*
FORM GOODSMVT_CGR_RCV TABLES PT_90X2 STRUCTURE ZGTMMT9082
                       USING PV_TYPE.

  PERFORM BAPI_GOODSMVT_CREATE.

  IF GS_MHDRT IS NOT INITIAL.
    PERFORM BAPI_COMMIT.
    PERFORM RTN_SCCGR_RCV TABLES PT_90X2 USING 'S'.

    CASE PV_TYPE.
      WHEN 'S'.
        PERFORM MODIFY_ZPPT0001_SCGR.
      WHEN 'N'.
*--> 지중/소재 MOM 구분
**** OTHERS는 현재 없기에 나중에 구현
        CASE GV_SYSTEM_ID.
          WHEN 'KPCM' OR 'KPMS'. "--> 지중
            PERFORM MODIFY_ZPPT0001_GR.
          WHEN 'KSCM'. "--> 소재 SCR
            PERFORM MODIFY_ZPPT0001_GR_SCR.
          WHEN OTHERS.

        ENDCASE.
*<-- 지중/소재 MOM 구분
    ENDCASE.

  ELSE.
    PERFORM BAPI_ROLLBACK.

    READ TABLE GT_RTN WITH KEY TYPE = GC_A.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RTN WITH KEY TYPE = GC_E.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RTN WITH KEY TYPE = GC_W.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RTN WITH KEY TYPE = GC_I.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RTN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      PERFORM RTN_CGR_RCV TABLES PT_90X2 USING 'E'.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CREATE.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GS_MHDR
      GOODSMVT_CODE         = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET      = GS_MHDRT
*     MATERIALDOCUMENT      = GS_MHDRT-MAT_DOC
*     MATDOCUMENTYEAR       = GS_MHDRT-DOC_YEAR
    TABLES
      GOODSMVT_ITEM         = GT_MITM
      GOODSMVT_SERIALNUMBER = GT_MSRN
      RETURN                = GT_RTN
    EXCEPTIONS
      OTHERS                = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ZTITGRK_MBLNR
*&      --> LT_ZTITGRK_MJAHR
*&      --> GT_I10_BUDAT
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CANCEL USING PV_MBLNR
                                PV_MJAHR
                                PV_BUDAT.

  CLEAR : GS_CHDR, GS_MHDRT, GT_RTN[].

  GS_CHDR-MAT_DOC    = PV_MBLNR.
  GS_CHDR-DOC_YEAR   = PV_MJAHR.
  GS_CHDR-PSTNG_DATE = PV_BUDAT.


  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_CHDR-MAT_DOC
      MATDOCUMENTYEAR     = GS_CHDR-DOC_YEAR
      GOODSMVT_PSTNG_DATE = GS_CHDR-PSTNG_DATE
    IMPORTING
      GOODSMVT_HEADRET    = GS_MHDRT
    TABLES
      RETURN              = GT_RTN.

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
*& Form RTN_RST_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I17
*&---------------------------------------------------------------------*
FORM RTN_RST_MSG TABLES PT_RST.

  DATA : LV_SUC TYPE I,
         LV_ERR TYPE I,
         LV_TOT TYPE I.


  CLEAR : GV_ZSTAT, GV_MESSAGE.

  LOOP AT PT_RST.
    ASSIGN COMPONENT 'ZRESULT' OF STRUCTURE PT_RST TO FIELD-SYMBOL(<LFS_RST>).

    CASE <LFS_RST>.
      WHEN 'S'.
        LV_SUC += 1.
      WHEN OTHERS.
        LV_ERR += 1.
    ENDCASE.

    LV_TOT += 1.
  ENDLOOP.

  IF LV_ERR IS NOT INITIAL.
    GV_ZSTAT = GC_E.
    "전체 데이터: &1 성공: &2 실패: &3
    MESSAGE S073(ZGTMM01) WITH LV_TOT LV_SUC LV_ERR INTO GV_MESSAGE.
*   GV_MESSAGE = `전체 데이터: ` && LV_TOT
*             && ` 성공: `     && LV_SUC  "&& '/'
*             && ` 실패: `     && LV_ERR.
  ELSE.
    GV_ZSTAT = GC_S.
    MESSAGE S074(ZGTMM01) WITH LV_SUC INTO GV_MESSAGE. "성공: &
*   GV_MESSAGE = `성공: ` && LV_SUC.
  ENDIF.

  PERFORM SET_COM_LOG USING 'E' ' ' GV_ZSTAT GV_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I13_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_INPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_MATNR
    IMPORTING
      OUTPUT       = PV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHAR_FLTP_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHARLIST_VALUE
*&      <-- LV_VALUE_3
*&---------------------------------------------------------------------*
FORM CHAR_FLTP_CONVERSION USING PV_VALUE_S
                       CHANGING PV_VALUE_P.

  DATA : LV_FLTP LIKE RSCVP-VALU1.


  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      STRING          = PV_VALUE_S
    IMPORTING
      FLSTR           = LV_FLTP
    EXCEPTIONS
      STRING_NOT_FLTP = 1.

  PV_VALUE_P = LV_FLTP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MSC2N_BDC_CST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I13_MATNR
*&      --> GT_I13_CHARG
*&      --> GT_I13_WERKS
*&      --> LV_VALUE_3
*&---------------------------------------------------------------------*
FORM MSC2N_BDC_CST USING PV_MATNR
                         PV_CHARG
                         PV_WERKS
                         PV_LFIMG.

  DATA : LV_LFIMG(18).


  CLEAR : GT_BDCD[], GT_BDCM[], GS_PARA.

  LV_LFIMG = PV_LFIMG.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'       '1000',
                          ' '  'BDC_OKCODE'     '=ENTR',
                          ' '  'DFBATCH-MATNR'  PV_MATNR,
                          ' '  'DFBATCH-CHARG'  PV_CHARG,
                          ' '  'DFBATCH-WERKS'  PV_WERKS.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'       '1000',
                          ' '  'BDC_OKCODE'     '=CLAS'.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'       '1000',
                          ' '  'BDC_OKCODE'     '=AUFS'.

  PERFORM SET_BDC USING : 'X'  'SAPLCLHU'             '0600',
                          ' '  'BDC_OKCODE'           '=RETURN',
                          ' '  'CLHP-CR_STATUS_TEXT'  '조장(기본단위)'(T04),
                          ' '  'D0600_MAX_HITS'       '1'.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'         '1000',
                          ' '  'BDC_OKCODE'       '/00',
                          ' '  'RCTMS-MWERT(01)'  LV_LFIMG.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'         '1000',
                          ' '  'BDC_OKCODE'       '=AUFS'.

  PERFORM SET_BDC USING : 'X'  'SAPLCLHU'             '0600',
                          ' '  'BDC_OKCODE'           '=RETURN',
                          ' '  'CLHP-CR_STATUS_TEXT'  'Ind. 길이(기본 단위 "M")'(T05),
                          ' '  'D0600_MAX_HITS'       '1'.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'         '1000',
                          ' '  'BDC_OKCODE'       '/00',
                          ' '  'RCTMS-MWERT(01)'  LV_LFIMG.

  PERFORM SET_BDC USING : 'X'  'SAPLCHRG'         '1000',
                          ' '  'BDC_OKCODE'       '=SAVE'.

  GS_PARA-DISMODE  = GC_N.   "처리모드
  GS_PARA-UPDMODE  = GC_S.   "갱신세션
  GS_PARA-CATTMODE = GC_A.   "CATT모드
  GS_PARA-DEFSIZE  = ' '.    "기본화면
  GS_PARA-RACOMMIT = GC_X.   "COMMIT 이후 지속
  GS_PARA-NOBINPT  = GC_X.   "BI세션

  CALL TRANSACTION 'MSC2N' USING GT_BDCD
                    OPTIONS FROM GS_PARA
                   MESSAGES INTO GT_BDCM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_BDC USING PV_DYNBEGIN
                   PV_FNAM
                   PV_FVAL.

  CLEAR : GT_BDCD.

  IF PV_DYNBEGIN = GC_X.
    GT_BDCD-PROGRAM  = PV_FNAM.
    GT_BDCD-DYNPRO   = PV_FVAL.
    GT_BDCD-DYNBEGIN = GC_X.
  ELSE.
    GT_BDCD-FNAM     = PV_FNAM.
    GT_BDCD-FVAL     = PV_FVAL.
  ENDIF.

  APPEND GT_BDCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_CGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_9082
*&      --> P_
*&---------------------------------------------------------------------*
FORM RTN_CGR_RCV TABLES PT_90X2 STRUCTURE ZGTMMT9082
                  USING PV_RST.

  DATA : LV_MSG TYPE BAPI_MSG.


  CLEAR : GT_I18, PT_90X2.

  CASE PV_RST.
    WHEN 'S'.
      GT_I18-MBLNR = GS_MHDRT-MAT_DOC.
      GT_I18-MJAHR = GS_MHDRT-DOC_YEAR.

      CONCATENATE 'Material Doc.'(M17)
                  GS_MHDRT-MAT_DOC
                  GS_MHDRT-DOC_YEAR
                  'was created.'(M18)
             INTO LV_MSG SEPARATED BY SPACE.

    WHEN 'E'.
      LV_MSG = GT_RTN-MESSAGE && '(4)'.

  ENDCASE.

  PERFORM SET_CGR_RCV TABLES PT_90X2
                       USING PV_RST
                             LV_MSG.

  PERFORM UPD_XGR_LOT TABLES GT_T20  "추가(SJM 25.06.10)
                             GT_I20
                       USING PV_RST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CGR_RCV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_90X2
*&      --> PV_RST
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SET_CGR_RCV TABLES PT_90X2 STRUCTURE ZGTMMT9082
                  USING PV_RST
                        PV_MSG.

  GT_I18-VBELN   = GT_I12-VBELN.
  GT_I18-ZRESULT = PV_RST.
  GT_I18-MESSAGE = PV_MSG.

  "Log table
  MOVE-CORRESPONDING GT_I18 TO PT_90X2.
  PT_90X2-ZIFKEY = GT_9000-ZIFKEY.

  IF GT_I18-MBLNR IS NOT INITIAL.
    GT_I18-MBLNR = |{ GT_I18-MBLNR ALPHA = OUT }|.
  ENDIF.

  APPEND : GT_I18, PT_90X2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_GETDETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_MBLNR
*&      --> GV_MJAHR
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_GETDETAIL USING PV_MBLNR
                                   PV_MJAHR.

  CLEAR : GT_DITM[], GT_RTN[].

  CALL FUNCTION 'BAPI_GOODSMVT_GETDETAIL'
    EXPORTING
      MATERIALDOCUMENT = PV_MBLNR
      MATDOCUMENTYEAR  = PV_MJAHR
    TABLES
      GOODSMVT_ITEMS   = GT_DITM
      RETURN           = GT_RTN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EAI_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM SET_EAI_MSG USING PV_TYPE
              CHANGING PV_ZRESULT
                       PV_MESSAGE.

  CASE PV_TYPE.
    WHEN 'S'.
      PV_ZRESULT = GC_00.
      PV_MESSAGE = '처리가 완료되었습니다.'(M19).
    WHEN 'E'.
      PV_ZRESULT = GC_01.
      PV_MESSAGE = '처리시 에러가 발생했습니다.'(M20).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XGR_LOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_T20
*&      --> GT_I13
*&      --> GV_LINEID
*&---------------------------------------------------------------------*
FORM SET_XGR_LOT TABLES PT_T2X    " Log Item
                  USING PS_ITM    "Item
                        PV_LINE.

  CLEAR : PT_T2X.
  MOVE-CORRESPONDING PS_ITM TO PT_T2X.

  ASSIGN COMPONENT 'ZEILE' OF STRUCTURE PT_T2X TO FIELD-SYMBOL(<LFS_ZEILE>).
  <LFS_ZEILE> = PV_LINE.

  APPEND PT_T2X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPD_XGR_LOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_T20
*&      --> GT_I20
*&      --> PV_RST
*&---------------------------------------------------------------------*
FORM UPD_XGR_LOT TABLES PT_T2X
                        PT_I2X
                  USING PV_RST.

  "자재문서 및 검사 Lot정보 Update

  "입고 성공시 검사 Lot 정보 조회
  CLEAR : GT_LOT[].
  IF PV_RST = GC_S.
    SELECT * FROM ZGTMM_CV_GETINSPECTLOT
      INTO CORRESPONDING FIELDS OF TABLE @GT_LOT
     WHERE MJAHR = @GS_MHDRT-DOC_YEAR
       AND MBLNR = @GS_MHDRT-MAT_DOC.

    SORT GT_LOT BY ZEILE.
  ENDIF.

  LOOP AT PT_T2X.
    CLEAR : PT_I2X.
    MOVE-CORRESPONDING PT_T2X TO PT_I2X.

    ASSIGN COMPONENT 'ZEILE' OF STRUCTURE PT_I2X TO FIELD-SYMBOL(<LFS_ZEILE>).

    CASE PV_RST.
      WHEN 'S'.
        READ TABLE GT_LOT WITH KEY ZEILE = <LFS_ZEILE>
                                   BINARY SEARCH.

        IF SY-SUBRC = 0.
          SHIFT GT_LOT-PRUEFLOS LEFT DELETING LEADING '0'.
          MOVE-CORRESPONDING GT_LOT TO PT_I2X.
        ENDIF.

      WHEN 'E'.
        "입고 오류 발생시 검사 Lot 정보 無
        CLEAR : <LFS_ZEILE>.

    ENDCASE.

    APPEND PT_I2X.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_ZGTMMT9250
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_ZGTMMT9250.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GS_ZGTMMT9250-MATNR
    IMPORTING
      OUTPUT = GS_ZGTMMT9250-MATNR.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GS_ZGTMMT9250-UMMAT
    IMPORTING
      OUTPUT = GS_ZGTMMT9250-UMMAT.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      INPUT  = GS_ZGTMMT9250-MEINS
    IMPORTING
      OUTPUT = GS_ZGTMMT9250-MEINS.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ZGTMMT9250-KOSTL
    IMPORTING
      OUTPUT = GS_ZGTMMT9250-KOSTL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_ZGTMMT9250-CO_ORDER
    IMPORTING
      OUTPUT = GS_ZGTMMT9250-CO_ORDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZGTMMT9250_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ZGTMMT9250_DATA .

  IF GS_ZGTMMT9250-ZFLAG = 'P'.

    PERFORM CHECK_PRO_DATA.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ELSE.

    PERFORM CHECK_CANC_DATA.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SCRAP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SCRAP_DATA .

  DATA : LT_SCRAP LIKE TABLE OF GS_SCRAP.
  CLEAR : LT_SCRAP, GS_SCRAP.


*- Scrap 코드
  SELECT SINGLE MATKL, SPART
    INTO @DATA(LS_MARA)
    FROM MARA
    WHERE MATNR = @GS_ZGTMMT9250-MATNR.

  SELECT SINGLE SPGCD
    INTO @DATA(LV_SPGCD)
    FROM ZPPT0107 "SPG 코드
    WHERE WERKS = @GS_ZGTMMT9250-WERKS
     AND  SPART = @LS_MARA-SPART.

  SELECT O~MATNR, A~MEINS,G~LGORT, O~VLDYM
    INTO CORRESPONDING FIELDS OF TABLE @LT_SCRAP
    FROM ZPPT0105 AS O
    INNER JOIN ZPPT0106 AS G
        ON O~MATNR = G~MATNR
       AND O~VLDYM = G~VLDYM
       AND O~WERKS = G~WERKS
    INNER JOIN MARA AS A
        ON O~MATNR = A~MATNR
    UP TO 1 ROWS
    WHERE O~WERKS = @GS_ZGTMMT9250-WERKS    "플랜트
     AND  O~SPGCD = @LV_SPGCD             "SPG
     AND  O~OPGRP = @LS_MARA-MATKL        "공정그룹코드
     AND  O~VLDYM <= @GS_ZGTMMT9250-BUDAT(6)"처리일자
     AND  O~STCAN = 'X'                   "지시자: 처리상태 "폐기"
    ORDER BY O~VLDYM DESCENDING.

  GS_SCRAP = VALUE #( LT_SCRAP[ 1 ] OPTIONAL ).

*& ------------------------------
*   BDC 수행전 CHECK (1차 CHECK)
*& ------------------------------
  IF GS_SCRAP-MATNR IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '유효한 SCRAP자재가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '유효한 SCRAP자재가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.


*- Scrap 수량
  GS_SCRAP-MENGE = GS_ZGTMMT9250-MENGE.
  " SCRAP 수량 구하기 (CONVERSOIN 수량)
  PERFORM CONVERT_MAT_UNIT(ZCOR0180)
                              USING GS_ZGTMMT9250-MEINS
                                    GS_ZGTMMT9250-MATNR
                                    GS_SCRAP-MEINS
                           CHANGING GS_SCRAP-MENGE.


*- 원가차감 코드
  SELECT SINGLE PRCTR INTO @GS_SCRAP-PRCTR
      FROM MARC
     WHERE MATNR = @GS_ZGTMMT9250-MATNR
       AND WERKS = @GS_ZGTMMT9250-WERKS.

  SELECT SINGLE SP_MATNR INTO @GS_SCRAP-SP_MATNR
    FROM ZCOTP010
   WHERE PRCTR = @GS_SCRAP-PRCTR
     AND VALMONTH = ( SELECT MAX( VALMONTH )
                        FROM ZCOTP010
                       WHERE PRCTR     = @GS_SCRAP-PRCTR
                         AND VALMONTH <= @GS_ZGTMMT9250-BUDAT(6) ).

*& ------------------------------
*   BDC 수행전 CHECK (2차 CHECK)
*& ------------------------------
  IF GS_SCRAP-MENGE IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '단위 환산된 SCRAP수량이 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '단위 환산된 SCRAP수량이 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.

  ELSEIF GS_SCRAP-PRCTR IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '손익센터(MARC-PRCTR)가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '손익센터(MARC-PRCTR)가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.

  ELSEIF GS_SCRAP-MATNR IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '원가차감코드(ZCOTP010-SP_MATNR)가 없습니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '원가차감코드(ZCOTP010-SP_MATNR)가 없습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_ZGTMMT9250
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_ZGTMMT9250    USING  PV_CO_ORDER
                                         PV_RESULT
                                         PV_MESSAGE.

  "--> PV_RESULT = Y 일 시 소재 MOM은 309 MTOM 끝나고 별도 FORM에서 반영
  "--> PV_RESULT = Y 일 시 한미소(KFCM) 309 MTOM 끝나고 별도 FORM에서 반영
*  IF PV_RESULT = 'Y ' AND GV_SYSTEM_ID = 'KSCM'.
  IF PV_RESULT = 'Y ' AND ( GV_SYSTEM_ID = 'KSCM' OR GV_SYSTEM_ID = 'KFCM' ).
    IF GS_ZGTMMT9250-ZFLAG = 'C'. "--> 취소는 넣어주어야 함
      GT_ZGTMMT9250_RESULT = VALUE #( BASE GT_ZGTMMT9250_RESULT
                                  ( CO_ORDER = PV_CO_ORDER
                                    ZSERNO    = GS_ZGTMMT9250-ZSERNO
                                    MBLNR_O   = GV_MBLNR_O
                                    MBLNR_I   = GV_MBLNR_I
                                    MBLNR_Z   = GV_MBLNR_Z
                                    MBLNR_M   = GV_MBLNR_M "--> 309 MTOM
                                    MBLNR_OC  = GV_MBLNR_OC
                                    MBLNR_IC  = GV_MBLNR_IC
                                    MBLNR_ZC  = GV_MBLNR_ZC
                                    MBLNR_MC  = GV_MBLNR_MC "--> 309 MTOM
                                    ZPROC     = PV_RESULT
                                    MESSG     = PV_MESSAGE
                                    MATNR     = GS_ZGTMMT9250-MATNR "--> 본 자재코드
                                    SCMAT     = GS_SCRAP-MATNR      "--> 스크랩 자재코드
                                    UMMAT     = GS_ZGTMMT9250-UMMAT "--> MTOM 자재코드
                                                            ) ).
    ENDIF.
  ELSE.
    GT_ZGTMMT9250_RESULT = VALUE #( BASE GT_ZGTMMT9250_RESULT
                                ( CO_ORDER = PV_CO_ORDER
                                  ZSERNO    = GS_ZGTMMT9250-ZSERNO
                                  MBLNR_O   = GV_MBLNR_O
                                  MBLNR_I   = GV_MBLNR_I
                                  MBLNR_Z   = GV_MBLNR_Z
                                  MBLNR_M   = GV_MBLNR_M "--> 309 MTOM
                                  MBLNR_OC  = GV_MBLNR_OC
                                  MBLNR_IC  = GV_MBLNR_IC
                                  MBLNR_ZC  = GV_MBLNR_ZC
                                  MBLNR_MC  = GV_MBLNR_MC "--> 309 MTOM
                                  ZPROC     = PV_RESULT
                                  MESSG     = PV_MESSAGE
                                  MATNR     = GS_ZGTMMT9250-MATNR "--> 본 자재코드
                                  SCMAT     = GS_SCRAP-MATNR      "--> 스크랩 자재코드
                                  UMMAT     = GS_ZGTMMT9250-UMMAT "--> MTOM 자재코드
                                                          ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_RESULT_ZGTMMT9250
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_RESULT_ZGTMMT9250  USING    PV_CO_ORDER
                                      PV_RESULT
                                      PV_MESSAGE.

  DATA : LS_ZGTMMT9250 TYPE ZGTMMT9250.
  DATA  : LV_TIMESTAMP TYPE TIMESTAMPL.
  CLEAR : LS_ZGTMMT9250, LV_TIMESTAMP.

  GET TIME STAMP FIELD LV_TIMESTAMP.

  "--> PV_RESULT = Y 일 시 소재 MOM은 309 MTOM 끝나고 별도 FORM에서 반영
  "--> PV_RESULT = Y 일 시 한미소(KFCM) 309 MTOM 끝나고 별도 FORM에서 반영
*  IF PV_RESULT = 'Y ' AND GV_SYSTEM_ID = 'KSCM'.
  IF PV_RESULT = 'Y ' AND ( GV_SYSTEM_ID = 'KSCM' OR GV_SYSTEM_ID = 'KFCM' ).
    IF GS_ZGTMMT9250-ZFLAG = 'C'. "--> 취소는 넣어주어야 함
      LS_ZGTMMT9250 = VALUE #( BASE CORRESPONDING #( GS_ZGTMMT9250 EXCEPT CO_ORDER )
                                       TIMESTAMP = LV_TIMESTAMP
                                       CO_ORDER = PV_CO_ORDER
                                       MBLNR_O  = GV_MBLNR_O
                                       MBLNR_I  = GV_MBLNR_I
                                       MBLNR_Z  = GV_MBLNR_Z
                                       MBLNR_M  = GV_MBLNR_M "--> 309 MTOM
                                       MBLNR_OC = GV_MBLNR_OC
                                       MBLNR_IC = GV_MBLNR_IC
                                       MBLNR_ZC = GV_MBLNR_ZC
                                       MBLNR_MC = GV_MBLNR_MC "--> 309 MTOM
                                       ZRESULT  = PV_RESULT
                                       TEXT     = PV_MESSAGE
                                       ZERNAM   = SY-UNAME
                                       ZERDAT   = SY-DATUM
                                       ZERZET   = SY-UZEIT
                                       ZAENAM   = SY-UNAME
                                       ZAEDAT   = SY-DATUM
                                       ZAEZET   = SY-UZEIT
                                       SCMAT    = GS_SCRAP-MATNR "--> 스크랩 자재코드
                                       ).

      MODIFY ZGTMMT9250 FROM LS_ZGTMMT9250.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ELSE.
    LS_ZGTMMT9250 = VALUE #( BASE CORRESPONDING #( GS_ZGTMMT9250 EXCEPT CO_ORDER )
                                     TIMESTAMP = LV_TIMESTAMP
                                     CO_ORDER = PV_CO_ORDER
                                     MBLNR_O  = GV_MBLNR_O
                                     MBLNR_I  = GV_MBLNR_I
                                     MBLNR_Z  = GV_MBLNR_Z
                                     MBLNR_M  = GV_MBLNR_M "--> 309 MTOM
                                     MBLNR_OC = GV_MBLNR_OC
                                     MBLNR_IC = GV_MBLNR_IC
                                     MBLNR_ZC = GV_MBLNR_ZC
                                     MBLNR_MC = GV_MBLNR_MC "--> 309 MTOM
                                     ZRESULT  = PV_RESULT
                                     TEXT     = PV_MESSAGE
                                     ZERNAM   = SY-UNAME
                                     ZERDAT   = SY-DATUM
                                     ZERZET   = SY-UZEIT
                                     ZAENAM   = SY-UNAME
                                     ZAEDAT   = SY-DATUM
                                     ZAEZET   = SY-UZEIT
                                     SCMAT    = GS_SCRAP-MATNR "--> 스크랩 자재코드
                                     ).

    MODIFY ZGTMMT9250 FROM LS_ZGTMMT9250.
    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_CO_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_CO_ORDER .

  DATA : LS_ZCOTP006 TYPE ZCOTP006.
*  DATA : LV_SAVE.
*  CLEAR  LV_SAVE.
*&---------------------------------------------------------------
*& CO 생산오더 생성
*&---------------------------------------------------------------
  CLEAR: GV_CO_ORDER, GV_MESSAGE_CO.

  PERFORM BDC_KKF1(ZCOR0180)
                      USING 'C001'            "오더유형
                            GS_SCRAP-SP_MATNR "원가차감코드
                            GS_ZGTMMT9250-WERKS "플랜트
                            GV_GSBER          "사업영역
                   CHANGING GV_CO_ORDER       "CO_생산오더
                            GV_MESSAGE_CO.    "메시지

*&---------------------------------------------------------------------*
*&  Scarp 대체 테이블 Update
*&----------------------------------------------------------------------*
  IF GV_CO_ORDER IS NOT INITIAL.

    LS_ZCOTP006 = VALUE #( CO_ORDER  = GV_CO_ORDER
                           KOSTL     = GS_ZGTMMT9250-KOSTL
                           SC_REASON = GS_ZGTMMT9250-SC_REASON
                           BUDAT     = GS_ZGTMMT9250-BUDAT
                           MATNR     = GS_ZGTMMT9250-MATNR
                           WERKS     = GS_ZGTMMT9250-WERKS
                           PRCTR     = GS_SCRAP-PRCTR
                           LGORT     = GS_ZGTMMT9250-LGORT
                           SP_MATNR  = GS_SCRAP-SP_MATNR
                           CHARG     = GS_ZGTMMT9250-CHARG
                           QTY       = GS_ZGTMMT9250-MENGE
                           MEINS     = GS_ZGTMMT9250-MEINS
                           SC_MATNR  = GS_SCRAP-MATNR
                           SC_LGORT  = GS_SCRAP-LGORT
                           SC_QTY    = GS_SCRAP-MENGE
                           SC_MEINS  = GS_SCRAP-MEINS
                           USNAM     = SY-UNAME
                           MESSAGE   = GV_MESSAGE_CO ).

    MODIFY ZCOTP006 FROM LS_ZCOTP006.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.

  ELSE.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_CO.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                         'E'
                                         GV_MESSAGE_CO.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_CO_ORDER IS NOT INITIAL.

*&---------------------------------------------------------------
*& 자재출고처리
*&---------------------------------------------------------------
  CLEAR : GV_MBLNR_O, GV_MESSAGE_MO.

*- 처리사유에 따른 SCRAP 이동유형(출고) 가져오기
  SELECT SINGLE OUT_BWART INTO @DATA(LV_BWART)
      FROM ZCOTP005
     WHERE SC_REASON = @GS_ZGTMMT9250-SC_REASON.


  PERFORM BDC_MB1A(ZCOR0180) USING   GS_ZGTMMT9250-BUDAT  "전기일
                                     LV_BWART           "이동유형(출고)
                                     GS_ZGTMMT9250-WERKS  "플랜트
                                     GS_ZGTMMT9250-LGORT  "저장위치
                                     GS_ZGTMMT9250-MATNR  "자재
                                     GS_ZGTMMT9250-CHARG  "배치
                                     GS_ZGTMMT9250-MENGE  "수량
                                     GV_CO_ORDER        "CO_오더
                                     GS_ZGTMMT9250-BKTXT  "폐기사유
                            CHANGING GV_MBLNR_O
                                     GV_MESSAGE_MO.

  PERFORM MODIFY_ZCOTP006_MBLNR_OUT(ZCOR0180)
                                      USING ''
                                            GV_CO_ORDER
                                            GV_MBLNR_O
                                            GV_MESSAGE_MO.
  IF GV_MBLNR_O IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MO.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING  GV_CO_ORDER
                                          'E'
                                          GV_MESSAGE_MO.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_O IS NOT INITIAL.

*&---------------------------------------------------------------
*& SCRAP 입고처리
*&---------------------------------------------------------------
  CLEAR : LV_BWART, GV_MBLNR_I, GV_MESSAGE_MI.

*- 처리사유에 따른 SCRAP 이동유형(입고) 가져오기
  SELECT SINGLE IN_BWART INTO @LV_BWART
      FROM ZCOTP005
     WHERE SC_REASON = @GS_ZGTMMT9250-SC_REASON.


  PERFORM BDC_MB1C(ZCOR0180) USING   GS_ZGTMMT9250-BUDAT "전기일
                                     LV_BWART          "이동유형
                                     GS_ZGTMMT9250-WERKS "플랜트
                                     GS_SCRAP-LGORT    "저장위치(SCRAP)
                                     GS_SCRAP-MATNR    "자재(SCRAP)
                                     ''                "배치
                                     GS_SCRAP-MENGE    "수량
                                     GV_CO_ORDER      "CO 오더
                            CHANGING GV_MBLNR_I
                                     GV_MESSAGE_MI.

  PERFORM MODIFY_ZCOTP006_MBLNR_IN(ZCOR0180) USING ''
                                                   GV_CO_ORDER
                                                   GV_MBLNR_I
                                                   GV_MESSAGE_MI.
  IF GV_MBLNR_I IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MI.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                         'E'
                                         GV_MESSAGE_MI.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_I IS NOT INITIAL.

*&---------------------------------------------------------------
*& 매출원가 대체용 SCRAP 0 입고처리
*&---------------------------------------------------------------
  CLEAR: GV_MBLNR_Z,GV_MESSAGE_MZ.
  PERFORM BDC_MB31(ZCOR0180) USING  GS_ZGTMMT9250-BUDAT "전기일
                                   '101'              "이동유형
                                    GS_ZGTMMT9250-WERKS "플랜트
                                    GS_SCRAP-LGORT    "저장위치(SCRAP)
                                    GS_SCRAP-SP_MATNR "원가차감코드
                                    0                 "수량
                                    GV_CO_ORDER       "CO 오더
                          CHANGING  GV_MBLNR_Z
                                    GV_MESSAGE_MZ.

  PERFORM MODIFY_ZCOTP006_MBLNR_ZERO(ZCOR0180) USING ''
                                                     GV_CO_ORDER
                                                     GV_MBLNR_Z
                                                     GV_MESSAGE_MZ.

  IF GV_MBLNR_Z IS INITIAL.

    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MZ.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                         'E'
                                         GV_MESSAGE_MZ.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  CHECK GV_MBLNR_Z IS NOT INITIAL.

*- 성공
  PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                          'Y'
                                          GV_MESSAGE_MZ.

  PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                       'Y'
                                       GV_MESSAGE_MZ.

*&---------------------------------------------------------------
*& BDC 처리후 연결된 꼬리표의 잔량에서 처리량 만큼 감소시킴
*&---------------------------------------------------------------
  SELECT SINGLE * FROM ZPPT0001
    WHERE WERKS = @GS_ZGTMMT9250-WERKS
      AND MATNR = @GS_ZGTMMT9250-MATNR
      AND CHARG = @GS_ZGTMMT9250-CHARG
      AND TAGNR = @GS_ZGTMMT9250-TAGNR
    INTO @DATA(LS_ZPPT0001).

  IF LS_ZPPT0001 IS NOT INITIAL.

    LS_ZPPT0001-REMAIN  = LS_ZPPT0001-REMAIN - GS_ZGTMMT9250-MENGE.

    MODIFY ZPPT0001 FROM LS_ZPPT0001.
    IF SY-SUBRC = 0.
      COMMIT WORK.

    ELSE.
      PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GV_CO_ORDER
                                              'E'
                                              '꼬리표 잔량 Update Error.'.

      PERFORM SAVE_RESULT_ZGTMMT9250 USING GV_CO_ORDER
                                           'E'
                                           '꼬리표 잔량 Update Error.'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PRO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_PRO_DATA .

*- 각 필드의 누락 여부 체크
  PERFORM CHECK_ZGTMMT9250_FIELD.
  IF GV_ERROR = 'X'.
    EXIT.
  ENDIF.


*- 수량
  IF GS_ZGTMMT9250-MENGE <= 0.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '출고수량은 0보다 커야 합니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '출고수량은 0보다 커야 합니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.


*- 재고체크
  PERFORM CHECK_STOCK.
  IF GV_ERROR = 'X'.
    EXIT.
  ENDIF.


*- 코스트센터 체크
  PERFORM CHECK_KOSTL.
  IF GV_ERROR = 'X'.
    EXIT.
  ENDIF.


*- 꼬리표 체크
  CASE GV_SYSTEM_ID.
    WHEN 'KFCM'.

    WHEN OTHERS.
      SELECT SINGLE MANDT
        FROM ZPPT0001
        WHERE WERKS = @GS_ZGTMMT9250-WERKS
         AND  MATNR = @GS_ZGTMMT9250-MATNR
         AND  CHARG = @GS_ZGTMMT9250-CHARG
         AND  TAGNR = @GS_ZGTMMT9250-TAGNR
         AND  LGORT = @GS_ZGTMMT9250-LGORT
        INTO @SY-MANDT.
  ENDCASE.

*&---------------------------------------------------------------------*
*- 꼬리표
**  한미소의 경우 꼬리표 관리안함.
*&---------------------------------------------------------------------*
  IF SY-SUBRC <> 0.

   CASE GV_SYSTEM_ID.
     WHEN 'KFCM'.

   	 WHEN OTHERS.
       PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                               'E'
                                               '꼬리표가 존재하지 않습니다.'.
       PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                            'E'
                                            '꼬리표가 존재하지 않습니다.'.
       GV_ERROR = 'X'.
   ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZGTMMT9250_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ZGTMMT9250_FIELD .

  DATA : LV_MESSAGE(220),
         LV_MES(220).

  CLEAR : LV_MESSAGE, LV_MES.

*- CO_ORDER를 제외한 모든 필드들 체크
  IF GS_ZGTMMT9250-WERKS IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'WERKS' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-ZSERNO IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'ZSERNO' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-MATNR IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'MATNR' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-LGORT IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'LGORT' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-CHARG IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'CHARG' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-BUDAT IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'BUDAT' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-MENGE IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'MENGE' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-MEINS IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'MEINS' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-KOSTL IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'KOSTL' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-SC_REASON IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'SC_REASON' LV_MESSAGE.
  ENDIF.

*&---------------------------------------------------------------------*
*- 꼬리표
**  한미소의 경우 꼬리표 관리안함.
*&---------------------------------------------------------------------*
  IF GS_ZGTMMT9250-TAGNR IS INITIAL.
    CASE GV_SYSTEM_ID.
      WHEN 'KFCM'.

      WHEN OTHERS.
        PERFORM GET_FIELDTEXT USING 'TAGNR' LV_MESSAGE.
    ENDCASE.
  ENDIF.

  IF GS_ZGTMMT9250-BKTXT IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'BKTXT' LV_MESSAGE.
  ENDIF.
  IF GS_ZGTMMT9250-UMMAT IS INITIAL.
    PERFORM GET_FIELDTEXT USING 'UMMAT' LV_MESSAGE.
  ENDIF.

  IF GV_ERROR = 'X'.
    LV_MES = |{ LV_MESSAGE } 데이터가 누락되었습니다.|.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            LV_MES.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         LV_MES.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_STOCK .

  SELECT SINGLE
         A~WERKS,
         B~MATNR,
         A~RGEKZ,
         B~LGORT,
         B~CHARG,
         B~CLABS,
         C~MEINS
     INTO @DATA(LS_STOCK)
     FROM MARC AS A
     INNER JOIN MCHB AS B
       ON A~MATNR = B~MATNR
      AND A~WERKS = B~WERKS
     INNER JOIN MARA AS C
       ON A~MATNR = C~MATNR
      WHERE A~WERKS = @GS_ZGTMMT9250-WERKS
       AND  A~MATNR = @GS_ZGTMMT9250-MATNR
       AND  A~XCHPF = 'X'
       AND  B~LGORT = @GS_ZGTMMT9250-LGORT
       AND  B~CHARG = @GS_ZGTMMT9250-CHARG
       AND  B~LVORM = ''.

  IF GS_ZGTMMT9250-MENGE > LS_STOCK-CLABS.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '처리량이 가용재고보다 큽니다.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '처리량이 가용재고보다 큽니다.'.
    GV_ERROR = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_KOSTL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_KOSTL .

  DATA : LV_KOKRS TYPE KOKRS.
  CLEAR : LV_KOKRS, GV_GSBER.

*- 플랜트로 관리회계 영역 조회
  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_WERKS = GS_ZGTMMT9250-WERKS
    IMPORTING
      E_KOKRS = LV_KOKRS.

  SELECT SINGLE *
    FROM CSKS
    WHERE KOKRS = @LV_KOKRS           "관리회계 영역
     AND  KOSTL = @GS_ZGTMMT9250-KOSTL  "코스트센터
     AND  DATBI >= @GS_ZGTMMT9250-BUDAT "효력종료일
     AND  DATAB <= @GS_ZGTMMT9250-BUDAT "효력시작일
    INTO @DATA(LS_CSKS).

  IF SY-SUBRC <> 0.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING ' '
                                            'E'
                                            '처리부문을 확인하세요.'.
    PERFORM SAVE_RESULT_ZGTMMT9250 USING ' '
                                         'E'
                                         '처리부문을 확인하세요.'.
    GV_ERROR = 'X'.
  ELSE.
    GV_GSBER = LS_CSKS-GSBER. "사업영역
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CANC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CANC_DATA .

  CLEAR GS_ZGTMMT9250C.

*- Scrap 이력 테이블 존재 여부 확인
  SELECT SINGLE *
    INTO @GS_ZGTMMT9250C
    FROM ZGTMMT9250
    WHERE ZSERNO = @GS_ZGTMMT9250-ZSERNO
      AND CO_ORDER = @GS_ZGTMMT9250-CO_ORDER
      AND WERKS = @GS_ZGTMMT9250-WERKS
      AND ZFLAG = 'P'
      AND ZRESULT = 'Y'.

  IF GS_ZGTMMT9250C IS INITIAL.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                            'E'
                                            'Scrap 취소 처리대상이 존재하지 않습니다.'.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                         'E'
                                         'Scrap 취소 처리대상이 존재하지 않습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ELSE.
    SELECT SINGLE *
      INTO @GS_ZCOTP006
      FROM ZCOTP006
      WHERE CO_ORDER  = @GS_ZGTMMT9250C-CO_ORDER
       AND  KOSTL     = @GS_ZGTMMT9250C-KOSTL
       AND  SC_REASON = @GS_ZGTMMT9250C-SC_REASON
       AND  MATNR     = @GS_ZGTMMT9250C-MATNR
       AND  WERKS     = @GS_ZGTMMT9250C-WERKS.

    GV_MBLNR_O = GS_ZGTMMT9250C-MBLNR_O. "Scrap 처리문서
    GV_MBLNR_I = GS_ZGTMMT9250C-MBLNR_I. "Scrap 입고문서
    GV_MBLNR_Z = GS_ZGTMMT9250C-MBLNR_Z. "원가차감 문서
    GV_MBLNR_M = GS_ZGTMMT9250C-MBLNR_M. "309 MTOM 문서
  ENDIF.


*- 기취소된 문서가 존재하는지 확인
  IF ( GS_ZGTMMT9250C-MBLNR_O IS NOT INITIAL AND GS_ZGTMMT9250C-MBLNR_OC IS INITIAL ) OR
     ( GS_ZGTMMT9250C-MBLNR_I IS NOT INITIAL AND GS_ZGTMMT9250C-MBLNR_IC IS INITIAL ) OR
     ( GS_ZGTMMT9250C-MBLNR_Z IS NOT INITIAL AND GS_ZGTMMT9250C-MBLNR_ZC IS INITIAL ) OR

   "[한미소PJT] 309 MTOM 조건 추가
   "309 먼저 취소하고 나머지 작업 취소처리
     ( GV_SYSTEM_ID = 'KFCM' AND
       GS_ZGTMMT9250C-MBLNR_M IS NOT INITIAL AND GS_ZGTMMT9250C-MBLNR_MC IS INITIAL ).
  ELSE.
    PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                            'E'
                                            '이미 취소된 Scrap 입니다.'.

    PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                         'E'
                                         '이미 취소된 Scrap 입니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

  IF GV_SYSTEM_ID = 'KSCM'.
    IF ( GS_ZGTMMT9250C-MBLNR_M IS NOT INITIAL AND GS_ZGTMMT9250C-MBLNR_MC IS INITIAL ).
    ELSE.
      PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                              'E'
                                              '이미 취소된 Scrap 입니다.'.

      PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                           'E'
                                           '이미 취소된 Scrap 입니다.'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANC_MBLNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CANC_MBLNR .

  DATA : LV_MESSAGE(220).


*- 취소 대상 문서별로 분기
  IF GS_ZCOTP006-MBLNR_O IS NOT INITIAL AND
     GS_ZCOTP006-MBLNR_OC IS INITIAL.
    PERFORM DO_MBST USING 'MBLNR_OC'
                          GS_ZCOTP006.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  IF GS_ZCOTP006-MBLNR_I IS NOT INITIAL AND
     GS_ZCOTP006-MBLNR_IC IS INITIAL.
    PERFORM DO_MBST USING 'MBLNR_IC'
                          GS_ZCOTP006.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  IF GS_ZCOTP006-MBLNR_Z IS NOT INITIAL AND
     GS_ZCOTP006-MBLNR_ZC IS INITIAL.
    PERFORM DO_MBST USING 'MBLNR_ZC'
                          GS_ZCOTP006.
    IF GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.


*- Scrap 취소 성공
  CHECK GV_ERROR <> 'X'.
  LV_MESSAGE = GT_RETURN-MESSAGE.

  PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                          'Y'
                                          LV_MESSAGE.

  PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                       'Y'
                                       LV_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DO_MBST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_ZCOTP006
*&---------------------------------------------------------------------*
FORM DO_MBST    USING  PV_FIELDNAME
                       PS_ZCOTP006 TYPE ZCOTP006.

  DATA : LV_MBLNR   TYPE MBLNR,
         LV_YEAR    TYPE MJAHR,
         LV_MBLNR_C TYPE MBLNR,
         LV_MESSAGE TYPE BAPI_MSG.

  CLEAR : LV_MBLNR, LV_YEAR, LV_MBLNR_C, LV_MESSAGE.

  CASE PV_FIELDNAME.
    WHEN 'MBLNR_OC'. LV_MBLNR   = PS_ZCOTP006-MBLNR_O.
    WHEN 'MBLNR_IC'. LV_MBLNR   = PS_ZCOTP006-MBLNR_I.
    WHEN 'MBLNR_ZC'. LV_MBLNR   = PS_ZCOTP006-MBLNR_Z.
  ENDCASE.
  LV_YEAR = PS_ZCOTP006-BUDAT(4).
  PERFORM BDC_MBST USING PV_FIELDNAME
                         LV_MBLNR
                         LV_YEAR
                CHANGING LV_MBLNR_C
                         LV_MESSAGE.


  CLEAR P_MJAHR.
  P_MJAHR = PS_ZCOTP006-BUDAT+0(4).

  CASE PV_FIELDNAME.
    WHEN 'MBLNR_OC'.
      PERFORM MODIFY_ZCOTP006_MBLNR_OC USING GS_ZGTMMT9250-CO_ORDER
                                             LV_MBLNR_C
                                             LV_MESSAGE.

    WHEN 'MBLNR_IC'.
      PERFORM MODIFY_ZCOTP006_MBLNR_IC USING GS_ZGTMMT9250-CO_ORDER
                                             LV_MBLNR_C
                                             LV_MESSAGE.

    WHEN 'MBLNR_ZC'.
      PERFORM MODIFY_ZCOTP006_MBLNR_ZC USING GS_ZGTMMT9250-CO_ORDER
                                             LV_MBLNR_C
                                             LV_MESSAGE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_MBST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      --> LV_MBLNR
*&      --> LV_YEAR
*&      <-- LV_MBLNR_C
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM BDC_MBST  USING    PV_FIELDNAME
                        PV_MBLNR
                        PV_YEAR
               CHANGING PV_MBLNR_C
                        PV_MESSAGE.

  DATA: LV_SUBRC     TYPE SYSUBRC,
        LV_BUDAT     LIKE MKPF-BUDAT,
        LV_CDATE(10) TYPE C.

  CLEAR : LV_SUBRC, LV_BUDAT, LV_CDATE, GS_HEADRET, GT_RETURN, GT_RETURN[].
  CLEAR : PV_MBLNR_C, PV_MESSAGE.

*  역분개할 전표의 전기일로 역분개 처리하기
  SELECT SINGLE BUDAT
           INTO LV_BUDAT
           FROM MKPF
          WHERE MBLNR = PV_MBLNR
            AND MJAHR = PV_YEAR.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PV_MBLNR
      MATDOCUMENTYEAR     = PV_YEAR
      GOODSMVT_PSTNG_DATE = LV_BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = GS_HEADRET
    TABLES
      RETURN              = GT_RETURN.

  IF GS_HEADRET-MAT_DOC IS NOT INITIAL.
*___성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PV_MBLNR_C = GS_HEADRET-MAT_DOC.

    IF PV_FIELDNAME = 'MBLNR_OC'.
      GV_MBLNR_OC = PV_MBLNR_C.
    ELSEIF PV_FIELDNAME = 'MBLNR_IC'.
      GV_MBLNR_IC = PV_MBLNR_C.
    ELSEIF PV_FIELDNAME = 'MBLNR_ZC'.
      GV_MBLNR_ZC  = PV_MBLNR_C.
    ENDIF.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE GT_RETURN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETURN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETURN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETURN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.
      PV_MESSAGE = GT_RETURN-MESSAGE.

      PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                              'E'
                                              PV_MESSAGE.

      PERFORM SAVE_RESULT_ZGTMMT9250 USING  GS_ZGTMMT9250-CO_ORDER
                                            'E'
                                            PV_MESSAGE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZCOTP006_MBLNR_OC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZGTMMT9250_CO_ORDER
*&      --> LV_MBLNR_C
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MODIFY_ZCOTP006_MBLNR_OC    USING  PV_CO_ORDER
                                        PV_MBLNR_C
                                        PV_MESSAGE.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> START
  DATA : T_ERDAT LIKE AUFK-ERDAT.
  IF P_MJAHR IS INITIAL.
    SELECT SINGLE ERDAT INTO T_ERDAT FROM AUFK
     WHERE AUFNR = PV_CO_ORDER.
    P_MJAHR = T_ERDAT+0(4).
  ENDIF.

  SELECT SINGLE * FROM MKPF INTO @DATA(LS_MKPF)
                              WHERE MBLNR = @PV_MBLNR_C
                                AND MJAHR = @P_MJAHR.
  IF SY-SUBRC EQ 0.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> END

    UPDATE ZCOTP006 SET MBLNR_OC = PV_MBLNR_C
                        USNAM_C  = SY-UNAME
                        MESSAGE  = PV_MESSAGE
                        CHANGE_DATE = SY-DATUM
                  WHERE CO_ORDER = PV_CO_ORDER.

    IF SY-SUBRC = 0.
      IF PV_MBLNR_C IS INITIAL.
        ROLLBACK WORK.
        EXIT.
      ELSE.
        COMMIT WORK.
      ENDIF.
    ENDIF.


*- 꼬리표 수량 원복
    IF SY-SUBRC = 0 AND
       PV_MBLNR_C IS NOT INITIAL.
      SELECT SINGLE *
           INTO @DATA(LS_ZPPT0001)
           FROM ZPPT0001
           WHERE WERKS = @GS_ZGTMMT9250-WERKS
            AND  MATNR = @GS_ZGTMMT9250-MATNR
            AND  CHARG = @GS_ZGTMMT9250-CHARG
            AND  TAGNR = @GS_ZGTMMT9250-TAGNR.

      IF LS_ZPPT0001 IS NOT INITIAL.

        LS_ZPPT0001-REMAIN  = LS_ZPPT0001-REMAIN + GS_ZGTMMT9250-MENGE.
        MODIFY ZPPT0001 FROM LS_ZPPT0001.
        IF SY-SUBRC = 0.
          COMMIT WORK.

        ELSE.
          PERFORM RETURN_MESSAGE_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                                  'E'
                                                  '꼬리표 잔량 Update Error.'.

          PERFORM SAVE_RESULT_ZGTMMT9250 USING GS_ZGTMMT9250-CO_ORDER
                                               'E'
                                               '꼬리표 잔량 Update Error.'.
        ENDIF.
      ENDIF.
    ENDIF.


**  & 2009.04.28 BY ZCNSCO
*    IF PV_MBLNR_C IS INITIAL.
*      MESSAGE  S001(ZCO1)  WITH PV_MESSAGE.
*      ROLLBACK WORK.
*      RETURN.
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZCOTP006_MBLNR_IC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZGTMMT9250_CO_ORDER
*&      --> LV_MBLNR_C
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MODIFY_ZCOTP006_MBLNR_IC    USING  PV_CO_ORDER
                                        PV_MBLNR_C
                                        PV_MESSAGE.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> START
  DATA : T_ERDAT LIKE AUFK-ERDAT.
  IF P_MJAHR IS INITIAL.
    SELECT SINGLE ERDAT INTO T_ERDAT FROM AUFK
     WHERE AUFNR = PV_CO_ORDER.
    P_MJAHR = T_ERDAT+0(4).
  ENDIF.

  SELECT SINGLE * FROM MKPF INTO @DATA(LS_MKPF)
                              WHERE MBLNR = @PV_MBLNR_C
                                AND MJAHR = @P_MJAHR.
  IF SY-SUBRC EQ 0.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> END

    UPDATE ZCOTP006 SET MBLNR_IC = PV_MBLNR_C
                        USNAM_C  = SY-UNAME
                        MESSAGE  = PV_MESSAGE
                        CHANGE_DATE = SY-DATUM
                  WHERE CO_ORDER = PV_CO_ORDER.

    IF SY-SUBRC = 0.
      IF PV_MBLNR_C IS INITIAL.
        ROLLBACK WORK.
        EXIT.
      ELSE.
        COMMIT WORK.
      ENDIF.
    ENDIF.

**  & 2009.04.28 BY ZCNSCO
*    IF PV_MBLNR_C IS INITIAL.
*      MESSAGE  S001(ZCO1)  WITH PV_MESSAGE.
*      ROLLBACK WORK.
*      EXIT.
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZCOTP006_MBLNR_ZC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZGTMMT9250_CO_ORDER
*&      --> LV_MBLNR_C
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MODIFY_ZCOTP006_MBLNR_ZC    USING  PV_CO_ORDER
                                        PV_MBLNR_C
                                        PV_MESSAGE.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> START
  DATA : T_ERDAT LIKE AUFK-ERDAT.
  IF P_MJAHR IS INITIAL.
    SELECT SINGLE ERDAT INTO T_ERDAT FROM AUFK
     WHERE AUFNR = PV_CO_ORDER.
    P_MJAHR = T_ERDAT+0(4).
  ENDIF.

  SELECT SINGLE * FROM MKPF INTO @DATA(LS_MKPF)
                              WHERE MBLNR = @PV_MBLNR_C
                                AND MJAHR = @P_MJAHR.
  IF SY-SUBRC EQ 0.

*& 2012.02.03, ZCNSCO, 자재문서 존재여부 체크 -->> END

    UPDATE ZCOTP006 SET MBLNR_ZC = PV_MBLNR_C
                        USNAM_C  = SY-UNAME
                        MESSAGE  = PV_MESSAGE
                        CHANGE_DATE = SY-DATUM
                  WHERE CO_ORDER = PV_CO_ORDER.

    IF SY-SUBRC = 0.
      IF PV_MBLNR_C IS INITIAL.
        ROLLBACK WORK.
        EXIT.
      ELSE.
        COMMIT WORK.
      ENDIF.
    ENDIF.

**  & 2009.04.28 BY ZCNSCO
*    IF PV_MBLNR_C IS INITIAL.
*      MESSAGE  S001(ZCO1)  WITH PV_MESSAGE.
*      ROLLBACK WORK.
*      EXIT.
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT_ZGTMMT9250
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT_ZGTMMT9250 .

  LOOP AT GT_ZGTMMT9250_RESULT INTO DATA(LS_RESULT).

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MATNR
      IMPORTING
        OUTPUT = LS_RESULT-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-SCMAT
      IMPORTING
        OUTPUT = LS_RESULT-SCMAT.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-UMMAT
      IMPORTING
        OUTPUT = LS_RESULT-UMMAT.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-CO_ORDER
      IMPORTING
        OUTPUT = LS_RESULT-CO_ORDER.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_O
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_O.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_I
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_I.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_Z
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_Z.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_M
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_M.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_OC
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_OC.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_IC
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_IC.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_ZC
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_ZC.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MBLNR_MC
      IMPORTING
        OUTPUT = LS_RESULT-MBLNR_MC.


    MODIFY GT_ZGTMMT9250_RESULT FROM LS_RESULT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESULT_ZGTMMT9250_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM RESULT_ZGTMMT9250_DATA    USING  PO_RESULT
                                    PO_MESSAGE.

  DATA : LV_MESSAGE(80),
         LV_RESULT(1).
  CLEAR : LV_MESSAGE, LV_RESULT.

  IF GT_ZGTMMT9250_RESULT IS NOT INITIAL.

*- 성공 건수
    DATA(LV_CNT_S) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_S IN GT_ZGTMMT9250_RESULT
                     WHERE ( ZPROC = 'Y' )
                     NEXT SUM = SUM + 1 ).

*- 실패 건수
    DATA(LV_CNT_E) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_E IN GT_ZGTMMT9250_RESULT
                     WHERE ( ZPROC = 'E' )
                     NEXT SUM = SUM + 1 ).

    "전체 성공
    IF LV_CNT_S IS NOT INITIAL AND
       LV_CNT_E IS INITIAL.

      LV_RESULT = 'Y'.
      LV_MESSAGE = |{ LV_CNT_S }건 처리 성공|.

      "전체 실패
    ELSEIF LV_CNT_S IS INITIAL AND
           LV_CNT_E IS NOT INITIAL.

      LV_RESULT = 'E'.
      LV_MESSAGE = |{ LV_CNT_E }건 처리 실패|.

      "부분 성공
    ELSE.

      LV_RESULT = 'E'.
      LV_MESSAGE = |{ LV_CNT_S }건 처리 성공, { LV_CNT_E }건 처리 실패|.

    ENDIF.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.


  ELSE.
    LV_RESULT = 'E'.
    LV_MESSAGE = '전송실패'.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELDTEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM GET_FIELDTEXT  USING  PV_FIELDNAME PV_MESSAGE.

  DATA : LT_TAB TYPE TABLE OF DFIES.
  DATA : LV_FIELDTEXT TYPE DFIES-FIELDTEXT.
  CLEAR :  LT_TAB, LV_FIELDTEXT.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'ZGTMMSIF0078'
      FIELDNAME      = PV_FIELDNAME
      LANGU          = SY-LANGU
    TABLES
      DFIES_TAB      = LT_TAB
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.

  IF SY-SUBRC = 0.
    LV_FIELDTEXT = VALUE #( LT_TAB[ 1 ]-FIELDTEXT OPTIONAL ).
  ENDIF.

  IF PV_MESSAGE IS INITIAL.
    PV_MESSAGE = LV_FIELDTEXT.
  ELSE.
    PV_MESSAGE = |{ PV_MESSAGE } { LV_FIELDTEXT }|.
  ENDIF.
  GV_ERROR = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0001_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I15_MATNR
*&      --> GT_I15_WERKS
*&      --> GT_I15_R_WERKS
*&      --> GT_I15_TAGNR
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001_GI  USING    PV_MATNR
                                  PV_WERKS
                                  PV_R_WERKS
                                  PV_TAGNR
                                  PV_EBELN
                                  PV_GIFLG.

  DATA: LV_RESWK_G LIKE  ZPPT0134-GUBUN,
        LV_WERKS_G LIKE  ZPPT0134-GUBUN,
        LV_DISPO   LIKE  MARC-DISPO,
        LV_DISPO_R LIKE  MARC-DISPO,
        LV_AUFNR   LIKE  ZPPT0001-AUFNR.

  " 공급플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_RESWK_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = PV_WERKS
            AND B~MATNR = PV_MATNR.

  " 수요플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_WERKS_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = PV_R_WERKS
            AND B~MATNR = PV_MATNR.

  CASE PV_GIFLG.
    WHEN 'Y'.
      IF LV_RESWK_G = 'C' AND LV_WERKS_G = 'B'.
*& 비전선 꼬리표 생성...
        CLEAR  ZPPT0001.
        SELECT SINGLE *
          FROM ZPPT0001
         WHERE WERKS = PV_WERKS
           AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING ZPPT0001 TO ZPPT0211.
          ZPPT0211-WERKS   = PV_R_WERKS.
          ZPPT0211-TAGQTY  = ZPPT0001-MGVRG.
          ZPPT0211-CURQTY  = ZPPT0001-REMAIN.
          ZPPT0211-FINEQTY = ZPPT0001-REMAIN.
          ZPPT0211-GRFLG   = 'N'.
          ZPPT0211-GIFLG   = 'N'.
          INSERT ZPPT0211.
        ENDIF.

      ELSE.
*& 출고이전전기의 경우, 공급플랜트의 꼬리표 정보를 참조하여,
*&                      수요플랜트의 꼬리표 정보를 생성...
        CLEAR  ZPPT0001.
        SELECT SINGLE *
          FROM ZPPT0001
         WHERE WERKS = PV_WERKS
           AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          CLEAR : LV_AUFNR.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = PV_EBELN
            IMPORTING
              OUTPUT = LV_AUFNR.

          ZPPT0001-WERKS =  PV_R_WERKS.
          ZPPT0001-AUFNR =  LV_AUFNR.
          ZPPT0001-GRFLG = 'N'.
          ZPPT0001-GIFLG = 'N'.
          INSERT ZPPT0001.
        ENDIF.

      ENDIF.

*& 공급플랜트의 출고 플래그를 'Y'로 설정한다.
      UPDATE ZPPT0001
      SET:   "GIFLG   = 'Y' "--> 출고 시 업데이트 X
             MBLNR   = GS_MHDRT-MAT_DOC
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = PV_WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN 'N'.
      IF LV_RESWK_G = 'C' AND LV_WERKS_G = 'B'.
*& 비전선 꼬리표 삭제...
        DELETE
        FROM   ZPPT0211
        WHERE  WERKS = PV_R_WERKS
        AND    TAGNR = PV_TAGNR.
      ELSE.
*& 출고전기 취소의 경우, 수요플랜트의 꼬리표정보를 삭제...
        DELETE
        FROM    ZPPT0001
        WHERE   WERKS = PV_R_WERKS
        AND     TAGNR = PV_TAGNR.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'N'로 설정한다.
      UPDATE ZPPT0001
      SET:   "GIFLG   = 'N' "--> 출고 시 업데이트 X
             MBLNR   = ' '
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = PV_WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN  OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0211_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I15_MATNR
*&      --> GT_I15_WERKS
*&      --> GT_I15_R_WERKS
*&      --> GT_I15_TAGNR
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0211_GI  USING    PV_MATNR
                                  PV_WERKS
                                  PV_R_WERKS
                                  PV_TAGNR
                                  PV_EBELN
                                  PV_GIFLG.

  DATA: LV_RESWK_G LIKE  ZPPT0134-GUBUN,
        LV_WERKS_G LIKE  ZPPT0134-GUBUN.

*& 공급플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_RESWK_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = PV_WERKS
            AND B~MATNR = PV_MATNR.

*& 수요플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_WERKS_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = PV_R_WERKS
            AND B~MATNR = PV_MATNR.
  CASE PV_GIFLG.
    WHEN 'Y'.
      IF LV_RESWK_G = 'B' AND LV_WERKS_G = 'C'.
*& 전선 꼬리표 생성...
        CLEAR  ZPPT0211.
        SELECT SINGLE * FROM ZPPT0211
                       WHERE WERKS = PV_WERKS
                         AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING ZPPT0211 TO ZPPT0001.
          ZPPT0001-WERKS  =  PV_R_WERKS.
          ZPPT0001-MGVRG  =  ZPPT0211-TAGQTY.
          ZPPT0001-REMAIN =  ZPPT0211-CURQTY.
          ZPPT0001-GRFLG  = 'N'.
          ZPPT0001-GIFLG  = 'N'.
          INSERT ZPPT0001.
        ENDIF.


      ELSE.

*& 출고이전전기의 경우, 공급플랜트의 꼬리표 정보를 참조하여,
*&                      수요플랜트의 꼬리표 정보를 생성...
        CLEAR  ZPPT0211.
        SELECT SINGLE * FROM ZPPT0211
                       WHERE WERKS = PV_WERKS
                         AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          ZPPT0211-WERKS =  PV_R_WERKS.
          ZPPT0211-RUECK  =  ' '.
          ZPPT0211-GRFLG = 'N'.
          ZPPT0211-GIFLG = 'N'.
          ZPPT0211-STOKZ  = 'X'.
          INSERT ZPPT0211.
        ENDIF.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'Y'로 설정한다.
      UPDATE ZPPT0211
      SET:   "GIFLG   = 'Y' "--> 출고처리 시 업데이트 X
             MBLNR   = GS_MHDRT-MAT_DOC
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = PV_WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN 'N'.
      IF LV_RESWK_G = 'B' AND LV_WERKS_G = 'C'.
*& 전선 꼬리표 삭제...
        DELETE FROM ZPPT0001 WHERE WERKS = PV_R_WERKS
                               AND TAGNR = PV_TAGNR.
      ELSE.
*& 출고전기 취소의 경우, 수요플랜트의 꼬리표정보를 삭제...
        DELETE FROM ZPPT0211 WHERE WERKS = PV_R_WERKS
                               AND TAGNR = PV_TAGNR.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'N'로 설정한다.
      UPDATE ZPPT0211
      SET:   "GIFLG   = 'N' "--> 출고처리 시 업데이트 X
             MBLNR   = ' '
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = PV_WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN  OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_GIREV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001_GIREV USING  PV_MBLNR
                                  PV_MJAHR.

  DATA : LV_GUBUN(1). "--> 전선/비전선 구분자

  DATA : LV_AUFNR LIKE ZPPT0001-AUFNR,
         LV_POSNR LIKE ZPPT0001-POSNR.

  PERFORM BAPI_GOODSMVT_GETDETAIL USING PV_MBLNR
                                        PV_MJAHR.

  CHECK GT_DITM[] IS NOT INITIAL.

  LOOP AT GT_DITM.
    IF GT_DITM-X_AUTO_CRE IS INITIAL.
      IF GT_DITM-MOVE_TYPE = '351'.
        CLEAR : LV_GUBUN.
        CLEAR : ZPPT0134.

        SELECT SINGLE A~GUBUN
          INTO LV_GUBUN
          FROM ZPPT0134 AS A
               INNER JOIN MARC AS B
                ON A~WERKS = B~WERKS
                AND A~DISPO = B~DISPO
         WHERE A~WERKS = GT_DITM-PLANT
           AND B~MATNR = GT_DITM-MATERIAL.

        IF SY-SUBRC = 0.
          SELECT *
            FROM ZPPT0019
           WHERE EBELN  =  GT_DITM-PO_NUMBER
             AND EBELP  =  GT_DITM-PO_ITEM
             AND PLUMI  = '2'
             AND MBLNR  =  PV_MBLNR
             AND MJAHR  =  PV_MJAHR.

            CASE LV_GUBUN.
              WHEN 'C'.  "전선
                PERFORM UPDATE_ZPPT0001_GI USING
                                                  GT_DITM-MATERIAL
                                                  GT_DITM-PLANT
                                                  GT_DITM-MOVE_PLANT
                                                  ZPPT0019-TAGNR
                                                  GT_DITM-PO_NUMBER
                                                  'N'.
              WHEN 'B'.  "비전선
                PERFORM UPDATE_ZPPT0211_GI USING
                                                  GT_DITM-MATERIAL
                                                  GT_DITM-PLANT
                                                  GT_DITM-MOVE_PLANT
                                                  ZPPT0019-TAGNR
                                                  GT_DITM-PO_NUMBER
                                                  'N'.
            ENDCASE.

            UPDATE ZPPT0019
               SET MBLNR   = ' '
                   MJAHR   = ' '
                   MBLNR_F = ' '
            WHERE  EBELN   =  GT_DITM-PO_NUMBER
              AND  EBELP   =  GT_DITM-PO_ITEM
              AND  PLUMI   = '2'
              AND  TAGNR   =  ZPPT0019-TAGNR.
          ENDSELECT.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      DATA(L_CHK) = 'X'.
    ENDIF.
  ENDLOOP.

  CHECK L_CHK = 'X'.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_309_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_309_SCR .

  "*** 스크랩 입고자재 → 전기동 자재로 MTOM

  "--> 변수 CLEAR
  CLEAR : GS_MHDR, GS_MCOD, GS_MHDRT,
          GT_MITM, GT_MITM[], GT_MSRN, GT_MSRN[], GT_RTN, GT_RTN[].

  "--> HEADER SET
  GS_MCOD-GM_CODE = '04'. " TRANSFER POSTING
  GS_MHDR-PSTNG_DATE = GS_ZGTMMT9250-BUDAT. "전표 생성일
  GS_MHDR-DOC_DATE   = GS_ZGTMMT9250-BUDAT. "전표 증빙일
  GS_MHDR-HEADER_TXT = GS_ZGTMMT9250-BKTXT. "전표 헤더 텍스트
*  GS_MHDR-VER_GR_GI_SLIP  = '2'.
*  GS_MHDR-VER_GR_GI_SLIPX = 'X'.

  "--> ITEM SET
  GT_MITM-MATERIAL       = GS_SCRAP-MATNR.      "스크랩 입고자재
  GT_MITM-PLANT          = GS_ZGTMMT9250-WERKS. "플랜트
  GT_MITM-STGE_LOC       = GS_SCRAP-LGORT.      "저장위치
*  GT_MITM-BATCH          = GS_I15-CHARG.       "배치
  GT_MITM-MOVE_TYPE      = '309'.
  GT_MITM-ENTRY_QNT      = GS_SCRAP-MENGE.      "소요량
*  GT_MITM-ENTRY_UOM      = GS_I15-ERFME.       "입력단위
  GT_MITM-MOVE_PLANT     = GS_ZGTMMT9250-WERKS. "이동할 플랜트
  GT_MITM-MOVE_STLOC     = GS_SCRAP-LGORT.      "이동할 저장위치
*  GT_MITM-MOVE_BATCH     = GS_I15-UMCHA.        "입고/출고 배치
*  GT_MITM-VENDOR         = GS_I15-LIFNR.        "구매처
*  GT_MITM-CUSTOMER       = GS_I15-KUNNR.        "고객번호
*  GT_MITM-SALES_ORD      = GS_I15-KDAUF.        "판매오더번호
*  GT_MITM-VAL_SALES_ORD  = GS_I15-KDAUF.        "판매오더번호
*  GT_MITM-S_ORD_ITEM     = GS_I15-KDPOS.        "판매오더 품목번호
*  GT_MITM-VAL_S_ORD_ITEM = GS_I15-KDPOS.        "판매오더 품목번호
  GT_MITM-ITEM_TEXT      = GS_ZGTMMT9250-BKTXT. "품목텍스트
*  GT_MITM-GL_ACCOUNT     = GS_I15-KONTO.        "G/L계정
*  GT_MITM-COSTCENTER     = GS_I15-KOSTL.        "코스트센터
*  GT_MITM-WBS_ELEM       = GS_I15-PS_POSID.     "작업분석구조요소
  GT_MITM-MOVE_MAT       = GS_ZGTMMT9250-UMMAT. "입고/출고 자재
*  GT_MITM-PO_NUMBER      = GS_I15-EBELN.
*  GT_MITM-PO_ITEM        = GS_I15-EBELP.

  APPEND GT_MITM.

  "--> BAPI 호출
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GS_MHDR
      GOODSMVT_CODE         = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET      = GS_MHDRT
*     MATERIALDOCUMENT      = GS_MHDRT-MAT_DOC
*     MATDOCUMENTYEAR       = GS_MHDRT-DOC_YEAR
    TABLES
      GOODSMVT_ITEM         = GT_MITM
      GOODSMVT_SERIALNUMBER = GT_MSRN
      RETURN                = GT_RTN
    EXCEPTIONS
      OTHERS                = 4.

  IF GS_MHDRT IS NOT INITIAL. "--> 성공
    PERFORM BAPI_COMMIT.

    GV_MESSAGE_MM = 'SUCCESS'.
    GV_MBLNR_M = GS_MHDRT-MAT_DOC.

    PERFORM RETURN_MESSAGE_ZGTMMT9250_SCR   USING GV_CO_ORDER
                                            'Y'
                                            GV_MESSAGE_MM.

    PERFORM SAVE_RESULT_ZGTMMT9250_SCR  USING GV_CO_ORDER
                                        'Y'
                                        GV_MESSAGE_MM.
  ELSE. "--> 실패
    PERFORM BAPI_ROLLBACK.

    READ TABLE GT_RTN WITH KEY TYPE = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RTN WITH KEY TYPE = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RTN WITH KEY TYPE = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RTN WITH KEY TYPE = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RTN INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      GV_MESSAGE_MM = GT_RTN-MESSAGE.
    ENDIF.

    PERFORM RETURN_MESSAGE_ZGTMMT9250_SCR   USING GV_CO_ORDER
                                            'E'
                                            GV_MESSAGE_MM.

    PERFORM SAVE_RESULT_ZGTMMT9250_SCR  USING GV_CO_ORDER
                                        'E'
                                        GV_MESSAGE_MM.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_309_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CANCEL_309_SCR .

  DATA : LV_MESSAGE(220).

  CLEAR : GV_MBLNR, GV_MJAHR, GV_BUDAT, GS_MHDRT.
  CLEAR : GS_CHDR, GT_RTN, GT_RTN[].

  SELECT SINGLE MBLNR MJAHR BUDAT
    INTO (GV_MBLNR, GV_MJAHR, GV_BUDAT)
    FROM MKPF
   WHERE MBLNR = GS_ZGTMMT9250C-MBLNR_M.

  GS_CHDR-MAT_DOC    = GV_MBLNR.
  GS_CHDR-DOC_YEAR   = GV_MJAHR.
  GS_CHDR-PSTNG_DATE = GV_BUDAT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_CHDR-MAT_DOC
      MATDOCUMENTYEAR     = GS_CHDR-DOC_YEAR
      GOODSMVT_PSTNG_DATE = GS_CHDR-PSTNG_DATE
    IMPORTING
      GOODSMVT_HEADRET    = GS_MHDRT
    TABLES
      RETURN              = GT_RTN.

  READ TABLE GT_RTN WITH KEY TYPE = 'E'.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.

    LV_MESSAGE = GT_RTN-MESSAGE.

    PERFORM RETURN_MESSAGE_ZGTMMT9250_SCR USING GV_CO_ORDER
                                                'E'
                                                LV_MESSAGE.

    PERFORM SAVE_RESULT_ZGTMMT9250_SCR USING  GV_CO_ORDER
                                              'E'
                                              LV_MESSAGE.
    GV_ERROR = 'X'.
    EXIT.
  ELSE.
    PERFORM BAPI_COMMIT.

    LV_MESSAGE = 'CANCEL SUCCESS'.
    GV_MBLNR_MC = GS_MHDRT-MAT_DOC.

*    PERFORM RETURN_MESSAGE_ZGTMMT9250_SCR USING GV_CO_ORDER
*                                                'Y'
*                                                LV_MESSAGE.
*
*    PERFORM SAVE_RESULT_ZGTMMT9250_SCR USING  GV_CO_ORDER
*                                              'Y'
*                                              LV_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_ZGTMMT9250_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CO_ORDER
*&      --> P_
*&      --> GV_MESSAGE_MM
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_ZGTMMT9250_SCR   USING  PV_CO_ORDER
                                            PV_RESULT
                                            PV_MESSAGE.

  GT_ZGTMMT9250_RESULT = VALUE #( BASE GT_ZGTMMT9250_RESULT
                              ( CO_ORDER = PV_CO_ORDER
                                ZSERNO    = GS_ZGTMMT9250-ZSERNO
                                MBLNR_O   = GV_MBLNR_O
                                MBLNR_I   = GV_MBLNR_I
                                MBLNR_Z   = GV_MBLNR_Z
                                MBLNR_M   = GV_MBLNR_M "--> 309 MTOM
                                MBLNR_OC  = GV_MBLNR_OC
                                MBLNR_IC  = GV_MBLNR_IC
                                MBLNR_ZC  = GV_MBLNR_ZC
                                MBLNR_MC  = GV_MBLNR_MC "--> 309 MTOM
                                ZPROC     = PV_RESULT
                                MESSG     = PV_MESSAGE
                                MATNR     = GS_ZGTMMT9250-MATNR "--> 본 자재코드
                                SCMAT     = GS_SCRAP-MATNR      "--> 스크랩 자재코드
                                UMMAT     = GS_ZGTMMT9250-UMMAT "--> MTOM 자재코드
                                                        ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_RESULT_ZGTMMT9250_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CO_ORDER
*&      --> P_
*&      --> GV_MESSAGE_MM
*&---------------------------------------------------------------------*
FORM SAVE_RESULT_ZGTMMT9250_SCR  USING  PV_CO_ORDER
                                        PV_RESULT
                                        PV_MESSAGE.

  DATA : LS_ZGTMMT9250 TYPE ZGTMMT9250.
  DATA  : LV_TIMESTAMP TYPE TIMESTAMPL.
  CLEAR : LS_ZGTMMT9250, LV_TIMESTAMP.

  GET TIME STAMP FIELD LV_TIMESTAMP.

  LS_ZGTMMT9250 = VALUE #( BASE CORRESPONDING #( GS_ZGTMMT9250 EXCEPT CO_ORDER )
                                   TIMESTAMP = LV_TIMESTAMP
                                   CO_ORDER = PV_CO_ORDER
                                   MBLNR_O  = GV_MBLNR_O
                                   MBLNR_I  = GV_MBLNR_I
                                   MBLNR_Z  = GV_MBLNR_Z
                                   MBLNR_M  = GV_MBLNR_M "--> 309 MTOM
                                   MBLNR_OC = GV_MBLNR_OC
                                   MBLNR_IC = GV_MBLNR_IC
                                   MBLNR_ZC = GV_MBLNR_ZC
                                   MBLNR_MC = GV_MBLNR_MC "--> 309 MTOM
                                   ZRESULT  = PV_RESULT
                                   TEXT     = PV_MESSAGE
                                   ZERNAM   = SY-UNAME
                                   ZERDAT   = SY-DATUM
                                   ZERZET   = SY-UZEIT
                                   ZAENAM   = SY-UNAME
                                   ZAEDAT   = SY-DATUM
                                   ZAEZET   = SY-UZEIT
                                   SCMAT    = GS_SCRAP-MATNR "--> 스크랩 자재코드
                                   ).

  MODIFY ZGTMMT9250 FROM LS_ZGTMMT9250.
  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_kfcm
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM PROCESS_KFCM USING VALUE(PV_MODE) TYPE CHAR2.

  CLEAR: GS_ZGTMMT9250.

  LOOP AT GT_ZGTMMT9250 INTO GS_ZGTMMT9250.

    CLEAR: GV_MBLNR_O, GV_MBLNR_I, GV_MBLNR_Z, GV_MBLNR_M, GV_MBLNR_MC.
    CLEAR: GV_ERROR.

    PERFORM CONVERSION_INPUT_ZGTMMT9250.
    GS_ZGTMMT9250-ZFLAG = PV_MODE.

*- SCRAP 처리
    IF GS_ZGTMMT9250-ZFLAG = 'P'.

*- 수신 데이터 정합성 체크
      PERFORM CHECK_ZGTMMT9250_DATA.
      IF GV_ERROR = 'X'.
        CLEAR GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.

*- Scarp 처리 필요 데이터 발췌
      PERFORM GET_SCRAP_KFCM_DATA.
      IF GV_ERROR = 'X'.
        CLEAR: GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.

*- CO 오더생성
      PERFORM CRE_KFCM_CO_ORDER.
      IF GV_ERROR = 'X'.
        CLEAR: GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.

*- 309 MTM 처리 추가
      PERFORM CREATE_309_SCR.
      IF GV_ERROR = 'X'.
        CLEAR GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.


*- Scrap 취소 처리
    ELSE. " Scrap 취소

      CLEAR : GV_MBLNR_OC, GV_MBLNR_IC, GV_MBLNR_ZC.

*--- 취소 경로는 CRE_KFCM_CO_ORDER를 타지 않아 GV_CO_ORDER가 세팅되지 않는다.
*--- CANCEL_309_SCR은 실패 시 RETURN_MESSAGE_ZGTMMT9250_SCR에
*--- GV_CO_ORDER를 넘기므로, 공백이거나 같은 세션의 이전 건 오더번호가
*--- 회신/이력에 들어간다. 공유 FORM을 고치는 대신 여기서 세팅한다.
      GV_CO_ORDER = GS_ZGTMMT9250-CO_ORDER.

*- 수신 데이터 정합성 체크
      PERFORM CHECK_ZGTMMT9250_DATA.
      IF GV_ERROR = 'X'.
        CLEAR GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.

*--- 재시도(부분 취소 상태)인 경우, 이미 취소된 단계의 취소전표번호를
*--- 회신/이력에 그대로 유지시키기 위해 원본행 값을 선반영한다.
      GV_MBLNR_OC = GS_ZGTMMT9250C-MBLNR_OC.
      GV_MBLNR_IC = GS_ZGTMMT9250C-MBLNR_IC.
      GV_MBLNR_ZC = GS_ZGTMMT9250C-MBLNR_ZC.
      GV_MBLNR_MC = GS_ZGTMMT9250C-MBLNR_MC.

*- 309 MTM 취소 추가
*--- 309를 반드시 먼저 취소해야 한다. 스크랩 자재가 이미 부산물(추가장입)으로
*--- 대체되어 있어, 971 입고취소를 먼저 하면 재고부족으로 실패한다.
*--- 이미 취소된 상태(MBLNR_MC 존재)면 건너뛴다. → 재시도 대응
      IF GS_ZGTMMT9250C-MBLNR_M  IS NOT INITIAL AND
         GS_ZGTMMT9250C-MBLNR_MC IS INITIAL.

        CLEAR GV_MBLNR_MC.
        PERFORM CANCEL_309_SCR.
        IF GV_ERROR = 'X'.
          CLEAR GS_ZGTMMT9250.
          CONTINUE.
        ENDIF.

        PERFORM MODIFY_ZGTMMT9250C_MBLNR USING 'MBLNR_MC' GV_MBLNR_MC.

        WAIT UP TO 1 SECONDS.
      ENDIF.

*- Scrap 처리된 자재문서 취소
      PERFORM CANC_KFCM_MBLNR.
      IF GV_ERROR = 'X'.
        CLEAR GS_ZGTMMT9250.
        CONTINUE.
      ENDIF.

    ENDIF.

  ENDLOOP.
ENDFORM.
