*&---------------------------------------------------------------------*
*&  Include           MZQM0020I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.
      IF GV_TRTYP <> 'A'.
        PERFORM CHECK_DATA_CHANGED USING GV_FLAG.

        IF GV_FLAG = 'J'.
          PERFORM SAVE_COMPLAIN_DATA USING 'X'.
        ELSEIF GV_FLAG = 'N' OR GV_FLAG = SPACE.
          LEAVE TO SCREEN 0.
        ELSE.
          EXIT.
        ENDIF.

        PERFORM DEQUEUE_ZQMT0011H USING GV_RCEPNO.
      ELSE.
        LEAVE TO SCREEN 0.

      ENDIF.


    WHEN 'CACL'.
      PERFORM EXE_CACL.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_SAVE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF  GV_TRTYP <> 'A'.
        PERFORM CHECK_DATA_CHANGED USING GV_FLAG.

        IF GV_FLAG = 'J'.
          PERFORM SAVE_COMPLAIN_DATA USING 'X'.
          PERFORM GET_COMPLAIN_DATA.
        ELSEIF GV_FLAG = 'N' OR GV_FLAG = SPACE.
          LEAVE TO SCREEN 0.
        ELSE.
          EXIT.
        ENDIF.

        PERFORM DEQUEUE_ZQMT0011H USING GV_RCEPNO.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.


*__저장
    WHEN 'SAVE'.

*__ 고객불만관련 수정 20180807 BY SDW
      PERFORM CHECK_WBS.
      CHECK GV_CHK_WBS NE 'X'.
*__ 고객불만관련 수정 20180807 BY SDW

      PERFORM SAVE_COMPLAIN_DATA USING ' '.
      CHECK GV_FORM_FLG NE 'X'.

      PERFORM GET_COMPLAIN_DATA.

*__접수취소
    WHEN 'CANC2'.
      $$POPUP_TO_CONFIRM_STEP '접수중인 고객불만을 취소하시겠습니까?'
                              ' '
                              '접수취소'.
      CHECK GV_ANSWER = 'J'.
      GS_100-STATUS = 'CL99'.
      GS_100-KZLOESCH = 'X'.
      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      PERFORM GET_COMPLAIN_DATA.

*__접수완료
    WHEN 'CONF'.

*__ 고객불만관련 수정 20180807 BY SDW
      PERFORM CHECK_WBS.
      CHECK GV_CHK_WBS NE 'X'.
*__ 고객불만관련 수정 20180807 BY SDW

      PERFORM CHECK_DATA_CHANGED USING GV_FLAG.


      IF  G_BUKRS =  '6000'.     "2012.11 수정

        IF GV_FLAG = 'J'.
          PERFORM SAVE_COMPLAIN_DATA USING 'X'.
          PERFORM GET_COMPLAIN_DATA.
        ENDIF.
        PERFORM CHECK_FAULTDETAIL.
      ENDIF.

      READ TABLE GT_100 WITH KEY KZLOESCH = ''.
      IF SY-SUBRC NE 0.
*        $$POPUP_TO_CONFIRM_STEP '자재/불량정보가 없습니다.'
*                                '계속 진행하시겠습니까?'
*                                '접수완료'.

        MESSAGE I001  WITH  '자재/불량정보 결함유형을 입력하세요.'.
*
        EXIT.
*          CHECK GV_ANSWER = 'J'.
      ENDIF.

      PERFORM CHECK_EMAIL2 CHANGING GV_FLG.

      CHECK GV_FLG IS INITIAL.
      GS_100-STATUS = 'CL20'.

      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      PERFORM GET_COMPLAIN_DATA.

      PERFORM BUILD_MAIL_DATA3 CHANGING GV_FLG.
*__릴리즈
    WHEN 'SEND'.
      GS_100-QMDAT = SY-DATUM.
      GS_100-STATUS = 'CL30'.
      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      PERFORM GET_COMPLAIN_DATA.

*__불만취소
    WHEN 'CANC3'.
      PERFORM CANC_COMPLAIN_DATA.
      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      PERFORM GET_COMPLAIN_DATA.

*__종료승인
    WHEN 'OK'.
*접수 완료시 불량유형정보 입력 여부 체크 로직 추가(회사코드 1000인경우)
      IF  G_BUKRS =  '6000'.
        PERFORM CHECK_FAULTDETAIL.
      ENDIF.
      PERFORM ENDING_PERMIT_DATA.

*__종료반려
    WHEN 'UNDO'.
      PERFORM ENDING_UNDO_DATA.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_KUNUM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_KUNUM_SCREEN_100 INPUT.

  PERFORM GET_KUNUMT USING  GS_100-KUNUM  CHANGING GS_100-KUNUMT.

ENDMODULE.                 " READ_KUNUM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_WERKS_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_WERKS_SCREEN_100 INPUT.

*-{기능개선_73239 - 추가
  PERFORM CHECK_WERKS USING GS_100-WERKS_H.
*-}기능개선_73239 2015.03.31

  PERFORM GET_WERKST USING  GS_100-WERKS_H  CHANGING GS_100-WERKST.

ENDMODULE.                 " READ_WERKS_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_PRCTR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_PRCTR_SCREEN_100 INPUT.

  PERFORM GET_PRCTRT USING  GS_100-PRCTR  CHANGING GS_100-PRCTRT.

ENDMODULE.                 " READ_PRCTR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_PRIORITY_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_PRIORITY_SCREEN_100 INPUT.

  PERFORM GET_SUL_STATUS_TXT USING    'ZPRIORITY' GS_100-PRIORITY
                             CHANGING GS_100-PRIORITYT.

ENDMODULE.                 " READ_PRIORITY_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  DATA H_CURRENT  LIKE SY-TABIX.
  DATA H_TEXT_WA  TYPE SOURCE.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.

    WHEN 'SAVE'.
*      PERFORM PROCESS_CHECK.
*      CHECK GV_FORM_FLG NE 'X'.
*      PERFORM SAVE_TEXT.
*      CHECK GV_FORM_FLG NE 'X'.
*      PERFORM SAVE_PROCESS USING 'GS_200'
*                                  GS_200.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_0230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_0230 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES1_N
                        USING  G_CL_TEXT1
                               G_OLIN1
                               G_NLIN1.

ENDMODULE.                 " GET_LONG_TEXT_0230  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_0240  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_0240 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES2_N
                        USING  G_CL_TEXT2
                               G_OLIN2
                               G_NLIN2.

