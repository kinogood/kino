*&---------------------------------------------------------------------*
*&  Include           ZSDR1001B                                        *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
*      -->I_PROGRAM  프로그램.
*      -->I_DYNPRO   화면번호.
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING I_PROGRAM TYPE BDCDATA-PROGRAM
                      I_DYNPRO  TYPE BDCDATA-DYNPRO.
  DATA LS_BDCDATA LIKE BDCDATA.
  CLEAR LS_BDCDATA.
  LS_BDCDATA-PROGRAM  = I_PROGRAM.
  LS_BDCDATA-DYNPRO   = I_DYNPRO.
  LS_BDCDATA-DYNBEGIN = 'X'.
  APPEND LS_BDCDATA TO GT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
*      -->I_FNAM  필드이름.
*      -->I_FVAL  필드값.
*----------------------------------------------------------------------*
FORM BDC_FIELD USING I_FNAM
                     I_FVAL.
  DATA: LS_BDCDATA LIKE BDCDATA,
        LC_NODATA.
  IF I_FVAL <> LC_NODATA.
    CLEAR LS_BDCDATA.
    LS_BDCDATA-FNAM = I_FNAM.
    LS_BDCDATA-FVAL = I_FVAL.
    APPEND LS_BDCDATA TO GT_BDCDATA.
  ENDIF.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_FB60
*&---------------------------------------------------------------------*
*        트랜잭션 Call.
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_FB01.

* BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.

  CLEAR : GV_BELNR.


** FI요청으로 반영함. : ZGGBR000(UF02)에서 사용(주석처리 되어있음)
  EXPORT 'ZSD1R1000' TO MEMORY ID 'ZFITCODE'.

  CALL TRANSACTION 'FB01'  USING  GT_BDCDATA
                          UPDATE  'S'
                            MODE  P_MODE
                        MESSAGES INTO LT_BDCMSG.

  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'F5' AND
       SY-MSGNO EQ '312'.
      READ TABLE LT_BDCMSG WITH KEY MSGTYP = 'S'
                                    MSGID  = 'F5'
                                    MSGNR  = '312'.

      GV_BELNR = LT_BDCMSG-MSGV1.

    ENDIF.
  ENDIF.

  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.

        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.

** CBO테이블 관리.
** 미지급전표 생성여부 Check.
  CHECK NOT GV_BELNR IS INITIAL  AND
            GV_BELNR+0(2) EQ '12'.    " 전표번호의 Number Range

  MOVE-CORRESPONDING  GT_HEADER  TO  G_TMP_T.
  G_TMP_T-C_WAERK  =  GT_HEADER-WAERK.
  G_TMP_T-BELNR    =  GV_BELNR.

  APPEND  G_TMP_T.
  CLEAR  G_TMP_T.

ENDFORM.                    " CALL_TRANSACTION_FB60
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_VA02
*&---------------------------------------------------------------------*
*        트랜잭션 Call.
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_VA02 USING P_VBELN.

* BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.
  CALL TRANSACTION 'VA02' USING  GT_BDCDATA
                           UPDATE 'S'
                           MODE   P_MODE
                           MESSAGES INTO LT_BDCMSG.

  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'VL' AND
       SY-MSGNO EQ '312'.

    ENDIF.
  ENDIF.
  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = P_VBELN.
          GT_BDCMSG-UPDKZ = 'U'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.
        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = P_VBELN.
            GT_BDCMSG-UPDKZ = 'U'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = P_VBELN.
      GT_BDCMSG-UPDKZ = 'U'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CALL_TRANSACTION_VA02
*&---------------------------------------------------------------------*
*&      Form  call_transaction_fb08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_FB08 .

* BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.

  CLEAR : GV_BELNR.

