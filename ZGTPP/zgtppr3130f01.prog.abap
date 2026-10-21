*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_PSMNG_SUM LIKE ZGTCVORDSYVAL-PSMNG,
         LV_WEMNG_SUM LIKE ZGTCVORDSYVAL-WEMNG.
  DATA : LV_IDX          TYPE NUMC1.
  DATA : LV_BONSU(30),
         LV_SUNDIA(30).

  DATA : LV_SPGCD LIKE ZGTPPT2130-SPGCD.

  FIELD-SYMBOLS : <FS_BONSU>  TYPE ANY,
                  <FS_SUNDIA> TYPE ANY.

  RANGES: LR_DISPO FOR ZGTCVORDSYVAL-DISPO.




* 1) ZGTPPT2000 테이블에서 오더 수량(판매 단위) 합을 가져 온다
  SELECT A~GRPNR,
         A~ORDNO AS VBELN,
         A~KUNNR,
         A~EDATU,
         A~MATNR AS MATNR_F,
         A~MEINS,
         SUM( A~WMENG ) AS NWMENG
*         B~GONG_CD,
*         B~ORDNR AS AUFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
    FROM ZGTPPT2000 AS A "INNER JOIN ZGTPPT2010 AS B
                         "ON A~GRPNR = B~GRPNR
    WHERE A~WERKS   EQ @P_WERKS " 선택화면의 플랜트
      AND A~SPGCD   EQ @P_SPGCD "선택화면의 SPG
      AND A~MATNR   IN @S_MATNR "선택화면의 자재코드
      AND A~MAKTX   IN @S_MAKTX " 선택화면의 자재내역
      AND A~GRPNR   IN @S_GRPNR "선택화면의 조장구성표
      AND A~ERDAT   IN @S_ERDAT "선택화면의 작성일
      AND A~ORDNO   IN @S_ORDNO "선택화면의 판매오더
*      AND A~KUNNR   EQ @P_KUNNR "선택화면의 납품처
      AND A~EDATU   IN @S_EDATU "선택화면의 납품요청일
      AND A~ZSTATUS NE 'D'
   GROUP BY A~GRPNR,
            A~ORDNO,
            A~KUNNR,
            A~EDATU,
            A~MATNR,
            A~MEINS
            .
  SORT GT_DATA BY GRPNR VBELN.

  GT_DATA_INIT[] = GT_DATA[].

  SORT GT_DATA BY GRPNR MATNR_F.

  DELETE ADJACENT DUPLICATES FROM GT_DATA
                             COMPARING GRPNR MATNR_F.


  IF GT_DATA[] IS NOT INITIAL.
* 1_1) ZGTPPT2010 ( GONG_CD  ORDNR AS AUFNR )가져 온다
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_T2010
      FROM ZGTPPT2010
      FOR ALL ENTRIES IN @GT_DATA
     WHERE GRPNR EQ @GT_DATA-GRPNR
       AND ORDTY = 'PRD'.

    LOOP AT GT_DATA INTO GS_DATA.
      READ TABLE GT_T2010 INTO GS_T2010
           WITH KEY GRPNR = GS_DATA-GRPNR.
      IF SY-SUBRC = 0.
        GS_DATA-GONG_CD = GS_T2010-GONG_CD.
        GS_DATA-AUFNR   = GS_T2010-ORDNR.
      ENDIF.
      MODIFY GT_DATA FROM GS_DATA.
    ENDLOOP.

    SORT GT_DATA BY GRPNR VBELN.

    DATA : LV_POSNR LIKE AFPO-POSNR.
    " POSNR 자리수 맞춤 제품 자재코드 맵핑
    LOOP AT GT_T2010 INTO GS_T2010.
      READ TABLE GT_DATA INTO GS_DATA
                         WITH KEY GRPNR = GS_T2010-GRPNR.
      GS_T2010-MATNR_F    = GS_DATA-MATNR_F.
      GS_T2010-POSNR_AFPO = GS_T2010-POSNR+2(4).
      MODIFY GT_T2010 FROM GS_T2010.
    ENDLOOP.

    SORT GT_T2010 BY ORDNR POSNR.

    " 오더가 삭제 상태인것은 제외 시킨다 ZGTPP_CV_ORD_STAT DEL
    IF GT_DATA[] IS NOT INITIAL.
      SELECT AUFNR,
             DEL
        INTO CORRESPONDING FIELDS OF TABLE @GT_ORD_STAT
        FROM ZGTPP_CV_ORD_STAT
        FOR ALL ENTRIES IN @GT_DATA
       WHERE AUFNR = @GT_DATA-AUFNR .
    ENDIF.

    LOOP AT GT_DATA INTO GS_DATA.
      READ TABLE GT_ORD_STAT INTO GS_ORD_STAT
                             WITH KEY AUFNR = GS_DATA-AUFNR.
      IF SY-SUBRC = 0.
        IF GS_ORD_STAT-DEL = 'X'.
          GS_DATA-DEL = 'X'.
          MODIFY GT_DATA FROM GS_DATA.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DELETE GT_DATA WHERE DEL = 'X'.

*     ZGTPP_CV_ORD_STAT DEL DATA CHECK를 위한
    CLEAR : GT_TCVORD_STAT2[].
    IF GT_T2010[] IS NOT INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_TCVORD_STAT2
        FROM ZGTPP_CV_ORD_STAT
        FOR ALL ENTRIES IN @GT_T2010
       WHERE AUFNR = @GT_T2010-ORDNR.
    ENDIF.
    LOOP AT GT_T2010 INTO GS_T2010.
      READ TABLE GT_TCVORD_STAT2 INTO GS_TCVORD_STAT2
                                WITH KEY AUFNR = GS_T2010-ORDNR.
      IF SY-SUBRC = 0.
        IF   GS_TCVORD_STAT2-DLFL = 'X'.
          GS_T2010-DELCHK2 = 'X'.
        ENDIF.
        MODIFY GT_T2010 FROM GS_T2010.
      ENDIF.
    ENDLOOP.

    DELETE GT_T2010 WHERE DELCHK2 = 'X'.



*   GT_DATA_INIT[] = GT_DATA[].

* 1_2) 추출한 공정별 생산오더 번호(AUFNR.)별 입고수량을 추출 및 가공
    CLEAR : GT_AFPO[].
    SELECT AUFNR ,
           POSNR,
           WEMNG,
           MEINS
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFPO
      FROM AFPO
      FOR ALL ENTRIES IN @GT_T2010
     WHERE AUFNR EQ @GT_T2010-ORDNR
       AND POSNR EQ @GT_T2010-POSNR_AFPO.
*      WHERE WEMNG > 0
    .
    SORT GT_AFPO BY AUFNR.

    CLEAR : GT_AFPO_P[].
    SELECT AUFNR ,
           POSNR,
           PSMNG,
           MEINS
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFPO_P
      FROM AFPO
      FOR ALL ENTRIES IN @GT_T2010
     WHERE AUFNR EQ @GT_T2010-ORDNR
       AND POSNR EQ @GT_T2010-POSNR_AFPO.
    .
    SORT GT_AFPO_P BY AUFNR.

    LOOP AT GT_T2010 INTO GS_T2010.

      READ TABLE GT_AFPO INTO GS_AFPO
                         WITH KEY AUFNR = GS_T2010-ORDNR
                                  POSNR = GS_T2010-POSNR.

      GS_T2010-WEMNG = GS_AFPO-WEMNG.
      GS_T2010-MEINS = GS_AFPO-MEINS.

      MODIFY GT_T2010 FROM GS_T2010.
    ENDLOOP.

    LOOP AT GT_T2010 INTO GS_T2010.

      READ TABLE GT_AFPO_P INTO GS_AFPO_P
                         WITH KEY AUFNR = GS_T2010-ORDNR
                                  POSNR = GS_T2010-POSNR.

      GS_T2010-NWMENG = GS_AFPO_P-PSMNG.
      GS_T2010-MEINS = GS_AFPO-MEINS.

      MODIFY GT_T2010 FROM GS_T2010.
    ENDLOOP.

  ENDIF.

*--------------------------------------------------------------------*
*  MTS 오더 추출  ZGTCVORDSYVAL  START
*--------------------------------------------------------------------*
  IF CB_MTSOR = 'X'.
    CONCATENATE P_SPGCD+0(2) '*' INTO LV_SPGCD .
    LR_DISPO-SIGN   = 'I'.
    LR_DISPO-OPTION = 'CP'.
    LR_DISPO-LOW = LV_SPGCD.
    LR_DISPO-HIGH = ''.

    APPEND LR_DISPO.

    CONCATENATE P_SPGCD+0(2) '*'
           INTO LV_SPGCD .

    SELECT A~WERKS,
           A~AUART,
           A~AUFNR,
           A~POSNR,
           A~PSMNG,
           A~WEMNG,
           A~MEINS,
           A~MATNR,
           A~MAKTX,
           A~GSTRP,
           A~KDAUF,
           A~KDPOS,
           A~KUNNR,
           A~NAME1,
           A~PDCAVOLTAGE,
           A~PDCACONDSIZE1ST,
           A~PDCAPROCCODE,
           A~PDCAPROCNAME
      INTO CORRESPONDING FIELDS OF TABLE @GT_TCVORDSYVAL
      FROM ZGTCVORDSYVAL AS A INNER JOIN AFKO AS B
                              ON A~AUFNR = B~AUFNR
      WHERE A~WERKS  EQ @P_WERKS " 선택화면의 플랜트
        AND A~DISPO  IN @LR_DISPO "선택화면의 SPG
        AND A~GSTRP  IN @S_GSTRP " 선택화면의 오더 시작일자
        AND A~DLFL   NE 'X'.

    SORT GT_TCVORDSYVAL BY WERKS AUFNR .

    " MTS 오더별 원자재 소요량 정보 추출 (RESB)
    IF GT_TCVORDSYVAL[] IS NOT INITIAL.
      SELECT A~WERKS, A~AUFNR, A~RSNUM, A~RSPOS,
             A~MATNR, A~BDMNG, A~MEINS, A~AUSCH,
             B~MTART,
             C~MAKTX
        INTO CORRESPONDING FIELDS OF TABLE @GT_RESB
        FROM RESB AS A INNER JOIN MARA AS B
                       ON A~MATNR = B~MATNR
                       INNER JOIN MAKT AS C
                       ON A~MATNR = C~MATNR
        FOR ALL ENTRIES IN @GT_TCVORDSYVAL
        WHERE A~WERKS  EQ @P_WERKS " 선택화면의 플랜트
          AND A~RSNUM  EQ @GT_TCVORDSYVAL-RSNUM " 예약 문서 번호
          AND B~MTART  NE 'MCHF' "HALB"    "반제품 제외
          AND C~SPRAS  EQ @SY-LANGU
        .
    ENDIF.
    CLEAR : GT_ORDSYVALP.
    LOOP AT GT_TCVORDSYVAL INTO GS_TCVORDSYVAL.
      MOVE-CORRESPONDING GS_TCVORDSYVAL TO GS_ORDSYVALP.
      APPEND  GS_ORDSYVALP TO GT_ORDSYVALP.
      MOVE-CORRESPONDING GS_TCVORDSYVAL TO GS_ORDSYVALW.
      APPEND  GS_ORDSYVALW TO GT_ORDSYVALW.
    ENDLOOP.

    CLEAR : LV_PSMNG_SUM.
    LOOP AT GT_ORDSYVALP INTO GS_ORDSYVALP.
      GS_ORDSYVALP_SUM-AUFNR =  GS_ORDSYVALP-AUFNR.
      LV_PSMNG_SUM = LV_PSMNG_SUM + GS_ORDSYVALP-PSMNG.
      AT END OF AUFNR.
        GS_ORDSYVALP_SUM-PSMNG = LV_PSMNG_SUM.
        APPEND GS_ORDSYVALP_SUM TO GT_ORDSYVALP_SUM..
        CLEAR : LV_PSMNG_SUM.
      ENDAT.
    ENDLOOP.


  ENDIF.

*--------------------------------------------------------------------*
*  MTS 오더 추출  ZGTCVORDSYVAL   END
*--------------------------------------------------------------------*

*  2)조장구성표 판매오더의 제품별로 설계정보 추출
  SELECT FINSHMAT, WERKS,SPART, SUL_NO,REV_SEQ, GONG_SEQ, GONG_CD,
         GONG_NM, MATNR, JAJE_QTY, JAJE_UNIT
    INTO CORRESPONDING FIELDS OF TABLE @GT_TSULDM
    FROM ZGTCVSULDM
    FOR ALL ENTRIES IN @GT_DATA
   WHERE FINSHMAT = @GT_DATA-MATNR_F.
  SORT GT_TSULDM BY FINSHMAT SUL_NO.


*  2_1) ZGTCVSULDM -JAJE_UNIT이 비어있다면 해당 MATNR의 기본단위 MEINS를 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MARA
    FROM MARA
    FOR ALL ENTRIES IN GT_TSULDM
   WHERE MATNR = GT_TSULDM-MATNR.
  SORT GT_MARA BY MATNR.

  LOOP AT GT_TSULDM INTO GS_TSULDM.
    IF GS_TSULDM-JAJE_UNIT IS INITIAL.
      READ TABLE GT_MARA INTO GS_MARA
                         WITH KEY MATNR = GS_TSULDM-MATNR.
      IF SY-SUBRC = 0.
        GS_TSULDM-JAJE_UNIT = GS_MARA-MEINS.
        MODIFY GT_TSULDM FROM GS_TSULDM.
      ENDIF.
    ENDIF.
  ENDLOOP.


*  2_2)  ZGTCVSULCHAR - 소선정보 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_TSULCHAR
    FROM ZGTCVSULCHAR
    FOR ALL ENTRIES IN @GT_DATA
   WHERE MATNR = @GT_DATA-MATNR_F.
  SORT GT_TSULCHAR BY MATNR SUL_NO REV_SEQ GONG_SEQ.

  DATA : LV_BONSU_SUM   LIKE  ZGTCVSULCHAR-BONSU0.

  CLEAR : GT_SOSUN1_SUM[], GS_SOSUN1_SUM,
          GT_TSULCHAR2[], GT_TSULCHAR2.

  GT_TSULCHAR2[] =  GT_TSULCHAR[].

  DELETE GT_TSULCHAR2 WHERE GONG_SEQ = '00'.

  CLEAR : GS_TSULCHAR.
  LOOP AT GT_TSULCHAR2 INTO GS_TSULCHAR.
    LV_IDX = 0.
    CLEAR : GT_SOSUN1[], GS_SOSUN1.
    DO 8 TIMES.

      MOVE-CORRESPONDING GS_TSULCHAR TO GS_SOSUN1.

      CONCATENATE 'GS_TSULCHAR-BONSU' LV_IDX INTO LV_BONSU.
      ASSIGN  (LV_BONSU) TO  <FS_BONSU>.
      CONCATENATE 'GS_TSULCHAR-SUNDIA' LV_IDX INTO LV_SUNDIA.
      ASSIGN  (LV_SUNDIA) TO  <FS_SUNDIA>.
      GS_SOSUN1-BONSU    = <FS_BONSU>.
      GS_SOSUN1-SUNDIA    = <FS_SUNDIA>.
      APPEND GS_SOSUN1 TO GT_SOSUN1.
      LV_IDX = LV_IDX + 1.
      UNASSIGN <FS_BONSU>.
      UNASSIGN <FS_SUNDIA>.

    ENDDO.

    SORT GT_SOSUN1 BY SUNDIA BONSU.
    LOOP AT GT_SOSUN1 INTO GS_SOSUN1.
      MOVE-CORRESPONDING GS_SOSUN1 TO GS_SOSUN1_SUM.
      LV_BONSU_SUM = LV_BONSU_SUM + GS_SOSUN1-BONSU.
      AT END OF SUNDIA.
        GS_SOSUN1_SUM-BONSU = LV_BONSU_SUM.
        APPEND GS_SOSUN1_SUM TO GT_SOSUN1_SUM.
        CLEAR : GS_SOSUN1_SUM, LV_BONSU_SUM.
      ENDAT.
    ENDLOOP.

  ENDLOOP.

  DELETE GT_SOSUN1_SUM WHERE GONG_SEQ = '00'.

  SORT GT_SOSUN1_SUM BY BONSU DESCENDING.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZEDT0640
    FROM ZEDT0640
    FOR ALL ENTRIES IN @GT_TSULCHAR
   WHERE TYPECODE = @GT_TSULCHAR-CORE1_SHAPE+0(4).

  SELECT *
    APPENDING CORRESPONDING FIELDS OF TABLE @GT_ZEDT0640
    FROM ZEDT0640
    FOR ALL ENTRIES IN @GT_TSULCHAR
   WHERE TYPECODE = @GT_TSULCHAR-CORE3_SHAPE+0(4).



*  KNA1고객 번호 내역
  CHECK GT_DATA[] IS NOT INITIAL.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_KNA1
    FROM KNA1
    FOR ALL ENTRIES IN GT_DATA
   WHERE KUNNR = GT_DATA-KUNNR.
  SORT GT_KNA1 BY KUNNR.

*  MAKT 자재 내역
  CHECK GT_DATA[] IS NOT INITIAL.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
    FROM MAKT
    FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR_F
      AND SPRAS = SY-LANGU.
  SORT GT_MAKT BY MATNR.


  CHECK GT_TSULDM[] IS NOT INITIAL.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKT2
    FROM MAKT
    FOR ALL ENTRIES IN GT_TSULDM
   WHERE MATNR = GT_TSULDM-MATNR
      AND SPRAS = SY-LANGU.
  SORT GT_MAKT2 BY MATNR.


*  ZGTPPT3291
  CHECK GT_DATA[] IS NOT INITIAL.
  SELECT GRPNR, VBELN, MATNR_F, GONG_CD, MATNR, SEQ,LOSS
    INTO CORRESPONDING FIELDS OF TABLE @GT_T3291
    FROM ZGTPPT3291
    FOR ALL ENTRIES IN @GT_DATA
    WHERE GRPNR EQ @GT_DATA-GRPNR
      AND VBELN EQ @GT_DATA-VBELN+0(10)
      AND MATNR_F EQ @GT_DATA-MATNR_F "
*      AND GONG_CD EQ @GT_DATA-GONG_CD
*      AND MATNR   = GS_TSULDM-MATNR
     .
  SORT GT_T3291 BY GRPNR VBELN MATNR_F GONG_CD MATNR SEQ DESCENDING.


*  EKPO
  PERFORM SET_EKORG.

* 원자재, 원자재 내역으로 데이터 구성
  REFRESH GT_MAKT3.
  IF S_IDNRK[] IS NOT INITIAL OR S_MAKT2[] IS NOT INITIAL.
    SELECT MATNR MAKTX FROM MAKT
      INTO CORRESPONDING FIELDS OF TABLE GT_MAKT3
      WHERE MATNR IN S_IDNRK
        AND MAKTX IN S_MAKT2
        AND SPRAS = SY-LANGU.

    SORT GT_MAKT3 BY MATNR.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form exit_program
*&---------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_alv_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT   CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA:
    LS_VARIANT TYPE DISVARIANT.

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
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .
  DATA : LS_DYNTXT TYPE SMP_DYNTXT.

*-- 1. Function Key 정보 구성
  LS_DYNTXT = VALUE #(
                      ICON_ID   = ICON_VIEW_LIST
                      ICON_TEXT = |메일 수신자 관리|
                     ).
  SSCRFIELDS-FUNCTXT_01 = LS_DYNTXT.

*  IF S_DATUV[] IS INITIAL.
*
*    S_DATUV-SIGN   = 'I'.
*    S_DATUV-OPTION = 'BT'.
** 시작: 이번달 1일
*    CONCATENATE SY-DATUM+0(6) '01'  INTO S_DATUV-LOW .
** 종료: 3개월후  말일
**현재일자 대비 3개월 후를 가져 온다
*    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
*      EXPORTING
*        MONTHS  = '3'
*        OLDDATE = SY-DATUM
*      IMPORTING
*        NEWDATE = S_DATUV-HIGH.
** 현재일자가 속한 월의 마지막 일자를 RETURN해 줍니다.
*    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*      EXPORTING
*        DAY_IN            = S_DATUV-HIGH
*      IMPORTING
*        LAST_DAY_OF_MONTH = S_DATUV-HIGH
*      EXCEPTIONS
*        DAY_IN_NO_DATE    = 1
*        OTHERS            = 2.
*
*    APPEND S_DATUV.
*  ENDIF.
*
*  CLEAR : GT_OPTYPE[], GT_OPTYPE, GS_OPTYPE.
*  GS_OPTYPE-OPTYPE  = '01'.
*  GS_OPTYPE-OPTYPET = '연속 생산일'.
*  GS_OPTYPE-NOPNM   = '연속 생산일'.
*  APPEND GS_OPTYPE TO  GT_OPTYPE.
*
*  GS_OPTYPE-OPTYPE  = '02'.
*  GS_OPTYPE-OPTYPET = '교체 소요일'.
*  GS_OPTYPE-NOPNM   = '교체 소요일'.
*  APPEND GS_OPTYPE TO  GT_OPTYPE.
*
*  GS_OPTYPE-OPTYPE  = '03'.
*  GS_OPTYPE-OPTYPET = '비가동'.
*  GS_OPTYPE-NOPNM   = '비가동'.
*  APPEND GS_OPTYPE TO  GT_OPTYPE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_f4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_ARBPL USING    PV_GONG. .

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.

*-- 설비- 작업장  F4 정보 Select
  SELECT A~WERKS,  A~ARBPL,  B~KTEXT
    FROM CRHD AS A INNER JOIN CRTX AS B
                   ON A~OBJTY =  B~OBJTY
                   AND A~OBJID = B~OBJID
                   AND A~OBJTY = 'A'
   WHERE A~OBJTY   EQ 'A'
     AND A~WERKS   EQ @LV_WERKS
     AND B~SPRAS   EQ @SY-LANGU
    INTO TABLE @DATA(LT_IFNO).

  SORT LT_IFNO BY WERKS ARBPL KTEXT.

  DELETE ADJACENT DUPLICATES FROM LT_IFNO
                  COMPARING  WERKS ARBPL KTEXT.

  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'CRHD'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  PERFORM GET_FIELDINFO             USING    'CRTX'
                                             'KTEXT'
                                    CHANGING LS_FIELD.

  LS_FIELD = VALUE #( BASE LS_FIELD
                      POSITION = 0139
                      OFFSET   = 001164
                      REPTEXT  = '작업장명'

                    ).

  APPEND LS_FIELD TO LT_FIELDS.

  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = '플랜트'.
        <LS_FIELD>-SCRTEXT_M = '플랜트'.
        <LS_FIELD>-SCRTEXT_L = '플랜트'.
        <LS_FIELD>-REPTEXT   = '플랜트'.
      WHEN 'ARBPL'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 8.
        <LS_FIELD>-SCRTEXT_S = '작업장'.
        <LS_FIELD>-SCRTEXT_M = '작업장'.
        <LS_FIELD>-SCRTEXT_L = '작업장'.
        <LS_FIELD>-REPTEXT   = '작업장'.
      WHEN 'KTEXT'.
        <LS_FIELD>-POSITION = 3.
        <LS_FIELD>-OFFSET = 24.
        <LS_FIELD>-SCRTEXT_S = '작업장명'.
        <LS_FIELD>-SCRTEXT_M = '작업장명'.
        <LS_FIELD>-SCRTEXT_L = '작업장명'.
        <LS_FIELD>-REPTEXT   = '작업장명'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.

  SORT LT_FIELDS BY POSITION.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ARBPL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '작업장리스트'
    TABLES
      VALUE_TAB       = LT_IFNO
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  PV_GONG = LT_RETURN-FIELDVAL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fieldinfo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      <-- LS_FIELD
*&---------------------------------------------------------------------*
FORM GET_FIELDINFO  USING    PV_TABNAME   TYPE DDOBJNAME
                             PV_FIELDNAME
                    CHANGING PS_FIELD_TAB TYPE DFIES.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = PV_TABNAME
      FIELDNAME      = PV_FIELDNAME
      LFIELDNAME     = PV_FIELDNAME
    IMPORTING
      DFIES_WA       = PS_FIELD_TAB
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynp_values_update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DYNP
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_UPDATE  USING    PT_DYNP  TYPE DYNPREAD_T.

  CHECK PT_DYNP[] IS NOT INITIAL.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = PT_DYNP
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 납품처명
  IF NOT P_KUNNR IS INITIAL.
    CLEAR KNA1.
    SELECT SINGLE NAME1 INTO P_NAME2
             FROM KNA1
            WHERE WERKS EQ P_KUNNR.
  ELSE.
    CLEAR P_NAME2.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'T1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'R1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'T2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  LOOP AT SCREEN.

    IF SCREEN-GROUP1 = 'M2'.

      IF CB_MTSOR = 'X'. "발주내역 확인
        SCREEN-ACTIVE       = 1.
      ELSE.
        SCREEN-ACTIVE       = 0.
      ENDIF.
    ENDIF.

    CASE ABAP_TRUE.
      WHEN P_R1.
        CASE SCREEN-GROUP1.
          WHEN 'M3'.
            SCREEN-ACTIVE       = 0.
        ENDCASE.
      WHEN P_R2.
        CASE SCREEN-GROUP1.
          WHEN 'M1' OR 'M2' OR 'R1'.
            SCREEN-ACTIVE       = 0.
        ENDCASE.

        CASE SCREEN-NAME .
          WHEN 'P_SPGCD'.
            SCREEN-REQUIRED = 0.
        ENDCASE.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_OBJECT_>MT_TOOLBAR
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
                  USING   PV_FUNCTION
                          PV_ICON
                          PV_TEXT
                          PV_QUICKINFO
                          PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  LS_TOOLBAR-TEXT      = PV_TEXT.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING   PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_LAYOUT_GRID_0100.
      PERFORM SET_SORTTAB_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.                 " Layout

  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     i_soft_refresh = 'X'
      IS_STABLE = LS_SCROLL.

