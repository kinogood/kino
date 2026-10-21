*&---------------------------------------------------------------------*
*& Include          ZGTMMR6200F01
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

  CLEAR : GV_LCK. "위치 변경(PSJ 25.06.16)

  CLEAR : S_APRDT[].
  S_APRDT[] = VALUE #( ( SIGN   = GC_I
                         OPTION = GC_EQ
                         LOW    = SY-DATLO ) ).

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

  IMPORT GV_FNM FROM MEMORY ID 'ZNF'.
  SET CURSOR FIELD GV_FNM.
  FREE MEMORY ID 'ZNF'.

  LOOP AT SCREEN.
    IF SCREEN-NAME = GC_P_EKORG
    OR SCREEN-NAME = GC_P_WERKS
    OR SCREEN-NAME = GC_S_APRDT-LOW.
*   OR SCREEN-NAME = GC_S_EINDT-LOW.
      SCREEN-REQUIRED = 2.
      MODIFY SCREEN.
    ENDIF.

    IF P_BAN = GC_X AND SCREEN-GROUP1 = GC_PO. "추가(PSJ 25.04.10)
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.

    "구매오더시에도 확정 취소 조건 추가(PSJ 25.06.19)
*   IF P_BES = GC_X AND SCREEN-GROUP1 = GC_PR. "추가(PSJ 25.05.09)
*     SCREEN-ACTIVE = 0.
*     MODIFY SCREEN.
*   ENDIF.
  ENDLOOP.

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

  CLEAR : GV_ERR, GV_FNM.

  "필수 필드 Check
  PERFORM CHECK_NULL USING P_EKORG 'P_EKORG'.
  PERFORM CHECK_NULL USING P_WERKS 'P_WERKS'.
  PERFORM CHECK_NULL USING S_APRDT-LOW
                          'S_APRDT-LOW'.
* PERFORM CHECK_NULL USING S_EINDT-LOW
*                         'S_EINDT-LOW'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NULL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_EKORG
*&      --> P_
*&---------------------------------------------------------------------*
FORM CHECK_NULL USING P_VAL
                      P_FNM.

  CHECK GV_ERR IS INITIAL.

  IF P_VAL IS INITIAL.
    PERFORM DYNP_VALUES_READ USING P_FNM
                          CHANGING P_VAL.
  ENDIF.

  CHECK P_VAL IS INITIAL.

* SET CURSOR FIELD P_FNM.
  EXPORT GV_FNM = P_FNM TO MEMORY ID 'ZNF'.
  MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.

  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FNM
*&      <-- P_VAL
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING PV_FNAME
                   CHANGING PV_FVAL.

  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  CLEAR : LT_DYN[], PV_FVAL.
  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).

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

  CLEAR : GV_CNT, GT_LOCK[].
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_BUKRS.

  CASE 'X'.
    WHEN P_BAN.
      PERFORM GET_BAN_DATA.

    WHEN P_BES.
      PERFORM GET_BES_DATA.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BUKRS.

  CLEAR : GV_BUKRS.

  SELECT SINGLE BUKRS FROM T001K
    INTO GV_BUKRS WHERE BWKEY = P_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_POP_MSG USING PV_MSGTY
                       PV_MSGID
                       PV_MSGNO
                       PV_MSGV1
                       PV_MSGV2
                       PV_MSGV3
                       PV_MSGV4.

  APPEND VALUE #( MSGTY = PV_MSGTY
                  MSGID = PV_MSGID
                  MSGNO = PV_MSGNO
                  MSGV1 = PV_MSGV1
                  MSGV2 = PV_MSGV2
                  MSGV3 = PV_MSGV3
                  MSGV4 = PV_MSGV4 ) TO <GFS_MSG>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_HBAN_STYLE
*&---------------------------------------------------------------------*
FORM SET_STYLE USING PV_MODE
                     PV_FNAME
                     PT_STYLE TYPE LVC_T_STYL.

  DATA : LS_STYLE TYPE LVC_S_STYL.


  LS_STYLE-FIELDNAME = PV_FNAME.

  CASE PV_MODE.
    WHEN 'E'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    WHEN 'D'.
      LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  ENDCASE.

  INSERT LS_STYLE INTO TABLE PT_STYLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BAN_DATA.

  CLEAR : GT_HBAN[], GS_OSC.

  SELECT PR~*,
         CASE WHEN BANFN <> @SPACE THEN @ICON_LED_GREEN
                                   ELSE @ICON_LED_YELLOW
                                 END AS STATUS,
         ZJOB_NAME AS JOB_NM,
         ZPJT_NO   AS PJT_NO,
         POST1     AS PJT_NM
    FROM ZGTMM_CV_BD_JNPR_LIST AS PR
    INTO CORRESPONDING FIELDS OF TABLE @GT_HBAN
   WHERE EKORG        = @P_EKORG
     AND WERKS        = @P_WERKS
     AND EKGRP       IN @S_EKGRP
     AND ZAPRDT      IN @S_APRDT
     AND JOB_NO      IN @S_JOBNO
     AND VBELN       IN @S_VBELN
     AND ZMTGRP      IN @S_MTGRP   "추가(PSJ 25.03.18)
     AND MATKL       IN @S_MATKL
     AND MATNR       IN @S_MATNR
     AND KNTTP       IN @S_KNTTP   "추가(PSJ 25.02.17)
     AND AFNAM       IN @S_AFNAM
     AND ERDAT_LOCAL IN @S_ERDAT   "추가(PSJ 25.06.05)
*    AND EINDT       IN @S_EINDT   "삭제(PSJ 25.02.10)
     AND ZPJT_NO     IN @S_PJTNO
     AND JOBLS       IN @S_JOBLS
     AND MES_REQ     IN @S_REQNO
     AND EBELN      IN @S_EBELN           "추가(PSJ 2025.06.29)
