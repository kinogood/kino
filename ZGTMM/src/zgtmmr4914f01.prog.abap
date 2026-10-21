*&---------------------------------------------------------------------*
*& Include          ZGTMMR4914F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT.

  PERFORM GET_IFNO.

  CLEAR : S_IFDAT[], S_ERDAT[].
  S_IFDAT[] = S_ERDAT[] = VALUE #( ( SIGN   = GC_I
                                     OPTION = GC_BT
                                     LOW    = SY-DATLO - 1
                                     HIGH   = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IFNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IFNO.

  CLEAR : GT_IFNO[].

  SELECT DISTINCT FLD_01 AS KEY,
                  FLD_02 AS TEXT
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFNO
   WHERE MODULE_KIND = @GC_PP
     AND CODEGRP     = @GC_0010.

  SORT GT_IFNO BY KEY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  CLEAR : GR_GR1[], GR_SNM[].

  CASE 'X'.
    WHEN P_ILOG.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_SND ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT-LOW ) ).

    WHEN P_SEND.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_BUKRS )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_WERKS-LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_ERDAT-LOW ) ).

  ENDCASE.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 IN GR_GR1.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME IN GR_SNM.
      SCREEN-REQUIRED = 2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IFSYT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IFSYT USING PV_ID.

  DATA : LT_IFNO TYPE VRM_VALUES.


  LT_IFNO[] = CORRESPONDING #( GT_IFNO[] ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_IFNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GV_ERR.

  IF ( P_ILOG = GC_X AND   S_IFDAT[] IS INITIAL )
  OR ( P_SEND = GC_X AND ( S_WERKS[] IS INITIAL
                        OR S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL
                        OR P_BUKRS   IS INITIAL ) ).
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GV_CNT.
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_MST_INFO USING 'MM00005'.

  PERFORM MAKE_ITAB.
  CLEAR : <GT_HLIST>, <GT_ILIST>.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

  GV_CNT = LINES( <GT_HLIST> ).

  IF GV_CNT IS NOT INITIAL.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MST_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_MST_INFO USING PV_ID.

  CLEAR : GS_MST.

  SELECT SINGLE FLD_03,
                FLD_04,
                FLD_05
    FROM ZGTMM_CV_GET_IFLIST
    INTO @GS_MST
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0010
     AND FLD_01      = @PV_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB.

  CLEAR    : GV_HNAME,    GV_INAME.
  UNASSIGN : <GT_HLIST>, <GT_ILIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_HNAME = GS_MST-VIEW.   "ZGTMM_CV_ID_IF_LOG_L
      GV_INAME = GC_ZGTMMT9051.

    WHEN P_SEND.
      GV_HNAME = GC_ZGTMMSIF0007.
      GV_INAME = GC_ZGTMMSIF0008.

  ENDCASE.

  PERFORM ASSIGN_ITAB USING 'H' GV_HNAME.
  PERFORM ASSIGN_ITAB USING 'I' GV_INAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GV_HNAME
*&---------------------------------------------------------------------*
FORM ASSIGN_ITAB USING PV_TYPE
                       PV_NAME.

  DATA : LR_DATA  TYPE REF TO DATA.

  FIELD-SYMBOLS : <LS_LIST>.


  DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                       CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( PV_NAME ) ).

  CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
  ASSIGN LR_DATA->* TO <LS_LIST>.
  FREE : LR_DATA.

  CREATE DATA LR_DATA LIKE STANDARD TABLE OF <LS_LIST>.
  CASE PV_TYPE.
    WHEN 'H'.
      ASSIGN LR_DATA->* TO <GT_HLIST>.
    WHEN 'I'.
      ASSIGN LR_DATA->* TO <GT_ILIST>.
  ENDCASE.
  FREE : LR_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_DATA.

  DATA : LV_COND TYPE STRING.


  LV_COND = | IFDAT IN @S_IFDAT AND VBELN IN @S_VBELN |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_FNL IS NOT INITIAL.
    LV_COND = LV_COND && | AND LASTDATA = @GC_X |.
  ENDIF.

  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
    LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
  ENDIF.

  SELECT *
    FROM (GV_HNAME)
    INTO CORRESPONDING FIELDS OF TABLE @<GT_HLIST>
   WHERE (LV_COND).

  CHECK <GT_HLIST> IS NOT INITIAL.
  SORT <GT_HLIST> BY ('ZIFKEY') DESCENDING
                     ('VBELN')  ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_DATA.

  PERFORM GET_CDHDR.
*  CHECK GT_CDHDR[] IS NOT INITIAL. "반도전은 CDHDR에 없음

  PERFORM GET_HDR.
  PERFORM GET_ITM.

  SORT GT_SHDR BY VBELN.
  SORT GT_SITM BY VBELN POSNR.

  PERFORM DEL_FRC.
* PERFORM DEL_HDR.
* PERFORM DEL_ITM.

  <GT_HLIST>[] = CORRESPONDING #( GT_SHDR[] ).
* <GT_ILIST>[] = CORRESPONDING #( GT_SITM[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CDHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CDHDR.

  CLEAR : GT_CDHDR[], GR_VBELN[].

  SELECT OBJECTID
         CHANGENR
    FROM CDHDR
    INTO CORRESPONDING FIELDS OF TABLE GT_CDHDR
   WHERE OBJECTCLAS = GC_LIEFERUNG
     AND UDATE     IN S_ERDAT
     AND OBJECTID LIKE '18%'.
