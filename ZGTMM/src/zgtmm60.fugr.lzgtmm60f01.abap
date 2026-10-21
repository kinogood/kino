*----------------------------------------------------------------------*
***INCLUDE LZGTMM60F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAT>_MATNR
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
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_TAB_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAKT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAKT.

  CHECK GT_MAKT[] IS NOT INITIAL.

  SELECT MATNR MAKTX
    FROM MAKT
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
     FOR ALL ENTRIES IN GT_MAKT
   WHERE MATNR = GT_MAKT-MATNR
     AND SPRAS = SY-LANGU.

  SORT GT_MAKT BY MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAKT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_TAB_MATNR
*&      <-- OT_TAB_MAKTX
*&---------------------------------------------------------------------*
FORM SET_MAKT USING PV_MATNR
           CHANGING PV_MAKTX.

  CLEAR : PV_MAKTX.
  CHECK PV_MATNR IS NOT INITIAL.

  READ TABLE GT_MAKT WITH KEY MATNR = PV_MATNR
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  PV_MAKTX = GT_MAKT-MAKTX.

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

      IF GV_ZIFKEY IS NOT INITIAL.
        GT_9000-ZIFKEY = GV_ZIFKEY.
      ELSE.
        GET TIME STAMP FIELD GT_9000-ZIFKEY.
      ENDIF.

      GT_9000-ZIFNO     = PV_ZIFNO.
      GT_9000-SYSTEM_ID = GV_SYSTEM_ID.
      GT_9000-IFDAT     = SY-DATLO.
      GT_9000-IFTIM     = SY-TIMLO.
      GT_9000-IFNAM     = SY-UNAME.

      MODIFY ZGTMMT9000 FROM GT_9000.

    WHEN 'E'. "End
      UPDATE ZGTMMT9000 SET ZSTAT       = PV_ZSTAT
                            MESSAGE     = PV_MESSAGE
                            ERDAT       = GS_CREA-ERDAT
                            ERDAT_LOCAL = GS_CREA-ERDAT_LOCAL
                            ERTIM       = GS_CREA-ERTIM
                            ERTIM_LOCAL = GS_CREA-ERTIM_LOCAL
                            ERNAM       = GS_CREA-ERNAM
                      WHERE ZIFNO       = GT_9000-ZIFNO
                        AND ZIFKEY      = GT_9000-ZIFKEY
                        AND SYSTEM_ID   = GT_9000-SYSTEM_ID.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SNG_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SNG_MSG USING PV_RST
                       PV_MSG.

  GV_RST = PV_RST.
  GV_MSG = PV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTN_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_RTN_MSG USING PV_RST
                       PV_MSG.

  CLEAR : GT_OTN.

  GT_OTN-TYPE    = GV_RST = PV_RST.
  GT_OTN-MESSAGE = GV_MSG = PV_MSG.

  APPEND GT_OTN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_BAPI_MSG USING PV_RST
                       PV_MSG.

  CLEAR : GT_OTN.

  GV_RST = PV_RST.
  GV_MSG = PV_MSG.

  MOVE-CORRESPONDING GT_RTN TO GT_OTN.
  APPEND GT_OTN.

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
*& Form GET_BUDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MBLNR
*&      --> PV_MJAHR
*&---------------------------------------------------------------------*
FORM GET_BUDAT USING PV_MBLNR
                     PV_MJAHR.

  CLEAR : GV_BUDAT.
  CHECK PV_MBLNR IS NOT INITIAL.

  SELECT SINGLE BUDAT
    FROM MKPF INTO GV_BUDAT
   WHERE MBLNR = PV_MBLNR
     AND MJAHR = PV_MJAHR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MBLNR
*&      --> PV_MJAHR
*&      --> PV_BUDAT
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
      GOODSMVT_HEADER  = GS_MHDR
      GOODSMVT_CODE    = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET = GS_MHDRT
*     MATERIALDOCUMENT = GS_MHDRT-MAT_DOC
*     MATDOCUMENTYEAR  = GS_MHDRT-DOC_YEAR
    TABLES
      GOODSMVT_ITEM    = GT_MITM
*     GOODSMVT_SERIALNUMBER = GT_MSRN
      RETURN           = GT_RTN
    EXCEPTIONS
      OTHERS           = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      <-- GV_IV_NO
