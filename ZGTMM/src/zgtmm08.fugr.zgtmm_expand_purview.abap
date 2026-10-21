FUNCTION ZGTMM_EXPAND_PURVIEW.
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
*& 프로그램 ID : ZGTMM_EXPAND_PURVIEW
*& 프로그램 명 :  자재 마스터 구매 view 확장 function
*& 개요   : 자재 마스터 생성 시 구매 VIEW를 확장하는 FUCNTION 개발
*& 생성일 : 2026.03.27
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

"ALPHA CONVERSION
  CALL FUNCTION 'CONVERSION_EXIT_MATN5_INPUT'
    EXPORTING
      INPUT  = I_MATNR
    IMPORTING
      OUTPUT = LS_HEAD-MATERIAL.

*  2) DEFAULT 구매 그룹 선정을 위한 공통 마스터 조회
*	2-0) 자재마스터 기본 정보 조회
*     SELECT SINGLE * INTO LS_MARA FROM MARA WHERE MATNR = I_MATNR
  SELECT SINGLE
    MTART, MATKL
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
*
*2-1) 자재그룹 기준 정보 조회
*	--> 코드마스터에 등록된 자재그룹 별 구매그룹 값 SELECT (LT_GROUP1)
*	"SELECT FLD_01,FLD_02,FLD_03
*FROM ZGTPPT1010
*INTO LT_GROUP1
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0040'"
*
*2-2) 조달 유형 기준 정보 조회
*	--> 코드마스터에 등록된 조달 유형 별 구매그룹 값 SELECT (LT_GROUP2)
*	"SELECT FLD_01,FLD_02,FLD_03,FLD_04
*FROM ZGTPPT1010
*INTO LT_GROUP2
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0041'"

  SELECT CODEGRP, FLD_01, FLD_02, FLD_03, FLD_04
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP IN ( '0040', '0041' )
    ORDER BY CODEGRP, FLD_01, FLD_02, FLD_03, FLD_04
    INTO TABLE @DATA(LT_CODE).
*
*2-3) 해당 플랜트의 회사코드 조회 (LV_BUKRS)
*	"SELECT B~BUKRS
*FROM T001W AS A
*INNER JOIN T001K AS B
*ON A.BWKEY = B.BWKEY
*INTO LV_BUKRS
*WHERE A.WERKS = I_WERKS"
*
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

*  DATA: -> 위치 상단으로 이동
*    LS_HEAD   TYPE BAPIMATHEAD,
*    LS_PLANT  TYPE BAPI_MARC,
*    LS_PLANTX TYPE BAPI_MARCX,
*    LS_RETURN TYPE BAPIRET2.

*HEADDATA MATERIAL  "자재코드 ALPHA IN
*
*CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*    EXPORTING
*      INPUT  = I_MATNR
*    IMPORTING
*     OUTPUT = HEADERDATA-MATERIAL.
*"
* IND_SECTOR  "M"
*	MATL_TYPE	LS_MARA-MTART
*	PURCHASE_VIEW	"X"

*  LS_HEAD-MATERIAL = CONV MATNR18( I_MATNR ).
*  LS_HEAD-MATERIAL = |{ LS_HEAD-MATERIAL ALPHA = IN }|.

*  CALL FUNCTION 'CONVERSION_EXIT_MATN5_INPUT'
*    EXPORTING
*      INPUT  = I_MATNR
*    IMPORTING
*      OUTPUT = LS_HEAD-MATERIAL.
*
*  LS_HEAD-IND_SECTOR = 'M'.
*  LS_HEAD-MATL_TYPE = LS_MARA-MTART.
*  LS_HEAD-PURCHASE_VIEW = 'X'.
**
*PLANTDATA  PLANT I_WERKS
*	PUR_GROUP	"1) 자재그룹 기준 정보로 구매조직 할당
*2) 결과값 없는 경우 조달 유형 기준으로 할당
*
*1) READ TABLE  LT_GROUP1  WITH KEY FLD_01 = LS_MARA-MTART
*                                                  FLD_02 = LS_MARA-MATKL.
*    IF SY-SUBRC EQ 0.
*        LT_GROUP1-FLD_03 = PUR_GROUP
*    ELSE
*       2) READ TABLE  LT_GROUP2 WITH KEY FLD_01 = LS_MARA-MTART
*                                                  FLD_02 = I_BESKZ FLD_03 = I_SOBSL.
*           IF SY-SUBRC EQ 0.
*              LT_GROUP2-FLD_04 = PUR_GROUP
*          ENDIF.
*    ENDIF."

  LS_PLANT-PLANT = I_WERKS.
  FIELD-SYMBOLS <LS_CODE> LIKE LINE OF LT_CODE.
  READ TABLE LT_CODE ASSIGNING <LS_CODE> WITH KEY CODEGRP = '0040'
                                                                            FLD_01 = LS_MARA-MTART
                                                                            FLD_02 = LS_MARA-MATKL BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    LS_PLANT-PUR_GROUP = <LS_CODE>-FLD_03.
  ELSE.
    READ TABLE LT_CODE ASSIGNING <LS_CODE> WITH KEY CODEGRP = '0041'
                                                                              FLD_01 = LS_MARA-MTART
                                                                              FLD_02 = I_BESKZ
                                                                              FLD_03 = I_SOBSL BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LS_PLANT-PUR_GROUP = <LS_CODE>-FLD_04.
    ENDIF.
  ENDIF.

*PLANTDATAX	PLANT	I_WERKS
*	PUR_GROUP	"X"
  LS_PLANTX-PLANT = I_WERKS.
  LS_PLANTX-PUR_GROUP = ABAP_TRUE.

*CALL FUNCTION                  BAPI_MATERIAL_SAVEDATA
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      HEADDATA   = LS_HEAD
      PLANTDATA  = LS_PLANT
      PLANTDATAX = LS_PLANTX
    IMPORTING
      RETURN     = LS_RETURN.

*A) LS_RETURN - TYPE = 'E'인 데이터 존재 시
*EXPORT PARAMTER                  VALUE
*TYPE                 "E"
*MESSAGE                  LS_RETURN-TYPE = 'E' 인 MESSAGE
*
*B) LS_RETURN - TYPE = 'E'인 데이터가 없는 경우
*EXPORT PARAMTER                  VALUE
*TYPE                 "S"
*MESSAGE                  자재마스터를 확장했습니다.

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