*   INTO TABLE @DATA(LT_CDHDR).

  SORT GT_CDHDR BY OBJECTID ASCENDING CHANGENR DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_CDHDR COMPARING OBJECTID.

  IF S_VBELN[] IS NOT INITIAL.
    DELETE GT_CDHDR WHERE OBJECTID NOT IN S_VBELN.
  ENDIF.

  CHECK GT_CDHDR[] IS NOT INITIAL.

  GR_VBELN[] = VALUE #( FOR LS_CDHDR IN GT_CDHDR
                        ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_CDHDR-OBJECTID ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HDR.

  CLEAR : GT_SHDR[].

  "외주가공 헤더 삭제판단 쿼리
  SELECT VBELN,
         SUM( CASE STATUS WHEN 'C' THEN 1 ELSE 0 END ) AS CNT
    FROM ZMMTI35
   WHERE VBELN IN @S_VBELN
     AND ERDAT IN @S_ERDAT
     AND MATNR <> @SPACE   "추가(25.02.10)
   GROUP BY VBELN
    INTO TABLE @DATA(LT_DEL).

  "Inbound 납품서
  SELECT A~VBELN, A~LIFNR, A~ERDAT,
         B~WERKS, A~LFDAT, @GC_N AS ZDFLG
    FROM LIKP AS A INNER JOIN LIPS AS B
      ON A~VBELN  = B~VBELN
   WHERE A~LFART  = @GC_EL
     AND B~WERKS IN @S_WERKS
     AND A~VBELN IN @S_VBELN
     AND A~ERDAT IN @S_ERDAT
     AND B~MATNR <> @SPACE   "추가(25.02.10)
   GROUP BY A~VBELN, A~LIFNR, A~ERDAT, B~WERKS, A~LFDAT
    INTO TABLE @DATA(LT_SHDR).

  "외주가공 납품서
  SELECT A~VBELN,
         LPAD( A~LIFNR, 10, '0' ) AS LIFNR,
         CASE A~ERDAT WHEN '00000000' THEN A~LFDAT
                                      ELSE A~ERDAT
                                      END AS ERDAT,
         A~WERKS,
         A~LFDAT,
         CASE B~CNT WHEN 0 THEN @GC_D
                           ELSE @GC_N
                           END AS ZDFLG
    FROM ZMMTI34 AS A LEFT OUTER JOIN @LT_DEL AS B
      ON A~VBELN  = B~VBELN
   WHERE A~WERKS IN @S_WERKS
     AND A~VBELN IN @S_VBELN
     AND A~ERDAT IN @S_ERDAT
     AND A~MATNR <> @SPACE   "추가(25.02.10)
APPENDING CORRESPONDING FIELDS OF TABLE @LT_SHDR.

  "e-pro->sap 전송내역중 MES로 전송한 것만(변경정보 체크)
  PERFORM GET_EPRO TABLES LT_SHDR USING 1.
  "e-pro 삭제된 날짜/시간을 못 찾아서 +30일 기준으로 삭제만 찾음(누락현상 있어 중복적용)
  PERFORM GET_EPRO TABLES LT_SHDR USING 2.

* SORT LT_SHDR BY VBELN LIFNR LFDAT ZDFLG. "왜 이렇게 할까?? VBELN면 충분하지 않나?
* DELETE ADJACENT DUPLICATES FROM LT_SHDR
*                       COMPARING VBELN LIFNR LFDAT ZDFLG.
  "꼬리번호별 LFDAT가 상이할 경우, 가장 빠른(작은)날짜를 헤더정보로 남긴다(25.02.11)
  SORT LT_SHDR BY VBELN LIFNR ZDFLG LFDAT.
  DELETE ADJACENT DUPLICATES FROM LT_SHDR
                        COMPARING VBELN LIFNR ZDFLG.

  GT_SHDR[] = VALUE #( FOR LS_HDR IN LT_SHDR
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  CHANGENR = VALUE #( GT_CDHDR[ OBJECTID = LS_HDR-VBELN ]-CHANGENR OPTIONAL ) ) ) ).


************************************************************************
*  CLEAR : GT_SHDR[].
*
*  CHECK GR_VBELN[] IS NOT INITIAL.
*
*  "외주가공 헤더 삭제판단 쿼리
*  SELECT VBELN,
*         SUM( CASE STATUS WHEN 'C' THEN 1 ELSE 0 END ) AS CNT
*    FROM ZMMTI35
*   WHERE VBELN IN @GR_VBELN "S_VBELN
*     AND ERDAT IN @S_ERDAT  "확인?
*   GROUP BY VBELN
*    INTO TABLE @DATA(LT_DEL).
*
*  "Inbound 납품서
*  SELECT A~VBELN, A~LIFNR, A~ERDAT,
*         A~WERKS, A~LFDAT, @GC_N AS ZDFLG
*    FROM LIKP AS A INNER JOIN LIPS AS B
*      ON A~VBELN  = B~VBELN
*   WHERE A~LFART  = @GC_EL
*     AND B~WERKS IN @S_WERKS
*     AND A~VBELN IN @GR_VBELN "S_VBELN
*     AND A~ERDAT IN @S_ERDAT  "확인?
*   GROUP BY A~VBELN, A~LIFNR, A~ERDAT, A~WERKS, A~LFDAT
*    INTO TABLE @DATA(LT_SHDR).
**   INTO CORRESPONDING FIELDS OF TABLE @GT_SHDR.
*
*  "외주가공 납품서
*  SELECT A~VBELN,
*         LPAD( A~LIFNR, 10, '0' ) AS LIFNR,
*         CASE A~ERDAT WHEN '00000000' THEN A~LFDAT
*                                      ELSE A~ERDAT
*                                      END AS ERDAT,
*         A~WERKS,
*         A~LFDAT,
*         CASE B~CNT WHEN 0 THEN @GC_D
*                           ELSE @GC_N
*                           END AS ZDFLG
*    FROM ZMMTI34 AS A LEFT OUTER JOIN @LT_DEL AS B
*      ON A~VBELN  = B~VBELN
*   WHERE A~WERKS IN @S_WERKS
*     AND A~VBELN IN @GR_VBELN "S_VBELN
*     AND A~ERDAT IN @S_ERDAT  "확인?
*APPENDING CORRESPONDING FIELDS OF TABLE @LT_SHDR. "GT_SHDR.
*
*  "e-pro->sap 전송내역중 MES로 전송한 것만(변경정보 체크)
*  PERFORM GET_EPRO TABLES LT_SHDR USING 1.
*  "e-pro 삭제된 날짜/시간을 못 찾아서 +30일 기준으로 삭제만 찾음(누락현상 있어 중복적용)
*  PERFORM GET_EPRO TABLES LT_SHDR USING 2.
*
*  SORT LT_SHDR BY VBELN LIFNR LFDAT ZDFLG. "왜 이렇게 할까?? VBELN면 충분하지 않나?
*  DELETE ADJACENT DUPLICATES FROM LT_SHDR
*                        COMPARING VBELN LIFNR LFDAT ZDFLG.
*
*  GT_SHDR[] = VALUE #( FOR LS_HDR IN LT_SHDR
*                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
*                                  CHANGENR = VALUE #( GT_CDHDR[ OBJECTID = LS_HDR-VBELN ]-CHANGENR OPTIONAL ) ) ) ).
** GT_SHDR[] = CORRESPONDING #( LT_SHDR[] ).
*
** PERFORM EXCEPT_SEND_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SHDR
*&      --> P_1
*&---------------------------------------------------------------------*
FORM GET_EPRO TABLES PT_SHDR
               USING PV_TYPE.

  RANGES : LR_LFDAT FOR ZMMTI11-LFDAT,
           LR_LOEVM FOR ZMMTI11-LOEVM.


  CASE PV_TYPE.
    WHEN 1.
      LR_LFDAT[] = S_ERDAT[].
      LR_LOEVM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_D )
                            ( SIGN = GC_I OPTION = GC_EQ LOW = GC_R ) ).

    WHEN 2.
      LR_LFDAT[] = VALUE #( ( SIGN = GC_I OPTION = GC_BT
                              LOW  = SY-DATUM - 30
                              HIGH = SY-DATUM + 30 ) ).
      LR_LOEVM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_D ) ).

  ENDCASE.

  "기전송된 건만 대상으로(25.02.11)
  SELECT B~VBELN, B~LIFNR, B~LFDAT AS ERDAT,
         B~LFDAT,
         CASE LOEVM WHEN 'C' THEN @GC_N
                    WHEN 'D' THEN @GC_D
                    WHEN 'R' THEN @GC_R
                    ELSE @GC_N
                    END AS ZDFLG
    FROM ZMMTI11 AS B INNER JOIN ZGTMMT9051 AS I
      ON B~VBELN = I~VBELN
   INNER JOIN ZGTMMT9000 AS C
      ON I~ZIFKEY = C~ZIFKEY
   WHERE B~LFDAT    IN @LR_LFDAT
     AND B~VBELN    IN @S_VBELN  "GR_VBELN
     AND B~ZERET     = @GC_00
     AND B~LOEVM    IN @LR_LOEVM
