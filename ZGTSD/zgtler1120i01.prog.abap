*&---------------------------------------------------------------------*
*& Include          ZGTLER1120I01
*&---------------------------------------------------------------------*
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
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' .
      IF SY-DYNNR = '0100'.
*        SET SCREEN 0.
      ELSE.
        PERFORM DEQUEUE_ALL.
*        SET SCREEN 100.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_CHK INPUT.

  MODIFY GT_LIKP INDEX  TC01-CURRENT_LINE.

ENDMODULE.                 " input_chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_date  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_DATE INPUT.

  MODIFY GT_LIKP INDEX  TC01-CURRENT_LINE.

ENDMODULE.                 " input_date  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_route  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_ROUTE INPUT.

  IF S_VSTEL-LOW <= '6000' AND S_VSTEL-LOW >= '7999'.
    PERFORM GET_ROUTE_TEXT USING  GT_LIKP-ROUTE
                         CHANGING GT_LIKP-ROUTE_T.

    MODIFY GT_LIKP INDEX  TC01-CURRENT_LINE.
  ENDIF.

ENDMODULE.                 " input_route  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_vsart1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_VSART1 INPUT.

  IF GT_LIKP-VSART = ' '.
    CLEAR: GT_LIKP-VSART_T.
  ELSE.
    SELECT SINGLE BEZEI INTO GT_LIKP-VSART_T FROM T173T
      WHERE VSART = GT_LIKP-VSART
        AND SPRAS = SY-LANGU.
    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 출하유형입니다'.
    ENDIF.
  ENDIF.

  MODIFY GT_LIKP INDEX  TC01-CURRENT_LINE.

ENDMODULE.                 " input_vsart1  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR : OK_CODE.

  CASE SAVE_OK.
    WHEN 'P_ASG'.             "품목세부사항
      CLEAR: GV_SAVE_FLAG.
      PERFORM GET_DETAIL.
      IF LV_XHUPF = 'X'.
        CALL SCREEN 200.
      ELSE.
        CALL SCREEN 300.
      ENDIF.

    WHEN 'ASCD' OR 'DSCD'.    "SORT
      PERFORM SORT_LIKP .

    WHEN 'REFR'.              "refresh
      PERFORM REFRESH.

    WHEN 'WAST'.              "출고전기
      PERFORM WAST.

    WHEN 'PICK'.
      PERFORM PICK1.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

**-- 26.09 추가배차 추가
    WHEN 'VLSP'. "추가배차 추가
      PERFORM VLSP.

**-- REFRESH
      CLEAR: GT_LIKP[], GT_LIKP, R_VBELN[], R_VBELN.
      PERFORM DATA_QUERY TABLES GT_LIKP R_VBELN.
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_ROUTE_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_ROUTE_1 INPUT.

  IF S_VSTEL-LOW <= '6000' OR S_VSTEL-LOW >= '7999'.
    PERFORM GET_ROUTE_TEXT USING  TVROT-ROUTE
                         CHANGING TVROT-BEZEI.
  ENDIF.

ENDMODULE.                 " INPUT_ROUTE_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_vsart  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_VSART INPUT.

  CLEAR: T173T-BEZEI.
  SELECT SINGLE BEZEI INTO T173T-BEZEI FROM T173T
    WHERE VSART = T173T-VSART
      AND SPRAS = SY-LANGU.

ENDMODULE.                 " input_vsart  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_chk1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_CHK1 INPUT.

  GL_LIPS-CHK = ' '.
  MODIFY GL_LIPS TRANSPORTING CHK WHERE CHK = 'X'.

  GL_LIPS-CHK = 'X'.
  MODIFY GL_LIPS TRANSPORTING CHK WHERE POSNR = GT_LIPS-POSNR.

ENDMODULE.                 " input_chk1  INPUT
*----------------------------------------------------------------------*
*  MODULE INPUT_wadat INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE INPUT_WADAT INPUT.

  CLEAR: T173T-BEZEI.
  SELECT SINGLE BEZEI INTO T173T-BEZEI FROM T173T
    WHERE VSART = T173T-VSART
      AND SPRAS = SY-LANGU.

