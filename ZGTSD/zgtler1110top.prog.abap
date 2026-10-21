*&---------------------------------------------------------------------*
*& Include          ZGTLER1110TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: SHLP.

TABLES: ZLET0400,
        ZLET0401,
        AUSP,
        VBAP.

CONSTANTS: GC_VKORG      LIKE VBAK-VKORG VALUE '6000',
           GC_LGORT_3430 TYPE LGORT_D VALUE '3430', "문경저장위치
           GC_MEINS_KG   TYPE MEINS    VALUE 'KG',
           GC_MEINS_MM   TYPE MEINS    VALUE 'MM',
           GC_MEINS_M    TYPE MEINS    VALUE 'M',
           GC_LENGTH     LIKE CABN-ATNAM VALUE 'SAP_LENGTH_VKRME',  "조장
           GC_CBASE      LIKE CABN-ATNAM VALUE 'PD_CA_COLOR_BASE',  "색상
           GC_JOBNO      LIKE CABN-ATNAM VALUE 'PD_BD_JOB_NO', "제조지시번호
*[S] 안정화 GW20260825001
           GC_STRIP      LIKE CABN-ATNAM VALUE 'PD_CA_COLOR_STRIPE', "색상  STRIP
           GC_STRIPNO    LIKE CABN-ATNAM VALUE 'PD_CA_COLOR_STRIPE_NO', "색상 수 STRIP
           GC_INSCD      LIKE CABN-ATNAM VALUE 'PD_CA_INS_IDEN_CODE'. "절연

CONSTANTS: GC_SKID   LIKE CABN-ATNAM VALUE 'PD_CA_SKID_YN'. "스퀴드여부