*     AND B~SAPID    <> @SPACE " 공란인 경우도 있어서 주석처리
     AND C~ZIFNO     = @GC_MM00005
     AND C~SYSTEM_ID = @P_IFSYT
     AND C~ZSTAT     = @GC_S
   GROUP BY B~VBELN, B~LIFNR, B~LFDAT, B~LOEVM
APPENDING CORRESPONDING FIELDS OF TABLE @PT_SHDR. "GT_SHDR.


*  "e-pro->sap 전송내역중 MES로 전송한 것만(변경정보 체크)
*  SELECT B~VBELN, B~LIFNR, B~LFDAT AS ERDAT,
*         B~LFDAT,
*         CASE LOEVM WHEN 'C' THEN 'N'
*                    WHEN 'D' THEN 'D'
*                    WHEN 'R' THEN 'R'
*                    ELSE 'N'
*                    END AS ZDFLG
*    FROM ZMMTI11 AS B INNER JOIN ZGTMMT9051 AS C
*      ON B~VBELN = C~VBELN
*   WHERE B~VBELN IN @GR_VBELN "S_VBELN
*     AND B~LFDAT IN @S_ERDAT  "확인?
*     AND B~ZERET  = '00'
*     AND B~LOEVM IN ('R','D')
*     AND B~SAPID <> ' '
*   GROUP BY B~VBELN, B~LIFNR, B~LFDAT, B~LOEVM
*APPENDING CORRESPONDING FIELDS OF TABLE @LT_SHDR. "GT_SHDR.
*
*  "e-pro 삭제된 날짜/시간을 못 찾아서 +30일 기준으로 삭제만 찾음
*  "(누락현상 있어 중복적용)
*  SELECT B~VBELN, B~LIFNR, B~LFDAT AS ERDAT,
*              B~LFDAT,
*            CASE LOEVM
*              WHEN 'C' THEN 'N'
*              WHEN 'D' THEN 'D'
*              WHEN 'R' THEN 'R'
*             ELSE 'N'
*            END  AS ZDFLG
*  FROM ZMMTI11 AS B JOIN ZGTMMT9051 AS C ON B~VBELN = C~VBELN
*  WHERE LFDAT IN @S_UDATE1
*       AND ZERET = '00'
*       AND LOEVM = 'D'
*       AND SAPID <> ' '
*  GROUP BY B~VBELN, B~LIFNR, B~LFDAT, B~LOEVM
*  APPENDING   CORRESPONDING FIELDS OF TABLE @LT_SHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ITM.

  "중복 제거 기준 변경(25.02.11)
  " (기존)VBELN POSNR VGBEL VGPOS LICHN -> (변경)VBELN POSNR
  " NETWR/LICHN/HSDAT/VFDAT : 값을 넣어주지 않는다!

  DATA : BEGIN OF LT_SITM OCCURS 0,
           VBELN      TYPE LIPS-VBELN,
           POSNR      TYPE LIPS-POSNR,
           VGBEL      TYPE LIPS-VGBEL,
           VGPOS      TYPE LIPS-VGPOS,
           MATNR      TYPE LIPS-MATNR,
           MAKTX      TYPE MAKT-MAKTX,
           SPRAS      TYPE MAKT-SPRAS,
           WERKS      TYPE LIPS-WERKS,
           LGORT      TYPE LIPS-LGORT,
           LFIMG      TYPE LIPS-LFIMG,
           MEINS      TYPE LIPS-MEINS,
*          CHARG TYPE LIPS-CHARG,
*          NETWR TYPE LIPS-NETWR,
*          LICHN TYPE ZTAGNR,
*          HSDAT TYPE LIPS-HSDAT,
*          VFDAT TYPE LIPS-VFDAT,
           PSTYP      TYPE EKPO-PSTYP,
           ZDFLG,
           STATUS,
           ITEMSTATUS,
           DISPO      TYPE MARC-DISPO,
         END   OF LT_SITM.

  RANGES : LR_VBELN FOR LIKP-VBELN.


  CLEAR : GT_SITM[].

  CHECK GT_SHDR[] IS NOT INITIAL.

  LR_VBELN[] = VALUE #( FOR LS_HDR IN GT_SHDR
                        ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_HDR-VBELN ) ) ).

* "외주가공 아이템 삭제판단 쿼리 -> 삭제(25.02.12)
* SELECT VBELN, POSNR, TAGNR,
*        SUM( CASE STATUS WHEN 'C' THEN 1 ELSE 0 END ) AS CNT
*   FROM ZMMTI35
*  WHERE VBELN IN @LR_VBELN
*  GROUP BY VBELN, POSNR, TAGNR
*   INTO TABLE @DATA(LT_DEL).

  SELECT B~VBELN,
         B~POSNR,
*        B~ERDAT,
         B~VGBEL,
         B~VGPOS,
         B~MATNR,
         C~MAKTX,
         C~SPRAS,
         B~WERKS,
         B~LGORT,
         B~LFIMG,
         B~VRKME AS MEINS,
*        B~CHARG,
*        B~NETWR,
*        B~LICHN,
*        B~HSDAT,
*        B~VFDAT,
         D~DISPO,          "추가(25.02.13)
         E~PSTYP,          "추가(25.02.13)
         @GC_N   AS ZDFLG  "추가(25.02.12)
    FROM LIKP AS A INNER JOIN LIPS AS B
      ON A~VBELN = B~VBELN
   INNER JOIN MAKT AS C
      ON B~MATNR = C~MATNR
   INNER JOIN MARC AS D
      ON B~MATNR = D~MATNR
     AND B~WERKS = D~WERKS
   INNER JOIN EKPO AS E    "추가(25.02.13)
      ON B~VGBEL             = E~EBELN
     AND RIGHT( B~VGPOS, 5 ) = E~EBELP
