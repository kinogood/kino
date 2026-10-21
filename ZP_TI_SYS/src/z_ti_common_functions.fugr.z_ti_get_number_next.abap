FUNCTION z_ti_get_number_next.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(ZMPTY) TYPE  ZTIREQTY OPTIONAL
*"     VALUE(BUKRS) TYPE  BUKRS OPTIONAL
*"  EXPORTING
*"     VALUE(LCONO) TYPE  ZTIREQNO
*"  EXCEPTIONS
*"      NOT_TYPE
*"----------------------------------------------------------------------

  DATA : l_nrrangenr LIKE inri-nrrangenr,
         l_object    LIKE inri-object,
         l_ret_cd    LIKE inri-returncode,
         l_ret_code  LIKE sy-subrc.

  CASE zmpty.
    WHEN 'TT' OR 'TA' OR 'CD' OR 'TB' OR  "> 수입의뢰...
         'LA' OR 'LB' OR 'LS' OR 'LC' OR
         'LO' OR 'PU' OR
         'DA' OR 'DP' OR 'GS' OR
         'ZZ'.
      l_object = 'ZTIREQNO'.
    WHEN 'IS'.         " INSURANCE.
      l_object = 'ZTIIS'.
    WHEN 'IP'.         " INSURANCE.
      l_object = 'ZTIIIPNO'.
    WHEN 'BL'.         " B/L
      l_object = 'ZTIIBLNO'.
    WHEN 'LG'.         " L/G
      l_object = 'ZTIILGNO'.
    WHEN 'BS'.         " 반입예정.
      l_object = 'ZTIIBSNO'.
    WHEN 'BT'.         " 반입.
      l_object = 'ZTIBT'.
    WHEN 'BI'.         " 반입.
      l_object = 'ZTIIBINO'.
*     WHEN 'BO'.         " 반출.
*        L_OBJECT = 'ZTIBO'.
    WHEN 'BO'.         " 반출.
      l_object = 'ZTIIBONO'.
    WHEN 'IV'.         " COMMERCIAL INVOICE.
      l_object = 'ZTIIVONO'.
    WHEN 'CC'.         " 통관문서.
      l_object = 'ZTIICCNO'.
    WHEN 'CN'.         " 통관문서 Temp
      l_object = 'ZTIICCTN'.
    WHEN 'CS'.         " 비용문서.
      l_object = 'ZTIICSNO'.
*     WHEN 'CL'.         " Cliam
*        L_OBJECT = 'ZTICL'.
    WHEN 'PN'.         " Notice.
      l_object = 'ZTIPNTNO'.
    WHEN 'GR'.         " 입고.
      l_object = 'ZTIIGRNO'.
    WHEN 'VA'.         " 세금계산서.
      l_object = 'ZTIVATNO'.
    WHEN 'AC'.         " 인수증.
      l_object = 'ZTIACDNO'.
    WHEN 'TX'.         " 기납증.
      l_object = 'ZTITAXNO'.
    WHEN 'SD'.         " 수출.
      l_object = 'ZEXESDNO'.
    WHEN 'ED'.
      l_object = 'ZTISNCNT'.
    WHEN 'RS'.   "2004.01.06 INSERTED BY SYKIM
      l_object = 'ZTIPFIN'.
    WHEN OTHERS.
      RAISE  not_type.
  ENDCASE.

  l_nrrangenr  =  zmpty.

  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
            nr_range_nr      =   l_nrrangenr
            object           =   l_object
**            QUANTITY         =   '1'
            subobject        =   bukrs
*            TOYEAR           =   GJAHR
**            IGNORE_BUFFER    =   SPACE
       IMPORTING
            number           =   lcono
*            QUANTITY         =
            returncode       =   l_ret_cd
       EXCEPTIONS
            interval_not_found      =  1 ">Interval not found
            number_range_not_intern =  2 ">Number range is not internal
            object_not_found        =  3 ">Object not defined in TNRO
**>Number of numbers requested must be > 0
            quantity_is_0           =  4
**">Number of numbers requested must be 1
            quantity_is_not_1       =  5
**">Interval used up. Change not possible.
            interval_overflow       =  6.

  l_ret_code = l_ret_cd.
  IF sy-subrc <> 0.
*   Fehler bei interner Nummernvergabe
    MESSAGE a417(62).
  ELSEIF l_ret_code >= 2.
*   Das Nummernkreisintervall ist ausgesch?ft, keine Nummer mehr frei
    MESSAGE a593(60).
  ENDIF.

ENDFUNCTION.
