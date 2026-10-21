FUNCTION ZGTSD_IF_I_SO_CHANGES_HISTORY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"     VALUE(I_DISPMODE) TYPE  ZGTEFLAG OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN OPTIONAL
*"     VALUE(I_ZPJNO) TYPE  ZPJNO OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      ET_LIST STRUCTURE  ZGTSDSIF1013 OPTIONAL
*"      ET_CHNG STRUCTURE  ZGTSDSIF1014 OPTIONAL
*"      ET_ABGRU STRUCTURE  ZGTSDSIF1015 OPTIONAL
*"----------------------------------------------------------------------

  INCLUDE ZSDC0000.

  DATA      : LV_MSG   TYPE CHAR200,
              LV_ZPJNO TYPE ZPJNO,
              LT_SO    LIKE TABLE OF GS_SO_HIS.

  CONSTANTS : LC_OBJECTCLAS TYPE CDOBJECTCL VALUE 'VERKBELEG'.

  RANGES    : LR_VKBUR   FOR VBAK-VKBUR,
              LR_ZPJNO   FOR ZGTSDT1011-ZPJNO,
              LR_VBELN   FOR VBAK-VBELN.

  CLEAR : ES_RETURN, ET_CHNG, ET_CHNG[], LV_ZPJNO, LV_MSG, ET_ABGRU, ET_ABGRU[],
          GS_SO_HIS.