*    AND ORDCH        = @P_ORDCH   "추가(PSJ 25.04.09)->삭제(PSJ 25.04.10)
     AND CNFCL        = @P_CNFCL.  "추가(PSJ 25.04.09)

  CASE 'X'.
    WHEN P_NCM.
      DELETE GT_HBAN WHERE BANFN IS NOT INITIAL.
    WHEN P_YCM.
      DELETE GT_HBAN WHERE BANFN IS INITIAL.
  ENDCASE.

  IF GT_HBAN[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HBAN BY WERKS  MATNR   EINDT
                  JOB_NO LINE_NO SERIAL_INFO.

  PERFORM GET_MARC.

  LOOP AT GT_HBAN.
    GV_CNT += 1.
    GT_HBAN-IDX = GV_CNT.

    PERFORM CHECK_BAN_ERR.

    IF GT_HBAN-EKGRP IS INITIAL.
      PERFORM SET_MARC.
    ENDIF.

    PERFORM SET_NBAN.

    MODIFY GT_HBAN.
  ENDLOOP.

  "공급업체 조건 추가(PSJ 25.06.13)
  DELETE GT_HBAN WHERE FLIEF NOT IN S_FLIEF.

  IF GT_HBAN[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    CLEAR : GV_CNT.
    EXIT.
  ENDIF.

  GV_CNT = LINES( GT_HBAN ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

  GT_LOCK[] = CORRESPONDING #( GT_HBAN[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MARC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MARC.

  GT_MARC[] = CORRESPONDING #( GT_HBAN[] ).
  DELETE GT_MARC WHERE EKGRP IS NOT INITIAL.

  CHECK GT_MARC[] IS NOT INITIAL.

  SORT GT_MARC BY MATNR WERKS.
  DELETE ADJACENT DUPLICATES FROM GT_MARC COMPARING MATNR WERKS.

  SELECT MATNR WERKS EKGRP
    FROM MARC
    INTO CORRESPONDING FIELDS OF TABLE GT_MARC
     FOR ALL ENTRIES IN GT_MARC
   WHERE MATNR = GT_MARC-MATNR
     AND WERKS = GT_MARC-WERKS
     AND LVORM = SPACE.

  SORT GT_MARC BY MATNR WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MARC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MARC.

  READ TABLE GT_MARC WITH KEY MATNR = GT_HBAN-MATNR
                              WERKS = GT_HBAN-WERKS
                              BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  GT_HBAN-EKGRP = GT_MARC-EKGRP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BAN_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BAN_ERR.

  CLEAR : GV_ERR.
  ASSIGN COMPONENT 'MSG' OF STRUCTURE GT_HBAN TO <GFS_MSG>.

  CHECK GT_HBAN-BANFN IS INITIAL.

  IF GT_HBAN-MTART <> GC_ROH1
 AND GT_HBAN-MTART <> GC_ROH2.
    "구매요청 제조지시가 아닙니다.(자재유형 오류)
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '083' '' '' '' ''.
    GV_ERR = GC_X.
  ENDIF.

  PERFORM CHECK_ZMTGRP USING GT_HBAN-MATNR   "추가(PSJ 25.02.24)
                             GT_HBAN-ZMTGRP.

  CHECK GV_ERR = GC_X.
  GT_HBAN-STATUS = ICON_DEFECT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZMTGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN_MATNR
*&      --> GT_HBAN_ZMTGRP
*&---------------------------------------------------------------------*
FORM CHECK_ZMTGRP USING PV_MATNR
                        PV_ZMTGRP.

  "자재코드 有 But 발주그룹 無 -> Error 처리 추가(PSJ 25.02.24)
  " 구매요청/구매오더 모두 해당

  CHECK PV_MATNR  IS NOT INITIAL
    AND PV_ZMTGRP IS INITIAL.

  "발주그룹 코드를 등록 하세요.(T-Code:ZGTMMV6100)
  PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '117' '' '' '' ''.
  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_NBAN.

  CHECK GT_HBAN-BANFN IS INITIAL.

  PERFORM SET_FLIEF USING GT_HBAN
                 CHANGING GT_HBAN-FLIEF
                          GT_HBAN-FLIEF_NM.
* PERFORM SET_FLIEF USING GT_HBAN-FLIEF
*                         GT_HBAN-FLIEF_NM
*                         GT_HBAN-MATNR
*                         GT_HBAN-WERKS
*                         GT_HBAN-EINDT
*                         GT_HBAN-INFNR.

  PERFORM SET_INFO  USING GT_HBAN-EKORG
                          GT_HBAN-PSTYP
                          GT_HBAN-WERKS
                          GT_HBAN-MATNR
                          GT_HBAN-FLIEF
                          GT_HBAN-EINDT
                          GT_HBAN-INFNR.
*                CHANGING GT_HBAN-INFNR.

  PERFORM SET_EMLIF USING GT_HBAN-EMLIF
                          GT_HBAN-EMLIF_NM
                          GT_HBAN-WERKS
                          GT_HBAN-MATNR
                          GT_HBAN-FLIEF
                          ' '.

  CHECK GV_LCK IS INITIAL. "추가(PSJ 25.06.16)

  PERFORM SET_STYLE USING 'E' 'FLIEF' GT_HBAN-STYLE.
  "AAC='K'인 경우, 직납공급처 입력 불가(PSJ 25.02.24)
  IF GT_HBAN-KNTTP <> GC_K.
    PERFORM SET_STYLE USING 'E' 'EMLIF' GT_HBAN-STYLE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN_FLIEF
*&      --> GT_HBAN_FLIEF_NM
*&      --> GT_HBAN_MATNR
*&      --> GT_HBAN_WERKS
*&      --> GT_HBAN_EINDT
*&      --> GT_HBAN-INFNR
*&---------------------------------------------------------------------*
FORM SET_FLIEF USING PS_HBXX
            CHANGING PV_FLIEF
                     PV_FLIEF_NM.

  CHECK PV_FLIEF IS INITIAL.

  "구매문서 미생성시 공급업체 할당 기준 변경(PSJ 25.02.24)

  CLEAR : GS_FCN.
  MOVE-CORRESPONDING PS_HBXX TO GS_FCN.

  IF GS_FCN-MATNR IS NOT INITIAL.
    "1.구매 공급업체 지정(ZGTMMT6220)
    SELECT SINGLE LIFNR
      FROM ZGTMMT6220 INTO PV_FLIEF
     WHERE JOB_NO = GS_FCN-JOB_NO
       AND ZMTGRP = GS_FCN-ZMTGRP
       AND EKORG  = GS_FCN-EKORG
       AND WERKS  = GS_FCN-WERKS
       AND LVORM  = SPACE.

    "2.소스리스트(EORD)의 공급업체
    IF PV_FLIEF IS INITIAL.
      SELECT LIFNR, FLIFN
        FROM EORD INTO TABLE @DATA(LT_LIF)
       WHERE MATNR  = @GS_FCN-MATNR
         AND WERKS  = @GS_FCN-WERKS
         AND VDATU <= @GS_FCN-EINDT
         AND BDATU >= @GS_FCN-EINDT.

      IF LT_LIF[] IS NOT INITIAL.
        IF LINES( LT_LIF[] ) = 1.
          PV_FLIEF = LT_LIF[ 1 ]-LIFNR.
        ELSE.
          PV_FLIEF = VALUE #( LT_LIF[ FLIFN = GC_X ]-LIFNR OPTIONAL ).
        ENDIF.
      ENDIF.
    ENDIF.

  ELSE.
    IF GS_FCN-KNTTP = GC_K. "Only 구매오더
      SELECT INFNR, LIFNR
        FROM ZGTMM_CV_BD_INFO_PRICE INTO TABLE @DATA(LT_INF)
       WHERE EKORG  = @GS_FCN-EKORG
         AND ESOKZ  = @GS_FCN-PSTYP "변경(PSJ 25.03.21) @GC_0
         AND WERKS  = @GS_FCN-WERKS "1306
         AND MATNR  = @SPACE
         AND MATKL  = @GS_FCN-MATKL
         AND IDNLF  = @GS_FCN-IDNLF
         AND DATBI >= @GS_FCN-EINDT
         AND DATAB <= @GS_FCN-EINDT.

      "위 조건에 해당하는 데이터가 한 건인 경우에만 지정(PSJ 25.03.21)
      IF LINES( LT_INF[] ) = 1.
        PV_FLIEF = LT_INF[ 1 ]-LIFNR.
      ENDIF.
*     IF LT_INF[] IS NOT INITIAL.
*       SORT LT_INF BY INFNR DESCENDING.
*
*       PV_FLIEF = LT_INF[ 1 ]-LIFNR.
*     ENDIF.
    ENDIF.

  ENDIF.

* IF PV_MATNR IS NOT INITIAL.
*   SELECT SINGLE LIFNR
*     FROM EORD INTO PV_FLIEF
*    WHERE MATNR  = PV_MATNR
*      AND WERKS  = PV_WERKS
*      AND FLIFN  = GC_X
*      AND VDATU <= PV_EINDT
*      AND BDATU >= PV_EINDT.
* ELSE.
*   "구매오더의 경우, 자재코드가 없는 경우(ACC='K')는 외주공정 정보레코드의 공급업체로(PSJ 25.01.23)
*   IF PV_INFNR IS NOT INITIAL.
*     SELECT SINGLE LIFNR
*       FROM EINA INTO PV_FLIEF
*      WHERE INFNR = PV_INFNR
*        AND LOEKZ = SPACE.
*   ENDIF.
* ENDIF.

  PERFORM GET_LFA1 USING PV_FLIEF
                CHANGING PV_FLIEF_NM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FLIEF
*&      <-- PV_FLIEF_NM
*&---------------------------------------------------------------------*
FORM GET_LFA1 USING PV_LIFNR
           CHANGING PV_NAME1.

  CLEAR : PV_NAME1.
  CHECK PV_LIFNR IS NOT INITIAL.

  SELECT SINGLE NAME1
    FROM LFA1 INTO PV_NAME1
   WHERE LIFNR = PV_LIFNR
     AND LOEVM = SPACE.
*    AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBES
*&---------------------------------------------------------------------*
FORM SET_TYPE USING PS_HBXX.

  DATA : BEGIN OF LS_HBXX,
           WORK,                         "업무(구분자)
           MATKL LIKE ZGTMMT6210-MATKL,  "자재그룹
*          IDNLF LIKE ZGTMMT6210-IDNLF,  "외주공정 자재그룹
           MENGE LIKE ZGTMMT6210-MENGE,  "수량
           ONETW LIKE ZGTMMT6210-NETWR,  "외주가공/OEM 금액
           OWAER LIKE ZGTMMT6210-WAERS,  "Curr
         END   OF LS_HBXX.


  CLEAR : GS_OSC.

  CHECK P_BES = GC_X.

  MOVE-CORRESPONDING PS_HBXX TO LS_HBXX.

  GS_OSC-TYPE  = LS_HBXX-WORK.
  GS_OSC-MENGE = LS_HBXX-MENGE.
  GS_OSC-ONETW = LS_HBXX-ONETW.
  GS_OSC-OWAER = LS_HBXX-OWAER.

  CASE GS_OSC-TYPE.
    WHEN '5'.
      GS_OSC-MATKL = LS_HBXX-MATKL.

*   WHEN '7'.
*     GS_OSC-MATKL = LS_HBXX-IDNLF.

  ENDCASE.

************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!
*
*  DATA : BEGIN OF LS_HBXX,
*           KNTTP LIKE ZGTMMT6210-KNTTP,       "ACC
*           PSTYP LIKE ZGTMMT6210-PSTYP,       "ItmT
*           EXPRC LIKE ZGTMMT6210-EXPRC,       "외주공정 단가사용
*
*           INFNR LIKE EKPO-INFNR,             "정보레코드
*           MENGE LIKE ZGTMMT6210-MENGE,       "수량
*
*           OINFR LIKE ZGTMMT6210-INFNR,       "외주공정 Info
*           BSTMG LIKE ZGTMMT6210-BSTMG,       "가공 수량
*
*           ONETW LIKE ZGTMMT6210-NETWR,       "외주가공/OEM 금액
*         END   OF LS_HBXX.
*
** 1. AAC = 'K'(코스트센터) 일 때 - 외주공정 정보레코드 사용
**  PO금액 = 가공수량(BSTMG) * KBETR / PEINH
** 2. AAC <> 'K'(코스트센터) 일 때,
**  1) 외주공정 단가사용 안 할 때, EXPRC <> 'X' - 공급업체 정보레코드
**   PO금액 = 수량(MENGE) * KBETR / PEINH
**  2) 외주공정 단가사용 할 때, EXPRC = 'X'
**    가. ItmT = '3'(임가공) 일 때, - 외주공정 정보레코드 사용
**      PO금액 = 가공수량(BSTMG) * KBETR / PEINH
**    나. ItmT <> '3'(임가공) 일 때(OEM완제품)
**      PO금액 = ""외주가공/OEM 금액"""
*
*  CLEAR : GS_OSC.
*
*  CHECK P_BES = GC_X.
*
*  MOVE-CORRESPONDING PS_HBXX TO LS_HBXX.
*
*  CASE LS_HBXX-KNTTP.
*    WHEN 'K'. "코스트센터
*      GS_OSC-TYPE = GC_O.
*
*    WHEN OTHERS.
*      IF LS_HBXX-EXPRC = GC_X. "외주공정 단가사용 O
*        IF LS_HBXX-PSTYP = GC_3. "임가공 O
*          GS_OSC-TYPE = GC_O.
*        ELSE.                    "임가공 X(OEM완제품)
*          GS_OSC-TYPE = GC_E.
*        ENDIF.
*      ELSE.                    "외주공정 단가사용 X
*        GS_OSC-TYPE = GC_N.
*      ENDIF.
*
*  ENDCASE.
*
*  CASE GS_OSC-TYPE.
*    WHEN 'O'.    "외주공정
*      GS_OSC-INFNR = LS_HBXX-OINFR. "외주공정 정보레코드
*      GS_OSC-BSTMG = LS_HBXX-BSTMG.
*
*      ASSIGN COMPONENT 'INFNR' OF STRUCTURE PS_HBXX TO <GFS_INFNR>.
*      <GFS_INFNR>  = LS_HBXX-OINFR.
*
*    WHEN OTHERS.
*      GS_OSC-INFNR = LS_HBXX-INFNR. "공급업체 정보레코드
*      GS_OSC-BSTMG = LS_HBXX-MENGE.
*
*      IF GS_OSC-TYPE = GC_E.
*        GS_OSC-ONETW = LS_HBXX-ONETW.
*      ENDIF.
*
*  ENDCASE.
************************************************************************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN_EKORG
*&      --> GT_HBAN_PSTYP
*&      --> GT_HBAN_WERKS
*&      --> GT_HBAN_MATNR
*&      --> GT_HBAN_FLIEF
*&      --> GT_HBAN_EINDT
*&      --> GT_HBAN_INFNR
*&---------------------------------------------------------------------*
FORM SET_INFO USING PV_EKORG
                    PV_PSTYP
                    PV_WERKS
                    PV_MATNR
                    PV_FLIEF
                    PV_EINDT
                    PV_INFNR.

  DATA : LV_COND TYPE STRING.


  "공급업체 정보레코드
  CLEAR : GS_INF, PV_INFNR.

  CHECK PV_FLIEF IS NOT INITIAL.

  "공통조건: 구매조직 + PSTYP + 플랜트 + 업체 + 날짜
  LV_COND = |     EKORG  = @PV_EKORG |
         && | AND ESOKZ  = @PV_PSTYP |
         && | AND WERKS  = @PV_WERKS |
         && | AND LIFNR  = @PV_FLIEF |
         && | AND DATBI >= @PV_EINDT |
         && | AND DATAB <= @PV_EINDT |.

  CASE GS_OSC-TYPE.
    WHEN '5'.    " + 자재그룹
      LV_COND = LV_COND && | AND MATKL = @GS_OSC-MATKL |.

*   WHEN '7'.    " + 외주공정자재그룹
*     LV_COND = LV_COND && | AND IDNLF = @GS_OSC-MATKL |.

    WHEN OTHERS. " + 자재코드
      LV_COND = LV_COND && | AND MATNR = @PV_MATNR |.

  ENDCASE.

  SELECT SINGLE INFNR,
                KBETR AS NETPR,
                KONWA AS WAERS,
                PEINH,
                BPRME
    FROM ZGTMM_CV_BD_INFO_PRICE
    INTO CORRESPONDING FIELDS OF @GS_INF
   WHERE (LV_COND).

  PV_INFNR = GS_INF-INFNR.

************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!

*  "공급업체 정보레코드
*  CLEAR : GS_INF.
*
*  CASE GS_OSC-TYPE.
*    WHEN 'O'.    "외주공정
*      CHECK PV_INFNR IS NOT INITIAL.
*
*      SELECT SINGLE INFNR,
*                    KBETR AS NETPR,
*                    KONWA AS WAERS,
*                    PEINH,
*                    BPRME
*        FROM ZGTMM_CV_BD_INFO_PRICE
*        INTO CORRESPONDING FIELDS OF @GS_INF
*       WHERE INFNR  = @PV_INFNR  "정보레코드
*         AND EKORG  = @PV_EKORG
*         AND ESOKZ  = @PV_PSTYP  "ItmT
*         AND WERKS  = @PV_WERKS
*         AND DATBI >= @PV_EINDT
*         AND DATAB <= @PV_EINDT.
*
*    WHEN OTHERS.
*      CLEAR : PV_INFNR. "필요한가?
*      CHECK PV_FLIEF IS NOT INITIAL.
*
*      SELECT SINGLE INFNR,
*                    KBETR AS NETPR,
*                    KONWA AS WAERS,
*                    PEINH,
*                    BPRME
*        FROM ZGTMM_CV_BD_INFO_PRICE
*        INTO CORRESPONDING FIELDS OF @GS_INF
*       WHERE EKORG  = @PV_EKORG
*         AND ESOKZ  = @PV_PSTYP
*         AND WERKS  = @PV_WERKS
*         AND MATNR  = @PV_MATNR
*         AND LIFNR  = @PV_FLIEF
*         AND DATBI >= @PV_EINDT
*         AND DATAB <= @PV_EINDT.
*
*      PV_INFNR = GS_INF-INFNR.
*
*  ENDCASE.
************************************************************************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PRICE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBES
*&---------------------------------------------------------------------*
FORM SET_PRICE USING PS_HBXX.

  CHECK P_BES = GC_X.

  MOVE-CORRESPONDING GS_INF TO PS_HBXX.

  ASSIGN COMPONENT 'NETWR' OF STRUCTURE PS_HBXX TO FIELD-SYMBOL(<LFS_NETWR>).
  ASSIGN COMPONENT 'WAERS' OF STRUCTURE PS_HBXX TO FIELD-SYMBOL(<LFS_WAERS>).

  "PO 금액
  IF GS_OSC-TYPE = GC_3.
    IF GS_INF-PEINH IS NOT INITIAL.
      <LFS_NETWR> = GS_OSC-MENGE * GS_INF-NETPR / GS_INF-PEINH.
    ENDIF.
    <LFS_WAERS> = GS_INF-WAERS.
  ELSE.
    PERFORM BAPI_CURRENCY_CONV_TO_INTERNAL USING GS_OSC-OWAER
                                                 GS_OSC-ONETW
                                        CHANGING <LFS_NETWR>.
    <LFS_WAERS> = GS_OSC-OWAER.
  ENDIF.

************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!
*
*  IF GS_OSC-TYPE = GC_E.
*    <LFS_NETWR> = GS_OSC-ONETW.
*  ELSE.
*    IF GS_INF-PEINH IS NOT INITIAL.
*      <LFS_NETWR> = GS_OSC-BSTMG * GS_INF-NETPR / GS_INF-PEINH. "PO 금액
*    ENDIF.
*  ENDIF.
************************************************************************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CURRENCY_CONV_TO_INTERNAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_OSC_OWAER
*&      --> GS_OSC_ONETW
*&      <-- <LFS_NETWR>
*&---------------------------------------------------------------------*
FORM BAPI_CURRENCY_CONV_TO_INTERNAL USING PV_WAERS
                                          PV_NETPR_I
                                 CHANGING PV_NETPR_E.

  CLEAR : PV_NETPR_E.
  CHECK PV_NETPR_I IS NOT INITIAL.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      CURRENCY             = PV_WAERS
      AMOUNT_EXTERNAL      = CONV BAPICURR_D( PV_NETPR_I )
      MAX_NUMBER_OF_DIGITS = 20
    IMPORTING
      AMOUNT_INTERNAL      = PV_NETPR_E.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EMLIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN_EMLIF
*&      --> GT_HBAN_EMLIF_NM
*&      --> GT_HBAN_WERKS
*&      --> GT_HBAN_MATNR
*&      --> GT_HBAN_FLIEF
*&---------------------------------------------------------------------*
FORM SET_EMLIF USING PV_EMLIF
                     PV_EMLIF_NM
                     PV_WERKS
                     PV_MATNR
                     PV_FLIEF
                     PV_CHK.

  "직납공급처 Assign

  CLEAR : PV_EMLIF, PV_EMLIF_NM.

  IF PV_CHK = GC_X.
    PERFORM DEL_POP_MSG USING 'ZGTMM01' '094'.
    PERFORM DEL_ERR_COL USING 'EMLIF'.
  ENDIF.

  CHECK PV_FLIEF IS NOT INITIAL.

  SELECT ZSEQ, EMLIF
    FROM ZGTMMT4000
*   FROM ZGTMMT4000 AS M JOIN T001K AS K
*     ON M~BUKRS = K~BUKRS
*    AND M~WERKS = K~BWKEY
    INTO TABLE @DATA(LT_EMLIF)
   WHERE BUKRS = @GV_BUKRS
     AND WERKS = @PV_WERKS
     AND MATNR = @PV_MATNR
     AND LIFNR = @PV_FLIEF.

  DATA(LV_CNT) = LINES( LT_EMLIF[] ).
  CHECK LV_CNT = 1.

  PV_EMLIF = LT_EMLIF[ 1 ]-EMLIF.

  PERFORM GET_LFA1 USING PV_EMLIF
                CHANGING PV_EMLIF_NM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BES_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BES_DATA.

  CLEAR : GT_HBES[], GT_IBES[].

  PERFORM SET_ORDCH.

  SELECT PO~*,
         CASE WHEN EBELN <> @SPACE THEN @ICON_LED_GREEN
                                   ELSE @ICON_LED_YELLOW
                                 END AS STATUS,
         BSTME     AS OBSTM,
         ZJOB_NAME AS JOB_NM,
         ZPJT_NO   AS PJT_NO,
         POST1     AS PJT_NM
    FROM ZGTMM_CV_BD_JNPO_LIST AS PO
    INTO CORRESPONDING FIELDS OF TABLE @GT_HBES
   WHERE EKORG        = @P_EKORG
     AND WERKS        = @P_WERKS
     AND EKGRP       IN @S_EKGRP
     AND ZAPRDT      IN @S_APRDT
     AND JOB_NO      IN @S_JOBNO
     AND VBELN       IN @S_VBELN
     AND ZMTGRP      IN @S_MTGRP   "추가(PSJ 25.03.18)
     AND MATKL       IN @S_MATKL
     AND MATNR       IN @S_MATNR
     AND KNTTP       IN @S_KNTTP   "추가(PSJ 25.02.17)
     AND AFNAM       IN @S_AFNAM
     AND ERDAT_LOCAL IN @S_ERDAT   "추가(PSJ 25.06.05)
*    AND EINDT       IN @S_EINDT   "삭제(PSJ 25.02.10)
     AND ZPJT_NO     IN @S_PJTNO
     AND JOBLS       IN @S_JOBLS
     AND MES_REQ     IN @S_REQNO
*    AND ORDCH        = @P_ORDCH   "추가(PSJ 25.04.09)
     AND ORDCH       IN @GR_ORDCH  "변경(PSJ 25.04.10)
*    AND CNFCL        = @P_CNFCL.  "추가(PSJ 25.04.09)->삭제(PSJ 25.05.09)
*    AND CNFCL        = @SPACE.    "추가(PSJ 25.06.05)
     AND EBELN      IN @S_EBELN           "추가(PSJ 2025.06.29)
     AND CNFCL        = @P_CNFCL.  "변경(PSJ 25.06.19)

  CASE 'X'.
    WHEN P_NCM.
      DELETE GT_HBES WHERE EBELN IS NOT INITIAL.
    WHEN P_YCM.
      DELETE GT_HBES WHERE EBELN IS INITIAL.
  ENDCASE.

  IF GT_HBES[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    EXIT.
  ENDIF.

  SORT GT_HBES BY WERKS  KNTTP   MATNR MATKL EINDT
                  JOB_NO LINE_NO SERIAL_INFO.

  LOOP AT GT_HBES.
    GV_CNT += 1.
    GT_HBES-IDX = GV_CNT.

    PERFORM SET_WORK.
    PERFORM CHECK_BES_ERR.

    IF GT_HBES-BSTAE IS INITIAL.
      "확인제어 기준 변경(PSJ 25.03.06)
      GT_HBES-BSTAE = SWITCH #( GT_HBES-MTART WHEN 'HAWA' THEN GC_0004    "Inb 납품
                                                          ELSE GC_0007 ). "구매오더
*     GT_HBES-BSTAE = GC_0007.
    ENDIF.

    PERFORM SET_NBES.

*--> [CHM2602-00221] PO 생성이력은 BMES 고정공급업체 아닌 PO 공급업체 출력
    PERFORM SET_NBES_2.
*<-- [CHM2602-00221] PO 생성이력은 BMES 고정공급업체 아닌 PO 공급업체 출력

    MODIFY GT_HBES.
  ENDLOOP.

  "공급업체 조건 추가(PSJ 25.06.13)
  DELETE GT_HBES WHERE FLIEF NOT IN S_FLIEF.

  IF GT_HBES[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    CLEAR : GV_CNT.
    EXIT.
  ENDIF.

  GV_CNT = LINES( GT_HBES ).
  MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.

  GT_LOCK[] = CORRESPONDING #( GT_HBES[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORDCH.

  "구매오더 외주전환 라디오 버튼 조건 변경(PSJ 25.04.10)

  CLEAR : GR_ORDCH[].

  CHECK P_AOC <> GC_X.

  DATA(LV_XOC) = COND #( WHEN P_YOC = GC_X THEN GC_X
                         WHEN P_NOC = GC_X THEN SPACE ).

  GR_ORDCH[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_EQ
                          LOW    = LV_XOC ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WORK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_WORK.

  "구매오더 업무구분 기준 변경(PSJ 25.02.10)
  " 3)상품 구매(AS-IS 자재 4번대)       HAWA  M 0
  " 4)외주임가공 반제품(AS-IS 자재 6번대) HALB  M 3
  " 5)도장/페인팅 비재고구매                   K 0
  " 7)완제품 구매-OEM(AS-IS 자재 2번대) FERT  M 3

  CASE GT_HBES-KNTTP.
    WHEN 'K'.
      GT_HBES-WORK = GC_5.

    WHEN 'M'.
      CASE GT_HBES-MTART.
        WHEN 'HAWA'.
          IF GT_HBES-PSTYP = GC_0.
            GT_HBES-WORK = GC_3.
          ENDIF.

        WHEN 'HALB'.
          IF GT_HBES-PSTYP = GC_3.
            GT_HBES-WORK = GC_4.
          ENDIF.

        WHEN 'FERT'.
          IF GT_HBES-PSTYP = GC_3 OR GT_HBES-PSTYP = GC_0.
            GT_HBES-WORK = GC_7.
          ENDIF.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BES_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BES_ERR.

  CLEAR : GV_ERR.
  ASSIGN COMPONENT 'MSG' OF STRUCTURE GT_HBES TO <GFS_MSG>.

  IF GT_HBES-EBELN IS INITIAL.
    PERFORM CHECK_NBES_ERR.
  ELSE.
    PERFORM CHECK_YBES_ERR.
  ENDIF.

  CHECK GV_ERR = GC_X.
  GT_HBES-STATUS = ICON_DEFECT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_NBES_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_NBES_ERR.

  IF GT_HBES-MTART = GC_ROH1
 AND GT_HBES-MTART = GC_ROH2.
    "구매오더 제조지시 자재유형이 아닙니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '087' '' '' '' ''.
    GV_ERR = GC_X.
  ENDIF.

  IF GT_HBES-MTART IS NOT INITIAL. "FERT/HALB/HAWA 모두 판매오더 재고
    IF GT_HBES-KNTTP <> GC_M OR GT_HBES-VBELN IS INITIAL.
      "구매오더 제조지시가 판매오더재고가 아닙니다.
      PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '088' '' '' '' ''.
      GV_ERR = GC_X.
    ENDIF.
  ENDIF.

  IF GT_HBES-KNTTP = GC_K.
    IF GT_HBES-SAKTO IS INITIAL.
      "비재고 구매오더 제조지시의 G/L 계정번호가 없습니다.
      PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '089' '' '' '' ''.
      GV_ERR = GC_X.
    ENDIF.

    IF GT_HBES-KOSTL IS INITIAL.
      "비재고 구매오더 제조지시의 코스트센터가 없습니다.
      PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '090' '' '' '' ''.
      GV_ERR = GC_X.
    ENDIF.

*   IF GT_HBES-OINFR IS INITIAL. "체크로직 삭제(PSJ 25.02.17)
*     "비재고 구매오더 제조지시의 외주공정 Info가 없습니다.
*     PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '091'.
*     GV_ERR = GC_X.
*   ENDIF.

    IF GT_HBES-TXZ01 IS INITIAL.
      "비재고 구매오더 제조지시의 내역이 없습니다.
      PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '092' '' '' '' ''.
      GV_ERR = GC_X.
    ENDIF.
  ENDIF.

  PERFORM CHECK_ZMTGRP USING GT_HBES-MATNR   "추가(PSJ 25.02.24)
                             GT_HBES-ZMTGRP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_YBES_ERR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_YBES_ERR.

  IF GT_HBES-WEMNG > 0.
    "입고건이 있습니다. 확인하세요.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '102' '' '' '' ''.
    GV_ERR = GC_X.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NBES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_NBES.

  CHECK GT_HBES-EBELN IS INITIAL.

  PERFORM SET_TYPE  USING GT_HBES.

  PERFORM SET_FLIEF USING GT_HBES
                 CHANGING GT_HBES-FLIEF
                          GT_HBES-FLIEF_NM.
* PERFORM SET_FLIEF USING GT_HBES-FLIEF
*                         GT_HBES-FLIEF_NM
*                         GT_HBES-MATNR
*                         GT_HBES-WERKS
*                         GT_HBES-EINDT
*                         GT_HBES-OINFR. "INFNR.

  PERFORM SET_INFO  USING GT_HBES-EKORG
                          GT_HBES-PSTYP
                          GT_HBES-WERKS
                          GT_HBES-MATNR
                          GT_HBES-FLIEF
                          GT_HBES-EINDT
                          GT_HBES-INFNR.

  PERFORM SET_PRICE USING GT_HBES.
* PERFORM SET_PRC.

************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!

*      "외주공정 But M/3일 경우, 정보레코드는 공급업체 기준으로(PSJ 25.01.31)
*      IF GS_OSC-TYPE = GC_O AND GT_HBES-KNTTP <> GC_K.
*        CLEAR : GS_OSC-TYPE.
*        PERFORM SET_INFO  USING GT_HBES-EKORG
*                                GT_HBES-PSTYP
*                                GT_HBES-WERKS
*                                GT_HBES-MATNR
*                                GT_HBES-FLIEF
*                                GT_HBES-EINDT
*                                GT_HBES-INFNR.
*      ENDIF.
************************************************************************

  PERFORM SET_EMLIF USING GT_HBES-EMLIF
                          GT_HBES-EMLIF_NM
                          GT_HBES-WERKS
                          GT_HBES-MATNR
                          GT_HBES-FLIEF
                          ' '.

  CHECK GV_LCK IS INITIAL. "추가(PSJ 25.06.16)

  PERFORM SET_STYLE USING 'E' 'FLIEF' GT_HBES-STYLE.
  IF GT_HBES-WORK = GC_4.
    PERFORM SET_STYLE USING 'E' 'EMLIF' GT_HBES-STYLE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PRC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PRC.

  "PO 미생성시 가격정보(From 정보레코드)

  DATA : LV_INFNR TYPE INFNR,
         LV_BSTMG TYPE BSTMG,
         LV_OSC.

* 1.AAC = 'K'(코스트센터) 일 때 - 외주공정 정보레코드 사용
*  PO금액 = 가공수량(BSTMG) * KBETR / PEINH
* 2.AAC <> 'K'(코스트센터) 일 때,
*  1) 외주공정 단가사용 안 할 때, EXPRC <> 'X' - 공급업체 정보레코드
*   PO금액 = 수량(MENGE) * KBETR / PEINH
*  2) 외주공정 단가사용 할 때, EXPRC = 'X'
*    가. ItmT = '3'(임가공) 일 때, - 외주공정 정보레코드 사용
*      PO금액 = 가공수량(BSTMG) * KBETR / PEINH
*    나. ItmT <> '3'(임가공) 일 때(OEM완제품)
*      PO금액 = ""외주가공/OEM 금액"""

  CASE GT_HBES-KNTTP.
    WHEN 'K'. "코스트센터
      LV_OSC = GC_O.

    WHEN OTHERS.
      IF GT_HBES-EXPRC = GC_X. "외주공정 단가사용 O
        IF GT_HBES-PSTYP = GC_3. "임가공 O
          LV_OSC = GC_O.
        ELSE.                    "임가공 X(OEM완제품)
          LV_OSC = GC_E.
        ENDIF.

      ELSE.                    "외주공정 단가사용 X
        LV_OSC = GC_N.
      ENDIF.

  ENDCASE.

  CASE LV_OSC.
    WHEN 'O'. "외주공정
      LV_INFNR = GT_HBES-OINFR. "외주공정 정보레코드
      LV_BSTMG = GT_HBES-BSTMG.
    WHEN OTHERS.
      LV_INFNR = GT_HBES-INFNR. "공급업체 정보레코드
      LV_BSTMG = GT_HBES-MENGE.
  ENDCASE.

  IF LV_OSC = GC_O.
    CLEAR : GS_INF.
    SELECT SINGLE INFNR,
                  KBETR AS NETPR,
                  KONWA AS WAERS,
                  PEINH,
                  BPRME
      FROM ZGTMM_CV_BD_INFO_PRICE
      INTO CORRESPONDING FIELDS OF @GS_INF
     WHERE INFNR  = @LV_INFNR       "정보레코드
       AND EKORG  = @GT_HBES-EKORG
       AND ESOKZ  = @GT_HBES-PSTYP  "ItmT
       AND WERKS  = @GT_HBES-WERKS
       AND DATBI >= @GT_HBES-EINDT
       AND DATAB <= @GT_HBES-EINDT.
  ENDIF.

  MOVE-CORRESPONDING GS_INF TO GT_HBES.

  IF LV_OSC = GC_E.
    GT_HBES-NETWR = GT_HBES-ONETW.
  ELSE.
    GT_HBES-NETWR = LV_BSTMG * GS_INF-NETPR / GS_INF-PEINH. "PO 금액
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LOCK USING PV_CHK.

  "제조지시번호 Lock 설정(PSJ 25.03.21)

* CLEAR : GV_LCK.

  DELETE GT_LOCK WHERE JOB_NO IS INITIAL.
  CHECK GT_LOCK[] IS NOT INITIAL.

  SORT GT_LOCK BY JOB_NO.
  DELETE ADJACENT DUPLICATES FROM GT_LOCK COMPARING JOB_NO.

  PERFORM ENQUEUE_READ USING 'ZGTMMT6210'.

  IF GT_ENQ[] IS NOT INITIAL AND PV_CHK = GC_X.
    LOOP AT GT_LOCK.
      READ TABLE GT_ENQ WITH KEY GARG+3(10) = GT_LOCK-JOB_NO
                                 BINARY SEARCH.

      IF SY-SUBRC = 0.
        MESSAGE I601(MC) WITH GT_ENQ-GUNAME
                              GT_ENQ-GNAME  DISPLAY LIKE 'E'.

        GV_LCK = GC_X.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CHECK GV_LCK IS INITIAL.

  LOOP AT GT_LOCK.
    PERFORM ENQUEUE_ZGTMMT6210 USING GT_LOCK-JOB_NO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENQUEUE_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM ENQUEUE_READ USING PV_TNM.

  CLEAR : GT_ENQ[].

  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
*     GCLIENT               = SY-MANDT
      GNAME                 = CONV EQEGRANAME( PV_TNM )
*     GARG                  = LV_GARG
      GUNAME                = '*'
*     LOCAL                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
*   IMPORTING
*     NUMBER                =
*     SUBRC                 =
    TABLES
      ENQ                   = GT_ENQ
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1
      SYSTEM_FAILURE        = 2
      OTHERS                = 3.

  SORT GT_ENQ BY GARG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ENQUEUE_ZGTMMT6210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LOCK_JOB_NO
*&---------------------------------------------------------------------*
FORM ENQUEUE_ZGTMMT6210 USING PV_JOB_NO.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTMMT6210'
    EXPORTING
      MODE_ZGTMMT6210 = 'E'
*     MANDT           = SY-MANDT
      JOB_NO          = PV_JOB_NO
*     X_JOB_NO        = ' '
*     _SCOPE          = '2'
*     _WAIT           = ' '
*     _COLLECT        = ' '
    EXCEPTIONS
      FOREIGN_LOCK    = 1
      SYSTEM_FAILURE  = 2
      OTHERS          = 3.

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

  DATA : LT_EXCD TYPE TABLE OF FCODE.


  CLEAR : GT_EXCD[], GV_TITLE.

  "구매오더시에도 '확정대상 취소/확정대상 원복' 기능 추가(PSJ 25.06.19)

  "확정대상 취소/확정대상 원복 기능 추가에 따른 버튼 제어(PSJ 25.05.12)
  DATA(LV_CFX) = COND #( WHEN P_CNFCL = GC_X THEN 'CNFC'
                                             ELSE 'CNFR' ).

  CASE 'X'.
    WHEN P_BAN.
      GV_TITLE  = TEXT-R01. "구매요청
      GT_EXCD[] = VALUE #( ( 'CBES' )
                           ( 'DBES' )
                           ( LV_CFX ) ).

