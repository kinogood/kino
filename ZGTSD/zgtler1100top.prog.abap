*&---------------------------------------------------------------------*
*&  Include           ZLER0401TOP
*&---------------------------------------------------------------------*

CONSTANTS: GC_VKORG  LIKE VBAK-VKORG VALUE '6000',
           GC_TCODE1 LIKE TSTC-TCODE VALUE 'ZGTLER1101',  "생성
           GC_TCODE2 LIKE TSTC-TCODE VALUE 'ZGTLER1102',  "변경
           GC_TCODE3 LIKE TSTC-TCODE VALUE 'ZGTLER1103',  "조회
           GC_TCODE4 LIKE TSTC-TCODE VALUE 'ZLE0402A',  "변경(접수)
           GC_WAERK_KRW TYPE T001-WAERS VALUE 'KRW',
           GC_LENGTH LIKE CABN-ATNAM VALUE 'SAP_LENGTH_VKRME',  "조장
           GC_CBASE  LIKE CABN-ATNAM VALUE 'PD_CA_COLOR_BASE',  "색상
           GC_JOBNO  LIKE CABN-ATNAM VALUE 'PD_BD_JOB_NO', "제조지시번호
           GC_INSCD  LIKE CABN-ATNAM VALUE 'PD_CA_INS_IDEN_CODE'. "절연

TABLES: SSCRFIELDS.
DATA: FUNCTXT       TYPE SMP_DYNTXT.

TABLES: VBAK,
        VBAP,
        VBEP,
        VBPA,
        ZLET0400,
        ZLET0401,
        ZLET0402.

DATA: BEGIN OF GS_KEY,
        KEYNO(30),                            "출하요청 or 제조지시번호
        VBELN       LIKE ZLET0401-VBELN,      "판매오더
        KUNAG       LIKE ZLET0400-KUNAG,      "판매처
        KUNWE       LIKE ZLET0400-KUNWE,      "납품처
        POST_CODE1  LIKE ZLET0400-POST_CODE1, "우편번호
        LAND1       LIKE ZLET0400-LAND1,      "국가
        LZONE       LIKE ZLET0400-LZONE,      "운송지역
        TRTYP       LIKE ZLET0400-TRTYP,      "운송유형
        VSTEL       LIKE ZLET0400-VSTEL,      "출하지점
      END   OF GS_KEY.

DATA: BEGIN OF GS_DELV,
        POST_CODE1  LIKE ZLET0400-POST_CODE1, "우편번호
        LAND1       LIKE ZLET0400-LAND1,      "국가
        LZONE       LIKE ZLET0400-LZONE,      "운송지역
        CITY1       LIKE ZLET0400-CITY1,      "상세주소
        STREET      LIKE ZLET0400-STREET,     "상세주소2
        EXTENSION1  LIKE ZLET0400-EXTENSION1, "수령인
        TEL_NUMBER  LIKE ZLET0400-TEL_NUMBER, "연락처
        ARIND       LIKE ZLET0400-ARIND,      "도착시간 입력여부
        ARRDT       LIKE ZLET0400-ARRDT,      "도착일
        ARRTM       LIKE ZLET0400-ARRTM,      "도착시간
        IMMDT       LIKE ZLET0400-IMMDT,      "긴급출하
        ALONE       LIKE ZLET0400-ALONE,      "단독여부(혼적)
        ZREQ_TYPE   LIKE ZLET0400-ZREQ_TYPE,  "직송의뢰 신청 유형
        VHCTP       LIKE ZLET0400-VHCTP,      "차량제한여부
        VHCTX       LIKE TVSAKT-BEZEI,        "내역
        BKNFT       LIKE ZLET0400-BKNFT,      "왕복여부
        DIVID       LIKE ZLET0400-DIVID,      "분할출하
        TRTYP       LIKE ZLET0400-TRTYP,      "운송유형
        REMARK      LIKE ZLET0400-REMARK,     "비고
        ZREMARK1    LIKE ZLET0400-REMARK,     "출하실 요청사항
      END   OF GS_DELV.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        STAT_C      LIKE ICON-ID,             "여신점검 LED
        KEYNO       LIKE GS_KEY,
        DLVRQ       LIKE ZLET0400-DLVRQ,      "출하요청번호
        VBELN       LIKE ZLET0401-VBELN,      "판매오더
        POSNR       LIKE ZLET0401-POSNR,      "판매오더품목
        AUART       LIKE ZLET0400-AUART,      "오더유형
        VKORG       LIKE ZLET0400-VKORG,      "영업조직
        VKBUR       LIKE ZLET0400-VKBUR,      "영업팀
        VKGRP       LIKE ZLET0400-VKGRP,      "영업그룹
        PERNR       LIKE ZLET0400-PERNR,      "영업사원
        SNAME       LIKE ZZPA0001-SNAME,        "영업사원명
        CMGST       LIKE VBUK-CMGST,          "여신상태
        KUNWE       LIKE ZLET0400-KUNWE,      "납품처
        NAMWE       LIKE KNA1-NAME1,          "납품처명
        ADRNR       LIKE VBPA-ADRNR,          "납품처주소
        KUNAG       LIKE ZLET0400-KUNAG,      "판매처
        NAMAG       LIKE KNA1-NAME1,          "판매처명
        BSTKD       LIKE VBKD-BSTKD,          "PO번호
        BSTDK       LIKE VBKD-BSTDK,          "PO일자 - 기능개선 161289
        EMPST       LIKE VBKD-EMPST,          "Drum # - 기능개선 164038
        KDKG4       LIKE ZLET0400-KDKG4,      "내수/수출
        SOBKZ       LIKE ZLET0401-SOBKZ,      "특별재고지시자
        SOTXT(10),                            "MTO/MTS
        MATNR       LIKE ZLET0401-MATNR,      "자재
        MAKTX       LIKE MAKT-MAKTX,          "제품명
        KWMENG      LIKE ZLET0401-KWMENG,     "오더수량
        VRKME       LIKE ZLET0401-VRKME,      "판매단위
        INDLEN      LIKE ZLET0401-INDLEN,     "조장
        INDQTY      LIKE ZLET0401-INDQTY,     "조장수
        INDMEI      LIKE MARA-MEINS,          "조장수 단위
        COLOR       LIKE AUSP-ATWRT,          "색상
        JOBNO       LIKE AUSP-ATWRT,          "제조지시번호
        INSCD       LIKE AUSP-ATWRT, "절연선심식별코드 - 기능개선 161289
        VSTEL       LIKE ZLET0400-VSTEL,      "출하지점
        VTEXT       LIKE TVSTT-VTEXT,         "출하지점명
        WERKS       LIKE ZLET0401-WERKS,      "플랜트
        NAME1       LIKE T001W-NAME1,         "플랜트명
        LGORT       LIKE VBAP-LGORT,          "기능개선 231127 - 추가
        SPART       LIKE ZLET0400-SPART.      "제품군
        INCLUDE STRUCTURE GS_DELV.
