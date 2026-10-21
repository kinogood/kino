*&---------------------------------------------------------------------*
*& Include          ZGTFIR4003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       IF SY-DYNNR = '0200'.
          LEAVE TO SCREEN 0.
       ELSE.
         PERFORM RELEASE_ALV.
         LEAVE TO SCREEN 0.
       ENDIF.

    WHEN 'EXIT'.
      IF SY-DYNNR = '0500'.
        IF GCL_GRID_TR IS BOUND.
          GCL_GRID_TR->FREE( ).
          CLEAR : GCL_GRID_TR.
        ENDIF.
        LEAVE TO SCREEN 0.

      ELSE.
        PERFORM RELEASE_ALV.
        LEAVE PROGRAM.
      ENDIF.

     WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_ERR, GV_ANSWER.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  DATA LV_MSG TYPE BAPI_MSG.
  IF SY-DYNNR = '0100'.
    PERFORM GET_SELECTED_ROWS USING GCL_GRID 'M' GV_ERR LV_MSG.
  ELSE.
    PERFORM GET_SELECTED_ROWS USING GCL_GRID_IT 'M' GV_ERR LV_MSG.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

  CASE GV_OKCODE_SAVE.
    WHEN 'RECV'.  "접수

      IF GT_ROWS IS NOT INITIAL.
         LOOP AT GT_ROWS INTO GS_ROW.
            READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.

            IF <FS>-ZCHECK = GC_X.
               MESSAGE S000 DISPLAY LIKE 'E' WITH '직송 가능 수량이 없는 요청은 접수할 수 없습니다.'(M22).
               GV_ERR = GC_X.
           ELSE.
             IF <FS> IS ASSIGNED.
               <FS>-CHECK = GC_X.
            ENDIF.
           ENDIF.
         ENDLOOP.
      ENDIF.

      CHECK GV_ERR IS INITIAL.

        IF LINE_EXISTS( GT_LIST[ CHECK = GC_X ] ).
         PERFORM POPUP_TO_CONFIRM_STEP USING 'N' '선택된 직송 요청을 접수 하시겠습니까?'(M05) '' '확인'(M09).
         CHECK GV_ANSWER = GC_J.

         PERFORM SET_LIST_SAVE  USING 'RC'.

         PERFORM GET_DATA.
         MESSAGE S000 DISPLAY LIKE 'S' WITH '접수되었습니다..'(M15).
       ELSE.
           MESSAGE S000 DISPLAY LIKE 'E' WITH '접수 대상을 선택하세요.'(M06).
       ENDIF.

    WHEN 'REJECT'.  "반려

      IF GT_ROWS IS NOT INITIAL.
         LOOP AT GT_ROWS INTO GS_ROW.
            READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS2>) INDEX GS_ROW-INDEX.

             IF <FS2> IS ASSIGNED.
               <FS2>-CHECK = GC_X.
            ENDIF.
         ENDLOOP.
      ENDIF.

       IF LINE_EXISTS( GT_LIST[ CHECK = GC_X ] ).
         PERFORM POPUP_TO_CONFIRM_STEP USING 'N' '선택된 직송 요청을 반려 하시겠습니까?'(M10) '' '확인'(M09).
         CHECK GV_ANSWER = GC_J.

         PERFORM SET_LIST_SAVE  USING 'RJ'.

          PERFORM GET_DATA.
         MESSAGE S000 DISPLAY LIKE 'S' WITH '반려되었습니다..'(M16).
       ELSE.
           MESSAGE S000 DISPLAY LIKE 'E' WITH '반려 대상을 선택하세요.'(M11).
       ENDIF.


    WHEN 'REASON'.  "반려사유 등록&반려

      IF GT_ROWS IS NOT INITIAL.
         LOOP AT GT_ROWS INTO GS_ROW.
            READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS3>) INDEX GS_ROW-INDEX.

             IF <FS3> IS ASSIGNED.
               <FS3>-CHECK = GC_X.
            ENDIF.
         ENDLOOP.
      ENDIF.

       IF LINE_EXISTS( GT_LIST[ CHECK = GC_X ] ).

         GV_QUES = '선택된 직송 요청을 반려 하시겠습니까?'(M10).
         CALL SCREEN 0200  STARTING AT 10 5  ENDING AT 50 10.

         IF GV_REASON IS NOT INITIAL.
           CLEAR GV_REASON.
         ENDIF.

          PERFORM GET_DATA.
          MESSAGE S000 DISPLAY LIKE 'S' WITH '반려되었습니다..'(M16).
       ELSE.
           MESSAGE S000 DISPLAY LIKE 'E' WITH '반려 대상을 선택하세요.'(M11).
       ENDIF.

    WHEN 'SAVE'.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.

      CASE GC_X.
        WHEN RB_RCV. "의뢰접수-반려사유 등록&반려
           PERFORM SET_LIST_SAVE  USING 'RN'.
           PERFORM GET_DATA.
           PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

        WHEN RB_MNG.  "의뢰관리-반려
           PERFORM SET_LIST_SAVE  USING 'RJT'.
           PERFORM DATA_REFRESH.
           PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
           PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

        WHEN RB_GR.     "입고처리-직송입고
          IF GV_UCOMM = 'DRGR'.
            PERFORM SET_LIST_GR .
          ELSEIF GV_UCOMM = 'GRCANC'.
            PERFORM SET_LIST_GRCANC.
          ENDIF.

          PERFORM REFRESH_TABLE USING GCL_GRID_GRIT SPACE.

        WHEN OTHERS.
      ENDCASE.

      IF RB_GR IS INITIAL.
        LV_MSG = COND #( WHEN GV_ERR IS INITIAL THEN '저장 성공'
                                       ELSE '저장 실패' ).
        MESSAGE S000 WITH LV_MSG.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
