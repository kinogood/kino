FUNCTION ZGTMM_IF_O_PO_ER.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(I_AEDAT) LIKE  SY-DATUM OPTIONAL
*"     VALUE(I_EBELN) LIKE  EKKO-EBELN OPTIONAL
*"  EXPORTING
*"     VALUE(O_RESULT) TYPE  CHAR2
*"     VALUE(O_MESSAGE) TYPE  CHAR100
*"  TABLES
*"      LT_ITAB06 STRUCTURE  ZMMSI06 OPTIONAL
*"      LT_ITAB07 STRUCTURE  ZGTMMSIF0042 OPTIONAL
*"      LT_ITAB32 STRUCTURE  ZMMTI32 OPTIONAL
*"      LT_ITAB39 STRUCTURE  ZMMSI39 OPTIONAL
*"      LT_ITAB52 STRUCTURE  ZMMTI52 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_PO_ER
*& 프로그램 명 : 구매 오더 정보 송신(E-Proc 용)
*& 개요   : 기존 E-Proc 구매 오더 전송 정보에 구매처 필드 1건을 추가(Z_MM_SEND_PO_ER)
*& 생성일 : 2025.02.06
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

* Interal Table Declare....................
  DCL  : IT_EKKO    ZMMTI06,  IT_EKPO  ZMMTI07, IT_RESB  ZMMTI32.
  DCL  : IT_KOLD    ZMMTI06,  IT_POLD  ZMMTI07, IT_ROLD  ZMMTI32.
  DCL  : IT_TXT      ZMMTI39,  IT_TEXT   ZMMTI39.
  DCL  : IT_EVERS   T027B,    IT_VBELN ZMMTI52.

  DATA : GT_CHAR  LIKE ZLES001  OCCURS 0 WITH HEADER LINE.

  RANGES R_EBELN  FOR  EKKO-EBELN.
  RANGES R_ZGROUP FOR  ZPPT0004B-ZGROUP.
  DATA : L_NEW       TYPE I,
         L_OLD       TYPE I,
         L_ZROLEN    LIKE EKPO-MENGE,
         L_ZROLCN    LIKE EKPO-MENGE,
         L_ZROLTO    LIKE EKPO-MENGE,
         LV_INDEX    LIKE SY-TABIX,
         L_FLAG,
         L_NAME1     LIKE KNA1-NAME1,
         L_ORT01     LIKE KNA1-ORT01,
         L_NAME2     LIKE KNA1-NAME1,
         L_ORT02     LIKE KNA1-ORT01,

         L_ZCHARG(5) TYPE N.

*___순중량/총중량
  DATA : LV_MEINS  LIKE MARA-MEINS,
         LV_BRGEW  LIKE MARA-BRGEW,
         LV_NTGEW  LIKE MARA-NTGEW,
         LV_GEWEI  LIKE MARA-GEWEI,
         LV_MTART  LIKE MARA-MTART,
         LV_VRKME  LIKE VBAP-VRKME,
         LV_BRGEW1 LIKE MARA-BRGEW,
         LV_BRGEW2 LIKE MARA-BRGEW,
         LV_ZROLEN LIKE EKPO-MENGE,

         LT_BRGEW  LIKE MARA-BRGEW,
         LT_NTGEW  LIKE MARA-NTGEW.

* 납품요청일....
  DATA : BEGIN OF IT_EKET OCCURS 0,
           EBELN LIKE EKPO-EBELN,
           EBELP LIKE EKPO-EBELP,
           EINDT LIKE EKET-EINDT,
           BANFN LIKE EKET-BANFN,
           BNFPO LIKE EKET-BNFPO,
         END   OF IT_EKET.

  DATA : LV_ZTYPE(30).

* 변경history Table
  DATA: BEGIN OF IT_EBELN OCCURS 0,
          EBELN LIKE EKKO-EBELN,
        END OF IT_EBELN.

* C20120807_609 START
  TABLES ZMMTI82.
* C20120807_609 END

