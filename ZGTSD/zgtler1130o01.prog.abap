*&---------------------------------------------------------------------*
*& Include          ZGTLER1130O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '100' EXCLUDING GT_EXCL.
  SET TITLEBAR  '100' WITH GV_TITLE10.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_control  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_CONTROL OUTPUT.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  IF DOCKING IS INITIAL.
*/ Create the docking container
    PERFORM CREATE_DOCKING.
*/ Create the GRID LIST1
    PERFORM CREATE_GRID1.
  ELSE.
    CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh
  ENDIF.

***********/ DETAIL list.
  IF CONTAINER_SPLITER IS INITIAL.
*/ Create the splitter container
    PERFORM CREATE_SPLITTER.
*/ GRID LIST2
    PERFORM CREATE_GRID2.
  ELSE.
    CALL METHOD GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
*       I_SOFT_REFRESH = 'X'
        IS_STABLE = L_SCROLL.     "현재 그대로 입력한 refresh
  ENDIF.

ENDMODULE.                 " create_control  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '200'.
  SET TITLEBAR  '200'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '300' EXCLUDING GT_EXCL2.
  SET TITLEBAR '300'.

ENDMODULE.                 " status_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  list_box  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LIST_BOX OUTPUT.

  TYPE-POOLS VRM.

  DATA: VALUES1  TYPE VRM_VALUES WITH HEADER LINE.

  CLEAR: VALUES1[], VALUES1.
