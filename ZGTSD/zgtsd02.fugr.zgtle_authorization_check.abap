FUNCTION ZGTLE_AUTHORIZATION_CHECK .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_WERKS) TYPE  WERKS_D DEFAULT '*'
*"     VALUE(I_SPART) TYPE  SPART DEFAULT '*'
*"     VALUE(I_VSTEL) TYPE  VSTEL DEFAULT '*'
*"     VALUE(I_TPLST) TYPE  TPLST DEFAULT '*'
*"     VALUE(I_BZAREA) TYPE  ZBZAREA DEFAULT '*'
*"     VALUE(I_VKGRP) TYPE  VKGRP DEFAULT '*'
*"     VALUE(I_TYPE) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(E_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------

  SY-SUBRC = 4.


  CASE I_TYPE.
    WHEN '1'. "플랜트
      AUTHORITY-CHECK OBJECT 'ZCBO_LE003'
        ID 'SPART'  DUMMY
        ID 'WERKS'  FIELD I_WERKS
        ID 'BZAREA' DUMMY.

    WHEN '2'. "제품군
      AUTHORITY-CHECK OBJECT 'ZCBO_LE003'
        ID 'SPART'  FIELD I_SPART
        ID 'WERKS'  DUMMY
        ID 'BZAREA' DUMMY.

    WHEN '3'. "출하지점
      AUTHORITY-CHECK OBJECT 'ZCBO_LE001'
        ID 'VSTEL'  FIELD I_VSTEL.

    WHEN '4'. "운송계획지점
      AUTHORITY-CHECK OBJECT 'ZCBO_LE002'
        ID 'TPLST'  FIELD I_TPLST.

    WHEN '5'. "사업장
      AUTHORITY-CHECK OBJECT 'ZCBO_LE003'
        ID 'SPART'  DUMMY
        ID 'WERKS'  DUMMY
        ID 'BZAREA' FIELD I_BZAREA.

    WHEN '7'. "영업그룹
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
        ID 'VKBUR'  DUMMY
        ID 'VKGRP' FIELD I_VKGRP.

    WHEN OTHERS.
      SY-SUBRC = 4.

  ENDCASE.

  E_SUBRC = SY-SUBRC.



ENDFUNCTION.
