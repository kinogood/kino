FUNCTION ZGTSD_PICKING_STATUS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0050 OPTIONAL
*"      ET_DATA STRUCTURE  ZGTSDS0051 OPTIONAL
*"----------------------------------------------------------------------
  TYPES: BEGIN OF TY_KEY,
           VBELN TYPE LIPS-VBELN,
           POSNR TYPE LIPS-POSNR,
         END OF TY_KEY.

  TYPES: BEGIN OF TY_LIPS,
           VBELN TYPE LIPS-VBELN,
           POSNR TYPE LIPS-POSNR,
           UECHA TYPE LIPS-UECHA,
           MATNR TYPE LIPS-MATNR,
           LFIMG TYPE LIPS-LFIMG,
           VGBEL TYPE LIPS-VGBEL,
           VGPOS TYPE LIPS-VGPOS,
         END OF TY_LIPS.

  TYPES: BEGIN OF TY_SEQ,
           VBELN TYPE LIPS-VBELN,
           POSNR TYPE LIPS-POSNR,
           SEQ   TYPE I,
         END OF TY_SEQ.

  TYPES: BEGIN OF TY_CNT,
           VBELN TYPE LIPS-VBELN,
           POSNR TYPE LIPS-POSNR,
           CNT   TYPE I,
         END OF TY_CNT.

  TYPES: BEGIN OF TY_MARA,
           MATNR TYPE MARA-MATNR,
           DPCBT TYPE MARA-DPCBT,
         END OF TY_MARA.

  DATA: LT_KEY  TYPE STANDARD TABLE OF TY_KEY,    " 키값용
        LS_KEY  TYPE TY_KEY,
        LT_LIPS TYPE STANDARD TABLE OF TY_LIPS,
        LS_LIPS TYPE TY_LIPS,
        LT_SEQ  TYPE STANDARD TABLE OF TY_SEQ,
        LS_SEQ  TYPE TY_SEQ,
        LT_CNT  TYPE STANDARD TABLE OF TY_CNT,
        LS_CNT  TYPE TY_CNT,
        LT_MARA TYPE STANDARD TABLE OF TY_MARA,
        LS_MARA TYPE TY_MARA,
        LT_PICK TYPE STANDARD TABLE OF TY_LIPS,   " Batch split 라인용
        LS_PICK TYPE TY_LIPS.

  DATA: LT_CHAR TYPE STANDARD TABLE OF CONF_OUT,
        LS_CHAR TYPE CONF_OUT.

  DATA: LV_MSG  TYPE STRING,
        LV_ITEM TYPE STRING,
        LV_POS  TYPE C LENGTH 6,
        LV_LEN  TYPE P LENGTH 15 DECIMALS 5,
        LV_QTY  TYPE P LENGTH 15 DECIMALS 5,
        LV_CNT  TYPE I,
        LV_SEQ  TYPE I,
        LV_OK   TYPE C LENGTH 1.

  CONSTANTS: LC_ATNAM TYPE C LENGTH 30 VALUE 'SAP_LENGTH_VKRME'.

  CLEAR: E_TYPE, E_MSG, LV_MSG.
  CLEAR ET_DATA. REFRESH ET_DATA.

* INPUT 데이터 CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = '입력값이 없습니다'.
    RETURN.
  ENDIF.

  DO 1 TIMES.
*   VBELN_VL / POSNR_VL / SEQNO 전부 필수
*   SEQNO(CHAR3)이라 아래에서 정수 I TYPE 으로 대입되므로 숫자 여부를 미리 점검함
*   (숫자가 아니고 문자가 섞여 있으면 CONVT_NO_NUMBER 덤프 발생)

* 정수에 SEQNO를 대입하는 이유는 SEQNO는 CHAR3 TYPE이라
* SEQNO를 DESCENDING시에 문자로 정렬되므로 최대값을 뽑지 못하므로 가장큰 SEQNO를 뽑기위해...
    LOOP AT IT_DATA.
      IF IT_DATA-VBELN_VL IS INITIAL OR
         IT_DATA-POSNR_VL IS INITIAL OR
         IT_DATA-SEQNO    IS INITIAL OR
         IT_DATA-SEQNO CN ' 0123456789'. " 순번에 숫자만 있는지 체크...
        LV_MSG = '필수값 누락 또는 SEQNO 순번 오류'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_MSG IS NOT INITIAL.
      EXIT.
    ENDIF.

    LOOP AT IT_DATA.

      LS_KEY-VBELN = IT_DATA-VBELN_VL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = LS_KEY-VBELN
        IMPORTING
          OUTPUT = LS_KEY-VBELN.

      LS_KEY-POSNR = IT_DATA-POSNR_VL.
      APPEND LS_KEY TO LT_KEY.

      LS_SEQ-VBELN = LS_KEY-VBELN.
      LS_SEQ-POSNR = LS_KEY-POSNR.
      LS_SEQ-SEQ   = IT_DATA-SEQNO.
      APPEND LS_SEQ TO LT_SEQ.

    ENDLOOP.

