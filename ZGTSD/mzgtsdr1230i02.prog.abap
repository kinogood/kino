*&---------------------------------------------------------------------*
*&  Include           MZGTSDR1230I02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0311  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0311 INPUT.


  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.


  CASE OK_SAVE.
*   저장
    WHEN 'OKAY'.
      CASE SY-DYNNR.
        WHEN '0311' OR '0315' OR '0322'.
          PERFORM CHECK_INPUT_DATA_0311.
          PERFORM ADD_TABLECONTROL_0310.
          PERFORM EXE_CACL.
        WHEN '0316'.
          PERFORM CHECK_INPUT_DATA_0316.
          PERFORM ADD_TABLECONTROL_0316.
          PERFORM EXE_CACL.
      ENDCASE.
*   입력값 삭제
    WHEN 'CLS'.
      CASE SY-DYNNR.
        WHEN '0311'.
          CLEAR: GS_311, GS_101-MATNR, GS_101-MAKTX,
                 GS_101-WERKS_M, GS_101-WERKST.
        WHEN '0315'.
          CLEAR: GS_311.
        WHEN '0316'.
          CLEAR: GS_316.
      ENDCASE.
**   불량코드검색
*    WHEN 'FLS'.
*      PERFORM GET_CODE_SEARCH USING 'FLS'
*                              CHANGING GS_316-FTGRP
*                                       GS_316-FLTTP
*                                       GS_316-FTTXT
*                                       GS_316-FTKAT
*                                       GS_316-FLVER.
**   위치코드검색
*    WHEN 'OTS'.
*      PERFORM GET_CODE_SEARCH USING 'OTS'
*                              CHANGING GS_316-OTRGRP
*                                       GS_316-OTEIL
*                                       GS_316-OTTXT
*                                       GS_316-OTKAT
*                                       GS_316-OTVER.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0311  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRC_MATNR  INPUT
*&---------------------------------------------------------------------*
*       자재코드 입력시 처리
*----------------------------------------------------------------------*
MODULE PRC_MATNR INPUT.
*  CLEAR : GV_FORM_FLG.
*
** 유효성 체크
*  IF NOT GS_101-MATNR IS INITIAL.
*    SELECT SINGLE *
*      FROM MARC
*     WHERE WERKS = GS_101-WERKS_M
*       AND MATNR = GS_101-MATNR.
*    IF SY-SUBRC <> 0.
*MESSAGE S001 WITH '해당 자재플랜트에 유효한 자재가 아닙니다.' DISPLAY
*LIKE 'E'.
*      GV_FORM_FLG = 'X'.
*      EXIT.
*    ENDIF.
*  ENDIF.

* 자재내역을 읽어온다.
  PERFORM GET_MATNR_DESC USING  GS_101-MATNR
                                GS_101-MAKTX.  "자재내역
  IF GS_101-MAKTX IS INITIAL.
    MESSAGE E000 WITH '해당 자재코드가 존재하지 않습니다.'.
  ENDIF.

* 단위 및 제품군을 읽어온다.
  PERFORM GET_SPART USING    GS_101-MATNR
                    CHANGING GS_311-SPGCD      "제품군
                             GS_311-MGEIN.     "단위

* 제품군 내역을 읽어온다.
  PERFORM GET_SPGCD_DESC USING    GS_311-SPGCD
                         CHANGING GS_311-SPGCDT.

ENDMODULE.                 " PRC_MATNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SD_BELEG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SD_BELEG INPUT.

  IF  NOT GS_311-KDAUF IS INITIAL  AND
      NOT GS_311-VBELN IS INITIAL.

    PERFORM LIEFERUNG_LESEN USING GS_311-VBELN
                                  GS_311-POSNR
                         CHANGING VBDKL
                                  VBDPL.

    IF GS_311-KDAUF NE VBDPL-VBELN_VAUF.
      MESSAGE E020(QM).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_SD_BELEG  INPUT
