*&---------------------------------------------------------------------*
*& Include          ZGTPPR3110F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
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
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_AUTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_AUTH .

*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
                      ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH '플랜트[' P_WERKS
                      '] 작업권한을 확인하세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  DATA : BEGIN OF LS_CHK_VBELN,
           VBELN LIKE VBAK-VBELN,
         END OF LS_CHK_VBELN.
  DATA : LT_CHK_VBELN LIKE TABLE OF LS_CHK_VBELN.

  DATA : BEGIN OF LS_RSNUM,
           RSNUM LIKE RESB-RSNUM,
         END OF LS_RSNUM.
  DATA : LT_CHK_RSNUM LIKE TABLE OF LS_RSNUM.

  DATA : BEGIN OF LS_AUFNR,
           AUFNR LIKE ZGTPPT3250-AUFNR,
         END OF LS_AUFNR.
  DATA : LT_CHK_AUFNR LIKE TABLE OF LS_AUFNR.

  DATA : BEGIN OF LS_CHK_ANNAM,
           MATNR  TYPE MATNR,
           MATNR2 TYPE MATNR,
           ANNAM  TYPE STPOX-ANNAM,
         END OF LS_CHK_ANNAM.
  DATA : LT_CHK_ANNAM LIKE TABLE OF LS_CHK_ANNAM.

  DATA : BEGIN OF LS_CHK_NAME,
           ANNAM     TYPE STPOX-ANNAM,
           NAME_TEXT LIKE USER_ADDR-NAME_TEXTC,
         END OF LS_CHK_NAME.
  DATA : LT_CHK_NAME LIKE TABLE OF LS_CHK_NAME.

  DATA : BEGIN OF LS_MAIN,
           AUFNR    TYPE AUFK-AUFNR,
           GSTRP    TYPE AFKO-GSTRP,
           GLTRP    TYPE AFKO-GLTRP,
           GAMNG    TYPE AFKO-GAMNG,
           GMEIN    TYPE AFKO-GMEIN,
           RSNUM    TYPE AFKO-RSNUM,
           MATNR    TYPE AFPO-MATNR,
           KDAUF    TYPE AFPO-KDAUF,
           ORD_STAT TYPE CHAR20,
         END OF LS_MAIN.
  DATA : LT_MAIN LIKE TABLE OF LS_MAIN.
  DATA : LV_DEL_CHK.
  DATA : LT_STB TYPE TABLE OF STPOX.

  DATA : BEGIN OF LS_BOM,
           AUFNR   TYPE AUFK-AUFNR,
           MATNR   TYPE AFPO-MATNR,
           INDEX   TYPE I,
           MATNR2  TYPE AFPO-MATNR,
           MNGKO   TYPE STPOX-MNGKO,
           MEINS   TYPE MEINS,
           CHK_USE TYPE CHAR01,
         END OF LS_BOM.
  DATA : LT_BOM LIKE TABLE OF LS_BOM.
  DATA : LT_BOM_ORD LIKE TABLE OF LS_BOM.

  DATA : BEGIN OF LS_RESB,
           RSNUM   TYPE RESB-RSNUM,
           RSPOS   TYPE RESB-RSPOS,
           RSART   TYPE RESB-RSART,
           MATNR   TYPE RESB-MATNR,
           BDMNG   TYPE RESB-BDMNG,
           MEINS   TYPE RESB-MEINS,
           CHK_USE TYPE CHAR01,
         END OF LS_RESB.
  DATA : LT_RESB LIKE TABLE OF LS_RESB.
  DATA : LT_RESB_ORD LIKE TABLE OF LS_RESB.
  DATA : LS_MAIN_INFOR LIKE GS_MAIN_DISP.

  DATA : BEGIN OF LS_CHK_MATNR,
           MATNR TYPE AFPO-MATNR,
         END OF LS_CHK_MATNR.
  DATA : LT_CHK_MATNR LIKE TABLE OF LS_CHK_MATNR.

  DATA : BEGIN OF LS_0220,
           MATNR   TYPE ZPPT0220-MATNR,
           IDNRK   TYPE ZPPT0220-IDNRK,
           SETQTY  TYPE ZPPT0220-SETQTY,
           POSNR   TYPE ZPPT0220-POSNR,
           QTY     TYPE ZPPT0220-QTY,
           CHK_USE TYPE CHAR01,
         END OF LS_0220.
  DATA : LT_0220 LIKE TABLE OF LS_0220.
  DATA : LT_0220_CHK LIKE TABLE OF LS_0220.
  DATA : LT_0220_ORD LIKE TABLE OF LS_0220.

  DATA : LV_ORD_IDX TYPE I.

* 기본데이터 추출
  SELECT A~AUFNR, B~GSTRP, B~GLTRP, B~GAMNG, B~GMEIN, B~RSNUM, C~MATNR, C~KDAUF
      FROM AUFK AS A
      INNER JOIN AFKO AS B
                           ON B~AUFNR = A~AUFNR
      INNER JOIN AFPO AS C
                           ON C~AUFNR = A~AUFNR
      INNER JOIN MARC AS D
                           ON D~MATNR = C~MATNR
                          AND D~WERKS = A~WERKS
      INNER JOIN RESB AS E
                           ON E~RSNUM = B~RSNUM
    WHERE A~WERKS = @P_WERKS
       AND A~AUFNR IN @S_AUFNR
       AND C~MATNR IN @S_MATNR
       AND B~GSTRP IN @S_GSTRP
       AND D~DISPO IN @S_DISPO
       AND E~MATNR IN @S_IDNRK
    INTO CORRESPONDING FIELDS OF TABLE @LT_MAIN.

  SORT LT_MAIN BY AUFNR KDAUF.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING AUFNR KDAUF.
* 오더 상태 체크, 표준봄 조회
  LOOP AT LT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
*  오더 상태 조회 후 후속처리
    CLEAR LV_DEL_CHK.
    PERFORM GET_STATUS USING <LS_MAIN>-AUFNR CHANGING <LS_MAIN>-ORD_STAT LV_DEL_CHK.
    IF LV_DEL_CHK IS NOT INITIAL." 삭제처리
      DELETE LT_MAIN.
      CONTINUE.
    ENDIF.

