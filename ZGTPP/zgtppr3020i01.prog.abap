*&---------------------------------------------------------------------*
*&  Include           ZPPR0021I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM EXIT_PROGRAM.
  ENDCASE.
  CLEAR OK_CODE.
ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  DATA: LF_PRGRM(1) TYPE C  VALUE 'X',   "프로그램 호출시 플래그
        LV_BUKRS    TYPE MSEG-BUKRS.
  DATA : LV_CNT(2)  TYPE N,
         LV_TEXT(8).
  FIELD-SYMBOLS : <LV_FS> TYPE ANY.

  CLEAR : LV_BUKRS.

  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.
  CASE GV_OKCODE.
    WHEN 'ZPPM0021'.   "작업지시 상세조회
      PERFORM GET_CURRENT_ROW_INDEX USING ''.

      CHECK NOT ROW_TABLE[] IS INITIAL.
      SET PARAMETER ID 'WRK'    FIELD P_PWERK.
      SET PARAMETER ID 'ANR'    FIELD GT_AFKO-AUFNR.
      SET PARAMETER ID 'VGN'    FIELD GT_AFKO-VORNR.
      SET PARAMETER ID 'KMH'    FIELD LF_PRGRM.

      CALL TRANSACTION 'ZPPM0021' AND SKIP FIRST SCREEN.

    WHEN 'REL'.

*& 2009.11.09 정찬근대리 요청
      IF P_PWERK+0(1) EQ '2' OR   "JS전선만
         P_PWERK = '1901'.
        MESSAGE S001 WITH TEXT-073."생산오더 릴리즈 화면에서 릴리즈하세요.
        EXIT.
      ENDIF.

      CASE P_PWERK.
*&        WHEN '1201' OR '1304' OR '1305'. "권선,제선
        WHEN '1301'.              "UTP
          IF S_DISPO-LOW+0(2) = 'LN'.
            PERFORM CREATE_SELECTION_TABLE_0025.

            CHECK NOT ROW_TABLE[] IS INITIAL.
            SUBMIT ZPPR0025 WITH SELECTION-TABLE GT_SELTAB
*&                           VIA SELECTION-SCREEN
                             AND RETURN.
          ELSE.
            PERFORM CREATE_SELECTION_TABLE_0025.

            CHECK NOT ROW_TABLE[] IS INITIAL.
            SUBMIT ZPPR0026 WITH SELECTION-TABLE GT_SELTAB
*&                           VIA SELECTION-SCREEN
                             AND RETURN.
          ENDIF.
        WHEN  OTHERS.
          PERFORM CREATE_SELECTION_TABLE_0025.

          CHECK NOT ROW_TABLE[] IS INITIAL.
          SUBMIT ZPPR0026 WITH SELECTION-TABLE GT_SELTAB
*&                           VIA SELECTION-SCREEN
                           AND RETURN.
      ENDCASE.

    WHEN 'ZPPM0030'.   "작업실적 입력

      PERFORM GET_CURRENT_ROW_INDEX USING ' '.

*&      CHECK NOT row_table[] IS INITIAL.

      CHECK NOT GT_ZPPS040[] IS INITIAL.
      EXPORT GT_ZPPS040 TO MEMORY ID 'ZPPS040'.

      READ TABLE GT_ZPPS040 INDEX 1.

      SET PARAMETER ID 'WRK'    FIELD P_PWERK.
      SET PARAMETER ID 'ANR'    FIELD GT_ZPPS040-AUFNR.
      SET PARAMETER ID 'AGR'    FIELD GT_ZPPS040-ARBPL.
      SET PARAMETER ID 'VGN'    FIELD GT_ZPPS040-VORNR.