*&---------------------------------------------------------------------*
*&      Module  KDAUF_KDPOS_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE KDAUF_KDPOS_CHECK INPUT.


  IF GS_311-KDAUF IS INITIAL AND
     NOT GS_311-KDPOS IS INITIAL.
    MESSAGE E013(QM).
  ENDIF.

ENDMODULE.                 " KDAUF_KDPOS_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  KDAUF_LESEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE KDAUF_LESEN INPUT.

  RQM01-LS_KDAUF = GS_311-KDAUF.
  RQM01-LS_KDPOS = GS_311-KDPOS.

  PERFORM GET_VBELN.              "납품오더리스트
  PERFORM GET_PO.                 "PO번호 리스트
  PERFORM GET_TAGNR.              "꼬리표 번호리스트
  PERFORM GET_MCNO.               "기계번호

ENDMODULE.                 " KDAUF_LESEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0312  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0312 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR: OK_CODE.

  CASE OK_SAVE.
    WHEN 'CACL'.
      PERFORM EXE_CACL.
      LEAVE TO SCREEN 0.

    WHEN 'OKAY'.
      PERFORM GET_GS_DISPLAY.
      GS_311-KDAUF = GT_VBELN-VGBEL.  "판매오더
      GS_311-VBELN = GT_VBELN-VBELN.  "납품오더
      GS_311-POSNR = GT_VBELN-POSNR.  "납품오더품목
      GS_311-CHARG = GT_VBELN-CHARG.  "배치번호
      GS_311-GELIM = GT_VBELN-LFIMG.  "납품수량
      GS_311-MGEIN = GT_VBELN-MEINS.  "단위
      GS_101-MATNR = GT_VBELN-MATNR.  "자재번호
      GS_311-KDPOS = GT_VBELN-VGPOS.  "판매오더품목
      PERFORM GET_MATNR_DESC USING GS_101-MATNR
                                   GS_101-MAKTX.

      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C312
                                   G_GRID_312.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      "nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0312  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0313  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0313 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR: OK_CODE.

  CASE OK_SAVE.
    WHEN 'CACL'.
      LEAVE TO SCREEN 0.

    WHEN 'OKAY'.
      PERFORM GET_CHOSE_TANGR.
      GS_311-TAGNR  = GT_TAGNR-TAGNR.
      GS_311-DRUM   = GT_TAGNR-DRUM.
      GS_311-SERIAL = GT_TAGNR-SERIAL.
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C313
                                   G_GRID_313.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      "nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0313  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MCNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MCNO INPUT.

  CHECK GS_311-KDAUF IS INITIAL.
  SELECT SINGLE KDAUF KDPOS
           FROM EQBS
           INTO (GS_311-KDAUF, GS_311-KDPOS)
          WHERE EQUNR EQ GS_311-MCNO.

* 납품오더리스트
  IF GS_311-VBELN IS INITIAL.
    PERFORM GET_VBELN.
  ENDIF.

* PO번호 리스트
  IF GS_311-FERTAUFNR IS INITIAL.
    PERFORM GET_PO.
  ENDIF.

* 꼬리표 번호리스트
  IF GS_311-TAGNR IS INITIAL.
    PERFORM GET_TAGNR.
  ENDIF.

ENDMODULE.                 " CHECK_MCNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  VBELN_POSNR_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBELN_POSNR_CHECK INPUT.

  IF RQM01-LS_VBELN IS INITIAL AND
      NOT RQM01-LS_POSNR IS INITIAL.
    MESSAGE E021(QM).
  ENDIF.

