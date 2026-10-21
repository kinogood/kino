*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1030BDC
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bom_modify_by_bdc
*&---------------------------------------------------------------------*
FORM BOM_MODIFY_BY_BDC.
  DATA: LV_AUSCH   TYPE CHAR6,
        LV_SORTF   TYPE CHAR10,
        LV_WKMGN   TYPE CHAR17,
        LV_WKSRT   TYPE CHAR17,
        LV_WKEND   TYPE CHAR17,
        LV_FHANK   TYPE CHAR17,
        LV_MESSAGE TYPE CHAR100,
        LV_LGORT   LIKE MARD-LGORT.

  DATA : LT_TEMP    LIKE TABLE OF GT_TEMP.

  READ TABLE GT_TAIL  WITH KEY CHK  = 'X'
                               FLAG = 'GOOD'.
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH 'BOM /LC 정보 수정 대상자료가 없습니다.'.
    RETURN.
  ENDIF.

  READ TABLE GT_TAIL WITH KEY CHK = 'X'
                              FLAG = 'ERROR'.

  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '오류 자재는 선택을 제외하고 저장하세요.'.
    RETURN.
  ENDIF.

  LOOP AT GT_TAIL  WHERE CHK  = 'X'
                     AND FLAG = 'GOOD'.

    REFRESH: GT_BDCDATA, GT_MESSTAB.
    CLEAR:   GT_BDCDATA, GT_MESSTAB, LV_MESSAGE.

    WRITE: GT_TAIL-AUSCH TO LV_AUSCH  NO-GROUPING,
           GT_TAIL-WKMGN TO LV_SORTF  NO-GROUPING NO-ZERO,
           GT_TAIL-WKMGN TO LV_WKMGN  NO-GROUPING NO-ZERO,
           GT_TAIL-WKSRT TO LV_WKSRT  NO-GROUPING,
           GT_TAIL-WKEND TO LV_WKEND  NO-GROUPING,
           GT_TAIL-FHANK TO LV_FHANK  NO-GROUPING.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0100'.
    PERFORM BDC_FIELD       USING: 'RC29N-MATNR'
                                   GT_TAIL-MATNR,
                                   'RC29N-WERKS'
                                   GP_WERKS,
                                   'RC29N-STLAN'
                                   GP_STLAN,      " 용도
                                   'RC29N-STLAL'
                                   GT_TAIL-STLAL,
                                   'BDC_OKCODE'
                                   '=KALL'.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2110'.
    PERFORM BDC_FIELD       USING: 'RC29K-STLST'
                                   '01',
                                   'BDC_OKCODE'
                                   '=FCPU'.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2150'.
    PERFORM BDC_FIELD       USING: 'BDC_OKCODE'
                                   '=SETP'.       " 위치

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '0708'.
    PERFORM BDC_FIELD       USING: 'BDC_CURSOR'
                                   'RC29P-SELPO',
                                   'RC29P-SELPO'
                                   GT_TAIL-POSNR,
                                   'BDC_OKCODE'
                                   '=CLWI'.

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2150'.
    PERFORM BDC_FIELD       USING: 'RC29P-AUSKZ(01)'
                                   'X',
                                   'BDC_OKCODE'
                                   '=PALL'.         " 품목

    PERFORM BDC_DYNPRO      USING 'SAPLCSDI' '2130'.
    PERFORM BDC_FIELD       USING: 'RC29P-AUSCH'
                                   LV_AUSCH.

*&  배치관리여부(SPACE=>미관리, 'X'=>관리)
    IF GT_TAIL-DPCBT = SPACE.
      IF GT_TAIL-LGFLG = 'X'.
        PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                    '=FCBU'.
      ELSE.
        PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                    '=PDAT'.       " 상태/설명 TAB

        PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
        PERFORM BDC_FIELD    USING: 'RC29P-LGORT'
                                    GT_TAIL-LGORT,
                                    'BDC_OKCODE'
                                    '=FCBU'.
      ENDIF.
    ELSEIF GP_STLAN = '6'.
      PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                  '=FCBU'.
    ELSE.
      IF GT_TAIL-CALCM = '2'.
        PERFORM BDC_FIELD USING: 'RC29P-SORTF'
                                 LV_SORTF.
      ENDIF.

      IF GT_TAIL-LGFLG = 'X'.                    " 저장위치 존재하면
        PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                    '=CAB/CS_DATA'.
      ELSE.
        PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                    '=PDAT'.    " 상태/설명 TAB

        PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
        PERFORM BDC_FIELD    USING: 'RC29P-LGORT'
                                    GT_TAIL-LGORT,
                                    'BDC_OKCODE'
                                    '=CAB/CS_DATA'.
      ENDIF.

      PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
      PERFORM BDC_FIELD    USING: 'RC29P-/SAPMP/MET_LRCH'
                                  GT_TAIL-CALCM,
                                  'RC29P-/SAPMP/FIX_AS_J'
                                  LV_WKMGN,
                                  'RC29P-/SAPMP/RUND_FAKT'
                                  '1',
                                  'BDC_OKCODE'
                                  '/00'.

      IF GT_TAIL-CALCM = '2'.
        PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
        PERFORM BDC_FIELD    USING: 'RC29P-/SAPMP/MAX_FERTL'
                                    LV_FHANK,
                                    'BDC_OKCODE'
                                    '=FCBU'.
      ELSEIF GT_TAIL-CALCM = 'Z1'.
        PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
        PERFORM BDC_FIELD    USING: 'RC29P-/SAPMP/MAX_FERTL'
                                    LV_FHANK,
                                    'RC29P-/SAPMP/FIX_AS_E'
                                    LV_WKSRT,
                                    'RC29P-/SAPMP/FIX_AS_L'
                                    LV_WKEND,
                                    'BDC_OKCODE'
                                    '=FCBU'.
      ELSEIF GT_TAIL-CALCM = SPACE.
        PERFORM BDC_DYNPRO   USING 'SAPLCSDI' '2130'.
        PERFORM BDC_FIELD    USING: 'BDC_OKCODE'
                                    '=FCBU'.
      ENDIF.
    ENDIF.

    PERFORM BDC_TRANSACTION USING 'CS02'.

