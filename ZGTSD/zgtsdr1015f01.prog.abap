*&---------------------------------------------------------------------*
*& Include          ZGTSDR1015F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-영업조직
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 )
      TO S_VKORG.

**-유통경로
*  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
*                  LOW = GC_VTWEG_10 HIGH = GC_VTWEG_50 )
*      TO S_VTWEG.
*
**-제품군
*  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
*                  LOW = GC_SPART_3C HIGH = GC_SPART_4C )
*      TO S_SPART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
*-01. INIT OBJECTS
  PERFORM INIT_OBJECTS.

*-02. CHECK INPUT
  PERFORM CHECK_INPUT_VALUE.

*-03. SET VALUES
  PERFORM SET_VALUES.

*-04. GET DATA
  PERFORM GET_DATA.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR: GV_EDIT,
         GV_TITLE.

  REFRESH: GT_LIST,
           GR_LOEVM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .

*-VKORG+VTWEG+SPART
  PERFORM SD_ORGDATA_INPUT_CHECK.

*-권한점검
  PERFORM AUTHORIZATION_CHECK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VALUES .

*-TITLE
  GV_TITLE = TEXT-003.

  GV_EDIT = GC_X.

  READ TABLE S_VKORG INDEX 1.
  GV_VKORG = S_VKORG-LOW.

*-삭제 지시자
  IF P_DEL IS NOT INITIAL.
    CLEAR: GR_LOEVM[].

  ELSE.
    APPEND VALUE #( SIGN = 'E' OPTION = 'EQ' LOW = GC_X )
        TO GR_LOEVM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST
    FROM ZGTSDT1102
   WHERE VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
     AND SPART IN @S_SPART
     AND VKGRP IN @S_VKGRP
     AND LOEVM IN @GR_LOEVM.
  SORT GT_LIST BY VKORG VTWEG SPART VKGRP.

  CHECK GT_LIST[] IS NOT INITIAL.

*-영업그룹
  DATA(LT_TEMP) = GT_LIST[].
  SORT LT_TEMP BY VKGRP.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKGRP.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VKGRP,BEZEI
      FROM TVGRT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VKGRP EQ @LT_TEMP-VKGRP
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVGRT).
    SORT LT_TVGRT BY VKGRP.
  ENDIF.

*-지급조건
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY ZTERM.
  DELETE LT_TEMP WHERE ZTERM IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING ZTERM.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT ZTERM,TEXT1
      FROM T052U
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE ZTERM EQ @LT_TEMP-ZTERM
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_T052U).
    SORT LT_T052U BY ZTERM.

  ENDIF.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    <FS_LIST>-FLAG1 = GC_X.  "DB 존재 데이터

    "영업그룹
    IF <FS_LIST>-VKGRP IS NOT INITIAL.
      <FS_LIST>-VKGRP_TX = VALUE #( LT_TVGRT[ VKGRP = <FS_LIST>-VKGRP ]-BEZEI OPTIONAL ).
    ENDIF.

    "지급조건
    IF <FS_LIST>-ZTERM IS NOT INITIAL.
      <FS_LIST>-ZTERM_TX = VALUE #( LT_T052U[ ZTERM = <FS_LIST>-ZTERM ]-TEXT1 OPTIONAL ).
    ENDIF.

  ENDLOOP.

  SORT GT_LIST BY VKORG VTWEG SPART VKGRP ZTERM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  CALL SCREEN 100.
*  IF GT_LIST[] IS NOT INITIAL.
*    CALL SCREEN 100.
*  ELSE.
*    MESSAGE S000 WITH TEXT-M01.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDING .
  CLEAR:GT_EXCLU[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'Z1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORIZATION_CHECK .
  DATA: LV_SUBRC TYPE SY-SUBRC.

*-영업조직
  SELECT VKORG
    FROM TVKO
   WHERE VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_VKORG).
  LOOP AT LT_VKORG INTO DATA(LS_VKORG).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_1 LS_VKORG-VKORG
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S200 WITH LS_VKORG-VKORG DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDLOOP.

*-유통경로
  SELECT VTWEG
    FROM TVTW
   WHERE VTWEG IN @S_VTWEG
    INTO TABLE @DATA(LT_VTWEG).
  LOOP AT LT_VTWEG INTO DATA(LS_VTWEG).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_2 LS_VTWEG-VTWEG
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S201 WITH LS_VTWEG-VTWEG DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.

