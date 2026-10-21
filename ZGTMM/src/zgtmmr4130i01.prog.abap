*&---------------------------------------------------------------------*
*& Include          ZGTMMR4130I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR OK_CODE.

      PERFORM EXIT_PROGRAM.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  GV_OKCODE = OK_CODE.
  CLEAR: OK_CODE.
  CASE GV_OKCODE.
    WHEN 'ME21N'.                    "구매오더 생성(BAPI)
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '구매오더를 생성 하시겠습니까?'
        '구매오더 생성'.
      IF GV_ANSWER = 'J'.
        PERFORM CREATE_PURCHASE_ORDER.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'ME21N_D'.                  "구매오더 삭제(BAPI)
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '구매오더를 삭제 하시겠습니까?'
        '구매오더 삭제'.
      IF GV_ANSWER = 'J'.
        PERFORM DELETE_PURCHASE_ORDER.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'ME22N'.                    "구매오더 변경
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '구매오더를 변경 하시겠습니까?'
        '구매오더 변경'.
      IF GV_ANSWER = 'J'.
        GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
        PERFORM CHANGE_PURCHASE_ORDER.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'MEBOM'.                    "구성부품조회
      PERFORM CALL_SCREEN_0200.

*& 화면을 새롭게 갱신...
      PERFORM ADDITIONAL_INFO_PROC.
      PERFORM REFRESH_GT_EBAN_DISPLAY.

    WHEN 'ZMMR0041'.                 "발주서 발행
      PERFORM SUBMIT_ZMMR0041.

    WHEN 'ZPPR0058'.                 "설계서 발행
      PERFORM SUBMIT_ZPPT0058.

    WHEN 'ZPPR0052'.                 "꼬리표 발행
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '꼬리표를 발행 하시겠습니까?'
        '꼬리표 발행'.
      IF GV_ANSWER = 'J'.
        PERFORM CREATE_ZPPT0001.
        PERFORM SUBMIT_ZPPR0052 USING '선발행'.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'ZPPR0052_R'.               "꼬리표 재발행
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '꼬리표를 재발행 하시겠습니까?'
        '꼬리표 재발행'.
      IF GV_ANSWER = 'J'.
        PERFORM SUBMIT_ZPPR0052 USING '재발행'.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'POTEXT'.                 "설계정보 복사
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '설계정보를 복사하시겠습니까?'
        '설계정보 복사'.
      IF GV_ANSWER = 'J'.
        PERFORM COPY_PO_TEXT.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'ME51N_D'.                 "구매요청 삭제

      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '구매요청을 삭제하시겠습니까?'
          '구매요청 삭제'.
      IF GV_ANSWER = 'J'.
        PERFORM DELETE_PR.
        PERFORM REFRESH_GT_EBAN_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'TEST'.
*&      gv_testrun = 'X'.              "BAPI 테스트 모드
      GS_BDCPARAMS-DISMODE  = 'A'.   "BDC 처리모드

    WHEN  OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  GV_OKCODE = OK_CODE.
  CLEAR: OK_CODE.
  CASE GV_OKCODE.
    WHEN 'MB1B'.                     "SC 재고
*(S)기능 추가 관련(SJM 25.03.18)
      IF LINE_EXISTS( GT_MDSB_L[  CHECK = GC_X STATS = ICON_ALLOW ] )
      OR LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X STATS = ICON_ALLOW ] ).
        DATA(LV_CHK) = GC_X. "한도 체크 불필요. 기존 로직으로 출고 처리!
      ENDIF.

      IF GV_ZUSE = GC_X AND LV_CHK IS INITIAL.
        PERFORM PRCS_MB1B.
      ELSE.
        CLEAR : LV_CHK.
        PERFORM CHECK_MB1B USING 'X'.
        CHECK GV_ERR IS INITIAL.
