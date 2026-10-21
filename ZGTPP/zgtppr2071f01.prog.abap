*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP
    FROM ZGTPPT2130 AS A
    WHERE A~WERKS EQ @P_WERKS
      AND A~spgcd EQ @P_SPGCD
      AND A~arbpl IN @S_ARBPL
      AND A~nopnm IN @S_NOPNM
      AND A~OPTYPE IN @S_OPTYP
      AND ( A~DATUV <= @S_DATUV-LOW AND A~DATUB >= @S_DATUV-HIGH )
       OR ( A~DATUV >= @S_DATUV-LOW AND A~DATUB <= @S_DATUV-HIGH )
       OR ( A~DATUV <= @S_DATUV-LOW AND A~DATUB >= @S_DATUV-HIGH )
    .

  SORT GT_DISP BY WERKS SPGCD.


  IF GT_DISP[] IS NOT INITIAL.
    SELECT A~WERKS,  A~ARBPL,  B~KTEXT
      INTO CORRESPONDING FIELDS OF TABLE @GT_CRHD
      FROM CRHD AS A INNER JOIN CRTX AS B
                     ON A~OBJTY =  B~OBJTY
                     AND A~OBJID = B~OBJID
                     AND A~OBJTY = 'A'
      FOR ALL ENTRIES IN @GT_DISP
     WHERE ARBPL    EQ @GT_DISP-ARBPL
       AND A~OBJTY   EQ 'A'
       AND A~WERKS   EQ @P_WERKS
       AND B~SPRAS   EQ @SY-LANGU
      .
    SORT GT_CRHD BY WERKS ARBPL.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form exit_program
*&---------------------------------------------------------------------*
FORM exit_program .

  CALL METHOD go_docking_container->free.
  CLEAR : go_docking_container, go_grid_0100.
  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_alv_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM select_alv_variant   CHANGING pv_layo TYPE disvariant-variant.

  DATA:
    ls_variant TYPE disvariant.

  ls_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = ls_variant
      i_save        = 'A'
    IMPORTING
      es_variant    = ls_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    pv_layo = ls_variant-variant.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen_value .

  IF S_DATUV[] IS INITIAL.

    S_DATUV-SIGN   = 'I'.
    S_DATUV-OPTION = 'BT'.
* 시작: 이번달 1일
    CONCATENATE SY-DATUM+0(6) '01'  INTO S_DATUV-LOW .
* 종료: 3개월후  말일
*현재일자 대비 3개월 후를 가져 온다
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '3'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_DATUV-HIGH.
* 현재일자가 속한 월의 마지막 일자를 RETURN해 줍니다.
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = S_DATUV-HIGH
      IMPORTING
        LAST_DAY_OF_MONTH = S_DATUV-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_DATUV.
  ENDIF.

  CLEAR : GT_OPTYPE[], GT_OPTYPE, GS_OPTYPE.
  GS_OPTYPE-OPTYPE  = '01'.
  GS_OPTYPE-OPTYPET = '연속 생산일'.
  GS_OPTYPE-NOPNM   = '연속 생산일'.
  APPEND GS_OPTYPE TO  GT_OPTYPE.

  GS_OPTYPE-OPTYPE  = '02'.
  GS_OPTYPE-OPTYPET = '교체 소요일'.
  GS_OPTYPE-NOPNM   = '교체 소요일'.
  APPEND GS_OPTYPE TO  GT_OPTYPE.

  GS_OPTYPE-OPTYPE  = '03'.
  GS_OPTYPE-OPTYPET = '비가동'.
  GS_OPTYPE-NOPNM   = '비가동'.
  APPEND GS_OPTYPE TO  GT_OPTYPE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_f4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_f4_ARBPL USING    PV_GONG. .

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.

