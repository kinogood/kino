*&---------------------------------------------------------------------*
*& Include ZGTMMR6200TOP
*&---------------------------------------------------------------------*

TABLES : ZGTMMT6210, ZGTEDT2121, EKPO.


RANGES : GR_ORDCH FOR ZGTMMT6210-ORDCH.
*        GR_CNFCL FOR ZGTMMT6210-CNFCL.

DATA : GV_BUKRS LIKE T001K-BUKRS.

DATA : BEGIN OF GT_LOCK OCCURS 0,
         JOB_NO LIKE ZGTMMT6210-JOB_NO,
       END   OF GT_LOCK.

DATA : GT_ENQ LIKE SEQG3 OCCURS 0 WITH HEADER LINE.

"구매요청/구매오더 자재명(ERP) 위치변경(PSJ 25.05.09)

DATA : BEGIN OF GT_HBAN OCCURS 0,
         STATUS      LIKE ICON-ID,                "Msg
         WERKS       LIKE ZGTMMT6210-WERKS,       "플랜트
         CNFCL       LIKE ZGTMMT6210-CNFCL,       "확정취소
         KNTTP       LIKE ZGTMMT6210-KNTTP,       "ACC
         PSTYP       LIKE ZGTMMT6210-PSTYP,       "ItmT
         JOB_NO      LIKE ZGTMMT6210-JOB_NO,      "제조지시번호
         MATNR       LIKE ZGTMMT6210-MATNR,       "자재코드
         TXZ01       LIKE ZGTMMT6210-TXZ01,       "자재명(MES)
*        TXZ01_ERP   LIKE MAKT-MAKTX,             "자재명(ERP)
         MENGE       LIKE ZGTMMT6210-MENGE,       "수량
         MEINS       LIKE ZGTMMT6210-MEINS,       "단위
         EINDT       LIKE ZGTMMT6210-EINDT,       "납품일

         FLIEF       LIKE ZGTMMT6210-FLIEF,       "고정 공급업체
         FLIEF_NM    LIKE LFA1-NAME1,             "고정 공급업체명
         INFNR       LIKE EBAN-INFNR,             "정보레코드 EINA
         BANFN       LIKE EBAN-BANFN,             "구매요청번호
         BNFPO       LIKE EBAN-BNFPO,             "품목
         EBELN       LIKE EKPO-EBELN,             "구매오더번호
         EBELP       LIKE EKPO-EBELP,             "품목
         STATU       LIKE EBAN-STATU,             "구매요청 처리상태
         EMLIF       LIKE ZGTMMT6210-EMLIF,       "직납공급처
         EMLIF_NM    LIKE LFA1-NAME1,             "직납공급처명

         AFNAM       LIKE ZGTMMT6210-AFNAM,       "요청자
         BSTYP       LIKE ZGTMMT6210-BSTYP,       "Cat
         EKORG       LIKE ZGTMMT6210-EKORG,       "구매조직
         EKGRP       LIKE ZGTMMT6210-EKGRP,       "PGrp
         MTART       LIKE MARA-MTART,             "자재유형
         MATKL       LIKE ZGTMMT6210-MATKL,       "자재그룹
         LGORT       LIKE ZGTMMT6210-LGORT,       "저장위치
         ABLAD       LIKE ZGTMMT6210-ABLAD,       "하역지점
         TXZ01_ERP   LIKE MAKT-MAKTX,             "자재명(ERP)
         SOBKZ       LIKE ZGTMMT6210-SOBKZ,       "SP
         VBELN       LIKE ZGTMMT6210-VBELN,       "판매오더
         VBELP       LIKE ZGTMMT6210-VBELP,       "품목
         ZMTGRP      LIKE ZGTMMT6210-ZMTGRP,      "발주그룹
         ZMTGRPT     LIKE ZGTMMT6100-ZMTGRPT,     "발주그룹명
         JOB_NM      LIKE ZGTEDT2121-ZJOB_NAME,   "제조지시명
         LINE_NO     LIKE ZGTMMT6210-LINE_NO,     "라인번호
         SERIAL_INFO LIKE ZGTMMT6210-SERIAL_INFO, "시리얼정보
         PJT_NO      LIKE ZGTEDT2121-ZPJT_NO,     "프로젝트
         PJT_NM      LIKE PROJ-POST1,             "프로젝트명
         MES_REQ     LIKE ZGTMMT6210-MES_REQ,     "MES 요청번호
         MES_SEQ     LIKE ZGTMMT6210-MES_SEQ,     "MES 요청순번
         SAKTO       LIKE ZGTMMT6210-SAKTO,       "G/L 계정
         KOSTL       LIKE ZGTMMT6210-KOSTL,       "코스트센터
         ZAPRID      LIKE SY-UNAME,               "승인자
         ZAPRDT      LIKE SY-DATLO,               "승인일
         JOBLS       LIKE ZGTMMT6210-JOBLS,       "제조지시 요청번호
         ERDAT_LOCAL LIKE ZGTMMT6210-ERDAT_LOCAL, "생성일
         DEL_REQDT   LIKE ZGTMMT6600-ERDAT_LOCAL, "PO삭제 요청일
         CLCRS       LIKE ZGTMMT6600-CLCRS,       "삭제요청 사유

         IDX         LIKE SY-INDEX,
         MSG         TYPE BAL_T_MSG,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_HBAN.

