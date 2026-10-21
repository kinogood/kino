*----------------------------------------------------------------------*
***INCLUDE MZQM0020F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_ZQMT0011H
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RCEPNO  text
*----------------------------------------------------------------------*
FORM ENQUEUE_ZQMT0011H  USING    PV_RCEPNO.
  DATA: LV_MSGV1  LIKE SY-MSGV1.

  CALL FUNCTION 'ENQUEUE_EZ_ZQMT0011H'
   EXPORTING
     RCEPNO               = PV_RCEPNO
   EXCEPTIONS
     FOREIGN_LOCK         = 1
     SYSTEM_FAILURE       = 2
     OTHERS               = 3.

  IF SY-SUBRC <> 0.
    LV_MSGV1 = SY-MSGV1.

    MESSAGE S004 DISPLAY LIKE 'E'
       WITH PV_RCEPNO '접수번호는 사용자' LV_MSGV1
            '이(가) 처리 중 입니다.'.

    LEAVE PROGRAM.
  ENDIF.

ENDFORM.                    " ENQUEUE_ZQMT0011H
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZQMT0011H
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZQMT0011H  USING    PV_RCEPNO.

  CALL FUNCTION 'DEQUEUE_EZ_ZQMT0011H'
   EXPORTING
     RCEPNO               = PV_RCEPNO.

ENDFORM.                    " DEQUEUE_ZQMT0011H
*&---------------------------------------------------------------------*
*&      Form  SET_LONG_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_LONG_TEXT  TABLES   PT_LINES STRUCTURE TLINE
                    USING    PC_TEXT  TYPE REF TO C_TEXTEDIT_CONTROL
                             PV_OLIN
                             PV_NLIN.

  CLEAR   : G_LINES, G_HDLIN.
  REFRESH : G_LINES.

  LOOP AT PT_LINES.
    CLEAR : G_LINES.

    IF PT_LINES-TDFORMAT = '>X'.
      G_LINES-TDFORMAT = '*'.

      G_LINES-TDLINE = PT_LINES-TDLINE.

      G_HDLIN = SY-TABIX.
    ELSE.
      G_LINES = PT_LINES.
    ENDIF.

    APPEND G_LINES.
  ENDLOOP.

  IF GV_TRTYP <> 'A' AND SY-SUBRC = 0.
    CLEAR : G_LINES.

    G_LINES-TDFORMAT = '*'.

    APPEND G_LINES.
  ENDIF.

  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    TABLES
      ITF_TEXT    = G_LINES
      TEXT_STREAM = TEXT_TABLE.

  CALL METHOD PC_TEXT->SET_TEXT_AS_STREAM
    EXPORTING
      TEXT   = TEXT_TABLE
    EXCEPTIONS
      OTHERS = 1.

  IF  G_HDLIN IS NOT INITIAL AND G_HDLIN < PV_OLIN.
    IF PV_OLIN IS NOT INITIAL.
      CALL METHOD PC_TEXT->SELECT_LINES
        EXPORTING
          FROM_LINE = 1
          TO_LINE   = PV_OLIN.

      CALL METHOD PC_TEXT->PROTECT_SELECTION
        EXPORTING
          PROTECT_MODE = YTRUE.

      IF PV_NLIN <= PV_OLIN.
        PV_NLIN = PV_OLIN + 1.
      ENDIF.

      CALL METHOD PC_TEXT->SET_SELECTION_POS
        EXPORTING
          FROM_LINE = PV_NLIN
          FROM_POS  = 1
          TO_LINE   = PV_NLIN
          TO_POS    = 1.
    ENDIF.
  ELSEIF G_HDLIN IS NOT INITIAL.

    CALL METHOD PC_TEXT->SELECT_LINES
      EXPORTING
        FROM_LINE = 1
        TO_LINE   = G_HDLIN.

    CALL METHOD PC_TEXT->PROTECT_SELECTION
      EXPORTING
        PROTECT_MODE = YTRUE.

    IF PV_NLIN <= PV_OLIN.
      PV_NLIN = PV_OLIN + 1.
    ENDIF.

    CALL METHOD PC_TEXT->SET_SELECTION_POS
      EXPORTING
        FROM_LINE = PV_NLIN
        FROM_POS  = 1
        TO_LINE   = PV_NLIN
        TO_POS    = 1.
  ENDIF.