*-- 설비- 작업장  F4 정보 Select
  SELECT a~WERKS,  a~ARBPL,  B~KTEXT
    FROM CRHD AS a INNER JOIN CRTX AS B
                   ON A~objty =  B~objty
                   AND A~objid = B~objid
                   AND A~objty = 'A'
   WHERE a~objty   EQ 'A'
     AND a~werks   EQ @LV_WERKS
     AND B~spras   EQ @sy-langu
    INTO TABLE @DATA(lt_ifno).

  SORT lt_ifno BY WERKS ARBPL KTEXT.

  DELETE ADJACENT DUPLICATES FROM lt_ifno
                  COMPARING  WERKS ARBPL KTEXT.

  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'CRHD'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  PERFORM get_fieldinfo             USING    'CRTX'
                                             'KTEXT'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 0139
                      offset   = 001164
                      reptext  = '작업장명'

                    ).

  APPEND ls_field TO LT_FIELDS.

  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = '플랜트'.
        <LS_FIELD>-SCRTEXT_M = '플랜트'.
        <LS_FIELD>-SCRTEXT_L = '플랜트'.
        <LS_FIELD>-REPTEXT   = '플랜트'.
      WHEN 'ARBPL'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 8.
        <LS_FIELD>-SCRTEXT_S = '작업장'.
        <LS_FIELD>-SCRTEXT_M = '작업장'.
        <LS_FIELD>-SCRTEXT_L = '작업장'.
        <LS_FIELD>-REPTEXT   = '작업장'.
      WHEN 'KTEXT'.
        <LS_FIELD>-POSITION = 3.
        <LS_FIELD>-OFFSET = 24.
        <LS_FIELD>-SCRTEXT_S = '작업장명'.
        <LS_FIELD>-SCRTEXT_M = '작업장명'.
        <LS_FIELD>-SCRTEXT_L = '작업장명'.
        <LS_FIELD>-REPTEXT   = '작업장명'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.

  SORT LT_FIELDS BY POSITION.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ARBPL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '작업장리스트'
    TABLES
      VALUE_TAB       = lt_ifno
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  PV_GONG = LT_RETURN-FIELDVAL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fieldinfo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      <-- LS_FIELD
*&---------------------------------------------------------------------*
FORM get_fieldinfo  USING    pv_tabname   TYPE ddobjname
                             pv_fieldname
                    CHANGING ps_field_tab TYPE dfies.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = pv_tabname
      fieldname      = pv_fieldname
      lfieldname     = pv_fieldname
    IMPORTING
      dfies_wa       = ps_field_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynp_values_update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DYNP
*&---------------------------------------------------------------------*
FORM dynp_values_update  USING    pt_dynp  TYPE dynpread_t.

  CHECK pt_dynp[] IS NOT INITIAL.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = pt_dynp
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_OBJECT_>MT_TOOLBAR
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_toolbar  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
                  USING   PV_FUNCTION
                          PV_ICON
                          PV_TEXT
                          PV_QUICKINFO
                          PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  LS_TOOLBAR-TEXT      = PV_TEXT.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM refresh_grid  USING   PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_LAYOUT_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.                 " Layout
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.

  IF GV_DIS_MODE = 'D'.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 0.
  ELSE.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> TEXT_M01
*&      --> TEXT_M02
*&---------------------------------------------------------------------*
FORM popup_to_confirm_step  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .

  DATA : LS_ZGTPPT2130 TYPE ZGTPPT2130.
  DATA : LT_ZGTPPT2130 TYPE TABLE OF ZGTPPT2130.
  DATA : LV_VAILD_CHK(1).

  LV_VAILD_CHK = ''.
*--- 저장전 빈 ROW인지 확인 한다 ( 새로운 행 추가 인 경우 에만 해당 )
  LOOP AT GT_DISP INTO GS_DISP WHERE STATUS_VAL = 'INS'
                                  OR  STATUS_VAL = 'DEL'
                                  OR  STATUS_VAL = 'COP'.
    CASE GS_DISP-status_val.
      WHEN 'INS'.
        IF GS_DISP-ARBPL IS INITIAL     " 작업 코드가 공란인 경우
          AND GS_DISP-KTEXT IS INITIAL  " 작업장 내역이 공란인 경우
          AND GS_DISP-DATUV IS INITIAL  " 효력 시작일이 공란인 경우
          AND GS_DISP-DATUB IS INITIAL  " 효력 종료일이 공란인 경우
          AND GS_DISP-OPTYPE IS INITIAL " 가동유형이 공란인 경우.
          AND GS_DISP-OPTYPET IS INITIAL " 가동유형내역이 공란인 경우.
          AND GS_DISP-OPRDAY IS INITIAL " 소요일이 공란인 경우.
          AND GS_DISP-NOPNM IS INITIAL " 비가동내역이 공란인 경우.
          .
          GS_DISP-NULL_CHK = 'Y'.
        ENDIF.
      WHEN 'DEL'.
        IF GS_DISP-ARBPL IS INITIAL     " 작업 코드가 공란인 경우
          AND GS_DISP-KTEXT IS INITIAL  " 작업장 내역이 공란인 경우
          AND GS_DISP-DATUV IS INITIAL  " 효력 시작일이 공란인 경우
          AND GS_DISP-DATUB IS INITIAL  " 효력 종료일이 공란인 경우