*  IF GV_DIS_MODE = 'D'.
*    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 0.
*  ELSE.
*    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 1.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> TEXT_M01
*&      --> TEXT_M02
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
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                               PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0100  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_NAME1 TYPE T001W-NAME1.
  DATA : LV_DESCR TYPE ZPPT0107-DESCR.

* 플랜트명
  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS
      INTO @LV_NAME1.
  ENDIF.

  CONCATENATE '플랜트 :' P_WERKS ', ' LV_NAME1 INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  CLEAR :LV_TEXT.
* SPG
  CLEAR : LV_DESCR.
  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE DESCR INTO LV_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ENDIF.

  CONCATENATE 'SPG :' P_SPGCD ', ' LV_DESCR INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

*  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0100->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  DATA : LV_PSMNG_SUM LIKE ZGTCVORDSYVAL-PSMNG.

  DATA : LV_WEMNG_SUM LIKE AFPO-WEMNG.
  DATA : LV_LINE  TYPE NUMC3,
         LV_LINE2 TYPE NUMC3..
  DATA : LV_AUART(10),
         LV_AUFNR_TXT1(100),
         LV_AUFNR_TXT(100).
  DATA : LV_VBELN(10),
         LV_VBELN_TXT1(100),
         LV_VBELN_TXT(100).
  DATA : LV_SOSUN1(200),
         LV_SOSUN2(200),
         LV_VTEXT(20),
         LV_BONSU(15),
         LV_BONSU_P     TYPE P DECIMALS 0,
         LV_SUNDIA(15),
         LV_SUNDIA_P    TYPE P DECIMALS 2,
         LV_SOSUN1_NUM  TYPE NUMC1,
         LV_SOSUN2_NUM  TYPE NUMC1.
  DATA : LV_SUM1       LIKE ZGTPPT2000-WMENG,
         LV_NWMENG_SUM LIKE ZGTPPT2000-WMENG.
  DATA : LV_SPGCD(5).

  RANGES: LR_DISPO FOR ZGTCVORDSYVAL-DISPO.

  CLEAR : GT_DISP[], GS_DISP,
          GT_DISP_MTS[], GS_DISP_MTS,
          GT_DISP_MAT[], GS_DISP_MAT.

  "====================================================================
  "  ----1차 ALV DATA 구성
  "ZGTCVSULDM 기준으로 DATA 리스트 생성
  "====================================================================
  LOOP AT GT_DATA INTO GS_DATA.

    LOOP AT GT_TSULDM INTO GS_TSULDM
                           WHERE FINSHMAT = GS_DATA-MATNR_F.

*     GS_DISP-CHECK   ,          "  체크박스
      GS_DISP-GRPNR      =   GS_DATA-GRPNR.    "  조장표번호
      " 판매 오더
      CLEAR :LV_LINE, LV_LINE2.
      LOOP AT GT_DATA_INIT INTO GS_DATA_INIT
                            WHERE GRPNR = GS_DISP-GRPNR.
        LV_LINE = LV_LINE + 1.
      ENDLOOP.

      GS_DISP-VBELN	     =   GS_DATA-VBELN.    "  판매오더
      CASE LV_LINE.
        WHEN 0.
          LV_LINE2 = 0.
          LV_AUFNR_TXT = ''.
        WHEN 1.
          LV_LINE2 = LV_LINE.
          CONCATENATE GS_DISP-VBELN '' INTO LV_VBELN_TXT1.
          CONCATENATE  LV_VBELN_TXT1
                       ''
                  INTO LV_VBELN_TXT  SEPARATED BY SPACE..
        WHEN OTHERS .
          LV_LINE2 = LV_LINE - 1.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = LV_LINE2
            IMPORTING
              OUTPUT = LV_LINE2.
          CONCATENATE GS_DISP-VBELN '외' INTO LV_VBELN_TXT1.
          CONCATENATE  LV_VBELN_TXT1
                       ' '
                       LV_LINE2
                      '건'
                  INTO LV_VBELN_TXT  SEPARATED BY SPACE..
      ENDCASE.
      GS_DISP-VBELN_TXT	 =   LV_VBELN_TXT.    "  판매오더
      GS_DISP-KUNNR      =   GS_DATA-KUNNR.  "   고객사코드
      " 납선
      CLEAR : GS_KNA1.
      READ TABLE GT_KNA1 INTO GS_KNA1
                         WITH KEY KUNNR = GS_DATA-KUNNR
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-NAME1   =   GS_KNA1-NAME1.
      ENDIF.

      GS_DISP-EDATU      =   GS_DATA-EDATU.  "   납품요청일

      " 설계서번호/REVISION  MATNR_F 완제품 기준 "ZGTCVSULDM" 추출
      GS_DISP-SUL_NO  =   GS_TSULDM-SUL_NO.  " 설계서번호
      GS_DISP-REV_SEQ =   GS_TSULDM-REV_SEQ. "REVISION

      " 소선구성 1  /소선구성 2
      CLEAR : GS_SOSUN1_SUM.
      DELETE GT_SOSUN1_SUM WHERE BONSU = '0.0' AND SUNDIA = '0.0'.

      SORT GT_SOSUN1_SUM BY MATNR  WERKS SPART SUL_NO REV_SEQ
                            GONG_SEQ  SUNDIA BONSU.

      READ TABLE GT_TSULCHAR INTO GS_TSULCHAR
                           WITH KEY MATNR = GS_DATA-MATNR_F
                           BINARY SEARCH.
      IF SY-SUBRC = 0.
        SORT GT_SOSUN1_SUM BY MATNR GONG_SEQ REV_SEQ DESCENDING
                              .
        "소선정보1 구성
        CLEAR : LV_SOSUN1, LV_SOSUN2,
                LV_BONSU, LV_SUNDIA,
                LV_BONSU_P, LV_SUNDIA_P.
        IF GS_TSULCHAR-GONG_SEQ = '00' AND GS_TSULCHAR-SOSUN3 = 0.
          CLEAR : GS_SOSUN1_SUM.
          READ TABLE GT_SOSUN1_SUM INTO GS_SOSUN1_SUM
                                   WITH KEY MATNR = GS_DATA-MATNR_F
                                            WERKS = GS_TSULDM-WERKS
                                            SPART = GS_TSULDM-SPART
                                            SUL_NO = GS_TSULDM-SUL_NO
                                            REV_SEQ = GS_TSULDM-REV_SEQ
                                            GONG_SEQ = '01'.
*                                                    JACK_SEQ = GS_TSULDM-JACK_SEQ.
          CLEAR :LV_SOSUN1, LV_BONSU, LV_SUNDIA.
          CLEAR : GS_ZEDT0640.
          READ TABLE GT_ZEDT0640 INTO GS_ZEDT0640
                          WITH KEY TYPECODE = GS_TSULCHAR-CORE1_SHAPE+0(4).
          LV_BONSU_P  = GS_SOSUN1_SUM-BONSU.
          LV_BONSU    = LV_BONSU_P.
          LV_SUNDIA_P   = GS_SOSUN1_SUM-SUNDIA.
          LV_SUNDIA   = LV_SUNDIA_P.
          CONCATENATE '('GS_TSULCHAR-CORE1_JAJE+0(4)'/'GS_ZEDT0640-VTEXT')'
          LV_BONSU'/'LV_SUNDIA
                 INTO LV_SOSUN1.
        ENDIF.

        "소선정보1/2 구성
        IF GS_TSULCHAR-GONG_SEQ = '00' AND GS_TSULCHAR-SOSUN3 <> 0.
          "소선정보1 구성
          LV_SOSUN1_NUM = 1.
          LOOP AT GT_SOSUN1_SUM INTO GS_SOSUN1_SUM
                                WHERE MATNR = GS_DATA-MATNR_F
                                  AND WERKS = GS_TSULDM-WERKS
                                  AND SPART = GS_TSULDM-SPART
                                  AND SUL_NO = GS_TSULDM-SUL_NO
                                  AND REV_SEQ = GS_TSULDM-REV_SEQ
                                  AND GONG_SEQ = '01'.
*                                        JACK_SEQ = GS_TSULDM-JACK_SEQ.

            CLEAR : LV_BONSU, LV_SUNDIA.

            IF LV_SOSUN1_NUM = 1 .
              CLEAR : GS_ZEDT0640.
              READ TABLE GT_ZEDT0640 INTO GS_ZEDT0640
                              WITH KEY TYPECODE = GS_TSULCHAR-CORE1_SHAPE+0(4).

              LV_BONSU_P  = GS_SOSUN1_SUM-BONSU.
              LV_BONSU    = LV_BONSU_P.
              LV_SUNDIA_P   = GS_SOSUN1_SUM-SUNDIA.
              LV_SUNDIA   = LV_SUNDIA_P.
              CONCATENATE '('GS_TSULCHAR-CORE1_JAJE+0(4)'/'GS_ZEDT0640-VTEXT')'
                           LV_BONSU'/'LV_SUNDIA
                     INTO LV_SOSUN1.
            ELSE.
              IF GS_SOSUN1_SUM-BONSU <> 0 AND GS_SOSUN1_SUM-SUNDIA <> 0.
                LV_BONSU_P  = GS_SOSUN1_SUM-BONSU.
                LV_BONSU    = LV_BONSU_P.
                LV_SUNDIA_P   = GS_SOSUN1_SUM-SUNDIA.
                LV_SUNDIA   = LV_SUNDIA_P.
                CONCATENATE LV_SOSUN1'+' LV_BONSU'/'LV_SUNDIA INTO LV_SOSUN1.
              ENDIF.
            ENDIF.


            LV_SOSUN1_NUM = LV_SOSUN1_NUM + 1.
          ENDLOOP.

          "소선정보2 구성
          LV_SOSUN2_NUM = 1 .
          CLEAR : GS_SOSUN1_SUM.
          LOOP AT GT_SOSUN1_SUM INTO GS_SOSUN1_SUM  WHERE MATNR = GS_DATA-MATNR_F
                                                      AND WERKS = GS_TSULDM-WERKS
                                                      AND SPART = GS_TSULDM-SPART
                                                      AND SUL_NO = GS_TSULDM-SUL_NO
                                                      AND REV_SEQ = GS_TSULDM-REV_SEQ
                                                      AND GONG_SEQ <> '01'.
*                                                    JACK_SEQ = GS_TSULDM-JACK_SEQ.
            CLEAR :  LV_BONSU, LV_SUNDIA.
            IF LV_SOSUN2_NUM = 1 .
              CLEAR : GS_ZEDT0640.
              READ TABLE GT_ZEDT0640 INTO GS_ZEDT0640
                              WITH KEY TYPECODE = GS_TSULCHAR-CORE3_SHAPE+0(4).

              LV_BONSU_P  = GS_SOSUN1_SUM-BONSU.
              LV_BONSU    = LV_BONSU_P.
              LV_SUNDIA_P   = GS_SOSUN1_SUM-SUNDIA.
              LV_SUNDIA   = LV_SUNDIA_P.
              CONCATENATE '('GS_TSULCHAR-CORE3_JAJE+0(4)'/'GS_ZEDT0640-VTEXT')'
              LV_BONSU'/'LV_SUNDIA
                     INTO LV_SOSUN2.
            ELSE.
              IF GS_SOSUN1_SUM-BONSU <> 0 AND GS_SOSUN1_SUM-SUNDIA <> 0.
                LV_BONSU_P  = GS_SOSUN1_SUM-BONSU.
                LV_BONSU    = LV_BONSU_P.
                LV_SUNDIA_P   = GS_SOSUN1_SUM-SUNDIA.
                LV_SUNDIA   = LV_SUNDIA_P.
                CONCATENATE LV_SOSUN2
                            '+' LV_BONSU'/'LV_SUNDIA
                       INTO LV_SOSUN2.
              ENDIF.
            ENDIF.

            LV_SOSUN2_NUM = LV_SOSUN2_NUM + 1.
          ENDLOOP.

        ENDIF.

        CONDENSE LV_SOSUN1 NO-GAPS.
        GS_DISP-SOSUN1  =   LV_SOSUN1.  " 소선구성 1

        CONDENSE LV_SOSUN2 NO-GAPS.
        GS_DISP-SOSUN3  =   LV_SOSUN2.   " 소선구성 2

        GS_DISP-KV         =   GS_TSULCHAR-KV.    " KV
        GS_DISP-SQ         =   GS_TSULCHAR-SQ.    " SQ
      ENDIF.

      GS_DISP-MATNR_F    =   GS_DATA-MATNR_F.   " 제품

      " 제품명
      CLEAR : GS_MAKT.
      READ TABLE GT_MAKT INTO GS_MAKT
                         WITH KEY MATNR = GS_DATA-MATNR_F
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-MAKTX_F =   GS_MAKT-MAKTX.
      ENDIF.

*      GS_DISP-MEINS      =  GS_AFPO_P-MEINS.     "   수주단위
      GS_DISP-GONG_SEQ   =  GS_TSULDM-GONG_SEQ. "  공정순서
      GS_DISP-GONG_CD    =  GS_TSULDM-GONG_CD. "  공정코드
      GS_DISP-GONG_NM    =  GS_TSULDM-GONG_NM. "공정

      " 자재내역
      CLEAR : GS_MAKT.
      READ TABLE GT_MAKTALL INTO GS_MAKT
                         WITH KEY MATNR = GS_TSULDM-MATNR
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-MAKTX_R =   GS_MAKT-MAKTX.
      ENDIF.
      GS_DISP-MATNR_R    =   GS_TSULDM-MATNR.   "  자재코드



      GS_DISP-JAJE_QTY   =   GS_TSULDM-JAJE_QTY." 정미량
      GS_DISP-JAJE_UNIT  =   GS_TSULDM-JAJE_UNIT.          "JAJE_UNIT단위

      IF GS_DISP-BANFN IS NOT INITIAL..
        GS_DISP-PO_YN  =    'Y'.                  " 발주여부
      ELSE.
        GS_DISP-PO_YN  =    'N' .
      ENDIF.


      APPEND GS_DISP TO GT_DISP .

    ENDLOOP.

  ENDLOOP.
  .

*      ZGTPPT3290 발주내역 정보 조회 한다
  CHECK GT_DATA[] IS NOT INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_T8090
    FROM ZGTPPT3290 AS A INNER JOIN ZGTPPT3280 AS B
                       ON A~BANFN = B~BANFN
                       AND A~BNFPO = B~BNFPO
    FOR ALL ENTRIES IN @GT_DISP
    WHERE A~GRPNR   = @GT_DISP-GRPNR
      AND A~VBELN   = @GT_DISP-VBELN+0(10)
      AND A~MATNR_F = @GT_DISP-MATNR_F
      AND A~GONG_CD = @GT_DISP-GONG_CD
*      AND A~MATNR    = @GT_DISP-MATNR_R
      AND A~LOEKZ     = ''
      .
  SORT GT_T8090 BY GRPNR
                   VBELN
                   MATNR_F
                   GONG_CD
                   AUFNR
                   MATNR.

*  MARA DATA 조회
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARA
    FROM MARA
    FOR ALL ENTRIES IN @GT_DISP
    WHERE MATNR = @GT_DISP-MATNR_R.
  SORT GT_MARA BY MATNR.

*     ZGTPP_CV_ORD_STAT DATA CHECK(삭제오더체크)를 위한 DATA 취합
  CLEAR : GT_TCVORD_STAT[].
  IF GT_T2010[] IS NOT INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_TCVORD_STAT
      FROM ZGTPP_CV_ORD_STAT
      FOR ALL ENTRIES IN @GT_T2010
     WHERE AUFNR = @GT_T2010-ORDNR.
  ENDIF.

  LOOP AT GT_T2010 INTO GS_T2010.
    READ TABLE GT_TCVORD_STAT INTO GS_TCVORD_STAT
                              WITH KEY AUFNR = GS_T2010-ORDNR.
    IF SY-SUBRC = 0.
      IF GS_TCVORD_STAT-DEL  = 'X'
         OR GS_TCVORD_STAT-DLFL = 'X'.

        GS_T2010-DELCHK = 'X'.

      ENDIF.
      MODIFY GT_T2010 FROM GS_T2010.
    ENDIF.
  ENDLOOP.

  "ZGTPP_CV_ORD_STAT 삭제처리 된 오더  DELETE
  DELETE GT_T2010 WHERE DELCHK = 'X'.

  "====================================================================
  "  ----2차 ALV DISP DATA 구성
  "  오더 총 수량 , 잔여수량 입고 수량
  "  1차 로스율 소요량(수주 기준) 소요량(잔여 기준)
  "====================================================================
  PERFORM CREATE_ALV_DISP_DATA2.

  "====================================================================
  " MTS 오더 선택시 ALV DATA 추가  구성 START
  "====================================================================
*  ZGTPPT3291
  CLEAR : GT_T3291[].
  SELECT GRPNR, VBELN, MATNR_F, GONG_CD, MATNR, SEQ,LOSS
    INTO CORRESPONDING FIELDS OF TABLE @GT_T3291
    FROM ZGTPPT3291
    FOR ALL ENTRIES IN @GT_DISP
    WHERE GRPNR EQ @GT_DISP-GRPNR
    .
  SORT GT_T3291 BY GRPNR
                   VBELN
                   MATNR_F
                   GONG_CD
                   MATNR
                   SEQ DESCENDING.

  IF CB_MTSOR = 'X'.

    GT_DISP_AUF[] =  GT_DISP[].

    DELETE GT_DISP_AUF WHERE AUFNR_T = ''.

    DELETE ADJACENT DUPLICATES FROM GT_DISP_AUF
                              COMPARING AUFNR_T.
    SORT GT_DISP_AUF BY AUFNR_T.

    CONCATENATE P_SPGCD+0(2) '*' INTO LV_SPGCD .
    LR_DISPO-SIGN   = 'I'.
    LR_DISPO-OPTION = 'CP'.
    LR_DISPO-LOW = LV_SPGCD.
    LR_DISPO-HIGH = ''.

    APPEND LR_DISPO.

    SELECT A~WERKS,
           A~AUART,
           A~AUFNR,
           A~POSNR,
           A~PSMNG,
           A~WEMNG,
           A~MEINS,
           A~MATNR,
           A~MAKTX,
           A~GSTRP,
           A~KDAUF,
           A~KDPOS,
           A~KUNNR,
           A~NAME1,
           A~PDCAVOLTAGE,
           A~PDCACONDSIZE1ST,
           A~PDCAPROCCODE,
           A~PDCAPROCNAME
      INTO CORRESPONDING FIELDS OF TABLE @GT_TCVORDSYVAL
      FROM ZGTCVORDSYVAL AS A INNER JOIN AFKO AS B
                              ON A~AUFNR = B~AUFNR
      WHERE A~WERKS  EQ @P_WERKS " 선택화면의 플랜트
        AND A~DISPO  IN @LR_DISPO "선택화면의 SPG
        AND A~GSTRP  IN @S_GSTRP " 선택화면의 오더 시작일자
        .
    SORT GT_TCVORDSYVAL BY WERKS AUFNR .

    LOOP AT GT_TCVORDSYVAL INTO GS_TCVORDSYVAL.
      READ TABLE GT_DISP_AUF INTO GS_DISP_AUF
                             WITH KEY AUFNR_T =  GS_TCVORDSYVAL-AUFNR
                             BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_TCVORDSYVAL-CHK = 'X'.
        MODIFY GT_TCVORDSYVAL FROM GS_TCVORDSYVAL.
      ENDIF.
    ENDLOOP.
    DELETE GT_TCVORDSYVAL WHERE CHK = 'X'.

    " MTS 오더별 원자재 소요량 정보 추출 (RESB)
    SELECT A~WERKS, A~AUFNR, A~RSNUM, A~RSPOS,
           A~MATNR, A~BDMNG, A~MEINS, A~AUSCH,
           B~MTART,
           C~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE @GT_RESB
      FROM RESB AS A INNER JOIN MARA AS B
                     ON A~MATNR = B~MATNR
                     INNER JOIN MAKT AS C
                     ON A~MATNR = C~MATNR
      FOR ALL ENTRIES IN @GT_TCVORDSYVAL
      WHERE A~WERKS  EQ @P_WERKS " 선택화면의 플랜트
        AND A~AUFNR  EQ @GT_TCVORDSYVAL-AUFNR " 오더번호
        AND B~MTART  NE 'MCHF' "HALB"    "반제품 제외
        AND C~SPRAS  EQ @SY-LANGU
      .
    SORT GT_RESB BY WERKS AUFNR.

    CLEAR : GT_ORDSYVALP.
    LOOP AT GT_TCVORDSYVAL INTO GS_TCVORDSYVAL.
      MOVE-CORRESPONDING GS_TCVORDSYVAL TO GS_ORDSYVALP.
      APPEND  GS_ORDSYVALP TO GT_ORDSYVALP.
      MOVE-CORRESPONDING GS_TCVORDSYVAL TO GS_ORDSYVALW.
      APPEND  GS_ORDSYVALW TO GT_ORDSYVALW.
    ENDLOOP.

    CLEAR : LV_PSMNG_SUM.
    LOOP AT GT_ORDSYVALP INTO GS_ORDSYVALP.
      GS_ORDSYVALP_SUM-AUFNR =  GS_ORDSYVALP-AUFNR.
      LV_PSMNG_SUM = LV_PSMNG_SUM + GS_ORDSYVALP-PSMNG.
      AT END OF AUFNR.
        GS_ORDSYVALP_SUM-PSMNG = LV_PSMNG_SUM.
        APPEND GS_ORDSYVALP_SUM TO GT_ORDSYVALP_SUM..
        CLEAR : LV_PSMNG_SUM.
      ENDAT.
    ENDLOOP.

*    MTS 오더 선택시 발주 내역_소요 정보 ALV DATA 추가
    SELECT *
     APPENDING CORRESPONDING FIELDS OF TABLE @GT_T8090
     FROM ZGTPPT3290 AS A INNER JOIN ZGTPPT3280 AS B
                        ON A~BANFN = B~BANFN
                        AND A~BNFPO = B~BNFPO
     FOR ALL ENTRIES IN @GT_TCVORDSYVAL
     WHERE A~VBELN = @GT_TCVORDSYVAL-KDAUF
       AND A~MATNR_F = @GT_TCVORDSYVAL-MATNR
       AND A~GONG_CD = @GT_TCVORDSYVAL-PDCAPROCCODE+0(3)
      " AND A~MATNR   = @GT_TCVORDSYVAL-MATNR_R
      .
    SORT GT_T8090 BY BANFN BNFPO.

    PERFORM CREATE_MTS_DATA.

  ENDIF. "

  " MTS 오더인 경우 삭제된 오더 제거
*  "ZGTPP_CV_ORD_STAT DATA CHECK를 위함
  CLEAR : GT_TCVORD_STAT_MTS[].
  IF GT_DISP_MTS[] IS NOT INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_TCVORD_STAT_MTS
      FROM ZGTPP_CV_ORD_STAT
      FOR ALL ENTRIES IN @GT_DISP_MTS
     WHERE AUFNR = @GT_DISP_MTS-AUFNR_T.
  ENDIF.

  LOOP AT GT_DISP_MTS INTO GS_DISP_MTS.
    READ TABLE GT_TCVORD_STAT_MTS INTO GS_TCVORD_STAT_MTS
                              WITH KEY AUFNR = GS_DISP_MTS-AUFNR_T.
    IF SY-SUBRC = 0.
      IF GS_TCVORD_STAT_MTS-DEL  = 'X'
       OR GS_TCVORD_STAT_MTS-DLFL = 'X'.
        GS_DISP_MTS-MTS_AUDEL   = 'X'.
      ENDIF.
      MODIFY GT_DISP_MTS FROM GS_DISP_MTS.
    ENDIF.
  ENDLOOP.

  DELETE GT_DISP_MTS WHERE MTS_AUDEL = 'X'.

  " MTS 포함인경우 DATA APPEND
  LOOP AT GT_DISP_MTS INTO GS_DISP_MTS.
    APPEND GS_DISP_MTS TO GT_DISP.
  ENDLOOP.
  "====================================================================
  " MTS 오더 선택시 ALV DATA 추가  구성 END
  "====================================================================

  "====================================================================
  "  ----3차 ALV DATA 구성
  "-- 구매오더 PO DATA 확인
  "====================================================================
  CLEAR : GT_DISP_TMP[].
  GT_DISP_TMP[] = GT_DISP[].
  " 수행 속도를 위해 RP내역이 있는것만 추출한다
  DELETE GT_DISP_TMP[] WHERE BANFN IS INITIAL.

  PERFORM CHECK_ALV_DISP_PO_DATA.

  "====================================================================
  "  ----4차 ALV DATA 구성
  "  -- 자재내역, 대체자재 변경유무 판단
  "====================================================================
  " 대체자재 코드 추출
  CLEAR : GT_T3292[].
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T3292
    FROM ZGTPPT3292
    FOR ALL ENTRIES IN GT_DISP
   WHERE GRPNR = GT_DISP-GRPNR
     AND VBELN = GT_DISP-VBELN+0(10)
