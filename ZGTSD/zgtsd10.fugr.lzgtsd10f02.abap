*----------------------------------------------------------------------*
***INCLUDE LZGTSD10F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form BDC_PROCESS_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_PROCESS_RTN .
  CLEAR : GT_BDCTAB, G_MSG_T, G_CNT.
  REFRESH : GT_BDCTAB, G_MSG_T.

  G_CNT  =  1.

  LOOP AT G_TMP_T.

    PERFORM  RECORD_INIT_RTN.

    LOOP AT G_BDC_T WHERE VBELN = G_TMP_T-VBELN.

      PERFORM  RECORD_RTN.

    ENDLOOP.

    PERFORM  RECORD_END_RTN.

    G_CNT  =  G_CNT  +  1.

  ENDLOOP.

  PERFORM  RECORD_SAVE_RTN.

** Transaction option

  IF  G_UCOMM  =  'VF01'  OR     " 대금청구 온라인
      G_UCOMM  =  'VF01_54'.     " 대금청구 온라인(동박)
    G_IMODE  =  'E'.
  ELSEIF G_TCODE = 'ZGTSDR0120' OR G_TCODE = 'ZGTSDR1080'.  "부스덕트
    G_IMODE  =  'N'.
  ENDIF.

  CTU_PARAMS-DISMODE  =  G_IMODE.
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'VF01' USING GT_BDCTAB
                          OPTIONS FROM CTU_PARAMS
                          MESSAGES INTO G_MSG_T.

*  G_BDC_T-SUBRC = SY-SUBRC.

*  IF  G_UCOMM  =  'VF01'.     " 대금청구 온라인
    PERFORM  MESSAGE_RTN_VF01.
*  ELSE.
*    PERFORM  MESSAGE_RTN.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECORD_INIT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECORD_INIT_RTN .
  DATA : L_FKDAT(8),
         L_VBELN    LIKE LIPS-VBELN,
         L_CNT      TYPE I.
  CLEAR : L_VBELN, L_CNT.

  IF  G_FKDAT  <>  '00000000'.
    L_FKDAT  =  G_FKDAT.
  ELSE.
    L_FKDAT  =  SPACE.
  ENDIF.

  IF  G_CNT  =  1.

    DESCRIBE TABLE G_TMP2_T LINES L_CNT.

    IF  L_CNT  >  1.
      READ TABLE G_TMP2_T INDEX 2.
      L_VBELN  =  G_TMP2_T-VBELN.
    ENDIF.

    PERFORM  DYNPRO  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN',
                 ' '  'KOMFK-VBELN(01)'  ' '.

    IF  G_UCOMM  =  'BDC2'.      " g_flag  =  'X'.

*          perform  dynpro  using :
*                   'X'  'SAPMV60A'         '0102',
*                   ' '  'BDC_OKCODE'       '=PICK',
*                   ' '  'RV60A-FKDAT'      l_fkdat,
*                   ' '  'RV60A-FKART'      'ZF2',    " 적송가매출
*                   ' '  'RV60A-SELKZ(01)'  'X',
*                   ' '  'KOMFK-VBELN(01)'  g_tmp_t-vbeln,
*                   ' '  'KOMFK-VBELN(02)'  l_vbeln.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '/00',
               ' '  'RV60A-FKART'      'ZF2',    " 적송가매출
               ' '  'KOMFK-VBELN(01)'  ' ',
               ' '  'KOMFK-VBELN(02)'  ' '.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-SELKZ(01)'  'X',
               ' '  'KOMFK-VBELN(01)'  G_TMP_T-VBELN,
               ' '  'KOMFK-VBELN(02)'  L_VBELN.

    ELSE.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-SELKZ(01)'  'X',
               ' '  'KOMFK-VBELN(01)'  G_TMP_T-VBELN,
               ' '  'KOMFK-VBELN(02)'  L_VBELN.

    ENDIF.

  ELSEIF  G_CNT  =  2.

** Changed By SDC06 : 2005-06-13
** 하나의 문서에 여러개의 품목이 있을경우도 있으므로 변경.
    IF  G_UCOMM  =  'BDC2'.      " g_flag  =  'X'.

      PERFORM  DYNPRO  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN'.

