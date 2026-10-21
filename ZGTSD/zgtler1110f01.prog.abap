*&---------------------------------------------------------------------*
*& Include          ZGTLER1110F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INIT_PARAMETER .
  TYPE-POOLS: VRM.
  DATA: LV_NAME  TYPE VRM_ID,
        LT_LIST  TYPE VRM_VALUES,
        LS_VALUE LIKE LINE OF LT_LIST.

  CLEAR   : S_ERDAT, LT_LIST.
  REFRESH : S_ERDAT, LT_LIST.

*___출하요청 생성일
  S_ERDAT-SIGN     = 'I'.
  S_ERDAT-OPTION   = 'BT'.
*  S_ERDAT-LOW      = SY-DATLO - 60.
  S_ERDAT-LOW      = SY-DATLO.
  S_ERDAT-LOW+6(2) = '01'.
  S_ERDAT-HIGH     = SY-DATLO.
  APPEND S_ERDAT.

*___운송유형
  LV_NAME = 'P_TRTYP'.

  LS_VALUE-KEY  = '00'.
  LS_VALUE-TEXT = '전체'.
  APPEND LS_VALUE TO LT_LIST.

  SELECT A~DOMVALUE_L
         B~DDTEXT
    INTO (LS_VALUE-KEY, LS_VALUE-TEXT)
    FROM DD07L AS A
   INNER JOIN DD07T AS B
      ON A~DOMNAME = B~DOMNAME
     AND B~DDLANGUAGE = SY-LANGU
     AND A~AS4LOCAL   = B~AS4LOCAL
     AND A~VALPOS     = B~VALPOS
     AND A~AS4VERS    = B~AS4VERS
   WHERE A~DOMNAME = 'ZDTRTYP'.

    APPEND LS_VALUE TO LT_LIST.

  ENDSELECT.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = LV_NAME
      VALUES = LT_LIST.

*-재고조회 저장위치
  CLEAR:GR_LGORT,GR_LGORT[].
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3410' ) TO GR_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3420' ) TO GR_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3430' ) TO GR_LGORT.

*-특성값
  CLEAR:GR_ATNAM[],GR_ATNAM.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_JOBNO ) TO GR_ATNAM.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LENGTH ) TO GR_ATNAM.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_CBASE ) TO GR_ATNAM.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_INSCD ) TO GR_ATNAM.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_SKID ) TO GR_ATNAM.

*-출하요청 확정(직납)
  CLEAR:GR_LGORT_DIR,GR_LGORT_DIR[].
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3497' ) TO GR_LGORT_DIR.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = '3498' ) TO GR_LGORT_DIR.


ENDFORM.                    " SET_INIT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHRIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_AUTHRIZATION .
  DATA: LV_SUBRC    LIKE SY-SUBRC.

  CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
    EXPORTING
      I_VSTEL = P_VSTEL
      I_TYPE  = '3'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E002 WITH '출하지점에 대한 권한이 없습니다.'.
  ENDIF.

*-영업그룹
  SELECT VKGRP
    FROM TVBVK
   WHERE VKGRP IN @S_VKGRP
    INTO TABLE @DATA(LT_VKGRP).

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'
      EXPORTING
        I_VKGRP = LS_VKGRP-VKGRP
        I_TYPE  = '7'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E004 WITH '영업그룹' LS_VKGRP-VKGRP
                        '에 대한 권한이 없습니다.'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_AUTHRIZATION
*&---------------------------------------------------------------------*
*&      Form  GET_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DELIVERY_REQ_DATA .
  RANGES: LR_KDKG4  FOR  VBKD-KDKG4,
          LR_TRTYP  FOR  ZLET0400-TRTYP.
  DATA : LV_DATE LIKE SY-DATUM.
  DATA : LV_NTGEW  LIKE MARA-NTGEW.

  DATA : LV_LGORT_CHK(1).

  CLEAR   : GT_MAIN, GT_0401, LR_KDKG4, LR_TRTYP,GT_LSTOCK_ITEM,GT_LSTOCK_DETAIL,
            GT_ESTOCK_ITEM,GT_ESTOCK_DETAIL.
  REFRESH : GT_MAIN, GT_0401, LR_KDKG4, LR_TRTYP,GT_LSTOCK_ITEM,GT_LSTOCK_DETAIL,
            GT_ESTOCK_ITEM,GT_ESTOCK_DETAIL.

  CASE 'X'.
    WHEN P_R12.      "내수/로컬
      SET_RANGES: LR_KDKG4 'I' 'EQ' '4D' ' ',
                  LR_KDKG4 'I' 'EQ' '4L' ' '.

    WHEN P_R13.      "수출
      SET_RANGES: LR_KDKG4 'I' 'EQ' '4E' ' ',
                  LR_KDKG4 'I' 'EQ' '4S' ' '.

    WHEN OTHERS.    "전체

  ENDCASE.

  IF P_TRTYP <> '00'.
    SET_RANGES: LR_TRTYP 'I' 'EQ' P_TRTYP ' '.
  ENDIF.

  SELECT A~DLVRQ,            "출하요청번호
         B~VBELN,            "판매오더
         B~POSNR,            "판매오더품목
*         i~vgbel,            "납품문서
*         i~vgpos,            "납품문서품목
         A~AUART,            "오더유형
         A~KUNWE,            "납품처
         A~KUNAG,            "판매처
         A~KDKG4,            "내수/수출
         B~SOBKZ,            "특별재고지시자
         B~MATNR,            "자재
         B~KWMENG,           "오더수량
         B~VRKME,            "판매단위
         B~INDLEN,           "조장
         B~INDQTY,           "조장수
*         C~VSTEL            "출하지점
         A~VSTEL,            "출하지점
         B~WERKS,            "플랜트
         A~SPART,            "제품군
         A~POST_CODE1,       "우편번호
         A~LAND1,            "국가
         A~LZONE,            "운송지역
         CONCAT( A~CITY1, A~STREET ) AS ADDRESS,
         A~CITY1,            "상세주소
         A~STREET,           "상세주소2
         A~EXTENSION1,       "수령인
         A~TEL_NUMBER,       "연락처
         A~ARIND,            "도착시간 입력 여부
         A~ARRDT,            "도착일
         A~ARRTM,            "도착시간
         A~IMMDT,            "긴급출하
         A~ALONE,            "단독여부(혼적)
         A~VHCTP,            "차량제한여부
         A~BKNFT,            "왕복여부
         A~DIVID,            "분할출하
         A~ZREQ_TYPE,        "직송의뢰 신청 유형
         A~TRTYP,            "운송유형
         B~EDATU,            "납품일정
         B~DLRMG,            "출하요청수량
         B~REVIW,            "출하검토여부
         B~REVMG,            "출하검토수량
         B~LECFM,            "출하확정
         B~SDCFM,            "영업확정
         A~REMARK,           "비고
         A~LVORM AS HLVORM,  "삭제지시자(헤더)
         B~LVORM AS ILVORM,  "삭제지시자(품목)

         C~FIXMG,            "MTO/MTS 구분기준

         A~ZREMARK1,         "출하실요청사항

         C~MVGR3,            "정조장여부 판단
         D~BSTKD_E,
*         b~aenam,
         CASE WHEN B~LECFM IS NOT INITIAL AND
                   A~LVORM IS INITIAL AND
                   B~LVORM IS INITIAL
              THEN F~NAME_LAST ELSE @SPACE END AS CFM_NAME,

         F~NAME_LAST AS REQNAM "출하요청자

    FROM ZLET0400 AS A INNER JOIN ZLET0401 AS B
                       ON A~DLVRQ =  B~DLVRQ
                       INNER JOIN VBAP AS C
                       ON B~VBELN =  C~VBELN AND
                          B~POSNR =  C~POSNR
                       LEFT JOIN VBKD AS D
                       ON B~VBELN EQ D~VBELN
                       AND B~POSNR EQ D~POSNR

                       LEFT JOIN USR21 AS E
                       ON B~AENAM EQ E~BNAME
                       LEFT JOIN ADRP AS F
                       ON E~PERSNUMBER EQ F~PERSNUMBER

                       LEFT JOIN USR21 AS G
                       ON A~ERNAM EQ G~BNAME
                       LEFT JOIN ADRP AS H
                       ON G~PERSNUMBER EQ H~PERSNUMBER

*                       LEFT JOIN zlet0402 AS i
*                       ON  b~dlvrq EQ i~dlvrq
*                       AND b~vbeln EQ i~vbeln
*                       AND b~posnr EQ i~posnr
   WHERE A~VKORG EQ @GC_VKORG
     AND A~DLVRQ IN @S_DLVRQ
     AND A~ERDAT IN @S_ERDAT
     AND A~TRTYP IN @LR_TRTYP
     AND B~EDATU IN @S_EDATU
     AND A~VKBUR IN @S_VKBUR
     AND A~VKGRP IN @S_VKGRP
     AND A~KUNAG IN @S_KUNAG
     AND A~KUNWE IN @S_KUNWE
     AND B~VBELN IN @S_VBELN
     AND A~VSTEL EQ @P_VSTEL
*     AND C~VSTEL EQ P_VSTEL
     AND A~SPART IN @S_SPART
     AND B~WERKS IN @S_WERKS
     AND B~MATNR IN @S_MATNR
     AND A~KDKG4 IN @LR_KDKG4
     AND A~PERNR IN @S_PERNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_MAIN.

  DATA : LT_MAIN LIKE TABLE OF GT_MAIN WITH EMPTY KEY.
  LT_MAIN[] = CORRESPONDING #( GT_MAIN[] ).

  WITH +SO_INFO AS ( SELECT A~VBELN, A~POSNR
                       FROM @LT_MAIN AS A
                      GROUP BY A~VBELN, A~POSNR )

     SELECT A~VGBEL,  A~VGPOS,  A~LGORT, C~IV_NO
       FROM LIPS AS A INNER JOIN +SO_INFO AS B
                         ON A~VGBEL EQ B~VBELN
                        AND A~VGPOS EQ B~POSNR
                       LEFT OUTER JOIN ZGTSD_I_VALID_INV_ITEM AS C
                         ON A~VBELN EQ C~VBELN
                        AND A~POSNR EQ C~POSNR
      ORDER BY A~VGBEL, A~VGPOS

       INTO TABLE @DATA(LT_DO_INFO).

*  WITH +do_info AS ( SELECT vgbel
*                      FROM @lt_main AS a
*                     GROUP BY vgbel )
*     SELECT a~vgbel, b~iv_no
*       FROM +do_info AS a INNER JOIN zgtsd_i_valid_inv_item AS b
*                          ON a~vgbel EQ b~vbeln
*      WHERE b~iv_no NE @abap_false
*     GROUP BY a~vgbel, b~iv_no
*      INTO TABLE @DATA(lt_iv).

*->>[LINK 조장수]--------------------------------2026.07.13 S
  PERFORM GET_LINK_JOJANG.
*-<<[LINK 조장수]--------------------------------2026.07.13 E


  LOOP AT GT_MAIN.
    DATA(LV_INDEX) = SY-TABIX.
    CLEAR:LV_LGORT_CHK,GV_LGORT_M.

*___출하/영업 확정 선택조건
    IF ( P_R22 = 'X' AND ( GT_MAIN-LECFM =  'CM'      OR
                           GT_MAIN-LECFM =  'CS'      OR
                           GT_MAIN-SDCFM =  'CM'      OR
                           GT_MAIN-SDCFM =  'CS'  ) ) OR
       ( P_R23 = 'X' AND ( GT_MAIN-LECFM <> 'CM'      AND
                           GT_MAIN-LECFM <> 'CS'      AND
                           GT_MAIN-SDCFM <> 'CM'      AND
                           GT_MAIN-SDCFM <> 'CS' ) ).
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.

*___삭제여부 선택조건
    IF P_R31 = 'X' AND ( GT_MAIN-HLVORM = 'X' OR
                         GT_MAIN-ILVORM = 'X' ).
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.

*___판매오더 특성 - 제조지시번호
    GT_MAIN-JOBNO = GT_MAIN-BSTKD_E.

**--- 거래명세서 번호
*    READ TABLE LT_IV INTO DATA(LS_IV) WITH KEY VGBEL = GT_MAIN-VGBEL.
*    IF SY-SUBRC EQ 0.
*      GT_MAIN-IV_NO = LS_IV-IV_NO.
*    ENDIF.
*    PERFORM GET_ORDER_JOBNO(ZLER0401) USING GT_MAIN-VBELN
*                                            GT_MAIN-POSNR
*                                            GT_MAIN-JOBNO.
*
*    IF GT_MAIN-JOBNO NOT IN S_JOBNO.
*      DELETE GT_MAIN.
*      CONTINUE.
*    ENDIF.

*___포장재(드럼)기호
    PERFORM GET_PACK_DM     USING GT_MAIN-VBELN
                                  GT_MAIN-POSNR
                                  GT_MAIN-PACK_CAT
                                  GT_MAIN-DRUM_NO
                                  GT_MAIN-PACKDM.


*___납품생성수량(출하요청)
    SELECT SUM( B~LFIMG )
      INTO GT_MAIN-LFIMG_DR
      FROM ZLET0402 AS A
     INNER JOIN LIPS AS B
        ON A~VGBEL = B~VBELN
     WHERE A~DLVRQ = GT_MAIN-DLVRQ
       AND A~VBELN = GT_MAIN-VBELN
       AND A~POSNR = GT_MAIN-POSNR
       AND ( A~VGPOS = B~POSNR
          OR A~VGPOS = B~UECHA ).

*___출하잔량 = 출하요청수량 - 납품생성수량
    IF GT_MAIN-DLRMG > GT_MAIN-LFIMG_DR.
      GT_MAIN-REMMG = GT_MAIN-DLRMG - GT_MAIN-LFIMG_DR.
    ENDIF.

*___납품생성 수량(판매오더)
    SELECT SUM( LFIMG )
      INTO GT_MAIN-LFIMG
      FROM LIPS
     WHERE VGBEL = GT_MAIN-VBELN
       AND VGPOS = GT_MAIN-POSNR.

*___오더잔량 = 오더수량 - 납품생성수량
    IF GT_MAIN-KWMENG > GT_MAIN-LFIMG.
      GT_MAIN-ODREM = GT_MAIN-KWMENG - GT_MAIN-LFIMG.
    ENDIF.

    IF GT_MAIN-HLVORM IS INITIAL AND GT_MAIN-ILVORM IS INITIAL AND
       GT_MAIN-LECFM  <> 'CM'    AND GT_MAIN-LECFM  <> 'CS'    AND
       GT_MAIN-ODREM  IS INITIAL.
      GT_MAIN-LECFM = 'CS'.

*___확정(시스템) Flag 'CS' 입력 대상
      CLEAR : GT_0401.
      "납품수량
      GT_0401-REVMG = GT_MAIN-LFIMG.
*      PERFORM GET_DELIVERY_QTY CHANGING GT_MAIN.
      GT_0401-DLVRQ = GT_MAIN-DLVRQ.
      GT_0401-VBELN = GT_MAIN-VBELN.
      GT_0401-POSNR = GT_MAIN-POSNR.
      GT_0401-LECFM = 'CS'.
      COLLECT GT_0401.
    ENDIF.

*   출하지점 '*98' => 저장위치 DEFAULT
    IF GT_MAIN-HLVORM IS INITIAL AND GT_MAIN-ILVORM IS INITIAL AND
       GT_MAIN-LECFM  NE 'CM'    AND GT_MAIN-LECFM  NE 'CS'.
      IF GT_MAIN-VSTEL+2(2) EQ '98'.
*        GT_MAIN-LGORT = '3498'.
        CASE GT_MAIN-ZREQ_TYPE.
          WHEN 'A'.
            GT_MAIN-LGORT = '3498'.
            LV_LGORT_CHK = GC_X.
          WHEN 'B'.
            GT_MAIN-LGORT = '3497'.
            LV_LGORT_CHK = GC_X.
        ENDCASE.

      ENDIF.
    ENDIF.

*___여신관리:리스크범주
    SELECT SINGLE CTLPC
      INTO GT_MAIN-CTLPC
      FROM VBAK
     WHERE VBELN = GT_MAIN-VBELN.

*___MTO/MTS
    IF GT_MAIN-FIXMG IS NOT INITIAL.
      GT_MAIN-SOTXT = 'MTS'.
    ELSE.
      GT_MAIN-SOTXT = 'MTO'.
    ENDIF.
*    IF GT_MAIN-SOBKZ IS NOT INITIAL.
*      GT_MAIN-SOTXT = 'MTO'.
*    ELSE.
*      GT_MAIN-SOTXT = 'MTS'.
*    ENDIF.

*___조장
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_LENGTH
                                                  GT_MAIN-INDLEN.

*___색상
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_CBASE
                                                  GT_MAIN-COLOR.
*[S] 안정화 GW20260825001
*___색상[STRIPE]
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_STRIP
                                                  GT_MAIN-STRIP.

*___색상수 [STRIPE NO]
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_STRIPNO
                                                  GT_MAIN-STRIPNO.

*___절연선심식별 코드
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_INSCD
                                                  GT_MAIN-INSCD.

*___PO번호/PO일자
    PERFORM GET_CUSTOMER_PO(ZLER0401)
      USING GT_MAIN-VBELN
            GT_MAIN-POSNR
            GT_MAIN-BSTKD
            GT_MAIN-BSTDK
            GT_MAIN-EMPST.

    IF GT_MAIN-VSTEL+2(2) NE '98'.
      READ TABLE LT_DO_INFO WITH KEY VGBEL = GT_MAIN-VBELN
                                     VGPOS = GT_MAIN-POSNR
                            INTO DATA(LS_DO_INFO).
      IF SY-SUBRC EQ 0.
        GT_MAIN-LGORT = LS_DO_INFO-LGORT.
      ENDIF.
    ENDIF.



*___가용재고/품질재고
    PERFORM GET_STOCK_DATA USING GT_MAIN-MATNR
                                 GT_MAIN-VSTEL
                                 GT_MAIN-WERKS
                                 GT_MAIN-LGORT
                                 GT_MAIN-VBELN
                                 GT_MAIN-POSNR
                                 GT_MAIN-SOBKZ
                                 GT_MAIN-VRKME
                                 GT_MAIN-LABST
                                 GT_MAIN-INSME
                                 GT_MAIN-LECFM
                                 GT_MAIN-SDCFM
                                 GT_MAIN-ZREQ_TYPE
                                 LV_LGORT_CHK.

    IF GV_LGORT_M EQ 'X'. "재고 저장위치가 MULTI
      GT_MAIN-STSTA = ICON_CHECKED.
    ELSE.
      IF GT_MAIN-AUART <> 'RE' AND GT_MAIN-AUART <> 'ZREQ'.
*___재고상태
        IF GT_MAIN-LABST >= GT_MAIN-DLRMG.
          GT_MAIN-STSTA = '@5B@'.      "ICON_LED_GREEN
        ELSEIF GT_MAIN-LABST IS INITIAL.
          GT_MAIN-STSTA = '@5C@'.      "ICON_LED_RED
        ELSE.
          GT_MAIN-STSTA = '@5D@'.      "ICON_LED_YELLOW
        ENDIF.
      ENDIF.
    ENDIF.

*___출하확정수량 - 기본값
    IF GT_MAIN-SDCFM <> 'CM' AND
       GT_MAIN-LECFM <> 'CS' AND
       GT_MAIN-LECFM <> 'CM'.

      IF GT_MAIN-REVIW <> 'X'.
        IF GT_MAIN-LABST >= GT_MAIN-REMMG.
          GT_MAIN-REVMG = GT_MAIN-REMMG.
        ELSE.
          GT_MAIN-REVMG = GT_MAIN-LABST.
        ENDIF.

      ENDIF.

    ELSE.
      CLEAR GT_MAIN-REVMG.
    ENDIF.

*___출하요청/검토 조장수
    IF GT_MAIN-INDLEN IS NOT INITIAL.
      GT_MAIN-DRIND = GT_MAIN-DLRMG / GT_MAIN-INDLEN.
      GT_MAIN-RVIND = GT_MAIN-REVMG / GT_MAIN-INDLEN.
    ENDIF.

*___출하검토상태
    IF GT_MAIN-REVIW IS NOT INITIAL.
      IF GT_MAIN-REVMG >= GT_MAIN-DLRMG.
        GT_MAIN-RVSTA = 'CM'.          "검토완료
      ELSE.
        IF GT_MAIN-DIVID = 'X'.
          GT_MAIN-RVSTA = 'P'.         "분할납품/검토
        ELSE.
          GT_MAIN-RVSTA = 'C'.         "검토
        ENDIF.
      ENDIF.
    ENDIF.

*   정조장인 경우: 재고상태 = 녹색,저장위치 = 3410
    IF GT_MAIN-MVGR3 EQ 'X'.

*      GT_MAIN-MVGR3 = 'O'.    "정재고 여부 표시
      "재고상태
      GT_MAIN-STSTA = '@5B@'. "ICON_LED_GREEN
      "저장위치
      GT_MAIN-LGORT = '3410'.

*      "출하확정조장수
*      GT_MAIN-RVIND = GT_MAIN-DRIND.
*      "출하확정수량
*      GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.

      "출하잔량이 있는경우
      IF GT_MAIN-REMMG > 0. "출하잔량
        "출하확정수량
        GT_MAIN-REVMG = GT_MAIN-REMMG.
        "출하확정조장수
        GT_MAIN-RVIND = GT_MAIN-REVMG / GT_MAIN-INDLEN.
      ELSE.
        CLEAR:GT_MAIN-REVMG,GT_MAIN-RVIND.
      ENDIF.

    ENDIF.