ENDMODULE.                 " GET_LONG_TEXT_0240  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_RCPERNR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_RCPERNR_SCREEN_100 INPUT.

  GV_FLAG = '1'.

  IF GS_100-RCPERNR IS NOT INITIAL.
    PERFORM GET_USRID USING GS_100-RCPERNR
                      CHANGING GS_100-RCPERNRT
                               GS_100-RCNAM
                               GS_100-RCNAMT.
  ENDIF.

ENDMODULE.                 " READ_RCPERNR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_CORDI_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_CORDI_SCREEN_100 INPUT.

  GV_FLAG = '2'.

  IF GS_100-CORDINR IS NOT INITIAL.
    PERFORM GET_USRID USING GS_100-CORDINR
                      CHANGING GS_100-CORDINRT
                               GS_100-CORDI
                               GS_100-CORDIT.
  ENDIF.
ENDMODULE.                 " READ_CORDI_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_JGNAM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_JGNAM_SCREEN_100 INPUT.

  GV_FLAG = '3'.

  IF GS_100-JGNAMNR IS NOT INITIAL.
    PERFORM GET_USRID USING GS_100-JGNAMNR
                     CHANGING GS_100-JGNAMNRT
                              GS_100-JGNAM
                              GS_100-JGNAMT.
  ENDIF.
ENDMODULE.                 " READ_JGNAM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_SDNAM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_SDNAM_SCREEN_100 INPUT.

  GV_FLAG = '4'.

  IF GS_100-SDNAMNR IS NOT INITIAL.
    PERFORM GET_USRID USING GS_100-SDNAMNR
                     CHANGING GS_100-SDNAMNRT
                              GS_100-SDNAM
                              GS_100-SDNAMT.
  ENDIF.

ENDMODULE.                 " READ_SDNAM_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_DSTGR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_DSTGR_SCREEN_100 INPUT.

  PERFORM  DSTGR_READ  USING  GS_100-DSTGR  CHANGING  GS_100-DSTGRT.

ENDMODULE.                 " READ_DSTGR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_VKBUR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_VKBUR_SCREEN_100 INPUT.

*& C20120703_39817: 영업그룹 선입력 위한 조건구문 추가
  IF GS_100-VKGRP IS NOT INITIAL.
    PERFORM  VKBUR_READ  USING  GS_100-VKBUR  CHANGING  GS_100-VKBURT.
  ELSE.
    MESSAGE W001 WITH '영업그룹을 먼저 입력하세요.'.
    CLEAR: GS_100-VKBUR,
           GS_100-VKBURT.
  ENDIF.
ENDMODULE.                 " READ_VKBUR_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_VKGRP_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_VKGRP_SCREEN_100 INPUT.

*& C20120703_39817: 영업그룹 선입력 위한 조건구문 추가
  IF GS_100-VKGRP IS INITIAL.
    MESSAGE W001 WITH '영업그룹을 먼저 입력하세요.'.
    CLEAR: GS_100-VKBUR,
           GS_100-VKBURT.
    EXIT.
  ENDIF.

  PERFORM  VKGRP_READ  USING   GS_100-VKGRP  CHANGING  GS_100-VKGRPT.
*& C20120703_39817: 영업팀 자동입력
  IF GV_CURFLG EQ 'X'.
    PERFORM  VKBUR_READ_CHANGE  CHANGING GS_100-VKBUR GS_100-VKBURT.
  ENDIF.

ENDMODULE.                 " READ_VKGRP_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_VTWEG_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_VTWEG_SCREEN_100 INPUT.

  PERFORM  VTWEG_READ  USING  GS_100-VTWEG  CHANGING  GS_100-VTWEGT.

ENDMODULE.                 " READ_VTWEG_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  AUTHORITY_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE AUTHORITY_CHECK INPUT.

  CHECK GS_100-WERKS_H NE SPACE.

  PERFORM AUTHORITY_CHECKING_PROC   USING GS_100-WERKS_H
                                    CHANGING GV_SUBRC.
  IF GV_SUBRC = 0.
    PERFORM GET_BUKRS USING    GS_100-WERKS_H
                      CHANGING GV_BUKRS.

*    IF GV_BUKRS EQ '2000'.
*      GV_DOKAR = 'JQS'.
*    ELSE.
*      GV_DOKAR = 'QCS'.
*    ENDIF.
  ELSE.
    MESSAGE E003 WITH '플랜트 [' GS_100-WERKS_H
                    '] 작업권한을 확인하세요.'.
  ENDIF.

ENDMODULE.                 " AUTHORITY_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0210 INPUT.

  OK_SAVE = OK_CODE.

  CASE OK_SAVE.
    WHEN 'CREATE'.
      PERFORM CHECK_SCREEN USING GV_FLG.
      CHECK GV_FLG IS INITIAL.
      PERFORM CALL_GOS USING GC_E.

    WHEN 'CHANGE'.
      PERFORM CALL_GOS USING GC_E.

    WHEN 'DISPLAY'.
      PERFORM CALL_GOS USING GC_D.

  ENDCASE.

  "첨부파일
  PERFORM CHECK_ATTACH.

*  CASE OK_SAVE.
*
*    WHEN 'CREATE'.
*      PERFORM CHECK_SCREEN USING GV_FLG.
*      CHECK GV_FLG IS INITIAL.
*      PERFORM BDC_CV01N.
*      WAIT UP TO 2 SECONDS.
*      PERFORM EXEC_CV02N.
*
*    WHEN 'CHANGE'.
*      PERFORM EXEC_CV02N.
*
*    WHEN 'DISPLAY'.
*      PERFORM EXEC_CV03N.
*
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_TABLE_CONTROL INPUT.

  MODIFY GT_100 FROM GS_100_TC INDEX TC_100-CURRENT_LINE.

ENDMODULE.                 " READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MATERIAL_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_MATERIAL_DATA INPUT.

  GV_MATCHG = 'X'.

ENDMODULE.                 " GET_MATERIAL_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_100_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_100_ITAB_DATA INPUT.