*      perform  dynpro  using :
*               'X'  'SAPMV60A'         '0102',
*               ' '  'BDC_CURSOR'       'KOMFK-VBELN(02)',
*               ' '  'BDC_OKCODE'       '=PICK',
*               ' '  'RV60A-FKDAT'      l_fkdat,
*               ' '  'RV60A-FKART'      'ZF2',    " 적송가매출
*               ' '  'RV60A-SELKZ(02)'  'X'.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(01)',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-FKART'      'ZF2',    " 적송가매출
               ' '  'RV60A-SELKZ(01)'  'X'.

    ELSE.

      PERFORM  DYNPRO  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN'.

*      perform  dynpro  using :
*               'X'  'SAPMV60A'         '0102',
*               ' '  'BDC_CURSOR'       'KOMFK-VBELN(02)',
*               ' '  'BDC_OKCODE'       '=PICK',
*               ' '  'RV60A-FKDAT'      l_fkdat,
*               ' '  'RV60A-SELKZ(02)'  'X'.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(01)',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-SELKZ(01)'  'X'.

    ENDIF.

  ELSE.

    PERFORM  DYNPRO  USING :
                 'X'  'SAPMV60A'         '0102',
                 ' '  'BDC_OKCODE'       '=FKAN'.

    IF  G_UCOMM  =  'BDC2'.        " g_flag  =  'X'.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(02)',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-FKART'      'ZF2',    " 적송가매출
               ' '  'RV60A-SELKZ(02)'  'X',
               ' '  'KOMFK-VBELN(02)'  G_TMP_T-VBELN.

    ELSE.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_CURSOR'       'KOMFK-VBELN(02)',
               ' '  'BDC_OKCODE'       '=PICK',
               ' '  'RV60A-FKDAT'      L_FKDAT,
               ' '  'RV60A-SELKZ(02)'  'X',
               ' '  'KOMFK-VBELN(02)'  G_TMP_T-VBELN.

    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECORD_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECORD_RTN .
  PERFORM  DYNPRO  USING :
                   'X'  'SAPLV60P'         '4413',
                   ' '  'BDC_OKCODE'       '=POPO'.

  PERFORM  DYNPRO  USING :
                   'X'  'SAPLV60P'         '0251',
                   ' '  'BDC_OKCODE'       '=POSI',
                   ' '  'RV45A-POSNR'      G_BDC_T-POSNR.

  PERFORM  DYNPRO  USING :
                   'X'  'SAPLV60P'         '4413',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'RV60A-SELKZ(01)'  'X'.
  IF G_TAD IS INITIAL.
    PERFORM  DYNPRO  USING :   ' '  'VDICS-ORFMNG(01)' G_BDC_T-REMN_QTY.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECORD_END_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECORD_END_RTN .
  PERFORM  DYNPRO  USING :
                   'X'  'SAPLV60P'         '4413',
                   ' '  'BDC_OKCODE'       '=RUEB'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECORD_SAVE_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECORD_SAVE_RTN .
  IF  G_UCOMM  =  'VF01'.            " 대금청구 온라인

    IF  G_GUBUN  =   'E'.

      READ TABLE G_BDC_T WITH KEY VBELN = G_TMP_T-VBELN.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=UEBK'.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '9000',
               ' '  'BDC_OKCODE'       '=FKVW',
               ' '  'GV_KURSK'         G_BDC_T-KURRF.

    ELSE.

      PERFORM  DYNPRO  USING :
             'X'  'SAPMV60A'         '0102',
             ' '  'BDC_OKCODE'       '=UEBK'.

    ENDIF.

  ELSEIF  G_UCOMM  =  'VF01_54'.     " 대금청구 온라인(동박)

    PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=UEBK'.
    PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0104',
               ' '  'BDC_OKCODE'       '=KFKO'.
    PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '6001',
               ' '  'BDC_OKCODE'       '=V69A_KONX'.

  ELSE.

