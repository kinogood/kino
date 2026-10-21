*&---------------------------------------------------------------------*
*& Include          ZGTMMR4915F01
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
  OR ( P_SEND = GC_X AND ( S_ERDAT[] IS INITIAL
                        OR P_IFSYT   IS INITIAL ) ).
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

  CASE 'X'.
    WHEN P_IF1. " 배차정보
      PERFORM GET_MST_INFO USING 'MM00022'.
    WHEN P_IF2. " 계근정보
      PERFORM GET_MST_INFO USING 'MM00023'.
  ENDCASE.

  PERFORM MAKE_ITAB.
  CLEAR : <GT_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
  ENDCASE.

  GV_CNT = LINES( <GT_LIST> ).
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

  DATA : LR_DATA  TYPE REF TO DATA.


  CLEAR    : GV_TNAME.
  UNASSIGN : <GT_LIST>, <GS_LIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_TNAME = GS_MST-VIEW.
    WHEN P_SEND.
      CASE 'X'.
        WHEN P_IF1.
          GV_TNAME = GC_ZGTMMSIF0076.
        WHEN P_IF2.
          GV_TNAME = GC_ZGTMMSIF0077.
      ENDCASE.
  ENDCASE.

  CHECK GV_TNAME IS NOT INITIAL.

  DATA(LS_STRC) = CAST CL_ABAP_STRUCTDESCR(
                       CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( GV_TNAME ) ).

  CREATE DATA LR_DATA TYPE HANDLE LS_STRC.
  ASSIGN LR_DATA->* TO  <GS_LIST>.
  FREE : LR_DATA.

  CREATE DATA LR_DATA LIKE STANDARD TABLE OF <GS_LIST>.
  ASSIGN LR_DATA->* TO <GT_LIST>.
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

*  DATA : LV_COND TYPE STRING.
*
*  LV_COND = |     IFDAT IN @S_IFDAT |
*         && | AND WERKS IN @S_WERKS |
*         && | AND RSNUM IN @S_RSNUM |
*         && | AND BWART IN @S_BWART |.
*
*  IF P_IFSYT IS NOT INITIAL.
*    LV_COND = LV_COND && | AND SYSTEM_ID = @P_IFSYT |.
*  ENDIF.
*
*  IF P_FNL IS NOT INITIAL.
*    LV_COND = LV_COND && | AND LASTDATA = @GC_X |.
*  ENDIF.
*
*  IF P_FRC IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
*    LV_COND = LV_COND && | AND ZSTAT <> @GC_S |.
*  ENDIF.

*  SELECT *
*    FROM (GV_TNAME)
*    INTO CORRESPONDING FIELDS OF TABLE @<GT_LIST>
*   WHERE (LV_COND).

  CASE 'X'.
    WHEN P_IF1.
      SELECT DISTINCT
             B~*,
             A~IFDAT,
             A~IFTIM,
             A~ZSTAT
        FROM ZGTMMT9000 AS A
             INNER JOIN ZGTMMT9210 AS B
              ON A~ZIFKEY = B~ZIFKEY
       WHERE A~ZIFNO = @GC_MM00022
         AND A~SYSTEM_ID = @P_IFSYT
         AND A~IFDAT IN @S_IFDAT
         AND B~ZSEQNO IN @S_ZSEQNO
        INTO CORRESPONDING FIELDS OF TABLE @GT_9210_LOG.

      CLEAR : GS_9210_LOG.
      LOOP AT GT_9210_LOG INTO GS_9210_LOG.
        SELECT COUNT(*)
          FROM ZGTMMT9210 AS A
         WHERE A~ZSEQNO = GS_9210_LOG-ZSEQNO
           AND A~ZIFKEY = GS_9210_LOG-ZIFKEY
           AND A~ZIFKEY = (
                           SELECT MAX( AA~ZIFKEY )
                             FROM ZGTMMT9210 AS AA
                            WHERE AA~ZSEQNO = A~ZSEQNO
                          ).
        IF SY-DBCNT > 0.
          GS_9210_LOG-LASTDATA = 'X'.
          MODIFY GT_9210_LOG FROM GS_9210_LOG TRANSPORTING LASTDATA.
        ENDIF.
      ENDLOOP.

      "--> 최종 전송내역만 조회
      IF P_FNL IS NOT INITIAL.
        DELETE GT_9210_LOG WHERE LASTDATA <> 'X'.
      ENDIF.

      "--> I/F 성공내역 제외
      IF P_FRC IS INITIAL.
        DELETE GT_9210_LOG WHERE ZSTAT = GC_S.
      ENDIF.

      CHECK GT_9210_LOG[] IS NOT INITIAL.
      SORT GT_9210_LOG BY ZIFKEY DESCENDING ZSEQNO ASCENDING.

      <GT_LIST> = CORRESPONDING #( GT_9210_LOG[] ).
    WHEN P_IF2.
      SELECT DISTINCT
             B~*,
             A~IFDAT,
             A~IFTIM,
             A~ZSTAT
        FROM ZGTMMT9000 AS A
             INNER JOIN ZGTMMT9220 AS B
              ON A~ZIFKEY = B~ZIFKEY
       WHERE A~ZIFNO = @GC_MM00023
         AND A~SYSTEM_ID = @P_IFSYT
         AND A~IFDAT IN @S_IFDAT
         AND B~ZSEQNO IN @S_ZSEQNO
        INTO CORRESPONDING FIELDS OF TABLE @GT_9220_LOG.

      CLEAR : GS_9220_LOG.
      LOOP AT GT_9220_LOG INTO GS_9220_LOG.
        SELECT COUNT(*)
          FROM ZGTMMT9220 AS A
         WHERE A~ZSEQNO = GS_9220_LOG-ZSEQNO
           AND A~ZIFKEY = GS_9220_LOG-ZIFKEY
           AND A~ZIFKEY = (
                           SELECT MAX( AA~ZIFKEY )
                             FROM ZGTMMT9220 AS AA
                            WHERE AA~ZSEQNO = A~ZSEQNO
                          ).
        IF SY-DBCNT > 0.
          GS_9220_LOG-LASTDATA = 'X'.
          MODIFY GT_9220_LOG FROM GS_9220_LOG TRANSPORTING LASTDATA.
        ENDIF.
      ENDLOOP.

      "--> 최종 전송내역만 조회
      IF P_FNL IS NOT INITIAL.
        DELETE GT_9220_LOG WHERE LASTDATA <> 'X'.
      ENDIF.

      "--> I/F 성공내역 제외
      IF P_FRC IS INITIAL.
        DELETE GT_9220_LOG WHERE ZSTAT = GC_S.
      ENDIF.

      CHECK GT_9220_LOG[] IS NOT INITIAL.
      SORT GT_9220_LOG BY ZIFKEY DESCENDING ZSEQNO ASCENDING.

      <GT_LIST> = CORRESPONDING #( GT_9220_LOG[] ).
  ENDCASE.

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

  CLEAR : GT_LIST_IF1, GT_LIST_IF1[].
  CLEAR : GT_LIST_IF2, GT_LIST_IF2[].