*** 자재번호 오류여부 체크로직 추가해야 함.
*
*  READ TABLE GT_100 INTO GS_100_TC
*                   INDEX TC_100-CURRENT_LINE.
*  IF SY-SUBRC = 0.
*    IF GV_MATCHG = 'X'.
*      CLEAR : GV_MATCHG.
*      GT_100-WERKS = GS_100-WERKS.
*
*      IF GT_100-WERKS IS NOT INITIAL AND GT_100-ZMATSEQ IS INITIAL
*        AND ( GT_100-MATNR IS NOT INITIAL OR
*              GT_100-KDAUF IS NOT INITIAL ) .
*        GT_100-ZMATSEQ = TC_100-CURRENT_LINE.
**        GT_100-ZMATSEQ = SY-TABIX.
**        GV_SEQCHK = 'X'.
*      ENDIF.
*
*      IF GT_100-MATNR IS NOT INITIAL.
*        SELECT SINGLE A~MEINS B~MAKTX
*          INTO (GT_100-MGEIN, GT_100-MAKTX)
*          FROM MARA AS A
*         INNER JOIN MAKT AS B
*            ON B~SPRAS = SY-LANGU
*           AND A~MATNR = B~MATNR
*         WHERE A~MATNR = GT_100-MATNR.
*
*        GT_100-VRKME = GT_100-MGEIN.
*
*        SELECT SINGLE SPART
*          INTO GT_100-SPGCD
*          FROM MARA
*         WHERE MATNR = GT_100-MATNR.
*      ENDIF.
*
*      MODIFY  GT_100 INDEX TC_100-CURRENT_LINE.
*    ELSE.
*      MODIFY GT_100 INDEX TC_100-CURRENT_LINE
*                    TRANSPORTING MARK.
*    ENDIF.
*  ELSE.
*    GT_100-WERKS = GS_100-WERKS.
*
*    IF GT_100-WERKS IS NOT INITIAL AND GT_100-ZMATSEQ IS INITIAL
*AND ( GT_100-MATNR IS NOT INITIAL OR GT_100-KDAUF IS NOT INITIAL ) .
*      GT_100-ZMATSEQ = TC_100-CURRENT_LINE.
**      GT_100-ZMATSEQ = SY-TABIX.
**      GV_SEQCHK = 'X'.
*    ENDIF.
*
*    IF GT_100-MATNR IS NOT INITIAL.
*      SELECT SINGLE A~MEINS B~MAKTX
*        INTO (GT_100-MGEIN, GT_100-MAKTX)
*        FROM MARA AS A
*       INNER JOIN MAKT AS B
*          ON B~SPRAS = SY-LANGU
*         AND A~MATNR = B~MATNR
*       WHERE A~MATNR = GT_100-MATNR.
*
*      GT_100-VRKME = GT_100-MGEIN.
*
*      SELECT SINGLE SPART
*        INTO GT_100-SPGCD
*        FROM MARA
*       WHERE MATNR = GT_100-MATNR.
*    ENDIF.
*
*    APPEND GT_100.
*  ENDIF.

ENDMODULE.                 " MODIFY_100_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATA_GT_170  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DATA_GT_170 INPUT.

  IF GT_160-MARK = 'X'.

    CLEAR: GV_RE,   GV_ZREQ, GV_WERKS_M,
           GV_ZORQ, GV_ZFQ,  GV_ZMATSEQ,
           GT_170.
    REFRESH : GT_170.

    GV_ZMATSEQ = GT_160-ZMATSEQ.
    GV_WERKS_M = GT_160-WERKS_M.


    LOOP AT GT_140 WHERE ZMATSEQ = GV_ZMATSEQ.
      MOVE-CORRESPONDING GT_140 TO GT_170.

      PERFORM MODIFY_LIST USING    GT_170-STATUS
                          CHANGING GT_170-LIGHTS
                                   GT_170-STATUST.
      APPEND GT_170.      CLEAR GT_170.
    ENDLOOP.

    IF NOT GT_170[] IS INITIAL.
      GT_170_OLD[] = GT_170[].
    ENDIF.

  ENDIF.

ENDMODULE.                 " GET_DATA_GT_170  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_510 INPUT.
  OK_SAVE = OK_CODE.

  REFRESH: GT_BDC, MESSTAB.

  CASE OK_SAVE.
*__정상반품오더 생성
    WHEN 'RE_CR'.

      PERFORM CHECK_VKORG.
      CHECK GV_FORM_FLG <> 'X'.

      READ TABLE GT_160 WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        CLEAR: GV_ZMATSEQ, GV_MATNR, GV_KDAUF.
        GV_ZMATSEQ = GT_160-ZMATSEQ.
        GV_MATNR   = GT_160-MATNR.
        GV_KDAUF   = GT_160-KDAUF.

        IF GT_160-KDAUF NE SPACE.
          GV_CHK = '1'.

          PERFORM GET_DATA_180.

          CALL SCREEN 0520 STARTING AT 10 10 ENDING AT 90 30.
        ELSE.
          PERFORM BDC_VA01_RE_NEW.

          CHECK GV_ERROR_FLG NE 'X'.
          PERFORM UPDATE_0014S USING GV_RFUND.
          PERFORM REFRESH_GRID_170.
        ENDIF.

      ELSE.
        MESSAGE S001 WITH '자재를 선택하세요.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

*__불량품교환반품오더 생성
    WHEN 'ZREQ_CR'.

      PERFORM CHECK_VKORG.
      CHECK GV_FORM_FLG <> 'X'.

      READ TABLE GT_160 WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        CLEAR: GV_ZMATSEQ, GV_MATNR, GV_KDAUF.
        GV_ZMATSEQ = GT_160-ZMATSEQ.
        GV_MATNR   = GT_160-MATNR.
        GV_KDAUF   = GT_160-KDAUF.

        IF GT_160-KDAUF NE SPACE.
          PERFORM BDC_VA01_ZREQ.
        ELSE.
          PERFORM BDC_VA01_ZREQ_NEW.
        ENDIF.
        CHECK GV_ERROR_FLG NE 'X'.
        PERFORM UPDATE_0014S USING GV_RFUND.
        PERFORM REFRESH_GRID_170.

      ELSE.
        MESSAGE S001 WITH '자재를 선택하세요.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

*__불량품교환출고오더 생성
    WHEN 'ZORQ_CR'.
      IF GV_ZREQ = ''.
        MESSAGE S002 WITH '참조할 불량품교환'
                          '반품오더(ZREQ)가 없습니다.'
                          DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        PERFORM  BDC_VA01_ZORQ.
        CHECK GV_ERROR_FLG NE 'X'.
        PERFORM UPDATE_0014S USING GV_RFUND.
        PERFORM REFRESH_GRID_170.
      ENDIF.