*       AND AUFNR = GT_DISP-AUFNR_T
     AND MATNR_F = GT_DISP-MATNR_F
     AND GONG_CD = GT_DISP-GONG_CD
    .
  SORT GT_T3292 BY  GRPNR VBELN AUFNR MATNR_F
                    GONG_CD MATNR_ORIGIN
                    SEQ DESCENDING.

  PERFORM CHANGE_MATNR_SEARCH_LIST.

  " 대채 자재경우 DATA APPEND
  LOOP AT GT_DISP_MAT INTO GS_DISP_MAT.
    APPEND GS_DISP_MAT TO GT_DISP.
  ENDLOOP.

  "추가된 대체 자재 리스트로 인해 자재내역 다시 가져오기
*  MAKT 자재 내역
  CHECK GT_DATA[] IS NOT INITIAL.
  SELECT MATNR MAKTX
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKTALL
    FROM MAKT
    FOR ALL ENTRIES IN GT_DISP
   WHERE MATNR = GT_DISP-MATNR_R
      AND SPRAS = SY-LANGU.
  SORT GT_MAKTALL BY MATNR.

  SELECT MATNR MAKTX
    APPENDING  CORRESPONDING FIELDS OF TABLE GT_MAKTALL
    FROM MAKT
    FOR ALL ENTRIES IN GT_DISP
   WHERE MATNR = GT_DISP-MATNR_F
      AND SPRAS = SY-LANGU.
  SORT GT_MAKTALL BY MATNR.

*  ZGTPPT3291 변경된 로스율 내역을 가져 온다
  CLEAR : GT_T3291[].
  SELECT GRPNR, VBELN,AUFNR, MATNR_F, GONG_CD, MATNR, SEQ,LOSS
    INTO CORRESPONDING FIELDS OF TABLE @GT_T3291
    FROM ZGTPPT3291
    FOR ALL ENTRIES IN @GT_DISP
    WHERE GRPNR EQ @GT_DISP-GRPNR
    .
  SORT GT_T3291 BY GRPNR
                   VBELN
                   AUFNR
                   MATNR_F
                   GONG_CD
                   MATNR
                   SEQ DESCENDING.

  "====================================================================
  "  ----5차 ALV DATA 구성
  "  --- LOSS 최종 계산
  "  --  MTS 자재내역과 ,자재내역, 대체자재추가로  변경유무 판단
  "====================================================================
  PERFORM LAST_LOSSRATE_COL_DISP.

  " 대체자재 변경으로 리스트 추가 되어 PR생성 리스트를 재검색한다
  " 재검색된 PR리스트 수량 파악하여 N OR 해당 PR번호 DATA 생성
  PERFORM RE_SEARCH_3290.

  " 다시 기존 PR요청 내역기준으로 MAIN DISPLAY ALV LIST에서 찾아 온다----------------
  CLEAR :GT_DISP_BAN[].
  PERFORM RE_PR_SEARCH_3290.

  " PR발주 자재경우 중복 재거후 DATA APPEND
  SORT GT_DISP_BAN BY GRPNR
                      VBELN
                      MATNR_F
                      SUL_NO
                      REV_SEQ
                      GONG_CD
                      AUFNR_T
                      MATNR_R.

  DELETE ADJACENT DUPLICATES FROM GT_DISP_BAN
                          COMPARING GRPNR
                                    VBELN
                                    MATNR_F
                                    SUL_NO
                                    REV_SEQ
                                    GONG_CD
                                    AUFNR_T
                                    MATNR_R.

  CLEAR : GT_DISP_BAN2[].
  CLEAR : GT_DISP_90[], GS_DISP_90.
  " MTS 오더와 조장표 오더별로 MAIN ALV DISPLAY DATA 중에서
  " 중복된 발주내역을 check한다
  PERFORM DELETE_DUPL_CHK_PR_LIST_MTS.

  CLEAR : GT_DISP_90[], GS_DISP_90.
  PERFORM DELETE_DUPL_CHK_PR_LIST.

  " 최종 중복 발주 내역을 제거
  DELETE GT_DISP_BAN WHERE DCHK = 'X'.

  " 최종적으로 추가 check 된 발주내역을 생성
  LOOP AT GT_DISP_BAN INTO GS_DISP_BAN.

    SELECT SINGLE MAKTX
       INTO GS_DISP_BAN-MAKTX_R
       FROM MAKT
      WHERE MATNR = GS_DISP_BAN-MATNR_R
        AND SPRAS = SY-LANGU.

    APPEND GS_DISP_BAN TO GT_DISP_BAN2.
  ENDLOOP.

  SORT GT_DISP_BAN2 BY GRPNR
                      VBELN
                      MATNR_F
                      SUL_NO
                      REV_SEQ
                      GONG_CD
                      AUFNR_T
                      MATNR_R.

  DELETE ADJACENT DUPLICATES FROM GT_DISP_BAN2
                          COMPARING GRPNR
                                    VBELN
                                    MATNR_F
                                    SUL_NO
                                    REV_SEQ
                                    GONG_CD
                                    AUFNR_T
                                    MATNR_R.


  " 중복 되지 않는 pr 발주 리스트를 main alv에 추가 한다
  LOOP AT GT_DISP_BAN2 INTO GS_DISP_BAN2.
    APPEND GS_DISP_BAN2 TO GT_DISP.
  ENDLOOP.


  " 최종 발주 내역이 추가 되었음으로 기존 pr발주내역 자재 발주내역 재점검
  PERFORM RE_MAKE_LIST_DISP.

  " 잔여수량 0인 경우우 제외 옵션 체크시
  IF CB_ZERO = 'X'.
    LOOP AT GT_DISP INTO GS_DISP.
      IF GS_DISP-NWMENG > 0. " 오더 총 수량
        IF  GS_DISP-RWMENG <= 0.  " 잔여수량
          GS_DISP-MNG_CHK = 'X'.
        ENDIF.
      ENDIF.
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.
  ENDIF.

  DELETE GT_DISP WHERE MNG_CHK = 'X'.  " 잔여수량

* 원자재 원자재 내역 조회조건 추가로 화면데이터 필터링
  PERFORM FILTER_IDNRK.

  SORT GT_DISP BY GRPNR
                  VBELN
                  KUNNR
                  NAME1
                  EDATU
                  MATNR_F
                  SUL_NO
                  REV_SEQ
                  KV
                  SQ
                  GONG_SEQ
                  AUFNR_T.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4 .

  CLEAR: GS_F4, GT_F4.

  GS_F4-FIELDNAME = 'ARBPL'.
  GS_F4-REGISTER = ABAP_ON.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'OPTYPE'.
  GS_F4-REGISTER = ABAP_ON.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GO_GRID_0100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROID_ROW_ID
*&      <-- LS_DISP
*&---------------------------------------------------------------------*
FORM F4_ARBPL  USING PV_INDEX
              CHANGING PS_LIST LIKE GS_DISP.

*  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
*        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.
*
*  DATA: LT_FIELDS TYPE TABLE OF DFIES,
*        LS_FIELD  TYPE DFIES.
*  DATA: LV_WERKS TYPE WERKS_D.
*
*  CALL FUNCTION 'GET_DYNP_VALUE'
*    EXPORTING
*      I_FIELD = 'P_WERKS'
*      I_REPID = SY-REPID
*      I_DYNNR = '1000'
*    CHANGING
*      O_VALUE = LV_WERKS.
*
**-- 설비- 작업장  F4 정보 Select
*  SELECT a~WERKS,  a~ARBPL,  B~KTEXT
*    FROM CRHD AS a INNER JOIN CRTX AS B
*                   ON A~objty =  B~objty
*                   AND A~objid = B~objid
*                   AND A~objty = 'A'
*   WHERE a~objty   EQ 'A'
*     AND a~werks   EQ @P_WERKS
*     AND B~spras   EQ @sy-langu
*    INTO TABLE @DATA(lt_ifno).
*
*  SORT lt_ifno BY WERKS ARBPL KTEXT.
*
*  DELETE ADJACENT DUPLICATES FROM lt_ifno
*                  COMPARING  WERKS ARBPL KTEXT.
*
*  CLEAR LS_FIELD.
*  CALL FUNCTION 'DDIF_FIELDINFO_GET'
*    EXPORTING
*      TABNAME        = 'CRHD'
*    TABLES
*      DFIES_TAB      = LT_FIELDS
*    EXCEPTIONS
*      NOT_FOUND      = 1
*      INTERNAL_ERROR = 2
*      OTHERS         = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*
*  PERFORM get_fieldinfo             USING    'CRTX'
*                                             'KTEXT'
*                                    CHANGING ls_field.
*
*  ls_field = VALUE #( BASE ls_field
*                      position = 0139
*                      offset   = 001164
*                      reptext  = '작업장명'
*
*                    ).
*
*  APPEND ls_field TO LT_FIELDS.
*
*  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
*
*    CASE <LS_FIELD>-FIELDNAME.
*      WHEN 'WERKS'.
*        <LS_FIELD>-POSITION = 1.
*        <LS_FIELD>-OFFSET = 0.
*        <LS_FIELD>-SCRTEXT_S = '플랜트'.
*        <LS_FIELD>-SCRTEXT_M = '플랜트'.
*        <LS_FIELD>-SCRTEXT_L = '플랜트'.
*        <LS_FIELD>-REPTEXT   = '플랜트'.
*      WHEN 'ARBPL'.
*        <LS_FIELD>-POSITION = 2.
*        <LS_FIELD>-OFFSET = 8.
*        <LS_FIELD>-SCRTEXT_S = '작업장'.
*        <LS_FIELD>-SCRTEXT_M = '작업장'.
*        <LS_FIELD>-SCRTEXT_L = '작업장'.
*        <LS_FIELD>-REPTEXT   = '작업장'.
*      WHEN 'KTEXT'.
*        <LS_FIELD>-POSITION = 3.
*        <LS_FIELD>-OFFSET = 24.
*        <LS_FIELD>-SCRTEXT_S = '작업장명'.
*        <LS_FIELD>-SCRTEXT_M = '작업장명'.
*        <LS_FIELD>-SCRTEXT_L = '작업장명'.
*        <LS_FIELD>-REPTEXT   = '작업장명'.
*      WHEN OTHERS.
*        DELETE LT_FIELDS.
*    ENDCASE.
*  ENDLOOP.
*
*  SORT LT_FIELDS BY POSITION.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'ARBPL'
*      DYNPPROG        = SY-CPROG
*      DYNPNR          = SY-DYNNR
*      VALUE_ORG       = 'S'
*      WINDOW_TITLE    = '작업장리스트'
*    TABLES
*      VALUE_TAB       = lt_ifno
*      FIELD_TAB       = LT_FIELDS
*      RETURN_TAB      = LT_RETURN
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*
*  READ TABLE LT_RETURN INDEX 1.
*
*
*  PS_LIST-ARBPL = LT_RETURN-FIELDVAL.
*
*  READ TABLE lt_ifno INTO DATA(LS_ifno)
*                      WITH KEY ARBPL = PS_LIST-ARBPL
*                      BINARY SEARCH.
*  IF SY-SUBRC EQ 0.
*    PS_LIST-KTEXT = LS_ifno-KTEXT.
*    IF PS_LIST-STATUS IS INITIAL.
*      PS_LIST-STATUS  = ICON_CHANGE.
*      PS_LIST-STATUS_VAL  = 'CHA'.
*    ENDIF.
*    MODIFY GT_DISP FROM PS_LIST INDEX PV_INDEX.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_OPTYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROID_ROW_ID
*&      <-- LS_DISP
*&---------------------------------------------------------------------*
FORM F4_OPTYPE   USING PV_INDEX
              CHANGING PS_LIST LIKE GS_DISP.

*  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
*        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.
*
*  DATA: LT_FIELDS TYPE TABLE OF DFIES,
*        LS_FIELD  TYPE DFIES.
*  DATA: LV_WERKS TYPE WERKS_D.
*
*  SORT GT_OPTYPE BY OPTYPE.
*
*  CLEAR LS_FIELD.
*  CALL FUNCTION 'DDIF_FIELDINFO_GET'
*    EXPORTING
*      TABNAME        = 'ZGTPPT2130'
*    TABLES
*      DFIES_TAB      = LT_FIELDS
*    EXCEPTIONS
*      NOT_FOUND      = 1
*      INTERNAL_ERROR = 2
*      OTHERS         = 3.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*
*  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
*
*    CASE <LS_FIELD>-FIELDNAME.
*
*      WHEN 'OPTYPE'.
*        <LS_FIELD>-POSITION = 1.
*        <LS_FIELD>-OFFSET = 0.
*        <LS_FIELD>-SCRTEXT_S = '가동유형'.
*        <LS_FIELD>-SCRTEXT_M = '가동유형'.
*        <LS_FIELD>-SCRTEXT_L = '가동유형'.
*        <LS_FIELD>-REPTEXT   = '가동유형'.
*      WHEN 'NOPNM'.
*        <LS_FIELD>-POSITION = 2.
*        <LS_FIELD>-OFFSET = 4.
*        <LS_FIELD>-SCRTEXT_S = '가동유형명'.
*        <LS_FIELD>-SCRTEXT_M = '가동유형명'.
*        <LS_FIELD>-SCRTEXT_L = '가동유형명'.
*        <LS_FIELD>-REPTEXT   = '가동유형명'.
*      WHEN OTHERS.
*        DELETE LT_FIELDS.
*    ENDCASE.
*  ENDLOOP.
*
*  SORT LT_FIELDS BY POSITION.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'OPTYPE'
*      DYNPPROG        = SY-CPROG
*      DYNPNR          = SY-DYNNR
*      VALUE_ORG       = 'S'
*      WINDOW_TITLE    = '가동유형리스트'
*    TABLES
*      VALUE_TAB       = GT_OPTYPE
*      FIELD_TAB       = LT_FIELDS
*      RETURN_TAB      = LT_RETURN
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*
*  READ TABLE LT_RETURN INDEX 1.
*
*
*  PS_LIST-OPTYPE = LT_RETURN-FIELDVAL.
*
*  READ TABLE GT_OPTYPE INTO DATA(LS_OPTYPE)
*                      WITH KEY OPTYPE = PS_LIST-OPTYPE
*                      BINARY SEARCH.
*  IF SY-SUBRC EQ 0.
*    PS_LIST-OPTYPET = LS_OPTYPE-OPTYPET.
*    IF PS_LIST-STATUS IS INITIAL.
*      PS_LIST-STATUS  = ICON_CHANGE.
*      PS_LIST-STATUS_VAL  = 'CHA'.
*    ENDIF.
*    MODIFY GT_DISP FROM PS_LIST INDEX PV_INDEX.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_REQ  USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_DATE_CHK TYPE SY-DATUM.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_POSNR(5) TYPE N.
  DATA : LV_UNIT TYPE ZGTMMT4210-PSTOCK.
  DATA : LV_LIFNR TYPE LIFNR.
  DATA : LV_PR_CHK.

  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_field>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_field2> IS ASSIGNED. UNASSIGN <lv_field2>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main2> TO <lv_field2>.
  END-OF-DEFINITION.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PO_SENDER->GET_SELECTED_CELLS_ID(
          IMPORTING
           ET_CELLS = LT_CELLS ).                " CELL IDS
    WHEN OTHERS.
      RETURN.
  ENDCASE.


  " 동일 자재에 대한 PR 요청 수량 SIM
  CLEAR : GT_DISP_SUB[], GS_DISP_SUB.
  CLEAR : GT_DISP_SUM[], GS_DISP_SUM.
  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
    MOVE-CORRESPONDING GS_DISP TO GS_DISP_SUB.
    APPEND GS_DISP_SUB TO GT_DISP_SUB.
  ENDLOOP.

  LOOP AT GT_DISP_SUB INTO GS_DISP_SUB .
    MOVE-CORRESPONDING GS_DISP_SUB TO GS_DISP_SUM.
    COLLECT GS_DISP_SUM INTO GT_DISP_SUM.
  ENDLOOP.

  REFRESH GT_DISP_400.
  CLEAR LV_POSNR.


  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X' .

    "'기존 구매요청 정보' 추출. 아래 조건으로 'ZGTPPT3290' & 'ZGTPPT3280 추출하여 데이터 존재하는지 확인
    CLEAR : GT_PRCA_CHK[] , GS_PRCA_CHK.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_PRCA_CHK
      FROM ZGTPPT3290 AS A INNER JOIN ZGTPPT3280 AS B
                           ON A~BANFN = B~BANFN
                           AND A~BNFPO =  B~BNFPO
      WHERE A~GRPNR    = GS_DISP-GRPNR
        AND A~VBELN    = GS_DISP-VBELN
        AND A~MATNR_F  = GS_DISP-MATNR_F
        AND A~GONG_CD  = GS_DISP-GONG_CD
        AND A~MATNR    = GS_DISP-MATNR_R.
*        AND A~LOEKZ    = ''  .  " 추후 확인 요망
    IF GT_PRCA_CHK[] IS NOT INITIAL.
      LV_PR_CHK = 'Y'.
      "기존 구매요청 정보' 추출 성공시 PO 전환 정보, 입고 수량 추출
      READ TABLE  GT_PRCA_CHK INTO GS_PRCA_CHK INDEX 1.
      SELECT  A~EBELN, A~EBELP, A~MEINS , SUM( B~WEMNG ) AS WEMNG
        INTO CORRESPONDING FIELDS OF TABLE @GT_EKPO
        FROM EKPO AS A  INNER JOIN EKET AS B
                        ON   A~EBELN = A~EBELN
                        AND  A~EBELP = A~EBELP
       WHERE A~BANFN = @GS_PRCA_CHK-BANFN
         AND A~BNFPO = @GS_PRCA_CHK-BNFPO
       GROUP BY A~EBELN, A~EBELP,A~MEINS.
*      CLEAR : GT_PRCA_CHK[] , GT_PRCA_CHK.
    ELSE.
      LV_PR_CHK = 'N'.
*      EXIT.
    ENDIF.
  ENDLOOP.

*  CHECK LV_PR_CHK <> 'N'.

  LOOP AT GT_DISP_SUM INTO GS_DISP_SUM .
    APPEND INITIAL LINE TO GT_DISP_400
                           ASSIGNING FIELD-SYMBOL(<LS_DISP_400>).
*     순번
    ADD 10 TO LV_POSNR.
    <LS_DISP_400>-BNFPO = LV_POSNR.
*    자재, 자재내역
    <LS_DISP_400>-MATNR = GS_DISP_SUM-MATNR_R.
    <LS_DISP_400>-MAKTX =
            ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_DISP_400>-MATNR ).
    IF <LS_DISP_400>-MAKTX IS INITIAL.
      SELECT SINGLE MAKTX
        INTO <LS_DISP_400>-MAKTX
        FROM MAKT
       WHERE MATNR EQ <LS_DISP_400>-MATNR
       AND   SPRAS EQ SY-LANGU.
    ENDIF.

*    납품일
*    IF GS_DISP-LFDAT IS NOT INITIAL.
**      <LS_DISP_400>-LFDAT = GS_DISP_SUM-LFDAT..
*    ELSE.
    <LS_DISP_400>-LFDAT = SY-DATUM..
*    ENDIF.
*      요청수량 - 구매제안 수량은 전부 -
    <LS_DISP_400>-MENGE = GS_DISP_SUM-ERFMG_RE.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_DISP_400>-MATNR
      IMPORTING
        OUTPUT = <LS_DISP_400>-MATNR.

*    단위
    READ TABLE GT_MARA INTO GS_MARA WITH KEY MATNR = <LS_DISP_400>-MATNR.
    IF GS_MARA-MEINS IS NOT INITIAL.
      <LS_DISP_400>-MEINS = GS_MARA-MEINS.
    ELSE.
      SELECT SINGLE MEINS
        INTO GS_MARA-MEINS
        FROM MARA
        WHERE MATNR  = <LS_DISP_400>-MATNR.
      <LS_DISP_400>-MEINS = GS_MARA-MEINS.
    ENDIF.
*    플랜트
    <LS_DISP_400>-WERKS = P_WERKS.
*    저장소
    PERFORM GET_LGORT USING <LS_DISP_400>-MATNR CHANGING <LS_DISP_400>-LGORT.

***    READ TABLE GT_EKPO INTO GS_EKPO INDEX 1.
***    IF SY-SUBRC = 0.
****     PO 번호
***      <LS_DISP_400>-PREQ_NO = GS_EKPO-EBELN.
****     PO 품목번호
***      <LS_DISP_400>-BNFPO   = GS_EKPO-EBELP.
***    ENDIF.

  ENDLOOP.

*  헤더세팅
  CLEAR GS_REQ_DISP.
*  구매요청유형
  GS_REQ_DISP-BSART = 'NB'. " 디폴드값 세팅
  GS_REQ_DISP-BSTYP = 'B'. " 디폴드값 세팅

  READ TABLE GT_MASTER_EKORG INTO DATA(LS_EKORG) INDEX 1.
  GS_REQ_DISP-EKORG = LS_EKORG-EKORG.
  GS_REQ_DISP-EKOTX = LS_EKORG-EKOTX.

*  구매요청유형 TEXT
  PERFORM GET_TEXT_BSART USING GS_REQ_DISP-BSART 'B' CHANGING GS_REQ_DISP-BATXT.
*  구매요청유형 TEXT
  PERFORM GET_TEXT_FLIEF USING GS_REQ_DISP-FLIEF CHANGING GS_REQ_DISP-NAME1.

** 요청자
  PERFORM GET_USER_NAME CHANGING GS_REQ_DISP-AFNAM.

  CLEAR GV_MODE.

  IF GT_DISP_400[] IS INITIAL.
    GV_MODE = ABAP_TRUE. " 조회된 데이터가 없으면 변경모드로 적용
  ENDIF.

  CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 135 25.


*  PERFORM REFRESH_DATA..


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISP>_MATNR
*&      <-- <LS_DISP>_LGORT
*&---------------------------------------------------------------------*
FORM GET_LGORT USING    PV_MATNR TYPE MATNR
                      CHANGING    PV_LGORT TYPE LGORT_D.

  SELECT SINGLE LGFSB FROM MARC
    INTO PV_LGORT
   WHERE WERKS = P_WERKS
       AND MATNR = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_BSART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_REQ_DISP_BSART
*&      --> P_
*&      <-- GS_REQ_DISP_BATXT
*&---------------------------------------------------------------------*
FORM GET_TEXT_BSART  USING    PV_BSART
                              PV_BSTYP
                      CHANGING    PV_BATXT.

  SELECT SINGLE BATXT FROM T161T
      INTO PV_BATXT
   WHERE BSART = PV_BSART
       AND BSTYP = PV_BSTYP
       AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_REQ_DISP_FLIEF
*&      <-- GS_REQ_DISP_NAME1
*&---------------------------------------------------------------------*
FORM GET_TEXT_FLIEF   USING    PV_FLIEF TYPE LIFNR
                            CHANGING    PV_NAME1.

  SELECT SINGLE NAME1 FROM LFA1
    INTO PV_NAME1
   WHERE LIFNR = PV_FLIEF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_USER_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_REQ_DISP_AFNAM
*&---------------------------------------------------------------------*
FORM GET_USER_NAME  CHANGING PV_AFNAM.

  DATA : LS_USER_ADDR  TYPE USER_ADDR.

  CALL FUNCTION 'FKK_GET_USER_NAME'
    EXPORTING
      I_UNAME     = SY-UNAME
    IMPORTING
      E_USER_ADDR = LS_USER_ADDR.
  IF LS_USER_ADDR IS NOT INITIAL.
    PV_AFNAM = LS_USER_ADDR-NAME_TEXTC.
  ENDIF.
  .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_DATA .

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form TRANSLATE_UNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CV_MATNR
*&      --> LS_CHK_MEINS_MEINS
*&      --> LS_CV_MEINS
*&      <-- GS_DSUM_DMQTY
*&---------------------------------------------------------------------*
FORM TRANSLATE_UNIT  USING    PV_MATNR TYPE MATNR
                                             PV_ORING_MEINS TYPE MEINS
                                             PV_ORDER_MEINS TYPE MEINS
                             CHANGING   PV_QTY.



  DATA : LV_QTY TYPE EKPO-MENGE.
  LV_QTY = PV_QTY.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR    " <-- 해당 자재코드
      I_IN_ME              = PV_ORDER_MEINS  "<-- 현 수량의 단위
      I_OUT_ME             = PV_ORING_MEINS " <-- 변경되어질 수량의 단위
      I_MENGE              = LV_QTY " <-- 현 수량 변수
    IMPORTING
      E_MENGE              = LV_QTY " <-- 변경되어질 수량변수
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

  PV_QTY = LV_QTY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0400 .
  CREATE OBJECT GO_CONTAIN_0400
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAIN_0400'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
      I_APPL_EVENTS = ABAP_TRUE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0400
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0400  USING  PO_GRID
                                       TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  CASE PO_GRID.

    WHEN GO_GRID_0400.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0400 .

  CLEAR GS_LAYOUT_0400.
