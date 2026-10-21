*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4500
*& 프로그램 명 : 자재문서 통문증 발행
*& 개요   : 가온전선_기존 LS 통문증발행(ZLER0015)프로그램 카피 후 단순화 및 폼 변경
*& 생성일 : 2026.01.06
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자 :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT  ZGTMMR4500 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.

INCLUDE ZGTMMR4500TOP.
INCLUDE ZGTMMR4500F01.

*&---------------------------------------------------------------------*
*&   Event AT INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* 권한/필수입력값 CHECK
  PERFORM AUTHORITY_CHECK.

*___타 프로그램에서 호출되는 경우 통문유형을 받아옴.
  PERFORM IMPORT_IVTYPE_FROM_PARAMETER.

  PERFORM VALUE_REQUEST USING 'GUBUN1' .

AT SELECTION-SCREEN OUTPUT.
* Radio button click시 필드 활성/비활성
  PERFORM SCREEN_FIELD_CHANG.

  PERFORM VALUE_REQUEST USING 'GUBUN1' .

  PERFORM SET_DEFAULT_GUBUN.

*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN
*&---------------------------------------------------------------------*

*AT SELECTION-SCREEN ON P_BZAREA.
*  PERFORM CHECK_INPUT(ZLER0012) USING P_BZAREA.

AT SELECTION-SCREEN ON P_BUKRS.
  PERFORM CHECK_BUKRS.


*&---------------------------------------------------------------------*
*&   Event START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*가온전선_사업장 조회조건 미사용으로 주석_(ZGODEV04_260106)
  IF P_GUBUN1 IS INITIAL.
    MESSAGE S002(ZLE1) DISPLAY LIKE 'E'
    WITH '이동유형(통문구분)을 입력하십시오'.
    EXIT.
 ENDIF.

*  ELSE.
    CASE 'X'.
      WHEN R1.
*    MM 통문발행 대상 발췌
        PERFORM MM_GET_DATA.

      WHEN R2.
*    매각, 폐기
        PERFORM DD_GET_DATA.

      WHEN OTHERS.
*    PP/서비스_가온전선_해당로직 숨김(미사용)_(ZGODEV04 260106)
*      PERFORM PP_GET_DATA.
    ENDCASE.
*  ENDIF.

">>251027
  MODIFY GT_OUT FROM VALUE #( NUM = SPACE ) TRANSPORTING NUM
   WHERE NUM IS NOT INITIAL.
  CLEAR: GV_NUM.
"<<
*/ 2005.07.13 BY SDC08
  LOOP AT GT_OUT.
    CASE GT_OUT-IVTYP .
      WHEN 'B04'.  "플랜트간 이동
        PERFORM COSTOMER_INFO USING ' ' ' ' 'X'.
      WHEN 'D02'.  "매각
        PERFORM COSTOMER_INFO USING ' ' 'X' ' '.
      WHEN OTHERS.
        PERFORM COSTOMER_INFO USING 'X' ' ' ' '.
    ENDCASE.
">>251027
   GV_NUM = GV_NUM + 1.
   GT_OUT-NUM = GV_NUM.
   CONDENSE GT_OUT-NUM.
"<<
    MODIFY GT_OUT TRANSPORTING LIFNR KUNNR UMWRK NUM.
  ENDLOOP.

  IF P_GUBUN1 = 'B11' OR P_GUBUN1 = 'B13' OR
     P_GUBUN1 = 'B14' OR P_GUBUN1 = 'B15'.
    CALL SCREEN 300.
  ELSE.
    CALL SCREEN 100.
  ENDIF.

END-OF-SELECTION.
*  BREAK-POINT.

*&---------------------------------------------------------------------*
*&   Event AT USER-COMMAND
*&---------------------------------------------------------------------*
AT USER-COMMAND.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
  LOOPS = 22.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  IF P_GUBUN1 = 'B15'.
    SET PF-STATUS '0300'.
  ELSE.
    SET PF-STATUS '100'.
  ENDIF.
  SET TITLEBAR '100'.
  LOOPS = 22.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      CLEAR: TM_TRUNO.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR: SY-UCOMM, TEMP_LIFNR, TEMP_MBLNR.

ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA: TM_MBLNR LIKE MSEG-MBLNR.

  CASE SY-UCOMM.
