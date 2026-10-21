*&---------------------------------------------------------------------*
*&  Include           ZMMR1371_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLE
**----------------------------------------------------------------------*
TABLES : ZTITCCK,
         ZTITCCP,
         ZTITRQS,
         MARA,
         EKKO .

*----------------------------------------------------------------------*
*  INTERNAL TABLE
*----------------------------------------------------------------------*
"메인 리스트

  DATA: BEGIN OF GT_TEMP OCCURS 0,
         ICCNO  LIKE ZTITCCK-ICCNO,
         ICCIT  LIKE ZTITCCP-ICCIT,
         ICCSQ  LIKE ZTITCCK-ICCSQ ,  "차수
         CDCNO  LIKE ZTITCCK-OPNNO,  "수입신고번호
         CDRDT  LIKE ZTITCCK-CDRDT,  "수리일
         CDRDT_T(20),
         LIFNR  LIKE EKKO-LIFNR ,
         NAME1  LIKE LFA1-NAME1   ,   "해외공급자상호

         CSSEQ  LIKE ZTITCC2-CSSEQ,  "란번호
         CMSEQ  LIKE ZTITCC2-CMSEQ,  "행번호
         CSSID  LIKE ZTITCC1-CSSID,  "란세번부호
         CSDRT  LIKE ZTITCC1-CSDRT,  "란관세율
         CSDUYT(40),                 "관세구분


         MAKTX  LIKE MAKT-MAKTX ,    "거래품명
         WERKS  LIKE EKPO-WERKS,     "사업부(플랜트)
         SPART  LIKE MARA-SPART,
         VTEXT  LIKE TSPAT-VTEXT,
         MATNR  LIKE EKPO-MATNR ,   "자재코드
         CPYME  LIKE ZTITCCK-CPYME,  "결제방법
        CPYATC  LIKE ZTITCCK-CPYATC, "결제금액통화
*        CSDRT   LIKE ZTITCCK-CSDRT,   "관세율
        CCMNG   LIKE ZTITCCP-CCMNG ,  "통관수량
        MEINS   LIKE ZTITCCP-MEINS ,  "통관단위
        NETPR   LIKE EKPO-NETPR,     "단가
        WAERS   LIKE EKKO-WAERS,

         BLNUM  LIKE ZTITBLK-BLNUM  ,  "BL번호
        KEY(50),
        EKORG  LIKE EKKO-EKORG     , "구매조직 (담당자)
         CDAT  LIKE ZTITCCK-CDAT ,
         CDUTX   LIKE ZTITCCK-CDUTX ,  "관세
         CADTX   LIKE ZTITCCK-CADTX ,  "부가세


         CFRAT 	  LIKE ZTITCCK-CFRAT, "운임
         CIPAT    LIKE ZTITCCK-CIPAT,  "보험료
         CPLAT    LIKE ZTITCCK-CPLAT,  "가산금액
         CFEAT    LIKE ZTITCCK-CFEAT,  "공제금액


         CPYRT   LIKE  ZTITCCK-CPYRT,  "통관환율
         REFWR   LIKE  ZTITCCP-REFWR,  "외화송장금액
         CCUAK    LIKE  ZTITCCK-CCUAK , "총과세가견
         REFWK   LIKE  ZTITCCK-CCUAK , "원화송장금액



         CLTTX   LIKE ZTITCCK-CLTTX ,  "신고지연가산세
         CCUAKC  LIKE ZTITCCK-CCUAKC ,
         IBLNO   LIKE ZTITCCP-IBLNO,
         REQNO   LIKE ZTITCCP-REQNO,
         AMDSQ   LIKE ZTITRQS-AMDSQ,
         REQDT   LIKE ZTITRQS-REQDT, "개설희망일
         OPNDT   LIKE ZTITRQS-OPNDT, "개설일
         OPNNO   LIKE ZTITRQS-OPNNO, "개설번호
         OPAMT   LIKE ZTITRQS-OPAMT , "개설금액(총합)
         OPAMT_N LIKE ZTITRQS-OPAMT , "개설금액(건별)
         WAERS2   LIKE ZTITRQS-WAERS ,
         USAMT   LIKE ZTITRQS-USAMT , "미화환산금액

         LIFNR2  LIKE ZTITRQK-LIFNR ,
         NAME2   LIKE LFA1-NAME1,
         EBELN   LIKE ZTITCCP-EBELN,
         EBELP   LIKE ZTITCCP-EBELP,
         BSART   LIKE EKKO-BSART,  "구매문서유형
         PEINH   LIKE EKPO-PEINH ,  "per
         RQMNG   LIKE ZTITRQP-RQMNG , "개설수량
         MENGE    LIKE EKPO-MENGE, "발주수량
         MENGE_GR LIKE EKPO-MENGE,  "입고수량 (누적)

         CDAPN   LIKE ZTITCCK-CDAPN, "신고자상호

         STATE   LIKE ZTITCCK-STATE, "의뢰관세사코드
         NAMET   LIKE ZTSTIG3-NAMET, "의뢰관세사상호

       END OF GT_TEMP.


