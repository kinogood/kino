*&---------------------------------------------------------------------*
*& Include          ZGTPBR0020_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_so_mapping_data
*&---------------------------------------------------------------------*
*& 거래명세서 출력 정보 기준 견적품 정보 추가 구성
*&---------------------------------------------------------------------*
*&      --> PT_LIST  : 기존 거래명세서 출력 리스트 정보
*&      --> PT_QLIST : 견적품 정보 추가 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM GET_SO_MAPPING_DATA  TABLES   PT_LIST  LIKE GT_QLIST[]
                                   PT_QLIST LIKE GT_QLIST[].

  DATA : LT_LIST  LIKE TABLE OF GT_QLIST WITH EMPTY KEY,

         LS_QLIST LIKE LINE OF GT_QLIST,

         LV_CNT   TYPE I,
         LV_VGPOS TYPE VGPOS.

  CLEAR : PT_QLIST, PT_QLIST[].

  LT_LIST[]  = CORRESPONDING #( PT_LIST[] ).

*-----------------------------------------------------------------------
*-- 판매오더 정보 기준 견적품 정보 Select
*-----------------------------------------------------------------------
*-- 판매오더 기준 견적품 정보 Select
*  WITH +SO_INFO AS ( SELECT A~VGBEL, A~VGPOS,
*                            A~VBELN, A~POSNR
*                       FROM @LT_LIST AS A )
**                      GROUP BY A~VGBEL, A~VGPOS )
*
*    SELECT A~VBELN,  A~POSNR,  A~QCODE,  A~QNAME,  A~QNAME_PRNT,
*           A~QQTY,   A~QUNIT,  B~VBELN AS VBELN_J, B~POSNR AS POSNR_J
*
*      FROM ZGTSDT0066 AS A INNER JOIN +SO_INFO AS B
*                              ON A~VBELN EQ B~VGBEL
*                             AND A~POSNR EQ B~VGPOS
*     ORDER BY A~VBELN, A~POSNR
*
*      INTO TABLE @DATA(LT_QUOTE).

  WITH +SO_INFO AS ( SELECT A~VGBEL, A~VGPOS,
                            A~VBELN, A~POSNR
                       FROM @LT_LIST AS A ),

       +CHARG AS ( SELECT DISTINCT B~VBELN, B~CHARG, B~MATNR, B~VGBEL, B~VGPOS,
                          CASE WHEN B~UECHA IS NOT NULL THEN B~UECHA ELSE B~POSNR END AS POSNR
                     FROM +SO_INFO AS A INNER JOIN LIPS AS B
                       ON A~VGBEL = B~VGBEL
                      AND A~VGPOS = B~VGPOS
                    WHERE B~LFIMG > 0  ),

      +QTY_67 AS ( SELECT D~VBELN, D~POSNR, A~VGBEL, A~VGPOS, QCODE, SUM( C~QQTY ) AS QQTY
                     FROM +SO_INFO AS A INNER JOIN +CHARG AS D
                       ON A~VBELN = D~VBELN
                      AND A~POSNR = D~POSNR
                    INNER JOIN MCH1 AS B
                       ON B~CHARG = D~CHARG
                      AND B~MATNR = D~MATNR
                    INNER JOIN ZGTSDT0067 AS C
                       ON C~JOB_NO = B~ZZJOB_NO
                      AND C~LINE_NO = B~ZZLINE_NO
                      AND C~SERIAL_INFO = B~ZZSERIAL_INFO
                    GROUP BY A~VGBEL, A~VGPOS, D~VBELN, D~POSNR, QCODE ),

     +QTY_66 AS ( SELECT A~VBELN,  A~POSNR,  A~QCODE,  A~QNAME,  A~QNAME_PRNT,
                         A~QUNIT,  B~VBELN AS VBELN_J, B~POSNR AS POSNR_J, QQTY
                    FROM ZGTSDT0066 AS A INNER JOIN +SO_INFO AS B
                      ON A~VBELN EQ B~VGBEL
                     AND A~POSNR EQ B~VGPOS )

    SELECT A~VBELN,  A~POSNR,  A~QCODE,  A~QNAME,  A~QNAME_PRNT,
           A~QUNIT,  A~VBELN_J, A~POSNR_J,
           CASE WHEN C~QQTY > 0 THEN C~QQTY ELSE A~QQTY END AS QQTY
      FROM +QTY_66 AS A LEFT OUTER JOIN +QTY_67 AS C
        ON A~VBELN = C~VGBEL
       AND A~POSNR = C~VGPOS
       AND A~QCODE = C~QCODE
       AND A~VBELN_J = C~VBELN
     ORDER BY A~VBELN, A~POSNR

      INTO TABLE @DATA(LT_QUOTE).