DATA : BEGIN OF GT_MARC OCCURS 0,
         MATNR LIKE MARC-MATNR,
         WERKS LIKE MARC-WERKS,
         EKGRP LIKE MARC-EKGRP,
       END   OF GT_MARC.

FIELD-SYMBOLS : <GFS_MSG>   TYPE BAL_T_MSG,
                <GFS_TYL>   TYPE LVC_T_STYL,
                <GFS_COL>   TYPE LVC_T_SCOL,
                <GFS_STS>,
                <GFS_LIFNR>,
                <GFS_VNAME>,
                <GFS_INFNR>,
                <GFS_JOBLS>.


DATA : BEGIN OF GS_FCN,
         JOB_NO LIKE ZGTMMT6210-JOB_NO, "제조지시번호
         ZMTGRP LIKE ZGTMMT6210-ZMTGRP, "발주그룹
         EKORG  LIKE ZGTMMT6210-EKORG,  "구매조직
         WERKS  LIKE ZGTMMT6210-WERKS,  "플랜트

         MATNR  LIKE ZGTMMT6210-MATNR,  "자재코드
         EINDT  LIKE ZGTMMT6210-EINDT,  "납품일

         KNTTP  LIKE ZGTMMT6210-KNTTP,  "ACC
         PSTYP  LIKE ZGTMMT6210-PSTYP,  "ItmT
         MATKL  LIKE ZGTMMT6210-MATKL,  "자재그룹
         IDNLF  LIKE ZGTMMT6210-IDNLF,  "외주공정 자재그룹
       END   OF GS_FCN.

DATA : BEGIN OF GS_COM,
         EKORG LIKE ZGTMMT6210-EKORG, "구매조직
         KNTTP LIKE ZGTMMT6210-KNTTP, "ACC
         PSTYP LIKE ZGTMMT6210-PSTYP, "ItmT
         WERKS LIKE ZGTMMT6210-WERKS, "플랜트
         MATNR LIKE ZGTMMT6210-MATNR, "자재코드
         MATKL LIKE ZGTMMT6210-MATKL, "자재그룹
         EINDT LIKE ZGTMMT6210-EINDT, "납품일

         FLIEF LIKE ZGTMMT6210-FLIEF, "고정 공급업체
         EMLIF LIKE ZGTMMT6210-EMLIF, "직납공급처
       END   OF GS_COM.

DATA : BEGIN OF GS_CFV,
         FLIEF    LIKE ZGTMMT6210-FLIEF, "고정 공급업체
         FLIEF_NM LIKE LFA1-NAME1,       "고정 공급업체명
         INFNR    LIKE EINA-INFNR,       "정보레코드
       END   OF GS_CFV.

DATA : BEGIN OF GS_CSV,
         EMLIF    LIKE ZGTMMT6210-EMLIF, "직납공급처
         EMLIF_NM LIKE LFA1-NAME1,       "직납공급처명
       END   OF GS_CSV.

DATA : BEGIN OF GS_OSC,
         TYPE,
         MATKL LIKE ZGTMMT6210-MATKL, "자재그룹
         MENGE LIKE ZGTMMT6210-MENGE, "수량
         ONETW LIKE ZGTMMT6210-NETWR, "외주가공/OEM 금액
         OWAER LIKE ZGTMMT6210-WAERS, "Curr
************************************************************************
         "기준 변경(PSJ 25.02.10) -> 기존 로직 주석처리!
*        TYPE,
*        INFNR TYPE INFNR,
*        BSTMG TYPE BSTMG,
*        ONETW LIKE ZGTMMT6210-NETWR, "외주가공/OEM 금액
************************************************************************
       END   OF GS_OSC.

DATA : BEGIN OF GS_INF,
         INFNR LIKE EINA-INFNR,  "정보레코드
*        NETWR LIKE EKPO-NETWR,  "PO 금액
         NETPR LIKE KONP-KBETR,  "Info 단가
         WAERS LIKE KONP-KONWA,  "Curr.
         PEINH LIKE KONP-KPEIN,  "Per
         BPRME LIKE KONP-KMEIN,  "OPU
       END   OF GS_INF.