*--Check Option
    WHEN 'ASEL' OR 'DSEL'.
      PERFORM ALL_DE_SELECT_CHECKBOX.

*--Check box 선택시 사양
    WHEN 'CHK'.
      CLEAR GV_MBLNR.
      I_CURSOR_LINE = TC01-CURRENT_LINE + I_CURSOR_LINE - 1.

      READ TABLE GT_OUT INTO GT_OUT_T INDEX I_CURSOR_LINE.
      GV_MBLNR = GT_OUT_T-MBLNR.

      PERFORM SAME_MBLNR_CHECK USING GV_MBLNR.

*--전체선택
*-{기능개선 71811 - 추가
    WHEN 'ALL_C'.
      PERFORM CHK_ALL.
*-}기능개선 71811_2015.03.18

*--Refresh
    WHEN 'REFR'.
      IF R1 = 'X' ."OR R4 = 'X'. "*가온전선_R4(서비스)미사용으로 주석_(ZGODEV04_260106)
*      MM 통문발행 대상 발췌
        PERFORM MM_GET_DATA.

      ELSEIF R2 = 'X'.
*      매각, 폐기
        PERFORM DD_GET_DATA.

      ELSE.
*      PP "가온전선_R3/R4(서비스)미사용으로 주석_(ZGODEV04_260106).
*        PERFORM PP_GET_DATA.
      ENDIF.

      LOOP AT GT_OUT.
        CASE GT_OUT-IVTYP .
          WHEN 'B04'.  "플랜트간 이동
            PERFORM COSTOMER_INFO USING ' ' ' ' 'X'.

          WHEN 'D02'.  "매각
            PERFORM COSTOMER_INFO USING ' ' 'X' ' '.

          WHEN OTHERS.
            PERFORM COSTOMER_INFO USING 'X' ' ' ' '.
        ENDCASE.
        MODIFY GT_OUT TRANSPORTING LIFNR KUNNR UMWRK.
      ENDLOOP.

*--통문증 미리보기
    WHEN 'LV_PR'.
      CALL SCREEN 0200.

*--통문증 발행
    WHEN 'LV_PN'.
      PERFORM SMART_FORM_PRINT.

*--엑셀 다운로드 기능 추가
    WHEN 'DOWN'.
      PERFORM EXCEL_DOWN.
*   20061229 수정완료

*--SORT
    WHEN 'DSOR' OR 'ASOR'.
      PERFORM A_DE_SCENDING_SORT.

*--Page Down/Up 설정
    WHEN 'P++' OR 'P+' OR 'P--' OR 'P-'.
      PERFORM PAGE_SCROLLING CHANGING TC01-TOP_LINE.
  ENDCASE.

*통문증 발행 후 거래수량과 납품수량이 일치하면 삭제
  LOOP AT GT_OUT WHERE CHK = 'X'.
    CLEAR: T_LFIMG, ZGTMMT4501."ZLET0006.
    SELECT * FROM ZGTMMT4501 WHERE MBLNR = GT_OUT-MBLNR
                             AND ZEILE = GT_OUT-ZEILE
                             AND MJAHR = GT_OUT-MJAHR.
*     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
    CLEAR ZGTMMT4500. "ZLET0005.
    SELECT SINGLE * FROM ZGTMMT4500 WHERE IV_NO = ZGTMMT4501-IV_NO
                                                            AND IV_CANCEL_YN <> 'X'.
     IF SY-SUBRC = 0.
       T_LFIMG = T_LFIMG + ZGTMMT4501-LFIMG.
     ENDIF.
    ENDSELECT.

    IF GT_OUT-MENGE = T_LFIMG.
      DELETE GT_OUT INDEX SY-TABIX.
      CONTINUE.
    ENDIF.
  ENDLOOP.