*-- 견적품코드 기준 GP Flag 정보 Select
  WITH +PROD_CD AS ( SELECT A~QCODE
                       FROM @LT_QUOTE AS A
                      GROUP BY A~QCODE )

    SELECT B~QCODE,  A~FLD_03
      FROM ZGTPPT1010 AS A INNER JOIN +PROD_CD AS B
                              ON A~MODULE_KIND EQ 'SD'
                             AND A~CODEGRP     EQ '0060'
                             AND A~FLD_01      EQ B~QCODE
     ORDER BY B~QCODE

       INTO TABLE @DATA(LT_GP_FLG).

  SORT PT_LIST BY VGBEL VGPOS VBELN POSNR .

*-----------------------------------------------------------------------
*-- 견적품 정보 Mapping & 리스트 구성
*-----------------------------------------------------------------------
*-- 판매오더 품목 기준 견적품 정보 확이 & 추가 구성  <-- 견적품 정보 없는 리스트 제외
  LOOP AT LT_QUOTE INTO DATA(LS_QUOTE)
                   GROUP BY ( VBELN = LS_QUOTE-VBELN
                              POSNR = LS_QUOTE-POSNR
                              VBELN_J = LS_QUOTE-VBELN_J
                              POSNR_J = LS_QUOTE-POSNR_J
                              SIZE  = GROUP SIZE )
                   ASSIGNING FIELD-SYMBOL(<LF_QUOTE_GRP>).
    CLEAR LV_CNT.

    LOOP AT GROUP <LF_QUOTE_GRP>
                  ASSIGNING FIELD-SYMBOL(<LF_QUOTE_LST>).
*-- 견적품 추가 이전 판매오더 품목 정보 기준 견적품 Mapping 정보 Read
      READ TABLE PT_LIST WITH KEY VGBEL = <LF_QUOTE_LST>-VBELN
                                  VGPOS = <LF_QUOTE_LST>-POSNR
                                  VBELN = <LF_QUOTE_LST>-VBELN_J
                                  POSNR = <LF_QUOTE_LST>-POSNR_J

                         BINARY SEARCH INTO DATA(LS_LIST).

      IF SY-SUBRC EQ 0.
        LV_VGPOS = COND #( WHEN LV_CNT GT 0 THEN LS_LIST-VGPOS + LV_CNT
                           ELSE LS_LIST-VGPOS ).

        LS_QLIST = CORRESPONDING #( LS_LIST ).

        LS_QLIST = VALUE #( BASE LS_QLIST
                            VGPOS      = LV_VGPOS                   " 판매오더 품목코드
                            PROD_CD    = <LF_QUOTE_LST>-QCODE       " 견적품코드
                            PROD       = <LF_QUOTE_LST>-QNAME       " 견적품명
                            QQTY       = <LF_QUOTE_LST>-QQTY        " 견적품 물량
                            QUNIT      = <LF_QUOTE_LST>-QUNIT       " 견적품 단위
                            QNAME_PRNT = <LF_QUOTE_LST>-QNAME_PRNT  " 견적품 출력명
                          ).

*-- 견적품 코드 기준 GP Flag 정보 구성
        READ TABLE LT_GP_FLG WITH KEY QCODE = <LF_QUOTE_LST>-QCODE
                             INTO DATA(LS_GP_FLG).
        IF SY-SUBRC EQ 0.
          LS_QLIST-GP_FLAG = LS_GP_FLG-FLD_03.
        ELSE.
          LS_QLIST-GP_FLAG = 'D'.
        ENDIF.

        APPEND LS_QLIST TO PT_QLIST.

        ADD 1 TO LV_CNT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_data_VBELN