*    BOM 조회 Function을 사용하여 Lv1 구성품 확인
*    READ TABLE LT_BOM TRANSPORTING NO FIELDS WITH KEY MATNR = <LS_MAIN>-MATNR.
*    IF SY-SUBRC NE 0.

    REFRESH LT_STB.
    PERFORM GET_BOM_DATA TABLES LT_STB
                                          USING <LS_MAIN>-GAMNG <LS_MAIN>-MATNR.

    IF LT_STB[] IS NOT INITIAL.
      LOOP AT LT_STB INTO DATA(LS_STB) WHERE STUFE = 1
                                                               AND IDNRK IN S_IDNRK.
        CLEAR LS_BOM.
        LS_BOM-AUFNR = <LS_MAIN>-AUFNR.
        LS_BOM-MATNR = <LS_MAIN>-MATNR.
        LS_BOM-INDEX = LS_STB-INDEX.
        LS_BOM-MATNR2 = LS_STB-IDNRK.
        LS_BOM-MNGKO = LS_STB-MNGKO.
        LS_BOM-MEINS = LS_STB-MMEIN.
        APPEND LS_BOM TO LT_BOM.

        READ TABLE LT_CHK_ANNAM INTO LS_CHK_ANNAM WITH KEY MATNR = <LS_MAIN>-MATNR
                                                                                         MATNR2 = LS_STB-IDNRK
                                                                                         BINARY SEARCH.
        IF SY-SUBRC NE 0.
          LS_CHK_ANNAM-MATNR = <LS_MAIN>-MATNR.
          LS_CHK_ANNAM-MATNR2 = LS_STB-IDNRK.
          LS_CHK_ANNAM-ANNAM = LS_STB-ANNAM.
          INSERT LS_CHK_ANNAM INTO LT_CHK_ANNAM INDEX SY-TABIX.
        ENDIF.

      ENDLOOP.
    ENDIF.
*    ENDIF.
  ENDLOOP.

  SORT LT_BOM BY AUFNR MATNR INDEX.

* 생산 오더 구성품 조회
  LT_CHK_RSNUM = VALUE #( FOR WA_RSNUM  IN LT_MAIN WHERE ( RSNUM IS NOT INITIAL ) ( RSNUM = WA_RSNUM-RSNUM ) ).

  SORT LT_CHK_RSNUM BY RSNUM.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_RSNUM COMPARING RSNUM.

  IF LT_CHK_RSNUM[] IS NOT INITIAL.
    SELECT RSNUM, RSPOS, RSART, MATNR, ERFMG AS BDMNG, ERFME AS MEINS
       FROM RESB
       FOR ALL ENTRIES IN @LT_CHK_RSNUM
     WHERE RSNUM = @LT_CHK_RSNUM-RSNUM
        AND WERKS = @P_WERKS
        AND MATNR IN @S_IDNRK
        AND XLOEK NE @ABAP_TRUE
       INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
  ENDIF.

  SORT LT_RESB BY RSNUM RSPOS RSART.

* 판매오더 정보 조회
  LT_CHK_VBELN = VALUE #( FOR WA_VBELN  IN LT_MAIN WHERE ( KDAUF IS NOT INITIAL ) ( VBELN = WA_VBELN-KDAUF ) ).

  SORT LT_CHK_VBELN BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_VBELN COMPARING VBELN.

  IF LT_CHK_VBELN[] IS NOT INITIAL.
    SELECT A~VBELN, B~BSTKD, C~ZPTXT, E~NAME1
      FROM VBAK AS A
      LEFT JOIN VBKD AS B
                           ON B~VBELN = A~VBELN
      LEFT JOIN ZSD0106T AS C
                              ON C~ZPJNO = A~ZPJNO
      INNER JOIN VBPA AS D
                            ON D~VBELN = A~VBELN
                           AND D~PARVW = 'AG'
      INNER JOIN KNA1 AS E
                            ON E~KUNNR = D~KUNNR
     FOR ALL ENTRIES IN @LT_CHK_VBELN
     WHERE A~VBELN = @LT_CHK_VBELN-VBELN
      INTO TABLE @DATA(LT_VBELN).
  ENDIF.
  SORT LT_VBELN BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_VBELN COMPARING VBELN.

* KIT 작업 표준 조회
  LT_CHK_MATNR = VALUE #( FOR WA_MATNR  IN LT_MAIN WHERE ( MATNR IS NOT INITIAL ) ( MATNR = WA_MATNR-MATNR ) ).
  SORT LT_CHK_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING MATNR.
  IF LT_CHK_MATNR[] IS NOT INITIAL.
    SELECT MATNR, IDNRK, SETQTY, POSNR, QTY FROM ZPPT0220
         FOR ALL ENTRIES IN @LT_CHK_MATNR
       WHERE MATNR = @LT_CHK_MATNR-MATNR
           AND IDNRK IN @S_IDNRK
        INTO CORRESPONDING FIELDS OF TABLE @LT_0220.
  ENDIF.

  SORT LT_0220 BY MATNR IDNRK QTY POSNR.

* 차이 사유 조회
  LT_CHK_AUFNR = VALUE #( FOR WA_AUFNR  IN LT_MAIN WHERE ( AUFNR IS NOT INITIAL ) ( AUFNR = WA_AUFNR-AUFNR ) ).
  SORT LT_CHK_AUFNR BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AUFNR COMPARING AUFNR.
  IF LT_CHK_AUFNR[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT3250
         FOR ALL ENTRIES IN @LT_CHK_AUFNR
     WHERE WERKS = @P_WERKS
         AND AUFNR = @LT_CHK_AUFNR-AUFNR
        INTO TABLE @DATA(LT_REASON).
  ENDIF.
  SORT LT_REASON BY AUFNR MATNR RCOMP BCOMP JCOMP.
  DELETE ADJACENT DUPLICATES FROM LT_REASON COMPARING AUFNR MATNR RCOMP BCOMP JCOMP.

*  추출된 데이터로 출력테이블 구성
  REFRESH GT_MAIN_DISP.
  LOOP AT LT_MAIN INTO LS_MAIN.
*    기본 생성오더 정보
    CLEAR LS_MAIN_INFOR.
    LS_MAIN_INFOR-ORD_STAT = LS_MAIN-ORD_STAT.
    LS_MAIN_INFOR-AUFNR = LS_MAIN-AUFNR.
    LS_MAIN_INFOR-MATNR = LS_MAIN-MATNR.
    LS_MAIN_INFOR-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MAIN-MATNR ).
    LS_MAIN_INFOR-GAMNG = LS_MAIN-GAMNG.
    LS_MAIN_INFOR-GMEIN = LS_MAIN-GMEIN.
    LS_MAIN_INFOR-GSTRP = LS_MAIN-GSTRP.
    LS_MAIN_INFOR-GLTRP = LS_MAIN-GLTRP.