DATA:   DRCMG       LIKE ZLET0401-KWMENG,     "기출하요청
        UDMNG       LIKE ZLET0401-KWMENG,     "미출고(출하요청완료)
        LFIMG       LIKE LIPS-LFIMG,          "납품생성수량
        DCMNG       LIKE ZLET0401-KWMENG,     "출고완료
        LFIMG_R     LIKE LIPS-LFIMG,          "납품생성수량-출하요청
        DCMNG_R     LIKE ZLET0401-KWMENG,     "출고완료-출하요청
        LFIMG_M     LIKE LIPS-LFIMG,          "납품생성수량-자신
        RAMNG       LIKE ZLET0401-KWMENG,     "요청가능수량
        LABST       LIKE ZLET0401-KWMENG,     "가용재고
        INSME       LIKE ZLET0401-KWMENG,     "품질재고
        EDATU       LIKE ZLET0401-EDATU,      "납품일정
        BMENG       LIKE VBEP-BMENG,          "확정수량
        DLRMG       LIKE ZLET0401-DLRMG,      "출하요청수량
        DRIND       LIKE ZLET0401-INDQTY,     "출하요청조장수
        REVIW       LIKE ZLET0401-REVIW,      "출하검토여부
        RVSTA(2),                             "출하검토 상태
        REVMG       LIKE ZLET0401-REVMG,      "출하검토수량
        LECFM       LIKE ZLET0401-LECFM,      "출하확정
        SDCFM       LIKE ZLET0401-SDCFM,      "영업확정
        CONFM,                                "납품문서 생성여부
        AVLBT(10),                            "가용성
        ABGRU       LIKE VBAP-ABGRU,          "거절사유
        HLVORM      LIKE ZLET0400-LVORM,      "삭제지시자
        ILVORM      LIKE ZLET0401-LVORM,      "삭제지시자
        TRADE,                                "수출/내수 구분
        VGBEL       LIKE ZLET0402-VGBEL,      "납품문서
        VGPOS       LIKE ZLET0402-VGPOS,      "납품품목
        LFIMG_D     LIKE LIPS-LFIMG,          "납품문서수량
        SACPT(4),                             "선적접수여부
        LIFSK       LIKE VBAK-LIFSK,          "납품보류
        MARK,
        HDSEL,
        ITSEL,

        ZTERM       LIKE VBKD-ZTERM,
        ERDAT       LIKE VBAK-ERDAT,
        VTWEG       LIKE VBAK-VTWEG,

        MSG(80),

        KUNRG       TYPE KNA1-KUNNR,          "지급처
        KKBER       TYPE VBAK-KKBER,          "여신영역
        WAERK       TYPE VBAP-WAERK,          "문서통화
        NETWR       TYPE VBAP-NETWR,          "금액
        MWSBP       TYPE VBAP-MWSBP,          "세금
        DLRMG_OLD   TYPE ZLET0401-DLRMG,      "저장된 DB의 출하요청수량
        FIXMG       TYPE VBAP-FIXMG,
        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: BEGIN OF GS_LINK ,
        DLVRQ       LIKE ZLET0400-DLVRQ,      "출하요청번호
        VBELN       LIKE ZLET0401-VBELN,      "판매오더
        POSNR       LIKE ZLET0401-POSNR,      "판매오더품목
        MATNR       LIKE ZLET0401-MATNR,      "자재
        WERKS       LIKE ZLET0401-WERKS,      "플랜트
        UPDKZ(1),
      END OF GS_LINK.