*&---------------------------------------------------------------------*
*  납품문서 기준 신규 발행 정보 Select
*----------------------------------------------------------------------*
*      <--PT_LIST    : 납품문서 기준 신규 발행 리스트 정보 리턴
*----------------------------------------------------------------------*
FORM GET_DATA_VBELN  CHANGING PT_LIST TYPE GTY_T_LIST.

  CLEAR PT_LIST.

  WITH +MAIN     AS ( SELECT X~KUNNR, X~WADAT_IST, X~ROUTE, X~LFART,          "--> 조회조건 기준 계산서 발행 대상 납품 리스트
                             X~VSART, X~VBTYP,     X~VSTEL, X~KUNAG,
                             Y~VBELN, Y~POSNR, Y~WERKS, Y~MATNR, Y~ARKTX,
                             Y~LFIMG, Y~VRKME, Y~CHARG, Y~MEINS, Y~VGBEL,
                             Y~VGPOS, Y~UMVKZ, Y~UMVKN, Y~VKBUR, Y~VKGRP,
                             Y~VTWEG
                        FROM LIKP AS X INNER JOIN LIPS AS Y
                                          ON X~VBELN EQ Y~VBELN
                       WHERE X~VBELN     IN @S_VBELN
                         AND X~LFART     IN @R_LFART
                         AND X~VSTEL     IN @S_VSTEL
                         AND X~VSTEL     IN @R_VSTEL
                         AND X~WADAT_IST IN @S_WADAT
                         AND X~KUNNR     IN @S_KUNNR
                         AND X~ERNAM     IN @S_ERNAM
                         AND X~ROUTE     IN @S_ROUTE
                         AND X~ROUTE     NOT IN ('01-001', '02-001')
                         AND X~ZOUT      IN @R_OUTYN "'Y'
                         AND Y~VKBUR     IN @S_VKBUR
                         AND Y~VKGRP     IN @S_VKGRP
                         AND Y~VTWEG     IN @S_VTWEG
                         AND X~WBSTK     EQ 'C'
                         AND Y~UECHA     EQ '000000'
                         AND X~VSART     IN @S_VSART ),

       +DO_INFO  AS ( SELECT A~VBELN                                          "--> 납품문서 기준 구성
                        FROM +MAIN AS A
                       GROUP BY A~VBELN ),

       +ISSUE    AS ( SELECT B~VBELN                                          "--> 납품문서 기준 거래명세서 발급 납품문서 정보
                        FROM ZLET0005 AS A INNER JOIN ZLET0006 AS B
                                              ON A~IV_NO EQ B~IV_NO
                                           INNER JOIN +DO_INFO AS C
                                              ON B~VBELN EQ C~VBELN
                       WHERE A~IV_PRINT_YN  EQ @ABAP_TRUE
                         AND A~IV_CANCEL_YN EQ @ABAP_FALSE
                         AND A~IV_TYPE     NE 'L01'       " 수출컨테이너 재고이전 제외
                        GROUP BY B~VBELN ),

       +SHIP     AS ( SELECT B~VBELN                                          "--> 납품문서 기준 선적문재 존재 여부 확인
                        FROM VTTK AS A INNER JOIN VTTP AS B
                                          ON A~TKNUM EQ B~TKNUM
                                       INNER JOIN +DO_INFO AS C
                                          ON B~VBELN EQ C~VBELN
                       WHERE A~SHTYP NE 'Z103'
                      GROUP BY B~VBELN ),

       +LIST     AS ( SELECT A~KUNNR, A~WADAT_IST, A~ROUTE, A~LFART,          "---> 거래명세서 발급 여부 추가 리스트
                             A~VSART, A~VBTYP,     A~VSTEL, A~KUNAG,
                             A~VBELN, A~POSNR, A~WERKS, A~MATNR, A~ARKTX,
                             A~LFIMG, A~VRKME, A~CHARG, A~MEINS, A~VGBEL,
                             A~VGPOS, A~UMVKZ, A~UMVKN, A~VKBUR, A~VKGRP,
                             A~VTWEG,

                             CASE WHEN B~VBELN IS NOT NULL THEN @ABAP_TRUE
                                  ELSE @ABAP_FALSE
                             END AS ISSUE_FLG,

                             CASE WHEN C~VBELN IS NOT NULL THEN @ABAP_TRUE
                                  ELSE @ABAP_FALSE
                             END AS SHIP_FLG

                        FROM +MAIN AS A LEFT OUTER JOIN +ISSUE AS B
                                                ON A~VBELN EQ B~VBELN
                                        LEFT OUTER JOIN +SHIP AS C
                                                ON A~VBELN EQ C~VBELN )

    SELECT A~KUNNR, A~WADAT_IST, A~ROUTE, A~LFART,
           A~VSART, A~VBTYP,     A~VSTEL, A~KUNAG,
           A~VBELN, A~POSNR, A~WERKS, A~MATNR, A~ARKTX,
           A~LFIMG, A~VRKME, A~CHARG, A~MEINS, A~VGBEL,
           A~VGPOS, A~UMVKZ, A~UMVKN, A~VKBUR, A~VKGRP,
           A~VTWEG

      FROM +LIST AS A
     WHERE A~ISSUE_FLG NE @ABAP_TRUE            " 거래명세서 발행리스트 제외
       AND A~SHIP_FLG  NE @ABAP_TRUE            " 선적문서 존재 리스트 제외

     INTO CORRESPONDING FIELDS OF TABLE @PT_LIST.

