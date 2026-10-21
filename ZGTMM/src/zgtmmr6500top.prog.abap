*&---------------------------------------------------------------------*
*& Include ZGTMMR6500TOP
*&---------------------------------------------------------------------*

TABLES : ZGTMMT6500.


DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,                "Status

         BANFN       LIKE EBAN-BANFN,             "구매요청 번호
         BNFPO       LIKE EBAN-BNFPO,             "품목
         EKORG       LIKE EBAN-EKORG,             "구매조직
         WERKS       LIKE EBAN-WERKS,             "플랜트
         EKGRP       LIKE EBAN-EKGRP,             "구매그룹
         AFNAM       LIKE EBAN-AFNAM,             "요청자
         MATNR       LIKE EBAN-MATNR,             "자재
         LENTH       LIKE ZGTMMT6500-LENTH,       "길이(MM)
         NUMBR       LIKE ZGTMMT6500-NUMBR,       "개수(EA)
         LFDAT       LIKE EBAN-LFDAT,             "납품일
         ETCTX       LIKE ZGTMMT6500-ETCTX,       "비고
         FLIEF       LIKE EBAN-FLIEF,             "고정 공급업체
         NAME1       LIKE LFA1-NAME1,             "고정 공급업체명
         MAKTX       LIKE MAKT-MAKTX,             "자재 내역
         BAMNG       LIKE EBAN-MENGE,             "PR 수량
         BAMEI       LIKE EBAN-MEINS,             "PR 단위
         EBELN       LIKE EKPO-EBELN,             "구매오더 번호
         EBELP       LIKE EKPO-EBELP,             "품목
         UMREN       LIKE MARM-UMREN,             "대체수량
         MEINH       LIKE MARM-MEINH,             "대체단위
         UMREZ       LIKE MARM-UMREZ,             "기본수량
         MEINS       LIKE MARA-MEINS,             "기본단위
         LGORT       LIKE MARC-LGFSB,             "저장위치
         BADAT       LIKE EBAN-BADAT,             "요청일
         ERNAM       LIKE ZGTMMT6500-ERNAM,       "생성자
         ERDAT_LOCAL LIKE ZGTMMT6500-ERDAT_LOCAL, "생성일
         ERTIM_LOCAL LIKE ZGTMMT6500-ERTIM_LOCAL, "생성시간
         EM_RECV     LIKE ZGTMMT6500-EM_RECV,     "수신자 E-MAIL
         EM_UNAME    LIKE ZGTMMT6500-EM_UNAME,    "메일 전송자
         EM_DATLO    LIKE ZGTMMT6500-EM_DATLO,    "메일 전송일
         EM_TIMLO    LIKE ZGTMMT6500-EM_TIMLO,    "메일 전송시간
         GUIDC       LIKE ZGTMMT6500-GUIDC,       "GUID

         MSG         TYPE BAL_T_MSG,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_LIST.

DATA : GT_TMP LIKE GT_LIST OCCURS 0 WITH HEADER LINE,
       GT_SND LIKE GT_LIST OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_SND,
         FLIEF   LIKE EBAN-FLIEF,
         NAME1   LIKE LFA1-NAME1,
         EM_RECV LIKE ZGTMMT6500-EM_RECV,
       END   OF GS_SND.

DATA : GV_TEXT TYPE SO_OBJ_DES,
       GT_MTXT TYPE BCSY_TEXT,
       GS_MTXT TYPE SOLI.

DATA : BEGIN OF GS_ITM,
         BANFN(10),
         LFDAT(10),
         MAKTX(40),
         LENTH(20),
         NUMBR(10),
         BAMNG(20),
         BAMEI(3),
         MATNR(40),
       END   OF GS_ITM.


DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM,
       GV_TITLE  TYPE STRING.

DATA : GT_EXCD TYPE TABLE OF FCODE.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GV_CHK,
       GV_ERR,
       GV_REF,
       GV_ANS,
       GV_MSG(100).

DATA : GV_FNM TYPE LVC_FNAME.

DATA : GS_HND TYPE BALLOGHNDL.

