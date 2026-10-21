*----------------------------------------------------------------------*
***INCLUDE LZGTSD90F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form ZGT_INIT_TIMESTAMP_1009
*&---------------------------------------------------------------------*
*& 유지보수 뷰 저장 이전 Timestamp 자동 구성
*&---------------------------------------------------------------------*
FORM zgt_init_timestamp_1009 .

*-- 입력된 값 기준 Time Stamp 값 자동 구성
  SELECT SINGLE a~ernam,    a~erdat,    a~erzeit,
                a~erdatlo,  a~ertimlo,  a~ertcode,  a~erempno,
                a~aenam,    a~aedat,    a~aezeit,
                a~aedatlo,  a~aetimlo,  a~aetcode,  a~aeempno

    FROM zgtsdt1009 AS a
   WHERE a~vkorg EQ @zgtsdv1009-vkorg
     AND a~vtweg EQ @zgtsdv1009-vtweg
     AND a~spart EQ @zgtsdv1009-spart
     AND a~auart EQ @zgtsdv1009-auart
     AND a~ettyp EQ @zgtsdv1009-ettyp

    INTO @DATA(ls_1009).

  IF sy-subrc EQ 0.
*-- 변경 이력
    zgtsdv1009-aenam   = sy-uname.
    zgtsdv1009-aedat   = sy-datum.
    zgtsdv1009-aezeit  = sy-uzeit.
    zgtsdv1009-aedatlo = sy-datlo.
    zgtsdv1009-aetimlo = sy-timlo.
    zgtsdv1009-aetcode = sy-tcode.
    zgtsdv1009-aeempno = sy-uname.

  ELSE.
*-- 신규 생성
    zgtsdv1009-ernam   = sy-uname.
    zgtsdv1009-erdat   = sy-datum.
    zgtsdv1009-erzeit  = sy-uzeit.
    zgtsdv1009-erdatlo = sy-datlo.
    zgtsdv1009-ertimlo = sy-timlo.
    zgtsdv1009-ertcode = sy-tcode.
    zgtsdv1009-erempno = sy-uname.

  ENDIF.

ENDFORM.
