FUNCTION ZGTMM_IF_O_INBSTATUS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"     VALUE(I_AEDAT_F) TYPE  DATS
*"     VALUE(I_AEDAT_T) TYPE  DATS
*"     VALUE(I_ERNAM) TYPE  CHAR12 OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_PLANT STRUCTURE  SGT_S_WERKS OPTIONAL
*"      OT_ITEM STRUCTURE  ZGTMMSIF0027
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_INBSTATUS
*& 프로그램 명 : 납품서 입고 상태 조회
*& 개요   : Inbound Delivery 정보 송신용 RFC (To WMS)
*& 생성일 : 2025.06.19
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  RANGES : LR_WERKS FOR LIPS-WERKS,
           LR_AEDAT FOR EKKO-AEDAT,
           LR_ERNAM FOR EKKO-ERNAM.


  CLEAR : OT_ITEM[].

  "Import Paramter 필수값 누락시 Error
  IF I_SYSTEM_ID IS INITIAL
  OR I_AEDAT_F   IS INITIAL
  OR I_AEDAT_T   IS INITIAL.
    ZO_RESULT = GC_E.
    MESSAGE S018(ZGTMM01) INTO ZO_MESSAGE. "필수 입력 정보가 누락되었습니다.
    RETURN.
  ENDIF.

  "Import Paramter Range 변수 변환
  IF IT_PLANT[] IS NOT INITIAL.
    LR_WERKS[] = VALUE #( FOR LS_PLANT IN IT_PLANT
                          ( VALUE #( SIGN = GC_I OPTION = GC_EQ LOW = LS_PLANT-WERKS ) ) ).
  ENDIF.

  LR_AEDAT[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_BT
                          LOW    = I_AEDAT_F
                          HIGH   = I_AEDAT_T ) ).

  IF I_ERNAM IS NOT INITIAL.
    LR_ERNAM[] = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = I_ERNAM ) ).
  ENDIF.

  "Data Gathering
  SELECT * FROM ZGTMM_CV_GETINBOUND_STATUS
    INTO CORRESPONDING FIELDS OF TABLE @OT_ITEM
   WHERE WERKS IN @LR_WERKS
     AND AEDAT IN @LR_AEDAT
     AND ERNAM IN @LR_ERNAM.

  IF OT_ITEM[] IS INITIAL.
    ZO_RESULT = GC_E.
    MESSAGE S002(ZGTMM01) INTO ZO_MESSAGE. "조회된 값이 없습니다.
  ELSE.
    SORT OT_ITEM BY EBELN EBELP ETENS.

    DATA(LV_CNT) = LINES( OT_ITEM ).
    DATA(LV_TXT) = `납품서 정보 ` && LV_CNT.

    ZO_RESULT = GC_S.
    MESSAGE S003(ZGTMM01) WITH LV_TXT INTO ZO_MESSAGE. "& 건의 데이터가 조회되었습니다.
  ENDIF.

ENDFUNCTION.