*          AND GS_DISP-OPTYPE IS INITIAL " 가동유형이 공란인 경우.
*          AND GS_DISP-OPTYPET IS INITIAL " 가동유형내역이 공란인 경우.
*          AND GS_DISP-OPRDAY IS INITIAL " 소요일이 공란인 경우.
*          AND GS_DISP-NOPNM IS INITIAL " 비가동내역이 공란인 경우.
          .
          GS_DISP-NULL_CHK = 'Y'.
        ENDIF.
      WHEN 'COP'.
        IF GS_DISP-ARBPL IS INITIAL     " 작업 코드가 공란인 경우
          AND GS_DISP-KTEXT IS INITIAL  " 작업장 내역이 공란인 경우
          AND GS_DISP-DATUV IS INITIAL  " 효력 시작일이 공란인 경우
          AND GS_DISP-DATUB IS INITIAL  " 효력 종료일이 공란인 경우
*          AND GS_DISP-OPTYPE IS INITIAL " 가동유형이 공란인 경우.
*          AND GS_DISP-OPTYPET IS INITIAL " 가동유형내역이 공란인 경우.
*          AND GS_DISP-OPRDAY IS INITIAL " 소요일이 공란인 경우.
*          AND GS_DISP-NOPNM IS INITIAL " 비가동내역이 공란인 경우.
          .
          GS_DISP-NULL_CHK = 'Y'.
        ENDIF.
     ENDCASE.

     MODIFY GT_DISP FROM GS_DISP.
  ENDLOOP.
  " 빈 ROW 는 삭제 처리 한다
  DELETE GT_DISP WHERE NULL_CHK = 'Y'.

  " 저장할 행이 있는지 확인 한다
  LOOP AT GT_DISP INTO GS_DISP WHERE STATUS_VAL = 'INS'
                                 OR  STATUS_VAL = 'DEL'
                                 OR  STATUS_VAL = 'COP'
                                 OR  STATUS_VAL = 'CHA'.

    LV_VAILD_CHK = 'Y'.
    EXIT.
  ENDLOOP.

  " 빈행을 제거후 신규 저항 항목이 없을 경우
  IF LV_VAILD_CHK = ''.
   " 조회 조건 기준으로 DATA 초기화
      PERFORM get_data.
      PERFORM MODIFY_DATA.
   " 화면 리프레쉬
      PERFORM REFRESH_GRID USING GO_GRID_0100.
  ENDIF.

  " 저장할 내역이 있으면 저장 로직 진행 한다
  CHECK LV_VAILD_CHK = 'Y'.
      .
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP_TMP
    FROM ZGTPPT2130 AS A
    WHERE A~WERKS EQ @P_WERKS
      AND A~spgcd EQ @P_SPGCD
      AND A~arbpl IN @S_ARBPL
      AND A~nopnm IN @S_NOPNM
      AND A~OPTYPE IN @S_OPTYP
      .

*- 저장 Validation
  LV_VAILD_CHK = 'Y'.
  LOOP AT GT_DISP INTO GS_DISP WHERE STATUS_VAL = 'INS'
                                 OR  STATUS_VAL = 'DEL'
                                 OR  STATUS_VAL = 'COP'
                                 OR  STATUS_VAL = 'CHA'.
