FUNCTION Z_TI_SET_POST_DATA_FOR_COST.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IM_BUKRS) TYPE  BUKRS OPTIONAL
*"     VALUE(IM_EXPGR) TYPE  ZTIEXPGR OPTIONAL
*"     VALUE(IM_FIXED_DATE) TYPE  C DEFAULT SPACE
*"     VALUE(IM_MONSC) TYPE  ZTIMONSC DEFAULT 'S'
*"  EXPORTING
*"     VALUE(EX_ANSWER) TYPE  C
*"     VALUE(EX_SUCCESS) TYPE  I
*"     VALUE(EX_ERROR) TYPE  I
*"  TABLES
*"      CT_ZTITCSK STRUCTURE  ZTISCSK OPTIONAL
*"      CT_ZTITCSP STRUCTURE  ZTISCSIT OPTIONAL
*"      CT_ZTITCSO STRUCTURE  ZTITCSO OPTIONAL
*"  EXCEPTIONS
*"      NOT_POSTING
*"----------------------------------------------------------------------


  DATA: L_CSTCT TYPE ZTICSTCT,
        L_ICSNO TYPE ZTIICSNO.

  CLEAR: EX_ANSWER,  EX_SUCCESS, EX_ERROR,   XZTITCSP,   ZTITCSK,
         IT_ZTITCSK, IT_ZTITCSP, IT_ZTITCSO.
  REFRESH: XZTITCSP, IT_ZTITCSK, IT_ZTITCSP, IT_ZTITCSO.

  IT_ZTITCSK[] = CT_ZTITCSK[].
  IT_ZTITCSP[] = CT_ZTITCSP[].
  IT_ZTITCSO[] = CT_ZTITCSO[].

  IF IM_MONSC EQ 'S'.
    DESCRIBE TABLE IT_ZTITCSK LINES G_LINE.
    CASE G_LINE.
      WHEN 1.
      WHEN 0.
        MESSAGE E943 RAISING NOT_POSTING.
      WHEN OTHERS.
        MESSAGE E944 RAISING NOT_POSTING.
    ENDCASE.
  ENDIF.
*  BREAK-POINT.

* Company code
  SELECT *
    FROM T001 UP TO 1 ROWS
   WHERE BUKRS EQ IM_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    MESSAGE E348(M7) WITH DFIES-SCRTEXT_M RAISING NOT_POSTING.
  ENDIF.

*> 회사별 프로세스.
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH T001-BUKRS RAISING NOT_POSTING.
  ENDIF.

*>
  CASE IM_EXPGR.
    WHEN 'L'. ">수입 은행관련비용.
      L_CSTCT = 'B'.
    WHEN 'I'. ">수입 적하보험료.
      L_CSTCT = 'H'.
    WHEN 'B'. ">수입 B/L(AWB) 관련비용.
      L_CSTCT = 'M'.
    WHEN 'C'. ">수입 통관관련비용.
      L_CSTCT = 'N'.
    WHEN 'T'. ">관세전가액.
      L_CSTCT = 'E'.
    WHEN OTHERS.
  ENDCASE.

*>전기일자/증빙일자 입력...
  IF IM_FIXED_DATE EQ SPACE.
    DESCRIBE TABLE IT_ZTITCSK LINES G_LINE.
    IF G_LINE EQ 1.
      READ TABLE IT_ZTITCSK INDEX 1.
      IF SY-SUBRC EQ 0.
        BKPF-BLDAT = IT_ZTITCSK-BLDAT.
        BKPF-BUDAT = IT_ZTITCSK-BUDAT.
      ENDIF.
    ELSE.
      BKPF-BUDAT = SY-DATLO.
      BKPF-BUDAT = SY-DATLO.
    ENDIF.

    CALL FUNCTION 'Z_TS_GET_POSTING_DATE'
      IMPORTING
        EX_ANSWER = EX_ANSWER
      CHANGING
        CH_BUDAT  = BKPF-BUDAT
        CH_BLDAT  = BKPF-BLDAT.

    IF EX_ANSWER EQ 'Y'.

*      BREAK-POINT.

      LOOP AT IT_ZTITCSK.
        G_TABIX = SY-TABIX.

        IT_ZTITCSK-BUDAT = BKPF-BUDAT.
        IT_ZTITCSK-BLDAT = BKPF-BLDAT.