*&---------------------------------------------------------------------*
FORM GET_NUMBER USING PV_RANGE
                      PV_OBJECT
             CHANGING PV_NUMBER.

  CLEAR : PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = CONV NRNR( PV_RANGE )
      OBJECT                  = CONV NROBJ( PV_OBJECT )
*     QUANTITY                = '1'
*     SUBOBJECT               = ' '
*     TOYEAR                  = '0000'
*     IGNORE_BUFFER           = ' '
    IMPORTING
      NUMBER                  = PV_NUMBER
*     QUANTITY                =
*     RETURNCODE              =
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I72_KUNNR
*&---------------------------------------------------------------------*
FORM CHECK_KUNNR USING PV_KUNNR.

  CHECK GV_CHK   IS INITIAL.
  CHECK PV_KUNNR IS NOT INITIAL.

  SELECT SINGLE KUNNR
    FROM KNA1 INTO @DATA(LV_KUNNR)
   WHERE KUNNR = @PV_KUNNR
     AND LOEVM = @SPACE.

  CHECK SY-SUBRC = 0.
  GV_CHK = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I72_KUNNR
*&---------------------------------------------------------------------*
FORM CHECK_LIFNR USING PV_LIFNR.

  CHECK GV_CHK   IS INITIAL.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE LIFNR
    FROM LFA1 INTO @DATA(LV_LIFNR)
   WHERE LIFNR = @PV_LIFNR
     AND LOEVM = @SPACE.

  CHECK SY-SUBRC = 0.
  GV_CHK = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IV_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_CIV_IV_NO
*&---------------------------------------------------------------------*
FORM GET_IV_NO USING PV_IV_NO.

  CLEAR : GS_PIV.
  CHECK PV_IV_NO IS NOT INITIAL.

  SELECT SINGLE IV_NO
                IV_CANCEL_YN
                OUT_YN
    FROM ZLET0005
    INTO CORRESPONDING FIELDS OF GS_PIV
   WHERE IV_NO = PV_IV_NO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZLET0005
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I72_IV_NO
*&---------------------------------------------------------------------*
FORM UPDATE_ZLET0005 USING PV_IV_NO.

  "통문 취소

  CLEAR : GV_CHK.
  CHECK PV_IV_NO IS NOT INITIAL.

  UPDATE ZLET0005 SET IV_CANCEL_YN = GC_X
                      REQST        = SPACE     "추가(PSJ 25.03.11)
                      CHANGE_DATE  = SY-DATLO
                      CHANGE_TIME  = SY-TIMLO
                WHERE IV_NO        = PV_IV_NO.

  IF SY-SUBRC = 0.
    GV_CHK = GC_S.
    COMMIT WORK.
  ELSE.
    GV_CHK = GC_E.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COM_LE05
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_I70_PERNR
*&---------------------------------------------------------------------*
FORM SET_COM_LE05 USING PV_PERNR.

  GT_LE05-IV_DATE     = SY-DATLO. "발행일자
  GT_LE05-IV_PRINT_YN = GC_X.     "발행여부
  GT_LE05-PRINT_CNT   = 1.        "발행회수

  SELECT SINGLE BZAREA
    FROM ZLET0034 INTO GT_LE05-BZAREA  "사업장
   WHERE WERKS = GT_LE05-WERKS.

  SELECT SINGLE ENAME ORGEH
    FROM ZZPA0001
    INTO ( GT_LE05-ENAME, GT_LE05-ORGEH )
   WHERE PERNR  = PV_PERNR
     AND BEGDA <= SY-DATLO
     AND ENDDA >= SY-DATLO.

  SELECT SINGLE ORGTX
    FROM T527X INTO GT_LE05-ORGTX
   WHERE SPRSL = SY-LANGU
     AND ORGEH = GT_LE05-ORGEH
     AND ENDDA = GC_99991231.

  GT_LE05-PERNR = GT_LE05-BERNR = PV_PERNR. "사원번호
  GT_LE05-BNAME = GT_LE05-ENAME. "포매팅된 이름
  GT_LE05-BRGEH	= GT_LE05-ORGEH. "조직단위
  GT_LE05-BRGTX = GT_LE05-ORGTX. "조직단위 내역

  GT_LE05-CREATE_USER_ID = SY-UNAME. "CHAR8/12 짤림! 확인!!
  GT_LE05-CREATE_DATE    = SY-DATLO.
  GT_LE05-CREATE_TIME    = SY-TIMLO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZLET0005
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_ZLET0005.

  CLEAR : GV_CHK.
  CHECK GT_LE05[] IS NOT INITIAL.

  MODIFY ZLET0006 FROM TABLE GT_LE06.
  MODIFY ZLET0005 FROM TABLE GT_LE05.

  IF SY-SUBRC = 0.
    GV_CHK = GC_S.
    COMMIT WORK.
  ELSE.
    GV_CHK = GC_E.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VB_CREATE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I67_MATNR