* 판매오더 정보
    READ TABLE LT_VBELN INTO DATA(LS_VBELN) WITH KEY VBELN = LS_MAIN-KDAUF BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LS_MAIN_INFOR-BSTKD = LS_VBELN-BSTKD.
      LS_MAIN_INFOR-ZPTXT = LS_VBELN-ZPTXT.
      LS_MAIN_INFOR-NAME1 = LS_VBELN-NAME1.
    ENDIF.

* 제조번호
    PERFORM GET_TAGNR USING LS_MAIN-AUFNR LS_MAIN-MATNR CHANGING LS_MAIN_INFOR-TAGNR.

* 구성 자재별 세팅 / 비교
* 오더 예약자재
    REFRESH LT_RESB_ORD.
    LT_RESB_ORD = VALUE #( FOR WA_RESB  IN LT_RESB WHERE ( RSNUM = LS_MAIN-RSNUM ) ( CORRESPONDING #( WA_RESB ) ) ).
* 오더의 자재 기준 표준봄
    REFRESH LT_BOM_ORD.
    LT_BOM_ORD = VALUE #( FOR WA_BOM  IN LT_BOM WHERE ( AUFNR = LS_MAIN-AUFNR AND MATNR = LS_MAIN-MATNR ) ( CORRESPONDING #( WA_BOM ) ) ).
