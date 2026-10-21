FUNCTION ZGTSD_SHIP_REQ_DUE_LIST_AMT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PARTNER) TYPE  BU_PARTNER OPTIONAL
*"     VALUE(I_SEGMENT) TYPE  KKBER OPTIONAL
*"     VALUE(I_FROMDATE) TYPE  SY-DATUM OPTIONAL
*"  EXPORTING
*"     VALUE(E_AMOUNT) TYPE  UKM_COMM_ACTUAL_ITEM
*"     VALUE(E_WAERS) TYPE  WAERS
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSD_SHIP_REQ_DUE_LIST_AMT
*&  프로그램 명  : 미 출하확정량 여신금액 산출
*&  개요       : 가온전선_출하요청 후 출하확정하지 않은 물량에 대해 지급처/여신세그먼트별로 금액을 산출
*&  생성일      : 2025.11.26
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA: LV_AMT       TYPE WRBTR.
  CONSTANTS: LC_WAERS_KRW TYPE WAERS VALUE 'KRW'.


*-01. 입력 체크
  IF I_PARTNER IS INITIAL.
    E_TYPE = 'E'.
    MESSAGE S000(ZGTSD01) WITH TEXT-M61 INTO E_MSG.
    EXIT.
  ELSE.
    SELECT SINGLE PARTNER
      FROM BUT000
     WHERE PARTNER EQ @I_PARTNER
      INTO @DATA(LV_PARTNER).
    IF SY-SUBRC NE 0.
      E_TYPE = 'E'.
      MESSAGE S000(ZGTSD01) WITH TEXT-M64 INTO E_MSG.
      EXIT.
    ENDIF.
  ENDIF.

  IF I_SEGMENT IS INITIAL.
    E_TYPE = 'E'.
    MESSAGE S000(ZGTSD01) WITH TEXT-M62 INTO E_MSG.
    EXIT.
  ELSE.
    SELECT SINGLE KKBER
      FROM UKM_KKBER2SGM
     WHERE KKBER EQ @I_SEGMENT
      INTO @DATA(LV_KKBER).
    IF SY-SUBRC NE 0.
      E_TYPE = 'E'.
      MESSAGE S000(ZGTSD01) WITH TEXT-M63 INTO E_MSG.
      EXIT.
    ENDIF.
  ENDIF.

*-02.DATE
  IF I_FROMDATE IS INITIAL.
    I_FROMDATE = SY-DATLO - 30.
  ENDIF.

*-03. 미 출하확정 데이터
  SELECT A~VBELN,A~POSNR,A~DLVRQ,A~DLRMG,A~REVMG,A~VRKME,
         B~CMPRE,
         D~WAERK,
         ( A~DLRMG - A~REVMG ) AS REQTY

    FROM ZLET0401 AS A INNER JOIN VBAP AS B
                       ON A~VBELN = B~VBELN AND
                          A~POSNR = B~POSNR
                       INNER JOIN VBPA AS C
                       ON B~VBELN = C~VBELN  AND
                          C~POSNR = '000000' AND
                          C~PARVW = 'RG'
                       INNER JOIN VBAK AS D
                       ON B~VBELN = D~VBELN
   WHERE A~LECFM       NE 'CM'
     AND A~LECFM       NE 'CS'
     AND A~AEDAT       GE @I_FROMDATE
     AND A~LVORM       EQ @SPACE
     AND C~ASSIGNED_BP EQ @I_PARTNER
     AND D~KKBER       EQ @I_SEGMENT
    INTO TABLE @DATA(LT_LIST).


  LOOP AT LT_LIST INTO DATA(LS_LIST).
    CLEAR LV_AMT.
    "여신금액
    LV_AMT = LS_LIST-REQTY * LS_LIST-CMPRE.

    "KRW 환산
    IF LS_LIST-WAERK NE LC_WAERS_KRW.
      LV_AMT = ZGTSD_CL_COMMON2=>CONV_TO_LOCAL_CURRENCY( IV_DATE   = SY-DATUM
                                                         IV_FR_AMT = LV_AMT
                                                         IV_FR_CUR = LS_LIST-WAERK
                                                         IV_TO_CUR = LC_WAERS_KRW  ).

    ENDIF.

    "여신금액 SUM
    E_AMOUNT = E_AMOUNT + LV_AMT.
  ENDLOOP.


  E_WAERS = LC_WAERS_KRW.
  E_TYPE  = 'S'.
  E_MSG   = TEXT-S01.

ENDFUNCTION.