*{
* ZGGBR000 에서 사용
  DATA : TCODE_MEMORY LIKE SY-TCODE.
  TCODE_MEMORY = 'ZSDR1000_1'.
  EXPORT TCODE_MEMORY TO MEMORY ID 'TCODE_MEMORY'.

  CALL TRANSACTION 'FB08' USING  GT_BDCDATA
                          UPDATE 'S'
                          MODE   P_MODE
                          MESSAGES INTO LT_BDCMSG.


  FREE MEMORY ID 'TCODE_MEMORY'.


  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'F5' AND
       SY-MSGNO EQ '312'.
      READ TABLE LT_BDCMSG WITH KEY MSGTYP = 'S'
                                    MSGID  = 'F5'
                                    MSGNR  = '312'.

      GV_BELNR = LT_BDCMSG-MSGV1.

** 정상적으로 수행이 되면 부가세전표관련 테이블 삭제
      IF  SY-SUBRC  =  0.
        DELETE
          FROM  ZSD0016T
         WHERE  BELNR  =  GT_HEADER-BELNR.
      ENDIF.

    ENDIF.
  ENDIF.

*{
  FREE MEMORY ID 'TCODE_MEMORY'.
*} 2021.03.09

  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.
        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " call_transaction_fb08

*&---------------------------------------------------------------------*
*&      Form  call_transaction_fb08_2
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_FB08_2 .

* BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.

  CLEAR : GV_BUGA_BELNR.

  CALL TRANSACTION 'FB08'   USING  GT_BDCDATA
                           UPDATE  'S'
                             MODE  P_MODE
                         MESSAGES INTO LT_BDCMSG.

  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'F5' AND
       SY-MSGNO EQ '312'.
      READ TABLE LT_BDCMSG WITH KEY MSGTYP = 'S'
                                    MSGID  = 'F5'
                                    MSGNR  = '312'.

      GV_BUGA_BELNR = LT_BDCMSG-MSGV1.

** 정상적으로 수행이 되면 부가세전표관련 테이블 삭제
** 삭제가 아니라 부가세전표번호/부가세금액만 Clear.
*      if  sy-subrc  =  0.
**          delete
**            from  zsd0016t
**           where  buga_belnr  =  gt_header-buga_belnr.
*        update  zsd0016t
*           set  buga_amnt  =  0
*                k_waerk    =  ' '
*                buga_belnr =  ' '
*                aedat      =  sy-datum
*                aenam      =  sy-uname
*         where  buga_belnr =  gt_header-buga_belnr.
*      endif.

    ENDIF.
  ENDIF.

  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BUGA_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.

        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BUGA_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.

    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BUGA_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " call_transaction_fb08_2

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_fb08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_FIELD_DATA_FB08 .

  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0105'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'UF05A-STGRD'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM BDC_FIELD       USING 'RF05A-BELNS'
                                GT_HEADER-BELNR.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                S_VKORG-LOW.
  PERFORM BDC_FIELD       USING 'RF05A-GJAHS'
                                 P_SPMON(4).
*                                sy-datum(4).
  PERFORM BDC_FIELD       USING 'UF05A-STGRD'
                                '01'.

ENDFORM.                    " fill_field_data_fb08

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_fb08_2
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA_FB08_2 .

  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0105'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'UF05A-STGRD'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
*  perform bdc_field       using 'RF05A-BELNS'
*                                gt_header-buga_belnr.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                S_VKORG-LOW.
  PERFORM BDC_FIELD       USING 'RF05A-GJAHS'
                                 P_SPMON(4).
*                                sy-datum(4).
  PERFORM BDC_FIELD       USING 'UF05A-STGRD'
                                '01'.

ENDFORM.                    " fill_field_data_fb08_2

*&---------------------------------------------------------------------*
*&      Form  execute_va02_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXECUTE_VA02_BDC .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_FLAG, LV_FLAG2.
  REFRESH GT_BDCDATA.

  LOOP AT GT_HEADER WHERE BOX = 'X'.

** c_hkont 계정 결정 수정 written by choi seok won
    PERFORM CHANGE_HKONT.
* 분할 정산 오더삭제
    PERFORM DELETE_SALES_DOC USING  GT_HEADER-VBELN.
    PERFORM CALL_TRANSACTION_VA02 USING GT_HEADER-VBELN.
  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_va02_bdc
*&---------------------------------------------------------------------*
*&      Form  delete_sales_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBELN  text
*----------------------------------------------------------------------*
FORM DELETE_SALES_DOC  USING    P_VBELN.

  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '0102'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'VBAK-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'VBAK-VBELN'
                                P_VBELN.

  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/ELOES'.

ENDFORM.                    " delete_sales_doc

*&---------------------------------------------------------------------*
*&      Form  change_order_va02
*&---------------------------------------------------------------------*
FORM CHANGE_ORDER_VA02 .

**-> CCM : 12.06.2023 13:43:27 / ZLSGSD3
*  DATA : l_va_lifnr LIKE vbpa-lifnr,
*         l_vf_lifnr LIKE vbpa-lifnr.
*
*  CLEAR : l_va_lifnr, l_vf_lifnr.
*
**  DATA : L_VA_PERNR LIKE VBPA-PERNR,
**         L_VF_PERNR LIKE VBPA-PERNR.
**
**  CLEAR : L_VA_PERNR, L_VF_PERNR.
**<-
*
*  SELECT  SINGLE *
*    FROM  knvp
*   WHERE  kunnr = gt_header-bonem
*     AND  vkorg = gt_header-vkorg
*     AND  vtweg = gt_header-vtweg
*     AND  spart = gt_header-spart
*     AND  parvw = 'VE'
*     AND  parza = '001'.
*
*  CHECK sy-subrc EQ 0.
*
**-> CCM : 12.06.2023 13:43:00 / ZLSGSD3
*** 정산오더의 영업사원 벤더 Query
*  SELECT  SINGLE lifnr
*    INTO  l_va_lifnr
*    FROM  vbpa
*   WHERE  vbeln = gt_header-vbeln
*     AND  posnr = '0'
*     AND  parvw = 'VE'.
*
*
****기존 로직 주석 처리
**** 정산오더의 영업사원을 Query
**  SELECT  SINGLE PERNR
**    INTO  L_VA_PERNR
**    FROM  VBPA
**   WHERE  VBELN = GT_HEADER-VBELN
**     AND  POSNR = '0'
**     AND  PARVW = 'VE'.
**<-
*
*  READ TABLE gt_item WITH KEY knuma = gt_header-knuma.
*
**-> CCM : 12.06.2023 13:44:41 / ZLSGSD3
*** 대금청구문서의 영업벤더 Query
*  SELECT  SINGLE lifnr
*    INTO  l_vf_lifnr
*    FROM  vbpa
*   WHERE  vbeln = gt_item-vbeln2
*     AND  posnr = '0'
*     AND  parvw = 'VE'.
*
*  CHECK l_va_lifnr NE l_vf_lifnr.
*
****기존 로직 주석 처리
**** 대금청구문서의 영업사원을 Query
**  SELECT  SINGLE PERNR
**    INTO  L_VF_PERNR
**    FROM  VBPA
**   WHERE  VBELN = GT_ITEM-VBELN2
**     AND  POSNR = '0'
**     AND  PARVW = 'VE'.
*
*
**  CHECK L_VA_PERNR NE L_VF_PERNR.
**<-
*
*  CLEAR : gt_bdcdata, gt_bdcdata[].
*
*  PERFORM bdc_dynpro      USING 'SAPMV45A' '0102'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'VBAK-VBELN'
*                                gt_header-vbeln.
*
*  PERFORM bdc_dynpro      USING 'SAPMV45A' '4001'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=KPAR_SUB'.
*
*  PERFORM bdc_dynpro      USING 'SAPMV45A' '4002'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=LISTBOX1'.
*  PERFORM bdc_field       USING 'GV_FILTER'
*                                'PARPE'.
*
*  PERFORM bdc_dynpro      USING 'SAPMV45A' '4002'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=SICH'.
**-> CCM : 12.06.2023 13:46:35 / ZLSGSD3
*** BDC 화면 필드 / 벤더코드 변경
*  PERFORM bdc_field       USING 'GVS_TC_DATA-REC-PARTNER_EXT(01)'
*                                l_vf_lifnr.
*
**  PERFORM BDC_FIELD       USING 'GVS_TC_DATA-REC-PARTNER(01)'
**                                L_VF_PERNR.
**<-
*
** BDC Detail Message.
*  DATA: lt_bdcmsg TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
*  CALL TRANSACTION 'VA02' USING  gt_bdcdata
*                           UPDATE 'S'
*                           MODE   p_mode
*                           MESSAGES INTO lt_bdcmsg.
*
*  IF  sy-subrc  NE  0.
*    MESSAGE e002 WITH '영업사원 변경중 Error :' lt_bdcmsg-msgv1.
*  ENDIF.

ENDFORM.                    " change_order_va02
*&---------------------------------------------------------------------*
*&      Form  change_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_HKONT .

  DATA : LS_KTOKD LIKE KNA1-KTOKD.
  CLEAR: LS_KTOKD.

  DATA : LS_VTWEG LIKE KONA-VTWEG.
  CLEAR: LS_VTWEG.

  IF GT_HEADER-VKORG = '3000'.
* 계약의 유통경로와 판매오더의 유통경로는 동일.
    SELECT SINGLE VTWEG
      INTO LS_VTWEG
      FROM KONA
      WHERE KNUMA = GT_HEADER-KNUMA.

    IF LS_VTWEG = '10'.
      C_HKONT = '6310317'.
      H_HKONT = '2150101'.
    ELSE.
      C_HKONT = '6430101'.
      H_HKONT = '2150106'.
    ENDIF.
  ELSE.
    C_HKONT = '6430101'.
    H_HKONT = '2150106'.
  ENDIF.



ENDFORM.                    " change_hkont
