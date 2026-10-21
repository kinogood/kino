*----------------------------------------------------------------------*
***INCLUDE ZSDR0950I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_VKBUR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_VKBUR INPUT.

  SELECT VKBUR
    INTO TABLE @DATA(LT_VALUE2)
    FROM VBAK
    WHERE VKORG = @GS_ORG-VKORG
     AND  VTWEG = @GS_ORG-VTWEG
     AND  SPART = @GS_ORG-SPART.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GS_ORG-VKBUR'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE2
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_VKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_VKGRP INPUT.

  IF GS_ORG-VKBUR IS INITIAL.
    MESSAGE S001 WITH TEXT-E28 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.

    SELECT VKGRP
      INTO TABLE @DATA(LT_VALUE3)
      FROM KNVV
       WHERE VKORG = @GS_ORG-VKORG
         AND VTWEG = @GS_ORG-VTWEG
         AND SPART = @GS_ORG-SPART
         AND VKBUR = @GS_ORG-VKBUR.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'VKGRP'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'GS_ORG-VKGRP'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_VALUE3
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
* 권한체크
  CLEAR GV_ERROR.
  PERFORM CHECK_AUTHORITY.
  CHECK GV_ERROR IS INITIAL.

  IF SY-UCOMM = 'EXE'.
    PERFORM INITIAIZATION.
    CALL SCREEN 200.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_KNUMA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_KNUMA INPUT.

  SELECT KNUMA, BOTEXT
    INTO TABLE @DATA(LT_VALUE4)
    FROM ZKONA
   WHERE VKORG EQ @GC_VKORG_6000.

  CHECK LT_VALUE4[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GV_KNUMA'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE4
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DROPBOX_KOBOG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_KOBOG INPUT.
*- 필수/자동입력 값 체크: 통화/유효기간
*- 팝업메시지 : 통화, 유통기간 필드의 값이 바뀔때 확인 메시지 창

*  DATA : LT_DYNPUPD TYPE DYNPREAD OCCURS 0 WITH HEADER LINE.
*  DATA : BEGIN OF LS_TEMP,
*           KEY(4),
*           TEXT(30),
*         END OF LS_TEMP,
*         LT_VALUE LIKE TABLE OF LS_TEMP.
*  DATA : LV_CONCATE(5).
*
*  SELECT DISTINCT A~KSCHL,   "조건유형
*                  C~VTEXT,   "내역
*                  B~KOTABNR, "조건테이블 번호
*                  D~DDTEXT,  "키조합
*                  E~KRECH    "키조합+a  조건계산유형(A:RATE/C:정액)
*    INTO TABLE @DATA(LT_VALUE5)
*    FROM T685 AS A INNER JOIN T682I AS B
*                     ON A~KOZGF = B~KOZGF
*                   INNER JOIN T685T AS C
*                     ON C~SPRAS = '3'
*                    AND A~KSCHL = C~KSCHL
*                   INNER JOIN DD02T AS D
*                    ON D~DDLANGUAGE = '3'
*                    AND D~TABNAME = B~KOTABNR
*                   INNER JOIN T685A AS E
*                    ON E~KSCHL = A~KSCHL
*    WHERE A~KSCHL = 'ZBO1'
*       OR A~KSCHL = 'ZBO2'
*       OR A~KSCHL = 'ZBO3'
*       OR A~KSCHL = 'ZBO4'
*       OR A~KSCHL = 'ZBO5'
*       OR A~KSCHL = 'ZBO6'
*       OR A~KSCHL = 'ZBO7'.
*
*  LT_VALUE = VALUE #( BASE LT_VALUE FOR LS_VALUE IN LT_VALUE5
*                     ( KEY = LS_VALUE-KSCHL
*                      TEXT = COND #( WHEN LS_VALUE-KRECH = 'A' THEN |{ LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } Rate|
*                                     WHEN LS_VALUE-KRECH = 'C' THEN |{ LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } 정액| ) ) ).
*
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'KOBOG'
*      DYNPPROG        = SY-CPROG
*      DYNPNR          = SY-DYNNR
*      DYNPROFIELD     = 'GS_HEADER-KOBOG'
*      VALUE_ORG       = 'S'
*    TABLES
*      VALUE_TAB       = LT_VALUE
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*
*  IF SY-SUBRC = 0.
*
*
*  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE SY-UCOMM.
    WHEN 'BT01'.
      CALL SCREEN 400 STARTING AT 5 2
                     ENDING AT 70 10.

    WHEN 'BT02'.
      CALL SCREEN 500  STARTING AT 10 2
                      ENDING AT 60  10.

    WHEN 'DELETE'.  "계약상태 변경 : 삭제(E)
      PERFORM DELETE_CONDITION.

    WHEN 'SAVE'.     "커미션 생성

*      IF SY-TCODE = 'ZVBO6' AND  GS_HEADER-BOSTA = ' ' .
*        PERFORM SAVE_COMMISSION_ZVBO6.
*      ELSE.
      PERFORM SAVE_COMMISSION.
*      ENDIF.

    WHEN 'LOG_DISP'.
      PERFORM GET_CHANGED_LOG.
*]-SRM2406-00779_E

*    WHEN 'APPR_REQ'. "승인요청
*      PERFORM APPR_REQ.
*
*    WHEN 'APPR_CANC'."승인요청취소
*      PERFORM APPR_CANC.
*
*    WHEN 'APPR'.   "승인
*      PERFORM APPR.
*
*    WHEN 'REJEC'.  "반려
*      PERFORM REJEC.

    WHEN 'COND'.  "조건유형 변경