*    FOR ALL ENTRIES IN @GT_SHDR
*  WHERE A~VBELN  = @GT_SHDR-VBELN
   WHERE A~VBELN IN @LR_VBELN
     AND B~WERKS IN @S_WERKS
     AND B~LFIMG  > 0
     AND C~SPRAS  = @SY-LANGU
     AND A~LFART  = @GC_EL
     AND ( ( B~XCHPF  = @GC_X AND B~POSNR LIKE @GC_9% )
        OR ( B~XCHPF <> @GC_X AND B~POSNR LIKE @GC_0% ) )
    INTO CORRESPONDING FIELDS OF TABLE @LT_SITM.

  "e-pro inbound 납품서 삭제된 경우만
  SELECT B~VBELN,
         C~POSNR,
         B~VGBEL,
         B~VGPOS,
         B~MATNR,
*        C~LICHN,
         D~DISPO,           "추가(25.02.13)
         E~PSTYP,           "추가(25.02.13)
         B~LOEVM AS ZDFLG
    FROM ZMMTI12 AS B JOIN ZGTMMT9051 AS C
      ON B~VBELN = C~VBELN
     AND B~VGBEL = C~VGBEL
     AND B~VGPOS = C~VGPOS
    JOIN EKPO AS E          "추가(25.02.13)
      ON B~VGBEL             = E~EBELN
     AND RIGHT( B~VGPOS, 5 ) = E~EBELP
    JOIN MARC AS D          "추가(25.02.13)
      ON E~MATNR = D~MATNR
     AND E~WERKS = D~WERKS
*    FOR ALL ENTRIES IN @GT_SHDR
*  WHERE B~VBELN  = @GT_SHDR-VBELN
   WHERE B~VBELN IN @LR_VBELN
     AND B~LOEVM  = @GC_D
     AND C~PSTYP <> @GC_3
APPENDING CORRESPONDING FIELDS OF TABLE @LT_SITM.

  "외주가공 납품서
  SELECT A~VBELN,
         A~POSNR,
         A~EBELN AS VGBEL,
         A~EBELP AS VGPOS,
         A~MATNR,
         D~TXZ01 AS MAKTX,
         A~WERKS,
         D~LGORT,
         A~LFIMG,
         A~MEINS,
*        A~TAGNR AS LICHN,
*        A~HSDAT,
         D~PSTYP,
*-(S) 추출 기준 변경(25.02.12)
*        CASE B~CNT WHEN 0 THEN @GC_D
*                          ELSE @GC_N
*                          END AS ZDFLG
*   FROM ZMMTI34 AS A LEFT OUTER JOIN @LT_DEL AS B
         B~STATUS,               "납품서+항번+꼬리표별 최종상태
         E~STATUS AS ITEMSTATUS, "납품서+항번별 최종상태
         F~DISPO                 "추가(25.02.13)
    FROM ZMMTI34 AS A INNER JOIN ZGTMM_CV_ZMMTI35_SUM AS B
*-(E) 추출 기준 변경(25.02.12)
      ON A~VBELN = B~VBELN
     AND A~POSNR = B~POSNR
     AND A~TAGNR = B~TAGNR
   INNER JOIN EKPO AS D
      ON A~EBELN = D~EBELN
     AND A~EBELP = D~EBELP
*-(S) 추출 기준 변경(25.02.12)
   INNER JOIN ZGTMM_CV_ZMMTI34LAST AS E
      ON A~VBELN = E~VBELN
     AND A~POSNR = E~POSNR
*-(E) 추출 기준 변경(25.02.12)
   INNER JOIN MARC AS F          "추가(25.02.13)
      ON D~MATNR = F~MATNR
     AND D~WERKS = F~WERKS
   WHERE A~WERKS IN @S_WERKS
     AND A~VBELN IN @LR_VBELN
APPENDING CORRESPONDING FIELDS OF TABLE @LT_SITM.

* SORT LT_SITM BY VBELN POSNR VGBEL VGPOS LICHN. "왜 이렇게 할까?? VBELN/POSNR면 충분하지 않나?
* DELETE ADJACENT DUPLICATES FROM LT_SITM
*                       COMPARING VBELN POSNR VGBEL VGPOS LICHN ZDFLG.
*
* GT_SITM[] = CORRESPONDING #( LT_SITM[] ).

  CHECK LT_SITM[] IS NOT INITIAL.

  LOOP AT LT_SITM.
*S4DK919646	[GT_MM] ZGTMMR4914 2025.06.10 by 이정민 CTS였음
*(S)구미 물자 창고 WMS 도입(SJM 25.06.10)
* - WMS는 특정 SPG만 대상으로 하지 않음. MRP관리자 기준 데이터 한정했던 로직 주석처리.
*   PERFORM CHECK_DISPO USING LT_SITM-DISPO.
*   CHECK GV_CHK = GC_X.
*(E)구미 물자 창고 WMS 도입(SJM 25.06.10)
*S4DK919646	[GT_MM] ZGTMMR4914 2025.06.10 by 이정민 CTS였음