*-----------------------------------------------------------------------
*-- Import 값 정합성 체크
*-----------------------------------------------------------------------

  IF IS_D365_LOGIN-ENAME IS INITIAL.
    MESSAGE S007(ZGTSD01) WITH TEXT-E12 INTO LV_MSG.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  IF I_DISPMODE IS INITIAL.
    MESSAGE S007(ZGTSD01) WITH TEXT-E14 INTO LV_MSG.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  IF I_ZPJNO IS NOT INITIAL.
    IF I_ZPJNO(2) NE 'PD'.
      LV_ZPJNO = I_ZPJNO(8) && `*`.
      __RNG LR_ZPJNO 'I' 'CP' LV_ZPJNO ''.
    ELSE.
      LV_ZPJNO = I_ZPJNO.
      __RNG LR_ZPJNO 'I' 'EQ' LV_ZPJNO ''.
    ENDIF.
  ENDIF.


  IF I_VBELN IS NOT INITIAL.
    __RNG LR_VBELN 'I' 'EQ' I_VBELN ''.
  ENDIF.

  CASE I_DISPMODE.

    WHEN ZGTSD_A. " 주문 목록 조회

      IF I_ZPJNO IS  INITIAL.
        MESSAGE S007(ZGTSD01) WITH TEXT-E02 INTO LV_MSG.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.

      WITH +MAX_1013 AS (
        SELECT MAX( ZSEQNO ) AS ZSEQNO,
               VBELN
          FROM ZGTSDT1013
         WHERE ZPJNO IN @LR_ZPJNO
           AND VBELN IN @LR_VBELN
         GROUP BY VBELN
      ),
      +MAX_CHR AS (
        SELECT MAX( B~CHANGENR ) AS CHANGENR,
               B~VBELN, B~ZSEQNO
          FROM +MAX_1013 AS A INNER JOIN ZGTSDT1013 AS B
            ON A~ZSEQNO = B~ZSEQNO
           AND A~VBELN  = B~VBELN
         GROUP BY B~VBELN, B~ZSEQNO
      ),
      +SO_1013 AS (
        SELECT B~ZSEQNO, B~VBELN, B~ERDAT,
               B~TRTYP, B~ERNAM, B~APPROVED_STATUS,
               MAX( B~CHANGENR ) AS CHANGENR
          FROM +MAX_CHR AS A INNER JOIN ZGTSDT1013 AS B
            ON A~ZSEQNO = B~ZSEQNO
           AND A~VBELN  = B~VBELN
           AND A~CHANGENR  = B~CHANGENR
         GROUP BY B~ZSEQNO, B~VBELN, B~ERDAT, B~TRTYP, B~ERNAM, B~APPROVED_STATUS
         ORDER BY B~ERDAT ASCENDING
      )
      SELECT A~ZSEQNO, A~VBELN, B~BSTNK AS BSTKD, A~TRTYP,
             A~APPROVED_STATUS, A~ERDAT AS REJECTED_DATE, C~NAME
        FROM +SO_1013 AS A INNER JOIN VBAK AS B
          ON A~VBELN EQ B~VBELN
         AND B~VKORG EQ @IS_D365_LOGIN-VKORG
        LEFT OUTER JOIN ZGTMM_CV_GETUSERNAME AS C
          ON B~ERNAM = C~USERID
       ORDER BY A~ZSEQNO, A~VBELN, A~ERDAT
        INTO CORRESPONDING FIELDS OF TABLE @ET_LIST.

      IF SY-SUBRC EQ 0.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_S MESSAGE = TEXT-M09 ).
      ELSE.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = TEXT-M10 ).
      ENDIF.

    WHEN ZGTSD_B. "변경 이력 조회

      IF I_VBELN IS INITIAL.
        MESSAGE S007(ZGTSD01) WITH TEXT-E13 INTO LV_MSG.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.

      WITH +RJCT_SO  AS ( SELECT A~ZSEQNO, A~VBELN, A~CHANGENR, A~TRTYP, A~APPROVED_STATUS
                            FROM ZGTSDT1013 AS A
                           WHERE A~VBELN EQ @I_VBELN
                             AND A~CHANGENR NE @SPACE
*                             AND A~APPROVED_STATUS IN  ( @ZGTSD_A, @ZGTSD_T, @ZGTSD_P ) ),"작성 전, 임시저장, 진행 중
                             AND A~ZSEQNO EQ ( SELECT MAX( ZSEQNO )
                                                FROM ZGTSDT1013
                                               WHERE VBELN = @I_VBELN )
                             AND A~APPROVED_STATUS NE @ZGTSD_C ),"완료

           +CONFIG   AS ( SELECT FLD_05 AS TABNAME, "통제 테이블
                                 FLD_07 AS FNAME,   "통제 필드
                                 FLD_03 AS ZLEVEL   "헤더/아이템 구분
                            FROM ZGTPPT1010
                           WHERE MODULE_KIND EQ 'SD'
                             AND CODEGRP     EQ '5009'
                             AND FLD_09      EQ 'Y'   "통제여부
                             AND FLD_10 LE @SY-DATUM  "시작일
                             AND FLD_11 GE @SY-DATUM  "종료일
                             AND FLD_12   EQ 'X'
                           ORDER BY FLD_03, FLD_05, FLD_07 ),          "에너지주문통제 해당여부

          +FLD_TXT    AS ( SELECT A~TABNAME, A~FNAME, C~DDTEXT AS FLDTXT,  A~ZLEVEL
                             FROM +CONFIG AS A LEFT OUTER JOIN DD03L AS B
                               ON A~TABNAME EQ B~TABNAME
                              AND A~FNAME   EQ B~FIELDNAME
                             LEFT OUTER JOIN DD04T AS C
                               ON B~ROLLNAME   EQ C~ROLLNAME
                              AND C~DDLANGUAGE EQ @SY-LANGU ),

          +CDPOS     AS ( SELECT A~*, B~ZLEVEL, B~FLDTXT,
                                CAST(
                                      CASE WHEN A~TABNAME = 'VBAP' OR
                                                A~TABNAME = 'VBKD' OR
                                                A~TABNAME = 'VBEP'

                                           THEN SUBSTRING( A~TABKEY, 14, 6 )
                                           WHEN A~TABNAME = 'KONVC'
                                           THEN SUBSTRING( A~TABKEY, 1, 6 )
                                           ELSE '000000'
                                      END AS NUMC( 6 ) ) AS POSNR
                            FROM CDPOS AS A INNER JOIN +FLD_TXT AS B
                              ON A~FNAME   = B~FNAME
                             AND A~TABNAME = B~TABNAME
                           WHERE A~OBJECTCLAS EQ @LC_OBJECTCLAS
                             AND A~OBJECTID EQ @I_VBELN )

     SELECT A~ZSEQNO,   A~VBELN,  A~APPROVED_STATUS, A~TRTYP,
            B~TABNAME,  B~FNAME,  B~CHNGIND,  B~VALUE_OLD, B~VALUE_NEW,
            B~FLDTXT,   B~ZLEVEL, B~CUKY_NEW, B~CUKY_OLD,  B~TABKEY,
            A~CHANGENR, C~UDATE,  C~UTIME,    C~TCODE,
            C~USERNAME AS USERID,
            G~NAME1    AS USERNAME, B~POSNR