*   부분 정조장
    DATA:LV_INDSUM LIKE ZLET0401-INDQTY,
         LV_INDREM LIKE ZLET0401-INDQTY.
    IF GT_MAIN-MVGR3 EQ 'Y'.
      IF GT_MAIN-LECFM NE 'CM' AND
         GT_MAIN-LECFM NE 'CS'.

        "SALES ORDER STOCK 조장수
        DATA(LS_SSTOCK) = VALUE #( GT_ESTOCK_ITEM[ VBELN = GT_MAIN-VBELN
                                                   POSNR = GT_MAIN-POSNR ] OPTIONAL ).
        IF LS_SSTOCK IS NOT INITIAL.
          LV_INDSUM = LV_INDSUM + LS_SSTOCK-ESTOCK.
        ENDIF.
        "LINK 조장수
        DATA(LS_LSTOCK) = VALUE #( GT_LSTOCK_ITEM[ VBELN = GT_MAIN-VBELN
                                                   POSNR = GT_MAIN-POSNR ] OPTIONAL ).
        IF LS_LSTOCK IS NOT INITIAL.
          LV_INDSUM = LV_INDSUM + LS_LSTOCK-LSTOCK.
        ENDIF.

        "사전 출하물량 없는 경우
        IF GT_MAIN-DLRMG = GT_MAIN-REMMG.
          "계산 조장수 >= 출하잔량 조장수
          IF GT_MAIN-DRIND <= LV_INDSUM.
            "출하확정조장수
            GT_MAIN-RVIND = GT_MAIN-DRIND.
            "출하확정수량
            GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.

            "재고상태
            GT_MAIN-STSTA = '@5B@'. "ICON_LED_GREEN
          ELSE.
            "출하확정조장수
            GT_MAIN-RVIND = LV_INDSUM.
            "출하확정수량
            GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.
          ENDIF.

          "저장위치
          GT_MAIN-LGORT = '3410'.

        ELSE.
          "출하잔량 존재
          IF GT_MAIN-REMMG > 0.
            "출하잔량 조장수
            LV_INDREM = GT_MAIN-REMMG / GT_MAIN-INDLEN.

            "계산 조장수 >= 출하잔량 조장수
            IF LV_INDSUM >= LV_INDREM.
              "출하확정조장수
              GT_MAIN-RVIND = LV_INDREM.
              "출하확정수량
              GT_MAIN-REVMG = GT_MAIN-REMMG.

              "재고상태
              GT_MAIN-STSTA = '@5B@'. "ICON_LED_GREEN

            ELSE.
              "출하확정조장수
              GT_MAIN-RVIND = LV_INDSUM.
              "출하확정수량
              GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.
            ENDIF.

            "저장위치
            GT_MAIN-LGORT = '3410'.
          ENDIF.
        ENDIF.


      ENDIF.
    ENDIF.

*->>[LINK 조장수]--------------------------------2026.07.13 S
    IF GT_MAIN-MVGR3 NE 'Y'.
      PERFORM SET_LINK_JOJANG CHANGING GT_MAIN.
    ENDIF.
*-<<[LINK 조장수]--------------------------------2026.07.13 E


*   직납적용
    IF SY-TCODE EQ 'ZGTLER1111'.
      IF NOT ( GT_MAIN-LGORT IN GR_LGORT_DIR ).
        DELETE GT_MAIN INDEX LV_INDEX.
      ENDIF.
    ENDIF.

*___출하/영업 확정여부
    IF GT_MAIN-LECFM = 'CM' OR GT_MAIN-LECFM = 'CS' OR
       GT_MAIN-SDCFM = 'CM'.
      GT_MAIN-CONFM = 'X'.
    ENDIF.

*___판매처 명
    PERFORM GET_KUNNR_DESC USING: GT_MAIN-KUNAG
                                  GT_MAIN-NAMAG.

*___납품처명
    PERFORM GET_KUNWE_DESC USING: GT_MAIN-VBELN
                                  GT_MAIN-POSNR
                                  GT_MAIN-NAMWE.

*___제품명
    PERFORM GET_MATNR_DESC USING GT_MAIN-MATNR
                                 GT_MAIN-MAKTX.

*___출하지점명
    PERFORM GET_VSTEL_DESC USING GT_MAIN-VSTEL
                                 GT_MAIN-VTEXT.

*___플랜트명
    PERFORM GET_WERKS_DESC USING GT_MAIN-WERKS
                                 GT_MAIN-NAME1.

*___저장위치명
    PERFORM GET_LGORT_DESC USING GT_MAIN-WERKS
                                 GT_MAIN-LGORT
                                 GT_MAIN-LGORT_TX.

*___차량제한
    PERFORM GET_VHCTP_DESC USING GT_MAIN-VHCTP
                                 GT_MAIN-VHCTX.

    GT_MAIN-INDMEI = 'EA'.

*___납품생성 단위 Key Field
    MOVE-CORRESPONDING GT_MAIN TO GT_MAIN-KEYNO.

*--->>제조지시번호 제외 2026.07.04--------------------S
    GT_MAIN-KEYNO-KEYNO = GT_MAIN-VBELN.
*    IF GT_MAIN-JOBNO IS NOT INITIAL.
*      GT_MAIN-KEYNO-KEYNO = GT_MAIN-JOBNO.   "제조지시번호
*    ELSE.
**      IF GT_MAIN-DLVRQ(8) <> '20160712'.
**        GT_MAIN-KEYNO-KEYNO = GT_MAIN-DLVRQ.   "출하요청번호
**      ENDIF.
*    ENDIF.
*---<<제조지시번호 제외 2026.07.04--------------------E

*   총중량 표시
    CLEAR : LV_NTGEW.
    CONSTANTS : LV_FT LIKE MARA-NTGEW VALUE '0.305'.

    SELECT SINGLE NTGEW GEWEI
      FROM MARA
      INTO (LV_NTGEW, GT_MAIN-GEWEI)
     WHERE MATNR = GT_MAIN-MATNR.
    GT_MAIN-NTGEW = LV_NTGEW * GT_MAIN-REVMG.

    IF GT_MAIN-VRKME = 'FT'. "판매단위가 FT인경우
      GT_MAIN-NTGEW = GT_MAIN-NTGEW * LV_FT.
    ENDIF.

    GT_MAIN-NTGEW_M = LV_NTGEW.

    CLEAR : LV_DATE.
    LV_DATE = SY-DATUM + 1.

    CALL FUNCTION 'ZTR_GET_AFTER_WORKDAY'
      EXPORTING
        I_DATE      = LV_DATE
        I_CALENDAR1 = 'LS'
      IMPORTING
        O_WORKDAY   = GT_MAIN-WADAT.



    "폭/드럼
    "약경/드럼
    "드럼무게/개
    IF P_CBM IS NOT INITIAL.
      PERFORM GET_CBM_DATA CHANGING GT_MAIN.
    ENDIF.
    "총 중량(드럼포함)
    PERFORM GET_TOTAL_WEIGHT CHANGING GT_MAIN.

    "스퀴드여부
    PERFORM GET_SO_CHARACTERISTIC(ZLER0401) USING GT_MAIN-VBELN
                                                  GT_MAIN-POSNR
                                                  GC_SKID
                                                  GT_MAIN-SKID_YN.

    GT_MAIN-MEINS_MM = 'EA'.


**-- 26.09 내수/수출 명칭 수정
    GT_MAIN-KDKG4_T = COND #( WHEN GT_MAIN-KDKG4+1(1) EQ 'D' THEN |{ GT_MAIN-KDKG4 } (내수) |
                              WHEN GT_MAIN-KDKG4+1(1) EQ 'L' THEN |{ GT_MAIN-KDKG4 } (내수) |
                              WHEN GT_MAIN-KDKG4+1(1) EQ 'S' THEN |{ GT_MAIN-KDKG4 } (수출) |
                              WHEN GT_MAIN-KDKG4+1(1) EQ 'E' THEN |{ GT_MAIN-KDKG4 } (수출) | ).


    MODIFY GT_MAIN.

    CLEAR:LS_LSTOCK,LS_SSTOCK.
  ENDLOOP.

*___출하요청 확정을 통하지 않고 생성한 납품문서로 인해 판매오더의 잔량이
*   없는 경우 확정(시스템) 처리
  LOOP AT GT_0401.
    UPDATE ZLET0401 SET LECFM = GT_0401-LECFM
                        REVMG = GT_0401-REVMG
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                        AENAM = SY-UNAME
                  WHERE DLVRQ = GT_0401-DLVRQ
                    AND VBELN = GT_0401-VBELN
                    AND POSNR = GT_0401-POSNR.
  ENDLOOP.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
    MESSAGE S004 WITH '확정(시스템) 처리된 출하요청이 있습니다.'.
    LOOP AT GT_0401 INTO DATA(LS_0401).
      READ TABLE GT_MAIN ASSIGNING FIELD-SYMBOL(<FS_MAIN>) WITH KEY
      DLVRQ = LS_0401-DLVRQ
      VBELN = LS_0401-VBELN
      POSNR = LS_0401-POSNR.
      IF SY-SUBRC EQ 0.
        <FS_MAIN>-REVMG = LS_0401-REVMG.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_DELIVERY_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_STOCK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_STOCK_DATA  USING    PV_MATNR
                              PV_VSTEL       "기능개선 231127 - 추가
                              PV_WERKS
                              PV_LGORT       "기능개선 231127 - 추가
                              PV_VBELN
                              PV_POSNR
                              PV_SOBKZ
                              PV_VRKME
                              PV_LABST
                              PV_INSME
                              PV_LECFM
                              PV_SDCFM
                              PV_ZREQ_TYPE
                              PV_LGORT_CHK.

  DATA: LV_MEINS LIKE MARA-MEINS,
        LV_RAUBE LIKE MARA-RAUBE.    "기능개선 231127 - 추가

  RANGES: LR_LGORT  FOR  MARD-LGORT.
  RANGES: LR_LGORT_TMP FOR MARD-LGORT.

  CLEAR   : LR_LGORT, PV_LABST, PV_INSME.
  REFRESH : LR_LGORT.

  APPEND VALUE #( SIGN = 'I' OPTION = 'CP' LOW = '349*' ) TO LR_LGORT_TMP.

*___자재기본단위
  SELECT SINGLE RAUBE
                MEINS
    INTO (LV_RAUBE, LV_MEINS)
    FROM MARA
   WHERE MATNR = PV_MATNR.

*{ 기능개선 231127 - 추가
  IF PV_LGORT IS INITIAL.
*___납품에 대한 저장위치 결정
    SELECT SINGLE LGORT
      INTO PV_LGORT
      FROM TVKOL
     WHERE VSTEL = PV_VSTEL
       AND WERKS = PV_WERKS
       AND RAUBE = LV_RAUBE.
  ENDIF.

  IF PV_LGORT IS NOT INITIAL.
*___저장위치가 있는 경우 해당 저장위치의 재고만 조회
    LR_LGORT-SIGN   = 'I'.
    LR_LGORT-OPTION = 'EQ'.
    LR_LGORT-LOW    = PV_LGORT.
    APPEND LR_LGORT.
  ELSE.
**} 기능개선 231127 - 추가
*    SELECT LGORT AS LOW
*      INTO CORRESPONDING FIELDS OF TABLE LR_LGORT
*      FROM ZLET0053
*     WHERE WERKS   = PV_WERKS
*       AND ZUSE_YN = 'Y'.
*
*    LR_LGORT-SIGN   = 'E'.
*    LR_LGORT-OPTION = 'EQ'.
*    MODIFY LR_LGORT TRANSPORTING SIGN OPTION
*                    WHERE LOW IS NOT INITIAL.
  ENDIF.

  IF PV_SOBKZ IS INITIAL.  "MTS 재고
    SELECT SUM( LABST )
           SUM( INSME )
      INTO (PV_LABST, PV_INSME)
      FROM MARD
     WHERE MATNR =  PV_MATNR
       AND WERKS =  PV_WERKS
       AND LGORT IN LR_LGORT.

  ELSE.                    "MTO 재고
    SELECT SUM( KALAB )
           SUM( KAINS )
      INTO (PV_LABST, PV_INSME)
      FROM MSKA
     WHERE MATNR = PV_MATNR
       AND WERKS = PV_WERKS
       AND SOBKZ = PV_SOBKZ
       AND VBELN = PV_VBELN
       AND POSNR = PV_POSNR
       AND LGORT IN LR_LGORT.


  ENDIF.

  IF PV_LECFM NE  'CM' AND   "확정 아닌 경우
     PV_LECFM NE  'CS' AND
     PV_SDCFM NE  'CM' AND
     PV_SDCFM NE  'CS' AND
     PV_LGORT_CHK IS INITIAL."출하지점 '*98' 제외

    IF PV_SOBKZ IS INITIAL.  "MTS 재고
      SELECT LGORT, SUM( LABST ) AS LABST
        INTO TABLE @DATA(LT_MARD)
        FROM MARD
       WHERE MATNR =  @PV_MATNR
         AND WERKS =  @PV_WERKS
         AND LGORT IN @LR_LGORT
       GROUP BY LGORT.
      SORT LT_MARD BY LABST DESCENDING.

    ELSE.
      SELECT LGORT, SUM( KALAB ) AS LABST
        INTO CORRESPONDING FIELDS OF TABLE @LT_MARD
        FROM MSKA
       WHERE MATNR = @PV_MATNR
         AND WERKS = @PV_WERKS
         AND SOBKZ = @PV_SOBKZ
         AND VBELN = @PV_VBELN
         AND POSNR = @PV_POSNR
        GROUP BY LGORT.
      SORT LT_MARD BY LABST DESCENDING.
    ENDIF.

    "재고존재 + 저장위치 1개
    "-저장위치 > 1 이면 저장위치 SPACE, 재고 = 0. 지정
    DELETE LT_MARD WHERE LGORT+0(1) EQ '2'.
    IF LT_MARD[] IS NOT INITIAL.
      DELETE LT_MARD WHERE LABST <= 0.
      IF PV_ZREQ_TYPE IS NOT INITIAL.
        DELETE LT_MARD WHERE NOT LGORT IN LR_LGORT_TMP.
      ENDIF.

      IF LINES( LT_MARD[] ) > 0.
        IF LINES( LT_MARD[] ) EQ 1.
          DATA(LS_MARD) = VALUE #( LT_MARD[ 1 ] OPTIONAL ).
          PV_LGORT = LS_MARD-LGORT.
          PV_LABST = LS_MARD-LABST.
        ELSE.
          CLEAR: PV_LGORT,PV_LABST.
          GV_LGORT_M = 'X'.
        ENDIF.

      ELSE.
        CLEAR: PV_LGORT,PV_LABST.
      ENDIF.
*      IF lines( lt_mard[] ) EQ 1 AND
*         ls_mard-labst > 0.
*        pv_lgort = ls_mard-lgort.
*        pv_labst = ls_mard-labst.
*      ELSE.
*        CLEAR: pv_lgort,pv_labst.
*      ENDIF.

    ELSE.
      CLEAR: PV_LGORT,PV_LABST.
    ENDIF.

*    DATA(LS_MARD) = VALUE #( LT_MARD[ 1 ] OPTIONAL ).
*    IF LINES( LT_MARD[] ) EQ 1 AND
*       LS_MARD-LABST > 0.
*      PV_LGORT = LS_MARD-LGORT.
*    ELSE.
*      CLEAR PV_LGORT.
*    ENDIF.
**---저장위치 첫 자리가 2* 인 것은 재고가 존재하면 재고로 인식하지 않는다
*    IF PV_LGORT(2) EQ '2'.
*      CLEAR: PV_LABST, PV_LGORT.
*    ENDIF.
  ENDIF.


  CHECK PV_VRKME <> LV_MEINS.

*--------------------------------------------------------------------*
**-- 26.09 판매단위가 FT 인경우만
**-- 판매단위와 자재단위가 다른경우 자재의 환산단위가 없는경우
**-- 판매오더 기준의 환산기준으로 적용한다.
*--------------------------------------------------------------------*
  IF PV_VRKME EQ 'FT'.
    SELECT SINGLE FROM MARM FIELDS MANDT
          WHERE MATNR EQ @PV_MATNR
            AND MEINH EQ @PV_VRKME
      INTO @SY-MANDT.
    IF SY-SUBRC EQ 0.
*___판매오더 단위와 기본단위가 다른 경우 판매오더 단위로 수량 변경
      PERFORM CONVERT_MATERIAL_UNIT USING: PV_MATNR
                                           PV_VRKME
                                           LV_MEINS
                                           PV_LABST,

                                           PV_MATNR
                                           PV_VRKME
                                           LV_MEINS
                                           PV_INSME.
    ELSE.
      SELECT SINGLE FROM VBAP FIELDS VRKME, UMVKZ, UMVKN, MEINS
        WHERE VBELN EQ @PV_VBELN
          AND POSNR EQ @PV_POSNR
        INTO @DATA(LS_VBAP).
      IF LS_VBAP IS NOT INITIAL.
        " 판매오더 기준 환산 수량 계산 ( 기본단위 -> 판매단위 )
        PV_LABST = ( LS_VBAP-UMVKN / LS_VBAP-UMVKZ ) * PV_LABST.
      ENDIF.
    ENDIF.
  ELSE.
*___판매오더 단위와 기본단위가 다른 경우 판매오더 단위로 수량 변경
    PERFORM CONVERT_MATERIAL_UNIT USING: PV_MATNR
                                         PV_VRKME
                                         LV_MEINS
                                         PV_LABST,

                                         PV_MATNR
                                         PV_VRKME
                                         LV_MEINS
                                         PV_INSME.
  ENDIF.
ENDFORM.                    " GET_STOCK_DATA
*&---------------------------------------------------------------------*
*&      Form  CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERT_MATERIAL_UNIT  USING  PV_MATNR LIKE MARA-MATNR
                                   PV_MEINS LIKE MARA-MEINS
                                   PV_BMEIN LIKE MARA-MEINS
                                   PV_BRGEW.
  DATA : LV_BRGEW  LIKE MARA-BRGEW,
         LV_MENGE  LIKE EKPO-MENGE,
         LV_MENGE1 TYPE P DECIMALS 2,
         LV_MEINS  LIKE MARA-MEINS.

  CHECK PV_MEINS <> PV_BMEIN.

  CLEAR : LV_MENGE, LV_MEINS.

  SELECT SINGLE MEINS
    INTO LV_MEINS
    FROM MARA
   WHERE MATNR = PV_MATNR.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      MATNR                = PV_MATNR
      INPUT                = PV_BRGEW
      MEINH                = PV_MEINS
      KZMEINH              = 'X'
      MEINS                = LV_MEINS
    IMPORTING
      OUTPUT               = LV_MENGE
    EXCEPTIONS
      CONVERSION_NOT_FOUND = 01
      INPUT_INVALID        = 02
      MATERIAL_NOT_FOUND   = 03
      MEINH_NOT_FOUND      = 04
      MEINS_MISSING        = 05
      NO_MEINH             = 06
      OUTPUT_INVALID       = 07
      OVERFLOW             = 08.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        MATNR                = PV_MATNR
        INPUT                = LV_MENGE
        MEINH                = PV_BMEIN
        KZMEINH              = SPACE
        MEINS                = LV_MEINS
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 01
        INPUT_INVALID        = 02
        MATERIAL_NOT_FOUND   = 03
        MEINH_NOT_FOUND      = 04
        MEINS_MISSING        = 05
        NO_MEINH             = 06
        OUTPUT_INVALID       = 07
        OVERFLOW             = 08.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT                = PV_BRGEW
        ROUND_SIGN           = 'X'
        UNIT_IN              = PV_MEINS
        UNIT_OUT             = PV_BMEIN
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 1
        DIVISION_BY_ZERO     = 2
        INPUT_INVALID        = 3
        OUTPUT_INVALID       = 4
        OVERFLOW             = 5
        TYPE_INVALID         = 6
        UNITS_MISSING        = 7
        UNIT_IN_NOT_FOUND    = 8
        UNIT_OUT_NOT_FOUND   = 9
        OTHERS               = 10.
  ENDIF.
  IF SY-SUBRC = 0.
    LV_MENGE1 = LV_MENGE.
    PV_BRGEW  = LV_MENGE1.
  ELSE.
    CLEAR : PV_BRGEW.
  ENDIF.


ENDFORM.                    " CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*&      Form  GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_KUNNR_DESC  USING    PV_KUNNR
                              PV_NAME1.

  CLEAR : PV_NAME1.

  CHECK PV_KUNNR IS NOT INITIAL.

  READ TABLE GT_KNA1 WITH KEY KUNNR = PV_KUNNR
                     BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_KNA1.

    SELECT SINGLE KUNNR
                  NAME1
      INTO GT_KNA1
      FROM KNA1
     WHERE KUNNR = PV_KUNNR.

    IF SY-SUBRC = 0.
      APPEND GT_KNA1.

      SORT GT_KNA1 BY KUNNR.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_NAME1 = GT_KNA1-NAME1.
  ENDIF.

ENDFORM.                    " GET_KUNNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MATNR_DESC  USING    PV_MATNR
                              PV_MAKTX.

  CLEAR : PV_MAKTX.

  CHECK PV_MATNR IS NOT INITIAL.

  READ TABLE GT_MAKT WITH KEY MATNR = PV_MATNR
                     BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_MAKT.

    SELECT SINGLE A~MATNR
                  B~MAKTX
      INTO GT_MAKT
      FROM MARA AS A
     INNER JOIN MAKT AS B
        ON A~MATNR = B~MATNR
       AND B~SPRAS = SY-LANGU
     WHERE A~MATNR = PV_MATNR.

    IF SY-SUBRC = 0.
      APPEND GT_MAKT.

      SORT GT_MAKT BY MATNR.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_MAKTX = GT_MAKT-MAKTX.
  ENDIF.

ENDFORM.                    " GET_MATNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_VSTEL_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_VSTEL_DESC  USING    PV_VSTEL
                              PV_VTEXT.

  CLEAR : PV_VTEXT.

  CHECK PV_VSTEL IS NOT INITIAL.

  READ TABLE GT_TVSTT WITH KEY VSTEL = PV_VSTEL
                      BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_TVSTT.

    SELECT SINGLE A~VSTEL
                  B~VTEXT
      INTO GT_TVSTT
      FROM TVST AS A
     INNER JOIN TVSTT AS B
        ON B~SPRAS = SY-LANGU
       AND A~VSTEL = B~VSTEL
     WHERE A~VSTEL = PV_VSTEL.

    IF SY-SUBRC = 0.
      APPEND GT_TVSTT.

      SORT GT_TVSTT BY VSTEL.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_VTEXT = GT_TVSTT-VTEXT.
  ENDIF.