*__클레임출고오더 생성
    WHEN 'ZFQ_CR'.

      PERFORM CHECK_VKORG.
      CHECK GV_FORM_FLG <> 'X'.

      READ TABLE GT_160 WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        CLEAR: GV_ZMATSEQ, GV_MATNR.
        GV_ZMATSEQ = GT_160-ZMATSEQ.
        GV_MATNR   = GT_160-MATNR.
        GV_KDAUF   = GT_160-KDAUF.

        IF GT_160-KDAUF NE SPACE.
          GV_CHK = '2'.

          PERFORM GET_DATA_180.

          CALL SCREEN 0520 STARTING AT 10 10 ENDING AT 90 30.

        ELSE.
          PERFORM BDC_VA01_ZFQ_NEW.

          CHECK GV_ERROR_FLG NE 'X'.
          PERFORM UPDATE_0014S USING GV_RFUND.
          PERFORM REFRESH_GRID_170.
        ENDIF.

      ELSE.
        MESSAGE S001 WITH '자재를 선택하세요.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

*__정상반품오더 변경
    WHEN 'RE_CH'.
      PERFORM CHANGE_VA02  USING GV_RE.
      PERFORM UPDATE_0014S USING GV_RE.
      PERFORM REFRESH_GRID_170.

*__불량품교환반품오더 변경
    WHEN 'ZREQ_CH'.
      PERFORM CHANGE_VA02  USING GV_ZREQ.
      PERFORM UPDATE_0014S USING GV_ZREQ.
      PERFORM REFRESH_GRID_170.

*__불량품교환출고오더 변경
    WHEN 'ZORQ_CH'.
      PERFORM CHANGE_VA02  USING GV_ZORQ.
      PERFORM UPDATE_0014S USING GV_ZORQ.
      PERFORM REFRESH_GRID_170.

*__클레임출고오더 변경
    WHEN 'ZFQ_CH'.
      PERFORM CHANGE_VA02  USING GV_ZFQ.
      PERFORM UPDATE_0014S USING GV_ZFQ.
      PERFORM REFRESH_GRID_170.

*__정상반품오더 처리요청
    WHEN 'RE_RQ_CR'.
*      IF NOT GV_RE IS INITIAL.
      PERFORM CHECK_EMAIL CHANGING GV_FLG.
      CHECK GV_FLG IS INITIAL.
      GV_CHK1 = '1'.
      PERFORM BUILD_MAIL_DATA CHANGING GV_FLG.
*      ELSE.
*        MESSAGE S001 WITH '처리요청할 데이타가 없습니다.'
*                          DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.

*__불량품교환반품오더 처리요청
    WHEN 'ZREQ_RQ_CR'.
*      IF NOT GV_ZREQ IS INITIAL.
      PERFORM CHECK_EMAIL CHANGING GV_FLG.
      CHECK GV_FLG IS INITIAL.
      GV_CHK1 = '2'.
      PERFORM BUILD_MAIL_DATA CHANGING GV_FLG.
*      ELSE.
*        MESSAGE S001 WITH '처리요청할 데이타가 없습니다.'
*                          DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.

*__불량품교환출고오더 처리요청
    WHEN 'ZORQ_RQ_CR'.
*      IF NOT GV_ZORQ IS INITIAL.
      PERFORM CHECK_EMAIL CHANGING GV_FLG.
      CHECK GV_FLG IS INITIAL.
      GV_CHK1 = '3'.
      PERFORM BUILD_MAIL_DATA CHANGING GV_FLG.
*      ELSE.
*        MESSAGE S001 WITH '처리요청할 데이타가 없습니다.'
*                          DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.

*__클레임출고오더 처리요청
    WHEN 'ZFQ_RQ_CR'.
*      IF NOT GV_ZFQ IS INITIAL.
      PERFORM CHECK_EMAIL CHANGING GV_FLG.
      CHECK GV_FLG IS INITIAL.
      GV_CHK1 = '4'.
      PERFORM BUILD_MAIL_DATA CHANGING GV_FLG.
*      ELSE.
*        MESSAGE S001 WITH '처리요청할 데이타가 없습니다.'
*                          DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_510  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0520 INPUT.


  OK_SAVE = OK_CODE.

  CASE OK_SAVE.

    WHEN 'ABBR'.
      LEAVE TO SCREEN 0.

    WHEN 'ENT1'.
      READ TABLE GT_180 WITH KEY MARK = 'X'.
      IF SY-SUBRC <> 0.
        MESSAGE S001 WITH '일괄생성할 데이타를 선택하세요.' DISPLAY LIKE
        'E'.
        EXIT.
      ELSE.
        IF GV_CHK = '1'.
          PERFORM BDC_VA01_RE.
        ELSEIF GV_CHK = '2'.
          PERFORM BDC_VA01_ZFQ.
        ENDIF.

        CHECK GV_ERROR_FLG NE 'X'.
        PERFORM UPDATE_0014S USING GV_RFUND.
        PERFORM REFRESH_GRID_170.

        LEAVE TO SCREEN 0.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0520  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_160_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_160_ITAB_DATA INPUT.

  READ TABLE GT_160 INTO GS_160_TC
                   INDEX TC_160-CURRENT_LINE.
  IF SY-SUBRC = 0.
    MODIFY GT_160 INDEX TC_160-CURRENT_LINE
              TRANSPORTING MARK.
  ENDIF.
  IF SY-SUBRC = 0 AND GT_160-MARK = 'X'.
    CLEAR : GV_MARK.

    GV_MARK = GT_160-MARK.

    CLEAR : GT_160-MARK.

    MODIFY GT_160 TRANSPORTING MARK
                  WHERE RCEPNO IS NOT INITIAL.

    GT_160-MARK = GV_MARK.

    MODIFY GT_160 INDEX TC_160-CURRENT_LINE
              TRANSPORTING MARK.
  ENDIF.

ENDMODULE.                 " MODIFY_160_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_190_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_190_ITAB_DATA INPUT.

  READ TABLE GT_190 INTO GS_190_TC
                   INDEX TC_190-CURRENT_LINE.
  IF SY-SUBRC = 0 AND GT_190-MARK = 'X'.
    CLEAR : GV_MARK.

    GV_MARK = GT_190-MARK.

    CLEAR : GT_190-MARK.

    MODIFY GT_190 TRANSPORTING MARK
                  WHERE RCEPNO IS NOT INITIAL.

    GT_190-MARK = GV_MARK.

    MODIFY GT_190 INDEX TC_190-CURRENT_LINE
              TRANSPORTING MARK.
  ENDIF.

