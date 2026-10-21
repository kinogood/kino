*----------------------------------------------------------------------*
***INCLUDE LZGTSD00F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form message_text_build
*&---------------------------------------------------------------------*
*& 메세지 내역 구성
*&---------------------------------------------------------------------*
*&      <-- PS_RETURN  : 메세지 정보 기준 내역정보 리턴
*&---------------------------------------------------------------------*
FORM message_text_build  CHANGING ps_return TYPE bapiret2.

  DATA : lv_msgid TYPE symsgid,
         lv_msgnr TYPE symsgno,
         lv_msgv1 TYPE symsgv1,
         lv_msgv2 TYPE symsgv2,
         lv_msgv3 TYPE symsgv3,
         lv_msgv4 TYPE symsgv4.

  lv_msgid = ps_return-id.
  lv_msgnr = ps_return-number.
  lv_msgv1 = ps_return-message_v1.
  lv_msgv2 = ps_return-message_v2.
  lv_msgv3 = ps_return-message_v3.
  lv_msgv4 = ps_return-message_v4.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = lv_msgid
      msgnr               = lv_msgnr
      msgv1               = lv_msgv1
      msgv2               = lv_msgv2
      msgv3               = lv_msgv3
      msgv4               = lv_msgv4
    IMPORTING
      message_text_output = ps_return-message.

ENDFORM.