ENDMODULE.                    "INPUT_wadat INPUT
*&---------------------------------------------------------------------*

*&      Module  input_jisiqty  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_JISIQTY INPUT.

*/ 납품가능량 > 납품지시수량
  IF GT_LIPS-LFIMG < GT_LIPS-JISIQTY.
    MESSAGE E000 WITH '지시수량이 납품가능량을 초과합니다.'.
  ENDIF.

  IF GT_LIPS-DELQTY > GT_LIPS-JISIQTY.
    MESSAGE E000 WITH '지시수량이 배치에 지정된 수량보다 적습니다'.
  ENDIF.

  IF NOT GT_LIPS-LENGTH IS INITIAL.
    GL_LIPS-FACTOR = GT_LIPS-JISIQTY / GT_LIPS-LENGTH.
  ENDIF.

  GL_LIPS-JISIQTY = GT_LIPS-JISIQTY .
  MODIFY GL_LIPS TRANSPORTING JISIQTY FACTOR
      WHERE POSNR = GT_LIPS-POSNR.

*  CLEAR: gv_jisiqty.
*  IF gt_lips-icon1 = c_icon1.    "접기일때,
*    LOOP AT gl_lips WHERE item1 = gt_lips-item1
*                      AND sub   = '2'.
*      ADD gl_lips-jisiqty  TO gv_jisiqty.
*    ENDLOOP.
*  ENDIF.

*  gl_lips-jisiqty = gt_lips-jisiqty - gv_jisiqty.
*  MODIFY gl_lips TRANSPORTING jisiqty WHERE posnr = gt_lips-posnr.

ENDMODULE.                 " input_jisiqty  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_shp_no  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_SHP_NO INPUT.

  GT_SHIP-VBELN       = GT_LIPS-VBELN.
  GT_SHIP-POSNR       = GT_LIPS-POSNR.
  GT_SHIP-SHIPPING_NO = GT_LIPS-SHIPPING_NO.
  APPEND GT_SHIP.

  GL_LIPS-SHIPPING_NO = GT_LIPS-SHIPPING_NO.
  MODIFY GL_LIPS TRANSPORTING SHIPPING_NO WHERE POSNR = GT_LIPS-POSNR.

ENDMODULE.                 " input_shp_no  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_assg-chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_ASSG-CHK INPUT.

  MODIFY GT_ASSG INDEX  TC03-CURRENT_LINE.

ENDMODULE.                 " input_assg-chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_nasg-chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_NASG-CHK INPUT.

  MODIFY GT_NASG INDEX  TC04-CURRENT_LINE.

ENDMODULE.                 " input_nasg-chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  SAVE_OK = OK_CODE.
  CASE SAVE_OK.
    WHEN 'SAVE'.
      PERFORM SAVE_200.

    WHEN 'PICKING'.
*      PERFORM picking.
      PERFORM PICKING_200.
    WHEN 'WAST1'.
      PERFORM WAST1.

    WHEN 'DELT'.
      PERFORM DELIVERY_DELETE USING 'X'.

    WHEN 'EXPD'.
      PERFORM COLLAPS_OR_EXPAND.

    WHEN 'CHK2'.
      PERFORM DISPLAY_ASSG_NASG.

    WHEN 'LEFT'.  "미지정=>지정
      PERFORM MOVE_LEFT_200 .

    WHEN 'RIGHT'. "지정=>미지정
      PERFORM MOVE_RIGHT_200.

    WHEN 'PICK2'.
      PERFORM GET_BATCH_INFO.

    WHEN 'REFR'.
      PERFORM REFRESH_DETAIL.

    WHEN 'P_MMBE'.
      PERFORM GO_MMBE.

    WHEN 'CHAR'.

    WHEN 'CO09'.
      PERFORM GO_CO09.