ENDFORM.                    " GET_VSTEL_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_WERKS_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_WERKS_DESC  USING    PV_WERKS
                              PV_NAME1.

  CLEAR : PV_NAME1.

  CHECK PV_WERKS IS NOT INITIAL.

  READ TABLE GT_T001W WITH KEY WERKS = PV_WERKS
                      BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_T001W.

    SELECT SINGLE WERKS
                  NAME1
      INTO GT_T001W
      FROM T001W
     WHERE WERKS = PV_WERKS.

    IF SY-SUBRC = 0.
      APPEND GT_T001W.

      SORT GT_T001W BY WERKS.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_NAME1 = GT_T001W-NAME1.
  ENDIF.

ENDFORM.                    " GET_WERKS_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_VHCTP_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_VHCTP_DESC  USING    PV_SDABW
                              PV_BEZEI.
  DATA: LV_HTYPE    LIKE DD01V-DATATYPE.

  CLEAR : PV_BEZEI.

  CHECK PV_SDABW IS NOT INITIAL.

  READ TABLE GT_TVSAK WITH KEY SDABW = PV_SDABW
                      BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_TVSAK.

    SELECT SINGLE SDABW
                  BEZEI
      INTO GT_TVSAK
      FROM TVSAKT
     WHERE SPRAS = SY-LANGU
       AND SDABW = PV_SDABW.

    IF SY-SUBRC = 0.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          STRING_IN = GT_TVSAK-SDABW
        IMPORTING
*         STRING_OUT       =
          HTYPE     = LV_HTYPE.

      IF LV_HTYPE = 'NUMC'.
        CONCATENATE GT_TVSAK-BEZEI '이하'
               INTO GT_TVSAK-BEZEI SEPARATED BY SPACE.
      ENDIF.

      APPEND GT_TVSAK.

      SORT GT_TVSAK BY SDABW.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_BEZEI = GT_TVSAK-BEZEI.
  ENDIF.

ENDFORM.                    " GET_VHCTP_DESC
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO .

  CLEAR : GS_LAYOUT.

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
*  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

ENDFORM.                    " SET_GRID_LAYO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'HDSEL'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      'S/O선택'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'ITSEL'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '품목선택'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'DLVRQ'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 12
      ' '            'DLVRQ'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'VBELN'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      ' '            'POSNR'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'RVSTA'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
      '검토상태'     ' '      ' '         'X' 'CHAR' 'X' ' ' ' ' ' ',

      'KUNWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNWE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAMWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '납품처명'     'NAME1'  'KNA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'KUNAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNAG'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '판매처명'     'NAME1'  'KNA1'      ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 161289 - 추가
      'BSTKD'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'PO 번호'      'BSTKD'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',

      'BSTKD_E'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'CS작번'       'BSTKD_E'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',

      'BSTDK'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'PO 일자'      'BSTDK'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 161289 - 추가

*{ 기능개선 164038 - 추가
      'EMPST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 25
      ' '            'EMPST'  'VBKD'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 164038 - 추가

      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '            'MATNR'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'MAKTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'MAKTX'  'MAKT'      ' ' ' '    'X' ' ' ' ' ' ',

      'KWMENG'   ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '오더수량'            'KWMENG' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'VRKME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '단위'         'VRKME'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'INDLEN'   ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      '조장'            'INDLEN' 'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'INDQTY'   ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'INDQTY' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'INDMEI'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'MARA'      'X' ' '    'X' ' ' ' ' ' ',

      'COLOR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '색상'         'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

*[S] 안정화  GW20260825001
      'STRIP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '색상(STRIPE)'         'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

      'STRIPNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '색상수(STRIPE)'         'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

*[E] 안정화  GW20260825001

*{ 기능개선 161289 - 추가
      'INSCD'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '절연선심식별' 'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',
*} 기능개선 161289 - 추가

      'JOBNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '제조지시번호' 'ATWRT'  'AUSP'      ' ' ' '    'X' ' ' ' ' ' ',

      'VSTEL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'VSTEL'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '출하지점명'   'VTEXT'  'TVSTT'     ' ' ' '    'X' ' ' ' ' ' ',

      'SPART'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '            'SPART'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'WERKS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'WERKS'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '플랜트명'     'NAME1'  'T001W'     ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 231127 - 추가
      'LGORT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '저장위치'     'LGORT'  'VBAP'      ' ' ' '    'X' ' ' ' ' 'X',
*} 기능개선 231127 - 추가

      'LGORT_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 16
      '저장위치명'   'LGOBE'  'T001L'     ' ' ' '    'X' ' ' ' ' ' ',

      'POST_CODE1' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '        'POST_CODE1' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'LAND1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'LAND1'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'LZONE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'LZONE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

*      'CITY1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
*      '상세주소'     'CITY1'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',
*
*      'STREET'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 60
*      '상세주소2'     'STREET'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ADDRESS'    ' '      ' '     ' ' ' ' 'X' ' '    ' ' ' ' ' ' 100
      '상세주소'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'EXTENSION1' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '수령인'   'EXTENSION1' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'TEL_NUMBER' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '연락처'   'TEL_NUMBER' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ARRDT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ARRDT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ARRTM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      ' '            'ARRTM'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'IMMDT'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'IMMDT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ALONE'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'ALONE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'BKNFT'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'BKNFT'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VHCTP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'VHCTP'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'VHCTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '차량제한명'   'BEZEI'  'TVSAKT'    ' ' ' '    'X' ' ' ' ' ' ',

      'DIVID'    ' '      ' '     ' ' 'X' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'DIVID'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',

      'ZREQ_TYPE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      ' '            'ZREQ_TYPE'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '
      ,

      'TRTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '            'TRTYP'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',
*--------------------------------------------------------------------*
**-- 26.09 내수/수출 명칭으로 변경
*--------------------------------------------------------------------*
      'KDKG4_T'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '내수/수출'    ' '  ' '  ' ' ' '    'X' ' ' ' ' ' ',

*      'KDKG4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
*      '내수/수출'    'KDKG4'  'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' ',
*--------------------------------------------------------------------*

      'SOTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'MTS/MTO'      ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'LABST'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '가용재고'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'INSME'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '품질재고'     'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'EDATU'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '출하요청일'   'EDATU'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'LFIMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '납품수량'     'LFIMG'  'LIKP'      ' ' ' '    ' ' ' ' ' ' ' ',

      'ODREM'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '미납품잔량'   'LFIMG'  'LIKP'      ' ' ' '    ' ' ' ' ' ' ' ',

      'LFIMG_DR' ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출하요청납품수량' 'LFIMG' 'LIKP'   ' ' ' '    ' ' ' ' ' ' ' ',

      'REMMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출하미확정수량' 'DLRMG' 'ZLET0401' ' ' ' '    ' ' ' ' ' ' ' ',

      'PACK_CAT'    ' '      '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      '포장유형' 'PACKAGING_CAT' 'ZEDT0230' ' ' ' '  ' ' ' ' ' ' ' ',

      'DRUM_NO'    ' '      '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      '드럼기호' 'DRUM_NO' 'ZEDT0230' ' ' ' '  ' ' ' ' ' ' ' ',

      'PACKDM'    ' '      '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '포장재(드럼)코드' 'PACKING_DM' 'ZEDT0230' ' ' ' '  ' ' ' ' ' ' ' ',

      'NTGEW'    ' '      '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '제품총중량' 'NTGEW' 'MARA' ' ' ' '  ' ' ' ' ' ' ' ',

      'GEWEI'    ' '      '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '단위' 'GEWEI' 'MARA' ' ' ' '  ' ' ' ' ' ' ' ',

      'DLRMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출하요청수량'            'DLRMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'DRIND'    ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '출하요청조장수' 'INDQTY' 'ZLET0401' ' ' ' '   ' ' ' ' ' ' ' ',

      'STSTA'    ' '      ' '     'X' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '재고상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'REVMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '출하확정'     'REVMG'  'ZLET0401'  ' ' ' '    ' ' ' ' ' ' 'X',

      'RVIND'    ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '출하확정조장수' 'INDQTY' 'ZLET0401' ' ' ' '   ' ' ' ' ' ' 'X',

      'RVIND_LINK'    ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      'LINK조장수' 'INDQTY' 'ZLET0401' ' ' ' '   ' ' ' ' ' ' ' ',

      'WADAT'    ' '     '' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 18
      '출고예정일' 'WADAT' 'LIKP' ' ' ' '   ' ' ' ' ' ' 'X',

      'LECFM'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
      ' '            'LECFM'  'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'SDCFM'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 2
      ' '            'SDCFM'  'ZLET0401'  'X' ' '    'X' ' ' ' ' ' ',


      'OUT_WID'   ' '      'MEINS_MM' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 70
      '폭/드럼'            '/BEV1/RPMNGLI' 'VTRLK'  ' ' ' '    ' ' '' ' '
      ' ',

      'PLAN_DIA'   ' '      'MEINS_MM' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 71
      '약경/드럼'            '/BEV1/RPMNGLI' 'VTRLK'  ' ' ' '    ' ' '' ' '
      ' ',

      'DR_WEIGHT'   ' '      'MEINS_MM' ' ' ' ' 'R' ' '    ' ' ' ' ' '
      72
      '드럼무게/개'            '/BEV1/RPMNGLI' 'VTRLK'  ' ' ' '    ' ' ' '
      ' ' ' ',

      'BRGEW'   ' '      'MEINS_KG' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 73
      '총 중량(드럼포함)'            'BRGEW' 'MARA'  ' ' ' '    ' ' ' ' ' ' ' '
      ,

      'SKID_YN'   ' '      ' ' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 74
      '스퀴드여부'            'ATWRT' 'AUSP'  ' ' ' '    ' ' ' ' ' ' ' ',

      'ZREMARK1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '출하실요청사항 '            'ZREMARK1' 'ZLET0400'  ' ' ' '    'X' ' '
      ' ' ' ',

      'CFM_NAME' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '출하확정자'   'NAME_LAST' 'ADRP'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQNAM' ' '    ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '출하요청자'   'NAME_LAST' 'ADRP'  ' ' ' '    'X' ' ' ' ' ' ',

      'MVGR3'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 4
      '정재고'            'MVGR3'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

      'VGBEL'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '납품문서'            'VGBEL'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'VGPOS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      '납품품목'            'VGPOS'  'ZLET0402'  ' ' ' '    'X' ' ' ' ' ' ',

      'IV_NO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '거래명세서'            'IV_NO'  'ZLET0006'  ' ' ' '    'X' ' ' ' ' ' ',

*{ 기능개선 157326 - 추가
      'REMARK'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 100
      ' '            'REMARK' 'ZLET0400'  ' ' ' '    'X' ' ' ' ' ' '.
*} 기능개선 157326 - 추가

ENDFORM.                    " SET_GRID_FCAT
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                             USING PV_FNAME
                                   PV_CURK
                                   PV_UNIT
                                   PV_ICON
                                   PV_CHECK
                                   PV_JUST
                                   PV_EMPHA
                                   PV_FIX
                                   PV_NOOUT
                                   PV_NOZERO
                                   PV_LENGTH
                                   PV_TEXT
                                   PV_REFF
                                   PV_REFT
                                   PV_TECH
                                   PV_TYPE
                                   PV_NOSUM
                                   PV_DOSUM
                                   PV_HOTSPOT
                                   PV_EDIT.

  CLEAR : GS_FIELDCAT.

  GV_POS = GV_POS + 1.

  GS_FIELDCAT-COL_POS        = GV_POS.
  GS_FIELDCAT-FIELDNAME      = PV_FNAME.
  GS_FIELDCAT-CFIELDNAME     = PV_CURK.
  GS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  GS_FIELDCAT-ICON           = PV_ICON.
  GS_FIELDCAT-CHECKBOX       = PV_CHECK.
  GS_FIELDCAT-JUST           = PV_JUST.
  GS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  GS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  GS_FIELDCAT-KEY            = PV_FIX.
  GS_FIELDCAT-NO_OUT         = PV_NOOUT.
  GS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  GS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  GS_FIELDCAT-COLTEXT        = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_S      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_M      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_L      = PV_TEXT.
  GS_FIELDCAT-REPTEXT        = PV_TEXT.
  GS_FIELDCAT-REF_FIELD      = PV_REFF.
  GS_FIELDCAT-REF_TABLE      = PV_REFT.
  GS_FIELDCAT-TECH           = PV_TECH.
  GS_FIELDCAT-DATATYPE       = PV_TYPE.
  GS_FIELDCAT-NO_SUM         = PV_NOSUM.
  GS_FIELDCAT-DO_SUM         = PV_DOSUM.
  GS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  GS_FIELDCAT-EDIT           = PV_EDIT.
  GS_FIELDCAT-COLDDICTXT     = 'M'.

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  CASE PV_FNAME.
    WHEN 'LFIMG'.
      GS_FIELDCAT-TOOLTIP = '판매오더로 생성된 납품문서 총수량'.

    WHEN 'LFIMG_DR'.
      GS_FIELDCAT-TOOLTIP = '출하요청을 통해 생성된 납품문서 수량'.

    WHEN 'ODREM'.
      GS_FIELDCAT-TOOLTIP = '= 판매오더 수량 - 납품문서 수량'.

    WHEN 'REMMG'.
      GS_FIELDCAT-TOOLTIP = '= 출하요청 수량 - (출하요청)납품수량'.

  ENDCASE.

  "DECIMAL NO OUT(EDIT:RVIND,REVMG => 입력필드는 제외)
  IF PV_FNAME EQ 'BRGEW' OR  "총중량(드럼포함)
     PV_FNAME EQ 'DLRMG' OR  "출하요청수량
     PV_FNAME EQ 'INDLEN' OR "조장
     PV_FNAME EQ 'KWMENG' OR "오더수량
*     PV_FNAME EQ 'RVIND' OR  "출하확정조장수
*     PV_FNAME EQ 'REVMG' OR "출하확정
     PV_FNAME EQ 'ODREM' OR "미납품잔량
     PV_FNAME EQ 'LABST' OR "가용재고
     PV_FNAME EQ 'INSME' OR "품질재고
     PV_FNAME EQ 'LFIMG' OR "납품수량
     PV_FNAME EQ 'LFIMG_DR' OR "출하요청납품수량
     PV_FNAME EQ 'NTGEW' OR "제품총중량
     PV_FNAME EQ 'REMMG'.   "출하미확정수량

    GS_FIELDCAT-DECIMALS_O = '0'.
    GS_FIELDCAT-DATATYPE = 'DEC'.
    CLEAR:GS_FIELDCAT-QFIELDNAME.
    CLEAR:GS_FIELDCAT-REF_FIELD,GS_FIELDCAT-REF_TABLE.
  ENDIF.

  APPEND GS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL.

*___각 Cell의 특성 제어
  LOOP AT GT_MAIN.
    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR     CHANGING LT_COLOR.

    REFRESH : GT_MAIN-CELLTAB, GT_MAIN-F_COL.

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MAIN-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MAIN-F_COL.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF GT_MAIN-CONFM  IS INITIAL AND
       GT_MAIN-HLVORM IS INITIAL AND
       GT_MAIN-ILVORM IS INITIAL.
      IF L_FIELDCAT-EDIT = 'X'.
