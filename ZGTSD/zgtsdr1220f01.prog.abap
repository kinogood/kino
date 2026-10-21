*&---------------------------------------------------------------------*
*& Include          ZGTSDR1220F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-제품군
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_10 )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_23 )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_31 )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_41 )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_43 )
      TO S_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SPART_90 )
      TO S_SPART.

*-자재유형
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_FERT )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_MCHF )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_MCFE )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_MCHA )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_HAWA )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_SCRP )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_ROH1 )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_ROH2 )
      TO S_MTART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_MTART_MRM1 )
      TO S_MTART.

*-플랜트
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_WERKS_6500 )
      TO S_WERKS.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_WERKS_6581 )
      TO S_WERKS.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_WERKS_6591 )
      TO S_WERKS.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_WERKS_6600 )
      TO S_WERKS.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_WERKS_6691 )
      TO S_WERKS.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

  PERFORM AUTHORITY_CHECK.

  PERFORM CHECK_SCREEN_INPUT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INVISIBLE = 1.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .
  DATA: GT_T001W LIKE T001W OCCURS 0 WITH HEADER LINE,
        GT_TSPA  LIKE TSPA OCCURS 0 WITH HEADER LINE,
        LV_SUBRC LIKE SY-SUBRC.

  SELECT *
    INTO TABLE GT_T001W
    FROM T001W
   WHERE WERKS IN S_WERKS.

  LOOP  AT  GT_T001W.
    CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
      EXPORTING
        I_WERKS = GT_T001W-WERKS
        I_TYPE  = '4'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '플랜트에 대한 권한이 없읍니다'
                        GT_T001W-WERKS.
    ENDIF.
  ENDLOOP.

  SELECT *
    INTO TABLE GT_TSPA
    FROM TSPA
   WHERE SPART IN S_SPART.

  LOOP  AT  GT_TSPA.
    CLEAR : LV_SUBRC.
    CALL FUNCTION 'Z_SD_AUTHORIZATION_CHECK'
      EXPORTING
        I_SPART = GT_TSPA-SPART
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '제품군에 대한 권한이 없읍니다'
                        GT_TSPA-SPART.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SCREEN_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SCREEN_INPUT .

  IF NOT S_MTART[] IS INITIAL.

    SELECT * FROM T134
             WHERE MTART IN S_MTART.
      IF T134-MTART NE 'FERT' AND T134-MTART NE 'MCFE' AND
         T134-MTART NE 'HAWA' AND T134-MTART NE 'MCHA' AND
*         T134-MTART NE 'HALB' AND
         T134-MTART NE 'MCHF' AND
         T134-MTART NE 'ROH1' AND
         T134-MTART NE 'ROH2' AND
         T134-MTART NE 'MRM1' AND
*         T134-MTART NE 'ROH1' AND T134-MTART NE 'MFER' AND
*         T134-MTART NE 'MHAW' AND
         T134-MTART NE 'SCRP'.

        MESSAGE E000 WITH
 '자재유형 FERT,HAWA,MCFE,MCHA,MCHF,SCRP,ROH1,ROH2,MRM1만 대상입니다'.
* '자재유형 FERT,HAWA,HALB,MCFE,MCHA,MCHF,ROH1,MFER,MHAW,SCRP만 대상입니다'.
      ENDIF.

    ENDSELECT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  data_get_from_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_GET_FROM_DB .

  DATA:LWERKS(4).
  DATA: LL_CNT  TYPE I.

  CLEAR GMARC.REFRESH GMARC.

  SELECT A~MATNR  "자재코드
         A~SPART  "제품군
         A~MTART  "자재유형
         A~MEINS  "기본단위
         B~WERKS  "플랜트
         B~PSTAT  "신규/기존  "V: 영업뷰 존재
         B~DISMM  "MRP 유형
         C~MAKTX  "자재명
    INTO CORRESPONDING FIELDS OF TABLE GMARC
         FROM MARA AS A
         JOIN MARC AS B
            ON A~MATNR = B~MATNR
         JOIN MAKT AS C
            ON A~MATNR = C~MATNR
       WHERE A~MATNR IN S_MATNR
         AND A~SPART IN S_SPART
         AND A~MTART IN S_MTART
         AND A~LVORM = ' '
         AND B~WERKS IN S_WERKS
         AND C~SPRAS = '3'.

  COUNT = LINES( GMARC ).

  PERFORM PROGRESS_INDICATOR USING COUNT '대상데이타 가져오는 중...'.

*--------------------------------------------------------------------*
**-- 26.10 적재그룹 추가 / 적재그룹 추가 조건일시
*--------------------------------------------------------------------*
  IF P_PS5 IS NOT INITIAL.
    SELECT FROM MARC AS A INNER JOIN MVKE AS B
                        ON A~MATNR EQ B~MATNR
           FIELDS DISTINCT A~MATNR, A~WERKS
      WHERE A~LADGR EQ @SPACE
        AND B~VKORG EQ @GC_VKORG_6000
        AND B~VTWEG EQ '10'
        AND A~MATNR IN @S_MATNR
        AND A~WERKS IN @S_WERKS
        AND A~LVORM EQ @SPACE
        AND B~LVORM EQ @SPACE
        AND A~PSTAT LIKE '%D%'
      INTO TABLE @DATA(LT_LADGR).
  ENDIF.

*--------------------------------------------------------------------*

*  신규기존 체크
*  p_ps2 : 기존
*  p_ps3 : 신규
*  p_ps4 : 확장
  LOOP AT  GMARC.

    IF GMARC-WERKS+0(1) = '6'.
      GMARC-VKORG = GC_VKORG_6000.
    ENDIF.

    IF   P_PS2 = 'X'.
*        기존의 경우, 플랜트 뷰(marc)가 없으면 대상에서 삭제
      IF GMARC-PSTAT NA 'V'.
        DELETE GMARC. CONTINUE.
      ENDIF.

    ELSEIF P_PS3 = 'X'.
*        신규의 경우, 영업/플랜트 뷰(marc)가 있으면 삭제
*      IF GMARC-PSTAT CA 'V'.
*        DELETE GMARC. CONTINUE.
*      ENDIF.

    ELSEIF P_PS4 = 'X'.
*        확장의 경우, 영업/플랜트 뷰(marc)가 있으면 삭제
*        확장의 경우, 반드시 MRP view가 확장되어 있어야 함
      IF GMARC-PSTAT CA 'V'.
        DELETE GMARC. CONTINUE.
      ENDIF.

      IF GMARC-DISMM = ''.
        DELETE GMARC. CONTINUE.
      ENDIF.

    ENDIF.



* 제.상품코드의 기본 플랜트를 가져옴.
* 기본 플랜트는 설계의 W/F TABLE활용 (자재코드 생성후 BASIC,MRP VIEW
* 생성 후 타모듈에 전송된 W/F내역이며 여기있는 기본 PLANT정보를 활용함.)
* 이 플랜트 정보를 참조하여
* 1) 신규생성의 경우 납품플랜트로 활용
* 2) 확장생성의 경우 이미 생성된 적이 있는지 확인
    IF     P_PS4 = 'X'.

      SELECT SINGLE WERKS INTO LWERKS
             FROM ZEDT7440
             WHERE MATNR = GMARC-MATNR.
      IF SY-SUBRC NE 0.
        DELETE GMARC. CONTINUE.
      ENDIF.

*          기존조회
*          신규생성
    ELSEIF GMARC-PSTAT NA 'V'.

*->>[CHG]--------------------------------------S 가온전선
*      CLEAR LWERKS.
*      SELECT SINGLE WERKS INTO LWERKS
*             FROM ZEDT7440
*             WHERE MATNR = GMARC-MATNR
*               AND WERKS = GMARC-WERKS.
*
*      IF LWERKS = ' '.
*        DELETE GMARC. CONTINUE.
*      ELSE.
*        GMARC-WERKS = LWERKS.
*      ENDIF.
*-<<[CHG]--------------------------------------E 가온전선


    ENDIF.  "    IF  GMARC-PSTAT NA 'V'.
*-


*->>[CHG]--------------------------------------S 가온전선
** 양산요청번호
** --> 전선설계 System
*    SELECT SINGLE
*          VBELN MAX( POSNR ) INTO (GMARC-VBELN,GMARC-POSNR)
*                   FROM ZEDT0060
*                   WHERE NEW_MATNR = GMARC-MATNR
*                   AND WERKS       = GMARC-WERKS
*                   GROUP BY VBELN.
*
*    IF GMARC-VBELN NE ' '.
*      HMARA-ICON = C_ICON_NOM.
*    ELSE.
*
** --> 부품설계 System
*      SELECT SINGLE
*            VBELN MAX( POSNR ) INTO (GMARC-VBELN,GMARC-POSNR)
*                 FROM ZEDT7040
*                  WHERE MATNR = GMARC-MATNR
*                    AND ACTIVE_IND = 'X'
*                    GROUP BY VBELN.
*
*      IF     GMARC-VBELN NE ' '.
*        HMARA-ICON = C_ICON_NOM.
*      ELSEIF GMARC-MTART = 'KMAT'.
*        HMARA-ICON = C_ICON_PARK.
*      ELSE.
*
*        SELECT SINGLE MAX( SEQNO )
*          INTO LS_SEQNO
*          FROM ZSD0119T
*         WHERE MATN2 = GMARC-MATNR
*           AND RJTYP = ''
*           AND VBELN LIKE '1%'
*          GROUP BY VBELN POSNR.
*
*        IF LS_SEQNO NE ' '.
*
*          SELECT SINGLE VBELN  POSNR
*            INTO (GMARC-VBELN,GMARC-POSNR)
*            FROM ZSD0119T
*           WHERE MATN2 = GMARC-MATNR
*             AND RJTYP = ''
*             AND VBELN LIKE '1%'
*             AND SEQNO = LS_SEQNO.
*
*          IF  GMARC-VBELN NE ' '.
*            HMARA-ICON = C_ICON_NOM.
*          ENDIF.
*
*        ELSEIF GMARC-MTART = 'KMAT'.
*          HMARA-ICON = C_ICON_PARK.
*
*        ELSE.
** --> 설계하지 않는 경우는 여기서 찾음
*          SELECT SINGLE
*               VBELN MAX( POSNR ) INTO (GMARC-VBELN,GMARC-POSNR)
*                    FROM ZEDT7120
*                   WHERE MATNR = GMARC-MATNR
*                   GROUP BY VBELN.
*
*          IF GMARC-VBELN NE ' '.
*            HMARA-ICON = C_ICON_NOM.
*          ELSE.
*            HMARA-ICON = C_ICON_PARK.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.
*--

*    IF GMARC-WERKS+0(1) = '1'.
*      GMARC-VKORG  = '1000'.
*    ELSEIF GMARC-WERKS+0(1) = '3'.
*      GMARC-VKORG  = '3000'.
*    ELSEIF GMARC-WERKS+0(1) = '5'.
*      GMARC-VKORG  = '5000'.
*    ELSE.
*      GMARC-VKORG   = '2000'.
*    ENDIF.