*&  처리결과를 읽는다.
    PERFORM EDIT_ERROR_MESSAGE  USING LV_MESSAGE.

*&  BDC처리시 에러발생 여부 체크
    IF NOT LV_MESSAGE IS INITIAL.
      GT_TAIL-MESSAGE = LV_MESSAGE.
    ELSE.
      COMMIT WORK  AND WAIT.

      GT_TAIL-FLAG = 'SUCC'.

*& 2010.08.10 CSR : C20100810_17193
*& 1801일 경우 해당 bom에 대하여 1xxx의 생산버젼이 있을 경우 BOM 변경
*반영
      IF GP_WERKS EQ '1801'.

        CLEAR : LV_MESSAGE.
        PERFORM CHANGE_PROD_VERSION USING LV_MESSAGE.

        IF NOT LV_MESSAGE IS INITIAL.
          GT_TAIL-MESSAGE = LV_MESSAGE.
        ELSE.
          COMMIT WORK AND WAIT.
          GT_TAIL-FLAG = 'SUCC'.
        ENDIF.

      ENDIF.

*& 2014.03.03 CSR:기능개선_11724 저장위치 확인
      IF GT_TAIL-FLAG = 'SUCC'.

        SELECT SINGLE LGORT
          INTO LV_LGORT
          FROM MARD
         WHERE MATNR = GT_TAIL-IDNRK
           AND WERKS = GP_WERKS
           AND LGORT = GT_TAIL-LGORT.

* 저장위치가 확장 않된 경우
        IF SY-SUBRC NE 0.

          PERFORM MMSC_EXTENTION_LGORT USING GT_TAIL-IDNRK
                                             GT_TAIL-LGORT
                                             GT_TAIL-FLAG.

          IF GT_TAIL-FLAG = 'E'.
            GT_TAIL-MESSAGE = '저장위치 확장 오류'.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.

*&---------------------------------------------------------------------*
    IF GT_TAIL-FLAG = 'SUCC'. " 성공건에 대해 자재마스터의 조립품 스크랩(불량) 추가
      READ TABLE GT_TEMP INTO DATA(LS_TEMP) WITH KEY MATNR = GT_TAIL-MATNR.
      IF SY-SUBRC EQ 0.
        APPEND LS_TEMP TO LT_TEMP.
      ENDIF.
    ENDIF.
*&---------------------------------------------------------------------*

    MODIFY GT_TAIL.
  ENDLOOP.

*  자재마스터의 조립품 스크랩(불량) 업데이트
  IF LT_TEMP[] IS NOT INITIAL.
    DATA : LT_CONF TYPE TABLE OF CONF_OUT.
    DATA : LV_MASSAGE(200).
    DATA : LV_CHK_ERR.

    REFRESH LT_CONF.

    SORT LT_TEMP BY MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING MATNR.
    LOOP AT LT_TEMP INTO LS_TEMP.
      CLEAR LV_CHK_ERR.
      CALL FUNCTION 'VC_I_GET_CONFIGURATION'
        EXPORTING
          INSTANCE            = LS_TEMP-CUOBF
          MILL_SE_RECALC      = 'X'
          MILL_SE_EVAL_DK     = 'X'
        TABLES
          CONFIGURATION       = LT_CONF
        EXCEPTIONS
          INSTANCE_NOT_FOUND  = 1
          INTERNAL_ERROR      = 2
          NO_CLASS_ALLOCATION = 3
          INSTANCE_NOT_VALID  = 4
          OTHERS              = 5.
      IF SY-SUBRC <> 0.
        LV_CHK_ERR = ABAP_TRUE.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = SY-MSGID
            MSGNR               = SY-MSGNO
            MSGV1               = SY-MSGV1
            MSGV2               = SY-MSGV2
            MSGV3               = SY-MSGV3
            MSGV4               = SY-MSGV4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LV_MASSAGE.
      ENDIF.

      IF LV_CHK_ERR IS INITIAL.
        READ TABLE LT_CONF INTO DATA(LS_CONF) WITH KEY ATNAM = 'PD_CA_CUSTOMER_CODE'.


        PERFORM MM02_BABI USING LS_TEMP LS_CONF-ATWRT
                           CHANGING LV_CHK_ERR LV_MASSAGE.
        CLEAR LS_CONF.
      ENDIF.

*    오류처리
      IF LV_CHK_ERR IS NOT INITIAL.
        GT_TAIL-FLAG = 'E'.
        GT_TAIL-MESSAGE = LV_MASSAGE.
        MODIFY GT_TAIL FROM GT_TAIL TRANSPORTING FLAG MESSAGE
         WHERE MATNR = LS_TEMP-MATNR.
      ENDIF.

    ENDLOOP.
  ENDIF.


ENDFORM.                    " bom_modify_by_bdc