*  PERFORM CONVERT_DATE.

  CASE 'X'.
    WHEN P_IF1. " 배차정보
      SELECT DISTINCT
             A~ZSEQNO        ,
             A~CU_CLS        ,
             A~CU_CLS_TXT    ,
             A~ORIGIN_CD     ,
             A~ORIGIN_TXT    ,
             A~EBELN_EXT     ,
             A~BL_NO         ,
             A~GRADE         ,
             A~KUNNR_EXT     ,
             A~NAME_K        ,
             A~LIFNR_EXT     ,
             A~NAME_L        ,
             A~BRAND_ID      ,
             A~BRAND_TXT     ,
             A~VEHIC_NO      ,
             A~DISPATCH_DAT  ,
             A~DISPATCH_RMRK ,
             A~DISPATCH_CRID ,
             A~DISPATCH_CHGID,
             A~CARR_ID       ,
             A~CARR_NAME     ,
             A~DRIVER_NAME   ,
             A~DRIVER_TELNO  ,
             A~GRDAT         ,
             A~CARR_WT       ,
             A~MEINS         ,
             A~SHIP_RMRK     ,
             A~LVORM         ,
*-->> [한미소PJT] 한국미래소재 필드 추가 -- [S]
             A~EBELP_EXT        ,
             A~BL_SEQ           ,
             A~MATNR            ,
             A~MAKTX            ,
             A~EKGRP            ,
             A~ZTERM            ,
             A~INCO1            ,
             A~MENGE            ,
             A~PO_MEINS         ,
             A~NETPR            ,
             A~PEINH            ,
             A~BPRME            ,
             A~WAERS            ,
             A~TARE_WT          ,
             A~PKG_CNT          ,
             A~CONTAINER_NO     ,
             A~SEAL_NO          ,
             A~ZZLOADGRP        ,
             A~IN_DLV_NO        ,
             A~ZZIOTYP          ,
             A~ZZBSART          ,
             A~SHIP_FR_POST     ,
             A~SHIP_FR_NM       ,
             A~SHIP_FR_ADDR     ,
             A~SHIP_FR_ADDR_DTL ,
             A~SHIP_TO_POST     ,
             A~SHIP_TO_NM       ,
             A~SHIP_TO_ADDR     ,
             A~SHIP_TO_ADDR_DTL ,
             A~MATNR_01         ,
             A~NETPR_01         ,
             A~MATNR_02         ,
             A~NETPR_02         ,
             A~MATNR_03         ,
             A~NETPR_03         ,
             A~MATNR_04         ,
             A~NETPR_04         ,
             A~MATNR_05         ,
             A~NETPR_05         ,
             A~VEHIC_TYPE       ,
             A~UEBTO            ,
             A~UNTTO
*<<-- [한미소PJT] 한국미래소재 필드 추가 -- [E]
        FROM ZSDT9538 AS A
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST_IF1
       WHERE A~ZSEQNO IN @S_ZSEQNO
         AND (
                A~ERDATLO IN @S_ERDAT
                OR
                A~AEDATLO IN @S_ERDAT
             ).

      "--> I/F 예외처리. 수기 반영내역 대상 조회 X
      DELETE GT_LIST_IF1 WHERE ZSEQNO+0(6) = '260101'.


*<<-- [한미소PJT] 수신시스템별 전송 대상 분리-- [S]
      "--> 관리번호 7번째 자리 'F' = 한미소(KFCM)
      "--> 그 외 전선 MOM
      CASE P_IFSYT.
        WHEN GC_KFCM.
          DELETE GT_LIST_IF1 WHERE ZSEQNO+6(1) <> GC_F.

        WHEN GC_KSCM.
          DELETE GT_LIST_IF1 WHERE ZSEQNO+6(1) = GC_F.
      ENDCASE.
*-->> [한미소PJT] 수신시스템별 전송 대상 분리-- [E]


      CHECK GT_LIST_IF1[] IS NOT INITIAL.

*      PERFORM EXCEPT_SEND_DATA.
      PERFORM EXCEPT_SEND_DATA_IF1.

      CHECK GT_LIST_IF1[] IS NOT INITIAL.
      SORT GT_LIST_IF1 BY ZSEQNO.

      "--> REQTYP 구분자
      LOOP AT GT_LIST_IF1.
        IF GT_LIST_IF1-LVORM = 'X'.
          GT_LIST_IF1-REQTYP = 'A'.
        ELSE.
          IF GT_LIST_IF1-DISPATCH_CHGID IS NOT INITIAL.
            GT_LIST_IF1-REQTYP = 'U'.
          ELSE.
            GT_LIST_IF1-REQTYP = 'C'.
          ENDIF.
        ENDIF.
        MODIFY GT_LIST_IF1 TRANSPORTING REQTYP.
      ENDLOOP.

      "--> 한미소의 경우, 기타입고일 때 PO_MEINS 단위를 MEINS로 넣어준다 -- [S]
      " CU_CLS = 'C'(기타) AND ZZIOTYP = 'I'(입고)
      LOOP AT GT_LIST_IF1 ASSIGNING FIELD-SYMBOL(<FS_IF1>)
                          WHERE ZSEQNO+6(1) = 'F'
                            AND CU_CLS      = 'C'
                            AND ZZIOTYP     = 'I'
                            AND MATNR       = ' '.

        <FS_IF1>-MEINS = <FS_IF1>-PO_MEINS.
      ENDLOOP.
      "--> 한미소의 경우, 기타입고의 경우 PO_MEINS 단위를 MEINS로 넣어준다 -- [E]

      <GT_LIST> = CORRESPONDING #( GT_LIST_IF1[] ).

    WHEN P_IF2. " 계근정보

      SELECT DISTINCT
             A~ZSEQNO	     ,
             A~WEIGH_ID    ,
             A~WEIGH_USR   ,
             A~BUKRS_WT    ,
             A~WEIGH_RMRK  ,
             A~WEIGH_CRID  ,
             A~WEIGH_CHGID ,
             A~DIFF_WT     ,
             A~FINAL_WT    ,
             A~DEVIAT      ,
             A~MEINS       ,
             A~LVORM
        FROM ZSDT9539 AS A
        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST_IF2
       WHERE A~ZSEQNO IN @S_ZSEQNO
         AND (
                A~ERDATLO IN @S_ERDAT
                OR
                A~AEDATLO IN @S_ERDAT
             ).

      "--> I/F 예외처리. 수기 반영내역 대상 조회 X
      DELETE GT_LIST_IF2 WHERE ZSEQNO+0(6) = '260101'.

