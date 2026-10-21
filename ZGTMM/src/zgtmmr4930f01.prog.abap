*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4911F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM SET_INIT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
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
*& FORM GET_IFNO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_IFNO.

  CLEAR : GT_IFNO[].

  SELECT DISTINCT
         FLD_01 AS KEY,
         FLD_02 AS TEXT
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @GT_IFNO
   WHERE MODULE_KIND = @GC_PP
       AND CODEGRP        = @GC_0010.

  APPEND  VALUE #( KEY   = ''
                                TEXT = '전체' ) TO GT_IFNO .

  SORT GT_IFNO BY KEY.
  DELETE ADJACENT DUPLICATES FROM GT_IFNO COMPARING KEY TEXT.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.

  "회사코드 권한 체크..
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
  ID 'BUKRS' FIELD P_BUKRS.

  IF SY-SUBRC NE 0.
    "회사 코드 &에 대한 권한이 없습니다.
    MESSAGE E000 WITH '회사코드_' P_BUKRS ' 에 대한 권한이 없습니다.'.
    GV_ERR = ABAP_TRUE.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.

  CLEAR : GR_GR1[], GR_SNM[].

  CASE 'X'.
    WHEN P_ILOG.
      CLEAR : P_MIG, P_BAT, P_FNL.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_SND ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_IFDAT_LOW ) ).

    WHEN P_SEND.
      CLEAR : P_MIG,  P_FNL.
      GR_GR1[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_DIS ) ).

      GR_SNM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = GC_P_IFSYT )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_WERKS_LOW )
                          ( SIGN = GC_I OPTION = GC_EQ LOW = GC_S_ERDAT_LOW ) ).

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
*& FORM F4_IFSYT
*&---------------------------------------------------------------------*
*& TEXT
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
*& FORM CHECK_COND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CHECK_COND.

  CLEAR : GV_ERR.

  IF ( P_ILOG = GC_X AND S_IFDAT[] IS INITIAL )
    OR ( P_SEND = GC_X AND ( P_BUKRS IS INITIAL
                                     OR S_ERDAT[] IS INITIAL
                                     OR P_IFSYT   IS INITIAL ) ).
    MESSAGE S018 DISPLAY LIKE 'E'. "필수 입력 정보가 누락되었습니다.
    GV_ERR = GC_X. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA.

  CLEAR : GV_CNT, GT_IFHEAD, GT_IFITEM, GT_IFCHAR, GT_IFBOM,
               GT_SITEM, GT_SCHAR, GT_SBOM.
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_MST_INFO USING 'MM00029'.

  IF P_BAT = GC_X.
    WAIT UP TO 1 SECONDS.
  ENDIF.

  CASE 'X'.
    WHEN P_ILOG.
      PERFORM GET_ILOG_DATA.
      GV_CNT = LINES( GT_LOG ).

    WHEN P_SEND.
      PERFORM GET_SEND_DATA.
      GV_CNT = LINES( GT_PCHG ).
  ENDCASE.

  IF P_BAT IS  INITIAL.
    IF GV_CNT IS NOT INITIAL.
      MESSAGE S003 WITH GV_CNT. "& 건의 데이터가 조회되었습니다.
    ELSE.
      MESSAGE S002 DISPLAY LIKE 'E'. "조회된 값이 없습니다.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_MST_INFO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_MST_INFO USING PV_ID.

  CLEAR : GS_MST.

  SELECT SINGLE FLD_03 AS TYPE,
                FLD_04 AS PROG,
                FLD_05 AS VIEW
    FROM ZGTMM_CV_GET_IFLIST
    INTO @GS_MST
   WHERE MODULE_KIND = @GC_MM
     AND CODEGRP     = @GC_0010
     AND FLD_01      = @PV_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MAKE_ITAB
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM MAKE_ITAB.

  CLEAR    : GV_HNAME, GV_INAME, GV_TNAME, GV_FNAME.
  UNASSIGN : <GT_HLIST>, <GT_ILIST>, <GT_TLIST>, <GT_FLIST>.

  CASE 'X'.
    WHEN P_ILOG.
      GV_HNAME = GS_MST-VIEW. "ZGTMM_CV_PO_IF_LOG_L
      GV_INAME = GC_ZGTMMT9430. "구매오더 헤더
      PERFORM ASSIGN_ITAB USING 'L' GV_HNAME.
      CLEAR <GT_HLIST>.

    WHEN P_SEND.
      GV_HNAME = 'GT_PCHG'.         "구매오더 헤더
      GV_INAME = GC_ZGTMMT9431. "구매오더품목
  ENDCASE.

  GV_TNAME = GC_ZGTMMT9433.  "특성
  GV_FNAME = GC_ZGTMMT9432. "BOM

  PERFORM ASSIGN_ITAB USING 'I' GV_INAME.
  PERFORM ASSIGN_ITAB USING 'T' GV_TNAME.
  PERFORM ASSIGN_ITAB USING 'F' GV_FNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ASSIGN_ITAB
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> <GT_HLIST>
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
    WHEN 'L'.
      ASSIGN LR_DATA->* TO <GT_HLIST>.
    WHEN 'H'.
      ASSIGN LR_DATA->* TO <GT_HLIST>.
    WHEN 'I'.
      ASSIGN LR_DATA->* TO <GT_ILIST>.
    WHEN 'T'.
      ASSIGN LR_DATA->* TO <GT_TLIST>.
    WHEN 'F'.
      ASSIGN LR_DATA->* TO <GT_FLIST>.
  ENDCASE.
  FREE : LR_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_ILOG_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_ILOG_DATA.

  DATA : LV_AMT(16),
             LS_IFIT LIKE LINE OF GT_IFITEM.

  DATA : LT_OT_SPEC TYPE TABLE OF ZGTEDSIF0041.

  CLEAR : GT_LOG, GT_HEAD, GT_ITEM, GT_CHAR, GT_BOM.

*1.전송 LOG 조회
  DATA : LV_COND  TYPE STRING,
         LR_IFSYT TYPE RANGE OF ZGTPPT1010-FLD_01.

  LV_COND = | IFDAT IN @S_IFDAT AND LIFNR IN @S_LIFNR AND EBELN IN @S_EBELN |.

  IF P_IFSYT IS NOT INITIAL.
    LV_COND &&= | AND SYSTEM_ID = @P_IFSYT |.
  ENDIF.

  IF P_FNL EQ GC_X.
    LV_COND &&= | AND LASTDATA = @GC_X |.
  ENDIF.

  SELECT @ABAP_TRUE AS CHECK,
               A~*
    FROM ZGTMM_CV_SRMPO_IF_LOG_L AS A
    WHERE (LV_COND)
    INTO CORRESPONDING FIELDS OF TABLE @GT_LOG.

  CHECK GT_LOG IS NOT INITIAL.
  SORT GT_LOG BY ZIFKEY SYSTEM_ID EBELN .

*2.변경 구매오더 헤더 조회
  SELECT * FROM ZGTMMT9430
    FOR ALL ENTRIES IN @GT_LOG
    WHERE ZIFKEY = @GT_LOG-ZIFKEY
         AND EBELN = @GT_LOG-EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEAD.

  SORT GT_HEAD BY ZIFKEY EBELN.
  GT_IFHEAD[] = GT_HEAD[].

*3.변경 구매오더 품목 조회
  SELECT * FROM ZGTMMT9431
    FOR ALL ENTRIES IN @GT_LOG
    WHERE ZIFKEY = @GT_LOG-ZIFKEY
         AND EBELN = @GT_LOG-EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  SORT GT_ITEM BY  EBELN EBELP.

  LT_OT_SPEC = VALUE #( BASE LT_OT_SPEC FOR WA IN GT_ITEM
                                          WHERE ( MATNR IS NOT INITIAL )
                                          ( CORRESPONDING #( WA ) ) ).
  SORT LT_OT_SPEC BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_OT_SPEC.

  IF LT_OT_SPEC[] IS NOT INITIAL.
    CALL FUNCTION 'ZGTED_SEND_OEM_SPEC'
      TABLES
        OT_SPEC = LT_OT_SPEC.
  ENDIF.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM0>) WHERE MATNR IS NOT INITIAL.

    READ TABLE LT_OT_SPEC  INTO DATA(LS_OT_SPEC) WITH KEY MATNR = <ITEM0>-MATNR.
    IF SY-SUBRC EQ 0 AND LS_OT_SPEC-FILENAME <> ''.
      <ITEM0>-MAPKEY = LS_OT_SPEC-FILENAME.
    ELSE.
      <ITEM0>-MAPKEY = ''.
    ENDIF.
  ENDLOOP.

*  GT_IFITEM[] = CORRESPONDING #( GT_ITEM[] ).
  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