*  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWMARK   = ABAP_TRUE.
  GS_LAYOUT_0400-STYLEFNAME = 'CELLTAB'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0400 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_400'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0400.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_DISP_400
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0400 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 1.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 2.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_POS = 3.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품일'.
        <LS_FCAT>-COL_POS = 4.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QUANTITY = 'MEINS'.
        <LS_FCAT>-COL_POS = 5.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 6.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 7.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 8.
      WHEN 'BIGO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기타사항(메모)'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 9.
        <LS_FCAT>-OUTPUTLEN = 20.
        <LS_FCAT>-EDIT = 'X'.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 10.
      WHEN 'PREQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 11.
      WHEN 'BNFPO2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-COL_POS = 12.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_POS = 13.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0400 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR ls_celltab.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    ls_celltab-fieldname = lv_fieldname.
    ls_celltab-style = CONV #( &2 ).
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    __SET_STYLE : 'STATUS' ALV_STYLE_COLOR_POSITIVE,
                          'PREQ_NO' ALV_STYLE_COLOR_POSITIVE,
                          'BNFPO2' ALV_STYLE_COLOR_POSITIVE,
                          'MESSAGE' ALV_STYLE_COLOR_POSITIVE.
    IF GV_MODE = ABAP_TRUE.
      __SET_STYLE : 'MATNR' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ELSE.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0400 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0400_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0400_DISPLAY .

  CALL METHOD GO_GRID_0400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0400
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0400
    CHANGING
      IT_OUTTAB            = GT_DISP_400
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

  GO_GRID_0400->SET_READY_FOR_INPUT( 1 ).

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_FLIEF_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_FLIEF_0400 .

  DATA : LR_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF LR_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : BEGIN OF LS_FLIEF,
           MATNR  TYPE EINA-MATNR,
           WERKS  TYPE EINE-WERKS,
           LIFNR  TYPE EINA-LIFNR,
           NAME1  TYPE LFA1-NAME1,
           INFNR  TYPE EINA-INFNR,
           ESOKZ  TYPE EINE-ESOKZ,
           DDTEXT TYPE DD07T-DDTEXT,
         END OF LS_FLIEF.
  DATA : LT_FLIEF LIKE TABLE OF LS_FLIEF.
  DATA : LV_POSION(4) TYPE N.
  DATA : LV_OFFSET(6) TYPE N.

  DATA : LO_FLIEF TYPE REF TO DATA.

  CREATE DATA LO_FLIEF LIKE LS_FLIEF.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LOOP AT GT_DISP_400 INTO GS_DISP_400.
    CLEAR LS_MATNR.
    IF GS_DISP_400-MATNR IS NOT INITIAL.
      LS_MATNR-SIGN = 'I'.
      LS_MATNR-OPTION = 'EQ'.
      LS_MATNR-LOW = GS_DISP_400-MATNR.
      COLLECT LS_MATNR INTO LR_MATNR.
    ENDIF.
  ENDLOOP.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_POSION.
  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).
    IF <LS_FIELD_TAB>-FIELDNAME = 'LIFNR'.
      <LS_FIELD_TAB>-KEYFLAG = ABAP_TRUE.
    ENDIF.

    <LS_FIELD_TAB>-REPTEXT  = <LS_FIELD_TAB>-SCRTEXT_M.
    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
*    ADD 1 TO LV_POSION.
*    <LS_FIELD_TAB>-POSITION = LV_POSION.
  ENDLOOP.

  SELECT A~MATNR, B~WERKS, A~LIFNR, C~NAME1, A~INFNR, B~ESOKZ, D~DDTEXT
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
    LEFT JOIN DD07T AS D ON D~DOMVALUE_L = B~ESOKZ
                          AND D~DDLANGUAGE = @SY-LANGU
                          AND D~DOMNAME = 'ESOKZ'
   WHERE A~MATNR IN @LR_MATNR
      AND B~EKORG  = @GS_REQ_DISP-EKORG
      AND B~WERKS  = @P_WERKS
      AND A~LOEKZ   = ' '
      AND B~LOEKZ   = ' '
     INTO CORRESPONDING FIELDS OF TABLE @LT_FLIEF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPROFIELD     = 'GS_REQ_DISP-FLIEF'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공급업체'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_FLIEF                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_REQ_DISP-FLIEF = LS_RETURN_TAB-FIELDVAL.
    READ TABLE LT_FLIEF INTO LS_FLIEF WITH KEY LIFNR = GS_REQ_DISP-FLIEF.
    IF SY-SUBRC EQ 0.
      GS_REQ_DISP-NAME1 = LS_FLIEF-NAME1.
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EKORG .

  REFRESH GT_MASTER_EKORG. " 유효한 구매조직

  SELECT A~EKORG, B~EKOTX
    FROM T024W AS A
    INNER JOIN T024E AS B
                            ON B~EKORG = A~EKORG
    WHERE A~WERKS = @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_MASTER_EKORG.

  SORT GT_MASTER_EKORG BY EKORG.
  DELETE ADJACENT DUPLICATES FROM GT_MASTER_EKORG COMPARING EKORG.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_REQ_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_REQ_0400  TABLES  PT_DISP STRUCTURE GS_DISP
                           USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                           .

  DATA : LV_ERR.
  DATA : LS_PRHEADER TYPE BAPIMEREQHEADER.
  DATA : LS_PRHEADERX TYPE BAPIMEREQHEADERX.
  DATA : LS_PRHEADEREXP TYPE BAPIMEREQHEADER.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE  TABLE OF BAPIMEREQITEMX.
  DATA : LT_PRITEMTEXT   TYPE  TABLE OF BAPIMEREQITEMTEXT.
  DATA : LT_DISP_MESSAGE TYPE TABLE OF ZTESMESSAGE.
  DATA : LV_SEQ(6) TYPE N.

*  PERFORM CHECK_REQ CHANGING LV_ERR. "구매요청 생성전 점검
*
*  IF LV_ERR EQ ABAP_TRUE.
*    RETURN.
*  ENDIF.
*
  CHECK GT_DISP_400[] IS NOT INITIAL.


*  if GS_REQ_DISP-FLIEF is INITIAL.
*    MESSAGE s003 DISPLAY LIKE 'E' WITH '공급업체를 입력하세요.'.
*    RETURN.
*  ENDIF.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '해당 정보로 구매요청이 생성됩니다. 진행하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

* Bapi 정보 구성
  LS_PRHEADER-PR_TYPE = GS_REQ_DISP-BSART."화면에서 선택한 구매요청 유형
  LS_PRHEADERX-PR_TYPE = ABAP_TRUE.

  LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
    <LS_PRITEM>-PREQ_ITEM  = <LS_MAIN>-BNFPO. "ALV의 품목번호 5자리
    <LS_PRITEM>-PREQ_NAME  = GS_REQ_DISP-AFNAM. "화면의 요청자
    <LS_PRITEM>-MATERIAL   = <LS_MAIN>-MATNR. "ALV의 자재코드
    <LS_PRITEM>-PLANT      = <LS_MAIN>-WERKS.    "ALV의 플랜트
    <LS_PRITEM>-STORE_LOC  = <LS_MAIN>-LGORT."ALV의 저장위치
    <LS_PRITEM>-QUANTITY   = <LS_MAIN>-MENGE. "ALV의 수량
    <LS_PRITEM>-UNIT       = <LS_MAIN>-MEINS.     "ALV의 단위
    <LS_PRITEM>-PURCH_ORG  = GS_REQ_DISP-EKORG. "화면의 구매조직
    <LS_PRITEM>-DELIV_DATE = <LS_MAIN>-LFDAT."화면의 납품일
    CASE GS_REQ_DISP-CHECK.
      WHEN ''.
        <LS_PRITEM>-FIXED_VEND = GS_REQ_DISP-FLIEF."화면의 공급업체(재고이전 지시자 미체크시)
      WHEN ABAP_TRUE.
        <LS_PRITEM>-SUPPL_PLNT = GS_REQ_DISP-RESWK."화면 상단에서 입력한 공급플랜트(재고이전 지시자 체크시)
        <LS_PRITEM>-ITEM_CAT = '7'. "7(재고이전 지시자 체크시), 기본 빈값
    ENDCASE.

    APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
    <LS_PRITEMX>-PREQ_ITEM  = <LS_MAIN>-BNFPO. "ALV의 품목번호 5자리
    <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
    <LS_PRITEMX>-PREQ_NAME  = ABAP_TRUE.
    <LS_PRITEMX>-MATERIAL   = ABAP_TRUE.
    <LS_PRITEMX>-PLANT      = ABAP_TRUE.
    <LS_PRITEMX>-STORE_LOC  = ABAP_TRUE.
    <LS_PRITEMX>-QUANTITY   = ABAP_TRUE.
    <LS_PRITEMX>-UNIT       = ABAP_TRUE.
    <LS_PRITEMX>-PURCH_ORG  = ABAP_TRUE.
    <LS_PRITEMX>-DELIV_DATE = ABAP_TRUE.
    CASE GS_REQ_DISP-CHECK.
      WHEN ''.
        <LS_PRITEMX>-FIXED_VEND = ABAP_TRUE."X(재고이전 지시자 미체크시)
      WHEN ABAP_TRUE.
        <LS_PRITEMX>-SUPPL_PLNT = ABAP_TRUE. "X(재고이전 지시자 체크시)
        <LS_PRITEMX>-ITEM_CAT   = ABAP_TRUE. "X(재고이전 지시자 체크시)
    ENDCASE.

    "LT_PRITEMTEXT
    APPEND INITIAL LINE TO LT_PRITEMTEXT ASSIGNING FIELD-SYMBOL(<LS_PRITEMTEXT>).
    <LS_PRITEMTEXT>-PREQ_ITEM = <LS_MAIN>-BNFPO. "ALV의 품목번호 5자리
    <LS_PRITEMTEXT>-TEXT_LINE = <LS_MAIN>-BIGO. "ALV에서 품목별로 입력한 "기타사항(메모)"

  ENDLOOP.

* Bapi 실행
  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER    = LS_PRHEADER
      PRHEADERX   = LS_PRHEADERX
    IMPORTING
      PRHEADEREXP = LS_PRHEADEREXP
    TABLES
      RETURN      = LT_RETURN
      PRITEM      = LT_PRITEM
      PRITEMX     = LT_PRITEMX
      PRITEMTEXT  = LT_PRITEMTEXT.

  READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0. " 에러건 존재시

    LOOP AT GT_DISP_400 ASSIGNING <LS_MAIN>.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      IF LS_RETURN-MESSAGE IS NOT INITIAL.
        <LS_MAIN>-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        MESSAGE ID LS_RETURN-ID TYPE 'S'  NUMBER LS_RETURN-NUMBER INTO <LS_MAIN>-MESSAGE .
      ENDIF.
    ENDLOOP.

    REFRESH LT_DISP_MESSAGE.
    CLEAR LV_SEQ.
    LOOP AT LT_RETURN INTO LS_RETURN.
      APPEND INITIAL LINE TO LT_DISP_MESSAGE ASSIGNING FIELD-SYMBOL(<LS_DISP_MESSAGE>).
      ADD 1 TO LV_SEQ.
      <LS_DISP_MESSAGE>-MSGSQ = LV_SEQ .
      <LS_DISP_MESSAGE>-MSGID = LS_RETURN-ID.
      <LS_DISP_MESSAGE>-MSGNO = LS_RETURN-NUMBER..
      <LS_DISP_MESSAGE>-MSGTY = LS_RETURN-TYPE.
      <LS_DISP_MESSAGE>-MSGV1 = LS_RETURN-MESSAGE_V1.
      <LS_DISP_MESSAGE>-MSGV2 = LS_RETURN-MESSAGE_V2.
      <LS_DISP_MESSAGE>-MSGV3 = LS_RETURN-MESSAGE_V3.
      <LS_DISP_MESSAGE>-MSGV4 = LS_RETURN-MESSAGE_V4.
      <LS_DISP_MESSAGE>-MSGTX = LS_RETURN-MESSAGE.
    ENDLOOP.

    CALL FUNCTION 'Z_TE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        XMSG = LT_DISP_MESSAGE.

  ELSE. " 성공시
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LOOP AT GT_DISP_400 ASSIGNING <LS_MAIN>.
      <LS_MAIN>-STATUS = ICON_LED_GREEN.
      <LS_MAIN>-PREQ_NO = LS_PRHEADEREXP-PREQ_NO.
      <LS_MAIN>-BNFPO2 = <LS_MAIN>-BNFPO.
      <LS_MAIN>-MESSAGE = TEXT-M11.
    ENDLOOP.

    PERFORM SET_LOG_CREATE_REQ  TABLES PT_DISP
                                       GT_DISP_400
                                USING  GS_REQ_DISP.


    GV_MODE = 'C'.
    MESSAGE S003 DISPLAY LIKE 'S' WITH '구매요청 작업이 성공 되었습니다.'.

  ENDIF.


  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG_CREATE_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&---------------------------------------------------------------------*
FORM SET_LOG_CREATE_REQ  TABLES PT_DISP STRUCTURE GS_DISP
                                PT_MAIN STRUCTURE GS_DISP_400
                         USING  PS_REQ_DISP LIKE GS_REQ_DISP.

  DATA : LS_DISP LIKE GS_DISP,
         LT_DISP LIKE TABLE OF GS_DISP . "전송 ALV 테이블

  DATA : LS_3280 TYPE ZGTPPT3280.
  DATA : LS_3290 TYPE  ZGTPPT3290,
         LT_3290 LIKE TABLE OF ZGTPPT3290 . "전송 ALV 테이블
  DATA : LV_SEQ_MAX    LIKE ZGTPPT3290-SEQ.

  LOOP AT PT_MAIN INTO DATA(PS_MAIN).
    LS_3280-BANFN = PS_MAIN-PREQ_NO. "BAPI 성공 Return한 구매요청 번호
    LS_3280-BNFPO = PS_MAIN-BNFPO2 + 0. "BAPI 성공 Return한 구매요청 품목번호
    LS_3280-BADAT = SY-DATUM.
    LS_3280-LIFNR = PS_REQ_DISP-FLIEF. "공급업체
    LS_3280-RESWK = PS_REQ_DISP-RESWK. "공급 플랜트
    LS_3280-MATNR = PS_MAIN-MATNR. "구매요청 생성화면 ALV에서 입력한 품목별 자재코드
    LS_3280-WERKS = PS_MAIN-WERKS. "구매요청 생성화면 ALV에서 입력한 품목별 플랜트
    LS_3280-LGORT = PS_MAIN-LGORT. "구매요청 생성화면 ALV에서 입력한 품목별 저장위치
    LS_3280-MENGE = PS_MAIN-MENGE. "구매요청 생성화면 ALV에서 입력한 품목별 구매요청수량
    LS_3280-MEINS = PS_MAIN-MEINS. "구매요청 생성화면 ALV에서 입력한 품목별 구매요청단위
    LS_3280-LFDAT = PS_MAIN-LFDAT. "구매요청 생성화면 ALV에서 입력한 품목별 납품일
    LS_3280-BIGO  = PS_MAIN-BIGO. "구매요청 생성화면 ALV에서 입력한 품목별 기타사항(메모)

    MOVE : SY-UNAME TO LS_3280-CRNAM,
           SY-DATUM TO LS_3280-CRDAT,
           SY-UZEIT TO LS_3280-CRTIM,
           SY-UNAME TO LS_3280-CHNAM,
           SY-DATUM TO LS_3280-CHDAT,
           SY-UZEIT TO LS_3280-CHTIM,
           SY-UNAME TO LS_3280-CHNAM.


    MODIFY ZGTPPT3280 FROM LS_3280.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

  SORT PT_DISP BY CHECK
                  GRPNR
                  VBELN
                  MATNR_F
                  SUL_NO
                  REV_SEQ
                  GONG_CD
                  AUFNR_T
                  MATNR_R.

  DELETE ADJACENT DUPLICATES FROM PT_DISP
                  COMPARING
                  CHECK
                  GRPNR
                  VBELN
                  MATNR_F
                  SUL_NO
                  REV_SEQ
                  GONG_CD
                  AUFNR_T
                  MATNR_R.


  LOOP AT PT_DISP INTO DATA(PS_DISP) WHERE CHECK = 'X'.

    CLEAR : LV_SEQ_MAX.
    IF PT_DISP-MTS_CHK = 'MTS'.
      SELECT SINGLE MAX( SEQ )
       INTO LV_SEQ_MAX
       FROM ZGTPPT3290
       WHERE GRPNR     = PS_DISP-GRPNR
         AND VBELN     = PS_DISP-VBELN
         AND MATNR_F   = PS_DISP-MATNR_F
         AND SUL_NO    = PS_DISP-SUL_NO
         AND REV_SEQ   = PS_DISP-REV_SEQ
         AND GONG_CD   = PS_DISP-GONG_CD
         AND AUFNR     = PS_DISP-AUFNR_T
         AND MATNR     = PS_DISP-MATNR_R.
    ELSE.
      SELECT SINGLE MAX( SEQ )
       INTO LV_SEQ_MAX
       FROM ZGTPPT3290
       WHERE GRPNR     = PS_DISP-GRPNR
         AND VBELN     = PS_DISP-VBELN
         AND MATNR_F   = PS_DISP-MATNR_F
         AND SUL_NO    = PS_DISP-SUL_NO
         AND REV_SEQ   = PS_DISP-REV_SEQ
         AND GONG_CD   = PS_DISP-GONG_CD
*         AND aufnr     = ps_disp-aufnr_t
         AND MATNR     = PS_DISP-MATNR_R.

    ENDIF.

    LV_SEQ_MAX = LV_SEQ_MAX + 1.

    MOVE-CORRESPONDING PS_DISP TO LS_3290.

    READ TABLE PT_MAIN INTO DATA(PS_PRDATA)
                       WITH KEY MATNR = PS_DISP-MATNR_R.

    LS_3290-GRPNR     = PS_DISP-GRPNR.  "Main ALV 화면에서 체크한 조장구성표
    LS_3290-VBELN     = PS_DISP-VBELN.  "Main ALV 화면에서 체크한 판매오더번호
    LS_3290-MATNR_F   = PS_DISP-MATNR_F."Main ALV 화면에서 체크한 제품
    LS_3290-SUL_NO    = PS_DISP-SUL_NO.
    LS_3290-REV_SEQ   = PS_DISP-REV_SEQ.
    LS_3290-GONG_CD   = PS_DISP-GONG_CD. "Main ALV 화면에서 체크한 공정 코드
    IF PS_DISP-MTS_CHK = 'MTS'.
      LS_3290-AUFNR     = PS_DISP-AUFNR_T.
    ENDIF.
    LS_3290-MATNR     = PS_PRDATA-MATNR.    "구매요청 ALV 화면에서 체크한 원자재
    LS_3290-SEQ       = LV_SEQ_MAX.
    LS_3290-ERFMG     = PS_DISP-ERFMG_SO.   "Main ALV 화면에서 체크한 소요량(수주 기준)
    LS_3290-ERFMG_R   = PS_DISP-ERFMG_RE.   "Main ALV 화면에서 체크한 소요량(잔여 기준).
    LS_3290-ERFME     = PS_PRDATA-MEINS. "구매요청 생성화면 ALV에서 입력한 품목별 저장위치
    LS_3290-BADAT     = SY-DATUM.
    LS_3290-BANFN     = PS_PRDATA-PREQ_NO. "BAPI 성공 Return한 구매요청 번호
    LS_3290-BNFPO     = PS_PRDATA-BNFPO2 + 0. "BAPI 성공 Return한 구매요청 품목번호
    LS_3290-MENGE     = PS_PRDATA-MENGE. "구매요청 생성화면 ALV에서 입력한 품목별 구매요청수량
    LS_3290-MEINS     = PS_PRDATA-MEINS. " ???구매요청 생성화면 ALV에서 입력한 품목별 구매요청단위
    LS_3290-LFDAT     = PS_PRDATA-LFDAT. "구매요청 생성화면 ALV에서 입력한 품목별 납품일

    MOVE : SY-UNAME TO LS_3290-CRNAM,
           SY-DATUM TO LS_3290-CRDAT,
           SY-UZEIT TO LS_3290-CRTIM,
           SY-UNAME TO LS_3290-CHNAM,
           SY-DATUM TO LS_3290-CHDAT,
           SY-UZEIT TO LS_3290-CHTIM,
           SY-UNAME TO LS_3290-CHNAM.


    MODIFY ZGTPPT3290 FROM LS_3290.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_3291
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISPL>
*&---------------------------------------------------------------------*
FORM SAVE_LOG_3291  USING   PS_DISP LIKE GS_DISP
                            PV_RESULT.

  DATA : LS_T3291 TYPE ZGTPPT3291,
         LT_T3291 TYPE TABLE OF ZGTPPT3291.
  DATA : LV_SEQ_MAX    LIKE ZGTPPT3291-SEQ.

  SELECT SINGLE MAX( SEQ )
   INTO LV_SEQ_MAX
   FROM ZGTPPT3291
   WHERE GRPNR     = PS_DISP-GRPNR
     AND VBELN     = PS_DISP-VBELN
     AND MATNR_F   = PS_DISP-MATNR_F
     AND GONG_CD   = PS_DISP-GONG_CD
     AND MATNR     = PS_DISP-MATNR_R.

  LS_T3291-GRPNR     = PS_DISP-GRPNR.
  LS_T3291-VBELN     = PS_DISP-VBELN.
  IF PS_DISP-MTS_CHK = 'MTS'.
    LS_T3291-AUFNR     = PS_DISP-AUFNR_T.
  ENDIF.
  LS_T3291-MATNR_F   = PS_DISP-MATNR_F.
  LS_T3291-GONG_CD   = PS_DISP-GONG_CD.
  LS_T3291-MATNR     = PS_DISP-MATNR_R.
  LS_T3291-SEQ       = LV_SEQ_MAX + 1.
  LS_T3291-LOSS      = PS_DISP-AUSCH.
  LS_T3291-CRDAT     = SY-DATUM.
  LS_T3291-CRTIM     = SY-UZEIT.
  LS_T3291-CRNAM     = SY-UNAME.
  LS_T3291-CHDAT     = SY-DATUM.
  LS_T3291-CHTIM     = SY-UZEIT.
  LS_T3291-CHNAM     = SY-UNAME.
  APPEND LS_T3291 TO LT_T3291.

  MODIFY ZGTPPT3291 FROM TABLE LT_T3291.
  IF SY-SUBRC = 0.
    COMMIT WORK.
    PV_RESULT = 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_DEL_REQ  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
*  DATA : LT_RS_INFOR_CHK LIKE TABLE OF GS_RS_INFO.
  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.
  DATA : LV_PR_CHK(1).
  DATA : LV_PR_CHKALL(1).
  DATA : LV_PR_DELCHK(1).

  LV_PR_CHKALL = 'N'.
  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
    LV_PR_CHKALL = 'Y'.
  ENDLOOP.

  IF LV_PR_CHKALL = 'N'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
  ENDIF.
  CHECK LV_PR_CHKALL <> 'N'.


  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.

    LV_PR_CHK = 'Y'.
    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>)
                       INDEX SY-TABIX.
    IF SY-SUBRC = 0.
      IF <LS_DISP>-BANFN IS INITIAL.
        LV_PR_CHK = 'N'.
        "선택한 Line { ALV Line 위치 }에 삭제할 구매요청 번호가 없습니다.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E07
                                           SY-TABIX
                                           TEXT-E08.
        LV_PR_CHK = 'N'.
        EXIT.
      ENDIF.

      IF <LS_DISP>-BANFN = 'N건'.
        LV_PR_CHK = 'N'.
        "선택한 Line { ALV Line 위치 }에 삭제할 구매요청 번호가 없습니다.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E07
                                           SY-TABIX
                                           TEXT-E13.
        LV_PR_CHK = 'N'.
        EXIT.
      ENDIF.


      IF <LS_DISP>-EBELN IS NOT INITIAL.
        LV_PR_CHK = 'N'.
        "선택한 Line { ALV Line 위치 }에 구매오더가 있어 구매요청을 삭제할 수 없습니다.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E07
                                           SY-TABIX
                                           TEXT-E09.
        LV_PR_CHK = 'N'.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK LV_PR_CHK <> 'N'.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매요청이 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.

    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP_DEL>)
                       INDEX SY-TABIX.
    IF SY-SUBRC = 0.
      CLEAR LV_NUMBER.
      REFRESH : LT_RETURN, LT_PRITEM, LT_PRITEMX.

      LV_NUMBER = <LS_DISP_DEL>-BANFN.

      APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = <LS_DISP_DEL>-BNFPO
        IMPORTING
          OUTPUT = <LS_PRITEM>-PREQ_ITEM.
      <LS_PRITEM>-DELETE_IND = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
      <LS_PRITEMX>-PREQ_ITEM = <LS_PRITEM>-PREQ_ITEM.
      <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
      <LS_PRITEMX>-DELETE_IND = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          NUMBER  = LV_NUMBER
