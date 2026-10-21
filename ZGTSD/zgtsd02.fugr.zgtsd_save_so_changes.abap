FUNCTION ZGTSD_SAVE_SO_CHANGES .
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HDR) TYPE  ZGTSDT1013 OPTIONAL
*"     VALUE(IV_TRTYP) TYPE  TRTYP OPTIONAL
*"  TABLES
*"      IT_RJT_ITM STRUCTURE  ZGTSDT1014 OPTIONAL
*"----------------------------------------------------------------------
  DATA : LS_CDHDR   TYPE CDHDR,
         LV_VBELN   TYPE VBAK-VBELN,
         LV_FOUND   TYPE ABAP_BOOL,
         LV_CHGNENR TYPE CHAR10,
         LT_1013    TYPE TABLE OF ZGTSDT1013.

  CONSTANTS : LC_OBJECTCLAS TYPE CDOBJECTCL VALUE 'VERKBELEG'.

  LV_VBELN = IS_HDR-VBELN.

  IF IT_RJT_ITM[] IS NOT INITIAL.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR             = '03'
        OBJECT                  = 'ZGTSD_DOCN'
      IMPORTING
        NUMBER                  = LV_CHGNENR
      EXCEPTIONS
        INTERVAL_NOT_FOUND      = 1
        NUMBER_RANGE_NOT_INTERN = 2
        OBJECT_NOT_FOUND        = 3
        QUANTITY_IS_0           = 4
        QUANTITY_IS_NOT_1       = 5
        INTERVAL_OVERFLOW       = 6
        BUFFER_OVERFLOW         = 7
        OTHERS                  = 8.

    LOOP AT IT_RJT_ITM.
      IT_RJT_ITM-CHANGENR = LV_CHGNENR.
      MODIFY IT_RJT_ITM.
    ENDLOOP.

  ENDIF.

  CASE IV_TRTYP.
    WHEN 'H'.         "생성

      APPEND IS_HDR TO LT_1013.

      TRY.
          INSERT ZGTSDT1013 FROM TABLE LT_1013 ACCEPTING DUPLICATE KEYS.
        CATCH CX_ROOT INTO DATA(LO_EX).
          MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1013 UDATE Error!.'.
      ENDTRY.

      TRY.
          INSERT ZGTSDT1014 FROM TABLE IT_RJT_ITM ACCEPTING DUPLICATE KEYS.
        CATCH CX_ROOT INTO LO_EX.
          MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1014 UDATE Error!.'.
      ENDTRY.

    WHEN 'V'.         "변경


*  "가장 최근 변경문서 헤더를 후보로 조회 (동일 사용자/TCODE/오브젝트)
      WITH +CONFIG AS ( SELECT FLD_05 AS TABNAME, "통제 테이블
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

           +CDPOS AS ( SELECT A~*
                         FROM CDPOS AS A INNER JOIN +CONFIG AS B
                           ON A~FNAME   = B~FNAME
                          AND A~TABNAME = B~TABNAME
                        WHERE A~OBJECTCLAS EQ @LC_OBJECTCLAS ),

           +CDHDR AS (  SELECT *
                         FROM CDHDR
                        WHERE OBJECTCLAS = 'VERKBELEG'
                          AND OBJECTID    = @LV_VBELN
                          AND UDATE       = @IS_HDR-AEDAT
                          AND USERNAME    = @IS_HDR-AENAM
*                          AND TCODE       = @SY-TCODE
                          AND UTIME       = ( SELECT MAX( UTIME )
                                                 FROM CDHDR
                                                 WHERE OBJECTCLAS = 'VERKBELEG'
                                                   AND OBJECTID    = @LV_VBELN
                                                   AND UDATE       = @IS_HDR-AEDAT
                                                   AND USERNAME    = @IS_HDR-AENAM )
*                                                   AND TCODE       = @SY-TCODE )
                          AND CHANGENR NOT IN ( SELECT DISTINCT CHANGENR
                                                  FROM ZGTSDT1013
                                                 WHERE VBELN = @LV_VBELN )
                      )
      SELECT SINGLE A~*
        FROM +CDHDR AS A INNER JOIN +CDPOS AS B
          ON A~OBJECTCLAS = B~OBJECTCLAS
         AND A~OBJECTID   = B~OBJECTID
         AND A~CHANGENR   = B~CHANGENR
        INTO CORRESPONDING FIELDS OF @LS_CDHDR.
      IF SY-SUBRC = 0.
*        "후보 검증: CDPOS에 실제 아이템이 존재하는가?
*        SELECT SINGLE @ABAP_TRUE
*          FROM CDPOS
*          WHERE CHANGENR = @LS_CDHDR-CHANGENR
*            AND OBJECTID = @LV_VBELN
*          INTO @LV_FOUND.
*
*        IF LV_FOUND = ABAP_TRUE.
*          "중복 방지: 동일 키 존재 시 무시

        IS_HDR-CHANGENR = LS_CDHDR-CHANGENR.
        APPEND IS_HDR TO LT_1013.

*          LOOP AT IT_RJT_ITM.
*            IT_RJT_ITM-CHANGENR = LS_CDHDR-CHANGENR.
*            MODIFY IT_RJT_ITM.
*          ENDLOOP.

        TRY.
            INSERT ZGTSDT1013 FROM TABLE LT_1013 ACCEPTING DUPLICATE KEYS.
          CATCH CX_ROOT INTO LO_EX.
            MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1013 UDATE Error!.'.
        ENDTRY.

*          TRY.
*              IF IT_RJT_ITM[] IS NOT INITIAL.
*                INSERT ZGTSDT1014 FROM TABLE IT_RJT_ITM ACCEPTING DUPLICATE KEYS.
*              ENDIF.
*            CATCH CX_ROOT INTO LO_EX.
*              MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1014 UDATE Error!.'.
*          ENDTRY.

*        ENDIF.

      ELSE.

        IF IT_RJT_ITM[] IS NOT INITIAL.
          IS_HDR-CHANGENR = LV_CHGNENR.
          APPEND IS_HDR TO LT_1013.

          TRY.
              INSERT ZGTSDT1013 FROM TABLE LT_1013 ACCEPTING DUPLICATE KEYS.
            CATCH CX_ROOT INTO LO_EX.
              MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1013 UDATE Error!.'.
          ENDTRY.
        ENDIF.

      ENDIF.

  ENDCASE.

  CHECK IT_RJT_ITM[] IS NOT INITIAL.
  TRY.
      INSERT ZGTSDT1014 FROM TABLE IT_RJT_ITM ACCEPTING DUPLICATE KEYS.
    CATCH CX_ROOT INTO LO_EX.
      MESSAGE S000(ZGTSD01) WITH 'ZGTSDT1014 UDATE Error!.'.
  ENDTRY.


ENDFUNCTION.