DATA: BEGIN OF GS_KEY,
        KEYNO(30),                            "출하요청 or 제조지시번호
        KUNAG      LIKE ZLET0400-KUNAG,      "판매처
        KUNWE      LIKE ZLET0400-KUNWE,      "납품처
        POST_CODE1 LIKE ZLET0400-POST_CODE1, "우편번호
        LAND1      LIKE ZLET0400-LAND1,      "국가
        LZONE      LIKE ZLET0400-LZONE,      "운송지역
        TRTYP      LIKE ZLET0400-TRTYP,      "운송유형
        VSTEL      LIKE ZLET0400-VSTEL,      "출하지점
        CTLPC      LIKE VBAK-CTLPC,          "여신관리:리스크범주
        CITY1      LIKE ZLET0400-CITY1,      "납지
        STREET     LIKE ZLET0400-STREET,     "납지2
      END   OF GS_KEY.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        KEYNO       LIKE GS_KEY,
        DLVRQ       LIKE ZLET0400-DLVRQ,      "출하요청번호
        VBELN       LIKE ZLET0401-VBELN,      "판매오더
        POSNR       LIKE ZLET0401-POSNR,      "판매오더품목
        VGBEL       LIKE ZLET0402-VGBEL,
        VGPOS       LIKE ZLET0402-VGPOS,
        AUART       LIKE ZLET0400-AUART,      "오더유형
        KUNWE       LIKE ZLET0400-KUNWE,      "납품처
        NAMWE       LIKE KNA1-NAME1,          "납품처명
        KUNAG       LIKE ZLET0400-KUNAG,      "판매처
        NAMAG       LIKE KNA1-NAME1,          "판매처명
        MATNR       LIKE ZLET0401-MATNR,      "자재
        MAKTX       LIKE MAKT-MAKTX,          "제품명
        KWMENG      LIKE ZLET0401-KWMENG,     "오더수량
        VRKME       LIKE ZLET0401-VRKME,      "판매단위
        INDLEN      LIKE ZLET0401-INDLEN,     "조장
        INDQTY      LIKE ZLET0401-INDQTY,     "조장수
        INDMEI      LIKE MARA-MEINS,          "조장수 단위
        COLOR(30),                            "색상
        STRIP(30),                            "strip 색상
        STRIPNO(30),                         "strip 색상 수
        JOBNO       LIKE AUSP-ATWRT,          "제조지시번호
        INSCD       LIKE AUSP-ATWRT, "절연선심식별코드 - 기능개선 161289
        BSTKD       LIKE VBKD-BSTKD,          "PO번호 - 기능개선 161289
        BSTDK       LIKE VBKD-BSTDK,          "PO일자 - 기능개선 161289
        EMPST       LIKE VBKD-EMPST,          "Drum # - 기능개선 164038
        VSTEL       LIKE ZLET0400-VSTEL,      "출하지점
        VTEXT       LIKE TVSTT-VTEXT,         "출하지점명
        CTLPC       LIKE VBAK-CTLPC,          "여신관리:리스크범주
        WERKS       LIKE ZLET0401-WERKS,      "플랜트
        NAME1       LIKE T001W-NAME1,         "플랜트명
        LGORT       LIKE VBAP-LGORT,          "기능개선 231127 - 추가
        LGORT_TX    LIKE T001L-LGOBE,
        SPART       LIKE ZLET0400-SPART,      "제품군
        POST_CODE1  LIKE ZLET0400-POST_CODE1, "우편번호
        LAND1       LIKE ZLET0400-LAND1,      "국가
        LZONE       LIKE ZLET0400-LZONE,      "운송지역
        CITY1       LIKE ZLET0400-CITY1,      "상세주소
        STREET      LIKE ZLET0400-STREET,     "상세주소2
        ADDRESS     TYPE C LENGTH 100,         "상세주소 전체
        EXTENSION1  LIKE ZLET0400-EXTENSION1, "수령인
        TEL_NUMBER  LIKE ZLET0400-TEL_NUMBER, "연락처
        ARIND       LIKE ZLET0400-ARIND,      "도착시간 입력여부
        ARRDT       LIKE ZLET0400-ARRDT,      "도착일
        ARRTM       LIKE ZLET0400-ARRTM,      "도착시간
        IMMDT       LIKE ZLET0400-IMMDT,      "긴급출하
        ALONE       LIKE ZLET0400-ALONE,      "단독여부(혼적)
        VHCTP       LIKE ZLET0400-VHCTP,      "차량제한여부
        VHCTX       LIKE TVSAKT-BEZEI,        "차량제한여부
        BKNFT       LIKE ZLET0400-BKNFT,      "왕복여부
        DIVID       LIKE ZLET0400-DIVID,      "분할출하
        ZREQ_TYPE   LIKE ZLET0400-ZREQ_TYPE,  "직송의뢰 신청 유형
        TRTYP       LIKE ZLET0400-TRTYP,      "운송유형
        REMARK      LIKE ZLET0400-REMARK,     "비고
        KDKG4       LIKE ZLET0400-KDKG4,      "내수/수출
        KDKG4_T     TYPE C LENGTH 10,        "내수/수출      "26.09 텍스트 추가
        SOBKZ       LIKE ZLET0401-SOBKZ,      "특별재고지시자
        SOTXT(10),                            "MTO/MTS
        LABST       LIKE ZLET0401-KWMENG,     "가용재고
        INSME       LIKE ZLET0401-KWMENG,     "품질재고
        EDATU       LIKE ZLET0401-EDATU,      "납품일정
        DLRMG       LIKE ZLET0401-DLRMG,      "출하요청수량
        DRIND       LIKE ZLET0401-INDQTY,     "출하요청조장수
        STSTA(4),                             "재고상태
        LFIMG_DR    LIKE LIPS-LFIMG,          "납품생성수량-출하요청
        LFIMG       LIKE LIPS-LFIMG,          "납품생성수량-오더
        ODREM       LIKE ZLET0401-KWMENG,     "오더잔량
        REMMG       LIKE ZLET0401-REVMG,      "출하잔량
        PACK_CAT    LIKE ZEDT0230-PACKAGING_CAT, "포장유형
        DRUM_NO     LIKE ZEDT0230-DRUM_NO,    "드럼기호
        PACKDM      LIKE ZEDT0230-PACKING_DM, "포장재(드럼)코드
        NTGEW       LIKE MARA-NTGEW,          "제품총중량
        GEWEI       LIKE MARA-GEWEI,          "중량단위
        REVIW       LIKE ZLET0401-REVIW,      "출하검토여부
        REVMG       LIKE ZLET0401-REVMG,      "출하확정수량
        RVIND       LIKE ZLET0401-INDQTY,     "출하확정조장수
        RVIND_LINK  LIKE ZLET0401-INDQTY,     "LINK 조장수
        LECFM       LIKE ZLET0401-LECFM,      "출하확정
        SDCFM       LIKE ZLET0401-SDCFM,      "영업확정
        CONFM,                                "납품문서 생성여부
        HLVORM      LIKE ZLET0400-LVORM,      "삭제지시자
        ILVORM      LIKE ZLET0401-LVORM,      "삭제지시자
        WADAT       LIKE LIKP-WADAT,
        RVSTA(2),                             "출하검토 상태

        OUT_WID     LIKE VTRLK-/BEV1/RPMNGLI, "ZEDT0210-OUT_WID,"폭/드럼
        PLAN_DIA    LIKE VTRLK-/BEV1/RPMNGLI, "ZEDT0210-PLAN_DIA,"약경/드럼
        DR_WEIGHT   LIKE VTRLK-/BEV1/RPMNGLI, "ZEDT0210-DR_WEIGHT,"드럼무게/개
        BRGEW       LIKE MARA-BRGEW,          "총중량(드럼포함)
        SKID_YN     LIKE AUSP-ATWRT,          "스퀴드여부
        ZREMARK1    LIKE ZLET0400-ZREMARK1,   "출하실요청사항
        BSTKD_E     LIKE VBKD-BSTKD_E,       "ASIS 작번

        FIXMG       TYPE VBAP-FIXMG,          "MTO/MTS 구분 기준
        NTGEW_M     TYPE MARA-NTGEW,          "순중량
        MEINS_MM    TYPE MARA-MEINS,
        MEINS_KG    TYPE MARA-MEINS,
        MVGR3       TYPE VBAP-MVGR3,          "자재그룹3(정조장여부판단)
