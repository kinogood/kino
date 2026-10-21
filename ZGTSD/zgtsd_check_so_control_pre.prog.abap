*&---------------------------------------------------------------------*
*& Include          ZGTSD_CHECK_SO_CONTROL_PRE
*&---------------------------------------------------------------------*
**********************************************************************
*로직 미확정으로 주석 처리
**********************************************************************

  DATA : LV_ACTIVE TYPE CHAR01,
         LV_ABGRU  TYPE ABGRU,
         LV_EXCEPT TYPE CHAR01,
         LV_STAT   TYPE ZGTSDT1011-APPROVED_STATUS,
         LV_TXT    TYPE CHAR40,
         LV_VAL    TYPE DOMVALUE_L,
         LV_FLAG   TYPE CHAR01,
         LV_CHG    TYPE CHAR01,
         LV_USERID TYPE SYST_UNAME.

  DATA : BEGIN OF LS_CFG,
           TYPE  TYPE CHAR02,
           ABGRU TYPE CHAR02,
           TABLE TYPE CHAR40,
           FLD   TYPE CHAR40,
         END OF LS_CFG,
         LT_CFG LIKE TABLE OF LS_CFG.

  DATA : LT_1014  LIKE TABLE OF ZGTSDT1014 WITH HEADER LINE.

* Z_SD_RFC_365_SO_CHANGE_NEW에서 SO 변경자 SAP ID IMPORT
  CLEAR LV_USERID.
  IF T180-TRTYP EQ 'V'.
    IMPORT LV_USERID FROM MEMORY ID 'ZGTSD_D365ID'.
    IF LV_USERID IS NOT INITIAL.
      SY-UNAME = LV_USERID.
      FREE MEMORY ID 'ZGTSD_D365ID'.
    ENDIF.
  ENDIF.

  FIELD-SYMBOLS : <LFS_OVAL>,
                  <LFS_NVAL>.

  CHECK VBAK-ERDAT >= '20250801'.

  SELECT SINGLE MANDT INTO SY-MANDT  "특정 TCODE SKIP   Z
    FROM ZGTPPT1010
   WHERE MODULE_KIND  = 'SD'
     AND CODEGRP = '5010'
*     AND FLD_01 = SY-REPID
     AND FLD_02 = 'ZGTSD_CHECK_SO_CONTROL_PRE'
     AND FLD_03 = SY-TCODE.
  CHECK SY-SUBRC NE 0.

**********************************************************************
*ZGTSD_IF_I_SO_REJECT_RELEASE 에서  승인시 거부사유 제거를 위한 FLAG
*FLAG 값이 있을경우 하위 로직 SKIP
  IMPORT LV_FLAG FROM MEMORY ID 'ZGTSD_UPD_STS'.
  CHECK LV_FLAG IS INITIAL.
**********************************************************************

  SELECT SINGLE MANDT INTO SY-MANDT  "특정 유저 SKIP   Z
    FROM ZGTPPT1010
   WHERE MODULE_KIND  = 'SD'
     AND CODEGRP = 'ZZZZ'
     AND FLD_01 = SY-UNAME.
  CHECK SY-SUBRC NE 0.

*1) 에너지 사업부 여부 확인

  CALL FUNCTION 'ZGTSD_EXIT_CONTROL'
    EXPORTING
      I_PERFORM = 'CHECK_SO_CONTROL'
      I_VKORG   = VBAK-VKORG
      I_AUART   = VBAK-AUART
      I_VKBUR   = VBAK-VKBUR
    IMPORTING
      E_ACTIVE  = LV_ACTIVE.

  CHECK LV_ACTIVE EQ |Y|.

*2) 판매오더 생성/변경 여부 확인
  CASE T180-TRTYP.
    WHEN 'H'.     "생성

      LV_ABGRU = 'Z2'.
      LV_CHG = 'X'.

    WHEN 'V'.     "변경

*3) 변경의 경우 통제 대상 여부 확인
* 품의서 상태 '진행' 이면 판매오더 수정 불가
      SELECT SINGLE APPROVED_STATUS INTO LV_STAT
        FROM ZGTSDT1013
       WHERE VBELN = VBAK-VBELN
*         AND APPROVED_STATUS IN ('P','T')
         AND APPROVED_STATUS EQ 'P'
         AND ZSEQNO = ( SELECT MAX( ZSEQNO ) FROM ZGTSDT1013
                         WHERE VBELN = VBAK-VBELN
*                           AND APPROVED_STATUS IN ('P','T') ) .
                           AND APPROVED_STATUS EQ 'P' ) .
      IF SY-SUBRC = 0.
        LV_VAL = LV_STAT.
        LV_TXT = ZGTSD_CL_COMMON=>GET_DOMAIN_TEXT( EXPORTING IV_DOMNAME  = 'ZGTD_APPROVE_ST'
                                                             IV_DOMVALUE = LV_VAL ).
        MESSAGE E065(ZGTSD01) WITH LV_TXT.EXIT.  "주문 변경 품의서 상태가 &1 입니다.
      ENDIF.