*-<<[CHG]--------------------------------------E 가온전선
****C20090707_86411
**** icon 결정
    IF HMARA-ICON = '@5B@'. "GREEN

      CLEAR: LL_CNT.

      SELECT COUNT(*)
        INTO LL_CNT
        FROM MVKE
       WHERE VKORG = GMARC-VKORG
         AND MATNR = GMARC-MATNR.


      IF LL_CNT > 1.

      ELSEIF LL_CNT = 1.
        HMARA-ICON = C_ICON_SP.
      ELSE.
        HMARA-ICON = C_ICON_PARK.
      ENDIF.

    ENDIF.

*  양산번호 유무체크
* 1) 양산의뢰번호가 있는 경우
*    조회조건이 "양산의뢰번호 없음"이면 대상 삭제
*    아니면 양산의뢰번호에 대한 특성값 가져옮.
* 2) 양산의뢰번호가 없는 경우
*    조회조건이 "양산의뢰번호 있음"이면 대상 삭제.

    IF GMARC-VBELN NE SPACE.

      IF P_VB3 = 'X'.
        DELETE GMARC. CONTINUE.
      ENDIF.

      PERFORM GET_CUOBJ_DATA. "특성치가져오기

      SELECT  SINGLE VKORG
        INTO GMARC-VKORG
        FROM VBAK
       WHERE VBELN = GMARC-VBELN. "JS, LS조직구분위해

      IF GMARC-VKORG+0(1) = GMARC-WERKS+0(1).
        GMARC-VTWEG  = 10.          "유통채널은 10으로 설정한다.
      ELSE.
        DELETE GMARC. CONTINUE.
      ENDIF.

    ELSE.

      IF P_VB2 = 'X'.
        DELETE GMARC. CONTINUE.
      ENDIF.

    ENDIF.

*->>[CHG]--------------------------------------S 가온전선
    GMARC-VTWEG  = 10.
*-<<[CHG]--------------------------------------E 가온전선
*--


*--------------------------------------------------------------------*
**-- 26.10 적재그룹 추가 / 적재그룹 추가 조건일시
*--------------------------------------------------------------------*
    IF P_PS5 EQ ABAP_TRUE.
      READ TABLE LT_LADGR TRANSPORTING NO FIELDS WITH KEY MATNR = GMARC-MATNR
                                                          WERKS = GMARC-WERKS.
      IF SY-SUBRC NE 0.
        DELETE GMARC. CONTINUE.
      ENDIF.
    ENDIF.
*--------------------------------------------------------------------*


    MODIFY GMARC.
    MOVE-CORRESPONDING GMARC TO HMARA.

    COLLECT HMARA.

  ENDLOOP.


*--------------------------------------------------------------------*
**-- 26.10 적재그룹 추가 / 적재그룹 추가 조건이 아닐시
*--------------------------------------------------------------------*
  IF P_PS5 IS INITIAL.
* 영업조직 유통경로(50)
    LOOP AT GMARC WHERE VTWEG  = '10'.

      GMARC-VTWEG  = '50'.
      APPEND GMARC.CLEAR GMARC.

    ENDLOOP.
  ENDIF.

  IF P_PS2 = 'X' OR P_PS3 = 'X'.

    DATA(LT_TEMP) = GMARC[].
    SORT LT_TEMP BY MATNR VKORG VTWEG.
    DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING MATNR VKORG VTWEG.
    IF LT_TEMP[] IS NOT INITIAL.
      SELECT MATNR,VKORG,VTWEG
        FROM MVKE
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE MATNR EQ @LT_TEMP-MATNR
         AND VKORG EQ @LT_TEMP-VKORG
         AND VTWEG EQ @LT_TEMP-VTWEG
        INTO TABLE @DATA(LT_MVKE).
      SORT LT_MVKE BY MATNR VKORG VTWEG.
    ENDIF.

    LOOP AT GMARC INTO DATA(LS_GMARC).
      DATA(LV_INDEX) = SY-TABIX.
      READ TABLE LT_MVKE TRANSPORTING NO FIELDS WITH KEY MATNR = LS_GMARC-MATNR
                                                         VKORG = LS_GMARC-VKORG
                                                         VTWEG = LS_GMARC-VTWEG
                                                BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        IF P_PS3 = 'X'.
          DELETE GMARC INDEX LV_INDEX.
        ENDIF.
      ELSE.
        IF P_PS2 = 'X'.
          DELETE GMARC INDEX LV_INDEX.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR:HMARA[].
    LOOP AT GMARC INTO LS_GMARC.
      MOVE-CORRESPONDING LS_GMARC TO HMARA.
      COLLECT HMARA.
    ENDLOOP.

  ENDIF.

  FREE:LT_MVKE,LV_INDEX,LS_GMARC.
ENDFORM.                    " data_get_from_db
*&---------------------------------------------------------------------*
*&      Form  display_item_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ITEM_DATA .
  G_REPID = SY-REPID.
  GS_VARIANT-REPORT = G_REPID.
  G_SAVE           = 'A'.

  G_TABNAME_HEADER = 'HMARA'.
  G_TABNAME_ITEM   = 'GMARC'.

  CLEAR GS_KEYINFO.
  GS_KEYINFO-HEADER01 = 'MATNR'.
  GS_KEYINFO-ITEM01   = 'MATNR'.
  GS_KEYINFO-HEADER02 = 'WERKS'.
  GS_KEYINFO-ITEM02   = 'WERKS'.

  PERFORM SET_FIELDCAT_INIT  USING GT_FIELDCAT[].

  PERFORM SET_EVENTTAB_BUILD USING GT_EVENTS[].

  PERFORM SET_SP_GROUP_BUILD USING GT_SP_GROUP[].

  PERFORM SET_LAYOUT_BUILD   USING GS_LAYOUT.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = G_REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = GT_FIELDCAT[]
      IT_SPECIAL_GROUPS  = GT_SP_GROUP[]
      I_DEFAULT          = G_DEFAULT
      I_SAVE             = G_SAVE
      IS_VARIANT         = G_VARIANT
      IT_EVENTS          = GT_EVENTS[]
      I_TABNAME_HEADER   = G_TABNAME_HEADER
      I_TABNAME_ITEM     = G_TABNAME_ITEM
      IS_KEYINFO         = GS_KEYINFO
      I_BUFFER_ACTIVE    = 'X'
      I_BYPASSING_BUFFER = 'X'
    TABLES
      T_OUTTAB_HEADER    = HMARA
      T_OUTTAB_ITEM      = GMARC.

ENDFORM.                    " display_item_data
*&------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*       at user command event에 기술할 내용을 적는?
*-------------------------------------------------------------------*
FORM USER_COMMAND USING P_UCOMM    LIKE SY-UCOMM
                        P_SELFIELD TYPE SLIS_SELFIELD.

  CASE P_UCOMM.

    WHEN '&IC1'.

    WHEN 'EXEC'.  "자재마스터생성
      P_SELFIELD-REFRESH = 'X'.
*--------------------------------------------------------------------*
**-- 26.10 적재그룹 조회시 적재그룹만 추가
*--------------------------------------------------------------------*
      CASE P_PS5.
        WHEN ABAP_TRUE.
          PERFORM MATERIAL_MASTER_CREATE_LADGR.
        WHEN OTHERS.
          PERFORM MATERIAL_MASTER_CREATE.
      ENDCASE.
*--------------------------------------------------------------------*

  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*----------------------------------------------------------------------*
*       100 번 PF-STATUS 세팅.
*----------------------------------------------------------------------*
FORM  PF_STATUS_SET USING P_RT_EXTAB TYPE SLIS_T_EXTAB.

*->>[CHG]--------------------------------------S 가온전선
  IF P_PS2 = 'X'.
    SET PF-STATUS 'MAIN' EXCLUDING 'EXEC'.
  ELSE.
    SET PF-STATUS 'MAIN'.
  ENDIF.

*  IF P_VB3 = 'X'.
*    SET PF-STATUS 'MAIN' EXCLUDING 'EXEC'.
*  ELSE.
*    SET PF-STATUS 'MAIN'.
*  ENDIF.
*-<<[CHG]--------------------------------------S 가온전선
ENDFORM.                    "pf_status_set
*&---------------------------------------------------------------------*
*&      Form  TOP_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA:CNT TYPE I.
  CNT = SY-LINSZ / 2 - 14.

  WRITE AT  CNT '----------------------------------'.
  WRITE:AT /CNT '|  자재마스터 영업뷰 자동생성    |' COLOR 2.
  WRITE:AT /CNT '----------------------------------'.

  SKIP.

ENDFORM.                    " TOP_WRITE
*&---------------------------------------------------------------------*
*&      Form  init_value_setting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_VALUE_SETTING .

  IF S_MTART[] IS INITIAL.
    S_MTART-SIGN   = 'I'.
    S_MTART-OPTION = 'EQ'.
    S_MTART-LOW = 'FERT'. APPEND S_MTART.
    S_MTART-LOW = 'HAWA'. APPEND S_MTART.
*    S_MTART-LOW = 'HALB'. APPEND S_MTART.
    S_MTART-LOW = 'MCFE'. APPEND S_MTART.
    S_MTART-LOW = 'MCHA'. APPEND S_MTART.
    S_MTART-LOW = 'MCHF'. APPEND S_MTART.
*   자동차부품을 위해추가
*    S_MTART-LOW = 'ROH1'. APPEND S_MTART.
*   기계 자재유형 추가 060712 SDB01
*    S_MTART-LOW = 'MFER'. APPEND S_MTART.
*    S_MTART-LOW = 'MHAW'. APPEND S_MTART.
*    S_MTART-LOW = 'MDIE'. APPEND S_MTART.
    S_MTART-LOW = 'SCRP'. APPEND S_MTART.
    S_MTART-LOW = 'ROH1'. APPEND S_MTART.
    S_MTART-LOW = 'ROH2'. APPEND S_MTART.
    S_MTART-LOW = 'MRM1'. APPEND S_MTART.
  ENDIF.