*******************************************************************
DATA : BEGIN OF GT_HBES OCCURS 0,
         STATUS      LIKE ICON-ID,                "Msg
         WERKS       LIKE ZGTMMT6210-WERKS,       "플랜트
         CNFCL       LIKE ZGTMMT6210-CNFCL,       "확정취소
         KNTTP       LIKE ZGTMMT6210-KNTTP,       "ACC
         PSTYP       LIKE ZGTMMT6210-PSTYP,       "ItmT
         JOB_NO      LIKE ZGTMMT6210-JOB_NO,      "제조지시번호
         LINE_NO     LIKE ZGTMMT6210-LINE_NO,     "라인번호
         SERIAL_INFO LIKE ZGTMMT6210-SERIAL_INFO, "시리얼정보
         MATNR       LIKE ZGTMMT6210-MATNR,       "자재코드
         TXZ01       LIKE ZGTMMT6210-TXZ01,       "자재명(MES)
*        TXZ01_ERP   LIKE MAKT-MAKTX,             "자재명(ERP)
         MENGE       LIKE ZGTMMT6210-MENGE,       "수량
         MEINS       LIKE ZGTMMT6210-MEINS,       "단위
         ORDCH       LIKE ZGTMMT6210-ORDCH,       "전환
         EINDT       LIKE ZGTMMT6210-EINDT,       "납품일

         FLIEF       LIKE ZGTMMT6210-FLIEF,       "고정 공급업체
         FLIEF_NM    LIKE LFA1-NAME1,             "고정 공급업체명
         INFNR       LIKE EKPO-INFNR,             "정보레코드
         EBELN       LIKE EKPO-EBELN,             "구매오더번호
         EBELP       LIKE EKPO-EBELP,             "품목
         EMLIF       LIKE ZGTMMT6210-EMLIF,       "직납공급처
         EMLIF_NM    LIKE LFA1-NAME1,             "직납공급처명

         AFNAM       LIKE ZGTMMT6210-AFNAM,       "요청자
         BSTYP       LIKE ZGTMMT6210-BSTYP,       "Cat

         WORK,                                    "업무(구분자)
         WEMNG       LIKE EKET-WEMNG,             "납품수량

         WAERS       LIKE EKKO-WAERS,             "Curr.
         NETWR       LIKE EKPO-NETWR,             "PO 금액
         NETPR       LIKE EKPO-NETPR,             "Info 단가
         PEINH       LIKE EKPO-PEINH,             "Per
         BPRME       LIKE EKPO-BPRME,             "OPU

         EXPRC       LIKE ZGTMMT6210-EXPRC,       "외주공정 단가사용
         IDNLF       LIKE ZGTMMT6210-IDNLF,       "외주공정 자재그룹
         BSTMG       LIKE ZGTMMT6210-BSTMG,       "가공 수량
         BSTME       LIKE ZGTMMT6210-BSTME,       "가공 단위

         OINFR       LIKE ZGTMMT6210-INFNR,       "외주공정 Info
         ONETP       LIKE ZGTMMT6210-NETPR,       "외주공정 단가
         OPEIN       LIKE ZGTMMT6210-PEINH,       "Per
         OBSTM       LIKE ZGTMMT6210-BSTME,       "OPU
         ONETW       LIKE ZGTMMT6210-NETWR,       "외주가공/OEM 금액
         OWAER       LIKE ZGTMMT6210-WAERS,       "Curr

         EKORG       LIKE ZGTMMT6210-EKORG,       "구매조직
         EKGRP       LIKE ZGTMMT6210-EKGRP,       "PGrp
         MTART       LIKE MARA-MTART,             "자재유형
         MATKL       LIKE ZGTMMT6210-MATKL,       "자재그룹
         SOBKZ       LIKE ZGTMMT6210-SOBKZ,       "SP
         LGORT       LIKE ZGTMMT6210-LGORT,       "저장위치
         ABLAD       LIKE ZGTMMT6210-ABLAD,       "하역지점
         TXZ01_ERP   LIKE MAKT-MAKTX,             "자재명(ERP)
         VBELN       LIKE ZGTMMT6210-VBELN,       "판매오더
         VBELP       LIKE ZGTMMT6210-VBELP,       "품목
         ZMTGRP      LIKE ZGTMMT6210-ZMTGRP,      "발주그룹
         ZMTGRPT     LIKE ZGTMMT6100-ZMTGRPT,     "발주그룹명
         JOB_NM      LIKE ZGTEDT2121-ZJOB_NAME,   "제조지시명

         PJT_NO      LIKE ZGTEDT2121-ZPJT_NO,     "프로젝트
         PJT_NM      LIKE PROJ-POST1,             "프로젝트명
         MES_REQ     LIKE ZGTMMT6210-MES_REQ,     "MES 요청번호
         MES_SEQ     LIKE ZGTMMT6210-MES_SEQ,     "MES 요청순번
         SAKTO       LIKE ZGTMMT6210-SAKTO,       "G/L 계정
         KOSTL       LIKE ZGTMMT6210-KOSTL,       "코스트센터
         BSTAE       LIKE EKPO-BSTAE,             "확인 제어 EINE
         UMSON       LIKE ZGTMMT6210-UMSON,       "무상
         ZAPRID      LIKE SY-UNAME,               "승인자
         ZAPRDT      LIKE SY-DATLO,               "승인일
         JOBLS       LIKE ZGTMMT6210-JOBLS,       "제조지시 요청번호
         ERDAT_LOCAL LIKE ZGTMMT6210-ERDAT_LOCAL, "생성일
         ZWEIGHT     LIKE ZGTMMT6210-ZWEIGHT,     "중량(Kg)
         ZLENGTH_1   LIKE ZGTMMT6210-ZLENGTH_1,   "길이1(mm)
         ZLENGTH_2   LIKE ZGTMMT6210-ZLENGTH_2,   "길이2(mm)
         ZLENGTH_3   LIKE ZGTMMT6210-ZLENGTH_3,   "길이3(mm)
         ZLENGTH_4   LIKE ZGTMMT6210-ZLENGTH_4,   "길이4(mm)
         ZLENGTH_5   LIKE ZGTMMT6210-ZLENGTH_5,   "길이5(mm)
         ZLENGTH_6   LIKE ZGTMMT6210-ZLENGTH_6,   "길이6(mm)
         ZLENGTH_7   LIKE ZGTMMT6210-ZLENGTH_7,   "길이7(mm)

         IDX         LIKE SY-INDEX,
         MSG         TYPE BAL_T_MSG,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_HBES.