*<<-- [한미소PJT] 수신시스템별 전송 대상 분리-- [S]
      "--> 관리번호 7번째 자리 'F' = 한미소(KFCM)
      "--> 그 외 전선 MOM
      CASE P_IFSYT.
        WHEN GC_KFCM.
          DELETE GT_LIST_IF2 WHERE ZSEQNO+6(1) <> GC_F.

        WHEN GC_KSCM.
          DELETE GT_LIST_IF2 WHERE ZSEQNO+6(1) = GC_F.
      ENDCASE.
*-->> [한미소PJT] 수신시스템별 전송 대상 분리-- [E]


      CHECK GT_LIST_IF2[] IS NOT INITIAL.
*      PERFORM EXCEPT_SEND_DATA.
      PERFORM EXCEPT_SEND_DATA_IF2.

      CHECK GT_LIST_IF2[] IS NOT INITIAL.
      SORT GT_LIST_IF2 BY ZSEQNO.

      "--> REQTYP 구분자 (계근은 삭제가 없음)
      LOOP AT GT_LIST_IF2.
        IF GT_LIST_IF2-WEIGH_CHGID IS NOT INITIAL.
          GT_LIST_IF2-REQTYP = 'U'.
        ELSE.
          GT_LIST_IF2-REQTYP = 'C'.
        ENDIF.
        MODIFY GT_LIST_IF2 TRANSPORTING REQTYP.
      ENDLOOP.

      <GT_LIST> = CORRESPONDING #( GT_LIST_IF2[] ).

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERT_DATE.

  CLEAR : GR_DATE, GR_DATE[].

  CHECK S_ERDAT[] IS NOT INITIAL.
  READ TABLE S_ERDAT INDEX 1.

  PERFORM CONVERT_DATE_TO_TSTMP USING S_ERDAT-LOW  '000000'
                             CHANGING GR_DATE-LOW.
  PERFORM CONVERT_DATE_TO_TSTMP USING S_ERDAT-HIGH '235959'
                             CHANGING GR_DATE-HIGH.

*  CALL FUNCTION 'FRE_CONVERT_DATE_TO_TIMESTMP'
*    EXPORTING
*      IP_START_DATE    = S_ERDAT-LOW
*      IP_END_DATE      = S_ERDAT-HIGH
**     IP_WERKS         =
**     IP_TIME_ZONE     =
**     IP_ZERO_TIME     =
*    IMPORTING
*      EP_START_DATE    = GR_DATE-LOW
*      EP_END_DATE      = GR_DATE-HIGH
*    EXCEPTIONS
*      CONVERSION_ERROR = 1
*      OTHERS           = 2.

  GR_DATE-SIGN   = GC_I.
  GR_DATE-OPTION = SWITCH #( GR_DATE-HIGH WHEN ' ' THEN GC_EQ
                                                   ELSE GC_BT ).
  APPEND GR_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_DATE_TO_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_ERDAT_LOW
*&      --> P_
*&      <-- GR_DATE_LOW
*&---------------------------------------------------------------------*
FORM CONVERT_DATE_TO_TSTMP USING PV_DATE
                                 PV_TIME
                        CHANGING PV_TSTMP.

  CHECK PV_DATE IS NOT INITIAL.

  CONVERT DATE PV_DATE TIME PV_TIME
     INTO TIME STAMP PV_TSTMP TIME ZONE SY-ZONLO. "SY-TZONE.

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

*  CHECK P_FRC     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
*  CHECK GT_LIST[] IS NOT INITIAL.
*
*  CASE 'X'.
*    WHEN P_IF1.
*      SELECT DISTINCT
*             A~ZSEQNO        ,
*             A~CU_CLS        ,
*             A~CU_CLS_TXT    ,
*             A~ORIGIN_CD     ,
*             A~ORIGIN_TXT    ,
*             A~EBELN_EXT     ,
*             A~BL_NO         ,
*             A~GRADE         ,
*             A~KUNNR_EXT     ,
*             A~NAME_K        ,
*             A~LIFNR_EXT     ,
*             A~NAME_L        ,
*             A~BRAND_ID      ,
*             A~BRAND_TXT     ,
*             A~VEHIC_NO      ,
*             A~DISPATCH_DAT  ,
*             A~DISPATCH_RMRK ,
*             A~DISPATCH_CRID ,
*             A~DISPATCH_CHGID,
*             A~CARR_ID       ,
*             A~CARR_NAME     ,
*             A~DRIVER_NAME   ,
*             A~DRIVER_TELNO  ,
*             A~GRDAT         ,
*             A~CARR_WT       ,
*             A~MEINS         ,
*             A~SHIP_RMRK     ,
*             A~LVORM
*        FROM ZGTMMT9210 AS A
*     FOR ALL ENTRIES IN @GT_LIST
*       WHERE A~RSNUM = @GT_LIST-ZSEQNO
*         AND A~ZIFKEY = (
*                         SELECT MAX( AA~ZIFKEY )
*                           FROM ZGTMMT9210 AS AA
*                          WHERE A~ZSEQNO = AA~ZSEQNO
*                        )
*        INTO TABLE @DATA(LT_OLD).
*    WHEN P_IF2.
*
*  ENDCASE.
*
*  CHECK SY-SUBRC = 0.
*
*  SORT BY LT_OLD.
*  SORT BY GT_LIST.
*
*  LOOP AT GT_LIST INTO DATA(LS_NEW).
*    READ TABLE LT_OLD INTO DATA(LS_RESB_OLD)
*                       WITH KEY RSNUM = LS_NEW-RSNUM
*                                RSPOS = LS_NEW-RSPOS
*                                RSDAT = LS_NEW-RSDAT
*                                WEMPF = LS_NEW-WEMPF
*                                BWART = LS_NEW-BWART
*                                XWAOK = LS_NEW-XWAOK
*                                KZEAR = LS_NEW-KZEAR
*                                XLOEK = LS_NEW-XLOEK
*                                MATNR = LS_NEW-MATNR
*                                WERKS = LS_NEW-WERKS
*                                LGORT = LS_NEW-LGORT
*                                UMWRK = LS_NEW-UMWRK
*                                UMLGO = LS_NEW-UMLGO
*                                ERFME = LS_NEW-ERFME
*                                BDMNG = LS_NEW-BDMNG
*                                ENMNG = LS_NEW-ENMNG.
*
*    IF SY-SUBRC = 0.
*      DELETE GT_LIST WHERE RSNUM = LS_NEW-RSNUM
*                       AND RSPOS = LS_NEW-RSPOS.
*      CONTINUE.
*    ENDIF.
*  ENDLOOP.

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

  DATA : LT_F009 LIKE ZGTMMSIF0009 OCCURS 0 WITH HEADER LINE.
  DATA : LT_F076 LIKE ZGTMMSIF0076 OCCURS 0 WITH HEADER LINE.
  DATA : LT_F077 LIKE ZGTMMSIF0077 OCCURS 0 WITH HEADER LINE.


  CLEAR : GT_F009[], GT_RLOG[].
  CLEAR : GT_F076[], GT_RLOG_IF1[].
  CLEAR : GT_F077[], GT_RLOG_IF2[].

  CLEAR : GV_CNT, GV_MSG.

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

  CASE 'X'.

