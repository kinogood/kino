*&---------------------------------------------------------------------*
*& Include          ZGTLER1120O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '100'.
  SET TITLEBAR  '100'.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

  CLEAR: OK_CODE, SAVE_OK.
  DESCRIBE TABLE GT_LIKP     LINES TC01-LINES.

ENDMODULE.                 " init_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_100_likp  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_100_LIKP OUTPUT.

*/ 피킹이 된것만 체크박스 OPEN
  IF GT_LIKP-KOSTK = 'A' OR
     GT_LIKP-KOSTK = 'B' OR
     GT_LIKP-CMGST = 'B' OR
     GT_LIKP-CMGST = 'C'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'GT_LIKP-CHK'.
          SCREEN-INPUT  = 0.
          SCREEN-ACTIVE = 0.
        WHEN 'GT_LIKP-ROUTE' OR
             'GT_LIKP-WADAT_IST' OR
             'GT_LIKP-VSART'.
          SCREEN-INPUT  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*{ SRM2202-09416 - s   플랜트3602시에만 자재그루핑(형식명 필드) 보여주기
  DATA : LV_WERKS LIKE LIPS-WERKS.

  SELECT SINGLE WERKS
    INTO LV_WERKS FROM TVSWZ
   WHERE VSTEL = S_VSTEL-LOW.

  IF LV_WERKS NE '3602'.
    PERFORM HIDE_TC TABLES TC01-COLS
                    USING '1'.
  ENDIF.
*} SRM2202-09416 - e

ENDMODULE.                 " pbo_100_likp  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR: S_FUNC[].
  IF GT_LIKP-CMGST = 'B' OR
     GT_LIKP-CMGST = 'C'.
    S_FUNC = 'SAVE'.
    APPEND S_FUNC.
    S_FUNC = 'PICKING'.
    APPEND S_FUNC.
    S_FUNC = 'WAST1'.
    APPEND S_FUNC.

*{ 기능개선 145969 - 추가
    S_FUNC = 'COPY'.
    APPEND S_FUNC.
*} 기능개선 145969 - 추가
  ELSE.
    IF GT_LIKP-KOSTK = 'C'.     "피킹완료: 출고전기 가능
      S_FUNC = 'PICKING'.
      APPEND S_FUNC.
    ELSEIF GT_LIKP-KOSTK = ' '. "피킹관련없음: 출고전기 가능
      S_FUNC = 'PICKING'.
      APPEND S_FUNC.
    ELSE.
*      IF p_kostk = 'C'.
      IF OK_PICKING = 'X'.
        S_FUNC = 'WAST1'.
        APPEND S_FUNC.
      ELSE.
        S_FUNC = 'PICKING'.
        APPEND S_FUNC.
        S_FUNC = 'WAST1'.
        APPEND S_FUNC.
      ENDIF.
    ENDIF.
  ENDIF.

  S_FUNC = 'CO09'.
  APPEND S_FUNC.

  SET PF-STATUS '200' EXCLUDING S_FUNC.
  SET TITLEBAR  '200'.

ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_0200 OUTPUT.

  CLEAR: SAVE_OK, OK_CODE.

  IF S_VSTEL-LOW >= '6000' AND S_VSTEL-LOW <= '7999'.

    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'TVROT-ROUTE'.
          SCREEN-REQUIRED  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
  PERFORM SET_GT_LIPS.

  DESCRIBE TABLE GT_LIPS     LINES TC02-LINES.
  DESCRIBE TABLE GT_ASSG     LINES TC03-LINES.
  DESCRIBE TABLE GT_NASG     LINES TC04-LINES.


ENDMODULE.                 " init_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_200_lips  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_200_LIPS OUTPUT.

  IF GT_LIPS-SUB = '1'.
    PERFORM MODIFY_SCREEN_SUB_1.
  ELSE.
    PERFORM MODIFY_SCREEN_SUB_2.
  ENDIF.