*{ 기능개선 145969 - 추가
    WHEN 'COPY'.
      PERFORM COPY_QUANTITY.
*} 기능개선 145969 - 추가

*    WHEN 'PICK2'.
*      SET PARAMETER ID 'VL' FIELD p_vbeln.
*      CALL TRANSACTION 'VL03N'
*                    AND SKIP  FIRST SCREEN.
  ENDCASE.

ENDMODULE.                 " user_command_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_lips_factor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_LIPS_FACTOR INPUT.

  GV_JISIQTY = GT_LIPS-LENGTH * GT_LIPS-FACTOR.
  IF GV_JISIQTY > GT_LIPS-LFIMG .
    MESSAGE E000 WITH '입력한 조장수가 너무 큽니다'.
  ELSE.
    GT_LIPS-JISIQTY = GV_JISIQTY.
    IF SY-DYNNR = '0200'.
      MODIFY GT_LIPS INDEX  TC02-CURRENT_LINE.
    ELSEIF SY-DYNNR = '0300'.
      MODIFY GT_LIPS INDEX  TC12-CURRENT_LINE.
    ENDIF.

    LOOP AT GL_LIPS WHERE                                   "sub = '1'
                       POSNR = GT_LIPS-POSNR.
      GL_LIPS-JISIQTY = GV_JISIQTY.
      GL_LIPS-FACTOR  = GT_LIPS-FACTOR.
      MODIFY GL_LIPS.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " input_lips_factor  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xassg-chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XASSG-CHK INPUT.

  MODIFY XT_ASSG INDEX  TC13-CURRENT_LINE.

ENDMODULE.                 " input_xassg-chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xassg-factor1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XASSG-FACTOR1 INPUT.

  IF XT_ASSG-FACTOR1 > XT_ASSG-FACTOR.
    MESSAGE E002 WITH '지정해제조장수가' XT_ASSG-FACTOR
                      '보다 큽니다'.
  ENDIF.
  XT_ASSG-DELQTY = XT_ASSG-LENGTH * XT_ASSG-FACTOR1.

  IF NOT XT_ASSG-LENGTH  IS INITIAL.
    PERFORM CHECK_BAESU USING XT_ASSG-DELQTY
                              XT_ASSG-LENGTH.
  ENDIF.

  XT_ASSG-CHK = 'X'.

  MODIFY XT_ASSG INDEX  TC13-CURRENT_LINE.

ENDMODULE.                 " input_xassg-factor1  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xassg-delqty  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XASSG-DELQTY INPUT.

*
  IF XT_ASSG-DELQTY > XT_ASSG-LABST.
    MESSAGE E002 WITH '지정해제수량이' XT_ASSG-LABST
                      '보다 큽니다'.
  ENDIF.

*
  IF NOT XT_ASSG-LENGTH  IS INITIAL.
    PERFORM CHECK_BAESU USING XT_ASSG-DELQTY
                              XT_ASSG-LENGTH.
  ENDIF.

  IF NOT XT_ASSG-LENGTH  IS INITIAL AND
     NOT XT_ASSG-FACTOR1 IS INITIAL.
    XT_ASSG-FACTOR1 = XT_ASSG-DELQTY / XT_ASSG-LENGTH.
  ENDIF.

  XT_ASSG-CHK = 'X'.
  MODIFY XT_ASSG INDEX  TC13-CURRENT_LINE.

ENDMODULE.                 " input_xassg-delqty  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xnasg-chk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XNASG-CHK INPUT.

  MODIFY XT_NASG INDEX  TC14-CURRENT_LINE.

ENDMODULE.                 " input_xnasg-chk  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xnasg-factor1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XNASG-FACTOR1 INPUT.

  IF XT_NASG-FACTOR1 > XT_NASG-FACTOR.
    MESSAGE E002 WITH '지정조장수가' XT_NASG-FACTOR
                      '보다 큽니다'.
  ENDIF.
  XT_NASG-DELQTY = XT_NASG-LENGTH * XT_NASG-FACTOR1.

  IF NOT XT_NASG-LENGTH  IS INITIAL.
    PERFORM CHECK_BAESU USING XT_NASG-DELQTY
                              XT_NASG-LENGTH.
  ENDIF.

  XT_NASG-CHK = 'X'.

  MODIFY XT_NASG INDEX  TC14-CURRENT_LINE.

