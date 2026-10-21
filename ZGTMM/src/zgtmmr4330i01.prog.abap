*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      MODULE  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.
*
*  PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
*                                      TEXT-M04
*                                      ''
*                                      TEXT-T01.
*  CHECK GV_ANSWER = ZGTFI_J.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
      PERFORM RELEASE_ALV.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0300 INPUT.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.

    WHEN 'BACK' OR 'CANC' OR  'EXIT'.
       LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
**&---------------------------------------------------------------------*
**&      MODULE  CHECK_BUDAT  INPUT
**&---------------------------------------------------------------------*
**       TEXT
**----------------------------------------------------------------------*
MODULE CHECK_BUDAT INPUT.

  IF GV_BUDAT IS NOT INITIAL.

*    IF SY-SUBRC <> 0.
*      MESSAGE E017.  "유효하지 않은 코드 입니다.
*    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE .
    WHEN 'REFRESH'.
      PERFORM GET_DATA.
      PERFORM SET_CELL_STYLE .

    WHEN 'LABEL'.          "라벨조회
      PERFORM LABEL_INFO_SELECT.

    WHEN 'GR'.              "입고
      PERFORM EXCUTE_GR USING 'GR'.

    WHEN 'GR_CANC'.   "입고취소
      PERFORM EXCUTE_GR USING 'GR_CANC'.

    WHEN 'DELV_FIN'.   "납품완료
      PERFORM DELIVERY_FINISH USING 'DFIN'.

    WHEN 'FIN_CANC'.  "납품완료취소
      PERFORM DELIVERY_FINISH USING 'DFCC'.

    WHEN 'DELCLOSE'. "납품문서 종결
      PERFORM UPDATE_DELCLOSE.
      PERFORM SET_CELL_STYLE .

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.
      IF GV_BUDAT IS INITIAL.
        MESSAGE S000 WITH TEXT-E07 DISPLAY LIKE 'E'.
        "전기일을 입력하세요.

      ELSE.
        IF GV_OKCODE_SAVE = 'GR'. "입고처리
*          PERFORM SET_BAPI_DATA.
          PERFORM SET_BAPI_DATA2.

        ELSEIF GV_OKCODE_SAVE = 'GR_CANC'. "입고취소
          PERFORM SET_CANC_BAPI_DATA.
        ENDIF.

        PERFORM SET_CELL_STYLE .
        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR : GV_OKCODE_SAVE2, GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'FC_Y'. "YES(입고수량 입력)
      IF LINE_EXISTS( GT_LIST_LABEL[ CHECK = GC_X ] ).

        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
        LEAVE TO SCREEN 0.

      ELSE.
        MESSAGE S000 WITH TEXT-E11 DISPLAY LIKE 'E'.
        "대상 라벨을 선택하세요.
      ENDIF.

    WHEN 'FC_C'. "입고수량초기화
      READ TABLE GT_LIST_LABEL INTO DATA(LS_LB) INDEX 1.
      IF SY-SUBRC = 0.

        SORT GT_LIST BY DELNO DELITEM.
        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>)
        WITH KEY DELNO   = LS_LB-DELNO
                       DELITEM = LS_LB-DELITEM BINARY SEARCH.
        IF SY-SUBRC = 0.
          CLEAR <FS>-ERFMG.
        ENDIF.

        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'FC_N'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