*  KIT 작업표준
    REFRESH LT_0220_ORD.
    CASE ABAP_TRUE.
      WHEN P_ORDNO. " 오더 구성자재 기준 작업표준 조회
        LOOP AT LT_RESB_ORD INTO DATA(LS_RESB_ORD).
          REFRESH LT_0220_CHK.
          LT_0220_CHK = VALUE #( FOR WA_0220  IN LT_0220 WHERE ( MATNR = LS_MAIN-MATNR
                                                                                    AND   IDNRK = LS_RESB_ORD-MATNR
                                                                                    AND   SETQTY = LS_MAIN-GAMNG )
                                                                 ( CORRESPONDING #( WA_0220 ) ) ).
          IF LT_0220_CHK[] IS NOT INITIAL.
            APPEND LINES OF LT_0220_CHK TO LT_0220_ORD.
          ENDIF.
        ENDLOOP.
      WHEN P_BOM. " 표준 봄 구성자재 기준 작업표준 조회
        LOOP AT LT_BOM_ORD INTO DATA(LS_BOM_ORD).
          REFRESH LT_0220_CHK.
          LT_0220_CHK = VALUE #( FOR WA_0220  IN LT_0220 WHERE ( MATNR = LS_BOM_ORD-MATNR
                                                                                    AND   IDNRK = LS_BOM_ORD-MATNR2
                                                                                    AND   SETQTY = LS_MAIN-GAMNG )
                                                                 ( CORRESPONDING #( WA_0220 ) ) ).
          IF LT_0220_CHK[] IS NOT INITIAL.
            APPEND LINES OF LT_0220_CHK TO LT_0220_ORD.
          ENDIF.
        ENDLOOP.
    ENDCASE.

    SORT LT_0220_ORD BY MATNR IDNRK SETQTY POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_0220_ORD COMPARING MATNR IDNRK SETQTY POSNR.

*  하위 구성자재별 콜렉트(차후 조정가능)
*&---------------------------------------------------------------------*
    DATA(LT_RESB_ORD_RE) = LT_RESB_ORD.
    DATA(LT_BOM_ORD_RE) = LT_BOM_ORD.
    DATA(LT_0220_ORD_RE) = LT_0220_ORD.

    REFRESH LT_RESB_ORD.
    REFRESH LT_BOM_ORD.
    REFRESH LT_0220_ORD.

    LOOP AT LT_RESB_ORD_RE INTO DATA(LS_RESB_ORD_RE).
      CLEAR : LS_RESB_ORD_RE-RSPOS, LS_RESB_ORD_RE-RSART.
      COLLECT LS_RESB_ORD_RE INTO LT_RESB_ORD.
    ENDLOOP.

    LOOP AT LT_BOM_ORD_RE INTO DATA(LS_BOM_ORD_RE).
      CLEAR : LS_BOM_ORD_RE-INDEX.
      COLLECT LS_BOM_ORD_RE INTO LT_BOM_ORD.
    ENDLOOP.

    LOOP AT LT_0220_ORD_RE INTO DATA(LS_0220_ORD_RE).
      CLEAR : LS_0220_ORD_RE-POSNR.
      COLLECT LS_0220_ORD_RE INTO LT_0220_ORD.
    ENDLOOP.

*&---------------------------------------------------------------------*
    CLEAR LV_ORD_IDX.
    CASE ABAP_TRUE.
      WHEN P_ORDNO. " 오더 구성자재 기준 소팅
        LOOP AT LT_RESB_ORD INTO LS_RESB_ORD.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-MATNR2 = LS_RESB_ORD-MATNR.
          <LS_MAIN_DISP>-BDMNG = LS_RESB_ORD-BDMNG.
          <LS_MAIN_DISP>-MEINS = LS_RESB_ORD-MEINS.
          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_RESB_ORD-MATNR ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
* 봄자재비교
          READ TABLE LT_BOM_ORD ASSIGNING FIELD-SYMBOL(<LS_BOM_ORD>) WITH KEY MATNR2 = LS_RESB_ORD-MATNR
                                                                                                                       CHK_USE = ' '.
          IF SY-SUBRC EQ 0.
            <LS_BOM_ORD>-CHK_USE = ABAP_TRUE.
            <LS_MAIN_DISP>-IDNRK = <LS_BOM_ORD>-MATNR2.
            <LS_MAIN_DISP>-MENGE = <LS_BOM_ORD>-MNGKO.
            IF <LS_MAIN_DISP>-BDMNG > <LS_MAIN_DISP>-MENGE.
              <LS_MAIN_DISP>-COMP01 = ICON_GREATER_RED.
            ELSEIF <LS_MAIN_DISP>-BDMNG = <LS_MAIN_DISP>-MENGE.
              <LS_MAIN_DISP>-COMP01 = ICON_EQUAL_GREEN.
            ELSE.
              <LS_MAIN_DISP>-COMP01 = ICON_LESS_RED.
            ENDIF.
          ELSE.
            <LS_MAIN_DISP>-COMP01 = ICON_NOT_EQUAL_RED.
          ENDIF.

* 표준구성품 비교
          READ TABLE LT_0220_ORD ASSIGNING FIELD-SYMBOL(<LS_0220_ORD>) WITH KEY IDNRK = LS_RESB_ORD-MATNR
                                                                                                                        CHK_USE = ' '.
          IF SY-SUBRC EQ 0.
            <LS_0220_ORD>-CHK_USE = ABAP_TRUE.
            <LS_MAIN_DISP>-IDNRK2 = <LS_0220_ORD>-IDNRK.
            <LS_MAIN_DISP>-QTY = <LS_0220_ORD>-QTY.
            IF <LS_MAIN_DISP>-BDMNG > <LS_MAIN_DISP>-QTY.
              <LS_MAIN_DISP>-COMP02 = ICON_GREATER_RED.
            ELSEIF <LS_MAIN_DISP>-BDMNG = <LS_MAIN_DISP>-QTY.
              <LS_MAIN_DISP>-COMP02 = ICON_EQUAL_GREEN.
            ELSE.
              <LS_MAIN_DISP>-COMP02 = ICON_LESS_RED.
            ENDIF.
          ELSE.
            <LS_MAIN_DISP>-COMP02 = ICON_NOT_EQUAL_RED.
          ENDIF.
        ENDLOOP.

*  오더 구성자재 기준 제외한 나머지 존재건 처리
* 표준봄
        LOOP AT LT_BOM_ORD ASSIGNING <LS_BOM_ORD> WHERE CHK_USE = ' '.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-IDNRK = <LS_BOM_ORD>-MATNR2.
          <LS_MAIN_DISP>-MENGE = <LS_BOM_ORD>-MNGKO.
          <LS_MAIN_DISP>-MEINS = <LS_BOM_ORD>-MEINS.
          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_BOM_ORD>-MATNR2 ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
          <LS_MAIN_DISP>-COMP01 = ICON_NOT_EQUAL_RED.
        ENDLOOP.

* 표준구성품
        LOOP AT LT_0220_ORD ASSIGNING <LS_0220_ORD> WHERE CHK_USE = ' '.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-IDNRK2 = <LS_0220_ORD>-IDNRK.
          <LS_MAIN_DISP>-MENGE = <LS_0220_ORD>-QTY.
          SELECT SINGLE MEINS FROM MARA
            INTO <LS_MAIN_DISP>-MEINS
            WHERE MATNR = <LS_0220_ORD>-IDNRK.

          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_0220_ORD>-IDNRK ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
          <LS_MAIN_DISP>-COMP02 = ICON_NOT_EQUAL_RED.
        ENDLOOP.

      WHEN P_BOM. " 표준 봄 구성자재 기준 소팅
        LOOP AT LT_BOM_ORD INTO LS_BOM_ORD.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-IDNRK = LS_BOM_ORD-MATNR2.
          <LS_MAIN_DISP>-MENGE = LS_BOM_ORD-MNGKO.
          <LS_MAIN_DISP>-MEINS = LS_BOM_ORD-MEINS.
          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_BOM_ORD-MATNR2 ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
* 봄자재비교
          READ TABLE LT_RESB_ORD ASSIGNING FIELD-SYMBOL(<LS_RESB_ORD>) WITH KEY MATNR = LS_BOM_ORD-MATNR2
                                                                                                                         CHK_USE = ' '.
          IF SY-SUBRC EQ 0.
            <LS_RESB_ORD>-CHK_USE = ABAP_TRUE.
            <LS_MAIN_DISP>-MATNR2 = <LS_RESB_ORD>-MATNR.
            <LS_MAIN_DISP>-BDMNG = <LS_RESB_ORD>-BDMNG.
            IF <LS_MAIN_DISP>-BDMNG > <LS_MAIN_DISP>-MENGE.
              <LS_MAIN_DISP>-COMP01 = ICON_GREATER_RED.
            ELSEIF <LS_MAIN_DISP>-BDMNG = <LS_MAIN_DISP>-MENGE.
              <LS_MAIN_DISP>-COMP01 = ICON_EQUAL_GREEN.
            ELSE.
              <LS_MAIN_DISP>-COMP01 = ICON_LESS_RED.
            ENDIF.
          ELSE.
            <LS_MAIN_DISP>-COMP01 = ICON_NOT_EQUAL_RED.
          ENDIF.

* 표준구성품 비교
          READ TABLE LT_0220_ORD ASSIGNING <LS_0220_ORD> WITH KEY IDNRK = LS_BOM_ORD-MATNR2
                                                                                                  CHK_USE = ' '.
          IF SY-SUBRC EQ 0.
            <LS_0220_ORD>-CHK_USE = ABAP_TRUE.
            <LS_MAIN_DISP>-IDNRK2 = <LS_0220_ORD>-IDNRK.
            <LS_MAIN_DISP>-QTY = <LS_0220_ORD>-QTY.
            IF <LS_MAIN_DISP>-MENGE > <LS_MAIN_DISP>-QTY.
              <LS_MAIN_DISP>-COMP02 = ICON_GREATER_RED.
            ELSEIF <LS_MAIN_DISP>-MENGE = <LS_MAIN_DISP>-QTY.
              <LS_MAIN_DISP>-COMP02 = ICON_EQUAL_GREEN.
            ELSE.
              <LS_MAIN_DISP>-COMP02 = ICON_LESS_RED.
            ENDIF.
          ELSE.
            <LS_MAIN_DISP>-COMP02 = ICON_NOT_EQUAL_RED.
          ENDIF.
        ENDLOOP.

*  오더 구성자재 기준 제외한 나머지 존재건 처리
* 표준봄
        LOOP AT LT_RESB_ORD ASSIGNING <LS_RESB_ORD> WHERE CHK_USE = ' '.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-MATNR2 = <LS_RESB_ORD>-MATNR.
          <LS_MAIN_DISP>-BDMNG = <LS_RESB_ORD>-BDMNG.
          <LS_MAIN_DISP>-MEINS = <LS_RESB_ORD>-MEINS.
          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_RESB_ORD>-MATNR ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
          <LS_MAIN_DISP>-COMP01 = ICON_NOT_EQUAL_RED.
        ENDLOOP.

* 표준구성품
        LOOP AT LT_0220_ORD ASSIGNING <LS_0220_ORD> WHERE CHK_USE = ' '.
          ADD 1 TO LV_ORD_IDX.
          APPEND INITIAL LINE TO GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.
          MOVE-CORRESPONDING LS_MAIN_INFOR TO <LS_MAIN_DISP>. " 기존 오더 정보 세팅
*         오더 자재 구성 기준으로 세팅
          <LS_MAIN_DISP>-IDNRK2 = <LS_0220_ORD>-IDNRK.
          <LS_MAIN_DISP>-MENGE = <LS_0220_ORD>-QTY.
          SELECT SINGLE MEINS FROM MARA
            INTO <LS_MAIN_DISP>-MEINS
            WHERE MATNR = <LS_0220_ORD>-IDNRK.

          <LS_MAIN_DISP>-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_0220_ORD>-IDNRK ).