*        IF ( L_FIELDCAT-FIELDNAME = 'REVMG' AND
*             GT_MAIN-INDLEN IS NOT INITIAL ) OR
        IF ( L_FIELDCAT-FIELDNAME = 'RVIND' AND
             GT_MAIN-INDLEN IS INITIAL ).
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                          + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.
  DATA: LS_CELLTAB TYPE LVC_S_STYL,
        LS_COLOR   TYPE LVC_S_SCOL,
        L_MODE     TYPE RAW4.

  DATA: L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_COLOR-FNAME = L_FIELDCAT-FIELDNAME.

    IF  L_FIELDCAT-KEY = 'X'.
      IF LS_COLOR-FNAME <> 'HDSEL' AND LS_COLOR-FNAME <> 'ITSEL'.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 1.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ELSE.
      IF L_FIELDCAT-EDIT IS INITIAL.
        IF GT_MAIN-ITSEL = 'X'.
          LS_COLOR-COLOR-COL = 7.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 2.
          LS_COLOR-COLOR-INT = 0.
        ENDIF.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILL_COLOR
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  REFRESH : PT_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .

  CALL METHOD GC_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER.

  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID.

ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-HANDLE = '0001'.

  CALL METHOD GC_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_MAIN[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GC_ALV_GRID->CHECK_CHANGED_DATA.

  CALL METHOD GC_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CLEAR : GT_MAIN-MARK.
  MODIFY GT_MAIN TRANSPORTING MARK
                 WHERE VBELN IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_MAIN INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GT_MAIN-MARK = 'X'.
      MODIFY GT_MAIN INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

  CALL METHOD GC_ALV_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS .

  REFRESH : GT_ROWS.

  LOOP AT GT_MAIN.
    IF GT_MAIN-MARK = 'X'.
      CLEAR : GS_ROWS.
      GS_ROWS-INDEX = SY-TABIX.
      APPEND GS_ROWS TO GT_ROWS.
    ENDIF.
  ENDLOOP.

  IF GT_ROWS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS.
  ENDIF.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_ALL .
  DATA : LT_FILTER TYPE LVC_T_FILT,
         LS_FILTER TYPE LVC_S_FILT.

  DATA : BEGIN OF LT_OPT OCCURS 0,
           SIGN(1),
           OPTION(2),
           LOW(50),
           HIGH(50),
         END   OF LT_OPT.

  FIELD-SYMBOLS : <FLD> TYPE ANY.

  DATA : LT_MAIN      LIKE GT_MAIN OCCURS 0 WITH HEADER LINE,
         LV_FNAME(40).

*___ALV Filter에 따라 선택된 데이터만 전체선택한다.
  CLEAR   : LS_FILTER.
  REFRESH : LT_FILTER.

  LT_MAIN[] = GT_MAIN[].

  CALL METHOD GC_ALV_GRID->GET_FILTER_CRITERIA
    IMPORTING
      ET_FILTER = LT_FILTER.

  IF NOT LT_FILTER[] IS INITIAL.
    SORT LT_FILTER BY FIELDNAME.

    LOOP AT LT_FILTER INTO LS_FILTER.
      AT NEW FIELDNAME.
        CLEAR   : LT_OPT, LV_FNAME.
        REFRESH : LT_OPT.

        CONCATENATE 'LT_MAIN-' LS_FILTER-FIELDNAME
               INTO LV_FNAME.
        ASSIGN (LV_FNAME) TO <FLD>.
      ENDAT.

      LT_OPT-SIGN   = LS_FILTER-SIGN.
      LT_OPT-OPTION = LS_FILTER-OPTION.
      LT_OPT-LOW    = LS_FILTER-LOW.
      LT_OPT-HIGH   = LS_FILTER-HIGH.
      APPEND LT_OPT.

      AT END OF FIELDNAME.
        LOOP AT LT_MAIN.
          IF <FLD> NOT IN LT_OPT.
            DELETE LT_MAIN.
          ENDIF.
        ENDLOOP.
      ENDAT.
    ENDLOOP.
  ENDIF.

  SORT LT_MAIN BY DLVRQ VBELN POSNR.

  LOOP AT GT_MAIN.
    READ TABLE LT_MAIN WITH KEY DLVRQ = GT_MAIN-DLVRQ
                                VBELN = GT_MAIN-VBELN
                                POSNR = GT_MAIN-POSNR
                                BINARY SEARCH.

    IF SY-SUBRC = 0.
      IF OK_SAVE = 'ASEL'          AND GT_MAIN-CONFM IS INITIAL AND
         GT_MAIN-HLVORM IS INITIAL AND GT_MAIN-ILVORM IS INITIAL.
        GT_MAIN-HDSEL = 'X'.
        GT_MAIN-ITSEL = 'X'.
      ELSE.
        CLEAR : GT_MAIN-HDSEL, GT_MAIN-ITSEL.
      ENDIF.

      MODIFY GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED USING RR_DATA_CHANGED TYPE REF TO
                                        CL_ALV_CHANGED_DATA_PROTOCOL
                        R_ONF4
                        R_UCOMM TYPE SY-UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI.

  DATA: LV_REVMG LIKE ZLET0401-REVMG,
        LV_RVIND LIKE ZLET0401-INDQTY,
        LV_LECFM LIKE ZLET0401-LECFM,
        LV_WERKS LIKE T001L-WERKS,
        LV_LGORT LIKE T001L-LGORT.

  CALL METHOD RR_DATA_CHANGED->REFRESH_PROTOCOL.

  LOOP AT RR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'LGORT'.   "저장위치
        READ TABLE GT_MAIN INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            IMPORTING
              E_VALUE     = LV_LGORT.

          CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'WERKS'
            IMPORTING
              E_VALUE     = LV_WERKS.

          IF LV_WERKS IS NOT INITIAL AND LV_LGORT IS NOT INITIAL.
            SELECT SINGLE WERKS,LGORT
              FROM T001L
             WHERE WERKS EQ @LV_WERKS
               AND LGORT EQ @LV_LGORT
              INTO @DATA(LS_T001L).
            IF SY-SUBRC NE 0.
              CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
                EXPORTING
                  I_MSGID     = 'ZLE1'
                  I_MSGNO     = '004'
                  I_MSGTY     = 'E'
                  I_MSGV1     = |저장위치 { LV_LGORT }은(는)|
                  I_MSGV2     = '플랜트'
                  I_MSGV3     = LV_WERKS
                  I_MSGV4     = ' 에 존재하지 않습니다.'
                  I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID.

            ENDIF.
          ENDIF.

          CLEAR LS_T001L.


        ENDIF.

      WHEN 'REVMG'.     "출하검토수량
        READ TABLE GT_MAIN INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            IMPORTING
              E_VALUE     = LV_REVMG.

          IF LV_REVMG > GT_MAIN-REMMG.
            CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZLE1'
                I_MSGNO     = '004'
                I_MSGTY     = 'E'
                I_MSGV1     = '출하확정수량은'
                I_MSGV2     = '출하잔량을'
                I_MSGV3     = '초과할 수 없습니다.'
                I_MSGV4     = ' '
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
          ENDIF.
        ENDIF.

      WHEN 'RVIND'.     "출하검토조장수
        READ TABLE GT_MAIN INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            IMPORTING
              E_VALUE     = LV_RVIND.

          LV_REVMG = GT_MAIN-INDLEN * LV_RVIND.

          IF LV_REVMG > GT_MAIN-REMMG.
            CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZLE1'
                I_MSGNO     = '004'
                I_MSGTY     = 'E'
                I_MSGV1     = '출하확정수량은'
                I_MSGV2     = '출하잔량을'
                I_MSGV3     = '초과할 수 없습니다.'
                I_MSGV4     = ' '
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
          ENDIF.
        ENDIF.

      WHEN  'LECFM'.    "출하확정
        READ TABLE GT_MAIN INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            IMPORTING
              E_VALUE     = LV_LECFM.

          IF LV_LECFM = 'CM' AND GT_MAIN-DLRMG <> GT_MAIN-REVMG.
            CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = 'ZLE1'
                I_MSGNO     = '004'
                I_MSGTY     = 'E'
                I_MSGV1     = '출하요청수량과 출하검토수량이'
                I_MSGV2     = '동일한 경우에 출하확정(CM)을'
                I_MSGV3     = '입력할 수 있습니다.'
                I_MSGV4     = ' '
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
          ENDIF.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  CALL METHOD RR_DATA_CHANGED->DISPLAY_PROTOCOL.
*  CALL METHOD RR_DATA_CHANGED->PROTOCOL_IS_VISIBLE.

ENDFORM.                    " DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING R_MODIFIED
                                  RT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  CHECK R_MODIFIED = 'X'.

  LOOP AT RT_GOOD_CELLS INTO LS_GOOD_CELLS.
    READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
    IF SY-SUBRC = 0.
      CASE LS_GOOD_CELLS-FIELDNAME.
        WHEN 'HDSEL'.   "판매오더 선택
          GT_MAIN-ITSEL = GT_MAIN-HDSEL.

          MODIFY GT_MAIN TRANSPORTING HDSEL ITSEL
                         WHERE DLVRQ = GT_MAIN-DLVRQ
                           AND VBELN = GT_MAIN-VBELN
                           AND CONFM IS INITIAL.

        WHEN 'RVIND'.   "출하검토조장수
          GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.

          "총 중량(드럼포함)
          PERFORM GET_TOTAL_WEIGHT CHANGING GT_MAIN.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.

        WHEN 'REVMG'.   "출하검토수량
          IF GT_MAIN-INDLEN IS NOT INITIAL.
            GT_MAIN-RVIND = GT_MAIN-REVMG / GT_MAIN-INDLEN.

            "총 중량(드럼포함)
            PERFORM GET_TOTAL_WEIGHT CHANGING GT_MAIN.

            MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
          ENDIF.

        WHEN 'LGORT'.
          PERFORM GET_LGORT_DESC USING GT_MAIN-WERKS
                                       GT_MAIN-LGORT
                                       GT_MAIN-LGORT_TX.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.

      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  LE_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LE_CONFIRM USING PV_FLAG.
  DATA: LV_TEXT(50).

  PERFORM CHECK_SELECTED_ROWS USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM CHECK_SELECTED_DATA USING PV_FLAG
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG = 'X'.
    LV_TEXT = '출하확정 하시겠습니까?'.
  ELSE.
    LV_TEXT = '출하검토 하시겠습니까?'.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CREATE_DELIVERY_DATA USING PV_FLAG.

    PERFORM GET_DELIVERY_REQ_DATA.
  ELSE.
    MESSAGE S004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " LE_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM  USING    PV_TITLE
                                PV_TEXT
                                PV_DEFAULT
                                PV_ANSWER.

  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.
  CLEAR : PV_ERROR.

  LOOP AT GT_MAIN WHERE ITSEL = 'X'.
    LV_CNT = LV_CNT + 1.

  ENDLOOP.

  IF LV_CNT IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S100 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_DATA  USING    PV_FLAG
                                   PV_ERROR.
  DATA: LV_TEXT(20).
  DATA: LV_TEXT2(20).

  CLEAR : PV_ERROR.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT GT_MAIN WHERE ITSEL = 'X'.
    CONCATENATE GT_MAIN-VBELN '-' GT_MAIN-POSNR
           INTO LV_TEXT.

    IF PV_FLAG IS NOT INITIAL.   "출하확정
      IF GT_MAIN-REVIW IS INITIAL.
**___출하검토여부
*        PV_ERROR = 'X'.
*
*        PERFORM MESSAGE_STORE
*          USING 'ZLE1' 'E' '004'
*                '출하검토되지 않은 판매오더-품목이'
*                '선택되었습니다.'
*                '판매오더-품목'
*                LV_TEXT.
      ENDIF.

*      IF GT_MAIN-DIVID IS INITIAL AND
*         GT_MAIN-REMMG <> GT_MAIN-REVMG.
**___분할출하가 아니고 검토수량과 잔량이 다른 경우
*        PV_ERROR = 'X'.
*
*        PERFORM MESSAGE_STORE
*          USING 'ZLE1' 'E' '004'
*                '분할출하가 아니고 출하확정인 경우'
*                '출하검토수량은 출하잔량과 동일해야 합니다.'
*                '판매오더-품목'
*                LV_TEXT.
*      ENDIF.
    ENDIF.

*___출하검토(확정)수량
    IF GT_MAIN-REVMG IS INITIAL.
      PV_ERROR = 'X'.

      PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                  '판매오더-품목'
                                  LV_TEXT
                                  '의 출하확정 수량이 없습니다.'
                                  ' '.
    ENDIF.

*___저장위치 입력
    IF GT_MAIN-LGORT IS INITIAL.
      PV_ERROR = 'X'.
      PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                  TEXT-040
                                  LV_TEXT
                                  TEXT-041
                                  ' '.
    ENDIF.
  ENDLOOP.

  "저장위치 혼재여부 체크 : 문경저장위치와 다른 저장위치 혼재 불가
  DATA:LV_CHK1(1).
  IF PV_ERROR IS INITIAL.
    LOOP AT GT_MAIN INTO DATA(LS_MAIN) WHERE ITSEL = GC_X
                                         AND ( TRTYP NE '02' OR INDLEN =
                                         0 )
                                       GROUP BY ( KEYNO = LS_MAIN-KEYNO
                                                  INDEX = GROUP INDEX
                                                  SIZE = GROUP SIZE )
                                       ASSIGNING FIELD-SYMBOL(<FS_MAIN>)
                                       .

      CLEAR:LV_CHK1.
      LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
        IF <FS_LINE>-LGORT EQ GC_LGORT_3430. "문경저장위치
          LV_CHK1 = GC_X.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF LV_CHK1 IS NOT INITIAL.
        LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
          IF <FS_LINE>-LGORT NE GC_LGORT_3430. "문경저장위치
            PV_ERROR = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF PV_ERROR IS NOT INITIAL.
          LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
            CLEAR:LV_TEXT,LV_TEXT2.
            CONCATENATE <FS_LINE>-VBELN '-' <FS_LINE>-POSNR
                   INTO LV_TEXT.
            LV_TEXT2 = |({ <FS_LINE>-LGORT })|.
            PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                        '판매오더-품목'
                                        LV_TEXT
                                        LV_TEXT2
                                        TEXT-M02.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.




  IF PV_ERROR = 'X'.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        SHOW_LINNO = SPACE.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_DELIVERY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_DELIVERY_DATA USING PV_FLAG.
  DATA: LV_TEXT(50).

  CLEAR : GV_ERROR, GS_MAIN.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  SORT GT_MAIN BY KEYNO VBELN POSNR.

  IF PV_FLAG = 'X'.
*___출하확정 - 납품문서 생성
    LV_TEXT = '출하확정'.

*___운송유형이 '02'(로베드)인 경우 조장수만큼 납품 생성
    LOOP AT GT_MAIN WHERE ITSEL  =  'X'
                      AND ( TRTYP  =  '02' AND INDLEN > 0 )
                      AND REVMG  >  0.
      GS_MAIN       = GT_MAIN.
      GT_MAIN-REVMG = GT_MAIN-INDLEN.

      DO GT_MAIN-RVIND TIMES.
        CLEAR   : GT_BDCTAB, GT_RETMSG, GT_0402, GV_POSNR.
        REFRESH : GT_BDCTAB, GT_RETMSG, GT_0402.

        PERFORM FILL_BDC_HEADER.

        PERFORM FILL_BDC_ITEM USING 'X'.

        PERFORM FILL_BDC_LAST.

        PERFORM CALL_TRANSACTION USING GV_ERROR.
      ENDDO.
    ENDLOOP.

    LOOP AT GT_MAIN WHERE ITSEL = 'X'
                      AND ( TRTYP  <> '02' OR INDLEN = 0 )
                      AND REVMG  >  0.
      IF GS_MAIN-KEYNO <> GT_MAIN-KEYNO.
        IF GS_MAIN IS NOT INITIAL.
          PERFORM FILL_BDC_LAST.

          PERFORM CALL_TRANSACTION USING GV_ERROR.
        ENDIF.

        CLEAR   : GT_BDCTAB, GT_RETMSG, GT_0402, GV_POSNR.
        REFRESH : GT_BDCTAB, GT_RETMSG, GT_0402.

        GS_MAIN = GT_MAIN.

        PERFORM FILL_BDC_HEADER.

        PERFORM FILL_BDC_ITEM USING 'X'.
      ELSE.
        PERFORM FILL_BDC_ITEM USING ' '.
      ENDIF.
    ENDLOOP.

    IF SY-SUBRC = 0.
      PERFORM FILL_BDC_LAST.

      PERFORM CALL_TRANSACTION USING GV_ERROR.
    ENDIF.
  ELSE.
    LV_TEXT = '출하검토'.

*___출하검토 - 검토수량 저장
    LOOP AT GT_MAIN WHERE ITSEL = 'X'.
      UPDATE ZLET0401 SET REVIW = 'X'
                          REVMG = GT_MAIN-REVMG
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE DLVRQ = GT_MAIN-DLVRQ
                      AND VBELN = GT_MAIN-VBELN
                      AND POSNR = GT_MAIN-POSNR.

      IF SY-SUBRC <> 0.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERROR IS NOT INITIAL.
      ROLLBACK WORK.

      PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                  '출하요청번호'
                                  GT_MAIN-DLVRQ
                                  '의 품목정보 Update 시'
                                  '오류가 발생하였습니다.'.
    ENDIF.
  ENDIF.

  IF GV_ERROR IS INITIAL.
    MESSAGE S004 WITH LV_TEXT '을(를) 완료하였습니다.'.
    IF PV_FLAG = 'X'.
      CALL FUNCTION 'MESSAGES_SHOW'
        EXPORTING
          SHOW_LINNO = SPACE.
    ENDIF.
  ELSE.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        SHOW_LINNO = SPACE.
  ENDIF.

ENDFORM.                    " CREATE_DELIVERY_DATA
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_BDC_HEADER .
  DATA: LV_EDATU     LIKE VBEP-EDATU,
        LV_DATUM(10).

  LV_EDATU = '99991231'.
  WRITE: LV_EDATU TO LV_DATUM.

  PERFORM  DYNPRO  USING :
               'X'  'SAPMV50A'              '4001',
               ' '  'BDC_OKCODE'            '/00',
               ' '  'LIKP-VSTEL'            GT_MAIN-VSTEL,
               ' '  'LV50C-DATBI'           LV_DATUM,
               ' '  'LV50C-VBELN'           GT_MAIN-VBELN,
               ' '  'LV50C-ABPOS'           GT_MAIN-POSNR,
               ' '  'LV50C-BIPOS'           GT_MAIN-POSNR.

ENDFORM.                    " FILL_BDC_HEADER
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_BDC_ITEM USING PV_FIRST.
  DATA: LV_LFIMG(20).

  GV_POSNR = GV_POSNR + 10.

  WRITE : GT_MAIN-REVMG TO LV_LFIMG UNIT GT_MAIN-VRKME
                                    LEFT-JUSTIFIED.

  CLEAR : GT_0402.
  GT_0402-DLVRQ = GT_MAIN-DLVRQ.
  GT_0402-VBELN = GT_MAIN-VBELN.
  GT_0402-POSNR = GT_MAIN-POSNR.
  GT_0402-VGPOS = GV_POSNR.
  GT_0402-WBSTA = 'A'.
  APPEND GT_0402.

  IF PV_FIRST IS INITIAL.
    PERFORM  DYNPRO  USING :
                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '=RAUF_T',    "판매오더 납품

                 'X'  'SAPMV50A'          '0105',
                 ' '  'BDC_OKCODE'        '=ENT1',
                 ' '  'LV50C-VBELN'       GT_MAIN-VBELN,
                 ' '  'LV50C-ABPOS'       GT_MAIN-POSNR,
                 ' '  'LV50C-BIPOS'       GT_MAIN-POSNR.
  ENDIF.

  PERFORM  DYNPRO  USING :
                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '=POPO_T',    "품목선택

                 'X'  'SAPMV50A'          '0111',
                 ' '  'BDC_OKCODE'        '=WEIT',      "품목입력
                 ' '  'RV50A-POSNR'       GV_POSNR,

                 'X'  'SAPMV50A'          '1000',
                 ' '  'BDC_OKCODE'        '/00',
                 ' '  'LIPSD-G_LFIMG(01)' LV_LFIMG,
                 ' '  'LIPS-LGORT(01)'    GT_MAIN-LGORT.

ENDFORM.                    " FILL_BDC_ITEM
*&---------------------------------------------------------------------*
*&      Form  FILL_BDC_LAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_BDC_LAST.
  DATA: LV_DATUM1(10),
        LV_DATUM2(10),
        LV_TEXT(40).
  DATA: BEGIN OF LS_ROUTE_GO,
          VSTEL TYPE LIKP-VSTEL,
          LGORT TYPE LIPS-LGORT,
        END OF LS_ROUTE_GO.


  DATA: LV_ROUTE_SO TYPE VBAP-ROUTE.

  IF GS_MAIN-EDATU < SY-DATLO.
    GS_MAIN-EDATU = SY-DATLO.  "출하요청일 과거일이면 당일로 변경
  ENDIF.

  IF GS_MAIN-ARRDT < SY-DATLO.
    CLEAR : GS_MAIN-ARRTM.

    GS_MAIN-ARRDT = SY-DATLO.  "도착일이 과거일이면 당일로 변경
  ENDIF.

  IF P_VSTEL = '3500'.
    WRITE : GS_MAIN-WADAT TO LV_DATUM1,
        GS_MAIN-ARRDT TO LV_DATUM2.
  ELSE.
    WRITE : GS_MAIN-EDATU TO LV_DATUM1,
            GS_MAIN-ARRDT TO LV_DATUM2.
  ENDIF.

*-SO의 ROUTE
  SELECT SINGLE ROUTE
    INTO LV_ROUTE_SO
    FROM VBAP
   WHERE VBELN EQ GS_MAIN-VBELN
     AND POSNR EQ GS_MAIN-POSNR.
*-SO의 고객조건그룹4
  SELECT SINGLE KDKG4
    FROM VBKD
   WHERE VBELN EQ @GS_MAIN-VBELN
    INTO @DATA(LV_KDKG4).

*-ROUTE
  IF GS_MAIN-LGORT EQ '3498' OR
     GS_MAIN-LGORT EQ '3497'.
    LS_ROUTE_GO-VSTEL = GS_MAIN-VSTEL.
    LS_ROUTE_GO-LGORT = GS_MAIN-LGORT.
    EXPORT LS_ROUTE_GO TO MEMORY ID 'ZGTLER1110_S100'.
  ENDIF.


*  CONCATENATE GS_MAIN-EXTENSION1 '/' GS_MAIN-TEL_NUMBER
*         INTO LV_TEXT.

  PERFORM  DYNPRO  USING :
               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=WADR_T',    "납품처주소

               'X'  'SAPLV09C'              '5000',
               ' '  'BDC_OKCODE'            '=ENT1',
               ' '  'ADDR1_DATA-POST_CODE1' GS_MAIN-POST_CODE1,
               ' '  'ADDR1_DATA-CITY1'      GS_MAIN-CITY1,
               ' '  'ADDR1_DATA-STREET'     GS_MAIN-STREET,
               ' '  'ADDR1_DATA-COUNTRY'    GS_MAIN-LAND1,
               ' '  'ADDR1_DATA-TRANSPZONE' GS_MAIN-LZONE,
               ' '  'SZA1_D0100-TEL_NUMBER' GS_MAIN-TEL_NUMBER,
*               ' '  'ADDR1_DATA-EXTENSION2' LV_TEXT,
               ' '  'ADDR1_DATA-EXTENSION2' GS_MAIN-EXTENSION1,

               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=HTRA_T',    "헤더-선적

               'X'  'SAPMV50A'              '2000',
               ' '  'BDC_OKCODE'            '=BACK_T'.    "BACK
*-SO의 운송경로가 보관매출,직납이 아닌경우(VBAP-ROUTE+3(3) NE '001' '002')
  IF LV_KDKG4 EQ '4D' OR LV_KDKG4 EQ '4L'.
    IF LV_ROUTE_SO+3(3) NE '001' AND
       LV_ROUTE_SO+3(3) NE '002'.
      IF LV_ROUTE_SO+3(3) NE GS_MAIN-LZONE(3).
        LV_ROUTE_SO+3(3) = GS_MAIN-LZONE(3).

        PERFORM  DYNPRO  USING :
                 ' '  'LIKP-ROUTE'            LV_ROUTE_SO.
      ENDIF.
*  ELSE.
*    PERFORM  DYNPRO  USING :
*               'X'  'SAPMV50A'              '2000',
*               ' '  'BDC_OKCODE'            '=BACK_T'.    "BACK
    ENDIF.
  ENDIF.
*-----

  IF GS_MAIN-EDATU IS NOT INITIAL.
    PERFORM  DYNPRO  USING :
               ' '  'LIKP-WADAT'            LV_DATUM1.
  ENDIF.

  IF GS_MAIN-ARRDT IS NOT INITIAL.
    PERFORM  DYNPRO  USING :
               ' '  'LIKP-LFDAT'            LV_DATUM2.
  ENDIF.

  PERFORM  DYNPRO  USING :
               ' '  'LIKP-LFUHR'            GS_MAIN-ARRTM(4),

               'X'  'SAPMV50A'              '1000',
               ' '  'BDC_OKCODE'            '=SICH_T'.    "저장

ENDFORM.                    " FILL_BDC_LAST
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION USING PV_ERROR.
  DATA: LS_MAIN     LIKE GT_MAIN.

  DATA: LV_LECFM LIKE ZLET0401-LECFM,
        LV_REVIW LIKE ZLET0401-REVIW,
        LV_FLAG.

** Transaction option
  CLEAR : CTU_PARAMS.
  CTU_PARAMS-DISMODE  =  GV_MODE.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'VL01N' USING         GT_BDCTAB
                           OPTIONS  FROM CTU_PARAMS
                           MESSAGES INTO GT_RETMSG.

  CLEAR : GT_RETMSG.

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                MSGID  = 'VL'
                                MSGNR  = '311'.
  IF SY-SUBRC = 0.
    PERFORM MESSAGE_STORE USING 'ZLE1' 'S' '004'
                                '출하요청번호'
                                GS_MAIN-DLVRQ
                                '의 납품문서가 생성되었습니다.'
                                GT_RETMSG-MSGV2.

    GT_0402-VGBEL = GT_RETMSG-MSGV2.

    MODIFY GT_0402 TRANSPORTING VGBEL
                   WHERE DLVRQ IS NOT INITIAL.

    CLEAR : LV_FLAG.

    LOOP AT GT_MAIN INTO LS_MAIN WHERE KEYNO = GS_MAIN-KEYNO
                                   AND ITSEL = 'X'.
      IF LS_MAIN-TRTYP = '02' AND LS_MAIN-INDLEN > 0.
*___운송유형이 '02'(로베드)인 경우 해당 품목만 CM을 입력하기 위해 점검
        CHECK LS_MAIN-POSNR = GS_MAIN-POSNR.
      ENDIF.

      IF LS_MAIN-REVMG EQ LS_MAIN-REMMG.
*___출하잔량과 출하검토수량이 동일하면 확정
        LV_LECFM = 'CM'.
        LV_REVIW = 'X'.
      ELSE.
*___출하잔량과 출하검토수량이 동일하지 않으면 부분확정
        LV_LECFM = 'CP'.
        LV_REVIW = ' '.
      ENDIF.

*      "기존 ZLET0401의 REVMG 수량 과 확정 수량을 SUM하여 REVMG 수량을 UPDATE
*      SELECT SINGLE *
*        FROM ZLET0401
*       WHERE DLVRQ = @LS_MAIN-DLVRQ
*         AND VBELN = @LS_MAIN-VBELN
*         AND POSNR = @LS_MAIN-POSNR
*        INTO @DATA(LS_ZLET0401).
*
*      LS_MAIN-REVMG = LS_MAIN-REVMG + LS_ZLET0401-REVMG.
      SELECT SUM( LFIMG )
        FROM LIPS
       WHERE VGBEL EQ @LS_MAIN-VBELN
         AND VGPOS EQ @LS_MAIN-POSNR
        INTO @DATA(LV_LFIMG_SUM).

      UPDATE ZLET0401 SET REVIW = LV_REVIW
                          REVMG = LV_LFIMG_SUM  "LS_MAIN-REVMG
                          LECFM = LV_LECFM
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE DLVRQ = LS_MAIN-DLVRQ
                      AND VBELN = LS_MAIN-VBELN
                      AND POSNR = LS_MAIN-POSNR.

      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
      MODIFY ZLET0402 FROM TABLE GT_0402.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ELSE.
        PV_ERROR = 'X'.

        PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                    '출하요청번호'
                                    GS_MAIN-DLVRQ
                                    '의 납품정보(ZLET0402) 생성 시'
                                    '오류가 발생하였습니다.'.

        ROLLBACK WORK.
      ENDIF.
    ELSE.
      PV_ERROR = 'X'.

      PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                                  '출하요청번호'
                                  GS_MAIN-DLVRQ
                                  '의 품목정보 Update 시'
                                  '오류가 발생하였습니다.'.

      ROLLBACK WORK.
    ENDIF.
  ELSE.
    PV_ERROR = 'X'.

    PERFORM APPEND_MESSAGE.
  ENDIF.

ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  APPEND_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_MESSAGE .

  PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
                              '출하요청번호'
                              GS_MAIN-DLVRQ
                              '의 납품문서 생성 시'
                              '오류가 발생하였습니다.'.

  LOOP AT GT_RETMSG.
    PERFORM MESSAGE_STORE USING GT_RETMSG-MSGID
                                GT_RETMSG-MSGTYP
                                GT_RETMSG-MSGNR
                                GT_RETMSG-MSGV1
                                GT_RETMSG-MSGV2
                                GT_RETMSG-MSGV3
                                GT_RETMSG-MSGV4.
  ENDLOOP.

ENDFORM.                    " APPEND_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STORE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MESSAGE_STORE  USING    PV_MSGID
                             PV_MSGTYP
                             PV_MSGNR
                             PV_MSGV1
                             PV_MSGV2
                             PV_MSGV3
                             PV_MSGV4.

  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      ARBGB = PV_MSGID
      MSGTY = PV_MSGTYP
      MSGV1 = PV_MSGV1
      MSGV2 = PV_MSGV2
      MSGV3 = PV_MSGV3
      MSGV4 = PV_MSGV4
      TXTNR = PV_MSGNR.

ENDFORM.                    " MESSAGE_STORE
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0200 .
  DATA: LV_DSCRP    LIKE ZLET0013-DSCRP.

*[S] 안정화
* AS-IS:  PERFORM check_selected_rows USING gv_error.
  PERFORM CHECK_SELECTED_ROWS1 USING GV_ERROR.
*[E] 안정화
  CHECK GV_ERROR IS INITIAL.

  READ TABLE GT_MAIN WITH KEY ITSEL = 'X'.
  IF SY-SUBRC = 0.
*{ 기능개선 157326 - 변경
    CLEAR : GS_DELV, GV_EDATU.

    MOVE-CORRESPONDING GT_MAIN TO GS_DELV.

    GV_EDATU = GT_MAIN-EDATU.

*    CLEAR : GV_EDATU.
*
*    GV_TRTYP = GT_MAIN-TRTYP.
*    GV_ARRDT = GT_MAIN-ARRDT.
*    GV_ARRTM = GT_MAIN-ARRTM.
*} 기능개선 157326 - 변경

    CALL SCREEN 0200 STARTING AT 20 2.
  ENDIF.

ENDFORM.                    " CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*&      Form  CHANGE_DELIVERY_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHANGE_DELIVERY_INFO .
  DATA: LT_0400     LIKE ZLET0400 OCCURS 0 WITH HEADER LINE.

  DATA: LV_FLAG.                          "기능개선 157326 - 추가

  PERFORM POPUP_TO_CONFIRM USING '변경'
                                 '납품정보를 변경하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR   : LT_0400.
    REFRESH : LT_0400.

    CLEAR : GT_MAIN.

*--------------------------------------------------------------------*
**-- 26.09 변경이력 history 추가
**   출하요청번호 기준으로 변경된 필드가 존재하면 변경된 필드 내역만
**   CBO 테이블에 저장해 준다
*--------------------------------------------------------------------*
    DATA LT_HIS LIKE TABLE OF ZGTSDT9140.
    REFRESH LT_HIS. CLEAR LT_HIS.
    DATA: LV_NUMBER TYPE CDCHANGENR.
    CLEAR LV_NUMBER.
    CLEAR GV_ERROR.


    " GS_DELV 필드 데이터 추가대비 FIELDCAT 기준 정리
    DATA(LO_STRUCT) = CAST CL_ABAP_STRUCTDESCR(
      CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GS_DELV ) ).
    FIELD-SYMBOLS : <FS_NEW> TYPE ANY,
                    <FS_OLD> TYPE ANY.


    DATA(LT_MAIN) = GT_MAIN[].
    SORT LT_MAIN BY ITSEL.
    DELETE LT_MAIN WHERE ITSEL = SPACE.
    SORT LT_MAIN BY KEYNO ITSEL.
    DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING KEYNO.

    LOOP AT LT_MAIN INTO DATA(LS_MAIN) WHERE ITSEL = 'X' .

      LOOP AT LO_STRUCT->COMPONENTS INTO DATA(LS_COMP).
        ASSIGN COMPONENT LS_COMP-NAME OF STRUCTURE LS_MAIN TO <FS_OLD>.
        ASSIGN COMPONENT LS_COMP-NAME OF STRUCTURE GS_DELV TO <FS_NEW>.
        CHECK <FS_OLD> IS ASSIGNED AND <FS_NEW> IS ASSIGNED.
        IF <FS_OLD> NE <FS_NEW>.
          APPEND VALUE ZGTSDT9140(
                          DLVRQ     = LS_MAIN-DLVRQ
                          TABKEY   = SY-MANDT && LS_MAIN-DLVRQ && LS_MAIN-VBELN && SY-DATUM && SY-UZEIT && SY-UNAME
                          FNAME     = LS_COMP-NAME
                          CHNGIND   = 'U'
                          VALUE_NEW = <FS_NEW>
                          VALUE_OLD = <FS_OLD>
                          DDTEXT    = CAST CL_ABAP_ELEMDESCR(
                                       LO_STRUCT->GET_COMPONENT_TYPE( LS_COMP-NAME )
                                     )->GET_DDIC_FIELD( )-FIELDTEXT
                          ERNAM     = SY-UNAME
                          ERDAT     = SY-DATUM
                          ERZEIT    = SY-UZEIT
                          ERDATLO   = SY-DATLO
                          ERTIMLO   = SY-TIMLO
                          ERTCODE   = SY-TCODE
                          EREMPNO   = SY-UNAME
                          AENAM     = SY-UNAME
                          AEDAT     = SY-DATUM
                          AEZEIT    = SY-UZEIT
                          AEDATLO   = SY-DATLO
                          AETIMLO   = SY-TIMLO
                          AETCODE   = SY-TCODE
                          AEEMPNO   = SY-UNAME
                          ) TO LT_HIS.

        ENDIF.
      ENDLOOP.
      CLEAR : LS_MAIN, LS_COMP.
    ENDLOOP.

    IF LT_HIS[] IS NOT INITIAL.
      "변경번호 채번 - ZSD_000018
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR             = '01'
          OBJECT                  = 'ZSD_000018'
        IMPORTING
          NUMBER                  = LV_NUMBER
        EXCEPTIONS
          INTERVAL_NOT_FOUND      = 1
          NUMBER_RANGE_NOT_INTERN = 2
          OBJECT_NOT_FOUND        = 3
          QUANTITY_IS_0           = 4
          QUANTITY_IS_NOT_1       = 5
          INTERVAL_OVERFLOW       = 6
          BUFFER_OVERFLOW         = 7
          OTHERS                  = 8.

      " 채번정보 UPDATE + TABKEY 추가
      MODIFY LT_HIS FROM VALUE #( CHANGENR = LV_NUMBER ) TRANSPORTING CHANGENR WHERE CHANGENR IS INITIAL.
      INSERT ZGTSDT9140 FROM TABLE LT_HIS ACCEPTING DUPLICATE KEYS.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        DATA(LV_ERR) = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDIF.