DATA : GS_RHDR  LIKE BAPIMEREQHEADER,
       GS_RHDRX LIKE BAPIMEREQHEADERX,
       GT_RTN   LIKE BAPIRET2          OCCURS 0 WITH HEADER LINE,
       GT_RITM  LIKE BAPIMEREQITEMIMP  OCCURS 0 WITH HEADER LINE,
       GT_RITMX LIKE BAPIMEREQITEMX    OCCURS 0 WITH HEADER LINE,
       GT_RTXT  LIKE BAPIMEREQITEMTEXT OCCURS 0 WITH HEADER LINE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.


FIELD-SYMBOLS : <GFS_STS>,
                <GFS_MSG> TYPE BAL_T_MSG,
                <GFS_COL> TYPE LVC_T_SCOL.

RANGES : GR_MATNR FOR EORD-MATNR,
         GR_DROW  FOR LVC_S_MOCE-ROW_ID.


DEFINE _SET_HTML1.
  GS_MTXT-LINE = &1.
  APPEND GS_MTXT TO GT_MTXT.
END-OF-DEFINITION.

DEFINE _SET_HTML3.
  GS_MTXT-LINE = &1 && &2 && &3.
  APPEND GS_MTXT TO GT_MTXT.
END-OF-DEFINITION.


CONSTANTS : GC_A(1)            VALUE 'A',
            GC_C(1)            VALUE 'C',
            GC_D(1)            VALUE 'D',
            GC_E(1)            VALUE 'E',
            GC_I(1)            VALUE 'I',
            GC_L(1)            VALUE 'L',
            GC_M(1)            VALUE 'M',
            GC_S(1)            VALUE 'S',
            GC_X(1)            VALUE 'X',
            GC_0(1)            VALUE '0',
            GC_1(1)            VALUE '1',
            GC_2(1)            VALUE '2',
            GC_6(1)            VALUE '6',
            GC_*(1)            VALUE '*',
            GC_EM(1)           VALUE '!',
            GC_EQ(2)           VALUE 'EQ',
            GC_NB(2)           VALUE 'NB',
*           GC_MM(2)           VALUE 'MM',
            GC_B01(3)          VALUE 'B01',
            GC_DIS(3)          VALUE 'DIS',
            GC_LOG(3)          VALUE 'LOG',
            GC_30D(3)          VALUE '30D',
            GC_1100(4)         VALUE '1100',
            GC_1306(4)         VALUE '1306',
            GC_SAVE(4)         VALUE 'SAVE',
            GC_REFR(4)         VALUE 'REFR',
            GC_ROH1(4)         VALUE 'ROH1',
            GC_C112(4)         VALUE 'C112',
            GC_C300(4)         VALUE 'C300',
            GC_C500(4)         VALUE 'C500',
            GC_COLOR(5)        VALUE 'COLOR',
            GC_STYLE(5)        VALUE 'STYLE',
            GC_MATNR(5)        VALUE 'MATNR',
            GC_FLIEF(5)        VALUE 'FLIEF',
            GC_STATUS(6)       VALUE 'STATUS',
            GC_P_EKGRP(7)      VALUE 'P_EKGRP',
            GC_S_BADAT-LOW(11) VALUE 'S_BADAT-LOW'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_DISP RADIOBUTTON GROUP GR1
                             USER-COMMAND GR1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_DISP.

    SELECTION-SCREEN POSITION 32.
    PARAMETERS : P_CREA RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_CREA.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  PARAMETERS     : P_EKORG LIKE ZGTMMT6500-EKORG
                                OBLIGATORY MEMORY ID EKO,
                   P_WERKS LIKE ZGTMMT6500-WERKS
                                OBLIGATORY MEMORY ID WRK,
                   P_EKGRP LIKE ZGTMMT6500-EKGRP
                                OBLIGATORY MEMORY ID EKG.
  SELECT-OPTIONS : S_BADAT  FOR ZGTMMT6500-BADAT MODIF ID DIS,
                   S_AFNAM  FOR ZGTMMT6500-AFNAM MODIF ID DIS,
                   S_BANFN  FOR ZGTMMT6500-BANFN MODIF ID DIS,
                   S_MATNR  FOR ZGTMMT6500-MATNR MODIF ID DIS
                            MATCHCODE OBJECT ZGTMMH_BUSBAR,
                   S_FLIEF  FOR ZGTMMT6500-FLIEF MODIF ID DIS,
                   S_LFDAT  FOR ZGTMMT6500-LFDAT MODIF ID DIS.
SELECTION-SCREEN END   OF BLOCK BK2.