DATA : GS_HBES LIKE LINE OF GT_HBES.

DATA : BEGIN OF GT_CBES OCCURS 0.
DATA : GRP(85).
INCLUDE STRUCTURE GT_HBES.
DATA : END   OF GT_CBES.

"[주의!!] GT_HBES/GT_CBES 필드 동일하나, 필드 위치만 차이! 추가/삭제시 연동 필요! -> 필요 없어짐!!
*DATA : BEGIN OF GT_CBES OCCURS 0,
*         WERKS       LIKE ZGTMMT6210-WERKS,       "플랜트
*         FLIEF       LIKE ZGTMMT6210-FLIEF,       "고정 공급업체
*         EKGRP       LIKE ZGTMMT6210-EKGRP,       "PGrp
*         KNTTP       LIKE ZGTMMT6210-KNTTP,       "ACC
*         PSTYP       LIKE ZGTMMT6210-PSTYP,       "ItmT
*         MATNR       LIKE ZGTMMT6210-MATNR,       "자재코드
*         MATKL       LIKE ZGTMMT6210-MATKL,       "자재그룹
*         JOB_NO      LIKE ZGTMMT6210-JOB_NO,      "제조지시번호
*         LINE_NO     LIKE ZGTMMT6210-LINE_NO,     "라인번호
*         SERIAL_INFO LIKE ZGTMMT6210-SERIAL_INFO, "시리얼정보
*
*         STATUS      LIKE ICON-ID,                "Msg
*         CNFCL       LIKE ZGTMMT6210-CNFCL,       "확정취소
*         ZMTGRP      LIKE ZGTMMT6210-ZMTGRP,      "발주그룹
*         ZMTGRPT     LIKE ZGTMMT6100-ZMTGRPT,     "발주그룹명
*         TXZ01       LIKE ZGTMMT6210-TXZ01,       "자재명(MES)
*         TXZ01_ERP   LIKE MAKT-MAKTX,             "자재명(ERP)
*         MENGE       LIKE ZGTMMT6210-MENGE,       "수량
*         MEINS       LIKE ZGTMMT6210-MEINS,       "단위
*         ORDCH       LIKE ZGTMMT6210-ORDCH,       "전환
*         EINDT       LIKE ZGTMMT6210-EINDT,       "납품일
*
*         FLIEF_NM    LIKE LFA1-NAME1,             "고정 공급업체명
*         INFNR       LIKE EKPO-INFNR,             "정보레코드
*         EBELN       LIKE EKPO-EBELN,             "구매오더번호
*         EBELP       LIKE EKPO-EBELP,             "품목
*         EMLIF       LIKE ZGTMMT6210-EMLIF,       "직납공급처
*         EMLIF_NM    LIKE LFA1-NAME1,             "직납공급처명
*
*         AFNAM       LIKE ZGTMMT6210-AFNAM,       "요청자
*         BSTYP       LIKE ZGTMMT6210-BSTYP,       "Cat
*
*         WORK,                                    "업무(구분자)
*         WEMNG       LIKE EKET-WEMNG,             "납품수량
*
*         WAERS       LIKE EKKO-WAERS,             "Curr.
*         NETWR       LIKE EKPO-NETWR,             "PO 금액
*         NETPR       LIKE EKPO-NETPR,             "Info 단가
*         PEINH       LIKE EKPO-PEINH,             "Per
*         BPRME       LIKE EKPO-BPRME,             "OPU
*
*         EXPRC       LIKE ZGTMMT6210-EXPRC,       "외주공정 단가사용
*         IDNLF       LIKE ZGTMMT6210-IDNLF,       "외주공정 자재그룹
*         BSTMG       LIKE ZGTMMT6210-BSTMG,       "가공 수량
*         BSTME       LIKE ZGTMMT6210-BSTME,       "가공 단위
*
*         OINFR       LIKE ZGTMMT6210-INFNR,       "외주공정 Info
*         ONETP       LIKE ZGTMMT6210-NETPR,       "외주공정 단가
*         OPEIN       LIKE ZGTMMT6210-PEINH,       "Per
*         OBSTM       LIKE ZGTMMT6210-BSTME,       "OPU
*         ONETW       LIKE ZGTMMT6210-NETWR,       "외주가공/OEM 금액
*         OWAER       LIKE ZGTMMT6210-WAERS,       "Curr
*
*         EKORG       LIKE ZGTMMT6210-EKORG,       "구매조직
*         MTART       LIKE MARA-MTART,             "자재유형
*         SOBKZ       LIKE ZGTMMT6210-SOBKZ,       "SP
*         LGORT       LIKE ZGTMMT6210-LGORT,       "저장위치
*         ABLAD       LIKE ZGTMMT6210-ABLAD,       "하역지점
*         VBELN       LIKE ZGTMMT6210-VBELN,       "판매오더
*         VBELP       LIKE ZGTMMT6210-VBELP,       "품목
*         JOB_NM      LIKE ZGTEDT2121-ZJOB_NAME,   "제조지시명
*
*         PJT_NO      LIKE ZGTEDT2121-ZPJT_NO,     "프로젝트
*         PJT_NM      LIKE PROJ-POST1,             "프로젝트명
*         MES_REQ     LIKE ZGTMMT6210-MES_REQ,     "MES 요청번호
*         MES_SEQ     LIKE ZGTMMT6210-MES_SEQ,     "MES 요청순번
*         SAKTO       LIKE ZGTMMT6210-SAKTO,       "G/L 계정
*         KOSTL       LIKE ZGTMMT6210-KOSTL,       "코스트센터
*         BSTAE       LIKE EKPO-BSTAE,             "확인 제어 EINE
*         UMSON       LIKE ZGTMMT6210-UMSON,       "무상
*         ZAPRID      LIKE SY-UNAME,               "승인자
*         ZAPRDT      LIKE SY-DATLO,               "승인일
*         JOBLS       LIKE ZGTMMT6210-JOBLS,       "제조지시 요청번호
*         ERDAT_LOCAL LIKE ZGTMMT6210-ERDAT_LOCAL, "생성일
*         ZWEIGHT     LIKE ZGTMMT6210-ZWEIGHT,     "중량(Kg)
*         ZLENGTH_1   LIKE ZGTMMT6210-ZLENGTH_1,   "길이1(mm)
*         ZLENGTH_2   LIKE ZGTMMT6210-ZLENGTH_2,   "길이2(mm)
*         ZLENGTH_3   LIKE ZGTMMT6210-ZLENGTH_3,   "길이3(mm)
*         ZLENGTH_4   LIKE ZGTMMT6210-ZLENGTH_4,   "길이4(mm)
*         ZLENGTH_5   LIKE ZGTMMT6210-ZLENGTH_5,   "길이5(mm)
*         ZLENGTH_6   LIKE ZGTMMT6210-ZLENGTH_6,   "길이6(mm)
*         ZLENGTH_7   LIKE ZGTMMT6210-ZLENGTH_7,   "길이7(mm)
*
*         IDX         LIKE SY-INDEX,
*         MSG         TYPE BAL_T_MSG,
*         STYLE       TYPE LVC_T_STYL,
*         COLOR       TYPE LVC_T_SCOL,
*       END   OF GT_CBES.
*******************************************************************