** 2005/05/11 윤방희 추가(로컬 부분)
    IF  G_GUBUN  =  'E'.      " 로칼일 경우.

      READ TABLE G_BDC_T WITH KEY VBELN = G_TMP_T-VBELN.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0102',
               ' '  'BDC_OKCODE'       '=UEBK'.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '9000',
               ' '  'BDC_OKCODE'       '=FKVW',
               ' '  'GV_KURSK'         G_BDC_T-KURRF.

      PERFORM  DYNPRO  USING :
               'X'  'SAPMV60A'         '0104',
               ' '  'BDC_OKCODE'       '=SICH'.

    ELSE.

      PERFORM  DYNPRO  USING :
             'X'  'SAPMV60A'         '0102',
             ' '  'BDC_OKCODE'       '=SICH'.

    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_RTN_VF01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MESSAGE_RTN_VF01 .
  DATA : L_VBELN    LIKE VBRP-VBELN,
         L_MESG(70).
  CLEAR : L_VBELN, L_MESG.

** VBUP의 FKSTA가 'C'일 경우 대금청구가 완료.
*-> CCM : 13.04.2023 16:27:39 / ZLSGSD3
*  SELECT  SINGLE *
*    FROM  VBUP
*   WHERE  VBELN  =  G_BDC_T-VBELN
*     AND  POSNR  =  G_BDC_T-POSNR
**     and  fksta  =  'C'.
*     AND  FKSTA  IN  ('B', 'C').

  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @G_BDC_T-VBELN
     AND FKSTK EQ 'C'
    INTO @DATA(LS_LIKP).
*<-

  IF  SY-SUBRC  =  0.

*-> CCM : 13.04.2023 16:32:20 / ZLSGSD3
*    SELECT  SINGLE VBELN
*      INTO  L_VBELN
*      FROM  VBRP
*     WHERE  VGBEL  =  G_BDC_T-VBELN.

    SELECT SINGLE VBELN
      INTO L_VBELN
      FROM VBRP
     WHERE VGBEL = G_BDC_T-VBELN
       AND DRAFT = SPACE.
*<-


    CONCATENATE  '대금청구문서 ' L_VBELN '이(가) 생성되었습니다'
           INTO  L_MESG SEPARATED BY SPACE.

    G_BDC_T-MESG   =  L_MESG.
    G_BDC_T-SUBRC  = 0.

  ELSE.
    G_BDC_T-MESG  =  '비정상적으로 수행.'.
    G_BDC_T-SUBRC  = 4.
  ENDIF.

  G_SUBRC  =  G_BDC_T-SUBRC.
  G_MESG  =  G_BDC_T-MESG.

  MODIFY G_BDC_T TRANSPORTING SUBRC MESG
                       WHERE VBELN = G_TMP_T-VBELN.

*  modify g_itab_t transporting mesg
*                       where mark = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MESSAGE_RTN .
  DATA : L_LINE TYPE I.

  DESCRIBE TABLE G_MSG_T LINES L_LINE.
  READ TABLE G_MSG_T INDEX L_LINE.

  IF  G_MSG_T-MSGTYP = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
*       msgid               = 'VF'
*       msgnr               = '311'
        MSGID               = G_MSG_T-MSGID
        MSGNR               = G_MSG_T-MSGNR
        MSGV1               = G_MSG_T-MSGV1
        MSGV2               = G_MSG_T-MSGV2
        MSGV3               = G_MSG_T-MSGV3
        MSGV4               = G_MSG_T-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = G_BDC_T-MESG.

    G_BDC_T-SUBRC  =  0.

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
        MESSAGE_TEXT_OUTPUT = G_BDC_T-MESG.

    G_BDC_T-SUBRC  =  4.

  ENDIF.

  G_SUBRC  =  G_BDC_T-SUBRC.
  G_MESG  =  G_BDC_T-MESG.

  MODIFY G_BDC_T TRANSPORTING SUBRC MESG
                       WHERE VBELN = G_TMP_T-VBELN.

*  modify g_itab_t transporting mesg
*                       where mark = 'X'.
ENDFORM.
