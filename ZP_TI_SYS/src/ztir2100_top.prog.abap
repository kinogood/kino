*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLE
**----------------------------------------------------------------------*
TABLES : SSCRFIELDS, ZTITBLK, LFA1.

*----------------------------------------------------------------------*
*  INTERNAL TABLE
*----------------------------------------------------------------------*

"메인 리스트
DATA : BEGIN OF GT_LIST OCCURS 0,

        BLNUM LIKE ZTITBLH-BLNUM , "B/L 번호
        BLDAT LIKE ZTITBLH-BLDAT , "B/L발행일
        LIFNR LIKE ZTITBLH-LIFNR , "공급업체 계정 번호
        NAME1 LIKE LFA1-NAME1 , "업체명
        FWDCD LIKE ZTITBLH-FWDCD , "포워더
        FWDTX LIKE ZTITBLK-FWDTX , "포워더명
        FWDTY LIKE ZTITBLH-FWDTY , "운송 방법
        FWDFM LIKE ZTITBLH-FWDFM , "운송형태
        CTNQ2 LIKE ZTITBLH-CTNQ2 , "20FT 컨테이너 수
        CTNQ4 LIKE ZTITBLH-CTNQ4 , "40FT 컨테이너 수

        CTNTY LIKE ZTITBLH-CTNTY , "컨테이너 종류
        BIPKG LIKE ZTITBLH-BIPKG , "포장개수
        BRGEW LIKE ZTITBLH-BRGEW , "총중량


        VOLUM LIKE ZTITBLH-VOLUM , "볼륨

        IVSLN LIKE ZTITBLH-IVSLN , "선기명(주운송수단)
        BLETD LIKE ZTITBLH-BLETD , "ETD(출발 예정 시각)
        BLETA LIKE ZTITBLH-BLETA , "ETA(도착 예정 시각)

        FLAND LIKE ZTITBLH-FLAND , "선적국
        FPORT LIKE ZTITBLH-FPORT , "선적항

        IBLNO LIKE ZTITBLH-IBLNO,

        INFO(4) TYPE C,            "ALV ROW COLOR
        COLINFO TYPE LVC_T_SCOL,   "ALV COLUMN COLOR
        STYLE   TYPE LVC_T_STYL,   "ALV CONTROL
        END OF GT_LIST.

DATA :  GT_EXCEL      LIKE  TABLE OF ZMMS0757  WITH HEADER LINE,
        GT_UPLOAD     LIKE  TABLE OF ZMMT1365 WITH HEADER LINE .


**----------------------------------------------------------------------*
**  FIELD-SYMBOLS
**----------------------------------------------------------------------*
*FIELD-SYMBOLS : <GT_LIST>   LIKE GT_LIST.

*----------------------------------------------------------------------*
*  TYPE
*----------------------------------------------------------------------*
TYPE-POOLS : VRM,                " for Dropdown Listbox
             SLIS.

*----------------------------------------------------------------------*
*  ALV
*----------------------------------------------------------------------*
*메인
DATA : GS_CUSTOM_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GS_SPLITTER         TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GS_CONTAINER_TOP    TYPE REF TO CL_GUI_CONTAINER,
       GS_ALV_GRID         TYPE REF TO CL_GUI_ALV_GRID,      "alv grid
       GS_VARIANT          TYPE DISVARIANT,    " Layout (External Use)
       GS_LAYOUT           TYPE LVC_S_LAYO,      " ALV control: Layout
       GT_FIELDCAT         TYPE LVC_T_FCAT WITH HEADER LINE,
       GT_FIELD            TYPE SLIS_T_FIELDCAT_ALV,
       GT_SORT             TYPE TABLE OF LVC_S_SORT,        "Field sort
       GT_EXCLUDE          TYPE UI_FUNCTIONS,          "ALV Toolbar dim
       GT_COLOR            TYPE LVC_T_SCOL WITH HEADER LINE, "ALV color
       GS_EVENT_RECEIVER   TYPE REF TO LCL_EVENT_RECEIVER,   "ALV Event
       GS_STBL             TYPE LVC_S_STBL.            "최신표시 안정성

