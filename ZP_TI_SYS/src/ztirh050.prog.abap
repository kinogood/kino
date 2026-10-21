************************************************************************
*                                                                      *
* Title         : ZTIRH040                                             *
*                                                                      *
* Description   : [Report] 수입 진행 List                              *
*                                                                      *
* Creation Date : 2008/05/26                                           *
*                                                                      *
* Author        : Soo Ho, Yoon                                         *
*                                                                      *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2009/10/13    조성임    [제목] 자재명,업체코드 추가                  *
*                         [요청번호]C20091013_39827                    *
* 2019/05/03    신재호    [제목] 보험관련 필드 추가                    *
*                         [요청번호] 기능개선 278454                   *
************************************************************************
REPORT  ZTIRH040
        MESSAGE-ID ZMTI00
        NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: SLIS.    "> Globale Type(ALV)

TABLES : ZTITIG00.

TYPES: BEGIN OF TY_SELT.
TYPES:
            RPTTYN LIKE DD07D-DDTEXT.       "신고형태명
TYPES: END OF TY_SELT.


****at line-selection****alv용
DATA: BEGIN OF FC_STRUCT,
        TABNAME(7),
        FIELDNAME(9),
        REF_TABNAME(7),
        REF_FIELDNAME(6),
        NO_OUT(1),
        CQINDICATOR(1),
        CQFIELD(6),
      END OF FC_STRUCT.

*>ALV POPUP.
DATA: GS_PRIVATE  TYPE SLIS_DATA_CALLER_EXIT,
      T_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      G_EXIT(1)   TYPE C,
      DYNAME      LIKE D020S-PROG,
*      L_TITLE     TYPE SY-TITLE.
      G_TITLE(99) TYPE C,
      EXTAB TYPE SLIS_T_EXTAB.


*> Range 변수
RANGES: GR_REFNO  FOR ZTITCSD-REFNO,
        GR_REFNO2 FOR ZTITCSD-REFNO,
        GR_DATE   FOR SY-DATLO.
*        gr_ekorg  FOR ekko-ekorg.

RANGES: GR_SUBMI  FOR EKKO-SUBMI,
        GR_ELIKZX FOR EKPO-ELIKZ.



************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: DFIES,
        EKKO,
        EKPO,
        T001,
        T001W,
        RBKP,
        ZTITRQK,
        ZTITRQP,
        ZTITRQS,
        ZTITBLK,
        ZTITBLP,
        ZTITCRK,
        ZTITCCK,
        ZTITCCP,
        ZTITGRK,
        ZTITGRP,
        ZTITIVK,
        ZTITIVP,
        ZTITBIK,
        ZTITBOK,
        BSE_CLR,
        ZTITPNK,
        BSEG,
        ZTITPNP,
        MARA.

TABLES: ICON.
************************************************************************
* Internal Tables  & Structure
************************************************************************
*SELECT용
DATA: IT_SELT TYPE STANDARD TABLE OF TY_SELT,
      GS_SELT TYPE TY_SELT,
      LS_SELT TYPE TY_SELT.

DATA: BEGIN OF IT_LIST OCCURS 0,
        BOX,
        EBELN     LIKE EKKO-EBELN,      "구매번호
        EBELP     LIKE EKPO-EBELP,      "구매번호아이템
        LCICN(4),                       "L/C  아이콘
        BLICN(4),                       "B/L  아이콘
        IPICN(4),                       "보험 아이콘
        CCICN(4),                       "통관 아이콘
        GRICN(4),                       "G/R  아이콘
        IVICN(4),                       "송장 아이콘
        PNICN(4),                     "Notice 아이콘
        BIICN(4),
        BOICN(4),
*.......P/O
        LIFNR     LIKE EKKO-LIFNR,      "공급업체
        NAME1     LIKE LFA1-NAME1,      "공급업체명
        WERKS     LIKE EKPO-WERKS,      "플랜트
        MATNR     LIKE EKPO-MATNR,      "자재번호
        MAKTX     LIKE MAKT-MAKTX,      "자재명
        TXZ01     LIKE EKPO-TXZ01,      "PO내역
        MENGE     LIKE EKPO-MENGE,      "P/O 수량
        MEINS     LIKE EKPO-MEINS,      "P/O 수량 단위
        NETPR     LIKE EKPO-NETPR,      "단가
        WAERS     LIKE EKKO-WAERS,      "통화키
        NETWR     LIKE EKPO-NETWR,      "금액
        BSART     LIKE EKKO-BSART,    "문서유형
        BEDAT     LIKE EKKO-BEDAT,
*        zzmlcca   LIKE ekko-zzmlcca,    "L/C Category
*.......L/C
        REQNO     LIKE ZTITRQK-REQNO,   "수입의뢰관리번호
        AMDSQ     LIKE ZTITRQP-AMDSQ,   "Amend 차수
        REQTYL    LIKE ZTITRQK-REQTY,   "수입의뢰종류
        ZTERM     LIKE ZTITRQS-ZTERM,
        TEXT1     LIKE T052U-TEXT1,
        REQIT     LIKE ZTITRQP-REQIT,   "수입의뢰item
        OPNNO     LIKE ZTITRQS-OPNNO,   "수입개설번호
        OPNDT     LIKE ZTITRQS-OPNDT,   "수입개설일자
        RQMNG     LIKE ZTITRQP-RQMNG,   "수량
        DOCSTL    LIKE ZTITRQS-DOCST,
*> 2008.06.17 --- 사후건 확인하기 위하여 추가
        ANBTY     LIKE ZTITRQK-ANBTY,  "사전/사후 구분자
*< 2008.06.17 --- 사후건 확인하기 위하여 추가
*.......B/L
        IBLNO     LIKE ZTITBLK-IBLNO,   "B/L관리번호
        IBLIT     LIKE ZTITBLP-IBLIT,   "B/L관리번호 ITEM
        BLNUM     LIKE ZTITBLK-BLNUM,   "B/L번호
        INBDT     LIKE ZTITBLK-INBDT,   "실입항일
        BLMNG     LIKE ZTITBLP-BLMNG,   "B/L수량
        BLETD     LIKE ZTITBLK-BLETD,
        BLETA     LIKE ZTITBLK-BLETA,
*.......I/P
        IIPNO     LIKE ZTITIP1-IIPNO,   "보험관리번호
        ISPNO     LIKE ZTITIP1-ISPNO,   "보험증권번호
        IOPDT     LIKE ZTITIP1-IOPDT,   "보험개시일
        DOCST     LIKE ZTITIP1-DOCST,
*.......C/C
        ICCNO     LIKE ZTITCCK-ICCNO,   "통관관리번호
        CDCNO     LIKE ZTITCCK-CDCNO,   "통관수리번호
        CDRDT     LIKE ZTITCCK-CDRDT,   "수리일자
*        netpr_cc  LIKE ztitccp-netpr,   "잠정단가
*        cnfpr     LIKE ztitccp-cnfpr,   "확정단가
        CCMNG     LIKE ZTITCCP-CCMNG,   "통관수량
        DOCSTC    LIKE ZTITCRK-DOCST,
*.......G/R
        IGRNO     LIKE ZTITGRK-IGRNO,   "입고관리번호
        BUDAT_GR  LIKE ZTITGRK-BUDAT,   "전기일
        GRMNG     LIKE ZTITGRP-GRMNG,   "입고수량
*.......I/V
        IVONO     LIKE ZTITIVK-IVONO,   "송장관리번호
        IVNUM     LIKE ZTITIVK-IVNUM,   "송장번호
        RBLGP     LIKE ZTITIVP-RBLGP,     "송장품목번호'
        BELNR     LIKE ZTITIVK-BELNR,   "송장전표번호
        BELNR1    LIKE BKPF-BELNR,      "송장회계문서 번호.
        AJAHR     LIKE ZTITIVK-GJAHR,   "회계년도
        BUDAT     LIKE ZTITIVK-BUDAT,   "전기일
        BLDAT     LIKE ZTITIVK-BLDAT,   "증빙일
        NETDT_IV  LIKE ZTITIVK-NETDT,   "만기일
        REFWR     LIKE ZTITIVP-REFWR,   "송장금액
        IVMNG     LIKE ZTITIVP-IVMNG,   "송장수량
        GJAHR     LIKE ZTITIVK-GJAHR,   "송장년도
        BUKRS     LIKE ZTITIVK-BUKRS,   "회사코드
        LIVST      LIKE ZTITIVK-LIVST,  "문서상태 전기완료, 전기대상.
        PNTNO LIKE ZTITPNK-PNTNO, "Notice관리번호
        GJAHR_CLR LIKE ZTITPNK-GJAHR, "반제전표년도
        BELNR_CLR LIKE ZTITPNK-BELNR, "반제전표
        AUGBL LIKE BSEG-AUGBL, "지급전표
        AUGDT LIKE BSEG-AUGDT, "지급전표일자
*>반입
        IBINO     LIKE ZTITBIK-IBINO,
        BIDNR     LIKE ZTITBIK-BIDNR,
        BLOCC    LIKE ZTITBIK-BLOCC,
        BIWET     LIKE ZTITBIK-BIWET,
        BIMEI     LIKE ZTITBIK-MEINS,
        BILOT       LIKE ZTITBIK-BILOT,
        BINDT      LIKE ZTITBIK-BINDT,
*>반출
        IBONO    LIKE  ZTITBOK-IBONO,
        BODNR   LIKE  ZTITBOK-BODNR,
        BOWET   LIKE  ZTITBOK-BOWET,
        BOUDT   LIKE  ZTITBOK-BOUDT,
        BOMEI   LIKE  ZTITBOK-MEINS.

DATA: END   OF IT_LIST.

DATA: BEGIN OF IT_IMTAB OCCURS 0,
        EBELN     LIKE EKKO-EBELN,      "구매번호
        EBELP     LIKE EKPO-EBELP,      "구매번호아이템
        LIFNR     LIKE EKKO-LIFNR,      "공급업체
        WERKS     LIKE EKPO-WERKS,      "플랜트
        MATNR     LIKE EKPO-MATNR,      "자재번호
        MENGE     LIKE EKPO-MENGE,      "P/O 수량
        MEINS     LIKE EKPO-MEINS,      "P/O 수량 단위
        NETPR     LIKE EKPO-NETPR,      "단가
        WAERS     LIKE EKKO-WAERS,      "통화키
        NETWR     LIKE EKPO-NETWR,      "금액
        BSART     LIKE EKKO-BSART,      "문서유형
        BEDAT     LIKE EKKO-BEDAT,
        TXZ01     LIKE EKPO-TXZ01,      "자재명
      END OF IT_IMTAB.

DATA : BEGIN OF IT_ZTITIG02 OCCURS 0.
        INCLUDE STRUCTURE ZTITIG02.
DATA : END   OF IT_ZTITIG02.

*> ALV용.
* Global variables for handling ALV functionality
DATA: ALV_KEYINFO      TYPE SLIS_KEYINFO_ALV.
DATA: ALV_VARIANT      LIKE DISVARIANT.
DATA: GS_LAYOUT        TYPE SLIS_LAYOUT_ALV.
DATA: ALV_REPID        LIKE SY-REPID.
DATA: ALV_PRINT        TYPE SLIS_PRINT_ALV.
DATA: ST_SORT          TYPE SLIS_SORTINFO_ALV.

DATA: ALV_DETAIL_FUNC(30).
DATA: FC       TYPE SLIS_T_FIELDCAT_ALV,
      FC1      TYPE SLIS_T_FIELDCAT_ALV,
      FCS      TYPE SLIS_FIELDCAT_ALV,
      IT_SORT  TYPE SLIS_T_SORTINFO_ALV.

DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GS_FIELDCAT LIKE LINE OF IT_FIELDCAT.

DATA : S_VARIANT      LIKE  DISVARIANT,
       S_VAR_USR      LIKE  DISVARIANT.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
    C_SAVE(1)   TYPE  C             VALUE 'A',
              C_SUCCESS   TYPE C        VALUE 'S'.
*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : G_LINE          TYPE   I,             "Line counter
       G_SUBRC         LIKE   SY-SUBRC,      "Return code
       G_TABIX         LIKE   SY-TABIX,      "table index
       G_LINE1(3)      TYPE   N,             "LINE COUNT
       G_OUT_TEXT(70)  TYPE   C,             "text field(display)
       G_ERR_MODE      TYPE   C,
       G_MODE          TYPE   C,
       LINE_CNT(02)    TYPE   N,
       G_ANSWER        TYPE   C,
       FIELD_NAME(20),
       FIELD_NAME1(20),
       G_FINDSCR        LIKE SY-DYNNR,
       G_FINDLINE       TYPE I,
       G_FIELDNAME(20)  TYPE C.

DATA: OK-CODE          TYPE SYUCOMM.

DATA : LIFNR_T LIKE LFA1-NAME1,
       PAYER_T LIKE LFA1-NAME1.

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE: <ICON>,
         <SYMBOL>.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BOX1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITIVK-EKORG MODIF  ID IOG,                 "4구매조직
  S_EKGRP  FOR ZTITIVK-EKGRP MODIF  ID IOG,                 "3구매그룹
  S_EBELN  FOR EKKO-EBELN,
  S_EBELP  FOR EKPO-EBELP,
  S_LIFNR  FOR EKKO-LIFNR,
  S_WERKS  FOR EKPO-WERKS,
  S_MATNR  FOR MARA-MATNR,
  S_ZTERM  FOR EKKO-ZTERM,
  S_BEDAT  FOR EKKO-BEDAT.
SELECTION-SCREEN END OF BLOCK BOX1.

SELECTION-SCREEN BEGIN OF BLOCK BOX2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_FULL RADIOBUTTON GROUP PG3 MODIF ID OPN DEFAULT 'X',
            P_LIST RADIOBUTTON GROUP PG3 MODIF ID OPN .
SELECTION-SCREEN END OF BLOCK BOX2.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK ALV WITH FRAME TITLE TEXT-004.
PARAMETERS: ALV_DEF LIKE DISVARIANT-VARIANT." NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK ALV.


************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  SET_INITIAL_DATA.
  PERFORM  SET_ALV_INIT.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR ALV_DEF.
  PERFORM EXEC_ALV_F4.

AT SELECTION-SCREEN.
  PERFORM INPUT_FIELD_CHECK.
  PERFORM ALV_VARIANT_CHECK.

*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-LOW.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-LOW.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-HIGH.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-HIGH.

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM CLEARING_WORK_AREA.      ">Initialize internal table
  PERFORM GET_DATA_FOR_DISPLAY.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  G_LINE1 = 100.
  G_OUT_TEXT = TEXT-905.
  REPLACE '%99999%' WITH G_LINE1 INTO G_OUT_TEXT.
  PERFORM SET_COLORIZE_BUILD.       ">Set color
  PERFORM SET_SORT_FIELD.           ">Set ALV sort fields
  PERFORM SET_FIELDCAT_BUILD.       ">Set ALV field category
  PERFORM DISPLAY_ALV_LIST.         ">Call ALV Functions

************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.

************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  set_initial_data
*&---------------------------------------------------------------------*
FORM SET_INITIAL_DATA .

  DATA: L_BUKRS LIKE T001-BUKRS.
*STATUS
  SET TITLEBAR 'T1000'.

  GET PARAMETER ID 'BUK' FIELD L_BUKRS.

  SELECT SINGLE * FROM T001
                 WHERE BUKRS EQ L_BUKRS.
*  IF sy-subrc NE 0.
*    SELECT SINGLE * FROM t001
*                   WHERE bukrs EQ 'SPC'.
*  ENDIF.

  ALV_REPID = SY-REPID.
* Get default variant
  CLEAR S_VARIANT.
  S_VARIANT-REPORT = SY-REPID.
  S_VAR_USR = S_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = C_SAVE
    CHANGING
      CS_VARIANT = S_VAR_USR
    EXCEPTIONS
      NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    ALV_DEF =  S_VAR_USR-VARIANT.
  ENDIF.


  IF L_BUKRS IS INITIAL.
    L_BUKRS  = '3000'.
  ENDIF.


  SELECT SINGLE * FROM ZTITIG00 WHERE BUKRS EQ L_BUKRS.

ENDFORM.                    " set_initial_data
*&---------------------------------------------------------------------*
*&      Form  set_alv_init
*&---------------------------------------------------------------------*
FORM SET_ALV_INIT .
  FREE:  IT_SORT, FC.
  CLEAR: ALV_KEYINFO, GS_LAYOUT, ALV_PRINT, FC.
* PRINTING SETTINGS
  GS_LAYOUT-GET_SELINFOS = 'X'.
  GS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.

  ALV_PRINT-NO_PRINT_SELINFOS = 'X'.
  ALV_PRINT-NO_COVERPAGE = 'X'.
  ALV_PRINT-NO_PRINT_LISTINFOS = 'X'.

ENDFORM.                    " set_alv_init
*&---------------------------------------------------------------------*
*&      Form  clearing_work_area
*&---------------------------------------------------------------------*
FORM CLEARING_WORK_AREA .

  IF P_FULL EQ 'X'.
    ALV_DETAIL_FUNC = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    ALV_DETAIL_FUNC = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " clearing_work_area
*&---------------------------------------------------------------------*
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
FORM GET_DATA_FOR_DISPLAY .

  DATA : BEGIN OF LT_CCTAB OCCURS 0,
          ICCNO     LIKE ZTITCCK-ICCNO,   "통관관리번호
          CDCNO     LIKE ZTITCCK-CDCNO,   "통관수리번호
          CDRDT     LIKE ZTITCCK-CDRDT,   "수리일자
          CCMNG     LIKE ZTITCCP-CCMNG,   "통관수량
          CFNST     LIKE ZTITCCK-CFNST,   "신고유형
          DOCST    LIKE ZTITCCK-DOCST,   ">by YSH(070730)
  END OF LT_CCTAB.


  DATA : BEGIN OF LT_BLTAB OCCURS 0,
          IBLNO     LIKE ZTITBLK-IBLNO,
          IBLIT     LIKE ZTITBLP-IBLIT,
          BLNUM     LIKE ZTITBLK-BLNUM,
          INBDT     LIKE ZTITBLK-INBDT,
          BLETD     LIKE ZTITBLK-BLETD,
          BLETA     LIKE ZTITBLK-BLETA,
          BLMNG     LIKE ZTITBLP-BLMNG,
          BLDST     LIKE ZTITBLK-BLDST,
         END OF LT_BLTAB.

  DATA : BEGIN OF LT_LCTAB OCCURS 0,
          REQNO     LIKE ZTITRQP-REQNO,
          AMDSQ     LIKE ZTITRQP-AMDSQ,
          REQTYL    LIKE ZTITRQK-REQTY,
          ZTERM     LIKE ZTITRQS-ZTERM,
          TEXT1     LIKE T052U-TEXT1,
          REQIT     LIKE ZTITRQP-REQIT,
          RQMNG     LIKE ZTITRQP-RQMNG,
          OPNNO     LIKE ZTITRQS-OPNNO,
          OPNDT     LIKE ZTITRQS-OPNDT,
          DOCSTL    LIKE ZTITRQS-DOCST,