*        SELECT SINGLE *
*          FROM ztstiga
*         WHERE zterm EQ it_ztitcsk-zterm.
*        IF sy-subrc NE 0.
*          MESSAGE e002(zmts00)
*                  WITH it_ztitcsk-zterm RAISING not_posting.
*        ENDIF.

        CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
          EXPORTING
            I_BLDAT = IT_ZTITCSK-BLDAT
            I_BUDAT = IT_ZTITCSK-BUDAT
            I_CPUDT = SY-DATLO
            I_ZTERM = IT_ZTITCSK-ZTERM
          IMPORTING
            E_ZBD1T = IT_ZTITCSK-ZBD1T
            E_ZBD1P = IT_ZTITCSK-ZBD1P
            E_ZBD2T = IT_ZTITCSK-ZBD2T
            E_ZBD2P = IT_ZTITCSK-ZBD2P
            E_ZBD3T = IT_ZTITCSK-ZBD3T
            E_ZSCHF = IT_ZTITCSK-ZLSPR
            E_ZLSCH = IT_ZTITCSK-ZLSCH
            E_ZFBDT = IT_ZTITCSK-ZFBDT.

        CLEAR: FAEDE.

        FAEDE-SHKZG = 'H'.
        FAEDE-KOART = 'K'.
        FAEDE-ZFBDT = IT_ZTITCSK-ZFBDT.
        FAEDE-ZBD1T = IT_ZTITCSK-ZBD1T.
        FAEDE-ZBD2T = IT_ZTITCSK-ZBD2T.
        FAEDE-ZBD3T = IT_ZTITCSK-ZBD3T.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
        FAEDE-BLDAT = IT_ZTITCSK-BLDAT.

        CALL FUNCTION 'DETERMINE_DUE_DATE'
          EXPORTING
            I_FAEDE = FAEDE
          IMPORTING
            E_FAEDE = FAEDE
          EXCEPTIONS
            OTHERS  = 1.

        IT_ZTITCSK-NETDT = FAEDE-NETDT.

        MODIFY IT_ZTITCSK INDEX G_TABIX.
      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

*> 기본값.
  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS  EQ  T001-BUKRS
     AND CSTCT  EQ  L_CSTCT.

  IF SY-SUBRC EQ 0.
    LOOP AT IT_ZTITCSK.
      G_TABIX1 = SY-TABIX.

      MOVE-CORRESPONDING IT_ZTITCSK TO ZTITCSK.
**> 헤더텍스트.
*      IF ztitig07-dtrfd EQ space.
*        it_ztitcsk-bktxt = ztitig07-bktxt.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrfd
*                                              it_ztitcsk-bktxt
*                                              'X'
*                                              'X'.
**> 참조.
*      IF ztitig07-dtrfh EQ space.
*        it_ztitcsk-xblnr = ztitig07-xblnr.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrfh
*                                              it_ztitcsk-xblnr
*                                              'X'
*                                              'X'.
**> 대변텍스트.
*      IF ztitig07-dtrfic EQ space.
*        it_ztitcsk-sgtxt = ztitig07-sgtxtc.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrfic
*                                              it_ztitcsk-sgtxt
*                                              'X'
*                                              'X'.
**> 대변지정.
*      IF ztitig07-dtrfac EQ space.
*        it_ztitcsk-zuonr = ztitig07-zuonrc.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrfac
*                                              it_ztitcsk-zuonr
*                                              'X'
*                                              'X'.
*
**> 대변참조키 1.
*      IF ztitig07-dtrf1c EQ space.
*        it_ztitcsk-xref1 = ztitig07-xref1c.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrf1c
*                                              it_ztitcsk-xref1
*                                              'X'
*                                              'X'.
*
**> 대변참조키 2.
*      IF ztitig07-dtrf2c EQ space.
*        it_ztitcsk-xref2 = ztitig07-xref2c.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrf2c
*                                              it_ztitcsk-xref2
*                                              'X'
*                                              'X'.
*
**> 대변참조키 3.
*      IF ztitig07-dtrf3c EQ space.
*        it_ztitcsk-xref3 = ztitig07-xref3c.
*      ENDIF.
*      PERFORM get_reference_field_value USING ztitig07-dtrf3c
*                                              it_ztitcsk-xref3
*                                              'X'
*                                              'X'.
***********************  품목 ************************

      LOOP AT IT_ZTITCSP WHERE ICSNO = IT_ZTITCSK-ICSNO.
        G_TABIX = SY-TABIX.
        MOVE-CORRESPONDING IT_ZTITCSP TO ZTISCSIT.