ENDFORM.                    " SET_LONG_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_LONG_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONG_TEXT  TABLES   PT_LINES STRUCTURE TLINE
                    USING    PC_TEXT  TYPE REF TO C_TEXTEDIT_CONTROL
                             PV_OLIN
                             PV_NLIN.

*  READ TEXT FROM G_CL_TEXT
  CALL METHOD PC_TEXT->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT = TEXT_TABLE.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

  IF SY-SUBRC <> 0.
*   add your handling
  ENDIF.

* and convert text stream into ITF text
  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = TEXT_TABLE
      ITF_TEXT    = G_LINES.

  REFRESH : PT_LINES.

  LOOP AT G_LINES.
    CLEAR : PT_LINES.

    IF G_LINES-TDLINE(1) = '>'.
      PT_LINES-TDFORMAT = '>X'.
      PT_LINES-TDLINE    = G_LINES-TDLINE.
    ELSE.
      PT_LINES = G_LINES.
    ENDIF.

    IF SY-TABIX > PV_OLIN AND G_LINES-TDLINE IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND PT_LINES.
  ENDLOOP.

  DESCRIBE TABLE PT_LINES LINES PV_NLIN.

  IF PV_OLIN <> PV_NLIN.
    G_TABIX = PV_OLIN + 1.

    READ TABLE PT_LINES INDEX G_TABIX.
    IF SY-SUBRC = 0.
      IF PT_LINES-TDLINE(1) <> '>'.
        CLEAR : PT_LINES.

        PT_LINES-TDFORMAT = '>X'.

        CALL FUNCTION 'TEXT_CREATE_HISTORY_LINE'
          IMPORTING
            HISTORY_LINE = PT_LINES-TDLINE.

        PT_LINES-TDLINE(1) = '>'.

        INSERT PT_LINES INDEX G_TABIX.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_LONG_TEXT
*&---------------------------------------------------------------------*
*&      Form  CREATE_TEXT_EDITOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_TEXT_EDITOR USING PC_TEXT TYPE REF TO C_TEXTEDIT_CONTROL
                              PV_DYNNR LIKE SY-DYNNR
                              PV_CONTAINER.

  CREATE OBJECT PC_TEXT
    EXPORTING
      REPID                      = SY-REPID
      DYNNR                      = PV_DYNNR
      DYNPRO_CONTAINER           = PV_CONTAINER
      WORDWRAP_MODE              = 2
      WORDWRAP_POSITION          = 72
      WORDWRAP_TO_LINEBREAK_MODE = 1.

  CALL METHOD PC_TEXT->SET_TOOLBAR_MODE
    EXPORTING
      TOOLBAR_MODE = CL_GUI_TEXTEDIT=>FALSE.

  CALL METHOD PC_TEXT->SET_STATUSBAR_MODE
    EXPORTING
      STATUSBAR_MODE = CL_GUI_TEXTEDIT=>FALSE.

ENDFORM.                    " CREATE_TEXT_EDITOR
*&---------------------------------------------------------------------*
*&      Form  REFRESH_TABLE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_TABLE_DATA .

  CLEAR   : GT_100,     GT_110,     GT_120,     GT_130,     GS_100,
            GT_140,     GT_150,     GT_160,     GT_170,     GT_180,
            GT_190,     GT_200,     GT_210,     GT_230,     GT_240,
            GT_250,     GT_260,     GT_270,     GT_280,     GT_110A,
            GT_120A,    GT_100_OLD, GT_110_OLD, GT_120_OLD, GT_130_OLD,
            GS_100_OLD, GT_140_OLD, GT_150_OLD, GT_160_OLD, GT_170_OLD,
            GT_180_OLD, GT_190_OLD, GT_110A,    GT_200_OLD, GT_210_OLD,
            GT_230_OLD, GT_240_OLD, GT_250_OLD, GT_260_OLD, GT_270_OLD,
            S_810.
  REFRESH : GT_100,     GT_110,     GT_120,     GT_130,     GT_140,
            GT_150,     GT_160,     GT_170,     GT_180,     GT_190,
            GT_200,     GT_210,     GT_230,     GT_240,     GT_250,
            GT_260,     GT_270,     GT_280,     GT_110A,    GT_120A,
            GT_100_OLD, GT_110_OLD, GT_120_OLD, GT_130_OLD, GT_140_OLD,
            GT_150_OLD, GT_160_OLD, GT_170_OLD, GT_180_OLD, GT_190_OLD,
            GT_200_OLD, GT_210_OLD, GT_230_OLD, GT_240_OLD, GT_250_OLD,
            GT_260_OLD, GT_270_OLD.