*    READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<HD>)
*    WITH KEY ZIFKEY = <ITEM>-ZIFKEY
*                   EBELN = <ITEM>-EBELN BINARY SEARCH.
*    IF SY-SUBRC = 0.
*       DATA(LV_WAERS) = <HD>-WAERS.
*       <ITEM>-WAERS = <HD>-WAERS.
**금액 통화 적용
*       LV_AMT = <ITEM>-NETPR.
*       _CURR_SAP_IDOC LV_WAERS LV_AMT.
*       <ITEM>-NETPR = LV_AMT.
*       LV_AMT = <ITEM>-NETWR.
*       _CURR_SAP_IDOC LV_WAERS LV_AMT.
*       <ITEM>-NETWR = LV_AMT.
*       LV_AMT = <ITEM>-BRTWR.
*       _CURR_SAP_IDOC LV_WAERS LV_AMT.
*       <ITEM>-BRTWR = LV_AMT.
*    ENDIF.

    LS_IFIT = CORRESPONDING #( <ITEM> ).
*    APPEND LS_IFIT TO GT_IFITEM.
    INSERT LS_IFIT INTO TABLE GT_IFITEM.
  ENDLOOP.

*4.변경 구매오더 특성 조회
  SELECT * FROM ZGTMMT9433
    FOR ALL ENTRIES IN @GT_LOG
    WHERE ZIFKEY = @GT_LOG-ZIFKEY
         AND EBELN = @GT_LOG-EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_CHAR.

  SORT GT_CHAR BY ZIFKEY EBELN EBELP ATNAM.
  GT_IFCHAR[] = CORRESPONDING #( GT_CHAR[] ).

*5.변경 구매오더 BOM 조회
  SELECT * FROM ZGTMMT9432
    FOR ALL ENTRIES IN @GT_LOG
    WHERE ZIFKEY = @GT_LOG-ZIFKEY
         AND EBELN = @GT_LOG-EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_BOM.

  SORT GT_BOM BY ZIFKEY EBELN EBELP IDNRK.
  GT_IFBOM[] = CORRESPONDING #( GT_BOM[] ).


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_SEND_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_SEND_DATA.

  DATA : LV_WAERS(5), LV_AMT(16).
  DATA : LT_OT_SPEC TYPE TABLE OF ZGTEDSIF0041.
  DATA : LT_SO     TYPE TABLE OF ZGTMMS1020,
*              LT_BRGEW TYPE TABLE OF ZGTMMS1021.
         LT_OUTPUT TYPE TABLE OF ZGTEDSIF0034.  "ED 드럼 FM 데이터

  CLEAR : GT_PCHG[], GT_ITEM[], GT_CHAR[], GT_BOM[].
  CLEAR : GS_PCHG, GS_ITEM.

  IF P_MIG = GC_X. "재전송
    SELECT @ABAP_TRUE AS CHECK,
                 A~*
    FROM ZGTMM_CV_GET_PODATA_H AS A
    INNER JOIN ZGTMM_CV_SRMPO_IF_LOG_L AS B
        ON A~EBELN = B~EBELN
       AND A~CHANGENR = B~CHANGENR
    WHERE A~BUKRS = @P_BUKRS
         AND A~LIFNR IN @S_LIFNR
         AND A~EBELN IN @S_EBELN
         AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH
         AND B~ZSTAT NE @GC_S
    INTO CORRESPONDING FIELDS OF TABLE @GT_PCHG.

  ELSE.
*    SELECT @ABAP_TRUE AS CHECK,
*                 A~*
*    FROM ZGTMM_CV_GET_PODATA_H AS A
*    WHERE A~BUKRS = @P_BUKRS
*         AND A~LIFNR IN @S_LIFNR
*         AND A~EBELN IN @S_EBELN
*         AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH
*         AND A~CHANGENR = ( SELECT MAX( CHANGENR )
*                         FROM ZGTMM_CV_GET_PODATA_H
*                        WHERE EBELN = A~ebeln
*                         AND A~BUKRS = @P_BUKRS
*                         AND A~LIFNR IN @S_LIFNR
*                        AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH )
*    INTO CORRESPONDING FIELDS OF TABLE @GT_PCHG.
    SELECT @ABAP_TRUE AS CHECK,
                 A~*
    FROM ZGTMM_CV_GET_PODATA_H AS A
    WHERE A~BUKRS = @P_BUKRS
         AND A~LIFNR IN @S_LIFNR
         AND A~EBELN IN @S_EBELN
         AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH
         AND A~TIMESTAMP = ( SELECT MAX( TIMESTAMP )
                         FROM ZGTMM_CV_GET_PODATA_H
                        WHERE EBELN = A~EBELN
                         AND A~BUKRS = @P_BUKRS
                         AND A~LIFNR IN @S_LIFNR
                        AND A~UDATE BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH )
    INTO CORRESPONDING FIELDS OF TABLE @GT_PCHG.
  ENDIF.

  IF P_MIG IS INITIAL.
    PERFORM EXCEPT_SEND_DATA .
  ENDIF.

  CHECK GT_PCHG[] IS NOT INITIAL.

  SORT GT_PCHG BY EBELN.
  DELETE ADJACENT DUPLICATES FROM GT_PCHG COMPARING EBELN.

  CHECK GT_PCHG[] IS NOT INITIAL.
  SELECT *
    FROM ZGTMM_CV_GET_PODATA_I
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM
    FOR ALL ENTRIES IN @GT_PCHG
    WHERE EBELN = @GT_PCHG-EBELN.

  SORT GT_ITEM BY EBELN EBELP.
  CHECK GT_ITEM[] IS NOT INITIAL.

*SPEC CODE
  LT_OT_SPEC = VALUE #( BASE LT_OT_SPEC FOR WA IN GT_ITEM
                                          WHERE ( MATNR IS NOT INITIAL )
                                          ( CORRESPONDING #( WA ) ) ).

  SORT LT_OT_SPEC BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_OT_SPEC.

  IF LT_OT_SPEC[] IS NOT INITIAL.
    CALL FUNCTION 'ZGTED_SEND_OEM_SPEC'
      TABLES
        OT_SPEC = LT_OT_SPEC.
  ENDIF.

*판매오더 기준 총 중량 데이터 가져오기
  LT_SO = VALUE #( BASE LT_SO FOR WA2 IN GT_ITEM
                                                   WHERE ( VBELN IS NOT INITIAL )
                             ( CORRESPONDING #( WA2 ) ) ).
*  CALL FUNCTION 'ZGTMM_SELECT_SO_BRGEW'
*    TABLES
*      IT_SO          = LT_SO
*      OT_BRGEW  = LT_BRGEW
*            .
*  SORT LT_BRGEW BY VBELN POSNR.

  LT_OUTPUT = CORRESPONDING #( LT_SO ).

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      OT_OUTPUT = LT_OUTPUT.               " [GT] 가온전선 용적계산 결과값 Return 구조체
  .
  SORT LT_OUTPUT BY VBELN POSNR.

*구매오더 기준 특성정보 조회.
  SELECT * FROM ZGTMM_CV_PO_VCVALUE_MAIN2
    FOR ALL ENTRIES IN @GT_ITEM
    WHERE PDOC = @GT_ITEM-EBELN
    INTO TABLE @DATA(LT_VC).
  SORT LT_VC BY PDOC PDOCITEM.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM0>) WHERE MATNR IS NOT INITIAL.

    READ TABLE LT_OT_SPEC  INTO DATA(LS_OT_SPEC) WITH KEY MATNR = <ITEM0>-MATNR.
    IF SY-SUBRC EQ 0 AND LS_OT_SPEC-FILENAME <> ''.
      <ITEM0>-MAPKEY = LS_OT_SPEC-FILENAME.
    ELSE.
      <ITEM0>-MAPKEY = ''.
    ENDIF.

*판매오더 존재하는 구매오더의 총중량 재계산 로직 추가
    IF <ITEM0>-VBELN IS NOT INITIAL.
**1)판매오더&품목과 일치하는 총 중량 데이터 찾아오기.
*      READ TABLE LT_BRGEW ASSIGNING FIELD-SYMBOL(<BR>)
*      WITH KEY VBELN = <ITEM0>-VBELN
*                      POSNR = <ITEM0>-POSNR BINARY SEARCH.
*      IF SY-SUBRC = 0.
**2)구매오더 기준 특성정보의 '드럼 수'와 판매오더 기준 '총중량'으로 재계산
*        READ TABLE LT_VC ASSIGNING FIELD-SYMBOL(<VC>)
*        WITH KEY PDOC = <ITEM0>-EBELN
*                       PDOCITEM = <ITEM0>-EBELP BINARY SEARCH.
*        IF SY-SUBRC = 0 AND <BR>-BRGEW > 0.
*          <ITEM0>-BRGEW = <VC>-DRQTY * <BR>-BRGEW.
*        ENDIF.
*      ENDIF.

      "1) 판매오더&품목과 일치하는 드럼 1개 중량 데이터 찾아오기.
      READ TABLE LT_OUTPUT ASSIGNING FIELD-SYMBOL(<LS_OUTPUT>)
      WITH KEY VBELN = <ITEM0>-VBELN
                      POSNR = <ITEM0>-POSNR BINARY SEARCH.

      "2) 총중량 = 기존 총중량 + 드럼 1개 중량 * 드럼 수 (드럼 없는 경우에는 0으로 더함)
      IF SY-SUBRC = 0.
        READ TABLE LT_VC ASSIGNING FIELD-SYMBOL(<VC>)
        WITH KEY PDOC = <ITEM0>-EBELN
                       PDOCITEM = <ITEM0>-EBELP BINARY SEARCH.
        IF SY-SUBRC = 0 .
          <ITEM0>-BRGEW = <ITEM0>-BRGEW + <VC>-DRQTY * <LS_OUTPUT>-BRGEW.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.