DATA : BEGIN OF GT_IBES OCCURS 0,
         MES_CMP LIKE ZGTMMT6211-MES_CMP, "MES 구성품번호
         MATNR   LIKE ZGTMMT6211-MATNR,   "자재코드
         MAKTX   LIKE MAKT-MAKTX,         "자재명
         BDMNG   LIKE ZGTMMT6211-BDMNG,   "소요량
         MEINS   LIKE ZGTMMT6211-MEINS,   "단위
         UMLGO   LIKE RESB-UMLGO,         "출고 저장위치
         MTART   LIKE MARA-MTART,         "자재유형
         MES_REQ LIKE ZGTMMT6211-MES_REQ, "MES 요청번호
         MES_SEQ LIKE ZGTMMT6211-MES_SEQ, "MES 요청순번
         LABST   LIKE MARD-LABST,         "재고수량
         MEINS_M LIKE MARA-MEINS,         "재고단위
       END   OF GT_IBES.

DATA : BEGIN OF GT_DBES OCCURS 0,
         EBELN  LIKE EKPO-EBELN,
         EBELP  LIKE EKPO-EBELP,

         INFNR  LIKE EKPO-INFNR, "정보레코드
         NETPR  LIKE EKPO-NETPR, "Info 단가
         PEINH  LIKE EKPO-PEINH, "Per
         BPRME  LIKE EKPO-BPRME, "OPU

         STATUS LIKE ICON-ID,
         IDX    LIKE SY-INDEX,
         MSG    TYPE BAL_T_MSG,
         STYLE  TYPE LVC_T_STYL,