*  3-1) 통제 대상 필드 조회
      SELECT FLD_03 AS TYPE  FLD_04 AS ABGRU
             FLD_05 AS TABLE FLD_07 AS FLD
        INTO CORRESPONDING FIELDS OF TABLE LT_CFG
        FROM ZGTPPT1010
       WHERE MODULE_KIND EQ 'SD'
         AND CODEGRP     EQ '5009'
         AND FLD_09      EQ 'Y'
         AND FLD_10      LE SY-DATUM "통제시작일
         AND FLD_11      GE SY-DATUM "통제종료일
         AND FLD_12      EQ 'X'.

      SORT LT_CFG BY TABLE FLD.

      IF LT_CFG[] IS INITIAL.
        EXIT.
      ENDIF.

*3-2) 아이템 추가 여부 확인
      LOOP AT XVBAP INTO DATA(LS_XVBAP).

        CHECK LS_XVBAP-UPDKZ IS NOT INITIAL.

        READ TABLE YVBAP INTO DATA(LS_YVBAP) WITH KEY POSNR = LS_XVBAP-POSNR.
        IF SY-SUBRC NE 0 AND LS_XVBAP-UPDKZ = 'I'.  "    " 신규 추가
          READ TABLE LT_CFG INTO LS_CFG WITH KEY TABLE = 'VBAP' TYPE  = 'I'.
          IF SY-SUBRC = 0.
            LV_ABGRU = LS_CFG-ABGRU.
          ELSE.
            LV_ABGRU = 'Z2'.
          ENDIF.
          LV_CHG = 'X'.EXIT.
        ENDIF.

        CLEAR LS_YVBAP.

      ENDLOOP.

*3-3) 대금청구계획 추가 여부 확인
*      LOOP AT XFPLT INTO DATA(LS_XFPLT).
*
*        CHECK LS_XFPLT-UPDKZ IS NOT INITIAL.
*
*        READ TABLE YFPLT INTO DATA(LS_YFPLT) WITH KEY FPLNR = LS_XFPLT-FPLNR
*                                                      FPLTR = LS_XFPLT-FPLTR.
*        IF SY-SUBRC NE 0 AND LS_XFPLT-UPDKZ = 'I'.  "    " 신규 추가
*          READ TABLE LT_CFG INTO LS_CFG WITH KEY TABLE = 'FPLT' TYPE  = 'I'.
*          IF SY-SUBRC = 0.
*            LV_ABGRU = LS_CFG-ABGRU.
*          ELSE.
*            LV_ABGRU = 'Z2'.
*          ENDIF.
*          LV_CHG = 'X'.EXIT.
*        ENDIF.
*
*        CLEAR LS_YFPLT.
*
*      ENDLOOP.


      IF LV_CHG IS INITIAL.