*특성
  SELECT *
    FROM ZGTMM_CV_GET_PODATA_C
    FOR ALL ENTRIES IN @GT_ITEM
    WHERE EBELN = @GT_ITEM-EBELN
         AND EBELP = @GT_ITEM-EBELP
    INTO CORRESPONDING FIELDS OF TABLE @GT_CHAR.

  DATA :
    LS_CHAR LIKE GS_CHAR,
    LV_NAME LIKE THEAD-TDNAME.
*판매오더 기준의 특성값 있는 경우 추가..
  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>) WHERE VBELN IS NOT INITIAL.
    CLEAR : LS_CHAR, LV_NAME.
    LS_CHAR = CORRESPONDING #( <ITEM> ).

    LV_NAME = <ITEM>-VBELN.
    PERFORM SET_TEXT_VBELN USING 'H' '0001' LV_NAME 'VBBK' LS_CHAR.

    LV_NAME &&= <ITEM>-POSNR.
    PERFORM SET_TEXT_VBELN USING 'I' '0001' LV_NAME 'VBBP' LS_CHAR.
    PERFORM SET_TEXT_VBELN USING 'Q' 'ZG01' LV_NAME 'VBBP' LS_CHAR.
  ENDLOOP.

  SORT GT_CHAR BY EBELN EBELP ATNAM.
  DELETE ADJACENT DUPLICATES FROM GT_CHAR COMPARING EBELN EBELP ATNAM.

*BOM
  SELECT EBELN, EBELP, IDNRK, ERFMG, ERFME, POSTP
    FROM  ZGTMM_CV_GET_RESB_SC_MAT
    FOR ALL ENTRIES IN @GT_ITEM
    WHERE EBELN = @GT_ITEM-EBELN
         AND EBELP = @GT_ITEM-EBELP
    INTO CORRESPONDING FIELDS OF TABLE @GT_BOM.

  SORT GT_BOM BY EBELN EBELP IDNRK.

  GT_SITEM[] = CORRESPONDING #( GT_ITEM[] ).
  GT_SCHAR[] = CORRESPONDING #( GT_CHAR[] ).
  GT_SBOM[] = CORRESPONDING #( GT_BOM[] ).

  DATA LT_KEY TYPE TABLE OF ZGTMMT9431 WITH EMPTY KEY
           WITH NON-UNIQUE SORTED KEY F_KEY COMPONENTS EBELN.
  LT_KEY[] = GT_ITEM[].

  LOOP AT GT_PCHG INTO GS_PCHG.

    LV_WAERS = GS_PCHG-WAERS.

    AT NEW EBELN.
      PERFORM SET_TEXT USING 'H'.
      MODIFY GT_PCHG FROM GS_PCHG TRANSPORTING MEMO_H.

*구매오더 기준의 품목 정보 그룹핑
      CLEAR GT_TITM[].
      GT_TITM[] = CORRESPONDING #( FILTER #( LT_KEY USING KEY F_KEY
                                                         WHERE  EBELN = GS_PCHG-EBELN ) ).
*구매오더+품목 기준의 메모 정보 가져오기
      LOOP AT GT_TITM INTO GS_ITEM.
        PERFORM SET_TEXT USING 'I'.

        READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>)
        WITH KEY EBELN = GS_ITEM-EBELN
                       EBELP = GS_ITEM-EBELP BINARY SEARCH.

        IF SY-SUBRC = 0.
          <FS>-MEMO_I = GS_ITEM-MEMO_I.
**금액 통화 적용
*           LV_AMT = <FS>-NETPR.
*           _CURR_SAP_IDOC LV_WAERS LV_AMT.
*           <FS>-NETPR = LV_AMT.
*           LV_AMT = <FS>-NETWR.
*           _CURR_SAP_IDOC LV_WAERS LV_AMT.
*           <FS>-NETWR = LV_AMT.
*           LV_AMT = <FS>-BRTWR.
*           _CURR_SAP_IDOC LV_WAERS LV_AMT.
*           <FS>-BRTWR = LV_AMT.
        ENDIF.

        CLEAR GS_ITEM.
      ENDLOOP.
    ENDAT.

    CLEAR : GS_PCHG.", LV_WAERS, LV_AMT.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCEPT_SEND_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM EXCEPT_SEND_DATA .

  DATA : LT_PCHG LIKE TABLE OF GS_PCHG .

  LT_PCHG[] = GT_PCHG[].
  SORT LT_PCHG BY CHANGENR EBELN.
  DELETE ADJACENT DUPLICATES FROM LT_PCHG COMPARING CHANGENR EBELN.

  SELECT *
    FROM ZGTMM_CV_SRMPO_IF_LOG_L
    INTO TABLE @DATA(LT_LOG)
     FOR ALL ENTRIES IN @LT_PCHG
   WHERE CHANGENR = @LT_PCHG-CHANGENR
        AND EBELN        = @LT_PCHG-EBELN
        AND LASTDATA = @GC_X
        AND SYSTEM_ID = @P_IFSYT.

  IF LT_LOG[] IS NOT INITIAL.
    SORT LT_LOG BY  CHANGENR EBELN.
    SORT GT_PCHG BY CHANGENR EBELN DESCENDING.

*P_MIG(재전송)IS INITIAL->최종 전송 성공한 데이터는 전송 대상에서 제외
    LOOP AT GT_PCHG ASSIGNING <GS_LIST>.
      DATA(LV_TABIX) = SY-TABIX.

      READ TABLE LT_LOG ASSIGNING FIELD-SYMBOL(<LOG>)
      WITH  KEY CHANGENR = <GS_LIST>-('CHANGENR')
                      EBELN = <GS_LIST>-('EBELN') BINARY SEARCH.

      IF  SY-SUBRC = 0 AND <LOG>-ZSTAT = GC_S. "최종전송 성공
        DELETE GT_PCHG INDEX LV_TABIX.
      ENDIF.

      IF <LOG> IS ASSIGNED.
        UNASSIGN <LOG>.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_TEXT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_TEXT USING PV_GB .

  DATA :
    LV_NAME LIKE THEAD-TDNAME,
    LV_OBJ  LIKE THEAD-TDOBJECT,
    LT_LINE LIKE TLINE OCCURS 0 WITH HEADER LINE.

  LV_NAME = COND #( WHEN PV_GB = GC_H THEN GS_PCHG-EBELN
                                  ELSE |{ GS_ITEM-EBELN }{ GS_ITEM-EBELP }| ).
  LV_OBJ = COND #( WHEN PV_GB = GC_H THEN 'EKKO'
                               ELSE 'EKPO').

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = 'F01'
      LANGUAGE                = GC_3
      NAME                    = LV_NAME
      OBJECT                  = LV_OBJ
    TABLES
      LINES                   = LT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  CHECK SY-SUBRC = 0.

  LOOP AT LT_LINE.
    IF PV_GB = GC_H.
      GS_PCHG-MEMO_H &&= GS_PCHG-MEMO_H && ' ' && LT_LINE-TDLINE.
    ELSE.
      GS_ITEM-MEMO_I &&= GS_ITEM-MEMO_I && ' ' && LT_LINE-TDLINE.
    ENDIF.
*    CONCATENATE GS_ITEM-MEMO_I LT_LINE-TDLINE
*           INTO GS_SITM-ZTEXT SEPARATED BY SPACE.
  ENDLOOP.