*&      --> GT_I67_WERKS
*&      --> GT_I67_CHARG
*&---------------------------------------------------------------------*
FORM VB_CREATE_BATCH USING PV_MATNR
                           PV_WERKS
                           PV_CHARG.

  DATA : LS_YMCHA LIKE MCHA.


  CLEAR : GT_RTN[].

  "Batch 생성 여부 Check
  SELECT SINGLE MANDT
    FROM MCH1 INTO @DATA(LV_MANDT)
   WHERE MATNR = @PV_MATNR
     AND CHARG = @PV_CHARG
     AND LVORM = @SPACE.

  CHECK SY-SUBRC <> 0.

  LS_YMCHA-MATNR         = PV_MATNR.
  LS_YMCHA-WERKS         = PV_WERKS.
  LS_YMCHA-CHARG         = PV_CHARG.
  LS_YMCHA-ZZPJT_NO      = GS_PJT-ZPJT_NO.
  LS_YMCHA-ZZJOB_NO      = GS_PJT-JOB_NO.
  LS_YMCHA-ZZLINE_NO     = GS_PJT-LINE_NO.
  LS_YMCHA-ZZSERIAL_INFO = GS_PJT-SERIAL_INFO.

  CALL FUNCTION 'VB_CREATE_BATCH'
    EXPORTING
      YMCHA                        = LS_YMCHA
*     NEW_LGORT                    =
*     BYPASS_LOCK                  = ' '
*     MESSAGE_WHEN_AUTO            = ' '
*     X_BNCOM                      =
*     QM_ZUSTD                     =
*     REF_MATNR                    =
*     REF_CHARG                    =
*     REF_WERKS                    =
*     KZCLA                        =
*     XKCFC                        =
*     CLASS                        =
*     NO_CHECK_OF_QM_CHAR          = ' '
*     BUFFER_REFRESH               = ' '
*     NO_CHANGE_DOCUMENT           = ' '
*     CHECK_EXTERNAL               = X
*     CHECK_CUSTOMER               = X
*     NO_CFC_CALLS                 = ' '
*     NO_CHANGE_OF_BWTAR           = ' '
*     NO_CLF_INIT                  = ' '
*     READ_BUFFER                  = ' '
*     LS_GOITEM                    =
*     IREF_PCBT_BATCH              =
*   IMPORTING
*     YMCHA                        =
    TABLES
*     CHAR_OF_BATCH                =
*     NEW_BATCH                    =
*     NEW_BATCH_STOLOC             =
      RETURN                       = GT_RTN
    EXCEPTIONS
      NO_MATERIAL                  = 1
      NO_BATCH                     = 2
      NO_PLANT                     = 3
      MATERIAL_NOT_FOUND           = 4
      PLANT_NOT_FOUND              = 5
      STOLOC_NOT_FOUND             = 6
      LOCK_ON_MATERIAL             = 7
      LOCK_ON_PLANT                = 8
      LOCK_ON_BATCH                = 9
      LOCK_SYSTEM_ERROR            = 10
      NO_AUTHORITY                 = 11
      BATCH_EXIST                  = 12
      STOLOC_EXIST                 = 13
      ILLEGAL_BATCH_NUMBER         = 14
      NO_BATCH_HANDLING            = 15
      NO_VALUATION_AREA            = 16
      VALUATION_TYPE_NOT_FOUND     = 17
      NO_VALUATION_FOUND           = 18
      ERROR_AUTOMATIC_BATCH_NUMBER = 19
      CANCELLED                    = 20
      WRONG_STATUS                 = 21
      INTERVAL_NOT_FOUND           = 22
      NUMBER_RANGE_NOT_EXTERN      = 23
      OBJECT_NOT_FOUND             = 24
      ERROR_CHECK_BATCH_NUMBER     = 25
      NO_EXTERNAL_NUMBER           = 26
      NO_CUSTOMER_NUMBER           = 27
      NO_CLASS                     = 28
      ERROR_IN_CLASSIFICATION      = 29
      INCONSISTENCY_IN_KEY         = 30
      REGION_OF_ORIGIN_NOT_FOUND   = 31
      COUNTRY_OF_ORIGIN_NOT_FOUND  = 32
      VENDOR_ERROR                 = 33
      OTHERS                       = 34.

  IF SY-SUBRC <> 0.
    PERFORM BAPI_ROLLBACK.
    GV_ERR = GC_X.

    DATA(LV_MSG) = GV_MATNR && ': 배치 생성 할 프로젝트를 찾지 못했습니다.'(M47).
    PERFORM SET_RTN_MSG USING 'E' LV_MSG.
  ELSE.
    PERFORM BAPI_COMMIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_OBJCL_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_PCHK_VBELN