*-제품군
  SELECT SPART
    FROM TSPA
   WHERE SPART IN @S_SPART
    INTO TABLE @DATA(LT_SPART).
  LOOP AT LT_SPART INTO DATA(LS_SPART).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_3 LS_SPART-SPART
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S202 WITH LS_SPART-SPART DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.

*-영업그룹
  SELECT VKGRP
    FROM TVKGR
   WHERE VKGRP IN @S_VKGRP
    INTO TABLE @DATA(LT_VKGRP).
  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_7 LS_VKGRP-VKGRP
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S203 WITH LS_VKGRP-VKGRP DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORIZATION_CHECK_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_1
*&      --> LS_VKORG_VKORG
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
FORM AUTHORIZATION_CHECK_EXEC  USING    PV_STEP
                                        PV_VALUE
                               CHANGING PV_SUBRC.
  DATA:LV_VKORG TYPE VKORG,
       LV_VTWEG TYPE VTWEG,
       LV_SPART TYPE SPART,
       LV_VKGRP TYPE VKGRP.
  DATA:LV_TYPE(1).

  LV_TYPE = PV_STEP.

  CASE LV_TYPE.
    WHEN GC_1."영업조직
      LV_VKORG = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VKORG = LV_VKORG
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_2."유통채널
      LV_VTWEG = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VTWEG = LV_VTWEG
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_3."제품군
      LV_SPART = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_SPART = LV_SPART
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_7."영업그룹
      LV_VKGRP = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VKGRP = LV_VKGRP
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LIST
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_LINE  CHANGING PS_LIST LIKE GT_LIST.
  DATA: LV_MSG(200).

*-VKORG
  IF PS_LIST-VKORG IS INITIAL.
    PS_LIST-RSLT = GC_E.
    LV_MSG = TEXT-004.
  ENDIF.

*-VTWEG
  IF PS_LIST-VTWEG IS INITIAL.
    PS_LIST-RSLT = GC_E.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-005 }|.
    ELSE.
      LV_MSG = TEXT-005.
    ENDIF.
  ENDIF.

*-SPART
  IF PS_LIST-SPART IS INITIAL.
    PS_LIST-RSLT = GC_E.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-006 }|.
    ELSE.
      LV_MSG = TEXT-006.
    ENDIF.
  ENDIF.

*-VKGRP
  IF PS_LIST-VKGRP IS INITIAL.
    PS_LIST-RSLT = GC_E.
    CLEAR PS_LIST-VKGRP_TX.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-007 }|.
    ELSE.
      LV_MSG = TEXT-007.
    ENDIF.
  ENDIF.

*-ZTERM
  IF PS_LIST-ZTERM IS INITIAL.
    PS_LIST-RSLT = GC_E.
    CLEAR PS_LIST-ZTERM_TX.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-008 }|.
    ELSE.
      LV_MSG = TEXT-008.
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    MESSAGE S008 WITH LV_MSG INTO PS_LIST-MSG.
    EXIT.
  ENDIF.

*-VKORG+VTWEG+SPART+VKGRP
  PERFORM CHECK_SD_ORGDATA CHANGING PS_LIST.

*-ZTERM
  PERFORM CHECK_ZTERM CHANGING PS_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SD_ORGDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_LIST
*&---------------------------------------------------------------------*
FORM CHECK_SD_ORGDATA  CHANGING PS_LIST LIKE GT_LIST.
  DATA LV_MSG(200).

* TVTA: VTBER = VKORG x VTWEG x SPART
  IF NOT PS_LIST-VKORG IS INITIAL AND NOT PS_LIST-VTWEG IS INITIAL
     AND NOT PS_LIST-SPART IS INITIAL.

    SELECT SINGLE * INTO @DATA(LS_TVTA) FROM TVTA
      WHERE VKORG = @PS_LIST-VKORG
        AND VTWEG = @PS_LIST-VTWEG
        AND SPART = @PS_LIST-SPART.
    IF SY-SUBRC NE 0.
      PS_LIST-RSLT = GC_E.
      MESSAGE E115(CZ) WITH PS_LIST-VKORG PS_LIST-VTWEG PS_LIST-SPART
          INTO LV_MSG.

      EXIT.
    ENDIF.

    IF PS_LIST-VKGRP IS NOT INITIAL.
      SELECT SINGLE A~VKORG,A~VTWEG,A~SPART,A~VKBUR,
                    B~VKGRP
        FROM TVKBZ AS A INNER JOIN TVBVK AS B
                        ON A~VKBUR = B~VKBUR
       WHERE A~VKORG = @PS_LIST-VKORG
         AND A~VTWEG = @PS_LIST-VTWEG
         AND A~SPART = @PS_LIST-SPART
         AND B~VKGRP = @PS_LIST-VKGRP
        INTO @DATA(LS_LINE).
      IF SY-SUBRC NE 0.
        PS_LIST-RSLT = GC_E.
        MESSAGE S105 WITH PS_LIST-VKORG PS_LIST-VTWEG PS_LIST-SPART PS_LIST-VKGRP
            INTO LV_MSG.
        EXIT.
      ENDIF.

      "TEXT
      PS_LIST-VKGRP_TX = ZGTSD_CL_COMMON2=>GET_VKGRP_TEXT( IV_VKGRP = PS_LIST-VKGRP
                                                           IV_SPRAS = SY-LANGU     ).
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SD_ORGDATA_INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SD_ORGDATA_INPUT_CHECK .