*            CAST( '000000' AS NUMC( 6 ) )  AS FPLTR,
*            CAST( @SPACE AS CHAR( 2 ) ) AS ABGRU
       FROM +RJCT_SO AS A LEFT OUTER JOIN +CDPOS AS B
                                       ON A~VBELN       EQ B~OBJECTID
                                      AND A~CHANGENR    EQ B~CHANGENR

                           LEFT OUTER JOIN CDHDR AS C
                                        ON B~OBJECTCLAS EQ C~OBJECTCLAS
                                       AND B~OBJECTID   EQ C~OBJECTID
                                       AND B~CHANGENR   EQ C~CHANGENR

                           LEFT OUTER JOIN VBPA AS F
                                        ON A~VBELN      EQ F~VBELN
                                       AND F~PARVW      EQ 'VE'

                           LEFT OUTER JOIN LFA1 AS G
                                        ON F~LIFNR      EQ G~LIFNR

        INTO CORRESPONDING FIELDS OF TABLE @LT_SO.

      IF SY-SUBRC EQ 0.
**********************************************************************
*거부사유, 청구계획번호등 기타 데이터
**********************************************************************
        PERFORM MAKE_DATA_SO_HISTORY TABLES LT_SO.
**********************************************************************

        ET_CHNG[] = CORRESPONDING #( LT_SO ).
        SORT ET_CHNG BY ZSEQNO VBELN POSNR FNAME UDATE ASCENDING UTIME ASCENDING.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_S MESSAGE = TEXT-M09 ).
      ELSE.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = TEXT-M10 ).
      ENDIF.


    WHEN ZGTSD_C.

      IF I_VBELN IS INITIAL.
        MESSAGE S007(ZGTSD01) WITH TEXT-E13 INTO LV_MSG.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = LV_MSG ).
        PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
        EXIT.
      ENDIF.

      WITH +Z10130 AS (
                        SELECT A~*
                          FROM ZGTSDT1013 AS A
                         WHERE A~VBELN EQ @I_VBELN
                           AND A~ZSEQNO = ( SELECT MAX( ZSEQNO )
                                              FROM ZGTSDT1013
                                             WHERE VBELN = @I_VBELN ) )

      SELECT A~ZSEQNO, C~CHANGENR, A~VBELN, A~APPROVED_STATUS,
             C~POSNR, C~ABGRU, BEZEI
        FROM ZGTSDT1014 AS C INNER JOIN +Z10130 AS A
          ON C~VBELN    = A~VBELN
         AND C~ZSEQNO   = A~ZSEQNO
        LEFT OUTER JOIN TVAGT AS B
          ON C~ABGRU = B~ABGRU
         AND B~SPRAS = @SY-LANGU
       WHERE C~VBELN EQ @I_VBELN
        INTO TABLE @DATA(LT_1014).
      IF SY-SUBRC NE 0.
        SELECT A~* INTO CORRESPONDING FIELDS OF TABLE @LT_1014
          FROM ZGTSDT1013 AS A
         WHERE A~VBELN EQ @I_VBELN
           AND A~ZSEQNO = ( SELECT MAX( ZSEQNO ) FROM ZGTSDT1013 WHERE VBELN = @I_VBELN ).
      ENDIF.

      SORT LT_1014 BY ZSEQNO VBELN POSNR ASCENDING CHANGENR DESCENDING.
      DELETE ADJACENT DUPLICATES FROM LT_1014 COMPARING ZSEQNO VBELN POSNR .

      LOOP AT LT_1014 ASSIGNING FIELD-SYMBOL(<LS_1014>) WHERE APPROVED_STATUS = 'R'.
        <LS_1014>-BEZEI = <LS_1014>-ABGRU = SPACE.
      ENDLOOP.

      ET_ABGRU[] = CORRESPONDING #( LT_1014[] ).
      IF ET_ABGRU[] IS NOT INITIAL.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_S MESSAGE = TEXT-M09 ).
      ELSE.
        ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = TEXT-M10 ).
      ENDIF.
  ENDCASE.
  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.


ENDFUNCTION.