ENDMODULE.                 " MODIFY_190_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATA_GT_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DATA_GT_200 INPUT.

  READ TABLE GT_190 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    CLEAR : GT_200,    GV_ZMATSEQ.
    REFRESH : GT_200[].
    GV_ZMATSEQ = GT_190-ZMATSEQ.

    LOOP AT GT_150 WHERE RCEPNO  = GT_190-RCEPNO
                     AND ZMATSEQ = GT_190-ZMATSEQ.
      MOVE-CORRESPONDING GT_150 TO GT_200.

      PERFORM MODIFY_LIST USING    GT_200-STATUS
                          CHANGING GT_200-LIGHTS
                                   GT_200-STATUST.
      APPEND GT_200.      CLEAR GT_200.
    ENDLOOP.
  ELSE.
    CLEAR : GT_200, GT_200[].
  ENDIF.

  IF NOT GT_200[] IS INITIAL.
    GT_200_OLD[] = GT_200[].
  ENDIF.

ENDMODULE.                 " GET_DATA_GT_200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_610  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_610 INPUT.

  OK_SAVE = OK_CODE.

  CASE OK_SAVE.

*__검사로트 생성
    WHEN 'PRUEFLOS_CR'.
      READ TABLE GT_190 WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        MOVE-CORRESPONDING GT_190 TO GS_LOT.
        GS_LOT-KUNUM = GS_100-KUNUM.
        GS_LOT-QMTXT = GS_100-QMTXT.

        PERFORM  BDC_LOT_CREATE USING  GS_LOT.
        PERFORM  REFRESH_GRID_200.
      ELSE.
        MESSAGE S001 WITH '자재 SEQ를 선택하세요.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

*__검사로트 변경
    WHEN 'PRUEFLOS_CH'.
      SET    PARAMETER ID 'QLS'   FIELD  GV_PRUEFLOS.
      CALL   TRANSACTION  'QA02'  AND SKIP FIRST SCREEN.

      PERFORM UPDATE_QA USING GV_PRUEFLOS.
      PERFORM  REFRESH_GRID_200.


*__검사로트 결과
    WHEN 'PRUEFLOS_IN_CH'.
      SET    PARAMETER ID 'QLS'   FIELD  GV_PRUEFLOS.
      SET    PARAMETER ID 'WRK'   FIELD  GS_100-WERKS_H.
      CALL   TRANSACTION  'QE01'  AND SKIP FIRST SCREEN.

      PERFORM UPDATE_QA USING GV_PRUEFLOS.
      PERFORM  REFRESH_GRID_200.

*__사용결정
    WHEN 'PRUEFLOS_UD_CH'.
      SET    PARAMETER ID 'QLS'   FIELD  GV_PRUEFLOS.
      CALL   TRANSACTION  'QA11'  AND SKIP FIRST SCREEN.

      PERFORM UPDATE_QA USING GV_PRUEFLOS.
      PERFORM  REFRESH_GRID_200.

* 재고 전기 버튼
    WHEN  'PRUEFLOS_MB1B' .
*      CALL   TRANSACTION  'MB1B'  AND SKIP FIRST SCREEN.
      CALL   TRANSACTION  'MIGO'  AND SKIP FIRST SCREEN.

    WHEN '/CS'. "더블클
      PERFORM  REFER_OBJECT_ITEMS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_610  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION7  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION7 INPUT.

  CHECK GS_100-QMNUM <> ''.

  SET PARAMETER ID 'IQM' FIELD GS_100-QMNUM.

  CALL TRANSACTION 'QM03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION7  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_1110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_1110 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES3_N
                        USING  G_CL_TEXT3
                               G_OLIN3
                               G_NLIN3.

ENDMODULE.                 " GET_LONG_TEXT_1110  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_1120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_1120 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES4_N
                        USING  G_CL_TEXT4
                               G_OLIN4
                               G_NLIN4.

ENDMODULE.                 " GET_LONG_TEXT_1120  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_1140  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_1140 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES5_N
                        USING  G_CL_TEXT5
                               G_OLIN5
                               G_NLIN5.

ENDMODULE.                 " GET_LONG_TEXT_1140  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1130 INPUT.
  OK_SAVE = OK_CODE.

  CASE OK_SAVE.
    WHEN 'ADD_1130'.
      PERFORM GET_TC_ADD_1130.

    WHEN 'DELETE_1130'.
      PERFORM GET_TC_DELETE_1130.

    WHEN 'DEL_CANC_1130'.
      PERFORM GET_TC_DEL_CANC_1130.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1130  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_240_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_240_ITAB_DATA INPUT.

  READ TABLE GT_240_TC INTO GS_240_TC
                   INDEX TC_1130-CURRENT_LINE.
  IF SY-SUBRC = 0.
    MODIFY GT_240_TC INDEX TC_1130-CURRENT_LINE
              TRANSPORTING MARK.
  ENDIF.

ENDMODULE.                 " MODIFY_240_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LONG_TEXT_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LONG_TEXT_1210 INPUT.

  PERFORM GET_LONG_TEXT TABLES G_LINES6_N
                        USING  G_CL_TEXT6
                               G_OLIN6
                               G_NLIN6.

ENDMODULE.                 " GET_LONG_TEXT_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1210 INPUT.

  OK_SAVE = OK_CODE.

  CASE OK_SAVE.

    WHEN 'WF_CLOSE'.
      CLEAR GV_MAIL.

      PERFORM CHECK_EMAIL1 CHANGING GV_FLG.

      CHECK GV_FLG IS INITIAL.

      PERFORM CHECK_DATA1 CHANGING GV_FLG.

      CHECK GV_FLG IS INITIAL.

      IF GV_MAIL = ' '.
        $$POPUP_TO_CONFIRM_STEP '고객불만 종료승인을 요청하시겠습니까?'
                                ' ' '종료승인요청'.
        CHECK GV_ANSWER = 'J'.

        GS_100-STATUS = 'CL40'.

        PERFORM SAVE_COMPLAIN_DATA USING 'X'.
        PERFORM GET_COMPLAIN_DATA.

        PERFORM BUILD_MAIL_DATA1 CHANGING GV_FLG.

      ENDIF.

    WHEN 'CHK'.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_RESPT_SCREEN_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_RESPT_SCREEN_1210 INPUT.

  IF  NOT  GS_100-RESPT  IS INITIAL.
    PERFORM  RESPT_READ  USING    'AB'  GS_100-RESPT
                         CHANGING  GS_100-RESPTT.
  ELSE.
    CLEAR: GS_100-RESPTT.
  ENDIF.

ENDMODULE.                 " READ_RESPT_SCREEN_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_CONET2_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_CONET2_1210 INPUT.
  PERFORM F4_CONET_S1210.
ENDMODULE.                 " F4_CONET2_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_RESPT_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_RESPT_1210 INPUT.
  PERFORM F4_RESPT_1210.