ENDMODULE.                 " VBELN_POSNR_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  LIEFERUNG_LESEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LIEFERUNG_LESEN INPUT.

  IF  NOT RQM01-LS_VBELN IS INITIAL.
    PERFORM LIEFERUNG_LESEN USING RQM01-LS_VBELN
                                  RQM01-LS_POSNR
                         CHANGING VBDKL
                                  VBDPL.

    PERFORM LIEFERUNG_TO_QMEL USING VBDKL
                                    VBDPL
                           CHANGING RQM01.

  ELSE.
    CLEAR: RQM01-KUNUM,
           RQM01-BSTNK,
           RQM01-BSTDK,
           RQM01-VKORG,
           RQM01-VTWEG,
           RQM01-SPART,
           RQM01-VKBUR,
           RQM01-KDMAT,
           RQM01-MATNR,
           RQM01-MAWERK,
           RQM01-CHARG,
           RQM01-LICHN,
           RQM01-LGORTCHAR,
           RQM01-LGORTVORG,
           RQM01-RKMNG,
           RQM01-BZMNG,
           RQM01-RKMNG,
           RQM01-BZMNG,
           RQM01-MGEIN.
  ENDIF.

ENDMODULE.                 " LIEFERUNG_LESEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  VBELN_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBELN_GET INPUT.

* local variable
  DATA: LV_CNT TYPE I.

  CASE SY-DYNNR.
*   불만제품 등록일 경우
    WHEN '0311'.
      SELECT SINGLE VBELN
               FROM VBKD
               INTO GT_PO-VBELN
              WHERE BSTKD EQ GS_311-FERTAUFNR
                AND BSTDK EQ GS_311-BSTDK.

      SELECT * FROM LIPS
               INTO CORRESPONDING FIELDS OF TABLE GT_PO
              WHERE VGBEL EQ GT_PO-VBELN.

      DESCRIBE TABLE GT_PO LINES LV_CNT.
      IF LV_CNT > 1.
        CALL SCREEN '0314' STARTING AT 10 8
                           ENDING AT 100 20.
      ELSE.
        READ TABLE GT_PO INDEX 1.
        GS_311-KDAUF = GT_PO-VGBEL.
        GS_311-KDPOS = GT_PO-VGPOS.
        GS_311-VBELN = GT_PO-VBELN.
        GS_311-POSNR = GT_PO-POSNR.
      ENDIF.

*   배치 등록일경우 (오더번호가 고정되어 있음)
    WHEN '0315'.
      SELECT * FROM LIPS
               INTO CORRESPONDING FIELDS OF TABLE GT_PO
              WHERE VGBEL EQ GS_311-KDAUF.  "오더번호

      DESCRIBE TABLE GT_PO LINES LV_CNT.
      IF LV_CNT > 1.
        CALL SCREEN '0314' STARTING AT 10 8
                           ENDING AT 100 20.
      ELSE.
        READ TABLE GT_PO INDEX 1.
        GS_311-KDPOS = GT_PO-VGPOS.
        GS_311-VBELN = GT_PO-VBELN.
        GS_311-POSNR = GT_PO-POSNR.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " VBELN_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0314  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0314 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR: OK_CODE.

  CASE OK_SAVE.
    WHEN 'CACL'.
      LEAVE TO SCREEN 0.

    WHEN 'OKAY'.
      PERFORM GET_CHOSE_PO.
      GS_311-KDAUF = GT_PO-VGBEL.
      GS_311-KDPOS = GT_PO-VGPOS.
      GS_311-VBELN = GT_PO-VBELN.
      GS_311-POSNR = GT_PO-POSNR.
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C314
                                   G_GRID_314.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      "nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0314  INPUT
*&---------------------------------------------------------------------*
*&      Module  TAGNR_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAGNR_GET INPUT.

* local variable
  DATA: LV_DPCBT LIKE MARA-DPCBT.

* check
  SELECT SINGLE DPCBT
           INTO LV_DPCBT
           FROM MARA
          WHERE MATNR EQ GS_101-MATNR
            AND SPART EQ GS_311-SPGCD.
  IF LV_DPCBT EQ 'A'.
    MESSAGE S001 WITH '팩터배치는 조회가 불가능합니다.'.
  ENDIF.

  RQM01-LS_KDAUF = GS_311-KDAUF.
  RQM01-LS_KDPOS = GS_311-KDPOS.

  PERFORM GET_CHARG.                  "배치번호
  CHECK GS_311-CHARG IS NOT INITIAL.

  PERFORM GET_DMNO.                   "드럼번호
  PERFORM GET_VBELN_CHARG.            "납품오더리스트
  PERFORM GET_KDAUF_CHARG.            "판매오더리스트
  PERFORM GET_PO.                     "PO번호 리스트
  PERFORM GET_MCNO.                   "기계번호