*  CONDENSE GS_ITEM-MEMO_I.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_TEXT_VBELN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_TEXT_VBELN USING PV_GB PV_ID PV_NAME PV_OBJ
                                CHANGING PS_CHAR STRUCTURE GS_CHAR.

  DATA :  LT_LINE   LIKE TLINE OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = PV_ID
      LANGUAGE                = GC_3
      NAME                    = PV_NAME
      OBJECT                  = PV_OBJ
    TABLES
      LINES                   = LT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  IF LT_LINE[] IS NOT INITIAL.
    CASE PV_GB.
      WHEN GC_H.
        PS_CHAR-ATNAM &&= TEXT-M04. "PC_SPECIAL_TEXTH
        PS_CHAR-ATBEZ &&= TEXT-M07.  "특기사항(공통)

        LOOP AT LT_LINE.
          PS_CHAR-ATWRT &&= LT_LINE-TDLINE.
        ENDLOOP.
        APPEND PS_CHAR TO GT_CHAR.

      WHEN GC_I.
        CLEAR : PS_CHAR-ATNAM, PS_CHAR-ATBEZ, PS_CHAR-ATWRT.
        PS_CHAR-ATNAM &&= TEXT-M05. "PC_SPECIAL_TEXT
        PS_CHAR-ATBEZ &&= TEXT-M08.  "특기사항(품목)

        LOOP AT LT_LINE.
          PS_CHAR-ATWRT &&= LT_LINE-TDLINE.
        ENDLOOP.
        APPEND PS_CHAR TO GT_CHAR.

      WHEN OTHERS.
        CLEAR : PS_CHAR-ATNAM, PS_CHAR-ATBEZ, PS_CHAR-ATWRT.
        PS_CHAR-ATNAM &&= TEXT-M06. "PC_QC_SPECIAL_TEXT
        PS_CHAR-ATBEZ &&= TEXT-M09.  "QC 요청사항

        LOOP AT LT_LINE.
          PS_CHAR-ATWRT &&= LT_LINE-TDLINE.
        ENDLOOP.
        APPEND PS_CHAR TO GT_CHAR.

    ENDCASE.


*    LOOP AT LT_LINE.
*      CASE PV_GB.
*        WHEN GC_H.
*          PS_CHAR-ATNAM &&= TEXT-M04. "PC_SPECIAL_TEXTH
*          PS_CHAR-ATBEZ &&= TEXT-M07.  "특기사항(공통)
*          PS_CHAR-ATWRT &&= LT_LINE-TDLINE.
*
*        WHEN GC_I.
*          PS_CHAR-ATNAM &&= TEXT-M05. "PC_SPECIAL_TEXT
*          PS_CHAR-ATBEZ &&= TEXT-M08.  "특기사항(품목)
*          PS_CHAR-ATWRT &&= ' ' && LT_LINE-TDLINE.
*
*        WHEN OTHERS.
*          PS_CHAR-ATNAM &&= TEXT-M06. "PC_QC_SPECIAL_TEXT
*          PS_CHAR-ATBEZ &&= TEXT-M09.  "QC 요청사항
*          PS_CHAR-ATWRT &&= ' ' && LT_LINE-TDLINE.
*      ENDCASE.
*
*      APPEND PS_CHAR TO GT_CHAR.
*    ENDLOOP.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SEND_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_DATA USING PV_CHK.

  DATA : LV_DEST LIKE ZIFDEST-DEST,
         LV_RST  TYPE ZO_RESULT,
         LV_MSG  TYPE ZO_MESSAGE,
         LV_RET  TYPE ZIFE_IFRET.
  DATA : LT_LOG  LIKE TABLE OF GS_LOG,
         LT_PCHG LIKE TABLE OF GS_PCHG.
  DATA : LT_HEAD LIKE TABLE OF ZGTMMT9430,
         LS_HEAD TYPE  ZGTMMT9430,
         LT_ITEM LIKE TABLE OF ZGTMMT9431,
         LT_CHAR LIKE TABLE OF ZGTMMT9433,
*  DATA : LT_HEAD LIKE TABLE OF ZGTMMS1003,
*             LT_ITEM LIKE TABLE OF ZGTMMS1004,
*             LT_CHAR LIKE TABLE OF ZGTMMS1006,
         LT_BOM  LIKE TABLE OF ZGTMMT9432. "ZGTMMS1005.

  CLEAR : GT_FHEAD[], GT_FITEM[], GT_FCHAR[], GT_FBOM[], LT_HEAD.
  CLEAR : GV_CNT,  GV_MSG.

  IF PV_CHK = GC_X.
*전송 용 HEADER 구성
    CASE GC_X.
      WHEN P_ILOG.
        LT_LOG[] = GT_LOG[].
        DELETE LT_LOG WHERE CHECK IS INITIAL.

        IF LINE_EXISTS( LT_LOG[ LASTDATA = SPACE ] ).
          MESSAGE S049 DISPLAY LIKE 'E'. "최종이 아닌 데이터는 전송할 수 없습니다.
          GV_ERR = GC_X. EXIT.
        ENDIF.
        LT_HEAD[] = VALUE #( FOR LS_HD IN LT_LOG
                          ( VALUE #( BASE CORRESPONDING #( LS_HD )
                                  EBELN = |{ LS_HD-EBELN ALPHA = OUT }|
                                  LIFNR  = |{ LS_HD-LIFNR ALPHA = OUT }| ) ) ).
      WHEN P_SEND.
        LT_PCHG[] = GT_PCHG[].
        DELETE LT_PCHG WHERE CHECK IS INITIAL.
        LT_HEAD[] = VALUE #( FOR LS_CH IN LT_PCHG
                          ( VALUE #( BASE CORRESPONDING #( LS_CH )
                                  EBELN = |{ LS_CH-EBELN ALPHA = OUT }|
                                  LIFNR  = |{ LS_CH-LIFNR ALPHA = OUT }| ) ) ).
      WHEN OTHERS.
    ENDCASE.

    IF LT_HEAD[] IS INITIAL."<GT_HLIST>[] IS INITIAL.
      MESSAGE S146 WITH TEXT-B02 DISPLAY LIKE 'E'.
      GV_ERR = GC_X. "전송 할 레코드를 선택하세요.
    ELSE.
      GT_FHEAD[] = CORRESPONDING #( LT_HEAD[] ).
    ENDIF.

    PERFORM SEND_SEL_DATA TABLES LT_ITEM LT_CHAR LT_BOM.
    CHECK GV_ERR IS INITIAL.

  ELSE.
    CHECK P_BAT = GC_X.
    CLEAR : GT_FHEAD, GT_FHEAD[].

    LOOP AT GT_PCHG ASSIGNING FIELD-SYMBOL(<FS>).
      GT_FHEAD = CORRESPONDING #( <FS> ).
      GT_FHEAD-EBELN = |{ GT_FHEAD-EBELN ALPHA = OUT }|.
      GT_FHEAD-LIFNR  = |{ GT_FHEAD-LIFNR ALPHA = OUT }|.
      APPEND GT_FHEAD. CLEAR GT_FHEAD.

      LS_HEAD   = CORRESPONDING #( <FS> ).
      APPEND LS_HEAD TO LT_HEAD. CLEAR LS_HEAD.
    ENDLOOP.

    PERFORM SEND_BAT_DATA TABLES LT_ITEM LT_CHAR LT_BOM.

  ENDIF.

  IF P_IFSYT IS INITIAL AND P_BAT IS INITIAL.
    MESSAGE S015 WITH 'I/F 시스템'(M01) DISPLAY LIKE 'E'. "&를(을) 입력하세요.
    EXIT.
  ENDIF.

  IF PV_CHK = GC_X.
    CHECK GV_ANS = GC_1.
  ENDIF.

*전송 RFC 호출
*DESTINATION
  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      I_ZIFNO = GC_MM00029
    IMPORTING
      E_ZDEST = LV_DEST.
  IF LV_DEST IS INITIAL.
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        GUBUN                 = 'IS'
      IMPORTING
        DEST_NAME             = LV_DEST
      EXCEPTIONS
        DESTINATION_NOT_FOUND = 1
        OTHERS                = 2.
  ENDIF.

*PO/SO 전송 펑션
  TRY.
      CALL FUNCTION 'ZGTMM_IF_O_PO_SRM'
        DESTINATION LV_DEST
        EXPORTING
          I_SYSTEM_ID           = P_IFSYT
          I_BUKRS               = P_BUKRS
        IMPORTING
          ZO_RESULT             = LV_RST
          ZO_MESSAGE            = LV_MSG
        TABLES
          OT_EKKO               = GT_FHEAD
          OT_EKPO               = GT_FITEM
          OT_BOM                = GT_FBOM
          OT_CHAR               = GT_FCHAR
        EXCEPTIONS
          SYSTEM_FAILURE        = 1 MESSAGE LV_MSG
          COMMUNICATION_FAILURE = 2 MESSAGE LV_MSG
          OTHERS                = 3.
      .
    CATCH CX_ROOT INTO DATA(LV_ERR).
      LV_MSG = LV_ERR->GET_TEXT(  ).
      MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDTRY.

  IF SY-SUBRC <> 0.
    LV_RST = GC_02.
  ENDIF.

  CASE LV_RST.
    WHEN '00' OR '0'.
      LV_RET = GC_S.
      GV_CNT = LINES( LT_HEAD[] ).
      GV_MSG = GV_CNT && '건 전송 성공'(M02).

    WHEN OTHERS.
      LV_RET = GC_E.
      GV_MSG = '전송 실패'(M03).
  ENDCASE.

