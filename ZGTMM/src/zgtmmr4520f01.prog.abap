*----------------------------------------------------------------------*
***INCLUDE ZLER0017F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    E_ROW
                            E_COLUMN.

  IF E_COLUMN = 'ZPDF_DIS'.
    READ TABLE GT_ALV1 INDEX E_ROW.
    IF SY-SUBRC = 0.
      IF GT_ALV1-ZPDF IS NOT INITIAL.

        SET PARAMETER ID 'CV1' FIELD GT_ALV1-ZPDF.
        SET PARAMETER ID 'CV2' FIELD 'VLE'.
        SET PARAMETER ID 'CV3' FIELD '000'.
        SET PARAMETER ID 'CV4' FIELD '00'.


        CALL FUNCTION 'ZLE_FILE_SEL_MULTI'
          EXPORTING
            i_doc    = GT_ALV1-ZPDF
            i_title  = '기타 통문'
            i_append = 'X'
          TABLES
            it_file  = gt_file[].

      ENDIF.
    ENDIF.


  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Module  GET_TR_REQ_INFO  INPUT
*&---------------------------------------------------------------------*
*       기능개선 214781 - 추가
*----------------------------------------------------------------------*
MODULE GET_TR_REQ_INFO INPUT.

  IF WA-REQNO IS NOT INITIAL.
    SELECT SINGLE CARNO
                  DRVNM
                  TELNO
      INTO (WA-TRUCK_NO, WA-DRNAM,
            WA-DRPHO)
      FROM ZLET1000
     WHERE REQNO = WA-REQNO.

    IF SY-SUBRC <> 0.
      MESSAGE E004 WITH '존재하지 않는 요청번호입니다.'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " GET_TR_REQ_INFO  INPUT
*&---------------------------------------------------------------------*
*&      Form  MB22_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALB1_RSNUM  text
*----------------------------------------------------------------------*
FORM MB22_BDC  USING    P_RSNUM.

CLEAR : BDCDATA, G_MSG_T.
  REFRESH: BDCDATA, G_MSG_T.

  CTU_PARAMS-DISMODE  =  'N'.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-NOBINPT = 'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  PERFORM DYNPRO USING:
          'X' 'SAPMM07R'          '0560',
          ' ' 'BDC_OKCODE'        '/00',
          ' ' 'RM07M-RSNUM'        P_RSNUM.


  PERFORM DYNPRO USING:
          'X' 'SAPMM07R'          '0521',
          ' ' 'BDC_OKCODE'        '=DB'.

  PERFORM DYNPRO USING:
          'X' 'SAPLSPO1'          '0100',
          ' ' 'BDC_OKCODE'        '=YES'.

  CALL TRANSACTION 'MB22' USING  BDCDATA
                          OPTIONS FROM CTU_PARAMS
                          MESSAGES INTO G_MSG_T.

  PERFORM  MESSAGE_RTN2.

ENDFORM.                    " MB22_BDC

FORM MESSAGE_RTN2 .

  DATA : L_LINE TYPE I,
           L_MESG(70).

  DESCRIBE TABLE G_MSG_T LINES L_LINE.
  READ TABLE G_MSG_T INDEX L_LINE.

  IF  G_MSG_T-MSGTYP = 'S'.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = G_MSG_T-MSGID
        MSGNR               = G_MSG_T-MSGNR
        MSGV1               = G_MSG_T-MSGV1
        MSGV2               = G_MSG_T-MSGV2
        MSGV3               = G_MSG_T-MSGV3
        MSGV4               = G_MSG_T-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = L_MESG.
  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = G_MSG_T-MSGID
        MSGNR               = G_MSG_T-MSGNR
        MSGV1               = G_MSG_T-MSGV1
        MSGV2               = G_MSG_T-MSGV2
        MSGV3               = G_MSG_T-MSGV3
        MSGV4               = G_MSG_T-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = L_MESG.

    GV_SUBRC = 4.
  ENDIF.

  G_MESG = L_MESG.

ENDFORM.                    " MESSAGE_RTN2
FORM DYNPRO  USING    DYNBEGIN NAME VALUE.

  CLEAR  BDCDATA.

  IF DYNBEGIN = 'X'.
    MOVE:  'X'   TO  BDCDATA-DYNBEGIN,
           NAME  TO  BDCDATA-PROGRAM,
           VALUE TO  BDCDATA-DYNPRO.
  ELSE.
    MOVE:
           NAME  TO  BDCDATA-FNAM,
           VALUE TO  BDCDATA-FVAL.
  ENDIF.

  APPEND BDCDATA.

ENDFORM.                    " dynpro