*        COLOR  TYPE LVC_T_SCOL,
       END   OF GT_DBES.

DATA : GS_CBES LIKE GT_CBES,
       GS_DBES LIKE GT_DBES.

DATA : GS_DBES_D LIKE GT_DBES.

DATA : BEGIN OF GS_LIF,
         FLIEF LIKE ZGTMMT6210-FLIEF, "고정 공급업체
         EMLIF LIKE ZGTMMT6210-EMLIF, "직납공급처
       END   OF GS_LIF.

DATA : BEGIN OF GT_RDPO OCCURS 0.
         INCLUDE STRUCTURE ZGTMMT6600.
DATA :   IDX LIKE SY-INDEX.
DATA : END   OF GT_RDPO.

DATA : BEGIN OF GT_RDPM OCCURS 0,
         SEQNO   LIKE ZGTMMT6212-SEQNO,
         EM_RECV LIKE ZGTMMT6212-EM_RECV,
       END   OF GT_RDPM.

DATA : GV_CLCRS LIKE ZGTMMT6600-CLCRS.

DATA : GT_MTXT TYPE SOLI_TAB,
       GS_MTXT TYPE SOLI.

DATA : GS_CREA LIKE ZGTMMS0001.


DATA : GV_FNM TYPE LVC_FNAME.

DATA : GV_CNT TYPE I,
       GV_IDX LIKE SY-INDEX.

DATA : GV_CHK,
       GV_ERR,
       GV_LCK,
       GV_REF,
       GV_ANS,
       GV_MSG(50).

DATA : GV_OKCODE LIKE SY-UCOMM,
       GV_TITLE  TYPE STRING.

DATA : GT_EXCD TYPE TABLE OF FCODE.

DATA : GT_STAB LIKE RSPARAMS   OCCURS 0 WITH HEADER LINE,
       GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GS_HND TYPE BALLOGHNDL.

DATA : GS_RHDR  LIKE BAPIMEREQHEADER,
       GS_RHDRX LIKE BAPIMEREQHEADERX,
       GT_RTN   LIKE BAPIRET2          OCCURS 0 WITH HEADER LINE,
       GT_RITM  LIKE BAPIMEREQITEMIMP  OCCURS 0 WITH HEADER LINE,
       GT_RITMX LIKE BAPIMEREQITEMX    OCCURS 0 WITH HEADER LINE,
       GT_RACT  LIKE BAPIMEREQACCOUNT  OCCURS 0 WITH HEADER LINE,
       GT_RACTX LIKE BAPIMEREQACCOUNTX OCCURS 0 WITH HEADER LINE,
       GT_RTXT  LIKE BAPIMEREQITEMTEXT OCCURS 0 WITH HEADER LINE.