ENDMODULE.                 " TAGNR_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHARG_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHARG_GET INPUT.

  PERFORM GET_TAGNR_FOR_CHARG.        "꼬리표 번호리스트
  PERFORM GET_DMNO.                   "드럼번호
  PERFORM GET_VBELN_CHARG.            "납품오더리스트
  PERFORM GET_KDAUF_CHARG.            "판매오더리스트
  PERFORM GET_PO.                     "PO번호 리스트
  PERFORM GET_MCNO.                   "기계번호

ENDMODULE.                 " CHARG_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TBON_HEDER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TBON_HEDER INPUT.

* local variable
  DATA: LS_TMP LIKE GT_100.

* 라디오버튼 선택여부 확인
  CHECK GT_100-MARK EQ 'X'.
  PERFORM OFF_RADIO_BUTTON_0310.
  MODIFY GT_100 INDEX TC_100-CURRENT_LINE TRANSPORTING MARK.

  CLEAR: GS_100_TC,
         GT_110, GT_110[], GT_110A,
         GT_120, GT_120[], GT_120A.
  READ TABLE GT_100 INTO GS_100_TC
                   INDEX TC_100-CURRENT_LINE.

* 배치의 헤더를 설정한다.
  GS_101-ZMATSEQ  = GT_100-ZMATSEQ.          "자재Seq
  GS_101-MATNR    = GT_100-MATNR.            "자재번호
  GS_101-MAKTX    = GT_100-MAKTX.            "자재내역
  GS_101-KDAUF    = GT_100-KDAUF.            "판매오더
  GS_101-KZLOESCH = GT_100-KZLOESCH.         "삭제플래그
  GS_101-WERKS_M  = GT_100-WERKS_M.          "자재플랜트
  PERFORM GET_WERKST USING    GS_101-WERKS_M
                     CHANGING GS_101-WERKST. "플랜트명

* gt_110a 에서 일치하는 데이터를 가져온다.
  LOOP AT GT_110A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                    AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    GT_110 = GT_110A.
    APPEND GT_110.
    CLEAR: GT_110, GT_110A.
  ENDLOOP.

* gt_120a 에서 일치하는 데이터를 가져온다.
  LOOP AT GT_120A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                    AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    GT_120 = GT_120A.
    APPEND GT_120.
    CLEAR: GT_120, GT_120A.
  ENDLOOP.


ENDMODULE.                 " GET_TBON_HEDER  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CHARGE_COUNT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CHARGE_COUNT INPUT.

  CHECK NOT GT_110[] IS INITIAL.

  CHECK GT_110-ZMATSEQ <> '000'. "기능개선_153749

* 입력값 저장
  MODIFY GT_110 INDEX TC_110-CURRENT_LINE
                TRANSPORTING RKMNG KWMENG MARK.
  MODIFY GT_110A FROM GT_110 TRANSPORTING RKMNG KWMENG
                WHERE RCEPNO  EQ GT_110-RCEPNO
                  AND ZMATSEQ EQ GT_110-ZMATSEQ
                  AND ZCHASEQ EQ GT_110-ZCHASEQ.

* 불만수량 계산
  PERFORM SET_CHARGE_COUNT.

ENDMODULE.                 " SET_CHARGE_COUNT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_310  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_310 INPUT.

* ok_code는 main에서 사용하므로 여기서 clear하지 않음.
  OK_SAVE = OK_CODE.
  CASE OK_SAVE.