*      PERFORM MODIFY_F009_DATA.
*      LT_F009[] = GT_F009[].

    WHEN P_IF1.
      PERFORM MODIFY_F076_DATA.
      LT_F076[] = GT_F076[].

      CALL FUNCTION 'Z_IF_DESTINATION'
        EXPORTING
          GUBUN                 = 'IS'
        IMPORTING
          DEST_NAME             = LV_DEST
        EXCEPTIONS
          DESTINATION_NOT_FOUND = 1
          OTHERS                = 2.

      CALL FUNCTION 'ZGTMM_IF_O_SHIPMENT_SEND'
        DESTINATION LV_DEST
        EXPORTING
          I_SYSTEM_ID = P_IFSYT
        IMPORTING
          ZO_RESULT   = LV_RST
          ZO_MESSAGE  = LV_MSG
        TABLES
          OT_TAB      = LT_F076[]
        EXCEPTIONS
          OTHERS      = 1.
    WHEN P_IF2.
      PERFORM MODIFY_F077_DATA .
      LT_F077[] = GT_F077[].

      CALL FUNCTION 'Z_IF_DESTINATION'
        EXPORTING
          GUBUN                 = 'IS'
        IMPORTING
          DEST_NAME             = LV_DEST
        EXCEPTIONS
          DESTINATION_NOT_FOUND = 1
          OTHERS                = 2.

      CALL FUNCTION 'ZGTMM_IF_O_WGTSPLY_SEND'
        DESTINATION LV_DEST
        EXPORTING
          I_SYSTEM_ID = P_IFSYT
        IMPORTING
          ZO_RESULT   = LV_RST
          ZO_MESSAGE  = LV_MSG
        TABLES
          OT_TAB      = LT_F077[]
        EXCEPTIONS
          OTHERS      = 1.
  ENDCASE.

  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00'.
      LV_RET = GC_S.
