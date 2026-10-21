FUNCTION ZGTMM_IF_I_IMGR_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_HEAD STRUCTURE  ZGTMMSIF0010
*"      IT_ITEM STRUCTURE  ZGTMMSIF0011
*"      OT_TAB STRUCTURE  ZGTMMSIF0017
*"      OT_ITEM STRUCTURE  ZGTMMSIF0021 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_IMGR_RCV
*& 프로그램 명 : 수입 자재 입고 정보 수신
*& 개요   : 수입 자재 입고 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.07
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.06.10
*& 수정자  : ZGSIDEV03
*& 수정개요: 구미 물자 창고 WMS 도입
*&---------------------------------------------------------------------*

  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' 'MM00007' ' ' ' '.

  CLEAR : GT_I10[], GT_I11[], GT_I17[], GT_I21[].

  GT_I10[] = IT_HEAD[].
  GT_I11[] = IT_ITEM[].
  SORT GT_I10 BY ICCNO ICCSQ.
  SORT GT_I11 BY ICCNO ICCIT.

  PERFORM SET_907X_LOG.

  "수입 입고 or 취소
  PERFORM RUN_IMGR_RCV.

  PERFORM RTN_RST_MSG TABLES GT_I17.

  PERFORM SET_EAI_MSG USING GV_ZSTAT CHANGING ZO_RESULT
                                              ZO_MESSAGE.
* "Export Parameter : 고정값
* ZO_RESULT  = '00'.
* ZO_MESSAGE = '전송 데이터 처리 성공'.

  OT_TAB[]  = GT_I17[].
  OT_ITEM[] = GT_I21[]. "추가(SJM 25.06.10)

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_907X_LOG
*&---------------------------------------------------------------------*
FORM SET_907X_LOG.

* DATA : LV_SEQ TYPE I.


  "수신 Data Log Table 저장

  CLEAR : GT_9070[], GT_9071[], GT_9072[].

* GT_9070[] = CORRESPONDING #( GT_I10[] ).
* GT_9070-ZIFKEY = GT_9000-ZIFKEY.
* MODIFY GT_9070 TRANSPORTING ZIFKEY WHERE ZIFKEY IS INITIAL.
  GT_9070[] = VALUE #( FOR LS_I10 IN GT_I10
                       ( VALUE #( BASE CORRESPONDING #( LS_I10 )
                                  ZIFKEY = GT_9000-ZIFKEY ) ) ).

* LOOP AT GT_I11.
*   LV_SEQ += 1.
*
*   CLEAR : GT_9071.
*   MOVE-CORRESPONDING GT_I11 TO GT_9071.
*   GT_9071-ZIFKEY = GT_9000-ZIFKEY.
*   GT_9071-SEQNO  = LV_SEQ.
*   CONDENSE GT_9071-SEQNO.
*
*   APPEND GT_9071.
* ENDLOOP.
  GT_9071[] = VALUE #( FOR LS_I11 IN GT_I11
                       ( VALUE #( BASE CORRESPONDING #( LS_I11 )
                                  ZIFKEY = GT_9000-ZIFKEY
                                  SEQNO  = CONDENSE( REDUCE I( INIT X = 1
                                                               FOR LS_9071 IN GT_9071
                                                               NEXT X += 1 ) ) ) ) ).

  MODIFY ZGTMMT9071 FROM TABLE GT_9071.
  MODIFY ZGTMMT9070 FROM TABLE GT_9070.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_IMGR_RCV
*&---------------------------------------------------------------------*
FORM RUN_IMGR_RCV.

  LOOP AT GT_I10.
    CASE GT_I10-TYPE.
      WHEN 'I'.
        PERFORM RUN_I_TYPE. "수입 입고
      WHEN 'C'.
        PERFORM RUN_C_TYPE. "수입 취소
    ENDCASE.
  ENDLOOP.

  CHECK GT_9072[] IS NOT INITIAL.
  MODIFY ZGTMMT9072 FROM TABLE GT_9072.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_I_TYPE