*--------------------------------------------------------------------*
**-- 26.09
**  ZGTSDT9140 테이블 업데이트가 실패하는 경우 변경내역을
**  기존테이블 (ZLET0400)에 저장하지 않고 오류메시지를 POP-UP 형태로 뿌려준다
*--------------------------------------------------------------------*
    IF LV_ERR IS INITIAL.
      LOOP AT GT_MAIN WHERE ITSEL = 'X'.
        LT_0400-DLVRQ = GT_MAIN-DLVRQ.

        COLLECT LT_0400.
      ENDLOOP.

      LOOP AT LT_0400.

        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF LT_0400
          FROM ZLET0400
         WHERE DLVRQ = LT_0400-DLVRQ.

        MOVE-CORRESPONDING: GS_DELV TO GT_MAIN,
                            GS_DELV TO GT_MAIN-KEYNO,
                            GS_DELV TO LT_0400.

        MODIFY GT_MAIN TRANSPORTING KEYNO
                                    POST_CODE1      "우편번호
                                    LAND1           "국가
                                    LZONE           "운송지역
                                    CITY1           "상세주소
                                    EXTENSION1      "수령인
                                    TEL_NUMBER      "연락처
                                    ARIND           "도착시간 입력여부
                                    ARRDT           "도착일
                                    ARRTM           "도착시간
                                    IMMDT           "긴급출하
                                    ALONE           "단독여부(혼적)
                                    VHCTP           "차량제한여부
                                    VHCTX           "차량제한여부
                                    BKNFT           "왕복여부
                                    DIVID           "분할출하
                                    TRTYP           "운송유형
                                    REMARK          "비고
                                    ZREMARK1        "출하실요청사항
                              WHERE DLVRQ = LT_0400-DLVRQ.

        MODIFY LT_0400.

      ENDLOOP.

      IF GV_EDATU IS NOT INITIAL.
        GT_MAIN-EDATU = GV_EDATU.

        MODIFY GT_MAIN TRANSPORTING EDATU         "납품일
                              WHERE ITSEL = 'X'.
      ENDIF.

      MODIFY ZLET0400 FROM TABLE LT_0400.
      IF SY-SUBRC = 0.
        CLEAR : LV_FLAG.

        LOOP AT GT_MAIN WHERE ITSEL = 'X'.
          UPDATE ZLET0401 SET EDATU = GT_MAIN-EDATU
                              AEDAT = SY-DATLO
                              AEZET = SY-TIMLO
                              AENAM = SY-UNAME
                        WHERE DLVRQ = GT_MAIN-DLVRQ
                          AND VBELN = GT_MAIN-VBELN
                          AND POSNR = GT_MAIN-POSNR.

          IF SY-SUBRC <> 0.
            LV_FLAG = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF LV_FLAG IS INITIAL.
          COMMIT WORK AND WAIT.

          MESSAGE S004 WITH '납품처 정보가 변경되었습니다.'.

          LEAVE TO SCREEN 0.
        ELSE.
          ROLLBACK WORK.

          MESSAGE S004 DISPLAY LIKE 'E'
             WITH '출하요청 품목정보 Update Error!'.
        ENDIF.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S004 DISPLAY LIKE 'E'
           WITH '출하요청 헤더정보 Update Error!'.
      ENDIF.
    ELSE.
      MESSAGE I004 DISPLAY LIKE 'E'
         WITH '변경 History 테이블 업데이트 실패, 재 처리해 주세요!'.
      GV_ERROR = ABAP_TRUE.
    ENDIF.


  ELSE.
    MESSAGE S004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CHANGE_DELIVERY_INFO
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  E_ROW  TYPE LVC_S_ROW
                          E_COLUMN TYPE LVC_S_COL.

  CHECK E_ROW-ROWTYPE IS INITIAL.
  READ TABLE GT_MAIN INDEX E_ROW-INDEX.
  IF SY-SUBRC  = 0.
    CASE E_COLUMN-FIELDNAME.
      WHEN 'VBELN' OR 'POSNR'.
        IF GT_MAIN-VBELN IS NOT INITIAL.
          SET PARAMETER ID 'AUN' FIELD GT_MAIN-VBELN.
          SET PARAMETER ID 'VPO' FIELD GT_MAIN-POSNR.

          CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST
          SCREEN.
        ENDIF.

      WHEN 'LABST' OR 'INSME'.
        IF GT_MAIN-LABST IS NOT INITIAL OR
           GT_MAIN-INSME IS NOT INITIAL.
          PERFORM SUBMIT_ZLER0011.
        ENDIF.

      WHEN  OTHERS.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  GET_KUNWE_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_KUNWE_DESC  USING    PV_VBELN
                              PV_POSNR
                              PV_NAME1.

  CLEAR : PV_NAME1.

  SELECT SINGLE B~NAME1
    INTO PV_NAME1
    FROM VBPA AS A
   INNER JOIN ADRC AS B
      ON A~ADRNR = B~ADDRNUMBER
   WHERE A~VBELN     =  PV_VBELN
     AND A~POSNR     =  PV_POSNR
     AND A~PARVW     =  'WE'
     AND B~DATE_FROM <= SY-DATLO
     AND B~DATE_TO   >= SY-DATLO.

  IF SY-SUBRC <> 0.
    SELECT SINGLE B~NAME1
      INTO PV_NAME1
      FROM VBPA AS A
     INNER JOIN ADRC AS B
        ON A~ADRNR = B~ADDRNUMBER
     WHERE A~VBELN     =  PV_VBELN
       AND A~POSNR     =  '000000'
       AND A~PARVW     =  'WE'
       AND B~DATE_FROM <= SY-DATLO
       AND B~DATE_TO   >= SY-DATLO.
  ENDIF.

ENDFORM.                    " GET_KUNWE_DESC
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_ZLER0011
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUBMIT_ZLER0011 .
  DATA: LT_PARAMS   LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_PARAMS.
  REFRESH : LT_PARAMS.

  CLEAR   : LT_PARAMS.
  LT_PARAMS-SELNAME = 'S_WERKS'.
  LT_PARAMS-KIND    = 'S'.
  LT_PARAMS-SIGN    = 'I'.
  LT_PARAMS-OPTION  = 'EQ'.
  LT_PARAMS-LOW     = GT_MAIN-WERKS.
  APPEND LT_PARAMS.

  CLEAR   : LT_PARAMS.
  LT_PARAMS-SELNAME = 'S_LGORT'.
  LT_PARAMS-KIND    = 'S'.
  LT_PARAMS-SIGN    = 'I'.
  LT_PARAMS-OPTION  = 'CP'.
  LT_PARAMS-LOW     = '*'.
  APPEND LT_PARAMS.

  CLEAR   : LT_PARAMS.
  LT_PARAMS-SELNAME = 'S_MATNR'.
  LT_PARAMS-KIND    = 'S'.
  LT_PARAMS-SIGN    = 'I'.
  LT_PARAMS-OPTION  = 'EQ'.
  LT_PARAMS-LOW     = GT_MAIN-MATNR.
  APPEND LT_PARAMS.

  IF GT_MAIN-SOBKZ IS INITIAL.
    CLEAR   : LT_PARAMS.
    LT_PARAMS-SELNAME = 'CK_MTO'.
    LT_PARAMS-KIND    = 'P'.
    LT_PARAMS-LOW     = ' '.
    APPEND LT_PARAMS.
  ELSE.
    CLEAR   : LT_PARAMS.
    LT_PARAMS-SELNAME = 'R1'.
    LT_PARAMS-KIND    = 'P'.
    LT_PARAMS-LOW     = ' '.
    APPEND LT_PARAMS.

    CLEAR   : LT_PARAMS.
    LT_PARAMS-SELNAME = 'R2'.
    LT_PARAMS-KIND    = 'P'.
    LT_PARAMS-LOW     = 'X'.
    APPEND LT_PARAMS.

    CLEAR   : LT_PARAMS.
    LT_PARAMS-SELNAME = 'CK_MTS'.
    LT_PARAMS-KIND    = 'P'.
    LT_PARAMS-LOW     = ' '.
    APPEND LT_PARAMS.

    CLEAR   : LT_PARAMS.
    LT_PARAMS-SELNAME = 'S_VBELN'.
    LT_PARAMS-KIND    = 'S'.
    LT_PARAMS-SIGN    = 'I'.
    LT_PARAMS-OPTION  = 'EQ'.
    LT_PARAMS-LOW     = GT_MAIN-VBELN.
    APPEND LT_PARAMS.
  ENDIF.

  SUBMIT ZLER0011 WITH SELECTION-TABLE LT_PARAMS
                  AND RETURN.

ENDFORM.                    " SUBMIT_ZLER0011
*&---------------------------------------------------------------------*
*&      Form  CHECK_POST_CODE
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
FORM CHECK_POST_CODE USING PV_POST1
                           PV_LZONE.

  DATA: LV_LZONE    LIKE ZGTSDT9121-ZONE1.

  CLEAR : LV_LZONE.

  SELECT SINGLE ZONE1
    INTO LV_LZONE
    FROM ZGTSDT9121
   WHERE POST_CODE = PV_POST1.

  IF SY-SUBRC = 0.
    PV_LZONE = LV_LZONE.

*    IF PV_LZONE <> LV_LZONE AND LV_LZONE IS NOT INITIAL.
*      IF PV_ERROR = 'E'.
*        MESSAGE E004
*           WITH '우편번호와 운송지역 정보가'
*                '일치하지 않습니다.'.
*      ELSE.
*        PV_ERROR = 'X'.
*
*        PERFORM MESSAGE_STORE USING 'ZLE1' 'E' '004'
*                                    '판매오더-품목'
*                                    PV_TEXT
*                                    '우편번호와 운송지역 정보가'
*                                    '일치하지 않습니다.'.
*      ENDIF.
*    ENDIF.
  ELSE.
    MESSAGE E004 WITH '유효하지 않은 우편번호입니다.'.
  ENDIF.

ENDFORM.                    " CHECK_POST_CODE
*&---------------------------------------------------------------------*
*&      Form  CHECK_TRANSPORT_ZONE
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
FORM CHECK_TRANSPORT_ZONE .


  CHECK GS_DELV-LAND1 IS NOT INITIAL OR
        GS_DELV-LZONE IS NOT INITIAL.

  IF ( GS_DELV-LAND1 IS NOT INITIAL AND GS_DELV-LZONE IS INITIAL ) OR
     ( GS_DELV-LZONE IS NOT INITIAL AND GS_DELV-LAND1 IS INITIAL ).
    MESSAGE E004 WITH '국가키와 운송경로를 모두 입력하십시오.'.
  ELSE.
    SELECT SINGLE ZONE1
      INTO GS_DELV-LZONE
      FROM TZONE
     WHERE LAND1 = GS_DELV-LAND1
       AND ZONE1 = GS_DELV-LZONE.

    IF SY-SUBRC <> 0.
      MESSAGE E004 WITH '유효하지 않은 운송경로입니다.'
                        '국가키와 운송경로를 확인하십시오.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_TRANSPORT_ZONE
*&---------------------------------------------------------------------*
*&      Form  F4HELP_POST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_POST  USING    PV_PCODE.
  DATA: SELECTFIELD  LIKE  HELP_INFO-FIELDNAME,
        IT_FIELDS    LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
        SELECT_VALUE LIKE  HELP_INFO-FLDVALUE,
        LD_TABIX     LIKE  SY-TABIX.

  DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
        FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_9121 OCCURS 0,
          POST_CODE LIKE ZGTSDT9121-POST_CODE,
          POST_NAME LIKE ZGTSDT9121-POST_NAME,
        END   OF LT_9121.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, LT_9121.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, LT_9121.

  SELECT POST_CODE
         POST_NAME
    INTO CORRESPONDING FIELDS OF TABLE LT_9121
    FROM ZGTSDT9121.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '설정된 우편번호가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZGTSDT9121'.
  IT_FIELDS-FIELDNAME  = 'POST_CODE'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZGTSDT9121'.
  IT_FIELDS-FIELDNAME  = 'POST_NAME'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = LT_9121
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.

  READ TABLE LT_9121 INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_PCODE = LT_9121-POST_CODE.
  ENDIF.

ENDFORM.                    " F4HELP_POST
*&---------------------------------------------------------------------*
*&      Form  GET_PACK_DM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MAIN_VBELN  text
*      -->P_GT_MAIN_POSNR  text
*      -->P_GT_MAIN_PACK_CAT  text
*      -->P_GT_MAIN_DRUM_NO  text
*      -->P_GT_MAIN_PACKDM  text
*----------------------------------------------------------------------*
FORM GET_PACK_DM  USING    PV_VBELN
                           PV_POSNR
                           PV_PACK_CAT
                           PV_DRUM_NO
                           PV_PACKDM.

  CLEAR : PV_PACK_CAT, PV_DRUM_NO, PV_PACKDM.

  SELECT SINGLE PACKAGING_CAT DRUM_NO PACKING_DM
    INTO (PV_PACK_CAT, PV_DRUM_NO, PV_PACKDM)
    FROM ZEDT0230
   WHERE VBELN = PV_VBELN
     AND POSNR = PV_POSNR.



ENDFORM.                    " GET_PACK_DM
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG EQ @GC_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VSTEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VSTEL  USING    PV_FNAME.

  SELECT DISTINCT B~VSTEL,C~VTEXT
    FROM TVKWZ AS A INNER JOIN TVSWZ AS B
                    ON A~WERKS = B~WERKS
                    INNER JOIN TVSTT AS C
                    ON B~VSTEL = C~VSTEL AND
                       C~SPRAS = @SY-LANGU
   WHERE A~VKORG EQ @GC_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VSTEL.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VSTEL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING    PV_FNAME.
  RANGES: LR_VKBUR FOR VBAK-VKBUR.

  LR_VKBUR[] = CORRESPONDING #( S_VKBUR[] ).

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG EQ @GC_VKORG
     AND A~VKBUR IN @LR_VKBUR
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS  USING    PV_FNAME.

  SELECT DISTINCT A~WERKS,B~NAME1
    FROM TVKWZ AS A INNER JOIN T001W AS B
                    ON A~WERKS = B~WERKS
   WHERE A~VKORG EQ @GC_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY WERKS.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING    PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG EQ @GC_VKORG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_DLVRQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_DLVRQ  USING    PV_FNAME.

  DATA: LT_RET LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA: LV_CALLPROG TYPE SY-REPID VALUE SY-REPID,
        LV_CALLFORM TYPE SY-XFORM VALUE 'F4_CALLBACK_FORM'.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME          = 'ZLET0400'
      FIELDNAME        = 'DLVRQ'
      SEARCHHELP       = 'ZSD_DLVRQ'
      DYNPPROG         = SY-CPROG
      DYNPNR           = SY-DYNNR
      DYNPROFIELD      = PV_FNAME
      MULTIPLE_CHOICE  = SPACE
      CALLBACK_PROGRAM = LV_CALLPROG
      CALLBACK_FORM    = LV_CALLFORM
    TABLES
      RETURN_TAB       = LT_RET.