*LOG
  PERFORM SAVE_LOG TABLES LT_HEAD LT_ITEM LT_CHAR LT_BOM
  USING LV_RET LV_MSG.

*  IF P_BAT IS INITIAL.
  MESSAGE S000 DISPLAY LIKE LV_RET WITH GV_MSG.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
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
*& FORM POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& TEXT
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
*     TEXT_BUTTON_1 = 'JA'(001)
*     ICON_BUTTON_1 = ' '
*     TEXT_BUTTON_2 = 'NEIN'(002)
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
*& FORM SEND_SEL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SEND_SEL_DATA TABLES PT_ITEM PT_CHAR PT_BOM .

  DATA : LT_LOG  LIKE TABLE OF GS_LOG,
         LT_PCHG LIKE TABLE OF GS_PCHG.

  DEFINE _BAPI_CURR.
    CLEAR:
         LV_AMT_EXT,
         LV_AMT_INT.

    LV_AMT_INT = &2.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        CURRENCY                 = &1
        AMOUNT_INTERNAL    = LV_AMT_INT
     IMPORTING
       AMOUNT_EXTERNAL    = LV_AMT_EXT
              .
     &2 = LV_AMT_EXT.
  END-OF-DEFINITION.

  DATA :
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT TYPE MATDOC-DMBTR.

  CHECK GV_ERR IS INITIAL.
  PERFORM POPUP_TO_CONFIRM USING '확인'(P01)
                          'DATA를 전송 하시겠습니까?'(P02).
  CHECK GV_ANS = GC_1.

*전송 용 ITEM TABLE 구성
  CLEAR : GS_ITEM, GS_CHAR.

  LOOP AT GT_ITEM INTO GS_ITEM.
    GS_ITEM-EBELN = |{ GS_ITEM-EBELN ALPHA = OUT }|.
    GS_ITEM-KUNNR = |{ GS_ITEM-KUNNR ALPHA = OUT }|.
    GS_ITEM-VBELN = |{ GS_ITEM-VBELN ALPHA = OUT }|.

    PERFORM CONVERT_MATN1_OUTPUT USING GS_ITEM-MATNR.
    SHIFT GS_ITEM-EBELP LEFT DELETING LEADING '0'.

    IF GS_ITEM-BANFN IS INITIAL.
      CLEAR GS_ITEM-BNFPO.
    ELSE.
      SHIFT GS_ITEM-BNFPO LEFT DELETING LEADING '0'.
    ENDIF.

    IF GS_ITEM-VBELN IS INITIAL.
      CLEAR GS_ITEM-POSNR.
    ELSE.
      SHIFT GS_ITEM-POSNR LEFT DELETING LEADING '0'.
    ENDIF.

    IF GS_ITEM-EMLIF IS INITIAL.
      CLEAR GS_ITEM-NAME_V.
    ELSE.
      SHIFT GS_ITEM-EMLIF LEFT DELETING LEADING '0'.
    ENDIF.

*금액변환
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-NETPR.
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-NETWR.
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-BRTWR.

    APPEND GS_ITEM TO PT_ITEM.
  ENDLOOP.

  LOOP AT GT_CHAR INTO GS_CHAR.
    GS_CHAR-EBELN = |{ GS_CHAR-EBELN ALPHA = OUT }|.
    SHIFT GS_CHAR-EBELP LEFT DELETING LEADING '0'.

    APPEND GS_CHAR TO PT_CHAR.
  ENDLOOP.

  LOOP AT GT_BOM INTO GS_BOM.
    GS_BOM-EBELN = |{ GS_BOM-EBELN ALPHA = OUT }|.
    SHIFT GS_BOM-EBELP LEFT DELETING LEADING '0'.

    PERFORM CONVERT_MATN1_OUTPUT USING GS_BOM-IDNRK.
    APPEND GS_BOM TO PT_BOM.
  ENDLOOP.

  GT_FITEM[] = CORRESPONDING #( PT_ITEM[] ).
  GT_FCHAR[] = CORRESPONDING #( PT_CHAR[] ).
  GT_FBOM[] = CORRESPONDING #( PT_BOM[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM APPEND_LIST
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_F002
*&      --> <GS_LIST>
*&---------------------------------------------------------------------*
FORM APPEND_LIST TABLES PT_ITAB
                  USING PS_LIST.

  CLEAR : PT_ITAB.

  PT_ITAB = CORRESPONDING #( PS_LIST ).
  APPEND PT_ITAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SEND_BAT_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SEND_BAT_DATA TABLES PT_ITEM PT_CHAR PT_BOM.

  DATA :
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT TYPE MATDOC-DMBTR.

  DEFINE _BAPI_CURR.
    CLEAR:
         LV_AMT_EXT,
         LV_AMT_INT.

    LV_AMT_INT = &2.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        CURRENCY                 = &1
        AMOUNT_INTERNAL    = LV_AMT_INT
     IMPORTING
       AMOUNT_EXTERNAL    = LV_AMT_EXT
              .
     &2 = LV_AMT_EXT.
  END-OF-DEFINITION.

*전송 용 ITEM TABLE 구성
  CLEAR : GS_ITEM, GS_CHAR, GS_BOM.

  CLEAR GT_FITEM.
  LOOP AT GT_ITEM INTO GS_ITEM.
    GS_ITEM-EBELN = |{ GS_ITEM-EBELN ALPHA = OUT }|.
    GS_ITEM-KUNNR = |{ GS_ITEM-KUNNR ALPHA = OUT }|.
    GS_ITEM-VBELN = |{ GS_ITEM-VBELN ALPHA = OUT }|.

    PERFORM CONVERT_MATN1_OUTPUT USING GS_ITEM-MATNR.
    SHIFT GS_ITEM-EBELP LEFT DELETING LEADING '0'.

    IF GS_ITEM-BANFN IS INITIAL.
      CLEAR GS_ITEM-BNFPO.
    ELSE.
      SHIFT GS_ITEM-BNFPO LEFT DELETING LEADING '0'.
    ENDIF.

    IF GS_ITEM-VBELN IS INITIAL.
      CLEAR GS_ITEM-POSNR.
    ELSE.
      SHIFT GS_ITEM-POSNR LEFT DELETING LEADING '0'.
    ENDIF.

    IF GS_ITEM-EMLIF IS INITIAL.
      CLEAR GS_ITEM-NAME_V.
    ELSE.
      SHIFT GS_ITEM-EMLIF LEFT DELETING LEADING '0'.
    ENDIF.

*금액변환
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-NETPR.
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-NETWR.
    _BAPI_CURR GS_ITEM-WAERS GS_ITEM-BRTWR.

    PT_ITEM = CORRESPONDING #( GS_ITEM ).
    APPEND PT_ITEM. CLEAR GS_ITEM.
  ENDLOOP.

  CLEAR GT_FCHAR.
  LOOP AT GT_CHAR INTO GS_CHAR.
    GS_CHAR-EBELN = |{ GS_CHAR-EBELN ALPHA = OUT }|.
    SHIFT GS_CHAR-EBELP LEFT DELETING LEADING '0'.

    PT_CHAR = CORRESPONDING #( GS_CHAR ).
    APPEND PT_CHAR.  CLEAR GS_CHAR.
  ENDLOOP.

  CLEAR GT_FBOM.
  LOOP AT GT_BOM INTO GS_BOM.
    GS_BOM-EBELN = |{ GS_BOM-EBELN ALPHA = OUT }|.
    SHIFT GS_BOM-EBELP LEFT DELETING LEADING '0'.

    PERFORM CONVERT_MATN1_OUTPUT USING GS_BOM-IDNRK.

    PT_BOM = CORRESPONDING #( GS_BOM ).
    APPEND PT_BOM. CLEAR GS_BOM.
  ENDLOOP.

  GT_FITEM[] = CORRESPONDING #( PT_ITEM[] ).
  GT_FCHAR[] = CORRESPONDING #( PT_CHAR[] ).
  GT_FBOM[] = CORRESPONDING #( PT_BOM[] ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MODIFY_F00X_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM MODIFY_F00X_DATA.