*&---------------------------------------------------------------------*
FORM RUN_I_TYPE.

  DATA : LS_ZTITGRK LIKE ZTITGRK.

  DATA : LV_GRMNG LIKE GS_ZTISCCIT-GRMNG.

*  DATA : LT_ZPPT0001 TYPE TABLE OF ZPPT0001,
*         LT_ZPPT0001 TYPE ZPPT0001.
*  DATA : GS_MSEG    TYPE MSEG.
*  CLEAR : LT_ZPPT0001.


  PERFORM GET_ICCNO_INFO.

  "SET 입고 헤더용 기초 Value
  PERFORM SET_GR_INITIAL_DATA USING LS_ZTITGRK.
  "Item 기타 정보 Read
  PERFORM SET_OTHERS_FIELDS_BY_ITEMS.


  CLEAR : GS_MHDR,   GS_MCOD,   GS_MHDRT,
          GT_MITM[], GT_MSRN[], GT_RTN[].

  CLEAR : GV_LINE,   GT_T21[].  "추가(SJM 25.06.10)

  GS_MCOD-GM_CODE = '01'.
  GV_MVT_IND      = 'B'.

  PERFORM SET_IMGR_HEAD USING LS_ZTITGRK.

  LOOP AT GT_I11 WHERE ICCNO = GT_I10-ICCNO. "추가
    PERFORM SET_IMGR_ITEM. "SET_GR_DATA_ITEM
    PERFORM SET_XGR_LOT TABLES GT_T21 "추가(SJM 25.06.10)
                         USING GT_I11
                               GV_LINE.

    LV_GRMNG = LV_GRMNG + GT_I11-GRMNG.

    AT END OF ICCIT.
      LOOP AT GT_ZTITCCP INTO GS_ZTISCCIT
                        WHERE ICCNO = GT_I11-ICCNO
                          AND ICCIT = GT_I11-ICCIT.

        GS_ZTISCCIT-GRMNG = LV_GRMNG.
        MODIFY GT_ZTITCCP FROM GS_ZTISCCIT TRANSPORTING GRMNG.
        CLEAR : LV_GRMNG.
      ENDLOOP.
    ENDAT.
  ENDLOOP.

  PERFORM BAPI_GOODSMVT_CREATE.

  IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
    PERFORM BAPI_COMMIT.

    "Table Modify
    PERFORM MODIFY_ZTITGRK USING LS_ZTITGRK.
    PERFORM MODIFY_ZTITGRP USING LS_ZTITGRK.
    PERFORM MODIFY_ZTITGRB USING LS_ZTITGRK.

    "Return Message
    PERFORM RTN_IMGR_RCV USING 'S' '수입자재 입고 성공'(M01).
  ELSE.
    PERFORM BAPI_ROLLBACK.

    "Return Message
    READ TABLE GT_RTN WITH KEY TYPE = 'E'.

    IF SY-SUBRC = 0.
      PERFORM RTN_IMGR_RCV USING 'E' GT_RTN-MESSAGE.
    ELSE.
      PERFORM RTN_IMGR_RCV USING 'E' '수입자재 입고 실패'(M02).
    ENDIF.
  ENDIF.

  "구미 물자 창고 WMS 도입(SJM 25.06.10)
  DATA(LV_RST) = COND #( WHEN GS_MHDRT-MAT_DOC = SPACE THEN GC_E
                                                       ELSE GC_S ).

  PERFORM UPD_XGR_LOT TABLES GT_T21
                             GT_I21
                       USING LV_RST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ICCNO_INFO
*&---------------------------------------------------------------------*
FORM GET_ICCNO_INFO.

