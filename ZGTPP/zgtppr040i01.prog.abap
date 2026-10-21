*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  GV_OK_CODE2 = GV_OK_CODE.
  CLEAR: GV_OK_CODE.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'CANC'.
      PERFORM EXIT_PROGRAM.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  GV_OK_CODE2 = GV_OK_CODE.
  CLEAR: GV_OK_CODE.

  CASE GV_OK_CODE2.
    WHEN 'SEND' OR "전송
            'RESEND'. "재처리
*      PERFORM send_data.
    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
* 조회 조건 기준으로 기초 DATA 조회
      REFRESH  : GT_DISP.
      PERFORM GET_DATA.
*  기초 data 필드별 생성
      PERFORM MODIFY_DATA.

      REFRESH  : GT_DISP1, GT_DISP2, GT_DISP3.
*  조회 모드별 data sum 변경
      PERFORM MODIFY_DATA_SUM.

      PERFORM REFRESH_GRID USING GO_GRID_0100.

*U01
    WHEN 'MATGIMIG'.
      PERFORM PROC_MATGIMIG.
    WHEN 'CONFIRM'.
      CHECK P_R1 = ABAP_TRUE.
      PERFORM PROC_CONFIRM.
*U01

  ENDCASE.
* REFRESH DISPLAY
*  CALL METHOD go_grid_0100->refresh_table_display
*    EXPORTING
*      i_soft_refresh = 'X'
*      is_stable      = gv_stable.

ENDMODULE.