*     "확정취소 선택시 버튼 제어(PSJ 25.04.09)
*     IF P_CNFCL = GC_X.
*       LT_EXCD[] = VALUE #( ( 'FVND' )
*                            ( 'DVND' )
*                            ( 'CBAN' ) ).
*
*       GT_EXCD[] = CORRESPONDING #( BASE ( GT_EXCD[] ) LT_EXCD[] ).
*     ENDIF.

    WHEN P_BES.
      GV_TITLE  = TEXT-R02. "구매오더
      GT_EXCD[] = VALUE #( ( 'CBAN' )
                           ( 'DBAN' )
                           ( 'RDPO' )    "추가(PSJ 25.04.30)
                           ( LV_CFX ) ). "변경(PSJ 25.06.19)
*                          ( 'CNFC' )    "추가(PSJ 25.05.09)
*                          ( 'CNFR' ) ). "추가(PSJ 25.05.09)

  ENDCASE.

  "Lock 발생시 모든 버튼 숨김처리(PSJ 25.03.21)
  IF GV_LCK = GC_X.
    CLEAR : GT_EXCD[].
    GT_EXCD[] = VALUE #( ( 'FVND' )
                         ( 'DVND' )
                         ( 'CBAN' )
                         ( 'DBAN' )
                         ( 'CBES' )
                         ( 'DBES' )
                         ( 'RDPO' )    "추가(PSJ 25.04.30)
                         ( 'CNFC' )    "추가(PSJ 25.05.09)
                         ( 'CNFR' ) ). "추가(PSJ 25.05.09)
    EXIT.
  ENDIF.

  "확정취소 선택시 버튼 제어(PSJ 25.06.19)
  IF P_CNFCL = GC_X.
    DATA(LV_CBX) = COND #( WHEN P_BAN = GC_X THEN 'CBAN'
                           WHEN P_BES = GC_X THEN 'CBES' ).

    LT_EXCD[] = VALUE #( ( 'FVND' )
                         ( 'DVND' )
                         ( LV_CBX ) ).

    GT_EXCD[] = CORRESPONDING #( BASE ( GT_EXCD[] ) LT_EXCD[] ).
  ENDIF.

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

  DATA : LV_ROWS TYPE I.


  CASE SY-DYNNR.
    WHEN '0100'.
      GR_DOCK = NEW #( REPID     = SY-REPID
                       DYNNR     = SY-DYNNR
                       SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                       EXTENSION = 655 ).

      LV_ROWS = COND #( WHEN P_BAN = GC_X THEN 1
                        WHEN P_BES = GC_X THEN 2 ).

      GR_SPLIT = NEW #( PARENT  = GR_DOCK
                        ROWS    = LV_ROWS
                        COLUMNS = 1 ).

      "#1 Row
      GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1
                                          COLUMN = 1 ).

      GR_HGRID = NEW #( I_PARENT      = GR_HCNTR
                        I_APPL_EVENTS = GC_X ).

      CHECK P_BES = GC_X.

      GR_SPLIT->SET_ROW_HEIGHT( ID     = 1
                                HEIGHT = 75 ). "크기 조정(PSJ 25.03.06)

      "#2 Row
      GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2
                                          COLUMN = 1 ).

      GR_IGRID = NEW #( I_PARENT      = GR_ICNTR
                        I_APPL_EVENTS = GC_X ).

    WHEN '0200'.
      GR_RCUST = NEW #( CONTAINER_NAME = 'CC_0200' ).

      GR_RGRID = NEW #( I_PARENT      = GR_RCUST
                        I_APPL_EVENTS = GC_X ).

  ENDCASE.

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

  CLEAR : GT_CEXCL[], GT_REXCL[].

  IF SY-DYNNR = GC_0200.
    GT_REXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL  ) ).
    EXIT.
  ENDIF.

  GT_CEXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                        ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
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

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-STYLEFNAME = GC_STYLE.
      PS_LAYO-CTAB_FNAME = GC_COLOR.
    WHEN 'R'.
      CLEAR : PS_LAYO-CWIDTH_OPT.
      PS_LAYO-SMALLTITLE = GC_X.
      PS_LAYO-GRID_TITLE = '수신자 E-Mail'(T03).
  ENDCASE.

  CHECK P_BES = GC_X.

  PS_LAYO-SMALLTITLE = GC_X.

  CASE PV_TYPE.
    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '아이템'(T01).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '구성품'(T02).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_F4 USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                  PV_OTEXT.

  CLEAR : GT_F4.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      APPEND VALUE #( FIELDNAME = GC_FLIEF
                      REGISTER  = GC_X ) TO GT_F4.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD PR_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

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
      SET HANDLER GR_EVENTS->HANDLE_ONF4          FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_DOUBLE_CLICK  FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_HOTSPOT_CLICK FOR PR_GRID.

      PERFORM SET_EVNT_EDIT USING PR_GRID.

    WHEN 'GR_IGRID'.


    WHEN 'GR_RGRID'.
      SET HANDLER GR_EVENTS->HANDLE_TOOLBAR       FOR PR_GRID.
      SET HANDLER GR_EVENTS->HANDLE_USER_COMMAND  FOR PR_GRID.

      PERFORM SET_EVNT_EDIT USING PR_GRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVNT_EDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_GRID
*&---------------------------------------------------------------------*
FORM SET_EVNT_EDIT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED          FOR PR_GRID.
  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED_FINISHED FOR PR_GRID.

  CALL METHOD PR_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD PR_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> GT_HBAN
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                          PT_LIST
                    USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                          PS_LAYO TYPE LVC_S_LAYO
                          PV_TNME.

  IF GV_LCK = GC_X. "추가(PSJ 25.03.21)
    ASSIGN COMPONENT 'STYLE' OF STRUCTURE PT_LIST TO <GFS_TYL>.

    IF SY-SUBRC = 0.
      DATA(LV_COND) = | STYLE IS NOT INITIAL |.
      CLEAR : <GFS_TYL>[].
      MODIFY PT_LIST TRANSPORTING ('STYLE') WHERE (LV_COND).
    ENDIF.
  ENDIF.

  PERFORM SET_FCAT TABLES PT_FCAT
                          PT_LIST
                    USING PV_TNME.

  PERFORM SET_DISP TABLES PT_FCAT
                          PT_LIST
                    USING PR_GRID
                          PS_LAYO
                          PV_TNME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&      --> PT_LIST
*&      --> PV_TNME
*&---------------------------------------------------------------------*
FORM SET_FCAT TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PV_TNME.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.


  CLEAR : LT_FCAT[], PT_FCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = PV_TNME
*     I_INCLNAME         = SY-REPID
      I_BYPASSING_BUFFER = GC_X
*     I_BUFFER_ACTIVE    = ''
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FCAT[]
    TABLES
      IT_DATA         = PT_LIST
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.

  LOOP AT PT_FCAT INTO GS_FCAT.
    CLEAR : GS_FCAT-KEY.

    CASE PV_TNME.
      WHEN 'GT_HBAN'.
        PERFORM SET_HBAN_FCAT.
      WHEN 'GT_HBES'.
        PERFORM SET_HBES_FCAT.
      WHEN 'GT_IBES'.
        PERFORM SET_IBES_FCAT.
      WHEN 'GT_RDPM'.
        PERFORM SET_RDPM_FCAT.
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
*& Form SET_HBAN_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HBAN_FCAT.

  "제조지시번호, 발주그룹/발주그룹명 위치 교환(PSJ 25.03.18)

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Msg'(F01).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112. "Key 고정과 동시적용 불가!
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F02).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'CNFCL'.  "추가(PSJ 25.04.09)
      PERFORM SET_FTXT USING '확정취소'(F75).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-CHECKBOX  = GC_X.
    WHEN 'KNTTP'.
      PERFORM SET_FTXT USING 'ACC'(F03).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'JOB_NO'.
      PERFORM SET_FTXT USING '제조지시번호'(F26).
      GS_FCAT-KEY       = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재코드'(F04).
      GS_FCAT-KEY       = GC_X.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'TXZ01'.                  "변경(PSJ 25.03.31)
      PERFORM SET_FTXT USING '자재명(MES)'(F73).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'TXZ01_ERP'.              "추가(PSJ 25.03.31)
      PERFORM SET_FTXT USING '자재명(ERP)'(F74).
    WHEN 'MENGE'.
      PERFORM SET_FTXT USING '수량'(F06).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F07).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
    WHEN 'EINDT'.
      PERFORM SET_FTXT USING '납품일'(F08).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)

    WHEN 'FLIEF'.
      PERFORM SET_FTXT USING '고정 공급업체'(F09).
      GS_FCAT-F4AVAILABL = GC_X.
*     GS_FCAT-EMPHASIZE = 'C500'.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'FLIEF_NM'.
      PERFORM SET_FTXT USING '고정 공급업체명'(F10).
*     GS_FCAT-EMPHASIZE = 'C500'.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'INFNR'.
      PERFORM SET_FTXT USING '정보레코드'(F11).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'BANFN'.
      PERFORM SET_FTXT USING '구매요청번호'(F12).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'BNFPO'.
      PERFORM SET_FTXT USING '품목'(F13).
      GS_FCAT-EMPHASIZE = GC_C500.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'EBELN'. "추가(PSJ 25.04.07)
      PERFORM SET_FTXT USING '구매오더번호'(F45).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'EBELP'. "추가(PSJ 25.04.07)
      PERFORM SET_FTXT USING '품목'(F13).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'EMLIF'.
      PERFORM SET_FTXT USING '직납공급처'(F14).
*     GS_FCAT-EMPHASIZE = 'C500'.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'EMLIF_NM'.
      PERFORM SET_FTXT USING '직납공급처명'(F15).
*     GS_FCAT-EMPHASIZE = 'C500'.
*     GS_FCAT-KEY       = GC_X.
    WHEN 'AFNAM'.
      PERFORM SET_FTXT USING '요청자'(F16).
    WHEN 'BSTYP'.
      PERFORM SET_FTXT USING 'Cat'(F17).
      GS_FCAT-JUST      = GC_C.

    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F18).
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING 'PGrp'(F19).
    WHEN 'MTART'.
      PERFORM SET_FTXT USING '자재유형'(F20).
    WHEN 'MATKL'.
      PERFORM SET_FTXT USING '자재그룹'(F21).
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F22).
    WHEN 'ABLAD'.
      PERFORM SET_FTXT USING '하역지점'(F23).
    WHEN 'SOBKZ'.
      PERFORM SET_FTXT USING 'SP'(F24).
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.28)
    WHEN 'VBELN'.
      PERFORM SET_FTXT USING '판매오더'(F25).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.28)
    WHEN 'VBELP'.
      PERFORM SET_FTXT USING '품목'(F13).
      GS_FCAT-EMPHASIZE = GC_C500.
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.28)
    WHEN 'ZMTGRP'.   "추가(PSJ 25.02.24)
      PERFORM SET_FTXT USING '발주그룹'(F63).
*     GS_FCAT-KEY       = GC_X.
    WHEN 'ZMTGRPT'.  "추가(PSJ 25.02.24)
      PERFORM SET_FTXT USING '발주그룹명'(F64).
*     GS_FCAT-KEY       = GC_X.
    WHEN 'JOB_NM'.
      PERFORM SET_FTXT USING '제조지시명'(F27).
    WHEN 'LINE_NO'.
      PERFORM SET_FTXT USING '라인번호'(F28).
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.28)
    WHEN 'SERIAL_INFO'.
      PERFORM SET_FTXT USING '시리얼정보'(F29).
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.28)
    WHEN 'PJT_NO'.
      PERFORM SET_FTXT USING '프로젝트'(F30).
    WHEN 'PJT_NM'.
      PERFORM SET_FTXT USING '프로젝트명'(F31).
    WHEN 'MES_REQ'.
      PERFORM SET_FTXT USING 'MES 요청번호'(F32).
    WHEN 'MES_SEQ'.
      PERFORM SET_FTXT USING 'MES 요청순번'(F33).
    WHEN 'SAKTO'.
      PERFORM SET_FTXT USING 'G/L 계정'(F34).
    WHEN 'KOSTL'.
      PERFORM SET_FTXT USING '코스트센터'(F35).
    WHEN 'ZAPRID'.
      PERFORM SET_FTXT USING '승인자'(F36).
    WHEN 'ZAPRDT'.
      PERFORM SET_FTXT USING '승인일'(F37).
    WHEN 'JOBLS'.
      PERFORM SET_FTXT USING '제조지시 요청번호'(F38).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일'(F39).
    WHEN 'DEL_REQDT'. "추가(PSJ 25.04.30)
      PERFORM SET_FTXT USING 'PO삭제 요청일'(F76).
      GS_FCAT-EMPHASIZE = GC_C700.
    WHEN 'CLCRS'.     "추가(PSJ 25.05.12)
      PERFORM SET_FTXT USING '삭제요청 사유'(F77).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HBES_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HBES_FCAT.

  "제조지시번호, 발주그룹/발주그룹명 위치 교환(PSJ 25.03.18)

  CASE GS_FCAT-FIELDNAME.
    WHEN 'STATUS'.
      PERFORM SET_FTXT USING 'Msg'(F01).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'WERKS'.
      PERFORM SET_FTXT USING '플랜트'(F02).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'CNFCL'.  "추가(PSJ 25.04.09)
      PERFORM SET_FTXT USING '확정취소'(F75).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-CHECKBOX  = GC_X.
*     GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.05.09)->삭제(PSJ 25.06.19)
    WHEN 'KNTTP'.
      PERFORM SET_FTXT USING 'ACC'(F03).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'PSTYP'.
      PERFORM SET_FTXT USING 'ItmT'(F40).
      GS_FCAT-KEY       = GC_X.
      GS_FCAT-JUST      = GC_C.
    WHEN 'JOB_NO'.
      PERFORM SET_FTXT USING '제조지시번호'(F26).
      GS_FCAT-KEY       = GC_X.
    WHEN 'LINE_NO'.                "변경(PSJ 25.04.24)
      PERFORM SET_FTXT USING '라인번호'(F28).
      GS_FCAT-KEY       = GC_X.
    WHEN 'SERIAL_INFO'.            "변경(PSJ 25.04.24)
      PERFORM SET_FTXT USING '시리얼정보'(F29).
      GS_FCAT-KEY       = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재코드'(F04).
      GS_FCAT-KEY       = GC_X.
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'TXZ01'.                  "변경(PSJ 25.03.31)
      PERFORM SET_FTXT USING '자재명(MES)'(F73). "'내역'(F41).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
*     GS_FCAT-EMPHASIZE = GC_C112.
    WHEN 'TXZ01_ERP'.              "추가(PSJ 25.03.31)
      PERFORM SET_FTXT USING '자재명(ERP)'(F74).
    WHEN 'MENGE'.
      PERFORM SET_FTXT USING '수량'(F06).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F07).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
    WHEN 'ORDCH'.
      PERFORM SET_FTXT USING '전환'(F42).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)
      GS_FCAT-CHECKBOX  = GC_X.
    WHEN 'EINDT'.
      PERFORM SET_FTXT USING '납품일'(F08).
*     GS_FCAT-KEY       = GC_X.    "삭제(PSJ 25.03.31)

    WHEN 'FLIEF'.
      PERFORM SET_FTXT USING '공급업체'(F43).
      GS_FCAT-F4AVAILABL = GC_X.
    WHEN 'FLIEF_NM'.
      PERFORM SET_FTXT USING '공급업체명'(F44).
    WHEN 'INFNR'.
      PERFORM SET_FTXT USING '정보레코드'(F11).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'EBELN'.
      PERFORM SET_FTXT USING '구매오더번호'(F45).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'EBELP'.
      PERFORM SET_FTXT USING '품목'(F13).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'EMLIF'.
      PERFORM SET_FTXT USING '직납공급처'(F14).
    WHEN 'EMLIF_NM'.
      PERFORM SET_FTXT USING '직납공급처명'(F15).

    WHEN 'AFNAM'.
      PERFORM SET_FTXT USING '요청자'(F16).
    WHEN 'BSTYP'.
      PERFORM SET_FTXT USING 'Cat'(F17).
      GS_FCAT-JUST      = GC_C.

    WHEN 'WAERS'.
      PERFORM SET_FTXT USING 'Curr.'(F46).
    WHEN 'NETWR'.
      PERFORM SET_FTXT USING 'PO 금액'(F47).
      GS_FCAT-EMPHASIZE = GC_C300.
    WHEN 'NETPR'.
      PERFORM SET_FTXT USING 'Info 단가'(F48).
    WHEN 'PEINH'.
      PERFORM SET_FTXT USING 'Per'(F49).
    WHEN 'BPRME'.
      PERFORM SET_FTXT USING 'OPU'(F50).

    WHEN 'EXPRC'.
      PERFORM SET_FTXT USING '외주공정 단가사용'(F51).
      GS_FCAT-CHECKBOX = GC_X.
    WHEN 'IDNLF'.
      PERFORM SET_FTXT USING '외주공정 자재그룹'(F52).
    WHEN 'BSTMG'.
      PERFORM SET_FTXT USING '가공 수량'(F53).
    WHEN 'BSTME'.
      PERFORM SET_FTXT USING '가공 단위'(F54).

    WHEN 'OINFR'.
      PERFORM SET_FTXT USING '외주공정 Info'(F55).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
      GS_FCAT-NO_OUT    = GC_X. "추가(PSJ 25.03.18)
    WHEN 'ONETP'.
      PERFORM SET_FTXT USING '외주공정 단가'(F56).
      GS_FCAT-CFIELDNAME = GC_OWAER.
    WHEN 'OPEIN'.
      PERFORM SET_FTXT USING 'Per'(F49).
    WHEN 'OBSTM'.
      PERFORM SET_FTXT USING 'OPU'(F50).
    WHEN 'ONETW'.
      PERFORM SET_FTXT USING '외주가공/OEM 금액'(F57).
*     GS_FCAT-CFIELDNAME = GC_OWAER.
    WHEN 'OWAER'.
      PERFORM SET_FTXT USING 'Curr.'(F46).

    WHEN 'EKORG'.
      PERFORM SET_FTXT USING '구매조직'(F18).
    WHEN 'EKGRP'.
      PERFORM SET_FTXT USING 'PGrp'(F19).
    WHEN 'MTART'.
      PERFORM SET_FTXT USING '자재유형'(F20).
    WHEN 'MATKL'.
      PERFORM SET_FTXT USING '자재그룹'(F21).
    WHEN 'SOBKZ'.
      PERFORM SET_FTXT USING 'SP'(F24).
    WHEN 'LGORT'.
      PERFORM SET_FTXT USING '저장위치'(F22).
    WHEN 'ABLAD'.
      PERFORM SET_FTXT USING '하역지점'(F23).
    WHEN 'VBELN'.
      PERFORM SET_FTXT USING '판매오더'(F25).
      GS_FCAT-HOTSPOT   = GC_X.
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'VBELP'.
      PERFORM SET_FTXT USING '품목'(F13).
      GS_FCAT-EMPHASIZE = GC_C500.
    WHEN 'ZMTGRP'.   "추가(PSJ 25.02.24)
      PERFORM SET_FTXT USING '발주그룹'(F63).
*     GS_FCAT-KEY       = GC_X.
    WHEN 'ZMTGRPT'.  "추가(PSJ 25.02.24)
      PERFORM SET_FTXT USING '발주그룹명'(F64).