*&      --> GT_PCHK_VBELP
*&      --> GT_PCHK-EBELN
*&      --> GT_PCHK-EBELP
*&      --> GT_I67_WERKS
*&      --> GT_I67_MATNR
*&      --> GT_I67_CHARG
*&---------------------------------------------------------------------*
FORM BAPI_OBJCL_CHANGE USING PV_VBELN
                             PV_VBELP
                             PV_EBELN
                             PV_EBELP
                             PV_WERKS
                             PV_MATNR
                             PV_CHARG.

  DATA : LT_NUMC LIKE BAPI1003_ALLOC_VALUES_NUM  OCCURS 0 WITH HEADER LINE,
         LT_CHAR LIKE BAPI1003_ALLOC_VALUES_CHAR OCCURS 0 WITH HEADER LINE,
         LT_CURR LIKE BAPI1003_ALLOC_VALUES_CURR OCCURS 0 WITH HEADER LINE,
         LT_RTRN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_CLS[].

  SELECT ATFOR, ATNAM, ATFLV, ATFLB, ATWRT
    FROM ZGTMM_CV_BD_GET_VCOFSO
    INTO CORRESPONDING FIELDS OF TABLE @GT_CLS
   WHERE VBELN = @PV_VBELN
     AND POSNR = @PV_VBELP
     AND WERKS = @PV_WERKS.

  CHECK GT_CLS[] IS NOT INITIAL.

  LOOP AT GT_CLS.
    PERFORM SET_CLS TABLES LT_NUMC.
    PERFORM SET_CLS TABLES LT_CHAR.
    PERFORM SET_CLS TABLES LT_CURR.
  ENDLOOP.

  PERFORM RESET_CHAR TABLES LT_CHAR
                      USING PV_EBELN
                            PV_EBELP.

  CALL FUNCTION 'BAPI_OBJCL_CHANGE'
    EXPORTING
      OBJECTKEY          = CONV OBJNUM( PV_MATNR && PV_CHARG )
      OBJECTTABLE        = 'MCH1'
      CLASSNUM           = 'FT_NBD_GENERAL_001'
      CLASSTYPE          = '023'
*     STATUS             = '1'
*     STANDARDCLASS      =
*     CHANGENUMBER       =
*     KEYDATE            = SY-DATUM
*     NO_DEFAULT_VALUES  = ' '
*     KEEP_SAME_DEFAULTS = ' '
*     OBJECTKEY_LONG     =
*   IMPORTING
*     CLASSIF_STATUS     =
    TABLES
      ALLOCVALUESNUMNEW  = LT_NUMC
      ALLOCVALUESCHARNEW = LT_CHAR
      ALLOCVALUESCURRNEW = LT_CURR
      RETURN             = LT_RTRN.

  READ TABLE LT_RTRN WITH KEY TYPE = GC_E.

  IF SY-SUBRC = 0.
    PERFORM BAPI_ROLLBACK.
    GV_ERR = GC_X.

    DATA(LV_MSG) = GV_MATNR && ': 배치 특성치를 수정하지 못했습니다.'(M48).
    PERFORM SET_RTN_MSG USING 'E' LV_MSG.
  ELSE.
    READ TABLE LT_RTRN WITH KEY TYPE   = GC_I
                                ID     = GC_CL
                                NUMBER = GC_738. "지정을 변경하지 않았습니다

    IF SY-SUBRC <> 0.
      PERFORM BAPI_COMMIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_NUMC