*      GV_CNT = LINES( GT_F009[] ).
      CASE 'X'.
        WHEN P_IF1.
          GV_CNT = LINES( GT_F076[] ).
        WHEN P_IF2.
          GV_CNT = LINES( GT_F077[] ).
      ENDCASE.
      GV_MSG = GV_CNT && '건 전송 성공'(M02).
    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

  PERFORM SAVE_LOG USING LV_RET
                         LV_MSG.

  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.

  CHECK P_ILOG = GC_X.
  PERFORM GET_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
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

  DATA : LT_LOG_IF1 LIKE ZGTMMT9210 OCCURS 0 WITH HEADER LINE.
  DATA : LT_LOG_IF2 LIKE ZGTMMT9220 OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF LT_SEL OCCURS 0,
           ZIFKEY LIKE ZGTMMT9210-ZIFKEY,
           ZSEQNO LIKE ZGTMMT9210-ZSEQNO,
         END   OF LT_SEL.

  PERFORM GET_SELECTED_ROWS USING GR_GRID 'M' 'X'.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE <GT_LIST> INTO <GS_LIST> INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    CASE 'X'.
      WHEN P_ILOG.
        ASSIGN COMPONENT 'LASTDATA' OF STRUCTURE <GS_LIST> TO FIELD-SYMBOL(<LFS_LAST>).

        IF <LFS_LAST> IS INITIAL.
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.

    LT_SEL = CORRESPONDING #( <GS_LIST> ).
    COLLECT LT_SEL.
  ENDLOOP.

  CHECK LT_SEL[] IS NOT INITIAL.

  CLEAR : GT_ROW, GS_ROW.

  CASE 'X'.
    WHEN P_IF1.
      LT_LOG_IF1[] = CORRESPONDING #( <GT_LIST> ).
      SORT LT_LOG_IF1 BY ZIFKEY DESCENDING
                         ZSEQNO ASCENDING.
      LOOP AT LT_SEL.
        READ TABLE LT_LOG_IF1 WITH KEY ZIFKEY = LT_SEL-ZIFKEY
                                       ZSEQNO  = LT_SEL-ZSEQNO.

        CHECK SY-SUBRC = 0.

        LOOP AT LT_LOG_IF1 FROM SY-TABIX.
          IF NOT (
                   LT_LOG_IF1-ZIFKEY = LT_SEL-ZIFKEY
                   AND
                   LT_LOG_IF1-ZSEQNO  = LT_SEL-ZSEQNO
                 ).
            EXIT.
          ENDIF.

          GS_ROW-INDEX = SY-TABIX.
          APPEND GS_ROW TO GT_ROW.

          GT_RLOG_IF1 = CORRESPONDING #( LT_LOG_IF1 ).
          APPEND GT_RLOG_IF1.
        ENDLOOP.
      ENDLOOP.
    WHEN P_IF2.
      LT_LOG_IF2[] = CORRESPONDING #( <GT_LIST> ).
      SORT LT_LOG_IF2 BY ZIFKEY DESCENDING
                         ZSEQNO ASCENDING.
      LOOP AT LT_SEL.
        READ TABLE LT_LOG_IF2 WITH KEY ZIFKEY = LT_SEL-ZIFKEY
                                       ZSEQNO  = LT_SEL-ZSEQNO.

        CHECK SY-SUBRC = 0.

        LOOP AT LT_LOG_IF2 FROM SY-TABIX.
          IF NOT (
                   LT_LOG_IF2-ZIFKEY = LT_SEL-ZIFKEY
                   AND
                   LT_LOG_IF2-ZSEQNO  = LT_SEL-ZSEQNO
                 ).
            EXIT.
          ENDIF.

          GS_ROW-INDEX = SY-TABIX.
          APPEND GS_ROW TO GT_ROW.

          GT_RLOG_IF2 = CORRESPONDING #( LT_LOG_IF2 ).
          APPEND GT_RLOG_IF2.
        ENDLOOP.
      ENDLOOP.
  ENDCASE.

  GR_GRID->SET_SELECTED_ROWS( IT_INDEX_ROWS = GT_ROW ).

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

  CASE 'X'.
    WHEN P_IF1.
      GT_RLOG_IF1[] = CORRESPONDING #( <GT_LIST> ).
    WHEN P_IF2.
      GT_RLOG_IF2[] = CORRESPONDING #( <GT_LIST> ).
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F009_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F009_DATA.

  LOOP AT GT_RLOG.
    GT_F009 = CORRESPONDING #( GT_RLOG ).
    PERFORM CONVERT_MATN1_OUTPUT USING GT_F009-MATNR.

    SHIFT GT_F009-RSNUM LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
    SHIFT GT_F009-RSPOS LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

    APPEND GT_F009.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_F006_MATNR
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

  CLEAR : GS_9000, GT_9060[].
  CLEAR : GT_9210[], GT_9220[].

  CASE 'X'.
    WHEN P_IF1.
      GS_9000-ZIFNO = GC_MM00022.
    WHEN P_IF2.
      GS_9000-ZIFNO = GC_MM00023.
  ENDCASE.

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
*  GS_9000-ZIFNO       = GC_MM00006.
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

  CASE 'X'.
    WHEN P_IF1.
      GT_9210[] = VALUE #( FOR LS_LOG_1 IN GT_RLOG_IF1
                           ( VALUE #( BASE CORRESPONDING #( LS_LOG_1 )
                                      ZIFKEY = GS_9000-ZIFKEY ) ) ).

      CHECK GT_9210[] IS NOT INITIAL.

      MODIFY ZGTMMT9210 FROM TABLE GT_9210.
      MODIFY ZGTMMT9000 FROM GS_9000.
    WHEN P_IF2.
      GT_9220[] = VALUE #( FOR LS_LOG_2 IN GT_RLOG_IF2
                           ( VALUE #( BASE CORRESPONDING #( LS_LOG_2 )
                                      ZIFKEY = GS_9000-ZIFKEY ) ) ).

      CHECK GT_9220[] IS NOT INITIAL.

      MODIFY ZGTMMT9220 FROM TABLE GT_9220.
      MODIFY ZGTMMT9000 FROM GS_9000.
  ENDCASE.

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
*&      --> GR_DOCK
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_OBJ USING PR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER
                   PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  PR_DOCK = NEW #( REPID     = SY-REPID
                   DYNNR     = SY-DYNNR
                   SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                   EXTENSION = 655 ).

  PR_GRID = NEW #( I_PARENT      = PR_DOCK
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

  "다운로드 기능(MC_MB_EXPORT) 삭제(송종면E 25.02.10)

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
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA      = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.
  PS_LAYO-GRID_TITLE = COND #( WHEN P_ILOG = 'X' THEN 'Interface 처리상태'(T01)
                               WHEN P_SEND = 'X' THEN 'Interface 대상'(T02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME     = SY-REPID
*     I_INTERNAL_TABNAME = PV_TNAME
      I_STRUCTURE_NAME   = CONV TABNAME( GV_TNAME )
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
      IT_DATA         = <GT_LIST>
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  CASE 'X'.
    WHEN P_IF1.
      LOOP AT PT_FCAT.
        CASE PT_FCAT-FIELDNAME.
          WHEN 'REQTYP'.
            PT_FCAT-SCRTEXT_L = '요청유형'.
            PT_FCAT-SCRTEXT_M = '요청유형'.
            PT_FCAT-SCRTEXT_S = '요청유형'.
          WHEN 'CU_CLS'.
            PT_FCAT-SCRTEXT_L = '일반/수탁 구분 코드'.
            PT_FCAT-SCRTEXT_M = '일반/수탁 구분 코드'.
            PT_FCAT-SCRTEXT_S = '일반/수탁 구분 코드'.
          WHEN 'CU_CLS_TXT'.
            PT_FCAT-SCRTEXT_L = '구분 텍스트'.
            PT_FCAT-SCRTEXT_M = '구분 텍스트'.
            PT_FCAT-SCRTEXT_S = '구분 텍스트'.
          WHEN 'ORIGIN_CD'.
            PT_FCAT-SCRTEXT_L = '국산/수입 구분 코드'.
            PT_FCAT-SCRTEXT_M = '국산/수입 구분 코드'.
            PT_FCAT-SCRTEXT_S = '국산/수입 구분 코드'.
          WHEN 'ORIGIN_TXT'.
            PT_FCAT-SCRTEXT_L = '구분 텍스트'.
            PT_FCAT-SCRTEXT_M = '구분 텍스트'.
            PT_FCAT-SCRTEXT_S = '구분 텍스트'.
          WHEN 'EBELN_EXT'.
            PT_FCAT-SCRTEXT_L = 'PO 번호'.
            PT_FCAT-SCRTEXT_M = 'PO 번호'.
            PT_FCAT-SCRTEXT_S = 'PO 번호'.
          WHEN 'BL_NO'.
            PT_FCAT-SCRTEXT_L = 'B/L 번호'.
            PT_FCAT-SCRTEXT_M = 'B/L 번호'.
            PT_FCAT-SCRTEXT_S = 'B/L 번호'.
          WHEN 'KUNNR_EXT'.
            PT_FCAT-SCRTEXT_L = '고객사ID'.
            PT_FCAT-SCRTEXT_M = '고객사ID'.
            PT_FCAT-SCRTEXT_S = '고객사ID'.
          WHEN 'NAME_K'.
            PT_FCAT-SCRTEXT_L = '고객사명'.
            PT_FCAT-SCRTEXT_M = '고객사명'.
            PT_FCAT-SCRTEXT_S = '고객사명'.
          WHEN 'LIFNR_EXT'.
            PT_FCAT-SCRTEXT_L = '공급사ID'.
            PT_FCAT-SCRTEXT_M = '공급사ID'.
            PT_FCAT-SCRTEXT_S = '공급사ID'.
          WHEN 'NAME_L'.
            PT_FCAT-SCRTEXT_L = '공급사명'.
            PT_FCAT-SCRTEXT_M = '공급사명'.
            PT_FCAT-SCRTEXT_S = '공급사명'.
          WHEN 'BRAND_ID'.
            PT_FCAT-SCRTEXT_L = '브랜드'.
            PT_FCAT-SCRTEXT_M = '브랜드'.
            PT_FCAT-SCRTEXT_S = '브랜드'.
          WHEN 'BRAND_TXT'.
            PT_FCAT-SCRTEXT_L = '브랜드명'.
            PT_FCAT-SCRTEXT_M = '브랜드명'.
            PT_FCAT-SCRTEXT_S = '브랜드명'.
          WHEN 'VEHIC_NO'.
            PT_FCAT-SCRTEXT_L = '차량번호'.
            PT_FCAT-SCRTEXT_M = '차량번호'.
            PT_FCAT-SCRTEXT_S = '차량번호'.
          WHEN 'DISPATCH_DAT'.
            PT_FCAT-SCRTEXT_L = '배차일자'.
            PT_FCAT-SCRTEXT_M = '배차일자'.
            PT_FCAT-SCRTEXT_S = '배차일자'.
          WHEN 'DISPATCH_RMRK'.
            PT_FCAT-SCRTEXT_L = '배차비고'.
            PT_FCAT-SCRTEXT_M = '배차비고'.
            PT_FCAT-SCRTEXT_S = '배차비고'.
          WHEN 'DISPATCH_CRID'.
            PT_FCAT-SCRTEXT_L = '배차생성자'.
            PT_FCAT-SCRTEXT_M = '배차생성자'.
            PT_FCAT-SCRTEXT_S = '배차생성자'.
          WHEN 'DISPATCH_CHGID'.
            PT_FCAT-SCRTEXT_L = '배차변경자'.
            PT_FCAT-SCRTEXT_M = '배차변경자'.
            PT_FCAT-SCRTEXT_S = '배차변경자'.
          WHEN 'CARR_ID'.
            PT_FCAT-SCRTEXT_L = '운송사ID'.
            PT_FCAT-SCRTEXT_M = '운송사ID'.
            PT_FCAT-SCRTEXT_S = '운송사ID'.
          WHEN 'CARR_NAME'.
            PT_FCAT-SCRTEXT_L = '운송사명'.
            PT_FCAT-SCRTEXT_M = '운송사명'.
            PT_FCAT-SCRTEXT_S = '운송사명'.
          WHEN 'DRIVER_NAME'.
            PT_FCAT-SCRTEXT_L = '운전자명'.
            PT_FCAT-SCRTEXT_M = '운전자명'.
            PT_FCAT-SCRTEXT_S = '운전자명'.
          WHEN 'DRIVER_TELNO'.
            PT_FCAT-SCRTEXT_L = '운전자폰번호'.
            PT_FCAT-SCRTEXT_M = '운전자폰번호'.
            PT_FCAT-SCRTEXT_S = '운전자폰번호'.
          WHEN 'GRDAT'.
            PT_FCAT-SCRTEXT_L = '입고일자'.
            PT_FCAT-SCRTEXT_M = '입고일자'.
            PT_FCAT-SCRTEXT_S = '입고일자'.
          WHEN 'CARR_WT'.
            PT_FCAT-SCRTEXT_L = '운송업체중량'.
            PT_FCAT-SCRTEXT_M = '운송업체중량'.
            PT_FCAT-SCRTEXT_S = '운송업체중량'.
          WHEN 'SHIP_RMRK'.
            PT_FCAT-SCRTEXT_L = '운송비고'.
            PT_FCAT-SCRTEXT_M = '운송비고'.
            PT_FCAT-SCRTEXT_S = '운송비고'.
          WHEN 'LASTDATA'.
            PT_FCAT-SCRTEXT_L = '최종전송'.
            PT_FCAT-SCRTEXT_M = '최종전송'.
            PT_FCAT-SCRTEXT_S = '최종전송'.
        ENDCASE.
        MODIFY PT_FCAT.
      ENDLOOP.
    WHEN P_IF2.
      LOOP AT PT_FCAT.
        CASE PT_FCAT-FIELDNAME.
          WHEN 'REQTYP'.
            PT_FCAT-SCRTEXT_L = '요청유형'.
            PT_FCAT-SCRTEXT_M = '요청유형'.
            PT_FCAT-SCRTEXT_S = '요청유형'.
          WHEN 'WEIGH_ID'.
            PT_FCAT-SCRTEXT_L = '계근자ID'.
            PT_FCAT-SCRTEXT_M = '계근자ID'.
            PT_FCAT-SCRTEXT_S = '계근자ID'.
          WHEN 'WEIGH_USR'.
            PT_FCAT-SCRTEXT_L = '계근자명'.
            PT_FCAT-SCRTEXT_M = '계근자명'.
            PT_FCAT-SCRTEXT_S = '계근자명'.
          WHEN 'BUKRS_WT'.
            PT_FCAT-SCRTEXT_L = '계근중량'.
            PT_FCAT-SCRTEXT_M = '계근중량'.
            PT_FCAT-SCRTEXT_S = '계근중량'.
          WHEN 'WEIGH_RMRK'.
            PT_FCAT-SCRTEXT_L = '실중량비고'.
            PT_FCAT-SCRTEXT_M = '실중량비고'.
            PT_FCAT-SCRTEXT_S = '실중량비고'.
          WHEN 'WEIGH_CRID'.
            PT_FCAT-SCRTEXT_L = '생성 ID'.
            PT_FCAT-SCRTEXT_M = '생성 ID'.
            PT_FCAT-SCRTEXT_S = '생성 ID'.
          WHEN 'WEIGH_CHGID'.
            PT_FCAT-SCRTEXT_L = '변경 ID'.
            PT_FCAT-SCRTEXT_M = '변경 ID'.
            PT_FCAT-SCRTEXT_S = '변경 ID'.
          WHEN 'FINAL_WT'.
            PT_FCAT-SCRTEXT_L = '마감중량'.
            PT_FCAT-SCRTEXT_M = '마감중량'.
            PT_FCAT-SCRTEXT_S = '마감중량'.
          WHEN 'LASTDATA'.
            PT_FCAT-SCRTEXT_L = '최종전송'.
            PT_FCAT-SCRTEXT_M = '최종전송'.
            PT_FCAT-SCRTEXT_S = '최종전송'.
        ENDCASE.
        MODIFY PT_FCAT.
      ENDLOOP.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = 'GR_GRID' ).

  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FCAT