*--'효력 시작일 > 효력 종료일, 오류 CHECK
     IF  GS_DISP-DATUV > GS_DISP-DATUB.
        MESSAGE E003 WITH TEXT-E02. "유효하지 않은 일자가 입력되었습니다.
        LV_VAILD_CHK = 'N'.
        EXIT.
     ENDIF.

     IF GS_DISP-STATUS_VAL = 'INS' OR GS_DISP-STATUS_VAL = 'COP'.
*-- 효력일 중복 체크 key check
       READ TABLE GT_DISP_TMP INTO DATA(GS_DISP_TMP)
                              WITH KEY WERKS  = GS_DISP-WERKS
                                       SPGCD  = GS_DISP-SPGCD
                                       ARBPL  = GS_DISP-ARBPL
                                       DATUV  = GS_DISP-DATUV
                                       DATUB  = GS_DISP-DATUB
                                       OPTYPE = GS_DISP-OPTYPE
                                       .
       IF SY-SUBRC = 0.
            MESSAGE E003 WITH TEXT-E03. "중복 가동일이 입력되었습니다. 효력일을 확인하세요
            LV_VAILD_CHK = 'N'.
            EXIT.
       ENDIF.
     ENDIF.

*'가동유형 <> "03" 인 경우 소요일 필수, 입력 check
     IF GS_DISP-OPTYPE <> '03' AND  GS_DISP-OPRDAY IS INITIAL.
          MESSAGE E003 WITH TEXT-E04. "비가동 외 소요일이 입력되어야 합니다. 입력 내용을 확인하세요
          LV_VAILD_CHK = 'N'.
          EXIT.
     ENDIF.

*'가동유형 = "03" 인 경우 비가동 내역 필수, 입력 check
     IF GS_DISP-OPTYPE = '03' AND  GS_DISP-NOPNM IS INITIAL.
          MESSAGE E003 WITH TEXT-E05. "비가동 내역이 입력되지 않았습니다. 입력 내용을 확인하세요
          LV_VAILD_CHK = 'N'.
          EXIT.
     ENDIF.


  ENDLOOP.

  CHECK LV_VAILD_CHK <> 'N'.


  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '수정 내용을 저장 하시겠습니까?'(M06)
    '저장'(M07).
  IF GV_ANSWER = 'J'.
    TRY.
      LOOP AT GT_DISP INTO GS_DISP.

        CASE GS_DISP-STATUS_VAL.

          WHEN 'INS'.

            MOVE-CORRESPONDING GS_DISP TO LS_ZGTPPT2130.
            LS_ZGTPPT2130-WERKS = P_WERKS.
            LS_ZGTPPT2130-SPGCD = P_SPGCD.
            LS_ZGTPPT2130-ERDAT = SY-DATUM.
            LS_ZGTPPT2130-ERNAM = SY-UNAME.
            LS_ZGTPPT2130-AEDAT = SY-DATUM.
            LS_ZGTPPT2130-AENAM = SY-UNAME.

            MODIFY ZGTPPT2130 FROM LS_ZGTPPT2130.
            IF SY-SUBRC = 0.
              COMMIT WORK.
            ENDIF.

          WHEN 'DEL'.

            DELETE FROM ZGTPPT2130 WHERE WERKS  = GS_DISP-WERKS
                                     AND SPGCD  = GS_DISP-SPGCD
                                     AND ARBPL  = GS_DISP-ARBPL
                                     AND DATUV  = GS_DISP-DATUV
                                     AND DATUB  = GS_DISP-DATUB
                                     AND OPTYPE = GS_DISP-OPTYPE.
            IF sy-subrc = 0.
              COMMIT WORK.
            ENDIF.

          WHEN 'COP'.

            MOVE-CORRESPONDING GS_DISP TO LS_ZGTPPT2130.
            LS_ZGTPPT2130-ERDAT = SY-DATUM.
            LS_ZGTPPT2130-ERNAM = SY-UNAME.
            LS_ZGTPPT2130-AEDAT = SY-DATUM.
            LS_ZGTPPT2130-AENAM = SY-UNAME.
            MODIFY ZGTPPT2130 FROM LS_ZGTPPT2130.
            IF SY-SUBRC = 0.
              COMMIT WORK.
            ENDIF.

          WHEN 'CHA'.

            MOVE-CORRESPONDING GS_DISP TO LS_ZGTPPT2130.
            LS_ZGTPPT2130-ERDAT = GS_DISP-ERDAT.
            LS_ZGTPPT2130-ERNAM = GS_DISP-ERNAM.
            LS_ZGTPPT2130-AEDAT = SY-DATUM.
            LS_ZGTPPT2130-AENAM = SY-UNAME.
            MODIFY ZGTPPT2130 FROM LS_ZGTPPT2130.
            IF SY-SUBRC = 0.
              COMMIT WORK.
            ENDIF.

       ENDCASE.

      ENDLOOP.