*        순번 조정을 위한 오더 인덱스
          <LS_MAIN_DISP>-INDEX = LV_ORD_IDX.
          <LS_MAIN_DISP>-COMP02 = ICON_NOT_EQUAL_RED.
        ENDLOOP.

    ENDCASE.

  ENDLOOP.

  LOOP AT GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP>.

    READ TABLE LT_REASON INTO DATA(LS_REASON) WITH KEY AUFNR = <LS_MAIN_DISP>-AUFNR
                                                                                    MATNR = <LS_MAIN_DISP>-MATNR
                                                                                    RCOMP = <LS_MAIN_DISP>-MATNR2
                                                                                    BCOMP = <LS_MAIN_DISP>-IDNRK
                                                                                    JCOMP = <LS_MAIN_DISP>-IDNRK2.
    IF SY-SUBRC EQ 0.
      <LS_MAIN_DISP>-REASON = LS_REASON-REASON.
      <LS_MAIN_DISP>-INNAM = LS_REASON-INNAM.
      <LS_MAIN_DISP>-ZCHECK = LS_REASON-ZCHECK.
      <LS_MAIN_DISP>-CHNAM = LS_REASON-CHNAM.

      IF <LS_MAIN_DISP>-INNAM IS NOT INITIAL.
        CLEAR LS_CHK_NAME.
        READ TABLE LT_CHK_NAME INTO LS_CHK_NAME WITH KEY ANNAM = <LS_MAIN_DISP>-INNAM
                                                                                         BINARY SEARCH.
        IF SY-SUBRC NE 0.
          DATA(LV_TABIX_I) = SY-TABIX.
          CLEAR LS_CHK_NAME.
          LS_CHK_NAME-ANNAM = <LS_MAIN_DISP>-INNAM.
          PERFORM GET_USER_NAME USING LS_CHK_NAME-ANNAM CHANGING LS_CHK_NAME-NAME_TEXT.
          INSERT LS_CHK_NAME INTO LT_CHK_NAME INDEX  LV_TABIX_I.
        ENDIF.

        <LS_MAIN_DISP>-NAME_TEXT2 = LS_CHK_NAME-NAME_TEXT.
      ENDIF.
      IF <LS_MAIN_DISP>-CHNAM IS NOT INITIAL.
        CLEAR LS_CHK_NAME.
        READ TABLE LT_CHK_NAME INTO LS_CHK_NAME WITH KEY ANNAM = <LS_MAIN_DISP>-CHNAM
                                                                                         BINARY SEARCH.
        IF SY-SUBRC NE 0.
          LV_TABIX_I = SY-TABIX.
          CLEAR LS_CHK_NAME.
          LS_CHK_NAME-ANNAM = <LS_MAIN_DISP>-CHNAM.
          PERFORM GET_USER_NAME USING LS_CHK_NAME-ANNAM CHANGING LS_CHK_NAME-NAME_TEXT.
          INSERT LS_CHK_NAME INTO LT_CHK_NAME INDEX  LV_TABIX_I.
        ENDIF.

        <LS_MAIN_DISP>-NAME_TEXT3 = LS_CHK_NAME-NAME_TEXT.
      ENDIF.
    ENDIF.

* 봄 구성자 추가
    READ TABLE LT_CHK_ANNAM INTO LS_CHK_ANNAM WITH KEY MATNR = <LS_MAIN_DISP>-MATNR
                                                                                     MATNR2 = <LS_MAIN_DISP>-IDNRK
                                                                                     BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      READ TABLE LT_CHK_NAME INTO LS_CHK_NAME WITH KEY ANNAM = LS_CHK_ANNAM-ANNAM
                                                                                       BINARY SEARCH.
      IF SY-SUBRC NE 0.
        LV_TABIX_I = SY-TABIX.
        CLEAR LS_CHK_NAME.
        LS_CHK_NAME-ANNAM = LS_CHK_ANNAM-ANNAM.
        PERFORM GET_USER_NAME USING LS_CHK_NAME-ANNAM CHANGING LS_CHK_NAME-NAME_TEXT.
        INSERT LS_CHK_NAME INTO LT_CHK_NAME INDEX  LV_TABIX_I.
      ENDIF.
      <LS_MAIN_DISP>-ANNAM = LS_CHK_NAME-ANNAM.
      <LS_MAIN_DISP>-NAME_TEXT = LS_CHK_NAME-NAME_TEXT.

    ENDIF.

    IF P_DIFF = ABAP_TRUE.
      IF <LS_MAIN_DISP>-COMP01 = ICON_EQUAL_GREEN AND
        <LS_MAIN_DISP>-COMP02 = ICON_EQUAL_GREEN.
        DELETE GT_MAIN_DISP.
        CONTINUE.
      ENDIF.
    ENDIF.