*> 2008.06.17 --- 사후건 확인하기 위하여 추가
        ANBTY     LIKE ZTITRQK-ANBTY,  "사전/사후 구분자
*< 2008.06.17 --- 사후건 확인하기 위하여 추가
         END OF LT_LCTAB.
  DATA : LT_LIST_T LIKE IT_LIST OCCURS 0 WITH HEADER LINE.
  DATA : LT_EKBE   LIKE EKBE    OCCURS 0 WITH HEADER LINE.

  DATA : L_AMDSQ LIKE ZTITRQP-AMDSQ.

  CLEAR:  IT_LIST,  IT_LIST[],
          IT_IMTAB, IT_IMTAB[].

*> Get import document type and terms of payment .
  PERFORM GET_USED_PAYMENT_TERM(ZTIR0000)  TABLES  IT_ZTITIG02
                                           USING   G_SUBRC C_SUCCESS.
  IF G_SUBRC NE 0.
    EXIT.
  ENDIF.


  SELECT A~EBELN B~EBELP A~LIFNR A~WAERS A~BEDAT
         B~WERKS B~MATNR B~MENGE B~MEINS B~NETPR B~NETWR
**********************************************************
* 20091013 simcho by 유경진S
* 자재품명, 업체명 추가
**********************************************************
         B~TXZ01
           INTO CORRESPONDING FIELDS OF TABLE IT_IMTAB
           FROM EKKO AS A
           JOIN EKPO AS B
             ON A~EBELN = B~EBELN
          FOR ALL ENTRIES IN IT_ZTITIG02
          WHERE A~EBELN   IN S_EBELN
            AND B~EBELP   IN S_EBELP
            AND A~BUKRS   IN S_BUKRS
            AND A~EKORG   IN S_EKORG
            AND A~EKGRP   IN S_EKGRP
            AND A~LIFNR   IN S_LIFNR
            AND A~ZTERM   IN S_ZTERM
            AND A~BEDAT   IN S_BEDAT
            AND  B~WERKS IN S_WERKS
            AND B~MATNR IN S_MATNR
            AND B~LOEKZ   EQ SPACE
            AND A~LOEKZ EQ SPACE
            AND A~MEMORY EQ SPACE
*          AND   frgrl  NE c_true
            AND B~REPOS  NE SPACE
            AND A~BSTYP  EQ IT_ZTITIG02-BSTYP
            AND A~BSART  EQ IT_ZTITIG02-BSART
            AND A~ZTERM  EQ IT_ZTITIG02-ZTERM.


  IF SY-SUBRC NE 0.
    MESSAGE S902.  EXIT.
  ENDIF.

* LC
  LOOP AT IT_IMTAB.
    CLEAR : LT_LIST_T.
    MOVE-CORRESPONDING IT_IMTAB TO LT_LIST_T.
    SELECT B~REQNO B~AMDSQ B~REQIT B~RQMNG A~DOCST AS DOCSTL
           A~OPNNO A~OPNDT A~ZTERM C~REQTY AS REQTYL
           C~ANBTY
           INTO CORRESPONDING FIELDS OF TABLE LT_LCTAB
           FROM ZTITRQP AS B
           JOIN ZTITRQS AS A
             ON A~REQNO = B~REQNO
            AND A~AMDSQ = B~AMDSQ
           JOIN ZTITRQK AS C
             ON A~REQNO = C~REQNO
          WHERE B~EBELN = IT_IMTAB-EBELN
            AND B~EBELP = IT_IMTAB-EBELP.
    IF SY-SUBRC = 0.
      LOOP AT LT_LCTAB.
        CLEAR L_AMDSQ.
        SELECT DISTINCT MAX( AMDSQ ) INTO L_AMDSQ
                                     FROM ZTITRQP
                                    WHERE REQNO = LT_LCTAB-REQNO
                                      AND REQIT = LT_LCTAB-REQIT.
        CHECK L_AMDSQ = LT_LCTAB-AMDSQ.
        MOVE-CORRESPONDING LT_LCTAB TO LT_LIST_T.
*> Terms of payment Text.
        IF NOT LT_LIST_T-ZTERM IS INITIAL.
          SELECT TEXT1
            FROM T052U UP TO 1 ROWS
            INTO LT_LIST_T-TEXT1
           WHERE ZTERM  EQ  LT_LIST_T-ZTERM
             AND SPRAS  EQ  SY-LANGU.
          ENDSELECT.
        ENDIF.

        CASE LT_LIST_T-DOCSTL.
          WHEN 'O'.
            LT_LIST_T-LCICN = ICON_LED_GREEN.
          WHEN OTHERS.
            LT_LIST_T-LCICN = ICON_LED_YELLOW.
        ENDCASE.

        APPEND LT_LIST_T.
      ENDLOOP.
    ELSE.
      LT_LIST_T-LCICN = ICON_LED_RED.
      APPEND LT_LIST_T.
    ENDIF.
  ENDLOOP.


*.B/L
  LOOP AT LT_LIST_T.
    CLEAR IT_LIST.
    MOVE-CORRESPONDING LT_LIST_T TO IT_LIST.
*>사후건 분리하여 REPORT 표시 수정 2008.06.16 BY KSJ
    IF LT_LIST_T-ANBTY EQ 'A'.  ">사후건
      SELECT A~BLNUM A~INBDT A~BLDST A~BLETD A~BLETA
             B~IBLNO B~IBLIT B~BLMNG
             INTO CORRESPONDING FIELDS OF TABLE LT_BLTAB
             FROM ZTITBLK AS A
             JOIN ZTITBLP AS B
               ON A~IBLNO = B~IBLNO
           WHERE B~EBELN = LT_LIST_T-EBELN
             AND B~EBELP = LT_LIST_T-EBELP.
*           AND b~reqno = lt_list_t-reqno    ">사후건은 의뢰no가 없음
*           AND b~reqit = lt_list_t-reqit.
    ELSE.          ">사전
      SELECT A~BLNUM A~INBDT A~BLDST A~BLETD A~BLETA
             B~IBLNO B~IBLIT B~BLMNG
             INTO CORRESPONDING FIELDS OF TABLE LT_BLTAB
             FROM ZTITBLK AS A
             JOIN ZTITBLP AS B
               ON A~IBLNO = B~IBLNO
           WHERE B~EBELN = LT_LIST_T-EBELN
             AND B~EBELP = LT_LIST_T-EBELP
             AND B~REQNO = LT_LIST_T-REQNO
             AND B~REQIT = LT_LIST_T-REQIT.
    ENDIF.
    IF SY-SUBRC = 0.
      LOOP AT LT_BLTAB.
        MOVE-CORRESPONDING LT_BLTAB TO IT_LIST.
        IT_LIST-BLICN = ICON_LED_GREEN.

        APPEND IT_LIST.
      ENDLOOP.
    ELSE.
      IT_LIST-BLICN = ICON_LED_RED.
      APPEND IT_LIST.
    ENDIF.
  ENDLOOP.


  LOOP AT IT_LIST.
*.I/P
    IF IT_LIST-ANBTY EQ 'A'.    ">사후건
      SELECT SINGLE IIPNO ISPNO IOPDT DOCST
                    INTO CORRESPONDING FIELDS OF IT_LIST
                    FROM ZTITIP1
                   WHERE REQNO EQ IT_LIST-REQNO
                     AND IBLNO EQ IT_LIST-IBLNO.
    ELSE.
      SELECT SINGLE IIPNO ISPNO IOPDT DOCST
                    INTO CORRESPONDING FIELDS OF IT_LIST
                    FROM ZTITIP1
                   WHERE REQNO EQ IT_LIST-REQNO
                     AND EBELN EQ IT_LIST-EBELN.
    ENDIF.
    IF SY-SUBRC = 0.
      CASE IT_LIST-DOCST.
        WHEN 'O'.
          IT_LIST-IPICN = ICON_LED_GREEN.
        WHEN OTHERS.
          IT_LIST-IPICN = ICON_LED_YELLOW.
      ENDCASE.
    ELSE.
      IT_LIST-IPICN = ICON_LED_RED.
    ENDIF.

*.C/C
    CLEAR : LT_CCTAB, LT_CCTAB[].
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_CCTAB
             FROM   ZTITCCK AS A
               JOIN ZTITCCP AS B
                 ON A~ICCNO = B~ICCNO
                AND A~ICCSQ = B~ICCSQ
            WHERE B~EBELN EQ IT_LIST-EBELN
              AND B~EBELP EQ IT_LIST-EBELP
              AND B~IBLNO EQ IT_LIST-IBLNO
              AND B~IBLIT EQ IT_LIST-IBLIT
              AND A~CFNST IN ('C', 'H').

    IF SY-SUBRC = 0.

      READ TABLE LT_CCTAB WITH KEY CFNST = 'C'.
      IF SY-SUBRC = 0.
        MOVE : LT_CCTAB-ICCNO TO IT_LIST-ICCNO,
               LT_CCTAB-CDCNO TO IT_LIST-CDCNO,
               LT_CCTAB-CDRDT TO IT_LIST-CDRDT,

               LT_CCTAB-CCMNG TO IT_LIST-CCMNG.
      ELSE.
        READ TABLE LT_CCTAB WITH KEY CFNST = 'H'.
        MOVE : LT_CCTAB-ICCNO TO IT_LIST-ICCNO,
               LT_CCTAB-CDCNO TO IT_LIST-CDCNO,
               LT_CCTAB-CDRDT TO IT_LIST-CDRDT,
               LT_CCTAB-CCMNG TO IT_LIST-CCMNG.
      ENDIF.
      MOVE  LT_CCTAB-DOCST TO IT_LIST-DOCSTC.

      CASE IT_LIST-DOCSTC.
        WHEN 'O'.
          IT_LIST-CCICN = ICON_LED_GREEN.
        WHEN OTHERS.
          IT_LIST-CCICN = ICON_LED_YELLOW.
      ENDCASE.
    ELSE.
      DATA : BEGIN OF LS_ZTITCRP,
          ICCNO     LIKE ZTITCRP-ICCNO,
      END OF LS_ZTITCRP.
      SELECT SINGLE  ICCNO INTO CORRESPONDING FIELDS OF LS_ZTITCRP
         FROM   ZTITCRP AS A
        WHERE A~EBELN EQ IT_LIST-EBELN
          AND A~EBELP EQ IT_LIST-EBELP
          AND A~IBLNO EQ IT_LIST-IBLNO
          AND A~IBLIT EQ IT_LIST-IBLIT.
      IF SY-SUBRC = 0.
        IT_LIST-ICCNO = LS_ZTITCRP-ICCNO.
        IT_LIST-CCICN = ICON_LED_YELLOW.
      ELSE.
        IT_LIST-CCICN = ICON_LED_RED.
      ENDIF.
    ENDIF.

*.G/R
    SELECT SINGLE A~IGRNO A~BUDAT AS BUDAT_GR B~GRMNG
                  INTO CORRESPONDING FIELDS OF IT_LIST
                  FROM ZTITGRK AS A
                  JOIN ZTITGRP AS B
                    ON A~IGRNO = B~IGRNO
                 WHERE B~EBELN EQ IT_LIST-EBELN
                   AND B~EBELP EQ IT_LIST-EBELP
                   AND B~IBLNO EQ IT_LIST-IBLNO
                   AND B~IBLIT EQ IT_LIST-IBLIT.
    IF SY-SUBRC = 0.
      IT_LIST-GRICN = ICON_LED_GREEN.
    ELSE.  "> 실패시 BL ITEM 제외후 재검색 2008.06.26
      SELECT SINGLE A~IGRNO A~BUDAT AS BUDAT_GR B~GRMNG
                    INTO CORRESPONDING FIELDS OF IT_LIST
                    FROM ZTITGRK AS A
                    JOIN ZTITGRP AS B
                      ON A~IGRNO = B~IGRNO
                   WHERE B~EBELN EQ IT_LIST-EBELN
                     AND B~EBELP EQ IT_LIST-EBELP
                     AND B~IBLNO EQ IT_LIST-IBLNO.
*                     AND b~iblit EQ it_list-iblit.
      IF SY-SUBRC = 0.
        IT_LIST-GRICN = ICON_LED_GREEN.
      ELSE.
        IT_LIST-GRICN = ICON_LED_RED.
      ENDIF.
    ENDIF.

*.I/V
    IF IT_LIST-ANBTY EQ 'A'.  ">사후
      SELECT SINGLE A~IVONO B~RBLGP A~IVNUM A~BUDAT
                    A~BLDAT A~NETDT AS NETDT_IV
                    A~BELNR A~GJAHR AS AJAHR A~LIVST
                    B~REFWR B~IVMNG A~GJAHR A~BUKRS
                    INTO CORRESPONDING FIELDS OF IT_LIST
                    FROM ZTITIVK AS A
                    JOIN ZTITIVP AS B
                      ON A~IVONO = B~IVONO
              WHERE B~EBELN EQ IT_LIST-EBELN
                AND B~EBELP EQ IT_LIST-EBELP
*                AND b~reqno EQ it_list-reqno
*                AND b~reqit EQ it_list-reqit
                AND B~IBLNO EQ IT_LIST-IBLNO
                AND B~IBLIT EQ IT_LIST-IBLIT.
    ELSE.
      SELECT SINGLE A~IVONO B~RBLGP A~IVNUM A~BUDAT
                    A~BLDAT A~NETDT AS NETDT_IV
                    A~BELNR A~GJAHR AS AJAHR A~LIVST
                    B~REFWR B~IVMNG A~GJAHR A~BUKRS
                    INTO CORRESPONDING FIELDS OF IT_LIST
                    FROM ZTITIVK AS A
                    JOIN ZTITIVP AS B
                      ON A~IVONO = B~IVONO
              WHERE B~EBELN EQ IT_LIST-EBELN
                AND B~EBELP EQ IT_LIST-EBELP
                AND B~REQNO EQ IT_LIST-REQNO
                AND B~REQIT EQ IT_LIST-REQIT
                AND B~IBLNO EQ IT_LIST-IBLNO
                AND B~IBLIT EQ IT_LIST-IBLIT.
    ENDIF.
    IF SY-SUBRC <> 0.
      IF IT_LIST-REQTYL = 'TT'.
        IF IT_LIST-ANBTY EQ 'A'.  ">사후
          SELECT SINGLE A~IVONO A~IVNUM A~BUDAT
                        A~BLDAT A~NETDT AS NETDT_IV
                        A~BELNR A~GJAHR AS AJAHR A~LIVST
                        B~REFWR B~IVMNG A~GJAHR A~BUKRS
                        INTO CORRESPONDING FIELDS OF IT_LIST
                        FROM ZTITIVK AS A
                        JOIN ZTITIVP AS B
                          ON A~IVONO = B~IVONO
                  WHERE B~EBELN EQ IT_LIST-EBELN
                    AND B~EBELP EQ IT_LIST-EBELP
                    AND B~IBLNO EQ IT_LIST-IBLNO
                    AND B~IBLIT EQ IT_LIST-IBLIT.

        ELSE.
          SELECT SINGLE A~IVONO A~IVNUM A~BUDAT
                        A~BLDAT A~NETDT AS NETDT_IV
                        A~BELNR A~GJAHR AS AJAHR A~LIVST
                        B~REFWR B~IVMNG A~GJAHR A~BUKRS
                        INTO CORRESPONDING FIELDS OF IT_LIST
                        FROM ZTITIVK AS A
                        JOIN ZTITIVP AS B
                          ON A~IVONO = B~IVONO
                  WHERE B~EBELN EQ IT_LIST-EBELN
                    AND B~EBELP EQ IT_LIST-EBELP
                    AND B~REQNO EQ IT_LIST-REQNO
                    AND B~REQIT EQ IT_LIST-REQIT.
        ENDIF.
      ENDIF.
    ENDIF.
    IF SY-SUBRC = 0.
      IT_LIST-IVICN = ICON_LED_GREEN.
*...전표
      DATA : L_AWKEY LIKE BKPF-AWKEY,
             L_AWTYP LIKE BKPF-AWTYP,
             L_BELNR LIKE BKPF-BELNR,
             L_GJAHR LIKE BKPF-GJAHR.

*      CONCATENATE it_list-ivnum it_list-gjahr INTO l_awkey.
      CONCATENATE IT_LIST-BELNR IT_LIST-GJAHR INTO L_AWKEY.

      L_AWTYP       = 'RMRP '.
      CLEAR : L_BELNR, L_GJAHR.

      SELECT SINGLE BELNR GJAHR
        INTO (L_BELNR, L_GJAHR)
        FROM BKPF
       WHERE AWTYP  EQ  L_AWTYP
         AND AWKEY  EQ  L_AWKEY.

      IT_LIST-BELNR1 =  L_BELNR.

      CASE  IT_LIST-LIVST.
        WHEN 'N'.
          IT_LIST-IVICN = ICON_LED_YELLOW.
        WHEN OTHERS.
          IT_LIST-IVICN = ICON_LED_GREEN.
      ENDCASE.
    ELSE.
      IT_LIST-IVICN = ICON_LED_RED.
    ENDIF.


*...TEXT
    PERFORM VENDOR_NAME USING: IT_LIST-LIFNR
                               IT_LIST-NAME1.

    PERFORM MATERIAL_NAME USING: IT_LIST-MATNR
                                 IT_LIST-MAKTX.
*

    MODIFY IT_LIST.
    CLEAR IT_LIST.
  ENDLOOP.

  DESCRIBE TABLE IT_LIST LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S902.
  ENDIF.

ENDFORM.                    " get_data_for_display
*&---------------------------------------------------------------------*
*&      Form  display_alv_list
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST .

  DATA: FC_DETAIL TYPE SLIS_FIELDCAT_ALV OCCURS 0 WITH HEADER LINE.
  DATA: VARIANT_DETAIL      LIKE DISVARIANT.
  DATA: EXIT     TYPE SLIS_EVENT_EXIT   OCCURS 0 WITH HEADER LINE.
  DATA: EVENTS   TYPE SLIS_ALV_EVENT    OCCURS 0 WITH HEADER LINE.
  DATA: GROUPS   TYPE SLIS_SP_GROUP_ALV OCCURS 0 WITH HEADER LINE.

  SET TITLEBAR 'T1000'.
* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH FC_DETAIL.
  LOOP AT IT_FIELDCAT INTO GS_FIELDCAT.
    MOVE-CORRESPONDING GS_FIELDCAT TO FC_DETAIL.
    CLEAR FC_DETAIL-TABNAME.
    APPEND FC_DETAIL.
  ENDLOOP.

  CLEAR VARIANT_DETAIL.
  VARIANT_DETAIL-REPORT = ALV_REPID.
  VARIANT_DETAIL-HANDLE = ' '.

  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'BOX'.

*>color field define.
*  gs_layout-coltab_fieldname  = 'COLOR'.
*  gs_layout-group_change_edit = 'X'.
  GS_LAYOUT-F2CODE            = 'DISPLAY'.

* header.
*  gs_layout-no_colhead        = 'X'.

*  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
*  gs_layout-totals_text = ' TOTAL'.

  REFRESH EXIT.
  EXIT-UCOMM = '&OL0'. EXIT-AFTER = 'X'. APPEND EXIT.
  EXIT-UCOMM = '&OLX'. APPEND EXIT.
  EXIT-UCOMM = '&OAD'. APPEND EXIT.

*> event define.
  REFRESH EVENTS.
  EVENTS-NAME = SLIS_EV_TOP_OF_PAGE.
  EVENTS-FORM = 'TOP_OF_PAGE'.
  APPEND EVENTS.

  EVENTS-NAME = SLIS_EV_SUBTOTAL_TEXT.
  EVENTS-FORM = SLIS_EV_SUBTOTAL_TEXT.
  APPEND EVENTS.

  EVENTS-NAME = SLIS_EV_PF_STATUS_SET.
  EVENTS-FORM = 'SET_ALV_STATUS'.
  APPEND EVENTS.

  EVENTS-NAME = SLIS_EV_CONTEXT_MENU.
  EVENTS-FORM = 'SET_CONTEXT_MENU'.
  APPEND EVENTS.


*> ALV reuse function call..
  CALL FUNCTION  ALV_DETAIL_FUNC
      EXPORTING
        I_CALLBACK_PROGRAM       = ALV_REPID
