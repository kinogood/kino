FUNCTION ZGTMM_IF_O_DDEV_STAT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_RDATE_F) TYPE  DATS OPTIONAL
*"     VALUE(I_RDATE_T) TYPE  DATS OPTIONAL
*"     VALUE(I_LIFNR) TYPE  LIFNR
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(I_CNAME) TYPE  CHAR35 OPTIONAL
*"     VALUE(I_MATNR) TYPE  MATNR OPTIONAL
*"     VALUE(I_MAKTX) TYPE  MAKTX OPTIONAL
*"     VALUE(I_ZVD_STAT) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DEST1) TYPE  CHAR60 OPTIONAL
*"     VALUE(I_AR_DATE_F) TYPE  DATS OPTIONAL
*"     VALUE(I_AR_DATE_T) TYPE  DATS OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_EBELN STRUCTURE  ZGTMMS4513 OPTIONAL
*"      IT_VBELN STRUCTURE  ZGTMMS4514 OPTIONAL
*"      IT_DOC STRUCTURE  ZGTMMS4515 OPTIONAL
*"      OT_DATA STRUCTURE  ZGTMMS4510
*"      OT_TRUCK STRUCTURE  ZGTMMS4512
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_DDEV_STAT
*& 프로그램 명 :  직송 의뢰 진행 상태 조회(SAP -> G-SRM)
*& 개요   : 직송 의뢰 대상의 전체 상태를 조회 할 수 있는 RFC
*& 생성일 : 2026.01.14
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  DATA : LT_TRUCK TYPE TABLE OF ZGTMMS4512,
             LS_TR TYPE ZGTMMS4512,
             LS_DT TYPE ZGTMMS4510,
             LV_COND TYPE STRING,
             LV_CNAME TYPE CHAR35,
             LV_MATNR TYPE CHAR40,
             LV_MAKTX TYPE CHAR40,
             LV_DEST TYPE CHAR60.           .

*--필수 입력 값 체크
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR I_LIFNR IS INITIAL.

     ZO_RESULT    = '02'.
     ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
     RETURN.
  ENDIF.

*--DATA 조회
  I_LIFNR = |{ I_LIFNR   ALPHA = IN }|.
  LV_COND = | BUKRS = '{ I_BUKRS }' AND LIFNR = '{ I_LIFNR }'  AND ZMM_STAT = @GC_A |.
*  PERFORM SET_RANGE TABLES IT_EBELN IT_VBELN IT_DOC.
*  LV_COND &&= ' AND EBELN IN @GR_EBELN AND AND VBELN IN @GR_VBELN'.
*  LV_COND &&= ' AND ZDOC_NO IN @GR_DOC'.

  PERFORM SET_COND USING I_RDATE_F I_WERKS I_ZVD_STAT I_AR_DATE_F I_AR_DATE_T CHANGING LV_COND.

  LV_CNAME = COND #( WHEN I_CNAME IS INITIAL THEN '%' ELSE |{ '%' }{ I_CNAME }{ '%' }| ).
  LV_MATNR = COND #( WHEN I_MATNR IS INITIAL THEN '%' ELSE |{ '%' }{ I_MATNR }{ '%' }| ).
  LV_MAKTX = COND #( WHEN I_MAKTX IS INITIAL THEN '%' ELSE |{ '%' }{ I_MAKTX }{ '%' }| ).
  LV_DEST = COND #( WHEN I_DEST1 IS INITIAL THEN '%' ELSE |{ '%' }{ I_DEST1 }{ '%' }| ).
  LV_COND &&= ' AND CNAME LIKE @LV_CNAME AND MATNR LIKE @LV_MATNR AND MAKTX LIKE @LV_MAKTX AND DEST1 LIKE @LV_DEST'.

  SELECT FROM ZGTMM_CV_GET_DDINFO
    FIELDS *
    WHERE (LV_COND)
    INTO TABLE @DATA(LT_DATA).

*--RESULT
  IF LT_DATA IS INITIAL.
     ZO_RESULT    = '00'.
     ZO_MESSAGE = '조회된 정보가 없습니다.'(M08).

  ELSE.
*     OT_DATA[] = CORRESPONDING #( LT_DATA[] ).
    LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<FSD>).
         LS_DT = CORRESPONDING #( <FSD> ).
         LS_DT-MATNR = |{ LS_DT-MATNR ALPHA = OUT }|.
         LS_DT-LIFNR   = |{ LS_DT-LIFNR   ALPHA = OUT }|.
         LS_DT-KUNNR = |{ LS_DT-KUNNR ALPHA = OUT }|.

         _SET_SPACE LS_DT-REQDATE.
         _SET_SPACE LS_DT-AR_DATE.
         _SET_SPACE LS_DT-AR_TIME.
         _SET_SPACE LS_DT-PROD_DATE.
         _SET_SPACE LS_DT-ZINSPDATE.
         _SET_SPACE LS_DT-ZMM_DATE.
         _SET_SPACE LS_DT-ZVD_DATE.
         _SET_SPACE LS_DT-ZVD_TIME.

         LS_DT-VNAME  = ''.
         APPEND LS_DT TO OT_DATA.
    ENDLOOP.

*배차정보 가져오기
     CLEAR LT_TRUCK.
     SELECT FROM ZGTMM_CV_GET_TRANSDATA "ZGTMMT4403
       FIELDS *
       FOR ALL ENTRIES IN @LT_DATA
       WHERE BUKRS         EQ @LT_DATA-BUKRS
            AND ZREQ_TYPE EQ @LT_DATA-ZREQ_TYPE
            AND DLVRQ         EQ @LT_DATA-DLVRQ
            AND VBELN         EQ @LT_DATA-VBELN
            AND POSNR        EQ @LT_DATA-POSNR
            AND EBELN         EQ @LT_DATA-EBELN
            AND EBELP         EQ @LT_DATA-EBELP
            INTO CORRESPONDING FIELDS OF TABLE @LT_TRUCK.

      IF LT_TRUCK[] IS NOT INITIAL.
         LOOP AT LT_TRUCK ASSIGNING FIELD-SYMBOL(<FST>).
           LS_TR = CORRESPONDING #( <FST> ).

           _SET_SPACE LS_TR-ZDOC_DATE.
           _SET_SPACE LS_TR-BUDAT.
           _SET_SPACE LS_TR-GIDATE.

           APPEND LS_TR TO OT_TRUCK.
         ENDLOOP.
*          OT_TRUCK[] =  LT_TRUCK[].
      ENDIF.

     ZO_RESULT     = '00'.
     ZO_MESSAGE  = 'SO/PO 정보가 조회 되었습니다.'(M09).
  ENDIF.

ENDFUNCTION.
