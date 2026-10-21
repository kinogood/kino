*&---------------------------------------------------------------------*
*& Include          ZGTMMR4320I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE GV_OKCODE.
    WHEN 'CANC' OR 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      IF SY-DYNNR = '300'.
        LEAVE TO SCREEN 0.
      ELSE.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR GV_OKCODE_SCR.
  GV_OKCODE_SCR = GV_OKCODE.

  CASE GV_OKCODE.
    WHEN 'RFRS'."새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'POST'. "입고처리
      CLEAR GV_OKCODE.
      IF P_ELC = GC_X.
        PERFORM F_POST.
      ELSEIF P_SCR = GC_X.
        PERFORM F_POST_SCR.
      ENDIF.
      PERFORM F_SET_ALV_STYLE.

    WHEN 'REVE'. "입고취소
      CLEAR GV_OKCODE.
      IF P_ELC = GC_X.
        PERFORM F_REVERSE.
      ELSEIF P_SCR = GC_X.
        PERFORM F_REVERSE_SCR.
      ENDIF.
      PERFORM F_SET_ALV_STYLE.

    WHEN 'PO'. "구매오더 조회/등록
      CLEAR GV_OKCODE.
      PERFORM F_EBELN_POP.

    WHEN 'SO'. "판매오더 조회/등록
      CLEAR GV_OKCODE.
      PERFORM F_VBELN_POP.
  ENDCASE.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDMODULE.

**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0200  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE USER_COMMAND_0200 INPUT.
*
*  CASE GV_OKCODE.
*    WHEN 'CONF'."확인
*      CLEAR GV_OKCODE.
*      PERFORM F_SET_ERFMG.
*
*  ENDCASE.
*ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK'.
      CLEAR GV_OKCODE.

      CHECK GV_ERR IS INITIAL.
      GS_SCR-ZOK = ABAP_TRUE.

      IF  GV_OKCODE_SCR = 'POST'.
        IF P_ELC = 'X'.
          PERFORM F_SET_BAPI_DATA_ELC.
        ELSEIF P_SCR = 'X'.
          PERFORM F_SET_BAPI_DATA.
        ENDIF.
      ENDIF.

      IF GV_OKCODE_SCR = 'PO'.
        PERFORM F_SET_EBELN_EBELP.
      ENDIF.

      IF GV_OKCODE_SCR = 'SO'.
        PERFORM F_SET_VBELN_POSNR.
      ENDIF.

      CLEAR : GS_SCR-EBELN, GS_SCR-EBELP,
                   GS_SCR-VBELN, GS_SCR-POSNR,
                   GS_SCR-BUDAT.

      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_EBELN_EBELP    INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_EBELN_EBELP INPUT.

  DATA: LS_SHLP   TYPE SHLP_DESCR,
        LT_RETURN TYPE TABLE OF DDSHRETVAL,
        LS_SELOPT TYPE DDSHSELOPT.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      SHLPNAME = 'MEKK'
    IMPORTING
      SHLP     = LS_SHLP.

  LOOP AT LS_SHLP-INTERFACE ASSIGNING  FIELD-SYMBOL(<FS_INTERFACE>).
    IF <FS_INTERFACE>-SHLPFIELD = 'EBELN' OR <FS_INTERFACE>-SHLPFIELD = 'EBELP'.
      <FS_INTERFACE>-VALFIELD = 'X'.
    ENDIF.

    IF <FS_INTERFACE>-SHLPFIELD = 'BUKRS'.
      <FS_INTERFACE>-VALFIELD = P_BUKRS.
    ENDIF.
  ENDLOOP.

  IF P_BUKRS IS NOT INITIAL.
    APPEND VALUE #( SHLPNAME  = 'MEKK'
                  SHLPFIELD ='BUKRS'
                  SIGN      = 'I'
                  OPTION    = 'EQ'
                  LOW       = P_BUKRS ) TO LS_SHLP-SELOPT.
  ENDIF.

  " 2. 다중 필드 리턴을 지원하는 함수를 호출
  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      SHLP       = LS_SHLP
    TABLES
      RETURN_VALUES = LT_RETURN.

  " 3. 사용자가 정상 선택(더블클릭)했을 때만 값을 추출
  IF LT_RETURN IS NOT INITIAL.
    CLEAR: GS_SCR-EBELN, GS_SCR-EBELP.

    LOOP AT LT_RETURN INTO DATA(LS_RET).
      CASE LS_RET-FIELDNAME.
        WHEN 'EBELN'.
          GS_SCR-EBELN = LS_RET-FIELDVAL. " 구매오더
        WHEN 'EBELP'.
          GS_SCR-EBELP = LS_RET-FIELDVAL. " 품목번호
      ENDCASE.
    ENDLOOP.

  IF GS_SCR-EBELN IS NOT INITIAL.
    CLEAR GV_ERR .

    READ TABLE GT_ROW INTO DATA(LS_ROW) INDEX 1.
    CHECK SY-SUBRC = 0.

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>)
    INDEX LS_ROW-ROW_ID.
    CHECK SY-SUBRC = 0.

    SELECT SINGLE KALSK
       FROM LFM1
       WHERE LIFNR EQ @<LIST>-LIFNR
            AND KALSK EQ 'FT'
       INTO @DATA(LV_EXIST).

    IF SY-SUBRC = 0.
      MESSAGE S000 WITH TEXT-E02 DISPLAY LIKE 'E'.
      GV_ERR = GC_X.
     "수입 구매오더는 수입 시스템에서 처리 가능합니다.
    ELSE.
      SELECT SINGLE INCO1
        FROM EKKO
        WHERE EBELN EQ @GS_SCR-EBELN
        INTO @DATA(LV_INCO).

        IF SY-SUBRC = 0 AND LV_INCO IS NOT INITIAL.
            MESSAGE S000 WITH TEXT-E02 DISPLAY LIKE 'E'.
            GV_ERR = GC_X.
            "수입 구매오더는 수입 시스템에서 처리 가능합니다.
        ENDIF.
    ENDIF.
  ENDIF.

    " 5. 화면(UI) 강제 새로고침
  CHECK GV_ERR IS INITIAL.
  DATA: LT_DYNPFIELDS TYPE TABLE OF DYNPREAD,
            LS_DYNPFIELD  TYPE DYNPREAD.

    LS_DYNPFIELD-FIELDNAME = 'GS_SCR-EBELN'.
    LS_DYNPFIELD-FIELDVALUE = GS_SCR-EBELN.
    APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

    LS_DYNPFIELD-FIELDNAME = 'GS_SCR-EBELP'.
    LS_DYNPFIELD-FIELDVALUE = GS_SCR-EBELP.
    APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME     = SY-CPROG
        DYNUMB     = SY-DYNNR
      TABLES
        DYNPFIELDS = LT_DYNPFIELDS
      EXCEPTIONS
        OTHERS     = 1.

  ENDIF.