*         TESTRUN = ABAP_TRUE " 테스트를 위한 플레그 이관시 삭제예정
        TABLES
          RETURN  = LT_RETURN
          PRITEM  = LT_PRITEM
          PRITEMX = LT_PRITEMX.

      IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ) .
        READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
        <LS_DISP_DEL>-ID = ICON_LED_RED.
        <LS_DISP_DEL>-RTMSG = LS_RETURN-MESSAGE.
      ELSEIF LINE_EXISTS( LT_RETURN[ TYPE = 'A' ] ) .
        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
        <LS_DISP_DEL>-ID = ICON_LED_RED.
        <LS_DISP_DEL>-RTMSG = LS_RETURN-MESSAGE.
      ELSE.
        <LS_DISP_DEL>-ID = ICON_LED_GREEN.
        <LS_DISP_DEL>-RTMSG = TEXT-M10.
      ENDIF.

      IF <LS_DISP_DEL>-ID = ICON_LED_GREEN.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
*   처리결과 로그테이블 저장 처리
        CLEAR : LV_PR_DELCHK.
        PERFORM SET_LOG_3280_PRDEL USING 'D'
                                         <LS_DISP_DEL>
                                         LV_PR_DELCHK.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*   처리결과 로그테이블 저장 처리 없음(현재 성공건만 저장)
*  *      PERFORM SET_LOG_3280_PRDEL USING 'D' LS_CHK.
      ENDIF.
      WAIT UP TO '0.5' SECONDS.


    ENDIF.
  ENDLOOP.

  MESSAGE S003 DISPLAY LIKE 'S' WITH '구매요청이 삭제 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG_3260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> <LS_DISP_DEL>
*&---------------------------------------------------------------------*
FORM SET_LOG_3280_PRDEL  USING    PV_GUPUN
                                  PS_DISP LIKE GS_DISP
                                  PV_PR_DELCHK.

  UPDATE ZGTPPT3280
       SET LOEKZ = 'X',
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_DISP-BANFN
     AND BNFPO = @PS_DISP-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_DELCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_DELCHK = 'F'.
  ENDIF.

  UPDATE ZGTPPT3290
       SET LOEKZ = 'X',
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_DISP-BANFN
     AND BNFPO = @PS_DISP-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_DELCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_DELCHK = 'F'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0220 .

  CREATE OBJECT GO_CONTAIN_0220
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0220
    EXPORTING
      I_PARENT      = GO_CONTAIN_0220
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0220
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0220
                         USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  IF PO_GRID = GO_GRID_0220.

    CLEAR LT_F4.
    LT_F4-FIELDNAME  = 'IDNRK'.
    LT_F4-REGISTER   = 'X'.
    LT_F4-GETBEFORE  = 'X'.
    LT_F4-CHNGEAFTER = SPACE.
    INSERT TABLE LT_F4.
*& ONF4 이벤트 등록
    CALL METHOD PO_GRID->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = LT_F4[].
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
    CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDIF.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.
*// Event Handler ##


  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR PO_GRID.

  IF PO_GRID = GO_GRID_0220.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4 FOR PO_GRID.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0220 .

  CLEAR GS_LAYOUT_0220.
*  gs_layout_0220-cwidth_opt = abap_true.
  GS_LAYOUT_0220-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0220-SEL_MODE   = 'A'.
  GS_LAYOUT_0220-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0220 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0220[]
    TABLES
      IT_DATA         = GT_POPUP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0220 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "조장표번호
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "공정
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "오더번호
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "품목번호
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'NWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F47. "오더 총수량
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
*      WHEN 'GONG_CD'.
*        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f21. "공정코드
*        <ls_fcat>-qfieldname = 'ERFME'.
*        <ls_fcat>-just = 'R'.
*        <ls_fcat>-col_opt = abap_true.
      WHEN 'WEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "입고수량
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "입고단위
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN OTHERS .
        <LS_FCAT>-NO_OUT = 'X'.


    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0220 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0220
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0220_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0220_DISPLAY .
  CALL METHOD GO_GRID_0220->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0220
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0220
    CHANGING
      IT_OUTTAB            = GT_POPUP
      IT_FIELDCATALOG      = GT_FIELDCAT_0220.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0220->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0220->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOSS_3291
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISPL>
*&      --> GS_DISP_AUSCH
*&---------------------------------------------------------------------*
FORM SAVE_LOSS_3291  USING  PS_DISP LIKE GS_DISP
                            PS_AUSCH
                            PV_RESULT.

  DATA : LS_T3291 TYPE ZGTPPT3291,
         LT_T3291 TYPE TABLE OF ZGTPPT3291.
  DATA : LV_SEQ_MAX    LIKE ZGTPPT3291-SEQ.

  SELECT SINGLE MAX( SEQ )
   INTO LV_SEQ_MAX
   FROM ZGTPPT3291
   WHERE GRPNR     = PS_DISP-GRPNR
     AND VBELN     = PS_DISP-VBELN
     AND MATNR_F   = PS_DISP-MATNR_F
     AND GONG_CD   = PS_DISP-GONG_CD
     AND MATNR     = PS_DISP-MATNR_R.

  LS_T3291-GRPNR     = PS_DISP-GRPNR.
  LS_T3291-VBELN     = PS_DISP-VBELN.
  IF PS_DISP-MTS_CHK = 'MTS'.
    LS_T3291-AUFNR     = PS_DISP-AUFNR_T.
  ENDIF.
  LS_T3291-MATNR_F   = PS_DISP-MATNR_F.
  LS_T3291-GONG_CD   = PS_DISP-GONG_CD.
  LS_T3291-MATNR     = PS_DISP-MATNR_R.
  LS_T3291-SEQ       = LV_SEQ_MAX + 1.
  LS_T3291-LOSS      = PS_AUSCH.
  LS_T3291-CRDAT     = SY-DATUM.
  LS_T3291-CRTIM     = SY-UZEIT.
  LS_T3291-CRNAM     = SY-UNAME.
  LS_T3291-CHDAT     = SY-DATUM.
  LS_T3291-CHTIM     = SY-UZEIT.
  LS_T3291-CHNAM     = SY-UNAME.
  APPEND LS_T3291 TO LT_T3291.

  MODIFY ZGTPPT3291 FROM TABLE LT_T3291.
  IF SY-SUBRC = 0.
    COMMIT WORK.
    PV_RESULT = 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SENDER
*&      --> P_ROW_INDEX
*&---------------------------------------------------------------------*
FORM SET_SELECTED_ROWS  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                 P_INDEX  TYPE LVC_INDEX.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

  DATA: LS_INDEX_ROWS TYPE LVC_S_ROW,
        LS_ROW_NO     TYPE LVC_S_ROID.

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  LS_INDEX_ROWS-INDEX = P_INDEX.
  APPEND LS_INDEX_ROWS TO LT_INDEX_ROWS.

  LS_ROW_NO-ROW_ID = P_INDEX.
  APPEND LS_ROW_NO TO LT_ROW_NO.

  P_SENDER->SET_SELECTED_ROWS(
    EXPORTING
      IT_INDEX_ROWS = LT_INDEX_ROWS
      IT_ROW_NO     = LT_ROW_NO ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_BOX .

*  DATA : lt_celltab TYPE lvc_t_styl.
*  DATA : ls_celltab TYPE lvc_s_styl.
*  DATA : lt_cellcol TYPE lvc_t_scol.
*  DATA : ls_cellcol TYPE lvc_s_scol.
*  DATA : lv_fieldname TYPE fieldname.
*  DATA : lv_date TYPE sy-datum.
*  FIELD-SYMBOLS <lv_field> TYPE any.
*  FIELD-SYMBOLS <lt_celltab> TYPE any.
*
*  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<ls_data>) WHERE check = 'X' .
*    REFRESH lt_cellcol.
*    LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fact>).
*      CASE <ls_fact>-fieldname.
*        WHEN 'GRPNR' OR 'VBELN' OR 'KUNNR' OR
*             'NAME1' OR 'EDATU' OR 'MATNR_F' OR
*             'SUL_NO' OR 'REV_SEQ' OR
*             'KV' OR 'SQ'
*             .
*
*        WHEN OTHERS .
*          CLEAR ls_celltab.
*          CLEAR lv_fieldname.
*          lv_fieldname = <ls_fact>-fieldname.
*          ls_cellcol-fname = lv_fieldname.
*          ls_cellcol-color-col = '3'.
*          ls_cellcol-color-int = '0'.
*          ls_cellcol-color-inv = '0'.
*          ls_cellcol-nokeycol  = ' '.
*          INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*      ENDCASE.
*    ENDLOOP.
*
*    MOVE-CORRESPONDING lt_cellcol TO <ls_data>-cellScol.
*
*  ENDLOOP.
*
*  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<ls_data2>) WHERE check = '' .
*    CLEAR : <ls_data>-cellScol.
*
*
*  ENDLOOP.


  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MTS_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MTS_CHECK .
  CLEAR : GV_MTS_CHK.
  IF CB_MTSOR = 'X'.
    IF S_GSTRP-LOW IS INITIAL.
      GV_MTS_CHK = 'X'.
      MESSAGE S003 WITH TEXT-E11 DISPLAY LIKE 'E'. "MTS 오더 포함 조회시 오더시작일자를 입력해주세요
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_GRPNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_GRPNR_LOW
*&---------------------------------------------------------------------*
FORM SET_F4_GRPNR  USING PV_TITLE
                         PV_RETFIELD
                   CHANGING PV_CODE.

  DATA : LS_ZGTPPT2010 TYPE ZGTPPT2010,
         LT_ZGTPPT2010 TYPE TABLE OF ZGTPPT2010.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @LT_ZGTPPT2010
    FROM ZGTPPT2010.
  SORT LT_ZGTPPT2010 BY GRPNR..
  DELETE ADJACENT DUPLICATES FROM LT_ZGTPPT2010 COMPARING GRPNR.


  DATA : BEGIN OF LS_CODE,
           GRPNR TYPE ZGTPPT2010-GRPNR,
         END OF LS_CODE,
         LT_CODE LIKE TABLE OF LS_CODE.

  "Get Data
  LT_CODE[] = CORRESPONDING #( LT_ZGTPPT2010[] MAPPING GRPNR = GRPNR ).
  SORT LT_CODE BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CODE COMPARING GRPNR.

  "Call F4 Help
  PERFORM F4IF_INT_TABLE_VALUE_REQUEST TABLES   LT_CODE
                                       USING    PV_RETFIELD
                                                PV_TITLE
                                                SPACE
                                       CHANGING PV_CODE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_INT_TABLE_VALUE_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CODE
*&      --> PV_RETFIELD
*&      --> PV_TITLE
*&      --> SPACE
*&      <-- PV_CODE
*&---------------------------------------------------------------------*
FORM F4IF_INT_TABLE_VALUE_REQUEST  TABLES    PT_DATA
                                   USING    PV_RETFIELD
                                            PV_TITLE
                                            PV_DISPLAY
                                   CHANGING PV_CODE.
  DATA: LT_RETTAB TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = PV_RETFIELD          " Return Field
      VALUE_ORG       = ZGTSD_S
      WINDOW_TITLE    = PV_TITLE
      DISPLAY         = PV_DISPLAY
    TABLES
      VALUE_TAB       = PT_DATA[]            " Value
      RETURN_TAB      = LT_RETTAB            " Return Tab
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_CODE = VALUE #( LT_RETTAB[ 1 ]-FIELDVAL OPTIONAL ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0230 .

  CREATE OBJECT GO_CONTAIN_0230
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAIN_0230'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT GO_GRID_0230
    EXPORTING
      I_PARENT      = GO_CONTAIN_0230
      I_APPL_EVENTS = ABAP_TRUE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0230
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0230
                        USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.


  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  CASE PO_GRID.

    WHEN GO_GRID_0230.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0230 .

  CLEAR GS_LAYOUT_0230.
*  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0230-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0230-NO_ROWMARK   = ABAP_TRUE.
  GS_LAYOUT_0230-SEL_MODE   = 'D'.
  GS_LAYOUT_0230-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0230-CTAB_FNAME = 'CELLSCOL'.    "셀색상
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0230 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_T3290P'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0230[]
    TABLES
      IT_DATA         = GT_POPUP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0230 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-COLTEXT = TEXT-F01. "상태
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT  = ' '.
        <LS_FCAT>-EDIT    = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-CHECKBOX  = 'X'.
        <LS_FCAT>-KEY     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'BANFN'.
        <LS_FCAT>-COLTEXT = TEXT-F32.  "PR 번호
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'BNFPO'.
        <LS_FCAT>-COLTEXT = TEXT-F33.   "PR Item 번호
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'BADAT'.
        <LS_FCAT>-COLTEXT = TEXT-F31.   "구매요청일
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MATNR'.
        <LS_FCAT>-COLTEXT = TEXT-F24.  " 자재코드
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MAKTX_R'.
        <LS_FCAT>-COLTEXT = TEXT-F23.   " 자재내역
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'MENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F34.  "PR 수량
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MEINS'.
        <LS_FCAT>-COLTEXT = TEXT-F35.  "단위
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'LFDAT'.
        <LS_FCAT>-COLTEXT = TEXT-F36.   " 납기일
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.


      WHEN 'BIGO'.
        <LS_FCAT>-COLTEXT = TEXT-F42.   " 기타사항(메모)
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'EBELN'.
        <LS_FCAT>-COLTEXT = TEXT-F37.  " PO번호
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'EBELP'.
        <LS_FCAT>-COLTEXT = TEXT-F38.   " PO Item 번호
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-F4AVAILABL = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'WEMNG2'.
        <LS_FCAT>-COLTEXT = TEXT-F39.   " 입고 수량
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MEINS2'.
        <LS_FCAT>-COLTEXT = TEXT-F46.  "입고단위
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '5'.


      WHEN 'STATUS'.
        <LS_FCAT>-COLTEXT = TEXT-F44.   " T상대
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.

      WHEN 'MESSAGE'.
        <LS_FCAT>-COLTEXT = TEXT-F45.   " 메시지
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '20'.



      WHEN OTHERS .
        <LS_FCAT>-NO_OUT = 'X'.


    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0230 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR ls_celltab.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    ls_celltab-fieldname = lv_fieldname.
    ls_celltab-style = CONV #( &2 ).
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_T3290P ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLCOL.
    LOOP AT GT_FIELDCAT_0230 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
      CASE <LS_FACT>-FIELDNAME.
        WHEN 'EBELN' OR 'EBELP' OR 'WEMNG2' OR 'MEINS2'.
          .
          CLEAR LS_CELLTAB.
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = <LS_FACT>-FIELDNAME.
          LS_CELLCOL-FNAME = LV_FIELDNAME.
          LS_CELLCOL-COLOR-COL = '4'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN 'STATUS' OR 'MESSAGE'.
          CLEAR LS_CELLTAB.
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = <LS_FACT>-FIELDNAME.
          LS_CELLCOL-FNAME = LV_FIELDNAME.
          LS_CELLCOL-COLOR-COL = '5'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN OTHERS." 'PO_YN'.



      ENDCASE.
    ENDLOOP.

    MOVE-CORRESPONDING LT_CELLCOL TO <LS_MAIN>-CELLSCOL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0230 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0230
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0230_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0230_DISPLAY .
  CALL METHOD GO_GRID_0230->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0230
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0230
    CHANGING
      IT_OUTTAB            = GT_T3290P
      IT_FIELDCATALOG      = GT_FIELDCAT_0230.

  GO_GRID_0230->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0230->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0230->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_change_req_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DISP
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CHANGE_REQ_0230  TABLES  PT_DISP STRUCTURE GS_DISP
                           USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                           .

  DATA : LV_ERR.
  DATA : LS_PRHEADER TYPE BAPIMEREQHEADER.
  DATA : LS_PRHEADERX TYPE BAPIMEREQHEADERX.
  DATA : LS_PRHEADEREXP TYPE BAPIMEREQHEADER.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE  TABLE OF BAPIMEREQITEMX.
  DATA : LT_PRITEMTEXT   TYPE  TABLE OF BAPIMEREQITEMTEXT.
  DATA : LT_DISP_MESSAGE TYPE TABLE OF ZTESMESSAGE.
  DATA : LV_SEQ(6) TYPE N.
  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LV_PR_UPCHK(1).
*  PERFORM CHECK_REQ CHANGING LV_ERR. "구매요청 생성전 점검
*
*  IF LV_ERR EQ ABAP_TRUE.
*    RETURN.
*  ENDIF.
*
  CHECK GT_T3290P[] IS NOT INITIAL.


*  if GS_REQ_DISP-FLIEF is INITIAL.
*    MESSAGE s003 DISPLAY LIKE 'E' WITH '공급업체를 입력하세요.'.
*    RETURN.
*  ENDIF.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '해당 정보로 구매요청이 생성됩니다. 진행하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

* Bapi 정보 구성

  LOOP AT GT_T3290P INTO GS_T3290P WHERE CHECK = 'X'.

    READ TABLE GT_T3290P ASSIGNING FIELD-SYMBOL(<LS_DISP_CHG>)
                       INDEX SY-TABIX.
    IF SY-SUBRC = 0.
      CLEAR LV_NUMBER.
      REFRESH : LT_RETURN, LT_PRITEM, LT_PRITEMX.
      LV_NUMBER = <LS_DISP_CHG>-BANFN.

      APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
      <LS_PRITEM>-PREQ_ITEM  = <LS_DISP_CHG>-BNFPO. "ALV의 품목번호 5자리
      <LS_PRITEM>-QUANTITY   = <LS_DISP_CHG>-MENGE. "ALV의 수량
      <LS_PRITEM>-UNIT       = <LS_DISP_CHG>-MEINS.     "ALV의 단위
      <LS_PRITEM>-DELIV_DATE = <LS_DISP_CHG>-LFDAT."화면의 납품일

      APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
      <LS_PRITEMX>-PREQ_ITEM  = <LS_DISP_CHG>-BNFPO. "ALV의 품목번호 5자리
      <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
      <LS_PRITEMX>-QUANTITY   = ABAP_TRUE.
      <LS_PRITEMX>-UNIT       = ABAP_TRUE.
      <LS_PRITEMX>-DELIV_DATE = ABAP_TRUE.

      "LT_PRITEMTEXT
      APPEND INITIAL LINE TO LT_PRITEMTEXT ASSIGNING FIELD-SYMBOL(<LS_PRITEMTEXT>).
      <LS_PRITEMTEXT>-PREQ_ITEM = <LS_DISP_CHG>-BNFPO. "ALV의 품목번호 5자리
      <LS_PRITEMTEXT>-TEXT_LINE = <LS_DISP_CHG>-BIGO. "ALV에서 품목별로 입력한 "기타사항(메모)"
*     Bapi 실행
      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          NUMBER     = LV_NUMBER
        TABLES
          RETURN     = LT_RETURN
          PRITEM     = LT_PRITEM
          PRITEMX    = LT_PRITEMX
          PRITEMTEXT = LT_PRITEMTEXT.

      READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0. " 에러건 존재시


        <LS_DISP_CHG>-STATUS = ICON_LED_RED.
        IF LS_RETURN-MESSAGE IS NOT INITIAL.
          <LS_DISP_CHG>-MESSAGE = LS_RETURN-MESSAGE.
        ELSE.
          MESSAGE ID LS_RETURN-ID TYPE 'S'  NUMBER LS_RETURN-NUMBER
                                       INTO <LS_DISP_CHG>-MESSAGE .
        ENDIF.


        REFRESH LT_DISP_MESSAGE.
        CLEAR LV_SEQ.
        LOOP AT LT_RETURN INTO LS_RETURN.
          APPEND INITIAL LINE TO LT_DISP_MESSAGE
                      ASSIGNING FIELD-SYMBOL(<LS_DISP_MESSAGE>).
          ADD 1 TO LV_SEQ.
          <LS_DISP_MESSAGE>-MSGSQ = LV_SEQ .
          <LS_DISP_MESSAGE>-MSGID = LS_RETURN-ID.
          <LS_DISP_MESSAGE>-MSGNO = LS_RETURN-NUMBER..
          <LS_DISP_MESSAGE>-MSGTY = LS_RETURN-TYPE.
          <LS_DISP_MESSAGE>-MSGV1 = LS_RETURN-MESSAGE_V1.
          <LS_DISP_MESSAGE>-MSGV2 = LS_RETURN-MESSAGE_V2.
          <LS_DISP_MESSAGE>-MSGV3 = LS_RETURN-MESSAGE_V3.
          <LS_DISP_MESSAGE>-MSGV4 = LS_RETURN-MESSAGE_V4.
          <LS_DISP_MESSAGE>-MSGTX = LS_RETURN-MESSAGE.
        ENDLOOP.

        CALL FUNCTION 'Z_TE_POPUP_TO_ERROR_MESSAGE'
          TABLES
            XMSG = LT_DISP_MESSAGE.

      ELSE. " 성공시
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.


        <LS_DISP_CHG>-STATUS = ICON_LED_GREEN.
        <LS_DISP_CHG>-MESSAGE = TEXT-M12. "구매요청 변경 되었습니다.

        PERFORM SET_LOG_CREATE_REQ_230  TABLES PT_DISP
                                    USING <LS_DISP_CHG>
                                         LV_PR_UPCHK.

        GV_MODE = 'C'.
        MESSAGE S003 DISPLAY LIKE 'S' WITH '구매요청 작업이 성공 되었습니다.'.

      ENDIF.


    ENDIF.
  ENDLOOP.



  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_log_create_req_230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DISP
*&      --> <LS_DISP_CHG>
*&      --> GS_REQ_DISP
*&---------------------------------------------------------------------*
FORM SET_LOG_CREATE_REQ_230  TABLES PT_DISP STRUCTURE GS_DISP
                             USING  PS_MAIN LIKE GS_T3290P
                                    PV_PR_UPCHK .

  UPDATE ZGTPPT3280
      SET MENGE  = @PS_MAIN-MENGE,
           MEINS = @PS_MAIN-MEINS,
           LFDAT = @PS_MAIN-LFDAT,
           BIGO  = @PS_MAIN-BIGO,
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_MAIN-BANFN
     AND BNFPO = @PS_MAIN-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_UPCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_UPCHK = 'F'.
  ENDIF.

  UPDATE ZGTPPT3290
      SET MENGE = @PS_MAIN-MENGE,
           MEINS = @PS_MAIN-MEINS,
           LFDAT = @PS_MAIN-LFDAT,
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_MAIN-BANFN
     AND BNFPO = @PS_MAIN-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_UPCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_UPCHK = 'F'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_del_req_230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_DEL_REQ_230  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
*  DATA : LT_RS_INFOR_CHK LIKE TABLE OF GS_RS_INFO.
  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.
  DATA : LV_PR_CHK(1).
  DATA : LV_PR_DELCHK(1).


  LOOP AT GT_T3290P INTO GS_T3290P WHERE CHECK = 'X'.

    LV_PR_CHK = 'Y'.
    READ TABLE GT_T3290P ASSIGNING FIELD-SYMBOL(<LS_T3290P>)
                       INDEX SY-TABIX.
    IF SY-SUBRC = 0.

      IF <LS_T3290P>-EBELN IS NOT INITIAL.
        LV_PR_CHK = 'N'.
        "선택한 Line { ALV Line 위치 }에 구매오더가 있어 구매요청을 삭제할 수 없습니다.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E07
                                           SY-TABIX
                                           TEXT-E09.
        LV_PR_CHK = 'N'.
        EXIT.
      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK LV_PR_CHK <> 'N'.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매요청이 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_T3290P INTO GS_T3290P WHERE CHECK = 'X'.

    READ TABLE GT_T3290P ASSIGNING FIELD-SYMBOL(<LS_DISP_DEL>)
                       INDEX SY-TABIX.
    IF SY-SUBRC = 0.
      CLEAR LV_NUMBER.
      REFRESH : LT_RETURN, LT_PRITEM, LT_PRITEMX.

      LV_NUMBER = <LS_DISP_DEL>-BANFN.

      APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = <LS_DISP_DEL>-BNFPO
        IMPORTING
          OUTPUT = <LS_PRITEM>-PREQ_ITEM.
      <LS_PRITEM>-DELETE_IND = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
      <LS_PRITEMX>-PREQ_ITEM = <LS_PRITEM>-PREQ_ITEM.
      <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
      <LS_PRITEMX>-DELETE_IND = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          NUMBER  = LV_NUMBER
*         TESTRUN = ABAP_TRUE " 테스트를 위한 플레그 이관시 삭제예정
        TABLES
          RETURN  = LT_RETURN
          PRITEM  = LT_PRITEM
          PRITEMX = LT_PRITEMX.

      IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ) .
        READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
        <LS_DISP_DEL>-STATUS = ICON_LED_RED.
        <LS_DISP_DEL>-MESSAGE = LS_RETURN-MESSAGE.
      ELSEIF LINE_EXISTS( LT_RETURN[ TYPE = 'A' ] ) .
        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
        <LS_DISP_DEL>-STATUS = ICON_LED_RED.
        <LS_DISP_DEL>-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        READ TABLE LT_RETURN INTO DATA(LS_RETURNS) INDEX 1.
        <LS_DISP_DEL>-STATUS = ICON_LED_GREEN.
        <LS_DISP_DEL>-MESSAGE = LS_RETURNS-MESSAGE.
      ENDIF.

      IF <LS_DISP_DEL>-STATUS = ICON_LED_GREEN.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
*   처리결과 로그테이블 저장 처리
        CLEAR : LV_PR_DELCHK.

        PERFORM SET_LOG_3280_PRDEL_230 USING 'D'
                                         <LS_DISP_DEL>
                                         LV_PR_DELCHK.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*   처리결과 로그테이블 저장 처리 없음(현재 성공건만 저장)