*  GT_FHEAD[] = VALUE #( FOR LS_HEAD IN GT_FHEAD
*                       ( VALUE #( BASE CORRESPONDING #( LS_HEAD )
*                                  EBELN = |{ LS_HEAD-EBELN ALPHA = OUT }|
*                                  LIFNR  = |{ LS_HEAD-LIFNR ALPHA = OUT }| ) ) ).

  LOOP AT GT_FHEAD.
    GT_FHEAD-EBELN = |{ GT_FHEAD-EBELN ALPHA = OUT }|.
    GT_FHEAD-LIFNR  = |{ GT_FHEAD-LIFNR ALPHA = OUT }|.
    MODIFY GT_FHEAD TRANSPORTING EBELN LIFNR.
  ENDLOOP.

  LOOP AT GT_FITEM.
    GT_FITEM-EBELN = |{ GT_FITEM-EBELN ALPHA = OUT }|.
*    GT_FITEM-LIFNR = |{ GT_FITEM-LIFNR ALPHA = OUT }|.
    GT_FITEM-KUNNR = |{ GT_FITEM-KUNNR ALPHA = OUT }|.
    GT_FITEM-VBELN = |{ GT_FITEM-VBELN ALPHA = OUT }|.
    PERFORM CONVERT_MATN1_OUTPUT USING GT_FITEM-MATNR.

    SHIFT GT_FITEM-EBELP LEFT DELETING LEADING '0'.
*    SHIFT GT_FITEM-VBELP LEFT DELETING LEADING '0'.

    MODIFY GT_FITEM TRANSPORTING EBELN KUNNR VBELN MATNR EBELP.
  ENDLOOP.

  LOOP AT GT_FCHAR.
    GT_FCHAR-EBELN = |{ GT_FCHAR-EBELN ALPHA = OUT }|.
*    GT_FCHAR-LIFNR = |{ GT_FCHAR-LIFNR ALPHA = OUT }|.
*    PERFORM CONVERT_MATN1_OUTPUT USING GT_FCHAR-MATNR.

    SHIFT GT_FCHAR-EBELP LEFT DELETING LEADING '0'.

    MODIFY GT_FCHAR TRANSPORTING EBELN EBELP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CONVERT_MATN1_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
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
*& FORM SAVE_LOG
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM SAVE_LOG TABLES PT_HEAD PT_ITEM PT_CHAR PT_BOM
                              USING PV_RET PV_MSG.

  DATA : LV_AMT TYPE WMTO_S-AMOUNT.

  CLEAR : GS_9000, GT_9430[], GT_9431[], GT_9432[], GT_9433[].

  GET TIME STAMP FIELD GS_9000-ZIFKEY.
  GS_9000-ZIFNO       = GC_MM00029.
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

  IF PT_HEAD[] IS NOT INITIAL.
*  IF GT_FHEAD[] IS INITIAL.
    LOOP AT PT_HEAD INTO GT_9430.
      GT_9430-ZIFKEY  = GS_9000-ZIFKEY.
      APPEND GT_9430. CLEAR GT_9430.
    ENDLOOP.
*  ELSE.
*    GT_9430[] = VALUE #( FOR LS_HDR IN GT_FHEAD
*                     ( VALUE #( BASE CORRESPONDING #( LS_HDR )
*                                      ZIFKEY  = GS_9000-ZIFKEY ) ) ).
  ENDIF.

  IF GT_FITEM[] IS INITIAL.
    LOOP AT PT_ITEM INTO GT_9431.
      CLEAR : LV_AMT.
      LV_AMT = GT_9431-NETPR.
      _CURR_DISPLAY_TO_SAP GT_9431-WAERS LV_AMT.
      GT_9431-NETPR = LV_AMT.

      LV_AMT = GT_9431-NETWR.
      _CURR_DISPLAY_TO_SAP GT_9431-WAERS LV_AMT.
      GT_9431-NETWR = LV_AMT.

      LV_AMT = GT_9431-BRTWR.
      _CURR_DISPLAY_TO_SAP GT_9431-WAERS LV_AMT.
      GT_9431-BRTWR = LV_AMT.


      GT_9431-ZIFKEY  = GS_9000-ZIFKEY.

      APPEND GT_9431. CLEAR GT_9431.
    ENDLOOP.
  ELSE.
    GT_9431[] = VALUE #( FOR LS_IT IN GT_FITEM
                     ( VALUE #( BASE CORRESPONDING #( LS_IT )
                                      ZIFKEY  = GS_9000-ZIFKEY ) ) ).
  ENDIF.

  IF PT_BOM[] IS NOT  INITIAL.
*  IF GT_FBOM[] IS INITIAL.
    LOOP AT PT_BOM INTO GT_9432.
      GT_9432-ZIFKEY  = GS_9000-ZIFKEY.
      APPEND GT_9432. CLEAR GT_9432.
    ENDLOOP.
*  ELSE.
*    GT_9432[] = VALUE #( FOR LS_BOM IN GT_FBOM
*                     ( VALUE #( BASE CORRESPONDING #( LS_BOM )
*                                      ZIFKEY  = GS_9000-ZIFKEY ) ) ).
  ENDIF.

*  IF GT_FCHAR[] IS INITIAL.
  IF PT_CHAR[] IS NOT INITIAL.
    LOOP AT PT_CHAR INTO GT_9433.
      GT_9433-ZIFKEY  = GS_9000-ZIFKEY.
      APPEND GT_9433. CLEAR GT_9433.
    ENDLOOP.
*  ELSE.
*    GT_9433[] = VALUE #( FOR LS_CH IN GT_FCHAR
*                     ( VALUE #( BASE CORRESPONDING #( LS_CH )
*                                      ZIFKEY  = GS_9000-ZIFKEY ) ) ).
  ENDIF.

  MODIFY ZGTMMT9433 FROM TABLE GT_9433.
  MODIFY ZGTMMT9432 FROM TABLE GT_9432.
  MODIFY ZGTMMT9431 FROM TABLE GT_9431.
  MODIFY ZGTMMT9430 FROM TABLE GT_9430.
  MODIFY ZGTMMT9000 FROM GS_9000.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_GUI
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_GUI.

  GV_SEND = COND #( WHEN P_ILOG = 'X'  THEN '재전송'(B01)
                                  WHEN P_SEND = 'X' THEN '전송'(B02) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_OBJ_IF
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_OBJ_IF.

  GR_DOCK = NEW #( REPID        = SY-REPID
                                DYNNR       = SY-DYNNR
                                SIDE           = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                                EXTENSION = 800 ).

  GR_SPLIT = NEW #( PARENT    = GR_DOCK
                                ROWS       = 5
                                COLUMNS = 1 ).

  "#1 ROW
  GR_LCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1  COLUMN = 1 ).

  GR_LGRID = NEW #( I_PARENT           = GR_LCNTR
                                 I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1  HEIGHT = 25 ).

  "#2 ROW
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2  COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT           = GR_HCNTR
                                 I_APPL_EVENTS = GC_X ).

  "#3 ROW
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 3    COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT          = GR_ICNTR
                               I_APPL_EVENTS = GC_X ).

  "#4 ROW
  GR_TCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 4    COLUMN = 1 ).

  GR_TGRID = NEW #( I_PARENT         = GR_TCNTR
                               I_APPL_EVENTS = GC_X ).

  "#5 ROW
  GR_FCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 5    COLUMN = 1 ).

  GR_FGRID = NEW #( I_PARENT         = GR_FCNTR
                               I_APPL_EVENTS = GC_X ).


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_OBJ
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_OBJ.

  GR_DOCK = NEW #( REPID        = SY-REPID
                                DYNNR       = SY-DYNNR
                                SIDE           = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
                                EXTENSION = 800 ).

  GR_SPLIT = NEW #( PARENT    = GR_DOCK
                                ROWS       = 4
                                COLUMNS = 1 ).

  "#1 ROW
  GR_HCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 1  COLUMN = 1 ).

  GR_HGRID = NEW #( I_PARENT           = GR_HCNTR
                                 I_APPL_EVENTS = GC_X ).

  GR_SPLIT->SET_ROW_HEIGHT( ID     = 1  HEIGHT = 35 ).

  "#2 ROW
  GR_ICNTR = GR_SPLIT->GET_CONTAINER( ROW    = 2    COLUMN = 1 ).

  GR_IGRID = NEW #( I_PARENT          = GR_ICNTR
                               I_APPL_EVENTS = GC_X ).

  "#3 ROW
  GR_TCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 3    COLUMN = 1 ).

  GR_TGRID = NEW #( I_PARENT         = GR_TCNTR
                               I_APPL_EVENTS = GC_X ).

  "#4 ROW
  GR_FCNTR = GR_SPLIT->GET_CONTAINER( ROW    = 4    COLUMN = 1 ).

  GR_FGRID = NEW #( I_PARENT         = GR_FCNTR
                               I_APPL_EVENTS = GC_X ).


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EXCL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_EXCL.

  CLEAR : GT_EXCL[].

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
*& FORM SET_LAYO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_LAYO USING PS_LAYO TYPE LVC_S_LAYO
                                     PV_TYPE.

  CLEAR : PS_LAYO.

  PS_LAYO-SEL_MODE   = GC_D.
  PS_LAYO-CWIDTH_OPT = GC_X.
  PS_LAYO-ZEBRA          = GC_X.
  PS_LAYO-SMALLTITLE = GC_X.

  CASE PV_TYPE.
    WHEN 'L'.
      PS_LAYO-GRID_TITLE = '구매오더전송LOG'(T01).

    WHEN 'H'.
      PS_LAYO-GRID_TITLE = '구매오더헤더'(T02).

    WHEN 'I'.
      PS_LAYO-GRID_TITLE = '구매오더품목'(T03).

    WHEN 'T'.
      PS_LAYO-GRID_TITLE = '구매오더특성'(T04).

    WHEN 'F'.
      PS_LAYO-GRID_TITLE = '임가공 BOM'(T05).

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_FCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
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

  CHECK PV_TYPE = GC_H.

  GS_FCAT-HOTSPOT = GC_X.
  MODIFY PT_FCAT FROM GS_FCAT TRANSPORTING HOTSPOT
                WHERE FIELDNAME = GC_EBELN.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT  USING PV_GUBUN TYPE CHAR1.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.
  CLEAR GR_DREF.

  CASE PV_GUBUN.
    WHEN 'H'.
      IF P_ILOG = GC_X.
        CREATE DATA GR_DREF LIKE GS_HEAD.
      ELSE.
        CREATE DATA GR_DREF LIKE GS_PCHG.
      ENDIF.

    WHEN 'I'.
      CREATE DATA GR_DREF LIKE GS_ITEM.

    WHEN 'T'.
      CREATE DATA GR_DREF LIKE GS_CHAR.

    WHEN 'F'.
      CREATE DATA GR_DREF LIKE GS_BOM.

    WHEN OTHERS.
      CREATE DATA GR_DREF LIKE GS_LOG.
  ENDCASE.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

  " 필드 카탈로그 변경사항 적용
  CASE PV_GUBUN.
    WHEN 'H'.
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT USING 'H'.

    WHEN 'I'.
      PERFORM ADJUST_FLDCATS_ITEM TABLES LT_FCAT USING 'I'.

    WHEN 'T'.
      PERFORM ADJUST_FLDCATS_ITEM TABLES LT_FCAT USING 'T'.

    WHEN 'F'.
      PERFORM ADJUST_FLDCATS_ITEM TABLES LT_FCAT USING 'F'.

    WHEN OTHERS.
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT USING 'L'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT USING PV_GB.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_LFCAT[], GT_HFCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'. "선택
        _FCAT TEXT-F01.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.

      WHEN OTHERS.