ENDFORM.

FORM F4_CALLBACK_FORM  TABLES PT_RECORD_TAB   STRUCTURE SEAHLPRES
                     CHANGING PS_SHLP         TYPE SHLP_DESCR_T
                              PS_CALLCONTROL  LIKE DDSHF4CTRL.

  DATA:LS_SELOPT TYPE DDSHSELOPT.

  CLEAR LS_SELOPT.
  LS_SELOPT-SHLPFIELD = 'VKORG'.
  LS_SELOPT-SIGN      = 'I'.
  LS_SELOPT-OPTION    = 'EQ'.
  LS_SELOPT-LOW       = GC_VKORG.
  APPEND LS_SELOPT TO PS_SHLP-SELOPT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDE .

  APPEND VALUE #( FCODE = 'LEREV' ) TO GT_EXCL.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_STOCK .

  PERFORM CHECK_SELECTED_ROWS USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  "CHECK
  PERFORM CHECK_DISPLAY_STOCK.

  CHECK GV_ERROR IS INITIAL.

  "재고조회 : SUBMIT ZLER0011
  PERFORM SUBMIT_ZLER0011_RUN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DISPLAY_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DISPLAY_STOCK .

  DATA:LV_MSG(200).

  LOOP AT GT_MAIN INTO DATA(LS_MAIN) WHERE ITSEL EQ GC_X.
*   저장위치 입력
    IF LS_MAIN-LGORT IS INITIAL.
      GV_ERROR = GC_X.
      LV_MSG = TEXT-M01.
      MESSAGE I004 WITH LV_MSG DISPLAY LIKE GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUBMIT_ZLER0011_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SUBMIT_ZLER0011_RUN .

  RANGES: LR_WERKS FOR LIPS-WERKS,
          LR_LGORT FOR LIPS-LGORT,
          LR_MATNR FOR MARA-MATNR.

  LOOP AT GT_MAIN INTO DATA(LS_MAIN) WHERE ITSEL EQ GC_X.
    "플랜트
    CLEAR LR_WERKS.
    LR_WERKS-SIGN = 'I'.LR_WERKS-OPTION = 'EQ'.LR_WERKS-LOW =
    LS_MAIN-WERKS.
    COLLECT LR_WERKS.
    "저장위치
    CLEAR LR_LGORT.
    LR_LGORT-SIGN = 'I'.LR_LGORT-OPTION = 'EQ'.LR_LGORT-LOW =
    LS_MAIN-LGORT.
    COLLECT LR_LGORT.
    "자재
    CLEAR LR_MATNR.
    LR_MATNR-SIGN = 'I'.LR_MATNR-OPTION = 'EQ'.LR_MATNR-LOW =
    LS_MAIN-MATNR.
    COLLECT LR_MATNR.
  ENDLOOP.

  SUBMIT ZLER0011 WITH R1      = ''
                  WITH R2      = GC_X
                  WITH S_WERKS IN LR_WERKS
                  WITH S_LGORT IN LR_LGORT
                  WITH S_MATNR IN LR_MATNR
                  WITH CK_MTS  = GC_X
                  WITH CK_MTO  = GC_X
                  WITH P_NEW   = GC_X
                   AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL_WEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
FORM GET_TOTAL_WEIGHT  CHANGING    PS_MAIN LIKE GT_MAIN.
  DATA : LV_FT LIKE MARA-NTGEW VALUE '0.305'.
  DATA : LV_MENGE    TYPE LIPS-LFIMG,
         LV_INDQTY   TYPE ZLET0401-INDQTY,
         LV_NTGEW_DR TYPE MARA-NTGEW,
         LV_NTGEW_MM TYPE MARA-NTGEW.
  "DRIND

*-제품중량
  SELECT SINGLE MEINS,NTGEW,GEWEI
    FROM MARA
   WHERE MATNR EQ @PS_MAIN-MATNR
    INTO @DATA(LS_MARA).

* 확정인 경우 : 출하요청수량/출하요청조장수
  IF PS_MAIN-LECFM = 'CM' OR PS_MAIN-LECFM = 'CS'.
    "출하요청 수량
    LV_MENGE = PS_MAIN-DLRMG.

    "출하요청 조장수
    LV_INDQTY = PS_MAIN-DRIND.

  ELSE.
* 미확정인 경우 : 출하확정수량/출하확정조장수
    "출하확정 수량
    LV_MENGE = PS_MAIN-REVMG.

    "출하확정 조장수
    LV_INDQTY = PS_MAIN-RVIND.
  ENDIF.

  "자재 기본단위로 변경
  IF PS_MAIN-VRKME NE LS_MARA-MEINS.
    IF PS_MAIN-VRKME EQ 'FT'. "판매단위가 FT인경우.
      LV_MENGE = LV_MENGE * LV_FT.
    ELSE.
      LV_MENGE = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR =
      PS_MAIN-MATNR
                                                             IV_IN_ME =
PS_MAIN-VRKME
                                                             IV_OT_ME =
LS_MARA-MEINS
                                                             IV_MENGE =
                                                             LV_MENGE
                                                             ).
    ENDIF.
  ENDIF.

  LV_NTGEW_MM = LS_MARA-NTGEW * LV_MENGE.

  "중량단위 'KG'
  IF LS_MARA-GEWEI NE GC_MEINS_KG.
    LV_NTGEW_MM = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR =
    PS_MAIN-MATNR
                                                              IV_IN_ME =
LS_MARA-GEWEI
                                                              IV_OT_ME =
GC_MEINS_KG
                                                              IV_MENGE =
LV_NTGEW_MM        ).
  ENDIF.

*-총중량(드럼포함) : 드럼무게/개 + 제품중량
  PS_MAIN-BRGEW = ( PS_MAIN-DR_WEIGHT * LV_INDQTY ) + LV_NTGEW_MM.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DELIVERY_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_MAIN
*&---------------------------------------------------------------------*
FORM GET_DELIVERY_QTY  CHANGING PS_MAIN LIKE GT_MAIN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_POST_CODE_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DELV_POST_CODE1
*&---------------------------------------------------------------------*
FORM CHECK_POST_CODE_NEW  USING   PV_POST1.

  SELECT SINGLE POST_CODE
    INTO @DATA(LV_POST_CODE)
    FROM ZGTSDT9121
   WHERE POST_CODE EQ @PV_POST1.

  IF SY-SUBRC NE 0.
    MESSAGE E004 WITH '유효하지 않은 우편번호입니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CBM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_MAIN
*&---------------------------------------------------------------------*
FORM GET_CBM_DATA  CHANGING PS_MAIN LIKE GT_MAIN.
  DATA: LT_TAB TYPE TABLE OF ZGTEDSIF0034.

  APPEND VALUE #( VBELN = PS_MAIN-VBELN
                  POSNR = PS_MAIN-POSNR
                 ) TO LT_TAB.

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      OT_OUTPUT = LT_TAB.

  DATA(LS_TAB) = VALUE #( LT_TAB[ 1 ] OPTIONAL ).

  CHECK LS_TAB-MSG_TYPE NE 'E'.

  "폭/드럼
  PS_MAIN-OUT_WID = LS_TAB-OUT_WID.

  "약경/드럼
  PS_MAIN-PLAN_DIA = LS_TAB-BARREL_DIA.

  "드럼무게/개
  PS_MAIN-DR_WEIGHT = LS_TAB-BRGEW.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0900 .
  IF GC_ALV_GRID2 IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID2->FREE.
    CLEAR GC_ALV_GRID2.
  ENDIF.
  IF GC_CUSTOM_CONTAINER2 IS NOT INITIAL.
    CALL METHOD GC_CUSTOM_CONTAINER2->FREE.
    CLEAR:GC_CUSTOM_CONTAINER2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYO_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GRID_LAYO_0900 .
  CLEAR : GS_LAYOUT2.

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT2-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT2-ZEBRA      = 'X'.
  GS_LAYOUT2-SMALLTITLE = 'X'.
  GS_LAYOUT2-SEL_MODE   = 'A'.              "select multiple lines
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME = 'F_COL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_FCAT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GRID_FCAT_0900 .
  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT2.

  GV_ITAB = 'GT_STOCK'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
                                  USING :

      'WERKS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'WERKS'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

      'WERKS_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '플랜트명'     'NAME1'  'T001W'     ' ' ' '    'X' ' ' ' ' ' ',

      'LGORT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '저장위치'     'LGORT'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

       'LGORT_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '저장위치명'     'LGOBE'  'T001L'     ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '거래처명'     'NAME1'  'ADRC'      ' ' ' '    'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      'SO번호'            'VBELN'  'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      'SO항번'            'POSNR'  'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '            'MATNR'  'MARA'  ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'MAKTX'  'MAKT'      ' ' ' '    'X' ' ' ' ' ' ',

      'MENGE'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '가용재고'     'CLABS'  'MCHB'  ' ' ' '    ' ' ' ' ' ' ' ',



      'LENGTH'   ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'INDLEN' 'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'FACTOR'   ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'INDQTY' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' '  ' ' ' 3
      '단위'         'MEINS'  'MARA'  ' ' ' '    'X' ' ' ' ' ' ',

      'DESC'    ' '      ' '     'X' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '재고상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ZSORT'    ' '      ' '     'X' ' ' ' ' ' '    ' ' 'X' ' ' 1
      'SORT'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_0900 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_0900 .
*  CALL METHOD GC_ALV_GRID2->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER.

  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID2.
*  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID2.
*  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
*          FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DISPLAY_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_DISPLAY_0900 .
  GS_VARIANT2-REPORT = SY-REPID.
  GS_VARIANT2-HANDLE = '0002'.

  CALL METHOD GC_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT2
      IS_LAYOUT            = GS_LAYOUT2
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT2[]
      IT_SORT              = GT_SORT2[]
      IT_OUTTAB            = GT_STOCK[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_STOCK_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_STOCK_0900 .
  CLEAR GT_STOCK[].

  CLEAR GV_ERROR.
  PERFORM CHECK_SELECTED_ROWS USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM GET_STOCK_INFO.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_STOCK_INFO .

  DATA: LS_D365_LOGIN TYPE  ZSDS_LOG_0000_GO,
        LV_MODE       TYPE  ZGTEMODE_STOCK  VALUE 'Z'.

  DATA: LS_RETURN        TYPE  ZSDS_LOG_0001_GO,
        LT_SEARCH        LIKE TABLE OF ZGTSDSIF0096,
        LS_SEARCH        LIKE ZGTSDSIF0096,
        LT_AVL_ITEM      LIKE TABLE OF ZGTSDSIF0098,
        LT_LSTOCK_ITEM   LIKE TABLE OF ZGTSDSIF0100,
        LT_LSTOCK_DETAIL LIKE TABLE OF ZGTSDSIF0101,
        LT_ESTOCK_ITEM   LIKE TABLE OF ZGTSDSIF0102,
        LT_ESTOCK_DETAIL LIKE TABLE OF ZGTSDSIF0103.

  DATA: LT_STOCK LIKE TABLE OF GT_STOCK.
  DATA: LS_STOCK LIKE GT_STOCK.

  DATA: LV_MSG TYPE BAPI_MSG.

  DATA: LV_CNT TYPE I.


*-IT_SEARCH 구성
  LOOP AT GT_MAIN INTO DATA(LS_MAIN) WHERE ITSEL EQ GC_X.
    CLEAR: LS_SEARCH.
    LS_SEARCH-MATNR = LS_MAIN-MATNR.
    LS_SEARCH-WERKS = LS_MAIN-WERKS.

    COLLECT LS_SEARCH INTO LT_SEARCH.
  ENDLOOP.

  LS_D365_LOGIN-ENAME = SY-UNAME.

  CALL FUNCTION 'ZSD_365_0050_0040_GO'
    EXPORTING
      IS_D365_LOGIN    = LS_D365_LOGIN
      I_MODE           = LV_MODE
    IMPORTING
      ES_RETURN        = LS_RETURN
    TABLES
      IT_SEARCH        = LT_SEARCH
      ET_AVL_ITEM      = LT_AVL_ITEM
      ET_LSTOCK_ITEM   = LT_LSTOCK_ITEM
      ET_LSTOCK_DETAIL = LT_LSTOCK_DETAIL
      ET_ESTOCK_ITEM   = LT_ESTOCK_ITEM
      ET_ESTOCK_DETAIL = LT_ESTOCK_DETAIL.

  IF LS_RETURN-MTYPE NE GC_S.
    LV_MSG = |{ TEXT-M03 } { LS_RETURN-MESSAGE }|.
    MESSAGE I004 WITH LV_MSG(50)
                      LV_MSG+50(50)
                      LV_MSG+100(50)
                      LV_MSG+150(50)
         DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-01.LINK 재고
  CLEAR LT_STOCK[].
  LOOP AT LT_LSTOCK_DETAIL INTO DATA(LS_LSTOCK_DETAIL) WHERE LGORT IN
  GR_LGORT
                                        GROUP BY ( VBELN =
                                        LS_LSTOCK_DETAIL-VBELN
                                                   POSNR =
LS_LSTOCK_DETAIL-POSNR
                                                   WERKS =
LS_LSTOCK_DETAIL-WERKS
                                                   LGORT =
LS_LSTOCK_DETAIL-LGORT
                                                   MATNR  =
LS_LSTOCK_DETAIL-MATNR
                                                   LENGTH =
LS_LSTOCK_DETAIL-LENGTH )
                                        ASCENDING ASSIGNING
                                        FIELD-SYMBOL(<FS_MAIN10>).

    CLEAR: LS_STOCK,LV_CNT.
    LOOP AT GROUP <FS_MAIN10> ASSIGNING FIELD-SYMBOL(<FS_LINE10>).
      LV_CNT = LV_CNT + 1.
      IF LV_CNT EQ 1.
        LS_STOCK-VBELN  = <FS_LINE10>-VBELN.
        LS_STOCK-POSNR  = <FS_LINE10>-POSNR.
        LS_STOCK-WERKS  = <FS_LINE10>-WERKS.
        LS_STOCK-LGORT  = <FS_LINE10>-LGORT.
        LS_STOCK-MATNR  = <FS_LINE10>-MATNR.
        LS_STOCK-LENGTH = <FS_LINE10>-LENGTH.
        LS_STOCK-MEINS  = <FS_LINE10>-VRKME.
        LS_STOCK-DESC   = TEXT-T01.
        LS_STOCK-INDMEI = 'EA'.
        LS_STOCK-ZSORT  = GC_A.
      ENDIF.
      LS_STOCK-FACTOR = LS_STOCK-FACTOR + <FS_LINE10>-LSTOCK.
    ENDLOOP.
    APPEND LS_STOCK TO LT_STOCK.
  ENDLOOP.

*LOOP AT LT_LSTOCK_DETAIL INTO DATA(LS_LSTOCK_DETAIL) WHERE LGORT IN
*GR_LGORT.
*    CLEAR:LS_STOCK.
*    LS_STOCK-VBELN  = LS_LSTOCK_DETAIL-VBELN.
*    LS_STOCK-POSNR  = LS_LSTOCK_DETAIL-POSNR.
*    LS_STOCK-WERKS  = LS_LSTOCK_DETAIL-WERKS.
*    LS_STOCK-LGORT  = LS_LSTOCK_DETAIL-LGORT.
*    LS_STOCK-MATNR  = LS_LSTOCK_DETAIL-MATNR.
*    LS_STOCK-LENGTH = LS_LSTOCK_DETAIL-LENGTH.
*    LS_STOCK-FACTOR = LS_LSTOCK_DETAIL-LSTOCK.
*    LS_STOCK-MEINS  = LS_LSTOCK_DETAIL-VRKME.
*    LS_STOCK-DESC   = TEXT-T01.
*    LS_STOCK-INDMEI = 'EA'.
*
*    APPEND LS_STOCK TO LT_STOCK.
*  ENDLOOP.
  IF LT_STOCK[] IS NOT INITIAL.
    APPEND LINES OF LT_STOCK TO GT_STOCK.
  ENDIF.

*-02. 판매오더재고
  CLEAR LT_STOCK[].
  LOOP AT LT_ESTOCK_DETAIL INTO DATA(LS_ESTOCK_DETAIL) WHERE LGORT IN
  GR_LGORT
                                        GROUP BY ( VBELN =
                                        LS_ESTOCK_DETAIL-VBELN
                                                   POSNR =
LS_ESTOCK_DETAIL-POSNR
                                                   WERKS =
LS_ESTOCK_DETAIL-WERKS
                                                   LGORT =
LS_ESTOCK_DETAIL-LGORT
                                                   MATNR  =
LS_ESTOCK_DETAIL-MATNR
                                                   LENGTH =
LS_ESTOCK_DETAIL-LENGTH )
                                        ASCENDING ASSIGNING
                                        FIELD-SYMBOL(<FS_MAIN20>).
    CLEAR: LS_STOCK,LV_CNT.
    LOOP AT GROUP <FS_MAIN20> ASSIGNING FIELD-SYMBOL(<FS_LINE20>).
      LV_CNT = LV_CNT + 1.
      IF LV_CNT EQ 1.
        LS_STOCK-VBELN  = <FS_LINE20>-VBELN.
        LS_STOCK-POSNR  = <FS_LINE20>-POSNR.
        LS_STOCK-WERKS  = <FS_LINE20>-WERKS.
        LS_STOCK-LGORT  = <FS_LINE20>-LGORT.
        LS_STOCK-MATNR  = <FS_LINE20>-MATNR.
        LS_STOCK-LENGTH = <FS_LINE20>-LENGTH.
        LS_STOCK-MEINS  = <FS_LINE20>-VRKME.
        LS_STOCK-DESC   = TEXT-T02.
        LS_STOCK-INDMEI = 'EA'.
        LS_STOCK-ZSORT  = GC_B.
      ENDIF.
      LS_STOCK-FACTOR = LS_STOCK-FACTOR + <FS_LINE20>-ESTOCK.
    ENDLOOP.
    APPEND LS_STOCK TO LT_STOCK.
  ENDLOOP.

*LOOP AT LT_ESTOCK_DETAIL INTO DATA(LS_ESTOCK_DETAIL) WHERE LGORT IN
*GR_LGORT.
*    CLEAR:LS_STOCK.
*    LS_STOCK-VBELN  = LS_ESTOCK_DETAIL-VBELN.
*    LS_STOCK-POSNR  = LS_ESTOCK_DETAIL-POSNR.
*    LS_STOCK-WERKS  = LS_ESTOCK_DETAIL-WERKS.
*    LS_STOCK-LGORT  = LS_ESTOCK_DETAIL-LGORT.
*    LS_STOCK-MATNR  = LS_ESTOCK_DETAIL-MATNR.
*    LS_STOCK-LENGTH = LS_ESTOCK_DETAIL-LENGTH.
*    LS_STOCK-FACTOR = LS_ESTOCK_DETAIL-ESTOCK.
*    LS_STOCK-MEINS  = LS_ESTOCK_DETAIL-VRKME.
*    LS_STOCK-DESC   = TEXT-T02.
*    LS_STOCK-INDMEI = 'EA'.
*
*    COLLECT LS_STOCK INTO LT_STOCK.
*  ENDLOOP.
  IF LT_STOCK[] IS NOT INITIAL.
    APPEND LINES OF LT_STOCK TO GT_STOCK.
  ENDIF.

*-03. 가용재고
  CLEAR LT_STOCK[].
  LOOP AT LT_AVL_ITEM INTO DATA(LS_AVL_ITEM) WHERE LGORT IN GR_LGORT.
    CLEAR:LS_STOCK.
    LS_STOCK-WERKS  = LS_AVL_ITEM-WERKS.
    LS_STOCK-LGORT  = LS_AVL_ITEM-LGORT.
    LS_STOCK-MATNR  = LS_AVL_ITEM-MATNR.
    LS_STOCK-LENGTH = LS_AVL_ITEM-LENGTH.
    LS_STOCK-FACTOR = LS_AVL_ITEM-STOCK.
    LS_STOCK-MEINS  = LS_AVL_ITEM-MEINS.
    LS_STOCK-DESC   = TEXT-T03.
    LS_STOCK-INDMEI = 'EA'.
    LS_STOCK-ZSORT  = GC_C.

    APPEND LS_STOCK TO LT_STOCK.
  ENDLOOP.
  IF LT_STOCK[] IS NOT INITIAL.
    APPEND LINES OF LT_STOCK TO GT_STOCK.
  ENDIF.

*-플랜트 명
  DATA(LT_TEMP) = GT_STOCK[].
  SORT LT_TEMP BY WERKS.
  DELETE LT_TEMP WHERE WERKS IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING WERKS.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT WERKS,NAME1
      FROM T001W
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE WERKS EQ @LT_TEMP-WERKS
      INTO TABLE @DATA(LT_T001W).
    SORT LT_T001W BY WERKS.
  ENDIF.

*-저장위치 명
  CLEAR LT_TEMP[].
  LT_TEMP[] = CORRESPONDING #( GT_STOCK[] ).
  SORT LT_TEMP BY WERKS LGORT.
  DELETE LT_TEMP WHERE WERKS IS INITIAL.
  DELETE LT_TEMP WHERE LGORT IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING WERKS LGORT.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT WERKS,LGORT,LGOBE
      FROM T001L
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE WERKS EQ @LT_TEMP-WERKS
       AND LGORT EQ @LT_TEMP-LGORT
      INTO TABLE @DATA(LT_T001L).
    SORT LT_T001L BY WERKS LGORT.
  ENDIF.

*-자재 명
  CLEAR LT_TEMP[].
  LT_TEMP[] = CORRESPONDING #( GT_STOCK[] ).
  SORT LT_TEMP BY MATNR.
  DELETE LT_TEMP WHERE MATNR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING MATNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT MATNR,MAKTX
      FROM MAKT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE MATNR EQ @LT_TEMP-MATNR
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_MAKT).
    SORT LT_MAKT BY MATNR.
  ENDIF.

