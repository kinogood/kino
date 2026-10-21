*----------------------------------------------------------------------*
***INCLUDE LZGTMM15F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_WHERE_OPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_KUNNR
*&      --> I_LIFNR
*&      --> I_VBELN
*&      --> I_MATNR
*&---------------------------------------------------------------------*
FORM SET_WHERE_OPTION  USING    PV_ZPJNO
                                                         PV_KUNNR
                                                         PV_LIFNR
                                                         PV_VBELN
                                                         PV_POSNR
                                                         PV_MATNR
                                           CHANGING PV_WHERE TYPE STRING.




*옵셔널 파라메터 중 입력 유무에 따라 셀렉트 조건 추가 설정
*영업팀
  IF PV_ZPJNO IS NOT INITIAL.
     PV_WHERE &&= | AND ZPJNO = '{ PV_ZPJNO }' |.
  ENDIF.
**영업그룹
*  IF PV_VKGRP IS NOT INITIAL.
*    PV_WHERE &&= | AND VKGRP = '{  PV_VKGRP }' | .
*  ENDIF.
*고객코드
  IF PV_KUNNR IS NOT INITIAL.
     PV_WHERE &&= | AND KUNNR = '{  PV_KUNNR }' | .
  ENDIF.
*공급업체코드
  IF PV_LIFNR IS NOT INITIAL.
     PV_WHERE &&= | AND LIFNR = '{  PV_LIFNR }' | .
  ENDIF.
*판매오더번호
  IF PV_VBELN IS NOT INITIAL.
    PV_WHERE &&= | AND VBELN = '{  PV_VBELN }' | .
  ENDIF.
*판매오더항번
  IF PV_POSNR IS NOT INITIAL.
    PV_WHERE &&= | AND POSNR = '{  PV_POSNR }' | .
  ENDIF.
* 자재문서
  IF PV_MATNR IS NOT INITIAL.
    PV_WHERE &&= | AND MATNR = '{  PV_MATNR }' | .
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
***INCLUDE LZGTMM15F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_WHERE_OPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_KUNNR
*&      --> I_LIFNR
*&      --> I_VBELN
*&      --> I_MATNR
*&---------------------------------------------------------------------*
FORM SET_WHERE_OPTION2  USING   PV_VKBUR
                                                         PV_VKGRP
                                                         PV_KUNNR
                                                         PV_LIFNR
                                                         PV_VBELN
                                                         PV_DLVRQ
                                           CHANGING PV_WHERE TYPE STRING.


*옵셔널 파라메터 중 입력 유무에 따라 셀렉트 조건 추가 설정
*영업팀
  IF PV_VKBUR IS NOT INITIAL.
     PV_WHERE &&= | AND VKBUR = '{ PV_VKBUR }' |.
  ENDIF.
*영업그룹
  IF PV_VKGRP IS NOT INITIAL.
    PV_WHERE &&= | AND VKGRP = '{  PV_VKGRP }' | .
  ENDIF.
*고객코드
  IF PV_KUNNR IS NOT INITIAL.
     PV_WHERE &&= | AND KUNNR = '{  PV_KUNNR }' | .
  ENDIF.
*공급업체코드
  IF PV_LIFNR IS NOT INITIAL.
     PV_WHERE &&= | AND LIFNR = '{  PV_LIFNR }' | .
  ENDIF.
*판매오더번호
  IF PV_VBELN IS NOT INITIAL.
    PV_WHERE &&= | AND VBELN = '{  PV_VBELN }' | .
  ENDIF.
*판매오더항번
  IF PV_DLVRQ IS NOT INITIAL.
    PV_WHERE &&= | AND DLVRQ = '{  PV_DLVRQ }' | .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_CURRENCY  USING PV_PRICE
                                       CHANGING PV_EX_PRICE .

  DATA LV_AMOUNT(20) TYPE C.
  LV_AMOUNT = PV_PRICE.  CONDENSE LV_AMOUNT NO-GAPS.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
    EXPORTING
      CURRENCY          = 'KRW'
      SAP_AMOUNT      = LV_AMOUNT
    IMPORTING
      IDOC_AMOUNT     = LV_AMOUNT
            .
    PV_EX_PRICE = LV_AMOUNT.

ENDFORM.