*-{자체개선 54306 - 변경
*  select * from tvtkt where spras = '3'.
*    values1-key   = tvtkt-shtyp.
*    values1-text  = tvtkt-bezei .
*    append values1.
*  endselect.
  SELECT A~SHTYP AS KEY
         B~BEZEI AS TEXT
    FROM TVTK AS A INNER JOIN TVTKT AS B
       ON A~SHTYP EQ B~SHTYP
    INTO CORRESPONDING FIELDS OF TABLE VALUES1
  WHERE SPRAS = '3'.
*-}자체개선 54306_2014.11.25

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'WA-SHTYP'  "SCREEN FIELD NAME
      VALUES          = VALUES1[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " list_box  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROL_SUB1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_CONTROL_SUB3 OUTPUT.

  IF CONTAINER_SUB3 IS INITIAL.

    CREATE OBJECT CONTAINER_SUB3
      EXPORTING
        CONTAINER_NAME = 'CUSTOM_SUB3'.

    CREATE OBJECT GRID3
      EXPORTING
        I_PARENT = CONTAINER_SUB3.


**/ 출력할 필드 속성을 정의
*    PERFORM SET_FIELD_CATALOGS_GRID3 .

*  */ LAYOUT SETTING
    PERFORM SET_OPTION_GRID3.

    PERFORM SET_DROPDOWN3.

    CALL METHOD GRID3->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

**  / ALV DATA 뿌려줌
*    CALL METHOD GRID3->SET_TABLE_FOR_FIRST_DISPLAY
*      EXPORTING
*        IS_LAYOUT            = GS_LAYOUT3
*        IT_TOOLBAR_EXCLUDING = GT_TBAR_EXCLUDING1
*        I_SAVE               = 'A'
*        IS_VARIANT           = ALV_VARIANT3
*      CHANGING
*        IT_OUTTAB            = GT_ALV3[]
*        IT_FIELDCATALOG      = GT_LVC3[].

    CREATE OBJECT EVENT_RECEIVER3.
    SET HANDLER EVENT_RECEIVER3->HANDLE_USER_COMMAND      FOR GRID3.
    SET HANDLER EVENT_RECEIVER3->HANDLE_TOOLBAR           FOR GRID3.
    SET HANDLER EVENT_RECEIVER3->HANDLE_DOUBLE_CLICK      FOR GRID3.

    SET HANDLER EVENT_RECEIVER3->HANDLE_DATA_CHANGED_FINISHED FOR GRID3.

  ENDIF.

  IF GF_ALV_FIRST IS NOT INITIAL.

**/ 출력할 필드 속성을 정의
    PERFORM SET_FIELD_CATALOGS_GRID3 .

    CALL METHOD GRID3->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT3
        IT_TOOLBAR_EXCLUDING = GT_TBAR_EXCLUDING1
        I_SAVE               = 'A'
        IS_VARIANT           = ALV_VARIANT3
      CHANGING
        IT_OUTTAB            = GT_ALV3[]
        IT_FIELDCATALOG      = GT_LVC3[].

    CALL METHOD GRID3->SET_TOOLBAR_INTERACTIVE.

    CLEAR GF_ALV_FIRST.
  ELSE.
    PERFORM REFRESH_TABLE_DISPLAY USING GRID3.
  ENDIF.


ENDMODULE.                 " CREATE_CONTROL_SUB1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '400' EXCLUDING GT_EXCL3.
  SET TITLEBAR '400' WITH GV_TITLE.

  ST_ATTACH_KEY-ICON_ID   = ICON_ATTACHMENT.

ENDMODULE.                 " STATUS_0400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0700 OUTPUT.
  SET PF-STATUS '700' EXCLUDING GT_EXCL3.
  SET TITLEBAR '700' WITH ZLES042-TYPE.
ENDMODULE.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CUSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CUSOR OUTPUT.

  IF GV_SCREEN_FILED IS NOT INITIAL.
    SET CURSOR FIELD GV_SCREEN_FILED.
    CLEAR GV_SCREEN_FILED.
  ENDIF.

ENDMODULE.                 " SET_CUSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0600 OUTPUT.
  SET PF-STATUS '600'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0800 OUTPUT.

  DATA : LV_TITLE_800(30).

  CLEAR : GT_EXCL4, GT_EXCL4[].




  IF GF_SPOT IS INITIAL .
    LV_TITLE_800 = '운송경로(금액) 등록'.
    GT_EXCL4 = 'APPRQ'. APPEND GT_EXCL4.
  ELSE.
    LV_TITLE_800 = '일회성 단가등록'.
    GT_EXCL4 = 'ENTER4'. APPEND GT_EXCL4.
  ENDIF.

  SET TITLEBAR  '800' WITH LV_TITLE_800.
  SET PF-STATUS '800' EXCLUDING GT_EXCL4[].

ENDMODULE.                 " STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ENTER_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ENTER_0800 OUTPUT.

  DATA : LT_RTN       LIKE TABLE OF DDSHRETVAL WITH HEADER LINE,
         LT_DFIES     LIKE TABLE OF DFIES  WITH HEADER LINE,
         LV_TITLE(40),

         BEGIN OF LT_ZROUTE OCCURS 0,
           ZROUTE      LIKE  ZLET0210-ZROUTE,
           ZDEPARTURET LIKE  ZLET0210-ZDEPARTURET,
           ZARRIVALT   LIKE  ZLET0210-ZARRIVALT,
           TRK_TONT    LIKE  ZLET0210-TRK_TONT,
           PRICE(20),
           WAERS       LIKE  ZLET0210-WAERS,
         END OF LT_ZROUTE ,

         BEGIN OF LT_ZDEPARTURE OCCURS 0,
           ZDEPARTURE  LIKE  ZLET0210-ZDEPARTURE,
           ZDEPARTURET LIKE  ZLET0210-ZDEPARTURET,
         END OF LT_ZDEPARTURE ,


         BEGIN OF LT_ZARRIVAL OCCURS 0,
           ZARRIVAL  LIKE  ZLET0210-ZARRIVAL,
           ZARRIVALT LIKE  ZLET0210-ZARRIVALT,
         END OF LT_ZARRIVAL ,


         BEGIN OF LT_TRK_TON OCCURS 0,
           TRK_TON  LIKE  ZLET0210-TRK_TON,
           TRK_TONT LIKE  ZLET0210-TRK_TONT,
         END OF LT_TRK_TON ,

         LR_TDLNR      LIKE RANGE OF ZLET0210-TDLNR WITH HEADER LINE,
         LR_TRK_TON    LIKE RANGE OF ZLET0210-TRK_TON WITH HEADER LINE
         ,
         LR_ZARRIVAL   LIKE RANGE OF ZLET0210-ZARRIVAL WITH HEADER LINE,
         LR_ZDEPARTURE LIKE RANGE OF ZLET0210-ZDEPARTURE  WITH HEADER
                         LINE .


  CLEAR :  LR_TDLNR, LR_TDLNR[],
           LR_TRK_TON, LR_TRK_TON[],
           LR_ZARRIVAL, LR_ZARRIVAL[],
           LR_ZDEPARTURE, LR_ZDEPARTURE[],
           LT_DFIES  , LT_DFIES[],
           LT_RTN    , LT_RTN[].


  %%RA_ITAB_EQ : LR_TDLNR      'I' 'EQ' ZLET0210-TDLNR        '',
                 LR_TRK_TON    'I' 'EQ' ZLET0210-TRK_TON      '',
                 LR_ZARRIVAL   'I' 'EQ' ZLET0210-ZARRIVAL     '',
                 LR_ZDEPARTURE 'I' 'EQ' ZLET0210-ZDEPARTURE   ''.


  CASE GC_X. "서치헬프(엔터처리후 실행)
    WHEN GF_ZROUTE_F4 .
      PERFORM EXEC_ZROUTE_F4.

    WHEN GF_ZDEPARTURE_F4 .
      PERFORM EXEC_ZDEPARTURE_F4.

    WHEN GF_ZARRIVAL_F4 .
      PERFORM EXEC_ZARRIVAL_F4.

    WHEN GF_TRK_TON_F4 .
      PERFORM EXEC_TRK_TON_F4.

    WHEN GF_APPRQ. "[CHM2106-00116] 1회성 운송비 승인요청
      PERFORM REQUEST_APPROVAL.

    WHEN GF_ZROUTE.
      PERFORM ENTER_ZROUTE_TO_ALV3.
  ENDCASE.

ENDMODULE.                 " ENTER_0800  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  SET PF-STATUS '900'.
  SET TITLEBAR '900'.

ENDMODULE.                 " STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROL_SUB4  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_CONTROL_SUB4 OUTPUT.


  IF CONTAINER_SUB4 IS INITIAL.

    CREATE OBJECT CONTAINER_SUB4
      EXPORTING
        CONTAINER_NAME = 'CUSTOM_SUB4'.

    CREATE OBJECT GRID4
      EXPORTING
        I_PARENT = CONTAINER_SUB4.


*/ 출력할 필드 속성을 정의
    PERFORM SET_FIELD_CATALOGS_GRID4 .

*  */ LAYOUT SETTING
    PERFORM SET_OPTION_GRID4.

*  / ALV DATA 뿌려줌
    CALL METHOD GRID4->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT4
        IT_TOOLBAR_EXCLUDING = GT_TBAR_EXCLUDING4
        I_SAVE               = 'A'
        IS_VARIANT           = ALV_VARIANT4
      CHANGING
        IT_OUTTAB            = GT_0005[]
        IT_FIELDCATALOG      = GT_LVC4[].

  ELSE.
    PERFORM REFRESH_TABLE_DISPLAY USING GRID4.
  ENDIF.


ENDMODULE.                 " CREATE_CONTROL_SUB4  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ENTER_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ENTER_0400 OUTPUT.

  IF GF_ZGATING IS NOT INITIAL. "통문매핑
    CLEAR GF_ZGATING.
    PERFORM MAP_ZGATING .
  ENDIF.

ENDMODULE.                 " ENTER_0900  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_0400 OUTPUT.

  LOOP AT SCREEN .

    IF SCREEN-GROUP1 EQ 'PG'.
      IF GF_NREQUEST IS NOT INITIAL.
        SCREEN-ACTIVE = 1.
      ELSE.
        SCREEN-ACTIVE = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF. .
  ENDLOOP.


ENDMODULE.                 " SET_SCREEN_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_0800 OUTPUT.


  LOOP AT SCREEN .
    IF SCREEN-NAME EQ 'ZLET0210-ZROUTE'.
      IF GF_SPOT IS NOT INITIAL.
        SCREEN-INPUT = 0. "비활성
      ELSE.
        SCREEN-INPUT = 1. "활성
      ENDIF.
      MODIFY SCREEN.

    ENDIF .

    IF SCREEN-NAME EQ 'ZLET0210-PRICE'.
      IF GF_SPOT IS NOT INITIAL.
        SCREEN-INPUT = 1.
      ELSE.
        SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.

    ENDIF .

  ENDLOOP.


ENDMODULE.                 " SET_SCREEN_0800  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR '9000'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_9000 OUTPUT.
  IF CONTAINER_SUB3 IS INITIAL.

    CREATE OBJECT CONTAINER_SUB9
      EXPORTING
        CONTAINER_NAME = 'CONT9000'.

    CREATE OBJECT GRID9
      EXPORTING
        I_PARENT = CONTAINER_SUB9.


**/ 필드 속성을 정의
    PERFORM SET_FIELD_CATALOGS_GRID9 .

*  */ LAYOUT SETTING
    PERFORM SET_OPTION_GRID9.

*   SORT
    PERFORM SET_SORT_GRID9.

*    PERFORM SET_DROPDOWN3.

*    CALL METHOD GRID3->REGISTER_EDIT_EVENT
*      EXPORTING
*        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

**  / ALV DATA 뿌려줌
*    CALL METHOD GRID3->SET_TABLE_FOR_FIRST_DISPLAY
*      EXPORTING
*        IS_LAYOUT            = GS_LAYOUT3
*        IT_TOOLBAR_EXCLUDING = GT_TBAR_EXCLUDING1
*        I_SAVE               = 'A'
*        IS_VARIANT           = ALV_VARIANT3
*      CHANGING
*        IT_OUTTAB            = GT_ALV3[]
*        IT_FIELDCATALOG      = GT_LVC3[].

*    CREATE OBJECT EVENT_RECEIVER3.
*    SET HANDLER EVENT_RECEIVER3->HANDLE_USER_COMMAND      FOR GRID3.
*    SET HANDLER EVENT_RECEIVER3->HANDLE_TOOLBAR           FOR GRID3.
*    SET HANDLER EVENT_RECEIVER3->HANDLE_DOUBLE_CLICK      FOR GRID3.
*
*    SET HANDLER EVENT_RECEIVER3->HANDLE_DATA_CHANGED_FINISHED FOR GRID3.

    CALL METHOD GRID9->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT9
        IT_TOOLBAR_EXCLUDING = GT_TBAR_EXCLUDING9
        I_SAVE               = 'A'
        IS_VARIANT           = ALV_VARIANT9
      CHANGING
        IT_OUTTAB            = GT_STOCK[]
        IT_SORT              = GT_SORT9[]
        IT_FIELDCATALOG      = GT_LVC9[].

    CALL METHOD GRID9->SET_TOOLBAR_INTERACTIVE.

  ENDIF.
ENDMODULE.