*        i_callback_pf_status_set = 'SET_ALV_STATUS'
        I_CALLBACK_USER_COMMAND  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      IT_EVENTS                      = EVENTS[]
      IT_EVENT_EXIT                  = EXIT[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        IT_FIELDCAT              = FC_DETAIL[]
        IT_SORT                  = IT_SORT
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        IS_VARIANT               = ALV_VARIANT
        I_SAVE                   = C_SAVE
        IS_LAYOUT                = GS_LAYOUT
        IS_PRINT                 = ALV_PRINT
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        T_OUTTAB                 = IT_LIST[].

ENDFORM.                    " display_alv_list
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM SET_ALV_STATUS USING  EXTAB TYPE SLIS_T_EXTAB.

  APPEND 'ARCHIVE'   TO EXTAB.
  APPEND '&VEXCEL'   TO EXTAB.
  APPEND '&AQW'      TO EXTAB.
  APPEND '&VCRYSTAL' TO EXTAB.
  APPEND '&VGRID'    TO EXTAB.
  APPEND '&EB9'      TO EXTAB.
  APPEND '&CRDESIG'  TO EXTAB.

*  APPEND '&OL0'  TO extab.
*  APPEND '&OAD'  TO extab.
*  APPEND '&AVE'  TO extab.

*  SET TITLEBAR 'T1000'.
  SET PF-STATUS 'STANDARD' EXCLUDING EXTAB.

ENDFORM.                    " SET_ALV_STATUS
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_BUILD .

  PERFORM 3010_FILL_FIELD_CATEGORY USING :

       'S' 'TABNAME'     'IT_LIST',     "BOX
       ' ' 'FIELDNAME'   'BOX',
       ' ' 'NO_OUT'      'X',
       'E' 'OUTPUTLEN'   '1',

       'S' 'REF_TABNAME'  'EKKO',       "구매번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'EBELN',
       ' ' 'HOTSPOT'      'X',
       ' ' 'KEY'          'X',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'EKPO',       "구매번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'EBELP',
       ' ' 'HOTSPOT'      'X',
       ' ' 'KEY'          'X',
       'E' 'OUTPUTLEN'    '4',

* 상태
       'S' 'TABNAME'     'IT_LIST',      "L/C아이콘
       ' ' 'SELTEXT_S'   'L/C진행',
       ' ' 'SELTEXT_M'   'L/C진행',
       ' ' 'FIELDNAME'   'LCICN',
       ' ' 'KEY'          'X',
       ' ' 'ICON'         'X',
       'E' 'OUTPUTLEN'    '4',

       'S' 'TABNAME'     'IT_LIST',      "B/L아이콘
       ' ' 'SELTEXT_S'   'B/L진행',
       ' ' 'SELTEXT_M'   'B/L진행',
       ' ' 'FIELDNAME'   'BLICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

       'S' 'TABNAME'     'IT_LIST',      "부보 아이콘 - 기능개선 278454
       ' ' 'SELTEXT_S'   'I/P진행',
       ' ' 'SELTEXT_M'   'I/P진행',
       ' ' 'FIELDNAME'   'IPICN',
       ' ' 'KEY'          'X',
       ' ' 'ICON'         'X',
       'E' 'OUTPUTLEN'    '4',


       'S' 'TABNAME'     'IT_LIST',      "I/V아이콘
       ' ' 'SELTEXT_S'   'I/V진행',
       ' ' 'SELTEXT_M'   'I/V진행',
       ' ' 'FIELDNAME'   'IVICN',
       ' ' 'KEY'          'X',
       ' ' 'ICON'         'X',
       'E' 'OUTPUTLEN'    '4',




       'S' 'TABNAME'     'IT_LIST',      "C/C아이콘
       ' ' 'SELTEXT_S'   'C/C진행',
       ' ' 'SELTEXT_M'   'C/C진행',
       ' ' 'FIELDNAME'   'CCICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

       'S' 'TABNAME'     'IT_LIST',      "G/R아이콘
       ' ' 'SELTEXT_S'   'G/R진행',
       ' ' 'SELTEXT_M'   'G/R진행',
       ' ' 'FIELDNAME'   'GRICN',
       ' ' 'KEY'         'X',
       ' ' 'ICON'        'X',
       'E' 'OUTPUTLEN'   '4',

* P/O
       'S' 'REF_TABNAME'  'EKPO',      "자재번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MATNR',
       ' ' 'EMPHASIZE'   'C100',
       ' ' 'HOTSPOT'      'X',
       'E' 'OUTPUTLEN'    '10',

*************************************************************
* CSR No. : C20091013_39827
* Display 추가 : 자재명, 공급업체 정보
*************************************************************

       'S' 'REF_TABNAME'  'MARA',       "자재명
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'SELTEXT_S'    '자재명',
       ' ' 'SELTEXT_M'    '자재명',
       ' ' 'FIELDNAME'    'MAKTX',
       'E' 'OUTPUTLEN'    '30',

       'S' 'REF_TABNAME'  'LFA1',       "업체코드
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'LIFNR',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'LFA1',       "업체명
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'NAME1',
       'E' 'OUTPUTLEN'    '30',
*************************************************************

*       'S' 'REF_TABNAME'  'MAKT',      "자재명
*       ' ' 'TABNAME'      'IT_LIST',
*       ' ' 'FIELDNAME'    'MAKTX',
*       ' ' 'EMPHASIZE'   'C100',
*       'E' 'OUTPUTLEN'    '30',

       'S' 'REF_TABNAME'  'EKPO',      "P/O 수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MENGE',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C100',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'EKPO',      "P/O 수량 단위
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'MEINS',
       ' ' 'EMPHASIZE'   'C100',
       'E' 'OUTPUTLEN'    '3',

       'S' 'REF_TABNAME'  'EKKO',      "일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BEDAT',
       ' ' 'EMPHASIZE'    'C100',
       'E' 'OUTPUTLEN'    '10',

*. L/C
       'S' 'REF_TABNAME'  'ZTITRQK',      "수입의뢰관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'REQNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITRQP',      "Amend 차수
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'AMDSQ',
*       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'    'C200',
*       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '2',

       'S' 'REF_TABNAME'  'ZTITRQP',      "수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'RQMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITRQS',      "수입개설일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'OPNDT',
       ' ' 'EMPHASIZE'    'C200',
       'E' 'OUTPUTLEN'    '10',

* B/L
       'S' 'REF_TABNAME'  'ZTITBLK',      "B/L관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IBLNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',


       'S' 'REF_TABNAME'  'ZTITBLP',      "B/L수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'    'C300',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITBLK',      "ETD
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLETD',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITBLK',      "ETA
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BLETA',
       ' ' 'EMPHASIZE'   'C300',
       'E' 'OUTPUTLEN'    '10',

* I/P - 기능개선 278454 추가
       'S' 'REF_TABNAME'  'ZTITIP1',      "I/P 관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IIPNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C700',
       'E' 'OUTPUTLEN'    '10',


       'S' 'REF_TABNAME'  'ZTITIP1',      "보험증권번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'ISPNO',
       ' ' 'EMPHASIZE'    'C700',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITIP1',      "보험 개시일
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IOPDT',
       ' ' 'EMPHASIZE'    'C700',
       'E' 'OUTPUTLEN'    '10',

*. I/V
       'S' 'REF_TABNAME'  'ZTITIVK',      "I/V 관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IVONO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'     'C200',
       'E' 'OUTPUTLEN'    '10',


       'S' 'REF_TABNAME'  'ZTITIVP',      "I/V 수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IVMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'EMPHASIZE'     'C200',
       'E' 'OUTPUTLEN'    '15',


       'S' 'REF_TABNAME'  'ZTITIVK',      "I/V 전기일
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BUDAT',
       ' ' 'EMPHASIZE'     'C200',
       'E' 'OUTPUTLEN'    '15',


*. C/C
       'S' 'REF_TABNAME'  'ZTITCCK',      "통관관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'ICCNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITCCP',      "통관수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'CCMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITCCK',      "수리일자
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'CDRDT',
       ' ' 'EMPHASIZE'   'C500',
       'E' 'OUTPUTLEN'    '10',

* G/R
       'S' 'REF_TABNAME'  'ZTITGRK',      "입고관리번호
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'IGRNO',
       ' ' 'HOTSPOT'      'X',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '10',

       'S' 'REF_TABNAME'  'ZTITGRP',      "입고수량
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'GRMNG',
       ' ' 'QFIELDNAME'   'MEINS',
       ' ' 'QTABNAME'     'IT_LIST',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '15',

       'S' 'REF_TABNAME'  'ZTITGRK',      "전기일
       ' ' 'REF_FIELDNAME' 'BUDAT',
       ' ' 'TABNAME'      'IT_LIST',
       ' ' 'FIELDNAME'    'BUDAT_GR',
       ' ' 'EMPHASIZE'   'C600',
       'E' 'OUTPUTLEN'    '10'.




ENDFORM.                    " set_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_FILL_FIELD_CATEGORY  USING    P_SECTION P_FNAME P_VALUE.

  DATA L_COL(40).
  FIELD-SYMBOLS <L_FS>.

  IF P_SECTION = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT-' P_FNAME  INTO L_COL.
  ASSIGN      (L_COL)         TO       <L_FS>.
  MOVE         P_VALUE        TO       <L_FS>.

  IF P_SECTION = 'E'.
    APPEND GS_FIELDCAT TO IT_FIELDCAT.
  ENDIF.

ENDFORM.                    " 3010_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
FORM SET_COLORIZE_BUILD .

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  set_sort_field
*&---------------------------------------------------------------------*
FORM SET_SORT_FIELD .

  CLEAR  ST_SORT.
  ST_SORT-SPOS      = '01'.
  ST_SORT-FIELDNAME = 'EBELN'.
  ST_SORT-TABNAME   = 'IT_LIST'.
*  st_sort-up        = 'X'.
  ST_SORT-DOWN      = 'X'.
  ST_SORT-GROUP     = 'X'.
  ST_SORT-SUBTOT    = 'X'.
*      ST_SORT-EXPA      = 'X'.
  APPEND ST_SORT TO IT_SORT.

ENDFORM.                    " set_sort_field
*&---------------------------------------------------------------------*
*&      Form  exec_alv_f4
*&---------------------------------------------------------------------*
FORM EXEC_ALV_F4 .

  ALV_REPID = SY-REPID.
  CLEAR: ALV_VARIANT.
  ALV_VARIANT-REPORT = ALV_REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT = ALV_VARIANT
      I_SAVE     = 'A'
    IMPORTING
      ES_VARIANT = ALV_VARIANT
    EXCEPTIONS
      NOT_FOUND  = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    ALV_DEF = ALV_VARIANT-VARIANT.
  ENDIF.

ENDFORM.                    " exec_alv_f4
*&---------------------------------------------------------------------*
*&      Form  alv_variant_check
*&---------------------------------------------------------------------*
FORM ALV_VARIANT_CHECK .

  ALV_VARIANT-REPORT = ALV_REPID.
  ALV_VARIANT-VARIANT = ALV_DEF.
  IF NOT ALV_DEF IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        I_SAVE     = 'A'
      CHANGING
        CS_VARIANT = ALV_VARIANT
      EXCEPTIONS
        OTHERS     = 1.
    IF SY-SUBRC <> 0.
      MESSAGE E321(M7) WITH ALV_DEF ALV_REPID.
    ENDIF.
  ENDIF.


ENDFORM.                    " alv_variant_check
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: L_MODE TYPE I.
  DATA: HEADER TYPE SLIS_LISTHEADER OCCURS 0 WITH HEADER LINE.
  DATA: L_HEADER(20) TYPE C.



  REFRESH HEADER.
  HEADER-TYP = 'H'.
  HEADER-INFO = '진행리스트'.

  CONCATENATE L_HEADER HEADER-INFO INTO HEADER-INFO
                                     SEPARATED BY SPACE.

  CLEAR: HEADER-KEY.
  APPEND HEADER.

  HEADER-TYP = 'S'.
  HEADER-KEY = '출력일자:'(106).
  WRITE: SY-DATLO TO HEADER-INFO.
  APPEND HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = HEADER[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INPUT_FIELD_CHECK .

* Company code
*  SELECT SINGLE *
*    FROM t001
*   WHERE bukrs IN s_bukrs.
*  IF sy-subrc <> 0.
*    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
*                                CHANGING dfies g_subrc.
*    SET CURSOR FIELD 'S_BUKRS'.
*    MESSAGE e348(m7) WITH dfies-scrtext_m.
*  ENDIF.

ENDFORM.                    " input_field_check
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain Text Read
*----------------------------------------------------------------------*
FORM GET_DOMAIN_VALUE_TEXT  USING  P_DOMAIN LIKE  DD07L-DOMNAME
                                   P_VALUE
                                   P_TEXT.

  DATA: L_VALUE  LIKE DD07V-DOMVALUE_L,
        L_TEXT   LIKE DD07V-DDTEXT.

  CLEAR: L_TEXT.

  MOVE: P_VALUE TO L_VALUE.

  CALL FUNCTION 'RV_DOMAIN_VALUE_TEXTS'
    EXPORTING
      DOMNAME  = P_DOMAIN
      DOMVALUE = L_VALUE
    IMPORTING
      DDTEXT   = L_TEXT.

  MOVE: L_TEXT TO P_TEXT.

ENDFORM.                    " CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM USER_ALV_COMMAND USING   R_UCOMM      LIKE SY-UCOMM
                              RS_SELFIELD  TYPE SLIS_SELFIELD.


  CASE R_UCOMM.
    WHEN 'REFRESH'.
      PERFORM GET_DATA_FOR_DISPLAY.    ">data select
      RS_SELFIELD-REFRESH = 'X'.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
      CHECK : RS_SELFIELD-TABINDEX GT 0 AND
              RS_SELFIELD-TABINDEX LT 99999999999.

      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.
      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER  USING IT_LIST-EBELN
                                                IT_LIST-EBELP.

        WHEN 'REQNO'.
          PERFORM DISPLAY_IMPORT_DOCUMENT USING IT_LIST-REQNO
                                                IT_LIST-AMDSQ
                                                SPACE.
        WHEN 'IBLNO'.
          PERFORM DISPLAY_BL_DOCUMENT     USING IT_LIST-IBLNO
                                                SPACE.

        WHEN 'IIPNO'.
          PERFORM DISPLAY_IP_DOCUMENT     USING IT_LIST-IIPNO
                                                SPACE.

        WHEN 'ICCNO'.
          PERFORM DISPLAY_CC_DOCUMENT     USING IT_LIST-ICCNO
                                                SPACE.

        WHEN 'IGRNO'.
          PERFORM DISPLAY_GR_DOCUMENT     USING IT_LIST-IGRNO.

        WHEN 'IVONO'.
          PERFORM DISPLAY_CIV_DOCUMENT    USING IT_LIST-IVONO.

        WHEN 'PNTNO'.
          PERFORM DISPLAY_PN_DOCUMENT    USING IT_LIST-PNTNO.

        WHEN 'MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER    USING IT_LIST-MATNR
                                                   IT_LIST-WERKS
                                                   SPACE.

        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER    USING IT_LIST-LIFNR
                                                 SPACE.
        WHEN 'BELNR'.
          PERFORM DISPLAY_LIV_DOCUMENT    USING IT_LIST-BELNR
                                                IT_LIST-AJAHR
                                                S_BUKRS-LOW.
        WHEN 'BELNR1'.
          PERFORM DISPLAY_FI_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-BELNR1
                                                IT_LIST-AJAHR
                                                S_BUKRS-LOW.
        WHEN 'BELNR_CLR'.
          PERFORM DISPLAY_FI_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-BELNR_CLR
                                                IT_LIST-GJAHR_CLR
                                                S_BUKRS-LOW.

        WHEN 'AUGBL'.
          PERFORM DISPLAY_FI_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-AUGBL
                                                IT_LIST-AUGDT
                                                S_BUKRS-LOW.

        WHEN 'IBINO'.
          PERFORM DISPLAY_BI_DOCUMENT     USING IT_LIST-IBINO.

        WHEN 'IBONO'.
          PERFORM DISPLAY_BO_DOCUMENT     USING IT_LIST-IBONO.


      ENDCASE.

*...Create
    WHEN 'ZTICREATE'.  "CREATE

    WHEN OTHERS.
      PERFORM CONTEXT_MENU_TCODE USING R_UCOMM.
  ENDCASE.
  CLEAR: R_UCOMM.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  VENDOR_NAME
*&---------------------------------------------------------------------*
FORM VENDOR_NAME  USING    P_LIFNR
                           P_NAME1.

  SELECT SINGLE NAME1 INTO P_NAME1
                      FROM LFA1
                     WHERE LIFNR EQ P_LIFNR.

ENDFORM.                    " VENDOR_NAME
*&---------------------------------------------------------------------*
*&      Form  display_import_document
*&---------------------------------------------------------------------*
FORM DISPLAY_IMPORT_DOCUMENT  USING    P_REQNO
                                       P_AMDSQ
                                       P_REQIT.
  CHECK NOT P_REQNO IS INITIAL.

  SET PARAMETER ID 'ZTIREQNO' FIELD P_REQNO.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD P_AMDSQ.
  SET PARAMETER ID 'ZTIREQIT' FIELD P_REQIT.
  SET PARAMETER ID 'BES'      FIELD SPACE.
  SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.

  CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN..

ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  display_bl_document
*&---------------------------------------------------------------------*
FORM DISPLAY_BL_DOCUMENT      USING    P_IBLNO
                                       P_IBLIT.
  CHECK NOT P_IBLNO IS INITIAL.

  SET PARAMETER ID 'ZTIIBLNO' FIELD P_IBLNO.
  SET PARAMETER ID 'ZTIIBLIT' FIELD P_IBLIT.
  SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.

  CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  display_IP_document
*&---------------------------------------------------------------------*
*       A cargo insurance document is display
*----------------------------------------------------------------------*
FORM DISPLAY_IP_DOCUMENT  USING        P_IIPNO
                                       P_AMDSQ.

  CHECK NOT P_IIPNO IS INITIAL.

  SET PARAMETER ID 'ZTIIIPNO' FIELD P_IIPNO.
  SET PARAMETER ID 'ZTIAMSEQ' FIELD P_AMDSQ.
*   SET PARAMETER ID 'BES'      FIELD space.
*   SET PARAMETER ID 'ZTIOPNNO' FIELD space.
*
  CALL TRANSACTION 'ZTIT103' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_ip_document
*&---------------------------------------------------------------------*
*&      Form  display_CC_document
*&---------------------------------------------------------------------*

FORM DISPLAY_CC_DOCUMENT      USING    P_ICCNO
                                       P_ICCSQ.

  CHECK NOT P_ICCNO IS INITIAL.

  SET PARAMETER ID 'ZTIICCNO' FIELD P_ICCNO.
  SET PARAMETER ID 'ZTIICCSQ' FIELD P_ICCSQ.
  SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
  SET PARAMETER ID 'BES'      FIELD SPACE.

  CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_cc_document
*&---------------------------------------------------------------------*
*&      Form  display_GR_document
*&---------------------------------------------------------------------*
FORM DISPLAY_GR_DOCUMENT      USING    P_IGRNO.

  CHECK NOT P_IGRNO IS INITIAL.

  SET PARAMETER ID 'ZTIIGRNO' FIELD P_IGRNO.
  SET PARAMETER ID 'ZTIICCNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
  SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD SPACE.
  SET PARAMETER ID 'BES'      FIELD SPACE.

  CALL TRANSACTION 'ZTIT503' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_gr_document
*&---------------------------------------------------------------------*
*&      Form  display_CIV_document
*&---------------------------------------------------------------------*
FORM DISPLAY_CIV_DOCUMENT      USING    P_IVONO.

  CHECK NOT P_IVONO IS INITIAL.

  SET PARAMETER ID 'ZTIIVONO' FIELD P_IVONO.
  SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
  SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
  SET PARAMETER ID 'BES'      FIELD SPACE.

  CALL TRANSACTION 'ZTIT303' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_civ_document
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  display_PN_document
*&---------------------------------------------------------------------*
FORM DISPLAY_PN_DOCUMENT      USING    P_PNTNO.

  CHECK NOT P_PNTNO IS INITIAL.

  SET PARAMETER ID 'ZTIPNTNO' FIELD P_PNTNO.
  SET PARAMETER ID 'ZTIICCNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
  SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
  SET PARAMETER ID 'ZTIAMDSQ' FIELD SPACE.
  SET PARAMETER ID 'BES'      FIELD SPACE.

  CALL TRANSACTION 'ZTIT803' AND SKIP FIRST SCREEN.

ENDFORM.                    " display_pn_document
*&---------------------------------------------------------------------*
*&      Form  display_purchase_order
*&---------------------------------------------------------------------*
FORM DISPLAY_PURCHASE_ORDER  USING    P_EBELN  LIKE EKPO-EBELN
                                      P_EBELP  LIKE EKPO-EBELP.

  CHECK NOT P_EBELN IS INITIAL.
*   IF sy-binpt IS INITIAL.
*     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD c_true.
*   ELSE.
*     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD c_false.
*   ENDIF.
*   CLEAR: sy-binpt .

  CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
    EXPORTING
      I_EBELN                    = P_EBELN
      I_EBELP                    = P_EBELP
      I_ENJOY                    = 'X'
*       i_enjoy                    = c_true
*        I_PREVIEW                  =
*        I_DATA_FROM_BUFFER         =
*        I_BSTYP                    =
*        I_DISPLAY_ONLY             = ' '
*        I_EDIT                     = ' '
*        I_ETENR                    =
*        I_DOC_INITIATOR            =
   EXCEPTIONS
     NOT_FOUND                  = 1
     NO_AUTHORITY               = 2
     INVALID_CALL               = 3
     PREVIEW_NOT_POSSIBLE       = 4
     OTHERS                     = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " display_purchase_order
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_name
*&---------------------------------------------------------------------*
FORM MATERIAL_NAME  USING    P_MATNR
                             P_MAKTX.

  SELECT SINGLE MAKTX INTO P_MAKTX
                      FROM MAKT
                     WHERE MATNR EQ P_MATNR
                       AND SPRAS EQ SY-LANGU.

ENDFORM.                    " MATERIAL_name
*&---------------------------------------------------------------------*
*&      Form  display_material_master
*&---------------------------------------------------------------------*
FORM DISPLAY_MATERIAL_MASTER  USING    P_MATNR
                                       P_WERKS
                                       P_LGORT.

  CHECK NOT P_MATNR IS INITIAL.

  CALL FUNCTION 'MMPUR_MATERIAL_DISPLAY'
    EXPORTING
      IM_MATNR = P_MATNR
      IM_WERKS = P_WERKS
      IM_LGORT = P_LGORT.


ENDFORM.                    " DISPLAY_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*&      Form  display_VENDOR_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST_LFINR  text
*----------------------------------------------------------------------*
FORM DISPLAY_VENDOR_MASTER  USING    P_LIFNR
                                     P_EKORG.
*------- Direktwerte GPA/SPA-------------------------------------------*
  DATA: KDY_VAL(8) VALUE '/110'.

  CHECK NOT P_LIFNR IS INITIAL.

  IF P_EKORG IS INITIAL.
    SET PARAMETER ID 'LIF' FIELD P_LIFNR.
    SET PARAMETER ID 'EKO' FIELD SPACE.
    SET PARAMETER ID 'KDY' FIELD KDY_VAL.
    CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
  ELSE.
    CALL FUNCTION 'MMPUR_VENDOR_DISPLAY'
      EXPORTING
        IM_LIFNR = P_LIFNR
        IM_EKORG = P_EKORG.
  ENDIF.

ENDFORM.                    " display_vendor_master
*&---------------------------------------------------------------------*
*&      Form  display_liv_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_LIV_DOCUMENT  USING    P_BELNR
                                    P_GJAHR
                                    P_BUKRS.

  CHECK NOT P_BELNR IS INITIAL.
  SELECT SINGLE *
    FROM RBKP
   WHERE BELNR = P_BELNR
     AND GJAHR = P_GJAHR.
  IF SY-SUBRC EQ 0.
    SET PARAMETER ID 'RBN' FIELD P_BELNR.
    SET PARAMETER ID 'GJR' FIELD P_GJAHR.
    CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
  ELSE.
    CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
      EXPORTING
        BUKRS                      = P_BUKRS
        BELNR                      = P_BELNR
        GJAHR                      = P_GJAHR
*           AKTYP                      = 'A'
*           XEPOS                      =
*           I_NOCHANGE                 =
*           XPRNT                      =
*    IMPORTING
*           E_CMRQ                     =
*           E_CHNG                     =
     EXCEPTIONS
        DISPLAY_NOT_POSSIBLE       = 1
        NO_AUTHORITY               = 2
        OTHERS                     = 3.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_LIV_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  display_bi_document
*&---------------------------------------------------------------------*
FORM DISPLAY_BI_DOCUMENT  USING    P_IBINO.

  CHECK NOT P_IBINO IS INITIAL.
  SET PARAMETER ID 'ZTIIBINO' FIELD P_IBINO.
  CALL TRANSACTION 'ZTIT463' AND SKIP FIRST SCREEN.


ENDFORM.                    " display_bi_document
*&---------------------------------------------------------------------*
*&      Form  display_bo_document
*&---------------------------------------------------------------------*
FORM DISPLAY_BO_DOCUMENT  USING    P_IBONO.
  CHECK NOT P_IBONO IS INITIAL.
  SET PARAMETER ID 'ZTIIBONO' FIELD P_IBONO.
  CALL TRANSACTION 'ZTIT473' AND SKIP FIRST SCREEN.
ENDFORM.                    " display_bo_document
*&---------------------------------------------------------------------*
*&      Form  SET_CONTEXT_MENU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_OBJECT   text
*----------------------------------------------------------------------*
FORM SET_CONTEXT_MENU USING P_CTXMENU TYPE REF TO CL_CTMENU.

  P_CTXMENU->ADD_SEPARATOR( ).
*
**--> 사전계약 메뉴...
*  IF g_igchk NE ''.
*    PERFORM build_menu_wb(ztsrcomm)
*      USING : p_ctxmenu  'WB',
*              p_ctxmenu  'WC',
*              p_ctxmenu  'WD',
*              p_ctxmenu  'WR'.
*  ENDIF.
*
*  PERFORM set_function_code(ztsrcomm)
*          USING : p_ctxmenu 'ZTSNARROW'.
*
*  p_ctxmenu->add_separator( ).
*
***항차 프로세스 적용시만 활용
*  IF g_igchk_os NE ''.
*    PERFORM build_menu_wb(ztsrcomm)
*      USING : p_ctxmenu  'OS'.
*  ENDIF.

  P_CTXMENU->ADD_SEPARATOR( ).

  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'IR'.

**적하부보프로세스 사용시만 활용
*  IF ztitig00-ippmt NE 'Z'.
  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'IP'.
*  ENDIF.

  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'BL'.

***L/G 프로세스 사용시만 활용
*  IF ztitig00-lgpcs NE 'Z'.
*    PERFORM build_menu_import(ztircomm)
*      USING : ztitig00 p_ctxmenu  'LG'.
*  ENDIF.
*
**송장프로세스 사용시만 활용
*  IF ztitig00-ivprc NE 'T'.
  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'IV'.
*  ENDIF.

***잠정/확정가 정산 사용시만 활용
*  IF ztitig00-prpux EQ 'X'.
**  IF ztitig00-prcty EQ 'F'."확정송장일 경우만
*    PERFORM build_menu_import(ztircomm)
*    USING : ztitig00 p_ctxmenu  'ST'.
*  ENDIF.
*
***TD 사용시만 활용
*  IF ztitig00-vslyn NE 'Z'. "Z(미적용)
*    PERFORM build_menu_import(ztircomm)
*    USING : ztitig00 p_ctxmenu  'MC'.
*  ENDIF.

**반입예정 사용시만 활용
  IF ZTITIG00-BSMTU  EQ 'X'.
    PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
      USING : ZTITIG00 P_CTXMENU  'BS'.
  ENDIF.

**반입 사용시만 활용
*  IF ztitig00-bimtu  EQ 'X'.
  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'BI'.
*  ENDIF.

***반출 사용시만 활용
  IF ZTITIG00-BDMTU  EQ 'X'.
    PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
      USING : ZTITIG00 P_CTXMENU  'BO'.
  ENDIF.
*
***통관요청 사용시만 활용
  IF ZTITIG00-CCRQM NE 'N'.
    PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
      USING : ZTITIG00 P_CTXMENU  'CR'.
  ENDIF.

  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'TD',
            ZTITIG00 P_CTXMENU  'CC'.

**입고프로세스 사용시만 활용
*  IF ztitig00-grtyp NE space.
  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'GR'.
*  ENDIF.


*--> 세금계산서......
*  IF ztitig00-vatfx EQ 'X'.
  PERFORM BUILD_MENU_IMPORT(ZTIRCOMM)
    USING : ZTITIG00 P_CTXMENU  'VA'.
*  ENDIF.

**--> 인수증...
*  IF ztitig00-acpcs NE 'Z'.
*    PERFORM build_menu_import(ztircomm)
*      USING ztitig00 p_ctxmenu  'AC'.
*  ENDIF.
*
**--> 기납증 ......
*  IF ztitig00-gnjfx EQ 'X'.
*    PERFORM build_menu_import(ztircomm)
*      USING ztitig00 p_ctxmenu  'TX'.
*  ENDIF.
**--------------------------------------------------------------------*

ENDFORM.         "SET_CONTEXT_MENU
*&---------------------------------------------------------------------*
*&      Form  CONTEXT_MENU_TCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_UCOMM  text
*----------------------------------------------------------------------*
FORM CONTEXT_MENU_TCODE  USING   R_UCOMM.

  DATA: L_COUNT     TYPE I,
        L_DOCNO(10).

  CASE R_UCOMM.
*> Line check
  CLEAR: L_COUNT.
  LOOP AT IT_LIST WHERE BOX EQ 'X'.
    ADD 1 TO L_COUNT.
  ENDLOOP.

  IF L_COUNT EQ 0.
    MESSAGE S909. EXIT.
  ENDIF.
*
**--------------------------------------------------------------------*
**> 계약 및 오더
*    WHEN 'ZTST101'. "사전계약 생성(참조생성)
*      IF L_COUNT > 1.
*        MESSAGE E929.  EXIT.
*      ENDIF.
*
*      IF IT_LIST-ICWB(3) EQ SPACE OR
*         IT_LIST-ICWB(3) EQ ICON_LED_RED(3).
*        MESSAGE E605 WITH '계약문서'. EXIT.
*      ENDIF.
*
*      IF IT_LIST-TKONN IS INITIAL.
*        MESSAGE E999 WITH '참조할 계약이 존재하지 않습니다.'.
*      ENDIF.
*
*      CTU_PARAMS-DISMODE  = 'E'. ">처리모드
*      PERFORM EXEC_COPY_REF(ZTSR1000) USING IT_LIST-TKONN
*                                            CTU_PARAMS-DISMODE
*                                            L_SUBRC.
*
*      CLEAR: *ZTSTWBK.
*      IMPORT *ZTSTWBK FROM MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
*
**          IF *ztstwbk-tkonn IS NOT INITIAL.
**            PERFORM exec_after_process(ztsr1000)
**              USING l_subrc rs_selfield.
**          ENDIF.
*
*    WHEN 'ZTST102' OR 'ZTST103' OR 'ZTST104' OR 'ZTST111' OR
*          'ZTST112' OR 'ZTST113' OR 'ZTST114' OR 'ZTST115' OR
*          'ZTST121' OR 'ZTST122' OR 'ZTST123' OR 'ZTST124' OR
*          'ZTST125'.
*      IF L_COUNT > 1.
*        MESSAGE E929.  EXIT.
*      ENDIF.
*
**          PERFORM GET_SELECTED_ROW   USING G__LIST
*
*      PERFORM CALL_WB_DOCUMENT_NEW(ZTSRCOMM) USING IT_LIST-TKONN
*                                                   IT_LIST-TKSEQ
*                                                   L_DOCNO
*                                                   R_UCOMM.
**          IF l_docno IS NOT INITIAL.
**            PERFORM exec_after_process(ztsr1000)
**              USING l_subrc rs_selfield.
**          ENDIF.
*
***          CLEAR: *ztstwbk.
***          IMPORT *ztstwbk FROM MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
***          FREE MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
***          IF *ztstwbk-tkonn IS NOT INITIAL.
***            PERFORM exec_after_process(ztsr1000)
***              USING l_subrc rs_selfield.
***          ENDIF.
*
*
*    WHEN 'ZTSR100'. "ZTSR100 - 문서별 계약 현황 레포트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'WB' L_COUNT.
*      SUBMIT ZTSR1000 WITH S_TKONN IN GR_REFNO
*                      WITH S_CNAM  IN LR_CNAM
*                      WITH S_CDAT  IN LR_ALLDT
*                      AND RETURN.
*
*    WHEN 'ZTSR101'. "ZTSR101 - 자재별 계약 현황 레포트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'WB' L_COUNT.
*      SUBMIT ZTSR1010 WITH S_TKONN IN GR_REFNO
*                      WITH S_CDAT  IN LR_ALLDT AND RETURN.
*
**--------------------------------------------------------------------*
**> 항차
*    WHEN 'ZTIR260'. "항차 Due list
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'PO' L_COUNT.
*
*      SUBMIT ZTIR2600 WITH S_EBELN IN GR_REFNO
*                      WITH S_AEDAT IN LR_ALLDT AND RETURN.
*
*
*    WHEN 'ZTST201'. "항차 생성
*
*      L_OK_CODE = 'ZTIT261'.
*
*      LOOP AT IT_LIST WHERE BOX = 'X'.
*
*        GS_ZTES_PKEY-BUKRS = IT_LIST-BUKRS.
*        GS_ZTES_PKEY-VGBEL = IT_LIST-EBELN.
*        GS_ZTES_PKEY-VGPOS = IT_LIST-EBELP.
*
*        IF IT_LIST-PPAID IS NOT INITIAL.
*          LT_PPAID-PPAID = IT_LIST-PPAID.
*        ENDIF.
*        COLLECT LT_PPAID.
*
*        COLLECT GS_ZTES_PKEY INTO IT_ZTES_PKEY.
*
*      ENDLOOP.
*
*      SORT IT_ZTES_PKEY BY VGBEL VGPOS.
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR2600) IF FOUND
*       TABLES IT_ZTES_PKEY LT_PPAID
*        USING L_DOCNO L_OK_CODE.
*
*    WHEN 'ZTST202' OR 'ZTST203' OR 'ZTST204' OR
*          'ZTST205' OR 'ZTST206'.
*      PERFORM CALL_OS_DOCUMENT_NEW(ZTSRCOMM) USING IT_LIST-GCARN
*                                                   IT_LIST-OSNUM
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN  'ZTSR201'. "ZTSR201 - 항차 상태별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'OS' L_COUNT.
*
*      SUBMIT ZTSR2010 WITH S_OSNUM IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTSR994'. "ZTSR994 - 선박마스터 관리
*      SET PARAMETER ID 'ZTSSHCOD' FIELD IT_LIST-SHCOD.
*      SUBMIT ZTSR9940 WITH GD_TREE_SHCOD EQ IT_LIST-SHCOD
*                      AND RETURN.
*
**--------------------------------------------------------------------*
**> 수입개설
WHEN 'ZTIR000'. "수입 개설 대상 리스트
  PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
                       USING 'PO' L_COUNT.

  SUBMIT ZTIR0000 WITH S_EBELN IN GR_REFNO
                  WITH S_AEDAT IN GR_DATE
                  AND RETURN.

    WHEN 'ZTIR001'. "사후송금 대상 리스트
      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
                           USING 'BL' L_COUNT.

      SUBMIT ZTIR0010 WITH S_IBLNO IN GR_REFNO
*                          WITH s_aedat IN gr_date
                      AND RETURN.
    WHEN 'ZTIR002'. "유보금대상 리스트
      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
                           USING 'BL' L_COUNT.

      SUBMIT ZTIR0020 WITH S_IBLNO IN GR_REFNO
*                          WITH s_aedat IN gr_date
                      AND RETURN.

    WHEN 'ZTIR003'. "무역외 송금 리스트
*          PERFORM set_ranges_data TABLES gr_refno gr_date
*                               USING 'IR' l_count.

      SUBMIT ZTIR0030 "WITH s_iblno IN gr_refno
*                          WITH s_aedat IN gr_date
                      VIA SELECTION-SCREEN
                      AND RETURN.

    WHEN 'ZTIT001' . "수입 개설 생성

*      CLEAR : LT_REQTY, LT_REQTY[],
*              LT_IVONO, LT_IVONO[],
*              L_ERROR_CHK.

*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        CLEAR GS_ZTIS_PKEY.
*
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*
**-------------------------------------
**--> 수출 반품을 위해서...
*
*        IF IT_LIST-RETPO EQ 'X' AND     ">반품이면서.
*          ZTITIG00-RTNPX EQ ABAP_FALSE. ">미적용이면 오류...
*          MESSAGE S189 WITH T001-BUKRS DISPLAY LIKE C_ERROR.
*          L_ERROR_CHK = 'X'.
*          EXIT.
*        ENDIF.
*
**            BREAK-POINT.
*        IF IT_LIST-RETPO EQ 'X' AND
*           IT_LIST-VBELN_RT IS NOT INITIAL.
*          GS_ZTIS_PKEY-BUKRS       = IT_LIST-BUKRS.
*          GS_ZTIS_PKEY-VBELN       = IT_LIST-VBELN.
*          GS_ZTIS_PKEY-POSNR       = IT_LIST-POSNR.
*          GS_ZTIS_PKEY-VBELN_RT    = IT_LIST-VBELN_RT.
*          GS_ZTIS_PKEY-POSNR_RT    = IT_LIST-POSNR_RT.
*          GS_ZTIS_PKEY-VBELN_RE    = IT_LIST-VBELN_RE.
*          GS_ZTIS_PKEY-POSNR_RE    = IT_LIST-POSNR_RE.
*        ENDIF.
**-------------------------------------
*
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*
*        MOVE-CORRESPONDING IT_LIST   TO LT_REQTY.
*
*        COLLECT LT_REQTY.
*
*        MOVE: IT_LIST-IVONO   TO LT_IVONO-IVONO,
*              IT_LIST-LIVST   TO LT_IVONO-LIVST.
*        IF IT_LIST-IVONO IS NOT INITIAL AND
*          IT_LIST-LIVST EQ 'P'.
*          L_IVONO = IT_LIST-IVONO.
*          COLLECT LT_IVONO.
*        ENDIF.
*      ENDLOOP.
*
*      SORT LT_REQTY BY REQTY ANBTY.
*      DELETE ADJACENT DUPLICATES FROM LT_REQTY
*                      COMPARING REQTY ANBTY.
*
*      SORT IT_ZTIS_PKEY BY EBELN EBELP IBLNO IBLIT IVONO RBLGP.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                            COMPARING EBELN EBELP IBLNO IBLIT IVONO RBLGP.
*
*
*      CASE LINES( LT_REQTY[] ).
*        WHEN 0.
*          CHECK L_ERROR_CHK EQ ABAP_FALSE.
*
*          MESSAGE S001 DISPLAY LIKE C_ERROR.
*          EXIT.
*
*        WHEN 1.
*          READ TABLE LT_REQTY INDEX 1.
*
*          IF LT_REQTY-REQTY EQ 'TT' AND
*             LT_REQTY-ANBTY EQ 'A'  AND " 사후 T/T 구분
*             ZTITIG00-ATTPX EQ 'X'. " 사후 T/T 사용 IMG
*
*            CLEAR : L_SUBRC .
*
*            CASE LINES( LT_IVONO[] ).
*              WHEN 0.
*                MESSAGE S173 DISPLAY LIKE C_ERROR.
*                EXIT.
*              WHEN 1.
*
*              WHEN OTHERS.
*                MESSAGE S989 WITH '인보이스'(M99) DISPLAY LIKE C_ERROR.
*                EXIT.
*            ENDCASE.
*
**> 사후 T/T일 경우 헤더레벨 생성이기에  인보이스 관리번호 기준으로 관련 라인 정보를
**> 전부 가져온다.
*            CLEAR : IT_ZTIS_PKEY, IT_ZTIS_PKEY[].
*            LOOP AT IT_LIST WHERE IVONO EQ L_IVONO.
*              CLEAR GS_ZTIS_PKEY.
*              MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*
*              APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*            ENDLOOP.
*
*            SORT IT_ZTIS_PKEY BY EBELN EBELP IBLNO IBLIT IVONO RBLGP.
*            DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                                  COMPARING EBELN EBELP IBLNO IBLIT IVONO RBLGP.
*
*          ENDIF.
*
*          CHECK L_ERROR_CHK IS INITIAL.
*
*          PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR0000) IF FOUND
*               TABLES IT_ZTIS_PKEY
*                USING L_DOCNO R_UCOMM.
*
*        WHEN OTHERS.
*          MESSAGE S999 WITH '하나의 수입의뢰 종류건만 허용합니다.'
*                  DISPLAY LIKE C_ERROR.
*          EXIT.
*      ENDCASE.
*
*
*

