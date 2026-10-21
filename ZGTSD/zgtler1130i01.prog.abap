*&---------------------------------------------------------------------*
*& Include          ZGTLER1130I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE OK_CODE.
    WHEN 'BACK' .
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      IF R01 = 'X' AND WA-ICON1 = ICON_GREEN_LIGHT.
        DELETE GT_ALV1 WHERE VBELN = WA-VBELN.
        REFRESH: GT_ALV2.
        CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.
        CALL METHOD GRID2->REFRESH_TABLE_DISPLAY.
      ENDIF.
      CLEAR: WA.
      SET SCREEN 0.
  ENDCASE.

  CLEAR OK_CODE.

ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND INPUT.

  CASE SY-UCOMM.
    WHEN 'VT01N'.    "당사배차
      PERFORM SAVE3.
    WHEN 'SAVE2'.    "운송사배차
      PERFORM SAVE2.
    WHEN 'REFR'.
      REFRESH: R_VBELN.
      CLEAR:GT_ALV1[],GT_ALV2[].
      PERFORM DATA_QUERY TABLES GT_ALV1
                                R_VBELN.

*--[기능개선 286869  추가
    WHEN 'REQUEST'. "배차요청(문자/메일)
      PERFORM REQUEST_CAR_DISPATCH.

*    WHEN 'MGMT1' OR 'MGMT2' .
*      PERFORM CALL_TRANACTION USING SY-UCOMM.

    WHEN 'MAP'.
      PERFORM MAPPING_DISPATCH.


    WHEN 'MSETUP'.
      CALL SCREEN '600' STARTING AT 1  1.


    WHEN 'VT01N_BDC '. "20210126 BDC자동생성추가
      PERFORM SAVE4.


*--]기능개선 286869 - 20190726


    WHEN 'NREQUEST'. " [CHM2104-0029] 비주문배차요청
      PERFORM NREQUEST_CAR_DISPATCH.


  ENDCASE.

ENDMODULE.                 " user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TPLNR_SH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TDLNR_SH INPUT.

  CLEAR:  *LFA1,  ZLET0107.

  SELECT SINGLE * INTO *LFA1 FROM LFA1 WHERE LIFNR EQ GS_RECEIVER-LIFNR.

  SELECT SINGLE * INTO GS_RECEIVER
    FROM ZLET0107
   WHERE LIFNR EQ GS_RECEIVER-LIFNR
     AND INACTIVE EQ SPACE.

  IF SY-SUBRC NE 0.
    CLEAR : GV_TDLNR_SH, GS_RECEIVER.
    MESSAGE S001 WITH '등록되지 않은 운송업체입니다.'.
    EXIT.
  ELSE.
    GV_TDLNR_SH_T = *LFA1-NAME1.

*    CONCATENATE GV_TDLNR_SH_T GS_RECEIVER-TEL_NO GS_RECEIVER-EMAIL
*     INTO GV_TDLNR_SH_T SEPARATED BY SPACE.

  ENDIF.

ENDMODULE.                 " F4_TPLNR_SH  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_GV_PERNR_SH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_GV_PERNR_SH INPUT.

  SELECT SINGLE ENAME INTO GV_PERNR_SH_T
    FROM PA0001 WHERE PERNR EQ GS_SENDER-PERNR AND ENDDA EQ '99991231'.

  SELECT SINGLE * INTO GS_SENDER
    FROM ZLET0106
   WHERE PERNR EQ GS_SENDER-PERNR
     AND INACTIVE EQ SPACE.

  IF SY-SUBRC NE 0.
    CLEAR : GS_SENDER, GV_PERNR_SH_T.
    MESSAGE S001 WITH '등록되지 않은 하차담당자입니다.'.
    EXIT.
  ENDIF.


ENDMODULE.                 " F4_GV_PERNR_SH  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_GV_PERNR_SH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_GV_PERNR_SH_1 INPUT.

  SELECT SINGLE ENAME INTO ZLES042-NAME
    FROM PA0001 WHERE PERNR EQ ZLES042-PERNR AND ENDDA EQ '99991231'.

  SELECT SINGLE TEL_NO INTO ZLES042-CONTACT_NO
    FROM ZLET0106A
   WHERE PERNR EQ ZLES042-PERNR
     AND INACTIVE EQ SPACE.

  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH '등록되지 않은 상차담당자입니다.'.
    EXIT.
  ENDIF.


  FIND '_' IN ZLES042-CONTACT_NO .
  IF SY-SUBRC NE 0.
    WRITE ZLES042-CONTACT_NO TO ZLES042-CONTACT_NO
    USING EDIT MASK '___-____-____'.

  ENDIF.