*&      --> GR_GRID
*&      --> GS_LAYO
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO.

  CLEAR : GS_VARI.
  GS_VARI-REPORT   = SY-REPID.
  GS_VARI-HANDLE   = SY-DYNNR.
  GS_VARI-USERNAME = SY-UNAME.

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_BUFFER_ACTIVE      =
*     I_BYPASSING_BUFFER   =
*     I_CONSISTENCY_CHECK  =
*     I_STRUCTURE_NAME     =
*     IS_VARIANT           = GS_VARI
      I_SAVE               = GC_A
*     I_DEFAULT            = GC_X
      IS_LAYOUT            = PS_LAYO
*     IS_PRINT             =
*     IT_SPECIAL_GROUPS    =
      IT_TOOLBAR_EXCLUDING = GT_EXCL
*     IT_HYPERLINK         =
*     IT_ALV_GRAPHICS      =
*     IT_EXCEPT_QINFO      =
*     IR_SALV_ADAPTER      =
    CHANGING
      IT_OUTTAB            = <GT_LIST>
      IT_FIELDCATALOG      = PT_FCAT[].
*     IT_SORT              = PT_SORT[].
*     IT_FILTER            =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> GS_LAYO
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
      CALL METHOD GR_GRID->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_GRID, GR_DOCK.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA_IF1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA_IF1 .

  CHECK P_FRC     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
  CHECK GT_LIST_IF1[] IS NOT INITIAL.

  SELECT DISTINCT
         A~ZSEQNO        ,
         A~CU_CLS        ,
         A~CU_CLS_TXT    ,
         A~ORIGIN_CD     ,
         A~ORIGIN_TXT    ,
         A~EBELN_EXT     ,
         A~BL_NO         ,
         A~GRADE         ,
         A~KUNNR_EXT     ,
         A~NAME_K        ,
         A~LIFNR_EXT     ,
         A~NAME_L        ,
         A~BRAND_ID      ,
         A~BRAND_TXT     ,
         A~VEHIC_NO      ,
         A~DISPATCH_DAT  ,
         A~DISPATCH_RMRK ,
         A~DISPATCH_CRID ,
         A~DISPATCH_CHGID,
         A~CARR_ID       ,
         A~CARR_NAME     ,
         A~DRIVER_NAME   ,
         A~DRIVER_TELNO  ,
         A~GRDAT         ,
         A~CARR_WT       ,