WHEN 'ZTIT003'. "수입 개설 조회
  PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
                           USING 'IR' L_COUNT.
  IF L_COUNT = 1.
    SELECT COUNT(*)
      INTO L_COUNT
      FROM ZTITRQS
     WHERE REQNO EQ IT_LIST-REQNO.
    IF L_COUNT EQ 1.
      PERFORM CALL_IR_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-REQNO
                                                   IT_LIST-AMDSQ
                                                   IT_LIST-EBELN
                                                   L_DOCNO
                                                   R_UCOMM.
    ELSE.
      SUBMIT ZTIR0040 WITH S_REQNO IN GR_REFNO
                      WITH P_LAST  EQ ''
                      AND RETURN.
    ENDIF.
  ELSE.
    SUBMIT ZTIR0040 WITH S_REQNO IN GR_REFNO
                    WITH P_LAST  EQ ''
                    AND RETURN.
  ENDIF.

*    WHEN 'ZTIT002' OR 'ZTIT004' OR  'ZTIT051' OR 'ZTIT005' OR  " 수입의뢰 접수 추가....
*          'ZTIT006' OR 'ZTIT007' OR 'ZTIT008' OR 'ZTIT009'.
*      PERFORM CALL_IR_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-REQNO
*                                                   IT_LIST-AMDSQ
*                                                   IT_LIST-EBELN
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR004'. "ZTIR004 - 수입요청(개설) 현황 List
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*      SUBMIT ZTIR0040 WITH S_REQNO IN GR_REFNO
*                      WITH P_LAST  EQ ''
*                      AND RETURN.
*
*    WHEN 'ZTIR008'. "ZTIR004 - 수입요청(개설) 현황 List
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*
*      SUBMIT ZTIR0080 WITH S_REQNO IN GR_REFNO
*                      WITH P_STEP1 EQ SPACE
*                      WITH P_STEP2 EQ SPACE
*                      WITH P_STEP3 EQ SPACE
*                      WITH P_STEP4 EQ SPACE
*                      WITH P_STEP5 EQ SPACE
*                      WITH P_STEP7 EQ SPACE
*                      WITH P_STEP8 EQ 'X'
*                      AND RETURN.
*
*    WHEN 'ZTIR018'. "ZTIR018 - 수입의뢰 변경 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*
*      SUBMIT ZTIR0180 WITH S_REQNO IN GR_REFNO
*                      AND RETURN.
*
*    WHEN 'ZTIR099'. "ZTIR099 - 품목별 수입의뢰 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*
*      SUBMIT ZTIR0990 WITH S_REQNO IN GR_REFNO
*                      AND RETURN.
**
**        WHEN 'ZTIR003'. "ZTIR003 - 수입요청(개설) 상태별 현황
**          PERFORM set_ranges_data TABLES gr_refno gr_date
**                                   USING 'IR'
**                                         l_count.
**          SUBMIT ztir0030 WITH s_reqno IN gr_refno
**                          WITH p_step3 EQ ' '
**                          WITH p_step8 EQ 'X'
**                          AND RETURN.
*
*    WHEN 'ZTIR009'. ":ZTIR009 - P/O 종료상태 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PO'
*                                     L_COUNT.
*
*      SUBMIT ZTIR0090 WITH S_EBELN IN GR_REFNO
*                      WITH S_BEDAT EQ IT_LIST-BEDAT
*                      AND RETURN.
*
*    WHEN 'ZTIR007' . " 수입요청 승인 관리 ....
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*
*      SUBMIT ZTIR0070 WITH S_REQNO IN GR_REFNO
*                      AND RETURN.
*
*    WHEN 'ZTIR007_C' . " 수입요청 승인 취소 ....
**          BREAK BESDC05.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*
*      SUBMIT ZTIR0070 WITH S_REQNO IN GR_REFNO
*                      WITH P_STEP1 EQ SPACE
*                      WITH P_STEP2 EQ ABAP_TRUE
*                      WITH P_STEP3 EQ SPACE
*                      AND RETURN.
***********************************************************************
**> 보험  (GSC 미사용)
*
*
***********************************************************************
**> 선적
*    WHEN 'ZTIR200'. "B/L due list
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'PO' L_COUNT.
*
*      SUBMIT ZTIR2000 WITH S_EBELN  IN GR_REFNO
*                      WITH S_BEDAT3 IN LR_ALLDT AND RETURN.
*
*    WHEN 'ZTIT201'.
*
*      CLEAR: LT_REQTY[].
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*
*        CLEAR GS_ZTIS_PKEY.
*
*        IF IT_LIST-RETPO EQ ABAP_TRUE.
*          MOVE-CORRESPONDING IT_LIST TO GS_ZTIS_PKEY.
*          GS_ZTIS_PKEY-BUKRS = T001-BUKRS.
*          APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        ELSE.
*          SELECT SINGLE *
*            INTO CORRESPONDING FIELDS OF GS_ZTIS_PKEY
*            FROM ZTIVPO00
*           WHERE EBELN EQ IT_LIST-EBELN
*             AND EBELP EQ IT_LIST-EBELP.
*
*          MOVE-CORRESPONDING IT_LIST TO GS_ZTIS_PKEY.
*          MOVE: IT_LIST-EBELN        TO GS_ZTIS_PKEY-EBELN.
*          APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        ENDIF.
*
*        CLEAR: LT_REQTY.
*        LT_REQTY-REQTY = IT_LIST-REQTY.
*        LT_REQTY-RETPO = IT_LIST-RETPO.
*        COLLECT LT_REQTY.
*      ENDLOOP.
*
*      IF LINES( LT_REQTY[] ) > 1.
**> 무환건은 Combine할 수 있음...
*        DELETE LT_REQTY WHERE REQTY = 'ZZ'.
*
*        IF LINES( LT_REQTY[] ) > 1.
*          MESSAGE E999 WITH '하나의 수입의뢰 종류건만 허용합니다.'.
*          EXIT.
*        ENDIF.
*      ENDIF.
*
*      SORT IT_ZTIS_PKEY.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                 COMPARING ALL FIELDS.
*
*      READ TABLE LT_REQTY INDEX 1.
*
*      IF LT_REQTY-RETPO EQ 'X'.  ">수출 반품의 경우..
*
*        PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR2000)
*                TABLES IT_ZTIS_PKEY
*                USING  L_DOCNO
*                     'ZTIT20D'                          " 'ZTIT20A'
*                       R_UCOMM.
*      ELSE.
*
*        PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR2000)
*                TABLES IT_ZTIS_PKEY
*                USING  L_DOCNO
*                     'ZTIT20C'                          " 'ZTIT20A'
*                       R_UCOMM.
*      ENDIF.
*
*    WHEN 'ZTIT202' OR 'ZTIT203' OR 'ZTIT204'.
*      PERFORM CALL_BL_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IBLNO
*                                                   IT_LIST-REQNO
*                                                   IT_LIST-EBELN
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR203'. "ZTIR203 - 선적서류 상태별  현황 List
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'BL'
*                                     L_COUNT.
*      SUBMIT ZTIR2030 WITH S_IBLNO IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIR299'. "ZTIR299 - B/L 품목별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'BL'
*                                     L_COUNT.
*      SUBMIT ZTIR2990 WITH S_IBLNO IN GR_REFNO AND RETURN.
*
***********************************************************************
**> 송장
*    WHEN 'ZTIR300'. "I/V 생성 대상 리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'PO' L_COUNT.
*      SUBMIT ZTIR3000 WITH S_EBELN  IN GR_REFNO AND RETURN.
*
**> 2015/09/22 HyeungJungKim 사전송금 T/T Due List  추가
*    WHEN 'ZTIR301'. "사전송금 T/T Due List
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IR' L_COUNT.
*      SUBMIT ZTIR3010 WITH S_REQNO  IN GR_REFNO AND RETURN.
*
*
*    WHEN 'ZTIT301'.
*      SORT IT_ZTITIG01 BY EKORG.
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*
*        "항차관리 사용여부...
*        IF ZTITIG00-VSLYN EQ 'O'.
*
*          READ TABLE IT_ZTITIG01 WITH KEY EKORG = IT_LIST-EKORG
*                                 BINARY SEARCH.
*          IF SY-SUBRC EQ 0.
*            IF IT_ZTITIG01-OPRYN EQ 'Y'.
*              IF IT_LIST-OSNUM IS INITIAL.
*                MESSAGE E214(ZMTS00) WITH IT_LIST-EBELN.
*                EXIT.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
*        ADD 1 TO G_LINE.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      IF G_LINE EQ 0.
*        MESSAGE S003(OK). EXIT.
*      ENDIF.
*
*      SORT IT_ZTIS_PKEY BY IBLNO IBLIT EBELN EBELP.
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR3000) IF FOUND
*              TABLES IT_ZTIS_PKEY
*               USING L_DOCNO  R_UCOMM.
*
*    WHEN 'ZTIT302' OR 'ZTIT304' OR 'ZTIT305' OR 'ZTIT306' OR 'ZTIT307'.
*      PERFORM CALL_IV_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IVONO
*                                                   IT_LIST-IBLNO
*                                                   IT_LIST-EBELN
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*      IF R_UCOMM EQ 'ZTIT304'.
*        IF SY-MSGID EQ 'ZMTI00' AND
*           SY-MSGNO EQ '300'.
*          MESSAGE S315(ZMTI00) WITH IT_LIST-IVONO.
*        ENDIF.
*      ENDIF.
*
*    WHEN 'ZTIT303'."송장 조회
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'IV'
*                                     L_COUNT.
*      IF L_COUNT = 1.
*        PERFORM CALL_IV_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IVONO
*                                                     IT_LIST-IBLNO
*                                                     IT_LIST-EBELN
*                                                     L_DOCNO
*                                                     R_UCOMM.
*      ELSE.
*        SUBMIT ZTIR3040 WITH S_IVONO IN GR_REFNO
*                        AND RETURN.
*
**==>>> 전표 처리 여부 확인...
*        SELECT *
*          INTO CORRESPONDING FIELDS OF TABLE LT_ZTITIVK
*          FROM ZTITIVK
*         WHERE IVONO IN GR_REFNO
*           AND LIVST EQ 'P'
*           AND ( PRCTY EQ 'P' OR
*                 PRCTY EQ 'F' ).
*
*        IF SY-SUBRC EQ 0.
*          LOOP AT LT_ZTITIVK.
*            MOVE-CORRESPONDING LT_ZTITIVK TO *ZTITIVK.
**----------------------------> 지출결의...
*            PERFORM INTERFACE_PPS_GSC(SAPLZ_TI_MAIN_FOR_IV)
*                    IF FOUND
*                    USING   *ZTITIVK.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.
*
*    WHEN 'ZTIR304'. "인보이스 상태현황(잠정가 정산)
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'OI'
*                                     L_COUNT.
**          PERFORM set_ranges_data TABLES gr_refno
**                                         gr_date
**                                   USING 'IV'
**                                         l_count.
*      SUBMIT ZTIR3040 WITH S_IVONO IN GR_REFNO
*                      WITH P_INCL  EQ 'X'
*                      AND RETURN.
*
**==>>> 전표 처리 여부 확인...
*      SELECT *
*        INTO CORRESPONDING FIELDS OF TABLE LT_ZTITIVK
*        FROM ZTITIVK
*       WHERE IVONO IN GR_REFNO
*         AND LIVST EQ 'P'
*         AND ( PRCTY EQ 'P' OR
*               PRCTY EQ 'F' ).
*
*      IF SY-SUBRC EQ 0.
*        LOOP AT LT_ZTITIVK.
*          MOVE-CORRESPONDING LT_ZTITIVK TO *ZTITIVK.
**----------------------------> 지출결의...
*          PERFORM INTERFACE_PPS_GSC(SAPLZ_TI_MAIN_FOR_IV)
*                  IF FOUND
*                  USING   *ZTITIVK.
*        ENDLOOP.
*      ENDIF.
*
*    WHEN 'ZTIR305'. "ZTIR305 - 인보이스 미결 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'OI' "'IV'
*                                     L_COUNT.
*      SUBMIT ZTIR3050 WITH S_IVONO IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT "gr_date
*                      AND RETURN.
*
*    WHEN 'ZTIR398'. "ZTIR398 - 인보이스 품목별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'IV_L'
*                                      L_COUNT.
*      SUBMIT ZTIR3980 WITH S_IBLNO IN GR_REFNO
*                      WITH S_BLDAT IN LR_ALLDT "gr_date
*                      AND RETURN.
*
*
*    WHEN 'ZTIR320'.    ">결제스케쥴...
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PO'
*                                     L_COUNT.
*
**--> Memory ID 초기화
*      CLEAR : *ZTITIVD.
*      EXPORT *ZTITIVD TO MEMORY ID 'ZTIR3200'.   ">함수명...
*
*
*      SUBMIT ZTIR3200 WITH S_EBELN IN GR_REFNO
*                      WITH S_EKORG IN GR_EKORG
*                      AND RETURN.
*
**--> Memory ID 받아오기...
*      IMPORT *ZTITIVD FROM MEMORY ID 'ZTIR3200'.
*
*      CLEAR L_DOCNO.
*      IF *ZTITIVD-IVONO IS NOT INITIAL.
*        L_DOCNO = *ZTITIVD-IVONO.
*      ENDIF.
*
**        WHEN 'ZTIR321'.    ">결제스케쥴...
**          PERFORM set_ranges_data TABLES gr_refno
**                                         gr_date
**                                   USING 'PO'
**                                         l_count.
**
**          SUBMIT ztir3200 WITH s_ebeln IN gr_refno
**                          WITH s_ekorg IN gr_ekorg
**                          AND RETURN.
*
**--------------------------------------------------------------------*
**> 물량확정(TD) 관리
*    WHEN 'ZTIR290'. "ZTIR290 - 수입물량 확정 관리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'OS'
*                                     L_COUNT.
*      SUBMIT ZTIR2900 WITH S_OSNUM IN GR_REFNO
*                      WITH S_CDAT  IN LR_ALLDT AND RETURN.
*
**        WHEN 'ZTIR410'. "ZTIR410 - 확정신고 Due List
**          SUBMIT ztir4101 WITH s_iccno EQ IT_LIST-iccno_r AND RETURN.
*
*    WHEN 'ZDDI130'. " ZDDI130 - 가격신고서-부대비처리
*      L_LINES = L_COUNT.
*
*      PERFORM SET_BDC_PARAMS USING CTU_PARAMS.
*
*      CLEAR: L_COUNT, L_LAST.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        ADD 1 TO L_COUNT.
*
*        IF L_COUNT EQ L_LINES.
*          L_LAST = 'X'.
*        ENDIF.
*
*        IF IT_LIST-GCARN IS NOT INITIAL.
*
*          CLEAR: L_TEXT.
*          L_COUNTN = L_COUNT.
*          CONCATENATE 'RSCSEL_255-SLOW_I' '(' L_COUNTN ')' INTO L_TEXT.
*          CONDENSE L_TEXT.
*
*          PERFORM CALL_BDC_ZDDI130_CHANGE(SAPLZ_TS_CHANGE_COMMON) USING L_COUNT
*                                                                        L_TEXT
*                                                                        IT_LIST-GCARN
*                                                                        L_LAST
*                                                                        CTU_PARAMS
*                                                                        L_SUBRC.
*
*        ENDIF.
*      ENDLOOP.
*
*
*      IF L_COUNT EQ 0.
*        MESSAGE S917 DISPLAY LIKE 'E'. EXIT.
*      ENDIF.
*
**--------------------------------------------------------------------*
**> 통관
*    WHEN 'ZTIR400'. "통관요청 생성대상리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'BL'     L_COUNT.
*      SUBMIT ZTIR4000 WITH S_IBLNO IN GR_REFNO
*                      WITH S_CDAT  IN LR_ALLDT AND RETURN.
*
*    WHEN 'ZTIR430'. "통관필증 생성대상리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'CR'     L_COUNT.
*      SUBMIT ZTIR4000 WITH S_IBLNO IN GR_REFNO
*                      WITH S_CDAT  IN LR_ALLDT AND RETURN.
*
*    WHEN 'ZTIT401'.
*      CLEAR : LT_BL[].
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X' .
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        GS_ZTIS_PKEY-ICCNO = IT_LIST-ICCNO_R.
*        GS_ZTIS_PKEY-ICCSQ = IT_LIST-ICCSQ_R.
*        GS_ZTIS_PKEY-ICCIT = IT_LIST-ICCIT_R.
*        GS_ZTIS_PKEY-RBLSQ = SPACE.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        LT_BL-IBLNO = IT_LIST-IBLNO.
*        COLLECT LT_BL.
*      ENDLOOP.
*
*      IF LINES( LT_BL[] ) > 1.
*        MESSAGE S999 DISPLAY LIKE 'E'  WITH '하나의 B/L건만 허용합니다.'. EXIT.
*      ELSE.
*
**--------------------------------------------------------------------*
**            SORT it_ztis_pkey BY iccno iccit iblno iblit ebeln ebelp.
**
**            PERFORM check_and_call_transaction(ztir4000) TABLES it_ztis_pkey
**                                                          USING l_docno
**                                                                r_ucomm.
**--------------------------------------------------------------------*
**> B/L 기준으로 변경
*        CLEAR: IT_ZTIS_PKEY, IT_ZTIS_PKEY[].
*
*        READ TABLE LT_BL INDEX 1.
*
*        LOOP AT IT_LIST WHERE IBLNO EQ LT_BL-IBLNO.
*          CLEAR: GS_ZTIS_PKEY.
*          MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*          APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        ENDLOOP.
*
*        SORT IT_ZTIS_PKEY BY IBLNO IBLIT.
*        DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY COMPARING IBLNO IBLIT.
*
*        PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR4000) TABLES IT_ZTIS_PKEY
*                                                      USING L_DOCNO
*                                                            R_UCOMM.
*
**--------------------------------------------------------------------*
*
*      ENDIF.
*
*
*    WHEN 'ZTIT431'.
*      CLEAR : LT_BL[].
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X' .
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        GS_ZTIS_PKEY-ICCNO = IT_LIST-ICCNO_R.
*        GS_ZTIS_PKEY-ICCSQ = IT_LIST-ICCSQ_R.
*        GS_ZTIS_PKEY-ICCIT = IT_LIST-ICCIT_R.
*        GS_ZTIS_PKEY-RBLSQ = SPACE.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        LT_BL-IBLNO = IT_LIST-IBLNO.
*        COLLECT LT_BL.
*      ENDLOOP.
*
*      IF LINES( LT_BL[] ) > 1.
*        MESSAGE S999 DISPLAY LIKE 'E'  WITH '하나의 B/L건만 허용합니다.'. EXIT.
*      ELSE.
*
*        SORT IT_ZTIS_PKEY BY ICCNO ICCIT IBLNO IBLIT EBELN EBELP.
*
**--------------------------------------------------------------------*
**> 2015/10/26 HyeungJungKim 통관 면장 생성 시 체크로직 추가.
**--------------------------------------------------------------------*
*        " 체크
**            PERFORM check_and_call_transaction(ztir4000) TABLES it_ztis_pkey
**                                                          USING l_docno
**                                                                r_ucomm.
**--------------------------------------------------------------------*
*        CLEAR: GS_ZTIS_PKEY, G_SUBRC.
*        READ TABLE IT_ZTIS_PKEY INTO GS_ZTIS_PKEY INDEX 1.
*        PERFORM CHECK_REQUEST_DOCST IN PROGRAM SAPLZ_TI_MAIN_FOR_CC
*                                         USING GS_ZTIS_PKEY-ICCNO
*                                               GS_ZTIS_PKEY-ICCSQ
*                                               G_SUBRC
*                                               'ZTIT431'.
*
*        IF G_SUBRC EQ 0.
*          PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR4000) TABLES IT_ZTIS_PKEY
*                                                        USING L_DOCNO
*                                                              R_UCOMM.
*        ENDIF.
**--------------------------------------------------------------------*
*
*      ENDIF.
*
*    WHEN 'ZTIT403'. "수입 신고 의뢰 조회
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'CR'     L_COUNT.
*      IF L_COUNT = 1.
*        SELECT COUNT(*)
*          INTO L_COUNT
*          FROM ZTITCRK
*         WHERE ICCNO EQ IT_LIST-ICCNO_R.
*        IF L_COUNT EQ 1.
*          PERFORM CALL_CC_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-ICCNO_R
*                                                       IT_LIST-ICCSQ_R
*                                                       IT_LIST-IBLNO
*                                                       IT_LIST-BLNUM
*                                                       IT_LIST-EBELN
*                                                       L_DOCNO
*                                                       R_UCOMM.
*        ELSE.
*          SUBMIT ZTIR4320_GSC WITH S_ICCNO IN GR_REFNO
*                              WITH S_ERDAT IN LR_ALLDT AND RETURN.
*        ENDIF.
*      ELSE.
*        SUBMIT ZTIR4320_GSC WITH S_ICCNO IN GR_REFNO
*                            WITH S_ERDAT IN LR_ALLDT AND RETURN.
*      ENDIF.
*
*    WHEN 'ZTIT433'. "수입 신고 필증 조회
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*      IF L_COUNT = 1.
*        SELECT COUNT(*)
*          INTO L_COUNT
*          FROM ZTITCCK
*         WHERE ICCNO EQ IT_LIST-ICCNO.
*        IF L_COUNT EQ 1.
*          PERFORM CALL_CC_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-ICCNO
*                                                       IT_LIST-ICCSQ
*                                                       IT_LIST-IBLNO
*                                                       IT_LIST-BLNUM
*                                                       IT_LIST-EBELN
*                                                       L_DOCNO
*                                                       R_UCOMM.
*        ELSE.
*          SUBMIT ZTIR4010 WITH S_CDCDT IN LR_ALLDT
*                         WITH S_ICCNO IN GR_REFNO AND RETURN.
*        ENDIF.
*      ELSE.
*        SUBMIT ZTIR4010 WITH S_CDCDT IN LR_ALLDT
*                        WITH S_ICCNO IN GR_REFNO AND RETURN.
*      ENDIF.
*
***************************************************
**20130725 by jsh - GSC
**GSC 수입진행사항 list 로직추가
*    WHEN 'ZTIR410'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'CR'     L_COUNT.
*
*      SUBMIT ZTIR4101 VIA SELECTION-SCREEN
*                      WITH S_CDAT  IN GR_DATE
*                      WITH S_ICCNO IN GR_REFNO AND RETURN.
***************************************************
*
*    WHEN 'ZTIT402' OR 'ZTIT404' OR 'ZTIT409' OR
*         'ZTIT432' OR 'ZTIT434'.
*      PERFORM CALL_CC_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-ICCNO_R
*                                                   IT_LIST-ICCSQ_R
*                                                   IT_LIST-IBLNO
*                                                   IT_LIST-BLNUM
*                                                   IT_LIST-EBELN
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR432'. "ZTIR432 - 수입신고 상태별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CR'
*                                     L_COUNT.
*      SUBMIT ZTIR4320 WITH S_ICCNO IN GR_REFNO AND RETURN.
**                                WITH s_erdat IN lr_alldt AND RETURN.
*
*    WHEN 'ZTIR401'."ZTIR401 - 수입신고 현황 List(계층현황)
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*      DELETE GR_DATE WHERE LOW EQ '00000000'.
*      IF GR_DATE[] IS INITIAL.
*        MESSAGE E902 DISPLAY LIKE 'S'.
*      ENDIF.
*      SUBMIT ZTIR4010 WITH S_CDCDT IN GR_DATE
*                      WITH S_ICCNO IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIR407'. "ZTIR407 - 수입 통관/하역 List(면허번호별)
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*      SUBMIT ZTIR4070 WITH S_ICCNO IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIR408'. "ZTIR408 - 통관실적 현황(자재별)
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*      SUBMIT ZTIR4080 WITH S_ICCNO IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIR409'. "ZTIR409 - 수입통관현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
**          DELETE gr_date WHERE low EQ '00000000'.
**          IF gr_date[] IS INITIAL.
**            MESSAGE e902 DISPLAY LIKE 'S'.
**          ENDIF.
*      SUBMIT ZTIR4090 WITH S_CDRDT IN LR_ALLDT "gr_date
*                      WITH S_ICCNO IN GR_REFNO
*                      AND RETURN.
*
**--------------------------------------------------------------------*
**> 입고
*    WHEN 'ZTIR500'. "수입물품입고 생성대상리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'CC' L_COUNT.
*
*      SUBMIT ZTIR5000 WITH S_ICCNO IN GR_REFNO
*                      AND RETURN.
*    WHEN 'ZTIR502'. "미통관분 입고 생성리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'BL' L_COUNT.
*
*      SUBMIT ZTIR5020 WITH S_IBLNO IN GR_REFNO
*                      WITH S_CDAT  IN LR_ALLDT
*                      AND RETURN.
*
*    WHEN 'ZTIT501'.
*
**> 전기처리.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*
*        PERFORM CHECK_GR_DATA_NON_CC USING IT_LIST.
*
**            IF IT_LIST-iverr EQ 'E'.
**              IF ztitig00-igrmt IS INITIAL.
**                MESSAGE e173.
**              ELSE.
**                MESSAGE ID 'ZMTI00' TYPE ztitig00-igrmt NUMBER '173'.
**              ENDIF.
**            ENDIF.
**
**            "인도조건이 운임 지불 조건인 경우 po의 운임조건 유무 체크
**            IF IT_LIST-ebeln IS NOT INITIAL.
**              CLEAR : l_knumv, l_inco1.
**              SELECT SINGLE a~knumv a~inco1
**                INTO (l_knumv, l_inco1)
**                FROM ekko AS a JOIN ztstigb AS b
**                  ON a~inco1 EQ b~inco1
**               WHERE a~ebeln EQ IT_LIST-ebeln
**                 AND b~imind EQ 'X'
**                 AND b~ppaid EQ ' '.
**              IF sy-subrc EQ 0.
**                IF l_knumv IS INITIAL.
**                  MESSAGE e997 WITH l_inco1 IT_LIST-ebeln
**                             'PO 에는 운임조건이 미등록되어 입고처리가 불가능합니다'.
**                ENDIF.
**
**                CLEAR lt_kschl[].
**                SELECT DISTINCT kschl
**                   INTO CORRESPONDING FIELDS OF TABLE lt_kschl
**                   FROM ztitig06
**                  WHERE bukrs EQ p_bukrs
**                    AND cstcl IN ('O', 'R')
**                    AND kschl NE space.
**
**                IF lt_kschl[] IS NOT INITIAL.
**                  SELECT COUNT( * )
**                    INTO sy-dbcnt
**                    FROM konv FOR ALL ENTRIES IN lt_kschl
**                   WHERE knumv EQ l_knumv
**                     AND kposn EQ IT_LIST-ebelp
**                     AND kschl EQ lt_kschl-kschl.
**                  IF sy-subrc NE 0.
**                    MESSAGE e997 WITH l_inco1 IT_LIST-ebeln
**                               'PO 에는 운임조건이 미등록되어 입고처리가 불가능합니다'.
**                  ENDIF.
**                ENDIF.
**              ENDIF.
**
**            ENDIF.
*
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*
*        IT_LIFNR-LIFNR = IT_LIST-LIFNR.
*        COLLECT IT_LIFNR.
*
*        LT_IBLNO-IBLNO = IT_LIST-IBLNO.
*        COLLECT LT_IBLNO.
*
*        LT_ICCNO-ICCNO = IT_LIST-ICCNO.
*        LT_ICCNO-ICCSQ = IT_LIST-ICCSQ.
*        COLLECT LT_ICCNO.
*
*        LT_RPTTY-RPTTY = IT_LIST-RPTTY.
*        COLLECT LT_RPTTY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY ICCNO ICCIT IBLNO IBLIT EBELN EBELP.
*
*      "통관 - 미통관 건 체크
*      IF LINES( LT_RPTTY[] ) > 1.
*        MESSAGE E999 WITH '수입신고종류가 통관과 미통관분이 함께 존재합니다.'.
*      ENDIF.
*
*      "다중 B/L 체크
*      IF LINES( LT_IBLNO[] ) > 1.
*        MESSAGE E999.
*      ENDIF.
*
*
*      READ TABLE LT_RPTTY INDEX 1.
*      READ TABLE LT_ICCNO INDEX 1.
*      READ TABLE LT_IBLNO INDEX 1.
*      IF LT_RPTTY-RPTTY EQ 'Z' OR
*           LT_ICCNO-ICCNO IS INITIAL.
**--------------------------------------------------------------------*
**> B/L 기준 추가 2013.07.05
*        LOOP AT IT_LIST WHERE IBLNO EQ LT_IBLNO-IBLNO.
*          CLEAR: GS_ZTIS_PKEY .
*          PERFORM CHECK_GR_DATA_NON_CC USING IT_LIST.
*          MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*          APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        ENDLOOP.
*        SORT IT_ZTIS_PKEY BY IBLNO IBLIT IBLPT.
*        DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY COMPARING IBLNO IBLIT IBLPT.
**--------------------------------------------------------------------*
*        "미통관분 입고
*        PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR5020) TABLES IT_ZTIS_PKEY
*                                                      USING L_DOCNO
*                                                            'ZTIT001'.
*
*      ELSE.
*
**--------------------------------------------------------------------*
**> C/C 기준 추가
*        LOOP AT IT_LIST WHERE ICCNO EQ LT_ICCNO-ICCNO
*                            AND ICCSQ EQ LT_ICCNO-ICCSQ.
*          CLEAR: GS_ZTIS_PKEY .
*          PERFORM CHECK_GR_DATA_NON_CC USING IT_LIST.
*          MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*          APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*        ENDLOOP.
*        SORT IT_ZTIS_PKEY BY ICCNO ICCSQ ICCIT.
*        DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY COMPARING ICCNO ICCSQ ICCIT.
**--------------------------------------------------------------------*
*
*        "미통관분 이외 입고
*        PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR5000) TABLES IT_ZTIS_PKEY
*                                                            IT_LIFNR
*                                                      USING L_DOCNO
*                                                            R_UCOMM.
*      ENDIF.
*
*
*    WHEN 'ZTIT503'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*      IF L_COUNT EQ 1.
*        PERFORM CALL_GR_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IGRNO
*                                                     IT_LIST-ICCNO
*                                                     IT_LIST-ICCSQ
*                                                     IT_LIST-IBLNO
*                                                     IT_LIST-EBELN
*                                                     L_DOCNO
*                                                     R_UCOMM.
*      ELSE.
*        SUBMIT ZTIR5080 WITH S_IGRNO IN GR_REFNO
*                        WITH S_BUDAT IN LR_ALLDT
*                        WITH P_COGR  EQ ' '
*                        WITH P_ALL   EQ 'X'
*                        AND RETURN.
*      ENDIF.
*
*    WHEN 'ZTIT502' OR 'ZTIT504' OR
*        'ZTIT505' OR 'ZTIT506'.
*      PERFORM CALL_GR_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IGRNO
*                                                   IT_LIST-ICCNO
*                                                   IT_LIST-ICCSQ
*                                                   IT_LIST-IBLNO
*                                                   IT_LIST-EBELN
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR501'. "ZTIR501 - 외자 입고 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'GR'
*                                     L_COUNT.
*
*      SUBMIT ZTIR5010 WITH S_IGRNO IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT
*                      AND RETURN.
*
*    WHEN 'ZTIR508'. "ZTIR508 - 입고 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'GR'
*                                     L_COUNT.
*
*      SUBMIT ZTIR5080 WITH S_IGRNO IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT
*                      WITH P_COGR  EQ ' '
*                      WITH P_ALL   EQ 'X'
*                      AND RETURN.
*
*    WHEN 'ZTIR509'. "ZTIR509 - 입고 품목별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'GR'
*                                     L_COUNT.
*      SUBMIT ZTIR5090 WITH S_IGRNO IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT
*                      AND RETURN.
*
**--------------------------------------------------------------------*
**> L/G
**        WHEN 'ZTIR600'. "생성 대상리스트
**          PERFORM set_ranges_data TABLES gr_refno gr_date
**                                   USING 'IV'     l_count.
**
**          SUBMIT ztir8000 WITH s_ivono IN gr_refno
**                          AND RETURN.
*
*    WHEN 'ZTIT601' . "L/G
*
*      CLEAR LT_REFNO[].
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        CLEAR : LT_REFNO.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*
*        LT_REFNO-REFNO = GS_ZTIS_PKEY-IBLNO.
*        IF LT_REFNO-REFNO IS NOT INITIAL.
*          COLLECT LT_REFNO.
**--------------------------------------------------------------------*
*          " 한건만 허용하기에 LOOP 밖으로 이동..
**              APPEND gs_ztis_pkey TO it_ztis_pkey.
**--------------------------------------------------------------------*
*        ENDIF.
*      ENDLOOP.
*
*      G_LINE = LINES( LT_REFNO[] ).
*      CASE G_LINE.
*        WHEN 0.
*          MESSAGE E999 WITH '선택된 선적(B/L)단위가 존재하지 않습니다.'.
*          EXIT.
*        WHEN 1.
*
*        WHEN OTHERS.
*          MESSAGE E999 WITH '하나의 선적(B/L)단위만 허용합니다.'.
*          EXIT.
*      ENDCASE.
*
**> 한건만 가져옴.
*      READ TABLE IT_LIST WITH KEY BOX = 'X'.
*      IF SY-SUBRC EQ 0.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDIF.
*
**> 한 건만 허용하기에 주석처리. ----------------------------*
**          SORT it_ztis_pkey BY iblno.
**          DELETE ADJACENT DUPLICATES FROM it_ztis_pkey
**                                COMPARING iblno.
**-----------------------------------------------------------*
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR6000) IF FOUND
*                                           TABLES IT_ZTIS_PKEY
*                                            USING L_DOCNO
**                                                      'ZTIT60A'
*                                                  'ZTIT601'
*                                                  'ZTIT601'.
*
*    WHEN 'ZTIT602' OR 'ZTIT603' OR'ZTIT604' OR  'ZTIT605' OR
*          'ZTIT606' OR 'ZTIT607'.
*      PERFORM CALL_LG_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-ILGNO
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR601'. "L/G 상태별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'LG' L_COUNT.
*
*      SUBMIT ZTIR6010 WITH S_ILGNO IN GR_REFNO
*                      AND RETURN.
*
*    WHEN 'ZTIR602'. "L/G 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'LG' L_COUNT.
*
*      SUBMIT ZTIR6020 WITH S_ILGNO IN GR_REFNO
*                      AND RETURN.
*
*
*    WHEN 'ZTIR603' . " LG 승인 관리 ..
*
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'LG' L_COUNT.
*
*      SUBMIT ZTIR6030 WITH P_BUKRS EQ T001-BUKRS
*                      WITH S_ILGNO IN GR_REFNO
*                      AND RETURN.
*
*    WHEN 'ZTIR603_C' . " LG 승인 취소...
**          BREAK BESDC05.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'LG' L_COUNT.
*
*      SUBMIT ZTIR6030 WITH P_BUKRS EQ T001-BUKRS
*                      WITH S_ILGNO IN GR_REFNO
*                      WITH P_STA1  EQ SPACE
*                      WITH P_STA2  EQ ABAP_TRUE
*                      WITH P_STA3  EQ SPACE
*                      AND RETURN.
*
***********************************************************************
**> 인수확정
*    WHEN 'ZTIR800'. "인수확정 생성 대상리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'IV'     L_COUNT.
*      SUBMIT ZTIR8000 WITH S_IVONO IN GR_REFNO
*                      AND RETURN.
*
*    WHEN 'ZTIT801'.
*      IF L_COUNT > 1.
*        MESSAGE S929 DISPLAY LIKE 'E'.  EXIT.
*      ENDIF.
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        CLEAR GS_ZTIS_PKEY.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY IVONO RBLGP IBLNO IBLIT EBELN EBELP.
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR8000) TABLES IT_ZTIS_PKEY
*                                                    USING L_DOCNO
*                                                          R_UCOMM.
*
*    WHEN 'ZTIT802' OR 'ZTIT803' OR 'ZTIT804' OR
*         'ZTIT805' OR 'ZTIT806'.
*      PERFORM CALL_PN_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-PNTNO
*                                                   IT_LIST-IVONO
*                                                   IT_LIST-IBLNO
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR802'. "ZTIR802 - 인수확정 자재별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'PN' L_COUNT.
*
*      SUBMIT ZTIR8020 WITH S_PNTNO IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT
*                      AND RETURN.
*
*    WHEN 'ZTIR803'. "ZTIR803 - 인수확정 문서별 현황
*      PERFORM SET_RANGES_DATE_PN TABLES GR_DATE
*                                        GR_EKORG
*                                  USING L_COUNT.
*      IF GR_DATE[] IS INITIAL.
*        MESSAGE E902.
*      ELSE.
*        SUBMIT ZTIR8030 WITH S_EKORG IN GR_EKORG
*                        WITH S_ZFBDT IN LR_ALLDT "gr_date
*                        AND RETURN.
*      ENDIF.
*
*    WHEN 'ZTIR805'. "ZTIR805 - 인수확정 상태별 현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PN_B'
*                                     L_COUNT.
*      SUBMIT ZTIR8050 WITH S_BELNR IN GR_REFNO AND RETURN.
*
***********************************************************************
**> 세금계산서
*    WHEN 'ZTIR700'.  "세금계산서 생성대상 리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                              USING 'PO' L_COUNT.
*      SUBMIT ZTIR7000 WITH S_EBELN IN GR_REFNO
*                      WITH S_BUDAT IN LR_ALLDT AND RETURN.
*
*    WHEN 'ZTIT701'. "ZTIT701 - 세금계산서 생성
**                REFRESH: lt_reqno.
**                LOOP AT IT_LIST WHERE box EQ 'X'.
**                  ADD 1 TO g_line.
**                  lt_reqno-reqno = IT_LIST-reqno.
**                  COLLECT: lt_reqno.
**
**                  MOVE-CORRESPONDING : IT_LIST TO gs_ztis_pkey.
**                  MOVE: IT_LIST-gjahr TO gs_ztis_pkey-lfgja,  "Material Year
**                        IT_LIST-belnr TO gs_ztis_pkey-lfbnr,  "Mat.Doc
**                        IT_LIST-buzei TO gs_ztis_pkey-lfpos.  "Mat.Item
**
**                  APPEND gs_ztis_pkey TO it_ztis_pkey.
**                ENDLOOP.
**
**                CLEAR : g_line.
**
**                DESCRIBE TABLE lt_reqno LINES g_line.
**                CASE g_line.
**                  WHEN 0.
**                    MESSAGE s003(ok). EXIT.
**                  WHEN 1.
**                  WHEN OTHERS.
**                    MESSAGE e009 WITH '수입 의뢰'.
**                ENDCASE.
**
**           PERFORM check_and_call_transaction(ztir7000) TABLES it_ztis_pkey
**                                                            USING l_docno
**                                                                  l_ok_code.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING ''
*                                     L_COUNT.
*      IF L_COUNT > 1.
*        MESSAGE E929. EXIT.
*      ENDIF.
*
*      PERFORM CALL_VA_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-BUKRS
*                                                   IT_LIST-VATNO
*                                                   IT_LIST-REQNO
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIT703'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'VA'
*                                     L_COUNT.
*      IF L_COUNT EQ 1.
*        PERFORM CALL_VA_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-BUKRS
*                                                     IT_LIST-VATNO
*                                                     IT_LIST-REQNO
*                                                     L_DOCNO
*                                                     R_UCOMM.
*      ELSE.
*        SUBMIT ZTIR7010 WITH S_VATNO IN GR_REFNO AND RETURN.
*      ENDIF.
*
*    WHEN 'ZTIT702' OR 'ZTIT704' OR 'ZTIT705'.
*      PERFORM CALL_VA_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-BUKRS
*                                                   IT_LIST-VATNO
*                                                   IT_LIST-REQNO
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN  'ZTIR701'. "ZTIR701 - 세금계산서 처리 현황 LIST
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'VA'
*                                     L_COUNT.
*      SUBMIT ZTIR7010 WITH S_VATNO IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIR702'. "ZTIR702 - 세금계산서 상태현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'VA_PO'
*                                     L_COUNT.
*      SUBMIT ZTIR7020 WITH S_BLDAT IN LR_ALLDT "gr_date
*                      WITH S_EBELN IN GR_REFNO
*                      AND RETURN.
*
***********************************************************************
**> 인수증
*    WHEN 'ZTIR720'. "인수증 생성대상리스트
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                               USING 'PO' L_COUNT.
*
*      SUBMIT ZTIR7200 WITH S_BUDAT IN LR_ALLDT
*                      WITH S_EBELN IN GR_REFNO AND RETURN.
*
*    WHEN 'ZTIT721'.                                     "'ZTIT720'
*      L_OK_CODE = 'ZTIT721'.
*
*      CLEAR : G_LINE,  IT_OPNNO.
*      REFRESH: IT_OPNNO.
*
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        ADD 1 TO G_LINE.
*        MOVE-CORRESPONDING :IT_LIST TO IT_OPNNO.
*        COLLECT IT_OPNNO.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      DESCRIBE TABLE IT_OPNNO LINES G_LINE.
*      CASE G_LINE.
*        WHEN 0.
*          MESSAGE S721.    EXIT.
*        WHEN 1.
*          PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR7200) TABLES IT_ZTIS_PKEY
*                                                        USING L_DOCNO
*                                                              L_OK_CODE.
*
*        WHEN OTHERS.
*          MESSAGE S722 WITH G_LINE.    EXIT.
*      ENDCASE.
*
*    WHEN 'ZTIT723'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PO'
*                                     L_COUNT.
*      IF L_COUNT EQ 1.
*        PERFORM CALL_AC_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-BUKRS
*                                                     IT_LIST-ACDNO
*                                                     L_DOCNO
*                                                     R_UCOMM.
*      ELSE.
*        SUBMIT ZTIR7210 WITH S_EBELN IN GR_REFNO AND RETURN.
*      ENDIF.
*
*    WHEN 'ZTIT722' OR 'ZTIT723' OR 'ZTIT724'.
*      PERFORM CALL_AC_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-BUKRS
*                                                   IT_LIST-ACDNO
*                                                   L_DOCNO
*                                                   R_UCOMM.
*
*    WHEN 'ZTIR721'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PO'
*                                     L_COUNT.
*      SUBMIT ZTIR7210 WITH S_EBELN IN GR_REFNO AND RETURN.
*
***********************************************************************
***> 기납증
**        WHEN 'ZTIT741'.
**          l_ok_code = 'ZTIT741'.
**
**          CLEAR : g_line,  it_reqno.
**          REFRESH: it_reqno.
**
**          LOOP AT IT_LIST WHERE box EQ 'X'.
**            ADD 1 TO g_line.
**            MOVE-CORRESPONDING :IT_LIST TO it_reqno.
**            COLLECT it_reqno.
**            MOVE-CORRESPONDING : IT_LIST TO gs_ztis_pkey.
**            APPEND gs_ztis_pkey TO it_ztis_pkey.
**          ENDLOOP.
**
**          DESCRIBE TABLE it_reqno LINES g_line.
**          CASE g_line.
**            WHEN 0.
**              MESSAGE s721.    EXIT.
**
**            WHEN 1.
**              PERFORM check_and_call_transaction(ztir7400)
**               TABLES it_ztis_pkey
**                USING l_docno
**                      l_ok_code.
**
**            WHEN OTHERS.
**              MESSAGE s035(0k).   EXIT.
**          ENDCASE.
***********************************************************************
**> 비용
*    WHEN 'ZTIR911'. "ZTIR911 - 수입 은행관련비용 처리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'IR'
*                                     L_COUNT.
*
*      PERFORM SUBMIT_CS_PROGRAM USING'IR' L_DOCNO.
*
*    WHEN 'ZTIR912'. "ZTIR912 - 수입 적하보험비용 처리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'IP'
*                                     L_COUNT.
*
*      PERFORM SUBMIT_CS_PROGRAM USING 'IP'
*                                      L_DOCNO.
*
*    WHEN 'ZTIR918' . "ZTIR918 - 수입 항차관련비용 처리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'OS'
*                                     L_COUNT.
*
*      PERFORM SUBMIT_CS_PROGRAM USING 'OS'
*                                      L_DOCNO.
*
*    WHEN 'ZTIR913'. "ZTIR913 - 수입 선적관련비용 처리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'BL'
*                                     L_COUNT.
*
*      PERFORM SUBMIT_CS_PROGRAM USING 'BL'
*                                      L_DOCNO.
*
*    WHEN 'ZTIR914'. "ZTIR914 - 수입 통관관련비용 처리
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'CC'
*                                     L_COUNT.
*
*      PERFORM SUBMIT_CS_PROGRAM USING 'CC'
*                                      L_DOCNO.
*
*    WHEN 'ZTIR901'. "ZTIR901 - 수입비용현황
*
*
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                           USING 'CS' L_COUNT.
*      SUBMIT ZTIR9010
*              WITH P_BUKRS  EQ T001-BUKRS
*              WITH P_FULL   EQ 'X'
*              WITH P_LIST   EQ SPACE
*              WITH P_RFCEXE EQ SPACE
*              WITH P_STEP1  EQ SPACE
*              WITH P_STEP2  EQ SPACE
*              WITH P_STEP3  EQ 'X'
*              WITH P_STEP4  EQ SPACE
**--------------------------------------------------------------------*
**> 2016/01/13 HyeungJungKim 제비용 조회 시 넘기는 필드가 잘 못 되어 수정.
**--------------------------------------------------------------------*
**                  WITH s_refno  IN gr_refno     " Before
*              WITH S_ICSNO  IN GR_REFNO     " After
**--------------------------------------------------------------------*
*              AND RETURN.
*
*    WHEN 'ZTIR9011'. "ZTIR901 - 수입비용현황
**          PERFORM set_ranges_data TABLES gr_refno
**                                         gr_date
**                                   USING 'PO'
**                                         l_count.
**          SUBMIT ztir9011 WITH s_ebeln IN gr_refno AND RETURN.
*
*      LOOP AT IT_LIST WHERE BOX = 'X'.
*
*        REFRESH IT_MEMORY.
*        LOOP AT IT_CS_TOTAL WHERE EBELN = IT_LIST-EBELN
*                              AND EBELP = IT_LIST-EBELP.
*          CLEAR : IT_MEMORY.
*          IT_MEMORY-BUKRS = T001-BUKRS.
*          IT_MEMORY-ICSNO = IT_CS_TOTAL-ICSNO.
*          IT_MEMORY-ICSSQ = IT_CS_TOTAL-ICSSQ.
*          COLLECT IT_MEMORY.
*
*        ENDLOOP.
*      ENDLOOP.
*
**---> 메모리..
*      PERFORM CALL_TCODE_ZTIR9011  TABLES IT_MEMORY
*                                   USING  G_LIST
*                                          T001-BUKRS.
*
*    WHEN 'ZTIR902'. "ZTIR902 - 수입미착현황
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'PO'
*                                     L_COUNT.
*      SUBMIT ZTIR9020 WITH S_EBELN IN GR_REFNO AND RETURN.
*
**--------------------------------------------------------------------*
**> 착지변경
*    WHEN 'ZTSCHGHIST'.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO
*                                     GR_DATE
*                               USING 'WBP'
*                                     L_COUNT.
*      IF L_COUNT > 1.
*        MESSAGE S929 DISPLAY LIKE 'E'.  EXIT.
*      ENDIF.
*
*      PERFORM ORDER_CHANGE USING IT_LIST
*                                 R_UCOMM.
*
**--------------------------------------------------------------------*
**>계약 Narrow Down
*    WHEN 'ZTSNARROW'.
*      IF L_COUNT > 1 .
*        MESSAGE E929.  EXIT.
*      ENDIF.
*      IF IT_LIST-ICWB(3) EQ SPACE OR
*         IT_LIST-ICWB(3) EQ ICON_LED_RED(3).
*        MESSAGE E605 WITH '계약문서'. EXIT.
*      ENDIF.
*
*      IF IT_LIST-TKONN IS INITIAL.
*        MESSAGE E999 WITH '참조할 계약이 존재하지 않습니다.'.
*      ENDIF.
*      PERFORM SET_NARROW_DOWN USING IT_LIST
*                                    L_DOCNO.
*
**--------------------------------------------------------------------*
**>품질보증 : 오더변경 화면 Call
*    WHEN 'ZTSQMLCKMM'.
*      IF L_COUNT > 1 .
*        MESSAGE E929.  EXIT.
*      ENDIF.
*
*      IF IT_LIST-ICWB IS INITIAL.
*        MESSAGE S999 DISPLAY LIKE 'E' WITH '계약이 존재하지 않습니다.'.
*        EXIT.
*      ENDIF.
*
*      PERFORM SET_BDC_PARAMS USING CTU_PARAMS.
*      PERFORM CALL_BDC_ORDER_CHANGE(SAPLZ_TS_CHANGE_COMMON) USING IT_LIST-TKONN
*                                                                  IT_LIST-TKSEQ
*                                                                  IT_LIST-TPOSN
*                                                                  CTU_PARAMS
*                                                                  L_SUBRC.
*
**--------------------------------------------------------------------*
**> Formula 수정 : 사전계약 참조생성으로 Call
*    WHEN 'ZTSFMLCKMM'.
*      IF L_COUNT > 1 .
*        MESSAGE E929.  EXIT.
*      ENDIF.
*
*      IF IT_LIST-ICWB(3) EQ SPACE OR
*         IT_LIST-ICWB(3) EQ ICON_LED_RED(3).
*        MESSAGE S605 DISPLAY LIKE 'E' WITH '계약문서'. EXIT.
*      ENDIF.
*
*      IF IT_LIST-TKONN IS INITIAL.
*        MESSAGE S999 DISPLAY LIKE 'E' WITH '참조할 계약이 존재하지 않습니다.'.
*        EXIT.
*      ENDIF.
*
*      CTU_PARAMS-DISMODE  = 'E'. ">처리모드
*      PERFORM EXEC_COPY_REF(ZTSR1000) USING IT_LIST-TKONN
*                                            CTU_PARAMS-DISMODE
*                                            L_SUBRC.
*
*      CLEAR: *ZTSTWBK.
*      IMPORT *ZTSTWBK FROM MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TS_WB_SAVE_DOCUMENT'.
*
**--------------------------------------------------------------------*
*    WHEN 'ZLINK'.
*      IF L_COUNT > 1.
*        MESSAGE E929.  EXIT.
*      ENDIF.
*
*      PERFORM PO_NUMBER_EXPORT_MEMORY USING IT_LIST-EBELN
*                                            IT_LIST-EBELP
*                                            IT_LIST-IBLNO
*                                            IT_LIST-IBLIT.
*
***************************************************
**20130725 by jsh - GSC
**GSC 수입진행사항 반입예정, 반입, 반출, 적하부보 기능 추가
***반입예정정보
*    WHEN 'ZTIR450'.
*      IF IT_LIST-ICBS EQ '@5B\Q생성완료@'. " 생성 됐을때
*        MESSAGE E999 WITH '반입예정정보가 생성되어 있습니다.'.
*      ENDIF.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                           USING 'BL' L_COUNT.
*
**--> MEMORY CLEAR.
*      CLEAR : *ZTITBSK.
*      EXPORT *ZTITBSK TO MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.
*
*      SUBMIT  ZTIR4500 WITH S_IBLNO  IN GR_REFNO
*                      AND RETURN.
*
**--> MEMORY ID 받아오기...
*      IMPORT *ZTITBSK FROM MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.
*
*      CLEAR L_DOCNO.
*      IF *ZTITBSK-IBSNO IS NOT INITIAL.
*        L_DOCNO = *ZTITBSK-IBSNO.
*      ENDIF.
*
*      CLEAR : *ZTITBSK.
*      EXPORT *ZTITBSK TO MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TI_BS_SAVE_DOCUMENT'.
*
***반입예정생성 T-CODE
*    WHEN 'ZTIT451'.
*
*      IF IT_LIST-ICBS EQ '@5B\Q생성완료@'. " 생성됬을때
*        MESSAGE E999 WITH '반입예정정보가 생성되어 있습니다.'.
*      ENDIF.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY IBLNO.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                            COMPARING IBLNO.
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR4500) IF FOUND
*       TABLES IT_ZTIS_PKEY
*        USING L_DOCNO R_UCOMM.
*
***반입예정변경,조회,삭제 T-CODE
*    WHEN 'ZTIT452' OR 'ZTIT453' OR 'ZTIT454'.
*      IF IT_LIST-ICBS EQ '@5C\Q미생성.@'. " 생성됬지 않았을때
*        MESSAGE E999 WITH '반입예정정보가 생성되지 않았습니다.'.
*      ENDIF.
*
*      PERFORM CALL_BS_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IBSNO
*                                                                                        L_DOCNO
*                                                                                        R_UCOMM.
*************************************************************
***반입 DUE LIST 연결
***반입정보
*    WHEN 'ZTIR460'.
*      IF IT_LIST-ICBI EQ '@5B\Q생성완료@'. " 생성됬을때
*        MESSAGE E999 WITH '반입정보가 생성되어 있습니다.'.
*      ENDIF.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                           USING 'BL' L_COUNT.
*
**--> MEMORY CLEAR.
*      CLEAR : *ZTITBIK.
*      EXPORT *ZTITBIK TO MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.
*
*      SUBMIT  ZTIR4600 WITH S_IBLNO  IN GR_REFNO
*                                          AND RETURN.
*
**--> MEMORY ID 받아오기...
*      IMPORT *ZTITBIK FROM MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.
*
*      CLEAR L_DOCNO.
*      IF *ZTITBIK-IBINO IS NOT INITIAL.
*        L_DOCNO = *ZTITBIK-IBINO.
*      ENDIF.
*
*      CLEAR : *ZTITBIK.
*      EXPORT *ZTITBIK TO MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TI_BI_SAVE_DOCUMENT'.
*
*
***반입생성 T-CODE
*    WHEN 'ZTIT461'.
*      IF IT_LIST-ICBI EQ '@5B\Q생성완료@'. " 생성됬을때
*        MESSAGE E999 WITH '반입정보가 생성되어 있습니다.'.
*      ENDIF.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY IBLNO.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                            COMPARING IBLNO.
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR4600) IF FOUND
*       TABLES IT_ZTIS_PKEY
*        USING L_DOCNO R_UCOMM.
*
***반입변경,조회,삭제 T-CODE
*    WHEN 'ZTIT462' OR 'ZTIT463' OR 'ZTIT464'.
*      IF IT_LIST-ICBI EQ '@5C\Q미생성.@'. " 생성됬지 않았을때
*        MESSAGE E999 WITH '반입정보가 생성되지 않았습니다.'.
*      ENDIF.
*      PERFORM CALL_BI_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IBINO
*                                                                                        IT_LIST-BLNUM
*                                                                                        L_DOCNO
*                                                                                        R_UCOMM.
*
*************************************************************
***반출 DUE LIST 연결
***반출정보
*    WHEN 'ZTIR470'.
*      IF IT_LIST-ICBO EQ '@5B\Q생성완료@'. " 생성됬을때
*        MESSAGE E999 WITH '반출정보가 생성되어 있습니다.'.
*      ENDIF.
*      PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                           USING 'BL' L_COUNT.
*
**--> MEMORY CLEAR.
*      CLEAR : *ZTITBOK.
*      EXPORT *ZTITBOK TO MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.
*
*      SELECT SINGLE *
*        FROM ZTITCCK
*        WHERE ICCNO EQ IT_LIST-ICCNO.
***통관면장이 존재할 경우
*      IF SY-SUBRC EQ 0.
*        SUBMIT  ZTIR4700 WITH S_IBLNO  IN GR_REFNO
*                        AND RETURN.
***통관면장이 존재하지 않을 경우
*      ELSE.
*        SUBMIT  ZTIR4700 WITH S_IBLNO  IN GR_REFNO
*                                   WITH P_CC EQ ''
*                                   WITH  P_BI EQ 'X'
*                                   AND RETURN.
*      ENDIF.
*
**--> MEMORY ID 받아오기...
*      IMPORT *ZTITBOK FROM MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.
*
*      CLEAR L_DOCNO.
*      IF *ZTITBOK-IBONO IS NOT INITIAL.
*        L_DOCNO = *ZTITBOK-IBONO.
*      ENDIF.
*
*      CLEAR : *ZTITBOK.
*      EXPORT *ZTITBOK TO MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TI_BO_SAVE_DOCUMENT'.
*
*    WHEN 'ZTIT471'.
*      IF IT_LIST-ICBO EQ '@5B\Q생성완료@'. " 생성됬을때
*        MESSAGE E999 WITH '반출정보가 생성되어 있습니다.'.
*      ENDIF.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY IBLNO.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                            COMPARING IBLNO.
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR4700) IF FOUND
*       TABLES IT_ZTIS_PKEY
*        USING L_DOCNO R_UCOMM.
*
***반출변경,조회,삭제 T-CODE
*    WHEN 'ZTIT472' OR 'ZTIT473' OR 'ZTIT474'.
*      IF IT_LIST-ICBO EQ '@5C\Q미생성.@'. " 생성되지 않았을때
*        MESSAGE E999 WITH '반출정보가 생성되지 않았습니다.'.
*      ENDIF.
*      PERFORM CALL_BO_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IBONO
*                                                                                        IT_LIST-BLNUM
*                                                                                        L_DOCNO
*                                                                                        R_UCOMM.
*
*************************************************************
***적하부보 DUE LIST 연결
***적하부보
*    WHEN 'ZTIR100'.
*      IF IT_LIST-ICIP EQ '@5D\Q요청완료@' OR IT_LIST-ICIP EQ '@5B\Q생성완료@'. "생성됬을때
*        MESSAGE E999 WITH '적하부보가 생성되어 있습니다.'.
*      ENDIF.
*
*      CASE ZTITIG00-IPMTH.
***BL 데이타 생성기준
*        WHEN 'B'.
*          PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                                   USING 'BL' L_COUNT.
*
**--> MEMORY CLEAR.
*          CLEAR : *ZTITIP1.
*          EXPORT *ZTITIP1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*
*
*          SUBMIT  ZTIR1000 WITH S_IBLNO  IN GR_REFNO
*                          AND RETURN.
*
***PO 데이타 생성기준
*        WHEN 'P'.
*          PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                                   USING 'PO' L_COUNT.
*
**--> MEMORY CLEAR.
*          CLEAR : *ZTITIP1.
*          EXPORT *ZTITIP1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*
*
*          SUBMIT  ZTIR1000 WITH S_EBELN  IN GR_REFNO
*                          AND RETURN.
***IR 데이타 생성기준
*        WHEN 'R'.
*          PERFORM SET_RANGES_DATA TABLES GR_REFNO GR_DATE
*                                   USING 'IR' L_COUNT.
*
**--> MEMORY CLEAR.
*          CLEAR : *ZTITIP1.
*          EXPORT *ZTITIP1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*
*
*          SUBMIT  ZTIR1000 WITH S_REQNO  IN GR_REFNO
*                          AND RETURN.
*
*      ENDCASE.
*
**--> MEMORY ID 받아오기...
*      IMPORT *ZTITIP1 FROM MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*
*      CLEAR L_DOCNO.
*      IF *ZTITIP1-IIPNO IS NOT INITIAL.
*        L_DOCNO = *ZTITIP1-IIPNO.
*      ENDIF.
*
*      CLEAR : *ZTITIP1.
*      EXPORT *ZTITIP1 TO MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*      FREE MEMORY ID 'Z_TI_IP_SAVE_DOCUMENT'.
*
***적하부보 생성
*    WHEN 'ZTIT101'.
*      IF IT_LIST-ICIP EQ '@5D\Q요청완료@' OR IT_LIST-ICIP EQ '@5B\Q생성완료@'."생성됬을때
*        MESSAGE E999 WITH '적하부보가 생성되어 있습니다.'.
*      ENDIF.
*      LOOP AT IT_LIST WHERE BOX EQ 'X'.
*        MOVE-CORRESPONDING : IT_LIST TO GS_ZTIS_PKEY.
*        APPEND GS_ZTIS_PKEY TO IT_ZTIS_PKEY.
*      ENDLOOP.
*
*      SORT IT_ZTIS_PKEY BY IBLNO.
*      DELETE ADJACENT DUPLICATES FROM IT_ZTIS_PKEY
*                            COMPARING IBLNO.
*
*      PERFORM CHECK_AND_CALL_TRANSACTION(ZTIR1000) IF FOUND
*       TABLES IT_ZTIS_PKEY
*        USING L_DOCNO R_UCOMM.
*
***적하부보,변경,조회,삭제, 배서생성, 확정 T-CODE
*    WHEN 'ZTIT102' OR  'ZTIT103' OR 'ZTIT104' OR
*         'ZTIT105' OR
*         'ZTIT151'.
*      IF IT_LIST-ICIP EQ '@5C\Q미생성.@'. " 생성됬을때
*        MESSAGE E999 WITH '적하부보가 생성되지 않았습니다.'.
*      ENDIF.
*      PERFORM CALL_IP_DOCUMENT_NEW(ZTIRCOMM) USING IT_LIST-IIPNO
*                                                   IT_LIST-AMDSQ_IP
*                                                   L_DOCNO
*                                                   R_UCOMM.
WHEN OTHERS.
ENDCASE.

