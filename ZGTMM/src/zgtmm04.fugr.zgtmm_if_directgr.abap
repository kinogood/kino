FUNCTION ZGTMM_IF_DIRECTGR.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_ZRESULT) TYPE  BAPI_MTYPE
*"     VALUE(E_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DELIV STRUCTURE  ZGTMMSIF0044 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_DIRECTGR
*& 프로그램 명 : 직납 납품서 검수 결과 수신
*& 개요   : E-Pro에서 검수한 직납 납품 정보를 수신
*& 생성일 : 2025.02.06
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : LT_DELIV LIKE ZGTMMSIF0044 OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF LT_IDH OCCURS 0,
           BUKRS     LIKE ZGTMMT4010-BUKRS,
           WERKS     LIKE ZGTMMT4010-WERKS,
           VBELN     LIKE ZGTMMT4010-VBELN,
           ZCLOSE(1),
           MBLNR     LIKE MKPF-MBLNR.
           INCLUDE STRUCTURE ZGTMMS0001.
  DATA : END   OF LT_IDH.

  DATA : LT_CHK LIKE LT_IDH     OCCURS 0 WITH HEADER LINE,
         LT_H41 LIKE ZGTMMT4010 OCCURS 0 WITH HEADER LINE.


  IF IT_DELIV[] IS INITIAL.
    E_ZRESULT = GC_E.
    E_MESSAGE = '전송된 DATA가 없습니다.'(M01).
    RETURN.
  ENDIF.

  LT_DELIV[] = VALUE #( FOR LS_DELIV IN IT_DELIV
                       ( VALUE #( BASE CORRESPONDING #( LS_DELIV )
                                  VBELN = |{ LS_DELIV-VBELN ALPHA = IN }|
                                  LIFNR = |{ LS_DELIV-LIFNR ALPHA = IN }|
                                  EMLIF = |{ LS_DELIV-EMLIF ALPHA = IN }| ) ) ).

  SELECT *
    FROM ZGTMM_CV_GETINBDIRECT_H
    INTO CORRESPONDING FIELDS OF TABLE @LT_IDH
     FOR ALL ENTRIES IN @LT_DELIV
   WHERE BUKRS = @LT_DELIV-BUKRS
     AND WERKS = @LT_DELIV-WERKS
     AND VBELN = @LT_DELIV-VBELN.

  LT_CHK[] = LT_IDH[].
  DELETE LT_CHK WHERE NOT ( ZCLOSE <> SPACE OR MBLNR <> SPACE ).

  "전송된 납품서 종결 처리여부 Check
  IF LT_CHK[] IS NOT INITIAL.
    E_ZRESULT = GC_E.
    E_MESSAGE = '입고 처리된 납품서가 존재합니다.'(M02).
    RETURN.
  ENDIF.

  SELECT VBELN, STOCKVALSUM, WAERS
    FROM ZGTMM_CV_GETINB_VALUE_SUM
    INTO TABLE @DATA(LT_SVS)
     FOR ALL ENTRIES IN @LT_DELIV
   WHERE VBELN = @LT_DELIV-VBELN.

  SORT LT_SVS BY VBELN.
  SORT LT_IDH BY BUKRS WERKS VBELN.

  CLEAR : GT_RECV[].

  PERFORM SET_TIMESTAMP USING 'X' 'X'.

  LOOP AT LT_DELIV.
    MOVE-CORRESPONDING LT_DELIV TO LT_H41.

    "납품서 금액
    READ TABLE LT_SVS INTO DATA(LS_SVS)
      WITH KEY VBELN = LT_DELIV-VBELN BINARY SEARCH.

    IF SY-SUBRC = 0.
      LT_H41-STOCKVALSUM = LS_SVS-STOCKVALSUM.
      LT_H41-WAERS       = LS_SVS-WAERS.
    ENDIF.

    "기저장 여부 Check
    READ TABLE LT_IDH WITH KEY BUKRS = LT_DELIV-BUKRS
                               WERKS = LT_DELIV-WERKS
                               VBELN = LT_DELIV-VBELN
                               BINARY SEARCH.

    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING LT_IDH  TO LT_H41.
    ELSE.
      MOVE-CORRESPONDING GS_CREA TO LT_H41.
    ENDIF.

    MOVE-CORRESPONDING GS_CHNG TO LT_H41.
    APPEND LT_H41.

    GT_RECV-VBELN = LT_DELIV-VBELN.
    COLLECT GT_RECV.
  ENDLOOP.

  "데이터 저장
  MODIFY ZGTMMT4010 FROM TABLE LT_H41.

  IF SY-SUBRC = 0.
    COMMIT WORK.

    PERFORM SEND_MAIL_DGR.

    E_ZRESULT = GC_S.
    E_MESSAGE = '직납 검수 정보가 저장되었습니다.'(M03).
  ELSE.
    ROLLBACK WORK.

    E_ZRESULT = GC_E.
    E_MESSAGE = 'Data 저장시 오류가 발생했습니다.'(M04).
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SEND_MAIL_DGR
*&---------------------------------------------------------------------*
FORM SEND_MAIL_DGR.

  DATA : LV_CNT(3).


  "메일 전송 기능 추가(SJM 25.03.17)
  " 직납 납품서 결과 수신시 해당 납품서의 구매오더 생성자에게 이메일 전송(Notice)

  SORT GT_RECV BY VBELN.
  DELETE ADJACENT DUPLICATES FROM GT_RECV COMPARING VBELN.

  SELECT ERNAM, EMAIL, LIFNR, NAME1
    FROM ZGTMM_CV_POUSERBYDEV
     FOR ALL ENTRIES IN @GT_RECV
   WHERE VBELN = @GT_RECV-VBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_RECV.

  CHECK GT_RECV[] IS NOT INITIAL.

  SORT GT_RECV BY ERNAM LIFNR.
  DELETE ADJACENT DUPLICATES FROM GT_RECV COMPARING ERNAM LIFNR.

  LOOP AT GT_RECV.
    MOVE-CORRESPONDING GT_RECV TO GS_RECV.

    AT NEW ERNAM.
      CLEAR : GV_UNAME, GV_EMAIL, GV_TEXT, GT_MTXT.
      LV_CNT = -1.

      GV_UNAME = GS_RECV-ERNAM.
      GV_EMAIL = GS_RECV-EMAIL.
      GV_TEXT  = '[' && GS_RECV-NAME1 && ']'.
    ENDAT.

    LV_CNT += 1.

    GS_MTXT-LINE = '[' && GS_RECV-NAME1 && ']' && ' 직납 검수 정보가 수신되었습니다.'(M05).
    APPEND GS_MTXT TO GT_MTXT.

    AT END OF ERNAM.
      CONDENSE LV_CNT.
      IF LV_CNT > 0.
        GV_TEXT = GV_TEXT && ` ` && '외'(M06) && ` ` && LV_CNT && '건'(M07).
      ENDIF.
      GV_TEXT = GV_TEXT && ' 직납 검수 정보가 수신되었습니다.'(M05).

      GS_MTXT-LINE = 'T-Code ZGTMMR4020에서 상세 확인하세요.'(M08).
      APPEND GS_MTXT TO GT_MTXT.

      PERFORM SEND_MAIL.
    ENDAT.
  ENDLOOP.

ENDFORM.