*   불만제품
    WHEN 'ADD'.       PERFORM GET_TC_100_ADD.      "추가
    WHEN 'DELE'.      PERFORM GET_TC_100_DELETE.   "삭제
    WHEN 'DEL_CANC'.  PERFORM TC_100_DELETE_CANC.  "삭제취소
    WHEN 'KDAUF_OK'.  PERFORM GET_TC_100_UPD.      "판매오더로 등록

*   불만제품(배치)
    WHEN 'ADD1'.      PERFORM GET_TC_100_ADD1.     "추가
    WHEN 'DELE1'.     PERFORM GET_TC_100_DELETE1.  "삭제
    WHEN 'DEL_CANC1'. PERFORM TC_100_DELETE_CANC1. "삭제취소
    WHEN 'PREV'.      PERFORM TC_100_PREV1.        "이전품목
    WHEN 'NEXT'.      PERFORM TC_100_NEXT1.        "다음품목
*{[기능개선 CHM2201-00099] 불량수량 일괄 등록 개선
    WHEN 'COPY_MNG'.  PERFORM GET_GT_110_COPY_MNG. "납품수량 복사
    WHEN 'COPY_CANC'. PERFORM GET_GT_110_COPY_CANC."납품수량 복사취소
*}[기능개선 CHM2201-00099] 2022.01.11 kmj A.C

*   불만제품(불량)
    WHEN 'ADD2'.      PERFORM GET_TC_100_ADD2.     "추가
    WHEN 'DELE2'.     PERFORM GET_TC_100_DELETE2.  "삭제
    WHEN 'DEL_CANC2'. PERFORM TC_100_DELETE_CANC2. "삭제취소



  ENDCASE.

ENDMODULE.                 " USER_COMMAND_310  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRC_WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRC_WERKS INPUT.

  CLEAR: GS_101-WERKST.
  PERFORM GET_WERKST USING    GS_101-WERKS_M
                     CHANGING GS_101-WERKST.

ENDMODULE.                 " PRC_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MATNR_WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR_WERKS INPUT.

  CHECK NOT GS_101-MATNR   IS INITIAL AND
        NOT GS_101-WERKS_M IS INITIAL.

  PERFORM CHECK_MATNR_WERKS USING GS_101-MATNR
                                  GS_101-WERKS_M
                                  'ERRM'.

ENDMODULE.                 " CHECK_MATNR_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MATNR_KDAUF  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR_KDAUF INPUT.

  CHECK NOT GS_101-MATNR IS INITIAL AND
        NOT GS_311-KDAUF IS INITIAL AND
        NOT GS_311-KDPOS IS INITIAL.

  PERFORM CHECK_MATNR_KDAUF USING GS_101-MATNR
                                  GS_311-KDAUF
                                  GS_311-KDPOS.

ENDMODULE.                 " CHECK_MATNR_KDAUF  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_KDAUF_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KDAUF_KUNNR INPUT.

* local variable
  DATA: LV_VBELN TYPE VBAK-VBELN.

  SELECT SINGLE VBELN FROM VBAK
                      INTO LV_VBELN
                     WHERE VBELN EQ GS_311-KDAUF
                       AND KUNNR EQ GS_100-KUNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH TEXT-E11.
  ENDIF.

ENDMODULE.                 " CHECK_KDAUF_KUNNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0320 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'OKAY'.
      PERFORM GET_LIST.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0320  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_FAULTY_CASE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_FAULTY_CASE INPUT.

  CHECK NOT GT_120[] IS INITIAL.

* 입력값 저장
  MODIFY GT_120 INDEX TC_120-CURRENT_LINE
                TRANSPORTING MARK.

ENDMODULE.                 " SET_FAULTY_CASE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_KDAUF_0320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KDAUF_0320 INPUT.

  CHECK NOT GS_102-KDAUF IS INITIAL.

* 판매오더 번호와 고객번호가 일치하는지 확인한다.
  SELECT SINGLE * FROM VBAK
                 WHERE VBELN EQ GS_102-KDAUF
                   AND KUNNR EQ GS_100-KUNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH TEXT-E12.
  ENDIF.

