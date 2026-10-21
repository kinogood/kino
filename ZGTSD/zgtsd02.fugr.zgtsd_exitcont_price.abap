FUNCTION ZGTSD_EXITCONT_PRICE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VKORG) TYPE  VKORG OPTIONAL
*"     REFERENCE(I_SPART) TYPE  SPART OPTIONAL
*"     REFERENCE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     REFERENCE(I_AUART) TYPE  AUART OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_EXCETP) TYPE  CHAR01
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_EXITCONT_PRICE
*& 프로그램 명 :
*& 개요   : "수주보고와 Sales Order 판가 다를시 User Exit 실행을
*            제외하기 위한 Function
*& 생성일 : 2025.04.30
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SalesOutlook
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_SPART FOR VBAK-SPART,
           LR_AUART FOR VBAK-AUART,
           LR_WERKS FOR LIKP-WERKS.

  CLEAR : E_EXCETP.

  IF I_VKORG IS INITIAL AND I_SPART IS INITIAL AND I_WERKS IS INITIAL.
    E_EXCETP = ZGTSD_N.EXIT.
  ENDIF.

  IF I_VKORG IS NOT INITIAL.
    __RNG LR_VKORG 'I' 'EQ' I_VKORG ''.
  ENDIF.

  IF I_SPART IS NOT INITIAL.
    __RNG LR_SPART 'I' 'EQ' I_SPART ''.
  ENDIF.

  IF I_WERKS IS NOT INITIAL.
    __RNG LR_WERKS 'I' 'EQ' I_WERKS ''.
  ENDIF.

  IF I_AUART IS NOT INITIAL.
    __RNG LR_AUART 'I' 'EQ' I_AUART ''.
  ENDIF.

  SELECT SINGLE
         CASE WHEN FLD_09 = '1' THEN 'Y' ELSE 'N' END AS FLAG
         INTO @E_EXCETP
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'SD'
     AND CODEGRP EQ '5006'
     AND FLD_01  IN @LR_VKORG
     AND FLD_03  IN @LR_SPART
     AND FLD_05  IN @LR_WERKS
     AND FLD_07  IN @LR_AUART.


ENDFUNCTION.
