*&---------------------------------------------------------------------*
*& Report ZGTSDR0120_CANCEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTSDR0120_CANCEL MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR0120_CANCELSEL. " Selection-Screen

DATA : LS_EMKPF TYPE EMKPF,
       LT_MESG  TYPE TABLE OF MESG,
       LV_MBLNR TYPE MBLNR,
       LV_MSG   TYPE CHAR200.

TRY.
    CALL FUNCTION 'WS_REVERSE_GOODS_ISSUE'
      EXPORTING
        I_VBELN                   = P_VBELN
        I_BUDAT                   = P_BUDAT
        I_MBLNR                   = P_MBLNR
        I_TCODE                   = P_TCODE
        I_VBTYP                   = P_VBTYP
        I_MJAHR                   = P_MJAHR
      IMPORTING
        ES_EMKPF                  = LS_EMKPF
      TABLES
        T_MESG                    = LT_MESG
      EXCEPTIONS
        ERROR_MESSAGE             = 0
        ERROR_REVERSE_GOODS_ISSUE = 1
        OTHERS                    = 2.
  CATCH CX_ROOT INTO DATA(LO_ERR).
    MESSAGE S001 WITH LO_ERR->GET_LONGTEXT( ) DISPLAY LIKE 'E'.
ENDTRY.

IF LS_EMKPF-MBLNR IS NOT INITIAL.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

  LV_MBLNR = LS_EMKPF-MBLNR .
  EXPORT LV_MBLNR TO MEMORY ID 'ZPODCANC'.

ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*->>[가온전선]-------------------------------------------S 2025.12.15
  LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AEX'.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID
          TYPE 'E'
        NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
          INTO DATA(LV_MESSAGE).
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = TEXT-M01.
    ENDIF.
    APPEND VALUE #( MSGTY = 'E'
                    TEXT  = LV_MESSAGE ) TO LT_MESG.
  ENDIF.
*-<<[가온전선]-------------------------------------------E 2025.12.15
ENDIF.

*->>[가온전선]-------------------------------------------S 2025.12.15
EXPORT LV_MBLNR LT_MESG TO MEMORY ID 'ZGTSDDOCANC'.
*-<<[가온전선]-------------------------------------------E 2025.12.15