ENDMODULE.

MODULE F4_VBELN_POSNR INPUT.

  CLEAR : LT_RETURN, LS_SHLP.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      SHLPNAME = 'VMVA'         " 묶음 서치 헬프 명칭
    IMPORTING
      SHLP     = LS_SHLP.

  LOOP AT LS_SHLP-INTERFACE ASSIGNING  FIELD-SYMBOL(<FS_IF>).
    IF <FS_IF>-SHLPFIELD = 'VBELN' OR <FS_IF>-SHLPFIELD = 'POSNR'.
      <FS_IF>-VALFIELD = 'X'.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      SHLP          = LS_SHLP
    TABLES
      RETURN_VALUES = LT_RETURN. "

  IF LT_RETURN IS NOT INITIAL.
    CLEAR: GS_SCR-VBELN, GS_SCR-POSNR, LS_RET.

    LOOP AT LT_RETURN INTO LS_RET.
      CASE LS_RET-FIELDNAME.
        WHEN 'VBELN'.
          GS_SCR-VBELN = LS_RET-FIELDVAL. " 판매오더
        WHEN 'POSNR'.
          GS_SCR-POSNR = LS_RET-FIELDVAL. " 품목번호
      ENDCASE.
    ENDLOOP.

    CLEAR: LT_DYNPFIELDS ,  LS_DYNPFIELD.

    LS_DYNPFIELD-FIELDNAME = 'GS_SCR-VBELN'.
    LS_DYNPFIELD-FIELDVALUE = GS_SCR-VBELN.
    APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

    LS_DYNPFIELD-FIELDNAME = 'GS_SCR-POSNR'.
    LS_DYNPFIELD-FIELDVALUE = GS_SCR-POSNR.
    APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME     = SY-CPROG
        DYNUMB     = SY-DYNNR
      TABLES
        DYNPFIELDS = LT_DYNPFIELDS
      EXCEPTIONS
        OTHERS     = 1.
  ENDIF.

ENDMODULE.