DATA: GT_LINK LIKE TABLE OF GS_LINK.

DATA: BEGIN OF GT_0401 OCCURS 0,
        DLVRQ       LIKE ZLET0401-DLVRQ,      "출하요청번호
        VBELN       LIKE ZLET0401-VBELN,      "판매오더
        POSNR       LIKE ZLET0401-POSNR,      "판매오더품목
        DLRMG       LIKE ZLET0401-DLRMG,      "출하요청수량
        VRKME       LIKE ZLET0401-VRKME,      "판매단위
        UDMNG       LIKE ZLET0401-KWMENG,     "미출고(출하요청완료)
        DCMNG       LIKE ZLET0401-KWMENG,     "출고완료
        RAMNG       LIKE ZLET0401-KWMENG,     "요청가능수량
      END   OF GT_0401.

DATA: BEGIN OF GT_0402 OCCURS 0.
        INCLUDE STRUCTURE ZLET0402.
DATA:   LFIMG       LIKE LIPS-LFIMG,
        VRKME       LIKE LIPS-VRKME,
      END   OF GT_0402.

DATA: BEGIN OF GT_0406 OCCURS 0,
        VBELN       LIKE ZLET0401-VBELN,
        POSNR       LIKE ZLET0401-POSNR.
        INCLUDE STRUCTURE ZLET0406.
DATA: END   OF GT_0406.

DATA: GV_AGNNM1     LIKE KNA1-NAME1,          "에이전트명1
      GV_AGNNM2     LIKE KNA1-NAME1,          "에이전트명2
      GV_ABWNM      LIKE KNA1-NAME1.          "대체수취인명

DATA: BEGIN OF GT_UPLD OCCURS 0,
        VBELN(10),                            "판매오더
        POSNR(6),                             "품목
        KUNAG(10),                            "판매처
        NAMAG(35),                            "판매처명
        KUNWE(10),                            "납품처
        NAMWE(35),                            "납품처명
        MATNR(18),                            "자재
        MAKTX(40),                            "자재내역
        KWMENG(20),                           "판매오더수량
        VRKME(3),                             "판매단위
        INDLEN(15),                           "조장
        INDQTY(5),                            "조장수
        AVLBT(10),                            "가용성점검
        CMGST(1),                             "여신상태
        ABGRU(2),                             "거부사유
        LABST(20),                            "가용재고
        INSME(20),                            "품질재고
        RAMNG(20),                            "요청가능수량
        EDATU(10),                            "출하요청일
        DLRMG(20),                            "출하요청수량
        REMARK(100),                          "비고
        POST_CODE1(10),                       "우편번호
        LAND1(3),                             "국가
        LZONE(10),                            "운송지역
        CITY1(40),                            "상세주소
        STREET(60),                           "상세주소2
        EXTENSION1(40),                       "수령인
        TEL_NUMBER(30),                       "연락처
        ARRDT(10),                            "도착일
        ARRTM(8),                             "도착시간
        IMMDT(1),                             "긴급출하
        ALONE(1),                             "단독여부
        BKNFT(1),                             "왕복여부
        VHCTP(4),                             "차량제한
        VHCTX(40),                            "차량제한명
        DIVID(1),                             "분할출하
        TRTYP(2),                             "운송유형
      END   OF GT_UPLD.

DATA: BEGIN OF GT_VBAP OCCURS 0,
        VBELN       LIKE VBAP-VBELN,
        POSNR       LIKE VBAP-POSNR,
        DLRMG       LIKE VBAP-KWMENG,
      END   OF GT_VBAP.

DATA: GV_DLVRQ      LIKE ZLET0400-DLVRQ,
      GV_EDATU      LIKE ZLET0401-EDATU.

DATA: GV_ICON(4).

