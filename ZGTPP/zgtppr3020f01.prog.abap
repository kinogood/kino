*&---------------------------------------------------------------------*
*&  Include           ZPPR0021F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  select_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PROC .

  DATA: LT_TLINES  LIKE TLINE OCCURS 0 WITH HEADER LINE,
        LT_SCH     LIKE THEAD-TDNAME,
        LS_TCO09WA LIKE TCO09.

  REFRESH GT_AFKO.        CLEAR GT_AFKO.
*& 2006.07.24 CSR번호:C2006071001000000664
*& 판매오더번호,품목번호 조건 추가

*& 2006.09.11 CSR번호 :
*& 작업의 제어키 ZP03(Dummy) 조회 삭제
*- Start 2024.10.16 SELECT ~ ENDSELECT -> SELECT ~ INTO ... TABLE. LOOP ~ ENDLOOP.
*- Start 2025.02.04 배치 잡 전송일 경우 최대 적중수 조건 제외
  PERFORM GET_DATA_SELECT_PROC.
*- End 2025.02.04
  LOOP AT GT_AFKO.
*& 제어키로 외주공정 여부 체크...
    IF GT_AFKO-STEUS = 'PP02' OR
       GT_AFKO-STEUS = 'PP06'.
      GT_AFKO-EXFLG = 'Y'.
    ELSE.
      GT_AFKO-EXFLG = 'N'.
    ENDIF.
*& 공정코드 = 자재그룹의 5-7자리의 문자를 사용...
    MOVE GT_AFKO-MATKL+4(3)     TO GT_AFKO-PROCD.
*& 작업 우선순의를 결정하기위한 Key Field 생성...
*&    CONCATENATE gt_afko-plnnr
    CONCATENATE GT_AFKO-PROCD
                GT_AFKO-ARBPL
                GT_AFKO-GSTRS INTO GT_AFKO-ZSORT.

    MOVE: GT_AFKO-GSUZS         TO GT_AFKO-GSUZS_S,
          GT_AFKO-PWERK         TO GT_AFKO-WERKS.

    GT_AFKO-PNMNG = GT_AFKO-PSMNG - GT_AFKO-PSAMG.

    IF P_PWERK EQ '1401'     AND
       S_DISPO+3(2) EQ 'OF'  AND
     ( S_PROCD+3(3) EQ 'FDM' OR
       S_PROCD+3(3) EQ 'HPT' ).
      PERFORM GET_BIGO_TEXT.
    ENDIF.
*& 2012.08.06 추가 (C20120726_54972)
*& 2201플랜트, TAP공정인 경우 전공정(하위공정) 추가
* 2014.05.13 풍세전선 반영
    IF ( P_PWERK EQ '2201' OR P_PWERK EQ '1901' ) AND
       S_PROCD+3(3) EQ 'TAP'.

      DATA: LD_MATKL LIKE MARA-MATKL.

      SELECT SINGLE M~MATKL
        INTO LD_MATKL
        FROM RESB AS R INNER JOIN MARA AS M
                          ON R~MATNR = M~MATNR
       WHERE R~AUFNR = GT_AFKO-AUFNR
         AND ( M~MTART = 'MCHF'
          OR   M~MTART = 'HALB' ).
      GT_AFKO-PRECD = LD_MATKL+4(3).
    ENDIF.
*- Start 2024.10.16 생산 오더 번호 취합
    PERFORM GET_AUFNR.
*- End 2024.10.16
    MODIFY GT_AFKO. CLEAR GT_AFKO.

  ENDLOOP.
*- End 2024.10.16
  SORT GT_AFKO BY ZSORT GSUZS_S AUFNR.

ENDFORM.                    " select_proc
*&---------------------------------------------------------------------*
*&      Form  additional_info_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADDITIONAL_INFO_PROC .

  DATA: LV_SEQNO LIKE GT_AFKO-SEQNO,
        LV_CHK   TYPE CHAR1,
        LV_MATNR TYPE MARA-MATNR,
        LV_QMCNT TYPE I.
  DATA : LV_NUM(2) TYPE N.
*-{ 기능개선_179037 조회조건의 오더 상태만 조회
  PERFORM GET_ORDER_STAT_CODE.
*}-기능개선_179037
*- Start 2025.02.12
  CLEAR : GS_STATUS, GT_STATUS, GS_AUFM2, GT_AUFM2.
  DATA(LT_AFKO) = GT_AFKO[].
  SORT LT_AFKO BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_AFKO COMPARING AUFNR.

  IF LT_AFKO[] IS NOT INITIAL.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_AUFM2
        FROM AUFM
        FOR ALL ENTRIES IN @LT_AFKO
        WHERE AUFNR EQ @LT_AFKO-AUFNR
             AND BWART IN ( '261', '262' )
             AND WERKS EQ @P_PWERK.

  ENDIF.
*- End 2025.02.12
  LOOP AT GT_AFKO.

    CLEAR : LV_CHK.
*- Start 2025.01.10 필드 우선 순위 프로세스 변경
* 코드 마스터 "실적 모니터링(3020)_우선순위 필드 사용 여부" 추출
    SELECT SINGLE MANDT
                    INTO @SY-MANDT
                    FROM ZGTPPT1010
                    WHERE MODULE_KIND = 'PP'
                         AND CODEGRP = '3030'
                         AND FLD_01 EQ @GT_AFKO-WERKS
                         AND FLD_02 EQ @GT_AFKO-DISPO+0(2).
* 대상 추출을 성공하면, 오더별 우선순위(AUFK-ZZPRIORITY) 추출하여 ALV의 우선순위에 대입
    IF SY-SUBRC = 0.
      SELECT SINGLE ZZPRIORITY INTO @GT_AFKO-SEQNO
                                                    FROM AUFK
                                                    WHERE AUFNR EQ @GT_AFKO-AUFNR.
      LV_SEQNO = GT_AFKO-SEQNO.
* 대상 추출 실패 시 기존 로직 수행
    ELSE.
*& 작업 우선순위를 부여한다.
      AT NEW ZSORT.
        LV_SEQNO = 1.
      ENDAT.
      GT_AFKO-SEQNO = LV_SEQNO.
    ENDIF.
    LV_SEQNO = LV_SEQNO + 1.
*& 생산오더의 상태를 가져온다...
    PERFORM GET_ORDER_STATUS  USING GT_AFKO-OBJNR
                           CHANGING GT_AFKO-STTXT.
*-{ 기능개선_179037 조회조건의 오더 상태만 조회
    IF GT_STAT[] IS NOT INITIAL.
      READ TABLE GT_STAT WITH KEY STAT = GT_AFKO-STTXT.
      IF SY-SUBRC NE 0.
        GI_DELLINECNT = GI_DELLINECNT  + 1.
        DELETE GT_AFKO.
        LV_SEQNO = LV_SEQNO - 1.
        CONTINUE.
      ENDIF.
    ENDIF.
*}-기능개선_179037
    IF GV_SKIP IS INITIAL.
*& 납품처,명을 가져 온다...
      IF NOT GT_AFKO-KDAUF IS INITIAL.
        PERFORM GET_VBPA_KUNNR.
      ENDIF.
    ENDIF.

    IF C_CHAR = 'X'.   " 특성값포함이 check된 경우j
      PERFORM GET_CHARACTERISTIC.
    ENDIF.
*& 세부유형 텍스트를 가져온다...
    PERFORM GET_APRIO_TEXT.
*& 작업지시 정보...
    CLEAR  ZPPT0020.
    SELECT SINGLE ARBPL CFPRI
      INTO (GT_AFKO-ARBPL_C, GT_AFKO-CFPRI)
      FROM ZPPT0020
     WHERE WERKS = GT_AFKO-WERKS
       AND SPGCD = GT_AFKO-DISPO+0(2)
       AND AUFNR = GT_AFKO-AUFNR
*&       and lppnr = gt_afko-lppnr
       AND VORNR = GT_AFKO-VORNR.
*****2009.09.07 보빈교체/선재교체/규격교체/품종교체 추가
    IF P_PWERK EQ '1304' AND
       GT_AFKO-DISPO EQ 'MGF'.

      CLEAR  ZPPT0020.
      SELECT SINGLE BZCHG CBCHG SZCHG GRCHG
        INTO (GT_AFKO-BZCHG, GT_AFKO-CBCHG,
              GT_AFKO-SZCHG, GT_AFKO-GRCHG)
        FROM ZPPT0020
       WHERE WERKS = GT_AFKO-WERKS
         AND SPGCD = GT_AFKO-DISPO+0(2)
         AND AUFNR = GT_AFKO-AUFNR
*&       and lppnr = gt_afko-lppnr
         AND VORNR = GT_AFKO-VORNR.

    ENDIF.

    IF GV_SKIP IS INITIAL.
*& 절단유무 체크...
      SELECT SINGLE MANDT INTO ZLET0018-MANDT
               FROM ZLET0018
              WHERE AUFNR  = GT_AFKO-AUFNR
                AND POSNRZ = GT_AFKO-POSNR.
      IF SY-SUBRC = 0.
        GT_AFKO-JISIR = 'X'.
      ELSE.
        GT_AFKO-JISIR = ' '.
      ENDIF.

    ENDIF.
*& 비고 유무...
    IF GT_AFKO-LTEXT IS INITIAL.
      GT_AFKO-BUTTON = ICON_SPACE.
    ELSE.
      GT_AFKO-BUTTON = ICON_DISPLAY_NOTE.
    ENDIF.
*& 2007.09.12
*& JS전선 2201 플랜트의 INS,PTS,UST,SHE,TAP 공정에서
*& 작업지시전,작업대기인 오더들에 대한 생산오더 소요량과
*& 현재 반제품재고량을 +- 1% 공차로 반제품이 모두 있으면
*& 파란색, 일부라도 부족하면 빨간색, 해당 조건이 아니면
*& space로 표시
* 2014.05.13 풍세전선 반영
    IF ( P_PWERK = '2201'  OR
         P_PWERK = '2301'  OR
         P_PWERK = '1901'  OR
         P_PWERK = '1801')    AND    "기능개선 91782
      ( GT_AFKO-PROCD = 'INS' OR
        GT_AFKO-PROCD = 'PTS' OR
        GT_AFKO-PROCD = 'UST' OR
        GT_AFKO-PROCD = 'SHE' OR
        GT_AFKO-PROCD = 'TAP' OR
        GT_AFKO-PROCD = 'WSD' OR
        GT_AFKO-PROCD = 'TPA' OR
        GT_AFKO-PROCD = 'WAR' OR
        GT_AFKO-PROCD = 'MRK' OR
        GT_AFKO-PROCD = 'STP' OR
        GT_AFKO-PROCD = 'BUN' ) AND
      ( GT_AFKO-STTXT = TEXT-039 OR
        GT_AFKO-STTXT = TEXT-040 ).

      PERFORM GET_STOCK_STATUS  USING GT_AFKO-AUFNR
                                      GT_AFKO-MATKL
                                      GT_AFKO-ARBPL
                                      LV_CHK.

      IF LV_CHK EQ SPACE.
        GT_AFKO-STOCK = ICON_LED_GREEN.
      ELSE.
        GT_AFKO-STOCK = ICON_LED_RED.
      ENDIF.

    ELSE.

      GT_AFKO-STOCK = ICON_SPACE.

    ENDIF.

    IF GV_SKIP IS INITIAL.
*& 2008.01.21
*& CSR : C20080121_03914
*& 오더 확정수량과 납품수량 추가
      SELECT SUM( IGMNG )
        INTO GT_AFKO-IGMNG
        FROM AFKO
       WHERE AUFNR = GT_AFKO-AUFNR.
*- Start 2024.10.22 단위 테스트 요청 사항 반영
*      SELECT SUM( wemng )
*        INTO gt_afko-wemng
*        FROM afpo
*       WHERE aufnr = gt_afko-aufnr.
      SELECT SUM( WEMNG )
                       INTO GT_AFKO-WEMNG
                       FROM AFPO
                       WHERE AUFNR     = GT_AFKO-AUFNR
                            AND POSNR = GT_AFKO-POSNR.
*- End 2024.10.22
      IF GT_AFKO-POSNR = '0001'.                            "20250123
        SELECT SUM( LMNGA )
          INTO GT_AFKO-LMNGA
          FROM AFRU
         WHERE AUFNR    = GT_AFKO-AUFNR
*            AND vornr = gt_afko-vornr
              AND WERKS  = GT_AFKO-WERKS
*- Start 2024.10.22 단위 테스트 요청 사항 반영
              AND GRUND = SPACE
*- End 2024.10.22
              AND STOKZ  = SPACE
              AND STZHL  = 0
              AND LMNGA  > 0.
      ENDIF.

    ENDIF.
*& 2008.07.24
*& C20080718_00975
*& 색상내역 필드 추가
    IF GT_AFKO-ZZCOLOR_BASE IS NOT INITIAL
     OR GT_AFKO-ZZCOLOR_STRIPE IS NOT INITIAL. "기능개선_46712 추가

      SELECT SINGLE CLRTX
        INTO GT_AFKO-CLRTX
        FROM ZEDT0160
       WHERE COLOR = GT_AFKO-ZZCOLOR_BASE.
*-{기능개선_46712
*-색상 STRIPE의 색상내역 필드 추가
      SELECT SINGLE CLRTX
        INTO GT_AFKO-CLRTX1
        FROM ZEDT0160
       WHERE COLOR = GT_AFKO-ZZCOLOR_STRIPE.
*-}기능개선_46712_2014.10.07
    ENDIF.
*-{CHM2009-00353 1801플랜트 UST/TAP공정인 경우 완제품자재 색상 조회
    IF P_PWERK EQ '1801' AND
       ( GT_AFKO-PROCD = 'UST' OR GT_AFKO-PROCD = 'TAP' ).
      PERFORM GET_MCFE_BASE_COLOR USING GT_AFKO-AUFNR
                                CHANGING GT_AFKO-FCOLOR.
    ENDIF.
*}-CHM2009-00353
*** 2009.09.03
    IF P_PWERK EQ '1304' AND
       GT_AFKO-DISPO EQ 'MGF'.
*&    라벨발행수 추가
      PERFORM LABEL_COUNT USING GT_AFKO.
*&    납선 특성 값
      PERFORM MATRIAL_GET_CHARACTERISTIC USING GT_AFKO.
    ENDIF.
*-{ 기능개선_93494 고무선의 경우 INS,SHE의 하위 자재 컴파운드명 표시
    IF ( P_PWERK EQ '1801' OR P_PWERK EQ '1901' ) AND
       ( GT_AFKO-PROCD = 'INS' OR GT_AFKO-PROCD = 'SHE' ).
      PERFORM GET_COMP_DESCRIPTION.
    ENDIF.
*}-기능개선_93494
*- Start 2024.10.16 신규 필드 체크 로직 추가
    PERFORM CHECK_LOGIC_NEW_FIELD.
* 투입 Status
    READ TABLE GT_3300 INTO DATA(LS_3300) WITH KEY AUFNR = GT_AFKO-AUFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_AFKO-EXCLUD_GUID = '제외'.
    ENDIF.

*[U01] 가온전선 추가
    IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
      "작업장내역추출
      SELECT SINGLE B~KTEXT
        FROM CRHD AS A
        JOIN CRTX AS B ON B~OBJTY EQ A~OBJTY
                      AND B~OBJID EQ A~OBJID
                      AND B~SPRAS EQ @SY-LANGU
       WHERE A~ARBPL EQ @GT_AFKO-ARBPL
         AND A~WERKS EQ @GT_AFKO-WERKS
        INTO @GT_AFKO-KTEXT.
    ENDIF.
*[U01] 가온전선 추가

* 2026.08.24 가온전선 추가 - 재질
    SELECT * FROM /NFM/TKGW
      INTO TABLE @DATA(LT_TKGW)
     WHERE WERKS = @GT_AFKO-WERKS
       AND MATNR = @GT_AFKO-MATNR.
    IF SY-SUBRC EQ 0.
      CLEAR LV_NUM.
      LOOP AT LT_TKGW INTO DATA(LS_TKGW).
        ADD 1 TO LV_NUM.
        IF LV_NUM = '03'.
          EXIT.
        ENDIF.
        PERFORM SET_VALUE_FROM_TKGW USING LV_NUM LS_TKGW CHANGING GT_AFKO.
      ENDLOOP.
    ENDIF.

* 2026.08.24 가온전선 추가

    MODIFY GT_AFKO.
    CLEAR GT_AFKO.
*- End 2024.10.16
  ENDLOOP.
*& 2009/05/13
*& C20090512_54480
*& JS전선 품질통지 이력 카운터 조회 추가
* 2014.05.13 풍세전선 반영
  IF GT_AFKO-WERKS+0(1) EQ '2' OR
     GT_AFKO-WERKS = '1901'.

    SORT GT_AFKO BY MATNR.

    CLEAR : LV_MATNR.

    LOOP AT GT_AFKO.

      IF LV_MATNR NE GT_AFKO-MATNR.

        SELECT COUNT(*)
          INTO LV_QMCNT
          FROM QMEL
         WHERE MAWERK = GT_AFKO-WERKS
           AND MATNR =  GT_AFKO-MATNR
           AND KZLOESCH NE 'X'.

      ENDIF.

      GT_AFKO-QMCNT = LV_QMCNT.
      LV_MATNR = GT_AFKO-MATNR.

      CLEAR : ZPPT0153.
*& 2009.12.04 CSR : C20091202_70500
*& 자재별 특기사항 추가
      SELECT SINGLE *
        FROM ZPPT0153
       WHERE WERKS = GT_AFKO-WERKS
         AND SPGCD = GT_AFKO-MATKL+1(2)
         AND PROCD = GT_AFKO-MATKL+4(3)
         AND MATNR = GT_AFKO-MATNR.

      IF SY-SUBRC EQ 0.
        GT_AFKO-ETC = ICON_LED_YELLOW.
      ELSE.
        GT_AFKO-ETC = ICON_SPACE.
      ENDIF.
*& 2013.12.05 CSR:기능개선 2189
*& 띠색상 추가
      IF GT_AFKO-MATKL+4(3) EQ 'INS' OR
         GT_AFKO-MATKL+4(3) EQ 'MRK' OR
         GT_AFKO-MATKL+4(3) EQ 'SHE'.

        PERFORM GET_MATNR_STRIPE USING GT_AFKO-SPCOL.

      ENDIF.

      MODIFY GT_AFKO.

    ENDLOOP.

  ENDIF.
* 2014.03.14 CSR:기능개선_13463
* 2014.05.13 풍세전선 반영
  IF ( P_PWERK = '1801' OR
       P_PWERK = '1901' ) AND S_DISPO-LOW+0(2) EQ 'RC'.
    PERFORM CHECK_POJANG_CHANGE.
  ENDIF.

*-{ 기능개선_78645 산특 대연스크린 재질 조회
  IF P_PWERK EQ '1801' OR P_PWERK EQ '1901'.

    CLEAR : GT_MATNR[], GT_MATNR.

    LOOP AT GT_AFKO WHERE MATKL+4(3) = 'PTS'
                      OR  MATKL+4(3) = 'INS'.

      IF GT_AFKO-MATKL+4(3) EQ 'PTS'.
        GT_MATNR-MATNR = GT_AFKO-MATNR.
        GT_MATNR-GUBUN = '1'.
      ELSEIF GT_AFKO-MATKL+4(3) EQ 'INS'.
        GT_MATNR-MATNR = GT_AFKO-MATNR.
        GT_MATNR-AUFNR = GT_AFKO-AUFNR.
        GT_MATNR-GUBUN = '2'.
      ENDIF.
      APPEND GT_MATNR.

    ENDLOOP.

    CALL FUNCTION 'Z_PP_GET_PTS_SCREEN'
      TABLES
        IT_ATWRT = GT_MATNR.

    LOOP AT GT_MATNR WHERE GUBUN = '1'.

      GT_AFKO-ATWRT = GT_MATNR-ATWRT.
      MODIFY GT_AFKO TRANSPORTING ATWRT
                    WHERE  MATNR = GT_MATNR-MATNR.

    ENDLOOP.

    LOOP AT GT_MATNR WHERE GUBUN = '2'.

      GT_AFKO-ATWRT = GT_MATNR-ATWRT.
      MODIFY GT_AFKO TRANSPORTING ATWRT
                    WHERE AUFNR = GT_MATNR-AUFNR.

    ENDLOOP.

  ENDIF.
*}-기능개선_103632 1801 플랜트 특정 작업장의 경우 입고 자재의
*  단위 중량 출력
  IF P_PWERK EQ '1801' AND S_DISPO-LOW+0(2) = 'RC'.
    PERFORM GET_CONVERT_MENGE.
  ENDIF.
*- Start 2025.01.09 필드에 색상 넣는 로직은 여기로 이동
  PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
*- End 2025.01.09
*}-기능개선_103632
* 데이터 정렬 기준을 작업시작일->시작시간->우선순위->오더번호->오더 품목번호 순으로 정렬
*  SORT gt_afko BY zsort gsuzs_s aufnr.
  SORT GT_AFKO BY GSTRS GSUZS SEQNO AUFNR POSNR.

ENDFORM.                    " additional_info_proc
*&---------------------------------------------------------------------*
*&      Form  get_parameter_desc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PARAMETER_DESC .
*& 플랜트명...
  IF NOT P_PWERK IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO T_NAME1
FROM T001W
WHERE WERKS = P_PWERK.
  ELSE.
    CLEAR T_NAME1.
  ENDIF.
*& 설비명...
  IF NOT S_ARBPL-LOW IS INITIAL.

    CLEAR M_CRAMN.
    SELECT SINGLE KTEXT INTO L_KTEXT
             FROM M_CRAMN
            WHERE WERKS = P_PWERK
              AND ARBPL = S_ARBPL-LOW
              AND SPRAS = SY-LANGU.
  ELSE.
    CLEAR L_KTEXT.
  ENDIF.

  IF NOT S_ARBPL-HIGH IS INITIAL.
    CLEAR M_CRAMN.
    SELECT SINGLE KTEXT INTO H_KTEXT
             FROM M_CRAMN
            WHERE WERKS = P_PWERK
              AND ARBPL = S_ARBPL-HIGH
              AND SPRAS = SY-LANGU.
  ELSE.
    CLEAR H_KTEXT.
  ENDIF.

ENDFORM.                    " get_parameter_desc
*&---------------------------------------------------------------------*
*&      Form  modify_selection_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SELECTION_SCREEN .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'ABC'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " modify_selection_screen
*&---------------------------------------------------------------------*
*&      Form  get_order_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ORDER_STATUS  USING PV_OBJNR
                    CHANGING PV_STTXT.

  DATA  : LV_STTXT LIKE RC65D-STTXT,
          LV_INDEX LIKE SY-INDEX.

  CHECK PV_OBJNR NE SPACE.
  REFRESH GR_STATUS. CLEAR GR_STATUS.
  SELECT C~TXT04 INTO GR_STATUS-LOW
    FROM JEST AS A INNER JOIN TJ02  AS B
                           ON A~STAT = B~ISTAT
                   INNER JOIN TJ02T AS C
                           ON A~STAT = C~ISTAT
   WHERE A~OBJNR = PV_OBJNR
     AND A~INACT = ''
     AND B~NODIS = ''
     AND C~SPRAS = SY-LANGU.
*- Start 2025.02.12
    CLEAR GS_STATUS.
    GS_STATUS-AUFNR = GT_AFKO-AUFNR.
    GS_STATUS-TXT04 = GR_STATUS-LOW.
    APPEND GS_STATUS TO GT_STATUS.
*- End 2025.02.12
    MOVE: 'I'              TO GR_STATUS-SIGN,
          'EQ'             TO GR_STATUS-OPTION.
    APPEND GR_STATUS.   CLEAR GR_STATUS.

  ENDSELECT.
*- Start 2024.10.16 오더 'Payoff' 상태 값 존재 시 해당 값 추출 후 대입
  SELECT D~TXT04 INTO @GR_STATUS-LOW
      FROM JEST AS A INNER JOIN JSTO AS B
          ON A~OBJNR EQ B~OBJNR
          INNER JOIN TJ30 AS C
          ON  A~STAT    EQ C~ESTAT
          AND B~STSMA EQ C~STSMA
          INNER JOIN TJ30T AS D
          ON  A~STAT    EQ D~ESTAT
          AND B~STSMA EQ D~STSMA
           WHERE A~OBJNR = @PV_OBJNR
               AND A~INACT = ''
               AND D~SPRAS = @SY-LANGU.
*- Start 2025.02.12
    CLEAR GS_STATUS.
    GS_STATUS-AUFNR = GT_AFKO-AUFNR.
    GS_STATUS-TXT04 = GR_STATUS-LOW.
    APPEND GS_STATUS TO GT_STATUS.
*- End 2025.02.12
    MOVE: 'I'              TO GR_STATUS-SIGN,
          'EQ'             TO GR_STATUS-OPTION.
    APPEND GR_STATUS.   CLEAR GR_STATUS.

  ENDSELECT.
*- End 2024.10.16
*&**********************************************************************
*&             작업 상태 컨버젼
*&----------------------------------------------------------------------
*&case order.status
*&  case teco가 있거나 dlfl이나 clsd이나 vcal가 있으면
*&    오더종료
*&  case cnf & dlv 혹은
*&         cnf & pdlv 혹은
*&         pcnf & dlv 가 있으면,
*&    작업완료
*&  case pcnf 이나 pdlv이나 gmco가 있으면
*&    작업중
*&  case rel 가 있으면
*&    작업대기
*&  case crtd가 있으면
*&    작업지시전
*&  case others
*&    비정상오더
*&end case
*&----------------------------------------------------------------------
  IF     'TECO' IN GR_STATUS OR
         'DLFL' IN GR_STATUS OR
         'CLSD' IN GR_STATUS OR
         'VCAL' IN GR_STATUS.
    PV_STTXT = TEXT-041. "오더종료

  ELSEIF ( 'CNF' IN GR_STATUS AND
           'DLV' IN GR_STATUS ).
    PV_STTXT = TEXT-002. "작업완료

  ELSEIF ( 'PCNF' IN GR_STATUS AND
           'DLV' IN GR_STATUS ).
    PV_STTXT = TEXT-042. "작업완료 처리대상

  ELSEIF ( 'CNF'  IN GR_STATUS AND
           'PDLV' IN GR_STATUS ).
    PV_STTXT = TEXT-043. "입고완료 처리대상

  ELSEIF 'PCNF' IN GR_STATUS OR
         'PDLV' IN GR_STATUS OR
         'GMCO' IN GR_STATUS.
    PV_STTXT = TEXT-044. "작업중
*- Start 2024.10.16 오더 'Payoff' 상태 값 존재 시 해당 값 추출 후 대입
  ELSEIF 'PAYO' IN GR_STATUS.
    PV_STTXT = TEXT-T08. "Pay Off
*- End 2024.10.16
  ELSEIF 'REL'  IN GR_STATUS.
    PV_STTXT = TEXT-040. "작업대기
  ELSEIF 'CRTD' IN GR_STATUS.
    PV_STTXT = TEXT-039. "작업지시전
  ELSE.
    PV_STTXT = TEXT-045. "비정상오더
  ENDIF.

ENDFORM.                    " get_order_status
*&---------------------------------------------------------------------*
*&      Form  get_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC .

  DATA: INFO         LIKE RFCSI, C,  "Message text
        SND_JOBS     TYPE I VALUE 1,  "Sent jobs
        RCV_JOBS     TYPE I VALUE 1,  "Received replies
        EXCP_FLAG(1) TYPE C,  "Number of RESOURCE_FAILUREs
        TASKNAME(4)  TYPE N VALUE '0001',  "Task name administration
        LV_CNT       TYPE I.

  CLEAR : GT_CHAR, GT_CHAR[].

  MOVE-CORRESPONDING GT_AFKO TO GT_CHAR.

  APPEND GT_CHAR.

  DO.

* Active Session
    DO.
      LV_CNT = SND_JOBS - RCV_JOBS.
      IF LV_CNT < 3 .
        EXIT.  "Job processing finished
      ENDIF.
      WAIT UP TO 10 SECONDS.
    ENDDO.
* Active Session

    IF SY-MANDT EQ '100'.

      CALL FUNCTION 'Z_PP_GET_P_CLASSFICATION'
        STARTING NEW TASK TASKNAME DESTINATION IN GROUP 'LSCABLE'
        PERFORMING RETURN_01 ON END OF TASK
        TABLES
          IT_AFKO               = GT_CHAR
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          RESOURCE_FAILURE      = 3.

    ELSEIF SY-MANDT EQ '600' OR
           SY-MANDT EQ '300' OR
           SY-MANDT EQ '210' OR
           SY-MANDT EQ '200'.

      CALL FUNCTION 'Z_PP_GET_P_CLASSFICATION'
        STARTING NEW TASK TASKNAME DESTINATION IN GROUP DEFAULT
        PERFORMING RETURN_01 ON END OF TASK
        TABLES
          IT_AFKO               = GT_CHAR
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          RESOURCE_FAILURE      = 3.

    ENDIF.

    CASE SY-SUBRC.
      WHEN 0.
* Administration of asynchronous tasks

        TASKNAME = TASKNAME + 1.
        SND_JOBS = SND_JOBS + 1.
        CLEAR EXCP_FLAG.  "Reset flag
        EXIT.  "Job processing finished

      WHEN 1 OR 2.
* Handling of communication and system failure
        ...
      WHEN 3.  "No resources available at present
* Receive reply to asynchronous RFC calls
        IF EXCP_FLAG = SPACE.
          EXCP_FLAG = 'X'.
* First attempt for RESOURCE_FAILURE handling
          WAIT UNTIL RCV_JOBS >= SND_JOBS UP TO '0.01' SECONDS.
        ELSE.
* Second attempt for RESOURCE_FAILURE handling
          WAIT UNTIL RCV_JOBS >= SND_JOBS UP TO '0.1' SECONDS.
        ENDIF.
        IF SY-SUBRC = 0.
          CLEAR EXCP_FLAG.  "Reset flag
        ELSE.  "No replies

        ENDIF.
    ENDCASE.
  ENDDO.
* Receive remaining asynchronous replies
  WAIT UNTIL RCV_JOBS >= SND_JOBS.

ENDFORM.                    " get_CHARACTERISTIC
*&---------------------------------------------------------------------*
*&      Form  RETURN_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_AFKO  text
*      -->P_=  text
*      -->P_LT_AFKO  text
*      -->P_EXCEPTIONS  text
*      -->P_COMMUNICATION_FAILURE  text
*      -->P_=  text
*      -->P_1  text
*      -->P_SYSTEM_FAILURE  text
*      -->P_=  text
*      -->P_2  text
*      -->P_RESOURCE_FAILURE  text
*      -->P_=  text
*      -->P_3  text
*----------------------------------------------------------------------*

FORM RETURN_01 USING TASKNAME.

  DATA: LT_AFKO  TYPE ZPPS112 OCCURS 0 WITH HEADER LINE.
  DATA: SND_JOBS TYPE I VALUE 1,  "Sent jobs
        RCV_JOBS TYPE I VALUE 1.  "Received replies


  RECEIVE RESULTS FROM FUNCTION 'Z_PP_GET_P_CLASSFICATION'
      TABLES
        IT_AFKO               = GT_CHAR
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        RESOURCE_FAILURE      = 3.

  RCV_JOBS = RCV_JOBS + 1.  "Receiving data

  IF GT_CHAR[] IS NOT INITIAL.

    READ TABLE GT_CHAR INDEX 1.

    MOVE-CORRESPONDING GT_CHAR TO GT_AFKO.

  ENDIF.

ENDFORM.                                                    "return_01
*&---------------------------------------------------------------------*
*&      Form  get_current_row_index
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CURRENT_ROW_INDEX USING P_GUBUN.
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

*& only one selected row!
  READ TABLE ROW_TABLE INDEX 1.
  IF SY-SUBRC = 0.
    CLEAR GT_AFKO.
    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.
  ELSE.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
  ENDIF.

  IF P_GUBUN = 'M'.
    CHECK GV_OKCODE = 'ZPPM0030M'.
  ELSE.
    CHECK GV_OKCODE = 'ZPPM0030'.
  ENDIF.
*& 작업실적 호출용...
  REFRESH GT_ZPPS040.  CLEAR GT_ZPPS040.
  LOOP AT ROW_TABLE.
    CLEAR GT_AFKO.
    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.
    IF GT_AFKO-STTXT = TEXT-039. "작업지시전
      MESSAGE S001 WITH TEXT-047."작업지시전 오더가 포함되어있습니다.
      RETURN.
    ENDIF.

    IF GV_OKCODE = 'ZPPM0030M' AND
       ( GT_AFKO-WERKS NE '1401'  OR
         GT_AFKO-DISPO+0(2) NE 'OC'    OR
         GT_AFKO-PROCD NE 'FCO' ).

      MESSAGE S001 WITH TEXT-048."다중 실적처리를 할수 없는 공정입니다.
      RETURN.
    ENDIF.

    GT_ZPPS040-AUFNR  = GT_AFKO-AUFNR.
    GT_ZPPS040-VORNR  = GT_AFKO-VORNR.
    GT_ZPPS040-ARBPL  = GT_AFKO-ARBPL.
    GT_ZPPS040-MATNR  = GT_AFKO-MATNR.
    GT_ZPPS040-MAKTX  = GT_AFKO-MAKTX.
    GT_ZPPS040-PSMNG  = GT_AFKO-PSMNG.
    GT_ZPPS040-WERKS  = GT_AFKO-WERKS.
*&    gt_zpps040-length = gt_afko-length.
*&    gt_zpps040-factor = gt_afko-factor.

    PERFORM CHAR_TO_DECMALS USING GT_AFKO-LENGTH
                         CHANGING GT_ZPPS040-LENGTH.

    PERFORM CHAR_TO_DECMALS USING GT_AFKO-FACTOR
                         CHANGING GT_ZPPS040-FACTOR.

    APPEND GT_ZPPS040. CLEAR GT_ZPPS040.
  ENDLOOP.

ENDFORM.                    " get_current_row_index
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_TITLE  text
*      -->P_SY_LINSZ  text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE  USING    P_TITLE
                           P_LINSZ.

  DATA: LV_LEN LIKE    SY-LINSZ,
        LV_COL LIKE    SY-LINSZ,
        LV_TXT LIKE    SY-PRTXT.

*& 제목 출력...
  LV_LEN = STRLEN( P_TITLE ).
  LV_COL = ( P_LINSZ - LV_LEN ) / 2.

  PRINT-CONTROL FUNCTION 'SABLD'.
  PRINT-CONTROL FUNCTION 'SAULN'.
  WRITE AT /LV_COL(LV_LEN) P_TITLE.
  PRINT-CONTROL FUNCTION 'SAOFF'.

*& 출력일시 출력...
  WRITE: TEXT-049        TO LV_TXT(10), "출력일시 :
          SY-DATUM+0(4)      TO LV_TXT+11(4),
         '/'                 TO LV_TXT+15(1),
          SY-DATUM+4(2)      TO LV_TXT+16(2),
         '/'                 TO LV_TXT+18(1),
          SY-DATUM+6(2)      TO LV_TXT+19(2),
          SY-UZEIT+0(2)      TO LV_TXT+22(2),
         ':'                 TO LV_TXT+24(1),
          SY-UZEIT+2(2)      TO LV_TXT+25(2),
         ':'                 TO LV_TXT+27(1),
          SY-UZEIT+4(2)      TO LV_TXT+28(2).

  LV_LEN = STRLEN( LV_TXT ).
  LV_COL = P_LINSZ - LV_LEN - 2.
  WRITE AT /LV_COL(LV_LEN) LV_TXT.

*& 페이지번호 출력...
  CLEAR LV_TXT.
  WRITE: TEXT-050        TO LV_TXT(10),"페이지   :
          SY-PAGNO           TO LV_TXT+11(5),
         '/'                 TO LV_TXT+17(1),
         '*****'             TO LV_TXT+19(5).

  WRITE AT /LV_COL(LV_LEN) LV_TXT.

ENDFORM.                    " top_of_page
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  LEAVE TO SCREEN 0.

ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  INIT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_VARIANT .
*& 작업시작일...
*& 다들 필요없다고 지우라고 난리쳐서 막음
*& 2005.08.12 DJCHA
*&
*  IF sy-uzeit > '060000'.                                   "06:00기준
*    s_gstrs-low = sy-datum.
*  ELSE.
*    s_gstrs-low = sy-datum - 1.
*  ENDIF.
*  APPEND s_gstrs.


*- Start 2026.07.25 -가온전선 추가사항
  IF SY-TCODE = 'ZGTPPR3021G' OR SY-TCODE = 'ZGTPPR3020G'.
*    S_GSTRS-LOW = SY-DATUM+0(6) && '01'.
*    S_GSTRS-HIGH = S_GSTRS-LOW.
*    PERFORM GET_LAST_DAY_OF_MONTH CHANGING S_GSTRS-HIGH.
*    APPEND S_GSTRS.

    S_PAYOFF-LOW = SY-DATUM+0(6) && '01'.
    S_PAYOFF-HIGH = S_PAYOFF-LOW.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING S_PAYOFF-HIGH.
    APPEND S_PAYOFF.

    CLEAR P_DBCNT.
  ENDIF.
*- end 2026.07.25

ENDFORM.                    " INIT_VARIANT
*&---------------------------------------------------------------------*
*&      Form  get_vbpa_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_VBPA_KUNNR.

*& 2007.09.11
*& LS는 인도처, JS는 판매처로 분기

  IF GV_BUKRS = '1000' OR
     P_PWERK NE '1901'.

    SELECT SINGLE A~KUNNR
                  B~NAME1
             INTO CORRESPONDING FIELDS OF GT_AFKO
             FROM VBPA AS A  INNER JOIN KNA1 AS B
                                     ON A~KUNNR = B~KUNNR
            WHERE A~VBELN =  GT_AFKO-KDAUF
              AND A~PARVW = 'WE'.

  ELSEIF GV_BUKRS = '2000' OR
         P_PWERK = '1901'.

    SELECT SINGLE A~KUNNR
                  B~NAME1
             INTO CORRESPONDING FIELDS OF GT_AFKO
             FROM VBPA AS A  INNER JOIN KNA1 AS B
                                     ON A~KUNNR = B~KUNNR
            WHERE A~VBELN =  GT_AFKO-KDAUF
              AND A~PARVW = 'AG'.

  ENDIF.

ENDFORM.                    " get_vbpa_kunnr
*&---------------------------------------------------------------------*
*&      Form  create_selection_table_0027
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_SELECTION_TABLE_0027 .
  REFRESH GT_SELTAB.    CLEAR GT_SELTAB.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046. "선택한 데이타가 없습니다!!!
  ELSE.
    LOOP AT ROW_TABLE.
      CLEAR GT_AFKO.
      READ TABLE GT_AFKO    INDEX ROW_TABLE-INDEX.

      CLEAR  GS_SELTAB_WA.
      MOVE: 'P_PWERK'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
             P_PWERK           TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

      CLEAR GS_SELTAB_WA.
      MOVE: 'S_AUFNR'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
             GT_AFKO-AUFNR     TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " create_selection_table_0027
*&---------------------------------------------------------------------*
*&      Form  create_selection_table_0025
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_SELECTION_TABLE_0025 .
  REFRESH GT_SELTAB.    CLEAR GT_SELTAB.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
  ELSE.
    LOOP AT ROW_TABLE.
      CLEAR GT_AFKO.
      READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.

      CLEAR  GS_SELTAB_WA.
      MOVE: 'P_PWERK'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,    " PARAMETER
             P_PWERK           TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

      CLEAR GS_SELTAB_WA.
      MOVE: 'S_DISPO'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,    "
             GT_AFKO-DISPO     TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

      CLEAR GS_SELTAB_WA.
      MOVE: 'S_AUFNR'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,    "
             GT_AFKO-AUFNR     TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

* 작업지시 릴리즈에 공정코드가 필수사항이 됨에 따른 오류 Fix
      CLEAR GS_SELTAB_WA.
      MOVE: 'S_PROCD'          TO GS_SELTAB_WA-SELNAME,
            'P'                TO GS_SELTAB_WA-KIND,    "
            '*'                TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " create_selection_table_0025
*&---------------------------------------------------------------------*
*&      Form  pov_for_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_STATUS_LOW  text
*----------------------------------------------------------------------*
FORM POV_FOR_STATUS  CHANGING PV_STATUS        LIKE RC65D-STTXT.
  DATA: LT_RETURN_TAB TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_STATUS OCCURS 0,
          STTXT LIKE RC65D-STTXT,
        END   OF LT_STATUS.

  CLEAR LT_STATUS.  LT_STATUS = TEXT-039. APPEND LT_STATUS."작업지시전
  CLEAR LT_STATUS.  LT_STATUS = TEXT-040. APPEND LT_STATUS."작업대기
  CLEAR LT_STATUS.  LT_STATUS = TEXT-044. APPEND LT_STATUS."작업중
  CLEAR LT_STATUS.  LT_STATUS = TEXT-002. APPEND LT_STATUS."작업완료
  CLEAR LT_STATUS.  LT_STATUS = TEXT-041. APPEND LT_STATUS."오더종료
  CLEAR LT_STATUS.  LT_STATUS = TEXT-045. APPEND LT_STATUS."비정상오더

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'STTXT'
      DYNPPROG     = SY-CPROG
      DYNPNR       = SY-DYNNR
      WINDOW_TITLE = TEXT-051 "오더상태
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = LT_STATUS
      RETURN_TAB   = LT_RETURN_TAB.

  READ TABLE LT_RETURN_TAB INDEX 1.

  PV_STATUS  = LT_RETURN_TAB-FIELDVAL.

ENDFORM.                    " pov_for_status
*&---------------------------------------------------------------------*
*&      Form  pov_for_aprio
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_APRIO  text
*----------------------------------------------------------------------*
FORM POV_FOR_APRIO  CHANGING PV_APRIO.
  DATA: LT_RETURN_TAB TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_APRIO OCCURS 0,
          APRIO LIKE AFKO-APRIO,
          DESCR TYPE LTRM_LTEXT,
        END   OF LT_APRIO.

  SELECT SUBKEY VALUE INTO (LT_APRIO-APRIO,LT_APRIO-DESCR)
                      FROM ZPPT0000
                     WHERE SECTIONID = 'FIXED_VALUES'
                       AND KEYID     = 'APRIO'.
    APPEND LT_APRIO. CLEAR LT_APRIO.
  ENDSELECT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'APRIO'
      DYNPPROG     = SY-CPROG
      DYNPNR       = SY-DYNNR
      WINDOW_TITLE = TEXT-F31 "세부유형
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = LT_APRIO
      RETURN_TAB   = LT_RETURN_TAB.

  READ TABLE LT_RETURN_TAB INDEX 1.

  PV_APRIO  = LT_RETURN_TAB-FIELDVAL.

ENDFORM.                    " pov_for_aprio
*&---------------------------------------------------------------------*
*&      Form  initial_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIAL_PROC .
  DATA: LS_SPGCD LIKE ZPPT0030-SPGCD.

  RANGES : LS_GSTRS FOR AFKO-GSTRS OCCURS 0.

  DATA : BEGIN OF GT_AUFNR OCCURS 0.
  DATA : AUFNR TYPE AFKO-AUFNR,
         END OF GT_AUFNR.

  CLEAR : GV_SKIP.

*& 공정코드 WHERE 조건 설정...
  IF S_PROCD-LOW IS INITIAL.
    GV_MATKL = '%'.
  ELSE.
    CONCATENATE '____' S_PROCD-LOW '%'  INTO GV_MATKL.
  ENDIF.

  REPLACE '*' IN GV_MATKL WITH '%'.

*& TECO/DLFL 조건 설정...
  REFRESH GT_WTAB.                          CLEAR GT_WTAB.
  IF C_TECO = 'X'.
    CONCATENATE '    B~IDAT2 EQ ' ' ''00000000'' '  INTO GT_WTAB.
    APPEND GT_WTAB.                         CLEAR GT_WTAB.

    CONCATENATE 'AND B~LOEKZ EQ ' ' '' '' '  INTO GT_WTAB.
    APPEND GT_WTAB.                         CLEAR GT_WTAB.

  ENDIF.

*& 2008.02.29
*& CSR : C20080228_24725
*& 동적 변형의 p_date1, p_date2가 있으면 작업시작/종료 일자 조건에 저장
  IF P_DATE1 IS NOT INITIAL AND
     P_DATE2 IS NOT INITIAL.
    S_GSTRS-SIGN = 'I'.
    S_GSTRS-OPTION = 'BT'.
    S_GSTRS-LOW  = P_DATE1.
    S_GSTRS-HIGH = P_DATE2.
    APPEND S_GSTRS.

  ENDIF.

*& 2010.07.08 JS전선은 시작/종료일이 없으면 -3 ~ 3개월로 오더 상태 변경
  IF S_GSTRS[] IS INITIAL AND
     S_AUFNR[] IS INITIAL AND
     P_PWERK+0(1) = '2'.

    CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
      EXPORTING
        DMM_DATIN = SY-DATUM
        DMM_COUNT = '3'
        DMM_OPER  = '-'
        DMM_POS   = ' '
      IMPORTING
        DMM_DAOUT = S_GSTRS-LOW
      EXCEPTIONS
        UNKNOWN   = 1
        OTHERS    = 2.

    CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
      EXPORTING
        DMM_DATIN = SY-DATUM
        DMM_COUNT = '3'
        DMM_OPER  = '+'
        DMM_POS   = ' '
      IMPORTING
        DMM_DAOUT = S_GSTRS-HIGH
      EXCEPTIONS
        UNKNOWN   = 1
        OTHERS    = 2.

    S_GSTRS-SIGN = 'I'.
    S_GSTRS-OPTION = 'BT'.

    APPEND S_GSTRS.

  ENDIF.

  IF S_GSTRS[] IS INITIAL.  "시작일자가 없으면 -6 ~ +6개월로 오더상태만

    CLEAR : LS_GSTRS[], LS_GSTRS.

    CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
      EXPORTING
        DMM_DATIN = SY-DATUM
        DMM_COUNT = '6'
        DMM_OPER  = '-'
        DMM_POS   = ' '
      IMPORTING
        DMM_DAOUT = LS_GSTRS-LOW
      EXCEPTIONS
        UNKNOWN   = 1
        OTHERS    = 2.

    CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
      EXPORTING
        DMM_DATIN = SY-DATUM
        DMM_COUNT = '6'
        DMM_OPER  = '+'
        DMM_POS   = ' '
      IMPORTING
        DMM_DAOUT = LS_GSTRS-HIGH
      EXCEPTIONS
        UNKNOWN   = 1
        OTHERS    = 2.

    LS_GSTRS-SIGN = 'I'.
    LS_GSTRS-OPTION = 'BT'.

    APPEND LS_GSTRS.
  ENDIF.

  IF P_PWERK = '1301' AND
     S_DISPO+3(2) = 'LN' AND
     ( GV_MATKL+4(3) = 'PTS' OR
       GV_MATKL+4(3) = 'INS' OR
       GV_MATKL+4(3) = 'UST' OR
       GV_MATKL+4(3) = 'BUN' ).

    GV_SKIP = 'X'.

  ENDIF.

  IF S_STATUS-LOW = 'B' OR
     S_STATUS-LOW = 'C' OR
     S_STATUS-LOW = 'D' OR
     S_STATUS-LOW = 'E' OR
     S_STATUS-LOW = 'F' OR
     S_STATUS-LOW = 'G'.

    REFRESH: GT_SELTAB.
    CLEAR  : GT_SELTAB, GS_SELTAB_WA.

    IF S_GSTRS[] IS NOT INITIAL.
      SELECT DISTINCT A~AUFNR AS LOW
        INTO CORRESPONDING FIELDS OF TABLE GT_SELTAB
        FROM AFKO AS A  INNER JOIN AUFK AS B
                                ON A~AUFNR = B~AUFNR
                        INNER JOIN AFPO AS C
                                ON A~AUFNR = C~AUFNR
                        INNER JOIN AFVC AS D
                                ON A~AUFPL = D~AUFPL
                        INNER JOIN CRHD AS E
                                ON D~ARBID = E~OBJID
                               AND E~OBJTY = 'A'
                               AND E~WERKS = P_PWERK
                        INNER JOIN MARA AS F
                                ON C~MATNR = F~MATNR
       WHERE A~DISPO    IN  S_DISPO
         AND A~AUFNR    IN  S_AUFNR
         AND A~GSTRS    IN  S_GSTRS
         AND A~FTRMI    IN  S_FTRMI
         AND A~APRIO    IN  S_APRIO
         AND C~PWERK    EQ  P_PWERK
         AND C~MATNR    IN  S_MATNR
         AND C~DAUAT    IN  S_DAUAT
*      AND c~xloek    EQ  space
         AND D~APLFL    IN ('','000000' )   "순서
         AND E~ARBPL    IN  S_ARBPL
*       AND e~objty    EQ 'A'            "작업장
         AND F~MATKL  LIKE  GV_MATKL     "자재그룹
         AND (GT_WTAB).
    ELSE.
      SELECT DISTINCT A~AUFNR AS LOW
        INTO CORRESPONDING FIELDS OF TABLE GT_SELTAB
        FROM AFKO AS A  INNER JOIN AUFK AS B
                                ON A~AUFNR = B~AUFNR
                        INNER JOIN AFPO AS C
                                ON A~AUFNR = C~AUFNR
                        INNER JOIN AFVC AS D
                                ON A~AUFPL = D~AUFPL
                        INNER JOIN CRHD AS E
                                ON D~ARBID = E~OBJID
                               AND E~OBJTY = 'A'
                               AND E~WERKS = P_PWERK
                        INNER JOIN MARA AS F
                                ON C~MATNR = F~MATNR
       WHERE A~DISPO    IN  S_DISPO
         AND A~AUFNR    IN  S_AUFNR
         AND A~GSTRS    IN  LS_GSTRS
         AND A~FTRMI    IN  S_FTRMI
         AND A~APRIO    IN  S_APRIO
         AND C~PWERK    EQ  P_PWERK
         AND C~MATNR    IN  S_MATNR
         AND C~DAUAT    IN  S_DAUAT
*      AND c~xloek    EQ  space
         AND D~APLFL    IN ('','000000' )   "순서
         AND E~ARBPL    IN  S_ARBPL
*       AND e~objty    EQ 'A'            "작업장
         AND F~MATKL  LIKE  GV_MATKL     "자재그룹
         AND (GT_WTAB).

    ENDIF.

    LOOP AT GT_SELTAB.

      MOVE: 'S_AUFNR'          TO GT_SELTAB-SELNAME,
            'S'                TO GT_SELTAB-KIND,    " SELECT-OPTION
            'I'                TO GT_SELTAB-SIGN,
            'EQ'               TO GT_SELTAB-OPTION.

      MODIFY GT_SELTAB.
      CLEAR  GT_SELTAB.
    ENDLOOP.

    SUBMIT ZPPR0063 WITH SELECTION-TABLE GT_SELTAB
*&                           VIA SELECTION-SCREEN
                     AND RETURN.
  ENDIF.

*& 2007.09.11 회사코드 조회
  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_WERKS = P_PWERK
    IMPORTING
      E_BUKRS = GV_BUKRS.

ENDFORM.                    " initial_proc
*&---------------------------------------------------------------------*
*&      Form  get_aprio_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_APRIO_TEXT .
  CLEAR ZPPT0000.
  SELECT SINGLE VALUE INTO GT_AFKO-APRIO_T
           FROM ZPPT0000
          WHERE SECTIONID = 'FIXED_VALUES'
            AND KEYID     = 'APRIO'
            AND SUBKEY    =  GT_AFKO-APRIO.
ENDFORM.                    " get_aprio_text
*&---------------------------------------------------------------------*
*&      Form  save_text_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_TEXT_PROC .
  DATA: LS_THEAD      TYPE THEAD.

  CASE GV_BUTTON.
    WHEN 'MENU'.  "툴바의 버튼이 눌린 경우...
*&      LOOP AT gt_afko WHERE check = 'X'.
*&        PERFORM build_text_head CHANGING ls_thead.
*&        PERFORM call_func_save_text USING ls_thead.
*&
*&        MODIFY gt_afko.
*&      ENDLOOP.
    WHEN 'GRID'.  "리스트의 버튼이 눌린 경우...
      PERFORM BUILD_TEXT_HEAD CHANGING LS_THEAD.
      PERFORM CALL_FUNC_SAVE_TEXT USING LS_THEAD.
    WHEN  OTHERS.
  ENDCASE.
  CLEAR GV_BUTTON.

ENDFORM.                    " save_text_proc
*&---------------------------------------------------------------------*
*&      Form  build_text_head
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_THEAD  text
*----------------------------------------------------------------------*
FORM BUILD_TEXT_HEAD  CHANGING PS_THEAD TYPE THEAD.
  DATA: LV_REC_CNT        LIKE SY-TABIX.

  DESCRIBE TABLE GT_TLINES LINES LV_REC_CNT.

  MOVE: 'AUFK'                         TO PS_THEAD-TDOBJECT,
        'KOPF'                         TO PS_THEAD-TDID,
        '3'                            TO PS_THEAD-TDSPRAS,
*        'ㅅㄷㄴㅅ'                     to ps_thead-TDTITLE,
*        'SYSTEM'                       to ps_thead-tdform,
         SY-MANDT                      TO PS_THEAD-MANDT,
         SY-UNAME                      TO PS_THEAD-TDFUSER,
         SY-SAPRL                      TO PS_THEAD-TDFRELES,
         SY-DATUM                      TO PS_THEAD-TDFDATE,
         SY-UZEIT                      TO PS_THEAD-TDFTIME,
         SY-UNAME                      TO PS_THEAD-TDLUSER,
         SY-SAPRL                      TO PS_THEAD-TDLRELES,
         SY-DATUM                      TO PS_THEAD-TDLDATE,
         SY-UZEIT                      TO PS_THEAD-TDLTIME,
        '72'                           TO PS_THEAD-TDLINESIZE,
         LV_REC_CNT                    TO PS_THEAD-TDTXTLINES.
  CONCATENATE SY-MANDT GT_AFKO-AUFNR INTO PS_THEAD-TDNAME.

ENDFORM.                    " build_text_head
*&---------------------------------------------------------------------*
*&      Form  call_func_save_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_THEAD  text
*----------------------------------------------------------------------*
FORM CALL_FUNC_SAVE_TEXT  USING  PS_THEAD TYPE THEAD.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = PS_THEAD
*&          insert          = 'X'
      SAVEMODE_DIRECT = 'X'
*&          OWNER_SPECIFIED = 'X'
*&  importing
*&        function        =
*&        NEWHEADER       =
    TABLES
      LINES           = GT_TLINES
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBJECT          = 4.

*& SAP Table Update...
*& 오더마스터(AUFK) 테이블의 설명있음 필드(LTEXT)의 값을 변경...
  CHECK SY-SUBRC = 0.
  IF GT_TLINES[] IS INITIAL.
    UPDATE AUFK SET: LTEXT = ''
              WHERE  AUFNR = GT_AFKO-AUFNR.
    GT_AFKO-LTEXT = ''.
    GT_AFKO-BUTTON = '@0K@@B_NOCR@'.
  ELSE.
    UPDATE AUFK SET: LTEXT = SY-LANGU
              WHERE  AUFNR = GT_AFKO-AUFNR.

    GT_AFKO-LTEXT = SY-LANGU.
    GT_AFKO-BUTTON = '@0L@@B_NODP@'.
  ENDIF.

ENDFORM.                    " call_func_save_text
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS .
*- Start 2024.10.22 단위 테스트 요청 사항 반영
  IF GO_GRID_0100 IS NOT BOUND.

    PERFORM SET_OBJECT_GRID_0100.
*& Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
*& GRID 속성 지정(Display): Display시 옵션 지정
    PERFORM SET_LAYOUT_GRID_0100.
*& 출력할 필드 속성을 정의
    PERFORM SET_FIELDCAT_GRID_0100.

*    PERFORM set_cell_attribute_grid_0100.

    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.

    PERFORM CALL_GRID_0100_DISPLAY.

  ENDIF.
*- End 2024.10.22
ENDFORM.                    " create_and_init_controls
*&---------------------------------------------------------------------*
*&      Form  call_screen_900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1929   text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_900 USING PV_BUTTON.
  CASE PV_BUTTON.
    WHEN 'MENU'.
      READ TABLE GT_AFKO WITH KEY CHECK = 'X'.
      IF SY-SUBRC = 0.
        GV_BUTTON = PV_BUTTON.
        CALL SCREEN 900 STARTING AT 10   2
                          ENDING AT 75  15.
      ELSE.
        MESSAGE S004 WITH TEXT-052. "선택된 라인이 없습니다!!!
      ENDIF.
    WHEN 'GRID'.
      GV_BUTTON = PV_BUTTON.
      CALL SCREEN 900 STARTING AT 10   2
                        ENDING AT 75  15.

    WHEN 'STOCK'.
      GV_BUTTON = PV_BUTTON.
      CALL SCREEN 901 STARTING AT 10   2
                        ENDING AT 110  23.

    WHEN 'ETC'.
      GV_BUTTON = PV_BUTTON.
      CALL SCREEN 902 STARTING AT 10   2
                        ENDING AT 75  15.
    WHEN 'GRID2'.
      GV_BUTTON = PV_BUTTON.
      CALL SCREEN 904 STARTING AT 10   2
                        ENDING AT 132  30.

    WHEN  OTHERS.
  ENDCASE.

  CLEAR GV_BUTTON.

ENDFORM.                    " call_screen_900
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_afko_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_AFKO_DISPLAY .

  DATA: LS_SCROLL       TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.     "현재 그대로 입력한 refresh

ENDFORM.                    " refresh_gt_afko_display
*&---------------------------------------------------------------------*
*&      Form  print_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PROC .
  DATA: LT_ZPPS003 LIKE ZPPS003 OCCURS 0 WITH HEADER LINE,
        LV_BDMNG   TYPE P DECIMALS 1.

  REFRESH LT_ZPPS003.            CLEAR LT_ZPPS003.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
  ELSE.
    LOOP AT ROW_TABLE.
      CLEAR GT_AFKO.
      READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.
      MOVE-CORRESPONDING GT_AFKO  TO LT_ZPPS003.
      CONDENSE: LT_ZPPS003-LENGTH,
                LT_ZPPS003-FACTOR NO-GAPS.

*& 광케이블의 경우, 꼬리표번호를 가져온다...
      IF GT_AFKO-DISPO = 'OCH'.
        CLEAR  RESB.
        SELECT SINGLE MATNR CHARG
                 INTO (RESB-MATNR, RESB-CHARG)
                 FROM RESB
                WHERE WERKS  = P_PWERK
                  AND AUFNR  = GT_AFKO-AUFNR
                  AND VORNR  = GT_AFKO-VORNR
                  AND SHKZG  = 'H'
                  AND BAUGR  = GT_AFKO-MATNR
                  AND CHARG <> SPACE.
        IF SY-SUBRC = 0.
          CLEAR  ZPPT0001.
          SELECT SINGLE TAGNR INTO LT_ZPPS003-TAGNR
                   FROM ZPPT0001
                  WHERE WERKS = P_PWERK
                    AND MATNR = RESB-MATNR
                    AND CHARG = RESB-CHARG.
        ENDIF.
      ENDIF.

*& 2008.06.10
*& CSR : C20080609_79265
*& JS전선 '2201','2301' 플랜트의 INS,TAP,SHE,STP,MRK 공정일때
*& 하위 반제품의 자재코드,품명규격,소요수량,단위를 출력
* 2014.05.13 풍세전선 반영
      IF ( ( GT_AFKO-WERKS EQ '2201' OR
             GT_AFKO-WERKS EQ '2301' OR
             GT_AFKO-WERKS EQ '1901' )  AND
           ( GT_AFKO-PROCD EQ 'INS' OR GT_AFKO-PROCD EQ 'TAP' OR
             GT_AFKO-PROCD EQ 'SHE' OR GT_AFKO-PROCD EQ 'STP' OR
             GT_AFKO-PROCD EQ 'MRK' ) ).

        CLEAR : LV_BDMNG.

*& 생산오더의 하위 반제품 1개만 조회
        SELECT SINGLE A~MATNR A~BDMNG A~MEINS C~MAKTX
          INTO (LT_ZPPS003-HMATNR, LV_BDMNG, LT_ZPPS003-HMEINS,
                LT_ZPPS003-HMAKTX)
        FROM RESB AS A INNER JOIN MARA AS B
                          ON A~MATNR = B~MATNR
                       INNER JOIN MAKT AS C
                          ON A~MATNR = C~MATNR
       WHERE A~AUFNR  = GT_AFKO-AUFNR
         AND A~WERKS  = GT_AFKO-WERKS
         AND A~KZKUP  = SPACE          " 연산품은 제외
         AND A~XLOEK  = SPACE          " 삭제품목은 제외
         AND A~DUMPS  = SPACE          " 가상품목은 제외
         AND B~MTART  IN ('HALB', 'FERT', 'MCFE', 'MCHF')
         AND C~SPRAS = SY-LANGU.

        WRITE LV_BDMNG TO LT_ZPPS003-HBDMNG LEFT-JUSTIFIED.

      ENDIF.

      APPEND LT_ZPPS003.  CLEAR LT_ZPPS003.
    ENDLOOP.
  ENDIF.

  CHECK NOT LT_ZPPS003[] IS INITIAL.
  PERFORM CALL_SMART_FORMS TABLES LT_ZPPS003
                            USING 'Z_PP_ZPPR0021_FORMS'.

ENDFORM.                    " print_proc
*&---------------------------------------------------------------------*
*&      Form  call_smart_forms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1733   text
*----------------------------------------------------------------------*
FORM CALL_SMART_FORMS TABLES PT_ZPPS003 STRUCTURE ZPPS003
                       USING PV_FORMNAME TYPE TDSFNAME.

  DATA: LV_FM_NAME  TYPE RS38L_FNAM,
        LV_WERKS_NM TYPE MAKTX.

*& 플랜트...
  CLEAR T001W.
  SELECT SINGLE NAME1   INTO T001W-NAME1
           FROM T001W
          WHERE WERKS = P_PWERK.
  CONCATENATE P_PWERK '(' T001W-NAME1 ')'
                        INTO LV_WERKS_NM.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = PV_FORMNAME
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = LV_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID
          TYPE 'S'     "sy-msgty
        NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CALL FUNCTION LV_FM_NAME
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        CONTROL_PARAMETERS = GS_CONTROL_PAR
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
        OUTPUT_OPTIONS     = GS_OUTPUT_OPT
        USER_SETTINGS      = ' '
        IMP_WERKS          = LV_WERKS_NM
*      IMPORTING
*       DOCUMENT_OUTPUT_INFO =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
      TABLES
        PT_ZPPS003         = PT_ZPPS003
      EXCEPTIONS
        FORMATTING_ERROR   = 1
        INTERNAL_ERROR     = 2
        SEND_ERROR         = 3
        USER_CANCELED      = 4
        OTHERS             = 5.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE 'S'     "sy-msgty
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " call_smart_forms
*&---------------------------------------------------------------------*
*&      Form  set_smart_form_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SMART_FORM_PARAMETERS .
*& 스마트폼 제어 매개변수 설정...
  GS_CONTROL_PAR-NO_DIALOG = ' '.     "출력화면 표시여부
*& 출력 매개변수 설정...
  GS_OUTPUT_OPT-TDDEST     = 'ZP01'.  "출력장치
  GS_OUTPUT_OPT-TDIMMED    = 'X'.     "Print immdiately.
  GS_OUTPUT_OPT-TDNEWID    = 'X'.     "New spool request.
  GS_OUTPUT_OPT-TDDELETE   = 'X'.     "Delete after printing.
  GS_OUTPUT_OPT-TDNOPREV   = ' '.     "No print preview
  GS_OUTPUT_OPT-TDNOPRINT  = ' '.     "
  GS_OUTPUT_OPT-TDFINAL    = ' '.     "스풀 요청을 완료

ENDFORM.                    " set_smart_form_parameters
*&---------------------------------------------------------------------*
*&      Form  submit_zppu0117_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZPPU0117_PROC .
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  LOOP AT ROW_TABLE.
    CLEAR GT_AFKO.
    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.

*& 작업상태 체크...
    IF GT_AFKO-STTXT = TEXT-039 OR "작업지시전
       GT_AFKO-STTXT = TEXT-040."작업대기
    ELSE.
      MESSAGE W004 WITH TEXT-053."작업지시전이나 대기인 경우만
      "뱃치결정이 가능합니다.
      CONTINUE.
    ENDIF.

*& 가능공정 체크...
    CLEAR  ZPPT0000.
    SELECT SINGLE MANDT INTO ZPPT0000-MANDT
             FROM ZPPT0000
            WHERE SECTIONID = 'BATCH_ASSIGN'
              AND KEYID     =  GT_AFKO-DISPO+0(2)
              AND SUBKEY    =  GT_AFKO-PROCD.
    IF SY-SUBRC <> 0.
      MESSAGE W004 WITH TEXT-054."뱃치를 결정할수 있는 공정이 아닙니다.
      CONTINUE.
    ENDIF.

*& 뱃치결정 프로그램 호출...
    REFRESH GT_SELTAB.    CLEAR GT_SELTAB.
    CLEAR  GS_SELTAB_WA.
    MOVE: 'P_AUFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_AFKO-AUFNR     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'P_DMODE'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
          'N'                TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    SUBMIT ZPPU0117 WITH SELECTION-TABLE GT_SELTAB
*&                       VIA SELECTION-SCREEN
                     AND RETURN.

  ENDLOOP.
ENDFORM.                    " submit_zppu0117_proc
*&---------------------------------------------------------------------*
*&      Form  char_to_decmals
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_ZPPS040_LENGTH  text
*----------------------------------------------------------------------*
FORM CHAR_TO_DECMALS USING PV_INPUT
                  CHANGING PV_OUTPUT.

  DATA: LV_OUTPUT     TYPE ATWRT.

  CALL FUNCTION 'Z_PP_CHAR_TO_DECMALS'
    EXPORTING
      IF_INPUT  = PV_INPUT
    IMPORTING
      IF_OUTPUT = LV_OUTPUT.

  PV_OUTPUT = LV_OUTPUT.

ENDFORM.                    " char_to_decmals
*&---------------------------------------------------------------------*
*&      Form  authority_checking_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*- Start 2025.05.22
**& 플랜트에 대한 권한체크
*  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
*                      ID 'WERKS'  FIELD p_pwerk.
*
*  IF sy-subrc <> 0.
*    MESSAGE e003 WITH TEXT-016 p_pwerk TEXT-017.
*  ELSE.
**& SPG에 대한 권한체크
*  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
*                      ID 'WERKS'  FIELD p_pwerk
*                      ID 'SPGCD'  FIELD s_procd-low.
*
*  IF sy-subrc <> 0.
*    MESSAGE e003 WITH 'SPG {' s_procd-low TEXT-017.
*  ELSE.
*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
  ID 'WERKS'  FIELD P_PWERK
  ID 'DISPO'  FIELD S_DISPO-LOW.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH TEXT-018 S_DISPO-LOW TEXT-017.
  ENDIF.
*  ENDIF.
*  ENDIF.
*- End 2025.05.22
ENDFORM.                    " authority_checking_proc
*&---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .


ENDFORM.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  select_proc2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PROC2 .

  REFRESH GT_AFKO. CLEAR GT_AFKO.
*& 2006.07.24 CSR번호:C2006071001000000664
*& 판매오더번호,품목번호 조건 추가

*& 2006.09.11 CSR번호 :
*& 작업의 제어키 ZP03(Dummy) 조회 삭제
*- Start 2024.10.16 SELECT ~ ENDSELECT -> SELECT ~ INTO ... TABLE. LOOP ~ ENDLOOP.
*- Start 2025.02.04 배치 잡 전송일 경우 최대 적중수 조건 제외
  PERFORM GET_DATA_SELECT_PROC2.
*- End 2025.02.04
  LOOP AT GT_AFKO.
*& 제어키로 외주공정 여부 체크...
    IF GT_AFKO-STEUS = 'PP02' OR
       GT_AFKO-STEUS = 'PP06'.
      GT_AFKO-EXFLG = 'Y'.
    ELSE.
      GT_AFKO-EXFLG = 'N'.
    ENDIF.
*& 공정코드 = 자재그룹의 5-7자리의 문자를 사용...
    MOVE GT_AFKO-MATKL+4(3)     TO GT_AFKO-PROCD.
*& 작업 우선순의를 결정하기위한 Key Field 생성...
*&    CONCATENATE gt_afko-plnnr
    CONCATENATE GT_AFKO-PROCD
                GT_AFKO-ARBPL
                GT_AFKO-GSTRS INTO GT_AFKO-ZSORT.

    MOVE: GT_AFKO-GSUZS         TO GT_AFKO-GSUZS_S,
          GT_AFKO-PWERK         TO GT_AFKO-WERKS.

    GT_AFKO-PNMNG = GT_AFKO-PSMNG - GT_AFKO-PSAMG.

    IF P_PWERK EQ '1401'     AND
       S_DISPO+3(2) EQ 'OF'  AND
     ( S_PROCD+3(3) EQ 'FDM' OR
       S_PROCD+3(3) EQ 'HPT' ).
      PERFORM GET_BIGO_TEXT.
    ENDIF.
*- Start 2024.10.16 생산 오더 번호 취합
    PERFORM GET_AUFNR.
*- End 2024.10.16
    MODIFY GT_AFKO. CLEAR GT_AFKO.

  ENDLOOP.
*- End 2024.10.16
  SORT GT_AFKO BY ZSORT GSUZS_S AUFNR.

ENDFORM.                    " select_proc2
*&---------------------------------------------------------------------*
*&      Form  select_proc1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PROC1 .

  REFRESH GT_AFKO.        CLEAR GT_AFKO.
*& 2006.07.24 CSR번호:C2006071001000000664
*& 판매오더번호,품목번호 조건 추가

*& 2006.09.11 CSR번호 :
*& 작업의 제어키 ZP03(Dummy) 조회 삭제
*- Start 2024.10.16 SELECT ~ ENDSELECT -> SELECT ~ INTO ... TABLE. LOOP ~ ENDLOOP.
*- Start 2025.02.04 배치 잡 전송일 경우 최대 적중수 조건 제외
  PERFORM GET_DATA_SELECT_PROC1.
*- End 2025.02.04
  LOOP AT GT_AFKO.
*& 제어키로 외주공정 여부 체크...
    IF GT_AFKO-STEUS = 'PP02' OR
       GT_AFKO-STEUS = 'PP06'.
      GT_AFKO-EXFLG = 'Y'.
    ELSE.
      GT_AFKO-EXFLG = 'N'.
    ENDIF.
*& 공정코드 = 자재그룹의 5-7자리의 문자를 사용...
    MOVE GT_AFKO-MATKL+4(3)     TO GT_AFKO-PROCD.
*& 작업 우선순의를 결정하기위한 Key Field 생성...
*&    CONCATENATE gt_afko-plnnr
    CONCATENATE GT_AFKO-PROCD
                GT_AFKO-ARBPL
                GT_AFKO-GSTRS INTO GT_AFKO-ZSORT.

    MOVE: GT_AFKO-GSUZS         TO GT_AFKO-GSUZS_S,
          GT_AFKO-PWERK         TO GT_AFKO-WERKS.

    GT_AFKO-PNMNG = GT_AFKO-PSMNG - GT_AFKO-PSAMG.

    IF P_PWERK EQ '1401'     AND
       S_DISPO+3(2) EQ 'OF'  AND
     ( S_PROCD+3(3) EQ 'FDM' OR
       S_PROCD+3(3) EQ 'HPT' ).
      PERFORM GET_BIGO_TEXT.
    ENDIF.
*- Start 2024.10.16 생산 오더 번호 취합
    PERFORM GET_AUFNR.
*- End 2024.10.16
    MODIFY GT_AFKO. CLEAR GT_AFKO.

  ENDLOOP.
*- End 2024.10.16
  SORT GT_AFKO BY ZSORT GSUZS_S AUFNR.

ENDFORM.                    " select_proc1
*&---------------------------------------------------------------------*
*&      Form  get_stock_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AFKO_AUFNR  text
*      -->P_LV_CHK  text
*----------------------------------------------------------------------*
FORM GET_STOCK_STATUS  USING    PV_AUFNR
                                PV_MATKL
                                PV_ARBPL
                                PV_CHK.

  DATA : BEGIN OF LT_RESB OCCURS 0,
           MATNR  TYPE RESB-MATNR,
           LGORT  TYPE RESB-LGORT,
           BDMNG  TYPE RESB-BDMNG,
           MEINS  TYPE RESB-MEINS,
           STOCK1 TYPE RESB-BDMNG,     "+공차
           STOCK2 TYPE RESB-BDMNG,     "-공차
           MATKL  TYPE MARA-MATKL,
         END OF LT_RESB.

  DATA : BEGIN OF LT_CHARG OCCURS 0,
           WERKS TYPE RESB-WERKS,
           MATNR TYPE RESB-MATNR,
           CHARG TYPE RESB-CHARG,
           TAGNR TYPE ZPPT0001-TAGNR,
         END OF LT_CHARG.

  DATA : LT_STOCK LIKE LT_CHARG OCCURS 0 WITH HEADER LINE.

  DATA : LV_CNT     TYPE I.

  CLEAR : LT_RESB, LT_CHARG, LT_STOCK, LV_CNT.
  REFRESH : LT_STOCK, LT_CHARG, LT_STOCK.

*& 생산오더의 Push 반제품과 소요량을 조회

  SELECT A~MATNR A~LGORT A~BDMNG A~MEINS B~MATKL
    INTO CORRESPONDING FIELDS OF TABLE LT_RESB
    FROM RESB AS A INNER JOIN MARA AS B
                      ON A~MATNR = B~MATNR
   WHERE A~AUFNR  = PV_AUFNR
     AND A~WERKS = P_PWERK
     AND A~KZKUP  = SPACE          " 연산품은 제외
     AND A~XLOEK  = SPACE          " 삭제품목은 제외
     AND A~DUMPS  = SPACE          " 가상품목은 제외
     AND A~RGEKZ  NE 'X'           " 백플러쉬 제외
     AND B~MTART  IN ('HALB', 'FERT', 'MCFE', 'MCHF').

*& 2009.09.18 CSR : C20090917_26138
*& PTS,UST 공정일때만 CCB,CST 자재일 경우 체크 로직에서 제외
  IF PV_MATKL+4(3) EQ 'PTS' OR
     PV_MATKL+4(3) EQ 'UST'.
    LOOP AT LT_RESB.
      IF LT_RESB-MATKL+4(3) EQ 'CCB' OR
         LT_RESB-MATKL+4(3) EQ 'CST'.
        DELETE LT_RESB.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT LT_RESB WHERE BDMNG > 0.

    CLEAR : LT_CHARG.     REFRESH : LT_CHARG.

    LT_RESB-STOCK1 = LT_RESB-BDMNG + LT_RESB-BDMNG * '0.01'.
    LT_RESB-STOCK2 = LT_RESB-BDMNG - LT_RESB-BDMNG * '0.01'.

*& mchb에서 해당 플랜트,자재코드,저장위치에 +- 소요량에 있는
*& 재고가 있는지 확인

    IF P_PWERK EQ '1901'.
      SELECT A~WERKS A~MATNR A~CHARG B~TAGNR
        INTO CORRESPONDING FIELDS OF TABLE LT_CHARG
        FROM MCHB AS A INNER JOIN ZPPT0001 AS B
                          ON A~WERKS = B~WERKS
                         AND A~MATNR = B~MATNR
                         AND A~CHARG = B~CHARG
       WHERE A~WERKS = P_PWERK
         AND A~LGORT = LT_RESB-LGORT
         AND A~MATNR = LT_RESB-MATNR
         AND A~CLABS BETWEEN LT_RESB-STOCK2 AND LT_RESB-STOCK1
         AND B~GIFLG = 'N'
         AND B~REMAIN BETWEEN LT_RESB-STOCK2 AND LT_RESB-STOCK1
         AND B~INSPFLG = 'OK'.
    ELSE.
      SELECT A~WERKS A~MATNR A~CHARG B~TAGNR
        INTO CORRESPONDING FIELDS OF TABLE LT_CHARG
        FROM MCHB AS A INNER JOIN ZPPT0001 AS B
                          ON A~WERKS = B~WERKS
                         AND A~MATNR = B~MATNR
                         AND A~CHARG = B~CHARG
       WHERE A~WERKS = P_PWERK
         AND A~LGORT = LT_RESB-LGORT
         AND A~MATNR = LT_RESB-MATNR
         AND A~CLABS >= LT_RESB-BDMNG
         AND B~GIFLG = 'N'
         AND B~REMAIN >= LT_RESB-BDMNG
         AND B~INSPFLG = 'OK'.
    ENDIF.

*& 다른 설비에 이미 투입된 재고인지 확인
    LOOP AT LT_CHARG.

      SELECT COUNT( DISTINCT TAGNR )
        INTO LV_CNT
        FROM ZPPT0021
       WHERE TAGNR = LT_CHARG-TAGNR
         AND WERKS = LT_CHARG-WERKS
         AND FITYN = 'I'
         AND MATNR = LT_CHARG-MATNR
         AND CHARG = LT_CHARG-CHARG
         AND ARBPL NE PV_ARBPL.

      IF LV_CNT > 0.

        DELETE LT_CHARG.

      ENDIF.
    ENDLOOP.

    IF LT_CHARG[] IS NOT INITIAL.

*& 소요량 재고로 쓰인 재고라면 삭제, 아니면 소요량 재고에 추가
      LOOP AT LT_STOCK.

        DELETE LT_CHARG WHERE MATNR = LT_STOCK-MATNR
                          AND CHARG = LT_STOCK-CHARG.

      ENDLOOP.

      IF LT_CHARG[] IS NOT INITIAL.   "소요량 재고가 있다면 추가

        READ TABLE LT_CHARG INDEX 1.

        LT_STOCK-MATNR = LT_CHARG-MATNR.
        LT_STOCK-CHARG = LT_CHARG-CHARG.

        APPEND LT_STOCK.

      ELSE.               "소요량 재고가 없다면 pv_chk ='X'후 EXIT

        PV_CHK = 'X'.

        EXIT.

      ENDIF.

    ELSE.               " mchb에 재고가 없으면 pv_chk ='X'후 EXIT

      PV_CHK = 'X'.

      EXIT.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " get_stock_status
*&---------------------------------------------------------------------*
*&      Form  get_aufnr_stock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AFKO_AUFNR  text
*----------------------------------------------------------------------*
FORM GET_AUFNR_STOCK  USING    PV_AUFNR.

  DATA : BEGIN OF LT_RESB OCCURS 0,
           MATNR  TYPE RESB-MATNR,
           LGORT  TYPE RESB-LGORT,
           BDMNG  TYPE RESB-BDMNG,
           MEINS  TYPE RESB-MEINS,
           STOCK1 TYPE RESB-BDMNG,     "+공차
           STOCK2 TYPE RESB-BDMNG,     "-공차
           MATKL  TYPE MARA-MATKL,
         END OF LT_RESB.

  DATA : BEGIN OF LT_CHARG OCCURS 0,
           WERKS  TYPE RESB-WERKS,
           MATNR  TYPE RESB-MATNR,
           CHARG  TYPE RESB-CHARG,
           TAGNR  TYPE ZPPT0001-TAGNR,
           CLABS  TYPE MCHB-CLABS,
           REMAIN TYPE ZPPT0001-REMAIN,
           MEINS  TYPE ZPPT0001-MEINS,
           MAKTX  TYPE MAKT-MAKTX,
         END OF LT_CHARG.

  DATA : LT_STOCK LIKE GT_STOCK OCCURS 0 WITH HEADER LINE.

  DATA : LV_CNT     TYPE I.

  CLEAR : LT_RESB, LT_CHARG, LT_STOCK, LV_CNT.
  REFRESH : LT_STOCK, LT_CHARG, LT_STOCK.

*& 생산오더의 Push 반제품과 소요량을 조회

  SELECT A~MATNR A~LGORT A~BDMNG A~MEINS B~MATKL
    INTO CORRESPONDING FIELDS OF TABLE LT_RESB
    FROM RESB AS A INNER JOIN MARA AS B
                      ON A~MATNR = B~MATNR
   WHERE A~AUFNR  = PV_AUFNR
     AND A~WERKS  = P_PWERK
     AND A~KZKUP  = SPACE          " 연산품은 제외
     AND A~XLOEK  = SPACE          " 삭제품목은 제외
     AND A~DUMPS  = SPACE          " 가상품목은 제외
     AND A~RGEKZ  NE 'X'           " 백플러쉬 제외
     AND B~MTART  IN ('HALB', 'FERT', 'MCFE', 'MCHF').

*& 2009.09.18 CSR : C20090917_26138
*& PTS,UST 공정일때만 CCB,CST 자재일 경우 체크 로직에서 제외
  IF GT_AFKO-MATKL+4(3) EQ 'PTS' OR
     GT_AFKO-MATKL+4(3) EQ 'UST'.
    LOOP AT LT_RESB.
      IF LT_RESB-MATKL+4(3) EQ 'CCB' OR
         LT_RESB-MATKL+4(3) EQ 'CST'.
        DELETE LT_RESB.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT LT_RESB WHERE BDMNG > 0.

    CLEAR : LT_CHARG.     REFRESH : LT_CHARG.

    LT_RESB-STOCK1 = LT_RESB-BDMNG + LT_RESB-BDMNG * '0.01'.
    LT_RESB-STOCK2 = LT_RESB-BDMNG - LT_RESB-BDMNG * '0.01'.

*& mchb에서 해당 플랜트,자재코드,저장위치에 +- 소요량에 있는
*& 재고가 있는지 확인
    IF P_PWERK = '1901'.
      SELECT A~WERKS A~MATNR A~CHARG B~TAGNR A~CLABS B~REMAIN
             B~MEINS C~MAKTX
        INTO CORRESPONDING FIELDS OF TABLE LT_CHARG
        FROM MCHB AS A INNER JOIN ZPPT0001 AS B
                          ON A~WERKS = B~WERKS
                         AND A~MATNR = B~MATNR
                         AND A~CHARG = B~CHARG
                       INNER JOIN MAKT AS C
                          ON A~MATNR = C~MATNR
       WHERE A~WERKS = P_PWERK
         AND A~LGORT = LT_RESB-LGORT
         AND A~MATNR = LT_RESB-MATNR
         AND A~CLABS BETWEEN LT_RESB-STOCK2 AND LT_RESB-STOCK1
         AND B~GIFLG = 'N'
         AND B~REMAIN BETWEEN LT_RESB-STOCK2 AND LT_RESB-STOCK1
         AND B~INSPFLG = 'OK'
         AND C~SPRAS  =  SY-LANGU.
    ELSE.
      SELECT A~WERKS A~MATNR A~CHARG B~TAGNR A~CLABS B~REMAIN
             B~MEINS C~MAKTX
        INTO CORRESPONDING FIELDS OF TABLE LT_CHARG
        FROM MCHB AS A INNER JOIN ZPPT0001 AS B
                          ON A~WERKS = B~WERKS
                         AND A~MATNR = B~MATNR
                         AND A~CHARG = B~CHARG
                       INNER JOIN MAKT AS C
                          ON A~MATNR = C~MATNR
       WHERE A~WERKS = P_PWERK
         AND A~LGORT = LT_RESB-LGORT
         AND A~MATNR = LT_RESB-MATNR
         AND A~CLABS >= LT_RESB-BDMNG
         AND B~GIFLG = 'N'
         AND B~REMAIN >= LT_RESB-BDMNG
         AND B~INSPFLG = 'OK'
         AND C~SPRAS  =  SY-LANGU.
    ENDIF.

*& 다른 설비에 이미 투입된 재고인지 확인
    LOOP AT LT_CHARG.

      SELECT COUNT( DISTINCT TAGNR )
        INTO LV_CNT
        FROM ZPPT0021
       WHERE TAGNR = LT_CHARG-TAGNR
         AND WERKS = LT_CHARG-WERKS
         AND FITYN = 'I'
         AND MATNR = LT_CHARG-MATNR
         AND CHARG = LT_CHARG-CHARG
         AND ARBPL NE GT_AFKO-ARBPL.

      IF LV_CNT > 0.

        DELETE LT_CHARG.

      ENDIF.
    ENDLOOP.

    IF LT_CHARG[] IS NOT INITIAL.   "소요량 재고가 있다면 추가

      LOOP AT LT_CHARG.
        MOVE-CORRESPONDING LT_CHARG TO LT_STOCK.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LT_STOCK-MATNR
          IMPORTING
            OUTPUT = LT_STOCK-MATNR.

        APPEND LT_STOCK.
      ENDLOOP.

    ELSE.

      EXIT.

    ENDIF.

  ENDLOOP.

  SORT LT_STOCK BY MATNR CHARG TAGNR.

  DELETE ADJACENT DUPLICATES FROM LT_STOCK COMPARING MATNR CHARG TAGNR.

*& 소요량에 맞는 재고를 gt_stock에 복사

  GT_STOCK[] = LT_STOCK[].

ENDFORM.                    " get_aufnr_stock
"RETURN_01
*&---------------------------------------------------------------------*
*&      Form  MOVE_TO_GT_NUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_TO_GT_NUM .

  CLEAR : GT_NUM, GT_NUM[].

  SELECT QMNUM QMTXT
  INTO CORRESPONDING FIELDS OF TABLE GT_NUM
  FROM QMEL
  WHERE MATNR = GT_AFKO-MATNR
    AND MAWERK = GT_AFKO-WERKS
    AND KZLOESCH NE 'X'.

ENDFORM.                    " MOVE_TO_GT_NUM
*&---------------------------------------------------------------------*
*&      Form  WRITE_GT_NR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2307   text
*----------------------------------------------------------------------*
FORM WRITE_GT_NR USING P_TITLE.

  SORT GT_NUM BY QMNUM.

  CALL SCREEN '0101' STARTING AT C_COL1 C_LIN1 ENDING AT C_COL2 C_LIN2.

ENDFORM.                    " WRITE_GT_NR
*&---------------------------------------------------------------------*
*&      Form  LABEL_COUNT
*&---------------------------------------------------------------------*
FORM LABEL_COUNT USING LS_AFKO LIKE LINE OF GT_AFKO.
  DATA: LT_ZPPT0001 LIKE ZPPT0001 OCCURS 0 WITH HEADER LINE.
  CLEAR: LT_ZPPT0001[], LT_ZPPT0001.

  SELECT * FROM ZPPT0001 INTO TABLE LT_ZPPT0001
   WHERE WERKS   = LS_AFKO-WERKS
     AND AUFNR   = LS_AFKO-AUFNR
     AND PRINTYN = 'X'.

  CHECK LT_ZPPT0001[] IS NOT INITIAL.
  LOOP AT LT_ZPPT0001.
    ADD LT_ZPPT0001-PCONT TO LS_AFKO-ZLABEL.
  ENDLOOP.

ENDFORM.                    " LABEL_COUNT
*&---------------------------------------------------------------------*
*&      Form  MATRIAL_GET_CHARACTERISTIC
*&---------------------------------------------------------------------*
FORM MATRIAL_GET_CHARACTERISTIC USING LS_AFKO LIKE LINE OF GT_AFKO.
  DATA: LV_OBJECT LIKE AUSP-OBJEK.
  CLEAR LV_OBJECT.
  LV_OBJECT = LS_AFKO-MATNR.

  PERFORM CLASSIFICATION_FUNCTION_CALL USING LV_OBJECT C_PDMW
                                       CHANGING LS_AFKO-NAPSUN.

ENDFORM.                    " MATRIAL_GET_CHARACTERISTIC
*&---------------------------------------------------------------------*
*&      Form  CLASSIFICATION_FUNCTION_CALL
*&---------------------------------------------------------------------*
FORM CLASSIFICATION_FUNCTION_CALL  USING    P_OBJECT LIKE AUSP-OBJEK
                                            P_ATNAM  TYPE ATNAM
                                   CHANGING P_VALUE  TYPE ATWRT.

  DATA: LV_CLINT  LIKE KLAH-CLINT .

  CLEAR: LV_CLINT,
         GT_CLASS, GT_CLASS[],
         GT_OBJCT, GT_OBJCT[],
         GT_AUSP,  GT_AUSP[],
         GT_CABN,  GT_CABN[].

  CALL FUNCTION '/SAPMP/CE1_CLASSIFICATION_GET'
    EXPORTING
      CLASSTYPE          = '001'
*-> CCM 2023.04.13 오바다 - CUOBN50사용
      OBJECT             = CONV CUOBN50( P_OBJECT )
*<- CCM 2023.04.13 오바다
    TABLES
      T_CLASS            = GT_CLASS
      T_OBJECTDATA       = GT_OBJCT
      T_AUSP             = GT_AUSP
      T_CABN             = GT_CABN
    EXCEPTIONS
      NO_CLASSIFICATION  = 1
      NO_CLASSTYPES      = 2
      INVALID_CLASS_TYPE = 3
      INTERNAL_ERROR     = 4
      OTHERS             = 5.

  READ TABLE GT_CABN  WITH KEY ATNAM = P_ATNAM.

  IF SY-SUBRC EQ 0.
    READ TABLE GT_AUSP WITH KEY ATINN = GT_CABN-ATINN.
    IF SY-SUBRC EQ 0.
      P_VALUE = GT_AUSP-ATWRT.
    ENDIF.
  ENDIF.

*  SELECT SINGLE clint FROM klah INTO lv_clint
*    WHERE klart EQ c_klart
*      AND class EQ c_class .
*
*  CALL FUNCTION '/SAPMP/CE1_CLASSIFICATION_GET'
*    EXPORTING
*      classtype          = c_klart
*      object             = p_object
*      class              = c_class
*      clint              = lv_clint
*    TABLES
*      t_class            = gt_class
*      t_objectdata       = gt_objct
*      t_ausp             = gt_ausp
*      t_cabn             = gt_cabn
*    EXCEPTIONS
*      no_classification  = 1
*      no_classtypes      = 2
*      invalid_class_type = 3
*      internal_error     = 4
*      OTHERS             = 5.
*
*  IF sy-subrc = 0.
*    READ TABLE gt_objct WITH KEY atnam = p_atnam.
*    IF sy-subrc = 0.
*      p_value = gt_objct-ausp1.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " CLASSIFICATION_FUNCTION_CALL
*&---------------------------------------------------------------------*
*&      Form  MULTI_AUFNR_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MULTI_AUFNR_PRINT.

  DATA : LV_ANSWER            TYPE C.

  PERFORM FUNCTION_FOR_CONFIRM  USING TEXT-055 "작업지시서 출력
                                      TEXT-056
                                      SPACE
                             CHANGING LV_ANSWER.

  IF LV_ANSWER <> 'J'.        " 확인버튼 클릭시
    MESSAGE S001 WITH TEXT-057."작업지시서 출력이 취소되었습니다.
    RETURN.
  ENDIF.

*& 멀티 출력시에는 미리보기 기능 없이 연속 출력만
  GS_CONTROL_PAR-NO_DIALOG = 'X'.     "출력화면 표시여부
  GS_OUTPUT_OPT-TDDEST     = 'ZP02'.  "출력장치
  GS_OUTPUT_OPT-TDIMMED    = 'X'.     "Print immdiately.
  GS_OUTPUT_OPT-TDNEWID    = 'X'.     "New spool request.
  GS_OUTPUT_OPT-TDDELETE   = 'X'.     "Delete after printing.
  GS_OUTPUT_OPT-TDNOPREV   = 'X'.     "No print preview
  GS_OUTPUT_OPT-TDNOPRINT  = ' '.     "
  GS_OUTPUT_OPT-TDFINAL    = ' '.     "스풀 요청을 완료

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  DATA : LV_AUFNR   TYPE AFKO-AUFNR.
  CLEAR : GT_PRINT, GT_PRINT[], GT_AUFNR, GT_AUFNR[].

  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
  ELSE.
    LOOP AT ROW_TABLE.
      CLEAR GT_AFKO.
      READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.

      GT_AUFNR-AUFNR = GT_AFKO-AUFNR.
      GT_AUFNR-VORNR = GT_AFKO-VORNR.

      COLLECT GT_AUFNR.

    ENDLOOP.

    CLEAR OK_CODE.

  ENDIF.

  LOOP AT GT_AUFNR.

    PERFORM PRINT_AUFNR_SMARTFORMS.
    PERFORM CALL_SMART_FORMS_MULTI.

  ENDLOOP.

  MESSAGE S004 WITH TEXT-058."작업지시서 출력이 완료되었습니다.

ENDFORM.                    " MULTI_AUFNR_PRINT
*&---------------------------------------------------------------------*
*&      Form  PRINT_AUFNR_SMARTFORMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_AUFNR_SMARTFORMS.

  REFRESH : GT_MILL, GT_MILL_TMP, GT_RESB, GT_PACK, GT_TLINES.
  CLEAR   : GS_TITLE, GT_MILL[], GT_MILL_TMP[], GT_RESB[], GT_PACK[],
GT_TLINES[],
            GT_PRINT, GT_PRINT[].

  SELECT A~AUFNR A~PLNNR A~FTRMI A~GSTRS A~GLTRS
         A~GSUZS A~GLUZS A~DISPO A~APRIO
         B~AUTYP B~OBJNR
         C~MATNR C~DAUAT C~KDAUF C~KDPOS C~PSMNG C~AMEIN
         C~CUOBJ C~POSNR C~PSAMG
         D~VORNR D~STEUS
         E~ARBPL
         F~MTART F~MATKL
         G~MAKTX B~LTEXT
    INTO CORRESPONDING FIELDS OF GT_PRINT
    FROM AFKO AS A  INNER JOIN AUFK AS B
                            ON A~AUFNR = B~AUFNR
                    INNER JOIN AFPO AS C
                            ON A~AUFNR = C~AUFNR
                    INNER JOIN AFVC AS D
                            ON A~AUFPL = D~AUFPL
                    INNER JOIN CRHD AS E
                            ON D~ARBID = E~OBJID
                    INNER JOIN MARA AS F
                            ON C~MATNR = F~MATNR
                    INNER JOIN MAKT AS G
                            ON C~MATNR = G~MATNR
   WHERE A~AUFNR  =  GT_AUFNR-AUFNR
     AND C~PWERK  =  P_PWERK
     AND D~VORNR  =  GT_AUFNR-VORNR
     AND C~XLOEK  =  SPACE
     AND D~APLFL IN ('','000000')      "순서
     AND E~OBJTY  = 'A'            "작업장
     AND G~SPRAS  =  SY-LANGU.

*& 제어키로 외주공정 여부 체크...
    IF GT_PRINT-STEUS = 'PP02' OR
       GT_PRINT-STEUS = 'PP06'.
      GT_PRINT-EXFLG = 'Y'.
    ELSE.
      GT_PRINT-EXFLG = 'N'.
    ENDIF.

*& 공정코드 = 자재그룹의 5-7자리의 문자를 사용...
    MOVE GT_PRINT-MATKL+4(3)     TO GT_PRINT-PROCD.

    GT_PRINT-PNMNG = GT_PRINT-PSMNG - GT_PRINT-PSAMG.

    APPEND GT_PRINT.     CLEAR GT_PRINT.
  ENDSELECT.

  DATA: LV_TABIX     LIKE SY-TABIX.

  REFRESH: GT_MILL, GT_PACK.
  CLEAR  : GT_MILL, GT_PACK, GV_BUKRS.

*& 플랜트로 회사코드 조회
  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_WERKS = P_PWERK
    IMPORTING
      E_BUKRS = GV_BUKRS.

  LOOP AT GT_PRINT.
    LV_TABIX = SY-TABIX.

*& 납품처,명을 가져 온다...
    PERFORM GET_VBPA_KUNNR_PRINT.

*& 공정명을 가져온다.
    PERFORM GET_ZEDT0011.
*
*& 설비명을 가져온다.
    PERFORM GET_M_CRAMN.

*& 작업지시 조장내역...
    PERFORM GET_CHARACTERISTIC_PRINT.
*
*& 설계번호를 가져옴...
    PERFORM GET_SUL_NO.
*
*& 작업표준 번호를 가져옴...
    PERFORM GET_WKSNR_PROC.
*
    IF P_PWERK = '1301' AND
       GT_PRINT-DISPO = 'LNH'  AND
       GT_PRINT-PROCD = 'PTS'.

      SELECT SINGLE A~ARBPL
                   B~KTEXT
              INTO (GT_PRINT-ARBPL_C, GT_PRINT-KTEXT_C)
              FROM ZPPT0020 AS A INNER JOIN ZPPT0119 AS B
                                         ON A~WERKS = B~WERKS AND
                                            A~SPGCD = B~SPGCD AND
                                            A~ARBPL = B~ARBPL
             WHERE A~WERKS = P_PWERK
               AND A~SPGCD = GT_PRINT-DISPO+0(2)
               AND A~AUFNR = GT_PRINT-AUFNR
               AND A~VORNR = GT_PRINT-VORNR
               AND B~PROCD = GT_PRINT-PROCD.

    ENDIF.


*& 자재 투입 소요량...
    PERFORM SELECT_RESB_PROC.
*
    IF LV_TABIX = 1.
*& 쉬스마킹 정보...
      PERFORM GET_MARKING_INFO.
    ENDIF.

*& 포장정보...
    IF NOT GT_AFKO-KDAUF IS INITIAL AND
         ( GT_AFKO-DISPO = 'LNH' OR
           GT_AFKO-DISPO = 'LNF' ).

      PERFORM GET_PACKING_INFO.
    ENDIF.

    MODIFY GT_PRINT.
  ENDLOOP.


  PERFORM PRINT_TITLE.
  PERFORM PRINT_GT_MILL.                   "작업지시 조장내역
  PERFORM PRINT_GT_RESB.                   "자재 투입 소요량
  PERFORM PRINT_PACK.                      "포장정보


* 2014.07.22 CSR:기능개선_36616 광케이블 자재 주의사항 출력
  IF P_PWERK = '1401' AND
     ( GT_AFKO-PROCD = 'LTB' OR GT_AFKO-PROCD = 'RTB' ).
    PERFORM PRINT_MATNR_CAUTION.
  ELSE.
    IF GT_PRINT-LTEXT IS NOT INITIAL.
      PERFORM PRINT_BIGO.
    ENDIF.
  ENDIF.

ENDFORM.                    " PRINT_AUFNR_SMARTFORMS
*&---------------------------------------------------------------------*
*&      Form  PRINT_TITLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_TITLE .
  DATA : LV_TXT1  TYPE CHAR30,
         LV_TXT2  TYPE CHAR30,
         LV_MATNR TYPE MARA-MATNR.

  CLEAR : T001W, ZEDT0011, LV_TXT1, LV_TXT2, LV_MATNR, M_CRAMN.

  SELECT SINGLE NAME1 INTO T001W-NAME1
           FROM T001W
          WHERE WERKS = P_PWERK.

  SELECT SINGLE GONG_NM INTO ZEDT0011-GONG_NM
         FROM ZEDT0011
        WHERE GONG_CD = GT_PRINT-PROCD.

  GS_TITLE-WERKS2 = P_PWERK.
*& 플랜트
  CONCATENATE P_PWERK '(' T001W-NAME1 ')' INTO GS_TITLE-WERKS.

  CONCATENATE SY-DATUM+0(4) '/' SY-DATUM+4(2) '/' SY-DATUM+6(2)
              INTO LV_TXT1.

  CONCATENATE SY-UZEIT+0(2) ':' SY-UZEIT+2(2) ':' SY-UZEIT+4(2)
              INTO LV_TXT2.

*& 발행일자
  CONCATENATE LV_TXT1 LV_TXT2 INTO GS_TITLE-PRDAT SEPARATED BY SPACE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GT_PRINT-MATNR
    IMPORTING
      OUTPUT = LV_MATNR.

  GS_TITLE-MATNR2 = LV_MATNR.

*& 자재코드+자재명
  CONCATENATE LV_MATNR '(' GT_PRINT-MAKTX ')' INTO GS_TITLE-MATNR.

*& 공정코드
  CONCATENATE GT_PRINT-PROCD '(' ZEDT0011-GONG_NM ')' INTO
GS_TITLE-PROCD.

  SELECT SINGLE KTEXT INTO M_CRAMN-KTEXT
         FROM M_CRAMN
        WHERE WERKS = P_PWERK
          AND ARBPL = GT_PRINT-ARBPL.

*& 설비
  IF SY-SUBRC = 0.
    CONCATENATE GT_PRINT-ARBPL
               '('
                M_CRAMN-KTEXT
               ')'                   INTO GS_TITLE-WRKCN.
  ELSE.
    CONCATENATE GT_PRINT-ARBPL
               ' '                   INTO GS_TITLE-WRKCN.
  ENDIF.

  IF NOT GT_PRINT-ARBPL_C IS INITIAL.
    CONCATENATE LV_TXT2
               '☞'
                GT_PRINT-ARBPL_C
               '('
                GT_PRINT-KTEXT_C
               ')'                   INTO GS_TITLE-WRKCN.
  ENDIF.

  CLEAR  ZPPT0000.
  SELECT SINGLE VALUE INTO ZPPT0000-VALUE
                      FROM ZPPT0000
                     WHERE SECTIONID = 'FIXED_VALUES'
                       AND KEYID     = 'APRIO'
                       AND SUBKEY    =  GT_PRINT-APRIO.

*& 작업지시일
  CONCATENATE GT_PRINT-FTRMI+0(4) '/' GT_PRINT-FTRMI+4(2) '/'
              GT_PRINT-FTRMI+6(2) INTO GS_TITLE-FTRMI.
*& 작업시작일
  CONCATENATE GT_PRINT-GSTRS+0(4) '/' GT_PRINT-GSTRS+4(2) '/'
              GT_PRINT-GSTRS+6(2) INTO GS_TITLE-GSTRS.
*& 작업종료일
  CONCATENATE GT_PRINT-GLTRS+0(4) '/' GT_PRINT-GLTRS+4(2) '/'
              GT_PRINT-GLTRS+6(2) INTO GS_TITLE-GLTRS.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GT_PRINT-AUFNR
    IMPORTING
      OUTPUT = GS_TITLE-AUFNR.

  MOVE : GT_PRINT-DISPO+0(2) TO GS_TITLE-DISPO,              "SPG
         GT_PRINT-VORNR      TO GS_TITLE-VORNR,              "소공정번호
         GT_PRINT-SUL_NO     TO GS_TITLE-SUL_NO,             "설계번호
         GT_PRINT-WKSNR_T    TO GS_TITLE-WKSNR_T,
"작업표준번호
         ZPPT0000-VALUE     TO GS_TITLE-VALUE,
"생산오더유형
         GT_PRINT-SPEC_NO    TO GS_TITLE-SPEC_NO,            "스펙명
         GT_PRINT-COLOR      TO GS_TITLE-COLOR.              "색상


  IF GT_PRINT-KDAUF IS INITIAL   AND
     ( P_PWERK  EQ '1401' OR P_PWERK EQ '1301' ) AND
     GT_PRINT-DISPO+0(2) EQ 'OC' AND
     GS_TITLE-NAME1 IS INITIAL.

    SELECT  SINGLE C~NAME1
            INTO CORRESPONDING FIELDS OF GS_TITLE
            FROM ZPPT0136 AS A INNER JOIN VBAK AS B
                                       ON B~VBELN = A~ORDNO
                               INNER JOIN KNA1 AS C
                                       ON B~KUNNR = C~KUNNR
           WHERE A~AUFNR = GT_PRINT-AUFNR.

  ENDIF.

*& 2011.06.29 CSR : C20110622_09947
*& 광케이블 LTB공정의 튜브 내경 및 완제품 구분
  IF GT_PRINT-DISPO+0(2) EQ 'OC' AND GT_PRINT-PROCD EQ 'LTB'.

    PERFORM GET_LTB_CHARACTERISTIC.
    GS_TITLE-INDIA = GT_PRINT-INDIA.
    GS_TITLE-M_TYPE = GT_PRINT-M_TYPE.
  ENDIF.

*& 2012.11.13 CSR:C20121113_16537
  IF GT_PRINT-DISPO+0(2) EQ 'OC' AND
       ( GT_PRINT-PROCD EQ 'LTB' OR GT_PRINT-PROCD EQ 'SZS' ).
    PERFORM SELECT_LOSS_SPEC.   "광섬유 손실규격치
    GS_TITLE-LOSSQ = GT_PRINT-LOSSQ.
  ENDIF.

*-{ 기능개선_51802 광케이블 FCO/LTB공정일때 완제품 광섬유투입기준 조회
  IF GT_PRINT-DISPO+0(2) = 'OC' AND
     ( GT_PRINT-PROCD EQ 'LTB' OR GT_PRINT-PROCD EQ 'FCO' ).
    PERFORM GET_FIBER_SPEC.
  ENDIF.

ENDFORM.                    " PRINT_TITLE
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SUL_NO.

  SELECT SINGLE MTART
    INTO GT_AFKO-MTART
    FROM MARA
   WHERE MATNR = GT_PRINT-MATNR.

  CASE GT_AFKO-MTART.
    WHEN 'MCFE' OR 'FERT'.  "완제품인 경우
      PERFORM GET_SUL_NO_FERT.
    WHEN 'MCHF' OR 'HALB' OR 'ZCSH'.  "반제품인 경우
      PERFORM GET_SUL_NO_HALB.
    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " GET_SUL_NO
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_NO_FERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SUL_NO_FERT .
  DATA: LT_ATWRT   LIKE ZPPS009 OCCURS 50 WITH HEADER LINE,
        LV_SUL_NO  TYPE ATWRT,
        LV_REV_SEQ TYPE ATWRT.

  REFRESH LT_ATWRT.  CLEAR LT_ATWRT.
*& 자재에대한 특성값을 가져옴...
  CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
    EXPORTING
      IF_KLART          = '001'
      IF_MATNR          = GT_PRINT-MATNR
    TABLES
      IT_ATWRT          = LT_ATWRT
    EXCEPTIONS
      NO_CLASSIFICATION = 1
      INVALID_KLART     = 2.

*& CSR : C2007051701000000253
*& LS/JS 전선 완제품 특성의 설계번호,개정번호 분기 로직
*& 회사코드 1000이면  PD_CA_DESIGN_NO/PD_CA_DESIGN_REV_NO
*& 회사코드 2000이면  PD_JS_DESIGN_NO,PD_JS_DESIGN_REV_NO


  LOOP AT LT_ATWRT.
    IF GV_BUKRS = '1000'.

      IF P_PWERK = '1201'.           "안양권선
        CASE LT_ATWRT-ATNAM.
          WHEN 'PD_CA_DESIGN_NO_AY'.           "설계번호
            LV_SUL_NO = LT_ATWRT-ATWRT.
          WHEN 'PD_CA_DESIGN_REV_NO_AY'.       "개정번호
            LV_REV_SEQ = LT_ATWRT-ATWRT.
          WHEN  OTHERS.
        ENDCASE.
      ELSEIF P_PWERK = '1304'.       "구미권선
        CASE LT_ATWRT-ATNAM.
          WHEN 'PD_CA_DESIGN_NO_KM'.           "설계번호
            LV_SUL_NO = LT_ATWRT-ATWRT.
          WHEN 'PD_CA_DESIGN_REV_NO_KM'.       "개정번호
            LV_REV_SEQ = LT_ATWRT-ATWRT.
          WHEN  OTHERS.
        ENDCASE.
      ELSE.
        CASE LT_ATWRT-ATNAM.
          WHEN 'PD_CA_DESIGN_NO'.           "설계번호
            LV_SUL_NO = LT_ATWRT-ATWRT.
          WHEN 'PD_CA_DESIGN_REV_NO'.       "개정번호
            LV_REV_SEQ = LT_ATWRT-ATWRT.
          WHEN  OTHERS.
        ENDCASE.
      ENDIF.

    ELSEIF GV_BUKRS = '2000'.
      CASE LT_ATWRT-ATNAM.
        WHEN 'PD_JS_DESIGN_NO'.           "설계번호
          LV_SUL_NO = LT_ATWRT-ATWRT.
        WHEN 'PD_JS_DESIGN_REV_NO'.       "개정번호
          LV_REV_SEQ = LT_ATWRT-ATWRT.
        WHEN  OTHERS.
      ENDCASE.
    ENDIF.

  ENDLOOP.
  CONCATENATE LV_SUL_NO '-' LV_REV_SEQ INTO GT_PRINT-SUL_NO.

ENDFORM.                    " GET_SUL_NO_FERT
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_NO_HALB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SUL_NO_HALB .
  DATA : LV_SPART    LIKE  MARA-SPART,
         LV_SULNO    LIKE  ZEDT1000-SUL_NO,
         LV_REVSEQ   LIKE  ZEDT1000-REV_SEQ,
         LV_GONG_SEQ LIKE  ZEDT1050-GONG_SEQ,
         LV_ATWRT    TYPE  ATWRT.

  CLEAR : LV_SPART, LV_SULNO, LV_REVSEQ, LV_ATWRT, LV_GONG_SEQ.

  SELECT SINGLE SPART
    INTO LV_SPART
    FROM MARA
   WHERE MATNR = GT_PRINT-MATNR.

*& 2007.09.20 반제품 설계번호 조회 로직 보완
  CALL FUNCTION 'Z_ED_GET_SUL_NO'
    EXPORTING
      I_BUKRS    = GV_BUKRS
      I_WERKS    = P_PWERK
      I_SPART    = LV_SPART
      I_MATNR    = GT_PRINT-MATNR
    IMPORTING
      O_SUL_NO   = LV_SULNO
      O_REV_SEQ  = LV_REVSEQ
      O_GONG_SEQ = LV_GONG_SEQ.

  CONCATENATE LV_SULNO '-' LV_REVSEQ INTO LV_ATWRT.
  GT_PRINT-SUL_NO = LV_ATWRT.

ENDFORM.                    " GET_SUL_NO_HALB
*&---------------------------------------------------------------------*
*&      Form  GET_WKSNR_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_WKSNR_PROC .
  CLEAR  ZPPT0020.
  SELECT SINGLE WKSNR REVNO
           INTO (ZPPT0020-WKSNR, ZPPT0020-REVNO)
           FROM ZPPT0020
          WHERE WERKS = P_PWERK
            AND SPGCD = GT_PRINT-DISPO+0(2)
            AND AUFNR = GT_PRINT-AUFNR
            AND VORNR = GT_PRINT-VORNR.
  IF SY-SUBRC = 0 AND ( NOT ZPPT0020-WKSNR IS INITIAL ).
    CONCATENATE ZPPT0020-WKSNR
               '-'
                ZPPT0020-REVNO  INTO GT_PRINT-WKSNR_T.
  ELSE.
    CLEAR GT_PRINT-WKSNR_T.
  ENDIF.

ENDFORM.                    " GET_WKSNR_PROC
*&---------------------------------------------------------------------*
*&      Form  GET_SPEC_NO_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SPEC_NO_COLOR .
  DATA: LT_CONFIGURATION_IDOC LIKE API_VALUE OCCURS 50 WITH HEADER LINE,
        LT_E1CUVAL            LIKE E1CUVAL OCCURS 50 WITH HEADER LINE.

  DATA: LV_LENGTH_P(16)  TYPE P DECIMALS 3,
        LV_LENGTH_N(16)  TYPE N,
        LV_FACTOR_P(16)  TYPE P DECIMALS 3,
        LV_FACTOR_N(16)  TYPE N,
        LV_TEMP_P(16)    TYPE P DECIMALS 3,
        LV_ATNAM_COLOR   LIKE ZPPT0102-ATNAM,
        LV_ATNAM_SPEC    LIKE ZPPT0102-ATNAM,
        LV_MATNR         LIKE MARA-MATNR,
        LV_LENGTH_ST(16) TYPE N,  "기본조장
        LV_LENGTH_SD(16) TYPE N.  "판매조장

  REFRESH: LT_CONFIGURATION_IDOC, LT_E1CUVAL.
  CLEAR  : LT_CONFIGURATION_IDOC, LT_E1CUVAL.

  CLEAR  : LV_LENGTH_P, LV_LENGTH_N, LV_FACTOR_P,
           LV_FACTOR_N, LV_TEMP_P,   LV_ATNAM_COLOR,
           LV_ATNAM_SPEC,            LV_MATNR,
           LV_LENGTH_ST,             LV_LENGTH_SD.

*& SPG/공정별 특성이름 매핑...
  CLEAR ZPPT0102.
  SELECT * FROM ZPPT0102
          WHERE SPGCD = GT_PRINT-DISPO+0(2)
            AND PROCD = GT_PRINT-PROCD.
    CASE ZPPT0102-CRITER.
      WHEN 'COLOR'.
        LV_ATNAM_COLOR = ZPPT0102-ATNAM.
      WHEN 'SPEC'.
        LV_ATNAM_SPEC  = ZPPT0102-ATNAM.
      WHEN  OTHERS.
    ENDCASE.
  ENDSELECT.
*& 디폴트값 지정...
  IF LV_ATNAM_COLOR IS INITIAL.
    LV_ATNAM_COLOR = 'PD_CA_COLOR_BASE'.
  ENDIF.
  IF LV_ATNAM_SPEC  IS INITIAL.
    LV_ATNAM_SPEC  = 'PD_CA_SPEC_NO'.
  ENDIF.


  LOOP AT GT_AFKO WHERE AUFNR = GT_PRINT-AUFNR.

*& 오더에대한 특성값을 가져옴...
    CALL FUNCTION 'Z_PP_GET_CHARACTERISTIC'
      EXPORTING
        I_AUFNR              = GT_PRINT-AUFNR
        I_POSNR              = GT_AFKO-POSNR
      TABLES
        T_CONFIGURATION_IDOC = LT_CONFIGURATION_IDOC
      EXCEPTIONS
        INSTANCE_NOT_FOUND   = 1
        INVALID_DATA         = 2.

*& 작업지시 조장내역...
    MOVE : GT_AFKO-POSNR     TO GT_MILL-POSNR.   "순번
    MOVE:  GT_PRINT-AMEIN      TO GT_MILL-AMEIN,   "단위
           GT_AFKO-KDAUF      TO GT_MILL-KDAUF,   "판매오더번호
           GT_AFKO-KDPOS      TO GT_MILL-KDPOS,   "품목번호
           GT_AFKO-NAME1      TO GT_MILL-NAME1.   "납선명

    LOOP AT LT_CONFIGURATION_IDOC.
      CASE LT_CONFIGURATION_IDOC-ATNAM.
        WHEN 'SAP_MILLCA_LENGTH'.                "지시조장(기본)
          LV_LENGTH_ST = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'SAP_LENGTH_VKRME'.                "지시조장(판매)
          LV_LENGTH_SD = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN LV_ATNAM_COLOR.                     "색상
          GT_PRINT-COLOR   = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN LV_ATNAM_SPEC.                      "스펙
          GT_PRINT-SPEC_NO = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN  OTHERS.
      ENDCASE.
    ENDLOOP.

    LV_LENGTH_P = LV_LENGTH_ST.
    LV_LENGTH_P = LV_LENGTH_P / 1000.

*& 조장이 없는 경우, Net 수량으로 대체...
    IF LV_LENGTH_P IS INITIAL.
      LV_LENGTH_P = GT_PRINT-PNMNG.
    ENDIF.

    WRITE: LV_LENGTH_P TO GT_MILL-MWERT11 DECIMALS 1
                                          RIGHT-JUSTIFIED.

    IF LV_LENGTH_P > 0.
      LV_TEMP_P = GT_PRINT-PNMNG / LV_LENGTH_P.         "지시보빈수
      WRITE LV_TEMP_P TO GT_MILL-MWERT12 DECIMALS 0
                                         RIGHT-JUSTIFIED.
      LV_TEMP_P = GT_PRINT-PNMNG / LV_LENGTH_P.         "입고보빈수
      WRITE LV_TEMP_P TO GT_MILL-MWERT22 DECIMALS 0
                                         RIGHT-JUSTIFIED.

    ENDIF.

*& 여장 정보...
    CLEAR ZPPTC002.
    SELECT SINGLE * FROM ZPPTC002
                   WHERE AUFNR = GT_PRINT-AUFNR
                     AND POSNR = GT_AFKO-POSNR.
    WRITE: ZPPTC002-PSAMG TO GT_MILL-MWERT13 DECIMALS 1  "검사여장
                                             RIGHT-JUSTIFIED,
           ZPPTC002-PSMNG TO GT_MILL-MWERT14 DECIMALS 1  "시료여장
                                             RIGHT-JUSTIFIED.
*& 입고조장...
    CLEAR LV_TEMP_P.
    LV_TEMP_P = LV_LENGTH_P + ZPPTC002-PSAMG  "입고조장(11+13+14)
                            + ZPPTC002-PSMNG.

*& 입고 조장이 없는 경우, 수량으로 대체...
    IF LV_TEMP_P IS INITIAL.
      LV_TEMP_P = GT_AFKO-PSMNG.
    ENDIF.
    WRITE: LV_TEMP_P TO GT_MILL-MWERT21 DECIMALS 1
                                        RIGHT-JUSTIFIED.

*& 총수량(조장 * 보빈수)...
    CLEAR LV_TEMP_P.
    IF LV_LENGTH_P > 0.
      LV_TEMP_P = ( LV_LENGTH_P + ZPPTC002-PSAMG + ZPPTC002-PSMNG )
                * ( GT_AFKO-PNMNG / LV_LENGTH_P ).
    ENDIF.
    WRITE: LV_TEMP_P TO GT_MILL-MWERT23 DECIMALS 1
                                        RIGHT-JUSTIFIED.

*& SD문서의 특성값중 포장재를 가져온다...
    CALL FUNCTION 'Z_ED_SO_CHARACTERISTIC_GET'
      EXPORTING
        I_VBELN                      = GT_AFKO-KDAUF
        I_POSNR                      = GT_AFKO-KDPOS
      TABLES
        IT_E1CUVAL                   = LT_E1CUVAL
      EXCEPTIONS
        INSTANCE_NOT_FOUND           = 1
        INSTANCE_IS_A_CLASSIFICATION = 2
        INVALID_DATA                 = 3.

    LOOP AT LT_E1CUVAL.
      CASE LT_E1CUVAL-CHARC.
        WHEN 'SAP_MILLCA_PACKAGING'.       "포장재
          PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                           CHANGING LV_MATNR.
          CLEAR MAKT.
          SELECT SINGLE MAKTX INTO GT_MILL-PACK_T
                   FROM MAKT
                  WHERE MATNR = LV_MATNR
                    AND SPRAS = SY-LANGU.
        WHEN  OTHERS.
      ENDCASE.
    ENDLOOP.

    APPEND  GT_MILL.      CLEAR GT_MILL.

  ENDLOOP.

ENDFORM.                    " GET_SPEC_NO_COLOR
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_MATN1_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_E1CUVAL_VALUE  text
*      <--P_LV_MATNR  text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_INPUT  USING    PV_MATNR_IN
                                  CHANGING PV_MATNR_OUT.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_MATNR_IN
    IMPORTING
      OUTPUT = PV_MATNR_OUT.

ENDFORM.                    " CONVERSION_EXIT_MATN1_INPUT
*&---------------------------------------------------------------------*
*&      Form  PRINT_GT_MILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_GT_MILL .
  REFRESH : GT_MILL_TMP.
  CLEAR   : GT_MILL_TMP.

  LOOP AT GT_MILL.

    MOVE-CORRESPONDING GT_MILL TO GT_MILL_TMP.

    WRITE : GT_MILL-POSNR   TO GT_MILL_TMP-POSNR NO-ZERO RIGHT-JUSTIFIED
 ,
            GT_MILL-MWERT11 TO GT_MILL_TMP-MWERT11 RIGHT-JUSTIFIED,
            GT_MILL-MWERT12 TO GT_MILL_TMP-MWERT12 RIGHT-JUSTIFIED,
            GT_MILL-MWERT13 TO GT_MILL_TMP-MWERT13 RIGHT-JUSTIFIED,
            GT_MILL-MWERT14 TO GT_MILL_TMP-MWERT14 RIGHT-JUSTIFIED,
            GT_MILL-MWERT21 TO GT_MILL_TMP-MWERT21 RIGHT-JUSTIFIED,
            GT_MILL-MWERT22 TO GT_MILL_TMP-MWERT22 RIGHT-JUSTIFIED,
            GT_MILL-MWERT23 TO GT_MILL_TMP-MWERT23 RIGHT-JUSTIFIED,
            GT_MILL-KDPOS+2(4) TO GT_MILL_TMP-KDPOS.

    APPEND GT_MILL_TMP.

    CLEAR GT_MILL_TMP.
  ENDLOOP.

ENDFORM.                    " PRINT_GT_MILL
*&---------------------------------------------------------------------*
*&      Form  PRINT_GT_RESB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_GT_RESB .
  REFRESH GT_RESB_TMP.
  CLEAR   GT_RESB_TMP.
  LOOP AT GT_RESB.

    MOVE-CORRESPONDING GT_RESB TO GT_RESB_TMP.

* 2021.02.04 조영현 PJT START 케이블반제품 자릿수 증가(7→9)
    IF GT_RESB-MATNR+9(1) <> '0'.
      WRITE: GT_RESB-MATNR+9(9)  TO GT_RESB_TMP-MATNR,
             GT_RESB-SORTF       TO GT_RESB_TMP-SORTF LEFT-JUSTIFIED,
             GT_RESB-BDMNG       TO GT_RESB_TMP-BDMNG LEFT-JUSTIFIED,
             GT_RESB-BINQT       TO GT_RESB_TMP-BINQT RIGHT-JUSTIFIED.
    ELSE.
      WRITE: GT_RESB-MATNR+11(7)  TO GT_RESB_TMP-MATNR,
             GT_RESB-SORTF        TO GT_RESB_TMP-SORTF LEFT-JUSTIFIED,
             GT_RESB-BDMNG        TO GT_RESB_TMP-BDMNG LEFT-JUSTIFIED,
             GT_RESB-BINQT        TO GT_RESB_TMP-BINQT RIGHT-JUSTIFIED.
    ENDIF.
* 수정전
*    WRITE : gt_resb-matnr+11(7)   TO gt_resb_tmp-matnr,
*            gt_resb-sortf         TO gt_resb_tmp-sortf LEFT-JUSTIFIED,
*            gt_resb-bdmng         TO gt_resb_tmp-bdmng LEFT-JUSTIFIED,
*          gt_resb-binqt         TO gt_resb_tmp-binqt   RIGHT-JUSTIFIED.
* 2021.02.04 조영현 PJT END   케이블반제품 자릿수 증가(7→9)

    APPEND GT_RESB_TMP.

    CLEAR GT_RESB_TMP.
  ENDLOOP.

ENDFORM.                    " PRINT_GT_RESB
*&---------------------------------------------------------------------*
*&      Form  PRINT_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PACK .
  REFRESH GT_PACK_TMP.
  CLEAR   GT_PACK_TMP.
  LOOP AT GT_PACK.

    MOVE-CORRESPONDING GT_PACK TO GT_PACK_TMP.

    WRITE : GT_PACK-POSNR         TO GT_PACK_TMP-POSNR LEFT-JUSTIFIED,
            GT_PACK-CAT           TO GT_PACK_TMP-CAT1  LEFT-JUSTIFIED.

    APPEND GT_PACK_TMP.

    CLEAR GT_PACK_TMP.
  ENDLOOP.

ENDFORM.                    " PRINT_PACK
*&---------------------------------------------------------------------*
*&      Form  CALL_SMART_FORMS_MULTI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SMART_FORMS_MULTI .
  DATA: L_EXIST,
        LFM_NAME   TYPE RS38L_FNAM,    " CALL할 SMARTFORM
        L_SSFC     TYPE SSFCTRLOP,
        L_TDSFNAME TYPE TDSFNAME.

*  l_ssfc-preview   = 'X'.   "gc_true.
*  l_ssfc-no_dialog = 'X'.   "gc_true.

*[CHM2402-00072]-광케이블 LTB 비고 출력 위치 조정
  CLEAR L_TDSFNAME.
  IF P_PWERK EQ '1401' AND
    GT_AFKO-PROCD EQ 'LTB'.
    L_TDSFNAME = 'Z_PP_WORK_ORDER_LTB'.
  ELSE.
    L_TDSFNAME = 'Z_PP_WORK_ORDER'.
  ENDIF.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
*     formname           = 'Z_PP_WORK_ORDER'
      FORMNAME           = L_TDSFNAME
    IMPORTING
      FM_NAME            = LFM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2.
*[CHM2402-00072]-2024.02.26 By 오바다

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  CALL FUNCTION LFM_NAME
    EXPORTING
      IS_ZPPS301         = GS_TITLE     "작업지시서 타이틀
      IS_ZPPS304         = GS_MARK      "마킹정보
      CONTROL_PARAMETERS = GS_CONTROL_PAR
    TABLES
      IT_MILL            = GT_MILL_TMP  "작업지시 조장내역
      IT_RESB            = GT_RESB_TMP  "자재투입 소요
      IT_PACK            = GT_PACK_TMP  "포장정보
      IT_BIGO            = GT_TLINES  "비고
    EXCEPTIONS
      FORMATTING_ERROR   = 1
      INTERNAL_ERROR     = 2
      SEND_ERROR         = 3
      USER_CANCELED      = 4
      OTHERS             = 5.

ENDFORM.                    " CALL_SMART_FORMS_MULTI
*&---------------------------------------------------------------------*
*&      Form  SELECT_RESB_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_RESB_PROC .

  DATA: LV_TAGNR LIKE ZPPT0001-TAGNR,
        LV_DBCNT LIKE SY-DBCNT.

  REFRESH: GT_RESB.    CLEAR: GT_RESB.
  SELECT MATNR CHARG BDMNG MEINS LGORT SORTF
         COUNT( * ) AS BINQT
    INTO CORRESPONDING FIELDS OF TABLE GT_RESB
    FROM RESB
   WHERE WERKS = P_PWERK
     AND AUFNR = GT_PRINT-AUFNR
     AND VORNR = GT_PRINT-VORNR
     AND SHKZG = 'H'
     AND XLOEK = SPACE
     AND BAUGR = GT_PRINT-MATNR
  GROUP BY MATNR CHARG BDMNG MEINS LGORT SORTF POSNR.

  SORT GT_RESB BY MATNR CHARG BDMNG MEINS LGORT SORTF.


  LOOP AT GT_RESB.
*& Material Description...
    CLEAR MAKT.
    SELECT SINGLE MAKTX INTO GT_RESB-MAKTX
             FROM MAKT
            WHERE MATNR = GT_RESB-MATNR
              AND SPRAS = SY-LANGU.

*& 배치번호에 해당하는 꼬리표번호가 1개인 경우에만 꼬리표번호를 가져옴..
    IF NOT GT_RESB-CHARG IS INITIAL.
      CLEAR: LV_TAGNR, LV_DBCNT.
      SELECT TAGNR COUNT( * ) INTO (LV_TAGNR, LV_DBCNT)
                              FROM ZPPT0001
                             WHERE WERKS = P_PWERK
                               AND MATNR = GT_RESB-MATNR
                               AND CHARG = GT_RESB-CHARG
                             GROUP BY TAGNR
                             ORDER BY TAGNR.
      ENDSELECT.
      IF LV_DBCNT = 1.
        GT_RESB-TAGNR = LV_TAGNR.
      ENDIF.
    ENDIF.
    MODIFY GT_RESB.
  ENDLOOP.

ENDFORM.                    " SELECT_RESB_PROC
*&---------------------------------------------------------------------*
*&      Form  GET_MARKING_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MARKING_INFO .
  DATA: BEGIN OF LT_ZPPT0129 OCCURS 0,
          ATT_CLS    LIKE ZPPT0129-ATT_CLS,
          ATTRIBUTE  LIKE ZPPT0129-ATTRIBUTE,
          MSEHI_TEXT LIKE ZPPT0129-MSEHI_TEXT,
          HELP_TYPE  LIKE ZPPT0129-HELP_TYPE,
          HELP_NAME  LIKE ZPPT0129-HELP_NAME,
          DATA_CHAR  LIKE ZEDT1030-DATA_CHAR,
          DATA_NUM   LIKE ZEDT1030-DATA_NUM,
        END   OF LT_ZPPT0129.

  DATA: LV_SUL_NO       LIKE ZEDT1010-SUL_NO,
        LV_REV_SEQ      LIKE ZEDT1010-REV_SEQ,
        LV_DATA_NUM(20).

  CLEAR: GV_MARK, LV_SUL_NO, LV_REV_SEQ.
  SPLIT GT_AFKO-SUL_NO AT '-' INTO LV_SUL_NO LV_REV_SEQ.

*& 제품에따른 마킹정보를 설계에서 가져온다...
  REFRESH LT_ZPPT0129.           CLEAR LT_ZPPT0129.
  SELECT A~ATT_CLS A~ATTRIBUTE A~MSEHI_TEXT
         A~HELP_TYPE A~HELP_NAME
         D~DATA_CHAR D~DATA_NUM
    INTO CORRESPONDING FIELDS OF TABLE LT_ZPPT0129
    FROM ZPPT0129 AS A INNER JOIN ZEDT1010 AS B
                               ON A~GONG_CD   = B~GONG_CD
                       INNER JOIN ZEDT1020 AS C
                               ON B~SUL_NO    = C~SUL_NO    AND
                                  B~REV_SEQ   = C~REV_SEQ   AND
                                  B~GONG_SEQ  = C~GONG_SEQ  AND
                                  A~JACK_CD   = C~JACK_CD
                       INNER JOIN ZEDT1030 AS D
                               ON C~SUL_NO    = D~SUL_NO    AND
                                  C~REV_SEQ   = D~REV_SEQ   AND
                                  C~GONG_SEQ  = D~GONG_SEQ  AND
                                  C~JACK_SEQ  = D~JACK_SEQ  AND
                                  A~ATTRIBUTE = D~ATTRIBUTE
    WHERE A~SPGCD   = GT_PRINT-DISPO+0(2)
      AND A~GONG_CD = GT_PRINT-PROCD
      AND B~SUL_NO  = LV_SUL_NO
      AND B~REV_SEQ = LV_REV_SEQ.

  CLEAR GS_MARK.
  LOOP AT LT_ZPPT0129.
    CASE LT_ZPPT0129-ATT_CLS.
      WHEN '1'.
        IF LT_ZPPT0129-HELP_TYPE = 'D'.
          SELECT SINGLE DDTEXT INTO GS_MARK-TYPE
                   FROM DD07V
                  WHERE DOMNAME = LT_ZPPT0129-HELP_NAME
                    AND DDLANGUAGE = SY-LANGU
                    AND DOMVALUE_L = LT_ZPPT0129-DATA_CHAR.
        ELSE.
          GS_MARK-TYPE = LT_ZPPT0129-DATA_CHAR.
        ENDIF.

      WHEN '2'.
        WRITE: LT_ZPPT0129-DATA_NUM          TO LV_DATA_NUM
                                             LEFT-JUSTIFIED.
        CONCATENATE LV_DATA_NUM
                    LT_ZPPT0129-MSEHI_TEXT INTO GS_MARK-HEIGHT.

      WHEN '3'.
        WRITE: LT_ZPPT0129-DATA_NUM          TO LV_DATA_NUM
                                             LEFT-JUSTIFIED.
        CONCATENATE LV_DATA_NUM
                    LT_ZPPT0129-MSEHI_TEXT INTO GS_MARK-WIDTH.

      WHEN '4'.
        WRITE: LT_ZPPT0129-DATA_NUM          TO LV_DATA_NUM
                                             LEFT-JUSTIFIED.
        CONCATENATE LV_DATA_NUM
                    LT_ZPPT0129-MSEHI_TEXT INTO GS_MARK-PITCH.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

*& 고객에따른 마킹정보를 판매오더 특성에서 가져온다...
  IF GT_PRINT-KDAUF IS INITIAL.
    PERFORM GET_CHARACTERISTIC_PP.
  ELSE.
    PERFORM GET_CHARACTERISTIC_SD.
  ENDIF.


ENDFORM.                    " GET_MARKING_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_CHARACTERISTIC_PP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC_PP .
  DATA: LT_CONFIGURATION_IDOC LIKE API_VALUE OCCURS 50 WITH HEADER LINE.

  CALL FUNCTION 'Z_PP_GET_CHARACTERISTIC'
    EXPORTING
      I_AUFNR              = GT_PRINT-AUFNR
      I_POSNR              = GT_PRINT-POSNR
    TABLES
      T_CONFIGURATION_IDOC = LT_CONFIGURATION_IDOC
    EXCEPTIONS
      INSTANCE_NOT_FOUND   = 1
      INVALID_DATA         = 2.

  LOOP AT LT_CONFIGURATION_IDOC.
    CASE LT_CONFIGURATION_IDOC-ATNAM.
      WHEN 'PD_CA_MARK_LENGTH'.          "길이표시여부
        GS_MARK-CA_LEN = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_LEN_CONTINUITY'.  "조장마킹연속성
        GS_MARK-CA_LEN_CON = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_LEN_INTERVAL'.    "길이표시간격
        PERFORM CHAR_FLTP_CONVERSION USING LT_CONFIGURATION_IDOC-ATWRT
                                  CHANGING GS_MARK-CA_LEN_INT.

      WHEN 'PD_CA_MARK_LEN_UNIT'.        "조장단위
        GS_MARK-CA_LEN_UNIT = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_CONTENTS_5TH'.    "마킹내용(5)
        GS_MARK-CA_CON5 = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_CONTENTS_6TH'.    "마킹내용(6)
        GS_MARK-CA_CON6 = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_CONTENTS_7TH'.    "마킹내용(7)
        GS_MARK-CA_CON7 = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'PD_CA_MARK_CONTENTS_8TH'.    "마킹내용(8)
        GS_MARK-CA_CON8 = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN  OTHERS.

    ENDCASE.
  ENDLOOP.

  IF GV_BUKRS = '1000'.                      "LS전선이면

    LOOP AT LT_CONFIGURATION_IDOC.
      CASE LT_CONFIGURATION_IDOC-ATNAM.
        WHEN 'PD_CA_MARK_CONTENTS_1ST'.    "마킹내용(1)
          GS_MARK-CA_CON1 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_CA_MARK_CONTENTS_2ND'.    "마킹내용(2)
          GS_MARK-CA_CON2 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_CA_MARK_CONTENTS_3RD'.    "마킹내용(3)
          GS_MARK-CA_CON3 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_CA_MARK_CONTENTS_4TH'.    "마킹내용(4)
          GS_MARK-CA_CON4 = LT_CONFIGURATION_IDOC-ATWRT.
      ENDCASE.
    ENDLOOP.

  ELSEIF GV_BUKRS = '2000'.                  "JS전선이면
    LOOP AT LT_CONFIGURATION_IDOC.
      CASE LT_CONFIGURATION_IDOC-ATNAM.
        WHEN 'PD_JS_MARK_CONTENTS_1ST'.    "마킹내용(1)
          GS_MARK-CA_CON1 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_JS_MARK_CONTENTS_2ND'.    "마킹내용(2)
          GS_MARK-CA_CON2 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_JS_MARK_CONTENTS_3RD'.    "마킹내용(3)
          GS_MARK-CA_CON3 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_JS_MARK_CONTENTS_4TH'.    "마킹내용(4)
          GS_MARK-CA_CON4 = LT_CONFIGURATION_IDOC-ATWRT.

        WHEN 'PD_JS_MARK_CONTENTS_5TH'.    "마킹내용(4)
          GS_MARK-CA_CON5 = LT_CONFIGURATION_IDOC-ATWRT.

      ENDCASE.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_CHARACTERISTIC_PP
*&---------------------------------------------------------------------*
*&      Form  GET_CHARACTERISTIC_SD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC_SD .
  DATA: LT_E1CUVAL      LIKE E1CUVAL OCCURS 50 WITH HEADER LINE.
  DATA: LV_VALUE_0(16) TYPE P DECIMALS 0,
        LV_VALUE_3(16) TYPE P DECIMALS 3.


  CALL FUNCTION 'Z_ED_SO_CHARACTERISTIC_GET'
    EXPORTING
      I_VBELN                      = GT_PRINT-KDAUF
      I_POSNR                      = GT_PRINT-KDPOS
    TABLES
      IT_E1CUVAL                   = LT_E1CUVAL
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INSTANCE_IS_A_CLASSIFICATION = 2
      INVALID_DATA                 = 3.

  LOOP AT LT_E1CUVAL.
    CASE LT_E1CUVAL-CHARC.
      WHEN 'PD_CA_MARK_LENGTH'.          "길이표시여부
        GS_MARK-CA_LEN = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_LEN_CONTINUITY'.  "조장마킹연속성
        GS_MARK-CA_LEN_CON = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_LEN_INTERVAL'.    "길이표시간격
        PERFORM CHAR_FLTP_CONVERSION USING LT_E1CUVAL-VALUE
                                  CHANGING GS_MARK-CA_LEN_INT.

      WHEN 'PD_CA_MARK_LEN_UNIT'.        "조장단위
        GS_MARK-CA_LEN_UNIT = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_CONTENTS_5TH'.    "마킹내용(5)
        GS_MARK-CA_CON5 = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_CONTENTS_6TH'.    "마킹내용(6)
        GS_MARK-CA_CON6 = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_CONTENTS_7TH'.    "마킹내용(7)
        GS_MARK-CA_CON7 = LT_E1CUVAL-VALUE.

      WHEN 'PD_CA_MARK_CONTENTS_8TH'.    "마킹내용(8)
        GS_MARK-CA_CON8 = LT_E1CUVAL-VALUE.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

  IF GV_BUKRS = '1000'.                  "LS전선이면
    LOOP AT LT_E1CUVAL.
      CASE LT_E1CUVAL-CHARC.
        WHEN 'PD_CA_MARK_CONTENTS_1ST'.    "마킹내용(1)
          GS_MARK-CA_CON1 = LT_E1CUVAL-VALUE.

        WHEN 'PD_CA_MARK_CONTENTS_2ND'.    "마킹내용(2)
          GS_MARK-CA_CON2 = LT_E1CUVAL-VALUE.

        WHEN 'PD_CA_MARK_CONTENTS_3RD'.    "마킹내용(3)
          GS_MARK-CA_CON3 = LT_E1CUVAL-VALUE.

        WHEN 'PD_CA_MARK_CONTENTS_4TH'.    "마킹내용(4)
          GS_MARK-CA_CON4 = LT_E1CUVAL-VALUE.
      ENDCASE.
    ENDLOOP.

  ELSEIF GV_BUKRS = '2000'.              "JS전선이면
    LOOP AT LT_E1CUVAL.
      CASE LT_E1CUVAL-CHARC.
        WHEN 'PD_JS_MARK_CONTENTS_1ST'.    "마킹내용(1)
          GS_MARK-CA_CON1 = LT_E1CUVAL-VALUE.

        WHEN 'PD_JS_MARK_CONTENTS_2ND'.    "마킹내용(2)
          GS_MARK-CA_CON2 = LT_E1CUVAL-VALUE.

        WHEN 'PD_JS_MARK_CONTENTS_3RD'.    "마킹내용(3)
          GS_MARK-CA_CON3 = LT_E1CUVAL-VALUE.

        WHEN 'PD_JS_MARK_CONTENTS_4TH'.    "마킹내용(4)
          GS_MARK-CA_CON4 = LT_E1CUVAL-VALUE.

        WHEN 'PD_JS_MARK_CONTENTS_5TH'.    "마킹내용(4)
          GS_MARK-CA_CON5 = LT_E1CUVAL-VALUE.
      ENDCASE.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " GET_CHARACTERISTIC_SD
*&---------------------------------------------------------------------*
*&      Form  CHAR_FLTP_CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CONFIGURATION_IDOC_ATWRT  text
*      <--P_GS_MARK_CA_LEN_INT  text
*----------------------------------------------------------------------*
FORM CHAR_FLTP_CONVERSION  USING    PV_VALUE_S
                           CHANGING PV_VALUE_C.

  DATA: LV_FLTP     LIKE RSCVP-VALU1,
        LV_PACK(16) TYPE P DECIMALS 3.

  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      STRING          = PV_VALUE_S
    IMPORTING
      FLSTR           = LV_FLTP
*&      ivalu           = x_ival
    EXCEPTIONS
      STRING_NOT_FLTP = 1.

  LV_PACK = LV_FLTP.
  WRITE LV_PACK      TO PV_VALUE_C LEFT-JUSTIFIED.
ENDFORM.                    " CHAR_FLTP_CONVERSION
*&---------------------------------------------------------------------*
*&      Form  GET_PACKING_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PACKING_INFO .
  DATA: LT_E1CUVAL      LIKE E1CUVAL OCCURS 50 WITH HEADER LINE.
  DATA: LV_VALUE_0(16) TYPE P DECIMALS 0,
        LV_VALUE_3(16) TYPE P DECIMALS 3,
        LV_MATNR       LIKE MARA-MATNR.

  CALL FUNCTION 'Z_ED_SO_CHARACTERISTIC_GET'
    EXPORTING
      I_VBELN                      = GT_PRINT-KDAUF
      I_POSNR                      = GT_PRINT-KDPOS
    TABLES
      IT_E1CUVAL                   = LT_E1CUVAL
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INSTANCE_IS_A_CLASSIFICATION = 2
      INVALID_DATA                 = 3.

  LOOP AT LT_E1CUVAL.
    CASE LT_E1CUVAL-CHARC.
      WHEN 'SAP_MILLCA_PACKAGING_CAT'.   "포장재 유형
        GT_PACK-CAT = LT_E1CUVAL-VALUE.

      WHEN 'SAP_MILLCA_PACKAGING'.       "포장재코드
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                         CHANGING LV_MATNR.

        PERFORM GET_MATERIAL_DESC           USING LV_MATNR
                                         CHANGING GT_PACK-MAT.

      WHEN 'PD_CA_PACKING_DM'.           "포장재(드럼)
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                         CHANGING LV_MATNR.

        PERFORM GET_MATERIAL_DESC           USING LV_MATNR
                                         CHANGING GT_PACK-DM.

      WHEN 'PD_CA_PACKING_BX'.           "포장재(BOX)
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                         CHANGING LV_MATNR.

        PERFORM GET_MATERIAL_DESC           USING LV_MATNR
                                         CHANGING GT_PACK-BX.

      WHEN 'PD_CA_PACKING_PA'.           "포장재(PALLET)
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                         CHANGING LV_MATNR.

        PERFORM GET_MATERIAL_DESC           USING LV_MATNR
                                         CHANGING GT_PACK-PA.

      WHEN 'PD_LN_LABEL_DESIGN_NO_1ST'.  "LN LABEL 설계번호(1)
        GT_PACK-ED_1ST = LT_E1CUVAL-VALUE.

      WHEN  OTHERS.

    ENDCASE.
  ENDLOOP.

  GT_PACK-POSNR = GT_PRINT-POSNR.
  APPEND GT_PACK.   CLEAR GT_PACK.

ENDFORM.                    " GET_PACKING_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_MATERIAL_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_MATNR  text
*      <--P_GT_PACK_MAT  text
*----------------------------------------------------------------------*
FORM GET_MATERIAL_DESC  USING    PV_MATNR
                        CHANGING PV_MAKTX.

  CLEAR  MAKT.
  SELECT SINGLE MAKTX INTO PV_MAKTX
           FROM MAKT
          WHERE MATNR = PV_MATNR
            AND SPRAS = SY-LANGU.

ENDFORM.                    " GET_MATERIAL_DESC
*&---------------------------------------------------------------------*
*&      Form  PRINT_BIGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_BIGO .
  DATA: LTSCH   LIKE THEAD-TDNAME,
        TCO09WA LIKE TCO09.

  REFRESH  GT_TEXTEDIT_LINES.
  CLEAR:   GS_TEXTEDIT_HEADER.

* Objekt und ID der Texte auslesen
  CALL FUNCTION 'CO_TA_TCO09_READ'
    EXPORTING
      AUTYP    = GT_PRINT-AUTYP
    IMPORTING
      STRUCT   = TCO09WA
    EXCEPTIONS
      NO_ENTRY = 1.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'CO_ZK_TEXTKEY_CAUFV'
    EXPORTING
      AUFNR = GT_PRINT-AUFNR
    IMPORTING
      LTSCH = LTSCH.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = TCO09WA-IDORD
      LANGUAGE  = '3'             "한국어
      NAME      = LTSCH
      OBJECT    = TCO09WA-OBJEC
    TABLES
      LINES     = GT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

ENDFORM.                    " PRINT_BIGO
*&---------------------------------------------------------------------*
*&      Form  FUNCTION_FOR_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4649   text
*      -->P_4650   text
*      -->P_SPACE  text
*      <--P_LV_ANSWER  text
*----------------------------------------------------------------------*
FORM FUNCTION_FOR_CONFIRM  USING P_TITLE
                                 P_TEXT1
                                 P_TEXT2
                        CHANGING P_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      TITEL     = P_TITLE
      TEXTLINE1 = P_TEXT1
      TEXTLINE2 = P_TEXT2
    IMPORTING
      ANSWER    = P_ANSWER.
ENDFORM.                    " FUNCTION_FOR_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  GET_VBPA_KUNNR_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_VBPA_KUNNR_PRINT .
*& 2007.09.11
*& LS는 인도처, JS는 판매처로 분기

  IF GV_BUKRS = '1000'.

    SELECT SINGLE A~KUNNR
                  B~NAME1
             INTO CORRESPONDING FIELDS OF GT_PRINT
             FROM VBPA AS A  INNER JOIN KNA1 AS B
                                     ON A~KUNNR = B~KUNNR
            WHERE A~VBELN =  GT_PRINT-KDAUF
              AND A~PARVW = 'WE'.

  ELSEIF GV_BUKRS = '2000'.

    SELECT SINGLE A~KUNNR
                  B~NAME1
             INTO CORRESPONDING FIELDS OF GT_PRINT
             FROM VBPA AS A  INNER JOIN KNA1 AS B
                                     ON A~KUNNR = B~KUNNR
            WHERE A~VBELN =  GT_PRINT-KDAUF
              AND A~PARVW = 'AG'.

  ENDIF.
ENDFORM.                    " GET_VBPA_KUNNR_PRINT
*&---------------------------------------------------------------------*
*&      Form  GET_ZEDT0011
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZEDT0011 .
  CLEAR ZEDT0011.
  SELECT SINGLE GONG_NM INTO GT_PRINT-GONG_NM
           FROM ZEDT0011
          WHERE GONG_CD = GT_PRINT-PROCD.

ENDFORM.                    " GET_ZEDT0011
*&---------------------------------------------------------------------*
*&      Form  GET_M_CRAMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_M_CRAMN .
  CLEAR M_CRAMN.
  SELECT SINGLE KTEXT INTO GT_PRINT-KTEXT
           FROM M_CRAMN
          WHERE WERKS = P_PWERK
            AND ARBPL = GT_PRINT-ARBPL
            AND SPRAS = SY-LANGU.

ENDFORM.                    " GET_M_CRAMN
*&---------------------------------------------------------------------*
*&      Form  GET_CHARACTERISTIC_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHARACTERISTIC_PRINT .
  DATA: LT_CONFIGURATION_IDOC LIKE API_VALUE OCCURS 50 WITH HEADER LINE,
        LT_E1CUVAL            LIKE E1CUVAL OCCURS 50 WITH HEADER LINE.

  DATA: LV_LENGTH_P(16)  TYPE P DECIMALS 3,
        LV_LENGTH_N(16)  TYPE N,
        LV_FACTOR_P(16)  TYPE P DECIMALS 3,
        LV_FACTOR_N(16)  TYPE N,
        LV_TEMP_P(16)    TYPE P DECIMALS 3,
        LV_ATNAM_COLOR   LIKE ZPPT0102-ATNAM,
        LV_ATNAM_SPEC    LIKE ZPPT0102-ATNAM,
        LV_MATNR         LIKE MARA-MATNR,
        LV_LENGTH_ST(16) TYPE N,  "기본조장
        LV_LENGTH_SD(16) TYPE N.  "판매조장

  REFRESH: LT_CONFIGURATION_IDOC, LT_E1CUVAL.
  CLEAR  : LT_CONFIGURATION_IDOC, LT_E1CUVAL.

  CLEAR  : LV_LENGTH_P, LV_LENGTH_N, LV_FACTOR_P,
           LV_FACTOR_N, LV_TEMP_P,   LV_ATNAM_COLOR,
           LV_ATNAM_SPEC,            LV_MATNR,
           LV_LENGTH_ST,             LV_LENGTH_SD.

*& SPG/공정별 특성이름 매핑...
  CLEAR ZPPT0102.
  SELECT * FROM ZPPT0102
          WHERE SPGCD = GT_PRINT-DISPO+0(2)
            AND PROCD = GT_PRINT-PROCD.
    CASE ZPPT0102-CRITER.
      WHEN 'COLOR'.
        LV_ATNAM_COLOR = ZPPT0102-ATNAM.
      WHEN 'SPEC'.
        LV_ATNAM_SPEC  = ZPPT0102-ATNAM.
      WHEN  OTHERS.
    ENDCASE.
  ENDSELECT.
*& 디폴트값 지정...
  IF LV_ATNAM_COLOR IS INITIAL.
    LV_ATNAM_COLOR = 'PD_CA_COLOR_BASE'.
  ENDIF.
  IF LV_ATNAM_SPEC  IS INITIAL.
    LV_ATNAM_SPEC  = 'PD_CA_SPEC_NO'.
  ENDIF.

*& 오더에대한 특성값을 가져옴...
  CALL FUNCTION 'Z_PP_GET_CHARACTERISTIC'
    EXPORTING
      I_AUFNR              = GT_PRINT-AUFNR
      I_POSNR              = GT_PRINT-POSNR
    TABLES
      T_CONFIGURATION_IDOC = LT_CONFIGURATION_IDOC
    EXCEPTIONS
      INSTANCE_NOT_FOUND   = 1
      INVALID_DATA         = 2.

*& 작업지시 조장내역...
  MOVE : GT_PRINT-POSNR     TO GT_MILL-POSNR.   "순번
  MOVE: GT_PRINT-AMEIN      TO GT_MILL-AMEIN,   "단위
        GT_PRINT-KDAUF      TO GT_MILL-KDAUF,   "판매오더번호
        GT_PRINT-KDPOS      TO GT_MILL-KDPOS,   "품목번호
        GT_PRINT-NAME1      TO GT_MILL-NAME1.   "납선명

  LOOP AT LT_CONFIGURATION_IDOC.
    CASE LT_CONFIGURATION_IDOC-ATNAM.
      WHEN 'SAP_MILLCA_LENGTH'.                "지시조장(기본)
        LV_LENGTH_ST = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN 'SAP_LENGTH_VKRME'.                "지시조장(판매)
        LV_LENGTH_SD = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN LV_ATNAM_COLOR.                     "색상
        GT_PRINT-COLOR   = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN LV_ATNAM_SPEC.                      "스펙
        GT_PRINT-SPEC_NO = LT_CONFIGURATION_IDOC-ATWRT.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

  LV_LENGTH_P = LV_LENGTH_ST.
  LV_LENGTH_P = LV_LENGTH_P / 1000.

*& 조장이 없는 경우, Net 수량으로 대체...
  IF LV_LENGTH_P IS INITIAL.
    LV_LENGTH_P = GT_PRINT-PNMNG.
  ENDIF.

  WRITE: LV_LENGTH_P TO GT_MILL-MWERT11 DECIMALS 1
                                        RIGHT-JUSTIFIED.

  IF LV_LENGTH_P > 0.
    LV_TEMP_P = GT_PRINT-PNMNG / LV_LENGTH_P.         "지시보빈수
    WRITE LV_TEMP_P TO GT_MILL-MWERT12 DECIMALS 0
                                       RIGHT-JUSTIFIED.
    LV_TEMP_P = GT_PRINT-PNMNG / LV_LENGTH_P.         "입고보빈수
    WRITE LV_TEMP_P TO GT_MILL-MWERT22 DECIMALS 0
                                       RIGHT-JUSTIFIED.

  ENDIF.

*& 여장 정보...
  CLEAR ZPPTC002.
  SELECT SINGLE * FROM ZPPTC002
                 WHERE AUFNR = GT_PRINT-AUFNR
                   AND POSNR = GT_PRINT-POSNR.
  WRITE: ZPPTC002-PSAMG TO GT_MILL-MWERT13 DECIMALS 1  "검사여장
                                           RIGHT-JUSTIFIED,
         ZPPTC002-PSMNG TO GT_MILL-MWERT14 DECIMALS 1  "시료여장
                                           RIGHT-JUSTIFIED.
*& 입고조장...
  CLEAR LV_TEMP_P.
  LV_TEMP_P = LV_LENGTH_P + ZPPTC002-PSAMG  "입고조장(11+13+14)
                          + ZPPTC002-PSMNG.

*& 입고 조장이 없는 경우, 수량으로 대체...
  IF LV_TEMP_P IS INITIAL.
    LV_TEMP_P = GT_PRINT-PSMNG.
  ENDIF.
  WRITE: LV_TEMP_P TO GT_MILL-MWERT21 DECIMALS 1
                                      RIGHT-JUSTIFIED.

*& 총수량(조장 * 보빈수)...
  CLEAR LV_TEMP_P.
  IF LV_LENGTH_P > 0.
    LV_TEMP_P = ( LV_LENGTH_P + ZPPTC002-PSAMG + ZPPTC002-PSMNG )
              * ( GT_PRINT-PNMNG / LV_LENGTH_P ).
  ENDIF.
  WRITE: LV_TEMP_P TO GT_MILL-MWERT23 DECIMALS 1
                                      RIGHT-JUSTIFIED.

*& SD문서의 특성값중 포장재를 가져온다...
  CALL FUNCTION 'Z_ED_SO_CHARACTERISTIC_GET'
    EXPORTING
      I_VBELN                      = GT_PRINT-KDAUF
      I_POSNR                      = GT_PRINT-KDPOS
    TABLES
      IT_E1CUVAL                   = LT_E1CUVAL
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INSTANCE_IS_A_CLASSIFICATION = 2
      INVALID_DATA                 = 3.

  LOOP AT LT_E1CUVAL.
    CASE LT_E1CUVAL-CHARC.
      WHEN 'SAP_MILLCA_PACKAGING'.       "포장재
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                         CHANGING LV_MATNR.
        CLEAR MAKT.
        SELECT SINGLE MAKTX INTO GT_MILL-PACK_T
                 FROM MAKT
                WHERE MATNR = LV_MATNR
                  AND SPRAS = SY-LANGU.
      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

  APPEND  GT_MILL.      CLEAR GT_MILL.

ENDFORM.                    " GET_CHARACTERISTIC_PRINT
*&---------------------------------------------------------------------*
*&      Form  CHECK_ZPPM0030M_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ZPPM0030M_VALIDATION .
  DATA: LV_WERKS TYPE AFPO-PWERK,
        LV_AUFNR TYPE AFPO-AUFNR,
        LV_DISPO LIKE GT_AFKO-DISPO,
        LV_PROCD LIKE GT_AFKO-PROCD.

  LOOP AT GT_ZPPS040.

    CLEAR: LV_WERKS, LV_AUFNR, GV_ERRFLG.

    SELECT SINGLE D~ARBPL
      INTO CRHD-ARBPL
      FROM AFKO AS A  INNER JOIN AFVC AS C
                              ON A~AUFPL = C~AUFPL
                      INNER JOIN CRHD AS D
                              ON C~ARBID = D~OBJID
      WHERE C~WERKS  = P_PWERK
        AND A~AUFNR  = GT_ZPPS040-AUFNR
        AND C~VORNR  = GT_ZPPS040-VORNR
        AND D~ARBPL  = GT_ZPPS040-ARBPL.

    IF SY-SUBRC <> 0.
      MESSAGE S004
         WITH 'W/C [' GT_ZPPS040-ARBPL TEXT-059."]는 해당 오더에 존재하지
      "않습니다.
      GV_ERRFLG = 'X'.
      EXIT.
    ENDIF.

    IF GV_ERRFLG IS INITIAL.
      PERFORM ENQUEUE_READ_FR_AUFNR  USING 'ZPPT0001'
                                           GT_ZPPS040-AUFNR
                                           GV_ERRFLG.
    ENDIF.

  ENDLOOP.

  IF GV_ERRFLG IS INITIAL.

*& 플랜트,spg,공정코드가 다를 경우 에러 처리
    LOOP AT GT_ZPPS040.

      READ TABLE GT_AFKO WITH KEY AUFNR = GT_ZPPS040-AUFNR.

      IF ( LV_WERKS IS NOT INITIAL AND
           LV_WERKS NE GT_AFKO-WERKS ) OR
         ( LV_DISPO IS NOT INITIAL AND
           LV_DISPO NE GT_AFKO-DISPO ) OR
         ( LV_PROCD IS NOT INITIAL AND
           LV_PROCD NE GT_AFKO-PROCD ).
        MESSAGE S001
           WITH TEXT-060."플랜트,SPG,공정코드가 같은 경우에만 사용가능합니다.
        GV_ERRFLG = 'X'.
        EXIT.
      ENDIF.

      LV_WERKS = GT_AFKO-WERKS.
      LV_DISPO = GT_AFKO-DISPO.
      LV_PROCD = GT_AFKO-PROCD.
    ENDLOOP.

*& 1401,OC, FCO 의 경우 중복 설비가 있을 경우 에러 처리
    LOOP AT GT_ZPPS040 WHERE WERKS = '1401' .

      READ TABLE GT_AFKO WITH KEY AUFNR = GT_ZPPS040-AUFNR.

      IF GT_AFKO-DISPO+(2) = 'OC' AND
         GT_AFKO-PROCD = 'FCO'.

        LOOP AT GT_ZPPS040 WHERE AUFNR NE GT_AFKO-AUFNR
                             AND ARBPL EQ GT_AFKO-ARBPL.

          MESSAGE S001 WITH TEXT-061."중복 설비에 대해서는 사용할수 없습니다.
          GV_ERRFLG = 'X'.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF GV_ERRFLG = 'X'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_ZPPM0030M_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_READ_FR_AUFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8022   text
*      -->P_GT_ZPPS040_AUFNR  text
*      -->P_GV_ERRFLG  text
*----------------------------------------------------------------------*
FORM ENQUEUE_READ_FR_AUFNR  USING PV_TABNAM
                                  PV_AUFNR
                                  PV_ERRFLG.
  DATA: LV_AUFNR  TYPE AFKO-AUFNR,
        LT_SEQG3  TYPE SEQG3  OCCURS 0 WITH HEADER LINE,
        LV_LTEXT1 TYPE CHAR72,
        LV_LTEXT2 TYPE CHAR72.

  CLEAR: PV_ERRFLG, LV_AUFNR, LV_LTEXT1, LV_LTEXT2, LT_SEQG3, LT_SEQG3[]
 .

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      GNAME                 = PV_TABNAM
      GUNAME                = SPACE
    TABLES
      ENQ                   = LT_SEQG3
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      OTHERS                = 2.

  IF NOT LT_SEQG3[] IS INITIAL.
    LOOP AT LT_SEQG3.
      IF PV_TABNAM = 'ZPPT0001'.
        LV_AUFNR = LT_SEQG3-GARG+7(12).
      ELSE.
        LV_AUFNR = LT_SEQG3-GARG+3(12).
      ENDIF.

      IF LV_AUFNR = PV_AUFNR.
        IF PV_TABNAM = 'ZPPT0001'.
          PV_ERRFLG = 'X'.
          CONCATENATE TEXT-062 LT_SEQG3-GUNAME TEXT-063
                                                   INTO LV_LTEXT1.
          CONCATENATE PV_AUFNR TEXT-064 INTO LV_LTEXT2.

          MESSAGE S002 WITH LV_LTEXT1 LV_LTEXT2.
          EXIT.
        ELSE.
          PV_ERRFLG = 'X'.
          CONCATENATE TEXT-062 LT_SEQG3-GUNAME TEXT-063
                                                   INTO LV_LTEXT1.
          CONCATENATE PV_AUFNR TEXT-065 INTO LV_LTEXT2.

          MESSAGE S002 WITH LV_LTEXT1 LV_LTEXT2.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " ENQUEUE_READ_FR_AUFNR
*&---------------------------------------------------------------------*
*&      Form  GET_LTB_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LTB_CHARACTERISTIC .
  DATA: LT_ATWRT   LIKE ZPPS009 OCCURS 50 WITH HEADER LINE,
        LV_SUL_NO  TYPE ATWRT,
        LV_REV_SEQ TYPE ATWRT,
        LV_DIA     TYPE ATWRT,
        LV_MATNR_F TYPE MARA-MATNR.

  REFRESH LT_ATWRT.
  CLEAR : LT_ATWRT, LV_DIA.
*& 자재에대한 특성값을 가져옴...
  CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
    EXPORTING
      IF_KLART          = '001'
      IF_MATNR          = GT_PRINT-MATNR
    TABLES
      IT_ATWRT          = LT_ATWRT
    EXCEPTIONS
      NO_CLASSIFICATION = 1
      INVALID_KLART     = 2.

  LOOP AT LT_ATWRT.

    IF LT_ATWRT-ATNAM EQ 'PD_OC_TUBE_IN_DIA'.
      GT_PRINT-INDIA = LT_ATWRT-ATWRT.
      EXIT.
    ENDIF.
  ENDLOOP.

*& 설계번호로 완제품 자재코드를 조회하여 표준품명 2자리 조회
  IF GT_PRINT-SUL_NO IS NOT INITIAL.

    CLEAR : LV_MATNR_F.

    SELECT SINGLE NEW_MATNR
      INTO LV_MATNR_F
      FROM ZEDT1000
     WHERE SUL_NO  = GT_PRINT-SUL_NO+0(9)
       AND REV_SEQ = GT_PRINT-SUL_NO+10(2).

    IF LV_MATNR_F IS NOT INITIAL.

      REFRESH LT_ATWRT.
      CLEAR : LT_ATWRT, LV_DIA.
*& 자재에대한 특성값을 가져옴...
      CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
        EXPORTING
          IF_KLART          = '001'
          IF_MATNR          = LV_MATNR_F
        TABLES
          IT_ATWRT          = LT_ATWRT
        EXCEPTIONS
          NO_CLASSIFICATION = 1
          INVALID_KLART     = 2.

      LOOP AT LT_ATWRT.

        IF LT_ATWRT-ATNAM EQ 'PD_AA_STD_PRODUCT_NAME'.
          GT_PRINT-M_TYPE = LT_ATWRT-ATWRT+0(2).
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_LTB_CHARACTERISTIC
*&---------------------------------------------------------------------*
*&      Form  GET_BIGO_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BIGO_TEXT .
*& 비고text 삽입  (C20120128_40165)
  REFRESH: GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES.
  CLEAR  : GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES,
           GS_TEXTEDIT_HEADER.

*Objekt und ID der Texte auslesen
  CALL FUNCTION 'CO_TA_TCO09_READ'
    EXPORTING
      AUTYP    = GT_AFKO-AUTYP
    IMPORTING
      STRUCT   = LS_TCO09WA
    EXCEPTIONS
      NO_ENTRY = 1.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'CO_ZK_TEXTKEY_CAUFV'
    EXPORTING
      AUFNR = GT_AFKO-AUFNR
    IMPORTING
      LTSCH = LT_SCH.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = LS_TCO09WA-IDORD
      LANGUAGE  = '3'             "한국어
      NAME      = LT_SCH
      OBJECT    = LS_TCO09WA-OBJEC
*&    importing
*&      header    = e_theader
    TABLES
      LINES     = LT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

  IF LT_TLINES[] IS NOT INITIAL.
    READ TABLE LT_TLINES.
    GT_AFKO-LTEXT_C = LT_TLINES-TDLINE.
  ELSE.
  ENDIF.

ENDFORM.                    " GET_BIGO_TEXT
*&---------------------------------------------------------------------*
*&      Form  SELECT_LOSS_SPEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_LOSS_SPEC.
  DATA : LV_MATNR    LIKE  MARA-MATNR,
         LV_PLNNR    TYPE   PLKO-PLNNR,
         LV_PLNAL    TYPE   PLKO-PLNAL,
         LT_PAC_DATA LIKE   PAC_CLASS_DATA OCCURS 0 WITH HEADER LINE,
         LT_CHA_DATA LIKE   CHA_CLASS_DATA OCCURS 0  WITH HEADER LINE,
         LT_HDR_DATA LIKE   TSK_CLASS_DATA OCCURS 0,
         LV_VALUE    TYPE   ZQMT0052-VALUE,
         LV_SPEC1(4),
         LV_SPEC2(4),
         LV_SPEC3(4),
         LV_SPEC4(4).

  DATA : BEGIN OF LT_SPEC OCCURS 0,
           KURZTEXT   LIKE CHA_CLASS_DATA-KURZTEXT,
           TOLERANZOB LIKE CHA_CLASS_DATA-TOLERANZOB,
         END OF LT_SPEC.

  CLEAR : LV_MATNR,  LV_PLNNR, LV_PLNAL, LT_SPEC, LT_SPEC[].

*& 생산오더의 페깅된 완제품 생산오더가 있는 경우만 해당 완제품 자재의
*& 검사계획의 손실규격치를 사용
  SELECT SINGLE MATNR_F
   INTO  LV_MATNR
   FROM  ZPPT0136
  WHERE  AUFNR = GT_PRINT-AUFNR.

  IF LV_MATNR IS NOT INITIAL.

    SELECT SINGLE A~PLNNR A~PLNAL
     INTO (LV_PLNNR, LV_PLNAL)
     FROM MAPL AS A INNER JOIN PLKO AS B
                       ON A~PLNNR = B~PLNNR
                      AND A~PLNAL = B~PLNAL
                      AND A~PLNTY = B~PLNTY
    WHERE A~WERKS = P_PWERK
      AND A~MATNR = LV_MATNR
      AND A~PLNTY = 'Q'
      AND B~VERWE = '5'
      AND B~LOEKZ = SPACE.

    IF LV_PLNNR IS NOT INITIAL.
      CLEAR : LT_CHA_DATA.
      CALL FUNCTION 'RMXT412_GET_INSPECTION_PLANS'
        EXPORTING
          I_KEY_DATE_SOURCE = SY-DATUM
          I_PLNTY_SOURCE    = 'Q'
          I_PLNNR_SOURCE    = LV_PLNNR
          I_PLNAL_SOURCE    = LV_PLNAL
        TABLES
          ET_PAC_DATA       = LT_PAC_DATA
          ET_CHA_DATA       = LT_CHA_DATA
          ET_HDR_DATA       = LT_HDR_DATA.
    ENDIF.
    LOOP AT LT_CHA_DATA.
      LT_SPEC-KURZTEXT    = LT_CHA_DATA-KURZTEXT.
      LT_SPEC-TOLERANZOB  = LT_CHA_DATA-TOLERANZOB.
      APPEND LT_SPEC.
    ENDLOOP.

    LOOP AT LT_SPEC.

      IF LT_SPEC-KURZTEXT CS TEXT-066 AND
         LT_SPEC-KURZTEXT CS 'OSE'.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 6
            EXPON = 0
            INPUT = LT_SPEC-TOLERANZOB
            IVALU = 'X'
          IMPORTING
            FLSTR = LV_VALUE.
        LV_SPEC1 = LV_VALUE+3(4).    "소숫점 둘째자리 절삭
      ENDIF.

      IF LT_SPEC-KURZTEXT CS TEXT-067 AND
         LT_SPEC-KURZTEXT CS 'OSE'.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 6
            EXPON = 0
            INPUT = LT_SPEC-TOLERANZOB
            IVALU = 'X'
          IMPORTING
            FLSTR = LV_VALUE.

        LV_SPEC2 = LV_VALUE+3(4).    "소숫점 둘째자리 절삭

      ENDIF.

      IF LT_SPEC-KURZTEXT CS TEXT-068 AND
         LT_SPEC-KURZTEXT CS 'OSE'.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 6
            EXPON = 0
            INPUT = LT_SPEC-TOLERANZOB
            IVALU = 'X'
          IMPORTING
            FLSTR = LV_VALUE.

        LV_SPEC3 = LV_VALUE+3(4).    "소숫점 둘째자리 절삭

      ENDIF.

      IF LT_SPEC-KURZTEXT CS TEXT-069 AND
         LT_SPEC-KURZTEXT CS 'OSE'.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 6
            EXPON = 0
            INPUT = LT_SPEC-TOLERANZOB
            IVALU = 'X'
          IMPORTING
            FLSTR = LV_VALUE.

        LV_SPEC4 = LV_VALUE+3(4).    "소숫점 둘째자리 절삭

      ENDIF.
    ENDLOOP.

    GT_PRINT-LOSSQ+0(4) = LV_SPEC1.
    GT_PRINT-LOSSQ+4(1) = '/'.
    GT_PRINT-LOSSQ+5(4) = LV_SPEC2.
    GT_PRINT-LOSSQ+9(1) = '/'.
    GT_PRINT-LOSSQ+10(4) = LV_SPEC3.
    GT_PRINT-LOSSQ+14(1) = '/'.
    GT_PRINT-LOSSQ+15(4) = LV_SPEC4.
    GT_PRINT-LOSSQ+19(8) = '(1625nm)'.

  ELSE.
    GT_PRINT-LOSSQ+0(4) = '   '.
    GT_PRINT-LOSSQ+4(1) = '/'.
    GT_PRINT-LOSSQ+5(4) = '   '.
    GT_PRINT-LOSSQ+9(1) = '/'.
    GT_PRINT-LOSSQ+10(4) = '   '.
    GT_PRINT-LOSSQ+14(1) = '/'.
    GT_PRINT-LOSSQ+15(4) = '   '.
  ENDIF.

ENDFORM.                    " SELECT_LOSS_SPEC
*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_STRIPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AFKO_SPCOL  text
*----------------------------------------------------------------------*
FORM GET_MATNR_STRIPE  USING  P_SPCOL.

  SELECT SINGLE ATWRT
   INTO P_SPCOL
   FROM AUSP
  WHERE OBJEK =  GT_AFKO-MATNR
*-> S/4HANA-ATINN 2023.05.02 오바다
    AND ATINN = '0000000804'. "'0000000595'"PD_CA_COLOR_STRIPE
*<- CCM 2023.05.02 오바다

ENDFORM.                    " GET_MATNR_STRIPE
*&---------------------------------------------------------------------*
*&      Form  CHECK_POJANG_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_POJANG_CHANGE.

  DATA : BEGIN OF LT_AFKO OCCURS 0,
           CHECK(1),
           AUFNR    LIKE AFKO-AUFNR,
           PMATNR   LIKE MARA-MATNR,
           BDMNG    LIKE RESB-BDMNG,
         END OF LT_AFKO.

  DATA : BEGIN OF LT_RESB_A OCCURS 0,
           AUFNR LIKE AFKO-AUFNR,
         END OF LT_RESB_A.

  DATA : BEGIN OF LT_RESB_B OCCURS 0,
           MATNR LIKE MARA-MATNR,
         END OF LT_RESB_B.

  DATA : BEGIN OF LT_RESB OCCURS 0,
           MATNR LIKE MARA-MATNR,
           BDMNG LIKE RESB-BDMNG,
         END OF LT_RESB.

  DATA : LT_E1CUVAL            LIKE E1CUVAL OCCURS 50 WITH HEADER LINE.

  DATA : LV_MATNR              LIKE MARA-MATNR.

* 판매오더의 포장재 특성 조회
*& SD문서의 특성값중 포장재를 가져온다...
  LOOP AT GT_AFKO.
    CALL FUNCTION 'Z_ED_SO_CHARACTERISTIC_GET'
      EXPORTING
        I_VBELN                      = GT_AFKO-KDAUF
        I_POSNR                      = GT_AFKO-KDPOS
      TABLES
        IT_E1CUVAL                   = LT_E1CUVAL
      EXCEPTIONS
        INSTANCE_NOT_FOUND           = 1
        INSTANCE_IS_A_CLASSIFICATION = 2
        INVALID_DATA                 = 3.

    LOOP AT LT_E1CUVAL.
      CASE LT_E1CUVAL-CHARC.
        WHEN 'SAP_MILLCA_PACKAGING'.       "포장재
          PERFORM CONVERSION_EXIT_MATN1_INPUT USING LT_E1CUVAL-VALUE
                                           CHANGING LV_MATNR.
          IF LV_MATNR IS NOT INITIAL.
            GT_AFKO-PMATNR = LV_MATNR.
            MODIFY GT_AFKO.
          ENDIF.

        WHEN  OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.


* 생산오더의 포장재,조장수를 이용하여 RESB의 포장재,조장수 확인
  LOOP AT GT_AFKO WHERE KDAUF IS NOT INITIAL
                    AND PMATNR IS NOT INITIAL.

    CLEAR : LT_AFKO.

    LT_AFKO-AUFNR  = GT_AFKO-AUFNR.
    LT_AFKO-PMATNR = GT_AFKO-PMATNR.
    LT_AFKO-BDMNG = GT_AFKO-FACTOR.

    COLLECT LT_AFKO.

  ENDLOOP.

* 생산오더만 저장
  LOOP AT LT_AFKO.

    READ TABLE LT_RESB_A WITH KEY AUFNR = LT_AFKO-AUFNR.

    IF SY-SUBRC NE 0.
      LT_RESB_A-AUFNR = LT_AFKO-AUFNR.
      APPEND LT_RESB_A.
      CLEAR LT_RESB_A.
    ENDIF.

  ENDLOOP.


  LOOP AT LT_AFKO.

    DATA : LV_BDMNG   LIKE  RESB-BDMNG.

    CLEAR LV_BDMNG.

    SELECT SUM( BDMNG )
      INTO LV_BDMNG
      FROM RESB
     WHERE AUFNR = LT_AFKO-AUFNR
       AND MATNR = LT_AFKO-PMATNR
       AND XLOEK EQ SPACE.

    IF LV_BDMNG > 0 AND
       LV_BDMNG EQ LT_AFKO-BDMNG.

      LOOP AT GT_AFKO WHERE AUFNR  = LT_AFKO-AUFNR
                        AND PMATNR = LT_AFKO-PMATNR.

        GT_AFKO-PSTAT = ICON_LED_GREEN.
        MODIFY GT_AFKO.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

* 생산오더로 포장재중 판매오더에 없는게 있는지 체크
  LOOP AT LT_RESB_A.

    SELECT A~MATNR
      INTO CORRESPONDING FIELDS OF TABLE LT_RESB_B
      FROM RESB AS A INNER JOIN MARA AS B
                       ON A~MATNR = B~MATNR
      WHERE A~AUFNR = LT_RESB_A-AUFNR
        AND A~XLOEK EQ SPACE
        AND B~MTART IN ('MRM1', 'MRM2', 'MRM3')
        AND A~BWART EQ '261'.

    LOOP AT LT_RESB_B.

      READ TABLE GT_AFKO WITH KEY AUFNR  = LT_RESB_A-AUFNR
                                  PMATNR = LT_RESB_B-MATNR.

      IF SY-SUBRC NE 0.

        LOOP AT GT_AFKO WHERE AUFNR = LT_RESB_A-AUFNR.
          GT_AFKO-PSTAT = ICON_LED_RED.
          MODIFY GT_AFKO INDEX SY-TABIX.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT GT_AFKO WHERE KDAUF IS NOT INITIAL
                    AND PMATNR IS NOT INITIAL.

    IF GT_AFKO-PSTAT = SPACE.
      GT_AFKO-PSTAT = ICON_LED_RED.
    ENDIF.
    MODIFY GT_AFKO.

  ENDLOOP.

ENDFORM.                    " CHECK_POJANG_CHANGE
*&---------------------------------------------------------------------*
*&      Form  PRINT_MATNR_CAUTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_MATNR_CAUTION .
  DATA: LTSCH   LIKE THEAD-TDNAME,
        TCO09WA LIKE TCO09.

  REFRESH  GT_TEXTEDIT_LINES.
  CLEAR:   GS_TEXTEDIT_HEADER, GT_TLINES, GT_TLINES[].

  CONCATENATE P_PWERK GT_AFKO-DISPO+0(2)
                      GT_PRINT-MATNR INTO LTSCH.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'Z01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LTSCH
      OBJECT    = 'ZPP_MAT'    "자재코드 특기사항 오브젝트
    TABLES
      LINES     = GT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

ENDFORM.                    " PRINT_MATNR_CAUTION
*&---------------------------------------------------------------------*
*&      Form  GET_FIBER_SPEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FIBER_SPEC .
  DATA: LT_ATWRT   LIKE ZPPS009 OCCURS 50 WITH HEADER LINE,
        LV_SUL_NO  TYPE ATWRT,
        LV_REV_SEQ TYPE ATWRT,
        LV_DIA     TYPE ATWRT,
        LV_MATNR_F TYPE MARA-MATNR.

  SELECT SINGLE MATNR_F
    INTO LV_MATNR_F
    FROM ZPPT0136
   WHERE AUFNR = GT_PRINT-AUFNR.

  CHECK LV_MATNR_F IS NOT INITIAL.  "0136에 있는 경우에만

  REFRESH LT_ATWRT.
  CLEAR : LT_ATWRT, LV_DIA.

*& 자재에대한 특성값을 가져옴...
  CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
    EXPORTING
      IF_KLART          = '001'
      IF_MATNR          = LV_MATNR_F
    TABLES
      IT_ATWRT          = LT_ATWRT
    EXCEPTIONS
      NO_CLASSIFICATION = 1
      INVALID_KLART     = 2.

  LOOP AT LT_ATWRT.

    IF LT_ATWRT-ATNAM EQ 'PD_CA_FIBER_SPEC_1ST'.
      GS_TITLE-FSPEC = LT_ATWRT-ATWRT.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_FIBER_SPEC
*&---------------------------------------------------------------------*
*&      Form  GET_COMP_DESCRIPTION
*&---------------------------------------------------------------------*
*       생산오더 투입 원자재의 품명을 표시
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMP_DESCRIPTION .

  DATA : BEGIN OF LT_RESB  OCCURS 0,
           MATNR LIKE RESB-MATNR,
           BDMNG LIKE RESB-BDMNG,
           MEINS LIKE RESB-MEINS,
           MAKTX LIKE MAKT-MAKTX,
         END OF LT_RESB.

  DATA : LV_CNT  TYPE I.

*& 생산오더의 하위 반제품 1개만 조회
  SELECT A~MATNR A~BDMNG A~MEINS C~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE LT_RESB
  FROM RESB AS A INNER JOIN MARA AS B
                    ON A~MATNR = B~MATNR
                 INNER JOIN MAKT AS C
                    ON A~MATNR = C~MATNR
                 INNER JOIN KSSK AS D
                    ON A~MATNR = D~OBJEK
                 INNER JOIN KLAH AS E
                    ON D~CLINT = E~CLINT
 WHERE A~AUFNR  = GT_AFKO-AUFNR
   AND A~WERKS  = GT_AFKO-WERKS
   AND A~KZKUP  = SPACE          " 연산품은 제외
   AND A~XLOEK  = SPACE          " 삭제품목은 제외
   AND A~DUMPS  = SPACE          " 가상품목은 제외
   AND D~KLART  = '001'
   AND E~KLART  = '001'
   AND E~CLASS  = 'RW_CA_COMPD'  "컴파운드 자재
   AND C~SPRAS = SY-LANGU.

  CHECK LT_RESB[] IS NOT INITIAL.

  DESCRIBE TABLE LT_RESB LINES LV_CNT.


* 컴파운드 자재가 1개 이상일때는 소요량이 많은 기준으로
  IF LV_CNT > 1.

    LOOP AT LT_RESB WHERE MEINS = 'KG'.
      LT_RESB-BDMNG = LT_RESB-BDMNG / 1000.
      MODIFY LT_RESB.
    ENDLOOP.

    SORT LT_RESB BY BDMNG DESCENDING.
  ENDIF.

  READ TABLE LT_RESB INDEX 1.
  GT_AFKO-RMAKTX = LT_RESB-MAKTX.

ENDFORM.                    " GET_COMP_DESCRIPTION
*&---------------------------------------------------------------------*
*&      Form  GET_CONVERT_MENGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONVERT_MENGE.

  DATA : LV_BRGEW TYPE   MARM-BRGEW,
         LV_GEWEI TYPE   MARM-GEWEI,
         LV_CMENG TYPE   P DECIMALS 2.

  DATA : BEGIN OF LT_SUBKEY OCCURS 0,
           SUBKEY TYPE ZPPT0000-SUBKEY,
         END  OF LT_SUBKEY.
* ZPPT0000 테이블에서 단위 중량 조회 작업장 조회
  SELECT SUBKEY
    INTO CORRESPONDING FIELDS OF TABLE LT_SUBKEY
    FROM ZPPT0000
   WHERE SECTIONID = 'CONVERT'
     AND KEYID     = P_PWERK
     AND SUBKEY    = GT_AFKO-ARBPL.
* 생산오더중 조회된 작업장의 생산오더인 경우만 중량 조회
  LOOP AT LT_SUBKEY.

    LOOP AT GT_AFKO WHERE ARBPL = LT_SUBKEY-SUBKEY
                      AND CMENG = 0.

      CLEAR : LV_GEWEI, LV_BRGEW, LV_CMENG.

      SELECT SINGLE BRGEW GEWEI
        INTO (LV_BRGEW, LV_GEWEI)
        FROM MARM
       WHERE MATNR = GT_AFKO-MATNR
         AND MEINH = 'M'.

* M당 환산중량을 kg으로 변경
      IF LV_GEWEI = 'G'.
        LV_BRGEW = LV_BRGEW / 1000.
      ELSEIF LV_GEWEI = 'KG'.
        LV_BRGEW = LV_BRGEW.
      ENDIF.

      IF LV_BRGEW > 0.
        CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
          EXPORTING
*           I_RTYPE     = ' '  "반올림
*           I_RTYPE     = '+'  "올림
            I_RTYPE     = '-'  "버림
            I_RUNIT     = '0.01'
            I_VALUE     = LV_BRGEW
          IMPORTING
            E_VALUE_RND = LV_CMENG.

        IF LV_CMENG > 0.
          GT_AFKO-CMENG = LV_CMENG.
        ENDIF.

        MODIFY GT_AFKO  TRANSPORTING CMENG
                               WHERE MATNR = GT_AFKO-MATNR.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " GET_CONVERT_MENGE
*&---------------------------------------------------------------------*
*&      Form  GET_ORDER_STAT_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ORDER_STAT_CODE.

  DATA : LV_CHAR(1) TYPE C,
         LV_NUM     TYPE I,
         LV_EXIT    TYPE C.

  CLEAR : GT_STAT, GT_STAT[].
*- Start 2025.05.12
  IF S_STATUS[] IS NOT INITIAL.

    LOOP AT S_STATUS WHERE OPTION = 'EQ'.
      GT_STAT-STAT = S_STATUS-LOW.
      APPEND GT_STAT.
    ENDLOOP.

    LOOP AT S_STATUS WHERE OPTION = 'BT'.

      CLEAR : LV_EXIT.
      GT_STAT-STAT = S_STATUS-LOW.
      APPEND GT_STAT.

      SEARCH SY-ABCDE FOR S_STATUS-LOW.

      IF S_STATUS-LOW NE  S_STATUS-HIGH .

        WHILE LV_EXIT EQ  SPACE.
          IF LV_NUM EQ 0.
            LV_NUM = SY-FDPOS + 1.
          ELSE.
            LV_NUM = LV_NUM + 1.
          ENDIF.

          GT_STAT-STAT = SY-ABCDE+LV_NUM(1).
          APPEND GT_STAT.

          IF GT_STAT-STAT = S_STATUS-HIGH.
            LV_EXIT = 'X'.
          ENDIF.

        ENDWHILE.

      ENDIF.

    ENDLOOP.

    LOOP AT GT_STAT.

      CASE GT_STAT-STAT.
        WHEN 'A'.
          GT_STAT-STAT = TEXT-039."작업지시전
        WHEN 'B'.
          GT_STAT-STAT = TEXT-040."작업대기
        WHEN 'C'.
          GT_STAT-STAT = TEXT-044."작업중
        WHEN 'D'.
          GT_STAT-STAT = TEXT-002."작업완료
        WHEN 'E'.
          GT_STAT-STAT = TEXT-041."오더종료
        WHEN 'Z'.
          GT_STAT-STAT = TEXT-045."비정상오더
        WHEN 'F'.
          GT_STAT-STAT = TEXT-042."작업완료 처리대상
        WHEN 'G'.
          GT_STAT-STAT = TEXT-043."입고완료 처리대상
      ENDCASE.

      MODIFY GT_STAT.

    ENDLOOP.

    CLEAR GT_STAT.
    READ TABLE GT_STAT WITH KEY STAT = TEXT-044.
    IF SY-SUBRC = 0.
      GT_STAT-STAT = TEXT-T08. APPEND GT_STAT."Pay Off
    ENDIF.

  ELSE.

    GT_STAT-STAT = TEXT-039. APPEND GT_STAT."작업지시전
    GT_STAT-STAT = TEXT-040. APPEND GT_STAT."작업대기
    GT_STAT-STAT = TEXT-044. APPEND GT_STAT."작업중
    GT_STAT-STAT = TEXT-T08. APPEND GT_STAT."Pay Off
    GT_STAT-STAT = TEXT-002. APPEND GT_STAT."작업완료
    GT_STAT-STAT = TEXT-041. APPEND GT_STAT."오더종료
    GT_STAT-STAT = TEXT-045. APPEND GT_STAT."비정상오더
    GT_STAT-STAT = TEXT-042. APPEND GT_STAT."작업완료 처리대상
    GT_STAT-STAT = TEXT-043. APPEND GT_STAT."입고완료 처리대상

  ENDIF.

  SORT GT_STAT BY STAT.
  DELETE ADJACENT DUPLICATES FROM GT_STAT COMPARING STAT.
*- End 2025.05.12
ENDFORM.                    " GET_ORDER_STAT_CODE
*&---------------------------------------------------------------------*
*&      Form  GET_COOIS_COMPONENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COOIS_COMPONENT.

  DATA : LS_SC1100  TYPE PPIO_ENTRY_SC1100.

  RANGES : LR_AUFNR  FOR AFKO-AUFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].

  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
    EXIT.
  ENDIF.

  LOOP AT ROW_TABLE.
    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.

    LR_AUFNR-SIGN = 'I'.
    LR_AUFNR-OPTION = 'EQ'.
    LR_AUFNR-LOW = GT_AFKO-AUFNR.
    APPEND LR_AUFNR.
  ENDLOOP.

  LS_SC1100-PPIO_LISTTYP = 'PPIOM000'.
  LS_SC1100-ALV_VARIANT = '/Z1'.

  SUBMIT PPIO_ENTRY
  WITH P_TCODE = 'COOIS'
  WITH P_SC1100 = LS_SC1100
  WITH S_AUFNR IN LR_AUFNR
  AND RETURN.

ENDFORM.                    " GET_COOIS_COMPONENT
*&---------------------------------------------------------------------*
*&      Form  GET_MCFE_BASE_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AFKO_AUFNR  text
*      <--P_GT_AFKO_FCOLOR  text
*----------------------------------------------------------------------*
FORM GET_MCFE_BASE_COLOR  USING    P_AUFNR
                          CHANGING P_FCOLOR.

  SELECT SINGLE ZZCOLOR_BASE
    INTO P_FCOLOR
    FROM ZPPT0136 AS A INNER JOIN MARA AS B
                          ON A~MATNR_F = B~MATNR
   WHERE A~AUFNR = P_AUFNR.

ENDFORM.                    " GET_MCFE_BASE_COLOR
*&---------------------------------------------------------------------*
*& Form get_aufnr
*&---------------------------------------------------------------------*
FORM GET_AUFNR .

  GT_ORDER-AUFNR = GT_AFKO-AUFNR.
  APPEND GT_ORDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_logic_new_field
*&---------------------------------------------------------------------*
FORM CHECK_LOGIC_NEW_FIELD .
* 오더별 작업번호가 N건일때 가장 첫번째 Data에만 반영( 입고 상태 제외 )
* 과거에 종료되었어야할 오더의 투입 자재 점검
  CLEAR GV_CHECK.
*  IF gt_afko-gltrs < sy-datum OR
*    ( gt_afko-gltrs EQ sy-datum AND gt_afko-gluzs <= sy-uzeit ).
*- Start 2025.01.15
*- 입고 Status Check
  PERFORM CHECK_GR_STATUS.
*- 실적 Status Check
  PERFORM CHECK_CF_STATUS.
*- 투입 Status Check
  PERFORM CHECK_GI_STATUS.
*- 지연 시간, 지연 구분
  PERFORM UPDATE_DELAY_TYPE_AND_TIME.
*- End 2025.01.15
*  ENDIF.
*- Start 여장 수량, 수리 작업 수량, End 여장 수량
*- 예압 시간, 여장 작업 시간, 수리 작업 시간, End 여장 작업 시간
  PERFORM MERGE_CGMENGE_BADMENGE.
* 시간 단위
  CHECK GT_AFKO-POSNR = '0001'.

  SELECT SINGLE C~VGE02 INTO GT_AFKO-TIMEM
     FROM AFKO AS A INNER JOIN AFVC AS B
          ON A~AUFPL = B~AUFPL
          INNER JOIN AFVV AS C
          ON   B~AUFPL = C~AUFPL
          AND B~APLZL = C~APLZL
          WHERE AUFNR EQ GT_AFKO-AUFNR
               AND PLNFL = '000000'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_gi_status
*&---------------------------------------------------------------------*
FORM CHECK_GI_STATUS .

  DATA : BEGIN OF LT_ERFMG OCCURS 0,
           MATNR      LIKE RESB-MATNR,
           ERFMG      TYPE P DECIMALS 3,
           ERFME      LIKE MARA-MEINS,
           SPART      LIKE MARA-SPART,
           MTPOS_MARA LIKE MARA-MTPOS_MARA,
         END OF LT_ERFMG. "자재별 소요량 데이터
  DATA : BEGIN OF LT_MENGE OCCURS 0,
           MATNR      LIKE RESB-MATNR,
           MENGE      TYPE P DECIMALS 3,
           MEINS      LIKE MARA-MEINS,
           SPART      LIKE MARA-SPART,
           MTPOS_MARA LIKE MARA-MTPOS_MARA,
         END OF LT_MENGE. "자재별 투입 데이터
  DATA : LV_CONV_ERFMG LIKE EKPO-MENGE.

  CHECK GT_AFKO-POSNR = '0001'.
* 오더의 입고 상태가 'DLV' OR 'PDLV'일 때만 투입 상태 업데이트
  IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN OR GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
* 소요량 데이터 취합
    SELECT AUFNR, RSPOS, MATNR, ERFMG, ERFME, ENMNG, MEINS
        INTO TABLE @DATA(LT_RESB)
        FROM RESB
        WHERE AUFNR EQ @GT_AFKO-AUFNR
             AND BWART EQ '261'
             AND XLOEK <> 'X'.

    CLEAR : LT_ERFMG[], LT_MENGE[].
    LOOP AT LT_RESB INTO DATA(LS_RESB).

      CLEAR : LT_ERFMG.
      LT_ERFMG-MATNR = LS_RESB-MATNR.
      LT_ERFMG-ERFMG = LS_RESB-ERFMG.
      LT_ERFMG-ERFME = LS_RESB-ERFME.
      SELECT SINGLE SPART, MTPOS_MARA
               INTO ( @LT_ERFMG-SPART, @LT_ERFMG-MTPOS_MARA )
               FROM MARA
               WHERE MATNR = @LT_ERFMG-MATNR.
      COLLECT LT_ERFMG.

    ENDLOOP.
* 투입 데이터
    LOOP AT GT_AUFM2 INTO GS_AUFM2
                                    WHERE AUFNR = GT_AFKO-AUFNR.

      IF GS_AUFM2-BWART = '262'.
        GS_AUFM2-MENGE = GS_AUFM2-MENGE * -1.
      ENDIF.

      CLEAR LT_MENGE.
      LT_MENGE-MATNR = GS_AUFM2-MATNR.
      LT_MENGE-MENGE = GS_AUFM2-MENGE.
      LT_MENGE-MEINS = GS_AUFM2-MEINS.
      SELECT SINGLE SPART, MTPOS_MARA
               INTO ( @LT_MENGE-SPART, @LT_MENGE-MTPOS_MARA )
               FROM MARA
               WHERE MATNR = @LT_MENGE-MATNR.
      COLLECT LT_MENGE.

    ENDLOOP.

    DELETE LT_MENGE WHERE MENGE EQ 0.

    SORT: LT_ERFMG BY MATNR,
          LT_MENGE BY MATNR.

*[U01] 가온전선 추가
    IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
      IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN.
        LOOP AT LT_ERFMG.

          CLEAR LT_MENGE.
          READ TABLE LT_MENGE WITH KEY MATNR = LT_ERFMG-MATNR.
* 투입 수량이 없고, 해당 자재가 제품군:90, 일반품목범주:VERP 일 경우 대체 투입 체크.
          IF SY-SUBRC <> 0.

            IF LT_ERFMG-SPART EQ '90' AND LT_ERFMG-MTPOS_MARA = 'VERP'.

              CLEAR LT_MENGE.
              READ TABLE LT_MENGE WITH KEY SPART      = '90'
                                           MTPOS_MARA = 'VERP'.
              IF SY-SUBRC = 0. "대체 투입 있으면 노란불
                GT_AFKO-GISTAT = ICON_LED_YELLOW.
                EXIT.
              ELSE. "대체 투입 없으면 빨간불
                IF GT_AFKO-GISTAT NE ICON_LED_YELLOW.
                  GT_AFKO-GISTAT = ICON_LED_RED.
*                EXIT.
                ENDIF.
              ENDIF.
* 아닐 경우 빨간불
            ELSE.
              IF GT_AFKO-GISTAT NE ICON_LED_YELLOW.
                GT_AFKO-GISTAT = ICON_LED_RED.
*              EXIT.
              ENDIF.
            ENDIF.
* 투입 수량이 존재하는 경우 표준 소요량과 비교하여 상태값 업데이트
          ELSE.
* 표준 소요량 계산
            CLEAR LV_CONV_ERFMG.
            IF LT_ERFMG-ERFMG NE 0 AND GV_WEMNG NE 0 AND GV_PSMNG NE 0.
              LV_CONV_ERFMG = LT_ERFMG-ERFMG * GV_WEMNG / GV_PSMNG.
            ENDIF.
* 단위가 다를 경우 단위 Conversion 필요
            IF LT_MENGE-MEINS NE LT_ERFMG-ERFME.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR  = LT_ERFMG-MATNR
                  I_IN_ME  = LT_ERFMG-ERFME
                  I_OUT_ME = LT_MENGE-MEINS
                  I_MENGE  = LV_CONV_ERFMG
                IMPORTING
                  E_MENGE  = LV_CONV_ERFMG.

            ENDIF.
            "투입량 < 소요량
            IF LT_MENGE-MENGE <= LV_CONV_ERFMG.
              GT_AFKO-GISTAT = ICON_LED_YELLOW.
              EXIT.
            ENDIF.

          ENDIF.
        ENDLOOP.

      ELSEIF GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
        LOOP AT LT_ERFMG.

          CLEAR LT_MENGE.
          READ TABLE LT_MENGE WITH KEY MATNR = LT_ERFMG-MATNR.
* 투입 수량이 없고, 해당 자재가 제품군:90, 일반품목범주:VERP 일 경우 대체 투입 체크.
          IF SY-SUBRC EQ 0.
* 표준 소요량 계산
            CLEAR LV_CONV_ERFMG.
            IF LT_ERFMG-ERFMG NE 0 AND GV_WEMNG NE 0 AND GV_PSMNG NE 0.
              LV_CONV_ERFMG = LT_ERFMG-ERFMG * GV_WEMNG / GV_PSMNG.
            ENDIF.
* 단위가 다를 경우 단위 Conversion 필요
            IF LT_MENGE-MEINS NE LT_ERFMG-ERFME.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR  = LT_ERFMG-MATNR
                  I_IN_ME  = LT_ERFMG-ERFME
                  I_OUT_ME = LT_MENGE-MEINS
                  I_MENGE  = LV_CONV_ERFMG
                IMPORTING
                  E_MENGE  = LV_CONV_ERFMG.

            ENDIF.
            "투입량 < 소요량
            IF LT_MENGE-MENGE <= LV_CONV_ERFMG.
              GT_AFKO-GISTAT = ICON_LED_YELLOW.
              EXIT.
            ENDIF.

          ELSE.
            GT_AFKO-GISTAT = ICON_LED_RED.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ELSE.
*[U01] 가온전선 추가

      IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN.
        LOOP AT LT_ERFMG.

          CLEAR LT_MENGE.
          READ TABLE LT_MENGE WITH KEY MATNR = LT_ERFMG-MATNR.
* 투입 수량이 없고, 해당 자재가 제품군:90, 일반품목범주:VERP 일 경우 대체 투입 체크.
          IF SY-SUBRC <> 0.

            IF LT_ERFMG-SPART EQ '90' AND LT_ERFMG-MTPOS_MARA = 'VERP'.

              CLEAR LT_MENGE.
              READ TABLE LT_MENGE WITH KEY SPART      = '90'
                                           MTPOS_MARA = 'VERP'.
              IF SY-SUBRC = 0. "대체 투입 있으면 노란불
                GT_AFKO-GISTAT = ICON_LED_YELLOW.
*            EXIT.
              ELSE. "대체 투입 없으면 빨간불
                GT_AFKO-GISTAT = ICON_LED_RED.
                EXIT.
              ENDIF.
* 아닐 경우 빨간불
            ELSE.
              GT_AFKO-GISTAT = ICON_LED_RED.
              EXIT.
            ENDIF.
* 투입 수량이 존재하는 경우 표준 소요량과 비교하여 상태값 업데이트
          ELSE.
* 표준 소요량 계산
            CLEAR LV_CONV_ERFMG.
            IF LT_ERFMG-ERFMG NE 0 AND GV_WEMNG NE 0 AND GV_PSMNG NE 0.
              LV_CONV_ERFMG = LT_ERFMG-ERFMG * GV_WEMNG / GV_PSMNG.
            ENDIF.
* 단위가 다를 경우 단위 Conversion 필요
            IF LT_MENGE-MEINS NE LT_ERFMG-ERFME.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR  = LT_ERFMG-MATNR
                  I_IN_ME  = LT_ERFMG-ERFME
                  I_OUT_ME = LT_MENGE-MEINS
                  I_MENGE  = LV_CONV_ERFMG
                IMPORTING
                  E_MENGE  = LV_CONV_ERFMG.

            ENDIF.
            "투입량 < 소요량
            IF LT_MENGE-MENGE < LV_CONV_ERFMG.
              GT_AFKO-GISTAT = ICON_LED_YELLOW.
*            EXIT.
            ENDIF.

          ENDIF.
        ENDLOOP.

      ELSEIF GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
        LOOP AT LT_ERFMG.

          CLEAR LT_MENGE.
          READ TABLE LT_MENGE WITH KEY MATNR = LT_ERFMG-MATNR.
* 투입 수량이 없고, 해당 자재가 제품군:90, 일반품목범주:VERP 일 경우 대체 투입 체크.
          IF SY-SUBRC EQ 0.
* 표준 소요량 계산
            CLEAR LV_CONV_ERFMG.
            IF LT_ERFMG-ERFMG NE 0 AND GV_WEMNG NE 0 AND GV_PSMNG NE 0.
              LV_CONV_ERFMG = LT_ERFMG-ERFMG * GV_WEMNG / GV_PSMNG.
            ENDIF.
* 단위가 다를 경우 단위 Conversion 필요
            IF LT_MENGE-MEINS NE LT_ERFMG-ERFME.

              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  I_MATNR  = LT_ERFMG-MATNR
                  I_IN_ME  = LT_ERFMG-ERFME
                  I_OUT_ME = LT_MENGE-MEINS
                  I_MENGE  = LV_CONV_ERFMG
                IMPORTING
                  E_MENGE  = LV_CONV_ERFMG.

            ENDIF.
            "투입량 < 소요량
            IF LT_MENGE-MENGE < LV_CONV_ERFMG.
              GT_AFKO-GISTAT = ICON_LED_YELLOW.
*            EXIT.
            ENDIF.

          ELSE.
            GT_AFKO-GISTAT = ICON_LED_RED.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ENDIF.  "[U01] 가온전선 추가


** 오더 입고 상태 : "PDLV" 일 땐 노란불 EXIT.빨간불일 경우에도 EXIT
** 그 외 노란불일 때는 상태값 담아두고 다음 건 체크
*    LOOP AT LT_ERFMG.
*
*      CLEAR LT_MENGE.
*      READ TABLE LT_MENGE WITH KEY MATNR = LT_ERFMG-MATNR.
** 투입 수량이 없고, 해당 자재가 제품군:90, 일반품목범주:VERP 일 경우 대체 투입 체크.
*      IF SY-SUBRC <> 0.
*
*        IF LT_ERFMG-SPART EQ '90' AND LT_ERFMG-MTPOS_MARA = 'VERP'.
*
*          CLEAR LT_MENGE.
*          READ TABLE LT_MENGE WITH KEY SPART      = '90'
*                                       MTPOS_MARA = 'VERP'.
*          IF SY-SUBRC = 0. "대체 투입 있으면 노란불
*            GT_AFKO-GISTAT = ICON_LED_YELLOW.
**            EXIT.
*          ELSE. "대체 투입 없으면 빨간불
*            GT_AFKO-GISTAT = ICON_LED_RED.
*            EXIT.
*          ENDIF.
** 아닐 경우 빨간불
*        ELSE.
*          GT_AFKO-GISTAT = ICON_LED_RED.
*          EXIT.
*        ENDIF.
** 투입 수량이 존재하는 경우 표준 소요량과 비교하여 상태값 업데이트
*      ELSE.
** 오더 입고 상태가 "DLV"이고, 투입 수량이 표준 소요량보다 작으면 노란불
*        IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN.
** 표준 소요량 계산
*          CLEAR LV_CONV_ERFMG.
*          IF LT_ERFMG-ERFMG NE 0 AND GV_WEMNG NE 0 AND GV_PSMNG NE 0.
*            LV_CONV_ERFMG = LT_ERFMG-ERFMG * GV_WEMNG / GV_PSMNG.
*          ENDIF.
** 단위가 다를 경우 단위 Conversion 필요
*          IF LT_MENGE-MEINS NE LT_ERFMG-ERFME.
*
*            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
*              EXPORTING
*                I_MATNR  = LT_ERFMG-MATNR
*                I_IN_ME  = LT_ERFMG-ERFME
*                I_OUT_ME = LT_MENGE-MEINS
*                I_MENGE  = LV_CONV_ERFMG
*              IMPORTING
*                E_MENGE  = LV_CONV_ERFMG.
*
*          ENDIF.
*          "투입량 < 소요량
*          IF LT_MENGE-MENGE < LV_CONV_ERFMG.
*            GT_AFKO-GISTAT = ICON_LED_YELLOW.
**            EXIT.
*          ENDIF.
*
** 오더 입고 상태가 "PDLV"일 경우 무조건 노란불
*        ELSEIF GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
*          GT_AFKO-GISTAT = ICON_LED_YELLOW.
**          EXIT.
*        ENDIF.
*
*      ENDIF.
*
*    ENDLOOP.
* 앞에서 상태값이 비었을 경우 정상 처리로 보고 초록불
    IF GT_AFKO-GISTAT IS INITIAL.
      GT_AFKO-GISTAT = ICON_LED_GREEN.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_cf_status
*&---------------------------------------------------------------------*
FORM CHECK_CF_STATUS .

  CHECK GT_AFKO-POSNR = '0001'.

  CLEAR : GV_WEMNG, GV_PSMNG.

***  Start CNF Status 개선 20260722 ZGISPP03
* 오더의 입고 상태가 'DLV' OR 'PDLV'일 때만 실적 상태 업데이트
  IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN OR GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
* 품목 입고 수량
    SELECT SINGLE SUM( WEMNG ) INTO @GV_WEMNG
                    FROM AFPO
                    WHERE AUFNR EQ @GT_AFKO-AUFNR.
*                         AND posnr EQ @gt_afko-posnr.
* 오더 총 수량
    SELECT SINGLE SUM( PSMNG ) INTO @GV_PSMNG
                FROM AFPO
                WHERE AUFNR EQ @GT_AFKO-AUFNR.
*                     AND posnr EQ @gt_afko-posnr.
* 총 양품 실적 수량
    SELECT SINGLE SUM( LMNGA ) INTO @DATA(LV_LMNGA)
                    FROM AFRU
                    WHERE AUFNR EQ @GT_AFKO-AUFNR
                         AND GRUND EQ @SPACE
                         AND STOKZ EQ @SPACE
                         AND STZHL EQ @SPACE.
* 오더 입고 상태가 "DLV"일 경우
    IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN.
* 총 양품 실적 수량이 0이면 빨간색
      IF LV_LMNGA EQ 0.
        GT_AFKO-CFSTAT = ICON_LED_RED.
*- Start 2025.05.12
* 오더의 품목 입고 수량 = 해당 작업번호의 총 양품 실적 수량이고 & 오더의 상태가 CNF이면 초록불
      ELSEIF GV_WEMNG = LV_LMNGA AND 'CNF' IN GR_STATUS.
        GT_AFKO-CFSTAT = ICON_LED_GREEN.
*- End 2025.05.12
* (오더의 품목 입고 수량 > 해당 작업번호의 총 양품 실적 수량) or
* (오더의 품목 입고 수량 <= 총 양품 실적 수량이지만 오더의 상태가 PCNF)이면 노란불
*        ELSEIF GV_WEMNG > LV_LMNGA OR
*             ( GV_WEMNG <= LV_LMNGA AND 'PCNF' IN GR_STATUS ).
      ELSE.  "[U01]
        GT_AFKO-CFSTAT = ICON_LED_YELLOW.
      ENDIF.
* 오더 입고 상태가 "PDLV"일 경우
    ELSEIF GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
* 총 양품 실적 수량이 0이면 빨간색
      IF LV_LMNGA EQ 0.
        GT_AFKO-CFSTAT = ICON_LED_RED.
      ELSE.
        GT_AFKO-CFSTAT = ICON_LED_YELLOW.
      ENDIF.

    ENDIF.

  ENDIF.

** 오더 종료 여부가 작업완료이면 GREEN
*  IF GT_AFKO-STTXT EQ TEXT-002.
*    GT_AFKO-CFSTAT = ICON_LED_GREEN.
*  ELSE.
** 오더의 입고 상태가 'DLV' OR 'PDLV'일 때만 실적 상태 업데이트
*    IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN OR GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
** 품목 입고 수량
*      SELECT SINGLE SUM( WEMNG ) INTO @GV_WEMNG
*                      FROM AFPO
*                      WHERE AUFNR EQ @GT_AFKO-AUFNR.
**                         AND posnr EQ @gt_afko-posnr.
** 오더 총 수량
*      SELECT SINGLE SUM( PSMNG ) INTO @GV_PSMNG
*                  FROM AFPO
*                  WHERE AUFNR EQ @GT_AFKO-AUFNR.
**                     AND posnr EQ @gt_afko-posnr.
** 총 양품 실적 수량
*      SELECT SINGLE SUM( LMNGA ) INTO @DATA(LV_LMNGA)
*                      FROM AFRU
*                      WHERE AUFNR EQ @GT_AFKO-AUFNR
*                           AND GRUND EQ @SPACE
*                           AND STOKZ EQ @SPACE
*                           AND STZHL EQ @SPACE.
** 오더 입고 상태가 "DLV"일 경우
*      IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN.
** 총 양품 실적 수량이 0이면 빨간색
*        IF LV_LMNGA EQ 0.
*          GT_AFKO-CFSTAT = ICON_LED_RED.
**- Start 2025.05.12
** 오더의 품목 입고 수량 = 해당 작업번호의 총 양품 실적 수량이고 & 오더의 상태가 CNF이면 초록불
**      ELSEIF gv_wemng <= lv_lmnga AND 'CNF' IN gr_status.
*        ELSEIF GV_WEMNG = LV_LMNGA AND 'CNF' IN GR_STATUS.
*          GT_AFKO-CFSTAT = ICON_LED_GREEN.
**- End 2025.05.12
** (오더의 품목 입고 수량 > 해당 작업번호의 총 양품 실적 수량) or
** (오더의 품목 입고 수량 <= 총 양품 실적 수량이지만 오더의 상태가 PCNF)이면 노란불
**        ELSEIF GV_WEMNG > LV_LMNGA OR
**             ( GV_WEMNG <= LV_LMNGA AND 'PCNF' IN GR_STATUS ).
*        ELSE.  "[U01]
*          GT_AFKO-CFSTAT = ICON_LED_YELLOW.
*        ENDIF.
** 오더 입고 상태가 "PDLV"일 경우
*      ELSEIF GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
** 총 양품 실적 수량이 0이면 빨간색
*        IF LV_LMNGA EQ 0.
*          GT_AFKO-CFSTAT = ICON_LED_RED.
*        ELSE.
*          GT_AFKO-CFSTAT = ICON_LED_YELLOW.
*        ENDIF.
*
*      ENDIF.
*
*    ENDIF.
*  ENDIF.
***  End CNF Status 개선 20260722 ZGISPP03

*  DATA : lv_lmnga LIKE afru-lmnga,
*         lv_aueru.
*
*  CLEAR : gt_afru2, gv_check.
*  READ TABLE gt_afru2 WITH KEY aufnr = gt_afko-aufnr.
*
*  IF sy-subrc <> 0.
*
*    gv_check = 'X'.
*
*  ELSE.
*
*    LOOP AT gt_afru2 FROM sy-tabix.
*
*      IF gt_afru2-aufnr NE gt_afko-aufnr.
*        EXIT.
*      ELSE.
** 생산 오더 내 모든 작업이 최종 확정되었는 지 확인
*        CLEAR lv_aueru.
*        LOOP AT gt_afru WHERE aufnr EQ gt_afru2-aufnr
*                                       AND vornr EQ gt_afru2-vornr
*                                       AND aueru EQ 'X'.
*          lv_aueru = 'X'.
*          EXIT.
*        ENDLOOP.
** 최종 확정(AUERU) 되지 않았을 경우 오더 총 수량과 총 실적 수량 비교
*        IF lv_aueru IS INITIAL.
*
*          CLEAR : lv_lmnga.
*          LOOP AT gt_afru WHERE aufnr EQ gt_afru2-aufnr
*                                      AND vornr EQ gt_afru2-vornr
*                                      AND grund EQ space.
*            lv_lmnga = lv_lmnga + gt_afru-lmnga.
*          ENDLOOP.
** 오더 작업별 지시 수량보다 실적 수량이 적을 경우 에러 메시지
*          IF gt_afko-psmng > lv_lmnga.
*            gv_check = 'X'.
*            EXIT.
*          ENDIF.
*
*        ENDIF.
*
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDIF.
*
*  IF gv_check IS INITIAL.
*    gt_afko-cfstat = icon_led_green.
*  ELSE.
*    gt_afko-cfstat = icon_led_red.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_new_field
*&---------------------------------------------------------------------*
FORM GET_DATA_NEW_FIELD .

  IF GT_ORDER[] IS NOT INITIAL.
* RESB에서 투입 정보 취합
    SORT GT_ORDER BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM GT_ORDER COMPARING AUFNR.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_RESB2
        FROM RESB
        FOR ALL ENTRIES IN @GT_ORDER
        WHERE AUFNR EQ @GT_ORDER-AUFNR
*- Start 2024.10.22 단위 테스트 요청 사항 반영
            AND KZKUP = ' '.
*- End 2024.10.22
    SORT GT_RESB2 BY AUFNR.
* AFRU에서 실적 정보 취합
    SELECT *
        FROM AFRU
        FOR ALL ENTRIES IN @GT_ORDER
        WHERE AUFNR EQ @GT_ORDER-AUFNR
             AND STOKZ EQ @SPACE
             AND STZHL EQ @SPACE
             INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU.

    SORT GT_AFRU BY AUFNR.

*    gt_afru2[] = gt_afru[].
*    SORT gt_afru2 BY aufnr vornr.
*    DELETE ADJACENT DUPLICATES FROM gt_afru2
*                                                 COMPARING aufnr vornr.
* AFPO
    SELECT *
       INTO CORRESPONDING FIELDS OF TABLE @GT_AFPO
       FROM AFPO
       FOR ALL ENTRIES IN @GT_ORDER
       WHERE AUFNR EQ @GT_ORDER-AUFNR.

    SORT GT_AFPO BY AUFNR.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_gr_status
*&---------------------------------------------------------------------*
FORM CHECK_GR_STATUS .

  DATA : LV_AUFNR LIKE AUFM-AUFNR.

  CLEAR : GT_AUFM.
* 오더가 입고완료(DLV) 상태면 초록색
  IF 'DLV' IN GR_STATUS.
    GT_AFKO-GRSTAT = ICON_LED_GREEN.
* 오더가 부분 입고(PDLV) 상태면 노란색
  ELSEIF 'PDLV' IN GR_STATUS.
    GT_AFKO-GRSTAT = ICON_LED_YELLOW.
* 오더가 위 상태들이 아니면, "후행 오더의 자재 이동 문서 존재여부" 확인 후 업데이트
  ELSE.
    SELECT SINGLE ORDNR INTO @DATA(LV_ORDNR) FROM ZGTPPT2010
                                          WHERE REORD EQ @GT_AFKO-AUFNR
                                               AND RELINE EQ @GT_AFKO-POSNR.
* 후공정 오더 추출 성공시, 자재문서 존재 여부 확인
    IF LV_ORDNR IS NOT INITIAL.

      LV_AUFNR = LV_ORDNR.
      SELECT AUFNR, MBLNR, MJAHR
           INTO CORRESPONDING FIELDS OF TABLE @GT_AUFM
           FROM AUFM
           WHERE AUFNR EQ @LV_AUFNR.
* 존재 시 빨간색
      IF GT_AUFM[] IS NOT INITIAL.
        SORT GT_AUFM BY MBLNR.
        GT_AFKO-GRSTAT = ICON_LED_RED.
      ELSE.
        CLEAR GT_AFKO-GRSTAT.
      ENDIF.

    ENDIF.

  ENDIF.
*  DATA : lv_wemng LIKE afpo-wemng,
*         lv_elikz.
** 생산 오더 납품 완료 지시자(ELIKZ)가 모두 체크되었는 지 확인
*  CLEAR : lv_elikz, gv_check.
*  LOOP AT gt_afpo WHERE aufnr EQ gt_afko-aufnr
*                               AND elikz NE 'X'.
*    lv_elikz = 'X'.
*    EXIT.
*  ENDLOOP.
** 납품 완료 지시자가 체크되어 있지 않을 경우 오더 대비 입고 수량 확인
*  IF lv_elikz IS NOT INITIAL.
*
*    CLEAR : lv_wemng.
*    LOOP AT gt_afpo WHERE aufnr EQ gt_afko-aufnr.
*      lv_wemng = lv_wemng + gt_afpo-wemng.
*    ENDLOOP.
** 오더 작업별 지시 수량보다 실적 수량이 적을 경우 에러 메시지
*    IF gt_afko-psmng > lv_wemng.
*      gv_check = 'X'.
*    ENDIF.
*
*  ENDIF.
*
*  IF gv_check IS INITIAL.
*    gt_afko-grstat = icon_led_green.
*  ELSE.
*    gt_afko-grstat = icon_led_red.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form merge_cgmenge_badmenge
*&---------------------------------------------------------------------*
FORM MERGE_CGMENGE_BADMENGE .

  CHECK GT_AFKO-POSNR = '0001'.

  LOOP AT GT_AFRU WHERE AUFNR  EQ GT_AFKO-AUFNR
                           AND VORNR EQ GT_AFKO-VORNR.
* Start 여장 수량
*    IF gt_afru-grund EQ 'CH01'.
    IF GT_AFRU-GRUND EQ 'CH02'.
      GT_AFKO-CGMENGE = GT_AFKO-CGMENGE + GT_AFRU-LMNGA.
* 수리 작업 수량
    ELSEIF GT_AFRU-GRUND EQ 'RW01'.
      GT_AFKO-BADMENGE = GT_AFKO-BADMENGE + GT_AFRU-XMNGA.
* End 여장 수량
    ELSEIF GT_AFRU-GRUND EQ 'CH03'.
      GT_AFKO-ENDMENGE = GT_AFKO-ENDMENGE + GT_AFRU-LMNGA.
    ENDIF.
* 예압 시간
    IF GT_AFRU-GRUND EQ 'CH01'.
      GT_AFKO-YEAPT = GT_AFKO-YEAPT + GT_AFRU-ISM01.
* Start 여장 작업 시간
    ELSEIF GT_AFRU-GRUND EQ 'CH02'.
      GT_AFKO-CGT = GT_AFKO-CGT + GT_AFRU-ISM02.
* 수리 작업 시간
    ELSEIF GT_AFRU-GRUND EQ 'RW01'.
      GT_AFKO-BADT = GT_AFKO-BADT + GT_AFRU-ISM02.
* End 여장 작업 시간
    ELSEIF GT_AFRU-GRUND EQ 'CH03'.
      GT_AFKO-ENDT = GT_AFKO-ENDT + GT_AFRU-ISM02.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_delay_type_and_time
*&---------------------------------------------------------------------*
FORM UPDATE_DELAY_TYPE_AND_TIME .

  DATA : LV_CPUDT LIKE MKPF-CPUDT,
         LV_CPUTM LIKE MKPF-CPUTM.
*- 지연구분(DELAY)  = 대입 값(Text) 우선순위는 아래와 같음
*   1) 입고 현황 = 빨간색이면,  "입고"
*   2) 실적 현황 = 빨간색이면,  "실적"
*   3) 투입 현황 = 빨간색이면,  "입고"
*   4) 위에 해당안되면
* 지연구분이 "입고"인 경우, 후공정 오더의 최초 자재문서 입력일자, 시간을 확인하여 현재 시간과 비교
  CLEAR : LV_CPUDT, LV_CPUTM.
  IF GT_AFKO-GRSTAT EQ ICON_LED_RED.

    GT_AFKO-DELAY = TEXT-T03.
    CLEAR GS_AUFM.
    READ TABLE GT_AUFM INTO GS_AUFM INDEX 1.

    SELECT SINGLE CPUDT, CPUTM INTO (@LV_CPUDT, @LV_CPUTM )
                    FROM MKPF
                    WHERE MBLNR EQ @GS_AUFM-MBLNR
                         AND MJAHR EQ @GS_AUFM-MJAHR.

    PERFORM CALCURATE_DATETIME USING LV_CPUDT LV_CPUTM.
* 입고를 제외한 나머지는 첫번째 데이터에만 반영
  ELSEIF GT_AFKO-POSNR = '0001'.

    IF GT_AFKO-CFSTAT EQ ICON_LED_RED.
      GT_AFKO-DELAY = TEXT-T02.
    ELSEIF GT_AFKO-GISTAT EQ ICON_LED_RED.
      GT_AFKO-DELAY = TEXT-T01.
    ENDIF.
* 지연구분 값이 존재시 아래 로직을 태울 것
    CHECK GT_AFKO-DELAY IS NOT INITIAL.
* 지연구분이 "실적" 또는 "투입"인 경우, 오더의 입고 자재문서의 가장 빠른(MIN) 입력일자, 시간을 확인하여 현재 시간과 비교
    IF GT_AFKO-DELAY = TEXT-T02 OR GT_AFKO-DELAY = TEXT-T01.

      SELECT MBLNR, MJAHR
          INTO TABLE @DATA(LT_MATDOC)
          FROM MATDOC
          WHERE AUFNR EQ @GT_AFKO-AUFNR
               AND BWART EQ '101'
               AND CANCELLED NE 'X'.

      SORT LT_MATDOC BY MBLNR.
      READ TABLE LT_MATDOC INTO DATA(LS_MATDOC) INDEX 1.

      SELECT SINGLE CPUDT, CPUTM INTO (@LV_CPUDT, @LV_CPUTM )
                      FROM MKPF
                      WHERE MBLNR EQ @LS_MATDOC-MBLNR
                           AND MJAHR EQ @LS_MATDOC-MJAHR.

      PERFORM CALCURATE_DATETIME USING LV_CPUDT LV_CPUTM.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_to_email_delay_order
*&---------------------------------------------------------------------*
FORM SEND_TO_EMAIL_DELAY_ORDER .

  DATA : LV_APRIO LIKE AFKO-APRIO.
  DATA : RESULT_TAB TYPE MATCH_RESULT_TAB.

  CLEAR : GT_AFKO2, GT_AFKO2[], GT_AFKO3, GT_AFKO3[], GT_AFKO4, GT_AFKO4[],
*- Start 2025.05.14
          GV_FLD_02, GT_AFKO5, GT_AFKO5[].
* 마감 점검용은 우선 현재일자가 Working Day 말일인지 점검 후 맞으면 전송
  PERFORM CHECK_LAST_DAY.
*- End 2025.05.14
  LOOP AT GT_AFKO.
* 알람 제외 대상의 경우 배치 전송 제외
    READ TABLE GT_3300 INTO DATA(LS_3300) WITH KEY AUFNR = GT_AFKO-AUFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CONTINUE.
    ENDIF.

    CLEAR LV_APRIO.
    SELECT SINGLE APRIO INTO LV_APRIO FROM AFKO
                                       WHERE AUFNR EQ GT_AFKO-AUFNR.
* 해당 우선 순위는 전송 제외
    IF LV_APRIO = '6' OR LV_APRIO = '7' OR LV_APRIO = '8' OR LV_APRIO = '9'.
    ELSE.
* 초과 입고 or 실적
      IF GT_AFKO-AUFNR_E IS NOT INITIAL.
        APPEND GT_AFKO TO GT_AFKO3.
        APPEND GT_AFKO TO GT_AFKO4.
      ENDIF.
* 지연 정보
      IF GT_AFKO-GISTAT EQ ICON_LED_RED OR "투입상태
        GT_AFKO-CFSTAT EQ ICON_LED_RED OR "실적상태
        GT_AFKO-GRSTAT EQ ICON_LED_RED. "입고상태

        APPEND GT_AFKO TO GT_AFKO2.
        APPEND GT_AFKO TO GT_AFKO4.

      ENDIF.
*- Start 2025.05.14
* 현재일자가 Workiing Day 기준 말일과 같다면 마감 점검 데이터 취합
      IF GV_OK EQ ABAP_TRUE. "오더 미종료, 입고&실적 상태 빨간색 or 노란색
* 품목별 입고수량 합산
        CLEAR GT_AFKO5.
        READ TABLE GT_AFKO5 WITH KEY PROCD = GT_AFKO-PROCD
                                     ARBPL = GT_AFKO-ARBPL
                                     AUFNR = GT_AFKO-AUFNR.
        IF SY-SUBRC <> 0.

          MOVE-CORRESPONDING GT_AFKO TO GT_AFKO5.
* 오더 입고 상태 : 빨간색 or 노란색
          IF GT_AFKO-GRSTAT EQ ICON_LED_RED OR
            GT_AFKO-GRSTAT EQ ICON_LED_YELLOW.
            GT_AFKO5-REASON = TEXT-078. " 입고수량 누락
* 오더 실적 상태 : 빨간색 or 실적 상태 : 노란색, 종료 상태 : 초록색
          ELSEIF GT_AFKO-CFSTAT EQ ICON_LED_RED OR
            ( GT_AFKO-CFSTAT EQ ICON_LED_YELLOW AND
             GT_AFKO-CLOSE EQ ICON_LED_GREEN ).
            GT_AFKO5-REASON = TEXT-079. " 입고수량 대비 실적수량 누락
* 오더 종료 상태 : 노란색, 실적상태 : 노란색
*        ELSEIF gt_afko-sttxt = TEXT-042 OR " 작업완료 처리대상
*          gt_afko-sttxt = TEXT-043. " 입고완료 처리대상
          ELSEIF GT_AFKO-CLOSE EQ ICON_LED_YELLOW AND
                GT_AFKO-CFSTAT EQ ICON_LED_YELLOW.
            GT_AFKO5-REASON = TEXT-080. " 오더 종료 미처리
* 오더 입고 상태 : 빈 값, 실적 상태 : 빈 값, 작업 상태 : 작업 중
          ELSEIF GT_AFKO-GRSTAT IS INITIAL AND
            GT_AFKO-CFSTAT IS INITIAL AND
            GT_AFKO-STTXT = TEXT-044.
            GT_AFKO5-REASON = TEXT-044. " 작업 중
          ENDIF.

          IF GT_AFKO5-REASON IS NOT INITIAL.
            APPEND GT_AFKO5.
          ENDIF.

        ELSE.

          GT_AFKO5-WEMNG = GT_AFKO5-WEMNG + GT_AFKO-WEMNG.
          GT_AFKO5-PSMNG = GT_AFKO5-PSMNG + GT_AFKO-PSMNG.
          MODIFY GT_AFKO5 INDEX SY-TABIX.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.
* 초과 입고 or 실적, 지연 정보 메일 전송
  IF GT_AFKO4[] IS NOT INITIAL.
    PERFORM SEND_MAIL_OVER_IPGO_DELAY.
  ENDIF.
* 마감 점검 메일 전송
  IF GT_AFKO5[] IS NOT INITIAL.
    SORT GT_AFKO5 BY PROCD ARBPL AUFNR.
    PERFORM SEND_MAIL_CHECK_FINISH_ORDER.
  ENDIF.
*- End 2025.05.14

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calcurate_datetime
*&---------------------------------------------------------------------*
FORM CALCURATE_DATETIME USING PV_CPUDT PV_CPUTM.

  DATA : LV_TDIFF    LIKE  TVRO-FAHZTD,
         LV_NUM(8)   TYPE N,
         LV_DAY(6),
         LV_DAY2(3),
         LV_DAY3(3),
         LV_HOUR(4),
         LV_HOUR2(2),
         LV_MIN(2).

*PV_CPUDT가 비어 있는 경우 오더의 계획시작일로 대체 20260220 ZGODEV03
  IF PV_CPUDT IS INITIAL.
    PV_CPUDT = GT_AFKO-GSTRS.
    PV_CPUTM = GT_AFKO-GSUZS.
  ENDIF.
*PV_CPUDT가 비어 있는 경우 오더의 계획시작일로 대체 20260220 ZGODEV03

  CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
    EXPORTING
      I_DATE1 = SY-DATUM
      I_TIME1 = SY-UZEIT
      I_DATE2 = PV_CPUDT
      I_TIME2 = PV_CPUTM
    IMPORTING
      E_TDIFF = LV_TDIFF.

  LV_NUM = LV_TDIFF.
* 처음  4자리 : hour. 그 다음 2자리 : min. 나머지 2자리 : sec
  LV_DAY = LV_NUM+0(4) / 24.
  CONDENSE LV_DAY NO-GAPS.

  SPLIT LV_DAY AT '.' INTO LV_DAY2 LV_DAY3. "일자 계산

  LV_HOUR = LV_DAY2 * 24.

  LV_HOUR2 = LV_NUM+0(4) - LV_HOUR. "시간 계산
  CONDENSE LV_HOUR2 NO-GAPS.

  CONCATENATE LV_DAY2 TEXT-T05 LV_HOUR2 TEXT-T06
                  INTO GT_AFKO-DEL_TIME SEPARATED BY SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_select_proc
*&---------------------------------------------------------------------*
FORM GET_DATA_SELECT_PROC .

  CLEAR : GT_AFKO_S, GT_AFKO_S[].
  IF SY-BATCH NE 'X'.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS, A~DISPO,
           A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT, C~MATNR, C~DAUAT,
           C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN, C~CUOBJ, C~POSNR, C~PWERK,
           C~PSAMG, D~VORNR, D~STEUS, E~ARBPL, F~MATKL, F~ZZCOLOR_BASE,
           F~ZZIDEN_CODE, F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A INNER JOIN AUFK AS B
                             ON A~AUFNR = B~AUFNR
                     INNER JOIN AFPO AS C
                             ON A~AUFNR = C~AUFNR
                     INNER JOIN AFVC AS D
                             ON A~AUFPL = D~AUFPL
                     INNER JOIN CRHD AS E
                             ON D~ARBID = E~OBJID
                            AND E~OBJTY = 'A'
                            AND E~WERKS = @P_PWERK
                     INNER JOIN MARA AS F
                             ON C~MATNR = F~MATNR
                     INNER JOIN MAKT AS G
                             ON C~MATNR = G~MATNR
*- Start 2025.05.20
                     LEFT OUTER JOIN ZGTPPT2010 AS H
                                  ON A~AUFNR = H~ORDNR
                                 AND H~ORDTY ='PRD'
*- End 2025.05.20
       UP TO @P_DBCNT ROWS BYPASSING BUFFER
       WHERE A~DISPO   IN  @S_DISPO
         AND A~AUFNR   IN  @S_AUFNR
*&      AND a~plnnr  IN  s_plnnr
         AND A~GSTRS   IN  @S_GSTRS
         AND A~FTRMI   IN  @S_FTRMI
         AND A~APRIO   IN  @S_APRIO
         AND (GT_WTAB)
         AND C~PWERK   EQ @P_PWERK
         AND C~MATNR   IN  @S_MATNR
         AND C~DAUAT   IN  @S_DAUAT
         AND C~XLOEK   EQ @SPACE
         AND C~KDAUF   IN  @S_KDAUF
         AND C~KDPOS   IN  @S_KDPOS
         AND D~STEUS   NE  'ZP03'
*&     AND d~plnfl    IN ('','000000')      "순서
         AND D~APLFL   IN ('','000000' )   "순서
         AND E~ARBPL   IN @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
         AND F~MATKL   LIKE @GV_MATKL      "자재그룹
         AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
         AND H~GRPNR   IN @S_GRPNR.
*- End 2025.05.20

  ELSE.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS,
           A~DISPO, A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT,
           C~MATNR, C~DAUAT, C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN,
           C~CUOBJ, C~POSNR, C~PWERK, C~PSAMG, D~VORNR, D~STEUS,
           E~ARBPL, F~MATKL, F~ZZCOLOR_BASE, F~ZZIDEN_CODE,
           F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A INNER JOIN AUFK AS B
                             ON A~AUFNR = B~AUFNR
                     INNER JOIN AFPO AS C
                             ON A~AUFNR = C~AUFNR
                     INNER JOIN AFVC AS D
                             ON A~AUFPL = D~AUFPL
                     INNER JOIN CRHD AS E
                             ON D~ARBID = E~OBJID
                            AND E~OBJTY = 'A'
                            AND E~WERKS = @P_PWERK
                     INNER JOIN MARA AS F
                             ON C~MATNR = F~MATNR
                     INNER JOIN MAKT AS G
                             ON C~MATNR = G~MATNR
*- Start 2025.05.20
                     LEFT OUTER JOIN ZGTPPT2010 AS H
                                  ON A~AUFNR = H~ORDNR
                                 AND H~ORDTY ='PRD'
*- End 2025.05.20
      WHERE A~DISPO   IN  @S_DISPO
        AND A~AUFNR   IN  @S_AUFNR
*&     AND a~plnnr  IN  s_plnnr
        AND A~GSTRS   IN  @S_GSTRS
        AND A~FTRMI   IN  @S_FTRMI
        AND A~APRIO   IN  @S_APRIO
        AND (GT_WTAB)
        AND C~PWERK   EQ @P_PWERK
        AND C~MATNR   IN  @S_MATNR
        AND C~DAUAT   IN  @S_DAUAT
        AND C~XLOEK   EQ @SPACE
        AND C~KDAUF   IN  @S_KDAUF
        AND C~KDPOS   IN  @S_KDPOS
        AND D~STEUS   NE  'ZP03'
*&     AND d~plnfl    IN ('','000000')      "순서
        AND D~APLFL   IN ('','000000' )   "순서
        AND E~ARBPL   IN @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
        AND F~MATKL   LIKE @GV_MATKL      "자재그룹
        AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
        AND H~GRPNR   IN @S_GRPNR.
*- End 2025.05.20
  ENDIF.
**- Start 2025.05.12
** 조회조건 : 조장구성표 추가 체크
*  IF s_grpnr[] IS NOT INITIAL.
*    PERFORM check_zgtppt2010.
*  ENDIF.
**- End 2025.05.12
* 정확한 일자 반영을 위한 추가 데이터 취합
  PERFORM GET_NEW_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_select_proc1
*&---------------------------------------------------------------------*
FORM GET_DATA_SELECT_PROC1 .

  IF SY-BATCH NE 'X'.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS, A~DISPO,
           A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT, C~MATNR, C~DAUAT,
           C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN, C~CUOBJ, C~POSNR, C~PWERK,
           C~PSAMG, D~VORNR, D~STEUS, E~ARBPL, F~MATKL, F~ZZCOLOR_BASE,
           F~ZZIDEN_CODE, F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A  INNER JOIN AUFK AS B
                              ON A~AUFNR = B~AUFNR
                      INNER JOIN AFPO AS C
                              ON A~AUFNR = C~AUFNR
                      INNER JOIN AFVC AS D
                              ON A~AUFPL = D~AUFPL
                      INNER JOIN CRHD AS E
                                ON D~ARBID = E~OBJID
                               AND E~OBJTY = 'A'
                               AND E~WERKS = @P_PWERK
                      INNER JOIN MARA AS F
                              ON C~MATNR = F~MATNR
                      INNER JOIN MAKT AS G
                              ON C~MATNR = G~MATNR
*- Start 2025.05.20
                      LEFT OUTER JOIN ZGTPPT2010 AS H
                                   ON A~AUFNR = H~ORDNR
                                  AND H~ORDTY ='PRD'
*- End 2025.05.20
         UP TO @P_DBCNT ROWS BYPASSING BUFFER
         WHERE A~DISPO   IN  @S_DISPO
           AND A~AUFNR   IN  @S_AUFNR
*&     AND a~plnnr  IN  s_plnnr
           AND A~GSTRS   IN  @S_GSTRS
           AND A~FTRMI   IN  @S_FTRMI
           AND A~APRIO   IN  @S_APRIO
           AND (GT_WTAB)
           AND C~PWERK   EQ  @P_PWERK
           AND C~MATNR   IN  @S_MATNR
           AND C~DAUAT   IN  @S_DAUAT
           AND C~XLOEK   EQ  @SPACE
           AND C~KDAUF   IN  @S_KDAUF
           AND C~KDPOS   IN  @S_KDPOS
*&     AND d~plnfl    IN ('','000000')      "순서
           AND D~APLFL   IN ('','000000' )   "순서
           AND D~STEUS   NE 'ZP03'
           AND E~ARBPL   IN  @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
           AND F~MATKL   LIKE  @GV_MATKL      "자재그룹
           AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
           AND H~GRPNR   IN @S_GRPNR
*- End 2025.05.20
           AND NOT EXISTS ( SELECT AUFNR FROM ZPPT0138
                             WHERE AUFNR = A~AUFNR ).

  ELSE.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS,
           A~DISPO, A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT,
           C~MATNR, C~DAUAT, C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN,
           C~CUOBJ, C~POSNR, C~PWERK, C~PSAMG, D~VORNR, D~STEUS,
           E~ARBPL, F~MATKL, F~ZZCOLOR_BASE, F~ZZIDEN_CODE,
           F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A INNER JOIN AUFK AS B
                             ON A~AUFNR = B~AUFNR
                     INNER JOIN AFPO AS C
                             ON A~AUFNR = C~AUFNR
                     INNER JOIN AFVC AS D
                             ON A~AUFPL = D~AUFPL
                     INNER JOIN CRHD AS E
                             ON D~ARBID = E~OBJID
                            AND E~OBJTY = 'A'
                            AND E~WERKS = @P_PWERK
                     INNER JOIN MARA AS F
                             ON C~MATNR = F~MATNR
                     INNER JOIN MAKT AS G
                             ON C~MATNR = G~MATNR
*- Start 2025.05.20
                     LEFT OUTER JOIN ZGTPPT2010 AS H
                                  ON A~AUFNR = H~ORDNR
                                 AND H~ORDTY ='PRD'
*- End 2025.05.20
      WHERE A~DISPO   IN  @S_DISPO
        AND A~AUFNR   IN  @S_AUFNR
*&     AND a~plnnr  IN  s_plnnr
        AND A~GSTRS   IN  @S_GSTRS
        AND A~FTRMI   IN  @S_FTRMI
        AND A~APRIO   IN  @S_APRIO
        AND (GT_WTAB)
        AND C~PWERK   EQ  @P_PWERK
        AND C~MATNR   IN  @S_MATNR
        AND C~DAUAT   IN  @S_DAUAT
        AND C~XLOEK   EQ  @SPACE
        AND C~KDAUF   IN  @S_KDAUF
        AND C~KDPOS   IN  @S_KDPOS
*&     AND d~plnfl    IN ('','000000')      "순서
        AND D~APLFL   IN ('','000000' )   "순서
        AND D~STEUS   NE 'ZP03'
        AND E~ARBPL   IN  @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
        AND F~MATKL   LIKE  @GV_MATKL      "자재그룹
        AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
        AND H~GRPNR   IN @S_GRPNR
*- End 2025.05.20
        AND NOT EXISTS ( SELECT AUFNR FROM ZPPT0138
                          WHERE AUFNR = A~AUFNR ).

  ENDIF.
**- Start 2025.05.12
** 조회조건 : 조장구성표 추가 체크
*  IF s_grpnr[] IS NOT INITIAL.
*    PERFORM check_zgtppt2010.
*  ENDIF.
**- End 2025.05.12
* 정확한 일자 반영을 위한 추가 데이터 취합
  PERFORM GET_NEW_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_select_proc2
*&---------------------------------------------------------------------*
FORM GET_DATA_SELECT_PROC2 .

  IF SY-BATCH NE 'X'.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS, A~DISPO,
           A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT, C~MATNR, C~DAUAT,
           C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN, C~CUOBJ, C~POSNR, C~PWERK,
           C~PSAMG, D~VORNR, D~STEUS, E~ARBPL, F~MATKL, F~ZZCOLOR_BASE,
           F~ZZIDEN_CODE, F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A INNER JOIN AUFK AS B
                             ON A~AUFNR = B~AUFNR
                     INNER JOIN AFPO AS C
                             ON A~AUFNR = C~AUFNR
                     INNER JOIN AFVC AS D
                             ON A~AUFPL = D~AUFPL
                     INNER JOIN CRHD AS E
                             ON D~ARBID = E~OBJID
                            AND E~OBJTY = 'A'
                            AND E~WERKS = @P_PWERK
                     INNER JOIN MARA AS F
                             ON C~MATNR = F~MATNR
                     INNER JOIN MAKT AS G
                             ON C~MATNR = G~MATNR
*- Start 2025.05.20
                     LEFT OUTER JOIN ZGTPPT2010 AS H
                                  ON A~AUFNR = H~ORDNR
                                 AND H~ORDTY ='PRD'
*- End 2025.05.20
       UP TO @P_DBCNT ROWS BYPASSING BUFFER
       WHERE A~DISPO   IN  @S_DISPO
         AND A~AUFNR   IN  @S_AUFNR
*&     AND a~plnnr  IN  s_plnnr
         AND A~GSTRS   IN  @S_GSTRS
         AND A~FTRMI   IN  @S_FTRMI
         AND A~APRIO   IN  @S_APRIO
         AND (GT_WTAB)
         AND C~PWERK   EQ  @P_PWERK
         AND C~MATNR   IN  @S_MATNR
         AND C~DAUAT   IN  @S_DAUAT
         AND C~XLOEK   EQ  @SPACE
         AND C~KDAUF   IN  @S_KDAUF
         AND C~KDPOS   IN  @S_KDPOS
*&     AND d~plnfl    IN ('','000000')      "순서
         AND D~APLFL   IN ('','000000' )   "순서
         AND D~STEUS   NE 'ZP03'
         AND E~ARBPL   IN  @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
         AND F~MATKL   LIKE  @GV_MATKL      "자재그룹
         AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
         AND H~GRPNR   IN @S_GRPNR.
*- End 2025.05.20
  ELSE.

    SELECT DISTINCT
           A~AUFNR, A~FTRMI, A~GSTRS, A~GLTRS, A~GSUZS, A~GLUZS,
           A~DISPO, A~APRIO, A~IGMNG, B~OBJNR, B~AUTYP, B~LTEXT,
           C~MATNR, C~DAUAT, C~KDAUF, C~KDPOS, C~PSMNG, C~AMEIN,
           C~CUOBJ, C~POSNR, C~PWERK, C~PSAMG, D~VORNR, D~STEUS,
           E~ARBPL, F~MATKL, F~ZZCOLOR_BASE, F~ZZIDEN_CODE,
           F~ZZMAKTX80, F~ZZCOLOR_STRIPE, G~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFKO
      FROM AFKO AS A INNER JOIN AUFK AS B
                             ON A~AUFNR = B~AUFNR
                     INNER JOIN AFPO AS C
                             ON A~AUFNR = C~AUFNR
                     INNER JOIN AFVC AS D
                             ON A~AUFPL = D~AUFPL
                     INNER JOIN CRHD AS E
                             ON D~ARBID = E~OBJID
                            AND E~OBJTY = 'A'
                            AND E~WERKS = @P_PWERK
                     INNER JOIN MARA AS F
                             ON C~MATNR = F~MATNR
                     INNER JOIN MAKT AS G
                             ON C~MATNR = G~MATNR
*- Start 2025.05.20
                     LEFT OUTER JOIN ZGTPPT2010 AS H
                                  ON A~AUFNR = H~ORDNR
                                 AND H~ORDTY ='PRD'
*- End 2025.05.20
      WHERE A~DISPO   IN  @S_DISPO
        AND A~AUFNR   IN  @S_AUFNR
*&     AND a~plnnr  IN  s_plnnr
        AND A~GSTRS   IN  @S_GSTRS
        AND A~FTRMI   IN  @S_FTRMI
        AND A~APRIO   IN  @S_APRIO
        AND (GT_WTAB)
        AND C~PWERK   EQ  @P_PWERK
        AND C~MATNR   IN  @S_MATNR
        AND C~DAUAT   IN  @S_DAUAT
        AND C~XLOEK   EQ  @SPACE
        AND C~KDAUF   IN  @S_KDAUF
        AND C~KDPOS   IN  @S_KDPOS
*&     AND d~plnfl    IN ('','000000')      "순서
        AND D~APLFL   IN ('','000000' )   "순서
        AND D~STEUS   NE 'ZP03'
        AND E~ARBPL   IN  @S_ARBPL
*     AND e~objty    EQ 'A'            "작업장
        AND F~MATKL   LIKE  @GV_MATKL      "자재그룹
        AND G~SPRAS   EQ  @SY-LANGU
*- Start 2025.05.20
        AND H~GRPNR   IN @S_GRPNR.
*- End 2025.05.20
  ENDIF.
**- Start 2025.05.12
** 조회조건 : 조장구성표 추가 체크
*  IF s_grpnr[] IS NOT INITIAL.
*    PERFORM check_zgtppt2010.
*  ENDIF.
**- End 2025.05.12
* 정확한 일자 반영을 위한 추가 데이터 취합
  PERFORM GET_NEW_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_teco_order
*&---------------------------------------------------------------------*
FORM PROCESS_TECO_ORDER .

  DATA : LV_ERROR,
         LV_TEXT(100),
         LV_MONTH     LIKE ISELLIST-MONTH,
         LV_MONTH2    LIKE ISELLIST-MONTH,
         LV_SUBRC     LIKE SY-SUBRC,
         LV_BUDAT     LIKE SY-DATUM.
  DATA : LV_DATUM LIKE SY-DATUM.
  DATA : LV_OK.
  DATA : LV_AUFNR LIKE AFKO-AUFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].
*- 데이터 선택 여부 체크
  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
    EXIT.
  ENDIF.

  CLEAR LV_ERROR.
  LOOP AT ROW_TABLE.

    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.
*- 오더의 상태가 작업지시전(A), 작업대기(B), 작업완료(D), 오더 종료(E)는 한 건이라도 선택시 수행 불가.
    IF GT_AFKO-STTXT = TEXT-039 OR GT_AFKO-STTXT = TEXT-040 OR GT_AFKO-STTXT = TEXT-002 OR
      GT_AFKO-STTXT = TEXT-041.

      LV_ERROR = 'X'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GT_AFKO-AUFNR
        IMPORTING
          OUTPUT = GT_AFKO-AUFNR.
      CONCATENATE TEXT-070 GT_AFKO-AUFNR TEXT-071 GT_AFKO-STTXT TEXT-072
                      INTO LV_TEXT SEPARATED BY SPACE.
      MESSAGE W001 WITH LV_TEXT.
      EXIT.

    ENDIF.

  ENDLOOP.

  CHECK LV_ERROR IS INITIAL.
*- 걸리는 건이 없으면 날짜 입력 받은 후 오더 종료 처리 수행
*- Start 2025.02.13 전월이나 현재월 아니면 에러메시지 출력
  CLEAR LV_OK.
  DO.

    CLEAR : LV_MONTH, LV_MONTH2, LV_SUBRC, LV_BUDAT.
    LV_MONTH = SY-DATUM+0(6).
    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        ACTUAL_MONTH               = LV_MONTH
        FACTORY_CALENDAR           = ' '
        HOLIDAY_CALENDAR           = ' '
        LANGUAGE                   = SY-LANGU
        START_COLUMN               = 8
        START_ROW                  = 5
      IMPORTING
        SELECTED_MONTH             = LV_MONTH2
        RETURN_CODE                = LV_SUBRC
      EXCEPTIONS
        FACTORY_CALENDAR_NOT_FOUND = 1
        HOLIDAY_CALENDAR_NOT_FOUND = 2
        MONTH_NOT_FOUND            = 3
        OTHERS                     = 4.
* 해당 값이 비어있으면 취소한 것이므로 빠져나올 것
    IF LV_MONTH2 IS INITIAL.
      EXIT.
    ELSE.
* 전월 취합
      CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
        EXPORTING
          MONTHS  = '-1'
          OLDDATE = SY-DATUM
        IMPORTING
          NEWDATE = LV_DATUM.

      IF LV_MONTH2+0(6) EQ SY-DATUM+0(6) "현재월 체크
        OR LV_MONTH2+0(6) EQ LV_DATUM+0(6). "전월 체크   .
        LV_OK = 'X'.
* 입력 월을 확인하여 현재월일 경우 현재일자, 아닐 경우 전월 마지막 일자 반영
        IF LV_MONTH2+0(6) EQ LV_DATUM+0(6).
          CONCATENATE LV_MONTH2+0(6) '01' INTO LV_BUDAT.
          CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
            EXPORTING
              DAY_IN            = LV_BUDAT
            IMPORTING
              LAST_DAY_OF_MONTH = LV_BUDAT
            EXCEPTIONS
              DAY_IN_NO_DATE    = 1
              OTHERS            = 2.
        ELSE.
          LV_BUDAT = SY-DATUM.
        ENDIF.

      ELSE.
        MESSAGE I001 DISPLAY LIKE 'E' WITH TEXT-E01.
      ENDIF.

      IF LV_OK = 'X'.
        EXIT.
      ENDIF.

    ENDIF.

  ENDDO.

  CHECK LV_BUDAT IS NOT INITIAL.
*- End 2025.02.13
*- CONF 처리 -> 배치 생성(GR_ZERO1) -> 0 입고(DLV) 수행
  CLEAR : GS_INFO2, GT_INFO2.
  LOOP AT ROW_TABLE.

    CLEAR : GT_AFKO, GV_CASE, GV_CASE2, GS_INFO2.
    READ TABLE GT_AFKO INDEX ROW_TABLE-INDEX.
    PERFORM COMPLETE_TECO_ORDER USING LV_BUDAT.
    IF GV_CASE EQ 'X'. "입고 상태
      GT_AFKO-GRSTAT = ICON_LED_GREEN.
    ENDIF.

    IF GV_CASE2 EQ 'X'. "실적 상태
      GT_AFKO-CFSTAT = ICON_LED_GREEN.
    ENDIF.

    IF GT_AFKO-GRSTAT = ICON_LED_GREEN AND GT_AFKO-CFSTAT = ICON_LED_GREEN. "작업 상태
      GT_AFKO-CLOSE = ICON_LED_GREEN.
      GT_AFKO-STTXT = TEXT-002.
    ENDIF.

*- 투입 Status Check
    PERFORM CHECK_GI_STATUS.
*- 지연 시간, 지연 구분
    PERFORM UPDATE_DELAY_TYPE_AND_TIME.

    MODIFY GT_AFKO INDEX ROW_TABLE-INDEX.
    APPEND GS_INFO2 TO GT_INFO2.
* 제대로 처리되었으면 해당 오더 기준으로 다른 품목번호의 입고상태 업데이트
    IF GV_CASE EQ 'X'. "입고 상태
      LV_AUFNR = GT_AFKO-AUFNR.
      LOOP AT GT_AFKO WHERE AUFNR EQ LV_AUFNR.
        GT_AFKO-GRSTAT = ICON_LED_GREEN.
        GT_AFKO-CLOSE = ICON_LED_GREEN.
        GT_AFKO-STTXT = TEXT-002.
        MODIFY GT_AFKO.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
*- 에러 건 있으면 팝업으로 출력
  IF GT_INFO2[] IS NOT INITIAL.
    CALL SCREEN 0102 STARTING AT 2 2 ENDING AT 90 20.
  ENDIF.
*- 데이터 REFRESH
  PERFORM REFRESH_GT_AFKO_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMPLETE_TECO_ORDER
*&---------------------------------------------------------------------*
FORM COMPLETE_TECO_ORDER USING PV_BUDAT.

  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
*- Start 2025.02.12
* 오더 상태값을 체크하여 'CNF'가 있을 경우 패스
  CLEAR GS_STATUS.
  READ TABLE GT_STATUS INTO GS_STATUS WITH KEY AUFNR = GT_AFKO-AUFNR
                                                                           TXT04 = 'CNF'.
  IF GS_STATUS IS INITIAL.

    CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.
    SELECT SINGLE B~RUECK INTO @DATA(LV_RUECK)
                    FROM AFKO AS A INNER JOIN AFVC AS B
                        ON A~AUFPL EQ B~AUFPL
                        WHERE A~AUFNR  EQ @GT_AFKO-AUFNR
                             AND B~VORNR EQ @GT_AFKO-VORNR
                             AND B~APLFL   EQ '000000'.

    LT_TT = VALUE #( ( CONF_NO     = LV_RUECK
                              ORDERID      = GT_AFKO-AUFNR
                              OPERATION   = GT_AFKO-VORNR
                              WORK_CNTR   = GT_AFKO-ARBPL
                              POSTG_DATE = PV_BUDAT
                              PLANT           = GT_AFKO-WERKS
                              FIN_CONF       = 'X'
                              CLEAR_RES    = 'X'
                        ) ).
*- 생산 실적 처리 (최종 확정 처리)
    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
      IMPORTING
        RETURN         = LS_RETURN
      TABLES
        TIMETICKETS    = LT_TT
        GOODSMOVEMENTS = LT_GOODS
        DETAIL_RETURN  = LT_DETAIL.
*- 성공
    IF LS_RETURN IS INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      PERFORM APPEND_TEXT USING TEXT-M12 ICON_LED_GREEN.
      GV_CASE = 'X'.
*-  제대로 처리되었을 경우 재처리 방지를 위해 상태값 'CNF' 추가
      GS_STATUS-AUFNR = GT_AFKO-AUFNR.
      GS_STATUS-TXT04  = 'CNF'.
      APPEND GS_STATUS TO GT_STATUS.
*- 실패
    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                         OR  TYPE = 'E'
                                         OR  TYPE = 'X'.

        PERFORM APPEND_TEXT USING LS_DETAIL-MESSAGE ICON_LED_RED.
        EXIT.

      ENDLOOP.

    ENDIF.

  ELSE.

    GV_CASE = 'X'.
    PERFORM APPEND_TEXT USING TEXT-M15 ICON_LED_GREEN.

  ENDIF.
*- End 2025.02.12
*- 확정성공시 생산오더 입고 종료/취소
  IF GV_CASE = 'X'.
    PERFORM BAPI_BATCH_CREATE USING PV_BUDAT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_batch_create
*&---------------------------------------------------------------------*
FORM BAPI_BATCH_CREATE USING PV_BUDAT.

  DATA : LV_BATCH TYPE MCHA-CHARG VALUE 'GR_ZERO1'.
  DATA : LV_CLASS TYPE KLAH-CLASS.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2,
         LS_ATTR   TYPE BAPIBATCHATT,
         LS_CTRL   TYPE BAPIBATCHCTRL.
  DATA : LV_MESSAGE TYPE BAPIRET2-MESSAGE.
  DATA : LV_MATNR   TYPE MARA-MATNR.
  DATA : LV_LGORT LIKE AFPO-LGORT.
* 오더 상태값을 체크하여 'DLV가 있을 경우 패스
  CLEAR GS_STATUS.
  READ TABLE GT_STATUS INTO GS_STATUS WITH KEY AUFNR = GT_AFKO-AUFNR
                                                                           TXT04 = 'DLV'.
  IF GS_STATUS IS INITIAL.

    CLEAR: LV_MESSAGE.
    CLEAR: LV_CLASS, LT_RETURN, LS_ATTR, LS_CTRL.
    SELECT SINGLE CHARG
      INTO @DATA(LV_CHARG)
      FROM MCHA
     WHERE MATNR = @GT_AFKO-MATNR
       AND WERKS = @GT_AFKO-WERKS
       AND CHARG = @LV_BATCH.
    "배치생성
    IF SY-SUBRC <> 0.

      CLEAR : LV_MATNR, LV_LGORT.
      LV_MATNR = GT_AFKO-MATNR.
      SELECT SINGLE LGORT INTO LV_LGORT FROM AFPO
                                       WHERE AUFNR  EQ GT_AFKO-AUFNR
                                            AND POSNR EQ '0001'.
      CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
        EXPORTING
          MATERIAL           = LV_MATNR
          PLANT              = GT_AFKO-WERKS
          CLASSTYPE          = '023'
        IMPORTING
          CLASS              = LV_CLASS
        EXCEPTIONS
          NO_CLASS_FOUND     = 1
          NO_CLASSTYPE_FOUND = 2
          OTHERS             = 3.

      LS_ATTR-STATUSKEY = '1'.
      LS_CTRL = VALUE #( CLASS_NUM = LV_CLASS
                                  DOCLASSIFY = 'X' ).
      CALL FUNCTION 'BAPI_BATCH_CREATE'
        EXPORTING
          MATERIAL             = CONV MATNR18( GT_AFKO-MATNR )
          BATCH                = LV_BATCH
          PLANT                = GT_AFKO-WERKS
          BATCHATTRIBUTES      = LS_ATTR
          BATCHCONTROLFIELDS   = LS_CTRL
          BATCHSTORAGELOCATION = LV_LGORT
        TABLES
          RETURN               = LT_RETURN.

      IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
        PERFORM APPEND_TEXT USING LV_MESSAGE ICON_LED_RED.
        EXIT.

      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        PERFORM APPEND_TEXT USING TEXT-M13 ICON_LED_GREEN.

      ENDIF.

    ELSE.

      PERFORM APPEND_TEXT USING TEXT-M16 ICON_LED_GREEN.

    ENDIF.

    CALL FUNCTION 'DEQUEUE_EMMARCE'
      EXPORTING
        MATNR = GT_AFKO-MATNR
        WERKS = GT_AFKO-WERKS.
*- Start 2025.02.12
    "ZERO 입고처리 및 DLV 확정처리
    PERFORM BAPI_ZERO_GOODSMVT_CREATE USING LV_BATCH PV_BUDAT LV_LGORT.

  ELSE.

    PERFORM APPEND_TEXT USING TEXT-M17 ICON_LED_GREEN.

  ENDIF.
*- End 2025.02.12
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_zero_goodsmvt_create
*&---------------------------------------------------------------------*
FORM BAPI_ZERO_GOODSMVT_CREATE USING PV_BATCH PV_BUDAT PV_LGORT.

  DATA: LS_HEADER   TYPE BAPI2017_GM_HEAD_01,
        LV_CODE     TYPE BAPI2017_GM_CODE VALUE '02',
        LV_DOCUMENT TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR     TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LV_MESSAGE  TYPE BAPIRET2-MESSAGE,
        LT_ITEM     TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
        LT_RET      TYPE TABLE OF BAPIRET2,
        LS_RET      TYPE BAPIRET2.

*  DATA : lv_elikz LIKE afpo-elikz.  " ADD BY HSY 20250107
  DATA : BEGIN OF LT_POSNR OCCURS 0,
           POSNR LIKE AFPO-POSNR,
         END OF LT_POSNR.

  CLEAR: LV_DOCUMENT, LV_YEAR, LT_RET, LV_MESSAGE.
  LS_HEADER = VALUE #( PSTNG_DATE = PV_BUDAT
                       DOC_DATE   = PV_BUDAT
                       HEADER_TXT = PV_BATCH ).  "전표 헤더 텍스트
  "선택 생산오더 기준 납품완료 확인
*  CLEAR lv_elikz.
*  SELECT SINGLE elikz " 납품 완료 지시자
*    INTO @lv_elikz
*    FROM afpo
*   WHERE aufnr EQ @gt_afko-aufnr
*    AND pwerk    EQ @gt_afko-werks
*    AND posnr    EQ @gt_afko-posnr
*    AND elikz       EQ 'X' .    "납품완료
  CLEAR : LT_POSNR, LT_POSNR[].
  SELECT POSNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_POSNR
    FROM AFPO
   WHERE AUFNR EQ @GT_AFKO-AUFNR
    AND PWERK   EQ @GT_AFKO-WERKS
    AND ELIKZ     EQ @SPACE .    "납품완료

*  IF lv_elikz <> 'X'. " 해당 생산오더의 품목이 납품 완료가 아니면 완료 진행
  IF LT_POSNR[] IS NOT INITIAL. "해당 값을 가져오면 품목 납품 완료가 안된 건이므로 처리

    LOOP AT LT_POSNR.

      APPEND VALUE #( MATERIAL   = GT_AFKO-MATNR          "입고자재
                      PLANT      = GT_AFKO-WERKS                  "플랜트
                      ORDERID    = GT_AFKO-AUFNR                  "생산오더
*                    order_itno = gt_afko-posnr "오더품목번호
                      ORDER_ITNO = LT_POSNR-POSNR "오더품목번호
                      MVT_IND    = 'F'                            "이동지시자
                      STCK_TYPE  = SPACE                          "재고 유형
                      NO_MORE_GR = 'X'                            "납품완료 지시자
                      MOVE_TYPE  = '101'                          "이동유형
                      STGE_LOC   = PV_LGORT  "입고창고
                      BATCH      = PV_BATCH                       "배치번호
                      ENTRY_QNT  = '0'                            "입고수량
                      ENTRY_UOM  = GT_AFKO-AMEIN         "입고단위
                    ) TO LT_ITEM.

    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LV_CODE
      IMPORTING
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RET.

    IF LINE_EXISTS( LT_RET[ TYPE = 'E' ] ).

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* 자재 락 에러일 경우 추가 5번 시도
      CLEAR LS_RET.
      READ TABLE LT_RET INTO LS_RET WITH KEY TYPE     = 'E'
                                                                 ID          = 'M3'
                                                                 NUMBER = '897'.
      IF LS_RET IS NOT INITIAL.

        DO 5 TIMES.

          CALL FUNCTION 'DEQUEUE_EMMARCE'
            EXPORTING
              MATNR = GT_AFKO-MATNR
              WERKS = GT_AFKO-WERKS.

          WAIT UP TO '0.5' SECONDS.

          CLEAR: LV_DOCUMENT, LV_YEAR, LS_RET, LT_RET, LV_MESSAGE.
          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
            EXPORTING
              GOODSMVT_HEADER  = LS_HEADER
              GOODSMVT_CODE    = LV_CODE
            IMPORTING
              MATERIALDOCUMENT = LV_DOCUMENT
              MATDOCUMENTYEAR  = LV_YEAR
            TABLES
              GOODSMVT_ITEM    = LT_ITEM
              RETURN           = LT_RET.

          IF LINE_EXISTS( LT_RET[ TYPE = 'E' ] ).

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            PERFORM APPEND_TEXT USING TEXT-M14 ICON_LED_GREEN.
            GV_CASE2 = 'X'.
            EXIT.

          ENDIF.

        ENDDO.
* 5번 시도 후 여전히 처리안됐을 경우 마지막 에러 메시지 반영
        IF GV_CASE2 IS INITIAL.

          LV_MESSAGE = VALUE #( LT_RET[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

          PERFORM APPEND_TEXT USING LV_MESSAGE ICON_LED_RED.
          EXIT.

        ENDIF.
* 일반 에러일 경우 바로 메시지 반영
      ELSE.

        LV_MESSAGE = VALUE #( LT_RET[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

        PERFORM APPEND_TEXT USING LV_MESSAGE ICON_LED_RED.
        EXIT.

      ENDIF.

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      PERFORM APPEND_TEXT USING TEXT-M14 ICON_LED_GREEN.
      GV_CASE2 = 'X'.

    ENDIF.

  ELSE.

    PERFORM APPEND_TEXT USING TEXT-M17 ICON_LED_GREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_text
*&---------------------------------------------------------------------*
FORM APPEND_TEXT USING PV_MESSAGE PV_ICON.

  DATA : LV_AUFNR LIKE GT_AFKO-AUFNR.

  IF GS_INFO2-TEXT IS INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO-AUFNR
      IMPORTING
        OUTPUT = LV_AUFNR.
    GS_INFO2-AUFNR = LV_AUFNR.
    GS_INFO2-ICON = PV_ICON.
    CONCATENATE TEXT-020 PV_MESSAGE INTO GS_INFO2-TEXT SEPARATED BY SPACE.

  ELSE.

    GS_INFO2-ICON = PV_ICON.
    CONCATENATE GS_INFO2-TEXT '//' PV_MESSAGE INTO GS_INFO2-TEXT
                            SEPARATED BY SPACE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_new_date
*&---------------------------------------------------------------------*
FORM GET_NEW_DATE .

  DATA : LV_TABIX LIKE SY-TABIX.

  CLEAR : GT_AFKO_S, GT_AFKO_S[], GS_CDSV, GT_CDSV.
* Payoff 일자가 선택조건에 부합한 오더 취합
  IF GT_AFKO[] IS NOT INITIAL.

    GT_AFKO_S[] = GT_AFKO[].
    SORT GT_AFKO_S BY OBJNR.
    DELETE ADJACENT DUPLICATES FROM GT_AFKO_S COMPARING OBJNR.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_CDSV
        FROM ISTATUSOBJSTSCHG
        FOR ALL ENTRIES IN @GT_AFKO_S
        WHERE STATUSOBJECT EQ @GT_AFKO_S-OBJNR
            AND STATUSCODE EQ 'E0001'
            AND STATUSISINACTIVE EQ @SPACE.

    SORT GT_CDSV BY STATUSOBJECT
                             LASTCHANGEDATE DESCENDING
                             LASTCHANGETIME DESCENDING.
    DELETE ADJACENT DUPLICATES FROM GT_CDSV COMPARING STATUSOBJECT.
    DELETE GT_CDSV WHERE LASTCHANGEDATE NOT IN S_PAYOFF.

  ENDIF.
* 작업시작일자(ISDD)가 선택조건에 부합하는 오더
* 해당 데이터는 가져오되 위의 Payoff 데이터가 없을 시에만 반영
  CLEAR : GT_AFKO_S, GT_AFKO_S[], GT_AFRU_MIN, GT_AFRU_MIN[], GT_AFRU_MAX, GT_AFRU_MAX[].
  IF GT_AFKO[] IS NOT INITIAL.

    GT_AFKO_S[] = GT_AFKO[].
    SORT GT_AFKO_S BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM GT_AFKO_S COMPARING AUFNR.

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_MIN
        FROM AFRU
        FOR ALL ENTRIES IN @GT_AFKO_S
        WHERE AUFNR EQ @GT_AFKO_S-AUFNR
             AND RMZHL EQ ( SELECT MIN( RMZHL ) FROM AFRU
                                          WHERE AUFNR EQ @GT_AFKO_S-AUFNR
                                               AND AUERU NE 'X'
                                               AND STOKZ EQ @SPACE
                                               AND STZHL EQ @SPACE ).
    DELETE GT_AFRU_MIN WHERE ISDD NOT IN S_PAYOFF.

    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_MAX
    FROM AFRU
    FOR ALL ENTRIES IN @GT_AFKO_S
    WHERE AUFNR EQ @GT_AFKO_S-AUFNR
         AND RMZHL EQ ( SELECT MAX( RMZHL ) FROM AFRU
                                      WHERE AUFNR EQ @GT_AFKO_S-AUFNR
                                           AND AUERU NE 'X'
                                           AND STOKZ EQ @SPACE
                                           AND STZHL EQ @SPACE ).
    DELETE GT_AFRU_MAX WHERE ISDD NOT IN S_PAYOFF.

    REFRESH GT_3300.
    SELECT * FROM ZGTPPT3300
      INTO CORRESPONDING FIELDS OF TABLE GT_3300
      FOR ALL ENTRIES IN GT_AFKO_S
     WHERE AUFNR = GT_AFKO_S-AUFNR
       AND EXCLUDE = ABAP_TRUE.

    SORT GT_3300 BY AUFNR.

  ENDIF.
* Payoff, AFRU에 없는 건은 제외
  IF S_PAYOFF[] IS NOT INITIAL.

    LOOP AT GT_AFKO.

      LV_TABIX = SY-TABIX.
* Payoff
      CLEAR GS_CDSV.
      READ TABLE GT_CDSV INTO GS_CDSV WITH KEY STATUSOBJECT = GT_AFKO-OBJNR.
      IF GS_CDSV IS INITIAL.
* AFRU
        CLEAR GT_AFRU_MIN.
        READ TABLE GT_AFRU_MIN WITH KEY AUFNR = GT_AFKO-AUFNR.
        IF SY-SUBRC <> 0.
          DELETE GT_AFKO INDEX LV_TABIX.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_email_send_log
*&---------------------------------------------------------------------*
FORM APPEND_EMAIL_SEND_LOG USING PS_AFKO LIKE GT_AFKO.

  CLEAR GS_ZGTPPT3240.
  GS_ZGTPPT3240-WERKS = PS_AFKO-WERKS. "플랜트
  GS_ZGTPPT3240-AUFNR = PS_AFKO-AUFNR. "오더번호
  GS_ZGTPPT3240-ALTUM = SY-DATUM. "알림전송일자
  GS_ZGTPPT3240-ALEIT = SY-UZEIT. "알림전송시간
  GS_ZGTPPT3240-TIMESTAMPL = GV_TIMESTAMP. "타임스탬프
* 사유
  IF PS_AFKO-IPGO = 'X'. "초과 입고
    GS_ZGTPPT3240-REASON = TEXT-021.
  ELSEIF PS_AFKO-SILJEOK = 'X'. " 초과 실적
    GS_ZGTPPT3240-REASON = TEXT-022.
  ELSEIF PS_AFKO-DELAY IS NOT INITIAL. "지연
    GS_ZGTPPT3240-REASON = TEXT-023.
    GS_ZGTPPT3240-DELAY = PS_AFKO-DELAY.
    GS_ZGTPPT3240-DEL_TIME = PS_AFKO-DEL_TIME.
  ENDIF.

  GS_ZGTPPT3240-PROCD = PS_AFKO-PROCD. "공정코드
  GS_ZGTPPT3240-DISPO = PS_AFKO-DISPO. "MRP관리자
  GS_ZGTPPT3240-ARBPL = PS_AFKO-ARBPL. "작업장
  GS_ZGTPPT3240-PERNR = GV_FLD_04. "설비담당자 사번
  GS_ZGTPPT3240-EMAIL_ID = GV_ADDRESS. "설비담당자 이메일주소
  APPEND GS_ZGTPPT3240 TO GT_ZGTPPT3240.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .
*& 각 Cell의 특성 제어
  DATA : LT_STYL     TYPE LVC_T_STYL,
         LT_SCOL     TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).
*- Start 2025.03.14
  DATA : LV_OK.
*- End 2025.03.14
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_TDNAME    LIKE STXH-TDNAME.
*- Start 2025.03.25
  DATA : LV_PSMNG LIKE GT_AFKO-PSMNG.
*- End 2025.03.25
*[U01] 가온전선 추가
  DATA : LV_WEMNG LIKE AFPO-WEMNG.   "입고수량sum
*[U01] 가온전선 추가

  CLEAR GT_FIELDCAT_0100[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3020TOP'
      I_INTERNAL_TABNAME     = 'GT_AFKO'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_AFKO
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'EXCLUD_GUID'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'EXCLUD_GUID'.
    <LS_FCAT>-COLTEXT = TEXT-F83.
    <LS_FCAT>-COL_POS = '25'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST      = 'C'. "비고
  ENDIF.

  CLEAR : GT_AFKO_S, GT_AFKO_S[],
*- Start 2025.04.16
          GS_PROD_CHAR, GT_PROD_CHAR.

  GT_AFKO_S[] = GT_AFKO[].
  SORT GT_AFKO_S BY WERKS AUFNR POSNR.
  DELETE ADJACENT DUPLICATES FROM GT_AFKO_S
                        COMPARING WERKS AUFNR POSNR.

  IF GT_AFKO_S[] IS NOT INITIAL.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_PROD_CHAR
      FROM ZGTCVORDSYVAL
      FOR ALL ENTRIES IN @GT_AFKO_S
      WHERE WERKS EQ @GT_AFKO_S-WERKS
        AND AUFNR EQ @GT_AFKO_S-AUFNR
        AND POSNR EQ @GT_AFKO_S-POSNR.

  ENDIF.
*- End 2025.04.16
  GT_AFKO_S[] = GT_AFKO[].
  LOOP AT GT_AFKO.

    CLEAR: LT_STYL[], LT_SCOL[].

    LV_INDEX = SY-TABIX.
* 먼저, Payoff 데이터에서 작업시작일, 시작시간 반영
    CLEAR GS_CDSV.
    READ TABLE GT_CDSV INTO GS_CDSV WITH KEY STATUSOBJECT = GT_AFKO-OBJNR.
    IF GS_CDSV IS NOT INITIAL.
      GT_AFKO-WORK_SD = GS_CDSV-LASTCHANGEDATE. "작업시작일
      GT_AFKO-WORK_ST = GS_CDSV-LASTCHANGETIME. "시작시간
    ELSE.
* 만약, Payoff 데이터가 없을 시에는 AFRU에서 취합한 데이터 반영
      CLEAR GT_AFRU_MIN.
      READ TABLE GT_AFRU_MIN WITH KEY AUFNR = GT_AFKO-AUFNR.
      IF SY-SUBRC = 0.
        GT_AFKO-WORK_SD = GT_AFRU_MIN-ISDD. "작업시작일
        GT_AFKO-WORK_ST = GT_AFRU_MIN-ISDZ. "시작시간
      ENDIF.
    ENDIF.
* 작업종료일, 종료시간 반영
    CLEAR GT_AFRU_MAX.
    READ TABLE GT_AFRU_MAX WITH KEY AUFNR = GT_AFKO-AUFNR.
    IF SY-SUBRC = 0.
      GT_AFKO-WORK_ED = GT_AFRU_MAX-IEDD. "작업시작일
      GT_AFKO-WORK_ET = GT_AFRU_MAX-IEDZ. "시작시간
    ENDIF.

    PERFORM CONTROL_STYLE CHANGING LT_STYL.
    PERFORM CONTROL_COLOR CHANGING LT_SCOL.

    CLEAR: GT_AFKO-T_STYL[], GT_AFKO-T_SCOL[].
    INSERT LINES OF LT_STYL   INTO TABLE GT_AFKO-T_STYL.
    INSERT LINES OF LT_SCOL   INTO TABLE GT_AFKO-T_SCOL.
*- Start 2025.02.21
* 시작업/시생산이면 투입 상태,지연 구분, 지연 시간 안 보이게
    IF GT_AFKO-APRIO = '6' OR GT_AFKO-APRIO = '7' OR GT_AFKO-APRIO = '8'
      OR GT_AFKO-APRIO = '9'.
      CLEAR : GT_AFKO-GISTAT, GT_AFKO-DELAY, GT_AFKO-DEL_TIME.
    ENDIF.
* 작업일보 유무
    REFRESH : LT_TLINES.
    CLEAR : LT_TLINES, LV_TDNAME.

    CONCATENATE GT_AFKO-WERKS GT_AFKO-MATKL+1(2) GT_AFKO-MATNR INTO LV_TDNAME.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID        = 'Z01'     "품목 텍스트 ID
        LANGUAGE  = SY-LANGU
        NAME      = LV_TDNAME
        OBJECT    = 'ZPP_MAT'    "자재코드 특기사항 오브젝트
      TABLES
        LINES     = LT_TLINES
      EXCEPTIONS
        NOT_FOUND = 01.

    SELECT REG_FMSG, REG_SMSG
      INTO TABLE @DATA(LT_3180)
      FROM ZGTPPT3180
      WHERE WERKS EQ @GT_AFKO-WERKS
        AND AUFNR EQ @GT_AFKO-AUFNR
        AND POSNR EQ @GT_AFKO-POSNR
        AND ZIFKEY EQ ( SELECT MAX( ZIFKEY ) FROM ZGTPPT3180
                                             WHERE WERKS EQ @GT_AFKO-WERKS
                                               AND AUFNR EQ @GT_AFKO-AUFNR
                                               AND POSNR EQ @GT_AFKO-POSNR ).

    CLEAR : GT_TEXTEDIT_LINES, GT_TEXTEDIT_LINES[].
    IF LT_3180[] IS NOT INITIAL.
      LOOP AT LT_3180 INTO DATA(LS_3180).
        LT_TLINES-TDLINE = LS_3180-REG_FMSG.
        APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
        LT_TLINES-TDLINE = LS_3180-REG_SMSG.
        APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
      ENDLOOP.
    ENDIF.

    IF GT_TEXTEDIT_LINES[] IS INITIAL.
      GT_AFKO-BUTTON2 = ICON_SPACE.
    ELSE.
      GT_AFKO-BUTTON2 = ICON_DISPLAY_NOTE.
    ENDIF.
*- End 2025.02.21
*- Start 2025.03.06 입고일자 필드 추가
    SELECT SINGLE MAX( BUDAT ) INTO GT_AFKO-BUDAT
                               FROM MATDOC
                               WHERE WERKS EQ P_PWERK
                                 AND AUFNR EQ GT_AFKO-AUFNR
                                 AND AUFPS EQ GT_AFKO-POSNR
                                 AND BWART EQ '101'
                                 AND CANCELLED EQ SPACE.
*- End 2025.03.06
*- Start 2025.03.25
    CLEAR: LV_PSMNG, LV_WEMNG.
    IF GT_AFKO-POSNR = '0001'.

*[U01] 가온전선 추가
      "% 계산로직 추가
      IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
        LOOP AT GT_AFKO_S WHERE AUFNR = GT_AFKO-AUFNR.
          LV_WEMNG = LV_WEMNG + GT_AFKO_S-WEMNG.
        ENDLOOP.

        IF LV_WEMNG NE 0 AND GT_AFKO-LMNGA NE 0.
          GT_AFKO-ZPER = GT_AFKO-LMNGA / LV_WEMNG * 100.
        ENDIF.
      ELSE.
*[U01] 가온전선 추가
        LOOP AT GT_AFKO_S WHERE AUFNR = GT_AFKO-AUFNR.
          LV_PSMNG = LV_PSMNG + GT_AFKO_S-PSMNG.
        ENDLOOP.

        IF LV_PSMNG NE 0 AND GT_AFKO-LMNGA NE 0.
          GT_AFKO-ZPER = GT_AFKO-LMNGA / LV_PSMNG * 100.
        ENDIF.

      ENDIF.  "[U01]

    ENDIF.
*- End 2025.03.25
*- Start 2025.04.16 생산 오더 특성값 추가 반영
    CLEAR GS_PROD_CHAR.
    READ TABLE GT_PROD_CHAR INTO GS_PROD_CHAR
                            WITH KEY WERKS = GT_AFKO-WERKS
                                     AUFNR = GT_AFKO-AUFNR
                                     POSNR = GT_AFKO-POSNR.
    IF GS_PROD_CHAR IS NOT INITIAL.
      MOVE-CORRESPONDING GS_PROD_CHAR TO GT_AFKO.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GT_AFKO-DMORD
        IMPORTING
          OUTPUT = GT_AFKO-DMORD.
    ENDIF.
*- End 2025.04.16
*[U01] 가온전선 추가
    "조장, 조장수 추출
    IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
      IF GT_AFKO-PROCD EQ 'BWD'.
        SELECT SINGLE INLENGTH, INFACTOR, ADLENGTH
          FROM ZGTPPT2012
         WHERE ORDNR EQ @GT_AFKO-AUFNR
           AND POSNR EQ @GT_AFKO-POSNR
           INTO @DATA(LS_2012).

        GT_AFKO-INLENGTH = LS_2012-INLENGTH + LS_2012-ADLENGTH.
        GT_AFKO-INFACTOR = LS_2012-INFACTOR.

      ELSE.
        SELECT SINGLE INLENGTH, INFACTOR, QLENGTH, CLENGTH, SLENGTH, ELENGTH, ADLENGTH
          FROM ZGTPPT2010
         WHERE ORDNR EQ @GT_AFKO-AUFNR
           AND POSNR EQ @GT_AFKO-POSNR
          INTO @DATA(LS_2010).

        IF LS_2010 IS INITIAL.
          SELECT SINGLE INLENGTH, INFACTOR, QLENGTH, CLENGTH, ADLENGTH
            FROM ZGTPPT2340
           WHERE ORDNR EQ @GT_AFKO-AUFNR
             AND POSNR EQ @GT_AFKO-POSNR
            INTO CORRESPONDING FIELDS OF @LS_2010.
        ENDIF.

        GT_AFKO-INLENGTH = LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                           LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH.
        GT_AFKO-INFACTOR = LS_2010-INFACTOR.

      ENDIF.

      "기본조장, 기본조장수 가 없는 경우
      IF GT_AFKO-INLENGTH IS INITIAL AND GT_AFKO-INFACTOR IS INITIAL.
        GT_AFKO-INLENGTH = GT_AFKO-PSMNG.
        GT_AFKO-INFACTOR = '1'.
      ENDIF.

      CLEAR: LS_2012, LS_2010.
    ENDIF.
*[U01] 가온전선 추가
*- Start 2025.05.20
* 작업완료 처리대상, 입고완료 처리대상 : 노란불. 마감 점검시 무조건 조회 대상
    IF GT_AFKO-STTXT = TEXT-042 OR GT_AFKO-STTXT = TEXT-043.
      GT_AFKO-CLOSE = ICON_LED_YELLOW.
* 작업완료 : 초록불. 입고상태 or 실적 상태 or 투입 상태 중 하나라도 초록불이 아닐 경우 조회 대상
    ELSEIF GT_AFKO-STTXT = TEXT-002 OR "작업완료
           GT_AFKO-STTXT = TEXT-041.   "오더종료  "[U01] +
      GT_AFKO-CLOSE = ICON_LED_GREEN.
* 작업중 : 빈값. 마감 점검시 무조건 조회 대상
    ELSEIF GT_AFKO-STTXT = TEXT-044."작업중
      CLEAR GT_AFKO-CLOSE.
    ENDIF.
*- End 2025.05.20
    MODIFY GT_AFKO. " INDEX lv_index.
    CLEAR  GT_AFKO.

  ENDLOOP.

  SORT GT_AFKO BY GSTRS GSUZS SEQNO AUFNR POSNR.
*- Start 2025.03.14 오더종료여부 신호등 필드 관리
* 마감점검 조회 시 오더번호 기준(품목번호 Group By) 총 수량과 입고 수량 SUM 후 조회
  IF C_CHECK EQ 'X'.

    DATA(LT_AFKO) = GT_AFKO[].

    CLEAR : GT_AFKO, GT_AFKO[].
    LOOP AT LT_AFKO INTO DATA(LS_AFKO).

      CLEAR GT_AFKO.
      READ TABLE GT_AFKO WITH KEY AUFNR = LS_AFKO-AUFNR.
      IF SY-SUBRC <> 0.
        APPEND LS_AFKO TO GT_AFKO.
      ELSE.
        GT_AFKO-PSMNG = GT_AFKO-PSMNG + LS_AFKO-PSMNG.
        GT_AFKO-WEMNG = GT_AFKO-WEMNG + LS_AFKO-WEMNG.
        MODIFY GT_AFKO INDEX SY-TABIX.
      ENDIF.

    ENDLOOP.

    LOOP AT GT_AFKO.

      CLEAR LV_OK.
* 작업완료 처리대상, 입고완료 처리대상 : 노란불. 마감 점검시 무조건 조회 대상
      IF GT_AFKO-STTXT = TEXT-042 OR GT_AFKO-STTXT = TEXT-043.
        GT_AFKO-CLOSE = ICON_LED_YELLOW.
        LV_OK = 'X'.
* 작업완료 : 초록불. 입고상태 or 실적 상태 or 투입 상태 중 하나라도 초록불이 아닐 경우 조회 대상
      ELSEIF GT_AFKO-STTXT = TEXT-002 OR "작업완료
             GT_AFKO-STTXT = TEXT-041.   "오더종료  "[U01] +
        GT_AFKO-CLOSE = ICON_LED_GREEN.
        IF GT_AFKO-GRSTAT EQ ICON_LED_GREEN AND
          GT_AFKO-CFSTAT EQ ICON_LED_GREEN AND
          GT_AFKO-GISTAT EQ ICON_LED_GREEN.
        ELSE.
          LV_OK = 'X'.
        ENDIF.
* 작업중 : 빈값. 마감 점검시 무조건 조회 대상
      ELSEIF GT_AFKO-STTXT = TEXT-044."작업중
        CLEAR GT_AFKO-CLOSE.
        LV_OK = 'X'.
      ENDIF.
* 작업상태 관계없이 입고 수량 or 실적 수량이 초과되어 숫자가 빨간색으로 표시되는 대상도 조회 대상
      IF GT_AFKO-IPGO = 'X' OR GT_AFKO-SILJEOK = 'X'.
        LV_OK = 'X'.
      ENDIF.
* ALV 조회 List 대상이 아니면 삭제
      IF LV_OK IS INITIAL.
        DELETE GT_AFKO.
        CONTINUE.
      ENDIF.

      MODIFY GT_AFKO.

    ENDLOOP.

  ENDIF.
*- End 2025.03.14
ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_delay_mail
*&---------------------------------------------------------------------*
FORM SEND_DELAY_MAIL.
* 메일 제목 생성
  CONCATENATE TEXT-M02 GV_ARBPL TEXT-M03
                  INTO GV_SUBJECT SEPARATED BY SPACE.
* 메일 본문 생성
  MAIL_MSG: '<HTML>',
            '<BODY>'.

  CONCATENATE TEXT-M04 '<BR>' TEXT-M05 '<BR><BR><BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.

  CONCATENATE GV_ARBPL TEXT-M06 '<BR>' TEXT-M07 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.

  MAIL_MSG: '</BODY>',
            '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_over_mail
*&---------------------------------------------------------------------*
FORM SEND_OVER_MAIL .
* 메일 제목 생성
  CONCATENATE TEXT-M02 GV_ARBPL TEXT-M19
                  INTO GV_SUBJECT SEPARATED BY SPACE.
* 메일 본문 생성
  MAIL_MSG : '<HTML>',
                    '<BODY>'.

  CONCATENATE TEXT-M04 '<BR>' TEXT-M05 '<BR><BR><BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.

  CONCATENATE GV_ARBPL TEXT-M20 '<BR>' TEXT-M21 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.
* 오더 처리 정보 생성
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                    '<THEAD>',
                    '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Plant</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Production Order</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Reason</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Material</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Material Desc.</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Order Qty</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">GR Qty</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">GR Date</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">Conf Qty</TH>',
                    '</TR>',
                    '</THEAD>',
                    '<TBODY>'.

  LOOP AT GT_AFKO3 WHERE ARBPL EQ GT_AFKO4-ARBPL.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO3-MATNR
      IMPORTING
        OUTPUT = GT_AFKO3-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO3-AUFNR
      IMPORTING
        OUTPUT = GT_AFKO3-AUFNR.

    CLEAR GV_TEXT.
    IF GT_AFKO3-IPGO = 'X'. "초과 입고
      GV_TEXT = TEXT-030.
    ELSEIF GT_AFKO3-SILJEOK = 'X'. "초과 실적
      GV_TEXT = TEXT-031.
    ENDIF.

    CLEAR GV_DATE.
    IF GT_AFKO3-BUDAT IS NOT INITIAL.
      CONCATENATE GT_AFKO3-BUDAT+0(4) '.' GT_AFKO3-BUDAT+4(2) '.' GT_AFKO3-BUDAT+6(2)
             INTO GV_DATE.
    ENDIF.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-WERKS 'C'. "Plant
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-AUFNR 'C'. "Production Order
    PERFORM APPEND_HTML_FOR_LIST USING GV_TEXT 'C'. "Reason
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-MATNR 'C'. "Material
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-MAKTX 'L'. "Material Desc.
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-PSMNG 'R'. "Order Qty
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-WEMNG 'R'. "GR Qty
    PERFORM APPEND_HTML_FOR_LIST USING GV_DATE 'C'. "GR Date
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-LMNGA 'R'. "Conf Qty

    MAIL_MSG : '</TR>'.

  ENDLOOP.

  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '</BODY>',
                   '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_html_for_list
*&---------------------------------------------------------------------*
FORM APPEND_HTML_FOR_LIST USING PV_VALUE PV_SIGN.

  DATA : LV_MAIN(30),
         LV_LEFT(16),
         LV_RIGHT(6),
         LV_LEFT2(16),
         LV_RIGHT2(6).
  DATA : LV_MENGE TYPE STRING.

  IF PV_SIGN = 'C'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'L'.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: LEFT;">'
    PV_VALUE '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ELSEIF PV_SIGN = 'R'.
    CLEAR : LV_MAIN, LV_LEFT, LV_RIGHT, LV_LEFT2, LV_RIGHT2, LV_MENGE.
    LV_MENGE = PV_VALUE.
    CALL FUNCTION 'BUX_DECIMAL_START'
      EXPORTING
        I_VALUE_DB   = LV_MENGE
      IMPORTING
        E_VALUE_DYNP = LV_MAIN.
    SPLIT LV_MAIN AT '.' INTO LV_LEFT LV_RIGHT.
    IF LV_RIGHT IS INITIAL.
      SPLIT LV_MENGE AT '.' INTO LV_LEFT2 LV_RIGHT2.
      CONCATENATE LV_LEFT '.' LV_RIGHT2 INTO GV_TEXT2.
    ELSE.
      GV_TEXT2 = LV_MAIN.
    ENDIF.
    CONDENSE GV_TEXT2 NO-GAPS.
    CONCATENATE
    '<TD STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: RIGHT;">'
    GV_TEXT2 '</TD>' INTO GS_MSG SEPARATED BY SPACE.
  ENDIF.

  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR : GS_MSG, GV_TEXT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_delay_over_mail
*&---------------------------------------------------------------------*
FORM SEND_DELAY_OVER_MAIL .
* 메일 제목 생성
  CONCATENATE TEXT-M02 GV_ARBPL TEXT-M19
                  INTO GV_SUBJECT SEPARATED BY SPACE.
* 메일 본문 생성
  MAIL_MSG : '<HTML>',
                    '<BODY>'.

  CONCATENATE TEXT-M04 '<BR>' TEXT-M05 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.

  CONCATENATE GV_ARBPL TEXT-M22 '<BR>' TEXT-M23 '<BR>' TEXT-M21 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.
* 오더 처리 정보 생성
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                    '<THEAD>',
                    '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">플랜트</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">생산오더</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">사유</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">자재코드</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품명규격</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 오더수량</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 입고수량</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">입고일자</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 실적수량</TH>',
                    '</TR>',
                    '</THEAD>',
                    '<TBODY>'.
* 초과 입고/실적 리스트
  LOOP AT GT_AFKO3 WHERE ARBPL EQ GT_AFKO4-ARBPL.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO3-MATNR
      IMPORTING
        OUTPUT = GT_AFKO3-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO3-AUFNR
      IMPORTING
        OUTPUT = GT_AFKO3-AUFNR.

    CLEAR GV_TEXT.
    IF GT_AFKO3-IPGO = 'X'. "초과 입고
      GV_TEXT = TEXT-030.
    ELSEIF GT_AFKO3-SILJEOK = 'X'. "초과 실적
      GV_TEXT = TEXT-031.
    ENDIF.

    CLEAR GV_DATE.
    IF GT_AFKO3-BUDAT IS NOT INITIAL.
      CONCATENATE GT_AFKO3-BUDAT+0(4) '.' GT_AFKO3-BUDAT+4(2) '.' GT_AFKO3-BUDAT+6(2)
             INTO GV_DATE.
    ENDIF.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-WERKS 'C'. "Plant
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-AUFNR 'C'. "Production Order
    PERFORM APPEND_HTML_FOR_LIST USING GV_TEXT 'C'. "Reason
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-MATNR 'C'. "Material
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-MAKTX 'L'. "Material Desc.
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-PSMNG 'R'. "Order Qty
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-WEMNG 'R'. "GR Qty
    PERFORM APPEND_HTML_FOR_LIST USING GV_DATE 'C'. "GR Date
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO3-LMNGA 'R'. "Conf Qty

    MAIL_MSG : '</TR>'.

    PERFORM APPEND_EMAIL_SEND_LOG USING GT_AFKO3.

  ENDLOOP.
* 지연 투입/실적 리스트
  LOOP AT GT_AFKO2 WHERE ARBPL EQ GT_AFKO4-ARBPL.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO2-MATNR
      IMPORTING
        OUTPUT = GT_AFKO2-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO2-AUFNR
      IMPORTING
        OUTPUT = GT_AFKO2-AUFNR.

    CLEAR GV_TEXT.
    IF GT_AFKO2-DELAY = TEXT-T01.
      GV_TEXT = TEXT-032. "투입 지연
    ELSEIF GT_AFKO2-DELAY = TEXT-T02.
      GV_TEXT = TEXT-033. "실적 지연
    ELSEIF GT_AFKO2-DELAY = TEXT-T03.
      GV_TEXT = TEXT-034. "입고 지연
    ENDIF.

    CLEAR GV_DATE.
    IF GT_AFKO2-BUDAT IS NOT INITIAL.
      CONCATENATE GT_AFKO2-BUDAT+0(4) '.' GT_AFKO2-BUDAT+4(2) '.' GT_AFKO2-BUDAT+6(2)
             INTO GV_DATE.
    ENDIF.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-WERKS 'C'. "Plant
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-AUFNR 'C'. "Production Order
    PERFORM APPEND_HTML_FOR_LIST USING GV_TEXT 'C'. "Reason
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-MATNR 'C'. "Material
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-MAKTX 'L'. "Material Desc.
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-PSMNG 'R'. "Order Qty
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-WEMNG 'R'. "GR Qty
    PERFORM APPEND_HTML_FOR_LIST USING GV_DATE 'C'. "GR Date
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO2-LMNGA 'R'. "Conf Qty

    MAIL_MSG : '</TR>'.

    PERFORM APPEND_EMAIL_SEND_LOG USING GT_AFKO2.

  ENDLOOP.

  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '</BODY>',
                   '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LAST_DAY
*&---------------------------------------------------------------------*
FORM CHECK_LAST_DAY .

  CLEAR : GV_LAST_DAY, GV_OK.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = SY-DATUM
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LAST_DAY.
* Factory Calender 기준 말일 추출할 때까지 N번 반복 수행
  DO.

    CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
      EXPORTING
        DATE                       = GV_LAST_DAY
        FACTORY_CALENDAR_ID        = 'LG'
        MESSAGE_TYPE               = 'E'
      EXCEPTIONS
        DATE_AFTER_RANGE           = 1
        DATE_BEFORE_RANGE          = 2
        DATE_INVALID               = 3
        DATE_NO_WORKINGDAY         = 4
        FACTORY_CALENDAR_NOT_FOUND = 5
        MESSAGE_TYPE_INVALID       = 6.

    IF SY-SUBRC <> 0.
      GV_LAST_DAY = GV_LAST_DAY - 1.
    ELSE.
      EXIT.
    ENDIF.

  ENDDO.
* 현재 일자와 동일하다면 마감 점검 메일링 전송 수행
  IF GV_LAST_DAY EQ SY-DATUM.
    GV_OK = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mail_over_ipgo_delay
*&---------------------------------------------------------------------*
FORM SEND_MAIL_OVER_IPGO_DELAY .

  DATA : LV_TEXT(100).

  SORT GT_AFKO4 BY ARBPL.
  DELETE ADJACENT DUPLICATES FROM GT_AFKO4 COMPARING ARBPL.

  LOOP AT GT_AFKO4.
* 설비담당자 정보 추출
*- Start 2025.06.10
    SELECT * INTO TABLE @DATA(LT_1010)
                     FROM ZGTPPT1010
                     WHERE MODULE_KIND = 'PP'
                       AND CODEGRP = '3001'
                       AND FLD_01 EQ @P_PWERK
                       AND FLD_02 EQ @S_DISPO-LOW+0(2)
                       AND FLD_03 EQ @GT_AFKO4-ARBPL
                       AND FLD_06 EQ 'X'.
*    SELECT SINGLE fld_04 INTO @gv_fld_04
*                         FROM zgtppt1010
*                         WHERE module_kind = 'PP'
*                           AND codegrp = '3001'
*                           AND fld_01 EQ @p_pwerk
*                           AND fld_02 EQ @s_dispo-low+0(2)
*                           AND fld_03 EQ @gt_afko4-arbpl
*                           AND fld_06 EQ 'X'.
*                           AND fld_02 EQ @gt_afko4-arbpl
*                           AND fld_04 EQ 'X'.
** 설비담당자 정보 추출 성공시에만 메일 전송 2025.01.10
*    IF gv_fld_04 IS NOT INITIAL.
    LOOP AT LT_1010 INTO DATA(LS_1010).

      CLEAR : GV_TIMESTAMP, GS_USR21, GV_ADDRESS, GV_ARBPL, GT_ZGTPPT3240,
              GTT_MESSAGE.
*- 맵핑을 위한 변수키 생성
      GET TIME STAMP FIELD GV_TIMESTAMP.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF @GS_USR21
                      FROM USR21
                      WHERE BNAME EQ @LS_1010-FLD_04.
      SELECT SINGLE SMTP_ADDR INTO GV_ADDRESS FROM ADR6
                              WHERE ADDRNUMBER = GS_USR21-ADDRNUMBER
                                AND PERSNUMBER = GS_USR21-PERSNUMBER.
      CONCATENATE `'` GT_AFKO4-ARBPL `'` INTO GV_ARBPL.
* 처리 지연/입고/실적 건 메일 전송 : 설비 담당자
      PERFORM SEND_DELAY_OVER_MAIL.

      TRY.
          G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

          G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                          I_TYPE    = 'HTM'
                          I_TEXT    = GTT_MESSAGE
                          I_SUBJECT = GV_SUBJECT ).

          G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

          G_RECEIVER =
          CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

          G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                  I_EXPRESS   = 'X' ).

          G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

          G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                         RECEIVING RESULT              = GV_SEND_RESULT ).

          COMMIT WORK.

        CATCH CX_BCS INTO G_EXCEPTION.

      ENDTRY.
* 메일 전송 이력 저장
      IF SY-SUBRC = 0.
        MODIFY ZGTPPT3240 FROM TABLE GT_ZGTPPT3240.
        LV_TEXT = P_PWERK && '//' && GT_AFKO4-ARBPL && '//' && GV_FLD_04
                 && '//' && GV_ADDRESS && ' //' && TEXT-024.
        WRITE :/ LV_TEXT. "배치잡 스풀 로그 기록
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

*    ENDIF.

    ENDLOOP.

    CLEAR : LT_1010, LS_1010.
*- End 2025.06.10
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mail_check_finish_order
*&---------------------------------------------------------------------*
FORM SEND_MAIL_CHECK_FINISH_ORDER .

  DATA : LV_TEXT(100).
* 담당자 정보 추출
  SELECT * INTO TABLE @DATA(LT_1010) FROM ZGTPPT1010
                                     WHERE MODULE_KIND = 'PP'
                                       AND CODEGRP = '3001'
                                       AND FLD_01 EQ @P_PWERK
                                       AND FLD_02 EQ @S_DISPO-LOW+0(2)
                                       AND FLD_06 EQ 'X'.

  SORT LT_1010 BY FLD_04 FLD_05.
  DELETE ADJACENT DUPLICATES FROM LT_1010 COMPARING FLD_04 FLD_05.

  LOOP AT LT_1010 INTO DATA(LS_1010).

    CLEAR : GV_TIMESTAMP, GT_ZGTPPT3240, GTT_MESSAGE, GV_ADDRESS, GS_USR21.
*- 맵핑을 위한 변수키 생성
    GET TIME STAMP FIELD GV_TIMESTAMP.
* 설비담당자 정보 추출 성공시에만 메일 전송 2025.01.10
    IF LS_1010-FLD_04 IS NOT INITIAL.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF @GS_USR21
                      FROM USR21
                      WHERE BNAME EQ @LS_1010-FLD_04.
      SELECT SINGLE SMTP_ADDR INTO GV_ADDRESS FROM ADR6
                              WHERE ADDRNUMBER = GS_USR21-ADDRNUMBER
                                AND PERSNUMBER = GS_USR21-PERSNUMBER.
    ELSE.

      GV_ADDRESS = LS_1010-FLD_05.

    ENDIF.
* 담당자에게 메일 전송
    PERFORM SEND_NOT_FINISH_MAIL USING LS_1010-FLD_04.

    TRY.
        G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

        G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                        I_TYPE    = 'HTM'
                        I_TEXT    = GTT_MESSAGE
                        I_SUBJECT = GV_SUBJECT ).

        G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

        G_RECEIVER =
        CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

        G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                I_EXPRESS   = 'X' ).

        G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

        G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                       RECEIVING RESULT              = GV_SEND_RESULT ).

        COMMIT WORK.

      CATCH CX_BCS INTO G_EXCEPTION.

    ENDTRY.
* 메일 전송 이력 저장
    IF SY-SUBRC = 0.
      MODIFY ZGTPPT3240 FROM TABLE GT_ZGTPPT3240.
      LV_TEXT = P_PWERK && '//' && GV_ADDRESS && ' //' && TEXT-024..
      WRITE :/ LV_TEXT. "배치잡 스풀 로그 기록
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_not_finish_mail
*&---------------------------------------------------------------------*
FORM SEND_NOT_FINISH_MAIL USING PV_FLD_04.
* 메일 제목 생성
  GV_SUBJECT = TEXT-M24.
* 메일 본문 생성
  MAIL_MSG : '<HTML>',
                    '<BODY>'.

  CONCATENATE TEXT-M25 '<BR>' TEXT-M26 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.
* 마감 점검 정보 생성
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                    '<THEAD>',
                    '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">점검 필요 사유</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">공정</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">설비</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">생산오더</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">작업상태</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품명규격</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">단위</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 오더수량</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 입고수량</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">총 실적수량</TH>',
                    '</TR>',
                    '</THEAD>',
                    '<TBODY>'.
* 마감 점검 리스트
  LOOP AT GT_AFKO5.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GT_AFKO5-AUFNR
      IMPORTING
        OUTPUT = GT_AFKO5-AUFNR.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-REASON 'L'. "점검 필요사유
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-PROCD 'C'. "공정
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-ARBPL 'C'. "설비
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-AUFNR 'C'. "생산오더
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-STTXT 'L'. "작업상태
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-MAKTX 'L'. "품명규격
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-AMEIN 'C'. "단위
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-PSMNG 'R'. "총 오더수량
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-WEMNG 'R'. "총 입고수량
    PERFORM APPEND_HTML_FOR_LIST USING GT_AFKO5-LMNGA 'R'. "총 실적수량

    MAIL_MSG : '</TR>'.

    PERFORM APPEND_EMAIL_SEND_LOG2 USING GT_AFKO5 PV_FLD_04.

  ENDLOOP.

  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '</BODY>',
                   '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_email_send_log2
*&---------------------------------------------------------------------*
FORM APPEND_EMAIL_SEND_LOG2 USING PS_AFKO LIKE GT_AFKO5
                                  PV_FLD_04.

  CLEAR GS_ZGTPPT3240.
  GS_ZGTPPT3240-WERKS = PS_AFKO-WERKS. "플랜트
  GS_ZGTPPT3240-AUFNR = PS_AFKO-AUFNR. "오더번호
  GS_ZGTPPT3240-ALTUM = SY-DATUM. "알림전송일자
  GS_ZGTPPT3240-ALEIT = SY-UZEIT. "알림전송시간
  GS_ZGTPPT3240-TIMESTAMPL = GV_TIMESTAMP. "타임스탬프
  GS_ZGTPPT3240-REASON = PS_AFKO-REASON. "사유
  GS_ZGTPPT3240-PROCD = PS_AFKO-PROCD. "공정코드
  GS_ZGTPPT3240-DISPO = PS_AFKO-DISPO. "MRP관리자
  GS_ZGTPPT3240-ARBPL = PS_AFKO-ARBPL. "작업장
  GS_ZGTPPT3240-PERNR = PV_FLD_04. "설비담당자 사번
  GS_ZGTPPT3240-EMAIL_ID = GV_ADDRESS. "설비담당자 이메일주소
  APPEND GS_ZGTPPT3240 TO GT_ZGTPPT3240.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZGTPPT2010
*&---------------------------------------------------------------------*
FORM CHECK_ZGTPPT2010 .

  DATA(LT_AFKO) = GT_AFKO[].
  DATA : LV_TABIX LIKE SY-TABIX.

  SORT LT_AFKO BY AUFNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_AFKO COMPARING AUFNR POSNR.

  IF LT_AFKO[] IS NOT INITIAL.

    SELECT * INTO TABLE @DATA(LT_2010)
      FROM ZGTPPT2010
      FOR ALL ENTRIES IN @LT_AFKO
      WHERE ORDNR = @LT_AFKO-AUFNR
        AND ORDTY ='PRD'
        AND GRPNR IN @S_GRPNR.

  ENDIF.

  LOOP AT GT_AFKO.

    LV_TABIX = SY-TABIX.

    READ TABLE LT_2010 INTO DATA(LS_2010)
                       WITH KEY ORDNR      = GT_AFKO-AUFNR
                                POSNR+2(4) = GT_AFKO-POSNR.
    IF LS_2010 IS INITIAL.
      DELETE GT_AFKO INDEX LV_TABIX.
    ENDIF.
    CLEAR LS_2010.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUD_GUID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUD_GUID .

  DATA : LS_3300 TYPE ZGTPPT3300.
  DATA : LT_3300 TYPE TABLE OF ZGTPPT3300.
  DATA : LT_ROWS TYPE LVC_T_ROW.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS                 " Indexes of Selected Rows
  ).

  DELETE LT_ROWS WHERE INDEX = 0.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_AFKO INDEX LS_ROW-INDEX.
    IF SY-SUBRC EQ 0.
      CLEAR LS_3300.
      LS_3300-AUFNR = GT_AFKO-AUFNR.
      COLLECT LS_3300 INTO LT_3300.
    ENDIF.

  ENDLOOP.

  CHECK LT_3300[] IS NOT INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더의 알림이 제외됩니다. 계속 진행 하시겠습니까?'
    '알림제외'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_3300 ASSIGNING FIELD-SYMBOL(<LS_3300>).
    <LS_3300>-EXCLUDE = ABAP_TRUE.
    <LS_3300>-CRDAT = <LS_3300>-CHDAT = SY-DATUM.
    <LS_3300>-CRTIM = <LS_3300>-CHTIM = SY-UZEIT.
    <LS_3300>-CRNAM = <LS_3300>-CHNAM = SY-UNAME.
  ENDLOOP.

  MODIFY ZGTPPT3300 FROM TABLE LT_3300.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '테이블 업데이트중 오류 발생하였습니다.'.
    RETURN.
  ENDIF.

  PERFORM REFRESH_PROC.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_PROC .

  PERFORM INITIAL_PROC.
  CLEAR : GT_ORDER, GT_ORDER[], GT_RESB2, GT_RESB2[], GT_AFRU, GT_AFRU[],
              GT_AFPO, GT_AFPO[].

  IF S_PAYOFF[] IS NOT INITIAL.
    CLEAR P_DBCNT.
  ENDIF.

  IF S_STATUS-LOW = ' '.
    PERFORM SELECT_PROC.  "ALL
  ELSEIF S_STATUS-LOW = 'A'.
    PERFORM SELECT_PROC1.  "작업지시전...
  ELSE.
    PERFORM SELECT_PROC2.  "작업대기..오더종료
  ENDIF.

  PERFORM GET_DATA_NEW_FIELD.
  PERFORM ADDITIONAL_INFO_PROC.

  PERFORM REFRESH_GT_AFKO_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT  CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_LAYO = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_ACTIBITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_ACTIBITY .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LS_RETURN TYPE BAPIRET1.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS[].

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '취소할 레코드를 선택하십시요.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_AFKO INTO DATA(LS_AFKO) INDEX LS_ROW-INDEX.
    IF SY-SUBRC EQ 0.
      APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
      <LS_AUFNR>-SIGN = 'I'.
      <LS_AUFNR>-OPTION = 'EQ'.
      <LS_AUFNR>-LOW = LS_AFKO-AUFNR.
    ENDIF.
  ENDLOOP.
  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

  IF LT_AUFNR IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '시간확정 취소를 수행하시겠습니까?'
    '취소확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SELECT RUECK, RMZHL, BUDAT, AUFNR FROM AFRU
    INTO TABLE @DATA(LT_AFRU)
   WHERE AUFNR IN @LT_AUFNR
     AND STOKZ = '' " 역분개 지시자 제외
     AND STZHL = ''   " 취소된 카운터 제외
     AND GMNGA = 0. " 수량 확정건 제외

  LOOP AT LT_AFRU INTO DATA(LS_AFRU).
*    READ TABLE GT_AFKO ASSIGNING FIELD-SYMBOL(<LS_AFKO>) WITH KEY AUFNR = LS_AFRU-AUFNR.
    CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
      EXPORTING
        CONFIRMATION        = LS_AFRU-RUECK
        CONFIRMATIONCOUNTER = LS_AFRU-RMZHL
        POSTG_DATE          = LS_AFRU-BUDAT
        CONF_TEXT           = '시간확정 취소'
      IMPORTING
        RETURN              = LS_RETURN.

    IF LS_RETURN EQ 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.

* Transaction Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_PROC.

  MESSAGE S006 WITH '시간확정 취소 수행 되었습니다.'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_ACTIBITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SET_ACTIBITY .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LS_RETURN TYPE BAPIRET1.
  DATA : LT_TIMETICKETS TYPE TABLE OF BAPI_PP_TIMETICKET.
  DATA : LV_BUDAT TYPE SY-DATUM.
  DATA : LV_CHK_EXIST.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS[].

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '처리할 레코드를 선택하십시요.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_AFKO INTO DATA(LS_AFKO) INDEX LS_ROW-INDEX.
    IF SY-SUBRC EQ 0.
      APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
      <LS_AUFNR>-SIGN = 'I'.
      <LS_AUFNR>-OPTION = 'EQ'.
      <LS_AUFNR>-LOW = LS_AFKO-AUFNR.
    ENDIF.
  ENDLOOP.
  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

  IF LT_AUFNR IS INITIAL.
    RETURN.
  ENDIF.

  SELECT RUECK, RMZHL, BUDAT, AUFNR FROM AFRU
    INTO TABLE @DATA(LT_AFRU)
   WHERE AUFNR IN @LT_AUFNR
     AND STOKZ = '' " 역분개 지시자 제외
     AND STZHL = ''   " 취소된 카운터 제외
     AND GMNGA = 0. " 수량 확정건 제외

  IF LT_AFRU[] IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '시간확정 데이터가 존재합니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '시간확정 처리를 수행하시겠습니까?'
    '확정확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SELECT DISTINCT A~AUFNR, A~AUFPL, C~BMSCH, C~VGW01, C~VGW02, C~VGW03,
         C~VGW04, C~VGW05, C~VGW06, D~ARBPL
    FROM AFKO AS A
    INNER JOIN AFVC AS B ON B~AUFPL = A~AUFPL
    INNER JOIN AFVV AS C ON C~AUFPL = A~AUFPL
                        AND C~APLZL = B~APLZL
    INNER JOIN CRHD AS D ON D~OBJID = B~ARBID
    INTO TABLE @DATA(LT_ACTIVITY)
   WHERE A~AUFNR IN @LT_AUFNR
     AND B~PLNFL = '000000'
     AND D~OBJTY = 'A'.

  LOOP AT LT_ACTIVITY INTO DATA(LS_ACTIVITY).

    CLEAR LV_CHK_EXIST.
    LOOP AT GT_AFKO INTO LS_AFKO WHERE AUFNR = LS_ACTIVITY-AUFNR
                                   AND LMNGA NE 0.
      LV_CHK_EXIST = ABAP_TRUE.
      EXIT.
    ENDLOOP.


    IF LV_CHK_EXIST = ABAP_TRUE AND LS_AFKO-LMNGA NE 0.

      APPEND INITIAL LINE TO LT_TIMETICKETS ASSIGNING FIELD-SYMBOL(<LS_TIMETICKETS>).
      <LS_TIMETICKETS>-ORDERID = LS_ACTIVITY-AUFNR.
      <LS_TIMETICKETS>-OPERATION = '0010'.
      <LS_TIMETICKETS>-FIN_CONF = 'X'.

      CLEAR LV_BUDAT.
      SELECT SINGLE MAX( BUDAT ) FROM AFRU
        INTO @LV_BUDAT
       WHERE AUFNR = @LS_ACTIVITY-AUFNR
        AND STOKZ = 'X' " 역분개 지시자
        AND GMNGA = 0. " 수량 확정건 제외
      IF LV_BUDAT IS NOT INITIAL.
        <LS_TIMETICKETS>-POSTG_DATE = LV_BUDAT.
      ELSE.
        <LS_TIMETICKETS>-POSTG_DATE = SY-DATUM.
      ENDIF.
      <LS_TIMETICKETS>-CONF_TEXT = '시간확정 처리'.
      <LS_TIMETICKETS>-PLANT = P_PWERK.
      <LS_TIMETICKETS>-WORK_CNTR = LS_ACTIVITY-ARBPL.
*      <LS_TIMETICKETS>-YIELD = LS_AFKO-WEMNG.
      <LS_TIMETICKETS>-CONF_ACTI_UNIT1 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY1 = LS_ACTIVITY-VGW01.
      <LS_TIMETICKETS>-CONF_ACTI_UNIT2 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY2 = LS_ACTIVITY-VGW02 * ( LS_AFKO-LMNGA / LS_ACTIVITY-BMSCH ) .
      <LS_TIMETICKETS>-CONF_ACTI_UNIT3 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY3 = LS_ACTIVITY-VGW03 * ( LS_AFKO-LMNGA / LS_ACTIVITY-BMSCH ) .
      <LS_TIMETICKETS>-CONF_ACTI_UNIT4 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY4 = LS_ACTIVITY-VGW04 * ( LS_AFKO-LMNGA / LS_ACTIVITY-BMSCH ) .
      <LS_TIMETICKETS>-CONF_ACTI_UNIT5 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY5 = LS_ACTIVITY-VGW05 * ( LS_AFKO-LMNGA / LS_ACTIVITY-BMSCH ) .
      <LS_TIMETICKETS>-CONF_ACTI_UNIT6 = 'MIN'.
      <LS_TIMETICKETS>-CONF_ACTIVITY6 = LS_ACTIVITY-VGW06 * ( LS_AFKO-LMNGA / LS_ACTIVITY-BMSCH ) .
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN      = LS_RETURN
    TABLES
      TIMETICKETS = LT_TIMETICKETS.

  IF LS_RETURN EQ 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-LOG_MSG_NO DISPLAY LIKE 'E'
       WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4.
    RETURN.
  ELSE.
* Transaction Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
  ENDIF.

  PERFORM REFRESH_PROC.

  MESSAGE S006 WITH '시간확정 수행 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_2330_PEDTR
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_ZGTPPR1040
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_ZGTPPR1040 .

  DATA : LT_WERKS TYPE RANGE OF WERKS_D.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_GSTRP TYPE RANGE OF AFKO-GSTRP.

* 플랜트 설정
  APPEND INITIAL LINE TO LT_WERKS ASSIGNING FIELD-SYMBOL(<LS_WERKS>).
  <LS_WERKS>-SIGN = 'I'.
  <LS_WERKS>-OPTION = 'EQ'.
  <LS_WERKS>-LOW = P_PWERK.

* 생산오더 설정
  APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
  <LS_AUFNR>-SIGN = 'I'.
  <LS_AUFNR>-OPTION = 'EQ'.
  <LS_AUFNR>-LOW = GT_AFKO-AUFNR.

* 생산시작일자 설정
  IF GT_AFKO-GSTRS IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_GSTRP ASSIGNING FIELD-SYMBOL(<LS_GSTRP>).
    <LS_GSTRP>-SIGN = 'I'.
    <LS_GSTRP>-OPTION = 'EQ'.
    <LS_GSTRP>-LOW = GT_AFKO-GSTRS.
  ENDIF.

  SUBMIT ZGTPPR1040 WITH  P_R1 = 'X'
                              WITH P_C5 = ''
                               WITH S_WERKS IN LT_WERKS
                               WITH S_AUFNR IN LT_AUFNR
                               WITH S_GSTRP IN LT_GSTRP
                               AND RETURN.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUE_FROM_TKGW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_NUM
*&      --> LS_TKGW
*&      <-- GT_AFKO
*&---------------------------------------------------------------------*
FORM SET_VALUE_FROM_TKGW  USING    PV_NUM
                                   PS_TKGW TYPE /NFM/TKGW
                          CHANGING PS_AFKO LIKE GT_AFKO.

  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  STATICS : LT_TEXT TYPE TABLE OF /NFM/TNESTX.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  IF LT_TEXT[] IS INITIAL.
    SELECT * FROM /NFM/TNESTX
      INTO TABLE LT_TEXT
     WHERE SPRAS = SY-LANGU.
    SORT LT_TEXT BY NES.
  ENDIF.

*  재질
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = 'NES' && PV_NUM.
  ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE PS_AFKO TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = PS_TKGW-NES.
  ENDIF.

*  재질명
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = 'NES_T' && PV_NUM.
  ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE PS_AFKO TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    READ TABLE LT_TEXT INTO DATA(LS_TEXT) WITH KEY NES = PS_TKGW-NES BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LV_VALUE> = LS_TEXT-NESTX.
    ENDIF.
  ENDIF.

*  수량
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = 'KGW' && PV_NUM.
  ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE PS_AFKO TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    IF PS_TKGW-KGU NE 0.
      <LV_VALUE> = PS_AFKO-WEMNG * ( PS_TKGW-KGW / PS_TKGW-KGU ).
    ELSE.
      <LV_VALUE> = 0.
    ENDIF.
  ENDIF.

*  단위
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = 'BME' && PV_NUM.
  ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE PS_AFKO TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = PS_TKGW-BME.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_TECO_ORDER_1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_TECO_ORDER_1 .
  DATA : LV_ERROR,
         LV_TEXT(100),
         LV_MONTH     LIKE ISELLIST-MONTH,
         LV_MONTH2    LIKE ISELLIST-MONTH,
         LV_SUBRC     LIKE SY-SUBRC,
         LV_BUDAT     LIKE SY-DATUM.
  DATA : LV_DATUM LIKE SY-DATUM.
  DATA : LV_OK.
  DATA : LV_AUFNR LIKE AFKO-AUFNR.

  FIELD-SYMBOLS: <FS_S> LIKE GT_AFKO.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = ROW_TABLE[].
*- 데이터 선택 여부 체크
  IF ROW_TABLE[] IS INITIAL.
    MESSAGE W004 WITH TEXT-046."선택한 데이타가 없습니다!!!
    EXIT.
  ENDIF.

  "처리일자
  CLEAR: GV_ANS.
  PERFORM GET_EXEC_DATE_POPUP.

  CHECK GV_ANS = ABAP_TRUE.

  CLEAR: GT_TECO1.  "처리결과
  LOOP AT ROW_TABLE.

    READ TABLE GT_AFKO ASSIGNING <FS_S> INDEX ROW_TABLE-INDEX.

*- 오더의 상태가 작업완료(D), 오더 종료(E)는 한 건이라도 선택시 수행 불가.
    IF <FS_S>-STTXT = TEXT-002 OR <FS_S>-STTXT = TEXT-041.
      GS_TECO1-ID = ICON_LED_GREEN.
      GS_TECO1-TEXT  = TEXT-M27. "이미 종료(완료)처리된 오더입니다.
    ELSE.
      GS_TECO1-ID = ICON_LED_INACTIVE.
    ENDIF.
    GS_TECO1-AUFNR = <FS_S>-AUFNR.

    COLLECT GS_TECO1 INTO GT_TECO1.
    CLEAR: GS_TECO1.
  ENDLOOP.

  CHECK GT_TECO1[] IS NOT INITIAL.
  SORT GT_TECO1 BY AUFNR.

  PERFORM PROC_EXEC_TECO1.

  IF GT_TECO1[] IS NOT INITIAL.
    PERFORM CRE_OBJ_POP_ALV.
  ENDIF.

  "처리 결과 ALV 적용
  UNASSIGN: <FS_S>.
  LOOP AT GT_TECO1 INTO DATA(LS_T1) WHERE ID EQ ICON_LED_GREEN.
    READ TABLE GT_AFKO ASSIGNING <FS_S> WITH KEY AUFNR = LS_T1-AUFNR.
    IF SY-SUBRC EQ 0.
      <FS_S>-STTXT = TEXT-041. "오더종료
      <FS_S>-CLOSE = ICON_LED_GREEN.
    ENDIF.
  ENDLOOP.

*- 데이터 REFRESH
  PERFORM REFRESH_GT_AFKO_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXEC_DATE_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EXEC_DATE_POPUP .
  CLEAR GV_CDATE.

  DATA : LV_RETURN_CODE TYPE C.
  DATA : LT_FIELD TYPE TABLE OF SVAL.

  GV_CDATE = SY-DATLO.

  APPEND INITIAL LINE TO LT_FIELD ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
  <LS_FIELD>-FIELDTEXT = '처리일자'.
  <LS_FIELD>-TABNAME = 'AFRU'.
  <LS_FIELD>-FIELDNAME = 'BUDAT'.
  <LS_FIELD>-FIELD_OBL = ABAP_TRUE.
  <LS_FIELD>-VALUE = GV_CDATE.
*  WRITE GV_BUDAT TO <LS_FIELD>-VALUE.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = '처리일자 입력'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = LV_RETURN_CODE
    TABLES
      FIELDS          = LT_FIELD
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.

  IF LV_RETURN_CODE = 'A'. " 취소로 종료시
    RETURN.
  ENDIF.

  GV_ANS = ABAP_TRUE.

  READ TABLE LT_FIELD INTO DATA(LS_FIELD) INDEX 1.
  GV_CDATE = LS_FIELD-VALUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_EXEC_TECO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_EXEC_TECO1 .

  DATA: LT_DET_RETURN TYPE TABLE OF BAPI_ORDER_RETURN,
        LT_ORDERS     TYPE TABLE OF BAPI_ORDER_KEY,
        LS_ORDERS     TYPE BAPI_ORDER_KEY,
        LS_RETURN     TYPE BAPIRET2.

  CLEAR: LT_ORDERS, GS_TECO1.
  LOOP AT GT_TECO1 INTO GS_TECO1 WHERE ID = ICON_LED_INACTIVE.
    LS_ORDERS-ORDER_NUMBER = GS_TECO1-AUFNR.
    COLLECT LS_ORDERS INTO LT_ORDERS.
    CLEAR: LS_ORDERS.
  ENDLOOP.

  CHECK LT_ORDERS[] IS NOT INITIAL.
  CLEAR: LS_RETURN, LT_DET_RETURN[].
  CALL FUNCTION 'BAPI_PRODORD_COMPLETE_TECH'
    IMPORTING
      RETURN        = LS_RETURN
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_DET_RETURN.

  SORT LT_DET_RETURN BY ORDER_NUMBER.
  LOOP AT GT_TECO1 ASSIGNING FIELD-SYMBOL(<FS_T1>).
    READ TABLE LT_DET_RETURN INTO DATA(LS_DET_RETURN) WITH KEY ORDER_NUMBER = <FS_T1>-AUFNR.
    IF SY-SUBRC EQ 0.
      IF LS_DET_RETURN-TYPE EQ 'I' AND LS_DET_RETURN-ID EQ 'CO' AND LS_DET_RETURN-NUMBER EQ '889'.
        UPDATE AUFK SET IDAT2 = GV_CDATE
                  WHERE AUFNR EQ LS_DET_RETURN-ORDER_NUMBER.
        IF SY-SUBRC EQ 0.
          <FS_T1>-ID = ICON_LED_GREEN.
        ELSE.
          <FS_T1>-ID = ICON_LED_RED.
        ENDIF.
      ELSE.
        <FS_T1>-ID = ICON_LED_RED.
      ENDIF.
      <FS_T1>-TEXT = LS_DET_RETURN-MESSAGE.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_OBJ_POP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_OBJ_POP_ALV .
  PERFORM SET_LAYO_POP.
  PERFORM SET_FCAT_POP.
  PERFORM CRE_OBJT_POP.
  PERFORM CRE_ALVG_POP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYO_POP .
  GS_LAYOD-COL_OPT    = 'X'.
  GS_LAYOD-CWIDTH_OPT = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT_POP .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3020TOP'
      I_INTERNAL_TABNAME     = 'GS_TECO1'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FCATD[]
    TABLES
      IT_DATA         = GT_TECO1
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FCATD ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F91. "TECO처리상태
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F92. "생산오더
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F93. "메시지
        <LS_FCAT>-JUST = 'L'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_OBJT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_OBJT_POP .
  CREATE OBJECT GCL_POP
    EXPORTING
      I_T_FIELDCATALOG = GT_FCATD[]
      I_S_LAYOUT       = GS_LAYOD
      I_REPID          = SY-REPID
      I_DYNNR          = SY-DYNNR
      I_LEFT           = 300
      I_TOP            = 300
      I_HEIGHT         = 500
      I_WIDTH          = 700.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_ALVG_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_ALVG_POP .
  CALL METHOD GCL_POP->SHOW_DATA
    EXPORTING
      I_T_DATA = GT_TECO1[].
ENDFORM.