*   같은 납품, 항번, SEQNO 중복 제거
    SORT LT_KEY BY VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING VBELN POSNR.

*   납품, 항번별 SEQNO 내림차순 정렬 후 최대값만 남김.
    SORT LT_SEQ BY VBELN ASCENDING POSNR ASCENDING SEQ DESCENDING.
    DELETE ADJACENT DUPLICATES FROM LT_SEQ COMPARING VBELN POSNR.

*   SD 문서: 납품: 품목 데이터 조회
    SELECT VBELN POSNR UECHA MATNR LFIMG VGBEL VGPOS
      FROM LIPS
      INTO TABLE LT_LIPS
       FOR ALL ENTRIES IN LT_KEY
    WHERE VBELN = LT_KEY-VBELN
    AND ( POSNR = LT_KEY-POSNR OR UECHA = LT_KEY-POSNR ).

*   입력 키에 해당하는 헤더 품목과 split 라인 분리
    LOOP AT LT_LIPS INTO LS_LIPS WHERE UECHA IS NOT INITIAL.
      APPEND LS_LIPS TO LT_PICK.
    ENDLOOP.

*   품목 데이터에는 입력 품목 헤더 품목만 남김.
    DELETE LT_LIPS WHERE UECHA IS NOT INITIAL.
    SORT LT_LIPS BY VBELN POSNR.

*   CASE 1) 해당 납품문서/품목이 존재하지 않은 라인이 있으면 해당라인에 대해 납품문서/품목에
*   오류메시지를 ['VBELN_VL'-'POSNR_VL' 미 존재.] 형식으로 뿌려준다
    LOOP AT LT_KEY INTO LS_KEY.

      READ TABLE LT_LIPS TRANSPORTING NO FIELDS WITH KEY VBELN = LS_KEY-VBELN
                                                         POSNR = LS_KEY-POSNR
                                                         BINARY SEARCH.
      IF SY-SUBRC <> 0.
        LV_POS = LS_KEY-POSNR.
        SHIFT LV_POS LEFT DELETING LEADING '0'.
        CONCATENATE LS_KEY-VBELN '-' LV_POS ' 미 존재' INTO LV_ITEM.
        IF LV_MSG IS INITIAL.
          LV_MSG = LV_ITEM.
        ELSE.
          CONCATENATE LV_MSG '/' LV_ITEM INTO LV_MSG.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF LV_MSG IS NOT INITIAL.
      EXIT.
    ENDIF.

*  CASE 2) SEQNO 점검
*	         납품문서/항번별 조장수와 SEQNO 라인 숫자를 점검한 후 일치하지 않으면 오류메시지를
*          ['VBELN_VL'-'POSNR_VL' SEQNO 라인 불 일치] 형식으로 뿌려준다

*  조장수 = 납품수량 / 조장
    LOOP AT LT_KEY INTO LS_KEY.

      READ TABLE LT_LIPS INTO LS_LIPS WITH KEY VBELN = LS_KEY-VBELN
                                               POSNR = LS_KEY-POSNR
                                               BINARY SEARCH.

      READ TABLE LT_SEQ INTO LS_SEQ   WITH KEY VBELN = LS_KEY-VBELN
                                               POSNR = LS_KEY-POSNR
                                               BINARY SEARCH.

* 조장 : FM 'Z_LE_GET_CHARACTERISTIC_TABLE2' 사용하여 특성
*       'SAP_LENGTH_VKRME'의 ATWRT 사용하여 추출한다. SO 번호 및 항번은 ZZLIPS ? 이건 뭔지...
      CLEAR: LT_CHAR, LV_LEN, LV_QTY, LV_CNT, LV_OK.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
        EXPORTING
          I_VBELN = LS_LIPS-VGBEL " S/O 번호
          I_POSNR = LS_LIPS-VGPOS " S/O 항번
        TABLES
          ET_CHAR = LT_CHAR.      " 구성 출력

*    특징 이름
      READ TABLE LT_CHAR INTO LS_CHAR WITH KEY ATNAM = LC_ATNAM. " SAP_LENGTH_VKRME
      IF SY-SUBRC = 0.
        TRY.
            LV_LEN = LS_CHAR-ATWRT. " 특성 값
          CATCH CX_SY_CONVERSION_ERROR.
            CLEAR LV_LEN.
        ENDTRY.
      ENDIF.