* 조회 조건 기준으로 기초 DATA 조회
      PERFORM get_data.
      PERFORM MODIFY_DATA.
* 화면 리프레쉬
      PERFORM REFRESH_GRID USING GO_GRID_0100.
   CATCH CX_ROOT INTO DATA(LO_ROOT).
        MESSAGE S003 DISPLAY LIKE 'E' WITH  LO_ROOT->GET_TEXT( ).
        RETURN.
   ENDTRY.
  ELSE.
    MESSAGE S003 WITH TEXT-M16.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM alv_top_of_page  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                               PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_0100  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_NAME1 TYPE T001W-NAME1.
  DATA : LV_DESCR TYPE ZPPT0107-DESCR.

* 플랜트명
  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS
      INTO @LV_NAME1.
  ENDIF.

  CONCATENATE '플랜트 :' P_WERKS ', ' LV_NAME1 INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  CLEAR :LV_TEXT.
* SPG
  CLEAR : LV_DESCR.
  IF P_WERKS IS NOT INITIAL.
  SELECT SINGLE DESCR INTO LV_DESCR
           FROM ZPPT0107
          WHERE SPGCD EQ P_SPGCD.
  ENDIF.

  CONCATENATE 'SPG :' P_SPGCD ', ' LV_DESCR INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

*  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0100->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data .

  LOOP AT GT_DISP INTO GS_DISP.

    READ TABLE GT_CRHD INTO GS_CRHD WITH KEY WERKS = GS_DISP-WERKS
                                             ARBPL = GS_DISP-ARBPL
                                             BINARY SEARCH .
    IF SY-SUBRC = 0.
       GS_DISP-KTEXT  = GS_CRHD-KTEXT.
    ENDIF.

    READ TABLE GT_OPTYPE INTO GS_OPTYPE
               WITH KEY OPTYPE = GS_DISP-OPTYPE.
    IF SY-SUBRC = 0.
       GS_DISP-OPTYPET  = GS_OPTYPE-optypet.
    ENDIF.
    MODIFY GT_DISP FROM GS_DISP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_f4 .

  CLEAR: GS_F4, GT_F4.

  GS_F4-FIELDNAME = 'ARBPL'.
  GS_F4-REGISTER = ABAP_ON.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'OPTYPE'.
  GS_F4-REGISTER = ABAP_ON.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GO_GRID_0100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROID_ROW_ID
*&      <-- LS_DISP
*&---------------------------------------------------------------------*
FORM f4_arbpl  USING PV_INDEX
              CHANGING PS_LIST LIKE GS_DISP.

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.

