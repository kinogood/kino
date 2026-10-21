*&---------------------------------------------------------------------*
*& Include          ZSDR0950TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: <ICON>.
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
 TABLES : KONA, ZKONA, VBAK.
*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
 CONSTANTS: GC_ZVBO1(10)   VALUE 'ZGTSDR1101',
            GC_ZVBO2(10)   VALUE 'ZGTSDR1102',
            GC_ZVBO3(10)   VALUE 'ZGTSDR1103',
            GC_ZVBO4(10)   VALUE 'ZVBO4',
            GC_ZVBO5(10)   VALUE 'ZVBO5',
            GC_ZVBO6(10)   VALUE 'ZVBO6',
            GC_TITLE1(9)  VALUE '커미션 계약 생성',
            GC_TITLE2(9)  VALUE '커미션 계약 변경',
            GC_TITLE3(9)  VALUE '커미션 계약 조회',
*{ ZLSGSD4 - s
            GC_TITLE4(14) VALUE '커미션 승인요청 취소',
            GC_TITLE5(9)  VALUE '커미션 승인/반려',
            GC_TITLE6(12) VALUE '커미션 변경(권한자)'.
*} ZLSGSD4 - e
*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*
 DATA : GV_KNUMA TYPE ZKONA-KNUMA. "계약번호 SCREEN300
 DATA : GV_ERROR,
        GV_SAVE,
        GV_APRV_STAT,
        GV_ZNUMC     TYPE ZSDT0620-ZNUMC,
        GV_VAKEY     TYPE ZKONA_ITEM-VAKEY,
        GV_REQNO     TYPE ZSDT0630-ZV4REQNO,
        GV_EXIT, "ZLSGSD4 호출 시 EXIT COMMAND 제어
        GV_LONG. "SRM2404-03220 Longtext

 DATA : BEGIN OF GS_CHANGE,
          H(1),
          I(1),
        END OF GS_CHANGE.

*----------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*----------------------------------------------------------------------*
*- 조직데이터_SCREEN100
 DATA : BEGIN OF GS_ORG,
          VKORG TYPE VBAK-VKORG,
          VTWEG TYPE VBAK-VTWEG,
          SPART TYPE VBAK-SPART,
          VKBUR TYPE VBAK-VKBUR,
          VKGRP TYPE VBAK-VKGRP,
        END OF GS_ORG.

*- 커미션 헤더 데이터_SCREEN200
 DATA : BEGIN OF GS_HEADER,
          KNUMA  TYPE KONA-KNUMA,   "계약
          BOTEXT TYPE KONA-BOTEXT,  "내역
          AUSFU  TYPE ZKONA-AUSFU,  "리베이트 수령인
          WAERS  TYPE KONA-WAERS,   "통화
          DATAB  TYPE KONA-DATAB,   "효력시작일
          DATBI  TYPE KONA-DATBI,   "유효기간
          BOSTA  TYPE KONA-BOSTA,   "계약상태
          ABSPZ  TYPE KONA-ABSPZ,   "검증레벨
          KOBOG  TYPE KONA-KOBOG,   "조건유형 - ALV

          A925(1) TYPE C,
          A928(1) TYPE C,
          TABNAME(4),
        END OF GS_HEADER.
 DATA : GS_COPY LIKE GS_HEADER.

 DATA : BEGIN OF GS_DESC,
          A925(100),
          A928(100),
        END OF GS_DESC.

*- 커미션_헤더_TEXT
 DATA : BEGIN OF GS_TEXT,
          AUSFU_TX TYPE LFA1-NAME1,
          BOSTA_TX TYPE DD07V-DDTEXT,
          ABSPZ_TX TYPE DD07V-DDTEXT,
        END OF GS_TEXT.

*- LIST BOX
 DATA : BEGIN OF GS_LIST,
          KSCHL   TYPE T685-KSCHL,
          VTEXT   TYPE T685T-VTEXT,
          TABNAME TYPE DD02T-TABNAME,
          DDTEXT  TYPE DD02T-DDTEXT,
          KRECH   TYPE T685A-KRECH,
        END OF GS_LIST.

*{ SRM2404-03220 - s  기안자, 1~3차수 승인자
 DATA : BEGIN OF GS_APPROVER,
          UNAME1   TYPE ZSDT0630-UNAME,    "기안자
          SNAME1   TYPE ZSDT0630-SNAME,    "기안자 명
          ZAPPRV1  TYPE ZSDT0630-ZAPPRV,   "1차 승인상태
          ICON1    TYPE ICONS-TEXT,        "아이콘
          UNAME2   TYPE ZSDT0630-UNAME,    "1차수 승인자
          SNAME2   TYPE ZSDT0630-SNAME,    "1차수 승인자 명
          ZAPPRV2  TYPE ZSDT0630-ZAPPRV,   "1차 승인상태
          ICON2    TYPE ICONS-TEXT,        "아이콘
          UNAME3   TYPE ZSDT0630-UNAME,    "2차수 승인자
          SNAME3   TYPE ZSDT0630-SNAME,    "2차수 승인자 명
          ZAPPRV3  TYPE ZSDT0630-ZAPPRV,   "2차 승인상태
          ICON3    TYPE ICONS-TEXT,        "아이콘
          UNAME4   TYPE ZSDT0630-UNAME,    "3차수 승인자
          SNAME4   TYPE ZSDT0630-SNAME,    "3차수 승인자 명
          ZAPPRV4  TYPE ZSDT0630-ZAPPRV,   "3차 승인상태
          ICON4    TYPE ICONS-TEXT,        "아이콘
          ZV4REQNO TYPE ZSDT0630-ZV4REQNO, "결재요청번호
        END OF GS_APPROVER.
*} SRM2404-03220 - e