*__개요
  PERFORM GET_COMPLAIN_DATA_200.

  CHECK GS_100-RCEPNO IS NOT INITIAL.

  PERFORM GET_BUKRS USING    GS_100-WERKS_H
                    CHANGING GV_BUKRS.

*  IF GV_BUKRS EQ '2000'.
*    GV_DOKAR = 'JQS'.
*  ELSE.
*    GV_DOKAR = 'QCS'.
*  ENDIF.

*__자재/불량정보
  PERFORM GET_COMPLAIN_DATA_300.


*__물류처리
  PERFORM GET_COMPLAIN_DATA_400.


*__반품/출고
  PERFORM GET_COMPLAIN_DATA_500.


*__반품검사로트
  PERFORM GET_COMPLAIN_DATA_600.


*__손실금액
  PERFORM GET_COMPLAIN_DATA_700.


*__물류관련손실금액
  PERFORM GET_COMPLAIN_DATA_800.


*__시정조치
  PERFORM GET_COMPLAIN_DATA_1100.


*__처리결과/승인
  PERFORM GET_COMPLAIN_DATA_1200.


*__불만이력
  PERFORM GET_COMPLAIN_DATA_1300.


  GS_100_OLD   = GS_100.
  GT_100_OLD[] = GT_100[].
  GT_110_OLD[] = GT_110A[].  "gt_110 아님
  GT_120_OLD[] = GT_120A[].  "gt_120 아님
  GT_130_OLD[] = GT_130[].
  GT_140_OLD[] = GT_140[].
  GT_150_OLD[] = GT_150[].
  GT_160_OLD[] = GT_160[].
  GT_190_OLD[] = GT_190[].
  GT_210_OLD[] = GT_210[].
  GT_230_OLD[] = GT_230[].
  GT_240_OLD[] = GT_240[].
  GT_250_OLD[] = GT_250[].
  GT_260_OLD[] = GT_260[].
  GT_270_OLD[] = GT_270[].
  G_LINES1_N[] = G_LINES1_O[].
  G_LINES2_N[] = G_LINES2_O[].
  G_LINES3_N[] = G_LINES3_O[].
  G_LINES4_N[] = G_LINES4_O[].
  G_LINES5_N[] = G_LINES5_O[].
  G_LINES6_N[] = G_LINES6_O[].

  DESCRIBE TABLE G_LINES1_O LINES G_OLIN1.
  DESCRIBE TABLE G_LINES2_O LINES G_OLIN2.
  DESCRIBE TABLE G_LINES3_O LINES G_OLIN3.
  DESCRIBE TABLE G_LINES4_O LINES G_OLIN4.
  DESCRIBE TABLE G_LINES5_O LINES G_OLIN5.
  DESCRIBE TABLE G_LINES6_O LINES G_OLIN6.
  DESCRIBE TABLE G_LINES1_N LINES G_NLIN1.
  DESCRIBE TABLE G_LINES2_N LINES G_NLIN2.
  DESCRIBE TABLE G_LINES3_N LINES G_NLIN3.
  DESCRIBE TABLE G_LINES4_N LINES G_NLIN4.
  DESCRIBE TABLE G_LINES5_N LINES G_NLIN5.
  DESCRIBE TABLE G_LINES6_N LINES G_NLIN6.

ENDFORM.                    " REFRESH_TABLE_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_DEFAULT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_COMPANY_DEFAULT_DATA .
  DATA: LV_CURRDEC LIKE TCURX-CURRDEC.

  CLEAR : GV_WAERS, GV_LAND1, GV_CONVRT.

  SELECT SINGLE WAERS
                LAND1
    INTO (GV_WAERS, GV_LAND1)
    FROM T001
   WHERE BUKRS = GV_BUKRS.

  SELECT SINGLE CURRDEC
    INTO LV_CURRDEC
    FROM TCURX
   WHERE CURRKEY = GV_WAERS.

  IF SY-SUBRC <> 0.
    LV_CURRDEC = 2.
  ENDIF.

  GV_CONVRT = 10 ** ( 2 - LV_CURRDEC ).
endform.                    " GET_COMPANY_DEFAULT_DATA