**> 대변텍스트.
*        IF ztitig07-dtrfi EQ space.
*          it_ztitcsp-sgtxt = ztitig07-sgtxt.
*        ENDIF.
*        PERFORM get_reference_field_value USING ztitig07-dtrfi
*                                                it_ztitcsp-sgtxt
*                                                'X'
*                                                ' '.
**> 차변지정.
*        IF ztitig07-dtrfa EQ space.
*          it_ztitcsp-zuonr = ztitig07-zuonr.
*        ENDIF.
*        PERFORM get_reference_field_value USING ztitig07-dtrfa
*                                                it_ztitcsp-zuonr
*                                                'X'
*                                                ' '.
**> 차변 참조키 1.
*        IF ztitig07-dtrf1 EQ space.
*          it_ztitcsp-xref1 = ztitig07-xref1.
*        ENDIF.
*        PERFORM get_reference_field_value USING ztitig07-dtrf1
*                                                it_ztitcsp-xref1
*                                                'X'
*                                                ' '.
**> 차변 참조키 2.
*        IF ztitig07-dtrf2 EQ space.
*          it_ztitcsp-xref2 = ztitig07-xref2.
*        ENDIF.
*        PERFORM get_reference_field_value USING ztitig07-dtrf2
*                                                it_ztitcsp-xref2
*                                                'X'
*                                                ' '.
**> 차변 참조키 3.
*        IF ztitig07-dtrf3 EQ space.
*          it_ztitcsp-xref3 = ztitig07-xref3.
*        ENDIF.
*        PERFORM get_reference_field_value USING ztitig07-dtrf3
*                                                it_ztitcsp-xref3
*                                                'X'
*                                                ' '.
        MODIFY IT_ZTITCSP INDEX G_TABIX.
      ENDLOOP.
      MODIFY IT_ZTITCSK INDEX G_TABIX1.
    ENDLOOP.
  ENDIF.

  CLEAR: ZTITCSK, ZTISCSIT.

*> 국가코드 관련.
  SELECT SINGLE *
    FROM T005
   WHERE LAND1 EQ T001-LAND1.

  READ TABLE IT_ZTITCSK INDEX 1.
  IF SY-SUBRC EQ 0.
    CLEAR: ZTITCSK.
    L_ICSNO = IT_ZTITCSK-ICSNO.
    PERFORM GET_NEW_NODE_DATA  USING    L_ICSNO.
  ENDIF.

  CREATE OBJECT G_APPLICATION.

  CALL SCREEN 7000 STARTING AT 01 01.
*  ... ENDING AT x2 y2

*-- [CHM2110-00555] 엠트론 수입통관, 선적  제비용처리시 결과 적용 -[s]
  IF *ZTITCSK-ICSNO IS NOT INITIAL AND
      IM_BUKRS EQ '3000'           AND
      ( IM_EXPGR EQ 'B' OR IM_EXPGR EQ 'C' ).
    IT_ZTITCSK-BUKRS =  *ZTITCSK-BUKRS.
    IT_ZTITCSK-GJAHR =  *ZTITCSK-GJAHR.
    IT_ZTITCSK-ICSNO =  *ZTITCSK-ICSNO.
    IT_ZTITCSK-BELNR =  *ZTITCSK-BELNR.
    MODIFY  IT_ZTITCSK FROM *ZTITCSK INDEX 1.

    CT_ZTITCSK[] = IT_ZTITCSK[].

  ENDIF.
*-- [CHM2110-00555] 엠트론 수입통관, 선적  제비용처리시 결과 적용 -[e]

  EX_ANSWER  = G_ANSWER.
  EX_SUCCESS = G_SUCCESS_CNT.
  EX_ERROR   = G_ERROR_CNT.




ENDFUNCTION.