*        <FS_S_FCT>-TECH = GC_X.
    ENDCASE.

    IF PV_GB = 'L'.
      APPEND <FS_S_FCT> TO GT_LFCAT.
    ELSE.
      APPEND <FS_S_FCT> TO GT_HFCAT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_ITEM  TABLES PT_FCAT TYPE LVC_T_FCAT
                                                 USING PV_TYPE.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_IFCAT[], GT_TFCAT[], GT_FFCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN  'ZIFKEY' OR 'MANDT'.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'MENGE' OR 'MENGE_O' .
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.

      WHEN 'NETPR' OR 'NETWR' OR 'BRTWR'.
        <FS_S_FCT>-CFIELDNAME = 'WAERS'.

      WHEN 'NTGEW' OR 'BRGEW' .
        <FS_S_FCT>-QFIELDNAME = 'GEWEI'.

      WHEN 'VOLUM' .
        <FS_S_FCT>-QFIELDNAME = 'VOLEH'.

      WHEN 'VGW' OR 'VGW_T' OR 'VGW_T_O' .
        <FS_S_FCT>-QFIELDNAME = 'BME'.

      WHEN 'ERFMG'.
        <FS_S_FCT>-QFIELDNAME = 'ERFME'.

      WHEN OTHERS.
    ENDCASE.


    CASE PV_TYPE.
      WHEN 'I'.
        APPEND <FS_S_FCT> TO GT_IFCAT.
      WHEN 'T'.
        APPEND <FS_S_FCT> TO GT_TFCAT.
      WHEN OTHERS. "F
        APPEND <FS_S_FCT> TO GT_FFCAT.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EVNT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_HGRID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_EVNT USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                    PV_OTEXT.

  PR_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PR_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  GR_EVENTS = NEW LCL_EVENT_HANDLER( E_OBJECT_TEXT = PV_OTEXT ).

  SET HANDLER GR_EVENTS->HANDLE_DATA_CHANGED FOR PR_GRID.
*  SET HANDLER GR_EVENTS->HANDLE_CONTEXT_MENU FOR PR_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DISP
*&---------------------------------------------------------------------*
*& TEXT
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

*  CLEAR : GS_VARI.
*  GS_VARI-HANDLE     = PV_TYPE.
*  GS_VARI-REPORT     = SY-REPID.
*  GS_VARI-USERNAME = SY-UNAME.

  DATA(LS_VARIANT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                             HANDLE  =
                                  COND #( WHEN PR_GRID = GR_LGRID
                                                THEN '0001'
                                                WHEN PR_GRID = GR_HGRID
                                                THEN '0002'
                                                WHEN PR_GRID = GR_IGRID
                                                THEN '0003'
                                                WHEN PR_GRID = GR_TGRID
                                                THEN '0004'
                                                WHEN PR_GRID = GR_FGRID
                                                THEN '0005' ELSE '0006' ) ).

  CALL METHOD PR_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = LS_VARIANT "GS_VARI
      I_SAVE               = GC_A
      IS_LAYOUT            = PS_LAYO
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
    CHANGING
      IT_OUTTAB            = PT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[].

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REFRESH_GRID
*&---------------------------------------------------------------------*
*& TEXT
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
*& FORM FREE_OBJ
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM FREE_OBJ.

  CASE SY-DYNNR.
    WHEN '0100'.
      IF P_ILOG = GC_X.
        CALL METHOD GR_LGRID->FREE.
        CALL METHOD GR_LCNTR->FREE.
      ENDIF.
      CALL METHOD GR_HGRID->FREE.
      CALL METHOD GR_IGRID->FREE.
      CALL METHOD GR_TGRID->FREE.
      CALL METHOD GR_FGRID->FREE.
      CALL METHOD GR_HCNTR->FREE.
      CALL METHOD GR_ICNTR->FREE.
      CALL METHOD GR_TCNTR->FREE.
      CALL METHOD GR_FCNTR->FREE.
      CALL METHOD GR_DOCK->FREE.
      CLEAR : GR_HGRID, GR_IGRID, GR_HCNTR, GR_ICNTR, GR_DOCK,
                   GR_TGRID, GR_FGRID,GR_TCNTR, GR_FCNTR, GR_LGRID, GR_LCNTR.

      CLEAR : GT_LOG, GT_HEAD, GT_ITEM, GT_CHAR, GT_BOM.

    WHEN OTHERS.

  ENDCASE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&      --> GV_OTEXT
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                            PV_OTEXT.

  CASE PV_OTEXT.
    WHEN 'GR_HGRID' OR 'GR_LGRID'.
      LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).

        CASE LS_MOD_CELLS-FIELDNAME.

          WHEN 'CHECK'.
*        I/F LOG DISPLAY
            IF P_ILOG = GC_X.
              READ TABLE GT_LOG ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
              CHECK <FS> IS ASSIGNED.
              <FS>-CHECK = LS_MOD_CELLS-VALUE.

              IF <FS>-CHECK IS INITIAL.
                DELETE GT_HEAD WHERE ZIFKEY = <FS>-ZIFKEY AND EBELN = <FS>-EBELN.
                DELETE GT_ITEM WHERE ZIFKEY = <FS>-ZIFKEY AND EBELN = <FS>-EBELN.
                DELETE GT_CHAR WHERE ZIFKEY = <FS>-ZIFKEY AND EBELN = <FS>-EBELN.
                DELETE GT_BOM WHERE ZIFKEY = <FS>-ZIFKEY AND EBELN = <FS>-EBELN.
              ELSE.
                PERFORM GET_ITEM_CK_IF USING <FS>-ZIFKEY <FS>-EBELN <FS>-WAERS.
              ENDIF.