*        aenam      LIKE zlet0401-aenam,
        CFM_NAME    LIKE ADRP-NAME_LAST,
        REQNAM      LIKE ADRP-NAME_LAST,
        IV_NO       LIKE ZLET0006-IV_NO,     "거래명세서번호
        MARK,
        HDSEL,
        ITSEL,

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: BEGIN OF GT_0401 OCCURS 0,
        DLVRQ LIKE ZLET0401-DLVRQ,      "출하요청번호
        VBELN LIKE ZLET0401-VBELN,      "판매오더
        POSNR LIKE ZLET0401-POSNR,      "판매오더품목
        LECFM LIKE ZLET0401-LECFM,      "출하확정
        REVMG LIKE ZLET0401-REVMG,
      END   OF GT_0401.

DATA: GT_0402       LIKE ZLET0402 OCCURS 0 WITH HEADER LINE.

*{ 기능개선 157326 - 변경
DATA: BEGIN OF GS_DELV,
        POST_CODE1 LIKE ZLET0400-POST_CODE1, "우편번호
        LAND1      LIKE ZLET0400-LAND1,      "국가
        LZONE      LIKE ZLET0400-LZONE,      "운송지역
        CITY1      LIKE ZLET0400-CITY1,      "상세주소
        STREET     LIKE ZLET0400-STREET,     "상세주소
        EXTENSION1 LIKE ZLET0400-EXTENSION1, "수령인
        TEL_NUMBER LIKE ZLET0400-TEL_NUMBER, "연락처
        ARIND      LIKE ZLET0400-ARIND,      "도착시간 입력여부
        ARRDT      LIKE ZLET0400-ARRDT,      "도착일
        ARRTM      LIKE ZLET0400-ARRTM,      "도착시간
        IMMDT      LIKE ZLET0400-IMMDT,      "긴급출하
        ALONE      LIKE ZLET0400-ALONE,      "단독여부(혼적)
        VHCTP      LIKE ZLET0400-VHCTP,      "차량제한여부
        VHCTX      LIKE TVSAKT-BEZEI,        "내역
        BKNFT      LIKE ZLET0400-BKNFT,      "왕복여부
        DIVID      LIKE ZLET0400-DIVID,      "분할출하
        ZREQ_TYPE  LIKE ZLET0400-ZREQ_TYPE,  "직송의뢰 신청 유형
        TRTYP      LIKE ZLET0400-TRTYP,      "운송유형
        REMARK     LIKE ZLET0400-REMARK,     "비고
        ZREMARK1   LIKE ZLET0400-ZREMARK1,   "출하실요청사항
      END   OF GS_DELV.

DATA: BEGIN OF GT_STOCK OCCURS 0,
        WERKS    LIKE T001W-WERKS,
        WERKS_TX LIKE T001W-NAME1,
        LGORT    LIKE T001L-LGORT,
        LGORT_TX LIKE T001L-LGOBE,
        KUNNR    LIKE VBAK-KUNNR,
        KUNNR_TX LIKE ADRC-NAME1,
        VBELN    LIKE VBAP-VBELN,
        POSNR    LIKE VBAP-POSNR,
        MATNR    LIKE VBAP-MATNR,
        MATNR_TX LIKE MAKT-MAKTX,
        MENGE    LIKE MCHB-CLABS,
        LENGTH   LIKE ZLET0401-INDLEN,     "조장
        FACTOR   LIKE ZLET0401-INDQTY,     "조장수
        MEINS    LIKE MARA-MEINS,
        DESC(10),                      "재고상태
        INDMEI   LIKE MARA-MEINS,          "조장수 단위
        ZSORT(1),
      END OF GT_STOCK.

*DATA: GV_TRTYP      LIKE ZLET0400-TRTYP,
*      GV_ARRDT      LIKE ZLET0400-ARRDT,
*      GV_ARRTM      LIKE ZLET0400-ARRTM.
*} 기능개선 157326 - 변경