DATA: GV_TRTYP      TYPE TRTYP,               "A: 조회, H:생성, V:변경
      GV_DISP,
      GV_TITLE(50),
      GV_TITLE1(50),
      GV_ERROR,
      GV_ANSWER.

DATA: GV_TEXT(20),
      GV_MSG.                "Upload Data에 이상이 있는 경우 팝업창 표시

DATA: GS_MAIN       LIKE GT_MAIN,
      GV_POSNR      LIKE LIPS-POSNR.

DATA: GV_SUBSCR     LIKE SY-DYNNR,
      GV_CURSOR1(30),
      GV_CURSOR2(30).

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.

RANGES: GR_AUART    FOR  VBAK-AUART.

*___BDC용 변수
TABLES: CTU_PARAMS.

DATA: GV_MODE       LIKE CTU_PARAMS-DISMODE VALUE 'N'.

DATA: BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END   OF GT_BDCTAB.

DATA: GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

*___텍스트 읽기용
DATA: BEGIN OF GT_KNA1 OCCURS 0,
        KUNNR       LIKE KNA1-KUNNR,
        NAME1       LIKE KNA1-NAME1,
      END   OF GT_KNA1.

DATA: BEGIN OF GT_ADRC OCCURS 0,
        ADDRNUMBER  LIKE ADRC-ADDRNUMBER,
        NAME1       LIKE ADRC-NAME1,
        POST_CODE1  LIKE ADRC-POST_CODE1,
        COUNTRY     LIKE ADRC-COUNTRY,
        TRANSPZONE  LIKE ADRC-TRANSPZONE,
        CITY1       LIKE ADRC-CITY1,
        STREET      LIKE ADRC-STREET,
        EXTENSION1  LIKE ADRC-EXTENSION1,
        EXTENSION2  LIKE ADRC-EXTENSION2,
        TEL_NUMBER  LIKE ADRC-TEL_NUMBER,
      END   OF GT_ADRC.

DATA: BEGIN OF GT_MAKT OCCURS 0,
        MATNR       LIKE MARA-MATNR,
        MAKTX       LIKE MAKT-MAKTX,
      END   OF GT_MAKT.

DATA: BEGIN OF GT_TVSTT OCCURS 0,
        VSTEL       LIKE TVSTT-VSTEL,
        VTEXT       LIKE TVSTT-VTEXT,
      END   OF GT_TVSTT.

DATA: BEGIN OF GT_T001W OCCURS 0,
        WERKS       LIKE T001W-WERKS,
        NAME1       LIKE T001W-NAME1,
      END   OF GT_T001W.

DATA: BEGIN OF GT_PA01 OCCURS 0,
        PERNR       LIKE ZZPA0001-PERNR,
        SNAME       LIKE ZZPA0001-SNAME,
      END   OF GT_PA01.

DATA: BEGIN OF GT_VBUK OCCURS 0,
        VBELN       LIKE VBUK-VBELN,
        CMGST       LIKE VBUK-CMGST,
      END   OF GT_VBUK.

DATA: BEGIN OF GT_TVSAK OCCURS 0,
        SDABW       LIKE TVSAKT-SDABW,
        BEZEI       LIKE TVSAKT-BEZEI,
      END   OF GT_TVSAK.

*___ALV용 변수
DATA: GC_CONTAINER_NAME     TYPE SCRFNAME VALUE 'CONTAINER',
      GC_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID           TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER      TYPE REF TO LCL_EVENT_HANDLER,
      GC_CONTAINER_NAME1    TYPE SCRFNAME VALUE 'CONTAINER1',
      GC_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID1          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER1     TYPE REF TO LCL_EVENT_HANDLER,
      GS_LAYOUT             TYPE LVC_S_LAYO,
      GT_SORT               TYPE LVC_T_SORT WITH HEADER LINE,
      GT_FIELDCAT           TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_FIELDCAT1          TYPE LVC_T_FCAT WITH HEADER LINE,
      GS_FIELDCAT           TYPE LVC_S_FCAT,
      GS_SCROLL             TYPE LVC_S_STBL,
      GT_COLS               TYPE LVC_T_COL,
      GS_COLS               TYPE LVC_S_COL,
      GT_ROWS               TYPE LVC_T_ROW,
      GS_ROWS               TYPE LVC_S_ROW.

DATA: GT_EXCLUDE            TYPE UI_FUNCTIONS,
      GS_VARIANT            TYPE DISVARIANT,
      GV_ITAB               LIKE GS_FIELDCAT-TABNAME,
      GV_POS                LIKE GS_FIELDCAT-COL_POS.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
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

DEFINE SET_RANGES.
  CLEAR : &1.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH   = &5.
  APPEND &1.
END-OF-DEFINITION.