*- ALV
 DATA : BEGIN OF GS_ITAB,
*공통
          ICON         TYPE ICON-ID,
          MESSAGE(220),
          KSCHL        TYPE ZKONA_ITEM-KSCHL,
          VKORG        TYPE KONA-VKORG,
          VTWEG        TYPE KONA-VTWEG,
          SPART        TYPE KONA-SPART,
          AUSFU        TYPE ZKONA-AUSFU, "리베이트 수령인
          DATAB        TYPE KONA-DATAB,
          DATBI        TYPE KONA-DATBI,
          LOEVM        TYPE ZKONA_ITEM-LOEVM,
          KBETR        TYPE KONP-KBETR, "금액
          KONWA        TYPE KONP-KONWA, "통화
*테이블별 추가필드

          KUNNR        TYPE KNA1-KUNNR, "고객
          MATNR        TYPE MARA-MATNR, "자재
          PRODH        TYPE MARA-PRDHA, "제품 계층구조
          INCO1        TYPE VBKD-INCO1, "인코텀스
          AUBEL        TYPE VBAP-VBELN, "판매문서
          AUPOS        TYPE VBAP-POSNR, "판매문서 항목
          KPEIN        TYPE KONP-KPEIN,       "수량(정액)
          KMEIN        TYPE KONP-KMEIN,       "단위(정액)
          STAT_FLAG,
          NEW,
          ERROR,
          RSLT(1),                      "VK11/VK12 처리 결과
*          CREATE,
          DELETE,
          TABNAME(4),
          CELLTAB      TYPE LVC_T_STYL,
        END OF GS_ITAB.

*- ZSDT0620
 DATA : GS_0620 TYPE ZSDT0620.
*----------------------------------------------------------------------*
* DATA: Internal Table.
*----------------------------------------------------------------------*
 DATA : GT_ITAB  LIKE TABLE OF GS_ITAB.
 DATA : GT_HIST  LIKE TABLE OF GS_ITAB.
 DATA : GT_LIST  LIKE TABLE OF GS_LIST.

*-> CCM : 21.11.2023 11:28:15 / ZLSGSD4
 DATA : BEGIN OF GS_KSCHL OCCURS 0,
          KSCHL      TYPE ZKONA_ITEM-KSCHL, "조건유형
          VTEXT      TYPE T685T-VTEXT,     "조건유형 텍스트
          TABNAME(5),                   "조건테이블
          DDTEXT     TYPE DD02T-DDTEXT,    "조건유형 테이블 텍스트
          COUNT      TYPE I.               "조건 수
 DATA END OF GS_KSCHL.
 DATA GT_KSCHL LIKE TABLE OF GS_KSCHL.
*<-

*{ SRM2402-10021 - s  Change Doc 관리용 / X-변경 전 Y-변경 후
 DATA: XZKONA      LIKE ZKONA,
       YZKONA      LIKE ZKONA,
       XZKONA_ITEM LIKE YZKONA_ITEM OCCURS 0 WITH HEADER LINE,
       YZKONA_ITEM LIKE YZKONA_ITEM OCCURS 0 WITH HEADER LINE.
*} SRM2402-10021 - e

*-[SRM2406-00779_S
 DATA : GV_LOG(1),
        GV_CHECK(1),
        GS_LOG      TYPE ZKONA_LOG,
        GT_LOG      LIKE ZKONA_LOG OCCURS 0.
*]-SRM2406-00779_E
 DATA : GV_SIMPLE_APPROVAL.
 DATA : GV_ZSA1.
*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* BDC
*----------------------------------------------------------------------*
 DATA: GS_PARAMS  LIKE CTU_PARAMS,
       GT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
       GT_MESSAGE LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*
* LONGTEXT
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000   TYPE VKORG   VALUE '6000'.
CONSTANTS:
  GC_A TYPE C VALUE 'A',
  GC_B TYPE C VALUE 'B',
  GC_C TYPE C VALUE 'C',
  GC_D TYPE C VALUE 'D',
  GC_E TYPE C VALUE 'E',
  GC_F TYPE C VALUE 'F',
  GC_G TYPE C VALUE 'G',
  GC_H TYPE C VALUE 'H',
  GC_I TYPE C VALUE 'I',
  GC_J TYPE C VALUE 'J',
  GC_K TYPE C VALUE 'K',
  GC_L TYPE C VALUE 'L',
  GC_M TYPE C VALUE 'M',
  GC_N TYPE C VALUE 'N',
  GC_O TYPE C VALUE 'O',
  GC_P TYPE C VALUE 'P',
  GC_Q TYPE C VALUE 'Q',
  GC_R TYPE C VALUE 'R',
  GC_S TYPE C VALUE 'S',
  GC_T TYPE C VALUE 'T',
  GC_U TYPE C VALUE 'U',
  GC_V TYPE C VALUE 'V',
  GC_W TYPE C VALUE 'W',
  GC_X TYPE C VALUE 'X',
  GC_Y TYPE C VALUE 'Y',
  GC_Z TYPE C VALUE 'Z',
  GC_0 TYPE C VALUE '0',
  GC_1 TYPE C VALUE '1',
  GC_2 TYPE C VALUE '2',
  GC_3 TYPE C VALUE '3',
  GC_4 TYPE C VALUE '4',
  GC_5 TYPE C VALUE '5',
  GC_6 TYPE C VALUE '6',
  GC_7 TYPE C VALUE '7',
  GC_8 TYPE C VALUE '8',
  GC_9 TYPE C VALUE '9'.