ENDMODULE.                    "F4_GV_PERNR_SH_1 INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_CHECK INPUT.

  IF WA-CARRIER IS INITIAL.
    CLEAR: WA-CARRIER_T.
  ELSE.
    SELECT SINGLE  NAME1 INTO WA-CARRIER_T
       FROM LFA1
    WHERE LIFNR = WA-CARRIER.
    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH
      '존재하지 않는 운송사코드입니다'.
    ENDIF.
  ENDIF.

  IF WA-INCO1 IS INITIAL.
    CLEAR: WA-INCO1_T.
  ELSE.
    SELECT SINGLE  BEZEI INTO WA-INCO1_T
      FROM TINCT
     WHERE SPRAS = SY-LANGU
    AND INCO1 = WA-INCO1.
    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH
      '존재하지 않는 인도조건입니다'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " INPUT_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_NEMIX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_NEMIX INPUT.

  PERFORM F4_NEMIX USING WA-NEMIX.

ENDMODULE.                 " F4_NEMIX  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_check_300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_CHECK_300 INPUT.

  IF WA-TPLST IS INITIAL.
    CLEAR: WA-TPLST_T.
  ELSE.
    SELECT SINGLE  BEZEI INTO WA-TPLST_T
       FROM TTDST
    WHERE TPLST = WA-TPLST.
    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 운송계획지점입니다'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " input_check_300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_400 INPUT.

  CASE OK_CODE.

*--[기능개선 286869  추가
    WHEN 'SEND_MSG' OR 'SEND_RE'.
      PERFORM SEND_MSG_TO_TDLNR.

*--]기능개선 286869 - 20190726

*--[기능개선 290903  추가
    WHEN 'MAP_VLN'.
      PERFORM MAPPING_VBELN.

    WHEN 'ENTER3'.
      PERFORM GET_DATA_ALV3_NO_VBELN.

    WHEN 'MAP_CAN'.
      PERFORM MAPPING_CANCEL.

    WHEN 'SEND_CAN'.  "전송취소
      PERFORM CANCEL_MSG_TO_TDLNR.

*--]기능개선 290903


*--[기능개선 304309 첨부파일기능 추가
    WHEN 'ATT'.
      IF SY-DYNNR EQ '0500'.
        CLEAR GT_ALV3-ATTACH_KEY.
        PERFORM GET_LINE_ALV3.
        CHECK GT_ALV3-ATTACH_KEY IS NOT INITIAL.
      ENDIF.
      PERFORM SET_ATTACHMENT.

*      PERFORM ATTACH_TO_MAIL_A .

*--} 기능개선 304309 첨부파일기능

    WHEN 'PREVIEW'.
      PERFORM PRINT_JOB_ORD.

    WHEN 'JOB_ORDER'.
      PERFORM SET_JOB_ORDER_INIT.


    WHEN 'ENTER4'. "[CHM2104-0029] 운송경로등록
      GF_ZROUTE = GC_X.
      PERFORM SET_FUNTIONCODE USING 'ENTER'.

    WHEN 'DELETE4'. "[CHM2104-0029] 운송경로삭제
      PERFORM DELETE_ZROUTE_TO_ALV3.


    WHEN 'GATING'. "[CHM2104-0029] 기타통문생성
      PERFORM CREATE_GATING_DOCUMENT.


    WHEN 'EXEC9'."[CHM2104-0029] 통문매핑조회
      PERFORM EXEC_SEARCH_0900 .

    WHEN 'ENTER9'. "[CHM2104-0029]통문매핑선택(업데이트)
      PERFORM UPDATE_ZLET0005.

    WHEN 'APPRQ'. "[CHM2106-00116]1회성 운송비 승인요청
      GF_APPRQ = GC_X.
      PERFORM SET_FUNTIONCODE USING 'ENTER'.
  ENDCASE.

  CLEAR OK_CODE.