ENDFORM.                    " init_value_setting
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM SET_FIELDCAT_INIT  USING P_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: L_FIELDCAT_S  TYPE SLIS_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_HEADER
      I_INCLNAME         = G_REPID
    CHANGING
      CT_FIELDCAT        = P_FIELDCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_ITEM
      I_INCLNAME         = G_REPID
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
    CHANGING
      CT_FIELDCAT        = P_FIELDCAT[].

  LOOP AT P_FIELDCAT INTO L_FIELDCAT_S.

    CASE L_FIELDCAT_S-FIELDNAME.
      WHEN 'MAKTX'.
        IF L_FIELDCAT_S-TABNAME = 'GMARC'.
          L_FIELDCAT_S-EMPHASIZE = 'C500'.
        ENDIF.

      WHEN 'SPART' OR 'MTART' OR 'PSTAT'.
        L_FIELDCAT_S-EMPHASIZE = 'C700'.

      WHEN 'AUMNG' OR 'LFMNG' OR 'SCMNG'.

        L_FIELDCAT_S-EMPHASIZE = 'C300'.
        L_FIELDCAT_S-QFIELDNAME = 'VRKME'.

      WHEN 'MESSG'.
        L_FIELDCAT_S-SELTEXT_M = '전기결과'.
        L_FIELDCAT_S-DDICTXT   = 'M'.
        L_FIELDCAT_S-EMPHASIZE = 'C500'.
    ENDCASE.

    MODIFY P_FIELDCAT FROM L_FIELDCAT_S.

  ENDLOOP.

ENDFORM.                    " set_fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  set_eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM SET_EVENTTAB_BUILD USING P_EVENTS TYPE SLIS_T_EVENT.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = P_EVENTS.

  LOOP AT P_EVENTS INTO LS_EVENT.

    IF  LS_EVENT-NAME = SLIS_EV_TOP_OF_PAGE.
      LS_EVENT-FORM = GC_TOP_OF_PAGE.
    ELSEIF LS_EVENT-NAME = SLIS_EV_USER_COMMAND.
      LS_EVENT-FORM = GC_USER_COMMAND.
    ELSEIF LS_EVENT-NAME = SLIS_EV_PF_STATUS_SET.
      LS_EVENT-FORM = GC_PF_STATUS_SET.
    ENDIF.

    MODIFY P_EVENTS FROM LS_EVENT.

  ENDLOOP.

ENDFORM.                    " set_eventtab_build
*&---------------------------------------------------------------------*
*&      Form  set_sp_group_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SP_GROUP[]  text
*----------------------------------------------------------------------*
FORM SET_SP_GROUP_BUILD USING P_GROUP TYPE SLIS_T_SP_GROUP_ALV.

  DATA: LS_SP_GROUP TYPE SLIS_SP_GROUP_ALV.
  CLEAR  LS_SP_GROUP.

  LS_SP_GROUP-SP_GROUP = 'A'.
  LS_SP_GROUP-TEXT     = 'USER SETTING'.
  APPEND LS_SP_GROUP TO P_GROUP.

ENDFORM.                    " set_sp_group_build
*&---------------------------------------------------------------------*
*&      Form  set_layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM SET_LAYOUT_BUILD  USING  RS_LAYOUT TYPE SLIS_LAYOUT_ALV.

  RS_LAYOUT-HEADER_TEXT          = 'DOCUMENT HEADER'.
  RS_LAYOUT-ITEM_TEXT            = 'DOCUMENT ITEM'.
  RS_LAYOUT-DEFAULT_ITEM         = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE    = 'X'.
  RS_LAYOUT-BOX_FIELDNAME        = 'MARK'.
  RS_LAYOUT-BOX_TABNAME          = G_TABNAME_HEADER.
  RS_LAYOUT-DETAIL_POPUP         = 'X'.
  RS_LAYOUT-ZEBRA                = 'X'.
  RS_LAYOUT-EXPAND_FIELDNAME     = 'EXPEND'.
  RS_LAYOUT-EXPAND_ALL           = 'X'.
*  rs_layout-lights_fieldname     = 'LIGHT'.

ENDFORM.                    " set_layout_build
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MATERIAL_MASTER_CREATE .

  DATA: LS_BAPIMATHEAD LIKE BAPIMATHEAD,
        LS_BAPI_MARA   LIKE BAPI_MARA,
        LS_BAPI_MARAX  LIKE BAPI_MARAX,
        LS_BAPI_MVKE   LIKE BAPI_MVKE,
        LS_BAPI_MVKEX  LIKE BAPI_MVKEX,
        LS_BAPI_MARC   LIKE BAPI_MARC,
        LS_BAPI_MARCX  LIKE BAPI_MARCX,
        LS_BAPI_MARD   LIKE BAPI_MARD,
        LS_BAPI_MARDX  LIKE BAPI_MARDX,
        LS_BAPI_MBEW   LIKE BAPI_MBEW,
        LS_BAPI_MBEWX  LIKE BAPI_MBEWX.
  DATA: LS_RETURN2 LIKE BAPIRET2.
  DATA: LT_BAPI_MAKT     LIKE TABLE OF BAPI_MAKT WITH HEADER LINE,
        LT_BAPI_MARM     LIKE TABLE OF BAPI_MARM WITH HEADER LINE,
        LT_BAPI_MARMX    LIKE TABLE OF BAPI_MARMX WITH HEADER LINE,
        LT_BAPI_MLAN     LIKE TABLE OF BAPI_MLAN WITH HEADER LINE,
        LT_BAPIPAREX     LIKE TABLE OF BAPIPAREX WITH HEADER LINE,
        LT_BAPIPAREXX    LIKE TABLE OF BAPIPAREXX WITH HEADER LINE,
        LT_RETURNMESSAGE LIKE TABLE OF BAPI_MATRETURN2 WITH HEADER LINE.

  DATA: L_EXIT,
        LDISMM LIKE MARC-DISMM.
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR:GT_ZGTSDT9030[].

  CLEAR : COUNT, COUNTER.
  CALL FUNCTION 'MESSAGES_INITIALIZE'.
  COUNT = LINES( GMARC ).

*===> Start
  LOOP AT HMARA WHERE MARK = 'X'.

    LOOP AT GMARC WHERE MATNR =  HMARA-MATNR AND
                        WERKS =  HMARA-WERKS.

      PERFORM PROGRESS_INDICATOR USING COUNT '자재마스터 생성중...'.

* 0.Header data (제어정보 헤더세그멘트)
      PERFORM SET_BAPI_MAT_HEAD CHANGING LS_BAPIMATHEAD
                                         L_EXIT.
      CHECK L_EXIT IS INITIAL.

* 1.Basic view - MARA (클라이언트 레벨의 자재데이타)
      PERFORM SET_BAPI_MARA USING LS_BAPIMATHEAD
                         CHANGING LS_BAPI_MARA
                                  LS_BAPI_MARAX.

*  050926 : SDB01 DIV:32( 전력기기 ) 공통LOGIC 적용함.
*           왜 단위 view를 전력기기만 했지? MARA때문인가?
* 2.Basic view - MARM (단위)
*      perform set_bapi_marm tables lt_bapi_marm
*                                   lt_bapi_marmx
*                           using ls_bapimathead.
*

* 3.Sales view - MVKE (영업데이타)
      PERFORM SET_BAPI_MVKE USING LS_BAPIMATHEAD
                         CHANGING LS_BAPI_MVKE
                                  LS_BAPI_MVKEX.

      LS_BAPI_MARA-ITEM_CAT = LS_BAPI_MVKE-ITEM_CAT."일반품목법주
      LS_BAPI_MARAX-ITEM_CAT = 'X'.

* 4.Sales Plant - Marc (플랜트데이타)
      IF GMARC-VTWEG = '10'.
        PERFORM SET_BAPI_MARC USING LS_BAPIMATHEAD
                           CHANGING LS_BAPI_MARC
                                    LS_BAPI_MARCX
                                    LS_RETURN2.
      ENDIF.

* 5.Sales view - MLAN (세금데이타)
      PERFORM SET_BAPI_MLAN TABLES LT_BAPI_MLAN
                             USING LS_BAPIMATHEAD.

*{ 기능개선 60722 - 추가
      PERFORM CHECK_MATERIAL_LOCK USING GMARC-MATNR
                                        GV_MSGV1.
      IF GV_MSGV1 IS NOT INITIAL.
        LS_RETURN2-TYPE       = 'E'.
        LS_RETURN2-ID         = 'M3'.
        LS_RETURN2-NUMBER     = '022'.
        LS_RETURN2-MESSAGE_V1 = GMARC-MATNR.
        LS_RETURN2-MESSAGE_V2 = SY-UNAME.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = LS_RETURN2-ID
            MSGNR               = LS_RETURN2-NUMBER
            MSGV1               = LS_RETURN2-MESSAGE_V1
            MSGV2               = LS_RETURN2-MESSAGE_V2
            MSGV3               = LS_RETURN2-MESSAGE_V3
            MSGV4               = LS_RETURN2-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LS_RETURN2-MESSAGE.

      ENDIF.
*} 기능개선 60722 - 추가

* 6.Run Bapi
      IF LS_RETURN2 IS INITIAL.
        CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
          EXPORTING
            HEADDATA             = LS_BAPIMATHEAD
            CLIENTDATA           = LS_BAPI_MARA
            CLIENTDATAX          = LS_BAPI_MARAX
            PLANTDATA            = LS_BAPI_MARC
            PLANTDATAX           = LS_BAPI_MARCX
            STORAGELOCATIONDATA  = LS_BAPI_MARD
            STORAGELOCATIONDATAX = LS_BAPI_MARDX
            VALUATIONDATA        = LS_BAPI_MBEW
            VALUATIONDATAX       = LS_BAPI_MBEWX
            SALESDATA            = LS_BAPI_MVKE
            SALESDATAX           = LS_BAPI_MVKEX
          IMPORTING
            RETURN               = LS_RETURN2
          TABLES
            MATERIALDESCRIPTION  = LT_BAPI_MAKT
            UNITSOFMEASURE       = LT_BAPI_MARM
            UNITSOFMEASUREX      = LT_BAPI_MARMX
            TAXCLASSIFICATIONS   = LT_BAPI_MLAN
            RETURNMESSAGES       = LT_RETURNMESSAGE
            EXTENSIONIN          = LT_BAPIPAREX
            EXTENSIONINX         = LT_BAPIPAREXX.

      ENDIF.

      PERFORM PUT_MAT_RESULT TABLES LT_RETURNMESSAGE
                              USING LS_RETURN2
                                    LS_BAPIMATHEAD
                                    GMARC.
      CLEAR LS_RETURN2.
      REFRESH LT_RETURNMESSAGE.