*{ 기능개선 289651 - 추가_S
  DATA: LV_BRGEWP    LIKE VBAP-BRGEW,
        LV_GROES     LIKE MARA-GROES,
        LV_VOLUM     LIKE MARA-VOLUM,
        LV_TEXT1(40),
        LV_TEXT2(40),
        LV_TEXT3(40).

  CLT : IT_EKKO, IT_EKPO, IT_KOLD, IT_POLD, IT_EBKN, R_EBELN.

*___회사코드에 해당하는 플랜트 Range를 가져온다.
  CLEAR   : R_WERKS.
  REFRESH : R_WERKS.

  CALL FUNCTION 'Z_MM_GET_PLANT_RANGE'
    EXPORTING
      I_BUKRS  = C_BUKRS
    TABLES
      ET_WERKS = R_WERKS.

*-. 2008.06.25. Modified By SHIN.
*-. 엠트론으로 분사된 플랜트 제외시키기
  LOOP AT R_WERKS.
    SELECT SINGLE *
      FROM ZMMT0129
     WHERE WERKS EQ R_WERKS-LOW.

    IF SY-SUBRC EQ 0 AND R_WERKS-LOW NE '1204'.
      DELETE R_WERKS.
    ENDIF.
  ENDLOOP.

* 조회일자 SETTING...
  PERFORM DATE_SETTING USING I_AEDAT.

  IF NOT I_EBELN IS INITIAL.
    CLT : R_DATE.
    R_EBELN-SIGN   = 'I'.
    R_EBELN-OPTION = 'EQ'.
    R_EBELN-LOW    = I_EBELN.
    APP R_EBELN.
  ENDIF.
*^v^* ksj_2005.10.06 -- 변경된 po를 먼저 select한다.
  REFRESH IT_EBELN. CLEAR IT_EBELN.
  SELECT DISTINCT A~OBJECTID AS EBELN
    INTO CORRESPONDING FIELDS OF TABLE IT_EBELN
    FROM CDHDR AS A JOIN EKKO AS B ON A~OBJECTID = B~EBELN
   WHERE A~OBJECTCLAS = 'EINKBELEG'
     AND A~UDATE IN R_DATE
     AND B~BUKRS = C_BUKRS
     AND B~EBELN IN R_EBELN.

*- 2006.12.14. Modified By SHIN
*- 서비스 관련 변경된 정보 I/F 처리하기 위해 추가
  SELECT B~EBELN AS EBELN
         APPENDING CORRESPONDING FIELDS OF TABLE IT_EBELN
    FROM CDHDR AS A JOIN EKPO AS B ON A~OBJECTID = B~PACKNO
   WHERE A~OBJECTCLAS = 'MM_SERVICE'
     AND A~UDATE IN R_DATE
     AND A~TCODE LIKE 'ME%'
     AND A~USERNAME NE 'EAIADM'
     AND B~BUKRS = C_BUKRS
     AND B~WERKS IN R_WERKS
     AND B~EBELN IN R_EBELN.
*-

* C20120807_609 START
  SELECT DISTINCT EBELN
    APPENDING CORRESPONDING FIELDS OF TABLE IT_EBELN
    FROM ZMMTI82
   WHERE ERDAT IN R_DATE
     AND WERKS IN R_WERKS
     AND EBELN IN R_EBELN.
* C20120807_609 END


  SELECT DISTINCT EBELN
    APPENDING CORRESPONDING FIELDS OF TABLE @IT_EBELN
    FROM ZMMTI06
   WHERE BUKRS = @C_BUKRS
     AND ZERET > '00'
     AND AEDAT2 EQ @SY-DATUM.

*-{기능개선 57957 - 추가
  SELECT DISTINCT EBELN
    APPENDING CORRESPONDING FIELDS OF TABLE IT_EBELN
    FROM EKBE
   WHERE VGABE EQ '1'
     AND CPUDT IN R_DATE
     AND EBELN IN R_EBELN
     AND WERKS IN R_WERKS.

  SORT IT_EBELN BY EBELN ASCENDING.
*-}기능개선 57957

  DELETE ADJACENT DUPLICATES FROM IT_EBELN COMPARING EBELN.

***********************************************************
** [S] 성공완료 대상 PO 건 제외 by 박우진 (2026.08.11) .
BREAK-POINT.
** ----------------------------------------------------------------------
** [BEFORE - 2026.08.11 최초 로직]
** 문제점: ZERET='00'(성공) AND AEDAT2=SY-DATUM(오늘) 조건만으로
**   "오늘 성공 전송된 PO"를 무조건 제외했음.
**   -> 당일 동일 PO에 변경이 여러 번(N회) 발생하는 경우, 최초 변경건이
**      성공 전송된 이후 추가로 발생한 변경분까지 전부 제외되어 인터페이스
**      누락이 발생함. 날짜(day) 단위 비교로는 "성공 전송이 최신 변경분을
**      반영했는지" 원천적으로 구분이 불가능하기 때문.
**
**  DATA: LS_MMTI06 TYPE ZMMTI06,
**        LT_MMTI06 LIKE TABLE OF LS_MMTI06.
**
**  "당일 정상 완료처리 건 수집.
**  SELECT *
**    INTO CORRESPONDING FIELDS OF TABLE @LT_MMTI06
**    FROM ZMMTI06
**    WHERE ZERET EQ '00'
**    AND  AEDAT2 EQ @SY-DATUM.
**
**  IF LT_MMTI06[] IS NOT INITIAL.
**    LOOP AT LT_MMTI06 INTO LS_MMTI06.
**      DELETE IT_EBELN WHERE EBELN = LS_MMTI06-EBELN.
**    ENDLOOP.
**  ENDIF.
** ----------------------------------------------------------------------
** [AFTER - 2026.08.28 수정 / 박우진]
** ZMMTI06에 성공 전송 시각(DRUHR) 필드를 추가,
** "성공 전송 시각(DRUHR) >= 해당 PO의 CDHDR 당일 최종 변경시각"인
** 경우에만 제외하도록 변경 (일 단위 -> 시간 단위 비교로 정밀화).
** 성공 전송 이후에 추가 변경이 발생했다면 제외하지 않고 그대로 통과시켜
** 뒤쪽 W_CHECK 필드단위 비교 로직에서 다시 판단하도록 함.
** ----------------------------------------------------------------------
  DATA: LS_MMTI06 TYPE ZMMTI06,
        LT_MMTI06 LIKE TABLE OF LS_MMTI06.

  "CDHDR 당일 최종 변경이력(EBELN 별 1건) 저장용
  TYPES: BEGIN OF TY_CDHDR_LAST,
           EBELN    TYPE CDHDR-OBJECTID,
           UDATE    TYPE CDHDR-UDATE,
           UTIME    TYPE CDHDR-UTIME,
           CHANGENR TYPE CDHDR-CHANGENR,
         END OF TY_CDHDR_LAST.

  DATA: LT_CDHDR_LAST TYPE TABLE OF TY_CDHDR_LAST.

  "당일 정상 완료처리 건 수집. (기존과 동일)
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @LT_MMTI06
    FROM ZMMTI06
    WHERE ZERET EQ '00'
    AND  AEDAT2 EQ @SY-DATUM.

  IF LT_MMTI06[] IS NOT INITIAL.

    "해당 PO들의 오늘자 CDHDR 변경이력 조회
    TYPES: BEGIN OF TY_OBJID,
             OBJECTID TYPE CDHDR-OBJECTID,
           END OF TY_OBJID.

    DATA: LT_OBJID TYPE TABLE OF TY_OBJID,
          LS_OBJID TYPE TY_OBJID.

    LOOP AT LT_MMTI06 INTO LS_MMTI06.
      CLEAR LS_OBJID.
      LS_OBJID-OBJECTID = LS_MMTI06-EBELN.
      APPEND LS_OBJID TO LT_OBJID.
    ENDLOOP.
    SORT LT_OBJID BY OBJECTID.
    DELETE ADJACENT DUPLICATES FROM LT_OBJID COMPARING OBJECTID.

    SELECT OBJECTID AS EBELN, UDATE, UTIME, CHANGENR
      INTO CORRESPONDING FIELDS OF TABLE @LT_CDHDR_LAST
      FROM CDHDR
       FOR ALL ENTRIES IN @LT_OBJID
     WHERE OBJECTCLAS = 'EINKBELEG'
       AND OBJECTID    = @LT_OBJID-OBJECTID
       AND UDATE       = @SY-DATUM.

    "EBELN 별 가장 최근 변경이력(1건)만 남긴다.
    "-> UDATE, UTIME, CHANGENR 내림차순 정렬 후 첫 행 = 최신 변경이력
    "   (MAX(UDATE)/MAX(UTIME)를 각각 집계하면 서로 다른 CDHDR 행이
    "    조합될 위험이 있어 이 방식으로 정확히 1건만 채택함)
    SORT LT_CDHDR_LAST BY EBELN
                          UDATE     DESCENDING
                          UTIME     DESCENDING
                          CHANGENR  DESCENDING.
    DELETE ADJACENT DUPLICATES FROM LT_CDHDR_LAST COMPARING EBELN.

    LOOP AT LT_MMTI06 INTO LS_MMTI06.

      READ TABLE LT_CDHDR_LAST INTO DATA(LS_CDHDR_LAST)
           WITH KEY EBELN = LS_MMTI06-EBELN
           BINARY SEARCH.

      IF SY-SUBRC = 0.
        "성공 전송 시각이 최신 변경시각 이상이면(=최신 변경분까지 반영 완료) 제외
        IF LS_MMTI06-DRUHR >= LS_CDHDR_LAST-UTIME.
          DELETE IT_EBELN WHERE EBELN = LS_MMTI06-EBELN.
        ENDIF.
        "ELSE: 성공 전송 이후에 추가 변경 발생 -> 제외하지 않고 통과시켜
        "      뒤쪽 W_CHECK 비교 로직에서 재판단하도록 함.
      ELSE.
        "오늘자 CDHDR 변경이력이 없는 경우(서비스/EKBE 등 다른 유입 경로)
        "-> 기존과 동일하게 성공건으로 보고 제외
        DELETE IT_EBELN WHERE EBELN = LS_MMTI06-EBELN.
      ENDIF.

    ENDLOOP.

  ENDIF.
** [E] 성공완료 대상 PO 건 제외 by 박우진 (2026.08.28, 시간단위 비교로 개선) .
***********************************************************

*^^*
* HEAD변경건 혹은 ITEM변경분 SELECT...
  IF NOT IT_EBELN[] IS INITIAL.
    SELECT DISTINCT K~MANDT K~EBELN K~BUKRS K~EKORG P~WERKS K~BSART
           K~AEDAT  P~PSTYP K~LIFNR K~WAERS K~ZTERM K~EKGRP K~INCO1
           K~INCO2  K~AUTLF K~FRGZU K~ERNAM K~LOEKZ
           P~AEDAT  AS      AEDAT2  P~AEDAT AS      FRGDA
      INTO CORRESPONDING FIELDS OF TABLE IT_EKKO
      FROM EKKO AS K INNER JOIN EKPO AS P
                             ON K~MANDT = P~MANDT AND
                                K~EBELN = P~EBELN
       FOR ALL ENTRIES IN IT_EBELN
     WHERE K~EBELN = IT_EBELN-EBELN
       AND K~EBELN IN R_EBELN
       AND K~EBELN > '4504235000' "2023.12.31 ZITCS4HDEV01 추가
       AND K~BUKRS =  C_BUKRS
       AND K~BSTYP = 'F'
       AND K~MEMORY EQ ' '      "보류는 제외
       AND P~WERKS IN R_WERKS
       AND P~PSTYP <> '7'       "재고이전은 제외
*-----------------------------------------------------------------------
* 2006.12.11. Modified By SHIN
* 내용 : 반품오더는 e-Proc로 넘기지 않는다.
* 요청자 : 이길상K, 김진Con.
*-----------------------------------------------------------------------
       AND P~RETPO = ' '        "반품오더는 제외
*-----------------------------------------------------------------------
       AND ( P~KNTTP <> 'U' AND
             P~KNTTP <> 'W' )
       AND K~BSART <> 'NBXE'.

*->2024.01.16 ZITCS4HDEV01 추가
    SELECT DISTINCT K~MANDT K~EBELN K~BUKRS K~EKORG P~WERKS K~BSART
           K~AEDAT  P~PSTYP K~LIFNR K~WAERS K~ZTERM K~EKGRP K~INCO1
           K~INCO2  K~AUTLF K~FRGZU K~ERNAM K~LOEKZ
           P~AEDAT  AS      AEDAT2  P~AEDAT AS      FRGDA
 APPENDING CORRESPONDING FIELDS OF TABLE IT_EKKO
      FROM EKKO AS K INNER JOIN EKPO AS P
                             ON K~MANDT = P~MANDT AND
                                K~EBELN = P~EBELN
       FOR ALL ENTRIES IN IT_EBELN
     WHERE K~EBELN = IT_EBELN-EBELN
       AND K~EBELN IN R_EBELN
       AND K~EBELN BETWEEN '4500000000' AND '4504235000'
       AND ( P~LOEKZ = 'X' OR P~ELIKZ = 'X' )
       AND K~BUKRS =  C_BUKRS
       AND K~BSTYP = 'F'
       AND K~MEMORY EQ ' '      "보류는 제외
       AND P~WERKS IN R_WERKS
       AND P~PSTYP <> '7'       "재고이전은 제외
*-----------------------------------------------------------------------
* 2006.12.11. Modified By SHIN
* 내용 : 반품오더는 e-Proc로 넘기지 않는다.
* 요청자 : 이길상K, 김진Con.
*-----------------------------------------------------------------------
       AND P~RETPO = ' '        "반품오더는 제외
*-----------------------------------------------------------------------
       AND ( P~KNTTP <> 'U' AND
             P~KNTTP <> 'W' )
       AND K~BSART <> 'NBXE'.
*<-
  ENDIF.

  CHECK NOT IT_EKKO[] IS INITIAL.
* WERKS때문에 중복이 발생.........
*-[START_33071]
  SORT IT_EBELN BY EBELN.
*-[END_33071]
  DELETE ADJACENT DUPLICATES FROM IT_EKKO COMPARING EBELN.

*^v^* ksj_2005.10.05 -- 서브원의 입고잡은것은 제외
  LOOP AT IT_EKKO.
    LV_INDEX = SY-TABIX.
*    CHECK IT_EKKO-LIFNR = '0000100548'.
    CHECK IT_EKKO-LIFNR = '0000136766'.
    CLEAR EKBE.
    SELECT SINGLE * FROM EKBE WHERE EBELN = IT_EKKO-EBELN
                                AND BWART = '101'.
    IF SY-SUBRC = 0.
      DELETE IT_EKKO INDEX LV_INDEX. CONTINUE.
    ENDIF.
  ENDLOOP.

  CHECK NOT IT_EKKO[] IS INITIAL.
*^v^*
* ITEM정보........................
  SELECT MANDT EBELN EBELP MATNR TXZ01 AS    MAKTX
         MENGE MEINS BRTWR NETPR WERKS LGORT MATKL
         KNTTP PSTYP BEDNR AEDAT AS AEDAT2   LOEKZ
         BANFN BNFPO AFNAM BSTAE ELIKZ EVERS KUNNR
         EMLIF PACKNO PEINH UEBTO UNTTO MWSKZ
    INTO CORRESPONDING FIELDS OF TABLE IT_EKPO
    FROM EKPO
     FOR ALL ENTRIES IN IT_EKKO
   WHERE EBELN = IT_EKKO-EBELN.

*--------------------------------------------------------
*  CSR No:C2006062001000000225
*  외주가공 구성부품이 변경되었는지 CHECK
*  2006.06.20. Modified By SHIN
*--------------------------------------------------------
  CLEAR: IT_RESB[], IT_RESB.
  LOOP AT IT_EKPO.
*-. 2008.06.30. Modified By SHIN.
*-. 1204 플랜트에 해당하는 제품군 : 50, 53, 55, 58 제외
    IF IT_EKPO-WERKS EQ '1204'.
      CLEAR MARA.
      SELECT SINGLE B~MATNR INTO MARA-MATNR
        FROM MARC AS A JOIN MARA     AS B ON A~MATNR = B~MATNR
                       JOIN ZMMT0129 AS C ON A~WERKS = C~WERKS
       WHERE A~WERKS EQ IT_EKPO-WERKS
         AND B~MATNR EQ IT_EKPO-MATNR.

      IF SY-SUBRC NE 0.
        IF IT_EKPO-MAKTX+0(4) EQ 'SBG_'.
          "Pass
        ELSE.
          DELETE IT_EKPO.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    IF IT_EKPO-PSTYP = '3'.
      SELECT MANDT RSNUM RSPOS RSART EBELN EBELP
             MATNR BAUGR ERFMG ERFME LIFNR
        INTO CORRESPONDING FIELDS OF IT_RESB
        FROM RESB
       WHERE EBELN EQ IT_EKPO-EBELN
         AND EBELP EQ IT_EKPO-EBELP
         AND BAUGR EQ IT_EKPO-MATNR.
*         AND lifnr EQ it_ekpo-lifnr.

        APPEND IT_RESB. CLEAR IT_RESB.

      ENDSELECT.
    ENDIF.

  ENDLOOP.
*--------------------------------------------------------
*  END CSR No:C2006062001000000225
*--------------------------------------------------------

*-. 2008.06.30. Modified By SHIN.
*-. item에 존재하지 않으면 헤더도 삭제
  LOOP AT IT_EKKO.
    CLEAR IT_EKPO.
    READ TABLE IT_EKPO WITH KEY EBELN = IT_EKKO-EBELN.

    IF SY-SUBRC NE 0.
      DELETE IT_EKKO.
    ENDIF.
  ENDLOOP.

* 납품요청일........................
  SELECT EBELN EBELP EINDT BANFN BNFPO INTO TABLE IT_EKET
    FROM EKET
     FOR ALL ENTRIES IN IT_EKPO
   WHERE EBELN = IT_EKPO-EBELN
     AND EBELP = IT_EKPO-EBELP.

* 출하지시텍스트....................
  SELECT * INTO TABLE IT_EVERS
    FROM T027B
   WHERE SPRAS = SY-LANGU.

* EKPO에 구매요청번호가 없는경우....EKET를 기준으로...
  SORT IT_EKET BY EBELN EBELP.
  LOOP AT IT_EKPO WHERE BANFN IS INITIAL.
    READ TABLE IT_EKET WITH KEY EBELN = IT_EKPO-EBELN
                                EBELP = IT_EKPO-EBELP
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      IT_EKPO-BANFN = IT_EKET-BANFN.
      IT_EKPO-BNFPO = IT_EKET-BNFPO.
    ELSE.
      SELECT SINGLE BANFN BNFPO
        INTO (IT_EKPO-BANFN, IT_EKPO-BNFPO)
        FROM EBAN
       WHERE EBELN = IT_EKPO-EBELN
         AND EBELP = IT_EKPO-EBELP.
    ENDIF.
    MODIFY IT_EKPO TRANSPORTING BANFN BNFPO.
  ENDLOOP.

*-------------------------------------------------------------------
* CSR NO:C2006042601000000315
* 수정일자:2006.04.26. Modified By SHIN.
* 내용:PO의 판매오더 필드 정보 인터페이스 추가
*-------------------------------------------------------------------
* 하역장소...수령인.................
  SELECT EBELN EBELP PS_PSP_PNR ABLAD WEMPF AUFNR VBELN VBELP
    INTO TABLE IT_EKKN
    FROM EKKN
     FOR ALL ENTRIES IN IT_EKPO
   WHERE EBELN = IT_EKPO-EBELN
     AND EBELP = IT_EKPO-EBELP
     AND ZEKKN = '01'.
*-------------------------------------------------------------------
* END CSR NO:C2006042601000000315
*-------------------------------------------------------------------

* HEAD 정보 수정....................(릴리즈일자...)
  SORT IT_EKPO BY EBELN EBELP LOEKZ.
  LOOP AT IT_EKKO.
    SELECT COUNT(*) FROM LFA1
     WHERE LIFNR = IT_EKKO-LIFNR
       AND KTOKK IN ('1000', '2000'). "-->내자..
    IF SY-DBCNT = 0.
      IT_EKKO-ZSHIP = 'O'.            "외자
    ELSE.
      IT_EKKO-ZSHIP = 'D'.            "내자..
    ENDIF.
    LOOP AT IT_EKPO WHERE EBELN = IT_EKKO-EBELN.
      ADD IT_EKPO-BRTWR TO IT_EKKO-ZAMT.
*     ITEM생성일이 가장큰것을 변경일자로한다....
      IF IT_EKKO-AEDAT2 < IT_EKPO-AEDAT2.
        IT_EKKO-AEDAT2 = IT_EKPO-AEDAT2.
      ENDIF.
    ENDLOOP.
*   ITEM이 모두 삭제 FLAG설정이면 HEAD를 삭제로...
    CLEAR IT_EKPO.
    SORT IT_EKPO BY EBELN LOEKZ.
    READ TABLE IT_EKPO WITH KEY EBELN = IT_EKKO-EBELN
                                LOEKZ = ' '
                       BINARY SEARCH.
    IF SY-SUBRC <> 0.  IT_EKKO-LOEKZ = 'D'. ENDIF.
    IT_EKKO-FRGZU = 'C'.
    MODIFY IT_EKKO.
  ENDLOOP.

* ITEM정보 수정.......................
  SORT IT_EKKN BY EBELN EBELP.

*----------------------------------------------------------------------*
*- 2007.03.26. Modified By SHIN / Requested By 윤종섭/특수선생산지원팀
*- 내용 : 판매오더 세부정보 I/F
*----------------------------------------------------------------------*
  CLEAR: IT_VBELN[], IT_VBELN.
  LOOP AT IT_EKKN WHERE VBELN NE ' '.

    LOOP AT IT_EKPO WHERE EBELN EQ IT_EKKN-EBELN
                      AND EBELP EQ IT_EKKN-EBELP
*                      AND kunnr NE ' '
                      .

      MOVE: '100'         TO IT_VBELN-MANDT,
            IT_EKKN-EBELN TO IT_VBELN-EBELN,
            IT_EKKN-EBELP TO IT_VBELN-EBELP,
            IT_EKKN-VBELN TO IT_VBELN-VBELN,
            IT_EKKN-VBELP TO IT_VBELN-VBELP,
            IT_EKPO-MATNR TO IT_VBELN-MATNR,
            IT_EKPO-MENGE TO IT_VBELN-MENGE.

*--> [CHM2603-00775] 판매오더 승인정보 추가
      SELECT SINGLE
             ZSHIP1 ZSHIP2
        INTO (IT_VBELN-ZSHIP1, IT_VBELN-ZSHIP2)
        FROM VBAK
       WHERE VBELN = IT_EKKN-VBELN.
*<-- [CHM2603-00775] 판매오더 승인정보 추가

*-    판매처 & 납품처
      SELECT SINGLE KUNNR INTO IT_VBELN-PKUNNR
        FROM VBPA
       WHERE VBELN = IT_EKKN-VBELN
         AND PARVW = 'AG'.

      SELECT SINGLE KUNNR INTO IT_VBELN-NKUNNR
        FROM VBPA
       WHERE VBELN = IT_EKKN-VBELN
         AND PARVW = 'WE'.

*-    고객 PO 번호
      SELECT SINGLE BSTKD INTO IT_VBELN-BSTKD
        FROM VBKD
       WHERE VBELN = IT_EKKN-VBELN
         AND POSNR = '000000'.

*-    납품요청일
      SELECT SINGLE EDATU INTO IT_VBELN-EDATU
        FROM VBEP
       WHERE VBELN = IT_EKKN-VBELN
         AND POSNR = IT_EKKN-VBELP
         AND ETENR  = '0001'.

*-    인도처 업체명 & 주소
      SELECT SINGLE NAME1 ORT01 INTO (L_NAME1, L_ORT01)
        FROM KNA1
       WHERE KUNNR = IT_VBELN-NKUNNR.

      CONCATENATE L_NAME1 L_ORT01
             INTO IT_VBELN-ZADDR
        SEPARATED BY '//'.

*{ 기능개선 289651 - 추가_S
      IF IT_VBELN-VBELN IS NOT INITIAL.
*___판매처명
        SELECT SINGLE NAME1
          INTO IT_VBELN-NAMAG
          FROM KNA1
         WHERE KUNNR = IT_VBELN-PKUNNR.

*___납품처명
        SELECT SINGLE NAME1
          INTO IT_VBELN-NAMWE
          FROM KNA1
         WHERE KUNNR = IT_VBELN-NKUNNR.

*___기본단위조장/판매단위조장/포장재
        PERFORM GET_SO_CHARACTERISTIC(ZSDC0430)
         USING: IT_VBELN-VBELN
                IT_VBELN-VBELP
                'SAP_MILLCA_LENGTH'
                IT_VBELN-INDLEN_B,

                IT_VBELN-VBELN
                IT_VBELN-VBELP
                'SAP_LENGTH_VKRME'
                IT_VBELN-INDLEN_S,

                IT_VBELN-VBELN
                IT_VBELN-VBELP
                'SAP_MILLCA_PACKAGING'
                IT_VBELN-PCKMAT.

*___기본단위/순중량(kg/1M)
        CLEAR : LV_NTGEW, LV_BRGEW, LV_GEWEI.

        SELECT SINGLE MEINS
                      NTGEW
                      BRGEW
                      GEWEI
          INTO (IT_VBELN-MEINS, LV_NTGEW,
                LV_BRGEW,       LV_GEWEI)
          FROM MARA
         WHERE MATNR = IT_VBELN-MATNR.

*___자재내역/판매단위/출력고객구분/포장구분
        SELECT SINGLE A~ARKTX
                      A~VRKME
                      B~ZCUST
                      B~ZWDTY
          INTO (IT_VBELN-ARKTX, IT_VBELN-VRKME,
                IT_VBELN-ZCUST, IT_VBELN-ZWDTY)
          FROM VBAP AS A
         INNER JOIN VBAK AS B
            ON A~VBELN = B~VBELN
         WHERE A~VBELN = IT_VBELN-VBELN
           AND A~POSNR = IT_VBELN-VBELP.

*___드럼번호
        SELECT SINGLE EMPST
          INTO IT_VBELN-EMPST
          FROM VBKD
         WHERE VBELN = IT_VBELN-VBELN
           AND POSNR = IT_VBELN-VBELP.

*___순중량 - 기본단위조장 * 자재마스터 순중량
        IT_VBELN-NTGEW = IT_VBELN-INDLEN_B * LV_NTGEW.

        PERFORM CONVERT_MATERIAL_UNIT USING IT_VBELN-MATNR
                                            LV_GEWEI
                                            'KG'
                                            IT_VBELN-NTGEW.

*___포장재 중량
        CLEAR : LV_BRGEWP, LV_VOLUM, LV_GROES.

        CALL FUNCTION 'Z_LE_PK_WD_COMPUTE_JS'
          EXPORTING
            I_MATNR      = IT_VBELN-PCKMAT
            I_PK_WD_TYPE = IT_VBELN-ZWDTY
            I_WERKS      = IT_EKPO-WERKS
          IMPORTING
            E_BRGEW      = LV_BRGEWP
            E_VOLUM      = LV_VOLUM
            E_GROES      = LV_GROES.


        IT_VBELN-PKGEW = LV_BRGEWP.

*___제원(Cm)
        CLEAR : LV_TEXT1, LV_TEXT2, LV_TEXT3.

        SPLIT LV_GROES AT 'X' INTO LV_TEXT1 LV_TEXT2.

        LV_TEXT1 = LV_TEXT1 / 10.   "mm -> cm 로 변환
        LV_TEXT2 = LV_TEXT2 / 10.
        CONDENSE: LV_TEXT1, LV_TEXT2.

        CONCATENATE LV_TEXT1 LV_TEXT2 LV_TEXT1
               INTO IT_VBELN-GROES SEPARATED BY 'X'.
      ELSE.
*___자재내역
        SELECT SINGLE MAKTX
          INTO IT_VBELN-ARKTX
          FROM MAKT
         WHERE MATNR = IT_VBELN-MATNR
           AND SPRAS = SY-LANGU.
      ENDIF.
*} 기능개선 289651 - 추가_E

      APPEND IT_VBELN.  CLEAR IT_VBELN.
    ENDLOOP.

  ENDLOOP.

  REFRESH LT_ITAB52.
  LT_ITAB52[] = IT_VBELN[].
*----------------------------------------------------------------------*
* 판매오더 정보 조회 끝!!
*----------------------------------------------------------------------*

  LOOP AT IT_EKPO.
*- 기계오픈 후 수정요청사항
*- 내용 : MRP관리자 & 명추가
*- 자재코드 존재하는 것만...
*- 2006.12.05 Modified By SHIN
    IF IT_EKPO-MATNR IS NOT INITIAL.

      SELECT SINGLE DISPO INTO IT_EKPO-DISPO
        FROM MARC
       WHERE MATNR = IT_EKPO-MATNR
         AND WERKS = IT_EKPO-WERKS.

      SELECT SINGLE DSNAM INTO IT_EKPO-DSNAM
        FROM T024D
       WHERE WERKS = IT_EKPO-WERKS
         AND DISPO = IT_EKPO-DISPO.

*- C20120615_28245
      SELECT SINGLE MATNR_C INTO IT_EKPO-MATNR_C
        FROM ZPPT0158
       WHERE MATNR = IT_EKPO-MATNR.
*- C20120615_28245

*-{ 자체개선 273289 - 재료규격 추가
      SELECT SINGLE ZMATSD INTO IT_EKPO-ZMATSD
        FROM ZEDT3002J
       WHERE BUKRS = C_BUKRS
         AND MATNR = IT_EKPO-MATNR
         AND LOEKZ = ' '.
*-} 자체개선 273289

    ENDIF.

*    한계값이 있는지 체크해서 소액/일반공사구분값으로 사용한다.
    SELECT SINGLE SUMLIMIT INTO IT_EKPO-SUMLIMIT
    FROM ESUH
    WHERE PACKNO = IT_EKPO-PACKNO.

    READ TABLE IT_EKET WITH KEY EBELN = IT_EKPO-EBELN
                                EBELP = IT_EKPO-EBELP
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      IT_EKPO-EINDT = IT_EKET-EINDT.
    ENDIF.
*   생성일은 EKKO에서 변경일은 EKPO에서 SELECT...
    READ TABLE IT_EKKO WITH KEY EBELN = IT_EKPO-EBELN.
    MOVE : IT_EKKO-LIFNR TO IT_EKPO-LIFNR,
           IT_EKKO-ERNAM TO IT_EKPO-ERNAM,
           IT_EKKO-AEDAT TO IT_EKPO-AEDAT.
*   특성정보를 SELECT한다..
    PERFORM GET_OTHER_DATA USING IT_EKPO.
**   LONG_TEXT 가져오기.....
*    PERFORM longtext_view  USING it_ekpo.
    CASE IT_EKPO-LOEKZ.
      WHEN ' '.
      WHEN 'L'.
        IT_EKPO-LOEKZ = 'D'.
    ENDCASE.

*   하역지점..수령인...
    READ TABLE IT_EKKN WITH KEY EBELN = IT_EKPO-EBELN
                                EBELP = IT_EKPO-EBELP
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      MOVE : IT_EKKN-AUFNR  TO IT_EKPO-AUFNR,
             IT_EKKN-ABLAD  TO IT_EKPO-ABLAD,
             IT_EKKN-WEMPF  TO IT_EKPO-WEMPF,
*------------CSR:C2006042601000000315
             IT_EKKN-VBELN  TO IT_EKPO-VBELN,
             IT_EKKN-VBELP  TO IT_EKPO-VBELP.
*------------END CSR.
    ENDIF.

*-. 2007.07.11. 계정지정범주가 'M'인 경우
*-. 판매오더의 납품처코드/납품처명,주소 I/F
    IF IT_EKPO-KNTTP = 'M'.
      CLEAR: L_NAME2, L_ORT02.

      SELECT SINGLE KUNNR INTO IT_EKPO-KUNWE
        FROM VBPA
       WHERE VBELN = IT_EKPO-VBELN
         AND PARVW = 'WE'.

*-    납품처 업체명 & 주소
      SELECT SINGLE NAME1 ORT01 INTO (L_NAME2, L_ORT02)
        FROM KNA1
       WHERE KUNNR = IT_EKPO-KUNWE.

      CONCATENATE L_NAME2 L_ORT02
             INTO IT_EKPO-ZADDR
        SEPARATED BY '//'.
    ENDIF.

    IF IT_EKPO-WERKS = '1306'. "(S)부스닥트 로직 추가(PSJ 25.03.31)
      DATA(LV_MAKTX) = IT_EKPO-MAKTX.
    ENDIF.                     "(E)부스닥트 로직 추가(PSJ 25.03.31)

* 자재품명 80자리 가져오기
*-. 2009.06.05 색상 SPEC 가지고 오기
    CLEAR MARA.
    SELECT SINGLE ZZMAKTX80 DPCBT
                  ZZCOLOR_BASE ZZCOLOR_STRIPE "기능개선 312355 추가
                  ZZSPEC_NO ZZIDEN_CODE
      INTO (IT_EKPO-MAKTX, IT_EKPO-DPCBT,
            IT_EKPO-ZZCOLOR_BASE, IT_EKPO-ZZCOLOR_STRIPE,
            IT_EKPO-ZZSPEC_NO, LV_ZTYPE)
      FROM MARA
     WHERE MATNR = IT_EKPO-MATNR
       AND ZZMAKTX80 <> ' '.

    IF IT_EKPO-WERKS = '1306'. "(S)부스닥트 로직 추가(PSJ 25.03.31)
      IT_EKPO-MAKTX = LV_MAKTX.
    ENDIF.                     "(E)부스닥트 로직 추가(PSJ 25.03.31)

*^^*_ksj_2005.09.23 -- Batch 관리 추가
    IF IT_EKPO-MATKL+4(3) = 'CST' OR
       IT_EKPO-MATKL+4(3) = 'COT'.
      IT_EKPO-DPCBT = 'C'.
    ENDIF.

    SELECT SINGLE ZTYPE2
      INTO IT_EKPO-ZZIDEN_CODE
      FROM ZPPT0004
     WHERE ZGROUP = '2' " 색상
       AND ZTYPE1 = LV_ZTYPE.

**품명이 FAVS이고 색상이 BN이면 BR로 표기
    IF GV_DESC = 'FAVS' AND IT_EKPO-ZZIDEN_CODE = 'BN'.
      IT_EKPO-ZZIDEN_CODE = 'Br'.
    ENDIF.

**품명이 FAVS이고 색상이 TA이면 TA로 표기
    IF GV_DESC = 'FAVS' AND IT_EKPO-ZZIDEN_CODE = 'TA'.
      IT_EKPO-ZZIDEN_CODE = 'Ta'.
    ENDIF.

*-<< 기능개선 297713 - 자동차전선 외주라벨용 유라코드 추가
    DATA : L_ATWRT_1  LIKE AUSP-ATWRT,                       "품명
           L_ATFLV_2  LIKE AUSP-ATFLV,                       "규격1
           L_ATWRT_3  LIKE AUSP-ATWRT,                       "규격2
           L_ZUCODE_1 LIKE ZPPT0004-ZUCODE,                  "품명
           L_ZUCODE_2 LIKE ZPPT0004-ZUCODE,                  "색상
           L_ZUCODE_3 LIKE ZPPT0004-ZUCODE.                  "규격
    DATA : L_DEC(15)  TYPE P DECIMALS 0,
           L_CHAR(30).

    CLEAR L_ATWRT_1.
    SELECT SINGLE ATWRT INTO L_ATWRT_1
      FROM AUSP
     WHERE OBJEK = IT_EKPO-MATNR
*       AND ATINN = '0000000573'. "품명
      AND ATINN = '0000004693'. "품명
*      AND ATINN = 'PD_AA_STD_PRODUCT_NAME'.

    IF SY-SUBRC = 0.
      CLEAR L_ZUCODE_1.
      SELECT SINGLE ZUCODE
        INTO L_ZUCODE_1
        FROM ZPPT0004
       WHERE ZGROUP = '1'  "품명
         AND ZTYPE1 = L_ATWRT_1.
    ENDIF.

    CLEAR L_ZUCODE_2.
    SELECT SINGLE ZUCODE
      INTO L_ZUCODE_2
      FROM ZPPT0004
     WHERE ZGROUP = '2' " 색상
       AND ZTYPE1 = LV_ZTYPE.

    CLEAR L_ATFLV_2.
    SELECT SINGLE ATFLV INTO L_ATFLV_2
      FROM AUSP
     WHERE OBJEK = IT_EKPO-MATNR
*       AND ATINN = '0000000626'. "PD_CA_CORE_NO_1ST
      AND ATINN = '00000005952'.
*      AND ATINN = 'PD_CA_CORE_NO_1ST'.

    CLEAR : L_DEC, L_CHAR.
    IF SY-SUBRC = 0.
      L_DEC = L_ATFLV_2.
      WRITE L_DEC TO L_CHAR LEFT-JUSTIFIED .
    ENDIF.

    CLEAR L_ATWRT_3.
    SELECT SINGLE ATWRT INTO L_ATWRT_3
      FROM AUSP
     WHERE OBJEK = IT_EKPO-MATNR
*       AND ATINN = '0000001059'. "PD_CA_COND_SIZE_1ST
        AND ATINN = '0000006050'. "PD_CA_COND_SIZE_1ST
*       AND ATINN = 'PD_CA_COND_SIZE_1ST'.

    IF L_CHAR IS NOT INITIAL AND L_ATWRT_3 IS NOT INITIAL.
      CONCATENATE L_CHAR 'X' L_ATWRT_3 INTO L_ATWRT_3.

      CLEAR L_ZUCODE_3.
      SELECT SINGLE ZUCODE
        INTO L_ZUCODE_3
        FROM ZPPT0004
       WHERE ZGROUP = '3'  "규격
         AND ZTYPE1 = L_ATWRT_3.
    ENDIF.

    IF L_ZUCODE_1 IS NOT INITIAL AND
       L_ZUCODE_2 IS NOT INITIAL AND
       L_ZUCODE_3 IS NOT INITIAL.

      "‘P’ + 품명 + 규격 + 색상
      CONCATENATE 'P' L_ZUCODE_1 L_ZUCODE_3 L_ZUCODE_2
             INTO IT_EKPO-ZUCODE1.
    ENDIF.
*->> 기능개선 297713

*   조장*조장수 & 발주수량을 비교해서 틀리면 조장수 Clear
*   2006.02.06. Requested By 이정익D. Modified By SHIN
    MOVE : IT_EKPO-ZROLEN TO L_ZROLEN,
           IT_EKPO-ZROLCN TO L_ZROLCN.

    L_ZROLTO = L_ZROLEN * L_ZROLCN.

    IF L_ZROLTO <> IT_EKPO-MENGE.
      CLEAR IT_EKPO-ZROLCN.
    ENDIF.

*->> 기능개선  CHM2010-00131
* 조장만 있고 조장수가 없을 경우 "발주수량 / 조장" 으로 조장수 자동 계산

    IF IT_EKPO-ZROLCN IS INITIAL AND
        IT_EKPO-WERKS  EQ '1404'  AND
        L_ZROLEN IS NOT INITIAL.
      IT_EKPO-ZROLCN = IT_EKPO-MENGE / L_ZROLEN.
    ENDIF.

    "--> 조장수 0 = NULL 일 시 1로 치환
    IF IT_EKPO-ZROLCN IS INITIAL OR IT_EKPO-ZROLCN = '0'.
      IT_EKPO-ZROLCN = '1'.
    ENDIF.
    "<-- 조장수 0 = NULL 일 시 1로 치환

***___순중량/총중량
    IF IT_EKPO-VBELN NE ' '.
* 주문특성
      REFRESH: GT_CHAR.
      PERFORM GET_CHARACTERISTIC(ZLER0001) TABLES GT_CHAR
                                 USING IT_EKPO-VBELN
                                       IT_EKPO-VBELP
                                       IT_EKPO-WERKS
                                       IT_EKPO-MATNR.
*  속도개선 위해 개발에서 테스트 및 검증. 운영반영은 추후 예정 (2026.08.07).
*      PERFORM get_characteristic TABLES gt_char
*                                 USING it_ekpo-vbeln
*                                       it_ekpo-vbelp
*                                       it_ekpo-werks
*                                       it_ekpo-matnr.

      IF NOT GT_CHAR[] IS INITIAL.
* 조장
        READ TABLE GT_CHAR WITH KEY ATNAM = 'SAP_LENGTH_VKRME'.
        IF SY-SUBRC = 0.
          LV_ZROLEN = GT_CHAR-ATWRT.
        ENDIF.
      ENDIF.
*-. 2009.06.05. Drump No 추가
      SELECT SINGLE EMPST INTO IT_EKPO-EMPST
        FROM VBKD
       WHERE VBELN = IT_EKPO-VBELN
         AND POSNR = IT_EKPO-VBELP.

      CLEAR : LV_MEINS, LV_BRGEW, LV_NTGEW, LV_GEWEI,
              LV_MTART, LV_VRKME.

      SELECT SINGLE MEINS BRGEW NTGEW GEWEI MTART
        INTO (LV_MEINS, LV_BRGEW, LV_NTGEW, LV_GEWEI, LV_MTART)
        FROM MARA
       WHERE MATNR = IT_EKPO-MATNR.

*-. 2009.06.05. 총중량 순중량
      SELECT SINGLE VRKME
        INTO LV_VRKME
        FROM VBAP
       WHERE VBELN EQ IT_EKPO-VBELN
         AND POSNR EQ IT_EKPO-VBELP.

      IF LV_VRKME = LV_MEINS.
        CLEAR : LV_BRGEW1.
        LV_BRGEW1 = LV_ZROLEN * LV_NTGEW.
*        lv_brgew1 = it_ekpo-zrolcn * lv_ntgew.
        PERFORM CONVERT_MATERIAL_UNIT USING IT_EKPO-MATNR
                                            LV_GEWEI
                                            'KG'
                                            LV_BRGEW1.
*// 포장목 반영 총중량 구하기 위한 순중량
        CLEAR : LV_BRGEW2.
        LV_BRGEW2 = LV_BRGEW1.

*// 총중량 구하기
        CLEAR : LV_BRGEW1.
        LV_BRGEW1 = LV_ZROLEN * LV_BRGEW.
*        lv_brgew1 = it_ekpo-zrolcn * lv_brgew.
        PERFORM CONVERT_MATERIAL_UNIT USING IT_EKPO-MATNR
                                            LV_GEWEI
                                            'KG'
                                            LV_BRGEW1.

      ELSE.                     "자재 기본단위와 판매단위가 다른 경우
        CLEAR : LT_BRGEW, LT_NTGEW.
        LV_BRGEW1 = LV_ZROLEN.
*        lv_brgew1 = it_ekpo-zrolen.
        PERFORM CONVERT_MATERIAL_UNIT USING IT_EKPO-MATNR
                                            LV_VRKME
                                            LV_MEINS
                                            LV_BRGEW1.
*// 총중량 구하기
        LT_BRGEW = LV_BRGEW1 * LV_BRGEW.
*// 순중량 구하기
        LT_NTGEW = LV_BRGEW1 * LV_NTGEW.

        LV_BRGEW1 = LT_NTGEW.
        PERFORM CONVERT_MATERIAL_UNIT USING IT_EKPO-MATNR
                                            LV_GEWEI
                                            'KG'
                                            LV_BRGEW1.

*// 포장목 반영 총중량 구하기 위한 순중량
        CLEAR : LV_BRGEW2.
        LV_BRGEW2 = LV_BRGEW1.

        LV_BRGEW1 = LT_BRGEW.
        PERFORM CONVERT_MATERIAL_UNIT USING IT_EKPO-MATNR
                                            LV_GEWEI
                                            'KG'
                                            LV_BRGEW1.

* [END] CSR NO : C20090110_83898
      ENDIF.

      MOVE : LV_BRGEW2 TO IT_EKPO-NTGEW,  " 순중량
             LV_BRGEW1 TO IT_EKPO-BRGEW.  " 총중량

    ENDIF.

*-. 자동차전선 배치번호 넘기기
*-. 2009.10.29
    IF IT_EKPO-WERKS EQ '1202'
*-{기능개선 68090 - 추가
      OR IT_EKPO-WERKS EQ '1306'  "부스닥트
      OR IT_EKPO-WERKS EQ '1205'  "H&M
      OR IT_EKPO-WERKS EQ '1206'. "H&M "기능개선 108591- H&M 플랜트변경
*-}기능개선 68090
      CLEAR L_ZCHARG.
      MOVE IT_EKPO-ZROLEN TO L_ZCHARG.
      L_ZCHARG = L_ZCHARG + 1.

      MOVE L_ZCHARG TO IT_EKPO-ZCHARG.
    ENDIF.

*-<< 기능개선 152029 - 부스닥트 면적수량/단위/단가/가격단위 추가
    IF IT_EKPO-WERKS EQ '1306' AND
       IT_EKPO-KNTTP EQ 'M' AND
       IT_EKPO-PSTYP EQ '3'.
      PERFORM SELECT_ZPPTIF33 USING IT_EKPO.
    ENDIF.
*->> 기능개선 152029

*-<< 기능개선 CHM2408-00118 - 고객사 납품코드 정보 추가
    DATA(LV_ZGROUP) = 'E'.
*    IF NOT r_zgroup IS INITIAL.
*      clt : r_zgroup.
*      r_zgroup-sign   = 'I'.
*      r_zgroup-option = 'EQ'.
*      r_zgroup-low    = lv_zgroup.
*      app r_zgroup.
*    ENDIF.
    SELECT ZGROUP, MATNR2, MAKTX, ZCOLOR
      FROM ZPPT0004B
      WHERE ZGROUP EQ @LV_ZGROUP
            AND MATNR EQ @IT_EKPO-MATNR
      INTO ( @IT_EKPO-ZGROUP, @IT_EKPO-MATNR2, @IT_EKPO-MAKTX2, @IT_EKPO-ZCOLOR ).
    ENDSELECT.
*->> 기능개선 CHM2408-00118

    MODIFY IT_EKPO. CLEAR IT_EKPO.
  ENDLOOP.

  IF I_AEDAT IS INITIAL AND I_EBELN IS INITIAL.
*   기전송정보 SELECT....(HEAD)..
    SELECT MANDT EBELN BUKRS EKORG WERKS BSART PSTYP AEDAT LIFNR
           WAERS ZTERM EKGRP ZSHIP ZAMT  INCO1 INCO2 AUTLF FRGZU
           FRGDA ERNAM LOEKZ AEDAT2
      INTO CORRESPONDING FIELDS OF TABLE IT_KOLD
      FROM ZMMTI06
       FOR ALL ENTRIES IN IT_EKKO
     WHERE EBELN = IT_EKKO-EBELN
       AND ZERET = '00'.          "전송성공분만...
*   .....................(ITEM)..
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_POLD
      FROM ZMMTI07 AS OLD
       FOR ALL ENTRIES IN IT_EKKO
     WHERE EBELN = IT_EKKO-EBELN
     AND EXISTS ( SELECT EBELN FROM ZMMTI06 WHERE EBELN = OLD~EBELN
                                                AND ZERET = '00' ).

*--------------------------------------------------------
*  CSR No:C2006062001000000225
*  외주가공 구성부품이 변경되었는지 CHECK
*  2006.06.20. Modified By SHIN
*--------------------------------------------------------
    CLEAR: IT_ROLD[], IT_ROLD.
    LOOP AT IT_EKPO.
      IF IT_EKPO-PSTYP = '3'.
        SELECT * INTO CORRESPONDING FIELDS OF IT_ROLD
          FROM ZMMTI32
         WHERE EBELN = IT_EKPO-EBELN
           AND EBELP = IT_EKPO-EBELP
           AND ZERET = '00'.

          APPEND IT_ROLD.  CLEAR IT_ROLD.

        ENDSELECT.
      ENDIF.
    ENDLOOP.

  ENDIF.
*--------------------------------------------------------
*  END CSR No:C2006062001000000225
*--------------------------------------------------------

*- [CHM2407-00134] 품목 텍스트가 변경되었는지 Check
  CLEAR : IT_TEXT[], IT_TEXT, IT_TXT[], IT_TXT.
  LOOP AT IT_EKPO.
    PERFORM LONGTEXT_VIEW_C USING IT_EKPO
                                   IT_TXT.
    IF SY-SUBRC = 0.
      APPEND : IT_TXT. CLEAR : IT_TXT.
    ENDIF.

    IF NOT IT_TXT[] IS INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF IT_TEXT
       FROM ZMMTI39
     WHERE EBELN = IT_EKPO-EBELN
        AND EBELP = IT_EKPO-EBELP
        AND ZERET = '00'.

        APPEND : IT_TEXT. CLEAR : IT_TEXT.
      ENDSELECT.
    ENDIF.
  ENDLOOP.
*- [CHM2407-00134] 품목 텍스트가 변경되었는지 Check

* 변경/신규생성분을 SELECT한다.
  SORT IT_EKPO BY EBELN EBELP.
  SORT IT_POLD BY EBELN EBELP.

  LOOP AT IT_EKKO.
    CLEAR : W_CHECK, L_NEW, L_OLD, IT_KOLD, W_TXT.
*   새로운 ITEM이 추가되었는지 CHECK...
    READ TABLE IT_EKPO WITH KEY EBELN = IT_EKKO-EBELN
                       BINARY SEARCH.
    LOOP AT IT_EKPO FROM SY-TABIX.
      IF IT_EKKO-EBELN = IT_EKPO-EBELN.
        ADD IT_EKPO-EBELP TO L_NEW.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.

    READ TABLE IT_POLD WITH KEY EBELN = IT_EKKO-EBELN
                       BINARY SEARCH.
    LOOP AT IT_POLD FROM SY-TABIX.
      IF IT_EKKO-EBELN = IT_POLD-EBELN.
        ADD IT_POLD-EBELP TO L_OLD.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
    CHECK L_NEW = L_OLD.   "변경이 발생되었다면 SKIP

*   ITEM의 변경이 생성되었는지 CHECK....
    LOOP AT IT_EKPO WHERE EBELN = IT_EKKO-EBELN.
      LOOP AT IT_POLD WHERE EBELN = IT_EKPO-EBELN
                        AND EBELP = IT_EKPO-EBELP.
*^0^*_ksj_2005.07.07 -- 기존자재 비교 오류 보완
        CLEAR: IT_POLD-ZERET, IT_POLD-ZEMSG.
        IF IT_EKPO <> IT_POLD.
          W_CHECK = 'X'.
        ENDIF.
      ENDLOOP.
      IF W_CHECK = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    CHECK W_CHECK = ' '.

*  HEAD의 변경이 발생되었는지 CHECK.....
    READ TABLE IT_KOLD WITH KEY EBELN = IT_EKKO-EBELN.
    IF SY-SUBRC = 0.
      CLEAR : IT_KOLD-ZERET, IT_KOLD-ZEMSG.
      CHECK IT_KOLD = IT_EKKO.
    ENDIF.

*- [CHM2407-00134] 품목 텍스트가 변경되었는지 Check
    LOOP AT IT_EKPO WHERE EBELN = IT_EKKO-EBELN.
      CLEAR : IT_TXT, IT_TEXT.
      READ TABLE IT_TXT WITH KEY EBELN = IT_EKPO-EBELN
                                                EBELP = IT_EKPO-EBELP.
      READ TABLE IT_TEXT    WITH KEY EBELN = IT_EKPO-EBELN
                                                EBELP = IT_EKPO-EBELP.
      CLEAR : IT_TEXT-ZERET, IT_TEXT-ZEMSG,
                IT_TEXT-AEDAT, IT_TEXT-DRUHR, IT_TEXT-LOEKZ.

      IF IT_TXT <>  IT_TEXT.    " 변경이 발생됐으면 SKIP
        W_TXT = 'X'.
      ENDIF.
      IF W_TXT = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    CHECK W_TXT = ' '.
*- [CHM2407-00134] 품목 텍스트가 변경되었는지 Check
*--------------------------------------------------------
*  CSR No:C2006062001000000225
*  외주가공 구성부품이 변경되었는지 CHECK
*  2006.06.20. Modified By SHIN
*--------------------------------------------------------
    CLEAR L_FLAG.
    LOOP AT IT_EKPO WHERE EBELN = IT_EKKO-EBELN
                      AND PSTYP = '3'.

      L_FLAG = 'X'.

      CLEAR: IT_RESB, IT_ROLD.
      READ TABLE IT_RESB WITH KEY EBELN = IT_EKPO-EBELN
                                  EBELP = IT_EKPO-EBELP.
      READ TABLE IT_ROLD WITH KEY EBELN = IT_EKPO-EBELN
                                  EBELP = IT_EKPO-EBELP.

      CLEAR: IT_ROLD-ZERET, IT_ROLD-ZEMSG,
             IT_ROLD-AEDAT, IT_ROLD-DRUHR.

      IF IT_RESB = IT_ROLD.
        DELETE IT_EKPO WHERE EBELN = IT_EKPO-EBELN
                         AND EBELP = IT_EKPO-EBELP.
        IF SY-SUBRC = 0.
          DELETE IT_EKKO WHERE EBELN = IT_EKPO-EBELN.
        ENDIF.
      ENDIF.

    ENDLOOP.
*---------------------------------------------------------
*  END CSR No:C2006062001000000225
*---------------------------------------------------------

*   변경이 없으면 전송분에서 제외......................
    IF L_FLAG NE 'X'.
      DELETE IT_EKPO WHERE EBELN = IT_EKKO-EBELN.
      DELETE IT_EKKO.
    ENDIF.

  ENDLOOP.

* 전송정보를 만든다............
  LOOP AT IT_EKKO.
    MOVE-CORRESPONDING IT_EKKO TO LT_ITAB06.
    MOVE  : '100'        TO LT_ITAB06-MANDT.
    WRITE : IT_EKKO-ZAMT TO LT_ITAB06-ZAMT CURRENCY IT_EKKO-WAERS.
    PERFORM CHANGE_AMOUNT USING LT_ITAB06-ZAMT.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LT_ITAB06-LIFNR
      IMPORTING
        OUTPUT = LT_ITAB06-LIFNR.
    IF LT_ITAB06-LOEKZ = ' '.
      READ TABLE IT_KOLD WITH KEY EBELN = IT_EKKO-EBELN.
      IF SY-SUBRC = 0.
        LT_ITAB06-LOEKZ = 'R'.
      ELSE.
        LT_ITAB06-LOEKZ = 'C'.
      ENDIF.
    ENDIF.

*   ITEM정보...
    LOOP AT IT_EKPO WHERE EBELN = IT_EKKO-EBELN.
      MOVE-CORRESPONDING IT_EKPO TO LT_ITAB07.
*     한도가 존재하면 소액 아니면 일반공사로 구분한다.
      SELECT SINGLE SUMLIMIT INTO LT_ITAB07-SUMLIMIT
      FROM ESUH
      WHERE PACKNO = IT_EKPO-PACKNO.

      MOVE  : '100'         TO LT_ITAB07-MANDT,
            LT_ITAB06-LIFNR TO LT_ITAB07-LIFNR.
      WRITE : IT_EKPO-BRTWR TO LT_ITAB07-BRTWR CURRENCY IT_EKKO-WAERS,
              IT_EKPO-NETPR TO LT_ITAB07-NETPR CURRENCY IT_EKKO-WAERS,
*-<< 기능개선 152029 - 추가
              IT_EKPO-NETPR_BD TO LT_ITAB07-NETPR_BD "
                                               CURRENCY IT_EKKO-WAERS.
*->> 기능개선 152029
      PERFORM CHANGE_AMOUNT USING : LT_ITAB07-BRTWR, LT_ITAB07-NETPR,
                                    LT_ITAB07-NETPR_BD.
*EHKIM CCM 수정 2023.04.18
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT  = LT_ITAB07-MATNR
        IMPORTING
          OUTPUT = LT_ITAB07-MATNR.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          INPUT    = LT_ITAB07-MEINS
          LANGUAGE = SY-LANGU
        IMPORTING
          OUTPUT   = LT_ITAB07-MEINS.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LT_ITAB07-BANFN
        IMPORTING
          OUTPUT = LT_ITAB07-BANFN.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LT_ITAB07-AUFNR
        IMPORTING
          OUTPUT = LT_ITAB07-AUFNR.

      LT_ITAB07-EMLIF = |{ LT_ITAB07-EMLIF ALPHA = OUT }|. "추가(송종면E 25.02.19)

      READ TABLE IT_EVERS WITH KEY EVERS = IT_EKPO-EVERS.
      IF SY-SUBRC = 0.
        LT_ITAB07-EVTXT = IT_EVERS-EVTXT.
      ENDIF.
*     공급업체/고객..찾기..
      IF IT_EKPO-KUNNR <> SPACE OR IT_EKPO-EMLIF NE SPACE.
        PERFORM SELECT_KUNNR USING LT_ITAB07 IT_EKPO.
      ENDIF.

*- [START_22259] APO 개별구매오더에 납품처/주소 추가
      IF IT_EKPO-KNTTP = 'M'.
        IF LT_ITAB07-NAME1 IS INITIAL AND LT_ITAB07-CITY1 IS INITIAL.
          CLEAR LT_ITAB52.
          READ TABLE LT_ITAB52 WITH KEY EBELN = IT_EKPO-EBELN
                                        EBELP = IT_EKPO-EBELP.

          IF SY-SUBRC = 0.
            IT_EKPO-KUNNR = LT_ITAB52-NKUNNR.
            PERFORM SELECT_KUNNR USING LT_ITAB07 IT_EKPO.
          ENDIF.
        ENDIF.
      ENDIF.
*- [END_22259] APO 개별구매오더에 납품처/주소 추가

*     생성/변경구분........
      IF LT_ITAB07-LOEKZ = ' '.
        READ TABLE IT_POLD WITH KEY EBELN = IT_EKPO-EBELN
                                    EBELP = IT_EKPO-EBELP.
        IF SY-SUBRC = 0.
          LT_ITAB07-LOEKZ = 'R'.
        ELSE.
          LT_ITAB07-LOEKZ = 'C'.
        ENDIF.
      ENDIF.

      APP LT_ITAB07.

    ENDLOOP.
    APP LT_ITAB06.
*   DB삭제....
    DELETE FROM ZMMTI06 WHERE EBELN = IT_EKKO-EBELN.
    DELETE FROM ZMMTI07 WHERE EBELN = IT_EKKO-EBELN.
  ENDLOOP.
*^^*_ksj_2005.11.17 -- 구매 항목별 품목텍스트 추가
  REFRESH : LT_ITAB39, IT_TXT. CLEAR : LT_ITAB39, IT_TXT.

  LOOP AT LT_ITAB07.
*   LONG_TEXT 가져오기.....
    PERFORM LONGTEXT_VIEW  USING LT_ITAB07.
    DELETE FROM ZMMTI39 WHERE EBELN = LT_ITAB07-EBELN
                          AND EBELP = LT_ITAB07-EBELP.

* 2012.04.02 Start 납품PO LONG_TEXT 가져오기.....
    PERFORM LONGTEXT_VIEW_04  USING LT_ITAB07.
* End
    MODIFY LT_ITAB07.
  ENDLOOP.

* RESB TABLES 에서 구성부품 만들기(2005.03.14)
  DATA: LT_EKPO LIKE IT_EKPO OCCURS 0 WITH HEADER LINE.
  LT_EKPO[] = IT_EKPO[].

* 품목범주는 외주가공 만 가지고 구성부품 가지고 온다.
  DELETE LT_EKPO WHERE PSTYP NE '3'.

  IF NOT LT_EKPO[] IS INITIAL.

* 1306(부스덕트)한정 구성부품(LT_ITAB32) 전송 제외 (2026.07.10 박우진)
*    IF NOT line_exists( lt_ekpo[ werks = '1306' ] ).

    REFRESH LT_ITAB32.  CLEAR LT_ITAB32.
    SELECT RSNUM
           RSPOS
           RSART
           EBELN
           EBELP
           MATNR
           BAUGR
           ERFMG
           ERFME
           LIFNR
           FROM RESB
           INTO CORRESPONDING FIELDS OF TABLE LT_ITAB32
           FOR ALL ENTRIES IN LT_EKPO
           WHERE EBELN EQ LT_EKPO-EBELN
             AND EBELP EQ LT_EKPO-EBELP
             AND BAUGR EQ LT_EKPO-MATNR
             AND LIFNR EQ LT_EKPO-LIFNR.

    SORT LT_ITAB32 BY EBELN EBELP .
    LT_ITAB32-MANDT = '100'.
    LT_ITAB32-AEDAT = SY-DATUM.
    LT_ITAB32-DRUHR = SY-UZEIT.
    MODIFY LT_ITAB32 TRANSPORTING MANDT AEDAT DRUHR WHERE EBELN NE ' '.

*-------------------------------------------------------------
*  CSR No:C2006062001000000225
*  납품서가 생성된 구성부품 인터페이스는 하지말자~!!
*  2006.06.20. Modified By SHIN
*-------------------------------------------------------------
    LOOP AT LT_ITAB32.

      CLEAR EKES.
      SELECT SINGLE EBELN INTO EKES-EBELN
        FROM EKES
       WHERE EBELN = LT_ITAB32-EBELN
         AND EBELP = LT_ITAB32-EBELP.

      IF SY-SUBRC = 0.
        DELETE LT_ITAB32 WHERE EBELN = LT_ITAB32-EBELN
                           AND EBELP = LT_ITAB32-EBELP.
      ENDIF.


*[S] 1306(부스덕트)한정 구성부품(LT_ITAB32) 전송 제외 (2026.08.10 박우진)

      READ TABLE LT_EKPO INTO DATA(PS_EKPO) WITH KEY EBELN = LT_ITAB32-EBELN
                                                     EBELP = LT_ITAB32-EBELP.

      IF SY-SUBRC EQ 0  AND PS_EKPO-WERKS EQ '1306'.
        DELETE LT_ITAB32 WHERE EBELN = LT_ITAB32-EBELN
                           AND EBELP = LT_ITAB32-EBELP.
      ENDIF.


*[E] 1306(부스덕트)한정 구성부품(LT_ITAB32) 전송 제외 (2026.08.10 박우진)

    ENDLOOP.
*-------------------------------------------------------------
*  END CSR No:C2006062001000000225
*-------------------------------------------------------------

*-{기능개선 94016 - 구성부품 동일자재 수량을 합산하여 전송함
*- 자체개선 96052 - EBELN 조건 추가
    DATA  : LT_TEMP32 LIKE LT_ITAB32 OCCURS 0 WITH HEADER LINE.
    CLEAR : LT_TEMP32, LT_TEMP32[].

    SORT LT_ITAB32 BY EBELN EBELP BAUGR MATNR.
    LT_TEMP32[] = LT_ITAB32[].
    DELETE ADJACENT DUPLICATES FROM LT_ITAB32
                                    COMPARING EBELN EBELP BAUGR MATNR.

    IF LT_TEMP32[] NE LT_ITAB32[].
      LOOP AT LT_TEMP32.
        AT END OF MATNR.
          SUM.
          READ TABLE LT_ITAB32 WITH KEY EBELN = LT_TEMP32-EBELN
                                        EBELP = LT_TEMP32-EBELP
                                        BAUGR = LT_TEMP32-BAUGR
                                        MATNR = LT_TEMP32-MATNR.
          IF SY-SUBRC = 0.
            LT_ITAB32-ERFMG = LT_TEMP32-ERFMG.
            MODIFY LT_ITAB32 TRANSPORTING ERFMG WHERE EBELN =
            LT_TEMP32-EBELN
                                                  AND EBELP =
                                                  LT_TEMP32-EBELP
                                                  AND BAUGR =
                                                  LT_TEMP32-BAUGR
                                                  AND MATNR =
                                                  LT_TEMP32-MATNR.
          ENDIF.
        ENDAT.
      ENDLOOP.
    ENDIF.
*-}기능개선 94016

*    ENDIF.
  ENDIF.

*EHKIM CCM 수정 2023.04.18
  LOOP AT LT_ITAB32.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = LT_ITAB32-MATNR
      IMPORTING
        OUTPUT = LT_ITAB32-MATNR.

    MODIFY LT_ITAB32 TRANSPORTING MATNR.
  ENDLOOP.


  IF NOT LT_ITAB06[] IS INITIAL.

    LOOP AT LT_ITAB06.
      LOOP AT IT_EKKO WHERE EBELN = LT_ITAB06-EBELN.
        IT_EKKO-ZERET = '00'.
*          IT_EKKO-ZEMSG = LT_ITAB06-ZEMSG.
        MODIFY IT_EKKO.
      ENDLOOP.
    ENDLOOP.

*- [CHM2403-00363] 외주가공 전송 결과 추가_2024.03.22
    LOOP AT LT_ITAB07.
      LOOP AT LT_ITAB32 WHERE EBELN = LT_ITAB07-EBELN
                                  AND EBELP = LT_ITAB07-EBELP.
        LT_ITAB32-ZERET = '00'.
        MODIFY LT_ITAB32.
      ENDLOOP.
    ENDLOOP.
*- [CHM2403-00363] 외주가공 전송 결과 추가_2024.03.22

*   결과...처리.....................................
    MODIFY ZMMTI06 FROM TABLE IT_EKKO.
    MODIFY ZMMTI07 FROM TABLE IT_EKPO.
    MODIFY ZMMTI32 FROM TABLE LT_ITAB32.
    LOOP AT LT_ITAB39.
      CLEAR ZMMTI39.
      MOVE-CORRESPONDING LT_ITAB39 TO ZMMTI39.
      MOVE '00'            TO ZMMTI39-ZERET.  " [CHM2407-00134] 텍스트 전송 결과 추가
      MOVE SY-DATUM  TO ZMMTI39-AEDAT.
      MOVE SY-UZEIT    TO ZMMTI39-DRUHR.
      MODIFY ZMMTI39.
    ENDLOOP.
    LOOP AT LT_ITAB52.
      CLEAR ZMMTI52.
      MOVE-CORRESPONDING LT_ITAB52 TO ZMMTI52.
*EHKIM CCM 수정 2023.04.18
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT  = ZMMTI52-MATNR
        IMPORTING
          OUTPUT = ZMMTI52-MATNR.
      MOVE SY-DATUM                TO ZMMTI52-AEDAT.
      MOVE SY-UNAME                TO ZMMTI52-AENAM.
      MODIFY ZMMTI52.
    ENDLOOP.
  ENDIF.

  IF NOT LT_ITAB06[] IS INITIAL.
*   RFC DESTINATION... SEARCH.......................
    CLEAR W_DEST.
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        GUBUN                 = G_MODULE
      IMPORTING
        DEST_NAME             = W_DEST
      EXCEPTIONS
        DESTINATION_NOT_FOUND = 1
        OTHERS                = 2.
    CHECK SY-SUBRC = 0.

*   EAI Call........................................
    CALL FUNCTION 'ZGTMM_IF_O_PO_ER' "'Z_MM_SEND_PO_ER'
      DESTINATION W_DEST
      IMPORTING
        O_RESULT              = O_RESULT
        O_MESSAGE             = O_MESSAGE
      TABLES
        LT_ITAB06             = LT_ITAB06
        LT_ITAB07             = LT_ITAB07
        LT_ITAB32             = LT_ITAB32
        LT_ITAB39             = LT_ITAB39
        LT_ITAB52             = LT_ITAB52
      EXCEPTIONS
        SYSTEM_FAILURE        = 1 MESSAGE W_MSG
        COMMUNICATION_FAILURE = 2 MESSAGE W_MSG
        OTHERS                = 3.

** ----------------------------------------------------------------------
** [BEFORE]
**    IF SY-SUBRC NE 0.
**      LOOP AT IT_EKKO.
**        IT_EKKO-ZERET = '01'.
**        IT_EKKO-ZEMSG = W_MSG.
**        MODIFY IT_EKKO.
**      ENDLOOP.
**    ELSE.
**      LOOP AT IT_EKKO.
**        IT_EKKO-ZERET = '00'.
**        IT_EKKO-ZEMSG = 'SUCCESS'.
**        MODIFY IT_EKKO.
**      ENDLOOP.
** ----------------------------------------------------------------------
** [AFTER - 2026.08.28 / 박우진]
** 성공/실패 처리 시 DRUHR(SY-UZEIT)을 함께 기록.
** 성공(ZERET='00') 건의 DRUHR이 위 [수정 지점 1]에서 비교 기준으로 쓰이는
** "성공 전송 시각"이 됨. 실패건 DRUHR은 필수는 아니나 시도 시각 추적용으로 기록.
** ----------------------------------------------------------------------
    IF SY-SUBRC NE 0.
*     EAI Connect Error일경우.. Error로 한다........
      LOOP AT IT_EKKO.
        IT_EKKO-ZERET = '01'.
        IT_EKKO-ZEMSG = W_MSG.
        IT_EKKO-DRUHR = SY-UZEIT.   "<< 추가 (2026.08.28) 시도 시각 기록(참고용)
        MODIFY IT_EKKO.
      ENDLOOP.
    ELSE.
      LOOP AT IT_EKKO.
        IT_EKKO-ZERET = '00'.
        IT_EKKO-ZEMSG = 'SUCCESS'.
        IT_EKKO-DRUHR = SY-UZEIT.   "<< 추가 (2026.08.28) [핵심] 성공 전송 시각 저장
        MODIFY IT_EKKO.
      ENDLOOP.

*      LOOP AT LT_ITAB06.
*        LOOP AT IT_EKKO WHERE EBELN = LT_ITAB06-EBELN.
*          IT_EKKO-ZERET = LT_ITAB06-ZERET.
*          IT_EKKO-ZEMSG = LT_ITAB06-ZEMSG.
*          MODIFY IT_EKKO.
*        ENDLOOP.
*      ENDLOOP.
*      LOOP AT LT_ITAB07.
*        LOOP AT IT_EKPO WHERE EBELN = LT_ITAB07-EBELN
*                          AND EBELP = LT_ITAB07-EBELP.
*          IT_EKPO-ZERET = LT_ITAB07-ZERET.
*          IT_EKPO-ZEMSG = LT_ITAB07-ZEMSG.
*          IT_EKPO-ZTEXT = LT_ITAB07-ZTEXT.
*          MODIFY IT_EKPO.
*        ENDLOOP.
*      ENDLOOP.

* C20120807_609 START
      LOOP AT IT_EBELN.
        DELETE FROM ZMMTI82
         WHERE EBELN = IT_EBELN-EBELN.
      ENDLOOP.
* C20120807_609 END

    ENDIF.

**   결과...처리.....................................
    MODIFY ZMMTI06 FROM TABLE IT_EKKO. "--> EAI 호출결과 반영 위한 주석 해제
*    MODIFY ZMMTI07 FROM TABLE IT_EKPO.
*    MODIFY ZMMTI32 FROM TABLE LT_ITAB32.
*    LOOP AT LT_ITAB39.
*      CLEAR ZMMTI39.
*      MOVE-CORRESPONDING LT_ITAB39 TO ZMMTI39.
*      MOVE SY-DATUM                TO ZMMTI39-AEDAT.
*      MOVE SY-UZEIT                TO ZMMTI39-DRUHR.
*      MODIFY ZMMTI39.
*    ENDLOOP.
*    LOOP AT LT_ITAB52.
*      CLEAR ZMMTI52.
*      MOVE-CORRESPONDING LT_ITAB52 TO ZMMTI52.
*      MOVE SY-DATUM                TO ZMMTI39-AEDAT.
*      MOVE SY-UNAME                TO ZMMTI52-AENAM.
*      MODIFY ZMMTI52.
*    ENDLOOP.
    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
*----------
* FORM
*----------
FORM CONVERT_MATERIAL_UNIT  USING  PV_MATNR LIKE MARA-MATNR
                                   PV_MEINS LIKE MARA-MEINS
                                   PV_BMEIN LIKE MARA-MEINS
                                   PV_BRGEW.
  DATA : LV_BRGEW  LIKE MARA-BRGEW,
         LV_MENGE  LIKE EKPO-MENGE,
         LV_MENGE1 TYPE P DECIMALS 2,
         LV_MEINS  LIKE MARA-MEINS.

  CHECK PV_MEINS <> PV_BMEIN.

  CLEAR : LV_MENGE, LV_MEINS.

  SELECT SINGLE MEINS
    INTO LV_MEINS
    FROM MARA
   WHERE MATNR = PV_MATNR.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      MATNR                = PV_MATNR
      INPUT                = PV_BRGEW
      MEINH                = PV_MEINS
      KZMEINH              = 'X'
      MEINS                = LV_MEINS
    IMPORTING
      OUTPUT               = LV_MENGE
    EXCEPTIONS
      CONVERSION_NOT_FOUND = 01
      INPUT_INVALID        = 02
      MATERIAL_NOT_FOUND   = 03
      MEINH_NOT_FOUND      = 04
      MEINS_MISSING        = 05
      NO_MEINH             = 06
      OUTPUT_INVALID       = 07
      OVERFLOW             = 08.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        MATNR                = PV_MATNR
        INPUT                = LV_MENGE
        MEINH                = PV_BMEIN
        KZMEINH              = SPACE
        MEINS                = LV_MEINS
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 01
        INPUT_INVALID        = 02
        MATERIAL_NOT_FOUND   = 03
        MEINH_NOT_FOUND      = 04
        MEINS_MISSING        = 05
        NO_MEINH             = 06
        OUTPUT_INVALID       = 07
        OVERFLOW             = 08.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT                = PV_BRGEW
        ROUND_SIGN           = 'X'
        UNIT_IN              = PV_MEINS
        UNIT_OUT             = PV_BMEIN
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 1
        DIVISION_BY_ZERO     = 2
        INPUT_INVALID        = 3
        OUTPUT_INVALID       = 4
        OVERFLOW             = 5
        TYPE_INVALID         = 6
        UNITS_MISSING        = 7
        UNIT_IN_NOT_FOUND    = 8
        UNIT_OUT_NOT_FOUND   = 9
        OTHERS               = 10.
  ENDIF.

  IF SY-SUBRC = 0.
    LV_MENGE1 = LV_MENGE.
    PV_BRGEW  = LV_MENGE1.
  ENDIF.

ENDFORM.                    " CONVERT_MATERIAL_UNIT