ENDMODULE.                 " USER_COMMAND_400  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0600 INPUT.

  CASE OK_CODE.

    WHEN 'MGMT1'.
      CALL TRANSACTION 'ZLEV0106'.
    WHEN 'MGMT2'.
      CALL TRANSACTION 'ZLEV0107'.

    WHEN 'MGMT3'.
      CALL TRANSACTION 'ZLET0108B'.

    WHEN 'MGMT4'.
      CALL TRANSACTION 'ZLEV0108C'.

    WHEN 'MGMT5'.
      CALL TRANSACTION 'ZLEV0110'.


  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZDEPARTURE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE  GET_ZDEPARTURET INPUT.

  IF ZLET0210-ZDEPARTURE IS NOT INITIAL.
    SELECT SINGLE TEXT1 INTO  ZLET0210-ZDEPARTURET
      FROM ZLET0212
      WHERE AREA EQ  ZLET0210-ZDEPARTURE.
    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '존재하지 않는 출발지입니다.'.
      CLEAR ZLET0210-ZDEPARTURET.
    ENDIF.
  ELSE.
    CLEAR ZLET0210-ZDEPARTURET.
  ENDIF.
ENDMODULE.                 " F4_ZDEPARTURE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZARRIVAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE  GET_ZARRIVALT INPUT.

  IF ZLET0210-ZARRIVAL IS NOT INITIAL.
    SELECT SINGLE TEXT1 INTO  ZLET0210-ZARRIVALT
      FROM ZLET0212
      WHERE AREA EQ  ZLET0210-ZARRIVAL.
    IF SY-SUBRC NE 0.
      MESSAGE S001 WITH '존재하지 않는 도착지입니다.'.
      CLEAR ZLET0210-ZARRIVALT.
    ENDIF.
  ELSE.
    CLEAR ZLET0210-ZARRIVALT.
  ENDIF.

ENDMODULE.                 " F4_ZARRIVAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4-TRK_TON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TRK_TONT INPUT.

  PERFORM GET_TRK_TONT.

ENDMODULE.                 " F4-TRK_TON  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_ROUTE_VALUE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ROUTE_VALUE INPUT.


  DATA : LV_LENGTH TYPE I.

  IF GF_SPOT IS INITIAL.
    PERFORM SET_ROUTE_VALUE .
  ELSE. "1회성단가
    PERFORM SET_SPOT_ROUTE_VALUE.
  ENDIF.
ENDMODULE.                 " SET_ROUTE_VALUE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZROUTE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZROUTE INPUT.

  GF_ZROUTE_F4 = GC_X.
* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.



ENDMODULE.                 " F4_ZROUTE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ZROUTE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_ZROUTE INPUT.

  CHECK ZLET0210-ZROUTE IS NOT  INITIAL AND
        GF_SPOT IS INITIAL.

  SELECT SINGLE *
    FROM ZLET0210
   WHERE ZROUTE     EQ  ZLET0210-ZROUTE
     AND DATAB      LE  SY-DATUM
     AND DATBI      GE  SY-DATUM
     AND CHK_INACT  EQ  SPACE
     AND ( ( CHK_SPOT EQ SPACE AND ESTAT EQ 'Y' )  OR
             CHK_SPOT NE SPACE ) .

  IF SY-SUBRC NE 0.
    MESSAGE  S001 WITH '존재하지않는 운송경로입니다.'.
    EXIT.
  ENDIF.


  GV_TRK_TONT = ZLET0210-TRK_TONT.

ENDMODULE.                 " GET_ZROUTE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZDEPARTURE_ENT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZDEPARTURE INPUT.

  GF_ZDEPARTURE_F4 = GC_X.

* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.


ENDMODULE.                 " F4_ZDEPARTURE_ENT  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ZARRIVAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ZARRIVAL INPUT.

  GF_ZARRIVAL_F4 = GC_X.

* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.


ENDMODULE.                 " F4_ZARRIVAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TRK_TON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TRK_TON INPUT.


  GF_TRK_TON_F4 = GC_X.

* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTER'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.


ENDMODULE.                 " F4_TRK_TON  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_GV_PERNR_PG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_GV_PERNR_PG INPUT.

  CLEAR : GV_ENAME_PG.

  SELECT SINGLE ENAME INTO GV_ENAME_PG
    FROM PA0001
   WHERE PERNR EQ GV_PERNR_PG
     AND ( BEGDA <= SY-DATUM  AND  ENDDA >= SY-DATUM  ).


ENDMODULE.                 " F4_GV_PERNR_PG  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  OK_SAVE = OK_CODE.
  CLEAR OK_CODE.

  CASE OK_SAVE.
    WHEN 'ZOK' OR 'ZCANC'.
      PERFORM INIT_CONTROLS_9000.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