*  *      PERFORM SET_LOG_3280_PRDEL USING 'D' LS_CHK.
      ENDIF.
      WAIT UP TO '0.5' SECONDS.


    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING PO_SENDER.

  MESSAGE S003 DISPLAY LIKE 'S' WITH '구매요청이 삭제 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_log_3280_prdel_230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> <LS_DISP_DEL>
*&      --> LV_PR_DELCHK
*&---------------------------------------------------------------------*
FORM SET_LOG_3280_PRDEL_230  USING    PV_GUPUN
                                  PS_DISP LIKE GS_T3290P
                                  PV_PR_DELCHK.

  UPDATE ZGTPPT3280
       SET LOEKZ = 'X',
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_DISP-BANFN
     AND BNFPO = @PS_DISP-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_DELCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_DELCHK = 'F'.
  ENDIF.

  UPDATE ZGTPPT3290
       SET LOEKZ = 'X',
           CHDAT = @SY-DATUM,
           CHTIM = @SY-UZEIT,
           CHNAM = @SY-UNAME
  WHERE BANFN = @PS_DISP-BANFN
     AND BNFPO = @PS_DISP-BNFPO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    PV_PR_DELCHK = 'S'.
  ELSE.
    ROLLBACK WORK.
    PV_PR_DELCHK = 'F'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_MATNR INPUT.

  DATA : BEGIN OF LT_MATNR OCCURS 0,
           MATNR   LIKE MARC-MATNR,
           MAKTX   LIKE MAKT-MAKTX,
           MATKL   LIKE MARA-MATKL,
           WGBEZ60 LIKE T023T-WGBEZ60,
         END OF LT_MATNR.
  DATA : LT_SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  REFRESH : GT_RTNTAB, GT_DSELC.
  CLEAR : GT_RTNTAB, GT_DSELC.

  GT_DSELC-FLDNAME = 'F0001'.
  GT_DSELC-DYFLDNAME = 'MATNR'.
  APPEND GT_DSELC.

  GT_DSELC-FLDNAME = 'F0002'.
  GT_DSELC-DYFLDNAME = 'MAKTX'.
  APPEND GT_DSELC.

  SELECT A~MATNR, B~MAKTX, C~MATKL, D~WGBEZ60
      INTO CORRESPONDING FIELDS OF TABLE @LT_MATNR
      FROM MARC AS A INNER JOIN MAKT AS B
          ON   A~MATNR EQ B~MATNR
          AND A~WERKS EQ @P_WERKS
          AND B~SPRAS EQ @SY-LANGU
          INNER JOIN MARA AS C
          ON  A~MATNR EQ C~MATNR
          INNER JOIN T023T AS D
          ON   D~SPRAS EQ @SY-LANGU
          AND C~MATKL EQ D~MATKL
          WHERE C~MEINS IN @GR_MEINS
               AND C~MATKL IN @GR_MATKL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATNR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-029 "자재 선택
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_MATNR
      RETURN_TAB      = GT_RTNTAB
      DYNPFLD_MAPPING = GT_DSELC
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CLEAR GT_RTNTAB.
  READ TABLE GT_RTNTAB WITH KEY RETFIELD = 'MATNR'.
  IF SY-SUBRC = 0.
    GV_MATNR = GT_RTNTAB-FIELDVAL.
  ENDIF.

  CLEAR GT_RTNTAB.
  READ TABLE GT_RTNTAB WITH KEY RETFIELD = 'MAKTX'.
  IF SY-SUBRC = 0.
    GV_MAKTX = GT_RTNTAB-FIELDVAL.
  ENDIF.
* 해당 BOM의 출고 저장위치 추출
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GV_MATNR
    IMPORTING
      OUTPUT = GV_MATNR.
  SELECT SINGLE A~LGORT INTO @GV_LGORT
                  FROM STPO AS A INNER JOIN MAST AS B
                      ON A~STLNR = B~STLNR
                      WHERE A~IDNRK EQ @GV_MATNR
                           AND A~LGORT <> @SPACE
                           AND B~WERKS EQ @P_WERKS
                           AND B~MATNR IN @GR_MATNR
                           AND B~STLAN EQ '1'. "양산 BOM
* BOM의 출고 저장위치 추출실패시, 기존 2) MARC~LGPRO 추출
  IF GV_LGORT IS INITIAL.

    SELECT SINGLE LGPRO INTO @GV_LGORT
                                     FROM MARC
                                     WHERE WERKS EQ @P_WERKS
                                          AND MATNR EQ @GV_MATNR.

  ENDIF.

  SELECT SINGLE LGOBE INTO @GV_LGOBE FROM T001L WHERE WERKS EQ @P_WERKS
                                                                                       AND LGORT EQ @GV_LGORT.
* 아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = GV_MATNR
    IMPORTING
      OUTPUT = GV_MATNR.
  LT_SCR_FIELDS-FIELDNAME  = 'GV_MATNR'.
  LT_SCR_FIELDS-FIELDVALUE = GV_MATNR.
  APPEND LT_SCR_FIELDS.

  LT_SCR_FIELDS-FIELDNAME  = 'GV_MAKTX'.
  LT_SCR_FIELDS-FIELDVALUE = GV_MAKTX.
  APPEND LT_SCR_FIELDS.

  LT_SCR_FIELDS-FIELDNAME  = 'GV_LGORT'.
  LT_SCR_FIELDS-FIELDVALUE = GV_LGORT.
  APPEND LT_SCR_FIELDS.

  LT_SCR_FIELDS-FIELDNAME  = 'GV_LGOBE'.
  LT_SCR_FIELDS-FIELDVALUE = GV_LGOBE.
  APPEND LT_SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form change_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_MATNR .

  DATA : LV_WEBLNR   LIKE AFFW-WEBLNR,
         LV_SEQ_MAX  LIKE ZGTPPT3292-SEQ,
         LV_MATNR_O  LIKE ZGTPPT3292-MATNR_TO,
         LV_MATNR_N  LIKE ZGTPPT3292-MATNR_TO,
         LV_CHECK(1),
         LV_TEXT(70).

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLS TYPE LVC_T_CENO.

  DATA : LS_DISP  LIKE GS_DISP,
         LS_T3292 TYPE ZGTPPT3292,
         LT_T3292 TYPE TABLE OF ZGTPPT3292.
  DATA : LS_DISP2 LIKE GS_DISP,
         LT_DISP2 LIKE TABLE OF GS_DISP . "전송 ALV 테이블
  CLEAR  : GT_ROW_NO, GT_ROW_NO[], GV_MANDT, GV_ANSWER.

  LV_CHECK = 'N'.
  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
    LV_CHECK = 'Y'.
  ENDLOOP.
* 선택 라인 없으면 오류 메시지 출력
  IF LV_CHECK = 'N'.
    MESSAGE S000 WITH TEXT-M21 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK LV_CHECK = 'Y'.

* 팝업 출력 이전 몇 가지 체크
  CLEAR : GV_ERROR, GS_MEINS, GT_MEINS, GR_MEINS, GR_MEINS[],
          GS_MATKL, GT_MATKL, GR_MATKL, GR_MATKL[], GR_MATNR,
          GR_MATNR[].

  " 대체자재 코드 추출
***  SELECT *
***    INTO CORRESPONDING FIELDS OF TABLE GT_T3292_C
***    FROM ZGTPPT3292
***    FOR ALL ENTRIES IN GT_DISP
***   WHERE GRPNR = GT_DISP-GRPNR
***     AND VBELN = GT_DISP-VBELN+0(10)
***     AND AUFNR = GT_DISP-AUFNR_T
***     AND MATNR_F = GT_DISP-MATNR_F
***     AND GONG_CD = GT_DISP-GONG_CD
***     AND MATNR_ORIGIN = GT_DISP-MATNR_R.
***
***  SORT GT_T3292_C BY GRPNR VBELN AUFNR
***                     MATNR_F GONG_CD MATNR_ORIGIN
***                     SEQ DESCENDING.
  CLEAR : GV_MATNR, GV_MAKTX, GV_LGORT, GV_LGOBE, GV_MEINS.
  CALL SCREEN 0300 STARTING AT 75 5.



*일괄 변경하는 데 문제 없으면 AFFW 업데이트 수행
  CLEAR : LT_DISP2[].

  LT_DISP2[] = GT_DISP[].

  CLEAR : LT_DISP2[].
  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPL2>)
                           WHERE CHECK = 'X'.
    MOVE-CORRESPONDING <LS_DISPL2> TO LS_DISP2.
    APPEND LS_DISP2 TO LT_DISP2.
  ENDLOOP.


  SORT LT_DISP2 BY CHECK
                  GRPNR
                  VBELN
                  AUFNR_T
                  MATNR_F
                  GONG_CD
                  MATNR_R.

  DELETE ADJACENT DUPLICATES FROM LT_DISP2
                  COMPARING
                  CHECK
                  GRPNR
                  VBELN
                  AUFNR_T
                  MATNR_F
                  GONG_CD
                  MATNR_R.


  IF GV_ANSWER = 'J'.
    LOOP AT LT_DISP2 ASSIGNING FIELD-SYMBOL(<LS_DISP>).
*                              WHERE CHECK = 'X'.

      " 대체자재 코드 추출
      CLEAR : LV_SEQ_MAX.
      IF <LS_DISP>-MTS_CHK = 'MTS'.
        SELECT MAX( SEQ )
          INTO LV_SEQ_MAX
          FROM ZGTPPT3292
         WHERE GRPNR = <LS_DISP>-GRPNR
           AND VBELN = <LS_DISP>-VBELN+0(10)
           AND AUFNR = <LS_DISP>-AUFNR_T
           AND MATNR_F = <LS_DISP>-MATNR_F
           AND GONG_CD = <LS_DISP>-GONG_CD
           AND MATNR_TO = <LS_DISP>-MATNR_R.
      ELSE.
        SELECT MAX( SEQ )
          INTO LV_SEQ_MAX
          FROM ZGTPPT3292
         WHERE GRPNR = <LS_DISP>-GRPNR
           AND VBELN = <LS_DISP>-VBELN+0(10)
*             AND AUFNR = <LS_DISP>-AUFNR_T
           AND MATNR_F = <LS_DISP>-MATNR_F
           AND GONG_CD = <LS_DISP>-GONG_CD
           AND MATNR_TO = <LS_DISP>-MATNR_R.

      ENDIF.

      IF LV_SEQ_MAX IS INITIAL.
        LV_SEQ_MAX = 1.
      ELSE.
        LV_SEQ_MAX = LV_SEQ_MAX + 1.
      ENDIF.

      LS_T3292-GRPNR           = <LS_DISP>-GRPNR.
      LS_T3292-VBELN           = <LS_DISP>-VBELN.
      IF <LS_DISP>-MTS_CHK = 'MTS'.
        LS_T3292-AUFNR           = <LS_DISP>-AUFNR_T.
      ENDIF.
      LS_T3292-MATNR_F         = <LS_DISP>-MATNR_F.
      LS_T3292-GONG_CD         = <LS_DISP>-GONG_CD.
      LS_T3292-SEQ             = LV_SEQ_MAX.

      LS_T3292-MATNR_ORIGIN    = <LS_DISP>-MATNR_R.
      LS_T3292-MATNR_FR        = <LS_DISP>-MATNR_R.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT  = GV_MATNR
        IMPORTING
          OUTPUT = GV_MATNR.
      LS_T3292-MATNR_TO        = GV_MATNR.
      LS_T3292-LOSS            = <LS_DISP>-AUSCH.

      MOVE : SY-DATUM TO LS_T3292-CRDAT,
             SY-UZEIT TO LS_T3292-CRTIM,
             SY-UNAME TO LS_T3292-CRNAM,
             SY-DATUM TO LS_T3292-CHDAT,
             SY-UZEIT TO LS_T3292-CHTIM,
             SY-UNAME TO LS_T3292-CHNAM.

      MODIFY ZGTPPT3292 FROM LS_T3292.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.


    ENDLOOP.

    LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
      GS_DISP-MATNR_R = GV_MATNR.
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0260 .

  CREATE OBJECT GO_CONTAIN_0260
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0260
    EXPORTING
      I_PARENT      = GO_CONTAIN_0260
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0260
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0260
                        USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  IF PO_GRID = GO_GRID_0260.

    CLEAR LT_F4.
    LT_F4-FIELDNAME  = 'IDNRK'.
    LT_F4-REGISTER   = 'X'.
    LT_F4-GETBEFORE  = 'X'.
    LT_F4-CHNGEAFTER = SPACE.
    INSERT TABLE LT_F4.
*& ONF4 이벤트 등록
    CALL METHOD PO_GRID->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = LT_F4[].
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
    CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDIF.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.
*// Event Handler ##


  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR PO_GRID.

  IF PO_GRID = GO_GRID_0260.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4 FOR PO_GRID.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0260 .

  CLEAR GS_LAYOUT_0260.
*  gs_layout_0260-cwidth_opt = abap_true.
  GS_LAYOUT_0260-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0260-SEL_MODE   = 'A'.
  GS_LAYOUT_0260-SMALLTITLE = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0260 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP2'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0260[]
    TABLES
      IT_DATA         = GT_POPUP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0260 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "판매오더
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ''.

      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "고객사코드
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.

      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "납선
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.

      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "납품요청일
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.

      WHEN 'MATNR_F'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "제품
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.

      WHEN OTHERS .
        <LS_FCAT>-NO_OUT = 'X'.


    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0260 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0260
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0260_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0260_DISPLAY .
  CALL METHOD GO_GRID_0260->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0260
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0260
    CHANGING
      IT_OUTTAB            = GT_POPUP2
      IT_FIELDCATALOG      = GT_FIELDCAT_0260.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0260->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0260->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0270 .

  CREATE OBJECT GO_CONTAIN_0270
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAIN_0270'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT GO_GRID_0270
    EXPORTING
      I_PARENT      = GO_CONTAIN_0270
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0270
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0270
                      USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  CASE PO_GRID.

    WHEN GO_GRID_0270.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0270 .
  CLEAR GS_LAYOUT_0270.
*  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0270-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0270-NO_ROWMARK   = ABAP_TRUE.
  GS_LAYOUT_0270-SEL_MODE   = 'D'.
  GS_LAYOUT_0270-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0270-CTAB_FNAME = 'CELLSCOL'.    "셀색상
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0270 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_T3292P'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0270[]
    TABLES
      IT_DATA         = GT_POPUP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0270 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-COLTEXT = TEXT-F01. "상태
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT  = 'X'.
*        <ls_fcat>-edit    = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-CHECKBOX  = 'X'.
        <LS_FCAT>-KEY     = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '3'.
      WHEN 'GRPNR'.
        <LS_FCAT>-COLTEXT = TEXT-F48.  "조장구성표
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'VBELN'.
        <LS_FCAT>-COLTEXT = TEXT-F49.   "판매문서번호
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'AUFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F50.   "오더번호
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '10'.
      WHEN 'MATNR_F'.
        <LS_FCAT>-COLTEXT = TEXT-F51.  " 완제품코드
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'GONG_CD'.
        <LS_FCAT>-COLTEXT = TEXT-F52.   " 공정코드
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'L'.
        <LS_FCAT>-OUTPUTLEN  = '5'.
      WHEN 'MATNR_FR'.
        <LS_FCAT>-COLTEXT = TEXT-F53.  "기존자재코드
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'L'.
*        <ls_fcat>-f4availabl = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'MAKTX_FR'.
        <LS_FCAT>-COLTEXT = TEXT-F58.  "기존 자재코드 내역
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'L'.
*        <ls_fcat>-f4availabl = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '20'.

      WHEN 'MATNR_TO'.
        <LS_FCAT>-COLTEXT = TEXT-F54.  "대체자재
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'MAKTX_TO'.
        <LS_FCAT>-COLTEXT = TEXT-F59.  "대체 자재코드 내역
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'L'.
*        <ls_fcat>-f4availabl = 'X'.
        <LS_FCAT>-OUTPUTLEN  = '20'.

      WHEN 'CRDAT'.
        <LS_FCAT>-COLTEXT = TEXT-F55.   " 생성일
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.

      WHEN 'CRTIM'.
        <LS_FCAT>-COLTEXT = TEXT-F56.   " 생성시간
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-edit   = 'X'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '15'.
      WHEN 'CRNAM'.
        <LS_FCAT>-COLTEXT = TEXT-F57.  " 생성자
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-EDIT   = ''.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-OUTPUTLEN  = '10'.



*      WHEN 'STATUS'.
*        <ls_fcat>-coltext = TEXT-f44.   " T상대
*        <ls_fcat>-col_pos = '15'.
*        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-edit   = ''.
*        <ls_fcat>-just      = 'C'.
*        <ls_fcat>-outputlen  = '10'.
*
*      WHEN 'MESSAGE'.
*        <ls_fcat>-coltext = TEXT-f45.   " 메시지
*        <ls_fcat>-col_pos = '16'.
*        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-edit   = ''.
*        <ls_fcat>-just      = 'L'.
*        <ls_fcat>-outputlen  = '20'.



      WHEN OTHERS .
        <LS_FCAT>-NO_OUT = 'X'.


    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0270 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR ls_celltab.
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    ls_celltab-fieldname = lv_fieldname.
    ls_celltab-style = CONV #( &2 ).
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_T3292P ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLCOL.
    LOOP AT GT_FIELDCAT_0270 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
*      CASE <ls_fact>-fieldname.
*        WHEN 'EBELN' OR 'EBELP' OR 'WEMNG2' OR 'MEINS2'.
*          .
*          CLEAR ls_celltab.
*          CLEAR lv_fieldname.
*          lv_fieldname = <ls_fact>-fieldname.
*          ls_cellcol-fname = lv_fieldname.
*          ls_cellcol-color-col = '4'.
*          ls_cellcol-color-int = '0'.
*          ls_cellcol-color-inv = '0'.
*          ls_cellcol-nokeycol  = ' '.
*          INSERT ls_cellcol INTO TABLE lt_cellcol.
*        WHEN 'STATUS' OR 'MESSAGE'.
*          CLEAR ls_celltab.
*          CLEAR lv_fieldname.
*          lv_fieldname = <ls_fact>-fieldname.
*          ls_cellcol-fname = lv_fieldname.
*          ls_cellcol-color-col = '5'.
*          ls_cellcol-color-int = '0'.
*          ls_cellcol-color-inv = '0'.
*          ls_cellcol-nokeycol  = ' '.
*          INSERT ls_cellcol INTO TABLE lt_cellcol.
*        WHEN OTHERS." 'PO_YN'.
*
*
*
*      ENDCASE.
    ENDLOOP.

    MOVE-CORRESPONDING LT_CELLCOL TO <LS_MAIN>-CELLSCOL.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0270 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0270
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0270_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0270_DISPLAY .
  CALL METHOD GO_GRID_0270->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0270
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0270
    CHANGING
      IT_OUTTAB            = GT_T3292P
      IT_FIELDCATALOG      = GT_FIELDCAT_0270.

  GO_GRID_0270->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0270->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0270->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL .

  DATA : LV_TEXT(100).
  DATA : LV_MAIL_CHK(1),
         LV_MAIL_CHK2(1).

  LV_MAIL_CHK2 = 'Y'.
  READ TABLE GT_DISP INTO GS_DISP
                     WITH KEY CHECK = 'X'.
  IF SY-SUBRC <> 0.
    LV_MAIL_CHK2 = 'N'.
    "선택된 라인이 없습니다.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
  ENDIF.
  CHECK LV_MAIL_CHK2 = 'Y'.

  LV_MAIL_CHK = 'Y'.
  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
    IF GS_DISP-BANFN IS INITIAL.
      LV_MAIL_CHK = 'N'.
      "구매요청문서가 없는 Line을 선택했습니다
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E19.
    ENDIF.

  ENDLOOP.
  CHECK LV_MAIL_CHK = 'Y'.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    TEXT-M28 "'해당 정보로 로스율이 저장됩니다. 진행하시겠습니까?'
    TEXT-M29. "'발송확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-M30."'메일 발송작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CHECK GV_ANSWER = 'J'.

  CLEAR : GV_TIMESTAMP, GS_USR21, GV_ADDRESS,
          GV_ARBPL, GT_ZGTPPT3293, GTT_MESSAGE.
*- 맵핑을 위한 변수키 생성
  GET TIME STAMP FIELD GV_TIMESTAMP.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT3293
    FROM ZGTPPT3293
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD.
  SORT GT_ZGTPPT3293 BY WERKS  SPGCD PERNR.


  IF GT_ZGTPPT3293[] IS NOT INITIAL.


    LOOP AT GT_ZGTPPT3293 INTO GS_ZGTPPT3293.

      CLEAR : GS_USR21, GV_ADDRESS.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF @GS_USR21
                      FROM USR21
                      WHERE BNAME EQ @GS_ZGTPPT3293-PERNR.
      SELECT SINGLE SMTP_ADDR INTO GV_ADDRESS FROM ADR6
                              WHERE ADDRNUMBER = GS_USR21-ADDRNUMBER
                                AND PERSNUMBER = GS_USR21-PERSNUMBER.

      IF GV_ADDRESS IS NOT INITIAL.
*        gv_address = 'largohsy@lscns.com'."'largohsy@lscns.com'.
*        gv_address_cc = 'enflyoon2@lscns.com'."'largohsy@lscns.com'.
*        gv_address = 'sun-woo.kim@lscns.com'.

        PERFORM SEND_MAIL_SETTING.

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

*            g_receiver =
*            cl_cam_address_bcs=>create_internet_address( gv_address_cc ).
*
*            g_email->add_recipient( i_recipient = g_receiver
*                                    i_copy   = 'X' ).

            G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

            G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                           RECEIVING RESULT              = GV_SEND_RESULT ).

            COMMIT WORK.

          CATCH CX_BCS INTO G_EXCEPTION.

        ENDTRY.
*    메일 전송 결과
        IF SY-SUBRC = 0.
          MESSAGE S003 DISPLAY LIKE 'S' WITH TEXT-E20.
          COMMIT WORK.
        ELSE.
          MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E21.
          ROLLBACK WORK.
        ENDIF.

      ELSE.

        "  메일 수신자(구매담당자)의 { GS_ZGTPPT3293-PERNR)
        "  } 전자 메일 주소 발췌를 실패했습니다.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E23
                                           GS_ZGTPPT3293-PERNR
                                           TEXT-E24
                                            .
      ENDIF.

    ENDLOOP.

  ELSE.

    "메일 전송할 플랜트, SPG의 수신자(구매담당자) 정보가 존재하지 않습니다.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E22.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mail_setting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL_SETTING .

  CLEAR : GTT_MESSAGE[].
* 메일 제목 생성
  CLEAR GV_DATE.
  CONCATENATE SY-DATUM+0(4) '.' SY-DATUM+4(2) '.' SY-DATUM+6(2)
           INTO GV_DATE.
  CONCATENATE TEXT-M23  GV_DATE
                  INTO GV_SUBJECT SEPARATED BY SPACE.
* 메일 본문 생성
  MAIL_MSG : '<HTML>',
                    '<BODY>'.

  CONCATENATE TEXT-M24 '<BR>' TEXT-M25 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.


* 구매요청 처리 정보 생성
  MAIL_MSG : '<TABLE STYLE="BORDER-COLLAPSE: COLLAPSE; TABLE-LAYOUT: FIXED; FONT-SIZE: 10PX;">',
                    '<THEAD>',
                    '<TR STYLE="BACKGROUND-COLOR: #F2F2F2; FONT-WEIGHT: BOLD;">',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">구매요청번호</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">품목번호</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">자재</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">내역</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">요청 수량</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">단위</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">납품일</TH>',
                    '<TH STYLE="BORDER: 1PX SOLID #CCC; PADDING: 7PX; TEXT-ALIGN: CENTER;">기타 참고 사항</TH>',
                    '</TR>',
                    '</THEAD>',
                    '<TBODY>'.
