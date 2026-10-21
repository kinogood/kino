*----------------------------------------------------------------------*
***INCLUDE ZLER0401I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

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

  PERFORM GET_SELECTED_ROWS.

  CASE OK_SAVE.
    WHEN 'CREA'.            "출하요청생성
      PERFORM CREATE_DELIVERY_REQ.

    WHEN 'DCHG'.            "납품정보변경
      PERFORM CALL_SCREEN_0200.

    WHEN 'SAVE'.            "저장
      PERFORM SAVE_DELIVERY_REQ.

    WHEN 'SDCFM'.           "영업확정
      PERFORM SD_CONFIRM.

    WHEN 'RDEL'.            "삭제
      PERFORM DELETE_ROW.

    WHEN 'DISP'.            "납품문서조회
      PERFORM CALL_SCREEN_0300.

    WHEN 'DDIS'.            "납품정보조회(선적추가정보)
      PERFORM DISPLAY_DELIVERY_INFO.

    WHEN 'DOWN'.            "다운로드
      PERFORM DOWNLOAD_DATA.

    WHEN 'RFSH'.            "Refresh
      CASE GV_TRTYP.
        WHEN 'H'.           "생성
          PERFORM GET_ORDER_DATA.

        WHEN OTHERS.       "변경/조회
          PERFORM GET_DELIVERY_REQ_DATA.

      ENDCASE.

    WHEN 'ASEL' OR 'DSEL'.  "전체선택/해제
      PERFORM SELECT_ALL.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_SAVE.
    WHEN 'CHNG'.     "변경
      PERFORM CHANGE_DELIVERY_INFO.

    WHEN 'ACPT'.     "선적접수
      PERFORM SHIPMENT_ACCEPT USING 'X'.

    WHEN 'CNAC'.     "선적접수 취소
      PERFORM SHIPMENT_ACCEPT USING ' '.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_POST_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_POST_CODE INPUT.

  CHECK GS_DELV-POST_CODE1 IS NOT INITIAL.

  PERFORM CHECK_POST_CODE_NEW USING GS_DELV-POST_CODE1.

*  IF GS_DELV-POST_CODE1 IS INITIAL.
*    IF GT_MAIN-TRADE <> 'E'.
*      CLEAR : GS_DELV-LZONE.
*    ENDIF.
*  ELSE.
*    PERFORM CHECK_POST_CODE USING GS_DELV-POST_CODE1
*                                  GS_DELV-LZONE
*                                  'E'
*                                  ' '.
*  ENDIF.

ENDMODULE.                 " CHECK_POST_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TRANSPORT_ZONE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TRANSPORT_ZONE INPUT.

  PERFORM CHECK_TRANSPORT_ZONE.

ENDMODULE.                 " CHECK_TRANSPORT_ZONE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_POST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_POST INPUT.

  PERFORM F4HELP_POST USING GS_DELV-POST_CODE1.

ENDMODULE.                 " F4HELP_POST  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE OK_SAVE.
    WHEN 'CONT'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EDATU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EDATU INPUT.

  IF GV_EDATU IS NOT INITIAL AND GV_EDATU < SY-DATLO.
    MESSAGE E004 WITH '납품일에 과거일자를'
                      '입력할 수 없습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EDATU  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VHCTP_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_VHCTP_DESC INPUT.

  PERFORM GET_VHCTP_DESC USING GS_DELV-VHCTP
                               GS_DELV-VHCTX.

  IF GS_DELV-VHCTP IS NOT INITIAL AND
     GS_DELV-VHCTX IS INITIAL.
    MESSAGE E004 WITH '차량제한여부 입력값을 점검하십시오.'.
  ENDIF.

ENDMODULE.                 " GET_VHCTP_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ARRIVAL_TIME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ARRIVAL_TIME INPUT.

  IF GS_DELV-ARIND IS INITIAL.
    CLEAR : GS_DELV-ARRDT, GS_DELV-ARRTM.
  ENDIF.

ENDMODULE.                 " CHECK_ARRIVAL_TIME  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_AGENT1_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_AGENT1_NAME INPUT.

*___에이전트명
  PERFORM GET_KUNNR_DESC USING GT_0406-AGENT1
                               GV_AGNNM1.

*->[가온전선]--------------------CHG S
*  IF GT_0406-AGENT1 IS NOT INITIAL AND GV_AGNNM1 IS INITIAL.
*    MESSAGE E004 WITH '에이전트' GT_0406-AGENT1
*                      '이(가) 존재하지 않습니다.'.
*  ENDIF.
*-<[가온전선]--------------------CHG E
ENDMODULE.                 " GET_AGENT1_NAME  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ABWZE_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_ABWZE_NAME INPUT.

*___대체수취인 명
  PERFORM GET_KUNNR_DESC USING GT_0406-ABWZE
                               GV_ABWNM.

*->[가온전선]--------------------CHG S
*  IF GT_0406-ABWZE IS NOT INITIAL AND GV_ABWNM IS INITIAL.
*    MESSAGE E004 WITH '대체수취인' GT_0406-ABWZE
*                      '이(가) 존재하지 않습니다.'.
*  ENDIF.
*-<[가온전선]--------------------CHG E
ENDMODULE.                 " GET_ABWZE_NAME  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  CASE SY-DYNNR.
    WHEN '0200'.
      GET CURSOR FIELD GV_CURSOR1.


    WHEN OTHERS.
      GET CURSOR FIELD GV_CURSOR2.

  ENDCASE.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DESTINATION_ADDRESS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DESTINATION_ADDRESS INPUT.

  IF GT_0406-INCO1(1) = 'D'.
    GT_0406-ADDRS = GT_MAIN-CITY1.
  ENDIF.

ENDMODULE.                 " GET_DESTINATION_ADDRESS  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_AGENT2_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_AGENT2_NAME INPUT.

*___에이전트명
  PERFORM GET_KUNNR_DESC USING GT_0406-AGENT2
                               GV_AGNNM2.

*->[가온전선]--------------------CHG S
*  IF GT_0406-AGENT2 IS NOT INITIAL AND GV_AGNNM2 IS INITIAL.
*    MESSAGE E004 WITH '에이전트' GT_0406-AGENT2
*                      '이(가) 존재하지 않습니다.'.
*  ENDIF.
*-<[가온전선]--------------------CHG E
ENDMODULE.                 " GET_AGENT2_NAME  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TRTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TRTYP INPUT.

  IF GT_0406-TRTYP1 <> 'O'.
    CLEAR : GT_0406-TRTYP2.
  ENDIF.

ENDMODULE.                 " CHECK_TRTYP  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LZONE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LZONE INPUT.
  PERFORM F4HELP_LZONE USING GS_DELV-LZONE.
ENDMODULE.