*  IF L_DOCNO IS NOT INITIAL.
**> Refresh
*    PERFORM LIST_REFRESH  USING RS_SELFIELD.
*  ENDIF.


CLEAR: R_UCOMM.

ENDFORM.                    " CONTEXT_MENU_TCODE
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8114   text
*      -->P_L_COUNT  text
*----------------------------------------------------------------------*
FORM SET_RANGES_DATA  TABLES PT_REFNO STRUCTURE GR_REFNO
                             PT_DATE  STRUCTURE GR_DATE
                       USING P_DOCTY
                             P_COUNT.

  DATA: BEGIN OF LT_IVONO OCCURS 0,
          IVONO LIKE ZTITIVK-IVONO,
        END OF LT_IVONO.

  CLEAR: LT_IVONO, LT_IVONO[],
         PT_REFNO, PT_REFNO[].



  IF P_DOCTY EQ 'CS'.  "> 비용일 경우....
*    REFRESH PT_REFNO.
*    LOOP AT IT_LIST WHERE BOX = 'X'.
*      LOOP AT IT_CS_TOTAL WHERE EBELN = IT_LIST-EBELN
*                            AND EBELP = IT_LIST-EBELP.
*        PT_REFNO-SIGN   = 'I'.
*        PT_REFNO-OPTION = 'EQ'.
*        PT_REFNO-LOW    = IT_CS_TOTAL-ICSNO.
*        PT_REFNO-HIGH   = SPACE.
*        COLLECT PT_REFNO.
*      ENDLOOP.
*    ENDLOOP.

  ELSE.


    LOOP AT IT_LIST WHERE BOX = 'X'.