DATA : GS_OHDR  LIKE BAPIMEPOHEADER,
       GS_OHDRX LIKE BAPIMEPOHEADERX,
       GT_OITM  LIKE BAPIMEPOITEM       OCCURS 0 WITH HEADER LINE,
       GT_OITMX LIKE BAPIMEPOITEMX      OCCURS 0 WITH HEADER LINE,
       GT_OSCD  LIKE BAPIMEPOSCHEDULE   OCCURS 0 WITH HEADER LINE,
       GT_OSCDX LIKE BAPIMEPOSCHEDULX   OCCURS 0 WITH HEADER LINE,
       GT_OACT  LIKE BAPIMEPOACCOUNT    OCCURS 0 WITH HEADER LINE,
       GT_OACTX LIKE BAPIMEPOACCOUNTX   OCCURS 0 WITH HEADER LINE,
       GT_OCND  LIKE BAPIMEPOCOND       OCCURS 0 WITH HEADER LINE,
       GT_OCNDX LIKE BAPIMEPOCONDX      OCCURS 0 WITH HEADER LINE,
       GT_OTXT  LIKE BAPIMEPOTEXT       OCCURS 0 WITH HEADER LINE,
       GT_OCMP  LIKE BAPIMEPOCOMPONENT  OCCURS 0 WITH HEADER LINE,
       GT_OCMPX LIKE BAPIMEPOCOMPONENTX OCCURS 0 WITH HEADER LINE.

DATA : GV_EBELP TYPE EBELP.

DATA : GV_EMSG(30),
       GV_PMSG(40),
       GV_RMSG(20).

DEFINE _COL_RNG.
  CLEAR : &1.
  IF &2 IS NOT INITIAL.
    &1-SIGN   = GC_I.
    &1-OPTION = GC_EQ.
    &1-LOW    = &2.
    COLLECT &1.
  ENDIF.
END-OF-DEFINITION.

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
            GC_H(1)            VALUE 'H',
            GC_I(1)            VALUE 'I',
            GC_K(1)            VALUE 'K',
            GC_L(1)            VALUE 'L',
            GC_M(1)            VALUE 'M',
            GC_N(1)            VALUE 'N',
            GC_O(1)            VALUE 'O',
            GC_S(1)            VALUE 'S',
            GC_X(1)            VALUE 'X',
            GC_0(1)            VALUE '0',
            GC_1(1)            VALUE '1',
            GC_3(1)            VALUE '3',
            GC_4(1)            VALUE '4',
            GC_5(1)            VALUE '5',
            GC_6(1)            VALUE '6',
            GC_7(1)            VALUE '7',
            GC_*(1)            VALUE '*',
            GC_BT(2)           VALUE 'BT',
            GC_EQ(2)           VALUE 'EQ',
            GC_NB(2)           VALUE 'NB',
            GC_PO(2)           VALUE 'PO',
            GC_PR(2)           VALUE 'PR',
            GC_01(2)           VALUE '01',
            GC_02(2)           VALUE '02',
            GC_ROH(3)          VALUE 'ROH',
            GC_001(3)          VALUE '001',
            GC_002(3)          VALUE '002',
            GC_C300(4)         VALUE 'C300',
            GC_C500(4)         VALUE 'C500',
            GC_C700(4)         VALUE 'C700',
            GC_0200(4)         VALUE '0200',
            GC_DVND(4)         VALUE 'DVND',
            GC_HALB(4)         VALUE 'HALB',
            GC_HAWA(4)         VALUE 'HAWA',
            GC_PBXX(4)         VALUE 'PBXX',
            GC_ROH1(4)         VALUE 'ROH1',
            GC_ROH2(4)         VALUE 'ROH2',
            GC_0001(4)         VALUE '0001',
            GC_0004(4)         VALUE '0004',
            GC_0007(4)         VALUE '0007',
            GC_COLOR(5)        VALUE 'COLOR',
            GC_STYLE(5)        VALUE 'STYLE',
            GC_EMLIF(5)        VALUE 'EMLIF',
            GC_FLIEF(5)        VALUE 'FLIEF',
            GC_OWAER(5)        VALUE 'OWAER',
            GC_P_EKORG(7)      VALUE 'P_EKORG',
            GC_P_WERKS(7)      VALUE 'P_WERKS',
            GC_ZGTMMR6100(10)  VALUE 'ZGTMMR6100',
            GC_ZGTMMR6300(10)  VALUE 'ZGTMMR6300',
            GC_S_APRDT-LOW(11) VALUE 'S_APRDT-LOW'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 32.
    PARAMETERS: P_BAN RADIOBUTTON GROUP GR1
                           USER-COMMAND GR1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (12) TEXT-R01 FOR FIELD P_BAN.

    SELECTION-SCREEN POSITION 52.
    PARAMETERS: P_BES RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (12) TEXT-R02 FOR FIELD P_BES.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK1.