* PR LIST
  CLEAR : GT_DISP_MAIL[], GS_DISP_MAIL.
  LOOP AT GT_DISP INTO GS_DISP WHERE CHECK = 'X'.
    MOVE-CORRESPONDING GS_DISP TO GS_DISP_MAIL.
    APPEND GS_DISP_MAIL TO GT_DISP_MAIL.
  ENDLOOP.

  CLEAR : GT_DISP_MAILN[], GS_DISP_MAILN.
  LOOP AT GT_DISP_MAIL INTO GS_DISP_MAIL.
    IF GS_DISP_MAIL-BANFN = 'N건' AND GS_DISP_MAIL-MTS_CHK = 'MTS'.
      LOOP AT GT_T8090 INTO GS_T8090 WHERE GRPNR  = GS_DISP_MAIL-GRPNR
                                       AND VBELN   = GS_DISP_MAIL-VBELN
                                       AND MATNR_F = GS_DISP_MAIL-MATNR_F
                                       AND AUFNR   = GS_DISP_MAIL-AUFNR_T
                                       AND SUL_NO  = GS_DISP_MAIL-SUL_NO
                                       AND GONG_CD = GS_DISP_MAIL-GONG_CD
                                       AND MATNR   = GS_DISP_MAIL-MATNR_R
                                       AND LOEKZ   = ''.
        GS_DISP_MAILN-CHECK    = 'X'.
        GS_DISP_MAILN-BANFN    = GS_T8090-BANFN .       "구매요청번호
        GS_DISP_MAILN-BNFPO    = GS_T8090-BNFPO.        "품목번호
        GS_DISP_MAILN-MATNR_R  = GS_T8090-MATNR.        "자재
        SELECT SINGLE MAKTX
               INTO GS_DISP_MAILN-MAKTX_R
               FROM MAKT
              WHERE MATNR = GS_DISP_MAIL-MATNR_R
                AND SPRAS = SY-LANGU.
        GS_DISP_MAILN-MENGE    = GS_T8090-MENGE.      "요청수량
        GS_DISP_MAILN-MEINS2   = GS_T8090-MEINS.      "단위
        GS_DISP_MAILN-BADAT    = GS_T8090-LFDAT.      " 납품일
        GS_DISP_MAILN-BIGO     = GS_T8090-BIGO .          "비고
        APPEND GS_DISP_MAILN TO GT_DISP_MAILN.
      ENDLOOP.
    ENDIF.

    IF GS_DISP_MAIL-BANFN = 'N건' AND GS_DISP_MAIL-MTS_CHK = ''.
      LOOP AT GT_T8090 INTO GS_T8090 WHERE GRPNR  = GS_DISP_MAIL-GRPNR
                                       AND VBELN   = GS_DISP_MAIL-VBELN
                                       AND MATNR_F = GS_DISP_MAIL-MATNR_F
                                       AND SUL_NO  = GS_DISP_MAIL-SUL_NO
                                       AND GONG_CD = GS_DISP_MAIL-GONG_CD
                                       AND REV_SEQ = GS_DISP_MAIL-REV_SEQ
                                       AND MATNR   = GS_DISP_MAIL-MATNR_R
                                       AND LOEKZ   = ''.
        GS_DISP_MAILN-CHECK    = 'X'.
        GS_DISP_MAILN-BANFN    = GS_T8090-BANFN .       "구매요청번호
        GS_DISP_MAILN-BNFPO    = GS_T8090-BNFPO.        "품목번호
        GS_DISP_MAILN-MATNR_R  = GS_T8090-MATNR.        "자재
        SELECT SINGLE MAKTX
               INTO GS_DISP_MAILN-MAKTX_R
               FROM MAKT
              WHERE MATNR = GS_DISP_MAIL-MATNR_R
                AND SPRAS = SY-LANGU.
        GS_DISP_MAILN-MENGE    = GS_T8090-MENGE.      "요청수량
        GS_DISP_MAILN-MEINS2   = GS_T8090-MEINS.      "단위
        GS_DISP_MAILN-BADAT    = GS_T8090-LFDAT.      " 납품일
        GS_DISP_MAILN-BIGO     = GS_T8090-BIGO .          "비고
        APPEND GS_DISP_MAILN TO GT_DISP_MAILN.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_DISP_MAILN INTO GS_DISP_MAILN.
    MOVE-CORRESPONDING GS_DISP_MAILN TO GS_DISP_MAIL.
    APPEND GS_DISP_MAIL TO GT_DISP_MAIL.
  ENDLOOP.

  SORT GT_DISP_MAIL BY BANFN BNFPO.

  DELETE ADJACENT DUPLICATES FROM GT_DISP_MAIL
                             COMPARING BANFN BNFPO.

  DELETE GT_DISP_MAIL WHERE BANFN = 'N건'.


  LOOP AT GT_DISP_MAIL INTO GS_DISP_MAIL WHERE CHECK = 'X'.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GS_DISP_MAIL-MATNR_R
      IMPORTING
        OUTPUT = GS_DISP_MAIL-MATNR_R.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GS_DISP_MAIL-BANFN
      IMPORTING
        OUTPUT = GS_DISP_MAIL-BANFN.


    CLEAR GV_DATE.
    IF GS_DISP_MAIL-BADAT IS NOT INITIAL.
      CONCATENATE GS_DISP_MAIL-BADAT+0(4) '.'
                  GS_DISP_MAIL-BADAT+4(2) '.'
                  GS_DISP_MAIL-BADAT+6(2)
             INTO GV_DATE.
    ENDIF.

    MAIL_MSG : '<TR STYLE="BACKGROUND-COLOR: #FFFFFF;">'.

    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-BANFN 'C'. "구매요청번호
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-BNFPO 'C'. "품목번호
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-MATNR_R 'C'. "자재
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-MAKTX_R 'C'. "자재내역
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-MENGE 'R'. "요청수량
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-MEINS2 'C'. "단위
    PERFORM APPEND_HTML_FOR_LIST USING GV_DATE 'C'. "납품일
    PERFORM APPEND_HTML_FOR_LIST USING GS_DISP_MAIL-BIGO 'C'. "비고

    MAIL_MSG : '</TR>'.

  ENDLOOP.
* 지연 투입/실적 리스트


  MAIL_MSG: '</TBODY>',
                   '</TABLE>',
                   '<BR>'.

  CONCATENATE TEXT-M26 '<BR>' TEXT-M27 '<BR><BR>'
                  INTO GS_MSG SEPARATED BY SPACE.
  APPEND GS_MSG TO GTT_MESSAGE.
  CLEAR GS_MSG.

  MAIL_MSG:         '</BODY>',
                   '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_HTML_FOR_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DISP_BANFN
*&      --> P_
*&---------------------------------------------------------------------*
FORM APPEND_HTML_FOR_LIST  USING PV_VALUE PV_SIGN.

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
*& Form RE_SEARCH_3290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RE_SEARCH_3290 .

  DATA : LV_LINE  TYPE NUMC3,
         LV_LINE2 TYPE NUMC3..

  LOOP AT GT_DISP INTO GS_DISP.

    CLEAR : LV_LINE.
    CLEAR : GS_T8090.
    LOOP AT GT_T8090 INTO GS_T8090 WHERE GRPNR  = GS_DISP-GRPNR
                                     AND VBELN   = GS_DISP-VBELN
                                     AND MATNR_F = GS_DISP-MATNR_F
                                     AND AUFNR   = GS_DISP-AUFNR_T
                                     AND GONG_CD = GS_DISP-GONG_CD
                                     AND MATNR   = GS_DISP-MATNR_R
                                     AND LOEKZ   = ''.
      LV_LINE = LV_LINE + 1.
    ENDLOOP.

    CASE LV_LINE.
      WHEN 0.

      WHEN 1.
        CLEAR : GS_T8090.
        IF GS_DISP-MTS_CHK = 'MTS'. "
          READ TABLE GT_T8090 INTO GS_T8090
                              WITH KEY  GRPNR  = GS_DISP-GRPNR
                                        VBELN   = GS_DISP-VBELN
                                        MATNR_F = GS_DISP-MATNR_F
                                        AUFNR   = GS_DISP-AUFNR_T
                                        SUL_NO  = GS_DISP-SUL_NO
                                        GONG_CD = GS_DISP-GONG_CD
                                        MATNR   = GS_DISP-MATNR_R
                                        LOEKZ   = ''.
        ELSE.
          READ TABLE GT_T8090 INTO GS_T8090
                              WITH KEY  GRPNR  = GS_DISP-GRPNR
                                        VBELN   = GS_DISP-VBELN
                                        MATNR_F = GS_DISP-MATNR_F
*                                        AUFNR   = GS_DISP-AUFNR_T
                                        SUL_NO  = GS_DISP-SUL_NO
                                        REV_SEQ = GS_DISP-REV_SEQ
                                        GONG_CD = GS_DISP-GONG_CD
                                        MATNR   = GS_DISP-MATNR_R
                                        LOEKZ   = ''.
        ENDIF.
        IF SY-SUBRC = 0.
          GS_DISP-BADAT      =  GS_T8090-BADAT.    " 구매요청일
          GS_DISP-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
          GS_DISP-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
          GS_DISP-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
          GS_DISP-MEINS2     =  GS_T8090-MEINS.    " 단위
          GS_DISP-LFDAT      =  GS_T8090-LFDAT.    " 납기일
          GS_DISP-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
        ELSE.
          GS_DISP-BADAT      =  ''.    " 구매요청일
          GS_DISP-BANFN      =  ''.    " 구매요청 번호
          GS_DISP-BNFPO      =  ''.    " 구매요청 품목번호
          GS_DISP-MENGE      =  ''.    " 구매요청 수량
          GS_DISP-MEINS2     =  ''.    " 단위
          GS_DISP-LFDAT      =  ''.    " 납기일
          GS_DISP-BIGO       =  ''.    " 기타사항(메모)
        ENDIF.
      WHEN OTHERS .
        GS_DISP-BANFN      =  'N건'.    " 구매요청 번호
    ENDCASE.

    MODIFY GT_DISP FROM GS_DISP.
    CLEAR : GS_DISP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RE_PR_SEARCH_3290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RE_PR_SEARCH_3290 .

  LOOP AT  GT_T8090 INTO GS_T8090.

    " MTS 오더를 찾는다
    CLEAR : GS_DISP.
    LOOP AT  GT_DISP INTO GS_DISP WHERE GRPNR   = GS_T8090-GRPNR
                                  AND   VBELN   = GS_T8090-VBELN
                                  AND MATNR_F = GS_T8090-MATNR_F
                                  AND AUFNR_T = GS_T8090-AUFNR
                                  AND SUL_NO  = GS_T8090-SUL_NO
                                  AND GONG_CD = GS_T8090-GONG_CD
                                  AND MATNR_R <> GS_T8090-MATNR
                                  AND LOEKZ   = ''
                                  AND MTS_CHK = 'MTS'.
      READ TABLE GT_DISP_BAN INTO GS_DISP_BAN
                             WITH KEY GRPNR   = GS_T8090-GRPNR
                                     VBELN   = GS_T8090-VBELN
                                     MATNR_F = GS_T8090-MATNR_F
                                     AUFNR_T = GS_T8090-AUFNR
                                     SUL_NO  = GS_T8090-SUL_NO
                                     GONG_CD = GS_T8090-GONG_CD
                                     MATNR_R = GS_T8090-MATNR
                                     LOEKZ   = ''
                                      MTS_CHK = 'MTS'.
      IF SY-SUBRC <> 0.
        MOVE-CORRESPONDING GS_DISP TO GS_DISP_BAN.
        GS_DISP_BAN-REV_SEQ    =  GS_T8090-REV_SEQ.    "
        GS_DISP_BAN-MATNR_R    =  GS_T8090-MATNR.
        GS_DISP_BAN-BADAT      =  GS_T8090-BADAT.    " 구매요청일
        GS_DISP_BAN-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
        GS_DISP_BAN-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
        GS_DISP_BAN-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
        GS_DISP_BAN-MEINS2     =  GS_T8090-MEINS.    " 단위
        GS_DISP_BAN-LFDAT      =  GS_T8090-LFDAT.    " 납기일
        GS_DISP_BAN-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
        GS_DISP_BAN-PO_YN      = 'Y'.
        GS_DISP_BAN-GUBUN   =  TEXT-V02."기존 발주내역
        APPEND  GS_DISP_BAN TO  GT_DISP_BAN .
      ENDIF.
    ENDLOOP.

    " 조장표 오더를 찾는다
    CLEAR : GS_DISP.
    LOOP AT  GT_DISP INTO GS_DISP WHERE GRPNR   = GS_T8090-GRPNR
                                  AND VBELN   = GS_T8090-VBELN
                                  AND MATNR_F = GS_T8090-MATNR_F
*                                  AND AUFNR_T = GS_T8090-AUFNR
                                  AND SUL_NO  = GS_T8090-SUL_NO
                                  AND GONG_CD = GS_T8090-GONG_CD
                                  AND REV_SEQ <> GS_T8090-REV_SEQ
*                                  AND MATNR_R = GS_T8090-MATNR
                                  AND LOEKZ   = ''
                                  AND MTS_CHK = ''.
      READ TABLE GT_DISP_BAN INTO GS_DISP_BAN
                             WITH KEY GRPNR   = GS_T8090-GRPNR
                                      VBELN   = GS_T8090-VBELN
                                      MATNR_F = GS_T8090-MATNR_F
*                                      AUFNR_T = GS_T8090-AUFNR
                                      SUL_NO  = GS_T8090-SUL_NO
                                      REV_SEQ = GS_T8090-REV_SEQ
                                      GONG_CD = GS_T8090-GONG_CD
                                      MATNR_R = GS_T8090-MATNR
                                      LOEKZ   = ''
                                      MTS_CHK = ''.
      IF SY-SUBRC <> 0.
        MOVE-CORRESPONDING GS_DISP TO GS_DISP_BAN.
        GS_DISP_BAN-REV_SEQ    =  GS_T8090-REV_SEQ.    "
        GS_DISP_BAN-MATNR_R    =  GS_T8090-MATNR.    "
        GS_DISP_BAN-BADAT      =  GS_T8090-BADAT.    " 구매요청일
        GS_DISP_BAN-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
        GS_DISP_BAN-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
        GS_DISP_BAN-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
        GS_DISP_BAN-MEINS2     =  GS_T8090-MEINS.    " 단위
        GS_DISP_BAN-LFDAT      =  GS_T8090-LFDAT.    " 납기일
        GS_DISP_BAN-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
        GS_DISP_BAN-PO_YN      = 'Y'.
        GS_DISP_BAN-GUBUN   =  TEXT-V02."기존 발주내역
        APPEND  GS_DISP_BAN TO  GT_DISP_BAN .

      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELET_DUPL_ALV_PR_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_DUPL_CHK_PR_LIST_MTS .

  LOOP AT  GT_DISP_BAN INTO GS_DISP_BAN WHERE LOEKZ   = ''
                                          AND MTS_CHK = 'MTS'.
    LOOP AT  GT_DISP INTO GS_DISP
                           WHERE GRPNR   = GS_DISP_BAN-GRPNR
                             AND VBELN   = GS_DISP_BAN-VBELN
                             AND MATNR_F = GS_DISP_BAN-MATNR_F
                             AND AUFNR_T = GS_DISP_BAN-AUFNR_T
                             AND SUL_NO  = GS_DISP_BAN-SUL_NO
                             AND GONG_CD = GS_DISP_BAN-GONG_CD
                             AND MATNR_R  = GS_DISP_BAN-MATNR_R
                             AND LOEKZ   = ''
                             AND MTS_CHK = 'MTS'.

      GS_DISP_BAN-DCHK = 'X'.
      MODIFY GT_DISP_BAN FROM GS_DISP_BAN.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_dupl_chk_pr_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_DUPL_CHK_PR_LIST .

  LOOP AT  GT_DISP_BAN INTO GS_DISP_BAN WHERE LOEKZ   = ''
                                          AND MTS_CHK = ''.
    LOOP AT  GT_DISP INTO GS_DISP
                           WHERE GRPNR   = GS_DISP_BAN-GRPNR
                             AND VBELN   = GS_DISP_BAN-VBELN
                             AND MATNR_F = GS_DISP_BAN-MATNR_F
                             AND SUL_NO  = GS_DISP_BAN-SUL_NO
                             AND REV_SEQ = GS_DISP_BAN-REV_SEQ
                             AND GONG_CD = GS_DISP_BAN-GONG_CD
                             AND MATNR_R = GS_DISP_BAN-MATNR_R
                             AND LOEKZ   = ''
                             AND MTS_CHK = ''.
      GS_DISP_BAN-DCHK = 'X'.
      MODIFY GT_DISP_BAN FROM GS_DISP_BAN.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form re_make_list_disp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RE_MAKE_LIST_DISP .

  LOOP AT GT_DISP INTO GS_DISP.
    IF GS_DISP-GUBUN = '대체자재 지정'.
      IF GS_DISP-MTS_CHK = 'MTS'. "

        READ TABLE  GT_T8090 INTO GS_T8090
                            WITH KEY   GRPNR  = GS_DISP-GRPNR
                                 VBELN   = GS_DISP-VBELN
                                 MATNR_F = GS_DISP-MATNR_F
                                 AUFNR   = GS_DISP-AUFNR_T
                                 SUL_NO  = GS_DISP-SUL_NO
                                 GONG_CD = GS_DISP-GONG_CD
                                 MATNR   = GS_DISP-MATNR_R
                                LOEKZ   = ''.
        IF SY-SUBRC = 0.
          GS_DISP-BADAT      =  GS_T8090-BADAT.    " 구매요청일
          GS_DISP-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
          GS_DISP-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
          GS_DISP-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
          GS_DISP-MEINS2     =  GS_T8090-MEINS.    " 단위
          GS_DISP-LFDAT      =  GS_T8090-LFDAT.    " 납기일
          GS_DISP-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
          GS_DISP-PO_YN      = 'Y'.
          MODIFY GT_DISP FROM  GS_DISP.
        ELSE.
          GS_DISP-BADAT      =  ''.    " 구매요청일
          GS_DISP-BANFN      =  ''.    " 구매요청 번호
          GS_DISP-BNFPO      =  ''.    " 구매요청 품목번호
          GS_DISP-MENGE      =  ''.    " 구매요청 수량
          GS_DISP-MEINS2     =  ''.    " 단위
          GS_DISP-LFDAT      =  ''.    " 납기일
          GS_DISP-BIGO       =  ''.   " 기타사항(메모)
          GS_DISP-PO_YN      = 'N'.
          MODIFY GT_DISP FROM  GS_DISP.
        ENDIF.
      ELSE.
        READ TABLE  GT_T8090 INTO GS_T8090
                            WITH KEY    GRPNR  = GS_DISP-GRPNR
                                 VBELN   = GS_DISP-VBELN
                                 MATNR_F = GS_DISP-MATNR_F
*                                AUFNR   = GS_DISP-AUFNR_T
                                 SUL_NO  = GS_DISP-SUL_NO
                                 REV_SEQ = GS_DISP-REV_SEQ
                                 GONG_CD = GS_DISP-GONG_CD
                                 MATNR   = GS_DISP-MATNR_R
                                 LOEKZ   = ''.
        IF SY-SUBRC = 0.
          GS_DISP-BADAT      =  GS_T8090-BADAT.    " 구매요청일
          GS_DISP-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
          GS_DISP-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
          GS_DISP-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
          GS_DISP-MEINS2     =  GS_T8090-MEINS.    " 단위
          GS_DISP-LFDAT      =  GS_T8090-LFDAT.    " 납기일
          GS_DISP-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
          GS_DISP-PO_YN      = 'Y'.
          MODIFY GT_DISP FROM  GS_DISP.
        ELSE.
          GS_DISP-BADAT      =  ''.    " 구매요청일
          GS_DISP-BANFN      =  ''.    " 구매요청 번호
          GS_DISP-BNFPO      =  ''.    " 구매요청 품목번호
          GS_DISP-MENGE      =  ''.    " 구매요청 수량
          GS_DISP-MEINS2     =  ''.    " 단위
          GS_DISP-LFDAT      =  ''.    " 납기일
          GS_DISP-BIGO       =  ''.   " 기타사항(메모)
          GS_DISP-PO_YN      = 'N'.
          MODIFY GT_DISP FROM  GS_DISP.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form last_loss_col_disp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LAST_LOSSRATE_COL_DISP .

  LOOP AT GT_DISP INTO GS_DISP.
    "자재내역
    CLEAR : GS_MAKT.
    READ TABLE GT_MAKTALL INTO GS_MAKT
                       WITH KEY MATNR = GS_DISP-MATNR_F
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-MAKTX_F =   GS_MAKT-MAKTX.
    ENDIF.

    "자재내역
    CLEAR : GS_MAKT.
    READ TABLE GT_MAKTALL INTO GS_MAKT
                       WITH KEY MATNR = GS_DISP-MATNR_R
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-MAKTX_R =   GS_MAKT-MAKTX.
    ENDIF.

    " 로스율  소요량(수주 기준) 소요량(잔여 기준) 계산
    IF GS_DISP-MTS_CHK = 'MTS'.

      CLEAR : GS_T3291.
      READ TABLE  GT_T3291 INTO GS_T3291
                           WITH KEY GRPNR   = GS_DISP-GRPNR
                                    VBELN   = GS_DISP-VBELN
                                    AUFNR   = GS_DISP-AUFNR_T
                                    MATNR_F = GS_DISP-MATNR_F
                                    GONG_CD = GS_DISP-GONG_CD
                                    MATNR   = GS_DISP-MATNR_R
                                    BINARY SEARCH.
      IF SY-SUBRC = 0.

        READ TABLE GT_RESB INTO GS_RESB
                   WITH KEY  AUFNR = GS_DISP-AUFNR_T
                             MATNR = GS_DISP-MATNR_R..

        GS_DISP-AUSCH      = GS_T3291-LOSS  .

        " 소요량 = 기존 소요량 * 수정한 로스율 / 기존 로스율
        GS_DISP-ERFMG_SO = ( GS_DISP-ERFMG_SO *
                           GS_T3291-LOSS / ( 1 + ( GS_RESB-AUSCH / 100 ) )
                           )
                           .
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                 / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.

      ELSE.
        READ TABLE GT_RESB INTO GS_RESB
                   WITH KEY  AUFNR = GS_DISP-AUFNR_T
                             MATNR = GS_DISP-MATNR_R.

        "로스율
        GS_DISP-AUSCH      = 1 + ( GS_RESB-AUSCH / 100 ) .
        "소요량(수주 기준)
        GS_DISP-ERFMG_SO  = GS_RESB-BDMNG.
        "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.

      ENDIF.

    ELSE.

      READ TABLE  GT_T3291 INTO GS_T3291
                           WITH KEY GRPNR   = GS_DISP-GRPNR
                                    VBELN   = GS_DISP-VBELN
                                    MATNR_F = GS_DISP-MATNR_F
                                    GONG_CD = GS_DISP-GONG_CD
                                    MATNR   = GS_DISP-MATNR_R.
      IF SY-SUBRC = 0.
        "로스율
        IF GS_T3291-LOSS <> 0.
          GS_DISP-AUSCH      = GS_T3291-LOSS .
        ELSE.
          GS_DISP-AUSCH      = '1.05' .
        ENDIF.
        "소요량(수주 기준) = '정미량(JAJE_QTY)' * 로스율 * '신규 수주량(WMENG) / 1000.
        GS_DISP-ERFMG_SO   =  ( GS_DISP-JAJE_QTY *
                               GS_DISP-AUSCH *
                               GS_DISP-NWMENG ) / 1000.
        "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.
      ELSE.
        "로스율
        GS_DISP-AUSCH      = '1.05' .
        "소요량(수주 기준) = '정미량(JAJE_QTY)' * 로스율 * '신규 수주량(WMENG) / 1000.
        GS_DISP-ERFMG_SO   =  ( GS_DISP-JAJE_QTY *
                               GS_DISP-AUSCH *
                               GS_DISP-NWMENG ) / 1000.
        "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.
      ENDIF.

    ENDIF.

    MODIFY GT_DISP FROM GS_DISP.
    CLEAR : GS_DISP.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_MATNR_SEARCH_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_MATNR_SEARCH_LIST .

  LOOP AT GT_DISP INTO GS_DISP.

    "대체자재 변경유무 판단---------------
    IF GS_DISP-MTS_CHK = 'MTS'. " MTS자재인지 아닌지 판단
      READ TABLE GT_T3292 INTO GS_T3292
                         WITH KEY GRPNR = GS_DISP-GRPNR
                               VBELN    = GS_DISP-VBELN+0(10)
                               AUFNR    = GS_DISP-AUFNR_T
                               MATNR_F  = GS_DISP-MATNR_F
                               GONG_CD  = GS_DISP-GONG_CD
                               MATNR_ORIGIN = GS_DISP-MATNR_R.
    ELSE.
      READ TABLE GT_T3292 INTO GS_T3292
                         WITH KEY GRPNR = GS_DISP-GRPNR
                               VBELN    = GS_DISP-VBELN+0(10)