*    ADD 1 TO p_count.

      CASE P_DOCTY.
        WHEN 'PO'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-EBELN.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

*        WHEN 'OS'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-OSNUM.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.

        WHEN 'IR'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-REQNO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

        WHEN 'IP'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IIPNO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

        WHEN 'BL'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IBLNO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

**modify by jsh (20130723)
**반입관리번호
        WHEN 'BI'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IBINO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

        WHEN 'IV'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IVONO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

          PT_DATE-SIGN   = 'I'.
          PT_DATE-OPTION = 'EQ'.
          PT_DATE-LOW    = IT_LIST-BUDAT.
          PT_DATE-HIGH   = 00000000.
          COLLECT PT_DATE.

*        WHEN 'IV_L'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-IBLNO.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.

*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-BLDAT_IV.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

*        WHEN 'CR'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-ICCNO_R.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.

        WHEN 'CC'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-ICCNO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-CDCDT.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

        WHEN 'GR'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IGRNO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-BUDAT_G.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

*        WHEN 'VA'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-VATNO.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.
*
*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-BLDAT_VA.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

*        WHEN 'VA_PO'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-EBELN.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.
*
*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-BLDAT_VA.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

*        WHEN 'PN'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-PNTNO.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.
*
*          PT_DATE-SIGN   = 'I'.
*          PT_DATE-OPTION = 'EQ'.
*          PT_DATE-LOW    = IT_LIST-CDAT_PN.
*          PT_DATE-HIGH   = 00000000.
*          COLLECT PT_DATE.