*상세
DATA : GS_CUSTOM_CONTAINER99 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GS_SPLITTER99         TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GS_CONTAINER_BOT      TYPE REF TO CL_GUI_CONTAINER,
       GS_ALV_GRID99         TYPE REF TO CL_GUI_ALV_GRID,      "alv grid
       GS_VARIANT99          TYPE DISVARIANT,    " Layout (External Use)
       GS_LAYOUT99           TYPE LVC_S_LAYO,      " ALV control: Layout
       GT_FIELDCAT99         TYPE LVC_T_FCAT WITH HEADER LINE,
       GT_FIELD99            TYPE SLIS_T_FIELDCAT_ALV,
       GT_SORT99             TYPE TABLE OF LVC_S_SORT,       "Field sort
       GT_EXCLUDE99          TYPE UI_FUNCTIONS,          "ALV Toolbar dim
       GT_COLOR99            TYPE LVC_T_SCOL WITH HEADER LINE, "ALV color
       GS_EVENT_RECEIVER99   TYPE REF TO LCL_EVENT_RECEIVER,   "ALV Event
       GS_STBL99             TYPE LVC_S_STBL.            "최신표시 안정성

*----------------------------------------------------------------------*
*  VARIABLE
*----------------------------------------------------------------------*
DATA :  GV_COL   TYPE C,                    "색깔 정보
        OK_CODE  LIKE SY-UCOMM,             "OK-CODE
        GV_LINES TYPE SY-TABIX,
        GV_CHK,
        GV_ANSWER,
        GV_TITLE_SUB(10),
        GV_BKTXT LIKE BKPF-BKTXT,
        GV_SQL_SET_DATE(100)      "query update 날짜변경 구문
        VALUE ' AENAM = sy-uname  AEDAT = sy-datlo  AEZET = sy-timlo '.

DATA : GT_ROWS TYPE LVC_T_ROW WITH HEADER LINE.

DATA : GS_F4 TYPE LVC_S_F4,             " F4 필드 관련
       GT_F4 TYPE LVC_T_F4,

*-Define Log
      GV_LOG_HANDLE               TYPE BALLOGHNDL,
      GS_LOG                      TYPE BAL_S_LOG,
      GS_MSG                      TYPE BAL_S_MSG,

      GV_CONTROL_HANDLE           TYPE BALCNTHNDL,
      GV_MSGNO                    TYPE SYMSGNO,
      GV_LINE_COUNT               LIKE SY-LOOPC,  "Count of table ctl
      GS_DISPLAY_PROFILE          TYPE BAL_S_PROF,

*-Define Flag
      GF_EDIT.

*----------------------------------------------------------------------*
* BDC
*----------------------------------------------------------------------*
DATA:  BEGIN OF BDCDATA OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA   END OF BDCDATA.
DATA : CTU_PARAMS LIKE CTU_PARAMS.
DATA : MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF RETURN OCCURS 0.
        INCLUDE STRUCTURE   BAPIRET2.
DATA : END   OF RETURN.

*----------------------------------------------------------------------*
* CONSTANT
*----------------------------------------------------------------------*
CONSTANTS :

  C_X VALUE 'X',
  C_BLART TYPE BLART VALUE 'AB', "반제전표유형
  C_TCODE TYPE TCODE VALUE 'ZMMPR088',

*-- ALV 필드 색상
 C_COL_YELLOW  TYPE CHAR4 VALUE 'C300',
 C_COL_BLUE    TYPE CHAR4 VALUE 'C400',
 C_COL_GREEN   TYPE CHAR4 VALUE 'C500',
 C_COL_RED     TYPE CHAR4 VALUE 'C600',
 C_COL_GREY    TYPE CHAR4 VALUE 'C000',
 C_COL_LGREY   TYPE CHAR4 VALUE 'C200',
 C_COL_VIOLET  TYPE CHAR4 VALUE 'C700',

 C_COL_YELLOW1  TYPE CHAR4 VALUE 'C310',
 C_COL_BLUE1    TYPE CHAR4 VALUE 'C410',
 C_COL_GREEN1   TYPE CHAR4 VALUE 'C510',
 C_COL_RED1     TYPE CHAR4 VALUE 'C610',
 C_COL_GREY1    TYPE CHAR4 VALUE 'C010',
 C_COL_LGREY1   TYPE CHAR4 VALUE 'C210',
 C_COL_VIOLET1  TYPE CHAR4 VALUE 'C710',

 C_COL_YELLOW2  TYPE CHAR4 VALUE 'C301',
 C_COL_BLUE2    TYPE CHAR4 VALUE 'C401',
 C_COL_GREEN2   TYPE CHAR4 VALUE 'C501',
 C_COL_RED2     TYPE CHAR4 VALUE 'C601',
 C_COL_GREY2    TYPE CHAR4 VALUE 'C001',
 C_COL_LGREY2   TYPE CHAR4 VALUE 'C201',
 C_COL_VIOLET2  TYPE CHAR4 VALUE 'C701'.