* CLEAR : ZTITIG00, ZTITBLK.

  CLEAR : GS_ZTITCCK, GT_ZTITCCP, GS_ZTISCCIT.

  SELECT MAX( ICCSQ )
    FROM ZTITCCK INTO @DATA(LV_ICCSQ)
   WHERE ICCNO = @GT_I10-ICCNO.

  CALL FUNCTION 'Z_TI_GET_CUSTOM_IMPORT'
    EXPORTING
      ICCNO     = GT_I10-ICCNO
      ICCSQ     = CONV ZTIICCSQ( LV_ICCSQ )
    IMPORTING
      ZTITCCK   = GS_ZTITCCK
    TABLES
      ZTITCCP   = GT_ZTITCCP
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*(S)미사용으로 보여 주석처리..
*  SELECT SINGLE * FROM ZTITIG00 WHERE BUKRS EQ '1000'.
*
*  SELECT SINGLE * FROM ZTITBLK
*   WHERE IBLNO EQ GS_ZTITCCK-IBLNO.
*(E)미사용으로 보여 주석처리..

  SORT GT_ZTITCCP BY ICCNO ICCIT. "추가

  LOOP AT GT_ZTITCCP INTO GS_ZTISCCIT.
    GS_ZTISCCIT-GRMNG = GS_ZTISCCIT-GRMNGL.

    IF GS_ZTISCCIT-MATNR IS NOT INITIAL.
      SELECT SINGLE MATKL MTART
        FROM MARA
        INTO (GS_ZTISCCIT-MATKL, GS_ZTISCCIT-MTART)
       WHERE MATNR = GS_ZTISCCIT-MATNR.
    ENDIF.

    MODIFY GT_ZTITCCP FROM GS_ZTISCCIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GR_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM SET_GR_INITIAL_DATA USING PS_ZTITGRK STRUCTURE ZTITGRK.

  DATA : LS_ZTITBLK LIKE ZTITBLK,
         ZTITIG00   LIKE ZTITIG00. "미사용??


  CLEAR : PS_ZTITGRK.

  PS_ZTITGRK-ICCNO = GS_ZTITCCK-ICCNO.
  PS_ZTITGRK-IBLNO = GS_ZTITCCK-IBLNO.

  SELECT SINGLE *
    FROM ZTITBLK INTO LS_ZTITBLK
   WHERE IBLNO = PS_ZTITGRK-IBLNO.

  IF PS_ZTITGRK-IGRTY IS INITIAL. "Initial이 아닐수도 있나??? (아래 쭉~~)
    IF LS_ZTITBLK-BLDTY = 'O'.
      PS_ZTITGRK-IGRTY = 'R'.
    ELSE.
      PS_ZTITGRK-IGRTY = 'P'.
    ENDIF.
  ENDIF.

  PS_ZTITGRK-RPTTY = LS_ZTITBLK-RPTTY.
  PS_ZTITGRK-IBLNO = LS_ZTITBLK-IBLNO. "왜 또???
  PS_ZTITGRK-LIFNR = LS_ZTITBLK-LIFNR.
  PS_ZTITGRK-PSPNR = LS_ZTITBLK-PSPNR.

  "이동유형
  IF PS_ZTITGRK-BWART IS INITIAL.
    SELECT SINGLE * FROM ZTITIG00 "미사용 로직으로 보이는데 왜??
     WHERE BUKRS = LS_ZTITBLK-BUKRS.

    IF PS_ZTITGRK-IGRTY = 'P'.
      PS_ZTITGRK-BWART = '101'.
    ELSEIF PS_ZTITGRK-IGRTY = 'R'.
      PS_ZTITGRK-BWART = '901'.
    ENDIF.
  ENDIF.

  "참조전표번호
  IF PS_ZTITGRK-FRBNR IS INITIAL.
    PS_ZTITGRK-FRBNR = GS_ZTITCCK-CBLNO.
  ENDIF.
  "참조전표번호
  IF PS_ZTITGRK-XBLNR IS INITIAL.
    PS_ZTITGRK-XBLNR = '통관:'(T01) && PS_ZTITGRK-ICCNO.
  ENDIF.

  IF PS_ZTITGRK-WAERS IS INITIAL.
    PS_ZTITGRK-WAERS = LS_ZTITBLK-WAERS.
  ENDIF.

  IF PS_ZTITGRK-BUKRS IS INITIAL.
    PS_ZTITGRK-BUKRS = LS_ZTITBLK-BUKRS.
  ENDIF.

  "입고순번
  IF PS_ZTITGRK-GRSEQ IS INITIAL.
    IF PS_ZTITGRK-ICCNO IS INITIAL.
      SELECT MAX( GRSEQ )
        FROM ZTITGRK INTO PS_ZTITGRK-GRSEQ
       WHERE IBLNO = PS_ZTITGRK-IBLNO.
    ELSE.
      SELECT MAX( GRSEQ )
        FROM ZTITGRK INTO PS_ZTITGRK-GRSEQ
       WHERE ICCNO = PS_ZTITGRK-ICCNO.
    ENDIF.
    ADD 1 TO PS_ZTITGRK-GRSEQ.
  ENDIF.

  "헤더 텍스트
  IF PS_ZTITGRK-BKTXT IS INITIAL.
    PS_ZTITGRK-BKTXT = '수입 물품 입고'(T02).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