*-- 설비- 작업장  F4 정보 Select
  SELECT a~WERKS,  a~ARBPL,  B~KTEXT
    FROM CRHD AS a INNER JOIN CRTX AS B
                   ON A~objty =  B~objty
                   AND A~objid = B~objid
                   AND A~objty = 'A'
   WHERE a~objty   EQ 'A'
     AND a~werks   EQ @P_WERKS
     AND B~spras   EQ @sy-langu
    INTO TABLE @DATA(lt_ifno).

  SORT lt_ifno BY WERKS ARBPL KTEXT.

  DELETE ADJACENT DUPLICATES FROM lt_ifno
                  COMPARING  WERKS ARBPL KTEXT.

  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'CRHD'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  PERFORM get_fieldinfo             USING    'CRTX'
                                             'KTEXT'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 0139
                      offset   = 001164
                      reptext  = '작업장명'

                    ).

  APPEND ls_field TO LT_FIELDS.

  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = '플랜트'.
        <LS_FIELD>-SCRTEXT_M = '플랜트'.
        <LS_FIELD>-SCRTEXT_L = '플랜트'.
        <LS_FIELD>-REPTEXT   = '플랜트'.
      WHEN 'ARBPL'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 8.
        <LS_FIELD>-SCRTEXT_S = '작업장'.
        <LS_FIELD>-SCRTEXT_M = '작업장'.
        <LS_FIELD>-SCRTEXT_L = '작업장'.
        <LS_FIELD>-REPTEXT   = '작업장'.
      WHEN 'KTEXT'.
        <LS_FIELD>-POSITION = 3.
        <LS_FIELD>-OFFSET = 24.
        <LS_FIELD>-SCRTEXT_S = '작업장명'.
        <LS_FIELD>-SCRTEXT_M = '작업장명'.
        <LS_FIELD>-SCRTEXT_L = '작업장명'.
        <LS_FIELD>-REPTEXT   = '작업장명'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.

  SORT LT_FIELDS BY POSITION.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ARBPL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '작업장리스트'
    TABLES
      VALUE_TAB       = lt_ifno
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.


  PS_LIST-ARBPL = LT_RETURN-FIELDVAL.

  READ TABLE lt_ifno INTO DATA(LS_ifno)
                      WITH KEY ARBPL = PS_LIST-ARBPL
                      BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    PS_LIST-KTEXT = LS_ifno-KTEXT.
    IF PS_LIST-STATUS IS INITIAL.
      PS_LIST-STATUS  = ICON_CHANGE.
      PS_LIST-STATUS_VAL  = 'CHA'.
    ENDIF.
    MODIFY GT_DISP FROM PS_LIST INDEX PV_INDEX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_OPTYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ROID_ROW_ID
*&      <-- LS_DISP
*&---------------------------------------------------------------------*
FORM f4_optype   USING PV_INDEX
              CHANGING PS_LIST LIKE GS_DISP.

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  SORT GT_OPTYPE BY OPTYPE.

  CLEAR LS_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME        = 'ZGTPPT2130'
    TABLES
      DFIES_TAB      = LT_FIELDS
    EXCEPTIONS
      NOT_FOUND      = 1
      INTERNAL_ERROR = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  LOOP AT LT_FIELDS ASSIGNING FIELD-SYMBOL(<LS_FIELD>).

    CASE <LS_FIELD>-FIELDNAME.

      WHEN 'OPTYPE'.
        <LS_FIELD>-POSITION = 1.
        <LS_FIELD>-OFFSET = 0.
        <LS_FIELD>-SCRTEXT_S = '가동유형'.
        <LS_FIELD>-SCRTEXT_M = '가동유형'.
        <LS_FIELD>-SCRTEXT_L = '가동유형'.
        <LS_FIELD>-REPTEXT   = '가동유형'.
      WHEN 'NOPNM'.
        <LS_FIELD>-POSITION = 2.
        <LS_FIELD>-OFFSET = 4.
        <LS_FIELD>-SCRTEXT_S = '가동유형명'.
        <LS_FIELD>-SCRTEXT_M = '가동유형명'.
        <LS_FIELD>-SCRTEXT_L = '가동유형명'.
        <LS_FIELD>-REPTEXT   = '가동유형명'.
      WHEN OTHERS.
        DELETE LT_FIELDS.
    ENDCASE.
  ENDLOOP.

  SORT LT_FIELDS BY POSITION.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'OPTYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '가동유형리스트'
    TABLES
      VALUE_TAB       = GT_OPTYPE
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.


  PS_LIST-OPTYPE = LT_RETURN-FIELDVAL.

  READ TABLE GT_OPTYPE INTO DATA(LS_OPTYPE)
                      WITH KEY OPTYPE = PS_LIST-OPTYPE
                      BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    PS_LIST-OPTYPET = LS_OPTYPE-OPTYPET.
    IF PS_LIST-STATUS IS INITIAL.
      PS_LIST-STATUS  = ICON_CHANGE.
      PS_LIST-STATUS_VAL  = 'CHA'.
    ENDIF.
    MODIFY GT_DISP FROM PS_LIST INDEX PV_INDEX.
  ENDIF.

ENDFORM.