*3-4) 판매오더 변경 여부 확인
        LOOP AT LT_CFG INTO LS_CFG .

          CASE LS_CFG-TABLE.

            WHEN 'VBAK'.    "VBAK 변경 여부 확인
              CHECK XVBAK IS NOT INITIAL.
              UNASSIGN : <LFS_OVAL>, <LFS_NVAL>.
              ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE YVBAK TO <LFS_OVAL>.
              CHECK SY-SUBRC = 0.
              ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE XVBAK TO <LFS_NVAL>.
              CHECK SY-SUBRC = 0.

              IF <LFS_OVAL> NE <LFS_NVAL>.
                LV_ABGRU = LS_CFG-ABGRU.
                LV_CHG = 'X'. EXIT.
              ENDIF.

            WHEN 'VBKD'.    " VBKD 변경 여부 확인

              READ TABLE YVBKD INTO DATA(LS_YVBKD) WITH KEY POSNR = '000000'.
              READ TABLE XVBKD INTO DATA(LS_XVBKD) WITH KEY POSNR = '000000'.

              CHECK LS_YVBKD-VBELN IS NOT INITIAL AND LS_XVBKD-VBELN IS NOT INITIAL.

              UNASSIGN : <LFS_OVAL>, <LFS_NVAL>.
              ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_YVBKD TO <LFS_OVAL>.
              CHECK SY-SUBRC = 0.
              ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_XVBKD TO <LFS_NVAL>.
              CHECK SY-SUBRC = 0.

              IF <LFS_OVAL> NE <LFS_NVAL>.
                LV_ABGRU = LS_CFG-ABGRU.
                LV_CHG = 'X'. EXIT.
              ENDIF.

              CLEAR : LS_YVBKD, LS_XVBKD.

            WHEN 'VBAP'.

              CLEAR LS_XVBAP.
              LOOP AT XVBAP INTO LS_XVBAP.

                CHECK LS_XVBAP-UPDKZ IS NOT INITIAL.

                CLEAR LS_YVBAP.
                READ TABLE YVBAP INTO LS_YVBAP WITH KEY POSNR = LS_XVBAP-POSNR.
                UNASSIGN : <LFS_OVAL>, <LFS_NVAL>.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_YVBAP TO <LFS_OVAL>.
                CHECK SY-SUBRC = 0.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_XVBAP TO <LFS_NVAL>.
                CHECK SY-SUBRC = 0.

                IF <LFS_OVAL> NE <LFS_NVAL>.
                  LV_ABGRU = LS_CFG-ABGRU.
                  LV_CHG = 'X'. EXIT.
                ENDIF.

              ENDLOOP.

            WHEN 'VBEP'.

              LOOP AT XVBEP INTO DATA(LS_XVBEP) where ETENR = '0001'.

                CHECK LS_XVBEP-UPDKZ IS NOT INITIAL.

                READ TABLE YVBEP INTO DATA(LS_YVBEP) WITH KEY POSNR = LS_XVBEP-POSNR
                                                              ETENR = '0001'.
                UNASSIGN : <LFS_OVAL>, <LFS_NVAL>.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_YVBEP TO <LFS_OVAL>.
                CHECK SY-SUBRC = 0.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_XVBEP TO <LFS_NVAL>.
                CHECK SY-SUBRC = 0.

                IF <LFS_OVAL> NE <LFS_NVAL>.
                  LV_ABGRU = LS_CFG-ABGRU.
                  LV_CHG = 'X'. EXIT.
                ENDIF.

                CLEAR LS_YVBEP.
              ENDLOOP.

            WHEN 'FPLT'. "대금청구계획: 일자


              LOOP AT XFPLT INTO DATA(LS_XFPLT).

                CHECK LS_XFPLT-UPDKZ IS NOT INITIAL.

                READ TABLE YFPLT INTO DATA(LS_YFPLT) WITH KEY FPLNR = LS_XFPLT-FPLNR
                                                              FPLTR = LS_XFPLT-FPLTR.
                UNASSIGN : <LFS_OVAL>, <LFS_NVAL>.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_YFPLT TO <LFS_OVAL>.
                CHECK SY-SUBRC = 0.
                ASSIGN COMPONENT LS_CFG-FLD OF STRUCTURE LS_XFPLT TO <LFS_NVAL>.
                CHECK SY-SUBRC = 0.

                IF <LFS_OVAL> NE <LFS_NVAL>.
                  LV_ABGRU = LS_CFG-ABGRU.
                  LV_CHG = 'X'. EXIT.
                ENDIF.

                CLEAR : LS_YFPLT, LS_XFPLT.

              ENDLOOP.
              CLEAR LS_XFPLT.
          ENDCASE.

        ENDLOOP.

      ENDIF.

  ENDCASE.

  IF LV_CHG IS NOT INITIAL.

    LOOP AT XVBAP.

*CBO LOG.
      CASE T180-TRTYP.
        WHEN 'H'.

        WHEN 'V'.
*ITEM 거부사유 입력 여부 확인
          IF XVBAP-ABGRU IS NOT INITIAL AND XVBAP-ABGRU NE 'Z2'.
            CLEAR YVBAP.
            READ TABLE YVBAP WITH KEY POSNR = XVBAP-POSNR.
            IF SY-SUBRC = 0 AND XVBAP-ABGRU NE YVBAP-ABGRU.
              MOVE-CORRESPONDING XVBAP TO LT_1014.
              LT_1014-ABGRU = XVBAP-ABGRU.
              ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_U
                                              CHANGING  CS_TIMESTAMP = LT_1014-TIMESTAMP ).

              APPEND LT_1014. CLEAR LT_1014.
            ELSE.
              DATA(LV_FLG) = 'X'.
            ENDIF.
          ENDIF.

      ENDCASE.

*FLAG값이 있을경우 Z2  (사용자가 거부사유 입력시 기존 거부사유 유지 위해)
      IF LV_FLG NE 'X'.
        XVBAP-ABGRU = LV_ABGRU.
      ENDIF.

      MODIFY XVBAP.
      CLEAR : LV_FLG.
    ENDLOOP.

    MESSAGE W000(ZGTSD01) WITH '에너지본부 주문 생성/변경은 팀장님 승인 필요합니다. (세일즈아웃룩 주문보류내역 탭에서 가능)'.

  ELSE.
    LT_1014-ZSEQNO = 'Z999999999'. APPEND LT_1014.  " ZGTSD_CHECK_SO_CONTROL_SAVE SKIP..
  ENDIF.

  FREE MEMORY ID 'ZGT_CHECK_SO_CONTROL'.
  IF LT_1014[] IS NOT INITIAL.
    EXPORT LT_1014 TO MEMORY ID 'ZGT_CHECK_SO_CONTROL'.
  ENDIF.
