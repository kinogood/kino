FUNCTION ZGTMM_BDMES_STOCK_LIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4 DEFAULT 'KBDM'
*"     VALUE(I_WERKS) TYPE  EWERK DEFAULT '1306'
*"     VALUE(I_JOB_NO) TYPE  ZGTE_BD_JOBNO OPTIONAL
*"  EXPORTING
*"     VALUE(O_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(O_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_MAT STRUCTURE  /ACCGO/CMN_S_MATNR OPTIONAL
*"      OT_TAB STRUCTURE  ZGTMMSIF0061
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_BDMES_STOCK_LIST
*& 프로그램 명 : [BD] 재고 조회 I/F 수신
*& 개요   : 부스닥트 MES에서 임가공 하위 구성품 출고를 위해 자재 또는 제조지시번호로 부스닥트 재고 조회
*& 생성일 : 2024.12.12
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기값 Setting
  O_RESULT  = GC_S.
  O_MESSAGE = SPACE.
  CLEAR : OT_TAB[].

  "제조지시번호 취소 가능 여부 Check(PSJ 25.04.18)
  IF I_JOB_NO+0(1) = GC_C.
    PERFORM CHECK_JOB_CANC USING I_JOB_NO
                        CHANGING O_RESULT
                                 O_MESSAGE.
    RETURN.
  ENDIF.

  "입력값 점검
  IF IT_MAT[] IS INITIAL AND I_JOB_NO IS INITIAL.
    O_RESULT  = GC_E.
    O_MESSAGE = '조회할 자재코드 또는 제조번호를 입력 하세요.'(M04).
    RETURN.
  ENDIF.

  "조회조건 Setiing
  PERFORM SET_COND_STOCK TABLES IT_MAT
                          USING I_JOB_NO.

  IF I_JOB_NO IS NOT INITIAL AND GR_VBELN[] IS INITIAL. "추가(PSJ 25.05.12)
    O_RESULT  = GC_E.
    O_MESSAGE = '해당 제조번호의 재고는 존재하지 않습니다.'(M05).
    RETURN.
  ENDIF.

  SELECT S~MATNR,
         S~WERKS,
         S~LGORT,
         S~CHARG,
         S~SOBKZ,
         S~LIFNR,
         P~POSID,
         S~KUNNR,
         S~VBELN,
         S~POSNR,