*--> 구미공장 WMS I/F TEST 위한 주석 - 20250724
*    PERFORM CHECK_DISPO USING LT_SITM-DISPO.
*    CHECK GV_CHK = GC_X.
*<-- 구미공장 WMS I/F TEST 위한 주석 - 20250724

    CLEAR : GT_SITM.

    "외주가공 납품서
    CASE LT_SITM-ITEMSTATUS.
      WHEN 'C'.
        "품목의 납품서 수량이 최종 존재하는 상태이면, 꼬리표가 살아있는 것만 Sum
        IF LT_SITM-STATUS = GC_C.
          LT_SITM-ZDFLG = GC_N.
        ELSE.
          CONTINUE.
        ENDIF.
      WHEN 'D'.
        "품목이 최종 삭제 상태이면, 꼬리표가 전체 죽은 것이므로 해당 항번 꼬리표 전체 Sum
        LT_SITM-ZDFLG = GC_D.
    ENDCASE.

    MOVE-CORRESPONDING LT_SITM TO GT_SITM.
    COLLECT GT_SITM. "VBELN/POSNR별 수량 Sum
  ENDLOOP.

  PERFORM CHECK_SHDR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DISPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DISPO USING PV_DISPO.

  DATA : LV_HTYPE LIKE DD01V-DATATYPE.


  "MARC-DISPO 앞2자리가 'PC'/'PO' or 숫자 3자리로만 구성될 경우만 대상(25.02.13)

  CLEAR : GV_CHK.
  CHECK PV_DISPO IS NOT INITIAL.

  CALL FUNCTION 'NUMERIC_CHECK'
    EXPORTING
      STRING_IN = PV_DISPO
    IMPORTING
      HTYPE     = LV_HTYPE.

  CHECK PV_DISPO+0(2) = GC_PC
     OR PV_DISPO+0(2) = GC_PO
     OR LV_HTYPE      = GC_NUMC.

  GV_CHK = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SHDR.

  "MARC-DISPO 조건에 해당하지 않는 DO 삭제(헤더기준) (25.02.13)

  CHECK GT_SHDR[] IS NOT INITIAL.

  GR_VBELN[] = VALUE #( FOR LS_SITM IN GT_SITM
                        ( VALUE #( SIGN = GC_E OPTION = GC_EQ LOW = LS_SITM-VBELN ) ) ).

  SORT GR_VBELN BY LOW.
  DELETE ADJACENT DUPLICATES FROM GR_VBELN COMPARING LOW.

  DELETE GT_SHDR WHERE VBELN IN GR_VBELN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_FRC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_FRC.

  "기전송(성공) 삭제 기준 변경(25.02.13)
  " 헤더/아이템 모두 기전송(성공) 데이터와 일치해야 삭제 대상..

  CHECK P_FRC     IS INITIAL. "기전송된 데이터 삭제
  CHECK GT_SHDR[] IS NOT INITIAL.

  PERFORM GET_HOLD.
  PERFORM GET_IOLD.

  CHECK GT_HOLD[] IS NOT INITIAL.

  LOOP AT GT_SHDR.
    PERFORM CHK_HOLD.
    PERFORM CHK_IOLD.

    PERFORM DEL_XOLD.
  ENDLOOP.

  SORT GT_SHDR BY VBELN.
  SORT GT_SITM BY VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HOLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HOLD.

  CLEAR : GT_HOLD[].

  DATA(LT_SHDR) = GT_SHDR[].

  SORT LT_SHDR BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_SHDR COMPARING VBELN.

  "기전송 Data
  SELECT ZIFKEY,
         VBELN,
         LIFNR,
         ERDAT,
         WERKS,
         LFDAT,
         ZDFLG
    FROM ZGTMM_CV_ID_IF_LOG_L
    INTO CORRESPONDING FIELDS OF TABLE @GT_HOLD
     FOR ALL ENTRIES IN @LT_SHDR
   WHERE SYSTEM_ID = @P_IFSYT
     AND ZSTAT     = @GC_S
     AND VBELN     = @LT_SHDR-VBELN.

  CHECK GT_HOLD[] IS NOT INITIAL.

  SORT GT_HOLD BY VBELN LIFNR ZIFKEY DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_HOLD COMPARING VBELN LIFNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IOLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_IOLD.

  CLEAR : GT_IOLD[].

  DATA(LT_SITM) = GT_SITM[].

  SORT LT_SITM BY VBELN POSNR. "VGBEL VGPOS LICHN.
  DELETE ADJACENT DUPLICATES FROM LT_SITM
        COMPARING VBELN POSNR. "VGBEL VGPOS LICHN.

  "기전송 Data
  SELECT I~ZIFKEY,
         VBELN,
         POSNR,
         VGBEL,
         VGPOS,
*        LICHN,
         MATNR,
*        MAKTX,
         WERKS,
         LGORT,
         LFIMG,
         MEINS,
*        NETWR,
*        HSDAT,
*        VFDAT,
         PSTYP,
         ZDFLG
    FROM ZGTMMT9051 AS I INNER JOIN ZGTMMT9000 AS C
      ON I~ZIFKEY = C~ZIFKEY
    INTO CORRESPONDING FIELDS OF TABLE @GT_IOLD
     FOR ALL ENTRIES IN @LT_SITM
   WHERE I~VBELN     = @LT_SITM-VBELN
     AND I~POSNR     = @LT_SITM-POSNR
*    AND I~VGBEL     = @LT_SITM-VGBEL
*    AND I~VGPOS     = @LT_SITM-VGPOS
*    AND I~LICHN     = @LT_SITM-LICHN.
     AND C~ZIFNO     = @GC_MM00005
     AND C~SYSTEM_ID = @P_IFSYT
     AND C~ZSTAT     = @GC_S.

  CHECK GT_IOLD[] IS NOT INITIAL.

  SORT GT_IOLD BY VBELN POSNR ZIFKEY DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_IOLD COMPARING VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_HOLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_HOLD.

  CLEAR : GV_HDEL.

  DATA(LV_IDX) = LINE_INDEX( GT_HOLD[ VBELN = GT_SHDR-VBELN
                                      LIFNR = GT_SHDR-LIFNR
                                      LFDAT = GT_SHDR-LFDAT
                                      ZDFLG = GT_SHDR-ZDFLG ] ).

  CHECK LV_IDX > 0.

  GV_HDEL = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_IOLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_IOLD.

  DATA : LV_TOT TYPE I,
         LV_CNT TYPE I.


  CLEAR : GV_IDEL.

  READ TABLE GT_SITM WITH KEY VBELN = GT_SHDR-VBELN
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_SITM INTO DATA(LS_SITM) FROM SY-TABIX.
    IF LS_SITM-VBELN <> GT_SHDR-VBELN.
      EXIT.
    ENDIF.

    LV_TOT += 1.

    SELECT SINGLE PSTYP
      FROM EKPO INTO @DATA(LV_PSTYP)
     WHERE EBELN = @LS_SITM-VGBEL
       AND EBELP = @LS_SITM-VGPOS.

    IF SY-SUBRC = 0.
      LS_SITM-PSTYP = LV_PSTYP.
    ENDIF.

    IF LS_SITM-ZDFLG IS INITIAL.
      LS_SITM-ZDFLG = GC_N.
    ENDIF.

    DATA(LV_IDX) = LINE_INDEX( GT_IOLD[ VBELN = LS_SITM-VBELN
                                        POSNR = LS_SITM-POSNR
                                        VGBEL = LS_SITM-VGBEL
                                        VGPOS = LS_SITM-VGPOS
*                                       LICHN = LS_SITM-LICHN
                                        MATNR = LS_SITM-MATNR
                                        WERKS = LS_SITM-WERKS
                                        LGORT = LS_SITM-LGORT
                                        LFIMG = LS_SITM-LFIMG
                                        MEINS = LS_SITM-MEINS
*                                       HSDAT = LS_SITM-HSDAT
*                                       VFDAT = LS_SITM-VFDAT
                                        PSTYP = LS_SITM-PSTYP
                                        ZDFLG = LS_SITM-ZDFLG ] ).

    CHECK LV_IDX > 0.
    LV_CNT += 1.
  ENDLOOP.

  "헤더를 구성하는 모든 아이템이 기전송건이면..
  CHECK LV_TOT = LV_CNT.
  GV_IDEL = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_XOLD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_XOLD.

  "헤더와 모든 아이템이 기전송과 일치시에만 대상에서 삭제

  CHECK GV_HDEL = GC_X AND GV_IDEL = GC_X.

  DELETE GT_SHDR WHERE VBELN = GT_SHDR-VBELN.
  DELETE GT_SITM WHERE VBELN = GT_SHDR-VBELN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA.

  RANGES : LR_VBELN FOR LIKP-VBELN.


  CHECK P_FRC     IS INITIAL. "기전송된 데이터 삭제
  CHECK GT_SHDR[] IS NOT INITIAL.

  DATA(LT_SHDR) = GT_SHDR[].

  SORT LT_SHDR BY VBELN CHANGENR.
  DELETE ADJACENT DUPLICATES FROM LT_SHDR COMPARING VBELN CHANGENR.

  SELECT DISTINCT VBELN AS LOW
    FROM ZGTMMT9000 AS C INNER JOIN ZGTMMT9050 AS H
      ON C~ZIFKEY = H~ZIFKEY
    INTO CORRESPONDING FIELDS OF TABLE @LR_VBELN
     FOR ALL ENTRIES IN @LT_SHDR
   WHERE C~ZIFNO     = @GC_MM00005
     AND C~SYSTEM_ID = @P_IFSYT
     AND C~ZSTAT     = @GC_S
     AND H~VBELN     = @LT_SHDR-VBELN
     AND H~CHANGENR  = @LT_SHDR-CHANGENR.

  CHECK LR_VBELN[] IS NOT INITIAL.
  LR_VBELN-SIGN   = GC_I.
  LR_VBELN-OPTION = GC_EQ.
  MODIFY LR_VBELN TRANSPORTING SIGN OPTION
                         WHERE SIGN IS INITIAL.

  DELETE GT_SHDR WHERE VBELN IN LR_VBELN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_HDR.

  CHECK P_FRC     IS INITIAL. "기전송된 데이터 삭제
  CHECK GT_SHDR[] IS NOT INITIAL.

  DATA(LT_SHDR) = GT_SHDR[].

  SORT LT_SHDR BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_SHDR COMPARING VBELN.

  "기전송 Data
  SELECT ZIFKEY,
         VBELN,
         LIFNR,
         ERDAT,
         WERKS,
         LFDAT,
         ZDFLG
    FROM ZGTMM_CV_ID_IF_LOG_L
    INTO TABLE @DATA(LT_OLD)
     FOR ALL ENTRIES IN @LT_SHDR
   WHERE SYSTEM_ID = @P_IFSYT
     AND ZSTAT     = @GC_S
     AND VBELN     = @LT_SHDR-VBELN.

  CHECK LT_OLD[] IS NOT INITIAL.

  SORT LT_OLD BY VBELN LIFNR ZIFKEY DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_OLD COMPARING VBELN LIFNR.

  LOOP AT GT_SHDR.
    DATA(LV_IDX) = LINE_INDEX( LT_OLD[ VBELN = GT_SHDR-VBELN
                                       LIFNR = GT_SHDR-LIFNR
                                       LFDAT = GT_SHDR-LFDAT
                                       ZDFLG = GT_SHDR-ZDFLG ] ).

    CHECK LV_IDX > 0.

    DELETE GT_SHDR WHERE VBELN = GT_SHDR-VBELN
                     AND LIFNR = GT_SHDR-LIFNR
                     AND LFDAT = GT_SHDR-LFDAT
                     AND ZDFLG = GT_SHDR-ZDFLG.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_ITM.

  DATA : LT_SITM LIKE ZGTMMSIF0008 OCCURS 0 WITH HEADER LINE.


  CHECK P_FRC     IS INITIAL. "기전송된 데이터 삭제
  CHECK GT_SITM[] IS NOT INITIAL.

  LT_SITM[] = GT_SITM[].

  SORT LT_SITM BY VBELN POSNR. "VGBEL VGPOS LICHN.
  DELETE ADJACENT DUPLICATES FROM LT_SITM
        COMPARING VBELN POSNR. "VGBEL VGPOS LICHN.

  "기전송 Data(성공된 건만)
  SELECT I~ZIFKEY,
         VBELN,
         POSNR,
         VGBEL,
         VGPOS,
*        LICHN,
         MATNR,
         MAKTX,
         WERKS,
         LGORT,
         LFIMG,
         MEINS,
*        NETWR,
*        HSDAT,
*        VFDAT,
         PSTYP,
         ZDFLG
    FROM ZGTMMT9051 AS I INNER JOIN ZGTMMT9000 AS C
      ON I~ZIFKEY = C~ZIFKEY
    INTO TABLE @DATA(LT_OLD)
     FOR ALL ENTRIES IN @LT_SITM
   WHERE I~VBELN     = @LT_SITM-VBELN
     AND I~POSNR     = @LT_SITM-POSNR
*    AND I~VGBEL     = @LT_SITM-VGBEL
*    AND I~VGPOS     = @LT_SITM-VGPOS
*    AND I~LICHN     = @LT_SITM-LICHN.
     AND C~ZIFNO     = @GC_MM00005
     AND C~SYSTEM_ID = @P_IFSYT
     AND C~ZSTAT     = @GC_S.

  CHECK LT_OLD[] IS NOT INITIAL.

* SORT LT_OLD BY VBELN POSNR VGBEL VGPOS LICHN ZIFKEY DESCENDING.
* DELETE ADJACENT DUPLICATES FROM LT_OLD
*       COMPARING VBELN POSNR VGBEL VGPOS LICHN.
  SORT LT_OLD BY VBELN POSNR ZIFKEY DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_OLD COMPARING VBELN POSNR.

  LOOP AT GT_SITM INTO DATA(LS_SITM).
    SELECT SINGLE PSTYP
      FROM EKPO INTO @DATA(LV_PSTYP)
     WHERE EBELN = @LS_SITM-VGBEL
       AND EBELP = @LS_SITM-VGPOS.

    IF SY-SUBRC = 0.
      LS_SITM-PSTYP = LV_PSTYP.
    ENDIF.

    IF LS_SITM-ZDFLG IS INITIAL.
      LS_SITM-ZDFLG = GC_N.
    ENDIF.

    DATA(LV_IDX) = LINE_INDEX( LT_OLD[ VBELN = LS_SITM-VBELN
                                       POSNR = LS_SITM-POSNR
                                       VGBEL = LS_SITM-VGBEL
                                       VGPOS = LS_SITM-VGPOS
*                                      LICHN = LS_SITM-LICHN
                                       MATNR = LS_SITM-MATNR
                                       WERKS = LS_SITM-WERKS
                                       LGORT = LS_SITM-LGORT
                                       LFIMG = LS_SITM-LFIMG
                                       MEINS = LS_SITM-MEINS
*                                      HSDAT = LS_SITM-HSDAT
*                                      VFDAT = LS_SITM-VFDAT
                                       PSTYP = LS_SITM-PSTYP
                                       ZDFLG = LS_SITM-ZDFLG ] ).

    CHECK LV_IDX > 0.

    DELETE GT_SITM WHERE VBELN = LS_SITM-VBELN
                     AND POSNR = LS_SITM-POSNR
                     AND VGBEL = LS_SITM-VGBEL
                     AND VGPOS = LS_SITM-VGPOS
*                    AND LICHN = LS_SITM-LICHN
                     AND MATNR = LS_SITM-MATNR
                     AND WERKS = LS_SITM-WERKS
                     AND LGORT = LS_SITM-LGORT
                     AND LFIMG = LS_SITM-LFIMG
                     AND MEINS = LS_SITM-MEINS
*                    AND HSDAT = LS_SITM-HSDAT
*                    AND VFDAT = LS_SITM-VFDAT
                     AND PSTYP = LS_SITM-PSTYP
                     AND ZDFLG = LS_SITM-ZDFLG.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_DATA USING PV_CHK.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE ZO_RESULT,
         LV_MSG  TYPE ZO_MESSAGE,
         LV_RET  TYPE ZIFE_IFRET.

  DATA : LT_F007 LIKE ZGTMMSIF0007 OCCURS 0 WITH HEADER LINE,
         LT_F008 LIKE ZGTMMSIF0008 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_F007[], GT_F008[].
  CLEAR : GT_HLOG[], GT_ILOG[].
  CLEAR : GV_CNT,    GV_MSG.

  IF PV_CHK = GC_X.
    PERFORM SEND_SEL_DATA.

    CHECK GV_ERR IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   'Data를 전송 하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ELSE.
    PERFORM SEND_BAT_DATA.
  ENDIF.

  IF P_IFSYT IS INITIAL.
    MESSAGE S015 WITH 'I/F 시스템'(M01) DISPLAY LIKE 'E'. "&를(을) 입력하세요.
    EXIT.
  ENDIF.

  PERFORM MODIFY_F00X_DATA.

  LT_F007[] = GT_F007[].
  LT_F008[] = GT_F008[].

  "Destination
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
*      GUBUN                 = 'MM'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTMM_IF_O_INBOUNDSEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = P_IFSYT
    IMPORTING
      ZO_RESULT   = LV_RST
      ZO_MESSAGE  = LV_MSG
    TABLES
      OT_HEAD     = LT_F007[] "GT_F007[]
      OT_ITEM     = LT_F008[] "GT_F008[]
    EXCEPTIONS
      OTHERS      = 1.

  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
      GV_CNT = LINES( GT_F007[] ).
      GV_MSG = GV_CNT && '건 전송 성공'(M02).
    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

  PERFORM SAVE_LOG USING LV_RET
                         LV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        MESSAGE S050 DISPLAY LIKE 'E'. "선택된 데이터가 없습니다.
      ENDIF.
    WHEN 1.
      IF PV_MODE = GC_S.
        READ TABLE GT_ROW INTO GS_ROW INDEX 1.
      ENDIF.
    WHEN OTHERS.
      IF PV_MODE = GC_S.
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM USING PV_TITLE
                            PV_QTEXT.

  CLEAR : GV_ANS. "1/2/A

  CALL FUNCTION 'POPUP_TO_CONFIRM' "POPUP_TO_CONFIRM_STEP
    EXPORTING
      TITLEBAR      = PV_TITLE
*     DIAGNOSE_OBJECT             = ' '
      TEXT_QUESTION = PV_QTEXT
*     TEXT_BUTTON_1 = 'Ja'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'Nein'(002)
*     ICON_BUTTON_2 = ' '
*     DEFAULT_BUTTON              = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN  = 25
*     START_ROW     = 6
*     POPUP_TYPE    =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER        = GV_ANS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SEL_DATA.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_HLIST> ASSIGNING <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE 'X'.
      WHEN P_ILOG.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LAST>).

        IF <LFS_LAST> IS INITIAL.
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

        PERFORM APPEND_LIST TABLES GT_HLOG USING <GS_LIST>.
        PERFORM APPEND_LIST TABLES GT_ILOG USING <GS_LIST>.

      WHEN P_SEND.
        PERFORM GET_SEND_ITM.
        PERFORM GET_SEND_HDR.

    ENDCASE.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_ITM.

    WHEN P_SEND.

  ENDCASE.

  GT_F008[] = CORRESPONDING #( GT_ILOG[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HLOG