ENDMODULE.                 " F4_RESPT_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_220 INPUT.
  OK_SAVE = OK_CODE.

  CASE OK_SAVE.

    WHEN 'RB'.
      CASE  'X'.
        WHEN  GV_RCLAS1.
          GS_100-RCLAS   =  '1'.
        WHEN  GV_RCLAS2.
          GS_100-RCLAS   =  '2'.
        WHEN  GV_RCLAS3.
          GS_100-RCLAS   =  '3'.
        WHEN  GV_RCLAS4.
          GS_100-RCLAS   =  '4'.
        WHEN  GV_RCLAS5.
          GS_100-RCLAS   =  '5'.
        WHEN  GV_RCLAS6.
          GS_100-RCLAS   =  '6'.
        WHEN  GV_RCLAS7.
          GS_100-RCLAS   =  '7'.
      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_220  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  CLEAR : GV_CURSOR1, GV_CURLIN1.

  IF GV_CURFLG IS INITIAL.
    GV_CURFLG = 'X'.

    CLEAR : GV_CURSOR, GV_CURLIN.
  ENDIF.

  GET CURSOR FIELD GV_CURSOR1 LINE GV_CURLIN1.

  IF GV_CURSOR1 IS NOT INITIAL.
    GV_CURSOR = GV_CURSOR1.

    CLEAR : GV_CURLIN.
  ENDIF.

  IF GV_CURLIN1 IS NOT INITIAL.
    GV_CURLIN = GV_CURLIN1.
  ENDIF.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION8  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION8 INPUT.
  CHECK GS_101-KDAUF <> ''.

  SET PARAMETER ID 'AUN' FIELD GS_101-KDAUF.

  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION8  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_CPERNR_SCREEN_930  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_CPERNR_SCREEN_930 INPUT.

  IF ZQMS301-CPERNR IS NOT INITIAL.
    PERFORM GET_USRID1 USING ZQMS301-CPERNR
                       CHANGING ZQMS301-CPERNRT.

  ENDIF.

ENDMODULE.                 " READ_CPERNR_SCREEN_930  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FTGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FTGRP INPUT.
  DATA : LW_TABIX LIKE SY-TABIX,
         LW_BUKRS TYPE BUKRS.

  CLEAR : GW_TABIX,   SELECTFIELD,
          LW_TABIX,   SELECT_VALUE,
          GT_ZFTGRP,  GT_ZFTGRP[],
          GT_FIELDS,  GT_FIELDS[],
          SCR_FIELDS, SCR_FIELDS[],
          GT_HEADER,  GT_HEADER[],
          LW_BUKRS.

  READ TABLE GT_230 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    PERFORM GET_BUKRS USING    GT_230-WERKS_M
                      CHANGING LW_BUKRS.
  ENDIF.

  GET CURSOR LINE LW_TABIX.

  SELECT A~CODEGRUPPE
         B~KURZTEXT
    FROM ZQMT0013C AS A
   INNER JOIN QPGT AS B
      ON A~KATALOGART = B~KATALOGART
     AND A~CODEGRUPPE = B~CODEGRUPPE
    INTO CORRESPONDING FIELDS OF TABLE GT_ZFTGRP
        WHERE A~BUKRS      = LW_BUKRS
          AND A~KATALOGART = '5'
          AND B~SPRACHE    = SY-LANGU.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'CODEGRUPPE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'CODEGRUPPE'.
  GT_HEADER-HEAD_TEXT = '원인그룹'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '원인그룹내역'.
  APPEND GT_HEADER.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_ZFTGRP
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_ZFTGRP INDEX GW_TABIX.

  SCR_FIELDS-FIELDNAME = 'GT_240_TC-FTGRP'.
  SCR_FIELDS-STEPL      = LW_TABIX.
  SCR_FIELDS-FIELDVALUE = GT_ZFTGRP-CODEGRUPPE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.


ENDMODULE.                 " F4HELP_FTGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FLTTP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FLTTP INPUT.

  DATA : LV_TABIX LIKE SY-TABIX.

  CLEAR : GW_TABIX,   SELECTFIELD,
          LV_TABIX,   SELECT_VALUE,
          GT_FLTTP,   GT_FLTTP[],
          GT_FIELDS,  GT_FIELDS[],
          SCR_FIELDS, SCR_FIELDS[],
          GT_HEADER,  GT_HEADER[].

  GET CURSOR LINE LV_TABIX.


  SCR_FIELDS-FIELDNAME = 'GT_240_TC-FTGRP'.
  SCR_FIELDS-STEPL     = LW_TABIX.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = SCR_FIELDS
    EXCEPTIONS
      OTHERS             = 1.

  READ TABLE SCR_FIELDS INDEX 1.
  IF SY-SUBRC = 0.
    GT_240_TC-FTGRP = SCR_FIELDS-FIELDVALUE.
  ENDIF.

  IF GT_240_TC-FTGRP IS INITIAL.
    MESSAGE S001 WITH '코드그룹을 선택하세요.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT CODE
         KURZTEXT
         FROM QPCT
         INTO CORRESPONDING FIELDS OF TABLE GT_FLTTP
        WHERE KATALOGART = '5'
          AND CODEGRUPPE = GT_240_TC-FTGRP
          AND SPRACHE    = SY-LANGU.


  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'CODE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'CODE'.
  GT_HEADER-HEAD_TEXT = '원인코드'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '원인코드내역'.
  APPEND GT_HEADER.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_FLTTP
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_FLTTP INDEX GW_TABIX.

  CLEAR   : SCR_FIELDS.
  REFRESH : SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GT_240_TC-FLTTP'.
  SCR_FIELDS-FIELDVALUE = GT_FLTTP-CODE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GT_240_TC-FLTTPT'.
  SCR_FIELDS-FIELDVALUE = GT_FLTTP-KURZTEXT.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDMODULE.                 " F4HELP_FLTTP  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_240_TC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_240_TC INPUT.

  CHECK NOT GT_240_TC IS INITIAL.

  MODIFY GT_240_TC INDEX TC_1130-CURRENT_LINE
                   TRANSPORTING FTGRP FLTTP FLTTPT TEXT.

  MODIFY GT_240 FROM GT_240_TC TRANSPORTING FTGRP FLTTP FLTTPT TEXT
               WHERE RCEPNO  = GV_RCEPNO
                 AND ZMATSEQ = GT_240_TC-ZMATSEQ
                 AND ZBADSEQ = GT_240_TC-ZBADSEQ
                 AND ZCAUSEQ = GT_240_TC-ZCAUSEQ.

