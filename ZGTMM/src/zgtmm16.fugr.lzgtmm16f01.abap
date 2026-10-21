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
*프로젝트번호
  IF PV_ZPJNO IS NOT INITIAL.
     PV_WHERE &&= | AND ZPJNO = '{ PV_ZPJNO }' |.
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
*판매문서항번
  IF PV_POSNR IS NOT INITIAL.
    PV_WHERE &&= | AND POSNR = '{  PV_POSNR }' | .
  ENDIF.
*자재번호
  IF PV_MATNR IS NOT INITIAL.
    PV_WHERE &&= | AND MATNR = '{  PV_MATNR }' | .
  ENDIF.

ENDFORM.