*         A~MEINS         ,
         A~SHIP_RMRK     ,
         A~LVORM         ,
*-->> [한미소PJT] 한국미래소재 필드 추가 -- [S]
         A~EBELP_EXT       ,
         A~BL_SEQ          ,
         A~MATNR           ,
         A~MAKTX           ,
         A~EKGRP           ,
         A~ZTERM           ,
         A~INCO1           ,
         A~MENGE           ,
         A~PO_MEINS        ,
         A~NETPR           ,
         A~PEINH           ,
         A~BPRME           ,
         A~WAERS           ,
         A~TARE_WT         ,
         A~PKG_CNT         ,
         A~CONTAINER_NO    ,
         A~SEAL_NO         ,
         A~ZZLOADGRP       ,
         A~IN_DLV_NO       ,
         A~ZZIOTYP         ,
         A~ZZBSART         ,
         A~SHIP_FR_POST    ,
         A~SHIP_FR_NM      ,
         A~SHIP_FR_ADDR    ,
         A~SHIP_FR_ADDR_DTL,
         A~SHIP_TO_POST    ,
         A~SHIP_TO_NM      ,
         A~SHIP_TO_ADDR    ,
         A~SHIP_TO_ADDR_DTL,
         A~MATNR_01        ,
         A~NETPR_01        ,
         A~MATNR_02        ,
         A~NETPR_02        ,
         A~MATNR_03        ,
         A~NETPR_03        ,
         A~MATNR_04        ,
         A~NETPR_04        ,
         A~MATNR_05        ,
         A~NETPR_05        ,
         A~VEHIC_TYPE      ,
         A~UEBTO           ,
         A~UNTTO
*<<-- [한미소PJT] 한국미래소재 필드 추가 -- [E]
    FROM ZGTMMT9210 AS A
         INNER JOIN ZGTMMT9000 AS B
          ON A~ZIFKEY = B~ZIFKEY
   FOR ALL ENTRIES IN @GT_LIST_IF1
   WHERE A~ZSEQNO = @GT_LIST_IF1-ZSEQNO
     AND B~ZIFNO = @GC_MM00022
     AND B~SYSTEM_ID = @P_IFSYT
     AND B~ZSTAT = @GC_S
     AND A~ZIFKEY = (
                     SELECT MAX( AA~ZIFKEY )
                       FROM ZGTMMT9210 AS AA
                      WHERE AA~ZSEQNO = A~ZSEQNO
                    )
    INTO TABLE @DATA(LT_OLD).

  CHECK SY-SUBRC = 0.

  SORT LT_OLD BY ZSEQNO.
  SORT GT_LIST_IF1 BY ZSEQNO.

  LOOP AT GT_LIST_IF1 INTO DATA(LS_NEW).
    READ TABLE LT_OLD INTO DATA(LS_OLD)
                       WITH KEY
                                ZSEQNO         = LS_NEW-ZSEQNO
                                CU_CLS         = LS_NEW-CU_CLS
                                CU_CLS_TXT     = LS_NEW-CU_CLS_TXT
                                ORIGIN_CD      = LS_NEW-ORIGIN_CD
                                ORIGIN_TXT     = LS_NEW-ORIGIN_TXT
                                EBELN_EXT      = LS_NEW-EBELN_EXT
                                BL_NO          = LS_NEW-BL_NO
                                GRADE          = LS_NEW-GRADE
                                KUNNR_EXT      = LS_NEW-KUNNR_EXT
                                NAME_K         = LS_NEW-NAME_K
                                LIFNR_EXT      = LS_NEW-LIFNR_EXT
                                NAME_L         = LS_NEW-NAME_L
                                BRAND_ID       = LS_NEW-BRAND_ID
                                BRAND_TXT      = LS_NEW-BRAND_TXT
                                VEHIC_NO       = LS_NEW-VEHIC_NO
                                DISPATCH_DAT   = LS_NEW-DISPATCH_DAT
                                DISPATCH_RMRK  = LS_NEW-DISPATCH_RMRK
                                DISPATCH_CRID  = LS_NEW-DISPATCH_CRID
                                DISPATCH_CHGID = LS_NEW-DISPATCH_CHGID
                                CARR_ID        = LS_NEW-CARR_ID
                                CARR_NAME      = LS_NEW-CARR_NAME
                                DRIVER_NAME    = LS_NEW-DRIVER_NAME
                                DRIVER_TELNO   = LS_NEW-DRIVER_TELNO
                                GRDAT          = LS_NEW-GRDAT
                                CARR_WT        = LS_NEW-CARR_WT
*                                MEINS          = LS_NEW-MEINS
                                SHIP_RMRK      = LS_NEW-SHIP_RMRK
                                LVORM          = LS_NEW-LVORM