*& 회사코드를 조회하여 작업실적 관리 분기

      CALL FUNCTION 'Z_FI_GET_ORG_CODE'
        EXPORTING
          I_WERKS = P_PWERK
        IMPORTING
          E_BUKRS = LV_BUKRS.

      IF LV_BUKRS = '1000'.

        IF P_PWERK = '1302'.     "MES 사업부는 권한 체크

          CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
            EXPORTING
              TCODE  = 'ZPPM0030'
            EXCEPTIONS
              OK     = 1
              NOT_OK = 2
              OTHERS = 3.

          IF SY-SUBRC <> 0.
            IF SY-SUBRC EQ 1.
              CALL TRANSACTION 'ZPPM0030'
                              AND SKIP FIRST SCREEN.
            ELSE.
              MESSAGE S000 DISPLAY LIKE 'E' WITH
                          TEXT-074."작업실적 입력 실행 권한이 없습니다.
            ENDIF.
          ENDIF.

        ELSE.
          CALL TRANSACTION 'ZPPM0030'
                          AND SKIP FIRST SCREEN.

        ENDIF.
      ELSE.
        CALL TRANSACTION 'ZPPM0030J'
                     AND SKIP FIRST SCREEN.

      ENDIF.

*      IF gt_afko-sttxt = '작업지시전'.
*        MESSAGE s004 WITH '생산오더가 릴리즈되지 않았습니다.'
*                          '먼저, 오더릴리즈를 하십시오.!!!'.
*      ELSE.
*        EXPORT gt_zpps040 TO MEMORY ID 'ZPPS040'.
*
*        SET PARAMETER ID 'WRK'    FIELD p_pwerk.
*        SET PARAMETER ID 'ANR'    FIELD gt_afko-aufnr.
*        SET PARAMETER ID 'AGR'    FIELD gt_afko-arbpl.
*        CALL TRANSACTION 'ZPPM0030' AND SKIP FIRST SCREEN.
*      ENDIF.

    WHEN 'ZPPR0027'.   "꼬리표 선발행
      PERFORM CREATE_SELECTION_TABLE_0027.

*& 회사코드를 조회하여 작업실적 관리 분기

      CALL FUNCTION 'Z_FI_GET_ORG_CODE'
        EXPORTING
          I_WERKS = P_PWERK
        IMPORTING
          E_BUKRS = LV_BUKRS.

      IF LV_BUKRS = '1000'.
        CHECK NOT ROW_TABLE[] IS INITIAL.
        SUBMIT ZPPR0027 WITH SELECTION-TABLE GT_SELTAB
                        AND RETURN.
      ELSEIF LV_BUKRS = '2000'.
        CHECK NOT ROW_TABLE[] IS INITIAL.
        SUBMIT ZPPR0027J WITH SELECTION-TABLE GT_SELTAB
                         AND RETURN.
      ENDIF.

    WHEN 'ZPPU0117'.   "뱃치결정
      PERFORM SUBMIT_ZPPU0117_PROC.

    WHEN 'PRNT'.
      PERFORM SET_SMART_FORM_PARAMETERS.
      PERFORM PRINT_PROC.

*& 2010.04.01 CSR : C20100329_36685
*& 복수 출력 기능 추가
    WHEN 'MPRINT'.
      PERFORM MULTI_AUFNR_PRINT.

*& 2010.06.24 CSR : C20100513_65861
    WHEN 'ZPPM0030M'.
      PERFORM GET_CURRENT_ROW_INDEX USING 'M'.

      PERFORM CHECK_ZPPM0030M_VALIDATION.

      IF GV_ERRFLG IS INITIAL.

        CHECK NOT GT_ZPPS040[] IS INITIAL.
        EXPORT GT_ZPPS040 TO MEMORY ID 'ZPPS040'.

        CALL TRANSACTION 'ZPPM0030M'
                       AND SKIP FIRST SCREEN.
      ENDIF.

*-{ 308567 COOIS 연결
    WHEN 'COOIS'.
      PERFORM GET_COOIS_COMPONENT.
*}-308567
*- Start 2025.01.16
    WHEN 'INFO'.
      CLEAR : LV_CNT, GS_INFO, GT_INFO.
      DO 17 TIMES.

        LV_CNT = LV_CNT + 1.
        CONCATENATE 'TEXT-I' LV_CNT INTO LV_TEXT.
        ASSIGN (LV_TEXT) TO <LV_FS>.