*(E)기능 추가 관련(SJM 25.03.18)

        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          'SC 재고이전 전기를 수행 하시겠습니까?'
          'SC 재고이전 전기'.
        IF GV_ANSWER = 'J'.
          PERFORM SC_STOCK_TRANFER.

          PERFORM REFRESH_GT_MDSB_L_DISPLAY.
          PERFORM REFRESH_GT_MDSB_W2_DISPLAY.
        ELSE.
          MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
        ENDIF.
      ENDIF. "추가(SJM 25.03.18)

    WHEN 'CCAP'.                     "상신취소
      PERFORM PRCS_CCAP. "추가(SJM 25.03.18)

    WHEN 'MBST'.                     "구성부품 이전전기 취소
      PERFORM CHECK_MBST.      "추가(SJM 25.04.03)
      CHECK GV_ERR IS INITIAL. "추가(SJM 25.04.03)

      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '구성부품 이전전기를 취소 하시겠습니까?'
        '구성부품 이전전기 취소'.
      IF GV_ANSWER = 'J'.
        PERFORM MM_DOC_CANCEL_BAPI.

        PERFORM REFRESH_GT_MDSB_L_DISPLAY.
        PERFORM REFRESH_GT_MDSB_W2_DISPLAY.
      ELSE.
        MESSAGE S001 WITH '작업이 취소 되었습니다.!!!'.
      ENDIF.

    WHEN 'ZLER0015'.                 "통문증 발행
      PERFORM SUBMIT_ZLER0015.

      PERFORM REFRESH_GT_MDSB_L_DISPLAY.
      PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

    WHEN 'ZLER0016'.                 "통문증 발행 취소
      PERFORM SUBMIT_ZLER0016.

      PERFORM REFRESH_GT_MDSB_L_DISPLAY.
      PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

    WHEN 'FOSTNR'.    "조장구성표 리스트
*& 조장구성표 번호로 읽기 방식으로 변경
      READ TABLE GT_MDSB_L WITH KEY CHECK = 'X'.
      CHECK SY-SUBRC = 0.

      SUBMIT ZPPR0061 WITH S_EBELN = GT_MDSB_L-EBELN
                   AND RETURN.

*& 조장구성표 번호로 읽기 방식의 이전 방식
*&      PERFORM display_length_ord_detail.

*& 자동차전선의 경우, 통문증 미발행대상은 CBO테이블(ZPPT0018)의 통문증
*& 발행여부 필드(OUTPR_F)만 관리한다...
    WHEN 'ZLER0015_Z'.               "통문증 미발행
      PERFORM SUBMIT_ZLER0015_Z.

      PERFORM REFRESH_GT_MDSB_L_DISPLAY.
      PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

    WHEN 'ZLER0016_Z'.               "통문증 미발행 취소
      PERFORM SUBMIT_ZLER0016_Z.

      PERFORM REFRESH_GT_MDSB_L_DISPLAY.
      PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

    WHEN 'SELA'.
      PERFORM MARKED_CHECK_BOX_200 USING 'X'.

    WHEN 'DSEL'.
      PERFORM MARKED_CHECK_BOX_200 USING ' '.

    WHEN 'TEST'.
      GV_TESTRUN = 'X'.              "BAPI 테스트 모드
      GS_BDCPARAMS-DISMODE  = 'A'.   "BDC 처리모드
    WHEN  OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      CLEAR OK_CODE.
      LEAVE TO SCREEN 0.
    WHEN  OTHERS.
  ENDCASE.
  CLEAR OK_CODE.

ENDMODULE.                 " user_command_0900  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE GV_OKCODE.
    WHEN 'CANC'.
      CASE SY-DYNNR.
        WHEN '0210'.
          SET SCREEN 0.
      ENDCASE.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0210 INPUT.

  CLEAR : GV_ERR.

  CASE GV_OKCODE.
    WHEN 'YPRX'. "Yes
      CASE GV_PRC.
        WHEN 'N'.
          PERFORM PRCS_GIAR.
        WHEN 'O'.
          PERFORM SC_STOCK_TRANFER.
      ENDCASE.

      IF GV_ERR IS INITIAL.
        PERFORM REFRESH_GT_MDSB_L_DISPLAY.
        PERFORM REFRESH_GT_MDSB_W2_DISPLAY.

        SET SCREEN 0.
      ENDIF.

    WHEN 'NPRX'. "No
      SET SCREEN 0.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
