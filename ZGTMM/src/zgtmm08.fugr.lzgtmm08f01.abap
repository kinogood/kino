*----------------------------------------------------------------------*
***INCLUDE LZGTMM08F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_SET_PLANT_DATA_MRPVIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_WERKS
*&      --> I_MATNR
*&      --> LS_MARA_MTART
*&      --> LS_MARA_MATKL
*&      --> I_BESKZ
*&      --> I_SOBSL
*&      <-- LS_PLANT
*&      <-- LS_PLANTX
*&---------------------------------------------------------------------*
FORM F_SET_PLANT_DATA_MRPVIEW  USING    PV_WERKS
                                                                        PV_MATNR
                                                                        PV_MTART
                                                                        PV_MATKL
                                                                        PV_SPART
                                                                        PV_BESKZ
                                                                        PV_SOBSL
                                        CHANGING CS_PLANT   TYPE BAPI_MARC
                                                         CS_PLANTX TYPE BAPI_MARCX.

* PLANT
  CS_PLANT-PLANT = PV_WERKS.
  CS_PLANT-MRP_TYPE = 'ND'.

*"IF I_BESKZ IS NOT INITIAL 인 경우 -> Import Parameter 값 사용
*ELSE -> 코드 마스터에서 값 가져옴 (자재유형 기준)

  IF PV_BESKZ IS NOT INITIAL.
    CS_PLANT-PROC_TYPE = PV_BESKZ.
    CS_PLANT-SPPROCTYPE = PV_SOBSL.
  ELSE.
    SELECT SINGLE
      FLD_02,
      FLD_03
      FROM ZGTPPT1010
      WHERE MODULE_KIND EQ 'MM'
      AND CODEGRP EQ '0050'
      AND FLD_01 EQ @PV_MTART
      INTO ( @CS_PLANT-PROC_TYPE, @CS_PLANT-SPPROCTYPE ).
  ENDIF.

*AVAILCHECK	가용성 점검 그룹	"KP"
  CS_PLANT-AVAILCHECK = 'KP'.

*SLOC_EXPRC	외부 조달 기본 저장위치	"코드 마스터에서 값 가져옴 (자재그룹 기준)
  SELECT SINGLE
    FLD_03
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0051'
    AND FLD_01 EQ @PV_WERKS
    AND FLD_02 EQ @PV_MATKL
    INTO @CS_PLANT-SLOC_EXPRC.

  " 2026.07.14MRP 관리자 값 코드마스터에서 할당 (플랜트, 자재유형, 제품군 기준)
  SELECT SINGLE
    FLD_04
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0053'
    AND FLD_01 EQ @PV_WERKS
    AND FLD_02 EQ @PV_MTART
    AND FLD_03 EQ @PV_SPART
    INTO @CS_PLANT-MRP_CTRLER.

*DEP_REQ_ID	개별/일괄 소요량	"[특수 목드럼에 사용되는 FLANGE는 코드 마스터의 값으로 할당]
*1) 자재 그룹이 플랜지면서
*2) 해당 플랜지의 구분기호가 특수 드럼 기호인 경우
*= 아래 SELECT 문의 결과 FLD_02 = 'S' 인 경우
*3) 코드 마스터의 값 할당

*[그 外 모든 CASE]
*DEP_REQ_ID = '2'
*ISS_ST_LOC(출고 저장장소) 할당 없음"
*ISS_ST_LOC	출고 저장 장소

*" 2026.07.14 일반/특수 구분없이 전부 체크로 변경 -> 주석처리
*  SELECT SINGLE @ABAP_TRUE
*  FROM ZGTMM_CV_FLANGE_GUBUN AS F
*  JOIN ZGTPPT1010 AS P ON F~DRM_GUBUN EQ P~FLD_01
*  WHERE F~MATNR EQ @PV_MATNR
*  AND P~MODULE_KIND EQ 'MM'
*  AND P~CODEGRP EQ '0700'
*  AND P~FLD_02 EQ 'S'
*  INTO @DATA(LV_CHK).

  SELECT SINGLE @ABAP_TRUE
  FROM ZGTMM_CV_FLANGE_GUBUN AS F
  WHERE F~MATNR EQ @PV_MATNR
  INTO @DATA(LV_CHK).

  IF PV_MATKL EQ 'RW600501' AND LV_CHK EQ ABAP_TRUE.
    SELECT SINGLE
      FLD_03,
      FLD_04
      FROM ZGTPPT1010
      WHERE MODULE_KIND EQ 'MM'
      AND CODEGRP EQ '0052'
      AND FLD_01 EQ @PV_WERKS
      AND FLD_02 EQ @PV_MATKL
      INTO ( @CS_PLANT-DEP_REQ_ID, @CS_PLANT-ISS_ST_LOC ).
  ELSE.
    CS_PLANT-DEP_REQ_ID = '2'.
  ENDIF.
*
*PLANT  플랜트 I_WERKS
*MRP_TYPE MRP 타입  "X"
*PROC_TYPE  조달 유형 "I_BESKZ 값 있는 경우 ""X""
*--> (수정) PLANTDATA-PROC_TYPE 값 있는 경우 ""X"""
*SPPROCTYPE 특별 조달 유형  "X"
*AVAILCHECK	가용성 점검 그룹	"X"
*SLOC_EXPRC	외부 조달 기본 저장위치	"X"
*DEP_REQ_ID	개별/일괄 소요량	"X"
*ISS_ST_LOC 출고 저장 장소  PLANTDATA-ISS_ST_LOC 값 있는 경우 "X"

  CS_PLANTX-PLANT = PV_WERKS.
  CS_PLANTX-MRP_TYPE = ABAP_TRUE.
  CS_PLANTX-SPPROCTYPE = ABAP_TRUE.
  CS_PLANTX-AVAILCHECK = ABAP_TRUE.
  CS_PLANTX-DEP_REQ_ID = ABAP_TRUE.

  " 존재여부 체크 후 X표시
  IF CS_PLANT-PROC_TYPE IS NOT INITIAL.
    CS_PLANTX-PROC_TYPE = ABAP_TRUE.
  ENDIF.
  IF CS_PLANT-ISS_ST_LOC IS NOT INITIAL.
    CS_PLANTX-ISS_ST_LOC = ABAP_TRUE.
  ENDIF.
  IF CS_PLANT-SLOC_EXPRC IS NOT INITIAL.
    CS_PLANTX-SLOC_EXPRC = ABAP_TRUE.
  ENDIF.
  IF CS_PLANT-MRP_CTRLER IS NOT INITIAL.
    CS_PLANTX-MRP_CTRLER = ABAP_TRUE.
  ENDIF.
ENDFORM.