*      IF ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO1 ) OR
*         ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO2 ) OR
*         ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO6 ).
*        MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.
      PERFORM CHANGE_COND.

    WHEN 'ATTC'. "파일첨부
      PERFORM ATTACHMENT.

**{ SRM2404-03220 - s  Long text 저장
*    WHEN 'LONGTXT0' OR  'LONGTXT1' OR 'LONGTXT2' OR 'LONGTXT3'.
*      PERFORM DISPLAY_LONGTEXT.
**} SRM2404-03220 - e
  ENDCASE.

  CLEAR SY-UCOMM.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CLEAR : GV_APRV_STAT.


  CLEAR : YZKONA_ITEM.
  REFRESH : YZKONA_ITEM.

*-LOCK
  IF SY-TCODE EQ 'ZGTSDR1102'.

    CALL FUNCTION 'ENQUEUE_EVKONAE'
      EXPORTING
        KNUMA          = GV_KNUMA
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      IF SY-MSGNO EQ '601'.
        MESSAGE S601(MC) WITH SY-MSGV1
        DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        MESSAGE S002 WITH GV_KNUMA '커미션이 잠금처리되었습니다.'
        DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

    ENDIF.

  ENDIF.

*_ check_1.계약상태(삭제:E)
  SELECT SINGLE BOSTA
    INTO @DATA(LV_BOSTA)
    FROM ZKONA
   WHERE KNUMA = @GV_KNUMA.
  IF LV_BOSTA = 'E'.
    IF SY-TCODE <> GC_ZVBO3.
      CLEAR LV_BOSTA.
      MESSAGE S001 WITH TEXT-E34 DISPLAY LIKE 'E'. " 삭제된 계약은 T-CODE ZVB03에서 조회 가능합니다.
      EXIT.
    ENDIF.
  ENDIF.

  CLEAR : GT_ITAB, GT_HIST, GS_ORG, GS_HEADER,
          GS_TEXT, GV_ERROR, GV_SAVE.

  IF GRID IS NOT INITIAL.

    CALL METHOD GRID->FREE.
    CALL METHOD G_CUSTOM_CONTAINER->FREE.

    CLEAR : GRID, G_CUSTOM_CONTAINER.
  ENDIF.

  SELECT SINGLE KNUMA, BOTEXT, AUSFU, WAERS,
                DATAB, DATBI,  BOSTA, ABSPZ, KOBOG
    INTO CORRESPONDING FIELDS OF @GS_HEADER
    FROM ZKONA
   WHERE KNUMA = @GV_KNUMA.

  IF GS_HEADER IS INITIAL.
    MESSAGE S001 WITH TEXT-E11 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    PERFORM SET_GS_TEXT.
  ENDIF.

  SELECT SINGLE VKORG, VTWEG,
                SPART, VKBUR,
                VKGRP
    INTO CORRESPONDING FIELDS OF @GS_ORG
    FROM ZKONA
   WHERE KNUMA = @GV_KNUMA.

  SELECT KSCHL, AUSFU, VKORG,
         VTWEG, SPART, KUNNR,
         MATNR, PRODH, INCO1,
         AUBEL, AUPOS, LOEVM,
         DATAB, DATBI, KBETR,
         KONWA, KPEIN, KMEIN,
         LOEVM AS DELETE, STAT_FLAG,

         CASE STAT_FLAG WHEN 'X' THEN '@0Y@'
                        WHEN 'D' THEN '@11@'
                        WHEN 'B' THEN '@DF@' END AS ICON
    INTO CORRESPONDING FIELDS OF TABLE @GT_HIST
    FROM ZKONA_ITEM
   WHERE KNUMA = @GV_KNUMA.


  LOOP AT GT_HIST INTO DATA(LS_HIST).

    MOVE-CORRESPONDING LS_HIST TO YZKONA_ITEM.

    PERFORM CREATE_VAKEY USING LS_HIST.

    YZKONA_ITEM-BONEM = GS_HEADER-AUSFU.
    YZKONA_ITEM-KNUMA = GS_HEADER-KNUMA.
    YZKONA_ITEM-VAKEY = GV_VAKEY.
    YZKONA_ITEM-WAERS = LS_HIST-KONWA.
    YZKONA_ITEM-KZ = 'U'.
    APPEND YZKONA_ITEM.

  ENDLOOP.

  PERFORM SET_GT_ITAB.
  PERFORM SET_GT_ITAB_STATUS.

  GS_COPY = CORRESPONDING #( GS_HEADER ).

  CALL SCREEN 200.