* TVTA: VTBER = VKORG x VTWEG x SPART

  SELECT SINGLE * INTO @DATA(LS_TVTA) FROM TVTA
    WHERE VKORG IN @S_VKORG
      AND VTWEG IN @S_VTWEG
      AND SPART IN @S_SPART.
  IF SY-SUBRC NE 0.
    DATA(LV_VKORG) = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
    DATA(LV_VTWEG) = VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ).
    DATA(LV_SPART) = VALUE #( S_SPART[ 1 ]-LOW OPTIONAL ).
    MESSAGE S115(CZ) WITH LV_VKORG LV_VTWEG LV_SPART DISPLAY LIKE GC_E.

    LEAVE LIST-PROCESSING.
  ENDIF.


  SELECT SINGLE A~VKORG,A~VTWEG,A~SPART,A~VKBUR,
                B~VKGRP
    FROM TVKBZ AS A INNER JOIN TVBVK AS B
                    ON A~VKBUR = B~VKBUR
   WHERE A~VKORG IN @S_VKORG
     AND A~VTWEG IN @S_VTWEG
     AND A~SPART IN @S_SPART
     AND B~VKGRP IN @S_VKGRP
    INTO @DATA(LS_LINE).
  IF SY-SUBRC NE 0.
    LV_VKORG = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
    LV_VTWEG = VALUE #( S_VTWEG[ 1 ]-LOW OPTIONAL ).
    LV_SPART = VALUE #( S_SPART[ 1 ]-LOW OPTIONAL ).
    DATA(LV_VKGRP) = VALUE #( S_VKGRP[ 1 ]-LOW OPTIONAL ).
    MESSAGE S105 WITH LV_VKORG LV_VTWEG LV_SPART LV_VKGRP DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ZTERM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_LIST
*&---------------------------------------------------------------------*
FORM CHECK_ZTERM  CHANGING PS_LIST LIKE GT_LIST.
  DATA LV_MSG(200).


  SELECT SINGLE ZTERM
    FROM T052
   WHERE ZTERM EQ @PS_LIST-ZTERM
    INTO @DATA(LV_ZTERM).
  IF SY-SUBRC NE 0.
    PS_LIST-RSLT = GC_E.

    MESSAGE S000 WITH TEXT-M03 INTO LV_MSG.
  ELSE.
    PS_LIST-ZTERM_TX = ZGTSD_CL_COMMON2=>GET_ZTERM_TEXT( IV_ZTERM = PS_LIST-ZTERM
                                                         IV_SPRAS = SY-LANGU      ).
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    IF PS_LIST-MSG IS NOT INITIAL.
      PS_LIST-MSG = |{ PS_LIST-MSG }/{ LV_MSG }|.
    ELSE.
      PS_LIST-MSG = LV_MSG.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING    PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANGE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_CHANGE_DATA  CHANGING PS_LIST LIKE GT_LIST.

  CHECK PS_LIST-RSLT  NE GC_E.
  CHECK PS_LIST-FLAG1 EQ GC_X.

  CLEAR:GS_NEW,GS_OLD.

  MOVE-CORRESPONDING PS_LIST TO GS_NEW.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF @GS_OLD
    FROM ZGTSDT1102
   WHERE VKORG EQ @PS_LIST-VKORG
     AND VTWEG EQ @PS_LIST-VTWEG
     AND SPART EQ @PS_LIST-SPART
     AND VKGRP EQ @PS_LIST-VKGRP
     AND ZTERM EQ @PS_LIST-ZTERM.

  IF GS_NEW EQ GS_OLD.
    CLEAR: PS_LIST-FLAG2,PS_LIST-SEL.
  ELSE.
    PS_LIST-SEL   = GC_X.
    PS_LIST-FLAG2 = GC_U.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_KEY_DUPLICATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_LIST>