ENDMODULE.                 " MODIFY_240_TC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FLTTP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FLTTP INPUT.

  IF GT_240_TC-FTGRP IS NOT INITIAL AND
     GT_240_TC-FLTTP IS NOT INITIAL.
    PERFORM CHECK_FLTTP USING GT_240_TC-FTGRP
                              GT_240_TC-FLTTP
                              GT_240_TC-FLTTPT.
  ELSE.
    MESSAGE E001 WITH '원인그룹/코드를 입력하십시오.'.
  ENDIF.

ENDMODULE.                 " CHECK_FLTTP  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FTGRP_N  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FTGRP_N INPUT.
  DATA : L_TABIX LIKE SY-TABIX.

  CLEAR : GW_TABIX,     SELECTFIELD,
          L_TABIX,      SELECT_VALUE,
          GT_ZFTGRP_N,  GT_ZFTGRP_N[],
          GT_FIELDS,    GT_FIELDS[],
          SCR_FIELDS,   SCR_FIELDS[],
          GT_HEADER,    GT_HEADER[],
          L_BUKRS.

  PERFORM GET_BUKRS USING    GS_101-WERKS_M
                    CHANGING L_BUKRS.

  GET CURSOR LINE L_TABIX.

  SELECT A~CODEGRUPPE
         B~KURZTEXT
    FROM ZQMT0013C AS A
   INNER JOIN QPGT AS B
      ON A~KATALOGART = B~KATALOGART
     AND A~CODEGRUPPE = B~CODEGRUPPE
    INTO CORRESPONDING FIELDS OF TABLE GT_ZFTGRP_N
        WHERE A~BUKRS      = L_BUKRS
          AND A~KATALOGART = '9'
          AND B~SPRACHE    = SY-LANGU.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'CODEGRUPPE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'CODEGRUPPE'.
  GT_HEADER-HEAD_TEXT = '불량코드그룹'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '불량코드그룹내역'.
  APPEND GT_HEADER.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_ZFTGRP_N
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_ZFTGRP_N INDEX GW_TABIX.

  SCR_FIELDS-FIELDNAME = 'GS_316-FTGRP'.
  SCR_FIELDS-STEPL      = L_TABIX.
  SCR_FIELDS-FIELDVALUE = GT_ZFTGRP_N-CODEGRUPPE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.


ENDMODULE.                 " F4HELP_FTGRP_N  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FLTTP_N  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FLTTP_N INPUT.

  CLEAR : GW_TABIX,    SELECTFIELD,
          LW_TABIX,     SELECT_VALUE,
          GT_FLTTP_N,  GT_FLTTP_N[],
          GT_FIELDS,   GT_FIELDS[],
          SCR_FIELDS,  SCR_FIELDS[],
          GT_HEADER,   GT_HEADER[].

  GET CURSOR LINE LW_TABIX.


  SCR_FIELDS-FIELDNAME = 'GS_316-FTGRP'.
  SCR_FIELDS-STEPL     = L_TABIX.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = SCR_FIELDS
    EXCEPTIONS
      OTHERS             = 1.

  READ TABLE SCR_FIELDS INDEX 1.
  IF SY-SUBRC = 0.
    GS_316-FTGRP = SCR_FIELDS-FIELDVALUE.
  ENDIF.

  IF GS_316-FTGRP IS INITIAL.
    MESSAGE S001 WITH '코드그룹을 선택하세요.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT CODE
         KURZTEXT
         FROM QPCT
         INTO CORRESPONDING FIELDS OF TABLE GT_FLTTP_N
        WHERE KATALOGART = '9'
          AND CODEGRUPPE = GS_316-FTGRP
          AND SPRACHE    = SY-LANGU.


  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'CODE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'CODE'.
  GT_HEADER-HEAD_TEXT = '불량코드'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '불량코드내역'.
  APPEND GT_HEADER.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_FLTTP_N
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_FLTTP_N INDEX GW_TABIX.

  CLEAR   : SCR_FIELDS.
  REFRESH : SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GS_316-FLTTP'.
  SCR_FIELDS-FIELDVALUE = GT_FLTTP_N-CODE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GS_316-FTTXT'.
  SCR_FIELDS-FIELDVALUE = GT_FLTTP_N-KURZTEXT.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDMODULE.                 " F4HELP_FLTTP_N  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_OTGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_OTGRP INPUT.
  DATA : L_INDEX LIKE SY-TABIX.",
*         L_BUKRS TYPE BUKRS.

  CLEAR : GW_TABIX,     SELECTFIELD,
          L_INDEX,      SELECT_VALUE,
          GT_OTRGRP,    GT_OTRGRP[],
          GT_FIELDS,    GT_FIELDS[],
          SCR_FIELDS,   SCR_FIELDS[],
          GT_HEADER,    GT_HEADER[],
          L_BUKRS.

  PERFORM GET_BUKRS USING    GS_101-WERKS_M
                    CHANGING L_BUKRS.

  GET CURSOR LINE L_INDEX.

  SELECT A~CODEGRUPPE
         B~KURZTEXT
    FROM ZQMT0013C AS A
   INNER JOIN QPGT AS B
      ON A~KATALOGART = B~KATALOGART
     AND A~CODEGRUPPE = B~CODEGRUPPE
    INTO CORRESPONDING FIELDS OF TABLE GT_OTRGRP
        WHERE A~BUKRS      = L_BUKRS
          AND A~KATALOGART = 'E'
          AND B~SPRACHE    = SY-LANGU.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'CODEGRUPPE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPGT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'CODEGRUPPE'.
  GT_HEADER-HEAD_TEXT = '위치코드그룹'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPGT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '위치코드그룹내역'.
  APPEND GT_HEADER.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_OTRGRP
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_OTRGRP INDEX GW_TABIX.

  SCR_FIELDS-FIELDNAME = 'GS_316-OTRGRP'.
  SCR_FIELDS-STEPL      = L_INDEX.
  SCR_FIELDS-FIELDVALUE = GT_OTRGRP-CODEGRUPPE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.