*&---------------------------------------------------------------------*
FORM SET_CLS TABLES PT_VAL.

  CASE GT_CLS-ATFOR.
    WHEN 'NUM' OR 'CURR'.
      ASSIGN COMPONENT 'VALUE_FROM' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_FROM>).
      ASSIGN COMPONENT 'VALUE_TO'   OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_TO>).

      CHECK <LFS_FROM> IS ASSIGNED.
      <LFS_FROM> = GT_CLS-ATFLV.
      <LFS_TO>   = GT_CLS-ATFLB.

    WHEN 'CHAR'.
      ASSIGN COMPONENT 'VALUE_CHAR' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_CHAR>).

      CHECK <LFS_CHAR> IS ASSIGNED.
      <LFS_CHAR> = GT_CLS-ATWRT.

    WHEN OTHERS.
      EXIT.

  ENDCASE.

  ASSIGN COMPONENT 'CHARACT' OF STRUCTURE PT_VAL TO FIELD-SYMBOL(<LFS_ACT>).
  <LFS_ACT> = GT_CLS-ATNAM.

  APPEND PT_VAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHAR
*&      --> PV_EBELN
*&      --> PV_EBELP
*&---------------------------------------------------------------------*
FORM RESET_CHAR TABLES PT_CHAR STRUCTURE BAPI1003_ALLOC_VALUES_CHAR
                 USING PV_EBELN
                       PV_EBELP.

  DATA : LV_WEIGHT TYPE ATWRT30,
         LV_LENGTH TYPE P DECIMALS 3. "변경 2->3(PSJ 25.04.25)

  DEFINE _SET_CHAR.
    CLEAR  PT_CHAR.
    PT_CHAR-CHARACT    = &1.
    PT_CHAR-VALUE_CHAR = &2. CONDENSE PT_CHAR-VALUE_CHAR.
    APPEND PT_CHAR.
  END-OF-DEFINITION.


  "ZGTMM_CV_BD_GET_VCOFSO-ATNAM이 특정값인 경우,(PD_NBD_CM_LENGTH/PD_NBD_CM_WEIGHT)
  "판매오더 클래스 속성값이 아닌 제조지시 구매 데이터로 대체(PSJ 25.03.18)

* CHECK LINE_EXISTS( PT_CHAR[ CHARACT = GC_PD_NBD_CM_LENGTH ] )
*    OR LINE_EXISTS( PT_CHAR[ CHARACT = GC_PD_NBD_CM_WEIGHT ] ).

  DELETE PT_CHAR WHERE ( CHARACT = GC_PD_NBD_CM_WEIGHT
                      OR CHARACT = GC_PD_NBD_CM_LENGTH ).

  SELECT SINGLE ZWEIGHT,
                ZLENGTH_1,
                ZLENGTH_2,
                ZLENGTH_3,
                ZLENGTH_4,
                ZLENGTH_5,
                ZLENGTH_6,
                ZLENGTH_7
    FROM ZGTMM_CV_BD_JNPO_LIST
    INTO @DATA(LS_WL)
   WHERE EBELN = @PV_EBELN
     AND EBELP = @PV_EBELP.

  LV_WEIGHT = LS_WL-ZWEIGHT.
  LV_LENGTH = ( LS_WL-ZLENGTH_1 + LS_WL-ZLENGTH_2 + LS_WL-ZLENGTH_3 + LS_WL-ZLENGTH_4
              + LS_WL-ZLENGTH_5 + LS_WL-ZLENGTH_6 + LS_WL-ZLENGTH_7 ) / 1000.

  _SET_CHAR GC_PD_NBD_CM_WEIGHT LV_WEIGHT.
  _SET_CHAR GC_PD_NBD_CM_LENGTH LV_LENGTH.

* PT_CHAR-VALUE_CHAR = LV_WEIGHT. CONDENSE PT_CHAR-VALUE_CHAR.
* MODIFY PT_CHAR TRANSPORTING VALUE_CHAR WHERE CHARACT = GC_PD_NBD_CM_WEIGHT.
*
* PT_CHAR-VALUE_CHAR = LV_LENGTH. CONDENSE PT_CHAR-VALUE_CHAR.
* MODIFY PT_CHAR TRANSPORTING VALUE_CHAR WHERE CHARACT = GC_PD_NBD_CM_LENGTH.

ENDFORM.