*&---------------------------------------------------------------------*
FORM CHECK_KEY_DUPLICATE.
  DATA: LV_CNT TYPE I.

  DATA(LT_TEMP) = GT_LIST[].



*  CHECK PS_LIST-RSLT  NE GC_E.
*  LOOP AT GT_LIST INTO DATA(LS_LIST).
*    IF LS_LIST-VKORG EQ PS_LIST-VKORG AND
*       LS_LIST-VTWEG EQ PS_LIST-VTWEG AND
*       LS_LIST-SPART EQ PS_LIST-SPART AND
*       LS_LIST-VKGRP EQ PS_LIST-VKGRP AND
*       LS_LIST-ZTERM EQ PS_LIST-ZTERM.
*      LV_CNT = LV_CNT + 1.
*    ENDIF.
*  ENDLOOP.
*
*  IF LV_CNT > 1.
*    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE VKORG EQ PS_LIST-VKORG
*                                                        AND VTWEG EQ PS_LIST-VTWEG
*                                                        AND SPART EQ PS_LIST-SPART
*                                                        AND VKGRP EQ PS_LIST-VKGRP
*                                                        AND ZTERM EQ PS_LIST-ZTERM.
*
*      <FS_LIST>-RSLT  = GC_E.
*      <FS_LIST>-STAT1 = ICON_LED_RED.
*      <FS_LIST>-MSG   = TEXT-M04.
*    ENDLOOP.
*  ELSE.
*
*    IF P_DEL IS INITIAL AND
*       PS_LIST-FLAG1 NE GC_X AND
*       PS_LIST-FLAG2 EQ GC_I.
*      SELECT SINGLE *
*        FROM ZGTSDT1102
*       WHERE VKORG EQ @PS_LIST-VKORG
*         AND VTWEG EQ @PS_LIST-VTWEG
*         AND SPART EQ @PS_LIST-SPART
*         AND VKGRP EQ @PS_LIST-VKGRP
*         AND ZTERM EQ @PS_LIST-ZTERM
*        INTO @DATA(LS_LINE).
*      IF SY-SUBRC EQ 0.
*        <FS_LIST>-RSLT  = GC_E.
*        <FS_LIST>-MSG   = TEXT-M05.
*      ENDIF.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GT_LIST.
  CASE PS_LIST-RSLT.
    WHEN GC_E.
      PS_LIST-STAT1 = ICON_LED_RED.
    WHEN OTHERS.
      CLEAR PS_LIST-STAT1.
  ENDCASE.

  CASE PS_LIST-FLAG2.
    WHEN GC_I.
      IF PS_LIST-FLAG1 EQ GC_X.
        CLEAR PS_LIST-STAT2.
      ELSE.
        PS_LIST-STAT2 = ICON_CREATE.
      ENDIF.
    WHEN GC_U.
      IF PS_LIST-FLAG1 EQ GC_X.
        PS_LIST-STAT2 = ICON_CHANGE.
      ELSE.
        CLEAR PS_LIST-STAT2.
      ENDIF.
    WHEN OTHERS.
      CLEAR PS_LIST-STAT2.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .
  DATA: LV_CNT TYPE I.

  PERFORM CHECK_CHANGED_DATA.