*  IF SY-TCODE = 'ZVBO2'    "커미션의 변경이 일어날 수 있는 tcode접속 시
*    OR SY-TCODE = 'ZVBO4'  "LOCK 걸고 확인
*    OR SY-TCODE = 'ZVBO5'
*    OR SY-TCODE = 'ZVBO6'.
*    CALL FUNCTION 'ENQUEUE_EVKONAE'
*      EXPORTING
*        KNUMA          = GV_KNUMA
*      EXCEPTIONS
*        FOREIGN_LOCK   = 1
*        SYSTEM_FAILURE = 2
*        OTHERS         = 3.
*
*    IF SY-SUBRC <> 0.
*      IF SY-MSGNO EQ '601'.
*        MESSAGE S601(MC) WITH SY-MSGV1
*        DISPLAY LIKE 'E'.
*        EXIT.
*      ELSE.
*        MESSAGE S002 WITH GV_KNUMA '커미션이 잠금처리되었습니다.'
*        DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.
*
*    ENDIF.
*
*  ENDIF.
*
**_ check_1.계약상태(삭제:E)
*  SELECT SINGLE BOSTA
*   INTO @DATA(LV_BOSTA)
*   FROM ZKONA
*   WHERE KNUMA = @GV_KNUMA.
*  IF LV_BOSTA = 'E'.
*    IF SY-TCODE <> GC_ZVBO3.
*      MESSAGE S001 WITH TEXT-E34 DISPLAY LIKE 'E'. " 삭제된 계약은 T-CODE ZVB03에서 조회 가능합니다.
*      EXIT.
*    ENDIF.
*  ELSE.
**_ check_2.승인상태 : 진행중(P),완료(C)
*    SELECT MAX( ZV4REQNO ) AS ZV4REQNO
*      INTO @DATA(LV_ZV4REQNO)
*      FROM ZSDT0630
*     WHERE VBELN = @GV_KNUMA.
*
*    SELECT SINGLE APRV_STAT
*      INTO @GV_APRV_STAT
*      FROM ZSDT0620 AS A INNER JOIN ZSDT0630 AS B
*                     ON A~ZV4REQNO = B~ZV4REQNO
*                    AND A~CON_TYPE = 'V6'
*      WHERE A~ZV4REQNO = @LV_ZV4REQNO.
**      WHERE B~VBELN = @GV_KNUMA.
*
*    IF GV_APRV_STAT IS INITIAL AND SY-SUBRC <> 0  AND LV_BOSTA <> ' '.
*      GV_APRV_STAT = 'C'.
*    ENDIF.
*
**_ check_3.승인자확인_승인요청취소
*    IF SY-TCODE = GC_ZVBO4.
*      IF GV_APRV_STAT = 'D'.
*        MESSAGE S001 WITH TEXT-E32 DISPLAY LIKE 'E'. "승인요청상태가 아닙니다.
*        EXIT.
*      ENDIF.
*
*      SELECT SINGLE A~MANDT
*        INTO @SY-MANDT
*        FROM ZSDT0620 AS A INNER JOIN ZSDT0630 AS B
*                      ON A~ZV4REQNO = B~ZV4REQNO
*                     AND A~CON_TYPE = 'V6'
*                     AND A~APRV_STAT = 'P'
*                     AND A~ZNUMC = '01'
*                     AND B~ZNUMC = '00'
*                     AND B~UNAME = @SY-UNAME
*         WHERE A~ZV4REQNO = @LV_ZV4REQNO.
**        WHERE B~VBELN = @GV_KNUMA.
*      IF SY-SUBRC <> 0.
*        MESSAGE S001 WITH TEXT-E15 DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.
*
*      SELECT SINGLE A~*
*      INTO CORRESPONDING FIELDS OF @GS_0620
*      FROM ZSDT0620 AS A INNER JOIN ZSDT0630 AS B
*                     ON A~ZV4REQNO = B~ZV4REQNO
*                    AND A~CON_TYPE = 'V6'
*                    AND A~APRV_STAT = 'P'
*                    AND A~ERNAM     = @SY-UNAME
*         WHERE A~ZV4REQNO = @LV_ZV4REQNO.
**      WHERE B~VBELN = @GV_KNUMA.
*    ENDIF.
*
**_ check_4.승인자확인_승인/반려
*    IF SY-TCODE = GC_ZVBO5.
*      SELECT SINGLE A~*
*      INTO CORRESPONDING FIELDS OF @GS_0620
*      FROM ZSDT0620 AS A INNER JOIN ZSDT0630 AS B
*                     ON A~ZV4REQNO = B~ZV4REQNO
*                    AND A~CON_TYPE = 'V6'
*                    AND A~APRV_STAT = 'P'
*                    AND A~PROG_NAM = @SY-UNAME
*         WHERE A~ZV4REQNO = @LV_ZV4REQNO.
**      WHERE B~VBELN = @GV_KNUMA.
**- S4HANA PJT_ZLSGSD3_S  관리자 조회용 로직 추가_23.11.22
*      IF SY-SUBRC <> 0 AND SY-UNAME+0(6) NE 'ZLSGSD' AND GV_ZSA1 = ' '.
*        MESSAGE S001 WITH TEXT-E16 DISPLAY LIKE 'E'.
*        EXIT.
**-> CCM : 26.12.2023 14:23:37 / ZLSGSD4
*      ELSEIF SY-UNAME+0(6)  EQ 'ZLSGSD' OR GV_ZSA1 = 'X'.
*        SELECT SINGLE A~*
*         INTO CORRESPONDING FIELDS OF @GS_0620
*         FROM ZSDT0620 AS A INNER JOIN ZSDT0630 AS B
*                       ON A~ZV4REQNO = B~ZV4REQNO
*                      AND A~CON_TYPE = 'V6'
*                      AND A~APRV_STAT = 'P'
*         WHERE A~ZV4REQNO = @LV_ZV4REQNO.
**<-
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*
*  CLEAR : GT_ITAB, GT_HIST, GS_ORG, GS_HEADER,
*          GS_TEXT, GV_ERROR, GV_SAVE.
*
*  IF GRID IS NOT INITIAL.
*
*    CALL METHOD GRID->FREE.
*    CALL METHOD G_CUSTOM_CONTAINER->FREE.
*
*    CLEAR : GRID, G_CUSTOM_CONTAINER.
*  ENDIF.
*
*  SELECT SINGLE KNUMA, BOTEXT, AUSFU, WAERS,
*                DATAB, DATBI,  BOSTA, ABSPZ, KOBOG
*    INTO CORRESPONDING FIELDS OF @GS_HEADER
*    FROM ZKONA
*   WHERE KNUMA = @GV_KNUMA.
*
*  IF GS_HEADER IS INITIAL.
*    MESSAGE S001 WITH TEXT-E11 DISPLAY LIKE 'E'.
*    EXIT.
*  ELSE.
*    PERFORM SET_GS_TEXT.
*  ENDIF.
*
*  SELECT SINGLE VKORG, VTWEG,
*                SPART, VKBUR,
*                VKGRP
*    INTO CORRESPONDING FIELDS OF @GS_ORG
*    FROM ZKONA
*   WHERE KNUMA = @GV_KNUMA.
*
*  SELECT KSCHL, AUSFU, VKORG,
*         VTWEG, SPART, KUNNR,
*         MATNR, PRODH, INCO1,
*         AUBEL, AUPOS, LOEVM,
*         DATAB, DATBI, KBETR,
*         KONWA, KPEIN, KMEIN,
*         LOEVM AS DELETE, STAT_FLAG,
*
*         CASE STAT_FLAG WHEN 'X' THEN '@0Y@'
*                        WHEN 'D' THEN '@11@'
*                        WHEN 'B' THEN '@DF@' END AS ICON
*    INTO CORRESPONDING FIELDS OF TABLE @GT_HIST
*    FROM ZKONA_ITEM
*   WHERE KNUMA = @GV_KNUMA.
*
**{ SRM2402-10021 변경Doc 관리 - s
** xzkona_item : 변경 전 저장
*  LOOP AT GT_HIST INTO DATA(LS_HIST).
*
*    MOVE-CORRESPONDING LS_HIST TO YZKONA_ITEM.
*
*    PERFORM CREATE_VAKEY USING LS_HIST.
*
*    YZKONA_ITEM-BONEM = GS_HEADER-AUSFU.
*    YZKONA_ITEM-KNUMA = GS_HEADER-KNUMA.
*    YZKONA_ITEM-VAKEY = GV_VAKEY.
*    YZKONA_ITEM-WAERS = LS_HIST-KONWA.
*    YZKONA_ITEM-KZ = 'U'.
*    APPEND YZKONA_ITEM.
*
*  ENDLOOP.
**} SRM2402-10021 - e
*
*  PERFORM SET_GT_ITAB.
*  PERFORM SET_GT_ITAB_STATUS. "S4HANA PJT25.01.2024 14:18:07
*
*  GS_COPY = CORRESPONDING #( GS_HEADER ).
*
*  CALL SCREEN 200.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  IF SY-UCOMM = 'NEXT'.

    CLEAR : GT_ITAB,GT_HIST, GS_ORG, GS_HEADER, GS_TEXT, GV_ERROR, GV_SAVE.
    IF GRID IS NOT INITIAL.
      CALL METHOD GRID->FREE.
      CALL METHOD G_CUSTOM_CONTAINER->FREE.
      CLEAR : GRID, G_CUSTOM_CONTAINER.
    ENDIF.


    SELECT SINGLE KNUMA, BOTEXT, AUSFU, WAERS, DATAB, DATBI, BOSTA, ABSPZ, KOBOG
    INTO CORRESPONDING FIELDS OF @GS_HEADER
    FROM ZKONA
    WHERE KNUMA = @GV_KNUMA.

    PERFORM SET_GS_TEXT.

    SELECT SINGLE VKORG, VTWEG, SPART, VKBUR, VKGRP
      INTO CORRESPONDING FIELDS OF @GS_ORG
      FROM ZKONA
      WHERE KNUMA = @GV_KNUMA.

    SELECT KSCHL, AUSFU, VKORG, VTWEG, SPART, KUNNR,
           MATNR, PRODH, INCO1, AUBEL, AUPOS,
           DATAB, DATBI, KBETR, KONWA, KPEIN, KMEIN
      INTO CORRESPONDING FIELDS OF TABLE @GT_HIST
      FROM ZKONA_ITEM
      WHERE KNUMA = @GV_KNUMA.

    GT_ITAB = VALUE #( FOR LS_HIST7 IN GT_HIST
                       WHERE ( KSCHL = 'ZBO1' )
                      ( CORRESPONDING #( LS_HIST7 ) ) ).

    GS_COPY = CORRESPONDING #( GS_HEADER ).

    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT2 INPUT.

  DATA  LV_ANSWER3.
  CLEAR LV_ANSWER3.

*{ ZLSGSD4 - s 외부 호출시 Back 프로그램 종료
  PERFORM DEQUEUE_KNUMA.

  IF GV_EXIT = 'X'.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
*} ZLSGSD4 - e

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_WAERS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_WAERS INPUT.
  DATA  LV_ANSWER2.
  CLEAR LV_ANSWER2.

*  IF GS_HEADER-AUSFU IS NOT INITIAL AND
*     GS_HEADER-WAERS IS NOT INITIAL.
*
*    SELECT SINGLE WAERS
*      INTO @DATA(LV_WAERS)
*      FROM KNVV
*      WHERE KUNNR = @GS_HEADER-AUSFU
*        AND VKORG = @GS_ORG-VKORG
*        AND VTWEG = @GS_ORG-VTWEG
*        AND SPART = @GS_ORG-SPART.
*    IF LV_WAERS <> GS_HEADER-WAERS.
**    IF SY-SUBRC <> 0.
*      PERFORM POPUP_CONFIRM USING '확인'
*      '고객코드에 등록한 통화와 다릅니다. 입력한 통화로 진행하시겠습니까?'
*                               LV_ANSWER2.
*      IF LV_ANSWER2 <> 1.
*        GS_HEADER-WAERS = LV_WAERS.
**      ELSE.
**        GS_HEADER-WAERS = GS_COPY-WAERS.
*      ENDIF.
*      LOOP AT GT_ITAB INTO DATA(LS_ITAB2) WHERE KONWA <> '%'.
*        LS_ITAB2-KONWA = GS_HEADER-WAERS.
*        MODIFY GT_ITAB FROM LS_ITAB2 TRANSPORTING KONWA .
*      ENDLOOP.
*
*      LOOP AT GT_HIST INTO DATA(LS_HIST3) WHERE KONWA <> '%'.
*        LS_HIST3-KONWA = GS_HEADER-WAERS.
*        MODIFY GT_HIST FROM LS_HIST3 TRANSPORTING KONWA.
*      ENDLOOP.
*      EXIT.
*    ENDIF.
*  ENDIF.

  CLEAR LV_ANSWER2.
  IF GT_HIST IS NOT INITIAL.
    PERFORM POPUP_CONFIRM USING '확인'
                       '입력한 통화을(를) 변경하시겠습니까?'
                             LV_ANSWER2.
    IF LV_ANSWER2 <> 1.
      GS_HEADER-WAERS = GS_COPY-WAERS.
    ELSE.
      GS_COPY-WAERS = GS_HEADER-WAERS.

      LOOP AT GT_ITAB INTO DATA(LS_ITAB2) WHERE KONWA <> '%'.
        LS_ITAB2-KONWA = GS_HEADER-WAERS.
        MODIFY GT_ITAB FROM LS_ITAB2 TRANSPORTING KONWA.
      ENDLOOP.

      LOOP AT GT_HIST INTO DATA(LS_HIST3) WHERE KONWA <> '%'.
        LS_HIST3-KONWA = GS_HEADER-WAERS.
        MODIFY GT_HIST FROM LS_HIST3 TRANSPORTING KONWA.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_DATBI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATBI INPUT.
*  DATA : LV_ANSWER5.
*  CLEAR : LV_ANSWER5, GV_ERROR.
*
*  PERFORM CHECK_DATBI_VALUE_VALIDATION.
*
*  IF GT_ITAB IS NOT INITIAL AND
*     GV_ERROR <> 'X'.
*    PERFORM POPUP_CONFIRM USING '확인'
*                       '입력한 유효기간을(를) 변경하시겠습니까?'
*                             LV_ANSWER5.
*    IF LV_ANSWER5 <> 1.
*      GS_HEADER-DATBI = GS_COPY-DATBI.
*    ELSE.
*      GS_COPY-DATBI = GS_HEADER-DATBI.
*
*      LOOP AT GT_ITAB INTO DATA(LS_ITAB).
*        LS_ITAB-DATBI = GS_HEADER-DATBI.
*        MODIFY GT_ITAB FROM LS_ITAB TRANSPORTING DATBI.
*      ENDLOOP.
*      LOOP AT GT_HIST INTO DATA(LS_HIST4).
*        LS_HIST4-DATBI = GS_HEADER-DATBI.
*        MODIFY GT_HIST FROM LS_HIST4 TRANSPORTING DATBI.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_DATAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATAB INPUT.
*  DATA  LV_ANSWER7.
*  CLEAR LV_ANSWER7.
*
*  IF GT_ITAB IS NOT INITIAL.
*    PERFORM POPUP_CONFIRM USING '확인'
*                       '입력한 효력시작일을(를) 변경하시겠습니까?'
*                             LV_ANSWER7.
*    IF LV_ANSWER7 <> 1.
*      GS_HEADER-DATAB = GS_COPY-DATAB.
*    ELSE.
*      GS_COPY-DATAB = GS_HEADER-DATAB.
*
*      LOOP AT GT_ITAB INTO DATA(LS_ITAB5).
*        LS_ITAB5-DATAB = GS_HEADER-DATAB.
*        MODIFY GT_ITAB FROM LS_ITAB5 TRANSPORTING DATAB.
*      ENDLOOP.
*
*      LOOP AT GT_HIST INTO DATA(LS_HIST6).
*        LS_HIST6-DATAB = GS_HEADER-DATAB.
*        MODIFY GT_HIST FROM LS_HIST6 TRANSPORTING DATAB.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_KOBOG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KOBOG INPUT.

  PERFORM CHECK_EMPTY_VALUE.

  IF GT_ITAB IS NOT INITIAL AND
     GV_ERROR = 'X'.
    IF GS_COPY-KOBOG IS INITIAL.
      GS_HEADER-KOBOG = 'ZBO1'.
    ELSE.
      GS_HEADER-KOBOG = GS_COPY-KOBOG.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BOTEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BOTEXT INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ABSPZ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ABSPZ INPUT.

  DATA : LT_DD07V TYPE TABLE OF DD07V.
  DATA : BEGIN OF LS_VALUE,
           VALUE TYPE DD07V-DOMVALUE_L,
           TEXT  TYPE DD07V-DDTEXT,
         END OF LS_VALUE,
         LT_VALUE LIKE TABLE OF LS_VALUE.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME         = 'ABSPZ'
      TEXT            = 'X'
    TABLES
      VALUES_TAB      = LT_DD07V
    EXCEPTIONS
      NO_VALUES_FOUND = 1
      OTHERS          = 2.

  IF SY-SUBRC = 0.
    LT_VALUE = VALUE #( FOR LS_DD07V IN LT_DD07V
                      ( VALUE = LS_DD07V-DOMVALUE_L
                        TEXT  = LS_DD07V-DDTEXT ) ).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'VALUE'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'GS_HEADER-ABSPZ'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_VALUE
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BOSTA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_BOSTA INPUT.

  DATA : LT_DYNPUPD TYPE DYNPREAD OCCURS 0 WITH HEADER LINE.
  CLEAR: LT_DYNPUPD, LT_DYNPUPD[], GS_TEXT-BOSTA_TX.

  SELECT SINGLE DDTEXT
   INTO @GS_TEXT-BOSTA_TX
   FROM DD07V
   WHERE DOMNAME = 'BOSTA'
     AND DDLANGUAGE = '3'
     AND DOMVALUE_L = @GS_HEADER-BOSTA.

  LT_DYNPUPD-FIELDNAME  = 'GS_TEXT-BOSTA_TX'.
  LT_DYNPUPD-FIELDVALUE =  GS_TEXT-BOSTA_TX.
  APPEND LT_DYNPUPD.

  PERFORM UPDATE TABLES LT_DYNPUPD.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_ABSPZ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_ABSPZ INPUT.

  DATA : LT_DYNPUPD2 TYPE DYNPREAD OCCURS 0 WITH HEADER LINE.
  CLEAR: LT_DYNPUPD2, LT_DYNPUPD2[], GS_TEXT-ABSPZ_TX.

  SELECT SINGLE DDTEXT
   INTO @GS_TEXT-ABSPZ_TX
   FROM DD07V
   WHERE DOMNAME = 'ABSPZ'
     AND DDLANGUAGE = '3'
     AND DOMVALUE_L = @GS_HEADER-ABSPZ.

  LT_DYNPUPD2-FIELDNAME  = 'GS_TEXT-ABSPZ_TX'.
  LT_DYNPUPD2-FIELDVALUE =  GS_TEXT-ABSPZ_TX.
  APPEND LT_DYNPUPD2.

  PERFORM UPDATE TABLES LT_DYNPUPD2.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELDS_DATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATE INPUT.

  DATA : LV_ANSWER5,
         LV_ER.
  CLEAR : LV_ANSWER5, LV_ER.

  PERFORM CHECK_DATBI_VALUE_VALIDATION USING LV_ER.

  IF GT_ITAB IS NOT INITIAL AND
     LV_ER <> 'X'.
    PERFORM POPUP_CONFIRM USING '확인'
                       '입력한 효력시작일과 유효기간으로 변경하시겠습니까?'
                             LV_ANSWER5.

    IF LV_ANSWER5 = 1.
      GS_COPY-DATAB = GS_HEADER-DATAB.
      GS_COPY-DATBI = GS_HEADER-DATBI.

      LOOP AT GT_ITAB INTO DATA(LS_ITAB).
        LS_ITAB-DATAB = GS_HEADER-DATAB.
        LS_ITAB-DATBI = GS_HEADER-DATBI.
        MODIFY GT_ITAB FROM LS_ITAB TRANSPORTING DATAB DATBI.
      ENDLOOP.

      LOOP AT GT_HIST INTO DATA(LS_HIST4).
        LS_HIST4-DATAB = GS_HEADER-DATAB.
        LS_HIST4-DATBI = GS_HEADER-DATBI.
        MODIFY GT_HIST FROM LS_HIST4 TRANSPORTING DATAB DATBI.
      ENDLOOP.

    ELSE.

      GS_HEADER-DATAB = GS_COPY-DATAB.
      GS_HEADER-DATBI = GS_COPY-DATBI.

    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_AUSFU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_AUSFU INPUT.

  DATA : LT_DYNPUPD3 TYPE DYNPREAD OCCURS 0 WITH HEADER LINE.
  DATA : LV_ANSWER6.
  DATA : LV_ERROR.
  CLEAR : LT_DYNPUPD3, LT_DYNPUPD3[], GS_TEXT-AUSFU_TX, LV_ANSWER6, LV_ERROR.