*     GS_FCAT-KEY       = GC_X.
    WHEN 'JOB_NM'.
      PERFORM SET_FTXT USING '제조지시명'(F27).
    WHEN 'PJT_NO'.
      PERFORM SET_FTXT USING '프로젝트'(F30).
    WHEN 'PJT_NM'.
      PERFORM SET_FTXT USING '프로젝트명'(F31).
    WHEN 'MES_REQ'.
      PERFORM SET_FTXT USING 'MES 요청번호'(F32).
    WHEN 'MES_SEQ'.
      PERFORM SET_FTXT USING 'MES 요청순번'(F33).
    WHEN 'SAKTO'.
      PERFORM SET_FTXT USING 'G/L 계정'(F34).
    WHEN 'KOSTL'.
      PERFORM SET_FTXT USING '코스트센터'(F35).
    WHEN 'BSTAE'.
      PERFORM SET_FTXT USING '확인 제어'(F58).
    WHEN 'UMSON'.
      PERFORM SET_FTXT USING '무상'(F59).
      GS_FCAT-CHECKBOX = GC_X.
      GS_FCAT-NO_OUT   = GC_X. "추가(PSJ 25.03.18)
    WHEN 'ZAPRID'.
      PERFORM SET_FTXT USING '승인자'(F36).
    WHEN 'ZAPRDT'.
      PERFORM SET_FTXT USING '승인일'(F37).
    WHEN 'JOBLS'.
      PERFORM SET_FTXT USING '제조지시 요청번호'(F38).
    WHEN 'ERDAT_LOCAL'.
      PERFORM SET_FTXT USING '생성일'(F39).
    WHEN 'ZWEIGHT'.    "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '중량(Kg)'(F65).
    WHEN 'ZLENGTH_1'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이1(mm)'(F66).
    WHEN 'ZLENGTH_2'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이2(mm)'(F67).
    WHEN 'ZLENGTH_3'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이3(mm)'(F68).
    WHEN 'ZLENGTH_4'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이4(mm)'(F69).
    WHEN 'ZLENGTH_5'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이5(mm)'(F70).
    WHEN 'ZLENGTH_6'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이6(mm)'(F71).
    WHEN 'ZLENGTH_7'.  "추가(PSJ 25.03.18)
      PERFORM SET_FTXT USING '길이7(mm)'(F72).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IBES_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_IBES_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'MES_CMP'.
      PERFORM SET_FTXT USING 'MES 구성품번호'(F60).
      GS_FCAT-KEY    = GC_X.
    WHEN 'MATNR'.
      PERFORM SET_FTXT USING '자재코드'(F04).
    WHEN 'MAKTX'.
      PERFORM SET_FTXT USING '자재명'(F05).
    WHEN 'BDMNG'.
      PERFORM SET_FTXT USING '소요량'(F61).
    WHEN 'MEINS'.
      PERFORM SET_FTXT USING '단위'(F07).
    WHEN 'UMLGO'.
      PERFORM SET_FTXT USING '출고저장위치'(F62).
    WHEN 'MTART'.
      PERFORM SET_FTXT USING '자재유형'(F20).
    WHEN 'MES_REQ'.
      PERFORM SET_FTXT USING 'MES 요청번호'(F32).
    WHEN 'MES_SEQ'.
      PERFORM SET_FTXT USING 'MES 요청순번'(F33).
    WHEN 'LABST'.    "추가(PSJ 25.06.20)
      PERFORM SET_FTXT USING '재고수량'(F78).
    WHEN 'MEINS_M'.  "추가(PSJ 25.06.20)
      PERFORM SET_FTXT USING '재고단위'(F79).

    WHEN OTHERS.
      GS_FCAT-NO_OUT = GC_X.
      GS_FCAT-TECH   = GC_X.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RDPM_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RDPM_FCAT.

  CASE GS_FCAT-FIELDNAME.
    WHEN 'SEQNO'.
      GS_FCAT-OUTPUTLEN = 5.

    WHEN 'EM_RECV'.
      GS_FCAT-OUTPUTLEN = 40.
      GS_FCAT-EDIT      = GC_X.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_FCAT
*&      --> PT_LIST
*&      --> PR_GRID
*&      --> PS_LAYO
*&      --> PV_TNME
*&---------------------------------------------------------------------*
FORM SET_DISP TABLES PT_FCAT TYPE LVC_T_FCAT
                     PT_LIST
               USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYO TYPE LVC_S_LAYO
                     PV_TNME.

  CLEAR : GS_VARI.
  CASE PV_TNME+3(1).
    WHEN 'H'.
      GS_VARI-REPORT   = SY-REPID.
      GS_VARI-HANDLE   = SY-DYNNR.
      GS_VARI-USERNAME = SY-UNAME.

  ENDCASE.

  DATA(LT_EXCL) = SWITCH #( SY-DYNNR WHEN '0200' THEN GT_REXCL[]
                                                 ELSE GT_CEXCL[] ).

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
      IT_TOOLBAR_EXCLUDING = LT_EXCL[] "GT_EXCL[]
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
      PERFORM CLEAR_OBJ USING GR_HGRID GR_HCNTR.
      PERFORM CLEAR_OBJ USING GR_IGRID GR_ICNTR.

      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_DOCK.

      IF GV_LCK IS INITIAL.
        CALL FUNCTION 'DEQUEUE_ALL'. "추가(PSJ 25.03.21)
      ENDIF.

    WHEN '0200'.
*     CLEAR : GV_CLCRS, GT_RDPM[].
*     PERFORM REFRESH_GRID USING GR_RGRID
*                                GS_RLAYO.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_OBJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> GR_HCNTR
*&---------------------------------------------------------------------*
FORM CLEAR_OBJ USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                     PR_CNTR TYPE REF TO CL_GUI_CONTAINER.

  CHECK PR_GRID IS BOUND.

  CALL METHOD PR_GRID->FREE.
  CALL METHOD PR_CNTR->FREE.

  CLEAR : PR_GRID, PR_CNTR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_REFR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_REFR.

  CLEAR : GV_ERR.

  PERFORM GET_DATA.
  GV_REF = GC_X.

  CHECK P_BES = GC_X.
  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                             PV_MODE
                             PV_CHK
                             PV_MSG.

  CLEAR : GT_ROW, GS_ROW, GV_ERR.
  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROW.

  DESCRIBE TABLE GT_ROW.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X.
        GV_ERR = GC_X.
        IF PV_MSG IS NOT INITIAL.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ELSE.
          MESSAGE S004 DISPLAY LIKE 'E'. "라인을 선택하세요.
        ENDIF.
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
*& Form SET_STAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> LV_BUKRS
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_STAB USING PV_SNAME
                    PV_KIND
                    PV_LOW
                    PV_HIGH.

  CLEAR : GT_STAB.

  GT_STAB-SELNAME = PV_SNAME.
  GT_STAB-KIND    = PV_KIND.
  GT_STAB-LOW     = PV_LOW.
  GT_STAB-HIGH    = PV_HIGH.

  IF PV_KIND = GC_S.
    GT_STAB-SIGN = GC_I.

    IF PV_HIGH IS NOT INITIAL.
      GT_STAB-OPTION = GC_BT.
    ELSE.
      GT_STAB-OPTION = GC_EQ.
    ENDIF.
  ENDIF.

  APPEND GT_STAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_FVND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_FVND.

  "Multi 진행 가능하도록 기준변경(PSJ 25.06.05)

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X' ' '. "S->M 변경(PSJ 25.06.05)

  CHECK GV_ERR IS INITIAL.

  CASE 'X'.
    WHEN P_BAN.
      PERFORM PRCS_FVND_BXX TABLES GT_HBAN.

    WHEN P_BES.
      PERFORM PRCS_FVND_BXX TABLES GT_HBES.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_FVND_BXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM PRCS_FVND_BXX TABLES PT_HBXX.

  DATA : LV_PNAME TYPE PROGNAME.


  PERFORM CHECK_FVND TABLES PT_HBXX. "추가(PSJ 25.06.05)
  CHECK GV_ERR IS INITIAL.           "추가(PSJ 25.06.05)

  PERFORM COM_XVND_BXX TABLES PT_HBXX.
  CHECK GV_ERR IS INITIAL.

  "KNTTP='K'인 구매오더의 경우, 공급업체 지정 호출 Pgm.변경(PSJ 25.03.21)
* IF P_BES = GC_X AND GS_COM-MATNR IS INITIAL.
*   MESSAGE S085 DISPLAY LIKE 'E'. "비재고 구매확정 건으로 공급업체 리스트가 없습니다.
*   EXIT.
* ENDIF.
  IF P_BES = GC_X AND GS_COM-KNTTP = GC_K.
    LV_PNAME = GC_ZGTMMR6300.

    PERFORM SET_STAB USING 'P_CALLD' 'P' GC_X         ' '.
    PERFORM SET_STAB USING 'P_EKORG' 'P' GS_COM-EKORG ' '.
    PERFORM SET_STAB USING 'P_WERKS' 'P' GS_COM-WERKS ' '.
    PERFORM SET_STAB USING 'S_MATKL' 'S' GS_COM-MATKL ' '.
    PERFORM SET_STAB USING 'S_ESOKZ' 'S' GS_COM-PSTYP ' '.
  ELSE.
    LV_PNAME = GC_ZGTMMR6100.

    PERFORM SET_STAB USING 'P_CALLD' 'P' GC_X         ' '.
    PERFORM SET_STAB USING 'S_MATNR' 'S' GS_COM-MATNR ' '.
    PERFORM SET_STAB USING 'P_VDATU' 'P' GS_COM-EINDT ' '.
  ENDIF.

  SUBMIT (LV_PNAME) WITH SELECTION-TABLE GT_STAB
                     AND RETURN.

  GET PARAMETER ID 'ZGTMM_FLIEF' FIELD GS_CFV-FLIEF.

  CHECK GS_CFV-FLIEF IS NOT INITIAL.

  IF GS_COM-FLIEF <> GS_CFV-FLIEF.
    LOOP AT GT_ROW INTO GS_ROW.              "추가(PSJ 25.06.05)
      READ TABLE PT_HBXX INDEX GS_ROW-INDEX. "추가(PSJ 25.06.05)
      CHECK SY-SUBRC = 0.                    "추가(PSJ 25.06.05)

      PERFORM ASSIGN_FS_SMC USING PT_HBXX.

      PERFORM RESET_BY_FLIEF USING PT_HBXX.

      PERFORM SET_EMLIF USING GS_CSV-EMLIF
                              GS_CSV-EMLIF_NM
                              GS_COM-WERKS
                              GS_COM-MATNR
                              GS_CFV-FLIEF
                              'X'.

      MOVE-CORRESPONDING GS_CSV TO PT_HBXX.

      PERFORM RESET_STATUS.

      PERFORM MODIFY_HBXX TABLES PT_HBXX.
    ENDLOOP.                                 "추가(PSJ 25.06.05)
  ELSE.
    MESSAGE S017. "변경된 내역이 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FVND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM CHECK_FVND TABLES PT_HBXX.

  DATA : BEGIN OF LT_MAT OCCURS 0,
           MATNR LIKE ZGTMMT6210-MATNR,
           MATKL LIKE ZGTMMT6210-MATKL,
         END   OF LT_MAT.


  "Multi 진행 가능하도록 기준변경(PSJ 25.06.05)

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE PT_HBXX INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    MOVE-CORRESPONDING PT_HBXX TO LT_MAT.
    COLLECT LT_MAT.
  ENDLOOP.

  CHECK LINES( LT_MAT[] ) > 1.
  MESSAGE S154 DISPLAY LIKE 'E'. "동일한 자재코드를 가진 라인만 선택하세요.
  GV_ERR = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COM_XVND_BXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM COM_XVND_BXX TABLES PT_HBXX.

  CLEAR : GV_ERR, GS_COM, GS_CFV, GS_CSV, GT_STAB[].

  READ TABLE PT_HBXX INDEX GS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  DATA(LV_KNAME) = COND #( WHEN P_BAN = GC_X THEN 'BANFN'
                           WHEN P_BES = GC_X THEN 'EBELN' ).

  ASSIGN COMPONENT LV_KNAME OF STRUCTURE PT_HBXX
                            TO FIELD-SYMBOL(<LFS_KNAME>).

  IF <LFS_KNAME> IS NOT INITIAL.
    MESSAGE S084 DISPLAY LIKE 'E'. "이미 구매 확정된 레코드입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  "모든 경우 직납공급처 입력 불가일 때 직납처 지정 안되도록(PSJ 25.02.24)
  IF GV_OKCODE = GC_DVND. "직납처 지정(구매요청/구매오더)
* IF P_BES = GC_X AND GV_OKCODE = GC_DVND. "직납처 지정(Only 구매오더)
    ASSIGN COMPONENT 'STYLE' OF STRUCTURE PT_HBXX TO <GFS_TYL>.

    READ TABLE <GFS_TYL> INTO DATA(LS_TYL)
                         WITH KEY FIELDNAME = GC_EMLIF.

    IF SY-SUBRC <> 0.
      MESSAGE S105 DISPLAY LIKE 'E'. "직납처 지정을 할 수 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING PT_HBXX TO GS_COM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_FS_SMC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM ASSIGN_FS_SMC USING PS_HBXX.

  ASSIGN COMPONENT 'STATUS' OF STRUCTURE PS_HBXX TO <GFS_STS>.
  ASSIGN COMPONENT 'MSG'    OF STRUCTURE PS_HBXX TO <GFS_MSG>.
  ASSIGN COMPONENT 'COLOR'  OF STRUCTURE PS_HBXX TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_BY_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM RESET_BY_FLIEF USING PS_HBXX.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '093'.
  PERFORM DEL_ERR_COL USING 'FLIEF'.

  PERFORM GET_LFA1 USING GS_CFV-FLIEF
                CHANGING GS_CFV-FLIEF_NM.

  "외주공정과 관계없이 고정 공급업체가 변경되면 정보레코드를 재발췌한다!(PSJ 25.01.21)

  PERFORM SET_TYPE USING PS_HBXX.
  PERFORM SET_INFO USING GS_COM-EKORG
                         GS_COM-PSTYP
                         GS_COM-WERKS
                         GS_COM-MATNR
                         GS_CFV-FLIEF
                         GS_COM-EINDT
                         GS_CFV-INFNR.
************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!

** CLEAR : GS_OSC.
*  PERFORM SET_TYPE USING PS_HBXX.
*  GS_OSC-TYPE = SWITCH #( GS_OSC-TYPE WHEN GC_O THEN ' ' ).
*
** IF GS_OSC-TYPE <> GC_O. "외주공정이 아닐때만..
*  PERFORM SET_INFO USING GS_COM-EKORG
*                         GS_COM-PSTYP
*                         GS_COM-WERKS
*                         GS_COM-MATNR
*                         GS_CFV-FLIEF
*                         GS_COM-EINDT
*                         GS_CFV-INFNR.
**               CHANGING GS_CFV-INFNR.
************************************************************************

  MOVE-CORRESPONDING GS_CFV TO PS_HBXX.

  PERFORM SET_PRICE USING PS_HBXX.
* ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_HBXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM MODIFY_HBXX TABLES PT_HBXX.

  CASE 'X'.
    WHEN P_BAN.
      MODIFY PT_HBXX INDEX GS_ROW-INDEX
              TRANSPORTING ('FLIEF')  ('FLIEF_NM') ('INFNR')
                           ('EMLIF')  ('EMLIF_NM')
                           ('STATUS') ('MSG')      ('COLOR').
    WHEN P_BES.
      MODIFY PT_HBXX INDEX GS_ROW-INDEX
              TRANSPORTING ('FLIEF')  ('FLIEF_NM') ('INFNR')
                           ('NETWR')  ('NETPR')    ('WAERS')
                           ('PEINH')  ('BPRME')
                           ('EMLIF')  ('EMLIF_NM')
                           ('STATUS') ('MSG')      ('COLOR').
  ENDCASE.

  GV_REF = GC_X.

  SET PARAMETER ID 'ZGTMM_FLIEF' FIELD SPACE.
  SET PARAMETER ID 'ZGTMM_EMLIF' FIELD SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_DVND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_DVND.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'S' 'X' ' '.

  CHECK GV_ERR IS INITIAL.

  CASE 'X'.
    WHEN P_BAN.
      PERFORM PRCS_DVND_BXX TABLES GT_HBAN.

    WHEN P_BES.
      PERFORM PRCS_DVND_BXX TABLES GT_HBES.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_DVND_BXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM PRCS_DVND_BXX TABLES PT_HBXX.

  "직납업체만 대상. '직납공급처 복사'시 공급업체는 가져오지 않음(PSJ 25.01.21)

  PERFORM COM_XVND_BXX TABLES PT_HBXX.
  CHECK GV_ERR IS INITIAL.

  IF GS_COM-FLIEF IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                   '공급업체가 없습니다. 진행하시겠습니까?'(P02).

    CHECK GV_ANS = GC_1.
  ENDIF.

  PERFORM SET_STAB USING 'P_CALLD' 'P' GC_X         ' '.
  PERFORM SET_STAB USING 'P_BUKRS' 'P' GV_BUKRS     ' '.
  PERFORM SET_STAB USING 'P_WERKS' 'P' GS_COM-WERKS ' '.
  PERFORM SET_STAB USING 'S_MATNR' 'S' GS_COM-MATNR ' '.

  IF GS_COM-FLIEF IS NOT INITIAL.
    PERFORM SET_STAB USING 'S_LIFNR' 'S' GS_COM-FLIEF ' '.
  ENDIF.

  SUBMIT ZGTMMR4000 WITH SELECTION-TABLE GT_STAB
*                        VIA SELECTION-SCREEN
                     AND RETURN.

* GET PARAMETER ID 'ZGTMM_FLIEF' FIELD GS_CFV-FLIEF.
  GET PARAMETER ID 'ZGTMM_EMLIF' FIELD GS_CSV-EMLIF.

* IF GS_COM-FLIEF <> GS_CFV-FLIEF.
*   PERFORM RESET_BY_FLIEF USING PT_HBXX.
* ENDIF.

  CHECK GS_CSV-EMLIF IS NOT INITIAL.

  IF GS_COM-EMLIF <> GS_CSV-EMLIF.
    PERFORM ASSIGN_FS_SMC USING PT_HBXX.

    PERFORM RESET_BY_EMLIF USING GS_CSV-EMLIF
                        CHANGING GS_CSV-EMLIF_NM.

    MOVE-CORRESPONDING GS_CSV TO PT_HBXX.

    PERFORM RESET_STATUS.

    PERFORM MODIFY_HBXX TABLES PT_HBXX.
  ELSE.
    MESSAGE S017. "변경된 내역이 없습니다.
  ENDIF.

* PERFORM MODIFY_HBXX TABLES PT_HBXX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_BY_EMLIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CSV_EMLIF
*&      <-- GS_CSV_EMLIF_NM
*&---------------------------------------------------------------------*
FORM RESET_BY_EMLIF USING PV_EMLIF
                 CHANGING PV_EMLIF_NM.

  PERFORM DEL_POP_MSG USING 'ZGTMM01' '094'.
  PERFORM DEL_ERR_COL USING 'EMLIF'.

  PERFORM GET_LFA1 USING PV_EMLIF
                CHANGING PV_EMLIF_NM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          PV_OTEXT.

  DATA : LS_TBAR TYPE STB_BUTTON.


  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.
    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION  = &2.
    LS_TBAR-ICON      = &3.
    LS_TBAR-TEXT      = &4.
    LS_TBAR-QUICKINFO = &4.
    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PV_OTEXT.
    WHEN 'GR_RGRID'.
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'INSR' ICON_INSERT_ROW  '추가'(B01).
      _SET_TBAR 0 'DELE' ICON_DELETE_ROW  '삭제'(B02).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PV_UCOMM LIKE SY-UCOMM
                               PV_OTEXT.

  CLEAR : GV_REF.

  CASE PV_UCOMM.
    WHEN 'INSR'.
      PERFORM INSR_LINE.

    WHEN 'DELE'.
      PERFORM DELE_LINE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSR_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSR_LINE.

  CLEAR : GT_RDPM.

  IF GT_RDPM[] IS NOT INITIAL.
    DATA(LV_LIN) = LINES( GT_RDPM ).
    GT_RDPM-SEQNO = ( GT_RDPM[ LV_LIN ]-SEQNO ) + 1.
  ELSE.
    GT_RDPM-SEQNO = 1.
  ENDIF.

  APPEND GT_RDPM.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELE_LINE.

  PERFORM GET_SELECTED_ROWS USING GR_RGRID 'M' 'X' ' '.
  CHECK GV_ERR IS INITIAL.

  DELETE GT_ROW WHERE INDEX IS INITIAL.
  SORT GT_ROW BY INDEX DESCENDING.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_RDPM INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    DELETE GT_RDPM INDEX GS_ROW-INDEX.
  ENDLOOP.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PV_OTEXT.