*  LOOP AT GT_OUT WHERE CHK = 'X'.
*    CLEAR: T_LFIMG, ZLET0006.
*    SELECT * FROM ZLET0006 WHERE MBLNR = GT_OUT-MBLNR
*                             AND ZEILE = GT_OUT-ZEILE
*                             AND MJAHR = GT_OUT-MJAHR.
**     통문증 Header에 삭제 Flag가 찍힌 Data는 통문증을 다시 재발행
*    CLEAR ZLET0005.
*    SELECT SINGLE * FROM ZLET0005 WHERE IV_NO = ZLET0006-IV_NO
*                                                            AND IV_CANCEL_YN <> 'X'.
*     IF SY-SUBRC = 0.
*       T_LFIMG = T_LFIMG + ZLET0006-LFIMG.
*     ENDIF.
*    ENDSELECT.
*
*    IF GT_OUT-MENGE = T_LFIMG.
*      DELETE GT_OUT INDEX SY-TABIX.
*      CONTINUE.
*    ENDIF.
*  ENDLOOP.

  CLEAR: TM_MBLNR, LV_MBLNR.
  CLEAR SY-UCOMM.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
* SET TITLEBAR 'xxx'.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  CLEAR: TEMP_PAGNO, TMP_MBLNR.
  CLEAR: LV_MBLNR, LV_ZEILE, LV_LIFNR, LV_IVTYP,
         LV_UMWRK, LV_WERKS, LV_LIFNR, LV_KUNNR.

  REFRESH: LV_SM01, LV_SM02, LV_SM03, OTF.
  CLEAR: LV_SM01, LV_SM02, LV_SM03, OTF, LV_CT.

* [START] CSR NO : C20070705_93500
  CLEAR: LV_SUM_LFIMG.
* [END]   CSR NO : C20070705_93500

  LOOP AT GT_OUT WHERE CHK = 'X'.
    LV_CT = LV_CT + 1.
    LV_MBLNR = GT_OUT-MBLNR.
    LV_ZEILE = GT_OUT-ZEILE.
    LV_LIFNR = GT_OUT-LIFNR.
    LV_IVTYP = GT_OUT-IVTYP.
    LV_WERKS = GT_OUT-WERKS.
    LV_UMWRK = GT_OUT-UMWRK.
    LV_LIFNR = GT_OUT-LIFNR.
    LV_KUNNR = GT_OUT-KUNNR.
    LV_MJAHR = GT_OUT-MJAHR.
    GV_BUKRS = GT_OUT-BUKRS.

  ENDLOOP.

  IF LV_CT = 0.
    MESSAGE S005(ZLE1) WITH 'DATA를 선택하세요'.
    EXIT.
  ENDIF.
*-{기능개선 48104 - 추가
  PERFORM DRIVER_CHK.
*-}기능개선 48104_2014.10.16
*
  CLEAR LV_IVNO.
* 통문증 Header
  PERFORM SM_HEADER USING LV_IVNO LV_MBLNR LV_IVTYP LV_LIFNR
                          LV_WERKS LV_UMWRK LV_KUNNR LV_MJAHR.
* 통문증 Middle
  PERFORM SM_MIDDLE.
* 통문증 Detail
  PERFORM SM_DETAIL.
* smart forms
  PERFORM SMART_FORM_SETTING.
*
  PERFORM SMART_FORM_FINALL_WRITE.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC01_GET_LINE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC01_GET_LINE OUTPUT.

  DATA: WA_COLS  LIKE LINE OF TC01-COLS.

  IF R1 = 'X' ."OR R3 = 'X' . "가온전선_R3(PP)미사용으로 주석_(ZGODEV04_260106)
    LOOP AT TC01-COLS INTO WA_COLS
       WHERE SCREEN-NAME = 'GT_OUT-WAERS' OR
             SCREEN-NAME = 'GT_OUT-NETPR' OR
             SCREEN-NAME = 'GT_OUT-DMBTR'.
      WA_COLS-INVISIBLE = '1'.
      MODIFY TC01-COLS FROM WA_COLS INDEX SY-TABIX.
    ENDLOOP.
  ENDIF.