*                                AUFNR    = GS_DISP-AUFNR_T
                               MATNR_F  = GS_DISP-MATNR_F
                               GONG_CD  = GS_DISP-GONG_CD
                               MATNR_ORIGIN = GS_DISP-MATNR_R.
    ENDIF.
    " 기존 리스트에 pr발주 이력이 있다면
    " 기존 리스트 내역과 대체자재 내역을 같이 보여준다
    IF SY-SUBRC = 0.
      IF GS_DISP-BANFN IS NOT INITIAL.
        MOVE-CORRESPONDING GS_DISP TO GS_DISP_MAT.
        GS_DISP_MAT-GUBUN   =  TEXT-V02."기존 발주내역
        APPEND  GS_DISP_MAT TO  GT_DISP_MAT .
      ENDIF.
      CLEAR : GS_DISP-GUBUN.
      GS_DISP-MATNR_R =  GS_T3292-MATNR_TO.
      GS_DISP-GUBUN   =  TEXT-V01."'대체자재 지정'.
    ENDIF.

    MODIFY GT_DISP FROM GS_DISP.
    CLEAR : GS_DISP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MTS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_MTS_DATA .

  DATA : LV_AUART(10).
  DATA : LV_LINE  TYPE NUMC3,
         LV_LINE2 TYPE NUMC3..

  LOOP AT GT_TCVORDSYVAL INTO GS_TCVORDSYVAL.
    CLEAR : GS_RESB.
    LOOP AT GT_RESB INTO GS_RESB
                    WHERE AUFNR = GS_TCVORDSYVAL-AUFNR.

      CLEAR : LV_AUART.
      CONCATENATE 'MTS#' GS_TCVORDSYVAL-AUART
             INTO LV_AUART.
      GS_DISP-GRPNR   =   LV_AUART.      "  조장표번호
      GS_DISP-VBELN	  =   GS_TCVORDSYVAL-KDAUF. "  판매오더
      GS_DISP-VBELN_TXT	  =   GS_TCVORDSYVAL-KDAUF. "  판매오더
      GS_DISP-KUNNR   =   GS_TCVORDSYVAL-KUNNR. "   고객사코드
      " 납선
      CLEAR : GS_KNA1.
      READ TABLE GT_KNA1 INTO GS_KNA1
                         WITH KEY KUNNR = GS_TCVORDSYVAL-KUNNR
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-NAME1   =   GS_KNA1-NAME1.
      ENDIF.

      GS_DISP-EDATU      =   ''.  " 납품요청일
      GS_DISP-SUL_NO     =   ''.  " 설계서번호
      GS_DISP-REV_SEQ    =   ''.  " REVISION
      GS_DISP-SOSUN1     =   ''.  " 소선구성 1
      GS_DISP-SOSUN3     =   ''.  " 소선구성 2
      GS_DISP-MATNR_F    =   GS_TCVORDSYVAL-MATNR.   " 제품
      GS_DISP-KV         =   GS_TCVORDSYVAL-PDCAVOLTAGE.    " KV
      GS_DISP-SQ         =   GS_TCVORDSYVAL-PDCACONDSIZE1ST." SQ
      " 제품명
      CLEAR : GS_MAKT.
      READ TABLE GT_MAKT INTO GS_MAKT
                         WITH KEY MATNR = GS_TCVORDSYVAL-MATNR
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-MAKTX_F =   GS_MAKT-MAKTX.
      ENDIF.
      " 오더 총 수량
      READ TABLE GT_ORDSYVALP_SUM INTO GS_ORDSYVALP_SUM
                           WITH KEY AUFNR = GS_TCVORDSYVAL-AUFNR.
      IF SY-SUBRC = 0.
        GS_DISP-NWMENG =  GS_ORDSYVALP_SUM-PSMNG.
      ENDIF.
      " 수주단위
      GS_DISP-MEINS    = GS_TCVORDSYVAL-MEINS.
      " 입고수량
      READ TABLE GT_ORDSYVALW_SUM INTO GS_ORDSYVALW_SUM
                           WITH KEY AUFNR = GS_TCVORDSYVAL-AUFNR.
      IF SY-SUBRC = 0.
        GS_DISP-WEMNG =  GS_ORDSYVALW_SUM-WEMNG.
      ENDIF.
      "입고단위 -> 오더 단위
      GS_DISP-AMEIN      = GS_TCVORDSYVAL-MEINS.
      " 잔여수량  DEFAULT 값 : {신규 수주량} - {입고 수량}  ????
      GS_DISP-RWMENG   = GS_DISP-NWMENG - GS_DISP-WEMNG.
      " 오더번호
      GS_DISP-AUFNR_T    = GS_TCVORDSYVAL-AUFNR.
      GS_DISP-AUFNR_TXT    = GS_TCVORDSYVAL-AUFNR.

      "공정코드
      GS_DISP-GONG_CD    =  GS_TCVORDSYVAL-PDCAPROCCODE.
      "공정
      GS_DISP-GONG_NM    =  GS_TCVORDSYVAL-PDCAPROCNAME.

      "자재코드
      GS_DISP-MATNR_R    =  GS_RESB-MATNR.

      CLEAR : GS_T3291.
      READ TABLE  GT_T3291 INTO GS_T3291
                           WITH KEY GRPNR   = GS_DISP-GRPNR
                                    VBELN   = GS_DISP-VBELN
                                    AUFNR   = GS_DISP-AUFNR_T
                                    MATNR_F = GS_DISP-MATNR_F
                                    GONG_CD = GS_DISP-GONG_CD
                                    MATNR   = GS_DISP-MATNR_R.
      IF SY-SUBRC = 0.
        GS_DISP-AUSCH      = GS_T3291-LOSS  .

        " 소요량 = 기존 소요량 * 수정한 로스율 / 기존 로스율
        GS_DISP-ERFMG_SO = ( GS_DISP-ERFMG_SO *
                           GS_T3291-LOSS / ( 1 + ( GS_RESB-AUSCH / 100 ) )
                           )
                           .
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                 / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.

      ELSE.
        "로스율
        GS_DISP-AUSCH      = 1 + ( GS_RESB-AUSCH / 100 ) .

        "소요량(수주 기준)
        GS_DISP-ERFMG_SO  = GS_RESB-BDMNG.

        "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량
        IF GS_DISP-NWMENG <> 0.
          GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                                / GS_DISP-NWMENG.
        ELSE.
          GS_DISP-ERFMG_RE   = 0 .
        ENDIF.

      ENDIF.

      "단위
      GS_DISP-JAJE_UNIT    =  GS_RESB-MEINS.

      CLEAR : LV_LINE.
      CLEAR : GS_T8090.
      LOOP AT GT_T8090 INTO GS_T8090 WHERE GRPNR  = GS_DISP-GRPNR
                                       AND VBELN   = GS_DISP-VBELN
                                       AND MATNR_F = GS_DISP-MATNR_F
                                       AND AUFNR   = GS_DISP-AUFNR_T
                                       AND GONG_CD = GS_DISP-GONG_CD
                                       AND MATNR   = GS_DISP-MATNR_R
                                       AND LOEKZ   = ''.
        LV_LINE = LV_LINE + 1.
      ENDLOOP.

      CASE LV_LINE.
        WHEN 0.

        WHEN 1.
          CLEAR : GS_T8090.
          READ TABLE GT_T8090 INTO GS_T8090
                              WITH KEY  GRPNR  = GS_DISP-GRPNR
                                        VBELN   = GS_DISP-VBELN
                                        MATNR_F = GS_DISP-MATNR_F
                                        AUFNR   = GS_DISP-AUFNR_T
                                        GONG_CD = GS_DISP-GONG_CD
                                        MATNR   = GS_DISP-MATNR_R
                                        LOEKZ   = ''.
          IF SY-SUBRC = 0.
            GS_DISP-BADAT      =  GS_T8090-BADAT.    " 구매요청일
            GS_DISP-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
            GS_DISP-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
            GS_DISP-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
            GS_DISP-MEINS2     =  GS_T8090-MEINS.    " 단위
            GS_DISP-LFDAT      =  GS_T8090-LFDAT.    " 납기일
            GS_DISP-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
          ENDIF.
        WHEN OTHERS .
          GS_DISP-BANFN      =  'N건'.    " 구매요청 번호
      ENDCASE.

      IF GS_DISP-BANFN IS NOT INITIAL..
        IF GS_DISP-LOEKZ IS INITIAL.
          GS_DISP-PO_YN  =    'Y'.                  " 발주여부
        ELSE.
          GS_DISP-PO_YN  =    'N'.                  " 발주여부
        ENDIF.
      ELSE.
        GS_DISP-PO_YN  =    'N' .
      ENDIF.

      GS_DISP-GUBUN   =  TEXT-V03."오더 BOM

      GS_DISP-MTS_CHK = 'MTS'.

      APPEND GS_DISP TO GT_DISP_MTS .
      CLEAR : GS_DISP.

    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_DISP_DATA2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_ALV_DISP_DATA2 .

  DATA : LV_WEMNG_SUM  LIKE AFPO-WEMNG,
         LV_NWMENG_SUM LIKE ZGTPPT2000-WMENG.
  DATA : LV_LINE  TYPE NUMC3,
         LV_LINE2 TYPE NUMC3..
  DATA : LV_AUART(10),
         LV_AUFNR_TXT1(100),
         LV_AUFNR_TXT(100).

  DATA : LV_INFACTOR TYPE ZGTPPT2010-INFACTOR.

  LOOP AT GT_DISP INTO GS_DISP.

    "오더 총 수량
    CLEAR : GS_T2010.
    CLEAR : LV_NWMENG_SUM.
    CLEAR LV_INFACTOR.
    LOOP AT GT_T2010 INTO GS_T2010 WHERE GRPNR = GS_DISP-GRPNR
                                   AND  GONG_CD = GS_DISP-GONG_CD.
      IF GS_T2010-DELCHK2 <> 'X'.
        LV_NWMENG_SUM = LV_NWMENG_SUM + GS_T2010-NWMENG.
      ENDIF.
      GS_DISP-MEINS      =  GS_T2010-MEINS.     "   수주단위
      LV_INFACTOR = GS_T2010-INFACTOR.
    ENDLOOP.

    GS_DISP-NWMENG     =  LV_NWMENG_SUM.   "    오더 총 수량
    "   잔여수량----
    CLEAR :LV_WEMNG_SUM, LV_LINE,LV_LINE2.
    LV_WEMNG_SUM = 0.
    LOOP AT GT_T2010 INTO GS_T2010 WHERE GRPNR = GS_DISP-GRPNR
                                     AND GONG_CD = GS_DISP-GONG_CD.
      IF GS_T2010-DELCHK2 <> 'X'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = GS_T2010-ORDNR
          IMPORTING
            OUTPUT = GS_DISP-AUFNR_T.
        LV_WEMNG_SUM      = LV_WEMNG_SUM + GS_T2010-WEMNG.  "입고수량 합
        GS_DISP-AMEIN     = GS_T2010-MEINS.    "  입고단위
        LV_LINE = LV_LINE + 1.
      ENDIF.
    ENDLOOP.

    CASE LV_LINE.
      WHEN 0.
        LV_LINE2 = 0.
        LV_AUFNR_TXT = ''.
      WHEN 1.
        LV_LINE2 = LV_LINE.
        CONCATENATE GS_DISP-AUFNR_T '' INTO LV_AUFNR_TXT1.
        CONCATENATE  LV_AUFNR_TXT1
                     ' '
                INTO LV_AUFNR_TXT  SEPARATED BY SPACE..
      WHEN OTHERS .
        LV_LINE2 = LV_LINE - 1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_LINE2
          IMPORTING
            OUTPUT = LV_LINE2.
        CONCATENATE GS_DISP-AUFNR_T '외' INTO LV_AUFNR_TXT1.
        CONCATENATE  LV_AUFNR_TXT1
                     ' '
                     LV_LINE2
                    '건'
                INTO LV_AUFNR_TXT  SEPARATED BY SPACE..
    ENDCASE.


    GS_DISP-AUFNR_TXT  = LV_AUFNR_TXT.     " 오더번호 외 N 건

    GS_DISP-RWMENG     = GS_DISP-NWMENG - LV_WEMNG_SUM. "   잔여수량
    GS_DISP-WEMNG      = LV_WEMNG_SUM.    "   입고수량

*
    IF P_WERKS = '1302'. " 지중은 조장구성표 조장수로 나누어 준다.
      IF LV_INFACTOR NE 0.
        GS_DISP-NWMENG     =  GS_DISP-NWMENG / LV_INFACTOR.   "    오더 총 수량
        GS_DISP-RWMENG     =  GS_DISP-RWMENG / LV_INFACTOR.   "    오더 총 수량
        GS_DISP-WEMNG     =  GS_DISP-WEMNG  / LV_INFACTOR.   "    오더 총 수량
      ENDIF.
    ENDIF.
    GS_DISP-INFACTOR = 1.
    IF LV_INFACTOR NE 0.
      GS_DISP-INFACTOR = LV_INFACTOR.
    ENDIF.

    " GONG_CD 가 AFPO(오더 품목)에 없는 경우
    READ TABLE GT_T2010 INTO GS_T2010
                        WITH KEY GRPNR = GS_DISP-GRPNR
                                 GONG_CD = GS_DISP-GONG_CD.
    IF SY-SUBRC <> 0.
      GS_DISP-RWMENG    = '0.0'. "   잔여수량
      GS_DISP-WEMNG     = '0.0'. "   입고수량
      GS_DISP-AMEIN     = ''.   "  입고단위
    ENDIF.

    READ TABLE  GT_T3291 INTO GS_T3291
                         WITH KEY GRPNR   = GS_DISP-GRPNR
                                  VBELN   = GS_DISP-VBELN
                                  MATNR_F = GS_DISP-MATNR_F
                                  GONG_CD = GS_DISP-GONG_CD
                                  MATNR   = GS_DISP-MATNR_R.
    IF SY-SUBRC = 0.
      "로스율
      IF GS_T3291-LOSS <> 0.
        GS_DISP-AUSCH      = GS_T3291-LOSS .
      ELSE.
        GS_DISP-AUSCH      = '1.05' .
      ENDIF.
      "소요량(수주 기준) = '정미량(JAJE_QTY)' * 로스율 * '신규 수주량(WMENG) / 1000.
      GS_DISP-ERFMG_SO   =  ( GS_DISP-JAJE_QTY *
                             GS_DISP-AUSCH *
                             GS_DISP-NWMENG ) / 1000.
      "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
      IF GS_DISP-NWMENG <> 0.
        GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                              / GS_DISP-NWMENG.
      ELSE.
        GS_DISP-ERFMG_RE   = 0 .
      ENDIF.
    ELSE.
      "로스율
      GS_DISP-AUSCH      = '1.05' .
      "소요량(수주 기준) = '정미량(JAJE_QTY)' * 로스율 * '신규 수주량(WMENG) / 1000.
      GS_DISP-ERFMG_SO   =  ( GS_DISP-JAJE_QTY *
                             GS_DISP-AUSCH *
                             GS_DISP-NWMENG ) / 1000.
      "소요량(잔여 기준) = '소요량(수주 기준)' * 잔여 수량 / 신규 수주량
      IF GS_DISP-NWMENG <> 0.
        GS_DISP-ERFMG_RE   = ( GS_DISP-ERFMG_SO * GS_DISP-RWMENG )
                              / GS_DISP-NWMENG.
      ELSE.
        GS_DISP-ERFMG_RE   = 0 .
      ENDIF.
    ENDIF.


    CLEAR : LV_LINE.
    CLEAR : GS_T8090.
    LOOP AT GT_T8090 INTO GS_T8090 WHERE GRPNR  = GS_DISP-GRPNR
                                     AND VBELN   = GS_DISP-VBELN
                                     AND MATNR_F = GS_DISP-MATNR_F
                                     AND GONG_CD = GS_DISP-GONG_CD
                                     AND MATNR   = GS_DISP-MATNR_R
                                     AND LOEKZ   = ''.

      LV_LINE = LV_LINE + 1.

    ENDLOOP.
    CASE LV_LINE.
      WHEN 0.

      WHEN 1.
        CLEAR : GS_T8090.
        IF GS_DISP-MTS_CHK = 'MTS'.
          READ TABLE GT_T8090 INTO GS_T8090
                              WITH KEY GRPNR   = GS_DISP-GRPNR
                                        VBELN   = GS_DISP-VBELN
                                        MATNR_F = GS_DISP-MATNR_F
                                        AUFNR   = GS_DISP-AUFNR_T
                                        SUL_NO  = GS_DISP-SUL_NO
                                        GONG_CD = GS_DISP-GONG_CD
                                        MATNR   = GS_DISP-MATNR_R
                                        LOEKZ   = ''.

        ELSE.
          READ TABLE GT_T8090 INTO GS_T8090
                              WITH KEY GRPNR   = GS_DISP-GRPNR
                                        VBELN   = GS_DISP-VBELN
                                        MATNR_F = GS_DISP-MATNR_F
                                        SUL_NO  = GS_DISP-SUL_NO
                                        GONG_CD = GS_DISP-GONG_CD
                                        MATNR   = GS_DISP-MATNR_R
                                        LOEKZ   = ''.

        ENDIF.
        .
        IF SY-SUBRC = 0.
          GS_DISP-BADAT      =  GS_T8090-BADAT.    " 구매요청일
          GS_DISP-BANFN      =  GS_T8090-BANFN.    " 구매요청 번호
          GS_DISP-BNFPO      =  GS_T8090-BNFPO.    " 구매요청 품목번호
          GS_DISP-MENGE      =  GS_T8090-MENGE.    " 구매요청 수량
          GS_DISP-MEINS2     =  GS_T8090-MEINS.    " 단위
          GS_DISP-LFDAT      =  GS_T8090-LFDAT.    " 납기일
          GS_DISP-BIGO       =  GS_T8090-BIGO.    " 기타사항(메모)
        ELSE.
          GS_DISP-BADAT      =  ''.    " 구매요청일
          GS_DISP-BANFN      =  ''.    " 구매요청 번호
          GS_DISP-BNFPO      =  ''.    " 구매요청 품목번호
          GS_DISP-MENGE      =  ''.    " 구매요청 수량
          GS_DISP-MEINS2     =  ''.    " 단위
          GS_DISP-LFDAT      =  ''.    " 납기일
          GS_DISP-BIGO       =  ''.    " 기타사항(메모)
        ENDIF.

      WHEN OTHERS .
        GS_DISP-BANFN      =  'N건'.    " 구매요청 번호
    ENDCASE.

    IF GS_DISP-BANFN IS NOT INITIAL..
      IF GS_DISP-LOEKZ IS INITIAL.
        GS_DISP-PO_YN  =    'Y'.                  " 발주여부
      ELSE.
        GS_DISP-PO_YN  =    'N'.                  " 발주여부
      ENDIF.
    ELSE.
      GS_DISP-PO_YN  =    'N' .
    ENDIF.

    GS_DISP-GUBUN   =  TEXT-V04."설계서 자재량

    MODIFY GT_DISP FROM GS_DISP.
    CLEAR : GS_DISP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ALV_DISP_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ALV_DISP_PO_DATA .

  IF GT_DISP_TMP[] IS NOT INITIAL.
    CLEAR : GT_EKPOA[].
    SELECT  *
      INTO CORRESPONDING FIELDS OF TABLE @GT_EKPOA
      FROM EKPO AS A  INNER JOIN EKET AS B
                      ON   A~EBELN = B~EBELN
                      AND  A~EBELP = B~EBELP
      FOR ALL ENTRIES IN @GT_DISP_TMP
     WHERE A~BANFN = @GT_DISP_TMP-BANFN
       AND A~BNFPO = @GT_DISP_TMP-BNFPO.

    LOOP AT GT_DISP INTO GS_DISP.
      CLEAR : GS_EKPOA.
      READ TABLE GT_EKPOA INTO GS_EKPOA
                          WITH KEY BANFN = GS_DISP-BANFN
                                   BNFPO = GS_DISP-BNFPO.
      IF SY-SUBRC = 0.
        GS_DISP-EBELN      =  GS_EKPOA-EBELN.    " 구매오더번호
        GS_DISP-EBELP      =  GS_EKPOA-EBELP.    " 구매오더 품목 번호
        GS_DISP-WEMNG2     =  GS_EKPOA-WEMNG.    " 입고 금액
      ENDIF.
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_GET_DATA .

  CASE ABAP_TRUE.
    WHEN P_R1. " 소요량
      PERFORM GET_DATA.
      PERFORM MODIFY_DATA.
    WHEN P_R2. " 발주내역 확인
      PERFORM GET_DATA_3280.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  CASE ABAP_TRUE.
    WHEN P_R1. " 소요량
      CALL SCREEN 100.
    WHEN P_R2. " 발주내역 확인
      CALL SCREEN 500.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_3280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_3280 .

  DATA : BEGIN OF LS_COLLECT_EKPO,
           EBELN TYPE EKPO-EBELN,
           EBELP TYPE EKPO-EBELP,
           BANFN TYPE EKPO-BANFN,
           BNFPO TYPE EKPO-BNFPO,
           MEINS TYPE EKPO-MEINS,
           WEMNG TYPE EKET-WEMNG,
         END OF LS_COLLECT_EKPO.
  DATA : LT_COLLECT_EKPO LIKE TABLE OF LS_COLLECT_EKPO.

  REFRESH GT_DISP_500.
  SELECT * FROM ZGTPPT3280
    INTO CORRESPONDING FIELDS OF TABLE GT_DISP_500
   WHERE WERKS = P_WERKS
      AND BANFN IN S_BANFN
      AND LGORT IN S_LGORT
      AND BADAT IN S_BADAT
      AND LIFNR IN S_LIFNR
      AND MATNR IN S_MATN2
      AND LFDAT IN S_LFDAT
      AND LOEKZ = ' '.

  DATA(LT_SORT_EKPO) = GT_DISP_500.
  SORT LT_SORT_EKPO BY BANFN BNFPO.
  DELETE ADJACENT DUPLICATES FROM LT_SORT_EKPO COMPARING BANFN BNFPO.
  IF LT_SORT_EKPO[] IS NOT INITIAL.
    SELECT A~EBELN, A~EBELP, B~ETENR, A~BANFN, A~BNFPO, A~MEINS, B~WEMNG
      FROM EKPO AS A
      INNER JOIN EKET AS B ON B~EBELN = A~EBELN
                                 AND B~EBELP = A~EBELP
      FOR ALL ENTRIES IN @LT_SORT_EKPO
     WHERE A~BANFN = @LT_SORT_EKPO-BANFN
        AND A~BNFPO = @LT_SORT_EKPO-BNFPO
       INTO TABLE @DATA(LT_EKPO).
  ENDIF.

  LOOP AT LT_EKPO INTO DATA(LS_EKPO).
    CLEAR LS_COLLECT_EKPO.
    MOVE-CORRESPONDING LS_EKPO TO LS_COLLECT_EKPO.
    COLLECT LS_COLLECT_EKPO INTO LT_COLLECT_EKPO.
  ENDLOOP.

  DELETE LT_COLLECT_EKPO WHERE WEMNG = 0.
  SORT LT_COLLECT_EKPO BY BANFN BNFPO.

  LOOP AT GT_DISP_500 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
*   자재내역
    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR ).
*   공급업체
    SELECT SINGLE NAME1 FROM LFA1
      INTO <LS_MAIN>-NAME1
     WHERE LIFNR = <LS_MAIN>-LIFNR.

* PO 변환정보가 있고 입고 수량이 존재한다면 modi
    CLEAR LS_COLLECT_EKPO.
    READ TABLE LT_COLLECT_EKPO INTO LS_COLLECT_EKPO WITH KEY BANFN = <LS_MAIN>-BANFN
                                                                                            BNFPO = <LS_MAIN>-BNFPO
                                                                                            BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-EBELN = LS_COLLECT_EKPO-EBELN.
      <LS_MAIN>-EBELP = LS_COLLECT_EKPO-EBELP.
      <LS_MAIN>-GRQTY = LS_COLLECT_EKPO-WEMNG.
      <LS_MAIN>-MEINS2 = LS_COLLECT_EKPO-MEINS.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0500 .

  CREATE OBJECT GO_CONTAIN_0500
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER_500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_500 .

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR GO_GRID_0500.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0500 .

  CLEAR GS_LAYOUT_0500.
  GS_LAYOUT_0500-CWIDTH_OPT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0500 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3130TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_500'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0500.
  FREE GT_FIELDCAT_0500.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0500[]
    TABLES
      IT_DATA         = GT_DISP_500
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BADAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청일'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'BANFN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'PR 번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'PR Item 번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'LIFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '업체내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청 수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납기일'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BIGO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기타사향(메모)'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'PO 번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'PO Item 번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GRQTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS2'.
      WHEN 'MEINS2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고단위'.
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0500 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
*                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0500_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0500_DISPLAY .

  CALL METHOD GO_GRID_0500->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0500
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0500
    CHANGING
      IT_OUTTAB            = GT_DISP_500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_filter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FILTER .

  DATA : LR_CONTROL TYPE REF TO ZCL_SALV_GRZ_CONTROLLER.
  DATA: LT_FILTERED TYPE LVC_T_FILT.

  CREATE OBJECT LR_CONTROL
    EXPORTING
      R_MASTER = GO_GRID_0100.                 " ALV List Viewer

  LR_CONTROL->IF_SALV_GUI_GRID_BRIDGE_CALLS~FILTER_TABLE(
    EXPORTING
      I_CALLED_BY_CONTEXT_MENU = ABAP_TRUE
    EXCEPTIONS
      NO_CHANGE                = 1
      OTHERS                   = 2
  ).
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LT_FILTERED = LR_CONTROL->MT_FITER_T.

  GO_GRID_0100->SET_FILTER_CRITERIA(
    EXPORTING
      IT_FILTER                 = LT_FILTERED                 " Filter Conditions
    EXCEPTIONS
      NO_FIELDCATALOG_AVAILABLE = 1                " Instance Variable of Field Catalog not yet Set
      OTHERS                    = 2
  ).

  PERFORM REFRESH_GRID USING GO_GRID_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILTER_IDNRK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILTER_IDNRK .

  CHECK NOT ( S_IDNRK[] IS INITIAL AND S_MAKT2[] IS INITIAL ) . " 원자재나 원자재 내역에 값이 있을경우만 필터링

  DATA : LV_INDEX TYPE I.

  SORT GT_MAKT3 BY MATNR.

  LOOP AT GT_DISP INTO DATA(LS_DISP).
    LV_INDEX = SY-TABIX.
    READ TABLE GT_MAKT3 TRANSPORTING NO FIELDS WITH KEY MATNR = LS_DISP-MATNR_R BINARY SEARCH.
    IF SY-SUBRC NE 0.
      DELETE GT_DISP INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.



ENDFORM.
