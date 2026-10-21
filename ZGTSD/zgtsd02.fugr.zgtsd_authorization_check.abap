FUNCTION ZGTSD_AUTHORIZATION_CHECK .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG DEFAULT '*'
*"     VALUE(I_VTWEG) TYPE  VTWEG DEFAULT '*'
*"     VALUE(I_SPART) TYPE  SPART DEFAULT '*'
*"     VALUE(I_WERKS) TYPE  WERKS_D DEFAULT '*'
*"     VALUE(I_KKBER) TYPE  KKBER DEFAULT '*'
*"     VALUE(I_BUKRS) TYPE  BUKRS DEFAULT '*'
*"     VALUE(I_VKGRP) TYPE  VKGRP DEFAULT '*'
*"     VALUE(I_VKBUR) TYPE  VKBUR DEFAULT '*'
*"     VALUE(I_TYPE) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(E_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------

  SY-SUBRC = 4.

  CASE I_TYPE.
    WHEN '1'.                "영업조직
      AUTHORITY-CHECK OBJECT 'ZCBO_SD001'
          ID 'VKORG' FIELD I_VKORG
          ID 'VTWEG' DUMMY
          ID 'SPART' DUMMY
          ID 'WERKS' DUMMY.

    WHEN '2'.                "유통채널
      AUTHORITY-CHECK OBJECT 'ZCBO_SD001'
          ID 'VKORG' DUMMY
          ID 'VTWEG' FIELD I_VTWEG
          ID 'SPART' DUMMY
          ID 'WERKS' DUMMY.

    WHEN '3'.                "제품군
      AUTHORITY-CHECK OBJECT 'ZCBO_SD001'
          ID 'VKORG' DUMMY
          ID 'VTWEG' DUMMY
          ID 'SPART' FIELD I_SPART
          ID 'WERKS' DUMMY.

    WHEN '4'.                "플랜트
      AUTHORITY-CHECK OBJECT 'ZCBO_SD001'
          ID 'VKORG' DUMMY
          ID 'VTWEG' DUMMY
          ID 'SPART' DUMMY
          ID 'WERKS' FIELD I_WERKS.
*
    WHEN '5'.                "여신영역
      AUTHORITY-CHECK OBJECT 'ZCBO_SD002'
          ID 'KKBER' FIELD I_KKBER
          ID 'BUKRS' DUMMY.

    WHEN '6'.                "회사코드
      AUTHORITY-CHECK OBJECT 'ZCBO_SD002'
          ID 'KKBER' DUMMY
          ID 'BUKRS' FIELD I_BUKRS.

    WHEN '7'.                "영업그룹
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
        ID 'VKBUR'  DUMMY
        ID 'VKGRP' FIELD I_VKGRP.

* [가온전선-SD][26.04.01] Add 영업팀 권한 Check  - Start.
    WHEN '8'.                "영업팀
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
        ID 'VKBUR' FIELD I_VKBUR
        ID 'VKGRP' DUMMY.
* [가온전선-SD][26.04.01] Add 영업팀 권한 Check  - End.

    WHEN OTHERS.
      SY-SUBRC = 4.

  ENDCASE.

  E_SUBRC = SY-SUBRC.



ENDFUNCTION.