ENDMODULE.                 " pbo_200_lips  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_200_assg  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_200_ASSG OUTPUT.

ENDMODULE.                 " pbo_200_assg  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_200_nasg  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_200_NASG OUTPUT.

  IF GT_NASG-ICON3 = C_ICON3.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'GT_NASG-CHK'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " pbo_200_nasg  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  CLEAR: S_FUNC[].

  IF G_CHECK = 'X' AND
     ( PT_VSTEL = 'M610' OR PT_VSTEL = 'M630' ).

    MESSAGE I001 WITH '일련번호 지정이 되지 않았습니다.'.
    S_FUNC = 'WAST1'.
    APPEND S_FUNC.
  ELSE.
    S_FUNC = 'SERNR'.
    APPEND S_FUNC.
  ENDIF.
  CLEAR G_CHECK.

  IF GT_LIKP-CMGST = 'B' OR
     GT_LIKP-CMGST = 'C'.
    S_FUNC = 'SAVE'.
    APPEND S_FUNC.
    S_FUNC = 'PICKING'.
    APPEND S_FUNC.
    S_FUNC = 'WAST1'.
    APPEND S_FUNC.

*{ 기능개선 145969 - 추가
    S_FUNC = 'COPY'.
    APPEND S_FUNC.
*} 기능개선 145969 - 추가
  ELSE.
    IF GT_LIKP-KOSTK = 'C'.     "피킹완료: 출고전기 가능
      S_FUNC = 'PICKING'.
      APPEND S_FUNC.
    ELSEIF GT_LIKP-KOSTK = ' '. "피킹관련없음: 출고전기 가능
      S_FUNC = 'PICKING'.
      APPEND S_FUNC.
    ELSE.
*      IF p_kostk = 'C'.
      IF OK_PICKING = 'X'.
        S_FUNC = 'WAST1'.
        APPEND S_FUNC.
      ELSE.
        S_FUNC = 'PICKING'.
        APPEND S_FUNC.
        S_FUNC = 'WAST1'.
        APPEND S_FUNC.
      ENDIF.
    ENDIF.
  ENDIF.

  S_FUNC = 'CO09'.
  APPEND S_FUNC.

  SET PF-STATUS '200' EXCLUDING S_FUNC.
  SET TITLEBAR  '300'.

ENDMODULE.                 " status_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_0300 OUTPUT.

  CLEAR: SAVE_OK, OK_CODE.

  IF S_VSTEL-LOW >= '6000' AND S_VSTEL-LOW <= '7999'.

    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'TVROT-ROUTE'.
          SCREEN-REQUIRED  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  PERFORM SET_GT_LIPS.

  DESCRIBE TABLE GT_LIPS     LINES TC12-LINES.
  DESCRIBE TABLE XT_ASSG     LINES TC13-LINES.
  DESCRIBE TABLE XT_NASG     LINES TC14-LINES.

ENDMODULE.                 " init_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_300_xt_assg  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_300_XT_ASSG OUTPUT.
  DATA: LV_TOGGLE   TYPE I.

  IF XT_ASSG-LENGTH IS INITIAL.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'XT_ASSG-FACTOR1'.
          SCREEN-INPUT  = 0.

      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
*
*
**** ADD BY HKSEO 2019.02.13  출하지점이 M620 ~ M628 일 경우만 표시
*  IF GV_TRACTOR =  'X'.
*    LV_TOGGLE = 0.
*  ELSE.
*    LV_TOGGLE = 1.
*  ENDIF.
*
*  LOOP AT SCREEN.
*    CASE SCREEN-NAME.
*      WHEN 'XT_ASSG-ICON2'.
**        SCREEN-ACTIVE    = LV_TOGGLE.
*        SCREEN-INVISIBLE = LV_TOGGLE.
*      WHEN 'XT_ASSG-VRKME'.
**        SCREEN-ACTIVE    = LV_TOGGLE.
*        SCREEN-INVISIBLE = LV_TOGGLE.
*    ENDCASE.
**
**    IF SCREEN-GROUP1 = 'PDI'.
**      SCREEN-ACTIVE    = LV_TOGGLE.
***      SCREEN-INVISIBLE = 0.
**    ENDIF.
****
*    MODIFY SCREEN.
*  ENDLOOP.