*  조회 조건 W/F 발신자 입력시 해당 대상 외 제외 처리
    IF S_ANNAM[] IS NOT INITIAL.
      IF <LS_MAIN_DISP>-ANNAM NOT IN S_ANNAM.
        DELETE GT_MAIN_DISP.
        CONTINUE.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_DATA>) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          SET PARAMETER ID 'ANR' FIELD <LS_DATA>-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'COMP01'.
          SET PARAMETER ID 'MAT' FIELD <LS_DATA>-MATNR.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'CSV' FIELD '1'.
          CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
        WHEN 'COMP02'.
          SUBMIT ZPPR0209   WITH P_WERKS EQ P_WERKS
                                     WITH S_DISPO IN S_DISPO
                                     WITH P_PROCD EQ 'KIT'
                                     WITH S_MATNR EQ <LS_DATA>-MATNR
                                     WITH S_DATE IN S_GSTRP
                                     AND RETURN.
      ENDCASE.
    WHEN GO_GRID_0200.
      READ TABLE GT_MAIN_DISP ASSIGNING <LS_DATA> WITH KEY AUFNR = GS_REASON-AUFNR.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          SET PARAMETER ID 'ANR' FIELD <LS_DATA>-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'COMP01'.
          SET PARAMETER ID 'MAT' FIELD <LS_DATA>-MATNR.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'CSV' FIELD '1'.
          CALL TRANSACTION 'CS03' AND SKIP FIRST SCREEN.
        WHEN 'COMP02'.
          SUBMIT ZPPR0209   WITH P_WERKS EQ P_WERKS
                                     WITH S_DISPO IN S_DISPO
                                     WITH P_PROCD EQ 'KIT'
                                     WITH S_MATNR EQ <LS_DATA>-MATNR
                                     WITH S_DATE IN S_GSTRP
                                     AND RETURN.
      ENDCASE.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_CONTAIN_0100
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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
  CASE PO_GRID.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3110TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(F01).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'TAGNR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TAGNR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'TAGNR'.
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'INDEX'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'INDEX'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'INDEX'.
    <LS_FCAT>-COL_POS = 13.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '11'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY .
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'BSTKD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '프로젝트명1'(F02).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '프로젝트명2'(F03).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매처'(F04).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(F05).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TAGNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제조번호'(F06).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '완제품자재코드'(F07).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품명'(F08).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산수량'(F09).
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업시작일'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업종료일'(F12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 BOM'(F13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BDMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'COMP01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　　'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준 BOM'(F14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'COMP02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　　'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'IDNRK2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'KIT 작업표준'(F15).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구성품명'(F16).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'REASON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차이 사유'(F18).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ANNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'W/F 발신자'(F19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME_TEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '발신자 성함'(F20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차이사유 입력자'(F21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME_TEXT2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입력자 성함'(F22).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZCHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차이 확인'(F23).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
      WHEN 'CHNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확인자'(F24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME_TEXT3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '확인자 성함'(F25).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
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
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_AUFNR
*&      <-- <LS_MAIN>_ORD_STAT
*&---------------------------------------------------------------------*
FORM GET_STATUS  USING    PV_AUFNR TYPE AUFNR
                       CHANGING PV_ORD_STAT TYPE CHAR20
                                     PV_DEL_CHK.

  DATA : LV_AUFNR TYPE AUFK-AUFNR.
  DATA : LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.
  DATA : LV_STCD TYPE ZORDSTCD.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_AUFNR
    IMPORTING
      OUTPUT = LV_AUFNR.

  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      IM_AUFNR        = LV_AUFNR
    IMPORTING
      EX_OSTCD        = LV_STCD
    TABLES
      ET_STTXT        = LT_TJ02T
    EXCEPTIONS
      NO_SELECTION    = 1
      NOT_FOUND_OBJNR = 2
      OTHERS          = 3.

*표시 우선 순위:  TECO>DLFL>CLSD>LKD>DLV>PDLV>CNF>PCNF>REL>CRTD
*출력 텍스트: 기술적마감(TECO), 삭제지시자(DLFL), 마감(CLSD), 잠금(LKD),
*입고(DLV), 부분입고(PDLV), 실적확정(CNF), 부분확정(PCNF), 릴리즈(REL),
*생성(CRTD)"

  SORT LT_TJ02T BY TXT04.

* TECO
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'TECO' BINARY SEARCH.
  IF SY-SUBRC = 0.
    IF P_TECO = ABAP_TRUE.
      PV_ORD_STAT = '기술적마감(TECO)'(t01).
    ELSE.
      PV_DEL_CHK = ABAP_TRUE.
    ENDIF.
    RETURN.
  ENDIF.

* DLFL
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'DLFL' BINARY SEARCH.
  IF SY-SUBRC = 0.
    IF P_DLFL = ABAP_TRUE.
      PV_ORD_STAT = '삭제지시자(DLFL)'(t02).
    ELSE.
      PV_DEL_CHK = ABAP_TRUE.
    ENDIF.
    RETURN.
  ENDIF.

* CLSD
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'CLSD' BINARY SEARCH.
  IF SY-SUBRC = 0.
    IF P_CLSD = ABAP_TRUE.
      PV_ORD_STAT = '마감(CLSD)'(t03).
    ELSE.
      PV_DEL_CHK = ABAP_TRUE.
    ENDIF.
    RETURN.
  ENDIF.

* LKD
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'LKD' BINARY SEARCH.
  IF SY-SUBRC = 0.
    IF P_LKD = ABAP_TRUE.
      PV_ORD_STAT = '잠금(LKD)'(t04).
    ELSE.
      PV_DEL_CHK = ABAP_TRUE.
    ENDIF.
    RETURN.
  ENDIF.

* DLV
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'DLV' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '입고(DLV)'(t05).
    RETURN.
  ENDIF.

* PDLV
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'PDLV' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '부분입고(PDLV)'(t06).
    RETURN.
  ENDIF.

* CNF
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'CNF' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '실적확정(CNF)'(t07).
    RETURN.
  ENDIF.

* PCNF
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'PCNF' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '부분확정(PCNF)'(t08).
    RETURN.
  ENDIF.

* REL
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'REL' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '릴리즈(REL)'(t09).
    RETURN.
  ENDIF.

* CRTD
  READ TABLE LT_TJ02T TRANSPORTING NO FIELDS WITH KEY TXT04 = 'CRTD' BINARY SEARCH.
  IF SY-SUBRC = 0.
    PV_ORD_STAT = '생성(CRTD)'(t10).
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BOM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_STB
*&      --> <LS_MAIN>_GAMNG
*&      --> <LS_MAIN>_MATNR
*&---------------------------------------------------------------------*
FORM GET_BOM_DATA  TABLES   PT_STB STRUCTURE STPOX
                                  USING    PV_GAMNG TYPE AFKO-GAMNG
                                              PV_MATNR TYPE MATNR.

  DATA : LV_EMENG TYPE STKO-BMENG.
  LV_EMENG = PV_GAMNG.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PV_MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
    TABLES
      STB                   = PT_STB[]
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TAGNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_AUFNR
*&      --> LS_MAIN_MATNR
*&      <-- LS_MAIN_INFOR_TAGNR
*&---------------------------------------------------------------------*
FORM GET_TAGNR  USING    PV_AUFNR TYPE AUFNR
                                       PV__MATNR TYPE MATNR
                     CHANGING     PV_TAGNR.

  SELECT SINGLE MIN( TAGNR )
        FROM ZPPT0211
      WHERE AUFNR = @PV_AUFNR
          AND MATNR = @PV__MATNR
        GROUP BY AUFNR
    INTO @DATA(LV_MIN_TAGNR).

  SELECT SINGLE MAX( TAGNR )
          FROM ZPPT0211
        WHERE AUFNR = @PV_AUFNR
            AND MATNR = @PV__MATNR
          GROUP BY AUFNR
      INTO @DATA(LV_MAX_TAGNR).

  IF LV_MAX_TAGNR = LV_MIN_TAGNR.
    PV_TAGNR = LV_MAX_TAGNR.
    RETURN.
  ENDIF.

  PV_TAGNR = LV_MIN_TAGNR.
  IF LV_MAX_TAGNR IS NOT INITIAL.
    SPLIT LV_MAX_TAGNR AT '-' INTO TABLE DATA(LT_STRING).
    IF SY-SUBRC EQ 0.
      DATA(LV_IDX) = LINES( LT_STRING ).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX LV_IDX.
      CONCATENATE PV_TAGNR '~' LS_STRING INTO PV_TAGNR SEPARATED BY SPACE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA(LT_CHK_MAIN) = GT_MAIN_DISP.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    REFRESH LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FIELDCAT).
      CASE ABAP_TRUE.
        WHEN P_ORDNO.
          CASE LS_FIELDCAT-FIELDNAME.
            WHEN 'MATNR2' OR 'BDMNG'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
        WHEN P_BOM.
          CASE LS_FIELDCAT-FIELDNAME.
            WHEN 'IDNRK' OR 'MENGE'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
      ENDCASE.
    ENDLOOP.
    <LS_MAIN_DISP>-CELLTAB = LT_CELLTAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'AUFNR'  'X' '' '',
                                       2 'INDEX'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_disp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  IF GT_MAIN_DISP[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    WHEN GO_GRID_0200.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_CONTAIN_0200
    EXPORTING
      CONTAINER_NAME              = 'CONTAINER_0200'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  CLEAR GS_LAYOUT_0200.
*  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0200-SEL_MODE   = 'C'.
  GS_LAYOUT_0200-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3110TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_0200'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_DISP_0200
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0200 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'INDEX'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'INDEX'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'INDEX'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '11'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY .
    <LS_FCAT>-COL_OPT = ABAP_TRUE.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(F05).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '완제품자재코드'(F07).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품명'(F08).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 BOM'(F13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BDMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'COMP01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　　'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준 BOM'(F14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'COMP02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　　'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'IDNRK2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'KIT 작업표준'(F15).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　' && '수량'(F17).
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구성품명'(F16).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'REASON'.
        CLEAR <LS_FCAT>-COL_OPT.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차이 사유'(F18).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-OUTPUTLEN = 30.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'CHK_CHG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0200 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.


  LOOP AT GT_DISP_0200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    REFRESH LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0200 INTO DATA(LS_FIELDCAT).
      CASE LS_FIELDCAT-FIELDNAME.
        WHEN 'AUFNR' OR 'MAKTX'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.

      CASE ABAP_TRUE.
        WHEN P_ORDNO.
          CASE LS_FIELDCAT-FIELDNAME.
            WHEN 'MATNR2' OR 'BDMNG'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
        WHEN P_BOM.
          CASE LS_FIELDCAT-FIELDNAME.
            WHEN 'IDNRK' OR 'MENGE'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
      ENDCASE.
    ENDLOOP.
    <LS_MAIN_DISP>-CELLTAB = LT_CELLTAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_DISP_0200
      IT_SORT              = GT_SORT_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_INPUT .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  DELETE LT_CELLS WHERE ROW_ID = 0.
  SORT  LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING  ROW_ID.

  CLEAR GS_REASON.

  REFRESH GT_MAIN_CHK.

  REFRESH GT_DISP_0200.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>) INDEX LS_CELLS-ROW_ID.
    APPEND INITIAL LINE TO GT_DISP_0200 ASSIGNING FIELD-SYMBOL(<LS_DISP_0200>).
    MOVE-CORRESPONDING <LS_MAIN_DISP> TO <LS_DISP_0200>.

  ENDLOOP.

  CLEAR GV_CHK_CHG.
  CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 191 25.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORDER_INFOR .

  CLEAR : GS_REASON-MATNR, GS_REASON-MAKTX, GS_REASON-REASON.

  CHECK GS_REASON-AUFNR IS NOT INITIAL.

  READ TABLE GT_MAIN_CHK INTO DATA(LS_MAIN_DISP) WITH KEY  AUFNR = GS_REASON-AUFNR.
  IF SY-SUBRC EQ 0.
    GS_REASON-MATNR = LS_MAIN_DISP-MATNR.
    GS_REASON-MAKTX = LS_MAIN_DISP-MAKTX.
  ENDIF.

  SELECT SINGLE REASON FROM ZGTPPT3250
   WHERE WERKS = @P_WERKS
       AND AUFNR = @GS_REASON-AUFNR
      INTO @GS_REASON-REASON.

  REFRESH GT_DISP_0200.

  IF GS_REASON-AUFNR IS NOT INITIAL.
    LOOP AT GT_MAIN_CHK ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>) WHERE AUFNR = GS_REASON-AUFNR.
      APPEND INITIAL LINE TO GT_DISP_0200 ASSIGNING FIELD-SYMBOL(<LS_DISP_0200>).
      MOVE-CORRESPONDING <LS_MAIN_DISP> TO <LS_DISP_0200>.
    ENDLOOP.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_REASON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_REASON .

*  CHECK GS_REASON-AUFNR IS NOT INITIAL.
  DATA : BEGIN OF LS_CHK_BP,
           BPID      TYPE STPOX-ANNAM,
           NAME_TEXT LIKE USER_ADDR-NAME_TEXTC,
         END OF LS_CHK_BP.
  DATA : LT_CHK_BP LIKE TABLE OF LS_CHK_BP.
  DATA : LV_TABIX TYPE SY-TABIX.
  DATA : LT_ZGTPPT3250_SAVE TYPE TABLE OF ZGTPPT3250.

  LOOP AT GT_DISP_0200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>) WHERE CHK_CHG IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_ZGTPPT3250_SAVE ASSIGNING FIELD-SYMBOL(<LS_ZGTPPT3250_SAVE>).
    <LS_ZGTPPT3250_SAVE>-WERKS = P_WERKS.
    <LS_ZGTPPT3250_SAVE>-AUFNR = <LS_MAIN_DISP>-AUFNR.
    <LS_ZGTPPT3250_SAVE>-MATNR = <LS_MAIN_DISP>-MATNR.
    <LS_ZGTPPT3250_SAVE>-RCOMP = <LS_MAIN_DISP>-MATNR2.
    <LS_ZGTPPT3250_SAVE>-BCOMP = <LS_MAIN_DISP>-IDNRK.
    <LS_ZGTPPT3250_SAVE>-JCOMP = <LS_MAIN_DISP>-IDNRK2.
    <LS_ZGTPPT3250_SAVE>-REASON = <LS_MAIN_DISP>-REASON.
    <LS_ZGTPPT3250_SAVE>-INNAM = SY-UNAME.

    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WITH KEY AUFNR = <LS_MAIN_DISP>-AUFNR
                                                                                                          MATNR = <LS_MAIN_DISP>-MATNR
                                                                                                          MATNR2 = <LS_MAIN_DISP>-MATNR2
                                                                                                          IDNRK = <LS_MAIN_DISP>-IDNRK
                                                                                                          IDNRK2 = <LS_MAIN_DISP>-IDNRK2.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-REASON = <LS_MAIN_DISP>-REASON.
      <LS_MAIN>-INNAM = SY-UNAME.
      READ TABLE LT_CHK_BP INTO LS_CHK_BP WITH KEY BPID = <LS_MAIN>-INNAM
                                                                            BINARY SEARCH.
      IF SY-SUBRC NE 0.
        LV_TABIX = SY-TABIX.
        LS_CHK_BP-BPID = <LS_MAIN>-INNAM.
        PERFORM GET_USER_NAME USING LS_CHK_BP-BPID CHANGING LS_CHK_BP-NAME_TEXT.
        <LS_MAIN>-NAME_TEXT2 = LS_CHK_BP-NAME_TEXT.
      ELSE.
        <LS_MAIN>-NAME_TEXT2 = LS_CHK_BP-NAME_TEXT.
      ENDIF.
    ENDIF.

  ENDLOOP.

  MODIFY ZGTPPT3250 FROM TABLE LT_ZGTPPT3250_SAVE.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM WRITE_ALL .

  GV_CHK_CHG = ABAP_TRUE.

  LOOP AT GT_DISP_0200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    <LS_MAIN_DISP>-REASON = GS_REASON-REASON.
    <LS_MAIN_DISP>-CHK_CHG = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
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
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'REASON'.
            GV_CHK_CHG = ABAP_TRUE.
            __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHK_CHG' ABAP_TRUE.
        ENDCASE.
      ENDLOOP.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0200 .

  REFRESH GT_SORT_0200.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0200
                            USING : 1 'AUFNR'  'X' '' '',
                                       2 'MAKTX'  'X' '' '',
                                       3 'INDEX'  'X' '' ''.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_USER_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_NAME_ANNAM
*&      <-- LS_CHK_NAME_NAME_TEXT
*&---------------------------------------------------------------------*
FORM GET_USER_NAME  USING    PV_ANNAM TYPE SY-UNAME
                    CHANGING PV_NAME_TEXT.

  DATA : LS_USER_ADDR  TYPE USER_ADDR.

  CALL FUNCTION 'FKK_GET_USER_NAME'
    EXPORTING
      I_UNAME     = PV_ANNAM
    IMPORTING
      E_USER_ADDR = LS_USER_ADDR.
  IF LS_USER_ADDR IS NOT INITIAL.
    PV_NAME_TEXT = LS_USER_ADDR-NAME_TEXTC.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CONFIRM .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CHK_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : BEGIN OF LS_CHK_BP,
           BPID      TYPE STPOX-ANNAM,
           NAME_TEXT LIKE USER_ADDR-NAME_TEXTC,
         END OF LS_CHK_BP.
  DATA : LT_CHK_BP LIKE TABLE OF LS_CHK_BP.
  DATA : LV_TABIX TYPE SY-TABIX.
  DATA : LV_CHK_CONFIRM.


  GO_GRID_0100->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  DELETE LT_CELLS WHERE ROW_ID = 0.
  SORT  LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING  ROW_ID.

  CLEAR GS_REASON.
  CLEAR LV_CHK_CONFIRM.
  REFRESH LT_CHK_MAIN.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>) INDEX LS_CELLS-ROW_ID.
    IF <LS_MAIN_DISP>-REASON IS NOT INITIAL.
      IF <LS_MAIN_DISP>-ZCHECK IS NOT INITIAL.
        LV_CHK_CONFIRM = ABAP_TRUE.
        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO LT_CHK_MAIN ASSIGNING FIELD-SYMBOL(<LS_CHK_MAIN>).
      MOVE-CORRESPONDING <LS_MAIN_DISP> TO <LS_CHK_MAIN> .
    ENDIF.
  ENDLOOP.

  IF LV_CHK_CONFIRM IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '이미 확인 처리된 라인이 있습니다.'(M10).
    RETURN.
  ENDIF.

  IF LT_CHK_MAIN[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택 라인 중 등록된 차이 내역이 없습니다.'(M09).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '차이 내역을 확인하고 확인 등록합니다. 계속 진행 하시겠습니까?'(M07)
    '등록확인'(M08).
  IF GV_ANSWER NE 'J'.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO LS_CELLS.
    READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN_DISP> INDEX LS_CELLS-ROW_ID.
    IF <LS_MAIN_DISP>-REASON IS NOT INITIAL.
      <LS_MAIN_DISP>-ZCHECK = ABAP_TRUE.
      <LS_MAIN_DISP>-CHNAM = SY-UNAME.

      READ TABLE LT_CHK_BP INTO LS_CHK_BP WITH KEY BPID = <LS_MAIN_DISP>-CHNAM
                                                                            BINARY SEARCH.
      IF SY-SUBRC NE 0.
        LV_TABIX = SY-TABIX.
        LS_CHK_BP-BPID = <LS_MAIN_DISP>-CHNAM.
        PERFORM GET_USER_NAME USING LS_CHK_BP-BPID CHANGING LS_CHK_BP-NAME_TEXT.
        <LS_MAIN_DISP>-NAME_TEXT3 = LS_CHK_BP-NAME_TEXT.
      ELSE.
        <LS_MAIN_DISP>-NAME_TEXT3 = LS_CHK_BP-NAME_TEXT.
      ENDIF.

*      로그테이블 저장
      PERFORM SET_LOG_CONFIRM USING <LS_MAIN_DISP>.
    ENDIF.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN_DISP>
*&---------------------------------------------------------------------*
FORM SET_LOG_CONFIRM  USING    PS_MAIN_DISP LIKE GS_MAIN_DISP.

  DATA : LS_ZGTPPT3250_SAVE TYPE ZGTPPT3250.

  SELECT SINGLE * FROM ZGTPPT3250
    WHERE WERKS = @P_WERKS
        AND AUFNR = @PS_MAIN_DISP-AUFNR
        AND MATNR = @PS_MAIN_DISP-MATNR
        AND RCOMP = @PS_MAIN_DISP-MATNR2
        AND BCOMP = @PS_MAIN_DISP-IDNRK
        AND JCOMP = @PS_MAIN_DISP-IDNRK2
        AND REASON IS NOT INITIAL
      INTO CORRESPONDING FIELDS OF @LS_ZGTPPT3250_SAVE.

  IF SY-SUBRC EQ 0.
    LS_ZGTPPT3250_SAVE-ZCHECK = ABAP_TRUE.
    LS_ZGTPPT3250_SAVE-CHNAM = SY-UNAME.
    MODIFY ZGTPPT3250 FROM LS_ZGTPPT3250_SAVE.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

ENDFORM.
