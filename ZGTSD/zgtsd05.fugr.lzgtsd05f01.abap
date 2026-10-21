*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form message_text_build
*&---------------------------------------------------------------------*
*& BAPI Message Text 내역 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PS_RETURN     : BAPI Message 코드 정보 & Text 리턴
*&---------------------------------------------------------------------*
FORM message_text_build  CHANGING ps_return  TYPE bapiret2.

  CLEAR : ps_return-message.

  CHECK ps_return IS NOT INITIAL.

*-- Message Text 정보 구성
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = ps_return-id
      msgnr               = ps_return-number
      msgv1               = ps_return-message_v1
      msgv2               = ps_return-message_v2
      msgv3               = ps_return-message_v3
      msgv4               = ps_return-message_v4
    IMPORTING
      message_text_output = ps_return-message.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form next_number_get
*&---------------------------------------------------------------------*
*& Number Range 번호 채번 수행
*&---------------------------------------------------------------------*
*&      --> PV_OBJECT     : Number Range 오브젝트 명
*&      --> PV_RANGE_NR   : 번호 범위 정보
*&      <-- PV_NUMBER     : 채번 번호 리턴
*&---------------------------------------------------------------------*
FORM next_number_get  USING    pv_object    TYPE nrobj
                               pv_range_nr  TYPE nrnr
                      CHANGING pv_number.
  CLEAR pv_number.

*-- Number Range 번호 채번 수행
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = pv_range_nr
      object                  = pv_object
    IMPORTING
      number                  = pv_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

ENDFORM.