ENDMODULE.                 " input_xnasg-factor1  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_xnasg-delqty  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_XNASG-DELQTY INPUT.

  IF XT_NASG-DELQTY > XT_NASG-LABST.
    MESSAGE E002 WITH '납품지정수가' XT_NASG-LABST
                      '보다 큽니다'.
  ENDIF.

  IF NOT XT_NASG-LENGTH  IS INITIAL.
    PERFORM CHECK_BAESU USING XT_NASG-DELQTY
                              XT_NASG-LENGTH.
  ENDIF.

  IF NOT XT_NASG-LENGTH  IS INITIAL. " AND
*     NOT xt_nasg-factor1 IS INITIAL.
    XT_NASG-FACTOR1 = XT_NASG-DELQTY / XT_NASG-LENGTH.
  ENDIF.

  XT_NASG-CHK = 'X'.

  MODIFY XT_NASG INDEX  TC14-CURRENT_LINE.

ENDMODULE.                 " input_xnasg-delqty  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  SAVE_OK = OK_CODE.
  CASE SAVE_OK.
    WHEN 'SAVE'.
      PERFORM SAVE_300.

    WHEN 'PICKING'.
      PERFORM PICKING.

    WHEN 'WAST1'.
      PERFORM WAST1.

    WHEN 'DELT'.
      PERFORM DELIVERY_DELETE USING ' '.

    WHEN 'EXPD1'.
      PERFORM COLLAPS_OR_EXPAND.

    WHEN 'CHK3'.
      PERFORM GET_XBATCH.

    WHEN 'LEFT1'.  "미지정 => 지정
      PERFORM MOVE_LEFT_300 .

    WHEN 'RIGHT1'. "지정   => 미지정
      PERFORM MOVE_RIGHT_300.

    WHEN 'REFR'.
      PERFORM REFRESH_DETAIL.

    WHEN 'P_MMBE'.
      PERFORM GO_MMBE.

*   배치 모두선택 기능 추가 by J.Y.Lee 08/07/2013 C20130805_81778
    WHEN 'P_ALL'.
      PERFORM SELECT_ALL.

    WHEN 'P_SAL'.
      PERFORM DESELECT_ALL.

* [START] CSR NO : C20080422_54645
    WHEN 'P_ASC'.
      PERFORM SORT_ASC.

    WHEN 'P_DESC'.
      PERFORM SORT_DESC.
* [END]   CSR NO : C20080422_54645

* [START] CSR NO : C20090605_68562
    WHEN 'P_BATCH'.
      PERFORM CALL_MSC2N.
      PERFORM GET_XBATCH.
* [END]   CSR NO : C20090605_68562

    WHEN 'CHAR'.

    WHEN 'CO09'.
      PERFORM GO_CO09.

    WHEN 'PICK2'.
      PERFORM GET_BATCH_INFO.

*      SET PARAMETER ID 'VL' FIELD p_vbeln.
*      CALL TRANSACTION 'VL03N'
*                    AND SKIP  FIRST SCREEN.

    WHEN 'SERNR'.
      PERFORM ASSIGN_SERNR.

*{ 기능개선 145969 - 추가
    WHEN 'COPY'.
      PERFORM COPY_QUANTITY.
*} 기능개선 145969 - 추가

    WHEN 'ZASSN'. "일괄 배치지정
      PERFORM SET_ASSIGN_BATCH_ALL_300.

  ENDCASE.


ENDMODULE.                 " user_command_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0210 INPUT.

*  save_ok = ok_code.
*  case save_ok.
*    when 'PICK2'.
*      perform get_batch_info.
*  endcase.

ENDMODULE.                 " user_command_0210  INPUT