*-리베이트 수령인 유효성 확인
*  IF GS_HEADER-AUSFU IS NOT INITIAL.
*    SELECT SINGLE KUNNR, VKORG, VTWEG, SPART
*      INTO @DATA(LS_VALUE1)
*      FROM KNVV
*       WHERE KUNNR = @GS_HEADER-AUSFU
*         AND VKORG = @GS_ORG-VKORG
*         AND VTWEG = @GS_ORG-VTWEG
*         AND SPART = @GS_ORG-SPART.
*    IF SY-SUBRC <> 0.
*      MESSAGE E001 WITH TEXT-E01. "리베이트 수령인 XXXX가 영업영역 XX XX XX 에 없습니다.
*    ENDIF.
*
*    SELECT SINGLE LIFNR
*      FROM LFB1
*      INTO @DATA(LS_VALUE2)
*     WHERE LIFNR = @GS_HEADER-AUSFU
*      AND  BUKRS = @GS_ORG-VKORG.
*    IF SY-SUBRC <> 0.
*      MESSAGE E001 WITH TEXT-E03.
*    ENDIF.
*  ENDIF.

  IF GS_HEADER-AUSFU IS NOT INITIAL.
    SELECT SINGLE MANDT
      INTO @SY-MANDT
      FROM LFB1
     WHERE LIFNR = @GS_HEADER-AUSFU
      AND  BUKRS = @GS_ORG-VKORG.
    IF SY-SUBRC <> 0.
      MESSAGE E001 WITH TEXT-E01. "리베이트 수령인을 확인해 주세요.
      LV_ERROR = 'X'.
    ENDIF.

