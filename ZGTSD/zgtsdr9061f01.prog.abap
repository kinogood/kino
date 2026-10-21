*&---------------------------------------------------------------------*
*& Include          ZGTSDR9061F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_initialization
*&---------------------------------------------------------------------*
*& Initialization  정보 구성
*&---------------------------------------------------------------------*
FORM set_initialization .

  DATA : lv_fdat TYPE dats,
         lv_tdat TYPE dats.

*-- 조회조건 필드 기본값 구성
  CLEAR : p_auart, s_erdat, s_erdat[].
  p_auart = gc_auart-zbc2.

  lv_fdat = sy-datum(06) && '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_fdat
    IMPORTING
      last_day_of_month = lv_tdat
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  APPEND VALUE #(
                  sign   = gc_sign-i
                  option = gc_optn-bt
                  low    = lv_fdat
                  high   = lv_tdat
                ) TO s_erdat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_mig_data
*&---------------------------------------------------------------------*
*&  적송 Mig. 정보 Select
*&---------------------------------------------------------------------*
FORM select_mig_data .

ENDFORM.
