*&---------------------------------------------------------------------*
*& Report ZGTSDR1040_STAT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*​
*& 모듈        : SD.
*& 프로그램 ID : ZGTSDR1040_STAT
*& 프로그램 명 : [GT] 소재 OEM/직판 매출정산 - Create Multi SO Stat Obj
*& 개요   :
*& 생성일 : 2026.04.17.​
*& 생성자 : ZGODEV05.
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​ 2026.04.17.
*& 수정자  :​ ZGODEV05.
*& 수정개요: Create. ( Copy Program SDSTATU2 )
*&                     Write Result Display 제거.
*&---------------------------------------------------------------------*

REPORT ZGTSDR1040_STAT.

*&---------------------------------------------------------------------*
*& TABLES
*&---------------------------------------------------------------------*
TABLES: jsto, vbak, vbap, tvak, tvap, t459k, cobrb, tvta.

*&---------------------------------------------------------------------*
*& Data.
*&---------------------------------------------------------------------*
DATA: BEGIN OF xvbak OCCURS 100.
        INCLUDE STRUCTURE vbak.
DATA: END OF xvbak.
DATA: BEGIN OF xvbap OCCURS 100.
        INCLUDE STRUCTURE vbap.
DATA: END OF xvbap.

*&---------------------------------------------------------------------*
*& SELECT-OPTIONS
*&---------------------------------------------------------------------*
SELECT-OPTIONS: s_vbeln FOR vbak-vbeln.

*&---------------------------------------------------------------------*
*& Start process
*&---------------------------------------------------------------------*
SELECT * FROM vbak WHERE objnr <> space AND
                         vbeln IN s_vbeln.
  SELECT SINGLE * FROM jsto WHERE objnr = vbak-objnr.
  IF sy-subrc <> 0.
*    OBJNR does not exist in table JSTO
    xvbak = vbak.
    APPEND xvbak.
  ENDIF.
ENDSELECT.

LOOP AT xvbak.
  SELECT SINGLE * FROM tvak WHERE auart = xvbak-auart.

  CALL FUNCTION 'STATUS_OBJECT_CREATE'
    EXPORTING
      chgkz                        = 'X'
      client                       = sy-mandt
      objnr                        = xvbak-objnr
      obtyp                        = 'VBK'
      stsma                        = tvak-stsma
    IMPORTING
      objnr                        = xvbak-objnr
    EXCEPTIONS
      obtyp_invalid                = 1
      status_object_already_exists = 2
      stsma_invalid                = 3
      stsma_obtyp_invalid          = 4
      OTHERS                       = 5.


  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDLOOP.

SELECT * FROM vbap WHERE objnr <> space AND
                         vbeln IN s_vbeln.
  SELECT SINGLE * FROM jsto WHERE objnr = vbap-objnr.
  IF sy-subrc <> 0.
    xvbap = vbap.
    APPEND xvbap.
  ENDIF.
ENDSELECT.

LOOP AT xvbap.
  SELECT SINGLE * FROM tvap WHERE pstyv = xvbap-pstyv.

  CALL FUNCTION 'STATUS_OBJECT_CREATE'
    EXPORTING
      chgkz                        = 'X'
      client                       = sy-mandt
      objnr                        = xvbap-objnr
      obtyp                        = 'VBP'
      stsma                        = tvap-stsma
    IMPORTING
      objnr                        = xvbap-objnr
    EXCEPTIONS
      obtyp_invalid                = 1
      status_object_already_exists = 2
      stsma_invalid                = 3
      stsma_obtyp_invalid          = 4
      OTHERS                       = 5.

  IF sy-subrc = 0.
    vbap = xvbap.
*     Einzelfertigungsstaus setzen
    IF xvbap-kzvbr = 'E'.
      PERFORM status_setzen(sapfv45p) USING 'I0234' 'X'.
    ELSE.
      PERFORM status_setzen(sapfv45p) USING 'I0235' 'X'.
    ENDIF.
*     Kopf nachlesen (tvta wird in t459k_lesen benötigt)
    IF vbak-vbeln NE xvbap-vbeln.
      SELECT SINGLE * FROM vbak WHERE
                         vbeln = xvbap-vbeln.
    ENDIF.
    PERFORM tvta_select(sapmv45a)
                        USING vbak-vkorg
                              vbak-vtweg
                              vbak-spart.
*     Kalkulationsstatus setzen
    PERFORM t459k_lesen(sapmv45a).
    IF vbap-kalnr IS INITIAL.
      IF NOT t459k-kalku IS INITIAL AND
         t459k-mntga NE '2'.
        PERFORM status_setzen(sapfv45p) USING 'I0164' 'X'.
      ENDIF.
    ELSE.
      PERFORM status_setzen(sapfv45p) USING 'I0165' 'X'.
    ENDIF.
* Abrechnungsvorschrift erfaßt?
    SELECT SINGLE * FROM cobrb WHERE objnr = vbap-objnr.
    IF sy-subrc = 0.
      PERFORM status_setzen(sapfv45p) USING 'I0028' 'X'.
    ENDIF.

    COMMIT WORK.

  ENDIF.
ENDLOOP.