FORM SET_OTHERS_FIELDS_BY_ITEMS.

  "미사용 로직으로 보여 주석처리. 확인!!
  " Loop 돌면서 값을 가져오긴 하는데.. Modify 하는 부분이 없음..

*  LOOP AT GT_ZTITCCP INTO GS_ZTISCCIT.
*    "Text
*    SELECT SINGLE MAKTX
*      INTO GS_ZTISCCIT-TXZ01
*      FROM MAKT
*      WHERE MATNR = GS_ZTISCCIT-MATNR
*       AND SPRAS = SY-LANGU.
*
**- 정가 계산
*    IF GS_ZTISCCIT-GRMNG NE '0'.
*      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*        EXPORTING
*          PEINH = GS_ZTISCCIT-PEINH
*          BPUMZ = GS_ZTISCCIT-BPUMZ
*          BPUMN = GS_ZTISCCIT-BPUMN
*          MENGE = GS_ZTISCCIT-GRMNG
*          NETPR = GS_ZTISCCIT-NETPR
*        CHANGING
*          NETWR = GS_ZTISCCIT-NETWR.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IMGR_HEAD
*&---------------------------------------------------------------------*
FORM SET_IMGR_HEAD USING PS_ZTITGRK STRUCTURE ZTITGRK.

  GS_MHDR-PSTNG_DATE     = GT_I10-BUDAT.
  GS_MHDR-DOC_DATE       = GT_I10-BUDAT.
  GS_MHDR-REF_DOC_NO     = PS_ZTITGRK-XBLNR.
  GS_MHDR-BILL_OF_LADING = PS_ZTITGRK-FRBNR.
  GS_MHDR-GR_GI_SLIP_NO  = SPACE.
  GS_MHDR-PR_UNAME       = SY-UNAME.
  GS_MHDR-HEADER_TXT     = PS_ZTITGRK-BKTXT.
  GS_MHDR-EXT_WMS        = PS_ZTITGRK-WEVER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IMGR_ITEM
*&---------------------------------------------------------------------*
FORM SET_IMGR_ITEM.

  DATA : LS_EKPO LIKE EKPO.


  READ TABLE GT_ZTITCCP INTO GS_ZTITCCP WITH KEY ICCNO = GT_I11-ICCNO
                                                 ICCIT = GT_I11-ICCIT
                                                 BINARY SEARCH.
  IF SY-SUBRC = 0.
    SELECT SINGLE * FROM EKPO INTO LS_EKPO
     WHERE EBELN = GS_ZTITCCP-EBELN
       AND EBELP = GS_ZTITCCP-EBELP.