*&      --> <GS_LIST>
*&---------------------------------------------------------------------*
FORM APPEND_LIST TABLES PT_ITAB
                  USING PS_LIST.

  CLEAR : PT_ITAB.

  PT_ITAB = CORRESPONDING #( PS_LIST ).
  APPEND PT_ITAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_ITM.

  DATA : LT_SITM LIKE SORTED TABLE OF ZGTMMSIF0008
                 WITH NON-UNIQUE KEY VBELN POSNR.
  DATA : LT_ILOG LIKE ZGTMMT9051 OCCURS 0 WITH HEADER LINE.


  ASSIGN COMPONENT 'VBELN' OF STRUCTURE <GS_LIST> TO <GV_VBELN>.

  LT_SITM[] = GT_SITM[].
  LT_ILOG[] = CORRESPONDING #( FILTER #( LT_SITM WHERE VBELN = <GV_VBELN> ) ).
  APPEND LINES OF LT_ILOG TO GT_ILOG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND_HDR.

  DATA : LS_SHDR LIKE GT_SHDR.


  READ TABLE GT_SHDR WITH KEY VBELN = <GV_VBELN>
                              BINARY SEARCH.

  IF SY-SUBRC = 0.
    LS_SHDR = CORRESPONDING #( <GS_LIST> ).
    LS_SHDR-CHANGENR = GT_SHDR-CHANGENR.

    PERFORM APPEND_LIST TABLES GT_HLOG USING LS_SHDR.
  ELSE.
    PERFORM APPEND_LIST TABLES GT_HLOG USING <GS_LIST>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILOG_ITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILOG_ITM.

  CHECK GT_ILOG[] IS NOT INITIAL.

  SORT GT_ILOG BY ZIFKEY VBELN.
  DELETE ADJACENT DUPLICATES FROM GT_ILOG COMPARING ZIFKEY VBELN.

  SELECT *
    FROM ZGTMMT9051
    INTO CORRESPONDING FIELDS OF TABLE GT_ILOG
     FOR ALL ENTRIES IN GT_ILOG
   WHERE ZIFKEY = GT_ILOG-ZIFKEY
     AND VBELN  = GT_ILOG-VBELN.

  SORT GT_ILOG BY ZIFKEY DESCENDING
                  VBELN  ASCENDING
                  POSNR  ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_BAT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_BAT_DATA.

  GT_HLOG[] = CORRESPONDING #( GT_SHDR[] ).
  GT_ILOG[] = CORRESPONDING #( GT_SITM[] ).

  GT_F007[] = CORRESPONDING #( GT_HLOG[] ).
  GT_F008[] = CORRESPONDING #( GT_ILOG[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F00X_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F00X_DATA.

  GT_F007[] = VALUE #( FOR LS_HDR IN GT_HLOG
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  VBELN = |{ LS_HDR-VBELN ALPHA = OUT }|
                                  LIFNR = |{ LS_HDR-LIFNR ALPHA = OUT }| ) ) ).

  LOOP AT GT_F008.
    GT_F008-VBELN = |{ GT_F008-VBELN ALPHA = OUT }|.
    GT_F008-VGBEL = |{ GT_F008-VGBEL ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F008-MATNR.

    SHIFT GT_F008-POSNR LEFT DELETING LEADING '0'. "추가(24.12.10)
    SHIFT GT_F008-VGPOS LEFT DELETING LEADING '0'. "추가(24.12.10)

    MODIFY GT_F008 TRANSPORTING VBELN VGBEL MATNR POSNR VGPOS.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F003_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_OUTPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_MATNR
    IMPORTING
      OUTPUT = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG USING PV_RET
                    PV_MSG.

  CLEAR : GS_9000, GT_9050[], GT_9051[].

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00005.
  GS_9000-SYSTEM_ID   = P_IFSYT.
  GS_9000-ZSTAT       = PV_RET.
  GS_9000-MESSAGE     = PV_MSG.
  GS_9000-IFDAT       = SY-DATLO.
  GS_9000-IFTIM       = SY-TIMLO.
  GS_9000-IFNAM       = SY-UNAME.
  GS_9000-ERDAT       = SY-DATUM.
  GS_9000-ERDAT_LOCAL = SY-DATLO.
  GS_9000-ERTIM       = SY-UZEIT.
  GS_9000-ERTIM_LOCAL = SY-TIMLO.
  GS_9000-ERNAM       = SY-UNAME.

  GT_9050[] = VALUE #( FOR LS_HDR IN GT_HLOG
                       ( VALUE #( BASE CORRESPONDING #( LS_HDR )
                                  ZIFKEY = GS_9000-ZIFKEY ) ) ).

  GT_9051[] = VALUE #( FOR LS_ITM IN GT_ILOG
                       ( VALUE #( BASE CORRESPONDING #( LS_ITM )
                                  ZIFKEY = GS_9000-ZIFKEY ) ) ).

  CHECK GT_9050[] IS NOT INITIAL.

  MODIFY ZGTMMT9051 FROM TABLE GT_9051.
  MODIFY ZGTMMT9050 FROM TABLE GT_9050.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  GV_SEND = COND #( WHEN P_ILOG = 'X' THEN '재전송'(B01)
                    WHEN P_SEND = 'X' THEN '전송'(B02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  GR_SPLIT = NEW #( PARENT  = GR_DOCK
                    ROWS    = 2
                    COLUMNS = 1 ).

  "#1 Row
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                      COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                    I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                            HEIGHT = 50 ).

  "#2 Row
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2
                                      COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
                    I_APPL_EVENTS = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

  "다운로드 기능(MC_MB_EXPORT) 삭제(25.02.10)

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO
                    PV_TYPE.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = COND #( WHEN P_ILOG = 'X' THEN 'Interface 처리상태'(T01)
                                   WHEN P_SEND = 'X' THEN '납품서 헤더'(T02) ).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '상세정보'(T03).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> <GT_HLIST>