DATA: GV_EDATU      LIKE ZLET0401-EDATU.

DATA: GV_ERROR,
      GV_ANSWER.

DATA: GS_MAIN  LIKE GT_MAIN,
      GV_POSNR LIKE LIPS-POSNR.

DATA: OK_CODE LIKE SY-UCOMM,
      OK_SAVE LIKE SY-UCOMM.

DATA: GV_LGORT_M(1). "재고 저장위치 MULTI

*___BDC용 변수
TABLES: CTU_PARAMS.

DATA: GV_MODE       LIKE CTU_PARAMS-DISMODE VALUE 'N'.

DATA: BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END   OF GT_BDCTAB.

DATA: GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

*___텍스트 읽기용
DATA: BEGIN OF GT_KNA1 OCCURS 0,
        KUNNR LIKE KNA1-KUNNR,
        NAME1 LIKE KNA1-NAME1,
      END   OF GT_KNA1.

DATA: BEGIN OF GT_MAKT OCCURS 0,
        MATNR LIKE MARA-MATNR,
        MAKTX LIKE MAKT-MAKTX,
      END   OF GT_MAKT.

DATA: BEGIN OF GT_MATNR OCCURS 0,
        MATNR LIKE MARA-MATNR,
        MAKTX LIKE MAKT-MAKTX,
        NTGEW LIKE MARA-NTGEW,
        GEWEI LIKE MARA-GEWEI,
        MEINS LIKE MARA-MEINS,
      END OF GT_MATNR.

DATA: BEGIN OF GT_TVSTT OCCURS 0,
        VSTEL LIKE TVSTT-VSTEL,
        VTEXT LIKE TVSTT-VTEXT,
      END   OF GT_TVSTT.

DATA: BEGIN OF GT_T001W OCCURS 0,
        WERKS LIKE T001W-WERKS,
        NAME1 LIKE T001W-NAME1,
      END   OF GT_T001W.

DATA: BEGIN OF GT_T001L OCCURS 0,
        WERKS LIKE T001L-WERKS,
        LGORT LIKE T001L-LGORT,
        LGOBE LIKE T001L-LGOBE,
      END OF GT_T001L.