*-->> [한미소PJT] 한국미래소재 필드 추가 -- [S]
                                EBELP_EXT        = LS_NEW-EBELP_EXT
                                BL_SEQ           = LS_NEW-BL_SEQ
                                MATNR            = LS_NEW-MATNR
                                MAKTX            = LS_NEW-MAKTX
                                EKGRP            = LS_NEW-EKGRP
                                ZTERM            = LS_NEW-ZTERM
                                INCO1            = LS_NEW-INCO1
                                MENGE            = LS_NEW-MENGE
                                PO_MEINS         = LS_NEW-PO_MEINS
                                NETPR            = LS_NEW-NETPR
                                PEINH            = LS_NEW-PEINH
                                BPRME            = LS_NEW-BPRME
                                WAERS            = LS_NEW-WAERS
                                TARE_WT          = LS_NEW-TARE_WT
                                PKG_CNT          = LS_NEW-PKG_CNT
                                CONTAINER_NO     = LS_NEW-CONTAINER_NO
                                SEAL_NO          = LS_NEW-SEAL_NO
                                ZZLOADGRP        = LS_NEW-ZZLOADGRP
                                IN_DLV_NO        = LS_NEW-IN_DLV_NO
                                ZZIOTYP          = LS_NEW-ZZIOTYP
                                ZZBSART          = LS_NEW-ZZBSART
                                SHIP_FR_POST     = LS_NEW-SHIP_FR_POST
                                SHIP_FR_NM       = LS_NEW-SHIP_FR_NM
                                SHIP_FR_ADDR     = LS_NEW-SHIP_FR_ADDR
                                SHIP_FR_ADDR_DTL = LS_NEW-SHIP_FR_ADDR_DTL
                                SHIP_TO_POST     = LS_NEW-SHIP_TO_POST
                                SHIP_TO_NM       = LS_NEW-SHIP_TO_NM
                                SHIP_TO_ADDR     = LS_NEW-SHIP_TO_ADDR
                                SHIP_TO_ADDR_DTL = LS_NEW-SHIP_TO_ADDR_DTL
                                MATNR_01         = LS_NEW-MATNR_01
                                NETPR_01         = LS_NEW-NETPR_01
                                MATNR_02         = LS_NEW-MATNR_02
                                NETPR_02         = LS_NEW-NETPR_02
                                MATNR_03         = LS_NEW-MATNR_03
                                NETPR_03         = LS_NEW-NETPR_03
                                MATNR_04         = LS_NEW-MATNR_04
                                NETPR_04         = LS_NEW-NETPR_04
                                MATNR_05         = LS_NEW-MATNR_05
                                NETPR_05         = LS_NEW-NETPR_05
                                VEHIC_TYPE       = LS_NEW-VEHIC_TYPE.
*<<-- [한미소PJT] 한국미래소재 필드 추가 -- [E]

    IF SY-SUBRC = 0.
      DELETE GT_LIST_IF1 WHERE ZSEQNO = LS_NEW-ZSEQNO.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F076_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F076_DATA .

  LOOP AT GT_RLOG_IF1.
    GT_F076 = CORRESPONDING #( GT_RLOG_IF1 ).

*    PERFORM CONVERT_MATN1_OUTPUT USING GT_F009-MATNR.
*    SHIFT GT_F009-RSNUM LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
*    SHIFT GT_F009-RSPOS LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

    APPEND GT_F076.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEPT_SEND_DATA_IF2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA_IF2 .

  CHECK P_FRC     IS INITIAL. "전송된 정보는 재전송 불가하게 조회 정보에서 삭제
  CHECK GT_LIST_IF2[] IS NOT INITIAL.


  SELECT DISTINCT
         A~ZSEQNO	     ,
         A~WEIGH_ID    ,
         A~WEIGH_USR   ,
         A~BUKRS_WT    ,
         A~WEIGH_RMRK  ,
         A~WEIGH_CRID  ,
         A~WEIGH_CHGID ,
         A~DIFF_WT     ,
         A~FINAL_WT    ,
         A~DEVIAT
*         A~MEINS      ,
*         A~LVORM      ,
    FROM ZGTMMT9220 AS A
         INNER JOIN ZGTMMT9000 AS B
          ON A~ZIFKEY = B~ZIFKEY
   FOR ALL ENTRIES IN @GT_LIST_IF2
   WHERE A~ZSEQNO = @GT_LIST_IF2-ZSEQNO
     AND B~ZIFNO = @GC_MM00023
     AND B~SYSTEM_ID = @P_IFSYT
     AND B~ZSTAT = @GC_S
     AND A~ZIFKEY = (
                     SELECT MAX( AA~ZIFKEY )
                       FROM ZGTMMT9220 AS AA
                      WHERE AA~ZSEQNO = A~ZSEQNO
                    )
    INTO TABLE @DATA(LT_OLD).

  CHECK SY-SUBRC = 0.

  SORT LT_OLD BY ZSEQNO.
  SORT GT_LIST_IF2 BY ZSEQNO.

  LOOP AT GT_LIST_IF2 INTO DATA(LS_NEW).
    READ TABLE LT_OLD INTO DATA(LS_OLD)
                       WITH KEY
                                ZSEQNO      = LS_NEW-ZSEQNO
                                WEIGH_ID    = LS_NEW-WEIGH_ID
                                WEIGH_USR   = LS_NEW-WEIGH_USR
                                BUKRS_WT    = LS_NEW-BUKRS_WT
                                WEIGH_RMRK  = LS_NEW-WEIGH_RMRK
                                WEIGH_CRID  = LS_NEW-WEIGH_CRID
                                WEIGH_CHGID = LS_NEW-WEIGH_CHGID
                                DIFF_WT     = LS_NEW-DIFF_WT
                                FINAL_WT    = LS_NEW-FINAL_WT
*                                MEINS       = LS_NEW-MEINS
                                DEVIAT      = LS_NEW-DEVIAT.
*                                LVORM       = LS_NEW-LVORM.

    IF SY-SUBRC = 0.
      DELETE GT_LIST_IF2 WHERE ZSEQNO = LS_NEW-ZSEQNO.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_F077_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_F077_DATA .

  LOOP AT GT_RLOG_IF2.
    GT_F077 = CORRESPONDING #( GT_RLOG_IF2 ).

*    PERFORM CONVERT_MATN1_OUTPUT USING GT_F009-MATNR.
*    SHIFT GT_F009-RSNUM LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)
*    SHIFT GT_F009-RSPOS LEFT DELETING LEADING '0'. "추가(송종면E 24.12.10)

    APPEND GT_F077.
  ENDLOOP.

ENDFORM.