*   SELECT SINGLE * FROM EKKO INTO LS_EKKO
    SELECT SINGLE LIFNR FROM EKKO INTO @DATA(LV_LIFNR)
     WHERE EBELN = @GS_ZTITCCP-EBELN.
  ENDIF.

  GV_LINE += 1.
  CLEAR : GT_MITM, GT_MSRN.

  GT_MITM-MATERIAL             = LS_EKPO-MATNR.
  GT_MITM-PLANT                = LS_EKPO-WERKS.
  GT_MITM-STGE_LOC             = GT_I11-LGORT.
  GT_MITM-BATCH                = GT_I11-CHARG.
  GT_MITM-MOVE_TYPE            = '101'.
  GT_MITM-VENDOR               = LV_LIFNR.
  GT_MITM-ENTRY_QNT            = GT_I11-GRMNG.
  GT_MITM-ENTRY_UOM            = GT_I11-MEINS.
  GT_MITM-ORDERPR_UN           = LS_EKPO-BPRME.
  GT_MITM-PO_NUMBER            = LS_EKPO-EBELN.
  GT_MITM-PO_ITEM              = LS_EKPO-EBELP.
* GT_MITM-NO_MORE_GR           = G_NO_MORE_GR.
  GT_MITM-ITEM_TEXT            = GT_I11-LOTNO.
  GT_MITM-GR_RCPT              = SY-UNAME.
  GT_MITM-RESERV_NO            = GS_ZTITCCP-RSNUM.
  GT_MITM-RES_ITEM             = GS_ZTITCCP-RSPOS.
  GT_MITM-RES_TYPE             = GS_ZTITCCP-RSART.
  GT_MITM-MVT_IND              = GV_MVT_IND.
  GT_MITM-PROD_DATE            = GT_I11-HSDAT.
  GT_MITM-DELIV_NUMB_TO_SEARCH = GS_ZTITCCP-VBELN.
  GT_MITM-DELIV_ITEM_TO_SEARCH = GS_ZTITCCP-POSNR.
  GT_MITM-SUPPL_VEND           = LV_LIFNR.
  APPEND GT_MITM.

  GT_MSRN-MATDOC_ITM = GV_LINE.
  GT_MSRN-SERIALNO   = GT_MITM-BATCH.
  APPEND GT_MSRN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_IGRNO
*&---------------------------------------------------------------------*
FORM GET_IGRNO USING PV_IGRNO.

  DATA : LV_ZMPTY TYPE ZTIREQTY VALUE 'GR',
         LV_LCONO TYPE ZTIREQNO.


  CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
    EXPORTING
      ZMPTY    = LV_ZMPTY
    IMPORTING
      LCONO    = LV_LCONO
    EXCEPTIONS
      NOT_TYPE = 1
      OTHERS   = 2.

  CHECK SY-SUBRC = 0.
  PV_IGRNO = LV_LCONO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZTITGRK
*&---------------------------------------------------------------------*
FORM MODIFY_ZTITGRK USING PS_ZTITGRK STRUCTURE ZTITGRK.

  "Header table modify

  IF PS_ZTITGRK-IGRNO IS INITIAL.
    PERFORM GET_IGRNO USING PS_ZTITGRK-IGRNO.
  ENDIF.

  PS_ZTITGRK-ICCNO = GT_I10-ICCNO.
  PS_ZTITGRK-BUDAT = GT_I10-BUDAT.
  PS_ZTITGRK-BLDAT = GT_I10-BUDAT.
  PS_ZTITGRK-MBLNR = GS_MHDRT-MAT_DOC.
  PS_ZTITGRK-MJAHR = GS_MHDRT-DOC_YEAR.
  PS_ZTITGRK-IGRST = 'G'.

  IF PS_ZTITGRK-CNAM IS INITIAL.
    PS_ZTITGRK-CNAM = SY-UNAME.
    PS_ZTITGRK-CDAT = SY-DATLO.
    PS_ZTITGRK-CTME = SY-TIMLO.
  ENDIF.
  PS_ZTITGRK-UNAM = SY-UNAME.
  PS_ZTITGRK-UDAT = SY-DATLO.
  PS_ZTITGRK-UTME = SY-TIMLO.

  MODIFY ZTITGRK FROM PS_ZTITGRK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZTITGRP
*&---------------------------------------------------------------------*
FORM MODIFY_ZTITGRP USING PS_ZTITGRK STRUCTURE ZTITGRK.

  DATA : LT_ZTITGRP LIKE VZTITGRP OCCURS 0 WITH HEADER LINE.

  "Items table modify

  DELETE FROM ZTITGRP WHERE IGRNO = PS_ZTITGRK-IGRNO.

  LOOP AT GT_ZTITCCP INTO GS_ZTISCCIT.
    CLEAR : LT_ZTITGRP.
    MOVE-CORRESPONDING GS_ZTISCCIT TO LT_ZTITGRP.

    LT_ZTITGRP-GRMNG  = GS_ZTISCCIT-GRMNG.
    LT_ZTITGRP-MATNR  = GS_ZTISCCIT-MATNR.
    LT_ZTITGRP-TXZ01  = GS_ZTISCCIT-TXZ01.
    LT_ZTITGRP-IGRNO  = PS_ZTITGRK-IGRNO.
    LT_ZTITGRP-BWART  = PS_ZTITGRK-BWART.
    LT_ZTITGRP-GRSEQ  = PS_ZTITGRK-GRSEQ.
    LT_ZTITGRP-SHKZG  = 'S'.
    LT_ZTITGRP-WERKS  = '1302'. "1404
    LT_ZTITGRP-BATCHX = 'X'.
    LT_ZTITGRP-IFCHK  = 'X'.
    APPEND LT_ZTITGRP.
  ENDLOOP.

  MODIFY ZTITGRP FROM TABLE LT_ZTITGRP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZTITGRB
*&---------------------------------------------------------------------*
FORM MODIFY_ZTITGRB USING PS_ZTITGRK STRUCTURE ZTITGRK.

  DATA : LV_IBCIT TYPE ZTITGRB-IBCIT.


  "Items Batch table modify
  CLEAR : GT_ZTITGRB.
  DELETE FROM ZTITGRB WHERE IGRNO = PS_ZTITGRK-IGRNO.

  LOOP AT GT_I11.
    CLEAR : GS_ZTITGRB.
    READ TABLE GT_ZTITCCP INTO GS_ZTISCCIT WITH KEY ICCNO = GT_I11-ICCNO
                                                    ICCIT = GT_I11-ICCIT
                                                    BINARY SEARCH.

    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING GS_ZTISCCIT TO GS_ZTITGRB.
    ENDIF.

    AT NEW ICCIT.
      CLEAR : LV_IBCIT.
    ENDAT.

    LV_IBCIT += 1.
    GS_ZTITGRB-IBCIT = LV_IBCIT.

    GS_ZTITGRB-IGRNO = PS_ZTITGRK-IGRNO.
    GS_ZTITGRB-BWART = PS_ZTITGRK-BWART.
    GS_ZTITGRB-WERKS = '1302'. "1404
    GS_ZTITGRB-TXZ01 = GS_ZTISCCIT-TXZ01.
    GS_ZTITGRB-LGORT = GT_I11-LGORT.
    GS_ZTITGRB-GRMNG = GT_I11-GRMNG.
    GS_ZTITGRB-MEINS = GT_I11-MEINS.
    GS_ZTITGRB-BATCH = GT_I11-CHARG.
    GS_ZTITGRB-ZEILE = SY-TABIX.
    APPEND GS_ZTITGRB TO GT_ZTITGRB.


*&-----------------------------------------------
*& 한국미래소재(KFCM) 꼬리표 관리 안함 - [s]
*&-----------------------------------------------
    "작업실적 테이블(꼬리표) 업데이트
*    PERFORM MODIFY_ZPPT0001_IMGR. "-> 주석처리
    CASE GV_SYSTEM_ID.
      WHEN 'KFCM'.

      WHEN OTHERS.
        PERFORM MODIFY_ZPPT0001_IMGR.
    ENDCASE.