*  MODIFY gt_out INDEX tc01-current_line.

ENDMODULE.                 " TC01_GET_LINE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC01_MODIFY INPUT.

  MODIFY GT_OUT INDEX TC01-CURRENT_LINE.

ENDMODULE.                 " TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  CLEAR: G_CURSOR_FIELD, I_CURSOR_LINE.
  GET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " get_cursor  INPUT
*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT OUTPUT.

  LOOP AT SCREEN.
    IF P_BUKRS <> '1000'.
      IF SCREEN-NAME = 'LV_LTEXT'.
        SCREEN-REQUIRED = 0.
      ELSEIF SCREEN-GROUP1 = 'G1'.
        SCREEN-ACTIVE = 0.
      ENDIF.

      IF SCREEN-GROUP1 = 'G11'.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP2 = 'G21' AND GV_COPY = 'X'.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

*{CHM2008-00227 - S
    IF P_BUKRS <> '3000' AND SCREEN-GROUP1 = 'M01'.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.
*}CHM2008-00227 - E

    MODIFY SCREEN.
  ENDLOOP.

  IF SY-DYNNR = '0100'.
    DESCRIBE TABLE GT_OUT LINES TC01-LINES.
  ELSE.
    DESCRIBE TABLE GT_OUT LINES TC02-LINES.
  ENDIF.

ENDMODULE.                 " INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TRUNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TRUNO INPUT.

*-{기능개선74585-추가, 수정
  PERFORM F4_TRNUM USING LV_TRUNO.
*  PERFORM f4_trnum(zler0020) USING lv_truno.
*-}기능개선74585_2015.04.07

ENDMODULE.                 " F4_TRUNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  PRING_JANGSU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRING_JANGSU INPUT.

*  CLEAR: ZLET0017.
*  IF TM_TRUNO = LV_TRUNO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ LV_TRUNO.
*       CHECK SY-SUBRC = 0.
*       IF LV_DRNAM = ' '.
*         LV_DRNAM = ZLET0017-DRNAM.
*       ENDIF.
*       IF LV_DRTEL = ' '.
*         LV_DRTEL = ZLET0017-DRPHO.
*       ENDIF.
*  ELSE.
*    IF LV_TRUNO <> ' '.
*       TM_TRUNO = LV_TRUNO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ LV_TRUNO.
*       IF SY-SUBRC = 0.
*         LV_DRNAM = ZLET0017-DRNAM.
*         LV_DRTEL = ZLET0017-DRPHO.
*       ELSE.
*         CLEAR: LV_DRNAM, LV_DRTEL.
*       ENDIF.
*    ELSE.
*      CLEAR: LV_DRNAM, LV_DRTEL.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " PRING_JANGSU  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC02_MODIFY INPUT.

  MODIFY GT_OUT INDEX TC02-CURRENT_LINE.

ENDMODULE.                 " TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TRUNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TRUNO INPUT.

*-{기능개선 93857 - 추가요구사항 : 플랜트 3604(특수) 일 경우,
*                                 운송사 마스터 찾아오지 않게 변경

*-{기능개선74585-추가
    IF STRLEN( LV_TRUNO ) = 4.
      PERFORM F4_TRUNO USING LV_TRUNO.
      PERFORM GET_DRNAM_DRTEL USING LV_TRUNO LV_DRNAM LV_DRTEL.
    ELSEIF LV_TRUNO IS NOT INITIAL.
      PERFORM GET_DRNAM_DRTEL USING LV_TRUNO LV_DRNAM LV_DRTEL.
    ENDIF.
*-}기능개선74585_2015.04.07

*-}기능개선 93857 - 추가요구사항

ENDMODULE.                 " CHECK_TRUNO  INPUT
