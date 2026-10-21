FUNCTION ZGTMM_EXPAND_MRPVIEW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATNR) TYPE  MATNR
*"     REFERENCE(I_WERKS) TYPE  WERKS_D
*"     REFERENCE(I_BESKZ) TYPE  BESKZ OPTIONAL
*"     REFERENCE(I_SOBSL) TYPE  SOBSL OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_TYPE) TYPE  BAPI_MTYPE
*"     REFERENCE(E_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_EXPAND_MRPVIEW
*& 프로그램 명 :  자재 마스터 MRP view 확장 function
*& 개요   : 자재 마스터 생성 시 MRP VIEW를 확장하는 FUCNTION 개발
*& 생성일 : 2026.04.02
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  CLEAR:
    E_TYPE,
    E_MESSAGE.

  DATA:
    LS_HEAD   TYPE BAPIMATHEAD,
    LS_PLANT  TYPE BAPI_MARC,
    LS_PLANTX TYPE BAPI_MARCX,
    LS_RETURN TYPE BAPIRET2.

*1) 전송 정보 누락 여부 확인
*	1-1) I_MATNR = '' OR I_WERKS = ''인 경우 다음 정보 Return 후 종료
*   Export Parameter                      Value
*   TYPE                      "E"
*   MESSAGE                     "필수 값이 누락되었습니다."

  IF I_MATNR IS INITIAL
    OR I_WERKS IS INITIAL.
    E_TYPE = GC_E.
    E_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

  "2026.07.10 ALPHA CONVERSION 위치 수정
  CALL FUNCTION 'CONVERSION_EXIT_MATN5_INPUT'
    EXPORTING
      INPUT  = I_MATNR
    IMPORTING
      OUTPUT = LS_HEAD-MATERIAL.


*  2) DEFAULT 구매 그룹 선정을 위한 공통 마스터 조회
*	2-0) 자재마스터 기본 정보 조회
  SELECT SINGLE
    MTART, MATKL, SPART   "2026.07.14 제품군 추가
    FROM MARA
    WHERE MATNR EQ @LS_HEAD-MATERIAL
    INTO @DATA(LS_MARA).

*    	2-0-1) IF SY-SUBRC NE 0.
* Export Parameter                      Value
* TYPE                      "E"
* MESSAGE                     "자재마스터가 존재하지 않습니다.."
*	 EXIT
*	ELSE.
  IF SY-SUBRC NE 0.
    E_TYPE = GC_E.
    E_MESSAGE = TEXT-E06.
    EXIT.
  ENDIF.

*2-1) 외부조달저장위치 할당
*	코드마스터에 등록된 외부 조달 기본 저장위치 SELECT (LT_GROUP1)

*2-2) 해당 플랜트의 회사코드 조회 (LV_BUKRS)
  SELECT SINGLE
    TK~BUKRS
    FROM T001W AS TW
              INNER JOIN
            T001K AS TK ON TW~BWKEY EQ TK~BWKEY
     WHERE TW~WERKS EQ @I_WERKS
    INTO @DATA(LV_BUKRS).

*2-4) 회사코드 별 로직 구성(향후 자회사 등 추가 확장 로직을 고려)
*	2-4-1) IF LV_BUKRS = '6000' 인 경우
  IF LV_BUKRS NE '6000'.
    E_TYPE = GC_E.
    E_MESSAGE = TEXT-E07.
    EXIT.
  ENDIF.


* HEADER
  LS_HEAD-IND_SECTOR = 'M'.
  LS_HEAD-MATL_TYPE = LS_MARA-MTART.
  LS_HEAD-MRP_VIEW = 'X'.

  "PLANT
  PERFORM F_SET_PLANT_DATA_MRPVIEW USING I_WERKS
                                                                            LS_HEAD-MATERIAL
                                                                            LS_MARA-MTART
                                                                            LS_MARA-MATKL
                                                                            LS_MARA-SPART
                                                                            I_BESKZ
                                                                            I_SOBSL "I_MATNR -> LS_HEAD-MATERIAL
                                                                 CHANGING LS_PLANT LS_PLANTX.

*CALL FUNCTION                  BAPI_MATERIAL_SAVEDATA
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      HEADDATA   = LS_HEAD
      PLANTDATA  = LS_PLANT
      PLANTDATAX = LS_PLANTX
    IMPORTING
      RETURN     = LS_RETURN.

*메시지 리턴 및 COMMIT 후 종료

  IF LS_RETURN-TYPE EQ GC_E.
    E_TYPE = GC_E.
    E_MESSAGE = LS_RETURN-MESSAGE.
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    E_TYPE = GC_S.
    E_MESSAGE = TEXT-M03. "자재마스터를 확장했습니다.
  ENDIF.

ENDFUNCTION.