*  CLEAR : GV_REF, GR_DROW[].
*
*  IF PR_CHNG->MT_INSERTED_ROWS IS NOT INITIAL.
*    GR_DROW[] = VALUE #( FOR LS_IROW IN PR_CHNG->MT_INSERTED_ROWS
*                         ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_IROW-ROW_ID ) ) ).
*
*    DELETE PR_CHNG->MT_GOOD_CELLS WHERE ROW_ID IN GR_DROW.
*    DELETE PR_CHNG->MT_MOD_CELLS  WHERE ROW_ID IN GR_DROW.
*    CLEAR : PR_CHNG->MT_INSERTED_ROWS.
*  ENDIF.
*
*  LOOP AT PR_CHNG->MT_GOOD_CELLS INTO GS_MODI.
*    CASE GS_MODI-FIELDNAME.
*      WHEN 'MATNR'.
*        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*      WHEN 'LIFNR'.
*        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*      WHEN 'EMLIF'.
*        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*      WHEN 'LBLKZ'.
*        PERFORM MODIFY_CELL USING PR_CHNG 'STATUS' ICON_CHANGE.
*    ENDCASE.
*
*    GV_REF = GC_X.
*  ENDLOOP.
*
*  CHECK GR_DROW[] IS NOT INITIAL. "ALV List 반영
*  PERFORM REFRESH_GRID USING GR_GRID
*                             GS_LAYO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODI
                                        PT_MODI TYPE LVC_T_MODI
                                        PV_OTEXT.

  CLEAR : GV_REF.
  CHECK PV_MODI IS NOT INITIAL.

  GT_MODI = PT_MODI.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      PERFORM CHNG_FNSH_HGRID.

    WHEN 'GR_RGRID'.
      PERFORM CHNG_FNSH_RGRID.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_HGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_HGRID.

  LOOP AT GT_MODI INTO GS_MODI.
    CASE 'X'.
      WHEN P_BAN.
        PERFORM CHANGE_HBXX TABLES GT_HBAN.
      WHEN P_BES.
        PERFORM CHANGE_HBXX TABLES GT_HBES.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_HBXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM CHANGE_HBXX TABLES PT_HBXX.

  READ TABLE PT_HBXX INDEX GS_MODI-ROW_ID.
  CHECK SY-SUBRC = 0.

  MOVE-CORRESPONDING PT_HBXX TO GS_COM.

  PERFORM ASSIGN_FS_SMC USING PT_HBXX.
  PERFORM ASSIGN_LIFNR  USING PT_HBXX.

  CASE GS_MODI-FIELDNAME.
    WHEN 'FLIEF'.
      PERFORM CHANGE_FLIEF USING PT_HBXX.
    WHEN 'EMLIF'.
      PERFORM CHANGE_EMLIF.
  ENDCASE.

  PERFORM RESET_STATUS.

  MODIFY PT_HBXX INDEX GS_MODI-ROW_ID.
  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM ASSIGN_LIFNR USING PS_HBXX.

  UNASSIGN : <GFS_LIFNR>, <GFS_VNAME>.

  DATA(LV_VNAME) = GS_MODI-FIELDNAME && '_NM'.

  ASSIGN COMPONENT GS_MODI-FIELDNAME OF STRUCTURE PS_HBXX TO <GFS_LIFNR>.
  ASSIGN COMPONENT LV_VNAME          OF STRUCTURE PS_HBXX TO <GFS_VNAME>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ERR_COL USING P_FNM.

  APPEND VALUE #( FNAME     = P_FNM
                  COLOR-COL = GC_6
                  COLOR-INT = GC_0
                  COLOR-INV = GC_0 ) TO <GFS_COL>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_POP_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_POP_MSG USING PV_MSGID
                       PV_MSGNO.

  CHECK  <GFS_MSG> IS NOT INITIAL.

  DELETE <GFS_MSG> WHERE MSGID = PV_MSGID
                     AND MSGNO = PV_MSGNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_ERR_COL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM DEL_ERR_COL USING P_FNM.

  CHECK  <GFS_COL> IS NOT INITIAL.

  DELETE <GFS_COL> WHERE FNAME = P_FNM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM CHANGE_FLIEF USING PS_HBXX.

  IF <GFS_LIFNR> IS NOT INITIAL.
    IF GS_COM-MATNR IS NOT INITIAL.
      SELECT SINGLE LIFNR
        FROM EORD INTO @DATA(LV_LIFNR)
       WHERE MATNR  = @GS_COM-MATNR
         AND WERKS  = @GS_COM-WERKS
         AND VDATU <= @GS_COM-EINDT
         AND BDATU >= @GS_COM-EINDT
         AND LIFNR  = @<GFS_LIFNR>.
    ELSE.
      "자재코드가 없는 경우(ACC='K')는 LFA1 Check(PSJ 25.01.23)
      SELECT SINGLE LIFNR
        FROM LFA1 INTO LV_LIFNR
       WHERE LIFNR = <GFS_LIFNR>
         AND LOEVM = SPACE.
    ENDIF.
  ENDIF.

  IF SY-SUBRC <> 0.
    "유효하지 않은 공급업체입니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '093' '' '' '' ''.
    PERFORM SET_ERR_COL USING 'FLIEF'.
  ELSE.
*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '093'.
*   PERFORM DEL_ERR_COL USING 'FLIEF'.

    CLEAR : GS_CFV.
    GS_CFV-FLIEF = <GFS_LIFNR>.

    PERFORM RESET_BY_FLIEF USING PS_HBXX.

    PERFORM SET_EMLIF USING GS_CSV-EMLIF
                            GS_CSV-EMLIF_NM
                            GS_COM-WERKS
                            GS_COM-MATNR
                            GS_CFV-FLIEF
                            'X'.

    MOVE-CORRESPONDING GS_CSV TO PS_HBXX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_EMLIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_EMLIF.

  IF <GFS_LIFNR> IS NOT INITIAL.
    "유효성 Check 기준 변경(ZGTMMT4000->LFA1)(PSJ 25.02.26)
    SELECT SINGLE LIFNR
      FROM LFA1 INTO @DATA(LV_LIFNR)
     WHERE LIFNR = @<GFS_LIFNR>
       AND LOEVM = @SPACE.
*   SELECT SINGLE EMLIF
*     FROM ZGTMMT4000 INTO @DATA(LV_EMLIF)
*    WHERE BUKRS = @GV_BUKRS
*      AND WERKS = @GS_COM-WERKS
*      AND MATNR = @GS_COM-MATNR
**     AND LIFNR = @GS_COM-FLIEF
*      AND EMLIF = @<GFS_LIFNR>.
  ENDIF.

  IF SY-SUBRC <> 0.
    "유효하지 않은 직납공급처입니다.
    PERFORM SET_POP_MSG USING 'E' 'ZGTMM01' '094' '' '' '' ''.
    PERFORM SET_ERR_COL USING 'EMLIF'.
  ELSE.
    PERFORM RESET_BY_EMLIF USING <GFS_LIFNR>
                        CHANGING <GFS_VNAME>.

*   PERFORM DEL_POP_MSG USING 'ZGTMM01' '094'.
*   PERFORM DEL_ERR_COL USING 'EMLIF'.
*
*   PERFORM GET_LFA1 USING <GFS_LIFNR>
*                 CHANGING <GFS_VNAME>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_STATUS.

  IF <GFS_MSG> IS NOT INITIAL.
    <GFS_STS> = ICON_DEFECT.
  ELSE.
    <GFS_STS> = ICON_LED_YELLOW.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHNG_FNSH_RGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHNG_FNSH_RGRID.

  DATA(LT_RDPM) = GT_RDPM[].

  LOOP AT GT_MODI INTO GS_MODI.
    READ TABLE GT_RDPM INDEX GS_MODI-ROW_ID.
    CHECK SY-SUBRC = 0.

    CASE GS_MODI-FIELDNAME.
      WHEN 'EM_RECV'.
        DATA(LV_CNT) = REDUCE I( INIT X = 0 FOR LS_RDPM IN GT_RDPM
                                          WHERE ( EM_RECV = GT_RDPM-EM_RECV )
                                           NEXT X = X + 1 ).

        IF LV_CNT > 1.
          CLEAR : GT_RDPM-EM_RECV.
          MODIFY GT_RDPM INDEX GS_MODI-ROW_ID.

          MESSAGE S012 DISPLAY LIKE 'E'. "중복된 데이터가 존재합니다.
          GV_REF = GC_X.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CBAN.

  PERFORM CHECK_CBAN.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매요청을 생성하시겠습니까?'(P03).
  CHECK GV_ANS = GC_1.

  "선택한 라인별 PR 생성(Item은 무조건 1개(10번))
  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBAN INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    "KNTTP='K' 케이스 추가(PSJ 25.02.10)

    PERFORM SET_RHDR.
    PERFORM SET_RITM.
    PERFORM SET_RACT.
    PERFORM SET_RTXT.

    PERFORM BAPI_PR_CREATE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CBAN.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '구매요청 생성할 레코드(들)을 선택하세요.'(M01).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBAN INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HBAN-STATUS = ICON_DEFECT.
      MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBAN-BANFN IS NOT INITIAL.
      MESSAGE S086 DISPLAY LIKE 'E'. "이미 구매 확정된 레코드가 있습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RHDR.

  CLEAR : GS_RHDR, GS_RHDRX, GT_RTN[].

  GS_RHDR-PR_TYPE  = GC_NB.
  GS_RHDRX-PR_TYPE = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RITM.

  "Short Text: [PR]모든 경우 MES에서 받은 품명으로 지정(PSJ 25.04.02)

  CLEAR : GT_RITM, GT_RITMX, GT_RITM[], GT_RITMX[].

  GT_RITM-PREQ_ITEM     = 10.
  GT_RITM-PUR_GROUP     = GT_HBAN-EKGRP.  "PGrp
  GT_RITM-PREQ_NAME     = GT_HBAN-AFNAM.  "요청자
  GT_RITM-SHORT_TEXT    = GT_HBAN-TXZ01.  "자재명(MES)
  GT_RITM-MATERIAL_LONG = GT_HBAN-MATNR.  "자재코드
  GT_RITM-PLANT         = GT_HBAN-WERKS.  "플랜트
  GT_RITM-STORE_LOC     = GT_HBAN-LGORT.  "저장위치
  GT_RITM-TRACKINGNO    = GT_HBAN-JOB_NO. "제조지시번호
  GT_RITM-QUANTITY      = GT_HBAN-MENGE.  "수량
  GT_RITM-UNIT          = GT_HBAN-MEINS.  "단위
  GT_RITM-PREQ_DATE     = SY-DATLO.       "요청일
  GT_RITM-DELIV_DATE    = GT_HBAN-EINDT.  "납품일
  GT_RITM-ACCTASSCAT    = GT_HBAN-KNTTP.  "AAC
  GT_RITM-GR_IND        = GC_X.
  GT_RITM-IR_IND        = GC_X.
  GT_RITM-FIXED_VEND    = GT_HBAN-FLIEF.  "고정공급업체
  GT_RITM-PURCH_ORG     = GT_HBAN-EKORG.  "구매오더
  GT_RITM-INFO_REC      = GT_HBAN-INFNR.  "정보레코드


  GT_RITMX-PREQ_ITEM     = 10.
  GT_RITMX-PREQ_ITEMX    = GC_X.
  GT_RITMX-PUR_GROUP     = GC_X.
  GT_RITMX-PREQ_NAME     = GC_X.
  GT_RITMX-SHORT_TEXT    = GC_X.
  GT_RITMX-MATERIAL_LONG = GC_X.
  GT_RITMX-PLANT         = GC_X.
  GT_RITMX-STORE_LOC     = SWITCH #( GT_HBAN-LGORT WHEN ' ' THEN ' '
                                                            ELSE 'X' ).
  GT_RITMX-TRACKINGNO    = GC_X.
  GT_RITMX-QUANTITY      = GC_X.
  GT_RITMX-UNIT          = GC_X.
  GT_RITMX-PREQ_DATE     = GC_X.
  GT_RITMX-DELIV_DATE    = GC_X.
  GT_RITMX-ACCTASSCAT    = SWITCH #( GT_HBAN-KNTTP WHEN ' ' THEN ' '
                                                            ELSE 'X' ).
  GT_RITMX-GR_IND        = GC_X.
  GT_RITMX-IR_IND        = GC_X.
  GT_RITMX-FIXED_VEND    = SWITCH #( GT_HBAN-FLIEF WHEN ' ' THEN ' '
                                                            ELSE 'X' ).
  GT_RITMX-PURCH_ORG     = GC_X.
  GT_RITMX-INFO_REC      = SWITCH #( GT_HBAN-INFNR WHEN ' ' THEN ' '
                                                            ELSE 'X' ).

  IF GT_HBAN-KNTTP <> GC_K.
    GT_RITM-SUPP_VENDOR  = GT_HBAN-EMLIF.  "직납공급처
    GT_RITM-SC_VENDOR    = SWITCH #( GT_HBAN-EMLIF WHEN ' ' THEN ' '
                                                             ELSE 'X' ).

    GT_RITMX-SUPP_VENDOR = GT_RITMX-SC_VENDOR
                         = SWITCH #( GT_HBAN-EMLIF WHEN ' ' THEN ' '
                                                            ELSE 'X' ).
  ENDIF.

  APPEND : GT_RITM, GT_RITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RACT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RACT.

  CLEAR : GT_RACT, GT_RACTX, GT_RACT[], GT_RACTX[].

  CHECK GT_HBAN-KNTTP IS NOT INITIAL.

  GT_RACT-PREQ_ITEM  = 10.
  GT_RACT-SERIAL_NO  = 1.
  GT_RACT-UNLOAD_PT  = GT_HBAN-ABLAD. "하역지점

  GT_RACTX-PREQ_ITEM  = 10.
  GT_RACTX-SERIAL_NO  = 1.
  GT_RACTX-PREQ_ITEMX = GC_X.
  GT_RACTX-SERIAL_NOX = GC_X.
  GT_RACTX-UNLOAD_PT  = SWITCH #( GT_HBAN-ABLAD WHEN ' ' THEN ' '
                                                         ELSE 'X' ).

  CASE GT_HBAN-KNTTP.
    WHEN 'K'.
      GT_RACT-GL_ACCOUNT = GT_HBAN-SAKTO. "G/L 계정번호
      GT_RACT-COSTCENTER = GT_HBAN-KOSTL. "코스트센터

      GT_RACTX-GL_ACCOUNT = GC_X.
      GT_RACTX-COSTCENTER = GC_X.

    WHEN OTHERS.
      GT_RACT-SD_DOC     = GT_HBAN-VBELN. "판매오더
      GT_RACT-ITM_NUMBER = GT_HBAN-VBELP. "판매오더 품목

      GT_RACTX-SD_DOC    = GT_RACTX-ITM_NUMBER
                         = SWITCH #( GT_HBAN-VBELN WHEN ' ' THEN ' '
                                                            ELSE 'X' ).

  ENDCASE.

  APPEND : GT_RACT, GT_RACTX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RTXT.

  CLEAR : GT_RTXT, GT_RTXT[].

  PERFORM SET_XTXT USING '10' 'B01'
                         GT_HBAN-JOB_NO
                         GT_HBAN-LINE_NO
                         GT_HBAN-SERIAL_INFO
                CHANGING GT_RTXT.

  "제조지시번호(JOB_NO)만 입력(PSJ 25.03.31)
  GT_RTXT-TEXT_LINE = GT_HBAN-JOB_NO.

  APPEND GT_RTXT.

  PERFORM APND_XTXT_JNM TABLES GT_RTXT
                         USING GT_HBAN-JOB_NM. "추가(PSJ 25.06.19)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_HBAN_JOB_NO