*-선택라인
  IF NOT ( LINE_EXISTS( GT_LIST[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.


*-오류라인
  IF LINE_EXISTS( GT_LIST[ SEL = GC_X RSLT = GC_E ] ).
    MESSAGE I000 WITH TEXT-M07 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL   EQ GC_X
                                       AND FLAG2 NE SPACE
                                       AND RSLT  NE GC_E.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.
  IF LV_CNT < 1.
    MESSAGE I000 WITH TEXT-M06 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-DB 존재건중 변경라인 미 선택
  CLEAR LV_CNT.
  LOOP AT GT_LIST INTO LS_LIST WHERE SEL   EQ SPACE
                                 AND FLAG1 EQ GC_X
                                 AND FLAG2 NE SPACE.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.
  IF LV_CNT > 0.
    MESSAGE I000 WITH TEXT-M12 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_DATA .
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-SAVE DATA
  PERFORM SAVE_DATA_PROC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA .
  DATA: LV_CNT TYPE I.
  DATA: LV_MSG(200).

*-01.중복라인 체크
  DATA(LT_TEMP1) = GT_LIST[].
  DELETE LT_TEMP1 WHERE SEL   = SPACE  "신규라인 미 선택건 제거
                    AND FLAG1 = SPACE.
  DELETE LT_TEMP1 WHERE SEL   = GC_X   "신규라인 선택건중 오류 제거
                    AND FLAG1 = SPACE
                    AND RSLT  = GC_E.
  "삭제 미포함시 DB의 삭제건도 고려.
  IF P_DEL IS INITIAL.
    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE @LT_TEMP1
      FROM ZGTSDT1102
     WHERE VKORG IN @S_VKORG
       AND VTWEG IN @S_VTWEG
       AND SPART IN @S_SPART
       AND VKGRP IN @S_VKGRP
       AND LOEVM EQ @GC_X.
  ENDIF.
  DATA(LT_TEMP2) = LT_TEMP1[].
  SORT LT_TEMP2 BY VKORG VTWEG SPART VKGRP ZTERM.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP2
    COMPARING VKORG VTWEG SPART VKGRP ZTERM.

  LOOP AT LT_TEMP2 INTO DATA(LS_TEMP2).
    CLEAR LV_CNT.
    LV_CNT = REDUCE I( INIT X = 0
                        FOR LS_LINE IN LT_TEMP1 WHERE ( VKORG = LS_TEMP2-VKORG AND
                                                        VTWEG = LS_TEMP2-VTWEG AND
                                                        SPART = LS_TEMP2-SPART AND
                                                        VKGRP = LS_TEMP2-VKGRP AND
                                                        ZTERM = LS_TEMP2-ZTERM     )
                        NEXT X = X + 1
                      ).
    IF LV_CNT > 1.
      GV_ERROR = GC_X.
      LV_MSG = |{ LS_TEMP2-VKORG }/{ LS_TEMP2-VTWEG }/{ LS_TEMP2-SPART }/{ LS_TEMP2-VKGRP }/{ LS_TEMP2-ZTERM }|.
      LV_MSG = |{ LV_MSG } { TEXT-M08 }|.
      MESSAGE I000 WITH LV_MSG(50) LV_MSG+50(50) LV_MSG+100(50) LV_MSG+150(50) DISPLAY LIKE GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.


*-02. 디폴트 설정 체크
*     영업조직/유통경로/제품군/영업그룹별
*     :디폴트 설정라인이 2개 이상인 경우,디폴트 설정라인이 없는 경우
*     => 현재 화면 리스트로 체크한다.
  CLEAR LT_TEMP1[].
  LT_TEMP1[] = GT_LIST[].
  DELETE LT_TEMP1 WHERE SEL   = SPACE  "신규라인 미 선택건 제거
                    AND FLAG1 = SPACE.
  DELETE LT_TEMP1 WHERE SEL   = GC_X   "신규라인 선택건중 오류 제거
                    AND FLAG1 = SPACE
                    AND RSLT  = GC_E.
  CLEAR: LV_CNT.
  LOOP AT LT_TEMP1 INTO DATA(LS_TEMP1) WHERE LOEVM     EQ SPACE
                                         AND ZZDEFAULT EQ GC_X.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M09 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  IF LV_CNT > 1.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M10 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA_PROC .
  DATA: LT_TABLE TYPE TABLE OF ZGTSDT1102,
        WA_TABLE TYPE ZGTSDT1102.
  DATA: LV_CNT TYPE I.
  DATA: LV_MSG(200).

*-저장 데이터 구성
  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL   EQ GC_X  "선택
                                       AND FLAG2 NE SPACE "생성/변경
                                       AND RSLT  NE GC_E. "오류 아닌건
    CLEAR WA_TABLE.
    MOVE-CORRESPONDING LS_LIST TO WA_TABLE.
    APPEND WA_TABLE TO LT_TABLE.
  ENDLOOP.
  IF LT_TABLE[] IS INITIAL.
    MESSAGE I000 WITH TEXT-M06 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-TIMESTAMP
  ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = LT_TABLE[] ).

*-저장
  MODIFY ZGTSDT1102 FROM TABLE LT_TABLE.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.

    LV_CNT = LINES( LT_TABLE[] ).
    WRITE: LV_CNT TO LV_MSG UNIT 'EA'. CONDENSE LV_MSG.
    MESSAGE I028 WITH LV_MSG DISPLAY LIKE GC_S.

    "REFRESH
    PERFORM REBUILD_LIST.

  ELSE.
    ROLLBACK WORK.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_S.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REBUILD_LIST .
  PERFORM GET_DATA.

  PERFORM CELL_ATTRIBUTES_0100.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