ENDFORM.                    " get_data_VBELN
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_TKNUM
*&---------------------------------------------------------------------*
*  선적정보 기준 신규 발행 리스트 정보 Select
*----------------------------------------------------------------------*
*      <-- PT_LIST    : 선적 정보 기준 신규 발행 리스트 정보 리턴
*----------------------------------------------------------------------*
FORM GET_DATA_TKNUM   CHANGING PT_LIST TYPE GTY_T_LIST.

  CLEAR : PT_LIST.

  WITH +MAIN     AS ( SELECT K~TKNUM, K~EXTI2, K~EXTI1, K~TPBEZ,              "--> 선적정보 기준 신규 발행 대상 리스트
                             K~SHTYP, K~TDLNR, K~SDABW,
                             X~KUNNR, X~WADAT_IST, X~ROUTE, X~LFART,
                             X~VSART, X~VBTYP, X~VSTEL, X~KUNAG,
                             Y~VBELN, Y~POSNR, Y~WERKS, Y~MATNR,
                             Y~ARKTX, Y~LFIMG, Y~VRKME, Y~CHARG,
                             Y~MEINS, Y~VGBEL, Y~VGPOS, Y~UMVKZ,
                             Y~UMVKN, Y~VKBUR, Y~VKGRP, Y~VTWEG
                        FROM VTTK AS K INNER JOIN VTTP AS P
                                          ON K~TKNUM EQ P~TKNUM
                                       INNER JOIN LIKP AS X
                                          ON P~VBELN EQ X~VBELN
                                       INNER JOIN LIPS AS Y
                                          ON X~VBELN EQ Y~VBELN
                         WHERE K~TKNUM     IN @S_TKNUM
                           AND K~SHTYP     NOT IN ('Z002', 'Z009', 'Z103')
                           AND P~VBELN     IN @S_VBELN
                           AND X~LFART     IN @R_LFART
                           AND X~VSTEL     IN @S_VSTEL
                           AND X~VSTEL     IN @R_VSTEL
                           AND X~WADAT_IST IN @S_WADAT
                           AND X~KUNNR     IN @S_KUNNR
                           AND X~ERNAM     IN @S_ERNAM
                           AND X~ROUTE     IN @S_ROUTE
                           AND X~ROUTE     NOT IN ('01-001', '02-001')
                           AND X~ZOUT      IN @R_OUTYN  "<> 'Y'
                           AND Y~VKBUR     IN @S_VKBUR
                           AND Y~VKGRP     IN @S_VKGRP
                           AND Y~VTWEG     IN @S_VTWEG
                           AND X~WBSTK     EQ 'C'
                           AND Y~UECHA     EQ '000000'
                           AND X~VSART     IN @S_VSART ),   "출하유형 조건 추가 07.02.05

       +TK_INFO  AS ( SELECT A~VBELN, A~TKNUM                                 "--> 납품, 선적문서 기준 조건 정보 구성
                        FROM +MAIN AS A
                       WHERE A~TKNUM IS NOT INITIAL
                       GROUP BY A~VBELN, A~TKNUM ),

       +DO_INFO  AS ( SELECT A~VBELN                                          "--> 납품문서 기준 구성
                        FROM +MAIN AS A
                       WHERE A~TKNUM IS INITIAL
                          OR A~TKNUM EQ ' '
                       GROUP BY A~VBELN ),

       +ISSUE_TK AS ( SELECT B~VBELN, B~TKNUM                                 "--> 선적정보 기준 거래명세서 발급 납품문서 정보
                        FROM ZLET0005 AS A INNER JOIN ZLET0006 AS B
                                              ON A~IV_NO EQ B~IV_NO
                                           INNER JOIN +TK_INFO AS C
                                              ON B~VBELN EQ C~VBELN
                                             AND B~TKNUM EQ C~TKNUM
                       WHERE A~IV_PRINT_YN  EQ @ABAP_TRUE
                         AND A~IV_CANCEL_YN EQ @ABAP_FALSE
                         AND A~IV_TYPE     NE 'L01'       " 수출컨테이너 재고이전 제외
                        GROUP BY B~VBELN, B~TKNUM ),

       +ISSUE_DO AS ( SELECT B~VBELN                                          "--> 납품문서 기준 거래명세서 발급 납품문서 정보
                        FROM ZLET0005 AS A INNER JOIN ZLET0006 AS B
                                              ON A~IV_NO EQ B~IV_NO
                                           INNER JOIN +DO_INFO AS C
                                              ON B~VBELN EQ C~VBELN
                       WHERE A~IV_PRINT_YN  EQ @ABAP_TRUE
                         AND A~IV_CANCEL_YN EQ @ABAP_FALSE
                         AND A~IV_TYPE     NE 'L01'       " 수출컨테이너 재고이전 제외
                        GROUP BY B~VBELN ),

       +LIST     AS ( SELECT A~TKNUM, A~EXTI2, A~EXTI1, A~TPBEZ,              "--> 거래명세서 발급 여부 추가 리스트
                             A~SHTYP, A~TDLNR, A~SDABW,
                             A~KUNNR, A~WADAT_IST, A~ROUTE, A~LFART,
                             A~VSART, A~VBTYP, A~VSTEL, A~KUNAG,
                             A~VBELN, A~POSNR, A~WERKS, A~MATNR,
                             A~ARKTX, A~LFIMG, A~VRKME, A~CHARG,
                             A~MEINS, A~VGBEL, A~VGPOS, A~UMVKZ,
                             A~UMVKN, A~VKBUR, A~VKGRP, A~VTWEG,

                             CASE WHEN B~TKNUM IS NOT NULL OR C~VBELN IS NOT NULL THEN @ABAP_TRUE
                                  ELSE @ABAP_FALSE
                             END AS ISSUE_FLG
                        FROM +MAIN AS A LEFT OUTER JOIN +ISSUE_TK AS B
                                                ON A~VBELN EQ B~VBELN
                                               AND A~TKNUM EQ B~TKNUM
                                        LEFT OUTER JOIN +ISSUE_DO AS C
                                                ON A~VBELN EQ C~VBELN )

    SELECT A~TKNUM, A~EXTI2, A~EXTI1, A~TPBEZ,
           A~SHTYP, A~TDLNR, A~SDABW,
           A~KUNNR, A~WADAT_IST, A~ROUTE, A~LFART,
           A~VSART, A~VBTYP, A~VSTEL, A~KUNAG,
           A~VBELN, A~POSNR, A~WERKS, A~MATNR,
           A~ARKTX, A~LFIMG, A~VRKME, A~CHARG,
           A~MEINS, A~VGBEL, A~VGPOS, A~UMVKZ,
           A~UMVKN, A~VKBUR, A~VKGRP, A~VTWEG

      FROM +LIST AS A
     WHERE A~ISSUE_FLG NE @ABAP_TRUE            " 거래명세서 발행 리스트 제외

      INTO CORRESPONDING FIELDS OF TABLE @PT_LIST.