*         DATA SEND
            ELSEIF P_SEND = GC_X.
              READ TABLE GT_PCHG ASSIGNING FIELD-SYMBOL(<CHG>) INDEX LS_MOD_CELLS-ROW_ID.
              CHECK <CHG> IS ASSIGNED.
              <CHG>-CHECK = LS_MOD_CELLS-VALUE.

              IF <CHG>-CHECK IS INITIAL.
                DELETE GT_ITEM WHERE EBELN = <CHG>-EBELN.
                DELETE GT_CHAR WHERE EBELN = <CHG>-EBELN.
                DELETE GT_BOM WHERE EBELN = <CHG>-EBELN.
              ELSE.
                PERFORM GET_ITEM_CHECK USING <CHG>-EBELN <CHG>-WAERS.
              ENDIF.
            ENDIF.

        ENDCASE.

      ENDLOOP.

      IF P_ILOG = GC_X.
        PERFORM REFRESH_GRID USING GR_LGRID GS_LLAYO.
      ENDIF.
      PERFORM REFRESH_GRID USING GR_HGRID GS_HLAYO.
      PERFORM REFRESH_GRID USING GR_IGRID  GS_ILAYO.
      PERFORM REFRESH_GRID USING GR_TGRID GS_TLAYO.
      PERFORM REFRESH_GRID USING GR_FGRID GS_FLAYO.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
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

*  CASE PV_OTEXT.
*    WHEN 'GR_HGRID'.
*      READ TABLE <GT_HLIST> ASSIGNING <GS_LIST> INDEX PS_ROW-INDEX.
*
*      CASE PS_COL-FIELDNAME.
*        WHEN 'EBELN'.
*
*          PERFORM REFRESH_GRID USING GR_IGRID
*                                     GS_ILAYO.
*
*      ENDCASE.
*
*    WHEN OTHERS.
*
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_ILIST_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_ILIST_DATA USING  PV_GB PV_KEY PV_EBELN.

  CASE PV_GB.
    WHEN 'H'.
      READ TABLE GT_HEAD INTO DATA(LS_HEAD)
      WITH KEY ZIFKEY = PV_KEY
                     EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FHEAD = CORRESPONDING #( LS_HEAD ).
        APPEND GT_FHEAD. CLEAR GT_FHEAD.
      ENDIF.

    WHEN 'I'.
      READ TABLE GT_ITEM INTO DATA(LS_IT)
      WITH KEY ZIFKEY = PV_KEY
                     EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FITEM = CORRESPONDING #( LS_IT ).
        APPEND GT_FITEM. CLEAR GT_FITEM.
      ENDIF.

    WHEN 'T'.
      READ TABLE GT_CHAR INTO DATA(LS_CH)
      WITH KEY ZIFKEY = PV_KEY
                     EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FCHAR = CORRESPONDING #( LS_CH ).
        APPEND GT_FCHAR. CLEAR GT_FCHAR.
      ENDIF.

    WHEN 'F'.
      READ TABLE GT_BOM INTO DATA(LS_BOM)
      WITH KEY ZIFKEY = PV_KEY
                     EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FBOM = CORRESPONDING #( LS_BOM ).
        APPEND GT_FBOM. CLEAR GT_FBOM.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SEND_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SEND_ITEM  USING  PV_GB  PV_EBELN.

  CASE PV_GB.
    WHEN 'H'.
      READ TABLE GT_HEAD INTO DATA(LS_HEAD)
      WITH KEY EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FHEAD = CORRESPONDING #( LS_HEAD ).
        APPEND GT_FHEAD. CLEAR GT_FHEAD.
      ENDIF.

    WHEN 'I'.
      READ TABLE GT_ITEM INTO DATA(LS_IT)
      WITH KEY EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FITEM = CORRESPONDING #( LS_IT ).
        APPEND GT_FITEM. CLEAR GT_FITEM.
      ENDIF.

    WHEN 'T'.
      READ TABLE GT_CHAR INTO DATA(LS_CH)
      WITH KEY  EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FCHAR = CORRESPONDING #( LS_CH ).
        APPEND GT_FCHAR. CLEAR GT_FCHAR.
      ENDIF.

    WHEN 'F'.
      READ TABLE GT_BOM INTO DATA(LS_BOM)
      WITH KEY EBELN = PV_EBELN BINARY SEARCH.
      IF SY-SUBRC = 0.
        GT_FBOM = CORRESPONDING #( LS_BOM ).
        APPEND GT_FBOM. CLEAR GT_FBOM.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_D
*&---------------------------------------------------------------------*
FORM SET_SELECT_ALL  USING    PV_GB. "A:전체선택  D:전체해제
*HEADER
  IF P_ILOG = GC_X.
    LOOP AT GT_LOG ASSIGNING FIELD-SYMBOL(<LOG>).
      <LOG>-CHECK = COND #( WHEN PV_GB = GC_A
                                               THEN GC_X ELSE SPACE ).
    ENDLOOP.
  ELSE.
    LOOP AT GT_PCHG ASSIGNING FIELD-SYMBOL(<CHG>).
      <CHG>-CHECK = COND #( WHEN PV_GB = GC_A
                                               THEN GC_X ELSE SPACE ).
    ENDLOOP.
  ENDIF.

*ITEM
  CASE PV_GB.
    WHEN GC_A.
      IF P_ILOG = GC_X.
        GT_HEAD[] = CORRESPONDING #( GT_IFHEAD[] ).
        GT_ITEM[] = CORRESPONDING #( GT_IFITEM[] ).
        GT_CHAR[] = CORRESPONDING #( GT_IFCHAR[] ).
        GT_BOM[] = CORRESPONDING #( GT_IFBOM[] ).

      ELSE.
        GT_ITEM[] = CORRESPONDING #( GT_SITEM[] ).
        GT_CHAR[] = CORRESPONDING #( GT_SCHAR[] ).
        GT_BOM[] = CORRESPONDING #( GT_SBOM[] ).
      ENDIF.

    WHEN GC_D.
      IF P_ILOG = GC_X.
        CLEAR GT_HEAD.
      ENDIF.
      CLEAR : GT_ITEM, GT_CHAR, GT_BOM.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITEM_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <CHG>_EBELN
*&---------------------------------------------------------------------*
FORM GET_ITEM_CHECK  USING    PV_EBELN TYPE EBELN
                                                     PV_WAERS TYPE WAERS      .

  DATA : LV_AMT(16).

  CLEAR: GS_ITEM, GS_CHAR, GS_BOM.

  LOOP AT GT_SITEM ASSIGNING FIELD-SYMBOL(<FSI>) WHERE EBELN = PV_EBELN.
    GS_ITEM = CORRESPONDING #( <FSI> ).
    APPEND GS_ITEM TO GT_ITEM.
  ENDLOOP.

  LOOP AT GT_SCHAR ASSIGNING FIELD-SYMBOL(<FSC>) WHERE EBELN = PV_EBELN.
    GS_CHAR = CORRESPONDING #( <FSC> ).
    APPEND GS_CHAR TO GT_CHAR.
  ENDLOOP.

  LOOP AT GT_SBOM ASSIGNING FIELD-SYMBOL(<FSB>) WHERE EBELN = PV_EBELN.
    GS_BOM = CORRESPONDING #( <FSB> ).
    APPEND GS_BOM TO GT_BOM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITEM_CK_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_ZIFKEY
*&      --> <FS>_EBELN
*&---------------------------------------------------------------------*
FORM GET_ITEM_CK_IF  USING    PV_ZIFKEY  TYPE ZGTEIFKEY
                                                  PV_EBELN TYPE EBELN
                                                  PV_WAERS TYPE WAERS.

  DATA : LV_WAERS(5),
         LV_AMT(16).
  CLEAR:  GS_HEAD, GS_ITEM, GS_CHAR, GS_BOM.

  LOOP AT GT_IFHEAD ASSIGNING FIELD-SYMBOL(<FS>) WHERE ZIFKEY = PV_ZIFKEY
                                                                                          AND EBELN = PV_EBELN.
    GS_HEAD = CORRESPONDING #( <FS> ).
    APPEND GS_HEAD TO GT_HEAD.
  ENDLOOP.

  LOOP AT GT_IFITEM ASSIGNING FIELD-SYMBOL(<FSI>) WHERE EBELN = PV_EBELN.
    GS_ITEM = CORRESPONDING #( <FSI> ).
    APPEND GS_ITEM TO GT_ITEM.
  ENDLOOP.

  LOOP AT GT_IFCHAR ASSIGNING FIELD-SYMBOL(<FSC>) WHERE EBELN = PV_EBELN.
    GS_CHAR = CORRESPONDING #( <FSC> ).
    APPEND GS_CHAR TO GT_CHAR.
  ENDLOOP.

  LOOP AT GT_IFBOM ASSIGNING FIELD-SYMBOL(<FSB>) WHERE EBELN = PV_EBELN.
    GS_BOM = CORRESPONDING #( <FSB> ).
    APPEND GS_BOM TO GT_BOM.
  ENDLOOP.


ENDFORM.