*    SELECT SINGLE MANDT
*      INTO @SY-MANDT
*      FROM KNB1
*      WHERE KUNNR = @GS_HEADER-AUSFU
*        AND BUKRS = @GS_ORG-VKORG.
*    IF SY-SUBRC <> 0.
*      MESSAGE E001 WITH TEXT-E01.
*      LV_ERROR = 'X'.
*    ENDIF.

    SELECT SINGLE MANDT
      INTO @SY-MANDT
      FROM KNVV
       WHERE KUNNR = @GS_HEADER-AUSFU
         AND VKORG = @GS_ORG-VKORG
         AND VTWEG = @GS_ORG-VTWEG
         AND SPART = @GS_ORG-SPART.
    IF SY-SUBRC <> 0.
      MESSAGE E001 WITH TEXT-E01. "리베이트 수령인을 확인해 주세요.
      LV_ERROR = 'X'.
    ENDIF.
  ENDIF.


  IF GT_ITAB IS NOT INITIAL AND
     LV_ERROR <> 'X'.
    PERFORM POPUP_CONFIRM USING '확인'
                       '입력한 리베이트 수령인을(를) 변경하시겠습니까?'
                             LV_ANSWER6.
    IF LV_ANSWER6 <> 1.
      GS_HEADER-AUSFU = GS_COPY-AUSFU.
    ELSE.
      GS_COPY-AUSFU = GS_HEADER-AUSFU.

      LOOP AT GT_ITAB INTO DATA(LS_ITAB3).
        LS_ITAB3-AUSFU = GS_HEADER-AUSFU.
        MODIFY GT_ITAB FROM LS_ITAB3 TRANSPORTING AUSFU.
      ENDLOOP.
      LOOP AT GT_HIST INTO DATA(LS_HIST5).
        LS_HIST5-AUSFU = GS_HEADER-AUSFU.
        MODIFY GT_HIST FROM LS_HIST5 TRANSPORTING AUSFU.
      ENDLOOP.
    ENDIF.
  ENDIF.


  SELECT SINGLE NAME1
    INTO @GS_TEXT-AUSFU_TX
    FROM LFA1
    WHERE LIFNR = @GS_HEADER-AUSFU.

  LT_DYNPUPD3-FIELDNAME  = 'GS_TEXT-AUSFU_TX'.
  LT_DYNPUPD3-FIELDVALUE =  GS_TEXT-AUSFU_TX.
  APPEND LT_DYNPUPD3.

  PERFORM UPDATE TABLES LT_DYNPUPD3.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT3 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : GRID2, G_CUSTOM_CONTAINER2.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_BOSTA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_BOSTA INPUT.

  DATA : BEGIN OF LS_BOSTA,
           VALUE TYPE DD07V-DOMVALUE_L,
           TEXT  TYPE DD07V-DDTEXT,
         END OF LS_BOSTA,
         LT_BOSTA_I TYPE TABLE OF DD07V,
         LT_BOSTA_O LIKE TABLE OF LS_BOSTA.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME         = 'BOSTA'
      TEXT            = 'X'
    TABLES
      VALUES_TAB      = LT_BOSTA_I
    EXCEPTIONS
      NO_VALUES_FOUND = 1
      OTHERS          = 2.

  IF SY-SUBRC = 0.

    LT_BOSTA_O = VALUE #( FOR LS_DD07V IN LT_BOSTA_I
                        ( VALUE = LS_DD07V-DOMVALUE_L
                          TEXT  = LS_DD07V-DDTEXT ) ).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'VALUE'
        DYNPPROG        = SY-CPROG
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'GS_HEADER-BOSTA'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_BOSTA_O
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BOSTA_CHANGED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BOSTA_CHANGED INPUT.

  DATA : LT_LOG           LIKE ZKONA_LOG OCCURS 0,
         LT_TEMP1         LIKE TABLE OF GS_ITAB,
         LT_TEMP2         LIKE TABLE OF GS_ITAB,
         LS_TEMP_HEADER   LIKE GS_HEADER,
         LV_LONGTEXT(300),
         LV_ANSWER.

  CLEAR : GV_LOG,    GS_LOG,
          GT_LOG,    GT_LOG[],
          LT_LOG,    LT_LOG[],
          LT_TEMP1,  LT_TEMP1[],
          LT_TEMP2,  LT_TEMP2[],
          LV_ANSWER, LV_LONGTEXT.

  CHECK SY-TCODE = 'ZVBO6'.