*&      --> GT_HBAN_LINE_NO
*&      --> GT_HBAN_SERIAL_INFO
*&      <-- GT_RTXT
*&---------------------------------------------------------------------*
FORM SET_XTXT USING PV_ITEM
                    PV_TDID
                    PV_JOB_NO
                    PV_LINE_NO
                    PV_SERIAL_INFO
           CHANGING PS_XTXT.

  ASSIGN COMPONENT 2 OF STRUCTURE PS_XTXT TO FIELD-SYMBOL(<LFS_ITEM>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_XTXT TO FIELD-SYMBOL(<LFS_ID>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_XTXT TO FIELD-SYMBOL(<LFS_FORM>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_XTXT TO FIELD-SYMBOL(<LFS_LINE>).

  <LFS_ITEM> = PV_ITEM.
  <LFS_ID>   = PV_TDID. "품목 텍스트
  <LFS_FORM> = GC_*.
  <LFS_LINE> = PV_JOB_NO  && ','
            && PV_LINE_NO && ','
            && PV_SERIAL_INFO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APND_XTXT_JNM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_RTXT
*&      --> GT_HBAN_JOB_NM
*&---------------------------------------------------------------------*
FORM APND_XTXT_JNM TABLES PT_XTXT
                    USING PV_JOB_NM.

  "PR/PO 생성시 Text 두번째 라인에 제조지시명 추가(PSJ 25.06.19)

  ASSIGN COMPONENT 5 OF STRUCTURE PT_XTXT TO FIELD-SYMBOL(<LFS_LINE>).

  <LFS_LINE> = PV_JOB_NM.
  APPEND PT_XTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PR_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PR_CREATE.

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER   = GS_RHDR
      PRHEADERX  = GS_RHDRX
*     TESTRUN    =
    IMPORTING
      NUMBER     = GS_RHDR-PREQ_NO
    TABLES
      RETURN     = GT_RTN
      PRITEM     = GT_RITM
      PRITEMX    = GT_RITMX
      PRACCOUNT  = GT_RACT
      PRACCOUNTX = GT_RACTX
      PRITEMTEXT = GT_RTXT.

  PERFORM BAPI_PR_RESULT USING 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PR_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM BAPI_PR_RESULT USING PV_TYPE.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0. "AND GS_RHDR-PREQ_NO IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    CLEAR : GT_HBAN-MSG[], GT_HBAN-STYLE[].

    CASE PV_TYPE.
      WHEN 'C'.
        GT_HBAN-STATUS = ICON_LED_GREEN.
        GT_HBAN-BANFN  = GS_RHDR-PREQ_NO.
        GT_HBAN-BNFPO  = 10.

      WHEN 'D'.
        GT_HBAN-STATUS = ICON_LED_YELLOW.
        GT_HBAN-BANFN  = SPACE.
        GT_HBAN-BNFPO  = SPACE.
        PERFORM RESET_LIF USING GT_HBAN.
        PERFORM SET_NBAN.

*       PERFORM SET_STYLE USING 'E' 'FLIEF' GT_HBAN-STYLE.
*       PERFORM SET_STYLE USING 'E' 'EMLIF' GT_HBAN-STYLE.

    ENDCASE.

    PERFORM MODIFY_6000 USING PV_TYPE GT_HBAN.

  ELSE.
    PERFORM BAPI_ROLLBACK.

    ASSIGN COMPONENT 'MSG' OF STRUCTURE GT_HBAN TO <GFS_MSG>.

    PERFORM SET_ERR_MSG USING GT_HBAN-STATUS.
  ENDIF.

  MODIFY GT_HBAN INDEX GS_ROW-INDEX.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_LIF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM RESET_LIF USING PS_HBXX.

  "구매문서 삭제시 업체 정보들 초기화

  CLEAR : GS_LIF.

  ASSIGN COMPONENT 'JOBLS' OF STRUCTURE PS_HBXX TO <GFS_JOBLS>.

  SELECT SINGLE FLIEF EMLIF
    FROM ZGTMMT6210
    INTO CORRESPONDING FIELDS OF GS_LIF
   WHERE JOBLS = <GFS_JOBLS>.

* PERFORM GET_LFA1 USING GS_LIF-FLIEF
*               CHANGING GS_LIF-FLIEF_NM.
*
* PERFORM GET_LFA1 USING GS_LIF-EMLIF
*               CHANGING GS_LIF-EMLIF_NM.

  MOVE-CORRESPONDING GS_LIF TO PS_HBXX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_6000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_TYPE
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM MODIFY_6000 USING PV_TYPE
                       PS_HBXX.

  DATA : LS_6000 LIKE ZGTMMT6000.
  DATA : LS_6000D LIKE ZGTMMT6000D.


  "신규 채번 아님!!(PSJ 25.01.23)
* PERFORM GET_NUMBER USING '01' 'ZGTMM_JOBL'
*                 CHANGING LS_6000-JOBLS.

  CASE PV_TYPE.
    WHEN 'C'.
      MOVE-CORRESPONDING PS_HBXX TO LS_6000.

      LS_6000-ERDAT       = SY-DATUM.
      LS_6000-ERDAT_LOCAL = SY-DATLO.
      LS_6000-ERTIM       = SY-UZEIT.
      LS_6000-ERTIM_LOCAL = SY-TIMLO.
      LS_6000-ERNAM       = SY-UNAME.

      MODIFY ZGTMMT6000 FROM LS_6000.

    WHEN 'D'.
      DELETE FROM ZGTMMT6000 WHERE JOBLS = <GFS_JOBLS>.

    WHEN 'L'. "--> 삭제 PO 로그 남기기
      MOVE-CORRESPONDING PS_HBXX TO LS_6000D.

      LS_6000D-ERDAT       = SY-DATUM.
      LS_6000D-ERDAT_LOCAL = SY-DATLO.
      LS_6000D-ERTIM       = SY-UZEIT.
      LS_6000D-ERTIM_LOCAL = SY-TIMLO.
      LS_6000D-ERNAM       = SY-UNAME.

      MODIFY ZGTMMT6000D FROM LS_6000D.
  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ERR_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN_STATUS
*&---------------------------------------------------------------------*
FORM SET_ERR_MSG USING PV_STATUS.

  PV_STATUS = ICON_LED_RED.

  "모든 에러 메세지를 보여준다!(PSJ 25.01.31)
  LOOP AT GT_RTN.
    CHECK GT_RTN-TYPE = GC_E OR GT_RTN-TYPE = GC_A.

    PERFORM SET_POP_MSG USING GT_RTN-TYPE
                              GT_RTN-ID
                              GT_RTN-NUMBER
                              GT_RTN-MESSAGE_V1
                              GT_RTN-MESSAGE_V2
                              GT_RTN-MESSAGE_V3
                              GT_RTN-MESSAGE_V4.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      <-- LS_6000_JOBLS
*&---------------------------------------------------------------------*
FORM GET_NUMBER USING PV_RANGE
                      PV_OBJECT
             CHANGING PV_NUMBER.

  CLEAR : PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = CONV NRNR( PV_RANGE )
      OBJECT                  = CONV NROBJ( PV_OBJECT )
*     QUANTITY                = '1'
*     SUBOBJECT               = ' '
*     TOYEAR                  = '0000'
*     IGNORE_BUFFER           = ' '
    IMPORTING
      NUMBER                  = PV_NUMBER
*     QUANTITY                =
*     RETURNCODE              =
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_DBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_DBAN.

  "구매요청 삭제기능 추가(PSJ 25.02.10)

  PERFORM CHECK_DBAN.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매요청 문서를 삭제하시겠습니까?'(P04).
  CHECK GV_ANS = GC_1.

  "선택한 라인별 PR 삭제
  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBAN INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    PERFORM SET_U_RITM.

    PERFORM BAPI_PR_CHANGE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DBAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DBAN.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '삭제할 레코드(들)을 선택하세요.'(M02).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBAN INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HBAN-BANFN IS INITIAL.
      MESSAGE S103 DISPLAY LIKE 'E'. "삭제할 대상이 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    "구매요청 생성 성공후 그 화면에서 바로 삭제할 경우, EBAN-STATU 추출 필요
    IF GT_HBAN-STATUS = ICON_LED_GREEN
   AND GT_HBAN-STATU IS INITIAL.
      SELECT SINGLE STATU FROM EBAN INTO GT_HBAN-STATU
       WHERE BANFN = GT_HBAN-BANFN
         AND BNFPO = GT_HBAN-BNFPO.
    ENDIF.

    IF GT_HBAN-STATU <> GC_N.
      MESSAGE S101 DISPLAY LIKE 'E'. "처리 상태를 확인하세요.
      GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_U_RITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_U_RITM.

  CLEAR : GT_RITM, GT_RITMX, GT_RITM[], GT_RITMX[], GT_RTN[].

  GT_RITM-PREQ_ITEM   = GT_HBAN-BNFPO. "선택한 라인의 품목번호
  GT_RITM-DELETE_IND  = GC_X.

  GT_RITMX-PREQ_ITEM  = GT_HBAN-BNFPO. "선택한 라인의 품목번호
  GT_RITMX-PREQ_ITEMX = GC_X.
  GT_RITMX-DELETE_IND = GC_X.

  APPEND : GT_RITM, GT_RITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PR_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PR_CHANGE.

  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      NUMBER  = GT_HBAN-BANFN
*     PRHEADER  =
*     PRHEADERX =
*     TESTRUN =
*   IMPORTING
*     PRHEADEREXP =
    TABLES
      RETURN  = GT_RTN
      PRITEM  = GT_RITM
      PRITEMX = GT_RITMX.

  PERFORM BAPI_PR_RESULT USING 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CBES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_CBES.

  PERFORM CHECK_CBES.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매오더를 생성하시겠습니까?'(P05).
  CHECK GV_ANS = GC_1.

  "구매오더 생성 기준 변경(PSJ 25.04.15)
  " 1.상품이외: 플랜트/공급업체/구매그룹/AAC/ItmT/자재코드/자재그룹/제조지시번호/라인번호 (최초 기준)
  " 2.상품(HAWA): 플랜트/공급업체/구매그룹/AAC/ItmT
  "시리얼정보에 따라 구매오더 아이템 한 건

  SORT GT_CBES BY GRP   WERKS FLIEF  EKGRP   KNTTP  PSTYP
                  MATNR MATKL JOB_NO LINE_NO SERIAL_INFO.

  LOOP AT GT_CBES.
    MOVE-CORRESPONDING GT_CBES TO GS_CBES.

    AT NEW GRP. "구매오더 생성 기준 변경(PSJ 25.04.15) LINE_NO.
      PERFORM SET_OHDR.
    ENDAT.

    GV_EBELP += 10.

    GT_CBES-EBELP = GV_EBELP.
    MODIFY GT_CBES TRANSPORTING EBELP.

    PERFORM SET_OITM.
    PERFORM SET_OSCD.
    PERFORM SET_OACT.
    PERFORM SET_OCND.
    PERFORM SET_OTXT.
    PERFORM SET_OCMP.

    AT END OF GRP. "구매오더 생성 기준 변경(PSJ 25.04.15) LINE_NO.
      PERFORM BAPI_PO_CREATE.
    ENDAT.
  ENDLOOP.

  "ALV List 반영 및 Table ZGTMMT6000 저장
  LOOP AT GT_CBES.
   READ TABLE GT_HBES WITH KEY IDX = GT_CBES-IDX.
*    READ TABLE GT_HBES INDEX GT_CBES-IDX.
    CHECK SY-SUBRC = 0.

    MOVE-CORRESPONDING GT_CBES TO GT_HBES.

*    MODIFY GT_HBES INDEX GT_CBES-IDX.
**   MODIFY GT_HBES WHERE IDX = GT_CBES-IDX.
    MODIFY GT_HBES
    TRANSPORTING STATUS EBELN EBELP MSG STYLE
    WHERE IDX = GT_CBES-IDX.

    IF GT_HBES-EBELN IS NOT INITIAL.
      "아이템 단위로 JOBLS (EBELN:JOBLS = 1:N)
      PERFORM MODIFY_6000 USING 'C' GT_HBES.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CBES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CBES.

  CLEAR : GT_CBES[].

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '구매오더 생성할 레코드(들)을 선택하세요.'(M03).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBES INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HBES-STATUS = ICON_DEFECT.
      MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBES-EBELN IS NOT INITIAL.
      MESSAGE S086 DISPLAY LIKE 'E'. "이미 구매 확정된 레코드가 있습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBES-FLIEF IS INITIAL.
      "필수 값이 누락되었습니다. &
      MESSAGE S008 WITH '공급업체'(F43) DISPLAY LIKE 'E'.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBES-INFNR IS INITIAL. "추가(PSJ 25.02.10)
      "정보레코드를 찾을 수 없습니다.
      MESSAGE S104 DISPLAY LIKE 'E'.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBES-EXPRC = GC_X AND GT_HBES-ONETW IS INITIAL. "추가(PSJ 25.03.31)
      MESSAGE S129 DISPLAY LIKE 'E'. "외주가공 금액이 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    PERFORM SET_GRP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GRP.

  "구매오더 생성 기준 변경(PSJ 25.04.15)
  " 1.상품이외: 플랜트/공급업체/구매그룹/AAC/ItmT/자재코드/자재그룹/제조지시번호/라인번호 (최초 기준)
  " 2.상품(HAWA): 플랜트/공급업체/구매그룹/AAC/ItmT

  CLEAR : GT_CBES.
  MOVE-CORRESPONDING GT_HBES TO GT_CBES.

  GT_CBES-GRP = GT_CBES-WERKS && GT_CBES-FLIEF && GT_CBES-EKGRP
             && GT_CBES-KNTTP && GT_CBES-PSTYP.


  IF GT_CBES-MTART <> GC_HAWA.
    GT_CBES-GRP = GT_CBES-GRP    && GT_CBES-MATNR && GT_CBES-MATKL
               && GT_CBES-JOB_NO && GT_CBES-LINE_NO.
  ENDIF.

  APPEND GT_CBES.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OHDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OHDR.

  CLEAR : GS_OHDR,   GS_OHDRX,   GT_OTXT[], GT_RTN[],
          GT_OITM[], GT_OITMX[], GT_OSCD[], GT_OSCDX[],
          GT_OACT[], GT_OACTX[], GT_OCND[], GT_OCNDX[],
          GT_OCMP[], GT_OCMPX[].

  CLEAR : GV_EBELP.

  GS_OHDR-COMP_CODE = GV_BUKRS.
  GS_OHDR-DOC_TYPE  = GC_NB.
  GS_OHDR-VENDOR    = GS_CBES-FLIEF. "공급업체
  GS_OHDR-PURCH_ORG = GS_CBES-EKORG. "구매조직
  GS_OHDR-PUR_GROUP = GS_CBES-EKGRP. "구매그룹

  GS_OHDRX-COMP_CODE = GC_X.
  GS_OHDRX-DOC_TYPE  = GC_X.
  GS_OHDRX-VENDOR    = GC_X.
  GS_OHDRX-PURCH_ORG = GC_X.
  GS_OHDRX-PUR_GROUP = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OITM.

  "Short Text: [PO]모든 경우 MES에서 받은 품명으로 지정(PSJ 25.04.01)

  CLEAR : GT_OITM, GT_OITMX.

  GT_OITM-PO_ITEM    = GV_EBELP.       "품목(+10)
  GT_OITM-PLANT      = GS_CBES-WERKS.  "플랜트
  GT_OITM-TRACKINGNO = GS_CBES-JOB_NO. "제조지시번호
  GT_OITM-INFO_REC   = GS_CBES-INFNR.  "정보레코드
  GT_OITM-QUANTITY   = GS_CBES-MENGE.  "수량
  GT_OITM-PO_UNIT    = GS_CBES-MEINS.  "단위
  GT_OITM-INFO_UPD   = SPACE.
  GT_OITM-ITEM_CAT   = GS_CBES-PSTYP.  "ItmT
  GT_OITM-ACCTASSCAT = GS_CBES-KNTTP.  "AAC
  GT_OITM-CONF_CTRL  = GS_CBES-BSTAE.  "확인제어
  GT_OITM-PREQ_NAME  = GS_CBES-AFNAM.  "요청자
  GT_OITM-FREE_ITEM  = GS_CBES-UMSON.  "무상
  GT_OITM-SHORT_TEXT = GS_CBES-TXZ01.  "자재명(MES)

  GT_OITMX-PO_ITEM    = GV_EBELP.
  GT_OITMX-PO_ITEMX   = GC_X.
  GT_OITMX-PLANT      = GC_X.
  GT_OITMX-TRACKINGNO = GC_X.
  GT_OITMX-INFO_REC   = GC_X.
  GT_OITMX-QUANTITY   = GC_X.
  GT_OITMX-PO_UNIT    = GC_X.
  GT_OITMX-INFO_UPD   = GC_X.
  GT_OITMX-ITEM_CAT   = GC_X.
  GT_OITMX-ACCTASSCAT = GC_X.
  GT_OITMX-CONF_CTRL  = GC_X.
  GT_OITMX-PREQ_NAME  = GC_X.
  GT_OITMX-FREE_ITEM  = GC_X.
  GT_OITMX-SHORT_TEXT = GC_X.

  IF     GS_CBES-KNTTP = GC_M.
    GT_OITM-MATERIAL_LONG = GS_CBES-MATNR.
    GT_OITM-STGE_LOC      = GS_CBES-LGORT.  "저장위치

    GT_OITMX-MATERIAL_LONG = GC_X.
    GT_OITMX-STGE_LOC      = GC_X.

    IF GS_CBES-WORK = GC_3 OR GS_CBES-WORK = GC_4.
      GT_OITM-SUPP_VENDOR = GS_CBES-EMLIF. "직납공급처
      GT_OITM-SC_VENDOR   = SWITCH #( GS_CBES-EMLIF WHEN ' ' THEN ' '
                                                             ELSE 'X' ).
      GT_OITMX-SUPP_VENDOR   = GT_OITMX-SC_VENDOR
                   = SWITCH #( GS_CBES-EMLIF WHEN ' ' THEN ' '
                                                      ELSE 'X' ).
    ENDIF.

  ELSEIF GS_CBES-KNTTP = GC_K.
*   GT_OITM-SHORT_TEXT = GS_CBES-TXZ01.  "내역
    GT_OITM-MATL_GROUP = GS_CBES-MATKL.

*   GT_OITMX-SHORT_TEXT = GC_X.
    GT_OITMX-MATL_GROUP = GC_X.

  ENDIF.

  APPEND : GT_OITM, GT_OITMX.

************************************************************************
  "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!

*  CLEAR : GT_OITM, GT_OITMX.
*
*  GT_OITM-PO_ITEM    = GV_EBELP.       "품목(+10)
*  GT_OITM-SHORT_TEXT = GS_CBES-TXZ01.  "내역
*  GT_OITM-PLANT      = GS_CBES-WERKS.  "플랜트
*  GT_OITM-STGE_LOC   = GS_CBES-LGORT.  "저장위치
*  GT_OITM-TRACKINGNO = GS_CBES-JOB_NO. "제조지시번호
*  GT_OITM-INFO_REC   = GS_CBES-INFNR.  "정보레코드
*  GT_OITM-QUANTITY   = GS_CBES-MENGE.  "수량
*  GT_OITM-PO_UNIT    = GS_CBES-MEINS.  "단위
*  GT_OITM-INFO_UPD   = SPACE.
*  GT_OITM-ACCTASSCAT = GS_CBES-KNTTP.  "AAC
*  GT_OITM-CONF_CTRL  = GS_CBES-BSTAE.  "확인제어
*  GT_OITM-PREQ_NAME  = GS_CBES-AFNAM.  "요청자
*  GT_OITM-FREE_ITEM  = GS_CBES-UMSON.  "무상
*
*  GT_OITMX-PO_ITEM    = GV_EBELP.
*  GT_OITMX-PO_ITEMX   = GC_X.
*  GT_OITMX-SHORT_TEXT = GC_X.
*  GT_OITMX-PLANT      = GC_X.
*  GT_OITMX-STGE_LOC   = GC_X.
*  GT_OITMX-TRACKINGNO = GC_X.
*  GT_OITMX-INFO_REC   = GC_X.
*  GT_OITMX-QUANTITY   = GC_X.
*  GT_OITMX-PO_UNIT    = GC_X.
*  GT_OITMX-INFO_UPD   = GC_X.
*  GT_OITMX-ACCTASSCAT = GC_X.
*  GT_OITMX-CONF_CTRL  = GC_X.
*  GT_OITMX-PREQ_NAME  = GC_X.
*  GT_OITMX-FREE_ITEM  = GC_X.
*
*  IF     GS_CBES-KNTTP = GC_M.
*    GT_OITM-INFO_REC  = SPACE.  "정보레코드
*    GT_OITMX-INFO_REC = SPACE.
*
*    "자재코드 O, 자재그룹 X (PSJ 25.01.21)
*    GT_OITM-MATERIAL_LONG = GS_CBES-MATNR.
*    GT_OITM-MATL_GROUP    = SPACE.
*
*    "아래 계산 금액을 BAPI_CURRENCY_CONV_TO_EXTERNAL
*    "외주가공 금액(ONETW) * 10000 / 수량(MENGE)
*    GT_OITM-NET_PRICE  = GS_CBES-ONETW * 10000 / GS_CBES-MENGE. "NETWR
*    PERFORM BAPI_CURRENCY_CONV_TO_EXTERNAL USING GS_CBES-WAERS
*                                                 GT_OITM-NET_PRICE
*                                        CHANGING GT_OITM-NET_PRICE.
*    GT_OITM-PRICE_UNIT  = 10000.
*    GT_OITM-ITEM_CAT    = GS_CBES-PSTYP. "ItmT
*    GT_OITM-SUPP_VENDOR = GS_CBES-EMLIF. "직납공급처
*    GT_OITM-SC_VENDOR   = SWITCH #( GS_CBES-EMLIF WHEN ' ' THEN ' '
*                                                           ELSE 'X' ).
*
*    GT_OITMX-NET_PRICE     = GC_X.
*    GT_OITMX-PRICE_UNIT    = GC_X.
*    GT_OITMX-ITEM_CAT      = GC_X.
*    GT_OITMX-SUPP_VENDOR   = GT_OITMX-SC_VENDOR
*                 = SWITCH #( GS_CBES-EMLIF WHEN ' ' THEN ' '
*                                                    ELSE 'X' ).
*
*  ELSEIF GS_CBES-KNTTP = GC_K.
*    "자재코드 X, 자재그룹 O (PSJ 25.01.21)
*    GT_OITM-MATERIAL_LONG = SPACE.
*    GT_OITM-MATL_GROUP    = GS_CBES-MATKL.
*
*  ENDIF.
*
*  GT_OITMX-MATERIAL_LONG
*  = SWITCH #( GT_OITM-MATERIAL_LONG WHEN ' ' THEN ' ' ELSE 'X' ).
*  GT_OITMX-MATL_GROUP
*  = SWITCH #( GT_OITM-MATL_GROUP    WHEN ' ' THEN ' ' ELSE 'X' ).
*
*  APPEND : GT_OITM, GT_OITMX.
************************************************************************
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CURRENCY_CONV_TO_EXTERNAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CBES_WAERS
*&      --> GT_OITM_NET_PRICE
*&      <-- GT_OITM_NET_PRICE
*&---------------------------------------------------------------------*
FORM BAPI_CURRENCY_CONV_TO_EXTERNAL USING PV_WAERS
                                          PV_NETPR_I
                                 CHANGING PV_NETPR_E.

  DATA : LV_NETPR LIKE BAPICURR-BAPICURR.


  CHECK PV_NETPR_I IS NOT INITIAL.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      CURRENCY        = PV_WAERS
      AMOUNT_INTERNAL = PV_NETPR_I
    IMPORTING
      AMOUNT_EXTERNAL = LV_NETPR.

  PV_NETPR_E = LV_NETPR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OSCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OSCD.

  CLEAR : GT_OSCD, GT_OSCDX.

  GT_OSCD-PO_ITEM       = GV_EBELP.
  GT_OSCD-SCHED_LINE    = GC_0001.
  GT_OSCD-DELIVERY_DATE = GS_CBES-EINDT. "납품일
  GT_OSCD-QUANTITY      = GS_CBES-MENGE. "수량

  GT_OSCDX-PO_ITEM       = GV_EBELP.
  GT_OSCDX-SCHED_LINE    = GC_0001.
  GT_OSCDX-PO_ITEMX      = GC_X.
  GT_OSCDX-SCHED_LINEX   = GC_X.
  GT_OSCDX-DELIVERY_DATE = GC_X.
  GT_OSCDX-QUANTITY      = GC_X.

  APPEND : GT_OSCD, GT_OSCDX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OACT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OACT.

  CLEAR : GT_OACT, GT_OACTX.

  GT_OACT-PO_ITEM   = GV_EBELP.
  GT_OACT-SERIAL_NO = GC_01.
  GT_OACT-UNLOAD_PT = GS_CBES-ABLAD. "하역지점
  GT_OACT-GR_RCPT   = GS_CBES-AFNAM. "요청인

  GT_OACTX-PO_ITEM    = GV_EBELP.
  GT_OACTX-SERIAL_NO  = GC_01.
  GT_OACTX-PO_ITEMX   = GC_X.
  GT_OACTX-SERIAL_NOX = GC_X.
  GT_OACTX-UNLOAD_PT  = GC_X.
  GT_OACTX-GR_RCPT    = GC_X.

  CASE GS_CBES-KNTTP.
    WHEN 'K'.
      GT_OACT-GL_ACCOUNT = GS_CBES-SAKTO. "G/L 계정번호
      GT_OACT-COSTCENTER = GS_CBES-KOSTL. "코스트센터

      GT_OACTX-GL_ACCOUNT = GC_X.
      GT_OACTX-COSTCENTER = GC_X.

    WHEN 'M'.
      GT_OACT-SD_DOC     = GS_CBES-VBELN. "판매오더번호
      GT_OACT-ITM_NUMBER = GS_CBES-VBELP. "판매오더품목

      GT_OACTX-SD_DOC     = GC_X.
      GT_OACTX-ITM_NUMBER = GC_X.

  ENDCASE.

  APPEND : GT_OACT, GT_OACTX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OCND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OCND.

  "기준 변경(PSJ 25.02.10): 단가(단위 참조 불필요)

* CHECK GS_CBES-KNTTP = GC_M.
* CHECK GS_CBES-PSTYP = GC_3. "임가공
  CHECK GS_CBES-WORK = GC_4 OR GS_CBES-WORK = GC_7.

  CLEAR : GT_OCND, GT_OCNDX.

  GT_OCND-ITM_NUMBER       = GV_EBELP.
  GT_OCND-COND_ST_NO       = GC_001. "002
  GT_OCND-COND_COUNT       = GC_02.  "GC_01.
  GT_OCND-COND_TYPE        = GC_PBXX.
  GT_OCND-COND_VALUE = GS_CBES-ONETW * 10000 / GS_CBES-MENGE. "GT_OITM-NET_PRICE.
  GT_OCND-CURRENCY         = GS_CBES-WAERS.
  GT_OCND-COND_P_UNT       = 10000. "GT_OITM-PRICE_UNIT.