ENDMODULE.                 " CHECK_KDAUF_0320  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0321  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0321 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR: OK_CODE.

  CASE OK_SAVE.
    WHEN 'CACL'.
      LEAVE TO SCREEN 0.

    WHEN 'OKAY'.
      PERFORM GET_DATA_0321.
      GS_311-KDPOS   = GT_0321-POSNR.  "판매 문서 품목
      GS_101-MATNR   = GT_0321-MATNR.  "자재 번호
      GS_101-WERKS_M = GT_0321-WERKS_M."플랜트
      GS_101-MAKTX   = GT_0321-MAKTX.  "자재 내역
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C321
                                   G_GRID_321.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      "nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0321  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_210_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_210_ITAB_DATA INPUT.

  CLEAR: GS_210_TC.
  READ TABLE GT_210 INTO GS_210_TC INDEX TC_210-CURRENT_LINE.

  IF SY-SUBRC = 0.
    MODIFY GT_210 INDEX TC_210-CURRENT_LINE
                  TRANSPORTING MARK.
  ENDIF.

ENDMODULE.                 " MODIFY_210_ITAB_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_810  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_810 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.

    WHEN 'PB_MADD'.       "문서추가

*      CALL SCREEN '0950' STARTING AT 15  8  ENDING AT 62  16.
      CALL SCREEN '0960' STARTING AT 15  8  ENDING AT 92  16.

    WHEN 'PB_MDEL'.       "문서삭


    WHEN OTHERS.
      PERFORM SUBMIT_ZQMR0820.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_810  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_910  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_910 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'PB_GLPOST'.    "전표생성
* C20120417_91448 전표 생성 시 영업정보 체크
      PERFORM CHECK_SALES.

      PERFORM EXE_910_POSTING.

    WHEN 'PB_ADD'.       "전표추가
      PERFORM EXE_910_ADD.

    WHEN 'PB_REVERSE'.   "전표역분개
      PERFORM EXE_910_REVERSE.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_910  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_930  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_930 OUTPUT.

  SET PF-STATUS 'POP2'.
  SET TITLEBAR 'T0000' WITH '전표 처리'.

ENDMODULE.                 " STATUS_930  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_930  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_930 INPUT.

* 전표 BDC 전기를 위한 변수
  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE.

  OK_SAVE = OK_CODE.

  CASE OK_SAVE.
    WHEN 'OKAY'.

*& 2014.05.23, ZLSGQM, 기능개선_19639 반영시작   >> START

"      PERFORM BDC_GLPOST_CREATE USING ZQMS301-RCEPNO
*->[가온전선]--------------------CHG S
      IF ZQMS301-WERKS+0(1) = '6'.
*      IF ZQMS301-WERKS+0(1) = '1'.
*-<[가온전선]--------------------CHG E

*<<<    전표 기표 BDC -> 펑션으로 변경 / ZITCS4HDEV10  2023.07.17
        PERFORM BDC_GLPOST_CREATE1_NEW TABLES LT_BBKPF LT_BBSEG
                                        USING ZQMS301-RCEPNO.
*        PERFORM BDC_GLPOST_CREATE1 USING ZQMS301-RCEPNO.
*>>>
      ELSEIF ZQMS301-WERKS+0(1) = '3' OR ZQMS301-WERKS+0(1) = '5'.
*<<<    전표 기표 BDC -> 펑션으로 변경 / ZITCS4HDEV10  2023.07.17
        PERFORM BDC_GLPOST_CREATE_NEW TABLES LT_BBKPF LT_BBSEG
                                       USING ZQMS301-RCEPNO.
*        PERFORM BDC_GLPOST_CREATE USING ZQMS301-RCEPNO.
*>>>
      ENDIF.

*& 2014.05.23, ZLSGQM, 기능개선_19639 반영끝   >> END

      IF G_930_FORM_FLG IS INITIAL.
        LEAVE TO SCREEN  0.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_930  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0940  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0940 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'OKAY'.

