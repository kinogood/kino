*&---------------------------------------------------------------------*
*& Report ZGTSDR2010_CANCEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTSDR2010_CANCEL MESSAGE-ID ZGTSD01.

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

  PARAMETERS : P_VBELN TYPE VBELN OBLIGATORY,
               P_BUDAT TYPE PODAT,
               P_MBLNR TYPE MBLNR,
               P_TCODE TYPE SY-TCODE,
               P_VBTYP TYPE VBTYPL,
               P_MJAHR TYPE MJAHR.


SELECTION-SCREEN END OF BLOCK B01.

DATA : LS_EMKPF TYPE EMKPF,
       LT_MESG  TYPE TABLE OF MESG,
       LV_MBLNR TYPE MBLNR,
       LV_MSG   TYPE CHAR200.
DATA: LV_ERR(1).
DATA: LV_CNT_R TYPE I,
      LV_CNT_H TYPE I.
DATA: LV_REVERSE(1).
DATA: LV_CNT_B TYPE I,
      LV_CNT_F TYPE I.


SELECT *
  FROM LIPS
 WHERE VBELN EQ @P_VBELN
   AND UECHA EQ '000000'
  INTO TABLE @DATA(LT_LIPS).

SELECT *
  FROM VBFA
 WHERE VBELV EQ @P_VBELN
   AND ( VBTYP_N EQ @IF_SD_DOC_CATEGORY=>GOODS_MOVEMENT  OR "서비스출고
         VBTYP_N EQ @IF_SD_DOC_CATEGORY=>CANCEL_GOODS_MOVEMENT ) "서비스출고 취소
   AND VBTYP_V EQ @IF_SD_DOC_CATEGORY=>DELIVERY
  INTO TABLE @DATA(LT_VBFA).
IF LT_VBFA[] IS INITIAL.
  LV_ERR = 'X'.
  APPEND VALUE #( MSGTY = 'E'
                  TEXT  = TEXT-M01 ) TO LT_MESG.
ENDIF.

IF LV_ERR IS INITIAL.
  SORT LT_VBFA BY VBELN POSNV POSNN.
  LV_CNT_B = LINES( LT_VBFA[] ).
  LOOP AT LT_LIPS INTO DATA(LS_LIPS).
    CLEAR:LV_CNT_H,LV_CNT_R.
    LOOP AT LT_VBFA INTO DATA(LS_VBFA) WHERE VBTYP_N EQ IF_SD_DOC_CATEGORY=>CANCEL_GOODS_MOVEMENT
                                          OR VBTYP_N EQ IF_SD_DOC_CATEGORY=>GOODS_MOVEMENT.
      IF LS_VBFA-VBTYP_N EQ IF_SD_DOC_CATEGORY=>GOODS_MOVEMENT.
        LV_CNT_R = LV_CNT_R + 1.
      ENDIF.

      IF LS_VBFA-VBTYP_N EQ IF_SD_DOC_CATEGORY=>CANCEL_GOODS_MOVEMENT.
        LV_CNT_H = LV_CNT_H + 1.
      ENDIF.
    ENDLOOP.
    IF LV_CNT_R > LV_CNT_H.
      LV_REVERSE = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_REVERSE IS INITIAL.
    LV_ERR = 'X'.
    APPEND VALUE #( MSGTY = 'E'
                    TEXT  = TEXT-M01 ) TO LT_MESG.
  ENDIF.


ENDIF.

IF LV_ERR IS INITIAL.
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
      LV_ERR = 'X'.
      APPEND VALUE #( MSGTY = 'E'
                     TEXT  = LO_ERR->GET_LONGTEXT( )
                     ) TO LT_MESG.
  ENDTRY.

  IF LV_ERR IS INITIAL.
    LOOP AT LT_MESG INTO DATA(LS_MESG) WHERE MSGTY CA 'AE'.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      WAIT UP TO '0.5' SECONDS.

      CLEAR LT_VBFA[].
      SELECT *
        FROM VBFA
       WHERE VBELV EQ @P_VBELN
         AND ( VBTYP_N EQ @IF_SD_DOC_CATEGORY=>GOODS_MOVEMENT  OR "서비스출고
               VBTYP_N EQ @IF_SD_DOC_CATEGORY=>CANCEL_GOODS_MOVEMENT ) "서비스출고 취소
         AND VBTYP_V EQ @IF_SD_DOC_CATEGORY=>DELIVERY
        INTO TABLE @LT_VBFA.
      SORT LT_VBFA BY VBELN POSNV POSNN.
      LV_CNT_F = LINES( LT_VBFA[] ).
      IF LV_CNT_B EQ LV_CNT_F.
        APPEND VALUE #( MSGTY = 'E'
                        TEXT  = TEXT-M02 ) TO LT_MESG.

      ELSE.
        APPEND VALUE #( MSGTY = 'S'
                               ) TO LT_MESG.
      ENDIF.


    ENDIF.
  ENDIF.

ENDIF.

EXPORT LT_MESG TO MEMORY ID 'ZGTSDDOCCANC_SERVICE'.