*&-----------------------------------------------
*& 한국미래소재(KFCM) 꼬리표 관리 안함 - [e]
*&-----------------------------------------------
  ENDLOOP.

  MODIFY ZTITGRB FROM TABLE GT_ZTITGRB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_IMGR
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001_IMGR.

  DATA : LT_ZPPT0001 LIKE ZPPT0001 OCCURS 0 WITH HEADER LINE.


  "작업실적 테이블(꼬리표) 업데이트

  CHECK GT_I11-TAGNR IS NOT INITIAL
    AND GT_I11-CHARG IS NOT INITIAL.

  "단위환산
  PERFORM MD_CONVERT_MATERIAL_UNIT USING GS_ZTISCCIT-MATNR
                                         GT_I11-MEINS
                                         'M'
                                CHANGING GT_I11-GRMNG.

  PERFORM GET_DISPO USING '1302' "1404
                          GS_ZTISCCIT-MATNR.

  CLEAR : GS_MSEG, LT_ZPPT0001.

  "단위환산 정보(자재전표로 가져오기)
  SELECT SINGLE MENGE MEINS
    FROM MSEG
    INTO CORRESPONDING FIELDS OF GS_MSEG
   WHERE MBLNR = GS_MHDRT-MAT_DOC
     AND MJAHR = GS_MHDRT-DOC_YEAR
     AND CHARG = GT_I11-CHARG.

  SELECT SINGLE *
    FROM ZPPT0001
    INTO CORRESPONDING FIELDS OF LT_ZPPT0001
   WHERE WERKS = '1302'  "1404
     AND TAGNR = GT_I11-TAGNR.

  IF LT_ZPPT0001 IS NOT INITIAL. "Update
    DATA(LV_MGVRG) = GT_I11-GRMNG + LT_ZPPT0001-MGVRG.

    UPDATE ZPPT0001 SET GRFLG   = 'Y'
                        MGVRG   = LV_MGVRG
                        MBLNR   = GS_MHDRT-MAT_DOC
                        LGORT   = GT_I11-LGORT
                        WKDAT   = GS_MHDR-PSTNG_DATE
                        GRINDAT = SY-DATUM
                        GRINTIM = SY-UZEIT
                        GRINNAM = SY-UNAME
                  WHERE WERKS   = '1302'  "1404
                    AND TAGNR   = GT_I11-TAGNR.

  ELSE.                          "Insert
    LT_ZPPT0001-WERKS   = '1302'. "1404
    LT_ZPPT0001-AUFNR   = SPACE.
    LT_ZPPT0001-TAGNR   = GT_I11-TAGNR.
    LT_ZPPT0001-RUECK   = SPACE.
    LT_ZPPT0001-RMZHL   = SPACE.
    LT_ZPPT0001-POSNR   = GS_ZTISCCIT-EBELP.
    LT_ZPPT0001-CHARG   = GT_I11-CHARG.
    LT_ZPPT0001-MBLNR   = GS_MHDRT-MAT_DOC.
    LT_ZPPT0001-MATNR   = GS_ZTISCCIT-MATNR.
    LT_ZPPT0001-SPGCD   = GV_DISPO.
    LT_ZPPT0001-MGVRG   = GS_MSEG-MENGE.
    LT_ZPPT0001-REMAIN  = GS_MSEG-MENGE.
    LT_ZPPT0001-MEINS   = GS_MSEG-MEINS.
    LT_ZPPT0001-OUTFLG  = 'X'.
    LT_ZPPT0001-GIFLG   = 'N'.
    LT_ZPPT0001-GRFLG   = 'Y'.
    LT_ZPPT0001-INSPFLG = 'OK'.
    LT_ZPPT0001-LGORT   = GT_I11-LGORT.
    LT_ZPPT0001-WKDAT   = GS_MHDR-PSTNG_DATE.
    LT_ZPPT0001-GRINDAT = SY-DATUM.
    LT_ZPPT0001-GRINTIM = SY-UZEIT.
    LT_ZPPT0001-GRINNAM = SY-UNAME.
    APPEND LT_ZPPT0001.

    MODIFY ZPPT0001 FROM TABLE LT_ZPPT0001.

  ENDIF.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_IMGR_RCV
