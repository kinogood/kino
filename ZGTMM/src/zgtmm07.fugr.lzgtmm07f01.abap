*----------------------------------------------------------------------*
***INCLUDE LZGTMM07F01.
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
                                        PV_BESKZ
                                        PV_SOBSL
                               CHANGING CS_PLANT TYPE BAPI_MARC
                                        CS_PLANTX TYPE BAPI_MARCX.

* PLANT
  CS_PLANT-PLANT = PV_WERKS.
  CS_PLANT-MRP_TYPE = 'ND'.


*"IF I_BESKZ IS NOT INITIAL 인 경우 -> Import Parameter 값 사용
*  PROC_TYPE = I_BESKZ
*  SPPROCTYPE = I_SOBSL
*ELSE -> 코드 마스터에서 값 가져옴 (자재유형 기준)
*SELECT SINGLE *
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0050'
*AND FLD_01 = LS_MARA-MTART
*
*  PROC_TYPE = FLD_02
*  SPPROCTYPE = FLD_03"
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
*
*SELECT SINGLE *
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0051'
*AND FLD_01 = I_WERKS
*AND FLD_02 = LS_MARA-MATKL.
*
*  SLOC_EXPRC = FLD_03"
  SELECT SINGLE
    FLD_03
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0051'
    AND FLD_01 EQ @PV_WERKS
    AND FLD_02 EQ @PV_MATKL
    INTO @CS_PLANT-SLOC_EXPRC.


*DEP_REQ_ID	개별/일괄 소요량	"[특수 목드럼에 사용되는 FLANGE는 코드 마스터의 값으로 할당]
*
*1) 자재 그룹이 플랜지면서
*IF LS_MARA-MATKL = 'RW600501'
*
*2) 해당 플랜지의 구분기호가 특수 드럼 기호인 경우
*= 아래 SELECT 문의 결과 FLD_02 = 'S' 인 경우
*SELECT SINGLE F~MATNR, F~DRM_GUBUN, P~FLD_02
*FROM ZGTMM_CV_FLANGE_GUBUN AS F
*JOIN ZGTPPT1010 AS P
*ON F~DRM_GUBUN = P~FLD_01
*WHERE F~MATNR = I_MATNR
*P~MODULE_KIND = 'MM'
*AND P~CODEGRP = '0700'
*
*3) 코드 마스터의 값 할당
*SELECT SINGLE *
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0052'
*AND FLD_01 = I_WERKS
*AND FLD_02 = LS_MARA-MATKL.
*
*DEP_REQ_ID = FLD_03
*ISS_ST_LOC = FLD_04
*
*[그 外 모든 CASE]
*그 외에는 모두 아래와 같이 할당
*DEP_REQ_ID = '2'
*ISS_ST_LOC(출고 저장장소) 할당 없음"
*ISS_ST_LOC	출고 저장 장소
*
  SELECT SINGLE @ABAP_TRUE
  FROM ZGTMM_CV_FLANGE_GUBUN AS F
  JOIN ZGTPPT1010 AS P ON F~DRM_GUBUN EQ P~FLD_01
  WHERE F~MATNR EQ @PV_MATNR
  AND P~MODULE_KIND EQ 'MM'
  AND P~CODEGRP EQ '0700'
  AND P~FLD_02 EQ 'S'
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

  IF CS_PLANTX-PROC_TYPE IS NOT INITIAL.
    CS_PLANTX-PROC_TYPE = ABAP_TRUE.
  ENDIF.

  CS_PLANTX-SPPROCTYPE = ABAP_TRUE.
  CS_PLANTX-AVAILCHECK = ABAP_TRUE.
  CS_PLANTX-SLOC_EXPRC = ABAP_TRUE.
  CS_PLANTX-DEP_REQ_ID = ABAP_TRUE.
  IF CS_PLANT-ISS_ST_LOC IS NOT INITIAL.
    CS_PLANTX-ISS_ST_LOC = ABAP_TRUE.
  ENDIF.

ENDFORM.