DATA : BEGIN OF GT_LIST OCCURS 0.
        INCLUDE STRUCTURE GT_TEMP.
*--< ALV color information
DATA :  INFO(4) TYPE C,            "ALV ROW COLOR
        COLINFO TYPE LVC_T_SCOL,   "ALV COLUMN COLOR
        STYLE   TYPE LVC_T_STYL,   "ALV CONTROL
        END OF GT_LIST.



  DATA : GT_CC_1 LIKE TABLE OF GT_TEMP WITH HEADER LINE,
         GT_CC_2 LIKE TABLE OF GT_TEMP WITH HEADER LINE.


  DATA : BEGIN OF GT_LFA1 OCCURS 0,
          LIFNR LIKE LFA1-LIFNR ,
          NAME1 LIKE LFA1-NAME1 ,
        END OF GT_LFA1.


  DATA : BEGIN OF GT_MAKT OCCURS 0,
          MATNR LIKE MAKT-MATNR ,
          MAKTX LIKE MAKT-MAKTX ,
        END OF GT_MAKT.


  DATA : BEGIN OF GT_RQS OCCURS 0,
          REQNO   LIKE ZTITRQS-REQNO,
          AMDSQ   LIKE ZTITRQS-AMDSQ,
          REQDT   LIKE ZTITRQS-REQDT, "개설희망일
          OPNNO   LIKE ZTITRQS-OPNNO, "개설번호
          OPAMT   LIKE ZTITRQS-OPAMT ,
          WAERS   LIKE ZTITRQS-WAERS ,
          LIFNR   LIKE ZTITRQK-LIFNR ,
          EBELN   LIKE ZTITRQP-EBELN,
          EBELP   LIKE ZTITRQP-EBELP,
          OPNDT   LIKE ZTITRQS-OPNDT, "개설일
          USAMT   LIKE ZTITRQS-USAMT,
          IBLNO   LIKE ZTITRQP-IBLNO,
          RQMNG   LIKE ZTITRQP-RQMNG , "개설수량
         END OF GT_RQS ,

         GT_RQS_R LIKE TABLE OF GT_RQS WITH HEADER LINE.


  DATA :  BEGIN OF GT_EKBE OCCURS 0,
            EBELN  LIKE EKBE-EBELN,
            EBELP  LIKE EKBE-EBELP,
            SHKZG  LIKE EKBE-SHKZG,
            MENGE  LIKE EKBE-MENGE,
          END OF GT_EKBE,


          BEGIN OF GT_EKPO_GR OCCURS 0,
            EBELN LIKE EKBE-EBELN,
            EBELP LIKE EKBE-EBELP,
            MENGE LIKE EKBE-MENGE,
          END OF GT_EKPO_GR,

          GT_EKPO LIKE TABLE OF GT_EKPO_GR WITH HEADER LINE,

          BEGIN OF GT_MARA OCCURS 0,
            MATNR LIKE MARA-MATNR,
            SPART LIKE MARA-SPART,
            VTEXT LIKE TSPAT-VTEXT,
          END OF GT_MARA .


 DATA : BEGIN OF GT_CC12 OCCURS 0,
         ICCNO LIKE ZTITCC2-ICCNO   ,
         ICCSQ LIKE ZTITCC2-ICCSQ   ,
         CSSEQ LIKE ZTITCC2-CSSEQ   ,
         CMSEQ LIKE ZTITCC2-CMSEQ   ,
         CMRS1 LIKE ZTITCC2-CMRS1   ,  "자재번호
         CSSID LIKE ZTITCC1-CSSID   ,
         CSDRT LIKE ZTITCC1-CSDRT   ,  "란관세율
         CSDUY LIKE ZTITCC1-CSDUY   ,  "관세구분
         CSDUYT(40),
        END OF GT_CC12.


*----------------------------------------------------------------------*
*  VARIABLE
*----------------------------------------------------------------------*

DATA : GV_SAVE      TYPE C VALUE 'A',    "-. for Parameter I_SAVE
       GV_EXIT      TYPE C,
       GV_REPID     TYPE SY-REPID,
       GV_DEFAULT   TYPE C.

DATA : ST_SWAP_KEY TYPE SMP_DYNTXT ,
       GT_SQL_SET_WHERE(100),

       GR_PARAM01 LIKE TABLE OF RSIS_S_RANGE WITH HEADER LINE ,
       GR_PARAM02 LIKE TABLE OF RSIS_S_RANGE WITH HEADER LINE ,
       GR_PARAM03 LIKE TABLE OF RSIS_S_RANGE WITH HEADER LINE ,
       GR_PARAM04 LIKE TABLE OF RSIS_S_RANGE WITH HEADER LINE ,

       GV_TABNAME TYPE SLIS_TABNAME.




*----------------------------------------------------------------------*
*  FIELD-SYMBOLS
*----------------------------------------------------------------------*
FIELD-SYMBOLS : <GT_LIST>  TYPE TABLE.

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
  C_S VALUE 'S',

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