"생성일(ERDAT_LOCAL) 조건 추가(PSJ 25.06.05)
"공급업체 조건 추가(PSJ 25.06.13)

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  PARAMETERS     : P_EKORG LIKE ZGTMMT6210-EKORG MEMORY ID EKO, "구매조직
                   P_WERKS LIKE ZGTMMT6210-WERKS MEMORY ID WRK. "플랜트
  SELECT-OPTIONS : S_EKGRP  FOR ZGTMMT6210-EKGRP,   "구매그룹
                   S_APRDT  FOR SY-DATLO,           "제조지시 승인일
                   S_JOBNO  FOR ZGTMMT6210-JOB_NO,  "제조지시 번호
                   S_FLIEF  FOR ZGTMMT6210-FLIEF,   "공급업체
                   S_EBELN  FOR EKPO-EBELN,              "구매문서
                   S_VBELN  FOR ZGTMMT6210-VBELN,   "판매오더
                   S_MTGRP  FOR ZGTMMT6210-ZMTGRP,  "발주그룹
                   S_MATKL  FOR ZGTMMT6210-MATKL,   "자재그룹
                   S_MATNR  FOR ZGTMMT6210-MATNR,   "자재코드
                   S_KNTTP  FOR ZGTMMT6210-KNTTP,   "계정 지정 범주
                   S_AFNAM  FOR ZGTMMT6210-AFNAM,   "요청자
                   S_ERDAT  FOR ZGTMMT6210-ERDAT.   "생성일

* "외주 전환 조건 추가(PSJ 25.04.09)
* SELECTION-SCREEN BEGIN OF LINE.
*   SELECTION-SCREEN POSITION 33.
*   PARAMETERS   : P_ORDCH AS CHECKBOX.
*   SELECTION-SCREEN COMMENT 1(08) TEXT-C01 FOR FIELD P_ORDCH.
* SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN ULINE.

  "납품일 ->삭제(PSJ 25.02.10)
* SELECT-OPTIONS : S_EINDT  FOR ZGTMMT6210-EINDT,   "납품일
  SELECT-OPTIONS : S_PJTNO  FOR ZGTEDT2121-ZPJT_NO, "프로젝트
                   S_JOBLS  FOR ZGTMMT6210-JOBLS,   "제조지시 요청번호
                   S_REQNO  FOR ZGTMMT6210-MES_REQ. "MES 요청번호
SELECTION-SCREEN END   OF BLOCK BK2.

"외주 전환 조건 변경(PSJ 25.04.10) : Check Box -> Radio Button
SELECTION-SCREEN BEGIN OF BLOCK BK4 WITH FRAME TITLE TEXT-S04.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 32.
    PARAMETERS: P_AOC RADIOBUTTON GROUP GR4
                           USER-COMMAND GR4 DEFAULT 'X' MODIF ID PO.
    SELECTION-SCREEN COMMENT (12) TEXT-R05 FOR FIELD P_AOC MODIF ID PO.

    SELECTION-SCREEN POSITION 52.
    PARAMETERS: P_YOC RADIOBUTTON GROUP GR4 MODIF ID PO.
    SELECTION-SCREEN COMMENT (12) TEXT-R06 FOR FIELD P_YOC MODIF ID PO.

    SELECTION-SCREEN POSITION 72.
    PARAMETERS: P_NOC RADIOBUTTON GROUP GR4 MODIF ID PO.
    SELECTION-SCREEN COMMENT (12) TEXT-R07 FOR FIELD P_NOC MODIF ID PO.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK4.

SELECTION-SCREEN BEGIN OF BLOCK BK3 WITH FRAME TITLE TEXT-S03.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 32.
    PARAMETERS: P_NCM RADIOBUTTON GROUP GR3
                           USER-COMMAND GR3 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (12) TEXT-R03 FOR FIELD P_NCM.

    SELECTION-SCREEN POSITION 52.
    PARAMETERS: P_YCM RADIOBUTTON GROUP GR3.
    SELECTION-SCREEN COMMENT (12) TEXT-R04 FOR FIELD P_YCM.

    SELECTION-SCREEN POSITION 72.
    PARAMETERS: P_ALL RADIOBUTTON GROUP GR3.
    SELECTION-SCREEN COMMENT (12) TEXT-R05 FOR FIELD P_ALL.
  SELECTION-SCREEN END   OF LINE.

  "확정 취소 조건 추가(PSJ 25.04.09) -> 구매요청시에만 적용(PSJ 25.05.09)
  "                             -> 구매오더시에도 적용(PSJ 25.06.19)
* SELECTION-SCREEN ULINE MODIF ID PR.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: P_CNFCL AS CHECKBOX. "MODIF ID PR.
    SELECTION-SCREEN COMMENT 1(08) TEXT-C02
      FOR FIELD P_CNFCL. "MODIF ID PR.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK3.