* 조장수 = 실제 납품 수량(판매 단위) / 조장
      IF LV_LEN > 0.
        LV_QTY = LS_LIPS-LFIMG / LV_LEN.
        IF FRAC( LV_QTY ) = 0.
          LV_CNT = LV_QTY.
          IF LV_CNT = LS_SEQ-SEQ.
            LV_OK = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF LV_OK IS INITIAL.
        LV_POS = LS_KEY-POSNR.
        SHIFT LV_POS LEFT DELETING LEADING '0'.
        CONCATENATE LS_KEY-VBELN '-' LV_POS ' SEQNO 라인 불일치' INTO LV_ITEM.
        IF LV_MSG IS INITIAL.
          LV_MSG = LV_ITEM.
        ELSE.
          CONCATENATE LV_MSG '/' LV_ITEM INTO LV_MSG.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF LV_MSG IS NOT INITIAL.
      EXIT.
    ENDIF.

*   CASE 3) Single Unit Batch 사용여부 점검
*           납품문서/항번별 자재코드를 읽어 Single Unit Batch 사용여부를 점검하여
*           Single Unit Batch 사용하지 않는 자재인 경우 오류메시지를
*           ['VBELN_VL'-'POSNR_VL' PDA 미대상 자재] 형식으로 뿌려준다

*  Single Unit Batch 사용 여부 MARA-DPCBT = 'C'
    SELECT MATNR DPCBT
      FROM MARA
      INTO TABLE LT_MARA
       FOR ALL ENTRIES IN LT_LIPS
     WHERE MATNR = LT_LIPS-MATNR.
    SORT LT_MARA BY MATNR.

    LOOP AT LT_KEY INTO LS_KEY.

      READ TABLE LT_LIPS INTO LS_LIPS WITH KEY VBELN = LS_KEY-VBELN
                                               POSNR = LS_KEY-POSNR  BINARY SEARCH.

      " Single Unit Batch 아니면 오류 리턴
      READ TABLE LT_MARA INTO LS_MARA WITH KEY MATNR = LS_LIPS-MATNR BINARY SEARCH.
      IF SY-SUBRC <> 0 OR LS_MARA-DPCBT <> 'C'. "단일단위 Batch에서 처리

        LV_POS = LS_KEY-POSNR.
        SHIFT LV_POS LEFT DELETING LEADING '0'.
        CONCATENATE LS_KEY-VBELN '-' LV_POS ' PDA 미대상 자재' INTO LV_ITEM.

        IF LV_MSG IS INITIAL.
          LV_MSG = LV_ITEM.
        ELSE.
          CONCATENATE LV_MSG '/' LV_ITEM INTO LV_MSG.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDDO.

* 오류 : 키 값은 그데로  STATUS_VL 은 전부 공백으로 리턴
  IF LV_MSG IS NOT INITIAL.
    E_TYPE = GC_E.
    E_MSG  = LV_MSG.

    LOOP AT IT_DATA.
      CLEAR ET_DATA.
      MOVE-CORRESPONDING IT_DATA TO ET_DATA.
      CLEAR ET_DATA-STATUS_VL.
      APPEND ET_DATA.
    ENDLOOP.

    RETURN.
  ENDIF.

* 정상건 : 납품 & 항번별 Batch Split 라인수 COUNT 하기
  LOOP AT LT_PICK INTO LS_PICK.   " UECHA가 있는 batch split 라인들
    CLEAR LS_CNT.
    LS_CNT-VBELN = LS_PICK-VBELN.
    LS_CNT-POSNR = LS_PICK-UECHA. " KEY는 원 품목번호(스펙의 UECHA = 항번)
    LS_CNT-CNT   = 1.
    COLLECT LS_CNT INTO LT_CNT.   " 키가 같으면 CNT를 합산한다
  ENDLOOP.

  SORT LT_CNT BY VBELN POSNR.

* SEQNO : 피킹 라인수이면 STATUS = Y로
  LOOP AT IT_DATA.

    CLEAR ET_DATA.
    MOVE-CORRESPONDING IT_DATA TO ET_DATA.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IT_DATA-VBELN_VL
      IMPORTING
        OUTPUT = LS_KEY-VBELN.

    LS_KEY-POSNR = IT_DATA-POSNR_VL.
    LV_SEQ       = IT_DATA-SEQNO.

    READ TABLE LT_CNT INTO LS_CNT WITH KEY VBELN = LS_KEY-VBELN
                                           POSNR = LS_KEY-POSNR BINARY SEARCH.

* SY-SUBRC EQ 0이면 LT_CNT에서 키값이 있다는거고 피킹된 라인이 1개 이상 있다는것
* SY-SUBRC NE 0이면 피킹이 안된거라 판단하여 Y를 넣지 않고 공백처리
* LV_SEQ <= LS_CNT-CNT = SEQNO가 피킹 라인수 이내인지 보는 조건
* 예) 피킹이 6라인이면 SEQNO 1~6만 Y이고, 7은 공백으로 처리한다
    IF SY-SUBRC = 0 AND LV_SEQ <= LS_CNT-CNT.
      ET_DATA-STATUS_VL = GC_Y.
    ENDIF.

    APPEND ET_DATA.

  ENDLOOP.

  E_TYPE = GC_S.
  E_MSG  = '성공'.

ENDFUNCTION.