*-거래처명
  CLEAR LT_TEMP[].
  LT_TEMP[] = CORRESPONDING #( GT_STOCK[] ).
  SORT LT_TEMP BY VBELN.
  DELETE LT_TEMP WHERE VBELN IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~VBELN,A~KUNNR,C~NAME1
      FROM VBAK AS A INNER JOIN KNA1 AS B
                     ON A~KUNNR = B~KUNNR
                     INNER JOIN ADRC AS C
                     ON B~ADRNR  = C~ADDRNUMBER AND
                        C~NATION = @SPACE
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~VBELN EQ @LT_TEMP-VBELN
      INTO TABLE @DATA(LT_VBAK).
    SORT LT_VBAK BY VBELN.
  ENDIF.

*-리스트 구성
  LOOP AT GT_STOCK ASSIGNING FIELD-SYMBOL(<FS_STOCK>).
    "가용재고
    <FS_STOCK>-MENGE = <FS_STOCK>-LENGTH * <FS_STOCK>-FACTOR.

    "플랜트명
    IF <FS_STOCK>-WERKS IS NOT INITIAL.
      <FS_STOCK>-WERKS_TX = VALUE #( LT_T001W[ WERKS = <FS_STOCK>-WERKS
      ]-NAME1 OPTIONAL ).

      "저장위치 명
      IF <FS_STOCK>-WERKS IS NOT INITIAL.
        <FS_STOCK>-LGORT_TX = VALUE #( LT_T001L[ WERKS =
        <FS_STOCK>-WERKS
                                                 LGORT =
                                                 <FS_STOCK>-LGORT
                                                 ]-LGOBE OPTIONAL ).
      ENDIF.
    ENDIF.

    "자재명
    IF <FS_STOCK>-MATNR IS NOT INITIAL.
      <FS_STOCK>-MATNR_TX = VALUE #( LT_MAKT[ MATNR = <FS_STOCK>-MATNR
      ]-MAKTX OPTIONAL ).
    ENDIF.

    "거래처명
    IF <FS_STOCK>-VBELN IS NOT INITIAL.
      <FS_STOCK>-KUNNR_TX = VALUE #( LT_VBAK[ VBELN = <FS_STOCK>-VBELN
      ]-NAME1 OPTIONAL ).
    ENDIF.

  ENDLOOP.

  CALL SCREEN 0900 STARTING AT 15 5
                   ENDING AT   170 30.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_SORT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GRID_SORT_0900 .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR:GT_SORT2[].


  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'ZSORT'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'WERKS'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'WERKS_TX'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'LGORT'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'LGORT_TX'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'VBELN'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR GS_SORT.
  LV_SPOS = LV_SPOS + 1.
  GS_SORT-SPOS = LV_SPOS.
  GS_SORT-FIELDNAME = 'POSNR'.
  APPEND GS_SORT TO GT_SORT2.

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'KUNNR_TX'.
*  APPEND GS_SORT TO GT_SORT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LGORT_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN_WERKS
*&      --> GT_MAIN_NAME1
*&---------------------------------------------------------------------*
FORM GET_LGORT_DESC  USING    PV_WERKS
                              PV_LGORT
                              PV_TEXT.

  CLEAR : PV_TEXT.

  CHECK PV_WERKS IS NOT INITIAL AND PV_LGORT IS NOT INITIAL.

  READ TABLE GT_T001L WITH KEY WERKS = PV_WERKS
                               LGORT = PV_LGORT
                      BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_T001L.

    SELECT SINGLE WERKS
                  LGORT
                  LGOBE
      INTO GT_T001L
      FROM T001L
     WHERE WERKS = PV_WERKS
       AND LGORT = PV_LGORT.

    IF SY-SUBRC = 0.
      APPEND GT_T001L.

      SORT GT_T001L BY WERKS LGORT.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_TEXT = GT_T001L-LGOBE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
FORM SET_ROUND  USING    PS_MAIN LIKE GT_MAIN.


  PERFORM SET_ROUND_VALUE USING:
                                PS_MAIN-BRGEW SPACE '1', "총중량(드럼포함)
                                PS_MAIN-DLRMG SPACE '1', "출하요청수량
                                PS_MAIN-INDLEN SPACE '1', "조장
                                PS_MAIN-REVMG SPACE '1', "출하확정
                                PS_MAIN-ODREM SPACE '1', "미납품잔량
                                PS_MAIN-LABST SPACE '1', "가용재고
                                PS_MAIN-INSME SPACE '1', "품질재고
                                PS_MAIN-LFIMG SPACE '1', "납품수량
                                PS_MAIN-LFIMG_DR SPACE '1', "출하요청납품수량
                                PS_MAIN-NTGEW SPACE '1', "제품총중량
                                PS_MAIN-REMMG SPACE '1'. "출하미확정수량


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ROUND_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAIN_BRGEW
*&      --> SPACE
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ROUND_VALUE  USING    PV_VALUE
                               PV_RTYPE
                               PV_RUNIT.
  DATA:LV_RTYPE TYPE VTBLEISTE-RTYPE,
       LV_RUNIT TYPE VTBFIMA-RUNIT  VALUE '1'.

  CHECK PV_VALUE NE 0.

  LV_RTYPE = PV_RTYPE.
  LV_RUNIT = PV_RUNIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = LV_RTYPE
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_VALUE
*     I_ROUNDDECIMALS       =
    IMPORTING
      E_VALUE_RND = PV_VALUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SO_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SO_CHAR .
  DATA: LV_VALID  LIKE IBIN-VALFR.

  CLEAR:GT_CHAR[],GT_CHAR.

  CHECK GT_MAIN[] IS NOT INITIAL.

  GET TIME STAMP FIELD LV_VALID.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR.

  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~VBELN, A~POSNR,
           D~ATNAM, C~ATWRT, C~ATFLV,
           C~ATFLB, D~ATFOR, D~ANZDZ
      INTO CORRESPONDING FIELDS OF TABLE @GT_CHAR
      FROM VBAP AS A
     INNER JOIN IBIN AS B
        ON A~CUOBJ = B~INSTANCE
     INNER JOIN V_IBIN_SYVAL AS C
        ON B~IN_RECNO = C~IN_RECNO
     INNER JOIN CABN AS D
        ON C~ATINN =  D~ATINN
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~VBELN =  @LT_TEMP-VBELN
       AND A~POSNR =  @LT_TEMP-POSNR
       AND B~VALFR <= @LV_VALID
       AND B~VALTO >= @LV_VALID
       AND D~ATNAM IN @GR_ATNAM.
    SORT GT_CHAR BY VBELN POSNR ATNAM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TEXT .
  CLEAR:GT_KNA1[],GT_MATNR[],GT_TVSTT[],GT_T001W[],GT_T001L[].
  CHECK GT_MAIN[] IS NOT INITIAL.
*___판매처 명
  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY KUNAG.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNAG.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR  = B~ADDRNUMBER AND
                        B~NATION = @SPACE
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE KUNNR EQ @LT_TEMP-KUNAG
      INTO CORRESPONDING FIELDS OF TABLE @GT_KNA1.

  ENDIF.

*___납품처명
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_MAIN[].
  SORT LT_TEMP BY KUNWE.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNWE.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR  = B~ADDRNUMBER AND
                        B~NATION = @SPACE
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE KUNNR EQ @LT_TEMP-KUNWE
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_KNA1.

  ENDIF.
  SORT GT_KNA1 BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM GT_KNA1 COMPARING KUNNR.

*___제품명등 GT_MATNR
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_MAIN[].
  SORT LT_TEMP BY MATNR.
  DELETE LT_TEMP WHERE MATNR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING MATNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~MATNR,A~MEINS,A~NTGEW,A~GEWEI,
           B~MAKTX
      FROM MARA AS A LEFT OUTER JOIN MAKT AS B
                     ON A~MATNR = B~MATNR AND
                        B~SPRAS = @SY-LANGU
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~MATNR EQ @LT_TEMP-MATNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_MATNR.
    SORT GT_MATNR BY MATNR.
  ENDIF.

*___출하지점명
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_MAIN[].
  SORT LT_TEMP BY VSTEL.
  DELETE LT_TEMP WHERE VSTEL IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VSTEL.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~VSTEL,B~VTEXT
      FROM TVST AS A INNER JOIN TVSTT AS B
                     ON A~VSTEL = B~VSTEL AND
                        B~SPRAS = @SY-LANGU
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~VSTEL EQ @LT_TEMP-VSTEL
      INTO CORRESPONDING FIELDS OF TABLE @GT_TVSTT.
    SORT GT_TVSTT BY VSTEL.
  ENDIF.

*___플랜트명
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_MAIN[].
  SORT LT_TEMP BY WERKS.
  DELETE LT_TEMP WHERE WERKS IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING WERKS.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT WERKS,NAME1
      FROM T001W
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE WERKS EQ @LT_TEMP-WERKS
      INTO CORRESPONDING FIELDS OF TABLE @GT_T001W.
    SORT GT_T001W BY WERKS.
  ENDIF.

*___저장위치명
*  CLEAR LT_TEMP[].
*  LT_TEMP[] = GT_MAIN[].
*  SORT LT_TEMP BY WERKS LGORT.
*  DELETE LT_TEMP WHERE WERKS IS INITIAL.
*  DELETE LT_TEMP WHERE LGORT IS INITIAL.
*  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING WERKS LGORT.
*  IF LT_TEMP[] IS NOT INITIAL.
*    SELECT WERKS,LGORT,LGOBE
*      FROM T001L
*       FOR ALL ENTRIES IN @LT_TEMP
*     WHERE WERKS = @LT_TEMP-WERKS
*       AND LGORT = @LT_TEMP-LGORT
*      INTO CORRESPONDING FIELDS OF TABLE @GT_T001L.
*    SORT GT_T001L BY WERKS LGORT.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PACK_DM_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PACK_DM_INFO .

  CLEAR:GT_PACKDM,GT_PACKDM[].
  CHECK GT_MAIN[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR.

  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VBELN,POSNR,PACKAGING_CAT, DRUM_NO, PACKING_DM
      INTO CORRESPONDING FIELDS OF TABLE @GT_PACKDM
      FROM ZEDT0230
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VBELN = @LT_TEMP-VBELN
       AND POSNR = @LT_TEMP-POSNR.
    SORT GT_PACKDM BY VBELN POSNR.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SO_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_MAIN
*&---------------------------------------------------------------------*
FORM SET_SO_CHAR  CHANGING PS_MAIN LIKE GT_MAIN.

*-조장
  READ TABLE GT_CHAR INTO DATA(LS_CHAR) WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_LENGTH
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-INDLEN = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-INDLEN = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.

*-색상
  CLEAR LS_CHAR.
  READ TABLE GT_CHAR INTO LS_CHAR WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_CBASE
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-COLOR = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-COLOR = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.
*[S] 안정화 GW20260825001
*-STRIP 색상
  CLEAR LS_CHAR.
  READ TABLE GT_CHAR INTO LS_CHAR WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_STRIP
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-STRIP = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-STRIP = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.

*-STRIP 색상수
  CLEAR LS_CHAR.
  READ TABLE GT_CHAR INTO LS_CHAR WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_STRIPNO
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-STRIPNO = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-STRIPNO = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.

*[E] 안정화 GW20260825001
*-절연선심식별 코드
  CLEAR LS_CHAR.
  READ TABLE GT_CHAR INTO LS_CHAR WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_INSCD
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-INSCD = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-INSCD = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.

*-스퀴드여부
  CLEAR LS_CHAR.
  READ TABLE GT_CHAR INTO LS_CHAR WITH KEY VBELN = GT_MAIN-VBELN
                                                 POSNR = GT_MAIN-POSNR
                                                 ATNAM = GC_SKID
                                          BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF LS_CHAR-ATFOR = 'NUM'.
      PS_MAIN-SKID_YN = LS_CHAR-ATFLV.
    ELSE.
      PS_MAIN-SKID_YN = LS_CHAR-ATWRT.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DELIVERY_REQ_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DELIVERY_REQ_DATA_NEW .
  RANGES: LR_KDKG4  FOR  VBKD-KDKG4,
          LR_TRTYP  FOR  ZLET0400-TRTYP.
  DATA : LV_DATE LIKE SY-DATUM.
  DATA : LV_NTGEW  LIKE MARA-NTGEW.

  DATA : LV_LGORT_CHK(1).

  CLEAR   : GT_MAIN, GT_0401, LR_KDKG4, LR_TRTYP,GT_LSTOCK_ITEM,GT_LSTOCK_DETAIL,
            GT_ESTOCK_ITEM,GT_ESTOCK_DETAIL.
  REFRESH : GT_MAIN, GT_0401, LR_KDKG4, LR_TRTYP,GT_LSTOCK_ITEM,GT_LSTOCK_DETAIL,
            GT_ESTOCK_ITEM,GT_ESTOCK_DETAIL.

  CASE 'X'.
    WHEN P_R12.      "내수/로컬
      SET_RANGES: LR_KDKG4 'I' 'EQ' '4D' ' ',
                  LR_KDKG4 'I' 'EQ' '4L' ' '.

    WHEN P_R13.      "수출
      SET_RANGES: LR_KDKG4 'I' 'EQ' '4E' ' ',
                  LR_KDKG4 'I' 'EQ' '4S' ' '.

    WHEN OTHERS.    "전체

  ENDCASE.

  IF P_TRTYP <> '00'.
    SET_RANGES: LR_TRTYP 'I' 'EQ' P_TRTYP ' '.
  ENDIF.

  SELECT A~DLVRQ,            "출하요청번호
         B~VBELN,            "판매오더
         B~POSNR,            "판매오더품목
         A~AUART,            "오더유형
         A~KUNWE,            "납품처
         A~KUNAG,            "판매처
         A~KDKG4,            "내수/수출
         B~SOBKZ,            "특별재고지시자
         B~MATNR,            "자재
         B~KWMENG,           "오더수량
         B~VRKME,            "판매단위
         B~INDLEN,           "조장
         B~INDQTY,           "조장수
*         C~VSTEL            "출하지점
         A~VSTEL,            "출하지점
         B~WERKS,            "플랜트
         A~SPART,            "제품군
         A~POST_CODE1,       "우편번호
         A~LAND1,            "국가
         A~LZONE,            "운송지역
         A~CITY1,            "상세주소
         A~EXTENSION1,       "수령인
         A~TEL_NUMBER,       "연락처
         A~ARIND,            "도착시간 입력 여부
         A~ARRDT,            "도착일
         A~ARRTM,            "도착시간
         A~IMMDT,            "긴급출하
         A~ALONE,            "단독여부(혼적)
         A~VHCTP,            "차량제한여부
         A~BKNFT,            "왕복여부
         A~DIVID,            "분할출하
         A~ZREQ_TYPE,        "직송의뢰 신청 유형
         A~TRTYP,            "운송유형
         B~EDATU,            "납품일정
         B~DLRMG,           "출하요청수량
         B~REVIW,            "출하검토여부
         B~REVMG,            "출하검토수량
         B~LECFM,            "출하확정
         B~SDCFM,            "영업확정
         A~REMARK,           "비고
         A~LVORM AS HLVORM,  "삭제지시자(헤더)
         B~LVORM AS ILVORM,  "삭제지시자(품목)

         C~FIXMG,            "MTO/MTS 구분기준

         V~CTLPC,            "여신관리 리스크범주
         K~BSTKD,            "PO번호
         K~BSTDK,            "PO일자

         A~ZREMARK1,         "출하실요청사항

         C~MVGR3,            "정조장여부 판단
         D~BSTKD_E,
*         b~aenam,
         CASE WHEN B~LECFM IS NOT INITIAL AND
                   A~LVORM IS INITIAL AND
                   B~LVORM IS INITIAL
              THEN F~NAME_LAST ELSE @SPACE END AS CFM_NAME,

         F~NAME_LAST AS REQNAM "출하요청자

    FROM ZLET0400 AS A INNER JOIN ZLET0401 AS B
                       ON A~DLVRQ =  B~DLVRQ
                       INNER JOIN VBAP AS C
                       ON B~VBELN =  C~VBELN AND
                          B~POSNR =  C~POSNR
                       INNER JOIN VBAK AS V
                       ON C~VBELN = V~VBELN
                       INNER JOIN VBKD AS K
                       ON V~VBELN = K~VBELN AND
                          K~POSNR = '000000'
                       LEFT JOIN VBKD AS D
                       ON B~VBELN EQ D~VBELN
                       AND B~POSNR EQ D~POSNR


                       LEFT JOIN USR21 AS E
                       ON B~AENAM EQ E~BNAME
                       LEFT JOIN ADRP AS F
                       ON E~PERSNUMBER EQ F~PERSNUMBER

                       LEFT JOIN USR21 AS G
                       ON A~ERNAM EQ G~BNAME
                       LEFT JOIN ADRP AS H
                       ON G~PERSNUMBER EQ H~PERSNUMBER
   WHERE A~VKORG EQ @GC_VKORG
     AND A~DLVRQ IN @S_DLVRQ
     AND A~ERDAT IN @S_ERDAT
     AND A~TRTYP IN @LR_TRTYP
     AND B~EDATU IN @S_EDATU
     AND A~VKBUR IN @S_VKBUR
     AND A~VKGRP IN @S_VKGRP
     AND A~KUNAG IN @S_KUNAG
     AND A~KUNWE IN @S_KUNWE
     AND B~VBELN IN @S_VBELN
     AND A~VSTEL EQ @P_VSTEL
*     AND C~VSTEL EQ P_VSTEL
     AND A~SPART IN @S_SPART
     AND B~WERKS IN @S_WERKS
     AND B~MATNR IN @S_MATNR
     AND A~KDKG4 IN @LR_KDKG4
     AND A~PERNR IN @S_PERNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_MAIN.

  DATA : LT_MAIN LIKE TABLE OF GT_MAIN WITH EMPTY KEY.
  LT_MAIN[] = CORRESPONDING #( GT_MAIN[] ).

  WITH +SO_INFO AS ( SELECT A~VBELN, A~POSNR
                       FROM @LT_MAIN AS A
                      GROUP BY A~VBELN, A~POSNR )

     SELECT A~VGBEL,  A~VGPOS,  A~LGORT
       FROM LIPS AS A INNER JOIN +SO_INFO AS B
                         ON A~VGBEL EQ B~VBELN
                        AND A~VGPOS EQ B~POSNR
      ORDER BY A~VGBEL, A~VGPOS

       INTO TABLE @DATA(LT_DO_INFO).


  CASE 'X'.
    WHEN P_R22.
      DELETE GT_MAIN WHERE LECFM = 'CM'
                        OR LECFM = 'CS'
                        OR SDCFM = 'CM'
                        OR SDCFM = 'CS'.
    WHEN P_R23.
      DELETE GT_MAIN WHERE LECFM NE 'CM'
                       AND LECFM NE 'CS'
                       AND SDCFM NE 'CM'
                       AND SDCFM NE 'CS'.
    WHEN OTHERS.
  ENDCASE.

  IF P_R31 = 'X'.   "삭제여부
    DELETE GT_MAIN WHERE HLVORM EQ 'X'
                      OR ILVORM EQ 'X'.
  ENDIF.

  "특성
  PERFORM GET_SO_CHAR.
  "포장재/드럼
  PERFORM GET_PACK_DM_INFO.
  "폭/약경/드럼
  IF P_CBM IS NOT INITIAL.
    PERFORM GET_CBM_DATA_INFO.
  ENDIF.
  "DO 수량
  PERFORM GET_DO_QTY_INFO.
  "TEXT
  PERFORM GET_TEXT.

*->>[LINK 조장수]--------------------------------2026.07.13 S
  PERFORM GET_LINK_JOJANG.
*-<<[LINK 조장수]--------------------------------2026.07.13 E


  LOOP AT GT_MAIN.
    DATA(LV_INDEX) = SY-TABIX.
    CLEAR:LV_LGORT_CHK.

*___판매오더 특성 - 제조지시번호
    GT_MAIN-JOBNO = GT_MAIN-BSTKD_E.

*___포장재(드럼)기호
    READ TABLE GT_PACKDM INTO DATA(LS_PACKDM) WITH KEY VBELN = GT_MAIN-VBELN
                                                       POSNR = GT_MAIN-POSNR
                                              BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_MAIN-PACK_CAT = LS_PACKDM-PACKAGING_CAT.
      GT_MAIN-DRUM_NO  = LS_PACKDM-DRUM_NO.
      GT_MAIN-PACKDM   = LS_PACKDM-PACKING_DM.
    ENDIF.

*___납품생성수량(출하요청)
    SELECT SUM( B~LFIMG )
      INTO GT_MAIN-LFIMG_DR
      FROM ZLET0402 AS A
     INNER JOIN LIPS AS B
        ON A~VGBEL = B~VBELN
     WHERE A~DLVRQ = GT_MAIN-DLVRQ
       AND A~VBELN = GT_MAIN-VBELN
       AND A~POSNR = GT_MAIN-POSNR
       AND ( A~VGPOS = B~POSNR
          OR A~VGPOS = B~UECHA ).

*___출하잔량 = 출하요청수량 - 납품생성수량
    IF GT_MAIN-DLRMG > GT_MAIN-LFIMG_DR.
      GT_MAIN-REMMG = GT_MAIN-DLRMG - GT_MAIN-LFIMG_DR.
    ENDIF.

*___납품생성 수량(판매오더)
    GT_MAIN-LFIMG = VALUE #( GT_LIPS_SUM[ VBELN = GT_MAIN-VBELN
                                          POSNR = GT_MAIN-POSNR ]-LFIMG OPTIONAL ).

*___오더잔량 = 오더수량 - 납품생성수량
    IF GT_MAIN-KWMENG > GT_MAIN-LFIMG.
      GT_MAIN-ODREM = GT_MAIN-KWMENG - GT_MAIN-LFIMG.
    ENDIF.

    IF GT_MAIN-HLVORM IS INITIAL AND GT_MAIN-ILVORM IS INITIAL AND
       GT_MAIN-LECFM  <> 'CM'    AND GT_MAIN-LECFM  <> 'CS'    AND
       GT_MAIN-ODREM  IS INITIAL.
      GT_MAIN-LECFM = 'CS'.

*___확정(시스템) Flag 'CS' 입력 대상
      CLEAR : GT_0401.
      "납품수량
      GT_0401-REVMG = GT_MAIN-LFIMG.