DATA: BEGIN OF GT_TVSAK OCCURS 0,
        SDABW LIKE TVSAKT-SDABW,
        BEZEI LIKE TVSAKT-BEZEI,
      END   OF GT_TVSAK.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE LIKE SY-UCOMM,
      END   OF GT_EXCL.

DATA : BEGIN OF GT_CHAR OCCURS 0,
         VBELN LIKE VBAP-VBELN,
         POSNR LIKE VBAP-POSNR,
         ATNAM LIKE CABN-ATNAM,
         ATWRT LIKE IBSYMBOL-ATWRT,
         ATFLV LIKE IBSYMBOL-ATFLV,
         ATFLB LIKE IBSYMBOL-ATFLB,
         ATFOR LIKE CABN-ATFOR,
         ANZDZ LIKE CABN-ANZDZ,
       END   OF GT_CHAR.

DATA: BEGIN OF GT_PACKDM OCCURS 0,
        VBELN         LIKE VBAP-VBELN,
        POSNR         LIKE VBAP-POSNR,
        PACKAGING_CAT LIKE ZEDT0230-PACKAGING_CAT,
        DRUM_NO       LIKE ZEDT0230-DRUM_NO,
        PACKING_DM    LIKE  ZEDT0230-PACKING_DM,
      END OF GT_PACKDM.

DATA: GT_ZGTEDSIF0034 TYPE TABLE OF ZGTEDSIF0034.

DATA: BEGIN OF GT_LIPS_SUM OCCURS 0,
        VBELN LIKE LIPS-VBELN,
        POSNR LIKE LIPS-POSNR,
        LFIMG LIKE LIPS-LFIMG,
      END OF GT_LIPS_SUM.

DATA:GT_LSTOCK_ITEM   LIKE TABLE OF ZGTSDSIF0100.
DATA:GT_LSTOCK_DETAIL   LIKE TABLE OF ZGTSDSIF0101.
DATA:GT_ESTOCK_ITEM   LIKE TABLE OF ZGTSDSIF0102.
DATA:GT_ESTOCK_DETAIL   LIKE TABLE OF ZGTSDSIF0103.

DATA:GT_ZLET0401 TYPE TABLE OF ZLET0401.

*___ALV용 변수
DATA: GC_CONTAINER_NAME    TYPE SCRFNAME VALUE 'CONTAINER',
      GC_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID          TYPE REF TO CL_GUI_ALV_GRID,
      GC_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID2         TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER     TYPE REF TO LCL_EVENT_HANDLER,
      GS_LAYOUT            TYPE LVC_S_LAYO,
      GT_SORT              TYPE LVC_T_SORT WITH HEADER LINE,
      GT_FIELDCAT          TYPE LVC_T_FCAT WITH HEADER LINE,
      GS_FIELDCAT          TYPE LVC_S_FCAT,
      GS_SCROLL            TYPE LVC_S_STBL,
      GT_COLS              TYPE LVC_T_COL,
      GS_COLS              TYPE LVC_S_COL,
      GT_ROWS              TYPE LVC_T_ROW,
      GS_LAYOUT2           TYPE LVC_S_LAYO,
      GT_SORT2             TYPE LVC_T_SORT WITH HEADER LINE,
      GS_SORT              TYPE LVC_S_SORT,
      GT_FIELDCAT2         TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_COLS2             TYPE LVC_T_COL,
      GS_ROWS              TYPE LVC_S_ROW.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GS_VARIANT  TYPE DISVARIANT,
      GS_VARIANT2 TYPE DISVARIANT,
      GS_VARIANT3 TYPE DISVARIANT,
      GV_ITAB     LIKE GS_FIELDCAT-TABNAME,
      GV_POS      LIKE GS_FIELDCAT-COL_POS.

RANGES: GR_LGORT FOR T001L-LGORT.

RANGES: GR_LGORT_DIR FOR T001L-LGORT.

RANGES: GR_ATNAM FOR CABN-ATNAM.

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
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high   = &5.
  APPEND &1.
END-OF-DEFINITION.