* 띄어쓰기 라인 추가
        CLEAR : GS_INFO.
        IF LV_CNT = '04' OR LV_CNT = '08' OR LV_CNT = '12' OR LV_CNT = '17'.
          APPEND GS_INFO TO GT_INFO.
        ENDIF.

        IF LV_CNT = '05' OR LV_CNT = '09' OR LV_CNT = '13'.
          CONCATENATE ICON_LED_GREEN <LV_FS> INTO GS_INFO-TEXT.
        ELSEIF LV_CNT = '06' OR LV_CNT = '10' OR LV_CNT = '14'.
          CONCATENATE ICON_LED_YELLOW <LV_FS> INTO GS_INFO-TEXT.
        ELSEIF LV_CNT = '07' OR LV_CNT = '11' OR LV_CNT = '15'.
          CONCATENATE ICON_LED_RED <LV_FS> INTO GS_INFO-TEXT.
        ELSE.
          GS_INFO-TEXT = <LV_FS>.
        ENDIF.
        APPEND GS_INFO TO GT_INFO.

      ENDDO.

      CALL SCREEN 0102 STARTING AT 2 2 ENDING AT 90 20.
*- Start 2025.02.11
    WHEN 'TECO'.
      PERFORM PROCESS_TECO_ORDER.
*- End 2025.02.11
    WHEN 'NOSEND'.
      PERFORM SET_EXCLUD_GUID.
*[U01] 가온전선 추가
    WHEN 'BACKLOG'.
      CALL TRANSACTION 'ZGTPPR3000'.
*[U01] 가온전선 추가
    WHEN 'DEL_ACTI'.
      CHECK SY-TCODE = 'ZGTPPR3021G'.
      PERFORM PROC_DEL_ACTIBITY.

    WHEN 'SET_ACTI'.
      CHECK SY-TCODE = 'ZGTPPR3021G'.
      PERFORM PROC_SET_ACTIBITY.

*[U03] 가온전선 추가
    WHEN 'TECO1'.
      CHECK SY-TCODE = 'ZGTPPR3021G'.
      PERFORM PROCESS_TECO_ORDER_1.
*[U03] 가온전선 추가

    WHEN  OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_control_text  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CONTROL_TEXT INPUT.
  DATA: LT_TEXTEDIT_LINES LIKE TLINE-TDLINE OCCURS 0
                          WITH HEADER LINE.

  REFRESH GT_TLINES.   CLEAR: GT_TLINES.

* get table from control
  CALL METHOD GS_EDITOR->GET_TEXT_AS_R3TABLE
    IMPORTING
      TABLE = GT_TEXTEDIT_LINES.

  LT_TEXTEDIT_LINES[] = GT_TEXTEDIT_LINES[].
  LOOP AT LT_TEXTEDIT_LINES.
    MOVE: '* '               TO GT_TLINES-TDFORMAT,
          LT_TEXTEDIT_LINES  TO GT_TLINES-TDLINE.
    APPEND GT_TLINES.    CLEAR GT_TLINES.
  ENDLOOP.

ENDMODULE.                 " get_control_text  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.
  CASE OK_CODE.
    WHEN 'SAVE'.
      CLEAR OK_CODE.
      PERFORM SAVE_TEXT_PROC.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR OK_CODE.
      LEAVE TO SCREEN 0.
    WHEN  OTHERS.
  ENDCASE.
  CLEAR OK_CODE.

ENDMODULE.                 " user_command_0900  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0901  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0901 INPUT.

  GV_OKCODE = OK_CODE.
  CLEAR OK_CODE.
  CASE GV_OKCODE.
    WHEN 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN  OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0901  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_gt_stock  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_GT_STOCK INPUT.
  MODIFY GT_STOCK  INDEX TC_STOCK-CURRENT_LINE.
ENDMODULE.                 " modify_gt_stock  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0902  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0902 INPUT.
  CASE OK_CODE.
    WHEN 'CANC'.
      CLEAR OK_CODE.
      LEAVE TO SCREEN 0.
    WHEN  OTHERS.
  ENDCASE.
  CLEAR OK_CODE.

ENDMODULE.                 " USER_COMMAND_0902  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD GO_CONTAIN_0102->FREE.
      FREE : GO_CONTAIN_0102, GO_GRID_0102.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_903  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_COMMAND_903 INPUT.

  CASE OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR OK_CODE2.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0903  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0903 INPUT.

  CASE OK_CODE2.
    WHEN 'CLSD'.
      CLEAR OK_CODE2.
      LEAVE TO SCREEN 0.
    WHEN  OTHERS.
  ENDCASE.
  CLEAR OK_CODE2.

ENDMODULE.