*      PERFORM GET_DELIVERY_QTY CHANGING GT_MAIN.
      GT_0401-DLVRQ = GT_MAIN-DLVRQ.
      GT_0401-VBELN = GT_MAIN-VBELN.
      GT_0401-POSNR = GT_MAIN-POSNR.
      GT_0401-LECFM = 'CS'.
      COLLECT GT_0401.
    ENDIF.

*   출하지점 '*98' => 저장위치 DEFAULT
    IF GT_MAIN-HLVORM IS INITIAL AND GT_MAIN-ILVORM IS INITIAL AND
       GT_MAIN-LECFM  NE 'CM'    AND GT_MAIN-LECFM  NE 'CS'.
      IF GT_MAIN-VSTEL+2(2) EQ '98'.
*        GT_MAIN-LGORT = '3498'.
        CASE GT_MAIN-ZREQ_TYPE.
          WHEN 'A'.
            GT_MAIN-LGORT = '3498'.
            LV_LGORT_CHK = GC_X.
          WHEN 'B'.
            GT_MAIN-LGORT = '3497'.
            LV_LGORT_CHK = GC_X.
        ENDCASE.

      ENDIF.
    ENDIF.


*___MTO/MTS
    IF GT_MAIN-FIXMG IS NOT INITIAL.
      GT_MAIN-SOTXT = 'MTS'.
    ELSE.
      GT_MAIN-SOTXT = 'MTO'.
    ENDIF.

*   특성(조장/색상/절연선심식별 코드/스퀴드여부)
    PERFORM SET_SO_CHAR CHANGING GT_MAIN.



    READ TABLE LT_DO_INFO WITH KEY VGBEL = GT_MAIN-VBELN
                                   VGPOS = GT_MAIN-POSNR
                          INTO DATA(LS_DO_INFO).
    IF SY-SUBRC EQ 0.
      GT_MAIN-LGORT = LS_DO_INFO-LGORT.
    ENDIF.

*___가용재고/품질재고
    PERFORM GET_STOCK_DATA USING GT_MAIN-MATNR
                                 GT_MAIN-VSTEL
                                 GT_MAIN-WERKS
                                 GT_MAIN-LGORT
                                 GT_MAIN-VBELN
                                 GT_MAIN-POSNR
                                 GT_MAIN-SOBKZ
                                 GT_MAIN-VRKME
                                 GT_MAIN-LABST
                                 GT_MAIN-INSME
                                 GT_MAIN-LECFM
                                 GT_MAIN-SDCFM
                                 GT_MAIN-ZREQ_TYPE
                                 LV_LGORT_CHK.

*   재고존재시 해당 저장위치 제안 => 출하지점 '6598'인 경우는 제외
    IF GT_MAIN-AUART <> 'RE' AND GT_MAIN-AUART <> 'ZREQ'.
*___재고상태
      IF GT_MAIN-LABST >= GT_MAIN-DLRMG.
        GT_MAIN-STSTA = '@5B@'.      "ICON_LED_GREEN
      ELSEIF GT_MAIN-LABST IS INITIAL.
        GT_MAIN-STSTA = '@5C@'.      "ICON_LED_RED
      ELSE.
        GT_MAIN-STSTA = '@5D@'.      "ICON_LED_YELLOW
      ENDIF.
    ENDIF.

*___출하확정수량 - 기본값
    IF GT_MAIN-SDCFM <> 'CM' AND
       GT_MAIN-LECFM <> 'CS' AND
       GT_MAIN-LECFM <> 'CM'.

      IF GT_MAIN-REVIW <> 'X'.
        IF GT_MAIN-LABST >= GT_MAIN-REMMG.
          GT_MAIN-REVMG = GT_MAIN-REMMG.
        ELSE.
          GT_MAIN-REVMG = GT_MAIN-LABST.
        ENDIF.

      ENDIF.
    ELSE.
      CLEAR GT_MAIN-REVMG.
    ENDIF.

*___출하요청/검토 조장수
    IF GT_MAIN-INDLEN IS NOT INITIAL.
      GT_MAIN-DRIND = GT_MAIN-DLRMG / GT_MAIN-INDLEN.
      GT_MAIN-RVIND = GT_MAIN-REVMG / GT_MAIN-INDLEN.
    ENDIF.

*___출하검토상태
    IF GT_MAIN-REVIW IS NOT INITIAL.
      IF GT_MAIN-REVMG >= GT_MAIN-DLRMG.
        GT_MAIN-RVSTA = 'CM'.          "검토완료
      ELSE.
        IF GT_MAIN-DIVID = 'X'.
          GT_MAIN-RVSTA = 'P'.         "분할납품/검토
        ELSE.
          GT_MAIN-RVSTA = 'C'.         "검토
        ENDIF.
      ENDIF.
    ENDIF.

*   정조장인 경우: 출하확정조장수 = 출하요청조장수,재고상태 = 녹색,저장위치 = 3410
    IF GT_MAIN-MVGR3 EQ 'X'.

      GT_MAIN-MVGR3 = 'O'.  "정재고 여부 표시
      "재고상태
      GT_MAIN-STSTA = '@5B@'.      "ICON_LED_GREEN
      "저장위치
      GT_MAIN-LGORT = '3410'.
*      "출하확정조장수
*      GT_MAIN-RVIND = GT_MAIN-DRIND.
*      "출하확정수량
*      GT_MAIN-REVMG = GT_MAIN-INDLEN * GT_MAIN-RVIND.

      "출하잔량이 있는경우
      IF GT_MAIN-REMMG > 0. "출하잔량
        "출하확정수량
        GT_MAIN-REVMG = GT_MAIN-REMMG.
        "출하확정조장수
        GT_MAIN-RVIND = GT_MAIN-REVMG / GT_MAIN-INDLEN.
      ELSE.
        CLEAR:GT_MAIN-REVMG,GT_MAIN-RVIND.
      ENDIF.

    ENDIF.

*->>[LINK 조장수]--------------------------------2026.07.13 S
    PERFORM SET_LINK_JOJANG CHANGING GT_MAIN.
*-<<[LINK 조장수]--------------------------------2026.07.13 E

*   직납적용
    IF SY-TCODE EQ 'ZGTLER1111'.
      IF NOT ( GT_MAIN-LGORT IN GR_LGORT_DIR ).
        DELETE GT_MAIN INDEX LV_INDEX.
      ENDIF.
    ENDIF.

*___출하/영업 확정여부
    IF GT_MAIN-LECFM = 'CM' OR GT_MAIN-LECFM = 'CS' OR
       GT_MAIN-SDCFM = 'CM'.
      GT_MAIN-CONFM = 'X'.
    ENDIF.


    GT_MAIN-INDMEI = 'EA'.

*___납품생성 단위 Key Field
    MOVE-CORRESPONDING GT_MAIN TO GT_MAIN-KEYNO.

*--->>제조지시번호 제외 2026.07.04--------------------S
    GT_MAIN-KEYNO-KEYNO = GT_MAIN-VBELN.
*    IF GT_MAIN-JOBNO IS NOT INITIAL.
*      GT_MAIN-KEYNO-KEYNO = GT_MAIN-JOBNO.   "제조지시번호
*    ELSE.
**      IF GT_MAIN-DLVRQ(8) <> '20160712'.
**        GT_MAIN-KEYNO-KEYNO = GT_MAIN-DLVRQ.   "출하요청번호
**      ENDIF.
*    ENDIF.
*---<<제조지시번호 제외 2026.07.04--------------------E

*   총중량 표시
    CLEAR : LV_NTGEW.
    CONSTANTS : LV_FT LIKE MARA-NTGEW VALUE '0.305'.

    IF GT_MAIN-MATNR IS NOT INITIAL.
      READ TABLE GT_MATNR INTO DATA(LS_MATNR) WITH KEY MATNR = GT_MAIN-MATNR
                                              BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LV_NTGEW      = LS_MATNR-NTGEW.
        GT_MAIN-GEWEI = LS_MATNR-GEWEI.
      ENDIF.
    ENDIF.

    GT_MAIN-NTGEW = LV_NTGEW * GT_MAIN-REVMG.

    IF GT_MAIN-VRKME = 'FT'. "판매단위가 FT인경우
      GT_MAIN-NTGEW = GT_MAIN-NTGEW * LV_FT.
    ENDIF.

    GT_MAIN-NTGEW_M = LV_NTGEW.

    CLEAR : LV_DATE.
    LV_DATE = SY-DATUM + 1.

    CALL FUNCTION 'ZTR_GET_AFTER_WORKDAY'
      EXPORTING
        I_DATE      = LV_DATE
        I_CALENDAR1 = 'LS'
      IMPORTING
        O_WORKDAY   = GT_MAIN-WADAT.

    ""폭/드럼,약경/드럼,드럼무게/개
    IF P_CBM IS NOT INITIAL.
      DATA(LS_CBM) = VALUE #( GT_ZGTEDSIF0034[ VBELN = GT_MAIN-VBELN
                                               POSNR = GT_MAIN-POSNR ] OPTIONAL ).
      IF LS_CBM IS NOT INITIAL.
        "폭/드럼
        GT_MAIN-OUT_WID   = LS_CBM-OUT_WID.
        "약경/드럼
        GT_MAIN-PLAN_DIA  = LS_CBM-BARREL_DIA.
        "드럼무게/개
        GT_MAIN-DR_WEIGHT = LS_CBM-BRGEW.
      ENDIF.
    ENDIF.
*    PERFORM GET_CBM_DATA CHANGING GT_MAIN.
    "총 중량(드럼포함)
*    PERFORM GET_TOTAL_WEIGHT CHANGING GT_MAIN.
    PERFORM GET_TOTAL_WEIGHT_NEW CHANGING GT_MAIN.

    GT_MAIN-MEINS_MM = 'EA'.

*___판매처 명
    IF GT_MAIN-KUNAG IS NOT INITIAL.
      GT_MAIN-NAMAG = VALUE #( GT_KNA1[ KUNNR = GT_MAIN-KUNAG ]-NAME1 OPTIONAL ).
    ENDIF.

*___납품처명
    IF GT_MAIN-NAMWE IS NOT INITIAL.
      GT_MAIN-NAMWE = VALUE #( GT_KNA1[ KUNNR = GT_MAIN-NAMWE ]-NAME1 OPTIONAL ).
    ENDIF.

*___제품명
    IF GT_MAIN-MATNR IS NOT INITIAL.
      GT_MAIN-MAKTX = VALUE #( GT_MATNR[ MATNR = GT_MAIN-MATNR ]-MAKTX OPTIONAL ).
    ENDIF.

*___출하지점명
    IF GT_MAIN-VSTEL IS NOT INITIAL.
      GT_MAIN-VTEXT = VALUE #( GT_TVSTT[ VSTEL = GT_MAIN-VSTEL ]-VTEXT OPTIONAL ).
    ENDIF.

*___플랜트명
    IF GT_MAIN-WERKS IS NOT INITIAL.
      GT_MAIN-NAME1 = VALUE #( GT_T001W[ WERKS = GT_MAIN-WERKS ]-NAME1 OPTIONAL ).
    ENDIF.

*___저장위치명
    IF GT_MAIN-WERKS IS NOT INITIAL AND GT_MAIN-LGORT IS NOT INITIAL.
      PERFORM GET_LGORT_DESC USING GT_MAIN-WERKS
                                   GT_MAIN-LGORT
                                   GT_MAIN-LGORT_TX.
    ENDIF.

*___차량제한
    PERFORM GET_VHCTP_DESC USING GT_MAIN-VHCTP
                                 GT_MAIN-VHCTX.


    MODIFY GT_MAIN.

    CLEAR:LS_MATNR.
  ENDLOOP.

*___출하요청 확정을 통하지 않고 생성한 납품문서로 인해 판매오더의 잔량이
*   없는 경우 확정(시스템) 처리
  LOOP AT GT_0401.
    UPDATE ZLET0401 SET LECFM = GT_0401-LECFM
                        REVMG = GT_0401-REVMG
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                        AENAM = SY-UNAME
                  WHERE DLVRQ = GT_0401-DLVRQ
                    AND VBELN = GT_0401-VBELN
                    AND POSNR = GT_0401-POSNR.
  ENDLOOP.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
    MESSAGE S004 WITH '확정(시스템) 처리된 출하요청이 있습니다.'.
    LOOP AT GT_0401 INTO DATA(LS_0401).
      READ TABLE GT_MAIN ASSIGNING FIELD-SYMBOL(<FS_MAIN>) WITH KEY
      DLVRQ = LS_0401-DLVRQ
      VBELN = LS_0401-VBELN
      POSNR = LS_0401-POSNR.
      IF SY-SUBRC EQ 0.
        <FS_MAIN>-REVMG = LS_0401-REVMG.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CBM_DATA_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CBM_DATA_INFO .

  CLEAR:GT_ZGTEDSIF0034,GT_ZGTEDSIF0034[].

  CHECK GT_MAIN[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR.

  GT_ZGTEDSIF0034[] = CORRESPONDING #( LT_TEMP[] ).

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      OT_OUTPUT = GT_ZGTEDSIF0034.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL_WEIGHT_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_MAIN
*&---------------------------------------------------------------------*
FORM GET_TOTAL_WEIGHT_NEW  CHANGING PS_MAIN LIKE GT_MAIN.
  DATA : LV_FT LIKE MARA-NTGEW VALUE '0.305'.
  DATA : LV_MENGE    TYPE LIPS-LFIMG,
         LV_INDQTY   TYPE ZLET0401-INDQTY,
         LV_NTGEW_DR TYPE MARA-NTGEW,
         LV_NTGEW_MM TYPE MARA-NTGEW.
  "DRIND

*-제품중량
  IF GT_MAIN-MATNR IS NOT INITIAL.
    READ TABLE GT_MATNR INTO DATA(LS_MARA) WITH KEY MATNR = GT_MAIN-MATNR
                                            BINARY SEARCH.
  ENDIF.
*  SELECT SINGLE MEINS,NTGEW,GEWEI
*    FROM MARA
*   WHERE MATNR EQ @PS_MAIN-MATNR
*    INTO @DATA(LS_MARA).

* 확정인 경우 : 출하요청수량/출하요청조장수
  IF PS_MAIN-LECFM = 'CM' OR PS_MAIN-LECFM = 'CS'.
    "출하요청 수량
    LV_MENGE = PS_MAIN-DLRMG.

    "출하요청 조장수
    LV_INDQTY = PS_MAIN-DRIND.

  ELSE.
* 미확정인 경우 : 출하확정수량/출하확정조장수
    "출하확정 수량
    LV_MENGE = PS_MAIN-REVMG.

    "출하확정 조장수
    LV_INDQTY = PS_MAIN-RVIND.
  ENDIF.

  "자재 기본단위로 변경
  IF PS_MAIN-VRKME NE LS_MARA-MEINS.
    IF PS_MAIN-VRKME EQ 'FT'. "판매단위가 FT인경우.
      LV_MENGE = LV_MENGE * LV_FT.
    ELSE.
      LV_MENGE = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR =
      PS_MAIN-MATNR
                                                             IV_IN_ME =
PS_MAIN-VRKME
                                                             IV_OT_ME =
LS_MARA-MEINS
                                                             IV_MENGE =
                                                             LV_MENGE
                                                             ).
    ENDIF.
  ENDIF.

  LV_NTGEW_MM = LS_MARA-NTGEW * LV_MENGE.

  "중량단위 'KG'
  IF LS_MARA-GEWEI NE GC_MEINS_KG.
    LV_NTGEW_MM = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR =
    PS_MAIN-MATNR
                                                              IV_IN_ME =
LS_MARA-GEWEI
                                                              IV_OT_ME =
GC_MEINS_KG
                                                              IV_MENGE =
LV_NTGEW_MM        ).
  ENDIF.

*-총중량(드럼포함) : 드럼무게/개 + 제품중량
  PS_MAIN-BRGEW = ( PS_MAIN-DR_WEIGHT * LV_INDQTY ) + LV_NTGEW_MM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DO_QTY_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DO_QTY_INFO .
  CLEAR:GT_LIPS_SUM,GT_LIPS_SUM[].

  CHECK GT_MAIN[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT B~VGBEL AS VBELN,
           B~VGPOS AS POSNR,
           SUM( B~LFIMG ) AS LFIMG
      FROM @LT_TEMP AS A INNER JOIN LIPS AS B
                        ON A~VBELN = B~VGBEL AND
                           A~POSNR = B~VGPOS
      GROUP BY B~VGBEL, B~VGPOS
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIPS_SUM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LINK_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_LINK_JOJANG .
  DATA:LT_SEARCH LIKE TABLE OF ZGTSDSIF0096,
       LS_SEARCH LIKE ZGTSDSIF0096,
       LS_RETURN TYPE  ZSDS_LOG_0001_GO.
  DATA:LS_D365_LOGIN TYPE  ZSDS_LOG_0000_GO,
       LV_MODE       TYPE  ZGTEMODE_STOCK  VALUE 'Z'.

  CHECK GT_MAIN[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_MAIN[].
  SORT LT_TEMP BY VBELN POSNR MATNR WERKS.
  DELETE LT_TEMP WHERE MATNR IS INITIAL.
  DELETE LT_TEMP WHERE WERKS IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR MATNR WERKS.

  CHECK LT_TEMP[] IS NOT INITIAL.
  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
    CLEAR: LS_SEARCH.
    LS_SEARCH-MATNR = LS_TEMP-MATNR.
    LS_SEARCH-WERKS = LS_TEMP-WERKS.
    LS_SEARCH-VBELN = LS_TEMP-VBELN.
    LS_SEARCH-POSNR = LS_TEMP-POSNR.
    COLLECT LS_SEARCH INTO LT_SEARCH.
  ENDLOOP.

  LS_D365_LOGIN-ENAME = SY-UNAME.

  CALL FUNCTION 'ZSD_365_0050_0040_GO'
    EXPORTING
      IS_D365_LOGIN    = LS_D365_LOGIN
      I_MODE           = LV_MODE
    IMPORTING
      ES_RETURN        = LS_RETURN
    TABLES
      IT_SEARCH        = LT_SEARCH
*     ET_AVL_ITEM      = LT_AVL_ITEM
      ET_LSTOCK_ITEM   = GT_LSTOCK_ITEM
      ET_LSTOCK_DETAIL = GT_LSTOCK_DETAIL
      ET_ESTOCK_ITEM   = GT_ESTOCK_ITEM
      ET_ESTOCK_DETAIL = GT_ESTOCK_DETAIL.

  SORT: GT_LSTOCK_ITEM   BY VBELN POSNR MATNR,
        GT_LSTOCK_DETAIL BY VBELN POSNR MATNR WERKS,
        GT_ESTOCK_ITEM   BY VBELN POSNR MATNR,
        GT_ESTOCK_DETAIL BY VBELN POSNR MATNR WERKS.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINK_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_MAIN
*&---------------------------------------------------------------------*
FORM SET_LINK_JOJANG  CHANGING PS_MAIN LIKE GT_MAIN.
  DATA: LV_RVIND LIKE ZLET0401-INDQTY.
  DATA: LV_RVIND_DIFF LIKE ZLET0401-INDQTY.

  CHECK PS_MAIN-INDLEN NE 0.
  CHECK PS_MAIN-REMMG  NE 0.

  "출하조장수
  LV_RVIND = PS_MAIN-REMMG / PS_MAIN-INDLEN.

  READ TABLE GT_LSTOCK_ITEM INTO DATA(LS_LSTOCK_ITEM) WITH KEY VBELN = PS_MAIN-VBELN
                                                               POSNR = PS_MAIN-POSNR
                                                               MATNR = PS_MAIN-MATNR
                                                      BINARY SEARCH.
  IF SY-SUBRC EQ 0 AND LS_LSTOCK_ITEM-LSTOCK NE 0.
    "저장위치
    IF PS_MAIN-RVIND IS INITIAL.
      READ TABLE GT_LSTOCK_DETAIL INTO DATA(LS_LSTOCK_DETAIL) WITH KEY VBELN = PS_MAIN-VBELN
                                                                       POSNR = PS_MAIN-POSNR
                                                                       MATNR = PS_MAIN-MATNR
                                                                       WERKS = PS_MAIN-WERKS
                                                              BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        PS_MAIN-LGORT = LS_LSTOCK_DETAIL-LGORT.
      ENDIF.
    ENDIF.
    "LINK 조장수
    PS_MAIN-RVIND_LINK = LS_LSTOCK_ITEM-LSTOCK.

    IF PS_MAIN-RVIND < LV_RVIND.
      LV_RVIND_DIFF = LV_RVIND - PS_MAIN-RVIND.

      IF LV_RVIND_DIFF <= PS_MAIN-RVIND_LINK.
        "출하확정 조장수
        PS_MAIN-RVIND      = PS_MAIN-RVIND + LV_RVIND_DIFF. "PS_MAIN-RVIND_LINK.
      ELSE.
        "출하확정 조장수
        PS_MAIN-RVIND      = PS_MAIN-RVIND + PS_MAIN-RVIND_LINK.
      ENDIF.
      "출하확정수량
      PS_MAIN-REVMG      = PS_MAIN-INDLEN * PS_MAIN-RVIND.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_selected_rows1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS1  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.
*[S] 안정화   사용자 실수로 납지 변경되지 않도록 수정
  DATA: LV_ADDRESS TYPE C LENGTH 100,         "상세주소 전체
        LV_CNT1    TYPE I.
*[E] 안정화
  CLEAR : PV_ERROR.

  LOOP AT GT_MAIN WHERE ITSEL = 'X'.
*[S] 안정화   사용자 실수로 납지 변경되지 않도록 수정
    IF LV_CNT = 0.
      LV_ADDRESS = GT_MAIN-ADDRESS.
    ENDIF.
*[E] 안정화
    LV_CNT = LV_CNT + 1.

*[S] 안정화   사용자 실수로 납지 변경되지 않도록 수정
    IF LV_ADDRESS NE GT_MAIN-ADDRESS AND  LV_CNT1 =  0.
      LV_CNT1 = 1.
      PV_ERROR = 'X'.
      MESSAGE S113 DISPLAY LIKE 'E'.
    ENDIF.
*[E] 안정화

  ENDLOOP.

  IF LV_CNT IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S100 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