*        MAKTX
         T~LGOBE,
         L~NAME1 AS LIFNR_NAME,
         K~NAME1 AS KUNNR_NAME,
         S~MEINS,
         S~LABST,
         S~INSME,
         M~ZZPJT_NO,
         M~ZZJOB_NO,
         M~ZZLINE_NO,
         M~ZZSERIAL_INFO
    FROM ZGTMM_CV_GET_STOCKLIST AS S
    LEFT JOIN PRPS  AS P ON S~PSPNR = P~PSPNR AND P~LOEVM = @SPACE
    LEFT JOIN T001L AS T ON S~WERKS = T~WERKS AND S~LGORT = T~LGORT
    LEFT JOIN LFA1  AS L ON S~LIFNR = L~LIFNR AND L~LOEVM = @SPACE
    LEFT JOIN KNA1  AS K ON S~KUNNR = K~KUNNR AND K~LOEVM = @SPACE
    LEFT JOIN MCH1  AS M ON S~MATNR = M~MATNR AND S~CHARG = M~CHARG AND M~LVORM = @SPACE "추가(PSJ 25.05.08)
   WHERE S~WERKS  = @I_WERKS
     AND S~MATNR IN @GR_MATNR
     AND S~VBELN IN @GR_VBELN
    INTO TABLE @DATA(LT_DATA).

  IF SY-SUBRC <> 0
  AND IT_MAT[] IS INITIAL AND I_JOB_NO IS NOT INITIAL.
    O_RESULT  = GC_E.
    O_MESSAGE = '해당 제조번호의 재고는 존재하지 않습니다.'(M05).
    RETURN.
  ENDIF.

  PERFORM GET_MAKT.

  LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    DELETE GR_MATNR WHERE LOW = <LS_DATA>-MATNR.

    CLEAR : OT_TAB.
    MOVE-CORRESPONDING <LS_DATA> TO OT_TAB.

    PERFORM SET_MAKT USING OT_TAB-MATNR
                  CHANGING OT_TAB-MAKTX.

    PERFORM CONVERT_MATN1_OUTPUT USING OT_TAB-MATNR.

    OT_TAB-LIFNR = |{ OT_TAB-LIFNR ALPHA = OUT }|.
    OT_TAB-KUNNR = |{ OT_TAB-KUNNR ALPHA = OUT }|.
    OT_TAB-VBELN = |{ OT_TAB-VBELN ALPHA = OUT }|.
    SHIFT OT_TAB-POSNR LEFT DELETING LEADING '0'.

    APPEND OT_TAB.
  ENDLOOP.

  "재고값이 없는 자재코드 구성
  IF GR_MATNR[] IS NOT INITIAL.
    LOOP AT GR_MATNR.
      PERFORM CONVERT_MATN1_OUTPUT USING GR_MATNR-LOW.

      CLEAR : OT_TAB.
      OT_TAB-MATNR = GR_MATNR-LOW.
      OT_TAB-WERKS = I_WERKS.
      APPEND OT_TAB.
    ENDLOOP.
  ENDIF.

  CHECK OT_TAB[] IS NOT INITIAL.
  O_RESULT  = GC_S.
  O_MESSAGE = '조회 되었습니다.'(M00).

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_COND_STOCK
*&---------------------------------------------------------------------*
FORM SET_COND_STOCK TABLES PT_MAT STRUCTURE /ACCGO/CMN_S_MATNR "MDG_BS_MAT_KEY_MATNR
                     USING PV_JOB_NO.

  CLEAR : GR_MATNR[], GR_VBELN[], GT_MAKT[].

  DATA(LT_MAT) = PT_MAT[].
  DELETE LT_MAT WHERE MATNR IS INITIAL.

  IF LT_MAT[] IS NOT INITIAL.
    SORT LT_MAT BY MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_MAT COMPARING MATNR.

    LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<LS_MAT>).
      PERFORM CONVERT_MATN1_INPUT USING <LS_MAT>-MATNR.

      GR_MATNR[] = VALUE #( BASE GR_MATNR[]
                     ( VALUE #( SIGN   = GC_I
                                OPTION = GC_EQ
                                LOW    = <LS_MAT>-MATNR ) ) ).

      CLEAR : GT_MAKT.
      GT_MAKT-MATNR = <LS_MAT>-MATNR.
      COLLECT GT_MAKT.
    ENDLOOP.

    SORT GR_MATNR BY LOW.
  ENDIF.

  IF PV_JOB_NO IS NOT INITIAL. "[TBD] 확인!
    SELECT DISTINCT VBELN AS LOW
      FROM VBAK
      INTO CORRESPONDING FIELDS OF TABLE @GR_VBELN
     WHERE BSTNK = @PV_JOB_NO.

    IF GR_VBELN[] IS NOT INITIAL.
      GR_VBELN-SIGN   = GC_I.
      GR_VBELN-OPTION = GC_EQ.
      MODIFY GR_VBELN TRANSPORTING SIGN OPTION
                             WHERE SIGN IS INITIAL.

      SELECT DISTINCT MATNR FROM VBAP
   APPENDING CORRESPONDING FIELDS OF TABLE GT_MAKT
       WHERE VBELN IN GR_VBELN.
    ENDIF.
  ENDIF.

  SORT GT_MAKT BY MATNR.
  DELETE ADJACENT DUPLICATES FROM GT_MAKT COMPARING MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JOB_CANC
*&---------------------------------------------------------------------*
FORM CHECK_JOB_CANC USING PV_JOB_NO
                 CHANGING PV_RESULT
                          PV_MESSAGE.

  GV_JOBNO = PV_JOB_NO+1(9).

  SELECT SINGLE JOB_NO
    FROM ZGTMM_CV_BD_JOBLS_PRPO
    INTO @DATA(LV_JOBNO)
   WHERE JOB_NO = @GV_JOBNO.

  IF LV_JOBNO IS NOT INITIAL.
    PV_RESULT  = GC_E.
    PV_MESSAGE = '구매문서 있음. 확정 취소 불가.'(M49).
  ELSE.
    PV_RESULT  = GC_S.
    PV_MESSAGE = '확정 취소 가능.'(M50).
  ENDIF.

ENDFORM.