*        WHEN 'PN_B'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-RE_BELNR.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.

*        WHEN 'OI'.
*          CLEAR: LT_IVONO, LT_IVONO[].
*          IF IT_LIST-IVONO IS NOT INITIAL.
*            CLEAR: PT_REFNO.
*            PT_REFNO-SIGN   = 'I'.
*            PT_REFNO-OPTION = 'EQ'.
*            PT_REFNO-LOW    = IT_LIST-IVONO.
*            PT_REFNO-HIGH   = SPACE.
*            COLLECT PT_REFNO.
*
*            SELECT IVONO
*              INTO CORRESPONDING FIELDS OF TABLE LT_IVONO
*              FROM ZTITIVK
*             WHERE OIVNO EQ IT_LIST-IVONO.
*
*            IF SY-SUBRC EQ 0.
*              LOOP AT LT_IVONO.
*                PT_REFNO-SIGN   = 'I'.
*                PT_REFNO-OPTION = 'EQ'.
*                PT_REFNO-LOW    = LT_IVONO-IVONO.
*                PT_REFNO-HIGH   = SPACE.
*                COLLECT PT_REFNO.
*              ENDLOOP.
*            ENDIF.
*          ENDIF.

        WHEN 'BI'.
          PT_REFNO-SIGN   = 'I'.
          PT_REFNO-OPTION = 'EQ'.
          PT_REFNO-LOW    = IT_LIST-IBINO.
          PT_REFNO-HIGH   = SPACE.
          COLLECT PT_REFNO.

*        WHEN 'LG'.
*          PT_REFNO-SIGN   = 'I'.
*          PT_REFNO-OPTION = 'EQ'.
*          PT_REFNO-LOW    = IT_LIST-ILGNO.
*          PT_REFNO-HIGH   = SPACE.
*          COLLECT PT_REFNO.

      ENDCASE.

    ENDLOOP.

  ENDIF.

  DELETE PT_REFNO WHERE LOW EQ SPACE.
  DESCRIBE TABLE PT_REFNO LINES P_COUNT.

*  CHECK p_docty NE 'OI'.

  CASE  P_COUNT.
    WHEN 0.
      MESSAGE E917 DISPLAY LIKE 'E'. EXIT.
*    WHEN 1.
*      READ TABLE IT_LIST INDEX rs_selfield-tabindex.
*    WHEN OTHERS.
*              MESSAGE s929 DISPLAY LIKE 'E'.  EXIT.
  ENDCASE.


ENDFORM.                    " SET_RANGES_DATA
