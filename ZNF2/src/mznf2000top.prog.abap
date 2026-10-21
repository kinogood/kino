*&---------------------------------------------------------------------*
*& Include MZNF2000TOP
*&---------------------------------------------------------------------*

PROGRAM  SAPMZNF2000  MESSAGE-ID ZNF1.

* TYPE-POOLS
TYPE-POOLS : SLIS.

TABLES : ZNFT1000, ZNFT1001, ZNFT1002,
         ZNFT0003, ZNFT0004, ZNFT0005,
         T001, KNA1.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GT_ZNFT1001 OCCURS 0.
        INCLUDE STRUCTURE ZNFT1001.
DATA: CHECK TYPE CHAR01,        " 필드정보
      UPDKZ TYPE CHAR01,        " 라인상태
      DBCHK TYPE CHAR01,        " DB값구분,
      SEQ   TYPE SY-TABIX.
DATA: END OF GT_ZNFT1001.
DATA: GS_ZNFT1001 LIKE GT_ZNFT1001.

DATA: BEGIN OF GS_NFKEY,
        SEQ   TYPE VALPOS,
        NFKEY TYPE DOMVALUE_L,
      END OF GS_NFKEY.
DATA: GT_NFKEY LIKE TABLE OF GS_NFKEY.

DATA: GT_ZNFT1001N LIKE ZNFT1001 OCCURS 0 WITH HEADER LINE,
      GT_ZNFT1001D LIKE ZNFT1001 OCCURS 0 WITH HEADER LINE.

* 파일 관리
DATA: GS_FILEM LIKE ZNFT1002 OCCURS 0 WITH HEADER LINE.

*사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR       LIKE ZNFT0005-NFCTR,
        NTEXT       LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

*손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR       LIKE ZNFT0003-PRCTR,
        PTEXT       LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

*영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP       LIKE ZNFT0003-VKGRP,
        VTEXT       LIKE ZNFT0003-VTEXT,
      END OF GT_VKGRP.

DATA: GV_FLAG1,
      GV_FLAG2,
      GV_FLAG3,
      GV_FLAG4,
      GV_FLAG5.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM.

*___Change Doc 관리용
DATA: YZNFT1000     LIKE ZNFT1000,
      XGT_1001      LIKE YZNFT1001 OCCURS 0 WITH HEADER LINE,
      YGT_1001      LIKE YZNFT1001 OCCURS 0 WITH HEADER LINE.

DATA: GS_ZNFT1002N TYPE ZNFT1002,
      GS_ZNFT1002Y TYPE ZNFT1002.

************************************************************************
* F4 Help용 변수
************************************************************************
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      LV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

************************************************************************
* Screen Parameters
************************************************************************
DATA: GV_BUKRS  LIKE ZNFT1000-BUKRS VALUE '1000',  " 회사코드
      GV_COTYP  LIKE ZNFT1000-COTYP VALUE '1',     " 계약유형
      GV_CONNO  LIKE ZNFT1000-CONNO,               " 계약번호
      GV_ERROR  TYPE CHAR01,
      GV_ANSWER TYPE CHAR01,
      GV_H_CHNG TYPE CHAR01.  " Header Info Change 유부

DATA: GV_TCODE1 TYPE SY-TCODE VALUE 'ZNF2M2001',
      GV_TCODE2 TYPE SY-TCODE VALUE 'ZNF2M2002A',
      GV_TCODE3 TYPE SY-TCODE VALUE 'ZNF2M2002B',
      GV_TCODE4 TYPE SY-TCODE VALUE 'ZNF2M2003'.

DATA: GV_SCR_CHANG_FIELD TYPE CHAR05.

CONTROLS : TC1 TYPE TABLEVIEW USING SCREEN 500.
DATA: GS_COLS       LIKE LINE OF TC1-COLS .

DATA: GV_CURSOR TYPE CHAR50,    " 커서위치
      GV_CURLIN     TYPE I.     " 라인번호

DATA: GV_DEC        TYPE P DECIMALS 3.

************************************************************************
* 입력필드 제어
************************************************************************
* T-CODE : ZNF22002A, ZNF22002B :: 수정시 변경유무 필드 체크
* 'X'이면 사업부/손익센터/영업그룹/고객센터 변경불가
DATA: GV_MODI_A TYPE CHAR01,    " S/O or 선물요청과 연결여부
      GV_MODI_B TYPE CHAR01,    " 선물집행후 정산 여부
      GV_MODI_C TYPE CHAR01.    " 계약유형 (경상선물,재고헷지)

************************************************************************
* 파일첨부 관련 변수 (BAPI & ...)
************************************************************************
DATA: GS_DOCUMENTDATA         TYPE BAPI_DOC_DRAW2,
      GS_DOCUMENTDATAX        TYPE BAPI_DOC_DRAWX2 ,
      GS_DOCUMENTDESCRIPTIONS TYPE BAPI_DOC_DRAT ,
      GS_CLASSIFICATION       TYPE BAPI_CHARACTERISTIC_VALUES,
      GS_CLASSALLOCATIONS     TYPE BAPI_CLASS_ALLOCATION ,
      GS_OBJECTLINKS          TYPE BAPI_DOC_DRAD ,
      GS_DOCUMENTFILES        TYPE BAPI_DOC_FILES2 ,
      GS_LONG_TEXTS           TYPE BAPI_DOC_TEXT .

DATA: GT_FILES LIKE BAPI_DOC_FILES2 OCCURS 0 WITH HEADER LINE,
      GT_COMPS LIKE BAPI_DOC_COMP   OCCURS 0 WITH HEADER LINE.

* DMS Document번호
DATA: G_DOKAR  LIKE BAPI_DOC_AUX-DOCTYPE,
      G_DOKNR  LIKE BAPI_DOC_AUX-DOCNUMBER,
      G_DOKTL  LIKE BAPI_DOC_AUX-DOCPART,
      G_DOKVR  LIKE BAPI_DOC_AUX-DOCVERSION.
* 결과 return
DATA : GS_RETURN1 TYPE BAPIRET2 .
************************************************************************