*&      --> GV_HNAME
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_DATA
               USING PV_NAME
                     PV_TYPE.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( PV_NAME )
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  DELETE LT_FCAT WHERE FIELDNAME = '.NODE1'.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = PT_DATA
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT PT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE GS_FCAT-FIELDNAME.
      WHEN 'VBELN'.
        IF PV_TYPE = GC_H.
          GS_FCAT-HOTSPOT = GC_X.
        ENDIF.
      WHEN 'ERDAT'.
        PERFORM SET_FTXT USING '레코드 생성일'(F01).
      WHEN 'LFDAT'.
        PERFORM SET_FTXT USING '납품일'(F02).
      WHEN 'HSDAT'.
        PERFORM SET_FTXT USING '제조일'(F03).
      WHEN 'VFDAT'.
        PERFORM SET_FTXT USING '유효 기한'(F04).
    ENDCASE.

    MODIFY PT_FCAT FROM GS_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FTXT USING PV_TEXT.

  GS_FCAT-SELTEXT = GS_FCAT-TOOLTIP
= GS_FCAT-REPTEXT = GS_FCAT-COLTEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

    WHEN 'GR_IGRID'.

  ENDCASE.

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> <GT_HLIST>
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO
                     PV_TYPE.

  CLEAR : GS_VARI.
  CASE PV_TYPE.
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.
  ENDCASE.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
      IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PS_LAYO TYPE LVC_S_LAYO.

  DATA : LS_STBL TYPE LVC_S_STBL.


  LS_STBL-ROW = GC_X.
  LS_STBL-COL = GC_X.

  CALL METHOD PR_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = PS_LAYO.

  CALL METHOD PR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
*     I_SOFT_REFRESH = GC_X
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GR_HGRID->FREE.
      CALL METHOD GR_IGRID->FREE.
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_HCNTR, GR_ICNTR, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_ROW  TYPE LVC_S_ROW
                                PS_COL  TYPE LVC_S_COL
                                PS_ROID TYPE LVC_S_ROID
                                PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      READ TABLE <GT_HLIST> ASSIGNING <GS_LIST> INDEX PS_ROW-INDEX.

      CASE PS_COL-FIELDNAME.
        WHEN 'VBELN'.
          PERFORM GET_ILIST_DATA.
          PERFORM REFRESH_GRID USING GR_IGRID
                                     GS_ILAYO.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ILIST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ILIST_DATA.

  CLEAR : <GT_ILIST>, GT_ILOG[].

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM APPEND_LIST TABLES GT_ILOG USING <GS_LIST>.
      PERFORM GET_ILOG_ITM.

    WHEN P_SEND.
      PERFORM GET_SEND_ITM.

  ENDCASE.

  <GT_ILIST>[] = CORRESPONDING #( GT_ILOG[] ).

ENDFORM.
