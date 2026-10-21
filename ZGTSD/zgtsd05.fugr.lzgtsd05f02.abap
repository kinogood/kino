*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_LOCK_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_TAB_VBELN
*&      --> LV_ABGRU
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
FORM CHECK_LOCK_CODE  USING    PV_VBELN
                      CHANGING PV_NAMETXT
                               PV_CODE
                               PV_ERR.

  DATA : LT_ENQ  TYPE TABLE OF SEQG3,
         LV_GARG TYPE SEQG3-GARG.

  CLEAR : PV_NAMETXT, PV_CODE, PV_ERR, LV_GARG.
  CONCATENATE SY-MANDT PV_VBELN INTO LV_GARG.
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GNAME                 = CONV EQEGRANAME( |VBAK| )
      GARG                  = LV_GARG
      GUNAME                = SPACE
    TABLES
      ENQ                   = LT_ENQ
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  CHECK SY-SUBRC EQ 0.

  LOOP AT LT_ENQ INTO DATA(LS_ENQ).

    CHECK LS_ENQ-GARG+00(03) EQ SY-MANDT          AND
          LS_ENQ-GARG+03(10) EQ PV_VBELN(10).

    PV_CODE = LS_ENQ-GARG+03(10).
    PV_ERR  = 'X'.  EXIT.

  ENDLOOP.

  CHECK PV_ERR EQ 'X'.

  SELECT SINGLE BNAME && '(' && NAME_TEXTC && ')' INTO @PV_NAMETXT
    FROM USER_ADDR
   WHERE BNAME EQ @LS_ENQ-GUNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOC_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_VB_VBELN
*&---------------------------------------------------------------------*
FORM DOC_LOCK  USING    PV_VBELN
               CHANGING PS_RET    STRUCTURE ZSDS_LOG_0001
                        PV_ERR.

  DATA : LV_NAMETXT TYPE USER_ADDR-NAME_TEXTC,
         LV_KUNNR   TYPE KUNNR,
         LV_ERR     TYPE FLAG.

  PERFORM CHECK_LOCK_CODE USING    PV_VBELN
                          CHANGING LV_NAMETXT LV_KUNNR LV_ERR.
  IF LV_ERR EQ 'X'.
    MESSAGE S104(ZGTSD01) WITH LV_NAMETXT LV_KUNNR INTO PS_RET-MESSAGE.
    PS_RET-MTYPE = |E|.
    PV_ERR = 'X'. EXIT.
  ENDIF.

*SALEORDER LOCK
  CALL FUNCTION 'ENQUEUE_EVVBAKE'
    EXPORTING
      MANDT          = SY-MANDT
      VBELN          = PV_VBELN
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  CASE SY-SUBRC.
    WHEN 0.

    WHEN 1.
      PERFORM GET_LOCK_USER USING    PV_VBELN
                            CHANGING LV_NAMETXT.

      MESSAGE S104(ZGTSD01) WITH LV_NAMETXT LV_KUNNR INTO PS_RET-MESSAGE.
      PS_RET-MTYPE = |E|.
      PV_ERR = 'X'. EXIT.
    WHEN OTHERS.
      MESSAGE S098(ZGTSD01) INTO PS_RET-MESSAGE..
      PS_RET-MTYPE = |E|.
      PV_ERR = 'X'. EXIT.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LOCK_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_LOCK_USER USING PV_VBELN
                CHANGING PV_NAMETXT.

  DATA : LT_ENQ  TYPE TABLE OF SEQG3,
         LV_GARG TYPE SEQG3-GARG.

  CLEAR PV_NAMETXT.
  CONCATENATE SY-MANDT PV_VBELN INTO LV_GARG.

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GNAME                 = CONV EQEGRANAME( |VBAK| )
      GARG                  = LV_GARG
      GUNAME                = SPACE
    TABLES
      ENQ                   = LT_ENQ
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  CHECK SY-SUBRC EQ 0.

  LOOP AT LT_ENQ INTO DATA(LS_ENQ).
    CHECK LS_ENQ-GARG+00(03) EQ SY-MANDT          AND
          LS_ENQ-GARG+03(10) EQ PV_VBELN(10).

    SELECT SINGLE BNAME && '(' && NAME_TEXTC && ')' INTO @PV_NAMETXT
      FROM USER_ADDR
     WHERE BNAME EQ @LS_ENQ-GUNAME.
    EXIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOC_UNLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOC_UNLOCK USING PV_VBELN.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
    EXPORTING
      MANDT = SY-MANDT
      VBELN = PV_VBELN.

ENDFORM.