*&---------------------------------------------------------------------*
FORM RTN_IMGR_RCV USING PV_RST
                        PV_MSG.

* CLEAR : GT_RST.
* GT_RST-ZRESULT = PV_RST.
* GT_RST-MESSAGE = PV_MSG.
* APPEND GT_RST.

  CLEAR : GT_I17, GT_9072.

  GT_I17-ICCNO   = GT_I10-ICCNO.
  GT_I17-ZRESULT = PV_RST.
  GT_I17-MESSAGE = PV_MSG.
* MOVE-CORRESPONDING GT_RST TO GT_I17.
  IF PV_RST = 'S'.
    GT_I17-MBLNR = GS_MHDRT-MAT_DOC.
    GT_I17-MJAHR = GS_MHDRT-DOC_YEAR.
  ENDIF.

  MOVE-CORRESPONDING GT_I17 TO GT_9072.
  GT_9072-ZIFKEY = GT_9000-ZIFKEY.
* GT_9072-ZRESULT   = SWITCH #( GT_9072-ZRESULT WHEN 'S' THEN '00'
*                                               WHEN 'E' THEN '02' ).

  GT_I17-MBLNR = |{ GT_I17-MBLNR ALPHA = OUT }|.

  APPEND : GT_I17, GT_9072.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_C_TYPE
*&---------------------------------------------------------------------*
FORM RUN_C_TYPE.

  DATA : LT_ZTITGRK LIKE ZTITGRK OCCURS 0 WITH HEADER LINE.


  SELECT IGRNO MBLNR MJAHR "*
    FROM ZTITGRK
    INTO CORRESPONDING FIELDS OF TABLE LT_ZTITGRK
   WHERE ICCNO = GT_I10-ICCNO.

  IF SY-SUBRC <> 0.
    PERFORM RTN_IMGR_RCV USING 'E' '취소할 데이터가 없습니다'(M03).
*   GT_RST-ZRESULT = 'E'.
*   GT_RST-MESSAGE = '취소할 데이터가 없습니다'.
    EXIT.
  ENDIF.

  LOOP AT LT_ZTITGRK.
    PERFORM BAPI_GOODSMVT_CANCEL USING LT_ZTITGRK-MBLNR
                                       LT_ZTITGRK-MJAHR
                                       GT_I10-BUDAT.

    IF GS_MHDRT-MAT_DOC IS NOT INITIAL.
      DELETE FROM ZTITGRK WHERE ICCNO = GT_I10-ICCNO.
      DELETE FROM ZTITGRP WHERE ICCNO = GT_I10-ICCNO.
      DELETE FROM ZTITGRB WHERE ICCNO = GT_I10-ICCNO.
      DELETE FROM ZTITGRH WHERE IGRNO = LT_ZTITGRK-IGRNO.
      PERFORM BAPI_COMMIT.

      PERFORM RTN_IMGR_RCV USING 'S' '수입자재 취소 성공'(M04).
    ELSE.
      PERFORM BAPI_ROLLBACK.

      PERFORM RTN_IMGR_RCV USING 'E' '수입자재 취소 실패'(M05).
    ENDIF.
  ENDLOOP.

  "구미 물자 창고 WMS 도입(SJM 25.06.10)
  " 취소의 경우 검사 Lot정보가 필요 없으므로 취소 성공/실패 여부과 관계 없이 구성
  LOOP AT GT_I11 WHERE ICCNO = GT_I10-ICCNO.
    CLEAR : GT_I21.
    MOVE-CORRESPONDING GT_I11 TO GT_I21.
    APPEND GT_I21.
  ENDLOOP.

ENDFORM.