ENDFORM.                    " GET_DATA_TKNUM
*&---------------------------------------------------------------------*
*& Form CHECK_GT_PGM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_GT_PGM .

  IF S_WADAT-LOW < '20250601'.
    DATA(LV_SUB) = 'X'.
    IF S_WADAT-HIGH IS NOT INITIAL AND S_WADAT-HIGH > '20250531'.
      MESSAGE S000(ZGTSD01) WITH '부스덕트 자재코드 변환으로 2025.06.01 이전과'
                                 '이후로 나눠서 조회해야 합니다.' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF LV_SUB IS NOT INITIAL.

    SUBMIT ZPBR0020 WITH R01 = R01
                    WITH R02 = R02
                    WITH R03 = R03
                    WITH R_TKNUM = R_TKNUM
                    WITH R_VBELN = R_VBELN
                    WITH R_SO = R_SO
                    WITH R_STO = R_STO
                    WITH R_ALL = R_ALL
                    WITH P_OUT = P_OUT

                    WITH S_WADAT IN S_WADAT
                    WITH S_VSART IN S_VSART
                    WITH S_ROUTE IN S_ROUTE
                    WITH S_KUNNR IN S_KUNNR
                    WITH S_VBELN IN S_VBELN
                    WITH S_TKNUM IN S_TKNUM
                    WITH S_ERNAM IN S_ERNAM
                    WITH S_IV_NO IN S_IV_NO
                    WITH S_DATE  IN S_DATE

                    WITH S_VKBUR  IN S_VKBUR
                    WITH S_VKGRP  IN S_VKGRP
                    WITH S_VTWEG  IN S_VTWEG AND RETURN.
    LEAVE LIST-PROCESSING.
  ENDIF.


ENDFORM.