*- DB의 BOSTA 가져옴
  SELECT SINGLE WAERS DATAB DATBI BOSTA ABSPZ
    INTO CORRESPONDING FIELDS OF LS_TEMP_HEADER
    FROM ZKONA
    WHERE KNUMA = GS_HEADER-KNUMA.

  IF GS_HEADER-BOSTA NE LS_TEMP_HEADER-BOSTA.

*- 회계팀 변경 이력 저장용
    GV_LOG = 'X'.

    LT_TEMP1[] = GT_ITAB[].
    LT_TEMP2[] = GT_HIST[].

    CLEAR GS_ITAB.

    CASE GS_HEADER-BOSTA.

      WHEN 'B'.
        GS_ITAB-LOEVM = ' '.
        GS_ITAB-STAT_FLAG = 'Y'.
        GS_ITAB-ICON = '@2W@'.
        MODIFY GT_ITAB FROM GS_ITAB TRANSPORTING LOEVM ICON
                                        WHERE KSCHL IS NOT INITIAL.

        MODIFY GT_HIST FROM GS_ITAB TRANSPORTING LOEVM ICON
                                        WHERE KSCHL IS NOT INITIAL.

        MODIFY GT_HIST FROM GS_ITAB TRANSPORTING STAT_FLAG
                                           WHERE STAT_FLAG EQ 'D'.

        CONCATENATE '변경된 계약상태에 따라 조건 유형이'
                    '일괄 활성화 되었습니다.'
                    '불필요한 삭제 유형이 있는 경우'
                    '확인하시어 삭제 지시자 입력해주시기 바랍니다!'
                    INTO LV_LONGTEXT SEPARATED BY SPACE.

      WHEN OTHERS.
        GS_ITAB-LOEVM = 'X'.
        GS_ITAB-STAT_FLAG = 'N'.
        GS_ITAB-ICON = '@11@'.
        MODIFY GT_ITAB FROM GS_ITAB TRANSPORTING LOEVM ICON
                                    WHERE KSCHL IS NOT INITIAL.

        MODIFY GT_HIST FROM GS_ITAB TRANSPORTING LOEVM ICON
                                    WHERE KSCHL IS NOT INITIAL.

        MODIFY GT_HIST FROM GS_ITAB TRANSPORTING STAT_FLAG
                                           WHERE STAT_FLAG NE 'D'.

        CONCATENATE '변경된 계약상태에 따라 조건 유형이'
                    '일괄 삭제 처리 되었습니다.'
                    INTO LV_LONGTEXT SEPARATED BY SPACE.

    ENDCASE.

    IF SY-SUBRC = 0.

      PERFORM POPUP_CONFIRM USING '계약 상태 변경에 따른 조건 유형 변경'
                                  LV_LONGTEXT
                                  LV_ANSWER.

      CASE LV_ANSWER.
        WHEN '1'.

          GS_LOG-KNUMA   = GS_HEADER-KNUMA.

          MOVE-CORRESPONDING GS_ORG TO GS_LOG.

          SELECT SINGLE MAX( ZSEQ )
            INTO GS_LOG-ZSEQ
            FROM ZKONA_LOG
           WHERE KNUMA = GS_HEADER-KNUMA.

          GS_LOG-ZSEQ = GS_LOG-ZSEQ + 1.

          GS_LOG-WAERS_O = LS_TEMP_HEADER-WAERS.
          GS_LOG-WAERS_N = GS_HEADER-WAERS.

          GS_LOG-DATAB_O = LS_TEMP_HEADER-DATAB.
          GS_LOG-DATAB_N = GS_HEADER-DATAB.

          GS_LOG-DATBI_O = LS_TEMP_HEADER-DATBI.
          GS_LOG-DATBI_N = GS_HEADER-DATBI.

          GS_LOG-BOSTA_O = LS_TEMP_HEADER-BOSTA.
          GS_LOG-BOSTA_N = GS_HEADER-BOSTA.

          GS_LOG-ABSPZ_O = LS_TEMP_HEADER-ABSPZ.
          GS_LOG-ABSPZ_N = GS_HEADER-ABSPZ.

          GS_LOG-AENAM   = SY-UNAME.
          GS_LOG-AEDAT   = SY-DATUM.
          GS_LOG-AEZET   = SY-UZEIT.

        WHEN OTHERS.

          CLEAR : GV_LOG,    GS_LOG,
                  GT_ITAB[], GT_HIST[],
                  GV_CHECK.

          GS_HEADER-BOSTA = LV_BOSTA.
          GT_ITAB[] = LT_TEMP1[].
          GT_HIST[] = LT_TEMP2[].

      ENDCASE.

    ENDIF.

  ELSE.
    CONCATENATE '계약 상태가 변경 전과 동일합니다!'
                '변경되기 전과 동일한 계약 상태로, 변경 없이 종료합니다.'
                '조건 유형만 변경하시는 경우, 계약 상태 필드를 수정하지'
                '마시고, 조건 유형에서 삭제를 클릭하여 진행해주시기 바랍니다.'
                INTO LV_LONGTEXT SEPARATED BY SPACE.

    PERFORM POPUP_CONFIRM USING '계약 상태 변경 없음'
                                LV_LONGTEXT
                                LV_ANSWER.

    LEAVE TO SCREEN 0.

  ENDIF.

ENDMODULE.