* GT_OCND-COND_UNIT        = GS_CBES-MEINS.
  GT_OCND-CHANGE_ID        = GC_I.
  GT_OCND-COND_COUNT_LONG  = GC_002.

  GT_OCNDX-ITM_NUMBER      = GV_EBELP.
  GT_OCNDX-COND_ST_NO      = GC_001.
  GT_OCNDX-COND_COUNT      = GC_X.
  GT_OCNDX-ITM_NUMBERX     = GC_X.
  GT_OCNDX-COND_ST_NOX     = GC_X.
  GT_OCNDX-COND_TYPE       = GC_X.
  GT_OCNDX-COND_VALUE      = GC_X.
  GT_OCNDX-CURRENCY        = GC_X.
  GT_OCNDX-COND_P_UNT      = GC_X.
* GT_OCNDX-COND_UNIT       = GC_X.
  GT_OCNDX-CHANGE_ID       = GC_X.
  GT_OCNDX-COND_COUNT_LONG = GC_X.

  APPEND : GT_OCND, GT_OCNDX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OTXT.

  DATA : LV_BSTMG(20),
         LV_ONETP(20).


  CLEAR : GT_OTXT.

  "제조지시번호(JOB_NO) && ',' && 라인번호(LINE_NO) && ',' && 시리얼정보(SERIAL_INFO)
  " && 가공수량(BSTMG) && 'X' && '@' && 외주가공단가 && Curr
  " 예1) 24040201,LN1,00101 / 73,734.000 X @4 KRW
  " 예2) 24040201,LN1,00101 / 73,734.000 X @1.30 USD

  PERFORM SET_XTXT USING GV_EBELP 'F01'
                         GS_CBES-JOB_NO
                         GS_CBES-LINE_NO
                         GS_CBES-SERIAL_INFO
                CHANGING GT_OTXT.

  "자재유형이 'HAWA'/'ROH'일 경우, 제조지시번호(JOB_NO)만 입력(PSJ 25.03.31)
  IF GS_CBES-MTART = GC_HAWA OR GS_CBES-MTART = GC_ROH.
    GT_OTXT-TEXT_LINE = GS_CBES-JOB_NO.
  ENDIF.

* IF GS_CBES-KNTTP = GC_M
* IF GS_CBES-WORK = GC_4 OR GS_CBES-WORK = GC_7. "기준 변경(PSJ 25.02.10)
  IF GS_CBES-WORK = GC_4.                        "기준 변경(PSJ 25.02.24)
    WRITE GS_CBES-BSTMG     UNIT GS_CBES-BSTME TO LV_BSTMG.
    WRITE GS_CBES-ONETP CURRENCY GS_CBES-OWAER TO LV_ONETP.

    CONDENSE : LV_BSTMG, LV_ONETP.

    GT_OTXT-TEXT_LINE = GT_OTXT-TEXT_LINE && ` / `
                     && LV_BSTMG          && ` X @` "가공 수량
                     && LV_ONETP          && ` `    "외주공정 단가
                     && GS_CBES-OWAER.              "외주공정 Curr
  ENDIF.

  APPEND GT_OTXT.

  PERFORM APND_XTXT_JNM TABLES GT_OTXT
                         USING GS_CBES-JOB_NM. "추가(PSJ 25.06.19)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OCMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OCMP.

  DATA : LT_CMP LIKE TABLE OF GT_IBES.

  DATA : LV_CNT TYPE I.


* CHECK GS_CBES-KNTTP = GC_M.
* CHECK GS_CBES-PSTYP = GC_3. "임가공
  CHECK GS_CBES-WORK = GC_4 OR GS_CBES-WORK = GC_7.

* SELECT C~MES_CMP, C~MATNR, C~BDMNG, C~MEINS, M~SBDKZ
*   FROM ZGTMMT6211 AS C LEFT JOIN MARC AS M
*     ON C~MATNR = M~MATNR
*   INTO TABLE @DATA(LT_CMP)
*  WHERE C~JOBLS = @GS_CBES-JOBLS
*    AND M~WERKS = @GS_CBES-WERKS. "상위 플랜트

  PERFORM GET_CMP_DATA TABLES LT_CMP
                        USING GS_CBES-JOBLS
                              GS_CBES-WERKS ' '.

* CHECK LT_CMP[] IS NOT INITIAL.
* SORT LT_CMP BY MES_CMP.

  LOOP AT LT_CMP INTO DATA(LS_CMP).
    CLEAR : GT_OCMP, GT_OCMPX.
    LV_CNT += 1.

    GT_OCMP-PO_ITEM        = GV_EBELP.
    GT_OCMP-SCHED_LINE     = GC_0001.
    GT_OCMP-ITEM_NO        = LV_CNT.
    GT_OCMP-MATERIAL_LONG  = LS_CMP-MATNR.
    GT_OCMP-ENTRY_QUANTITY = LS_CMP-BDMNG.
    GT_OCMP-ENTRY_UOM      = LS_CMP-MEINS.
    GT_OCMP-PLANT          = GS_CBES-WERKS.
    GT_OCMP-CHANGE_ID      = GC_I.
    GT_OCMP-ISS_ST_LOC     = LS_CMP-UMLGO.
*   GT_OCMP-ISS_ST_LOC = SWITCH #( LS_CMP-SBDKZ WHEN '1' THEN '2530' ).

    GT_OCMPX-PO_ITEM        = GV_EBELP.
    GT_OCMPX-SCHED_LINE     = GC_0001.
    GT_OCMPX-ITEM_NO        = LV_CNT.
    GT_OCMPX-PO_ITEMX       = GC_X.
    GT_OCMPX-SCHED_LINEX    = GC_X.
    GT_OCMPX-ITEM_NOX       = GC_X.
    GT_OCMPX-MATERIAL_LONG  = GC_X.
    GT_OCMPX-ENTRY_QUANTITY = GC_X.
    GT_OCMPX-ENTRY_UOM      = GC_X.
    GT_OCMPX-PLANT          = GC_X.
    GT_OCMPX-CHANGE_ID      = GC_X.
    GT_OCMPX-ISS_ST_LOC = SWITCH #( LS_CMP-UMLGO WHEN ' ' THEN ' ' ELSE 'X' ).
*   GT_OCMPX-ISS_ST_LOC = SWITCH #( LS_CMP-SBDKZ WHEN '1' THEN 'X' ).

    APPEND : GT_OCMP, GT_OCMPX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PO_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PO_CREATE.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      POHEADER         = GS_OHDR
      POHEADERX        = GS_OHDRX
      NO_AUTHORITY     = GC_X
    IMPORTING
      EXPPURCHASEORDER = GS_OHDR-PO_NUMBER
    TABLES
      RETURN           = GT_RTN
      POITEM           = GT_OITM
      POITEMX          = GT_OITMX
      POSCHEDULE       = GT_OSCD
      POSCHEDULEX      = GT_OSCDX
      POACCOUNT        = GT_OACT
      POACCOUNTX       = GT_OACTX
      POCOND           = GT_OCND
      POCONDX          = GT_OCNDX
      POTEXTITEM       = GT_OTXT
      POCOMPONENTS     = GT_OCMP
      POCOMPONENTSX    = GT_OCMPX.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0 AND GS_OHDR-PO_NUMBER IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    GS_CBES-STATUS = ICON_LED_GREEN.
    GS_CBES-EBELN  = GS_OHDR-PO_NUMBER.
    CLEAR : GS_CBES-MSG[], GS_CBES-STYLE[].

    MODIFY GT_CBES FROM GS_CBES TRANSPORTING STATUS EBELN MSG STYLE
     WHERE GRP     = GS_CBES-GRP. "구매오더 생성 기준 변경(PSJ 25.04.15)
*    WHERE WERKS   = GS_CBES-WERKS
*      AND FLIEF   = GS_CBES-FLIEF
*      AND EKGRP   = GS_CBES-EKGRP
*      AND KNTTP   = GS_CBES-KNTTP
*      AND PSTYP   = GS_CBES-PSTYP
*      AND MATNR   = GS_CBES-MATNR
*      AND MATKL   = GS_CBES-MATKL
*      AND JOB_NO  = GS_CBES-JOB_NO
*      AND LINE_NO = GS_CBES-LINE_NO.

  ELSE.
    PERFORM BAPI_ROLLBACK.

    ASSIGN COMPONENT 'MSG' OF STRUCTURE GS_CBES TO <GFS_MSG>.
    CLEAR : <GFS_MSG>.

    PERFORM SET_ERR_MSG USING GS_CBES-STATUS.
    GS_CBES-EBELP = SPACE.

    MODIFY GT_CBES FROM GS_CBES TRANSPORTING STATUS EBELP MSG
     WHERE GRP     = GS_CBES-GRP. "구매오더 생성 기준 변경(PSJ 25.04.15)
*    WHERE WERKS   = GS_CBES-WERKS
*      AND FLIEF   = GS_CBES-FLIEF
*      AND EKGRP   = GS_CBES-EKGRP
*      AND KNTTP   = GS_CBES-KNTTP
*      AND PSTYP   = GS_CBES-PSTYP
*      AND MATNR   = GS_CBES-MATNR
*      AND MATKL   = GS_CBES-MATKL
*      AND JOB_NO  = GS_CBES-JOB_NO
*      AND LINE_NO = GS_CBES-LINE_NO.

  ENDIF.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_DBES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_DBES.

  "구매오더 삭제기능 추가(PSJ 25.02.10)

  PERFORM CHECK_DBES.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매오더 문서를 삭제하시겠습니까?'(P06).
  CHECK GV_ANS = GC_1.

  SORT GT_DBES BY EBELN EBELP.

  LOOP AT GT_DBES.
    MOVE-CORRESPONDING GT_DBES TO GS_DBES.

    AT NEW EBELN.
      CLEAR : GT_OITM[], GT_OITMX[], GT_RTN[].
    ENDAT.

    PERFORM SET_U_OITM.

    AT END OF EBELN.
      PERFORM BAPI_PO_CHANGE.
    ENDAT.
  ENDLOOP.

  "ALV List 반영 및 Table ZGTMMT6000 삭제
  LOOP AT GT_DBES.

*    READ TABLE GT_HBES INDEX GT_DBES-IDX.
    READ TABLE GT_HBES WITH KEY IDX = GT_DBES-IDX.
    CHECK SY-SUBRC = 0.

*--> [CHM2509-00580] 삭제로그 관리 추가
**** ZGTMMT6000D 테이블에 삭제로그를 남겨 BMS PO I/F 시 활용
    PERFORM MODIFY_6000 USING 'L' GT_HBES.
*<-- [CHM2509-00580] 삭제로그 관리 추가

    MOVE-CORRESPONDING GT_DBES TO GT_HBES.
*   IF GT_HBES-WORK = GC_4.
*     PERFORM SET_STYLE USING 'E' 'EMLIF' GT_DBES-STYLE.
*   ENDIF.

    IF GT_HBES-EBELN IS INITIAL. "삭제 성공시..
      PERFORM RESET_LIF USING GT_HBES.
      PERFORM SET_NBES.

      PERFORM MODIFY_6000 USING 'D' GT_HBES.
    ENDIF.

*    MODIFY GT_HBES INDEX GT_DBES-IDX.
*    CLEAR : GS_HBES.
*    MOVE-CORRESPONDING GT_HBES TO GS_HBES.
    MODIFY GT_HBES
    TRANSPORTING EMLIF EMLIF_NM FLIEF FLIEF_NM WERKS MATNR STYLE
                 WAERS NETWR INFNR EKORG PSTYP EINDT
                 EBELN EBELP STATUS MSG NETPR PEINH BPRME
    WHERE IDX = GT_DBES-IDX.

  ENDLOOP.

* PERFORM PRCS_REFR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DBES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DBES.

  CLEAR : GT_DBES[].

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '삭제할 레코드(들)을 선택하세요.'(M02).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBES INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HBES-EBELN IS INITIAL.
      MESSAGE S103 DISPLAY LIKE 'E'. "삭제할 대상이 없습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBES-STATUS = ICON_DEFECT.
      MESSAGE S006 DISPLAY LIKE 'E'. "에러 내역이 존재합니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    MOVE-CORRESPONDING GT_HBES TO GT_DBES.
    APPEND GT_DBES.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_U_OITM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_U_OITM.

  CLEAR : GT_OITM, GT_OITMX.

  GT_OITM-PO_ITEM     = GS_DBES-EBELP. "PO항번
  GT_OITM-DELETE_IND  = GC_L.

  GT_OITMX-PO_ITEM    = GS_DBES-EBELP. "PO항번
  GT_OITMX-PO_ITEMX   = GC_X.
  GT_OITMX-DELETE_IND = GC_X.

  APPEND : GT_OITM, GT_OITMX.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PO_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PO_CHANGE.

  DATA : BEGIN OF LS_DEL,
           EBELN LIKE EKPO-EBELN,
           EBELP LIKE EKPO-EBELP,

           INFNR LIKE EKPO-INFNR,  "정보레코드
           NETPR LIKE EKPO-NETPR,  "Info 단가
           PEINH LIKE EKPO-PEINH,  "Per
           BPRME LIKE EKPO-BPRME,  "OPU
         END   OF LS_DEL.


  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GS_DBES-EBELN
    TABLES
      RETURN        = GT_RTN
      POITEM        = GT_OITM
      POITEMX       = GT_OITMX.

  READ TABLE GT_RTN WITH KEY TYPE = GC_E.

  IF SY-SUBRC <> 0.
    PERFORM BAPI_COMMIT.

    GS_DBES-STATUS = ICON_LED_YELLOW.
    MOVE-CORRESPONDING LS_DEL TO GS_DBES. "관련 필드 Clear

    CLEAR : GS_DBES-MSG[], GS_DBES-STYLE[].
*   PERFORM SET_STYLE USING 'E' 'FLIEF' GS_DBES-STYLE.
*   IF GS_DBES-WORK = GC_4.
*     PERFORM SET_STYLE USING 'E' 'EMLIF' GS_DBES-STYLE.
*   ENDIF.
  ELSE.
    PERFORM BAPI_ROLLBACK.

    ASSIGN COMPONENT 'MSG' OF STRUCTURE GS_DBES TO <GFS_MSG>.

    PERFORM SET_ERR_MSG USING GS_DBES-STATUS.
  ENDIF.

  LOOP AT GT_OITMX.
    MODIFY GT_DBES FROM GS_DBES
           TRANSPORTING STATUS EBELN EBELP MSG STYLE
                        INFNR  NETPR PEINH BPRME
                  WHERE EBELN = GT_DBES-EBELN
                    AND EBELP = GT_OITMX-PO_ITEM.
  ENDLOOP.

  GV_REF = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_RDPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_RDPO.

  "구매오더 삭제요청 기능 추가(PSJ 25.04.30)

  PERFORM CHECK_RDPO.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                                 '구매오더 삭제요청을 하시겠습니까?'(P07).
  CHECK GV_ANS = GC_1.

  PERFORM GET_EM_RECV.

  CALL SCREEN 200 STARTING AT 10 5
                    ENDING AT 60 12.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RDPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_RDPO.

  CLEAR : GT_RDPO[], GT_RDPM[], GV_CLCRS.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X'
                                  '구매오더 삭제요청 할 레코드(들)을 선택하세요.'(M04).
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE GT_HBAN INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GT_HBAN-EBELN IS INITIAL.
      MESSAGE S140 DISPLAY LIKE 'E'. "구매오더가 없는 레코드가 포함되어 있습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    IF GT_HBAN-DEL_REQDT IS NOT INITIAL.
      MESSAGE S141 DISPLAY LIKE 'E'. "이미 구매오더 삭제요청한 레코드가 포함되어 있습니다.
      GV_ERR = GC_X. EXIT.
    ENDIF.

    MOVE-CORRESPONDING GT_HBAN TO GT_RDPO.
    APPEND GT_RDPO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EM_RECV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EM_RECV.

  "메일 수신자 로직 기준 변경(PSJ 25.05.08)
  " 송신자의 가장 최근 날짜에 해당하는 메일 주소 모두

  IF GR_RCUST IS BOUND.
    GV_REF = GC_X.
  ENDIF.

  SELECT DISTINCT EM_RECV, EM_DATLO
    FROM ZGTMMT6212
   WHERE EM_RECV <> @SPACE
     AND EM_UNAME = @SY-UNAME
    INTO TABLE @DATA(LT_EM).

  CHECK LT_EM IS NOT INITIAL.

  SORT LT_EM BY EM_DATLO DESCENDING EM_RECV ASCENDING.
  DELETE LT_EM WHERE EM_DATLO <> LT_EM[ 1 ]-EM_DATLO.

  GT_RDPM[] = VALUE #( FOR LS_EM IN LT_EM INDEX INTO LV_IDX
                       ( SEQNO   = LV_IDX
                         EM_RECV = LS_EM-EM_RECV ) ).

************************************************************************
* "ZGTMMT6212에서 EM_DATLO, EM_TIMLO가 가장 최근인 제조지시번호의 수신자 E-Mail Default
*
* SELECT EM_RECV, EM_DATLO, EM_TIMLO
*   FROM ZGTMMT6212
*  WHERE EM_RECV <> @SPACE
*   INTO TABLE @DATA(LT_EM).
*
* CHECK LT_EM IS NOT INITIAL.
*
* SORT LT_EM BY EM_DATLO DESCENDING EM_TIMLO DESCENDING.
*
* CLEAR : GT_RDPM.
* GT_RDPM-SEQNO   = 1.
* GT_RDPM-EM_RECV = LT_EM[ 1 ]-EM_RECV.
* APPEND GT_RDPM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_RDPS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_RDPS.

  DATA : LT_REV TYPE BCSY_SMTPA,
         LS_REV TYPE LINE OF BCSY_SMTPA,
         LT_ATT TYPE BCSY_IFDOC,
         LV_RST.


  PERFORM CHECK_RDPS.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_RDPM.
    LS_REV = GT_RDPM-EM_RECV.
    COLLECT LS_REV INTO LT_REV.
  ENDLOOP.

  PERFORM SET_MAIL_MSG.

  CALL FUNCTION 'ZCC_SEND_MAIL'
    EXPORTING
      I_SENDER           = SY-UNAME
      I_RECEIVER         = LT_REV
      I_TITLE            = '구매오더 삭제요청'
*     I_DOCUMENT_TYPE    = 'HTM'
*     I_PUT_IN_OUTBOX    = 'X'
      I_SEND_IMMEDIATELY = 'X'
*     I_BC_RECEIVER      =
    IMPORTING
      E_RESULT           = LV_RST
    TABLES
      T_ATTACHMENTS      = LT_ATT
      T_MSG              = GT_MTXT.

  CASE LV_RST.
    WHEN 'X'.
      MESSAGE S143 DISPLAY LIKE 'E'. "구매오더 삭제요청 메일을 전송할 수 없습니다.

    WHEN OTHERS.
      PERFORM INSERT_6600.
      GV_REF = GC_X.

      MESSAGE S144. "구매오더 삭제요청 메일을 전송하였습니다.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RDPS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_RDPS.

  CLEAR : GV_ERR.

  IF GV_CLCRS IS INITIAL.
    MESSAGE S142 DISPLAY LIKE 'E'. "삭제요청 사유는 필수 입력값입니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

  IF GT_RDPM[] IS INITIAL OR LINE_EXISTS( GT_RDPM[ EM_RECV = SPACE ] ).
    MESSAGE S015 WITH '수신자 E-Mail'(T03) DISPLAY LIKE 'E'. "&를(을)입력하세요.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAIL_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MAIL_MSG.

  DATA : LT_RDPO     LIKE GT_LOCK OCCURS 0 WITH HEADER LINE,
         LV_DATE(10).


  LT_RDPO[] = CORRESPONDING #( GT_RDPO[] ).

  SORT LT_RDPO BY JOB_NO.
  DELETE ADJACENT DUPLICATES FROM LT_RDPO COMPARING JOB_NO.

  WRITE SY-DATLO TO LV_DATE.

  CLEAR : GT_MTXT.

  _SET_HTML1 '<!DOCTYPE HTML>'.
  _SET_HTML1 '<HTML LANG="KO">'.
  _SET_HTML1 '<HEAD>'.
  _SET_HTML1 '<META CHARSET="UTF-8">'.
  _SET_HTML1 '<META NAME="VIEWPORT" CONTENT="WIDTH=DEVICE-WIDTH, INITIAL-SCALE=1.0">'.
  _SET_HTML1 '</HEAD>'.
  _SET_HTML1 '<BODY>'.
  _SET_HTML1 '<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">항상 협조해 주셔서 감사 드립니다.</P>'.
  _SET_HTML1 '<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">아래 제조지시번호로 발생한 구매오더에 대해 삭제 요청 드립니다.</P><BR>'.

  LOOP AT LT_RDPO.
    _SET_HTML3 `<P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">제조지시 번호 : ` LT_RDPO-JOB_NO '</P>'.
  ENDLOOP.

  _SET_HTML3 `<BR><P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">PO삭제 요청일 : ` LV_DATE '</P>'.
  _SET_HTML1 '<BR><P STYLE="MARGIN: 0; PADDING: 0; FONT-SIZE: 14PX;">"T-CODE : ZGTMMR6600_[BD] 구매오더 삭제요청 처리"에서 처리 부탁 드립니다.</P>'.
  _SET_HTML1 '</BODY>'.
  _SET_HTML1 '</HTML>'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_6600
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_6600.

  DATA : LT_6600 LIKE ZGTMMT6600 OCCURS 0 WITH HEADER LINE,
         LT_6212 LIKE ZGTMMT6212 OCCURS 0 WITH HEADER LINE.


  "ALV List 삭제요청일 반영 및 Table ZGTMMT6600/ZGTMMT6212 저장

  PERFORM SET_TSTMP USING GS_CREA.

  LOOP AT GT_RDPO.
    READ TABLE GT_HBAN WITH KEY IDX = GT_RDPO-IDX.
    CHECK SY-SUBRC = 0.

    GT_HBAN-DEL_REQDT = SY-DATLO.
    MODIFY GT_HBAN TRANSPORTING DEL_REQDT
                          WHERE IDX = GT_RDPO-IDX.

    MOVE-CORRESPONDING GT_RDPO TO LT_6600.
    MOVE-CORRESPONDING GS_CREA TO LT_6600.
    LT_6600-CLCRS =  GV_CLCRS.
    APPEND LT_6600.

    LOOP AT GT_RDPM.
      MOVE-CORRESPONDING GT_RDPO TO LT_6212.
      MOVE-CORRESPONDING GT_RDPM TO LT_6212.
      LT_6212-EM_UNAME = GS_CREA-ERNAM.
      LT_6212-EM_DATLO = GS_CREA-ERDAT_LOCAL.
      LT_6212-EM_TIMLO = GS_CREA-ERTIM_LOCAL.
      APPEND LT_6212.
    ENDLOOP.
  ENDLOOP.

  CHECK LT_6600[] IS NOT INITIAL.

  MODIFY ZGTMMT6600 FROM TABLE LT_6600.
  MODIFY ZGTMMT6212 FROM TABLE LT_6212.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  CLEAR : PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CNFX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM PRCS_CNFX USING PV_CHK.

  "확정대상 취소/확정대상 원복 기능 추가(PSJ 25.05.09)
  " 구매오더시에도 해당 기능 추가(PSJ 25.06.19)

  CASE 'X'.
    WHEN P_BAN.
      PERFORM PRCS_CNFX_BXX TABLES GT_HBAN
                             USING PV_CHK.

    WHEN P_BES.
      PERFORM PRCS_CNFX_BXX TABLES GT_HBES
                             USING PV_CHK.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_CNFX_BXX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&      --> PV_CHK