ENDMODULE.                 " F4HELP_OTGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_OTEIL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_OTEIL INPUT.

  CLEAR : GW_TABIX,    SELECTFIELD,
          LW_TABIX,    SELECT_VALUE,
          GT_OTEIL,    GT_OTEIL[],
          GT_FIELDS,   GT_FIELDS[],
          SCR_FIELDS,  SCR_FIELDS[],
          GT_HEADER,   GT_HEADER[].

  GET CURSOR LINE LW_TABIX.


  SCR_FIELDS-FIELDNAME = 'GS_316-OTRGRP'.
  SCR_FIELDS-STEPL     = L_INDEX.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME             = SY-REPID
      DYNUMB             = SY-DYNNR
      TRANSLATE_TO_UPPER = 'X'
    TABLES
      DYNPFIELDS         = SCR_FIELDS
    EXCEPTIONS
      OTHERS             = 1.

  READ TABLE SCR_FIELDS INDEX 1.
  IF SY-SUBRC = 0.
    GS_316-OTRGRP = SCR_FIELDS-FIELDVALUE.
  ENDIF.

  IF GS_316-OTRGRP IS INITIAL.
    MESSAGE S001 WITH '코드그룹을 선택하세요.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT CODE
         KURZTEXT
         FROM QPCT
         INTO CORRESPONDING FIELDS OF TABLE GT_OTEIL
        WHERE KATALOGART = 'E'
          AND CODEGRUPPE = GS_316-OTRGRP
          AND SPRACHE    = SY-LANGU.


  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'CODE' .
  GT_FIELDS-SELECTFLAG = 'X' .
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'QPCT' .
  GT_FIELDS-FIELDNAME  = 'KURZTEXT' .
  GT_FIELDS-SELECTFLAG = '' .
  APPEND GT_FIELDS.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'CODE'.
  GT_HEADER-HEAD_TEXT = '위치코드'.
  APPEND GT_HEADER.

  GT_HEADER-TABNAME   = 'QPCT'.
  GT_HEADER-FIELDNAME = 'KURZTEXT'.
  GT_HEADER-HEAD_TEXT = '위치코드내역'.
  APPEND GT_HEADER.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GW_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_OTEIL
      HEADING_TABLE                = GT_HEADER
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK GW_TABIX IS NOT INITIAL.
  READ TABLE GT_OTEIL INDEX GW_TABIX.

  CLEAR   : SCR_FIELDS.
  REFRESH : SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GS_316-OTEIL'.
  SCR_FIELDS-FIELDVALUE = GT_OTEIL-CODE.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.

  SCR_FIELDS-FIELDNAME  = 'GS_316-OTTXT'.
  SCR_FIELDS-FIELDVALUE = GT_OTEIL-KURZTEXT.
  APPEND SCR_FIELDS.
  CLEAR SCR_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDMODULE.                 " F4HELP_OTEIL  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATA_S_810  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DATA_S_810 INPUT.

*  IF GT_210-MARK = 'X'.
  READ TABLE GT_210 INTO GS_210_TC WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    S_810-RFAMT  = GS_210_TC-RFAMT.
    S_810-RTAMT  = GS_210_TC-RTAMT.
    S_810-RTAMT2 = GS_210_TC-RTAMT2.
    S_810-GBAMT  = GS_210_TC-GBAMT.
    S_810-CLAMT  = GS_210_TC-CLAMT.
    S_810-IPCST  = GS_210_TC-IPCST.
    S_810-MVCST  = GS_210_TC-MVCST.
  ELSE.
    CLEAR : S_810-RFAMT,  S_810-RTAMT,  S_810-RTAMT2,
            S_810-GBAMT,  S_810-CLAMT,  S_810-IPCST,
            S_810-MVCST.
  ENDIF.
*  ENDIF.

ENDMODULE.                 " GET_DATA_S_810  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_SPGCD_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_SPGCD_SCREEN_100 INPUT.

*__제품군 내역
  PERFORM GET_SPGCD_DESC  USING    GS_100-SPGCD
                          CHANGING GS_100-SPGCDT.

ENDMODULE.                 " READ_SPGCD_SCREEN_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZPRIORITY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZPRIORITY INPUT.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.
  DATA : BEGIN OF LT_DOMN OCCURS 0,          "도메인을 받는 테이블
           DOMVALUE_L LIKE DD07V-DOMVALUE_L,
           DDTEXT     LIKE DD07V-DDTEXT,
         END OF LT_DOMN.

  IMPORT GD_BUKRS FROM MEMORY ID 'BUKRS_ID_GO'.
*& 엠트론인 경우 ZPRIORITY_2 도메인 기준으로 중요도 값을 불러옴
*(C20120830_74181)
*  IF GV_BUKRS = '3000' OR GS_100-BUKRS = '3000' OR
*     GD_BUKRS = '3000' OR GS_100-WERKS_H(1) = '3'.

*->[가온전선]--------------------CHG S
*  IF  GD_BUKRS = '3000'.
*
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE LT_DOMN
*      FROM DD07V
*     WHERE DOMNAME = 'ZPRIORITY_2'.
*
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        RETFIELD        = 'DOMVALUE_L'
*        VALUE_ORG       = 'S'
*      TABLES
*        VALUE_TAB       = LT_DOMN
*        RETURN_TAB      = LT_RETURN
*      EXCEPTIONS
*        PARAMETER_ERROR = 1
*        NO_VALUES_FOUND = 2
*        OTHERS          = 3.
*
*    IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*    READ TABLE LT_RETURN INDEX 1.
*    IF SY-SUBRC EQ 0.
*      GS_100-PRIORITY = LT_RETURN-FIELDVAL.
*    ENDIF.
*
*  ELSE.
*-<[가온전선]--------------------CHG E

    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE LT_DOMN
        FROM DD07V
       WHERE DOMNAME = 'ZPRIORITY'.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'DOMVALUE_L'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_DOMN
        RETURN_TAB      = LT_RETURN
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.

    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      GS_100-PRIORITY = LT_RETURN-FIELDVAL.
    ENDIF.

*  ENDIF.

ENDMODULE.                 " F4_ZPRIORITY  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_WERKS_H  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_WERKS_H INPUT.
  CLEAR LT_RETURN[].

  SELECT B~WERKS,B~NAME1
    FROM T001K AS A INNER JOIN T001W AS B
                    ON A~BWKEY = B~BWKEY
   WHERE A~BUKRS EQ @G_BUKRS
    INTO TABLE @DATA(LT_VALUE).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      GS_100-WERKS_H = LT_RETURN-FIELDVAL.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_VKBUR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_VKBUR INPUT.
  PERFORM F4_VKBUR CHANGING GS_100-VKBUR.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_VKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_VKGRP INPUT.
  PERFORM F4_VKGRP CHANGING GS_100-VKGRP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_SPART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_SPART INPUT.
  PERFORM F4_SPART CHANGING GS_100-SPGCD.
ENDMODULE.