ENDMODULE.                 " pbo_300_xt_assg  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_300_xt_nasg  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_300_XT_NASG OUTPUT.
*DATA: LV_TOGGLE   TYPE I.

  IF XT_NASG-LENGTH IS INITIAL.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'XT_NASG-FACTOR1'.
          SCREEN-INPUT  = 0.
      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
*
**** ADD BY HKSEO 2019.02.13  출하지점이 M620 ~ M628 일 경우만 표시
*  IF GV_TRACTOR =  'X'.
*    LV_TOGGLE = 0.
*  ELSE.
*    LV_TOGGLE = 1.
*  ENDIF.
*
*  LOOP AT SCREEN.
*    CASE SCREEN-NAME.
*      WHEN 'XT_NASG-ICON2'.
**        SCREEN-ACTIVE    = LV_TOGGLE.
*        SCREEN-INVISIBLE = LV_TOGGLE.
*      WHEN 'XT_ASSG-VRKME'.
**        SCREEN-ACTIVE    = LV_TOGGLE.
*        SCREEN-INVISIBLE = LV_TOGGLE.
*    ENDCASE.
**
**    IF SCREEN-GROUP1 = 'PDI'.
**      SCREEN-ACTIVE    = LV_TOGGLE.
***      SCREEN-INVISIBLE = 0.
**    ENDIF.
****
*    MODIFY SCREEN.
*  ENDLOOP.

ENDMODULE.                 " pbo_300_xt_nasg  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.

  SET PF-STATUS '210'.
  SET TITLEBAR  '210'.

ENDMODULE.                 " status_0210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_0210 OUTPUT.

  CLEAR: OK_CODE, SAVE_OK.
  DESCRIBE TABLE GT_DETL     LINES TC05-LINES.

ENDMODULE.                 " init_0210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_100_detl  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_100_DETL OUTPUT.

ENDMODULE.                 " pbo_100_detl  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC12  OUTPUT
*&---------------------------------------------------------------------*
*       기능개선 157076 - 추가
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_TC12 OUTPUT.

  IF GV_SERIAL IS INITIAL.
*___일련번호 관리하지 않는 경우 기계번호 필드 숨김
    LOOP AT TC12-COLS INTO WA_COLS.
      IF WA_COLS-SCREEN-GROUP1 = 'G11'.
        WA_COLS-SCREEN-INPUT = '0'.
        WA_COLS-INVISIBLE    = '1'.
      ENDIF.

      IF GV_TRACTOR = 'X'.
        IF WA_COLS-SCREEN-GROUP1 = 'PDI'.
          WA_COLS-SCREEN-INPUT  = '1'.
          WA_COLS-SCREEN-ACTIVE = '1'.
          WA_COLS-INVISIBLE     = '0'.
        ENDIF.
      ENDIF.

*
      MODIFY TC12-COLS FROM WA_COLS.
    ENDLOOP .
  ENDIF.
*

*->요청번호 CHM2009-00380 출하지점 M620이면 IMC필드 추가 2020.09.22
  IF GT_LIKP-VSTEL <> 'M620'.
    LOOP AT TC14-COLS INTO WA_COLS.
      IF WA_COLS-SCREEN-GROUP1 = 'IMC'.
        WA_COLS-SCREEN-INPUT = '0'.
        WA_COLS-INVISIBLE    = '1'.
        MODIFY TC14-COLS FROM WA_COLS.
      ENDIF.
    ENDLOOP.
  ENDIF.
*<-
ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC12  OUTPUT