*&---------------------------------------------------------------------*
FORM PRCS_CNFX_BXX TABLES PT_HBXX
                    USING PV_CHK.

  "구매요청/구매오더 확정대상 기능 로직 통합 작업(PSJ 25.06.20)

  PERFORM CHECK_CNFX TABLES PT_HBXX
                      USING PV_CHK.
  CHECK GV_ERR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'(P01) GV_PMSG.
  CHECK GV_ANS = GC_1.

  SORT GT_ROW BY INDEX DESCENDING.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE PT_HBXX INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    PERFORM UPDATE_CNFCL TABLES PT_HBXX
                          USING PV_CHK.
  ENDLOOP.

  IF GV_ERR IS INITIAL.
    COMMIT WORK.
    GV_REF = GC_X.
    MESSAGE S000 WITH GV_RMSG.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S152 DISPLAY LIKE 'E'. "DB 에러 발생하였습니다. 다시 시도해 주세요.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CNFX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&      --> PV_CHK
*&---------------------------------------------------------------------*
FORM CHECK_CNFX TABLES PT_HBXX  "추가(PSJ 25.06.19)
                 USING PV_CHK.

  PERFORM SET_XMSG USING PV_CHK.

  PERFORM GET_SELECTED_ROWS USING GR_HGRID 'M' 'X' ' '.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROW INTO GS_ROW.
    READ TABLE PT_HBXX INDEX GS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    DATA(LV_KNAME) = COND #( WHEN P_BAN = GC_X THEN 'BANFN'
                             WHEN P_BES = GC_X THEN 'EBELN' ).

    ASSIGN COMPONENT LV_KNAME OF STRUCTURE PT_HBXX
                              TO FIELD-SYMBOL(<LFS_KNAME>).
    ASSIGN COMPONENT 'CNFCL'  OF STRUCTURE PT_HBXX
                              TO FIELD-SYMBOL(<LFS_CNFCL>).

    IF ( PV_CHK = GC_X  AND ( <LFS_CNFCL> = GC_X OR <LFS_KNAME> <> SPACE ) )
    OR ( PV_CHK = SPACE AND ( <LFS_CNFCL> = SPACE ) ).
      MESSAGE S000 WITH GV_EMSG DISPLAY LIKE 'E'.
      GV_ERR = GC_X. EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_XMSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_CHK
*&---------------------------------------------------------------------*
FORM SET_XMSG USING PV_CHK.

  DATA : LV_TXT(10).


  CLEAR : GV_EMSG, GV_PMSG, GV_RMSG.

  LV_TXT = COND #( WHEN PV_CHK = GC_X  THEN '확정대상에서 취소'(M05)
                   WHEN PV_CHK = SPACE THEN '확정대상으로 원복'(M06) ).

  MESSAGE S149(ZGTMM01) WITH LV_TXT INTO GV_EMSG. "& 할 수 없는 건이 존재합니다.
  MESSAGE S150(ZGTMM01) WITH LV_TXT INTO GV_PMSG. "선택한 데이터를 모두 & 하시겠습니까?
  MESSAGE S151(ZGTMM01) WITH LV_TXT INTO GV_RMSG. "& 되었습니다.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_CNFCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&      --> PV_CHK
*&---------------------------------------------------------------------*
FORM UPDATE_CNFCL TABLES PT_HBXX  "추가(PSJ 25.06.19)
                   USING PV_CHK.

  ASSIGN COMPONENT 'JOB_NO' OF STRUCTURE PT_HBXX
                            TO FIELD-SYMBOL(<LFS_JOB_NO>).
  ASSIGN COMPONENT 'JOBLS ' OF STRUCTURE PT_HBXX
                            TO FIELD-SYMBOL(<LFS_JOBLS>).

  UPDATE ZGTMMT6210 SET CNFCL  = PV_CHK
                  WHERE JOB_NO = <LFS_JOB_NO>
                    AND JOBLS  = <LFS_JOBLS>.

  IF SY-SUBRC = 0.
    "처리 성공한 건은 List에서 삭제(PSJ 25.05.12)
    DELETE PT_HBXX INDEX GS_ROW-INDEX.
*   GT_HBAN-CNFCL = PV_CHK.
*   MODIFY GT_HBAN INDEX GS_ROW-INDEX TRANSPORTING CNFCL.
  ELSE.
    GV_ERR = GC_X.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_ONF4 USING PV_FNAME
                       PV_FVAL
                       PS_ROID  TYPE LVC_S_ROID
                       PR_EVENT TYPE REF TO CL_ALV_EVENT_DATA
                       PT_BCELL TYPE LVC_T_MODI
                       PV_DISPLAY
                       PV_OTEXT.

  FIELD-SYMBOLS : <LT_MODI> TYPE LVC_T_MODI.

  DATA : LS_MODI TYPE LVC_S_MODI.


  PR_EVENT->M_EVENT_HANDLED = GC_X.

  CLEAR : GV_IDX, GT_RTAB[].
  GV_IDX = PS_ROID-ROW_ID.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      CASE PV_FNAME.
        WHEN 'FLIEF'.
          PERFORM F4_FLIEF.

      ENDCASE.

    WHEN 'GR_IGRID'.

  ENDCASE.

  CHECK PV_DISPLAY IS INITIAL.
  CHECK GT_RTAB[]  IS NOT INITIAL.

  ASSIGN PR_EVENT->M_DATA->* TO <LT_MODI>.

  CLEAR : LS_MODI.
  LS_MODI-ROW_ID    = PS_ROID-ROW_ID.
  LS_MODI-FIELDNAME = PV_FNAME.
  LS_MODI-VALUE     = VALUE #( GT_RTAB[ 1 ]-FIELDVAL OPTIONAL ).
  APPEND LS_MODI TO <LT_MODI>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_FLIEF.

  "공급업체 F4 로직 추가(PSJ 25.05.07)

  CASE 'X'.
    WHEN P_BAN.
      PERFORM F4_A_FLIEF TABLES GT_HBAN.
    WHEN P_BES.
      PERFORM F4_A_FLIEF TABLES GT_HBES.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_A_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM F4_A_FLIEF TABLES PT_HBXX.

  READ TABLE PT_HBXX INDEX GV_IDX.
  CHECK SY-SUBRC = 0.

  ASSIGN COMPONENT 'MATNR' OF STRUCTURE PT_HBXX TO FIELD-SYMBOL(<LFS_MATNR>).
  ASSIGN COMPONENT 'WERKS' OF STRUCTURE PT_HBXX TO FIELD-SYMBOL(<LFS_WERKS>).

  SELECT DISTINCT E~LIFNR, L~NAME1
    FROM EORD AS E LEFT JOIN LFA1 AS L
      ON E~LIFNR = L~LIFNR
*    AND L~LOEVM = @SPACE
     AND L~SPRAS = @SY-LANGU
    INTO TABLE @DATA(LT_LIFNR)
   WHERE E~MATNR  = @<LFS_MATNR>
     AND E~WERKS  = @<LFS_WERKS>
     AND E~NOTKZ  = @SPACE
     AND E~VDATU <= @SY-DATLO
     AND E~BDATU >= @SY-DATLO
     AND L~LOEVM  = @SPACE.

  SORT LT_LIFNR BY LIFNR.

  PERFORM F4IF_TABLE TABLES LT_LIFNR
                      USING 'LIFNR'
                            'FLIEF'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4IF_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LIFNR
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_TABLE TABLES PT_VTAB
                 USING PV_RFIELD
                       PV_DFIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = PV_RFIELD
*     PVALKEY         = ' '
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_DFIELD
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      VALUE_ORG       = GC_S
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*     IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = PT_VTAB
*     FIELD_TAB       =
      RETURN_TAB      = GT_RTAB
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PS_ROW  TYPE LVC_S_ROW
                               PS_COL  TYPE LVC_S_COL
                               PS_ROID TYPE LVC_S_ROID
                               PV_OTEXT.

  CLEAR : GV_CHK, GV_IDX.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID'.
      IF PS_COL-FIELDNAME = 'STATUS'.
        GV_CHK = GC_M.
      ENDIF.

      GV_IDX = PS_ROW-INDEX.

      CASE 'X'.
        WHEN P_BAN.
          PERFORM CLK_DUB_HDR TABLES GT_HBAN.
        WHEN P_BES.
          PERFORM CLK_DUB_HDR TABLES GT_HBES.
      ENDCASE.

    WHEN 'GR_IGRID'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLK_DUB_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM CLK_DUB_HDR TABLES PT_HBXX.

  READ TABLE PT_HBXX INDEX GV_IDX.
  CHECK SY-SUBRC = 0.

  IF GV_CHK = GC_M.
    ASSIGN COMPONENT 'MSG' OF STRUCTURE PT_HBXX TO <GFS_MSG>.
    PERFORM DISPLAY_MSG.
    EXIT.
  ENDIF.

  CHECK P_BES = GC_X.

  ASSIGN COMPONENT 'JOBLS' OF STRUCTURE PT_HBXX TO FIELD-SYMBOL(<LFS_JOBLS>).
  ASSIGN COMPONENT 'WERKS' OF STRUCTURE PT_HBXX TO FIELD-SYMBOL(<LFS_WERKS>).

  PERFORM GET_CMP_DATA TABLES GT_IBES
                        USING <LFS_JOBLS>
                              <LFS_WERKS> 'X'.

  PERFORM MOD_STK_DATA USING PT_HBXX. "추가(PSJ 25.06.20)

  PERFORM REFRESH_GRID USING GR_IGRID
                             GS_ILAYO.

  GV_CNT = LINES( GT_IBES ).

  IF GV_CNT IS INITIAL.
    MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
  ELSE.
    MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_MSG.

  DATA : LS_LOG TYPE BAL_S_LOG,
         LS_MSG TYPE BAL_S_MSG,
         LS_PRF TYPE BAL_S_PROF.


  IF <GFS_MSG> IS INITIAL.
    EXIT.
  ENDIF.

  IF GS_HND IS NOT INITIAL.
    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        I_LOG_HANDLE = GS_HND
      EXCEPTIONS
        OTHERS       = 1.

    CLEAR : GS_HND.
  ENDIF.

  "Create an initial log file
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      I_S_LOG      = LS_LOG
    IMPORTING
      E_LOG_HANDLE = GS_HND
    EXCEPTIONS
      OTHERS       = 1.

  LOOP AT <GFS_MSG> INTO LS_MSG.
    "Add message to log file
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        I_LOG_HANDLE = GS_HND
        I_S_MSG      = LS_MSG
      EXCEPTIONS
        OTHERS       = 1.
  ENDLOOP.

  "Get a prepared profile
  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      E_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

  LS_PRF-USE_GRID          = GC_X.
  LS_PRF-DISVARIANT-REPORT = SY-REPID.
  LS_PRF-DISVARIANT-HANDLE = 'LOG'.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      I_S_DISPLAY_PROFILE = LS_PRF
    EXCEPTIONS
      OTHERS              = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CMP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_IBES
*&      --> <LFS_JOBLS>
*&      --> <LFS_WERKS>
*&---------------------------------------------------------------------*
FORM GET_CMP_DATA TABLES PT_CMP STRUCTURE GT_IBES
                   USING PV_JOBLS
                         PV_WERKS
                         PV_ALL.

  CLEAR : PT_CMP[], GV_CNT.

  IF PV_ALL = GC_X.
    SELECT C~MES_CMP,
           C~MATNR,
           T~MAKTX,
           C~BDMNG,
           C~MEINS,
           CASE WHEN M~SBDKZ = '1' THEN '2530' END AS UMLGO,
           A~MTART,
           C~MES_REQ,
           C~MES_SEQ
      FROM ZGTMMT6211 AS C LEFT JOIN MAKT AS T
        ON C~MATNR = T~MATNR
       AND T~SPRAS = @SY-LANGU
      LEFT JOIN MARA AS A
        ON C~MATNR = A~MATNR
      LEFT JOIN MARC AS M
        ON C~MATNR = M~MATNR
      INTO CORRESPONDING FIELDS OF TABLE @PT_CMP
     WHERE C~JOBLS = @PV_JOBLS
       AND M~WERKS = @PV_WERKS. "상위 플랜트

  ELSE.
    "하위 구성품 단위 기준 변경(PSJ 25.06.20)
    " ZGTMMT6211-MEINS -> MARA-MEINS (MES에서 잘못된 정보 전송되는 경우 발생)

    SELECT C~MES_CMP,
           C~MATNR,
           C~BDMNG,
           A~MEINS, "C~MEINS,
           CASE WHEN M~SBDKZ = '1' THEN '2530' END AS UMLGO
      FROM ZGTMMT6211 AS C LEFT JOIN MARC AS M
        ON C~MATNR = M~MATNR
      LEFT JOIN MARA AS A
        ON C~MATNR = A~MATNR
      INTO CORRESPONDING FIELDS OF TABLE @PT_CMP
     WHERE C~JOBLS = @PV_JOBLS
       AND M~WERKS = @PV_WERKS. "상위 플랜트

  ENDIF.

  CHECK PT_CMP[] IS NOT INITIAL.
  SORT PT_CMP BY MES_CMP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MOD_STK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HBXX
*&---------------------------------------------------------------------*
FORM MOD_STK_DATA USING PS_HBXX.

  DATA : BEGIN OF LS_SO,
           VBELN LIKE ZGTMMT6210-VBELN,
           VBELP LIKE ZGTMMT6210-VBELP,
         END   OF LS_SO.

  DATA : BEGIN OF LT_STK OCCURS 0,
           MATNR LIKE MSKA-MATNR,
           VBELN LIKE MSKA-VBELN,
           POSNR LIKE MSKA-POSNR,
           LABST LIKE MARD-LABST,
           MEINS LIKE MARA-MEINS,
         END   OF LT_STK.

  DATA : LV_COND TYPE STRING.


  "하위 구성품 재고수량 정보 추가(PSJ 25.06.20)

  "재고수량 추출 기준 변경(PSJ 25.06.23)
  " 구성품의 자재유형 = 'HALB': By MATNR/WERKS/VBELN/POSNR
  "                 그 외 : By MATNR/WERKS

  CHECK GT_IBES[] IS NOT INITIAL.

  MOVE-CORRESPONDING PS_HBXX TO LS_SO.

  IF LS_SO-VBELP IS INITIAL. "For CDS View 인식
    SHIFT LS_SO-VBELP LEFT DELETING LEADING '0'.
  ENDIF.

  LT_STK[] = CORRESPONDING #( GT_IBES[] ).
  DELETE LT_STK WHERE MATNR IS INITIAL.

  CHECK LT_STK[] IS NOT INITIAL.

  SORT LT_STK BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_STK COMPARING MATNR.

  SELECT MATNR, VBELN, POSNR, LABST, MEINS
    FROM ZGTMM_CV_GET_STOCKLIST
    INTO CORRESPONDING FIELDS OF TABLE @LT_STK
     FOR ALL ENTRIES IN @LT_STK
   WHERE MATNR = @LT_STK-MATNR
     AND WERKS = @P_WERKS.

  CHECK LT_STK[] IS NOT INITIAL.
  SORT LT_STK BY MATNR VBELN POSNR.

  LOOP AT GT_IBES.
    CLEAR : GT_IBES-LABST, GT_IBES-MEINS_M.

    LV_COND = | MATNR = GT_IBES-MATNR |.

    IF GT_IBES-MTART = GC_HALB.
      LV_COND = LV_COND && | AND VBELN = LS_SO-VBELN |
                        && | AND POSNR = LS_SO-VBELP |.
    ENDIF.

    LOOP AT LT_STK WHERE (LV_COND).
      GT_IBES-LABST  += LT_STK-LABST.
      GT_IBES-MEINS_M = LT_STK-MEINS.
    ENDLOOP.

    MODIFY GT_IBES TRANSPORTING LABST MEINS_M.
  ENDLOOP.

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
      GV_IDX = PS_ROW-INDEX.
      GV_FNM = PS_COL-FIELDNAME.

      CASE 'X'.
        WHEN P_BAN.
          PERFORM CLK_HOT_HDR TABLES GT_HBAN.
        WHEN P_BES.
          PERFORM CLK_HOT_HDR TABLES GT_HBES.
      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLK_HOT_HDR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_HBAN
*&---------------------------------------------------------------------*
FORM CLK_HOT_HDR TABLES PT_HBXX.

  READ TABLE PT_HBXX INDEX GV_IDX.
  CHECK SY-SUBRC = 0.

  MOVE-CORRESPONDING PT_HBXX TO GS_COM.

  ASSIGN COMPONENT GV_FNM OF STRUCTURE PT_HBXX TO FIELD-SYMBOL(<LFS_VAL>).
  CHECK <LFS_VAL> IS NOT INITIAL.

  CASE GV_FNM.
    WHEN 'INFNR' OR 'OINFR'.
      SELECT SINGLE A~INFNR INTO @DATA(LV_INFNR)
        FROM EINA AS A INNER JOIN EINE AS E
          ON A~INFNR = E~INFNR
       WHERE A~INFNR = @<LFS_VAL>
         AND A~MATNR = @GS_COM-MATNR
         AND A~LIFNR = @GS_COM-FLIEF
         AND E~EKORG = @GS_COM-EKORG
         AND E~WERKS = @GS_COM-WERKS
         AND E~ESOKZ = @GS_COM-PSTYP.

      IF SY-SUBRC <> 0.
        MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
        EXIT.
      ENDIF.

      SET PARAMETER ID 'LIF' FIELD GS_COM-FLIEF.
      SET PARAMETER ID 'MAT' FIELD GS_COM-MATNR.
      SET PARAMETER ID 'EKO' FIELD GS_COM-EKORG.
      SET PARAMETER ID 'WRK' FIELD GS_COM-WERKS.
      SET PARAMETER ID 'INF' FIELD <LFS_VAL>.
      SET PARAMETER ID 'ESO' FIELD GS_COM-PSTYP.

      CALL TRANSACTION 'ME13' AND SKIP FIRST SCREEN.

    WHEN 'BANFN'.
      SET PARAMETER ID 'BAN' FIELD <LFS_VAL>.
      CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

    WHEN 'VBELN'.
      SET PARAMETER ID 'AUN' FIELD <LFS_VAL>.
      CALL TRANSACTION 'VA03'  AND SKIP FIRST SCREEN.

    WHEN 'EBELN'.
      SET PARAMETER ID 'BES' FIELD <LFS_VAL>.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NBES_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_NBES_2 .

  CHECK GT_HBES-EBELN IS NOT INITIAL.

  DATA : LV_LIFNR LIKE EKKO-LIFNR.
  DATA : LV_NAME1 LIKE LFA1-NAME1.

  SELECT SINGLE A~LIFNR B~NAME1
    INTO (LV_LIFNR, LV_NAME1)
    FROM EKKO AS A
         INNER JOIN LFA1 AS B
          ON A~LIFNR = B~LIFNR
   WHERE A~EBELN = GT_HBES-EBELN.

  IF SY-SUBRC = 0.
    GT_HBES-FLIEF = LV_LIFNR.
    GT_HBES-FLIEF_NM = LV_NAME1.
    MODIFY GT_HBES TRANSPORTING FLIEF FLIEF_NM.
  ENDIF.

ENDFORM.