*----------------------------------------------------------------------
* 확장플랜트(MRP 유형이 존재하고 영업조직(1000/10)이 존재해야 함
*----------------------------------------------------------------------
*->>[CHG]--------------------------------------S 가온전선
*
*      CLEAR:LS_BAPIMATHEAD,
*            LS_BAPI_MARA,
*            LS_BAPI_MARAX,
*            LS_BAPI_MVKE,
*            LS_BAPI_MVKEX,
*            LS_BAPI_MARC,
*            LS_BAPI_MARCX ,
*            LS_BAPI_MARD ,
*            LS_BAPI_MARDX,
*            LS_BAPI_MBEW ,
*            LS_BAPI_MBEWX,
*            LS_RETURN2,
*            LT_BAPI_MAKT,
*            LT_BAPI_MARM,
*            LT_BAPI_MARMX,
*            LT_BAPI_MLAN,
*            LT_BAPIPAREX,
*            LT_BAPIPAREXX,
*            LT_RETURNMESSAGE.
*
*      REFRESH :LT_BAPI_MAKT,
*               LT_BAPI_MARM,
*               LT_BAPI_MARMX,
*               LT_BAPI_MLAN,
*               LT_BAPIPAREX,
*               LT_BAPIPAREXX,
*               LT_RETURNMESSAGE.
*
*      PERFORM DISISION_WERKS_EXTEND USING L_EXIT.
*
*      CHECK L_EXIT IS INITIAL AND GMARC-VTWEG = '10'.
*
*      CLEAR LDISMM.
*
*      SELECT SINGLE DISMM INTO LDISMM
*             FROM MARC
*             WHERE MATNR = GMARC-MATNR
*              AND  WERKS = GMARC-WERKS.
*
*      SELECT SINGLE *  FROM MVKE
*             WHERE MATNR = GMARC-MATNR
**              and  vkorg = '1000'
*              AND  VKORG = GMARC-VKORG
*              AND  VTWEG = '10'.
*
*      IF SY-SUBRC = 0 AND LDISMM <> SPACE.
*
*** sales view
*        LS_BAPIMATHEAD-MATERIAL   = GMARC-MATNR.
*        LS_BAPIMATHEAD-MATL_TYPE  = GMARC-MTART.
*        LS_BAPIMATHEAD-SALES_VIEW = 'X'.
*
*        IF LS_BAPIMATHEAD-SALES_VIEW = 'X'.
*
*          LS_BAPI_MARC-PLANT = GMARC-WERKS.   " 플랜트
*          LS_BAPI_MARCX-PLANT = GMARC-WERKS.
** 피복선 상품창고 자재의 적하그룹 23A 설정
** by J.Y.Lee 05/09/2012 C20120503_01336
*          IF GMARC-VKORG = '1000' AND GMARC-SPART = '23' AND
*             ( GMARC-MTART = 'MCHA' OR GMARC-MTART = 'HAWA' ).
*            LS_BAPI_MARC-LOADINGGRP = '23A'.
*          ELSE.
*            LS_BAPI_MARC-LOADINGGRP = GMARC-SPART. " 적하그룹
*          ENDIF.
*          LS_BAPI_MARCX-LOADINGGRP = 'X'.
*
** HS CODE(상품수입코드번호)
*          SELECT SINGLE * FROM T604
*                 WHERE STAWN = GMARC-STAWN.
*
*          IF SY-SUBRC = 0.
*            LS_BAPI_MARC-COMM_CODE  = GMARC-STAWN.
*            LS_BAPI_MARCX-COMM_CODE = 'X'.
*          ENDIF.
*
*        ENDIF.
*
**{ 기능개선 60722 - 추가
*        PERFORM CHECK_MATERIAL_LOCK USING GMARC-MATNR
*                                          GV_MSGV1.
**} 기능개선 60722 - 추가
*
** 10.Run Bapi
*        CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
*          EXPORTING
*            HEADDATA             = LS_BAPIMATHEAD
*            CLIENTDATA           = LS_BAPI_MARA
*            CLIENTDATAX          = LS_BAPI_MARAX
*            PLANTDATA            = LS_BAPI_MARC
*            PLANTDATAX           = LS_BAPI_MARCX
*            STORAGELOCATIONDATA  = LS_BAPI_MARD
*            STORAGELOCATIONDATAX = LS_BAPI_MARDX
*            VALUATIONDATA        = LS_BAPI_MBEW
*            VALUATIONDATAX       = LS_BAPI_MBEWX
*            SALESDATA            = LS_BAPI_MVKE
*            SALESDATAX           = LS_BAPI_MVKEX
*          IMPORTING
*            RETURN               = LS_RETURN2
*          TABLES
*            MATERIALDESCRIPTION  = LT_BAPI_MAKT
*            UNITSOFMEASURE       = LT_BAPI_MARM
*            UNITSOFMEASUREX      = LT_BAPI_MARMX
*            TAXCLASSIFICATIONS   = LT_BAPI_MLAN
*            RETURNMESSAGES       = LT_RETURNMESSAGE
*            EXTENSIONIN          = LT_BAPIPAREX
*            EXTENSIONINX         = LT_BAPIPAREXX.
*
*        CHECK SY-SUBRC EQ 0.
*        PERFORM PUT_MAT_RESULT TABLES LT_RETURNMESSAGE
*                                USING LS_RETURN2
*                                      LS_BAPIMATHEAD.
*        CLEAR LS_RETURN2.
*        REFRESH LT_RETURNMESSAGE.
*      ENDIF.
*-<<[CHG]--------------------------------------E 가온전선
    ENDLOOP.

  ENDLOOP.

*->>[CHG]--------------------------------------S 가온전선
  IF GV_BATCH IS NOT INITIAL.

    "LOG 저장
    IF GT_ZGTSDT9030[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9030[] ).
      MODIFY ZGTSDT9030 FROM TABLE GT_ZGTSDT9030.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9030[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |{ LV_MSG1 }/{ LV_MSG2 }|.

      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_PS3. "최초신규생성
          LV_MSG2 = TEXT-013.
        WHEN P_PS4. "플랜트확장생성
          LV_MSG2 = TEXT-014.
      ENDCASE.

      LV_MSG2 = LV_MSG2 && TEXT-011.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-012 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.

  ELSE.
*-<<[CHG]--------------------------------------E 가온전선
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        OBJECT             = TEXT-LOG
        SHOW_LINNO         = SPACE
      EXCEPTIONS
        INCONSISTENT_RANGE = 1
        NO_MESSAGES        = 2.
  ENDIF.

  FREE:LS_LOG.
ENDFORM.                    " MATERIAL_MASTER_CREATE
*&---------------------------------------------------------------------*
*&      Form  progress_indicator
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_COUNT  text
*      -->P_1447   text
*----------------------------------------------------------------------*
FORM PROGRESS_INDICATOR USING P_COUNT
                              P_PRGTEXT.
  IF P_COUNT = 0.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        TEXT = P_PRGTEXT.
  ELSE.
    PER = 100 / P_COUNT * SY-TABIX.
    IF PER > COUNTER.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          PERCENTAGE = PER
          TEXT       = P_PRGTEXT.
      COUNTER = COUNTER + 10.
    ENDIF.
  ENDIF.
ENDFORM.                    " progress_indicator
*&---------------------------------------------------------------------*
*&      Form  set_bapi_mat_head
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_BAPIMATHEAD  text
*      <--P_L_EXIT  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MAT_HEAD CHANGING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD
                                L_EXIT.
  CLEAR L_EXIT.
  CLEAR LS_BAPIMATHEAD.


  LS_BAPIMATHEAD-MATERIAL   = GMARC-MATNR.
  LS_BAPIMATHEAD-MATL_TYPE  = GMARC-MTART.

** Basic view
  IF GMARC-VTWEG = '10'.
    LS_BAPIMATHEAD-BASIC_VIEW = 'X'.
    LS_BAPIMATHEAD-STORAGE_VIEW = 'X'.
  ENDIF.
** sales view
  LS_BAPIMATHEAD-SALES_VIEW = 'X'.


ENDFORM.                    " set_bapi_mat_head
*&---------------------------------------------------------------------*
*&      Form  set_bapi_mara
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_BAPIMATHEAD  text
*      <--P_LS_BAPI_MARA  text
*      <--P_LS_BAPI_MARAX  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MARA USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD
                CHANGING LS_BAPI_MARA STRUCTURE BAPI_MARA
                         LS_BAPI_MARAX STRUCTURE BAPI_MARAX.

  DATA:IT_MATKL LIKE MARA-MATKL.

  CLEAR LS_BAPI_MARA.
  CLEAR LS_BAPI_MARAX.
* 기본뷰
  IF LS_BAPIMATHEAD-BASIC_VIEW = 'X'.

    SELECT SINGLE * FROM T179
           WHERE PRODH = GMARC-PRDHA.

    IF SY-SUBRC = 0.
      LS_BAPI_MARA-PROD_HIER = GMARC-PRDHA. " 제품계층구조
      LS_BAPI_MARAX-PROD_HIER = 'X'.
    ENDIF.


*  기계 추가작업 060712 : SDB01
* 기계상품자재유형에 대한 SPG별 상품-자재그룹 지정
* 제품에 대한 자재그룹은 생산에서 지정함.

*>>-- [AL PJT] 포장재 그룹 'ZAL' 세팅 추가 (2010.11.16, PPC30)
    IF GMARC-SPART = '64'.
      LS_BAPI_MARA-MAT_GRP_SM   = C_ZAL.  "AL포장재그룹.
      LS_BAPI_MARAX-MAT_GRP_SM  = 'X'.
    ENDIF.
*<<--

    IF GMARC-MTART = 'HAWA'  OR  GMARC-MTART = 'MCHA' OR
       GMARC-MTART = 'MHAW' .

      CASE GMARC-SPART.

        WHEN '10'.
          IT_MATKL = 'WBC-00000'. "상품-SCR/제선
        WHEN '20'.
          IT_MATKL = 'WEC-00000'. "상품-기기선
        WHEN '21'.
          IT_MATKL = 'WAU-00000'. "상품-자동차전선
        WHEN '22'.
          IT_MATKL = 'WTB-00000'. "상품-튜브
        WHEN '23'.
          IT_MATKL = 'WLC-00000'. "상품-피복선
        WHEN '24'.
          IT_MATKL = 'WRC-00000'. "상품-고무선
        WHEN '25'.
          IT_MATKL = 'WMW-00000'. "상품-권선

        WHEN '30'.
          IT_MATKL = 'WPC-00000'. "상품-전력선
        WHEN '31'.
          IT_MATKL = 'WPO-00000'. "상품-가공선
        WHEN '32'.
          IT_MATKL = 'WPA-00000'. "상품-전력기기

        WHEN '40'.
          IT_MATKL = 'WOF-00000'. "상품-광섬유
        WHEN '41'.
          IT_MATKL = 'WOC-00000'. "상품-광케이블
        WHEN '42'.
          IT_MATKL = 'WFS-00000'. "상품-FS
        WHEN '43'.
          IT_MATKL = 'WLN-00000'. "상품-랜케이블
        WHEN '44'.
          IT_MATKL = 'WCX-00000'. "상품-동축

        WHEN '50'.
          IT_MATKL = 'WLF-00000'. "상품-리드프레임
        WHEN '51'.
          IT_MATKL = 'WCN-00000'. "상품-커넥터
        WHEN '52'.
          IT_MATKL = 'WAF-00000'. "상품-기능성 테이프
        WHEN '53'.
          IT_MATKL = 'WPS-00000'. "상품-폴리머 스위치
        WHEN '54'.
          IT_MATKL = 'WCF-00000'. "상품-동박
        WHEN '55'.
          IT_MATKL = 'WHS-00000'. "상품-HS

        WHEN '60'.
          IT_MATKL = 'WBD-00000'. "상품-부스닥트
        WHEN '61'.
          IT_MATKL = 'WAP-00000'. "상품-자동차부품
        WHEN '62'.
          IT_MATKL = 'WIR-00000'. "상품-산업고무

        WHEN '63'.
          IT_MATKL = 'WAL-R0000'. "상품-ALROD
        WHEN '64'.
          IT_MATKL = 'WAL-B0000'. "상품-AL사업
        WHEN '65'.
          IT_MATKL = 'WCW-00000'. "상품-커튼월
        WHEN '66'.
          IT_MATKL = 'WFA-00000'. "상품-도시경관재

        WHEN '70'.
          IT_MATKL = 'WAC-00000'. "상품-공조
*        when '71'. it_matkl = 'WAL-B0000'. "상품-트랙터
*        when '72'. it_matkl = 'WCW-00000'. "상품-사출
*        when '73'. it_matkl = 'WFA-00000'. "상품-특수
*        when '75'. it_matkl = 'WFA-00000'. "상품-기계가공
*->>[CHG]--------------------------------------S 가온전선
        WHEN '90'.
          IT_MATKL = 'WAC-00000'. "상품-공통
*-<<[CHG]--------------------------------------S 가온전선
      ENDCASE.

*->>[CHG]--------------------------------------S 가온전선
**-  상품일때만, Update함
*      LS_BAPI_MARA-MATL_GROUP = IT_MATKL.  " 자재그룹
*      LS_BAPI_MARAX-MATL_GROUP = 'X'.
*-<<[CHG]--------------------------------------S 가온전선

    ENDIF.

    LS_BAPI_MARA-TRANS_GRP = '0001'.  " 운송그룹
    LS_BAPI_MARAX-TRANS_GRP = 'X'.
*->>[CHG]--------------------------------------S 가온전선
*    LS_BAPI_MARA-STOR_CONDS = GMARC-SPART."저장조건
*    LS_BAPI_MARAX-STOR_CONDS = 'X'.
*-<<[CHG]--------------------------------------S 가온전선
  ENDIF.

ENDFORM.                    " set_bapi_mara
*&---------------------------------------------------------------------*
*&      Form  set_bapi_mara_extentions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_BAPIPAREX  text
*      -->P_LT_BAPIPAREXX  text
*      -->P_LS_BAPIMATHEAD  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MARA_EXTENTIONS TABLES LT_BAPIPAREX STRUCTURE BAPIPAREX
                                     LT_BAPIPAREXX STRUCTURE BAPIPAREXX
                             USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD.

** BAPI_TE_MARA and BAPI_TE_MARAX should be appended by the same
** append structure used in the table MARA.
** Caution! All fields in append structure of BAPI_TE_MARA* should be
** character type regardless of source type of append fields of MARA.
** IMG에서 추가된 필드에 대해 필드선택그룹 지정 요함

  CLEAR : LT_BAPIPAREX, LT_BAPIPAREXX.
  REFRESH : LT_BAPIPAREX, LT_BAPIPAREXX.

* 기본뷰 확장구조
  IF LS_BAPIMATHEAD-BASIC_VIEW = 'X'.
*    lt_bapiparex-structure = 'BAPI_TE_MARA'.
*** Appended fields plus material.
*    lt_bapiparex-valuepart1+0(18) = ls_bapimathead-material.
*    lt_bapiparex-valuepart1+18(18) = GMARC-zscrp.
*    APPEND lt_bapiparex.
*    lt_bapiparexx-structure = 'BAPI_TE_MARAX'. " Info on update for
*MARA
*    lt_bapiparexx-valuepart1+0(18) = ls_bapimathead-material.
*    lt_bapiparexx-valuepart1+18(18) = GMARC-zscrp.
*    APPEND lt_bapiparexx.
  ENDIF.

ENDFORM.                    " set_bapi_mara_extentions
*&---------------------------------------------------------------------*
*&      Form  conversion_exit_input_alpha
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GMARC_KONDM  text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_INPUT_ALPHA  CHANGING P_VALUE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_VALUE
    IMPORTING
      OUTPUT = P_VALUE.

ENDFORM.                    " conversion_exit_input_alpha
*&---------------------------------------------------------------------*
*&      Form  set_bapi_mvke
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_BAPIMATHEAD  text
*      <--P_LS_BAPI_MVKE  text
*      <--P_LS_BAPI_MVKEX  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MVKE USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD
                CHANGING LS_BAPI_MVKE STRUCTURE BAPI_MVKE
                         LS_BAPI_MVKEX STRUCTURE BAPI_MVKEX.

  CLEAR : LS_BAPI_MVKE, LS_BAPI_MVKEX.

  IF LS_BAPIMATHEAD-SALES_VIEW = 'X'.

    LS_BAPI_MVKE-SALES_ORG     = GMARC-VKORG. "영업조직
    LS_BAPI_MVKEX-SALES_ORG    = GMARC-VKORG.
    LS_BAPI_MVKE-DISTR_CHAN    = GMARC-VTWEG. "유통경로
    LS_BAPI_MVKEX-DISTR_CHAN   = GMARC-VTWEG.

    IF GMARC-VRKME = GMARC-MEINS OR
       GMARC-VRKME = ''.
    ELSE.

      LS_BAPI_MVKE-SALES_UNIT    = GMARC-VRKME. "판매단위
      LS_BAPI_MVKEX-SALES_UNIT   = 'X'.

    ENDIF.

* 납품플랜트 생산플랜트와 동일 (제품군 25 = blank)
    IF GMARC-SPART <> '25'.
      IF GMARC-DWERK = ' '.
*->>[CHG]--------------------------------------S 가온전선
        CASE GMARC-WERKS+0(2).
          WHEN '65'.
            LS_BAPI_MVKE-DELYG_PLNT    = '6500'.
            LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
          WHEN '66'.
            LS_BAPI_MVKE-DELYG_PLNT    = '6600'.
            LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
          WHEN OTHERS.

        ENDCASE.
*        LS_BAPI_MVKE-DELYG_PLNT    = GMARC-WERKS.  " 생산플랜트
*        LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
*-<<[CHG]--------------------------------------E 가온전선
      ELSE.
        LS_BAPI_MVKE-DELYG_PLNT    = GMARC-DWERK.  " 납품플랜트
        LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
      ENDIF.

    ELSE.

      IF GMARC-DWERK = ' '.
        LS_BAPI_MVKE-DELYG_PLNT    = ' '.
        LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
      ELSE.
        LS_BAPI_MVKE-DELYG_PLNT    = GMARC-DWERK.  " 납품플랜트
        LS_BAPI_MVKEX-DELYG_PLNT   = 'X'.
      ENDIF.

    ENDIF.

    LS_BAPI_MVKE-MIN_ORDER     = GMARC-AUMNG.  " 최소오더수량
    LS_BAPI_MVKEX-MIN_ORDER    = 'X'.
    LS_BAPI_MVKE-MIN_DELY      = GMARC-LFMNG.  " 최소납품수량
    LS_BAPI_MVKEX-MIN_DELY     = 'X'.
    LS_BAPI_MVKE-DELY_UNIT     = GMARC-SCMNG.  " 납품단위
    LS_BAPI_MVKEX-DELY_UNIT    = 'X'.

    IF GMARC-SCHME = GMARC-MEINS OR
       GMARC-VRKME = ''.
    ELSE.

      LS_BAPI_MVKE-DELY_UOM      = GMARC-SCHME.  " 납품단위의단위
      LS_BAPI_MVKEX-DELY_UOM     = 'X'.
    ENDIF.

    LS_BAPI_MVKE-MATL_STATS    = '1'.          " 자재통계그룹
    LS_BAPI_MVKEX-MATL_STATS   = 'X'.
*->>[CHG]--------------------------------------S 가온전선
*    LS_BAPI_MVKE-MAT_PR_GRP    = '01'.         " 자재가격결정그룹
*    LS_BAPI_MVKEX-MAT_PR_GRP   = 'X'.
*-<<[CHG]--------------------------------------S 가온전선
*    ls_bapi_mvke-pr_ref_mat    = GMARC-pmatn.  "가격결정 참조자재
*    ls_bapi_mvkex-pr_ref_mat   = 'X'.
    CASE GMARC-MTART.

*-- 기능개선 157336 - 엠트론 자재유형 추가 {
*    기계 자재유형 추가 060712 SDB01
*    계정지정그룹 : MFER : 01, MHAW : 02
*    기계 자재유형 추가 060823 SDB01
*    계정지정그룹 : MDIE : 07
      WHEN 'FERT' OR 'MCFE' OR 'MFER' OR 'ZCSF'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '01'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'HAWA' OR 'MCHA' OR 'MHAW'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '02'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'HALB' OR 'MCHF' OR 'MACH' OR 'MHAL' OR 'ZCSH'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '04'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'MCRO' OR 'MRH1' OR 'ROH1'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '05'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'MRH2' OR 'MRM1' OR 'MRM2' OR 'ROH2' OR 'VERP'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '06'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'MDIE'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '07'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'MSCR' OR 'SCRP'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '51'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

      WHEN 'CSUB' OR 'ERSA' OR 'HIBE' OR 'MHIB'.
        LS_BAPI_MVKE-ACCT_ASSGT    = '55'.  " 계정지정그룹
        LS_BAPI_MVKEX-ACCT_ASSGT   = 'X'.

    ENDCASE.

*-- } 기능개선 157336 - 엠트론 자재유형 추가_2016.09.08

* 일반품목범주그룹(MTPOS_MARA)은 MARA에서 관리
* 2005/06/27:  25변경 (NORM -> ZNOR)
* 2005/07/11:  40변경 (NORM -> ZNOR)
* 2005/07/20:  44변경 (NORM -> ZNOR)
* 2010/11/16:  64변경 (ZNOR -> NORM) : AL PJT.
* 2010/12/10:  64변경 (NORM -> ZNOR) : AL PJT.
    CASE GMARC-SPART.

      WHEN '10' OR
           '20' OR '21' OR '22' OR '23' OR '24' OR
*          '25' or '30' or '31' or '32' or '40' or '41' or
*                  '30' or '31' or '32' or '40' or '41' or
           '30' OR '31' OR '32' OR
           '34' OR '35' OR '67' OR
*->>[CHG]--------------------------------------S 가온전선
           '90' OR
*-<<[CHG]--------------------------------------S 가온전선
           '41' OR '42' OR '43'. "//OR  "or '44'.
*           '64'.  "// AL PJT
        LS_BAPI_MVKE-ITEM_CAT      = 'NORM'.  " 품목범주그룹
        LS_BAPI_MVKEX-ITEM_CAT     = 'X'.

*->>[CHG]--------------------------------------S 가온전선
**    기계 SPG 추가 060712 SDB01
**    기계SPG의 경우 품목범주그룹 : ZNOR
*      WHEN '25' OR '40' OR '44' OR
*           '50' OR '51' OR '52' OR '53' OR '54' OR '55' OR
*           '60' OR '61' OR '62' OR '63' OR '65' OR '64' OR
*           '66' OR '70' OR '71' OR '72' OR '73' OR '75' .
*        LS_BAPI_MVKE-ITEM_CAT      = 'ZNOR'.  " 품목범주그룹
*        LS_BAPI_MVKEX-ITEM_CAT     = 'X'.
*-<<[CHG]--------------------------------------S 가온전선
    ENDCASE.

*->>[CHG]--------------------------------------S 가온전선
**    기계 품목범주 예외 처리 060823 SDB01
**    자재유형이 MDIE일 경우 품목범주그룹 : ZDIE
*    IF GMARC-MTART = 'MDIE'.
*      LS_BAPI_MVKE-ITEM_CAT      = 'ZDIE'.  " 품목범주그룹
*      LS_BAPI_MVKEX-ITEM_CAT     = 'X'.
*    ENDIF.
*-<<[CHG]--------------------------------------S 가온전선

*->>[CHG]--------------------------------------S 가온전선
    IF GMARC-MTART = 'HAWA' OR
       GMARC-MTART = 'MCHA'.
      LS_BAPI_MVKE-ITEM_CAT      = 'ZHAW'.  " 품목범주그룹
      LS_BAPI_MVKEX-ITEM_CAT     = 'X'.
    ENDIF.
*-<<[CHG]--------------------------------------S 가온전선

    LS_BAPI_MVKE-MATL_GRP_1    = GMARC-MVGR1.  " Series No
    LS_BAPI_MVKEX-MATL_GRP_1   = 'X'.
    LS_BAPI_MVKE-MATL_GRP_2    = GMARC-MVGR2.  " 용도구분
    LS_BAPI_MVKEX-MATL_GRP_2   = 'X'.
    LS_BAPI_MVKE-MATL_GRP_3    = GMARC-MVGR3.  " 용량구분
    LS_BAPI_MVKEX-MATL_GRP_3   = 'X'.

* 제품계층구조
    SELECT SINGLE * FROM T179
           WHERE PRODH = GMARC-PRDHA.

    IF SY-SUBRC = 0.
      LS_BAPI_MVKE-PROD_HIER  = GMARC-PRDHA.
      LS_BAPI_MVKEX-PROD_HIER = 'X'.
    ENDIF.

  ENDIF.

ENDFORM.                    " set_bapi_mvke
*&---------------------------------------------------------------------*
*&      Form  put_mat_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURNMESSAGE  text
*      -->P_LS_RETURN2  text
*      -->P_LS_BAPIMATHEAD  text
*----------------------------------------------------------------------*
FORM PUT_MAT_RESULT TABLES PT_RETURN STRUCTURE BAPI_MATRETURN2
                     USING PS_RETURN STRUCTURE BAPIRET2
                           LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD
                           PS_GMARC LIKE GMARC.
*->>[CHG]--------------------------------------S 가온전선
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  IF PS_RETURN-TYPE EQ 'S'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    HMARA-MARK   = '1'.
    CONCATENATE C_ICON_NOM C_SUCC INTO HMARA-MESSG.


  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    HMARA-MARK   = '1'.
    CONCATENATE C_ICON_PARK C_FAIL INTO HMARA-MESSG.

  ENDIF.
  MODIFY HMARA TRANSPORTING MARK MESSG  WHERE MATNR = GMARC-MATNR
                                          AND WERKS = GMARC-WERKS
                                          AND  MARK  = 'X'.

  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      ARBGB                  = PS_RETURN-ID
      MSGTY                  = PS_RETURN-TYPE
      MSGV1                  = PS_RETURN-MESSAGE_V1
      MSGV2                  = PS_RETURN-MESSAGE_V2
      MSGV3                  = PS_RETURN-MESSAGE_V3
      MSGV4                  = PS_RETURN-MESSAGE_V4
      TXTNR                  = PS_RETURN-NUMBER
      ZEILE                  = '1'
    EXCEPTIONS
      MESSAGE_TYPE_NOT_VALID = 1
      NOT_ACTIVE             = 2.

  IF GV_BATCH IS NOT INITIAL.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = PS_RETURN-ID
        MSGNR               = PS_RETURN-NUMBER
        MSGV1               = PS_RETURN-MESSAGE_V1
        MSGV2               = PS_RETURN-MESSAGE_V2
        MSGV3               = PS_RETURN-MESSAGE_V3
        MSGV4               = PS_RETURN-MESSAGE_V4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = LV_MSG.

    APPEND VALUE #( ZGUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                    MATNR = PS_GMARC-MATNR
                    WERKS = PS_GMARC-WERKS
                    VKORG = PS_GMARC-VKORG
                    VTWEG = PS_GMARC-VTWEG
                    SPART = PS_GMARC-SPART
                    TYPE    = PS_RETURN-TYPE
                    MESSAGE = LV_MSG
                  ) TO GT_ZGTSDT9030.
  ENDIF.




*  LOOP AT PT_RETURN WHERE TYPE EQ 'E'
*                      OR  TYPE EQ 'A'.
*    EXIT.
*  ENDLOOP.
*
*  IF SY-SUBRC = 0.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    HMARA-MARK   = '1'.
*    CONCATENATE C_ICON_PARK C_FAIL INTO HMARA-MESSG.
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*    HMARA-MARK   = '1'.
*    CONCATENATE C_ICON_NOM C_SUCC INTO HMARA-MESSG.
*  ENDIF.
*
*  MODIFY HMARA TRANSPORTING MARK MESSG  WHERE MATNR = GMARC-MATNR
*                                         AND  MARK  = 'X'.
*
*  LOOP AT PT_RETURN.
*    CALL FUNCTION 'MESSAGE_STORE'
*      EXPORTING
*        ARBGB                  = PT_RETURN-ID
*        MSGTY                  = PT_RETURN-TYPE
*        MSGV1                  = PT_RETURN-MESSAGE_V1
*        MSGV2                  = PT_RETURN-MESSAGE_V2
*        MSGV3                  = PT_RETURN-MESSAGE_V3
*        MSGV4                  = PT_RETURN-MESSAGE_V4
*        TXTNR                  = PT_RETURN-NUMBER
*        ZEILE                  = SY-TABIX
*      EXCEPTIONS
*        MESSAGE_TYPE_NOT_VALID = 1
*        NOT_ACTIVE             = 2.
*  ENDLOOP.
*-<<[CHG]--------------------------------------E 가온전선
ENDFORM.                    " put_mat_result
*&---------------------------------------------------------------------*
*&      Form  set_bapi_marc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_BAPIMATHEAD  text
*      <--P_LS_BAPI_MARC  text
*      <--P_LS_BAPI_MARCX  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MARC USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD
                CHANGING LS_BAPI_MARC STRUCTURE BAPI_MARC
                         LS_BAPI_MARCX STRUCTURE BAPI_MARCX
                         PS_RETURN TYPE BAPIRET2.

  DATA:LMTVFP LIKE MARC-MTVFP.

  CLEAR : LS_BAPI_MARC, LS_BAPI_MARCX.
* 영업추가
  IF LS_BAPIMATHEAD-SALES_VIEW = 'X'.

    LS_BAPI_MARC-PLANT = GMARC-WERKS.   " 플랜트
    LS_BAPI_MARCX-PLANT = GMARC-WERKS.
*   피복선 상품창고 자재의 적하그룹 23A 설정
*   by J.Y.Lee 05/09/2012 C20120503_01336
*->>[CHG]--------------------------------------S 가온전선
*    IF GMARC-VKORG = '1000' AND GMARC-SPART = '23' AND
*       ( GMARC-MTART = 'MCHA' OR GMARC-MTART = 'HAWA' ).
*      LS_BAPI_MARC-LOADINGGRP = '23A'.
*    ELSE.
*      LS_BAPI_MARC-LOADINGGRP = GMARC-SPART. " 적하그룹
*    ENDIF.
*-<<[CHG]--------------------------------------S 가온전선
    IF GMARC-VKORG = '6000'.
      SELECT SINGLE SPAAU
        FROM TVKOS
       WHERE VKORG = @GMARC-VKORG
         AND SPART = @GMARC-SPART
        INTO @DATA(LV_SPAAU).
      IF LV_SPAAU IS NOT INITIAL.
        LS_BAPI_MARC-LOADINGGRP = LV_SPAAU.
      ELSE.
        PS_RETURN-TYPE       = 'E'.
        PS_RETURN-ID         = 'ZGTSD01'.
        PS_RETURN-NUMBER     = '000'.
        PS_RETURN-MESSAGE_V1 = |{ LS_BAPIMATHEAD-MATERIAL }/{ LS_BAPI_MARC-PLANT }|.
        PS_RETURN-MESSAGE_V2 = '적하그룹을 결정할 수 없습니다.'.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = PS_RETURN-ID
            MSGNR               = PS_RETURN-NUMBER
            MSGV1               = PS_RETURN-MESSAGE_V1
            MSGV2               = PS_RETURN-MESSAGE_V2
            MSGV3               = PS_RETURN-MESSAGE_V3
            MSGV4               = PS_RETURN-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = PS_RETURN-MESSAGE.
        EXIT.
      ENDIF.

    ENDIF.
    LS_BAPI_MARCX-LOADINGGRP = 'X'.

* HS CODE(상품수입코드번호)
    SELECT SINGLE * FROM T604
           WHERE STAWN = GMARC-STAWN.

    IF SY-SUBRC = 0.
      LS_BAPI_MARC-COMM_CODE  = GMARC-STAWN.
      LS_BAPI_MARCX-COMM_CODE = 'X'.
    ENDIF.

* 가용성점검
*->>[CHG]--------------------------------------S 가온전선
*    CLEAR LMTVFP.
*    SELECT SINGLE MTVFP INTO LMTVFP
*           FROM MARC
*           WHERE MATNR = GMARC-MATNR
*            AND  WERKS = GMARC-WERKS.
*
*    CHECK LMTVFP = SPACE.
*
*    CASE GMARC-SPART.
*
*      WHEN '21' OR '25'.
*        IF GMARC-MTART = 'MCFE' OR
*           GMARC-MTART = 'FERT' OR
*           GMARC-MTART = 'MCHA' OR
*           GMARC-MTART = 'HAWA' OR
*           GMARC-MTART = 'MCHF' OR
*           GMARC-MTART = 'HALB' OR
*           GMARC-MTART = 'ROH1'.
*          LS_BAPI_MARC-AVAILCHECK = 'ZI'.
*          LS_BAPI_MARCX-AVAILCHECK = 'X'.
*        ELSE.
*          LS_BAPI_MARC-AVAILCHECK = 'CH'.
*          LS_BAPI_MARCX-AVAILCHECK = 'X'.
*        ENDIF.
*
**--[START] C20121010_96689 튜브 영업뷰 자동 생성시 가용성 점검 KP로
**변경_hoi
*      WHEN '22' OR '23'.
*        LS_BAPI_MARC-AVAILCHECK = 'KP'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
**--[END] C20121010_96689 튜브 영업뷰 자동 생성시 가용성 점검 KP로
**변경_hoi
*
**     050927 SDB01 고무선(24)의 가용성점검 그룹을 ZH로 변경
*      WHEN '24'.
*        LS_BAPI_MARC-AVAILCHECK = 'ZH'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
*
*
*      WHEN '10' OR '20'
**        OR '23'   "SRM2512-00020
*
*        OR "'22' OR "hoi
*           '30' OR '31' OR '32' OR '34' OR '35' OR '40' OR '41' OR
*           '42' OR '43' OR '44' OR '50' OR '52' OR '53' OR
*           '55' OR '62'.
*        LS_BAPI_MARC-AVAILCHECK = 'CH'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
*
*      WHEN '63'.
*        LS_BAPI_MARC-AVAILCHECK = '02'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
*
*      WHEN '51' OR '54' OR '61'.
*        LS_BAPI_MARC-AVAILCHECK = 'ZP'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
*
**    기계 SPG 추가 060712 SDB01
**    기계SPG 70/71/72/73/75의 가용성점검그룹 : KP
*      WHEN '60' OR '64' OR '65' OR '66' OR '67' OR
*           '70' OR '71' OR '72' OR '73' OR '75'.
*        LS_BAPI_MARC-AVAILCHECK = 'KP'.
*        LS_BAPI_MARCX-AVAILCHECK = 'X'.
*
*    ENDCASE.
*-<<[CHG]--------------------------------------S 가온전선


  ENDIF.

ENDFORM.                    " set_bapi_marc
*&---------------------------------------------------------------------*
*&      Form  DISISION_WERKS_EXTEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISISION_WERKS_EXTEND USING P_EXIT.

  CLEAR P_EXIT.

  CASE GMARC-SPART.

    WHEN '25'.  " 권선

      CASE GMARC-WERKS.
        WHEN '1201'.
          GMARC-WERKS = '1304'.
        WHEN '1304'.
          GMARC-WERKS = '1201'.
      ENDCASE.

    WHEN '20'.  " 기기선
      GMARC-WERKS = '1771'.

    WHEN '23'.
      CASE GMARC-WERKS.
        WHEN '1202'.
          GMARC-WERKS = '1303'.
        WHEN '1303'.
          GMARC-WERKS = '1202'.
      ENDCASE.

    WHEN '30' OR '31' OR '32'.  " 기기선
      GMARC-WERKS = '1391'.

    WHEN '41' OR '42' OR '43' OR '44'.  " 통신사업부

      CASE GMARC-WERKS.
        WHEN '1407'."13.02.2024 15:34:26  / ZLSGSD2
          GMARC-WERKS = '1491'.
        WHEN '1301'.
          GMARC-WERKS = '1391'.
        WHEN '1401'.
          GMARC-WERKS = '1491'.
      ENDCASE.

*    기계 SPG 추가 060712 SDB01
*    기계SPG 70/71/72/73/75의 보관플랜트 : 1691
    WHEN '70' OR '71' OR '72' OR '73' OR '75'.  " 기계사업부
      GMARC-WERKS = '1691'.

    WHEN OTHERS.
      P_EXIT = 'X'.

  ENDCASE.

ENDFORM.                    " DISISION_WERKS_EXTEND
*&---------------------------------------------------------------------*
*&      Form  GET_CUOBJ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CUOBJ_DATA.

  DATA:LCUOBJ LIKE     VBAP-CUOBJ,
       LCONF  LIKE  CONF_OUT  OCCURS 0 WITH HEADER LINE,
       LVALUE LIKE  API_VALUE OCCURS 0 WITH HEADER LINE.

  CLEAR: LCUOBJ,LCONF,LCONF[],LVALUE,LVALUE[].

  SELECT SINGLE CUOBJ FROM VBAP INTO LCUOBJ
         WHERE  VBELN = GMARC-VBELN
           AND  POSNR = GMARC-POSNR.

  CALL FUNCTION '/SAPMP/CE3_GET_CONFIG_SINGLE'
    EXPORTING
      IM_INSTANCE   = LCUOBJ
    TABLES
      CONFIGURATION = LCONF
      API_VALUES    = LVALUE
    EXCEPTIONS
      NOT_FOUND     = 1
      OTHERS        = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    LOOP AT LVALUE.

      CASE LVALUE-ATNAM.

        WHEN 'MS-MARA-PRDHA'.
          GMARC-PRDHA = LVALUE-ATWRT."제품계층구조

        WHEN 'MS-MARC-STAWN'.
          GMARC-STAWN = LVALUE-ATWRT."HS CODE

        WHEN 'MS-MVKE-DWERK'.
          GMARC-DWERK = LVALUE-ATWRT."납품플랜트

        WHEN 'MS-MVKE-MVGR1'.
          GMARC-MVGR1 = LVALUE-ATWRT.                       "자재그룹 1

        WHEN 'MS-MVKE-MVGR2'.
          GMARC-MVGR2 = LVALUE-ATWRT.                       "자재그룹 2

        WHEN 'MS-MVKE-MVGR3'.
          GMARC-MVGR3 = LVALUE-ATWRT.                       "자재그룹 3

        WHEN 'MS-MVKE-VRKME'.
          GMARC-VRKME = LVALUE-ATWRT."판매단위

        WHEN 'MS-MARA-BRGEW'.

          PERFORM CONVERT_NUMBER USING LVALUE-ATWRT.
          GMARC-BRGEW = LVALUE-ATWRT. "총중량

        WHEN 'MS-MARA-GEWEI'.
          GMARC-GEWEI = LVALUE-ATWRT."중량단위

        WHEN 'MS-MVKE-AUMNG'.

          PERFORM CONVERT_NUMBER USING LVALUE-ATWRT.
          GMARC-AUMNG = LVALUE-ATWRT."최소오더수량

        WHEN 'MS-MVKE-LFMNG'.

          PERFORM CONVERT_NUMBER USING LVALUE-ATWRT.
          GMARC-LFMNG = LVALUE-ATWRT."최소납품수량

        WHEN 'MS-MVKE-SCMNG'.
          PERFORM CONVERT_NUMBER USING LVALUE-ATWRT.
          GMARC-SCMNG = LVALUE-ATWRT."납품단위

        WHEN 'MS-MVKE-SCHME'.
          GMARC-SCHME = LVALUE-ATWRT."납품단위의단위

*        when 'MS-MVKE-KONDM'.
*          GMARC-kondm = lvalue-atwrt."가격결정그룹

      ENDCASE.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " GET_CUOBJ_DATA
*&---------------------------------------------------------------------*
*&      Form  set_bapi_mlan
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_BAPI_MLAN  text
*      -->P_LS_BAPIMATHEAD  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MLAN TABLES LT_BAPI_MLAN STRUCTURE BAPI_MLAN
                    USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD.
  CLEAR : LT_BAPI_MLAN.
  REFRESH : LT_BAPI_MLAN.
* 영업뷰
  IF LS_BAPIMATHEAD-SALES_VIEW = 'X'.
    CHECK LS_BAPIMATHEAD-SALES_VIEW = 'X'.
    LT_BAPI_MLAN-DEPCOUNTRY = 'KR'.    " 납품국
    LT_BAPI_MLAN-TAX_TYPE_1 = 'MWST'.  " 세금범주
    IF LS_BAPIMATHEAD-MATL_TYPE EQ GC_MTART_SCRP.
      LT_BAPI_MLAN-TAXCLASS_1 = '2'.     " 스크랩:잡매출
    ELSE.
      LT_BAPI_MLAN-TAXCLASS_1 = '1'.     " 세금분류자재
    ENDIF.
    APPEND LT_BAPI_MLAN.
  ENDIF.
ENDFORM.                    " set_bapi_mlan
*&---------------------------------------------------------------------*
*&      Form  set_bapi_marm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_BAPI_MARM  text
*      -->P_LT_BAPI_MARMX  text
*      -->P_LS_BAPIMATHEAD  text
*----------------------------------------------------------------------*
FORM SET_BAPI_MARM TABLES LT_BAPI_MARM STRUCTURE BAPI_MARM
                          LT_BAPI_MARMX STRUCTURE BAPI_MARMX
                    USING LS_BAPIMATHEAD STRUCTURE BAPIMATHEAD.

  CLEAR : LT_BAPI_MARM, LT_BAPI_MARMX.
  REFRESH : LT_BAPI_MARM, LT_BAPI_MARMX.
* 기본뷰(기본단위는 항상 넣어줘야함)
  IF LS_BAPIMATHEAD-BASIC_VIEW = 'X'.
    IF GMARC-SPART = '32'.

      LT_BAPI_MARM-GROSS_WT   = GMARC-BRGEW. " 총중량
      LT_BAPI_MARM-UNIT_OF_WT = GMARC-GEWEI.
      LT_BAPI_MARM-ALT_UNIT   = GMARC-MEINS.
      LT_BAPI_MARM-NUMERATOR = 1.   " 기본단위로의 전환에 대한 분자
      LT_BAPI_MARM-DENOMINATR = 1.  " 기본단위로의 전환에 대한 분모
      APPEND LT_BAPI_MARM.

      LT_BAPI_MARMX-GROSS_WT = 'X'.
      LT_BAPI_MARMX-UNIT_OF_WT = 'X'.
      LT_BAPI_MARMX-ALT_UNIT   = GMARC-MEINS.
      LT_BAPI_MARMX-NUMERATOR = 'X'.
      LT_BAPI_MARMX-DENOMINATR = 'X'.
      APPEND LT_BAPI_MARMX.

    ENDIF.
  ENDIF.

ENDFORM.                    " set_bapi_marm
*&---------------------------------------------------------------------*
*&      Form  convert_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LVALUE_ATWRT  text
*----------------------------------------------------------------------*
FORM CONVERT_NUMBER  USING    P_ATWRT.

  CALL FUNCTION 'Z_TR_CONVERT_NUMBER'
    EXPORTING
      P_INPUT  = P_ATWRT
    IMPORTING
      P_OUTPUT = P_ATWRT.

ENDFORM.                    " convert_number
*&---------------------------------------------------------------------*
*&      Form  init_value_setting_werks
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_VALUE_SETTING_EXT_WERKS .

  REFRESH: S_WERKS, S_SPART.
  CLEAR:   S_WERKS, S_SPART.
  IF S_WERKS[] IS INITIAL.
    S_WERKS-SIGN   = 'I'.
    S_WERKS-OPTION = 'EQ'.
*    S_WERKS-LOW = '1771'. APPEND S_WERKS.  "기기대구물류
*    S_WERKS-LOW = '1391'. APPEND S_WERKS.  "구미보관
*    S_WERKS-LOW = '1491'. APPEND S_WERKS.  "인동보관
*    S_WERKS-LOW = '1201'. APPEND S_WERKS.  "안양권선
*    S_WERKS-LOW = '1304'. APPEND S_WERKS.  "구미권선
*    S_WERKS-LOW = '1202'. APPEND S_WERKS.  "안양피복
*    S_WERKS-LOW = '1303'. APPEND S_WERKS.  "구미피복
**   기계 확장플랜트 추가 060712 SDB01
*    S_WERKS-LOW = '1691'. APPEND S_WERKS.  "구미피복
*    S_WERKS-LOW = '1406'. APPEND S_WERKS.  "인동통합배선
    S_WERKS-LOW = GC_WERKS_6500. APPEND S_WERKS. "가온전선(군포)
    S_WERKS-LOW = GC_WERKS_6581. APPEND S_WERKS. "가온전선(군포)_배관
    S_WERKS-LOW = GC_WERKS_6591. APPEND S_WERKS. "가온전선(군포)_보관품
    S_WERKS-LOW = GC_WERKS_6600. APPEND S_WERKS. "가온전선(전주)
    S_WERKS-LOW = GC_WERKS_6691. APPEND S_WERKS. "가온전선(전주)_보관품
  ENDIF.

  IF S_SPART[] IS INITIAL.
    S_SPART-SIGN   = 'I'.
    S_SPART-OPTION = 'EQ'.
*    S_SPART-LOW = '20'. APPEND S_SPART.  "기기선
*    S_SPART-LOW = '23'. APPEND S_SPART.  "피복선
*    S_SPART-LOW = '25'. APPEND S_SPART.  "권선
*    S_SPART-LOW = '43'. APPEND S_SPART.  "utp
*    S_SPART-LOW = '3*'. APPEND S_SPART.  "전력사업부
*    S_SPART-LOW = '4*'. APPEND S_SPART.  "통신사업부
**   기계 제품군추가 060712 SDB01
*    S_SPART-LOW = '7*'. APPEND S_SPART.  "기계사업부
    S_SPART-LOW = GC_SPART_10. APPEND S_SPART. "소재
    S_SPART-LOW = GC_SPART_23. APPEND S_SPART. "피복선
    S_SPART-LOW = GC_SPART_31. APPEND S_SPART. "가공선
    S_SPART-LOW = GC_SPART_41. APPEND S_SPART. "광케이블
    S_SPART-LOW = GC_SPART_43. APPEND S_SPART. "UTP
    S_SPART-LOW = GC_SPART_90. APPEND S_SPART. "공통
  ENDIF.


ENDFORM.                    " init_value_setting_werks
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATERIAL_LOCK
*&---------------------------------------------------------------------*
*       기능개선 60722 - 추가
*----------------------------------------------------------------------*
FORM CHECK_MATERIAL_LOCK  USING    PV_MATNR
                                   PV_MSGV1.

  CLEAR : PV_MSGV1.

  DO 5 TIMES.
    CALL FUNCTION 'ENQUEUE_EMMARAE'
      EXPORTING
        MATNR          = PV_MATNR
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC = 0.
      CLEAR : PV_MSGV1.

      CALL FUNCTION 'DEQUEUE_EMMARAE'
        EXPORTING
          MATNR = PV_MATNR.

      EXIT.
    ELSE.
      PV_MSGV1 = SY-MSGV1.

      WAIT UP TO '0.5' SECONDS.
    ENDIF.
  ENDDO.

ENDFORM.                    " CHECK_MATERIAL_LOCK
*&---------------------------------------------------------------------*
*& Form BACKGROUND_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BACKGROUND_PROCESS .

  CLEAR HMARA.
  HMARA-MARK = 'X'.
  MODIFY HMARA TRANSPORTING MARK WHERE MARK EQ SPACE.

*--------------------------------------------------------------------*
**-- 26.10 적재그룹 조회시 적재그룹만 추가
*--------------------------------------------------------------------*
  CASE P_PS5.
    WHEN ABAP_TRUE.
      PERFORM MATERIAL_MASTER_CREATE_LADGR.
    WHEN OTHERS.
      PERFORM MATERIAL_MASTER_CREATE.
  ENDCASE.
*--------------------------------------------------------------------*

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MATERIAL_MASTER_CREATE_LADGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MATERIAL_MASTER_CREATE_LADGR .

  DATA: LS_BAPIMATHEAD LIKE BAPIMATHEAD,
        LS_BAPI_MARA   LIKE BAPI_MARA,
        LS_BAPI_MARAX  LIKE BAPI_MARAX,
        LS_BAPI_MVKE   LIKE BAPI_MVKE,
        LS_BAPI_MVKEX  LIKE BAPI_MVKEX,
        LS_BAPI_MARC   LIKE BAPI_MARC,
        LS_BAPI_MARCX  LIKE BAPI_MARCX,
        LS_BAPI_MARD   LIKE BAPI_MARD,
        LS_BAPI_MARDX  LIKE BAPI_MARDX,
        LS_BAPI_MBEW   LIKE BAPI_MBEW,
        LS_BAPI_MBEWX  LIKE BAPI_MBEWX.
  DATA: LS_RETURN2 LIKE BAPIRET2.
  DATA: LT_BAPI_MAKT     LIKE TABLE OF BAPI_MAKT WITH HEADER LINE,
        LT_BAPI_MARM     LIKE TABLE OF BAPI_MARM WITH HEADER LINE,
        LT_BAPI_MARMX    LIKE TABLE OF BAPI_MARMX WITH HEADER LINE,
        LT_BAPI_MLAN     LIKE TABLE OF BAPI_MLAN WITH HEADER LINE,
        LT_BAPIPAREX     LIKE TABLE OF BAPIPAREX WITH HEADER LINE,
        LT_BAPIPAREXX    LIKE TABLE OF BAPIPAREXX WITH HEADER LINE,
        LT_RETURNMESSAGE LIKE TABLE OF BAPI_MATRETURN2 WITH HEADER LINE.

  DATA: L_EXIT,
        LDISMM LIKE MARC-DISMM.
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR:GT_ZGTSDT9030[].

  CLEAR : COUNT, COUNTER.
  CALL FUNCTION 'MESSAGES_INITIALIZE'.
  COUNT = LINES( GMARC ).

*===> Start
  LOOP AT HMARA WHERE MARK = 'X'.

    LOOP AT GMARC WHERE MATNR =  HMARA-MATNR AND
                        WERKS =  HMARA-WERKS.

      PERFORM PROGRESS_INDICATOR USING COUNT '자재마스터 생성중...'.

      LS_BAPIMATHEAD-MATERIAL   = GMARC-MATNR.
      LS_BAPIMATHEAD-SALES_VIEW = 'X'.

      PERFORM SET_BAPI_MARC USING LS_BAPIMATHEAD
                         CHANGING LS_BAPI_MARC
                                  LS_BAPI_MARCX
                                  LS_RETURN2.



      PERFORM CHECK_MATERIAL_LOCK USING GMARC-MATNR
                                        GV_MSGV1.
      IF GV_MSGV1 IS NOT INITIAL.
        LS_RETURN2-TYPE       = 'E'.
        LS_RETURN2-ID         = 'M3'.
        LS_RETURN2-NUMBER     = '022'.
        LS_RETURN2-MESSAGE_V1 = GMARC-MATNR.
        LS_RETURN2-MESSAGE_V2 = SY-UNAME.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = LS_RETURN2-ID
            MSGNR               = LS_RETURN2-NUMBER
            MSGV1               = LS_RETURN2-MESSAGE_V1
            MSGV2               = LS_RETURN2-MESSAGE_V2
            MSGV3               = LS_RETURN2-MESSAGE_V3
            MSGV4               = LS_RETURN2-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LS_RETURN2-MESSAGE.

      ENDIF.

* 6.Run Bapi
      IF LS_RETURN2 IS INITIAL.
        CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
          EXPORTING
            HEADDATA       = LS_BAPIMATHEAD
*           CLIENTDATA     = LS_BAPI_MARA
*           CLIENTDATAX    = LS_BAPI_MARAX
            PLANTDATA      = LS_BAPI_MARC
            PLANTDATAX     = LS_BAPI_MARCX
*           STORAGELOCATIONDATA  = LS_BAPI_MARD
*           STORAGELOCATIONDATAX = LS_BAPI_MARDX
*           VALUATIONDATA  = LS_BAPI_MBEW
*           VALUATIONDATAX = LS_BAPI_MBEWX
*           SALESDATA      = LS_BAPI_MVKE
*           SALESDATAX     = LS_BAPI_MVKEX
          IMPORTING
            RETURN         = LS_RETURN2
          TABLES
*           MATERIALDESCRIPTION  = LT_BAPI_MAKT
*           UNITSOFMEASURE = LT_BAPI_MARM
*           UNITSOFMEASUREX      = LT_BAPI_MARMX
*           TAXCLASSIFICATIONS   = LT_BAPI_MLAN
            RETURNMESSAGES = LT_RETURNMESSAGE.
*            EXTENSIONIN          = LT_BAPIPAREX
*            EXTENSIONINX         = LT_BAPIPAREXX.

      ENDIF.

      PERFORM PUT_MAT_RESULT TABLES LT_RETURNMESSAGE
                              USING LS_RETURN2
                                    LS_BAPIMATHEAD
                                    GMARC.
      CLEAR LS_RETURN2.
      REFRESH LT_RETURNMESSAGE.

    ENDLOOP.

  ENDLOOP.
*->>[CHG]--------------------------------------S 가온전선
  IF GV_BATCH IS NOT INITIAL.

    "LOG 저장
    IF GT_ZGTSDT9030[] IS NOT INITIAL.
      ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9030[] ).
      MODIFY ZGTSDT9030 FROM TABLE GT_ZGTSDT9030.
      COMMIT WORK AND WAIT.

      DATA(LS_LOG) = VALUE #( GT_ZGTSDT9030[ 1 ] OPTIONAL ).
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |{ LV_MSG1 }/{ LV_MSG2 }|.

      CLEAR LV_MSG2.
      CASE 'X'.
        WHEN P_PS5. "적재그룹 추가
          LV_MSG2 = TEXT-015.
      ENDCASE.

      LV_MSG2 = LV_MSG2 && TEXT-011.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-012 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH LV_MSG2.
    ENDIF.

  ELSE.
*-<<[CHG]--------------------------------------E 가온전선
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        OBJECT             = TEXT-LOG
        SHOW_LINNO         = SPACE
      EXCEPTIONS
        INCONSISTENT_RANGE = 1
        NO_MESSAGES        = 2.
  ENDIF.

  FREE:LS_LOG.
ENDFORM.