*& 2014.05.26, ZLSGQM, 기능개선_19639 반영시작   >> START

"        PERFORM EXE_940_REVERSE.
      IF S_940-BUKRS = '6000'.
        PERFORM EXE_940_REVERSE1.
      ELSEIF S_940-BUKRS = '3000' OR S_940-BUKRS = '5000'.
        PERFORM EXE_940_REVERSE.
      ENDIF.

*& 2014.05.26, ZLSGQM, 기능개선_19639 반영끝   >> END

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0940  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0920  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0920 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'OKAY'.
      PERFORM EXE_940_ADD.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0920  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0950  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0950 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'OKAY'.
      PERFORM EXE_950_ADD.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0950  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_710  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_710 INPUT.

  OK_SAVE = OK_CODE.

  CASE OK_SAVE.
    WHEN 'PB_AMNT'.
      PERFORM EXE_RECOM_COST_ALL.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_710  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0323  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0323 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR: OK_CODE.

  CASE OK_SAVE.
    WHEN 'OKAY'.
      PERFORM GET_0323_DISPLAY.
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C323
                                   G_GRID_323.
      LEAVE TO SCREEN 0.

    WHEN 'CACL'.
      PERFORM EXE_CACL.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0323  INPUT
*&---------------------------------------------------------------------*
*&      Module  EMPFK_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       대체수취인 리스트 설정
*----------------------------------------------------------------------*
MODULE EMPFK_DATA OUTPUT.

* global variable
  FREE VALUES1.
  CLEAR: GS_EFKDT, GT_EFKDT.

* 회사코드 확인
  IF ZQMS301-BUKRS IS INITIAL.
    MESSAGE S001 WITH '회사코드를 입력하십시오.'.
  ENDIF.

* 대체수취인 데이터를 읽어온다.
  DATA : L_LIFNR TYPE LFZA-LIFNR.


  L_LIFNR = ZQMS301-NEWKO2+7(10).
  SELECT A~EMPFK
        INTO CORRESPONDING FIELDS OF TABLE GT_EFKDT
         FROM LFZA AS A
        WHERE A~LIFNR EQ L_LIFNR
          AND A~BUKRS EQ ZQMS301-BUKRS.


*  SELECT A~EMPFK B~NAME1
*         INTO TABLE GT_EFKDT
*         FROM LFZA AS A
*         JOIN LFA1 AS B
*           ON A~LIFNR EQ B~LIFNR
*        WHERE A~LIFNR EQ ZQMS301-NEWKO2
*          AND A~BUKRS EQ ZQMS301-BUKRS.

* 리스트박스에 데이터를 담는다.
  LOOP AT GT_EFKDT INTO GS_EFKDT.

    SELECT SINGLE NAME1
    INTO GS_EFKDT-NAME1
    FROM LFA1
    WHERE LIFNR =  GS_EFKDT-EMPFK.

    VALUES1-KEY  = GS_EFKDT-EMPFK.
    VALUES1-TEXT = GS_EFKDT-NAME1.

    APPEND VALUES1.
    CLEAR: GS_EFKDT, VALUES1.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'GV_EMPFK'
      VALUES          = VALUES1[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0.

  ENDIF.


ENDMODULE.                 " EMPFK_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VBELN_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_VBELN_KUNNR INPUT.

  SELECT SINGLE VBELN FROM LIKP
                      INTO LV_VBELN
                     WHERE VBELN EQ GS_311-VBELN
                       AND KUNNR EQ GS_100-KUNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH TEXT-E11.
  ENDIF.

ENDMODULE.                 " CHECK_VBELN_KUNNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0960  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0960 INPUT.

  OK_SAVE = OK_CODE.
  CASE OK_SAVE.
    WHEN 'SAVE960'.
      PERFORM EXE_960_SAVE.
    WHEN 'OKAY'.
      PERFORM EXE_960_OKAY.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0960  INPUT
