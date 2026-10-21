*&---------------------------------------------------------------------*
*&  Include           ZSDR1040TOP                                      *
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*      데이타선언
*---------------------------------------------------------------------*
TABLES : zsd0106t,
         zsd0106ta,   "ZLSGSD4 - Project/Application 번호/WBS 매핑 관리
         prps,        "ZLSGSD4 - WBS (작업분할구조) 요소 마스터 데이타
         knvv.


DATA : gt_zsd0106t LIKE zsd0106t OCCURS 0 WITH HEADER LINE.

DATA : gs_zsd0106t LIKE zsd0106t.

*{ ZLSGSD4 - s
DATA : BEGIN OF gs_zsd0106ta.
         INCLUDE STRUCTURE zsd0106ta.
DATA :   posid TYPE prps-posid,        "작업 분석 구조 요소(WBS 요소)
       END OF gs_zsd0106ta.

DATA : gt_zsd0106ta LIKE gs_zsd0106ta OCCURS 0 WITH HEADER LINE.
*} ZLSGSD4 - e

DATA : gv_flag.
DATA: g_init,
      x_init(1)       TYPE c VALUE 'Y',   " 초기실행
      g_dynnr         LIKE sy-dynnr,
      g_name1         LIKE  kna1-name1,            " 판매처명
      g_name2         LIKE  tspat-vtext,           " 제품군명
      g_name3         LIKE  tvkbt-bezei,           " 영업팀명
      g_name4         LIKE  tvgrt-bezei,           " 영업그룹명
      g_name5         LIKE  zzpa0001-ename,          " ZLSGSD4 - 사원명

      g_activetab(10),
      readonly        TYPE i.

* 동적 GUI STATUS용
DATA: BEGIN OF it_fcode OCCURS 0,
        fcode LIKE rsmpe-func,
      END OF it_fcode .


RANGES : lr_spart FOR mara-spart.

*{ ZLSGSD4 - s
DATA : BEGIN OF fieldtab OCCURS 2.
         INCLUDE STRUCTURE help_value.
DATA : END OF fieldtab.

DATA : BEGIN OF  valuetab OCCURS 0,
         value LIKE help_vtab-value,
       END OF  valuetab.

DATA : BEGIN OF i_help_vtab OCCURS 0.
         INCLUDE STRUCTURE  help_vtab.
DATA : END OF i_help_vtab.
*} ZLSGSD4 - e


*----------------------------------------------------------------------*
* Internal Table -> Insert  , clear
*----------------------------------------------------------------------*
DEFINE append_tab.
  APPEND  : &1.
  CLEAR   : &1.
END-OF-DEFINITION.

* + ----------------------------------------------------------------- +
* 현재화면필드 (값포함)
* + ----------------------------------------------------------------- +
DATA: BEGIN OF dynpfields OCCURS 0.
        INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.

*----------------------------------------------------------------------*
* 도움말을 만들기위한 변수들
*----------------------------------------------------------------------*
DATA : help_value LIKE help_value OCCURS 0 WITH HEADER LINE.

************************************************************************
*    Note Pad
************************************************************************
TYPES: notetab_line(30) TYPE c.

DATA: wa_thead                  LIKE thead,
      itftext                   TYPE tline OCCURS 0 WITH HEADER LINE,
      notetab                   TYPE notetab_line OCCURS 0,
      textedit_custom_container TYPE REF TO cl_gui_custom_container,
      note_editor               TYPE REF TO cl_gui_textedit,
*     NOTE PAD 저장되는 TABLE
      it_long                   LIKE tline OCCURS 0 WITH HEADER LINE.

************************************************************************
*    Note Pad
************************************************************************
DATA: ok_code   LIKE sy-ucomm,
      gv_okcode LIKE ok_code.

*---------------------------------------------------------------------*
*      SELECTION-SCREEN
*---------------------------------------------------------------------*

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF SCREEN 0010 AS SUBSCREEN. " NO INTERVALS.

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

    SELECTION-SCREEN SKIP 1.
*selection-screen begin of line.
*
*parameters: r01 radiobutton group g_r1
*                user-command ucomm default 'X'.
*selection-screen comment 10(17) text-002 for field r01.
*
*parameters: r02 radiobutton group g_r1.
*selection-screen comment 30(21) text-003 for field r02.

    PARAMETERS: r01 AS CHECKBOX USER-COMMAND ucomm DEFAULT 'X'
                    MODIF ID xx.

*selection-screen end of line.

    SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN END   OF BLOCK b1.


  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-004.

    SELECTION-SCREEN SKIP 1.

    PARAMETERS: p_spmon TYPE spmon DEFAULT sy-datum MODIF ID xyz.

*PARAMETERS: P_SPART LIKE MARA-SPART  MEMORY ID SPA MODIF ID XYZ.

    SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN END   OF BLOCK b2.

SELECTION-SCREEN END OF SCREEN 0010.



SELECTION-SCREEN BEGIN OF SCREEN 0020 AS SUBSCREEN.

  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-005.

    SELECTION-SCREEN SKIP 1.

    PARAMETERS : p_pjno LIKE zsd0106t-zpjno MEMORY ID zpj
                           MATCHCODE OBJECT zsd_pjno1.

    SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN END   OF BLOCK b3.

SELECTION-SCREEN END OF SCREEN 0020.


*- STANDARD SELECTION SCREEN ------------------------------------------*
SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 14 LINES,
TAB (30) button1 USER-COMMAND push1,
TAB (30) button2 USER-COMMAND push2
  DEFAULT SCREEN 0010,
END OF BLOCK mytab.
